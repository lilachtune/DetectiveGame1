extends CanvasLayer

var location_owner: Node = null
var overlay_root: Control = null
var _is_active: bool = false
var _dialogue_steps: Array[Dictionary] = []
var _current_step_index: int = 0
var _dialogue_text: RichTextLabel = null
var _speaker_name: Label = null
var _portrait_left: TextureRect = null
var _portrait_right: TextureRect = null
var _next_button: Button = null
var _is_typing: bool = false

func _ready() -> void:
	visible = false
	layer = 100

func setup(location: Node) -> void:
	location_owner = location

func show_interrogation() -> void:
	if _is_active:
		return
	_is_active = true
	visible = true
	if location_owner != null:
		location_owner.is_busy = true
	GameManager.change_state(GameManager.GameState.DIALOGUE)
	if overlay_root == null:
		_build_ui()
	_start_dialogue()

func _build_ui() -> void:
	if overlay_root != null:
		return

	overlay_root = Control.new()
	overlay_root.name = "InterrogationOverlayRoot"
	overlay_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay_root)

	var dim := ColorRect.new()
	dim.name = "Dim"
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.0, 0.0, 0.0, 0.7)
	overlay_root.add_child(dim)

	var portrait_container := Control.new()
	portrait_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	portrait_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay_root.add_child(portrait_container)

	_portrait_left = TextureRect.new()
	_portrait_left.texture = preload("res://assets/characters/detective.png")
	_portrait_left.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
	_portrait_left.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait_left.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	_portrait_left.anchor_top = 0.12
	_portrait_left.anchor_bottom = 1.0
	_portrait_left.anchor_left = 0.0
	_portrait_left.anchor_right = 0.38
	_portrait_left.offset_left = -40.0
	_portrait_left.offset_right = 0.0
	_portrait_left.offset_top = 0.0
	_portrait_left.offset_bottom = 0.0
	_portrait_left.modulate.a = 0.0
	_portrait_left.scale = Vector2(0.98, 0.98)
	portrait_container.add_child(_portrait_left)

	_portrait_right = TextureRect.new()
	_portrait_right.texture = preload("res://assets/characters/tomas.png")
	_portrait_right.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
	_portrait_right.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait_right.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	_portrait_right.anchor_top = 0.12
	_portrait_right.anchor_bottom = 1.0
	_portrait_right.anchor_left = 0.62
	_portrait_right.anchor_right = 1.0
	_portrait_right.offset_left = 0.0
	_portrait_right.offset_right = 40.0
	_portrait_right.offset_top = 0.0
	_portrait_right.offset_bottom = 0.0
	_portrait_right.modulate.a = 0.0
	_portrait_right.scale = Vector2(0.98, 0.98)
	portrait_container.add_child(_portrait_right)

	var dialogue_panel := Control.new()
	dialogue_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	dialogue_panel.anchor_left = 0.08
	dialogue_panel.anchor_right = 0.92
	dialogue_panel.anchor_top = 0.70
	dialogue_panel.anchor_bottom = 0.96
	overlay_root.add_child(dialogue_panel)

	var dialogue_bg := PanelContainer.new()
	dialogue_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	dialogue_panel.add_child(dialogue_bg)

	var dialogue_vbox := VBoxContainer.new()
	dialogue_vbox.add_theme_constant_override("separation", 12)
	dialogue_bg.add_child(dialogue_vbox)

	_speaker_name = Label.new()
	_speaker_name.text = ""
	_speaker_name.add_theme_font_size_override("font_size", 24)
	dialogue_vbox.add_child(_speaker_name)

	_dialogue_text = RichTextLabel.new()
	_dialogue_text.bbcode_enabled = true
	_dialogue_text.scroll_active = false
	_dialogue_text.fit_content = true
	_dialogue_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dialogue_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_dialogue_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_dialogue_text.text = ""
	dialogue_vbox.add_child(_dialogue_text)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_END
	dialogue_vbox.add_child(button_row)

	_next_button = Button.new()
	_next_button.text = "ДАЛЕЕ"
	_next_button.custom_minimum_size = Vector2(180, 42)
	_next_button.pressed.connect(_advance_dialogue)
	button_row.add_child(_next_button)

	var finish_button := Button.new()
	finish_button.text = "ЗАВЕРШИТЬ"
	finish_button.custom_minimum_size = Vector2(180, 42)
	finish_button.pressed.connect(_close_interrogation)
	button_row.add_child(finish_button)

	var tween := create_tween()
	tween.tween_property(overlay_root, "modulate:a", 1.0, 0.25)
	tween.parallel().tween_property(_portrait_left, "modulate:a", 1.0, 0.35)
	tween.parallel().tween_property(_portrait_left, "scale", Vector2.ONE, 0.35)
	tween.parallel().tween_property(_portrait_right, "modulate:a", 1.0, 0.35)
	tween.parallel().tween_property(_portrait_right, "scale", Vector2.ONE, 0.35)

func _start_dialogue() -> void:
	_dialogue_steps = [
		{"speaker": "Вольф", "text": "Томас Бергер, спасибо, что пришли. Присядьте. Расскажите мне о постояльце из номера 304. Карле Мюллере."},
		{"speaker": "Томас", "text": "Карл Мюллер... Да. Он заселился к нам седьмого мая. Сказал, что будет у нас около двух недель, по делам. Оплатил номер наличными, без карты. Сразу бросилось в глаза, но у нас такое бывает."},
		{"speaker": "Вольф", "text": "Как он вёл себя за эту неделю?"},
		{"speaker": "Томас", "text": "Сложный гость. Очень сложный. Он постоянно кричал по телефону — я слышал через стенку в кабинете. Конфликтовал с другими постояльцами. С горничной. Со мной. Жалобы сыпались каждый день. Гертруда Хубер из сто первого жаловалась, что он на неё накричал в первый же день. Супруги Винтер из двести шестого — он выгнал их из бара. Я пытался с ним поговорить, но он послал меня куда подальше. Сказал, что я никто, а он, видите ли, важная персона."},
		{"speaker": "Вольф", "text": "А в последний вечер? Тринадцатого мая?"},
		{"speaker": "Томас", "text": "Странно, но было тихо. Обычно он орал до ночи, а тут тишина. Он заказал ужин в номер около восьми вечера. Повар отнёс. Больше никто не заходил — по крайней мере, мы никого не видели."},
		{"speaker": "Вольф", "text": "Повар? Кто именно?"},
		{"speaker": "Томас", "text": "Доминик Вагнер. Хороший парень, работает у нас уже полгода. Спокойный, незаметный. Никогда никаких проблем. В тот вечер он сам вызвался отнести поднос — сказал, что хочет подышать воздухом. Я не придал этому значения."},
		{"speaker": "Вольф", "text": "А после того, как он вернулся? Вы не заметили в нём ничего странного?"},
		{"speaker": "Томас", "text": "Нет... хотя коллеги потом говорили, что он вернулся с подносом бледный. Как будто увидел что-то. Я подумал — мало ли, гость накричал на него. Такое бывает. Доминик вообще парень тихий, он бы не стал жаловаться."},
		{"speaker": "Вольф", "text": "Доминик живёт один?"},
		{"speaker": "Томас", "text": "Да, снимает комнату неподалёку. У него мать болеет, я слышал. Он много работает, отправляет деньги домой. Хороший парень, правда. Я не хочу, чтобы у него были проблемы."},
		{"speaker": "Вольф", "text": "Спасибо, Томас Бергер. Если вспомните что-то ещё — дайте знать."},
	]
	_current_step_index = 0
	_advance_dialogue()

func _advance_dialogue() -> void:
	if _is_typing:
		return
	if _current_step_index >= _dialogue_steps.size():
		_close_interruption_after_last()
		return
	if _next_button != null:
		_next_button.disabled = true
	var step: Dictionary = _dialogue_steps[_current_step_index]
	_current_step_index += 1
	_speaker_name.text = step["speaker"]
	_dialogue_text.text = ""
	_is_typing = true
	_type_text(step["text"])

func _type_text(full_text: String) -> void:
	var char_index: int = 0
	while char_index < full_text.length():
		_dialogue_text.text += full_text.substr(char_index, 1)
		char_index += 1
		await get_tree().create_timer(0.03).timeout
	_is_typing = false
	if _next_button != null:
		_next_button.disabled = false

func _close_interruption_after_last() -> void:
	_close_interrogation()

func _close_interrogation() -> void:
	if location_owner != null:
		location_owner.is_busy = false
	GameManager.change_state(GameManager.GameState.PLAYING)
	_is_active = false
	var tween := create_tween()
	tween.tween_property(overlay_root, "modulate:a", 0.0, 0.2)
	tween.tween_callback(_finish_close)

func _finish_close() -> void:
	queue_free()
