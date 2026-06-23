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

const DIARY_HOTSPOTS := {
	"locations": {"rect": Rect2(925, 327, 515, 124), "label": "Локации"},
	"characters": {"rect": Rect2(925, 494, 515, 119), "label": "Персонажи"},
	"evidence": {"rect": Rect2(925, 656, 515, 124), "label": "Улики"},
}

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
	pass  # Переопределить в дочерних сценах

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
	# Escape открывает/закрывает паузу, только не во время диалога
	if event.is_action_pressed("ui_cancel"):
		if not is_busy:
			_toggle_pause()
		get_viewport().set_input_as_handled()
		return

	# ЛКМ — передать локации, только если не занято и пауза не открыта
	if event is InputEventMouseButton \
			and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT \
			and (event as InputEventMouseButton).pressed \
			and not is_busy \
			and not _is_pause_open() \
			and not _is_diary_open():
		_on_scene_clicked((event as InputEventMouseButton).position)

## Переопределить для обработки кликов по сцене.
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
	diary_overlay.add_child(dim)

	var image_rect := TextureRect.new()
	image_rect.texture = preload("res://assets/ui/diary.png")
	image_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	image_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	image_rect.stretch_mode = TextureRect.STRETCH_SCALE
	image_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	image_rect.gui_input.connect(_on_diary_image_input)
	diary_overlay.add_child(image_rect)

func _on_diary_image_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		var pos: Vector2 = (event as InputEventMouseButton).position
		var close_rect: Rect2 = Rect2(1675, 50, 207, 99)
		if close_rect.has_point(pos):
			_close_diary_overlay()
			return

	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		var pos: Vector2 = (event as InputEventMouseButton).position
		var image_rect: TextureRect = diary_overlay.get_child(1) if diary_overlay != null and diary_overlay.get_child_count() > 1 else null
		if image_rect == null:
			return
		var image_size: Vector2 = image_rect.texture.get_size()
		var control_size: Vector2 = image_rect.get_rect().size
		var scale_factor: float = min(control_size.x / image_size.x, control_size.y / image_size.y)
		var drawn_size: Vector2 = image_size * scale_factor
		var offset: Vector2 = (control_size - drawn_size) / 2.0
		var image_pos: Vector2 = (pos - offset) / scale_factor
		for hotspot_id in DIARY_HOTSPOTS.keys():
			var hotspot_data: Dictionary = DIARY_HOTSPOTS[hotspot_id]
			var rect: Rect2 = hotspot_data.get("rect", Rect2())
			if rect.has_point(image_pos):
				_show_diary_hotspot_feedback(hotspot_data.get("label", hotspot_id))
				return

func _show_diary_hotspot_feedback(label: String) -> void:
	var feedback := Label.new()
	feedback.text = label
	feedback.add_theme_font_size_override("font_size", 26)
	feedback.modulate = Color(1.0, 0.95, 0.4, 1.0)
	feedback.position = Vector2(100, 100)
	diary_overlay.add_child(feedback)
	var tween := create_tween()
	tween.tween_property(feedback, "modulate:a", 0.0, 0.8).set_delay(0.8)
	tween.tween_callback(feedback.queue_free)

func _close_diary_overlay() -> void:
	if diary_overlay != null:
		diary_overlay.queue_free()
		diary_overlay = null
	if diary and diary.has_method("close"):
		diary.close()
	is_busy = false

# ─── Диалоги ──────────────────────────────────────────────────────────────────

## Запустить диалог.
## data = { id, character_id, lines:[{speaker,text,portrait_path}] }
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
