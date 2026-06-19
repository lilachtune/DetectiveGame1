## DialogueBox.gd
## Система диалогов:
##  - Фоновый кадр с портретом персонажа
##  - Постепенный вывод текста (эффект печатной машинки)
##  - ЛКМ: раскрыть фразу полностью / перейти к следующей
##
## Структура сцены в редакторе:
##   DialogueBox (Control)
##   ├─ Overlay (ColorRect)             ← затемнение экрана (alpha ~0.3)
##   ├─ Portrait (TextureRect)          ← PNG-портрет персонажа
##   └─ TextPanel (PanelContainer)      ← нижняя панель
##       └─ VBox (VBoxContainer)
##           ├─ SpeakerName (Label)
##           ├─ DialogueText (RichTextLabel)
##           └─ ContinueHint (Label)    ← "▼ нажмите для продолжения"
class_name DialogueBox
extends Control

# ─── Сигналы ──────────────────────────────────────────────────────────────────
signal dialogue_finished(dialogue_id: String)

# ─── Узлы ─────────────────────────────────────────────────────────────────────
@onready var portrait:       TextureRect   = $Portrait
@onready var speaker_label:  Label         = $TextPanel/VBox/SpeakerName
@onready var dialogue_text:  RichTextLabel = $TextPanel/VBox/DialogueText
@onready var continue_hint:  Label         = $TextPanel/VBox/ContinueHint

# ─── Настройки ────────────────────────────────────────────────────────────────
## Задержка между символами (секунды). Чем меньше — тем быстрее.
@export var char_delay: float = 0.03

# ─── Внутренние переменные ────────────────────────────────────────────────────
var _dialogue_id:   String = ""
var _lines:         Array  = []   # Array[{ speaker, text, portrait_path }]
var _line_index:    int    = 0
var _char_index:    int    = 0
var _full_text:     String = ""
var _typing:        bool   = false
var _timer:         float  = 0.0

# ─── Инициализация ────────────────────────────────────────────────────────────

func _ready() -> void:
	visible = false
	if continue_hint:
		continue_hint.visible = false
	set_process(false)


# ─── Процесс печатания ────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	if not _typing:
		return
	_timer += delta
	if _timer >= char_delay:
		_timer = 0.0
		_type_next_char()


# ─── Публичный API ────────────────────────────────────────────────────────────

## Запустить диалог.
## data = {
##   id: String,
##   character_id: String,
##   lines: Array[{ speaker: String, text: String, portrait_path: String }]
## }
func start_dialogue(data: Dictionary) -> void:
	_dialogue_id = data.get("id", "dlg_%d" % randi())
	_lines       = data.get("lines", [])
	_line_index  = 0

	# Зарегистрируем в дневнике
	DiaryManager.register_dialogue(
		_dialogue_id,
		data.get("character_id", ""),
		_lines
	)

	visible = true
	set_process(true)
	_show_line()


# ─── Обработка ввода ──────────────────────────────────────────────────────────

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed:
		_handle_click()
		get_viewport().set_input_as_handled()


func _handle_click() -> void:
	if _typing:
		# Мгновенно показать весь текст
		dialogue_text.text = _full_text
		_char_index = _full_text.length()
		_typing     = false
		_show_continue_hint()
	else:
		# Перейти к следующей реплике
		_line_index += 1
		if _line_index >= _lines.size():
			_end_dialogue()
		else:
			_show_line()


# ─── Внутренние методы ────────────────────────────────────────────────────────

func _show_line() -> void:
	var line: Dictionary = _lines[_line_index]
	_full_text  = line.get("text", "")
	_char_index = 0
	_typing     = true
	_timer      = 0.0

	speaker_label.text  = line.get("speaker", "")
	dialogue_text.text  = ""

	if continue_hint:
		continue_hint.visible = false

	# Портрет
	var portrait_path: String = line.get("portrait_path", "")
	if portrait and portrait_path != "" and ResourceLoader.exists(portrait_path):
		portrait.texture = load(portrait_path)
	elif portrait:
		portrait.texture = null


func _type_next_char() -> void:
	if _char_index < _full_text.length():
		_char_index       += 1
		dialogue_text.text = _full_text.substr(0, _char_index)
	else:
		_typing = false
		_show_continue_hint()


func _show_continue_hint() -> void:
	if continue_hint:
		continue_hint.visible = true
		# Изменить текст подсказки в конце диалога
		if _line_index >= _lines.size() - 1:
			continue_hint.text = "▼  нажмите для завершения"
		else:
			continue_hint.text = "▼  нажмите для продолжения"


func _end_dialogue() -> void:
	visible = false
	set_process(false)
	_typing = false

	DiaryManager.complete_dialogue(_dialogue_id)
	dialogue_finished.emit(_dialogue_id)
