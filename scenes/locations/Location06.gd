## Location06.gd
## Локация: Главная спальня
extends LocationBase

func _ready() -> void:
	location_id   = "location_06"
	location_name = "Главная спальня"
	background_texture = preload("res://assets/locations/location_06.png")
	## Переходы: exits = { "В библиотеку": "Location02" }
	super._ready()

func _setup_location() -> void:
	## Подключи Area2D-зоны:
	## $InteractiveAreas/ExitA.input_event.connect(func(_v, e, _s):
	##     if e is InputEventMouseButton and e.pressed: travel_to("Location02"))
	pass

func _on_scene_clicked(pos: Vector2) -> void:
	pass
