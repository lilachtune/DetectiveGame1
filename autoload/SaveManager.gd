## SaveManager.gd
## Система сохранения/загрузки.
## Сохраняет при выходе из игры (автоматически).
extends Node

const SAVE_PATH := "user://savegame.save"

var save_data: Dictionary = {}

# ─── Автосохранение ───────────────────────────────────────────────────────────

## Автоматически сохраняет игру. Вызывать перед любым выходом.
func auto_save() -> void:
	if not GameManager.game_started:
		return

	save_data = {
		"current_location": GameManager.current_location,
		"story_completed":  GameManager.story_completed,
		"diary_data":       DiaryManager.get_save_data(),
		"audio_settings":   AudioManager.get_save_data(),
		"timestamp":        Time.get_datetime_string_from_system()
	}

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print("[SaveManager] Игра сохранена: ", save_data["timestamp"])
	else:
		push_error("[SaveManager] Не удалось открыть файл сохранения для записи.")


## Загружает данные из файла сохранения.
## Возвращает true при успехе.
func load_save() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false

	var json_string := file.get_as_text()
	file.close()

	var json := JSON.new()
	if json.parse(json_string) != OK:
		push_error("[SaveManager] Ошибка парсинга файла сохранения.")
		return false

	save_data = json.data
	print("[SaveManager] Сохранение загружено (", save_data.get("timestamp", "?"), ")")
	return true


## Применяет загруженные данные к менеджерам.
func apply_save() -> void:
	if save_data.is_empty():
		return

	GameManager.current_location = save_data.get("current_location", "Location01")
	GameManager.story_completed  = save_data.get("story_completed",  false)
	GameManager.game_started     = true

	if save_data.has("diary_data"):
		DiaryManager.load_save_data(save_data["diary_data"])

	if save_data.has("audio_settings"):
		AudioManager.load_save_data(save_data["audio_settings"])


## Проверяет, существует ли файл сохранения.
func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


## Удаляет файл сохранения (для «новой игры»).
func clear_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	save_data = {}
	print("[SaveManager] Файл сохранения удалён.")
