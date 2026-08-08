class_name ExpSystem
extends RefCounted

const EXP_NEEDS := [5, 10, 18, 30, 45, 65, 90, 120, 155, 195]
const EXTRA_LEVEL_GROWTH_RATE := 1.10
const MAX_EXP_ORBS := 220
const EXP_ORB_MERGE_RADIUS := 56.0
const EXP_PICKUP_RADIUS := 24.0
const PowerUpEffectProviderScript := preload("res://scripts/systems/power_up_effect_provider.gd")
const HardModeSystemScript := preload("res://scripts/systems/hard_mode_system.gd")

static func current_need(level: int) -> int:
	var idx := maxi(0, level - 1)
	if idx < EXP_NEEDS.size():
		return int(EXP_NEEDS[idx])
	var need: int = int(EXP_NEEDS[EXP_NEEDS.size() - 1])
	for _i in range(EXP_NEEDS.size(), idx + 1):
		need = int(floor(float(need) * EXTRA_LEVEL_GROWTH_RATE))
	return need

static func reward_config_for_enemy(enemy: Dictionary) -> Dictionary:
	var raw: Variant = enemy.get("rewardConfig", {})
	var source: Dictionary = raw as Dictionary if raw is Dictionary else {}
	var no_rewards := bool(enemy.get("noRewards", false))
	var config := {
		"scoreEnabled": bool(source.get("scoreEnabled", not bool(enemy.get("scoreDisabled", false)) and not no_rewards)),
		"scoreRate": maxf(0.0, float(source.get("scoreRate", enemy.get("scoreMultiplier", 1.0)))),
		"expEnabled": bool(source.get("expEnabled", not no_rewards)),
		"expRate": maxf(0.0, float(source.get("expRate", enemy.get("expRewardRate", 1.0)))),
		"starDropEnabled": bool(source.get("starDropEnabled", enemy.get("starDropEnabled", false))),
		"healDropEnabled": bool(source.get("healDropEnabled", enemy.get("healDropEnabled", enemy.has("healDropRate")))),
		"healDropRate": clampf(float(source.get("healDropRate", enemy.get("healDropRate", 0.0))), 0.0, 1.0)
	}
	# Legacy noRewards is still an all-reward kill switch unless an explicit
	# rewardConfig was supplied by the final-boss summon path.
	if no_rewards and source.is_empty():
		config["scoreEnabled"] = false
		config["expEnabled"] = false
	return config

static func base_exp_for_enemy(enemy: Dictionary) -> float:
	if enemy.has("baseExp"):
		return maxf(0.0, float(enemy.get("baseExp", 0.0)))
	var difficulty_base: Variant = enemy.get("difficultyBase", {})
	if difficulty_base is Dictionary and (difficulty_base as Dictionary).has("exp"):
		return maxf(0.0, float((difficulty_base as Dictionary).get("exp", 0.0)))
	return maxf(0.0, float(enemy.get("expValue", enemy.get("exp", 0.0))))

static func drop_from_enemy_for_target(target: Node, enemy: Dictionary) -> Dictionary:
	var reward := reward_config_for_enemy(enemy)
	if not bool(reward.get("expEnabled", true)):
		return {"generatedExp": 0, "expEnabled": false, "orbCreated": false, "discarded": 0}
	var runtime: Variant = target.get("difficulty_runtime")
	var difficulty_rate := 1.0
	if runtime is Dictionary:
		difficulty_rate = HardModeSystemScript.effective_exp_rate(runtime as Dictionary)
	var raw_value := base_exp_for_enemy(enemy) * difficulty_rate * float(reward.get("expRate", 1.0))
	var value := maxi(1, roundi(raw_value))
	var result := drop_value_for_target(target, Vector2(enemy.get("pos", Vector2.ZERO)), value)
	result["generatedExp"] = value
	result["expEnabled"] = true
	_record_generated_exp(target, value)
	return result

static func drop_bonus_value_for_target(target: Node, pos: Vector2, base_value: float, reward_rate: float, variant: String = "") -> int:
	var runtime: Variant = target.get("difficulty_runtime")
	var difficulty_rate := 1.0
	if runtime is Dictionary:
		difficulty_rate = HardModeSystemScript.effective_exp_rate(runtime as Dictionary)
	var value := maxi(1, roundi(maxf(0.0, base_value) * difficulty_rate * maxf(0.0, reward_rate)))
	drop_value_for_target(target, pos, value, variant)
	_record_generated_exp(target, value)
	return value

static func drop_value_for_target(target: Node, pos: Vector2, value: int, variant: String = "") -> Dictionary:
	var orbs: Array = target.get("exp_orbs") as Array
	value = maxi(1, value)
	if orbs.size() >= MAX_EXP_ORBS:
		_merge_exp_drop(orbs, pos, value)
		return {"orbCreated": false, "merged": true, "discarded": 0}
	var orb := {
		"pos": pos,
		"value": value,
		"visualType": visual_type_for_value(value),
		"life": 20.0
	}
	if variant != "":
		orb["variant"] = variant
	orbs.append(orb)
	return {"orbCreated": true, "merged": false, "discarded": 0}

static func _record_generated_exp(target: Node, value: int) -> void:
	var stats: Dictionary = target.get("balance_debug_stats") as Dictionary
	stats["expGenerated"] = int(stats.get("expGenerated", 0)) + value
	stats["expDropped"] = int(stats.get("expDropped", 0)) + value
	target.set("balance_debug_stats", stats)
	var runtime: Variant = target.get("difficulty_runtime")
	if runtime is Dictionary:
		var exp_stats: Dictionary = (runtime as Dictionary).get("expStats", {}) as Dictionary
		exp_stats["generated"] = int(exp_stats.get("generated", 0)) + value
		runtime["expStats"] = exp_stats
	var run_stats: Variant = target.get("hard_run_exp_stats")
	if run_stats is Dictionary:
		(run_stats as Dictionary)["generated"] = int((run_stats as Dictionary).get("generated", 0)) + value

static func discard_orbs_for_target(target: Node) -> int:
	var orbs: Array = target.get("exp_orbs") as Array
	var discarded := _sum_orb_values(orbs)
	if discarded <= 0:
		return 0
	var stats: Dictionary = target.get("balance_debug_stats") as Dictionary
	stats["expDiscarded"] = int(stats.get("expDiscarded", 0)) + discarded
	stats["expUncollected"] = 0
	target.set("balance_debug_stats", stats)
	var runtime: Variant = target.get("difficulty_runtime")
	if runtime is Dictionary:
		var exp_stats: Dictionary = (runtime as Dictionary).get("expStats", {}) as Dictionary
		exp_stats["discarded"] = int(exp_stats.get("discarded", 0)) + discarded
		exp_stats["uncollected"] = 0
		runtime["expStats"] = exp_stats
	var run_stats: Variant = target.get("hard_run_exp_stats")
	if run_stats is Dictionary:
		(run_stats as Dictionary)["discarded"] = int((run_stats as Dictionary).get("discarded", 0)) + discarded
		(run_stats as Dictionary)["uncollected"] = 0
	return discarded

static func _merge_exp_drop(orbs: Array, pos: Vector2, value: int) -> void:
	var best_index := -1
	var best_distance := INF
	var oldest_index := 0
	var oldest_life := INF
	var merge_radius_sq := EXP_ORB_MERGE_RADIUS * EXP_ORB_MERGE_RADIUS
	for i in range(orbs.size()):
		var orb: Dictionary = orbs[i]
		var rod_state := String(orb.get("rodCollectionState", "free"))
		if rod_state in ["attracted_to_lure", "attached_to_lure", "returning_with_lure", "homing_to_player"]:
			continue
		var orb_life := float(orb.get("life", 0.0))
		if orb_life < oldest_life:
			oldest_life = orb_life
			oldest_index = i
		var distance_sq := Vector2(orb.get("pos", pos)).distance_squared_to(pos)
		if distance_sq < best_distance and distance_sq <= merge_radius_sq:
			best_distance = distance_sq
			best_index = i
	if best_index < 0:
		# If every orb is temporarily claimed, preserve EXP mass by merging into
		# the oldest claimed orb rather than dropping the newly generated value.
		best_index = oldest_index if oldest_life < INF else 0
	var target_orb: Dictionary = orbs[best_index]
	var merged_value := int(target_orb.get("value", 1)) + value
	target_orb["value"] = merged_value
	target_orb["visualType"] = visual_type_for_value(merged_value)
	target_orb["life"] = maxf(float(target_orb.get("life", 0.0)), 12.0)
	target_orb["pos"] = Vector2(target_orb.get("pos", pos)).lerp(pos, 0.35)

static func visual_type_for_value(value: int) -> String:
	if value <= 1:
		return "small_blue"
	if value <= 3:
		return "medium_green"
	if value <= 6:
		return "large_red"
	return "gold_rainbow"

static func update_orbs(context: Dictionary) -> Dictionary:
	var orbs: Array = context["orbs"] as Array
	var player_pos: Vector2 = Vector2(context["playerPos"])
	var magnet_range: float = float(context["magnetRange"])
	var magnet_range_sq := magnet_range * magnet_range
	var pickup_radius_sq := EXP_PICKUP_RADIUS * EXP_PICKUP_RADIUS
	var magnet_speed_rate: float = maxf(0.1, float(context.get("magnetSpeedRate", 1.0)))
	var delta: float = float(context["delta"])
	var collected_exp: int = 0
	var collected_count: int = 0
	var attracted_count: int = 0
	var expired_exp: int = 0
	var kept_orbs: Array = []
	for orb_item in orbs:
		var orb: Dictionary = orb_item
		var rod_state := String(orb.get("rodCollectionState", "free"))
		if rod_state in ["attracted_to_lure", "attached_to_lure", "returning_with_lure"]:
			kept_orbs.append(orb)
			continue
		if rod_state == "homing_to_player":
			orb["rodCollectionState"] = "free"
			orb.erase("rodClaimToken")
			orb.erase("rodAttachIndex")
		var pos: Vector2 = Vector2(orb["pos"])
		var life := float(orb["life"]) - delta
		if life <= 0.0:
			expired_exp += int(orb.get("value", 0))
			continue
		orb["life"] = life
		if pos.distance_squared_to(player_pos) <= magnet_range_sq:
			attracted_count += 1
			pos = pos.lerp(player_pos, minf(1.0, delta * 7.5 * magnet_speed_rate))
		orb["pos"] = pos
		if pos.distance_squared_to(player_pos) < pickup_radius_sq:
			collected_count += 1
			collected_exp += int(orb["value"])
			continue
		kept_orbs.append(orb)
	return {
		"orbs": kept_orbs,
		"collectedExp": collected_exp,
		"collectedCount": collected_count,
		"attractedCount": attracted_count,
		"expiredExp": expired_exp,
		"uncollectedExp": _sum_orb_values(kept_orbs)
	}

static func _sum_orb_values(orbs: Array) -> int:
	var total := 0
	for item in orbs:
		if item is Dictionary:
			total += maxi(0, int((item as Dictionary).get("value", 0)))
	return total

static func update_orbs_for_target(target: Node, delta: float) -> Dictionary:
	var pickup_range_multiplier := 1.0
	if target.has_method("_song_live_heat_pickup_range_multiplier"):
		pickup_range_multiplier = maxf(0.1, float(target.call("_song_live_heat_pickup_range_multiplier")))
	var result: Dictionary = update_orbs({
		"orbs": target.get("exp_orbs"),
		"playerPos": target.get("player_pos"),
		"magnetRange": float(target.get("magnet_range")) * pickup_range_multiplier,
		"magnetSpeedRate": target.get("item_magnet_speed_rate"),
		"delta": delta
	})
	target.set("exp_orbs", result["orbs"] as Array)
	var balance_stats: Dictionary = target.get("balance_debug_stats") as Dictionary
	balance_stats["expExpired"] = int(balance_stats.get("expExpired", 0)) + int(result.get("expiredExp", 0))
	balance_stats["expUncollected"] = int(result.get("uncollectedExp", 0))
	target.set("balance_debug_stats", balance_stats)
	var runtime: Variant = target.get("difficulty_runtime")
	if runtime is Dictionary:
		var exp_stats: Dictionary = (runtime as Dictionary).get("expStats", {}) as Dictionary
		exp_stats["expired"] = int(exp_stats.get("expired", 0)) + int(result.get("expiredExp", 0))
		exp_stats["uncollected"] = int(result.get("uncollectedExp", 0))
		runtime["expStats"] = exp_stats
	var run_stats: Variant = target.get("hard_run_exp_stats")
	if run_stats is Dictionary:
		(run_stats as Dictionary)["expired"] = int((run_stats as Dictionary).get("expired", 0)) + int(result.get("expiredExp", 0))
		(run_stats as Dictionary)["uncollected"] = int(result.get("uncollectedExp", 0))
	if int(result.get("attractedCount", 0)) > 0:
		_append_comment_radar_fx_for_target(target)
	var collected_count: int = int(result["collectedCount"])
	result["levelUp"] = false
	result["levelUps"] = 0
	if collected_count > 0:
		if target.has_method("_collab_challenge_exp_gain_multiplier"):
			result["collectedExp"] = roundi(float(result["collectedExp"]) * maxf(1.0, float(target.call("_collab_challenge_exp_gain_multiplier"))))
		var bonus: int = ScoreSystem.exp_collect_bonus(int(target.get("like_score_level")), collected_count)
		target.set("score", int(target.get("score")) + bonus)
		var level_ups: int = add_exp_to_target(target, int(result["collectedExp"]))
		result["levelUps"] = level_ups
		result["levelUp"] = level_ups > 0
		balance_stats["expCollected"] = int(balance_stats.get("expCollected", 0)) + int(result["collectedExp"])
		balance_stats["levelUps"] = int(balance_stats.get("levelUps", 0)) + level_ups
		target.set("balance_debug_stats", balance_stats)
		if runtime is Dictionary:
			var exp_stats_after: Dictionary = (runtime as Dictionary).get("expStats", {}) as Dictionary
			exp_stats_after["collected"] = int(exp_stats_after.get("collected", 0)) + int(result["collectedExp"])
			exp_stats_after["uncollected"] = int(result.get("uncollectedExp", 0))
			(runtime as Dictionary)["expStats"] = exp_stats_after
		if run_stats is Dictionary:
			(run_stats as Dictionary)["collected"] = int((run_stats as Dictionary).get("collected", 0)) + int(result["collectedExp"])
			(run_stats as Dictionary)["uncollected"] = int(result.get("uncollectedExp", 0))
	return result

static func should_vacuum(enabled: bool, timer: float, delta: float) -> Dictionary:
	if not enabled:
		return {"timer": timer, "trigger": false}
	timer -= delta
	if timer > 0.0:
		return {"timer": timer, "trigger": false}
	return {"timer": 2.5, "trigger": true}

static func update_vacuum_for_target(target: Node, delta: float) -> bool:
	var result: Dictionary = should_vacuum(bool(target.get("exp_vacuum_extreme")), float(target.get("exp_vacuum_timer")), delta)
	target.set("exp_vacuum_timer", float(result["timer"]))
	if not bool(result["trigger"]):
		return false
	var orbs: Array = target.get("exp_orbs") as Array
	var player_pos: Vector2 = Vector2(target.get("player_pos"))
	for orb in orbs:
		orb["pos"] = player_pos
	return true

static func update_world_for_target(target: Node, delta: float) -> Dictionary:
	var result: Dictionary = update_orbs_for_target(target, delta)
	result["vacuumTriggered"] = update_vacuum_for_target(target, delta)
	return result

static func add_exp_to_target(target: Node, amount: int) -> int:
	var shop_snapshot = target.get("permanent_upgrade_snapshot")
	var shop_amount := amount if shop_snapshot == null else PowerUpEffectProviderScript.exp_amount(amount, shop_snapshot)
	var adjusted_amount: int = _exp_amount_with_notification_bonus_for_target(target, shop_amount)
	target.set("exp_value", int(target.get("exp_value")) + adjusted_amount)
	var level_ups := 0
	while int(target.get("exp_value")) >= current_need(int(target.get("exp_level"))):
		var need: int = current_need(int(target.get("exp_level")))
		target.set("exp_value", int(target.get("exp_value")) - need)
		target.set("exp_level", int(target.get("exp_level")) + 1)
		level_ups += 1
	return level_ups

static func _exp_amount_with_notification_bonus_for_target(target: Node, amount: int) -> int:
	if amount <= 0:
		return 0
	var level: int = int(target.get("notification_bell_level"))
	if level <= 0:
		return amount
	var bonus_pool: float = float(amount) * GiftSystem.notification_bell_exp_rate(level) + float(target.get("exp_bonus_remainder"))
	var bonus: int = int(floor(bonus_pool))
	target.set("exp_bonus_remainder", bonus_pool - float(bonus))
	if bonus > 0:
		_append_notification_bell_fx_for_target(target, bonus)
	return amount + bonus

static func _append_notification_bell_fx_for_target(target: Node, bonus: int) -> void:
	var hit_fx: Array = target.get("hit_fx") as Array
	hit_fx.append({
		"kind": "notification_bell",
		"pos": Vector2(target.get("player_pos")) + Vector2(26.0, -46.0),
		"life": 0.46,
		"maxLife": 0.46,
		"bonus": bonus
	})

static func _append_comment_radar_fx_for_target(target: Node) -> void:
	if int(target.get("comment_radar_level")) <= 0:
		return
	if float(target.get("comment_radar_fx_timer")) > 0.0:
		return
	var hit_fx: Array = target.get("hit_fx") as Array
	hit_fx.append({
		"kind": "comment_radar_ping",
		"pos": Vector2(target.get("player_pos")),
		"life": 0.38,
		"maxLife": 0.38,
		"radius": float(target.get("magnet_range"))
	})
	target.set("comment_radar_fx_timer", GiftSystem.COMMENT_RADAR_FX_COOLDOWN)
