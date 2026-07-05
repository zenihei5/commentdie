class_name ExpDrawSystem
extends RefCounted

const DrawDataSystemScript := preload("res://scripts/systems/draw_data_system.gd")
const DrawPrimitiveSystemScript := preload("res://scripts/systems/draw_primitive_system.gd")

static func draw_exp_orbs(target: CanvasItem, exp_orb_list: Array, elapsed: float, visible_rect: Rect2 = Rect2()) -> void:
	var use_culling := visible_rect.size != Vector2.ZERO
	for orb_item in exp_orb_list:
		var orb: Dictionary = orb_item as Dictionary
		var pos := Vector2(orb.get("pos", Vector2.ZERO))
		if use_culling and not visible_rect.has_point(pos):
			continue
		draw_exp_orb(target, DrawDataSystemScript.exp_orb_data(
			pos,
			elapsed,
			int(orb.get("value", 1)),
			String(orb.get("visualType", "small_blue"))
		))

static func draw_exp_orb(target: CanvasItem, data: Dictionary) -> void:
	for part in DrawDataSystemScript.exp_orb_parts():
		DrawPrimitiveSystemScript.draw_simple_draw_part(target, data, part as Dictionary)
