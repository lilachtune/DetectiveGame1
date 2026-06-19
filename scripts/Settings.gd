## Settings.gd
## Панель настроек звука (только общая громкость).
## Используется и в главном меню, и в меню паузы — это один и тот же
## экземпляр сцены Settings.tscn, инстансированный в обоих местах.
##
## Иерархия узлов (Settings.tscn):
##   Settings (Control)
##   ├─ Overlay (ColorRect)        — затемнение фона
##   └─ Panel (Panel)
##       ├─ BtnClose (Button)
##       └─ VBox (VBoxContainer)
##           ├─ Title (Label)
##           └─ Row_Master (HBoxContainer)
##               ├─ LabelMaster (Label)
##               ├─ MasterSlider (HSlider)
##               └─ MasterValue (Label)
class_name Settings
extends Control

@onready var btn_close:     Button  = $Panel/BtnClose
@onready var master_slider: HSlider = $Panel/VBox/Row_Master/MasterSlider
@onready var master_value:  Label   = $Panel/VBox/Row_Master/MasterValue


func _ready() -> void:
	# Работает даже когда дерево сцены на паузе (открыто из PauseMenu).
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	# Затемнение не должно перехватывать клики — иначе кнопки под ним
	# (и сама панель) могут не реагировать на нажатия.
	if has_node("Overlay"):
		$Overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_sync_slider_from_audio_manager()

	master_slider.value_changed.connect(_on_master_changed)
	btn_close.pressed.connect(_close)


func open() -> void:
	_sync_slider_from_audio_manager()
	visible = true


func _close() -> void:
	visible = false


func _sync_slider_from_audio_manager() -> void:
	master_slider.value = AudioManager.master_volume
	_update_label()


func _on_master_changed(value: float) -> void:
	AudioManager.set_master_volume(value)
	_update_label()


func _update_label() -> void:
	master_value.text = "%d%%" % roundi(AudioManager.master_volume * 100)
