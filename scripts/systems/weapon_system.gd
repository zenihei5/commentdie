extends RefCounted
class_name WeaponSystem

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
		"hitFx": [],
		"killed": [],
		"chat": []
	}
	var projectile_result: Dictionary = update_projectiles({
		"delta": context["delta"],
		"weapon": context["weapon"],
		"weaponType": context["weaponType"],
		"superchatLevel": context["superchatLevel"],
		"superchatTimer": context["superchatTimer"],
		"interval": context["interval"],
		"range": context["range"],
		"damage": context["damage"],
		"playerPos": context["playerPos"],
		"enemies": context["enemies"],
		"bullets": context["playerBullets"],
		"arena": context["arena"]
	})
	result["superchatTimer"] = projectile_result["superchatTimer"]
	result["playerBullets"] = projectile_result["bullets"]
	_merge_weapon_result(result, projectile_result)

	var hammer_result: Dictionary = update_hammer({
		"delta": context["delta"],
		"rng": context["rng"],
		"weaponType": context["weaponType"],
		"attackTimer": context["attackTimer"],
		"muteTimer": context["muteTimer"],
		"lastDir": context["lastDir"],
		"supportAttack": context["supportAttack"],
		"weaponMute": context["weaponMute"],
		"weaponMuteRate": context["weaponMuteRate"],
		"takeback": context["takeback"],
		"attackRightOnly": context["attackRightOnly"],
		"attackRightOnlyRate": context["attackRightOnlyRate"],
		"attackJitter": context["attackJitter"],
		"shortRange": context["shortRange"],
		"playerPos": context["playerPos"],
		"enemies": context["enemies"],
		"damage": context["damage"],
		"range": context["range"],
		"interval": context["interval"],
		"knockback": context["knockback"]
	})
	result["attackTimer"] = hammer_result["attackTimer"]
	result["muteTimer"] = hammer_result["muteTimer"]
	result["lastDir"] = hammer_result["lastDir"]
	_merge_weapon_result(result, hammer_result)

	var boomerang_result: Dictionary = update_boomerang({
		"weapon": context["weapon"],
		"weaponType": context["weaponType"],
		"boomerangLevel": context["boomerangLevel"],
		"elapsed": context["elapsed"],
		"playerPos": context["playerPos"],
		"enemies": context["enemies"],
		"boomerangHits": context["boomerangHits"],
		"range": context["range"],
		"damage": context["damage"],
		"knockback": context["knockback"]
	})
	result["boomerangHits"] = boomerang_result["boomerangHits"]
	_merge_weapon_result(result, boomerang_result)
	return result

static func update_for_target(target: Node, delta: float, arena: Rect2, rng: RandomNumberGenerator) -> Dictionary:
	var current_weapon: Dictionary = target.get("current_weapon") as Dictionary
	var result: Dictionary = update_weapons({
		"delta": delta,
		"rng": rng,
		"weapon": current_weapon,
		"weaponType": attack_type(current_weapon),
		"attackTimer": target.get("attack_timer"),
		"muteTimer": target.get("mute_timer"),
		"superchatTimer": target.get("superchat_timer"),
		"lastDir": target.get("last_hammer_dir"),
		"supportAttack": float(target.get("support_attack_timer")) > 0.0,
		"weaponMute": ModifierSystem.has_effect_for_target(target, "weapon_mute"),
		"weaponMuteRate": ModifierSystem.effect_rate_for_target(target, "weapon_mute"),
		"takeback": ModifierSystem.has_effect_for_target(target, "takeback"),
		"attackRightOnly": ModifierSystem.has_effect_for_target(target, "attack_right_only"),
		"attackRightOnlyRate": ModifierSystem.effect_rate_for_target(target, "attack_right_only"),
		"attackJitter": float(target.get("attack_jitter_timer")) > 0.0,
		"shortRange": ModifierSystem.has_effect_for_target(target, "short_range"),
		"superchatLevel": target.get("superchat_level"),
		"boomerangLevel": target.get("boomerang_level"),
		"elapsed": target.get("elapsed"),
		"playerPos": target.get("player_pos"),
		"enemies": target.get("enemies"),
		"playerBullets": target.get("player_bullets"),
		"boomerangHits": target.get("boomerang_hits"),
		"damage": target.get("hammer_damage"),
		"range": target.get("hammer_range"),
		"interval": target.get("hammer_interval"),
		"knockback": target.get("knockback_power"),
		"arena": arena
	})
	target.set("attack_timer", float(result["attackTimer"]))
	target.set("mute_timer", float(result["muteTimer"]))
	target.set("superchat_timer", float(result["superchatTimer"]))
	target.set("last_hammer_dir", Vector2(result["lastDir"]))
	target.set("player_bullets", result["playerBullets"])
	target.set("boomerang_hits", result["boomerangHits"])
	return result

static func apply_update_result_for_target(target: Node, result: Dictionary, arena: Rect2, rng: RandomNumberGenerator) -> Dictionary:
	var chats: Array = []
	var killed: Array = result.get("killed", []) as Array
	for item in killed:
		var enemy: Dictionary = item
		var kill_result: Dictionary = EnemySystem.apply_kill_for_target(target, enemy, arena, rng)
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
	target.set("enemies", enemies.filter(func(e): return float(e["hp"]) > 0.0))
	return {"chats": chats}

static func _merge_weapon_result(target: Dictionary, source: Dictionary) -> void:
	for key in ["hitFx", "killed", "chat"]:
		var target_items: Array = target.get(key, []) as Array
		var source_items: Array = source.get(key, []) as Array
		for item in source_items:
			target_items.append(item)

static func update_hammer(context: Dictionary) -> Dictionary:
	var result: Dictionary = {
		"attackTimer": float(context["attackTimer"]),
		"muteTimer": float(context["muteTimer"]),
		"lastDir": Vector2(context["lastDir"]),
		"hitFx": [],
		"killed": [],
		"chat": []
	}
	var hit_effects: Array = result["hitFx"] as Array
	var killed_enemies: Array = result["killed"] as Array
	var chat_events: Array = result["chat"] as Array
	if String(context["weaponType"]) != "melee_arc":
		return result
	var attack_timer_value: float = float(context["attackTimer"]) - float(context["delta"])
	if attack_timer_value > 0.0:
		result["attackTimer"] = attack_timer_value
		return result
	var interval_rate: float = 0.9 if bool(context["supportAttack"]) else 1.0
	attack_timer_value = float(context["interval"]) * interval_rate
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
	var dir: Vector2 = Vector2.RIGHT
	var target: Variant = nearest_enemy(enemies, player_pos)
	if bool(context["takeback"]):
		dir = Vector2.RIGHT.rotated(rng.randf_range(0.0, TAU))
	elif target != null:
		var target_data: Dictionary = target as Dictionary
		if bool(context["attackRightOnly"]):
			var right_power: float = float(context["attackRightOnlyRate"])
			if right_power < 0.95 and rng.randf() > 0.70:
				dir = (Vector2(target_data["pos"]) - player_pos).normalized()
		else:
			dir = (Vector2(target_data["pos"]) - player_pos).normalized()
	if bool(context["attackJitter"]):
		dir = dir.rotated(rng.randf_range(-0.45, 0.45))
	result["lastDir"] = dir
	var hits: int = 0
	var effective_range: float = float(context["range"]) * (0.55 if bool(context["shortRange"]) else 1.0)
	var closest_hit: Vector2 = player_pos + dir * effective_range
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item
		if float(enemy["hp"]) <= 0.0:
			continue
		var enemy_pos: Vector2 = Vector2(enemy["pos"])
		var to_enemy: Vector2 = enemy_pos - player_pos
		if to_enemy.length() <= effective_range and dir.dot(to_enemy.normalized()) > 0.38:
			enemy["hp"] = float(enemy["hp"]) - float(context["damage"])
			enemy["pos"] = enemy_pos + to_enemy.normalized() * float(context["knockback"])
			hits += 1
			if enemy_pos.distance_squared_to(player_pos) < closest_hit.distance_squared_to(player_pos):
				closest_hit = enemy_pos
			if float(enemy["hp"]) <= 0.0:
				killed_enemies.append(enemy)
	hit_effects.append({"pos": player_pos, "dir": dir, "life": 0.22, "range": effective_range, "hit": closest_hit, "count": hits})
	if hits > 0:
		chat_events.append("BAN命中！")
	result["attackTimer"] = attack_timer_value
	result["muteTimer"] = mute_timer_value
	return result

static func update_projectiles(context: Dictionary) -> Dictionary:
	var result: Dictionary = {
		"superchatTimer": float(context["superchatTimer"]),
		"bullets": context["bullets"],
		"killed": []
	}
	var killed_enemies: Array = result["killed"] as Array
	var delta: float = float(context["delta"])
	var timer: float = float(context["superchatTimer"]) - delta
	var is_main_projectile: bool = String(context["weaponType"]) == "projectile"
	var superchat_level: int = int(context["superchatLevel"])
	var has_projectile: bool = is_main_projectile or superchat_level > 0
	var player_pos: Vector2 = Vector2(context["playerPos"])
	var enemies: Array = context["enemies"] as Array
	var bullets: Array = context["bullets"] as Array
	if has_projectile and timer <= 0.0:
		var base_interval: float = float(context["interval"]) if is_main_projectile else 0.8
		timer = maxf(0.18, base_interval * pow(0.92, float(superchat_level)))
		var target: Variant = nearest_enemy(enemies, player_pos)
		if target != null:
			var target_data: Dictionary = target as Dictionary
			var dir: Vector2 = (Vector2(target_data["pos"]) - player_pos).normalized()
			var range_value: float = float(context["range"]) if is_main_projectile else 520.0
			if player_pos.distance_to(Vector2(target_data["pos"])) <= range_value:
				var weapon: Dictionary = context["weapon"] as Dictionary
				var speed: float = scaled_projectile_speed(float(weapon.get("projectileSpeed", 7.0))) if is_main_projectile else 460.0
				var damage: float = float(context["damage"]) if is_main_projectile else 3.0
				damage += float(superchat_level) * 1.5
				bullets.append({"pos": player_pos, "vel": dir * speed, "life": range_value / speed, "damage": damage})
	for bullet_item in bullets:
		var bullet: Dictionary = bullet_item
		bullet["pos"] = Vector2(bullet["pos"]) + Vector2(bullet["vel"]) * delta
		bullet["life"] = float(bullet["life"]) - delta
		for enemy_item in enemies:
			var enemy: Dictionary = enemy_item
			if float(enemy["hp"]) <= 0.0:
				continue
			if float(bullet["life"]) > 0.0 and Vector2(bullet["pos"]).distance_to(Vector2(enemy["pos"])) < float(enemy["radius"]) + 7.0:
				enemy["hp"] = float(enemy["hp"]) - float(bullet["damage"])
				bullet["life"] = -1.0
				if float(enemy["hp"]) <= 0.0:
					killed_enemies.append(enemy)
				break
	var arena: Rect2 = context["arena"]
	result["bullets"] = bullets.filter(func(b): return float(b["life"]) > 0.0 and arena.grow(60).has_point(Vector2(b["pos"])))
	result["superchatTimer"] = timer
	return result

static func update_boomerang(context: Dictionary) -> Dictionary:
	var result: Dictionary = {
		"hitFx": [],
		"killed": [],
		"boomerangHits": context["boomerangHits"]
	}
	var hit_effects: Array = result["hitFx"] as Array
	var killed_enemies: Array = result["killed"] as Array
	var weapon: Dictionary = context["weapon"] as Dictionary
	var weapon_type: String = String(context["weaponType"])
	var boomerang_level: int = int(context["boomerangLevel"])
	var count: int = orbit_count(weapon, boomerang_level)
	if count <= 0:
		return result
	var is_main_orbit: bool = weapon_type == "orbit"
	var player_pos: Vector2 = Vector2(context["playerPos"])
	var radius: float = float(context["range"]) if is_main_orbit else 78.0
	var hit_radius: float = float(weapon.get("hitRadius", 34.0)) if is_main_orbit else 28.0
	var speed: float = orbit_speed(weapon)
	var damage: float = float(context["damage"]) if is_main_orbit else 5.0
	damage += float(boomerang_level) * 1.5
	var hit_interval: float = float(weapon.get("hitInterval", 0.6)) if is_main_orbit else 0.6
	var elapsed: float = float(context["elapsed"])
	var enemies: Array = context["enemies"] as Array
	var hit_memory: Dictionary = context["boomerangHits"] as Dictionary
	for i in range(count):
		var angle: float = elapsed * speed + TAU * float(i) / float(count)
		var pos: Vector2 = player_pos + Vector2(cos(angle), sin(angle)) * radius
		for enemy_item in enemies:
			var enemy: Dictionary = enemy_item
			if float(enemy["hp"]) <= 0.0:
				continue
			var enemy_id: String = "%s_%d" % [String(enemy["kind"]), int(enemy.get("uid", 0))]
			var hit_key: String = "%d:%s" % [i, enemy_id]
			if float(hit_memory.get(hit_key, 0.0)) > elapsed:
				continue
			if pos.distance_to(Vector2(enemy["pos"])) < float(enemy["radius"]) + hit_radius:
				enemy["hp"] = float(enemy["hp"]) - damage
				var push_dir: Vector2 = (Vector2(enemy["pos"]) - player_pos).normalized()
				enemy["pos"] = Vector2(enemy["pos"]) + push_dir * float(context["knockback"]) * 0.45
				hit_memory[hit_key] = elapsed + hit_interval
				hit_effects.append({"pos": pos, "dir": push_dir, "life": 0.14, "range": 36.0, "hit": Vector2(enemy["pos"]), "count": 1})
				if float(enemy["hp"]) <= 0.0:
					killed_enemies.append(enemy)
	result["boomerangHits"] = hit_memory
	return result

static func update_hit_fx(hit_fx: Array, delta: float) -> Array:
	for fx_item in hit_fx:
		var fx: Dictionary = fx_item
		fx["life"] = float(fx["life"]) - delta
	return hit_fx.filter(func(f): return float(f["life"]) > 0.0)

static func update_hit_fx_for_target(target: Node, delta: float) -> void:
	target.set("hit_fx", update_hit_fx(target.get("hit_fx") as Array, delta))

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
