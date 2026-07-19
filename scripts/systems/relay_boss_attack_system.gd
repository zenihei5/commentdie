class_name RelayBossAttackSystem
extends RefCounted

const EnemySystemScript := preload("res://scripts/systems/enemy_system.gd")

const STATE_IDLE := "idle"
const STATE_TELEGRAPH := "telegraph"
const STATE_ACTIVE := "active"
const STATE_RECOVERY := "recovery"

const ATTACK_IDS: Array[String] = [
	"comment_shotgun", "offline_laser", "noise_summon",
	"kuso_maro_drop", "long_comment_line",
	"race_lane_charge", "game_over_barrage", "fake_gift_trap",
	"howling_ring", "pitch_wave", "rhythm_explosion",
	"dirty_paint", "eraser_sweep", "paint_warning",
	"division_noise", "collab_break", "all_genre_rush"
]

const LARGE_ATTACK_IDS := [
	"offline_laser", "game_over_barrage", "rhythm_explosion",
	"eraser_sweep", "paint_warning", "collab_break", "all_genre_rush"
]

static func empty_runtime() -> Dictionary:
	return {
		"active_attack": _empty_attack(),
		"hazards": [],
		"reuse_cooldowns": {},
		"last_attack_id": "",
		"last_attack_was_large": false,
		"pending_comment": false,
		"pending_phase": -1,
		"gameplay_variant": "",
		"arena_warning_timer": 0.0,
		"collab_break_uid": -1,
		"serial": 0,
		"debug_overlay": false,
		"debug_forced_attack": ""
		,"pending_attack": {},
		"noise_summon_cooldown": 0.0,
		"noise_summon_after_wave_lock": 0.0,
		"noise_summon_after_protected_attack_lock": 0.0,
		"noise_summon_wave_serial": 0,
		"noise_summon_pending_wave": {},
		"sync_star_drop_cooldown": 0.0,
		"sync_star_carrier_uid": -1
	}

static func reset_for_target(target: Node) -> void:
	target.set("relay_boss_runtime", empty_runtime())
	target.set("relay_boss_active_attack", {})

static func ensure_for_target(target: Node) -> Dictionary:
	var value: Variant = target.get("relay_boss_runtime")
	if value is Dictionary and not (value as Dictionary).is_empty():
		return value as Dictionary
	var runtime := empty_runtime()
	target.set("relay_boss_runtime", runtime)
	return runtime

static func active_attack_for_target(target: Node) -> Dictionary:
	return ensure_for_target(target).get("active_attack", {}) as Dictionary

static func is_busy_for_target(target: Node) -> bool:
	var state := String(active_attack_for_target(target).get("state", STATE_IDLE))
	return state == STATE_TELEGRAPH or state == STATE_ACTIVE

static func is_attack_in_progress_for_target(target: Node) -> bool:
	return String(active_attack_for_target(target).get("state", STATE_IDLE)) != STATE_IDLE

static func can_open_instruction_for_target(target: Node) -> bool:
	var state := String(active_attack_for_target(target).get("state", STATE_IDLE))
	return state == STATE_IDLE or state == STATE_RECOVERY

static func update_for_target(target: Node, delta: float, arena: Rect2, rng: RandomNumberGenerator, freeze_gameplay: bool = false) -> Dictionary:
	var runtime := ensure_for_target(target)
	var feedback := {"damageEvents": [], "chats": [], "toasts": []}
	if not bool(target.get("relay_boss_active")):
		return feedback
	if freeze_gameplay:
		_sync_legacy_attack_field(target, runtime)
		return feedback
	_decay_reuse_cooldowns(runtime, delta)
	_decay_noise_runtime(target, runtime, delta)
	_sync_noise_carrier_uid(target, runtime)
	_update_pending_noise_wave(target, runtime, delta, arena, rng)
	var active := runtime.get("active_attack", {}) as Dictionary
	var state := String(active.get("state", STATE_IDLE))
	var movement_state := RelayBossMovementSystem.state_for_target(target)
	if state == STATE_IDLE and movement_state != RelayBossMovementSystem.STATE_HOVER and movement_state != RelayBossMovementSystem.STATE_CRUISING:
		_sync_legacy_attack_field(target, runtime)
		return feedback
	if state == STATE_IDLE and float((RelayBossMovementSystem.ensure_for_target(target)).get("resume_timer", 0.0)) > 0.0:
		_sync_legacy_attack_field(target, runtime)
		return feedback
	match state:
		STATE_TELEGRAPH:
			_update_telegraph(target, runtime, active, delta, arena, rng)
		STATE_ACTIVE:
			_update_active(target, runtime, active, delta, arena, rng, feedback)
		STATE_RECOVERY:
			_update_recovery(target, runtime, active, delta)
		_:
			var pending: Dictionary = runtime.get("pending_attack", {}) as Dictionary
			if not pending.is_empty():
				_start_or_queue_attack(target, runtime, String(pending.get("id", "")), arena, rng, bool(pending.get("forced", false)))
				var pending_active: Dictionary = runtime.get("active_attack", {}) as Dictionary
				if String(pending_active.get("state", STATE_IDLE)) != STATE_IDLE:
					runtime["pending_attack"] = {}
			else:
				_pick_and_begin(target, runtime, arena, rng)
	_sync_legacy_attack_field(target, runtime)
	return feedback

static func force_attack_for_target(target: Node, attack_id: String) -> bool:
	if not ATTACK_IDS.has(attack_id):
		return false
	var runtime := ensure_for_target(target)
	clear_runtime_objects_for_target(target, false)
	var arena: Rect2 = target.call("_current_arena")
	var rng: RandomNumberGenerator = target.get("rng")
	_start_or_queue_attack(target, runtime, attack_id, arena, rng, true)
	runtime["debug_forced_attack"] = attack_id
	_sync_legacy_attack_field(target, runtime)
	return true

static func resume_after_phase_transition_for_target(target: Node, arena: Rect2, rng: RandomNumberGenerator) -> bool:
	if not bool(target.get("relay_boss_active")):
		return false
	var runtime := ensure_for_target(target)
	var active: Dictionary = runtime.get("active_attack", {}) as Dictionary
	var state := String(active.get("state", STATE_IDLE))
	if state != STATE_IDLE and state != STATE_RECOVERY:
		return false
	if RelayBossMovementSystem.state_for_target(target) != RelayBossMovementSystem.STATE_HOVER:
		return false
	var movement := RelayBossMovementSystem.ensure_for_target(target)
	if float(movement.get("resume_timer", 0.0)) > 0.0:
		return false
	runtime["active_attack"] = _empty_attack()
	runtime["pending_attack"] = {}
	runtime["last_attack_was_large"] = false
	_pick_and_begin(target, runtime, arena, rng)
	var started: Dictionary = runtime.get("active_attack", {}) as Dictionary
	if String(started.get("state", STATE_IDLE)) == STATE_IDLE:
		# This is only reached when every weighted candidate is filtered out.
		# Keep the boss active rather than leaving an invisible, invulnerable
		# looking idle state after a phase transition.
		_start_or_queue_attack(target, runtime, "comment_shotgun", arena, rng, true)
	_sync_legacy_attack_field(target, runtime)
	return String((runtime.get("active_attack", {}) as Dictionary).get("state", STATE_IDLE)) != STATE_IDLE

static func interrupt_for_target(target: Node, reason: String = "") -> void:
	var runtime := ensure_for_target(target)
	var active := runtime.get("active_attack", {}) as Dictionary
	active["state"] = STATE_RECOVERY
	active["timer"] = 0.0
	active["elapsed"] = 0.0
	runtime["active_attack"] = active
	clear_runtime_objects_for_target(target, false)
	target.set("collab_boss_partner_muted", false)
	if reason == "combo" or reason == "combo_ready":
		RelayBossMovementSystem.interrupt_for_target(target, RelayBossMovementSystem.STATE_STUNNED)
	else:
		RelayBossMovementSystem.on_attack_finished(target)
	_sync_legacy_attack_field(target, runtime)

static func clear_runtime_objects_for_target(target: Node, clear_attack: bool = true) -> void:
	var runtime := ensure_for_target(target)
	runtime["hazards"] = []
	runtime["noise_summon_pending_wave"] = {}
	runtime["collab_break_uid"] = -1
	if clear_attack:
		runtime["active_attack"] = _empty_attack()
		runtime["pending_attack"] = {}
	var bullets: Array = target.get("enemy_bullets")
	var kept: Array = []
	for item in bullets:
		var bullet: Dictionary = item as Dictionary
		if not bool(bullet.get("relayBossProjectile", false)):
			kept.append(bullet)
	target.set("enemy_bullets", kept)
	target.set("collab_boss_partner_muted", false)
	_sync_legacy_attack_field(target, runtime)

static func set_debug_overlay_for_target(target: Node, enabled: bool) -> void:
	var runtime := ensure_for_target(target)
	runtime["debug_overlay"] = enabled

static func has_handler(attack_id: String) -> bool:
	return ATTACK_IDS.has(attack_id)

static func handler_name(attack_id: String) -> String:
	return "_handle_" + attack_id if ATTACK_IDS.has(attack_id) else ""

static func _empty_attack() -> Dictionary:
	return {"id": "", "state": STATE_IDLE, "timer": 0.0, "elapsed": 0.0, "serial": 0, "large": false, "payload": {}}

static func _sync_legacy_attack_field(target: Node, runtime: Dictionary) -> void:
	target.set("relay_boss_active_attack", (runtime.get("active_attack", {}) as Dictionary).duplicate(true))

static func _decay_reuse_cooldowns(runtime: Dictionary, delta: float) -> void:
	var cooldowns: Dictionary = runtime.get("reuse_cooldowns", {}) as Dictionary
	for key in cooldowns.keys():
		cooldowns[key] = maxf(0.0, float(cooldowns[key]) - delta)
	runtime["reuse_cooldowns"] = cooldowns

static func _decay_noise_runtime(_target: Node, runtime: Dictionary, delta: float) -> void:
	runtime["noise_summon_cooldown"] = maxf(0.0, float(runtime.get("noise_summon_cooldown", 0.0)) - delta)
	runtime["noise_summon_after_wave_lock"] = maxf(0.0, float(runtime.get("noise_summon_after_wave_lock", 0.0)) - delta)
	runtime["noise_summon_after_protected_attack_lock"] = maxf(0.0, float(runtime.get("noise_summon_after_protected_attack_lock", 0.0)) - delta)
	runtime["sync_star_drop_cooldown"] = maxf(0.0, float(runtime.get("sync_star_drop_cooldown", 0.0)) - delta)

static func _sync_noise_carrier_uid(target: Node, runtime: Dictionary) -> void:
	var carrier_uid := int(runtime.get("sync_star_carrier_uid", -1))
	if carrier_uid < 0:
		return
	for item in target.get("enemies") as Array:
		var enemy: Dictionary = item as Dictionary
		if int(enemy.get("uid", -1)) != carrier_uid:
			continue
		if bool(enemy.get("syncStarCarrier", false)) and not bool(enemy.get("defeatResolved", false)) and float(enemy.get("relayBossSummonLifetime", 1.0)) > 0.0:
			return
	runtime["sync_star_carrier_uid"] = -1

static func _pick_and_begin(target: Node, runtime: Dictionary, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var boss_config: Dictionary = target.get("relay_mode_config").get("boss", {}) as Dictionary
	var attacks: Dictionary = boss_config.get("attacks", {}) as Dictionary
	var phase := int(target.get("relay_boss_phase"))
	var phase_names: Array[String] = ["zatsudan", "gameplay", "singing", "drawing", "collab_final"]
	var phase_name := phase_names[clampi(phase, 0, phase_names.size() - 1)]
	var previous := String(runtime.get("last_attack_id", ""))
	var previous_large := bool(runtime.get("last_attack_was_large", false))
	var movement_state := RelayBossMovementSystem.state_for_target(target)
	var candidates: Array = []
	var total := 0.0
	for attack_id in ATTACK_IDS:
		var payload: Dictionary = _normalized_payload(attack_id, attacks.get(attack_id, {}) as Dictionary)
		var stage := String(payload.get("stage", "common"))
		if stage != "common" and stage != phase_name:
			continue
		if float((runtime.get("reuse_cooldowns", {}) as Dictionary).get(attack_id, 0.0)) > 0.0:
			continue
		if attack_id == previous:
			continue
		if movement_state == RelayBossMovementSystem.STATE_CRUISING and RelayBossMovementSystem.movement_policy_for_attack(attack_id) != "mobile":
			continue
		if previous_large and bool(payload.get("large", false)):
			continue
		if attack_id == "noise_summon" and not can_start_noise_summon_for_target(target, runtime, payload, movement_state):
			continue
		var noise_payload: Dictionary = _noise_payload_for_target(target)
		var protected_ids: Array = noise_payload.get("protectedAttackIds", []) as Array
		if protected_ids.has(attack_id) and float(runtime.get("noise_summon_after_wave_lock", 0.0)) > 0.0:
			continue
		if attack_id == "noise_summon" and float(runtime.get("noise_summon_after_protected_attack_lock", 0.0)) > 0.0:
			continue
		if bool(payload.get("requiresFullArena", false)) and arena.size.x < 600.0:
			continue
		var allowed_phases: Array = payload.get("phases", []) as Array
		if not allowed_phases.is_empty() and not allowed_phases.has(phase):
			continue
		var weight := maxf(0.01, float(payload.get("weight", 1.0)))
		candidates.append({"id": attack_id, "weight": weight})
		total += weight
	if candidates.is_empty():
		runtime["last_attack_was_large"] = false
		# Cooldowns and phase filters may temporarily remove every weighted
		# candidate. Keep the boss active instead of leaving it permanently idle.
		_start_or_queue_attack(target, runtime, "comment_shotgun", arena, rng, true)
		return
	var roll := rng.randf_range(0.0, total)
	for candidate in candidates:
		roll -= float((candidate as Dictionary).get("weight", 0.0))
		if roll <= 0.0:
			_start_or_queue_attack(target, runtime, String((candidate as Dictionary).get("id", "")), arena, rng)
			return
	_start_or_queue_attack(target, runtime, String((candidates.back() as Dictionary).get("id", "")), arena, rng)

static func _start_or_queue_attack(target: Node, runtime: Dictionary, attack_id: String, arena: Rect2, rng: RandomNumberGenerator, forced: bool = false) -> void:
	var policy := RelayBossMovementSystem.movement_policy_for_attack(attack_id)
	if policy == "reposition_then_lock":
		var movement := RelayBossMovementSystem.ensure_for_target(target)
		var current_anchor := String(movement.get("anchor_id", "center"))
		var queued: Dictionary = runtime.get("pending_attack", {}) as Dictionary
		var required_anchor := String(queued.get("requiredAnchor", ""))
		if required_anchor == "":
			required_anchor = RelayBossMovementSystem.required_anchor_for_attack(attack_id, target, rng)
		var safe_required_anchor := RelayBossMovementSystem.safe_anchor_for_target(target, arena, required_anchor)
		if safe_required_anchor == "":
			# Central all-genre rushes wait until the player leaves the unsafe
			# center; other required attacks may use a safe alternate anchor.
			return
		required_anchor = safe_required_anchor
		var boss_pos := _boss_origin(target, arena)
		var required_pos := RelayBossMovementSystem.anchor_position_for_target(target, arena, required_anchor)
		if current_anchor != required_anchor or boss_pos.distance_to(required_pos) > 8.0:
			runtime["pending_attack"] = {"id": attack_id, "forced": forced, "requiredAnchor": required_anchor}
			RelayBossMovementSystem.request_anchor(target, arena, required_anchor)
			return
	_begin_attack(target, runtime, attack_id, arena, rng, forced)

static func _begin_attack(target: Node, runtime: Dictionary, attack_id: String, arena: Rect2, rng: RandomNumberGenerator, forced: bool = false) -> void:
	var boss_config: Dictionary = target.get("relay_mode_config").get("boss", {}) as Dictionary
	var attacks: Dictionary = boss_config.get("attacks", {}) as Dictionary
	var payload := _normalized_payload(attack_id, attacks.get(attack_id, {}) as Dictionary)
	var serial := int(runtime.get("serial", 0)) + 1
	var active := _empty_attack()
	active["id"] = attack_id
	active["state"] = STATE_TELEGRAPH
	active["timer"] = float(payload.get("telegraph", 0.8))
	active["elapsed"] = 0.0
	active["serial"] = serial
	active["payload"] = payload
	active["movementPolicy"] = String(payload.get("movementPolicy", RelayBossMovementSystem.movement_policy_for_attack(attack_id)))
	active["large"] = bool(payload.get("large", attack_id in LARGE_ATTACK_IDS))
	runtime["serial"] = serial
	runtime["active_attack"] = active
	runtime["last_attack_id"] = attack_id
	runtime["last_attack_was_large"] = false
	runtime["hazards"] = []
	RelayBossMovementSystem.on_attack_started(target, attack_id, _attack_marker_origin(target, attack_id, arena))
	if not forced:
		var cooldowns: Dictionary = runtime.get("reuse_cooldowns", {}) as Dictionary
		cooldowns[attack_id] = float(payload.get("reuseCooldown", 8.0))
		runtime["reuse_cooldowns"] = cooldowns

static func _normalized_payload(attack_id: String, source: Dictionary) -> Dictionary:
	var payload := _default_payload(attack_id)
	for key in source.keys():
		payload[key] = source[key]
	if source.has("warning") and not source.has("telegraph"):
		payload["telegraph"] = float(source.get("warning", 0.8))
	if source.has("duration") and not source.has("activeDuration"):
		payload["activeDuration"] = float(source.get("duration", 1.0))
	if source.has("cooldown") and not source.has("reuseCooldown"):
		payload["reuseCooldown"] = float(source.get("cooldown", 8.0))
	return payload

static func _default_payload(attack_id: String) -> Dictionary:
	var result := {"weight": 1.0, "telegraph": 0.8, "activeDuration": 1.0, "recovery": 0.6, "reuseCooldown": 8.0, "large": attack_id in LARGE_ATTACK_IDS, "requiresFullArena": false}
	match attack_id:
		"offline_laser": result["telegraph"] = 1.1; result["activeDuration"] = 0.8; result["recovery"] = 0.8; result["large"] = true
		"noise_summon": result["telegraph"] = 1.0; result["activeDuration"] = 0.1
		"race_lane_charge": result["telegraph"] = 1.2; result["activeDuration"] = 1.8
		"game_over_barrage": result["activeDuration"] = 4.5; result["recovery"] = 1.0; result["large"] = true
		"howling_ring": result["activeDuration"] = 2.25
		"pitch_wave": result["activeDuration"] = 3.0
		"rhythm_explosion": result["telegraph"] = 1.4; result["activeDuration"] = 2.65; result["recovery"] = 1.0; result["large"] = true
		"dirty_paint": result["activeDuration"] = 7.0
		"eraser_sweep": result["telegraph"] = 1.2; result["recovery"] = 0.9; result["large"] = true
		"paint_warning": result["telegraph"] = 1.4; result["activeDuration"] = 2.5; result["recovery"] = 1.0; result["large"] = true
		"division_noise": result["activeDuration"] = 4.0
		"collab_break": result["activeDuration"] = 10.0; result["recovery"] = 1.0; result["large"] = true
		"all_genre_rush": result["telegraph"] = 1.2; result["activeDuration"] = 2.5; result["recovery"] = 2.0; result["large"] = true
	return result

static func _update_telegraph(target: Node, runtime: Dictionary, active: Dictionary, delta: float, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var prepared_this_tick := false
	if String(active.get("id", "")) == "noise_summon" and (runtime.get("noise_summon_pending_wave", {}) as Dictionary).is_empty():
		var payload: Dictionary = active.get("payload", {}) as Dictionary
		var remaining := float(active.get("timer", 0.0))
		if remaining <= float(payload.get("spawnWarningSeconds", 0.6)):
			prepared_this_tick = _prepare_noise_summon_wave(target, runtime, payload, arena, rng, "main_attack", -1)
			if prepared_this_tick:
				var pending: Dictionary = runtime.get("noise_summon_pending_wave", {}) as Dictionary
				pending["warningTimer"] = remaining
				runtime["noise_summon_pending_wave"] = pending
	if prepared_this_tick:
		_update_pending_noise_wave(target, runtime, delta, arena, rng)
	active["timer"] = float(active.get("timer", 0.0)) - delta
	active["elapsed"] = float(active.get("elapsed", 0.0)) + delta
	if float(active["timer"]) > 0.0:
		return
	active["state"] = STATE_ACTIVE
	active["timer"] = float((active.get("payload", {}) as Dictionary).get("activeDuration", 1.0))
	active["elapsed"] = 0.0
	_activate_dedicated(target, runtime, active, arena, rng)

static func _update_active(target: Node, runtime: Dictionary, active: Dictionary, delta: float, arena: Rect2, rng: RandomNumberGenerator, feedback: Dictionary) -> void:
	active["timer"] = float(active.get("timer", 0.0)) - delta
	active["elapsed"] = float(active.get("elapsed", 0.0)) + delta
	var id := String(active.get("id", ""))
	if id == "game_over_barrage":
		_handle_game_over_barrage(target, runtime, active, arena, rng)
	elif id == "collab_break":
		_handle_collab_break(target, runtime, active)
	elif id == "all_genre_rush":
		_handle_all_genre_rush(target, runtime, active, delta, arena, rng)
	_update_pending_noise_wave(target, runtime, 0.0, arena, rng)
	_process_hazards(target, runtime, active, delta, arena, feedback)
	if float(active.get("timer", 0.0)) > 0.0:
		return
	active["state"] = STATE_RECOVERY
	active["timer"] = float((active.get("payload", {}) as Dictionary).get("recovery", 0.6))
	active["elapsed"] = 0.0
	runtime["last_attack_was_large"] = bool(active.get("large", false))

static func _update_recovery(target: Node, runtime: Dictionary, active: Dictionary, delta: float) -> void:
	active["timer"] = float(active.get("timer", 0.0)) - delta
	if float(active.get("timer", 0.0)) <= 0.0:
		if _protected_attack_ids_for_target(target).has(String(active.get("id", ""))):
			runtime["noise_summon_after_protected_attack_lock"] = float(_noise_payload_for_target(target).get("postProtectedAttackSummonSeconds", 1.0))
		if String(active.get("id", "")) == "all_genre_rush":
			runtime["gameplay_variant"] = ""
		runtime["active_attack"] = _empty_attack()
		runtime["hazards"] = []
		target.set("collab_boss_partner_muted", false)
		RelayBossMovementSystem.on_attack_finished(target)

static func _activate_dedicated(target: Node, runtime: Dictionary, active: Dictionary, arena: Rect2, rng: RandomNumberGenerator) -> void:
	match String(active.get("id", "")):
		"comment_shotgun": _handle_comment_shotgun(target, active, arena)
		"offline_laser": _handle_offline_laser(target, runtime, active, arena)
		"noise_summon": _handle_noise_summon(target, active, arena, rng)
		"kuso_maro_drop": _handle_kuso_maro_drop(target, runtime, active, arena, rng)
		"long_comment_line": _handle_long_comment_line(runtime, active, arena)
		"race_lane_charge": _handle_race_lane_charge(runtime, active, arena)
		"game_over_barrage": active["nextShot"] = 0.0
		"fake_gift_trap": _handle_fake_gift_trap(target, runtime, active, arena, rng)
		"howling_ring": _handle_howling_ring(target, runtime, active, arena)
		"pitch_wave": _handle_pitch_wave(runtime, active, arena)
		"rhythm_explosion": _handle_rhythm_explosion(target, runtime, active, arena)
		"dirty_paint": _handle_dirty_paint(runtime, active, arena)
		"eraser_sweep": _handle_eraser_sweep(runtime, active, arena)
		"paint_warning": _handle_paint_warning(target, runtime, active, arena)
		"division_noise": _handle_division_noise(target, runtime, active, arena, rng)
		"collab_break": _handle_collab_break_start(target, runtime, active, arena, rng)
		"all_genre_rush": _handle_all_genre_rush_start(target, runtime, active, arena, rng)

static func _append_hazard(runtime: Dictionary, hazard: Dictionary) -> void:
	var hazards: Array = runtime.get("hazards", []) as Array
	hazards.append(hazard)
	runtime["hazards"] = hazards

static func _new_hazard(kind: String, pos: Vector2, duration: float, damage: int) -> Dictionary:
	return {"id": "%s_%d" % [kind, Time.get_ticks_usec()], "kind": kind, "pos": pos, "time": duration, "maxTime": duration, "damage": damage, "hitTimer": 0.0, "active": true}

static func _process_hazards(target: Node, runtime: Dictionary, active: Dictionary, delta: float, arena: Rect2, feedback: Dictionary) -> void:
	var player_pos := Vector2(target.get("player_pos"))
	var kept: Array = []
	for item in runtime.get("hazards", []) as Array:
		var hazard: Dictionary = item as Dictionary
		hazard["time"] = float(hazard.get("time", 0.0)) - delta
		hazard["hitTimer"] = maxf(0.0, float(hazard.get("hitTimer", 0.0)) - delta)
		if hazard.has("delay"):
			hazard["delay"] = maxf(0.0, float(hazard.get("delay", 0.0)) - delta)
		if hazard.has("vel") and float(hazard.get("delay", 0.0)) <= 0.0:
			hazard["pos"] = Vector2(hazard.get("pos", Vector2.ZERO)) + Vector2(hazard.get("vel", Vector2.ZERO)) * delta
		if float(hazard.get("delay", 0.0)) <= 0.0 and int(hazard.get("damage", 0)) > 0 and float(hazard.get("hitTimer", 0.0)) <= 0.0 and _hazard_hits_player(hazard, player_pos):
			feedback["damageEvents"].append({"source": String(hazard.get("source", "relay_boss_attack")), "damage": int(hazard.get("damage", 0)), "attackId": String(active.get("id", "")), "attackType": String(hazard.get("kind", "hazard"))})
			hazard["hitTimer"] = maxf(0.1, float(hazard.get("damageInterval", 999.0)))
		if float(hazard.get("time", 0.0)) > 0.0:
			kept.append(hazard)
	runtime["hazards"] = kept

static func _hazard_hits_player(hazard: Dictionary, player_pos: Vector2) -> bool:
	match String(hazard.get("shape", "circle")):
		"circle":
			return player_pos.distance_squared_to(Vector2(hazard.get("pos", Vector2.ZERO))) <= pow(float(hazard.get("radius", 30.0)), 2.0)
		"rect":
			return Rect2(Vector2(hazard.get("pos", Vector2.ZERO)), Vector2(hazard.get("size", Vector2(80.0, 80.0)))).has_point(player_pos)
		"ring":
			return absf(player_pos.distance_to(Vector2(hazard.get("pos", Vector2.ZERO))) - float(hazard.get("radius", 100.0))) <= float(hazard.get("width", 20.0))
		"line":
			return _distance_to_segment(player_pos, Vector2(hazard.get("from", Vector2.ZERO)), Vector2(hazard.get("to", Vector2.ZERO))) <= float(hazard.get("width", 24.0))
	return false

static func _distance_to_segment(point: Vector2, from_pos: Vector2, to_pos: Vector2) -> float:
	var segment := to_pos - from_pos
	var length_sq := segment.length_squared()
	if length_sq <= 0.001:
		return point.distance_to(from_pos)
	var ratio := clampf((point - from_pos).dot(segment) / length_sq, 0.0, 1.0)
	return point.distance_to(from_pos + segment * ratio)

static func _boss_origin(target: Node, arena: Rect2) -> Vector2:
	for item in target.get("enemies") as Array:
		var enemy: Dictionary = item as Dictionary
		if bool(enemy.get("relayBoss", false)) or String(enemy.get("bossId", "")) == "last_offline" or String(enemy.get("kind", "")) == "last_offline":
			return Vector2(enemy.get("pos", arena.get_center()))
	return arena.get_center()

static func _attack_marker_name(attack_id: String) -> String:
	match attack_id:
		"comment_shotgun", "noise_summon":
			return "ChatModule"
		"offline_laser":
			return "CoreCenter"
		"game_over_barrage":
			return "GameModule"
		"howling_ring", "pitch_wave", "rhythm_explosion":
			return "SongModule"
		"dirty_paint", "eraser_sweep", "paint_warning":
			return "DrawModule"
		"collab_break":
			return "CollabModule"
	return "MuzzleCenter"

static func _attack_marker_origin(target: Node, attack_id: String, arena: Rect2) -> Vector2:
	return RelayBossMovementSystem.marker_world_position(target, _attack_marker_name(attack_id), arena)

static func _append_bullet(target: Node, pos: Vector2, vel: Vector2, life: float, damage: int, source: String, attack_id: String) -> void:
	var bullets: Array = target.get("enemy_bullets")
	bullets.append({"pos": pos, "vel": vel, "life": life, "damage": damage, "source": source, "sourceKind": attack_id, "attackType": "projectile", "relayBossProjectile": true})
	target.set("enemy_bullets", bullets)

static func emit_travel_attack_for_target(target: Node, attack_id: String, arena: Rect2, travel_context: Dictionary = {}) -> void:
	if not bool(target.get("relay_boss_active")):
		return
	var origin := RelayBossMovementSystem.marker_world_position(target, "ChatModule", arena)
	var player_pos := Vector2(target.get("player_pos"))
	var direction := (player_pos - origin).normalized()
	if direction.length_squared() <= 0.01:
		direction = Vector2.DOWN
	var travel_direction := Vector2(travel_context.get("travelDirection", Vector2.ZERO))
	if travel_direction.length_squared() <= 0.01:
		travel_direction = direction
	var rng: RandomNumberGenerator = target.get("rng") as RandomNumberGenerator
	match attack_id:
		"travel_comment_salvo":
			for i in range(3):
				var spread := (float(i) - 1.0) * 0.18
				_append_bullet(target, origin, (-travel_direction).rotated(spread) * 230.0, 3.5, 5, "relay_boss_travel_comment", "travel_comment_salvo")
		"travel_noise_shot":
			for i in range(2):
				var jitter := rng.randf_range(-0.35, 0.35) if rng != null else 0.0
				_append_bullet(target, origin, direction.rotated(jitter) * 265.0, 3.0, 4, "relay_boss_travel_noise", "travel_noise_shot")
		"travel_noise_summon":
			var payload := _noise_payload_for_target(target)
			var runtime := ensure_for_target(target)
			if not _prepare_noise_summon_wave(target, runtime, payload, arena, rng, "travel_support", 1):
				emit_travel_attack_for_target(target, "travel_noise_shot", arena, travel_context)
				return
			_update_pending_noise_wave(target, runtime, 0.0, arena, rng)

static func _handle_comment_shotgun(target: Node, active: Dictionary, arena: Rect2) -> void:
	var payload: Dictionary = active.get("payload", {}) as Dictionary
	var origin := RelayBossMovementSystem.marker_world_position(target, "ChatModule", arena)
	var direction := (Vector2(target.get("player_pos")) - origin).normalized()
	var count := mini(12, maxi(1, int(payload.get("count", 5))))
	for i in range(count):
		_append_bullet(target, origin, direction.rotated((float(i) - float(count - 1) * 0.5) * 0.12) * 240.0, 4.0, int(payload.get("damage", 7)), "relay_boss_comment_shotgun", String(active.get("id", "")))

static func _handle_offline_laser(target: Node, runtime: Dictionary, active: Dictionary, arena: Rect2) -> void:
	var payload: Dictionary = active.get("payload", {}) as Dictionary
	var origin := Vector2(runtime.get("locked_origin", RelayBossMovementSystem.marker_world_position(target, "CoreCenter", arena)))
	var direction := (Vector2(target.get("player_pos")) - origin).normalized()
	if direction.length_squared() < 0.01:
		direction = Vector2.DOWN
	var hazard := _new_hazard("offline_laser", origin, float(payload.get("activeDuration", 0.8)), int(payload.get("damage", 16)))
	hazard["shape"] = "line"; hazard["from"] = origin; hazard["to"] = origin + direction * 900.0; hazard["width"] = 26.0; hazard["source"] = "relay_boss_offline_laser"
	_append_hazard(runtime, hazard)

static func can_start_noise_summon_for_target(target: Node, runtime: Dictionary, payload: Dictionary, movement_state: String = "") -> bool:
	return _can_prepare_noise_wave(target, runtime, payload, movement_state, false)

static func _noise_payload_for_target(target: Node) -> Dictionary:
	var config: Dictionary = target.get("relay_mode_config") as Dictionary
	var boss_config: Dictionary = config.get("boss", {}) as Dictionary
	var attacks: Dictionary = boss_config.get("attacks", {}) as Dictionary
	return _normalized_payload("noise_summon", attacks.get("noise_summon", {}) as Dictionary)

static func _protected_attack_ids_for_target(target: Node) -> Array:
	return _noise_payload_for_target(target).get("protectedAttackIds", []) as Array

static func _noise_phase_settings(payload: Dictionary, phase: int) -> Dictionary:
	var settings: Array = payload.get("phaseSettings", []) as Array
	for item in settings:
		var entry: Dictionary = item as Dictionary
		if int(entry.get("phaseIndex", -1)) == phase:
			return entry
	return {"phaseIndex": phase, "spawnCount": int(payload.get("count", 2)), "activeCap": int(payload.get("maxActive", 4))}

static func _active_noise_summon_count(target: Node) -> int:
	var count := 0
	for item in target.get("enemies") as Array:
		var enemy: Dictionary = item as Dictionary
		if not bool(enemy.get("relayBossNoiseSummon", false)):
			continue
		if bool(enemy.get("defeatPending", false)) or bool(enemy.get("defeatResolved", false)):
			continue
		if float(enemy.get("relayBossSummonLifetime", enemy.get("lifeTimer", 1.0))) <= 0.0:
			continue
		count += 1
	return count

static func _can_prepare_noise_wave(target: Node, runtime: Dictionary, payload: Dictionary, movement_state: String, allow_collab_break: bool) -> bool:
	if float(runtime.get("noise_summon_cooldown", 0.0)) > 0.0:
		return false
	if not (runtime.get("noise_summon_pending_wave", {}) as Dictionary).is_empty():
		return false
	if bool(target.get("relay_boss_defeat_pending")) or bool(target.get("relay_boss_score_awarded")):
		return false
	if movement_state == RelayBossMovementSystem.STATE_REPOSITION_WARNING or movement_state == RelayBossMovementSystem.STATE_REPOSITION or movement_state == RelayBossMovementSystem.STATE_PHASE_TRANSITION or movement_state == RelayBossMovementSystem.STATE_STUNNED:
		return false
	if String(runtime.get("gameplay_variant", "")) == "all_genre_rush":
		return false
	if target.has_method("_collab_combo_sequence_active") and bool(target.call("_collab_combo_sequence_active")):
		return false
	var active_attack: Dictionary = runtime.get("active_attack", {}) as Dictionary
	if not allow_collab_break and String(active_attack.get("id", "")) == "collab_break":
		return false
	var phase := clampi(int(target.get("relay_boss_phase")), 0, 4)
	var phase_settings := _noise_phase_settings(payload, phase)
	return _active_noise_summon_count(target) < int(phase_settings.get("activeCap", payload.get("maxActive", 4)))

static func _prepare_noise_summon_wave(target: Node, runtime: Dictionary, payload: Dictionary, arena: Rect2, rng: RandomNumberGenerator, source: String, requested_override: int) -> bool:
	if not (runtime.get("noise_summon_pending_wave", {}) as Dictionary).is_empty():
		return false
	if source == "travel_support" and float(runtime.get("noise_summon_cooldown", 0.0)) > 0.0:
		return false
	if not _can_prepare_noise_wave(target, runtime, payload, RelayBossMovementSystem.state_for_target(target), source == "collab_break_sidecar") and source != "travel_support":
		return false
	var phase := clampi(int(target.get("relay_boss_phase")), 0, 4)
	var phase_settings := _noise_phase_settings(payload, phase)
	var requested := int(phase_settings.get("spawnCount", payload.get("count", 2)))
	if requested_override >= 0:
		requested = requested_override
	requested = maxi(0, requested)
	var active_cap := int(phase_settings.get("activeCap", payload.get("maxActive", 4)))
	var available := maxi(0, active_cap - _active_noise_summon_count(target))
	requested = mini(requested, available)
	if requested <= 0:
		return false
	var positions: Array = []
	var existing_positions: Array[Vector2] = []
	for item in target.get("enemies") as Array:
		var enemy: Dictionary = item as Dictionary
		if bool(enemy.get("relayBossNoiseSummon", false)) and not bool(enemy.get("defeatPending", false)) and not bool(enemy.get("defeatResolved", false)):
			existing_positions.append(Vector2(enemy.get("pos", Vector2.ZERO)))
	var boss_pos := _boss_origin(target, arena)
	var player_pos := Vector2(target.get("player_pos"))
	var walls: Array = EnemySystemScript.spawn_walls_for_target(target)
	var attempts := maxi(1, int(payload.get("candidateAttemptsPerEnemy", 48)))
	for _i in range(requested):
		var found := false
		var chosen := Vector2.ZERO
		for _attempt in range(attempts):
			var angle := rng.randf_range(0.0, TAU) if rng != null else 0.0
			var distance := rng.randf_range(float(payload.get("bossDistanceMin", 180.0)), float(payload.get("bossDistanceMax", 300.0))) if rng != null else float(payload.get("bossDistanceMin", 180.0))
			var candidate := boss_pos + Vector2.from_angle(angle) * distance
			var margin := float(payload.get("arenaMargin", 70.0))
			var safe_arena := arena.grow(-margin)
			var enemy_radius := 22.0
			if safe_arena.size.x <= enemy_radius * 2.0 or safe_arena.size.y <= enemy_radius * 2.0:
				break
			if not safe_arena.grow(-enemy_radius).has_point(candidate):
				continue
			if candidate.distance_to(player_pos) < float(payload.get("playerDistanceMin", 180.0)):
				continue
			if candidate.distance_to(boss_pos) < float(payload.get("bossBodyPadding", 28.0)) + 110.0:
				continue
			if EnemySystemScript.spawn_position_blocked_by_walls(candidate, enemy_radius, walls):
				continue
			var spaced := true
			for existing in existing_positions:
				if candidate.distance_to(existing) < float(payload.get("enemySpacingMin", 50.0)):
					spaced = false
					break
			if not spaced:
				continue
			for existing in positions:
				if candidate.distance_to(Vector2(existing)) < float(payload.get("enemySpacingMin", 50.0)):
					spaced = false
					break
			if not spaced:
				continue
			chosen = candidate
			found = true
			break
		if not found:
			break
		positions.append(chosen)
	if positions.is_empty():
		return false
	var wave_serial := int(runtime.get("noise_summon_wave_serial", 0)) + 1
	runtime["noise_summon_wave_serial"] = wave_serial
	runtime["noise_summon_pending_wave"] = {
		"waveId": wave_serial,
		"source": source,
		"phaseIndex": phase,
		"positions": positions,
		"warningTimer": 0.0 if source == "travel_support" else float(payload.get("spawnWarningSeconds", 0.6)),
		"spawned": false
	}
	return true

static func _update_pending_noise_wave(target: Node, runtime: Dictionary, delta: float, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var pending: Dictionary = runtime.get("noise_summon_pending_wave", {}) as Dictionary
	if pending.is_empty() or bool(pending.get("spawned", false)):
		return
	pending["warningTimer"] = maxf(0.0, float(pending.get("warningTimer", 0.0)) - delta)
	runtime["noise_summon_pending_wave"] = pending
	if float(pending.get("warningTimer", 0.0)) > 0.0:
		return
	pending["spawned"] = true
	runtime["noise_summon_pending_wave"] = pending
	_spawn_noise_wave(target, runtime, pending, arena, rng)

static func _spawn_noise_wave(target: Node, runtime: Dictionary, pending: Dictionary, _arena: Rect2, rng: RandomNumberGenerator) -> bool:
	var payload := _noise_payload_for_target(target)
	var phase := clampi(int(pending.get("phaseIndex", target.get("relay_boss_phase"))), 0, 4)
	var phase_settings := _noise_phase_settings(payload, phase)
	var available := maxi(0, int(phase_settings.get("activeCap", payload.get("maxActive", 4))) - _active_noise_summon_count(target))
	var positions: Array = pending.get("positions", []) as Array
	var actual_count := mini(available, positions.size())
	if actual_count <= 0:
		runtime["noise_summon_pending_wave"] = {}
		return false
	var source := String(pending.get("source", "main_attack"))
	var sync_config: Dictionary = payload.get("syncStar", {}) as Dictionary
	var can_carrier := source != "travel_support" and bool(sync_config.get("enabled", true)) and _active_noise_carrier_count(target) < int(sync_config.get("maxCarrierCount", 1)) and int(_reserved_sync_star_count(target)) < _required_sync_star_count(target) and float(runtime.get("sync_star_drop_cooldown", 0.0)) <= 0.0
	var carrier_index := actual_count - 1 if can_carrier else -1
	var enemies: Array = target.get("enemies") as Array
	var spawned_count := 0
	for i in range(actual_count):
		var uid := int(target.get("next_enemy_uid"))
		var summon := EnemySystemScript.build_enemy(String(payload.get("enemyKind", "noise_ghost_comment")), Vector2(positions[i]), uid, 999.0)
		_configure_noise_summon(summon, payload, source, int(pending.get("waveId", 0)), float(payload.get("enemyLifetimeSeconds", payload.get("lifetime", 14.0))))
		if i == carrier_index:
			summon["syncStarCarrier"] = true
			summon["syncStarCarrierWaveId"] = int(pending.get("waveId", 0))
			summon["syncStarCarrierRevealTimer"] = 0.45
			runtime["sync_star_carrier_uid"] = uid
		enemies.append(summon)
		target.set("next_enemy_uid", uid + 1)
		spawned_count += 1
	target.set("enemies", enemies)
	if spawned_count > 0:
		var min_cooldown := float(payload.get("cooldownMinSeconds", 11.0))
		var max_cooldown := maxf(min_cooldown, float(payload.get("cooldownMaxSeconds", 14.0)))
		runtime["noise_summon_cooldown"] = rng.randf_range(min_cooldown, max_cooldown) if rng != null else min_cooldown
		runtime["noise_summon_after_wave_lock"] = float(payload.get("postSummonProtectedAttackSeconds", 2.0))
	runtime["noise_summon_pending_wave"] = {}
	return spawned_count > 0

static func _configure_noise_summon(summon: Dictionary, payload: Dictionary, source: String, wave_id: int, lifetime: float) -> void:
	summon["relayBossSummon"] = true
	summon["relayBossNoiseSummon"] = true
	summon["relayBossSummonWaveId"] = wave_id
	summon["relayBossSummonSource"] = source
	summon["relayBossSummonLifetime"] = lifetime
	summon["spawnGraceTimer"] = float(payload.get("spawnGraceSeconds", 0.4))
	summon["contactDamage"] = int(payload.get("contactDamage", 7))
	summon["noRewards"] = true
	summon["score"] = 0
	summon["exp"] = 0
	summon["expDrop"] = 0
	summon["giftHypeReward"] = 0
	summon["itemDrop"] = false
	summon["healDrop"] = false
	summon["lifeTimer"] = lifetime
	summon["lastHitOwner"] = ""
	summon["defeatOwner"] = ""
	summon["removeReason"] = ""
	summon["syncStarDropped"] = false

static func _active_noise_carrier_count(target: Node) -> int:
	var count := 0
	for item in target.get("enemies") as Array:
		var enemy: Dictionary = item as Dictionary
		if bool(enemy.get("relayBossNoiseSummon", false)) and bool(enemy.get("syncStarCarrier", false)) and not bool(enemy.get("defeatPending", false)) and not bool(enemy.get("defeatResolved", false)):
			count += 1
	return count

static func _required_sync_star_count(target: Node) -> int:
	return int(target.call("_collab_required_sync_stars")) if target.has_method("_collab_required_sync_stars") else 3

static func _reserved_sync_star_count(target: Node) -> int:
	return int(target.call("_relay_boss_reserved_sync_stars")) if target.has_method("_relay_boss_reserved_sync_stars") else int(target.get("collab_sync_stars"))

static func _handle_noise_summon(target: Node, active: Dictionary, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var runtime := ensure_for_target(target)
	var pending: Dictionary = runtime.get("noise_summon_pending_wave", {}) as Dictionary
	if pending.is_empty():
		_prepare_noise_summon_wave(target, runtime, active.get("payload", {}) as Dictionary, arena, rng, "main_attack", -1)
		pending = runtime.get("noise_summon_pending_wave", {}) as Dictionary
	if not pending.is_empty() and float(pending.get("warningTimer", 0.0)) <= 0.0:
		_update_pending_noise_wave(target, runtime, 0.0, arena, rng)

static func _add_circle(runtime: Dictionary, kind: String, pos: Vector2, duration: float, damage: int, radius: float, source: String) -> void:
	var hazard := _new_hazard(kind, pos, duration, damage)
	hazard["shape"] = "circle"; hazard["radius"] = radius; hazard["source"] = source
	_append_hazard(runtime, hazard)

static func _clamp_point_to_arena(pos: Vector2, arena: Rect2, margin: float) -> Vector2:
	return Vector2(
		clampf(pos.x, arena.position.x + margin, arena.end.x - margin),
		clampf(pos.y, arena.position.y + margin, arena.end.y - margin)
	)

static func _handle_kuso_maro_drop(target: Node, runtime: Dictionary, active: Dictionary, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var center := Vector2(target.get("player_pos"))
	for i in range(4):
		var pos := center + Vector2.from_angle(float(i) * TAU / 4.0 + rng.randf_range(-0.2, 0.2)) * 170.0
		_add_circle(runtime, "kuso_maro_drop", _clamp_point_to_arena(pos, arena, 50.0), float((active.get("payload", {}) as Dictionary).get("activeDuration", 0.65)), 11, 52, "relay_boss_kuso_maro_drop")

static func _handle_long_comment_line(runtime: Dictionary, active: Dictionary, arena: Rect2) -> void:
	for i in range(3):
		var y := arena.position.y + arena.size.y * (0.24 + float(i) * 0.26)
		var hazard := _new_hazard("long_comment_line", arena.get_center(), float((active.get("payload", {}) as Dictionary).get("activeDuration", 0.6)), 11)
		hazard["shape"] = "line"; hazard["from"] = Vector2(arena.position.x, y); hazard["to"] = Vector2(arena.end.x, y); hazard["width"] = 18.0; hazard["source"] = "relay_boss_long_comment_line"
		_append_hazard(runtime, hazard)

static func _handle_race_lane_charge(runtime: Dictionary, active: Dictionary, arena: Rect2) -> void:
	for i in range(2):
		var y := arena.position.y + arena.size.y * (0.34 + float(i) * 0.32)
		var hazard := _new_hazard("race_lane_charge", Vector2(arena.position.x, y - 43.0), float((active.get("payload", {}) as Dictionary).get("activeDuration", 1.8)), 16)
		hazard["shape"] = "rect"; hazard["size"] = Vector2(arena.size.x, 86.0); hazard["source"] = "relay_boss_race_lane_charge"
		_append_hazard(runtime, hazard)

static func _handle_game_over_barrage(target: Node, runtime: Dictionary, active: Dictionary, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var payload: Dictionary = active.get("payload", {}) as Dictionary
	var next_shot := float(active.get("nextShot", 0.0))
	var interval := maxf(0.08, float(payload.get("fireInterval", 0.35)))
	if float(active.get("elapsed", 0.0)) < next_shot:
		return
	var origin := Vector2(runtime.get("locked_origin", RelayBossMovementSystem.marker_world_position(target, "GameModule", arena)))
	var direction := (Vector2(target.get("player_pos")) - origin).normalized()
	for i in range(mini(12, int(payload.get("count", 6)))):
		_append_bullet(target, origin, direction.rotated((float(i) - 2.5) * 0.18 + rng.randf_range(-0.03, 0.03)) * 190.0, 3.5, int(payload.get("damage", 7)), "relay_boss_game_over_barrage", String(active.get("id", "")))
	active["nextShot"] = next_shot + interval

static func _handle_fake_gift_trap(target: Node, runtime: Dictionary, active: Dictionary, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var center := Vector2(target.get("player_pos"))
	for i in range(5):
		var pos := center + Vector2.from_angle(float(i) * TAU / 5.0 + rng.randf_range(-0.18, 0.18)) * 170.0
		_add_circle(runtime, "fake_gift_trap", _clamp_point_to_arena(pos, arena, 45.0), float((active.get("payload", {}) as Dictionary).get("activeDuration", 0.45)), 11, 40, "relay_boss_fake_gift_trap")

static func _handle_howling_ring(target: Node, runtime: Dictionary, active: Dictionary, arena: Rect2) -> void:
	var center := RelayBossMovementSystem.marker_world_position(target, "SongModule", arena)
	for i in range(3):
		var hazard := _new_hazard("howling_ring", center, float((active.get("payload", {}) as Dictionary).get("activeDuration", 2.25)), 11)
		hazard["shape"] = "ring"; hazard["radius"] = 120.0 + float(i) * 88.0; hazard["width"] = 18.0; hazard["delay"] = float(i) * 0.75; hazard["source"] = "relay_boss_howling_ring"
		_append_hazard(runtime, hazard)

static func _handle_pitch_wave(runtime: Dictionary, active: Dictionary, arena: Rect2) -> void:
	for i in range(2):
		var y := arena.position.y + arena.size.y * (0.35 + float(i) * 0.3)
		var hazard := _new_hazard("pitch_wave", Vector2(arena.position.x - 80.0, y), float((active.get("payload", {}) as Dictionary).get("activeDuration", 3.0)), 11)
		hazard["shape"] = "circle"; hazard["radius"] = 42.0; hazard["vel"] = Vector2(300, 0); hazard["source"] = "relay_boss_pitch_wave"
		_append_hazard(runtime, hazard)

static func _handle_rhythm_explosion(target: Node, runtime: Dictionary, active: Dictionary, arena: Rect2) -> void:
	var center := RelayBossMovementSystem.marker_world_position(target, "SongModule", arena)
	for i in range(6):
		var pos := _clamp_point_to_arena(center + Vector2.from_angle(float(i) * TAU / 6.0) * 190.0, arena, 50.0)
		var hazard := _new_hazard("rhythm_explosion", pos, float((active.get("payload", {}) as Dictionary).get("activeDuration", 2.65)), 16)
		hazard["shape"] = "circle"; hazard["radius"] = 58.0; hazard["delay"] = 1.4 + float(i) * 0.25; hazard["source"] = "relay_boss_rhythm_explosion"
		_append_hazard(runtime, hazard)

static func _handle_dirty_paint(runtime: Dictionary, active: Dictionary, arena: Rect2) -> void:
	for i in range(3):
		var pos := Vector2(arena.position.x + arena.size.x * (0.28 + float(i) * 0.24), arena.position.y + arena.size.y * (0.38 + float(i % 2) * 0.24))
		var hazard := _new_hazard("dirty_paint", pos, float((active.get("payload", {}) as Dictionary).get("activeDuration", 7.0)), 0)
		hazard["shape"] = "circle"; hazard["radius"] = 145.0; hazard["slowRate"] = 0.35; hazard["source"] = "relay_boss_dirty_paint"
		_append_hazard(runtime, hazard)

static func _handle_eraser_sweep(runtime: Dictionary, active: Dictionary, arena: Rect2) -> void:
	var duration := float((active.get("payload", {}) as Dictionary).get("activeDuration", 1.0))
	var hazard := _new_hazard("eraser_sweep", Vector2(arena.position.x - 80.0, arena.position.y), duration, int((active.get("payload", {}) as Dictionary).get("damage", 20)))
	hazard["shape"] = "rect"; hazard["size"] = Vector2(128, arena.size.y); hazard["vel"] = Vector2(arena.size.x / maxf(0.1, duration), 0); hazard["source"] = "relay_boss_eraser_sweep"
	_append_hazard(runtime, hazard)

static func _handle_paint_warning(target: Node, runtime: Dictionary, active: Dictionary, arena: Rect2) -> void:
	var payload: Dictionary = active.get("payload", {}) as Dictionary
	var hazard := _new_hazard("paint_warning", RelayBossMovementSystem.marker_world_position(target, "DrawModule", arena), float(payload.get("activeDuration", 2.5)), int(payload.get("damage", 7)))
	hazard["shape"] = "circle"; hazard["radius"] = minf(arena.size.x, arena.size.y) * 0.24; hazard["damageInterval"] = float(payload.get("damageInterval", 0.6)); hazard["source"] = "relay_boss_paint_warning"
	_append_hazard(runtime, hazard)

static func _handle_division_noise(target: Node, runtime: Dictionary, active: Dictionary, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var anchors := [Vector2(target.get("player_pos"))]
	var partner: Variant = target.get("collab_partner_pos")
	if partner is Vector2:
		anchors.append(partner)
	for anchor in anchors:
		_add_circle(runtime, "division_noise", anchor, float((active.get("payload", {}) as Dictionary).get("activeDuration", 4.0)), 7, 46, "relay_boss_division_noise")
	if target.has_method("_relay_boss_spawn_division_noise"):
		target.call("_relay_boss_spawn_division_noise", 2, arena, rng)

static func _handle_collab_break_start(target: Node, runtime: Dictionary, active: Dictionary, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var payload: Dictionary = active.get("payload", {}) as Dictionary
	var boss_hp := 1.0
	for item in target.get("enemies") as Array:
		var enemy: Dictionary = item as Dictionary
		if bool(enemy.get("relayBoss", false)):
			boss_hp = float(enemy.get("max_hp", enemy.get("hp", 1.0)))
			break
	var core := RelayBossMovementSystem.marker_world_position(target, "CollabModule", arena)
	_add_circle(runtime, "collab_break", core, float(payload.get("activeDuration", 10.0)), int(round(boss_hp * 0.03)), 190, "relay_boss_collab_break")
	if target.has_method("_relay_boss_spawn_collab_break_core"):
		runtime["collab_break_uid"] = int(target.call("_relay_boss_spawn_collab_break_core", core, arena, rng))
	target.set("collab_boss_partner_muted", true)
	var noise_payload := _noise_payload_for_target(target)
	var phase_settings := _noise_phase_settings(noise_payload, clampi(int(target.get("relay_boss_phase")), 0, 4))
	var sidecar_count := maxi(1, floori(float(phase_settings.get("spawnCount", noise_payload.get("count", 2))) * float(noise_payload.get("collabBreakSpawnMultiplier", 0.75))))
	if _can_prepare_noise_wave(target, runtime, noise_payload, RelayBossMovementSystem.state_for_target(target), true):
		_prepare_noise_summon_wave(target, runtime, noise_payload, arena, rng, "collab_break_sidecar", sidecar_count)

static func _handle_all_genre_rush_start(target: Node, runtime: Dictionary, active: Dictionary, arena: Rect2, rng: RandomNumberGenerator) -> void:
	active["substep"] = 0
	runtime["gameplay_variant"] = "all_genre_rush"

static func _handle_collab_break(target: Node, _runtime: Dictionary, active: Dictionary) -> void:
	if float(active.get("timer", 0.0)) <= 0.0:
		target.set("collab_boss_partner_muted", false)

static func _handle_all_genre_rush(target: Node, runtime: Dictionary, active: Dictionary, delta: float, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var step_timer := float(active.get("genreStepTimer", 0.0)) - delta
	active["genreStepTimer"] = step_timer
	if step_timer > 0.0:
		return
	var step := int(active.get("substep", 0)) % 4
	match step:
		0:
			_handle_kuso_maro_drop(target, runtime, active, arena, rng)
		1:
			_handle_long_comment_line(runtime, active, arena)
		2:
			_handle_howling_ring(target, runtime, active, arena)
		3:
			_handle_dirty_paint(runtime, active, arena)
	active["substep"] = int(active.get("substep", 0)) + 1
	active["genreStepTimer"] = 0.6
