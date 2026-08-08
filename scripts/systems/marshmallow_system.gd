extends RefCounted
class_name MarshmallowSystem

const PowerUpEffectProviderScript := preload("res://scripts/systems/power_up_effect_provider.gd")

const PICKUP_BASE_RANGE := 40.0
const DEFAULT_AUTO_PICKUP_LIMIT := 2
const GAMEPLAY_AUTO_PICKUP_LIMIT := 1
const GAMEPLAY_DROP_PICKUP_LIMIT := 3
const DEFAULT_SPAWN_INTERVAL_MIN := 35.0
const DEFAULT_SPAWN_INTERVAL_MAX := 45.0
const GAMEPLAY_SPAWN_INTERVAL_MIN := 30.0
const GAMEPLAY_SPAWN_INTERVAL_MAX := 45.0
const GAMEPLAY_BULLET_HELL_SPAWN_INTERVAL_MIN := 42.0
const GAMEPLAY_BULLET_HELL_SPAWN_INTERVAL_MAX := 58.0
const SINGING_SPAWN_INTERVAL_MIN := 38.0
const SINGING_SPAWN_INTERVAL_MAX := 52.0

static func pick_data(context: Dictionary) -> Dictionary:
	var pool: Array = []
	var data_list: Array = context["data"] as Array
	var rng: RandomNumberGenerator = context["rng"] as RandomNumberGenerator
	var elapsed: float = float(context["elapsed"])
	var quick_test: bool = bool(context["quickTest"])
	var last_was_bad: bool = bool(context["lastWasBad"])
	var t: float = elapsed * (3.0 if quick_test else 1.0)
	var bad_rate: float = bad_rate_for_time(t)
	var want_bad: bool = rng.randf() < bad_rate and not last_was_bad
	for item in data_list:
		var data: Dictionary = item as Dictionary
		if t < float(data["minTime"]):
			continue
		var is_bad: bool = String(data["type"]) == "bad"
		if is_bad != want_bad:
			continue
		for i in range(int(data["weight"])):
			pool.append(data)
	if pool.is_empty():
		for item in data_list:
			var fallback: Dictionary = item as Dictionary
			if String(fallback["type"]) == "good" and t >= float(fallback["minTime"]):
				pool.append(fallback)
	if pool.is_empty():
		return {}
	return pool[rng.randi_range(0, pool.size() - 1)] as Dictionary

static func pick_debug_data(data_list: Array, kind: String, rng: RandomNumberGenerator) -> Dictionary:
	var pool: Array = []
	for item in data_list:
		var data: Dictionary = item as Dictionary
		if kind == "random":
			pool.append(data)
		elif kind == "bad" and String(data["type"]) == "bad":
			pool.append(data)
		elif kind == "god" and String(data["rarity"]) == "god":
			pool.append(data)
	if pool.is_empty():
		return {}
	return pool[rng.randi_range(0, pool.size() - 1)] as Dictionary

static func pick_data_for_target(target: Node, data_list: Array, rng: RandomNumberGenerator) -> Dictionary:
	return pick_data({
		"data": data_list,
		"rng": rng,
		"elapsed": target.get("elapsed"),
		"quickTest": target.get("quick_test_mode"),
		"lastWasBad": target.get("last_maro_was_kuso")
	})

static func speech_lines(data: Dictionary) -> Array[String]:
	if String(data.get("type", "")) == "bad":
		return ["開ける？", "一言いい？", "変な味する", "読まない方がいい"]
	if String(data.get("rarity", "")) == "god":
		return ["神マロです", "これは当たり", "救援物資", "読んで！"]
	var effect_type: String = String(data.get("effectType", ""))
	if effect_type == "heal":
		return ["がんばれ", "休んで", "回復どうぞ", "無理しないで"]
	if effect_type == "exp":
		return ["これ使えるかも", "成長チャンス", "拾って〜", "助かるやつ"]
	if effect_type == "score":
		return ["切り抜きたい", "今の良い", "拡散しとく", "伸びろ〜"]
	return ["差し入れです", "読んで〜", "いいマロ", "助かる"]

static func random_speech(data: Dictionary, rng: RandomNumberGenerator) -> String:
	var lines: Array[String] = speech_lines(data)
	if lines.is_empty():
		return ""
	return lines[rng.randi_range(0, lines.size() - 1)]

static func spawn_pickup_for_target(target: Node, data: Dictionary, rng: RandomNumberGenerator, arena: Rect2, effect_walls: Array, spawn_pos: Vector2 = Vector2.INF, source: String = "auto", reschedule: bool = true) -> bool:
	if data.is_empty():
		return false
	var stream_frame_id := DrawDataSystem.collision_frame_id_for_target(target)
	var pos: Vector2 = spawn_pos
	if pos == Vector2.INF:
		pos = find_position({
			"rng": rng,
			"arena": arena,
			"playerPos": target.get("player_pos"),
			"effectWalls": effect_walls,
			"streamFrameId": stream_frame_id
		})
	else:
		pos.x = clampf(pos.x, arena.position.x + 60.0, arena.end.x - 60.0)
		pos.y = clampf(pos.y, arena.position.y + 60.0, arena.end.y - 60.0)
		if point_in_wall(pos, effect_walls, stream_frame_id):
			pos = find_position({
				"rng": rng,
				"arena": arena,
				"playerPos": target.get("player_pos"),
				"effectWalls": effect_walls,
				"streamFrameId": stream_frame_id
			})
	var pickups: Array = target.get("marshmallows") as Array
	var read_bonus: float = float(target.get("read_manager_level")) * 5.0
	var speech_text: String = random_speech(data, rng)
	pickups.append({
		"pos": pos,
		"time": 12.0 + read_bonus,
		"data": data,
		"speechText": speech_text,
		"pickupType": "marshmallow",
		"itemTag": "sweet",
		"displayName": pickup_display_name_for_target(target),
		"source": source
	})
	if reschedule:
		target.set("next_mallow_time", float(target.get("elapsed")) + next_spawn_interval_for_target(target, rng))
	return true

static func spawn_random_for_target(target: Node, data_list: Array, rng: RandomNumberGenerator, arena: Rect2, effect_walls: Array) -> bool:
	var data: Dictionary = pick_data_for_target(target, data_list, rng)
	return spawn_pickup_for_target(target, data, rng, arena, effect_walls)

static func pickup_display_name_for_target(target: Node) -> String:
	if String(target.get("current_stream_frame_id")) == "gameplay":
		return "差し入れマシュマロ"
	if String(target.get("current_stream_frame_id")) == "singing":
		return "ライブ差し入れマロ"
	return "マシュマロ"

static func next_spawn_interval_for_target(target: Node, rng: RandomNumberGenerator) -> float:
	var frame_id := String(target.get("current_stream_frame_id"))
	if frame_id == "singing":
		return rng.randf_range(SINGING_SPAWN_INTERVAL_MIN, SINGING_SPAWN_INTERVAL_MAX)
	if frame_id == "collab":
		return rng.randf_range(GAMEPLAY_SPAWN_INTERVAL_MIN, GAMEPLAY_SPAWN_INTERVAL_MAX)
	if frame_id != "gameplay":
		return rng.randf_range(DEFAULT_SPAWN_INTERVAL_MIN, DEFAULT_SPAWN_INTERVAL_MAX)
	if String(target.get("active_genre_event")) == "bullet_hell":
		return rng.randf_range(GAMEPLAY_BULLET_HELL_SPAWN_INTERVAL_MIN, GAMEPLAY_BULLET_HELL_SPAWN_INTERVAL_MAX)
	return rng.randf_range(GAMEPLAY_SPAWN_INTERVAL_MIN, GAMEPLAY_SPAWN_INTERVAL_MAX)

static func active_pickup_limit_for_target(target: Node) -> int:
	if String(target.get("current_stream_frame_id")) == "gameplay":
		return GAMEPLAY_AUTO_PICKUP_LIMIT
	if String(target.get("current_stream_frame_id")) == "collab":
		return GAMEPLAY_AUTO_PICKUP_LIMIT
	if String(target.get("current_stream_frame_id")) == "singing":
		return GAMEPLAY_AUTO_PICKUP_LIMIT
	return DEFAULT_AUTO_PICKUP_LIMIT

static func pick_supply_data(data_list: Array, rng: RandomNumberGenerator) -> Dictionary:
	var pool: Array = []
	for item in data_list:
		var data: Dictionary = item as Dictionary
		if String(data.get("type", "")) != "good":
			continue
		if String(data.get("rarity", "normal")) == "god":
			continue
		for i in range(maxi(1, int(data.get("weight", 1)))):
			pool.append(data)
	if pool.is_empty():
		for item in data_list:
			var fallback: Dictionary = item as Dictionary
			if String(fallback.get("type", "")) == "good":
				pool.append(fallback)
	if pool.is_empty():
		return {}
	return pool[rng.randi_range(0, pool.size() - 1)] as Dictionary

static func spawn_supply_pickup_for_target(target: Node, data_list: Array, rng: RandomNumberGenerator, arena: Rect2, effect_walls: Array, pos: Vector2) -> bool:
	if String(target.get("current_stream_frame_id")) != "gameplay":
		return false
	var pickups: Array = target.get("marshmallows") as Array
	if pickups.size() >= GAMEPLAY_DROP_PICKUP_LIMIT:
		return false
	var data: Dictionary = pick_supply_data(data_list, rng)
	return spawn_pickup_for_target(target, data, rng, arena, effect_walls, pos, "gameplay_supply", false)

static func spawn_supply_drop_requests_for_target(target: Node, data_list: Array, requests: Array, rng: RandomNumberGenerator, arena: Rect2, effect_walls: Array) -> Dictionary:
	var spawned := 0
	for item in requests:
		var request: Dictionary = item as Dictionary
		if spawn_supply_pickup_for_target(target, data_list, rng, arena, effect_walls, Vector2(request.get("pos", Vector2.ZERO))):
			spawned += 1
	return {"spawned": spawned}

static func update_auto_spawn_for_target(target: Node, data_list: Array, rng: RandomNumberGenerator, arena: Rect2, effect_walls: Array) -> Dictionary:
	if float(target.get("elapsed")) < float(target.get("next_mallow_time")):
		return {"spawned": false, "chat": ""}
	var pickups: Array = target.get("marshmallows") as Array
	if pickups.size() >= active_pickup_limit_for_target(target):
		return {"spawned": false, "chat": ""}
	if spawn_random_for_target(target, data_list, rng, arena, effect_walls):
		return {"spawned": true, "chat": auto_spawn_chat_for_target(target)}
	return {"spawned": false, "chat": ""}

static func auto_spawn_chat_for_target(target: Node) -> String:
	if String(target.get("current_stream_frame_id")) == "gameplay":
		return "差し入れマシュマロが届いた！"
	if String(target.get("current_stream_frame_id")) == "singing":
		return "ライブ差し入れマロが届いた！"
	return "マシュマロが届いた！"

static func update_auto_spawn_if_enabled_for_target(target: Node, frame: Dictionary, data_list: Array, rng: RandomNumberGenerator, arena: Rect2, effect_walls: Array) -> Dictionary:
	if not StreamFrameSystem.has_event(frame, "marshmallow"):
		return {"chats": []}
	var result: Dictionary = update_auto_spawn_for_target(target, data_list, rng, arena, effect_walls)
	if bool(result["spawned"]):
		return {"chats": [String(result["chat"])]}
	return {"chats": []}

static func spawn_debug_for_target(target: Node, data_list: Array, kind: String, rng: RandomNumberGenerator, arena: Rect2, effect_walls: Array) -> bool:
	var data: Dictionary = pick_debug_data(data_list, kind, rng)
	return spawn_pickup_for_target(target, data, rng, arena, effect_walls)

static func find_position(context: Dictionary) -> Vector2:
	var rng: RandomNumberGenerator = context["rng"] as RandomNumberGenerator
	var arena: Rect2 = context["arena"] as Rect2
	var player_pos: Vector2 = Vector2(context["playerPos"])
	var effect_walls: Array = context["effectWalls"] as Array
	var stream_frame_id: String = String(context["streamFrameId"])
	for i in range(20):
		var angle: float = rng.randf_range(0.0, TAU)
		var dist: float = rng.randf_range(135.0, 430.0)
		var p: Vector2 = player_pos + Vector2(cos(angle), sin(angle)) * dist
		p.x = clampf(p.x, arena.position.x + 70.0, arena.end.x - 70.0)
		p.y = clampf(p.y, arena.position.y + 70.0, arena.end.y - 70.0)
		if p.distance_squared_to(player_pos) > 12100.0 and not point_in_wall(p, effect_walls, stream_frame_id):
			return p
	return arena.get_center() + Vector2(rng.randf_range(-160.0, 160.0), rng.randf_range(-120.0, 120.0))

static func point_in_wall(p: Vector2, effect_walls: Array, stream_frame_id: String = "zatsudan") -> bool:
	var static_walls: Array = DrawDataSystem.static_wall_rects(stream_frame_id)
	for wall in static_walls:
		var static_rect: Rect2 = wall as Rect2
		if static_rect.grow(28).has_point(p):
			return true
	for item in effect_walls:
		var rect: Rect2 = item
		if rect.grow(28).has_point(p):
			return true
	return false

static func bad_rate_for_time(t: float) -> float:
	if t >= 120.0:
		return 0.18
	if t >= 60.0:
		return 0.12
	return 0.05

static func good_effect_rate(passive_rate: float, sweet_tooth_level: int) -> float:
	var rate: float = passive_rate
	if sweet_tooth_level > 0:
		rate *= 1.0 + 0.15 * float(sweet_tooth_level)
	return rate

static func good_amount(amount: int, passive_rate: float, sweet_tooth_level: int) -> int:
	var rate: float = good_effect_rate(passive_rate, sweet_tooth_level)
	return int(ceil(float(amount) * rate))

static func good_duration(duration: float, passive_rate: float, sweet_tooth_level: int) -> float:
	return duration * good_effect_rate(passive_rate, sweet_tooth_level)

static func hp_amount(amount: int) -> int:
	if amount <= 10:
		return amount * DamageSystem.LEGACY_HP_UNIT
	return amount

static func kuso_duration(duration: float, sweet_tooth_level: int, steel_mental_level: int = 0) -> float:
	var resist_level: int = maxi(sweet_tooth_level, steel_mental_level)
	return duration * maxf(0.35, 1.0 - 0.30 * float(resist_level))

static func update_pickups(context: Dictionary) -> Dictionary:
	var updated: Array = []
	var picked: Array = []
	var expired: Array = []
	var player_pos: Vector2 = Vector2(context["playerPos"])
	var pickup_range: float = float(context.get("pickupRange", PICKUP_BASE_RANGE))
	var pickup_range_sq := pickup_range * pickup_range
	var delta: float = float(context.get("delta", 0.0))
	var unread_count: int = int(context.get("unread", 0))
	var marshmallows: Array = context["marshmallows"] as Array
	for item in marshmallows:
		var m: Dictionary = item as Dictionary
		m["time"] = float(m["time"]) - delta
		var pos: Vector2 = m["pos"]
		if pos.distance_squared_to(player_pos) < pickup_range_sq:
			picked.append(m)
			m["time"] = -1.0
		elif float(m["time"]) <= 0.0:
			expired.append(m)
			unread_count += 1
			m["time"] = -1.0
		if float(m["time"]) > 0.0:
			updated.append(m)
	return {
		"marshmallows": updated,
		"picked": picked,
		"expired": expired,
		"unread": unread_count
	}

static func update_pickups_for_target(target: Node, delta: float) -> Dictionary:
	var result: Dictionary = update_pickups({
		"marshmallows": target.get("marshmallows"),
		"delta": delta,
		"playerPos": target.get("player_pos"),
		"pickupRange": pickup_range_for_target(target),
		"unread": target.get("marshmallow_unread")
	})
	target.set("marshmallows", result["marshmallows"] as Array)
	target.set("marshmallow_unread", int(result["unread"]))
	return result

static func update_world_for_target(target: Node, delta: float, arena: Rect2, rng: RandomNumberGenerator) -> Dictionary:
	var result: Dictionary = {
		"messages": [],
		"maroChatLines": [],
		"toasts": [],
		"levelUp": false,
		"levelUps": 0,
		"goodPickupSe": false,
		"godPickupSe": false,
		"kusoPickupSe": false,
		"mentalHealAmount": 0
	}
	var messages: Array = result["messages"] as Array
	var maro_chat_lines: Array = result["maroChatLines"] as Array
	var toasts: Array = result["toasts"] as Array
	var pickup_result: Dictionary = update_pickups_for_target(target, delta)
	var picked: Array = pickup_result["picked"] as Array
	for item in picked:
		var marshmallow: Dictionary = item as Dictionary
		var data: Dictionary = marshmallow["data"] as Dictionary
		if data.is_empty():
			continue
		var feedback: Dictionary = apply_pickup_feedback_for_target(target, data, arena, rng)
		if String(feedback["maroChatKind"]) != "":
			maro_chat_lines.append(ChatSystem.random_marshmallow_line(String(feedback["maroChatKind"]), rng))
		toasts.append(String(feedback["toast"]))
		messages.append(String(feedback["chat"]))
		result["mentalHealAmount"] = int(result.get("mentalHealAmount", 0)) + int(feedback.get("mentalHealAmount", 0))
		var rarity: String = String(data.get("rarity", "normal"))
		if String(data.get("type", "")) == "good" and (rarity == "normal" or rarity == "good"):
			result["goodPickupSe"] = true
		if String(data.get("type", "")) == "good" and rarity == "god":
			result["godPickupSe"] = true
		if String(data.get("type", "")) == "bad":
			result["kusoPickupSe"] = true
		if bool(feedback["levelUp"]):
			result["levelUp"] = true
			result["levelUps"] = int(result["levelUps"]) + int(feedback.get("levelUps", 1))
	var expired: Array = pickup_result["expired"] as Array
	var expired_feedback: Dictionary = expire_pickups_for_target(target, expired, arena, rng)
	for message in (expired_feedback["messages"] as Array):
		messages.append(String(message))
	for kind in (expired_feedback["maroChatKinds"] as Array):
		maro_chat_lines.append(ChatSystem.random_marshmallow_line(String(kind), rng))
	return result

static func expire_pickups_for_target(target: Node, expired: Array, arena: Rect2, rng: RandomNumberGenerator) -> Dictionary:
	var messages: Array = []
	var maro_chat_kinds: Array = []
	for item in expired:
		var marshmallow: Dictionary = item as Dictionary
		EnemySystem.spawn_enemy_for_target(target, "unread_maro", arena, rng, Vector2(marshmallow["pos"]))
		messages.append("未読マロが荒らし化！")
		maro_chat_kinds.append("unread")
	return {
		"messages": messages,
		"maroChatKinds": maro_chat_kinds
	}

static func pickup_range_for_target(target: Node) -> float:
	var magnet_range: float = float(target.get("maro_magnet_range"))
	var radar_range: float = float(target.get("comment_radar_range_bonus"))
	var passive_rate: float = float(target.get("passive_maro_pickup_rate"))
	var pickup_base := PICKUP_BASE_RANGE
	var snapshot = target.get("permanent_upgrade_snapshot")
	if snapshot != null:
		pickup_base = PowerUpEffectProviderScript.normal_pickup_radius(pickup_base, snapshot)
	var range_value := (pickup_base + magnet_range + radar_range) * passive_rate
	if target.has_method("_song_live_heat_pickup_range_multiplier"):
		range_value *= maxf(0.1, float(target.call("_song_live_heat_pickup_range_multiplier")))
	return range_value

static func update_effect_timers(context: Dictionary) -> Dictionary:
	var delta: float = float(context.get("delta", 0.0))
	return {
		"toastTimer": maxf(0.0, float(context.get("toastTimer", 0.0)) - delta),
		"kusoChatTimer": maxf(0.0, float(context.get("kusoChatTimer", 0.0)) - delta),
		"attackJitterTimer": maxf(0.0, float(context.get("attackJitterTimer", 0.0)) - delta),
		"moveSlowTimer": maxf(0.0, float(context.get("moveSlowTimer", 0.0)) - delta),
		"spawnRateTimer": maxf(0.0, float(context.get("spawnRateTimer", 0.0)) - delta),
		"supportAttackTimer": maxf(0.0, float(context.get("supportAttackTimer", 0.0)) - delta)
	}

static func update_effect_timers_for_target(target: Node, delta: float) -> void:
	var timers: Dictionary = update_effect_timers({
		"delta": delta,
		"toastTimer": target.get("toast_timer"),
		"kusoChatTimer": target.get("kuso_chat_timer"),
		"attackJitterTimer": target.get("attack_jitter_timer"),
		"moveSlowTimer": target.get("move_slow_timer"),
		"spawnRateTimer": target.get("spawn_rate_timer"),
		"supportAttackTimer": target.get("support_attack_timer")
	})
	target.set("toast_timer", float(timers["toastTimer"]))
	target.set("kuso_chat_timer", float(timers["kusoChatTimer"]))
	target.set("attack_jitter_timer", float(timers["attackJitterTimer"]))
	target.set("move_slow_timer", float(timers["moveSlowTimer"]))
	target.set("spawn_rate_timer", float(timers["spawnRateTimer"]))
	target.set("support_attack_timer", float(timers["supportAttackTimer"]))

static func pickup_counts(data: Dictionary) -> Dictionary:
	var kind: String = String(data["type"])
	var rarity: String = String(data.get("rarity", "normal"))
	return {
		"answeredAdd": 1,
		"goodAdd": 0 if kind == "bad" else 1,
		"kusoAdd": 1 if kind == "bad" else 0,
		"godAdd": 1 if kind != "bad" and rarity == "god" else 0,
		"chatKind": "bad" if kind == "bad" else ("god" if rarity == "god" else "good"),
		"isBad": kind == "bad"
	}

static func apply_pickup(data: Dictionary, context: Dictionary) -> Dictionary:
	var result: Dictionary = context.duplicate()
	result["blocked"] = false
	result["spawnTrolls"] = 0
	result["effectValue"] = 0
	result["mentalHealAmount"] = 0
	var counts: Dictionary = pickup_counts(data)
	result["answered"] = int(result.get("answered", 0)) + int(counts["answeredAdd"])
	result["lastType"] = String(data["displayName"])
	result["lastWasKuso"] = bool(counts["isBad"])
	if bool(counts["isBad"]):
		if int(result.get("blockFunctionStock", 0)) > 0:
			result["blockFunctionStock"] = int(result.get("blockFunctionStock", 0)) - 1
			result["lastWasKuso"] = false
			result["blocked"] = true
			result["chatKind"] = "blocked"
			return result
		result["kuso"] = int(result.get("kuso", 0)) + int(counts["kusoAdd"])
	else:
		result["good"] = int(result.get("good", 0)) + int(counts["goodAdd"])
		result["god"] = int(result.get("god", 0)) + int(counts["godAdd"])
	result["chatKind"] = String(counts["chatKind"])
	var params: Dictionary = data["params"] as Dictionary
	var effect: String = String(data["effectType"])
	if effect == "heal":
		var before_hp: int = int(result.get("playerHp", 100))
		var heal_amount: int = good_amount(hp_amount(int(params["amount"])), float(result.get("passiveGoodRate", 1.0)), int(result.get("sweetToothLevel", 0)))
		var snapshot = result.get("permanentUpgradeSnapshot")
		if snapshot != null:
			heal_amount = PowerUpEffectProviderScript.scaled_heal_amount(heal_amount, snapshot, "marshmallow_heal")
		result["playerHp"] = mini(int(result.get("playerMaxHp", 100)), int(result.get("playerHp", 100)) + heal_amount)
		result["effectValue"] = int(result["playerHp"]) - before_hp
		result["mentalHealAmount"] = int(result["effectValue"])
	elif effect == "gift_hype":
		var before_hype: int = int(result.get("giftHype", 0))
		result["giftHype"] = clampi(int(result.get("giftHype", 0)) + good_amount(int(params["amount"]), float(result.get("passiveGoodRate", 1.0)), int(result.get("sweetToothLevel", 0))), 0, 100)
		result["maxGiftHype"] = maxi(int(result.get("maxGiftHype", 0)), int(result["giftHype"]))
		result["effectValue"] = int(result["giftHype"]) - before_hype
	elif effect == "exp":
		result["expAdd"] = good_amount(int(params["amount"]), float(result.get("passiveGoodRate", 1.0)), int(result.get("sweetToothLevel", 0)))
		result["effectValue"] = int(result["expAdd"])
	elif effect == "score":
		var score_add: int = good_amount(int(params["amount"]), float(result.get("passiveGoodRate", 1.0)), int(result.get("sweetToothLevel", 0)))
		result["score"] = int(result.get("score", 0)) + score_add
		result["effectValue"] = score_add
	elif effect == "attack_rate_buff":
		var buff_duration: float = good_duration(float(params["duration"]), float(result.get("passiveGoodRate", 1.0)), int(result.get("sweetToothLevel", 0)))
		result["supportAttackTimer"] = maxf(float(result.get("supportAttackTimer", 0.0)), buff_duration)
		result["effectValue"] = buff_duration
	elif effect == "invincible_heal":
		var before_invincible_hp: int = int(result.get("playerHp", 100))
		var invincible_heal_amount: int = good_amount(hp_amount(int(params["amount"])), float(result.get("passiveGoodRate", 1.0)), int(result.get("sweetToothLevel", 0)))
		var snapshot = result.get("permanentUpgradeSnapshot")
		if snapshot != null:
			invincible_heal_amount = PowerUpEffectProviderScript.scaled_heal_amount(invincible_heal_amount, snapshot, "marshmallow_heal")
		result["playerHp"] = mini(int(result.get("playerMaxHp", 100)), int(result.get("playerHp", 100)) + invincible_heal_amount)
		result["invincible"] = maxf(float(result.get("invincible", 0.0)), float(params["invincible"]))
		result["effectValue"] = int(result["playerHp"]) - before_invincible_hp
		result["mentalHealAmount"] = int(result["effectValue"])
	elif effect == "add_heart_pending":
		var before_heart_hype: int = int(result.get("giftHype", 0))
		result["heartPending"] = true
		result["giftHype"] = clampi(int(result.get("giftHype", 0)) + 30, 0, 100)
		result["maxGiftHype"] = maxi(int(result.get("maxGiftHype", 0)), int(result["giftHype"]))
		result["effectValue"] = int(result["giftHype"]) - before_heart_hype
	elif effect == "hype_down":
		var before_bad_hype: int = int(result.get("giftHype", 0))
		result["giftHype"] = maxi(0, int(result.get("giftHype", 0)) - int(params["amount"]))
		result["effectValue"] = before_bad_hype - int(result["giftHype"])
	elif effect == "chat_storm":
		result["kusoChatTimer"] = kuso_duration(float(params["duration"]), int(result.get("sweetToothLevel", 0)), int(result.get("steelMentalLevel", 0)))
		result["effectValue"] = float(result["kusoChatTimer"])
	elif effect == "attack_jitter":
		result["attackJitterTimer"] = kuso_duration(float(params["duration"]), int(result.get("sweetToothLevel", 0)), int(result.get("steelMentalLevel", 0)))
		result["effectValue"] = float(result["attackJitterTimer"])
	elif effect == "spawn_trolls":
		result["spawnTrolls"] = int(params["count"])
		result["effectValue"] = int(result["spawnTrolls"])
	elif effect == "move_slow":
		result["moveSlowTimer"] = kuso_duration(float(params["duration"]), int(result.get("sweetToothLevel", 0)), int(result.get("steelMentalLevel", 0)))
		result["effectValue"] = float(result["moveSlowTimer"])
	elif effect == "spawn_rate":
		result["spawnRateTimer"] = kuso_duration(float(params["duration"]), int(result.get("sweetToothLevel", 0)), int(result.get("steelMentalLevel", 0)))
		result["effectValue"] = float(result["spawnRateTimer"])
	return result

static func build_effect_context_from_target(target: Node) -> Dictionary:
	return {
		"answered": target.get("marshmallow_answered"),
		"good": target.get("marshmallow_good"),
		"god": target.get("marshmallow_god"),
		"kuso": target.get("marshmallow_kuso"),
		"lastType": target.get("last_maro_type"),
		"lastWasKuso": target.get("last_maro_was_kuso"),
		"blockFunctionStock": target.get("block_function_stock"),
		"playerHp": target.get("player_hp"),
		"playerMaxHp": target.get("player_max_hp"),
		"giftHype": target.get("gift_hype"),
		"maxGiftHype": target.get("max_gift_hype"),
		"score": target.get("score"),
		"supportAttackTimer": target.get("support_attack_timer"),
		"invincible": target.get("invincible"),
		"heartPending": target.get("heart_pending"),
		"kusoChatTimer": target.get("kuso_chat_timer"),
		"attackJitterTimer": target.get("attack_jitter_timer"),
		"moveSlowTimer": target.get("move_slow_timer"),
		"spawnRateTimer": target.get("spawn_rate_timer"),
		"passiveGoodRate": target.get("passive_maro_good_rate"),
		"sweetToothLevel": target.get("sweet_tooth_level"),
		"steelMentalLevel": target.get("steel_mental_level"),
		"permanentUpgradeSnapshot": target.get("permanent_upgrade_snapshot")
	}

static func apply_effect_result_to_target(target: Node, result: Dictionary) -> void:
	target.set("marshmallow_answered", int(result["answered"]))
	target.set("marshmallow_good", int(result["good"]))
	target.set("marshmallow_god", int(result["god"]))
	target.set("marshmallow_kuso", int(result["kuso"]))
	target.set("last_maro_type", String(result["lastType"]))
	target.set("last_maro_was_kuso", bool(result["lastWasKuso"]))
	target.set("block_function_stock", int(result["blockFunctionStock"]))
	target.set("player_hp", int(result["playerHp"]))
	target.set("gift_hype", int(result["giftHype"]))
	target.set("max_gift_hype", int(result["maxGiftHype"]))
	target.set("score", int(result["score"]))
	target.set("support_attack_timer", float(result["supportAttackTimer"]))
	target.set("invincible", float(result["invincible"]))
	target.set("heart_pending", bool(result["heartPending"]))
	target.set("kuso_chat_timer", float(result["kusoChatTimer"]))
	target.set("attack_jitter_timer", float(result["attackJitterTimer"]))
	target.set("move_slow_timer", float(result["moveSlowTimer"]))
	target.set("spawn_rate_timer", float(result["spawnRateTimer"]))

static func apply_pickup_to_target(target: Node, data: Dictionary) -> Dictionary:
	var result: Dictionary = apply_pickup(data, build_effect_context_from_target(target))
	apply_effect_result_to_target(target, result)
	return result

static func apply_pickup_feedback_for_target(target: Node, data: Dictionary, arena: Rect2, rng: RandomNumberGenerator) -> Dictionary:
	var result: Dictionary = apply_pickup_to_target(target, data)
	var feedback: Dictionary = pickup_feedback(data, result)
	for i in range(int(feedback["spawnTrolls"])):
		EnemySystem.spawn_enemy_for_target(target, "troll", arena, rng)
	var level_ups := 0
	if int(feedback["expAdd"]) > 0:
		level_ups = ExpSystem.add_exp_to_target(target, int(feedback["expAdd"]))
	feedback["levelUps"] = level_ups
	feedback["levelUp"] = level_ups > 0
	return feedback

static func pickup_feedback(data: Dictionary, result: Dictionary) -> Dictionary:
	if bool(result.get("blocked", false)):
		return {
			"blocked": true,
			"toast": "ブロック機能！クソマロを無効化",
			"chat": "ブロック機能たすかる",
			"maroChatKind": "",
			"spawnTrolls": 0,
			"expAdd": 0,
			"mentalHealAmount": 0
		}
	return {
		"blocked": false,
		"toast": pickup_toast_text(data, result),
		"chat": String(data["messageText"]),
		"maroChatKind": String(result.get("chatKind", "good")),
		"spawnTrolls": int(result.get("spawnTrolls", 0)),
		"expAdd": int(result.get("expAdd", 0)),
		"mentalHealAmount": int(result.get("mentalHealAmount", 0))
	}

static func pickup_toast_text(data: Dictionary, result: Dictionary) -> String:
	var effect: String = String(data.get("effectType", ""))
	var rarity: String = String(data.get("rarity", "normal"))
	var prefix: String = "マシュマロ読了！"
	if String(data.get("type", "")) == "bad":
		prefix = "クソマロだった！"
	elif rarity == "god":
		prefix = "神マロ！"
	elif rarity == "good":
		prefix = "良マロ！"
	var value: int = int(round(float(result.get("effectValue", 0))))
	if effect == "heal" or effect == "invincible_heal":
		return "%s メンタル +%d" % [prefix, value]
	if effect == "gift_hype":
		return "%s ギフト期待度 +%d" % [prefix, value]
	if effect == "exp":
		return "%s EXP +%d" % [prefix, value]
	if effect == "score":
		return "%s 視聴者数 +%d人" % [prefix, value]
	if effect == "hype_down":
		return "%s ギフト期待度 -%d" % [prefix, value]
	return String(data.get("toastText", ""))
