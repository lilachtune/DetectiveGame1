## PauseMenu.gd
## Меню паузы (Escape во время игры).
## Кнопки: Продолжить | Настройки | Главное меню | Выход
class_name PauseMenu
extends Control

@onready var btn_resume:     Button  = $Panel/VBox/BtnResume
@onready var btn_settings:   Button  = $Panel/VBox/BtnSettings
@onready var btn_main_menu:  Button  = $Panel/VBox/BtnMainMenu
@onready var btn_quit:       Button  = $Panel/VBox/BtnQuit
@onready var settings_panel: Settings = $Settings

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible      = false

	btn_resume.pressed.connect(_on_resume)
	btn_settings.pressed.connect(_on_settings)
	btn_main_menu.pressed.connect(_on_main_menu)
	btn_quit.pressed.connect(_on_quit)

	if settings_panel:
		settings_panel.visible = false


func _on_resume() -> void:
	visible           = false
	get_tree().paused = false


func _on_settings() -> void:
	if settings_panel:
		settings_panel.open()


func _on_main_menu() -> void:
	get_tree().paused = false
	GameManager.return_to_main_menu()


func _on_quit() -> void:
	GameManager.quit_game()
