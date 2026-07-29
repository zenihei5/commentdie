class_name WeaponDrawSystem
extends RefCounted

const DrawDataSystemScript := preload("res://scripts/systems/draw_data_system.gd")
const DrawPrimitiveSystemScript := preload("res://scripts/systems/draw_primitive_system.gd")

static func draw_bullets(target: CanvasItem, bullets: Array, from_player: bool, rotated_texture_drawer: Callable = Callable(), texture_loader: Callable = Callable(), visible_rect: Rect2 = Rect2()) -> void:
	var use_culling := visible_rect.size != Vector2.ZERO
	for bullet_item in bullets:
		var bullet: Dictionary = bullet_item as Dictionary
		if use_culling and not visible_rect.has_point(Vector2(bullet.get("pos", Vector2.ZERO))):
			continue
		var visual_kind: String = String(bullet.get("visualKind", ""))
		if from_player and (visual_kind == "starlight_superchat" or visual_kind == "high_superchat"):
			var bullet_data_items: Array = DrawDataSystemScript.bullet_draw_data([bullet], from_player)
			if not bullet_data_items.is_empty():
				draw_bullet_item(target, bullet_data_items[0] as Dictionary, rotated_texture_drawer, texture_loader)
			continue
		draw_simple_bullet_item(target, bullet, from_player)

static func draw_simple_bullet_item(target: CanvasItem, bullet: Dictionary, from_player: bool) -> void:
	var pos: Vector2 = Vector2(bullet["pos"])
	var raw_vel: Vector2 = Vector2(bullet["vel"])
	var vel_sq := raw_vel.length_squared()
	var vel: Vector2 = raw_vel / sqrt(vel_sq) if vel_sq > 0.01 else Vector2.RIGHT
	var visual_kind: String = String(bullet.get("visualKind", ""))
	var player_visual_scale: float = clampf(float(bullet.get("visualScale", 1.0)), 1.0, 1.60) if from_player else 1.0
	var trail_length: float = 22.0
	var trail_color := Color(0.25, 0.73, 1.0, 0.28)
	var trail_width: float = 8.0
	var outer_radius: float = 9.0
	var outer_color := Color("#1d8fff")
	var inner_radius: float = 4.0
	var inner_color := Color.WHITE
	if from_player and visual_kind == "genre_stg_shot":
		trail_length = 34.0
		trail_color = Color(0.45, 0.95, 1.0, 0.34)
		trail_width = 6.0
		outer_radius = 7.0
		outer_color = Color("#55dfff")
		inner_radius = 3.2
		inner_color = Color("#ffffff")
	if not from_player:
		trail_length = 18.0
		trail_color = Color(1.0, 0.17, 0.35, 0.32)
		trail_width = 7.0
		outer_radius = 8.0
		outer_color = Color("#ff3357")
		inner_radius = 4.0
		inner_color = Color("#ffd0d8")
		if visual_kind == "kuso_maro":
			trail_length = 16.0
			trail_color = Color(0.34, 0.04, 0.48, 0.34)
			trail_width = 9.0
			outer_radius = 13.0
			outer_color = Color("#4c2c4f")
			inner_radius = 8.0
			inner_color = Color("#f094bd")
		elif visual_kind == "armchair_comment":
			trail_length = 20.0
			trail_color = Color(0.78, 0.36, 1.0, 0.30)
			trail_width = 6.0
			outer_radius = 9.0
			outer_color = Color("#b96bff")
			inner_radius = 4.0
			inner_color = Color("#fff4ff")
		elif visual_kind == "dot_invader_bullet":
			trail_length = 18.0
			trail_color = Color(0.25, 0.86, 1.0, 0.32)
			trail_width = 5.0
			outer_radius = 7.0
			outer_color = Color("#41dfff")
			inner_radius = 3.4
			inner_color = Color("#ffffff")
		elif visual_kind == "wiki_comment":
			trail_length = 16.0
			trail_color = Color(1.0, 0.82, 0.24, 0.28)
			trail_width = 6.0
			outer_radius = 8.5
			outer_color = Color("#ffd452")
			inner_radius = 4.0
			inner_color = Color("#fff8d8")
		elif visual_kind == "drone_bullet":
			trail_length = 24.0
			trail_color = Color(0.34, 0.92, 1.0, 0.34)
			trail_width = 4.5
			outer_radius = 6.6
			outer_color = Color("#6fe7ff")
			inner_radius = 3.1
			inner_color = Color("#ffffff")
	if from_player:
		trail_length *= player_visual_scale
		trail_width *= player_visual_scale
		outer_radius *= player_visual_scale
		inner_radius *= player_visual_scale
	target.draw_line(pos - vel * trail_length, pos, trail_color, trail_width)
	target.draw_circle(pos, outer_radius, outer_color)
	target.draw_circle(pos, inner_radius, inner_color)

static func draw_bullet_item(target: CanvasItem, item: Dictionary, rotated_texture_drawer: Callable = Callable(), texture_loader: Callable = Callable()) -> void:
	for part in DrawDataSystemScript.bullet_parts(item):
		DrawPrimitiveSystemScript.draw_simple_draw_part(target, item, part as Dictionary)
	var image_path := String(item.get("imagePath", ""))
	if image_path == "" or not rotated_texture_drawer.is_valid():
		return
	var texture: Texture2D = null
	if texture_loader.is_valid():
		texture = texture_loader.call(image_path) as Texture2D
	if texture == null:
		texture = ResourceLoader.load(image_path) as Texture2D
	if texture == null:
		var image := Image.new()
		if image.load(image_path) == OK:
			texture = ImageTexture.create_from_image(image)
	if texture == null:
		return
	rotated_texture_drawer.call(
		texture,
		item.get("imagePos", item.get("pos", Vector2.ZERO)) as Vector2,
		item.get("imageSize", texture.get_size()) as Vector2,
		float(item.get("imageAngle", 0.0)),
		float(item.get("imageAlpha", 1.0))
	)

static func draw_boomerangs(target: CanvasItem, player_pos: Vector2, current_weapon: Dictionary, boomerang_level: int, hammer_range: float, elapsed: float, boomerang_texture: Texture2D = null, rotated_texture_drawer: Callable = Callable(), weapon_state: Dictionary = {}, bullet_support_level: int = 0, texture_loader: Callable = Callable()) -> void:
	for item in DrawDataSystemScript.boomerang_draw_data_for_weapon(player_pos, current_weapon, boomerang_level, hammer_range, elapsed, weapon_state, bullet_support_level):
		draw_boomerang_item(target, item as Dictionary, boomerang_texture, rotated_texture_drawer, texture_loader)

static func draw_boomerang_item(target: CanvasItem, visual: Dictionary, boomerang_texture: Texture2D = null, rotated_texture_drawer: Callable = Callable(), texture_loader: Callable = Callable()) -> void:
	if String(visual.get("visualKind", "")) == "" and boomerang_texture != null and rotated_texture_drawer.is_valid():
		rotated_texture_drawer.call(
			boomerang_texture,
			visual["pos"] as Vector2,
			visual["textureSize"] as Vector2,
			float(visual["textureAngle"]),
			1.0
		)
		return
	for part in DrawDataSystemScript.boomerang_parts(visual):
		DrawPrimitiveSystemScript.draw_simple_draw_part(target, visual, part as Dictionary)
	var image_path := String(visual.get("imagePath", ""))
	if image_path == "" or not rotated_texture_drawer.is_valid():
		return
	var texture: Texture2D = null
	if texture_loader.is_valid():
		texture = texture_loader.call(image_path) as Texture2D
	if texture == null:
		texture = ResourceLoader.load(image_path) as Texture2D
	if texture == null:
		var image := Image.new()
		if image.load(image_path) == OK:
			texture = ImageTexture.create_from_image(image)
	if texture == null:
		return
	rotated_texture_drawer.call(
		texture,
		visual.get("imagePos", visual.get("pos", Vector2.ZERO)) as Vector2,
		visual.get("imageSize", texture.get_size()) as Vector2,
		float(visual.get("imageAngle", 0.0)),
		float(visual.get("imageAlpha", 1.0))
	)
