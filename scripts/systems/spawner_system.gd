class_name SpawnerSystem
extends RefCounted

const RelayStageProfileSystemScript := preload("res://scripts/systems/relay_stage_profile_system.gd")

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
		"currentSpawnAmountMultiplier": context.get("currentSpawnAmountMultiplier", 1.0)
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
		"activeEnemyCap": active_enemy_cap
	}

static func update_for_target(target: Node, delta: float, arena: Rect2, rng: RandomNumberGenerator) -> Dictionary:
	var result: Dictionary = spawn_kinds(spawn_context_for_target(target, delta, rng))
	target.set("spawn_timer", float(result["spawnTimer"]))
	var kinds: Array = result["kinds"] as Array
	var requested_count := kinds.size()
	var active_normal_wave_count := EnemySystem.active_normal_wave_count(target.get("enemies") as Array)
	var cap := int(result.get("activeEnemyCap", 0))
	var available_slots := requested_count
	if cap > 0:
		available_slots = mini(requested_count, maxi(0, cap - active_normal_wave_count))
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
	var enemies: Array = target.get("enemies") as Array
	var bullets: Array = target.get("enemy_bullets") as Array
	var stats: Dictionary = target.get("balance_debug_stats") as Dictionary
	if stats.is_empty():
		stats = {"requested": 0, "actual": 0, "capped": 0, "defeats": 0, "expDropped": 0, "expCollected": 0, "levelUps": 0, "maxSimultaneousEnemies": 0, "maxSimultaneousBullets": 0, "tierCounts": {}, "kindCounts": {}}
	stats["requested"] = int(stats.get("requested", 0)) + requested_count
	stats["actual"] = int(stats.get("actual", 0)) + actual_count
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
		"actualSpawnCount": actual_count,
		"cappedSpawnCount": capped_count,
		"activeNormalWaveCount": active_normal_wave_count,
		"activeNormalWaveCap": cap,
		"balanceStats": stats.duplicate(true)
	}
	target.set("balance_debug_last", debug_snapshot)
	result["balanceDebug"] = debug_snapshot
	return result
