extends Node


func _ready() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	var failures: Array[String] = []
	var weapons: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/weapons.json")) as Array
	_check(not weapons.is_empty(), "weapon registry did not parse", failures)
	_test_fortress_shockwave(weapons, failures)
	_test_climax_enemy_combo(weapons, failures)
	_test_climax_boxes(weapons, failures)
	_test_buzz_boss_reel(weapons, failures)
	_test_buzz_normal_capture(weapons, failures)
	_test_buzz_box_hit(weapons, failures)
	if failures.is_empty():
		print("Evolved weapon consistency tests passed")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	get_tree().quit(1)


func _test_fortress_shockwave(weapons: Array, failures: Array[String]) -> void:
	var fortress := WeaponSystem.find_weapon(weapons, "moderator_fortress", {})
	var enemy := _enemy(1, Vector2(80.0, 0.0), 100.0, 20.0)
	var bullet := {"pos": Vector2(80.0, 0.0), "life": 1.0, "hitRadius": 8.0, "shieldBlockable": true}
	var context := _context(weapons, fortress, "moderator_fortress", [enemy], [], {}, [bullet])
	var result := WeaponSystem.update_equipment_weapons(context)
	var fortress_fx: Array = result.get("hitFx", []) as Array
	var active := _find_fx(fortress_fx, "moderator_fortress_active")
	var shockwave := _find_fx(fortress_fx, "moderator_fortress_shockwave")
	_check(not active.is_empty() and not shockwave.is_empty(), "fortress activation FX missing", failures)
	var active_hit_times := active.get("hitNextTimes", {}) as Dictionary
	var shockwave_hit_times := shockwave.get("hitNextTimes", {}) as Dictionary
	shockwave_hit_times["separationProbe"] = 1.0
	_check(not active_hit_times.has("separationProbe"), "fortress body and shockwave still share hit memory", failures)
	shockwave_hit_times.erase("separationProbe")
	_check(is_equal_approx(float(active.get("damage", 0.0)), 17.0), "fortress body damage changed", failures)
	_check(is_equal_approx(float(shockwave.get("damage", 0.0)), 10.0), "fortress shockwave damage changed", failures)
	_check(is_equal_approx(float(shockwave.get("knockback", 0.0)), 118.125), "fortress shockwave knockback changed", failures)
	fortress_fx = WeaponSystem.update_hit_fx(fortress_fx, 0.01, [enemy], [], [bullet], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(is_equal_approx(float(enemy.get("hp", 0.0)), 73.0), "fortress body and deployment shockwave did not deal 17 + 10", failures)
	_check(float(bullet.get("life", 1.0)) <= 0.0, "fortress projectile clear regressed", failures)
	_check(is_equal_approx(float(enemy.get("shieldContactSuppressTimer", 0.0)), 0.10), "fortress contact suppression regressed", failures)
	fortress_fx = WeaponSystem.update_hit_fx(fortress_fx, 0.10, [enemy], [], [bullet], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(is_equal_approx(float(enemy.get("hp", 0.0)), 73.0), "fortress shockwave or body repeated before 0.35 seconds", failures)
	fortress_fx = WeaponSystem.update_hit_fx(fortress_fx, 0.26, [enemy], [], [bullet], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(is_equal_approx(float(enemy.get("hp", 0.0)), 56.0), "fortress body 0.35-second rehit changed", failures)


func _test_climax_enemy_combo(weapons: Array, failures: Array[String]) -> void:
	var climax := WeaponSystem.find_weapon(weapons, "fansa_climax", {})
	var enemy := _enemy(20, Vector2(70.0, 0.0), 1000.0, 20.0)
	var timers: Dictionary = {}
	var context := _context(weapons, climax, "fansa_climax", [enemy], [], timers)
	var expected_after_main: Array[float] = [993.5, 984.0, 967.0]
	var expected_after_followup: Array[float] = [990.5, 981.0, 955.5]
	for step in range(3):
		timers["fansa_climax"] = 0.0
		var result := WeaponSystem.update_equipment_weapons(context)
		_check(is_equal_approx(float(enemy.get("hp", 0.0)), expected_after_main[step]), "climax main damage changed at step %d" % step, failures)
		_check(is_equal_approx(float(timers.get("fansa_climax", 0.0)), 0.47), "climax 0.47-second interval changed at step %d" % step, failures)
		var step_fx: Array = result.get("hitFx", []) as Array
		if step < 2:
			step_fx = WeaponSystem.update_hit_fx(step_fx, 0.12, [enemy], [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
			step_fx = WeaponSystem.update_hit_fx(step_fx, 0.001, [enemy], [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
		else:
			step_fx = WeaponSystem.update_hit_fx(step_fx, 0.001, [enemy], [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
		_check(is_equal_approx(float(enemy.get("hp", 0.0)), expected_after_followup[step]), "climax follow-up damage changed at step %d" % step, failures)


func _test_climax_boxes(weapons: Array, failures: Array[String]) -> void:
	var climax := WeaponSystem.find_weapon(weapons, "fansa_climax", {})
	for step in range(3):
		var box := _box(100 + step, Vector2(70.0, 0.0))
		var timers := {"__stage2WeaponStates": {"fansa_climax": {"comboStep": step}}}
		var result := WeaponSystem.update_equipment_weapons(_context(weapons, climax, "fansa_climax", [], [box], timers))
		_check(float(box.get("hp", 1.0)) <= 0.0 and (result.get("destroyedBoxes", []) as Array).size() == 1, "climax main step %d did not break a gift box exactly once" % (step + 1), failures)

	for step in [0, 1]:
		var timers := {"__stage2WeaponStates": {"fansa_climax": {"comboStep": step}}}
		var generated := WeaponSystem.update_equipment_weapons(_context(weapons, climax, "fansa_climax", [], [], timers))
		var echo := _find_fx(generated.get("hitFx", []) as Array, "fansa_climax_echo")
		var box := _box(120 + step, Vector2(70.0, 0.0))
		var destroyed: Array = []
		var echo_fx: Array = [echo]
		echo_fx = WeaponSystem.update_hit_fx(echo_fx, 0.12, [], [box], [], [], destroyed, {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
		echo_fx = WeaponSystem.update_hit_fx(echo_fx, 0.001, [], [box], [], [], destroyed, {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
		_check(float(box.get("hp", 1.0)) <= 0.0 and destroyed.size() == 1, "climax echo step %d did not break a gift box exactly once" % (step + 1), failures)

	var finisher_timers := {"__stage2WeaponStates": {"fansa_climax": {"comboStep": 2}}}
	var finisher_result := WeaponSystem.update_equipment_weapons(_context(weapons, climax, "fansa_climax", [], [], finisher_timers))
	for kind in ["fansa_climax_x", "fansa_climax_fan_wave"]:
		var effect := _find_fx(finisher_result.get("hitFx", []) as Array, kind)
		var box := _box(140 if kind == "fansa_climax_x" else 141, Vector2(70.0, 0.0))
		var destroyed: Array = []
		WeaponSystem.update_hit_fx([effect], 0.001, [], [box], [], [], destroyed, {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
		_check(float(box.get("hp", 1.0)) <= 0.0 and destroyed.size() == 1, "%s did not break a gift box exactly once" % kind, failures)


func _test_buzz_boss_reel(weapons: Array, failures: Array[String]) -> void:
	var buzz := WeaponSystem.find_weapon(weapons, "buzz_thumbnail_rod", {})
	var boss := _enemy(200, Vector2(90.0, 0.0), 100.0, 50.0)
	boss["isBoss"] = true
	boss["bossId"] = "test_boss"
	boss["canBePulled"] = false
	boss["canBeKnockedBack"] = false
	var bystander := _enemy(201, Vector2(110.0, 0.0), 100.0, 40.0)
	bystander["canBePulled"] = false
	var enemies: Array = [boss, bystander]
	var result := WeaponSystem.update_equipment_weapons(_context(weapons, buzz, "buzz_thumbnail_rod", enemies, [], {}))
	var buzz_fx: Array = result.get("hitFx", []) as Array
	var cast := _find_fx(buzz_fx, "buzz_thumbnail_rod_cast")
	_check(bool(cast.get("bossTarget", false)), "buzz did not select the nearest boss target", failures)
	_check(is_equal_approx(float(cast.get("bossReelDamage", 0.0)), 16.0), "buzz boss reel data changed", failures)
	_check(is_equal_approx(float(cast.get("itemAttractRadius", 0.0)), 360.0) and is_equal_approx(float(cast.get("itemReturnSpeed", 0.0)), 2100.0), "buzz item collection configuration changed", failures)
	buzz_fx = WeaponSystem.update_hit_fx(buzz_fx, 0.10, enemies, [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(is_equal_approx(float(boss.get("hp", 0.0)), 96.0), "buzz boss initial damage is not 4", failures)
	buzz_fx = WeaponSystem.update_hit_fx(buzz_fx, 0.80, enemies, [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	cast = _find_fx(buzz_fx, "buzz_thumbnail_rod_cast")
	_check(String(cast.get("phase", "")) == "throwing" and (cast.get("caughtTokens", []) as Array).is_empty(), "buzz boss did not enter the uncaptured finish path", failures)
	buzz_fx = WeaponSystem.update_hit_fx(buzz_fx, 0.01, enemies, [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	cast = _find_fx(buzz_fx, "buzz_thumbnail_rod_cast")
	_check(is_equal_approx(float(boss.get("hp", 0.0)), 80.0), "buzz boss did not receive 4 + 16 damage", failures)
	_check(is_equal_approx(float(bystander.get("hp", 0.0)), 92.5), "buzz boss-centered explosion did not deal 7.5", failures)
	_check(String(cast.get("phase", "")) == "waiting", "buzz boss did not continue to reel wait", failures)
	_check(not boss.has("movementPaused") and not boss.has("throwing"), "buzz boss was captured or suspended", failures)
	_check(not _find_fx(buzz_fx, "buzz_thumbnail_rod_explosion").is_empty(), "buzz boss-centered explosion FX missing", failures)
	buzz_fx = WeaponSystem.update_hit_fx(buzz_fx, 0.10, enemies, [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(is_equal_approx(float(boss.get("hp", 0.0)), 80.0) and is_equal_approx(float(bystander.get("hp", 0.0)), 92.5), "buzz boss reel or explosion repeated", failures)


func _test_buzz_normal_capture(weapons: Array, failures: Array[String]) -> void:
	var buzz := WeaponSystem.find_weapon(weapons, "buzz_thumbnail_rod", {})
	var enemies: Array = []
	for index in range(4):
		var enemy := _enemy(300 + index, Vector2(90.0 + float(index) * 5.0, 0.0), 1000.0, 16.0)
		enemy["canBePulled"] = true
		enemy["pullResistance"] = 0.0
		enemies.append(enemy)
	var result := WeaponSystem.update_equipment_weapons(_context(weapons, buzz, "buzz_thumbnail_rod", enemies, [], {}))
	var buzz_fx: Array = result.get("hitFx", []) as Array
	buzz_fx = WeaponSystem.update_hit_fx(buzz_fx, 0.20, enemies, [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	buzz_fx = WeaponSystem.update_hit_fx(buzz_fx, 0.80, enemies, [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	var cast := _find_fx(buzz_fx, "buzz_thumbnail_rod_cast")
	_check((cast.get("caughtTokens", []) as Array).size() == 3 and String(cast.get("phase", "")) == "throwing", "buzz normal capture count or phase changed", failures)
	buzz_fx = WeaponSystem.update_hit_fx(buzz_fx, 0.25, enemies, [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	cast = _find_fx(buzz_fx, "buzz_thumbnail_rod_cast")
	_check(String(cast.get("phase", "")) == "waiting" and int(cast.get("explosionCount", 0)) == 3, "buzz normal capture finish or explosions changed", failures)
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		_check(not enemy.has("movementPaused") and not enemy.has("throwing"), "buzz normal target remained suspended", failures)


func _test_buzz_box_hit(weapons: Array, failures: Array[String]) -> void:
	var buzz := WeaponSystem.find_weapon(weapons, "buzz_thumbnail_rod", {})
	var box := _box(500, Vector2(90.0, 0.0))
	var result := WeaponSystem.update_equipment_weapons(_context(weapons, buzz, "buzz_thumbnail_rod", [], [box], {}))
	var buzz_fx: Array = result.get("hitFx", []) as Array
	var cast := _find_fx(buzz_fx, "buzz_thumbnail_rod_cast")
	_check(int(cast.get("targetBoxUid", -1)) == 500, "buzz did not retain the selected gift box UID", failures)
	var destroyed: Array = []
	buzz_fx = WeaponSystem.update_hit_fx(buzz_fx, 0.10, [], [box], [], [], destroyed, {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(float(box.get("hp", 1.0)) <= 0.0 and destroyed.size() == 1, "buzz direct lure did not break the selected gift box", failures)
	buzz_fx = WeaponSystem.update_hit_fx(buzz_fx, 0.10, [], [box], [], [], destroyed, {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(destroyed.size() == 1, "buzz gift box damage repeated after landing", failures)


func _context(weapon_data: Array, weapon: Dictionary, weapon_id: String, enemies: Array, destructibles: Array, timers: Dictionary, enemy_bullets: Array = []) -> Dictionary:
	return {
		"delta": 0.1,
		"weaponData": weapon_data,
		"playerWeapons": [{"id": weapon_id, "level": 1}],
		"mainWeaponId": weapon_id,
		"timers": timers,
		"playerPos": Vector2.ZERO,
		"facingDir": Vector2.RIGHT,
		"playerVel": Vector2.ZERO,
		"manualAimDirection": Vector2.ZERO,
		"moveInput": Vector2.ZERO,
		"enemies": enemies,
		"destructibles": destructibles,
		"enemyBullets": enemy_bullets,
		"activeFx": [],
		"damageRate": 1.0,
		"rangeRate": 1.0,
		"intervalRate": 1.0,
		"attackAreaRate": 1.0,
		"bulletSupportLevel": 0,
		"shortRange": false,
		"shortRangeRate": 1.0,
		"knockback": 0.0,
		"normalWeaponsDisabled": false,
		"weaponMute": false
	}


func _enemy(uid: int, pos: Vector2, hp: float, radius: float) -> Dictionary:
	return {
		"kind": "test_enemy",
		"uid": uid,
		"spawnToken": "test_enemy:%d" % uid,
		"pos": pos,
		"hp": hp,
		"max_hp": hp,
		"radius": radius,
		"canBeKnockedBack": true,
		"knockbackResistance": 0.0,
		"damageTakenRate": 1.0
	}


func _box(uid: int, pos: Vector2) -> Dictionary:
	return {"id": "care_package_box", "uid": uid, "pos": pos, "hp": 1.0, "radius": 24.0}


func _find_fx(items: Array, kind: String) -> Dictionary:
	for item_value in items:
		var item: Dictionary = item_value as Dictionary
		if String(item.get("kind", "")) == kind:
			return item
	return {}


func _check(condition: bool, message: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(message)
