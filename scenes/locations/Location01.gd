## Location01.gd
## Локация: Гостиная
extends LocationBase

const HOTSPOTS := {
	"evidence_01": {"rect": Rect2(63, 714, 169, 115), "label": "Визитка Крамера"},
	"evidence_02": {"rect": Rect2(245, 899, 126, 185), "label": "Нить кашемира"},
	"evidence_03": {"rect": Rect2(1664, 802, 153, 119), "label": "Пепельница с окурками"},
	"evidence_04": {"rect": Rect2(809, 428, 52, 66), "label": "Царапина на замке"},
}

const DOOR_HOTSPOT := {"rect": Rect2(775, 166, 214, 520), "label": "Дверь"}

func _ready() -> void:
	location_id   = "location_01"
	location_name = "Гостиная"
	background_texture = preload("res://assets/locations/room_304.jpg")
	super._ready()

func _setup_location() -> void:
	pass

func _on_scene_clicked(pos: Vector2) -> void:
	for evidence_id in HOTSPOTS.keys():
		var hotspot_data: Dictionary = HOTSPOTS[evidence_id]
		var rect: Rect2 = hotspot_data.get("rect", Rect2())
		if rect.has_point(pos):
			_handle_evidence_click(evidence_id, pos)
			return
	var door_rect: Rect2 = DOOR_HOTSPOT.get("rect", Rect2())
	if door_rect.has_point(pos):
		_handle_door_click(pos)

func _handle_evidence_click(evidence_id: String, pos: Vector2) -> void:
	DiaryManager.find_evidence(evidence_id)
	_show_feedback(pos, "Улика найдена")

func _handle_door_click(pos: Vector2) -> void:
	var found_all := true
	for evidence_id in HOTSPOTS.keys():
		if not DiaryManager.evidence.get(evidence_id, {}).get("discovered", false):
			found_all = false
			break
	if found_all:
		travel_to("Location02")
	else:
		_show_feedback(pos, "Сначала найдите все улики")

func _show_feedback(pos: Vector2, text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = pos + Vector2(20, -24)
	label.z_index = 1000
	label.modulate = Color(1.0, 0.95, 0.25, 1.0)
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.25, 1.0))
	label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.75))
	label.add_theme_constant_override("outline_size", 6)
	ui_layer.add_child(label)

	var tween := create_tween()
	tween.tween_property(label, "modulate:a", 0.0, 0.8).set_delay(0.6)
	tween.tween_callback(label.queue_free)
