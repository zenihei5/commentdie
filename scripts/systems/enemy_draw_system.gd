class_name EnemyDrawSystem
extends RefCounted

const DrawDataSystemScript := preload("res://scripts/systems/draw_data_system.gd")
const DrawPrimitiveSystemScript := preload("res://scripts/systems/draw_primitive_system.gd")
const TextureCacheSystemScript := preload("res://scripts/systems/texture_cache_system.gd")

static var enemy_texture_cache: Dictionary = {}

static func draw_enemies(target: CanvasItem, enemy_list: Array) -> void:
	for enemy in enemy_list:
		var enemy_draw: Dictionary = DrawDataSystemScript.enemy_draw_data(enemy as Dictionary)
		for part in DrawDataSystemScript.enemy_draw_parts(enemy_draw):
			draw_enemy_part(target, part as Dictionary)

static func draw_enemy_part(target: CanvasItem, part: Dictionary) -> void:
	var kind: String = String(part["kind"])
	if kind == "shadow":
		var shadow: Dictionary = part["data"] as Dictionary
		DrawPrimitiveSystemScript.draw_shadow(target, shadow["pos"] as Vector2, shadow["size"] as Vector2, float(shadow["alpha"]))
	elif kind == "body":
		draw_enemy_body(target, part["data"] as Dictionary)
	elif kind == "face":
		draw_enemy_face(target, part["data"] as Dictionary)
	elif kind == "bar":
		draw_enemy_hp_bar(target, part["data"] as Dictionary)
	elif kind == "speech":
		DrawPrimitiveSystemScript.draw_speech_bubble(target, part["data"] as Dictionary)

static func draw_enemy_body(target: CanvasItem, body: Dictionary) -> void:
	for part in DrawDataSystemScript.enemy_body_parts(body):
		var draw_part: Dictionary = part as Dictionary
		if String(draw_part["kind"]) == "sprite":
			draw_enemy_sprite(target, body)
		else:
			DrawPrimitiveSystemScript.draw_simple_draw_part(target, body, draw_part)

static func draw_enemy_sprite(target: CanvasItem, body: Dictionary) -> void:
	var path: String = String(body.get("texturePath", ""))
	if path == "":
		return
	var texture: Texture2D = TextureCacheSystemScript.load_png_texture(enemy_texture_cache, path)
	if texture == null:
		return
	target.draw_texture_rect(texture, body["rect"] as Rect2, false, body.get("modulate", Color.WHITE) as Color)

static func draw_enemy_face(target: CanvasItem, face: Dictionary) -> void:
	for part in DrawDataSystemScript.enemy_face_parts():
		DrawPrimitiveSystemScript.draw_simple_draw_part(target, face, part as Dictionary)

static func draw_enemy_hp_bar(target: CanvasItem, bar: Dictionary) -> void:
	for part in DrawDataSystemScript.enemy_hp_bar_parts():
		DrawPrimitiveSystemScript.draw_simple_draw_part(target, bar, part as Dictionary)
