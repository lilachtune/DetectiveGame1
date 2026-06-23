## Location04.gd
## Локация: Кухня
extends "res://scripts/LocationBase.gd"

func _ready() -> void:
	location_id   = "location_04"
	location_name = "Кухня"
	background_texture = preload("res://assets/locations/location_04.png")
	## Переходы: exits = { "В библиотеку": "Location02" }
	super._ready()

func _setup_location() -> void:
	## Подключи Area2D-зоны:
	## $InteractiveAreas/ExitA.input_event.connect(func(_v, e, _s):
	##     if e is InputEventMouseButton and e.pressed: travel_to("Location02"))
	pass

func _on_scene_clicked(pos: Vector2) -> void:
	pass
