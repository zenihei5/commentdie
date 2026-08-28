class_name PowerUpShopManager
extends RefCounted

const PowerUpDatabaseScript := preload("res://scripts/systems/power_up_database.gd")
const PowerUpSaveStoreScript := preload("res://scripts/systems/power_up_save_store.gd")
const PowerUpEffectProviderScript := preload("res://scripts/systems/power_up_effect_provider.gd")
const StreamPointRewardCalculatorScript := preload("res://scripts/systems/stream_point_reward_calculator.gd")

signal points_changed(previous_value: int, new_value: int)
signal upgrade_purchased(upgrade_id: String, new_level: int, price: int)
signal upgrades_reset(refunded_points: int)
signal shop_unlocked
signal purchase_failed(reason: int)
signal reward_granted(run_id: String, total_pp: int)

enum Result { SUCCESS, LOCKED, BUSY, INVALID_ID, MAX_LEVEL, NOT_ENOUGH_POINTS, SAVE_FAILED, NOTHING_TO_RESET }

var database
var store
var profile: Dictionary = {}
var busy := false
const SENIOR_UNIT_CHARACTER_IDS := ["aosumi_kyasumi", "akarine_rizumu", "shizuki_miimu"]

func _init(database_instance = null, store_instance = null) -> void:
	database = database_instance if database_instance != null else PowerUpDatabaseScript.load_default()
	store = store_instance if store_instance != null else PowerUpSaveStoreScript.new()
	profile = store.load_data(database) if database.is_valid else store.default_data(database)

func is_available() -> bool:
	return database != null and database.is_valid

func is_unlocked() -> bool:
	return bool(profile.get("unlocked", false))

func current_points() -> int:
	return int(profile.get("currentPoints", 0))

func total_upgrade_level() -> int:
	var levels: Dictionary = profile.get("upgrades", {}) as Dictionary
	var total := 0
	for value in levels.values():
		total += int(value)
	return total

func get_upgrade_level(id: String) -> int:
	var levels: Dictionary = profile.get("upgrades", {}) as Dictionary
	return int(levels.get(id, 0))

func upgrade_levels() -> Dictionary:
	return (profile.get("upgrades", {}) as Dictionary).duplicate(true)

func selected_character_id() -> String:
	return String(profile.get("selectedCharacterId", "ban_chan"))

func unlocked_character_ids() -> Array:
	return (profile.get("unlockedCharacterIds", ["ban_chan", "superchat_chan", "maro_chan"]) as Array).duplicate()

func is_character_unlocked(id: String) -> bool:
	return unlocked_character_ids().has(id)

func discovered_evolution_recipe_ids() -> Array[String]:
	var discovered: Array[String] = []
	var stored: Variant = profile.get("discoveredEvolutionRecipes", [])
	if not (stored is Array):
		return discovered
	for item in stored as Array:
		var recipe_id: String = item.strip_edges() if item is String else str(item).strip_edges()
		if recipe_id != "" and not discovered.has(recipe_id):
			discovered.append(recipe_id)
	return discovered

func is_evolution_recipe_discovered(evolved_weapon_id: String) -> bool:
	var normalized_id := evolved_weapon_id.strip_edges()
	return normalized_id != "" and discovered_evolution_recipe_ids().has(normalized_id)

func discover_evolution_recipe(evolved_weapon_id: String) -> Dictionary:
	var normalized_id := evolved_weapon_id.strip_edges()
	if normalized_id == "":
		return {"ok": false, "newlyDiscovered": false, "saveFailed": false, "state": "invalid_id", "evolvedWeaponId": ""}
	var discovered := discovered_evolution_recipe_ids()
	if discovered.has(normalized_id):
		return {"ok": true, "newlyDiscovered": false, "saveFailed": false, "state": "already_discovered", "evolvedWeaponId": normalized_id}
	var candidate := profile.duplicate(true)
	discovered.append(normalized_id)
	candidate["discoveredEvolutionRecipes"] = discovered
	if not _commit(candidate):
		return {"ok": false, "newlyDiscovered": false, "saveFailed": true, "state": "save_failed", "evolvedWeaponId": normalized_id}
	return {"ok": true, "newlyDiscovered": true, "saveFailed": false, "state": "discovered", "evolvedWeaponId": normalized_id}

func save_selected_character_id(id: String) -> bool:
	var normalized_id := id.strip_edges()
	if normalized_id == "" or not is_character_unlocked(normalized_id):
		return false
	if selected_character_id() == normalized_id:
		return true
	var candidate := profile.duplicate(true)
	candidate["selectedCharacterId"] = normalized_id
	return _commit(candidate)

func grant_senior_unit_unlock_if_eligible(eligible: bool) -> bool:
	if not eligible:
		return false
	var candidate := profile.duplicate(true)
	var already_cleared := bool(candidate.get("normalRelayCleared", false))
	var unlocked: Array = candidate.get("unlockedCharacterIds", []) as Array
	var changed := false
	for id in SENIOR_UNIT_CHARACTER_IDS:
		if not unlocked.has(id):
			unlocked.append(id)
			changed = true
	candidate["unlockedCharacterIds"] = unlocked
	if not already_cleared:
		candidate["normalRelayCleared"] = true
		changed = true
	if not bool(candidate.get("seniorUnitUnlockShown", false)):
		candidate["seniorUnitUnlockShown"] = true
		changed = true
	if not changed:
		return false
	return _commit(candidate)

func debug_unlock_senior_unit() -> bool:
	var candidate := profile.duplicate(true)
	var unlocked: Array = candidate.get("unlockedCharacterIds", []) as Array
	var changed := false
	for id in SENIOR_UNIT_CHARACTER_IDS:
		if not unlocked.has(id):
			unlocked.append(id)
			changed = true
	candidate["unlockedCharacterIds"] = unlocked
	if not bool(candidate.get("normalRelayCleared", false)):
		candidate["normalRelayCleared"] = true
		changed = true
	if not bool(candidate.get("seniorUnitUnlockShown", false)):
		candidate["seniorUnitUnlockShown"] = true
		changed = true
	if not changed:
		return true
	return _commit(candidate)

func consume_senior_unit_unlock_notice() -> bool:
	if not bool(profile.get("normalRelayCleared", false)) or bool(profile.get("seniorUnitUnlockShown", false)):
		return false
	var candidate := profile.duplicate(true)
	candidate["seniorUnitUnlockShown"] = true
	return _commit(candidate)

func mark_senior_unit_unlock_presented() -> bool:
	if not bool(profile.get("normalRelayCleared", false)) or bool(profile.get("seniorUnitUnlockShown", false)):
		return true
	var candidate := profile.duplicate(true)
	candidate["seniorUnitUnlockShown"] = true
	return _commit(candidate)

func create_snapshot(enabled: bool):
	return PowerUpEffectProviderScript.create_snapshot(profile, database, enabled)

func purchase_upgrade(id: String) -> int:
	if busy:
		purchase_failed.emit(Result.BUSY)
		return Result.BUSY
	if not is_unlocked():
		purchase_failed.emit(Result.LOCKED)
		return Result.LOCKED
	var upgrade: Dictionary = database.get_upgrade(id) as Dictionary
	if upgrade.is_empty():
		purchase_failed.emit(Result.INVALID_ID)
		return Result.INVALID_ID
	var old_level := get_upgrade_level(id)
	var max_level := int(upgrade.get("maxLevel", 5))
	if old_level >= max_level:
		purchase_failed.emit(Result.MAX_LEVEL)
		return Result.MAX_LEVEL
	var prices: Array = upgrade.get("prices", []) as Array
	var price := int(prices[old_level]) if old_level < prices.size() else -1
	if price < 0:
		purchase_failed.emit(Result.INVALID_ID)
		return Result.INVALID_ID
	if current_points() < price:
		purchase_failed.emit(Result.NOT_ENOUGH_POINTS)
		return Result.NOT_ENOUGH_POINTS
	busy = true
	var candidate := profile.duplicate(true)
	var levels: Dictionary = candidate.get("upgrades", {}) as Dictionary
	levels[id] = old_level + 1
	candidate["upgrades"] = levels
	candidate["currentPoints"] = current_points() - price
	candidate["totalSpentPoints"] = maxi(0, int(candidate.get("totalSpentPoints", 0)) + price)
	if not _commit(candidate):
		busy = false
		purchase_failed.emit(Result.SAVE_FAILED)
		return Result.SAVE_FAILED
	busy = false
	emit_signal("points_changed", current_points() + price, current_points())
	upgrade_purchased.emit(id, old_level + 1, price)
	return Result.SUCCESS

func calculate_refund_points() -> int:
	var total := 0
	var levels: Dictionary = profile.get("upgrades", {}) as Dictionary
	for id in levels.keys():
		var upgrade: Dictionary = database.get_upgrade(String(id)) as Dictionary
		var prices: Array = upgrade.get("prices", []) as Array
		for index in range(mini(int(levels[id]), prices.size())):
			total += int(prices[index])
	return total

func reset_all_upgrades() -> int:
	if busy:
		purchase_failed.emit(Result.BUSY)
		return Result.BUSY
	var refund := calculate_refund_points()
	if refund <= 0:
		return Result.NOTHING_TO_RESET
	busy = true
	var candidate := profile.duplicate(true)
	var levels: Dictionary = candidate.get("upgrades", {}) as Dictionary
	for id in levels.keys():
		levels[id] = 0
	candidate["upgrades"] = levels
	candidate["currentPoints"] = current_points() + refund
	candidate["totalSpentPoints"] = 0
	if not _commit(candidate):
		busy = false
		purchase_failed.emit(Result.SAVE_FAILED)
		return Result.SAVE_FAILED
	busy = false
	upgrades_reset.emit(refund)
	return Result.SUCCESS

func grant_reward(run_id: String, reward, senior_unit_unlock_eligible: bool = false) -> Dictionary:
	if busy:
		return {"ok": false, "state": "busy", "totalPp": 0}
	if run_id.strip_edges() == "":
		return {"ok": false, "state": "invalid_run_id", "totalPp": 0}
	var rewarded_runs: Array = profile.get("rewardedRunIds", []) as Array
	if rewarded_runs.has(run_id):
		return {"ok": true, "state": "already_granted", "totalPp": 0, "balance": current_points()}
	busy = true
	var candidate := profile.duplicate(true)
	var before_unlocked := bool(candidate.get("unlocked", false))
	var before_senior_unlocked := bool(candidate.get("normalRelayCleared", false))
	var reward_keys: Array = candidate.get("rewardedRewardKeys", []) as Array
	var original_boss_defeat_pp := int(reward.boss_defeat_pp)
	var duplicate_boss_points := 0
	for entry in reward.boss_reward_entries:
		var boss_entry: Dictionary = entry as Dictionary
		var boss_key := String(boss_entry.get("rewardKey", ""))
		if boss_key != "" and reward_keys.has(boss_key):
			duplicate_boss_points += int(boss_entry.get("basePpReward", 0))
	var duplicate_first_stage := 0
	for stage_id in reward.newly_cleared_stage_ids:
		if reward_keys.has("first_stage:" + stage_id):
			duplicate_first_stage += floori(float(reward.first_stage_clear_pp) / float(maxi(1, reward.newly_cleared_stage_ids.size())))
	var duplicate_first_boss := 0
	for boss_id in reward.newly_defeated_boss_ids:
		if reward_keys.has("first:" + boss_id):
			duplicate_first_boss += floori(float(reward.first_boss_defeat_pp) / float(maxi(1, reward.newly_defeated_boss_ids.size())))
	var duplicate_first_relay := 0
	if reward.grants_first_relay_clear and reward_keys.has("first:relay"):
		duplicate_first_relay = int(reward.first_relay_clear_pp)
	reward.boss_defeat_pp = maxi(0, original_boss_defeat_pp - duplicate_boss_points)
	reward.first_stage_clear_pp = maxi(0, int(reward.first_stage_clear_pp) - duplicate_first_stage)
	reward.first_boss_defeat_pp = maxi(0, int(reward.first_boss_defeat_pp) - duplicate_first_boss)
	reward.first_relay_clear_pp = maxi(0, int(reward.first_relay_clear_pp) - duplicate_first_relay)
	# Rebuild every dependent subtotal after duplicate removal.  In v2 the
	# evaluation bonus is based on the adjusted remainder, so subtracting only
	# the old repeatable subtotal would leave an overpayment.
	StreamPointRewardCalculatorScript.recalculate_totals(reward)
	var points := int(reward.total_pp)
	for key in reward.reward_keys:
		if reward_keys.has(key):
			continue
		reward_keys.append(key)
	candidate["rewardedRewardKeys"] = reward_keys
	candidate["currentPoints"] = maxi(0, int(candidate.get("currentPoints", 0)) + points)
	candidate["totalEarnedPoints"] = maxi(0, int(candidate.get("totalEarnedPoints", 0)) + points)
	rewarded_runs.append(run_id)
	while rewarded_runs.size() > PowerUpSaveStoreScript.MAX_REWARDED_RUN_IDS:
		rewarded_runs.pop_front()
	candidate["rewardedRunIds"] = rewarded_runs
	if reward.total_pp > 0 or reward.first_stage_clear_pp > 0 or reward.first_boss_defeat_pp > 0 or reward.first_relay_clear_pp > 0:
		candidate["unlocked"] = true
	var stage_flags: Dictionary = candidate.get("firstStageClears", {}) as Dictionary
	for stage_id in reward.newly_cleared_stage_ids:
		stage_flags[stage_id] = true
	candidate["firstStageClears"] = stage_flags
	var boss_flags: Dictionary = candidate.get("firstBossDefeats", {}) as Dictionary
	for boss_id in reward.newly_defeated_boss_ids:
		boss_flags[boss_id] = true
	candidate["firstBossDefeats"] = boss_flags
	if reward.grants_first_relay_clear:
		candidate["firstRelayClear"] = true
	if senior_unit_unlock_eligible:
		candidate["normalRelayCleared"] = true
		var unlocked_character_ids: Array = candidate.get("unlockedCharacterIds", []) as Array
		for character_id in SENIOR_UNIT_CHARACTER_IDS:
			if not unlocked_character_ids.has(character_id):
				unlocked_character_ids.append(character_id)
		candidate["unlockedCharacterIds"] = unlocked_character_ids
	if not _commit(candidate):
		busy = false
		return {"ok": false, "state": "save_failed", "totalPp": 0}
	busy = false
	if not before_unlocked and bool(profile.get("unlocked", false)):
		shop_unlocked.emit()
	reward_granted.emit(run_id, points)
	return {"ok": true, "state": "granted", "totalPp": points, "balance": current_points(), "seniorUnitUnlocked": senior_unit_unlock_eligible and not before_senior_unlocked}

func _commit(candidate: Dictionary) -> bool:
	var normalized: Dictionary = store.normalize(candidate, database) as Dictionary
	if not store.save_data(normalized, database):
		return false
	var previous := profile
	profile = normalized
	return previous != profile
