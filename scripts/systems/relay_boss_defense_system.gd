class_name RelayBossDefenseSystem
extends RefCounted

const MovementSystemScript := preload("res://scripts/systems/relay_boss_movement_system.gd")

const STATE_NORMAL := "NORMAL"
const STATE_PHASE_INVINCIBLE := "PHASE_INVINCIBLE"
const STATE_DEAD := "DEAD"

static func empty_runtime() -> Dictionary:
	return {
		"state": STATE_NORMAL,
		"nextPhase": -1,
		"barrierVisible": false,
		"releaseActive": false,
		"releaseTimer": 0.0,
		"releaseDuration": 0.30,
		"invalidTextCooldown": 0.0,
		"hitSeCooldown": 0.0,
		"invalidTextTimer": 0.0,
		"ripples": [],
		"blockedHitCount": 0,
		"elapsed": 0.0,
		"barrierStartRatio": 1.0,
		"releaseSePlayed": false
	}

static func reset_for_target(target: Node) -> void:
	target.set("relay_boss_defense_runtime", empty_runtime())
	_sync_boss_flags(target, false, -1)

static func ensure_for_target(target: Node) -> Dictionary:
	var value: Variant = target.get("relay_boss_defense_runtime")
	if value is Dictionary and not (value as Dictionary).is_empty():
		return value as Dictionary
	var runtime := empty_runtime()
	target.set("relay_boss_defense_runtime", runtime)
	return runtime

static func state_for_target(target: Node) -> String:
	return String(ensure_for_target(target).get("state", STATE_NORMAL))

static func is_phase_invincible(target: Node) -> bool:
	var runtime := ensure_for_target(target)
	return String(runtime.get("state", STATE_NORMAL)) == STATE_PHASE_INVINCIBLE and bool(runtime.get("barrierVisible", false))

static func begin_phase_transition(target: Node, next_phase: int) -> bool:
	if not bool(target.get("relay_boss_active")):
		return false
	var boss := _active_boss(target)
	if boss.is_empty():
		return false
	var barrier := _barrier_config(target)
	if not bool(barrier.get("enabled", true)):
		return false
	var runtime := ensure_for_target(target)
	runtime["state"] = STATE_PHASE_INVINCIBLE
	runtime["nextPhase"] = clampi(next_phase, 0, 4)
	runtime["barrierVisible"] = true
	runtime["releaseActive"] = false
	runtime["releaseTimer"] = 0.0
	runtime["releaseDuration"] = maxf(0.01, float(barrier.get("releaseDuration", 0.30)))
	runtime["invalidTextCooldown"] = 0.0
	runtime["hitSeCooldown"] = 0.0
	runtime["invalidTextTimer"] = 0.0
	runtime["ripples"] = []
	runtime["elapsed"] = 0.0
	runtime["barrierStartRatio"] = clampf(float(boss.get("hp", 0.0)) / maxf(1.0, float(boss.get("max_hp", 1.0))), 0.0, 1.0)
	runtime["releaseSePlayed"] = false
	target.set("relay_boss_defense_runtime", runtime)
	_sync_boss_flags(target, true, int(runtime["nextPhase"]))
	return true

static func begin_release(target: Node) -> bool:
	var runtime := ensure_for_target(target)
	if String(runtime.get("state", STATE_NORMAL)) != STATE_PHASE_INVINCIBLE:
		return false
	if bool(runtime.get("releaseActive", false)):
		return false
	runtime["releaseActive"] = true
	runtime["releaseTimer"] = float(runtime.get("releaseDuration", 0.30))
	runtime["releaseSePlayed"] = true
	target.set("relay_boss_defense_runtime", runtime)
	_sync_boss_flags(target, true, int(runtime.get("nextPhase", -1)))
	if target.has_method("_play_relay_boss_barrier_release_se"):
		target.call("_play_relay_boss_barrier_release_se")
	return true

static func finish_phase_transition(target: Node) -> bool:
	var runtime := ensure_for_target(target)
	if String(runtime.get("state", STATE_NORMAL)) != STATE_PHASE_INVINCIBLE:
		return false
	runtime["state"] = STATE_NORMAL
	runtime["nextPhase"] = -1
	runtime["barrierVisible"] = false
	runtime["releaseActive"] = false
	runtime["releaseTimer"] = 0.0
	runtime["invalidTextTimer"] = 0.0
	runtime["ripples"] = []
	target.set("relay_boss_defense_runtime", runtime)
	_sync_boss_flags(target, false, -1)
	return true

static func force_clear(target: Node, final_state: String = STATE_NORMAL) -> void:
	var runtime := ensure_for_target(target)
	runtime["state"] = final_state if final_state in [STATE_NORMAL, STATE_DEAD] else STATE_NORMAL
	runtime["nextPhase"] = -1
	runtime["barrierVisible"] = false
	runtime["releaseActive"] = false
	runtime["releaseTimer"] = 0.0
	runtime["invalidTextTimer"] = 0.0
	runtime["ripples"] = []
	target.set("relay_boss_defense_runtime", runtime)
	_sync_boss_flags(target, false, -1)

static func update_for_target(target: Node, delta: float, transition_timer: float, center_timer: float) -> void:
	var runtime := ensure_for_target(target)
	if String(runtime.get("state", STATE_NORMAL)) != STATE_PHASE_INVINCIBLE:
		return
	var safe_delta := maxf(0.0, delta)
	runtime["elapsed"] = float(runtime.get("elapsed", 0.0)) + safe_delta
	runtime["invalidTextCooldown"] = maxf(0.0, float(runtime.get("invalidTextCooldown", 0.0)) - safe_delta)
	runtime["hitSeCooldown"] = maxf(0.0, float(runtime.get("hitSeCooldown", 0.0)) - safe_delta)
	runtime["invalidTextTimer"] = maxf(0.0, float(runtime.get("invalidTextTimer", 0.0)) - safe_delta)
	if bool(runtime.get("releaseActive", false)):
		runtime["releaseTimer"] = maxf(0.0, float(runtime.get("releaseTimer", 0.0)) - safe_delta)
	var ripples: Array = runtime.get("ripples", []) as Array
	var kept_ripples: Array = []
	for item in ripples:
		var ripple: Dictionary = item as Dictionary
		ripple["life"] = float(ripple.get("life", 0.0)) - safe_delta
		if float(ripple.get("life", 0.0)) > 0.0:
			kept_ripples.append(ripple)
	runtime["ripples"] = kept_ripples
	var release_duration := maxf(0.01, float(runtime.get("releaseDuration", 0.30)))
	if transition_timer > 0.0 and transition_timer <= release_duration:
		begin_release(target)
		return
	if transition_timer <= 0.0 and center_timer <= 0.0:
		finish_phase_transition(target)
		return
	target.set("relay_boss_defense_runtime", runtime)
	_sync_boss_flags(target, true, int(runtime.get("nextPhase", -1)))

static func register_blocked_hit(target: Node, hit_position: Vector2, source: String = "") -> bool:
	if not is_phase_invincible(target):
		return false
	var runtime := ensure_for_target(target)
	runtime["blockedHitCount"] = int(runtime.get("blockedHitCount", 0)) + 1
	var barrier := _barrier_config(target)
	var max_ripples := maxi(0, int(barrier.get("maxRipples", 3)))
	var ripples: Array = runtime.get("ripples", []) as Array
	if ripples.size() < max_ripples:
		ripples.append({
			"pos": hit_position,
			"life": maxf(0.05, float(barrier.get("rippleDuration", 0.34))),
			"maxLife": maxf(0.05, float(barrier.get("rippleDuration", 0.34))),
			"source": source
		})
	runtime["ripples"] = ripples
	if float(runtime.get("invalidTextCooldown", 0.0)) <= 0.0:
		runtime["invalidTextCooldown"] = maxf(0.01, float(barrier.get("invalidTextCooldown", 0.35)))
		runtime["invalidTextTimer"] = maxf(0.05, float(barrier.get("invalidTextDuration", 0.48)))
	if float(runtime.get("hitSeCooldown", 0.0)) <= 0.0:
		runtime["hitSeCooldown"] = maxf(0.01, float(barrier.get("hitSeCooldown", 0.20)))
		if target.has_method("_play_relay_boss_barrier_hit_se"):
			target.call("_play_relay_boss_barrier_hit_se")
	target.set("relay_boss_defense_runtime", runtime)
	return true

static func debug_text_for_target(target: Node) -> String:
	var runtime := ensure_for_target(target)
	var barrier := _barrier_config(target)
	return "DEFENSE %s barrier:%s nextPhase:%d release:%.2f ripples:%d/%d blocked:%d" % [
		String(runtime.get("state", STATE_NORMAL)),
		"on" if bool(runtime.get("barrierVisible", false)) else "off",
		int(runtime.get("nextPhase", -1)) + 1,
		float(runtime.get("releaseTimer", 0.0)),
		(ripples_count(runtime)),
		int(barrier.get("maxRipples", 3)),
		int(runtime.get("blockedHitCount", 0))
	]

static func ripples_count(runtime: Dictionary) -> int:
	return (runtime.get("ripples", []) as Array).size()

static func _barrier_config(target: Node) -> Dictionary:
	var config: Variant = target.get("relay_mode_config")
	if not config is Dictionary:
		return {}
	var boss: Dictionary = (config as Dictionary).get("boss", {}) as Dictionary
	return boss.get("phaseBarrier", {}) as Dictionary

static func _active_boss(target: Node) -> Dictionary:
	var enemies: Variant = target.get("enemies")
	if not enemies is Array:
		return {}
	for item in enemies as Array:
		var enemy: Dictionary = item as Dictionary
		if bool(enemy.get("relayBoss", false)) or String(enemy.get("bossId", "")) == "last_offline" or String(enemy.get("kind", "")) == "last_offline":
			return enemy
	return {}

static func _sync_boss_flags(target: Node, active: bool, next_phase: int) -> void:
	var boss := _active_boss(target)
	if boss.is_empty():
		return
	boss["phaseBarrierActive"] = active
	boss["phaseBarrierNextPhase"] = next_phase
	boss["invincible"] = active
	boss["invulnerable"] = active
	if not active:
		boss["hitFlashTimer"] = 0.0

static func _phase_theme_key(next_phase: int) -> String:
	match next_phase:
		1:
			return "gameplay"
		2:
			return "singing"
		3:
			return "drawing"
		4:
			return "collab_final"
	return "gameplay"

static func _phase_colors(target: Node, next_phase: int) -> Array[Color]:
	var barrier := _barrier_config(target)
	var colors_config: Dictionary = barrier.get("phaseColors", {}) as Dictionary
	var values: Array = colors_config.get(_phase_theme_key(next_phase), ["#85e6ff", "#947cff", "#fff7ff"]) as Array
	var colors: Array[Color] = []
	for value in values:
		colors.append(Color(String(value)))
	while colors.size() < 3:
		colors.append(Color.WHITE)
	return colors

static func _boss_center(target: Node, arena: Rect2) -> Vector2:
	var boss := _active_boss(target)
	return Vector2(boss.get("pos", arena.get_center())) if not boss.is_empty() else arena.get_center()

static func _barrier_geometry(target: Node) -> Dictionary:
	var barrier := _barrier_config(target)
	var boss := _active_boss(target)
	var visual_size := Vector2(boss.get("visualDrawSize", Vector2(520.0, 520.0)))
	var base_radius := maxf(40.0, maxf(visual_size.x, visual_size.y) * float(barrier.get("barrierRadiusRate", 0.60)))
	return {
		"center": Vector2(boss.get("pos", Vector2.ZERO)),
		"radius": base_radius,
		"aspect": clampf(float(barrier.get("barrierAspect", 0.90)), 0.4, 1.2)
	}

static func draw_back_for_target(target: Node, arena: Rect2) -> void:
	if not is_phase_invincible(target):
		return
	var geo := _barrier_geometry(target)
	var center: Vector2 = geo["center"]
	var radius: float = geo["radius"]
	var aspect: float = geo["aspect"]
	var colors := _phase_colors(target, int(ensure_for_target(target).get("nextPhase", 0)))
	var pulse := 0.5 + 0.5 * sin(float(ensure_for_target(target).get("elapsed", 0.0)) * 4.0)
	_draw_ellipse(target, center, radius * 1.08, aspect, colors[1].lerp(Color.WHITE, 0.35), 5.0, 0.08 + pulse * 0.04)
	_draw_ellipse(target, center, radius * 1.02, aspect, colors[2], 2.0, 0.14)
	_draw_module_gather(target, arena, center, colors, float(_barrier_config(target).get("moduleGatherRate", 0.16)))

static func draw_front_for_target(target: Node, arena: Rect2) -> void:
	if not is_phase_invincible(target):
		return
	var runtime := ensure_for_target(target)
	var geo := _barrier_geometry(target)
	var center: Vector2 = geo["center"]
	var radius: float = geo["radius"]
	var aspect: float = geo["aspect"]
	var colors := _phase_colors(target, int(runtime.get("nextPhase", 0)))
	var elapsed_value := float(runtime.get("elapsed", 0.0))
	var release_ratio := 0.0
	if bool(runtime.get("releaseActive", false)):
		release_ratio = clampf(float(runtime.get("releaseTimer", 0.0)) / maxf(0.01, float(runtime.get("releaseDuration", 0.30))), 0.0, 1.0)
	var scale := lerpf(0.78, 1.0, release_ratio) if bool(runtime.get("releaseActive", false)) else 1.0
	_draw_ellipse(target, center, radius * scale, aspect, colors[2].lerp(colors[0], 0.25), 5.0, 0.80)
	_draw_ellipse_arc(target, center, radius * scale * 0.96, aspect, elapsed_value * 0.9, elapsed_value * 0.9 + PI * 0.72, colors[0], 8.0, 0.92)
	_draw_ellipse_arc(target, center, radius * scale * 0.96, aspect, -elapsed_value * 0.7 + PI, -elapsed_value * 0.7 + PI * 1.78, colors[1], 7.0, 0.90)
	_draw_ellipse(target, center, radius * scale * 0.80, aspect, Color(1.0, 1.0, 1.0, 0.20), 2.0, 0.5)
	for scan in range(4):
		var scan_y := center.y - radius * aspect * 0.70 + fmod(elapsed_value * 90.0 + float(scan) * 38.0, radius * aspect * 1.40)
		var half_width := radius * sqrt(maxf(0.0, 1.0 - pow((scan_y - center.y) / maxf(1.0, radius * aspect), 2.0)))
		if half_width > 0.0:
			target.call("draw_line", Vector2(center.x - half_width, scan_y), Vector2(center.x + half_width, scan_y), Color(1.0, 1.0, 1.0, 0.10), 1.0)
	var max_ripples := maxi(0, int(_barrier_config(target).get("maxRipples", 3)))
	for ripple_item in runtime.get("ripples", []) as Array:
		var ripple: Dictionary = ripple_item as Dictionary
		var progress := 1.0 - clampf(float(ripple.get("life", 0.0)) / maxf(0.01, float(ripple.get("maxLife", 0.34))), 0.0, 1.0)
		var ripple_pos := Vector2(ripple.get("pos", center))
		target.call("draw_arc", ripple_pos, 18.0 + progress * 32.0, 0.0, TAU, 24, Color(1.0, 0.92, 1.0, 0.9 * (1.0 - progress)), 3.0, true)
	if float(runtime.get("invalidTextTimer", 0.0)) > 0.0:
		var invalid_alpha := clampf(float(runtime.get("invalidTextTimer", 0.0)) / maxf(0.01, float(_barrier_config(target).get("invalidTextDuration", 0.48))), 0.0, 1.0)
		if target.has_method("_draw_outlined_text"):
			target.call("_draw_outlined_text", center + Vector2(-46.0, -radius * aspect - 14.0), "無効", 92, 19, Color(1.0, 1.0, 1.0, invalid_alpha), Color(0.20, 0.04, 0.28, invalid_alpha), HORIZONTAL_ALIGNMENT_CENTER)
	# Keep this read explicit so a future renderer cannot accidentally exceed the configured ripple budget.
	if runtime.get("ripples", []).size() > max_ripples:
		runtime["ripples"] = (runtime.get("ripples", []) as Array).slice(0, max_ripples)

static func _draw_module_gather(target: Node, arena: Rect2, center: Vector2, colors: Array[Color], rate: float) -> void:
	var names := ["ChatModule", "GameModule", "SongModule", "DrawModule", "CollabModule"]
	for i in range(names.size()):
		var marker := MovementSystemScript.marker_world_position(target, names[i], arena)
		var gather := marker.lerp(center, clampf(rate, 0.0, 1.0))
		target.call("draw_line", marker, gather, Color(colors[i % colors.size()], 0.30), 2.0)
		target.call("draw_circle", gather, 5.0 + sin(float(target.get("elapsed")) * 4.0 + float(i)) * 1.5, Color(colors[i % colors.size()], 0.78), true)

static func _ellipse_points(center: Vector2, radius: float, aspect: float, start_angle: float = 0.0, end_angle: float = TAU, segments: int = 64) -> PackedVector2Array:
	var points := PackedVector2Array()
	var count := maxi(8, segments)
	for i in range(count + 1):
		var t := float(i) / float(count)
		var angle := lerpf(start_angle, end_angle, t)
		points.append(center + Vector2(cos(angle) * radius, sin(angle) * radius * aspect))
	return points

static func _draw_ellipse(target: Node, center: Vector2, radius: float, aspect: float, color: Color, width: float, alpha: float) -> void:
	var c := Color(color.r, color.g, color.b, color.a * alpha)
	target.call("draw_polyline", _ellipse_points(center, radius, aspect), c, width, true)

static func _draw_ellipse_arc(target: Node, center: Vector2, radius: float, aspect: float, start_angle: float, end_angle: float, color: Color, width: float, alpha: float) -> void:
	var c := Color(color.r, color.g, color.b, color.a * alpha)
	target.call("draw_polyline", _ellipse_points(center, radius, aspect, start_angle, end_angle, 28), c, width, true)
