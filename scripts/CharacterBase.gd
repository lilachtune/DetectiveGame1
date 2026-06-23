## CharacterBase.gd
## Базовый класс для персонажей.
##
## Ожидаемая иерархия узлов:
##   CharacterXX (Node2D)         ← скрипт CharacterBase (или дочерний)
##   ├─ Sprite2D                  ← PNG-спрайт персонажа
##   └─ ClickArea (Area2D)
##       └─ CollisionShape2D
extends Node2D

@export var character_id:     String     = "character_01"
@export var character_sprite: Texture2D

@onready var sprite:     Sprite2D = $Sprite2D
@onready var click_area: Area2D   = $ClickArea

## Диалоги персонажа. Формат каждого элемента:
## { id, character_id, lines:[{speaker, text, portrait_path}] }
## Заполняется в _setup_character() дочернего скрипта.
var dialogues: Array = []

var _dialogue_index: int  = 0
var _discovered:     bool = false

# ─── Инициализация ────────────────────────────────────────────────────────────

func _ready() -> void:
	if character_sprite and sprite:
		sprite.texture = character_sprite

	if click_area:
		click_area.input_event.connect(_on_click_area_input)
		click_area.mouse_entered.connect(
			func(): Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
		)
		click_area.mouse_exited.connect(
			func(): Input.set_default_cursor_shape(Input.CURSOR_ARROW)
		)

	_setup_character()

## Переопределить для заполнения `dialogues` и дополнительной настройки.
func _setup_character() -> void:
	pass

# ─── Взаимодействие ───────────────────────────────────────────────────────────

func _on_click_area_input(_viewport: Node, event: InputEvent, _shape: int) -> void:
	if event is InputEventMouseButton \
			and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT \
			and (event as InputEventMouseButton).pressed:
		_interact()
		get_viewport().set_input_as_handled()

func _interact() -> void:
	if not _discovered:
		DiaryManager.discover_character(character_id)
		_discovered = true
	_try_start_next_dialogue()

func _try_start_next_dialogue() -> void:
	if dialogues.is_empty():
		return

	var idx := clampi(_dialogue_index, 0, dialogues.size() - 1)
	var data: Dictionary = dialogues[idx]

	var location: Node = _get_parent_location()
	if location and location.has_method("start_dialogue"):
		var dialogue_box = location.get("dialogue_box")
		if dialogue_box and dialogue_box.has_signal("dialogue_finished") and \
				not dialogue_box.dialogue_finished.is_connected(_on_dialogue_done):
			dialogue_box.dialogue_finished.connect(_on_dialogue_done, CONNECT_ONE_SHOT)
		location.call("start_dialogue", data)

func _on_dialogue_done(_id: String) -> void:
	if _dialogue_index < dialogues.size() - 1:
		_dialogue_index += 1

# ─── Утилиты ──────────────────────────────────────────────────────────────────

func _get_parent_location() -> Node:
	var node: Node = get_parent()
	while node:
		if node.has_method("start_dialogue") and node.has_method("_apply_background"):
			return node
		node = node.get_parent()
	return null

func get_data() -> Dictionary:
	return DiaryManager.characters.get(character_id, {})
