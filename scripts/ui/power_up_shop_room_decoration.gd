class_name PowerUpShopRoomDecoration
extends Control

## Lightweight room motifs for the shop backdrop.  The decoration is deliberately
## drawn at the edge of the screen so it never competes with shop information.

var _phase := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func _process(delta: float) -> void:
	_phase = fmod(_phase + delta / 4.5, TAU)
	queue_redraw()

func _draw() -> void:
	var viewport_size := size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var left := Vector2(maxf(24.0, viewport_size.x * 0.07), viewport_size.y * 0.24)
	var right := Vector2(viewport_size.x - maxf(24.0, viewport_size.x * 0.07), viewport_size.y * 0.72)
	var pulse := 0.5 + 0.5 * sin(_phase)
	var line_color := Color(0.52, 0.42, 0.72, 0.07 + pulse * 0.025)
	var pink := Color(1.0, 0.45, 0.68, 0.08 + pulse * 0.025)
	var blue := Color(0.35, 0.72, 0.92, 0.07 + pulse * 0.02)
	var gold := Color(0.92, 0.68, 0.25, 0.08 + pulse * 0.02)

	# Left edge: monitor/window and comment bubbles.
	var monitor_rect := Rect2(left + Vector2(-48.0, -34.0), Vector2(128.0, 82.0))
	draw_style_box(_panel(line_color, 12.0), monitor_rect)
	draw_line(monitor_rect.position + Vector2(14.0, 22.0), monitor_rect.end - Vector2(14.0, 22.0), line_color, 2.0)
	draw_line(monitor_rect.position + Vector2(14.0, 40.0), monitor_rect.position + Vector2(76.0, 40.0), blue, 2.0)
	draw_line(monitor_rect.position + Vector2(24.0, 82.0), monitor_rect.position + Vector2(42.0, 98.0), line_color, 3.0)
	draw_line(monitor_rect.position + Vector2(42.0, 98.0), monitor_rect.position + Vector2(78.0, 98.0), line_color, 3.0)
	_draw_comment_bubble(left + Vector2(-6.0, 92.0), 0.82, pink)
	_draw_comment_bubble(left + Vector2(116.0, 54.0), 0.58, blue)

	# Right edge: PP flow, cable, and small equipment dots.
	draw_circle(right + Vector2(0.0, -78.0), 42.0, Color(0.95, 0.78, 0.32, 0.045 + pulse * 0.015))
	draw_arc(right + Vector2(0.0, -78.0), 42.0, 0.0, TAU, 32, gold, 2.0)
	draw_circle(right + Vector2(0.0, -78.0), 10.0, gold)
	draw_line(right + Vector2(-90.0, -12.0), right + Vector2(-30.0, -56.0), line_color, 2.0)
	draw_line(right + Vector2(-30.0, -56.0), right + Vector2(0.0, -78.0), line_color, 2.0)
	draw_circle(right + Vector2(-90.0, -12.0), 6.0, pink)
	draw_circle(right + Vector2(-30.0, -56.0), 5.0, blue)
	for index in range(3):
		var offset := Vector2(-12.0 * index, 22.0 * index)
		draw_circle(right + Vector2(56.0, 24.0) + offset, 4.0, Color(0.72, 0.62, 0.9, 0.08))

func _draw_comment_bubble(center: Vector2, scale_value: float, color: Color) -> void:
	var bubble_size := Vector2(72.0, 44.0) * scale_value
	var rect := Rect2(center - bubble_size * 0.5, bubble_size)
	draw_style_box(_panel(color, 12.0 * scale_value), rect)
	for index in range(3):
		var x := rect.position.x + 14.0 * scale_value + index * 14.0 * scale_value
		draw_circle(Vector2(x, rect.position.y + rect.size.y * 0.52), 3.0 * scale_value, color)

func _panel(color: Color, radius: float) -> StyleBoxFlat:
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color(color.r, color.g, color.b, color.a * 0.35)
	panel.border_color = color
	panel.set_border_width_all(1)
	panel.set_corner_radius_all(maxi(2, roundi(radius)))
	return panel
