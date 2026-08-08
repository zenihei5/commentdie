class_name RelayBossMovementSystem
extends RefCounted

const HardModeSystemScript := preload("res://scripts/systems/hard_mode_system.gd")

const STATE_HOVER := "IDLE_HOVER"
const STATE_CRUISING := "CRUISING"
const STATE_REPOSITION_WARNING := "REPOSITION_WARNING"
const STATE_REPOSITION := "REPOSITIONING"
const STATE_ATTACK_LOCK := "ATTACKING"
const STATE_PHASE_TRANSITION := "PHASE_TRANSITION"
const STATE_STUNNED := "STUNNED"
const STATE_DEAD := "DEAD"

const ANCHOR_NORMALIZED := {
	"upper_left": Vector2(0.0, 0.0),
	"upper_center": Vector2(0.5, 0.0),
	"upper_right": Vector2(1.0, 0.0),
	"middle_left": Vector2(0.0, 0.5),
	"center": Vector2(0.5, 0.5),
	"middle_right": Vector2(1.0, 0.5),
	"lower_left": Vector2(0.0, 1.0),
	"lower_center": Vector2(0.5, 1.0),
	"lower_right": Vector2(1.0, 1.0)
}

const MARKER_DEFAULTS := {
	"MuzzleCenter": Vector2(0.0, -0.08),
	"MuzzleLeft": Vector2(-0.16, -0.02),
	"MuzzleRight": Vector2(0.16, -0.02),
	"CoreCenter": Vector2(0.0, 0.08),
	"ChatModule": Vector2(-0.34, -0.17),
	"GameModule": Vector2(0.34, -0.17),
	"SongModule": Vector2(-0.34, 0.17),
	"DrawModule": Vector2(0.34, 0.17),
	"CollabModule": Vector2(0.0, 0.37)
}

static func empty_runtime() -> Dictionary:
	return {
		"state": STATE_HOVER,
		"target": Vector2.ZERO,
		"anchor_id": "center",
		"previous_anchor_id": "",
		"target_anchor_id": "center",
		"time_since_reposition": 0.0,
		"attacks_since_reposition": 0,
		"attack_limit": 2,
		"resume_timer": 0.0,
		"pattern_time": 0.0,
		"phase_center_timer": 0.0,
		"phase_center_pending": false,
		"reposition_warning_timer": 0.0,
		"reposition_warning_duration": 0.0,
		"cruise_target": Vector2.ZERO,
		"cruise_timer": 0.0,
		"travel_timer": 0.0,
		"travel_next_attack_timer": 0.0,
		"travel_attack_count": 0,
		"travel_attacks_emitted": 0,
		"travel_last_attack": "",
		"repositionWarningPulse": false,
		"visual_offset": Vector2.ZERO,
		"visual_rotation": 0.0,
		"visual_scale_vector": Vector2.ONE,
		"shadow_scale": 1.0,
		"telegraph_timer": 0.0,
		"locked_origin": Vector2.ZERO,
		"pending_anchor_request": ""
	}

static func reset_for_target(target: Node, arena: Rect2) -> void:
	var runtime := empty_runtime()
	runtime["target"] = arena.get_center()
	target.set("relay_boss_movement", runtime)
	_apply_visual_state(target, runtime)

static func ensure_for_target(target: Node) -> Dictionary:
	var value: Variant = target.get("relay_boss_movement")
	if value is Dictionary and not (value as Dictionary).is_empty():
		return value as Dictionary
	var runtime := empty_runtime()
	target.set("relay_boss_movement", runtime)
	return runtime

static func state_for_target(target: Node) -> String:
	return String(ensure_for_target(target).get("state", STATE_HOVER))

static func movement_policy_for_attack(attack_id: String) -> String:
	match attack_id:
		"comment_shotgun", "noise_summon":
			return "mobile"
		"offline_laser":
			return "lock_on_aim_commit"
		"race_lane_charge", "eraser_sweep", "all_genre_rush":
			return "reposition_then_lock"
	return "lock_on_telegraph"

static func required_anchor_for_attack(attack_id: String, target: Node, rng: RandomNumberGenerator) -> String:
	if attack_id == "all_genre_rush":
		return "center"
	if attack_id == "race_lane_charge" or attack_id == "eraser_sweep":
		return "upper_left" if rng.randf() < 0.5 else "upper_right"
	return ""

static func request_anchor(target: Node, arena: Rect2, anchor_id: String) -> bool:
	var runtime := ensure_for_target(target)
	var safe_id := safe_anchor_for_target(target, arena, anchor_id)
	if safe_id == "":
		return false
	var destination := anchor_position_for_target(target, arena, safe_id)
	var boss := _active_boss(target)
	if boss.is_empty():
		return false
	if safe_id == String(runtime.get("anchor_id", "")) and Vector2(boss.get("pos", destination)).distance_to(destination) <= arrival_distance(target):
		return false
	runtime["previous_anchor_id"] = String(runtime.get("anchor_id", ""))
	runtime["target_anchor_id"] = safe_id
	runtime["target"] = destination
	runtime["pending_anchor_request"] = safe_id
	runtime["reposition_warning_duration"] = reposition_warning_seconds(target)
	runtime["reposition_warning_timer"] = runtime["reposition_warning_duration"]
	runtime["travel_timer"] = 0.0
	runtime["travel_next_attack_timer"] = 0.0
	runtime["travel_attack_count"] = 0
	runtime["travel_attacks_emitted"] = 0
	runtime["travel_last_attack"] = ""
	runtime["state"] = STATE_REPOSITION_WARNING
	runtime["resume_timer"] = 0.0
	target.set("relay_boss_movement", runtime)
	target.set("relay_boss_reposition_warning", true)
	if target.has_method("_relay_boss_contact_reposition_started"):
		target.call("_relay_boss_contact_reposition_started")
	return true

static func begin_phase_transition(target: Node, arena: Rect2) -> bool:
	var runtime := ensure_for_target(target)
	var boss := _active_boss(target)
	if boss.is_empty():
		return false
	var movement_config := _movement_config(target)
	runtime["state"] = STATE_PHASE_TRANSITION
	runtime["target"] = anchor_position_for_target(target, arena, "center")
	runtime["target_anchor_id"] = "center"
	runtime["anchor_id"] = "center"
	runtime["phase_center_timer"] = float(movement_config.get("phaseTransitionCenterTime", 0.7))
	runtime["phase_center_pending"] = true
	runtime["resume_timer"] = 0.0
	runtime["cruise_target"] = Vector2.ZERO
	runtime["reposition_warning_timer"] = 0.0
	runtime["travel_timer"] = 0.0
	runtime["travel_attacks_emitted"] = 0
	target.set("relay_boss_movement", runtime)
	target.set("relay_boss_phase_center_timer", float(runtime["phase_center_timer"]))
	target.set("relay_boss_reposition_warning", false)
	if target.has_method("_relay_boss_contact_reposition_started"):
		target.call("_relay_boss_contact_reposition_started")
	return true

static func on_attack_started(target: Node, attack_id: String, origin: Vector2) -> void:
	var runtime := ensure_for_target(target)
	var policy := movement_policy_for_attack(attack_id)
	runtime["attacks_since_reposition"] = int(runtime.get("attacks_since_reposition", 0)) + 1
	runtime["locked_origin"] = origin
	runtime["telegraph_timer"] = 0.15
	if policy != "mobile":
		runtime["state"] = STATE_ATTACK_LOCK
	elif String(runtime.get("state", STATE_HOVER)) != STATE_CRUISING:
		runtime["state"] = STATE_HOVER
	target.set("relay_boss_movement", runtime)

static func on_attack_finished(target: Node) -> void:
	var runtime := ensure_for_target(target)
	if String(runtime.get("state", STATE_HOVER)) == STATE_ATTACK_LOCK:
		runtime["state"] = STATE_HOVER
	if String(runtime.get("state", STATE_HOVER)) == STATE_HOVER and int(runtime.get("attacks_since_reposition", 0)) < attack_limit_for_target(target):
		runtime["state"] = STATE_CRUISING
	runtime["cruise_timer"] = 0.0
	runtime["cruise_target"] = Vector2.ZERO
	runtime["resume_timer"] = randf_range(float(_movement_config(target).get("resumeDelayMin", 0.6)), float(_movement_config(target).get("resumeDelayMax", 1.2)))
	runtime["telegraph_timer"] = 0.0
	target.set("relay_boss_movement", runtime)

static func interrupt_for_target(target: Node, state: String = STATE_STUNNED) -> void:
	var runtime := ensure_for_target(target)
	runtime["state"] = state
	runtime["resume_timer"] = 0.35
	runtime["telegraph_timer"] = 0.0
	runtime["reposition_warning_timer"] = 0.0
	runtime["travel_timer"] = 0.0
	target.set("relay_boss_reposition_warning", false)
	target.set("relay_boss_movement", runtime)

static func force_resume_for_target(target: Node, arena: Rect2) -> void:
	var runtime := ensure_for_target(target)
	var center_target := anchor_position_for_target(target, arena, "center")
	var boss := _active_boss(target)
	if not boss.is_empty():
		boss["pos"] = center_target
	runtime["state"] = STATE_HOVER
	runtime["target"] = center_target
	runtime["target_anchor_id"] = "center"
	runtime["anchor_id"] = "center"
	runtime["phase_center_timer"] = 0.0
	runtime["phase_center_pending"] = false
	runtime["resume_timer"] = 0.0
	runtime["pending_anchor_request"] = ""
	runtime["cruise_target"] = Vector2.ZERO
	runtime["time_since_reposition"] = 0.0
	runtime["attacks_since_reposition"] = 0
	runtime["reposition_warning_timer"] = 0.0
	runtime["travel_timer"] = 0.0
	runtime["travel_next_attack_timer"] = 0.0
	runtime["travel_attack_count"] = 0
	runtime["travel_attacks_emitted"] = 0
	runtime["repositionWarningPulse"] = false
	runtime["attack_limit"] = _roll_attack_limit(target)
	target.set("relay_boss_phase_center_timer", 0.0)
	target.set("relay_boss_movement", runtime)
	target.set("relay_boss_reposition_warning", false)
	if target.has_method("_relay_boss_contact_reposition_finished"):
		target.call("_relay_boss_contact_reposition_finished")
	_apply_visual_state(target, runtime)

static func update_for_target(target: Node, delta: float, arena: Rect2, freeze_gameplay: bool = false) -> Dictionary:
	var runtime := ensure_for_target(target)
	var boss := _active_boss(target)
	if boss.is_empty():
		return {"state": STATE_DEAD, "phaseCenterArrived": false}
	var movement_config := _movement_config(target)
	runtime["pattern_time"] = float(runtime.get("pattern_time", 0.0)) + delta
	runtime["time_since_reposition"] = float(runtime.get("time_since_reposition", 0.0)) + delta
	runtime["resume_timer"] = maxf(0.0, float(runtime.get("resume_timer", 0.0)) - delta)
	runtime["telegraph_timer"] = maxf(0.0, float(runtime.get("telegraph_timer", 0.0)) - delta)
	var state := String(runtime.get("state", STATE_HOVER))
	# Phase movement owns its short transition window.  Do not let a
	# simultaneous combo freeze this state forever; gameplay remains frozen by
	# the caller while the boss moves to the phase anchor.
	if freeze_gameplay and state != STATE_PHASE_TRANSITION:
		_update_visual_history(target, runtime, boss, delta)
		_apply_visual_state(target, runtime)
		target.set("relay_boss_movement", runtime)
		return {"state": String(runtime.get("state", STATE_HOVER)), "phaseCenterArrived": false}
	if state == STATE_CRUISING:
		_advance_cruising(target, runtime, boss, arena, delta, movement_config)
	var phase_center_arrived := false
	if state == STATE_PHASE_TRANSITION:
		var center_duration := maxf(0.05, float(movement_config.get("phaseTransitionCenterTime", 0.7)))
		var center_timer := maxf(0.0, float(runtime.get("phase_center_timer", center_duration)) - delta)
		runtime["phase_center_timer"] = center_timer
		target.set("relay_boss_phase_center_timer", center_timer)
		var destination := Vector2(runtime.get("target", arena.get_center()))
		var center_result := _move_boss_toward(boss, destination, arena, center_duration, delta, true)
		if center_result or center_timer <= 0.0:
			boss["pos"] = destination
			runtime["phase_center_timer"] = 0.0
			runtime["phase_center_pending"] = false
			runtime["state"] = STATE_HOVER
			phase_center_arrived = true
			if target.has_method("_relay_boss_contact_reposition_finished"):
				target.call("_relay_boss_contact_reposition_finished")
			target.set("relay_boss_phase_center_timer", 0.0)
	elif state == STATE_REPOSITION_WARNING:
		runtime["reposition_warning_timer"] = maxf(0.0, float(runtime.get("reposition_warning_timer", 0.0)) - delta)
		if float(runtime.get("reposition_warning_timer", 0.0)) <= 0.0:
			runtime["state"] = STATE_REPOSITION
			runtime["travel_timer"] = 0.0
			runtime["travel_next_attack_timer"] = float(movement_config.get("travelVolleyFirstDelay", 0.5))
			runtime["travel_attack_count"] = _travel_attack_count(target)
			runtime["travel_attacks_emitted"] = 0
			runtime["repositionWarningPulse"] = false
		elif float(runtime.get("reposition_warning_timer", 0.0)) <= 0.18 and not bool(runtime.get("repositionWarningPulse", false)):
			runtime["repositionWarningPulse"] = true
			target.set("relay_boss_reposition_warning", true)
	elif state == STATE_REPOSITION:
		var position := Vector2(boss.get("pos", arena.get_center()))
		var destination := Vector2(runtime.get("target", position))
		var phase := clampi(int(target.get("relay_boss_phase")), 0, 4)
		var speeds: Array = movement_config.get("repositionSpeeds", [220.0, 240.0, 260.0, 280.0, 320.0]) as Array
		var speed := float(speeds[mini(phase, speeds.size() - 1)]) if not speeds.is_empty() else 220.0
		if HardModeSystemScript.is_hard_target(target):
			speed *= float(HardModeSystemScript.final_boss_rates(HardModeSystemScript.runtime_for_target(target)).get("moveSpeedRate", 1.08))
		if _movement_up_instruction_active(target):
			speed *= 1.35
		boss["pos"] = position.move_toward(destination, speed * delta)
		runtime["travel_timer"] = float(runtime.get("travel_timer", 0.0)) + delta
		if Vector2(boss.get("pos", position)).distance_to(destination) <= arrival_distance(target):
			boss["pos"] = destination
			runtime["state"] = STATE_HOVER
			runtime["anchor_id"] = String(runtime.get("target_anchor_id", runtime.get("anchor_id", "center")))
			runtime["pending_anchor_request"] = ""
			if target.has_method("_relay_boss_contact_reposition_finished"):
				target.call("_relay_boss_contact_reposition_finished")
			runtime["reposition_warning_timer"] = 0.0
			runtime["resume_timer"] = randf_range(float(movement_config.get("resumeDelayMin", 0.6)), float(movement_config.get("resumeDelayMax", 1.2)))
			runtime["time_since_reposition"] = 0.0
			runtime["attacks_since_reposition"] = 0
			runtime["attack_limit"] = _roll_attack_limit(target)
			runtime["cruise_target"] = Vector2.ZERO
			runtime["travel_timer"] = 0.0
		else:
			_update_travel_attacks(target, runtime, arena, destination - position)
		target.set("relay_boss_reposition_warning", false)
	elif state == STATE_STUNNED:
		if float(runtime.get("resume_timer", 0.0)) <= 0.0:
			runtime["state"] = STATE_HOVER
	elif (state == STATE_HOVER or state == STATE_CRUISING) and float(runtime.get("resume_timer", 0.0)) <= 0.0:
		var active_attack: Dictionary = target.get("relay_boss_active_attack") as Dictionary
		var active_attack_state := String(active_attack.get("state", "idle"))
		if active_attack_state != "idle" and active_attack_state != "recovery":
			_update_visual_history(target, runtime, boss, delta)
			_apply_visual_state(target, runtime)
			target.set("relay_boss_movement", runtime)
			return {"state": String(runtime.get("state", STATE_HOVER)), "phaseCenterArrived": false}
		if active_attack_state == "recovery":
			_update_visual_history(target, runtime, boss, delta)
			_apply_visual_state(target, runtime)
			target.set("relay_boss_movement", runtime)
			return {"state": String(runtime.get("state", STATE_HOVER)), "phaseCenterArrived": false}
		var same_area_limit := float(movement_config.get("sameAreaMaxSeconds", 4.0))
		if _movement_up_instruction_active(target):
			same_area_limit *= 0.65
		if int(runtime.get("attacks_since_reposition", 0)) >= attack_limit_for_target(target) or float(runtime.get("time_since_reposition", 0.0)) >= same_area_limit:
			var next_anchor := _choose_anchor(runtime, boss, arena, target)
			if next_anchor == "":
				runtime["resume_timer"] = 0.25
				runtime["cruise_timer"] = 0.0
				target.set("relay_boss_movement", runtime)
				return {"state": String(runtime.get("state", STATE_HOVER)), "phaseCenterArrived": false}
			if request_anchor(target, arena, next_anchor):
				runtime["cruise_timer"] = 0.0
			else:
				# If every safe candidate collapses to the current center (for
				# example in a narrow aspect ratio), release the attack counter so
				# the boss cannot repeatedly request the same unreachable anchor.
				runtime["attacks_since_reposition"] = 0
				runtime["time_since_reposition"] = 0.0
				runtime["resume_timer"] = 0.25
		else:
			runtime["cruise_timer"] = float(runtime.get("cruise_timer", 0.0)) + delta
	_update_visual_history(target, runtime, boss, delta)
	_apply_visual_state(target, runtime)
	target.set("relay_boss_movement", runtime)
	return {"state": String(runtime.get("state", STATE_HOVER)), "phaseCenterArrived": phase_center_arrived}

static func _advance_cruising(target: Node, runtime: Dictionary, boss: Dictionary, arena: Rect2, delta: float, movement_config: Dictionary) -> void:
	var cruise_target := Vector2(runtime.get("cruise_target", Vector2.ZERO))
	var position := Vector2(boss.get("pos", arena.get_center()))
	if cruise_target.length_squared() <= 1.0 or position.distance_to(cruise_target) <= arrival_distance(target):
		cruise_target = _choose_cruise_destination(target, boss, arena)
		runtime["cruise_target"] = cruise_target
	var speeds: Array = movement_config.get("cruiseSpeeds", [90.0, 110.0, 125.0, 140.0, 155.0]) as Array
	var phase := clampi(int(target.get("relay_boss_phase")), 0, maxi(0, speeds.size() - 1))
	var speed := float(speeds[phase]) if not speeds.is_empty() else 90.0
	if HardModeSystemScript.is_hard_target(target):
		speed *= float(HardModeSystemScript.final_boss_rates(HardModeSystemScript.runtime_for_target(target)).get("moveSpeedRate", 1.08))
	if _movement_up_instruction_active(target):
		speed *= 1.35
	boss["pos"] = position.move_toward(cruise_target, speed * delta)

static func anchor_position(arena: Rect2, anchor_id: String) -> Vector2:
	var normalized := ANCHOR_NORMALIZED.get(anchor_id, ANCHOR_NORMALIZED["center"]) as Vector2
	return Vector2(arena.position.x + arena.size.x * normalized.x, arena.position.y + arena.size.y * normalized.y)

static func anchor_position_for_target(target: Node, arena: Rect2, anchor_id: String) -> Vector2:
	var navigation := navigation_rect_for_target(target, arena)
	var safe_rect := safe_center_rect_for_target(target, navigation)
	var normalized := ANCHOR_NORMALIZED.get(anchor_id, ANCHOR_NORMALIZED["center"]) as Vector2
	if safe_rect.size.x <= 1.0 or safe_rect.size.y <= 1.0:
		# Keep the full image centered when the visible world is too small for
		# the requested opaque bounds.  _apply_visual_state reduces the image
		# uniformly in this exceptional case instead of letting it leave the
		# viewport.
		return navigation.get_center()
	return safe_rect.position + safe_rect.size * normalized

static func navigation_rect_for_target(target: Node, arena: Rect2) -> Rect2:
	var visible_world_rect: Rect2 = target.call("_visible_world_rect_for_spawning") if target.has_method("_visible_world_rect_for_spawning") else arena
	var navigation := visible_world_rect.intersection(arena)
	return navigation if navigation.size.x > 1.0 and navigation.size.y > 1.0 else arena

static func safe_center_rect_for_target(target: Node, navigation: Rect2) -> Rect2:
	var movement_config := _movement_config(target)
	var edge_padding := maxf(0.0, float(movement_config.get("edgePadding", 40.0)))
	var visual_size := _vector2_from_config(movement_config.get("visualOpaqueSize", {"x": 500.0, "y": 450.0}), Vector2(500.0, 450.0))
	var horizontal_margin := visual_size.x * 0.5 + edge_padding
	var vertical_margin := visual_size.y * 0.5 + edge_padding
	var safe_rect := navigation.grow_individual(-horizontal_margin, -vertical_margin, -horizontal_margin, -vertical_margin)
	if safe_rect.size.x > 1.0 and safe_rect.size.y > 1.0:
		return safe_rect
	# The 1600x900 field can be smaller than the opaque image plus padding.
	# Reduce padding first, then let the center row use the maximum legal area.
	var reduced_padding := 20.0
	safe_rect = navigation.grow_individual(-(visual_size.x * 0.5 + reduced_padding), -(visual_size.y * 0.5 + reduced_padding), -(visual_size.x * 0.5 + reduced_padding), -(visual_size.y * 0.5 + reduced_padding))
	if safe_rect.size.x > 1.0 and safe_rect.size.y > 1.0:
		return safe_rect
	return Rect2(navigation.get_center(), Vector2.ZERO)

static func marker_world_position(target: Node, marker_name: String, arena: Rect2) -> Vector2:
	var boss := _active_boss(target)
	if boss.is_empty():
		return arena.get_center()
	var marker := marker_normalized_for_target(target, marker_name)
	var movement_config := _movement_config(target)
	var draw_size := _vector2_from_config(movement_config.get("visualDrawSize", {"x": 520.0, "y": 520.0}), Vector2(520.0, 520.0))
	var scale_vector := boss.get("visualScaleVector", Vector2.ONE) as Vector2
	var local := Vector2(marker.x * draw_size.x * 0.5 * scale_vector.x, marker.y * draw_size.y * 0.5 * scale_vector.y)
	local = local.rotated(float(boss.get("visualRotation", 0.0)))
	return Vector2(boss.get("pos", arena.get_center())) + Vector2(boss.get("visualOffset", Vector2.ZERO)) + local

static func marker_normalized_for_target(target: Node, marker_name: String) -> Vector2:
	var config: Dictionary = target.get("relay_mode_config") as Dictionary
	var boss_config: Dictionary = config.get("boss", {}) as Dictionary
	var markers: Dictionary = boss_config.get("muzzleMarkers", {}) as Dictionary
	var raw: Variant = markers.get(marker_name, null)
	if raw is Dictionary:
		return Vector2(float((raw as Dictionary).get("x", 0.0)), float((raw as Dictionary).get("y", 0.0)))
	return MARKER_DEFAULTS.get(marker_name, Vector2.ZERO) as Vector2

static func safe_anchor_for_target(target: Node, arena: Rect2, anchor_id: String) -> String:
	var requested := anchor_id if ANCHOR_NORMALIZED.has(anchor_id) else "center"
	var player := Vector2(target.get("player_pos"))
	var requested_position := anchor_position_for_target(target, arena, requested)
	if requested_position.distance_to(player) >= minimum_player_distance(target):
		return requested
	if requested == "center":
		return ""
	return _choose_anchor(ensure_for_target(target), _active_boss(target), arena, target)

static func _choose_anchor(runtime: Dictionary, boss: Dictionary, arena: Rect2, target: Node) -> String:
	var current := String(runtime.get("anchor_id", "center"))
	var previous := String(runtime.get("previous_anchor_id", ""))
	var boss_pos := Vector2(boss.get("pos", arena.get_center()))
	var player := Vector2(target.get("player_pos"))
	var navigation := navigation_rect_for_target(target, arena)
	var safe_rect := safe_center_rect_for_target(target, navigation)
	var candidates: Array[Dictionary] = []
	for key in ANCHOR_NORMALIZED.keys():
		var candidate_id := String(key)
		if candidate_id == current or candidate_id == previous:
			continue
		var position := anchor_position_for_target(target, arena, candidate_id)
		if safe_rect.size.x <= 1.0 or safe_rect.size.y <= 1.0:
			position = navigation.get_center()
		var player_distance := position.distance_to(player)
		if player_distance < minimum_player_distance(target):
			continue
		candidates.append({"id": candidate_id, "position": position, "distance": boss_pos.distance_to(position), "playerDistance": player_distance})
	if candidates.is_empty():
		return ""
	var farthest := 0.0
	for candidate in candidates:
		farthest = maxf(farthest, float(candidate.get("distance", 0.0)))
	var configured_min := maxf(float(_movement_config(target).get("minimumTravelDistance", 400.0)), navigation.size.x * float(_movement_config(target).get("minimumTravelWidthRate", 0.30)))
	var effective_min := configured_min
	var far_candidates: Array[Dictionary] = []
	for candidate in candidates:
		if float(candidate.get("distance", 0.0)) >= effective_min:
			far_candidates.append(candidate)
	if far_candidates.is_empty():
		effective_min = minf(configured_min, farthest * 0.85)
		for candidate in candidates:
			if float(candidate.get("distance", 0.0)) >= effective_min:
				far_candidates.append(candidate)
	if far_candidates.is_empty():
		far_candidates = candidates
	var total_weight := 0.0
	for candidate in far_candidates:
		var weight := pow(maxf(0.01, float(candidate.get("distance", 0.0))) / maxf(1.0, farthest), 2.0)
		candidate["weight"] = weight
		total_weight += weight
	var rng: RandomNumberGenerator = target.get("rng") as RandomNumberGenerator
	var roll := rng.randf_range(0.0, total_weight) if rng != null else 0.0
	for candidate in far_candidates:
		roll -= float(candidate.get("weight", 0.0))
		if roll <= 0.0:
			return String(candidate.get("id", "center"))
	return String((far_candidates.back() as Dictionary).get("id", "center"))

static func _move_boss_toward(boss: Dictionary, destination: Vector2, arena: Rect2, duration: float, delta: float, _phase_transition: bool) -> bool:
	var position := Vector2(boss.get("pos", arena.get_center()))
	var distance := position.distance_to(destination)
	if distance <= 2.0:
		boss["pos"] = destination
		return true
	var speed := distance / maxf(0.05, duration)
	boss["pos"] = position.move_toward(destination, speed * delta)
	return Vector2(boss.get("pos", position)).distance_to(destination) <= 2.0

static func _roll_attack_limit(target: Node) -> int:
	var values: Array = _movement_config(target).get("attacksPerAnchor", [[2, 2]]) as Array
	var phase := clampi(int(target.get("relay_boss_phase")), 0, maxi(0, values.size() - 1))
	if values.is_empty():
		return 2
	var raw: Variant = values[phase]
	if raw is Array and not (raw as Array).is_empty():
		var range_values: Array = raw as Array
		var low := maxi(1, int(range_values[0]))
		var high := maxi(low, int(range_values[mini(1, range_values.size() - 1)]))
		var rng: RandomNumberGenerator = target.get("rng") as RandomNumberGenerator
		return rng.randi_range(low, high) if rng != null else low
	return 2

static func attack_limit_for_target(target: Node) -> int:
	var runtime := ensure_for_target(target)
	var value := int(runtime.get("attack_limit", 0))
	if value <= 0:
		value = _roll_attack_limit(target)
		runtime["attack_limit"] = value
	if _movement_up_instruction_active(target):
		return 1
	return value

static func _movement_up_instruction_active(target: Node) -> bool:
	var instruction: Dictionary = target.get("relay_boss_instruction") as Dictionary
	return String(instruction.get("id", "")) == "relay_boss_movement_up" and float(target.get("relay_boss_instruction_timer")) > 0.0

static func reposition_warning_seconds(target: Node) -> float:
	return maxf(0.05, float(_movement_config(target).get("repositionWarningSeconds", 0.4)))

static func arrival_distance(target: Node) -> float:
	return maxf(2.0, float(_movement_config(target).get("arrivalDistance", 10.0)))

static func minimum_player_distance(target: Node) -> float:
	var movement_distance := float(_movement_config(target).get("minimumPlayerDistance", 220.0))
	var config: Dictionary = target.get("relay_mode_config") as Dictionary
	var boss_config: Dictionary = config.get("boss", {}) as Dictionary
	var contact_config: Dictionary = boss_config.get("contact", {}) as Dictionary
	var contact_distance := float(contact_config.get("minimumDestinationPlayerDistance", movement_distance))
	return maxf(0.0, maxf(movement_distance, contact_distance))

static func _travel_attack_count(target: Node) -> int:
	var config := _movement_config(target)
	var low := maxi(2, int(config.get("travelVolleyCountMin", 2)))
	var high := maxi(low, int(config.get("travelVolleyCountMax", 3)))
	var rng: RandomNumberGenerator = target.get("rng") as RandomNumberGenerator
	return rng.randi_range(low, high) if rng != null else low

static func _update_travel_attacks(target: Node, runtime: Dictionary, arena: Rect2, travel_vector: Vector2) -> void:
	var emitted := int(runtime.get("travel_attacks_emitted", 0))
	var total := int(runtime.get("travel_attack_count", 0))
	if emitted >= total:
		return
	var timer := float(runtime.get("travel_timer", 0.0))
	if timer < float(runtime.get("travel_next_attack_timer", 0.5)):
		return
	var attack_id := _pick_travel_attack(target, runtime)
	if target.has_method("_relay_boss_emit_travel_attack"):
		target.call("_relay_boss_emit_travel_attack", attack_id, arena, {"travelDirection": travel_vector.normalized()})
	runtime["travel_last_attack"] = attack_id
	runtime["travel_attacks_emitted"] = emitted + 1
	var config := _movement_config(target)
	var interval_min := maxf(0.12, float(config.get("travelVolleyIntervalMin", 0.45)))
	var interval_max := maxf(interval_min, float(config.get("travelVolleyIntervalMax", 0.65)))
	var rng: RandomNumberGenerator = target.get("rng") as RandomNumberGenerator
	var interval := rng.randf_range(interval_min, interval_max) if rng != null else interval_min
	runtime["travel_next_attack_timer"] = timer + interval

static func _pick_travel_attack(target: Node, runtime: Dictionary) -> String:
	var rng: RandomNumberGenerator = target.get("rng") as RandomNumberGenerator
	var roll := rng.randf() if rng != null else 0.0
	if roll < 0.60:
		return "travel_comment_salvo"
	if roll < 0.90:
		return "travel_noise_shot"
	# A summon is deliberately conditional; when the summon cap is full the
	# target callback safely downgrades this volley to a small noise shot.
	return "travel_noise_summon"

static func _choose_cruise_destination(target: Node, boss: Dictionary, arena: Rect2) -> Vector2:
	var navigation := navigation_rect_for_target(target, arena)
	var safe_rect := safe_center_rect_for_target(target, navigation)
	if safe_rect.size.x <= 1.0 or safe_rect.size.y <= 1.0:
		return navigation.get_center()
	var origin := Vector2(boss.get("pos", navigation.get_center()))
	var rng: RandomNumberGenerator = target.get("rng") as RandomNumberGenerator
	var angle := rng.randf_range(0.0, TAU) if rng != null else 0.0
	var distance := rng.randf_range(80.0, 180.0) if rng != null else 120.0
	var candidate := origin + Vector2.from_angle(angle) * distance
	return Vector2(
		clampf(candidate.x, safe_rect.position.x, safe_rect.end.x),
		clampf(candidate.y, safe_rect.position.y, safe_rect.end.y)
	)

static func _vector2_from_config(value: Variant, fallback: Vector2) -> Vector2:
	if value is Vector2:
		return value as Vector2
	if value is Dictionary:
		var data: Dictionary = value as Dictionary
		return Vector2(float(data.get("x", fallback.x)), float(data.get("y", fallback.y)))
	return fallback

static func _update_visual_history(target: Node, runtime: Dictionary, boss: Dictionary, delta: float) -> void:
	var current := Vector2(boss.get("pos", Vector2.ZERO))
	var previous := Vector2(runtime.get("last_boss_pos", current))
	var afterimages: Array = boss.get("afterimages", []) as Array
	var kept: Array = []
	for item in afterimages:
		var image: Dictionary = item as Dictionary
		image["life"] = float(image.get("life", 0.0)) - delta
		if float(image.get("life", 0.0)) > 0.0:
			kept.append(image)
	if String(runtime.get("state", STATE_HOVER)) == STATE_REPOSITION and current.distance_to(previous) >= 3.0:
		kept.append({
			"pos": previous,
			"rotation": float(boss.get("visualRotation", 0.0)),
			"scaleVector": boss.get("visualScaleVector", Vector2.ONE),
			"life": 0.18,
			"maxLife": 0.18
		})
	while kept.size() > 2:
		kept.pop_front()
	boss["afterimages"] = kept
	runtime["last_boss_pos"] = current
	var movement_config := _movement_config(target)
	var draw_size := _vector2_from_config(movement_config.get("visualDrawSize", {"x": 520.0, "y": 520.0}), Vector2(520.0, 520.0))
	var desired_shadow := current + Vector2(0.0, draw_size.y * 0.37)
	var old_shadow := Vector2(boss.get("shadowPos", desired_shadow))
	boss["shadowPos"] = old_shadow.lerp(desired_shadow, clampf(delta * 4.0, 0.0, 1.0))

static func _movement_config(target: Node) -> Dictionary:
	var config: Dictionary = target.get("relay_mode_config") as Dictionary
	return (config.get("boss", {}) as Dictionary).get("movement", {}) as Dictionary

static func _active_boss(target: Node) -> Dictionary:
	for item in target.get("enemies") as Array:
		var enemy: Dictionary = item as Dictionary
		if bool(enemy.get("relayBoss", false)) or String(enemy.get("bossId", "")) == "last_offline" or String(enemy.get("kind", "")) == "last_offline":
			return enemy
	return {}

static func _apply_visual_state(target: Node, runtime: Dictionary) -> void:
	var boss := _active_boss(target)
	if boss.is_empty():
		return
	var movement_config := _movement_config(target)
	var pattern_time := float(runtime.get("pattern_time", 0.0))
	var hover_amplitude := float(movement_config.get("hoverAmplitude", 6.0))
	var hover_cycle := maxf(0.1, float(movement_config.get("hoverCycleSeconds", 1.4)))
	var tilt_degrees := float(movement_config.get("tiltDegrees", 1.5))
	var tilt_cycle := maxf(0.1, float(movement_config.get("tiltCycleSeconds", 2.0)))
	var telegraph_pulse := 0.0
	var attack: Dictionary = target.get("relay_boss_active_attack") as Dictionary
	if String(attack.get("state", "")) == "telegraph":
		telegraph_pulse = 1.0
	var state := String(runtime.get("state", STATE_HOVER))
	var navigation := navigation_rect_for_target(target, target.call("_current_arena") if target.has_method("_current_arena") else Rect2())
	var safe_rect := safe_center_rect_for_target(target, navigation)
	var fit_scale := Vector2.ONE if safe_rect.size.x > 1.0 and safe_rect.size.y > 1.0 else Vector2(0.94, 0.94)
	var drift := Vector2(0.0, sin(pattern_time * TAU / hover_cycle) * hover_amplitude)
	var rotation := deg_to_rad(sin(pattern_time * TAU / tilt_cycle) * tilt_degrees)
	var scale_vector := fit_scale * (1.0 + telegraph_pulse * 0.04)
	if state == STATE_REPOSITION_WARNING:
		var warning_ratio := clampf(float(runtime.get("reposition_warning_timer", 0.0)) / maxf(0.01, reposition_warning_seconds(target)), 0.0, 1.0)
		scale_vector *= 1.0 + (1.0 - warning_ratio) * 0.035
	if state == STATE_REPOSITION:
		var direction := Vector2(runtime.get("target", boss.get("pos", Vector2.ZERO))) - Vector2(boss.get("pos", Vector2.ZERO))
		if direction.length_squared() > 1.0:
			rotation = lerp_angle(rotation, direction.angle() * 0.035, 0.75)
			scale_vector *= Vector2(0.98, 1.02)
	boss["visualOffset"] = drift
	boss["visualRotation"] = rotation
	boss["visualScaleVector"] = scale_vector
	boss["visualScale"] = (scale_vector.x + scale_vector.y) * 0.5
	boss["shadowScale"] = 1.0 - sin(pattern_time * TAU / hover_cycle) * 0.04
