class_name WeaponDrawSystem
extends RefCounted

const DrawDataSystemScript := preload("res://scripts/systems/draw_data_system.gd")
const DrawPrimitiveSystemScript := preload("res://scripts/systems/draw_primitive_system.gd")
const KUSO_MARO_PROJECTILE_TEXTURE := "res://assets/generated/boss_attack_fx_v1/kuso_maro_projectile.png"
const KUSO_MARO_PROJECTILE_DRAW_SIZE := Vector2(42.0, 42.0)
const BUG_SPOILER_PROJECTILE_TEXTURE := "res://assets/generated/boss_attack_fx_v1/bug_spoiler_projectile.png"
const BUG_SPOILER_PROJECTILE_DRAW_SIZE := 40.0
const BUG_SPOILER_PROJECTILE_ROTATION_LIMIT := deg_to_rad(50.0)
const PITCH_POLICE_NOTE_DRAW_SIZE := 38.0
const PITCH_POLICE_NOTE_ROTATION_LIMIT := deg_to_rad(40.0)
const RED_PEN_BULLET_DRAW_SIZE := 38.0
const RED_PEN_BULLET_TRAIL_LENGTH := 24.0
const COMMENT_SHOTGUN_PROJECTILE_TEXTURE := "res://assets/generated/boss_attack_fx_v1/comment_shotgun_projectile.png"
const COMMENT_SHOTGUN_PROJECTILE_TEXTURE_RESOURCE: Texture2D = preload("res://assets/generated/boss_attack_fx_v1/comment_shotgun_projectile.png")
const COMMENT_SHOTGUN_PROJECTILE_DRAW_SIZE := 40.0
const COMMENT_SHOTGUN_PROJECTILE_TRAIL_LENGTH := 21.0
const TRAVEL_COMMENT_PROJECTILE_DRAW_SIZE := 40.0
const TRAVEL_COMMENT_PROJECTILE_TRAIL_LENGTH := 18.0
const TRAVEL_COMMENT_PROJECTILE_HIT_RADIUS := 22.0
const TRAVEL_COMMENT_PROJECTILE_FOREGROUND_DURATION := 0.40
const TRAVEL_NOISE_SHOT_DRAW_SIZE := 40.0
const TRAVEL_NOISE_SHOT_TRAIL_LENGTH := 16.0
const TRAVEL_NOISE_SHOT_HIT_RADIUS := 22.0
const TRAVEL_NOISE_SHOT_FOREGROUND_DURATION := 1.60
const GAME_OVER_BARRAGE_HIT_RADIUS := 22.0
const GAME_OVER_BARRAGE_TRAIL_LENGTH := 18.0

static func draw_bullets(target: CanvasItem, bullets: Array, from_player: bool, rotated_texture_drawer: Callable = Callable(), texture_loader: Callable = Callable(), visible_rect: Rect2 = Rect2(), visual_kind_filter: String = "") -> void:
	var use_culling := visible_rect.size != Vector2.ZERO
	var game_over_density: Dictionary = {}
	if not from_player:
		for bullet_index in range(bullets.size()):
			var density_bullet: Dictionary = bullets[bullet_index] as Dictionary
			if String(density_bullet.get("visualKind", "")) == "game_over_barrage" and bool(density_bullet.get("relayBossProjectile", false)):
				game_over_density[bullet_index] = _game_over_barrage_density_for_index(bullets, bullet_index)
	for bullet_index in range(bullets.size()):
		var bullet_item: Variant = bullets[bullet_index]
		var bullet: Dictionary = bullet_item as Dictionary
		if bool(bullet.get("redPenTelegraphPending", false)):
			continue
		if use_culling and not visible_rect.has_point(Vector2(bullet.get("pos", Vector2.ZERO))):
			continue
		var visual_kind: String = String(bullet.get("visualKind", ""))
		if visual_kind_filter == "exclude_kuso_maro" and visual_kind == "kuso_maro":
			continue
		var is_foreground_boss_projectile := visual_kind == "red_pen_mark" and bool(bullet.get("bossProjectile", false))
		if visual_kind_filter == "exclude_foreground_boss_projectiles" and (visual_kind in ["kuso_maro", "bug_spoiler", "pitch_police_note"] or is_foreground_boss_projectile):
			continue
		if visual_kind_filter == "only_kuso_maro" and visual_kind != "kuso_maro":
			continue
		if visual_kind_filter == "only_bug_spoiler" and visual_kind != "bug_spoiler":
			continue
		if visual_kind_filter == "only_pitch_police_note" and visual_kind != "pitch_police_note":
			continue
		if not from_player and visual_kind == "kuso_maro":
			draw_kuso_maro_projectile(target, bullet, rotated_texture_drawer, texture_loader)
			continue
		if not from_player and visual_kind == "bug_spoiler":
			draw_bug_spoiler_projectile(target, bullet, rotated_texture_drawer, texture_loader)
			continue
		if not from_player and visual_kind == "pitch_police_note":
			draw_pitch_police_note_projectile(target, bullet)
			continue
		if not from_player and visual_kind == "red_pen_mark" and bool(bullet.get("bossProjectile", false)):
			draw_red_pen_projectile(target, bullet)
			continue
		if not from_player and visual_kind == "comment_shotgun" and bool(bullet.get("relayBossProjectile", false)):
			draw_comment_shotgun_projectile(target, bullet, rotated_texture_drawer, texture_loader)
			continue
		if not from_player and visual_kind == "travel_comment_salvo" and bool(bullet.get("relayBossProjectile", false)):
			draw_travel_comment_projectile(target, bullet, rotated_texture_drawer, texture_loader)
			continue
		if not from_player and visual_kind == "travel_noise_shot" and bool(bullet.get("relayBossProjectile", false)):
			draw_travel_noise_shot_projectile(target, bullet)
			continue
		if not from_player and visual_kind == "game_over_barrage" and bool(bullet.get("relayBossProjectile", false)):
			draw_game_over_barrage_projectile(target, bullet, float(game_over_density.get(bullet_index, 1.0)))
			continue
		if from_player and (visual_kind == "starlight_superchat" or visual_kind == "high_superchat"):
			var bullet_data_items: Array = DrawDataSystemScript.bullet_draw_data([bullet], from_player)
			if not bullet_data_items.is_empty():
				draw_bullet_item(target, bullet_data_items[0] as Dictionary, rotated_texture_drawer, texture_loader)
			continue
		draw_simple_bullet_item(target, bullet, from_player)

static func _game_over_barrage_density_for_index(bullets: Array, bullet_index: int) -> float:
	var bullet: Dictionary = bullets[bullet_index] as Dictionary
	var pos := Vector2(bullet.get("pos", Vector2.ZERO))
	var nearby := 0
	for other_index in range(bullets.size()):
		if other_index == bullet_index:
			continue
		var other: Dictionary = bullets[other_index] as Dictionary
		if String(other.get("visualKind", "")) != "game_over_barrage" or not bool(other.get("relayBossProjectile", false)):
			continue
		if pos.distance_squared_to(Vector2(other.get("pos", Vector2.ZERO))) <= 64.0 * 64.0:
			nearby += 1
	if nearby <= 0:
		return 1.0
	if nearby == 1:
		return 0.78
	if nearby == 2:
		return 0.58
	return 0.42

static func _game_over_barrage_body_points(pos: Vector2, direction: Vector2, side: Vector2) -> PackedVector2Array:
	return PackedVector2Array([
		pos + direction * 10.5 + side * 3.8,
		pos + direction * 7.0 + side * 8.0,
		pos - direction * 7.8 + side * 7.4,
		pos - direction * 10.5 + side * 2.6,
		pos - direction * 9.4 - side * 5.4,
		pos + direction * 6.8 - side * 8.0,
		pos + direction * 10.5 - side * 3.0,
		pos + direction * 10.5 + side * 3.8
	])

static func _draw_game_over_barrage_bracket(target: CanvasItem, pos: Vector2, direction: Vector2, alpha: float, density_factor: float = 1.0) -> void:
	var bracket_alpha := maxf(0.26, alpha * clampf(density_factor, 0.42, 1.0))
	var angle := direction.angle()
	var bracket_color := Color(0.86, 0.10, 0.28, bracket_alpha)
	for offset in [0.0, PI * 0.5, PI, PI * 1.5]:
		target.draw_arc(pos, GAME_OVER_BARRAGE_HIT_RADIUS - 0.7, angle + offset - 0.22, angle + offset + 0.22, 5, bracket_color, 1.35, true)

static func _draw_game_over_barrage_symbol(target: CanvasItem, pos: Vector2, direction: Vector2, side: Vector2, pellet_index: int, alpha: float) -> void:
	var symbol_color := Color(1.0, 0.92, 0.94, clampf(alpha, 0.0, 1.0))
	var dark_color := Color(0.13, 0.01, 0.12, clampf(alpha * 0.86, 0.0, 1.0))
	match posmod(pellet_index, 6):
		0:
			target.draw_line(pos - direction * 4.7 - side * 4.6, pos + direction * 4.7 + side * 4.6, symbol_color, 1.8, true)
			target.draw_line(pos - direction * 4.7 + side * 4.6, pos + direction * 4.7 - side * 4.6, symbol_color, 1.8, true)
		1:
			target.draw_line(pos - side * 4.8, pos + side * 2.6, symbol_color, 2.0, true)
			target.draw_circle(pos + side * 5.0, 1.45, symbol_color)
		2:
			target.draw_line(pos + direction * 5.8 + side * 5.0, pos - direction * 5.0 + side * 5.0, symbol_color, 1.7, true)
			target.draw_line(pos - direction * 5.0 + side * 5.0, pos - direction * 5.0 + side * 1.2, symbol_color, 1.7, true)
			target.draw_line(pos + direction * 4.0 - side * 5.0, pos + direction * 4.0 - side * 1.4, dark_color, 1.5, true)
		3:
			target.draw_line(pos - direction * 5.0, pos + direction * 5.0, symbol_color, 1.7, true)
			target.draw_line(pos - side * 4.5, pos + side * 4.5, symbol_color, 1.7, true)
			target.draw_circle(pos, 1.7, dark_color)
		4:
			target.draw_rect(Rect2(pos + Vector2(-4.5, -3.5), Vector2(9.0, 7.0)), symbol_color, false, 1.6, true)
			target.draw_rect(Rect2(pos + Vector2(-1.4, -1.3), Vector2(3.0, 2.6)), dark_color, true)
		5:
			target.draw_line(pos - direction * 4.8 - side * 4.8, pos - direction * 1.0 - side * 4.8, symbol_color, 1.7, true)
			target.draw_line(pos - direction * 4.8 - side * 4.8, pos - direction * 4.8 + side * 0.8, symbol_color, 1.7, true)
			target.draw_line(pos + direction * 1.0 + side * 4.5, pos + direction * 5.0 + side * 1.2, Color(1.0, 0.34, 0.54, alpha * 0.90), 1.5, true)

static func draw_game_over_barrage_projectile(target: CanvasItem, bullet: Dictionary, density_factor: float = 1.0) -> void:
	var pos := Vector2(bullet.get("pos", Vector2.ZERO))
	var raw_vel := Vector2(bullet.get("vel", Vector2.RIGHT))
	var direction := raw_vel.normalized() if raw_vel.length_squared() > 0.01 else Vector2.RIGHT
	var side := Vector2(-direction.y, direction.x)
	var pellet_index := int(bullet.get("gameOverBarragePelletIndex", 0))
	var visual_seed := float(bullet.get("gameOverBarrageVisualSeed", 0.0))
	var age := maxf(0.0, float(bullet.get("gameOverBarrageAge", 0.0)))
	var pulse := 0.92 + 0.08 * sin(age * 16.0 + visual_seed * TAU)
	var density := clampf(density_factor, 0.42, 1.0)
	var trail_start := pos - direction * GAME_OVER_BARRAGE_TRAIL_LENGTH
	target.draw_line(trail_start, pos - direction * 7.0, Color(0.16, 0.01, 0.13, 0.28 * density), 2.6, true)
	target.draw_line(pos - direction * 16.0, pos - direction * 7.0, Color(0.86, 0.05, 0.22, 0.52 * density), 1.15, true)
	for fragment_index in range(2):
		var fragment_t := 0.30 + float(fragment_index) * 0.34
		var fragment_pos := pos - direction * GAME_OVER_BARRAGE_TRAIL_LENGTH * fragment_t + side * (sin(visual_seed * TAU + float(fragment_index) * 2.1) * 2.0)
		var fragment_size := 2.0 if fragment_index == 0 else 1.5
		target.draw_rect(Rect2(fragment_pos - Vector2(fragment_size, fragment_size * 0.5), Vector2(fragment_size * 2.0, fragment_size)), Color(0.64, 0.03, 0.24, 0.38 * density), true)
	var body_points := _game_over_barrage_body_points(pos, direction, side)
	target.draw_colored_polygon(body_points, Color(0.08, 0.012, 0.12, 0.94))
	target.draw_polyline(body_points, Color(0.72, 0.04, 0.24, 0.96), 1.55, true)
	var inner_points := PackedVector2Array([
		pos + direction * 7.8 + side * 2.4,
		pos + direction * 5.0 + side * 5.8,
		pos - direction * 5.8 + side * 5.2,
		pos - direction * 7.8 + side * 1.8,
		pos - direction * 7.0 - side * 3.7,
		pos + direction * 5.0 - side * 5.8,
		pos + direction * 7.8 - side * 2.1,
		pos + direction * 7.8 + side * 2.4
	])
	target.draw_colored_polygon(inner_points, Color(0.48, 0.018, 0.17, 0.78 * pulse))
	_draw_game_over_barrage_symbol(target, pos, direction, side, pellet_index, 0.96)
	_draw_game_over_barrage_bracket(target, pos, direction, 0.48, density)

static func _draw_game_over_barrage_edge(target: CanvasItem, bullet: Dictionary, alpha: float = 0.90) -> void:
	var pos := Vector2(bullet.get("pos", Vector2.ZERO))
	var raw_vel := Vector2(bullet.get("vel", Vector2.RIGHT))
	var direction := raw_vel.normalized() if raw_vel.length_squared() > 0.01 else Vector2.RIGHT
	var side := Vector2(-direction.y, direction.x)
	var points := _game_over_barrage_body_points(pos, direction, side)
	target.draw_polyline(points, Color(1.0, 0.18, 0.38, clampf(alpha, 0.0, 1.0)), 1.9, true)
	_draw_game_over_barrage_symbol(target, pos, direction, side, int(bullet.get("gameOverBarragePelletIndex", 0)), alpha)
	_draw_game_over_barrage_bracket(target, pos, direction, alpha * 0.72, 1.0)

static func draw_game_over_barrage_launch_foreground(target: CanvasItem, bullets: Array, visible_rect: Rect2 = Rect2()) -> void:
	var use_culling := visible_rect.size != Vector2.ZERO
	for bullet_item in bullets:
		var bullet: Dictionary = bullet_item as Dictionary
		if String(bullet.get("visualKind", "")) != "game_over_barrage" or not bool(bullet.get("relayBossProjectile", false)):
			continue
		if float(bullet.get("gameOverBarrageAge", 0.0)) > 0.15:
			continue
		var pos := Vector2(bullet.get("pos", Vector2.ZERO))
		if use_culling and not visible_rect.grow(36.0).has_point(pos):
			continue
		_draw_game_over_barrage_edge(target, bullet, 0.92)

static func draw_game_over_barrage_player_near_rims(target: CanvasItem, bullets: Array, player_pos: Vector2, visible_rect: Rect2 = Rect2()) -> void:
	var use_culling := visible_rect.size != Vector2.ZERO
	for bullet_item in bullets:
		var bullet: Dictionary = bullet_item as Dictionary
		if String(bullet.get("visualKind", "")) != "game_over_barrage" or not bool(bullet.get("relayBossProjectile", false)):
			continue
		if float(bullet.get("gameOverBarrageAge", 0.0)) <= 0.15:
			continue
		var pos := Vector2(bullet.get("pos", Vector2.ZERO))
		if pos.distance_squared_to(player_pos) > 90.0 * 90.0:
			continue
		if use_culling and not visible_rect.grow(36.0).has_point(pos):
			continue
		_draw_game_over_barrage_edge(target, bullet, 0.86)

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
	var boss_genre_visual := not from_player and bool(bullet.get("bossGenreVisual", false))
	if boss_genre_visual:
		trail_length = maxf(trail_length, 24.0)
		trail_color = Color(0.64, 0.05, 0.54, 0.38)
		trail_width = maxf(trail_width, 4.8)
		outer_color = Color("#d93b9f")
		inner_color = Color("#fff0fb")
	if from_player:
		trail_length *= player_visual_scale
		trail_width *= player_visual_scale
		outer_radius *= player_visual_scale
		inner_radius *= player_visual_scale
	target.draw_line(pos - vel * trail_length, pos, trail_color, trail_width)
	target.draw_circle(pos, outer_radius, outer_color)
	target.draw_circle(pos, inner_radius, inner_color)
	if boss_genre_visual:
		var side := Vector2(-vel.y, vel.x)
		var phase := int(abs(int(bullet.get("sourceUid", 0))) + floor(float(bullet.get("life", 0.0)) * 18.0))
		target.draw_arc(pos, outer_radius + 3.0, 0.15, PI * 1.55, 16, Color(1.0, 0.12, 0.72, 0.72), 1.8, true)
		var glitch_a := pos - vel * (8.0 + float(phase % 5)) + side * (outer_radius + 3.0)
		var glitch_b := pos - vel * (14.0 + float(phase % 4)) - side * (outer_radius + 2.0)
		target.draw_line(glitch_a - vel * 4.0, glitch_a + vel * 3.0, Color(0.06, 0.94, 1.0, 0.72), 2.0, true)
		target.draw_line(glitch_b - vel * 3.0, glitch_b + vel * 2.0, Color(0.76, 0.12, 1.0, 0.56), 1.5, true)

static func red_pen_point(pos: Vector2, direction: Vector2, forward: float, side_offset: float) -> Vector2:
	var side := Vector2(-direction.y, direction.x)
	return pos + direction * forward + side * side_offset

static func draw_red_pen_projectile(target: CanvasItem, bullet: Dictionary) -> void:
	if bool(bullet.get("redPenTelegraphPending", false)):
		return
	var pos := Vector2(bullet.get("pos", Vector2.ZERO))
	var raw_vel := Vector2(bullet.get("vel", Vector2.RIGHT))
	var direction := raw_vel.normalized() if raw_vel.length_squared() > 0.01 else Vector2.RIGHT
	var side := Vector2(-direction.y, direction.x)
	var draw_size := clampf(float(bullet.get("redPenDrawSize", RED_PEN_BULLET_DRAW_SIZE)), 36.0, 40.0)
	var scale := draw_size / RED_PEN_BULLET_DRAW_SIZE
	var trail_length := clampf(float(bullet.get("redPenTrailLength", RED_PEN_BULLET_TRAIL_LENGTH)), 20.0, 28.0) * scale
	var phase := float(bullet.get("redPenPhase", bullet.get("phase", 0.0)))
	var shot_index := int(bullet.get("redPenShotIndex", 0))
	var visual_seed := fposmod(phase + float(shot_index) * 1.618, TAU)
	var edge := Color(0.29, 0.005, 0.10, 0.94)
	var shadow := Color(0.47, 0.015, 0.12, 0.90)
	var red := Color(1.0, 0.055, 0.22, 0.98)
	var hot_red := Color(1.0, 0.16, 0.38, 0.96)
	var ink := Color(0.72, 0.012, 0.10, 0.98)
	var white := Color(1.0, 0.93, 0.96, 0.86)
	# The trail is deliberately short and tapered so it reads as ink, not a beam.
	target.draw_line(pos - direction * trail_length, pos - direction * (4.0 * scale), Color(edge.r, edge.g, edge.b, 0.48), 4.6 * scale, true)
	target.draw_line(pos - direction * (trail_length - 1.5 * scale), pos - direction * (5.0 * scale), Color(red.r, red.g, red.b, 0.68), 2.7 * scale, true)
	target.draw_line(pos - direction * (trail_length * 0.76) + side * 1.2 * scale, pos - direction * (trail_length * 0.28) + side * 0.4 * scale, Color(1.0, 0.60, 0.70, 0.34), 0.95 * scale, true)
	for trail_index in range(2):
		var trail_t := 0.30 + float(trail_index) * 0.31
		var trail_pos := pos - direction * trail_length * trail_t + side * sin(visual_seed + float(trail_index) * 2.1) * 1.7 * scale
		target.draw_circle(trail_pos, (1.5 - float(trail_index) * 0.35) * scale, Color(0.67, 0.015, 0.11, 0.34 - float(trail_index) * 0.08))
	# A compact, slightly irregular stroke keeps the main silhouette close to the
	# 36px hit circle without becoming a perfect round bullet.
	var outer_points := PackedVector2Array([
		red_pen_point(pos, direction, 18.0 * scale, 2.0 * scale),
		red_pen_point(pos, direction, 13.0 * scale, 8.2 * scale),
		red_pen_point(pos, direction, -13.0 * scale, 9.0 * scale),
		red_pen_point(pos, direction, -18.0 * scale, 2.8 * scale),
		red_pen_point(pos, direction, -16.0 * scale, -7.1 * scale),
		red_pen_point(pos, direction, 11.0 * scale, -8.0 * scale),
		red_pen_point(pos, direction, 18.0 * scale, -2.2 * scale)
	])
	target.draw_colored_polygon(outer_points, edge)
	var shadow_points := PackedVector2Array([
		red_pen_point(pos, direction, 15.8 * scale, 1.6 * scale),
		red_pen_point(pos, direction, 11.5 * scale, 6.4 * scale),
		red_pen_point(pos, direction, -11.0 * scale, 7.0 * scale),
		red_pen_point(pos, direction, -15.0 * scale, 2.0 * scale),
		red_pen_point(pos, direction, -13.0 * scale, -5.5 * scale),
		red_pen_point(pos, direction, 10.5 * scale, -6.2 * scale),
		red_pen_point(pos, direction, 15.5 * scale, -1.7 * scale)
	])
	target.draw_colored_polygon(shadow_points, shadow)
	var core_points := PackedVector2Array([
		red_pen_point(pos, direction, 14.2 * scale, 1.0 * scale),
		red_pen_point(pos, direction, 10.8 * scale, 4.5 * scale),
		red_pen_point(pos, direction, -10.3 * scale, 5.2 * scale),
		red_pen_point(pos, direction, -13.2 * scale, 1.7 * scale),
		red_pen_point(pos, direction, -11.4 * scale, -4.1 * scale),
		red_pen_point(pos, direction, 9.4 * scale, -4.8 * scale),
		red_pen_point(pos, direction, 14.0 * scale, -1.2 * scale)
	])
	target.draw_colored_polygon(core_points, red)
	var head := red_pen_point(pos, direction, 11.5 * scale, 0.8 * scale)
	target.draw_circle(head, 5.7 * scale, ink)
	target.draw_circle(head - direction * 1.2 * scale, 3.9 * scale, hot_red)
	var highlight_start := red_pen_point(pos, direction, -8.5 * scale, -2.5 * scale)
	var highlight_end := red_pen_point(pos, direction, -0.5 * scale, -2.0 * scale)
	target.draw_line(highlight_start, highlight_end, white, 1.85 * scale, true)
	# Small hook/correction mark; it is intentionally not a check symbol.
	var correction_center := red_pen_point(pos, direction, -1.5 * scale, 0.4 * scale)
	target.draw_arc(correction_center, 9.2 * scale, direction.angle() - 2.35, direction.angle() + 1.45, 12, Color(0.31, 0.0, 0.08, 0.82), 1.8 * scale, true)
	target.draw_arc(correction_center, 5.4 * scale, direction.angle() - 1.92, direction.angle() + 0.92, 10, Color(1.0, 0.22, 0.38, 0.62), 1.0 * scale, true)
	var hook_center := red_pen_point(pos, direction, -4.5 * scale, 6.0 * scale)
	target.draw_arc(hook_center, 4.2 * scale, direction.angle() - 0.92, direction.angle() + 0.82, 10, Color(0.40, 0.005, 0.10, 0.84), 1.65 * scale, true)
	target.draw_arc(hook_center, 2.7 * scale, direction.angle() - 0.78, direction.angle() + 0.54, 8, Color(1.0, 0.38, 0.52, 0.72), 1.0 * scale, true)

static func draw_red_pen_foreground(target: CanvasItem, bullets: Array, visible_rect: Rect2 = Rect2()) -> void:
	var use_culling := visible_rect.size != Vector2.ZERO
	for bullet_item in bullets:
		var bullet: Dictionary = bullet_item as Dictionary
		if String(bullet.get("visualKind", "")) != "red_pen_mark" or not bool(bullet.get("bossProjectile", false)):
			continue
		if bool(bullet.get("redPenTelegraphPending", false)):
			continue
		var pos := Vector2(bullet.get("pos", Vector2.ZERO))
		if use_culling and not visible_rect.has_point(pos):
			continue
		draw_red_pen_projectile(target, bullet)

static func draw_red_pen_player_near_rims(target: CanvasItem, bullets: Array, player_pos: Vector2, visible_rect: Rect2 = Rect2()) -> void:
	var use_culling := visible_rect.size != Vector2.ZERO
	for bullet_item in bullets:
		var bullet: Dictionary = bullet_item as Dictionary
		if String(bullet.get("visualKind", "")) != "red_pen_mark" or not bool(bullet.get("bossProjectile", false)) or bool(bullet.get("redPenTelegraphPending", false)):
			continue
		var pos := Vector2(bullet.get("pos", Vector2.ZERO))
		if use_culling and not visible_rect.has_point(pos):
			continue
		if pos.distance_squared_to(player_pos) > 58.0 * 58.0:
			continue
		var raw_vel := Vector2(bullet.get("vel", Vector2.RIGHT))
		var direction := raw_vel.normalized() if raw_vel.length_squared() > 0.01 else Vector2.RIGHT
		var side := Vector2(-direction.y, direction.x)
		var head := red_pen_point(pos, direction, 11.5, 0.8)
		target.draw_arc(head, 7.3, direction.angle() - 1.22, direction.angle() + 1.10, 12, Color(0.28, 0.0, 0.08, 0.94), 2.7, true)
		target.draw_circle(head, 5.1, Color(0.70, 0.01, 0.10, 0.88), false, 1.7, true)
		target.draw_line(head - direction * 3.8 - side * 1.2, head + direction * 2.4 - side * 0.6, Color(1.0, 0.90, 0.94, 0.82), 1.5, true)

static func travel_comment_visual_rotation(bullet: Dictionary) -> float:
	var seed := float(bullet.get("travelCommentSalvoVisualSeed", 0.0))
	var index := int(bullet.get("travelCommentSalvoIndex", 0))
	var age := maxf(0.0, float(bullet.get("travelCommentSalvoVisualAge", 0.0)))
	var tilt := lerpf(-deg_to_rad(6.0), deg_to_rad(6.0), seed)
	var sway := sin(age * (7.0 + float(index) * 0.45) + seed * TAU) * deg_to_rad(2.5)
	return clampf(tilt + sway, -deg_to_rad(9.0), deg_to_rad(9.0))

static func draw_travel_comment_projectile(target: CanvasItem, bullet: Dictionary, rotated_texture_drawer: Callable = Callable(), texture_loader: Callable = Callable(), alpha: float = 1.0, include_launch_pop: bool = true) -> void:
	var pos := Vector2(bullet.get("pos", Vector2.ZERO))
	var raw_vel := Vector2(bullet.get("vel", Vector2.RIGHT))
	var direction := raw_vel.normalized() if raw_vel.length_squared() > 0.01 else Vector2.RIGHT
	var side := Vector2(-direction.y, direction.x)
	var seed := float(bullet.get("travelCommentSalvoVisualSeed", 0.0))
	var draw_size := clampf(float(bullet.get("travelCommentSalvoDrawSize", TRAVEL_COMMENT_PROJECTILE_DRAW_SIZE)), 38.0, 42.0)
	var trail_length := clampf(float(bullet.get("travelCommentSalvoTrailLength", TRAVEL_COMMENT_PROJECTILE_TRAIL_LENGTH)), 16.0, 20.0)
	var fade := clampf(alpha, 0.0, 1.0)
	# The envelope is the formal 22px gameplay radius, kept deliberately faint
	# so it communicates danger without becoming a second large effect.
	target.draw_arc(pos, TRAVEL_COMMENT_PROJECTILE_HIT_RADIUS, seed * TAU, seed * TAU + PI * 1.72, 18, Color(1.0, 0.86, 0.95, 0.10 * fade), 1.0, true)
	target.draw_line(pos - direction * trail_length, pos - direction * 5.0, Color(0.34, 0.16, 0.42, 0.22 * fade), 3.0, true)
	target.draw_line(pos - direction * (trail_length - 1.5), pos - direction * 6.0, Color(1.0, 0.54, 0.78, 0.30 * fade), 1.25, true)
	var cyan_pos := pos - direction * (trail_length * 0.66) + side * (1.0 + seed * 1.5)
	var magenta_pos := pos - direction * (trail_length * 0.34) - side * (1.0 + seed)
	target.draw_line(cyan_pos - direction * 3.0, cyan_pos + direction * 3.0, Color(0.04, 0.86, 1.0, 0.52 * fade), 1.15, true)
	target.draw_line(magenta_pos - side * 2.5, magenta_pos + side * 2.5, Color(1.0, 0.20, 0.64, 0.46 * fade), 1.0, true)
	if include_launch_pop:
		var launch_duration := maxf(0.01, float(bullet.get("travelCommentSalvoLaunchVisualDuration", 0.16)))
		var launch_left := maxf(0.0, float(bullet.get("travelCommentSalvoLaunchVisualTimer", 0.0)))
		if launch_left > 0.0:
			var launch_ratio := clampf(launch_left / launch_duration, 0.0, 1.0)
			var pop := 1.0 - launch_ratio
			target.draw_arc(pos, 8.0 + pop * 5.0, seed * TAU, seed * TAU + PI * 1.45, 12, Color(1.0, 0.96, 0.99, 0.28 * launch_ratio * fade), 1.2, true)
			target.draw_circle(pos + side * 5.0 - direction * 2.0, 1.3, Color(0.04, 0.86, 1.0, 0.60 * launch_ratio * fade))
			target.draw_circle(pos - side * 5.0, 1.2, Color(1.0, 0.24, 0.66, 0.55 * launch_ratio * fade))
	var texture: Texture2D = COMMENT_SHOTGUN_PROJECTILE_TEXTURE_RESOURCE
	if texture_loader.is_valid():
		var cached_texture := texture_loader.call(COMMENT_SHOTGUN_PROJECTILE_TEXTURE) as Texture2D
		if cached_texture != null:
			texture = cached_texture
	if texture == null:
		texture = ResourceLoader.load(COMMENT_SHOTGUN_PROJECTILE_TEXTURE) as Texture2D
	if texture != null and rotated_texture_drawer.is_valid():
		rotated_texture_drawer.call(texture, pos, Vector2(draw_size, draw_size), travel_comment_visual_rotation(bullet), fade)

static func draw_travel_comment_salvo_launch_foreground(target: CanvasItem, bullets: Array, visible_rect: Rect2 = Rect2(), player_pos: Vector2 = Vector2(INF, INF), rotated_texture_drawer: Callable = Callable(), texture_loader: Callable = Callable()) -> void:
	var use_culling := visible_rect.size != Vector2.ZERO
	for bullet_item in bullets:
		var bullet: Dictionary = bullet_item as Dictionary
		if String(bullet.get("visualKind", "")) != "travel_comment_salvo" or not bool(bullet.get("relayBossProjectile", false)):
			continue
		if float(bullet.get("travelCommentSalvoVisualAge", 0.0)) > float(bullet.get("travelCommentSalvoForegroundDuration", TRAVEL_COMMENT_PROJECTILE_FOREGROUND_DURATION)):
			continue
		if float(bullet.get("travelCommentSalvoLaunchVisualTimer", 0.0)) <= 0.0:
			continue
		var pos := Vector2(bullet.get("pos", Vector2.ZERO))
		if pos.distance_squared_to(player_pos) <= 96.0 * 96.0:
			continue
		if use_culling and not visible_rect.grow(28.0).has_point(pos):
			continue
		draw_travel_comment_projectile(target, bullet, rotated_texture_drawer, texture_loader, 0.96, false)

static func draw_travel_comment_player_near_rims(target: CanvasItem, bullets: Array, player_pos: Vector2, visible_rect: Rect2 = Rect2()) -> void:
	var use_culling := visible_rect.size != Vector2.ZERO
	for bullet_item in bullets:
		var bullet: Dictionary = bullet_item as Dictionary
		if String(bullet.get("visualKind", "")) != "travel_comment_salvo" or not bool(bullet.get("relayBossProjectile", false)):
			continue
		var pos := Vector2(bullet.get("pos", Vector2.ZERO))
		if pos.distance_squared_to(player_pos) > 96.0 * 96.0:
			continue
		if use_culling and not visible_rect.grow(28.0).has_point(pos):
			continue
		var raw_vel := Vector2(bullet.get("vel", Vector2.RIGHT))
		var direction := raw_vel.normalized() if raw_vel.length_squared() > 0.01 else Vector2.RIGHT
		var side := Vector2(-direction.y, direction.x)
		var seed := float(bullet.get("travelCommentSalvoVisualSeed", 0.0))
		# Near the player, preserve only the silhouette fringe and glitch offsets;
		# the full bubble remains suppressed to keep the player readable.
		target.draw_arc(pos, TRAVEL_COMMENT_PROJECTILE_HIT_RADIUS, direction.angle() - 2.25, direction.angle() - 0.56, 10, Color(0.27, 0.02, 0.25, 0.72), 1.8, true)
		target.draw_arc(pos, TRAVEL_COMMENT_PROJECTILE_HIT_RADIUS - 2.0, direction.angle() + 0.62, direction.angle() + 1.55, 6, Color(1.0, 0.82, 0.92, 0.46), 1.0, true)
		var cyan_center := pos - direction * 4.0 + side * (6.0 + seed * 2.0)
		var magenta_center := pos + direction * 2.0 - side * (5.0 + seed)
		target.draw_line(cyan_center - direction * 4.0, cyan_center + direction * 3.0, Color(0.04, 0.88, 1.0, 0.76), 1.8, true)
		target.draw_line(magenta_center - side * 3.0, magenta_center + side * 3.0, Color(1.0, 0.20, 0.64, 0.70), 1.5, true)

static func _is_travel_noise_shot_bullet(bullet: Dictionary) -> bool:
	return String(bullet.get("sourceKind", "")) == "travel_noise_shot" \
		or String(bullet.get("visualKind", "")) == "travel_noise_shot"

static func _travel_noise_shot_point(pos: Vector2, direction: Vector2, side: Vector2, forward: float, lateral: float, scale: float) -> Vector2:
	return pos + direction * forward * scale + side * lateral * scale

static func _travel_noise_shot_body_points(pos: Vector2, direction: Vector2, side: Vector2, scale: float, seed: float) -> PackedVector2Array:
	var skew := (seed - 0.5) * 2.0
	return PackedVector2Array([
		_travel_noise_shot_point(pos, direction, side, 18.0 + skew * 0.8, 0.0, scale),
		_travel_noise_shot_point(pos, direction, side, 11.0, 10.2 + skew * 0.8, scale),
		_travel_noise_shot_point(pos, direction, side, 1.2, 16.8, scale),
		_travel_noise_shot_point(pos, direction, side, -8.8, 12.0 - skew * 0.7, scale),
		_travel_noise_shot_point(pos, direction, side, -18.0, 2.8, scale),
		_travel_noise_shot_point(pos, direction, side, -13.0, -11.2, scale),
		_travel_noise_shot_point(pos, direction, side, -1.0, -16.2, scale),
		_travel_noise_shot_point(pos, direction, side, 11.8, -9.2 - skew * 0.6, scale),
		_travel_noise_shot_point(pos, direction, side, 18.0 + skew * 0.8, 0.0, scale)
	])

static func _travel_noise_shot_inner_points(pos: Vector2, direction: Vector2, side: Vector2, scale: float, seed: float) -> PackedVector2Array:
	var skew := (seed - 0.5) * 1.4
	return PackedVector2Array([
		_travel_noise_shot_point(pos, direction, side, 13.2 + skew, 0.0, scale),
		_travel_noise_shot_point(pos, direction, side, 8.5, 7.2 + skew, scale),
		_travel_noise_shot_point(pos, direction, side, 1.0, 11.5, scale),
		_travel_noise_shot_point(pos, direction, side, -7.0, 8.5, scale),
		_travel_noise_shot_point(pos, direction, side, -13.0, 2.0, scale),
		_travel_noise_shot_point(pos, direction, side, -9.2, -7.6, scale),
		_travel_noise_shot_point(pos, direction, side, 0.0, -11.0, scale),
		_travel_noise_shot_point(pos, direction, side, 8.8, -6.8, scale),
		_travel_noise_shot_point(pos, direction, side, 13.2 + skew, 0.0, scale)
	])

static func _draw_travel_noise_shot_static_block(target: CanvasItem, center: Vector2, direction: Vector2, side: Vector2, width: float, height: float, color: Color) -> void:
	var half_width := width * 0.5
	var half_height := height * 0.5
	target.draw_colored_polygon(PackedVector2Array([
		center - direction * half_width - side * half_height,
		center + direction * half_width - side * half_height,
		center + direction * half_width + side * half_height,
		center - direction * half_width + side * half_height
	]), color)

static func draw_travel_noise_shot_projectile(target: CanvasItem, bullet: Dictionary, alpha: float = 1.0, trail_length_override: float = -1.0, include_trail: bool = true) -> void:
	var pos := Vector2(bullet.get("pos", Vector2.ZERO))
	var raw_vel := Vector2(bullet.get("vel", Vector2.RIGHT))
	var direction := raw_vel.normalized() if raw_vel.length_squared() > 0.01 else Vector2.RIGHT
	var side := Vector2(-direction.y, direction.x)
	var seed := fposmod(float(bullet.get("travelNoiseShotVisualSeed", 0.0)), 1.0)
	var age := maxf(0.0, float(bullet.get("travelNoiseShotVisualAge", 0.0)))
	var draw_size := clampf(float(bullet.get("travelNoiseShotDrawSize", TRAVEL_NOISE_SHOT_DRAW_SIZE)), 38.0, 42.0)
	var scale := draw_size / TRAVEL_NOISE_SHOT_DRAW_SIZE
	var fade := clampf(alpha, 0.0, 1.0)
	var pulse := 0.93 + 0.07 * sin(age * 13.0 + seed * TAU)
	var direction_angle := direction.angle()
	if include_trail:
		var trail_length := TRAVEL_NOISE_SHOT_TRAIL_LENGTH if trail_length_override < 0.0 else trail_length_override
		trail_length = clampf(trail_length, 3.0, 18.0) * scale
		var trail_end := minf(5.0 * scale, trail_length * 0.58)
		target.draw_line(pos - direction * trail_length, pos - direction * trail_end, Color(0.10, 0.015, 0.16, 0.32 * fade), 3.0 * scale, true)
		target.draw_line(pos - direction * (trail_length - 1.0 * scale) + side * 1.1 * scale, pos - direction * (trail_end + 0.8 * scale) + side * 0.7 * scale, Color(0.05, 0.82, 1.0, 0.56 * fade), 1.15 * scale, true)
		target.draw_line(pos - direction * (trail_length * 0.78) - side * 1.4 * scale, pos - direction * (trail_length * 0.28) - side * 0.6 * scale, Color(1.0, 0.20, 0.64, 0.48 * fade), 1.0 * scale, true)
		target.draw_line(pos - direction * (trail_length * 0.74) + side * 0.3 * scale, pos - direction * (trail_length * 0.42) + side * 0.8 * scale, Color(0.78, 0.82, 0.86, 0.58 * fade), 0.8 * scale, true)
		for trail_index in range(3):
			var trail_t := 0.24 + float(trail_index) * 0.29
			var block_center := pos - direction * trail_length * trail_t + side * sin(seed * TAU + float(trail_index) * 2.17) * 2.0 * scale
			var block_color := Color(0.04, 0.84, 1.0, (0.62 - float(trail_index) * 0.10) * fade) if trail_index % 2 == 0 else Color(1.0, 0.20, 0.64, (0.56 - float(trail_index) * 0.08) * fade)
			_draw_travel_noise_shot_static_block(target, block_center, direction, side, (3.2 - float(trail_index) * 0.45) * scale, (1.8 - float(trail_index) * 0.20) * scale, block_color)
	# The ring is intentionally incomplete: this reads as broken broadcast
	# hardware rather than a clean circle or the round noise-summon enemy.
	target.draw_arc(pos, 19.0 * scale, direction_angle - 2.22 + seed * 0.18, direction_angle - 0.72 + seed * 0.18, 9, Color(0.04, 0.84, 1.0, 0.70 * fade), 1.7 * scale, true)
	target.draw_arc(pos, 19.0 * scale, direction_angle + 0.18 + seed * 0.14, direction_angle + 1.42 + seed * 0.14, 8, Color(1.0, 0.20, 0.64, 0.72 * fade), 1.6 * scale, true)
	target.draw_arc(pos, 19.0 * scale, direction_angle + 2.20, direction_angle + 2.78, 5, Color(0.18, 0.05, 0.24, 0.86 * fade), 1.8 * scale, true)
	var outer_points := _travel_noise_shot_body_points(pos, direction, side, scale, seed)
	target.draw_colored_polygon(outer_points, Color(0.12, 0.015, 0.18, 0.98 * fade))
	target.draw_polyline(outer_points, Color(0.30, 0.08, 0.36, 0.96 * fade), 1.7 * scale, true)
	var inner_points := _travel_noise_shot_inner_points(pos, direction, side, scale, seed)
	target.draw_colored_polygon(inner_points, Color(0.82, 0.84, 0.84, 0.97 * fade))
	target.draw_polyline(inner_points, Color(1.0, 0.96, 0.94, 0.82 * fade), 1.05 * scale, true)
	# A missing dark-plum chunk breaks the otherwise pale core.
	target.draw_colored_polygon(PackedVector2Array([
		_travel_noise_shot_point(pos, direction, side, 2.0, 7.2, scale),
		_travel_noise_shot_point(pos, direction, side, 12.0, 8.0, scale),
		_travel_noise_shot_point(pos, direction, side, 7.0, 13.5, scale),
		_travel_noise_shot_point(pos, direction, side, -0.5, 10.0, scale)
	]), Color(0.12, 0.015, 0.18, 0.96 * fade))
	# Chromatic split is a physical seam in the icon, not a long projectile beam.
	target.draw_line(_travel_noise_shot_point(pos, direction, side, -8.0, -2.0, scale), _travel_noise_shot_point(pos, direction, side, 2.0, -2.0, scale), Color(0.04, 0.86, 1.0, 0.88 * fade), 1.8 * scale, true)
	target.draw_line(_travel_noise_shot_point(pos, direction, side, 2.0, 2.2, scale), _travel_noise_shot_point(pos, direction, side, 11.0, 3.0, scale), Color(1.0, 0.22, 0.66, 0.86 * fade), 1.7 * scale, true)
	target.draw_circle(pos - direction * 2.0 * scale - side * 1.4 * scale, 4.5 * scale, Color(1.0, 0.98, 0.91, 0.92 * fade))
	target.draw_line(pos - direction * 5.0 * scale - side * 3.0 * scale, pos + direction * 5.0 * scale + side * 3.0 * scale, Color(1.0, 1.0, 0.96, 0.46 * fade), 0.9 * scale, true)
	var notch_centers := [
		_travel_noise_shot_point(pos, direction, side, -8.5, 10.8, scale),
		_travel_noise_shot_point(pos, direction, side, 10.8, -9.8, scale),
		_travel_noise_shot_point(pos, direction, side, -1.0, -15.2, scale)
	]
	for notch_index in range(notch_centers.size()):
		var notch_color := Color(0.04, 0.84, 1.0, 0.86 * fade) if notch_index == 0 else (Color(1.0, 0.20, 0.64, 0.82 * fade) if notch_index == 1 else Color(0.12, 0.015, 0.18, 0.94 * fade))
		_draw_travel_noise_shot_static_block(target, notch_centers[notch_index], direction, side, (3.8 if notch_index < 2 else 3.0) * scale, (2.2 if notch_index < 2 else 1.8) * scale, notch_color)

static func _travel_noise_shot_overlaps_boss_opaque(pos: Vector2, boss: Dictionary) -> bool:
	var boss_center := Vector2(boss.get("pos", Vector2.ZERO)) + Vector2(boss.get("visualOffset", Vector2.ZERO))
	var opaque_size := Vector2(boss.get("visualOpaqueSize", Vector2(500.0, 450.0)))
	var scale_vector := Vector2(boss.get("visualScaleVector", Vector2.ONE))
	var half_size := Vector2(absf(opaque_size.x * scale_vector.x), absf(opaque_size.y * scale_vector.y)) * 0.5
	if half_size.x <= 1.0 or half_size.y <= 1.0:
		return false
	var local := (pos - boss_center).rotated(-float(boss.get("visualRotation", 0.0)))
	var nearest := Vector2(clampf(local.x, -half_size.x, half_size.x), clampf(local.y, -half_size.y, half_size.y))
	var projectile_radius := clampf(float(boss.get("travelNoiseShotOcclusionRadius", 20.0)), 16.0, 22.0)
	return local.distance_squared_to(nearest) <= projectile_radius * projectile_radius

static func draw_travel_noise_shot_boss_foreground(target: CanvasItem, bullets: Array, boss: Dictionary, visible_rect: Rect2 = Rect2()) -> void:
	if boss.is_empty():
		return
	var use_culling := visible_rect.size != Vector2.ZERO
	for bullet_item in bullets:
		var bullet: Dictionary = bullet_item as Dictionary
		if not _is_travel_noise_shot_bullet(bullet):
			continue
		if float(bullet.get("life", 0.0)) <= 0.0:
			continue
		var age := maxf(0.0, float(bullet.get("travelNoiseShotVisualAge", 0.0)))
		if age > float(bullet.get("travelNoiseShotForegroundDuration", TRAVEL_NOISE_SHOT_FOREGROUND_DURATION)):
			continue
		var pos := Vector2(bullet.get("pos", Vector2.ZERO))
		if not _travel_noise_shot_overlaps_boss_opaque(pos, boss):
			continue
		if use_culling and not visible_rect.grow(28.0).has_point(pos):
			continue
		# Only the body/fringe and a tiny trail root are redrawn over the boss.
		draw_travel_noise_shot_projectile(target, bullet, 0.98, 4.5, true)

static func draw_travel_noise_shot_player_near_rims(target: CanvasItem, bullets: Array, player_pos: Vector2, visible_rect: Rect2 = Rect2()) -> void:
	var use_culling := visible_rect.size != Vector2.ZERO
	for bullet_item in bullets:
		var bullet: Dictionary = bullet_item as Dictionary
		if not _is_travel_noise_shot_bullet(bullet) or float(bullet.get("life", 0.0)) <= 0.0:
			continue
		var pos := Vector2(bullet.get("pos", Vector2.ZERO))
		if pos.distance_squared_to(player_pos) > 96.0 * 96.0:
			continue
		if use_culling and not visible_rect.grow(28.0).has_point(pos):
			continue
		var raw_vel := Vector2(bullet.get("vel", Vector2.RIGHT))
		var direction := raw_vel.normalized() if raw_vel.length_squared() > 0.01 else Vector2.RIGHT
		var seed := fposmod(float(bullet.get("travelNoiseShotVisualSeed", 0.0)), 1.0)
		var radius := clampf(float(bullet.get("hitRadius", TRAVEL_NOISE_SHOT_HIT_RADIUS)), 18.0, 22.0)
		var angle := direction.angle()
		# Near the player, retain only a formal split rim and a few notches.  The
		# full 40px icon and its trail remain behind the player silhouette.
		target.draw_arc(pos, radius, angle - 2.34 + seed * 0.12, angle - 0.82 + seed * 0.12, 9, Color(0.10, 0.02, 0.20, 0.86), 1.9, true)
		target.draw_arc(pos, radius - 1.5, angle + 0.14, angle + 1.26, 7, Color(0.04, 0.86, 1.0, 0.86), 1.45, true)
		target.draw_arc(pos, radius - 0.5, angle + 1.42, angle + 2.30, 6, Color(1.0, 0.20, 0.64, 0.82), 1.35, true)
		var side := Vector2(-direction.y, direction.x)
		target.draw_line(pos - direction * 2.0 - side * 8.0, pos + direction * 2.0 - side * 3.0, Color(0.04, 0.86, 1.0, 0.74), 1.25, true)
		target.draw_line(pos - direction * 1.0 + side * 3.0, pos + direction * 3.0 + side * 8.0, Color(1.0, 0.20, 0.64, 0.72), 1.15, true)
		var notch_center := pos + direction * (radius * 0.72) + side * (4.0 + seed * 2.0)
		_draw_travel_noise_shot_static_block(target, notch_center, direction, side, 3.8, 2.0, Color(0.12, 0.015, 0.18, 0.90))

static func comment_shotgun_visual_rotation(bullet: Dictionary) -> float:
	var seed := float(bullet.get("commentShotgunVisualSeed", 0.0))
	var index := int(bullet.get("commentShotgunIndex", 0))
	var tilt := lerpf(-deg_to_rad(8.0), deg_to_rad(8.0), seed)
	var age := maxf(0.0, 4.0 - float(bullet.get("life", 4.0)))
	var frequency := 1.6 + fposmod(seed * 11.0 + float(index) * 0.17, 1.0) * 0.4
	var sway_phase := seed * TAU + float(index) * 0.37
	var sway := sin(age * TAU * frequency + sway_phase) * deg_to_rad(4.0)
	return clampf(tilt + sway, -deg_to_rad(12.0), deg_to_rad(12.0))

static func draw_comment_shotgun_projectile(target: CanvasItem, bullet: Dictionary, rotated_texture_drawer: Callable = Callable(), texture_loader: Callable = Callable(), alpha: float = 1.0, include_launch_pop: bool = true) -> void:
	var pos := Vector2(bullet.get("pos", Vector2.ZERO))
	var raw_vel := Vector2(bullet.get("vel", Vector2.RIGHT))
	var direction := raw_vel.normalized() if raw_vel.length_squared() > 0.01 else Vector2.RIGHT
	var side := Vector2(-direction.y, direction.x)
	var seed := float(bullet.get("commentShotgunVisualSeed", 0.0))
	var trail_length := clampf(float(bullet.get("commentShotgunTrailLength", COMMENT_SHOTGUN_PROJECTILE_TRAIL_LENGTH)), 18.0, 24.0)
	var draw_size := clampf(float(bullet.get("commentShotgunDrawSize", COMMENT_SHOTGUN_PROJECTILE_DRAW_SIZE)), 36.0, 42.0)
	var scale := draw_size / COMMENT_SHOTGUN_PROJECTILE_DRAW_SIZE
	var trail_fade := clampf(alpha, 0.0, 1.0)
	# The afterimage is short and tapered: it should read as a comment passing by,
	# never as a beam or flame.
	target.draw_line(pos - direction * trail_length, pos - direction * 5.0, Color(0.46, 0.20, 0.55, 0.18 * trail_fade), 3.4 * scale, true)
	target.draw_line(pos - direction * (trail_length - 2.0), pos - direction * 6.0, Color(1.0, 0.48, 0.75, 0.30 * trail_fade), 1.55 * scale, true)
	var cyan_start := pos - direction * (trail_length * 0.82) + side * (1.5 + seed * 2.0)
	var cyan_end := pos - direction * (trail_length * 0.42) + side * (2.5 + seed * 1.5)
	target.draw_line(cyan_start, cyan_end, Color(0.08, 0.86, 1.0, 0.46 * trail_fade), 1.15 * scale, true)
	var afterimage_pos := pos - direction * (trail_length * 0.72) - side * (1.0 + seed * 2.0)
	target.draw_circle(afterimage_pos, 1.8 * scale, Color(1.0, 0.94, 0.98, 0.42 * trail_fade))
	var fragment_a := pos - direction * (trail_length * 0.50) + side * 3.8
	var fragment_b := pos - direction * (trail_length * 0.24) - side * 3.0
	target.draw_rect(Rect2(fragment_a - Vector2(2.0, 1.0), Vector2(4.0, 2.0)), Color(0.08, 0.82, 1.0, 0.40 * trail_fade), true)
	target.draw_rect(Rect2(fragment_b - Vector2(1.5, 1.0), Vector2(3.0, 2.0)), Color(1.0, 0.22, 0.62, 0.44 * trail_fade), true)
	if include_launch_pop:
		var launch_duration := maxf(0.01, float(bullet.get("commentShotgunLaunchVisualDuration", 0.12)))
		var launch_left := maxf(0.0, float(bullet.get("commentShotgunLaunchVisualTimer", 0.0)))
		if launch_left > 0.0:
			var launch_ratio := clampf(launch_left / launch_duration, 0.0, 1.0)
			var pop := 1.0 - launch_ratio
			target.draw_arc(pos, (8.0 + pop * 4.0) * scale, seed * TAU, seed * TAU + PI * 1.45, 10, Color(1.0, 0.94, 0.98, 0.36 * launch_ratio * trail_fade), 1.3 * scale, true)
			target.draw_circle(pos + side * 5.0 - direction * 3.0, 1.4 * scale, Color(0.06, 0.84, 1.0, 0.58 * launch_ratio * trail_fade))
			target.draw_circle(pos - side * 5.0 - direction * 1.0, 1.3 * scale, Color(1.0, 0.30, 0.68, 0.54 * launch_ratio * trail_fade))
	var texture: Texture2D = COMMENT_SHOTGUN_PROJECTILE_TEXTURE_RESOURCE
	if texture_loader.is_valid():
		var cached_texture := texture_loader.call(COMMENT_SHOTGUN_PROJECTILE_TEXTURE) as Texture2D
		if cached_texture != null:
			texture = cached_texture
	if texture == null:
		texture = ResourceLoader.load(COMMENT_SHOTGUN_PROJECTILE_TEXTURE) as Texture2D
	if texture == null or not rotated_texture_drawer.is_valid():
		return
	rotated_texture_drawer.call(texture, pos, Vector2(draw_size, draw_size), comment_shotgun_visual_rotation(bullet), clampf(alpha, 0.0, 1.0))

static func draw_comment_shotgun_launch_foreground(target: CanvasItem, bullets: Array, visible_rect: Rect2 = Rect2(), rotated_texture_drawer: Callable = Callable(), texture_loader: Callable = Callable()) -> void:
	var use_culling := visible_rect.size != Vector2.ZERO
	for bullet_item in bullets:
		var bullet: Dictionary = bullet_item as Dictionary
		if String(bullet.get("visualKind", "")) != "comment_shotgun":
			continue
		if float(bullet.get("commentShotgunLaunchVisualTimer", 0.0)) <= 0.0:
			continue
		var pos := Vector2(bullet.get("pos", Vector2.ZERO))
		if use_culling and not visible_rect.has_point(pos):
			continue
		# During the muzzle window the full silhouette is lifted above the boss;
		# later frames use only the player-near rim pass below.
		draw_comment_shotgun_projectile(target, bullet, rotated_texture_drawer, texture_loader, 0.92, false)

static func draw_comment_shotgun_player_near_rims(target: CanvasItem, bullets: Array, player_pos: Vector2, visible_rect: Rect2 = Rect2()) -> void:
	var use_culling := visible_rect.size != Vector2.ZERO
	for bullet_item in bullets:
		var bullet: Dictionary = bullet_item as Dictionary
		if String(bullet.get("visualKind", "")) != "comment_shotgun":
			continue
		var pos := Vector2(bullet.get("pos", Vector2.ZERO))
		if use_culling and not visible_rect.has_point(pos):
			continue
		if pos.distance_squared_to(player_pos) > 112.0 * 112.0:
			continue
		var raw_vel := Vector2(bullet.get("vel", Vector2.RIGHT))
		var direction := raw_vel.normalized() if raw_vel.length_squared() > 0.01 else Vector2.RIGHT
		var side := Vector2(-direction.y, direction.x)
		var draw_size := clampf(float(bullet.get("commentShotgunDrawSize", COMMENT_SHOTGUN_PROJECTILE_DRAW_SIZE)), 36.0, 42.0)
		var rotation := comment_shotgun_visual_rotation(bullet)
		var edge_center := pos + side * 2.0
		target.draw_arc(edge_center, draw_size * 0.40, rotation - 2.25, rotation - 0.70, 8, Color(0.27, 0.02, 0.25, 0.70), 2.0, true)
		var glitch_center := pos - direction * (draw_size * 0.18) + side * (draw_size * 0.30)
		target.draw_line(glitch_center - direction * 4.0, glitch_center + direction * 3.0, Color(0.04, 0.88, 1.0, 0.72), 1.8, true)
		target.draw_line(pos - side * (draw_size * 0.36) - direction * 2.0, pos - side * (draw_size * 0.36) + direction * 4.0, Color(1.0, 0.18, 0.60, 0.66), 1.6, true)

static func draw_bug_spoiler_projectile(target: CanvasItem, bullet: Dictionary, rotated_texture_drawer: Callable = Callable(), texture_loader: Callable = Callable()) -> void:
	var pos := Vector2(bullet.get("pos", Vector2.ZERO))
	var raw_vel := Vector2(bullet.get("vel", Vector2.RIGHT))
	var dir := raw_vel.normalized() if raw_vel.length_squared() > 0.01 else Vector2.RIGHT
	var side := Vector2(-dir.y, dir.x)
	var trail_end := pos - dir * 7.0
	target.draw_line(pos - dir * 28.0, trail_end, Color(0.17, 0.01, 0.12, 0.48), 5.4, true)
	target.draw_line(pos - dir * 26.0, trail_end, Color(1.0, 0.06, 0.42, 0.46), 3.2, true)
	target.draw_line(pos - dir * 17.0, trail_end, Color(1.0, 0.91, 0.95, 0.66), 1.2, true)
	var glitch_a := pos - dir * 20.0 + side * 5.0
	var glitch_b := pos - dir * 13.0 - side * 5.5
	target.draw_line(glitch_a - dir * 3.5, glitch_a + dir * 2.5, Color(0.0, 0.94, 1.0, 0.70), 2.0, true)
	target.draw_line(glitch_b - side * 2.5, glitch_b + side * 2.0, Color(0.64, 0.12, 1.0, 0.52), 1.6, true)
	var texture: Texture2D = null
	if texture_loader.is_valid():
		texture = texture_loader.call(BUG_SPOILER_PROJECTILE_TEXTURE) as Texture2D
	if texture == null:
		texture = ResourceLoader.load(BUG_SPOILER_PROJECTILE_TEXTURE) as Texture2D
	if texture == null or not rotated_texture_drawer.is_valid():
		return
	var draw_size := clampf(float(bullet.get("bugSpoilerDrawSize", BUG_SPOILER_PROJECTILE_DRAW_SIZE)), 32.0, 52.0)
	var rotation_mode := String(bullet.get("bugSpoilerRotationMode", "folded"))
	var rotation := bug_spoiler_visual_rotation(dir, rotation_mode)
	rotated_texture_drawer.call(texture, pos, Vector2(draw_size, draw_size), rotation, 1.0)

static func bug_spoiler_visual_rotation(direction: Vector2, mode: String = "folded") -> float:
	var dir := direction.normalized() if direction.length_squared() > 0.01 else Vector2.RIGHT
	if mode == "velocity":
		return dir.angle()
	if mode == "fixed":
		return 0.0
	var folded := fposmod(dir.angle() + PI * 0.5, PI) - PI * 0.5
	return clampf(folded, -BUG_SPOILER_PROJECTILE_ROTATION_LIMIT, BUG_SPOILER_PROJECTILE_ROTATION_LIMIT)

static func draw_kuso_maro_projectile(target: CanvasItem, bullet: Dictionary, rotated_texture_drawer: Callable = Callable(), texture_loader: Callable = Callable()) -> void:
	var pos := Vector2(bullet.get("pos", Vector2.ZERO))
	var raw_vel := Vector2(bullet.get("vel", Vector2.RIGHT))
	var dir := raw_vel.normalized() if raw_vel.length_squared() > 0.01 else Vector2.RIGHT
	var side := Vector2(-dir.y, dir.x)
	var trail_end := pos - dir * 7.0
	target.draw_line(pos - dir * 26.0, trail_end, Color(0.55, 0.31, 0.67, 0.20), 5.2, true)
	target.draw_line(pos - dir * 23.0, trail_end, Color(0.98, 0.55, 0.78, 0.27), 3.0, true)
	target.draw_line(pos - dir * 19.0, trail_end, Color(1.0, 0.96, 0.98, 0.34), 1.2, true)
	target.draw_circle(pos - dir * 22.0 + side * 3.6, 1.7, Color(0.91, 0.66, 0.88, 0.34))
	target.draw_circle(pos - dir * 27.0 - side * 2.4, 1.1, Color(1.0, 0.94, 0.97, 0.38))
	var texture: Texture2D = null
	if texture_loader.is_valid():
		texture = texture_loader.call(KUSO_MARO_PROJECTILE_TEXTURE) as Texture2D
	if texture == null:
		texture = ResourceLoader.load(KUSO_MARO_PROJECTILE_TEXTURE) as Texture2D
	if texture != null and rotated_texture_drawer.is_valid():
		var rotation := float(bullet.get("visualRotation", 0.0))
		rotated_texture_drawer.call(texture, pos, KUSO_MARO_PROJECTILE_DRAW_SIZE, rotation, 1.0)

static func draw_kuso_maro_foreground_rims(target: CanvasItem, bullets: Array, player_pos: Vector2, rotated_texture_drawer: Callable = Callable(), texture_loader: Callable = Callable(), visible_rect: Rect2 = Rect2()) -> void:
	var use_culling := visible_rect.size != Vector2.ZERO
	var texture: Texture2D = null
	for bullet_item in bullets:
		var bullet: Dictionary = bullet_item as Dictionary
		if String(bullet.get("visualKind", "")) != "kuso_maro":
			continue
		var pos := Vector2(bullet.get("pos", Vector2.ZERO))
		if use_culling and not visible_rect.has_point(pos):
			continue
		if pos.distance_squared_to(player_pos) > 52.0 * 52.0:
			continue
		if texture == null and texture_loader.is_valid():
			texture = texture_loader.call(KUSO_MARO_PROJECTILE_TEXTURE) as Texture2D
		if texture == null:
			texture = ResourceLoader.load(KUSO_MARO_PROJECTILE_TEXTURE) as Texture2D
		if texture != null and rotated_texture_drawer.is_valid():
			var rotation := float(bullet.get("visualRotation", 0.0))
			rotated_texture_drawer.call(texture, pos, KUSO_MARO_PROJECTILE_DRAW_SIZE, rotation, 0.34)

static func draw_pitch_police_note_projectile(target: CanvasItem, bullet: Dictionary) -> void:
	var draw_items: Array = DrawDataSystemScript.bullet_draw_data([bullet], false)
	if draw_items.is_empty():
		return
	var item: Dictionary = draw_items[0] as Dictionary
	draw_bullet_item(target, item)
	draw_pitch_police_note_body(target, item, 1.0)

static func pitch_police_note_visual_rotation(direction: Vector2, mode: String, life: float, seed: float) -> float:
	var dir := direction.normalized() if direction.length_squared() > 0.01 else Vector2.RIGHT
	if mode == "velocity":
		return dir.angle()
	if mode == "fixed":
		return sin(life * 13.0 + seed) * deg_to_rad(5.0)
	var folded := fposmod(dir.angle() + PI * 0.5, PI) - PI * 0.5
	return clampf(folded, -PITCH_POLICE_NOTE_ROTATION_LIMIT, PITCH_POLICE_NOTE_ROTATION_LIMIT)

static func pitch_police_note_point(pos: Vector2, local_point: Vector2, rotation: float, scale: float) -> Vector2:
	return pos + (local_point * scale).rotated(rotation)

static func draw_pitch_police_note_body(target: CanvasItem, item: Dictionary, alpha: float = 1.0) -> void:
	var pos := Vector2(item.get("pos", Vector2.ZERO))
	var direction := Vector2(item.get("pitchDirection", Vector2.RIGHT))
	var draw_size := clampf(float(item.get("pitchNoteDrawSize", PITCH_POLICE_NOTE_DRAW_SIZE)), 34.0, 44.0)
	var scale := draw_size / PITCH_POLICE_NOTE_DRAW_SIZE
	var phase := clampi(int(item.get("pitchChiefPhase", 1)), 1, 3)
	var rotation := pitch_police_note_visual_rotation(direction, String(item.get("pitchNoteRotationMode", "folded")), float(item.get("pitchNoteLife", 0.0)), float(item.get("pitchNoteSeed", 0.0)))
	var dark := Color(0.25, 0.01, 0.12, 0.94 * alpha)
	var red := Color(1.0, 0.035, 0.30 + float(phase - 1) * 0.035, 0.98 * alpha)
	var hot_pink := Color(1.0, 0.16, 0.50, 0.98 * alpha)
	var white := Color(1.0, 0.96, 0.99, 0.98 * alpha)
	var aura_alpha := (0.30 + float(phase - 1) * 0.055) * alpha
	target.draw_arc(pos, 19.0 * scale, rotation - 2.72, rotation - 0.72, 14, Color(1.0, 0.08, 0.42, aura_alpha), 2.2 * scale, true)
	target.draw_arc(pos, 19.0 * scale, rotation + 0.42, rotation + 2.10, 12, Color(1.0, 0.64, 0.82, aura_alpha * 0.72), 1.4 * scale, true)
	var head := pitch_police_note_point(pos, Vector2(-8.3, 6.4), rotation, scale)
	var stem_bottom := pitch_police_note_point(pos, Vector2(-3.0, 5.0), rotation, scale)
	var stem_top := pitch_police_note_point(pos, Vector2(-3.0, -12.5), rotation, scale)
	target.draw_circle(head, 7.9 * scale, dark)
	target.draw_circle(head, 5.8 * scale, red)
	target.draw_line(stem_bottom, stem_top, dark, 7.0 * scale, true)
	target.draw_line(stem_bottom, stem_top, hot_pink, 4.1 * scale, true)
	var flag_outer := PackedVector2Array([
		pitch_police_note_point(pos, Vector2(-4.8, -14.0), rotation, scale),
		pitch_police_note_point(pos, Vector2(8.0, -10.8), rotation, scale),
		pitch_police_note_point(pos, Vector2(9.4, -3.5), rotation, scale),
		pitch_police_note_point(pos, Vector2(3.6, -7.0), rotation, scale),
		pitch_police_note_point(pos, Vector2(-4.2, -8.0), rotation, scale)
	])
	target.draw_colored_polygon(flag_outer, dark)
	var flag_inner := PackedVector2Array([
		pitch_police_note_point(pos, Vector2(-2.9, -11.8), rotation, scale),
		pitch_police_note_point(pos, Vector2(6.0, -9.3), rotation, scale),
		pitch_police_note_point(pos, Vector2(7.1, -6.0), rotation, scale),
		pitch_police_note_point(pos, Vector2(3.0, -8.0), rotation, scale),
		pitch_police_note_point(pos, Vector2(-2.9, -9.0), rotation, scale)
	])
	target.draw_colored_polygon(flag_inner, red)
	var check_a := pitch_police_note_point(pos, Vector2(0.0, 2.0), rotation, scale)
	var check_b := pitch_police_note_point(pos, Vector2(5.0, 8.0), rotation, scale)
	var check_c := pitch_police_note_point(pos, Vector2(15.0, -7.0), rotation, scale)
	target.draw_line(check_a, check_b, dark, 8.0 * scale, true)
	target.draw_line(check_b, check_c, dark, 8.0 * scale, true)
	target.draw_line(check_a, check_b, hot_pink, 4.8 * scale, true)
	target.draw_line(check_b, check_c, hot_pink, 4.8 * scale, true)
	var highlight_a := pitch_police_note_point(pos, Vector2(-10.2, 2.8), rotation, scale)
	var highlight_b := pitch_police_note_point(pos, Vector2(-6.7, 1.0), rotation, scale)
	target.draw_line(highlight_a, highlight_b, white, 1.5 * scale, true)
	var check_highlight_a := pitch_police_note_point(pos, Vector2(6.6, 5.3), rotation, scale)
	var check_highlight_b := pitch_police_note_point(pos, Vector2(12.8, -4.7), rotation, scale)
	target.draw_line(check_highlight_a, check_highlight_b, white, 1.45 * scale, true)

static func draw_pitch_police_note_foreground_rims(target: CanvasItem, bullets: Array, player_pos: Vector2, visible_rect: Rect2 = Rect2()) -> void:
	var use_culling := visible_rect.size != Vector2.ZERO
	for bullet_item in bullets:
		var bullet: Dictionary = bullet_item as Dictionary
		if String(bullet.get("visualKind", "")) != "pitch_police_note":
			continue
		var pos := Vector2(bullet.get("pos", Vector2.ZERO))
		if use_culling and not visible_rect.has_point(pos):
			continue
		if pos.distance_squared_to(player_pos) > 54.0 * 54.0:
			continue
		var raw_direction := Vector2(bullet.get("vel", Vector2.RIGHT))
		var direction := raw_direction.normalized() if raw_direction.length_squared() > 0.01 else Vector2.RIGHT
		var draw_size := clampf(float(bullet.get("pitchNoteDrawSize", PITCH_POLICE_NOTE_DRAW_SIZE)), 34.0, 44.0)
		var scale := draw_size / PITCH_POLICE_NOTE_DRAW_SIZE
		var rotation := pitch_police_note_visual_rotation(direction, String(bullet.get("pitchNoteRotationMode", "folded")), float(bullet.get("life", 0.0)), float(bullet.get("pitchNoteSeed", 0.0)))
		var dark_rim := Color(0.22, 0.0, 0.12, 0.82)
		var bright_rim := Color(1.0, 0.92, 0.98, 0.74)
		var head := pitch_police_note_point(pos, Vector2(-8.3, 6.4), rotation, scale)
		target.draw_circle(head, 7.5 * scale, dark_rim, false, 2.3 * scale, true)
		target.draw_arc(head, 6.3 * scale, rotation - 2.6, rotation - 0.25, 10, bright_rim, 1.3 * scale, true)
		var stem_bottom := pitch_police_note_point(pos, Vector2(-3.0, 5.0), rotation, scale)
		var stem_top := pitch_police_note_point(pos, Vector2(-3.0, -12.5), rotation, scale)
		target.draw_line(stem_bottom, stem_top, dark_rim, 3.8 * scale, true)
		target.draw_line(stem_bottom, stem_top, bright_rim, 1.3 * scale, true)
		var check_a := pitch_police_note_point(pos, Vector2(0.0, 2.0), rotation, scale)
		var check_b := pitch_police_note_point(pos, Vector2(5.0, 8.0), rotation, scale)
		var check_c := pitch_police_note_point(pos, Vector2(15.0, -7.0), rotation, scale)
		target.draw_line(check_a, check_b, dark_rim, 4.6 * scale, true)
		target.draw_line(check_b, check_c, dark_rim, 4.6 * scale, true)
		target.draw_line(check_a, check_b, bright_rim, 1.65 * scale, true)
		target.draw_line(check_b, check_c, bright_rim, 1.65 * scale, true)

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
