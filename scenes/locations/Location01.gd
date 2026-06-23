## Location01.gd
## Локация: Гостиная
extends "res://scripts/LocationBase.gd"

const ROOM_HOTSPOTS := {
	"evidence_01": {"rect": Rect2(805, 429, 47, 62), "label": "Замок с царапиной"},
	"evidence_02": {"rect": Rect2(335, 907, 449, 146), "label": "Нить"},
	"evidence_03": {"rect": Rect2(1647, 797, 153, 131), "label": "Пепельница"},
	"evidence_04": {"rect": Rect2(1783, 581, 105, 353), "label": "Пустая бутылка вина"},
}

const TABLE_TRIGGER_HOTSPOT := {"rect": Rect2(68, 577, 515, 316), "label": "Стол"}
const TABLE_EVIDENCE_HOTSPOTS := {
	"evidence_05": {"rect": Rect2(1259, 723, 484, 248), "label": "Визитка Штефана Крамера"},
	"evidence_06": {"rect": Rect2(218, 153, 1168, 836), "label": "Остатки ужина"},
}
const DOOR_HOTSPOT := {"rect": Rect2(770, 155, 239, 523), "label": "Дверь"}
const REQUIRED_EVIDENCE_IDS := ["evidence_01", "evidence_02", "evidence_03", "evidence_04", "evidence_05", "evidence_06"]

var _interrogation_notified: bool = false
var _notification_popup: Control = null
var _table_overlay: Control = null

func _ready() -> void:
	location_id = "location_01"
	location_name = "Гостиная"
	background_texture = preload("res://assets/locations/room_304.jpg")
	DiaryManager.evidence_found.connect(_on_evidence_found)
	super._ready()

func _setup_location() -> void:
	pass

func _on_scene_clicked(pos: Vector2) -> void:
	for evidence_id in ROOM_HOTSPOTS.keys():
		var hotspot_data: Dictionary = ROOM_HOTSPOTS[evidence_id]
		var rect: Rect2 = hotspot_data.get("rect", Rect2())
		if rect.has_point(pos):
			_handle_evidence_click(evidence_id, pos)
			return
	var table_rect: Rect2 = TABLE_TRIGGER_HOTSPOT.get("rect", Rect2())
	if table_rect.has_point(pos):
		_show_table_overlay()
		return
	var door_rect: Rect2 = DOOR_HOTSPOT.get("rect", Rect2())
	if door_rect.has_point(pos):
		_handle_door_click(pos)

func _handle_evidence_click(evidence_id: String, pos: Vector2) -> void:
	DiaryManager.find_evidence(evidence_id)
	_show_feedback(pos, "Улика найдена")

func _on_evidence_found(_evidence_id: String) -> void:
	_try_trigger_interrogation_notification()

func _try_trigger_interrogation_notification() -> void:
	if _interrogation_notified:
		return
	var all_found := true
	for evidence_id in REQUIRED_EVIDENCE_IDS:
		if not DiaryManager.evidence.get(evidence_id, {}).get("discovered", false):
			all_found = false
			break
	if all_found:
		_interrogation_notified = true
		_show_interrogation_notification()

func _handle_door_click(pos: Vector2) -> void:
	var found_all := true
	for evidence_id in REQUIRED_EVIDENCE_IDS:
		if not DiaryManager.evidence.get(evidence_id, {}).get("discovered", false):
			found_all = false
			break
	if found_all:
		travel_to("Location02")
	else:
		_show_feedback(pos, "Сначала найдите все улики")

func _show_table_overlay() -> void:
	if _table_overlay != null:
		return
	is_busy = true

	_table_overlay = Control.new()
	_table_overlay.name = "TableOverlay"
	_table_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_table_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	ui_layer.add_child(_table_overlay)

	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.0, 0.0, 0.0, 0.88)
	_table_overlay.add_child(dim)

	var image_rect := TextureRect.new()
	image_rect.texture = preload("res://assets/locations/table.jpg")
	image_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	image_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	image_rect.stretch_mode = TextureRect.STRETCH_SCALE
	image_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	image_rect.gui_input.connect(_on_table_image_input)
	_table_overlay.add_child(image_rect)

	var close_button := Button.new()
	close_button.text = "✕"
	close_button.custom_minimum_size = Vector2(56, 56)
	close_button.position = Vector2(1820, 24)
	close_button.pressed.connect(_close_table_overlay)
	_table_overlay.add_child(close_button)

func _on_table_image_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		var pos: Vector2 = (event as InputEventMouseButton).position
		for evidence_id in TABLE_EVIDENCE_HOTSPOTS.keys():
			var hotspot_data: Dictionary = TABLE_EVIDENCE_HOTSPOTS[evidence_id]
			var rect: Rect2 = hotspot_data.get("rect", Rect2())
			if rect.has_point(pos):
				_handle_evidence_click(evidence_id, pos)
				return

func _close_table_overlay() -> void:
	if _table_overlay != null:
		_table_overlay.queue_free()
		_table_overlay = null
	is_busy = false

func _show_interrogation_notification() -> void:
	if _notification_popup != null:
		return
	is_busy = true

	_notification_popup = Control.new()
	_notification_popup.name = "InterrogationNotification"
	_notification_popup.set_anchors_preset(Control.PRESET_FULL_RECT)
	_notification_popup.mouse_filter = Control.MOUSE_FILTER_STOP
	ui_layer.add_child(_notification_popup)

	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.0, 0.0, 0.0, 0.0)
	_notification_popup.add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_notification_popup.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(720, 320)
	panel.modulate.a = 0.0
	center.add_child(panel)

	var panel_vbox := VBoxContainer.new()
	panel_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel_vbox.add_theme_constant_override("separation", 16)
	panel.add_child(panel_vbox)

	var title := Label.new()
	title.text = "🔔 НОВЫЙ ДОПРОС"
	title.add_theme_font_size_override("font_size", 28)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel_vbox.add_child(title)

	var divider := ColorRect.new()
	divider.custom_minimum_size = Vector2(620, 2)
	divider.color = Color(0.8, 0.7, 0.35, 1.0)
	panel_vbox.add_child(divider)

	var body := Label.new()
	body.text = "Управляющий отеля Томас Бергер готов дать показания.\nОн был в контакте с жертвой каждый день."
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.custom_minimum_size = Vector2(620, 120)
	body.add_theme_font_size_override("font_size", 20)
	panel_vbox.add_child(body)

	var btn := Button.new()
	btn.text = "[ НАЧАТЬ ДОПРОС ]"
	btn.custom_minimum_size = Vector2(280, 54)
	btn.pressed.connect(_start_interrogation)
	panel_vbox.add_child(btn)

	var tween := create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.25)
	tween.tween_interval(7.0)
	tween.tween_property(panel, "modulate:a", 0.0, 0.25)
	tween.tween_callback(_clear_interrogation_notification)

func _start_interrogation() -> void:
	if _notification_popup != null:
		_clear_interrogation_notification(false)
	var overlay: CanvasLayer = load("res://scripts/InterrogationOverlay.gd").new()
	ui_layer.add_child(overlay)
	if overlay.has_method("setup"):
		overlay.setup(self)
	if overlay.has_method("show_interrogation"):
		overlay.show_interrogation()

func _clear_interrogation_notification(restore_input: bool = true) -> void:
	if _notification_popup != null:
		_notification_popup.queue_free()
		_notification_popup = null
	if restore_input:
		is_busy = false

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
