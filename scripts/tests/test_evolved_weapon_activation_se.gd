extends Node

const WeaponActivationSePoolScript := preload("res://scripts/systems/weapon_activation_se_pool.gd")
const WeaponSystemScript := preload("res://scripts/systems/weapon_system.gd")

const CAPACITY := 10
const SIMULATION_STEP := 0.05
const DEFAULT_STRESS_SECONDS := 6.0
const FANSA_SE_PATHS: Array[String] = [
	"res://assets/audio/fansa_baton_combo_1.mp3",
	"res://assets/audio/fansa_baton_combo_2.mp3",
	"res://assets/audio/fansa_climax_finisher.mp3",
]
const ROD_CAST_SE_PATH := "res://assets/audio/tsuri_thumbnail_rod_cast.mp3"
const ROD_REEL_SE_PATH := "res://assets/audio/tsuri_thumbnail_rod_reel.mp3"

var failures: Array[String] = []
var evidence: Dictionary = {}
var weapons: Array = []
var pool: WeaponActivationSePool


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/weapons.json"))
	weapons = parsed as Array if parsed is Array else []
	evidence = {
		"godotVersion": Engine.get_version_info(),
		"poolCapacity": CAPACITY,
		"audioLengthsSeconds": _audio_lengths(),
		"tests": {},
	}
	_check(not weapons.is_empty(), "weapon registry did not parse")
	pool = WeaponActivationSePoolScript.new()
	pool.name = "EvolvedWeaponActivationSePoolTest"
	add_child(pool)
	pool.configure(CAPACITY, -6.0, Callable(self, "_load_audio_stream"))
	await get_tree().process_frame

	_test_fansa_climax_three_steps()
	_test_baton_and_climax_pool_contract()
	_test_buzz_cast_once()
	_test_buzz_timeline()
	var stress_seconds := _stress_seconds()
	if stress_seconds > 0.0:
		evidence["maxLegalSpeed"] = await _run_max_legal_speed(stress_seconds)
		# Legal five-slot mix: the retained finisher and ring tails share this pool.
		evidence["fullEvolvedMix"] = await _run_max_legal_speed(minf(stress_seconds, 12.0), [
			"maro_comment_ring", "moderator_fortress", "fansa_climax", "buzz_thumbnail_rod", "full_voice_dome",
		])
	else:
		evidence["maxLegalSpeed"] = {"skipped": true, "reason": "duration_zero"}

	evidence["failures"] = failures.duplicate()
	evidence["passed"] = failures.is_empty()
	_write_optional_evidence()
	print("EVOLVED_WEAPON_ACTIVATION_SE_EVIDENCE=" + JSON.stringify(evidence))
	if failures.is_empty():
		print("Evolved weapon activation SE tests passed")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	get_tree().quit(1)


func _test_fansa_climax_three_steps() -> void:
	_reset_pool()
	var climax := WeaponSystemScript.find_weapon(weapons, "fansa_climax", {})
	var records: Array = []
	var requests: Array = []
	for step in range(3):
		var timers := {"__stage2WeaponStates": {"fansa_climax": {"comboStep": step}}}
		var enemies := _front_enemies(8, 72.0)
		var result := WeaponSystemScript.update_equipment_weapons(_context(climax, "fansa_climax", timers, enemies))
		var activation_fx := _activation_fx(result.get("hitFx", []) as Array)
		var main_fx := _find_fx(result.get("hitFx", []) as Array, "fansa_climax_hit")
		var secondary_activation: Array = []
		for fx_value in activation_fx:
			var fx: Dictionary = fx_value as Dictionary
			if String(fx.get("kind", "")) != "fansa_climax_hit":
				secondary_activation.append(String(fx.get("kind", "")))
		var path := String(main_fx.get("activationSePath", ""))
		_check(activation_fx.size() == 1, "fansa climax step %d did not emit exactly one activation SE" % (step + 1))
		_check(secondary_activation.is_empty(), "fansa climax step %d attached activation SE to secondary FX" % (step + 1))
		_check(path == FANSA_SE_PATHS[step], "fansa climax step %d used the wrong combo SE" % (step + 1))
		_check(int(main_fx.get("count", 0)) > 1, "fansa climax step %d multi-target probe did not hit multiple enemies" % (step + 1))
		var request := pool.request_play(path, float(main_fx.get("activationSeVolumeDb", 0.0)))
		requests.append(request)
		records.append({
			"step": step + 1,
			"comboStep": step,
			"path": path,
			"requestCount": activation_fx.size(),
			"enemyCount": enemies.size(),
			"mainHitCount": int(main_fx.get("count", 0)),
			"started": bool(request.get("started", false)),
			"slot": int(request.get("slot", -1)),
			"activeAfterRequest": pool.active_count(),
			"secondaryActivationFx": secondary_activation,
		})
	var snapshot := pool.debug_snapshot()
	_check(requests.all(func(request: Dictionary) -> bool: return bool(request.get("started", false))), "fansa climax three-step SE sequence did not start all requests")
	_check(int(snapshot.get("activeCount", 0)) == 3, "fansa climax three-step SE sequence did not retain three independent slots")
	_check(int(snapshot.get("skippedCount", -1)) == 0, "fansa climax three-step SE sequence skipped within capacity")
	(evidence["tests"] as Dictionary)["fansaClimaxThreeSteps"] = {"records": records, "pool": snapshot}


func _test_baton_and_climax_pool_contract() -> void:
	_reset_pool()
	var baton := WeaponSystemScript.find_weapon(weapons, "fansa_baton", {})
	var climax := WeaponSystemScript.find_weapon(weapons, "fansa_climax", {})
	var baton_timers := {"__stage2WeaponStates": {"fansa_baton": {"comboStep": 0}}}
	var climax_timers := {"__stage2WeaponStates": {"fansa_climax": {"comboStep": 2}}}
	var enemies := _dense_enemies(Vector2.ZERO, 4, 72.0)
	var baton_result := WeaponSystemScript.update_equipment_weapons(_context(baton, "fansa_baton", baton_timers, enemies, 5))
	var climax_result := WeaponSystemScript.update_equipment_weapons(_context(climax, "fansa_climax", climax_timers, enemies))
	var baton_fx := _find_fx(baton_result.get("hitFx", []) as Array, "fansa_baton_hit")
	var climax_fx := _find_fx(climax_result.get("hitFx", []) as Array, "fansa_climax_hit")
	var baton_request := pool.request_play(String(baton_fx.get("activationSePath", "")))
	var climax_request := pool.request_play(String(climax_fx.get("activationSePath", "")))
	var snapshot := pool.debug_snapshot()
	_check(bool(baton_request.get("started", false)) and bool(climax_request.get("started", false)), "baton and climax pool-contract requests did not both start")
	_check(int(baton_request.get("slot", -1)) != int(climax_request.get("slot", -1)), "baton and climax reused a playing pool slot")
	_check(int(snapshot.get("activeCount", 0)) == 2, "baton and climax did not remain active together")
	(evidence["tests"] as Dictionary)["batonAndClimaxPoolContract"] = {
		"normalPlayCanCoexist": false,
		"batonPath": String(baton_fx.get("activationSePath", "")),
		"climaxPath": String(climax_fx.get("activationSePath", "")),
		"requests": [baton_request, climax_request],
		"pool": snapshot,
	}


func _test_buzz_cast_once() -> void:
	_reset_pool()
	var buzz := WeaponSystemScript.find_weapon(weapons, "buzz_thumbnail_rod", {})
	var enemies := _dense_enemies(Vector2.ZERO, 5, 90.0)
	var result := WeaponSystemScript.update_equipment_weapons(_context(buzz, "buzz_thumbnail_rod", {}, enemies))
	var activation_fx := _activation_fx(result.get("hitFx", []) as Array)
	var cast := _find_fx(result.get("hitFx", []) as Array, "buzz_thumbnail_rod_cast")
	var path := String(cast.get("activationSePath", ""))
	_check(activation_fx.size() == 1, "buzz attack did not emit exactly one activation SE")
	_check(path == ROD_CAST_SE_PATH, "buzz attack did not inherit the rod cast SE")
	for fx_value in result.get("hitFx", []) as Array:
		var fx: Dictionary = fx_value as Dictionary
		if String(fx.get("kind", "")) != "buzz_thumbnail_rod_cast":
			_check(String(fx.get("activationSePath", "")) == "", "buzz secondary FX requested activation SE")
	_check(String(cast.get("reelSePath", "")) == "", "buzz cast inherited the long reel SE")
	var request := pool.request_play(path, float(cast.get("activationSeVolumeDb", 0.0)))
	_check(bool(request.get("started", false)), "buzz cast SE did not start in the shared pool")
	(evidence["tests"] as Dictionary)["buzzCastOnce"] = {
		"path": path,
		"activationRequestCount": activation_fx.size(),
		"request": request,
		"pool": pool.debug_snapshot(),
		"reelAttached": String(cast.get("reelSePath", "")) != "",
	}


func _test_buzz_timeline() -> void:
	var buzz := WeaponSystemScript.find_weapon(weapons, "buzz_thumbnail_rod", {})
	var enemies := _dense_enemies(Vector2.ZERO, 4, 90.0)
	for enemy_value in enemies:
		(enemy_value as Dictionary)["kind"] = "test_enemy"
	var result := WeaponSystemScript.update_equipment_weapons(_context(buzz, "buzz_thumbnail_rod", {}, enemies))
	var fx_state: Array = result.get("hitFx", []) as Array
	var initial_cast := _find_fx(fx_state, "buzz_thumbnail_rod_cast")
	var target_distance := Vector2(initial_cast.get("lastTargetPos", Vector2.ZERO)).length()
	var events := {
		"castStart": 0.0,
		"markStart": 0.0,
		"throwVisualStart": 0.0,
		"gatherStart": -1.0,
		"initialHitStart": -1.0,
		"throwPhaseStart": -1.0,
		"impactStart": -1.0,
		"reelPhaseStart": -1.0,
		"runtimeEnd": -1.0,
	}
	var feedback := {"barrierHitRequests": [], "weaponSeRequests": []}
	var elapsed := 0.0
	var delta := 0.001
	for _step in range(8000):
		elapsed += delta
		fx_state = WeaponSystemScript.update_hit_fx(fx_state, delta, enemies, [], [], [], [], feedback, Rect2(-1000.0, -1000.0, 2000.0, 2000.0), [], Vector2.ZERO)
		if float(events["gatherStart"]) < 0.0 and not _find_fx(fx_state, "buzz_thumbnail_rod_gather").is_empty():
			events["gatherStart"] = elapsed
		if float(events["initialHitStart"]) < 0.0 and not _find_fx(fx_state, "buzz_thumbnail_rod_hit").is_empty():
			events["initialHitStart"] = elapsed
		if float(events["impactStart"]) < 0.0 and not _find_fx(fx_state, "buzz_thumbnail_rod_catch_mark").is_empty():
			events["impactStart"] = elapsed
		var cast := _find_fx(fx_state, "buzz_thumbnail_rod_cast")
		if cast.is_empty():
			events["runtimeEnd"] = elapsed
			break
		var phase := String(cast.get("phase", ""))
		if phase == "throwing" and float(events["throwPhaseStart"]) < 0.0:
			events["throwPhaseStart"] = elapsed
		if phase == "reeling" and float(events["reelPhaseStart"]) < 0.0:
			events["reelPhaseStart"] = elapsed
	var reel_length := float((evidence["audioLengthsSeconds"] as Dictionary).get(ROD_REEL_SE_PATH, 0.0))
	var runtime_end := float(events["runtimeEnd"])
	var reel_phase_start := float(events["reelPhaseStart"])
	events["hypotheticalReelEndFromReelPhase"] = reel_phase_start + reel_length
	events["hypotheticalTailAfterRuntime"] = reel_phase_start + reel_length - runtime_end
	events["hypotheticalReelEndFromCast"] = reel_length
	events["hypotheticalCastStartTailAfterRuntime"] = reel_length - runtime_end
	for key in events.keys():
		if events[key] is float:
			events[key] = snappedf(float(events[key]), 0.0001)
	_check(float(events["gatherStart"]) >= 0.0, "buzz timeline did not reach gather")
	_check(float(events["throwPhaseStart"]) >= 0.0, "buzz timeline did not reach throw phase")
	_check(float(events["impactStart"]) >= 0.0, "buzz timeline did not reach catch impact")
	_check(float(events["reelPhaseStart"]) >= 0.0, "buzz timeline did not reach reel phase")
	_check(runtime_end > 0.0, "buzz timeline did not finish")
	_check((feedback.get("weaponSeRequests", []) as Array).is_empty(), "buzz runtime emitted a reel or duplicate activation SE request")
	(evidence["tests"] as Dictionary)["buzzTimeline"] = {
		"targetDistance": snappedf(target_distance, 0.0001),
		"stepSeconds": delta,
		"eventsSeconds": events,
		"runtimeWeaponSeRequests": feedback.get("weaponSeRequests", []),
		"reelDecision": "not_attached",
	}


func _run_max_legal_speed(seconds: float, weapon_ids: Array = ["fansa_climax", "buzz_thumbnail_rod"]) -> Dictionary:
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
	var game_weapon_data: Array = game.get("weapons") as Array
	var null_weapon := WeaponSystemScript.find_weapon(game_weapon_data, "phase1_null_weapon", {})
	game.set("current_weapon", null_weapon)
	game.set("current_weapon_id", "phase1_null_weapon")
	var equipment: Array = []
	var equipment_timers: Dictionary = {}
	for weapon_id in weapon_ids:
		equipment.append({"id": weapon_id, "level": 1})
		equipment_timers[weapon_id] = 0.0
	game.set("player_weapons", equipment)
	game.set("equipment_weapon_timers", equipment_timers)
	game.set("hit_fx", [])
	game.set("player_bullets", [])
	game.set("enemy_bullets", [])
	game.set("destructibles", [])
	game.set("exp_orbs", [])
	game.set("drop_items", [])
	game.set("boomerang_hits", {})
	game.set("enemies", _dense_enemies(Vector2(800.0, 450.0), 24, 250.0))
	var game_pool := game.get("weapon_activation_se_pool") as Node
	game_pool.call("stop_all")
	game_pool.call("reset_debug_counters")
	var fansa_attacks: Dictionary = {}
	var fansa_steps := {"1": 0, "2": 0, "3": 0}
	var buzz_attacks: Dictionary = {}
	var fansa_peak_active := 0
	var buzz_peak_active := 0
	var arena := game.call("_current_arena") as Rect2
	var step_count := int(ceil(seconds / SIMULATION_STEP))
	for _step in range(step_count):
		# The game process is disabled here, so advance its orbit/feedback clock explicitly.
		game.set("elapsed", float(_step) * SIMULATION_STEP)
		game.call("_update_weapons", SIMULATION_STEP, arena)
		for fx_value in game.get("hit_fx") as Array:
			var fx: Dictionary = fx_value as Dictionary
			var kind := String(fx.get("kind", ""))
			if kind == "fansa_climax_hit":
				var attack_id := String(fx.get("attackInstanceId", ""))
				if attack_id != "" and not fansa_attacks.has(attack_id):
					fansa_attacks[attack_id] = true
					var step_key := str(int(fx.get("comboStep", 0)) + 1)
					fansa_steps[step_key] = int(fansa_steps.get(step_key, 0)) + 1
			elif kind == "buzz_thumbnail_rod_cast":
				var claim_token := String(fx.get("collectionClaimToken", ""))
				if claim_token != "":
					buzz_attacks[claim_token] = true
		var active_snapshot: Dictionary = game_pool.call("debug_snapshot") as Dictionary
		fansa_peak_active = maxi(fansa_peak_active, _active_path_count(active_snapshot, FANSA_SE_PATHS))
		buzz_peak_active = maxi(buzz_peak_active, _active_path_count(active_snapshot, [ROD_CAST_SE_PATH]))
		var feedback: Dictionary = WeaponSystemScript.update_hit_fx_for_target(game, SIMULATION_STEP, arena, game.get("rng") as RandomNumberGenerator)
		game.call("_apply_hit_reaction_feedback", feedback)
		await get_tree().create_timer(SIMULATION_STEP, true, false, true).timeout
	var snapshot: Dictionary = game_pool.call("debug_snapshot") as Dictionary
	var started_by_path: Dictionary = snapshot.get("startedByPath", {}) as Dictionary
	var fansa_started := 0
	var fansa_skipped := 0
	for path in FANSA_SE_PATHS:
		fansa_started += int(started_by_path.get(path, 0))
		fansa_skipped += int((snapshot.get("skippedByPath", {}) as Dictionary).get(path, 0))
	var buzz_started := int(started_by_path.get(ROD_CAST_SE_PATH, 0))
	var buzz_skipped := int((snapshot.get("skippedByPath", {}) as Dictionary).get(ROD_CAST_SE_PATH, 0))
	if weapon_ids.has("maro_comment_ring"):
		var ring := WeaponSystemScript.find_weapon(game_weapon_data, "maro_comment_ring", {})
		var ring_path := String(ring.get("activationSePath", ""))
		var ring_requests := int(started_by_path.get(ring_path, 0)) + int((snapshot.get("skippedByPath", {}) as Dictionary).get(ring_path, 0))
		var expected_ring_requests := 1 + int(floor(float(step_count - 1) * SIMULATION_STEP * WeaponSystemScript.orbit_speed(ring) / TAU))
		_check(ring_requests == expected_ring_requests, "full evolved mix did not exercise recurring ring cues")
	_check(int(snapshot.get("skippedCount", -1)) == 0, "maximum legal-speed evolved weapon mix exceeded the activation SE pool")
	_check(int(snapshot.get("loadFailureCount", -1)) == 0, "maximum legal-speed evolved weapon mix had an audio load failure")
	_check(int(snapshot.get("peakActiveCount", 0)) <= CAPACITY, "maximum legal-speed evolved weapon mix exceeded finite capacity")
	_check(fansa_started == fansa_attacks.size(), "fansa climax emitted other than one started SE per attack")
	_check(buzz_started == buzz_attacks.size(), "buzz rod emitted other than one started cast SE per attack")
	for path in FANSA_SE_PATHS:
		_check(int(started_by_path.get(path, 0)) > 0, "maximum legal-speed test did not exercise %s" % path)
	_check(buzz_started > 0, "maximum legal-speed test did not exercise buzz cast SE")
	var result := {
		"seconds": seconds,
		"stepSeconds": SIMULATION_STEP,
		"equipmentIntervalRate": pow(0.92, 5.0),
		"shopAttackIntervalMultiplier": 0.90,
		"songHeatLevel": 5,
		"weapons": weapon_ids.duplicate(),
		"fansaAttackCount": fansa_attacks.size(),
		"fansaStepCounts": fansa_steps,
		"fansaStartedCount": fansa_started,
		"fansa": {"requestCount": fansa_attacks.size(), "startedCount": fansa_started, "skippedCount": fansa_skipped, "peakActiveCount": fansa_peak_active},
		"buzzAttackCount": buzz_attacks.size(),
		"buzzStartedCount": buzz_started,
		"buzz": {"requestCount": buzz_attacks.size(), "startedCount": buzz_started, "skippedCount": buzz_skipped, "peakActiveCount": buzz_peak_active},
		"pool": snapshot,
	}
	game.free()
	await get_tree().process_frame
	return result


func _context(weapon: Dictionary, weapon_id: String, timers: Dictionary, enemies: Array, level: int = 1) -> Dictionary:
	return {
		"delta": 0.0,
		"weaponData": weapons,
		"playerWeapons": [{"id": weapon_id, "level": level}],
		"mainWeaponId": weapon_id,
		"timers": timers,
		"playerPos": Vector2.ZERO,
		"facingDir": Vector2.RIGHT,
		"playerVel": Vector2.ZERO,
		"manualAimDirection": Vector2.ZERO,
		"moveInput": Vector2.ZERO,
		"enemies": enemies,
		"destructibles": [],
		"enemyBullets": [],
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
		"weaponMute": false,
	}


func _dense_enemies(center: Vector2, count: int, radius: float) -> Array:
	var result: Array = []
	for index in range(count):
		var angle := TAU * float(index) / float(maxi(1, count))
		var distance := radius + float(index % 4) * 6.0
		result.append({
			"kind": "enemy_dot_invader",
			"uid": index + 1000,
			"spawnToken": "evolved-weapon-se:%d" % index,
			"pos": center + Vector2.RIGHT.rotated(angle) * distance,
			"hp": 1000000.0,
			"max_hp": 1000000.0,
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


func _front_enemies(count: int, radius: float) -> Array:
	var result := _dense_enemies(Vector2.ZERO, count, radius)
	for index in range(result.size()):
		var ratio := float(index) / float(maxi(1, result.size() - 1))
		var angle := deg_to_rad(lerpf(-18.0, 18.0, ratio))
		(result[index] as Dictionary)["pos"] = Vector2.RIGHT.rotated(angle) * (radius + float(index % 3) * 2.0)
	return result


func _activation_fx(items: Array) -> Array:
	var result: Array = []
	for value in items:
		var fx: Dictionary = value as Dictionary
		if String(fx.get("activationSePath", "")) != "":
			result.append(fx)
	return result


func _active_path_count(snapshot: Dictionary, paths: Array) -> int:
	var count := 0
	for value in snapshot.get("slots", []) as Array:
		var slot: Dictionary = value as Dictionary
		if bool(slot.get("reserved", false)) and paths.has(String(slot.get("path", ""))):
			count += 1
	return count


func _find_fx(items: Array, kind: String) -> Dictionary:
	for value in items:
		var fx: Dictionary = value as Dictionary
		if String(fx.get("kind", "")) == kind:
			return fx
	return {}


func _audio_lengths() -> Dictionary:
	var result := {}
	for path in FANSA_SE_PATHS + [ROD_CAST_SE_PATH, ROD_REEL_SE_PATH]:
		var stream := ResourceLoader.load(path) as AudioStream
		result[path] = snappedf(stream.get_length(), 0.0001) if stream != null else -1.0
	return result


func _stress_seconds() -> float:
	var configured := OS.get_environment("EVOLVED_WEAPON_SE_STRESS_SECONDS")
	return maxf(0.0, float(configured)) if configured != "" else DEFAULT_STRESS_SECONDS


func _reset_pool() -> void:
	pool.stop_all()
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


func _write_optional_evidence() -> void:
	var output_path := OS.get_environment("EVOLVED_WEAPON_SE_EVIDENCE_PATH")
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
