## EndingTest.gd
## Финальный тест: кто убийца, как убил, зачем.
## Открывается из дневника после завершения сюжета.
##
## Структура сцены:
##   EndingTest (Control)
##   ├─ Overlay (ColorRect)
##   └─ Panel (PanelContainer)
##       ├─ BtnClose (Button)
##       └─ VBox (VBoxContainer)
##           ├─ Title (Label)
##           ├─ Row_Killer  (HBoxContainer)
##           │   ├─ Label "Убийца:"
##           │   └─ KillerSelect (OptionButton)
##           ├─ Row_Method  (HBoxContainer)
##           │   ├─ Label "Метод убийства:"
##           │   └─ MethodSelect (OptionButton)
##           ├─ Row_Motive  (HBoxContainer)
##           │   ├─ Label "Мотив:"
##           │   └─ MotiveSelect (OptionButton)
##           ├─ BtnConfirm (Button)
##           └─ ResultLabel (Label)
class_name EndingTest
extends Control

# ─── Правильные ответы (задать в редакторе или через код сюжета) ──────────────
@export var correct_killer_id: String = "character_01"
@export var correct_method:    String = "Отравление"
@export var correct_motive:    String = "Деньги"

@onready var killer_select:  OptionButton = $Panel/VBox/Row_Killer/KillerSelect
@onready var method_select:  OptionButton = $Panel/VBox/Row_Method/MethodSelect
@onready var motive_select:  OptionButton = $Panel/VBox/Row_Motive/MotiveSelect
@onready var btn_confirm:    Button       = $Panel/VBox/BtnConfirm
@onready var result_label:   Label        = $Panel/VBox/ResultLabel
@onready var btn_close:      Button       = $Panel/BtnClose

## Доступные методы убийства (заполнить под сюжет).
const METHODS: Array[String] = [
	"Отравление",
	"Огнестрельное оружие",
	"Холодное оружие",
	"Удушение",
	"Падение с высоты",
]

## Доступные мотивы (заполнить под сюжет).
const MOTIVES: Array[String] = [
	"Деньги / наследство",
	"Ревность",
	"Месть",
	"Самозащита",
	"Сокрытие тайны",
]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible      = false

	btn_close.pressed.connect(close)
	btn_confirm.pressed.connect(_on_confirm)
	result_label.text = ""


func open() -> void:
	visible = true
	_populate_options()


func close() -> void:
	visible = false


func _populate_options() -> void:
	# Убийцы — только открытые персонажи
	killer_select.clear()
	for char_id in DiaryManager.get_discovered_characters():
		var d: Dictionary = DiaryManager.characters[char_id]
		killer_select.add_item(d["name"] + " " + d["surname"])
		killer_select.set_item_metadata(killer_select.item_count - 1, char_id)

	method_select.clear()
	for m in METHODS:
		method_select.add_item(m)

	motive_select.clear()
	for mv in MOTIVES:
		motive_select.add_item(mv)

	result_label.text = ""


func _on_confirm() -> void:
	var killer_id := killer_select.get_item_metadata(killer_select.selected) as String
	var method    := method_select.get_item_text(method_select.selected)
	var motive    := motive_select.get_item_text(motive_select.selected)

	var killer_ok := killer_id == correct_killer_id
	var method_ok := method   == correct_method
	var motive_ok := motive   == correct_motive

	if killer_ok and method_ok and motive_ok:
		result_label.text = "✅ Верно! Дело раскрыто!"
		result_label.add_theme_color_override("font_color", Color(0.2, 0.9, 0.3))
		# Здесь можно запустить кат-сцену:
		# get_tree().change_scene_to_file("res://scenes/Cutscene.tscn")
	else:
		var errors: Array[String] = []
		if not killer_ok: errors.append("убийца указан неверно")
		if not method_ok: errors.append("метод убийства неверен")
		if not motive_ok: errors.append("мотив неверен")
		result_label.text = "❌ Неверно: " + ", ".join(errors) + "."
		result_label.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2))
