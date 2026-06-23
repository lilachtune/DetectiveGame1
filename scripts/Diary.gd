## Diary.gd
## Дневник следователя. Открывается кнопкой "Дневник" (правый верх).
##
## Иерархия узлов в Diary.tscn:
##   Diary (Control)
##   ├─ Overlay      (ColorRect)
##   └─ MainPanel    (Control)
##       ├─ Header   (HBoxContainer)
##       │   ├─ Title    (Label)
##       │   └─ BtnClose (Button)
##       ├─ Sidebar  (VBoxContainer)
##       │   ├─ BtnLocations  (Button)
##       │   ├─ BtnCharacters (Button)
##       │   └─ BtnEvidence   (Button)
##       └─ ContentArea (Control)
##           ├─ LocationsPanel  (Control)
##           │   └─ LocationList  (ItemList)
##           ├─ CharactersPanel  (Control)
##           │   └─ CharList      (ItemList)
##           ├─ EvidencePanel    (Control)
##           │   └─ EvidenceList  (ItemList)
##           └─ CharDetailPanel  (Control)
##               ├─ Photo        (TextureRect)
##               ├─ NameLabel    (Label)
##               ├─ InfoText     (RichTextLabel)
##               ├─ DialogueList (ItemList)
##               └─ BtnTest      (Button)
##   └─ EvidenceDetailOverlay (Control)  ← всплывающая карточка улики
##       └─ Panel
##           └─ VBox
##               ├─ Header (HBoxContainer)
##               │   ├─ TitleLabel (Label)
##               │   └─ BtnClose   (Button)
##               └─ DetailText (RichTextLabel)
class_name Diary
extends Control

@onready var btn_close:        Button        = $MainPanel/Header/BtnClose
@onready var tab_locations:    Button        = $MainPanel/Sidebar/BtnLocations
@onready var tab_characters:   Button        = $MainPanel/Sidebar/BtnCharacters
@onready var tab_evidence:     Button        = $MainPanel/Sidebar/BtnEvidence

@onready var locations_panel:  Control       = $MainPanel/ContentArea/LocationsPanel
@onready var characters_panel: Control       = $MainPanel/ContentArea/CharactersPanel
@onready var evidence_panel:   Control       = $MainPanel/ContentArea/EvidencePanel
@onready var char_detail:      Control       = $MainPanel/ContentArea/CharDetailPanel

@onready var location_list:    ItemList      = $MainPanel/ContentArea/LocationsPanel/LocationList
@onready var char_list:        ItemList      = $MainPanel/ContentArea/CharactersPanel/CharList
@onready var evidence_list:    ItemList      = $MainPanel/ContentArea/EvidencePanel/EvidenceList

@onready var char_photo:       TextureRect   = $MainPanel/ContentArea/CharDetailPanel/Photo
@onready var char_name_label:  Label         = $MainPanel/ContentArea/CharDetailPanel/NameLabel
@onready var char_info_text:   RichTextLabel = $MainPanel/ContentArea/CharDetailPanel/InfoText
@onready var char_dlg_list:    ItemList      = $MainPanel/ContentArea/CharDetailPanel/DialogueList
@onready var btn_test:         Button        = $MainPanel/ContentArea/CharDetailPanel/BtnTest

@onready var evidence_detail_overlay: Control       = $EvidenceDetailOverlay
@onready var evidence_title_label:    Label         = $EvidenceDetailOverlay/Panel/VBox/Header/TitleLabel
@onready var evidence_detail_text:    RichTextLabel = $EvidenceDetailOverlay/Panel/VBox/DetailText
@onready var btn_evidence_close:      Button        = $EvidenceDetailOverlay/Panel/VBox/Header/BtnClose

var _ending_test_scene: PackedScene = preload("res://scenes/ui/EndingTest.tscn")
var _ending_test_instance: Control  = null

# Изображение спрайта локаций на фоне панели locations_panel
var _locations_bg: TextureRect = null
const LOCATIONS_IMAGE_PATH := "res://assets/ui/diary_locations.png"

# ─── Инициализация ────────────────────────────────────────────────────────────

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible      = false

	btn_close.pressed.connect(close)
	tab_locations.pressed.connect(_show_locations)
	tab_characters.pressed.connect(_show_characters)
	tab_evidence.pressed.connect(_show_evidence)

	# Подключаем сигналы списков один раз
	char_list.item_selected.connect(_on_char_selected)
	evidence_list.item_selected.connect(_on_evidence_selected)
	btn_test.pressed.connect(_open_ending_test)
	btn_test.visible = false

	btn_evidence_close.pressed.connect(_close_evidence_detail)
	evidence_detail_overlay.visible = false

	DiaryManager.diary_updated.connect(_refresh_current)
	
	# Создаём фон для панели локаций (скрытый по умолчанию)
	_create_locations_background()

# ─── Создание фона локаций ──────────────────────────────────────────────────

func _create_locations_background() -> void:
	_locations_bg = TextureRect.new()
	_locations_bg.name = "LocationsBg"
	_locations_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_locations_bg.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	_locations_bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_locations_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_locations_bg.visible = false
	
	var tex := _load_locations_texture()
	if tex:
		_locations_bg.texture = tex
	else:
		_locations_bg.texture = _create_placeholder_texture()
	
	locations_panel.add_child(_locations_bg)

func _load_locations_texture() -> Texture2D:
	if ResourceLoader.exists(LOCATIONS_IMAGE_PATH):
		return load(LOCATIONS_IMAGE_PATH)
	return null

func _create_placeholder_texture() -> Texture2D:
	var image := Image.create(800, 600, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.15, 0.12, 0.2, 1.0))
	var tex := ImageTexture.new()
	tex.set_image(image)
	return tex

# ─── Открытие / Закрытие ─────────────────────────────────────────────────────

func open() -> void:
	visible = true
	_show_locations()

func close() -> void:
	visible = false

# ─── Переключение вкладок ─────────────────────────────────────────────────────

func _hide_all() -> void:
	locations_panel.visible  = false
	characters_panel.visible = false
	evidence_panel.visible   = false
	char_detail.visible      = false
	if _locations_bg:
		_locations_bg.visible = false

func _show_locations() -> void:
	_hide_all()
	locations_panel.visible = true
	_populate_locations()
	if _locations_bg:
		_locations_bg.visible = true

func _show_characters() -> void:
	_hide_all()
	characters_panel.visible = true
	_populate_characters()

func _show_evidence() -> void:
	_hide_all()
	evidence_panel.visible = true
	_populate_evidence()

# ─── Заполнение списков ───────────────────────────────────────────────────────

func _populate_locations() -> void:
	location_list.clear()
	
	# Названия локаций
	var labels := {
		"location_01": "Комната №304",
		"location_02": "Коридор",
		"location_03": "Кабинет",
		"location_04": "Кухня",
		"location_05": "Столовая",
		"location_06": "Главная спальня",
		"location_07": "Гостевая спальня",
		"location_08": "Подвал",
		"location_09": "Чердак",
		"location_10": "Сад",
		"location_11": "Гараж",
		"location_12": "Бальный зал",
		"location_13": "Коридор второго этажа",
		"location_14": "Ванная комната",
		"location_15": "Беседка",
	}
	
	var total := DiaryManager.LOCATION_ORDER.size()
	var unlocked := DiaryManager.unlocked_location_index
	
	for i in range(total):
		var loc_id := DiaryManager.LOCATION_ORDER[i]
		var is_unlocked := i < unlocked
		var is_current := i == unlocked - 1
		
		var display_text: String
		if is_unlocked:
			display_text = "🌐 %s" % labels.get(loc_id, loc_id)
		elif is_current:
			display_text = "🔒 %s (текущая)" % labels.get(loc_id, loc_id)
		else:
			display_text = "⬛ %s" % labels.get(loc_id, loc_id)
		
		location_list.add_item(display_text)
		# Отмечаем цветом: unlocked - белый, current - голубой, locked - серый
		if is_unlocked:
			location_list.set_item_custom_fg_color(i, Color(1.0, 0.95, 0.85))
		elif is_current:
			location_list.set_item_custom_fg_color(i, Color(0.7, 0.8, 1.0))
		else:
			location_list.set_item_custom_fg_color(i, Color(0.4, 0.4, 0.4))

func _populate_characters() -> void:
	char_list.clear()
	for char_id in DiaryManager.get_discovered_characters():
		var d: Dictionary = DiaryManager.characters[char_id]
		char_list.add_item("🕵 " + d["name"] + " " + d["surname"])
		char_list.set_item_metadata(char_list.item_count - 1, char_id)

func _populate_evidence() -> void:
	evidence_list.clear()
	for ev_id in DiaryManager.get_discovered_evidence():
		var d: Dictionary = DiaryManager.evidence[ev_id]
		evidence_list.add_item("🔍 " + d["title"])
		evidence_list.set_item_metadata(evidence_list.item_count - 1, ev_id)

# ─── Детали персонажа ─────────────────────────────────────────────────────────

func _on_char_selected(idx: int) -> void:
	var char_id: String = char_list.get_item_metadata(idx)
	_show_char_detail(char_id)

func _show_char_detail(char_id: String) -> void:
	_hide_all()
	char_detail.visible = true
	var d: Dictionary   = DiaryManager.characters[char_id]

	char_name_label.text = d["name"] + " " + d["surname"]

	# Фото
	if ResourceLoader.exists(d.get("photo_path", "")):
		char_photo.texture = load(d["photo_path"])
	else:
		char_photo.texture = null

	# Текст с информацией
	var txt := "[b]Общая информация:[/b]\n%s\n\n" % d.get("info", "")
	txt += "[b]Мотив:[/b] %s\n\n"  % d.get("motive", "—")
	txt += "[b]Алиби:[/b] %s\n\n"  % d.get("alibi",  "—")
	var interr: Array = d.get("interrogations", [])
	if interr.size() > 0:
		txt += "[b]Допросы:[/b]\n"
		for line in interr:
			txt += "• %s\n" % line
	char_info_text.text = txt

	# Завершённые диалоги с этим персонажем
	char_dlg_list.clear()
	for dlg_id in DiaryManager.get_dialogues_for_character(char_id):
		var dlg: Dictionary = DiaryManager.dialogue_history[dlg_id]
		for line in dlg.get("lines", []):
			char_dlg_list.add_item(
				"[%s]: %s" % [line.get("speaker", "?"), line.get("text", "")]
			)

	btn_test.visible = GameManager.story_completed

# ─── Детали улики ─────────────────────────────────────────────────────────────

func _on_evidence_selected(idx: int) -> void:
	var ev_id: String = evidence_list.get_item_metadata(idx)
	_show_evidence_detail(ev_id)

func _show_evidence_detail(ev_id: String) -> void:
	var d: Dictionary = DiaryManager.evidence[ev_id]

	evidence_title_label.text = "🔍  " + d.get("title", "Улика")
	var txt := "[b]Описание:[/b]\n%s\n\n" % d.get("description", "")
	txt += "[b]Где найдено:[/b] \n%s\n\n" % d.get("location_found", "—")
	txt += "[b]Обстоятельства:[/b] \n%s" % d.get("circumstances", "—")
	evidence_detail_text.text = txt

	evidence_detail_overlay.visible = true

func _close_evidence_detail() -> void:
	evidence_detail_overlay.visible = false

# ─── Финальный тест ───────────────────────────────────────────────────────────

func _open_ending_test() -> void:
	if not _ending_test_instance:
		_ending_test_instance = _ending_test_scene.instantiate()
		add_child(_ending_test_instance)
	if _ending_test_instance.has_method("open"):
		_ending_test_instance.open()

# ─── Обновление при изменении дневника ───────────────────────────────────────

func _refresh_current() -> void:
	if not visible:
		return
	if locations_panel.visible:
		_populate_locations()
	elif characters_panel.visible:
		_populate_characters()
	elif evidence_panel.visible:
		_populate_evidence()
