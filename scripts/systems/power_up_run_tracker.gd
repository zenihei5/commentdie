class_name PowerUpRunTracker
extends RefCounted

const TrackerScript := preload("res://scripts/systems/power_up_run_tracker.gd")

var run_id := ""
var reward_eligible := true
var result_committed := false
var shop_upgrades_enabled := true
var total_shop_upgrade_level := 0
var rewarded_boss_keys: Dictionary = {}
var defeated_bosses: Array[Dictionary] = []
var relay_final_reached := false
var relay_final_defeated := false
var difficulty_id := "normal"
var field_gift_pp := 0
var fallback_gift_pp := 0
var full_build_conversion_pp := 0
var claimed_reward_ids: Dictionary = {}

static func start(enabled: bool, total_level: int, eligible: bool = true):
	var tracker = TrackerScript.new()
	tracker.run_id = _new_run_id()
	tracker.shop_upgrades_enabled = enabled
	tracker.total_shop_upgrade_level = total_level
	tracker.reward_eligible = eligible
	return tracker

func register_boss_defeat(data: Dictionary) -> bool:
	if not reward_eligible or String(data.get("defeatReason", "")) != "player_side_damage":
		return false
	var reward_key := String(data.get("rewardKey", ""))
	if reward_key == "" or rewarded_boss_keys.has(reward_key):
		return false
	rewarded_boss_keys[reward_key] = true
	defeated_bosses.append(data.duplicate(true))
	return true

func mark_relay_final_reached() -> void:
	relay_final_reached = true

func mark_relay_final_defeated() -> void:
	relay_final_reached = true
	relay_final_defeated = true

func grant_direct_pp(amount: int, source: String, reward_id: String) -> Dictionary:
	var normalized_amount := maxi(0, int(amount))
	var normalized_source := String(source).to_lower()
	var normalized_id := String(reward_id).strip_edges()
	if not reward_eligible:
		return {"granted": false, "amount": 0, "source": normalized_source, "rewardId": normalized_id, "reason": "ineligible"}
	if normalized_amount <= 0 or normalized_id == "":
		return {"granted": false, "amount": 0, "source": normalized_source, "rewardId": normalized_id, "reason": "invalid"}
	if claimed_reward_ids.has(normalized_id):
		return {"granted": false, "amount": 0, "source": normalized_source, "rewardId": normalized_id, "reason": "duplicate"}
	claimed_reward_ids[normalized_id] = true
	match normalized_source:
		"field_random", "field_gift":
			field_gift_pp += normalized_amount
		"full_build_conversion":
			full_build_conversion_pp += normalized_amount
		_:
			fallback_gift_pp += normalized_amount
	return {"granted": true, "amount": normalized_amount, "source": normalized_source, "rewardId": normalized_id, "reason": "granted"}

func direct_pp_subtotal() -> int:
	return maxi(0, field_gift_pp) + maxi(0, fallback_gift_pp) + maxi(0, full_build_conversion_pp)

func should_unlock_senior_unit(input: Dictionary) -> bool:
	return bool(input.get("rewardEligible", false)) \
		and bool(input.get("official", input.get("rewardEligible", false))) \
		and bool(input.get("isRelay", false)) \
		and String(input.get("difficultyId", "normal")) == "normal" \
		and String(input.get("outcome", "")) == "completed" \
		and bool(input.get("relayFinalDefeated", false))

func reward_input(is_relay: bool, outcome: String, active_seconds: float, stage_id: String, stage_cleared: bool, cleared_frame_ids: Array) -> Dictionary:
	return {
		"outcome": outcome,
		"rewardEligible": reward_eligible,
		"isRelay": is_relay,
		"activePlaySeconds": active_seconds,
		"stageId": stage_id,
		"stageCleared": stage_cleared,
		"difficultyId": difficulty_id,
		"official": reward_eligible,
		"defeatedBosses": defeated_bosses.duplicate(true),
		"relayClearedFrameIds": cleared_frame_ids.duplicate(),
		"relayFinalReached": relay_final_reached,
		"relayFinalDefeated": relay_final_defeated,
		"fieldGiftPp": maxi(0, field_gift_pp),
		"fallbackGiftPp": maxi(0, fallback_gift_pp),
		"fullBuildConversionPp": maxi(0, full_build_conversion_pp),
		"directPpSubtotal": direct_pp_subtotal(),
		"claimedRewardIds": claimed_reward_ids.keys()
	}

func to_dictionary() -> Dictionary:
	return {
		"runId": run_id,
		"rewardEligible": reward_eligible,
		"resultCommitted": result_committed,
		"shopUpgradesEnabled": shop_upgrades_enabled,
		"totalShopUpgradeLevel": total_shop_upgrade_level,
		"difficultyId": difficulty_id,
		"rewardedBossKeys": rewarded_boss_keys.duplicate(true),
		"defeatedBosses": defeated_bosses.duplicate(true),
		"relayFinalReached": relay_final_reached,
		"relayFinalDefeated": relay_final_defeated,
		"fieldGiftPp": maxi(0, field_gift_pp),
		"fallbackGiftPp": maxi(0, fallback_gift_pp),
		"fullBuildConversionPp": maxi(0, full_build_conversion_pp),
		"directPpSubtotal": direct_pp_subtotal(),
		"claimedRewardIds": claimed_reward_ids.duplicate(true)
	}

static func _new_run_id() -> String:
	var stamp := Time.get_datetime_string_from_system().replace("-", "").replace(":", "").replace("T", "_")
	return "run_%s_%08x" % [stamp, randi()]
