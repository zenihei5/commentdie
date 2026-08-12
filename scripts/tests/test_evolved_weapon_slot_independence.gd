extends Node

const WeaponSystemScript := preload("res://scripts/systems/weapon_system.gd")
const WeaponEvolutionSystemScript := preload("res://scripts/systems/weapon_evolution_system.gd")
const GiftSystemScript := preload("res://scripts/systems/gift_system.gd")
const DrawDataSystemScript := preload("res://scripts/systems/draw_data_system.gd")
const TestTargetScript := preload("res://scripts/tests/slot_independence_test_target.gd")

var weapons: Array = []
var gifts: Array = []
var failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	weapons = JSON.parse_string(FileAccess.get_file_as_string("res://data/weapons.json")) as Array
	gifts = JSON.parse_string(FileAccess.get_file_as_string("res://data/gifts.json")) as Array
	_check(not weapons.is_empty(), "weapon registry parsed", failures)
	_check(not gifts.is_empty(), "gift registry parsed", failures)
	_test_evolution_apply_and_side_starlight()
	_test_side_ban_judgement()
	_test_side_maro_comment_ring()
	_test_initial_main_routes_are_not_duplicated()
	_test_remaining_evolved_slot_routes()
	_test_pause_and_cleanup()
	if failures.is_empty():
		print("EVOLVED_WEAPON_SLOT_INDEPENDENCE_TESTS: PASS")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("EVOLVED_WEAPON_SLOT_INDEPENDENCE_TESTS: FAIL (%d)" % failures.size())
	get_tree().quit(1)


func _test_evolution_apply_and_side_starlight() -> void:
	var target := _make_superchat_side_target()
	var evolution_gift := WeaponEvolutionSystemScript.evolution_gift_for_target(target, weapons)
	_check(String(evolution_gift.get("evolvedWeaponId", "")) == "starlight_superchat", "side starlight evolution gift resolves", failures)
	var apply_result := GiftSystemScript.apply_gift_to_target(target, evolution_gift)
	_check(not (apply_result.get("weaponEvolution", {}) as Dictionary).is_empty(), "side starlight evolution applies through GiftSystem", failures)
	_check(int(target.superchat_level) == 0, "side starlight does not depend on superchat_level", failures)

	var enemy := _enemy(1, Vector2(100.0, 0.0), 100.0, 20.0)
	var entries: Array = target.player_weapons
	var first := _update("ban_hammer", entries, [enemy], [], [], {}, [], 0.0, 0.0, false)
	var first_bullets: Array = first.get("playerBullets", []) as Array
	_check(first_bullets.size() == 3, "side starlight fires one three-shot volley", failures)
	_check(bool(first.get("superchatShotFired", false)), "side starlight OR-merges the firing SE flag", failures)
	for bullet_value in first_bullets:
		var bullet: Dictionary = bullet_value as Dictionary
		_check(String(bullet.get("owner", "")) == "starlight_superchat" and String(bullet.get("weaponId", "")) == "starlight_superchat", "side starlight bullet keeps source ID", failures)

	var hit_context_result := _update("ban_hammer", entries, [enemy], [], [], first.get("equipmentWeaponTimers", {}) as Dictionary, first_bullets, 0.15, 0.15, false)
	_check(float(enemy.get("hp", 0.0)) < 100.0 and String(enemy.get("lastHitSource", "")) == "starlight_superchat", "side starlight hit uses bullet registry source", failures)
	_check(_has_fx_with_owner(hit_context_result.get("hitFx", []) as Array, "starlight_superchat"), "side starlight hit FX keeps owner", failures)

	var premium_timers: Dictionary = {}
	var premium_bullets: Array = []
	var premium_found := false
	for volley in range(5):
		var volley_result := _update("ban_hammer", entries, [_enemy(20 + volley, Vector2(100.0, 0.0), 100.0, 20.0)], [], [], premium_timers, premium_bullets, float(volley) * 0.5, 0.5 if volley > 0 else 0.0, false)
		premium_timers = volley_result.get("equipmentWeaponTimers", {}) as Dictionary
		premium_bullets = []
		for bullet_value in volley_result.get("playerBullets", []) as Array:
			if String((bullet_value as Dictionary).get("visualKind", "")) == "high_superchat":
				premium_found = true
	_check(premium_found, "side starlight fifth volley creates the premium shot", failures)

	var box_volley := _update("ban_hammer", entries, [_enemy(2, Vector2(100.0, 0.0), 100.0, 20.0)], [], [], {}, [], 0.0, 0.0, false)
	var box_result := _update("ban_hammer", entries, [], [_box(2, Vector2.ZERO)], [], box_volley.get("equipmentWeaponTimers", {}) as Dictionary, box_volley.get("playerBullets", []).duplicate(true), 0.0, 0.0, false)
	_check((box_result.get("destroyedBoxes", []) as Array).size() == 1, "side starlight damages a box", failures)
	var enemy_bullet := {"pos": Vector2.ZERO, "life": 1.0, "hitRadius": 8.0}
	var clash_volley := _update("ban_hammer", entries, [_enemy(3, Vector2(100.0, 0.0), 100.0, 20.0)], [], [], {}, [], 0.0, 0.0, false)
	var clash_result := _update("ban_hammer", entries, [], [], [enemy_bullet], clash_volley.get("equipmentWeaponTimers", {}) as Dictionary, clash_volley.get("playerBullets", []).duplicate(true), 0.0, 0.0, false)
	_check(float(enemy_bullet.get("life", 1.0)) <= 0.0, "side starlight cancels an enemy bullet", failures)


func _test_side_ban_judgement() -> void:
	var entries: Array = [
		{"id": "superchat_shot", "level": 1},
		{"id": "ban_judgement", "level": 1, "isEvolved": true, "baseWeaponId": "ban_hammer"}
	]
	var near_enemy := _enemy(30, Vector2(60.0, 0.0), 100.0, 20.0)
	var shockwave_enemy := _enemy(31, Vector2(300.0, 0.0), 100.0, 20.0)
	var bullet := {"pos": Vector2(60.0, 0.0), "life": 1.0, "hitRadius": 8.0}
	var result := _update("superchat_shot", entries, [near_enemy, shockwave_enemy], [_box(3, Vector2(60.0, 0.0))], [bullet], {}, [], 0.0, 0.0, false)
	var effects: Array = result.get("hitFx", []) as Array
	var shockwave := _find_fx(effects, "ban_judgement_shockwave")
	_check(not shockwave.is_empty() and String(shockwave.get("owner", "")) == "ban_judgement" and String(shockwave.get("weaponId", "")) == "ban_judgement", "side BAN creates owned shockwave", failures)
	_check(is_equal_approx(float(result.get("equipmentWeaponTimers", {}).get("ban_judgement", 0.0)), 1.25), "side BAN has an independent 1.25 second timer", failures)
	_check(is_equal_approx(float(near_enemy.get("hp", 0.0)), 64.0), "side BAN direct hit is 36 (hp=%.2f)" % float(near_enemy.get("hp", 0.0)), failures)
	_check(is_equal_approx(float(shockwave_enemy.get("hp", 0.0)), 100.0), "side BAN shockwave target waits for its delayed phase", failures)
	_check(float(bullet.get("life", 1.0)) <= 0.0, "side BAN clears an enemy bullet", failures)
	_check(float((result.get("destroyedBoxes", []) as Array).size()) == 1.0, "side BAN damages a box", failures)

	var after_shockwave := WeaponSystemScript.update_hit_fx(effects, 0.20, [near_enemy, shockwave_enemy], [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	after_shockwave = WeaponSystemScript.update_hit_fx(after_shockwave, 0.0, [near_enemy, shockwave_enemy], [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	after_shockwave = WeaponSystemScript.update_hit_fx(after_shockwave, 0.30, [near_enemy, shockwave_enemy], [], [], [], [], {}, Rect2(-1000, -1000, 2000, 2000), [], Vector2.ZERO)
	_check(is_equal_approx(float(shockwave_enemy.get("hp", 0.0)), 76.0), "side BAN delayed shockwave is 24 (hp=%.2f)" % float(shockwave_enemy.get("hp", 0.0)), failures)
	_check(_find_fx(after_shockwave, "ban_judgement_shockwave").is_empty(), "side BAN shockwave completes once (remaining=%d)" % _find_all_fx(after_shockwave, "ban_judgement_shockwave").size(), failures)

	var blocked_result := _update("superchat_shot", entries, [shockwave_enemy], [], [], result.get("equipmentWeaponTimers", {}) as Dictionary, [], 0.1, 0.1, false)
	_check(_find_fx(blocked_result.get("hitFx", []) as Array, "ban_judgement_shockwave").is_empty(), "side BAN timer prevents a second same-frame attack", failures)


func _test_side_maro_comment_ring() -> void:
	var entries: Array = [
		{"id": "ban_hammer", "level": 1},
		{"id": "maro_comment_ring", "level": 1, "isEvolved": true, "baseWeaponId": "comment_boomerang"}
	]
	var resolved := WeaponSystemScript.resolve_equipped_weapon_for_base("comment_boomerang", _find_data(weapons, "ban_hammer"), entries, weapons)
	_check(bool(resolved.get("found", false)) and not bool(resolved.get("isMain", true)) and String((resolved.get("weapon", {}) as Dictionary).get("id", "")) == "maro_comment_ring", "maro side resolver returns evolved dictionary", failures)
	var draw_data := DrawDataSystemScript.boomerang_draw_data_for_weapon(Vector2.ZERO, resolved.get("weapon", {}) as Dictionary, 0, WeaponSystemScript.range_base(resolved.get("weapon", {}) as Dictionary), 0.0, {}, 0)
	_check(draw_data.size() == 7, "maro side draw data contains halo and six rings", failures)
	var ring_enemy := _enemy(40, Vector2(105.0, 0.0), 100.0, 20.0)
	var first := _update("ban_hammer", entries, [ring_enemy], [], [], {}, [], 0.0, 0.0, false)
	_check(float(ring_enemy.get("hp", 0.0)) <= 85.0 and String(ring_enemy.get("lastHitSource", "")) == "maro_comment_ring", "side maro ring deals evolved damage", failures)
	_check(_has_key_prefix(first.get("boomerangHits", {}) as Dictionary, "maro_comment_ring|"), "maro hit memory is weapon namespaced", failures)
	_check(bool(first.get("boomerangOrbitSe", false)) == false, "maro side does not overwrite an unrelated orbit SE state", failures)

	var pulse_enemy := _enemy(41, Vector2.ZERO, 100.0, 20.0)
	var pulse_result := _update("ban_hammer", entries, [pulse_enemy], [], [], first.get("equipmentWeaponTimers", {}) as Dictionary, [], 0.0, 2.0, false)
	_check(is_equal_approx(float(pulse_enemy.get("hp", 0.0)), 92.0), "side maro pulse deals 8", failures)
	_check(not _find_fx(pulse_result.get("hitFx", []) as Array, "maro_comment_pulse").is_empty(), "side maro pulse FX is emitted", failures)


func _test_initial_main_routes_are_not_duplicated() -> void:
	var starlight_entries: Array = [{"id": "starlight_superchat", "level": 1, "isEvolved": true, "baseWeaponId": "superchat_shot"}]
	var starlight_result := _update("starlight_superchat", starlight_entries, [_enemy(50, Vector2(100.0, 0.0), 100.0, 20.0)], [], [], {}, [], 0.0, 0.0, true)
	_check((starlight_result.get("playerBullets", []) as Array).size() == 3, "main starlight fires one volley without side duplication", failures)

	var ban_entries: Array = [{"id": "ban_judgement", "level": 1, "isEvolved": true, "baseWeaponId": "ban_hammer"}]
	var ban_result := _update("ban_judgement", ban_entries, [], [], [], {}, [], 0.0, 0.0, true)
	_check(_find_all_fx(ban_result.get("hitFx", []) as Array, "ban_judgement_shockwave").size() == 1, "main BAN creates one shockwave", failures)

	var maro_entries: Array = [{"id": "maro_comment_ring", "level": 1, "isEvolved": true, "baseWeaponId": "comment_boomerang"}]
	var maro_result := _update("maro_comment_ring", maro_entries, [_enemy(51, Vector2(105.0, 0.0), 100.0, 20.0)], [], [], {}, [], 0.0, 0.0, true)
	_check((maro_result.get("boomerangHits", {}) as Dictionary).size() == 1, "main maro ring is processed once", failures)


func _test_remaining_evolved_slot_routes() -> void:
	var ids: Array[String] = [
		"moderator_fortress", "fansa_climax", "buzz_thumbnail_rod",
		"full_voice_dome", "center_stage", "great_grassland", "comment_lockdown",
		"emote_festival", "all_block_laser", "listener_assembly"
	]
	for weapon_id in ids:
		var weapon := _find_data(weapons, weapon_id)
		var entry := {"id": weapon_id, "level": 1, "isEvolved": true, "baseWeaponId": String(weapon.get("baseWeaponId", ""))}
		var side_result := _update("ban_hammer", [{"id": "ban_hammer", "level": 1}, entry], [_enemy(100 + ids.find(weapon_id), Vector2(100.0, 0.0), 100.0, 20.0)], [], [], {}, [], 0.0, 0.0, false)
		_check(_has_weapon_fx(side_result.get("hitFx", []) as Array, weapon_id) or float((side_result.get("equipmentWeaponTimers", {}) as Dictionary).get(weapon_id, 0.0)) > 0.0, "%s side route activates once" % weapon_id, failures)
		var main_result := _update(weapon_id, [entry], [_enemy(200 + ids.find(weapon_id), Vector2(100.0, 0.0), 100.0, 20.0)], [], [], {}, [], 0.0, 0.0, true)
		_check(_has_weapon_fx(main_result.get("hitFx", []) as Array, weapon_id) or float((main_result.get("equipmentWeaponTimers", {}) as Dictionary).get(weapon_id, 0.0)) > 0.0, "%s main route activates once" % weapon_id, failures)


func _test_pause_and_cleanup() -> void:
	var starlight_entry := {"id": "starlight_superchat", "level": 1, "isEvolved": true, "baseWeaponId": "superchat_shot"}
	var paused := _update("ban_hammer", [{"id": "ban_hammer", "level": 1}, starlight_entry], [_enemy(300, Vector2(100.0, 0.0), 100.0, 20.0)], [], [], {}, [], 0.1, 0.0, false, true)
	_check((paused.get("playerBullets", []) as Array).is_empty(), "paused side starlight does not fire", failures)
	_check(is_equal_approx(float((paused.get("equipmentWeaponTimers", {}) as Dictionary).get("starlight_superchat", 0.0)), 0.0), "paused side starlight timer is held", failures)

	var target := TestTargetScript.new()
	target.weapons = weapons
	target.player_bullets = [{"weaponId": "starlight_superchat", "life": 1.0}, {"weaponId": "other_weapon", "life": 1.0}]
	target.hit_fx = [
		{"kind": "ban_judgement_shockwave", "owner": "ban_judgement", "weaponId": "ban_judgement", "life": 1.0},
		{"kind": "maro_comment_pulse", "owner": "maro_comment_ring", "weaponId": "maro_comment_ring", "life": 1.0},
		{"kind": "other", "life": 1.0}
	]
	target.equipment_weapon_timers = {
		"ban_judgement": 1.0,
		"starlight_superchat": 1.0,
		"maro_comment_ring": 1.0,
		"__starlight_superchat_shot_count": 5,
		"__maro_comment_pulse_index": 1,
		"__maro_comment_pulse_until": 2.0,
		"__maro_comment_flash_until": 2.0,
		"__comment_boomerang_orbit_index:maro_comment_ring": 1,
		"__comment_boomerang_orbit_weapon_id:maro_comment_ring": "maro_comment_ring"
	}
	target.boomerang_hits = {"maro_comment_ring|0|enemy:1": 1.0, "other|0|enemy:2": 1.0}
	WeaponSystemScript.cleanup_runtime_for_weapon(target)
	_check((target.player_bullets as Array).size() == 1 and String((target.player_bullets[0] as Dictionary).get("weaponId", "")) == "other_weapon", "cleanup removes side starlight bullets", failures)
	_check((target.hit_fx as Array).size() == 1 and String((target.hit_fx[0] as Dictionary).get("kind", "")) == "other", "cleanup removes initial evolved FX", failures)
	_check(not (target.equipment_weapon_timers as Dictionary).has("starlight_superchat") and not (target.equipment_weapon_timers as Dictionary).has("__starlight_superchat_shot_count") and not (target.equipment_weapon_timers as Dictionary).has("__maro_comment_pulse_index"), "cleanup removes initial evolved timers and counters", failures)
	_check(not _has_key_prefix(target.boomerang_hits, "maro_comment_ring|"), "cleanup removes maro hit memory", failures)


func _make_superchat_side_target() -> Node:
	var target := TestTargetScript.new()
	target.weapons = weapons
	target.gifts = gifts
	target.player_weapons = [
		{"id": "ban_hammer", "level": 1},
		{"id": "superchat_shot", "level": 5}
	]
	target.player_accessories = [{"id": "bullet_support", "level": 3}]
	target.current_weapon = _find_data(weapons, "ban_hammer")
	target.current_weapon_id = "ban_hammer"
	target.current_character_id = "ban_chan"
	target.current_character = {"id": "ban_chan", "baseStats": {"hp": 100, "moveSpeed": 5.0, "dashCooldown": 1.2, "pickupRange": 1.0}}
	return target


func _update(current_id: String, entries: Array, enemies: Array, boxes: Array, enemy_bullets: Array, timers: Dictionary, player_bullets: Array, delta: float, elapsed_time: float, main_attack_ready: bool, paused: bool = false) -> Dictionary:
	var weapon := _find_data(weapons, current_id)
	return WeaponSystemScript.update_weapons({
		"delta": delta,
		"rng": _rng(),
		"weapon": weapon,
		"weaponData": weapons,
		"playerWeapons": entries,
		"equipmentWeaponTimers": timers,
		"weaponType": WeaponSystemScript.attack_type(weapon),
		"attackTimer": 0.0 if main_attack_ready else 999.0,
		"muteTimer": 0.0,
		"superchatTimer": 0.0,
		"lastDir": Vector2.RIGHT,
		"facingDir": Vector2.RIGHT,
		"playerVel": Vector2.ZERO,
		"lastMoveDirection": Vector2.RIGHT,
		"manualAimDirection": Vector2.ZERO,
		"moveInput": Vector2.ZERO,
		"supportAttack": false,
		"weaponMute": false,
		"weaponMuteRate": 1.0,
		"takeback": false,
		"attackRightOnly": false,
		"attackRightOnlyRate": 1.0,
		"attackJitter": false,
		"shortRange": false,
		"shortRangeRate": 1.0,
		"superchatLevel": 0,
		"boomerangLevel": 0,
		"elapsed": elapsed_time,
		"playerPos": Vector2.ZERO,
		"expOrbs": [],
		"dropItems": [],
		"enemies": enemies,
		"destructibles": boxes,
		"playerBullets": player_bullets,
		"enemyBullets": enemy_bullets,
		"boomerangHits": {},
		"hitFxState": [],
		"damage": float(weapon.get("damage", 12.0)),
		"range": WeaponSystemScript.range_base(weapon),
		"arcAngle": float(weapon.get("arcAngle", 120.0)),
		"interval": WeaponSystemScript.attack_interval(weapon, 0.85),
		"attackAreaRate": 1.0,
		"equipmentDamageRate": 1.0,
		"equipmentRangeRate": 1.0,
		"equipmentIntervalRate": 1.0,
		"equipmentBulletSupportLevel": 0,
		"knockback": WeaponSystemScript.scaled_knockback(float(weapon.get("knockback", 1.0))),
		"arena": Rect2(-2000, -2000, 4000, 4000),
		"normalWeaponsDisabled": paused
	})


func _rng() -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	return rng


func _enemy(uid: int, pos: Vector2, hp: float, radius: float) -> Dictionary:
	return {"kind": "test_enemy", "uid": uid, "spawnToken": "slot-test:%d" % uid, "pos": pos, "hp": hp, "max_hp": hp, "radius": radius, "canBeKnockedBack": true, "knockbackResistance": 0.0, "damageTakenRate": 1.0}


func _box(uid: int, pos: Vector2) -> Dictionary:
	return {"id": "care_package_box", "uid": uid, "pos": pos, "hp": 1.0, "radius": 24.0}


func _find_data(data: Array, id: String) -> Dictionary:
	return WeaponSystemScript.find_weapon(data, id, {})


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


func _has_fx_with_owner(items: Array, owner_id: String) -> bool:
	for item_value in items:
		var item: Dictionary = item_value as Dictionary
		if String(item.get("owner", "")) == owner_id or String(item.get("weaponId", "")) == owner_id:
			return true
	return false


func _has_weapon_fx(items: Array, weapon_id: String) -> bool:
	return _has_fx_with_owner(items, weapon_id)


func _has_key_prefix(values: Dictionary, prefix: String) -> bool:
	for key in values.keys():
		if String(key).begins_with(prefix):
			return true
	return false


func _check(condition: bool, message: String, output: Array[String]) -> void:
	if not condition:
		output.append(message)
