class_name StreamPointRewardResult
extends RefCounted

const ResultScript := preload("res://scripts/systems/stream_point_reward_result.gd")
var participation_pp := 0
var progress_pp := 0
var clear_pp := 0
var boss_defeat_pp := 0
var relay_stage_pp := 0
var relay_final_reached_pp := 0
var relay_final_clear_pp := 0
var first_stage_clear_pp := 0
var first_boss_defeat_pp := 0
var first_relay_clear_pp := 0
var difficulty_multiplier := 1.0
var repeat_reward_base := 0
var difficulty_adjusted_reward := 0
var difficulty_adjustment := 0
var evaluation_version := 2
var evaluation_score := 0
var evaluation_rank := "D"
var evaluation_bonus_rate := 0.0
var evaluation_bonus_pp := 0
var repeatable_subtotal := 0
var one_time_subtotal := 0
var field_gift_pp := 0
var fallback_gift_pp := 0
var full_build_conversion_pp := 0
var direct_pp_subtotal := 0
var total_pp := 0
var newly_cleared_stage_ids: Array[String] = []
var newly_defeated_boss_ids: Array[String] = []
var grants_first_relay_clear := false
var reward_keys: Array[String] = []
var boss_reward_entries: Array[Dictionary] = []

static func from_dictionary(data: Dictionary):
	var result := ResultScript.new()
	result.participation_pp = int(data.get("participationPp", 0))
	result.progress_pp = int(data.get("progressPp", 0))
	result.clear_pp = int(data.get("clearPp", 0))
	result.boss_defeat_pp = int(data.get("bossDefeatPp", 0))
	result.relay_stage_pp = int(data.get("relayStagePp", 0))
	result.relay_final_reached_pp = int(data.get("relayFinalReachedPp", 0))
	result.relay_final_clear_pp = int(data.get("relayFinalClearPp", 0))
	result.first_stage_clear_pp = int(data.get("firstStageClearPp", 0))
	result.first_boss_defeat_pp = int(data.get("firstBossDefeatPp", 0))
	result.first_relay_clear_pp = int(data.get("firstRelayClearPp", 0))
	result.difficulty_multiplier = float(data.get("difficultyMultiplier", 1.0))
	result.repeat_reward_base = int(data.get("repeatRewardBase", 0))
	result.difficulty_adjusted_reward = int(data.get("difficultyAdjustedReward", 0))
	result.difficulty_adjustment = int(data.get("difficultyAdjustment", 0))
	result.evaluation_version = int(data.get("evaluationVersion", 2))
	result.evaluation_score = int(data.get("evaluationScore", 0))
	result.evaluation_rank = String(data.get("evaluationRank", "D"))
	result.evaluation_bonus_rate = float(data.get("evaluationBonusRate", 0.0))
	result.evaluation_bonus_pp = int(data.get("evaluationBonusPp", 0))
	result.repeatable_subtotal = int(data.get("repeatableSubtotal", 0))
	result.one_time_subtotal = int(data.get("oneTimeSubtotal", 0))
	result.field_gift_pp = int(data.get("fieldGiftPp", 0))
	result.fallback_gift_pp = int(data.get("fallbackGiftPp", 0))
	result.full_build_conversion_pp = int(data.get("fullBuildConversionPp", 0))
	result.direct_pp_subtotal = int(data.get("directPpSubtotal", 0))
	result.total_pp = int(data.get("totalPp", 0))
	for value in data.get("newlyClearedStageIds", []) as Array:
		result.newly_cleared_stage_ids.append(String(value))
	for value in data.get("newlyDefeatedBossIds", []) as Array:
		result.newly_defeated_boss_ids.append(String(value))
	result.grants_first_relay_clear = bool(data.get("grantsFirstRelayClear", false))
	for value in data.get("rewardKeys", []) as Array:
		result.reward_keys.append(String(value))
	for value in data.get("bossRewardEntries", []) as Array:
		if value is Dictionary:
			result.boss_reward_entries.append((value as Dictionary).duplicate(true))
	return result

func to_dictionary() -> Dictionary:
	return {
		"participationPp": participation_pp,
		"progressPp": progress_pp,
		"clearPp": clear_pp,
		"bossDefeatPp": boss_defeat_pp,
		"relayStagePp": relay_stage_pp,
		"relayFinalReachedPp": relay_final_reached_pp,
		"relayFinalClearPp": relay_final_clear_pp,
		"firstStageClearPp": first_stage_clear_pp,
		"firstBossDefeatPp": first_boss_defeat_pp,
		"firstRelayClearPp": first_relay_clear_pp,
		"difficultyMultiplier": difficulty_multiplier,
		"repeatRewardBase": repeat_reward_base,
		"difficultyAdjustedReward": difficulty_adjusted_reward,
		"difficultyAdjustment": difficulty_adjustment,
		"evaluationVersion": evaluation_version,
		"evaluationScore": evaluation_score,
		"evaluationRank": evaluation_rank,
		"evaluationBonusRate": evaluation_bonus_rate,
		"evaluationBonusPp": evaluation_bonus_pp,
		"repeatableSubtotal": repeatable_subtotal,
		"oneTimeSubtotal": one_time_subtotal,
		"fieldGiftPp": field_gift_pp,
		"fallbackGiftPp": fallback_gift_pp,
		"fullBuildConversionPp": full_build_conversion_pp,
		"directPpSubtotal": direct_pp_subtotal,
		"totalPp": total_pp,
		"newlyClearedStageIds": newly_cleared_stage_ids.duplicate(),
		"newlyDefeatedBossIds": newly_defeated_boss_ids.duplicate(),
		"grantsFirstRelayClear": grants_first_relay_clear,
		"rewardKeys": reward_keys.duplicate(),
		"bossRewardEntries": boss_reward_entries.duplicate(true)
	}

func breakdown_lines() -> Array[String]:
	var lines: Array[String] = []
	var entries := [
		["参加報酬", participation_pp, false], ["配信継続", progress_pp, false], ["配信クリア", clear_pp, false],
		["ボス討伐", boss_defeat_pp, false], ["リレー区間突破", relay_stage_pp, false],
		["ラスボス戦到達", relay_final_reached_pp, false], ["ラスボス撃破", relay_final_clear_pp, false],
		["配信枠初回クリア", first_stage_clear_pp, true], ["ボス初回討伐", first_boss_defeat_pp, true],
		["初回リレー完走", first_relay_clear_pp, true]
	]
	if difficulty_adjustment != 0:
		lines.append("難易度調整  %d PP" % difficulty_adjustment)
	if evaluation_bonus_pp != 0:
		lines.append("配信評価ボーナス  %d PP" % evaluation_bonus_pp)
	for entry in entries:
		if not bool(entry[2]) and int(entry[1]) != 0:
			lines.append("%s  %d PP" % [String(entry[0]), int(entry[1])])
	for entry in entries:
		if bool(entry[2]) and int(entry[1]) != 0:
			lines.append("%s  %d PP" % [String(entry[0]), int(entry[1])])
	if field_gift_pp != 0:
		lines.append("フィールドギフト  %d PP" % field_gift_pp)
	if fallback_gift_pp + full_build_conversion_pp != 0:
		lines.append("ギフト変換  %d PP" % (fallback_gift_pp + full_build_conversion_pp))
	return lines
