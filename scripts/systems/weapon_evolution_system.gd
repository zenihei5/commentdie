class_name WeaponEvolutionSystem
extends RefCounted

const REQUIRED_WEAPON_LEVEL := 5
const REQUIRED_EXP_LEVEL := 5


static func evolution_gift_for_target(target: Node, weapon_data: Array) -> Dictionary:
	var state: Dictionary = evolution_state_for_target(target, weapon_data)
	if not bool(state.get("canEvolve", false)):
		return {}
	var base_weapon: Dictionary = state["baseWeapon"] as Dictionary
	var evolved_weapon: Dictionary = state["evolvedWeapon"] as Dictionary
	var base_name: String = String(base_weapon.get("displayName", state.get("baseWeaponId", "")))
	var evolved_name: String = String(evolved_weapon.get("displayName", state.get("evolvedWeaponId", "")))
	return {
		"id": "evolution_%s" % String(state["baseWeaponId"]),
		"displayName": evolved_name,
		"description": "%sを進化させる" % base_name,
		"rarity": "evolution",
		"equipmentType": "evolution",
		"effectType": "weapon_evolution",
		"weight": 1,
		"maxLevel": 1,
		"isEvolutionGift": true,
		"baseWeaponId": String(state["baseWeaponId"]),
		"evolvedWeaponId": String(state["evolvedWeaponId"]),
		"baseDisplayName": base_name,
		"evolvedDisplayName": evolved_name,
		"iconPath": String(evolved_weapon.get("iconPath", base_weapon.get("iconPath", "")))
	}


static func evolution_state_for_target(target: Node, weapon_data: Array) -> Dictionary:
	var base_id: String = _initial_weapon_id(target)
	if base_id == "":
		return {"canEvolve": false}
	var player_weapons: Array = target.get("player_weapons") as Array
	var base_entry: Dictionary = EquipmentSystem.find_entry(player_weapons, base_id)
	if base_entry.is_empty() or EquipmentSystem.is_evolved_entry(base_entry):
		return {"canEvolve": false}
	var base_weapon: Dictionary = WeaponSystem.find_weapon(weapon_data, base_id, {})
	if base_weapon.is_empty():
		return {"canEvolve": false}
	var evolution: Dictionary = base_weapon.get("evolution", {}) as Dictionary
	if evolution.is_empty():
		return {"canEvolve": false}
	var required_character: String = String(evolution.get("requiredCharacterId", ""))
	if required_character != "" and required_character != String(target.get("current_character_id")):
		return {"canEvolve": false}
	var required_weapon_level: int = int(evolution.get("requiredWeaponLevel", REQUIRED_WEAPON_LEVEL))
	if EquipmentSystem.level(player_weapons, base_id) < required_weapon_level:
		return {"canEvolve": false}
	var required_exp_level: int = int(evolution.get("requiredExpLevel", REQUIRED_EXP_LEVEL))
	if int(target.get("exp_level")) < required_exp_level:
		return {"canEvolve": false}
	var evolved_id: String = String(evolution.get("evolvedWeaponId", ""))
	if evolved_id == "" or not EquipmentSystem.find_entry(player_weapons, evolved_id).is_empty():
		return {"canEvolve": false}
	var evolved_weapon: Dictionary = WeaponSystem.find_weapon(weapon_data, evolved_id, {})
	if evolved_weapon.is_empty():
		return {"canEvolve": false}
	return {
		"canEvolve": true,
		"baseWeaponId": base_id,
		"evolvedWeaponId": evolved_id,
		"baseWeapon": base_weapon,
		"evolvedWeapon": evolved_weapon,
		"baseLevel": EquipmentSystem.level(player_weapons, base_id)
	}


static func is_evolution_gift(gift: Dictionary) -> bool:
	return bool(gift.get("isEvolutionGift", false)) or String(gift.get("effectType", "")) == "weapon_evolution"


static func apply_evolution_gift_for_target(target: Node, gift: Dictionary) -> Dictionary:
	var base_id: String = String(gift.get("baseWeaponId", ""))
	var evolved_id: String = String(gift.get("evolvedWeaponId", ""))
	var weapon_data: Array = target.get("weapons") as Array
	var evolved_weapon: Dictionary = WeaponSystem.find_weapon(weapon_data, evolved_id, {})
	if base_id == "" or evolved_id == "" or evolved_weapon.is_empty():
		return _empty_apply_result({})

	var player_weapons: Array = target.get("player_weapons") as Array
	var target_index: int = -1
	for index in range(player_weapons.size()):
		var entry: Dictionary = player_weapons[index] as Dictionary
		if String(entry.get("id", "")) == base_id:
			target_index = index
			break
	if target_index < 0:
		return _empty_apply_result({})

	var previous_level: int = EquipmentSystem.level(player_weapons, base_id)
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
	target.set("equipment_weapon_timers", timers)

	var base_weapon: Dictionary = WeaponSystem.find_weapon(weapon_data, base_id, {})
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
