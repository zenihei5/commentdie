extends Node

func _ready() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var failures: Array[String] = []
	var weapons: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/weapons.json")) as Array
	var baton := WeaponSystem.find_weapon(weapons, "fansa_baton", {})
	var climax := WeaponSystem.find_weapon(weapons, "fansa_climax", {})
	_check(not baton.is_empty() and not climax.is_empty(), "fansa weapon registry entries missing", failures)
	var base_context := _context()
	var expected_radii := [110.0, 110.0, 130.0, 140.0, 150.0]
	var expected_arcs := [130.0, 130.0, 130.0, 150.0, 150.0]
	var expected_durations := [0.18, 0.18, 0.18, 0.18, 0.20]
	for index in range(5):
		var level_data := WeaponSystem._stage2_level_data(baton, index + 1)
		var shape := WeaponSystem.fansa_attack_shape(level_data, index + 1, base_context)
		_check(is_equal_approx(float(shape.get("radius", 0.0)), expected_radii[index]), "baton Lv%d radius mismatch" % (index + 1), failures)
		_check(is_equal_approx(float(shape.get("arcDegrees", 0.0)), expected_arcs[index]), "baton Lv%d arc mismatch" % (index + 1), failures)
		_check(is_equal_approx(float(shape.get("originOffset", 0.0)), 25.0), "baton Lv%d origin offset changed" % (index + 1), failures)
		_check(is_equal_approx(float(shape.get("hitboxDuration", 0.0)), expected_durations[index]), "baton Lv%d hitbox duration mismatch" % (index + 1), failures)
	var climax_shape := WeaponSystem.fansa_attack_shape(climax, 1, base_context)
	_check(is_equal_approx(float(climax_shape.get("radius", 0.0)), 180.0), "climax radius mismatch", failures)
	_check(is_equal_approx(float(climax_shape.get("arcDegrees", 0.0)), 180.0), "climax arc mismatch", failures)
	_check(is_equal_approx(float(climax_shape.get("originOffset", 0.0)), 25.0), "climax origin offset mismatch", failures)
	_check(bool(climax_shape.get("useHurtboxOverlap", false)) and not bool(climax_shape.get("autoLunge", true)), "climax hurtbox/lunge flags mismatch", failures)
	var short_context := _context()
	short_context["shortRange"] = true
	short_context["shortRangeRate"] = 0.50
	var short_shape := WeaponSystem.fansa_attack_shape(baton, 1, short_context)
	_check(is_equal_approx(float(short_shape.get("radius", 0.0)), 93.5), "short_range did not affect only radius", failures)
	_check(is_equal_approx(float(short_shape.get("arcDegrees", 0.0)), 130.0), "short_range changed baton arc", failures)
	_check(is_equal_approx(float(short_shape.get("originOffset", 0.0)), 25.0), "short_range changed origin offset", failures)

	var front := _enemy("front", Vector2(105, 0), 100.0, 20.0)
	var rear := _enemy("rear", Vector2(-70, 0), 100.0, 20.0)
	var corner := _enemy("corner", Vector2(50, 130), 100.0, 20.0)
	var enemies: Array = [front, rear, corner]
	var hit_ids: Dictionary = {}
	var killed: Array = []
	var hit_fx: Array = []
	var hits := WeaponSystem._apply_arc_damage(enemies, Vector2(25, 0), Vector2.RIGHT, 110.0, 130.0, 10.0, 0.0, killed, hit_fx, [], "fansa_baton", {"hitEnemyIds": hit_ids})
	_check(hits == 1 and float(front.get("hp", 0.0)) < 100.0, "front enemy was not hit by the baton fan", failures)
	_check(is_equal_approx(float(rear.get("hp", 0.0)), 100.0), "rear enemy was hit by the baton fan", failures)
	_check(is_equal_approx(float(corner.get("hp", 0.0)), 100.0), "outside-angle enemy was hit by the baton fan", failures)
	var rehit := WeaponSystem._apply_arc_damage(enemies, Vector2(25, 0), Vector2.RIGHT, 110.0, 130.0, 10.0, 0.0, killed, hit_fx, [], "fansa_baton", {"hitEnemyIds": hit_ids})
	_check(rehit == 0 and is_equal_approx(float(front.get("hp", 0.0)), 90.0), "one attack instance hit the same enemy more than once", failures)
	var next_attack_ids: Dictionary = {}
	var next_attack := WeaponSystem._apply_arc_damage(enemies, Vector2(25, 0), Vector2.RIGHT, 110.0, 130.0, 10.0, 0.0, killed, hit_fx, [], "fansa_baton", {"hitEnemyIds": next_attack_ids})
	_check(next_attack == 1 and is_equal_approx(float(front.get("hp", 0.0)), 80.0), "next baton attack could not hit again", failures)

	var boss := _enemy("last_offline", Vector2(210, 0), 1000.0, 78.0)
	boss["isBoss"] = true
	boss["bossId"] = "last_offline"
	_check(is_equal_approx(EnemySystem.weapon_hurt_radius(boss), 78.0) and is_equal_approx(float(boss.get("radius", 0.0)), 78.0), "boss hurtbox changed contact radius", failures)
	_check(WeaponSystem.fan_sector_circle_overlap(Vector2(25, 0), Vector2.RIGHT, 110.0, 130.0, Vector2(210, 0), EnemySystem.weapon_hurt_radius(boss)), "boss hurtbox edge did not overlap the baton fan", failures)
	_check(not WeaponSystem.fan_sector_circle_overlap(Vector2(25, 0), Vector2.RIGHT, 110.0, 130.0, Vector2(230, 0), EnemySystem.weapon_hurt_radius(boss)), "out-of-range boss hurtbox overlapped the baton fan", failures)
	var boss_context := _context()
	boss_context["enemies"] = [_enemy("normal_near", Vector2(80, 0), 100.0, 20.0), boss]
	var boss_selection := WeaponSystem._baton_direction_for_step(0, baton, boss_context)
	_check(String(boss_selection.get("targetType", "")) == "boss", "reachable boss was not prioritized over normal enemy", failures)
	boss["pos"] = Vector2(240, 0)
	var far_boss_selection := WeaponSystem._baton_direction_for_step(0, baton, boss_context)
	_check(String(far_boss_selection.get("targetType", "")) == "enemy", "unreachable boss was incorrectly prioritized", failures)

	var fallback_context := _context()
	fallback_context["moveInput"] = Vector2.UP
	fallback_context["lastMoveDirection"] = Vector2.LEFT
	var fallback_selection := WeaponSystem._baton_direction_for_step(0, baton, fallback_context)
	_check(String(fallback_selection.get("targetType", "")) == "fallback" and Vector2(fallback_selection.get("dir", Vector2.ZERO)).is_equal_approx(Vector2.UP), "empty-target fallback direction did not use current movement", failures)
	fallback_context["attackRightOnly"] = true
	var right_selection := WeaponSystem._baton_direction_for_step(0, baton, fallback_context)
	_check(Vector2(right_selection.get("dir", Vector2.ZERO)).is_equal_approx(Vector2.RIGHT), "attack_right_only did not force right", failures)

	var empty_timers: Dictionary = {}
	var empty_context := _context()
	empty_context["weaponData"] = [baton]
	empty_context["playerWeapons"] = [{"id": "fansa_baton", "level": 1}]
	empty_context["mainWeaponId"] = "fansa_baton"
	empty_context["timers"] = empty_timers
	var empty_result := WeaponSystem.update_equipment_weapons(empty_context)
	_check(not (empty_result.get("hitFx", []) as Array).is_empty(), "empty target did not create the fallback baton attack", failures)

	if failures.is_empty():
		print("Fansa baton range tests passed")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	get_tree().quit(1)

func _context() -> Dictionary:
	return {
		"delta": 0.1, "playerPos": Vector2.ZERO, "facingDir": Vector2.RIGHT, "playerVel": Vector2.ZERO,
		"moveInput": Vector2.ZERO, "lastMoveDirection": Vector2.RIGHT, "attackRightOnly": false,
		"attackRightOnlyRate": 1.0, "shortRange": false, "shortRangeRate": 1.0,
		"rangeRate": 1.0, "intervalRate": 1.0, "attackAreaRate": 1.0, "damageRate": 1.0,
		"enemies": [], "destructibles": [], "normalWeaponsDisabled": false, "activeFx": []
	}

func _enemy(kind: String, pos: Vector2, hp: float, radius: float) -> Dictionary:
	return {
		"kind": kind, "uid": int(abs(kind.hash())), "spawnToken": "%s:%d" % [kind, int(abs(kind.hash()))],
		"pos": pos, "hp": hp, "max_hp": hp, "radius": radius, "hurtboxRadius": radius,
		"canBeKnockedBack": true, "knockbackResistance": 0.0, "damageTakenRate": 1.0,
		"behavior": "chase", "canBePulled": true, "pullResistance": 0.0,
		"defeatPending": false, "defeatResolved": false
	}

func _check(condition: bool, message: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(message)
