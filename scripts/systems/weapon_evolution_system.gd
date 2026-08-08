class_name WeaponEvolutionSystem
extends RefCounted

const REQUIRED_WEAPON_LEVEL := 5
const REQUIRED_EXP_LEVEL := 0


static func evolution_gifts_for_target(target: Node, weapon_data: Array) -> Array:
	var result: Array = []
	for state_value in evolution_states_for_target(target, weapon_data):
		var state: Dictionary = state_value as Dictionary
		if not bool(state.get("canEvolve", false)):
			continue
		result.append(_evolution_gift_from_state(state))
	return result


static func evolution_gift_for_target(target: Node, weapon_data: Array) -> Dictionary:
	var gifts: Array = evolution_gifts_for_target(target, weapon_data)
	return gifts[0] as Dictionary if not gifts.is_empty() else {}


static func evolution_states_for_target(target: Node, weapon_data: Array) -> Array:
	var result: Array = []
	var weapons_value: Variant = target.get("player_weapons")
	if not weapons_value is Array:
		return result
	var player_weapons: Array = weapons_value as Array
	var seen_base_ids: Dictionary = {}
	for slot_index in range(player_weapons.size()):
		var entry_value: Variant = player_weapons[slot_index]
		if not entry_value is Dictionary:
			continue
		var entry: Dictionary = entry_value as Dictionary
		var base_id := String(entry.get("id", ""))
		if base_id == "" or bool(seen_base_ids.get(base_id, false)):
			continue
		seen_base_ids[base_id] = true
		var state := _evolution_state_for_entry(target, weapon_data, player_weapons, entry, slot_index)
		if not state.is_empty():
			result.append(state)
	return result


static func evolution_state_for_target(target: Node, weapon_data: Array) -> Dictionary:
	var states: Array = evolution_states_for_target(target, weapon_data)
	return states[0] as Dictionary if not states.is_empty() else {"canEvolve": false}


static func _evolution_state_for_entry(
	target: Node,
	weapon_data: Array,
	player_weapons: Array,
	entry: Dictionary,
	slot_index: int
) -> Dictionary:
	if EquipmentSystem.is_evolved_entry(entry):
		return {}
	var base_id := String(entry.get("id", ""))
	var base_weapon: Dictionary = WeaponSystem.find_weapon(weapon_data, base_id, {})
	if base_weapon.is_empty() or not EquipmentSystem.is_weapon(base_weapon):
		return {}
	if base_weapon.has("evolutionEnabled") and not bool(base_weapon.get("evolutionEnabled", false)):
		return {}
	var evolution_value: Variant = base_weapon.get("evolution", {})
	if not evolution_value is Dictionary:
		return {}
	var evolution: Dictionary = evolution_value as Dictionary
	if evolution.is_empty():
		return {}
	var evolved_id := String(evolution.get("evolvedWeaponId", ""))
	if evolved_id == "" or evolved_id == base_id:
		return {}
	var evolved_weapon: Dictionary = WeaponSystem.find_weapon(weapon_data, evolved_id, {})
	if evolved_weapon.is_empty():
		return {}
	if not EquipmentSystem.find_entry(player_weapons, evolved_id).is_empty():
		return {}
	if _has_evolved_lineage(player_weapons, weapon_data, base_id):
		return {}

	var required_weapon_level := _numeric_required_level(evolution.get("requiredWeaponLevel", REQUIRED_WEAPON_LEVEL), REQUIRED_WEAPON_LEVEL)
	if EquipmentSystem.entry_level(entry, 0) < required_weapon_level:
		return {}
	var required_exp_level := _numeric_required_level(evolution.get("requiredExpLevel", REQUIRED_EXP_LEVEL), REQUIRED_EXP_LEVEL)
	if int(target.get("exp_level")) < required_exp_level:
		return {}

	var required_character := String(evolution.get("requiredCharacterId", ""))
	var character_id := _target_character_id(target)
	var character_matches := required_character == "" or required_character == character_id
	var bypass_additional := bool(evolution.get("matchingCharacterBypassesAdditionalRequirements", false)) and required_character != "" and character_matches
	if required_character != "" and not character_matches and not bool(evolution.get("matchingCharacterBypassesAdditionalRequirements", false)):
		return {}
	var requirements_value: Variant = evolution.get("additionalRequirements", [])
	if requirements_value != null and not requirements_value is Array:
		return {}
	var additional_requirements: Array = _requirements_array(requirements_value)
	if not bypass_additional and not _additional_requirements_met(target, weapon_data, player_weapons, additional_requirements):
		return {}

	return {
		"canEvolve": true,
		"slotIndex": slot_index,
		"baseWeaponId": base_id,
		"evolvedWeaponId": evolved_id,
		"baseWeapon": base_weapon,
		"evolvedWeapon": evolved_weapon,
		"baseLevel": EquipmentSystem.entry_level(entry, 0),
		"requiredWeaponLevel": required_weapon_level,
		"requiredExpLevel": required_exp_level,
		"requiredCharacterId": required_character,
		"characterMatches": character_matches,
		"additionalRequirements": additional_requirements.duplicate(true),
		"additionalRequirementsSatisfied": bypass_additional or additional_requirements.is_empty() or _additional_requirements_met(target, weapon_data, player_weapons, additional_requirements)
	}


static func _evolution_gift_from_state(state: Dictionary) -> Dictionary:
	var base_weapon: Dictionary = state["baseWeapon"] as Dictionary
	var evolved_weapon: Dictionary = state["evolvedWeapon"] as Dictionary
	var base_id := String(state.get("baseWeaponId", ""))
	var evolved_id := String(state.get("evolvedWeaponId", ""))
	var base_name := String(base_weapon.get("displayName", base_id))
	var evolved_name := String(evolved_weapon.get("displayName", evolved_id))
	return {
		"id": "evolution_%s" % base_id,
		"displayName": evolved_name,
		"description": "%sを進化させる" % base_name,
		"rarity": "evolution",
		"equipmentType": "evolution",
		"effectType": "weapon_evolution",
		"weight": 1,
		"maxLevel": 1,
		"isEvolutionGift": true,
		"baseWeaponId": base_id,
		"evolvedWeaponId": evolved_id,
		"baseDisplayName": base_name,
		"evolvedDisplayName": evolved_name,
		"iconPath": String(evolved_weapon.get("iconPath", base_weapon.get("iconPath", "")))
	}


static func _additional_requirements_met(
	target: Node,
	weapon_data: Array,
	player_weapons: Array,
	requirements: Array
) -> bool:
	for requirement_value in requirements:
		if not requirement_value is Dictionary:
			return false
		var requirement: Dictionary = requirement_value as Dictionary
		var requirement_type := String(requirement.get("type", "")).to_lower()
		var requirement_id := String(requirement.get("id", ""))
		if requirement_id == "":
			return false
		if requirement_type == "accessory":
			var required_accessory_level := _accessory_required_level(target, requirement_id, requirement.get("requiredLevel", 1))
			if required_accessory_level < 0:
				return false
			var accessories_value: Variant = target.get("player_accessories")
			if not accessories_value is Array or EquipmentSystem.level(accessories_value as Array, requirement_id) < required_accessory_level:
				return false
		elif requirement_type == "weapon":
			var required_weapon_level := _numeric_required_level(requirement.get("requiredLevel", 1), 1)
			if required_weapon_level < 0 or not _weapon_requirement_met(player_weapons, weapon_data, requirement_id, required_weapon_level):
				return false
		else:
			return false
	return true


static func _accessory_required_level(target: Node, accessory_id: String, required_value: Variant) -> int:
	if required_value is String and String(required_value).strip_edges().to_lower() == "max":
		var gifts_value: Variant = target.get("gifts")
		if not gifts_value is Array:
			return -1
		var gift_data := _find_data_by_id(gifts_value as Array, accessory_id)
		if gift_data.is_empty():
			return -1
		var max_level := int(gift_data.get("maxLevel", 0))
		return max_level if max_level > 0 else -1
	return _numeric_required_level(required_value, 1)


static func _weapon_requirement_met(player_weapons: Array, weapon_data: Array, required_id: String, required_level: int) -> bool:
	for entry_value in player_weapons:
		if not entry_value is Dictionary:
			continue
		var entry: Dictionary = entry_value as Dictionary
		var entry_id := String(entry.get("id", ""))
		if entry_id == "":
			continue
		if entry_id == required_id:
			if EquipmentSystem.entry_level(entry, 0) >= required_level:
				return true
			continue
		if not _weapon_lineage_contains(entry_id, entry, required_id, player_weapons, weapon_data, {}):
			continue
		# An evolved material weapon represents the fully levelled source that
		# was used to create it, even though the evolved entry itself is Lv1.
		var entry_weapon := WeaponSystem.find_weapon(weapon_data, entry_id, {})
		if EquipmentSystem.is_evolved_entry(entry) or not String(entry_weapon.get("baseWeaponId", "")).is_empty():
			return true
	return false


static func _has_evolved_lineage(player_weapons: Array, weapon_data: Array, base_id: String) -> bool:
	for entry_value in player_weapons:
		if not entry_value is Dictionary:
			continue
		var entry: Dictionary = entry_value as Dictionary
		if not EquipmentSystem.is_evolved_entry(entry):
			continue
		var entry_id := String(entry.get("id", ""))
		if _weapon_lineage_contains(entry_id, entry, base_id, player_weapons, weapon_data, {}):
			return true
	return false


static func _weapon_lineage_contains(
	weapon_id: String,
	entry: Dictionary,
	required_id: String,
	player_weapons: Array,
	weapon_data: Array,
	visited: Dictionary
) -> bool:
	if weapon_id == required_id:
		return true
	if weapon_id == "" or bool(visited.get(weapon_id, false)):
		return false
	visited[weapon_id] = true
	var parent_id := String(entry.get("baseWeaponId", ""))
	if parent_id == "":
		var weapon := WeaponSystem.find_weapon(weapon_data, weapon_id, {})
		parent_id = String(weapon.get("baseWeaponId", ""))
	if parent_id == "":
		return false
	var parent_entry := EquipmentSystem.find_entry(player_weapons, parent_id)
	return _weapon_lineage_contains(parent_id, parent_entry, required_id, player_weapons, weapon_data, visited)


static func _find_data_by_id(data: Array, id: String) -> Dictionary:
	for item in data:
		if not item is Dictionary:
			continue
		var entry: Dictionary = item as Dictionary
		if String(entry.get("id", "")) == id:
			return entry
	return {}


static func _requirements_array(value: Variant) -> Array:
	if value is Array:
		return value as Array
	if value == null:
		return []
	return []


static func _numeric_required_level(value: Variant, fallback: int) -> int:
	if value is String:
		var text := String(value).strip_edges()
		if text.to_lower() == "max":
			return -1
		if text.is_valid_int():
			return int(text)
		return fallback
	if value is int or value is float:
		return int(value)
	return fallback


static func _target_character_id(target: Node) -> String:
	var current_character_id := String(target.get("current_character_id"))
	if current_character_id != "":
		return current_character_id
	var current_character_value: Variant = target.get("current_character")
	if current_character_value is Dictionary:
		var character_id := String((current_character_value as Dictionary).get("id", ""))
		if character_id != "":
			return character_id
	return ""


static func is_evolution_gift(gift: Dictionary) -> bool:
	return bool(gift.get("isEvolutionGift", false)) or bool(gift.get("isEvolution", false)) or bool(gift.get("evolution", false)) or String(gift.get("effectType", "")) == "weapon_evolution" or String(gift.get("equipmentType", "")) == "evolution"


static func apply_evolution_gift_for_target(target: Node, gift: Dictionary) -> Dictionary:
	var base_id := String(gift.get("baseWeaponId", ""))
	var evolved_id := String(gift.get("evolvedWeaponId", ""))
	var weapon_data_value: Variant = target.get("weapons")
	var weapon_data: Array = weapon_data_value as Array if weapon_data_value is Array else []
	if base_id == "" or evolved_id == "":
		return _empty_apply_result({})
	var state := _state_for_pair(target, weapon_data, base_id, evolved_id)
	if not bool(state.get("canEvolve", false)):
		return _empty_apply_result({})
	var evolved_weapon: Dictionary = state.get("evolvedWeapon", {}) as Dictionary
	var player_weapons: Array = target.get("player_weapons") as Array
	var target_index := int(state.get("slotIndex", -1))
	if target_index < 0 or target_index >= player_weapons.size():
		return _empty_apply_result({})
	var target_entry: Dictionary = player_weapons[target_index] as Dictionary
	if String(target_entry.get("id", "")) != base_id or EquipmentSystem.is_evolved_entry(target_entry):
		return _empty_apply_result({})

	var previous_level := EquipmentSystem.entry_level(target_entry, 0)
	WeaponSystem.cleanup_runtime_for_weapon(target, base_id, evolved_id, "evolution")
	player_weapons[target_index] = {
		"id": evolved_id,
		"level": 1,
		"isEvolved": true,
		"baseWeaponId": base_id,
		"evolvedAtLevel": previous_level
	}
	target.set("player_weapons", player_weapons)
	var current_weapon: Dictionary = target.get("current_weapon") as Dictionary
	if String(target.get("current_weapon_id")) == base_id or String(current_weapon.get("id", "")) == base_id:
		target.set("current_weapon_id", evolved_id)
		target.set("current_weapon", evolved_weapon)

	var timers: Dictionary = target.get("equipment_weapon_timers") as Dictionary
	timers.erase(base_id)
	timers.erase(evolved_id)
	timers.erase("__starlight_superchat_shot_count")
	timers.erase("__maro_comment_pulse_index")
	timers.erase("__maro_comment_pulse_until")
	timers.erase("__maro_comment_flash_until")
	target.set("equipment_weapon_timers", timers)

	var base_weapon: Dictionary = state.get("baseWeapon", {}) as Dictionary
	if WeaponSystem.attack_type(base_weapon) == "orbit" or WeaponSystem.attack_type(evolved_weapon) == "orbit":
		var boomerang_hits: Dictionary = target.get("boomerang_hits") as Dictionary
		boomerang_hits.clear()
		target.set("boomerang_hits", boomerang_hits)

	return _empty_apply_result({
		"weaponEvolution": {
			"baseWeaponId": base_id,
			"evolvedWeaponId": evolved_id,
			"baseDisplayName": String(gift.get("baseDisplayName", base_id)),
			"evolvedDisplayName": String(gift.get("evolvedDisplayName", evolved_weapon.get("displayName", evolved_id)))
		}
	})


static func _state_for_pair(target: Node, weapon_data: Array, base_id: String, evolved_id: String) -> Dictionary:
	for state_value in evolution_states_for_target(target, weapon_data):
		var state: Dictionary = state_value as Dictionary
		if String(state.get("baseWeaponId", "")) == base_id and String(state.get("evolvedWeaponId", "")) == evolved_id:
			return state
	return {}


static func _empty_apply_result(extra: Dictionary) -> Dictionary:
	var result: Dictionary = {
		"rollGenreEvent": false,
		"heartPendingActivated": false,
		"heartPendingDuplicate": false
	}
	for key in extra.keys():
		result[key] = extra[key]
	return result


static func _initial_weapon_id(target: Node) -> String:
	var current_character: Dictionary = target.get("current_character") as Dictionary
	var initial_weapon_id: String = String(current_character.get("initialWeapon", ""))
	if initial_weapon_id != "":
		return initial_weapon_id
	var current_weapon: Dictionary = target.get("current_weapon") as Dictionary
	return String(current_weapon.get("baseWeaponId", current_weapon.get("id", "")))
