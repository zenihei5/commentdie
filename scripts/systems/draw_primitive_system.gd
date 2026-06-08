class_name DrawPrimitiveSystem
extends RefCounted

const GameFontSystemScript := preload("res://scripts/systems/game_font_system.gd")

static func draw_shadow(target: CanvasItem, pos: Vector2, size: Vector2, alpha: float = 0.28) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	for i in range(18):
		var angle: float = TAU * float(i) / 18.0
		points.append(pos + Vector2(cos(angle) * size.x * 0.5, sin(angle) * size.y * 0.5))
	target.draw_colored_polygon(points, Color(0.0, 0.0, 0.0, alpha))

static func draw_spark(target: CanvasItem, pos: Vector2, size: float, color: Color) -> void:
	target.draw_line(pos + Vector2(-size, 0), pos + Vector2(size, 0), color, 2.0)
	target.draw_line(pos + Vector2(0, -size), pos + Vector2(0, size), color, 2.0)

static func draw_speech_bubble(target: CanvasItem, bubble: Dictionary) -> void:
	if bubble.is_empty():
		return
	var rect: Rect2 = bubble["rect"] as Rect2
	var tail: PackedVector2Array = bubble["tail"] as PackedVector2Array
	var fill: Color = bubble["fill"] as Color
	var border: Color = bubble["border"] as Color
	var border_width: int = int(bubble["borderWidth"])
	target.draw_colored_polygon(tail, fill)
	target.draw_rect(rect, fill, true)
	target.draw_rect(rect, border, false, border_width)
	if tail.size() >= 3:
		target.draw_line(tail[0], tail[2], border, float(border_width))
		target.draw_line(tail[1], tail[2], border, float(border_width))
	draw_text_item(target, bubble, "", HORIZONTAL_ALIGNMENT_CENTER)

static func draw_simple_draw_part(target: CanvasItem, data: Dictionary, part: Dictionary) -> void:
	var kind: String = String(part["kind"])
	var prefix: String = String(part.get("prefix", ""))
	if kind == "line":
		var line_width: float = float(part["width"]) if part.has("width") else float(data[String(part.get("widthKey", prefix + "Width" if prefix != "" else "width"))])
		var line_color_override: Variant = null
		if part.has("colorKey"):
			line_color_override = data[String(part["colorKey"])] as Color
		draw_line_item(target, data, prefix, line_width, line_color_override)
	elif kind == "panel":
		draw_panel_rect(target, data)
	elif kind == "circle":
		draw_circle_item(
			target,
			data,
			prefix,
			String(part.get("radiusPrefix", "")),
			bool(part.get("filled", true)),
			float(part.get("width", -1.0)),
			String(part.get("colorKey", ""))
		)
	elif kind == "rect":
		draw_rect_item(target, data, prefix)
	elif kind == "rect_keys":
		draw_rect_item(target, {"rect": data[String(part["rectKey"])] as Rect2, "color": data[String(part["colorKey"])] as Color})
	elif kind == "bar":
		draw_bar_item(target, data)
	elif kind == "arc":
		if part.has("pos"):
			draw_fixed_arc(target, part["pos"] as Vector2, float(part["radius"]), float(part["start"]), float(part["end"]), int(part["points"]), part["color"] as Color, float(part["width"]))
		else:
			draw_arc_item(target, data, prefix)
	elif kind == "text":
		var alignment: int = int(part.get("alignment", HORIZONTAL_ALIGNMENT_LEFT))
		var text_color_override: Variant = null
		if part.has("colorKey"):
			text_color_override = data[String(part["colorKey"])] as Color
		draw_text_item(target, data, prefix, alignment, text_color_override, String(part.get("text", "")))
	elif kind == "dot":
		draw_circle_item(target, {"pos": part["pos"] as Vector2, "radius": data["dotRadius"], "color": data["dotColor"] as Color})
	elif kind == "time":
		draw_text_item(target, data, "time", HORIZONTAL_ALIGNMENT_LEFT, null, "%02d" % int(ceil(float(data["timeLeft"]))))
	elif kind == "shadow":
		draw_shadow(target, data["shadowPos"] as Vector2, data["shadowSize"] as Vector2, float(data["shadowAlpha"]))
	elif kind == "polygon":
		target.draw_polygon(data[String(part["pointsKey"])] as PackedVector2Array, data[String(part["colorsKey"])] as PackedColorArray)
	elif kind == "polyline":
		target.draw_polyline(data[String(part["pointsKey"])] as PackedVector2Array, data[String(part["colorKey"])] as Color, float(data[String(part["widthKey"])]))
	elif kind == "speech":
		draw_speech_bubble(target, part["data"] as Dictionary)

static func draw_panel_rect(target: CanvasItem, data: Dictionary) -> void:
	var rect: Rect2 = data["rect"] as Rect2
	target.draw_rect(rect, data["fill"] as Color)
	target.draw_rect(rect, data["border"] as Color, false, int(data["borderWidth"]))

static func draw_prefixed_panel_rect(target: CanvasItem, data: Dictionary, prefix: String) -> void:
	var rect: Rect2 = data[prefix + "Rect"] as Rect2
	target.draw_rect(rect, data[prefix + "Fill"] as Color)
	target.draw_rect(rect, data[prefix + "Border"] as Color, false, int(data[prefix + "BorderWidth"]))

static func draw_rect_outline(target: CanvasItem, rect: Rect2, color: Color, width: int) -> void:
	target.draw_rect(rect, color, false, width)

static func draw_rect_item(target: CanvasItem, item: Dictionary, prefix: String = "") -> void:
	var key_prefix: String = prefix
	var rect_key: String = key_prefix + "Rect" if key_prefix != "" else "rect"
	var color_key: String = key_prefix + "Color" if key_prefix != "" else "color"
	target.draw_rect(item[rect_key] as Rect2, item[color_key] as Color)

static func draw_bar_item(target: CanvasItem, item: Dictionary) -> void:
	draw_rect_item(target, item, "back")
	draw_rect_item(target, item, "fill")

static func draw_circle_item(target: CanvasItem, item: Dictionary, prefix: String = "", radius_prefix: String = "", filled: bool = true, width: float = -1.0, color_key_override: String = "") -> void:
	var key_prefix: String = prefix
	var radius_key_prefix: String = radius_prefix if radius_prefix != "" else key_prefix
	var pos_key: String = key_prefix + "Pos" if key_prefix != "" else "pos"
	var radius_key: String = radius_key_prefix + "Radius" if radius_key_prefix != "" else "radius"
	var color_key: String = key_prefix + "Color" if key_prefix != "" else "color"
	if color_key_override != "":
		color_key = color_key_override
	if key_prefix != "" and not item.has(pos_key) and item.has(key_prefix):
		pos_key = key_prefix
	if key_prefix != "" and not item.has(pos_key):
		pos_key = "pos"
	if key_prefix != "" and not item.has(color_key):
		color_key = "color"
	if not item.has(radius_key):
		radius_key = "radius"
	var width_value: float = width if width >= 0.0 else -1.0
	target.draw_circle(item[pos_key] as Vector2, float(item[radius_key]), item[color_key] as Color, filled, width_value)

static func draw_line_item(target: CanvasItem, item: Dictionary, prefix: String = "", width: float = -1.0, color_override: Variant = null) -> void:
	var key_prefix: String = prefix
	var start_key: String = key_prefix + "Start" if key_prefix != "" else "start"
	var end_key: String = key_prefix + "End" if key_prefix != "" else "end"
	var color_key: String = key_prefix + "Color" if key_prefix != "" else "color"
	var width_key: String = key_prefix + "Width" if key_prefix != "" else "width"
	if not item.has(start_key):
		start_key = "from" if item.has("from") else "start"
	if not item.has(end_key):
		end_key = "to" if item.has("to") else "end"
	if key_prefix != "" and not item.has(color_key):
		color_key = "color"
	var color_value: Color = color_override as Color if color_override != null else item[color_key] as Color
	var width_value: float = width if width >= 0.0 else float(item[width_key])
	target.draw_line(item[start_key] as Vector2, item[end_key] as Vector2, color_value, width_value)

static func draw_arc_item(target: CanvasItem, item: Dictionary, prefix: String) -> void:
	draw_fixed_arc(target, item["pos"] as Vector2, float(item[prefix + "Radius"]), float(item[prefix + "Start"]), float(item[prefix + "End"]), int(item[prefix + "Points"]), item[prefix + "Color"] as Color, float(item[prefix + "Width"]))

static func draw_fixed_arc(target: CanvasItem, pos: Vector2, radius: float, start_angle: float, end_angle: float, points: int, color: Color, width: float) -> void:
	target.draw_arc(pos, radius, start_angle, end_angle, points, color, width)

static func draw_text_item(target: CanvasItem, item: Dictionary, prefix: String = "", alignment = HORIZONTAL_ALIGNMENT_LEFT, override_color: Variant = null, override_text: String = "") -> void:
	var key_prefix: String = prefix
	var pos_key: String = key_prefix + "Pos" if key_prefix != "" else "pos"
	var text_key: String = key_prefix if key_prefix != "" else "text"
	if key_prefix != "" and item.has(key_prefix + "Text"):
		text_key = key_prefix + "Text"
	elif key_prefix != "" and not item.has(text_key):
		text_key = key_prefix + "Text"
	var width_key: String = key_prefix + "Width" if key_prefix != "" else "width"
	var size_key: String = key_prefix + "Size" if key_prefix != "" else "size"
	var color_key: String = key_prefix + "Color" if key_prefix != "" else "color"
	var text_value: String = override_text if override_text != "" else String(item[text_key])
	var color_value: Color = override_color as Color if override_color != null else item[color_key] as Color
	target.draw_string(
		GameFontSystemScript.font_for_item(item, prefix),
		item[pos_key] as Vector2,
		text_value,
		alignment,
		int(item.get(width_key, -1)),
		int(item[size_key]),
		color_value
	)

static func draw_multiline_text_item(target: CanvasItem, item: Dictionary, alignment = HORIZONTAL_ALIGNMENT_LEFT) -> void:
	target.draw_multiline_string(
		GameFontSystemScript.font_for_item(item),
		item["pos"] as Vector2,
		String(item["text"]),
		alignment,
		int(item.get("width", -1)),
		int(item["size"]),
		-1,
		item["color"] as Color
	)
