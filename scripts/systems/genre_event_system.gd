extends RefCounted
class_name GenreEventSystem

static func roll_event(events: Array, rng: RandomNumberGenerator) -> String:
	var pool: Array[String] = []
	for item in events:
		var event_data: Dictionary = item as Dictionary
		for i in range(int(event_data.get("weight", 1))):
			pool.append(String(event_data.get("id", "race")))
	if pool.is_empty():
		pool = ["race", "bullet_hell", "horror"]
	return pool[rng.randi_range(0, pool.size() - 1)]

static func set_next_known_event_for_target(target: Node, events: Array, rng: RandomNumberGenerator) -> String:
	var event_id: String = roll_event(events, rng)
	target.set("next_known_genre_event", event_id)
	return event_id

static func label(event_id: String) -> String:
	if event_id == "race":
		return "レースゲーム風"
	if event_id == "bullet_hell":
		return "弾幕シューティング風"
	if event_id == "horror":
		return "ホラーゲーム風"
	return "ジャンルイベント"

static func start_text(event_id: String) -> Dictionary:
	if event_id == "race":
		return {"toast": "ゲームが変わった！？ レースゲーム風！", "chat": "走り抜けろ！"}
	if event_id == "bullet_hell":
		return {"toast": "ゲームが変わった！？ 弾幕シューティング風！", "chat": "避けろ！"}
	if event_id == "horror":
		return {"toast": "ゲームが変わった！？ ホラーゲーム風！", "chat": "後ろを見るな！"}
	return {"toast": "ゲームが変わった！？", "chat": "何か始まった！"}

static func start_event_for_target(target: Node, event_id: String) -> Dictionary:
	target.set("active_genre_event", event_id)
	target.set("genre_event_timer", 12.0)
	target.set("genre_event_hurt", false)
	target.set("genre_race_move_timer", 0.0)
	target.set("genre_bullet_timer", 0.25)
	target.set("genre_event_count", int(target.get("genre_event_count")) + 1)
	if bool(target.get("first_play_adapt")):
		target.set("invincible", maxf(float(target.get("invincible")), 1.5))
	if event_id == "race":
		target.set("race_event_count", int(target.get("race_event_count")) + 1)
	elif event_id == "bullet_hell":
		target.set("bullet_hell_event_count", int(target.get("bullet_hell_event_count")) + 1)
	elif event_id == "horror":
		target.set("horror_event_count", int(target.get("horror_event_count")) + 1)
	var text_data: Dictionary = start_text(event_id)
	return {
		"toast": String(text_data["toast"]),
		"chat": String(text_data["chat"]),
		"spawnHorror": event_id == "horror"
	}

static func start_world_event_for_target(target: Node, event_id: String, arena: Rect2, rng: RandomNumberGenerator) -> Dictionary:
	var result: Dictionary = start_event_for_target(target, event_id)
	if bool(result["spawnHorror"]):
		spawn_horror_ghosts_for_target(target, arena, rng)
	return {
		"toasts": [String(result["toast"])],
		"chats": [String(result["chat"])]
	}

static func event_from_comment(comment_id: String, events: Array, rng: RandomNumberGenerator) -> String:
	if comment_id == "genre_change":
		return roll_event(events, rng)
	if comment_id == "force_bullet_hell":
		return "bullet_hell"
	if comment_id == "force_race":
		return "race"
	if comment_id == "force_horror":
		return "horror"
	return ""

static func next_event_time(elapsed: float, rng: RandomNumberGenerator) -> float:
	return elapsed + rng.randf_range(35.0, 45.0)

static func finish_event_for_target(target: Node, events: Array, rng: RandomNumberGenerator) -> void:
	var active_event: String = String(target.get("active_genre_event"))
	var hurt: bool = bool(target.get("genre_event_hurt"))
	if active_event == "bullet_hell" and not hurt:
		var gift_hype: int = clampi(int(target.get("gift_hype")) + 10, 0, 100)
		target.set("gift_hype", gift_hype)
		target.set("max_gift_hype", maxi(int(target.get("max_gift_hype")), gift_hype))
	if not hurt:
		target.set("genre_event_clear_count", int(target.get("genre_event_clear_count")) + 1)
	target.set("active_genre_event", "")
	target.set("next_genre_event_time", next_event_time(float(target.get("elapsed")), rng))
	if bool(target.get("strategy_wiki")):
		set_next_known_event_for_target(target, events, rng)

static func update_idle_event_for_target(target: Node, events: Array, rng: RandomNumberGenerator) -> Dictionary:
	if bool(target.get("strategy_wiki")) and String(target.get("next_known_genre_event")) == "":
		target.set("next_known_genre_event", roll_event(events, rng))
	if float(target.get("elapsed")) < float(target.get("next_genre_event_time")):
		return {"startEvent": ""}
	var event_id: String = String(target.get("next_known_genre_event"))
	if event_id == "":
		event_id = roll_event(events, rng)
	target.set("next_known_genre_event", "")
	return {"startEvent": event_id}

static func update_world_for_target(target: Node, delta: float, events: Array, arena: Rect2, rng: RandomNumberGenerator) -> Dictionary:
	var feedback: Dictionary = {"toasts": [], "chats": []}
	var toasts: Array = feedback["toasts"] as Array
	var chats: Array = feedback["chats"] as Array
	if String(target.get("active_genre_event")) == "":
		var idle_result: Dictionary = update_idle_event_for_target(target, events, rng)
		var event_id: String = String(idle_result["startEvent"])
		if event_id == "":
			return feedback
		var start_feedback: Dictionary = start_world_event_for_target(target, event_id, arena, rng)
		for toast in (start_feedback["toasts"] as Array):
			toasts.append(String(toast))
		for chat in (start_feedback["chats"] as Array):
			chats.append(String(chat))
		return feedback
	var result: Dictionary = update_active_event_for_target(target, delta)
	if bool(result["raceBonus"]):
		chats.append("レースボーナス +100")
	if bool(result["spawnBullet"]):
		spawn_bullet_for_target(target, arena, rng)
	if bool(result["finished"]):
		finish_event_for_target(target, events, rng)
	return feedback

static func update_world_if_enabled_for_target(target: Node, frame: Dictionary, delta: float, events: Array, arena: Rect2, rng: RandomNumberGenerator) -> Dictionary:
	if not StreamFrameSystem.has_event(frame, "game_genre_event"):
		return {"toasts": [], "chats": []}
	return update_world_for_target(target, delta, events, arena, rng)

static func start_comment_event_if_enabled_for_target(target: Node, frame: Dictionary, comment_id: String, events: Array, arena: Rect2, rng: RandomNumberGenerator) -> Dictionary:
	if not StreamFrameSystem.has_event(frame, "game_genre_event"):
		return {"toasts": [], "chats": []}
	var event_id: String = event_from_comment(comment_id, events, rng)
	if event_id == "":
		return {"toasts": [], "chats": []}
	return start_world_event_for_target(target, event_id, arena, rng)

static func update_active_event_for_target(target: Node, delta: float) -> Dictionary:
	target.set("genre_event_timer", float(target.get("genre_event_timer")) - delta)
	var active_event: String = String(target.get("active_genre_event"))
	var race_bonus: bool = false
	var spawn_bullet: bool = false
	if active_event == "race":
		if Vector2(target.get("player_vel")).length() > 80.0:
			var move_timer: float = float(target.get("genre_race_move_timer")) + delta
			if move_timer >= 2.0:
				move_timer = 0.0
				target.set("score", int(target.get("score")) + ScoreSystem.race_bonus(100, int(target.get("streaming_skill_level"))))
				race_bonus = true
			target.set("genre_race_move_timer", move_timer)
		else:
			target.set("genre_race_move_timer", 0.0)
	elif active_event == "bullet_hell":
		var bullet_timer: float = float(target.get("genre_bullet_timer")) - delta
		if bullet_timer <= 0.0:
			bullet_timer = 0.42 + 0.08 * float(target.get("kusoge_resist_level"))
			spawn_bullet = true
		target.set("genre_bullet_timer", bullet_timer)
	return {
		"raceBonus": race_bonus,
		"spawnBullet": spawn_bullet,
		"finished": float(target.get("genre_event_timer")) <= 0.0
	}

static func make_bullet(arena: Rect2, player_pos: Vector2, rng: RandomNumberGenerator) -> Dictionary:
	var side: int = rng.randi_range(0, 3)
	var pos: Vector2 = Vector2.ZERO
	if side == 0:
		pos = Vector2(rng.randf_range(arena.position.x, arena.end.x), arena.position.y - 20.0)
	elif side == 1:
		pos = Vector2(rng.randf_range(arena.position.x, arena.end.x), arena.end.y + 20.0)
	elif side == 2:
		pos = Vector2(arena.position.x - 20.0, rng.randf_range(arena.position.y, arena.end.y))
	else:
		pos = Vector2(arena.end.x + 20.0, rng.randf_range(arena.position.y, arena.end.y))
	var dir: Vector2 = (player_pos - pos).normalized().rotated(rng.randf_range(-0.22, 0.22))
	var speed: float = 185.0
	return {"pos": pos, "vel": dir * speed, "life": 5.0, "hitRadius": 17.0, "source": "genre bullet"}

static func spawn_bullet_for_target(target: Node, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var bullets: Array = target.get("enemy_bullets") as Array
	bullets.append(make_bullet(arena, Vector2(target.get("player_pos")), rng))
	target.set("enemy_bullets", bullets)

static func horror_positions(arena: Rect2, player_pos: Vector2, count: int, rng: RandomNumberGenerator) -> Array:
	var result: Array = []
	for i in range(count):
		var angle: float = rng.randf_range(0.0, TAU)
		var pos: Vector2 = player_pos + Vector2(cos(angle), sin(angle)) * rng.randf_range(300.0, 430.0)
		pos.x = clampf(pos.x, arena.position.x + 40.0, arena.end.x - 40.0)
		pos.y = clampf(pos.y, arena.position.y + 40.0, arena.end.y - 40.0)
		result.append(pos)
	return result

static func spawn_horror_ghosts_for_target(target: Node, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var count: int = 1 if int(target.get("kusoge_resist_level")) > 0 else 2
	var positions: Array = horror_positions(arena, Vector2(target.get("player_pos")), count, rng)
	var enemies: Array = target.get("enemies") as Array
	var next_uid: int = int(target.get("next_enemy_uid"))
	for item in positions:
		var pos: Vector2 = item
		enemies.append(EnemySystem.build_enemy("ghost_comment", pos, next_uid, 1.0))
		next_uid += 1
	target.set("enemies", enemies)
	target.set("next_enemy_uid", next_uid)
