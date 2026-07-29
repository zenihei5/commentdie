extends Node

const WEAPON_IDS := ["moderator_shield", "fansa_baton", "tsuri_thumbnail_rod"]

func _ready() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var failures: Array[String] = []
	var characters: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/characters.json")) as Array
	var weapons: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/weapons.json")) as Array
	_check(not characters.is_empty() and not weapons.is_empty(), "data files did not parse", failures)
	var expected_initial := {
		"aosumi_kyasumi": "moderator_shield",
		"akarine_rizumu": "fansa_baton",
		"shizuki_miimu": "tsuri_thumbnail_rod"
	}
	for character_item in characters:
		var character: Dictionary = character_item as Dictionary
		var character_id := String(character.get("id", ""))
		if expected_initial.has(character_id):
			_check(String(character.get("initialWeapon", "")) == String(expected_initial[character_id]), "%s initial weapon mismatch" % character_id, failures)
	for weapon_id in WEAPON_IDS:
		var weapon := WeaponSystem.find_weapon(weapons, weapon_id, {})
		_check(not weapon.is_empty(), "%s missing from weapon registry" % weapon_id, failures)
		_check(int(weapon.get("maxLevel", 0)) == 5, "%s is not Lv5-capable" % weapon_id, failures)
		_check(bool(weapon.get("offerEnabled", false)) and bool(weapon.get("giftEnabled", false)) and bool(weapon.get("canAppearAsUpgrade", false)) and bool(weapon.get("ownedUpgradeOnly", false)), "%s candidate flags are not owned-only" % weapon_id, failures)
		_check((weapon.get("levelStats", []) as Array).size() == 5, "%s levelStats is incomplete" % weapon_id, failures)
		_check(is_equal_approx(float(weapon.get("baseDamage", 0.0)), 10.0), "%s baseDamage bridge missing" % weapon_id, failures)
	_check(EquipmentSystem.initial_weapons("phase1_null_weapon").is_empty(), "phase1 null weapon still consumes a slot", failures)

	var shield_weapon := WeaponSystem.find_weapon(weapons, "moderator_shield", {})
	var shield_context := _context(shield_weapon, "moderator_shield", [_enemy("shield_target", Vector2(90, 0), 100.0)], [])
	var shield_no_target := WeaponSystem.update_equipment_weapons(_context_with(shield_weapon, "moderator_shield", [], {}))
	_check(is_equal_approx(float((shield_no_target["timers"] as Dictionary).get("moderator_shield", 0.0)), 0.15), "shield no-target retry was not used", failures)
	_check((shield_no_target["hitFx"] as Array).is_empty(), "shield spawned FX without a target", failures)
	var shield_result := WeaponSystem.update_equipment_weapons(shield_context)
	_check((shield_result["hitFx"] as Array).size() == 1, "shield did not spawn its active FX", failures)
	var shield_enemies: Array = shield_context["enemies"] as Array
	var shield_fx: Array = shield_result["hitFx"] as Array
	WeaponSystem.update_hit_fx(shield_fx, 0.25, shield_enemies, [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(float((shield_enemies[0] as Dictionary).get("hp", 100.0)) < 100.0, "shield did not route damage through enemy hit path", failures)
	_check(int((shield_fx[0] as Dictionary).get("bulletClears", 0)) <= 3, "shield exceeded bullet clear cap", failures)
	var shield_box := _gift_box(1001, Vector2(90, 0))
	var shield_box_context := _context_with(shield_weapon, "moderator_shield", [], {})
	shield_box_context["destructibles"] = [shield_box]
	var shield_box_result := WeaponSystem.update_equipment_weapons(shield_box_context)
	var shield_box_fx: Array = shield_box_result["hitFx"] as Array
	var shield_destroyed: Array = []
	_check(shield_box_fx.size() == 1, "shield did not target a field gift without enemies", failures)
	WeaponSystem.update_hit_fx(shield_box_fx, 0.25, [], [shield_box], [], [], shield_destroyed, {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(float(shield_box.get("hp", 1.0)) <= 0.0 and shield_destroyed.size() == 1, "shield did not damage a field gift", failures)

	var baton_weapon := WeaponSystem.find_weapon(weapons, "fansa_baton", {})
	var baton_timers: Dictionary = {}
	var baton_enemies: Array = [_enemy("baton_target", Vector2(80, 0), 1000.0)]
	for expected_step in [0, 1, 2]:
		baton_timers["fansa_baton"] = 0.0
		var baton_result := WeaponSystem.update_equipment_weapons(_context_with(baton_weapon, "fansa_baton", baton_enemies, baton_timers))
		var stage_states: Dictionary = baton_timers.get("__stage2WeaponStates", {}) as Dictionary
		var baton_state: Dictionary = stage_states.get("fansa_baton", {}) as Dictionary
		_check(int(baton_state.get("comboStep", -1)) == (expected_step + 1) % 3, "baton combo did not advance from step %d" % expected_step, failures)
		_check(not (baton_result["hitFx"] as Array).is_empty(), "baton step %d did not produce visual FX" % expected_step, failures)
	baton_timers["fansa_baton"] = 0.0
	var baton_before: Dictionary = (baton_timers.get("__stage2WeaponStates", {}) as Dictionary).get("fansa_baton", {}) as Dictionary
	var baton_empty := WeaponSystem.update_equipment_weapons(_context_with(baton_weapon, "fansa_baton", [], baton_timers))
	var baton_after: Dictionary = (baton_timers.get("__stage2WeaponStates", {}) as Dictionary).get("fansa_baton", {}) as Dictionary
	_check(int(baton_before.get("comboStep", -1)) == int(baton_after.get("comboStep", -2)), "baton advanced without a target", failures)
	_check((baton_empty["hitFx"] as Array).is_empty(), "baton spawned FX without a target", failures)
	var baton_box := _gift_box(1002, Vector2(80, 0))
	var baton_box_context := _context_with(baton_weapon, "fansa_baton", [], {})
	baton_box_context["destructibles"] = [baton_box]
	var baton_box_result := WeaponSystem.update_equipment_weapons(baton_box_context)
	_check(not (baton_box_result["hitFx"] as Array).is_empty(), "baton did not target a field gift without enemies", failures)
	_check(float(baton_box.get("hp", 1.0)) <= 0.0 and (baton_box_result["destroyedBoxes"] as Array).size() == 1, "baton did not damage a field gift", failures)

	var rod_weapon := WeaponSystem.find_weapon(weapons, "tsuri_thumbnail_rod", {})
	var rod_target := _enemy("rod_target", Vector2(100, 0), 100.0)
	var rod_path_target := _enemy("rod_path", Vector2(50, 0), 100.0)
	var rod_enemies: Array = [rod_target, rod_path_target]
	var rod_timers: Dictionary = {}
	var rod_result := WeaponSystem.update_equipment_weapons(_context_with(rod_weapon, "tsuri_thumbnail_rod", rod_enemies, rod_timers))
	var rod_fx: Array = rod_result["hitFx"] as Array
	_check(rod_fx.size() == 1, "rod did not create one cast", failures)
	WeaponSystem.update_hit_fx(rod_fx, 0.2, rod_enemies, [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(String((rod_fx[0] as Dictionary).get("phase", "")) == "gathering", "rod did not land on its target", failures)
	WeaponSystem.update_hit_fx(rod_fx, 0.22, rod_enemies, [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	WeaponSystem.update_hit_fx(rod_fx, 0.70, rod_enemies, [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	WeaponSystem.update_hit_fx(rod_fx, 0.10, rod_enemies, [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(float(rod_target.get("hp", 100.0)) < 100.0 and float(rod_path_target.get("hp", 100.0)) < 100.0, "rod did not apply initial/path damage", failures)
	var rod_box := _gift_box(1003, Vector2(100, 0))
	var rod_box_context := _context_with(rod_weapon, "tsuri_thumbnail_rod", [], {})
	rod_box_context["destructibles"] = [rod_box]
	var rod_box_result := WeaponSystem.update_equipment_weapons(rod_box_context)
	var rod_box_fx: Array = rod_box_result["hitFx"] as Array
	var rod_destroyed: Array = []
	_check(rod_box_fx.size() == 1, "rod did not target a field gift without enemies", failures)
	WeaponSystem.update_hit_fx(rod_box_fx, 0.2, [], [rod_box], [], [], rod_destroyed, {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(float(rod_box.get("hp", 1.0)) <= 0.0 and rod_destroyed.size() == 1, "rod did not damage a field gift", failures)

	if failures.is_empty():
		print("Stage2 weapon tests passed")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	get_tree().quit(1)

func _enemy(kind: String, pos: Vector2, hp: float) -> Dictionary:
	return {"kind": kind, "uid": int(abs(kind.hash())), "spawnToken": "%s:%d" % [kind, int(abs(kind.hash()))], "pos": pos, "hp": hp, "max_hp": hp, "radius": 20.0, "canBeKnockedBack": true, "knockbackResistance": 0.0, "damageTakenRate": 1.0, "behavior": "chase", "canBePulled": true, "pullResistance": 0.0, "defeatPending": false, "defeatResolved": false}

func _gift_box(uid: int, pos: Vector2) -> Dictionary:
	return {"id": "care_package_box", "uid": uid, "pos": pos, "hp": 1.0, "radius": 24.0}

func _context(weapon: Dictionary, weapon_id: String, enemies: Array, bullets: Array) -> Dictionary:
	return _context_with(weapon, weapon_id, enemies, {})

func _context_with(weapon: Dictionary, weapon_id: String, enemies: Array, timers: Dictionary) -> Dictionary:
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
