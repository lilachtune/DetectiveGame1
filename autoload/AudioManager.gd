## AudioManager.gd
## Управление звуком. Настраивает шины Master / Music / SFX.
## Создай три шины в Audio menu: Master, Music, SFX.
extends Node

var master_volume: float = 1.0
var music_volume:  float = 0.8
var sfx_volume:    float = 1.0

var _music_player: AudioStreamPlayer
var _sfx_player:   AudioStreamPlayer

# ─── Музыкальные треки ────────────────────────────────────────────
var main_menu_music: AudioStream
var locations_music: AudioStream
var dosmotr_music:   AudioStream

func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.name = "MusicPlayer"
	add_child(_music_player)
	_music_player.finished.connect(_on_music_finished)

	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.name = "SFXPlayer"
	add_child(_sfx_player)

	_ensure_buses()
	_apply_volumes()
	_load_music_tracks()


func _load_music_tracks() -> void:
	main_menu_music = load("res://resources/main_menu.mp3")
	locations_music = load("res://resources/locations.mp3")
	dosmotr_music   = load("res://resources/dosmotr.mp3")


func play_main_menu_music() -> void:
	play_music(main_menu_music)


func play_locations_music() -> void:
	play_music(locations_music)


func play_dosmotr_music() -> void:
	play_music(dosmotr_music)


# ─── Настройка громкости ──────────────────────────────────────────────────────

func set_master_volume(value: float) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),
		linear_to_db(master_volume)
	)

func set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	var idx := AudioServer.get_bus_index("Music")
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, linear_to_db(music_volume))

func set_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)
	var idx := AudioServer.get_bus_index("SFX")
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, linear_to_db(sfx_volume))


# ─── Воспроизведение ──────────────────────────────────────────────────────────

func play_music(stream: AudioStream, fade: bool = false) -> void:
	if _music_player.stream == stream and _music_player.playing:
		return
	_music_player.stream = stream
	_music_player.play()

func stop_music() -> void:
	_music_player.stop()

func play_sfx(stream: AudioStream) -> void:
	_sfx_player.stream = stream
	_sfx_player.play()


# ─── Сохранение/Загрузка ─────────────────────────────────────────────────────

func get_save_data() -> Dictionary:
	return {
		"master_volume": master_volume,
		"music_volume":  music_volume,
		"sfx_volume":    sfx_volume,
	}

func load_save_data(data: Dictionary) -> void:
	set_master_volume(data.get("master_volume", 1.0))
	set_music_volume(data.get("music_volume",  0.8))
	set_sfx_volume(data.get("sfx_volume",    1.0))


# ─── Зацикливание ─────────────────────────────────────────────────────────────

func _on_music_finished() -> void:
	# Автоматически перезапускаем текущую зацикленную музыку
	if _music_player.stream != null:
		_music_player.play()


# ─── Внутренние методы ────────────────────────────────────────────────────────

func _apply_volumes() -> void:
	set_master_volume(master_volume)
	set_music_volume(music_volume)
	set_sfx_volume(sfx_volume)

## Создаёт шины Music и SFX, если их нет.
func _ensure_buses() -> void:
	if AudioServer.get_bus_index("Music") < 0:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "Music")
		AudioServer.set_bus_send(AudioServer.bus_count - 1, "Master")
		_music_player.bus = "Music"

	if AudioServer.get_bus_index("SFX") < 0:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "SFX")
		AudioServer.set_bus_send(AudioServer.bus_count - 1, "Master")
		_sfx_player.bus = "SFX"
