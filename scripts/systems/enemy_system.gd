extends RefCounted
class_name EnemySystem

const BossSystemScript := preload("res://scripts/systems/boss_system.gd")
const KNOCKBACK_SPEED_SCALE := 13.0
const KNOCKBACK_DECAY_RATE := 13.0
const KNOCKBACK_STOP_SPEED := 8.0
const KNOCKBACK_MAX_SPEED := 1800.0
const SHOOTER_FIRE_INTERVAL_MIN := 2.35
const SHOOTER_FIRE_INTERVAL_MAX := 2.90
const SHOOTER_BULLET_LIFE := 2.7
const MAX_ENEMY_BULLETS := 72

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

static func hit_flash_duration_for_kind(kind: String, is_boss: bool = false) -> float:
	if is_boss or kind.begins_with("boss_"):
		return 0.06
	if kind == "long_comment_guy":
		return 0.08
	return 0.10

static func knockback_resistance_for_kind(kind: String, is_boss: bool = false) -> float:
	if is_boss or kind.begins_with("boss_"):
		return 1.0
	if kind == "fast" or kind == "unread_maro":
		return 0.1
	if kind == "shooter" or kind == "ghost_comment":
		return 0.2
	if kind == "clipper":
		return 0.3
	if kind == "long_comment_guy":
		return 0.7
	return 0.0

static func can_knockback_kind(kind: String, is_boss: bool = false) -> bool:
	return knockback_resistance_for_kind(kind, is_boss) < 1.0

static func enemy_data(kind: String) -> Dictionary:
	if kind == "fast":
		return {"displayName": "連投マン", "description": "高速で距離を詰める連投コメント敵", "hp": 8.0, "speed": 155.0, "radius": 20.0, "score": 40, "exp": 2, "behavior": "chase_fast"}
	if kind == "shooter":
		return {"displayName": "指示厨", "description": "距離を取りながら指示弾を撃つ敵", "hp": 14.0, "speed": 95.0, "radius": 24.0, "score": 60, "exp": 3, "behavior": "shooter"}
	if kind == "long_comment_guy":
		return {"displayName": "長文ニキ", "description": "遅いがしぶとく進路をふさぐ長文コメント敵", "hp": 40.0, "speed": 62.0, "radius": 34.0, "score": 80, "exp": 5, "behavior": "tank"}
	if kind == "clipper":
		return {"displayName": "悪質切り抜き師", "description": "予告後に突進して事故シーンを狙う敵", "hp": 18.0, "speed": 120.0, "radius": 23.0, "score": 100, "exp": 4, "behavior": "charger"}
	if kind == "unread_maro":
		return {"displayName": "未読マロ", "description": "放置されたマシュマロが荒らし化した敵", "hp": 8.0, "speed": 130.0, "radius": 19.0, "score": 20, "exp": 1, "behavior": "chase"}
	if kind == "ghost_comment":
		return {"displayName": "幽霊コメント", "description": "ホラー風イベント中に現れる透明気味のコメント敵", "hp": 20.0, "speed": 122.0, "radius": 23.0, "score": 120, "exp": 3, "behavior": "ghost"}
	if kind == "boss_super_long_comment":
		return {"displayName": "超長文ニキ", "description": "長文ニキの巨大版。大きなコメント塊でプレイヤーを追い詰める。", "hp": 400.0, "speed": 58.0, "radius": 78.0, "score": 3000, "exp": 20, "behavior": "tank"}
	return {"displayName": "荒らし", "description": "まっすぐ近づいてくる基本コメント敵", "hp": 10.0, "speed": 92.0, "radius": 21.0, "score": 20, "exp": 1, "behavior": "chase"}

static func spawn_position(arena: Rect2, rng: RandomNumberGenerator) -> Vector2:
	var edge := rng.randi_range(0, 3)
	if edge == 0:
		return Vector2(rng.randf_range(arena.position.x, arena.end.x), arena.position.y + 20)
	if edge == 1:
		return Vector2(rng.randf_range(arena.position.x, arena.end.x), arena.end.y - 20)
	if edge == 2:
		return Vector2(arena.position.x + 20, rng.randf_range(arena.position.y, arena.end.y))
	return Vector2(arena.end.x - 20, rng.randf_range(arena.position.y, arena.end.y))

static func speech_lines(kind: String) -> Array[String]:
	if kind == "fast":
		return ["連投失礼", "追いついた", "逃がさない", "連投マン参上"]
	if kind == "shooter":
		return ["指示します", "そこ避けて", "こう動いて", "弾幕いくぞ"]
	if kind == "long_comment_guy":
		return ["長文失礼します", "結論から言うと", "読んでください", "要約すると無理"]
	if kind == "clipper":
		return ["悪質切り抜き中", "今の切り取る", "サムネにする", "そこだけ使う"]
	if kind == "unread_maro":
		return ["未読です", "読んで", "マロ溜めるな", "返事まだ？"]
	if kind == "ghost_comment":
		return ["見てるよ", "うしろ", "消えないよ", "既読つけて"]
	return ["草", "それな〜", "逃げろ", "BANできる？", "右いけ右"]

static func random_speech(kind: String, rng: RandomNumberGenerator) -> String:
	var lines: Array[String] = speech_lines(kind)
	if lines.is_empty():
		return ""
	return lines[rng.randi_range(0, lines.size() - 1)]

static func build_enemy(kind: String, pos: Vector2, uid: int, shoot: float, giant_power: float = 0.0, speech_text: String = "") -> Dictionary:
	var data: Dictionary = enemy_data(kind)
	var is_boss_kind: bool = kind.begins_with("boss_")
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
		"expValue": data["exp"],
		"behavior": data["behavior"],
		"shoot": shoot,
		"speechText": speech_text,
		"hitFlashDuration": float(data.get("hitFlashDuration", hit_flash_duration_for_kind(kind, is_boss_kind))),
		"hitFlashTimer": 0.0,
		"knockbackResistance": float(data.get("knockbackResistance", knockback_resistance_for_kind(kind, is_boss_kind))),
		"canBeKnockedBack": bool(data.get("canBeKnockedBack", can_knockback_kind(kind, is_boss_kind))),
		"knockbackVelocity": Vector2.ZERO,
		"defeatPending": false,
		"defeatDelay": 0.0,
		"defeatResolved": false
	}

static func spawn_enemy_for_target(target: Node, kind: String, arena: Rect2, rng: RandomNumberGenerator, pos: Vector2 = Vector2.INF) -> void:
	var spawn_pos: Vector2 = pos
	if spawn_pos == Vector2.INF:
		spawn_pos = spawn_position(arena, rng)
	var giant_power: float = 0.0
	if ModifierSystem.has_effect_for_target(target, "giant_enemies"):
		giant_power = ModifierSystem.effect_rate_for_target(target, "giant_enemies")
	var shoot_seed: float = rng.randf_range(0.6, 1.4) if pos == Vector2.INF else 1.0
	if kind == "shooter":
		shoot_seed = rng.randf_range(1.4, SHOOTER_FIRE_INTERVAL_MAX)
	var enemies: Array = target.get("enemies") as Array
	var next_uid: int = int(target.get("next_enemy_uid"))
	var speech_text: String = ""
	if rng.randf() < 0.33:
		speech_text = random_speech(kind, rng)
	enemies.append(build_enemy(kind, spawn_pos, next_uid, shoot_seed, giant_power, speech_text))
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
	var is_boss: bool = bool(enemy.get("isBoss", false)) or String(enemy.get("kind", "")) == "boss_super_long_comment"
	append_defeat_fx_for_target(target, enemy, is_boss)
	if is_boss:
		return BossSystemScript.apply_defeat_for_target(target, enemy)
	target.set("score", int(target.get("score")) + ScoreSystem.enemy_score_for_target(target, enemy))
	ExpSystem.drop_from_enemy_for_target(target, enemy)
	var split_enemy: bool = ModifierSystem.has_effect_for_target(target, "split_enemy")
	var events: Dictionary = kill_events(enemy, split_enemy, rng)
	var splits: Array = events["splits"] as Array
	for item in splits:
		spawn_enemy_for_target(target, "troll", arena, rng, Vector2(item))
	return {
		"chat": String(events["chat"]),
		"enemyDefeated": true
	}

static func defeat_delay_for_enemy(enemy: Dictionary) -> float:
	var base_delay: float = 0.16 if bool(enemy.get("isBoss", false)) else 0.12
	return maxf(base_delay, float(enemy.get("hitFlashDuration", 0.10)))

static func queue_defeat_for_enemy(enemy: Dictionary) -> void:
	if bool(enemy.get("defeatPending", false)) or bool(enemy.get("defeatResolved", false)):
		return
	enemy["defeatPending"] = true
	enemy["defeatDelay"] = defeat_delay_for_enemy(enemy)
	enemy["killQueued"] = true

static func should_keep_enemy(enemy_value: Variant) -> bool:
	var enemy: Dictionary = enemy_value as Dictionary
	return not bool(enemy.get("defeatResolved", false))

static func add_knockback_for_enemy(enemy: Dictionary, direction: Vector2, distance: float) -> void:
	if distance <= 0.0:
		return
	var dir: Vector2 = direction.normalized()
	if dir.length() < 0.1:
		return
	var velocity: Vector2 = Vector2(enemy.get("knockbackVelocity", Vector2.ZERO))
	velocity += dir * distance * KNOCKBACK_SPEED_SCALE
	if velocity.length() > KNOCKBACK_MAX_SPEED:
		velocity = velocity.normalized() * KNOCKBACK_MAX_SPEED
	enemy["knockbackVelocity"] = velocity

static func clamp_enemy_pos_to_arena(pos: Vector2, arena: Rect2) -> Vector2:
	return Vector2(
		clampf(pos.x, arena.position.x + 15.0, arena.end.x - 15.0),
		clampf(pos.y, arena.position.y + 15.0, arena.end.y - 15.0)
	)

static func apply_knockback_motion(enemy: Dictionary, enemy_pos: Vector2, previous_enemy_pos: Vector2, delta: float, arena: Rect2, effect_walls: Array, stream_frame_id: String) -> Vector2:
	var velocity: Vector2 = Vector2(enemy.get("knockbackVelocity", Vector2.ZERO))
	if velocity.length() <= KNOCKBACK_STOP_SPEED:
		enemy["knockbackVelocity"] = Vector2.ZERO
		return enemy_pos
	enemy_pos += velocity * delta
	enemy_pos = clamp_enemy_pos_to_arena(enemy_pos, arena)
	enemy_pos = PlayerSystem.resolve_wall_collision(enemy_pos, previous_enemy_pos, float(enemy["radius"]), effect_walls, stream_frame_id)
	enemy_pos = clamp_enemy_pos_to_arena(enemy_pos, arena)
	velocity *= exp(-KNOCKBACK_DECAY_RATE * delta)
	if velocity.length() <= KNOCKBACK_STOP_SPEED:
		velocity = Vector2.ZERO
	enemy["knockbackVelocity"] = velocity
	return enemy_pos

static func append_defeat_fx_for_target(target: Node, enemy: Dictionary, is_boss: bool = false) -> void:
	if bool(enemy.get("defeatFxSpawned", false)):
		return
	enemy["defeatFxSpawned"] = true
	var hit_fx: Array = target.get("hit_fx") as Array
	var radius: float = float(enemy.get("radius", 22.0))
	hit_fx.append({
		"kind": "enemy_defeat",
		"pos": Vector2(enemy.get("pos", Vector2.ZERO)),
		"radius": radius,
		"life": 0.44 if is_boss else 0.28,
		"maxLife": 0.44 if is_boss else 0.28,
		"boss": is_boss
	})
	target.set("hit_fx", hit_fx)

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
		"bulletHell": String(target.get("active_genre_event")) == "bullet_hell",
		"effectWalls": target.get("effect_walls"),
		"streamFrameId": target.get("current_stream_frame_id")
	})
	target.set("enemy_bullets", result["bullets"])
	apply_pending_defeats_for_target(target, result, arena, rng)
	return result

static func apply_pending_defeats_for_target(target: Node, result: Dictionary, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var enemies: Array = target.get("enemies") as Array
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item
		if not bool(enemy.get("defeatPending", false)):
			continue
		if bool(enemy.get("defeatResolved", false)):
			continue
		if float(enemy.get("defeatDelay", 0.0)) > 0.0:
			continue
		enemy["defeatResolved"] = true
		var kill_result: Dictionary = apply_kill_for_target(target, enemy, arena, rng)
		merge_kill_feedback(result, kill_result)
	var current_enemies: Array = target.get("enemies") as Array
	target.set("enemies", current_enemies.filter(func(e): return should_keep_enemy(e)))

static func merge_kill_feedback(target: Dictionary, source: Dictionary) -> void:
	var chats: Array = target.get("chats", []) as Array
	var chat: String = String(source.get("chat", ""))
	if chat != "":
		chats.append(chat)
	target["chats"] = chats
	if float(source.get("screenShakePower", 0.0)) > float(target.get("screenShakePower", 0.0)):
		target["screenShakePower"] = float(source.get("screenShakePower", 0.0))
	if float(source.get("screenShakeDuration", 0.0)) > float(target.get("screenShakeDuration", 0.0)):
		target["screenShakeDuration"] = float(source.get("screenShakeDuration", 0.0))
	if float(source.get("hitStop", 0.0)) > float(target.get("hitStop", 0.0)):
		target["hitStop"] = float(source.get("hitStop", 0.0))
	if bool(source.get("enemyDefeated", false)):
		target["enemyDefeated"] = true

static func _merge_damage_events(target: Dictionary, source: Dictionary) -> void:
	var target_items: Array = target.get("damageEvents", []) as Array
	var source_items: Array = source.get("damageEvents", []) as Array
	for item in source_items:
		target_items.append(item)

static func update_enemies(context: Dictionary) -> Dictionary:
	var result: Dictionary = {
		"bullets": context["bullets"],
		"damageEvents": [],
		"chats": []
	}
	var damage_events: Array = result["damageEvents"] as Array
	var bullets: Array = context["bullets"] as Array
	var enemies: Array = context["enemies"] as Array
	var rng: RandomNumberGenerator = context["rng"] as RandomNumberGenerator
	var delta: float = float(context["delta"])
	var player_pos: Vector2 = Vector2(context["playerPos"])
	var arena: Rect2 = context["arena"] as Rect2
	var effect_walls: Array = context["effectWalls"] as Array
	var stream_frame_id: String = String(context["streamFrameId"])
	var speed_rate: float = 1.0 + 0.45 * float(context["enemySpeedRate"])
	if bool(context["godReservation"]):
		speed_rate += 0.10 * float(context["godReservationRate"])
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item
		var enemy_pos: Vector2 = Vector2(enemy["pos"])
		var previous_enemy_pos: Vector2 = enemy_pos
		enemy["hitFlashTimer"] = maxf(0.0, float(enemy.get("hitFlashTimer", 0.0)) - delta)
		if bool(enemy.get("defeatPending", false)):
			enemy_pos = apply_knockback_motion(enemy, enemy_pos, previous_enemy_pos, delta, arena, effect_walls, stream_frame_id)
			enemy["pos"] = enemy_pos
			enemy["defeatDelay"] = maxf(0.0, float(enemy.get("defeatDelay", 0.0)) - delta)
			continue
		var behavior: String = String(enemy["behavior"])
		var to_player: Vector2 = player_pos - enemy_pos
		var dist: float = to_player.length()
		var dir: Vector2 = to_player.normalized()
		var local_speed_rate: float = 1.0 if bool(enemy.get("isBoss", false)) else speed_rate
		var speed: float = float(enemy["speed"]) * local_speed_rate
		var slow_timer: float = float(enemy.get("slowTimer", 0.0))
		if slow_timer > 0.0:
			var slow_rate: float = clampf(float(enemy.get("slowRate", 0.0)), 0.0, 0.85)
			speed *= 1.0 - slow_rate
			enemy["slowTimer"] = maxf(0.0, slow_timer - delta)
		if behavior == "shooter":
			if dist < 250.0:
				dir *= -1.0
			elif dist < 360.0:
				dir = Vector2.ZERO
			enemy["shoot"] = float(enemy["shoot"]) - delta
			if float(enemy["shoot"]) <= 0.0 and dist < 650.0:
				enemy["shoot"] = rng.randf_range(SHOOTER_FIRE_INTERVAL_MIN, SHOOTER_FIRE_INTERVAL_MAX)
				if bullets.size() < MAX_ENEMY_BULLETS:
					bullets.append({"pos": enemy_pos, "vel": to_player.normalized() * 260.0, "life": SHOOTER_BULLET_LIFE})
		elif behavior == "charger":
			enemy["shoot"] = float(enemy["shoot"]) - delta
			if float(enemy["shoot"]) < -0.35:
				enemy["shoot"] = rng.randf_range(1.2, 2.0)
			elif float(enemy["shoot"]) <= 0.0:
				dir = to_player.normalized() * 3.2
			else:
				dir *= 0.55
		enemy_pos += dir * speed * delta
		enemy_pos = clamp_enemy_pos_to_arena(enemy_pos, arena)
		enemy_pos = PlayerSystem.resolve_wall_collision(enemy_pos, previous_enemy_pos, float(enemy["radius"]), effect_walls, stream_frame_id)
		enemy_pos = clamp_enemy_pos_to_arena(enemy_pos, arena)
		enemy_pos = apply_knockback_motion(enemy, enemy_pos, enemy_pos, delta, arena, effect_walls, stream_frame_id)
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
