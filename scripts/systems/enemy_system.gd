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
const SPAWN_EDGE_PADDING := 72.0
const SPAWN_WALL_CLEARANCE := 24.0
const SPAWN_POSITION_ATTEMPTS := 64
const SPAWN_OUTER_BAND_DEPTH := 280.0
const ENEMY_WALL_AVOIDANCE_MARGIN := 18.0
const ENEMY_WALL_AVOIDANCE_BLEND := 0.62
const ENEMY_WALL_AVOIDANCE_FALLBACK_DISTANCE := 420.0
const ENEMY_WALL_AVOIDANCE_MIN_FORWARD_DOT := 0.28
const ENEMY_WALL_AVOIDANCE_ROUTE_TURN_THRESHOLD := 160.0
const BOSS_WALL_NAVIGATION_RADIUS_RATE := 0.62
const BOSS_WALL_NAVIGATION_RADIUS_MIN := 56.0
const BOSS_WALL_UNSTICK_STEP_RATE := 0.58

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

static func contact_damage_for_kind(kind: String, is_boss: bool = false) -> int:
	if is_boss or kind.begins_with("boss_"):
		return DamageSystem.BOSS_CONTACT_DAMAGE
	if kind == "long_comment_guy" or kind == "clipper" or kind == "ghost_comment":
		return DamageSystem.STRONG_CONTACT_DAMAGE
	if kind == "fast":
		return DamageSystem.FAST_CONTACT_DAMAGE
	return DamageSystem.DEFAULT_CONTACT_DAMAGE

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

static func spawn_position(arena: Rect2, rng: RandomNumberGenerator, edge_padding: float = 20.0) -> Vector2:
	var rect := spawn_candidate_rect(arena, edge_padding)
	return spawn_position_on_rect_edge(rect, rng)

static func spawn_candidate_rect(arena: Rect2, edge_padding: float) -> Rect2:
	var rect := arena.grow(-edge_padding)
	if rect.size.x <= 1.0 or rect.size.y <= 1.0:
		return arena
	return rect

static func spawn_position_on_rect_edge(rect: Rect2, rng: RandomNumberGenerator) -> Vector2:
	var edge := rng.randi_range(0, 3)
	if edge == 0:
		return Vector2(rng.randf_range(rect.position.x, rect.end.x), rect.position.y)
	if edge == 1:
		return Vector2(rng.randf_range(rect.position.x, rect.end.x), rect.end.y)
	if edge == 2:
		return Vector2(rect.position.x, rng.randf_range(rect.position.y, rect.end.y))
	return Vector2(rect.end.x, rng.randf_range(rect.position.y, rect.end.y))

static func spawn_position_in_outer_band(rect: Rect2, rng: RandomNumberGenerator) -> Vector2:
	var band: float = minf(SPAWN_OUTER_BAND_DEPTH, minf(rect.size.x, rect.size.y) * 0.5)
	var edge := rng.randi_range(0, 3)
	if edge == 0:
		return Vector2(rng.randf_range(rect.position.x, rect.end.x), rng.randf_range(rect.position.y, rect.position.y + band))
	if edge == 1:
		return Vector2(rng.randf_range(rect.position.x, rect.end.x), rng.randf_range(rect.end.y - band, rect.end.y))
	if edge == 2:
		return Vector2(rng.randf_range(rect.position.x, rect.position.x + band), rng.randf_range(rect.position.y, rect.end.y))
	return Vector2(rng.randf_range(rect.end.x - band, rect.end.x), rng.randf_range(rect.position.y, rect.end.y))

static func spawn_walls_for_target(target: Node) -> Array:
	var stream_frame_id := String(target.get("current_stream_frame_id"))
	if stream_frame_id == "":
		stream_frame_id = "zatsudan"
	var effect_walls_value: Variant = target.get("effect_walls")
	var effect_walls: Array = []
	if effect_walls_value is Array:
		effect_walls = effect_walls_value as Array
	return movement_wall_rects(effect_walls, stream_frame_id)

static func spawn_position_blocked_by_walls(pos: Vector2, radius: float, walls: Array) -> bool:
	var clearance := radius + SPAWN_WALL_CLEARANCE
	for wall_value in walls:
		var wall := wall_value as Rect2
		if wall.grow(clearance).has_point(pos):
			return true
	return false

static func spawn_position_for_target(target: Node, arena: Rect2, rng: RandomNumberGenerator, radius: float) -> Vector2:
	var walls: Array = spawn_walls_for_target(target)
	var edge_padding := radius + SPAWN_EDGE_PADDING
	var rect := spawn_candidate_rect(arena, edge_padding)
	for i in range(SPAWN_POSITION_ATTEMPTS):
		var pos := spawn_position_on_rect_edge(rect, rng)
		if not spawn_position_blocked_by_walls(pos, radius, walls):
			return pos
	for i in range(SPAWN_POSITION_ATTEMPTS):
		var pos := spawn_position_in_outer_band(rect, rng)
		if not spawn_position_blocked_by_walls(pos, radius, walls):
			return pos
	return spawn_position(arena, rng, edge_padding)

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
		"contactDamage": int(data.get("contactDamage", contact_damage_for_kind(kind, is_boss_kind))),
		"knockbackVelocity": Vector2.ZERO,
		"defeatPending": false,
		"defeatDelay": 0.0,
		"defeatResolved": false
	}

static func spawn_enemy_for_target(target: Node, kind: String, arena: Rect2, rng: RandomNumberGenerator, pos: Vector2 = Vector2.INF) -> void:
	var spawn_pos: Vector2 = pos
	var giant_power: float = 0.0
	if ModifierSystem.has_effect_for_target(target, "giant_enemies"):
		giant_power = ModifierSystem.effect_rate_for_target(target, "giant_enemies")
	var data := enemy_data(kind)
	var spawn_radius := float(data.get("radius", 22.0))
	if giant_power > 0.0:
		spawn_radius *= lerpf(1.5, 2.0, giant_power)
	if spawn_pos == Vector2.INF:
		spawn_pos = spawn_position_for_target(target, arena, rng, spawn_radius)
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
	var base_delay: float = 0.55 if bool(enemy.get("isBoss", false)) else 0.12
	return maxf(base_delay, float(enemy.get("hitFlashDuration", 0.10)))

static func queue_defeat_for_enemy(enemy: Dictionary) -> void:
	if bool(enemy.get("defeatPending", false)) or bool(enemy.get("defeatResolved", false)):
		return
	var delay: float = defeat_delay_for_enemy(enemy)
	enemy["defeatPending"] = true
	enemy["defeatDelay"] = delay
	enemy["defeatDelayMax"] = delay
	enemy["killQueued"] = true
	if bool(enemy.get("isBoss", false)):
		enemy["hitFlashColor"] = Color(1.0, 0.96, 0.66, 1.0)
		enemy["hitFlashDuration"] = maxf(float(enemy.get("hitFlashDuration", 0.10)), 0.18)
		enemy["hitFlashTimer"] = maxf(float(enemy.get("hitFlashTimer", 0.0)), float(enemy["hitFlashDuration"]))

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

static func wall_navigation_radius(enemy: Dictionary) -> float:
	var radius := float(enemy.get("radius", 22.0))
	if bool(enemy.get("isBoss", false)):
		return minf(radius, maxf(BOSS_WALL_NAVIGATION_RADIUS_MIN, radius * BOSS_WALL_NAVIGATION_RADIUS_RATE))
	return radius

static func movement_wall_rects(effect_walls: Array, stream_frame_id: String) -> Array:
	var frame_id := stream_frame_id
	if frame_id == "":
		frame_id = "zatsudan"
	var walls: Array = DrawDataSystem.static_wall_rects(frame_id)
	for effect_wall in effect_walls:
		walls.append(effect_wall as Rect2)
	return walls

static func resolve_enemy_wall_collision(pos: Vector2, previous_pos: Vector2, radius: float, walls: Array) -> Vector2:
	var resolved: Vector2 = pos
	for wall_item in walls:
		var wall: Rect2 = wall_item as Rect2
		var grown: Rect2 = wall.grow(radius)
		if not grown.has_point(resolved):
			continue
		if previous_pos.x <= wall.position.x:
			resolved.x = wall.position.x - radius
		elif previous_pos.x >= wall.end.x:
			resolved.x = wall.end.x + radius
		elif previous_pos.y <= wall.position.y:
			resolved.y = wall.position.y - radius
		elif previous_pos.y >= wall.end.y:
			resolved.y = wall.end.y + radius
		else:
			var left_push: float = absf(resolved.x - grown.position.x)
			var right_push: float = absf(grown.end.x - resolved.x)
			var top_push: float = absf(resolved.y - grown.position.y)
			var bottom_push: float = absf(grown.end.y - resolved.y)
			var min_push: float = minf(minf(left_push, right_push), minf(top_push, bottom_push))
			if min_push == left_push:
				resolved.x = grown.position.x
			elif min_push == right_push:
				resolved.x = grown.end.x
			elif min_push == top_push:
				resolved.y = grown.position.y
			else:
				resolved.y = grown.end.y
	return resolved

static func segment_intersects_rect(from_pos: Vector2, to_pos: Vector2, rect: Rect2) -> bool:
	if rect.has_point(from_pos) or rect.has_point(to_pos):
		return true
	var delta: Vector2 = to_pos - from_pos
	var t_min := 0.0
	var t_max := 1.0
	if absf(delta.x) < 0.001:
		if from_pos.x < rect.position.x or from_pos.x > rect.end.x:
			return false
	else:
		var tx1: float = (rect.position.x - from_pos.x) / delta.x
		var tx2: float = (rect.end.x - from_pos.x) / delta.x
		t_min = maxf(t_min, minf(tx1, tx2))
		t_max = minf(t_max, maxf(tx1, tx2))
	if absf(delta.y) < 0.001:
		if from_pos.y < rect.position.y or from_pos.y > rect.end.y:
			return false
	else:
		var ty1: float = (rect.position.y - from_pos.y) / delta.y
		var ty2: float = (rect.end.y - from_pos.y) / delta.y
		t_min = maxf(t_min, minf(ty1, ty2))
		t_max = minf(t_max, maxf(ty1, ty2))
	return t_max >= t_min and t_max >= 0.0 and t_min <= 1.0

static func point_distance_to_rect(pos: Vector2, rect: Rect2) -> float:
	var dx: float = maxf(maxf(rect.position.x - pos.x, 0.0), pos.x - rect.end.x)
	var dy: float = maxf(maxf(rect.position.y - pos.y, 0.0), pos.y - rect.end.y)
	return Vector2(dx, dy).length()

static func choose_vertical_avoidance(enemy: Dictionary, enemy_pos: Vector2, goal_pos: Vector2, rect: Rect2) -> Vector2:
	if goal_pos.y <= rect.position.y:
		enemy["wallAvoidY"] = -1
		return Vector2.UP
	if goal_pos.y >= rect.end.y:
		enemy["wallAvoidY"] = 1
		return Vector2.DOWN
	var desired_delta := goal_pos.y - enemy_pos.y
	if absf(desired_delta) > ENEMY_WALL_AVOIDANCE_ROUTE_TURN_THRESHOLD:
		var route := 1 if desired_delta > 0.0 else -1
		enemy["wallAvoidY"] = route
		return Vector2.DOWN if route > 0 else Vector2.UP
	var stored_route := int(enemy.get("wallAvoidY", 0))
	if stored_route != 0:
		return Vector2.DOWN if stored_route > 0 else Vector2.UP
	if absf(desired_delta) > 18.0:
		stored_route = 1 if desired_delta > 0.0 else -1
		enemy["wallAvoidY"] = stored_route
		return Vector2.DOWN if stored_route > 0 else Vector2.UP
	var top_cost: float = absf(enemy_pos.y - rect.position.y) + absf(goal_pos.y - rect.position.y) * 0.35
	var bottom_cost: float = absf(enemy_pos.y - rect.end.y) + absf(goal_pos.y - rect.end.y) * 0.35
	if absf(top_cost - bottom_cost) <= 8.0:
		stored_route = -1 if int(enemy.get("uid", 0)) % 2 == 0 else 1
	else:
		stored_route = -1 if top_cost < bottom_cost else 1
	enemy["wallAvoidY"] = stored_route
	return Vector2.DOWN if stored_route > 0 else Vector2.UP

static func choose_horizontal_avoidance(enemy: Dictionary, enemy_pos: Vector2, goal_pos: Vector2, rect: Rect2) -> Vector2:
	if goal_pos.x <= rect.position.x:
		enemy["wallAvoidX"] = -1
		return Vector2.LEFT
	if goal_pos.x >= rect.end.x:
		enemy["wallAvoidX"] = 1
		return Vector2.RIGHT
	var desired_delta := goal_pos.x - enemy_pos.x
	if absf(desired_delta) > ENEMY_WALL_AVOIDANCE_ROUTE_TURN_THRESHOLD:
		var route := 1 if desired_delta > 0.0 else -1
		enemy["wallAvoidX"] = route
		return Vector2.RIGHT if route > 0 else Vector2.LEFT
	var stored_route := int(enemy.get("wallAvoidX", 0))
	if stored_route != 0:
		return Vector2.RIGHT if stored_route > 0 else Vector2.LEFT
	if absf(desired_delta) > 18.0:
		stored_route = 1 if desired_delta > 0.0 else -1
		enemy["wallAvoidX"] = stored_route
		return Vector2.RIGHT if stored_route > 0 else Vector2.LEFT
	var left_cost: float = absf(enemy_pos.x - rect.position.x) + absf(goal_pos.x - rect.position.x) * 0.35
	var right_cost: float = absf(enemy_pos.x - rect.end.x) + absf(goal_pos.x - rect.end.x) * 0.35
	if absf(left_cost - right_cost) <= 8.0:
		stored_route = -1 if int(enemy.get("uid", 0)) % 2 == 0 else 1
	else:
		stored_route = -1 if left_cost < right_cost else 1
	enemy["wallAvoidX"] = stored_route
	return Vector2.RIGHT if stored_route > 0 else Vector2.LEFT

static func wall_avoidance_direction(enemy: Dictionary, enemy_pos: Vector2, goal_pos: Vector2, radius: float, walls: Array) -> Vector2:
	var best_dir := Vector2.ZERO
	var best_score := INF
	var desired: Vector2 = goal_pos - enemy_pos
	if desired.length() < 0.1:
		return best_dir
	for wall_item in walls:
		var wall: Rect2 = wall_item as Rect2
		var grown: Rect2 = wall.grow(radius + ENEMY_WALL_AVOIDANCE_MARGIN)
		if not segment_intersects_rect(enemy_pos, goal_pos, grown):
			continue
		var horizontal_block: bool = (
			(enemy_pos.x <= grown.position.x and goal_pos.x >= grown.position.x)
			or (enemy_pos.x >= grown.end.x and goal_pos.x <= grown.end.x)
		)
		var vertical_block: bool = (
			(enemy_pos.y <= grown.position.y and goal_pos.y >= grown.position.y)
			or (enemy_pos.y >= grown.end.y and goal_pos.y <= grown.end.y)
		)
		var enemy_y_inside: bool = enemy_pos.y >= grown.position.y and enemy_pos.y <= grown.end.y
		var enemy_x_inside: bool = enemy_pos.x >= grown.position.x and enemy_pos.x <= grown.end.x
		var candidate := Vector2.ZERO
		if (horizontal_block and enemy_y_inside) or (enemy_y_inside and absf(desired.x) >= absf(desired.y)):
			candidate = choose_vertical_avoidance(enemy, enemy_pos, goal_pos, grown)
		elif (vertical_block and enemy_x_inside) or (enemy_x_inside and absf(desired.y) > absf(desired.x)):
			candidate = choose_horizontal_avoidance(enemy, enemy_pos, goal_pos, grown)
		else:
			candidate = choose_vertical_avoidance(enemy, enemy_pos, goal_pos, grown) if absf(desired.x) >= absf(desired.y) else choose_horizontal_avoidance(enemy, enemy_pos, goal_pos, grown)
		var score := point_distance_to_rect(enemy_pos, grown)
		if score < best_score:
			best_score = score
			best_dir = candidate
	return best_dir

static func forward_safe_avoidance_dir(base_dir: Vector2, avoid_dir: Vector2) -> Vector2:
	if avoid_dir.length() < 0.1:
		return Vector2.ZERO
	var safe_dir := avoid_dir.normalized()
	var backward: float = safe_dir.dot(base_dir)
	if backward >= -0.05:
		return safe_dir
	safe_dir = safe_dir - base_dir * backward
	if safe_dir.length() < 0.1:
		return Vector2.ZERO
	return safe_dir.normalized()

static func blended_enemy_move_dir(base_dir: Vector2, avoid_dir: Vector2, dir_power: float) -> Vector2:
	var safe_avoid := forward_safe_avoidance_dir(base_dir, avoid_dir)
	if safe_avoid.length() < 0.1:
		return base_dir * dir_power
	var mixed := (base_dir * (1.0 - ENEMY_WALL_AVOIDANCE_BLEND) + safe_avoid * ENEMY_WALL_AVOIDANCE_BLEND)
	if mixed.length() < 0.1:
		return base_dir * dir_power
	mixed = mixed.normalized()
	if mixed.dot(base_dir) < ENEMY_WALL_AVOIDANCE_MIN_FORWARD_DOT:
		var side := safe_avoid - base_dir * safe_avoid.dot(base_dir)
		if side.length() < 0.1:
			return base_dir * dir_power
		var side_rate := sqrt(1.0 - ENEMY_WALL_AVOIDANCE_MIN_FORWARD_DOT * ENEMY_WALL_AVOIDANCE_MIN_FORWARD_DOT)
		mixed = (base_dir * ENEMY_WALL_AVOIDANCE_MIN_FORWARD_DOT + side.normalized() * side_rate).normalized()
	return mixed * dir_power

static func move_enemy_with_wall_avoidance(enemy: Dictionary, enemy_pos: Vector2, dir: Vector2, speed: float, delta: float, arena: Rect2, walls: Array, player_pos: Vector2) -> Vector2:
	if dir.length() < 0.1 or speed <= 0.0:
		return enemy_pos
	var radius := wall_navigation_radius(enemy)
	var dir_power := dir.length()
	var base_dir := dir / dir_power
	var to_player := player_pos - enemy_pos
	var goal_pos := enemy_pos + base_dir * ENEMY_WALL_AVOIDANCE_FALLBACK_DISTANCE
	if to_player.length() > 0.1 and base_dir.dot(to_player.normalized()) > 0.35:
		goal_pos = player_pos
	var avoid_dir := wall_avoidance_direction(enemy, enemy_pos, goal_pos, radius, walls)
	var safe_avoid_dir := forward_safe_avoidance_dir(base_dir, avoid_dir)
	var move_dir := blended_enemy_move_dir(base_dir, safe_avoid_dir, dir_power)
	if avoid_dir.length() <= 0.1:
		enemy.erase("wallAvoidX")
		enemy.erase("wallAvoidY")

	var previous_pos := enemy_pos
	var expected_distance := speed * delta * dir_power
	var moved_pos := enemy_pos + move_dir * speed * delta
	moved_pos = clamp_enemy_pos_to_arena(moved_pos, arena)
	moved_pos = resolve_enemy_wall_collision(moved_pos, previous_pos, radius, walls)
	moved_pos = clamp_enemy_pos_to_arena(moved_pos, arena)
	var moved_step := moved_pos - previous_pos
	var moved_forward_enough := moved_step.dot(base_dir) >= expected_distance * 0.18
	if avoid_dir.length() <= 0.1 or (moved_pos.distance_to(previous_pos) >= expected_distance * 0.3 and (not bool(enemy.get("isBoss", false)) or moved_forward_enough)):
		return moved_pos

	if safe_avoid_dir.length() <= 0.1:
		return moved_pos

	var fallback_pos := enemy_pos + safe_avoid_dir * speed * delta * dir_power
	fallback_pos = clamp_enemy_pos_to_arena(fallback_pos, arena)
	fallback_pos = resolve_enemy_wall_collision(fallback_pos, previous_pos, radius, walls)
	fallback_pos = clamp_enemy_pos_to_arena(fallback_pos, arena)
	var fallback_step := fallback_pos - previous_pos
	var best_pos := moved_pos
	if fallback_step.dot(base_dir) >= -0.01 and fallback_pos.distance_to(previous_pos) > moved_pos.distance_to(previous_pos):
		best_pos = fallback_pos
	if bool(enemy.get("isBoss", false)):
		var unstick_pos := enemy_pos + base_dir * speed * delta * dir_power * BOSS_WALL_UNSTICK_STEP_RATE
		unstick_pos = clamp_enemy_pos_to_arena(unstick_pos, arena)
		var unstick_step := unstick_pos - previous_pos
		var best_step := best_pos - previous_pos
		if unstick_step.dot(base_dir) > best_step.dot(base_dir) + 0.01:
			return unstick_pos
	return best_pos

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
		if bool(enemy.get("isBoss", false)) and not bool(enemy.get("defeatReactionApplied", false)):
			enemy["defeatReactionApplied"] = true
			merge_kill_feedback(result, {
				"screenShakePower": 0.55,
				"screenShakeDuration": 0.25,
				"hitStop": 0.10,
				"screenFlashColor": Color(1.0, 0.94, 0.50, 0.34),
				"screenFlashDuration": 0.16
			})
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
	for item in (source.get("chats", []) as Array):
		chats.append(String(item))
	target["chats"] = chats
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
	var walls: Array = movement_wall_rects(effect_walls, stream_frame_id)
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
					bullets.append({"pos": enemy_pos, "vel": to_player.normalized() * 260.0, "life": SHOOTER_BULLET_LIFE, "damage": DamageSystem.ENEMY_BULLET_DAMAGE})
		elif behavior == "charger":
			enemy["shoot"] = float(enemy["shoot"]) - delta
			if float(enemy["shoot"]) < -0.35:
				enemy["shoot"] = rng.randf_range(1.2, 2.0)
			elif float(enemy["shoot"]) <= 0.0:
				dir = to_player.normalized() * 3.2
			else:
				dir *= 0.55
		enemy_pos = move_enemy_with_wall_avoidance(enemy, enemy_pos, dir, speed, delta, arena, walls, player_pos)
		enemy_pos = apply_knockback_motion(enemy, enemy_pos, enemy_pos, delta, arena, effect_walls, stream_frame_id)
		enemy["pos"] = enemy_pos
		if enemy_pos.distance_to(player_pos) < float(enemy["radius"]) + 22.0:
			var contact_source: String = String(enemy["kind"]) + " contact"
			var contact_damage: int = int(enemy.get("contactDamage", contact_damage_for_kind(String(enemy["kind"]), bool(enemy.get("isBoss", false)))))
			damage_events.append({"source": contact_source, "damage": contact_damage})
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
			damage_events.append({"source": String(bullet.get("source", "enemy bullet")), "damage": int(bullet.get("damage", DamageSystem.ENEMY_BULLET_DAMAGE))})
	result["bullets"] = bullets.filter(func(b): return float(b["life"]) > 0.0 and arena.grow(80).has_point(Vector2(b["pos"])))
	return result
