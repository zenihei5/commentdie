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

static func label(event_id: String) -> String:
	if event_id == "race":
		return "Race style"
	if event_id == "bullet_hell":
		return "Bullet hell style"
	if event_id == "horror":
		return "Horror style"
	return "Unknown"

static func start_text(event_id: String) -> Dictionary:
	if event_id == "race":
		return {"toast": "Game changed: Race style!", "chat": "Keep moving!"}
	if event_id == "bullet_hell":
		return {"toast": "Game changed: Bullet hell style!", "chat": "Dodge!"}
	if event_id == "horror":
		return {"toast": "Game changed: Horror style!", "chat": "Do not look back!"}
	return {"toast": "Game changed!", "chat": "Something started!"}

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

static func horror_positions(arena: Rect2, player_pos: Vector2, count: int, rng: RandomNumberGenerator) -> Array:
	var result: Array = []
	for i in range(count):
		var angle: float = rng.randf_range(0.0, TAU)
		var pos: Vector2 = player_pos + Vector2(cos(angle), sin(angle)) * rng.randf_range(300.0, 430.0)
		pos.x = clampf(pos.x, arena.position.x + 40.0, arena.end.x - 40.0)
		pos.y = clampf(pos.y, arena.position.y + 40.0, arena.end.y - 40.0)
		result.append(pos)
	return result
