class_name StreamPointRewardResult
extends RefCounted

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
		["参加報酬", participation_pp], ["配信継続", progress_pp], ["配信クリア", clear_pp],
		["ボス討伐", boss_defeat_pp], ["リレー区間突破", relay_stage_pp],
		["ラスボス戦到達", relay_final_reached_pp], ["ラスボス撃破", relay_final_clear_pp],
		["配信枠初回クリア", first_stage_clear_pp], ["ボス初回討伐", first_boss_defeat_pp],
		["初回リレー完走", first_relay_clear_pp]
	]
	if field_gift_pp != 0:
		lines.append("フィールドギフト  %d PP" % field_gift_pp)
	if fallback_gift_pp + full_build_conversion_pp != 0:
		lines.append("ギフト変換  %d PP" % (fallback_gift_pp + full_build_conversion_pp))
	for entry in entries:
		if int(entry[1]) != 0:
			lines.append("%s  %d PP" % [String(entry[0]), int(entry[1])])
	return lines
