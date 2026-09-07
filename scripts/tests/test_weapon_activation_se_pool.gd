extends Node

const WeaponActivationSePoolScript := preload("res://scripts/systems/weapon_activation_se_pool.gd")
const WeaponSystemScript := preload("res://scripts/systems/weapon_system.gd")

const CAPACITY := 10
const SHIELD := "res://assets/audio/moderator_shield_activate.mp3"
const BATON_1 := "res://assets/audio/fansa_baton_combo_1.mp3"
const BATON_2 := "res://assets/audio/fansa_baton_combo_2.mp3"
const BATON_3 := "res://assets/audio/fansa_baton_combo_3.mp3"
const ROD_CAST := "res://assets/audio/tsuri_thumbnail_rod_cast.mp3"
const ROD_REEL := "res://assets/audio/tsuri_thumbnail_rod_reel.mp3"
const VALID_MAX_SPEED_SECONDS := 6.0
const SIMULATION_STEP := 0.05

var failures: Array[String] = []
var evidence: Dictionary = {}
var pool: WeaponActivationSePool


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	get_tree().paused = false
	evidence = {
		"godotVersion": Engine.get_version_info(),
		"poolCapacity": CAPACITY,
		"tests": {},
	}
	pool = WeaponActivationSePoolScript.new()
	pool.name = "WeaponActivationSePoolContractTest"
	add_child(pool)
	pool.configure(CAPACITY, -6.0, Callable(self, "_load_audio_stream"))
	await get_tree().process_frame

	_test_same_frame_three_sources()
	_test_same_source_distinct_events()
	_test_long_reel_with_other_sources()
	_test_capacity_policy()
	await _test_slot_reuse()
	_test_settings_reflection()
	_test_stop_scope_and_restart()
	await _test_game_wiring_and_lifecycle()
	evidence["regularPlay"] = [
		await _run_regular_play_scenario("normal_shield", ["moderator_shield", "fansa_baton", "tsuri_thumbnail_rod"]),
		await _run_regular_play_scenario("evolved_shield", ["moderator_fortress", "fansa_baton", "tsuri_thumbnail_rod"]),
	]
	for scenario_value in evidence["regularPlay"] as Array:
		var scenario: Dictionary = scenario_value as Dictionary
		var scenario_pool: Dictionary = scenario.get("pool", {}) as Dictionary
		var started_by_path: Dictionary = scenario_pool.get("startedByPath", {}) as Dictionary
		_check(int(scenario_pool.get("skippedCount", -1)) == 0, "%s regular play exceeded pool capacity" % String(scenario.get("name", "scenario")))
		_check(int(started_by_path.get(ROD_REEL, 0)) > 0, "%s regular play did not exercise rod reel playback" % String(scenario.get("name", "scenario")))

	evidence["failures"] = failures.duplicate()
	evidence["passed"] = failures.is_empty()
	_write_optional_evidence()
	print("WEAPON_ACTIVATION_SE_POOL_EVIDENCE=" + JSON.stringify(evidence))
	if failures.is_empty():
		print("Weapon activation SE pool tests passed")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	get_tree().quit(1)


func _test_same_frame_three_sources() -> void:
	_reset_pool()
	var first := pool.request_play(SHIELD)
	var first_snapshot := pool.debug_snapshot()
	var first_stream_id := int(_slot(first_snapshot, int(first.get("slot", -1))).get("streamInstanceId", 0))
	var second := pool.request_play(BATON_1)
	var third := pool.request_play(ROD_CAST)
	var snapshot := pool.debug_snapshot()
	_check(bool(first.get("started", false)) and bool(second.get("started", false)) and bool(third.get("started", false)), "same-frame three-source requests did not all start")
	_check(int(snapshot.get("activeCount", 0)) == 3, "same-frame three-source active count was not 3")
	_check(int(_slot(snapshot, int(first.get("slot", -1))).get("streamInstanceId", 0)) == first_stream_id, "later request replaced the first stream")
	_check(bool(_slot(snapshot, int(first.get("slot", -1))).get("playing", false)), "later request stopped the first stream")
	_check(_active_paths(snapshot).has(SHIELD) and _active_paths(snapshot).has(BATON_1) and _active_paths(snapshot).has(ROD_CAST), "same-frame paths were not retained independently")
	(evidence["tests"] as Dictionary)["sameFrameThreeSources"] = {"requests": [first, second, third], "snapshot": snapshot}


func _test_same_source_distinct_events() -> void:
	_reset_pool()
	var first := pool.request_play(SHIELD)
	var second := pool.request_play(SHIELD)
	var snapshot := pool.debug_snapshot()
	_check(bool(first.get("started", false)) and bool(second.get("started", false)), "same-source distinct events did not both start")
	_check(int(first.get("slot", -1)) != int(second.get("slot", -1)), "same-source events reused a playing slot")
	_check(int(snapshot.get("activeCount", 0)) == 2, "same-source active count was not 2")
	(evidence["tests"] as Dictionary)["sameSourceDistinctEvents"] = {"requests": [first, second], "snapshot": snapshot}


func _test_long_reel_with_other_sources() -> void:
	_reset_pool()
	var reel := pool.request_play(ROD_REEL)
	var reel_slot := int(reel.get("slot", -1))
	var reel_before := _slot(pool.debug_snapshot(), reel_slot)
	var requests := [pool.request_play(SHIELD), pool.request_play(BATON_1), pool.request_play(ROD_CAST)]
	var snapshot := pool.debug_snapshot()
	var reel_after := _slot(snapshot, reel_slot)
	_check(bool(reel.get("started", false)), "long reel did not start")
	_check(bool(reel_after.get("playing", false)) and String(reel_after.get("path", "")) == ROD_REEL, "other weapon request stopped the reel")
	_check(int(reel_after.get("streamInstanceId", 0)) == int(reel_before.get("streamInstanceId", -1)), "other weapon request replaced the reel stream")
	_check(int(snapshot.get("activeCount", 0)) == 4, "reel plus three sources did not occupy four slots")
	(evidence["tests"] as Dictionary)["longReelWithOtherSources"] = {"reel": reel, "otherRequests": requests, "snapshot": snapshot}


func _test_capacity_policy() -> void:
	_reset_pool()
	var accepted: Array = []
	for _index in range(CAPACITY):
		accepted.append(pool.request_play(SHIELD))
	var overflow := pool.request_play(BATON_1)
	var snapshot := pool.debug_snapshot()
	_check((accepted as Array).all(func(item: Dictionary) -> bool: return bool(item.get("started", false))), "capacity fill rejected an in-capacity request")
	_check(not bool(overflow.get("started", true)) and String(overflow.get("reason", "")) == "capacity", "overflow request did not use deterministic skip policy")
	_check(int(snapshot.get("activeCount", 0)) == CAPACITY, "overflow altered active slot count")
	_check(int(snapshot.get("skippedCount", 0)) == 1, "overflow skip count was not 1")
	_check(int(snapshot.get("queueLength", -1)) == 0, "overflow created a queue")
	_check(pool.get_child_count() == CAPACITY, "overflow changed the finite node count")
	(evidence["tests"] as Dictionary)["capacityPolicy"] = {"accepted": accepted, "overflow": overflow, "snapshot": snapshot, "childCount": pool.get_child_count()}


func _test_slot_reuse() -> void:
	_reset_pool()
	var first := pool.request_play(SHIELD)
	var stopped := pool.stop(SHIELD)
	var second := pool.request_play(BATON_1)
	_check(stopped == 1, "explicit path stop did not release exactly one slot")
	_check(int(first.get("slot", -1)) == int(second.get("slot", -2)), "explicitly stopped slot was not reused")
	pool.call("_on_slot_finished", int(first.get("slot", -1)))
	_check(pool.active_count() == 1 and _active_paths(pool.debug_snapshot()).has(BATON_1), "stale finish notification released a reused slot")
	var explicit_snapshot := pool.debug_snapshot()

	_reset_pool()
	var natural_first := pool.request_play(ROD_CAST)
	# Headless audio playback advances reliably when the main loop is allowed to
	# service several short frames instead of sleeping through one long timer.
	for _frame_index in range(20):
		await get_tree().create_timer(0.05, true, false, true).timeout
	var finished_snapshot := pool.debug_snapshot()
	var natural_second := pool.request_play(SHIELD)
	_check(int(finished_snapshot.get("activeCount", -1)) == 0, "naturally finished slot remained occupied")
	_check(int(finished_snapshot.get("naturalReleaseCount", 0)) >= 1, "natural finish was not recorded")
	_check(int(natural_first.get("slot", -1)) == int(natural_second.get("slot", -2)), "naturally finished slot was not reused")
	(evidence["tests"] as Dictionary)["slotReuse"] = {
		"explicit": {"first": first, "stopCount": stopped, "second": second, "snapshot": explicit_snapshot},
		"natural": {"first": natural_first, "afterFinish": finished_snapshot, "second": natural_second},
	}


func _test_settings_reflection() -> void:
	_reset_pool()
	pool.set_base_volume_db(-12.0)
	var request := pool.request_play(SHIELD, -1.0)
	var slot_index := int(request.get("slot", -1))
	var initial := _slot(pool.debug_snapshot(), slot_index)
	pool.set_base_volume_db(-18.0)
	var updated := _slot(pool.debug_snapshot(), slot_index)
	pool.stop_all()
	pool.set_base_volume_db(-80.0)
	var muted_request := pool.request_play(BATON_1)
	var muted := _slot(pool.debug_snapshot(), int(muted_request.get("slot", -1)))
	_check(is_equal_approx(float(initial.get("volumeDb", 0.0)), -13.0), "per-event volume offset was not preserved")
	_check(is_equal_approx(float(updated.get("volumeDb", 0.0)), -19.0), "live SE volume update did not reach active slot")
	_check(float(muted.get("volumeDb", 0.0)) <= -79.9, "mute did not reach a reused slot")
	_check(String(muted.get("bus", "")) == "Master", "output bus changed from the existing Master route")
	_check(is_equal_approx(float(muted.get("pitchScale", 0.0)), 1.0), "default pitch changed")
	_check(int(muted.get("processMode", -1)) == Node.PROCESS_MODE_INHERIT, "pause process mode changed")
	(evidence["tests"] as Dictionary)["settingsReflection"] = {"initial": initial, "updated": updated, "muted": muted}


func _test_stop_scope_and_restart() -> void:
	_reset_pool()
	var unrelated := AudioStreamPlayer.new()
	unrelated.name = "UnrelatedAudioPlayer"
	unrelated.stream = _load_audio_stream(ROD_REEL, false)
	add_child(unrelated)
	unrelated.play()
	pool.request_play(ROD_REEL)
	var stopped := pool.stop_all()
	var restart_request := pool.request_play(SHIELD)
	_check(stopped == 1 and pool.active_count() == 1, "stop-all/restart did not reset pool occupancy")
	_check(unrelated.playing, "pool stop affected an unrelated audio player")
	_check(bool(restart_request.get("started", false)), "pool did not restart after explicit stop")
	(evidence["tests"] as Dictionary)["stopScopeAndRestart"] = {"poolStopCount": stopped, "unrelatedStillPlaying": unrelated.playing, "restart": restart_request, "snapshot": pool.debug_snapshot()}
	unrelated.stop()
	unrelated.queue_free()
	pool.configure(CAPACITY, -6.0, Callable(self, "_load_audio_stream"))
	var reconfigured_request := pool.request_play(ROD_CAST)
	_check(pool.get_child_count() == CAPACITY, "reconfigure duplicated pool nodes")
	_check(bool(reconfigured_request.get("started", false)), "pool did not restart after reconfigure")
	(evidence["tests"] as Dictionary)["reconfigure"] = {"childCount": pool.get_child_count(), "request": reconfigured_request, "snapshot": pool.debug_snapshot()}


func _test_game_wiring_and_lifecycle() -> void:
	var game := (load("res://scenes/main.tscn") as PackedScene).instantiate()
	add_child(game)
	await get_tree().process_frame
	game.set_process(false)
	game.set("quick_test_mode", true)
	var game_pool := game.get("weapon_activation_se_pool") as Node
	_check(game_pool != null, "game did not create the activation SE pool")
	_check(int(game_pool.call("slot_count")) == CAPACITY, "game pool capacity differs from tested capacity")
	game.call("_play_weapon_activation_se", SHIELD, 0.0)
	game.call("_play_weapon_activation_se", BATON_1, 0.0)
	game.call("_play_weapon_activation_se", ROD_CAST, 0.0)
	var same_frame: Dictionary = game_pool.call("debug_snapshot") as Dictionary
	_check(int(same_frame.get("activeCount", 0)) == 3, "game wiring did not retain three same-frame sources")
	game.call("_stop_weapon_activation_se", ROD_CAST)
	var path_stop: Dictionary = game_pool.call("debug_snapshot") as Dictionary
	_check(int(path_stop.get("activeCount", 0)) == 2 and not _active_paths(path_stop).has(ROD_CAST), "path stop affected wrong game slots")

	game.call("_stop_all_weapon_activation_se")
	game.call("_play_weapon_activation_se", ROD_REEL, 0.0)
	game.call("_play_weapon_activation_se", SHIELD, 0.0)
	WeaponSystemScript.cleanup_runtime_for_weapon(game, "tsuri_thumbnail_rod", "buzz_thumbnail_rod", "evolution")
	var evolution: Dictionary = game_pool.call("debug_snapshot") as Dictionary
	_check(not _active_paths(evolution).has(ROD_REEL) and _active_paths(evolution).has(SHIELD), "evolution cleanup did not stop only the evolved weapon's audio")

	game.call("_stop_all_weapon_activation_se")
	game.call("_play_weapon_activation_se", ROD_REEL, 0.0)
	game.set("state", "pause")
	var pause_before: Dictionary = game_pool.call("debug_snapshot") as Dictionary
	await get_tree().create_timer(0.12, true, false, true).timeout
	var pause_during: Dictionary = game_pool.call("debug_snapshot") as Dictionary
	game.set("state", "playing")
	await get_tree().create_timer(0.12, true, false, true).timeout
	var pause_after: Dictionary = game_pool.call("debug_snapshot") as Dictionary
	_check(_active_paths(pause_during).has(ROD_REEL) and _active_paths(pause_after).has(ROD_REEL), "pause/resume stopped the reel")

	game.set("state", "playing")
	game.call("_start_game_over_intro", "TEST")
	var game_over: Dictionary = game_pool.call("debug_snapshot") as Dictionary
	_check(int(game_over.get("activeCount", -1)) == 0, "game over did not stop activation SE slots")
	game.call("_play_weapon_activation_se", ROD_REEL, 0.0)
	game.call("_restart")
	var retry: Dictionary = game_pool.call("debug_snapshot") as Dictionary
	_check(int(retry.get("activeCount", -1)) == 0, "retry did not stop activation SE slots")
	game.call("_play_weapon_activation_se", ROD_REEL, 0.0)
	WeaponSystemScript.cleanup_runtime_for_weapon(game, "", "", "title_transition")
	var transition: Dictionary = game_pool.call("debug_snapshot") as Dictionary
	_check(int(transition.get("activeCount", -1)) == 0, "combat transition cleanup did not stop activation SE slots")

	(evidence["tests"] as Dictionary)["gameWiringAndLifecycle"] = {
		"sameFrame": same_frame,
		"pathStop": path_stop,
		"evolution": evolution,
		"pauseBefore": pause_before,
		"pauseDuring": pause_during,
		"pauseAfter": pause_after,
		"gameOver": game_over,
		"retry": retry,
		"transition": transition,
	}
	var pool_ref: WeakRef = weakref(game_pool)
	game.free()
	await get_tree().process_frame
	_check(pool_ref.get_ref() == null, "scene exit retained the activation SE pool node")


func _run_regular_play_scenario(scenario_name: String, weapon_ids: Array[String]) -> Dictionary:
	var game := (load("res://scenes/main.tscn") as PackedScene).instantiate()
	add_child(game)
	await get_tree().process_frame
	game.set_process(false)
	game.set("quick_test_mode", true)
	game.set("state", "playing")
	game.set("previous_state", "playing")
	game.set("current_stream_frame_id", "singing")
	game.set("song_live_heat_level", 5)
	game.set("player_pos", Vector2(800.0, 450.0))
	game.set("player_vel", Vector2.ZERO)
	game.set("last_hammer_dir", Vector2.RIGHT)
	game.set("player_facing_x", 1.0)
	game.set("mute_timer", 0.0)
	game.set("support_attack_timer", 0.0)
	game.set("equipment_interval_rate", pow(0.92, 5.0))
	var shop_snapshot: Object = game.get("permanent_upgrade_snapshot") as Object
	if shop_snapshot != null:
		shop_snapshot.set("attack_interval_multiplier", 0.90)
	var weapon_data: Array = game.get("weapons") as Array
	var null_weapon := WeaponSystemScript.find_weapon(weapon_data, "phase1_null_weapon", {})
	game.set("current_weapon", null_weapon)
	game.set("current_weapon_id", "phase1_null_weapon")
	var equipped: Array = []
	var timers: Dictionary = {}
	for weapon_id in weapon_ids:
		equipped.append({"id": weapon_id, "level": 5})
		timers[weapon_id] = 0.0
	game.set("player_weapons", equipped)
	game.set("equipment_weapon_timers", timers)
	game.set("hit_fx", [])
	game.set("player_bullets", [])
	game.set("enemy_bullets", [
		{"pos": Vector2(882.0, 450.0), "vel": Vector2.ZERO, "life": 30.0, "hitRadius": 7.0, "shieldBlockable": true, "clearableByPlayerWeapon": true},
		{"pos": Vector2(910.0, 418.0), "vel": Vector2.ZERO, "life": 30.0, "hitRadius": 7.0, "shieldBlockable": true, "clearableByPlayerWeapon": true},
	])
	game.set("destructibles", [])
	game.set("exp_orbs", [])
	game.set("drop_items", [])
	game.set("boomerang_hits", {})
	game.set("enemies", _dense_enemies(Vector2(800.0, 450.0)))
	var game_pool := game.get("weapon_activation_se_pool") as Node
	game_pool.call("stop_all")
	game_pool.call("reset_debug_counters")
	var arena := game.call("_current_arena") as Rect2
	var steps := int(ceil(VALID_MAX_SPEED_SECONDS / SIMULATION_STEP))
	for _step in range(steps):
		game.call("_update_weapons", SIMULATION_STEP, arena)
		var hit_fx_feedback: Dictionary = WeaponSystemScript.update_hit_fx_for_target(game, SIMULATION_STEP, arena, game.get("rng") as RandomNumberGenerator)
		game.call("_apply_hit_reaction_feedback", hit_fx_feedback)
		await get_tree().create_timer(SIMULATION_STEP, true, false, true).timeout
	var snapshot: Dictionary = game_pool.call("debug_snapshot") as Dictionary
	var result := {
		"name": scenario_name,
		"weaponIds": weapon_ids,
		"seconds": VALID_MAX_SPEED_SECONDS,
		"step": SIMULATION_STEP,
		"equipmentIntervalRate": pow(0.92, 5.0),
		"shopAttackIntervalMultiplier": 0.90,
		"songHeatCooldownMultiplier": 0.95 * 0.92,
		"pool": snapshot,
	}
	game.free()
	await get_tree().process_frame
	return result


func _dense_enemies(center: Vector2) -> Array:
	var result: Array = []
	for index in range(24):
		var angle := TAU * float(index) / 24.0
		# Keep the valid-play stress targets dense but far enough away that the
		# rod reel remains active long enough to overlap shield and baton audio.
		var radius := 250.0 + float(index % 4) * 20.0
		result.append({
			"kind": "enemy_dot_invader",
			"uid": index + 1000,
			"spawnToken": "weapon-se-pool:%d" % index,
			"pos": center + Vector2.RIGHT.rotated(angle) * radius,
			"hp": 100000.0,
			"max_hp": 100000.0,
			"radius": 20.0,
			"hurtboxRadius": 20.0,
			"canBeKnockedBack": true,
			"knockbackResistance": 0.0,
			"damageTakenRate": 1.0,
			"behavior": "chase",
			"canBePulled": true,
			"pullResistance": 0.0,
			"stunTimer": 0.0,
			"slowTimer": 0.0,
			"defeatPending": false,
			"defeatResolved": false,
		})
	return result


func _reset_pool() -> void:
	pool.stop_all()
	pool.set_base_volume_db(-6.0)
	pool.reset_debug_counters()


func _load_audio_stream(path: String, loop: bool = false) -> AudioStream:
	var source := ResourceLoader.load(path) as AudioStream
	if source == null:
		return null
	var stream := source.duplicate() as AudioStream
	if stream == null:
		stream = source
	if stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = loop
	return stream


func _slot(snapshot: Dictionary, slot_index: int) -> Dictionary:
	var slots: Array = snapshot.get("slots", []) as Array
	if slot_index < 0 or slot_index >= slots.size():
		return {}
	return slots[slot_index] as Dictionary


func _active_paths(snapshot: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for slot_value in snapshot.get("slots", []) as Array:
		var slot: Dictionary = slot_value as Dictionary
		if bool(slot.get("reserved", false)):
			result.append(String(slot.get("path", "")))
	return result


func _write_optional_evidence() -> void:
	var output_path := OS.get_environment("WEAPON_ACTIVATION_SE_EVIDENCE_PATH")
	if output_path == "":
		return
	var file := FileAccess.open(output_path, FileAccess.WRITE)
	if file == null:
		failures.append("could not write evidence file: %s" % output_path)
		return
	file.store_string(JSON.stringify(evidence, "  "))
	file.close()


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
