## Settings.gd
## Панель настроек звука.
## Используется и в главном меню, и в меню паузы — это один и тот же
## экземпляр сцены Settings.tscn, инстансированный в обоих местах.
##
## Иерархия узлов (Settings.tscn):
##   Settings (Control)
##   ├─ Overlay (ColorRect)        — затемнение
##   └─ Panel (Panel)
##       ├─ BtnClose (Button)
##       └─ VBox (VBoxContainer)
##           ├─ Title (Label)
##           └─ Row_Master (HBoxContainer)
class_name Settings
extends Control

@onready var overlay:       ColorRect = $Overlay
@onready var btn_close:     Button     = $Panel/BtnClose
@onready var master_slider: HSlider    = $Panel/VBox/Row_Master/MasterSlider
@onready var master_value:  Label      = $Panel/VBox/Row_Master/MasterValue


func _ready() -> void:
	# Работает даже когда дерево сцены на паузе (открыто из PauseMenu).
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	_sync_slider()

	master_slider.value_changed.connect(_on_master_changed)
	btn_close.pressed.connect(_close)

	# Клик по корню вне панели закрывает настройки
	gui_input.connect(_on_root_input)


func open() -> void:
	_sync_slider()
	visible = true


func _close() -> void:
	visible = false


func _on_root_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
			and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		if not $Panel.get_global_rect().has_point(get_global_mouse_position()):
			_close()


func _sync_slider() -> void:
	master_slider.value = AudioManager.master_volume
	master_value.text = "%d%%" % roundi(AudioManager.master_volume * 100)


func _on_master_changed(value: float) -> void:
	AudioManager.set_master_volume(value)
	master_value.text = "%d%%" % roundi(value * 100)