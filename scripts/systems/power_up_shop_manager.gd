class_name PowerUpShopManager
extends RefCounted

const PowerUpDatabaseScript := preload("res://scripts/systems/power_up_database.gd")
const PowerUpSaveStoreScript := preload("res://scripts/systems/power_up_save_store.gd")
const PowerUpEffectProviderScript := preload("res://scripts/systems/power_up_effect_provider.gd")
const StreamPointRewardCalculatorScript := preload("res://scripts/systems/stream_point_reward_calculator.gd")
const StreamPointRewardResultScript := preload("res://scripts/systems/stream_point_reward_result.gd")
const StreamMissionSystemScript := preload("res://scripts/systems/stream_mission_system.gd")
const CodexRewardSystemScript := preload("res://scripts/systems/codex_reward_system.gd")
const CustomizationDatabaseScript := preload("res://scripts/systems/customization_database.gd")
const CustomizationProviderScript := preload("res://scripts/systems/customization_provider.gd")

signal points_changed(previous_value: int, new_value: int)
signal upgrade_purchased(upgrade_id: String, new_level: int, price: int)
signal upgrades_reset(refunded_points: int)
signal shop_unlocked
signal purchase_failed(reason: int)
signal reward_granted(run_id: String, total_pp: int)
signal stream_missions_granted(result: Dictionary)
signal codex_milestones_granted(category_id: String, claimed_ids: Array, total_pp: int)
signal customization_conditions_unlocked(condition_ids: Array)
signal customization_purchased(item_id: String, price: int)
signal customization_equipped(category: String, item_id: String)

enum Result { SUCCESS, LOCKED, BUSY, INVALID_ID, MAX_LEVEL, NOT_ENOUGH_POINTS, SAVE_FAILED, NOTHING_TO_RESET }

var database
var store
var profile: Dictionary = {}
var busy := false
var codex_reward_system
var customization_database
var _customization_notification_baseline: Array[String] = []
var _customization_notification_baseline_initialized := false
const SENIOR_UNIT_CHARACTER_IDS := ["aosumi_kyasumi", "akarine_rizumu", "shizuki_miimu"]

func _init(database_instance = null, store_instance = null, codex_reward_system_instance = null) -> void:
	database = database_instance if database_instance != null else PowerUpDatabaseScript.load_default()
	store = store_instance if store_instance != null else PowerUpSaveStoreScript.new()
	codex_reward_system = codex_reward_system_instance if codex_reward_system_instance != null else CodexRewardSystemScript.new()
	customization_database = CustomizationDatabaseScript.load_default()
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

func claimed_codex_milestone_ids() -> Array[String]:
	var result: Array[String] = []
	var stored: Variant = profile.get("claimedCodexMilestones", [])
	if not stored is Array:
		return result
	for item in stored as Array:
		var milestone_id := String(item).strip_edges()
		if milestone_id != "" and not result.has(milestone_id):
			result.append(milestone_id)
	return result

func completed_stream_mission_ids() -> Array[String]:
	return _profile_string_list("completedStreamMissions")

func completed_stage_mission_set_ids() -> Array[String]:
	return _profile_string_list("completedStageMissionSets")

func unlocked_customization_condition_ids() -> Array[String]:
	return _profile_string_list("unlockedCustomizationConditions")

func purchased_customization_ids() -> Array[String]:
	return _profile_string_list("purchasedCustomizations")

func equipped_customizations() -> Dictionary:
	var stored: Variant = profile.get("equippedCustomizations", {})
	var result := {"title": "", "theme": "", "resultStamp": ""}
	if stored is Dictionary:
		for slot in result.keys():
			result[slot] = String((stored as Dictionary).get(slot, ""))
	return result

func total_customization_spent_points() -> int:
	return maxi(0, int(profile.get("totalCustomizationSpentPoints", 0)))

func get_customization_item(id: String) -> Dictionary:
	if customization_database == null or not customization_database.is_valid:
		return {}
	return customization_database.get_item(id)

func customization_items_for_category(category: String) -> Array[Dictionary]:
	if customization_database == null or not customization_database.is_valid:
		return []
	var result: Array[Dictionary] = []
	for item in customization_database.items_for_category(category):
		if String(item.get("acquisitionType", "purchase")).strip_edges().to_lower() == "mission_reward":
			continue
		result.append(item)
	return result

func initialize_customization_notification_baseline(codex_source = null) -> void:
	var source := codex_source as Object if codex_source is Object else null
	if source == null or not source.has_method("get_discovered_count") or not source.has_method("get_total_count"):
		return
	_customization_notification_baseline = _eligible_customization_condition_ids(source)
	_customization_notification_baseline_initialized = true

func get_customization_condition_status(condition_id: String, codex_source = null) -> Dictionary:
	var id := condition_id.strip_edges()
	var condition: Dictionary = customization_database.get_condition(id) if customization_database != null and customization_database.is_valid else {}
	if condition.is_empty():
		return {"id": id, "valid": false, "unlocked": unlocked_customization_condition_ids().has(id), "eligibleNow": false, "label": "解禁条件を確認できません"}
	if String(condition.get("kind", "")) == "mission_reward":
		var completed := completed_stream_mission_ids()
		var total := StreamMissionSystemScript.EXPECTED_MISSION_IDS.size()
		var found := 0
		for mission_id in StreamMissionSystemScript.EXPECTED_MISSION_IDS:
			if completed.has(mission_id):
				found += 1
		var complete := total > 0 and found >= total
		return {
			"id": id,
			"valid": true,
			"kind": "mission_reward",
			"category": "",
			"percent": 100,
			"required": total,
			"found": found,
			"total": total,
			"unlocked": unlocked_customization_condition_ids().has(id) or complete,
			"eligibleNow": complete,
			"completedOnce": complete,
			"label": String(condition.get("displayName", id)),
			"progressText": "配信目標 %d / %d" % [found, total]
		}
	var source := codex_source as Object if codex_source is Object else null
	var progress := _customization_condition_progress(condition, source)
	var eligible_now := _customization_condition_is_eligible(condition, source)
	var unlocked := unlocked_customization_condition_ids().has(id)
	var percent := int(condition.get("percent", 100))
	var required := int(progress.get("required", 0))
	var label := String(condition.get("displayName", id))
	if String(condition.get("kind", "")) == "collection":
		label = "配信図鑑 COLLECTION %d / %dで解禁" % [required, int(progress.get("total", 0))]
	elif String(condition.get("kind", "")) == "category":
		label = "%s %d / %d (100%%)で解禁" % [CustomizationProviderScript.category_label_from_codex(String(condition.get("category", ""))), required, int(progress.get("total", 0))]
	return {
		"id": id,
		"valid": true,
		"kind": String(condition.get("kind", "")),
		"category": String(condition.get("category", "")),
		"percent": percent,
		"required": required,
		"found": int(progress.get("found", 0)),
		"total": int(progress.get("total", 0)),
		"unlocked": unlocked,
		"eligibleNow": eligible_now,
		"completedOnce": bool(progress.get("completedOnce", false)),
		"label": label,
		"progressText": String(progress.get("text", condition.get("displayName", id)))
	}

func sync_customization_unlocks(codex_source = null) -> Dictionary:
	var empty_result := {"ok": false, "state": "master_invalid", "newlyUnlockedConditionIds": [], "newlyEligibleConditionIds": [], "unlockedConditionIds": unlocked_customization_condition_ids()}
	if busy:
		empty_result["state"] = "busy"
		return empty_result
	if customization_database == null or not customization_database.is_valid:
		return empty_result
	var source := codex_source as Object if codex_source is Object else null
	if source == null or not source.has_method("get_discovered_count") or not source.has_method("get_total_count"):
		empty_result["state"] = "invalid_source"
		return empty_result
	var stored := unlocked_customization_condition_ids()
	var eligible := _eligible_customization_condition_ids(source)
	var previous_eligible := _customization_notification_baseline.duplicate()
	var baseline_was_initialized := _customization_notification_baseline_initialized
	var newly_eligible: Array[String] = []
	if baseline_was_initialized:
		for condition_id in eligible:
			if not previous_eligible.has(condition_id):
				newly_eligible.append(condition_id)
	var additions: Array[String] = []
	for condition_id in eligible:
		if not stored.has(condition_id):
			stored.append(condition_id)
			additions.append(condition_id)
	if additions.is_empty():
		_customization_notification_baseline = eligible.duplicate()
		_customization_notification_baseline_initialized = true
		return {"ok": true, "state": "already_synchronized", "newlyUnlockedConditionIds": [], "newlyEligibleConditionIds": [], "unlockedConditionIds": stored.duplicate()}
	var newly_eligible_unlocked: Array[String] = []
	for condition_id in newly_eligible:
		if additions.has(condition_id):
			newly_eligible_unlocked.append(condition_id)
	var candidate := profile.duplicate(true)
	candidate["unlockedCustomizationConditions"] = stored
	busy = true
	if not _commit(candidate):
		busy = false
		return {"ok": false, "state": "save_failed", "newlyUnlockedConditionIds": [], "newlyEligibleConditionIds": [], "unlockedConditionIds": unlocked_customization_condition_ids()}
	busy = false
	_customization_notification_baseline = eligible.duplicate()
	_customization_notification_baseline_initialized = true
	customization_conditions_unlocked.emit(additions.duplicate())
	return {"ok": true, "state": "synchronized", "newlyUnlockedConditionIds": additions.duplicate(), "newlyEligibleConditionIds": newly_eligible_unlocked.duplicate(), "unlockedConditionIds": unlocked_customization_condition_ids()}

func customization_shop_gate_status(codex_source = null) -> Dictionary:
	var gate := get_customization_condition_status("collection:25", codex_source)
	return {
		"shopUnlocked": is_unlocked(),
		"conditionUnlocked": bool(gate.get("unlocked", false)),
		"condition": gate,
		"viewable": is_available()
	}

func get_customization_status(id: String, codex_source = null) -> Dictionary:
	var item := get_customization_item(id)
	if item.is_empty():
		return {"id": id, "state": "INVALID", "valid": false, "canPurchase": false}
	var category := String(item.get("category", ""))
	var slot := CustomizationProviderScript.category_slot(category)
	var condition_id := String(item.get("unlockConditionId", ""))
	var condition_unlocked := unlocked_customization_condition_ids().has(condition_id)
	var collection_gate_unlocked := unlocked_customization_condition_ids().has("collection:25")
	var purchased := purchased_customization_ids().has(id)
	var equipped := String(equipped_customizations().get(slot, "")) == id
	var shop_unlocked := is_unlocked()
	var price := maxi(0, int(item.get("pricePp", 0)))
	var acquisition_type := String(item.get("acquisitionType", "purchase")).strip_edges().to_lower()
	var state := "AVAILABLE"
	var locked_reason := ""
	if acquisition_type == "mission_reward":
		condition_unlocked = bool(get_customization_condition_status(condition_id, codex_source).get("unlocked", false))
		if equipped:
			state = "EQUIPPED"
		elif purchased:
			state = "OWNED"
		else:
			state = "LOCKED"
			locked_reason = "mission_reward"
	elif not shop_unlocked:
		state = "LOCKED"
		locked_reason = "shop_locked"
	elif not collection_gate_unlocked:
		state = "LOCKED"
		locked_reason = "collection_gate"
	elif not condition_unlocked:
		state = "LOCKED"
		locked_reason = "condition_locked"
	elif equipped:
		state = "EQUIPPED"
	elif purchased:
		state = "OWNED"
	var can_purchase := acquisition_type != "mission_reward" and state == "AVAILABLE" and current_points() >= price
	return {
		"id": id,
		"valid": true,
		"category": category,
		"displayName": String(item.get("displayName", id)),
		"description": String(item.get("description", "")),
		"presentationId": String(item.get("presentationId", id)),
		"unlockConditionId": condition_id,
		"price": price,
		"acquisitionType": acquisition_type,
		"state": state,
		"lockedReason": locked_reason,
		"conditionUnlocked": condition_unlocked,
		"collectionGateUnlocked": collection_gate_unlocked,
		"condition": get_customization_condition_status(condition_id, codex_source),
		"purchased": purchased,
		"equipped": equipped,
		"shopUnlocked": shop_unlocked,
		"canPurchase": can_purchase,
		"insufficientPoints": state == "AVAILABLE" and current_points() < price,
		"shortage": maxi(0, price - current_points())
	}

func purchase_customization(id: String) -> int:
	var item := get_customization_item(id)
	if item.is_empty():
		purchase_failed.emit(Result.INVALID_ID)
		return Result.INVALID_ID
	if String(item.get("acquisitionType", "purchase")).strip_edges().to_lower() == "mission_reward":
		purchase_failed.emit(Result.INVALID_ID)
		return Result.INVALID_ID
	if busy:
		purchase_failed.emit(Result.BUSY)
		return Result.BUSY
	if not is_unlocked():
		purchase_failed.emit(Result.LOCKED)
		return Result.LOCKED
	var normalized_id := String(item.get("id", ""))
	var unlocked_conditions := unlocked_customization_condition_ids()
	if not unlocked_conditions.has("collection:25"):
		purchase_failed.emit(Result.LOCKED)
		return Result.LOCKED
	if not unlocked_conditions.has(String(item.get("unlockConditionId", ""))):
		purchase_failed.emit(Result.LOCKED)
		return Result.LOCKED
	var purchased := purchased_customization_ids()
	if purchased.has(normalized_id):
		purchase_failed.emit(Result.INVALID_ID)
		return Result.INVALID_ID
	var price := maxi(0, int(item.get("pricePp", -1)))
	if price < 0:
		purchase_failed.emit(Result.INVALID_ID)
		return Result.INVALID_ID
	var before_balance := current_points()
	if before_balance < price:
		purchase_failed.emit(Result.NOT_ENOUGH_POINTS)
		return Result.NOT_ENOUGH_POINTS
	purchased.append(normalized_id)
	var candidate := profile.duplicate(true)
	candidate["purchasedCustomizations"] = purchased
	candidate["currentPoints"] = before_balance - price
	candidate["totalCustomizationSpentPoints"] = total_customization_spent_points() + price
	busy = true
	if not _commit(candidate):
		busy = false
		purchase_failed.emit(Result.SAVE_FAILED)
		return Result.SAVE_FAILED
	busy = false
	points_changed.emit(before_balance, current_points())
	customization_purchased.emit(normalized_id, price)
	return Result.SUCCESS

func equip_customization(category: String, id: String) -> int:
	var normalized_category := category.strip_edges().to_lower()
	if not ["title", "theme", "result_stamp"].has(normalized_category):
		return Result.INVALID_ID
	var slot := CustomizationProviderScript.category_slot(normalized_category)
	var current_id := String(equipped_customizations().get(slot, ""))
	var normalized_id := id.strip_edges()
	if normalized_id != "":
		var item := get_customization_item(normalized_id)
		if item.is_empty() or String(item.get("category", "")) != normalized_category:
			return Result.INVALID_ID
		if not purchased_customization_ids().has(normalized_id):
			return Result.LOCKED
	if current_id == normalized_id:
		return Result.SUCCESS
	if busy:
		return Result.BUSY
	var candidate := profile.duplicate(true)
	var equipped := equipped_customizations()
	equipped[slot] = normalized_id
	candidate["equippedCustomizations"] = equipped
	busy = true
	if not _commit(candidate):
		busy = false
		return Result.SAVE_FAILED
	busy = false
	customization_equipped.emit(normalized_category, normalized_id)
	return Result.SUCCESS

func equipped_customization_display_name(category: String) -> String:
	var normalized_category := category.strip_edges().to_lower()
	var slot := CustomizationProviderScript.category_slot(normalized_category)
	var id := String(equipped_customizations().get(slot, ""))
	if id == "":
		return ""
	var item := get_customization_item(id)
	return String(item.get("displayName", "")) if String(item.get("category", "")) == normalized_category else ""

func _profile_string_list(key: String) -> Array[String]:
	var result: Array[String] = []
	var stored: Variant = profile.get(key, [])
	if not stored is Array:
		return result
	for value in stored as Array:
		var id := String(value).strip_edges()
		if id != "" and not result.has(id):
			result.append(id)
	return result

func _eligible_customization_condition_ids(source: Object) -> Array[String]:
	var result: Array[String] = []
	if customization_database == null or not customization_database.is_valid:
		return result
	for condition_id in customization_database.condition_ids():
		var condition: Dictionary = customization_database.get_condition(condition_id)
		if _customization_condition_is_eligible(condition, source):
			result.append(condition_id)
	return result

func _customization_condition_is_eligible(condition: Dictionary, source: Object) -> bool:
	if source == null:
		return false
	var kind := String(condition.get("kind", ""))
	if kind == "collection":
		if source.has_method("collection_completed_once") and bool(source.call("collection_completed_once")):
			return true
		var progress := _customization_condition_progress(condition, source)
		return int(progress.get("total", 0)) > 0 and int(progress.get("found", 0)) >= int(progress.get("required", 0))
	if kind == "category":
		var category := String(condition.get("category", ""))
		if source.has_method("category_completed_once") and bool(source.call("category_completed_once", category)):
			return true
		var total := maxi(0, int(source.call("get_total_count", category)))
		var found := maxi(0, int(source.call("get_discovered_count", category)))
		var percent := int(condition.get("percent", 100))
		var required := ceili(float(total) * float(percent) / 100.0)
		return total > 0 and found >= required
	return false

func _customization_condition_progress(condition: Dictionary, source: Object) -> Dictionary:
	if source == null or not source.has_method("get_discovered_count") or not source.has_method("get_total_count"):
		return {"found": 0, "total": 0, "required": 0, "completedOnce": false, "text": String(condition.get("displayName", ""))}
	var kind := String(condition.get("kind", ""))
	if kind == "collection":
		var found := 0
		var total := 0
		for category in ["characters", "weapons", "accessories", "enemies"]:
			found += maxi(0, int(source.call("get_discovered_count", category)))
			total += maxi(0, int(source.call("get_total_count", category)))
		var completed_once := source.has_method("collection_completed_once") and bool(source.call("collection_completed_once"))
		var percent := int(condition.get("percent", 100))
		var required := ceili(float(total) * float(percent) / 100.0) if total > 0 else 0
		return {"found": found, "total": total, "required": required, "completedOnce": completed_once, "text": "COLLECTION %d / %d" % [found, total]}
	if kind == "category":
		var category := String(condition.get("category", ""))
		var category_found := maxi(0, int(source.call("get_discovered_count", category)))
		var category_total := maxi(0, int(source.call("get_total_count", category)))
		var category_once := source.has_method("category_completed_once") and bool(source.call("category_completed_once", category))
		var category_percent := int(condition.get("percent", 100))
		var category_required := ceili(float(category_total) * float(category_percent) / 100.0) if category_total > 0 else 0
		return {"found": category_found, "total": category_total, "required": category_required, "completedOnce": category_once, "text": "%s %d / %d" % [CustomizationProviderScript.category_label_from_codex(category), category_found, category_total]}
	return {"found": 0, "total": 0, "required": 0, "completedOnce": false, "text": String(condition.get("displayName", ""))}

func get_codex_category_reward_status(category_id: String, codex_source = null) -> Dictionary:
	var category := category_id.strip_edges().to_lower()
	if codex_reward_system == null or not codex_reward_system.is_valid():
		return _codex_invalid_status(category, "master_invalid")
	var source := codex_source as Object if codex_source is Object else null
	if source == null or not source.has_method("get_total_count") or not source.has_method("get_discovered_count"):
		return _codex_invalid_status(category, "invalid_source")
	var total := maxi(0, int(source.call("get_total_count", category)))
	var found := maxi(0, int(source.call("get_discovered_count", category)))
	return codex_reward_system.category_status(category, found, total, claimed_codex_milestone_ids(), is_unlocked())

func get_codex_milestone_crossings(category_id: String, previous_found: int, current_found: int, total: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if codex_reward_system == null or not codex_reward_system.is_valid():
		return result
	var claimed := claimed_codex_milestone_ids()
	for milestone in codex_reward_system.crossed_milestones(category_id, previous_found, current_found, total):
		var milestone_id := String(milestone.get("id", ""))
		if milestone_id != "" and not claimed.has(milestone_id):
			result.append(milestone.duplicate(true))
	return result

func grant_codex_milestone_rewards(category_id: String, codex_source = null) -> Dictionary:
	var category := category_id.strip_edges().to_lower()
	if busy:
		return {"ok": false, "state": "busy", "categoryId": category, "claimedIds": [], "totalPp": 0}
	if codex_reward_system == null or not codex_reward_system.is_valid():
		return {"ok": false, "state": "master_invalid", "categoryId": category, "claimedIds": [], "totalPp": 0}
	var source := codex_source as Object if codex_source is Object else null
	if source == null or not source.has_method("get_total_count") or not source.has_method("get_discovered_count"):
		return {"ok": false, "state": "invalid_source", "categoryId": category, "claimedIds": [], "totalPp": 0}
	var status := get_codex_category_reward_status(category, source)
	if not bool(status.get("ok", false)):
		return {"ok": false, "state": String(status.get("blockedReason", "invalid_category")), "categoryId": category, "claimedIds": [], "totalPp": 0}
	if not is_unlocked():
		return {"ok": false, "state": "shop_locked", "categoryId": category, "claimedIds": [], "totalPp": 0}
	var claimable_ids: Array = status.get("claimableIds", []) as Array
	var total_pp := int(status.get("claimablePp", 0))
	if claimable_ids.is_empty():
		return {"ok": true, "state": "nothing_to_claim", "categoryId": category, "claimedIds": [], "totalPp": 0, "balance": current_points()}
	var before_balance := current_points()
	var candidate := profile.duplicate(true)
	var claimed := claimed_codex_milestone_ids()
	for milestone_id_value in claimable_ids:
		var milestone_id := String(milestone_id_value)
		if not claimed.has(milestone_id):
			claimed.append(milestone_id)
	candidate["claimedCodexMilestones"] = claimed
	candidate["currentPoints"] = maxi(0, int(candidate.get("currentPoints", 0)) + total_pp)
	candidate["totalEarnedPoints"] = maxi(0, int(candidate.get("totalEarnedPoints", 0)) + total_pp)
	busy = true
	if not _commit(candidate):
		busy = false
		return {"ok": false, "state": "save_failed", "categoryId": category, "claimedIds": claimable_ids.duplicate(), "totalPp": 0, "requestedPp": total_pp, "beforeBalance": before_balance, "balance": current_points()}
	busy = false
	var new_balance := current_points()
	points_changed.emit(before_balance, new_balance)
	codex_milestones_granted.emit(category, claimable_ids.duplicate(), total_pp)
	return {"ok": true, "state": "granted", "categoryId": category, "claimedIds": claimable_ids.duplicate(), "totalPp": total_pp, "beforeBalance": before_balance, "balance": new_balance}

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
	return grant_reward_with_stream_missions(run_id, reward, senior_unit_unlock_eligible, {})

func grant_reward_with_stream_missions(run_id: String, reward, senior_unit_unlock_eligible: bool = false, mission_context: Dictionary = {}) -> Dictionary:
	if busy:
		return {"ok": false, "state": "busy", "totalPp": 0}
	if run_id.strip_edges() == "":
		return {"ok": false, "state": "invalid_run_id", "totalPp": 0}
	var pristine_reward = _clone_stream_reward(reward)
	if pristine_reward == null:
		return {"ok": false, "state": "invalid_reward", "totalPp": 0}
	# Keep mutable reward history isolated until _commit successfully saves it.
	var candidate := profile.duplicate(true)
	var rewarded_runs: Array = candidate.get("rewardedRunIds", []) as Array
	if rewarded_runs.has(run_id):
		return {"ok": true, "state": "already_granted", "totalPp": 0, "balance": current_points(), "streamMissionResult": _empty_stream_mission_result()}
	busy = true
	var before_unlocked := bool(candidate.get("unlocked", false))
	var before_senior_unlocked := bool(candidate.get("normalRelayCleared", false))
	var reward_keys: Array = candidate.get("rewardedRewardKeys", []) as Array
	var adjusted_reward = pristine_reward
	var original_boss_defeat_pp := int(adjusted_reward.boss_defeat_pp)
	var duplicate_boss_points := 0
	for entry in adjusted_reward.boss_reward_entries:
		var boss_entry: Dictionary = entry as Dictionary
		var boss_key := String(boss_entry.get("rewardKey", ""))
		if boss_key != "" and reward_keys.has(boss_key):
			duplicate_boss_points += int(boss_entry.get("basePpReward", 0))
	var duplicate_first_stage := 0
	for stage_id in adjusted_reward.newly_cleared_stage_ids:
		if reward_keys.has("first_stage:" + stage_id):
			duplicate_first_stage += floori(float(adjusted_reward.first_stage_clear_pp) / float(maxi(1, adjusted_reward.newly_cleared_stage_ids.size())))
	var duplicate_first_boss := 0
	for boss_id in adjusted_reward.newly_defeated_boss_ids:
		if reward_keys.has("first:" + boss_id):
			duplicate_first_boss += floori(float(adjusted_reward.first_boss_defeat_pp) / float(maxi(1, adjusted_reward.newly_defeated_boss_ids.size())))
	var duplicate_first_relay := 0
	if adjusted_reward.grants_first_relay_clear and reward_keys.has("first:relay"):
		duplicate_first_relay = int(adjusted_reward.first_relay_clear_pp)
	adjusted_reward.boss_defeat_pp = maxi(0, original_boss_defeat_pp - duplicate_boss_points)
	adjusted_reward.first_stage_clear_pp = maxi(0, int(adjusted_reward.first_stage_clear_pp) - duplicate_first_stage)
	adjusted_reward.first_boss_defeat_pp = maxi(0, int(adjusted_reward.first_boss_defeat_pp) - duplicate_first_boss)
	adjusted_reward.first_relay_clear_pp = maxi(0, int(adjusted_reward.first_relay_clear_pp) - duplicate_first_relay)
	# Rebuild every dependent subtotal after duplicate removal.  In v2 the
	# evaluation bonus is based on the adjusted remainder, so subtracting only
	# the old repeatable subtotal would leave an overpayment.
	StreamPointRewardCalculatorScript.recalculate_totals(adjusted_reward)
	var mission_result := _evaluate_stream_missions(mission_context, candidate)
	var mission_pp := maxi(0, int(mission_result.get("missionPp", 0)))
	var set_pp := maxi(0, int(mission_result.get("setPp", 0)))
	var points := int(adjusted_reward.total_pp) + mission_pp + set_pp
	var before_balance := int(candidate.get("currentPoints", current_points()))
	for key in adjusted_reward.reward_keys:
		if reward_keys.has(key):
			continue
		reward_keys.append(key)
	candidate["rewardedRewardKeys"] = reward_keys
	candidate["currentPoints"] = maxi(0, before_balance + points)
	candidate["totalEarnedPoints"] = maxi(0, int(candidate.get("totalEarnedPoints", 0)) + points)
	if not mission_result.is_empty():
		candidate["completedStreamMissions"] = (mission_result.get("completedStreamMissions", []) as Array).duplicate()
		candidate["completedStageMissionSets"] = (mission_result.get("completedStageMissionSets", []) as Array).duplicate()
		if bool(mission_result.get("allMissionsComplete", false)):
			var mission_conditions: Array = candidate.get("unlockedCustomizationConditions", []) as Array
			if not mission_conditions.has("stream_missions:all"):
				mission_conditions.append("stream_missions:all")
			candidate["unlockedCustomizationConditions"] = mission_conditions
			var purchased_customizations: Array = candidate.get("purchasedCustomizations", []) as Array
			if not purchased_customizations.has("title_perfect_streamer"):
				purchased_customizations.append("title_perfect_streamer")
			candidate["purchasedCustomizations"] = purchased_customizations
	rewarded_runs.append(run_id)
	while rewarded_runs.size() > PowerUpSaveStoreScript.MAX_REWARDED_RUN_IDS:
		rewarded_runs.pop_front()
	candidate["rewardedRunIds"] = rewarded_runs
	if points > 0:
		candidate["unlocked"] = true
	var stage_flags: Dictionary = candidate.get("firstStageClears", {}) as Dictionary
	for stage_id in adjusted_reward.newly_cleared_stage_ids:
		stage_flags[stage_id] = true
	candidate["firstStageClears"] = stage_flags
	var boss_flags: Dictionary = candidate.get("firstBossDefeats", {}) as Dictionary
	for boss_id in adjusted_reward.newly_defeated_boss_ids:
		boss_flags[boss_id] = true
	candidate["firstBossDefeats"] = boss_flags
	if adjusted_reward.grants_first_relay_clear:
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
		return {"ok": false, "state": "save_failed", "totalPp": 0, "beforeBalance": before_balance, "balance": current_points(), "reward": adjusted_reward, "streamMissionResult": mission_result}
	busy = false
	if not before_unlocked and bool(profile.get("unlocked", false)):
		shop_unlocked.emit()
	reward_granted.emit(run_id, points)
	if not (mission_result.get("newMissionIds", []) as Array).is_empty() or not (mission_result.get("newSetIds", []) as Array).is_empty():
		stream_missions_granted.emit(mission_result.duplicate(true))
	return {"ok": true, "state": "granted", "totalPp": points, "balance": current_points(), "beforeBalance": before_balance, "reward": adjusted_reward, "streamMissionResult": mission_result, "seniorUnitUnlocked": senior_unit_unlock_eligible and not before_senior_unlocked}

func _clone_stream_reward(reward):
	if reward == null:
		return null
	if reward is Object and (reward as Object).has_method("to_dictionary"):
		return StreamPointRewardResultScript.from_dictionary(reward.to_dictionary())
	if reward is Dictionary:
		return StreamPointRewardResultScript.from_dictionary((reward as Dictionary).duplicate(true))
	return null

func _empty_stream_mission_result() -> Dictionary:
	return {
		"newMissionIds": [],
		"newSetIds": [],
		"completedStreamMissions": completed_stream_mission_ids(),
		"completedStageMissionSets": completed_stage_mission_set_ids(),
		"allMissionsComplete": false,
		"missionPp": 0,
		"setPp": 0,
		"stageProgress": {}
	}

func _evaluate_stream_missions(mission_context: Dictionary, candidate: Dictionary) -> Dictionary:
	var snapshot: Variant = mission_context.get("snapshot", {})
	if not snapshot is Dictionary or (snapshot as Dictionary).is_empty():
		return _empty_stream_mission_result()
	return StreamMissionSystemScript.load_default().evaluate_new(
		(snapshot as Dictionary).duplicate(true),
		(candidate.get("completedStreamMissions", []) as Array).duplicate(),
		(candidate.get("completedStageMissionSets", []) as Array).duplicate()
	)

func _codex_invalid_status(category: String, reason: String) -> Dictionary:
	return {
		"ok": false,
		"categoryId": category,
		"found": 0,
		"total": 0,
		"displayPercent": 0,
		"milestones": [],
		"eligibleIds": [],
		"eligiblePp": 0,
		"claimableIds": [],
		"claimablePp": 0,
		"nextMilestone": {},
		"allClaimed": false,
		"currentComplete": false,
		"shopUnlocked": is_unlocked(),
		"claimEnabled": false,
		"blockedReason": reason
	}

func _commit(candidate: Dictionary) -> bool:
	var normalized: Dictionary = store.normalize(candidate, database) as Dictionary
	if not store.save_data(normalized, database):
		return false
	var previous := profile
	profile = normalized
	return previous != profile
