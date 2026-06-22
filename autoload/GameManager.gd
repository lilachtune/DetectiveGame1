## GameManager.gd
## Глобальный синглтон управления состоянием игры.
## Добавить как Autoload в Project > Project Settings > Autoload.
extends Node

# ─── Состояния игры ───────────────────────────────────────────────────────────
enum GameState {
	MAIN_MENU,
	PLAYING,
	DIALOGUE,
	PAUSED,
	DIARY,
	ENDING
}

var current_state: GameState = GameState.MAIN_MENU
var current_location: String  = "Location01"
var game_started:     bool    = false
var story_completed:  bool    = false

# ─── Сигналы ──────────────────────────────────────────────────────────────────
signal state_changed(new_state: GameState)
signal location_changed(location_name: String)

# ─── Публичные методы ─────────────────────────────────────────────────────────

func change_state(new_state: GameState) -> void:
	current_state = new_state
	state_changed.emit(new_state)


## Переход на локацию по имени (например "Location03").
func travel_to_location(location_name: String) -> void:
	current_location = location_name
	SaveManager.auto_save()
	get_tree().change_scene_to_file(
		"res://scenes/locations/%s.tscn" % location_name
	)
	location_changed.emit(location_name)


## Начать новую игру — сбрасывает все данные и показывает вступительный эпилог.
func start_new_game() -> void:
	game_started    = true
	story_completed = false
	current_location = "Location01"
	DiaryManager.reset()
	SaveManager.clear_save()
	change_state(GameState.PLAYING)
	get_tree().change_scene_to_file("res://scenes/Epilogue.tscn")


## Продолжить игру из сохранения.
func continue_game() -> void:
	if SaveManager.load_save():
		SaveManager.apply_save()
		change_state(GameState.PLAYING)
		get_tree().change_scene_to_file(
			"res://scenes/locations/%s.tscn" % current_location
		)


## Вернуться в главное меню с автосохранением.
func return_to_main_menu() -> void:
	SaveManager.auto_save()
	game_started = false
	change_state(GameState.MAIN_MENU)
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


## Выход из игры с автосохранением.
func quit_game() -> void:
	SaveManager.auto_save()
	get_tree().quit()


## Вызвать когда сюжет завершён — разблокирует тест в дневнике.
func complete_story() -> void:
	story_completed = true
	SaveManager.auto_save()
	change_state(GameState.ENDING)
