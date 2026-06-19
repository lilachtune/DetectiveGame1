## Location08.gd
## Локация: Подвал
extends LocationBase

func _ready() -> void:
	location_id   = "location_08"
	location_name = "Подвал"
	background_texture = preload("res://assets/locations/location_08.png")
	## Переходы: exits = { "В библиотеку": "Location02" }
	super._ready()

func _setup_location() -> void:
	## Подключи Area2D-зоны:
	## $InteractiveAreas/ExitA.input_event.connect(func(_v, e, _s):
	##     if e is InputEventMouseButton and e.pressed: travel_to("Location02"))
	pass

func _on_scene_clicked(pos: Vector2) -> void:
	pass
