class_name PowerUpShopHeroPattern
extends Control

var category := "combat"
var accent := Color("#FF8FBD")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func configure(next_category: String) -> void:
	category = next_category
	accent = Color("#FF8FBD") if category == "combat" else Color("#79D9EF")
	queue_redraw()

func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var ink := Color(accent, 0.12)
	var soft := Color(accent, 0.075)
	var right := Vector2(size.x - 36.0, size.y * 0.46)
	if category == "combat":
		for index in range(6):
			var angle := -PI * 0.82 + float(index) * 0.27
			var start := right + Vector2.from_angle(angle) * 18.0
			var end := right + Vector2.from_angle(angle) * (46.0 + float(index % 2) * 12.0)
			draw_line(start, end, ink, 3.0)
		for index in range(3):
			var spark := Vector2(size.x * 0.62 + float(index) * 38.0, 28.0 + float(index % 2) * 28.0)
			draw_circle(spark, 4.0, ink)
			draw_line(spark - Vector2(14.0, 0.0), spark + Vector2(14.0, 0.0), soft, 2.0)
			draw_line(spark - Vector2(0.0, 14.0), spark + Vector2(0.0, 14.0), soft, 2.0)
		var arrow_base := Vector2(size.x - 86.0, size.y - 36.0)
		draw_line(arrow_base, arrow_base + Vector2(0.0, -48.0), ink, 3.0)
		draw_line(arrow_base + Vector2(0.0, -48.0), arrow_base + Vector2(-10.0, -36.0), ink, 3.0)
		draw_line(arrow_base + Vector2(0.0, -48.0), arrow_base + Vector2(10.0, -36.0), ink, 3.0)
	else:
		var ring_center := Vector2(size.x - 70.0, size.y * 0.50)
		for radius in [24.0, 42.0, 60.0]:
			draw_arc(ring_center, radius, -PI * 0.65, PI * 0.65, 24, soft, 3.0)
		_draw_bubble(Vector2(52.0, 34.0), 0.78, ink)
		_draw_bubble(Vector2(size.x * 0.52, size.y - 30.0), 0.55, soft)
		var wave_start := Vector2(size.x * 0.46, size.y * 0.50)
		var points := PackedVector2Array()
		for index in range(9):
			points.append(wave_start + Vector2(float(index) * 15.0, sin(float(index) * 0.9) * 8.0))
		draw_polyline(points, ink, 3.0, true)

func _draw_bubble(center: Vector2, scale_value: float, color: Color) -> void:
	var radius := 18.0 * scale_value
	draw_circle(center, radius, Color(color.r, color.g, color.b, color.a * 0.35))
	draw_arc(center, radius, 0.0, TAU, 20, color, 2.0)
	draw_circle(center + Vector2(-radius * 0.32, 0.0), 2.5 * scale_value, color)
	draw_circle(center + Vector2(radius * 0.32, 0.0), 2.5 * scale_value, color)
