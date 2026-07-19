class_name PowerUpShopCardPattern
extends Control

var pattern_id := ""
var pattern_color := Color.WHITE
var pattern_alpha := 0.06
var visual_tier := 0

func configure(style: Dictionary, tier: int) -> void:
	pattern_id = String(style.get("patternId", ""))
	pattern_color = Color(String(style.get("accentColor", "#FFFFFF")))
	pattern_alpha = float(style.get("patternAlpha", 0.06))
	visual_tier = tier
	queue_redraw()

func _draw() -> void:
	if pattern_id == "":
		return
	var tier_alpha: float = pattern_alpha + [0.0, 0.02, 0.04, 0.07][clampi(visual_tier, 0, 3)]
	var ink := Color(pattern_color, clampf(tier_alpha, 0.04, 0.15))
	var rect := Rect2(Vector2(0, 0), size)
	var center := rect.get_center()
	match pattern_id:
		"heart_circle":
			draw_arc(Vector2(size.x - 46, 42), 22, 0.0, TAU, 24, ink, 2.0)
			draw_circle(Vector2(size.x - 46, 42), 7, ink)
			draw_circle(Vector2(size.x - 28, 42), 7, ink)
			draw_line(Vector2(size.x - 52, 47), Vector2(size.x - 37, 61), ink, 3.0)
		"spark_impact":
			var impact := Vector2(size.x - 44, 40)
			for index in range(6):
				var angle := TAU * float(index) / 6.0
				draw_line(impact + Vector2.from_angle(angle) * 12.0, impact + Vector2.from_angle(angle) * 30.0, ink, 3.0)
		"speed_wing":
			for index in range(3):
				var y := 28.0 + float(index) * 15.0
				draw_line(Vector2(size.x - 86, y), Vector2(size.x - 24, y - 12.0), ink, 3.0)
			draw_arc(Vector2(size.x - 46, 42), 24, -2.5, 0.2, 16, ink, 2.0)
		"hex_shield":
			var hex := PackedVector2Array()
			for index in range(6):
				hex.append(center + Vector2.from_angle(TAU * float(index) / 6.0) * 28.0)
			hex.append(hex[0])
			draw_polyline(hex, ink, 3.0, true)
		"book_chart":
			draw_rect(Rect2(size.x - 78, 22, 48, 40), ink, false, 3.0)
			draw_line(Vector2(size.x - 68, 53), Vector2(size.x - 54, 42), ink, 3.0)
			draw_line(Vector2(size.x - 54, 42), Vector2(size.x - 46, 47), ink, 3.0)
			draw_line(Vector2(size.x - 46, 47), Vector2(size.x - 35, 31), ink, 3.0)
		"comment_suction":
			draw_arc(Vector2(size.x - 48, 44), 30, 0.0, TAU, 32, ink, 2.0)
			draw_arc(Vector2(size.x - 48, 44), 18, 0.0, TAU, 24, ink, 2.0)
			draw_circle(Vector2(size.x - 48, 44), 5, ink)
		"steam_heart":
			draw_arc(Vector2(size.x - 48, 40), 18, PI, TAU, 16, ink, 3.0)
			draw_arc(Vector2(size.x - 48, 54), 22, PI, TAU, 16, ink, 3.0)
			draw_circle(Vector2(size.x - 48, 63), 8, ink)
		"star_ribbon":
			var star := PackedVector2Array()
			for index in range(10):
				var radius := 25.0 if index % 2 == 0 else 10.0
				star.append(Vector2(size.x - 48, 43) + Vector2.from_angle(-PI / 2.0 + TAU * float(index) / 10.0) * radius)
			star.append(star[0])
			draw_polyline(star, ink, 3.0, true)
			draw_line(Vector2(size.x - 82, 68), Vector2(size.x - 14, 68), ink, 3.0)
