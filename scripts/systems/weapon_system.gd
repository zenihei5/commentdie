extends RefCounted
class_name WeaponSystem

const DestructibleSystemScript := preload("res://scripts/systems/destructible_system.gd")
const DEFEAT_KNOCKBACK_MULTIPLIER := 2.4
const SHORT_RANGE_MIN_PROJECTILE_RANGE := 165.0
const SHORT_RANGE_MIN_AREA_RADIUS := 66.0
const SHORT_RANGE_MIN_SEARCH_RANGE := 206.0
const SHORT_RANGE_MIN_LASER_RANGE := 247.5
const SHORT_RANGE_MIN_ORBIT_RADIUS := 34.0
const STARLIGHT_SHOT_COUNTER_KEY := "__starlight_superchat_shot_count"
const MARO_PULSE_INDEX_KEY := "__maro_comment_pulse_index"
const MARO_PULSE_UNTIL_KEY := "__maro_comment_pulse_until"
const MARO_FLASH_UNTIL_KEY := "__maro_comment_flash_until"

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

static func _short_range_rate(context: Dictionary, normal_rate: float, heart_rate: float) -> float:
	if not bool(context.get("shortRange", false)):
		return 1.0
	return heart_rate if float(context.get("shortRangeRate", 1.0)) < 0.95 else normal_rate

static func _apply_short_range(context: Dictionary, value: float, normal_rate: float, heart_rate: float, min_value: float = 0.0) -> float:
	var result: float = value * _short_range_rate(context, normal_rate, heart_rate)
	if min_value > 0.0:
		result = maxf(result, min_value)
	return result

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
		"superchatShotFired": false
	}
	var projectile_result: Dictionary = update_projectiles({
		"delta": context["delta"],
		"weapon": context["weapon"],
		"weaponTimers": context["equipmentWeaponTimers"],
		"weaponType": context["weaponType"],
		"superchatLevel": context["superchatLevel"],
		"bulletSupportLevel": context["equipmentBulletSupportLevel"],
		"superchatTimer": context["superchatTimer"],
		"interval": context["interval"],
		"range": context["range"],
		"damage": context["damage"],
		"shortRange": context["shortRange"],
		"shortRangeRate": context["shortRangeRate"],
		"playerPos": context["playerPos"],
		"enemies": context["enemies"],
		"destructibles": context["destructibles"],
		"bullets": context["playerBullets"],
		"enemyBullets": context["enemyBullets"],
		"knockback": context["knockback"],
		"arena": context["arena"]
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
		"knockback": context["knockback"]
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
		"knockback": context["knockback"]
	})
	result["boomerangHits"] = boomerang_result["boomerangHits"]
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
		"bulletSupportLevel": context["equipmentBulletSupportLevel"],
		"shortRange": context["shortRange"],
		"shortRangeRate": context["shortRangeRate"],
		"knockback": context["knockback"]
	})
	result["equipmentWeaponTimers"] = equipment_result["timers"]
	_merge_weapon_result(result, equipment_result)
	return result

static func update_for_target(target: Node, delta: float, arena: Rect2, rng: RandomNumberGenerator) -> Dictionary:
	var current_weapon: Dictionary = target.get("current_weapon") as Dictionary
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
		"damage": target.get("hammer_damage"),
		"range": target.get("hammer_range"),
		"arcAngle": current_weapon.get("arcAngle", 120.0),
		"interval": target.get("hammer_interval"),
		"equipmentDamageRate": target.get("equipment_damage_rate"),
		"equipmentRangeRate": target.get("equipment_range_rate"),
		"equipmentIntervalRate": target.get("equipment_interval_rate"),
		"equipmentBulletSupportLevel": target.get("equipment_bullet_support_level"),
		"knockback": target.get("knockback_power"),
		"arena": arena
	})
	target.set("attack_timer", float(result["attackTimer"]))
	target.set("mute_timer", float(result["muteTimer"]))
	target.set("superchat_timer", float(result["superchatTimer"]))
	target.set("last_hammer_dir", Vector2(result["lastDir"]))
	target.set("player_bullets", result["playerBullets"])
	var enemy_bullets: Array = result.get("enemyBullets", target.get("enemy_bullets")) as Array
	target.set("enemy_bullets", enemy_bullets.filter(func(b): return float(b.get("life", 0.0)) > 0.0))
	target.set("boomerang_hits", result["boomerangHits"])
	target.set("equipment_weapon_timers", result.get("equipmentWeaponTimers", target.get("equipment_weapon_timers")))
	return result

static func apply_update_result_for_target(target: Node, result: Dictionary, arena: Rect2, rng: RandomNumberGenerator) -> Dictionary:
	var chats: Array = []
	var feedback: Dictionary = {"chats": chats}
	_merge_reaction_result(feedback, result)
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
	target.set("hit_fx", hit_fx)

	var weapon_chats: Array = result.get("chat", []) as Array
	for item in weapon_chats:
		chats.append(String(item))

	var enemies: Array = target.get("enemies") as Array
	target.set("enemies", enemies.filter(func(e): return EnemySystem.should_keep_enemy(e)))
	var destroy_feedback: Dictionary = DestructibleSystemScript.apply_destroyed_for_target(target, result.get("destroyedBoxes", []) as Array, rng)
	for item in (destroy_feedback["chats"] as Array):
		chats.append(String(item))
	return feedback

static func _merge_weapon_result(target: Dictionary, source: Dictionary) -> void:
	for key in ["hitFx", "killed", "destroyedBoxes", "chat"]:
		var target_items: Array = target.get(key, []) as Array
		var source_items: Array = source.get(key, []) as Array
		for item in source_items:
			target_items.append(item)
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
	_merge_reaction_result(result, reaction)

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

static func _apply_enemy_hit(enemy: Dictionary, damage: float, push_dir: Vector2, knockback: float, killed_enemies: Array, hit_effects: Array) -> bool:
	if float(enemy.get("hp", 0.0)) <= 0.0:
		return false
	var enemy_pos: Vector2 = Vector2(enemy.get("pos", Vector2.ZERO))
	enemy["hp"] = float(enemy["hp"]) - damage
	_start_enemy_hit_flash(enemy)
	var dir: Vector2 = push_dir.normalized()
	var defeated := float(enemy.get("hp", 0.0)) <= 0.0
	var scaled_knockback: float = _scaled_hit_knockback(enemy, knockback, defeated)
	if scaled_knockback > 0.0 and dir.length() > 0.1:
		EnemySystem.add_knockback_for_enemy(enemy, dir, scaled_knockback)
	hit_effects.append(_damage_number_fx(enemy_pos, damage))
	_append_killed_once(enemy, killed_enemies)
	return true

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
	var dir: Vector2 = (pos - center).normalized()
	if dir.length() < 0.1:
		dir = Vector2.RIGHT
	return {
		"kind": "maro_bullet_clear",
		"pos": pos,
		"dir": dir,
		"life": 0.24,
		"maxLife": 0.24
	}

static func _clear_enemy_bullets_in_circle(enemy_bullets: Array, center: Vector2, radius: float, hit_effects: Array, clear_fx_kind: String = "") -> int:
	var cleared: int = 0
	for item in enemy_bullets:
		var bullet: Dictionary = item as Dictionary
		if float(bullet.get("life", 0.0)) <= 0.0:
			continue
		var bullet_pos: Vector2 = Vector2(bullet["pos"])
		var bullet_radius: float = float(bullet.get("hitRadius", 16.0))
		if bullet_pos.distance_to(center) <= radius + bullet_radius:
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
		if to_bullet.length() > radius + float(bullet.get("hitRadius", 16.0)):
			continue
		if to_bullet.length() <= 0.1 or norm_dir.dot(to_bullet.normalized()) >= dot_threshold:
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
	hit_effects: Array
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

	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if float(enemy.get("hp", 0.0)) <= 0.0:
			continue
		var enemy_pos: Vector2 = Vector2(enemy["pos"])
		var to_enemy: Vector2 = enemy_pos - player_pos
		var enemy_radius: float = float(enemy.get("radius", 20.0))
		var range_padding: float = enemy_radius * 0.65 + 12.0
		if to_enemy.length() <= swing_range + range_padding and (to_enemy.length() <= 0.1 or norm_dir.dot(to_enemy.normalized()) >= arc_dot_threshold):
			var push_dir: Vector2 = to_enemy.normalized()
			if push_dir.length() < 0.1:
				push_dir = norm_dir
			if _apply_enemy_hit(enemy, swing_damage, push_dir, swing_knockback, killed_enemies, hit_effects):
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
		if to_box.length() <= swing_range + box_padding and (to_box.length() <= 0.1 or norm_dir.dot(to_box.normalized()) >= arc_dot_threshold):
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
		"hitIds": hit_ids.duplicate(),
		"count": shockwave_hits
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
		"chat": []
	}
	var hit_effects: Array = result["hitFx"] as Array
	var killed_enemies: Array = result["killed"] as Array
	var destroyed_boxes: Array = result["destroyedBoxes"] as Array
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
	attack_timer_value = maxf(min_interval, float(context["interval"]) * interval_rate)
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
	var effective_range: float = _apply_short_range(context, float(context["range"]), 0.75, 0.85, SHORT_RANGE_MIN_AREA_RADIUS)
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
			inherited_range_rate * _short_range_area_rate(context),
			killed_enemies,
			destroyed_boxes,
			hit_effects
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
		if to_enemy.length() <= effective_range + range_padding and dir.dot(to_enemy.normalized()) >= arc_dot_threshold:
			var damage: float = float(context["damage"])
			_apply_enemy_hit(enemy, damage, to_enemy.normalized(), float(context["knockback"]), killed_enemies, hit_effects)
			hits += 1
			enemy_hits += 1
			if enemy_pos.distance_squared_to(player_pos) < closest_hit.distance_squared_to(player_pos):
				closest_hit = enemy_pos
	for box_item in destructibles:
		var box: Dictionary = box_item as Dictionary
		var box_pos: Vector2 = Vector2(box["pos"])
		var to_box: Vector2 = box_pos - player_pos
		var box_padding: float = float(box.get("radius", 24.0)) * 0.55 + 10.0
		if float(box.get("hp", 0.0)) > 0.0 and to_box.length() <= effective_range + box_padding and dir.dot(to_box.normalized()) >= arc_dot_threshold:
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
		"superchatShotFired": false
	}
	var killed_enemies: Array = result["killed"] as Array
	var destroyed_boxes: Array = result["destroyedBoxes"] as Array
	var hit_effects: Array = result["hitFx"] as Array
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
	if has_projectile and timer <= 0.0:
		var base_interval: float = float(context["interval"]) if is_main_projectile else 0.8
		timer = maxf(0.18, base_interval * pow(0.92, float(superchat_level)))
		var target: Variant = nearest_enemy(enemies, player_pos)
		if target != null:
			var target_data: Dictionary = target as Dictionary
			var dir: Vector2 = (Vector2(target_data["pos"]) - player_pos).normalized()
			var range_value: float = float(context["range"]) if is_main_projectile else 520.0
			range_value = _apply_short_range(context, range_value, 0.60, 0.75, SHORT_RANGE_MIN_PROJECTILE_RANGE)
			if player_pos.distance_to(Vector2(target_data["pos"])) <= range_value:
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
						bullets.append(_starlight_bullet_data(weapon, player_pos, shot_dir, speed, range_value / speed, damage, shot_index, projectile_count, weapon_timers))
					else:
						bullets.append({"pos": player_pos, "vel": shot_dir * speed, "life": range_value / speed, "damage": damage})
				result["superchatShotFired"] = true
	for bullet_item in bullets:
		var bullet: Dictionary = bullet_item
		bullet["pos"] = Vector2(bullet["pos"]) + Vector2(bullet["vel"]) * delta
		bullet["life"] = float(bullet["life"]) - delta
		if float(bullet["life"]) > 0.0:
			for enemy_bullet_item in enemy_bullets:
				var enemy_bullet: Dictionary = enemy_bullet_item as Dictionary
				if float(enemy_bullet.get("life", 0.0)) <= 0.0:
					continue
				var bullet_pos: Vector2 = Vector2(bullet["pos"])
				var enemy_bullet_pos: Vector2 = Vector2(enemy_bullet["pos"])
				if bullet_pos.distance_to(enemy_bullet_pos) <= float(enemy_bullet.get("hitRadius", 16.0)) + float(bullet.get("hitRadius", 8.0)):
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
			var bullet_hit_ids: Array = bullet.get("hitIds", []) as Array
			if bullet_hit_ids.has(enemy_id):
				continue
			if Vector2(bullet["pos"]).distance_to(Vector2(enemy["pos"])) < float(enemy["radius"]) + float(bullet.get("hitRadius", 7.0)):
				var damage: float = float(bullet["damage"])
				var hit_pos: Vector2 = Vector2(enemy["pos"])
				var push_dir: Vector2 = Vector2(bullet["vel"]).normalized()
				if push_dir.length() < 0.1:
					push_dir = (hit_pos - player_pos).normalized()
				if push_dir.length() < 0.1:
					push_dir = Vector2.RIGHT
				bullet_hit_ids.append(enemy_id)
				bullet["hitIds"] = bullet_hit_ids
				if _apply_enemy_hit(enemy, damage, push_dir, float(context.get("knockback", 0.0)) * 0.42, killed_enemies, hit_effects):
					var weapon_for_hit: Dictionary = context["weapon"] as Dictionary
					if bool(bullet.get("premium", false)):
						var explosion_hits: int = _apply_starlight_explosion(weapon_for_hit, context, hit_pos, enemies, destructibles, killed_enemies, destroyed_boxes, hit_effects)
						_request_weapon_hit_reaction(result, weapon_for_hit, 1 + explosion_hits, 1 + explosion_hits)
					elif String(bullet.get("visualKind", "")) == "starlight_superchat":
						hit_effects.append(_starlight_hit_fx(hit_pos))
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
				var bullet_hit_ids: Array = bullet.get("hitIds", []) as Array
				if bullet_hit_ids.has(box_id):
					continue
				if Vector2(bullet["pos"]).distance_to(Vector2(box["pos"])) < float(box.get("radius", 24.0)) + float(bullet.get("hitRadius", 7.0)):
					DestructibleSystemScript.damage_box(box, 1.0, destroyed_boxes, hit_effects)
					var hit_pos: Vector2 = Vector2(box["pos"])
					bullet_hit_ids.append(box_id)
					bullet["hitIds"] = bullet_hit_ids
					if bool(bullet.get("premium", false)):
						_apply_starlight_explosion(context["weapon"] as Dictionary, context, hit_pos, enemies, destructibles, killed_enemies, destroyed_boxes, hit_effects)
					elif String(bullet.get("visualKind", "")) == "starlight_superchat":
						hit_effects.append(_starlight_hit_fx(hit_pos))
					var pierce_left: int = int(bullet.get("pierceLeft", 0))
					if pierce_left > 0:
						bullet["pierceLeft"] = pierce_left - 1
						continue
					bullet["life"] = -1.0
					break
	var arena: Rect2 = context["arena"]
	result["bullets"] = bullets.filter(func(b): return float(b["life"]) > 0.0 and arena.grow(60).has_point(Vector2(b["pos"])))
	result["superchatTimer"] = timer
	return result

static func update_boomerang(context: Dictionary) -> Dictionary:
	var result: Dictionary = {
		"hitFx": [],
		"killed": [],
		"destroyedBoxes": [],
		"boomerangHits": context["boomerangHits"]
	}
	var hit_effects: Array = result["hitFx"] as Array
	var killed_enemies: Array = result["killed"] as Array
	var destroyed_boxes: Array = result["destroyedBoxes"] as Array
	var weapon: Dictionary = context["weapon"] as Dictionary
	var weapon_type: String = String(context["weaponType"])
	var weapon_timers: Dictionary = context.get("weaponTimers", {}) as Dictionary
	var boomerang_level: int = int(context["boomerangLevel"])
	var count: int = orbit_count(weapon, boomerang_level)
	if count > 0:
		count += int(context.get("bulletSupportLevel", 0))
	if count <= 0:
		return result
	var is_main_orbit: bool = weapon_type == "orbit"
	var is_maro_ring: bool = is_main_orbit and _is_maro_comment_ring(weapon)
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
	var speed: float = orbit_speed(weapon)
	var damage: float = float(context["damage"]) if is_main_orbit else 5.0
	damage += float(boomerang_level) * 1.5
	var hit_interval: float = float(weapon.get("hitInterval", 0.6)) if is_main_orbit else 0.6
	var elapsed: float = float(context["elapsed"])
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
			if pos.distance_to(Vector2(enemy["pos"])) < float(enemy["radius"]) + hit_radius:
				var push_dir: Vector2 = (Vector2(enemy["pos"]) - player_pos).normalized()
				if _apply_enemy_hit(enemy, damage, push_dir, float(context["knockback"]) * 0.45, killed_enemies, hit_effects):
					_request_weapon_hit_reaction(result, weapon, 1)
				hit_memory[hit_key] = elapsed + hit_interval
				if is_maro_ring:
					hit_effects.append(_maro_comment_hit_fx(Vector2(enemy["pos"])))
				else:
					hit_effects.append({"pos": pos, "dir": push_dir, "life": 0.14, "range": 36.0, "hit": Vector2(enemy["pos"]), "count": 1})
		for box_item in destructibles:
			var box: Dictionary = box_item as Dictionary
			if float(box.get("hp", 0.0)) <= 0.0:
				continue
			var box_id: String = "box_%d" % int(box.get("uid", 0))
			var box_hit_key: String = "%d:%s" % [i, box_id]
			if float(hit_memory.get(box_hit_key, 0.0)) > elapsed:
				continue
			if pos.distance_to(Vector2(box["pos"])) < float(box.get("radius", 24.0)) + hit_radius:
				hit_memory[box_hit_key] = elapsed + hit_interval
				DestructibleSystemScript.damage_box(box, 1.0, destroyed_boxes, hit_effects)
	result["boomerangHits"] = hit_memory
	return result

static func update_equipment_weapons(context: Dictionary) -> Dictionary:
	var result: Dictionary = {"timers": context["timers"], "hitFx": [], "killed": [], "destroyedBoxes": [], "chat": []}
	var timers: Dictionary = result["timers"] as Dictionary
	var hit_effects: Array = result["hitFx"] as Array
	var killed_enemies: Array = result["killed"] as Array
	var destroyed_boxes: Array = result["destroyedBoxes"] as Array
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
	for entry_item in player_weapons:
		var entry: Dictionary = entry_item as Dictionary
		var weapon_id: String = String(entry.get("id", ""))
		if weapon_id == main_weapon_id or weapon_id in ["superchat_shot", "comment_boomerang"]:
			continue
		var weapon: Dictionary = find_weapon(weapon_data, weapon_id, {})
		if weapon.is_empty():
			continue
		var timer: float = float(timers.get(weapon_id, 0.0)) - delta
		if timer > 0.0:
			timers[weapon_id] = timer
			continue
		var attack_dir: Vector2 = _direction_with_attack_right_only(facing_dir, context)
		var level_value: int = int(entry.get("level", 1))
		var damage: float = (float(weapon.get("damage", 4.0)) + float(level_value - 1) * 1.5) * float(context["damageRate"])
		var range_value: float = range_base(weapon) * float(context["rangeRate"])
		var interval: float = attack_interval(weapon, 1.0) * float(context["intervalRate"])
		range_value = _short_range_range_for_weapon(weapon_id, weapon, range_value, context)
		var spawn_support_level: int = support_level if String(weapon.get("attribute", "")) == "bullet" else 0
		timers[weapon_id] = maxf(0.18, interval)
		if attack_type(weapon) == "melee_arc":
			var arc_angle: float = float(weapon.get("arcAngle", 120.0)) + 8.0
			var closest_hit: Vector2 = player_pos + attack_dir * range_value
			var enemy_hits: int = _apply_arc_damage(enemies, player_pos, attack_dir, range_value, arc_angle, damage, float(context["knockback"]), killed_enemies, hit_effects)
			var hits: int = enemy_hits
			hits += _apply_arc_damage_to_boxes(destructibles, player_pos, attack_dir, range_value, arc_angle, destroyed_boxes, hit_effects)
			hits += _clear_enemy_bullets_in_arc(enemy_bullets, player_pos, attack_dir, range_value + 18.0, arc_angle, hit_effects)
			_request_weapon_hit_reaction(result, weapon, hits, enemy_hits)
			hit_effects.append({
				"pos": player_pos,
				"dir": attack_dir,
				"life": 0.24,
				"range": range_value * 0.88,
				"arcAngle": arc_angle,
				"hammer": weapon_id == "ban_hammer",
				"hit": closest_hit,
				"count": hits
			})
			if weapon_id == "ban_hammer" and hits > 0:
				chat_events.append("BAN命中！")
		elif weapon_id == "mic_barrier":
			var enemy_hits: int = _apply_circle_damage(enemies, player_pos, range_value, damage, float(context["knockback"]), killed_enemies, hit_effects)
			_apply_circle_damage_to_boxes(destructibles, player_pos, range_value, destroyed_boxes, hit_effects)
			_clear_enemy_bullets_in_circle(enemy_bullets, player_pos, range_value, hit_effects)
			_request_weapon_hit_reaction(result, weapon, enemy_hits, enemy_hits)
			hit_effects.append({"kind": "mic_wave", "pos": player_pos, "life": 0.42, "maxLife": 0.42, "range": range_value, "hitCount": enemy_hits, "count": enemy_hits})
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
			var spotlight_radius: float = maxf(72.0 * float(context["rangeRate"]) * _short_range_explosion_area_rate(context), SHORT_RANGE_MIN_AREA_RADIUS)
			var enemy_hits: int = _apply_circle_damage(enemies, center, spotlight_radius, damage, float(context["knockback"]) * 0.35, killed_enemies, hit_effects)
			_apply_circle_damage_to_boxes(destructibles, center, spotlight_radius, destroyed_boxes, hit_effects)
			_clear_enemy_bullets_in_circle(enemy_bullets, center, spotlight_radius, hit_effects)
			_request_weapon_hit_reaction(result, weapon, enemy_hits, enemy_hits)
			hit_effects.append({"kind": "spotlight", "pos": center, "dir": Vector2.RIGHT, "life": 0.55, "maxLife": 0.55, "range": spotlight_radius, "arcAngle": 360.0, "hit": center, "count": 1})
		elif weapon_id == "kusa_wave":
			hit_effects.append({
				"kind": "kusa_wave",
				"pos": player_pos + attack_dir * 34.0,
				"dir": attack_dir,
				"vel": attack_dir * 430.0,
				"life": 0.48,
				"maxLife": 0.48,
				"range": range_value,
				"arcAngle": float(weapon.get("arcAngle", 80.0)),
				"hit": player_pos + attack_dir * range_value,
				"count": 1,
				"damage": damage,
				"knockback": float(context["knockback"]),
				"screenShakePower": float(weapon.get("screenShakePower", 0.0)),
				"screenShakeDuration": float(weapon.get("screenShakeDuration", 0.10)),
				"hitStop": float(weapon.get("hitStop", 0.0)),
				"hitRadius": 30.0 + 12.0 * float(context["rangeRate"]),
				"hitIds": []
			})
		elif weapon_id == "comment_pin":
			_spawn_comment_pin_projectiles(weapon, level_value, spawn_support_level, player_pos, attack_dir, enemies, range_value, damage, hit_effects)
		elif weapon_id == "emote_mine":
			_spawn_emote_mines(weapon, level_value, spawn_support_level, player_pos, active_fx, hit_effects, damage, float(context["rangeRate"]) * _short_range_explosion_area_rate(context))
		elif weapon_id == "ng_word_laser":
			_fire_ng_word_lasers(weapon, level_value, spawn_support_level, player_pos, attack_dir, enemies, destructibles, enemy_bullets, range_value, damage, float(context["rangeRate"]), float(context["knockback"]), killed_enemies, destroyed_boxes, hit_effects)
		elif weapon_id == "listener_summon":
			_spawn_listener_summons(weapon, level_value, spawn_support_level, player_pos, attack_dir, active_fx, hit_effects, damage, float(context["rangeRate"]) * _short_range_search_rate(context), float(context["knockback"]))
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

static func _maro_comment_hit_fx(pos: Vector2) -> Dictionary:
	return {
		"kind": "maro_comment_hit",
		"pos": pos,
		"life": 0.22,
		"maxLife": 0.22
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
	return scaled_range(radius_value) * _short_range_explosion_area_rate(context)

static func _apply_starlight_explosion(
	weapon: Dictionary,
	context: Dictionary,
	center: Vector2,
	enemies: Array,
	destructibles: Array,
	killed_enemies: Array,
	destroyed_boxes: Array,
	hit_effects: Array
) -> int:
	var radius: float = _premium_superchat_explosion_radius(weapon, context)
	var damage: float = float(weapon.get("premiumExplosionDamage", 7.0))
	var knockback: float = float(context.get("knockback", 0.0)) * 0.28
	var hits: int = _apply_circle_damage(enemies, center, radius, damage, knockback, killed_enemies, hit_effects)
	_apply_circle_damage_to_boxes(destructibles, center, radius, destroyed_boxes, hit_effects)
	hit_effects.append(_starlight_burst_fx(center, radius))
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
	for orb_item in exp_orbs:
		var orb: Dictionary = orb_item as Dictionary
		if float(orb.get("life", 0.0)) <= 0.0:
			continue
		var pos: Vector2 = Vector2(orb.get("pos", Vector2.ZERO))
		var distance: float = pos.distance_to(player_pos)
		if distance <= radius and distance > 18.0:
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
	var hit_count: int = _apply_circle_damage(enemies, player_pos, pulse_radius, pulse_damage, float(context["knockback"]) * 0.20, killed_enemies, hit_effects)
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

static func _spawn_comment_pin_projectiles(weapon: Dictionary, level_value: int, support_level: int, player_pos: Vector2, facing_dir: Vector2, enemies: Array, range_value: float, damage: float, hit_effects: Array) -> void:
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
			"hitRadius": 12.0,
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
	var perpendicular: float = (to_enemy - dir * along).length()
	return perpendicular <= half_width + enemy_radius

static func _apply_laser_damage(enemies: Array, destructibles: Array, enemy_bullets: Array, start: Vector2, dir: Vector2, length: float, width: float, damage: float, knockback: float, killed_enemies: Array, destroyed_boxes: Array, hit_effects: Array) -> int:
	var hits: int = 0
	var half_width: float = width * 0.5
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if float(enemy.get("hp", 0.0)) <= 0.0:
			continue
		var enemy_pos: Vector2 = Vector2(enemy["pos"])
		if not _laser_hit(enemy_pos, float(enemy.get("radius", 20.0)), start, dir, length, half_width):
			continue
		if _apply_enemy_hit(enemy, damage, dir, knockback * 0.55, killed_enemies, hit_effects):
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

static func _fire_ng_word_lasers(weapon: Dictionary, level_value: int, support_level: int, player_pos: Vector2, facing_dir: Vector2, enemies: Array, destructibles: Array, enemy_bullets: Array, range_value: float, damage: float, range_rate: float, knockback: float, killed_enemies: Array, destroyed_boxes: Array, hit_effects: Array) -> void:
	var count: int = _weapon_spawn_count(weapon, "laserCount", level_value, support_level)
	var duration: float = maxf(0.08, float(weapon.get("duration", 0.25)))
	var width: float = scaled_range(float(weapon.get("width", 0.6))) * range_rate * (1.12 if level_value >= 5 else 1.0)
	for i in range(count):
		var dir: Vector2 = _spread_direction(facing_dir, i, count, deg_to_rad(18.0))
		var start: Vector2 = player_pos + dir * 28.0
		var hits: int = _apply_laser_damage(enemies, destructibles, enemy_bullets, start, dir, range_value, width, damage, knockback, killed_enemies, destroyed_boxes, hit_effects)
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

static func _spawn_listener_summons(weapon: Dictionary, level_value: int, support_level: int, player_pos: Vector2, facing_dir: Vector2, active_fx: Array, hit_effects: Array, damage: float, range_rate: float, knockback: float) -> void:
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
			"hitRadius": 18.0,
			"hitCooldown": 0.70,
			"hitTimer": 0.0,
			"knockback": knockback
		})
		active_count += 1

static func _apply_circle_damage(enemies: Array, center: Vector2, radius: float, damage: float, knockback: float, killed_enemies: Array, hit_effects: Array) -> int:
	var hits: int = 0
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item
		if float(enemy["hp"]) <= 0.0:
			continue
		var enemy_pos: Vector2 = Vector2(enemy["pos"])
		var offset: Vector2 = enemy_pos - center
		if offset.length() <= radius:
			if _apply_enemy_hit(enemy, damage, offset.normalized(), knockback, killed_enemies, hit_effects):
				hits += 1
	return hits

static func _apply_circle_damage_to_boxes(destructibles: Array, center: Vector2, radius: float, destroyed_boxes: Array, hit_effects: Array) -> void:
	for box_item in destructibles:
		var box: Dictionary = box_item as Dictionary
		if float(box.get("hp", 0.0)) <= 0.0:
			continue
		if center.distance_to(Vector2(box["pos"])) <= radius + float(box.get("radius", 24.0)):
			DestructibleSystemScript.damage_box(box, 1.0, destroyed_boxes, hit_effects)

static func _apply_arc_damage(enemies: Array, origin: Vector2, dir: Vector2, radius: float, arc_angle: float, damage: float, knockback: float, killed_enemies: Array, hit_effects: Array) -> int:
	var dot_threshold: float = cos(deg_to_rad(arc_angle * 0.5))
	var hits: int = 0
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item
		if float(enemy["hp"]) <= 0.0:
			continue
		var enemy_pos: Vector2 = Vector2(enemy["pos"])
		var to_enemy: Vector2 = enemy_pos - origin
		if to_enemy.length() <= radius and dir.dot(to_enemy.normalized()) >= dot_threshold:
			if _apply_enemy_hit(enemy, damage, to_enemy.normalized(), knockback, killed_enemies, hit_effects):
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
		if to_box.length() <= radius + float(box.get("radius", 24.0)) * 0.55 + 10.0 and dir.dot(to_box.normalized()) >= dot_threshold:
			DestructibleSystemScript.damage_box(box, 1.0, destroyed_boxes, hit_effects)
			hits += 1
	return hits

static func update_kusa_wave_damage(fx: Dictionary, enemies: Array, destructibles: Array, enemy_bullets: Array, killed_enemies: Array, destroyed_boxes: Array, hit_effects: Array, feedback: Dictionary = {}) -> void:
	var pos: Vector2 = Vector2(fx["pos"])
	var dir: Vector2 = Vector2(fx.get("dir", Vector2.RIGHT)).normalized()
	if dir.length() < 0.1:
		dir = Vector2.RIGHT
	var side: Vector2 = Vector2(-dir.y, dir.x)
	var life: float = float(fx.get("life", 0.0))
	var max_life: float = maxf(0.01, float(fx.get("maxLife", 0.48)))
	var progress: float = clampf(1.0 - life / max_life, 0.0, 1.0)
	var chars: int = clampi(1 + int(progress * 6.0), 1, 7)
	var hit_radius: float = float(fx.get("hitRadius", 38.0))
	var damage: float = float(fx.get("damage", 0.0))
	var knockback: float = float(fx.get("knockback", 0.0))
	var hit_ids: Array = fx.get("hitIds", []) as Array
	var hit_points: Array = []
	var hit_count: int = 0
	for i in range(chars):
		var centered_index: float = float(i) - float(chars - 1) * 0.5
		var wobble: Vector2 = side * sin(life * 28.0 + float(i) * 0.8) * 7.0
		hit_points.append(pos - dir * centered_index * 16.0 + wobble)
	for bullet_item in enemy_bullets:
		var bullet: Dictionary = bullet_item as Dictionary
		if float(bullet.get("life", 0.0)) <= 0.0:
			continue
		var bullet_pos: Vector2 = Vector2(bullet["pos"])
		for point_item in hit_points:
			var point: Vector2 = Vector2(point_item)
			if bullet_pos.distance_to(point) <= float(bullet.get("hitRadius", 16.0)) + hit_radius:
				bullet["life"] = -1.0
				hit_effects.append(_bullet_pop_fx(bullet_pos))
				break
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item
		if float(enemy["hp"]) <= 0.0:
			continue
		var uid: String = "%s_%d" % [String(enemy.get("kind", "")), int(enemy.get("uid", 0))]
		if hit_ids.has(uid):
			continue
		var enemy_pos: Vector2 = Vector2(enemy["pos"])
		var did_hit: bool = false
		for point in hit_points:
			if enemy_pos.distance_to(point) <= float(enemy.get("radius", 20.0)) + hit_radius:
				did_hit = true
				break
		if not did_hit:
			continue
		var push_dir: Vector2 = (enemy_pos - pos).normalized()
		if push_dir.length() < 0.1:
			push_dir = dir
		hit_ids.append(uid)
		if _apply_enemy_hit(enemy, damage, push_dir, knockback, killed_enemies, hit_effects):
			hit_count += 1
	if hit_count > 0:
		_merge_reaction_result(feedback, {
			"enemyDamaged": true,
			"screenShakePower": float(fx.get("screenShakePower", 0.0)),
			"screenShakeDuration": float(fx.get("screenShakeDuration", 0.10)),
			"hitStop": float(fx.get("hitStop", 0.0))
		})
	for box_item in destructibles:
		var box: Dictionary = box_item as Dictionary
		if float(box.get("hp", 0.0)) <= 0.0:
			continue
		var box_uid: String = "box_%d" % int(box.get("uid", 0))
		if hit_ids.has(box_uid):
			continue
		var box_pos: Vector2 = Vector2(box["pos"])
		var box_hit: bool = false
		for point in hit_points:
			if box_pos.distance_to(point) <= float(box.get("radius", 24.0)) + hit_radius:
				box_hit = true
				break
		if not box_hit:
			continue
		DestructibleSystemScript.damage_box(box, 1.0, destroyed_boxes, hit_effects)
		hit_ids.append(box_uid)
	fx["hitIds"] = hit_ids

static func update_ban_judgement_shockwave_damage(fx: Dictionary, enemies: Array, destructibles: Array, killed_enemies: Array, destroyed_boxes: Array, hit_effects: Array, feedback: Dictionary = {}) -> void:
	var pos: Vector2 = Vector2(fx["pos"])
	var dir: Vector2 = Vector2(fx.get("dir", Vector2.RIGHT)).normalized()
	if dir.length() < 0.1:
		dir = Vector2.RIGHT
	var range_value: float = float(fx.get("range", 450.0))
	var width_value: float = float(fx.get("width", 96.0))
	var damage: float = float(fx.get("damage", 0.0))
	var knockback: float = float(fx.get("knockback", 0.0))
	var hit_ids: Array = fx.get("hitIds", []) as Array
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
		if _apply_enemy_hit(enemy, damage, dir, knockback, killed_enemies, hit_effects):
			hit_ids.append(target_id)
			hit_count += 1
	if hit_count > 0:
		_merge_reaction_result(feedback, {"enemyDamaged": true})
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
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if float(enemy.get("hp", 0.0)) <= 0.0:
			continue
		var enemy_pos: Vector2 = Vector2(enemy["pos"])
		if pos.distance_to(enemy_pos) > float(enemy.get("radius", 20.0)) + hit_radius:
			continue
		enemy["slowTimer"] = maxf(float(enemy.get("slowTimer", 0.0)), float(fx.get("slowDuration", 2.0)))
		enemy["slowRate"] = maxf(float(enemy.get("slowRate", 0.0)), float(fx.get("slowRate", 0.4)))
		var push_dir: Vector2 = Vector2(fx.get("dir", enemy_pos - pos)).normalized()
		if push_dir.length() < 0.1:
			push_dir = (enemy_pos - pos).normalized()
		_apply_enemy_hit(enemy, damage, push_dir, float(fx.get("knockback", 0.0)), killed_enemies, hit_effects)
		_merge_reaction_result(feedback, {"enemyDamaged": true})
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
		if pos.distance_to(Vector2(box["pos"])) <= float(box.get("radius", 24.0)) + hit_radius:
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
		if pos.distance_to(Vector2(enemy["pos"])) <= float(enemy.get("radius", 20.0)) + trigger_radius:
			should_explode = true
			break
	if not should_explode:
		return
	var radius: float = float(fx.get("radius", 120.0))
	var damage: float = float(fx.get("damage", 0.0))
	var hit_count: int = _apply_circle_damage(enemies, pos, radius, damage, float(fx.get("knockback", 0.0)), killed_enemies, hit_effects)
	_apply_circle_damage_to_boxes(destructibles, pos, radius, destroyed_boxes, hit_effects)
	_clear_enemy_bullets_in_circle(enemy_bullets, pos, radius, hit_effects)
	_merge_reaction_result(feedback, {
		"enemyDamaged": hit_count > 0,
		"screenShakePower": float(fx.get("screenShakePower", 0.0)),
		"screenShakeDuration": float(fx.get("screenShakeDuration", 0.15)),
		"hitStop": float(fx.get("hitStop", 0.0))
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
	if pos.distance_to(enemy_pos) > float(target_enemy.get("radius", 20.0)) + float(fx.get("hitRadius", 18.0)):
		return
	if hit_timer > 0.0:
		return
	var damage: float = float(fx.get("damage", 0.0))
	_apply_enemy_hit(target_enemy, damage, dir, float(fx.get("knockback", 0.0)) * 0.7, killed_enemies, hit_effects)
	_merge_reaction_result(feedback, {"enemyDamaged": true, "listenerSummonAttacked": true})
	hit_effects.append({
		"kind": "listener_burst",
		"pos": enemy_pos,
		"life": 0.22,
		"maxLife": 0.22
	})
	fx["hitTimer"] = float(fx.get("hitCooldown", 0.70))

static func update_hit_fx(hit_fx: Array, delta: float, enemies: Array = [], destructibles: Array = [], enemy_bullets: Array = [], killed_enemies: Array = [], destroyed_boxes: Array = [], feedback: Dictionary = {}) -> Array:
	var appended_fx: Array = []
	for fx_item in hit_fx:
		var fx: Dictionary = fx_item
		var delay: float = float(fx.get("delay", 0.0))
		if delay > 0.0:
			fx["delay"] = maxf(0.0, delay - delta)
			continue
		if fx.has("vel"):
			var move: Vector2 = Vector2(fx["vel"]) * delta
			fx["pos"] = Vector2(fx["pos"]) + move
			if fx.has("hit"):
				fx["hit"] = Vector2(fx["hit"]) + move
		if String(fx.get("kind", "")) == "kusa_wave":
			update_kusa_wave_damage(fx, enemies, destructibles, enemy_bullets, killed_enemies, destroyed_boxes, appended_fx, feedback)
		elif String(fx.get("kind", "")) == "ban_judgement_shockwave":
			update_ban_judgement_shockwave_damage(fx, enemies, destructibles, killed_enemies, destroyed_boxes, appended_fx, feedback)
		elif String(fx.get("kind", "")) == "comment_pin":
			update_comment_pin_damage(fx, enemies, destructibles, killed_enemies, destroyed_boxes, appended_fx, feedback)
		elif String(fx.get("kind", "")) == "emote_mine":
			update_emote_mine_damage(fx, enemies, destructibles, enemy_bullets, killed_enemies, destroyed_boxes, appended_fx, feedback)
		elif String(fx.get("kind", "")) == "listener_summon":
			update_listener_summon_damage(fx, delta, enemies, killed_enemies, appended_fx, feedback)
		fx["life"] = float(fx["life"]) - delta
	var remaining: Array = hit_fx.filter(func(f): return float(f["life"]) > 0.0)
	for fx_item in appended_fx:
		remaining.append(fx_item)
	return remaining

static func update_hit_fx_for_target(target: Node, delta: float, arena: Rect2, rng: RandomNumberGenerator) -> Dictionary:
	var chats: Array = []
	var feedback: Dictionary = {"chats": chats}
	var killed_enemies: Array = []
	var destroyed_boxes: Array = []
	var enemies: Array = target.get("enemies") as Array
	var destructibles: Array = target.get("destructibles") as Array
	var enemy_bullets: Array = target.get("enemy_bullets") as Array
	target.set("hit_fx", update_hit_fx(target.get("hit_fx") as Array, delta, enemies, destructibles, enemy_bullets, killed_enemies, destroyed_boxes, feedback))
	target.set("enemy_bullets", enemy_bullets.filter(func(b): return float(b.get("life", 0.0)) > 0.0))
	for item in killed_enemies:
		var enemy: Dictionary = item
		var kill_result: Dictionary = EnemySystem.apply_kill_for_target(target, enemy, arena, rng)
		_merge_reaction_result(feedback, kill_result)
		var kill_chat: String = String(kill_result["chat"])
		if kill_chat != "":
			chats.append(kill_chat)
	target.set("enemies", enemies.filter(func(e): return EnemySystem.should_keep_enemy(e)))
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
