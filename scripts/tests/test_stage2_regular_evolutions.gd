extends Node

const TestTargetScript := preload("res://scripts/tests/stage4_test_target.gd")
const TextureCacheSystemScript := preload("res://scripts/systems/texture_cache_system.gd")
const GiftSystemScript := preload("res://scripts/systems/gift_system.gd")

var weapons: Array = []
var failures: Array[String] = []
var texture_cache: Dictionary = {}


func _ready() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/weapons.json"))
	weapons = parsed as Array if parsed is Array else []
	_check(not weapons.is_empty(), "weapon registry did not parse", failures)
	_test_data_values()
	_test_full_voice_dome()
	_test_center_stage()
	_test_center_stage_deployment_cadence()
	_test_kusa_wave_progression()
	_test_great_grassland()
	_test_grass_wave_reflection_and_distance()
	_test_great_grassland_concurrent_load()
	_test_comment_lockdown()
	_test_emote_trigger_radius()
	_test_emote_festival()
	_test_all_block_laser()
	_test_listener_assembly()
	_test_pause_and_cleanup()
	_test_visual_fallbacks()
	_test_formal_visuals()
	if failures.is_empty():
		print("STAGE2_REGULAR_EVOLUTIONS_TESTS: PASS")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("STAGE2_REGULAR_EVOLUTIONS_TESTS: FAIL (%d)" % failures.size())
	get_tree().quit(1)


func _test_data_values() -> void:
	var expected: Array = [
		{"id": "full_voice_dome", "behavior": "full_voice_dome", "damage": 9.0, "interval": 0.40, "countKey": "pulseDamage", "count": 15.0},
		{"id": "center_stage", "behavior": "center_stage", "damage": 4.0, "interval": 3.0, "countKey": "maxTicks", "count": 4},
		{"id": "great_grassland", "behavior": "great_grassland", "damage": 12.0, "interval": 1.15, "countKey": "projectileCount", "count": 3},
		{"id": "comment_lockdown", "behavior": "comment_lockdown", "damage": 11.0, "interval": 2.8, "countKey": "projectileCount", "count": 3},
		{"id": "emote_festival", "behavior": "emote_festival", "damage": 18.0, "interval": 3.8, "countKey": "maxActiveCount", "count": 5},
		{"id": "all_block_laser", "behavior": "all_block_laser", "damage": 20.0, "interval": 4.0, "countKey": "laserCount", "count": 3},
		{"id": "listener_assembly", "behavior": "listener_assembly", "damage": 12.0, "interval": 5.0, "countKey": "maxActiveCount", "count": 4}
	]
	for expected_value in expected:
		var spec: Dictionary = expected_value as Dictionary
		var weapon := WeaponSystem.find_weapon(weapons, String(spec["id"]), {})
		_check(not weapon.is_empty(), "%s data exists" % String(spec["id"]), failures)
		_check(String(weapon.get("stage2Behavior", "")) == String(spec["behavior"]), "%s behavior is data-driven" % String(spec["id"]), failures)
		_check(is_equal_approx(float(weapon.get("damage", -1.0)), float(spec["damage"])), "%s damage data" % String(spec["id"]), failures)
		_check(is_equal_approx(float(weapon.get("attackInterval", weapon.get("summonInterval", -1.0))), float(spec["interval"])), "%s interval data" % String(spec["id"]), failures)
		_check(int(weapon.get("maxLevel", 0)) == 1 and bool(weapon.get("isEvolved", false)), "%s is Lv1 evolved data" % String(spec["id"]), failures)
		_check(not bool(weapon.get("evolutionEnabled", true)) and not bool(weapon.get("offerEnabled", true)) and not bool(weapon.get("giftEnabled", true)) and not bool(weapon.get("canAppearAsUpgrade", true)), "%s is not a normal candidate" % String(spec["id"]), failures)
		_check(is_equal_approx(float(weapon.get(String(spec["countKey"]), -1.0)), float(spec["count"])), "%s specialized value" % String(spec["id"]), failures)
	_check(is_equal_approx(float((WeaponSystem.find_weapon(weapons, "center_stage", {}).get("radius", 0.0))), 105.0), "center_stage radius data", failures)
	_check(is_equal_approx(float((WeaponSystem.find_weapon(weapons, "center_stage", {}).get("duration", 0.0))), 2.4), "center_stage duration data", failures)
	_check(is_equal_approx(float((WeaponSystem.find_weapon(weapons, "center_stage", {}).get("hitInterval", 0.0))), 0.6), "center_stage hit interval data", failures)
	_check(not bool(WeaponSystem.find_weapon(weapons, "center_stage", {}).get("intermediateTickHitSe", true)), "center_stage intermediate tick hit SE is disabled", failures)
	_check(is_zero_approx(float(WeaponSystem.find_weapon(weapons, "center_stage", {}).get("finishFlashDuration", -1.0))), "center_stage fullscreen finish flash is disabled", failures)
	var grassland := WeaponSystem.find_weapon(weapons, "great_grassland", {})
	_check(is_equal_approx(float(grassland.get("sideAngleDegrees", 0.0)), 18.0), "great_grassland side angle assumption is explicit", failures)
	_check(is_equal_approx(float(grassland.get("range", 0.0)), 3200.0), "great_grassland maximum distance data", failures)
	_check(is_equal_approx(float(grassland.get("sizeMultiplier", 0.0)), 1.70), "great_grassland size multiplier data", failures)
	_check(int(grassland.get("bounceCount", 0)) == 8, "great_grassland bounce count data", failures)
	_check(is_equal_approx(float(grassland.get("sameEnemyRehit", 0.0)), 0.30), "great_grassland rehit interval remains unchanged", failures)
	_check(is_equal_approx(float((WeaponSystem.find_weapon(weapons, "emote_mine", {}).get("triggerRadius", 0.0))), 48.0), "emote_mine trigger radius data", failures)
	_check(is_equal_approx(float((WeaponSystem.find_weapon(weapons, "emote_festival", {}).get("triggerRadius", 0.0))), 60.0), "emote_festival trigger radius data", failures)
	_check(is_equal_approx(float((WeaponSystem.find_weapon(weapons, "emote_festival", {}).get("chainDamageCoefficient", 0.0))), 0.70), "emote_festival chain coefficient data", failures)
	var listener_weapon := WeaponSystem.find_weapon(weapons, "listener_assembly", {})
	_check(is_equal_approx(float(listener_weapon.get("hitCooldown", 0.0)), 0.70), "listener_assembly hit cooldown data", failures)
	_check(is_equal_approx(float(listener_weapon.get("summonCount", 0.0)), 2.0) and int(listener_weapon.get("maxActiveCount", 0)) == 4, "listener_assembly summon count and cap remain unchanged", failures)
	_check(is_equal_approx(float(listener_weapon.get("duration", 0.0)), 9.0) and is_equal_approx(float(listener_weapon.get("moveSpeed", 0.0)), 195.0) and is_equal_approx(float(listener_weapon.get("searchRange", 0.0)), 680.0), "listener_assembly duration speed and range remain unchanged", failures)
	var distribution: Dictionary = listener_weapon.get("targetDistribution", {}) as Dictionary
	_check(is_equal_approx(float(distribution.get("approachOffset", 0.0)), 24.0) and is_equal_approx(float(distribution.get("approachPhaseStepDegrees", 0.0)), 137.5), "listener_assembly target distribution is data-driven", failures)


func _test_full_voice_dome() -> void:
	var enemy := _enemy(1, Vector2.ZERO, 100.0, 20.0)
	var box := _box(1, Vector2(70.0, 0.0))
	var clearable := {"pos": Vector2(80.0, 0.0), "life": 1.0, "hitRadius": 8.0, "clearableByPlayerWeapon": true}
	var non_clearable := {"pos": Vector2(80.0, 0.0), "life": 1.0, "hitRadius": 8.0, "clearableByPlayerWeapon": false}
	var context := _context("full_voice_dome", [enemy], [box], {}, [], [clearable, non_clearable], 0.1)
	var result := WeaponSystem.update_equipment_weapons(context)
	var generated: Array = result.get("hitFx", []) as Array
	_check(not _find_fx(generated, "full_voice_dome_wave").is_empty() and not _find_fx(generated, "full_voice_dome_pulse").is_empty(), "full_voice_dome normal and pulse FX are independent", failures)
	_check(is_equal_approx(float(enemy.get("hp", 0.0)), 76.0), "full_voice_dome normal plus pulse damage is 9 + 15", failures)
	_check(float(clearable.get("life", 1.0)) <= 0.0 and is_equal_approx(float(non_clearable.get("life", 0.0)), 1.0), "full_voice_dome only clears explicit clearable bullets", failures)
	_check(float(box.get("hp", 1.0)) <= 0.0 and (result.get("destroyedBoxes", []) as Array).size() == 1, "full_voice_dome breaks one box", failures)
	var timers: Dictionary = result.get("timers", {}) as Dictionary
	var state: Dictionary = (timers.get("__stage2WeaponStates", {}) as Dictionary).get("full_voice_dome", {}) as Dictionary
	_check(is_equal_approx(float(timers.get("full_voice_dome", 0.0)), 0.4) and is_equal_approx(float(state.get("pulseTimer", 0.0)), 2.0), "full_voice_dome keeps separate cooldowns", failures)
	var next_result := WeaponSystem.update_equipment_weapons(_context("full_voice_dome", [], [], timers, [], [], 0.4))
	_check(not _find_fx(next_result.get("hitFx", []) as Array, "full_voice_dome_wave").is_empty() and _find_fx(next_result.get("hitFx", []) as Array, "full_voice_dome_pulse").is_empty(), "full_voice_dome normal timer does not force pulse", failures)


func _test_center_stage() -> void:
	var enemy := _enemy(2, Vector2(90.0, 0.0), 100.0, 20.0)
	var nearby := _enemy(3, Vector2(115.0, 0.0), 100.0, 20.0)
	var clearable := {"pos": Vector2(90.0, 0.0), "life": 1.0, "hitRadius": 8.0, "shieldBlockable": true}
	var result := WeaponSystem.update_equipment_weapons(_context("center_stage", [enemy, nearby], [], {}, [], [clearable], 0.0))
	var generated: Array = result.get("hitFx", []) as Array
	var area := _find_fx(generated, "center_stage_area")
	_check(not area.is_empty() and is_equal_approx(float(area.get("radius", 0.0)), 105.0), "center_stage area uses data radius", failures)
	_check(int(area.get("tickCount", 0)) == 1 and not _find_fx(generated, "center_stage_tick").is_empty(), "center_stage starts with tick one", failures)
	_check(bool(result.get("enemyDamaged", false)), "center_stage initial tick still requests hit SE", failures)
	_check(float(clearable.get("life", 1.0)) <= 0.0, "center_stage clears explicit bullet", failures)
	var intermediate_feedback: Dictionary = {}
	generated = WeaponSystem.update_hit_fx(generated, 0.6, [enemy, nearby], [], [clearable], [], [], intermediate_feedback, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(not bool(intermediate_feedback.get("enemyDamaged", false)), "center_stage intermediate tick does not request hit SE", failures)
	_check(String(intermediate_feedback.get("weaponCommentKind", "")) == "spotlight", "center_stage intermediate tick keeps weapon reaction feedback", failures)
	var finish_feedback: Dictionary = {}
	generated = WeaponSystem.update_hit_fx(generated, 1.8, [enemy, nearby], [], [clearable], [], [], finish_feedback, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(is_equal_approx(float(enemy.get("hp", 0.0)), 76.0), "center_stage applies four ticks and one finish for 24 damage", failures)
	_check(_find_fx(generated, "center_stage_area").is_empty() and not _find_fx(generated, "center_stage_finish").is_empty(), "center_stage ends once after finish", failures)
	_check(bool(finish_feedback.get("enemyDamaged", false)), "center_stage finish still requests hit SE", failures)
	_check(is_zero_approx(float(finish_feedback.get("screenFlashDuration", 0.0))), "center_stage finish does not emit fullscreen flash", failures)
	var repeated_feedback: Dictionary = {}
	generated = WeaponSystem.update_hit_fx(generated, 0.1, [enemy, nearby], [], [clearable], [], [], repeated_feedback, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(not bool(repeated_feedback.get("enemyDamaged", false)) and is_zero_approx(float(repeated_feedback.get("screenFlashDuration", 0.0))), "center_stage finish feedback does not repeat", failures)


func _test_center_stage_deployment_cadence() -> void:
	var normal := _run_center_stage_cadence(1.0, 720)
	_check(int(normal.get("areas", -1)) == 4, "center_stage normal 12-second deployment count is four", failures)
	_check(int(normal.get("maxConcurrent", -1)) == 1, "center_stage normal deployment keeps one active area", failures)
	_check(int(normal.get("ticks", -1)) == 16 and int(normal.get("finishes", -1)) == 4, "center_stage normal tick and finish counts remain 16 and four", failures)
	_check(is_equal_approx(float(normal.get("damage", 0.0)), 96.0), "center_stage normal 12-second damage is four complete areas", failures)
	_check((normal.get("generationFrames", []) as Array) == [0, 181, 362, 543], "center_stage normal deployment frames use the 3-second attack interval", failures)
	_check(is_equal_approx(float(normal.get("firstTimer", 0.0)), 3.0), "center_stage resets its deployment timer from attackInterval", failures)
	_check(bool(normal.get("contractValid", false)), "center_stage normal areas keep the independent internal tick contract", failures)

	# This is the same legal interval-rate product used by the existing
	# high-speed path: high_speed_connection Lv5, permanent attack speed Lv5,
	# singing live-heat Lv4 and Lv5.  It is passed through the normal
	# update_equipment_weapons intervalRate field, not an activationInterval override.
	var legal_high_speed_rate := GiftSystemScript.high_speed_connection_interval_rate(5) * 0.90 * 0.95 * 0.92
	var high := _run_center_stage_cadence(legal_high_speed_rate, 720)
	_check(int(high.get("areas", -1)) == 8, "center_stage legal high-speed 12-second deployment count is eight", failures)
	_check(int(high.get("maxConcurrent", -1)) == 2, "center_stage legal high-speed deployment keeps at most two active areas", failures)
	_check(int(high.get("ticks", -1)) == 30 and int(high.get("finishes", -1)) == 7, "center_stage legal high-speed tick and finish counts are 30 and seven", failures)
	_check(is_equal_approx(float(high.get("damage", 0.0)), 176.0), "center_stage legal high-speed 12-second damage follows completed areas", failures)
	_check((high.get("generationFrames", []) as Array) == [0, 94, 188, 282, 376, 470, 564, 658], "center_stage legal high-speed deployment frames use the corrected cadence", failures)
	_check(is_equal_approx(float(high.get("firstTimer", 0.0)), 3.0 * legal_high_speed_rate), "center_stage high-speed timer uses the existing interval correction", failures)
	_check(bool(high.get("contractValid", false)), "center_stage high-speed areas keep unmodified internal timing and damage data", failures)


func _run_center_stage_cadence(interval_rate: float, frame_count: int) -> Dictionary:
	var enemy := _enemy(900, Vector2.ZERO, 100000.0, 20.0)
	var timers: Dictionary = {}
	var active_fx: Array = []
	var generation_frames: Array = []
	var finished_serials: Dictionary = {}
	var areas := 0
	var ticks := 0
	var finishes := 0
	var max_concurrent := 0
	var first_timer := -1.0
	var contract_valid := true
	var step := 1.0 / 60.0
	for frame in range(frame_count):
		var context := _context("center_stage", [enemy], [], timers, active_fx, [], step)
		context["intervalRate"] = interval_rate
		var result := WeaponSystem.update_equipment_weapons(context)
		timers = result.get("timers", timers) as Dictionary
		var generated: Array = result.get("hitFx", []) as Array
		for fx_value in generated:
			var fx: Dictionary = fx_value as Dictionary
			if String(fx.get("kind", "")) != "center_stage_area":
				continue
			areas += 1
			generation_frames.append(frame)
			var serial := areas
			fx["testAreaSerial"] = serial
			var initial_tick_count := int(fx.get("tickCount", 0))
			ticks += initial_tick_count
			if first_timer < 0.0:
				first_timer = float(timers.get("center_stage", -1.0))
			if not is_equal_approx(float(fx.get("duration", -1.0)), 2.4) or not is_equal_approx(float(fx.get("hitInterval", -1.0)), 0.6) or int(fx.get("maxTicks", -1)) != 4 or not is_equal_approx(float(fx.get("tickDamage", -1.0)), 4.0) or not is_equal_approx(float(fx.get("finishDamage", -1.0)), 8.0):
				contract_valid = false
		active_fx.append_array(generated)
		max_concurrent = maxi(max_concurrent, _find_all_fx(active_fx, "center_stage_area").size())
		var before_areas: Dictionary = {}
		var before_ticks: Dictionary = {}
		var before_ages: Dictionary = {}
		var area_refs: Dictionary = {}
		for fx_value in active_fx:
			var fx: Dictionary = fx_value as Dictionary
			if String(fx.get("kind", "")) != "center_stage_area" or not fx.has("testAreaSerial"):
				continue
			var serial := int(fx.get("testAreaSerial", 0))
			before_areas[serial] = true
			before_ticks[serial] = int(fx.get("tickCount", 1))
			before_ages[serial] = float(fx.get("age", 0.0))
			area_refs[serial] = fx
		active_fx = WeaponSystem.update_hit_fx(active_fx, step, [enemy], [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
		var after_areas: Dictionary = {}
		for fx_value in active_fx:
			var fx: Dictionary = fx_value as Dictionary
			if String(fx.get("kind", "")) == "center_stage_area" and fx.has("testAreaSerial"):
				after_areas[int(fx.get("testAreaSerial", 0))] = true
		for serial_value in before_areas.keys():
			var serial := int(serial_value)
			var area_ref: Dictionary = area_refs[serial] as Dictionary
			ticks += maxi(0, int(area_ref.get("tickCount", before_ticks[serial])) - int(before_ticks[serial]))
			if not after_areas.has(serial) and not finished_serials.has(serial) and (bool(area_ref.get("finishApplied", false)) or float(before_ages[serial]) + step + 0.0001 >= 2.4):
				finishes += 1
				finished_serials[serial] = true
	return {
		"areas": areas,
		"ticks": ticks,
		"finishes": finishes,
		"maxConcurrent": max_concurrent,
		"damage": 100000.0 - float(enemy.get("hp", 100000.0)),
		"firstTimer": first_timer,
		"generationFrames": generation_frames,
		"contractValid": contract_valid
	}


func _test_kusa_wave_progression() -> void:
	var level_one_context := _context("kusa_wave", [], [], {}, [], [], 0.0)
	level_one_context["mainWeaponId"] = ""
	level_one_context["playerWeapons"] = [{"id": "kusa_wave", "level": 1}]
	var level_one_result := WeaponSystem.update_equipment_weapons(level_one_context)
	var level_one_wave := _find_fx(level_one_result.get("hitFx", []) as Array, "kusa_wave")
	_check(not level_one_wave.is_empty(), "kusa_wave Lv1 spawns", failures)
	if not level_one_wave.is_empty():
		_check(is_equal_approx(float(level_one_wave.get("damage", 0.0)), 5.0), "kusa_wave Lv1 damage remains five", failures)
		_check(is_equal_approx(Vector2(level_one_wave.get("vel", Vector2.ZERO)).length(), 440.0), "kusa_wave Lv1 speed remains 440", failures)
		_check(is_equal_approx(float(level_one_wave.get("maxDistance", 0.0)), 900.0), "kusa_wave Lv1 maximum distance is 900", failures)
		_check(is_equal_approx(float(level_one_wave.get("sizeScale", 0.0)), 1.0), "kusa_wave Lv1 size remains 1.00", failures)
		_check(int(level_one_wave.get("bouncesLeft", 0)) == 1, "kusa_wave Lv1 has one reflection", failures)
		_check(is_equal_approx(float(level_one_wave.get("maxLife", 0.0)), 900.0 / 440.0 + 0.35), "kusa_wave Lv1 safety life follows distance", failures)

	var level_five_context := _context("kusa_wave", [], [], {}, [], [], 0.0)
	level_five_context["mainWeaponId"] = ""
	level_five_context["playerWeapons"] = [{"id": "kusa_wave", "level": 5}]
	var level_five_result := WeaponSystem.update_equipment_weapons(level_five_context)
	var level_five_wave := _find_fx(level_five_result.get("hitFx", []) as Array, "kusa_wave")
	_check(not level_five_wave.is_empty(), "kusa_wave Lv5 spawns", failures)
	if not level_five_wave.is_empty():
		_check(is_equal_approx(float(level_five_wave.get("damage", 0.0)), 12.0), "kusa_wave Lv5 damage remains twelve", failures)
		_check(is_equal_approx(Vector2(level_five_wave.get("vel", Vector2.ZERO)).length(), 440.0), "kusa_wave Lv5 speed remains 440", failures)
		_check(is_equal_approx(float(level_five_wave.get("maxDistance", 0.0)), 2400.0), "kusa_wave Lv5 maximum distance is 2400", failures)
		_check(is_equal_approx(float(level_five_wave.get("sizeScale", 0.0)), 1.55), "kusa_wave Lv5 size is 1.55", failures)
		_check(int(level_five_wave.get("bouncesLeft", 0)) == 5, "kusa_wave Lv5 has five reflections", failures)
		_check(is_equal_approx(float(level_five_wave.get("maxLife", 0.0)), 2400.0 / 440.0 + 0.35), "kusa_wave Lv5 safety life follows distance", failures)


func _test_great_grassland() -> void:
	var enemy := _enemy(4, Vector2(40.0, 0.0), 100.0, 80.0)
	var box := _box(4, Vector2(40.0, 0.0))
	var result := WeaponSystem.update_equipment_weapons(_context("great_grassland", [enemy], [box], {}, [], [], 0.0))
	var generated: Array = result.get("hitFx", []) as Array
	var waves := _find_all_fx(generated, "great_grassland_wave")
	_check(waves.size() == 3, "great_grassland always spawns three waves", failures)
	if waves.size() == 3:
		var left_wave := waves[0] as Dictionary
		var center_wave := waves[1] as Dictionary
		var right_wave := waves[2] as Dictionary
		_check(is_equal_approx(float(left_wave.get("damage", 0.0)), 12.0), "great_grassland damage is twelve per wave", failures)
		_check(is_equal_approx(float(left_wave.get("sizeScale", 0.0)), 1.70), "great_grassland size multiplier is 1.70", failures)
		_check(is_equal_approx(float(left_wave.get("maxDistance", 0.0)), 3200.0), "great_grassland maximum distance is 3200", failures)
		_check(int(left_wave.get("bouncesLeft", 0)) == 8, "great_grassland bounce count is eight", failures)
		_check(is_equal_approx(Vector2(left_wave.get("vel", Vector2.ZERO)).length(), 440.0), "great_grassland speed remains 440", failures)
		_check(is_equal_approx(float(left_wave.get("maxLife", 0.0)), 3200.0 / 440.0 + 0.35), "great_grassland safety life follows distance", failures)
		_check(is_equal_approx(float((waves[0] as Dictionary).get("sameEnemyRehit", 0.0)), 0.30), "great_grassland rehit cooldown is data-driven", failures)
		_check(absf(absf(rad_to_deg(Vector2(left_wave.get("dir", Vector2.ZERO)).angle_to(Vector2(center_wave.get("dir", Vector2.ZERO))))) - 18.0) < 0.001, "great_grassland left wave keeps the 18 degree spread", failures)
		_check(absf(absf(rad_to_deg(Vector2(center_wave.get("dir", Vector2.ZERO)).angle_to(Vector2(right_wave.get("dir", Vector2.ZERO))))) - 18.0) < 0.001, "great_grassland right wave keeps the 18 degree spread", failures)
	generated = WeaponSystem.update_hit_fx(generated, 0.0, [enemy], [box], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(is_equal_approx(float(enemy.get("hp", 0.0)), 64.0), "great_grassland keeps independent hit memory per wave", failures)
	_check(float(box.get("hp", 1.0)) <= 0.0, "great_grassland breaks a box", failures)


func _test_grass_wave_reflection_and_distance() -> void:
	var normal_context := _context("kusa_wave", [], [], {}, [], [], 0.0)
	normal_context["mainWeaponId"] = ""
	normal_context["playerWeapons"] = [{"id": "kusa_wave", "level": 5}]
	var normal_result := WeaponSystem.update_equipment_weapons(normal_context)
	var normal_wave := _find_fx(normal_result.get("hitFx", []) as Array, "kusa_wave")
	_check(not normal_wave.is_empty(), "kusa_wave Lv5 reflection probe spawns", failures)
	if not normal_wave.is_empty():
		_test_wave_reflection_budget(normal_wave, "kusa_wave", 5)

	var evolved_result := WeaponSystem.update_equipment_weapons(_context("great_grassland", [], [], {}, [], [], 0.0))
	var evolved_wave := _find_fx(evolved_result.get("hitFx", []) as Array, "great_grassland_wave")
	_check(not evolved_wave.is_empty(), "great_grassland reflection probe spawns", failures)
	if evolved_wave.is_empty():
		return
	_test_wave_reflection_budget(evolved_wave, "great_grassland_wave", 8)

	var distance_wave: Dictionary = evolved_wave.duplicate(true)
	distance_wave["pos"] = Vector2.ZERO
	distance_wave["dir"] = Vector2.RIGHT
	distance_wave["vel"] = Vector2.RIGHT * 440.0
	distance_wave["life"] = float(distance_wave.get("maxLife", 0.0))
	distance_wave["distanceTraveled"] = 0.0
	distance_wave["bouncesLeft"] = 8
	var distance_fx: Array = [distance_wave]
	distance_fx = WeaponSystem.update_hit_fx(distance_fx, 0.2, [], [], [], [], [], {}, Rect2(-80.0, -80.0, 160.0, 160.0), [], Vector2.ZERO)
	var reflected_wave := _find_fx(distance_fx, "great_grassland_wave")
	_check(not reflected_wave.is_empty() and int(reflected_wave.get("bouncesLeft", 0)) == 7, "great_grassland consumes one reflection in a narrow arena", failures)
	_check(not reflected_wave.is_empty() and is_equal_approx(float(reflected_wave.get("distanceTraveled", 0.0)), 88.0), "reflection retains traveled distance", failures)
	distance_fx = WeaponSystem.update_hit_fx(distance_fx, 7.0, [], [], [], [], [], {}, Rect2(), [], Vector2.ZERO)
	reflected_wave = _find_fx(distance_fx, "great_grassland_wave")
	_check(not reflected_wave.is_empty() and is_equal_approx(float(reflected_wave.get("distanceTraveled", 0.0)), 3168.0), "distance continues accumulating after reflection", failures)
	distance_fx = WeaponSystem.update_hit_fx(distance_fx, 0.1, [], [], [], [], [], {}, Rect2(), [], Vector2.ZERO)
	_check(_find_fx(distance_fx, "great_grassland_wave").is_empty(), "great_grassland expires when cumulative distance reaches 3200", failures)


func _test_wave_reflection_budget(source_wave: Dictionary, kind: String, expected_reflections: int) -> void:
	var wave: Dictionary = source_wave.duplicate(true)
	wave["pos"] = Vector2.ZERO
	wave["dir"] = Vector2(1.0, 1.0).normalized()
	wave["vel"] = Vector2(1.0, 1.0).normalized() * 440.0
	wave["life"] = float(wave.get("maxLife", 0.0))
	wave["distanceTraveled"] = 0.0
	wave["bouncesLeft"] = expected_reflections
	var active_fx: Array = [wave]
	var reflections := 0
	var previous_bounces := expected_reflections
	for _step in range(40):
		active_fx = WeaponSystem.update_hit_fx(active_fx, 0.2, [], [], [], [], [], {}, Rect2(-80.0, -80.0, 160.0, 160.0), [], Vector2.ZERO)
		var active_wave := _find_fx(active_fx, kind)
		if active_wave.is_empty():
			break
		var current_bounces := int(active_wave.get("bouncesLeft", 0))
		if current_bounces < previous_bounces:
			reflections += previous_bounces - current_bounces
		previous_bounces = current_bounces
		if reflections >= expected_reflections:
			break
	var final_wave := _find_fx(active_fx, kind)
	_check(reflections == expected_reflections, "%s performs all %d configured reflections" % [kind, expected_reflections], failures)
	_check(not final_wave.is_empty() and int(final_wave.get("bouncesLeft", -1)) == 0, "%s remains active after its final allowed reflection" % kind, failures)


func _test_great_grassland_concurrent_load() -> void:
	var stress_enemies: Array = []
	for index in range(120):
		var column := index % 15
		var row := index / 15
		stress_enemies.append(_enemy(1000 + index, Vector2(160.0 + float(column) * 85.0, -300.0 + float(row) * 85.0), 100000.0, 18.0))
	var timers: Dictionary = {}
	var active_fx: Array = []
	var max_concurrent_waves := 0
	var start_usec := Time.get_ticks_usec()
	for _frame in range(480):
		var context := _context("great_grassland", stress_enemies, [], timers, active_fx, [], 1.0 / 60.0)
		var result := WeaponSystem.update_equipment_weapons(context)
		timers = result.get("timers", timers) as Dictionary
		active_fx.append_array(result.get("hitFx", []) as Array)
		active_fx = WeaponSystem.update_hit_fx(active_fx, 1.0 / 60.0, stress_enemies, [], [], [], [], {}, Rect2(), [], Vector2.ZERO)
		max_concurrent_waves = maxi(max_concurrent_waves, _find_all_fx(active_fx, "great_grassland_wave").size())
	var elapsed_msec := float(Time.get_ticks_usec() - start_usec) / 1000.0
	print("GREAT_GRASSLAND_STRESS: 120 enemies / 480 frames / max waves %d / %.2f ms" % [max_concurrent_waves, elapsed_msec])
	_check(max_concurrent_waves >= 18, "great_grassland keeps multiple projectile generations active", failures)
	_check(max_concurrent_waves <= 24, "great_grassland concurrent waves match the configured interval and lifetime", failures)


func _test_comment_lockdown() -> void:
	var weapon := WeaponSystem.find_weapon(weapons, "comment_lockdown", {})
	var regular := _enemy(10, Vector2(24.0, 0.0), 100.0, 20.0)
	var regular_fx := _lockdown_fx(weapon, regular)
	var generated := WeaponSystem.update_hit_fx([regular_fx], 0.0, [regular], [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(is_equal_approx(float(regular.get("hp", 0.0)), 89.0) and is_equal_approx(float(regular.get("stunTimer", 0.0)), 0.5) and is_equal_approx(float(regular.get("slowTimer", 0.0)), 2.0) and is_equal_approx(float(regular.get("slowRate", 0.0)), 0.60), "comment_lockdown regular control uses stun 0.5 and movement 0.40", failures)
	var followup := _find_fx(generated, "comment_lockdown_followup")
	_check(not followup.is_empty() and is_equal_approx(float(followup.get("delay", 0.0)), 1.0) and String(followup.get("weaponId", "")) == "comment_lockdown", "comment_lockdown followup retains owner and delay", failures)
	generated = WeaponSystem.update_hit_fx([followup], 1.0, [regular], [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	generated = WeaponSystem.update_hit_fx(generated, 0.0, [regular], [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(is_equal_approx(float(regular.get("hp", 0.0)), 79.0), "comment_lockdown followup deals once after delay", failures)

	var large := _enemy(11, Vector2(24.0, 0.0), 100.0, 40.0)
	var large_fx := _lockdown_fx(weapon, large)
	WeaponSystem.update_hit_fx([large_fx], 0.0, [large], [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(is_equal_approx(float(large.get("stunTimer", 0.0)), 0.25) and is_equal_approx(float(large.get("slowRate", 0.0)), 0.50), "comment_lockdown large non-boss control uses stun 0.25 and movement 0.50", failures)
	var boss := _enemy(12, Vector2(24.0, 0.0), 100.0, 50.0)
	boss["isBoss"] = true
	boss["bossId"] = "test_boss"
	var boss_fx := _lockdown_fx(weapon, boss)
	WeaponSystem.update_hit_fx([boss_fx], 0.0, [boss], [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(not boss.has("stunTimer") and is_equal_approx(float(boss.get("slowRate", 0.0)), 0.20), "comment_lockdown boss has no stun and uses movement 0.80", failures)
	var cancelled := _enemy(13, Vector2(24.0, 0.0), 100.0, 20.0)
	var cancelled_fx := _lockdown_fx(weapon, cancelled)
	var cancelled_result := WeaponSystem.update_hit_fx([cancelled_fx], 0.0, [cancelled], [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	var cancelled_followup := _find_fx(cancelled_result, "comment_lockdown_followup")
	cancelled["hp"] = 0.0
	cancelled_result = WeaponSystem.update_hit_fx([cancelled_followup], 1.0, [cancelled], [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	cancelled_result = WeaponSystem.update_hit_fx(cancelled_result, 0.0, [cancelled], [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(is_equal_approx(float(cancelled.get("hp", 0.0)), 0.0), "comment_lockdown cancels followup after target death", failures)


func _test_emote_trigger_radius() -> void:
	var normal_weapon := WeaponSystem.find_weapon(weapons, "emote_mine", {})
	var normal_spawned: Array = []
	WeaponSystem._spawn_emote_mines(normal_weapon, 1, 0, Vector2.ZERO, [], normal_spawned, 10.0, 1.0)
	var normal_mine := _find_fx(normal_spawned, "emote_mine")
	_check(is_equal_approx(float(normal_mine.get("triggerRadius", 0.0)), 48.0), "emote_mine spawned trigger radius comes from data", failures)
	var normal_inside := _enemy(18, Vector2(67.0, 0.0), 100.0, 20.0)
	var normal_inside_probe := normal_mine.duplicate(true)
	WeaponSystem.update_emote_mine_damage(normal_inside_probe, [normal_inside], [], [], [], [], [], {})
	_check(is_equal_approx(float(normal_inside.get("hp", 0.0)), 90.0), "emote_mine triggers within the expanded 48px radius", failures)
	var normal_outside := _enemy(19, Vector2(69.0, 0.0), 100.0, 20.0)
	var normal_outside_probe := normal_mine.duplicate(true)
	WeaponSystem.update_emote_mine_damage(normal_outside_probe, [normal_outside], [], [], [], [], [], {})
	_check(is_equal_approx(float(normal_outside.get("hp", 0.0)), 100.0), "emote_mine does not expand beyond its configured trigger radius", failures)

	var festival_result := WeaponSystem.update_equipment_weapons(_context("emote_festival", [], [], {}, [], [], 0.0))
	var festival_mine := _find_fx(festival_result.get("hitFx", []) as Array, "emote_festival_mine")
	_check(is_equal_approx(float(festival_mine.get("triggerRadius", 0.0)), 60.0), "emote_festival spawned trigger radius comes from its own data", failures)
	var festival_mine_pos := Vector2(festival_mine.get("pos", Vector2.ZERO))
	var festival_inside := _enemy(21, festival_mine_pos + Vector2(79.0, 0.0), 100.0, 20.0)
	var festival_inside_probe := festival_mine.duplicate(true)
	WeaponSystem.update_emote_festival_mine_damage(festival_inside_probe, [festival_inside], [], [], [], [], [], [festival_inside_probe], {})
	_check(is_equal_approx(float(festival_inside.get("hp", 0.0)), 82.0), "emote_festival triggers within the expanded 60px radius", failures)
	var festival_outside := _enemy(22, festival_mine_pos + Vector2(81.0, 0.0), 100.0, 20.0)
	var festival_outside_probe := festival_mine.duplicate(true)
	WeaponSystem.update_emote_festival_mine_damage(festival_outside_probe, [festival_outside], [], [], [], [], [], [festival_outside_probe], {})
	_check(is_equal_approx(float(festival_outside.get("hp", 0.0)), 100.0) and not bool(festival_outside_probe.get("exploded", false)), "emote_festival does not expand beyond its configured trigger radius", failures)


func _test_emote_festival() -> void:
	var weapon := WeaponSystem.find_weapon(weapons, "emote_festival", {})
	var result := WeaponSystem.update_equipment_weapons(_context("emote_festival", [], [], {}, [], [], 0.0))
	var generated: Array = result.get("hitFx", []) as Array
	_check(_find_all_fx(generated, "emote_festival_mine").size() == 2, "emote_festival places two mines", failures)
	var enemy := _enemy(20, Vector2.ZERO, 100.0, 20.0)
	var mine_a := _mine("emote_festival:manual_a", Vector2.ZERO, 18.0)
	var mine_b := _mine("emote_festival:manual_b", Vector2(100.0, 0.0), 18.0)
	var chain_fx := WeaponSystem.update_hit_fx([mine_a, mine_b], 0.0, [enemy], [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(is_equal_approx(float(enemy.get("hp", 0.0)), 82.0), "emote_festival first mine deals 18", failures)
	var queued := _find_fx(chain_fx, "emote_festival_mine")
	_check(bool(queued.get("chainQueued", false)) and bool(queued.get("chainTriggered", false)) and is_equal_approx(float(queued.get("damage", 0.0)), 12.6), "emote_festival queues one delayed chain at coefficient 0.70", failures)
	chain_fx = WeaponSystem.update_hit_fx(chain_fx, 0.01, [enemy], [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	chain_fx = WeaponSystem.update_hit_fx(chain_fx, 0.0, [enemy], [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(is_equal_approx(float(enemy.get("hp", 0.0)), 69.4), "emote_festival delayed chain explodes once", failures)
	_check(_find_fx(chain_fx, "emote_festival_mine").is_empty(), "emote_festival prevents cycle and double explosion", failures)
	var active: Array = []
	for index in range(4):
		active.append(_mine("emote_festival:active_%d" % index, Vector2(300.0 + index * 20.0, 0.0), 18.0))
	var capped := WeaponSystem.update_equipment_weapons(_context("emote_festival", [], [], {}, active, [], 0.0))
	_check(_find_all_fx(capped.get("hitFx", []) as Array, "emote_festival_mine").size() == 1, "emote_festival counts active and pending mines toward five", failures)
	_check(not weapon.is_empty(), "emote_festival definition remains available for cap test", failures)


func _test_all_block_laser() -> void:
	var enemy := _enemy(30, Vector2(120.0, 0.0), 100.0, 20.0)
	var box := _box(30, Vector2(120.0, 0.0))
	var clearable := {"pos": Vector2(120.0, 0.0), "life": 1.0, "hitRadius": 8.0, "clearableByPlayerWeapon": true}
	var non_clearable := {"pos": Vector2(120.0, 0.0), "life": 1.0, "hitRadius": 8.0, "clearableByPlayerWeapon": false}
	var result := WeaponSystem.update_equipment_weapons(_context("all_block_laser", [enemy], [box], {}, [], [clearable, non_clearable], 0.0))
	var generated: Array = result.get("hitFx", []) as Array
	_check(_find_all_fx(generated, "all_block_laser").size() == 3, "all_block_laser fires three fixed lasers", failures)
	_check(is_equal_approx(float(enemy.get("hp", 0.0)), 40.0), "all_block_laser allows three hits on one large target", failures)
	_check(float(clearable.get("life", 1.0)) <= 0.0 and is_equal_approx(float(non_clearable.get("life", 0.0)), 1.0), "all_block_laser only clears explicit clearable bullets", failures)
	_check(float(box.get("hp", 1.0)) <= 0.0, "all_block_laser breaks a box once", failures)


func _test_listener_assembly() -> void:
	var enemy := _enemy(40, Vector2(32.0, 0.0), 100.0, 20.0)
	var result := WeaponSystem.update_equipment_weapons(_context("listener_assembly", [enemy], [], {}, [], [], 0.0))
	var generated: Array = result.get("hitFx", []) as Array
	var summons := _find_all_fx(generated, "listener_assembly")
	_check(summons.size() == 2, "listener_assembly summons two", failures)
	if not summons.is_empty():
		_check(is_equal_approx(float((summons[0] as Dictionary).get("damage", 0.0)), 12.0) and is_equal_approx(float((summons[0] as Dictionary).get("moveSpeed", 0.0)), 195.0) and is_equal_approx(float((summons[0] as Dictionary).get("hitCooldown", 0.0)), 0.70), "listener_assembly uses data damage speed and cooldown", failures)
	generated = WeaponSystem.update_hit_fx(generated, 0.0, [enemy], [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(is_equal_approx(float(enemy.get("hp", 0.0)), 76.0), "listener_assembly two summons can hit independently", failures)
	generated = WeaponSystem.update_hit_fx(generated, 0.1, [enemy], [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(is_equal_approx(float(enemy.get("hp", 0.0)), 76.0), "listener_assembly respects 0.70 hit cooldown", failures)
	var serial_set: Dictionary = {}
	var approach_phases: Dictionary = {}
	var motion_phases: Dictionary = {}
	for summon_value in summons:
		var summon: Dictionary = summon_value as Dictionary
		serial_set[int(summon.get("unitSerial", -1))] = true
		approach_phases[float(summon.get("approachPhase", 0.0))] = true
		motion_phases[float(summon.get("motionPhase", 0.0))] = true
	_check(serial_set.size() == 2 and approach_phases.size() == 2 and motion_phases.size() == 2, "listener_assembly units receive distinct stable serials and phases", failures)

	var three_enemies: Array = [_enemy(41, Vector2(140.0, 0.0), 100.0, 20.0), _enemy(42, Vector2(0.0, 140.0), 100.0, 20.0), _enemy(43, Vector2(-140.0, 0.0), 100.0, 20.0)]
	var two_listeners: Array = [_listener_assembly_fx(1), _listener_assembly_fx(2)]
	two_listeners = WeaponSystem.update_hit_fx(two_listeners, 0.05, three_enemies, [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(_listener_target_counts(_find_all_fx(two_listeners, "listener_assembly")).size() == 2, "listener_assembly distributes two units across different targets", failures)

	var four_enemies: Array = [_enemy(44, Vector2(140.0, 0.0), 100.0, 20.0), _enemy(45, Vector2(0.0, 140.0), 100.0, 20.0), _enemy(46, Vector2(-140.0, 0.0), 100.0, 20.0), _enemy(47, Vector2(0.0, -140.0), 100.0, 20.0)]
	var four_listeners: Array = []
	for index in range(4):
		four_listeners.append(_listener_assembly_fx(index + 1))
	four_listeners = WeaponSystem.update_hit_fx(four_listeners, 0.05, four_enemies, [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(_listener_target_counts(_find_all_fx(four_listeners, "listener_assembly")).size() == 4, "listener_assembly gives four units four distinct targets", failures)

	var two_target_enemies: Array = [_enemy(48, Vector2(140.0, 0.0), 100.0, 20.0), _enemy(49, Vector2(-140.0, 0.0), 100.0, 20.0)]
	var four_on_two: Array = []
	for index in range(4):
		four_on_two.append(_listener_assembly_fx(index + 1))
	four_on_two = WeaponSystem.update_hit_fx(four_on_two, 0.05, two_target_enemies, [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	var four_on_two_counts := _listener_target_counts(_find_all_fx(four_on_two, "listener_assembly"))
	_check(four_on_two_counts.size() == 2 and _count_spread_is_balanced(four_on_two_counts), "four listener units split two targets evenly", failures)

	var three_on_two: Array = [_listener_assembly_fx(1), _listener_assembly_fx(2), _listener_assembly_fx(3)]
	three_on_two = WeaponSystem.update_hit_fx(three_on_two, 0.05, two_target_enemies, [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	var three_on_two_counts := _listener_target_counts(_find_all_fx(three_on_two, "listener_assembly"))
	_check(three_on_two_counts.size() == 2 and _count_spread_is_balanced(three_on_two_counts), "three listener units keep two target counts within one", failures)

	var death_enemies: Array = [_enemy(50, Vector2(140.0, 0.0), 100.0, 20.0), _enemy(51, Vector2(-140.0, 0.0), 100.0, 20.0)]
	var death_listeners: Array = [_listener_assembly_fx(1), _listener_assembly_fx(2)]
	death_listeners = WeaponSystem.update_hit_fx(death_listeners, 0.05, death_enemies, [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	death_enemies[0]["hp"] = 0.0
	death_listeners = WeaponSystem.update_hit_fx(death_listeners, 0.0, death_enemies, [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	var remaining_target := _stage2_test_token(death_enemies[1] as Dictionary)
	var reassigned := true
	for summon_value in _find_all_fx(death_listeners, "listener_assembly"):
		if String((summon_value as Dictionary).get("targetToken", "")) != remaining_target:
			reassigned = false
	_check(reassigned, "listener_assembly reassigns safely after target defeat", failures)

	var range_enemies: Array = [_enemy(52, Vector2(80.0, 0.0), 100.0, 20.0), _enemy(53, Vector2(300.0, 0.0), 100.0, 20.0)]
	var range_limited: Array = [_listener_assembly_fx(1, Vector2.ZERO, 100.0)]
	range_limited = WeaponSystem.update_hit_fx(range_limited, 0.0, range_enemies, [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(String((_find_fx(range_limited, "listener_assembly")).get("targetToken", "")) == _stage2_test_token(range_enemies[0] as Dictionary), "listener_assembly does not reserve an out-of-range enemy", failures)

	var deterministic_base: Array = [_listener_assembly_fx(1), _listener_assembly_fx(2), _listener_assembly_fx(3)]
	var deterministic_a: Array = deterministic_base.duplicate(true)
	var deterministic_b: Array = deterministic_base.duplicate(true)
	var deterministic_enemies_a: Array = four_enemies.duplicate(true)
	var deterministic_enemies_b: Array = four_enemies.duplicate(true)
	deterministic_a = WeaponSystem.update_hit_fx(deterministic_a, 0.05, deterministic_enemies_a, [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	deterministic_b = WeaponSystem.update_hit_fx(deterministic_b, 0.05, deterministic_enemies_b, [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	var deterministic_match := true
	for index in range(3):
		var first: Dictionary = _find_all_fx(deterministic_a, "listener_assembly")[index] as Dictionary
		var second: Dictionary = _find_all_fx(deterministic_b, "listener_assembly")[index] as Dictionary
		if String(first.get("targetToken", "")) != String(second.get("targetToken", "")) or Vector2(first.get("pos", Vector2.ZERO)) != Vector2(second.get("pos", Vector2.ZERO)) or Vector2(first.get("dir", Vector2.RIGHT)) != Vector2(second.get("dir", Vector2.RIGHT)):
			deterministic_match = false
	_check(deterministic_match, "listener_assembly target allocation is deterministic", failures)

	var one_enemy := _enemy(54, Vector2(32.0, 0.0), 100.0, 20.0)
	var two_same_target: Array = [_listener_assembly_fx(1), _listener_assembly_fx(2)]
	two_same_target = WeaponSystem.update_hit_fx(two_same_target, 0.0, [one_enemy], [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(is_equal_approx(float(one_enemy.get("hp", 0.0)), 76.0) and _listener_target_counts(_find_all_fx(two_same_target, "listener_assembly")).size() == 1, "one enemy remains shared attack target and takes two hits", failures)

	var path_enemy := _enemy(55, Vector2(220.0, 0.0), 100.0, 20.0)
	var separated_path: Array = [_listener_assembly_fx(1), _listener_assembly_fx(2)]
	separated_path = WeaponSystem.update_hit_fx(separated_path, 0.20, [path_enemy], [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	var path_a: Dictionary = _find_all_fx(separated_path, "listener_assembly")[0] as Dictionary
	var path_b: Dictionary = _find_all_fx(separated_path, "listener_assembly")[1] as Dictionary
	_check(Vector2(path_a.get("pos", Vector2.ZERO)) != Vector2(path_b.get("pos", Vector2.ZERO)) and Vector2(path_a.get("dir", Vector2.RIGHT)) != Vector2(path_b.get("dir", Vector2.RIGHT)), "same-target listener units use different approach paths", failures)

	var normal_enemy := _enemy(56, Vector2(220.0, 0.0), 100.0, 20.0)
	var normal_listeners: Array = [
		{"kind": "listener_summon", "owner": "listener_summon", "weaponId": "listener_summon", "pos": Vector2.ZERO, "dir": Vector2.RIGHT, "life": 2.0, "maxLife": 2.0, "moveSpeed": 195.0, "searchRange": 680.0, "hitRadius": 18.0, "hitTimer": 0.0, "hitCooldown": 0.70},
		{"kind": "listener_summon", "owner": "listener_summon", "weaponId": "listener_summon", "pos": Vector2.ZERO, "dir": Vector2.RIGHT, "life": 2.0, "maxLife": 2.0, "moveSpeed": 195.0, "searchRange": 680.0, "hitRadius": 18.0, "hitTimer": 0.0, "hitCooldown": 0.70}
	]
	normal_listeners = WeaponSystem.update_hit_fx(normal_listeners, 0.10, [normal_enemy], [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	var normal_a: Dictionary = _find_all_fx(normal_listeners, "listener_summon")[0] as Dictionary
	var normal_b: Dictionary = _find_all_fx(normal_listeners, "listener_summon")[1] as Dictionary
	_check(Vector2(normal_a.get("pos", Vector2.ZERO)) == Vector2(normal_b.get("pos", Vector2.ZERO)) and Vector2(normal_a.get("dir", Vector2.RIGHT)) == Vector2(normal_b.get("dir", Vector2.RIGHT)), "normal listener_summon keeps individual nearest-target behavior", failures)
	var active: Array = []
	for index in range(4):
		active.append({"kind": "listener_assembly", "owner": "listener_assembly", "weaponId": "listener_assembly", "pos": Vector2(300.0 + index * 20.0, 0.0), "life": 1.0})
	var capped := WeaponSystem.update_equipment_weapons(_context("listener_assembly", [], [], {}, active, [], 0.0))
	_check((capped.get("hitFx", []) as Array).is_empty(), "listener_assembly enforces max active four", failures)


func _test_pause_and_cleanup() -> void:
	var paused := WeaponSystem.update_equipment_weapons(_context("full_voice_dome", [], [], {}, [], [], 0.1, true))
	_check((paused.get("hitFx", []) as Array).is_empty() and is_equal_approx(float((paused.get("timers", {}) as Dictionary).get("full_voice_dome", 0.0)), 0.0), "pause disables new evolved attacks and timers", failures)
	var target := TestTargetScript.new()
	target.hit_fx = []
	for weapon_id in ["full_voice_dome", "center_stage", "great_grassland", "comment_lockdown", "emote_festival", "all_block_laser", "listener_assembly"]:
		target.hit_fx.append({"kind": "runtime_probe", "owner": weapon_id, "weaponId": weapon_id, "life": 1.0})
	target.equipment_weapon_timers = {"full_voice_dome": 1.0, "center_stage": 1.0, "__stage2WeaponStates": {"emote_festival": {"mineSerial": 3}, "listener_assembly": {"listenerUnitSerial": 4}}}
	WeaponSystem.cleanup_runtime_for_weapon(target, "", "", "test_cleanup")
	_check((target.hit_fx as Array).is_empty(), "cleanup removes all seven evolved runtime owners", failures)
	var cleanup_timers: Dictionary = target.equipment_weapon_timers as Dictionary
	var cleanup_states: Dictionary = cleanup_timers.get("__stage2WeaponStates", {}) as Dictionary
	_check(not cleanup_timers.has("full_voice_dome") and not cleanup_timers.has("center_stage") and not cleanup_states.has("listener_assembly"), "cleanup clears evolved timers and listener serial state", failures)


func _test_visual_fallbacks() -> void:
	var probes: Array = [
		{"kind": "full_voice_dome_wave", "radius": 145.0, "hitCount": 1},
		{"kind": "center_stage_area", "radius": 105.0},
		{"kind": "great_grassland_wave", "dir": Vector2.RIGHT, "maxDistance": 3200.0},
		{"kind": "comment_lockdown_projectile", "dir": Vector2.RIGHT},
		{"kind": "emote_festival_mine", "radius": 160.0},
		{"kind": "all_block_laser", "dir": Vector2.RIGHT, "range": 875.0, "width": 60.0},
		{"kind": "listener_assembly", "dir": Vector2.RIGHT},
		{"kind": "stage2_bullet_clear"}
	]
	for probe_value in probes:
		var probe: Dictionary = probe_value as Dictionary
		probe["pos"] = Vector2.ZERO
		probe["life"] = 0.2
		probe["maxLife"] = 0.2
		var visual_items := DrawDataSystem.hit_fx_draw_data([probe])
		_check(not visual_items.is_empty(), "%s has inherited/procedural visual fallback" % String(probe["kind"]), failures)


func _test_formal_visuals() -> void:
	var expected_paths: Array[String] = [
		"res://assets/weapons/full_voice_dome/full_voice_dome_icon.png",
		"res://assets/weapons/full_voice_dome/full_voice_dome_wave.png",
		"res://assets/weapons/full_voice_dome/full_voice_dome_power_wave.png",
		"res://assets/weapons/center_stage/center_stage_icon.png",
		"res://assets/weapons/center_stage/center_stage_light.png",
		"res://assets/weapons/center_stage/center_stage_floor.png",
		"res://assets/weapons/center_stage/center_stage_finish.png",
		"res://assets/weapons/great_grassland/grass_unavoidable_icon.png",
		"res://assets/weapons/great_grassland/grass_unavoidable_wave.png",
		"res://assets/weapons/comment_lockdown/comment_lockdown_icon.png",
		"res://assets/weapons/comment_lockdown/comment_lockdown_projectile.png",
		"res://assets/weapons/comment_lockdown/comment_lockdown_bind.png",
		"res://assets/weapons/comment_lockdown/comment_lockdown_ng_hit.png",
		"res://assets/weapons/emote_festival/emote_festival_icon.png",
		"res://assets/weapons/emote_festival/emote_festival_mine.png",
		"res://assets/weapons/emote_festival/emote_festival_explosion.png",
		"res://assets/weapons/emote_festival/emote_festival_chain.png",
		"res://assets/weapons/all_block_laser/all_block_laser_icon.png",
		"res://assets/weapons/all_block_laser/all_block_laser_beam.png",
		"res://assets/weapons/all_block_laser/all_block_laser_flash.png",
		"res://assets/weapons/listener_assembly/listener_gathering_icon.png",
		"res://assets/weapons/listener_assembly/listener_gathering_unit.png",
		"res://assets/weapons/listener_assembly/listener_gathering_spawn.png"
	]
	for path in expected_paths:
		_check(FileAccess.file_exists(path), "formal image exists: %s" % path, failures)
		_check(TextureCacheSystemScript.load_png_texture(texture_cache, path) != null, "formal image loads: %s" % path, failures)
	for icon_id in ["full_voice_dome", "center_stage", "great_grassland", "comment_lockdown", "emote_festival", "all_block_laser", "listener_assembly"]:
		var weapon := WeaponSystem.find_weapon(weapons, icon_id, {})
		var icon_path := String(weapon.get("iconPath", ""))
		var icon_texture := TextureCacheSystemScript.load_png_texture(texture_cache, icon_path)
		_check(icon_texture != null and is_equal_approx(icon_texture.get_size().x, icon_texture.get_size().y), "%s formal icon is square and loadable" % icon_id, failures)
		var visuals: Dictionary = weapon.get("visuals", {}) as Dictionary
		_check(not visuals.is_empty(), "%s has formal visuals dictionary" % icon_id, failures)
		for role_value in visuals.values():
			var role: Dictionary = role_value as Dictionary
			var path := String(role.get("path", ""))
			_check(path != "" and FileAccess.file_exists(path), "%s visual path registered" % icon_id, failures)

	var full_visuals: Dictionary = (WeaponSystem.find_weapon(weapons, "full_voice_dome", {}).get("visuals", {}) as Dictionary)
	var full_wave := _draw_visual({"kind": "full_voice_dome_wave", "pos": Vector2.ZERO, "life": 0.42, "maxLife": 0.42, "radius": 145.0, "visuals": full_visuals})
	var full_power := _draw_visual({"kind": "full_voice_dome_pulse", "pos": Vector2.ZERO, "life": 0.48, "maxLife": 0.48, "radius": 180.0, "visuals": full_visuals})
	_check(not _find_layer(full_wave, "wave").is_empty() and not _find_layer(full_power, "powerWave").is_empty(), "full voice normal and power waves use separate formal images", failures)
	_check(String((_find_layer(full_wave, "wave").get("path", ""))) != String((_find_layer(full_power, "powerWave").get("path", ""))), "full voice wave paths remain distinct", failures)

	var center_visuals: Dictionary = WeaponSystem.find_weapon(weapons, "center_stage", {}).get("visuals", {}) as Dictionary
	var center_area := _draw_visual({"kind": "center_stage_area", "pos": Vector2.ZERO, "life": 2.4, "maxLife": 2.4, "radius": 105.0, "visuals": center_visuals})
	_check(bool(center_area.get("fieldLayer", false)) and String(_find_layer(center_area, "areaFloor").get("drawLayer", "")) == "back" and String(_find_layer(center_area, "areaLight").get("drawLayer", "")) == "front", "center stage area keeps floor below and light above", failures)
	var center_finish := _draw_visual({"kind": "center_stage_finish", "pos": Vector2.ZERO, "life": 0.30, "maxLife": 0.30, "radius": 105.0, "visuals": center_visuals})
	_check(not _find_layer(center_finish, "finish").is_empty(), "center stage finish uses one formal image", failures)

	var grass_visuals: Dictionary = WeaponSystem.find_weapon(weapons, "great_grassland", {}).get("visuals", {}) as Dictionary
	var grass := _draw_visual({"kind": "great_grassland_wave", "pos": Vector2.ZERO, "dir": Vector2.DOWN, "life": 1.0, "maxLife": 1.0, "sizeScale": 1.70, "attackAreaRate": 1.0, "maxDistance": 3200.0, "visuals": grass_visuals})
	_check(not _find_layer(grass, "wave").is_empty() and is_equal_approx(float(_find_layer(grass, "wave").get("rotation", 0.0)), PI * 0.5), "grass formal wave follows reflected direction", failures)

	var lockdown_visuals: Dictionary = WeaponSystem.find_weapon(weapons, "comment_lockdown", {}).get("visuals", {}) as Dictionary
	var projectile := _draw_visual({"kind": "comment_lockdown_projectile", "pos": Vector2.ZERO, "dir": Vector2.DOWN, "life": 0.45, "maxLife": 0.45, "visuals": lockdown_visuals})
	_check(not _find_layer(projectile, "projectile").is_empty() and is_equal_approx(float(_find_layer(projectile, "projectile").get("rotation", 0.0)), PI * 0.5), "lockdown projectile rotates with movement", failures)
	var bind := _draw_visual({"kind": "comment_lockdown_bind", "pos": Vector2.ZERO, "stunActive": false, "life": 1.0, "maxLife": 2.0, "visuals": lockdown_visuals})
	_check(not _find_layer(bind, "bind").is_empty() and is_equal_approx(float(bind.get("bindStunActive", true)), 0.0), "lockdown bind has a weak slow-state visual", failures)
	var ng_hit := _draw_visual({"kind": "comment_lockdown_followup_hit", "pos": Vector2.ZERO, "life": 0.22, "maxLife": 0.22, "visuals": lockdown_visuals})
	_check(not _find_layer(ng_hit, "ngHit").is_empty(), "lockdown NG image is reserved for followup hit", failures)

	var emote_visuals: Dictionary = WeaponSystem.find_weapon(weapons, "emote_festival", {}).get("visuals", {}) as Dictionary
	var mine := _draw_visual({"kind": "emote_festival_mine", "pos": Vector2.ZERO, "life": 12.0, "maxLife": 12.0, "radius": 160.0, "visuals": emote_visuals})
	_check(bool(mine.get("fieldLayer", false)) and not _find_layer(mine, "mine").is_empty(), "emote mine uses formal field image", failures)
	var burst := _draw_visual({"kind": "emote_festival_burst", "pos": Vector2.ZERO, "life": 0.28, "maxLife": 0.28, "radius": 160.0, "visuals": emote_visuals})
	_check(not _find_layer(burst, "explosion").is_empty(), "emote explosion uses formal image", failures)
	var chain := _draw_visual({"kind": "emote_festival_chain", "pos": Vector2(50.0, 0.0), "from": Vector2.ZERO, "to": Vector2(100.0, 100.0), "life": 0.28, "maxLife": 0.28, "visuals": emote_visuals})
	var chain_layer := _find_layer(chain, "chain")
	_check(not chain_layer.is_empty() and is_equal_approx(float((chain_layer.get("size", Vector2.ZERO) as Vector2).x), sqrt(20000.0)) and is_equal_approx(float((chain_layer.get("size", Vector2.ZERO) as Vector2).y), 40.0), "emote chain stretches only along its link", failures)

	var laser_visuals: Dictionary = WeaponSystem.find_weapon(weapons, "all_block_laser", {}).get("visuals", {}) as Dictionary
	var laser := _draw_visual({"kind": "all_block_laser", "pos": Vector2.ZERO, "dir": Vector2.RIGHT, "hit": Vector2(500.0, 0.0), "life": 0.25, "maxLife": 0.25, "range": 875.0, "width": 60.0, "visuals": laser_visuals})
	_check(is_equal_approx(float((_find_layer(laser, "beam").get("size", Vector2.ZERO) as Vector2).x), 500.0), "laser beam follows actual hit length", failures)
	var laser_flash := _draw_visual({"kind": "all_block_laser_flash", "pos": Vector2.ZERO, "life": 0.18, "maxLife": 0.18, "visuals": laser_visuals})
	_check(not _find_layer(laser_flash, "flash").is_empty(), "laser volley has one origin flash role", failures)

	var listener_visuals: Dictionary = WeaponSystem.find_weapon(weapons, "listener_assembly", {}).get("visuals", {}) as Dictionary
	var listener := _draw_visual({"kind": "listener_assembly", "pos": Vector2.ZERO, "dir": Vector2.LEFT, "life": 9.0, "maxLife": 9.0, "attackAreaRate": 1.0, "visuals": listener_visuals})
	var listener_spawn := _draw_visual({"kind": "listener_assembly_spawn", "pos": Vector2(32.0, 0.0), "dir": Vector2.LEFT, "life": 0.28, "maxLife": 0.28, "visuals": listener_visuals})
	_check(not _find_layer(listener, "unit").is_empty() and bool(_find_layer(listener, "unit").get("flipX", false)), "listener unit follows left-facing direction", failures)
	_check(not _find_layer(listener_spawn, "spawn").is_empty(), "listener spawn image is emitted at summon position", failures)
	var listener_phase_zero := _draw_visual({"kind": "listener_assembly", "pos": Vector2.ZERO, "dir": Vector2.RIGHT, "life": 1.0, "maxLife": 9.0, "motionPhase": 0.0, "visuals": listener_visuals})
	var listener_phase_offset := _draw_visual({"kind": "listener_assembly", "pos": Vector2.ZERO, "dir": Vector2.RIGHT, "life": 1.0, "maxLife": 9.0, "motionPhase": PI, "visuals": listener_visuals})
	var phase_zero_layer := _find_layer(listener_phase_zero, "unit")
	var phase_offset_layer := _find_layer(listener_phase_offset, "unit")
	_check(not phase_zero_layer.is_empty() and not phase_offset_layer.is_empty() and Vector2(phase_zero_layer.get("pos", Vector2.ZERO)) != Vector2(phase_offset_layer.get("pos", Vector2.ZERO)), "listener formal image bob uses motion phase", failures)
	var listener_phase_missing := _draw_visual({"kind": "listener_assembly", "pos": Vector2.ZERO, "dir": Vector2.RIGHT, "life": 1.0, "maxLife": 9.0, "visuals": listener_visuals})
	_check(Vector2(_find_layer(listener_phase_missing, "unit").get("pos", Vector2.ZERO)) == Vector2(phase_zero_layer.get("pos", Vector2.ZERO)), "listener missing motion phase falls back to zero", failures)

	var missing_visual := _draw_visual({"kind": "full_voice_dome_wave", "pos": Vector2.ZERO, "life": 0.2, "maxLife": 0.42, "radius": 145.0, "visuals": {"wave": {"path": "res://assets/weapons/missing/formal.png", "size": [10, 10]}}})
	_check(not missing_visual.is_empty() and not DrawDataSystem.hit_fx_procedural_parts(missing_visual, {}, {}).is_empty(), "missing formal image keeps draw-data fallback without crashing", failures)
	var incomplete_generic := _draw_visual({"kind": "legacy_generic_hit", "pos": Vector2.ZERO, "life": 0.18})
	_check(not incomplete_generic.is_empty(), "generic hit FX without direction uses a safe visual fallback", failures)


func _draw_visual(fx: Dictionary) -> Dictionary:
	var items := DrawDataSystem.hit_fx_draw_data([fx])
	return items[0] as Dictionary if not items.is_empty() else {}


func _find_layer(data: Dictionary, role: String) -> Dictionary:
	for layer_value in (data.get("imageLayers", []) as Array):
		var layer: Dictionary = layer_value as Dictionary
		if String(layer.get("role", "")) == role:
			return layer
	return {}


func _context(weapon_id: String, enemies: Array, destructibles: Array, timers: Dictionary, active_fx: Array, enemy_bullets: Array, delta: float, paused: bool = false) -> Dictionary:
	var weapon := WeaponSystem.find_weapon(weapons, weapon_id, {})
	var entry := {"id": weapon_id, "level": 1, "isEvolved": true, "baseWeaponId": String(weapon.get("baseWeaponId", ""))}
	return {
		"delta": delta,
		"weaponData": weapons,
		"playerWeapons": [entry],
		"mainWeaponId": weapon_id,
		"timers": timers,
		"playerPos": Vector2.ZERO,
		"facingDir": Vector2.RIGHT,
		"playerVel": Vector2.ZERO,
		"lastMoveDirection": Vector2.RIGHT,
		"manualAimDirection": Vector2.ZERO,
		"moveInput": Vector2.ZERO,
		"enemies": enemies,
		"destructibles": destructibles,
		"enemyBullets": enemy_bullets,
		"activeFx": active_fx,
		"damageRate": 1.0,
		"rangeRate": 1.0,
		"intervalRate": 1.0,
		"attackAreaRate": 1.0,
		"bulletSupportLevel": 0,
		"shortRange": false,
		"shortRangeRate": 1.0,
		"knockback": 0.0,
		"normalWeaponsDisabled": paused,
		"weaponMute": false
	}


func _lockdown_fx(weapon: Dictionary, enemy: Dictionary) -> Dictionary:
	return {
		"kind": "comment_lockdown_projectile",
		"owner": "comment_lockdown",
		"weaponId": "comment_lockdown",
		"pos": Vector2(enemy.get("pos", Vector2.ZERO)),
		"dir": Vector2.RIGHT,
		"life": 1.0,
		"maxLife": 1.0,
		"damage": 11.0,
		"hitRadius": 12.0,
		"followupDamage": 10.0,
		"followupDelay": 1.0,
		"weapon": weapon.duplicate(true)
	}


func _mine(serial: String, pos: Vector2, damage: float) -> Dictionary:
	var weapon := WeaponSystem.find_weapon(weapons, "emote_festival", {})
	return {
		"kind": "emote_festival_mine",
		"owner": "emote_festival",
		"weaponId": "emote_festival",
		"mineSerial": serial,
		"pos": pos,
		"life": 12.0,
		"maxLife": 12.0,
		"damage": damage,
		"radius": 160.0,
		"triggerRadius": float(weapon.get("triggerRadius", 28.0)),
		"chainRadius": 200.0,
		"chainDamageCoefficient": 0.70,
		"chainDelay": 0.01,
		"chainQueued": false,
		"chainTriggered": false,
		"exploded": false
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


func _listener_assembly_fx(serial: int, pos: Vector2 = Vector2.ZERO, search_range: float = 680.0) -> Dictionary:
	var weapon := WeaponSystem.find_weapon(weapons, "listener_assembly", {})
	var distribution: Dictionary = weapon.get("targetDistribution", {}) as Dictionary
	return {
		"kind": "listener_assembly",
		"owner": "listener_assembly",
		"weaponId": "listener_assembly",
		"pos": pos,
		"dir": Vector2.RIGHT,
		"life": 9.0,
		"maxLife": 9.0,
		"damage": 12.0,
		"moveSpeed": 195.0,
		"searchRange": search_range,
		"hitRadius": 18.0,
		"hitCooldown": 0.70,
		"hitTimer": 0.0,
		"unitSerial": serial,
		"approachPhase": fposmod(deg_to_rad(float(distribution.get("approachPhaseStepDegrees", 137.5))) * float(serial - 1), TAU),
		"motionPhase": fposmod(float(distribution.get("motionPhaseStepRadians", 2.35)) * float(serial - 1), TAU),
		"targetDistribution": distribution.duplicate(true)
	}


func _listener_target_counts(summons: Array) -> Dictionary:
	var counts: Dictionary = {}
	for summon_value in summons:
		var token := String((summon_value as Dictionary).get("targetToken", ""))
		if token == "":
			continue
		counts[token] = int(counts.get(token, 0)) + 1
	return counts


func _count_spread_is_balanced(counts: Dictionary) -> bool:
	if counts.is_empty():
		return false
	var minimum := 1000000
	var maximum := -1
	for value in counts.values():
		var count := int(value)
		minimum = mini(minimum, count)
		maximum = maxi(maximum, count)
	return maximum - minimum <= 1


func _stage2_test_token(enemy: Dictionary) -> String:
	return String(enemy.get("spawnToken", ""))


func _find_fx(items: Array, kind: String) -> Dictionary:
	for item_value in items:
		var item: Dictionary = item_value as Dictionary
		if String(item.get("kind", "")) == kind:
			return item
	return {}


func _find_all_fx(items: Array, kind: String) -> Array:
	var result: Array = []
	for item_value in items:
		var item: Dictionary = item_value as Dictionary
		if String(item.get("kind", "")) == kind:
			result.append(item)
	return result


func _check(condition: bool, message: String, output: Array[String]) -> void:
	if not condition:
		output.append(message)
