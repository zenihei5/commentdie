class_name EnemyDrawSystem
extends RefCounted

const DrawDataSystemScript := preload("res://scripts/systems/draw_data_system.gd")
const DrawPrimitiveSystemScript := preload("res://scripts/systems/draw_primitive_system.gd")
const GameFontSystemScript := preload("res://scripts/systems/game_font_system.gd")
const TextureCacheSystemScript := preload("res://scripts/systems/texture_cache_system.gd")

static var enemy_texture_cache: Dictionary = {}

static func draw_enemies(target: CanvasItem, enemy_list: Array, visible_rect: Rect2 = Rect2()) -> void:
	var use_culling := visible_rect.size != Vector2.ZERO
	for enemy in enemy_list:
		var enemy_data: Dictionary = enemy as Dictionary
		if float(enemy_data.get("cutinVisualAlpha", 1.0)) <= 0.001:
			continue
		if use_culling and not visible_rect.has_point(Vector2(enemy_data.get("pos", Vector2.ZERO))):
			continue
		var enemy_draw: Dictionary = DrawDataSystemScript.enemy_draw_data(enemy_data)
		draw_red_pen_boss_attack_fx(target, enemy_data)
		draw_enemy_shot_warning(target, enemy_data)
		draw_collab_enemy_fx(target, enemy_data)
		draw_unread_maro_spawn_fx(target, enemy_data)
		for part in DrawDataSystemScript.enemy_draw_parts(enemy_draw):
			var part_data: Dictionary = part as Dictionary
			draw_enemy_part(target, part_data)
			if String(part_data.get("kind", "")) == "body":
				draw_red_pen_summon_pop_in(target, enemy_data)
				if String(enemy_data.get("kind", "")) == "red_pen_review_chief" and bool(enemy_data.get("redPenSummonWarningActive", false)):
					draw_red_pen_summon_warning(target, enemy_data, Vector2(enemy_data.get("pos", Vector2.ZERO)), float(enemy_data.get("radius", 100.0)))
			draw_kuso_maro_barrage_telegraph(target, enemy_data)
		draw_relay_noise_summon_fx(target, enemy_data)
		draw_unread_maro_summon_telegraph(target, enemy_data)
		draw_bug_spoiler_telegraph(target, enemy_data)
		if bool(enemy_data.get("syncStarCarrier", false)) and not bool(enemy_data.get("defeatResolved", false)):
			draw_sync_star_carrier(target, enemy_data)

static func draw_bug_spoiler_telegraph(target: CanvasItem, enemy: Dictionary) -> void:
	if String(enemy.get("kind", "")) != "bugged_final_boss" or not enemy.has("buggedSpoilerTelegraphDirections"):
		return
	var directions: Array = enemy.get("buggedSpoilerTelegraphDirections", []) as Array
	if directions.is_empty():
		return
	var pos := Vector2(enemy.get("pos", Vector2.ZERO))
	var radius := float(enemy.get("radius", 96.0))
	var duration := maxf(0.01, float(enemy.get("buggedSpoilerTelegraphDuration", 0.40)))
	var timer := clampf(float(enemy.get("buggedSpoilerTelegraphTimer", duration)), 0.0, duration)
	var progress := clampf(1.0 - timer / duration, 0.0, 1.0)
	var clock := float(Time.get_ticks_msec()) / 1000.0
	var pulse := 0.5 + 0.5 * sin(clock * 18.0)
	var final_charge := smoothstep(0.72, 1.0, progress)
	var phase_strength := 1.12 if directions.size() >= 4 else 1.0
	for direction_item in directions:
		var dir: Vector2 = direction_item
		if dir.length_squared() < 0.01:
			continue
		dir = dir.normalized()
		var side := Vector2(-dir.y, dir.x)
		var marker_start := pos + dir * radius * 0.43
		var marker_end := pos + dir * radius * (1.12 + pulse * 0.025)
		var alpha := (0.56 + progress * 0.20 + final_charge * 0.20) * phase_strength
		target.draw_line(marker_start, marker_end, Color(0.20, 0.01, 0.09, 0.54 * alpha), 8.0, true)
		target.draw_line(marker_start + dir * 2.0, marker_end, Color(1.0, 0.06, 0.40, 0.76 * alpha), 4.0, true)
		target.draw_line(marker_start + dir * 8.0, marker_end - dir * 4.0, Color(1.0, 0.88, 0.94, (0.52 + final_charge * 0.32) * alpha), 1.2, true)
		var glitch_center := marker_start.lerp(marker_end, 0.68) + side * (6.0 + pulse * 2.0)
		target.draw_line(glitch_center - dir * 4.0, glitch_center + dir * 3.0, Color(0.02, 0.94, 1.0, 0.72 * alpha), 2.0, true)
		target.draw_line(glitch_center - side * 3.0 - dir * 1.0, glitch_center + side * 2.0 + dir * 1.0, Color(0.62, 0.12, 1.0, 0.54 * alpha), 1.5, true)
		var bubble_center := marker_end + dir * (7.0 + final_charge * 2.0)
		var bubble_forward := dir * (8.0 + pulse * 0.7)
		var bubble_side := side * (5.2 + pulse * 0.4)
		var bubble_points := PackedVector2Array([
			bubble_center - bubble_forward - bubble_side,
			bubble_center + bubble_forward - bubble_side,
			bubble_center + bubble_forward + bubble_side,
			bubble_center - bubble_forward * 0.18 + bubble_side,
			bubble_center - bubble_forward * 0.62 + bubble_side * 1.45,
			bubble_center - bubble_forward * 0.55 + bubble_side,
			bubble_center - bubble_forward - bubble_side
		])
		target.draw_colored_polygon(bubble_points, Color(1.0, 0.82, 0.91, 0.74 * alpha))
		target.draw_polyline(bubble_points, Color(0.42, 0.01, 0.17, 0.92 * alpha), 2.2, true)
		target.draw_line(bubble_center - dir * 4.8, bubble_center + dir * 4.8, Color(0.11, 0.01, 0.08, 0.90 * alpha), 2.2, true)

static func draw_kuso_maro_barrage_telegraph(target: CanvasItem, enemy: Dictionary) -> void:
	if String(enemy.get("kind", "")) != "boss_kuso_maro_king" or not enemy.has("kusoMaroBarrageStartAngle"):
		return
	var pos := Vector2(enemy.get("pos", Vector2.ZERO))
	var radius := float(enemy.get("radius", 96.0))
	var count := maxi(1, int(enemy.get("kusoMaroBarrageTelegraphCount", 6)))
	var start_angle := float(enemy.get("kusoMaroBarrageStartAngle", 0.0))
	var duration := maxf(0.01, float(enemy.get("kusoMaroBarrageTelegraphDuration", 0.46)))
	var timer := clampf(float(enemy.get("kusoMaroBarrageTelegraphTimer", duration)), 0.0, duration)
	var progress := clampf(1.0 - timer / duration, 0.0, 1.0)
	var clock := float(Time.get_ticks_msec()) / 1000.0
	var pulse := 0.5 + 0.5 * sin(clock * 16.0)
	var alpha := 0.46 + progress * 0.34 + pulse * 0.12
	target.draw_circle(pos, radius * (0.68 + pulse * 0.035), Color(0.94, 0.40, 0.76, 0.10 * alpha), false, 2.4, true)
	for i in range(count):
		var angle := start_angle + TAU * float(i) / float(count)
		var dir := Vector2(cos(angle), sin(angle))
		var marker_start := pos + dir * radius * 0.38
		var marker_end := pos + dir * radius * (1.31 + pulse * 0.045)
		target.draw_line(marker_start, marker_end, Color(0.54, 0.26, 0.66, 0.28 * alpha), 5.2, true)
		target.draw_line(marker_start, marker_end, Color(0.98, 0.48, 0.76, 0.70 * alpha), 2.6, true)
		target.draw_line(marker_start + dir * 6.0, marker_end - dir * 4.0, Color(1.0, 0.96, 1.0, 0.58 * alpha), 0.9, true)
		var marker_center := marker_end + dir * (5.0 + progress * 3.0)
		target.draw_circle(marker_center, 7.0 + pulse * 1.4, Color(0.94, 0.50, 0.82, 0.18 * alpha))
		target.draw_circle(marker_center, 4.2 + pulse * 0.8, Color(0.92, 0.42, 0.75, 0.66 * alpha))
		target.draw_circle(marker_center, 1.8 + progress * 0.4, Color(1.0, 0.97, 1.0, 0.82 * alpha))

static func draw_unread_maro_summon_telegraph(target: CanvasItem, enemy: Dictionary) -> void:
	if String(enemy.get("kind", "")) != "boss_kuso_maro_king" or not enemy.has("unreadMaroSummonTelegraphPositions"):
		return
	var positions: Array = enemy.get("unreadMaroSummonTelegraphPositions", []) as Array
	if positions.is_empty():
		return
	var duration := maxf(0.01, float(enemy.get("unreadMaroSummonTelegraphDuration", 0.50)))
	var timer := clampf(float(enemy.get("unreadMaroSummonTelegraphTimer", duration)), 0.0, duration)
	var progress := clampf(1.0 - timer / duration, 0.0, 1.0)
	var appear := smoothstep(0.0, 0.12, progress)
	var final_charge := smoothstep(0.80, 1.0, progress)
	var clock := float(Time.get_ticks_msec()) / 1000.0
	var pulse := 0.5 + 0.5 * sin(clock * 13.0)
	var boss_pos := Vector2(enemy.get("pos", Vector2.ZERO))
	var boss_radius := float(enemy.get("radius", 96.0))
	var cast_envelope := 1.0 - smoothstep(0.36, 0.48, progress)
	if cast_envelope > 0.0:
		var cast_burst := sin(clampf(progress / 0.48, 0.0, 1.0) * PI)
		target.draw_circle(boss_pos, boss_radius * (0.78 + cast_burst * 0.16), Color(0.96, 0.48, 0.82, 0.14 * cast_envelope))
		target.draw_circle(boss_pos, boss_radius * (0.90 + cast_burst * 0.12), Color(0.70, 0.42, 0.86, 0.48 * cast_envelope), false, 3.0, true)
		for i in range(5):
			var puff_angle := -PI * 0.86 + float(i) * PI * 0.43
			var puff_pos := boss_pos + Vector2(cos(puff_angle), sin(puff_angle)) * boss_radius * (0.58 + cast_burst * 0.15)
			var puff_color := Color(1.0, 0.96, 1.0, 0.46 * cast_envelope) if i % 2 == 0 else Color(0.86, 0.62, 0.94, 0.40 * cast_envelope)
			target.draw_circle(puff_pos, 4.0 + cast_burst * 3.0, puff_color)
			var paper_side := Vector2(-sin(puff_angle), cos(puff_angle))
			target.draw_line(puff_pos - paper_side * 3.0, puff_pos + paper_side * 3.0, Color(1.0, 0.82, 0.94, 0.52 * cast_envelope), 1.6, true)
	var send_progress := smoothstep(0.04, 0.64, progress)
	for index in range(positions.size()):
		var marker_pos: Vector2 = positions[index]
		if progress < 0.72:
			for trail_index in range(3):
				var trail_t := clampf(send_progress - float(trail_index) * 0.105, 0.0, 1.0)
				var trail_pos := boss_pos.lerp(marker_pos, trail_t)
				var trail_alpha := sin(trail_t * PI) * appear * (1.0 - smoothstep(0.62, 0.72, progress))
				target.draw_circle(trail_pos, 2.2 - float(trail_index) * 0.35, Color(1.0, 0.34, 0.64, 0.72 * trail_alpha))
		var ring_radius := lerpf(30.0, 26.0, appear)
		ring_radius = lerpf(ring_radius + pulse * 1.6, 21.5, final_charge)
		var marker_alpha := appear * (0.72 + pulse * 0.18)
		target.draw_circle(marker_pos, ring_radius + 7.0, Color(0.86, 0.66, 0.96, 0.08 * marker_alpha))
		target.draw_circle(marker_pos, ring_radius, Color(1.0, 0.96, 1.0, 0.12 * marker_alpha))
		target.draw_circle(marker_pos, ring_radius, Color(0.78, 0.40, 0.88, 0.72 * marker_alpha), false, 3.2, true)
		target.draw_circle(marker_pos, ring_radius - 4.5, Color(1.0, 0.58, 0.80, 0.74 * marker_alpha), false, 1.7, true)
		for dot_index in range(4):
			var dot_angle := clock * 0.8 + float(dot_index) * TAU / 4.0 + float(index) * 0.47
			var dot_pos := marker_pos + Vector2(cos(dot_angle), sin(dot_angle)) * (ring_radius + 3.0)
			target.draw_circle(dot_pos, 1.8 + final_charge * 0.8, Color(1.0, 0.92, 1.0, 0.76 * marker_alpha))
		var badge_pos := marker_pos + Vector2(ring_radius * 0.62, -ring_radius * 0.62)
		target.draw_circle(badge_pos, 10.2, Color(0.28, 0.02, 0.12, 0.36 * marker_alpha))
		target.draw_circle(badge_pos, 9.0 + final_charge * 0.7, Color(1.0, 0.16, 0.43, 0.94 * marker_alpha))
		target.draw_circle(badge_pos, 9.0 + final_charge * 0.7, Color(1.0, 0.90, 0.96, 0.88 * marker_alpha), false, 1.2, true)
		target.draw_string(GameFontSystemScript.black_font(), badge_pos + Vector2(-10.5, 3.2), "99+", HORIZONTAL_ALIGNMENT_CENTER, 21.0, 9, Color(1.0, 1.0, 1.0, marker_alpha))

static func draw_unread_maro_spawn_fx(target: CanvasItem, enemy: Dictionary) -> void:
	if String(enemy.get("kind", "")) != "unread_maro" or not enemy.has("unreadMaroPopInTimer"):
		return
	var duration := maxf(0.01, float(enemy.get("unreadMaroPopInDuration", 0.20)))
	var timer := clampf(float(enemy.get("unreadMaroPopInTimer", 0.0)), 0.0, duration)
	if timer <= 0.0:
		return
	var progress := clampf(1.0 - timer / duration, 0.0, 1.0)
	var fade := 1.0 - smoothstep(0.38, 1.0, progress)
	var pos := Vector2(enemy.get("pos", Vector2.ZERO))
	var phase := float(int(enemy.get("uid", 0)) % 17) * 0.37
	var ring_radius := lerpf(28.0, 13.0, smoothstep(0.0, 1.0, progress))
	target.draw_circle(pos, ring_radius, Color(1.0, 0.95, 1.0, 0.24 * fade))
	target.draw_circle(pos, ring_radius, Color(0.94, 0.42, 0.76, 0.66 * fade), false, 2.4, true)
	for i in range(4):
		var angle := phase + float(i) * TAU / 4.0
		var travel := 8.0 + progress * (15.0 + float(i % 2) * 4.0)
		var puff_pos := pos + Vector2(cos(angle), sin(angle)) * travel
		var puff_color := Color(1.0, 0.98, 0.94, 0.58 * fade) if i % 2 == 0 else Color(0.84, 0.62, 0.94, 0.48 * fade)
		target.draw_circle(puff_pos, lerpf(5.4, 2.2, progress), puff_color)
		if i < 3:
			var paper_side := Vector2(-sin(angle), cos(angle))
			target.draw_line(puff_pos - paper_side * 3.2, puff_pos + paper_side * 3.2, Color(1.0, 0.72, 0.88, 0.68 * fade), 1.8, true)
	var badge_pos := pos + Vector2(13.0 + progress * 6.0, -13.0 - progress * 5.0)
	target.draw_circle(badge_pos, lerpf(6.5, 2.5, progress), Color(1.0, 0.14, 0.40, 0.78 * fade))

static func _relay_noise_visual_hash(seed: float, salt: int) -> float:
	return fposmod(sin(seed * 12.9898 + float(salt) * 78.233) * 43758.5453, 1.0)

static func draw_relay_noise_summon_fx(target: CanvasItem, enemy: Dictionary) -> void:
	if String(enemy.get("kind", "")) != "noise_ghost_comment" or not bool(enemy.get("relayNoiseSummonVisual", false)) or not bool(enemy.get("relayBossNoiseSummon", false)):
		return
	if bool(enemy.get("defeatResolved", false)):
		return
	var pos := Vector2(enemy.get("pos", Vector2.ZERO))
	var radius := maxf(12.0, float(enemy.get("radius", 22.0)))
	var seed := float(enemy.get("relayNoiseVisualSeed", 0.0))
	var elapsed := float(target.get("elapsed")) if target.has_method("get") else 0.0
	var nearby_count := 1
	var enemy_list_value: Variant = target.get("enemies") if target.has_method("get") else null
	if enemy_list_value is Array:
		nearby_count = 0
		for item in enemy_list_value as Array:
			var other: Dictionary = item as Dictionary
			if String(other.get("kind", "")) != "noise_ghost_comment" or not bool(other.get("relayNoiseSummonVisual", false)) or bool(other.get("defeatResolved", false)) or bool(other.get("defeatPending", false)):
				continue
			if Vector2(other.get("pos", pos)).distance_squared_to(pos) <= 108.0 * 108.0:
				nearby_count += 1
		if nearby_count <= 0:
			nearby_count = 1
	var density_alpha := 1.0
	if nearby_count >= 6:
		density_alpha = 0.62
	elif nearby_count >= 4:
		density_alpha = 0.78
	var source_alpha := 0.70 if String(enemy.get("relayNoiseSource", enemy.get("relayBossSummonSource", "main_attack"))) == "travel_support" else 1.0
	var pulse := 0.62 + 0.38 * sin(elapsed * 6.0 + seed)
	var alpha := density_alpha * source_alpha
	var variant := int(floor(_relay_noise_visual_hash(seed, 4) * 3.0)) % 3
	var split_gap := 0.30 + float(variant) * 0.10
	# The overlay stays close to the 22px enemy silhouette.  It is a broken
	# broadcast edge, not a danger ring, tether, or second enemy body.
	target.draw_arc(pos, radius + 3.0, seed + 0.12, seed + 1.10 - split_gap, 8, Color(0.18, 0.90, 1.0, 0.18 * alpha), 1.4, true)
	target.draw_arc(pos, radius + 3.0, seed + 1.38 + split_gap, seed + 2.55, 8, Color(1.0, 0.24, 0.68, 0.16 * alpha), 1.3, true)
	target.draw_arc(pos, radius + 3.0, seed + 3.28, seed + 4.08 - split_gap * 0.5, 7, Color(0.26, 0.84, 1.0, 0.13 * alpha), 1.2, true)
	var scan_width := radius * 0.92
	var scan_y := pos.y - radius * 0.34
	target.draw_line(Vector2(pos.x - scan_width * 0.42, scan_y), Vector2(pos.x + scan_width * 0.12, scan_y), Color(0.82, 0.94, 1.0, (0.16 + pulse * 0.05) * alpha), 1.0, true)
	target.draw_line(Vector2(pos.x - scan_width * 0.08, pos.y + radius * 0.22), Vector2(pos.x + scan_width * 0.46, pos.y + radius * 0.22), Color(1.0, 0.34, 0.72, 0.11 * alpha), 1.0, true)
	var block_offsets := [
		Vector2(-radius * 0.78, -radius * 0.18),
		Vector2(radius * 0.38, -radius * 0.78),
		Vector2(radius * 0.72, radius * 0.36),
		Vector2(-radius * 0.20, radius * 0.76)
	]
	for i in range(4):
		if i == 3 and nearby_count >= 4:
			continue
		var offset: Vector2 = block_offsets[(i + variant) % block_offsets.size()]
		var jitter := (_relay_noise_visual_hash(seed, 10 + i) - 0.5) * 3.0
		var block_pos := pos + offset + Vector2(jitter, -jitter * 0.45)
		var block_size := Vector2(4.0 + float(i % 2) * 2.0, 2.0 + float((i + variant) % 2))
		var block_color := Color(0.10, 0.03, 0.18, 0.20 * alpha) if i % 2 == 0 else Color(0.96, 0.19, 0.62, 0.14 * alpha)
		target.draw_rect(Rect2(block_pos - block_size * 0.5, block_size), block_color, true)
	var signal_start := pos + Vector2(-radius * 0.72, radius * 0.05)
	var signal_end := pos + Vector2(-radius * 0.18, radius * 0.05)
	target.draw_line(signal_start, signal_end, Color(0.30, 0.92, 1.0, 0.17 * alpha), 1.4, true)
	target.draw_line(signal_end + Vector2(3.0, -2.0), signal_end + Vector2(7.0, 2.0), Color(1.0, 0.28, 0.70, (0.16 + pulse * 0.04) * alpha), 1.3, true)

static func draw_red_pen_summon_pop_in(target: CanvasItem, enemy: Dictionary) -> void:
	if String(enemy.get("kind", "")) != "drawing_fix_note" or not bool(enemy.get("redPenSummonVisual", false)):
		return
	var duration := maxf(0.01, float(enemy.get("redPenSummonPopInDuration", 0.20)))
	var timer := clampf(float(enemy.get("redPenSummonPopInTimer", 0.0)), 0.0, duration)
	if timer <= 0.0:
		return
	var progress := clampf(1.0 - timer / duration, 0.0, 1.0)
	var fade := 1.0 - smoothstep(0.72, 1.0, progress)
	var pulse := sin(progress * PI)
	var pos := Vector2(enemy.get("pos", Vector2.ZERO))
	var seed := float(enemy.get("redPenSummonVisualSeed", 0.0))
	var variant := int(enemy.get("redPenSummonVisualVariant", 0))
	var ring_radius := lerpf(24.0, 17.0, smoothstep(0.0, 1.0, progress))
	target.draw_arc(pos, ring_radius + pulse * 3.0, seed + 0.24, seed + 2.0, 16, Color(0.34, 0.005, 0.12, 0.50 * fade), 3.0, true)
	target.draw_arc(pos, ring_radius, seed + 2.52, seed + 4.70, 16, Color(0.88, 0.02, 0.20, 0.76 * fade), 1.8, true)
	var stroke_dir := Vector2.from_angle(seed + float(variant) * 0.46)
	var stroke_side := Vector2(-stroke_dir.y, stroke_dir.x)
	var stroke_center := pos + stroke_side * 2.0
	target.draw_line(stroke_center - stroke_dir * 13.0, stroke_center + stroke_dir * 9.0, Color(0.28, 0.003, 0.08, 0.78 * fade), 3.8, true)
	target.draw_line(stroke_center - stroke_dir * 8.0, stroke_center + stroke_dir * 5.0, Color(1.0, 0.18, 0.34, 0.78 * fade), 1.5, true)
	for i in range(3):
		var angle := seed + float(i) * 2.06 + float(variant) * 0.17
		var shard_dir := Vector2.from_angle(angle)
		var shard_pos := pos + shard_dir * (13.0 + progress * 9.0)
		target.draw_circle(shard_pos, 2.0 - float(i % 2) * 0.35, Color(0.68, 0.01, 0.15, 0.72 * fade))
		if i < 2:
			target.draw_line(shard_pos - shard_dir * 2.0, shard_pos + shard_dir * 4.0, Color(1.0, 0.76, 0.84, 0.54 * fade), 1.2, true)
	for i in range(2):
		var paper_angle := seed + float(i) * PI + 0.6
		var paper_dir := Vector2.from_angle(paper_angle)
		var paper_pos := pos + paper_dir * (16.0 + progress * 8.0)
		target.draw_line(paper_pos - Vector2(3.0, 1.0).rotated(paper_angle), paper_pos + Vector2(3.0, 1.0).rotated(paper_angle), Color(1.0, 0.94, 0.96, 0.64 * fade), 1.4, true)

static func draw_sync_star_carrier(target: CanvasItem, enemy: Dictionary) -> void:
	var pos := Vector2(enemy.get("pos", Vector2.ZERO))
	var radius := float(enemy.get("radius", 22.0))
	var clock := float(Time.get_ticks_msec()) / 1000.0
	var phase := float(enemy.get("syncStarCarrierWaveId", 0)) * 0.61
	var pulse := 0.5 + 0.5 * sin(clock * 4.5 + phase)
	var reveal := clampf(float(enemy.get("syncStarCarrierRevealTimer", 0.0)) / 0.45, 0.0, 1.0)
	var alpha := 1.0 - reveal * 0.18
	target.draw_circle(pos + Vector2(0.0, -radius - 25.0), 24.0 + pulse * 6.0, Color(1.0, 0.82, 0.28, 0.10 * alpha), true)
	target.draw_arc(pos + Vector2(0.0, -radius - 25.0), 25.0 + pulse * 4.0, clock * 1.8, clock * 1.8 + TAU * 0.82, 24, Color(1.0, 0.62, 0.84, 0.72 * alpha), 2.2, true)
	var icon_path := "res://assets/generated/field_pickup_icons_v1/icons/sync_star.png"
	var config_value: Variant = target.get("relay_mode_config") if target.has_method("get") else null
	if config_value is Dictionary:
		var boss_config: Dictionary = (config_value as Dictionary).get("boss", {}) as Dictionary
		var attacks: Dictionary = boss_config.get("attacks", {}) as Dictionary
		var sync_config: Dictionary = ((attacks.get("noise_summon", {}) as Dictionary).get("syncStar", {}) as Dictionary)
		icon_path = String(sync_config.get("iconPath", icon_path))
	var texture := TextureCacheSystemScript.load_png_texture(enemy_texture_cache, icon_path)
	if texture != null:
		var size := Vector2(36.0, 36.0) * (1.0 + reveal * 0.30)
		var icon_pos := pos + Vector2(-size.x * 0.5, -radius - 48.0 - size.y * 0.5)
		target.draw_texture_rect(texture, Rect2(icon_pos, size), false, Color(1.0, 1.0, 1.0, alpha))
	for i in range(4):
		var angle := clock * 1.5 + float(i) * TAU / 4.0
		var sparkle_pos := pos + Vector2(cos(angle) * (28.0 + pulse * 4.0), -radius - 25.0 + sin(angle) * (20.0 + pulse * 3.0))
		target.draw_circle(sparkle_pos, 2.0 + reveal * 3.0, Color(1.0, 0.92, 0.52, (0.52 + reveal * 0.40) * alpha))

static func draw_collab_enemy_fx(target: CanvasItem, enemy: Dictionary) -> void:
	var kind := String(enemy.get("kind", ""))
	if not kind.begins_with("collab_"):
		return
	var pos := Vector2(enemy.get("pos", Vector2.ZERO))
	var radius := float(enemy.get("radius", 22.0))
	var clock := float(Time.get_ticks_msec()) / 1000.0
	if kind == "collab_comparison_troll":
		var pulse := 0.5 + 0.5 * sin(clock * 6.0)
		target.draw_circle(pos, radius + 11.0 + pulse * 3.0, Color(0.98, 0.50, 0.66, 0.12), false, 2.0, true)
		target.draw_line(pos + Vector2(-7.0, -radius - 11.0), pos + Vector2(0.0, -radius - 4.0), Color("#d7567c"), 2.4, true)
		target.draw_line(pos + Vector2(0.0, -radius - 4.0), pos + Vector2(7.0, -radius - 11.0), Color("#d7567c"), 2.4, true)
	elif kind == "collab_messenger_pigeon":
		var warning := float(enemy.get("messengerWarningTimer", 0.0))
		if warning <= 0.0:
			return
		var target_pos := Vector2(enemy.get("messengerDashTarget", pos))
		var target_delta := target_pos - pos
		var dash_dir := target_delta.normalized()
		if dash_dir.length_squared() < 0.01:
			dash_dir = Vector2.RIGHT
		var side := Vector2(-dash_dir.y, dash_dir.x)
		var charge := 1.0 - clampf(warning / 0.55, 0.0, 1.0)
		var pulse := 0.72 + 0.28 * sin(clock * 16.0)
		var start := pos + dash_dir * (radius + 5.0)
		var line_length := clampf(target_delta.length() - radius * 0.35, 112.0, 210.0)
		var end := pos + dash_dir * line_length
		var tail_width := 5.0 + charge * 1.8
		var ribbon := PackedVector2Array([
			start + side * tail_width,
			start - side * tail_width,
			end - side * 0.7,
			end + side * 0.7
		])
		target.draw_colored_polygon(ribbon, Color(0.45, 0.28, 0.72, (0.10 + charge * 0.08) * pulse))
		for marker_index in range(5):
			var marker_t := fposmod(clock * (0.70 + charge * 0.45) + float(marker_index) * 0.19, 1.0)
			marker_t = 0.08 + marker_t * 0.78
			var marker_center := start.lerp(end, marker_t)
			var marker_half_length := 4.0 + charge * 1.8
			var marker_alpha := sin(marker_t * PI) * pulse
			var marker_from := marker_center - dash_dir * marker_half_length
			var marker_to := marker_center + dash_dir * marker_half_length
			target.draw_line(marker_from, marker_to, Color(0.16, 0.07, 0.25, marker_alpha * 0.58), 4.2, true)
			target.draw_line(marker_from, marker_to, Color(0.78, 0.68, 1.0, marker_alpha), 1.8, true)
		var arrow_base := end - dash_dir * (13.0 + charge * 3.0)
		var arrow_width := 6.0 + charge * 1.5
		target.draw_line(arrow_base + side * arrow_width, end, Color(0.18, 0.08, 0.28, pulse * 0.72), 4.8, true)
		target.draw_line(arrow_base - side * arrow_width, end, Color(0.18, 0.08, 0.28, pulse * 0.72), 4.8, true)
		target.draw_line(arrow_base + side * arrow_width, end, Color(0.88, 0.80, 1.0, pulse), 2.0, true)
		target.draw_line(arrow_base - side * arrow_width, end, Color(0.88, 0.80, 1.0, pulse), 2.0, true)
		var arc_rotation := clock * (3.4 + charge * 2.2)
		target.draw_arc(pos, radius + 8.0, arc_rotation, arc_rotation + PI * 0.68, 18, Color(0.82, 0.72, 1.0, pulse), 2.4, true)
		target.draw_arc(pos, radius + 8.0, arc_rotation + PI, arc_rotation + PI * 1.68, 18, Color(0.82, 0.72, 1.0, pulse), 2.4, true)
	elif kind == "collab_discord_troll":
		var pulse_warning := float(enemy.get("collabPulseWarningTimer", 0.0))
		if pulse_warning > 0.0:
			var pulse_alpha := 0.36 + 0.36 * sin(clock * 15.0)
			target.draw_circle(pos, 190.0, Color(0.84, 0.30, 0.72, pulse_alpha * 0.08), true)
			target.draw_circle(pos, 190.0, Color(0.82, 0.28, 0.69, pulse_alpha), false, 3.5, true)
	elif kind == "collab_volume_police":
		var field_warning := float(enemy.get("collabFieldWarningTimer", 0.0))
		if field_warning > 0.0:
			var field_alpha := 0.35 + 0.32 * sin(clock * 13.0)
			target.draw_circle(pos, 135.0, Color(0.46, 0.66, 1.0, field_alpha * 0.10), true)
			target.draw_circle(pos, 135.0, Color(0.56, 0.74, 1.0, field_alpha), false, 3.0, true)
	elif kind == "collab_exclusive_listener" and bool(enemy.get("collabPartnerAttached", false)):
		target.draw_circle(pos, radius + 7.0, Color(0.72, 0.39, 0.57, 0.24), false, 3.0, true)

static func draw_red_pen_boss_attack_fx(target: CanvasItem, enemy: Dictionary) -> void:
	if String(enemy.get("kind", "")) != "red_pen_review_chief":
		return
	var warning_active := bool(enemy.get("redPenSummonWarningActive", false))
	var line_time := float(enemy.get("redPenLineCastFx", 0.0))
	var summon_time := float(enemy.get("redPenSummonCastFx", 0.0))
	if not warning_active and line_time <= 0.0 and summon_time <= 0.0:
		return
	var pos := Vector2(enemy.get("pos", Vector2.ZERO))
	var radius := float(enemy.get("radius", 100.0))
	var dir := Vector2(enemy.get("redPenCastDir", Vector2.RIGHT))
	if dir.length_squared() <= 0.01:
		dir = Vector2.RIGHT
	dir = dir.normalized()
	var side := Vector2(-dir.y, dir.x)
	var clock := float(Time.get_ticks_msec()) / 1000.0
	if line_time > 0.0:
		var max_time := maxf(0.01, float(enemy.get("redPenLineCastFxMax", 0.76)))
		var ratio := clampf(line_time / max_time, 0.0, 1.0)
		var progress := 1.0 - ratio
		var pulse := 0.5 + 0.5 * sin(clock * 18.0)
		target.draw_circle(pos, radius * (1.08 + progress * 0.30), Color(0.30, 0.01, 0.05, 0.32 * ratio), false, 10.0, true)
		target.draw_circle(pos, radius * (0.88 + pulse * 0.08), Color(1.0, 0.10, 0.18, 0.46 * ratio), false, 4.0, true)
		for i in range(4):
			var angle := clock * 1.6 + float(i) * TAU / 4.0
			var mark_pos := pos + Vector2(cos(angle), sin(angle)) * radius * (0.72 + progress * 0.22)
			var mark_side := Vector2(-sin(angle), cos(angle))
			target.draw_line(mark_pos - mark_side * 10.0, mark_pos + mark_side * 10.0, Color(1.0, 0.78, 0.80, 0.68 * ratio), 3.0, true)
			target.draw_line(mark_pos - Vector2(5.0, 5.0), mark_pos + Vector2(5.0, 5.0), Color(1.0, 0.12, 0.22, 0.72 * ratio), 2.2, true)
	if summon_time > 0.0:
		var max_time := maxf(0.01, float(enemy.get("redPenSummonCastFxMax", 0.16)))
		var ratio := clampf(summon_time / max_time, 0.0, 1.0)
		var progress := 1.0 - ratio
		var burst := sin(progress * PI)
		var confirm_radius := radius * (0.70 + burst * 0.10)
		target.draw_arc(pos, confirm_radius, -0.6 + progress * 0.4, 1.55 + progress * 0.4, 18, Color(0.35, 0.005, 0.10, 0.44 * ratio), 3.0, true)
		target.draw_arc(pos, confirm_radius - 4.0, 2.4 + progress * 0.35, 4.2 + progress * 0.35, 18, Color(1.0, 0.18, 0.34, 0.64 * ratio), 1.6, true)
		for i in range(3):
			var angle := 0.45 + float(i) * 2.18 + progress * 0.28
			var mark_pos := pos + Vector2.from_angle(angle) * radius * (0.56 + burst * 0.08)
			var mark_side := Vector2(-sin(angle), cos(angle))
			target.draw_line(mark_pos - mark_side * 5.0, mark_pos + mark_side * 5.0, Color(1.0, 0.72, 0.80, 0.58 * ratio), 2.0, true)
			target.draw_circle(mark_pos + Vector2.from_angle(angle) * 2.0, 2.0 + burst * 1.0, Color(0.72, 0.01, 0.16, 0.68 * ratio))

static func draw_red_pen_summon_warning(target: CanvasItem, enemy: Dictionary, pos: Vector2, radius: float) -> void:
	var duration := maxf(0.01, float(enemy.get("redPenSummonWarningDuration", 0.50)))
	var real_left := clampf(float(enemy.get("redPenSummonWarningRealLeft", duration)), 0.0, duration)
	var progress := clampf(1.0 - real_left / duration, 0.0, 1.0)
	var count := clampi(int(enemy.get("redPenSummonWarningCount", 1)), 1, 3)
	var cast_serial := int(enemy.get("redPenSummonWarningCastSerial", 0))
	var boss_uid := int(enemy.get("uid", -1))
	var seed := fposmod(float(cast_serial * 0.73 + boss_uid * 0.19), TAU)
	var late := smoothstep(0.36, 0.86, progress)
	var pulse := sin(clampf((progress - 0.80) / 0.20, 0.0, 1.0) * PI)
	var alpha := 0.24 + late * 0.48 + pulse * 0.10
	# The dragon sprite is wider than its gameplay radius; keep the cue outside
	# that visual envelope so the pips remain readable instead of being buried.
	var visual_envelope := radius * 2.08
	var ring_radius := visual_envelope + 8.0 + pulse * 2.5
	# Broken correction ring: this is an attack cue, not a solid hazard circle.
	target.draw_arc(pos, ring_radius, seed + 0.10, seed + 1.32, 18, Color(0.28, 0.003, 0.10, 0.58 * alpha), 3.2, true)
	target.draw_arc(pos, ring_radius, seed + 1.82, seed + 3.12, 18, Color(0.68, 0.01, 0.16, 0.78 * alpha), 2.0, true)
	target.draw_arc(pos, ring_radius, seed + 3.78, seed + 4.86, 16, Color(1.0, 0.20, 0.38, 0.64 * alpha), 1.3, true)
	var underline_side := Vector2.from_angle(seed + 1.1)
	var underline_center := pos + underline_side * (visual_envelope + 15.0)
	var underline_dir := Vector2(-underline_side.y, underline_side.x)
	target.draw_line(underline_center - underline_dir * 12.0, underline_center + underline_dir * 11.0, Color(0.38, 0.005, 0.12, 0.72 * alpha), 3.0, true)
	target.draw_line(underline_center - underline_dir * 8.0, underline_center + underline_dir * 6.0, Color(1.0, 0.42, 0.55, 0.76 * alpha), 1.0, true)
	for i in range(count):
		var pip_angle := -PI * 0.5 + (float(i) - float(count - 1) * 0.5) * 0.72
		var pip_dir := Vector2.from_angle(pip_angle)
		var pip_pos := pos + pip_dir * (visual_envelope + 28.0 + pulse * 3.0)
		var pip_alpha := (0.42 + late * 0.52 + pulse * 0.18) * (1.0 - float(i) * 0.04)
		var pip_radius := 7.0 + pulse * 2.0
		target.draw_arc(pip_pos, pip_radius + 3.0, seed + float(i) * 1.7, seed + float(i) * 1.7 + 2.9, 12, Color(0.32, 0.003, 0.11, 0.60 * pip_alpha), 2.2, true)
		target.draw_circle(pip_pos, pip_radius, Color(0.76, 0.01, 0.18, 0.72 * pip_alpha))
		target.draw_line(pip_pos - pip_dir * 3.5, pip_pos + pip_dir * 4.5, Color(1.0, 0.94, 0.96, 0.72 * pip_alpha), 1.5, true)
		target.draw_line(pip_pos - Vector2(-pip_dir.y, pip_dir.x) * 3.0, pip_pos + Vector2(-pip_dir.y, pip_dir.x) * 2.0, Color(1.0, 0.30, 0.48, 0.72 * pip_alpha), 1.3, true)
		if i < 2:
			var paper_pos := pip_pos + Vector2(-pip_dir.y, pip_dir.x) * (8.0 + float(i) * 4.0)
			target.draw_line(paper_pos - pip_dir * 3.0, paper_pos + pip_dir * 3.0, Color(1.0, 0.92, 0.96, 0.54 * pip_alpha), 1.2, true)
	if progress >= 0.62:
		var label_pos := pos + Vector2(-38.0, -visual_envelope - 10.0)
		var label_alpha := 0.46 + late * 0.42
		var font := GameFontSystemScript.black_font()
		target.draw_string(font, label_pos + Vector2(1.0, 1.0), "RETAKE!", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13, Color(0.18, 0.005, 0.08, 0.72 * label_alpha))
		target.draw_string(font, label_pos, "RETAKE!", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13, Color(1.0, 0.62, 0.72, label_alpha))

static func draw_enemy_shot_warning(target: CanvasItem, enemy: Dictionary) -> void:
	var timer := float(enemy.get("shotWarningTimer", 0.0))
	if timer <= 0.0:
		return
	var duration := maxf(0.01, float(enemy.get("shotWarningDuration", timer)))
	var ratio := clampf(1.0 - timer / duration, 0.0, 1.0)
	var pos := Vector2(enemy.get("pos", Vector2.ZERO))
	var radius := float(enemy.get("radius", 24.0)) + lerpf(18.0, 7.0, ratio)
	var alpha := 0.35 + 0.35 * sin(ratio * PI)
	target.draw_circle(pos, radius + 2.0, Color(0.04, 0.02, 0.03, 0.24 * alpha), false, 5.0, true)
	target.draw_circle(pos, radius, Color(1.0, 0.16, 0.24, 0.72 * alpha), false, 3.0, true)
	target.draw_circle(pos, radius - 4.0, Color(1.0, 1.0, 1.0, 0.36 * alpha), false, 1.5, true)
	var dir := Vector2(enemy.get("shotWarningDir", Vector2.ZERO))
	if dir.length() <= 0.1:
		return
	dir = dir.normalized()
	var start := pos + dir * (radius + 5.0)
	var end := pos + dir * (radius + 48.0)
	target.draw_line(start, end, Color(0.05, 0.02, 0.03, 0.32 * alpha), 5.0, true)
	target.draw_line(start, end, Color(1.0, 0.20, 0.28, 0.66 * alpha), 2.5, true)

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
	elif kind == "linked_troll_speech":
		draw_linked_troll_speech(target, part["data"] as Dictionary)

static func draw_linked_troll_speech(target: CanvasItem, bubble: Dictionary) -> void:
	if bubble.is_empty():
		return
	var rect: Rect2 = bubble["rect"] as Rect2
	var tail: PackedVector2Array = bubble["tail"] as PackedVector2Array
	var fill: Color = bubble["fill"] as Color
	var border: Color = bubble["border"] as Color
	target.draw_colored_polygon(tail, fill)
	target.draw_rect(rect, fill, true)
	target.draw_rect(rect, border, false, int(bubble["borderWidth"]))
	if tail.size() >= 3:
		target.draw_line(tail[0], tail[2], border, float(bubble["borderWidth"]), true)
		target.draw_line(tail[1], tail[2], border, float(bubble["borderWidth"]), true)
	var warning_pos: Vector2 = bubble["warningPos"] as Vector2
	target.draw_circle(warning_pos, float(bubble["warningRadius"]) + 1.2, Color(0.35, 0.05, 0.14, (bubble["warningFill"] as Color).a * 0.52))
	target.draw_circle(warning_pos, float(bubble["warningRadius"]), bubble["warningFill"] as Color)
	target.draw_string(GameFontSystemScript.font_for_item(bubble), bubble["warningTextPos"] as Vector2, "!", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, bubble["warningTextColor"] as Color)
	var text_item := {
		"text": String(bubble["text"]),
		"pos": bubble["textPos"] as Vector2,
		"width": int(bubble["textWidth"]),
		"size": int(bubble["textSize"]),
		"color": bubble["textColor"] as Color
	}
	for offset in [Vector2(-0.8, 0.0), Vector2(0.8, 0.0), Vector2(0.0, -0.8), Vector2(0.0, 0.8)]:
		var outline_item: Dictionary = text_item.duplicate()
		outline_item["pos"] = (text_item["pos"] as Vector2) + offset
		outline_item["color"] = bubble["outlineColor"] as Color
		DrawPrimitiveSystemScript.draw_multiline_text_item(target, outline_item)
	DrawPrimitiveSystemScript.draw_multiline_text_item(target, text_item)

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
	if bool(body.get("relayBossTransformed", false)) and target.has_method("_draw_relay_boss_sprite"):
		target.call("_draw_relay_boss_sprite", texture, body)
		return
	if bool(body.get("bugLagWarpVisualActive", false)):
		draw_bug_lag_warp_sprite(target, texture, body)
		return
	# Enemy sprites are already positioned in world coordinates by DrawDataSystem.
	# Keep the draw call in that coordinate space; a temporary CanvasItem transform
	# makes the boss image drift toward the viewport corner in this draw path.
	target.draw_texture_rect(texture, body["rect"] as Rect2, false, body.get("modulate", Color.WHITE) as Color)

static func draw_bug_lag_warp_sprite(target: CanvasItem, texture: Texture2D, body: Dictionary) -> void:
	var rect: Rect2 = body.get("rect", Rect2()) as Rect2
	var modulate: Color = body.get("modulate", Color.WHITE) as Color
	var warning := maxf(0.0, float(body.get("bugLagWarpWarning", 0.0)))
	var warning_duration := maxf(0.01, float(body.get("bugLagWarpWarningDuration", 0.40)))
	var rebuild_timer := maxf(0.0, float(body.get("bugLagWarpRebuildTimer", 0.0)))
	var rebuild_duration := maxf(0.01, float(body.get("bugLagWarpRebuildDuration", 0.15)))
	var old_ghost_timer := maxf(0.0, float(body.get("bugLagWarpOldGhostTimer", 0.0)))
	var old_ghost_duration := maxf(0.01, float(body.get("bugLagWarpOldGhostDuration", 0.033)))
	var current_pos := Vector2(body.get("bugLagWarpCurrentPos", rect.get_center()))
	var target_pos := Vector2(body.get("bugLagWarpTarget", current_pos))
	var origin_pos := Vector2(body.get("bugLagWarpOrigin", current_pos))
	var visual_seed := float(body.get("bugLagWarpVisualSeed", 0.0))
	if warning > 0.0:
		var elapsed := clampf(warning_duration - warning, 0.0, warning_duration)
		var visual_frame := int(floor(elapsed * 60.0 + 0.001))
		var destination_rect := Rect2(rect.position + target_pos - current_pos, rect.size)
		if warning > 0.24:
			_draw_bug_lag_phase_a(target, texture, rect, modulate, visual_seed, visual_frame)
		elif warning > 0.08:
			var phase_b_progress := clampf((0.24 - warning) / 0.16, 0.0, 1.0)
			_draw_bug_lag_destination_preview(target, texture, destination_rect, visual_seed, 0.35 + phase_b_progress * 0.45)
			_draw_bug_lag_phase_b(target, texture, rect, modulate, visual_seed, visual_frame, phase_b_progress)
		else:
			var phase_c_progress := clampf((0.08 - warning) / 0.08, 0.0, 1.0)
			_draw_bug_lag_destination_preview(target, texture, destination_rect, visual_seed, 0.82 + phase_c_progress * 0.18)
			_draw_bug_lag_phase_c(target, texture, rect, modulate, visual_seed, visual_frame, phase_c_progress)
		return
	if rebuild_timer > 0.0:
		var rebuild_progress := clampf(1.0 - rebuild_timer / rebuild_duration, 0.0, 1.0)
		if old_ghost_timer > 0.0:
			var old_rect := Rect2(rect.position + origin_pos - current_pos, rect.size)
			var old_ratio := clampf(old_ghost_timer / old_ghost_duration, 0.0, 1.0)
			_draw_bug_lag_afterimage(target, texture, old_rect, visual_seed, 2, 0.13 * old_ratio, 6.0, 7)
		_draw_bug_lag_rebuild(target, texture, rect, modulate, visual_seed, rebuild_progress)
		return
	target.draw_texture_rect(texture, rect, false, modulate)

static func _draw_bug_lag_phase_a(target: CanvasItem, texture: Texture2D, rect: Rect2, modulate: Color, visual_seed: float, visual_frame: int) -> void:
	var separation := 2.0 + fposmod(visual_seed * 1.7, 2.0)
	var stutter := 0.0
	if visual_frame % 9 == 3 or visual_frame % 9 == 4:
		stutter = (1.5 if sin(visual_seed + float(visual_frame)) >= 0.0 else -1.5)
	target.draw_texture_rect(texture, Rect2(rect.position + Vector2(-separation, 0.5), rect.size), false, Color(0.05, 0.92, 1.0, 0.11 * modulate.a))
	target.draw_texture_rect(texture, Rect2(rect.position + Vector2(separation, -0.5), rect.size), false, Color(1.0, 0.08, 0.68, 0.10 * modulate.a))
	target.draw_texture_rect(texture, Rect2(rect.position + Vector2(stutter, 0.0), rect.size), false, modulate)
	_draw_bug_lag_scanlines(target, rect, visual_seed, 0.30, 1.0)
	_draw_bug_lag_rectangles(target, rect, visual_seed, visual_frame, 0.28, 3)

static func _draw_bug_lag_phase_b(target: CanvasItem, texture: Texture2D, rect: Rect2, modulate: Color, visual_seed: float, visual_frame: int, progress: float) -> void:
	var ghost_alphas := [0.24, 0.15, 0.08]
	for ghost_index in range(3):
		var horizontal_offset := (2.0 + float(ghost_index) * 2.7) * (1.0 if sin(visual_seed * 1.3 + float(ghost_index)) >= 0.0 else -1.0)
		var vertical_offset := sin(visual_seed * 2.1 + float(ghost_index) * 1.8) * (1.5 + float(ghost_index) * 0.8)
		var ghost_rect := Rect2(rect.position + Vector2(horizontal_offset, vertical_offset), rect.size)
		_draw_bug_lag_afterimage(target, texture, ghost_rect, visual_seed, ghost_index, float(ghost_alphas[ghost_index]) * modulate.a, 2.0 + float(ghost_index) * 2.0, visual_frame)
	var separation := 2.8 + progress * 1.2
	target.draw_texture_rect(texture, Rect2(rect.position + Vector2(-separation, 0.0), rect.size), false, Color(0.04, 0.92, 1.0, 0.12 * modulate.a))
	target.draw_texture_rect(texture, Rect2(rect.position + Vector2(separation, 0.0), rect.size), false, Color(1.0, 0.06, 0.65, 0.11 * modulate.a))
	target.draw_texture_rect(texture, rect, false, modulate)
	_draw_bug_lag_scanlines(target, rect, visual_seed + progress, 0.38 + progress * 0.10, 1.2)
	_draw_bug_lag_rectangles(target, rect, visual_seed, visual_frame, 0.34 + progress * 0.12, 4)

static func _draw_bug_lag_phase_c(target: CanvasItem, texture: Texture2D, rect: Rect2, modulate: Color, visual_seed: float, visual_frame: int, progress: float) -> void:
	var slice_count := 9
	var missing_slice := (visual_frame + int(floor(visual_seed * 10.0))) % slice_count
	var omit_slice := visual_frame % 3 == 1
	for slice_index in range(slice_count):
		var direction := -1.0 if (slice_index + int(floor(visual_seed * 3.0))) % 2 == 0 else 1.0
		var variance := 0.72 + fposmod(visual_seed + float(slice_index) * 0.73, 0.58)
		var offset := direction * (2.2 + progress * 5.2) * variance
		_draw_bug_lag_texture_slice(target, texture, rect, slice_index, slice_count, offset - 3.0 - progress * 1.5, 1.0 + progress * 2.0, Color(0.02, 0.94, 1.0, 0.20 * modulate.a))
		_draw_bug_lag_texture_slice(target, texture, rect, slice_index, slice_count, offset + 3.0 + progress * 1.5, 1.0 + progress * 2.0, Color(1.0, 0.04, 0.65, 0.18 * modulate.a))
		if not (omit_slice and slice_index == missing_slice):
			_draw_bug_lag_texture_slice(target, texture, rect, slice_index, slice_count, offset, progress * 3.0, modulate)
	_draw_bug_lag_scanlines(target, rect, visual_seed + progress * 2.0, 0.52 + progress * 0.18, 1.5)
	_draw_bug_lag_rectangles(target, rect, visual_seed + progress, visual_frame, 0.48 + progress * 0.16, 5)

static func _draw_bug_lag_rebuild(target: CanvasItem, texture: Texture2D, rect: Rect2, modulate: Color, visual_seed: float, progress: float) -> void:
	var residual := 1.0 - progress
	var slice_count := 9
	for slice_index in range(slice_count):
		var direction := -1.0 if (slice_index + int(floor(visual_seed * 5.0))) % 2 == 0 else 1.0
		var offset := direction * residual * (3.2 + fposmod(visual_seed + float(slice_index) * 0.61, 2.2))
		_draw_bug_lag_texture_slice(target, texture, rect, slice_index, slice_count, offset - residual * 5.0, residual * 2.0, Color(0.02, 0.94, 1.0, 0.24 * residual * modulate.a))
		_draw_bug_lag_texture_slice(target, texture, rect, slice_index, slice_count, offset + residual * 5.0, residual * 2.0, Color(1.0, 0.05, 0.66, 0.20 * residual * modulate.a))
		_draw_bug_lag_texture_slice(target, texture, rect, slice_index, slice_count, offset, residual * 2.4, modulate)
	if residual > 0.02:
		_draw_bug_lag_scanlines(target, rect, visual_seed + progress, 0.58 * residual, 1.0 + residual)
		_draw_bug_lag_rectangles(target, rect, visual_seed, int(floor(progress * 12.0)), 0.48 * residual, 4)

static func _draw_bug_lag_destination_preview(target: CanvasItem, texture: Texture2D, rect: Rect2, visual_seed: float, strength: float) -> void:
	var slice_count := 9
	for slice_index in [1, 3, 5, 7]:
		var offset := sin(visual_seed * 1.7 + float(slice_index) * 1.3) * (2.5 + strength * 2.0)
		_draw_bug_lag_texture_slice(target, texture, rect, slice_index, slice_count, offset, 2.0 + strength * 3.0, Color(0.04, 0.94, 1.0, (0.07 + strength * 0.09)))
	var bracket_color := Color(0.05, 0.90, 1.0, 0.18 + strength * 0.20)
	var bracket_length := 18.0 + strength * 5.0
	var inset := 14.0
	var bracket_points := [
		rect.position + Vector2(inset, rect.size.y * 0.27),
		rect.position + Vector2(rect.size.x - inset, rect.size.y * 0.50),
		rect.position + Vector2(inset, rect.size.y * 0.73)
	]
	for bracket_index in range(bracket_points.size()):
		var point: Vector2 = bracket_points[bracket_index]
		var horizontal_dir := 1.0 if bracket_index != 1 else -1.0
		target.draw_line(point, point + Vector2(horizontal_dir * bracket_length * 0.42, 0.0), bracket_color, 2.0, true)
		target.draw_line(point + Vector2(horizontal_dir * bracket_length * 0.64, 0.0), point + Vector2(horizontal_dir * bracket_length, 0.0), bracket_color, 2.0, true)
		target.draw_line(point, point + Vector2(0.0, (1.0 if bracket_index < 2 else -1.0) * bracket_length * 0.45), bracket_color, 2.0, true)
	_draw_bug_lag_scanlines(target, rect, visual_seed + 0.9, 0.20 + strength * 0.16, 1.0)

static func _draw_bug_lag_afterimage(target: CanvasItem, texture: Texture2D, rect: Rect2, visual_seed: float, ghost_index: int, alpha: float, stretch: float, visual_frame: int) -> void:
	var slice_count := 9
	var color := Color(0.05, 0.92, 1.0, alpha) if ghost_index % 2 == 0 else Color(1.0, 0.08, 0.68, alpha)
	for slice_index in range(slice_count):
		if (slice_index + ghost_index * 2 + visual_frame) % 5 == 0:
			continue
		var offset := sin(visual_seed + float(slice_index) * 1.37 + float(ghost_index)) * (1.0 + float(ghost_index))
		_draw_bug_lag_texture_slice(target, texture, rect, slice_index, slice_count, offset, stretch, color)

static func _draw_bug_lag_texture_slice(target: CanvasItem, texture: Texture2D, rect: Rect2, slice_index: int, slice_count: int, x_offset: float, stretch: float, modulate: Color) -> void:
	var texture_size := Vector2(texture.get_size())
	var source_height := texture_size.y / float(slice_count)
	var destination_height := rect.size.y / float(slice_count)
	var source := Rect2(0.0, source_height * float(slice_index), texture_size.x, source_height)
	var destination := Rect2(
		rect.position.x + x_offset - stretch * 0.5,
		rect.position.y + destination_height * float(slice_index),
		rect.size.x + stretch,
		destination_height + 0.55
	)
	target.draw_texture_rect_region(texture, destination, source, modulate)

static func _draw_bug_lag_scanlines(target: CanvasItem, rect: Rect2, visual_seed: float, alpha: float, width: float) -> void:
	for line_index in range(5):
		var line_t := fposmod(0.11 + visual_seed * 0.037 + float(line_index) * 0.191, 0.82) + 0.09
		var line_y := rect.position.y + rect.size.y * line_t
		var line_start := rect.position.x + rect.size.x * fposmod(visual_seed * 0.09 + float(line_index) * 0.17, 0.42)
		var line_length := rect.size.x * (0.26 + fposmod(visual_seed + float(line_index) * 0.41, 0.28))
		var color := Color(0.05, 0.94, 1.0, alpha * (0.72 if line_index % 2 == 0 else 0.48)) if line_index % 3 != 1 else Color(1.0, 0.10, 0.65, alpha * 0.62)
		target.draw_line(Vector2(line_start, line_y), Vector2(minf(rect.end.x, line_start + line_length), line_y), color, width, true)

static func _draw_bug_lag_rectangles(target: CanvasItem, rect: Rect2, visual_seed: float, visual_frame: int, alpha: float, count: int) -> void:
	for rect_index in range(count):
		var x_rate := fposmod(visual_seed * 0.071 + float(rect_index) * 0.229 + float(visual_frame) * 0.017, 0.84) + 0.05
		var y_rate := fposmod(visual_seed * 0.113 + float(rect_index) * 0.317, 0.78) + 0.08
		var glitch_size := Vector2(8.0 + float((rect_index + visual_frame) % 3) * 7.0, 2.0 + float(rect_index % 2) * 2.0)
		var glitch_pos := rect.position + Vector2(rect.size.x * x_rate, rect.size.y * y_rate)
		var color := Color(0.02, 0.95, 1.0, alpha * 0.72) if rect_index % 2 == 0 else Color(1.0, 0.06, 0.64, alpha * 0.64)
		target.draw_rect(Rect2(glitch_pos, glitch_size), color, true)

static func draw_enemy_face(target: CanvasItem, face: Dictionary) -> void:
	for part in DrawDataSystemScript.enemy_face_parts():
		DrawPrimitiveSystemScript.draw_simple_draw_part(target, face, part as Dictionary)

static func draw_enemy_hp_bar(target: CanvasItem, bar: Dictionary) -> void:
	for part in DrawDataSystemScript.enemy_hp_bar_parts():
		DrawPrimitiveSystemScript.draw_simple_draw_part(target, bar, part as Dictionary)
