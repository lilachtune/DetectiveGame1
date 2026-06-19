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
class_name LocationBase
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

# ─── Инициализация ────────────────────────────────────────────────────────────

func _ready() -> void:
	DiaryManager.discover_location(location_id)
	_apply_background()

	if location_music:
		AudioManager.play_music(location_music)

	if diary_button:
		diary_button.theme_type_variation = &"HudButton"
		diary_button.text = "Дневник"
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
		(background as Sprite2D).texture = background_texture
	elif background is TextureRect:
		(background as TextureRect).texture = background_texture

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
	if diary and diary.has_method("open"):
		diary.open()

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
