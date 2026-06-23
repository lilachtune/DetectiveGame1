## Location02.gd
## Локация: Библиотека
extends "res://scripts/LocationBase.gd"

func _ready() -> void:
	location_id   = "location_02"
	location_name = "Коридор"
	background_texture = preload("res://assets/locations/room_304.jpg")
	super._ready()

func _setup_location() -> void:
	## Подключи Area2D-зоны:
	## $InteractiveAreas/ExitA.input_event.connect(func(_v, e, _s):
	##     if e is InputEventMouseButton and e.pressed: travel_to("Location02"))
	pass

func _on_scene_clicked(pos: Vector2) -> void:
	pass
