extends RefCounted
class_name WeaponSystem

const DestructibleSystemScript := preload("res://scripts/systems/destructible_system.gd")
const RelayBossDefenseSystemScript := preload("res://scripts/systems/relay_boss_defense_system.gd")
const HIT_NONE := 0
const HIT_DAMAGED := 1
const HIT_BLOCKED := 2
const DEFEAT_KNOCKBACK_MULTIPLIER := 2.4
const SHORT_RANGE_MIN_PROJECTILE_RANGE := 165.0
const SHORT_RANGE_MIN_AREA_RADIUS := 66.0
const SHORT_RANGE_MIN_SEARCH_RANGE := 206.0
const SHORT_RANGE_MIN_LASER_RANGE := 247.5
const SHORT_RANGE_MIN_ORBIT_RADIUS := 34.0
const STARLIGHT_SHOT_COUNTER_KEY := "__starlight_superchat_shot_count"
const BOOMERANG_ORBIT_INDEX_KEY := "__comment_boomerang_orbit_index"
const BOOMERANG_ORBIT_WEAPON_ID_KEY := "__comment_boomerang_orbit_weapon_id"
const MARO_PULSE_INDEX_KEY := "__maro_comment_pulse_index"
const MARO_PULSE_UNTIL_KEY := "__maro_comment_pulse_until"
const MARO_FLASH_UNTIL_KEY := "__maro_comment_flash_until"
const STAGE2_WEAPON_STATE_KEY := "__stage2WeaponStates"
const STAGE2_WEAPON_IDS := ["moderator_shield", "fansa_baton", "tsuri_thumbnail_rod", "moderator_fortress", "fansa_climax", "buzz_thumbnail_rod"]
const KUSA_WAVE_DAMAGE_BY_LEVEL := [5.0, 7.0, 8.0, 10.0, 12.0]
const KUSA_WAVE_INTERVAL_BY_LEVEL := [1.40, 1.35, 1.30, 1.25, 1.20]
const KUSA_WAVE_SIZE_BY_LEVEL := [1.0, 1.0, 1.25, 1.25, 1.45]
const KUSA_WAVE_DISTANCE_BY_LEVEL := [450.0, 520.0, 580.0, 650.0, 750.0]
const KUSA_WAVE_BOUNCES_BY_LEVEL := [1, 1, 1, 2, 2]
const KUSA_WAVE_SPEED := 440.0
const KUSA_WAVE_HIT_COOLDOWN := 0.30
const KUSA_WAVE_MIN_LIFE := 0.40
const BAN_JUDGEMENT_STUN_DURATION := 0.18
const BAN_JUDGEMENT_HEAVY_STUN_DURATION := 0.12
const MAX_HIT_FX := 150
const MAX_DECORATIVE_HIT_FX := 80

static func find_weapon(weapons: Array, id: String, fallback: Dictionary) -> Dictionary:
	for item in weapons:
		var weapon: Dictionary = item as Dictionary
		if String(weapon.get("id", "")) == id:
			return weapon
	return fallback

static func attack_type(weapon: Dictionary) -> String:
	var explicit_type: String = String(weapon.get("attackType", ""))
	if explicit_type != "":
		return explicit_type
	var legacy_type: String = String(weapon.get("weaponType", "hammer"))
	if legacy_type == "superchat":
		return "projectile"
	if legacy_type == "boomerang":
		return "orbit"
	return "melee_arc"

static func is_melee_attack_type(value: String) -> bool:
	return value == "melee_arc" or value == "melee_shockwave"

static func attack_interval(weapon: Dictionary, default_value: float = 0.85) -> float:
	return float(weapon.get("attackInterval", weapon.get("interval", default_value)))

static func scaled_move_speed(value: float) -> float:
	return value * 51.0 if value <= 20.0 else value

static func scaled_range(value: float, scale: float = 82.5) -> float:
	return value * scale if value <= 20.0 else value

static func scaled_projectile_speed(value: float) -> float:
	return value * 65.0 if value <= 20.0 else value

static func scaled_knockback(value: float) -> float:
	return value * 18.0 if value <= 5.0 else value

static func range_base(weapon: Dictionary) -> float:
	if attack_type(weapon) == "orbit":
		return scaled_range(float(weapon.get("orbitRadius", weapon.get("range", 1.8))), 43.0)
	return scaled_range(float(weapon.get("range", 2.0)))

static func attack_area_rate(context: Dictionary) -> float:
	return clampf(float(context.get("attackAreaRate", 1.0)), 1.0, 1.60)

static func player_attack_interval(base_interval: float, rate: float) -> float:
	var safe_base := maxf(0.01, base_interval)
	return maxf(safe_base * 0.50, safe_base * maxf(0.10, rate))

static func _short_range_rate(context: Dictionary, normal_rate: float, heart_rate: float) -> float:
	if not bool(context.get("shortRange", false)):
		return 1.0
	return heart_rate if float(context.get("shortRangeRate", 1.0)) < 0.95 else normal_rate

static func _apply_short_range(context: Dictionary, value: float, normal_rate: float, heart_rate: float, min_value: float = 0.0) -> float:
	var result: float = value * _short_range_rate(context, normal_rate, heart_rate)
	if min_value > 0.0:
		result = maxf(result, min_value)
	return result

static func _alive_enemy_bullets(enemy_bullets: Array) -> Array:
	var kept_bullets: Array = []
	for bullet_item in enemy_bullets:
		var bullet: Dictionary = bullet_item
		if float(bullet.get("life", 0.0)) > 0.0:
			kept_bullets.append(bullet)
	return kept_bullets

static func _kept_enemies(enemies: Array) -> Array:
	var kept_enemies: Array = []
	for enemy_item in enemies:
		if EnemySystem.should_keep_enemy(enemy_item):
			kept_enemies.append(enemy_item)
	return kept_enemies

static func _alive_hit_fx(hit_fx: Array) -> Array:
	var remaining: Array = []
	for fx_item in hit_fx:
		var fx: Dictionary = fx_item
		if float(fx["life"]) > 0.0:
			remaining.append(fx)
	return remaining

static func _hit_fx_priority(fx: Dictionary) -> int:
	var kind := String(fx.get("kind", ""))
	if kind in ["moderator_shield_active", "moderator_shield_end_wave", "tsuri_rod_cast", "fansa_baton_hit", "fansa_baton_cross_followup", "moderator_shield_bullet_clear", "moderator_fortress_active", "moderator_fortress_hit", "moderator_fortress_shockwave", "moderator_fortress_bullet_clear", "fansa_climax_hit", "fansa_climax_echo", "fansa_climax_x", "fansa_climax_fan_wave", "buzz_thumbnail_rod_cast", "buzz_thumbnail_rod_gather", "buzz_thumbnail_rod_explosion", "buzz_thumbnail_rod_target_mark", "buzz_thumbnail_rod_throw", "buzz_thumbnail_rod_bear_flash", "buzz_thumbnail_rod_catch_mark", "buzz_thumbnail_rod_hit"]:
		return 5
	if kind in ["emote_mine", "listener_summon", "kusa_wave", "ng_word_laser", "boss_defeat", "maro_comment_pulse"]:
		return 3
	if kind in ["ban_judgement_shockwave", "ban_judgement_defeat", "starlight_defeat", "starlight_burst", "enemy_defeat", "emote_burst", "mic_wave", "spotlight"]:
		return 2
	return 1

static func _capped_hit_fx(hit_fx: Array) -> Array:
	if hit_fx.size() <= MAX_HIT_FX:
		return hit_fx
	var keep_indices: Array = []
	var decorative_count := 0
	for i in range(hit_fx.size() - 1, -1, -1):
		var fx: Dictionary = hit_fx[i]
		var priority := _hit_fx_priority(fx)
		if priority <= 1 and decorative_count >= MAX_DECORATIVE_HIT_FX:
			continue
		if keep_indices.size() >= MAX_HIT_FX and priority < 3:
			continue
		keep_indices.append(i)
		if priority <= 1:
			decorative_count += 1
	keep_indices.sort()
	var capped: Array = []
	for index_item in keep_indices:
		capped.append(hit_fx[int(index_item)])
	return capped

static func _short_range_projectile_rate(context: Dictionary) -> float:
	return _short_range_rate(context, 0.60, 0.75)

static func _short_range_area_rate(context: Dictionary) -> float:
	return _short_range_rate(context, 0.75, 0.85)

static func _short_range_orbit_rate(context: Dictionary) -> float:
	return _short_range_rate(context, 0.70, 0.85)

static func _short_range_explosion_area_rate(context: Dictionary) -> float:
	return _short_range_rate(context, 0.85, 0.92)

static func _short_range_search_rate(context: Dictionary) -> float:
	return _short_range_rate(context, 0.60, 0.75)

static func _short_range_laser_rate(context: Dictionary) -> float:
	return _short_range_rate(context, 0.55, 0.75)

static func _short_range_range_for_weapon(weapon_id: String, weapon: Dictionary, range_value: float, context: Dictionary) -> float:
	match weapon_id:
		"ban_hammer", "ban_judgement", "mic_barrier":
			return _apply_short_range(context, range_value, 0.75, 0.85, SHORT_RANGE_MIN_AREA_RADIUS)
		"comment_boomerang", "maro_comment_ring":
			return _apply_short_range(context, range_value, 0.70, 0.85, SHORT_RANGE_MIN_ORBIT_RADIUS)
		"spotlight", "kusa_wave", "comment_pin":
			return _apply_short_range(context, range_value, 0.60, 0.75, SHORT_RANGE_MIN_PROJECTILE_RANGE)
		"ng_word_laser":
			return _apply_short_range(context, range_value, 0.55, 0.75, SHORT_RANGE_MIN_LASER_RANGE)
		"listener_summon":
			return _apply_short_range(context, range_value, 0.60, 0.75, SHORT_RANGE_MIN_SEARCH_RANGE)
		"emote_mine":
			return range_value
	if attack_type(weapon) == "orbit":
		return _apply_short_range(context, range_value, 0.70, 0.85, SHORT_RANGE_MIN_ORBIT_RADIUS)
	if is_melee_attack_type(attack_type(weapon)) or attack_type(weapon) == "aura":
		return _apply_short_range(context, range_value, 0.75, 0.85, SHORT_RANGE_MIN_AREA_RADIUS)
	return _apply_short_range(context, range_value, 0.60, 0.75, SHORT_RANGE_MIN_PROJECTILE_RANGE)

static func orbit_count(weapon: Dictionary, boomerang_level: int) -> int:
	var base_count: int = int(weapon.get("boomerangCount", 1)) if attack_type(weapon) == "orbit" else 0
	return base_count + boomerang_level

static func orbit_speed(weapon: Dictionary) -> float:
	var speed: float = float(weapon.get("orbitSpeed", 4.0)) if attack_type(weapon) == "orbit" else 4.0
	return deg_to_rad(speed) if speed > 20.0 else speed

static func _boomerang_orbit_se_due(weapon: Dictionary, weapon_timers: Dictionary, elapsed: float, speed: float, is_main_orbit: bool) -> bool:
	var safe_speed: float = absf(speed)
	if safe_speed <= 0.001:
		return false
	var sound_weapon_id: String = String(weapon.get("id", "")) if is_main_orbit else "comment_boomerang"
	if sound_weapon_id == "":
		sound_weapon_id = "comment_boomerang"
	var orbit_index: int = int(floor(elapsed * safe_speed / TAU))
	var last_weapon_id: String = String(weapon_timers.get(BOOMERANG_ORBIT_WEAPON_ID_KEY, ""))
	if not weapon_timers.has(BOOMERANG_ORBIT_INDEX_KEY) or last_weapon_id != sound_weapon_id:
		weapon_timers[BOOMERANG_ORBIT_WEAPON_ID_KEY] = sound_weapon_id
		weapon_timers[BOOMERANG_ORBIT_INDEX_KEY] = orbit_index
		return false
	var last_orbit_index: int = int(weapon_timers.get(BOOMERANG_ORBIT_INDEX_KEY, orbit_index))
	if orbit_index <= last_orbit_index:
		return false
	weapon_timers[BOOMERANG_ORBIT_INDEX_KEY] = orbit_index
	return true

static func update_weapons(context: Dictionary) -> Dictionary:
	var result: Dictionary = {
		"attackTimer": float(context["attackTimer"]),
		"muteTimer": float(context["muteTimer"]),
		"superchatTimer": float(context["superchatTimer"]),
		"lastDir": Vector2(context["lastDir"]),
		"playerBullets": context["playerBullets"],
		"boomerangHits": context["boomerangHits"],
		"enemyBullets": context["enemyBullets"],
		"hitFx": [],
		"killed": [],
		"destroyedBoxes": [],
		"chat": [],
		"barrierHitRequests": [],
		"superchatShotFired": false,
		"boomerangOrbitSe": false
	}
	var normal_weapons_disabled := bool(context.get("normalWeaponsDisabled", false))
	var projectile_result: Dictionary = update_projectiles({
		"delta": context["delta"],
		"weapon": context["weapon"],
		"weaponTimers": context["equipmentWeaponTimers"],
		"weaponType": context["weaponType"],
		"superchatLevel": context["superchatLevel"],
		"bulletSupportLevel": context["equipmentBulletSupportLevel"],
		"superchatTimer": context["superchatTimer"],
		"interval": context["interval"],
		"equipmentIntervalRate": context.get("equipmentIntervalRate", 1.0),
		"range": context["range"],
		"damage": context["damage"],
		"shortRange": context["shortRange"],
		"shortRangeRate": context["shortRangeRate"],
		"attackAreaRate": context.get("attackAreaRate", 1.0),
		"playerPos": context["playerPos"],
		"enemies": context["enemies"],
		"destructibles": context["destructibles"],
		"bullets": context["playerBullets"],
		"enemyBullets": context["enemyBullets"],
		"knockback": context["knockback"],
		"arena": context["arena"],
		"normalWeaponsDisabled": normal_weapons_disabled
	})
	result["superchatTimer"] = projectile_result["superchatTimer"]
	result["playerBullets"] = projectile_result["bullets"]
	result["superchatShotFired"] = bool(projectile_result.get("superchatShotFired", false))
	_merge_weapon_result(result, projectile_result)

	var hammer_result: Dictionary = update_hammer({
		"delta": context["delta"],
		"rng": context["rng"],
		"weapon": context["weapon"],
		"weaponType": context["weaponType"],
		"attackTimer": context["attackTimer"],
		"muteTimer": context["muteTimer"],
		"lastDir": context["lastDir"],
		"facingDir": context["facingDir"],
		"supportAttack": context["supportAttack"],
		"weaponMute": context["weaponMute"],
		"weaponMuteRate": context["weaponMuteRate"],
		"takeback": context["takeback"],
		"attackRightOnly": context["attackRightOnly"],
		"attackRightOnlyRate": context["attackRightOnlyRate"],
		"attackJitter": context["attackJitter"],
		"shortRange": context["shortRange"],
		"shortRangeRate": context["shortRangeRate"],
		"playerPos": context["playerPos"],
		"enemies": context["enemies"],
		"destructibles": context["destructibles"],
		"enemyBullets": context["enemyBullets"],
		"damage": context["damage"],
		"range": context["range"],
		"arcAngle": context["arcAngle"],
		"interval": context["interval"],
		"attackAreaRate": context.get("attackAreaRate", 1.0),
		"knockback": context["knockback"],
		"normalWeaponsDisabled": normal_weapons_disabled
	})
	result["attackTimer"] = hammer_result["attackTimer"]
	result["muteTimer"] = hammer_result["muteTimer"]
	result["lastDir"] = hammer_result["lastDir"]
	_merge_weapon_result(result, hammer_result)

	var boomerang_result: Dictionary = update_boomerang({
		"delta": context["delta"],
		"weapon": context["weapon"],
		"weaponTimers": context["equipmentWeaponTimers"],
		"weaponType": context["weaponType"],
		"boomerangLevel": context["boomerangLevel"],
		"bulletSupportLevel": context["equipmentBulletSupportLevel"],
		"elapsed": context["elapsed"],
		"playerPos": context["playerPos"],
		"expOrbs": context["expOrbs"],
		"enemies": context["enemies"],
		"destructibles": context["destructibles"],
		"enemyBullets": context["enemyBullets"],
		"boomerangHits": context["boomerangHits"],
		"range": context["range"],
		"damage": context["damage"],
		"shortRange": context["shortRange"],
		"shortRangeRate": context["shortRangeRate"],
		"attackAreaRate": context.get("attackAreaRate", 1.0),
		"knockback": context["knockback"],
		"normalWeaponsDisabled": normal_weapons_disabled
	})
	result["boomerangHits"] = boomerang_result["boomerangHits"]
	result["boomerangOrbitSe"] = bool(boomerang_result.get("boomerangOrbitSe", false))
	_merge_weapon_result(result, boomerang_result)
	var main_weapon: Dictionary = context["weapon"] as Dictionary
	var equipment_result: Dictionary = update_equipment_weapons({
		"delta": context["delta"],
		"weaponData": context["weaponData"],
		"playerWeapons": context["playerWeapons"],
		"mainWeaponId": String(main_weapon.get("id", "")),
		"timers": context["equipmentWeaponTimers"],
		"playerPos": context["playerPos"],
		"facingDir": context["facingDir"],
		"playerVel": context.get("playerVel", Vector2.ZERO),
		"rng": context["rng"],
		"attackRightOnly": context["attackRightOnly"],
		"attackRightOnlyRate": context["attackRightOnlyRate"],
		"enemies": context["enemies"],
		"destructibles": context["destructibles"],
		"enemyBullets": context["enemyBullets"],
		"activeFx": context.get("hitFxState", []),
		"damageRate": context["equipmentDamageRate"],
		"rangeRate": context["equipmentRangeRate"],
		"intervalRate": context["equipmentIntervalRate"],
		"attackAreaRate": context.get("attackAreaRate", 1.0),
		"bulletSupportLevel": context["equipmentBulletSupportLevel"],
		"shortRange": context["shortRange"],
		"shortRangeRate": context["shortRangeRate"],
		"knockback": context["knockback"],
		"normalWeaponsDisabled": normal_weapons_disabled
	})
	result["equipmentWeaponTimers"] = equipment_result["timers"]
	_merge_weapon_result(result, equipment_result)
	return result

static func song_live_heat_attack_cooldown_multiplier_for_target(target: Node) -> float:
	if target.has_method("_song_live_heat_attack_cooldown_multiplier"):
		return maxf(0.1, float(target.call("_song_live_heat_attack_cooldown_multiplier")))
	return 1.0

static func collab_attack_cooldown_multiplier_for_target(target: Node) -> float:
	if target.has_method("_collab_attack_cooldown_multiplier"):
		return maxf(0.1, float(target.call("_collab_attack_cooldown_multiplier")))
	return 1.0

static func collab_player_damage_multiplier_for_target(target: Node) -> float:
	if target.has_method("_collab_player_damage_multiplier"):
		return maxf(0.1, float(target.call("_collab_player_damage_multiplier")))
	return 1.0

static func normal_weapons_disabled_for_target(target: Node) -> bool:
	if target.has_method("_normal_weapons_disabled_by_song_bad_light"):
		return bool(target.call("_normal_weapons_disabled_by_song_bad_light"))
	return false

static func update_for_target(target: Node, delta: float, arena: Rect2, rng: RandomNumberGenerator) -> Dictionary:
	var current_weapon: Dictionary = target.get("current_weapon") as Dictionary
	var song_cooldown_rate := song_live_heat_attack_cooldown_multiplier_for_target(target)
	var collab_cooldown_rate := collab_attack_cooldown_multiplier_for_target(target)
	var collab_damage_rate := collab_player_damage_multiplier_for_target(target)
	var support_attack_rate := ModifierSystem.combined_multiplier_for_target(target, "playerAttackDamage")
	var character_damage_rate := 1.0
	var raw_character_damage_rate: Variant = target.get("character_attack_multiplier")
	if raw_character_damage_rate != null:
		character_damage_rate = maxf(0.01, float(raw_character_damage_rate))
	var player_damage_rate := character_damage_rate * collab_damage_rate * support_attack_rate
	var normal_weapons_disabled := normal_weapons_disabled_for_target(target)
	var shop_snapshot = target.get("permanent_upgrade_snapshot")
	var shop_attack_area_rate := 1.0
	var shop_attack_interval_rate := 1.0
	if shop_snapshot != null:
		shop_attack_area_rate = clampf(float(shop_snapshot.attack_area_multiplier), 1.0, 1.60)
		shop_attack_interval_rate = clampf(float(shop_snapshot.attack_interval_multiplier), 0.50, 1.0)
	var result: Dictionary = update_weapons({
		"delta": delta,
		"rng": rng,
		"weapon": current_weapon,
		"weaponData": target.get("weapons"),
		"playerWeapons": target.get("player_weapons"),
		"equipmentWeaponTimers": target.get("equipment_weapon_timers"),
		"weaponType": attack_type(current_weapon),
		"attackTimer": target.get("attack_timer"),
		"muteTimer": target.get("mute_timer"),
		"superchatTimer": target.get("superchat_timer"),
		"lastDir": target.get("last_hammer_dir"),
		"facingDir": Vector2(float(target.get("player_facing_x")), 0.0),
		"playerVel": target.get("player_vel"),
		"supportAttack": float(target.get("support_attack_timer")) > 0.0,
		"weaponMute": ModifierSystem.has_effect_for_target(target, "weapon_mute"),
		"weaponMuteRate": ModifierSystem.effect_rate_for_target(target, "weapon_mute"),
		"takeback": ModifierSystem.has_effect_for_target(target, "takeback"),
		"attackRightOnly": ModifierSystem.has_effect_for_target(target, "attack_right_only"),
		"attackRightOnlyRate": ModifierSystem.effect_rate_for_target(target, "attack_right_only"),
		"attackJitter": float(target.get("attack_jitter_timer")) > 0.0,
		"shortRange": ModifierSystem.has_effect_for_target(target, "short_range"),
		"shortRangeRate": ModifierSystem.effect_rate_for_target(target, "short_range"),
		"superchatLevel": target.get("superchat_level"),
		"boomerangLevel": target.get("boomerang_level"),
		"elapsed": target.get("elapsed"),
		"playerPos": target.get("player_pos"),
		"expOrbs": target.get("exp_orbs"),
		"enemies": target.get("enemies"),
		"destructibles": target.get("destructibles"),
		"playerBullets": target.get("player_bullets"),
		"enemyBullets": target.get("enemy_bullets"),
		"boomerangHits": target.get("boomerang_hits"),
		"hitFxState": target.get("hit_fx"),
		"damage": float(target.get("hammer_damage")) * player_damage_rate,
		"range": target.get("hammer_range"),
		"arcAngle": current_weapon.get("arcAngle", 120.0),
		"interval": maxf(attack_interval(current_weapon, 0.85) * 0.50, float(target.get("hammer_interval")) * song_cooldown_rate * collab_cooldown_rate),
		"attackAreaRate": shop_attack_area_rate,
		"equipmentDamageRate": float(target.get("equipment_damage_rate")) * player_damage_rate,
		"equipmentRangeRate": target.get("equipment_range_rate"),
		"equipmentIntervalRate": float(target.get("equipment_interval_rate")) * song_cooldown_rate * collab_cooldown_rate * shop_attack_interval_rate,
		"equipmentBulletSupportLevel": target.get("equipment_bullet_support_level"),
		"knockback": target.get("knockback_power"),
		"arena": arena,
		"normalWeaponsDisabled": normal_weapons_disabled
	})
	target.set("attack_timer", float(result["attackTimer"]))
	target.set("mute_timer", float(result["muteTimer"]))
	target.set("superchat_timer", float(result["superchatTimer"]))
	target.set("last_hammer_dir", Vector2(result["lastDir"]))
	target.set("player_bullets", result["playerBullets"])
	var enemy_bullets: Array = result.get("enemyBullets", target.get("enemy_bullets")) as Array
	target.set("enemy_bullets", _alive_enemy_bullets(enemy_bullets))
	target.set("boomerang_hits", result["boomerangHits"])
	target.set("equipment_weapon_timers", result.get("equipmentWeaponTimers", target.get("equipment_weapon_timers")))
	return result

static func apply_update_result_for_target(target: Node, result: Dictionary, arena: Rect2, rng: RandomNumberGenerator) -> Dictionary:
	var chats: Array = []
	var feedback: Dictionary = {"chats": chats, "barrierHitRequests": []}
	_merge_reaction_result(feedback, result)
	_dispatch_barrier_hit_requests(target, result.get("barrierHitRequests", []) as Array)
	var killed: Array = result.get("killed", []) as Array
	for item in killed:
		var enemy: Dictionary = item
		var kill_result: Dictionary = EnemySystem.apply_kill_for_target(target, enemy, arena, rng)
		_merge_reaction_result(feedback, kill_result)
		var kill_chat: String = String(kill_result["chat"])
		if kill_chat != "":
			chats.append(kill_chat)

	var hit_fx: Array = target.get("hit_fx") as Array
	var effects: Array = result.get("hitFx", []) as Array
	for item in effects:
		hit_fx.append(item)
	target.set("hit_fx", _capped_hit_fx(hit_fx))

	var weapon_chats: Array = result.get("chat", []) as Array
	for item in weapon_chats:
		chats.append(String(item))

	var enemies: Array = target.get("enemies") as Array
	target.set("enemies", _kept_enemies(enemies))
	var destroy_feedback: Dictionary = DestructibleSystemScript.apply_destroyed_for_target(target, result.get("destroyedBoxes", []) as Array, rng)
	for item in (destroy_feedback["chats"] as Array):
		chats.append(String(item))
	var comment_event_ids: Array = feedback.get("commentEventIds", []) as Array
	for item in (destroy_feedback.get("commentEventIds", []) as Array):
		var event_id := String(item)
		if event_id != "" and not comment_event_ids.has(event_id):
			comment_event_ids.append(event_id)
	if not comment_event_ids.is_empty():
		feedback["commentEventIds"] = comment_event_ids
	return feedback

static func _dispatch_barrier_hit_requests(target: Node, requests: Array) -> void:
	if requests.is_empty() or not target.has_method("_relay_boss_register_barrier_hit"):
		return
	for request_item in requests:
		var request: Dictionary = request_item as Dictionary
		target.call("_relay_boss_register_barrier_hit", request)

static func _merge_weapon_result(target: Dictionary, source: Dictionary) -> void:
	for key in ["hitFx", "killed", "destroyedBoxes", "chat"]:
		var target_items: Array = target.get(key, []) as Array
		var source_items: Array = source.get(key, []) as Array
		for item in source_items:
			target_items.append(item)
	var barrier_requests: Array = target.get("barrierHitRequests", []) as Array
	for item in source.get("barrierHitRequests", []) as Array:
		barrier_requests.append(item)
	target["barrierHitRequests"] = barrier_requests
	_merge_reaction_result(target, source)

static func _merge_reaction_result(target: Dictionary, source: Dictionary) -> void:
	var chats: Array = target.get("chats", target.get("chat", [])) as Array
	for item in (source.get("chats", []) as Array):
		chats.append(String(item))
	if target.has("chats"):
		target["chats"] = chats
	elif target.has("chat"):
		target["chat"] = chats
	var toasts: Array = target.get("toasts", []) as Array
	for item in (source.get("toasts", []) as Array):
		toasts.append(String(item))
	if not toasts.is_empty():
		target["toasts"] = toasts
	if float(source.get("screenShakePower", 0.0)) > float(target.get("screenShakePower", 0.0)):
		target["screenShakePower"] = float(source.get("screenShakePower", 0.0))
	if float(source.get("screenShakeDuration", 0.0)) > float(target.get("screenShakeDuration", 0.0)):
		target["screenShakeDuration"] = float(source.get("screenShakeDuration", 0.0))
	if float(source.get("hitStop", 0.0)) > float(target.get("hitStop", 0.0)):
		target["hitStop"] = float(source.get("hitStop", 0.0))
	if float(source.get("screenFlashDuration", 0.0)) > float(target.get("screenFlashDuration", 0.0)):
		target["screenFlashDuration"] = float(source.get("screenFlashDuration", 0.0))
		target["screenFlashColor"] = source.get("screenFlashColor", Color.WHITE)
	if bool(source.get("enemyDamaged", false)):
		target["enemyDamaged"] = true
	if bool(source.get("listenerSummonAttacked", false)):
		target["listenerSummonAttacked"] = true
	if bool(source.get("enemyDefeated", false)):
		target["enemyDefeated"] = true
	var weapon_comment_kind := String(source.get("weaponCommentKind", ""))
	if weapon_comment_kind != "":
		target["weaponCommentKind"] = weapon_comment_kind

static func _request_weapon_hit_reaction(result: Dictionary, weapon: Dictionary, hit_count: int, enemy_hit_count: int = -1) -> void:
	if hit_count <= 0:
		return
	var reaction: Dictionary = {
		"screenShakePower": float(weapon.get("screenShakePower", 0.0)),
		"screenShakeDuration": float(weapon.get("screenShakeDuration", 0.10)),
		"hitStop": float(weapon.get("hitStop", 0.0))
	}
	if enemy_hit_count < 0:
		enemy_hit_count = hit_count
	if enemy_hit_count > 0:
		reaction["enemyDamaged"] = true
		var weapon_comment_kind := weapon_comment_kind_for_id(String(weapon.get("id", "")))
		if weapon_comment_kind != "":
			reaction["weaponCommentKind"] = weapon_comment_kind
	_merge_reaction_result(result, reaction)

static func weapon_comment_kind_for_id(weapon_id: String) -> String:
	match weapon_id:
		"ban_hammer":
			return "ban_hammer"
		"ban_judgement":
			return "ban_judgement"
		"superchat_shot", "starlight_superchat":
			return "superchat"
		"maro_comment_ring":
			return "maro_ring"
		"comment_boomerang":
			return "comment_boomerang"
		"mic_barrier":
			return "mic"
		"comment_pin":
			return "comment_pin"
		"kusa_wave":
			return "kusa_wave"
		"ng_word_laser":
			return "ng_word_laser"
		"listener_summon":
			return "listener_summon"
		"emote_mine":
			return "emote_mine"
	return ""

static func _enemy_knockback_scale(enemy: Dictionary) -> float:
	if not bool(enemy.get("canBeKnockedBack", true)):
		return 0.0
	var resistance: float = clampf(float(enemy.get("knockbackResistance", 0.0)), 0.0, 1.0)
	return 1.0 - resistance

static func _scaled_hit_knockback(enemy: Dictionary, knockback: float, defeated: bool) -> float:
	var value: float = knockback * _enemy_knockback_scale(enemy)
	if defeated:
		value *= DEFEAT_KNOCKBACK_MULTIPLIER
	return value

static func _start_enemy_hit_flash(enemy: Dictionary) -> void:
	var duration: float = maxf(0.01, float(enemy.get("hitFlashDuration", 0.10)))
	enemy["hitFlashDuration"] = duration
	enemy["hitFlashTimer"] = duration

static func _append_killed_once(enemy: Dictionary, _killed_enemies: Array) -> void:
	if float(enemy.get("hp", 0.0)) > 0.0:
		return
	if bool(enemy.get("defeatPending", false)) or bool(enemy.get("defeatResolved", false)):
		return
	EnemySystem.queue_defeat_for_enemy(enemy)

static func _apply_enemy_hit(enemy: Dictionary, damage: float, push_dir: Vector2, knockback: float, killed_enemies: Array, hit_effects: Array, barrier_hit_requests: Array = [], hit_source: String = "") -> int:
	if float(enemy.get("hp", 0.0)) <= 0.0:
		return HIT_NONE
	var enemy_pos: Vector2 = Vector2(enemy.get("pos", Vector2.ZERO))
	if bool(enemy.get("phaseBarrierActive", false)):
		barrier_hit_requests.append({"enemyUid": int(enemy.get("uid", -1)), "pos": enemy_pos, "source": hit_source})
		return HIT_BLOCKED
	var applied_damage: float = damage * maxf(0.05, float(enemy.get("damageTakenRate", 1.0)))
	enemy["hp"] = float(enemy["hp"]) - applied_damage
	if hit_source != "":
		enemy["lastHitSource"] = hit_source
	enemy["lastHitOwner"] = "player"
	_start_enemy_hit_flash(enemy)
	var dir: Vector2 = push_dir.normalized()
	var defeated := float(enemy.get("hp", 0.0)) <= 0.0
	if defeated:
		if hit_source != "":
			enemy["defeatSource"] = hit_source
		enemy["defeatOwner"] = "player"
		enemy["removeReason"] = "combat_defeat"
	var scaled_knockback: float = _scaled_hit_knockback(enemy, knockback, defeated)
	if scaled_knockback > 0.0 and dir.length() > 0.1:
		EnemySystem.add_knockback_for_enemy(enemy, dir, scaled_knockback)
	hit_effects.append(_damage_number_fx(enemy_pos, applied_damage))
	_append_killed_once(enemy, killed_enemies)
	return HIT_DAMAGED

static func _is_boss_enemy(enemy: Dictionary) -> bool:
	return EnemySystem.is_boss_enemy(enemy)

static func _ban_judgement_knockback_rate(enemy: Dictionary) -> float:
	if _is_boss_enemy(enemy):
		return 0.0
	var kind: String = String(enemy.get("kind", ""))
	var radius: float = float(enemy.get("radius", 20.0))
	var max_hp: float = float(enemy.get("max_hp", enemy.get("maxHp", enemy.get("hp", 0.0))))
	if radius >= 58.0 or max_hp >= 120.0:
		return 0.35
	if radius >= 38.0:
		return 0.62
	if kind == "clipper" or kind == "ghost_comment":
		return 0.85
	return 1.0

static func _ban_judgement_stun_duration(enemy: Dictionary, normal_duration: float, heavy_duration: float) -> float:
	if _is_boss_enemy(enemy) or not bool(enemy.get("canBeKnockedBack", true)):
		return 0.0
	var kind: String = String(enemy.get("kind", ""))
	var radius: float = float(enemy.get("radius", 20.0))
	if radius >= 38.0 or kind == "long_comment_guy" or kind == "clipper" or kind == "ghost_comment":
		return heavy_duration
	return normal_duration

static func _ban_judgement_hit_fx(pos: Vector2, dir: Vector2, boss_hit: bool = false) -> Dictionary:
	return {
		"kind": "ban_judgement_hit",
		"pos": pos,
		"dir": dir,
		"life": 0.26 if not boss_hit else 0.18,
		"maxLife": 0.26 if not boss_hit else 0.18,
		"bossHit": boss_hit
	}

static func _ban_judgement_enemy_defeated(enemy: Dictionary) -> bool:
	return float(enemy.get("hp", 0.0)) <= 0.0 or bool(enemy.get("defeatPending", false))

static func _ban_judgement_defeat_fx(enemy: Dictionary, dir: Vector2) -> Dictionary:
	var boss_hit: bool = _is_boss_enemy(enemy)
	var max_life: float = 0.52 if boss_hit else 0.42
	return {
		"kind": "ban_judgement_defeat",
		"pos": Vector2(enemy.get("pos", Vector2.ZERO)),
		"dir": dir,
		"life": max_life,
		"maxLife": max_life,
		"radius": float(enemy.get("radius", 22.0)),
		"boss": boss_hit
	}

static func _apply_ban_judgement_enemy_hit(enemy: Dictionary, damage: float, push_dir: Vector2, knockback: float, stun_duration: float, heavy_stun_duration: float, killed_enemies: Array, hit_effects: Array, barrier_hit_requests: Array) -> int:
	var enemy_pos: Vector2 = Vector2(enemy.get("pos", Vector2.ZERO))
	var boss_hit: bool = _is_boss_enemy(enemy)
	var applied_knockback: float = knockback * _ban_judgement_knockback_rate(enemy)
	var hit_result := _apply_enemy_hit(enemy, damage, push_dir, applied_knockback, killed_enemies, hit_effects, barrier_hit_requests)
	if hit_result != HIT_DAMAGED:
		return hit_result
	var stun: float = _ban_judgement_stun_duration(enemy, stun_duration, heavy_stun_duration)
	if stun > 0.0:
		enemy["stunTimer"] = maxf(float(enemy.get("stunTimer", 0.0)), stun)
	elif boss_hit:
		enemy["hitFlashTimer"] = maxf(float(enemy.get("hitFlashTimer", 0.0)), 0.10)
	hit_effects.append(_ban_judgement_hit_fx(enemy_pos, push_dir, boss_hit))
	if _ban_judgement_enemy_defeated(enemy):
		hit_effects.append(_ban_judgement_defeat_fx(enemy, push_dir))
	return HIT_DAMAGED

static func _damage_number_fx(pos: Vector2, damage: float) -> Dictionary:
	return {
		"kind": "damage_number",
		"pos": pos + Vector2(randf_range(-8.0, 8.0), -22.0 + randf_range(-5.0, 3.0)),
		"vel": Vector2(randf_range(-14.0, 14.0), -52.0),
		"life": 0.62,
		"maxLife": 0.62,
		"damage": damage
	}

static func _bullet_pop_fx(pos: Vector2) -> Dictionary:
	return {
		"pos": pos,
		"dir": Vector2.RIGHT,
		"life": 0.12,
		"range": 22.0,
		"arcAngle": 360.0,
		"hit": pos,
		"count": 1
	}

static func _maro_bullet_clear_fx(pos: Vector2, center: Vector2) -> Dictionary:
	var offset := pos - center
	var offset_sq := offset.length_squared()
	var dir: Vector2 = offset / sqrt(offset_sq) if offset_sq >= 0.01 else Vector2.RIGHT
	if dir.length_squared() < 0.01:
		dir = Vector2.RIGHT
	return {
		"kind": "maro_bullet_clear",
		"pos": pos,
		"dir": dir,
		"life": 0.28,
		"maxLife": 0.28
	}

static func _clear_enemy_bullets_in_circle(enemy_bullets: Array, center: Vector2, radius: float, hit_effects: Array, clear_fx_kind: String = "") -> int:
	var cleared: int = 0
	for item in enemy_bullets:
		var bullet: Dictionary = item as Dictionary
		if float(bullet.get("life", 0.0)) <= 0.0:
			continue
		var bullet_pos: Vector2 = Vector2(bullet["pos"])
		var bullet_radius: float = float(bullet.get("hitRadius", 16.0))
		var hit_range: float = radius + bullet_radius
		if bullet_pos.distance_squared_to(center) <= hit_range * hit_range:
			bullet["life"] = -1.0
			if clear_fx_kind == "maro_comment":
				hit_effects.append(_maro_bullet_clear_fx(bullet_pos, center))
			else:
				hit_effects.append(_bullet_pop_fx(bullet_pos))
			cleared += 1
	return cleared

static func _clear_enemy_bullets_in_arc(enemy_bullets: Array, origin: Vector2, dir: Vector2, radius: float, arc_angle: float, hit_effects: Array) -> int:
	var cleared: int = 0
	var norm_dir: Vector2 = dir.normalized()
	if norm_dir.length() < 0.1:
		norm_dir = Vector2.RIGHT
	var dot_threshold: float = cos(deg_to_rad(arc_angle * 0.5))
	for item in enemy_bullets:
		var bullet: Dictionary = item as Dictionary
		if float(bullet.get("life", 0.0)) <= 0.0:
			continue
		var bullet_pos: Vector2 = Vector2(bullet["pos"])
		var to_bullet: Vector2 = bullet_pos - origin
		var hit_range: float = radius + float(bullet.get("hitRadius", 16.0))
		var distance_sq: float = to_bullet.length_squared()
		if distance_sq > hit_range * hit_range:
			continue
		if distance_sq <= 0.01 or norm_dir.dot(to_bullet / sqrt(distance_sq)) >= dot_threshold:
			bullet["life"] = -1.0
			hit_effects.append(_bullet_pop_fx(bullet_pos))
			cleared += 1
	return cleared

static func _attack_target_id(prefix: String, item: Dictionary) -> String:
	return "%s_%d" % [prefix, int(item.get("uid", 0))]

static func _is_forward_shockwave_hit(origin: Vector2, dir: Vector2, length: float, width: float, target_pos: Vector2, target_radius: float) -> bool:
	var norm_dir: Vector2 = dir.normalized()
	if norm_dir.length() < 0.1:
		norm_dir = Vector2.RIGHT
	var offset: Vector2 = target_pos - origin
	var forward: float = offset.dot(norm_dir)
	if forward < -target_radius or forward > length + target_radius:
		return false
	var side: Vector2 = Vector2(-norm_dir.y, norm_dir.x)
	var progress: float = clampf(forward / maxf(1.0, length), 0.0, 1.0)
	var half_width: float = width * (0.42 + progress * 0.16)
	return absf(offset.dot(side)) <= half_width + target_radius

static func _apply_ban_judgement_attack(
	weapon: Dictionary,
	enemies: Array,
	destructibles: Array,
	enemy_bullets: Array,
	player_pos: Vector2,
	dir: Vector2,
	swing_range: float,
	arc_angle: float,
	swing_damage: float,
	swing_knockback: float,
	shockwave_range_rate: float,
	shockwave_width_rate: float,
	killed_enemies: Array,
	destroyed_boxes: Array,
	hit_effects: Array,
	barrier_hit_requests: Array
) -> Dictionary:
	var norm_dir: Vector2 = dir.normalized()
	if norm_dir.length() < 0.1:
		norm_dir = Vector2.RIGHT
	var hit_ids: Array[String] = []
	var hits: int = 0
	var swing_hits: int = 0
	var swing_enemy_hits: int = 0
	var shockwave_hits: int = 0
	var closest_hit: Vector2 = player_pos + norm_dir * swing_range
	var closest_swing_hit: Vector2 = closest_hit
	var arc_dot_threshold: float = cos(deg_to_rad(arc_angle * 0.5))
	var stun_duration: float = float(weapon.get("stunDuration", BAN_JUDGEMENT_STUN_DURATION))
	var heavy_stun_duration: float = float(weapon.get("heavyStunDuration", BAN_JUDGEMENT_HEAVY_STUN_DURATION))

	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if float(enemy.get("hp", 0.0)) <= 0.0:
			continue
		var enemy_pos: Vector2 = Vector2(enemy["pos"])
		var to_enemy: Vector2 = enemy_pos - player_pos
		var enemy_radius: float = float(enemy.get("radius", 20.0))
		var range_padding: float = enemy_radius * 0.65 + 12.0
		var hit_range: float = swing_range + range_padding
		var distance_sq: float = to_enemy.length_squared()
		if distance_sq <= hit_range * hit_range and (distance_sq <= 0.01 or norm_dir.dot(to_enemy / sqrt(distance_sq)) >= arc_dot_threshold):
			var hit_result := _apply_ban_judgement_enemy_hit(enemy, swing_damage, norm_dir, swing_knockback, stun_duration, heavy_stun_duration, killed_enemies, hit_effects, barrier_hit_requests)
			if hit_result == HIT_DAMAGED:
				hit_ids.append(_attack_target_id("enemy", enemy))
				hits += 1
				swing_hits += 1
				swing_enemy_hits += 1
				if enemy_pos.distance_squared_to(player_pos) < closest_hit.distance_squared_to(player_pos):
					closest_hit = enemy_pos
				if enemy_pos.distance_squared_to(player_pos) < closest_swing_hit.distance_squared_to(player_pos):
					closest_swing_hit = enemy_pos

	for box_item in destructibles:
		var box: Dictionary = box_item as Dictionary
		if float(box.get("hp", 0.0)) <= 0.0:
			continue
		var box_pos: Vector2 = Vector2(box["pos"])
		var to_box: Vector2 = box_pos - player_pos
		var box_padding: float = float(box.get("radius", 24.0)) * 0.55 + 10.0
		var box_hit_range: float = swing_range + box_padding
		var box_distance_sq: float = to_box.length_squared()
		if box_distance_sq <= box_hit_range * box_hit_range and (box_distance_sq <= 0.01 or norm_dir.dot(to_box / sqrt(box_distance_sq)) >= arc_dot_threshold):
			DestructibleSystemScript.damage_box(box, 1.0, destroyed_boxes, hit_effects)
			hit_ids.append(_attack_target_id("box", box))
			hits += 1
			swing_hits += 1
			if box_pos.distance_squared_to(player_pos) < closest_swing_hit.distance_squared_to(player_pos):
				closest_swing_hit = box_pos

	var cleared_bullets: int = _clear_enemy_bullets_in_arc(enemy_bullets, player_pos, norm_dir, swing_range + 18.0, arc_angle, hit_effects)
	if cleared_bullets > 0:
		hits += cleared_bullets
		swing_hits += cleared_bullets

	var shockwave_range: float = maxf(scaled_range(float(weapon.get("shockwaveRange", 5.5))) * shockwave_range_rate, SHORT_RANGE_MIN_PROJECTILE_RANGE)
	var shockwave_width: float = maxf(scaled_range(float(weapon.get("shockwaveWidth", 1.2))) * shockwave_width_rate, SHORT_RANGE_MIN_AREA_RADIUS)
	var base_damage: float = maxf(0.01, float(weapon.get("damage", 28.0)))
	var damage_rate: float = swing_damage / base_damage
	var shockwave_damage: float = float(weapon.get("shockwaveDamage", 18.0)) * damage_rate
	var base_knockback: float = maxf(0.01, scaled_knockback(float(weapon.get("knockback", 1.8))))
	var knockback_rate: float = swing_knockback / base_knockback
	var shockwave_knockback: float = scaled_knockback(float(weapon.get("shockwaveKnockback", 1.0))) * knockback_rate
	var shockwave_origin: Vector2 = player_pos + norm_dir * 18.0

	hit_effects.append({
		"kind": "ban_judgement_shockwave",
		"pos": shockwave_origin,
		"dir": norm_dir,
		"life": float(weapon.get("shockwaveLife", 0.22)),
		"maxLife": float(weapon.get("shockwaveLife", 0.22)),
		"delay": float(weapon.get("shockwaveDelay", 0.12)),
		"maxDelay": float(weapon.get("shockwaveDelay", 0.12)),
		"range": shockwave_range,
		"width": shockwave_width,
		"damage": shockwave_damage,
		"knockback": shockwave_knockback,
		"stunDuration": stun_duration,
		"heavyStunDuration": heavy_stun_duration,
		"screenShakePower": float(weapon.get("screenShakePower", 0.0)) * 0.72,
		"screenShakeDuration": float(weapon.get("screenShakeDuration", 0.10)),
		"hitStop": float(weapon.get("hitStop", 0.0)) * 0.72,
		"hitIds": hit_ids.duplicate(),
		"count": shockwave_hits
	})
	hit_effects.append({
		"pos": player_pos,
		"dir": norm_dir,
		"life": 0.26,
		"range": swing_range * 0.92,
		"arcAngle": arc_angle,
		"hammer": true,
		"judgement": true,
		"hit": closest_swing_hit,
		"count": swing_hits
	})
	return {
		"hits": hits,
		"swingHits": swing_hits,
		"swingEnemyHits": swing_enemy_hits,
		"shockwaveHits": shockwave_hits,
		"closestHit": closest_hit
	}

static func update_hammer(context: Dictionary) -> Dictionary:
	var result: Dictionary = {
		"attackTimer": float(context["attackTimer"]),
		"muteTimer": float(context["muteTimer"]),
		"lastDir": Vector2(context["lastDir"]),
		"hitFx": [],
		"killed": [],
		"destroyedBoxes": [],
		"barrierHitRequests": [],
		"chat": []
	}
	var hit_effects: Array = result["hitFx"] as Array
	var killed_enemies: Array = result["killed"] as Array
	var destroyed_boxes: Array = result["destroyedBoxes"] as Array
	var barrier_hit_requests: Array = result["barrierHitRequests"] as Array
	var chat_events: Array = result["chat"] as Array
	var weapon_type: String = String(context["weaponType"])
	if not is_melee_attack_type(weapon_type):
		return result
	var attack_timer_value: float = float(context["attackTimer"]) - float(context["delta"])
	if attack_timer_value > 0.0:
		result["attackTimer"] = attack_timer_value
		return result
	var weapon: Dictionary = context.get("weapon", {}) as Dictionary
	var interval_rate: float = 0.9 if bool(context["supportAttack"]) else 1.0
	var min_interval: float = float(weapon.get("minAttackInterval", weapon.get("minCooldown", 0.0)))
	var base_interval: float = attack_interval(weapon, 0.85)
	attack_timer_value = maxf(min_interval, maxf(base_interval * 0.50, float(context["interval"]) * interval_rate))
	if bool(context.get("normalWeaponsDisabled", false)):
		result["attackTimer"] = 0.0
		return result
	var mute_timer_value: float = float(context["muteTimer"]) + float(context["interval"])
	var mute_window: float = 1.1 * float(context["weaponMuteRate"])
	if bool(context["weaponMute"]) and fmod(mute_timer_value, 3.0) < mute_window:
		result["attackTimer"] = attack_timer_value
		result["muteTimer"] = mute_timer_value
		chat_events.append("武器ミュート中")
		return result
	var rng: RandomNumberGenerator = context["rng"] as RandomNumberGenerator
	var player_pos: Vector2 = Vector2(context["playerPos"])
	var enemies: Array = context["enemies"] as Array
	var destructibles: Array = context["destructibles"] as Array
	var enemy_bullets: Array = context["enemyBullets"] as Array
	var dir: Vector2 = Vector2(context.get("facingDir", Vector2.RIGHT))
	if dir.length() < 0.1:
		dir = Vector2(context["lastDir"])
	if dir.length() < 0.1:
		dir = Vector2.RIGHT
	dir = dir.normalized()
	if bool(context["takeback"]):
		dir = Vector2.RIGHT.rotated(rng.randf_range(0.0, TAU))
	elif bool(context["attackRightOnly"]):
		var right_power: float = float(context["attackRightOnlyRate"])
		if right_power >= 0.95 or rng.randf() <= 0.70:
			dir = Vector2.RIGHT
	if bool(context["attackJitter"]):
		dir = dir.rotated(rng.randf_range(-0.45, 0.45))
	result["lastDir"] = dir
	var hits: int = 0
	var enemy_hits: int = 0
	var is_judgement: bool = weapon_type == "melee_shockwave" or String(weapon.get("id", "")) == "ban_judgement"
	var inherited_range_rate: float = float(context["range"]) / maxf(1.0, range_base(weapon))
	var area_rate: float = attack_area_rate(context)
	var effective_range: float = _apply_short_range(context, float(context["range"]), 0.75, 0.85, SHORT_RANGE_MIN_AREA_RADIUS) * area_rate
	var arc_angle: float = float(context.get("arcAngle", 120.0)) if is_judgement else float(context.get("arcAngle", 120.0)) + 8.0
	var arc_dot_threshold: float = cos(deg_to_rad(arc_angle * 0.5))
	var closest_hit: Vector2 = player_pos + dir * effective_range
	if is_judgement:
		var judgement_result: Dictionary = _apply_ban_judgement_attack(
			weapon,
			enemies,
			destructibles,
			enemy_bullets,
			player_pos,
			dir,
			effective_range,
			arc_angle,
			float(context["damage"]),
			float(context["knockback"]),
			inherited_range_rate * _short_range_projectile_rate(context),
			inherited_range_rate * _short_range_area_rate(context) * area_rate,
			killed_enemies,
			destroyed_boxes,
			hit_effects,
			barrier_hit_requests
		)
		hits = int(judgement_result.get("hits", 0))
		closest_hit = judgement_result.get("closestHit", closest_hit) as Vector2
		var swing_hits: int = int(judgement_result.get("swingHits", 0))
		var swing_enemy_hits: int = int(judgement_result.get("swingEnemyHits", swing_hits))
		if swing_hits > 0:
			_request_weapon_hit_reaction(result, weapon, swing_hits, swing_enemy_hits)
		if hits > 0:
			chat_events.append("BANジャッジメント命中！")
		result["attackTimer"] = attack_timer_value
		result["muteTimer"] = mute_timer_value
		return result
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item
		if float(enemy["hp"]) <= 0.0:
			continue
		var enemy_pos: Vector2 = Vector2(enemy["pos"])
		var to_enemy: Vector2 = enemy_pos - player_pos
		var enemy_radius: float = float(enemy.get("radius", 20.0))
		var range_padding: float = enemy_radius * 0.65 + 12.0
		var hit_range: float = effective_range + range_padding
		var distance_sq: float = to_enemy.length_squared()
		if distance_sq <= hit_range * hit_range and distance_sq > 0.01:
			var enemy_dir: Vector2 = to_enemy / sqrt(distance_sq)
			if dir.dot(enemy_dir) < arc_dot_threshold:
				continue
			var damage: float = float(context["damage"])
			var hit_result := _apply_enemy_hit(enemy, damage, enemy_dir, float(context["knockback"]), killed_enemies, hit_effects, barrier_hit_requests)
			if hit_result == HIT_DAMAGED:
				hits += 1
				enemy_hits += 1
			if enemy_pos.distance_squared_to(player_pos) < closest_hit.distance_squared_to(player_pos):
				closest_hit = enemy_pos
	for box_item in destructibles:
		var box: Dictionary = box_item as Dictionary
		var box_pos: Vector2 = Vector2(box["pos"])
		var to_box: Vector2 = box_pos - player_pos
		var box_padding: float = float(box.get("radius", 24.0)) * 0.55 + 10.0
		var box_hit_range: float = effective_range + box_padding
		var box_distance_sq: float = to_box.length_squared()
		if float(box.get("hp", 0.0)) > 0.0 and box_distance_sq <= box_hit_range * box_hit_range and box_distance_sq > 0.01 and dir.dot(to_box / sqrt(box_distance_sq)) >= arc_dot_threshold:
			DestructibleSystemScript.damage_box(box, 1.0, destroyed_boxes, hit_effects)
			hits += 1
	hits += _clear_enemy_bullets_in_arc(enemy_bullets, player_pos, dir, effective_range + 18.0, arc_angle, hit_effects)
	hit_effects.append({"pos": player_pos, "dir": dir, "life": 0.26, "range": effective_range * 0.92, "arcAngle": arc_angle, "hammer": true, "hit": closest_hit, "count": hits})
	if hits > 0:
		chat_events.append("BAN命中！")
		_request_weapon_hit_reaction(result, weapon, hits, enemy_hits)
	result["attackTimer"] = attack_timer_value
	result["muteTimer"] = mute_timer_value
	return result

static func update_projectiles(context: Dictionary) -> Dictionary:
	var result: Dictionary = {
		"superchatTimer": float(context["superchatTimer"]),
		"bullets": context["bullets"],
		"hitFx": [],
		"killed": [],
		"destroyedBoxes": [],
		"barrierHitRequests": [],
		"superchatShotFired": false
	}
	var killed_enemies: Array = result["killed"] as Array
	var destroyed_boxes: Array = result["destroyedBoxes"] as Array
	var hit_effects: Array = result["hitFx"] as Array
	var barrier_hit_requests: Array = result["barrierHitRequests"] as Array
	var delta: float = float(context["delta"])
	var timer: float = float(context["superchatTimer"]) - delta
	var is_main_projectile: bool = String(context["weaponType"]) == "projectile"
	var superchat_level: int = int(context["superchatLevel"])
	var bullet_support_level: int = int(context.get("bulletSupportLevel", 0))
	var has_projectile: bool = is_main_projectile or superchat_level > 0
	var player_pos: Vector2 = Vector2(context["playerPos"])
	var enemies: Array = context["enemies"] as Array
	var destructibles: Array = context["destructibles"] as Array
	var bullets: Array = context["bullets"] as Array
	var enemy_bullets: Array = context["enemyBullets"] as Array
	var weapon_timers: Dictionary = context.get("weaponTimers", {}) as Dictionary
	var area_rate: float = attack_area_rate(context)
	if has_projectile and timer <= 0.0 and bool(context.get("normalWeaponsDisabled", false)):
		timer = 0.0
	elif has_projectile and timer <= 0.0:
		var base_interval: float = float(context["interval"]) if is_main_projectile else player_attack_interval(0.8, float(context.get("equipmentIntervalRate", 1.0)))
		timer = maxf(0.18, base_interval * pow(0.92, float(superchat_level)))
		var target: Variant = nearest_enemy(enemies, player_pos)
		if target != null:
			var target_data: Dictionary = target as Dictionary
			var target_pos: Vector2 = Vector2(target_data["pos"])
			var dir: Vector2 = (target_pos - player_pos).normalized()
			var range_value: float = float(context["range"]) if is_main_projectile else 520.0
			range_value = _apply_short_range(context, range_value, 0.60, 0.75, SHORT_RANGE_MIN_PROJECTILE_RANGE)
			if player_pos.distance_squared_to(target_pos) <= range_value * range_value:
				var weapon: Dictionary = context["weapon"] as Dictionary
				var speed: float = scaled_projectile_speed(float(weapon.get("projectileSpeed", 7.0))) if is_main_projectile else 460.0
				var damage: float = float(context["damage"]) if is_main_projectile else 3.0
				damage += float(superchat_level) * 1.5
				var projectile_count: int = (maxi(1, int(weapon.get("projectileCount", 1))) if is_main_projectile else 1) + bullet_support_level
				var spread_rad: float = deg_to_rad(float(weapon.get("projectileSpreadDegrees", 10.0)))
				if is_main_projectile and _is_starlight_superchat(weapon):
					weapon_timers[STARLIGHT_SHOT_COUNTER_KEY] = int(weapon_timers.get(STARLIGHT_SHOT_COUNTER_KEY, 0)) + 1
				for shot_index in range(projectile_count):
					var shot_dir: Vector2 = _spread_direction(dir, shot_index, projectile_count, spread_rad)
					if is_main_projectile and _is_starlight_superchat(weapon):
						var starlight_bullet := _starlight_bullet_data(weapon, player_pos, shot_dir, speed, range_value / speed, damage, shot_index, projectile_count, weapon_timers)
						starlight_bullet["hitRadius"] = float(starlight_bullet.get("hitRadius", 7.0)) * area_rate
						starlight_bullet["visualScale"] = area_rate
						bullets.append(starlight_bullet)
					else:
						bullets.append({"pos": player_pos, "vel": shot_dir * speed, "life": range_value / speed, "damage": damage, "hitRadius": 7.0 * area_rate, "visualScale": area_rate})
				result["superchatShotFired"] = true
	for bullet_item in bullets:
		var bullet: Dictionary = bullet_item
		bullet["pos"] = Vector2(bullet["pos"]) + Vector2(bullet["vel"]) * delta
		bullet["life"] = float(bullet["life"]) - delta
		var bullet_pos: Vector2 = Vector2(bullet["pos"])
		var bullet_hit_ids: Array = bullet.get("hitIds", []) as Array
		if float(bullet["life"]) > 0.0:
			for enemy_bullet_item in enemy_bullets:
				var enemy_bullet: Dictionary = enemy_bullet_item as Dictionary
				if float(enemy_bullet.get("life", 0.0)) <= 0.0:
					continue
				var enemy_bullet_pos: Vector2 = Vector2(enemy_bullet["pos"])
				var bullet_clash_radius: float = float(enemy_bullet.get("hitRadius", 16.0)) + float(bullet.get("hitRadius", 8.0))
				if bullet_pos.distance_squared_to(enemy_bullet_pos) <= bullet_clash_radius * bullet_clash_radius:
					enemy_bullet["life"] = -1.0
					bullet["life"] = -1.0
					hit_effects.append(_bullet_pop_fx(enemy_bullet_pos))
					break
		for enemy_item in enemies:
			var enemy: Dictionary = enemy_item
			if float(enemy["hp"]) <= 0.0:
				continue
			if float(bullet["life"]) <= 0.0:
				break
			var enemy_id: String = _attack_target_id("enemy", enemy)
			if bullet_hit_ids.has(enemy_id):
				continue
			var enemy_pos: Vector2 = Vector2(enemy["pos"])
			var enemy_hit_radius: float = float(enemy["radius"]) + float(bullet.get("hitRadius", 7.0))
			if bullet_pos.distance_squared_to(enemy_pos) < enemy_hit_radius * enemy_hit_radius:
				var damage: float = float(bullet["damage"])
				var hit_pos: Vector2 = enemy_pos
				var bullet_vel := Vector2(bullet["vel"])
				var vel_sq := bullet_vel.length_squared()
				var push_dir: Vector2 = bullet_vel / sqrt(vel_sq) if vel_sq >= 0.01 else Vector2.ZERO
				if push_dir.length_squared() < 0.01:
					var fallback_offset := hit_pos - player_pos
					var fallback_sq := fallback_offset.length_squared()
					push_dir = fallback_offset / sqrt(fallback_sq) if fallback_sq >= 0.01 else Vector2.RIGHT
				if push_dir.length_squared() < 0.01:
					push_dir = Vector2.RIGHT
				bullet_hit_ids.append(enemy_id)
				bullet["hitIds"] = bullet_hit_ids
				var visual_kind: String = String(bullet.get("visualKind", ""))
				var is_starlight_bullet: bool = visual_kind == "starlight_superchat" or visual_kind == "high_superchat"
				var is_premium_bullet: bool = bool(bullet.get("premium", false))
				var hit_result := _apply_enemy_hit(enemy, damage, push_dir, float(context.get("knockback", 0.0)) * 0.42, killed_enemies, hit_effects, barrier_hit_requests, String(bullet.get("source", "")))
				if hit_result == HIT_DAMAGED:
					if is_starlight_bullet:
						hit_effects.append(_starlight_hit_fx(hit_pos, is_premium_bullet))
						if _starlight_enemy_defeated(enemy):
							hit_effects.append(_starlight_defeat_fx(enemy, is_premium_bullet))
					var weapon_for_hit: Dictionary = context["weapon"] as Dictionary
					if is_premium_bullet:
						var explosion_hits: int = _apply_starlight_explosion(weapon_for_hit, context, hit_pos, enemies, destructibles, killed_enemies, destroyed_boxes, hit_effects, barrier_hit_requests)
						_request_weapon_hit_reaction(result, weapon_for_hit, 1 + explosion_hits, 1 + explosion_hits)
					_request_weapon_hit_reaction(result, context["weapon"] as Dictionary, 1)
				var pierce_left: int = int(bullet.get("pierceLeft", 0))
				if pierce_left > 0:
					bullet["pierceLeft"] = pierce_left - 1
					continue
				bullet["life"] = -1.0
				break
		if float(bullet["life"]) > 0.0:
			for box_item in destructibles:
				var box: Dictionary = box_item as Dictionary
				if float(box.get("hp", 0.0)) <= 0.0:
					continue
				var box_id: String = _attack_target_id("box", box)
				if bullet_hit_ids.has(box_id):
					continue
				var box_pos: Vector2 = Vector2(box["pos"])
				var box_hit_radius: float = float(box.get("radius", 24.0)) + float(bullet.get("hitRadius", 7.0))
				if bullet_pos.distance_squared_to(box_pos) < box_hit_radius * box_hit_radius:
					DestructibleSystemScript.damage_box(box, 1.0, destroyed_boxes, hit_effects)
					var hit_pos: Vector2 = box_pos
					bullet_hit_ids.append(box_id)
					bullet["hitIds"] = bullet_hit_ids
					if bool(bullet.get("premium", false)):
						hit_effects.append(_starlight_hit_fx(hit_pos, true))
						_apply_starlight_explosion(context["weapon"] as Dictionary, context, hit_pos, enemies, destructibles, killed_enemies, destroyed_boxes, hit_effects, barrier_hit_requests)
					elif String(bullet.get("visualKind", "")) == "starlight_superchat":
						hit_effects.append(_starlight_hit_fx(hit_pos))
					var pierce_left: int = int(bullet.get("pierceLeft", 0))
					if pierce_left > 0:
						bullet["pierceLeft"] = pierce_left - 1
						continue
					bullet["life"] = -1.0
					break
	var arena: Rect2 = context["arena"]
	var bullet_keep_area: Rect2 = arena.grow(60.0)
	var kept_bullets: Array = []
	for bullet_item in bullets:
		var bullet: Dictionary = bullet_item
		if float(bullet["life"]) > 0.0 and bullet_keep_area.has_point(Vector2(bullet["pos"])):
			kept_bullets.append(bullet)
	result["bullets"] = kept_bullets
	result["superchatTimer"] = timer
	return result

static func update_boomerang(context: Dictionary) -> Dictionary:
	var result: Dictionary = {
		"hitFx": [],
		"killed": [],
		"destroyedBoxes": [],
		"barrierHitRequests": [],
		"boomerangHits": context["boomerangHits"],
		"boomerangOrbitSe": false
	}
	var hit_effects: Array = result["hitFx"] as Array
	var killed_enemies: Array = result["killed"] as Array
	var destroyed_boxes: Array = result["destroyedBoxes"] as Array
	var barrier_hit_requests: Array = result["barrierHitRequests"] as Array
	var weapon: Dictionary = context["weapon"] as Dictionary
	var weapon_type: String = String(context["weaponType"])
	var weapon_timers: Dictionary = context.get("weaponTimers", {}) as Dictionary
	if bool(context.get("normalWeaponsDisabled", false)):
		return result
	var boomerang_level: int = int(context["boomerangLevel"])
	var is_main_orbit: bool = weapon_type == "orbit"
	var is_maro_ring: bool = is_main_orbit and _is_maro_comment_ring(weapon)
	var count: int = orbit_count(weapon, boomerang_level)
	if count > 0 and not is_maro_ring:
		count += int(context.get("bulletSupportLevel", 0))
	if count <= 0:
		return result
	var player_pos: Vector2 = Vector2(context["playerPos"])
	var radius: float = float(context["range"]) if is_main_orbit else 78.0
	radius = _apply_short_range(context, radius, 0.70, 0.85, SHORT_RANGE_MIN_ORBIT_RADIUS)
	if is_maro_ring:
		_update_maro_comment_pulse(weapon, context, radius, weapon_timers, context["enemies"] as Array, killed_enemies, hit_effects, result)
		var pulse_until: float = float(weapon_timers.get(MARO_PULSE_UNTIL_KEY, 0.0))
		var pulse_duration: float = maxf(0.05, float(weapon.get("pulseDuration", 0.25)))
		if float(context["elapsed"]) < pulse_until:
			var pulse_progress: float = clampf(1.0 - (pulse_until - float(context["elapsed"])) / pulse_duration, 0.0, 1.0)
			var pulse_strength: float = sin(pulse_progress * PI)
			radius = lerpf(radius, _maro_pulse_radius(weapon, radius), pulse_strength)
			_nudge_exp_orbs_for_maro_pulse(context.get("expOrbs", []) as Array, player_pos, _maro_pulse_exp_pull_radius(weapon), float(context["delta"]))
	var hit_radius: float = float(weapon.get("hitRadius", 34.0)) if is_main_orbit else 28.0
	hit_radius *= attack_area_rate(context)
	var speed: float = orbit_speed(weapon)
	var damage: float = float(context["damage"]) if is_main_orbit else 5.0
	damage += float(boomerang_level) * 1.5
	var hit_interval: float = float(weapon.get("hitInterval", 0.6)) if is_main_orbit else 0.6
	var elapsed: float = float(context["elapsed"])
	result["boomerangOrbitSe"] = _boomerang_orbit_se_due(weapon, weapon_timers, elapsed, speed, is_main_orbit)
	var enemies: Array = context["enemies"] as Array
	var destructibles: Array = context["destructibles"] as Array
	var enemy_bullets: Array = context["enemyBullets"] as Array
	var hit_memory: Dictionary = context["boomerangHits"] as Dictionary
	for i in range(count):
		var angle: float = elapsed * speed + TAU * float(i) / float(count)
		var pos: Vector2 = player_pos + Vector2(cos(angle), sin(angle)) * radius
		var cleared_bullets: int = _clear_enemy_bullets_in_circle(enemy_bullets, pos, hit_radius + 10.0, hit_effects, "maro_comment" if is_maro_ring else "")
		if is_maro_ring and cleared_bullets > 0:
			weapon_timers[MARO_FLASH_UNTIL_KEY] = elapsed + 0.18
		for enemy_item in enemies:
			var enemy: Dictionary = enemy_item
			if float(enemy["hp"]) <= 0.0:
				continue
			var enemy_id: String = "%s_%d" % [String(enemy["kind"]), int(enemy.get("uid", 0))]
			var hit_key: String = "%d:%s" % [i, enemy_id]
			if float(hit_memory.get(hit_key, 0.0)) > elapsed:
				continue
			var enemy_pos: Vector2 = Vector2(enemy["pos"])
			var enemy_hit_radius: float = float(enemy["radius"]) + hit_radius
			if pos.distance_squared_to(enemy_pos) < enemy_hit_radius * enemy_hit_radius:
				var push_dir: Vector2 = (enemy_pos - player_pos).normalized()
				var hit_result := _apply_enemy_hit(enemy, damage, push_dir, float(context["knockback"]) * 0.45, killed_enemies, hit_effects, barrier_hit_requests)
				if hit_result == HIT_DAMAGED:
					_request_weapon_hit_reaction(result, weapon, 1)
				hit_memory[hit_key] = elapsed + hit_interval
				if is_maro_ring:
					hit_effects.append(_maro_comment_hit_fx(enemy_pos))
				else:
					hit_effects.append({"pos": pos, "dir": push_dir, "life": 0.14, "range": 36.0, "hit": enemy_pos, "count": 1})
		for box_item in destructibles:
			var box: Dictionary = box_item as Dictionary
			if float(box.get("hp", 0.0)) <= 0.0:
				continue
			var box_id: String = "box_%d" % int(box.get("uid", 0))
			var box_hit_key: String = "%d:%s" % [i, box_id]
			if float(hit_memory.get(box_hit_key, 0.0)) > elapsed:
				continue
			var box_pos: Vector2 = Vector2(box["pos"])
			var box_hit_radius: float = float(box.get("radius", 24.0)) + hit_radius
			if pos.distance_squared_to(box_pos) < box_hit_radius * box_hit_radius:
				hit_memory[box_hit_key] = elapsed + hit_interval
				DestructibleSystemScript.damage_box(box, 1.0, destroyed_boxes, hit_effects)
	result["boomerangHits"] = hit_memory
	return result

static func update_equipment_weapons(context: Dictionary) -> Dictionary:
	var result: Dictionary = {"timers": context["timers"], "hitFx": [], "killed": [], "destroyedBoxes": [], "chat": [], "barrierHitRequests": []}
	var timers: Dictionary = result["timers"] as Dictionary
	var hit_effects: Array = result["hitFx"] as Array
	var killed_enemies: Array = result["killed"] as Array
	var destroyed_boxes: Array = result["destroyedBoxes"] as Array
	var barrier_hit_requests: Array = result["barrierHitRequests"] as Array
	var chat_events: Array = result["chat"] as Array
	var delta: float = float(context["delta"])
	var weapon_data: Array = context["weaponData"] as Array
	var player_weapons: Array = context["playerWeapons"] as Array
	var main_weapon_id: String = String(context.get("mainWeaponId", ""))
	var player_pos: Vector2 = Vector2(context["playerPos"])
	var facing_dir: Vector2 = Vector2(context["facingDir"]).normalized()
	if facing_dir.length() < 0.1:
		facing_dir = Vector2.RIGHT
	var enemies: Array = context["enemies"] as Array
	var destructibles: Array = context["destructibles"] as Array
	var enemy_bullets: Array = context["enemyBullets"] as Array
	var active_fx: Array = context.get("activeFx", []) as Array
	var support_level: int = int(context.get("bulletSupportLevel", 0))
	var normal_weapons_disabled := bool(context.get("normalWeaponsDisabled", false))
	var area_rate: float = attack_area_rate(context)
	for entry_item in player_weapons:
		var entry: Dictionary = entry_item as Dictionary
		var weapon_id: String = String(entry.get("id", ""))
		if (weapon_id == main_weapon_id and not _is_stage2_weapon_id(weapon_id)) or weapon_id in ["superchat_shot", "comment_boomerang"]:
			continue
		var weapon: Dictionary = find_weapon(weapon_data, weapon_id, {})
		if weapon.is_empty():
			continue
		if _is_stage2_weapon_id(weapon_id):
			var stage2_result := _update_stage2_weapon(weapon, entry, context, timers, hit_effects, killed_enemies, barrier_hit_requests)
			_merge_weapon_result(result, stage2_result)
			continue
		var timer: float = float(timers.get(weapon_id, 0.0)) - delta
		if timer > 0.0:
			timers[weapon_id] = timer
			continue
		if normal_weapons_disabled:
			timers[weapon_id] = 0.0
			continue
		var attack_dir: Vector2 = _direction_with_attack_right_only(facing_dir, context)
		var level_value: int = int(entry.get("level", 1))
		var damage: float = (float(weapon.get("damage", 4.0)) + float(level_value - 1) * 1.5) * float(context["damageRate"])
		var range_value: float = range_base(weapon) * float(context["rangeRate"])
		var base_interval: float = attack_interval(weapon, 1.0)
		var interval: float = player_attack_interval(base_interval, float(context["intervalRate"]))
		if weapon_id == "kusa_wave":
			damage = _kusa_wave_damage_for_level(level_value) * float(context["damageRate"])
			range_value = _kusa_wave_distance_for_level(level_value) * float(context["rangeRate"])
			interval = player_attack_interval(_kusa_wave_interval_for_level(level_value), float(context["intervalRate"]))
		range_value = _short_range_range_for_weapon(weapon_id, weapon, range_value, context)
		var spawn_support_level: int = support_level if String(weapon.get("attribute", "")) == "bullet" else 0
		timers[weapon_id] = maxf(0.18, interval)
		if attack_type(weapon) == "melee_arc":
			var attack_range: float = range_value * area_rate
			var arc_angle: float = float(weapon.get("arcAngle", 120.0)) + 8.0
			var closest_hit: Vector2 = player_pos + attack_dir * attack_range
			var enemy_hits: int = _apply_arc_damage(enemies, player_pos, attack_dir, attack_range, arc_angle, damage, float(context["knockback"]), killed_enemies, hit_effects, barrier_hit_requests)
			var hits: int = enemy_hits
			hits += _apply_arc_damage_to_boxes(destructibles, player_pos, attack_dir, attack_range, arc_angle, destroyed_boxes, hit_effects)
			hits += _clear_enemy_bullets_in_arc(enemy_bullets, player_pos, attack_dir, attack_range + 18.0 * area_rate, arc_angle, hit_effects)
			_request_weapon_hit_reaction(result, weapon, hits, enemy_hits)
			hit_effects.append({
				"pos": player_pos,
				"dir": attack_dir,
				"life": 0.24,
				"range": attack_range * 0.88,
				"arcAngle": arc_angle,
				"hammer": weapon_id == "ban_hammer",
				"hit": closest_hit,
				"count": hits
			})
			if weapon_id == "ban_hammer" and hits > 0:
				chat_events.append("BAN命中！")
		elif weapon_id == "mic_barrier":
			var attack_radius: float = range_value * area_rate
			var enemy_hits: int = _apply_circle_damage(enemies, player_pos, attack_radius, damage, float(context["knockback"]), killed_enemies, hit_effects, barrier_hit_requests)
			_apply_circle_damage_to_boxes(destructibles, player_pos, attack_radius, destroyed_boxes, hit_effects)
			_clear_enemy_bullets_in_circle(enemy_bullets, player_pos, attack_radius, hit_effects)
			_request_weapon_hit_reaction(result, weapon, enemy_hits, enemy_hits)
			hit_effects.append({"kind": "mic_wave", "pos": player_pos, "life": 0.42, "maxLife": 0.42, "range": attack_radius, "hitCount": enemy_hits, "count": enemy_hits})
		elif weapon_id == "spotlight":
			var target: Variant = nearest_enemy(enemies, player_pos)
			var center: Vector2 = player_pos + attack_dir * range_value
			if target != null:
				var target_pos: Vector2 = Vector2((target as Dictionary)["pos"])
				var to_target: Vector2 = target_pos - player_pos
				if to_target.length() <= range_value:
					center = target_pos
				elif to_target.length() > 0.1:
					center = player_pos + to_target.normalized() * range_value
			var spotlight_radius: float = maxf(72.0 * float(context["rangeRate"]) * area_rate * _short_range_explosion_area_rate(context), SHORT_RANGE_MIN_AREA_RADIUS)
			var enemy_hits: int = _apply_circle_damage(enemies, center, spotlight_radius, damage, float(context["knockback"]) * 0.35, killed_enemies, hit_effects, barrier_hit_requests)
			_apply_circle_damage_to_boxes(destructibles, center, spotlight_radius, destroyed_boxes, hit_effects)
			_clear_enemy_bullets_in_circle(enemy_bullets, center, spotlight_radius, hit_effects)
			_request_weapon_hit_reaction(result, weapon, enemy_hits, enemy_hits)
			hit_effects.append({"kind": "spotlight", "pos": center, "dir": Vector2.RIGHT, "life": 0.55, "maxLife": 0.55, "range": spotlight_radius, "arcAngle": 360.0, "hit": center, "count": 1})
		elif weapon_id == "kusa_wave":
			var base_fire_dir: Vector2 = _kusa_wave_fire_direction(Vector2(context.get("playerVel", Vector2.ZERO)), facing_dir, context)
			var fire_dirs: Array = _kusa_wave_supported_directions(base_fire_dir, support_level)
			var size_scale: float = _kusa_wave_size_for_level(level_value)
			var max_distance: float = range_value
			var max_life: float = maxf(KUSA_WAVE_MIN_LIFE, max_distance / KUSA_WAVE_SPEED + 0.35)
			for fire_dir_item in fire_dirs:
				var fire_dir: Vector2 = Vector2(fire_dir_item).normalized()
				if fire_dir.length() < 0.1:
					continue
				var start_pos: Vector2 = player_pos + fire_dir * (28.0 + 8.0 * size_scale) + Vector2(0.0, -4.0)
				hit_effects.append({
					"kind": "kusa_wave",
					"pos": start_pos,
					"dir": fire_dir,
					"vel": fire_dir * KUSA_WAVE_SPEED,
					"life": max_life,
					"maxLife": max_life,
					"range": max_distance,
					"maxDistance": max_distance,
					"distanceTraveled": 0.0,
					"bouncesLeft": _kusa_wave_bounces_for_level(level_value),
					"sizeScale": size_scale,
					"count": 1,
					"damage": damage,
					"knockback": float(context["knockback"]) * 0.45,
					"screenShakePower": float(weapon.get("screenShakePower", 0.0)),
					"screenShakeDuration": float(weapon.get("screenShakeDuration", 0.10)),
					"hitStop": float(weapon.get("hitStop", 0.0)),
					"hitRadius": 18.0 * size_scale * area_rate,
					"attackAreaRate": area_rate,
					"hitCooldowns": {}
				})
		elif weapon_id == "comment_pin":
			_spawn_comment_pin_projectiles(weapon, level_value, spawn_support_level, player_pos, attack_dir, enemies, range_value, damage, hit_effects, area_rate)
		elif weapon_id == "emote_mine":
			_spawn_emote_mines(weapon, level_value, spawn_support_level, player_pos, active_fx, hit_effects, damage, float(context["rangeRate"]) * area_rate * _short_range_explosion_area_rate(context))
		elif weapon_id == "ng_word_laser":
			var laser_hits: int = _fire_ng_word_lasers(weapon, level_value, spawn_support_level, player_pos, attack_dir, enemies, destructibles, enemy_bullets, range_value, damage, float(context["rangeRate"]) * area_rate, float(context["knockback"]), killed_enemies, destroyed_boxes, hit_effects, barrier_hit_requests)
			if laser_hits > 0:
				_merge_reaction_result(result, {"enemyDamaged": true, "weaponCommentKind": "ng_word_laser"})
		elif weapon_id == "listener_summon":
			_spawn_listener_summons(weapon, level_value, spawn_support_level, player_pos, attack_dir, active_fx, hit_effects, damage, float(context["rangeRate"]) * _short_range_search_rate(context), float(context["knockback"]), area_rate)
	return result

static func _is_stage2_weapon_id(weapon_id: String) -> bool:
	return weapon_id in STAGE2_WEAPON_IDS

static func _stage2_empty_result() -> Dictionary:
	return {"hitFx": [], "killed": [], "destroyedBoxes": [], "chat": [], "barrierHitRequests": []}

static func _stage2_states(timers: Dictionary) -> Dictionary:
	if not timers.has(STAGE2_WEAPON_STATE_KEY) or not (timers.get(STAGE2_WEAPON_STATE_KEY) is Dictionary):
		timers[STAGE2_WEAPON_STATE_KEY] = {}
	return timers[STAGE2_WEAPON_STATE_KEY] as Dictionary

static func _stage2_base_damage(weapon: Dictionary) -> float:
	return float(weapon.get("baseDamage", weapon.get("damage", 0.0)))

static func _stage2_visual_config(source: Dictionary, role: String) -> Dictionary:
	var visuals: Dictionary = source.get("visuals", {}) as Dictionary
	return visuals.get(role, {}) as Dictionary

static func _stage2_visual_duration(source: Dictionary, role: String, fallback: float) -> float:
	return maxf(0.05, float(_stage2_visual_config(source, role).get("durationSeconds", fallback)))

static func _stage2_coverage_rate(context: Dictionary) -> float:
	return clampf(float(context.get("rangeRate", 1.0)) * attack_area_rate(context), 0.1, 1.60)

static func _stage2_interval(weapon: Dictionary, context: Dictionary, fallback: float) -> float:
	var base_interval := float(weapon.get("activationInterval", weapon.get("hitInterval", weapon.get("attackInterval", fallback))))
	return player_attack_interval(base_interval, float(context.get("intervalRate", 1.0)))

static func _stage2_retry_delay(weapon: Dictionary) -> float:
	return maxf(0.01, float(weapon.get("retargetRetry", 0.15)))

static func _stage2_level_data(weapon: Dictionary, level: int) -> Dictionary:
	var resolved: Dictionary = weapon.duplicate(true)
	var stats: Array = weapon.get("levelStats", []) as Array
	if not stats.is_empty():
		var index := clampi(level - 1, 0, stats.size() - 1)
		var level_data: Dictionary = stats[index] as Dictionary
		for key in level_data.keys():
			resolved[String(key)] = level_data[key]
	resolved["level"] = level
	return resolved

static func _stage2_behavior(weapon: Dictionary) -> String:
	return String(weapon.get("stage2Behavior", weapon.get("attackType", "")))

static func _stage2_weapon_with_inherited_visuals(weapon: Dictionary, context: Dictionary) -> Dictionary:
	var resolved: Dictionary = weapon.duplicate(true)
	if not (resolved.get("visuals", {}) as Dictionary).is_empty():
		return resolved
	var source_id := String(resolved.get("visualSourceWeaponId", ""))
	if source_id == "":
		return resolved
	var source := find_weapon(context.get("weaponData", []) as Array, source_id, {})
	if not source.is_empty():
		resolved["visuals"] = (source.get("visuals", {}) as Dictionary).duplicate(true)
	return resolved

static func _update_stage2_weapon(weapon: Dictionary, entry: Dictionary, context: Dictionary, timers: Dictionary, hit_effects: Array, killed_enemies: Array, barrier_hit_requests: Array) -> Dictionary:
	var weapon_id := String(weapon.get("id", ""))
	var max_level := maxi(1, int(weapon.get("maxLevel", 1)))
	var level := clampi(int(entry.get("level", 1)), 1, max_level)
	var level_weapon := _stage2_weapon_with_inherited_visuals(_stage2_level_data(weapon, level), context)
	var behavior := _stage2_behavior(level_weapon)
	if behavior == "moderator_shield":
		return _update_moderator_shield_weapon(level_weapon, context, timers)
	if behavior == "fansa_baton":
		return _update_fansa_baton_weapon(level_weapon, entry, context, timers)
	if behavior == "tsuri_thumbnail_rod":
		return _update_tsuri_rod_weapon(level_weapon, context, timers)
	if behavior == "moderator_fortress":
		return _update_moderator_fortress_weapon(level_weapon, context, timers)
	if behavior == "fansa_climax":
		return _update_fansa_climax_weapon(level_weapon, context, timers)
	if behavior == "buzz_thumbnail_rod":
		return _update_buzz_thumbnail_rod_weapon(level_weapon, context, timers)
	return _stage2_empty_result()

static func _stage2_alive_enemy(enemy: Dictionary) -> bool:
	return float(enemy.get("hp", 0.0)) > 0.0 and not bool(enemy.get("defeatResolved", false))

static func _stage2_alive_box(box: Dictionary) -> bool:
	return float(box.get("hp", 0.0)) > 0.0

static func _stage2_box_token(box: Dictionary) -> String:
	return "box:%d" % int(box.get("uid", -1))

static func _stage2_nearest_box(destructibles: Array, origin: Vector2, max_range: float) -> Dictionary:
	var nearest: Dictionary = {}
	var nearest_distance := INF
	for box_item in destructibles:
		var box: Dictionary = box_item as Dictionary
		if not _stage2_alive_box(box):
			continue
		var distance := origin.distance_to(Vector2(box.get("pos", Vector2.ZERO)))
		if distance <= max_range and distance < nearest_distance:
			nearest = box
			nearest_distance = distance
	return nearest

static func _stage2_entity_token(enemy: Dictionary) -> String:
	var token := String(enemy.get("spawnToken", ""))
	if token != "":
		return token
	return "%s:%d" % [String(enemy.get("kind", "")), int(enemy.get("uid", -1))]

static func cleanup_runtime_for_weapon(target: Node, base_id: String = "", evolved_id: String = "", reason: String = "cleanup") -> void:
	var ids: Array[String] = []
	if base_id != "":
		ids.append(base_id)
	if evolved_id != "" and not ids.has(evolved_id):
		ids.append(evolved_id)
	if ids.is_empty():
		for stage_id in STAGE2_WEAPON_IDS:
			ids.append(String(stage_id))
	var enemies_value: Variant = target.get("enemies")
	var enemies: Array = enemies_value as Array if enemies_value is Array else []
	var hit_fx_value: Variant = target.get("hit_fx")
	var hit_fx: Array = hit_fx_value as Array if hit_fx_value is Array else []
	var remaining: Array = []
	for fx_item in hit_fx:
		var fx: Dictionary = fx_item as Dictionary
		var fx_id := String(fx.get("weaponId", fx.get("owner", "")))
		if not ids.has(fx_id):
			remaining.append(fx)
			continue
		_restore_stage2_transient_states(fx)
		fx["completionReason"] = reason
		target.set("lastWeaponRuntimeCleanupReason", reason)
	target.set("hit_fx", remaining)
	var timers_value: Variant = target.get("equipment_weapon_timers")
	if timers_value is Dictionary:
		var timers: Dictionary = timers_value as Dictionary
		for weapon_id in ids:
			timers.erase(weapon_id)
		var states_value: Variant = timers.get(STAGE2_WEAPON_STATE_KEY)
		if states_value is Dictionary:
			var states: Dictionary = states_value as Dictionary
			for weapon_id in ids:
				states.erase(weapon_id)
			timers[STAGE2_WEAPON_STATE_KEY] = states
		target.set("equipment_weapon_timers", timers)

static func _restore_stage2_transient_states(fx: Dictionary) -> void:
	var states_value: Variant = fx.get("suspendedTargetStates", {})
	if not states_value is Dictionary:
		return
	for state_value in (states_value as Dictionary).values():
		var state: Dictionary = state_value as Dictionary
		var enemy_value: Variant = state.get("enemy")
		if not enemy_value is Dictionary:
			continue
		var enemy: Dictionary = enemy_value as Dictionary
		var previous_value: Variant = state.get("previous", {})
		var previous: Dictionary = previous_value as Dictionary if previous_value is Dictionary else {}
		for key in ["throwing", "attackDisabled", "movementPaused", "contactDisabled", "navigationPaused", "damageInvulnerable"]:
			if previous.has(key):
				enemy[key] = previous[key]
			else:
				enemy.erase(key)

static func _stage2_quantized_direction(offset: Vector2, fallback: Vector2) -> Vector2:
	var direction := offset.normalized()
	if direction.length() < 0.1:
		direction = fallback.normalized()
	if direction.length() < 0.1:
		direction = Vector2.RIGHT
	var index := int(round(atan2(direction.y, direction.x) / (PI * 0.25)))
	return Vector2.RIGHT.rotated(float(index) * PI * 0.25).normalized()

static func _stage2_point_segment_distance(point: Vector2, from_pos: Vector2, to_pos: Vector2) -> float:
	var segment := to_pos - from_pos
	var length_sq := segment.length_squared()
	if length_sq <= 0.001:
		return point.distance_to(from_pos)
	var t := clampf((point - from_pos).dot(segment) / length_sq, 0.0, 1.0)
	return point.distance_to(from_pos + segment * t)

static func _stage2_shield_bullet_clearable(bullet: Dictionary) -> bool:
	if not bool(bullet.get("clearableByPlayerWeapon", false)):
		return false
	var source := String(bullet.get("source", "")).to_lower()
	var source_kind := String(bullet.get("sourceKind", "")).to_lower()
	var visual_kind := String(bullet.get("visualKind", "")).to_lower()
	var attack_type := String(bullet.get("attackType", "")).to_lower()
	if source.contains("laser") or source_kind.contains("boss") or source_kind.contains("relay") or source_kind.contains("collab"):
		return false
	if visual_kind.contains("laser") or visual_kind.contains("warning") or visual_kind.contains("boss"):
		return false
	if attack_type in ["laser", "beam", "floor", "warning_line", "spreadprojectile"]:
		return false
	return true

static func _shield_direction_and_score(weapon: Dictionary, context: Dictionary) -> Dictionary:
	var player_pos := Vector2(context.get("playerPos", Vector2.ZERO))
	var fallback := Vector2(context.get("facingDir", Vector2.RIGHT)).normalized()
	if fallback.length() < 0.1:
		fallback = Vector2.RIGHT
	var search_radius := float(weapon.get("searchRadius", 300.0))
	var buckets: Dictionary = {}
	var found := false
	for enemy_item in (context.get("enemies", []) as Array):
		var enemy: Dictionary = enemy_item as Dictionary
		if not _stage2_alive_enemy(enemy):
			continue
		var offset := Vector2(enemy.get("pos", Vector2.ZERO)) - player_pos
		if offset.length() > search_radius:
			continue
		var direction := _stage2_quantized_direction(offset, fallback)
		var index := int(round(atan2(direction.y, direction.x) / (PI * 0.25)))
		var weight := 1.0
		if not _is_boss_enemy(enemy) and EnemySystem.is_large_enemy(enemy):
			weight = 1.5
		var bucket: Dictionary = buckets.get(index, {"score": 0.0, "nearest": INF, "tie": 0.0, "dir": direction})
		bucket["score"] = float(bucket.get("score", 0.0)) + weight
		bucket["nearest"] = minf(float(bucket.get("nearest", INF)), offset.length())
		buckets[index] = bucket
		found = true
	for box_item in (context.get("destructibles", []) as Array):
		var box: Dictionary = box_item as Dictionary
		if not _stage2_alive_box(box):
			continue
		var offset := Vector2(box.get("pos", Vector2.ZERO)) - player_pos
		if offset.length() > search_radius:
			continue
		var direction := _stage2_quantized_direction(offset, fallback)
		var index := int(round(atan2(direction.y, direction.x) / (PI * 0.25)))
		var bucket: Dictionary = buckets.get(index, {"score": 0.0, "nearest": INF, "tie": 0.0, "dir": direction})
		bucket["score"] = float(bucket.get("score", 0.0)) + 1.0
		bucket["nearest"] = minf(float(bucket.get("nearest", INF)), offset.length())
		buckets[index] = bucket
		found = true
	for bullet_item in (context.get("enemyBullets", []) as Array):
		var bullet: Dictionary = bullet_item as Dictionary
		if float(bullet.get("life", 0.0)) <= 0.0 or not _stage2_shield_bullet_clearable(bullet):
			continue
		var offset := Vector2(bullet.get("pos", Vector2.ZERO)) - player_pos
		if offset.length() > search_radius:
			continue
		var direction := _stage2_quantized_direction(offset, fallback)
		var index := int(round(atan2(direction.y, direction.x) / (PI * 0.25)))
		var bucket: Dictionary = buckets.get(index, {"score": 0.0, "nearest": INF, "tie": 0.0, "dir": direction})
		bucket["score"] = float(bucket.get("score", 0.0)) + 1.25
		bucket["nearest"] = minf(float(bucket.get("nearest", INF)), offset.length())
		buckets[index] = bucket
		found = true
	if not found:
		return {"found": false}
	var velocity := Vector2(context.get("playerVel", Vector2.ZERO))
	var tie_direction := velocity.normalized() if velocity.length() > 0.1 else fallback
	var best: Dictionary = {}
	for key in buckets.keys():
		var candidate: Dictionary = buckets[key] as Dictionary
		candidate["tie"] = Vector2(candidate.get("dir", fallback)).dot(tie_direction)
		if best.is_empty() or float(candidate.get("score", 0.0)) > float(best.get("score", 0.0)) + 0.001 or (is_equal_approx(float(candidate.get("score", 0.0)), float(best.get("score", 0.0))) and float(candidate.get("nearest", INF)) < float(best.get("nearest", INF)) - 0.01) or (best.size() > 0 and is_equal_approx(float(candidate.get("score", 0.0)), float(best.get("score", 0.0))) and is_equal_approx(float(candidate.get("nearest", INF)), float(best.get("nearest", INF))) and float(candidate.get("tie", 0.0)) > float(best.get("tie", 0.0))):
			best = candidate
	return {"found": not best.is_empty(), "dir": Vector2(best.get("dir", fallback)).normalized(), "score": float(best.get("score", 0.0))}

static func _update_moderator_shield_weapon(weapon: Dictionary, context: Dictionary, timers: Dictionary) -> Dictionary:
	var result := _stage2_empty_result()
	var weapon_id := String(weapon.get("id", "moderator_shield"))
	var delta := float(context.get("delta", 0.0))
	var timer := float(timers.get(weapon_id, 0.0)) - delta
	if timer > 0.0:
		timers[weapon_id] = timer
		return result
	if bool(context.get("normalWeaponsDisabled", false)):
		timers[weapon_id] = 0.0
		return result
	var target := _shield_direction_and_score(weapon, context)
	if not bool(target.get("found", false)):
		timers[weapon_id] = _stage2_retry_delay(weapon)
		return result
	var direction := Vector2(target.get("dir", Vector2.RIGHT)).normalized()
	var player_pos := Vector2(context.get("playerPos", Vector2.ZERO))
	var coverage := _stage2_coverage_rate(context)
	var duration := maxf(0.05, float(weapon.get("travelDuration", 0.65)))
	var body_damage := _stage2_base_damage(weapon) * float(weapon.get("damageCoefficient", 0.90)) * float(weapon.get("damageMultiplier", 1.0)) * float(context.get("damageRate", 1.0))
	var body_width := float(weapon.get("width", 130.0)) * float(weapon.get("widthMultiplier", 1.0)) * coverage
	var fx := {
		"kind": "moderator_shield_active", "owner": weapon_id, "weaponId": weapon_id,
		"origin": player_pos, "pos": player_pos + direction * float(weapon.get("spawnOffset", 48.0)),
		"dir": direction, "age": 0.0, "life": duration + 0.05, "maxLife": duration + 0.05,
		"spawnOffset": float(weapon.get("spawnOffset", 48.0)),
		"travelDistance": float(weapon.get("travelDistance", 220.0)) * float(weapon.get("travelDistanceMultiplier", 1.0)), "travelDuration": duration,
		"width": body_width, "thickness": float(weapon.get("thickness", 48.0)),
		"damage": body_damage,
		"normalKnockbackDistance": float(weapon.get("normalKnockbackDistance", 70.0)) * float(weapon.get("normalKnockbackMultiplier", 1.0)),
		"largeKnockbackRate": float(weapon.get("largeKnockbackRate", 0.5)),
		"maxBulletClears": int(weapon.get("maxBulletClears", 3)), "bulletClears": 0,
		"hitEnemyIds": {}, "hitBoxIds": {}, "glow": 0.0,
		"visuals": (weapon.get("visuals", {}) as Dictionary).duplicate(true),
		"level": int(weapon.get("level", 1)), "allowCompletionWave": bool(weapon.get("completionWave", false)),
		"completionReason": "", "waveSpawned": false,
		"waveWidth": body_width * float(weapon.get("waveWidthMultiplier", 1.15)),
		"waveDepth": float(weapon.get("waveDepth", 26.0)),
		"waveDamage": body_damage * float(weapon.get("waveDamageRatio", 0.50)),
		"waveKnockback": float(weapon.get("normalKnockbackDistance", 70.0)) * float(weapon.get("normalKnockbackMultiplier", 1.0)) * float(weapon.get("waveKnockbackRatio", 0.35))
	}
	(result["hitFx"] as Array).append(fx)
	timers[weapon_id] = _stage2_interval(weapon, context, 3.0)
	return result

static func _update_moderator_fortress_weapon(weapon: Dictionary, context: Dictionary, timers: Dictionary) -> Dictionary:
	var result := _stage2_empty_result()
	var weapon_id := String(weapon.get("id", "moderator_fortress"))
	var timer := float(timers.get(weapon_id, 0.0)) - float(context.get("delta", 0.0))
	if timer > 0.0:
		timers[weapon_id] = timer
		return result
	if bool(context.get("normalWeaponsDisabled", false)):
		timers[weapon_id] = 0.0
		return result
	var target := _shield_direction_and_score(weapon, context)
	if not bool(target.get("found", false)):
		timers[weapon_id] = _stage2_retry_delay(weapon)
		return result
	var direction := Vector2(target.get("dir", Vector2.RIGHT)).normalized()
	var player_pos := Vector2(context.get("playerPos", Vector2.ZERO))
	var coverage := _stage2_coverage_rate(context)
	var duration := maxf(0.05, float(weapon.get("travelDuration", 0.65)))
	var body_damage := _stage2_base_damage(weapon) * float(weapon.get("damageCoefficient", 1.05)) * float(context.get("damageRate", 1.0))
	var body_width := float(weapon.get("width", 170.0)) * coverage
	var fx := {
		"kind": "moderator_fortress_active", "owner": weapon_id, "weaponId": weapon_id,
		"origin": player_pos, "pos": player_pos + direction * float(weapon.get("spawnOffset", 52.0)),
		"dir": direction, "age": 0.0, "life": duration + 0.05, "maxLife": duration + 0.05,
		"spawnOffset": float(weapon.get("spawnOffset", 52.0)), "travelDistance": float(weapon.get("travelDistance", 260.0)),
		"travelDuration": duration, "width": body_width, "thickness": float(weapon.get("thickness", 54.0)),
		"baseDamage": _stage2_base_damage(weapon), "damageRate": float(context.get("damageRate", 1.0)), "damage": body_damage, "normalKnockbackDistance": float(weapon.get("normalKnockbackDistance", 70.0)),
		"largeKnockbackRate": float(weapon.get("largeKnockbackRate", 0.60)), "maxBulletClears": int(weapon.get("maxBulletClears", 8)),
		"bulletClears": 0, "hitEnemyIds": {}, "hitBoxIds": {}, "visuals": (weapon.get("visuals", {}) as Dictionary).duplicate(true),
		"shockRadius": float(weapon.get("shockRadius", 120.0)) * coverage, "shockBaseMultiplier": float(weapon.get("shockBaseMultiplier", 1.30)),
		"shockChargePerClear": float(weapon.get("shockChargePerClear", 0.18)), "shockMaxMultiplier": float(weapon.get("shockMaxMultiplier", 2.74)),
		"shockKnockbackRatio": float(weapon.get("shockKnockbackRatio", 0.35)), "shockBulletClears": int(weapon.get("shockBulletClears", 4)),
		"completionReason": "", "waveSpawned": false
	}
	(result["hitFx"] as Array).append(fx)
	timers[weapon_id] = _stage2_interval(weapon, context, 2.7)
	return result

static func update_moderator_fortress_fx(fx: Dictionary, delta: float, enemies: Array, destructibles: Array, enemy_bullets: Array, killed_enemies: Array, destroyed_boxes: Array, hit_effects: Array, feedback: Dictionary) -> void:
	var age := float(fx.get("age", 0.0)) + delta
	var duration := maxf(0.05, float(fx.get("travelDuration", 0.65)))
	var progress := clampf(age / duration, 0.0, 1.0)
	var origin := Vector2(fx.get("origin", Vector2.ZERO))
	var direction := Vector2(fx.get("dir", Vector2.RIGHT)).normalized()
	if direction.length() < 0.1:
		direction = Vector2.RIGHT
	var position := origin + direction * (float(fx.get("spawnOffset", 52.0)) + float(fx.get("travelDistance", 260.0)) * progress)
	fx["age"] = age
	fx["pos"] = position
	fx["progress"] = progress
	var side := Vector2(-direction.y, direction.x)
	var hit_ids: Dictionary = fx.get("hitEnemyIds", {}) as Dictionary
	var half_width := float(fx.get("width", 170.0)) * 0.5
	var half_thickness := float(fx.get("thickness", 54.0)) * 0.5
	var barrier_requests: Array = feedback.get("barrierHitRequests", []) as Array
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if not _stage2_alive_enemy(enemy):
			continue
		var token := _stage2_entity_token(enemy)
		if bool(hit_ids.get(token, false)):
			continue
		var offset := Vector2(enemy.get("pos", Vector2.ZERO)) - position
		var radius := float(enemy.get("radius", 20.0))
		if absf(offset.dot(direction)) > half_thickness + radius or absf(offset.dot(side)) > half_width + radius:
			continue
		var knockback := 0.0
		if not _is_boss_enemy(enemy) and bool(enemy.get("canBeKnockedBack", true)):
			knockback = float(fx.get("normalKnockbackDistance", 70.0))
			if EnemySystem.is_large_enemy(enemy):
				knockback *= float(fx.get("largeKnockbackRate", 0.60))
		var hit_result := _apply_enemy_hit(enemy, float(fx.get("damage", 0.0)), direction, knockback, killed_enemies, hit_effects, barrier_requests, "moderator_fortress")
		if hit_result != HIT_NONE:
			hit_ids[token] = true
			var hit_duration := _stage2_visual_duration(fx, "hit", 0.19)
			hit_effects.append({"kind": "moderator_fortress_hit", "owner": String(fx.get("owner", "moderator_fortress")), "weaponId": String(fx.get("weaponId", "moderator_fortress")), "pos": Vector2(enemy.get("pos", position)), "dir": direction, "life": hit_duration, "maxLife": hit_duration, "visuals": (fx.get("visuals", {}) as Dictionary).duplicate(true)})
			if hit_result == HIT_DAMAGED:
				_merge_reaction_result(feedback, {"enemyDamaged": true, "weaponCommentKind": "moderator_fortress"})
	fx["hitEnemyIds"] = hit_ids
	var bullet_clears := int(fx.get("bulletClears", 0))
	var max_clears := int(fx.get("maxBulletClears", 8))
	if bullet_clears < max_clears:
		for bullet_item in enemy_bullets:
			if bullet_clears >= max_clears:
				break
			var bullet: Dictionary = bullet_item as Dictionary
			if float(bullet.get("life", 0.0)) <= 0.0 or not _stage2_shield_bullet_clearable(bullet):
				continue
			var bullet_pos := Vector2(bullet.get("pos", Vector2.ZERO))
			var bullet_radius := float(bullet.get("hitRadius", 10.0))
			if absf((bullet_pos - position).dot(direction)) > half_thickness + bullet_radius or absf((bullet_pos - position).dot(side)) > half_width + bullet_radius:
				continue
			bullet["life"] = 0.0
			bullet_clears += 1
			var bullet_break_duration := _stage2_visual_duration(fx, "bulletBreak", 0.18)
			var absorb_duration := _stage2_visual_duration(fx, "absorb", 0.18)
			var bullet_fx_duration := maxf(bullet_break_duration, absorb_duration)
			hit_effects.append({"kind": "moderator_fortress_bullet_clear", "owner": String(fx.get("owner", "moderator_fortress")), "weaponId": String(fx.get("weaponId", "moderator_fortress")), "pos": bullet_pos, "shieldPos": position, "life": bullet_fx_duration, "maxLife": bullet_fx_duration, "visuals": (fx.get("visuals", {}) as Dictionary).duplicate(true)})
	fx["bulletClears"] = bullet_clears
	if age >= duration:
		fx["completionReason"] = "travel_complete"
		if not bool(fx.get("waveSpawned", false)):
			fx["waveSpawned"] = true
			var charge := minf(float(fx.get("shockMaxMultiplier", 2.74)), float(fx.get("shockBaseMultiplier", 1.30)) + float(fx.get("bulletClears", 0)) * float(fx.get("shockChargePerClear", 0.18)))
			var shockwave_duration := _stage2_visual_duration(fx, "shockwave", 0.28)
			var charged_shockwave_duration := _stage2_visual_duration(fx, "shockwaveCharged", shockwave_duration)
			hit_effects.append({"kind": "moderator_fortress_shockwave", "owner": String(fx.get("owner", "moderator_fortress")), "weaponId": "moderator_fortress", "pos": position, "dir": direction, "radius": float(fx.get("shockRadius", 120.0)), "damage": float(fx.get("baseDamage", 10.0)) * charge * float(fx.get("damageRate", 1.0)), "damageMultiplier": charge, "knockback": float(fx.get("normalKnockbackDistance", 70.0)) * float(fx.get("shockKnockbackRatio", 0.35)), "maxBulletClears": int(fx.get("shockBulletClears", 4)), "bulletClears": 0, "absorbed": int(fx.get("bulletClears", 0)), "hitEnemyIds": {}, "life": maxf(shockwave_duration, charged_shockwave_duration), "maxLife": maxf(shockwave_duration, charged_shockwave_duration), "visuals": (fx.get("visuals", {}) as Dictionary).duplicate(true)})
		fx["life"] = 0.0

static func update_moderator_fortress_shockwave_fx(fx: Dictionary, enemies: Array, enemy_bullets: Array, killed_enemies: Array, hit_effects: Array, feedback: Dictionary) -> void:
	var center := Vector2(fx.get("pos", Vector2.ZERO))
	var radius := float(fx.get("radius", 120.0))
	var hit_ids: Dictionary = fx.get("hitEnemyIds", {}) as Dictionary
	var barrier_requests: Array = feedback.get("barrierHitRequests", []) as Array
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if not _stage2_alive_enemy(enemy):
			continue
		var token := _stage2_entity_token(enemy)
		if bool(hit_ids.get(token, false)) or Vector2(enemy.get("pos", Vector2.ZERO)).distance_to(center) > radius + float(enemy.get("radius", 20.0)):
			continue
		var offset := Vector2(enemy.get("pos", Vector2.ZERO)) - center
		var hit_result := _apply_enemy_hit(enemy, float(fx.get("damage", 0.0)), offset.normalized(), float(fx.get("knockback", 0.0)) if not _is_boss_enemy(enemy) else 0.0, killed_enemies, hit_effects, barrier_requests, "moderator_fortress")
		if hit_result != HIT_NONE:
			hit_ids[token] = true
			if hit_result == HIT_DAMAGED:
				_merge_reaction_result(feedback, {"enemyDamaged": true, "weaponCommentKind": "moderator_fortress"})
	fx["hitEnemyIds"] = hit_ids
	var cleared := int(fx.get("bulletClears", 0))
	for bullet_item in enemy_bullets:
		if cleared >= int(fx.get("maxBulletClears", 4)):
			break
		var bullet: Dictionary = bullet_item as Dictionary
		if float(bullet.get("life", 0.0)) <= 0.0 or not _stage2_shield_bullet_clearable(bullet):
			continue
		if Vector2(bullet.get("pos", Vector2.ZERO)).distance_to(center) > radius:
			continue
		bullet["life"] = 0.0
		cleared += 1
		var bullet_break_duration := _stage2_visual_duration(fx, "bulletBreak", 0.18)
		var absorb_duration := _stage2_visual_duration(fx, "absorb", 0.18)
		var bullet_fx_duration := maxf(bullet_break_duration, absorb_duration)
		hit_effects.append({"kind": "moderator_fortress_bullet_clear", "owner": String(fx.get("owner", "moderator_fortress")), "weaponId": String(fx.get("weaponId", "moderator_fortress")), "pos": Vector2(bullet.get("pos", center)), "shieldPos": center, "life": bullet_fx_duration, "maxLife": bullet_fx_duration, "visuals": (fx.get("visuals", {}) as Dictionary).duplicate(true)})
	fx["bulletClears"] = cleared

static func _baton_direction_for_step(step: int, weapon: Dictionary, context: Dictionary) -> Dictionary:
	var player_pos := Vector2(context.get("playerPos", Vector2.ZERO))
	var enemies: Array = context.get("enemies", []) as Array
	var coverage := _stage2_coverage_rate(context)
	var radius := float(weapon.get("finisherRange", 170.0)) * float(weapon.get("finisherRangeMultiplier", 1.0)) if step == 2 else float(weapon.get("normalRange", 110.0)) * float(weapon.get("normalRangeMultiplier", 1.0))
	var arc := float(weapon.get("finisherArcAngle", 70.0)) * float(weapon.get("finisherWidthMultiplier", 1.0)) if step == 2 else float(weapon.get("normalArcAngle", 50.0)) * float(weapon.get("normalWidthMultiplier", 1.0))
	var fallback := Vector2(context.get("facingDir", Vector2.RIGHT)).normalized()
	if fallback.length() < 0.1:
		fallback = Vector2.RIGHT
	var nearest: Dictionary = {}
	var nearest_distance := INF
	var directional_nearest: Dictionary = {}
	var directional_distance := INF
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if not _stage2_alive_enemy(enemy):
			continue
		var offset := Vector2(enemy.get("pos", Vector2.ZERO)) - player_pos
		if offset.length() > radius or offset.length() <= 0.01:
			continue
		if offset.length() < nearest_distance:
			nearest_distance = offset.length()
			nearest = enemy
		if step != 2 and offset.normalized().dot(fallback) >= 0.0 and offset.length() < directional_distance:
			directional_distance = offset.length()
			directional_nearest = enemy
	if nearest.is_empty():
		var nearest_box := _stage2_nearest_box(context.get("destructibles", []) as Array, player_pos, radius)
		if nearest_box.is_empty():
			return {"found": false}
		var box_direction := (Vector2(nearest_box.get("pos", player_pos)) - player_pos).normalized()
		if box_direction.length() < 0.1:
			box_direction = fallback
		return {"found": true, "dir": box_direction, "radius": radius, "arc": arc * coverage}
	if step != 2:
		var selected_normal: Dictionary = directional_nearest if not directional_nearest.is_empty() else nearest
		return {"found": true, "dir": (Vector2(selected_normal.get("pos", player_pos)) - player_pos).normalized(), "radius": radius, "arc": arc * coverage}
	var base_dir := (Vector2(nearest.get("pos", player_pos)) - player_pos).normalized()
	var best_dir := base_dir
	var best_count := -1
	var best_nearest := INF
	for enemy_item in enemies:
		var candidate: Dictionary = enemy_item as Dictionary
		if not _stage2_alive_enemy(candidate):
			continue
		var candidate_offset := Vector2(candidate.get("pos", Vector2.ZERO)) - player_pos
		if candidate_offset.length() > radius or candidate_offset.length() <= 0.01:
			continue
		var candidate_dir := candidate_offset.normalized()
		var count := 0
		var local_nearest := INF
		for other_item in enemies:
			var other: Dictionary = other_item as Dictionary
			if not _stage2_alive_enemy(other):
				continue
			var other_offset := Vector2(other.get("pos", Vector2.ZERO)) - player_pos
			if other_offset.length() <= radius and other_offset.length() > 0.01 and rad_to_deg(absf(candidate_dir.angle_to(other_offset.normalized()))) <= arc * 0.5 * coverage:
				count += 1
				local_nearest = minf(local_nearest, other_offset.length())
		var correction := rad_to_deg(absf(base_dir.angle_to(candidate_dir)))
		if correction > float(weapon.get("maxDirectionCorrectionDegrees", 180.0)):
			continue
		if count > best_count or (count == best_count and local_nearest < best_nearest):
			best_count = count
			best_nearest = local_nearest
			best_dir = candidate_dir
	return {"found": true, "dir": best_dir, "radius": radius, "arc": arc * coverage}

static func _update_fansa_baton_weapon(weapon: Dictionary, entry: Dictionary, context: Dictionary, timers: Dictionary) -> Dictionary:
	var result := _stage2_empty_result()
	var weapon_id := String(weapon.get("id", "fansa_baton"))
	var delta := float(context.get("delta", 0.0))
	var timer := float(timers.get(weapon_id, 0.0)) - delta
	if timer > 0.0:
		timers[weapon_id] = timer
		return result
	if bool(context.get("normalWeaponsDisabled", false)):
		timers[weapon_id] = 0.0
		return result
	var states := _stage2_states(timers)
	var state: Dictionary = states.get(weapon_id, {"comboStep": 0}) as Dictionary
	var step := clampi(int(state.get("comboStep", 0)), 0, 2)
	var selection := _baton_direction_for_step(step, weapon, context)
	if not bool(selection.get("found", false)):
		timers[weapon_id] = _stage2_retry_delay(weapon)
		states[weapon_id] = state
		return result
	var damage_coefficient := float(weapon.get("finisherDamageCoefficient", 1.25)) if step == 2 else float(weapon.get("normalDamageCoefficient", 0.55))
	var damage_multiplier := float(weapon.get("finisherDamageMultiplier", 1.0)) if step == 2 else float(weapon.get("normalDamageMultiplier", 1.0))
	var damage := _stage2_base_damage(weapon) * damage_coefficient * damage_multiplier * float(context.get("damageRate", 1.0))
	var knockback := float(weapon.get("normalKnockback", 0.0))
	if step == 2:
		knockback = float(weapon.get("finisherKnockback", 0.0)) * float(weapon.get("finisherKnockbackMultiplier", 1.0))
	var barrier_requests: Array = result["barrierHitRequests"] as Array
	var killed: Array = result["killed"] as Array
	var hit_effects: Array = result["hitFx"] as Array
	var player_pos := Vector2(context.get("playerPos", Vector2.ZERO))
	var attack_direction := Vector2(selection.get("dir", Vector2.RIGHT))
	var attack_range := float(selection.get("radius", 110.0))
	var attack_arc := float(selection.get("arc", 50.0))
	var enemy_hit_count := _apply_arc_damage(context.get("enemies", []) as Array, player_pos, attack_direction, attack_range, attack_arc, damage, knockback, killed, hit_effects, barrier_requests, weapon_id)
	var box_hit_count := _apply_arc_damage_to_boxes(context.get("destructibles", []) as Array, player_pos, attack_direction, attack_range, attack_arc, result["destroyedBoxes"] as Array, hit_effects)
	var hit_count := enemy_hit_count + box_hit_count
	state["comboStep"] = (step + 1) % 3
	states[weapon_id] = state
	timers[weapon_id] = _stage2_interval(weapon, context, 0.55)
	if enemy_hit_count > 0:
		_merge_reaction_result(result, {"enemyDamaged": true, "weaponCommentKind": weapon_id})
	var hit_role := "swingRight" if step == 0 else ("swingLeft" if step == 1 else "finisher")
	var hit_life := _stage2_visual_duration(weapon, hit_role, 0.24 if step != 2 else 0.34)
	hit_effects.append({"kind": "fansa_baton_hit", "owner": weapon_id, "pos": Vector2(context.get("playerPos", Vector2.ZERO)), "dir": Vector2(selection.get("dir", Vector2.RIGHT)), "comboStep": step, "level": int(weapon.get("level", 1)), "range": float(selection.get("radius", 110.0)), "arcAngle": float(selection.get("arc", 50.0)), "recoveryMultiplier": float(weapon.get("recoveryMultiplier", 1.0)), "count": hit_count, "life": hit_life, "maxLife": hit_life, "visuals": (weapon.get("visuals", {}) as Dictionary).duplicate(true)})
	if step == 2 and bool(weapon.get("crossFollowup", false)):
		var normal_damage := _stage2_base_damage(weapon) * float(weapon.get("normalDamageCoefficient", 0.55)) * float(weapon.get("normalDamageMultiplier", 1.0)) * float(context.get("damageRate", 1.0))
		var cross_range := float(selection.get("radius", 170.0)) * float(weapon.get("crossRangeRatio", 0.85))
		var cross_life := _stage2_visual_duration(weapon, "xSlash", 0.30)
		hit_effects.append({"kind": "fansa_baton_cross_followup", "owner": weapon_id, "pos": Vector2(context.get("playerPos", Vector2.ZERO)), "dir": Vector2(selection.get("dir", Vector2.RIGHT)), "level": int(weapon.get("level", 1)), "range": cross_range, "arcAngle": float(weapon.get("crossArcAngle", 70.0)) * _stage2_coverage_rate(context), "damage": normal_damage, "knockback": 0.0, "delay": float(weapon.get("crossDelay", 0.15)), "life": cross_life, "maxLife": cross_life, "hitEnemyIds": {}, "visuals": (weapon.get("visuals", {}) as Dictionary).duplicate(true)})
	return result

static func _update_fansa_climax_weapon(weapon: Dictionary, context: Dictionary, timers: Dictionary) -> Dictionary:
	var result := _stage2_empty_result()
	var weapon_id := String(weapon.get("id", "fansa_climax"))
	var timer := float(timers.get(weapon_id, 0.0)) - float(context.get("delta", 0.0))
	if timer > 0.0:
		timers[weapon_id] = timer
		return result
	if bool(context.get("normalWeaponsDisabled", false)):
		timers[weapon_id] = 0.0
		return result
	var states := _stage2_states(timers)
	var state: Dictionary = states.get(weapon_id, {"comboStep": 0}) as Dictionary
	var step := clampi(int(state.get("comboStep", 0)), 0, 2)
	var selection := _baton_direction_for_step(step, weapon, context)
	if not bool(selection.get("found", false)):
		timers[weapon_id] = _stage2_retry_delay(weapon)
		states[weapon_id] = state
		return result
	var player_pos := Vector2(context.get("playerPos", Vector2.ZERO))
	var direction := Vector2(selection.get("dir", Vector2.RIGHT)).normalized()
	var attack_range := float(selection.get("radius", 125.0))
	var attack_arc := float(selection.get("arc", 55.0))
	var base_damage := _stage2_base_damage(weapon) * float(context.get("damageRate", 1.0))
	var coefficient := float(weapon.get("finisherDamageCoefficient", 1.40)) if step == 2 else float(weapon.get("normalDamageCoefficient", 0.65))
	var damage := base_damage * coefficient
	var knockback := float(weapon.get("finisherKnockback", 10.0)) if step == 2 else 0.0
	var hit_effects: Array = result["hitFx"] as Array
	var killed: Array = result["killed"] as Array
	var barriers: Array = result["barrierHitRequests"] as Array
	var visuals := weapon.get("visuals", {}) as Dictionary
	var attack_serial := int(state.get("attackSerial", 0)) + 1
	state["attackSerial"] = attack_serial
	var main_spark_role := "finisher" if step == 2 else ("swingRight" if step == 0 else "swingLeft")
	var main_spark_ids: Dictionary = {}
	var main_visual_context := {"attackInstanceId": "%s:%d:main" % [weapon_id, attack_serial], "sparkRole": main_spark_role, "visuals": visuals, "sparkHitIds": main_spark_ids}
	var hits := _apply_arc_damage(context.get("enemies", []) as Array, player_pos, direction, attack_range, attack_arc, damage, knockback, killed, hit_effects, barriers, weapon_id, main_visual_context)
	if hits > 0:
		_merge_reaction_result(result, {"enemyDamaged": true, "weaponCommentKind": weapon_id})
	state["comboStep"] = (step + 1) % 3
	states[weapon_id] = state
	timers[weapon_id] = _stage2_interval(weapon, context, 0.47)
	var main_life := _stage2_visual_duration(weapon, main_spark_role, 0.24 if step < 2 else 0.34)
	hit_effects.append({"kind": "fansa_climax_hit", "owner": weapon_id, "weaponId": weapon_id, "attackInstanceId": "%s:%d:main" % [weapon_id, attack_serial], "pos": player_pos, "dir": direction, "comboStep": step, "range": attack_range, "arcAngle": attack_arc, "count": hits, "life": main_life, "maxLife": main_life, "visuals": visuals.duplicate(true)})
	if step < 2:
		var echo_life := _stage2_visual_duration(weapon, "echo", 0.22)
		hit_effects.append({"kind": "fansa_climax_echo", "owner": weapon_id, "weaponId": weapon_id, "attackInstanceId": "%s:%d:echo" % [weapon_id, attack_serial], "pos": player_pos, "dir": direction, "origin": player_pos, "range": attack_range, "arcAngle": attack_arc, "damage": base_damage * float(weapon.get("echoDamageCoefficient", 0.30)), "delay": float(weapon.get("echoDelay", 0.12)), "hitEnemyIds": {}, "sparkHitIds": {}, "applied": false, "life": echo_life, "maxLife": echo_life, "visuals": visuals.duplicate(true)})
	else:
		var x_life := _stage2_visual_duration(weapon, "xSlash", 0.30)
		var wave_life := _stage2_visual_duration(weapon, "wave", 0.28)
		hit_effects.append({"kind": "fansa_climax_x", "owner": weapon_id, "weaponId": weapon_id, "attackInstanceId": "%s:%d:x" % [weapon_id, attack_serial], "pos": player_pos, "dir": direction, "range": attack_range * 0.85, "arcAngle": attack_arc, "damage": base_damage * float(weapon.get("xDamageCoefficient", 0.80)), "hitEnemyIds": {}, "sparkHitIds": {}, "applied": false, "life": x_life, "maxLife": x_life, "visuals": visuals.duplicate(true)})
		hit_effects.append({"kind": "fansa_climax_fan_wave", "owner": weapon_id, "weaponId": weapon_id, "attackInstanceId": "%s:%d:wave" % [weapon_id, attack_serial], "pos": player_pos, "dir": direction, "radius": float(weapon.get("fanWaveRadius", 105.0)) * _stage2_coverage_rate(context), "damage": base_damage * float(weapon.get("fanWaveDamageCoefficient", 0.35)), "knockback": 3.0, "hitEnemyIds": {}, "sparkHitIds": {}, "applied": false, "life": wave_life, "maxLife": wave_life, "visuals": visuals.duplicate(true)})
	return result

static func _buzz_active_cast(context: Dictionary, weapon: Dictionary) -> bool:
	var active_count := 0
	var weapon_id := String(weapon.get("id", "buzz_thumbnail_rod"))
	for fx_item in (context.get("activeFx", []) as Array):
		var fx: Dictionary = fx_item as Dictionary
		if String(fx.get("kind", "")) == "buzz_thumbnail_rod_cast" and String(fx.get("weaponId", fx.get("owner", ""))) == weapon_id and float(fx.get("life", 0.0)) > 0.0:
			active_count += 1
	return active_count >= int(weapon.get("maxActiveCasts", 1))

static func _append_buzz_visual_fx(hit_effects: Array, kind: String, role: String, pos: Vector2, direction: Vector2, visuals: Dictionary, fallback_duration: float) -> void:
	var config := visuals.get(role, {}) as Dictionary
	var duration := maxf(0.01, float(config.get("durationSeconds", fallback_duration)))
	hit_effects.append({
		"kind": kind,
		"visualRole": role,
		"owner": "buzz_thumbnail_rod",
		"weaponId": "buzz_thumbnail_rod",
		"pos": pos,
		"dir": direction.normalized() if direction.length() > 0.01 else Vector2.RIGHT,
		"life": duration,
		"maxLife": duration,
		"visuals": visuals.duplicate(true)
	})

static func _buzz_select_target(weapon: Dictionary, context: Dictionary) -> Dictionary:
	var selection := _rod_select_target(weapon, context)
	if bool(selection.get("found", false)):
		var target: Dictionary = selection.get("target", {}) as Dictionary
		if not target.is_empty():
			selection["targetType"] = "boss" if _is_boss_enemy(target) else String(selection.get("targetType", "enemy"))
		return selection
	var player_pos := Vector2(context.get("playerPos", Vector2.ZERO))
	var max_range := float(weapon.get("maxCastRange", 380.0))
	var best_boss: Dictionary = {}
	var best_distance := INF
	for enemy_item in (context.get("enemies", []) as Array):
		var enemy: Dictionary = enemy_item as Dictionary
		if not _stage2_alive_enemy(enemy) or not _is_boss_enemy(enemy):
			continue
		var distance := player_pos.distance_to(Vector2(enemy.get("pos", player_pos)))
		if distance <= max_range and distance < best_distance:
			best_boss = enemy
			best_distance = distance
	if best_boss.is_empty():
		return {"found": false}
	return {"found": true, "target": best_boss, "targetType": "boss"}

static func _buzz_previous_state(enemy: Dictionary) -> Dictionary:
	var previous := {}
	for key in ["movementPaused", "attackDisabled", "contactDisabled", "navigationPaused", "damageInvulnerable", "throwing"]:
		if enemy.has(key):
			previous[key] = enemy[key]
	return previous

static func _buzz_begin_throw(fx: Dictionary, enemies: Array) -> void:
	var target := _rod_find_live_target(fx, enemies)
	if bool(fx.get("bossTarget", false)) or (not target.is_empty() and _is_boss_enemy(target)):
		fx["phase"] = "waiting"
		fx["phaseTimer"] = float(fx.get("reelDelay", 0.55))
		return
	var lure_pos := Vector2(fx.get("pos", Vector2.ZERO))
	var candidates: Array = []
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if not _stage2_alive_enemy(enemy) or not EnemySystem.is_collision_pullable_enemy(enemy):
			continue
		if lure_pos.distance_to(Vector2(enemy.get("pos", lure_pos))) > float(fx.get("gatherRadius", 125.0)) * 1.20:
			continue
		candidates.append(enemy)
	candidates.sort_custom(func(a: Dictionary, b: Dictionary):
			var a_distance := lure_pos.distance_to(Vector2(a.get("pos", lure_pos)))
			var b_distance := lure_pos.distance_to(Vector2(b.get("pos", lure_pos)))
			if not is_equal_approx(a_distance, b_distance):
				return a_distance < b_distance
			var a_hp := float(a.get("hp", 0.0))
			var b_hp := float(b.get("hp", 0.0))
			if not is_equal_approx(a_hp, b_hp):
				return a_hp > b_hp
			return _stage2_entity_token(a) < _stage2_entity_token(b))
	var caught: Array = []
	var suspended: Dictionary = fx.get("suspendedTargetStates", {}) as Dictionary
	var caught_references: Array = fx.get("caughtReferences", []) as Array
	var max_caught := mini(int(fx.get("caughtMaxTargets", 3)), candidates.size())
	for index in range(max_caught):
		var enemy: Dictionary = candidates[index] as Dictionary
		var token := _stage2_entity_token(enemy)
		var previous := _buzz_previous_state(enemy)
		suspended[token] = {"enemy": enemy, "previous": previous}
		enemy["movementPaused"] = true
		enemy["attackDisabled"] = true
		enemy["contactDisabled"] = true
		enemy["navigationPaused"] = true
		enemy["damageInvulnerable"] = true
		enemy["throwing"] = true
		var angle := TAU * float(index) / float(maxi(1, max_caught))
		enemy["pos"] = lure_pos + Vector2.RIGHT.rotated(angle) * (18.0 + float(index) * 6.0)
		caught.append(token)
		caught_references.append(enemy)
	fx["caughtReferences"] = caught_references
	fx["suspendedTargetStates"] = suspended
	fx["caughtTokens"] = caught
	fx["phase"] = "throwing" if not caught.is_empty() else "waiting"
	fx["phaseTimer"] = float(fx.get("throwDuration", 0.25)) if not caught.is_empty() else float(fx.get("reelDelay", 0.55))

static func _buzz_restore_targets(fx: Dictionary) -> void:
	_restore_stage2_transient_states(fx)
	fx["suspendedTargetStates"] = {}

static func _buzz_finish_throw(fx: Dictionary, enemies: Array, killed_enemies: Array, hit_effects: Array, feedback: Dictionary) -> void:
	var lure_pos := Vector2(fx.get("pos", Vector2.ZERO))
	var caught_tokens: Array = fx.get("caughtTokens", []) as Array
	var caught_set: Dictionary = {}
	for token_value in caught_tokens:
		caught_set[String(token_value)] = true
	var barrier_requests: Array = feedback.get("barrierHitRequests", []) as Array
	var caught_damage := float(fx.get("caughtDamage", 0.0))
	var visuals := fx.get("visuals", {}) as Dictionary
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		var token := _stage2_entity_token(enemy)
		if not caught_set.has(token) or not _stage2_alive_enemy(enemy):
			continue
		var enemy_pos := Vector2(enemy.get("pos", lure_pos))
		_append_buzz_visual_fx(hit_effects, "buzz_thumbnail_rod_catch_mark", "catchMark", enemy_pos, Vector2(fx.get("dir", Vector2.RIGHT)), visuals, 0.22)
		var hit_result := _apply_enemy_hit(enemy, caught_damage, (enemy_pos - lure_pos).normalized(), 0.0, killed_enemies, hit_effects, barrier_requests, "buzz_thumbnail_rod")
		if hit_result == HIT_DAMAGED:
			_merge_reaction_result(feedback, {"enemyDamaged": true, "weaponCommentKind": "buzz_thumbnail_rod"})
			_append_buzz_visual_fx(hit_effects, "buzz_thumbnail_rod_hit", "hit", enemy_pos, Vector2(fx.get("dir", Vector2.RIGHT)), visuals, 0.18)
		_hit_buzz_explosion(fx, enemy_pos, token, enemies, killed_enemies, hit_effects, feedback)
	_buzz_restore_targets(fx)
	if bool(fx.get("bossTarget", false)):
		var boss := _rod_find_live_target(fx, enemies)
		if not boss.is_empty():
			var boss_pos := Vector2(boss.get("pos", lure_pos))
			_append_buzz_visual_fx(hit_effects, "buzz_thumbnail_rod_catch_mark", "catchMark", boss_pos, Vector2(fx.get("dir", Vector2.RIGHT)), visuals, 0.22)
			var boss_result := _apply_enemy_hit(boss, float(fx.get("bossReelDamage", 0.0)), (boss_pos - lure_pos).normalized(), 0.0, killed_enemies, hit_effects, barrier_requests, "buzz_thumbnail_rod")
			if boss_result == HIT_DAMAGED:
				_merge_reaction_result(feedback, {"enemyDamaged": true, "weaponCommentKind": "buzz_thumbnail_rod"})
				_append_buzz_visual_fx(hit_effects, "buzz_thumbnail_rod_hit", "hit", boss_pos, Vector2(fx.get("dir", Vector2.RIGHT)), visuals, 0.18)
			_hit_buzz_explosion(fx, boss_pos, _stage2_entity_token(boss), enemies, killed_enemies, hit_effects, feedback)
	fx["phase"] = "waiting"
	fx["phaseTimer"] = float(fx.get("reelDelay", 0.55))

static func _hit_buzz_explosion(fx: Dictionary, center: Vector2, excluded_token: String, enemies: Array, killed_enemies: Array, hit_effects: Array, feedback: Dictionary) -> void:
	var explosion_count := int(fx.get("explosionCount", 0))
	var max_explosions := int(fx.get("caughtMaxTargets", 3))
	if explosion_count >= max_explosions:
		return
	var hit_ids: Dictionary = fx.get("explosionHitEnemyIds", {}) as Dictionary
	var radius := float(fx.get("explosionRadius", 78.0))
	var damage := float(fx.get("explosionDamage", 0.0))
	var barrier_requests: Array = feedback.get("barrierHitRequests", []) as Array
	var damaged_any := false
	var visuals := fx.get("visuals", {}) as Dictionary
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if not _stage2_alive_enemy(enemy):
			continue
		var token := _stage2_entity_token(enemy)
		if token == excluded_token or bool(hit_ids.get(token, false)):
			continue
		if Vector2(enemy.get("pos", center)).distance_to(center) > radius + float(enemy.get("radius", 20.0)):
			continue
		var hit_result := _apply_enemy_hit(enemy, damage, (Vector2(enemy.get("pos", center)) - center).normalized(), 0.0, killed_enemies, hit_effects, barrier_requests, "buzz_thumbnail_rod")
		if hit_result != HIT_NONE:
			hit_ids[token] = true
			if hit_result == HIT_DAMAGED:
				damaged_any = true
				_merge_reaction_result(feedback, {"enemyDamaged": true, "weaponCommentKind": "buzz_thumbnail_rod"})
	fx["explosionHitEnemyIds"] = hit_ids
	fx["explosionCount"] = explosion_count + 1
	if damaged_any:
		_append_buzz_visual_fx(hit_effects, "buzz_thumbnail_rod_hit", "hit", center, Vector2(fx.get("dir", Vector2.RIGHT)), visuals, 0.18)
	var explosion_duration := maxf(_stage2_visual_duration(fx, "explosion", 0.30), _stage2_visual_duration(fx, "burstDeco", 0.30))
	hit_effects.append({"kind": "buzz_thumbnail_rod_explosion", "owner": "buzz_thumbnail_rod", "pos": center, "radius": radius, "life": explosion_duration, "maxLife": explosion_duration, "visuals": (fx.get("visuals", {}) as Dictionary).duplicate(true)})

static func _update_buzz_thumbnail_rod_weapon(weapon: Dictionary, context: Dictionary, timers: Dictionary) -> Dictionary:
	var result := _stage2_empty_result()
	var weapon_id := String(weapon.get("id", "buzz_thumbnail_rod"))
	var delta := float(context.get("delta", 0.0))
	var timer := float(timers.get(weapon_id, 0.0)) - delta
	if timer > 0.0:
		timers[weapon_id] = timer
		return result
	if bool(context.get("normalWeaponsDisabled", false)) or _buzz_active_cast(context, weapon):
		timers[weapon_id] = 0.0 if bool(context.get("normalWeaponsDisabled", false)) else _stage2_retry_delay(weapon)
		return result
	var selection := _buzz_select_target(weapon, context)
	if not bool(selection.get("found", false)):
		timers[weapon_id] = _stage2_retry_delay(weapon)
		return result
	var target: Dictionary = selection.get("target", {}) as Dictionary
	var player_pos := Vector2(context.get("playerPos", Vector2.ZERO))
	var target_pos := Vector2(target.get("pos", player_pos))
	var visuals := weapon.get("visuals", {}) as Dictionary
	var coverage := _stage2_coverage_rate(context)
	var base_damage := _stage2_base_damage(weapon) * float(context.get("damageRate", 1.0))
	var fx := {
		"kind": "buzz_thumbnail_rod_cast", "owner": weapon_id, "weaponId": weapon_id, "phase": "casting",
		"pos": player_pos, "previousPos": player_pos, "dir": (target_pos - player_pos).normalized(),
		"targetReference": target, "targetToken": _stage2_entity_token(target), "lastTargetPos": target_pos,
		"bossTarget": String(selection.get("targetType", "enemy")) == "boss", "reelDestination": player_pos, "displayPlayerPos": player_pos,
		"phaseTimer": 0.0, "age": 0.0, "life": 10.0, "maxLife": 10.0, "level": 1,
		"lureSpeed": float(weapon.get("lureSpeed", 950.0)), "reelSpeed": float(weapon.get("reelSpeed", 1500.0)),
		"reelDelay": float(weapon.get("reelDelay", 0.55)), "gatherDuration": float(weapon.get("gatherDuration", 0.80)),
		"gatherRadius": float(weapon.get("gatherRadius", 125.0)) * coverage, "gatherMaxTargets": int(weapon.get("gatherMaxTargets", 10)),
		"caughtMaxTargets": int(weapon.get("caughtMaxTargets", 3)), "throwDuration": float(weapon.get("throwDuration", 0.25)),
		"initialDamage": base_damage * float(weapon.get("initialDamageCoefficient", 0.40)), "caughtDamage": base_damage * float(weapon.get("caughtDamageCoefficient", 1.35)),
		"explosionDamage": base_damage * float(weapon.get("explosionDamageCoefficient", 0.75)), "bossReelDamage": base_damage * float(weapon.get("bossReelCoefficient", 1.60)),
		"explosionRadius": float(weapon.get("explosionRadius", 78.0)) * coverage, "suspendedTargetStates": {}, "caughtTokens": [],
		"caughtReferences": [], "explosionHitEnemyIds": {}, "explosionCount": 0, "visuals": visuals.duplicate(true)
	}
	(result["hitFx"] as Array).append(fx)
	var launch_direction := Vector2(fx.get("dir", Vector2.RIGHT))
	_append_buzz_visual_fx(result["hitFx"] as Array, "buzz_thumbnail_rod_target_mark", "targetMark", target_pos, launch_direction, visuals, 0.35)
	var throw_config := visuals.get("throw", {}) as Dictionary
	var throw_offset := float(throw_config.get("forwardOffset", 28.0))
	_append_buzz_visual_fx(result["hitFx"] as Array, "buzz_thumbnail_rod_throw", "throw", player_pos + launch_direction * throw_offset, launch_direction, visuals, 0.25)
	timers[weapon_id] = _stage2_interval(weapon, context, 3.0)
	return result

static func update_buzz_thumbnail_rod_fx(fx: Dictionary, delta: float, enemies: Array, killed_enemies: Array, hit_effects: Array, feedback: Dictionary, player_pos: Vector2) -> void:
	var phase := String(fx.get("phase", "casting"))
	var position := Vector2(fx.get("pos", Vector2.ZERO))
	fx["displayPlayerPos"] = player_pos
	var target := _rod_find_live_target(fx, enemies)
	if phase == "casting":
		var destination := Vector2(fx.get("lastTargetPos", position))
		if not target.is_empty():
			destination = Vector2(target.get("pos", destination))
			fx["lastTargetPos"] = destination
		var direction := _rod_limited_turn(Vector2(fx.get("dir", Vector2.RIGHT)), destination - position, 7.5 * delta)
		var step := float(fx.get("lureSpeed", 950.0)) * delta
		fx["dir"] = direction
		if position.distance_to(destination) <= maxf(2.0, step):
			fx["pos"] = destination
			var lure_target := _rod_find_live_target(fx, enemies)
			var visuals := fx.get("visuals", {}) as Dictionary
			if not lure_target.is_empty():
				var initial_result := _apply_enemy_hit(lure_target, float(fx.get("initialDamage", 0.0)), (Vector2(lure_target.get("pos", destination)) - destination).normalized(), 0.0, killed_enemies, hit_effects, feedback.get("barrierHitRequests", []) as Array, "buzz_thumbnail_rod")
				if initial_result == HIT_DAMAGED:
					_merge_reaction_result(feedback, {"enemyDamaged": true, "weaponCommentKind": "buzz_thumbnail_rod"})
					_append_buzz_visual_fx(hit_effects, "buzz_thumbnail_rod_hit", "hit", destination, Vector2(fx.get("dir", Vector2.RIGHT)), visuals, 0.18)
			_append_buzz_visual_fx(hit_effects, "buzz_thumbnail_rod_bear_flash", "bearFlash", destination, Vector2(fx.get("dir", Vector2.RIGHT)), visuals, 0.20)
			var gathered := 0
			for gather_item in enemies:
				if gathered >= int(fx.get("gatherMaxTargets", 10)):
					break
				var gather_enemy: Dictionary = gather_item as Dictionary
				if not _stage2_alive_enemy(gather_enemy) or not EnemySystem.is_pullable_small_enemy(gather_enemy):
					continue
				if not lure_target.is_empty() and _stage2_entity_token(gather_enemy) == _stage2_entity_token(lure_target):
					continue
				if Vector2(gather_enemy.get("pos", destination)).distance_to(destination) > float(fx.get("gatherRadius", 125.0)):
					continue
				_rod_apply_pull(gather_enemy, destination, 25.0)
				gathered += 1
			fx["phase"] = "gathering"
			fx["phaseTimer"] = float(fx.get("gatherDuration", 0.80))
			var gather_duration := maxf(_stage2_visual_duration(fx, "zone", float(fx.get("gatherDuration", 0.80))), _stage2_visual_duration(fx, "pull", float(fx.get("gatherDuration", 0.80))))
			hit_effects.append({"kind": "buzz_thumbnail_rod_gather", "owner": "buzz_thumbnail_rod", "pos": destination, "radius": float(fx.get("gatherRadius", 125.0)), "life": gather_duration, "maxLife": gather_duration, "visuals": visuals.duplicate(true)})
		else:
			fx["pos"] = position + direction * step
		return
	if phase == "gathering":
		var gather_timer := float(fx.get("phaseTimer", 0.0)) - delta
		fx["phaseTimer"] = gather_timer
		if gather_timer <= 0.0:
			_buzz_begin_throw(fx, enemies)
		return
	if phase == "throwing":
		var throw_timer := float(fx.get("phaseTimer", 0.0)) - delta
		fx["phaseTimer"] = throw_timer
		if throw_timer <= 0.0:
			_buzz_finish_throw(fx, enemies, killed_enemies, hit_effects, feedback)
		return
	if phase == "waiting":
		var wait_timer := float(fx.get("phaseTimer", 0.0)) - delta
		fx["phaseTimer"] = wait_timer
		if wait_timer <= 0.0:
			fx["phase"] = "reeling"
			fx["reelDestination"] = player_pos
		return
	if phase != "reeling":
		return
	var destination := Vector2(fx.get("reelDestination", player_pos))
	var to_destination := destination - position
	var reel_step := float(fx.get("reelSpeed", 1500.0)) * delta
	fx["pos"] = destination if to_destination.length() <= reel_step else position + to_destination.normalized() * reel_step
	if Vector2(fx.get("pos", position)).distance_to(destination) <= 0.01:
		fx["life"] = 0.0

static func update_fansa_climax_echo_fx(fx: Dictionary, enemies: Array, killed_enemies: Array, hit_effects: Array, feedback: Dictionary) -> void:
	if bool(fx.get("applied", false)):
		return
	fx["applied"] = true
	var origin := Vector2(fx.get("origin", fx.get("pos", Vector2.ZERO)))
	var direction := Vector2(fx.get("dir", Vector2.RIGHT)).normalized()
	var spark_ids: Dictionary = fx.get("sparkHitIds", {}) as Dictionary
	var visual_context := {"attackInstanceId": String(fx.get("attackInstanceId", "fansa_climax:echo")), "sparkRole": "echo", "visuals": fx.get("visuals", {}) as Dictionary, "sparkHitIds": spark_ids}
	var hits := _apply_arc_damage(enemies, origin, direction, float(fx.get("range", 125.0)), float(fx.get("arcAngle", 55.0)), float(fx.get("damage", 0.0)), 0.0, killed_enemies, hit_effects, feedback.get("barrierHitRequests", []) as Array, "fansa_climax", visual_context)
	fx["sparkHitIds"] = spark_ids
	if hits > 0:
		_merge_reaction_result(feedback, {"enemyDamaged": true, "weaponCommentKind": "fansa_climax"})

static func update_fansa_climax_x_fx(fx: Dictionary, enemies: Array, killed_enemies: Array, hit_effects: Array, feedback: Dictionary) -> void:
	if bool(fx.get("applied", false)):
		return
	fx["applied"] = true
	var spark_ids: Dictionary = fx.get("sparkHitIds", {}) as Dictionary
	var visual_context := {"attackInstanceId": String(fx.get("attackInstanceId", "fansa_climax:x")), "sparkRole": "xSlash", "visuals": fx.get("visuals", {}) as Dictionary, "sparkHitIds": spark_ids}
	var hits := _apply_arc_damage(enemies, Vector2(fx.get("pos", Vector2.ZERO)), Vector2(fx.get("dir", Vector2.RIGHT)), float(fx.get("range", 160.0)), float(fx.get("arcAngle", 80.0)), float(fx.get("damage", 0.0)), 0.0, killed_enemies, hit_effects, feedback.get("barrierHitRequests", []) as Array, "fansa_climax", visual_context)
	fx["sparkHitIds"] = spark_ids
	if hits > 0:
		_merge_reaction_result(feedback, {"enemyDamaged": true, "weaponCommentKind": "fansa_climax"})

static func update_fansa_climax_fan_wave_fx(fx: Dictionary, enemies: Array, killed_enemies: Array, hit_effects: Array, feedback: Dictionary) -> void:
	if bool(fx.get("applied", false)):
		return
	fx["applied"] = true
	var center := Vector2(fx.get("pos", Vector2.ZERO))
	var radius := float(fx.get("radius", 105.0))
	var hit_ids: Dictionary = fx.get("hitEnemyIds", {}) as Dictionary
	var spark_ids: Dictionary = fx.get("sparkHitIds", {}) as Dictionary
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if not _stage2_alive_enemy(enemy):
			continue
		var token := _stage2_entity_token(enemy)
		if bool(hit_ids.get(token, false)) or Vector2(enemy.get("pos", Vector2.ZERO)).distance_to(center) > radius + float(enemy.get("radius", 20.0)):
			continue
		var hit_result := _apply_enemy_hit(enemy, float(fx.get("damage", 0.0)), (Vector2(enemy.get("pos", center)) - center).normalized(), float(fx.get("knockback", 0.0)), killed_enemies, hit_effects, feedback.get("barrierHitRequests", []) as Array, "fansa_climax")
		if hit_result != HIT_NONE:
			hit_ids[token] = true
			_append_fansa_climax_spark_fx(hit_effects, enemy, fx.get("visuals", {}) as Dictionary, String(fx.get("attackInstanceId", "fansa_climax:wave")), "wave", spark_ids)
			if hit_result == HIT_DAMAGED:
				_merge_reaction_result(feedback, {"enemyDamaged": true, "weaponCommentKind": "fansa_climax"})
	fx["hitEnemyIds"] = hit_ids
	fx["sparkHitIds"] = spark_ids

static func _rod_active_cast(context: Dictionary, weapon: Dictionary) -> bool:
	var active_count := 0
	for fx_item in (context.get("activeFx", []) as Array):
		var fx: Dictionary = fx_item as Dictionary
		if String(fx.get("kind", "")) == "tsuri_rod_cast" and float(fx.get("life", 0.0)) > 0.0:
			active_count += 1
	return active_count >= int(weapon.get("maxActiveCasts", 1))

static func _rod_select_target(weapon: Dictionary, context: Dictionary) -> Dictionary:
	var player_pos := Vector2(context.get("playerPos", Vector2.ZERO))
	var max_range := float(weapon.get("maxCastRange", 320.0)) * float(weapon.get("castRangeMultiplier", 1.0))
	var gather_radius := float(weapon.get("gatherRadius", 90.0)) * _stage2_coverage_rate(context)
	var enemies: Array = context.get("enemies", []) as Array
	var best_small: Dictionary = {}
	var best_count := -1
	var best_distance := -INF
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if not _stage2_alive_enemy(enemy) or not EnemySystem.is_pullable_small_enemy(enemy):
			continue
		var distance := player_pos.distance_to(Vector2(enemy.get("pos", Vector2.ZERO)))
		if distance > max_range:
			continue
		var nearby_count := 0
		for other_item in enemies:
			var other: Dictionary = other_item as Dictionary
			if other == enemy or not _stage2_alive_enemy(other) or not EnemySystem.is_pullable_small_enemy(other):
				continue
			if Vector2(other.get("pos", Vector2.ZERO)).distance_to(Vector2(enemy.get("pos", Vector2.ZERO))) <= gather_radius:
				nearby_count += 1
		if nearby_count > best_count or (nearby_count == best_count and distance > best_distance):
			best_small = enemy
			best_count = nearby_count
			best_distance = distance
	if not best_small.is_empty():
		return {"found": true, "target": best_small, "targetType": "enemy"}
	var best_large: Dictionary = {}
	var best_large_distance := INF
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if not _stage2_alive_enemy(enemy) or not EnemySystem.is_large_enemy(enemy):
			continue
		var distance := player_pos.distance_to(Vector2(enemy.get("pos", Vector2.ZERO)))
		if distance <= max_range and distance < best_large_distance:
			best_large = enemy
			best_large_distance = distance
	if not best_large.is_empty():
		return {"found": true, "target": best_large, "targetType": "enemy"}
	var nearest_box := _stage2_nearest_box(context.get("destructibles", []) as Array, player_pos, max_range)
	return {"found": not nearest_box.is_empty(), "target": nearest_box, "targetType": "destructible"}

static func _rod_find_live_target(fx: Dictionary, enemies: Array) -> Dictionary:
	var target_token := String(fx.get("targetToken", ""))
	var target_ref: Dictionary = fx.get("targetReference", {}) as Dictionary
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if not _stage2_alive_enemy(enemy) or _stage2_entity_token(enemy) != target_token:
			continue
		if target_ref.is_empty() or String(target_ref.get("spawnToken", "")) == String(enemy.get("spawnToken", "")):
			return enemy
	return {}

static func _rod_apply_pull(enemy: Dictionary, destination: Vector2, distance: float) -> void:
	if not EnemySystem.can_be_pulled(enemy):
		return
	var offset := destination - Vector2(enemy.get("pos", Vector2.ZERO))
	if offset.length() <= 0.01:
		return
	var resistance := clampf(float(enemy.get("pullResistance", 0.0)), 0.0, 1.0)
	var actual_distance := maxf(0.0, distance) * (1.0 - resistance)
	if actual_distance <= 0.0:
		return
	EnemySystem.add_knockback_for_enemy(enemy, offset.normalized(), actual_distance)

static func _rod_land(fx: Dictionary, enemies: Array, destructibles: Array, killed_enemies: Array, destroyed_boxes: Array, hit_effects: Array, feedback: Dictionary) -> void:
	if String(fx.get("phase", "")) != "casting":
		return
	var target := _rod_find_live_target(fx, enemies)
	var lure_pos := Vector2(fx.get("pos", Vector2.ZERO))
	fx["phase"] = "gathering"
	fx["phaseTimer"] = float(fx.get("gatherDuration", 0.22))
	fx["lastTargetPos"] = lure_pos
	if not target.is_empty():
		var target_pos := Vector2(target.get("pos", lure_pos))
		fx["lastTargetPos"] = target_pos
		var initial_result := _apply_enemy_hit(target, float(fx.get("initialDamage", 0.0)), (target_pos - lure_pos).normalized(), 0.0, killed_enemies, hit_effects, feedback.get("barrierHitRequests", []) as Array, "tsuri_thumbnail_rod")
		if initial_result == HIT_DAMAGED:
			_merge_reaction_result(feedback, {"enemyDamaged": true, "weaponCommentKind": "tsuri_thumbnail_rod"})
	var target_box_uid := int(fx.get("targetBoxUid", -1))
	if target_box_uid >= 0:
		for box_item in destructibles:
			var box: Dictionary = box_item as Dictionary
			if not _stage2_alive_box(box) or int(box.get("uid", -1)) != target_box_uid:
				continue
			fx["lastTargetPos"] = Vector2(box.get("pos", lure_pos))
			DestructibleSystemScript.damage_box(box, 1.0, destroyed_boxes, hit_effects)
			break
	var candidates: Array = []
	var gather_radius := float(fx.get("gatherRadius", 90.0))
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if not _stage2_alive_enemy(enemy) or not EnemySystem.is_pullable_small_enemy(enemy):
			continue
		if not target.is_empty() and _stage2_entity_token(enemy) == _stage2_entity_token(target):
			continue
		if Vector2(enemy.get("pos", Vector2.ZERO)).distance_to(lure_pos) <= gather_radius:
			candidates.append(enemy)
	candidates.sort_custom(func(a: Dictionary, b: Dictionary): return Vector2(a.get("pos", Vector2.ZERO)).distance_to(lure_pos) < Vector2(b.get("pos", Vector2.ZERO)).distance_to(lure_pos))
	var max_targets := mini(int(fx.get("gatherMaxTargets", 5)), candidates.size())
	for index in range(max_targets):
		_rod_apply_pull(candidates[index] as Dictionary, lure_pos, float(fx.get("gatherDistance", 25.0)))
	hit_effects.append({"kind": "tsuri_rod_gather", "pos": lure_pos, "radius": gather_radius, "life": float(fx.get("gatherDuration", 0.22)), "maxLife": float(fx.get("gatherDuration", 0.22)), "visuals": (fx.get("visuals", {}) as Dictionary).duplicate(true)})

static func _update_tsuri_rod_weapon(weapon: Dictionary, context: Dictionary, timers: Dictionary) -> Dictionary:
	var result := _stage2_empty_result()
	var weapon_id := String(weapon.get("id", "tsuri_thumbnail_rod"))
	var delta := float(context.get("delta", 0.0))
	var timer := float(timers.get(weapon_id, 0.0)) - delta
	if timer > 0.0:
		timers[weapon_id] = timer
		return result
	if bool(context.get("normalWeaponsDisabled", false)) or _rod_active_cast(context, weapon):
		timers[weapon_id] = 0.0 if bool(context.get("normalWeaponsDisabled", false)) else _stage2_retry_delay(weapon)
		return result
	var selection := _rod_select_target(weapon, context)
	if not bool(selection.get("found", false)):
		timers[weapon_id] = _stage2_retry_delay(weapon)
		return result
	var target: Dictionary = selection.get("target", {}) as Dictionary
	var target_type := String(selection.get("targetType", "enemy"))
	var target_is_box := target_type == "destructible"
	var player_pos := Vector2(context.get("playerPos", Vector2.ZERO))
	var target_pos := Vector2(target.get("pos", player_pos))
	var coverage := _stage2_coverage_rate(context)
	var fx := {
		"kind": "tsuri_rod_cast", "owner": weapon_id, "weaponId": weapon_id, "phase": "casting",
		"pos": player_pos, "previousPos": player_pos, "dir": (target_pos - player_pos).normalized(),
		"targetReference": {} if target_is_box else target, "targetToken": "" if target_is_box else _stage2_entity_token(target),
		"targetBoxUid": int(target.get("uid", -1)) if target_is_box else -1, "lastTargetPos": target_pos,
		"reelDestination": player_pos, "displayPlayerPos": player_pos, "phaseTimer": 0.0, "age": 0.0, "life": 8.0, "maxLife": 8.0,
		"level": int(weapon.get("level", 1)), "lureSpeed": float(weapon.get("lureSpeed", 900.0)) * float(weapon.get("lureSpeedMultiplier", 1.0)), "reelSpeed": float(weapon.get("reelSpeed", 1250.0)) * float(weapon.get("reelSpeedMultiplier", 1.0)),
		"visuals": (weapon.get("visuals", {}) as Dictionary).duplicate(true),
		"reelDelay": float(weapon.get("reelDelay", 0.70)), "gatherDuration": float(weapon.get("gatherDuration", 0.22)),
		"gatherRadius": float(weapon.get("gatherRadius", 90.0)) * coverage, "gatherMaxTargets": int(weapon.get("gatherMaxTargets", 5)),
		"gatherDistance": float(weapon.get("gatherDistance", 25.0)) * float(weapon.get("gatherDistanceMultiplier", 1.0)), "pathWidth": float(weapon.get("pathWidth", 22.0)) * coverage,
		"hookPullDistance": float(weapon.get("hookPullDistance", 45.0)), "minPlayerDistance": float(weapon.get("minPlayerDistance", 110.0)),
		"initialDamage": _stage2_base_damage(weapon) * float(weapon.get("initialDamageCoefficient", 0.30)) * float(weapon.get("initialDamageMultiplier", 1.0)) * float(context.get("damageRate", 1.0)),
		"reelDamage": _stage2_base_damage(weapon) * float(weapon.get("reelDamageCoefficient", 1.10)) * float(weapon.get("reelDamageMultiplier", 1.0)) * float(context.get("damageRate", 1.0)),
		"pathDamage": _stage2_base_damage(weapon) * float(weapon.get("pathCoefficient", 0.65)) * float(context.get("damageRate", 1.0)),
		"pathHitEnemyIds": {}, "pathHitBoxIds": {}, "collisionHitEnemyIds": {}, "collisionEnabled": bool(weapon.get("collisionEnabled", false)), "collisionMaxTargets": int(weapon.get("collisionMaxTargets", 5)), "collisionDamageRatio": float(weapon.get("collisionDamageRatio", 0.60)), "collisionRadius": float(weapon.get("collisionRadius", 24.0)) * coverage, "initialHit": false, "targetDied": false
	}
	(result["hitFx"] as Array).append(fx)
	timers[weapon_id] = _stage2_interval(weapon, context, 3.4)
	return result

static func _weapon_spawn_count(weapon: Dictionary, key: String, level_value: int, support_level: int) -> int:
	var count: int = int(weapon.get(key, 1))
	if level_value >= 5:
		count += 1
	return maxi(1, count + support_level)

static func _direction_with_attack_right_only(base_dir: Vector2, context: Dictionary) -> Vector2:
	var dir: Vector2 = base_dir.normalized()
	if dir.length() < 0.1:
		dir = Vector2.RIGHT
	if bool(context.get("attackRightOnly", false)):
		var right_power: float = float(context.get("attackRightOnlyRate", 1.0))
		var should_force_right: bool = right_power >= 0.95
		if not should_force_right:
			var rng: RandomNumberGenerator = context.get("rng", null) as RandomNumberGenerator
			should_force_right = rng.randf() <= 0.70 if rng != null else right_power > 0.0
		if should_force_right:
			dir = Vector2.RIGHT
	return dir

static func _level_table_float(table: Array, level_value: int, fallback: float) -> float:
	if table.is_empty():
		return fallback
	return float(table[clampi(level_value - 1, 0, table.size() - 1)])

static func _level_table_int(table: Array, level_value: int, fallback: int) -> int:
	if table.is_empty():
		return fallback
	return int(table[clampi(level_value - 1, 0, table.size() - 1)])

static func _kusa_wave_damage_for_level(level_value: int) -> float:
	return _level_table_float(KUSA_WAVE_DAMAGE_BY_LEVEL, level_value, 5.0)

static func _kusa_wave_interval_for_level(level_value: int) -> float:
	return _level_table_float(KUSA_WAVE_INTERVAL_BY_LEVEL, level_value, 1.4)

static func _kusa_wave_size_for_level(level_value: int) -> float:
	return _level_table_float(KUSA_WAVE_SIZE_BY_LEVEL, level_value, 1.0)

static func _kusa_wave_distance_for_level(level_value: int) -> float:
	return _level_table_float(KUSA_WAVE_DISTANCE_BY_LEVEL, level_value, 450.0)

static func _kusa_wave_bounces_for_level(level_value: int) -> int:
	return _level_table_int(KUSA_WAVE_BOUNCES_BY_LEVEL, level_value, 1)

static func _kusa_wave_fire_direction(player_vel: Vector2, facing_dir: Vector2, context: Dictionary) -> Vector2:
	var horizontal: float = 1.0
	if player_vel.x > 18.0:
		horizontal = 1.0
	elif player_vel.x < -18.0:
		horizontal = -1.0
	elif facing_dir.x < -0.1:
		horizontal = -1.0
	if bool(context.get("attackRightOnly", false)) and float(context.get("attackRightOnlyRate", 1.0)) >= 0.95:
		horizontal = 1.0
	return Vector2(horizontal, 1.0).normalized()

static func _kusa_wave_supported_directions(base_dir: Vector2, support_level: int) -> Array:
	var base: Vector2 = base_dir.normalized()
	if base.length() < 0.1:
		base = Vector2(1.0, 1.0).normalized()
	var horizontal: float = 1.0 if base.x >= 0.0 else -1.0
	var directions: Array = [Vector2(horizontal, 1.0).normalized()]
	var extra_count: int = support_level
	if extra_count < 0:
		extra_count = 0
	var pattern: Array = [
		Vector2(-horizontal, 1.0).normalized(),
		Vector2(0.0, 1.0),
		Vector2(horizontal, 0.0),
		Vector2(-horizontal, 0.0),
		Vector2(horizontal, -1.0).normalized(),
		Vector2(-horizontal, -1.0).normalized(),
	]
	for index in range(extra_count):
		var dir: Vector2 = Vector2(pattern[index % pattern.size()]).normalized()
		if index >= pattern.size():
			var cycle: int = int(index / pattern.size())
			var angle_sign: float = 1.0 if cycle % 2 == 1 else -1.0
			dir = dir.rotated(deg_to_rad(8.0 * angle_sign * float(cycle))).normalized()
		directions.append(dir)
	return directions

static func _level_duration(base_duration: float, level_value: int) -> float:
	return base_duration * (1.20 if level_value >= 3 else 1.0)

static func _spread_direction(base_dir: Vector2, index: int, count: int, spread_rad: float) -> Vector2:
	var dir: Vector2 = base_dir.normalized()
	if dir.length() < 0.1:
		dir = Vector2.RIGHT
	if count <= 1:
		return dir
	var offset: float = (float(index) - float(count - 1) * 0.5) * spread_rad
	return dir.rotated(offset).normalized()

static func _is_starlight_superchat(weapon: Dictionary) -> bool:
	return String(weapon.get("id", "")) == "starlight_superchat"

static func _is_maro_comment_ring(weapon: Dictionary) -> bool:
	return String(weapon.get("id", "")) == "maro_comment_ring"

static func _starlight_hit_fx(pos: Vector2, premium: bool = false) -> Dictionary:
	return {
		"kind": "starlight_hit",
		"pos": pos,
		"life": 0.24 if not premium else 0.30,
		"maxLife": 0.24 if not premium else 0.30,
		"premium": premium
	}

static func _starlight_burst_fx(pos: Vector2, radius: float) -> Dictionary:
	return {
		"kind": "starlight_burst",
		"pos": pos,
		"life": 0.38,
		"maxLife": 0.38,
		"radius": radius
	}

static func _starlight_enemy_defeated(enemy: Dictionary) -> bool:
	return float(enemy.get("hp", 0.0)) <= 0.0 or bool(enemy.get("defeatPending", false))

static func _starlight_defeat_tier(enemy: Dictionary) -> int:
	if _is_boss_enemy(enemy):
		return 2
	var radius: float = float(enemy.get("radius", 20.0))
	var max_hp: float = float(enemy.get("max_hp", enemy.get("maxHp", enemy.get("hp", 0.0))))
	if radius >= 42.0 or max_hp >= 90.0:
		return 1
	return 0

static func _starlight_defeat_fx(enemy: Dictionary, premium: bool = false) -> Dictionary:
	var tier: int = _starlight_defeat_tier(enemy)
	var max_life: float = 0.46 + 0.10 * float(tier) + (0.08 if premium else 0.0)
	return {
		"kind": "starlight_defeat",
		"pos": Vector2(enemy.get("pos", Vector2.ZERO)),
		"life": max_life,
		"maxLife": max_life,
		"radius": float(enemy.get("radius", 22.0)),
		"tier": tier,
		"premium": premium
	}

static func _maro_comment_hit_fx(pos: Vector2) -> Dictionary:
	return {
		"kind": "maro_comment_hit",
		"pos": pos,
		"life": 0.26,
		"maxLife": 0.26
	}

static func _maro_comment_pulse_fx(pos: Vector2, radius: float, pulled_exp: int) -> Dictionary:
	return {
		"kind": "maro_comment_pulse",
		"pos": pos,
		"life": 0.36,
		"maxLife": 0.36,
		"radius": radius,
		"pulledExp": pulled_exp
	}

static func _premium_superchat_explosion_radius(weapon: Dictionary, context: Dictionary) -> float:
	var radius_value: float = float(weapon.get("premiumExplosionRadius", 0.85))
	return scaled_range(radius_value) * _short_range_explosion_area_rate(context) * attack_area_rate(context)

static func _apply_starlight_explosion(
	weapon: Dictionary,
	context: Dictionary,
	center: Vector2,
	enemies: Array,
	destructibles: Array,
	killed_enemies: Array,
	destroyed_boxes: Array,
	hit_effects: Array,
	barrier_hit_requests: Array = []
) -> int:
	var radius: float = _premium_superchat_explosion_radius(weapon, context)
	var damage: float = float(weapon.get("premiumExplosionDamage", 7.0))
	var knockback: float = float(context.get("knockback", 0.0)) * 0.28
	var hits: int = _apply_starlight_circle_damage(enemies, center, radius, damage, knockback, killed_enemies, hit_effects, barrier_hit_requests)
	_apply_circle_damage_to_boxes(destructibles, center, radius, destroyed_boxes, hit_effects)
	hit_effects.append(_starlight_burst_fx(center, radius))
	return hits

static func _apply_starlight_circle_damage(enemies: Array, center: Vector2, radius: float, damage: float, knockback: float, killed_enemies: Array, hit_effects: Array, barrier_hit_requests: Array = []) -> int:
	var hits: int = 0
	var radius_sq := radius * radius
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item
		if float(enemy["hp"]) <= 0.0:
			continue
		var enemy_pos: Vector2 = Vector2(enemy["pos"])
		var offset: Vector2 = enemy_pos - center
		var offset_sq := offset.length_squared()
		if offset_sq <= radius_sq:
			var hit_dir := offset / sqrt(offset_sq) if offset_sq > 0.01 else Vector2.RIGHT
			if _apply_enemy_hit(enemy, damage, hit_dir, knockback, killed_enemies, hit_effects, barrier_hit_requests) == HIT_DAMAGED:
				hits += 1
				if _starlight_enemy_defeated(enemy):
					hit_effects.append(_starlight_defeat_fx(enemy, true))
	return hits

static func _maro_pulse_target_radius(weapon: Dictionary) -> float:
	return scaled_range(float(weapon.get("pulseOrbitRadius", 3.1)), 43.0)

static func _maro_pulse_exp_pull_radius(weapon: Dictionary) -> float:
	return scaled_range(float(weapon.get("pulseExpPullRadius", 3.5)), 43.0)

static func _maro_pulse_radius(weapon: Dictionary, base_radius: float) -> float:
	return maxf(base_radius, _maro_pulse_target_radius(weapon))

static func _nudge_exp_orbs_for_maro_pulse(exp_orbs: Array, player_pos: Vector2, radius: float, delta: float) -> int:
	var pulled: int = 0
	var pull_rate: float = minf(0.22, delta * 3.2)
	var radius_sq := radius * radius
	for orb_item in exp_orbs:
		var orb: Dictionary = orb_item as Dictionary
		if float(orb.get("life", 0.0)) <= 0.0:
			continue
		var pos: Vector2 = Vector2(orb.get("pos", Vector2.ZERO))
		var distance_sq: float = pos.distance_squared_to(player_pos)
		if distance_sq <= radius_sq and distance_sq > 324.0:
			orb["pos"] = pos.lerp(player_pos, pull_rate)
			pulled += 1
	return pulled

static func _update_maro_comment_pulse(
	weapon: Dictionary,
	context: Dictionary,
	base_radius: float,
	weapon_timers: Dictionary,
	enemies: Array,
	killed_enemies: Array,
	hit_effects: Array,
	result: Dictionary
) -> void:
	var elapsed: float = float(context["elapsed"])
	var pulse_interval: float = maxf(0.10, float(weapon.get("pulseInterval", 2.0)))
	var pulse_duration: float = maxf(0.05, float(weapon.get("pulseDuration", 0.25)))
	var pulse_index: int = int(floor(elapsed / pulse_interval))
	if not weapon_timers.has(MARO_PULSE_INDEX_KEY):
		weapon_timers[MARO_PULSE_INDEX_KEY] = pulse_index
		weapon_timers[MARO_PULSE_UNTIL_KEY] = 0.0
		return
	var last_pulse_index: int = int(weapon_timers.get(MARO_PULSE_INDEX_KEY, pulse_index))
	if pulse_index <= last_pulse_index:
		return
	weapon_timers[MARO_PULSE_INDEX_KEY] = pulse_index
	weapon_timers[MARO_PULSE_UNTIL_KEY] = elapsed + pulse_duration
	var player_pos: Vector2 = Vector2(context["playerPos"])
	var pulse_radius: float = _maro_pulse_radius(weapon, base_radius)
	var pulse_damage: float = float(weapon.get("pulseDamage", 8.0))
	var hit_count: int = _apply_circle_damage(enemies, player_pos, pulse_radius, pulse_damage, float(context["knockback"]) * 0.20, killed_enemies, hit_effects, result["barrierHitRequests"] as Array)
	var pulled_exp: int = _nudge_exp_orbs_for_maro_pulse(context.get("expOrbs", []) as Array, player_pos, _maro_pulse_exp_pull_radius(weapon), float(context["delta"]))
	_request_weapon_hit_reaction(result, weapon, hit_count, hit_count)
	hit_effects.append(_maro_comment_pulse_fx(player_pos, pulse_radius, pulled_exp))

static func _starlight_bullet_data(weapon: Dictionary, pos: Vector2, dir: Vector2, speed: float, life: float, base_damage: float, shot_index: int, projectile_count: int, weapon_timers: Dictionary) -> Dictionary:
	var is_center_shot: bool = shot_index == int(float(projectile_count - 1) * 0.5)
	var shot_count: int = int(weapon_timers.get(STARLIGHT_SHOT_COUNTER_KEY, 0))
	var premium_every: int = maxi(1, int(weapon.get("premiumEvery", 5)))
	var is_premium: bool = is_center_shot and shot_count > 0 and shot_count % premium_every == 0
	var damage: float = float(weapon.get("premiumDamage", 14.0)) if is_premium else base_damage
	var hit_radius: float = 11.0 if is_premium else 7.0
	var bullet := {
		"pos": pos,
		"vel": dir * speed,
		"life": life,
		"damage": damage,
		"visualKind": "high_superchat" if is_premium else "starlight_superchat",
		"hitRadius": hit_radius,
		"shotIndex": shot_index,
		"projectileCount": projectile_count,
		"centerShot": is_center_shot,
		"starlightSeed": float((shot_count * 19 + shot_index * 31) % 97) / 97.0,
		"hitIds": []
	}
	if is_premium:
		bullet["premium"] = true
		bullet["pierceLeft"] = maxi(0, int(weapon.get("premiumPierce", 1)))
	return bullet

static func _entity_uid(prefix: String, item: Dictionary) -> String:
	return "%s_%s_%d" % [prefix, String(item.get("kind", "")), int(item.get("uid", 0))]

static func _nearest_enemy_excluding(enemies: Array, origin: Vector2, max_range: float, used_ids: Array) -> Variant:
	var best: Variant = null
	var best_distance: float = max_range * max_range
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if float(enemy.get("hp", 0.0)) <= 0.0:
			continue
		var uid: String = _entity_uid("enemy", enemy)
		if used_ids.has(uid):
			continue
		var distance: float = Vector2(enemy["pos"]).distance_squared_to(origin)
		if distance < best_distance:
			best_distance = distance
			best = enemy
	return best

static func _active_fx_count(active_fx: Array, pending_fx: Array, kind: String, owner: String) -> int:
	var count: int = 0
	for list_item in [active_fx, pending_fx]:
		var fx_list: Array = list_item as Array
		for fx_item in fx_list:
			var fx: Dictionary = fx_item as Dictionary
			if String(fx.get("kind", "")) == kind and String(fx.get("owner", "")) == owner and float(fx.get("life", 0.0)) > 0.0:
				count += 1
	return count

static func _spawn_comment_pin_projectiles(weapon: Dictionary, level_value: int, support_level: int, player_pos: Vector2, facing_dir: Vector2, enemies: Array, range_value: float, damage: float, hit_effects: Array, area_rate: float = 1.0) -> void:
	var count: int = _weapon_spawn_count(weapon, "projectileCount", level_value, support_level)
	var speed: float = scaled_projectile_speed(float(weapon.get("projectileSpeed", 7.2)))
	var slow_duration: float = _level_duration(float(weapon.get("slowDuration", 2.0)), level_value)
	var used_ids: Array = []
	for i in range(count):
		var target: Variant = _nearest_enemy_excluding(enemies, player_pos, range_value, used_ids)
		var dir: Vector2 = _spread_direction(facing_dir, i, count, deg_to_rad(13.0))
		if target != null:
			var target_enemy: Dictionary = target as Dictionary
			used_ids.append(_entity_uid("enemy", target_enemy))
			dir = (Vector2(target_enemy["pos"]) - player_pos).normalized()
			if dir.length() < 0.1:
				dir = _spread_direction(facing_dir, i, count, deg_to_rad(13.0))
		var life: float = range_value / maxf(1.0, speed)
		hit_effects.append({
			"kind": "comment_pin",
			"owner": String(weapon.get("id", "comment_pin")),
			"pos": player_pos + dir * 24.0,
			"dir": dir,
			"vel": dir * speed,
			"life": life,
			"maxLife": life,
			"damage": damage,
			"slowRate": float(weapon.get("slowRate", 0.4)),
			"slowDuration": slow_duration,
			"hitRadius": 12.0 * area_rate,
			"knockback": scaled_knockback(float(weapon.get("knockback", 0.15)))
		})

static func _spawn_emote_mines(weapon: Dictionary, level_value: int, support_level: int, player_pos: Vector2, active_fx: Array, hit_effects: Array, damage: float, range_rate: float) -> void:
	var count: int = _weapon_spawn_count(weapon, "mineCount", level_value, support_level)
	var max_active: int = int(weapon.get("maxActiveCount", 3)) + support_level
	var active_count: int = _active_fx_count(active_fx, hit_effects, "emote_mine", String(weapon.get("id", "emote_mine")))
	var duration: float = _level_duration(float(weapon.get("duration", 8.0)), level_value)
	var radius: float = scaled_range(float(weapon.get("explosionRadius", 1.5))) * range_rate * (1.12 if level_value >= 3 else 1.0)
	radius = maxf(radius, SHORT_RANGE_MIN_AREA_RADIUS)
	for i in range(count):
		if active_count >= max_active:
			return
		var angle: float = TAU * float(i) / float(maxi(1, count))
		var offset: Vector2 = Vector2.RIGHT.rotated(angle) * (18.0 if count > 1 else 0.0)
		hit_effects.append({
			"kind": "emote_mine",
			"owner": String(weapon.get("id", "emote_mine")),
			"pos": player_pos + offset,
			"life": duration,
			"maxLife": duration,
			"damage": damage,
			"radius": radius,
			"triggerRadius": 28.0,
			"knockback": scaled_knockback(float(weapon.get("knockback", 0.2))),
			"screenShakePower": float(weapon.get("screenShakePower", 0.0)),
			"screenShakeDuration": float(weapon.get("screenShakeDuration", 0.15)),
			"hitStop": float(weapon.get("hitStop", 0.0))
		})
		active_count += 1

static func _laser_hit(enemy_pos: Vector2, enemy_radius: float, start: Vector2, dir: Vector2, length: float, half_width: float) -> bool:
	var to_enemy: Vector2 = enemy_pos - start
	var along: float = to_enemy.dot(dir)
	if along < 0.0 or along > length:
		return false
	var hit_width: float = half_width + enemy_radius
	return (to_enemy - dir * along).length_squared() <= hit_width * hit_width

static func _apply_laser_damage(enemies: Array, destructibles: Array, enemy_bullets: Array, start: Vector2, dir: Vector2, length: float, width: float, damage: float, knockback: float, killed_enemies: Array, destroyed_boxes: Array, hit_effects: Array, barrier_hit_requests: Array = []) -> int:
	var hits: int = 0
	var half_width: float = width * 0.5
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if float(enemy.get("hp", 0.0)) <= 0.0:
			continue
		var enemy_pos: Vector2 = Vector2(enemy["pos"])
		if not _laser_hit(enemy_pos, float(enemy.get("radius", 20.0)), start, dir, length, half_width):
			continue
		if _apply_enemy_hit(enemy, damage, dir, knockback * 0.55, killed_enemies, hit_effects, barrier_hit_requests) == HIT_DAMAGED:
			hits += 1
	for box_item in destructibles:
		var box: Dictionary = box_item as Dictionary
		if float(box.get("hp", 0.0)) <= 0.0:
			continue
		if _laser_hit(Vector2(box["pos"]), float(box.get("radius", 24.0)), start, dir, length, half_width):
			DestructibleSystemScript.damage_box(box, 1.0, destroyed_boxes, hit_effects)
			hits += 1
	for bullet_item in enemy_bullets:
		var bullet: Dictionary = bullet_item as Dictionary
		if float(bullet.get("life", 0.0)) <= 0.0:
			continue
		if _laser_hit(Vector2(bullet["pos"]), float(bullet.get("hitRadius", 16.0)), start, dir, length, half_width):
			bullet["life"] = -1.0
			hit_effects.append(_bullet_pop_fx(Vector2(bullet["pos"])))
			hits += 1
	return hits

static func _fire_ng_word_lasers(weapon: Dictionary, level_value: int, support_level: int, player_pos: Vector2, facing_dir: Vector2, enemies: Array, destructibles: Array, enemy_bullets: Array, range_value: float, damage: float, range_rate: float, knockback: float, killed_enemies: Array, destroyed_boxes: Array, hit_effects: Array, barrier_hit_requests: Array = []) -> int:
	var count: int = _weapon_spawn_count(weapon, "laserCount", level_value, support_level)
	var duration: float = maxf(0.08, float(weapon.get("duration", 0.25)))
	var width: float = scaled_range(float(weapon.get("width", 0.6))) * range_rate * (1.12 if level_value >= 5 else 1.0)
	var total_hits := 0
	for i in range(count):
		var dir: Vector2 = _spread_direction(facing_dir, i, count, deg_to_rad(18.0))
		var start: Vector2 = player_pos + dir * 28.0
		var hits: int = _apply_laser_damage(enemies, destructibles, enemy_bullets, start, dir, range_value, width, damage, knockback, killed_enemies, destroyed_boxes, hit_effects, barrier_hit_requests)
		total_hits += hits
		hit_effects.append({
			"kind": "ng_word_laser",
			"owner": String(weapon.get("id", "ng_word_laser")),
			"pos": start,
			"dir": dir,
			"life": duration,
			"maxLife": duration,
			"range": range_value,
			"width": width,
			"hit": start + dir * range_value,
			"count": hits
		})
	return total_hits

static func _spawn_listener_summons(weapon: Dictionary, level_value: int, support_level: int, player_pos: Vector2, facing_dir: Vector2, active_fx: Array, hit_effects: Array, damage: float, range_rate: float, knockback: float, area_rate: float = 1.0) -> void:
	var count: int = _weapon_spawn_count(weapon, "summonCount", level_value, support_level)
	var max_active: int = int(weapon.get("maxActiveCount", 3)) + support_level
	var active_count: int = _active_fx_count(active_fx, hit_effects, "listener_summon", String(weapon.get("id", "listener_summon")))
	var duration: float = _level_duration(float(weapon.get("duration", 6.0)), level_value)
	var speed: float = scaled_move_speed(float(weapon.get("moveSpeed", 3.5)))
	var search_range: float = scaled_range(float(weapon.get("searchRange", weapon.get("range", 7.0)))) * range_rate * (1.10 if level_value >= 3 else 1.0)
	search_range = maxf(search_range, SHORT_RANGE_MIN_SEARCH_RANGE)
	for i in range(count):
		if active_count >= max_active:
			return
		var dir: Vector2 = _spread_direction(facing_dir, i, count, deg_to_rad(28.0))
		hit_effects.append({
			"kind": "listener_summon",
			"owner": String(weapon.get("id", "listener_summon")),
			"pos": player_pos + dir * 32.0,
			"dir": dir,
			"life": duration,
			"maxLife": duration,
			"damage": damage,
			"moveSpeed": speed,
			"searchRange": search_range,
			"hitRadius": 18.0 * area_rate,
			"hitCooldown": 0.70,
			"hitTimer": 0.0,
			"knockback": knockback
		})
		active_count += 1

static func _apply_circle_damage(enemies: Array, center: Vector2, radius: float, damage: float, knockback: float, killed_enemies: Array, hit_effects: Array, barrier_hit_requests: Array = []) -> int:
	var hits: int = 0
	var radius_sq := radius * radius
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item
		if float(enemy["hp"]) <= 0.0:
			continue
		var enemy_pos: Vector2 = Vector2(enemy["pos"])
		var offset: Vector2 = enemy_pos - center
		var offset_sq := offset.length_squared()
		if offset_sq <= radius_sq:
			var hit_dir := offset / sqrt(offset_sq) if offset_sq > 0.01 else Vector2.RIGHT
			if _apply_enemy_hit(enemy, damage, hit_dir, knockback, killed_enemies, hit_effects, barrier_hit_requests) == HIT_DAMAGED:
				hits += 1
	return hits

static func _apply_circle_damage_to_boxes(destructibles: Array, center: Vector2, radius: float, destroyed_boxes: Array, hit_effects: Array) -> void:
	for box_item in destructibles:
		var box: Dictionary = box_item as Dictionary
		if float(box.get("hp", 0.0)) <= 0.0:
			continue
		var box_radius: float = radius + float(box.get("radius", 24.0))
		if center.distance_squared_to(Vector2(box["pos"])) <= box_radius * box_radius:
			DestructibleSystemScript.damage_box(box, 1.0, destroyed_boxes, hit_effects)

static func _append_fansa_climax_spark_fx(hit_effects: Array, enemy: Dictionary, visuals: Dictionary, attack_instance_id: String, spark_role: String, spark_hit_ids: Dictionary) -> void:
	var spark := visuals.get("spark", {}) as Dictionary
	if spark.is_empty():
		return
	var enemy_token := _stage2_entity_token(enemy)
	var dedupe_key := attack_instance_id + "|" + enemy_token
	if bool(spark_hit_ids.get(dedupe_key, false)):
		return
	spark_hit_ids[dedupe_key] = true
	var duration := maxf(0.01, float(spark.get("durationSeconds", 0.18)))
	var role_config := visuals.get(spark_role, {}) as Dictionary
	hit_effects.append({
		"kind": "fansa_climax_spark",
		"owner": "fansa_climax",
		"weaponId": "fansa_climax",
		"attackInstanceId": attack_instance_id,
		"enemyInstanceId": enemy_token,
		"sparkRole": spark_role,
		"sparkMultiplier": float(role_config.get("sparkMultiplier", 1.0)),
		"pos": Vector2(enemy.get("pos", Vector2.ZERO)),
		"life": duration,
		"maxLife": duration,
		"visuals": visuals.duplicate(true)
	})

static func _apply_arc_damage(enemies: Array, origin: Vector2, dir: Vector2, radius: float, arc_angle: float, damage: float, knockback: float, killed_enemies: Array, hit_effects: Array, barrier_hit_requests: Array = [], hit_source: String = "", visual_context: Dictionary = {}) -> int:
	var dot_threshold: float = cos(deg_to_rad(arc_angle * 0.5))
	var radius_sq := radius * radius
	var hits: int = 0
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item
		if float(enemy["hp"]) <= 0.0:
			continue
		var enemy_pos: Vector2 = Vector2(enemy["pos"])
		var to_enemy: Vector2 = enemy_pos - origin
		var dist_sq := to_enemy.length_squared()
		if dist_sq <= 0.01 or dist_sq > radius_sq:
			continue
		var to_enemy_dir := to_enemy / sqrt(dist_sq)
		if dir.dot(to_enemy_dir) >= dot_threshold:
			# Keep the existing arc-damage hit path unchanged; visual_context only adds
			# a non-authoritative spark after the same result is returned.
			var hit_result := _apply_enemy_hit(enemy, damage, to_enemy_dir, knockback, killed_enemies, hit_effects, barrier_hit_requests)
			if hit_result != HIT_NONE and not visual_context.is_empty():
				_append_fansa_climax_spark_fx(hit_effects, enemy, visual_context.get("visuals", {}) as Dictionary, String(visual_context.get("attackInstanceId", "fansa_climax")), String(visual_context.get("sparkRole", "spark")), visual_context.get("sparkHitIds", {}) as Dictionary)
			if hit_result == HIT_DAMAGED:
				hits += 1
	return hits

static func _apply_arc_damage_to_boxes(destructibles: Array, origin: Vector2, dir: Vector2, radius: float, arc_angle: float, destroyed_boxes: Array, hit_effects: Array) -> int:
	var dot_threshold: float = cos(deg_to_rad(arc_angle * 0.5))
	var hits: int = 0
	for box_item in destructibles:
		var box: Dictionary = box_item as Dictionary
		if float(box.get("hp", 0.0)) <= 0.0:
			continue
		var box_pos: Vector2 = Vector2(box["pos"])
		var to_box: Vector2 = box_pos - origin
		var box_hit_radius: float = radius + float(box.get("radius", 24.0)) * 0.55 + 10.0
		var dist_sq := to_box.length_squared()
		if dist_sq <= 0.01 or dist_sq > box_hit_radius * box_hit_radius:
			continue
		if dir.dot(to_box / sqrt(dist_sq)) >= dot_threshold:
			DestructibleSystemScript.damage_box(box, 1.0, destroyed_boxes, hit_effects)
			hits += 1
	return hits

static func _tick_kusa_wave_hit_cooldowns(fx: Dictionary, delta: float) -> Dictionary:
	var source: Dictionary = fx.get("hitCooldowns", {}) as Dictionary
	var result: Dictionary = {}
	for key in source.keys():
		var remaining: float = float(source[key]) - delta
		if remaining > 0.0:
			result[key] = remaining
	fx["hitCooldowns"] = result
	return result

static func _kusa_wave_collision_radius(fx: Dictionary) -> float:
	return float(fx.get("hitRadius", 18.0))

static func _kusa_wave_rect_normal(from_pos: Vector2, to_pos: Vector2, rect: Rect2) -> Vector2:
	if from_pos.x <= rect.position.x:
		return Vector2.LEFT
	if from_pos.x >= rect.end.x:
		return Vector2.RIGHT
	if from_pos.y <= rect.position.y:
		return Vector2.UP
	if from_pos.y >= rect.end.y:
		return Vector2.DOWN
	var left_distance: float = absf(to_pos.x - rect.position.x)
	var right_distance: float = absf(to_pos.x - rect.end.x)
	var top_distance: float = absf(to_pos.y - rect.position.y)
	var bottom_distance: float = absf(to_pos.y - rect.end.y)
	var min_distance: float = minf(minf(left_distance, right_distance), minf(top_distance, bottom_distance))
	if min_distance == left_distance:
		return Vector2.LEFT
	if min_distance == right_distance:
		return Vector2.RIGHT
	if min_distance == top_distance:
		return Vector2.UP
	return Vector2.DOWN

static func _kusa_wave_wall_collision(from_pos: Vector2, to_pos: Vector2, radius: float, walls: Array) -> Dictionary:
	for wall_item in walls:
		if not (wall_item is Rect2):
			continue
		var wall: Rect2 = wall_item
		var grown: Rect2 = wall.grow(radius)
		if EnemySystem.segment_intersects_rect(from_pos, to_pos, grown):
			var normal: Vector2 = _kusa_wave_rect_normal(from_pos, to_pos, grown)
			return {"hit": true, "normal": normal, "pos": to_pos}
	return {"hit": false}

static func _kusa_wave_arena_collision(from_pos: Vector2, to_pos: Vector2, radius: float, arena: Rect2) -> Dictionary:
	if arena.size.x <= 0.0 or arena.size.y <= 0.0:
		return {"hit": false}
	var normal: Vector2 = Vector2.ZERO
	var resolved: Vector2 = to_pos
	if to_pos.x < arena.position.x + radius:
		normal = Vector2.RIGHT
		resolved.x = arena.position.x + radius
	elif to_pos.x > arena.end.x - radius:
		normal = Vector2.LEFT
		resolved.x = arena.end.x - radius
	if to_pos.y < arena.position.y + radius:
		normal = Vector2.DOWN
		resolved.y = arena.position.y + radius
	elif to_pos.y > arena.end.y - radius:
		normal = Vector2.UP
		resolved.y = arena.end.y - radius
	if normal.length() < 0.1:
		return {"hit": false}
	if from_pos.distance_to(resolved) > from_pos.distance_to(to_pos) + radius:
		resolved = to_pos
	return {"hit": true, "normal": normal.normalized(), "pos": resolved}

static func _kusa_wave_reflect_velocity(velocity: Vector2, normal: Vector2) -> Vector2:
	var n: Vector2 = normal.normalized()
	if n.length() < 0.1:
		return -velocity
	return velocity - n * (2.0 * velocity.dot(n))

static func _kusa_wave_bounce_fx(pos: Vector2, dir: Vector2, size_scale: float, area_rate: float = 1.0, depleted: bool = false) -> Dictionary:
	return {
		"kind": "kusa_wave_bounce",
		"pos": pos,
		"dir": dir.normalized() if dir.length() > 0.1 else Vector2.RIGHT,
		"life": 0.22 if not depleted else 0.18,
		"maxLife": 0.22 if not depleted else 0.18,
		"sizeScale": size_scale,
		"attackAreaRate": area_rate,
		"depleted": depleted
	}

static func _kusa_wave_reflect_or_finish(fx: Dictionary, normal: Vector2, collision_pos: Vector2, hit_effects: Array, depleted: bool = false) -> bool:
	var bounces_left: int = int(fx.get("bouncesLeft", 0))
	var size_scale: float = float(fx.get("sizeScale", 1.0))
	var area_rate: float = attack_area_rate(fx)
	var velocity: Vector2 = Vector2(fx.get("vel", Vector2.RIGHT * KUSA_WAVE_SPEED))
	if bounces_left <= 0 or depleted:
		fx["pos"] = collision_pos
		fx["life"] = 0.0
		hit_effects.append(_kusa_wave_bounce_fx(collision_pos, Vector2(fx.get("dir", Vector2.RIGHT)), size_scale, area_rate, true))
		return false
	var reflected: Vector2 = _kusa_wave_reflect_velocity(velocity, normal)
	if reflected.length() < 0.1:
		reflected = -velocity
	var reflected_dir: Vector2 = reflected.normalized()
	fx["bouncesLeft"] = bounces_left - 1
	fx["vel"] = reflected_dir * maxf(KUSA_WAVE_SPEED * 0.55, velocity.length())
	fx["dir"] = reflected_dir
	fx["pos"] = collision_pos + reflected_dir * (4.0 + 2.0 * size_scale)
	hit_effects.append(_kusa_wave_bounce_fx(collision_pos, reflected_dir, size_scale, area_rate, false))
	return true

static func update_kusa_wave_damage(fx: Dictionary, delta: float, enemies: Array, destructibles: Array, _enemy_bullets: Array, killed_enemies: Array, destroyed_boxes: Array, hit_effects: Array, feedback: Dictionary = {}, arena: Rect2 = Rect2(), walls: Array = []) -> void:
	var barrier_hit_requests: Array = feedback.get("barrierHitRequests", []) as Array
	var pos: Vector2 = Vector2(fx.get("pos", Vector2.ZERO))
	var velocity: Vector2 = Vector2(fx.get("vel", Vector2.RIGHT * KUSA_WAVE_SPEED))
	if velocity.length() < 0.1:
		velocity = Vector2.RIGHT * KUSA_WAVE_SPEED
	var dir: Vector2 = velocity.normalized()
	fx["dir"] = dir
	var hit_radius: float = _kusa_wave_collision_radius(fx)
	var move: Vector2 = velocity * delta
	var next_pos: Vector2 = pos + move
	var distance_traveled: float = float(fx.get("distanceTraveled", 0.0)) + move.length()
	fx["distanceTraveled"] = distance_traveled
	if distance_traveled >= float(fx.get("maxDistance", fx.get("range", 450.0))):
		fx["pos"] = next_pos
		fx["life"] = 0.0
		return
	var arena_hit: Dictionary = _kusa_wave_arena_collision(pos, next_pos, hit_radius, arena)
	if bool(arena_hit.get("hit", false)):
		_kusa_wave_reflect_or_finish(fx, arena_hit["normal"] as Vector2, arena_hit["pos"] as Vector2, hit_effects)
		return
	var wall_hit: Dictionary = _kusa_wave_wall_collision(pos, next_pos, hit_radius, walls)
	if bool(wall_hit.get("hit", false)):
		_kusa_wave_reflect_or_finish(fx, wall_hit["normal"] as Vector2, wall_hit["pos"] as Vector2, hit_effects)
		return
	pos = next_pos
	fx["pos"] = pos
	var cooldowns: Dictionary = _tick_kusa_wave_hit_cooldowns(fx, delta)
	var damage: float = float(fx.get("damage", 0.0))
	var knockback: float = float(fx.get("knockback", 0.0))
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if float(enemy.get("hp", 0.0)) <= 0.0:
			continue
		var target_id: String = _attack_target_id("enemy", enemy)
		if float(cooldowns.get(target_id, 0.0)) > 0.0:
			continue
		var enemy_pos: Vector2 = Vector2(enemy["pos"])
		var enemy_hit_radius: float = float(enemy.get("radius", 20.0)) + hit_radius
		if pos.distance_squared_to(enemy_pos) > enemy_hit_radius * enemy_hit_radius:
			continue
		if _apply_enemy_hit(enemy, damage, dir, knockback, killed_enemies, hit_effects, barrier_hit_requests) == HIT_DAMAGED:
			cooldowns[target_id] = KUSA_WAVE_HIT_COOLDOWN
			fx["hitCooldowns"] = cooldowns
			_merge_reaction_result(feedback, {
				"enemyDamaged": true,
				"screenShakePower": float(fx.get("screenShakePower", 0.0)),
				"screenShakeDuration": float(fx.get("screenShakeDuration", 0.10)),
				"hitStop": float(fx.get("hitStop", 0.0)),
				"weaponCommentKind": "kusa_wave"
			})
	for box_item in destructibles:
		var box: Dictionary = box_item as Dictionary
		if float(box.get("hp", 0.0)) <= 0.0:
			continue
		var target_id: String = _attack_target_id("box", box)
		if float(cooldowns.get(target_id, 0.0)) > 0.0:
			continue
		var box_pos: Vector2 = Vector2(box["pos"])
		var box_hit_radius: float = float(box.get("radius", 24.0)) + hit_radius
		if pos.distance_squared_to(box_pos) > box_hit_radius * box_hit_radius:
			continue
		DestructibleSystemScript.damage_box(box, 1.0, destroyed_boxes, hit_effects)
		cooldowns[target_id] = KUSA_WAVE_HIT_COOLDOWN
		fx["hitCooldowns"] = cooldowns
	fx["hitCooldowns"] = cooldowns

static func update_ban_judgement_shockwave_damage(fx: Dictionary, enemies: Array, destructibles: Array, killed_enemies: Array, destroyed_boxes: Array, hit_effects: Array, feedback: Dictionary = {}) -> void:
	var pos: Vector2 = Vector2(fx["pos"])
	var dir: Vector2 = Vector2(fx.get("dir", Vector2.RIGHT)).normalized()
	if dir.length() < 0.1:
		dir = Vector2.RIGHT
	var range_value: float = float(fx.get("range", 450.0))
	var width_value: float = float(fx.get("width", 96.0))
	var damage: float = float(fx.get("damage", 0.0))
	var knockback: float = float(fx.get("knockback", 0.0))
	var stun_duration: float = float(fx.get("stunDuration", BAN_JUDGEMENT_STUN_DURATION))
	var heavy_stun_duration: float = float(fx.get("heavyStunDuration", BAN_JUDGEMENT_HEAVY_STUN_DURATION))
	var hit_ids: Array = fx.get("hitIds", []) as Array
	var barrier_hit_requests: Array = feedback.get("barrierHitRequests", []) as Array
	var hit_count: int = 0
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if float(enemy.get("hp", 0.0)) <= 0.0:
			continue
		var target_id: String = _attack_target_id("enemy", enemy)
		if hit_ids.has(target_id):
			continue
		var enemy_pos: Vector2 = Vector2(enemy["pos"])
		if not _is_forward_shockwave_hit(pos, dir, range_value, width_value, enemy_pos, float(enemy.get("radius", 20.0))):
			continue
		var hit_result := _apply_ban_judgement_enemy_hit(enemy, damage, dir, knockback, stun_duration, heavy_stun_duration, killed_enemies, hit_effects, barrier_hit_requests)
		if hit_result != HIT_NONE:
			hit_ids.append(target_id)
			if hit_result == HIT_DAMAGED:
				hit_count += 1
	if hit_count > 0:
		_merge_reaction_result(feedback, {
			"enemyDamaged": true,
			"screenShakePower": float(fx.get("screenShakePower", 0.0)),
			"screenShakeDuration": float(fx.get("screenShakeDuration", 0.10)),
			"hitStop": float(fx.get("hitStop", 0.0)),
			"weaponCommentKind": "ban_judgement"
		})
	for box_item in destructibles:
		var box: Dictionary = box_item as Dictionary
		if float(box.get("hp", 0.0)) <= 0.0:
			continue
		var target_id: String = _attack_target_id("box", box)
		if hit_ids.has(target_id):
			continue
		if not _is_forward_shockwave_hit(pos, dir, range_value, width_value, Vector2(box["pos"]), float(box.get("radius", 24.0))):
			continue
		DestructibleSystemScript.damage_box(box, 1.0, destroyed_boxes, hit_effects)
		hit_ids.append(target_id)
	fx["hitIds"] = hit_ids

static func update_comment_pin_damage(fx: Dictionary, enemies: Array, destructibles: Array, killed_enemies: Array, destroyed_boxes: Array, hit_effects: Array, feedback: Dictionary = {}) -> void:
	var pos: Vector2 = Vector2(fx["pos"])
	var damage: float = float(fx.get("damage", 0.0))
	var hit_radius: float = float(fx.get("hitRadius", 12.0))
	var barrier_hit_requests: Array = feedback.get("barrierHitRequests", []) as Array
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if float(enemy.get("hp", 0.0)) <= 0.0:
			continue
		var enemy_pos: Vector2 = Vector2(enemy["pos"])
		var enemy_hit_radius: float = float(enemy.get("radius", 20.0)) + hit_radius
		if pos.distance_squared_to(enemy_pos) > enemy_hit_radius * enemy_hit_radius:
			continue
		var push_dir: Vector2 = Vector2(fx.get("dir", enemy_pos - pos)).normalized()
		if push_dir.length() < 0.1:
			push_dir = (enemy_pos - pos).normalized()
		var hit_result := _apply_enemy_hit(enemy, damage, push_dir, float(fx.get("knockback", 0.0)), killed_enemies, hit_effects, barrier_hit_requests, "comment_pin")
		if hit_result == HIT_DAMAGED:
			enemy["slowTimer"] = maxf(float(enemy.get("slowTimer", 0.0)), float(fx.get("slowDuration", 2.0)))
			enemy["slowRate"] = maxf(float(enemy.get("slowRate", 0.0)), float(fx.get("slowRate", 0.4)))
			_merge_reaction_result(feedback, {"enemyDamaged": true, "weaponCommentKind": "comment_pin"})
			hit_effects.append({
				"kind": "pin_burst",
				"pos": enemy_pos,
				"life": 0.22,
				"maxLife": 0.22
			})
		fx["life"] = 0.0
		return
	for box_item in destructibles:
		var box: Dictionary = box_item as Dictionary
		if float(box.get("hp", 0.0)) <= 0.0:
			continue
		var box_pos: Vector2 = Vector2(box["pos"])
		var box_hit_radius: float = float(box.get("radius", 24.0)) + hit_radius
		if pos.distance_squared_to(box_pos) <= box_hit_radius * box_hit_radius:
			DestructibleSystemScript.damage_box(box, 1.0, destroyed_boxes, hit_effects)
			fx["life"] = 0.0
			return

static func update_emote_mine_damage(fx: Dictionary, enemies: Array, destructibles: Array, enemy_bullets: Array, killed_enemies: Array, destroyed_boxes: Array, hit_effects: Array, feedback: Dictionary = {}) -> void:
	var pos: Vector2 = Vector2(fx["pos"])
	var trigger_radius: float = float(fx.get("triggerRadius", 28.0))
	var should_explode := false
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if float(enemy.get("hp", 0.0)) <= 0.0:
			continue
		var enemy_pos: Vector2 = Vector2(enemy["pos"])
		var trigger_hit_radius: float = float(enemy.get("radius", 20.0)) + trigger_radius
		if pos.distance_squared_to(enemy_pos) <= trigger_hit_radius * trigger_hit_radius:
			should_explode = true
			break
	if not should_explode:
		return
	var radius: float = float(fx.get("radius", 120.0))
	var damage: float = float(fx.get("damage", 0.0))
	var hit_count: int = _apply_circle_damage(enemies, pos, radius, damage, float(fx.get("knockback", 0.0)), killed_enemies, hit_effects, feedback.get("barrierHitRequests", []) as Array)
	_apply_circle_damage_to_boxes(destructibles, pos, radius, destroyed_boxes, hit_effects)
	_clear_enemy_bullets_in_circle(enemy_bullets, pos, radius, hit_effects)
	_merge_reaction_result(feedback, {
		"enemyDamaged": hit_count > 0,
		"screenShakePower": float(fx.get("screenShakePower", 0.0)),
		"screenShakeDuration": float(fx.get("screenShakeDuration", 0.15)),
		"hitStop": float(fx.get("hitStop", 0.0)),
		"weaponCommentKind": "emote_mine"
	})
	feedback["emoteMineExploded"] = true
	hit_effects.append({
		"kind": "emote_burst",
		"pos": pos,
		"life": 0.28,
		"maxLife": 0.28,
		"radius": radius
	})
	fx["life"] = 0.0

static func update_listener_summon_damage(fx: Dictionary, delta: float, enemies: Array, killed_enemies: Array, hit_effects: Array, feedback: Dictionary = {}) -> void:
	var pos: Vector2 = Vector2(fx["pos"])
	var hit_timer: float = maxf(0.0, float(fx.get("hitTimer", 0.0)) - delta)
	fx["hitTimer"] = hit_timer
	var target: Variant = _nearest_enemy_excluding(enemies, pos, float(fx.get("searchRange", 520.0)), [])
	var dir: Vector2 = Vector2(fx.get("dir", Vector2.RIGHT)).normalized()
	if target != null:
		var enemy: Dictionary = target as Dictionary
		dir = (Vector2(enemy["pos"]) - pos).normalized()
		if dir.length() < 0.1:
			dir = Vector2(fx.get("dir", Vector2.RIGHT)).normalized()
	if dir.length() < 0.1:
		dir = Vector2.RIGHT
	pos += dir * float(fx.get("moveSpeed", 180.0)) * delta
	fx["pos"] = pos
	fx["dir"] = dir
	if target == null:
		return
	var target_enemy: Dictionary = target as Dictionary
	if float(target_enemy.get("hp", 0.0)) <= 0.0:
		return
	var enemy_pos: Vector2 = Vector2(target_enemy["pos"])
	var hit_radius: float = float(target_enemy.get("radius", 20.0)) + float(fx.get("hitRadius", 18.0))
	if pos.distance_squared_to(enemy_pos) > hit_radius * hit_radius:
		return
	if hit_timer > 0.0:
		return
	var damage: float = float(fx.get("damage", 0.0))
	var hit_result := _apply_enemy_hit(target_enemy, damage, dir, float(fx.get("knockback", 0.0)) * 0.7, killed_enemies, hit_effects, feedback.get("barrierHitRequests", []) as Array, "listener_summon")
	if hit_result == HIT_DAMAGED:
		_merge_reaction_result(feedback, {"enemyDamaged": true, "listenerSummonAttacked": true, "weaponCommentKind": "listener_summon"})
		hit_effects.append({
			"kind": "listener_burst",
			"pos": enemy_pos,
			"life": 0.22,
			"maxLife": 0.22
		})
	fx["hitTimer"] = float(fx.get("hitCooldown", 0.70))

static func update_moderator_shield_fx(fx: Dictionary, delta: float, enemies: Array, destructibles: Array, enemy_bullets: Array, killed_enemies: Array, destroyed_boxes: Array, hit_effects: Array, feedback: Dictionary) -> void:
	var age := float(fx.get("age", 0.0)) + delta
	var duration := maxf(0.05, float(fx.get("travelDuration", 0.65)))
	var progress := clampf(age / duration, 0.0, 1.0)
	var origin := Vector2(fx.get("origin", Vector2.ZERO))
	var direction := Vector2(fx.get("dir", Vector2.RIGHT)).normalized()
	if direction.length() < 0.1:
		direction = Vector2.RIGHT
	var position := origin + direction * (float(fx.get("spawnOffset", 48.0)) + float(fx.get("travelDistance", 220.0)) * progress)
	fx["age"] = age
	fx["pos"] = position
	fx["progress"] = progress
	var side := Vector2(-direction.y, direction.x)
	var hit_ids: Dictionary = fx.get("hitEnemyIds", {}) as Dictionary
	var half_width := float(fx.get("width", 130.0)) * 0.5
	var half_thickness := float(fx.get("thickness", 48.0)) * 0.5
	var barrier_requests: Array = feedback.get("barrierHitRequests", []) as Array
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if not _stage2_alive_enemy(enemy):
			continue
		var token := _stage2_entity_token(enemy)
		if bool(hit_ids.get(token, false)):
			continue
		var offset := Vector2(enemy.get("pos", Vector2.ZERO)) - position
		var radius := float(enemy.get("radius", 20.0))
		if absf(offset.dot(direction)) > half_thickness + radius or absf(offset.dot(side)) > half_width + radius:
			continue
		var knockback := 0.0
		if not _is_boss_enemy(enemy) and bool(enemy.get("canBeKnockedBack", true)):
			knockback = float(fx.get("normalKnockbackDistance", 70.0))
			if EnemySystem.is_large_enemy(enemy):
				knockback *= float(fx.get("largeKnockbackRate", 0.5))
		var hit_result := _apply_enemy_hit(enemy, float(fx.get("damage", 0.0)), direction, knockback, killed_enemies, hit_effects, barrier_requests, "moderator_shield")
		if hit_result != HIT_NONE:
			hit_ids[token] = true
			if hit_result == HIT_DAMAGED:
				_merge_reaction_result(feedback, {"enemyDamaged": true, "weaponCommentKind": "moderator_shield"})
	fx["hitEnemyIds"] = hit_ids
	var hit_box_ids: Dictionary = fx.get("hitBoxIds", {}) as Dictionary
	for box_item in destructibles:
		var box: Dictionary = box_item as Dictionary
		if not _stage2_alive_box(box):
			continue
		var box_token := _stage2_box_token(box)
		if bool(hit_box_ids.get(box_token, false)):
			continue
		var box_offset := Vector2(box.get("pos", Vector2.ZERO)) - position
		var box_radius := float(box.get("radius", 24.0))
		if absf(box_offset.dot(direction)) > half_thickness + box_radius or absf(box_offset.dot(side)) > half_width + box_radius:
			continue
		DestructibleSystemScript.damage_box(box, 1.0, destroyed_boxes, hit_effects)
		hit_box_ids[box_token] = true
	fx["hitBoxIds"] = hit_box_ids
	var bullet_clears := int(fx.get("bulletClears", 0))
	var max_clears := int(fx.get("maxBulletClears", 3))
	if bullet_clears < max_clears:
		for bullet_item in enemy_bullets:
			if bullet_clears >= max_clears:
				break
			var bullet: Dictionary = bullet_item as Dictionary
			if float(bullet.get("life", 0.0)) <= 0.0 or not _stage2_shield_bullet_clearable(bullet):
				continue
			var bullet_pos := Vector2(bullet.get("pos", Vector2.ZERO))
			var bullet_radius := float(bullet.get("hitRadius", 10.0))
			if absf((bullet_pos - position).dot(direction)) > half_thickness + bullet_radius or absf((bullet_pos - position).dot(side)) > half_width + bullet_radius:
				continue
			bullet["life"] = 0.0
			bullet_clears += 1
			var bullet_clear_duration := _stage2_visual_duration(fx, "bulletClear", 0.24)
			hit_effects.append({"kind": "moderator_shield_bullet_clear", "pos": bullet_pos, "life": bullet_clear_duration, "maxLife": bullet_clear_duration, "visuals": (fx.get("visuals", {}) as Dictionary).duplicate(true)})
	fx["bulletClears"] = bullet_clears
	if age >= duration:
		fx["completionReason"] = "travel_complete"
		if bool(fx.get("allowCompletionWave", false)) and not bool(fx.get("waveSpawned", false)):
			fx["waveSpawned"] = true
			var end_wave_duration := _stage2_visual_duration(fx, "endShockwave", 0.24)
			hit_effects.append({
				"kind": "moderator_shield_end_wave", "owner": String(fx.get("owner", "moderator_shield")), "weaponId": "moderator_shield",
				"pos": position, "dir": direction, "width": float(fx.get("waveWidth", 150.0)), "depth": float(fx.get("waveDepth", 26.0)), "level": int(fx.get("level", 5)),
				"damage": float(fx.get("waveDamage", 0.0)), "knockback": float(fx.get("waveKnockback", 0.0)),
				"hitEnemyIds": {}, "hitBoxIds": {}, "life": end_wave_duration, "maxLife": end_wave_duration, "visuals": (fx.get("visuals", {}) as Dictionary).duplicate(true)
			})
		fx["life"] = 0.0

static func update_moderator_shield_end_wave_fx(fx: Dictionary, enemies: Array, destructibles: Array, killed_enemies: Array, destroyed_boxes: Array, hit_effects: Array, feedback: Dictionary) -> void:
	var position := Vector2(fx.get("pos", Vector2.ZERO))
	var direction := Vector2(fx.get("dir", Vector2.RIGHT)).normalized()
	if direction.length() < 0.1:
		direction = Vector2.RIGHT
	var side := Vector2(-direction.y, direction.x)
	var hit_ids: Dictionary = fx.get("hitEnemyIds", {}) as Dictionary
	var half_width := float(fx.get("width", 150.0)) * 0.5
	var half_depth := float(fx.get("depth", 26.0)) * 0.5
	var barrier_requests: Array = feedback.get("barrierHitRequests", []) as Array
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if not _stage2_alive_enemy(enemy):
			continue
		var token := _stage2_entity_token(enemy)
		if bool(hit_ids.get(token, false)):
			continue
		var offset := Vector2(enemy.get("pos", Vector2.ZERO)) - position
		var radius := float(enemy.get("radius", 20.0))
		if absf(offset.dot(direction)) > half_depth + radius or absf(offset.dot(side)) > half_width + radius:
			continue
		var hit_result := _apply_enemy_hit(enemy, float(fx.get("damage", 0.0)), direction, float(fx.get("knockback", 0.0)), killed_enemies, hit_effects, barrier_requests, "moderator_shield")
		if hit_result != HIT_NONE:
			hit_ids[token] = true
			if hit_result == HIT_DAMAGED:
				_merge_reaction_result(feedback, {"enemyDamaged": true, "weaponCommentKind": "moderator_shield"})
	fx["hitEnemyIds"] = hit_ids
	var hit_box_ids: Dictionary = fx.get("hitBoxIds", {}) as Dictionary
	for box_item in destructibles:
		var box: Dictionary = box_item as Dictionary
		if not _stage2_alive_box(box):
			continue
		var box_token := _stage2_box_token(box)
		if bool(hit_box_ids.get(box_token, false)):
			continue
		var box_offset := Vector2(box.get("pos", Vector2.ZERO)) - position
		var box_radius := float(box.get("radius", 24.0))
		if absf(box_offset.dot(direction)) > half_depth + box_radius or absf(box_offset.dot(side)) > half_width + box_radius:
			continue
		DestructibleSystemScript.damage_box(box, 1.0, destroyed_boxes, hit_effects)
		hit_box_ids[box_token] = true
	fx["hitBoxIds"] = hit_box_ids

static func update_fansa_baton_cross_followup_fx(fx: Dictionary, enemies: Array, destructibles: Array, killed_enemies: Array, destroyed_boxes: Array, hit_effects: Array, feedback: Dictionary) -> void:
	if bool(fx.get("applied", false)):
		return
	fx["applied"] = true
	var barrier_requests: Array = feedback.get("barrierHitRequests", []) as Array
	var hits := _apply_arc_damage(enemies, Vector2(fx.get("pos", Vector2.ZERO)), Vector2(fx.get("dir", Vector2.RIGHT)), float(fx.get("range", 140.0)), float(fx.get("arcAngle", 70.0)), float(fx.get("damage", 0.0)), 0.0, killed_enemies, hit_effects, barrier_requests, "fansa_baton")
	_apply_arc_damage_to_boxes(destructibles, Vector2(fx.get("pos", Vector2.ZERO)), Vector2(fx.get("dir", Vector2.RIGHT)), float(fx.get("range", 140.0)), float(fx.get("arcAngle", 70.0)), destroyed_boxes, hit_effects)
	if hits > 0:
		_merge_reaction_result(feedback, {"enemyDamaged": true, "weaponCommentKind": "fansa_baton"})
	fx["life"] = 0.0

static func _rod_limited_turn(current: Vector2, desired: Vector2, max_turn: float) -> Vector2:
	var current_dir := current.normalized()
	if current_dir.length() < 0.1:
		current_dir = Vector2.RIGHT
	var desired_dir := desired.normalized()
	if desired_dir.length() < 0.1:
		return current_dir
	var angle := current_dir.angle_to(desired_dir)
	return current_dir.rotated(clampf(angle, -max_turn, max_turn)).normalized()

static func _rod_finish(fx: Dictionary, enemies: Array, killed_enemies: Array, hit_effects: Array, feedback: Dictionary, player_pos: Vector2) -> void:
	var target := _rod_find_live_target(fx, enemies)
	if not target.is_empty():
		var target_pos := Vector2(target.get("pos", Vector2.ZERO))
		var push_dir := (player_pos - target_pos).normalized()
		var hit_result := _apply_enemy_hit(target, float(fx.get("reelDamage", 0.0)), push_dir, 0.0, killed_enemies, hit_effects, feedback.get("barrierHitRequests", []) as Array, "tsuri_thumbnail_rod")
		var reel_hit_duration := float(_stage2_visual_config(fx, "reelHit").get("durationSeconds", 0.20))
		hit_effects.append({"kind": "tsuri_rod_reel_hit", "pos": target_pos, "dir": push_dir, "life": reel_hit_duration, "maxLife": reel_hit_duration, "visuals": (fx.get("visuals", {}) as Dictionary).duplicate(true)})
		if hit_result == HIT_DAMAGED:
			_merge_reaction_result(feedback, {"enemyDamaged": true, "weaponCommentKind": "tsuri_thumbnail_rod"})
		if _stage2_alive_enemy(target) and EnemySystem.can_be_pulled(target):
			var distance := target_pos.distance_to(player_pos)
			var allowed := minf(float(fx.get("hookPullDistance", 45.0)), maxf(0.0, distance - float(fx.get("minPlayerDistance", 110.0))))
			if allowed > 0.0:
				_rod_apply_pull(target, player_pos, allowed)
	fx["life"] = 0.0

static func update_tsuri_rod_fx(fx: Dictionary, delta: float, enemies: Array, destructibles: Array, killed_enemies: Array, destroyed_boxes: Array, hit_effects: Array, feedback: Dictionary, player_pos: Vector2) -> void:
	var phase := String(fx.get("phase", "casting"))
	var position := Vector2(fx.get("pos", Vector2.ZERO))
	fx["displayPlayerPos"] = player_pos
	var target := _rod_find_live_target(fx, enemies)
	if phase == "casting":
		var destination := Vector2(fx.get("lastTargetPos", position))
		if not target.is_empty():
			destination = Vector2(target.get("pos", destination))
			fx["lastTargetPos"] = destination
		var direction := _rod_limited_turn(Vector2(fx.get("dir", Vector2.RIGHT)), destination - position, 7.5 * delta)
		var step := float(fx.get("lureSpeed", 900.0)) * delta
		var remaining := position.distance_to(destination)
		fx["dir"] = direction
		fx["previousPos"] = position
		if remaining <= maxf(2.0, step):
			fx["pos"] = destination
			_rod_land(fx, enemies, destructibles, killed_enemies, destroyed_boxes, hit_effects, feedback)
		else:
			fx["pos"] = position + direction * step
		return
	if phase == "gathering":
		var phase_timer := float(fx.get("phaseTimer", 0.0)) - delta
		fx["phaseTimer"] = phase_timer
		if phase_timer <= 0.0:
			fx["phase"] = "waiting"
			fx["phaseTimer"] = float(fx.get("reelDelay", 0.70))
		return
	if phase == "waiting":
		var phase_timer := float(fx.get("phaseTimer", 0.0)) - delta
		fx["phaseTimer"] = phase_timer
		if phase_timer <= 0.0:
			fx["phase"] = "reeling"
			fx["reelDestination"] = player_pos
			fx["previousPos"] = position
		return
	if (phase == "waiting" or phase == "reeling") and target.is_empty() and not (fx.get("targetReference", {}) as Dictionary).is_empty():
		fx["targetDied"] = true
	if phase != "reeling":
		return
	var previous_pos := position
	var destination := Vector2(fx.get("reelDestination", player_pos))
	var to_destination := destination - position
	var reel_step := float(fx.get("reelSpeed", 1250.0)) * delta
	var next_pos := destination if to_destination.length() <= reel_step else position + to_destination.normalized() * reel_step
	fx["previousPos"] = previous_pos
	fx["pos"] = next_pos
	var path_hit_ids: Dictionary = fx.get("pathHitEnemyIds", {}) as Dictionary
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if not _stage2_alive_enemy(enemy):
			continue
		var token := _stage2_entity_token(enemy)
		if token == String(fx.get("targetToken", "")) or bool(path_hit_ids.get(token, false)):
			continue
		var path_distance := _stage2_point_segment_distance(Vector2(enemy.get("pos", Vector2.ZERO)), previous_pos, next_pos)
		if path_distance > float(fx.get("pathWidth", 22.0)) * 0.5 + float(enemy.get("radius", 20.0)):
			continue
		var hit_result := _apply_enemy_hit(enemy, float(fx.get("pathDamage", 0.0)), (next_pos - previous_pos).normalized(), 0.0, killed_enemies, hit_effects, feedback.get("barrierHitRequests", []) as Array, "tsuri_thumbnail_rod")
		if hit_result != HIT_NONE:
			path_hit_ids[token] = true
			if hit_result == HIT_DAMAGED:
				_merge_reaction_result(feedback, {"enemyDamaged": true, "weaponCommentKind": "tsuri_thumbnail_rod"})
	fx["pathHitEnemyIds"] = path_hit_ids
	var path_hit_box_ids: Dictionary = fx.get("pathHitBoxIds", {}) as Dictionary
	for box_item in destructibles:
		var box: Dictionary = box_item as Dictionary
		if not _stage2_alive_box(box):
			continue
		var box_token := _stage2_box_token(box)
		if bool(path_hit_box_ids.get(box_token, false)):
			continue
		var path_distance := _stage2_point_segment_distance(Vector2(box.get("pos", Vector2.ZERO)), previous_pos, next_pos)
		if path_distance > float(fx.get("pathWidth", 22.0)) * 0.5 + float(box.get("radius", 24.0)):
			continue
		DestructibleSystemScript.damage_box(box, 1.0, destroyed_boxes, hit_effects)
		path_hit_box_ids[box_token] = true
	fx["pathHitBoxIds"] = path_hit_box_ids
	var collision_ids: Dictionary = fx.get("collisionHitEnemyIds", {}) as Dictionary
	var collision_max := int(fx.get("collisionMaxTargets", 5))
	if bool(fx.get("collisionEnabled", false)) and not bool(fx.get("targetDied", false)) and collision_ids.size() < collision_max:
		for enemy_item in enemies:
			if collision_ids.size() >= collision_max:
				break
			var enemy: Dictionary = enemy_item as Dictionary
			if not _stage2_alive_enemy(enemy) or not EnemySystem.is_collision_pullable_enemy(enemy):
				continue
			var token := _stage2_entity_token(enemy)
			if token == String(fx.get("targetToken", "")) or bool(collision_ids.get(token, false)):
				continue
			if _stage2_point_segment_distance(Vector2(enemy.get("pos", Vector2.ZERO)), previous_pos, next_pos) > float(fx.get("collisionRadius", 24.0)) + float(enemy.get("radius", 20.0)):
				continue
			var collision_result := _apply_enemy_hit(enemy, float(fx.get("reelDamage", 0.0)) * float(fx.get("collisionDamageRatio", 0.60)), (next_pos - previous_pos).normalized(), 0.0, killed_enemies, hit_effects, feedback.get("barrierHitRequests", []) as Array, "tsuri_thumbnail_rod")
			if collision_result != HIT_NONE:
				collision_ids[token] = true
				if collision_result == HIT_DAMAGED:
					_merge_reaction_result(feedback, {"enemyDamaged": true, "weaponCommentKind": "tsuri_thumbnail_rod"})
	fx["collisionHitEnemyIds"] = collision_ids
	if next_pos.distance_to(destination) <= 0.01:
		_rod_finish(fx, enemies, killed_enemies, hit_effects, feedback, destination)

static func update_hit_fx(hit_fx: Array, delta: float, enemies: Array = [], destructibles: Array = [], enemy_bullets: Array = [], killed_enemies: Array = [], destroyed_boxes: Array = [], feedback: Dictionary = {}, arena: Rect2 = Rect2(), walls: Array = [], player_pos: Vector2 = Vector2.ZERO) -> Array:
	var appended_fx: Array = []
	for fx_item in hit_fx:
		var fx: Dictionary = fx_item
		var delay: float = float(fx.get("delay", 0.0))
		if delay > 0.0:
			fx["delay"] = maxf(0.0, delay - delta)
			continue
		var kind: String = String(fx.get("kind", ""))
		if fx.has("vel") and kind != "kusa_wave":
			var move: Vector2 = Vector2(fx["vel"]) * delta
			fx["pos"] = Vector2(fx["pos"]) + move
			if fx.has("hit"):
				fx["hit"] = Vector2(fx["hit"]) + move
		if kind == "kusa_wave":
			update_kusa_wave_damage(fx, delta, enemies, destructibles, enemy_bullets, killed_enemies, destroyed_boxes, appended_fx, feedback, arena, walls)
		elif kind == "ban_judgement_shockwave":
			update_ban_judgement_shockwave_damage(fx, enemies, destructibles, killed_enemies, destroyed_boxes, appended_fx, feedback)
		elif kind == "comment_pin":
			update_comment_pin_damage(fx, enemies, destructibles, killed_enemies, destroyed_boxes, appended_fx, feedback)
		elif kind == "emote_mine":
			update_emote_mine_damage(fx, enemies, destructibles, enemy_bullets, killed_enemies, destroyed_boxes, appended_fx, feedback)
		elif kind == "listener_summon":
			update_listener_summon_damage(fx, delta, enemies, killed_enemies, appended_fx, feedback)
		elif kind == "moderator_shield_active":
			update_moderator_shield_fx(fx, delta, enemies, destructibles, enemy_bullets, killed_enemies, destroyed_boxes, appended_fx, feedback)
		elif kind == "moderator_fortress_active":
			update_moderator_fortress_fx(fx, delta, enemies, destructibles, enemy_bullets, killed_enemies, destroyed_boxes, appended_fx, feedback)
		elif kind == "moderator_fortress_shockwave":
			update_moderator_fortress_shockwave_fx(fx, enemies, enemy_bullets, killed_enemies, appended_fx, feedback)
		elif kind == "moderator_shield_end_wave":
			update_moderator_shield_end_wave_fx(fx, enemies, destructibles, killed_enemies, destroyed_boxes, appended_fx, feedback)
		elif kind == "fansa_baton_cross_followup":
			update_fansa_baton_cross_followup_fx(fx, enemies, destructibles, killed_enemies, destroyed_boxes, appended_fx, feedback)
		elif kind == "fansa_climax_echo":
			update_fansa_climax_echo_fx(fx, enemies, killed_enemies, appended_fx, feedback)
		elif kind == "fansa_climax_x":
			update_fansa_climax_x_fx(fx, enemies, killed_enemies, appended_fx, feedback)
		elif kind == "fansa_climax_fan_wave":
			update_fansa_climax_fan_wave_fx(fx, enemies, killed_enemies, appended_fx, feedback)
		elif kind == "tsuri_rod_cast":
			update_tsuri_rod_fx(fx, delta, enemies, destructibles, killed_enemies, destroyed_boxes, appended_fx, feedback, player_pos)
		elif kind == "buzz_thumbnail_rod_cast":
			update_buzz_thumbnail_rod_fx(fx, delta, enemies, killed_enemies, appended_fx, feedback, player_pos)
		fx["life"] = float(fx["life"]) - delta
	var remaining: Array = _alive_hit_fx(hit_fx)
	for fx_item in appended_fx:
		remaining.append(fx_item)
	return _capped_hit_fx(remaining)

static func advance_hit_fx_visuals_for_target(target: Node, delta: float) -> void:
	var hit_fx: Array = target.get("hit_fx") as Array
	for fx_item in hit_fx:
		var fx: Dictionary = fx_item as Dictionary
		var delay := float(fx.get("delay", 0.0))
		if delay > 0.0:
			fx["delay"] = maxf(0.0, delay - delta)
			continue
		if fx.has("vel"):
			var move := Vector2(fx["vel"]) * delta
			fx["pos"] = Vector2(fx.get("pos", Vector2.ZERO)) + move
			if fx.has("hit"):
				fx["hit"] = Vector2(fx["hit"]) + move
		fx["life"] = float(fx.get("life", 0.0)) - delta
	target.set("hit_fx", _alive_hit_fx(hit_fx))

static func update_hit_fx_for_target(target: Node, delta: float, arena: Rect2, rng: RandomNumberGenerator) -> Dictionary:
	var chats: Array = []
	var feedback: Dictionary = {"chats": chats, "barrierHitRequests": []}
	var killed_enemies: Array = []
	var destroyed_boxes: Array = []
	var enemies: Array = target.get("enemies") as Array
	var destructibles: Array = target.get("destructibles") as Array
	var enemy_bullets: Array = target.get("enemy_bullets") as Array
	var stream_frame_id: String = DrawDataSystem.collision_frame_id_for_target(target)
	var effect_walls_value: Variant = target.get("effect_walls")
	var effect_walls: Array = []
	if effect_walls_value is Array:
		effect_walls = effect_walls_value as Array
	var walls: Array = EnemySystem.movement_wall_rects(effect_walls, stream_frame_id)
	target.set("hit_fx", update_hit_fx(target.get("hit_fx") as Array, delta, enemies, destructibles, enemy_bullets, killed_enemies, destroyed_boxes, feedback, arena, walls, Vector2(target.get("player_pos"))))
	target.set("enemy_bullets", _alive_enemy_bullets(enemy_bullets))
	_dispatch_barrier_hit_requests(target, feedback.get("barrierHitRequests", []) as Array)
	for item in killed_enemies:
		var enemy: Dictionary = item
		var kill_result: Dictionary = EnemySystem.apply_kill_for_target(target, enemy, arena, rng)
		_merge_reaction_result(feedback, kill_result)
		var kill_chat: String = String(kill_result["chat"])
		if kill_chat != "":
			chats.append(kill_chat)
	target.set("enemies", _kept_enemies(enemies))
	var destroy_feedback: Dictionary = DestructibleSystemScript.apply_destroyed_for_target(target, destroyed_boxes, rng)
	for item in (destroy_feedback["chats"] as Array):
		chats.append(String(item))
	return feedback

static func nearest_enemy(enemies: Array, player_pos: Vector2) -> Variant:
	var best: Variant = null
	var best_distance: float = INF
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item
		if float(enemy["hp"]) <= 0.0:
			continue
		var distance: float = Vector2(enemy["pos"]).distance_squared_to(player_pos)
		if distance < best_distance:
			best_distance = distance
			best = enemy
	return best
