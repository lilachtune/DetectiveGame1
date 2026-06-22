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

# ─── Инициализация ────────────────────────────────────────────────────────────

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible      = false

	btn_close.pressed.connect(close)
	tab_locations.pressed.connect(_show_locations)
	tab_characters.pressed.connect(_show_characters)
	tab_evidence.pressed.connect(_show_evidence)

	# Подключаем сигналы списков один раз (не при каждом populate)
	char_list.item_selected.connect(_on_char_selected)
	evidence_list.item_selected.connect(_on_evidence_selected)
	btn_test.pressed.connect(_open_ending_test)
	btn_test.visible = false

	btn_evidence_close.pressed.connect(_close_evidence_detail)
	evidence_detail_overlay.visible = false

	DiaryManager.diary_updated.connect(_refresh_current)

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

func _show_locations() -> void:
	_hide_all()
	locations_panel.visible = true
	_populate_locations()

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
	var labels := {
		"location_01": "Комната №304",
		"location_02": "Коридор",
	}
	for loc_id in DiaryManager.discovered_locations:
		var label: String = labels.get(loc_id, loc_id.replace("_", " ").capitalize())
		location_list.add_item("📍 " + label)

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
