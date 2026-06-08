class_name WeaponDrawSystem
extends RefCounted

const DrawDataSystemScript := preload("res://scripts/systems/draw_data_system.gd")
const DrawPrimitiveSystemScript := preload("res://scripts/systems/draw_primitive_system.gd")

static func draw_bullets(target: CanvasItem, bullets: Array, from_player: bool) -> void:
	for bullet in DrawDataSystemScript.bullet_draw_data(bullets, from_player):
		draw_bullet_item(target, bullet as Dictionary)

static func draw_bullet_item(target: CanvasItem, item: Dictionary) -> void:
	for part in DrawDataSystemScript.bullet_parts():
		DrawPrimitiveSystemScript.draw_simple_draw_part(target, item, part as Dictionary)

static func draw_boomerangs(target: CanvasItem, player_pos: Vector2, current_weapon: Dictionary, boomerang_level: int, hammer_range: float, elapsed: float, boomerang_texture: Texture2D = null, rotated_texture_drawer: Callable = Callable()) -> void:
	for item in DrawDataSystemScript.boomerang_draw_data_for_weapon(player_pos, current_weapon, boomerang_level, hammer_range, elapsed):
		draw_boomerang_item(target, item as Dictionary, boomerang_texture, rotated_texture_drawer)

static func draw_boomerang_item(target: CanvasItem, visual: Dictionary, boomerang_texture: Texture2D = null, rotated_texture_drawer: Callable = Callable()) -> void:
	if boomerang_texture != null and rotated_texture_drawer.is_valid():
		rotated_texture_drawer.call(
			boomerang_texture,
			visual["pos"] as Vector2,
			visual["textureSize"] as Vector2,
			float(visual["textureAngle"]),
			1.0
		)
		return
	for part in DrawDataSystemScript.boomerang_parts():
		DrawPrimitiveSystemScript.draw_simple_draw_part(target, visual, part as Dictionary)
