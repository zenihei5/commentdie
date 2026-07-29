extends Node

const WEAPON_IDS := ["moderator_shield", "fansa_baton", "tsuri_thumbnail_rod"]

func _ready() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var failures: Array[String] = []
	var weapons: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/weapons.json")) as Array
	_check(weapons.size() > 0, "weapon registry did not parse", failures)
	for weapon_id in WEAPON_IDS:
		var weapon := WeaponSystem.find_weapon(weapons, weapon_id, {})
		_check(int(weapon.get("maxLevel", 0)) == 5, "%s maxLevel" % weapon_id, failures)
		_check((weapon.get("levelStats", []) as Array).size() == 5, "%s levelStats" % weapon_id, failures)
		for level in range(1, 6):
			var level_data := WeaponSystem._stage2_level_data(weapon, level)
			_check(int(level_data.get("level", 0)) == level, "%s level snapshot %d" % [weapon_id, level], failures)

	var shield := WeaponSystem.find_weapon(weapons, "moderator_shield", {})
	var shield_level_3 := WeaponSystem._stage2_level_data(shield, 3)
	_check(int(shield_level_3.get("maxBulletClears", 0)) == 5, "shield Lv3 bullet cap", failures)
	var shield_level_5 := WeaponSystem._stage2_level_data(shield, 5)
	_check(bool(shield_level_5.get("completionWave", false)), "shield Lv5 completion wave flag", failures)

	var baton := WeaponSystem.find_weapon(weapons, "fansa_baton", {})
	var baton_level_4 := WeaponSystem._stage2_level_data(baton, 4)
	_check(is_equal_approx(float(baton_level_4.get("hitInterval", 0.0)), 0.47), "baton Lv4 interval", failures)
	var baton_level_5 := WeaponSystem._stage2_level_data(baton, 5)
	_check(bool(baton_level_5.get("crossFollowup", false)) and is_equal_approx(float(baton_level_5.get("crossDelay", 0.0)), 0.15), "baton Lv5 followup", failures)

	var rod := WeaponSystem.find_weapon(weapons, "tsuri_thumbnail_rod", {})
	var rod_level_3 := WeaponSystem._stage2_level_data(rod, 3)
	_check(int(rod_level_3.get("gatherMaxTargets", 0)) == 8, "rod Lv3 gather cap", failures)
	var rod_level_5 := WeaponSystem._stage2_level_data(rod, 5)
	_check(bool(rod_level_5.get("collisionEnabled", false)) and int(rod_level_5.get("collisionMaxTargets", 0)) == 5, "rod Lv5 collision cap", failures)

	var gift_context := {
		"initialWeaponId": "moderator_shield", "weaponRegistry": weapons,
		"currentCharacter": {"id": "aosumi_kyasumi"}, "playerWeapons": [{"id": "moderator_shield", "level": 2}],
		"playerAccessories": [], "gifts": [], "availableIds": [], "streamFrame": {}
	}
	var owned_candidate := GiftSystem._owned_initial_weapon_candidate(gift_context)
	_check(String(owned_candidate.get("id", "")) == "moderator_shield", "owned weapon candidate missing", failures)
	_check(int(owned_candidate.get("weight", 0)) == 10, "owned weapon candidate weight does not match standard weapons", failures)
	var normal_level_pool := GiftSystem._gift_candidate_pool(gift_context, 1, [], false, true)
	var found_owned_weapon := false
	for candidate_value in normal_level_pool:
		var candidate: Dictionary = candidate_value as Dictionary
		if String(candidate.get("id", "")) == "moderator_shield":
			found_owned_weapon = true
			break
	_check(found_owned_weapon, "owned weapon missing from normal Lv+1 pool", failures)
	gift_context["currentCharacter"] = {"id": "akarine_rizumu"}
	_check(GiftSystem._owned_initial_weapon_candidate(gift_context).is_empty(), "other character received owned weapon candidate", failures)
	gift_context["currentCharacter"] = {"id": "aosumi_kyasumi"}
	gift_context["playerWeapons"] = [{"id": "moderator_shield", "level": 5}]
	_check(GiftSystem._owned_initial_weapon_candidate(gift_context).is_empty(), "Lv5 weapon remained a gift candidate", failures)

	var pull_enemy := {"pos": Vector2.ZERO, "hp": 100.0, "max_hp": 100.0, "radius": 20.0, "canBePulled": true, "canBeKnockedBack": true, "pullResistance": 0.5, "knockbackResistance": 0.0, "knockbackVelocity": Vector2.ZERO}
	WeaponSystem._rod_apply_pull(pull_enemy, Vector2.RIGHT * 20.0, 20.0)
	_check(float((pull_enemy.get("knockbackVelocity", Vector2.ZERO) as Vector2).length()) > 0.0, "pull resistance did not allow partial movement", failures)
	pull_enemy["knockbackVelocity"] = Vector2.ZERO
	pull_enemy["pullResistance"] = 1.0
	WeaponSystem._rod_apply_pull(pull_enemy, Vector2.RIGHT * 20.0, 20.0)
	_check(is_equal_approx(float((pull_enemy.get("knockbackVelocity", Vector2.ZERO) as Vector2).length()), 0.0), "pull resistance 1 did not stop movement", failures)

	if failures.is_empty():
		print("Stage3 weapon data tests passed")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	get_tree().quit(1)

func _check(condition: bool, message: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(message)
