class_name StreamPointRewardCalculator
extends RefCounted

const StreamPointRewardResultScript := preload("res://scripts/systems/stream_point_reward_result.gd")

const DEFAULT_RULES := {
	"normal": {"participation": 5, "progressMax": 60, "progressDurationSeconds": 180.0, "clear": 85, "firstStageClear": 50, "firstBossDefeat": 75},
	"relay": {"participation": 10, "clearedFrame": 120, "finalReached": 100, "finalDefeated": 250, "firstClear": 200},
	"difficulty": {"normal": 1.0, "hard": 1.2, "expert": 1.4},
	"evaluation": {"S": 0.30, "A": 0.20, "B": 0.10, "C": 0.05, "D": 0.0}
}

static func difficulty_multiplier_for(difficulty_id: String) -> float:
	match difficulty_id.strip_edges().to_lower():
		"hard":
			return 1.2
		"expert":
			return 1.4
	return 1.0

static func evaluation_rate_for(rank: String) -> float:
	return float({"S": 0.30, "A": 0.20, "B": 0.10, "C": 0.05, "D": 0.0}.get(rank.strip_edges().to_upper(), 0.0))

static func recalculate_totals(result) -> void:
	var base := int(result.participation_pp) + int(result.progress_pp) + int(result.clear_pp) + int(result.boss_defeat_pp) + int(result.relay_stage_pp) + int(result.relay_final_reached_pp) + int(result.relay_final_clear_pp)
	result.repeat_reward_base = base
	result.difficulty_adjusted_reward = roundi(float(base) * maxf(0.0, float(result.difficulty_multiplier)))
	result.difficulty_adjustment = result.difficulty_adjusted_reward - base
	result.evaluation_bonus_pp = roundi(float(result.difficulty_adjusted_reward) * maxf(0.0, float(result.evaluation_bonus_rate)))
	result.repeatable_subtotal = result.difficulty_adjusted_reward + result.evaluation_bonus_pp
	result.one_time_subtotal = int(result.first_stage_clear_pp) + int(result.first_boss_defeat_pp) + int(result.first_relay_clear_pp)
	result.direct_pp_subtotal = maxi(0, int(result.field_gift_pp)) + maxi(0, int(result.fallback_gift_pp)) + maxi(0, int(result.full_build_conversion_pp))
	result.total_pp = result.repeatable_subtotal + result.one_time_subtotal + result.direct_pp_subtotal

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
	result.difficulty_multiplier = maxf(0.0, float(input.get("difficultyMultiplier", difficulty_rules.get(difficulty_id, difficulty_multiplier_for(difficulty_id)))))
	result.evaluation_version = int(input.get("evaluationVersion", 2))
	result.evaluation_score = clampi(int(input.get("evaluationScore", 0)), 0, 100)
	result.evaluation_rank = String(input.get("evaluationRank", "D")).strip_edges().to_upper()
	if not ["S", "A", "B", "C", "D"].has(result.evaluation_rank):
		result.evaluation_rank = "D"
	result.evaluation_bonus_rate = evaluation_rate_for(result.evaluation_rank)
	if is_relay:
		var relay_rules: Dictionary = all_rules.get("relay", {}) as Dictionary
		result.participation_pp = int(relay_rules.get("participation", 10))
		result.relay_stage_pp = maxi(0, int(input.get("relayClearedFrameIds", []).size())) * int(relay_rules.get("clearedFrame", 120))
		result.relay_final_reached_pp = int(relay_rules.get("finalReached", 100)) if bool(input.get("relayFinalReached", false)) else 0
		result.relay_final_clear_pp = int(relay_rules.get("finalDefeated", 250)) if bool(input.get("relayFinalDefeated", false)) else 0
		if bool(input.get("relayFinalDefeated", false)) and not first_relay_clear:
			result.first_relay_clear_pp = int(relay_rules.get("firstClear", 200))
			result.grants_first_relay_clear = true
	else:
		var normal_rules: Dictionary = all_rules.get("normal", {}) as Dictionary
		result.participation_pp = int(normal_rules.get("participation", 5))
		var active_seconds := float(input.get("activePlaySeconds", 0.0))
		result.progress_pp = roundi(float(normal_rules.get("progressMax", 60)) * clampf(active_seconds / maxf(0.01, float(normal_rules.get("progressDurationSeconds", 180.0))), 0.0, 1.0))
		result.clear_pp = int(normal_rules.get("clear", 85)) if bool(input.get("stageCleared", false)) and outcome == "completed" else 0
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
	result.field_gift_pp = maxi(0, int(input.get("fieldGiftPp", 0)))
	result.fallback_gift_pp = maxi(0, int(input.get("fallbackGiftPp", 0)))
	result.full_build_conversion_pp = maxi(0, int(input.get("fullBuildConversionPp", 0)))
	recalculate_totals(result)
	return result
