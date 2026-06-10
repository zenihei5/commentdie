class_name DestructibleSystem
extends RefCounted

const BOX_MAX_COUNT := 3
const BOX_FIRST_TIME := 15.0
const BOX_INTERVAL := 20.0
const DROP_LIFE := 15.0
const DROP_ATTRACT_RANGE := 96.0
const DROP_PICKUP_RANGE := 30.0

static func reset_for_target(target: Node) -> void:
	(target.get("destructibles") as Array).clear()
	(target.get("drop_items") as Array).clear()
	target.set("next_destructible_uid", 1)
	target.set("next_care_package_time", BOX_FIRST_TIME)

static func update_world_for_target(target: Node, delta: float, arena: Rect2, rng: RandomNumberGenerator, effect_walls: Array) -> Dictionary:
	var feedback: Dictionary = {"chats": [], "toasts": [], "dropPickupSe": false}
	_update_box_spawn_for_target(target, arena, rng, effect_walls)
	var drop_feedback: Dictionary = _update_drops_for_target(target, delta)
	for chat in (drop_feedback["chats"] as Array):
		(feedback["chats"] as Array).append(String(chat))
	for toast in (drop_feedback["toasts"] as Array):
		(feedback["toasts"] as Array).append(String(toast))
	if bool(drop_feedback.get("dropPickupSe", false)):
		feedback["dropPickupSe"] = true
	return feedback

static func _update_box_spawn_for_target(target: Node, arena: Rect2, rng: RandomNumberGenerator, effect_walls: Array) -> void:
	var elapsed: float = float(target.get("elapsed"))
	var next_time: float = float(target.get("next_care_package_time"))
	if elapsed < next_time:
		return
	target.set("next_care_package_time", next_time + BOX_INTERVAL)
	var boxes: Array = target.get("destructibles") as Array
	if _alive_box_count(boxes) >= BOX_MAX_COUNT:
		return
	spawn_box_for_target(target, arena, rng, effect_walls)

static func spawn_box_for_target(target: Node, arena: Rect2, rng: RandomNumberGenerator, effect_walls: Array) -> bool:
	var boxes: Array = target.get("destructibles") as Array
	if _alive_box_count(boxes) >= BOX_MAX_COUNT:
		return false
	var pos: Vector2 = find_spawn_position(target, arena, rng, effect_walls)
	var uid: int = int(target.get("next_destructible_uid"))
	target.set("next_destructible_uid", uid + 1)
	boxes.append({
		"id": "care_package_box",
		"uid": uid,
		"displayName": "差し入れ箱",
		"pos": pos,
		"hp": 1.0,
		"radius": 24.0,
		"spawnAge": 0.0
	})
	return true

static func _alive_box_count(boxes: Array) -> int:
	var count: int = 0
	for item in boxes:
		var box: Dictionary = item as Dictionary
		if float(box.get("hp", 0.0)) > 0.0:
			count += 1
	return count

static func find_spawn_position(target: Node, arena: Rect2, rng: RandomNumberGenerator, effect_walls: Array) -> Vector2:
	var player_pos: Vector2 = Vector2(target.get("player_pos"))
	var enemies: Array = target.get("enemies") as Array
	for i in range(20):
		var angle: float = rng.randf_range(0.0, TAU)
		var dist: float = rng.randf_range(150.0, 470.0)
		var p: Vector2 = player_pos + Vector2(cos(angle), sin(angle)) * dist
		p.x = clampf(p.x, arena.position.x + 70.0, arena.end.x - 70.0)
		p.y = clampf(p.y, arena.position.y + 80.0, arena.end.y - 80.0)
		if p.distance_to(player_pos) < 115.0:
			continue
		if _point_in_wall(p, effect_walls, String(target.get("current_stream_frame_id"))):
			continue
		if _near_enemy_cluster(p, enemies):
			continue
		return p
	return arena.get_center() + Vector2(rng.randf_range(-180.0, 180.0), rng.randf_range(-120.0, 120.0))

static func _near_enemy_cluster(p: Vector2, enemies: Array) -> bool:
	var nearby: int = 0
	for item in enemies:
		var enemy: Dictionary = item as Dictionary
		if float(enemy.get("hp", 0.0)) <= 0.0:
			continue
		if p.distance_to(Vector2(enemy["pos"])) < 95.0:
			nearby += 1
	return nearby >= 3

static func _point_in_wall(p: Vector2, effect_walls: Array, stream_frame_id: String = "zatsudan") -> bool:
	var static_walls: Array = DrawDataSystem.static_wall_rects(stream_frame_id)
	for wall in static_walls:
		var rect: Rect2 = wall as Rect2
		if rect.grow(32.0).has_point(p):
			return true
	for item in effect_walls:
		var rect: Rect2 = item as Rect2
		if rect.grow(32.0).has_point(p):
			return true
	return false

static func damage_box(box: Dictionary, damage: float, destroyed: Array, hit_effects: Array) -> bool:
	if float(box.get("hp", 0.0)) <= 0.0:
		return false
	box["hp"] = float(box.get("hp", 0.0)) - maxf(1.0, damage)
	var pos: Vector2 = Vector2(box["pos"])
	hit_effects.append({
		"kind": "pickup_text",
		"pos": pos + Vector2(-24.0, -32.0),
		"vel": Vector2(0.0, -42.0),
		"life": 0.55,
		"maxLife": 0.55,
		"text": "BREAK!",
		"color": Color("#ffdf5a")
	})
	if float(box["hp"]) <= 0.0:
		destroyed.append(box)
		return true
	return false

static func apply_destroyed_for_target(target: Node, destroyed: Array, rng: RandomNumberGenerator) -> Dictionary:
	if destroyed.is_empty():
		return {"chats": [], "toasts": []}
	var drops: Array = target.get("drop_items") as Array
	var hit_fx: Array = target.get("hit_fx") as Array
	var chats: Array = []
	for item in destroyed:
		var box: Dictionary = item as Dictionary
		var pos: Vector2 = Vector2(box["pos"])
		var drop_id: String = pick_drop_id_for_target(target, rng)
		drops.append({
			"id": drop_id,
			"displayName": drop_name(drop_id),
			"pos": pos,
			"life": DROP_LIFE,
			"age": 0.0
		})
		hit_fx.append({
			"kind": "pickup_text",
			"pos": pos + Vector2(-42.0, -38.0),
			"vel": Vector2(rng.randf_range(-12.0, 12.0), -56.0),
			"life": 0.75,
			"maxLife": 0.75,
			"text": "差し入れ！",
			"color": Color("#ff77aa")
		})
		chats.append("差し入れ箱が壊れた！")
	var alive_boxes: Array = []
	for item in (target.get("destructibles") as Array):
		var box: Dictionary = item as Dictionary
		if float(box.get("hp", 0.0)) > 0.0:
			alive_boxes.append(box)
	target.set("destructibles", alive_boxes)
	return {"chats": chats, "toasts": []}

static func pick_drop_id_for_target(target: Node, rng: RandomNumberGenerator) -> String:
	var hp_full: bool = int(target.get("player_hp")) >= int(target.get("player_max_hp"))
	var heart_pending: bool = bool(target.get("heart_pending"))
	var weights: Array = []
	if hp_full and heart_pending:
		weights = [{"id": "viewer_boost", "weight": 90}, {"id": "heal_drink", "weight": 10}]
	elif hp_full:
		weights = [{"id": "viewer_boost", "weight": 80}, {"id": "heal_drink", "weight": 10}, {"id": "heart_drop", "weight": 10}]
	elif heart_pending:
		weights = [{"id": "viewer_boost", "weight": 70}, {"id": "heal_drink", "weight": 30}]
	else:
		weights = [{"id": "viewer_boost", "weight": 60}, {"id": "heal_drink", "weight": 30}, {"id": "heart_drop", "weight": 10}]
	var total: int = 0
	for item in weights:
		total += int((item as Dictionary)["weight"])
	var roll: int = rng.randi_range(1, maxi(1, total))
	var cursor: int = 0
	for item in weights:
		var entry: Dictionary = item as Dictionary
		cursor += int(entry["weight"])
		if roll <= cursor:
			return String(entry["id"])
	return "viewer_boost"

static func drop_name(id: String) -> String:
	if id == "heal_drink":
		return "エナドリ"
	if id == "heart_drop":
		return "♡"
	return "視聴者流入"

static func _update_drops_for_target(target: Node, delta: float) -> Dictionary:
	var updated: Array = []
	var chats: Array = []
	var toasts: Array = []
	var drop_pickup_se := false
	var hit_fx: Array = target.get("hit_fx") as Array
	var player_pos: Vector2 = Vector2(target.get("player_pos"))
	for item in (target.get("drop_items") as Array):
		var drop: Dictionary = item as Dictionary
		drop["life"] = float(drop.get("life", DROP_LIFE)) - delta
		drop["age"] = float(drop.get("age", 0.0)) + delta
		var pos: Vector2 = Vector2(drop["pos"])
		var distance: float = pos.distance_to(player_pos)
		if distance < DROP_ATTRACT_RANGE and distance > 1.0:
			var speed: float = lerpf(110.0, 330.0, 1.0 - distance / DROP_ATTRACT_RANGE)
			pos += (player_pos - pos).normalized() * speed * delta
			drop["pos"] = pos
			distance = pos.distance_to(player_pos)
		if distance <= DROP_PICKUP_RANGE:
			var feedback: Dictionary = apply_drop_for_target(target, String(drop["id"]))
			chats.append(String(feedback["chat"]))
			toasts.append(String(feedback["toast"]))
			drop_pickup_se = true
			hit_fx.append({
				"kind": "pickup_text",
				"pos": player_pos + Vector2(-30.0, -48.0),
				"vel": Vector2(0.0, -52.0),
				"life": 0.72,
				"maxLife": 0.72,
				"text": String(feedback["popup"]),
				"color": feedback["color"] as Color
			})
			continue
		if float(drop["life"]) > 0.0:
			updated.append(drop)
	target.set("drop_items", updated)
	return {"chats": chats, "toasts": toasts, "dropPickupSe": drop_pickup_se}

static func apply_drop_for_target(target: Node, id: String) -> Dictionary:
	if id == "heal_drink":
		if int(target.get("player_hp")) < int(target.get("player_max_hp")):
			target.set("player_hp", mini(int(target.get("player_max_hp")), int(target.get("player_hp")) + 1))
			return {"chat": "エナドリを拾った！", "toast": "エナドリ！ メンタル +1", "popup": "メンタル +1", "color": Color("#37e06d")}
		target.set("score", int(target.get("score")) + 300)
		return {"chat": "エナドリが視聴者流入に変わった！", "toast": "メンタル満タン！ +300人", "popup": "+300人", "color": Color("#5ad7ff")}
	if id == "heart_drop":
		if not bool(target.get("heart_pending")):
			target.set("heart_pending", true)
			return {"chat": "♡を拾った！", "toast": "♡を拾った！ 次の指示コメが全部ちょっと甘くなる", "popup": "♡待機", "color": Color("#ff5fa8")}
		target.set("gift_hype", clampi(int(target.get("gift_hype")) + 15, 0, 100))
		target.set("max_gift_hype", maxi(int(target.get("max_gift_hype")), int(target.get("gift_hype"))))
		return {"chat": "♡がギフト期待度に変わった！", "toast": "♡待機中！ ギフト期待度 +15", "popup": "期待+15", "color": Color("#ff85c0")}
	target.set("score", int(target.get("score")) + 500)
	return {"chat": "視聴者流入！", "toast": "視聴者流入！ +500人", "popup": "+500人", "color": Color("#35d9ff")}
