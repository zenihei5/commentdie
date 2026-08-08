class_name RelayStageProfileSystem
extends RefCounted

static func phase_for_elapsed(config: Dictionary, elapsed: float) -> String:
	var times: Dictionary = config.get("phaseTimes", {}) as Dictionary
	if elapsed < float(times.get("introEnd", 30.0)):
		return "intro"
	if elapsed < float(times.get("mainEnd", 90.0)):
		return "main"
	return "climax"

static func segment_config(config: Dictionary, segment_id: String) -> Dictionary:
	return (config.get("segments", {}) as Dictionary).get(segment_id, {}) as Dictionary

static func enemy_multipliers(config: Dictionary, segment_id: String, elapsed: float) -> Dictionary:
	# Relay spawn and upper-enemy values are final phase curves. Do not multiply
	# the legacy enemyMultipliers.spawn/upperWeight or segment timeline again.
	var profile: Dictionary = ((config.get("enemyMultipliers", {}) as Dictionary).get(segment_id, {}) as Dictionary).duplicate(true)
	profile["spawn"] = _relay_curve_value(config, "relaySpawnCurves", segment_id, elapsed)
	profile["upperWeight"] = _relay_curve_value(config, "relayUpperEnemyWeights", segment_id, elapsed)
	profile["phase"] = phase_for_elapsed(config, elapsed)
	if segment_id == "drawing" or segment_id == "collab":
		var balance := relay_stage_balance_profile(config, segment_id, elapsed)
		for key in balance.keys():
			profile[key] = balance[key]
		# SpawnerSystem consumes these dedicated fields for late stages; the
		# legacy relaySpawnCurves/relayUpperEnemyWeights are not combined with it.
		profile["spawn"] = float(balance.get("spawnAmountMultiplier", 1.0))
		profile["upperWeight"] = 1.0
	return profile

static func relay_stage_balance_profile(config: Dictionary, segment_id: String, elapsed: float) -> Dictionary:
	var result: Dictionary = {
		"spawnAmountMultiplier": 1.0,
		"timePhaseIntervalMultiplier": 1.0,
		"additionalSpawnCountMin": 0,
		"additionalSpawnCountMax": 0,
		"activeEnemyCap": int((config.get("relayStageBalance", {}) as Dictionary).get("baseActiveEnemyCap", 20)),
		"tierWeights": {},
		"balanceStage": ""
	}
	var balance_root: Dictionary = config.get("relayStageBalance", {}) as Dictionary
	var stage: Dictionary = balance_root.get(segment_id, {}) as Dictionary
	if stage.is_empty():
		return result
	result["balanceStage"] = segment_id
	var phases: Array = stage.get("timePhases", []) as Array
	var phase: Dictionary = {}
	for item in phases:
		var candidate: Dictionary = item as Dictionary
		if elapsed >= float(candidate.get("start", 0.0)) and elapsed < float(candidate.get("end", 120.0)):
			phase = candidate
			break
	if phase.is_empty() and not phases.is_empty():
		phase = phases.back() as Dictionary
	result["timePhaseIntervalMultiplier"] = float(phase.get("spawnIntervalMultiplier", 1.0))
	result["additionalSpawnCountMin"] = int(phase.get("additionalSpawnCountMin", 0))
	result["additionalSpawnCountMax"] = int(phase.get("additionalSpawnCountMax", result["additionalSpawnCountMin"]))
	var base_cap := int(balance_root.get("baseActiveEnemyCap", 20))
	var cap_multiplier := float(stage.get("activeEnemyCapMultiplier", 1.0))
	var minimum_increase := int(stage.get("minimumCapIncrease", 0))
	result["activeEnemyCap"] = maxi(roundi(float(base_cap) * cap_multiplier), base_cap + minimum_increase)
	var amount := float(stage.get("spawnAmountMultiplier", 1.0))
	if segment_id == "drawing" and _drawing_pressure_reduced_for_target(stage):
		amount = float(stage.get("heavyGimmickSpawnAmountMultiplier", 1.10))
	if segment_id == "collab":
		var challenge_status := String(config.get("_runtime_collab_challenge_status", ""))
		if challenge_status == "starting" or challenge_status == "active":
			amount = float(stage.get("challengeSpawnAmountMultiplier", 1.15))
	result["spawnAmountMultiplier"] = maxf(0.25, amount)
	result["tierWeights"] = (stage.get("enemyTiers", {}) as Dictionary).duplicate(true)
	return result

static func relay_stage_profile_for_target(target: Node) -> Dictionary:
	var config: Dictionary = target.get("relay_mode_config") as Dictionary
	var segment_id := String(target.get("current_stream_frame_id"))
	return relay_stage_balance_profile(config, segment_id, float(target.get("elapsed")))

static func spawn_amount_multiplier_for_target(target: Node) -> float:
	if not bool(target.get("relay_mode")):
		return 1.0
	var config: Dictionary = target.get("relay_mode_config") as Dictionary
	var segment_id := String(target.get("current_stream_frame_id"))
	if segment_id != "drawing" and segment_id != "collab":
		return 1.0
	var balance_root: Dictionary = config.get("relayStageBalance", {}) as Dictionary
	var stage: Dictionary = balance_root.get(segment_id, {}) as Dictionary
	var amount := float(stage.get("spawnAmountMultiplier", 1.0))
	var challenge_status := String(target.get("collab_challenge_status"))
	if segment_id == "collab" and (challenge_status == "starting" or challenge_status == "active"):
		amount = float(stage.get("challengeSpawnAmountMultiplier", 1.15))
	var drawing_showcase_active: bool = target.has_method("_drawing_showcase_time_active") and target.call("_drawing_showcase_time_active") == true
	var drawing_finish_sequence_active: bool = target.get("drawing_finish_sequence_active") == true
	if segment_id == "drawing" and (drawing_showcase_active or drawing_finish_sequence_active):
		amount = float(stage.get("heavyGimmickSpawnAmountMultiplier", 1.10))
	return maxf(0.25, amount)

static func interval_multiplier_for_target(target: Node) -> float:
	if not bool(target.get("relay_mode")):
		return 1.0
	var config: Dictionary = target.get("relay_mode_config") as Dictionary
	var segment_id := String(target.get("current_stream_frame_id"))
	if segment_id != "drawing" and segment_id != "collab":
		return 1.0
	return float(relay_stage_balance_profile(config, segment_id, float(target.get("elapsed"))).get("timePhaseIntervalMultiplier", 1.0))

static func active_enemy_cap_for_target(target: Node) -> int:
	var balance_root: Dictionary = (target.get("relay_mode_config") as Dictionary).get("relayStageBalance", {}) as Dictionary
	if not bool(target.get("relay_mode")):
		return int(balance_root.get("baseActiveEnemyCap", 20))
	var profile := relay_stage_profile_for_target(target)
	return int(profile.get("activeEnemyCap", 20)) if not String(profile.get("balanceStage", "")).is_empty() else int(balance_root.get("baseActiveEnemyCap", 20))

static func additional_spawn_count_for_target(target: Node, rng: RandomNumberGenerator) -> int:
	var profile := relay_stage_profile_for_target(target)
	var minimum := int(profile.get("additionalSpawnCountMin", 0))
	var maximum := int(profile.get("additionalSpawnCountMax", minimum))
	return rng.randi_range(minimum, maxi(minimum, maximum))

static func tier_for_target(target: Node, rng: RandomNumberGenerator) -> String:
	var weights: Dictionary = relay_stage_profile_for_target(target).get("tierWeights", {}) as Dictionary
	if weights.is_empty():
		return ""
	var total := 0.0
	for item in weights.values():
		total += maxf(0.0, float((item as Dictionary).get("weight", 0.0)))
	if total <= 0.0:
		return "low"
	var roll := rng.randf() * total
	for key in ["low", "standard", "strong"]:
		var tier: Dictionary = weights.get(key, {}) as Dictionary
		roll -= maxf(0.0, float(tier.get("weight", 0.0)))
		if roll <= 0.0:
			return key
	return "low"

static func tier_kinds_for_target(target: Node, tier: String) -> Array:
	var profile := relay_stage_profile_for_target(target)
	var weights: Dictionary = profile.get("tierWeights", {}) as Dictionary
	return ((weights.get(tier, {}) as Dictionary).get("kinds", []) as Array).duplicate()

static func _drawing_pressure_reduced_for_target(_stage: Dictionary) -> bool:
	# Runtime-specific timers are read by spawn_amount_multiplier_for_target.
	return false

static func normal_stage_profile(config: Dictionary, segment_id: String, progress: float) -> Dictionary:
	var profile: Dictionary = {
		"hp": 1.0,
		"damage": 1.0,
		"speed": 1.0,
		"spawn": _normal_curve_value(config, "normalStageSpawnCurves", segment_id, progress),
		"upperWeight": _normal_curve_value(config, "normalUpperEnemyWeights", segment_id, progress),
		"progress": clampf(progress, 0.0, 1.0)
	}
	profile["phase"] = _normal_phase_for_progress(progress)
	return profile

static func profile_for_target(target: Node) -> Dictionary:
	var config: Dictionary = target.get("relay_mode_config") as Dictionary
	var segment_id := String(target.get("current_stream_frame_id"))
	var elapsed := float(target.get("elapsed"))
	if bool(target.get("relay_mode")):
		return enemy_multipliers(config, segment_id, elapsed)
	var duration := 180.0
	if target.has_method("_current_run_length"):
		duration = float(target.call("_current_run_length"))
	if is_inf(duration) or duration <= 0.0:
		duration = 180.0
	return normal_stage_profile(config, segment_id, elapsed / duration)

static func effective_spawn_multiplier(config: Dictionary, segment_id: String, elapsed: float) -> float:
	return maxf(0.25, float(enemy_multipliers(config, segment_id, elapsed).get("spawn", 1.0)))

static func damage_multiplier_for_target(target: Node) -> float:
	if target == null:
		return 1.0
	var config: Dictionary = target.get("relay_mode_config") as Dictionary
	var multipliers: Dictionary = config.get("enemyDamageMultipliers", {}) as Dictionary
	return maxf(0.05, float(multipliers.get(String(target.get("current_stream_frame_id")), 1.0)))

static func _normal_phase_for_progress(progress: float) -> String:
	if progress < 0.25:
		return "early"
	if progress < 0.60:
		return "mid"
	if progress < 0.85:
		return "late"
	return "final"

static func _normal_curve_value(config: Dictionary, curve_key: String, segment_id: String, progress: float) -> float:
	var curves: Dictionary = config.get(curve_key, {}) as Dictionary
	var values: Array = curves.get(segment_id, [1.0, 1.0, 1.0, 1.0]) as Array
	if values.is_empty():
		return 1.0
	var index := 0
	if progress >= 0.85:
		index = 3
	elif progress >= 0.60:
		index = 2
	elif progress >= 0.25:
		index = 1
	return float(values[mini(index, values.size() - 1)])

static func _relay_curve_value(config: Dictionary, curve_key: String, segment_id: String, elapsed: float) -> float:
	var curves: Dictionary = config.get(curve_key, {}) as Dictionary
	var values: Array = curves.get(segment_id, [1.0, 1.0, 1.0]) as Array
	if values.is_empty():
		return 1.0
	var times: Dictionary = config.get("phaseTimes", {}) as Dictionary
	var index := 0
	if elapsed >= float(times.get("mainEnd", 90.0)):
		index = 2
	elif elapsed >= float(times.get("introEnd", 30.0)):
		index = 1
	return float(values[mini(index, values.size() - 1)])
