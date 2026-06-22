## TitleCard.gd
## Заставка между прологом и началом игры.
## На весь экран показывается картинка номера, слева плавно появляется
## и пропадает подпись с номером комнаты и временем, после чего игра
## автоматически переходит на первую локацию.
extends Control

const NEXT_SCENE := "res://scenes/locations/Location01.tscn"

@export var fade_in_time:    float = 1.0   ## Сколько подпись плавно появляется
@export var hold_time:       float = 2.0   ## Сколько подпись остаётся полностью видимой
@export var fade_out_time:   float = 1.0   ## Сколько подпись плавно исчезает
@export var after_pause:     float = 1.0   ## Пауза после исчезновения подписи (картинка одна)
@export var transition_time: float = 0.8   ## Время затухания всей сцены перед переходом

@onready var caption: Label = $Caption

var _advancing: bool = false
var _sequence_tween: Tween


func _ready() -> void:
	caption.modulate.a = 0.0
	_sequence_tween = create_tween()
	_sequence_tween.tween_property(caption, "modulate:a", 1.0, fade_in_time)
	_sequence_tween.tween_interval(hold_time)
	_sequence_tween.tween_property(caption, "modulate:a", 0.0, fade_out_time)
	_sequence_tween.tween_interval(after_pause)
	_sequence_tween.finished.connect(_advance)


func _input(event: InputEvent) -> void:
	if _advancing:
		return

	var is_click: bool = event is InputEventMouseButton \
			and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT \
			and (event as InputEventMouseButton).pressed

	var is_key: bool = event is InputEventKey \
			and (event as InputEventKey).pressed \
			and not (event as InputEventKey).echo \
			and (event as InputEventKey).keycode in [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER, KEY_ESCAPE]

	if is_click or is_key:
		get_viewport().set_input_as_handled()
		_skip()


func _skip() -> void:
	if _sequence_tween and _sequence_tween.is_valid():
		_sequence_tween.kill()
	_advance()


func _advance() -> void:
	if _advancing:
		return
	_advancing = true

	var fade := create_tween()
	fade.tween_property(self, "modulate:a", 0.0, transition_time)
	await fade.finished

	get_tree().change_scene_to_file(NEXT_SCENE)
