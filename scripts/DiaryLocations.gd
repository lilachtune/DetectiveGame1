## DiaryLocations.gd
## Сцена с изображением diary_locations.png и списком локаций.
## Можно открыть в редакторе Godot и редактировать визуально.
class_name DiaryLocations
extends Control

var labels := {
	"location_01": "Комната №304",
	"location_02": "Коридор",
	"location_03": "Кабинет",
	"location_04": "Кухня",
	"location_05": "Столовая",
	"location_06": "Главная спальня",
	"location_07": "Гостевая спальня",
	"location_08": "Подвал",
	"location_09": "Чердак",
	"location_10": "Сад",
	"location_11": "Гараж",
	"location_12": "Бальный зал",
	"location_13": "Коридор второго этажа",
	"location_14": "Ванная комната",
	"location_15": "Беседка",
}

signal close_pressed

@onready var locations_container: VBoxContainer = $ScrollContainer/LocationsContainer
@onready var header: Label = $HeaderLabel
@onready var separator: ColorRect = $Separator
@onready var btn_back: Button = $BtnBack
@onready var bg: TextureRect = $Bg

func _ready() -> void:
	btn_back.pressed.connect(_on_close)
	_populate()

func set_background(texture: Texture2D) -> void:
	if texture:
		bg.texture = texture

func _on_close() -> void:
	close_pressed.emit()

func _populate() -> void:
	# Очищаем старые записи (кроме шапки если была)
	for child in locations_container.get_children():
		child.queue_free()
	
	var total := DiaryManager.LOCATION_ORDER.size()
	var unlocked := DiaryManager.unlocked_location_index
	
	for i in range(total):
		var loc_id := DiaryManager.LOCATION_ORDER[i]
		var is_unlocked := i < unlocked
		var is_next := i == unlocked
		
		var row := HBoxContainer.new()
		
		var icon := Label.new()
		icon.add_theme_font_size_override("font_size", 22)
		icon.custom_minimum_size = Vector2(36, 0)
		
		var name_label := Label.new()
		name_label.add_theme_font_size_override("font_size", 20)
		name_label.text = labels.get(loc_id, loc_id) if is_unlocked else "???"
		
		if is_unlocked:
			icon.text = "●"
			icon.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))
			name_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
		elif is_next:
			icon.text = "○"
			icon.add_theme_color_override("font_color", Color(0.7, 0.8, 1.0))
			name_label.add_theme_color_override("font_color", Color(0.7, 0.8, 1.0))
			name_label.text = "??? (следующая)"
		else:
			icon.text = "✕"
			icon.add_theme_color_override("font_color", Color(0.3, 0.3, 0.3))
			name_label.add_theme_color_override("font_color", Color(0.3, 0.3, 0.4))
			name_label.text = "???"
		
		row.add_child(icon)
		row.add_child(name_label)
		locations_container.add_child(row)

## Обновить список (вызвать после изменения unlocked_location_index)
func refresh() -> void:
	_populate()