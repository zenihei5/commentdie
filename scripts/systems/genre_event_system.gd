extends RefCounted

class_name GenreEventSystem

const PowerUpEffectProviderScript := preload("res://scripts/systems/power_up_effect_provider.gd")

const FIRST_GENRE_EVENT_TIME := 25.0
const GENRE_EVENT_DURATION := 20.0
const NEXT_GENRE_EVENT_MIN_DELAY := 22.0
const NEXT_GENRE_EVENT_MAX_DELAY := 30.0
const RACE_DASH_PAD_COUNT_MIN := 3
const RACE_DASH_PAD_COUNT_MAX := 5
const RACE_DASH_BUFF_DURATION := 1.5
const RACE_DASH_MOVE_SPEED_MULTIPLIER := 1.4
const RACE_DASH_PAD_FORCE_SPEED := 980.0
const RACE_DASH_PAD_COOLDOWN := 0.55
const RACE_COIN_COUNT_MIN := 8
const RACE_COIN_COUNT_MAX := 15
const RACE_COIN_SCORE := 200
const RACE_ENEMY_SPAWN_INTERVAL := 4.4
const RACE_MAX_EVENT_ENEMIES := 6
const BULLET_HELL_START_EXTRA_ENEMIES := 4
const BULLET_HELL_SPAWN_INTERVAL := 1.20
const BULLET_HELL_MAX_ENEMIES := 120
const STG_SHOT_INTERVAL := 0.15
const STG_SHOT_DAMAGE := 3.2
const STG_SHOT_SPEED := 720.0
const STG_SHOT_RANGE := 760.0
const HORROR_FAKE_GIFT_COUNT_MIN := 2
const HORROR_FAKE_GIFT_COUNT_MAX := 4
const HORROR_FAKE_GIFT_TRIGGER_RADIUS := 100.0
const HORROR_NORMAL_GIFT_BOX_SPAWN_COUNT := 3
const PLACEMENT_ATTEMPTS := 36

static func clear_temp_objects_for_target(target: Node) -> void:
	if target.get("genre_race_dash_pads") != null:
		(target.get("genre_race_dash_pads") as Array).clear()
	if target.get("genre_race_coins") != null:
		(target.get("genre_race_coins") as Array).clear()
	if target.get("genre_horror_fake_gifts") != null:
		(target.get("genre_horror_fake_gifts") as Array).clear()
	var destructibles_value: Variant = target.get("destructibles")
	if destructibles_value is Array:
		var kept_destructibles: Array = []
		for item in destructibles_value as Array:
			var box: Dictionary = item as Dictionary
			if String(box.get("id", "")) != "horror_fake_gift":
				kept_destructibles.append(box)
		target.set("destructibles", kept_destructibles)
	target.set("genre_race_dash_boost_timer", 0.0)
	target.set("genre_race_enemy_spawn_timer", 0.0)
	target.set("genre_stg_shot_timer", 0.0)
	target.set("genre_stg_spawn_timer", 0.0)
	target.set("genre_stg_last_dir", Vector2.RIGHT)
	var bullets: Array = target.get("player_bullets") as Array
	var kept_bullets: Array = []
	for bullet_item in bullets:
		var bullet: Dictionary = bullet_item
		if String(bullet.get("source", "")) != "genre_stg_shot":
			kept_bullets.append(bullet)
	target.set("player_bullets", kept_bullets)
	var enemies_value: Variant = target.get("enemies")
	if enemies_value is Array:
		var kept_enemies: Array = []
		for item in enemies_value as Array:
			var enemy: Dictionary = item as Dictionary
			if not bool(enemy.get("genreEventEnemy", false)):
				kept_enemies.append(enemy)
		target.set("enemies", kept_enemies)

static func placement_walls_for_target(target: Node) -> Array:
	var stream_frame_id := DrawDataSystem.collision_frame_id_for_target(target)
	var walls: Array = DrawDataSystem.static_wall_rects(stream_frame_id)
	var effect_walls: Array = target.get("effect_walls") as Array
	for wall_item in effect_walls:
		walls.append(wall_item as Rect2)
	return walls

static func position_blocked(pos: Vector2, radius: float, walls: Array) -> bool:
	for wall_item in walls:
		var wall: Rect2 = wall_item as Rect2
		if wall.grow(radius + 18.0).has_point(pos):
			return true
	return false

static func too_close_to_existing(pos: Vector2, collections: Array, distance: float) -> bool:
	var min_distance_sq := distance * distance
	for collection_item in collections:
		var collection: Array = collection_item as Array
		for item in collection:
			var data: Dictionary = item as Dictionary
			if pos.distance_squared_to(Vector2(data.get("pos", Vector2.ZERO))) < min_distance_sq:
				return true
	return false

static func too_close_to_positions(pos: Vector2, positions: Array, distance: float) -> bool:
	var min_distance_sq := distance * distance
	for item in positions:
		if pos.distance_squared_to(Vector2(item)) < min_distance_sq:
			return true
	return false

static func random_event_position(target: Node, arena: Rect2, rng: RandomNumberGenerator, radius: float, min_player_distance: float, collections: Array = []) -> Vector2:
	var walls := placement_walls_for_target(target)
	var player_pos := Vector2(target.get("player_pos"))
	var inner := arena.grow(-96.0)
	if inner.size.x <= 0.0 or inner.size.y <= 0.0:
		inner = arena.grow(-32.0)
	for i in range(PLACEMENT_ATTEMPTS):
		var pos := Vector2(rng.randf_range(inner.position.x, inner.end.x), rng.randf_range(inner.position.y, inner.end.y))
		if pos.distance_squared_to(player_pos) < min_player_distance * min_player_distance:
			continue
		if position_blocked(pos, radius, walls):
			continue
		if too_close_to_existing(pos, collections, 120.0):
			continue
		return pos
	return inner.get_center() + Vector2(rng.randf_range(-160.0, 160.0), rng.randf_range(-110.0, 110.0))

static func setup_race_objects_for_target(target: Node, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var pads: Array = target.get("genre_race_dash_pads") as Array
	var coins: Array = target.get("genre_race_coins") as Array
	pads.clear()
	coins.clear()
	var pad_count := rng.randi_range(RACE_DASH_PAD_COUNT_MIN, RACE_DASH_PAD_COUNT_MAX)
	for i in range(pad_count):
		var pos := random_event_position(target, arena, rng, 42.0, 180.0, [pads])
		var angle := rng.randf_range(-0.35, 0.35)
		if absf(pos.x - arena.get_center().x) > absf(pos.y - arena.get_center().y):
			angle += PI * 0.5
		pads.append({"pos": pos, "angle": angle, "radius": 48.0, "cooldown": 0.0, "seed": rng.randf() * TAU})
	var coin_count := rng.randi_range(RACE_COIN_COUNT_MIN, RACE_COIN_COUNT_MAX)
	for i in range(coin_count):
		var base_collection: Array = [coins]
		if not pads.is_empty() and rng.randf() < 0.58:
			var pad: Dictionary = pads[rng.randi_range(0, pads.size() - 1)] as Dictionary
			var dir := Vector2(cos(float(pad.get("angle", 0.0))), sin(float(pad.get("angle", 0.0))))
			var side := Vector2(-dir.y, dir.x)
			var candidate := Vector2(pad["pos"]) + dir * rng.randf_range(110.0, 260.0) + side * rng.randf_range(-70.0, 70.0)
			candidate.x = clampf(candidate.x, arena.position.x + 72.0, arena.end.x - 72.0)
			candidate.y = clampf(candidate.y, arena.position.y + 72.0, arena.end.y - 72.0)
			if not position_blocked(candidate, 24.0, placement_walls_for_target(target)) and not too_close_to_existing(candidate, base_collection, 58.0):
				coins.append({"pos": candidate, "radius": 24.0, "seed": rng.randf() * TAU})
				continue
		coins.append({"pos": random_event_position(target, arena, rng, 24.0, 140.0, base_collection), "radius": 24.0, "seed": rng.randf() * TAU})
	target.set("genre_race_dash_pads", pads)
	target.set("genre_race_coins", coins)
	target.set("genre_race_enemy_spawn_timer", 2.4)

static func setup_bullet_hell_objects_for_target(target: Node, arena: Rect2, rng: RandomNumberGenerator) -> void:
	target.set("genre_stg_shot_timer", 0.05)
	target.set("genre_stg_spawn_timer", 0.8)
	target.set("genre_stg_last_dir", Vector2.RIGHT if float(target.get("player_facing_x")) >= 0.0 else Vector2.LEFT)
	for i in range(BULLET_HELL_START_EXTRA_ENEMIES):
		spawn_bullet_hell_enemy_for_target(target, arena, rng)

static func setup_horror_objects_for_target(target: Node, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var fake_gifts: Array = target.get("genre_horror_fake_gifts") as Array
	var destructibles: Array = target.get("destructibles") as Array
	fake_gifts.clear()
	var count := rng.randi_range(HORROR_FAKE_GIFT_COUNT_MIN, HORROR_FAKE_GIFT_COUNT_MAX)
	for i in range(count):
		var uid := int(target.get("next_destructible_uid"))
		target.set("next_destructible_uid", uid + 1)
		var fake_gift := {
			"id": "horror_fake_gift",
			"uid": uid,
			"displayName": "偽ギフトボックス",
			"pos": random_event_position(target, arena, rng, 30.0, 220.0, [fake_gifts]),
			"hp": 1.0,
			"radius": 24.0,
			"seed": rng.randf() * TAU
		}
		fake_gifts.append(fake_gift)
		destructibles.append(fake_gift)
	target.set("genre_horror_fake_gifts", fake_gifts)
	target.set("destructibles", destructibles)
	spawn_horror_normal_gift_boxes_for_target(target, arena, rng)

static func spawn_horror_normal_gift_boxes_for_target(target: Node, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var effect_walls: Array = target.get("effect_walls") as Array
	var spawned := 0
	for i in range(HORROR_NORMAL_GIFT_BOX_SPAWN_COUNT):
		if DestructibleSystem.spawn_box_for_target(target, arena, rng, effect_walls):
			spawned += 1
	if spawned > 0:
		var elapsed: float = float(target.get("elapsed"))
		var current_next_time: float = float(target.get("next_care_package_time"))
		var next_time: float = elapsed + DestructibleSystem.HORROR_BOX_INTERVAL
		if current_next_time >= elapsed and current_next_time <= next_time:
			next_time = current_next_time
		target.set("next_care_package_time", next_time)

static func roll_event(events: Array, rng: RandomNumberGenerator, excluded_event_id: String = "") -> String:
	var pool: Array[String] = []
	for item in events:
		var event_data: Dictionary = item as Dictionary
		var event_id := String(event_data.get("id", "race"))
		if excluded_event_id != "" and event_id == excluded_event_id:
			continue
		for i in range(int(event_data.get("weight", 1))):
			pool.append(event_id)
	if pool.is_empty():
		for fallback_id in ["race", "bullet_hell", "horror"]:
			if excluded_event_id == "" or fallback_id != excluded_event_id:
				pool.append(fallback_id)
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

static func start_comment_event_id(event_id: String) -> String:
	if event_id == "race":
		return "gameplay_race_start"
	if event_id == "bullet_hell":
		return "gameplay_bullet_start"
	if event_id == "horror":
		return "gameplay_horror_start"
	return "gameplay_genre_change_common"

static func finish_comment_event_id(event_id: String) -> String:
	if event_id == "race":
		return "gameplay_race_finish"
	if event_id == "bullet_hell":
		return "gameplay_bullet_finish"
	if event_id == "horror":
		return "gameplay_horror_finish"
	return ""

static func pending_defeat_count_for_target(target: Node, defeat_source: String = "", enemy_source: String = "") -> int:
	var count := 0
	var enemies: Array = target.get("enemies") as Array
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if not bool(enemy.get("defeatPending", false)) or bool(enemy.get("defeatResolved", false)):
			continue
		if defeat_source != "" and String(enemy.get("defeatSource", enemy.get("lastHitSource", ""))) != defeat_source:
			continue
		if enemy_source != "" and String(enemy.get("source", "")) != enemy_source:
			continue
		count += 1
	return count

static func result_card_for_target(target: Node, event_id: String) -> Dictionary:
	var lines: Array[String] = []
	var title := ""
	if event_id == "race":
		title = "レースゲーム風 RESULT"
		lines.append("コイン回収 %d" % int(target.get("genre_result_coin_count")))
		lines.append("ダッシュ床 %d" % int(target.get("genre_result_dash_pad_count")))
	elif event_id == "bullet_hell":
		title = "弾幕STG風 RESULT"
		var kill_count: int = maxi(0, int(target.get("kills")) - int(target.get("genre_event_start_kills"))) + pending_defeat_count_for_target(target)
		lines.append("撃破数 %d" % kill_count)
		var shot_kills: int = int(target.get("genre_result_stg_shot_kill_count")) + pending_defeat_count_for_target(target, "genre_stg_shot")
		lines.append("ショット撃破 %d" % shot_kills)
	elif event_id == "horror":
		title = "ホラーゲーム風 RESULT"
		var fake_gift_kills: int = int(target.get("genre_result_fake_gift_defeat_count")) + pending_defeat_count_for_target(target, "", "fake_gift")
		lines.append("偽ギフト撃破 %d" % fake_gift_kills)
	else:
		title = "ジャンルイベント 終了！"
	return {
		"eventId": event_id,
		"title": title,
		"lines": lines,
		"duration": 1.55
	}

static func start_event_for_target(target: Node, event_id: String, duration: float = GENRE_EVENT_DURATION, source: String = "random") -> Dictionary:
	target.set("active_genre_event", event_id)
	target.set("genre_event_timer", duration)
	target.set("genre_event_duration", duration)
	target.set("genre_event_source", source)
	target.set("genre_event_hurt", false)
	target.set("genre_race_move_timer", 0.0)
	target.set("genre_bullet_timer", 0.25)
	target.set("genre_result_coin_count", 0)
	target.set("genre_result_dash_pad_count", 0)
	target.set("genre_event_start_kills", int(target.get("kills")))
	target.set("genre_result_stg_shot_kill_count", 0)
	target.set("genre_result_fake_gift_defeat_count", 0)
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
		"commentEventId": start_comment_event_id(event_id),
		"spawnHorror": event_id == "horror"
	}

static func start_world_event_for_target(target: Node, event_id: String, arena: Rect2, rng: RandomNumberGenerator, duration: float = GENRE_EVENT_DURATION, source: String = "random") -> Dictionary:
	clear_temp_objects_for_target(target)
	var result: Dictionary = start_event_for_target(target, event_id, duration, source)
	if event_id == "race":
		setup_race_objects_for_target(target, arena, rng)
	elif event_id == "bullet_hell":
		setup_bullet_hell_objects_for_target(target, arena, rng)
	elif event_id == "horror":
		setup_horror_objects_for_target(target, arena, rng)
	if bool(result["spawnHorror"]):
		spawn_horror_ghosts_for_target(target, arena, rng)
	var comment_event_ids: Array[String] = [String(result["commentEventId"])]
	if event_id == "horror":
		comment_event_ids.append("gameplay_horror_fake_gift_spawn")
	return {
		"toasts": [String(result["toast"])],
		"chats": [String(result["chat"])],
		"commentEventIds": comment_event_ids
	}

static func event_from_comment(comment_id: String, events: Array, rng: RandomNumberGenerator, excluded_event_id: String = "") -> String:
	if comment_id == "genre_change":
		return roll_event(events, rng, excluded_event_id)
	if comment_id == "force_bullet_hell":
		return "bullet_hell"
	if comment_id == "force_race":
		return "race"
	if comment_id == "force_horror":
		return "horror"
	return ""

static func next_event_time(elapsed: float, rng: RandomNumberGenerator) -> float:
	return elapsed + rng.randf_range(NEXT_GENRE_EVENT_MIN_DELAY, NEXT_GENRE_EVENT_MAX_DELAY)

static func finish_event_for_target(target: Node, events: Array, rng: RandomNumberGenerator) -> void:
	var active_event: String = String(target.get("active_genre_event"))
	var hurt: bool = bool(target.get("genre_event_hurt"))
	if active_event == "bullet_hell" and not hurt:
		var gift_hype: int = clampi(int(target.get("gift_hype")) + 10, 0, 100)
		target.set("gift_hype", gift_hype)
		target.set("max_gift_hype", maxi(int(target.get("max_gift_hype")), gift_hype))
	if not hurt:
		target.set("genre_event_clear_count", int(target.get("genre_event_clear_count")) + 1)
	clear_temp_objects_for_target(target)
	target.set("active_genre_event", "")
	target.set("genre_event_source", "")
	target.set("genre_event_duration", GENRE_EVENT_DURATION)
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
	var comment_event_ids: Array[String] = []
	if String(target.get("active_genre_event")) == "":
		if bool(target.get("boss_active")) or bool(target.get("boss_requested")):
			return feedback
		var idle_result: Dictionary = update_idle_event_for_target(target, events, rng)
		var event_id: String = String(idle_result["startEvent"])
		if event_id == "":
			return feedback
		var start_feedback: Dictionary = start_world_event_for_target(target, event_id, arena, rng)
		for toast in (start_feedback["toasts"] as Array):
			toasts.append(String(toast))
		for chat in (start_feedback["chats"] as Array):
			chats.append(String(chat))
		for event_id_item in (start_feedback.get("commentEventIds", []) as Array):
			comment_event_ids.append(String(event_id_item))
		feedback["commentEventIds"] = comment_event_ids
		return feedback
	var result: Dictionary = update_active_event_for_target(target, delta, arena, rng)
	if bool(result["raceBonus"]):
		chats.append("レースボーナス +100")
	for chat in (result.get("chats", []) as Array):
		chats.append(String(chat))
	for event_id_item in (result.get("commentEventIds", []) as Array):
		comment_event_ids.append(String(event_id_item))
	if bool(result["spawnBullet"]):
		spawn_bullet_for_target(target, arena, rng)
	if bool(result["finished"]):
		var finished_event := String(target.get("active_genre_event"))
		feedback["genreResult"] = result_card_for_target(target, finished_event)
		finish_event_for_target(target, events, rng)
		var finish_event_id := finish_comment_event_id(finished_event)
		if finish_event_id != "":
			comment_event_ids.append(finish_event_id)
	feedback["commentEventIds"] = comment_event_ids
	return feedback

static func update_world_if_enabled_for_target(target: Node, frame: Dictionary, delta: float, events: Array, arena: Rect2, rng: RandomNumberGenerator) -> Dictionary:
	if not StreamFrameSystem.has_event(frame, "game_genre_event"):
		return {"toasts": [], "chats": []}
	return update_world_for_target(target, delta, events, arena, rng)

static func start_comment_event_if_enabled_for_target(target: Node, frame: Dictionary, comment_id: String, events: Array, arena: Rect2, rng: RandomNumberGenerator) -> Dictionary:
	if not StreamFrameSystem.has_event(frame, "game_genre_event"):
		return {"toasts": [], "chats": []}
	if bool(target.get("boss_active")):
		return {"toasts": [], "chats": []}
	var active_event := String(target.get("active_genre_event"))
	var event_id: String = event_from_comment(comment_id, events, rng, active_event)
	if active_event != "" and event_id == active_event:
		return {"toasts": [], "chats": []}
	if event_id == "":
		return {"toasts": [], "chats": []}
	return start_world_event_for_target(target, event_id, arena, rng)

static func update_active_event_for_target(target: Node, delta: float, arena: Rect2, rng: RandomNumberGenerator) -> Dictionary:
	target.set("genre_event_timer", float(target.get("genre_event_timer")) - delta)
	var active_event: String = String(target.get("active_genre_event"))
	var race_bonus: bool = false
	var spawn_bullet: bool = false
	var chats: Array[String] = []
	var comment_event_ids: Array[String] = []
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
		update_race_objects_for_target(target, delta, arena, rng, chats, comment_event_ids)
	elif active_event == "bullet_hell":
		var bullet_timer: float = float(target.get("genre_bullet_timer")) - delta
		if bullet_timer <= 0.0:
			bullet_timer = 0.42 + 0.08 * float(target.get("kusoge_resist_level"))
			spawn_bullet = true
		target.set("genre_bullet_timer", bullet_timer)
		update_bullet_hell_objects_for_target(target, delta, arena, rng, chats, comment_event_ids)
	elif active_event == "horror":
		update_horror_objects_for_target(target, rng, chats, comment_event_ids)
	return {
		"raceBonus": race_bonus,
		"spawnBullet": spawn_bullet,
		"chats": chats,
		"commentEventIds": comment_event_ids,
		"finished": float(target.get("genre_event_timer")) <= 0.0
	}

static func append_pickup_text_for_target(target: Node, pos: Vector2, text: String, color: Color) -> void:
	var hit_fx: Array = target.get("hit_fx") as Array
	hit_fx.append({
		"kind": "pickup_text",
		"pos": pos,
		"vel": Vector2(0.0, -42.0),
		"life": 0.72,
		"maxLife": 0.72,
		"text": text,
		"color": color
	})
	target.set("hit_fx", hit_fx)

static func update_race_objects_for_target(target: Node, delta: float, arena: Rect2, rng: RandomNumberGenerator, chats: Array[String], comment_event_ids: Array[String]) -> void:
	var player_pos := Vector2(target.get("player_pos"))
	var boost_timer := maxf(0.0, float(target.get("genre_race_dash_boost_timer")) - delta)
	var pads: Array = target.get("genre_race_dash_pads") as Array
	for pad_item in pads:
		var pad: Dictionary = pad_item as Dictionary
		var cooldown := maxf(0.0, float(pad.get("cooldown", 0.0)) - delta)
		pad["cooldown"] = cooldown
		var radius := float(pad.get("radius", 48.0)) + 22.0
		if cooldown <= 0.0 and player_pos.distance_squared_to(Vector2(pad.get("pos", Vector2.ZERO))) <= radius * radius:
			var pad_dir := Vector2(cos(float(pad.get("angle", 0.0))), sin(float(pad.get("angle", 0.0)))).normalized()
			var current_speed := Vector2(target.get("player_vel")).length()
			target.set("player_vel", pad_dir * maxf(RACE_DASH_PAD_FORCE_SPEED, current_speed))
			if absf(pad_dir.x) > 0.05:
				target.set("player_facing_x", -1.0 if pad_dir.x < 0.0 else 1.0)
			boost_timer = maxf(boost_timer, RACE_DASH_BUFF_DURATION)
			pad["cooldown"] = RACE_DASH_PAD_COOLDOWN
			target.set("genre_result_dash_pad_count", int(target.get("genre_result_dash_pad_count")) + 1)
			append_pickup_text_for_target(target, Vector2(pad.get("pos", player_pos)) + Vector2(0.0, -26.0), "BOOST", Color("#ffb84d"))
			if not comment_event_ids.has("gameplay_race_dash_pad_used"):
				comment_event_ids.append("gameplay_race_dash_pad_used")
	target.set("genre_race_dash_boost_timer", boost_timer)
	var coins: Array = target.get("genre_race_coins") as Array
	var kept_coins: Array = []
	var picked_count := 0
	for coin_item in coins:
		var coin: Dictionary = coin_item as Dictionary
		var pickup_base := 24.0
		var snapshot = target.get("permanent_upgrade_snapshot")
		if snapshot != null:
			pickup_base = PowerUpEffectProviderScript.normal_pickup_radius(pickup_base, snapshot)
		var radius := float(coin.get("radius", 24.0)) + pickup_base
		var coin_pos := Vector2(coin.get("pos", Vector2.ZERO))
		if player_pos.distance_squared_to(coin_pos) <= radius * radius:
			var score_gain := ScoreSystem.race_bonus(RACE_COIN_SCORE, int(target.get("streaming_skill_level")))
			target.set("score", int(target.get("score")) + score_gain)
			append_pickup_text_for_target(target, coin_pos + Vector2(0.0, -22.0), "+%d" % score_gain, Color("#ffd35a"))
			picked_count += 1
		else:
			kept_coins.append(coin)
	target.set("genre_race_coins", kept_coins)
	if picked_count > 0 and chats.is_empty():
		chats.append("コインうまい")
	if picked_count > 0:
		target.set("genre_result_coin_count", int(target.get("genre_result_coin_count")) + picked_count)
		comment_event_ids.append("gameplay_race_coin_collected")
	var race_enemy_timer := float(target.get("genre_race_enemy_spawn_timer")) - delta
	if race_enemy_timer <= 0.0:
		race_enemy_timer = RACE_ENEMY_SPAWN_INTERVAL
		spawn_race_enemy_for_target(target, arena, rng)
	target.set("genre_race_enemy_spawn_timer", race_enemy_timer)

static func genre_event_enemy_count_for_target(target: Node, kinds: Array[String]) -> int:
	var count := 0
	for item in (target.get("enemies") as Array):
		var enemy: Dictionary = item as Dictionary
		if bool(enemy.get("genreEventEnemy", false)) and kinds.has(String(enemy.get("kind", ""))):
			count += 1
	return count

static func spawn_race_enemy_for_target(target: Node, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var race_kinds: Array[String] = ["enemy_wrong_way_kart", "enemy_jammer_cone"]
	if genre_event_enemy_count_for_target(target, race_kinds) >= RACE_MAX_EVENT_ENEMIES:
		return
	var kind := EnemySystem.pick_race_event_enemy(float(target.get("elapsed")), bool(target.get("quick_test_mode")), rng)
	if kind == "enemy_jammer_cone":
		EnemySystem.spawn_enemy_for_target(target, kind, arena, rng)
		return
	EnemySystem.spawn_enemy_for_target(target, kind, arena, rng)

static func update_bullet_hell_objects_for_target(target: Node, delta: float, arena: Rect2, rng: RandomNumberGenerator, chats: Array[String], comment_event_ids: Array[String]) -> void:
	var player_vel := Vector2(target.get("player_vel"))
	if player_vel.length() > 36.0:
		target.set("genre_stg_last_dir", player_vel.normalized())
	var shot_timer := float(target.get("genre_stg_shot_timer")) - delta
	var shots_fired := 0
	while shot_timer <= 0.0 and shots_fired < 3:
		fire_stg_shot_for_target(target)
		shot_timer += STG_SHOT_INTERVAL
		shots_fired += 1
	if shot_timer <= 0.0:
		shot_timer = STG_SHOT_INTERVAL
	target.set("genre_stg_shot_timer", shot_timer)
	var spawn_timer := float(target.get("genre_stg_spawn_timer")) - delta
	if spawn_timer <= 0.0:
		spawn_timer = BULLET_HELL_SPAWN_INTERVAL
		spawn_bullet_hell_enemy_for_target(target, arena, rng)
		if not comment_event_ids.has("gameplay_bullet_enemy_increase"):
			comment_event_ids.append("gameplay_bullet_enemy_increase")
		if rng.randf() < 0.18:
			chats.append("敵増えてきた")
	target.set("genre_stg_spawn_timer", spawn_timer)

static func fire_stg_shot_for_target(target: Node) -> void:
	var dir := Vector2(target.get("genre_stg_last_dir"))
	if dir.length() < 0.1:
		dir = Vector2.RIGHT if float(target.get("player_facing_x")) >= 0.0 else Vector2.LEFT
	dir = dir.normalized()
	var bullets: Array = target.get("player_bullets") as Array
	bullets.append({
		"pos": Vector2(target.get("player_pos")) + dir * 28.0,
		"vel": dir * STG_SHOT_SPEED,
		"life": STG_SHOT_RANGE / STG_SHOT_SPEED,
		"damage": STG_SHOT_DAMAGE,
		"hitRadius": 8.0,
		"visualKind": "genre_stg_shot",
		"source": "genre_stg_shot",
		"pierceLeft": 0
	})
	target.set("player_bullets", bullets)

static func spawn_bullet_hell_enemy_for_target(target: Node, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var enemies: Array = target.get("enemies") as Array
	if enemies.size() >= BULLET_HELL_MAX_ENEMIES:
		return
	var kind := EnemySystem.pick_bullet_hell_enemy(float(target.get("elapsed")), bool(target.get("quick_test_mode")), rng)
	EnemySystem.spawn_enemy_for_target(target, kind, arena, rng)

static func update_horror_objects_for_target(target: Node, _rng: RandomNumberGenerator, _chats: Array[String], _comment_event_ids: Array[String]) -> void:
	var synced_gifts: Array = []
	for sync_item in (target.get("genre_horror_fake_gifts") as Array):
		var sync_gift: Dictionary = sync_item as Dictionary
		if float(sync_gift.get("hp", 0.0)) > 0.0:
			synced_gifts.append(sync_gift)
	target.set("genre_horror_fake_gifts", synced_gifts)

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
	return {"pos": pos, "vel": dir * speed, "life": 5.0, "hitRadius": 17.0, "source": "genre bullet", "erasableByPinkPaint": true}

static func spawn_bullet_for_target(target: Node, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var bullets: Array = target.get("enemy_bullets") as Array
	bullets.append(make_bullet(arena, Vector2(target.get("player_pos")), rng))
	target.set("enemy_bullets", bullets)

static func horror_positions(target: Node, arena: Rect2, _player_pos: Vector2, count: int, rng: RandomNumberGenerator) -> Array:
	var result: Array = []
	for i in range(count):
		for attempt in range(PLACEMENT_ATTEMPTS):
			var pos := EnemySystem.spawn_position_for_target(target, arena, rng, 30.0)
			if pos == Vector2.INF:
				continue
			if too_close_to_positions(pos, result, 96.0):
				continue
			result.append(pos)
			break
	return result

static func spawn_horror_ghosts_for_target(target: Node, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var count: int = 1 if int(target.get("kusoge_resist_level")) > 0 else 2
	var positions: Array = horror_positions(target, arena, Vector2(target.get("player_pos")), count, rng)
	var enemies: Array = target.get("enemies") as Array
	var next_uid: int = int(target.get("next_enemy_uid"))
	for item in positions:
		var pos: Vector2 = item
		var speech_text: String = ""
		if rng.randf() < 0.33:
			speech_text = EnemySystem.random_speech("ghost_comment", rng)
		var enemy := EnemySystem.build_enemy("ghost_comment", pos, next_uid, 1.0, 0.0, speech_text)
		enemy["genreEventEnemy"] = true
		enemies.append(enemy)
		next_uid += 1
	var noise_count := 1
	var noise_positions: Array = horror_positions(target, arena, Vector2(target.get("player_pos")), noise_count, rng)
	for item in noise_positions:
		var pos: Vector2 = item
		var speech_text := ""
		if rng.randf() < 0.45:
			speech_text = EnemySystem.random_speech("enemy_noise_ghost_comment", rng)
		var noise_enemy := EnemySystem.build_enemy("enemy_noise_ghost_comment", pos, next_uid, 1.0, 0.0, speech_text)
		noise_enemy["genreEventEnemy"] = true
		enemies.append(noise_enemy)
		next_uid += 1
	target.set("enemies", enemies)
	target.set("next_enemy_uid", next_uid)
