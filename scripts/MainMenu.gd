## MainMenu.gd
## Главное меню игры.
extends Control


@export var background_image: Texture2D

const DEFAULT_BG_PATH := "res://assets/ui/menu_background.png"

@onready var bg_image_node: TextureRect = $BackgroundImage
@onready var content_panel: PanelContainer = $ContentPanel
@onready var version_backdrop: Panel = $VersionBackdrop
@onready var btn_new_game:  Button   = $ContentPanel/VBox/BtnNewGame
@onready var btn_continue:  Button   = $ContentPanel/VBox/BtnContinue
@onready var btn_settings:  Button   = $ContentPanel/VBox/BtnSettings
@onready var btn_quit:      Button   = $ContentPanel/VBox/BtnQuit
@onready var settings_node: Settings = $Settings

var _menu_buttons: Array[Button] = []


func _ready() -> void:
	GameManager.change_state(GameManager.GameState.MAIN_MENU)
	get_tree().paused = false

	_apply_background_image()

	btn_new_game.pressed.connect(_on_new_game)
	btn_continue.pressed.connect(_on_continue)
	btn_settings.pressed.connect(_on_settings)
	btn_quit.pressed.connect(_on_quit)

	btn_continue.disabled = not SaveManager.has_save()

	if settings_node:
		settings_node.visible = false

	_menu_buttons = [btn_new_game, btn_continue, btn_settings, btn_quit]
	for btn in _menu_buttons:
		btn.mouse_entered.connect(_on_button_hover.bind(btn))
		btn.focus_entered.connect(_on_button_hover.bind(btn))

	_play_entrance_animation()

	# Зацикленная музыка главного меню
	AudioManager.play_main_menu_music()


## Подставляет картинку фона: сначала смотрит на поле в Инспекторе,
## затем — на файл по умолчанию res://assets/ui/menu_background.png.
func _apply_background_image() -> void:
	if not bg_image_node:
		return

	var tex: Texture2D = background_image
	if not tex and ResourceLoader.exists(DEFAULT_BG_PATH):
		tex = load(DEFAULT_BG_PATH)

	bg_image_node.texture = tex


func _play_entrance_animation() -> void:
	content_panel.modulate.a = 0.0
	content_panel.scale = Vector2(0.96, 0.96)
	version_backdrop.modulate.a = 0.0

	var tween := create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(content_panel, "modulate:a", 1.0, 0.55)
	tween.tween_property(content_panel, "scale", Vector2.ONE, 0.55)
	tween.tween_property(version_backdrop, "modulate:a", 1.0, 0.7).set_delay(0.25)


func _on_button_hover(btn: Button) -> void:
	if btn.disabled:
		return
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(btn, "scale", Vector2(1.02, 1.02), 0.12)
	tween.tween_property(btn, "scale", Vector2.ONE, 0.1).set_delay(0.12)


func _on_new_game() -> void:
	GameManager.start_new_game()


func _on_continue() -> void:
	GameManager.continue_game()


func _on_settings() -> void:
	if settings_node:
		settings_node.open()


func _on_quit() -> void:
	get_tree().quit()
