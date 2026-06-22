## Epilogue.gd
## Вступительный текст: чёрный экран, печать сверху по центру вниз.
extends Control

const EPILOGUE_TEXT := """Гостиница «Северный вокзал», пригород Лейпцига.
14 мая 2018 года, 9:47 утра.
Телефон в полицейском участке звонит ровно три раза. Дежурный поднимает трубку.
Дежурный: Полиция Лейпцига, слушаю.
Голос (мужской, взволнованный, срывается): Доброе утро... Это гостиница «Северный вокзал». Меня зовут Томас Бергер, я управляющий. У нас... у нас тут проблема.
Дежурный: Что случилось?
Томас: Постоялец. В номере 304. Он... не просыпается.
Пауза.
Дежурный: Не просыпается?
Томас: Горничная зашла убраться. Он лежит в кровати. Мы думали, просто спит, но... она потрогала его за плечо. Он холодный. Я вызвал скорую, они приехали. Сказали, что он... что он мертв. Уже несколько часов.
Дежурный: Врачи назвали причину?
Томас: Предварительно — остановка сердца. Но они сказали, что точно будет известно после... ну, вы знаете. Я хочу вызвать полицию. Формально. Всё же мертвый человек в номере.
Дежурный: Вы знаете, кто он?
Томас: Да, он зарегистрирован. Карл Мюллер. Сорок лет. Заселился седьмого мая. Сказал, что будет у нас около двух недель, по делам. Оплатил номер наличными.
Дежурный: За неделю ничего странного не заметили?
Томас: Он... он был сложным гостем. Часто кричал по телефону, конфликтовал с другими постояльцами. Но вчера вечером было тихо.
Дежурный: Кто-нибудь заходил к нему вчера?
Томас: Только повар, когда относил ужин. Где-то около восьми вечера. Больше никто не заходил — по крайней мере, мы никого не видели. Администратор говорит, что он весь вечер сидел в номере один.
Дежурный: Повар что-нибудь сказал?
Томас: Сказал, что всё было нормально. Гость был пьян, но вел себя спокойно. Повар поставил поднос и ушел.
Дежурный: Хорошо. Ничего не трогайте в номере. Мы скоро приедем.
Томас: Да, конечно. Я... я просто не знаю, что делать. У нас никогда такого не было.
Дежурный: Ждите. Полиция будет через двадцать минут.
Томас выдыхает в трубку.
Томас: Спасибо. Ждем.
Гудки."""

const TEXT_WIDTH := 920.0

@export var char_delay: float = 0.05
@export var end_pause: float = 2.5

@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var text_label: RichTextLabel = $ScrollContainer/TextLabel
@onready var skip_hint: Label = $SkipHint

var _char_index: int = 0
var _typing: bool = true
var _timer: float = 0.0
var _typing_done: bool = false
var _ending: bool = false
var _end_timer: float = 0.0


func _ready() -> void:
	text_label.text = ""
	text_label.custom_minimum_size = Vector2(TEXT_WIDTH, 0.0)
	skip_hint.modulate.a = 0.0
	set_process(true)


func _process(delta: float) -> void:
	var typed := false
	if _typing:
		_timer += delta
		while _typing and _timer >= char_delay:
			_timer -= char_delay
			_type_next_char()
			typed = true

	if typed:
		call_deferred("_scroll_to_bottom")

	if _typing_done and not _ending:
		_end_timer += delta
		if _end_timer >= end_pause:
			_begin_gameplay()


func _input(event: InputEvent) -> void:
	if _ending:
		return

	var is_click: bool = false
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		is_click = mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed

	var is_key: bool = false
	if event is InputEventKey:
		var key_event := event as InputEventKey
		is_key = key_event.pressed \
				and not key_event.echo \
				and key_event.keycode in [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER, KEY_ESCAPE]

	if is_click or is_key:
		_handle_skip()
		var viewport := get_viewport()
		if viewport:
			viewport.set_input_as_handled()


func _handle_skip() -> void:
	if _typing:
		_char_index = EPILOGUE_TEXT.length()
		text_label.text = EPILOGUE_TEXT
		_typing = false
		call_deferred("_scroll_to_bottom")
		_on_typing_finished()
	elif _typing_done:
		_begin_gameplay()


func _type_next_char() -> void:
	if _char_index >= EPILOGUE_TEXT.length():
		_typing = false
		_on_typing_finished()
		return

	_char_index += 1
	text_label.text = EPILOGUE_TEXT.substr(0, _char_index)


func _scroll_to_bottom() -> void:
	var v_scroll := scroll_container.get_v_scroll_bar()
	scroll_container.scroll_vertical = int(v_scroll.max_value)


func _on_typing_finished() -> void:
	if _typing_done:
		return

	_typing_done = true
	_show_skip_hint()


func _show_skip_hint() -> void:
	var tween := create_tween()
	tween.tween_property(skip_hint, "modulate:a", 1.0, 0.6)


func _begin_gameplay() -> void:
	if _ending:
		return

	_ending = true
	set_process(false)
	get_tree().change_scene_to_file("res://scenes/locations/Location01.tscn")
