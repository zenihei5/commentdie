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
const STAGE2_WEAPON_IDS := ["moderator_shield", "fansa_baton", "tsuri_thumbnail_rod", "moderator_fortress", "fansa_climax", "buzz_thumbnail_rod", "full_voice_dome", "center_stage", "great_grassland", "comment_lockdown", "emote_festival", "all_block_laser", "listener_assembly"]
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


static func _weapon_parent_id(weapon_id: String, entry: Dictionary, weapon_data: Array) -> String:
	var parent_id := String(entry.get("baseWeaponId", ""))
	if parent_id != "":
		return parent_id
	var weapon := find_weapon(weapon_data, weapon_id, {})
	return String(weapon.get("baseWeaponId", ""))


static func _weapon_lineage_contains(
	weapon_id: String,
	entry: Dictionary,
	required_base_id: String,
	player_weapons: Array,
	weapon_data: Array,
	visited: Dictionary = {}
) -> bool:
	if weapon_id == required_base_id:
		return true
	if weapon_id == "" or bool(visited.get(weapon_id, false)):
		return false
	visited[weapon_id] = true
	var parent_id := _weapon_parent_id(weapon_id, entry, weapon_data)
	if parent_id == "":
		return false
	var parent_entry := EquipmentSystem.find_entry(player_weapons, parent_id)
	return _weapon_lineage_contains(parent_id, parent_entry, required_base_id, player_weapons, weapon_data, visited)


static func resolve_equipped_weapon_for_base(
	base_weapon_id: String,
	current_weapon: Dictionary,
	player_weapons: Array,
	weapon_data: Array
) -> Dictionary:
	if base_weapon_id == "":
		return {"found": false}
	var current_id := String(current_weapon.get("id", ""))
	if current_id != "" and _weapon_lineage_contains(
		current_id,
		EquipmentSystem.find_entry(player_weapons, current_id),
		base_weapon_id,
		player_weapons,
		weapon_data,
		{}
	):
		var main_entry := EquipmentSystem.find_entry(player_weapons, current_id)
		var main_weapon := find_weapon(weapon_data, current_id, current_weapon)
		return {
			"found": true,
			"weapon": main_weapon,
			"entry": main_entry if not main_entry.is_empty() else {"id": current_id, "level": 1},
			"entryLevel": EquipmentSystem.entry_level(main_entry, 1) if not main_entry.is_empty() else 1,
			"weaponId": current_id,
			"baseWeaponId": base_weapon_id,
			"slotIndex": player_weapons.find(main_entry) if not main_entry.is_empty() else -1,
			"isMain": true
		}
	for slot_index in range(player_weapons.size()):
		var entry_value: Variant = player_weapons[slot_index]
		if not entry_value is Dictionary:
			continue
		var entry: Dictionary = entry_value as Dictionary
		var weapon_id := String(entry.get("id", ""))
		if weapon_id == "" or not _weapon_lineage_contains(weapon_id, entry, base_weapon_id, player_weapons, weapon_data, {}):
			continue
		var weapon := find_weapon(weapon_data, weapon_id, {})
		if weapon.is_empty():
			continue
		return {
			"found": true,
			"weapon": weapon,
			"entry": entry,
			"entryLevel": EquipmentSystem.entry_level(entry, 1),
			"weaponId": weapon_id,
			"baseWeaponId": base_weapon_id,
			"slotIndex": slot_index,
			"isMain": false
		}
	return {"found": false}


static func _initial_evolved_runtime_kind(weapon: Dictionary) -> String:
	if not bool(weapon.get("isEvolved", false)) or String(weapon.get("baseWeaponId", "")) == "":
		return ""
	var type := attack_type(weapon)
	if type == "melee_shockwave":
		return "melee_shockwave"
	if type == "projectile" and weapon.has("premiumEvery") and weapon.has("premiumExplosionDamage"):
		return "starlight_projectile"
	if type == "orbit" and weapon.has("pulseInterval") and weapon.has("pulseDamage"):
		return "maro_orbit"
	return ""

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

## Standard, modifier-free values shared by the runtime and the codex.
## `initial_owner` selects the six character starting-weapon rules; all other
## normal weapons use the equipment-weapon path from update_equipment_weapons.
static func codex_standard_stats_for_level(weapon: Dictionary, level: int = 1, initial_owner: bool = false) -> Dictionary:
	if weapon.is_empty():
		return {}
	var weapon_id := String(weapon.get("id", ""))
	var max_level := maxi(1, int(weapon.get("maxLevel", 1)))
	var safe_level := clampi(level, 1, max_level)
	var resolved := stage2_level_data(weapon, safe_level) if _is_stage2_weapon_id(weapon_id) else weapon.duplicate(true)
	resolved["level"] = safe_level
	var base_damage := float(resolved.get("damage", resolved.get("baseDamage", 4.0)))
	var base_interval := attack_interval(resolved, 1.0)
	var base_range := range_base(resolved)
	var result: Dictionary = resolved.duplicate(true)
	if weapon_id == "kusa_wave":
		result["damage"] = _kusa_wave_damage_for_level(safe_level)
		result["attackInterval"] = _kusa_wave_interval_for_level(safe_level)
		result["range"] = _kusa_wave_distance_for_level(safe_level)
		result["sizeMultiplier"] = _kusa_wave_size_for_level(safe_level)
		result["bounceCount"] = _kusa_wave_bounces_for_level(safe_level)
	else:
		if initial_owner:
			var owner_damage := base_damage * (1.0 + 0.10 * float(safe_level - 1))
			if weapon_id in ["superchat_shot", "comment_boomerang"]:
				owner_damage += 1.5 * float(safe_level - 1)
			result["damage"] = owner_damage
			result["range"] = base_range * (1.0 + 0.08 * float(safe_level - 1))
			var owner_rate := pow(0.94, float(safe_level - 1))
			var owner_min := float(resolved.get("minAttackInterval", resolved.get("minCooldown", 0.28)))
			result["attackInterval"] = maxf(owner_min, player_attack_interval(base_interval, owner_rate))
		else:
			result["damage"] = base_damage + 1.5 * float(safe_level - 1)
			result["range"] = base_range
			result["attackInterval"] = player_attack_interval(base_interval, 1.0)
		if weapon_id in ["comment_pin", "emote_mine", "ng_word_laser", "listener_summon"]:
			var count_key := "projectileCount" if weapon_id == "comment_pin" else ("mineCount" if weapon_id == "emote_mine" else ("laserCount" if weapon_id == "ng_word_laser" else "summonCount"))
			result[count_key] = _weapon_spawn_count(resolved, count_key, safe_level, 0)
		if weapon_id == "comment_pin":
			result["slowDuration"] = _level_duration(float(resolved.get("slowDuration", 2.0)), safe_level)
		if weapon_id == "emote_mine":
			result["duration"] = _level_duration(float(resolved.get("duration", 8.0)), safe_level)
			result["explosionRadius"] = scaled_range(float(resolved.get("explosionRadius", 1.5))) * (1.12 if safe_level >= 3 else 1.0)
		if weapon_id == "ng_word_laser":
			result["width"] = scaled_range(float(resolved.get("width", 0.6))) * (1.12 if safe_level >= 5 else 1.0)
		if weapon_id == "listener_summon":
			result["duration"] = _level_duration(float(resolved.get("duration", 6.0)), safe_level)
			result["searchRange"] = scaled_range(float(resolved.get("searchRange", resolved.get("range", 7.0)))) * (1.10 if safe_level >= 3 else 1.0)
	if weapon_id in STAGE2_WEAPON_IDS and not bool(resolved.get("isEvolved", false)):
		var behavior := _stage2_behavior(resolved)
		if behavior in ["moderator_shield", "front_shield"]:
			result["damage"] = _stage2_base_damage(resolved) * float(resolved.get("damageMultiplier", 1.0))
			result["attackInterval"] = float(resolved.get("activationInterval", base_interval))
			result["radius"] = float(resolved.get("radius", 80.0)) * float(resolved.get("sizeRate", 1.0))
		elif behavior == "fansa_baton":
			var shape := fansa_attack_shape(resolved, safe_level, {})
			result["range"] = float(shape.get("radius", resolved.get("normalRange", 110.0)))
			result["arcAngle"] = float(shape.get("arcDegrees", resolved.get("normalArcAngle", 130.0)))
			result["attackInterval"] = float(resolved.get("hitInterval", resolved.get("attackInterval", 0.55)))
			result["normalDamage"] = _stage2_base_damage(resolved) * float(resolved.get("normalDamageCoefficient", 0.55)) * float(resolved.get("normalDamageMultiplier", 1.0))
			result["finisherDamage"] = _stage2_base_damage(resolved) * float(resolved.get("finisherDamageCoefficient", 1.25)) * float(resolved.get("finisherDamageMultiplier", 1.0))
		elif behavior == "tsuri_thumbnail_rod":
			result["initialDamage"] = _stage2_base_damage(resolved) * float(resolved.get("initialDamageCoefficient", 0.30)) * float(resolved.get("initialDamageMultiplier", 1.0))
			result["reelDamage"] = _stage2_base_damage(resolved) * float(resolved.get("reelDamageCoefficient", 1.10)) * float(resolved.get("reelDamageMultiplier", 1.0))
			result["attackInterval"] = float(resolved.get("activationInterval", base_interval))
			result["range"] = float(resolved.get("maxCastRange", resolved.get("range", 0.0))) * float(resolved.get("castRangeMultiplier", 1.0))
	elif weapon_id in STAGE2_WEAPON_IDS:
		var behavior := _stage2_behavior(resolved)
		if behavior == "moderator_fortress":
			result["damage"] = _stage2_base_damage(resolved) * float(resolved.get("damageRate", 1.0))
			result["attackInterval"] = float(resolved.get("activationInterval", base_interval))
			result["radius"] = float(resolved.get("radius", 100.0))
		elif behavior == "fansa_climax":
			result["normalDamage"] = _stage2_base_damage(resolved) * float(resolved.get("normalDamageCoefficient", 0.65))
			result["finisherDamage"] = _stage2_base_damage(resolved) * float(resolved.get("finisherDamageCoefficient", 1.40))
			result["echoDamage"] = _stage2_base_damage(resolved) * float(resolved.get("echoDamageCoefficient", 0.30))
			result["attackInterval"] = float(resolved.get("attackInterval", base_interval))
		elif behavior == "buzz_thumbnail_rod":
			result["initialDamage"] = _stage2_base_damage(resolved) * float(resolved.get("initialDamageCoefficient", 0.40))
			result["caughtDamage"] = _stage2_base_damage(resolved) * float(resolved.get("caughtDamageCoefficient", 1.35))
			result["attackInterval"] = float(resolved.get("activationInterval", base_interval))
	return result

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
	if kind in ["moderator_shield_active", "moderator_shield_deploy", "moderator_shield_end", "moderator_shield_end_wave", "tsuri_rod_cast", "fansa_baton_hit", "fansa_baton_cross_followup", "moderator_shield_bullet_clear", "moderator_fortress_active", "moderator_fortress_deploy", "moderator_fortress_end", "moderator_shield_hit", "moderator_fortress_hit", "moderator_fortress_shockwave", "moderator_fortress_bullet_clear", "fansa_climax_hit", "fansa_climax_echo", "fansa_climax_x", "fansa_climax_fan_wave", "buzz_thumbnail_rod_cast", "buzz_thumbnail_rod_gather", "buzz_thumbnail_rod_explosion", "buzz_thumbnail_rod_target_mark", "buzz_thumbnail_rod_throw", "buzz_thumbnail_rod_bear_flash", "buzz_thumbnail_rod_catch_mark", "buzz_thumbnail_rod_hit", "full_voice_dome_wave", "full_voice_dome_pulse", "center_stage_area", "center_stage_finish", "great_grassland_wave", "comment_lockdown_projectile", "comment_lockdown_followup", "comment_lockdown_hit", "comment_lockdown_followup_hit", "emote_festival_mine", "emote_festival_burst", "all_block_laser", "listener_assembly", "stage2_bullet_clear"]:
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
		"spotlight", "kusa_wave", "comment_pin", "center_stage", "great_grassland", "comment_lockdown":
			return _apply_short_range(context, range_value, 0.60, 0.75, SHORT_RANGE_MIN_PROJECTILE_RANGE)
		"ng_word_laser", "all_block_laser":
			return _apply_short_range(context, range_value, 0.55, 0.75, SHORT_RANGE_MIN_LASER_RANGE)
		"listener_summon", "listener_assembly":
			return _apply_short_range(context, range_value, 0.60, 0.75, SHORT_RANGE_MIN_SEARCH_RANGE)
		"fansa_baton", "fansa_climax":
			return _apply_short_range(context, range_value, 0.75, 0.85, 0.0)
		"emote_mine", "emote_festival":
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
	var sound_weapon_id: String = String(weapon.get("id", "")) if is_main_orbit else String(weapon.get("id", "comment_boomerang"))
	if sound_weapon_id == "":
		sound_weapon_id = "comment_boomerang"
	var index_key := BOOMERANG_ORBIT_INDEX_KEY if sound_weapon_id == "comment_boomerang" else "%s:%s" % [BOOMERANG_ORBIT_INDEX_KEY, sound_weapon_id]
	var weapon_id_key := BOOMERANG_ORBIT_WEAPON_ID_KEY if sound_weapon_id == "comment_boomerang" else "%s:%s" % [BOOMERANG_ORBIT_WEAPON_ID_KEY, sound_weapon_id]
	var orbit_index: int = int(floor(elapsed * safe_speed / TAU))
	var last_weapon_id: String = String(weapon_timers.get(weapon_id_key, ""))
	if not weapon_timers.has(index_key) or last_weapon_id != sound_weapon_id:
		weapon_timers[weapon_id_key] = sound_weapon_id
		weapon_timers[index_key] = orbit_index
		return false
	var last_orbit_index: int = int(weapon_timers.get(index_key, orbit_index))
	if orbit_index <= last_orbit_index:
		return false
	weapon_timers[index_key] = orbit_index
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
		"weaponData": context.get("weaponData", []),
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
		"dropItems": context.get("dropItems", []),
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
		"mainWeapon": main_weapon,
		"mainWeaponId": String(main_weapon.get("id", "")),
		"timers": context["equipmentWeaponTimers"],
		"playerPos": context["playerPos"],
		"facingDir": context["facingDir"],
		"playerVel": context.get("playerVel", Vector2.ZERO),
		"lastMoveDirection": context.get("lastMoveDirection", context.get("lastDir", Vector2.RIGHT)),
		"manualAimDirection": context.get("manualAimDirection", Vector2.ZERO),
		"moveInput": context.get("moveInput", Vector2.ZERO),
		"elapsed": context.get("elapsed", 0.0),
		"rng": context["rng"],
		"attackRightOnly": context["attackRightOnly"],
		"attackRightOnlyRate": context["attackRightOnlyRate"],
		"weaponMute": context.get("weaponMute", false),
		"enemies": context["enemies"],
		"destructibles": context["destructibles"],
		"enemyBullets": context["enemyBullets"],
		"playerBullets": result["playerBullets"],
		"boomerangHits": result["boomerangHits"],
		"expOrbs": context.get("expOrbs", []),
		"dropItems": context.get("dropItems", []),
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
	if equipment_result.has("playerBullets"):
		result["playerBullets"] = equipment_result["playerBullets"]
	if equipment_result.has("boomerangHits"):
		result["boomerangHits"] = equipment_result["boomerangHits"]
	result["superchatShotFired"] = bool(result.get("superchatShotFired", false)) or bool(equipment_result.get("superchatShotFired", false))
	result["boomerangOrbitSe"] = bool(result.get("boomerangOrbitSe", false)) or bool(equipment_result.get("boomerangOrbitSe", false))
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
		"lastMoveDirection": target.get("last_hammer_dir"),
		"manualAimDirection": Vector2.ZERO,
		"moveInput": target.get("player_vel"),
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
		"dropItems": target.get("drop_items"),
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
		"full_voice_dome":
			return "mic"
		"center_stage":
			return "spotlight"
		"comment_pin":
			return "comment_pin"
		"kusa_wave":
			return "kusa_wave"
		"great_grassland":
			return "kusa_wave"
		"comment_lockdown":
			return "comment_pin"
		"ng_word_laser":
			return "ng_word_laser"
		"all_block_laser":
			return "ng_word_laser"
		"listener_summon":
			return "listener_summon"
		"listener_assembly":
			return "listener_summon"
		"emote_mine":
			return "emote_mine"
		"emote_festival":
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
	var damage_fx := _damage_number_fx(enemy_pos, applied_damage)
	if hit_source != "":
		damage_fx["owner"] = hit_source
		damage_fx["weaponId"] = hit_source
	hit_effects.append(damage_fx)
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

static func _clear_enemy_bullets_in_circle(enemy_bullets: Array, center: Vector2, radius: float, hit_effects: Array, clear_fx_kind: String = "", owner_id: String = "") -> int:
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
				var maro_clear_fx := _maro_bullet_clear_fx(bullet_pos, center)
				_tag_hit_effects_for_weapon([maro_clear_fx], 0, owner_id)
				hit_effects.append(maro_clear_fx)
			else:
				var bullet_fx := _bullet_pop_fx(bullet_pos)
				if owner_id != "":
					bullet_fx["kind"] = "stage2_bullet_clear"
					bullet_fx["owner"] = owner_id
					bullet_fx["weaponId"] = owner_id
				hit_effects.append(bullet_fx)
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
		var judgement_fx_start := hit_effects.size()
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
		_tag_hit_effects_for_weapon(hit_effects, judgement_fx_start, String(weapon.get("id", "")) if bool(weapon.get("isEvolved", false)) else "")
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

static func _runtime_weapon_for_bullet(bullet: Dictionary, context: Dictionary) -> Dictionary:
	var weapon_id := String(bullet.get("weaponId", ""))
	var weapon_data: Array = context.get("weaponData", []) as Array
	if weapon_id != "":
		var registered := find_weapon(weapon_data, weapon_id, {})
		if not registered.is_empty():
			return registered
	return context.get("weapon", {}) as Dictionary


static func _weapon_knockback_for_context(weapon: Dictionary, context: Dictionary) -> float:
	var current_weapon: Dictionary = context.get("weapon", {}) as Dictionary
	var weapon_id := String(weapon.get("id", ""))
	if weapon_id == "" or weapon_id == String(current_weapon.get("id", "")):
		return float(context.get("knockback", 0.0))
	return scaled_knockback(float(weapon.get("knockback", 0.0)))


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
		var bullet_weapon: Dictionary = _runtime_weapon_for_bullet(bullet, context)
		var bullet_weapon_id := String(bullet.get("weaponId", ""))
		var bullet_visual_kind := String(bullet.get("visualKind", ""))
		if bullet_weapon_id == "" and (bullet_visual_kind == "starlight_superchat" or bullet_visual_kind == "high_superchat" or _is_starlight_superchat(bullet_weapon)):
			bullet_weapon_id = String(bullet_weapon.get("id", ""))
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
					var clash_fx_start := hit_effects.size()
					hit_effects.append(_bullet_pop_fx(enemy_bullet_pos))
					_tag_hit_effects_for_weapon(hit_effects, clash_fx_start, bullet_weapon_id if _is_starlight_superchat(bullet_weapon) else "")
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
				var is_starlight_bullet: bool = visual_kind == "starlight_superchat" or visual_kind == "high_superchat" or _is_starlight_superchat(bullet_weapon)
				if bullet_weapon_id == "" and is_starlight_bullet:
					bullet_weapon_id = String(bullet_weapon.get("id", ""))
				var is_premium_bullet: bool = bool(bullet.get("premium", false))
				var hit_source := String(bullet.get("source", ""))
				if hit_source == "":
					hit_source = bullet_weapon_id
				var hit_result := _apply_enemy_hit(enemy, damage, push_dir, _weapon_knockback_for_context(bullet_weapon, context) * 0.42, killed_enemies, hit_effects, barrier_hit_requests, hit_source)
				if hit_result == HIT_DAMAGED:
					if is_starlight_bullet:
						hit_effects.append(_starlight_hit_fx(hit_pos, is_premium_bullet, bullet_weapon_id))
						if _starlight_enemy_defeated(enemy):
							hit_effects.append(_starlight_defeat_fx(enemy, is_premium_bullet, bullet_weapon_id))
					var weapon_for_hit: Dictionary = bullet_weapon
					if is_premium_bullet:
						var explosion_hits: int = _apply_starlight_explosion(weapon_for_hit, context, hit_pos, enemies, destructibles, killed_enemies, destroyed_boxes, hit_effects, barrier_hit_requests, bullet_weapon_id)
						_request_weapon_hit_reaction(result, weapon_for_hit, 1 + explosion_hits, 1 + explosion_hits)
					_request_weapon_hit_reaction(result, weapon_for_hit, 1)
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
						hit_effects.append(_starlight_hit_fx(hit_pos, true, bullet_weapon_id))
						_apply_starlight_explosion(bullet_weapon, context, hit_pos, enemies, destructibles, killed_enemies, destroyed_boxes, hit_effects, barrier_hit_requests, bullet_weapon_id)
					elif String(bullet.get("visualKind", "")) == "starlight_superchat":
						hit_effects.append(_starlight_hit_fx(hit_pos, false, bullet_weapon_id))
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
	var is_main_orbit: bool = bool(context.get("isMainOrbit", weapon_type == "orbit"))
	var is_maro_ring: bool = _is_maro_comment_ring(weapon)
	var weapon_id := String(weapon.get("id", "comment_boomerang"))
	var evolved_owner_id := weapon_id if bool(weapon.get("isEvolved", false)) else ""
	var count: int = orbit_count(weapon, boomerang_level)
	if count > 0 and not is_maro_ring:
		count += int(context.get("bulletSupportLevel", 0))
	if count <= 0:
		return result
	var player_pos: Vector2 = Vector2(context["playerPos"])
	var radius: float = float(context["range"]) if is_main_orbit or is_maro_ring else 78.0
	radius = _apply_short_range(context, radius, 0.70, 0.85, SHORT_RANGE_MIN_ORBIT_RADIUS)
	if is_maro_ring:
		_update_maro_comment_pulse(weapon, context, radius, weapon_timers, context["enemies"] as Array, killed_enemies, hit_effects, result, evolved_owner_id)
		var pulse_until: float = float(weapon_timers.get(MARO_PULSE_UNTIL_KEY, 0.0))
		var pulse_duration: float = maxf(0.05, float(weapon.get("pulseDuration", 0.25)))
		if float(context["elapsed"]) < pulse_until:
			var pulse_progress: float = clampf(1.0 - (pulse_until - float(context["elapsed"])) / pulse_duration, 0.0, 1.0)
			var pulse_strength: float = sin(pulse_progress * PI)
			radius = lerpf(radius, _maro_pulse_radius(weapon, radius), pulse_strength)
			_nudge_exp_orbs_for_maro_pulse(context.get("expOrbs", []) as Array, player_pos, _maro_pulse_exp_pull_radius(weapon), float(context["delta"]))
	var hit_radius: float = float(weapon.get("hitRadius", 34.0)) if is_main_orbit or is_maro_ring else 28.0
	hit_radius *= attack_area_rate(context)
	var speed: float = orbit_speed(weapon)
	var damage: float = float(context["damage"]) if is_main_orbit or is_maro_ring else 5.0
	damage += float(boomerang_level) * 1.5
	var hit_interval: float = float(weapon.get("hitInterval", 0.6)) if is_main_orbit or is_maro_ring else 0.6
	var elapsed: float = float(context["elapsed"])
	result["boomerangOrbitSe"] = _boomerang_orbit_se_due(weapon, weapon_timers, elapsed, speed, is_main_orbit)
	var enemies: Array = context["enemies"] as Array
	var destructibles: Array = context["destructibles"] as Array
	var enemy_bullets: Array = context["enemyBullets"] as Array
	var hit_memory: Dictionary = context["boomerangHits"] as Dictionary
	for i in range(count):
		var angle: float = elapsed * speed + TAU * float(i) / float(count)
		var pos: Vector2 = player_pos + Vector2(cos(angle), sin(angle)) * radius
		var cleared_bullets: int = _clear_enemy_bullets_in_circle(enemy_bullets, pos, hit_radius + 10.0, hit_effects, "maro_comment" if is_maro_ring else "", evolved_owner_id)
		if is_maro_ring and cleared_bullets > 0:
			weapon_timers[MARO_FLASH_UNTIL_KEY] = elapsed + 0.18
		for enemy_item in enemies:
			var enemy: Dictionary = enemy_item
			if float(enemy["hp"]) <= 0.0:
				continue
			var enemy_id: String = "%s_%d" % [String(enemy["kind"]), int(enemy.get("uid", 0))] if evolved_owner_id == "" else _stage2_entity_token(enemy)
			var hit_key: String = "%d:%s" % [i, enemy_id] if evolved_owner_id == "" else "%s|%d|%s" % [weapon_id, i, enemy_id]
			if float(hit_memory.get(hit_key, 0.0)) > elapsed:
				continue
			var enemy_pos: Vector2 = Vector2(enemy["pos"])
			var enemy_hit_radius: float = float(enemy["radius"]) + hit_radius
			if pos.distance_squared_to(enemy_pos) < enemy_hit_radius * enemy_hit_radius:
				var push_dir: Vector2 = (enemy_pos - player_pos).normalized()
				var knockback_value: float = float(context["knockback"]) if is_main_orbit else scaled_knockback(float(weapon.get("knockback", 0.0)))
				var hit_result := _apply_enemy_hit(enemy, damage, push_dir, knockback_value * 0.45, killed_enemies, hit_effects, barrier_hit_requests, evolved_owner_id)
				if hit_result == HIT_DAMAGED:
					_request_weapon_hit_reaction(result, weapon, 1)
				hit_memory[hit_key] = elapsed + hit_interval
				if is_maro_ring:
					var maro_hit_fx := _maro_comment_hit_fx(enemy_pos)
					if evolved_owner_id != "":
						maro_hit_fx["owner"] = evolved_owner_id
						maro_hit_fx["weaponId"] = evolved_owner_id
					hit_effects.append(maro_hit_fx)
				else:
					var orbit_hit_fx := {"pos": pos, "dir": push_dir, "life": 0.14, "range": 36.0, "hit": enemy_pos, "count": 1}
					_tag_hit_effects_for_weapon([orbit_hit_fx], 0, evolved_owner_id)
					hit_effects.append(orbit_hit_fx)
		for box_item in destructibles:
			var box: Dictionary = box_item as Dictionary
			if float(box.get("hp", 0.0)) <= 0.0:
				continue
			var box_id: String = "box_%d" % int(box.get("uid", 0))
			var box_hit_key: String = "%d:%s" % [i, box_id] if evolved_owner_id == "" else "%s|%d|box:%d" % [weapon_id, i, int(box.get("uid", 0))]
			if float(hit_memory.get(box_hit_key, 0.0)) > elapsed:
				continue
			var box_pos: Vector2 = Vector2(box["pos"])
			var box_hit_radius: float = float(box.get("radius", 24.0)) + hit_radius
			if pos.distance_squared_to(box_pos) < box_hit_radius * box_hit_radius:
				hit_memory[box_hit_key] = elapsed + hit_interval
				DestructibleSystemScript.damage_box(box, 1.0, destroyed_boxes, hit_effects)
	result["boomerangHits"] = hit_memory
	return result


static func _update_side_ban_judgement_weapon(
	weapon: Dictionary,
	context: Dictionary,
	entry: Dictionary,
	timers: Dictionary,
	hit_effects: Array,
	killed_enemies: Array,
	destroyed_boxes: Array,
	barrier_hit_requests: Array
) -> Dictionary:
	var result := _stage2_empty_result()
	var weapon_id := String(weapon.get("id", "ban_judgement"))
	var delta := float(context.get("delta", 0.0))
	var timer := float(timers.get(weapon_id, 0.0)) - delta
	if timer > 0.0:
		timers[weapon_id] = timer
		return result
	if bool(context.get("normalWeaponsDisabled", false)):
		timers[weapon_id] = 0.0
		return result
	var interval := player_attack_interval(attack_interval(weapon, 1.0), float(context.get("intervalRate", 1.0)))
	timers[weapon_id] = maxf(0.18, interval)
	var player_pos: Vector2 = Vector2(context["playerPos"])
	var attack_dir := _direction_with_attack_right_only(Vector2(context["facingDir"]).normalized(), context)
	var area_rate := attack_area_rate(context)
	var base_range := maxf(1.0, range_base(weapon))
	var range_value := _short_range_range_for_weapon(weapon_id, weapon, base_range * float(context.get("rangeRate", 1.0)), context)
	var effective_range := range_value * area_rate
	var inherited_range_rate := effective_range / base_range
	var fx_start := hit_effects.size()
	var judgement_result := _apply_ban_judgement_attack(
		weapon,
		context["enemies"] as Array,
		context["destructibles"] as Array,
		context["enemyBullets"] as Array,
		player_pos,
		attack_dir,
		effective_range,
		float(weapon.get("arcAngle", 145.0)),
		float(weapon.get("damage", 36.0)) * float(context.get("damageRate", 1.0)),
		scaled_knockback(float(weapon.get("knockback", 4.4))),
		inherited_range_rate * _short_range_projectile_rate(context),
		inherited_range_rate * _short_range_area_rate(context) * area_rate,
		killed_enemies,
		destroyed_boxes,
		hit_effects,
		barrier_hit_requests
	)
	_tag_hit_effects_for_weapon(hit_effects, fx_start, weapon_id)
	var swing_hits := int(judgement_result.get("swingHits", 0))
	var swing_enemy_hits := int(judgement_result.get("swingEnemyHits", swing_hits))
	if swing_hits > 0:
		_request_weapon_hit_reaction(result, weapon, swing_hits, swing_enemy_hits)
		(result["chat"] as Array).append("BANジャッジメント命中！")
	return result


static func _update_side_starlight_weapon(
	weapon: Dictionary,
	context: Dictionary,
	timers: Dictionary,
	bullets: Array
) -> Dictionary:
	var result: Dictionary = {"superchatShotFired": false}
	var weapon_id := String(weapon.get("id", "starlight_superchat"))
	var delta := float(context.get("delta", 0.0))
	var timer := float(timers.get(weapon_id, 0.0)) - delta
	if timer > 0.0:
		timers[weapon_id] = timer
		return result
	if bool(context.get("normalWeaponsDisabled", false)):
		timers[weapon_id] = 0.0
		return result
	var interval := player_attack_interval(attack_interval(weapon, 0.5), float(context.get("intervalRate", 1.0)))
	timers[weapon_id] = maxf(0.18, interval)
	var player_pos: Vector2 = Vector2(context["playerPos"])
	var target: Variant = nearest_enemy(context["enemies"] as Array, player_pos)
	if target == null:
		return result
	var target_pos: Vector2 = Vector2((target as Dictionary).get("pos", player_pos))
	var range_value := _short_range_range_for_weapon(weapon_id, weapon, range_base(weapon) * float(context.get("rangeRate", 1.0)), context)
	if player_pos.distance_squared_to(target_pos) > range_value * range_value:
		return result
	var dir := (target_pos - player_pos).normalized()
	if dir.length() < 0.1:
		dir = Vector2.RIGHT
	var weapon_timers: Dictionary = timers
	weapon_timers[STARLIGHT_SHOT_COUNTER_KEY] = int(weapon_timers.get(STARLIGHT_SHOT_COUNTER_KEY, 0)) + 1
	var base_damage := float(weapon.get("damage", 10.0)) * float(context.get("damageRate", 1.0))
	var speed := scaled_projectile_speed(float(weapon.get("projectileSpeed", 9.5)))
	var projectile_count := maxi(1, int(weapon.get("projectileCount", 3))) + int(context.get("bulletSupportLevel", 0))
	var spread_rad := deg_to_rad(float(weapon.get("projectileSpreadDegrees", 12.0)))
	var area_rate := attack_area_rate(context)
	for shot_index in range(projectile_count):
		var shot_dir := _spread_direction(dir, shot_index, projectile_count, spread_rad)
		var bullet := _starlight_bullet_data(weapon, player_pos, shot_dir, speed, range_value / maxf(1.0, speed), base_damage, shot_index, projectile_count, weapon_timers)
		bullet["hitRadius"] = float(bullet.get("hitRadius", 7.0)) * area_rate
		bullet["visualScale"] = area_rate
		bullets.append(bullet)
	result["superchatShotFired"] = true
	return result


static func _update_side_maro_comment_ring(
	weapon: Dictionary,
	context: Dictionary,
	timers: Dictionary,
	boomerang_hits: Dictionary
) -> Dictionary:
	var side_context: Dictionary = context.duplicate()
	side_context["weapon"] = weapon
	side_context["weaponType"] = "orbit"
	side_context["isMainOrbit"] = false
	side_context["boomerangLevel"] = 0
	side_context["weaponTimers"] = timers
	side_context["boomerangHits"] = boomerang_hits
	side_context["range"] = range_base(weapon) * float(context.get("rangeRate", 1.0))
	side_context["damage"] = float(weapon.get("damage", 15.0)) * float(context.get("damageRate", 1.0))
	side_context["knockback"] = scaled_knockback(float(weapon.get("knockback", 0.3)))
	return update_boomerang(side_context)


static func _update_initial_evolved_side_weapon(
	weapon: Dictionary,
	entry: Dictionary,
	context: Dictionary,
	player_weapons: Array,
	weapon_data: Array,
	timers: Dictionary,
	hit_effects: Array,
	killed_enemies: Array,
	destroyed_boxes: Array,
	barrier_hit_requests: Array,
	player_bullets: Array,
	boomerang_hits: Dictionary
) -> Dictionary:
	var result := _stage2_empty_result()
	var base_id := String(weapon.get("baseWeaponId", ""))
	var resolved := resolve_equipped_weapon_for_base(base_id, context.get("mainWeapon", {}) as Dictionary, player_weapons, weapon_data)
	if not bool(resolved.get("found", false)) or bool(resolved.get("isMain", false)):
		return result
	if String(resolved.get("weaponId", "")) != String(entry.get("id", "")):
		return result
	match _initial_evolved_runtime_kind(weapon):
		"melee_shockwave":
			return _update_side_ban_judgement_weapon(weapon, context, entry, timers, hit_effects, killed_enemies, destroyed_boxes, barrier_hit_requests)
		"starlight_projectile":
			var projectile_result := _update_side_starlight_weapon(weapon, context, timers, player_bullets)
			for key in projectile_result.keys():
				result[key] = projectile_result[key]
			return result
		"maro_orbit":
			return _update_side_maro_comment_ring(weapon, context, timers, boomerang_hits)
	return result

static func update_equipment_weapons(context: Dictionary) -> Dictionary:
	var result: Dictionary = {"timers": context["timers"], "playerBullets": context.get("playerBullets", []), "boomerangHits": context.get("boomerangHits", {}), "superchatShotFired": false, "boomerangOrbitSe": false, "hitFx": [], "killed": [], "destroyedBoxes": [], "chat": [], "barrierHitRequests": []}
	var timers: Dictionary = result["timers"] as Dictionary
	var hit_effects: Array = result["hitFx"] as Array
	var killed_enemies: Array = result["killed"] as Array
	var destroyed_boxes: Array = result["destroyedBoxes"] as Array
	var barrier_hit_requests: Array = result["barrierHitRequests"] as Array
	var chat_events: Array = result["chat"] as Array
	var delta: float = float(context["delta"])
	var weapon_data: Array = context["weaponData"] as Array
	var player_weapons: Array = context["playerWeapons"] as Array
	var main_weapon: Dictionary = context.get("mainWeapon", {}) as Dictionary
	var main_weapon_id: String = String(context.get("mainWeaponId", ""))
	var player_pos: Vector2 = Vector2(context["playerPos"])
	var facing_dir: Vector2 = Vector2(context["facingDir"]).normalized()
	if facing_dir.length() < 0.1:
		facing_dir = Vector2.RIGHT
	var enemies: Array = context["enemies"] as Array
	var destructibles: Array = context["destructibles"] as Array
	var enemy_bullets: Array = context["enemyBullets"] as Array
	var player_bullets: Array = context.get("playerBullets", []) as Array
	var boomerang_hits: Dictionary = context.get("boomerangHits", {}) as Dictionary
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
		if _initial_evolved_runtime_kind(weapon) != "":
			var initial_result := _update_initial_evolved_side_weapon(
				weapon,
				entry,
				context,
				player_weapons,
				weapon_data,
				timers,
				hit_effects,
				killed_enemies,
				destroyed_boxes,
				barrier_hit_requests,
				player_bullets,
				boomerang_hits
			)
			result["playerBullets"] = player_bullets
			result["boomerangHits"] = initial_result.get("boomerangHits", result.get("boomerangHits", boomerang_hits))
			result["superchatShotFired"] = bool(result.get("superchatShotFired", false)) or bool(initial_result.get("superchatShotFired", false))
			result["boomerangOrbitSe"] = bool(result.get("boomerangOrbitSe", false)) or bool(initial_result.get("boomerangOrbitSe", false))
			_merge_weapon_result(result, initial_result)
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
		var standard_stats := codex_standard_stats_for_level(weapon, level_value, false)
		var damage: float = float(standard_stats.get("damage", float(weapon.get("damage", 4.0)))) * float(context["damageRate"])
		var range_value: float = float(standard_stats.get("range", range_base(weapon))) * float(context["rangeRate"])
		var base_interval: float = float(standard_stats.get("attackInterval", attack_interval(weapon, 1.0)))
		var interval: float = player_attack_interval(base_interval, float(context["intervalRate"]))
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

const ROD_COLLECTION_ACTIVE_STATES := ["attracted_to_lure", "attached_to_lure", "returning_with_lure"]

static func rod_collection_config_for_level(weapon: Dictionary, level: int = 1) -> Dictionary:
	var source: Dictionary = weapon.get("itemCollection", {}) as Dictionary
	var resolved: Dictionary = source.duplicate(true)
	var levels: Array = source.get("levels", []) as Array
	if not levels.is_empty():
		var row_value: Variant = levels[clampi(maxi(1, level) - 1, 0, levels.size() - 1)]
		if row_value is Dictionary:
			for key in (row_value as Dictionary).keys():
				resolved[String(key)] = (row_value as Dictionary)[key]
	resolved.erase("levels")
	return resolved

static func _rod_item_claim_active(item: Dictionary) -> bool:
	return ROD_COLLECTION_ACTIVE_STATES.has(String(item.get("rodCollectionState", "free")))

static func _rod_item_claimable(item: Dictionary, whitelist: Array, collection_kind: String) -> bool:
	if item.is_empty() or float(item.get("life", 1.0)) <= 0.0:
		return false
	var state := String(item.get("rodCollectionState", "free"))
	if state != "free" and state != "":
		return false
	if String(item.get("rodClaimToken", "")) != "":
		return false
	if bool(item.get("collected", false)) or bool(item.get("followingPlayer", false)) or bool(item.get("homingToPlayer", false)):
		return false
	var item_type := _rod_collectible_type(collection_kind, item)
	return item_type != "" and whitelist.has(item_type)

static func _rod_collectible_type(collection_kind: String, item: Dictionary) -> String:
	if collection_kind == "experience":
		return "experience"
	if collection_kind != "drop_items":
		return ""
	match String(item.get("id", "")):
		"viewer_boost":
			return "score"
		"heal_drink":
			return "heal"
		"heart_drop":
			return "heart"
		_:
			return ""

static func _rod_next_claim_token(weapon_id: String, timers: Dictionary) -> String:
	var states := _stage2_states(timers)
	var state: Dictionary = states.get(weapon_id, {}) as Dictionary
	var serial := int(state.get("collectionSerial", 0)) + 1
	state["collectionSerial"] = serial
	states[weapon_id] = state
	return "%s:collect:%d" % [weapon_id, serial]

static func _rod_collection_radius(config: Dictionary, context: Dictionary) -> float:
	var radius := maxf(0.0, float(config.get("attractRadius", 0.0)))
	return _apply_short_range(context, radius, 0.75, 0.85, 0.0)

static func rod_collection_effective_return_speed(weapon: Dictionary, context: Dictionary) -> float:
	var config := rod_collection_config_for_level(weapon, int(weapon.get("level", 1)))
	var base_speed := float(weapon.get("reelSpeed", config.get("attractSpeed", 0.0)))
	var reel_multiplier := float(weapon.get("reelSpeedMultiplier", 1.0))
	if bool(weapon.get("isEvolved", false)):
		var base_id := String(weapon.get("baseWeaponId", ""))
		var base_weapon := find_weapon(context.get("weaponData", []) as Array, base_id, {})
		if not base_weapon.is_empty():
			var base_level_five := _stage2_level_data(base_weapon, int(base_weapon.get("maxLevel", 5)))
			base_speed = float(base_level_five.get("reelSpeed", base_speed))
			reel_multiplier = float(base_level_five.get("reelSpeedMultiplier", 1.0))
	return maxf(0.0, base_speed * reel_multiplier * float(config.get("returnSpeedRate", 1.0)))

static func _rod_claim_collectibles_at_landing(fx: Dictionary, exp_orbs: Array, drop_items: Array) -> void:
	# The cast FX is created at the player's position.  Searching before the lure
	# lands consumes the one-shot search around the player instead of the landing
	# point, so keep the search pending until the gathering phase starts.
	if fx.get("phase", "casting") != "gathering":
		return
	if bool(fx.get("itemSearchDone", false)):
		return
	fx["itemSearchDone"] = true
	var config: Dictionary = fx.get("itemCollectionConfig", {}) as Dictionary
	if not bool(config.get("enabled", false)):
		return
	var whitelist: Array = config.get("collectibleWhitelist", []) as Array
	var radius := float(fx.get("itemAttractRadius", config.get("attractRadius", 0.0)))
	var lure_pos := Vector2(fx.get("pos", Vector2.ZERO))
	var token := String(fx.get("collectionClaimToken", ""))
	if token == "":
		return
	var claims: Array = fx.get("claimedCollectibles", []) as Array
	var attach_index := 0
	for source in [{"kind": "experience", "items": exp_orbs}, {"kind": "drop_items", "items": drop_items}]:
		var collection_kind := String(source["kind"])
		var items: Array = source["items"] as Array
		for item_value in items:
			var item: Dictionary = item_value as Dictionary
			if not _rod_item_claimable(item, whitelist, collection_kind):
				continue
			if Vector2(item.get("pos", lure_pos)).distance_to(lure_pos) > radius:
				continue
			item["rodCollectionState"] = "attracted_to_lure"
			item["rodClaimToken"] = token
			item["rodAttachIndex"] = attach_index
			var scatter_angle := TAU * float(attach_index) * 0.61803398875
			var scatter_radius := 9.0 + float(attach_index % 4) * 4.0
			claims.append({"item": item, "collectionKind": collection_kind, "attachIndex": attach_index, "scatterOffset": Vector2.RIGHT.rotated(scatter_angle) * scatter_radius})
			attach_index += 1
	fx["claimedCollectibles"] = claims
	fx["itemClaimedCount"] = claims.size()

static func _rod_update_collection_visuals(fx: Dictionary, lure_pos: Vector2) -> void:
	var config: Dictionary = fx.get("itemCollectionConfig", {}) as Dictionary
	var claims: Array = fx.get("claimedCollectibles", []) as Array
	var line_cap := maxi(0, int(config.get("maxVisualLines", 6)))
	var lines: Array = []
	var particles: Array = []
	var line_color := Color(String(config.get("lineColor", "#8df9e8")))
	var particle_color := Color(String(config.get("particleColor", "#b7fff3")))
	for index in range(claims.size()):
		var claim: Dictionary = claims[index] as Dictionary
		var item: Dictionary = claim.get("item", {}) as Dictionary
		if item.is_empty() or String(item.get("rodClaimToken", "")) != String(fx.get("collectionClaimToken", "")):
			continue
		var item_pos := Vector2(item.get("pos", lure_pos))
		if index < line_cap:
			lines.append({"from": item_pos, "to": lure_pos, "color": line_color, "width": float(config.get("lineWidth", 1.6)), "alpha": float(config.get("lineAlpha", 0.62)), "drawLayer": "back", "role": "collection"})
		if particles.size() < line_cap * 2 and (String(item.get("rodCollectionState", "")) == "attached_to_lure" or String(item.get("rodCollectionState", "")) == "returning_with_lure"):
			particles.append({"pos": item_pos, "radius": 3.0, "color": particle_color, "alpha": float(config.get("particleAlpha", 0.78)), "drawLayer": "front", "role": "collection"})
	fx["collectionLines"] = lines
	fx["collectionParticles"] = particles

static func _rod_transfer_claimed_collectibles_to_normal_pickup(fx: Dictionary, player_pos: Vector2) -> void:
	var token := String(fx.get("collectionClaimToken", ""))
	var claims: Array = fx.get("claimedCollectibles", []) as Array
	var attach_distance := maxf(1.0, float((fx.get("itemCollectionConfig", {}) as Dictionary).get("attachDistance", 16.0)))
	for claim_value in claims:
		var claim: Dictionary = claim_value as Dictionary
		var item: Dictionary = claim.get("item", {}) as Dictionary
		if item.is_empty() or String(item.get("rodClaimToken", "")) != token:
			continue
		var offset := Vector2(claim.get("scatterOffset", Vector2.ZERO))
		item["pos"] = player_pos + offset.limit_length(attach_distance)
		item["rodCollectionState"] = "homing_to_player"
		item.erase("rodClaimToken")
		item.erase("rodAttachIndex")
	fx["claimedCollectibles"] = []
	fx["collectionLines"] = []
	fx["collectionParticles"] = []
	fx["collectionReturned"] = true

static func _rod_release_claimed_collectibles(fx: Dictionary) -> void:
	var token := String(fx.get("collectionClaimToken", ""))
	for claim_value in (fx.get("claimedCollectibles", []) as Array):
		var claim: Dictionary = claim_value as Dictionary
		var item: Dictionary = claim.get("item", {}) as Dictionary
		if item.is_empty() or String(item.get("rodClaimToken", "")) != token:
			continue
		item["rodCollectionState"] = "free"
		item.erase("rodClaimToken")
		item.erase("rodAttachIndex")
	fx["claimedCollectibles"] = []
	fx["collectionLines"] = []
	fx["collectionParticles"] = []

static func _rod_update_claimed_collectibles(fx: Dictionary, delta: float, player_pos: Vector2) -> void:
	var claims: Array = fx.get("claimedCollectibles", []) as Array
	if claims.is_empty():
		return
	var phase := String(fx.get("phase", ""))
	var config: Dictionary = fx.get("itemCollectionConfig", {}) as Dictionary
	var lure_pos := Vector2(fx.get("pos", Vector2.ZERO))
	var attach_distance := maxf(1.0, float(config.get("attachDistance", 16.0)))
	fx["itemAttractElapsed"] = float(fx.get("itemAttractElapsed", 0.0)) + maxf(0.0, delta)
	if phase == "reeling":
		for claim_value in claims:
			var claim: Dictionary = claim_value as Dictionary
			var item: Dictionary = claim.get("item", {}) as Dictionary
			# Items that already reached the lure stay rigidly attached during the
			# reel. Only items that are still approaching need catch-up movement.
			if not item.is_empty() and String(item.get("rodCollectionState", "free")) == "attracted_to_lure":
				item["rodCollectionState"] = "returning_with_lure"
		if lure_pos.distance_to(player_pos) <= attach_distance:
			_rod_transfer_claimed_collectibles_to_normal_pickup(fx, player_pos)
			return
	var speed := maxf(0.0, float(config.get("attractSpeed", 0.0)))
	var catchup_rate := maxf(1.0, float(config.get("returnCatchupRate", 1.0)))
	var return_speed := maxf(0.0, maxf(float(fx.get("itemReturnSpeed", speed)), float(fx.get("reelSpeed", 0.0)) * catchup_rate))
	for claim_value in claims:
		var claim: Dictionary = claim_value as Dictionary
		var item: Dictionary = claim.get("item", {}) as Dictionary
		if item.is_empty() or String(item.get("rodClaimToken", "")) != String(fx.get("collectionClaimToken", "")):
			continue
		var state := String(item.get("rodCollectionState", "free"))
		var scatter := Vector2(claim.get("scatterOffset", Vector2.ZERO))
		if state == "attracted_to_lure":
			var item_pos := Vector2(item.get("pos", lure_pos))
			item_pos = item_pos.move_toward(lure_pos, speed * maxf(0.0, delta))
			item["pos"] = item_pos
			if item_pos.distance_to(lure_pos) <= attach_distance:
				item["rodCollectionState"] = "attached_to_lure"
		elif state == "attached_to_lure":
			item["pos"] = lure_pos + scatter
		elif state == "returning_with_lure":
			item["pos"] = Vector2(item.get("pos", lure_pos)).move_toward(lure_pos + scatter, return_speed * maxf(0.0, delta))
	_rod_update_collection_visuals(fx, lure_pos)

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

static func stage2_level_data(weapon: Dictionary, level: int = 1) -> Dictionary:
	return _stage2_level_data(weapon, level)

static func fansa_attack_shape(weapon: Dictionary, level: int = 1, context: Dictionary = {}) -> Dictionary:
	var weapon_id := String(weapon.get("id", ""))
	var safe_level := maxi(1, level)
	var radius := float(weapon.get("fanRadius", weapon.get("normalRange", 110.0)))
	var arc_degrees := float(weapon.get("fanArcDegrees", weapon.get("normalArcAngle", 130.0)))
	var origin_offset := float(weapon.get("attackOriginOffset", 25.0))
	var duration := float(weapon.get("hitboxDuration", 0.18))
	if weapon_id == "fansa_baton":
		var shape_levels: Array = weapon.get("fanShapeLevels", []) as Array
		if not shape_levels.is_empty():
			var shape_value: Variant = shape_levels[clampi(safe_level - 1, 0, shape_levels.size() - 1)]
			if shape_value is Dictionary:
				var shape := shape_value as Dictionary
				radius = float(shape.get("radius", radius))
				arc_degrees = float(shape.get("arcDegrees", arc_degrees))
				origin_offset = float(shape.get("originOffset", origin_offset))
				duration = float(shape.get("hitboxDuration", duration))
	var coverage := _stage2_coverage_rate(context)
	var final_radius := _short_range_range_for_weapon(weapon_id, weapon, maxf(0.0, radius) * coverage, context)
	return {
		"radius": maxf(0.0, final_radius),
		"arcDegrees": clampf(arc_degrees, 0.0, 360.0),
		"originOffset": maxf(0.0, origin_offset),
		"hitboxDuration": maxf(0.01, duration),
		"useHurtboxOverlap": bool(weapon.get("useHurtboxOverlap", true)),
		"autoLunge": bool(weapon.get("autoLunge", false)),
		"coverageRate": coverage
	}

static func fan_sector_circle_overlap(origin: Vector2, direction: Vector2, radius: float, arc_degrees: float, target_center: Vector2, target_radius: float = 0.0) -> bool:
	var safe_radius := maxf(0.0, radius)
	var safe_target_radius := maxf(0.0, target_radius)
	var offset := target_center - origin
	var center_distance := offset.length()
	if center_distance <= safe_target_radius:
		return true
	if center_distance > safe_radius + safe_target_radius:
		return false
	if safe_radius <= 0.0:
		return false
	var safe_direction := direction.normalized()
	if safe_direction.length() < 0.1:
		safe_direction = Vector2.RIGHT
	var half_arc := deg_to_rad(clampf(arc_degrees, 0.0, 360.0) * 0.5)
	if half_arc >= PI - 0.0001:
		return true
	var angular_margin := asin(clampf(safe_target_radius / maxf(0.0001, center_distance), 0.0, 1.0))
	return safe_direction.dot(offset / center_distance) >= cos(minf(PI, half_arc + angular_margin))

static func _fansa_attack_origin(player_pos: Vector2, direction: Vector2, origin_offset: float) -> Vector2:
	var safe_direction := direction.normalized()
	if safe_direction.length() < 0.1:
		safe_direction = Vector2.RIGHT
	return player_pos + safe_direction * maxf(0.0, origin_offset)

static func _fansa_fallback_direction(context: Dictionary) -> Vector2:
	if bool(context.get("attackRightOnly", false)):
		return Vector2.RIGHT
	var candidates: Array = [
		context.get("moveInput", Vector2.ZERO),
		context.get("playerVel", Vector2.ZERO),
		context.get("lastMoveDirection", context.get("lastDir", Vector2.ZERO)),
		context.get("facingDir", Vector2.ZERO)
	]
	for value in candidates:
		var candidate := Vector2(value)
		if candidate.length() > 0.1:
			return candidate.normalized()
	return Vector2.RIGHT

static func _fansa_target_direction(enemy: Dictionary, player_pos: Vector2, fallback: Vector2) -> Vector2:
	var direction := (Vector2(enemy.get("pos", player_pos)) - player_pos).normalized()
	if direction.length() < 0.1:
		return fallback
	return direction

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

static func _stage2_result_with_visuals(result: Dictionary, weapon: Dictionary) -> Dictionary:
	var visuals: Dictionary = weapon.get("visuals", {}) as Dictionary
	if visuals.is_empty():
		return result
	for fx_item in (result.get("hitFx", []) as Array):
		var fx: Dictionary = fx_item as Dictionary
		if not fx.has("visuals"):
			fx["visuals"] = visuals.duplicate(true)
	return result

static func _update_stage2_weapon(weapon: Dictionary, entry: Dictionary, context: Dictionary, timers: Dictionary, hit_effects: Array, killed_enemies: Array, barrier_hit_requests: Array) -> Dictionary:
	var weapon_id := String(weapon.get("id", ""))
	var max_level := maxi(1, int(weapon.get("maxLevel", 1)))
	var level := clampi(int(entry.get("level", 1)), 1, max_level)
	var level_weapon := _stage2_weapon_with_inherited_visuals(stage2_level_data(weapon, level), context)
	var behavior := _stage2_behavior(level_weapon)
	var result: Dictionary = _stage2_empty_result()
	if behavior in ["moderator_shield", "front_shield"]:
		result = _update_moderator_shield_weapon(level_weapon, context, timers)
	elif behavior == "fansa_baton":
		result = _update_fansa_baton_weapon(level_weapon, entry, context, timers)
	elif behavior == "tsuri_thumbnail_rod":
		result = _update_tsuri_rod_weapon(level_weapon, context, timers)
	elif behavior == "moderator_fortress":
		result = _update_moderator_fortress_weapon(level_weapon, context, timers)
	elif behavior == "fansa_climax":
		result = _update_fansa_climax_weapon(level_weapon, context, timers)
	elif behavior == "buzz_thumbnail_rod":
		result = _update_buzz_thumbnail_rod_weapon(level_weapon, context, timers)
	elif behavior == "full_voice_dome":
		result = _update_full_voice_dome_weapon(level_weapon, context, timers)
	elif behavior == "center_stage":
		result = _update_center_stage_weapon(level_weapon, context, timers)
	elif behavior == "great_grassland":
		result = _update_great_grassland_weapon(level_weapon, context, timers)
	elif behavior == "comment_lockdown":
		result = _update_comment_lockdown_weapon(level_weapon, context, timers)
	elif behavior == "emote_festival":
		result = _update_emote_festival_weapon(level_weapon, context, timers)
	elif behavior == "all_block_laser":
		result = _update_all_block_laser_weapon(level_weapon, context, timers)
	elif behavior == "listener_assembly":
		result = _update_listener_assembly_weapon(level_weapon, context, timers)
	return _stage2_result_with_visuals(result, level_weapon)

static func _stage2_source_weapon(weapon: Dictionary, context: Dictionary) -> Dictionary:
	var source_id := String(weapon.get("visualSourceWeaponId", ""))
	if source_id == "":
		return {}
	return find_weapon(context.get("weaponData", []) as Array, source_id, {})

static func _stage2_clear_bullet_fx(pos: Vector2, owner_id: String) -> Dictionary:
	return {
		"kind": "stage2_bullet_clear",
		"owner": owner_id,
		"weaponId": owner_id,
		"pos": pos,
		"life": 0.18,
		"maxLife": 0.18
	}

static func _stage2_clear_enemy_bullets_in_circle(enemy_bullets: Array, center: Vector2, radius: float, hit_effects: Array, owner_id: String) -> int:
	var cleared := 0
	for bullet_item in enemy_bullets:
		var bullet: Dictionary = bullet_item as Dictionary
		if float(bullet.get("life", 0.0)) <= 0.0 or not _stage2_shield_bullet_clearable(bullet):
			continue
		var bullet_pos := Vector2(bullet.get("pos", Vector2.ZERO))
		var hit_range := radius + float(bullet.get("hitRadius", 16.0))
		if bullet_pos.distance_squared_to(center) > hit_range * hit_range:
			continue
		bullet["life"] = -1.0
		hit_effects.append(_stage2_clear_bullet_fx(bullet_pos, owner_id))
		cleared += 1
	return cleared

static func _update_full_voice_dome_weapon(weapon: Dictionary, context: Dictionary, timers: Dictionary) -> Dictionary:
	var result := _stage2_empty_result()
	var weapon_id := String(weapon.get("id", "full_voice_dome"))
	var delta := float(context.get("delta", 0.0))
	var attack_timer := float(timers.get(weapon_id, 0.0)) - delta
	var states := _stage2_states(timers)
	var state: Dictionary = states.get(weapon_id, {}) as Dictionary
	var pulse_timer := float(state.get("pulseTimer", 0.0)) - delta
	if bool(context.get("normalWeaponsDisabled", false)) or bool(context.get("weaponMute", false)):
		timers[weapon_id] = 0.0
		state["pulseTimer"] = 0.0
		states[weapon_id] = state
		return result
	var player_pos := Vector2(context.get("playerPos", Vector2.ZERO))
	var coverage := _stage2_coverage_rate(context)
	var enemies: Array = context.get("enemies", []) as Array
	var destructibles: Array = context.get("destructibles", []) as Array
	var enemy_bullets: Array = context.get("enemyBullets", []) as Array
	var killed: Array = result["killed"] as Array
	var destroyed: Array = result["destroyedBoxes"] as Array
	var hit_effects: Array = result["hitFx"] as Array
	var barriers: Array = result["barrierHitRequests"] as Array
	var damage_rate := float(context.get("damageRate", 1.0))
	if attack_timer <= 0.0:
		var radius := float(weapon.get("radius", 0.0)) * coverage
		var damage := float(weapon.get("damage", weapon.get("baseDamage", 0.0))) * damage_rate
		var enemy_hits := _apply_circle_damage(enemies, player_pos, radius, damage, float(weapon.get("knockback", 0.0)), killed, hit_effects, barriers, weapon_id)
		_apply_circle_damage_to_boxes(destructibles, player_pos, radius, destroyed, hit_effects, weapon_id)
		_stage2_clear_enemy_bullets_in_circle(enemy_bullets, player_pos, radius, hit_effects, weapon_id)
		if enemy_hits > 0:
			_merge_reaction_result(result, {"enemyDamaged": true, "weaponCommentKind": weapon_comment_kind_for_id(weapon_id)})
		hit_effects.append({
			"kind": "full_voice_dome_wave", "owner": weapon_id, "weaponId": weapon_id,
			"pos": player_pos, "radius": radius, "hitCount": enemy_hits,
			"life": 0.42, "maxLife": 0.42
		})
		attack_timer = _stage2_interval(weapon, context, 0.0)
	if pulse_timer <= 0.0:
		var pulse_radius := float(weapon.get("pulseRadius", 0.0)) * coverage
		var pulse_damage := float(weapon.get("pulseDamage", 0.0)) * damage_rate
		var pulse_knockback := float(weapon.get("pulseKnockback", 0.0))
		var pulse_hits := _apply_circle_damage(enemies, player_pos, pulse_radius, pulse_damage, pulse_knockback, killed, hit_effects, barriers, weapon_id)
		_apply_circle_damage_to_boxes(destructibles, player_pos, pulse_radius, destroyed, hit_effects, weapon_id)
		_stage2_clear_enemy_bullets_in_circle(enemy_bullets, player_pos, pulse_radius, hit_effects, weapon_id)
		if pulse_hits > 0:
			_merge_reaction_result(result, {"enemyDamaged": true, "weaponCommentKind": weapon_comment_kind_for_id(weapon_id)})
		hit_effects.append({
			"kind": "full_voice_dome_pulse", "owner": weapon_id, "weaponId": weapon_id,
			"pos": player_pos, "radius": pulse_radius, "hitCount": pulse_hits,
			"life": 0.48, "maxLife": 0.48
		})
		pulse_timer = player_attack_interval(float(weapon.get("pulseInterval", 0.0)), float(context.get("intervalRate", 1.0)))
	timers[weapon_id] = attack_timer
	state["pulseTimer"] = pulse_timer
	states[weapon_id] = state
	return result

static func _center_stage_target_center(weapon: Dictionary, context: Dictionary) -> Vector2:
	var player_pos := Vector2(context.get("playerPos", Vector2.ZERO))
	var fallback := _direction_with_attack_right_only(Vector2(context.get("facingDir", Vector2.RIGHT)), context)
	if fallback.length() < 0.1:
		fallback = Vector2.RIGHT
	var placement_range := scaled_range(float(weapon.get("placementRange", 0.0))) * float(context.get("rangeRate", 1.0))
	placement_range = _apply_short_range(context, placement_range, 0.60, 0.75, SHORT_RANGE_MIN_PROJECTILE_RANGE)
	var radius := float(weapon.get("radius", 0.0)) * _stage2_coverage_rate(context)
	var best: Dictionary = {}
	var best_count := -1
	var best_distance := INF
	var best_token := ""
	for candidate_value in context.get("enemies", []) as Array:
		var candidate: Dictionary = candidate_value as Dictionary
		if not _stage2_alive_enemy(candidate):
			continue
		var candidate_pos := Vector2(candidate.get("pos", player_pos))
		var player_distance := player_pos.distance_to(candidate_pos)
		if player_distance > placement_range + float(candidate.get("radius", 20.0)):
			continue
		var count := 0
		for member_value in context.get("enemies", []) as Array:
			var member: Dictionary = member_value as Dictionary
			if not _stage2_alive_enemy(member):
				continue
			if candidate_pos.distance_to(Vector2(member.get("pos", candidate_pos))) <= radius + float(member.get("radius", 20.0)):
				count += 1
		var token := _stage2_entity_token(candidate)
		var better := count > best_count
		if count == best_count and player_distance < best_distance - 0.001:
			better = true
		if count == best_count and is_equal_approx(player_distance, best_distance) and (best_token == "" or token < best_token):
			better = true
		if better:
			best = candidate
			best_count = count
			best_distance = player_distance
			best_token = token
	if not best.is_empty():
		return Vector2(best.get("pos", player_pos))
	return player_pos + fallback * placement_range

static func _center_stage_apply_area(fx: Dictionary, damage_key: String, enemies: Array, destructibles: Array, enemy_bullets: Array, killed_enemies: Array, destroyed_boxes: Array, hit_effects: Array, feedback: Dictionary) -> int:
	var center := Vector2(fx.get("pos", Vector2.ZERO))
	var radius := float(fx.get("radius", 0.0))
	var damage := float(fx.get(damage_key, 0.0))
	var weapon_id := String(fx.get("weaponId", "center_stage"))
	var hits := _apply_circle_damage(enemies, center, radius, damage, 0.0, killed_enemies, hit_effects, feedback.get("barrierHitRequests", []) as Array, weapon_id)
	_apply_circle_damage_to_boxes(destructibles, center, radius, destroyed_boxes, hit_effects, weapon_id)
	_stage2_clear_enemy_bullets_in_circle(enemy_bullets, center, radius, hit_effects, weapon_id)
	if hits > 0:
		_merge_reaction_result(feedback, {"enemyDamaged": true, "weaponCommentKind": weapon_comment_kind_for_id(weapon_id)})
	return hits

static func _update_center_stage_weapon(weapon: Dictionary, context: Dictionary, timers: Dictionary) -> Dictionary:
	var result := _stage2_empty_result()
	var weapon_id := String(weapon.get("id", "center_stage"))
	var delta := float(context.get("delta", 0.0))
	var timer := float(timers.get(weapon_id, 0.0)) - delta
	if timer > 0.0:
		timers[weapon_id] = timer
		return result
	if bool(context.get("normalWeaponsDisabled", false)) or bool(context.get("weaponMute", false)):
		timers[weapon_id] = 0.0
		return result
	var player_pos := Vector2(context.get("playerPos", Vector2.ZERO))
	var radius := float(weapon.get("radius", 0.0)) * _stage2_coverage_rate(context)
	var duration := float(weapon.get("duration", 0.0))
	var hit_interval := float(weapon.get("hitInterval", 0.0))
	var tick_damage := float(weapon.get("tickDamage", weapon.get("damage", 0.0))) * float(context.get("damageRate", 1.0))
	var finish_damage := float(weapon.get("finishDamage", 0.0)) * float(context.get("damageRate", 1.0))
	var fx := {
		"kind": "center_stage_area", "owner": weapon_id, "weaponId": weapon_id,
		"pos": _center_stage_target_center(weapon, context), "radius": radius,
		"duration": duration, "age": 0.0, "tickCount": 1, "maxTicks": int(weapon.get("maxTicks", 0)),
		"nextTickAt": hit_interval, "hitInterval": hit_interval,
		"tickDamage": tick_damage, "finishDamage": finish_damage,
		"finishFlashDuration": float(weapon.get("finishFlashDuration", 0.0)),
		"finishApplied": false, "life": duration, "maxLife": duration
	}
	var hit_effects: Array = result["hitFx"] as Array
	var initial_hits := _center_stage_apply_area(fx, "tickDamage", context.get("enemies", []) as Array, context.get("destructibles", []) as Array, context.get("enemyBullets", []) as Array, result["killed"] as Array, result["destroyedBoxes"] as Array, hit_effects, result)
	hit_effects.append({"kind": "center_stage_tick", "owner": weapon_id, "weaponId": weapon_id, "pos": fx["pos"], "radius": radius, "tick": 1, "hitCount": initial_hits, "life": 0.22, "maxLife": 0.22})
	hit_effects.append(fx)
	timers[weapon_id] = _stage2_interval(weapon, context, 0.0)
	return result

static func update_center_stage_fx(fx: Dictionary, delta: float, enemies: Array, destructibles: Array, enemy_bullets: Array, killed_enemies: Array, destroyed_boxes: Array, hit_effects: Array, feedback: Dictionary = {}) -> void:
	if bool(fx.get("finishApplied", false)):
		return
	var age := float(fx.get("age", 0.0)) + maxf(0.0, delta)
	fx["age"] = age
	var tick_count := int(fx.get("tickCount", 1))
	var max_ticks := maxi(1, int(fx.get("maxTicks", 0)))
	var next_tick := float(fx.get("nextTickAt", INF))
	var hit_interval := maxf(0.01, float(fx.get("hitInterval", 0.0)))
	while tick_count < max_ticks and age + 0.0001 >= next_tick:
		tick_count += 1
		var hits := _center_stage_apply_area(fx, "tickDamage", enemies, destructibles, enemy_bullets, killed_enemies, destroyed_boxes, hit_effects, feedback)
		hit_effects.append({
			"kind": "center_stage_tick", "owner": String(fx.get("owner", "center_stage")), "weaponId": String(fx.get("weaponId", "center_stage")),
			"pos": fx.get("pos", Vector2.ZERO), "radius": float(fx.get("radius", 0.0)), "tick": tick_count,
			"hitCount": hits, "life": 0.22, "maxLife": 0.22, "visuals": (fx.get("visuals", {}) as Dictionary).duplicate(true)
		})
		next_tick += hit_interval
	fx["tickCount"] = tick_count
	fx["nextTickAt"] = next_tick
	var duration := float(fx.get("duration", fx.get("maxLife", 0.0)))
	if age + 0.0001 < duration:
		return
	var finish_hits := _center_stage_apply_area(fx, "finishDamage", enemies, destructibles, enemy_bullets, killed_enemies, destroyed_boxes, hit_effects, feedback)
	var owner_id := String(fx.get("owner", "center_stage"))
	hit_effects.append({
		"kind": "center_stage_finish", "owner": owner_id, "weaponId": String(fx.get("weaponId", owner_id)),
		"pos": fx.get("pos", Vector2.ZERO), "radius": float(fx.get("radius", 0.0)), "hitCount": finish_hits,
		"life": 0.30, "maxLife": 0.30, "visuals": (fx.get("visuals", {}) as Dictionary).duplicate(true)
	})
	var finish_flash_duration := float(fx.get("finishFlashDuration", 0.0))
	if finish_flash_duration > 0.0:
		feedback["screenFlashDuration"] = maxf(float(feedback.get("screenFlashDuration", 0.0)), finish_flash_duration)
		feedback["screenFlashColor"] = Color(1.0, 1.0, 1.0, 0.24)
	fx["finishApplied"] = true
	fx["life"] = 0.0

static func _update_great_grassland_weapon(weapon: Dictionary, context: Dictionary, timers: Dictionary) -> Dictionary:
	var result := _stage2_empty_result()
	var weapon_id := String(weapon.get("id", "great_grassland"))
	var timer := float(timers.get(weapon_id, 0.0)) - float(context.get("delta", 0.0))
	if timer > 0.0:
		timers[weapon_id] = timer
		return result
	if bool(context.get("normalWeaponsDisabled", false)) or bool(context.get("weaponMute", false)):
		timers[weapon_id] = 0.0
		return result
	var player_pos := Vector2(context.get("playerPos", Vector2.ZERO))
	var base_dir := _kusa_wave_fire_direction(Vector2(context.get("playerVel", Vector2.ZERO)), Vector2(context.get("facingDir", Vector2.RIGHT)), context)
	var count := maxi(1, int(weapon.get("projectileCount", 1)))
	var side_angle := deg_to_rad(float(weapon.get("sideAngleDegrees", 0.0)))
	var max_distance := float(weapon.get("range", 0.0)) * float(context.get("rangeRate", 1.0))
	max_distance = _short_range_range_for_weapon(weapon_id, weapon, max_distance, context)
	var size_scale := float(weapon.get("sizeMultiplier", 1.0))
	var damage := float(weapon.get("damage", weapon.get("baseDamage", 0.0))) * float(context.get("damageRate", 1.0))
	var speed := KUSA_WAVE_SPEED
	var hit_effects: Array = result["hitFx"] as Array
	for index in range(count):
		var direction := _spread_direction(base_dir, index, count, side_angle)
		var start_pos := player_pos + direction * (28.0 + 8.0 * size_scale) + Vector2(0.0, -4.0)
		var max_life := maxf(KUSA_WAVE_MIN_LIFE, max_distance / maxf(1.0, speed) + 0.35)
		hit_effects.append({
			"kind": "great_grassland_wave", "owner": weapon_id, "weaponId": weapon_id,
			"pos": start_pos, "dir": direction, "vel": direction * speed,
			"life": max_life, "maxLife": max_life, "range": max_distance, "maxDistance": max_distance,
			"distanceTraveled": 0.0, "bouncesLeft": int(weapon.get("bounceCount", 0)),
			"sizeScale": size_scale, "count": 1, "damage": damage,
			"knockback": float(weapon.get("knockback", 0.0)) * 0.45,
			"sameEnemyRehit": float(weapon.get("sameEnemyRehit", 0.0)),
			"attackAreaRate": attack_area_rate(context), "hitRadius": 18.0 * size_scale * attack_area_rate(context),
			"hitCooldowns": {}
		})
	timers[weapon_id] = _stage2_interval(weapon, context, 0.0)
	return result

static func _update_comment_lockdown_weapon(weapon: Dictionary, context: Dictionary, timers: Dictionary) -> Dictionary:
	var result := _stage2_empty_result()
	var weapon_id := String(weapon.get("id", "comment_lockdown"))
	var timer := float(timers.get(weapon_id, 0.0)) - float(context.get("delta", 0.0))
	if timer > 0.0:
		timers[weapon_id] = timer
		return result
	if bool(context.get("normalWeaponsDisabled", false)) or bool(context.get("weaponMute", false)):
		timers[weapon_id] = 0.0
		return result
	var player_pos := Vector2(context.get("playerPos", Vector2.ZERO))
	var facing := _direction_with_attack_right_only(Vector2(context.get("facingDir", Vector2.RIGHT)), context)
	if facing.length() < 0.1:
		facing = Vector2.RIGHT
	var range_value := float(weapon.get("range", 0.0)) * float(context.get("rangeRate", 1.0))
	range_value = _short_range_range_for_weapon(weapon_id, weapon, range_value, context)
	var speed := scaled_projectile_speed(float(weapon.get("projectileSpeed", 0.0)))
	var count := maxi(1, int(weapon.get("projectileCount", 1)))
	var used_ids: Array = []
	var hit_effects: Array = result["hitFx"] as Array
	for index in range(count):
		var target: Variant = _nearest_enemy_excluding(context.get("enemies", []) as Array, player_pos, range_value, used_ids)
		var direction := _spread_direction(facing, index, count, deg_to_rad(13.0))
		if target != null:
			var target_enemy: Dictionary = target as Dictionary
			used_ids.append(_entity_uid("enemy", target_enemy))
			direction = (Vector2(target_enemy.get("pos", player_pos)) - player_pos).normalized()
			if direction.length() < 0.1:
				direction = _spread_direction(facing, index, count, deg_to_rad(13.0))
		var life := range_value / maxf(1.0, speed)
		hit_effects.append({
			"kind": "comment_lockdown_projectile", "owner": weapon_id, "weaponId": weapon_id,
			"pos": player_pos + direction * 24.0, "dir": direction, "vel": direction * speed,
			"life": life, "maxLife": life, "damage": float(weapon.get("damage", weapon.get("baseDamage", 0.0))) * float(context.get("damageRate", 1.0)),
			"hitRadius": float(weapon.get("hitRadius", 12.0)) * attack_area_rate(context),
			"range": range_value, "followupDamage": float(weapon.get("followupDamage", 0.0)) * float(context.get("damageRate", 1.0)),
				"followupDelay": float(weapon.get("followupDelay", 0.0)), "weapon": weapon.duplicate(true)
		})
	timers[weapon_id] = _stage2_interval(weapon, context, 0.0)
	return result

static func _comment_lockdown_apply_control(enemy: Dictionary, weapon: Dictionary) -> void:
	var is_boss := _is_boss_enemy(enemy)
	var is_large := not is_boss and EnemySystem.is_large_enemy(enemy)
	var stun_duration := 0.0
	var movement_rate := float(weapon.get("normalMovementRate", 1.0))
	if is_boss:
		movement_rate = float(weapon.get("bossMovementRate", 1.0))
	elif is_large:
		stun_duration = float(weapon.get("largeStunDuration", 0.0))
		movement_rate = float(weapon.get("largeMovementRate", 1.0))
	else:
		stun_duration = float(weapon.get("stunDuration", 0.0))
		movement_rate = float(weapon.get("normalMovementRate", 1.0))
	if stun_duration > 0.0:
		enemy["stunTimer"] = maxf(float(enemy.get("stunTimer", 0.0)), stun_duration)
	enemy["slowTimer"] = maxf(float(enemy.get("slowTimer", 0.0)), float(weapon.get("slowDuration", 0.0)))
	# EnemySystem stores the reduction, not the remaining movement rate.
	enemy["slowRate"] = maxf(float(enemy.get("slowRate", 0.0)), clampf(1.0 - movement_rate, 0.0, 0.85))

static func _comment_lockdown_target_reference(enemy: Dictionary) -> Dictionary:
	return {
		"spawnToken": String(enemy.get("spawnToken", "")),
		"kind": String(enemy.get("kind", "")),
		"uid": int(enemy.get("uid", -1))
	}

static func _resolve_stage2_enemy(enemies: Array, fx: Dictionary) -> Dictionary:
	var expected_token := String(fx.get("targetToken", ""))
	var expected_spawn := String(fx.get("targetSpawnToken", ""))
	var expected_kind := String(fx.get("targetKind", ""))
	var expected_uid := int(fx.get("targetUid", -1))
	var expected_reference: Dictionary = fx.get("targetReference", {}) as Dictionary
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if not _stage2_alive_enemy(enemy):
			continue
		if expected_token != "" and _stage2_entity_token(enemy) != expected_token:
			continue
		if expected_spawn != "" and String(enemy.get("spawnToken", "")) != expected_spawn:
			continue
		if expected_kind != "" and String(enemy.get("kind", "")) != expected_kind:
			continue
		if expected_uid >= 0 and int(enemy.get("uid", -1)) != expected_uid:
			continue
		if not expected_reference.is_empty():
			if String(expected_reference.get("spawnToken", "")) != String(enemy.get("spawnToken", "")):
				continue
			if String(expected_reference.get("kind", "")) != String(enemy.get("kind", "")):
				continue
			if int(expected_reference.get("uid", -1)) != int(enemy.get("uid", -1)):
				continue
		return enemy
	return {}

static func update_comment_lockdown_projectile(fx: Dictionary, enemies: Array, destructibles: Array, killed_enemies: Array, destroyed_boxes: Array, hit_effects: Array, feedback: Dictionary = {}) -> void:
	var pos := Vector2(fx.get("pos", Vector2.ZERO))
	var damage := float(fx.get("damage", 0.0))
	var hit_radius := float(fx.get("hitRadius", 12.0))
	var source := String(fx.get("weaponId", "comment_lockdown"))
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if not _stage2_alive_enemy(enemy):
			continue
		var enemy_pos := Vector2(enemy.get("pos", pos))
		var combined_radius := hit_radius + float(enemy.get("radius", 20.0))
		if pos.distance_squared_to(enemy_pos) > combined_radius * combined_radius:
			continue
		var direction := Vector2(fx.get("dir", Vector2.RIGHT)).normalized()
		var hit_result := _apply_enemy_hit(enemy, damage, direction, 0.0, killed_enemies, hit_effects, feedback.get("barrierHitRequests", []) as Array, source)
		if hit_result == HIT_DAMAGED:
			var weapon: Dictionary = fx.get("weapon", {}) as Dictionary
			_comment_lockdown_apply_control(enemy, weapon)
			var bind_life := maxf(0.05, float(enemy.get("stunTimer", 0.0)) + float(enemy.get("slowTimer", 0.0)))
			var followup := {
				"kind": "comment_lockdown_followup", "owner": source, "weaponId": source,
				"targetToken": _stage2_entity_token(enemy), "targetSpawnToken": String(enemy.get("spawnToken", "")),
				"targetKind": String(enemy.get("kind", "")), "targetUid": int(enemy.get("uid", -1)),
				"targetReference": _comment_lockdown_target_reference(enemy),
				"pos": enemy_pos,
				"damage": float(fx.get("followupDamage", 0.0)), "delay": float(fx.get("followupDelay", 0.0)),
				"maxDelay": float(fx.get("followupDelay", 0.0)), "life": 0.28, "maxLife": 0.28,
				"applied": false, "visuals": (fx.get("visuals", {}) as Dictionary).duplicate(true)
			}
			hit_effects.append(followup)
			hit_effects.append({
			"kind": "comment_lockdown_bind", "owner": source, "weaponId": source,
			"targetToken": _stage2_entity_token(enemy), "targetSpawnToken": String(enemy.get("spawnToken", "")),
			"targetKind": String(enemy.get("kind", "")), "targetUid": int(enemy.get("uid", -1)),
			"targetReference": _comment_lockdown_target_reference(enemy), "pos": enemy_pos,
			"stunActive": true, "slowActive": false, "life": bind_life, "maxLife": bind_life,
			"visuals": (fx.get("visuals", {}) as Dictionary).duplicate(true)
		})
			hit_effects.append({"kind": "comment_lockdown_hit", "owner": source, "weaponId": source, "pos": enemy_pos, "dir": direction, "life": 0.22, "maxLife": 0.22})
			_merge_reaction_result(feedback, {"enemyDamaged": true, "weaponCommentKind": weapon_comment_kind_for_id(source)})
		fx["life"] = 0.0
		return
	for box_item in destructibles:
		var box: Dictionary = box_item as Dictionary
		if not _stage2_alive_box(box):
			continue
		var combined_radius := hit_radius + float(box.get("radius", 24.0))
		if pos.distance_squared_to(Vector2(box.get("pos", pos))) <= combined_radius * combined_radius:
			var fx_start := hit_effects.size()
			DestructibleSystemScript.damage_box(box, 1.0, destroyed_boxes, hit_effects)
			_tag_hit_effects_for_weapon(hit_effects, fx_start, source)
			fx["life"] = 0.0
			return

static func update_comment_lockdown_bind_fx(fx: Dictionary, enemies: Array) -> void:
	var enemy := _resolve_stage2_enemy(enemies, fx)
	if enemy.is_empty():
		fx["life"] = 0.0
		return
	var stun_timer := float(enemy.get("stunTimer", 0.0))
	var slow_timer := float(enemy.get("slowTimer", 0.0))
	if stun_timer <= 0.0 and slow_timer <= 0.0:
		fx["life"] = 0.0
		return
	fx["pos"] = enemy.get("pos", fx.get("pos", Vector2.ZERO))
	fx["stunActive"] = stun_timer > 0.0
	fx["slowActive"] = slow_timer > 0.0 and stun_timer <= 0.0

static func update_comment_lockdown_followup_fx(fx: Dictionary, enemies: Array, killed_enemies: Array, hit_effects: Array, feedback: Dictionary = {}) -> void:
	if bool(fx.get("applied", false)):
		return
	fx["applied"] = true
	var enemy := _resolve_stage2_enemy(enemies, fx)
	if enemy.is_empty():
		fx["life"] = 0.0
		return
	var hit_result := _apply_enemy_hit(enemy, float(fx.get("damage", 0.0)), Vector2.RIGHT, 0.0, killed_enemies, hit_effects, feedback.get("barrierHitRequests", []) as Array, String(fx.get("weaponId", "comment_lockdown")))
	if hit_result == HIT_DAMAGED:
		_merge_reaction_result(feedback, {"enemyDamaged": true, "weaponCommentKind": weapon_comment_kind_for_id(String(fx.get("weaponId", "comment_lockdown")))})
		hit_effects.append({"kind": "comment_lockdown_followup_hit", "owner": String(fx.get("owner", "comment_lockdown")), "weaponId": String(fx.get("weaponId", "comment_lockdown")), "pos": enemy.get("pos", Vector2.ZERO), "life": 0.22, "maxLife": 0.22, "visuals": (fx.get("visuals", {}) as Dictionary).duplicate(true)})
	fx["life"] = 0.0

static func _update_emote_festival_weapon(weapon: Dictionary, context: Dictionary, timers: Dictionary) -> Dictionary:
	var result := _stage2_empty_result()
	var weapon_id := String(weapon.get("id", "emote_festival"))
	var timer := float(timers.get(weapon_id, 0.0)) - float(context.get("delta", 0.0))
	if timer > 0.0:
		timers[weapon_id] = timer
		return result
	if bool(context.get("normalWeaponsDisabled", false)) or bool(context.get("weaponMute", false)):
		timers[weapon_id] = 0.0
		return result
	var source_weapon := _stage2_source_weapon(weapon, context)
	var active_fx: Array = context.get("activeFx", []) as Array
	var hit_effects: Array = result["hitFx"] as Array
	var max_active := maxi(1, int(weapon.get("maxActiveCount", 1)))
	var active_count := _active_fx_count(active_fx, hit_effects, "emote_festival_mine", weapon_id)
	var mine_count := maxi(1, int(weapon.get("mineCount", 1)))
	var duration := float(weapon.get("duration", 0.0))
	var radius := float(weapon.get("explosionRadius", 0.0)) * _stage2_coverage_rate(context)
	var chain_radius := float(weapon.get("chainRadius", 0.0)) * _stage2_coverage_rate(context)
	var damage := float(weapon.get("damage", weapon.get("baseDamage", 0.0))) * float(context.get("damageRate", 1.0))
	var player_pos := Vector2(context.get("playerPos", Vector2.ZERO))
	var knockback := float(weapon.get("knockback", source_weapon.get("knockback", 0.0)))
	var screen_shake := float(weapon.get("screenShakePower", source_weapon.get("screenShakePower", 0.0)))
	var screen_duration := float(weapon.get("screenShakeDuration", source_weapon.get("screenShakeDuration", 0.0)))
	var hit_stop := float(weapon.get("hitStop", source_weapon.get("hitStop", 0.0)))
	var states := _stage2_states(timers)
	var state: Dictionary = states.get(weapon_id, {}) as Dictionary
	var mine_serial := int(state.get("mineSerial", 0))
	for index in range(mine_count):
		if active_count >= max_active:
			break
		var angle := TAU * float(index) / float(maxi(1, mine_count))
		var mine_pos := player_pos + Vector2.RIGHT.rotated(angle) * (18.0 if mine_count > 1 else 0.0)
		mine_serial += 1
		hit_effects.append({
			"kind": "emote_festival_mine", "owner": weapon_id, "weaponId": weapon_id,
			"mineSerial": "%s:%d" % [weapon_id, mine_serial],
			"pos": mine_pos, "life": duration, "maxLife": duration, "damage": damage,
			"radius": radius, "triggerRadius": maxf(0.0, float(weapon.get("triggerRadius", source_weapon.get("triggerRadius", 28.0)))),
			"chainRadius": chain_radius, "chainDamageCoefficient": float(weapon.get("chainDamageCoefficient", 1.0)),
			"chainDelay": float(weapon.get("chainDelay", 0.0)), "chainQueued": false,
			"chainTriggered": false, "exploded": false, "knockback": knockback,
			"screenShakePower": screen_shake, "screenShakeDuration": screen_duration,
			"hitStop": hit_stop
		})
		active_count += 1
	state["mineSerial"] = mine_serial
	states[weapon_id] = state
	timers[weapon_id] = _stage2_interval(weapon, context, 0.0)
	return result

static func _stage2_mine_pool(all_fx: Array) -> Array:
	var pool: Array = []
	for item in all_fx:
		if item is Dictionary:
			pool.append(item)
	return pool

static func _queue_emote_festival_chain(fx: Dictionary, all_fx: Array, output_fx: Array) -> void:
	var center := Vector2(fx.get("pos", Vector2.ZERO))
	var owner_id := String(fx.get("owner", "emote_festival"))
	var radius := float(fx.get("chainRadius", 0.0))
	var coefficient := float(fx.get("chainDamageCoefficient", 1.0))
	var visuals: Dictionary = fx.get("visuals", {}) as Dictionary
	var candidates: Array = []
	for candidate_value in all_fx:
		var candidate: Dictionary = candidate_value as Dictionary
		if String(candidate.get("kind", "")) != "emote_festival_mine" or String(candidate.get("owner", "")) != owner_id:
			continue
		if bool(candidate.get("exploded", false)) or bool(candidate.get("chainQueued", false)) or float(candidate.get("life", 0.0)) <= 0.0:
			continue
		if Vector2(candidate.get("pos", center)).distance_to(center) > radius:
			continue
		candidates.append(candidate)
	candidates.sort_custom(func(a: Dictionary, b: Dictionary):
			var a_distance := Vector2(a.get("pos", center)).distance_to(center)
			var b_distance := Vector2(b.get("pos", center)).distance_to(center)
			if not is_equal_approx(a_distance, b_distance):
				return a_distance < b_distance
			return String(a.get("mineSerial", "")) < String(b.get("mineSerial", ""))
	)
	for candidate in candidates:
		var candidate_pos := Vector2(candidate.get("pos", center))
		var chain_vector := candidate_pos - center
		var chain_life := maxf(0.05, float((visuals.get("chain", {}) as Dictionary).get("durationSeconds", 0.28)))
		output_fx.append({
			"kind": "emote_festival_chain", "owner": owner_id, "weaponId": owner_id,
			"from": center, "to": candidate_pos, "pos": center.lerp(candidate_pos, 0.5),
			"dir": chain_vector.normalized() if chain_vector.length() > 0.01 else Vector2.RIGHT,
			"distance": chain_vector.length(), "life": chain_life, "maxLife": chain_life,
			"visuals": visuals.duplicate(true)
		})
		candidate["chainQueued"] = true
		candidate["chainTriggered"] = true
		candidate["damage"] = float(candidate.get("damage", 0.0)) * coefficient
		candidate["delay"] = maxf(0.001, float(fx.get("chainDelay", 0.01)))
		candidate["chainSource"] = String(fx.get("mineSerial", ""))

static func update_emote_festival_mine_damage(fx: Dictionary, enemies: Array, destructibles: Array, enemy_bullets: Array, killed_enemies: Array, destroyed_boxes: Array, hit_effects: Array, all_fx: Array, feedback: Dictionary = {}) -> void:
	if bool(fx.get("exploded", false)):
		return
	var pos := Vector2(fx.get("pos", Vector2.ZERO))
	var should_explode := bool(fx.get("chainTriggered", false))
	if not should_explode:
		var trigger_radius := float(fx.get("triggerRadius", 28.0))
		for enemy_item in enemies:
			var enemy: Dictionary = enemy_item as Dictionary
			if not _stage2_alive_enemy(enemy):
				continue
			var combined := trigger_radius + float(enemy.get("radius", 20.0))
			if pos.distance_squared_to(Vector2(enemy.get("pos", pos))) <= combined * combined:
				should_explode = true
				break
	if not should_explode:
		return
	fx["exploded"] = true
	fx["chainTriggered"] = false
	var radius := float(fx.get("radius", 0.0))
	var source := String(fx.get("weaponId", "emote_festival"))
	var hits := _apply_circle_damage(enemies, pos, radius, float(fx.get("damage", 0.0)), float(fx.get("knockback", 0.0)), killed_enemies, hit_effects, feedback.get("barrierHitRequests", []) as Array, source)
	_apply_circle_damage_to_boxes(destructibles, pos, radius, destroyed_boxes, hit_effects, source)
	_clear_enemy_bullets_in_circle(enemy_bullets, pos, radius, hit_effects, "", source)
	_merge_reaction_result(feedback, {
		"enemyDamaged": hits > 0, "screenShakePower": float(fx.get("screenShakePower", 0.0)),
		"screenShakeDuration": float(fx.get("screenShakeDuration", 0.15)), "hitStop": float(fx.get("hitStop", 0.0)),
		"weaponCommentKind": weapon_comment_kind_for_id(source), "emoteMineExploded": true
	})
	hit_effects.append({"kind": "emote_festival_burst", "owner": source, "weaponId": source, "pos": pos, "life": 0.28, "maxLife": 0.28, "radius": radius, "chain": bool(fx.get("chainQueued", false)), "visuals": (fx.get("visuals", {}) as Dictionary).duplicate(true)})
	_queue_emote_festival_chain(fx, all_fx, hit_effects)
	fx["life"] = 0.0

static func _all_block_laser_direction(weapon: Dictionary, context: Dictionary, length: float, width: float, fallback: Vector2) -> Vector2:
	var player_pos := Vector2(context.get("playerPos", Vector2.ZERO))
	var best_direction := fallback.normalized()
	if best_direction.length() < 0.1:
		best_direction = Vector2.RIGHT
	var best_score := -1
	var best_distance := INF
	var best_token := ""
	var enemies: Array = context.get("enemies", []) as Array
	for candidate_value in enemies:
		var candidate: Dictionary = candidate_value as Dictionary
		if not _stage2_alive_enemy(candidate):
			continue
		var candidate_pos := Vector2(candidate.get("pos", player_pos))
		var offset := candidate_pos - player_pos
		if offset.length() <= 0.01 or offset.length() > length + float(candidate.get("radius", 20.0)):
			continue
		var direction := offset.normalized()
		var score := 0
		for member_value in enemies:
			var member: Dictionary = member_value as Dictionary
			if not _stage2_alive_enemy(member):
				continue
			if _laser_hit(Vector2(member.get("pos", player_pos)), float(member.get("radius", 20.0)), player_pos, direction, length, width * 0.5):
				score += 1
		var distance := offset.length()
		var token := _stage2_entity_token(candidate)
		var better := score > best_score
		if score == best_score and distance < best_distance - 0.001:
			better = true
		if score == best_score and is_equal_approx(distance, best_distance) and (best_token == "" or token < best_token):
			better = true
		if better:
			best_score = score
			best_distance = distance
			best_token = token
			best_direction = direction
	return best_direction

static func _update_all_block_laser_weapon(weapon: Dictionary, context: Dictionary, timers: Dictionary) -> Dictionary:
	var result := _stage2_empty_result()
	var weapon_id := String(weapon.get("id", "all_block_laser"))
	var timer := float(timers.get(weapon_id, 0.0)) - float(context.get("delta", 0.0))
	if timer > 0.0:
		timers[weapon_id] = timer
		return result
	if bool(context.get("normalWeaponsDisabled", false)) or bool(context.get("weaponMute", false)):
		timers[weapon_id] = 0.0
		return result
	var player_pos := Vector2(context.get("playerPos", Vector2.ZERO))
	var fallback := _direction_with_attack_right_only(Vector2(context.get("facingDir", Vector2.RIGHT)), context)
	if fallback.length() < 0.1:
		fallback = Vector2.RIGHT
	var length := float(weapon.get("range", 0.0)) * float(context.get("rangeRate", 1.0))
	length = _short_range_range_for_weapon(weapon_id, weapon, length, context)
	var width := float(weapon.get("width", 0.0)) * attack_area_rate(context)
	var center_direction := _all_block_laser_direction(weapon, context, length, width, fallback)
	var count := maxi(1, int(weapon.get("laserCount", 1)))
	var side_angle := deg_to_rad(float(weapon.get("sideAngleDegrees", 0.0)))
	var damage := float(weapon.get("damage", weapon.get("baseDamage", 0.0))) * float(context.get("damageRate", 1.0))
	var barriers: Array = result["barrierHitRequests"] as Array
	var hit_effects: Array = result["hitFx"] as Array
	for index in range(count):
		var offset_index := index - int(count / 2)
		var direction := center_direction.rotated(float(offset_index) * side_angle).normalized()
		var start := player_pos
		var hits := _apply_laser_damage(context.get("enemies", []) as Array, context.get("destructibles", []) as Array, context.get("enemyBullets", []) as Array, start, direction, length, width, damage, float(weapon.get("knockback", 0.0)), result["killed"] as Array, result["destroyedBoxes"] as Array, hit_effects, barriers, bool(weapon.get("clearableOnly", true)), weapon_id)
		hit_effects.append({
			"kind": "all_block_laser", "owner": weapon_id, "weaponId": weapon_id,
			"pos": start, "dir": direction, "life": float(weapon.get("duration", 0.0)),
			"maxLife": float(weapon.get("duration", 0.0)), "range": length, "width": width,
			"hit": start + direction * length, "count": hits
		})
		if hits > 0:
			_merge_reaction_result(result, {"enemyDamaged": true, "weaponCommentKind": weapon_comment_kind_for_id(weapon_id)})
	if count > 0:
		var weapon_visuals: Dictionary = weapon.get("visuals", {}) as Dictionary
		var flash_config: Dictionary = weapon_visuals.get("flash", {}) as Dictionary
		var flash_life := maxf(0.05, float(flash_config.get("durationSeconds", 0.18)))
		hit_effects.append({
			"kind": "all_block_laser_flash", "owner": weapon_id, "weaponId": weapon_id,
			"pos": player_pos, "life": flash_life, "maxLife": flash_life,
			"visuals": weapon_visuals.duplicate(true)
		})
	timers[weapon_id] = _stage2_interval(weapon, context, 0.0)
	return result

static func _update_listener_assembly_weapon(weapon: Dictionary, context: Dictionary, timers: Dictionary) -> Dictionary:
	var result := _stage2_empty_result()
	var weapon_id := String(weapon.get("id", "listener_assembly"))
	var timer := float(timers.get(weapon_id, 0.0)) - float(context.get("delta", 0.0))
	if timer > 0.0:
		timers[weapon_id] = timer
		return result
	if bool(context.get("normalWeaponsDisabled", false)) or bool(context.get("weaponMute", false)):
		timers[weapon_id] = 0.0
		return result
	var active_count := _active_fx_count(context.get("activeFx", []) as Array, result["hitFx"] as Array, "listener_assembly", weapon_id)
	var max_active := maxi(1, int(weapon.get("maxActiveCount", 1)))
	var count := maxi(1, int(weapon.get("summonCount", 1)))
	var duration := float(weapon.get("duration", 0.0))
	var damage := float(weapon.get("damage", weapon.get("baseDamage", 0.0))) * float(context.get("damageRate", 1.0))
	var speed := float(weapon.get("moveSpeed", 0.0))
	var search_range := float(weapon.get("searchRange", 0.0)) * float(context.get("rangeRate", 1.0))
	search_range = _short_range_range_for_weapon(weapon_id, weapon, search_range, context)
	var player_pos := Vector2(context.get("playerPos", Vector2.ZERO))
	var facing := Vector2(context.get("facingDir", Vector2.RIGHT)).normalized()
	if facing.length() < 0.1:
		facing = Vector2.RIGHT
	var states: Dictionary = timers.get(STAGE2_WEAPON_STATE_KEY, {}) as Dictionary
	var state: Dictionary = states.get(weapon_id, {}) as Dictionary
	var next_serial := int(state.get("listenerUnitSerial", 0))
	var target_distribution := _listener_assembly_distribution(weapon)
	var hit_effects: Array = result["hitFx"] as Array
	for index in range(count):
		if active_count >= max_active:
			break
		next_serial += 1
		var direction := _spread_direction(facing, index, count, deg_to_rad(28.0))
		var spawn_pos := player_pos + direction * 32.0
		var visuals: Dictionary = weapon.get("visuals", {}) as Dictionary
		var spawn_config: Dictionary = visuals.get("spawn", {}) as Dictionary
		var spawn_life := maxf(0.05, float(spawn_config.get("durationSeconds", 0.28)))
		var approach_phase := fposmod(deg_to_rad(float(target_distribution["approachPhaseStepDegrees"])) * float(next_serial - 1), TAU)
		var motion_phase := fposmod(float(target_distribution["motionPhaseStepRadians"]) * float(next_serial - 1), TAU)
		hit_effects.append({
			"kind": "listener_assembly_spawn", "owner": weapon_id, "weaponId": weapon_id,
			"pos": spawn_pos, "dir": direction, "life": spawn_life, "maxLife": spawn_life,
			"visuals": visuals.duplicate(true)
		})
		hit_effects.append({
			"kind": "listener_assembly", "owner": weapon_id, "weaponId": weapon_id,
			"pos": spawn_pos, "dir": direction,
			"life": duration, "maxLife": duration, "damage": damage,
			"moveSpeed": speed, "searchRange": search_range, "hitRadius": 18.0 * attack_area_rate(context),
			"hitCooldown": float(weapon.get("hitCooldown", 0.0)), "hitTimer": 0.0, "knockback": float(weapon.get("knockback", 0.0)),
			"unitSerial": next_serial, "approachPhase": approach_phase, "motionPhase": motion_phase,
			"targetDistribution": target_distribution.duplicate(true)
		})
		active_count += 1
	state["listenerUnitSerial"] = next_serial
	states[weapon_id] = state
	timers[STAGE2_WEAPON_STATE_KEY] = states
	timers[weapon_id] = _stage2_interval(weapon, context, 0.0)
	return result

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
		var weapon_data_value: Variant = target.get("weapons")
		if weapon_data_value is Array:
			for weapon_item in weapon_data_value as Array:
				var weapon: Dictionary = weapon_item as Dictionary
				var weapon_id := String(weapon.get("id", ""))
				if weapon_id != "" and (bool(weapon.get("isEvolved", false)) or String(weapon.get("baseWeaponId", "")) != "") and not ids.has(weapon_id):
					ids.append(weapon_id)
		var current_weapon_value: Variant = target.get("current_weapon")
		if current_weapon_value is Dictionary:
			var current_id := String((current_weapon_value as Dictionary).get("id", ""))
			if current_id != "" and not ids.has(current_id):
				ids.append(current_id)
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
		if String(fx.get("kind", "")) == "tsuri_rod_cast" or String(fx.get("kind", "")) == "buzz_thumbnail_rod_cast":
			_rod_release_claimed_collectibles(fx)
		_restore_stage2_transient_states(fx)
		fx["completionReason"] = reason
		target.set("lastWeaponRuntimeCleanupReason", reason)
	target.set("hit_fx", remaining)
	var bullets_value: Variant = target.get("player_bullets")
	if bullets_value is Array:
		var remaining_bullets: Array = []
		for bullet_item in bullets_value as Array:
			var bullet: Dictionary = bullet_item as Dictionary
			var bullet_id := String(bullet.get("weaponId", bullet.get("owner", "")))
			if bullet_id == "" or not ids.has(bullet_id):
				remaining_bullets.append(bullet)
		target.set("player_bullets", remaining_bullets)
	var boomerang_hits_value: Variant = target.get("boomerang_hits")
	if boomerang_hits_value is Dictionary:
		var boomerang_hits: Dictionary = boomerang_hits_value as Dictionary
		for key_value in boomerang_hits.keys().duplicate():
			var key_text := String(key_value)
			for weapon_id in ids:
				if key_text.begins_with(String(weapon_id) + "|"):
					boomerang_hits.erase(key_value)
					break
		target.set("boomerang_hits", boomerang_hits)
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		enemy.erase("shieldContactSuppressTimer")
		enemy.erase("shieldBlocked")
	var timers_value: Variant = target.get("equipment_weapon_timers")
	if timers_value is Dictionary:
		var timers: Dictionary = timers_value as Dictionary
		for weapon_id in ids:
			timers.erase(weapon_id)
		if ids.has("starlight_superchat"):
			timers.erase(STARLIGHT_SHOT_COUNTER_KEY)
		if ids.has("maro_comment_ring"):
			timers.erase(MARO_PULSE_INDEX_KEY)
			timers.erase(MARO_PULSE_UNTIL_KEY)
			timers.erase(MARO_FLASH_UNTIL_KEY)
		for timer_key_value in timers.keys().duplicate():
			var timer_key := String(timer_key_value)
			if ids.has("maro_comment_ring") and timer_key.contains(MARO_PULSE_INDEX_KEY + ":"):
				timers.erase(timer_key_value)
			if ids.has("maro_comment_ring") and timer_key.contains(BOOMERANG_ORBIT_INDEX_KEY + ":maro_comment_ring"):
				timers.erase(timer_key_value)
			if ids.has("maro_comment_ring") and timer_key.contains(BOOMERANG_ORBIT_WEAPON_ID_KEY + ":maro_comment_ring"):
				timers.erase(timer_key_value)
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
	# Explicit projectile metadata is authoritative.  The old source-name
	# filter incorrectly made every boss/collab projectile unblockable and also
	# rejected ordinary spread shots.
	if bullet.has("shieldBlockable"):
		return bool(bullet.get("shieldBlockable", false))
	if bullet.has("unblockableByShield"):
		return not bool(bullet.get("unblockableByShield", false))
	if bullet.has("clearableByPlayerWeapon"):
		return bool(bullet.get("clearableByPlayerWeapon", false))
	var attack_type := String(bullet.get("attackType", "")).to_lower()
	if attack_type in ["laser", "beam", "field", "aoe", "floor", "warning_line", "contact", "stage_gimmick"]:
		return false
	return false

static func shield_fan_center(player_pos: Vector2, forward: Vector2, offset: float) -> Vector2:
	var direction := forward.normalized()
	if direction.length() < 0.1:
		direction = Vector2.RIGHT
	return player_pos + direction * offset

static func shield_fan_contains_point(center: Vector2, forward: Vector2, radius: float, arc_degrees: float, point: Vector2, target_radius: float = 0.0) -> bool:
	var offset := point - center
	var reach := maxf(0.0, radius) + maxf(0.0, target_radius)
	if offset.length_squared() > reach * reach:
		return false
	if offset.length_squared() <= 0.0001:
		return true
	var direction := forward.normalized()
	if direction.length() < 0.1:
		direction = Vector2.RIGHT
	var half_arc := deg_to_rad(clampf(arc_degrees, 0.0, 360.0) * 0.5)
	if half_arc >= PI - 0.0001:
		return true
	return direction.dot(offset.normalized()) >= cos(half_arc)

static func _shield_direction_from_context(context: Dictionary, current: Vector2 = Vector2.ZERO) -> Vector2:
	if bool(context.get("attackRightOnly", false)):
		return Vector2.RIGHT
	var candidates: Array = [context.get("manualAimDirection", Vector2.ZERO), context.get("moveInput", Vector2.ZERO), context.get("playerVel", Vector2.ZERO), current, context.get("facingDir", Vector2.ZERO), context.get("lastMoveDirection", Vector2.ZERO)]
	for candidate_value in candidates:
		var candidate := Vector2(candidate_value)
		if candidate.length() > 0.1:
			return candidate.normalized()
	return Vector2.RIGHT

static func shield_rotation_step(current: Vector2, desired: Vector2, delta: float, speed_degrees: float) -> Vector2:
	var from_dir := current.normalized()
	if from_dir.length() < 0.1:
		from_dir = desired.normalized()
	if from_dir.length() < 0.1:
		from_dir = Vector2.RIGHT
	var to_dir := desired.normalized()
	if to_dir.length() < 0.1:
		to_dir = Vector2.RIGHT
	var max_turn := deg_to_rad(maxf(0.0, speed_degrees)) * maxf(0.0, delta)
	var difference := wrapf(to_dir.angle() - from_dir.angle(), -PI, PI)
	if absf(difference) <= max_turn:
		return to_dir
	return Vector2.RIGHT.rotated(from_dir.angle() + signf(difference) * max_turn).normalized()

static func _shield_active_for_weapon(active_fx: Array, weapon_id: String) -> bool:
	for fx_item in active_fx:
		var fx: Dictionary = fx_item as Dictionary
		if String(fx.get("weaponId", fx.get("owner", ""))) == weapon_id and float(fx.get("life", 0.0)) > 0.0 and String(fx.get("kind", "")) in ["moderator_shield_active", "moderator_fortress_active"]:
			return true
	return false

static func shield_visual_debug_state(active_fx: Array, weapon_id: String) -> Dictionary:
	var state := {
		"weapon": weapon_id,
		"deployEffectPlayed": false,
		"shockwaveEffectPlayed": false,
		"idleEffectActive": false,
		"hitEffectCount": 0,
		"blockEffectCount": 0,
		"endEffectPlayed": false,
		"legacyTrailEffect": false
	}
	for fx_item in active_fx:
		var fx: Dictionary = fx_item as Dictionary
		if String(fx.get("weaponId", fx.get("owner", ""))) != weapon_id:
			continue
		state["deployEffectPlayed"] = bool(state["deployEffectPlayed"]) or bool(fx.get("deployEffectPlayed", false))
		state["shockwaveEffectPlayed"] = bool(state["shockwaveEffectPlayed"]) or bool(fx.get("shockwaveEffectPlayed", false)) or String(fx.get("kind", "")) == "moderator_fortress_shockwave"
		state["idleEffectActive"] = bool(state["idleEffectActive"]) or bool(fx.get("idleEffectActive", false))
		state["hitEffectCount"] = maxi(int(state["hitEffectCount"]), int(fx.get("hitEffectCount", 0)))
		state["blockEffectCount"] = maxi(int(state["blockEffectCount"]), int(fx.get("blockEffectCount", 0)))
		state["endEffectPlayed"] = bool(state["endEffectPlayed"]) or bool(fx.get("endEffectPlayed", false))
		state["legacyTrailEffect"] = bool(state["legacyTrailEffect"]) or bool(fx.get("legacyTrailEffect", false))
	return state

static func _shield_size_rate(context: Dictionary, weapon: Dictionary) -> float:
	var range_rate := clampf(float(context.get("rangeRate", 1.0)), 0.1, 1.6)
	var short_rate := float(context.get("shortRangeRate", 1.0)) if bool(context.get("shortRange", false)) else 1.0
	return clampf(float(weapon.get("sizeRate", 1.0)) * range_rate * short_rate, 0.1, 1.6)

static func _shield_pose(fx: Dictionary, delta: float, player_pos: Vector2, owner_context: Dictionary = {}) -> Dictionary:
	var context := owner_context.duplicate(true)
	context["playerPos"] = player_pos
	var held_direction := Vector2(fx.get("targetDir", fx.get("dir", Vector2.RIGHT)))
	var desired := _shield_direction_from_context(context, held_direction)
	var direction := shield_rotation_step(Vector2(fx.get("dir", desired)), desired, delta, float(fx.get("rotationSpeedDegrees", 1080.0)))
	var center := shield_fan_center(player_pos, direction, float(fx.get("offset", 0.0)))
	fx["targetDir"] = desired
	fx["dir"] = direction
	fx["playerPos"] = player_pos
	fx["pos"] = center
	fx["center"] = center
	return {"dir": direction, "center": center}

static func _shield_owner_context_for_target(target: Node) -> Dictionary:
	return {
		"playerPos": Vector2(target.get("player_pos")),
		"playerVel": Vector2(target.get("player_vel")),
		"lastMoveDirection": Vector2(target.get("last_hammer_dir")),
		"facingDir": Vector2(float(target.get("player_facing_x")), 0.0),
		"attackRightOnly": ModifierSystem.has_effect_for_target(target, "attack_right_only")
	}

static func prepare_shield_defense_for_target(target: Node) -> void:
	var hit_fx_value: Variant = target.get("hit_fx")
	var hit_fx: Array = hit_fx_value as Array if hit_fx_value is Array else []
	var enemies_value: Variant = target.get("enemies")
	var enemies: Array = enemies_value as Array if enemies_value is Array else []
	var bullets_value: Variant = target.get("enemy_bullets")
	var enemy_bullets: Array = bullets_value as Array if bullets_value is Array else []
	var owner_context := _shield_owner_context_for_target(target)
	for fx_item in hit_fx:
		var fx: Dictionary = fx_item as Dictionary
		if String(fx.get("kind", "")) not in ["moderator_shield_active", "moderator_fortress_active"] or float(fx.get("life", 0.0)) <= 0.0:
			continue
		var pose := _shield_pose(fx, 0.0, Vector2(owner_context["playerPos"]), owner_context)
		var direction: Vector2 = pose["dir"]
		var center: Vector2 = pose["center"]
		for enemy_item in enemies:
			var enemy: Dictionary = enemy_item as Dictionary
			if not _stage2_alive_enemy(enemy):
				continue
			if shield_fan_contains_point(center, direction, float(fx.get("radius", 80.0)), float(fx.get("arcDegrees", 100.0)), Vector2(enemy.get("pos", Vector2.ZERO)), float(enemy.get("radius", 20.0))):
				enemy["shieldContactSuppressTimer"] = maxf(float(enemy.get("shieldContactSuppressTimer", 0.0)), float(fx.get("contactSuppressSeconds", 0.10)))
		_shield_block_projectiles(fx, enemy_bullets, center, direction, hit_fx)
	target.set("hit_fx", hit_fx)
	target.set("enemy_bullets", enemy_bullets)

static func enemy_contact_blocked_by_shield(target: Node, enemy: Dictionary) -> bool:
	var hit_fx_value: Variant = target.get("hit_fx")
	var hit_fx: Array = hit_fx_value as Array if hit_fx_value is Array else []
	var owner_context := _shield_owner_context_for_target(target)
	var player_pos: Vector2 = owner_context["playerPos"]
	for fx_item in hit_fx:
		var fx: Dictionary = fx_item as Dictionary
		if String(fx.get("kind", "")) not in ["moderator_shield_active", "moderator_fortress_active"] or float(fx.get("life", 0.0)) <= 0.0:
			continue
		var pose := _shield_pose(fx, 0.0, player_pos, owner_context)
		if shield_fan_contains_point(Vector2(pose["center"]), Vector2(pose["dir"]), float(fx.get("radius", 80.0)), float(fx.get("arcDegrees", 100.0)), Vector2(enemy.get("pos", Vector2.ZERO)), float(enemy.get("radius", 20.0))):
			enemy["shieldContactSuppressTimer"] = maxf(float(enemy.get("shieldContactSuppressTimer", 0.0)), float(fx.get("contactSuppressSeconds", 0.10)))
			return true
	return false

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
	if _shield_active_for_weapon(context.get("activeFx", []) as Array, weapon_id):
		timers[weapon_id] = maxf(0.0, timer)
		return result
	if timer > 0.0:
		timers[weapon_id] = timer
		return result
	if bool(context.get("normalWeaponsDisabled", false)) or bool(context.get("weaponMute", false)):
		timers[weapon_id] = 0.0
		return result
	var player_pos := Vector2(context.get("playerPos", Vector2.ZERO))
	var direction := _shield_direction_from_context(context)
	var size_rate := _shield_size_rate(context, weapon)
	var duration := maxf(0.05, float(weapon.get("activeDuration", 4.00)))
	var body_damage := _stage2_base_damage(weapon) * float(weapon.get("damageRate", 1.0)) * float(weapon.get("damageMultiplier", 1.0)) * float(context.get("damageRate", 1.0))
	var hit_next_times: Dictionary = {}
	var fx := {
		"kind": "moderator_shield_active", "owner": weapon_id, "weaponId": weapon_id,
		"activationSePath": String(weapon.get("activationSePath", "")), "activationSeVolumeDb": float(weapon.get("activationSeVolumeDb", 0.0)),
		"playerPos": player_pos, "pos": shield_fan_center(player_pos, direction, float(weapon.get("offset", 52.0)) * size_rate),
		"dir": direction, "targetDir": direction, "age": 0.0, "life": duration, "maxLife": duration,
		"offset": float(weapon.get("offset", 52.0)) * size_rate, "radius": float(weapon.get("radius", 80.0)) * size_rate,
		"arcDegrees": float(weapon.get("arcDegrees", 100.0)), "sizeRate": size_rate,
		"damage": body_damage, "knockback": float(weapon.get("normalKnockbackDistance", 70.0)) * float(weapon.get("knockbackRate", 1.0)) * float(weapon.get("knockbackMultiplier", 1.0)),
		"enemyRehitInterval": float(weapon.get("enemyRehitInterval", 0.45)), "rotationSpeedDegrees": float(weapon.get("rotationSpeedDegrees", 1080.0)),
		"contactSuppressSeconds": float(weapon.get("contactSuppressSeconds", 0.10)), "blockEnemyProjectiles": bool(weapon.get("blockEnemyProjectiles", true)),
		"hitNextTimes": hit_next_times, "blockedProjectiles": 0,
		"nextHitEffectAt": -INF, "nextBlockEffectAt": -INF,
		"hitSoundCooldown": float(weapon.get("hitSoundCooldown", 0.06)), "lastHitSoundAt": -INF,
		"blockSoundCooldown": float(weapon.get("blockSoundCooldown", 0.08)), "lastBlockSoundAt": -INF,
		"visuals": (weapon.get("visuals", {}) as Dictionary).duplicate(true),
		"level": int(weapon.get("level", 1)), "completionReason": "",
		"deployEffectPlayed": true, "idleEffectActive": true, "hitEffectCount": 0, "blockEffectCount": 0,
		"endEffectPlayed": false, "legacyTrailEffect": false
	}
	(result["hitFx"] as Array).append(fx)
	var deploy_duration := _stage2_visual_duration(weapon, "deployEffect", 0.16)
	(result["hitFx"] as Array).append({
		"kind": "moderator_shield_deploy", "owner": weapon_id, "weaponId": weapon_id,
		"pos": fx["pos"], "dir": direction, "life": deploy_duration, "maxLife": deploy_duration,
		"visuals": (weapon.get("visuals", {}) as Dictionary).duplicate(true), "legacyTrailEffect": false
	})
	timers[weapon_id] = player_attack_interval(float(weapon.get("activationInterval", 5.5)), float(context.get("intervalRate", 1.0)))
	return result

static func _update_moderator_fortress_weapon(weapon: Dictionary, context: Dictionary, timers: Dictionary) -> Dictionary:
	var result := _stage2_empty_result()
	var weapon_id := String(weapon.get("id", "moderator_fortress"))
	var timer := float(timers.get(weapon_id, 0.0)) - float(context.get("delta", 0.0))
	if _shield_active_for_weapon(context.get("activeFx", []) as Array, weapon_id):
		timers[weapon_id] = maxf(0.0, timer)
		return result
	if timer > 0.0:
		timers[weapon_id] = timer
		return result
	if bool(context.get("normalWeaponsDisabled", false)) or bool(context.get("weaponMute", false)):
		timers[weapon_id] = 0.0
		return result
	var player_pos := Vector2(context.get("playerPos", Vector2.ZERO))
	var direction := _shield_direction_from_context(context)
	var size_rate := _shield_size_rate(context, weapon)
	var duration := maxf(0.05, float(weapon.get("activeDuration", 7.00)))
	var body_damage := _stage2_base_damage(weapon) * float(weapon.get("damageRate", 1.70)) * float(context.get("damageRate", 1.0))
	var hit_next_times: Dictionary = {}
	var fx := {
		"kind": "moderator_fortress_active", "owner": weapon_id, "weaponId": weapon_id,
		"activationSePath": String(weapon.get("activationSePath", "")), "activationSeVolumeDb": float(weapon.get("activationSeVolumeDb", 0.0)),
		"playerPos": player_pos, "pos": shield_fan_center(player_pos, direction, float(weapon.get("offset", 50.0)) * size_rate),
		"dir": direction, "targetDir": direction, "age": 0.0, "life": duration, "maxLife": duration,
		"offset": float(weapon.get("offset", 50.0)) * size_rate, "radius": float(weapon.get("radius", 100.0)) * size_rate,
		"arcDegrees": float(weapon.get("arcDegrees", 220.0)), "sizeRate": size_rate,
		"damage": body_damage, "knockback": float(weapon.get("normalKnockbackDistance", 70.0)) * float(weapon.get("knockbackRate", 1.35)),
		"enemyRehitInterval": float(weapon.get("enemyRehitInterval", 0.35)), "rotationSpeedDegrees": float(weapon.get("rotationSpeedDegrees", 1080.0)),
		"contactSuppressSeconds": float(weapon.get("contactSuppressSeconds", 0.10)), "blockEnemyProjectiles": bool(weapon.get("blockEnemyProjectiles", true)),
		"hitNextTimes": hit_next_times, "blockedProjectiles": 0,
		"nextHitEffectAt": -INF, "nextBlockEffectAt": -INF,
		"hitSoundCooldown": float(weapon.get("hitSoundCooldown", 0.06)), "lastHitSoundAt": -INF,
		"blockSoundCooldown": float(weapon.get("blockSoundCooldown", 0.08)), "lastBlockSoundAt": -INF,
		"visuals": (weapon.get("visuals", {}) as Dictionary).duplicate(true), "level": 1, "completionReason": "",
		"deployEffectPlayed": true, "shockwaveEffectPlayed": true, "idleEffectActive": true,
		"hitEffectCount": 0, "blockEffectCount": 0, "endEffectPlayed": false, "legacyTrailEffect": false
	}
	(result["hitFx"] as Array).append(fx)
	var deploy_duration := _stage2_visual_duration(weapon, "deployEffect", 0.18)
	(result["hitFx"] as Array).append({
		"kind": "moderator_fortress_deploy", "owner": weapon_id, "weaponId": weapon_id,
		"pos": fx["pos"], "dir": direction, "life": deploy_duration, "maxLife": deploy_duration,
		"visuals": (weapon.get("visuals", {}) as Dictionary).duplicate(true), "legacyTrailEffect": false
	})
	var shock_config: Dictionary = weapon.get("deploymentShockwave", {}) as Dictionary
	if bool(shock_config.get("enabled", true)):
		var shockwave_duration := _stage2_visual_duration(weapon, "shockwave", 0.28)
		(result["hitFx"] as Array).append({
			"kind": "moderator_fortress_shockwave", "owner": weapon_id, "weaponId": weapon_id,
			"pos": shield_fan_center(player_pos, direction, float(weapon.get("offset", 50.0)) * size_rate), "dir": direction,
			"playerPos": player_pos, "radius": float(weapon.get("radius", 100.0)) * size_rate, "arcDegrees": float(weapon.get("arcDegrees", 220.0)),
			"damage": _stage2_base_damage(weapon) * float(shock_config.get("damageRate", 1.0)) * float(context.get("damageRate", 1.0)),
			"knockback": float(weapon.get("normalKnockbackDistance", 70.0)) * float(weapon.get("knockbackRate", 1.35)) * float(shock_config.get("knockbackRate", 1.25)),
			"hitNextTimes": {}, "hitEnemyIds": {}, "shockwaveUsed": true, "life": shockwave_duration, "maxLife": shockwave_duration,
			"visuals": (weapon.get("visuals", {}) as Dictionary).duplicate(true)
		})
	timers[weapon_id] = player_attack_interval(float(weapon.get("activationInterval", 7.5)), float(context.get("intervalRate", 1.0)))
	return result

static func _shield_block_projectiles(fx: Dictionary, enemy_bullets: Array, center: Vector2, direction: Vector2, hit_effects: Array) -> void:
	if not bool(fx.get("blockEnemyProjectiles", true)):
		return
	var blocked := int(fx.get("blockedProjectiles", 0))
	var visuals: Dictionary = fx.get("visuals", {}) as Dictionary
	var block_effect_config := _stage2_visual_config(fx, "projectileBlockEffect")
	var effect_min_interval := maxf(0.0, float(block_effect_config.get("minIntervalSeconds", 0.03)))
	for bullet_item in enemy_bullets:
		var bullet: Dictionary = bullet_item as Dictionary
		if float(bullet.get("life", 0.0)) <= 0.0 or bool(bullet.get("shieldBlocked", false)) or not _stage2_shield_bullet_clearable(bullet):
			continue
		var bullet_pos := Vector2(bullet.get("pos", Vector2.ZERO))
		if not shield_fan_contains_point(center, direction, float(fx.get("radius", 0.0)), float(fx.get("arcDegrees", 0.0)), bullet_pos, float(bullet.get("hitRadius", 0.0))):
			continue
		bullet["life"] = 0.0
		bullet["shieldBlocked"] = true
		blocked += 1
		var block_clock := float(fx.get("shieldClock", 0.0))
		var last_sound := float(fx.get("lastBlockSoundAt", -INF))
		if block_clock - last_sound >= float(fx.get("blockSoundCooldown", 0.08)):
			fx["lastBlockSoundAt"] = block_clock
			fx["blockSoundTriggeredCount"] = int(fx.get("blockSoundTriggeredCount", 0)) + 1
		if block_clock < float(fx.get("nextBlockEffectAt", -INF)):
			continue
		fx["nextBlockEffectAt"] = block_clock + effect_min_interval
		fx["blockEffectCount"] = int(fx.get("blockEffectCount", 0)) + 1
		var clear_duration := _stage2_visual_duration(fx, "projectileBlockEffect", 0.19)
		if String(fx.get("weaponId", "")) == "moderator_fortress":
			clear_duration = maxf(clear_duration, _stage2_visual_duration(fx, "bulletBreak", 0.18))
			hit_effects.append({"kind": "moderator_fortress_bullet_clear", "owner": String(fx.get("owner", "moderator_fortress")), "weaponId": "moderator_fortress", "pos": bullet_pos, "shieldPos": center, "life": clear_duration, "maxLife": clear_duration, "visuals": visuals.duplicate(true)})
		else:
			hit_effects.append({"kind": "moderator_shield_bullet_clear", "owner": String(fx.get("owner", "moderator_shield")), "weaponId": "moderator_shield", "pos": bullet_pos, "life": clear_duration, "maxLife": clear_duration, "visuals": visuals.duplicate(true)})
	fx["blockedProjectiles"] = blocked

static func _update_front_shield_fx(fx: Dictionary, delta: float, enemies: Array, destructibles: Array, enemy_bullets: Array, killed_enemies: Array, destroyed_boxes: Array, hit_effects: Array, feedback: Dictionary, owner_context: Dictionary = {}) -> void:
	var player_pos := Vector2(owner_context.get("playerPos", fx.get("playerPos", Vector2.ZERO)))
	var pose := _shield_pose(fx, delta, player_pos, owner_context)
	var direction: Vector2 = pose["dir"]
	var center: Vector2 = pose["center"]
	var age := float(fx.get("age", 0.0)) + maxf(0.0, delta)
	var duration := maxf(0.05, float(fx.get("maxLife", fx.get("activeDuration", 4.0))))
	fx["age"] = age
	fx["progress"] = clampf(age / duration, 0.0, 1.0)
	var now := float(fx.get("shieldClock", 0.0)) + maxf(0.0, delta)
	fx["shieldClock"] = now
	var hit_next_times: Dictionary = fx.get("hitNextTimes", {}) as Dictionary
	var rehit := maxf(0.01, float(fx.get("enemyRehitInterval", 0.45)))
	var barrier_requests: Array = feedback.get("barrierHitRequests", []) as Array
	var is_fortress := String(fx.get("weaponId", "")) == "moderator_fortress"
	var hit_effect_config := _stage2_visual_config(fx, "enemyHitEffect")
	var hit_effect_min_interval := maxf(0.0, float(hit_effect_config.get("minIntervalSeconds", 0.05)))
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if not _stage2_alive_enemy(enemy):
			continue
		var token := _stage2_entity_token(enemy)
		if now < float(hit_next_times.get(token, -INF)):
			continue
		var enemy_pos := Vector2(enemy.get("pos", Vector2.ZERO))
		if not shield_fan_contains_point(center, direction, float(fx.get("radius", 80.0)), float(fx.get("arcDegrees", 100.0)), enemy_pos, float(enemy.get("radius", 20.0))):
			continue
		var push_dir := (enemy_pos - player_pos).normalized()
		if push_dir.length() < 0.1:
			push_dir = direction
		var knockback := float(fx.get("knockback", 0.0)) if bool(enemy.get("canBeKnockedBack", true)) and not _is_boss_enemy(enemy) else 0.0
		var hit_result := _apply_enemy_hit(enemy, float(fx.get("damage", 0.0)), push_dir, knockback, killed_enemies, hit_effects, barrier_requests, String(fx.get("weaponId", "moderator_shield")))
		hit_next_times[token] = now + rehit
		enemy["shieldContactSuppressTimer"] = maxf(float(enemy.get("shieldContactSuppressTimer", 0.0)), float(fx.get("contactSuppressSeconds", 0.10)))
		if hit_result != HIT_NONE:
			var last_hit_sound := float(fx.get("lastHitSoundAt", -INF))
			if now - last_hit_sound >= float(fx.get("hitSoundCooldown", 0.06)):
				fx["lastHitSoundAt"] = now
				fx["hitSoundTriggeredCount"] = int(fx.get("hitSoundTriggeredCount", 0)) + 1
			if now >= float(fx.get("nextHitEffectAt", -INF)):
				fx["nextHitEffectAt"] = now + hit_effect_min_interval
				fx["hitEffectCount"] = int(fx.get("hitEffectCount", 0)) + 1
				var hit_kind := "moderator_fortress_hit" if is_fortress else "moderator_shield_hit"
				var hit_duration := _stage2_visual_duration(fx, "enemyHitEffect", _stage2_visual_duration(fx, "hit", 0.19))
				hit_effects.append({"kind": hit_kind, "owner": String(fx.get("owner", fx.get("weaponId", "moderator_shield"))), "weaponId": String(fx.get("weaponId", "moderator_shield")), "pos": enemy_pos, "dir": push_dir, "life": hit_duration, "maxLife": hit_duration, "visuals": (fx.get("visuals", {}) as Dictionary).duplicate(true)})
			if hit_result == HIT_DAMAGED:
				_merge_reaction_result(feedback, {"enemyDamaged": true, "weaponCommentKind": String(fx.get("weaponId", "moderator_shield"))})
	for box_item in destructibles:
		var box: Dictionary = box_item as Dictionary
		if not _stage2_alive_box(box):
			continue
		var box_token := _stage2_box_token(box)
		if now < float(hit_next_times.get(box_token, -INF)):
			continue
		var box_pos := Vector2(box.get("pos", Vector2.ZERO))
		if not shield_fan_contains_point(center, direction, float(fx.get("radius", 80.0)), float(fx.get("arcDegrees", 100.0)), box_pos, float(box.get("radius", 24.0))):
			continue
		DestructibleSystemScript.damage_box(box, 1.0, destroyed_boxes, hit_effects)
		hit_next_times[box_token] = now + rehit
	fx["hitNextTimes"] = hit_next_times
	_shield_block_projectiles(fx, enemy_bullets, center, direction, hit_effects)
	if age >= duration:
		fx["completionReason"] = "duration_complete"
		fx["idleEffectActive"] = false
		if not bool(fx.get("endEffectPlayed", false)):
			fx["endEffectPlayed"] = true
			var end_duration := _stage2_visual_duration(fx, "endEffect", 0.16 if not is_fortress else 0.18)
			hit_effects.append({
				"kind": "moderator_fortress_end" if is_fortress else "moderator_shield_end",
				"owner": String(fx.get("owner", fx.get("weaponId", "moderator_shield"))),
				"weaponId": String(fx.get("weaponId", "moderator_shield")),
				"pos": center, "dir": direction, "life": end_duration, "maxLife": end_duration,
				"arcDegrees": float(fx.get("arcDegrees", 100.0)), "radius": float(fx.get("radius", 80.0)),
				"level": int(fx.get("level", 1)), "visuals": (fx.get("visuals", {}) as Dictionary).duplicate(true),
				"endEffectPlayed": true, "idleEffectActive": false, "legacyTrailEffect": false
			})
		fx["life"] = 0.0

static func update_moderator_fortress_fx(fx: Dictionary, delta: float, enemies: Array, destructibles: Array, enemy_bullets: Array, killed_enemies: Array, destroyed_boxes: Array, hit_effects: Array, feedback: Dictionary, owner_context: Dictionary = {}) -> void:
	_update_front_shield_fx(fx, delta, enemies, destructibles, enemy_bullets, killed_enemies, destroyed_boxes, hit_effects, feedback, owner_context)

static func update_moderator_fortress_shockwave_fx(fx: Dictionary, enemies: Array, _enemy_bullets: Array, killed_enemies: Array, hit_effects: Array, feedback: Dictionary) -> void:
	if bool(fx.get("shockwaveResolved", false)):
		return
	fx["shockwaveResolved"] = true
	var center := Vector2(fx.get("pos", Vector2.ZERO))
	var direction := Vector2(fx.get("dir", Vector2.RIGHT)).normalized()
	if direction.length() < 0.1:
		direction = Vector2.RIGHT
	var hit_next_times: Dictionary = fx.get("hitNextTimes", {}) as Dictionary
	var barrier_requests: Array = feedback.get("barrierHitRequests", []) as Array
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if not _stage2_alive_enemy(enemy):
			continue
		var enemy_pos := Vector2(enemy.get("pos", Vector2.ZERO))
		if not shield_fan_contains_point(center, direction, float(fx.get("radius", 100.0)), float(fx.get("arcDegrees", 220.0)), enemy_pos, float(enemy.get("radius", 20.0))):
			continue
		var token := _stage2_entity_token(enemy)
		if float(hit_next_times.get(token, -INF)) > 0.0:
			continue
		hit_next_times[token] = maxf(float(hit_next_times.get(token, -INF)), 0.35)
		var push_dir := (enemy_pos - Vector2(fx.get("playerPos", center))).normalized()
		if push_dir.length() < 0.1:
			push_dir = direction
		var hit_result := _apply_enemy_hit(enemy, float(fx.get("damage", 0.0)), push_dir, float(fx.get("knockback", 0.0)) if bool(enemy.get("canBeKnockedBack", true)) and not _is_boss_enemy(enemy) else 0.0, killed_enemies, hit_effects, barrier_requests, "moderator_fortress")
		if hit_result != HIT_NONE:
			hit_effects.append({"kind": "moderator_fortress_hit", "owner": "moderator_fortress", "weaponId": "moderator_fortress", "pos": enemy_pos, "dir": push_dir, "life": 0.19, "maxLife": 0.19, "visuals": (fx.get("visuals", {}) as Dictionary).duplicate(true)})
			if hit_result == HIT_DAMAGED:
				_merge_reaction_result(feedback, {"enemyDamaged": true, "weaponCommentKind": "moderator_fortress"})
	fx["hitNextTimes"] = hit_next_times

static func _baton_direction_for_step(_step: int, weapon: Dictionary, context: Dictionary) -> Dictionary:
	var player_pos := Vector2(context.get("playerPos", Vector2.ZERO))
	var enemies: Array = context.get("enemies", []) as Array
	var shape := fansa_attack_shape(weapon, int(weapon.get("level", 1)), context)
	var radius := float(shape.get("radius", 110.0))
	var arc := float(shape.get("arcDegrees", 130.0))
	var origin_offset := float(shape.get("originOffset", 25.0))
	var fallback := _fansa_fallback_direction(context)
	var boss_target: Dictionary = {}
	var boss_surface_distance := INF
	var normal_target: Dictionary = {}
	var normal_surface_distance := INF
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if not _stage2_alive_enemy(enemy):
			continue
		var enemy_direction := _fansa_target_direction(enemy, player_pos, fallback)
		var attack_origin := _fansa_attack_origin(player_pos, enemy_direction, origin_offset)
		var hurt_radius := EnemySystem.weapon_hurt_radius(enemy)
		var surface_distance := maxf(0.0, attack_origin.distance_to(Vector2(enemy.get("pos", player_pos))) - hurt_radius)
		if surface_distance > radius + 0.001:
			continue
		if _is_boss_enemy(enemy):
			if surface_distance < boss_surface_distance:
				boss_surface_distance = surface_distance
				boss_target = enemy
		elif surface_distance < normal_surface_distance:
			normal_surface_distance = surface_distance
			normal_target = enemy
	if not boss_target.is_empty():
		var boss_direction := _fansa_target_direction(boss_target, player_pos, fallback)
		return {"found": true, "dir": boss_direction, "radius": radius, "arc": arc, "originOffset": origin_offset, "useHurtboxOverlap": bool(shape.get("useHurtboxOverlap", true)), "targetType": "boss", "targetSurfaceInRange": true, "targetSurfaceDistance": boss_surface_distance}
	if not normal_target.is_empty():
		var normal_direction := _fansa_target_direction(normal_target, player_pos, fallback)
		return {"found": true, "dir": normal_direction, "radius": radius, "arc": arc, "originOffset": origin_offset, "useHurtboxOverlap": bool(shape.get("useHurtboxOverlap", true)), "targetType": "enemy", "targetSurfaceInRange": true, "targetSurfaceDistance": normal_surface_distance}
	var nearest_box := _stage2_nearest_box(context.get("destructibles", []) as Array, player_pos, radius)
	if not nearest_box.is_empty():
		var box_direction := (Vector2(nearest_box.get("pos", player_pos)) - player_pos).normalized()
		if box_direction.length() < 0.1:
			box_direction = fallback
		return {"found": true, "dir": box_direction, "radius": radius, "arc": arc, "originOffset": origin_offset, "useHurtboxOverlap": bool(shape.get("useHurtboxOverlap", true)), "targetType": "destructible", "targetSurfaceInRange": true}
	return {"found": true, "dir": fallback, "radius": radius, "arc": arc, "originOffset": origin_offset, "useHurtboxOverlap": bool(shape.get("useHurtboxOverlap", true)), "targetType": "fallback", "targetSurfaceInRange": false}

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
	var attack_direction := Vector2(selection.get("dir", Vector2.RIGHT)).normalized()
	var attack_range := float(selection.get("radius", 110.0))
	var attack_arc := float(selection.get("arc", 50.0))
	var attack_origin := _fansa_attack_origin(player_pos, attack_direction, float(selection.get("originOffset", 25.0)))
	var enemy_hit_ids: Dictionary = {}
	var hit_box_ids: Dictionary = {}
	var enemy_hit_count := _apply_arc_damage(context.get("enemies", []) as Array, attack_origin, attack_direction, attack_range, attack_arc, damage, knockback, killed, hit_effects, barrier_requests, weapon_id, {"hitEnemyIds": enemy_hit_ids, "useHurtboxOverlap": bool(selection.get("useHurtboxOverlap", true))})
	var box_hit_count := _apply_arc_damage_to_boxes(context.get("destructibles", []) as Array, attack_origin, attack_direction, attack_range, attack_arc, result["destroyedBoxes"] as Array, hit_effects, hit_box_ids, true)
	var hit_count := enemy_hit_count + box_hit_count
	var attack_serial := int(state.get("attackSerial", 0)) + 1
	state["attackSerial"] = attack_serial
	state["comboStep"] = (step + 1) % 3
	states[weapon_id] = state
	timers[weapon_id] = _stage2_interval(weapon, context, 0.55)
	if enemy_hit_count > 0:
		_merge_reaction_result(result, {"enemyDamaged": true, "weaponCommentKind": weapon_id})
	var hit_role := "swingRight" if step == 0 else ("swingLeft" if step == 1 else "finisher")
	var hit_life := _stage2_visual_duration(weapon, hit_role, 0.24 if step != 2 else 0.34)
	var shape := fansa_attack_shape(weapon, int(weapon.get("level", 1)), context)
	var hitbox_duration := float(shape.get("hitboxDuration", 0.18))
	var combo_se_entries: Array = weapon.get("comboAttackSe", []) as Array
	var combo_se: Dictionary = combo_se_entries[step] as Dictionary if step < combo_se_entries.size() and combo_se_entries[step] is Dictionary else {}
	hit_effects.append({"kind": "fansa_baton_hit", "owner": weapon_id, "weaponId": weapon_id, "attackInstanceId": "%s:%d" % [weapon_id, attack_serial], "pos": player_pos, "attackOrigin": attack_origin, "dir": attack_direction, "comboStep": step, "level": int(weapon.get("level", 1)), "range": attack_range, "arcAngle": attack_arc, "originOffset": float(selection.get("originOffset", 25.0)), "useHurtboxOverlap": bool(selection.get("useHurtboxOverlap", true)), "targetType": String(selection.get("targetType", "fallback")), "targetSurfaceInRange": bool(selection.get("targetSurfaceInRange", false)), "targetSurfaceDistance": float(selection.get("targetSurfaceDistance", INF)), "attackAreaActive": true, "hitboxDuration": hitbox_duration, "hitboxRemaining": hitbox_duration, "damage": damage, "knockback": knockback, "hitEnemyIds": enemy_hit_ids, "hitBoxIds": hit_box_ids, "recoveryMultiplier": float(weapon.get("recoveryMultiplier", 1.0)), "count": hit_count, "damageApplied": hit_count > 0, "life": hit_life, "maxLife": hit_life, "activationSePath": String(combo_se.get("path", "")), "activationSeVolumeDb": float(combo_se.get("volumeDb", 0.0)), "visuals": (weapon.get("visuals", {}) as Dictionary).duplicate(true)})
	if step == 2 and bool(weapon.get("crossFollowup", false)):
		var normal_damage := _stage2_base_damage(weapon) * float(weapon.get("normalDamageCoefficient", 0.55)) * float(weapon.get("normalDamageMultiplier", 1.0)) * float(context.get("damageRate", 1.0))
		var cross_range := float(selection.get("radius", 170.0)) * float(weapon.get("crossRangeRatio", 0.85))
		var cross_life := _stage2_visual_duration(weapon, "xSlash", 0.30)
		hit_effects.append({"kind": "fansa_baton_cross_followup", "owner": weapon_id, "weaponId": weapon_id, "attackInstanceId": "%s:%d:x" % [weapon_id, attack_serial], "pos": player_pos, "attackOrigin": attack_origin, "dir": attack_direction, "level": int(weapon.get("level", 1)), "range": cross_range, "arcAngle": float(weapon.get("crossArcAngle", 70.0)) * _stage2_coverage_rate(context), "originOffset": float(selection.get("originOffset", 25.0)), "damage": normal_damage, "knockback": 0.0, "delay": float(weapon.get("crossDelay", 0.15)), "life": cross_life, "maxLife": cross_life, "hitEnemyIds": {}, "hitBoxIds": {}, "visuals": (weapon.get("visuals", {}) as Dictionary).duplicate(true)})
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
	var attack_origin := _fansa_attack_origin(player_pos, direction, float(selection.get("originOffset", 25.0)))
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
	var main_hit_ids: Dictionary = {}
	var main_box_hit_ids: Dictionary = {}
	var main_visual_context := {"attackInstanceId": "%s:%d:main" % [weapon_id, attack_serial], "sparkRole": main_spark_role, "visuals": visuals, "sparkHitIds": main_spark_ids, "hitEnemyIds": main_hit_ids}
	var hits := _apply_arc_damage(context.get("enemies", []) as Array, attack_origin, direction, attack_range, attack_arc, damage, knockback, killed, hit_effects, barriers, weapon_id, main_visual_context)
	var box_hits := _apply_arc_damage_to_boxes(context.get("destructibles", []) as Array, attack_origin, direction, attack_range, attack_arc, result["destroyedBoxes"] as Array, hit_effects, main_box_hit_ids, true)
	if hits > 0:
		_merge_reaction_result(result, {"enemyDamaged": true, "weaponCommentKind": weapon_id})
	state["comboStep"] = (step + 1) % 3
	states[weapon_id] = state
	timers[weapon_id] = _stage2_interval(weapon, context, 0.47)
	var main_life := _stage2_visual_duration(weapon, main_spark_role, 0.24 if step < 2 else 0.34)
	hit_effects.append({"kind": "fansa_climax_hit", "owner": weapon_id, "weaponId": weapon_id, "attackInstanceId": "%s:%d:main" % [weapon_id, attack_serial], "pos": player_pos, "attackOrigin": attack_origin, "origin": attack_origin, "dir": direction, "comboStep": step, "range": attack_range, "arcAngle": attack_arc, "originOffset": float(selection.get("originOffset", 25.0)), "count": hits + box_hits, "hitEnemyIds": main_hit_ids, "hitBoxIds": main_box_hit_ids, "life": main_life, "maxLife": main_life, "visuals": visuals.duplicate(true)})
	if step < 2:
		var echo_life := _stage2_visual_duration(weapon, "echo", 0.22)
		hit_effects.append({"kind": "fansa_climax_echo", "owner": weapon_id, "weaponId": weapon_id, "attackInstanceId": "%s:%d:echo" % [weapon_id, attack_serial], "pos": player_pos, "dir": direction, "origin": attack_origin, "range": attack_range, "arcAngle": attack_arc, "originOffset": float(selection.get("originOffset", 25.0)), "damage": base_damage * float(weapon.get("echoDamageCoefficient", 0.30)), "delay": float(weapon.get("echoDelay", 0.12)), "hitEnemyIds": {}, "hitBoxIds": {}, "sparkHitIds": {}, "applied": false, "life": echo_life, "maxLife": echo_life, "visuals": visuals.duplicate(true)})
	else:
		var x_life := _stage2_visual_duration(weapon, "xSlash", 0.30)
		var wave_life := _stage2_visual_duration(weapon, "wave", 0.28)
		hit_effects.append({"kind": "fansa_climax_x", "owner": weapon_id, "weaponId": weapon_id, "attackInstanceId": "%s:%d:x" % [weapon_id, attack_serial], "pos": player_pos, "origin": attack_origin, "dir": direction, "range": attack_range, "arcAngle": attack_arc, "originOffset": float(selection.get("originOffset", 25.0)), "damage": base_damage * float(weapon.get("xDamageCoefficient", 0.80)), "hitEnemyIds": {}, "hitBoxIds": {}, "sparkHitIds": {}, "applied": false, "life": x_life, "maxLife": x_life, "visuals": visuals.duplicate(true)})
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
		# Keep bosses out of the capture list, but route them through the existing
		# finish step so bossReelDamage and the centered explosion can resolve.
		fx["caughtTokens"] = []
		fx["phase"] = "throwing"
		fx["phaseTimer"] = 0.0
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
	if bool(context.get("normalWeaponsDisabled", false)) or bool(context.get("weaponMute", false)) or _buzz_active_cast(context, weapon):
		timers[weapon_id] = 0.0 if bool(context.get("normalWeaponsDisabled", false)) or bool(context.get("weaponMute", false)) else _stage2_retry_delay(weapon)
		return result
	var selection := _buzz_select_target(weapon, context)
	if not bool(selection.get("found", false)):
		timers[weapon_id] = _stage2_retry_delay(weapon)
		return result
	var target: Dictionary = selection.get("target", {}) as Dictionary
	var target_type := String(selection.get("targetType", "enemy"))
	var target_is_box := target_type == "destructible"
	var player_pos := Vector2(context.get("playerPos", Vector2.ZERO))
	var target_pos := Vector2(target.get("pos", player_pos))
	var visuals := weapon.get("visuals", {}) as Dictionary
	var coverage := _stage2_coverage_rate(context)
	var level := int(weapon.get("level", 1))
	var item_config := rod_collection_config_for_level(weapon, level)
	item_config["attractRadius"] = _rod_collection_radius(item_config, context)
	var base_damage := _stage2_base_damage(weapon) * float(context.get("damageRate", 1.0))
	var fx := {
		"kind": "buzz_thumbnail_rod_cast", "owner": weapon_id, "weaponId": weapon_id, "phase": "casting",
		"pos": player_pos, "previousPos": player_pos, "dir": (target_pos - player_pos).normalized(),
		"targetReference": {} if target_is_box else target, "targetToken": "" if target_is_box else _stage2_entity_token(target),
		"targetBoxUid": int(target.get("uid", -1)) if target_is_box else -1, "lastTargetPos": target_pos,
		"bossTarget": String(selection.get("targetType", "enemy")) == "boss", "reelDestination": player_pos, "displayPlayerPos": player_pos,
		"phaseTimer": 0.0, "age": 0.0, "life": 10.0, "maxLife": 10.0, "level": level,
		"collectionClaimToken": _rod_next_claim_token(weapon_id, timers), "itemCollectionConfig": item_config,
		"itemAttractRadius": float(item_config.get("attractRadius", 0.0)), "itemReturnSpeed": rod_collection_effective_return_speed(weapon, context), "itemSearchDone": false, "claimedCollectibles": [], "collectionLines": [], "collectionParticles": [],
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

static func update_buzz_thumbnail_rod_fx(fx: Dictionary, delta: float, enemies: Array, killed_enemies: Array, hit_effects: Array, feedback: Dictionary, player_pos: Vector2, destructibles: Array = [], destroyed_boxes: Array = []) -> void:
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
			else:
				var target_box_uid := int(fx.get("targetBoxUid", -1))
				if target_box_uid >= 0:
					for box_item in destructibles:
						var box: Dictionary = box_item as Dictionary
						if not _stage2_alive_box(box) or int(box.get("uid", -1)) != target_box_uid:
							continue
						DestructibleSystemScript.damage_box(box, 1.0, destroyed_boxes, hit_effects)
						break
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
	# Follow the player's current position instead of the snapshot taken when
	# reeling started. Otherwise moving during the reel can make the lure finish
	# at an old position and release every claimed collectible there.
	fx["reelDestination"] = player_pos
	var destination := player_pos
	var to_destination := destination - position
	var reel_step := float(fx.get("reelSpeed", 1500.0)) * delta
	fx["pos"] = destination if to_destination.length() <= reel_step else position + to_destination.normalized() * reel_step
	if Vector2(fx.get("pos", position)).distance_to(destination) <= 0.01:
		# Buzz ends by setting life to zero, so complete the collectible hand-off
		# here instead of relying on the generic post-update pass to run before
		# zero-life cleanup releases the claims.
		_rod_transfer_claimed_collectibles_to_normal_pickup(fx, player_pos)
		fx["life"] = 0.0

static func update_fansa_climax_echo_fx(fx: Dictionary, enemies: Array, destructibles: Array, killed_enemies: Array, destroyed_boxes: Array, hit_effects: Array, feedback: Dictionary) -> void:
	if bool(fx.get("applied", false)):
		return
	fx["applied"] = true
	var origin := Vector2(fx.get("origin", fx.get("pos", Vector2.ZERO)))
	var direction := Vector2(fx.get("dir", Vector2.RIGHT)).normalized()
	var spark_ids: Dictionary = fx.get("sparkHitIds", {}) as Dictionary
	var hit_ids: Dictionary = fx.get("hitEnemyIds", {}) as Dictionary
	var hit_box_ids: Dictionary = fx.get("hitBoxIds", {}) as Dictionary
	var visual_context := {"attackInstanceId": String(fx.get("attackInstanceId", "fansa_climax:echo")), "sparkRole": "echo", "visuals": fx.get("visuals", {}) as Dictionary, "sparkHitIds": spark_ids, "hitEnemyIds": hit_ids}
	var hits := _apply_arc_damage(enemies, origin, direction, float(fx.get("range", 125.0)), float(fx.get("arcAngle", 55.0)), float(fx.get("damage", 0.0)), 0.0, killed_enemies, hit_effects, feedback.get("barrierHitRequests", []) as Array, "fansa_climax", visual_context)
	_apply_arc_damage_to_boxes(destructibles, origin, direction, float(fx.get("range", 125.0)), float(fx.get("arcAngle", 55.0)), destroyed_boxes, hit_effects, hit_box_ids, true)
	fx["sparkHitIds"] = spark_ids
	fx["hitEnemyIds"] = hit_ids
	fx["hitBoxIds"] = hit_box_ids
	if hits > 0:
		_merge_reaction_result(feedback, {"enemyDamaged": true, "weaponCommentKind": "fansa_climax"})

static func update_fansa_climax_x_fx(fx: Dictionary, enemies: Array, destructibles: Array, killed_enemies: Array, destroyed_boxes: Array, hit_effects: Array, feedback: Dictionary) -> void:
	if bool(fx.get("applied", false)):
		return
	fx["applied"] = true
	var spark_ids: Dictionary = fx.get("sparkHitIds", {}) as Dictionary
	var hit_ids: Dictionary = fx.get("hitEnemyIds", {}) as Dictionary
	var hit_box_ids: Dictionary = fx.get("hitBoxIds", {}) as Dictionary
	var visual_context := {"attackInstanceId": String(fx.get("attackInstanceId", "fansa_climax:x")), "sparkRole": "xSlash", "visuals": fx.get("visuals", {}) as Dictionary, "sparkHitIds": spark_ids, "hitEnemyIds": hit_ids}
	var origin := Vector2(fx.get("origin", fx.get("pos", Vector2.ZERO)))
	var hits := _apply_arc_damage(enemies, origin, Vector2(fx.get("dir", Vector2.RIGHT)), float(fx.get("range", 180.0)), float(fx.get("arcAngle", 180.0)), float(fx.get("damage", 0.0)), 0.0, killed_enemies, hit_effects, feedback.get("barrierHitRequests", []) as Array, "fansa_climax", visual_context)
	_apply_arc_damage_to_boxes(destructibles, origin, Vector2(fx.get("dir", Vector2.RIGHT)), float(fx.get("range", 180.0)), float(fx.get("arcAngle", 180.0)), destroyed_boxes, hit_effects, hit_box_ids, true)
	fx["sparkHitIds"] = spark_ids
	fx["hitEnemyIds"] = hit_ids
	fx["hitBoxIds"] = hit_box_ids
	if hits > 0:
		_merge_reaction_result(feedback, {"enemyDamaged": true, "weaponCommentKind": "fansa_climax"})

static func update_fansa_climax_fan_wave_fx(fx: Dictionary, enemies: Array, destructibles: Array, killed_enemies: Array, destroyed_boxes: Array, hit_effects: Array, feedback: Dictionary) -> void:
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
		if bool(hit_ids.get(token, false)) or Vector2(enemy.get("pos", Vector2.ZERO)).distance_to(center) > radius + EnemySystem.weapon_hurt_radius(enemy):
			continue
		var hit_result := _apply_enemy_hit(enemy, float(fx.get("damage", 0.0)), (Vector2(enemy.get("pos", center)) - center).normalized(), float(fx.get("knockback", 0.0)), killed_enemies, hit_effects, feedback.get("barrierHitRequests", []) as Array, "fansa_climax")
		if hit_result != HIT_NONE:
			hit_ids[token] = true
			_append_fansa_climax_spark_fx(hit_effects, enemy, fx.get("visuals", {}) as Dictionary, String(fx.get("attackInstanceId", "fansa_climax:wave")), "wave", spark_ids)
			if hit_result == HIT_DAMAGED:
				_merge_reaction_result(feedback, {"enemyDamaged": true, "weaponCommentKind": "fansa_climax"})
	fx["hitEnemyIds"] = hit_ids
	fx["sparkHitIds"] = spark_ids
	_apply_circle_damage_to_boxes(destructibles, center, radius, destroyed_boxes, hit_effects)

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
	var nearest_enemy: Dictionary = {}
	var nearest_enemy_distance := INF
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if not _stage2_alive_enemy(enemy):
			continue
		var distance := player_pos.distance_to(Vector2(enemy.get("pos", Vector2.ZERO)))
		if distance <= max_range and distance < nearest_enemy_distance:
			nearest_enemy = enemy
			nearest_enemy_distance = distance
	if not nearest_enemy.is_empty():
		return {"found": true, "target": nearest_enemy, "targetType": "enemy"}
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
	if bool(context.get("normalWeaponsDisabled", false)) or bool(context.get("weaponMute", false)) or _rod_active_cast(context, weapon):
		timers[weapon_id] = 0.0 if bool(context.get("normalWeaponsDisabled", false)) or bool(context.get("weaponMute", false)) else _stage2_retry_delay(weapon)
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
	var item_config := rod_collection_config_for_level(weapon, int(weapon.get("level", 1)))
	item_config["attractRadius"] = _rod_collection_radius(item_config, context)
	var cast_se: Dictionary = weapon.get("castSe", {}) as Dictionary
	var reel_se: Dictionary = weapon.get("reelSe", {}) as Dictionary
	var fx := {
		"kind": "tsuri_rod_cast", "owner": weapon_id, "weaponId": weapon_id, "phase": "casting",
		"activationSePath": String(cast_se.get("path", "")), "activationSeVolumeDb": float(cast_se.get("volumeDb", 0.0)),
		"reelSePath": String(reel_se.get("path", "")), "reelSeVolumeDb": float(reel_se.get("volumeDb", 0.0)),
		"pos": player_pos, "previousPos": player_pos, "dir": (target_pos - player_pos).normalized(),
		"targetReference": {} if target_is_box else target, "targetToken": "" if target_is_box else _stage2_entity_token(target),
		"targetBoxUid": int(target.get("uid", -1)) if target_is_box else -1, "lastTargetPos": target_pos,
		"reelDestination": player_pos, "displayPlayerPos": player_pos, "phaseTimer": 0.0, "age": 0.0, "life": 8.0, "maxLife": 8.0,
		"collectionClaimToken": _rod_next_claim_token(weapon_id, timers), "itemCollectionConfig": item_config,
		"itemAttractRadius": float(item_config.get("attractRadius", 0.0)), "itemReturnSpeed": rod_collection_effective_return_speed(weapon, context), "itemSearchDone": false, "claimedCollectibles": [], "collectionLines": [], "collectionParticles": [],
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

static func _starlight_hit_fx(pos: Vector2, premium: bool = false, owner_id: String = "") -> Dictionary:
	var fx := {
		"kind": "starlight_hit",
		"pos": pos,
		"life": 0.24 if not premium else 0.30,
		"maxLife": 0.24 if not premium else 0.30,
		"premium": premium
	}
	_tag_hit_effects_for_weapon([fx], 0, owner_id)
	return fx

static func _starlight_burst_fx(pos: Vector2, radius: float, owner_id: String = "") -> Dictionary:
	var fx := {
		"kind": "starlight_burst",
		"pos": pos,
		"life": 0.38,
		"maxLife": 0.38,
		"radius": radius
	}
	_tag_hit_effects_for_weapon([fx], 0, owner_id)
	return fx

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

static func _starlight_defeat_fx(enemy: Dictionary, premium: bool = false, owner_id: String = "") -> Dictionary:
	var tier: int = _starlight_defeat_tier(enemy)
	var max_life: float = 0.46 + 0.10 * float(tier) + (0.08 if premium else 0.0)
	var fx := {
		"kind": "starlight_defeat",
		"pos": Vector2(enemy.get("pos", Vector2.ZERO)),
		"life": max_life,
		"maxLife": max_life,
		"radius": float(enemy.get("radius", 22.0)),
		"tier": tier,
		"premium": premium
	}
	_tag_hit_effects_for_weapon([fx], 0, owner_id)
	return fx

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
	barrier_hit_requests: Array = [],
	owner_id: String = ""
) -> int:
	var radius: float = _premium_superchat_explosion_radius(weapon, context)
	var damage: float = float(weapon.get("premiumExplosionDamage", 7.0))
	var knockback: float = _weapon_knockback_for_context(weapon, context) * 0.28
	var hits: int = _apply_starlight_circle_damage(enemies, center, radius, damage, knockback, killed_enemies, hit_effects, barrier_hit_requests, owner_id)
	_apply_circle_damage_to_boxes(destructibles, center, radius, destroyed_boxes, hit_effects, owner_id)
	hit_effects.append(_starlight_burst_fx(center, radius, owner_id))
	return hits

static func _apply_starlight_circle_damage(enemies: Array, center: Vector2, radius: float, damage: float, knockback: float, killed_enemies: Array, hit_effects: Array, barrier_hit_requests: Array = [], hit_source: String = "") -> int:
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
			if _apply_enemy_hit(enemy, damage, hit_dir, knockback, killed_enemies, hit_effects, barrier_hit_requests, hit_source) == HIT_DAMAGED:
				hits += 1
				if _starlight_enemy_defeated(enemy):
					hit_effects.append(_starlight_defeat_fx(enemy, true, hit_source))
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
	result: Dictionary,
	owner_id: String = ""
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
	var hit_count: int = _apply_circle_damage(enemies, player_pos, pulse_radius, pulse_damage, float(context["knockback"]) * 0.20, killed_enemies, hit_effects, result["barrierHitRequests"] as Array, owner_id)
	var pulled_exp: int = _nudge_exp_orbs_for_maro_pulse(context.get("expOrbs", []) as Array, player_pos, _maro_pulse_exp_pull_radius(weapon), float(context["delta"]))
	_request_weapon_hit_reaction(result, weapon, hit_count, hit_count)
	var pulse_fx := _maro_comment_pulse_fx(player_pos, pulse_radius, pulled_exp)
	if owner_id != "":
		pulse_fx["owner"] = owner_id
		pulse_fx["weaponId"] = owner_id
	hit_effects.append(pulse_fx)

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
	var owner_id := String(weapon.get("id", ""))
	if owner_id != "":
		bullet["owner"] = owner_id
		bullet["weaponId"] = owner_id
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

static func _listener_assembly_distribution(fx: Dictionary) -> Dictionary:
	var defaults := {
		"approachOffset": 24.0,
		"approachPhaseStepDegrees": 137.5,
		"motionPhaseStepRadians": 2.35
	}
	var value: Variant = fx.get("targetDistribution", {})
	if value is Dictionary:
		var resolved: Dictionary = defaults.duplicate(true)
		for key in defaults.keys():
			if (value as Dictionary).has(key):
				resolved[key] = (value as Dictionary)[key]
		return resolved
	return defaults

static func _listener_assembly_target_candidates(fx: Dictionary, enemies: Array) -> Array:
	var candidates: Array = []
	var origin := Vector2(fx.get("pos", Vector2.ZERO))
	var search_range := maxf(0.0, float(fx.get("searchRange", 520.0)))
	var search_range_sq := search_range * search_range
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if not _stage2_alive_enemy(enemy):
			continue
		var enemy_pos := Vector2(enemy.get("pos", Vector2.ZERO))
		var distance_sq := origin.distance_squared_to(enemy_pos)
		if distance_sq > search_range_sq:
			continue
		candidates.append({
			"enemy": enemy,
			"token": _stage2_entity_token(enemy),
			"distanceSq": distance_sq
		})
	return candidates

static func _prepare_listener_assembly_target_assignments(hit_fx: Array, enemies: Array) -> void:
	var records: Array = []
	var order_index := 0
	for fx_item in hit_fx:
		var fx: Dictionary = fx_item as Dictionary
		if String(fx.get("kind", "")) != "listener_assembly" or float(fx.get("life", 0.0)) <= 0.0 or float(fx.get("delay", 0.0)) > 0.0:
			order_index += 1
			continue
		var candidates := _listener_assembly_target_candidates(fx, enemies)
		records.append({
			"fx": fx,
			"candidates": candidates,
			"serial": int(fx.get("unitSerial", order_index + 1)),
			"order": order_index,
			"currentToken": String(fx.get("targetToken", ""))
		})
		order_index += 1
	records.sort_custom(func(a: Dictionary, b: Dictionary):
			var a_count := (a.get("candidates", []) as Array).size()
			var b_count := (b.get("candidates", []) as Array).size()
			if a_count != b_count:
				return a_count < b_count
			var a_serial := int(a.get("serial", 0))
			var b_serial := int(b.get("serial", 0))
			if a_serial != b_serial:
				return a_serial < b_serial
			return int(a.get("order", 0)) < int(b.get("order", 0))
	)

	var reservation_counts: Dictionary = {}
	for record_value in records:
		var record: Dictionary = record_value as Dictionary
		var fx: Dictionary = record.get("fx", {}) as Dictionary
		var candidates: Array = record.get("candidates", []) as Array
		if candidates.is_empty():
			fx.erase("targetToken")
			continue
		var origin := Vector2(fx.get("pos", Vector2.ZERO))
		var current_token := String(record.get("currentToken", ""))
		candidates.sort_custom(func(a: Dictionary, b: Dictionary):
			var a_token := String(a.get("token", ""))
			var b_token := String(b.get("token", ""))
			var a_reservations := int(reservation_counts.get(a_token, 0))
			var b_reservations := int(reservation_counts.get(b_token, 0))
			if a_reservations != b_reservations:
				return a_reservations < b_reservations
			var a_distance := float(a.get("distanceSq", origin.distance_squared_to(Vector2.ZERO)))
			var b_distance := float(b.get("distanceSq", origin.distance_squared_to(Vector2.ZERO)))
			if not is_equal_approx(a_distance, b_distance):
				return a_distance < b_distance
			var a_current := a_token == current_token
			var b_current := b_token == current_token
			if a_current != b_current:
				return a_current
			return a_token < b_token
		)
		var selected: Dictionary = candidates[0] as Dictionary
		var selected_token := String(selected.get("token", ""))
		fx["targetToken"] = selected_token
		reservation_counts[selected_token] = int(reservation_counts.get(selected_token, 0)) + 1

static func _listener_assembly_target_for_fx(fx: Dictionary, enemies: Array) -> Dictionary:
	var target_token := String(fx.get("targetToken", ""))
	if target_token == "":
		return {}
	var origin := Vector2(fx.get("pos", Vector2.ZERO))
	var search_range := maxf(0.0, float(fx.get("searchRange", 520.0)))
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if not _stage2_alive_enemy(enemy) or _stage2_entity_token(enemy) != target_token:
			continue
		if origin.distance_to(Vector2(enemy.get("pos", Vector2.ZERO))) > search_range:
			return {}
		return enemy
	return {}

static func _listener_assembly_approach_point(fx: Dictionary, enemy: Dictionary) -> Vector2:
	var distribution := _listener_assembly_distribution(fx)
	var requested_offset := maxf(0.0, float(distribution["approachOffset"]))
	var enemy_radius := maxf(0.0, float(enemy.get("radius", 20.0)))
	var hit_radius := maxf(0.0, float(fx.get("hitRadius", 18.0)))
	var safe_offset := minf(requested_offset, maxf(0.0, enemy_radius + hit_radius - 0.001))
	var phase := float(fx.get("approachPhase", 0.0))
	return Vector2(enemy.get("pos", Vector2.ZERO)) + Vector2.RIGHT.rotated(phase) * safe_offset

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
			"triggerRadius": maxf(0.0, float(weapon.get("triggerRadius", 28.0))),
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

static func _apply_laser_damage(enemies: Array, destructibles: Array, enemy_bullets: Array, start: Vector2, dir: Vector2, length: float, width: float, damage: float, knockback: float, killed_enemies: Array, destroyed_boxes: Array, hit_effects: Array, barrier_hit_requests: Array = [], clearable_only: bool = false, hit_source: String = "") -> int:
	var hits: int = 0
	var half_width: float = width * 0.5
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if float(enemy.get("hp", 0.0)) <= 0.0:
			continue
		var enemy_pos: Vector2 = Vector2(enemy["pos"])
		if not _laser_hit(enemy_pos, float(enemy.get("radius", 20.0)), start, dir, length, half_width):
			continue
		if _apply_enemy_hit(enemy, damage, dir, knockback * 0.55, killed_enemies, hit_effects, barrier_hit_requests, hit_source) == HIT_DAMAGED:
			hits += 1
	for box_item in destructibles:
		var box: Dictionary = box_item as Dictionary
		if float(box.get("hp", 0.0)) <= 0.0:
			continue
		if _laser_hit(Vector2(box["pos"]), float(box.get("radius", 24.0)), start, dir, length, half_width):
			var fx_start := hit_effects.size()
			DestructibleSystemScript.damage_box(box, 1.0, destroyed_boxes, hit_effects)
			_tag_hit_effects_for_weapon(hit_effects, fx_start, hit_source)
			hits += 1
	for bullet_item in enemy_bullets:
		var bullet: Dictionary = bullet_item as Dictionary
		if float(bullet.get("life", 0.0)) <= 0.0:
			continue
		if clearable_only and not _stage2_shield_bullet_clearable(bullet):
			continue
		if _laser_hit(Vector2(bullet["pos"]), float(bullet.get("hitRadius", 16.0)), start, dir, length, half_width):
			bullet["life"] = -1.0
			var bullet_fx := _bullet_pop_fx(Vector2(bullet["pos"]))
			if clearable_only:
				bullet_fx["kind"] = "stage2_bullet_clear"
				bullet_fx["owner"] = hit_source
				bullet_fx["weaponId"] = hit_source
			hit_effects.append(bullet_fx)
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

static func _apply_circle_damage(enemies: Array, center: Vector2, radius: float, damage: float, knockback: float, killed_enemies: Array, hit_effects: Array, barrier_hit_requests: Array = [], hit_source: String = "") -> int:
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
			if _apply_enemy_hit(enemy, damage, hit_dir, knockback, killed_enemies, hit_effects, barrier_hit_requests, hit_source) == HIT_DAMAGED:
				hits += 1
	return hits

static func _tag_hit_effects_for_weapon(hit_effects: Array, start_index: int, owner_id: String) -> void:
	if owner_id == "":
		return
	for index in range(start_index, hit_effects.size()):
		var fx: Dictionary = hit_effects[index] as Dictionary
		fx["owner"] = owner_id
		fx["weaponId"] = owner_id

static func _apply_circle_damage_to_boxes(destructibles: Array, center: Vector2, radius: float, destroyed_boxes: Array, hit_effects: Array, owner_id: String = "") -> void:
	for box_item in destructibles:
		var box: Dictionary = box_item as Dictionary
		if float(box.get("hp", 0.0)) <= 0.0:
			continue
		var box_radius: float = radius + float(box.get("radius", 24.0))
		if center.distance_squared_to(Vector2(box["pos"])) <= box_radius * box_radius:
			var fx_start := hit_effects.size()
			DestructibleSystemScript.damage_box(box, 1.0, destroyed_boxes, hit_effects)
			_tag_hit_effects_for_weapon(hit_effects, fx_start, owner_id)

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
	var safe_direction := dir.normalized()
	if safe_direction.length() < 0.1:
		safe_direction = Vector2.RIGHT
	var hit_ids: Dictionary = visual_context.get("hitEnemyIds", {}) as Dictionary
	var use_hurtbox_overlap := bool(visual_context.get("useHurtboxOverlap", hit_source in ["fansa_baton", "fansa_climax"]))
	var hits: int = 0
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if not _stage2_alive_enemy(enemy):
			continue
		var token := _stage2_entity_token(enemy)
		if bool(hit_ids.get(token, false)):
			continue
		var enemy_pos := Vector2(enemy.get("pos", origin))
		if use_hurtbox_overlap:
			if not fan_sector_circle_overlap(origin, safe_direction, radius, arc_angle, enemy_pos, EnemySystem.weapon_hurt_radius(enemy)):
				continue
		else:
			var to_enemy := enemy_pos - origin
			var distance_squared := to_enemy.length_squared()
			if distance_squared <= 0.01 or distance_squared > radius * radius:
				continue
			if safe_direction.dot(to_enemy / sqrt(distance_squared)) < cos(deg_to_rad(arc_angle * 0.5)):
				continue
		var push_dir := (enemy_pos - origin).normalized()
		if push_dir.length() < 0.1:
			push_dir = safe_direction
		var hit_result := _apply_enemy_hit(enemy, damage, push_dir, knockback, killed_enemies, hit_effects, barrier_hit_requests, hit_source)
		if hit_result != HIT_NONE:
			hit_ids[token] = true
			if not visual_context.is_empty():
				_append_fansa_climax_spark_fx(hit_effects, enemy, visual_context.get("visuals", {}) as Dictionary, String(visual_context.get("attackInstanceId", hit_source)), String(visual_context.get("sparkRole", "spark")), visual_context.get("sparkHitIds", {}) as Dictionary)
			if hit_result == HIT_DAMAGED:
				hits += 1
	return hits

static func _apply_arc_damage_to_boxes(destructibles: Array, origin: Vector2, dir: Vector2, radius: float, arc_angle: float, destroyed_boxes: Array, hit_effects: Array, hit_box_ids: Dictionary = {}, use_sector_overlap: bool = false) -> int:
	var safe_direction := dir.normalized()
	if safe_direction.length() < 0.1:
		safe_direction = Vector2.RIGHT
	var hits: int = 0
	for box_item in destructibles:
		var box: Dictionary = box_item as Dictionary
		if not _stage2_alive_box(box):
			continue
		var box_token := _stage2_box_token(box)
		if bool(hit_box_ids.get(box_token, false)):
			continue
		var box_pos := Vector2(box.get("pos", origin))
		if use_sector_overlap:
			if not fan_sector_circle_overlap(origin, safe_direction, radius, arc_angle, box_pos, float(box.get("radius", 24.0))):
				continue
		else:
			var to_box := box_pos - origin
			var box_hit_radius := radius + float(box.get("radius", 24.0)) * 0.55 + 10.0
			var box_distance_squared := to_box.length_squared()
			if box_distance_squared <= 0.01 or box_distance_squared > box_hit_radius * box_hit_radius:
				continue
			if safe_direction.dot(to_box / sqrt(box_distance_squared)) < cos(deg_to_rad(arc_angle * 0.5)):
				continue
		DestructibleSystemScript.damage_box(box, 1.0, destroyed_boxes, hit_effects)
		hit_box_ids[box_token] = true
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

static func _kusa_wave_bounce_fx(pos: Vector2, dir: Vector2, size_scale: float, area_rate: float = 1.0, depleted: bool = false, owner_id: String = "", weapon_id: String = "", visuals: Dictionary = {}) -> Dictionary:
	var fx := {
		"kind": "kusa_wave_bounce",
		"pos": pos,
		"dir": dir.normalized() if dir.length() > 0.1 else Vector2.RIGHT,
		"life": 0.22 if not depleted else 0.18,
		"maxLife": 0.22 if not depleted else 0.18,
		"sizeScale": size_scale,
		"attackAreaRate": area_rate,
		"depleted": depleted
	}
	if owner_id != "":
		fx["owner"] = owner_id
		fx["weaponId"] = weapon_id if weapon_id != "" else owner_id
	if not visuals.is_empty():
		fx["visuals"] = visuals.duplicate(true)
	return fx

static func _kusa_wave_reflect_or_finish(fx: Dictionary, normal: Vector2, collision_pos: Vector2, hit_effects: Array, depleted: bool = false) -> bool:
	var bounces_left: int = int(fx.get("bouncesLeft", 0))
	var size_scale: float = float(fx.get("sizeScale", 1.0))
	var area_rate: float = attack_area_rate(fx)
	var velocity: Vector2 = Vector2(fx.get("vel", Vector2.RIGHT * KUSA_WAVE_SPEED))
	var owner_id := String(fx.get("owner", ""))
	var weapon_id := String(fx.get("weaponId", owner_id))
	var visuals: Dictionary = fx.get("visuals", {}) as Dictionary
	if bounces_left <= 0 or depleted:
		fx["pos"] = collision_pos
		fx["life"] = 0.0
		hit_effects.append(_kusa_wave_bounce_fx(collision_pos, Vector2(fx.get("dir", Vector2.RIGHT)), size_scale, area_rate, true, owner_id, weapon_id, visuals))
		return false
	var reflected: Vector2 = _kusa_wave_reflect_velocity(velocity, normal)
	if reflected.length() < 0.1:
		reflected = -velocity
	var reflected_dir: Vector2 = reflected.normalized()
	fx["bouncesLeft"] = bounces_left - 1
	fx["vel"] = reflected_dir * maxf(KUSA_WAVE_SPEED * 0.55, velocity.length())
	fx["dir"] = reflected_dir
	fx["pos"] = collision_pos + reflected_dir * (4.0 + 2.0 * size_scale)
	hit_effects.append(_kusa_wave_bounce_fx(collision_pos, reflected_dir, size_scale, area_rate, false, owner_id, weapon_id, visuals))
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
	var hit_cooldown: float = maxf(0.0, float(fx.get("sameEnemyRehit", KUSA_WAVE_HIT_COOLDOWN)))
	var hit_source := String(fx.get("weaponId", ""))
	var feedback_weapon_kind := weapon_comment_kind_for_id(hit_source) if hit_source != "" else "kusa_wave"
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
		if _apply_enemy_hit(enemy, damage, dir, knockback, killed_enemies, hit_effects, barrier_hit_requests, hit_source) == HIT_DAMAGED:
			cooldowns[target_id] = hit_cooldown
			fx["hitCooldowns"] = cooldowns
			_merge_reaction_result(feedback, {
				"enemyDamaged": true,
				"screenShakePower": float(fx.get("screenShakePower", 0.0)),
				"screenShakeDuration": float(fx.get("screenShakeDuration", 0.10)),
				"hitStop": float(fx.get("hitStop", 0.0)),
				"weaponCommentKind": feedback_weapon_kind
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
		var fx_start := hit_effects.size()
		DestructibleSystemScript.damage_box(box, 1.0, destroyed_boxes, hit_effects)
		_tag_hit_effects_for_weapon(hit_effects, fx_start, hit_source)
		cooldowns[target_id] = hit_cooldown
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
	var fx_start := hit_effects.size()
	var hit_source := String(fx.get("weaponId", ""))
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
	_tag_hit_effects_for_weapon(hit_effects, fx_start, hit_source)

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
	var source := String(fx.get("weaponId", "listener_summon"))
	var hit_result := _apply_enemy_hit(target_enemy, damage, dir, float(fx.get("knockback", 0.0)) * 0.7, killed_enemies, hit_effects, feedback.get("barrierHitRequests", []) as Array, source)
	if hit_result == HIT_DAMAGED:
		_merge_reaction_result(feedback, {"enemyDamaged": true, "listenerSummonAttacked": true, "weaponCommentKind": source})
		hit_effects.append({
			"kind": "listener_burst",
			"owner": source,
			"weaponId": source,
			"pos": enemy_pos,
			"life": 0.22,
			"maxLife": 0.22,
			"visuals": (fx.get("visuals", {}) as Dictionary).duplicate(true)
		})
	fx["hitTimer"] = float(fx.get("hitCooldown", 0.70))

static func update_listener_assembly_damage(fx: Dictionary, delta: float, enemies: Array, killed_enemies: Array, hit_effects: Array, feedback: Dictionary = {}) -> void:
	var pos: Vector2 = Vector2(fx.get("pos", Vector2.ZERO))
	var hit_timer: float = maxf(0.0, float(fx.get("hitTimer", 0.0)) - delta)
	fx["hitTimer"] = hit_timer
	var target := _listener_assembly_target_for_fx(fx, enemies)
	var dir: Vector2 = Vector2(fx.get("dir", Vector2.RIGHT)).normalized()
	if dir.length() < 0.1:
		dir = Vector2.RIGHT
	if not target.is_empty():
		var approach_point := _listener_assembly_approach_point(fx, target)
		dir = (approach_point - pos).normalized()
		if dir.length() < 0.1:
			dir = (Vector2(target.get("pos", pos)) - pos).normalized()
		if dir.length() < 0.1:
			dir = Vector2(fx.get("dir", Vector2.RIGHT)).normalized()
		if dir.length() < 0.1:
			dir = Vector2.RIGHT
	pos += dir * float(fx.get("moveSpeed", 180.0)) * delta
	fx["pos"] = pos
	fx["dir"] = dir
	if target.is_empty():
		return
	var target_enemy: Dictionary = target
	if not _stage2_alive_enemy(target_enemy):
		return
	var enemy_pos := Vector2(target_enemy.get("pos", pos))
	var hit_radius := float(target_enemy.get("radius", 20.0)) + float(fx.get("hitRadius", 18.0))
	if pos.distance_squared_to(enemy_pos) > hit_radius * hit_radius or hit_timer > 0.0:
		return
	var damage := float(fx.get("damage", 0.0))
	var source := String(fx.get("weaponId", "listener_assembly"))
	var hit_direction := (enemy_pos - pos).normalized()
	if hit_direction.length() < 0.1:
		hit_direction = dir
	var hit_result := _apply_enemy_hit(target_enemy, damage, hit_direction, float(fx.get("knockback", 0.0)) * 0.7, killed_enemies, hit_effects, feedback.get("barrierHitRequests", []) as Array, source)
	if hit_result == HIT_DAMAGED:
		_merge_reaction_result(feedback, {"enemyDamaged": true, "listenerSummonAttacked": true, "weaponCommentKind": source})
		hit_effects.append({
			"kind": "listener_burst",
			"owner": source,
			"weaponId": source,
			"pos": enemy_pos,
			"life": 0.22,
			"maxLife": 0.22,
			"visuals": (fx.get("visuals", {}) as Dictionary).duplicate(true)
		})
	fx["hitTimer"] = float(fx.get("hitCooldown", 0.70))

static func update_moderator_shield_fx(fx: Dictionary, delta: float, enemies: Array, destructibles: Array, enemy_bullets: Array, killed_enemies: Array, destroyed_boxes: Array, hit_effects: Array, feedback: Dictionary, owner_context: Dictionary = {}) -> void:
	_update_front_shield_fx(fx, delta, enemies, destructibles, enemy_bullets, killed_enemies, destroyed_boxes, hit_effects, feedback, owner_context)

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
	var hit_ids: Dictionary = fx.get("hitEnemyIds", {}) as Dictionary
	var hit_box_ids: Dictionary = fx.get("hitBoxIds", {}) as Dictionary
	var origin := Vector2(fx.get("attackOrigin", fx.get("pos", Vector2.ZERO)))
	var direction := Vector2(fx.get("dir", Vector2.RIGHT)).normalized()
	var visual_context := {"hitEnemyIds": hit_ids, "useHurtboxOverlap": true}
	var hits := _apply_arc_damage(enemies, origin, direction, float(fx.get("range", 140.0)), float(fx.get("arcAngle", 70.0)), float(fx.get("damage", 0.0)), 0.0, killed_enemies, hit_effects, barrier_requests, "fansa_baton", visual_context)
	_apply_arc_damage_to_boxes(destructibles, origin, direction, float(fx.get("range", 140.0)), float(fx.get("arcAngle", 70.0)), destroyed_boxes, hit_effects, hit_box_ids, true)
	fx["hitEnemyIds"] = hit_ids
	fx["hitBoxIds"] = hit_box_ids
	if hits > 0:
		_merge_reaction_result(feedback, {"enemyDamaged": true, "weaponCommentKind": "fansa_baton"})
	fx["life"] = 0.0

static func update_fansa_baton_hit_fx(fx: Dictionary, delta: float, enemies: Array, destructibles: Array, killed_enemies: Array, destroyed_boxes: Array, hit_effects: Array, feedback: Dictionary) -> void:
	var remaining_window := float(fx.get("hitboxRemaining", 0.0))
	if remaining_window <= 0.0:
		return
	var hit_ids: Dictionary = fx.get("hitEnemyIds", {}) as Dictionary
	var hit_box_ids: Dictionary = fx.get("hitBoxIds", {}) as Dictionary
	var origin := Vector2(fx.get("attackOrigin", fx.get("pos", Vector2.ZERO)))
	var direction := Vector2(fx.get("dir", Vector2.RIGHT)).normalized()
	var visual_context := {"hitEnemyIds": hit_ids, "useHurtboxOverlap": bool(fx.get("useHurtboxOverlap", true))}
	var hits := _apply_arc_damage(enemies, origin, direction, float(fx.get("range", 110.0)), float(fx.get("arcAngle", 130.0)), float(fx.get("damage", 0.0)), float(fx.get("knockback", 0.0)), killed_enemies, hit_effects, feedback.get("barrierHitRequests", []) as Array, String(fx.get("weaponId", "fansa_baton")), visual_context)
	var box_hits := _apply_arc_damage_to_boxes(destructibles, origin, direction, float(fx.get("range", 110.0)), float(fx.get("arcAngle", 130.0)), destroyed_boxes, hit_effects, hit_box_ids, true)
	fx["hitEnemyIds"] = hit_ids
	fx["hitBoxIds"] = hit_box_ids
	fx["count"] = int(fx.get("count", 0)) + hits + box_hits
	fx["hitboxRemaining"] = maxf(0.0, remaining_window - maxf(0.0, delta))
	if hits > 0:
		_merge_reaction_result(feedback, {"enemyDamaged": true, "weaponCommentKind": String(fx.get("weaponId", "fansa_baton"))})

static func _rod_limited_turn(current: Vector2, desired: Vector2, max_turn: float) -> Vector2:
	var current_dir := current.normalized()
	if current_dir.length() < 0.1:
		current_dir = Vector2.RIGHT
	var desired_dir := desired.normalized()
	if desired_dir.length() < 0.1:
		return current_dir
	var angle := current_dir.angle_to(desired_dir)
	return current_dir.rotated(clampf(angle, -max_turn, max_turn)).normalized()

static func _append_weapon_se_request(feedback: Dictionary, action: String, path: String, volume_db: float = 0.0) -> void:
	if path == "":
		return
	var weapon_se_requests: Array = feedback.get("weaponSeRequests", []) as Array
	weapon_se_requests.append({"action": action, "path": path, "volumeDb": volume_db})
	feedback["weaponSeRequests"] = weapon_se_requests

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
	_append_weapon_se_request(feedback, "stop", String(fx.get("reelSePath", "")))
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
			_append_weapon_se_request(feedback, "play", String(fx.get("reelSePath", "")), float(fx.get("reelSeVolumeDb", 0.0)))
			return
	if (phase == "waiting" or phase == "reeling") and target.is_empty() and not (fx.get("targetReference", {}) as Dictionary).is_empty():
		fx["targetDied"] = true
	if phase != "reeling":
		return
	var previous_pos := position
	# Keep the reel endpoint on the moving player so the shared collectible
	# transfer always reaches its hand-off condition.
	fx["reelDestination"] = player_pos
	var destination := player_pos
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

static func update_hit_fx(hit_fx: Array, delta: float, enemies: Array = [], destructibles: Array = [], enemy_bullets: Array = [], killed_enemies: Array = [], destroyed_boxes: Array = [], feedback: Dictionary = {}, arena: Rect2 = Rect2(), walls: Array = [], player_pos: Vector2 = Vector2.ZERO, owner_context: Dictionary = {}) -> Array:
	var appended_fx: Array = []
	_prepare_listener_assembly_target_assignments(hit_fx, enemies)
	for fx_item in hit_fx:
		var fx: Dictionary = fx_item
		var delay: float = float(fx.get("delay", 0.0))
		if delay > 0.0:
			fx["delay"] = maxf(0.0, delay - delta)
			continue
		var kind: String = String(fx.get("kind", ""))
		if kind == "mental_heal" and bool(fx.get("followPlayer", true)):
			fx["pos"] = player_pos + Vector2(0.0, -18.0)
		# HARD comment avalanche rows are advanced by HardModeSystem so their
		# world-clock, collision and lifetime stay in one owner.  Do not move
		# them here as well (normal hit effects keep the legacy path).
		if fx.has("vel") and kind != "kusa_wave" and kind != "great_grassland_wave" and kind != "hard_comment_avalanche_row":
			var move: Vector2 = Vector2(fx["vel"]) * delta
			fx["pos"] = Vector2(fx["pos"]) + move
			if fx.has("hit"):
				fx["hit"] = Vector2(fx["hit"]) + move
		if kind == "kusa_wave":
			update_kusa_wave_damage(fx, delta, enemies, destructibles, enemy_bullets, killed_enemies, destroyed_boxes, appended_fx, feedback, arena, walls)
		elif kind == "great_grassland_wave":
			update_kusa_wave_damage(fx, delta, enemies, destructibles, enemy_bullets, killed_enemies, destroyed_boxes, appended_fx, feedback, arena, walls)
		elif kind == "center_stage_area":
			update_center_stage_fx(fx, delta, enemies, destructibles, enemy_bullets, killed_enemies, destroyed_boxes, appended_fx, feedback)
		elif kind == "comment_lockdown_projectile":
			update_comment_lockdown_projectile(fx, enemies, destructibles, killed_enemies, destroyed_boxes, appended_fx, feedback)
		elif kind == "comment_lockdown_bind":
			update_comment_lockdown_bind_fx(fx, enemies)
		elif kind == "comment_lockdown_followup":
			update_comment_lockdown_followup_fx(fx, enemies, killed_enemies, appended_fx, feedback)
		elif kind == "ban_judgement_shockwave":
			update_ban_judgement_shockwave_damage(fx, enemies, destructibles, killed_enemies, destroyed_boxes, appended_fx, feedback)
		elif kind == "comment_pin":
			update_comment_pin_damage(fx, enemies, destructibles, killed_enemies, destroyed_boxes, appended_fx, feedback)
		elif kind == "emote_mine":
			update_emote_mine_damage(fx, enemies, destructibles, enemy_bullets, killed_enemies, destroyed_boxes, appended_fx, feedback)
		elif kind == "emote_festival_mine":
			var mine_pool := hit_fx.duplicate()
			mine_pool.append_array(appended_fx)
			update_emote_festival_mine_damage(fx, enemies, destructibles, enemy_bullets, killed_enemies, destroyed_boxes, appended_fx, mine_pool, feedback)
		elif kind == "listener_summon":
			update_listener_summon_damage(fx, delta, enemies, killed_enemies, appended_fx, feedback)
		elif kind == "listener_assembly":
			update_listener_assembly_damage(fx, delta, enemies, killed_enemies, appended_fx, feedback)
		elif kind == "moderator_shield_active":
			update_moderator_shield_fx(fx, delta, enemies, destructibles, enemy_bullets, killed_enemies, destroyed_boxes, appended_fx, feedback, owner_context)
		elif kind == "moderator_fortress_active":
			update_moderator_fortress_fx(fx, delta, enemies, destructibles, enemy_bullets, killed_enemies, destroyed_boxes, appended_fx, feedback, owner_context)
		elif kind == "moderator_fortress_shockwave":
			update_moderator_fortress_shockwave_fx(fx, enemies, enemy_bullets, killed_enemies, appended_fx, feedback)
		elif kind == "fansa_baton_hit":
			update_fansa_baton_hit_fx(fx, delta, enemies, destructibles, killed_enemies, destroyed_boxes, appended_fx, feedback)
		elif kind == "fansa_baton_cross_followup":
			update_fansa_baton_cross_followup_fx(fx, enemies, destructibles, killed_enemies, destroyed_boxes, appended_fx, feedback)
		elif kind == "fansa_climax_echo":
			update_fansa_climax_echo_fx(fx, enemies, destructibles, killed_enemies, destroyed_boxes, appended_fx, feedback)
		elif kind == "fansa_climax_x":
			update_fansa_climax_x_fx(fx, enemies, destructibles, killed_enemies, destroyed_boxes, appended_fx, feedback)
		elif kind == "fansa_climax_fan_wave":
			update_fansa_climax_fan_wave_fx(fx, enemies, destructibles, killed_enemies, destroyed_boxes, appended_fx, feedback)
		elif kind == "tsuri_rod_cast":
			update_tsuri_rod_fx(fx, delta, enemies, destructibles, killed_enemies, destroyed_boxes, appended_fx, feedback, player_pos)
		elif kind == "buzz_thumbnail_rod_cast":
			update_buzz_thumbnail_rod_fx(fx, delta, enemies, killed_enemies, appended_fx, feedback, player_pos, destructibles, destroyed_boxes)
		if kind == "tsuri_rod_cast" or kind == "buzz_thumbnail_rod_cast":
			_rod_claim_collectibles_at_landing(fx, owner_context.get("expOrbs", []) as Array, owner_context.get("dropItems", []) as Array)
			_rod_update_claimed_collectibles(fx, delta, player_pos)
		fx["life"] = float(fx["life"]) - delta
		if float(fx.get("life", 0.0)) <= 0.0 and (kind == "tsuri_rod_cast" or kind == "buzz_thumbnail_rod_cast"):
			_rod_release_claimed_collectibles(fx)
	var remaining: Array = _alive_hit_fx(hit_fx)
	for fx_item in appended_fx:
		remaining.append(fx_item)
	return _capped_hit_fx(remaining)

static func advance_hit_fx_visuals_for_target(target: Node, delta: float) -> void:
	var hit_fx: Array = target.get("hit_fx") as Array
	var player_pos := Vector2(target.get("player_pos"))
	for fx_item in hit_fx:
		var fx: Dictionary = fx_item as Dictionary
		var delay := float(fx.get("delay", 0.0))
		if delay > 0.0:
			fx["delay"] = maxf(0.0, delay - delta)
			continue
		if String(fx.get("kind", "")) == "mental_heal" and bool(fx.get("followPlayer", true)):
			fx["pos"] = player_pos + Vector2(0.0, -18.0)
		if fx.has("vel"):
			var move := Vector2(fx["vel"]) * delta
			fx["pos"] = Vector2(fx.get("pos", Vector2.ZERO)) + move
			if fx.has("hit"):
				fx["hit"] = Vector2(fx["hit"]) + move
		if String(fx.get("kind", "")) == "comment_lockdown_bind":
			update_comment_lockdown_bind_fx(fx, target.get("enemies") as Array)
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
	var owner_context := {
		"playerPos": Vector2(target.get("player_pos")),
		"playerVel": Vector2(target.get("player_vel")),
		"lastMoveDirection": Vector2(target.get("last_hammer_dir")),
		"facingDir": Vector2(float(target.get("player_facing_x")), 0.0),
		"expOrbs": target.get("exp_orbs"),
		"dropItems": target.get("drop_items"),
		"attackRightOnly": ModifierSystem.has_effect_for_target(target, "attack_right_only")
	}
	target.set("hit_fx", update_hit_fx(target.get("hit_fx") as Array, delta, enemies, destructibles, enemy_bullets, killed_enemies, destroyed_boxes, feedback, arena, walls, Vector2(target.get("player_pos")), owner_context))
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
