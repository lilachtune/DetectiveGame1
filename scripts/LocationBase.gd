## LocationBase.gd
## Базовый класс всех 15 локаций.
##
## Ожидаемая иерархия узлов в сцене локации:
##   LocationXX (Node2D)                       ← скрипт LocationXX.gd (extends LocationBase)
##   ├─ Background   (Sprite2D)                ← PNG-фон
##   ├─ Characters   (Node2D)                  ← дочерние CharacterBase
##   ├─ InteractiveAreas (Node2D)              ← Area2D-зоны
##   └─ UI           (CanvasLayer)
##       ├─ DiaryButton  (Button)
##       ├─ DialogueBox  (instance DialogueBox.tscn)
##       ├─ PauseMenu    (instance PauseMenu.tscn)
##       └─ Diary        (instance Diary.tscn)
extends Node2D

@export var location_id:        String       = "location_01"
@export var location_name:      String       = "Локация"
@export var location_music:     AudioStream
@export var background_texture: Texture2D

## Словарь переходов: { "Метка выхода" -> "LocationXX" }
@export var exits: Dictionary = {}

@onready var background:    Node        = $Background
@onready var ui_layer:      CanvasLayer = $UI
@onready var dialogue_box               = $UI/DialogueBox
@onready var pause_menu                 = $UI/PauseMenu
@onready var diary                      = $UI/Diary
@onready var diary_button:  Button      = $UI/DiaryButton

var is_busy: bool = false
var diary_overlay: Control = null

# Готовая сцена с кнопками на изображении diary.png
const HOTSPOTS_SCENE := preload("res://scenes/ui/DiaryHotspots.tscn")
const LOCATIONS_SCENE := preload("res://scenes/ui/DiaryLocations.tscn")

# ─── Инициализация ────────────────────────────────────────────────────────────

func _ready() -> void:
	DiaryManager.discover_location(location_id)
	_apply_background()

	if location_music:
		AudioManager.play_music(location_music)

	if diary_button:
		diary_button.theme_type_variation = &"HudButton"
		diary_button.text = ""
		diary_button.icon = preload("res://assets/icon_diary.png")
		diary_button.expand_icon = true
		diary_button.flat = true
		diary_button.custom_minimum_size = Vector2(72, 72)
		diary_button.pressed.connect(_open_diary)

	if dialogue_box and dialogue_box.has_signal("dialogue_finished"):
		dialogue_box.dialogue_finished.connect(_on_dialogue_finished)

	_setup_location()

func _setup_location() -> void:
	pass

func _apply_background() -> void:
	if not background or not background_texture:
		return
	if background is Sprite2D:
		var sprite: Sprite2D = background as Sprite2D
		sprite.texture = background_texture
		var viewport_size: Vector2 = get_viewport_rect().size
		if viewport_size.x > 0.0 and viewport_size.y > 0.0:
			var tex_size: Vector2 = background_texture.get_size()
			var scale_factor: float = max(viewport_size.x / tex_size.x, viewport_size.y / tex_size.y)
			sprite.centered = true
			sprite.offset = Vector2.ZERO
			sprite.position = viewport_size / 2.0
			sprite.scale = Vector2.ONE * scale_factor
	elif background is TextureRect:
		var rect := background as TextureRect
		rect.texture = background_texture
		rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		rect.stretch_mode = TextureRect.STRETCH_SCALE

# ─── Ввод ─────────────────────────────────────────────────────────────────────

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if diary_overlay != null:
			_close_diary_overlay()
			get_viewport().set_input_as_handled()
			return
		if not is_busy:
			_toggle_pause()
		get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseButton \
			and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT \
			and (event as InputEventMouseButton).pressed \
			and not is_busy \
			and not _is_pause_open() \
			and not _is_diary_open():
		_on_scene_clicked((event as InputEventMouseButton).position)

func _on_scene_clicked(pos: Vector2) -> void:
	pass

# ─── Пауза ────────────────────────────────────────────────────────────────────

func _toggle_pause() -> void:
	if not pause_menu:
		return
	var opening: bool = not pause_menu.visible
	pause_menu.visible = opening
	get_tree().paused  = opening

func _is_pause_open() -> bool:
	return pause_menu != null and pause_menu.visible

func _is_diary_open() -> bool:
	return diary != null and diary.visible

# ─── Дневник ──────────────────────────────────────────────────────────────────

func _open_diary() -> void:
	if diary_overlay != null:
		_close_diary_overlay()
		return
	if diary and diary.has_method("close"):
		diary.close()
	_show_diary_image_overlay()

func _show_diary_image_overlay() -> void:
	if diary_overlay != null:
		return
	is_busy = true

	diary_overlay = Control.new()
	diary_overlay.name = "DiaryImageOverlay"
	diary_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	diary_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	ui_layer.add_child(diary_overlay)

	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.0, 0.0, 0.0, 0.8)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	diary_overlay.add_child(dim)

	# Загружаем готовую сцену с кнопками на diary.png
	var hotspots: Control = HOTSPOTS_SCENE.instantiate()
	hotspots.name = "DiaryHotspots"
	diary_overlay.add_child(hotspots)
	
	# Подключаем сигналы кнопок (невидимые области)
	var btn_locations: Button = hotspots.get_node("BtnLocations")
	var btn_characters: Button = hotspots.get_node("BtnCharacters")
	var btn_evidence: Button = hotspots.get_node("BtnEvidence")
	var btn_close: Button = hotspots.get_node("BtnClose")
	
	btn_locations.pressed.connect(_on_locations_pressed)
	btn_characters.pressed.connect(_on_characters_pressed)
	btn_evidence.pressed.connect(_on_evidence_pressed)
	btn_close.pressed.connect(_close_diary_overlay)
	
	# Подключаем сигналы кнопок с текстом (BtnXxxLabel)
	var btn_locations_label: Button = hotspots.get_node("BtnLocationsLabel")
	var btn_characters_label: Button = hotspots.get_node("BtnCharactersLabel")
	var btn_evidence_label: Button = hotspots.get_node("BtnEvidenceLabel")
	
	btn_locations_label.pressed.connect(_on_locations_pressed)
	btn_characters_label.pressed.connect(_on_characters_pressed)
	btn_evidence_label.pressed.connect(_on_evidence_pressed)

func _on_locations_pressed() -> void:
	_show_locations_overlay()

func _on_characters_pressed() -> void:
	_show_diary_feedback("Персонажи")

func _on_evidence_pressed() -> void:
	_show_diary_feedback("Улики")

func _show_diary_feedback(text: String) -> void:
	var feedback := Label.new()
	feedback.text = text
	feedback.add_theme_font_size_override("font_size", 26)
	feedback.modulate = Color(1.0, 0.95, 0.4, 1.0)
	feedback.position = Vector2(100, 100)
	diary_overlay.add_child(feedback)
	var tween := create_tween()
	tween.tween_property(feedback, "modulate:a", 0.0, 0.8).set_delay(0.8)
	tween.tween_callback(feedback.queue_free)

# ─── Отображение локаций ────────────────────────────────────────────────────

func _show_locations_overlay() -> void:
	if not diary_overlay:
		return
	
	# Удаляем старый слой с кнопками дневника
	var old_hotspots := diary_overlay.get_node_or_null("DiaryHotspots")
	if old_hotspots:
		old_hotspots.queue_free()
	
	# Загружаем готовую сцену с изображением локаций и списком
	var locations_scene: Control = LOCATIONS_SCENE.instantiate()
	locations_scene.name = "DiaryLocationsScene"
	
	# Если файла diary_locations.png нет — используем заглушку
	var tex := load("res://assets/ui/diary_locations.png")
	if not tex:
		var img := Image.create(1920, 1080, false, Image.FORMAT_RGBA8)
		img.fill(Color(0.15, 0.12, 0.2, 1.0))
		var placeholder := ImageTexture.new()
		placeholder.set_image(img)
		# Устанавливаем фон через скрипт
		var locations_script: DiaryLocations = locations_scene as DiaryLocations
		if locations_script:
			locations_script.set_background(placeholder)
	
	diary_overlay.add_child(locations_scene)
	
	# Подключаем кнопку закрытия
	var locations_node: DiaryLocations = locations_scene as DiaryLocations
	if locations_node:
		locations_node.close_pressed.connect(_close_diary_overlay)


func _close_diary_overlay() -> void:
	if diary_overlay != null:
		diary_overlay.queue_free()
		diary_overlay = null
	if diary and diary.has_method("close"):
		diary.close()
	is_busy = false

# ─── Диалоги ──────────────────────────────────────────────────────────────────

func start_dialogue(data: Dictionary) -> void:
	if not dialogue_box:
		push_error("DialogueBox не найден в %s!" % location_id)
		return
	is_busy = true
	GameManager.change_state(GameManager.GameState.DIALOGUE)
	dialogue_box.start_dialogue(data)

func _on_dialogue_finished(_id: String) -> void:
	is_busy = false
	GameManager.change_state(GameManager.GameState.PLAYING)

# ─── Навигация ────────────────────────────────────────────────────────────────

func travel_to(location_scene_name: String) -> void:
	GameManager.travel_to_location(location_scene_name)
