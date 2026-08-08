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
	_check(String(shield_weapon.get("stage2Behavior", "")) == "front_shield", "shield did not opt into front-shield behavior", failures)
	_check(is_equal_approx(float(shield_weapon.get("activeDuration", 0.0)), 4.00), "shield active duration data changed", failures)
	_check(is_equal_approx(float(shield_weapon.get("activationInterval", 0.0)), 5.50), "shield activation interval data changed", failures)
	_check(is_equal_approx(float(shield_weapon.get("attackInterval", 0.0)), 5.50), "shield attack interval bridge changed", failures)
	_check(String(shield_weapon.get("activationSePath", "")) == "res://assets/audio/moderator_shield_activate.mp3", "shield activation SE path changed", failures)
	_check(FileAccess.file_exists(String(shield_weapon.get("activationSePath", ""))), "shield activation SE asset missing", failures)
	_check(is_equal_approx(float(shield_weapon.get("arcDegrees", 0.0)), 100.0), "shield arc data changed", failures)
	_check(int((shield_weapon.get("evolution", {}) as Dictionary).get("requiredExpLevel", 0)) == 5, "shield evolution EXP level is not five", failures)
	var expected_shield_durations := [4.00, 4.00, 4.50, 4.50, 5.00]
	var expected_shield_gaps := [1.50, 1.50, 1.00, 1.00, 0.50]
	for level_index in range(expected_shield_durations.size()):
		var level_data := WeaponSystem._stage2_level_data(shield_weapon, level_index + 1)
		_check(is_equal_approx(float(level_data.get("activeDuration", 0.0)), float(expected_shield_durations[level_index])), "shield Lv%d active duration" % (level_index + 1), failures)
		_check(is_equal_approx(float(level_data.get("activationInterval", 0.0)), 5.50), "shield Lv%d activation interval" % (level_index + 1), failures)
		_check(is_equal_approx(float(level_data.get("activationInterval", 0.0)) - float(level_data.get("activeDuration", 0.0)), float(expected_shield_gaps[level_index])), "shield Lv%d idle gap" % (level_index + 1), failures)
	var shield_context := _context(shield_weapon, "moderator_shield", [_enemy("shield_target", Vector2(90, 0), 100.0)], [])
	var shield_no_target := WeaponSystem.update_equipment_weapons(_context_with(shield_weapon, "moderator_shield", [], {}))
	_check(is_equal_approx(float((shield_no_target["timers"] as Dictionary).get("moderator_shield", 0.0)), 5.50), "shield cooldown did not start on deployment", failures)
	_check((shield_no_target["hitFx"] as Array).size() == 2, "shield did not deploy with its construction effect", failures)
	var shield_active := _fx_by_kind(shield_no_target["hitFx"] as Array, "moderator_shield_active")
	_check(not _fx_by_kind(shield_no_target["hitFx"] as Array, "moderator_shield_deploy").is_empty(), "shield construction effect was not separated", failures)
	_check(is_equal_approx(float(shield_active.get("maxLife", 0.0)), 4.00), "shield runtime duration did not use Lv1 data", failures)
	_check(String(shield_active.get("activationSePath", "")) == String(shield_weapon.get("activationSePath", "")), "shield deployment did not request its activation SE", failures)
	var shield_lifetime_fx: Array = [shield_active.duplicate(true)]
	shield_lifetime_fx = WeaponSystem.update_hit_fx(shield_lifetime_fx, 3.99, [], [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(shield_lifetime_fx.size() == 1, "shield expired before 4.0 seconds", failures)
	var shield_late_enemy := _enemy("shield_late_target", Vector2(90, 0), 100.0)
	var shield_late_bullet := {"pos": Vector2(90, 0), "vel": Vector2.ZERO, "life": 1.0, "hitRadius": 6.0, "shieldBlockable": true}
	WeaponSystem.update_hit_fx(shield_lifetime_fx, 0.0, [shield_late_enemy], [], [shield_late_bullet], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(float(shield_late_enemy.get("hp", 100.0)) < 100.0 and float(shield_late_bullet.get("life", 1.0)) <= 0.0, "shield lost contact or bullet defense before duration ended", failures)
	shield_lifetime_fx = WeaponSystem.update_hit_fx(shield_lifetime_fx, 0.01, [], [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(_fx_by_kind(shield_lifetime_fx, "moderator_shield_active").is_empty(), "shield gameplay field remained after 4.0 seconds", failures)
	_check(not _fx_by_kind(shield_lifetime_fx, "moderator_shield_end").is_empty(), "shield did not leave a short visual-only end fade", failures)
	var shield_stacking_context := _context_with(shield_weapon, "moderator_shield", [], {"moderator_shield": 0.0})
	shield_stacking_context["activeFx"] = [shield_active]
	var shield_stacking_result := WeaponSystem.update_equipment_weapons(shield_stacking_context)
	_check((shield_stacking_result["hitFx"] as Array).is_empty(), "shield stacked while an active shield remained", failures)
	var shield_result := WeaponSystem.update_equipment_weapons(shield_context)
	_check((shield_result["hitFx"] as Array).size() == 2, "shield did not spawn active/deploy FX", failures)
	var shield_enemies: Array = shield_context["enemies"] as Array
	var shield_fx: Array = shield_result["hitFx"] as Array
	WeaponSystem.update_hit_fx(shield_fx, 0.25, shield_enemies, [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(float((shield_enemies[0] as Dictionary).get("hp", 100.0)) < 100.0, "shield did not route damage through enemy hit path", failures)
	_check(not (shield_fx[0] as Dictionary).has("bulletClears"), "shield retained a bullet-clear cap", failures)
	var shield_bullets: Array = [
		{"pos": Vector2(90, 0), "vel": Vector2.ZERO, "life": 1.0, "hitRadius": 6.0, "shieldBlockable": true},
		{"pos": Vector2(90, 0), "vel": Vector2.ZERO, "life": 1.0, "hitRadius": 6.0, "shieldBlockable": false}
	]
	WeaponSystem.update_hit_fx(shield_fx, 0.0, [], [], shield_bullets, [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(float(shield_bullets[0].get("life", 1.0)) == 0.0 and float(shield_bullets[1].get("life", 0.0)) > 0.0, "shield projectile eligibility was not explicit", failures)
	var shield_visual_debug := WeaponSystem.shield_visual_debug_state(shield_fx, "moderator_shield")
	_check(bool(shield_visual_debug.get("deployEffectPlayed", false)) and bool(shield_visual_debug.get("idleEffectActive", false)), "shield visual phase debug state missing", failures)
	_check(int(shield_visual_debug.get("hitEffectCount", 0)) >= 1 and int(shield_visual_debug.get("blockEffectCount", 0)) >= 1, "shield hit/block visual counters missing", failures)
	_check(not bool(shield_visual_debug.get("legacyTrailEffect", true)), "shield legacy trail debug state was enabled", failures)
	var shield_box := _gift_box(1001, Vector2(90, 0))
	var shield_box_fx: Array = (WeaponSystem.update_equipment_weapons(_context_with(shield_weapon, "moderator_shield", [], {}))["hitFx"] as Array)
	var shield_destroyed_boxes: Array = []
	WeaponSystem.update_hit_fx(shield_box_fx, 0.0, [], [shield_box], [], [], shield_destroyed_boxes, {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(float(shield_box.get("hp", 1.0)) <= 0.0 and shield_destroyed_boxes.size() == 1, "shield did not damage a field gift", failures)
	_check(WeaponSystem.shield_fan_contains_point(Vector2.ZERO, Vector2.RIGHT, 80.0, 100.0, Vector2(60, 0)), "shield forward fan boundary rejected", failures)
	_check(not WeaponSystem.shield_fan_contains_point(Vector2.ZERO, Vector2.RIGHT, 80.0, 100.0, Vector2(0, 60)), "shield accepted outside 100 degree fan", failures)
	_check(WeaponSystem.shield_fan_contains_point(Vector2.ZERO, Vector2.RIGHT, 100.0, 220.0, Vector2(0, 80)), "fortress side fan rejected", failures)
	_check(not WeaponSystem.shield_fan_contains_point(Vector2.ZERO, Vector2.RIGHT, 100.0, 220.0, Vector2(-80, 0)), "fortress rear opening was not preserved", failures)
	var rotated := WeaponSystem.shield_rotation_step(Vector2.RIGHT, Vector2.UP, 0.1, 1080.0)
	_check(absf(rotated.angle()) <= deg_to_rad(108.0) + 0.01, "shield rotation exceeded configured speed", failures)
	var idle_left_direction := WeaponSystem._shield_direction_from_context({
		"moveInput": Vector2.ZERO, "playerVel": Vector2.ZERO,
		"lastMoveDirection": Vector2.RIGHT, "facingDir": Vector2.LEFT
	}, Vector2.LEFT)
	_check(idle_left_direction.is_equal_approx(Vector2.LEFT), "shield abandoned its held left direction while idle", failures)
	var deployed_left_direction := WeaponSystem._shield_direction_from_context({
		"moveInput": Vector2.ZERO, "playerVel": Vector2.ZERO,
		"lastMoveDirection": Vector2.RIGHT, "facingDir": Vector2.LEFT
	})
	_check(deployed_left_direction.is_equal_approx(Vector2.LEFT), "shield ignored left-facing deployment while idle", failures)
	var turning_shield := {"dir": Vector2.RIGHT, "targetDir": Vector2.LEFT, "offset": 52.0, "rotationSpeedDegrees": 360.0}
	WeaponSystem._shield_pose(turning_shield, 0.25, Vector2.ZERO, {
		"moveInput": Vector2.ZERO, "playerVel": Vector2.ZERO,
		"lastMoveDirection": Vector2.RIGHT, "facingDir": Vector2.LEFT
	})
	_check(absf(Vector2(turning_shield.get("dir", Vector2.RIGHT)).angle()) > deg_to_rad(89.0), "shield stopped turning after left input was released", failures)
	var rehit_enemy := _enemy("shield_rehit", Vector2(90, 0), 100.0)
	var rehit_fx: Array = (WeaponSystem.update_equipment_weapons(_context(shield_weapon, "moderator_shield", [rehit_enemy], []))["hitFx"] as Array)
	WeaponSystem.update_hit_fx(rehit_fx, 0.10, [rehit_enemy], [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	var hp_after_first := float(rehit_enemy.get("hp", 100.0))
	WeaponSystem.update_hit_fx(rehit_fx, 0.10, [rehit_enemy], [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(is_equal_approx(float(rehit_enemy.get("hp", 0.0)), hp_after_first), "shield rehit interval was not enforced", failures)
	WeaponSystem.update_hit_fx(rehit_fx, 0.40, [rehit_enemy], [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(float(rehit_enemy.get("hp", 100.0)) < hp_after_first, "shield did not rehit after cooldown", failures)

	var fortress_weapon := WeaponSystem.find_weapon(weapons, "moderator_fortress", {})
	_check(is_equal_approx(float(fortress_weapon.get("activeDuration", 0.0)), 7.00), "fortress active duration data changed", failures)
	_check(is_equal_approx(float(fortress_weapon.get("activationInterval", 0.0)), 7.50), "fortress activation interval data changed", failures)
	_check(is_equal_approx(float(fortress_weapon.get("attackInterval", 0.0)), 7.50), "fortress attack interval bridge changed", failures)
	_check(is_equal_approx(float(fortress_weapon.get("activationInterval", 0.0)) - float(fortress_weapon.get("activeDuration", 0.0)), 0.50), "fortress idle gap changed", failures)
	var fortress_enemy := _enemy("fortress_target", Vector2(80, -80), 1000.0)
	var fortress_result := WeaponSystem.update_equipment_weapons(_context(fortress_weapon, "moderator_fortress", [fortress_enemy], []))
	_check((fortress_result["hitFx"] as Array).size() == 3, "fortress did not deploy with construction and shockwave FX", failures)
	var fortress_fx: Array = fortress_result["hitFx"] as Array
	_check(is_equal_approx(float((fortress_result["timers"] as Dictionary).get("moderator_fortress", 0.0)), 7.50), "fortress cooldown did not start at 7.5 seconds", failures)
	var fortress_active: Dictionary = {}
	for fortress_fx_item in fortress_fx:
		var fortress_fx_data: Dictionary = fortress_fx_item as Dictionary
		if String(fortress_fx_data.get("kind", "")) == "moderator_fortress_active":
			fortress_active = fortress_fx_data
			break
	_check(is_equal_approx(float(fortress_active.get("maxLife", 0.0)), 7.00), "fortress runtime duration did not use data", failures)
	var fortress_visual_debug := WeaponSystem.shield_visual_debug_state(fortress_fx, "moderator_fortress")
	_check(bool(fortress_visual_debug.get("deployEffectPlayed", false)) and bool(fortress_visual_debug.get("shockwaveEffectPlayed", false)) and bool(fortress_visual_debug.get("idleEffectActive", false)), "fortress visual phase debug state missing", failures)
	_check(not bool(fortress_visual_debug.get("legacyTrailEffect", true)), "fortress legacy trail debug state was enabled", failures)
	var fortress_stacking_context := _context_with(fortress_weapon, "moderator_fortress", [], {"moderator_fortress": 0.0})
	fortress_stacking_context["activeFx"] = [fortress_active]
	var fortress_stacking_result := WeaponSystem.update_equipment_weapons(fortress_stacking_context)
	_check((fortress_stacking_result["hitFx"] as Array).is_empty(), "fortress stacked while an active fortress remained", failures)
	var fortress_lifetime_fx: Array = [fortress_active.duplicate(true)]
	fortress_lifetime_fx = WeaponSystem.update_hit_fx(fortress_lifetime_fx, 6.99, [], [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(fortress_lifetime_fx.size() == 1, "fortress expired before 7.0 seconds", failures)
	var fortress_late_enemy := _enemy("fortress_late_target", Vector2(50, 80), 100.0)
	var fortress_late_bullet := {"pos": Vector2(50, 80), "vel": Vector2.ZERO, "life": 1.0, "hitRadius": 6.0, "shieldBlockable": true}
	WeaponSystem.update_hit_fx(fortress_lifetime_fx, 0.0, [fortress_late_enemy], [], [fortress_late_bullet], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(float(fortress_late_enemy.get("hp", 100.0)) < 100.0 and float(fortress_late_bullet.get("life", 1.0)) <= 0.0, "fortress lost side contact or bullet defense before duration ended", failures)
	fortress_lifetime_fx = WeaponSystem.update_hit_fx(fortress_lifetime_fx, 0.01, [], [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(_fx_by_kind(fortress_lifetime_fx, "moderator_fortress_active").is_empty(), "fortress gameplay field remained after 7.0 seconds", failures)
	_check(not _fx_by_kind(fortress_lifetime_fx, "moderator_fortress_end").is_empty(), "fortress did not leave a short visual-only end fade", failures)
	WeaponSystem.update_hit_fx(fortress_fx, 0.0, [fortress_enemy], [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	var fortress_hp_after_deploy := float(fortress_enemy.get("hp", 1000.0))
	_check(fortress_hp_after_deploy < 1000.0, "fortress deployment shockwave did not hit", failures)
	WeaponSystem.update_hit_fx(fortress_fx, 0.1, [fortress_enemy], [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(is_equal_approx(float(fortress_enemy.get("hp", 0.0)), fortress_hp_after_deploy), "fortress shockwave and contact double-hit", failures)

	var baton_weapon := WeaponSystem.find_weapon(weapons, "fansa_baton", {})
	var expected_baton_se_paths := [
		"res://assets/audio/fansa_baton_combo_1.mp3",
		"res://assets/audio/fansa_baton_combo_2.mp3",
		"res://assets/audio/fansa_baton_combo_3.mp3"
	]
	var configured_baton_se: Array = baton_weapon.get("comboAttackSe", []) as Array
	_check(configured_baton_se.size() == 3, "baton combo SE data does not contain three entries", failures)
	for baton_se_path in expected_baton_se_paths:
		_check(FileAccess.file_exists(String(baton_se_path)), "baton combo SE asset missing: %s" % String(baton_se_path), failures)
		_check(ResourceLoader.load(String(baton_se_path)) is AudioStream, "baton combo SE could not be loaded: %s" % String(baton_se_path), failures)
	var baton_timers: Dictionary = {}
	var baton_enemies: Array = [_enemy("baton_target", Vector2(80, 0), 1000.0)]
	for expected_step in [0, 1, 2]:
		baton_timers["fansa_baton"] = 0.0
		var baton_result := WeaponSystem.update_equipment_weapons(_context_with(baton_weapon, "fansa_baton", baton_enemies, baton_timers))
		var stage_states: Dictionary = baton_timers.get("__stage2WeaponStates", {}) as Dictionary
		var baton_state: Dictionary = stage_states.get("fansa_baton", {}) as Dictionary
		_check(int(baton_state.get("comboStep", -1)) == (expected_step + 1) % 3, "baton combo did not advance from step %d" % expected_step, failures)
		_check(not (baton_result["hitFx"] as Array).is_empty(), "baton step %d did not produce visual FX" % expected_step, failures)
		var baton_attack_fx: Dictionary = {}
		for baton_fx_item in (baton_result["hitFx"] as Array):
			var baton_fx_data: Dictionary = baton_fx_item as Dictionary
			if String(baton_fx_data.get("kind", "")) == "fansa_baton_hit":
				baton_attack_fx = baton_fx_data
				break
		_check(String(baton_attack_fx.get("activationSePath", "")) == String(expected_baton_se_paths[expected_step]), "baton step %d used the wrong SE" % expected_step, failures)
	baton_timers["fansa_baton"] = 0.0
	var baton_before: Dictionary = (baton_timers.get("__stage2WeaponStates", {}) as Dictionary).get("fansa_baton", {}) as Dictionary
	var baton_empty := WeaponSystem.update_equipment_weapons(_context_with(baton_weapon, "fansa_baton", [], baton_timers))
	var baton_after: Dictionary = (baton_timers.get("__stage2WeaponStates", {}) as Dictionary).get("fansa_baton", {}) as Dictionary
	_check(int(baton_after.get("comboStep", -1)) == (int(baton_before.get("comboStep", 0)) + 1) % 3, "baton did not create its fallback swing without a target", failures)
	_check(not (baton_empty["hitFx"] as Array).is_empty(), "baton did not create a fallback swing without a target", failures)
	var baton_box := _gift_box(1002, Vector2(80, 0))
	var baton_box_context := _context_with(baton_weapon, "fansa_baton", [], {})
	baton_box_context["destructibles"] = [baton_box]
	var baton_box_result := WeaponSystem.update_equipment_weapons(baton_box_context)
	_check(not (baton_box_result["hitFx"] as Array).is_empty(), "baton did not target a field gift without enemies", failures)
	_check(float(baton_box.get("hp", 1.0)) <= 0.0 and (baton_box_result["destroyedBoxes"] as Array).size() == 1, "baton did not damage a field gift", failures)

	var rod_weapon := WeaponSystem.find_weapon(weapons, "tsuri_thumbnail_rod", {})
	var rod_cast_se_path := "res://assets/audio/tsuri_thumbnail_rod_cast.mp3"
	var rod_reel_se_path := "res://assets/audio/tsuri_thumbnail_rod_reel.mp3"
	for rod_se_path in [rod_cast_se_path, rod_reel_se_path]:
		_check(FileAccess.file_exists(rod_se_path), "rod SE asset missing: %s" % rod_se_path, failures)
		_check(ResourceLoader.load(rod_se_path) is AudioStream, "rod SE could not be loaded: %s" % rod_se_path, failures)
	var rod_target := _enemy("rod_target", Vector2(100, 0), 100.0)
	var rod_path_target := _enemy("rod_path", Vector2(50, 0), 100.0)
	var rod_enemies: Array = [rod_target, rod_path_target]
	var rod_timers: Dictionary = {}
	var rod_result := WeaponSystem.update_equipment_weapons(_context_with(rod_weapon, "tsuri_thumbnail_rod", rod_enemies, rod_timers))
	var rod_fx: Array = rod_result["hitFx"] as Array
	_check(rod_fx.size() == 1, "rod did not create one cast", failures)
	_check(String((rod_fx[0] as Dictionary).get("activationSePath", "")) == rod_cast_se_path, "rod cast used the wrong SE", failures)
	WeaponSystem.update_hit_fx(rod_fx, 0.2, rod_enemies, [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(String((rod_fx[0] as Dictionary).get("phase", "")) == "gathering", "rod did not land on its target", failures)
	WeaponSystem.update_hit_fx(rod_fx, 0.22, rod_enemies, [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	var rod_reel_feedback: Dictionary = {}
	WeaponSystem.update_hit_fx(rod_fx, 0.70, rod_enemies, [], [], [], [], rod_reel_feedback, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	var rod_se_requests: Array = rod_reel_feedback.get("weaponSeRequests", []) as Array
	_check(rod_se_requests.size() == 1 and String((rod_se_requests[0] as Dictionary).get("action", "")) == "play" and String((rod_se_requests[0] as Dictionary).get("path", "")) == rod_reel_se_path, "rod reel transition did not request its SE once", failures)
	var rod_finish_feedback: Dictionary = {}
	WeaponSystem.update_hit_fx(rod_fx, 0.10, rod_enemies, [], [], [], [], rod_finish_feedback, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	var rod_stop_requests: Array = rod_finish_feedback.get("weaponSeRequests", []) as Array
	_check(rod_stop_requests.size() == 1 and String((rod_stop_requests[0] as Dictionary).get("action", "")) == "stop" and String((rod_stop_requests[0] as Dictionary).get("path", "")) == rod_reel_se_path, "rod attack end did not stop its reel SE", failures)
	_check(float(rod_target.get("hp", 100.0)) < 100.0 and float(rod_path_target.get("hp", 100.0)) < 100.0, "rod did not apply initial/path damage", failures)
	var collab_rod_target := _enemy("collab_comparison_troll", Vector2(100, 0), 100.0)
	collab_rod_target["canBePulled"] = false
	var collab_rod_enemies: Array = [collab_rod_target]
	var collab_rod_result := WeaponSystem.update_equipment_weapons(_context_with(rod_weapon, "tsuri_thumbnail_rod", collab_rod_enemies, {}))
	var collab_rod_fx: Array = collab_rod_result["hitFx"] as Array
	_check(collab_rod_fx.size() == 1, "rod did not cast at a non-pullable collab enemy", failures)
	WeaponSystem.update_hit_fx(collab_rod_fx, 0.2, collab_rod_enemies, [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(float(collab_rod_target.get("hp", 100.0)) < 100.0, "rod did not damage a non-pullable collab enemy", failures)
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

func _fx_by_kind(items: Array, kind: String) -> Dictionary:
	for item in items:
		var fx: Dictionary = item as Dictionary
		if String(fx.get("kind", "")) == kind:
			return fx
	return {}

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
