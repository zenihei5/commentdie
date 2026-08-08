class_name SpawnerSystem
extends RefCounted

const RelayStageProfileSystemScript := preload("res://scripts/systems/relay_stage_profile_system.gd")
const HardModeSystemScript := preload("res://scripts/systems/hard_mode_system.gd")

static func spawn_step(context: Dictionary) -> Dictionary:
	var timer: float = float(context["spawnTimer"]) - float(context["delta"])
	if timer > 0.0:
		return {"spawnTimer": timer, "spawnCount": 0}

	var interval: float = float(context["baseInterval"])
	if int(context.get("marshmallowCount", 0)) > 0:
		interval *= 0.96

	var more_spawns: bool = bool(context.get("moreSpawns", false))
	var god_reservation: bool = bool(context.get("godReservation", false))
	var god_power: float = float(context.get("godReservationPower", 0.0))
	if more_spawns or god_reservation:
		var spawn_power: float = maxf(float(context.get("moreSpawnsPower", 0.0)), god_power)
		interval *= lerpf(0.82, 0.65, spawn_power)
	if bool(context.get("flameMarketing", false)):
		interval *= 0.8
	if float(context.get("spawnRateTimer", 0.0)) > 0.0:
		interval *= 0.9
	interval /= maxf(0.25, float(context.get("songInstructionSpawnMultiplier", 1.0)))
	if bool(context.get("useRelayStageBalance", false)):
		interval *= maxf(0.25, float(context.get("timePhaseIntervalMultiplier", 1.0)))
		interval /= maxf(0.25, float(context.get("currentSpawnAmountMultiplier", 1.0)))
	else:
		interval /= maxf(0.25, float(context.get("spawnMultiplier", context.get("relaySpawnMultiplier", 1.0))))
	interval /= maxf(0.25, float(context.get("hardSpawnRate", 1.0)))

	var count: int = 2 if (more_spawns or (god_reservation and god_power >= 0.95)) else 1
	count += int(context.get("additionalSpawnCount", 0))
	return {"spawnTimer": interval, "spawnCount": count, "requestedCount": count}

static func spawn_kinds(context: Dictionary) -> Dictionary:
	var base_interval: float = EnemySystem.spawn_interval({
		"elapsed": context["elapsed"],
		"quickTestMode": context["quickTestMode"]
	})
	var step: Dictionary = spawn_step({
		"spawnTimer": context["spawnTimer"],
		"delta": context["delta"],
		"baseInterval": base_interval,
		"marshmallowCount": context["marshmallowCount"],
		"moreSpawns": context["moreSpawns"],
		"moreSpawnsPower": context["moreSpawnsPower"],
		"godReservation": context["godReservation"],
		"godReservationPower": context["godReservationPower"],
		"flameMarketing": context["flameMarketing"],
		"spawnRateTimer": context["spawnRateTimer"],
		"spawnMultiplier": context.get("spawnMultiplier", context.get("relaySpawnMultiplier", 1.0)),
		"relaySpawnMultiplier": context.get("relaySpawnMultiplier", 1.0),
		"useRelayStageBalance": context.get("useRelayStageBalance", false),
		"timePhaseIntervalMultiplier": context.get("timePhaseIntervalMultiplier", 1.0),
		"currentSpawnAmountMultiplier": context.get("currentSpawnAmountMultiplier", 1.0),
		"hardSpawnRate": context.get("hardSpawnRate", 1.0),
		"additionalSpawnCount": context.get("additionalSpawnCount", 0)
	})
	var rng: RandomNumberGenerator = context["rng"] as RandomNumberGenerator
	var kinds: Array = []
	for i in range(int(step["spawnCount"])):
		var kind := _pick_kind(context, rng)
		if float(context.get("songCommentEnemyBias", 0.0)) > 0.0 and rng.randf() < float(context.get("songCommentEnemyBias", 0.0)):
			var comment_roll := rng.randf()
			if comment_roll < 0.45:
				kind = "request_spammer"
			elif comment_roll < 0.75:
				kind = "song_noise_comment"
			else:
				kind = "song_lyric_spoiler_comment"
		kinds.append(kind)
	return {
		"spawnTimer": step["spawnTimer"],
		"kinds": kinds,
		"balanceProgress": context.get("balanceProgress", 0.0),
		"balanceSpawnMultiplier": context.get("balanceSpawnMultiplier", context.get("spawnMultiplier", 1.0)),
		"balanceUpperWeight": context.get("balanceUpperWeight", context.get("relayUpperWeight", 1.0)),
		"activeEnemyCap": context.get("activeEnemyCap", 0),
		"useRelayStageBalance": context.get("useRelayStageBalance", false),
		"tierCounts": (context.get("_tierCounts", {}) as Dictionary).duplicate(),
		"timePhaseIntervalMultiplier": context.get("timePhaseIntervalMultiplier", 1.0),
		"currentSpawnAmountMultiplier": context.get("currentSpawnAmountMultiplier", 1.0),
		"hardSpawnRate": context.get("hardSpawnRate", 1.0),
		"hardOverlayRate": context.get("hardOverlayRate", 1.0),
		"baseSpawnMultiplier": context.get("baseSpawnMultiplier", 1.0),
		"finalSpawnMultiplier": context.get("finalSpawnMultiplier", context.get("spawnMultiplier", 1.0))
	}

static func _pick_kind(context: Dictionary, rng: RandomNumberGenerator) -> String:
	if bool(context.get("useRelayStageBalance", false)) and (String(context.get("streamFrameId", "")) == "drawing" or String(context.get("streamFrameId", "")) == "collab"):
		var tier := RelayStageProfileSystemScript.tier_for_target(context["target"] as Node, rng)
		var tier_counts: Dictionary = context.get("_tierCounts", {}) as Dictionary
		tier_counts[tier] = int(tier_counts.get(tier, 0)) + 1
		context["_tierCounts"] = tier_counts
		var tier_kinds := RelayStageProfileSystemScript.tier_kinds_for_target(context["target"] as Node, tier)
		if not tier_kinds.is_empty():
			return String(tier_kinds[rng.randi_range(0, tier_kinds.size() - 1)])
	return EnemySystem.pick_wave_enemy(
		float(context["elapsed"]),
		bool(context["quickTestMode"]),
		rng,
		String(context.get("streamFrameId", "")),
		String(context.get("activeGenreEvent", "")),
		float(context.get("relayUpperWeight", 1.0))
	)

static func spawn_context_for_target(target: Node, delta: float, rng: RandomNumberGenerator) -> Dictionary:
	var marshmallows: Array = target.get("marshmallows") as Array
	var song_instruction_spawn_multiplier := 1.0
	if target.has_method("_song_instruction_enemy_spawn_multiplier"):
		song_instruction_spawn_multiplier = maxf(0.25, float(target.call("_song_instruction_enemy_spawn_multiplier")))
	var song_comment_enemy_bias := 0.0
	if target.has_method("_song_comment_enemy_spawn_bias"):
		song_comment_enemy_bias = clampf(float(target.call("_song_comment_enemy_spawn_bias")), 0.0, 0.85)
	var spawn_multiplier := 1.0
	var upper_weight := 1.0
	var balance_progress := 0.0
	var use_relay_stage_balance := false
	var time_phase_interval_multiplier := 1.0
	var current_spawn_amount_multiplier := 1.0
	var additional_spawn_count := 0
	var active_enemy_cap := 0
	if not bool(target.get("relay_boss_active")):
		var balance_root: Dictionary = (target.get("relay_mode_config") as Dictionary).get("relayStageBalance", {}) as Dictionary
		active_enemy_cap = int(balance_root.get("baseActiveEnemyCap", 20))
		var profile := RelayStageProfileSystemScript.profile_for_target(target)
		spawn_multiplier = maxf(0.25, float(profile.get("spawn", 1.0)))
		upper_weight = float(profile.get("upperWeight", 1.0))
		balance_progress = float(profile.get("progress", 0.0))
		if String(target.get("active_genre_event")) == "bullet_hell":
			var config: Dictionary = target.get("relay_mode_config") as Dictionary
			var caps: Dictionary = config.get("dangerEnemyCaps", {}) as Dictionary
			spawn_multiplier = minf(spawn_multiplier, float(caps.get("bulletHellNormalEnemySpawnMultiplierCap", 1.20)))
		if bool(target.get("relay_mode")) and (String(target.get("current_stream_frame_id")) == "drawing" or String(target.get("current_stream_frame_id")) == "collab"):
			use_relay_stage_balance = true
			time_phase_interval_multiplier = RelayStageProfileSystemScript.interval_multiplier_for_target(target)
			current_spawn_amount_multiplier = RelayStageProfileSystemScript.spawn_amount_multiplier_for_target(target)
			additional_spawn_count = RelayStageProfileSystemScript.additional_spawn_count_for_target(target, rng)
			active_enemy_cap = RelayStageProfileSystemScript.active_enemy_cap_for_target(target)
			# The late-stage balance owns the effective spawn amount. Keep the
			# legacy relaySpawnCurves value out of both the interval and debug view.
			spawn_multiplier = current_spawn_amount_multiplier
	var hard_runtime := HardModeSystemScript.runtime_for_target(target)
	var collab_event_active := bool(target.get("relay_mode")) and String(target.get("current_stream_frame_id")) == "collab" and String(target.get("collab_challenge_status")) in ["starting", "active"]
	var hard_breakdown := HardModeSystemScript.spawn_rate_breakdown(hard_runtime, float(target.get("elapsed")), bool(target.get("boss_active")), collab_event_active)
	var hard_rate := float(hard_breakdown.get("final", 1.0))
	var hard_enabled := HardModeSystemScript.spawn_enabled(hard_runtime, float(target.get("elapsed")))
	if not hard_runtime.is_empty():
		hard_runtime["stageEventActive"] = collab_event_active
		hard_runtime["spawnBreakdown"] = hard_breakdown
	var base_spawn_multiplier := spawn_multiplier
	if use_relay_stage_balance:
		spawn_multiplier = current_spawn_amount_multiplier
	active_enemy_cap = HardModeSystemScript.active_enemy_cap(active_enemy_cap, hard_runtime)
	return {
		"target": target,
		"spawnTimer": target.get("spawn_timer"),
		"delta": delta,
		"elapsed": target.get("elapsed"),
		"quickTestMode": target.get("quick_test_mode"),
		"rng": rng,
		"marshmallowCount": marshmallows.size(),
		"moreSpawns": ModifierSystem.has_effect_for_target(target, "more_spawns"),
		"moreSpawnsPower": ModifierSystem.effect_rate_for_target(target, "more_spawns"),
		"godReservation": ModifierSystem.has_effect_for_target(target, "god_reservation"),
		"godReservationPower": ModifierSystem.effect_rate_for_target(target, "god_reservation"),
		"flameMarketing": target.get("flame_marketing"),
		"spawnRateTimer": target.get("spawn_rate_timer"),
		"streamFrameId": target.get("current_stream_frame_id"),
		"activeGenreEvent": target.get("active_genre_event"),
		"songInstructionSpawnMultiplier": song_instruction_spawn_multiplier,
		"songCommentEnemyBias": song_comment_enemy_bias,
		"spawnMultiplier": spawn_multiplier,
		"relaySpawnMultiplier": spawn_multiplier,
		"relayUpperWeight": upper_weight,
		"balanceProgress": balance_progress,
		"balanceSpawnMultiplier": spawn_multiplier,
		"balanceUpperWeight": upper_weight,
		"useRelayStageBalance": use_relay_stage_balance,
		"timePhaseIntervalMultiplier": time_phase_interval_multiplier,
		"currentSpawnAmountMultiplier": current_spawn_amount_multiplier,
		"additionalSpawnCount": additional_spawn_count,
		"activeEnemyCap": active_enemy_cap,
		"hardOverlayRate": hard_rate,
		"hardSpawnBreakdown": hard_breakdown,
		"hardSpawnRate": hard_rate if hard_enabled else 1.0,
		"hardSpawnEnabled": hard_enabled,
		"baseSpawnMultiplier": base_spawn_multiplier,
		"finalSpawnMultiplier": spawn_multiplier * (hard_rate if hard_enabled else 1.0),
		"hardBaseRate": float(hard_breakdown.get("base", 1.0)),
		"hardStageRate": float(hard_breakdown.get("stage", 1.0)),
		"hardTimeRate": float(hard_breakdown.get("time", 1.0)),
		"hardBossRate": float(hard_breakdown.get("boss", 1.0)),
		"hardEventRate": float(hard_breakdown.get("event", 1.0)),
		"hardSafetyRate": float(hard_breakdown.get("safety", 1.0))
	}

static func update_for_target(target: Node, delta: float, arena: Rect2, rng: RandomNumberGenerator) -> Dictionary:
	var context := spawn_context_for_target(target, delta, rng)
	if not bool(context.get("hardSpawnEnabled", true)):
		var stopped_runtime := HardModeSystemScript.runtime_for_target(target)
		if not stopped_runtime.is_empty():
			stopped_runtime["currentSpawnRate"] = 0.0
			stopped_runtime["spawnBreakdown"] = (context.get("hardSpawnBreakdown", {}) as Dictionary).duplicate(true)
		target.set("spawn_timer", INF)
		return {"spawnTimer": INF, "kinds": [], "requestedCount": 0, "actualCount": 0, "cappedCount": 0, "balanceDebug": {"hardSpawnEnabled": false}}
	var result: Dictionary = spawn_kinds(context)
	target.set("spawn_timer", float(result["spawnTimer"]))
	var kinds: Array = result["kinds"] as Array
	var requested_count := kinds.size()
	var enemies_before: Array = target.get("enemies") as Array
	var active_normal_wave_count := EnemySystem.active_normal_wave_count(enemies_before)
	var active_occupancy := EnemySystem.active_enemy_occupancy(enemies_before)
	var cap := int(result.get("activeEnemyCap", 0))
	var hard_wave_actual := 0
	var hard_runtime := HardModeSystemScript.runtime_for_target(target)
	var pending_actual := _spawn_pending_requests(target, arena, rng, hard_runtime, cap)
	if HardModeSystemScript.is_hard_runtime(hard_runtime):
		pending_actual += _process_pending_pressure_wave(target, arena, rng, hard_runtime, cap)
	if pending_actual > 0:
		active_occupancy = EnemySystem.active_enemy_occupancy(target.get("enemies") as Array)
	if HardModeSystemScript.is_hard_runtime(hard_runtime) and requested_count > 0:
		var player_level := int(target.get("exp_level"))
		var active_dangers: Dictionary = hard_runtime.get("dangerCategories", {}) as Dictionary
		var wave := HardModeSystemScript.choose_hard_wave(hard_runtime, float(target.get("elapsed")), player_level, active_occupancy, active_dangers, bool(target.get("boss_active")), rng, cap)
		if not wave.is_empty():
			var reserve := int(wave.get("activeEnemyLimitReserve", 0))
			if active_occupancy + reserve <= cap:
				var wave_actual := 0
				for raw_group in wave.get("groups", []) as Array:
					if not raw_group is Dictionary:
						continue
					var group: Dictionary = raw_group as Dictionary
					var enemy_id := String(group.get("enemyId", ""))
					var group_count := maxi(0, int(group.get("count", 0)))
					var pattern := String(group.get("spawnPattern", "outer_arc"))
					for group_index in range(group_count):
						if active_occupancy + wave_actual >= cap:
							break
						var wave_pos := _position_for_pattern(pattern, target, arena, rng, group_index, group_count)
						var uid := EnemySystem.spawn_enemy_for_target(target, enemy_id, arena, rng, wave_pos, "", "", "", "hard_wave")
						if uid >= 0:
							wave_actual += 1
				if wave_actual > 0:
					HardModeSystemScript.mark_hard_wave_started(hard_runtime, wave, float(target.get("elapsed")))
					hard_wave_actual = wave_actual
					var wave_categories: Array = wave.get("dangerCategories", []) as Array
					for category in wave_categories:
						var wave_owner := "hard_wave:" + String(wave.get("id", ""))
						HardModeSystemScript.begin_danger_for_target(target, String(category), wave_owner, HardModeSystemScript.spawn_priority_for_source("hard_wave"))
						HardModeSystemScript.end_danger_for_target(target, String(category), wave_owner)
	var enemies_after_wave: Array = target.get("enemies") as Array
	active_occupancy = EnemySystem.active_enemy_occupancy(enemies_after_wave)
	var available_slots := requested_count
	var occupancy_for_cap := active_occupancy if HardModeSystemScript.is_hard_runtime(hard_runtime) else active_normal_wave_count
	if cap > 0:
		available_slots = mini(requested_count, maxi(0, cap - occupancy_for_cap))
	var actual_count := 0
	var capped_count := maxi(0, requested_count - available_slots)
	for item in kinds:
		if actual_count >= available_slots:
			break
		var kind := String(item)
		if target.has_method("_queue_troll_linked_enemy") and bool(target.call("_queue_troll_linked_enemy", kind, arena, rng)):
			continue
		var uid := EnemySystem.spawn_enemy_for_target(target, kind, arena, rng, Vector2.INF, "", "", "", "normal_wave")
		if uid >= 0:
			actual_count += 1
	if not hard_runtime.is_empty():
		hard_runtime["currentSpawnRate"] = float(context.get("hardSpawnRate", 1.0))
		hard_runtime["totalEnemiesSpawned"] = int(hard_runtime.get("totalEnemiesSpawned", 0)) + actual_count + hard_wave_actual
	var enemies: Array = target.get("enemies") as Array
	var bullets: Array = target.get("enemy_bullets") as Array
	var stats: Dictionary = target.get("balance_debug_stats") as Dictionary
	if stats.is_empty():
		stats = {"requested": 0, "actual": 0, "capped": 0, "defeats": 0, "expDropped": 0, "expGenerated": 0, "expCollected": 0, "expUncollected": 0, "expExpired": 0, "expDiscarded": 0, "levelUps": 0, "maxSimultaneousEnemies": 0, "maxSimultaneousBullets": 0, "tierCounts": {}, "kindCounts": {}}
	stats["requested"] = int(stats.get("requested", 0)) + requested_count
	stats["actual"] = int(stats.get("actual", 0)) + actual_count + hard_wave_actual + pending_actual
	stats["capped"] = int(stats.get("capped", 0)) + capped_count
	var kind_counts: Dictionary = stats.get("kindCounts", {}) as Dictionary
	for kind_item in kinds:
		var kind_key := String(kind_item)
		kind_counts[kind_key] = int(kind_counts.get(kind_key, 0)) + 1
	stats["kindCounts"] = kind_counts
	var tier_counts: Dictionary = stats.get("tierCounts", {}) as Dictionary
	var result_tier_counts: Dictionary = result.get("tierCounts", {}) as Dictionary
	for tier_key in result_tier_counts.keys():
		tier_counts[tier_key] = int(tier_counts.get(tier_key, 0)) + int(result_tier_counts.get(tier_key, 0))
	stats["tierCounts"] = tier_counts
	stats["maxSimultaneousEnemies"] = maxi(int(stats.get("maxSimultaneousEnemies", 0)), enemies.size())
	stats["maxSimultaneousBullets"] = maxi(int(stats.get("maxSimultaneousBullets", 0)), bullets.size())
	target.set("balance_debug_stats", stats)
	var debug_snapshot := {
		"stageId": String(target.get("current_stream_frame_id")),
		"mode": "relay" if bool(target.get("relay_mode")) else "normal",
		"elapsedGameplayTime": float(target.get("elapsed")),
		"progress": float(result.get("balanceProgress", 0.0)),
		"spawnMultiplier": float(result.get("balanceSpawnMultiplier", 1.0)),
		"upperEnemyWeight": float(result.get("balanceUpperWeight", 1.0)),
		"timePhaseIntervalMultiplier": float(result.get("timePhaseIntervalMultiplier", 1.0)),
		"currentSpawnAmountMultiplier": float(result.get("currentSpawnAmountMultiplier", 1.0)),
		"activeEnemyCount": enemies.size(),
		"activeRangedEnemyCount": EnemySystem.dangerous_enemy_count(enemies, "ranged"),
		"activeSpreadShooterCount": EnemySystem.dangerous_enemy_count(enemies, "spread"),
		"activeChargeEnemyCount": EnemySystem.dangerous_enemy_count(enemies, "charge"),
		"activeAmbushEnemyCount": EnemySystem.dangerous_enemy_count(enemies, "ambush"),
		"activeEnemyBulletCount": bullets.size(),
		"spawnedKinds": (result.get("kinds", []) as Array).duplicate(),
		"requestedSpawnCount": requested_count,
		"actualSpawnCount": actual_count + hard_wave_actual + pending_actual,
		"cappedSpawnCount": capped_count,
		"activeNormalWaveCount": active_normal_wave_count,
		"activeEnemyOccupancy": active_occupancy,
		"activeNormalWaveCap": cap,
		"currentWave": String(hard_runtime.get("currentWave", "")),
		"pendingSpawnRequestCount": (hard_runtime.get("pendingSpawnRequests", []) as Array).size(),
		"totalEnemiesSpawned": int(hard_runtime.get("totalEnemiesSpawned", 0)),
		"totalEnemiesDefeated": int(hard_runtime.get("totalEnemiesDefeated", 0)),
		"balanceStats": stats.duplicate(true),
		"hardOverlayRate": float(result.get("hardOverlayRate", 1.0)),
		"hardSpawnBreakdown": (result.get("hardSpawnBreakdown", {}) as Dictionary).duplicate(true),
		"baseSpawnMultiplier": float(result.get("baseSpawnMultiplier", 1.0)),
		"finalSpawnMultiplier": float(result.get("finalSpawnMultiplier", result.get("balanceSpawnMultiplier", 1.0))),
		"expStats": (hard_runtime.get("expStats", {}) as Dictionary).duplicate(true)
	}
	target.set("balance_debug_last", debug_snapshot)
	result["balanceDebug"] = debug_snapshot
	return result

static func _position_for_pattern(pattern: String, target: Node, arena: Rect2, rng: RandomNumberGenerator, index: int, total: int) -> Vector2:
	var player_pos := arena.get_center()
	var raw_player_pos: Variant = target.get("player_pos")
	if raw_player_pos is Vector2:
		player_pos = raw_player_pos as Vector2
	if player_pos == Vector2.ZERO:
		player_pos = arena.get_center()
	var center := arena.get_center()
	var radius := minf(arena.size.x, arena.size.y) * 0.38
	var angle := (TAU * float(index) / maxf(1.0, float(total))) + rng.randf_range(-0.12, 0.12)
	if pattern == "four_directions":
		angle = TAU * float(index % 4) / 4.0
	elif pattern == "side_pair":
		angle = PI * 0.5 if index % 2 == 0 else PI * 1.5
	elif pattern == "player_front":
		var direction := (player_pos - center).normalized()
		if direction.length() < 0.1:
			direction = Vector2.UP
		return EnemySystem.clamp_enemy_pos_to_arena(player_pos + direction * maxf(260.0, radius * 0.9), arena)
	elif pattern == "player_back":
		var back_direction := (center - player_pos).normalized()
		if back_direction.length() < 0.1:
			back_direction = Vector2.DOWN
		return EnemySystem.clamp_enemy_pos_to_arena(player_pos + back_direction * maxf(280.0, radius * 0.95), arena)
	elif pattern == "left_right":
		var side_x := arena.position.x + arena.size.x * (0.20 if index % 2 == 0 else 0.80)
		return EnemySystem.clamp_enemy_pos_to_arena(Vector2(side_x, player_pos.y + rng.randf_range(-120.0, 120.0)), arena)
	elif pattern == "note_route_cross":
		return EnemySystem.clamp_enemy_pos_to_arena(Vector2(arena.position.x + arena.size.x * (0.25 + 0.50 * float(index) / maxf(1.0, float(total - 1))), player_pos.y + rng.randf_range(-150.0, 150.0)), arena)
	elif pattern == "paint_outer":
		return EnemySystem.clamp_enemy_pos_to_arena(center + Vector2.from_angle(PI * 0.35 + PI * 0.30 * float(index) / maxf(1.0, float(total - 1))) * radius, arena)
	elif pattern == "partner_sandwich":
		var partner_value: Variant = target.get("collab_partner_pos")
		var partner_pos := player_pos
		if partner_value is Vector2:
			partner_pos = partner_value as Vector2
		var sandwich_center := player_pos.lerp(partner_pos, 0.5)
		return EnemySystem.clamp_enemy_pos_to_arena(sandwich_center + Vector2((-1.0 if index % 2 == 0 else 1.0) * 260.0, rng.randf_range(-80.0, 80.0)), arena)
	elif pattern == "outer_ring":
		radius = minf(arena.size.x, arena.size.y) * 0.44
	elif pattern == "outer_arc":
		angle = PI * 0.18 + PI * 0.64 * float(index) / maxf(1.0, float(total - 1))
		# Keep one side of the arena clear as an escape route.
	return EnemySystem.clamp_enemy_pos_to_arena(center + Vector2(cos(angle), sin(angle)) * radius, arena)

static func _spawn_pending_requests(target: Node, arena: Rect2, rng: RandomNumberGenerator, runtime: Dictionary, cap: int) -> int:
	if runtime.is_empty():
		return 0
	var enemies: Array = target.get("enemies") as Array
	var occupancy := EnemySystem.active_enemy_occupancy(enemies)
	var resolved := HardModeSystemScript.resolve_spawn_requests(runtime, occupancy, cap, float(target.get("elapsed")))
	var pending: Array = runtime.get("pendingSpawnRequests", []) as Array
	var consumed: Dictionary = {}
	var actual := 0
	for view in resolved:
		var request: Dictionary = view as Dictionary
		var serial := int(request.get("serial", -1))
		var count := int(request.get("resolvedCount", 0))
		if count <= 0:
			continue
		var enemy_id := String(request.get("enemyId", ""))
		var spawned_for_request := 0
		for _i in range(count):
			var uid := EnemySystem.spawn_enemy_for_target(target, enemy_id, arena, rng, Vector2.INF, "", "", String(request.get("runtimeVariant", "")), String(request.get("source", "system")))
			if uid >= 0:
				actual += 1
				spawned_for_request += 1
		if serial >= 0:
			var requested := int(request.get("count", 0))
			if spawned_for_request >= requested:
				consumed[serial] = true
			else:
				for queued in pending:
					if queued is Dictionary and int((queued as Dictionary).get("serial", -1)) == serial:
						(queued as Dictionary)["count"] = requested - spawned_for_request
						break
	var kept: Array = []
	for queued in pending:
		if queued is Dictionary and not consumed.has(int((queued as Dictionary).get("serial", -1))):
			kept.append(queued)
	runtime["pendingSpawnRequests"] = kept
	return actual

static func _process_pending_pressure_wave(target: Node, arena: Rect2, rng: RandomNumberGenerator, runtime: Dictionary, cap: int) -> int:
	var pending: Dictionary = runtime.get("pendingPressureWave", {}) as Dictionary
	if pending.is_empty() or String(pending.get("state", "")) != "queued":
		return 0
	var now := float(target.get("elapsed"))
	var requested_at := float(pending.get("requestedAt", now))
	var max_delay := maxf(0.0, float(pending.get("maxDelay", 3.0)))
	var groups: Array = pending.get("groups", []) as Array
	var rate := clampf(float(pending.get("countRate", 1.0)), 0.1, 2.0)
	var planned := 0
	for raw_group in groups:
		if raw_group is Dictionary:
			planned += maxi(1, roundi(float((raw_group as Dictionary).get("count", 0)) * rate))
	pending["plannedCount"] = planned
	var enemies: Array = target.get("enemies") as Array
	var occupancy := EnemySystem.active_enemy_occupancy(enemies)
	var available := maxi(0, cap - occupancy)
	if now - requested_at < max_delay and available < planned:
		runtime["pendingPressureWave"] = pending
		return 0
	if available <= 0:
		# The reservation has reached its bounded wait. Do not remove an existing
		# enemy to force room and do not keep an unbounded request that can burst
		# after the cap frees up later.
		pending["state"] = "canceled"
		pending["actualCount"] = 0
		runtime["lastPressureWave"] = pending.duplicate(true)
		for category in ["stage_major_event", "high_density"]:
			HardModeSystemScript.end_danger_for_target(target, category, "hard_comment")
		runtime["pendingPressureWave"] = {}
		return 0
	var valid_groups: Array = []
	var group_counts: Array[int] = []
	for raw_group in groups:
		if raw_group is Dictionary:
			valid_groups.append(raw_group as Dictionary)
			group_counts.append(maxi(1, roundi(float((raw_group as Dictionary).get("count", 0)) * rate)))
	# Reserve one slot for every group whenever capacity allows it. This keeps
	# the mixed-wave identity visible instead of letting the first group consume
	# all available slots during a partial execution.
	var spawn_counts: Array[int] = []
	var remaining_slots := available
	for index in range(valid_groups.size()):
		var reserve := 1 if remaining_slots > valid_groups.size() - index - 1 else 0
		var amount := mini(group_counts[index], reserve)
		spawn_counts.append(amount)
		remaining_slots -= amount
	for index in range(valid_groups.size()):
		if remaining_slots <= 0:
			break
		var extra := mini(group_counts[index] - spawn_counts[index], remaining_slots)
		spawn_counts[index] += extra
		remaining_slots -= extra
	var actual := 0
	for group_index in range(valid_groups.size()):
		var group: Dictionary = valid_groups[group_index] as Dictionary
		var count := spawn_counts[group_index]
		for spawn_index in range(count):
			var enemy_id := String(group.get("enemyId", ""))
			var pattern := String(group.get("spawnPattern", "outer_arc"))
			var pos := _position_for_pattern(pattern, target, arena, rng, spawn_index, count)
			var uid := EnemySystem.spawn_enemy_for_target(target, enemy_id, arena, rng, pos, "", "", "", "comment_required")
			if uid >= 0:
				actual += 1
	pending["state"] = "done"
	pending["actualCount"] = actual
	runtime["lastPressureWave"] = pending.duplicate(true)
	for category in ["stage_major_event", "high_density"]:
		HardModeSystemScript.end_danger_for_target(target, category, "hard_comment")
	runtime["pendingPressureWave"] = {}
	return actual

static func prepare_capacity_for_boss(target: Node, needed: int = 1) -> int:
	var runtime := HardModeSystemScript.runtime_for_target(target)
	if not HardModeSystemScript.is_hard_runtime(runtime) or String(runtime.get("playMode", "")) != HardModeSystemScript.SINGLE:
		return 0
	var cap := HardModeSystemScript.active_enemy_cap(int((target.get("relay_mode_config") as Dictionary).get("relayStageBalance", {}).get("baseActiveEnemyCap", 20)), runtime)
	var enemies: Array = target.get("enemies") as Array
	var occupancy := EnemySystem.active_enemy_occupancy(enemies)
	var remove_count := maxi(0, occupancy + needed - cap)
	if remove_count <= 0:
		return 0
	var player_pos := Vector2.ZERO
	var raw_player_pos: Variant = target.get("player_pos")
	if raw_player_pos is Vector2:
		player_pos = raw_player_pos as Vector2
	var arena := Rect2(Vector2.ZERO, Vector2(1600.0, 900.0))
	if target.has_method("_current_arena"):
		arena = target.call("_current_arena") as Rect2
	var candidates: Array = []
	for item in enemies:
		if not item is Dictionary:
			continue
		var enemy: Dictionary = item as Dictionary
		var priority := int(enemy.get("spawnPriority", HardModeSystemScript.spawn_priority_for_source(String(enemy.get("spawnSource", "")))))
		var source := String(enemy.get("spawnSource", ""))
		if priority > HardModeSystemScript.spawn_priority_for_source("normal_wave") or not ["normal_wave", "extra_swarm"].has(source):
			continue
		if not bool(enemy.get("occupancyManaged", true)) or bool(enemy.get("isBoss", false)) or bool(enemy.get("defeatPending", false)):
			continue
		candidates.append(enemy)
	candidates.sort_custom(func(a: Variant, b: Variant) -> bool:
		var a_pos := Vector2((a as Dictionary).get("pos", Vector2.ZERO))
		var b_pos := Vector2((b as Dictionary).get("pos", Vector2.ZERO))
		var a_edge := minf(minf(a_pos.x - arena.position.x, arena.end.x - a_pos.x), minf(a_pos.y - arena.position.y, arena.end.y - a_pos.y))
		var b_edge := minf(minf(b_pos.x - arena.position.x, arena.end.x - b_pos.x), minf(b_pos.y - arena.position.y, arena.end.y - b_pos.y))
		var a_score := a_pos.distance_squared_to(player_pos) - a_edge * 900.0
		var b_score := b_pos.distance_squared_to(player_pos) - b_edge * 900.0
		return a_score > b_score
	)
	var removed_uids: Dictionary = {}
	var removed := 0
	for enemy in candidates:
		if removed >= remove_count:
			break
		var uid := int((enemy as Dictionary).get("uid", -1))
		removed_uids[uid] = true
		enemies.erase(enemy)
		removed += 1
	var bullets: Array = target.get("enemy_bullets") as Array
	var kept_bullets: Array = []
	for bullet in bullets:
		if not removed_uids.has(int((bullet as Dictionary).get("sourceUid", -2))):
			kept_bullets.append(bullet)
	target.set("enemies", enemies)
	target.set("enemy_bullets", kept_bullets)
	return removed
