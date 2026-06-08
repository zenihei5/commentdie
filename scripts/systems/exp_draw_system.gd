class_name ExpDrawSystem
extends RefCounted

const DrawDataSystemScript := preload("res://scripts/systems/draw_data_system.gd")
const DrawPrimitiveSystemScript := preload("res://scripts/systems/draw_primitive_system.gd")

static func draw_exp_orbs(target: CanvasItem, exp_orb_list: Array, elapsed: float) -> void:
	for orb in DrawDataSystemScript.exp_orbs_draw_data(exp_orb_list, elapsed):
		draw_exp_orb(target, orb as Dictionary)

static func draw_exp_orb(target: CanvasItem, data: Dictionary) -> void:
	for part in DrawDataSystemScript.exp_orb_parts():
		DrawPrimitiveSystemScript.draw_simple_draw_part(target, data, part as Dictionary)
