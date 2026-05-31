extends RefCounted
class_name EnemySystem

static func spawn_interval(context: Dictionary) -> float:
	var elapsed: float = float(context["elapsed"])
	if bool(context["quickTestMode"]):
		if elapsed >= 45.0:
			return 0.55
		if elapsed >= 30.0:
			return 0.75
		if elapsed >= 15.0:
			return 1.0
		return 1.25
	if elapsed >= 150.0:
		return 0.45
	if elapsed >= 120.0:
		return 0.6
	if elapsed >= 90.0:
		return 0.7
	if elapsed >= 60.0:
		return 0.8
	if elapsed >= 30.0:
		return 1.0
	return 1.3

static func pick_wave_enemy(elapsed: float, quick_test_mode: bool, rng: RandomNumberGenerator) -> String:
	var t: float = elapsed
	if quick_test_mode:
		t *= 3.0
	var roll: float = rng.randf()
	if t >= 150.0:
		if roll < 0.20:
			return "clipper"
		if roll < 0.40:
			return "long_comment_guy"
		if roll < 0.62:
			return "shooter"
		if roll < 0.82:
			return "fast"
		return "troll"
	if t >= 120.0:
		if roll < 0.25:
			return "clipper"
		if roll < 0.45:
			return "long_comment_guy"
		if roll < 0.68:
			return "shooter"
		return "fast" if roll < 0.84 else "troll"
	if t >= 90.0:
		if roll < 0.35:
			return "long_comment_guy"
		if roll < 0.62:
			return "shooter"
		return "fast" if roll < 0.82 else "troll"
	if t >= 60.0:
		if roll < 0.38:
			return "shooter"
		return "fast" if roll < 0.68 else "troll"
	if t >= 30.0:
		return "fast" if roll < 0.45 else "troll"
	return "troll"

static func enemy_data(kind: String) -> Dictionary:
	if kind == "fast":
		return {"hp": 8.0, "speed": 175.0, "radius": 20.0, "score": 25, "exp": 2, "behavior": "chase_fast"}
	if kind == "shooter":
		return {"hp": 15.0, "speed": 95.0, "radius": 24.0, "score": 40, "exp": 3, "behavior": "shooter"}
	if kind == "long_comment_guy":
		return {"hp": 40.0, "speed": 62.0, "radius": 34.0, "score": 80, "exp": 5, "behavior": "tank"}
	if kind == "clipper":
		return {"hp": 18.0, "speed": 120.0, "radius": 23.0, "score": 100, "exp": 4, "behavior": "charger"}
	if kind == "unread_maro":
		return {"hp": 8.0, "speed": 130.0, "radius": 19.0, "score": 20, "exp": 1, "behavior": "chase"}
	if kind == "ghost_comment":
		return {"hp": 20.0, "speed": 122.0, "radius": 23.0, "score": 120, "exp": 3, "behavior": "ghost"}
	return {"hp": 10.0, "speed": 105.0, "radius": 21.0, "score": 10, "exp": 1, "behavior": "chase"}

static func spawn_position(arena: Rect2, rng: RandomNumberGenerator) -> Vector2:
	var edge := rng.randi_range(0, 3)
	if edge == 0:
		return Vector2(rng.randf_range(arena.position.x, arena.end.x), arena.position.y + 20)
	if edge == 1:
		return Vector2(rng.randf_range(arena.position.x, arena.end.x), arena.end.y - 20)
	if edge == 2:
		return Vector2(arena.position.x + 20, rng.randf_range(arena.position.y, arena.end.y))
	return Vector2(arena.end.x - 20, rng.randf_range(arena.position.y, arena.end.y))

static func build_enemy(kind: String, pos: Vector2, uid: int, shoot: float, giant_power: float = 0.0) -> Dictionary:
	var data: Dictionary = enemy_data(kind)
	if giant_power > 0.0:
		data["hp"] = float(data["hp"]) * lerpf(1.25, 1.5, giant_power)
		data["radius"] = float(data["radius"]) * lerpf(1.5, 2.0, giant_power)
	return {
		"uid": uid,
		"kind": kind,
		"pos": pos,
		"hp": data["hp"],
		"max_hp": data["hp"],
		"speed": data["speed"],
		"radius": data["radius"],
		"score": data["score"],
		"exp": data["exp"],
		"behavior": data["behavior"],
		"shoot": shoot
	}

static func spawn_enemy_for_target(target: Node, kind: String, arena: Rect2, rng: RandomNumberGenerator, pos: Vector2 = Vector2.INF) -> void:
	var spawn_pos: Vector2 = pos
	if spawn_pos == Vector2.INF:
		spawn_pos = spawn_position(arena, rng)
	var giant_power: float = 0.0
	if ModifierSystem.has_effect_for_target(target, "giant_enemies"):
		giant_power = ModifierSystem.effect_rate_for_target(target, "giant_enemies")
	var shoot_seed: float = rng.randf_range(0.6, 1.4) if pos == Vector2.INF else 1.0
	var enemies: Array = target.get("enemies") as Array
	var next_uid: int = int(target.get("next_enemy_uid"))
	enemies.append(build_enemy(kind, spawn_pos, next_uid, shoot_seed, giant_power))
	target.set("enemies", enemies)
	target.set("next_enemy_uid", next_uid + 1)

static func kill_events(enemy: Dictionary, split_enemy: bool, rng: RandomNumberGenerator) -> Dictionary:
	var pos: Vector2 = Vector2(enemy["pos"])
	var splits: Array = []
	if split_enemy and rng.randf() < 0.35 and String(enemy["kind"]) != "troll":
		splits.append(pos + Vector2(18, 0))
		splits.append(pos + Vector2(-18, 0))
	return {
		"splits": splits,
		"chat": "今のBANうまい" if rng.randf() < 0.16 else ""
	}

static func apply_kill_for_target(target: Node, enemy: Dictionary, arena: Rect2, rng: RandomNumberGenerator) -> Dictionary:
	target.set("kills", int(target.get("kills")) + 1)
	target.set("score", int(target.get("score")) + ScoreSystem.enemy_score_for_target(target, enemy))
	ExpSystem.drop_from_enemy_for_target(target, enemy)
	var split_enemy: bool = ModifierSystem.has_effect_for_target(target, "split_enemy")
	var events: Dictionary = kill_events(enemy, split_enemy, rng)
	var splits: Array = events["splits"] as Array
	for item in splits:
		spawn_enemy_for_target(target, "troll", arena, rng, Vector2(item))
	return {
		"chat": String(events["chat"])
	}

static func update_enemy_world(context: Dictionary) -> Dictionary:
	var result: Dictionary = {
		"bullets": context["bullets"],
		"damageEvents": []
	}
	var enemy_result: Dictionary = update_enemies(context)
	result["bullets"] = enemy_result["bullets"]
	_merge_damage_events(result, enemy_result)
	var bullet_result: Dictionary = update_enemy_bullets({
		"delta": context["delta"],
		"bullets": result["bullets"],
		"playerPos": context["playerPos"],
		"arena": context["arena"],
		"bulletHell": context["bulletHell"]
	})
	result["bullets"] = bullet_result["bullets"]
	_merge_damage_events(result, bullet_result)
	return result

static func update_world_for_target(target: Node, delta: float, rng: RandomNumberGenerator, arena: Rect2) -> Dictionary:
	var result: Dictionary = update_enemy_world({
		"delta": delta,
		"rng": rng,
		"enemies": target.get("enemies"),
		"bullets": target.get("enemy_bullets"),
		"playerPos": target.get("player_pos"),
		"arena": arena,
		"enemySpeedRate": ModifierSystem.effect_rate_for_target(target, "enemy_speed"),
		"godReservation": ModifierSystem.has_effect_for_target(target, "god_reservation"),
		"godReservationRate": ModifierSystem.effect_rate_for_target(target, "god_reservation"),
		"bulletHell": String(target.get("active_genre_event")) == "bullet_hell"
	})
	target.set("enemy_bullets", result["bullets"])
	return result

static func _merge_damage_events(target: Dictionary, source: Dictionary) -> void:
	var target_items: Array = target.get("damageEvents", []) as Array
	var source_items: Array = source.get("damageEvents", []) as Array
	for item in source_items:
		target_items.append(item)

static func update_enemies(context: Dictionary) -> Dictionary:
	var result: Dictionary = {
		"bullets": context["bullets"],
		"damageEvents": []
	}
	var damage_events: Array = result["damageEvents"] as Array
	var bullets: Array = context["bullets"] as Array
	var enemies: Array = context["enemies"] as Array
	var rng: RandomNumberGenerator = context["rng"] as RandomNumberGenerator
	var delta: float = float(context["delta"])
	var player_pos: Vector2 = Vector2(context["playerPos"])
	var arena: Rect2 = context["arena"] as Rect2
	var speed_rate: float = 1.0 + 0.45 * float(context["enemySpeedRate"])
	if bool(context["godReservation"]):
		speed_rate += 0.10 * float(context["godReservationRate"])
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item
		var enemy_pos: Vector2 = Vector2(enemy["pos"])
		var behavior: String = String(enemy["behavior"])
		var to_player: Vector2 = player_pos - enemy_pos
		var dist: float = to_player.length()
		var dir: Vector2 = to_player.normalized()
		var speed: float = float(enemy["speed"]) * speed_rate
		if behavior == "shooter":
			if dist < 250.0:
				dir *= -1.0
			elif dist < 360.0:
				dir = Vector2.ZERO
			enemy["shoot"] = float(enemy["shoot"]) - delta
			if float(enemy["shoot"]) <= 0.0 and dist < 650.0:
				enemy["shoot"] = 1.4
				bullets.append({"pos": enemy_pos, "vel": to_player.normalized() * 260.0, "life": 3.0})
		elif behavior == "charger":
			enemy["shoot"] = float(enemy["shoot"]) - delta
			if float(enemy["shoot"]) < -0.35:
				enemy["shoot"] = rng.randf_range(1.2, 2.0)
			elif float(enemy["shoot"]) <= 0.0:
				dir = to_player.normalized() * 3.2
			else:
				dir *= 0.55
		enemy_pos += dir * speed * delta
		enemy_pos.x = clampf(enemy_pos.x, arena.position.x + 15.0, arena.end.x - 15.0)
		enemy_pos.y = clampf(enemy_pos.y, arena.position.y + 15.0, arena.end.y - 15.0)
		enemy["pos"] = enemy_pos
		if enemy_pos.distance_to(player_pos) < float(enemy["radius"]) + 22.0:
			damage_events.append({"source": String(enemy["kind"]) + " contact"})
	result["bullets"] = bullets
	return result

static func update_enemy_bullets(context: Dictionary) -> Dictionary:
	var result: Dictionary = {
		"bullets": context["bullets"],
		"damageEvents": []
	}
	var damage_events: Array = result["damageEvents"] as Array
	var bullets: Array = context["bullets"] as Array
	var delta: float = float(context["delta"])
	var player_pos: Vector2 = Vector2(context["playerPos"])
	var arena: Rect2 = context["arena"] as Rect2
	var bullet_hit_rate: float = 0.8 if bool(context["bulletHell"]) else 1.0
	for bullet_item in bullets:
		var bullet: Dictionary = bullet_item
		bullet["pos"] = Vector2(bullet["pos"]) + Vector2(bullet["vel"]) * delta
		bullet["life"] = float(bullet["life"]) - delta
		var hit_radius: float = float(bullet.get("hitRadius", 22.0)) * bullet_hit_rate
		if Vector2(bullet["pos"]).distance_to(player_pos) < hit_radius:
			bullet["life"] = -1.0
			damage_events.append({"source": String(bullet.get("source", "enemy bullet"))})
	result["bullets"] = bullets.filter(func(b): return float(b["life"]) > 0.0 and arena.grow(80).has_point(Vector2(b["pos"])))
	return result
