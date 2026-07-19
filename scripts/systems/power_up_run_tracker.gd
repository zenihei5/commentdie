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

func reward_input(is_relay: bool, outcome: String, active_seconds: float, stage_id: String, stage_cleared: bool, cleared_frame_ids: Array) -> Dictionary:
	return {
		"outcome": outcome,
		"rewardEligible": reward_eligible,
		"isRelay": is_relay,
		"activePlaySeconds": active_seconds,
		"stageId": stage_id,
		"stageCleared": stage_cleared,
		"difficultyId": "normal",
		"defeatedBosses": defeated_bosses.duplicate(true),
		"relayClearedFrameIds": cleared_frame_ids.duplicate(),
		"relayFinalReached": relay_final_reached,
		"relayFinalDefeated": relay_final_defeated
	}

func to_dictionary() -> Dictionary:
	return {
		"runId": run_id,
		"rewardEligible": reward_eligible,
		"resultCommitted": result_committed,
		"shopUpgradesEnabled": shop_upgrades_enabled,
		"totalShopUpgradeLevel": total_shop_upgrade_level,
		"rewardedBossKeys": rewarded_boss_keys.duplicate(true),
		"defeatedBosses": defeated_bosses.duplicate(true),
		"relayFinalReached": relay_final_reached,
		"relayFinalDefeated": relay_final_defeated
	}

static func _new_run_id() -> String:
	var stamp := Time.get_datetime_string_from_system().replace("-", "").replace(":", "").replace("T", "_")
	return "run_%s_%08x" % [stamp, randi()]
