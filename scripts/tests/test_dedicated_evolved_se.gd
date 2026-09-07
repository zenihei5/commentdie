extends "res://scripts/tests/test_evolved_weapon_activation_se.gd"

const RING_SE := "res://assets/audio/maro_comment_ring_activate.mp3"
const FINISH_SE := "res://assets/audio/fansa_climax_finisher.mp3"
const OLD_COMBO_3 := "res://assets/audio/fansa_baton_combo_3.mp3"


func _run() -> void:
	weapons = JSON.parse_string(FileAccess.get_file_as_string("res://data/weapons.json")) as Array
	evidence = {"tests": {}, "godot": Engine.get_version_info()}
	pool = WeaponActivationSePoolScript.new()
	add_child(pool)
	pool.configure(CAPACITY, -6.0, Callable(self, "_load_audio_stream"))
	await get_tree().process_frame
	_test_audio_sources()
	_test_ring_cycles()
	_test_fansa_climax_three_steps()
	_test_base_baton()
	await _test_game_routing_and_cleanup()
	evidence["failures"] = failures
	print("DEDICATED_EVOLVED_SE=" + JSON.stringify(evidence))
	var output := OS.get_environment("DEDICATED_EVOLVED_SE_EVIDENCE_PATH")
	if output != "":
		var file := FileAccess.open(output, FileAccess.WRITE)
		file.store_string(JSON.stringify(evidence, "  "))
	if failures.is_empty():
		print("Dedicated evolved SE tests passed")
	else:
		for failure in failures: push_error(failure)
	get_tree().quit(0 if failures.is_empty() else 1)


func _test_audio_sources() -> void:
	var rows: Array = []
	for path in [RING_SE, FINISH_SE]:
		var stream := ResourceLoader.load(path) as AudioStreamMP3
		_check(stream != null, "MP3 failed to load: " + path)
		if stream == null: continue
		_check(not stream.loop, "dedicated one-shot must not loop")
		_check(stream.get_length() > 0.0, "MP3 duration must be positive")
		rows.append({"path": path, "type": stream.get_class(), "loop": stream.loop, "seconds": stream.get_length()})
	evidence.tests["audioSources"] = rows


func _test_ring_cycles() -> void:
	var rows: Array = []
	var expected_maro: Array = []
	for enemy_count in [0, 18]:
		for fast in [false, true]:
			var ring := WeaponSystemScript.find_weapon(weapons, "maro_comment_ring", {})
			var context := _ring_context(ring, enemy_count)
			context["intervalRate"] = pow(0.92, 5) * 0.90 * 0.874 if fast else 1.0
			var frames: Array = []
			var common_hits := 0
			for frame in range(1800):
				context["elapsed"] = float(frame) / 60.0
				for enemy in context.enemies: enemy["hitFlashTimer"] = 0.0
				var result := WeaponSystemScript.update_boomerang(context)
				if bool(result.get("maroCommentRingOrbitSe", false)): frames.append(frame)
				_check(not bool(result.get("boomerangOrbitSe", false)), "maro leaked into base boomerang player")
				_check(_activation_fx(result.hitFx).is_empty(), "maro added activation per hit/pulse")
				common_hits += int(bool(result.get("enemyDamaged", false)))
			if expected_maro.is_empty(): expected_maro = frames
			_check(frames == expected_maro, "maro cue count/timing depends on enemy count or attack speed")
			_check(frames.size() == 20 and frames[0] == 0, "maro must deploy once then cue each 230-deg/s revolution")
			_check(common_hits > 0 if enemy_count > 0 else common_hits == 0, "contact fixture did not exercise common hit feedback")
			rows.append({"enemyCount": enemy_count, "fast": fast, "seconds": 30, "cycleFrames": frames, "requests": frames.size(), "commonHitRequests": common_hits})
	# Base sound retains its old helper's timing: no initial cue, 2-s orbit.
	var normal := WeaponSystemScript.find_weapon(weapons, "comment_boomerang", {})
	var normal_context := _ring_context(normal, 18)
	var reference_timers: Dictionary = {}
	var normal_frames: Array = []
	for frame in range(1800):
		var elapsed := float(frame) / 60.0
		normal_context["elapsed"] = elapsed
		var old_due := WeaponSystemScript._boomerang_orbit_se_due(normal, reference_timers, elapsed, WeaponSystemScript.orbit_speed(normal), true)
		var result := WeaponSystemScript.update_boomerang(normal_context)
		_check(bool(result.get("boomerangOrbitSe", false)) == old_due, "normal boomerang cue timing changed")
		_check(not bool(result.get("maroCommentRingOrbitSe", false)), "normal boomerang requested evolved cue")
		if old_due: normal_frames.append(frame)
	_check(normal_frames.size() == 14, "normal 30-s cue count changed")
	# Exercise the equipment aggregation path as well as the main orbit path.
	var ring := WeaponSystemScript.find_weapon(weapons, "maro_comment_ring", {})
	var side := _context(ring, "maro_comment_ring", {}, [])
	side["mainWeaponId"] = "phase1_null_weapon"
	side["mainWeapon"] = WeaponSystemScript.find_weapon(weapons, "phase1_null_weapon", {})
	side["elapsed"] = 0.0
	var side_result := WeaponSystemScript.update_equipment_weapons(side)
	_check(bool(side_result.get("maroCommentRingOrbitSe", false)), "side-slot ring deployment cue lost")
	side["timers"] = side_result.timers
	_check(not bool(WeaponSystemScript.update_equipment_weapons(side).get("maroCommentRingOrbitSe", false)), "same deployment requested twice")
	evidence.tests["ringCycles"] = {"cases": rows, "normalFrames": normal_frames, "sideSlot": true}


func _ring_context(weapon: Dictionary, enemy_count: int) -> Dictionary:
	return {
		"weapon": weapon, "weaponType": "orbit", "isMainOrbit": true,
		"delta": 1.0 / 60.0, "elapsed": 0.0, "boomerangLevel": 0,
		"weaponTimers": {}, "boomerangHits": {}, "playerPos": Vector2.ZERO,
		"range": WeaponSystemScript.range_base(weapon), "damage": float(weapon.damage),
		"knockback": 0.0, "enemies": _dense_enemies(Vector2.ZERO, enemy_count, 117.0),
		"destructibles": [], "enemyBullets": [], "expOrbs": []
	}


func _test_base_baton() -> void:
	var baton := WeaponSystemScript.find_weapon(weapons, "fansa_baton", {})
	var paths: Array = []
	for step in range(3):
		var timers := {"__stage2WeaponStates": {"fansa_baton": {"comboStep": step}}}
		var result := WeaponSystemScript.update_equipment_weapons(_context(baton, "fansa_baton", timers, _front_enemies(8, 72.0), 5))
		var cues := _activation_fx(result.hitFx)
		_check(cues.size() == 1, "normal baton must emit one main-step cue")
		var expected := "res://assets/audio/fansa_baton_combo_%d.mp3" % (step + 1)
		_check(String(cues[0].activationSePath) == expected, "normal baton audio changed")
		paths.append(expected)
	evidence.tests["normalBatonPaths"] = paths


func _test_game_routing_and_cleanup() -> void:
	_reset_pool()
	var game := preload("res://scripts/game.gd").new()
	game.quick_test_mode = true
	add_child(game)
	game.set_process(false)
	await get_tree().process_frame
	game.weapon_activation_se_pool.stop_all()
	game.weapon_activation_se_pool.reset_debug_counters()
	game._play_weapon_activation_se_from_result({"maroCommentRingOrbitSe": true, "hitFx": []})
	var first: Dictionary = game.weapon_activation_se_pool.debug_snapshot()
	_check(first.startedCount == 1 and first.activeCount == 1, "ring deployment did not start through production pool")
	game._play_weapon_activation_se_from_result({"hitFx": [{"activationSePath": FINISH_SE, "activationSeVolumeDb": 0.0}]})
	var both: Dictionary = game.weapon_activation_se_pool.debug_snapshot()
	_check(both.activeCount == 2, "finisher interrupted ring")
	for slot in both.slots:
		if bool(slot.reserved):
			_check(bool(slot.playing), "reserved new cue is not playing")
			_check(slot.path in [RING_SE, FINISH_SE], "old combo3 played for evolved finisher")
	game._cleanup_weapon_activation_se_for_weapon_ids(["maro_comment_ring"], false)
	_check(game.weapon_activation_se_pool.active_count() == 1, "ring cleanup stopped another weapon or retained ring")
	game._cleanup_weapon_activation_se_for_weapon_ids(["fansa_climax"], false)
	_check(game.weapon_activation_se_pool.active_count() == 0, "new finisher escaped cleanup")
	game._play_weapon_activation_se(RING_SE)
	await get_tree().create_timer((ResourceLoader.load(RING_SE) as AudioStream).get_length() + 0.2).timeout
	_check(game.weapon_activation_se_pool.active_count() == 0, "new ring did not naturally release its slot")
	game._play_weapon_activation_se(FINISH_SE)
	await get_tree().create_timer((ResourceLoader.load(FINISH_SE) as AudioStream).get_length() + 0.2).timeout
	_check(game.weapon_activation_se_pool.active_count() == 0, "new finisher did not naturally release its slot")
	evidence.tests["productionPool"] = {"first": first, "both": both, "final": game.weapon_activation_se_pool.debug_snapshot()}
	game.free()
