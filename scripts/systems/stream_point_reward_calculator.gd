class_name StreamPointRewardCalculator
extends RefCounted

const StreamPointRewardResultScript := preload("res://scripts/systems/stream_point_reward_result.gd")

const DEFAULT_RULES := {
	"normal": {"participation": 5, "progressMax": 60, "progressDurationSeconds": 180.0, "clear": 85, "firstStageClear": 50, "firstBossDefeat": 75},
	"relay": {"participation": 10, "clearedFrame": 120, "finalReached": 100, "finalDefeated": 250, "firstClear": 200},
	"difficulty": {"normal": 1.0, "hard": 1.0, "expert": 1.0}
}

static func calculate(input: Dictionary, first_stage_clears: Dictionary = {}, first_boss_defeats: Dictionary = {}, first_relay_clear: bool = false, rules: Dictionary = {}):
	var result = StreamPointRewardResultScript.new()
	if not bool(input.get("rewardEligible", false)):
		return result
	var outcome := String(input.get("outcome", "debug"))
	if outcome in ["retired", "crashed", "debug"]:
		return result
	var all_rules := DEFAULT_RULES.duplicate(true)
	if not rules.is_empty():
		all_rules = rules.duplicate(true)
	var is_relay := bool(input.get("isRelay", false))
	var difficulty_id := String(input.get("difficultyId", "normal"))
	var difficulty_rules: Dictionary = all_rules.get("difficulty", {}) as Dictionary
	result.difficulty_multiplier = maxf(0.0, float(input.get("difficultyMultiplier", difficulty_rules.get(difficulty_id, 1.0))))
	var repeatable := 0
	if is_relay:
		var relay_rules: Dictionary = all_rules.get("relay", {}) as Dictionary
		result.participation_pp = int(relay_rules.get("participation", 10))
		result.relay_stage_pp = maxi(0, int(input.get("relayClearedFrameIds", []).size())) * int(relay_rules.get("clearedFrame", 120))
		result.relay_final_reached_pp = int(relay_rules.get("finalReached", 100)) if bool(input.get("relayFinalReached", false)) else 0
		result.relay_final_clear_pp = int(relay_rules.get("finalDefeated", 250)) if bool(input.get("relayFinalDefeated", false)) else 0
		repeatable = result.participation_pp + result.relay_stage_pp + result.relay_final_reached_pp + result.relay_final_clear_pp
		if bool(input.get("relayFinalDefeated", false)) and not first_relay_clear:
			result.first_relay_clear_pp = int(relay_rules.get("firstClear", 200))
			result.grants_first_relay_clear = true
	else:
		var normal_rules: Dictionary = all_rules.get("normal", {}) as Dictionary
		result.participation_pp = int(normal_rules.get("participation", 5))
		var active_seconds := float(input.get("activePlaySeconds", 0.0))
		result.progress_pp = roundi(float(normal_rules.get("progressMax", 60)) * clampf(active_seconds / maxf(0.01, float(normal_rules.get("progressDurationSeconds", 180.0))), 0.0, 1.0))
		result.clear_pp = int(normal_rules.get("clear", 85)) if bool(input.get("stageCleared", false)) and outcome == "completed" else 0
		repeatable = result.participation_pp + result.progress_pp + result.clear_pp
		var stage_id := String(input.get("stageId", ""))
		if bool(input.get("stageCleared", false)) and outcome == "completed" and stage_id != "" and not bool(first_stage_clears.get(stage_id, false)):
			result.first_stage_clear_pp = int(normal_rules.get("firstStageClear", 50))
			result.newly_cleared_stage_ids.append(stage_id)
			result.reward_keys.append("first_stage:" + stage_id)
	var first_boss_pp := int(all_rules.get("normal", {}).get("firstBossDefeat", 75))
	var seen_reward_keys: Dictionary = {}
	var seen_first_defeat_ids: Dictionary = {}
	for item in input.get("defeatedBosses", []) as Array:
		if not (item is Dictionary):
			continue
		var boss: Dictionary = item as Dictionary
		if not bool(boss.get("isPpRewardTarget", false)) or String(boss.get("defeatReason", "")) != "player_side_damage":
			continue
		var reward_key := String(boss.get("rewardKey", ""))
		if reward_key == "" or seen_reward_keys.has(reward_key):
			continue
		seen_reward_keys[reward_key] = true
		result.reward_keys.append(reward_key)
		var pp_reward_id := String(boss.get("ppRewardId", boss.get("bossId", "")))
		var base_pp := int(boss.get("basePpReward", 0))
		var pp_rate := maxf(0.0, float(boss.get("ppRate", 1.0)))
		if base_pp > 0:
			var adjusted_base_pp := roundi(float(base_pp) * pp_rate)
			result.boss_defeat_pp += adjusted_base_pp
			result.boss_reward_entries.append({"rewardKey": reward_key, "ppRewardId": pp_reward_id, "basePpReward": adjusted_base_pp})
		if bool(boss.get("isFirstDefeatRewardTarget", false)) and pp_reward_id != "last_offline" and not bool(first_boss_defeats.get(pp_reward_id, false)) and not seen_first_defeat_ids.has(pp_reward_id):
			result.first_boss_defeat_pp += roundi(float(first_boss_pp) * pp_rate)
			seen_first_defeat_ids[pp_reward_id] = true
			if not result.newly_defeated_boss_ids.has(pp_reward_id):
				result.newly_defeated_boss_ids.append(pp_reward_id)
			if not result.reward_keys.has("first:" + pp_reward_id):
				result.reward_keys.append("first:" + pp_reward_id)
	if result.grants_first_relay_clear:
		result.reward_keys.append("first:relay")
	if not result.newly_defeated_boss_ids.is_empty():
		result.first_boss_defeat_pp = maxi(result.first_boss_defeat_pp, result.newly_defeated_boss_ids.size() * first_boss_pp)
	result.repeatable_subtotal = roundi(float(repeatable + result.boss_defeat_pp) * result.difficulty_multiplier)
	result.one_time_subtotal = result.first_stage_clear_pp + result.first_boss_defeat_pp + result.first_relay_clear_pp
	result.field_gift_pp = maxi(0, int(input.get("fieldGiftPp", 0)))
	result.fallback_gift_pp = maxi(0, int(input.get("fallbackGiftPp", 0)))
	result.full_build_conversion_pp = maxi(0, int(input.get("fullBuildConversionPp", 0)))
	result.direct_pp_subtotal = result.field_gift_pp + result.fallback_gift_pp + result.full_build_conversion_pp
	result.total_pp = result.repeatable_subtotal + result.one_time_subtotal + result.direct_pp_subtotal
	return result
