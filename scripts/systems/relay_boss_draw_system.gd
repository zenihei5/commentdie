class_name RelayBossDrawSystem
extends RefCounted

const AttackSystemScript := preload("res://scripts/systems/relay_boss_attack_system.gd")
const MovementSystemScript := preload("res://scripts/systems/relay_boss_movement_system.gd")
const DefenseSystemScript := preload("res://scripts/systems/relay_boss_defense_system.gd")

const OFFLINE_LASER_LENGTH := 900.0
const OFFLINE_LASER_HIT_WIDTH := 26.0
const KUSO_MARO_PROJECTILE_TEXTURE: Texture2D = preload("res://assets/generated/boss_attack_fx_v1/kuso_maro_projectile.png")

static func draw_for_target(target: Node, arena: Rect2) -> void:
	draw_back_for_target(target, arena)
	draw_front_for_target(target, arena)

static func draw_back_for_target(target: Node, arena: Rect2) -> void:
	if not bool(target.get("relay_boss_active")):
		return
	DefenseSystemScript.draw_back_for_target(target, arena)
	if target.has_method("_draw_relay_boss_motion_effects"):
		target.call("_draw_relay_boss_motion_effects", arena)
	var runtime: Dictionary = AttackSystemScript.ensure_for_target(target)
	var active: Dictionary = runtime.get("active_attack", {}) as Dictionary
	var state := String(active.get("state", AttackSystemScript.STATE_IDLE))
	var attack_id := String(active.get("id", ""))
	var payload: Dictionary = active.get("payload", {}) as Dictionary
	if float(target.get("relay_boss_arena_timer")) > 15.0:
		var warning_alpha := 0.24 + sin(float(target.get("elapsed")) * 14.0) * 0.10
		target.call("draw_rect", arena, Color(1.0, 0.35, 0.60, warning_alpha), false, 8.0)
	if state == AttackSystemScript.STATE_TELEGRAPH:
		if attack_id == "noise_summon":
			_draw_noise_summon_warning(target, active, arena, float(active.get("timer", 0.0)), false)
		elif attack_id == "kuso_maro_drop":
			_draw_kuso_maro_drop_warning(target, active, arena, float(active.get("timer", 0.0)), false)
		else:
			_draw_telegraph(target, attack_id, payload, arena, float(active.get("timer", 0.0)), active)
	_draw_noise_summon_visual_effects(target, runtime)
	_draw_hazards(target, runtime.get("hazards", []) as Array, arena)
	_draw_kuso_maro_drop_visual_effects(target, runtime)
	if bool(runtime.get("debug_overlay", false)):
		_draw_debug(target, runtime, arena)

static func draw_front_for_target(target: Node, arena: Rect2) -> void:
	if not bool(target.get("relay_boss_active")):
		return
	DefenseSystemScript.draw_front_for_target(target, arena)
	var runtime: Dictionary = AttackSystemScript.ensure_for_target(target)
	var active: Dictionary = runtime.get("active_attack", {}) as Dictionary
	if String(active.get("state", AttackSystemScript.STATE_IDLE)) == AttackSystemScript.STATE_TELEGRAPH and String(active.get("id", "")) == "noise_summon":
		_draw_noise_summon_warning(target, active, arena, float(active.get("timer", 0.0)), true)
	elif String(active.get("state", AttackSystemScript.STATE_IDLE)) == AttackSystemScript.STATE_TELEGRAPH and String(active.get("id", "")) == "kuso_maro_drop":
		_draw_kuso_maro_drop_warning(target, active, arena, float(active.get("timer", 0.0)), true)
	for item in runtime.get("hazards", []) as Array:
		var hazard: Dictionary = item as Dictionary
		if String(hazard.get("kind", "")) == "offline_laser":
			_draw_offline_laser_foreground(target, hazard, arena)
		elif bool(hazard.get("kusoMaroDropVisual", false)):
			_draw_kuso_maro_drop_foreground(target, hazard, arena)

static func _draw_telegraph(target: Node, attack_id: String, payload: Dictionary, arena: Rect2, timer: float, active: Dictionary) -> void:
	var alpha := clampf(0.30 + sin(timer * 12.0) * 0.12, 0.12, 0.55)
	var color := Color(1.0, 0.34, 0.62, alpha)
	var player_pos := Vector2(target.get("player_pos"))
	match attack_id:
		"comment_shotgun":
			target.call("draw_circle", MovementSystemScript.marker_world_position(target, "ChatModule", arena), 48.0, color, false, 4.0)
		"offline_laser":
			_draw_offline_laser_warning(target, active, arena, timer)
		"race_lane_charge", "long_comment_line":
			for i in range(3):
				var y := arena.position.y + arena.size.y * (0.24 + float(i) * 0.26)
				target.call("draw_line", Vector2(arena.position.x, y), Vector2(arena.end.x, y), color, 24.0)
		"eraser_sweep":
			target.call("draw_rect", Rect2(arena.position.x, arena.position.y, 128.0, arena.size.y), color, true)
		"game_over_barrage":
			target.call("draw_circle", MovementSystemScript.marker_world_position(target, "GameModule", arena), 56.0, color, false, 4.0)
		"howling_ring", "pitch_wave", "rhythm_explosion":
			target.call("draw_circle", MovementSystemScript.marker_world_position(target, "SongModule", arena), 92.0, color, false, 4.0)
		"paint_warning", "dirty_paint":
			target.call("draw_circle", MovementSystemScript.marker_world_position(target, "DrawModule", arena), 96.0, color, false, 4.0)
		"collab_break":
			target.call("draw_circle", MovementSystemScript.marker_world_position(target, "CollabModule", arena), 190.0, color)
		"all_genre_rush":
			target.call("draw_circle", MovementSystemScript.marker_world_position(target, "CoreCenter", arena), 190.0, color)
		_:
			target.call("draw_circle", player_pos, 64.0, color)

static func _kuso_maro_drop_boss_center(target: Node, arena: Rect2) -> Vector2:
	for item in target.get("enemies") as Array:
		var enemy: Dictionary = item as Dictionary
		if bool(enemy.get("relayBoss", false)) or String(enemy.get("bossId", "")) == "last_offline" or String(enemy.get("kind", "")) == "last_offline":
			return Vector2(enemy.get("pos", arena.get_center()))
	return MovementSystemScript.marker_world_position(target, "CoreCenter", arena)

static func _kuso_maro_drop_boss_radius(target: Node) -> float:
	for item in target.get("enemies") as Array:
		var enemy: Dictionary = item as Dictionary
		if bool(enemy.get("relayBoss", false)) or String(enemy.get("bossId", "")) == "last_offline" or String(enemy.get("kind", "")) == "last_offline":
			return maxf(80.0, float(enemy.get("radius", 105.0)))
	return 105.0

static func _kuso_maro_drop_pip_centers(boss_center: Vector2, boss_radius: float) -> Array:
	# Keep the four readable cues just below/around the boss silhouette.  The
	# relay final-boss HUD occupies the upper part of the arena, so a top-only
	# layout would be covered before the warning can be read.
	var layout_radius := clampf(boss_radius * 1.55, 170.0, 210.0)
	var side_offset := clampf(boss_radius * 0.60, 58.0, 78.0)
	var lower_offset := clampf(boss_radius * 1.34, 142.0, 178.0)
	return [
		boss_center + Vector2(-layout_radius, side_offset),
		boss_center + Vector2(-layout_radius * 0.34, lower_offset),
		boss_center + Vector2(layout_radius * 0.34, lower_offset),
		boss_center + Vector2(layout_radius, side_offset)
	]

static func _draw_kuso_maro_drop_warning(target: Node, active: Dictionary, arena: Rect2, timer: float, foreground: bool) -> void:
	var duration := maxf(0.01, float(active.get("kusoMaroDropWarningVisualDuration", (active.get("payload", {}) as Dictionary).get("telegraph", 1.2))))
	var remaining := clampf(timer, 0.0, duration)
	var progress := clampf(1.0 - remaining / duration, 0.0, 1.0)
	var mid := clampf((0.65 - remaining) / 0.45, 0.0, 1.0)
	var late := clampf((0.20 - remaining) / 0.20, 0.0, 1.0)
	var pulse := sin(late * PI)
	var seed := float(active.get("kusoMaroDropWarningVisualSeed", 0.0))
	var boss_center := _kuso_maro_drop_boss_center(target, arena)
	var boss_radius := _kuso_maro_drop_boss_radius(target)
	var pip_centers := _kuso_maro_drop_pip_centers(boss_center, boss_radius)
	var pip_alpha := 0.38 + mid * 0.20 + late * 0.20 + pulse * 0.10
	if not foreground:
		var halo_alpha := 0.035 + mid * 0.025 + late * 0.02
		target.call("draw_circle", boss_center + Vector2(0.0, -boss_radius * 0.42), boss_radius * 0.78, Color(1.0, 0.76, 0.88, halo_alpha), true)
		for i in range(pip_centers.size()):
			var pip: Vector2 = pip_centers[i]
			var puff_offset := Vector2(sin(seed * 5.0 + float(i) * 1.7) * 2.5, cos(seed * 3.0 + float(i) * 1.3) * 2.0)
			target.call("draw_circle", pip + puff_offset, 10.0 + mid * 2.0, Color(1.0, 0.91, 0.96, pip_alpha * 0.24), true)
			target.call("draw_arc", pip + puff_offset, 10.0 + mid * 2.0, seed + float(i) * 0.8, seed + float(i) * 0.8 + 1.9, 8, Color(0.66, 0.28, 0.54, pip_alpha * 0.34), 1.0, true)
			if mid > 0.0:
				var streak_alpha := pip_alpha * (0.30 + mid * 0.28)
				target.call("draw_line", pip + Vector2(0.0, 6.0), pip + Vector2(0.0, -12.0 - mid * 8.0), Color(1.0, 0.78, 0.90, streak_alpha), 1.1, true)
				target.call("draw_line", pip + Vector2(-5.0, -7.0), pip + Vector2(4.0, -15.0), Color(0.48, 0.16, 0.42, streak_alpha * 0.72), 1.0, true)
			if late > 0.0:
				var fragment_dir := Vector2.from_angle(seed * TAU + float(i) * 1.85)
				target.call("draw_line", pip + fragment_dir * 11.0, pip + fragment_dir * (16.0 + late * 6.0), Color(0.72, 0.25, 0.56, pip_alpha * late * 0.70), 1.0, true)
		return
	for i in range(pip_centers.size()):
		var pip: Vector2 = pip_centers[i]
		var pip_scale := 1.0 + pulse * 0.16
		var pip_radius := 7.0 * pip_scale
		target.call("draw_circle", pip, pip_radius, Color(1.0, 0.88, 0.94, pip_alpha), true)
		target.call("draw_arc", pip, pip_radius + 1.8, seed + float(i) * 0.9, seed + float(i) * 0.9 + 4.3, 12, Color(0.48, 0.13, 0.39, pip_alpha * 0.78), 1.3, true)
		target.call("draw_arc", pip, pip_radius - 2.0, seed + float(i) * 0.9 + 0.5, seed + float(i) * 0.9 + 2.2, 8, Color(1.0, 0.99, 1.0, pip_alpha * 0.72), 1.0, true)
		target.call("draw_line", pip + Vector2(-3.0, 2.0), pip + Vector2(4.0, -2.0), Color(0.72, 0.26, 0.58, pip_alpha * 0.70), 1.0, true)
		if late > 0.0:
			var flash_alpha := pulse * (0.40 + late * 0.34)
			target.call("draw_line", pip + Vector2(0.0, -pip_radius - 4.0), pip + Vector2(0.0, -pip_radius - 14.0), Color(1.0, 0.96, 1.0, flash_alpha), 1.4, true)
			target.call("draw_circle", pip, pip_radius + 4.0 + pulse * 2.0, Color(1.0, 0.80, 0.92, flash_alpha * 0.14), false, 1.0)
	if late > 0.0:
		var boss_flash := boss_center + Vector2(0.0, -boss_radius - 13.0)
		target.call("draw_line", boss_flash - Vector2(13.0, 0.0), boss_flash + Vector2(13.0, 0.0), Color(1.0, 0.96, 1.0, pulse * 0.54), 1.6, true)
		target.call("draw_line", boss_flash + Vector2(0.0, -10.0), boss_flash + Vector2(0.0, 8.0), Color(1.0, 0.76, 0.90, pulse * 0.42), 1.2, true)

static func _kuso_maro_drop_nearby_count(hazards: Array, pos: Vector2) -> int:
	var count := 0
	for item in hazards:
		var hazard: Dictionary = item as Dictionary
		if not bool(hazard.get("kusoMaroDropVisual", false)):
			continue
		if Vector2(hazard.get("pos", Vector2.ZERO)).distance_to(pos) <= 104.0:
			count += 1
	return maxi(1, count)

static func _draw_kuso_maro_shadow(target: Node, pos: Vector2, radius: float, scale_x: float, alpha: float) -> void:
	# Build the flattened shadow in world coordinates so the relay world
	# transform remains untouched for the following hazards and draw passes.
	var points := PackedVector2Array()
	for i in range(24):
		var angle := TAU * float(i) / 24.0
		points.append(pos + Vector2(cos(angle) * radius * scale_x, sin(angle) * radius * 0.46))
	target.call("draw_colored_polygon", points, Color(0.24, 0.08, 0.20, alpha))

static func _draw_kuso_maro_drop_hazard(target: Node, hazard: Dictionary, hazards: Array) -> void:
	var pos := Vector2(hazard.get("pos", Vector2.ZERO))
	var radius := maxf(1.0, float(hazard.get("radius", 52.0)))
	var max_time := maxf(0.01, float(hazard.get("maxTime", 0.65)))
	var remaining := clampf(float(hazard.get("time", 0.0)), 0.0, max_time)
	var elapsed := clampf(max_time - remaining, 0.0, max_time)
	var impact_duration := clampf(float(hazard.get("kusoMaroDropImpactDuration", 0.16)), 0.10, 0.18)
	var impact_progress := clampf(elapsed / impact_duration, 0.0, 1.0)
	var impact_eased := smoothstep(0.0, 1.0, impact_progress)
	var seed := float(hazard.get("kusoMaroDropVisualSeed", 0.0))
	var nearby_count := _kuso_maro_drop_nearby_count(hazards, pos)
	var interior_factor := 1.0 / (1.0 + float(maxi(0, nearby_count - 1)) * 0.28)
	var lifetime_factor := 0.78 + clampf(remaining / max_time, 0.0, 1.0) * 0.22
	# The fill and stain are intentionally quiet; the 52px boundary is the
	# authoritative gameplay geometry and remains undimmed in overlaps.
	target.call("draw_circle", pos, radius - 2.0, Color(1.0, 0.94, 0.82, 0.055 * interior_factor), true)
	target.call("draw_circle", pos + Vector2(0.0, 2.0), radius * 0.68, Color(1.0, 0.72, 0.82, 0.035 * interior_factor), true)
	target.call("draw_arc", pos, radius - 1.0, 0.0, TAU, 64, Color(0.28, 0.04, 0.25, 0.88 * lifetime_factor), 2.0, true)
	target.call("draw_arc", pos, radius - 2.3, 0.03, TAU - 0.03, 64, Color(1.0, 0.68, 0.82, 0.74 * lifetime_factor), 1.0, true)
	var notch := fposmod(seed * TAU * 1.7, TAU)
	for i in range(3):
		var stain_start := notch + float(i) * 2.02 + 0.14
		var stain_end := stain_start + 0.52 + float(i % 2) * 0.18
		target.call("draw_arc", pos, radius - 7.0 - float(i) * 4.0, stain_start, stain_end, 10, Color(0.65, 0.28, 0.54, 0.17 * interior_factor), 2.0, true)
	_draw_kuso_maro_shadow(target, pos + Vector2(0.0, 8.0), 14.0 - impact_eased * 2.5, 1.20 + (1.0 - impact_eased) * 0.10, 0.20 * interior_factor)
	var maro_offset := Vector2(0.0, -10.0 * (1.0 - impact_eased))
	var maro_scale := Vector2(1.12 - impact_eased * 0.12, 0.82 + impact_eased * 0.18)
	var maro_pos := pos + maro_offset
	var maro_size := Vector2(40.0, 40.0) * maro_scale
	target.call("draw_texture_rect", KUSO_MARO_PROJECTILE_TEXTURE, Rect2(maro_pos - maro_size * 0.5, maro_size), false, Color(1.0, 1.0, 1.0, 0.96))
	if impact_progress < 1.0:
		var streak_alpha := (1.0 - impact_progress) * 0.68
		target.call("draw_line", pos + Vector2(-2.0, -radius * 0.72 - (1.0 - impact_progress) * 18.0), pos + Vector2(-2.0, -radius * 0.42), Color(1.0, 0.94, 0.98, streak_alpha), 1.6, true)
		target.call("draw_line", pos + Vector2(4.0, -radius * 0.66 - (1.0 - impact_progress) * 12.0), pos + Vector2(4.0, -radius * 0.48), Color(1.0, 0.62, 0.82, streak_alpha * 0.72), 1.0, true)
	var gloss_angle := seed * TAU + 0.7
	var gloss_dir := Vector2.from_angle(gloss_angle)
	target.call("draw_line", maro_pos - gloss_dir * 5.0, maro_pos + gloss_dir * 2.0, Color(1.0, 1.0, 1.0, 0.35 * lifetime_factor), 1.0, true)

static func _draw_kuso_maro_drop_foreground(target: Node, hazard: Dictionary, arena: Rect2) -> void:
	var pos := Vector2(hazard.get("pos", Vector2.ZERO))
	var player_pos := Vector2(target.get("player_pos"))
	var distance := player_pos.distance_to(pos)
	if distance > 116.0:
		return
	var direction := (player_pos - pos).normalized()
	if direction.length_squared() <= 0.01:
		direction = Vector2.UP
	var angle := direction.angle()
	var seed := float(hazard.get("kusoMaroDropVisualSeed", 0.0))
	var phase := fposmod(seed * 4.0, 1.0)
	var start := angle - 0.92 + phase * 0.18
	var end := angle + 0.92 + phase * 0.18
	target.call("draw_arc", pos, 51.0, start, end, 20, Color(0.30, 0.04, 0.27, 0.46), 2.0, true)
	target.call("draw_arc", pos, 49.7, start + 0.06, end - 0.06, 18, Color(1.0, 0.78, 0.88, 0.36), 1.0, true)
	target.call("draw_circle", pos, 2.0, Color(1.0, 0.92, 0.96, 0.32), true)

static func _draw_kuso_maro_drop_visual_effects(target: Node, runtime: Dictionary) -> void:
	for item in runtime.get("kuso_maro_drop_visual_effects", []) as Array:
		var effect: Dictionary = item as Dictionary
		var kind := String(effect.get("kind", ""))
		if not kind.begins_with("kuso_maro_drop_"):
			continue
		var max_life := maxf(0.01, float(effect.get("maxLife", 0.20)))
		var life := clampf(float(effect.get("life", 0.0)), 0.0, max_life)
		if life <= 0.0:
			continue
		var fade := life / max_life
		var progress := 1.0 - fade
		var burst := sin(clampf(progress * PI, 0.0, PI))
		var pos := Vector2(effect.get("pos", Vector2.ZERO))
		var seed := float(effect.get("visualSeed", 0.0))
		if kind == "kuso_maro_drop_impact":
			var radius := 10.0 + burst * 8.0
			target.call("draw_arc", pos, radius, seed + 0.15, seed + 2.05, 16, Color(1.0, 0.94, 0.88, 0.52 * fade), 1.5, true)
			target.call("draw_arc", pos, radius + 3.0, seed + 2.45, seed + 4.05, 13, Color(0.72, 0.48, 0.72, 0.34 * fade), 1.2, true)
			target.call("draw_circle", pos + Vector2(0.0, 1.0), 3.0 + burst * 2.0, Color(1.0, 0.88, 0.82, 0.20 * fade), true)
			for i in range(3):
				var angle := seed + float(i) * 2.1
				var direction := Vector2.from_angle(angle)
				var center := pos + direction * (11.0 + burst * 8.0)
				target.call("draw_line", center - direction * 3.0, center + direction * (4.0 + burst * 2.0), Color(0.72, 0.30, 0.60, 0.52 * fade), 1.1, true)
		elif kind == "kuso_maro_drop_hit":
			var radius := 9.0 + burst * 10.0
			target.call("draw_arc", pos, radius, seed, seed + 2.7, 18, Color(1.0, 0.96, 0.92, 0.64 * fade), 1.7, true)
			target.call("draw_arc", pos, radius + 4.0, seed + 3.0, seed + 4.9, 14, Color(0.70, 0.36, 0.66, 0.48 * fade), 1.4, true)
			for i in range(3):
				var angle := seed + 0.6 + float(i) * 2.0
				var direction := Vector2.from_angle(angle)
				var center := pos + direction * (10.0 + burst * 10.0)
				target.call("draw_line", center - direction * 4.0, center + direction * 4.0, Color(0.82, 0.50, 0.76, 0.56 * fade), 1.3, true)
			target.call("draw_circle", pos, 3.0 + burst * 3.0, Color(1.0, 0.96, 0.98, 0.18 * fade), true)

static func _draw_offline_laser_warning(target: Node, active: Dictionary, arena: Rect2, timer: float) -> void:
	if not bool(active.get("offlineLaserSnapshotValid", false)):
		return
	var origin := Vector2(active.get("offlineLaserOrigin", Vector2.ZERO))
	var direction := Vector2(active.get("offlineLaserDir", Vector2.DOWN))
	if direction.length_squared() <= 0.01:
		direction = Vector2.DOWN
	else:
		direction = direction.normalized()
	var endpoint := Vector2(active.get("offlineLaserEndpoint", origin + direction * OFFLINE_LASER_LENGTH))
	if endpoint.distance_squared_to(origin) <= 0.01:
		endpoint = origin + direction * OFFLINE_LASER_LENGTH
	var side := Vector2(-direction.y, direction.x)
	var progress := 1.0 - clampf(timer / 1.10, 0.0, 1.0)
	var late := clampf((0.18 - timer) / 0.18, 0.0, 1.0)
	var seed := float(active.get("offlineLaserVisualSeed", 0.0))
	var strength := 0.50 + late * 0.18
	# The broad corridor is deliberately only a low-alpha underlay. The two
	# rails below are the readable 52px gameplay boundary.
	target.call("draw_line", origin, endpoint, Color(0.20, 0.02, 0.18, 0.035 + late * 0.02), 52.0, true)
	target.call("draw_line", origin, endpoint, Color(0.92, 0.06, 0.36, 0.08 + late * 0.03), 34.0, true)
	_draw_offline_laser_rail(target, origin + side * OFFLINE_LASER_HIT_WIDTH, endpoint + side * OFFLINE_LASER_HIT_WIDTH, -side, strength, false)
	_draw_offline_laser_rail(target, origin - side * OFFLINE_LASER_HIT_WIDTH, endpoint - side * OFFLINE_LASER_HIT_WIDTH, side, strength, false)
	_draw_offline_laser_signal(target, origin, endpoint, side, seed, progress, false)
	_draw_offline_laser_endcaps(target, origin, endpoint, direction, strength, false)
	if arena.has_point(endpoint):
		_draw_offline_laser_endpoint(target, endpoint, direction, seed, false, late)
	_draw_offline_laser_tracking_marker(target, Vector2(active.get("offlineLaserAimPoint", endpoint)), direction, side, late, seed, arena)

static func _draw_offline_laser_rail(target: Node, from_pos: Vector2, to_pos: Vector2, inward: Vector2, strength: float, active: bool) -> void:
	var edge_alpha := (0.62 if active else 0.48) * strength
	var edge_width := 2.45 if active else 2.15
	target.call("draw_line", from_pos, to_pos, Color(0.30, 0.01, 0.22, edge_alpha), edge_width, true)
	target.call("draw_line", from_pos, to_pos, Color(0.92, 0.04, 0.35, edge_alpha * 0.70), 1.15, true)
	var inner_offset := inward.normalized() * 1.15
	target.call("draw_line", from_pos + inner_offset, to_pos + inner_offset, Color(1.0, 0.72, 0.88, edge_alpha * 0.72), 0.95, true)

static func _draw_offline_laser_signal(target: Node, from_pos: Vector2, to_pos: Vector2, side: Vector2, seed: float, progress: float, active: bool) -> void:
	var segment := to_pos - from_pos
	var length := segment.length()
	if length <= 0.1:
		return
	var direction := segment / length
	var gap_start := 0.36 + fposmod(seed * 0.19, 0.12)
	var gap_size := 0.055 if active else 0.038
	var gap_end := minf(0.92, gap_start + gap_size)
	var first_end := from_pos + segment * gap_start
	var second_start := from_pos + segment * gap_end
	var core_alpha := (0.76 if active else 0.52) + progress * (0.12 if active else 0.08)
	target.call("draw_line", from_pos, first_end, Color(0.42, 0.98, 1.0, core_alpha), 2.8 if active else 2.25, true)
	target.call("draw_line", second_start, to_pos, Color(0.94, 0.98, 1.0, core_alpha * 0.88), 2.4 if active else 1.95, true)
	var crack_center := from_pos + segment * ((gap_start + gap_end) * 0.5)
	target.call("draw_line", crack_center - side * (3.0 if active else 2.0), crack_center + side * (3.0 if active else 2.0), Color(1.0, 0.35, 0.70, core_alpha * 0.78), 1.25, true)
	var fragment_count := 3 if active else 2
	for i in range(fragment_count):
		var t := fposmod(seed * 0.73 + float(i) * 0.29 + progress * (0.22 if active else 0.08), 0.86) + 0.07
		var center := from_pos + segment * t
		var half_length := 5.0 + float(i % 2) * 2.0
		var offset := side * ((-1.0 if i % 2 == 0 else 1.0) * (2.0 + float(i)))
		target.call("draw_line", center - direction * half_length + offset, center + direction * half_length + offset, Color(0.32, 0.91, 1.0, core_alpha * 0.58), 1.15, true)

static func _draw_offline_laser_tracking_marker(target: Node, aim_point: Vector2, direction: Vector2, side: Vector2, late: float, seed: float, arena: Rect2) -> void:
	if not arena.grow(48.0).has_point(aim_point):
		return
	var pulse := 0.65 + 0.35 * sin(seed * TAU + late * TAU * 2.0)
	var along := direction * 8.0
	var rail_span := side * 9.0
	var color := Color(0.35, 0.96, 1.0, 0.48 + late * 0.18)
	target.call("draw_line", aim_point - along - rail_span, aim_point - along + rail_span, color, 1.4, true)
	target.call("draw_line", aim_point + along - rail_span, aim_point + along + rail_span, color, 1.4, true)
	target.call("draw_line", aim_point - rail_span * 0.72, aim_point + rail_span * 0.72, Color(1.0, 0.38, 0.70, 0.32 + late * 0.16), 1.1, true)
	target.call("draw_circle", aim_point - direction * 12.0, 2.2 + late * 1.0, Color(1.0, 0.74, 0.90, 0.55 * pulse), true)
	target.call("draw_circle", aim_point + direction * 12.0, 1.8 + late * 0.8, Color(1.0, 0.26, 0.62, 0.46 * pulse), true)

static func _draw_offline_laser_endcaps(target: Node, origin: Vector2, endpoint: Vector2, direction: Vector2, strength: float, active: bool) -> void:
	var color := Color(0.52, 0.04, 0.35, (0.72 if active else 0.44) * strength)
	var highlight := Color(1.0, 0.55, 0.82, (0.42 if active else 0.28) * strength)
	for i in range(2):
		var center := origin if i == 0 else endpoint
		var facing := direction.angle() + (PI if i == 0 else 0.0)
		target.call("draw_arc", center, OFFLINE_LASER_HIT_WIDTH, facing - 0.92, facing - 0.18, 10, color, 2.1 if active else 1.8, true)
		target.call("draw_arc", center, OFFLINE_LASER_HIT_WIDTH, facing + 0.18, facing + 0.92, 10, highlight, 0.9, true)

static func _draw_offline_laser_endpoint(target: Node, endpoint: Vector2, direction: Vector2, seed: float, active: bool, late: float) -> void:
	var side := Vector2(-direction.y, direction.x)
	var alpha := (0.68 if active else 0.46) + late * 0.14
	var offset := side * (3.0 + fposmod(seed * 7.0, 3.0))
	target.call("draw_line", endpoint - direction * 12.0 - offset, endpoint - direction * 3.0 - offset, Color(0.28, 0.94, 1.0, alpha), 1.8, true)
	target.call("draw_line", endpoint + direction * 3.0 + offset, endpoint + direction * 12.0 + offset, Color(0.28, 0.94, 1.0, alpha * 0.82), 1.5, true)
	target.call("draw_line", endpoint - side * 8.0, endpoint + side * 8.0, Color(1.0, 0.27, 0.64, alpha * 0.72), 1.4, true)
	target.call("draw_circle", endpoint, 2.0 if active else 1.5, Color(1.0, 0.93, 0.98, alpha), true)

static func _draw_offline_laser_active(target: Node, hazard: Dictionary, arena: Rect2) -> void:
	var from_pos := Vector2(hazard.get("from", Vector2.ZERO))
	var to_pos := Vector2(hazard.get("to", from_pos))
	var segment := to_pos - from_pos
	if segment.length_squared() <= 0.01:
		return
	var direction := segment.normalized()
	var side := Vector2(-direction.y, direction.x)
	var max_time := maxf(0.1, float(hazard.get("maxTime", 0.8)))
	var remaining := clampf(float(hazard.get("time", 0.0)) / max_time, 0.0, 1.0)
	var intensity := 0.60 + remaining * 0.40
	var seed := float(hazard.get("offlineLaserVisualSeed", 0.0))
	target.call("draw_line", from_pos, to_pos, Color(0.12, 0.01, 0.16, 0.15 * intensity), 52.0, true)
	target.call("draw_line", from_pos, to_pos, Color(0.28, 0.01, 0.24, 0.78 * intensity), 30.0, true)
	target.call("draw_line", from_pos, to_pos, Color(0.95, 0.04, 0.42, 0.78 * intensity), 24.0, true)
	target.call("draw_line", from_pos, to_pos, Color(1.0, 0.27, 0.64, 0.68 * intensity), 14.0, true)
	target.call("draw_line", from_pos, to_pos, Color(1.0, 0.96, 1.0, 0.76 * intensity), 5.8 - remaining * 0.8, true)
	_draw_offline_laser_rail(target, from_pos + side * OFFLINE_LASER_HIT_WIDTH, to_pos + side * OFFLINE_LASER_HIT_WIDTH, -side, intensity, true)
	_draw_offline_laser_rail(target, from_pos - side * OFFLINE_LASER_HIT_WIDTH, to_pos - side * OFFLINE_LASER_HIT_WIDTH, side, intensity, true)
	_draw_offline_laser_signal(target, from_pos, to_pos, side, seed, 1.0 - remaining, true)
	_draw_offline_laser_endcaps(target, from_pos, to_pos, direction, intensity, true)
	if arena.has_point(to_pos):
		_draw_offline_laser_endpoint(target, to_pos, direction, seed, true, 0.0)

static func _draw_offline_laser_foreground(target: Node, hazard: Dictionary, arena: Rect2) -> void:
	var from_pos := Vector2(hazard.get("from", Vector2.ZERO))
	var to_pos := Vector2(hazard.get("to", from_pos))
	var segment := to_pos - from_pos
	var length_sq := segment.length_squared()
	if length_sq <= 0.01:
		return
	var player_pos := Vector2(target.get("player_pos"))
	var ratio := clampf((player_pos - from_pos).dot(segment) / length_sq, 0.0, 1.0)
	var closest := from_pos + segment * ratio
	if closest.distance_to(player_pos) > 132.0:
		return
	var direction := segment.normalized()
	var side := Vector2(-direction.y, direction.x)
	var local_from := from_pos + segment * clampf(ratio - 0.105, 0.0, 1.0)
	var local_to := from_pos + segment * clampf(ratio + 0.105, 0.0, 1.0)
	var seed := float(hazard.get("offlineLaserVisualSeed", 0.0))
	_draw_offline_laser_rail(target, local_from + side * OFFLINE_LASER_HIT_WIDTH, local_to + side * OFFLINE_LASER_HIT_WIDTH, -side, 0.55, true)
	_draw_offline_laser_rail(target, local_from - side * OFFLINE_LASER_HIT_WIDTH, local_to - side * OFFLINE_LASER_HIT_WIDTH, side, 0.55, true)
	target.call("draw_line", local_from, local_to, Color(1.0, 0.96, 1.0, 0.34), 2.5, true)
	_draw_offline_laser_signal(target, local_from, local_to, side, seed + 0.17, 0.7, true)

static func _draw_hazards(target: Node, hazards: Array, arena: Rect2) -> void:
	for item in hazards:
		var hazard: Dictionary = item as Dictionary
		if String(hazard.get("kind", "")) == "offline_laser":
			_draw_offline_laser_active(target, hazard, arena)
			continue
		if bool(hazard.get("kusoMaroDropVisual", false)):
			_draw_kuso_maro_drop_hazard(target, hazard, hazards)
			continue
		var alpha := clampf(float(hazard.get("time", 0.0)) / maxf(0.1, float(hazard.get("maxTime", 1.0))), 0.25, 0.85)
		var color := Color(1.0, 0.24, 0.52, alpha)
		match String(hazard.get("shape", "circle")):
			"circle":
				target.call("draw_circle", Vector2(hazard.get("pos", Vector2.ZERO)), float(hazard.get("radius", 30.0)), color)
			"ring":
				target.call("draw_arc", Vector2(hazard.get("pos", Vector2.ZERO)), float(hazard.get("radius", 100.0)), 0.0, TAU, 48, color, float(hazard.get("width", 18.0)))
			"line":
				target.call("draw_line", Vector2(hazard.get("from", Vector2.ZERO)), Vector2(hazard.get("to", Vector2.ZERO)), color, float(hazard.get("width", 20.0)))
			"rect":
				target.call("draw_rect", Rect2(Vector2(hazard.get("pos", Vector2.ZERO)), Vector2(hazard.get("size", Vector2(80.0, 80.0)))), color, true)

static func _noise_visual_hash(seed: float, salt: int) -> float:
	return fposmod(sin(seed * 12.9898 + float(salt) * 78.233) * 43758.5453, 1.0)

static func _draw_noise_summon_warning(target: Node, active: Dictionary, arena: Rect2, timer: float, foreground: bool) -> void:
	var marker := MovementSystemScript.marker_world_position(target, "ChatModule", arena)
	var duration := maxf(0.01, float(active.get("noiseSummonWarningVisualDuration", (active.get("payload", {}) as Dictionary).get("telegraph", 1.0))))
	var remaining := clampf(timer, 0.0, duration)
	var progress := clampf(1.0 - remaining / duration, 0.0, 1.0)
	var seed := float(active.get("noiseSummonWarningVisualSeed", 0.0))
	var mid := smoothstep(0.45, 0.82, progress)
	var final_pulse := smoothstep(0.85, 1.0, progress)
	var pulse := sin(final_pulse * PI)
	var ring_radius := 58.0 + mid * 4.0 + pulse * 3.0
	var alpha := (0.26 + mid * 0.20 + final_pulse * 0.15) * (0.72 if foreground else 1.0)
	if not foreground:
		target.call("draw_circle", marker, ring_radius - 3.0, Color(0.05, 0.02, 0.13, 0.025 + mid * 0.018), true)
	for i in range(5):
		var segment_start := seed + float(i) * TAU / 5.0 + progress * (0.22 if i % 2 == 0 else -0.15)
		var gap := 0.18 + mid * 0.17 + (0.08 if i == 2 else 0.0)
		var segment_end := segment_start + TAU / 5.0 * (0.62 - gap * 0.20)
		var color := Color(0.24, 0.90, 1.0, alpha * (0.86 if i % 2 == 0 else 0.54)) if i % 2 == 0 else Color(0.98, 0.20, 0.64, alpha * 0.76)
		target.call("draw_arc", marker, ring_radius, segment_start, segment_end, 10, color, 1.8 if not foreground else 1.35, true)
		if mid > 0.0:
			var offset_dir := Vector2.from_angle(segment_start)
			target.call("draw_line", marker + offset_dir * (ring_radius - 8.0), marker + offset_dir * (ring_radius + 5.0), Color(0.72, 0.88, 1.0, alpha * 0.55), 1.0, true)
	if foreground:
		# A small front rim keeps the boss-side cue legible without moving the
		# pending positions or painting a full overlay over the boss sprite.
		for i in range(3):
			var bar_angle := seed + float(i) * 2.1 + 0.4
			var bar_dir := Vector2.from_angle(bar_angle)
			target.call("draw_line", marker + bar_dir * (ring_radius - 5.0), marker + bar_dir * (ring_radius + 7.0), Color(0.78, 0.96, 1.0, alpha * 0.66), 1.0, true)
		if final_pulse > 0.0:
			target.call("draw_line", marker - Vector2(13.0, 0.0), marker + Vector2(13.0, 0.0), Color(1.0, 0.94, 1.0, pulse * 0.50), 1.2, true)
		# ChatModule is the authoritative attack-side marker.  It sits under the
		# final-boss HUD in the default camera, so add only a tiny, boss-attached
		# signal badge in the foreground; this never exposes pending positions or
		# changes the gameplay origin.
		var boss_pos := marker
		var boss_radius := 105.0
		for item in target.get("enemies") as Array:
			var enemy: Dictionary = item as Dictionary
			if bool(enemy.get("relayBoss", false)):
				boss_pos = Vector2(enemy.get("pos", marker))
				boss_radius = maxf(80.0, float(enemy.get("radius", boss_radius)))
				break
		var badge := boss_pos + Vector2(0.0, boss_radius + 30.0)
		var badge_alpha := alpha * 0.78
		target.call("draw_arc", badge, 17.0 + pulse * 2.0, seed + 0.35, seed + 1.30, 7, Color(0.24, 0.90, 1.0, badge_alpha * 0.72), 1.2, true)
		target.call("draw_arc", badge, 17.0 + pulse * 2.0, seed + 2.10, seed + 3.00, 6, Color(0.98, 0.20, 0.64, badge_alpha * 0.68), 1.3, true)
		target.call("draw_line", badge + Vector2(-7.0, 0.0), badge + Vector2(-2.0, 0.0), Color(0.92, 0.98, 1.0, badge_alpha * 0.74), 1.0, true)
		target.call("draw_line", badge + Vector2(3.0, 0.0), badge + Vector2(8.0, 0.0), Color(0.92, 0.98, 1.0, badge_alpha * 0.74), 1.0, true)
		return
	var block_offsets := [
		Vector2(-34.0, -21.0), Vector2(27.0, -29.0), Vector2(42.0, 12.0), Vector2(-19.0, 34.0)
	]
	for i in range(block_offsets.size()):
		var block_offset: Vector2 = block_offsets[i].rotated(seed * 0.08)
		var jitter := (_noise_visual_hash(seed, 20 + i) - 0.5) * 5.0
		var block_pos := marker + block_offset + Vector2(jitter, -jitter * 0.35)
		var block_size := Vector2(5.0 + float(i % 2) * 3.0, 2.0 + float((i + 1) % 2) * 2.0)
		var block_alpha := alpha * (0.35 + mid * 0.55 + final_pulse * 0.24) * (0.86 if i != 2 else 0.58)
		var block_color := Color(0.08, 0.03, 0.18, block_alpha) if i % 2 == 0 else Color(0.96, 0.22, 0.66, block_alpha * 0.72)
		target.call("draw_rect", Rect2(block_pos - block_size * 0.5, block_size), block_color, true)
	var scan_positions := [Vector2(-20.0, -8.0), Vector2(8.0, 4.0), Vector2(-7.0, 17.0)]
	for i in range(scan_positions.size()):
		var scan_pos: Vector2 = marker + scan_positions[i]
		var scan_half := 10.0 + float(i % 2) * 5.0
		target.call("draw_line", scan_pos - Vector2(scan_half, 0.0), scan_pos + Vector2(scan_half, 0.0), Color(0.82, 0.95, 1.0, alpha * (0.24 + mid * 0.28)), 0.9, true)
	if mid > 0.0:
		var fracture_side := Vector2(0.58, -0.82).rotated(seed * 0.13)
		target.call("draw_line", marker - fracture_side * 12.0, marker - fracture_side * 3.0, Color(0.04, 0.02, 0.10, alpha * 0.72), 2.0, true)
		target.call("draw_line", marker + fracture_side * 2.0, marker + fracture_side * 10.0, Color(0.04, 0.02, 0.10, alpha * 0.72), 2.0, true)
	if final_pulse > 0.0:
		var collapse_dir := Vector2.from_angle(seed + 0.7)
		target.call("draw_line", marker - collapse_dir * 20.0, marker - collapse_dir * 5.0, Color(0.32, 0.94, 1.0, final_pulse * 0.68), 1.5, true)
		target.call("draw_line", marker + collapse_dir * 5.0, marker + collapse_dir * 20.0, Color(1.0, 0.24, 0.70, final_pulse * 0.62), 1.5, true)

static func _draw_noise_summon_visual_effects(target: Node, runtime: Dictionary) -> void:
	for item in runtime.get("noise_summon_visual_effects", []) as Array:
		var effect: Dictionary = item as Dictionary
		var kind := String(effect.get("kind", ""))
		if not kind.begins_with("relay_noise_summon_"):
			continue
		var max_life := maxf(0.01, float(effect.get("maxLife", 0.2)))
		var life := clampf(float(effect.get("life", 0.0)), 0.0, max_life)
		if life <= 0.0:
			continue
		var fade := life / max_life
		var seed := float(effect.get("visualSeed", 0.0))
		var pos := Vector2(effect.get("pos", Vector2.ZERO))
		var strength := clampf(float(effect.get("strength", 1.0)), 0.0, 1.0)
		var alpha := fade * strength
		if kind == "relay_noise_summon_spawn":
			var progress := 1.0 - fade
			var burst := sin(clampf(progress * PI, 0.0, PI))
			var radius := 17.0 + burst * 5.0
			target.call("draw_arc", pos, radius, seed + 0.2, seed + 1.75, 12, Color(0.24, 0.88, 1.0, 0.72 * alpha), 1.8, true)
			target.call("draw_arc", pos, radius + 3.0, seed + 2.05, seed + 3.25, 10, Color(1.0, 0.20, 0.68, 0.62 * alpha), 1.5, true)
			target.call("draw_line", pos + Vector2(-radius * 0.72, -2.0), pos + Vector2(radius * 0.64, -2.0), Color(1.0, 0.96, 1.0, (0.42 + burst * 0.32) * alpha), 1.1, true)
			for i in range(4):
				var angle := seed + float(i) * 1.57 + 0.24
				var block_pos := pos + Vector2.from_angle(angle) * (13.0 + burst * 8.0)
				var block_size := Vector2(4.0 + float(i % 2) * 2.0, 2.0 + float((i + 1) % 2))
				target.call("draw_rect", Rect2(block_pos - block_size * 0.5, block_size), Color(0.08, 0.02, 0.16, 0.50 * alpha), true)
			for i in range(3):
				var fragment_dir := Vector2.from_angle(seed + 0.8 + float(i) * 2.0)
				var fragment_pos := pos + fragment_dir * (15.0 + burst * 12.0)
				target.call("draw_line", fragment_pos - fragment_dir * 4.0, fragment_pos + fragment_dir * 2.0, Color(0.96, 0.26, 0.72, 0.58 * alpha), 1.1, true)
		elif kind == "relay_noise_summon_boss_cue":
			var burst := sin(clampf((1.0 - fade) * PI, 0.0, PI))
			target.call("draw_arc", pos, 42.0 + burst * 5.0, seed + 0.1, seed + 1.5, 14, Color(0.25, 0.88, 1.0, 0.60 * alpha), 1.5, true)
			target.call("draw_arc", pos, 48.0 + burst * 4.0, seed + 2.0, seed + 3.25, 12, Color(0.96, 0.22, 0.68, 0.55 * alpha), 1.8, true)
			target.call("draw_line", pos - Vector2(8.0, 0.0), pos + Vector2(8.0, 0.0), Color(1.0, 0.96, 1.0, 0.42 * alpha), 1.2, true)
		elif kind == "relay_noise_summon_contact":
			var burst := sin(clampf((1.0 - fade) * PI, 0.0, PI))
			target.call("draw_circle", pos, 9.0 + burst * 5.0, Color(1.0, 0.96, 1.0, 0.28 * alpha), true)
			target.call("draw_line", pos + Vector2(-15.0, -4.0), pos + Vector2(-4.0, 0.0), Color(0.24, 0.90, 1.0, 0.72 * alpha), 1.5, true)
			target.call("draw_line", pos + Vector2(4.0, 1.0), pos + Vector2(16.0, 5.0), Color(1.0, 0.22, 0.68, 0.70 * alpha), 1.5, true)
			target.call("draw_line", pos + Vector2(-7.0, 8.0), pos + Vector2(8.0, 8.0), Color(0.08, 0.02, 0.16, 0.60 * alpha), 1.2, true)
		elif kind == "relay_noise_summon_defeat":
			var collapse := 1.0 - fade
			var radius := lerpf(23.0, 9.0, collapse)
			target.call("draw_arc", pos, radius, seed + 0.15, seed + 1.7, 12, Color(0.24, 0.90, 1.0, 0.56 * alpha), 1.6, true)
			target.call("draw_arc", pos, radius + 3.0, seed + 2.0, seed + 3.3, 10, Color(1.0, 0.20, 0.68, 0.50 * alpha), 1.4, true)
			for i in range(4):
				var fragment_dir := Vector2.from_angle(seed + float(i) * 1.57)
				var fragment_pos := pos + fragment_dir * (8.0 + collapse * 16.0)
				target.call("draw_rect", Rect2(fragment_pos - Vector2(3.0, 1.4), Vector2(6.0, 2.8)), Color(0.08, 0.02, 0.16, 0.64 * alpha), true)
			target.call("draw_line", pos - Vector2(10.0, 0.0), pos + Vector2(10.0, 0.0), Color(1.0, 0.96, 1.0, 0.52 * alpha), 1.0, true)

static func _draw_debug(target: Node, runtime: Dictionary, arena: Rect2) -> void:
	var active: Dictionary = runtime.get("active_attack", {}) as Dictionary
	var movement: Dictionary = MovementSystemScript.ensure_for_target(target)
	var balance: Dictionary = target.get("balance_debug_last") as Dictionary
	var stats: Dictionary = balance.get("balanceStats", {}) as Dictionary
	var text := "BOSS FSM %s  %s  %.1fs  hazards:%d  reuse:%d" % [
		String(active.get("state", AttackSystemScript.STATE_IDLE)).to_upper(),
		String(active.get("id", "IDLE")),
		float(active.get("timer", 0.0)),
		(runtime.get("hazards", []) as Array).size(),
		(runtime.get("reuse_cooldowns", {}) as Dictionary).size()
	]
	if target.has_method("_draw_outlined_text"):
		target.call("_draw_outlined_text", arena.position + Vector2(18.0, 32.0), text, 700, 14, Color.WHITE, Color("#37102d"), HORIZONTAL_ALIGNMENT_LEFT)
		var movement_text := "MOVE %s  anchor:%s -> %s  attacks:%d  %.1fs  target:(%.0f,%.0f) locked:(%.0f,%.0f)" % [
			String(movement.get("state", MovementSystemScript.STATE_HOVER)),
			String(movement.get("anchor_id", "center")),
			String(movement.get("pending_anchor_request", "")),
			int(movement.get("attacks_since_reposition", 0)),
			float(movement.get("time_since_reposition", 0.0)),
			Vector2(movement.get("target", arena.get_center())).x,
			Vector2(movement.get("target", arena.get_center())).y,
			Vector2(movement.get("locked_origin", Vector2.ZERO)).x,
			Vector2(movement.get("locked_origin", Vector2.ZERO)).y
		]
		target.call("_draw_outlined_text", arena.position + Vector2(18.0, 50.0), movement_text, 900, 12, Color("#fff1c6"), Color("#37102d"), HORIZONTAL_ALIGNMENT_LEFT)
		var balance_text := "BAL req:%d actual:%d cap:%d enemies:%d/%d bullets:%d defeats:%d exp:%d/%d lv:%d" % [
			int(balance.get("requestedSpawnCount", 0)),
			int(balance.get("actualSpawnCount", 0)),
			int(balance.get("cappedSpawnCount", 0)),
			int(balance.get("activeNormalWaveCount", 0)),
			int(balance.get("activeNormalWaveCap", 0)),
			int(balance.get("activeEnemyBulletCount", 0)),
			int(stats.get("defeats", 0)),
			int(stats.get("expDropped", 0)),
			int(stats.get("expCollected", 0)),
			int(stats.get("levelUps", 0))
		]
		target.call("_draw_outlined_text", arena.position + Vector2(18.0, 66.0), balance_text, 900, 12, Color("#c9f7ff"), Color("#37102d"), HORIZONTAL_ALIGNMENT_LEFT)
		var pending: Dictionary = runtime.get("noise_summon_pending_wave", {}) as Dictionary
		var noise_text := "NOISE phase:%d count:%d cap:%d/%d cd:%.1f" % [
			int(target.get("relay_boss_phase")),
			int((pending.get("positions", []) as Array).size()),
			int(_active_noise_count(target)),
			int(_noise_active_cap(target)),
			float(runtime.get("noise_summon_cooldown", 0.0))
		]
		target.call("_draw_outlined_text", arena.position + Vector2(18.0, 82.0), noise_text, 900, 12, Color("#ffe6f2"), Color("#37102d"), HORIZONTAL_ALIGNMENT_LEFT)
		var star_text := "STAR carrier:%d dropCd:%.1f reserved:%d/%d" % [int(runtime.get("sync_star_carrier_uid", -1)), float(runtime.get("sync_star_drop_cooldown", 0.0)), int(_reserved_stars(target)), int(_required_stars(target))]
		target.call("_draw_outlined_text", arena.position + Vector2(18.0, 98.0), star_text, 900, 12, Color("#fff2a7"), Color("#37102d"), HORIZONTAL_ALIGNMENT_LEFT)
		target.call("_draw_outlined_text", arena.position + Vector2(18.0, 114.0), DefenseSystemScript.debug_text_for_target(target), 900, 12, Color("#f0ddff"), Color("#37102d"), HORIZONTAL_ALIGNMENT_LEFT)

static func _active_noise_count(target: Node) -> int:
	var count := 0
	for item in target.get("enemies") as Array:
		var enemy: Dictionary = item as Dictionary
		if bool(enemy.get("relayBossNoiseSummon", false)) and not bool(enemy.get("defeatPending", false)) and not bool(enemy.get("defeatResolved", false)) and float(enemy.get("relayBossSummonLifetime", 1.0)) > 0.0:
			count += 1
	return count

static func _noise_active_cap(target: Node) -> int:
	var config: Dictionary = target.get("relay_mode_config") as Dictionary
	var boss_config: Dictionary = config.get("boss", {}) as Dictionary
	var attacks: Dictionary = boss_config.get("attacks", {}) as Dictionary
	var payload: Dictionary = attacks.get("noise_summon", {}) as Dictionary
	var phase := clampi(int(target.get("relay_boss_phase")), 0, 4)
	for item in payload.get("phaseSettings", []) as Array:
		var entry: Dictionary = item as Dictionary
		if int(entry.get("phaseIndex", -1)) == phase:
			return int(entry.get("activeCap", payload.get("maxActive", 4)))
	return int(payload.get("maxActive", 4))

static func _required_stars(target: Node) -> int:
	return int(target.call("_collab_required_sync_stars")) if target.has_method("_collab_required_sync_stars") else 3

static func _reserved_stars(target: Node) -> int:
	return int(target.call("_relay_boss_reserved_sync_stars")) if target.has_method("_relay_boss_reserved_sync_stars") else int(target.get("collab_sync_stars"))

static func _boss_origin(target: Node, arena: Rect2) -> Vector2:
	for item in target.get("enemies") as Array:
		var enemy: Dictionary = item as Dictionary
		if bool(enemy.get("relayBoss", false)) or String(enemy.get("bossId", "")) == "last_offline" or String(enemy.get("kind", "")) == "last_offline":
			return Vector2(enemy.get("pos", arena.get_center()))
	return arena.get_center()
