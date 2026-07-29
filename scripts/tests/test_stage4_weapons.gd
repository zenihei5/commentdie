extends Node

const TestTargetScript := preload("res://scripts/tests/stage4_test_target.gd")
const WeaponEvolutionSystemScript := preload("res://scripts/systems/weapon_evolution_system.gd")
const RelayRunDataScript := preload("res://scripts/systems/relay_run_data.gd")

func _ready() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var failures: Array[String] = []
	var weapons: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/weapons.json")) as Array
	_check(not weapons.is_empty(), "weapon registry did not parse", failures)
	var expected := {
		"moderator_shield": {"evolved": "moderator_fortress", "character": "aosumi_kyasumi"},
		"fansa_baton": {"evolved": "fansa_climax", "character": "akarine_rizumu"},
		"tsuri_thumbnail_rod": {"evolved": "buzz_thumbnail_rod", "character": "shizuki_miimu"}
	}
	for base_id in expected.keys():
		var base := WeaponSystem.find_weapon(weapons, String(base_id), {})
		var evolved_id := String((expected[base_id] as Dictionary)["evolved"])
		var evolved := WeaponSystem.find_weapon(weapons, evolved_id, {})
		_check(bool(base.get("evolutionEnabled", false)), "%s evolution disabled" % base_id, failures)
		var evolution: Dictionary = base.get("evolution", {}) as Dictionary
		_check(String(evolution.get("evolvedWeaponId", "")) == evolved_id, "%s evolution target mismatch" % base_id, failures)
		_check(int(evolution.get("requiredWeaponLevel", 0)) == 5 and int(evolution.get("requiredExpLevel", -1)) == 0, "%s evolution requirements" % base_id, failures)
		_check(bool(evolved.get("isEvolved", false)) and int(evolved.get("maxLevel", 0)) == 1, "%s evolved flags" % evolved_id, failures)
		_check(not bool(evolved.get("offerEnabled", true)) and not bool(evolved.get("giftEnabled", true)) and not bool(evolved.get("canAppearAsUpgrade", true)), "%s normal candidate flags" % evolved_id, failures)
		_check(String(evolved.get("visualSourceWeaponId", "")) == base_id, "%s visual source" % evolved_id, failures)

	for base_id in expected.keys():
		var target := _target_for(weapons, String(base_id), String((expected[base_id] as Dictionary)["character"]), 5)
		var state := WeaponEvolutionSystemScript.evolution_state_for_target(target, weapons)
		_check(bool(state.get("canEvolve", false)), "%s Lv5 did not evolve" % base_id, failures)
		target.set("player_weapons", [{"id": String(base_id), "level": 4}])
		_check(not bool(WeaponEvolutionSystemScript.evolution_state_for_target(target, weapons).get("canEvolve", false)), "%s Lv4 evolved" % base_id, failures)
		target.set("player_weapons", [{"id": String(base_id), "level": 5}])
		target.set("exp_level", 1)
		_check(bool(WeaponEvolutionSystemScript.evolution_state_for_target(target, weapons).get("canEvolve", false)), "%s incorrectly required exp level 5" % base_id, failures)
		target.set("current_character_id", "wrong_character")
		_check(not bool(WeaponEvolutionSystemScript.evolution_state_for_target(target, weapons).get("canEvolve", false)), "%s evolved for wrong character" % base_id, failures)

	var apply_target := _target_for(weapons, "moderator_shield", "aosumi_kyasumi", 5)
	apply_target.set("current_weapon_id", "moderator_shield")
	apply_target.set("current_weapon", WeaponSystem.find_weapon(weapons, "moderator_shield", {}))
	var evolution_gift := WeaponEvolutionSystemScript.evolution_gift_for_target(apply_target, weapons)
	var applied := WeaponEvolutionSystemScript.apply_evolution_gift_for_target(apply_target, evolution_gift)
	_check(not (applied.get("weaponEvolution", {}) as Dictionary).is_empty(), "evolution gift did not apply", failures)
	_check(String(((apply_target.get("player_weapons") as Array)[0] as Dictionary).get("id", "")) == "moderator_fortress", "evolution did not replace weapon slot", failures)
	_check(String(apply_target.get("current_weapon_id")) == "moderator_fortress", "current weapon did not follow evolution", failures)
	var evolved_candidate_context := {
		"initialWeaponId": "moderator_shield", "weaponRegistry": weapons,
		"currentCharacter": {"id": "aosumi_kyasumi"}, "playerWeapons": [{"id": "moderator_shield", "level": 5}, {"id": "moderator_fortress", "level": 1}]
	}
	_check(GiftSystem._owned_initial_weapon_candidate(evolved_candidate_context).is_empty(), "Lv5/evolved weapon leaked into normal gift pool", failures)
	_check(not EquipmentSystem.can_offer(apply_target, WeaponSystem.find_weapon(weapons, "moderator_fortress", {}), 0.0), "evolved weapon remained offerable", failures)

	var normalized := RelayRunDataScript.normalize_weapon_entries([
		{"id": "moderator_shield", "level": 5},
		{"id": "moderator_fortress", "level": 1, "isEvolved": true, "baseWeaponId": "moderator_shield"},
		{"id": "moderator_fortress", "level": 1, "isEvolved": true, "baseWeaponId": "moderator_shield"}
	])
	_check(normalized.size() == 1 and String((normalized[0] as Dictionary).get("id", "")) == "moderator_fortress", "relay duplicate normalization failed", failures)
	var cleanup_enemy := {"kind": "small", "uid": 99, "spawnToken": "small:99", "hp": 10.0, "movementPaused": true, "throwing": true}
	apply_target.set("enemies", [cleanup_enemy])
	apply_target.set("hit_fx", [{"kind": "buzz_thumbnail_rod_cast", "weaponId": "buzz_thumbnail_rod", "life": 1.0, "suspendedTargetStates": {"small:99": {"enemy": cleanup_enemy, "previous": {}}}}])
	WeaponSystem.cleanup_runtime_for_weapon(apply_target, "tsuri_thumbnail_rod", "buzz_thumbnail_rod", "test_cleanup")
	_check(not cleanup_enemy.has("movementPaused") and not cleanup_enemy.has("throwing"), "rod transient state was not restored during cleanup", failures)

	var context_weapons: Array = weapons.duplicate(true)
	var fortress := WeaponSystem.find_weapon(context_weapons, "moderator_fortress", {})
	var fortress_context := _context(fortress, "moderator_fortress", [{"kind": "small", "uid": 1, "spawnToken": "small:1", "pos": Vector2(80, 0), "hp": 100.0, "max_hp": 100.0, "radius": 20.0, "canBeKnockedBack": true}], {})
	var fortress_result := WeaponSystem.update_equipment_weapons(fortress_context)
	_check((fortress_result["hitFx"] as Array).size() == 1 and String(((fortress_result["hitFx"] as Array)[0] as Dictionary).get("kind", "")) == "moderator_fortress_active", "fortress did not activate", failures)
	var fortress_fx: Array = fortress_result["hitFx"] as Array
	fortress_fx = WeaponSystem.update_hit_fx(fortress_fx, 0.70, fortress_context["enemies"] as Array, [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	var fortress_has_wave := false
	for fortress_item in fortress_fx:
		if String((fortress_item as Dictionary).get("kind", "")) == "moderator_fortress_shockwave":
			fortress_has_wave = true
	_check(fortress_has_wave, "fortress did not create natural shockwave", failures)

	var climax := WeaponSystem.find_weapon(context_weapons, "fansa_climax", {})
	var climax_timers: Dictionary = {}
	var climax_context := _context(climax, "fansa_climax", [{"kind": "small", "uid": 2, "spawnToken": "small:2", "pos": Vector2(70, 0), "hp": 1000.0, "max_hp": 1000.0, "radius": 20.0, "canBeKnockedBack": true}], climax_timers)
	for expected_step in [0, 1, 2]:
		climax_timers["fansa_climax"] = 0.0
		var climax_result := WeaponSystem.update_equipment_weapons(climax_context)
		var climax_states: Dictionary = climax_timers.get("__stage2WeaponStates", {}) as Dictionary
		var climax_state: Dictionary = climax_states.get("fansa_climax", {}) as Dictionary
		_check(int(climax_state.get("comboStep", -1)) == (expected_step + 1) % 3, "climax combo step %d" % expected_step, failures)
		_check(not (climax_result["hitFx"] as Array).is_empty(), "climax step %d did not create FX" % expected_step, failures)

	var buzz := WeaponSystem.find_weapon(context_weapons, "buzz_thumbnail_rod", {})
	var buzz_enemies: Array = []
	for index in range(5):
		buzz_enemies.append({"kind": "small", "uid": 10 + index, "spawnToken": "small:%d" % (10 + index), "pos": Vector2(90 + index * 5, 0), "hp": 1000.0, "max_hp": 1000.0, "radius": 16.0, "canBeKnockedBack": true, "canBePulled": true, "pullResistance": 0.0})
	var buzz_context := _context(buzz, "buzz_thumbnail_rod", buzz_enemies, {})
	var buzz_result := WeaponSystem.update_equipment_weapons(buzz_context)
	var buzz_fx: Array = buzz_result["hitFx"] as Array
	_check(buzz_fx.size() == 1 and String((buzz_fx[0] as Dictionary).get("kind", "")) == "buzz_thumbnail_rod_cast", "buzz rod did not activate", failures)
	WeaponSystem.update_hit_fx(buzz_fx, 0.20, buzz_enemies, [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	WeaponSystem.update_hit_fx(buzz_fx, 0.80, buzz_enemies, [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	var buzz_state := buzz_fx[0] as Dictionary
	_check(int((buzz_state.get("caughtTokens", []) as Array).size()) <= 3, "buzz caught more than three targets", failures)
	WeaponSystem.cleanup_runtime_for_weapon(apply_target, "moderator_shield", "moderator_fortress", "test_cleanup")
	_check((apply_target.get("hit_fx") as Array).is_empty(), "evolution cleanup left hit FX", failures)

	if failures.is_empty():
		print("Stage4 weapon tests passed")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	get_tree().quit(1)

func _target_for(weapons: Array, base_id: String, character_id: String, level: int) -> Node:
	var target := TestTargetScript.new()
	target.weapons = weapons
	target.set("player_weapons", [{"id": base_id, "level": level}])
	target.set("current_character", {"id": character_id, "initialWeapon": base_id})
	target.set("current_character_id", character_id)
	target.set("current_weapon", WeaponSystem.find_weapon(weapons, base_id, {}))
	target.set("exp_level", 1)
	return target

func _context(weapon: Dictionary, weapon_id: String, enemies: Array, timers: Dictionary) -> Dictionary:
	return {
		"delta": 0.1, "weaponData": [weapon], "playerWeapons": [{"id": weapon_id, "level": 1}], "mainWeaponId": weapon_id,
		"timers": timers, "playerPos": Vector2.ZERO, "facingDir": Vector2.RIGHT, "playerVel": Vector2.ZERO,
		"enemies": enemies, "destructibles": [], "enemyBullets": [], "activeFx": [], "damageRate": 1.0,
		"rangeRate": 1.0, "intervalRate": 1.0, "attackAreaRate": 1.0, "bulletSupportLevel": 0,
		"shortRange": false, "shortRangeRate": 1.0, "knockback": 0.0, "normalWeaponsDisabled": false
	}

func _check(condition: bool, message: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(message)
