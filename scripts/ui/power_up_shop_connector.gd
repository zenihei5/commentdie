class_name PowerUpShopConnector
extends Control

var source_control: Control
var destination_control: Control
var line_color := Color(1.0, 0.56, 0.74, 0.28)
var line_width := 2.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func set_targets(source: Control, destination: Control, color: Color) -> void:
	source_control = source
	destination_control = destination
	line_color = Color(color, 0.28)
	queue_redraw()

func clear_targets() -> void:
	source_control = null
	destination_control = null
	queue_redraw()

func _draw() -> void:
	if source_control == null or destination_control == null:
		return
	if not is_instance_valid(source_control) or not is_instance_valid(destination_control):
		return
	var source_rect := source_control.get_global_rect()
	var destination_rect := destination_control.get_global_rect()
	var canvas_to_local := get_global_transform_with_canvas().affine_inverse()
	var source_point := canvas_to_local * Vector2(source_rect.end.x, source_rect.position.y + source_rect.size.y * 0.5)
	var destination_point := canvas_to_local * Vector2(destination_rect.position.x, destination_rect.position.y + destination_rect.size.y * 0.5)
	var bend_x := (source_point.x + destination_point.x) * 0.5
	var points := PackedVector2Array([
		source_point,
		Vector2(bend_x, source_point.y),
		Vector2(bend_x, destination_point.y),
		destination_point,
	])
	draw_polyline(points, line_color, line_width, true)
	draw_circle(source_point, 4.0, line_color)
	draw_circle(destination_point, 4.0, line_color)
