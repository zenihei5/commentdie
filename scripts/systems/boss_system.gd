class_name BossSystem
extends RefCounted

const BOSS_SUPER_LONG_COMMENT := "boss_super_long_comment"
const BOSS_KUSO_MARO_KING := "boss_kuso_maro_king"
const BOSS_KIND := BOSS_SUPER_LONG_COMMENT
const WARNING_DURATION := 3.0
const DEFAULT_MAX_SUMMONS := 1
const ATTACK_KUSO_MARO_BARRAGE := "kuso_maro_barrage"
const ATTACK_STICKY_MARO_FLOOR := "sticky_maro_floor"
const ATTACK_SUMMON_UNREAD_MARO := "summon_unread_maro"
const BOSS_ATTACK_PRIORITY := [ATTACK_KUSO_MARO_BARRAGE, ATTACK_STICKY_MARO_FLOOR, ATTACK_SUMMON_UNREAD_MARO]

static func default_boss_data() -> Dictionary:
	return {
		"id": BOSS_KIND,
		"displayName": "超長文ニキ",
		"description": "長文ニキの巨大版。大きなコメント塊でプレイヤーを追い詰める。",
		"hp": 400.0,
		"speed": 58.0,
		"radius": 78.0,
		"contactDamage": 1,
		"expValue": 20,
		"viewerValue": 3000,
		"giftHypeReward": 20,
		"lifetime": 45.0
	}

static func reset_for_target(target: Node, reset_count: bool = true) -> void:
	target.set("boss_requested", false)
	target.set("boss_warning_timer", 0.0)
	target.set("boss_warning_duration", WARNING_DURATION)
	target.set("boss_pending_id", "")
	target.set("boss_warning_text", "大荒れイベント発生！")
	target.set("boss_active", false)
	target.set("active_boss_uid", -1)
	target.set("boss_heart_variant", false)
	target.set("boss_hp_rate", 1.0)
	target.set("boss_attack_interval_rate", 1.0)
	target.set("boss_reward_rate", 1.0)
	if reset_count:
		target.set("boss_summon_count", 0)
	target.set("boss_summoned", false)
	target.set("boss_defeated", false)
	target.set("boss_last_name", "")
	target.set("boss_last_result", "")
	target.set("boss_reward_viewers", 0)
	if target.get("boss_slow_fields") != null:
		(target.get("boss_slow_fields") as Array).clear()

static func comment_available(context: Dictionary, comment: Dictionary, comment_time: float) -> bool:
	if String(comment.get("effectType", "")) != "summon_boss" and String(comment.get("id", "")) != "summon_boss":
		return true
	if comment_time < float(comment.get("minTime", 60.0)):
		return false
	if int(context.get("expLevel", 1)) < int(comment.get("requiredPlayerLevel", 3)):
		return false
	if int(context.get("bossSummonCount", 0)) >= int(comment.get("maxSelectCountPerRun", DEFAULT_MAX_SUMMONS)):
		return false
	if bool(context.get("bossRequested", false)) or bool(context.get("bossActive", false)):
		return false
	return not bool(context.get("bossDisabled", false))

static func request_summon_for_target(target: Node, view: Dictionary, has_heart: bool) -> Dictionary:
	if bool(target.get("boss_requested")) or bool(target.get("boss_active")):
		return {"chats": ["ボスコメントはすでに接近中！"], "toasts": []}
	var boss_id: String = boss_id_for_target(target)
	var data: Dictionary = boss_data_for_target(target, boss_id)
	var boss_name: String = String(data.get("displayName", "超長文ニキ"))
	var warning_text: String = warning_text_for_boss(data, boss_id)
	target.set("boss_requested", true)
	target.set("boss_warning_timer", WARNING_DURATION)
	target.set("boss_warning_duration", WARNING_DURATION)
	target.set("boss_pending_id", boss_id)
	target.set("boss_warning_text", warning_text)
	target.set("boss_heart_variant", has_heart)
	if boss_id == BOSS_KUSO_MARO_KING:
		target.set("current_death_text", death_text_for_boss(boss_id, has_heart))
	var params: Dictionary = view.get("params", {}) as Dictionary
	var variant: Dictionary = data.get("heartVariant", {}) as Dictionary
	var hp_rate: float = float(variant.get("hpRate", 1.0)) if has_heart else 1.0
	var interval_rate: float = float(variant.get("attackIntervalRate", 1.0)) if has_heart else 1.0
	var reward_rate: float = float(variant.get("rewardRate", 1.0)) if has_heart else 1.0
	target.set("boss_hp_rate", float(params.get("bossHpRate", hp_rate)))
	target.set("boss_attack_interval_rate", float(params.get("bossAttackIntervalRate", interval_rate)))
	target.set("boss_reward_rate", float(params.get("bossRewardRate", reward_rate)))
	return {
		"chats": request_chats_for_boss(boss_id, warning_text),
		"toasts": ["WARNING! %s接近中！" % boss_name]
	}

static func update_for_target(target: Node, delta: float, arena: Rect2, rng: RandomNumberGenerator) -> Dictionary:
	var chats: Array[String] = []
	var toasts: Array[String] = []
	update_slow_fields_for_target(target, delta)
	if bool(target.get("boss_requested")):
		var timer: float = maxf(0.0, float(target.get("boss_warning_timer")) - delta)
		target.set("boss_warning_timer", timer)
		if timer <= 0.0:
			var spawn_result: Dictionary = spawn_for_target(target, arena, rng)
			for item in (spawn_result.get("chats", []) as Array):
				chats.append(String(item))
			for item in (spawn_result.get("toasts", []) as Array):
				toasts.append(String(item))
	if bool(target.get("boss_active")):
		var boss: Dictionary = active_boss_for_target(target)
		if boss.is_empty():
			target.set("boss_active", false)
			target.set("active_boss_uid", -1)
		else:
			var life: float = float(boss.get("bossLifetimeElapsed", 0.0)) + delta
			boss["bossLifetimeElapsed"] = life
			if life >= float(boss.get("bossLifetime", 45.0)):
				var retreat_result: Dictionary = retreat_for_target(target)
				for item in (retreat_result.get("chats", []) as Array):
					chats.append(String(item))
				for item in (retreat_result.get("toasts", []) as Array):
					toasts.append(String(item))
			else:
				update_boss_attacks_for_target(target, boss, delta, arena, rng, chats, toasts)
	return {"chats": chats, "toasts": toasts}

static func spawn_for_target(target: Node, arena: Rect2, rng: RandomNumberGenerator) -> Dictionary:
	if bool(target.get("boss_active")):
		target.set("boss_requested", false)
		return {"chats": [], "toasts": []}
	var boss_id: String = String(target.get("boss_pending_id"))
	if boss_id == "":
		boss_id = boss_id_for_target(target)
	var data: Dictionary = boss_data_for_target(target, boss_id)
	var hp_rate: float = maxf(0.1, float(target.get("boss_hp_rate")))
	var reward_rate: float = maxf(0.1, float(target.get("boss_reward_rate")))
	var base_hp: float = float(data.get("hp", 400.0))
	var max_hp: float = base_hp * hp_rate
	var next_uid: int = int(target.get("next_enemy_uid"))
	var boss_name: String = String(data.get("displayName", "超長文ニキ"))
	if bool(target.get("boss_heart_variant")) and boss_id != BOSS_KUSO_MARO_KING:
		boss_name += "♡"
	var boss := {
		"uid": next_uid,
		"kind": boss_id,
		"bossId": String(data.get("id", boss_id)),
		"isBoss": true,
		"displayName": boss_name,
		"pos": spawn_position_for_target(target, arena, rng, float(data.get("radius", 78.0))),
		"hp": max_hp,
		"max_hp": max_hp,
		"speed": boss_speed(data),
		"radius": float(data.get("radius", 78.0)),
		"score": int(data.get("viewerValue", 3000)),
		"exp": int(data.get("expValue", 20)),
		"expValue": int(data.get("expValue", 20)),
		"behavior": "tank",
		"shoot": 1.0,
		"speechText": speech_text_for_boss(boss_id),
		"bossLifetime": float(data.get("lifetime", 45.0)),
		"bossLifetimeElapsed": 0.0,
		"bossHeartVariant": bool(target.get("boss_heart_variant")),
		"bossAttackTimers": initial_attack_timers(data, float(target.get("boss_attack_interval_rate"))),
		"bossAttackCooldown": 0.0,
		"bossAttackIntervalRate": float(target.get("boss_attack_interval_rate")),
		"bossRewardRate": reward_rate,
		"bossViewerReward": int(data.get("viewerValue", 3000)),
		"bossGiftHypeReward": int(data.get("giftHypeReward", 20))
	}
	var enemies: Array = target.get("enemies") as Array
	enemies.append(boss)
	target.set("enemies", enemies)
	target.set("next_enemy_uid", next_uid + 1)
	target.set("boss_requested", false)
	target.set("boss_warning_timer", 0.0)
	target.set("boss_active", true)
	target.set("active_boss_uid", next_uid)
	target.set("boss_summon_count", int(target.get("boss_summon_count")) + 1)
	target.set("boss_summoned", true)
	target.set("boss_last_name", boss_name)
	target.set("boss_last_result", "active")
	return {
		"chats": spawn_chats_for_boss(boss_id, boss_name),
		"toasts": ["ボス出現：%s" % boss_name]
	}

static func retreat_for_target(target: Node) -> Dictionary:
	var boss_name: String = String(target.get("boss_last_name"))
	if boss_name == "":
		boss_name = "超長文ニキ"
	var active_uid: int = int(target.get("active_boss_uid"))
	var remaining: Array = []
	for item in (target.get("enemies") as Array):
		var enemy: Dictionary = item as Dictionary
		if bool(enemy.get("isBoss", false)) and int(enemy.get("uid", -1)) == active_uid:
			continue
		remaining.append(enemy)
	target.set("enemies", remaining)
	target.set("boss_requested", false)
	target.set("boss_warning_timer", 0.0)
	target.set("boss_active", false)
	target.set("active_boss_uid", -1)
	target.set("boss_last_result", "retreated")
	if target.get("boss_slow_fields") != null:
		(target.get("boss_slow_fields") as Array).clear()
	return {
		"chats": [retreat_chat_for_boss(boss_name)],
		"toasts": ["ボス撤退：%s" % boss_name]
	}

static func apply_defeat_for_target(target: Node, boss: Dictionary) -> Dictionary:
	if int(target.get("active_boss_uid")) != int(boss.get("uid", -2)):
		return {"chat": ""}
	var boss_name: String = String(boss.get("displayName", target.get("boss_last_name")))
	if boss_name == "":
		boss_name = "超長文ニキ"
	var reward_rate: float = maxf(0.1, float(boss.get("bossRewardRate", 1.0)))
	var viewer_reward: int = int(round(float(boss.get("bossViewerReward", 3000)) * reward_rate))
	var exp_reward: int = maxi(1, int(round(float(boss.get("expValue", 20)) * reward_rate)))
	var hype_reward: int = maxi(1, int(round(float(boss.get("bossGiftHypeReward", 20)) * reward_rate)))
	(target.get("exp_orbs") as Array).append({
		"pos": Vector2(boss["pos"]),
		"value": exp_reward,
		"visualType": "gold_rainbow",
		"life": 24.0
	})
	target.set("score", int(target.get("score")) + viewer_reward)
	var gift_hype: int = clampi(int(target.get("gift_hype")) + hype_reward, 0, 100)
	target.set("gift_hype", gift_hype)
	target.set("max_gift_hype", maxi(int(target.get("max_gift_hype")), gift_hype))
	target.set("pending_gift_choices", int(target.get("pending_gift_choices")) + 1)
	target.set("boss_active", false)
	target.set("boss_requested", false)
	target.set("active_boss_uid", -1)
	target.set("boss_defeated", true)
	target.set("boss_last_name", boss_name)
	target.set("boss_last_result", "defeated")
	target.set("boss_reward_viewers", int(target.get("boss_reward_viewers")) + viewer_reward)
	if target.get("boss_slow_fields") != null:
		(target.get("boss_slow_fields") as Array).clear()
	return {
		"chat": "%s撃破！ ギフト箱が届いた！ 同時視聴者数 +%d人" % [boss_name, viewer_reward]
	}

static func active_boss_for_target(target: Node) -> Dictionary:
	var active_uid: int = int(target.get("active_boss_uid"))
	for item in (target.get("enemies") as Array):
		var enemy: Dictionary = item as Dictionary
		if bool(enemy.get("isBoss", false)) and int(enemy.get("uid", -1)) == active_uid:
			return enemy
	return {}

static func boss_data_for_target(target: Node, boss_id: String) -> Dictionary:
	var list_value: Variant = target.get("bosses")
	if list_value is Array:
		for item in (list_value as Array):
			var data: Dictionary = item as Dictionary
			if String(data.get("id", "")) == boss_id:
				return data
	return default_boss_data()

static func boss_id_for_target(target: Node) -> String:
	if String(target.get("current_stream_frame_id")) == "zatsudan":
		return BOSS_KUSO_MARO_KING
	return BOSS_SUPER_LONG_COMMENT

static func boss_speed(data: Dictionary) -> float:
	var value: float = float(data.get("speed", 58.0))
	if value <= 5.0:
		return value * 40.0
	return value

static func warning_text_for_boss(data: Dictionary, boss_id: String) -> String:
	if data.has("warningText"):
		return String(data["warningText"])
	if boss_id == BOSS_KUSO_MARO_KING:
		return "クソマロキング出現！"
	return "大荒れイベント発生！"

static func request_chats_for_boss(boss_id: String, warning_text: String) -> Array[String]:
	if boss_id == BOSS_KUSO_MARO_KING:
		return [
			"WARNING! %s" % warning_text,
			"コメント欄：クソマロ王きた",
			"コメント欄：マロ欄終わった"
		]
	return [
		"WARNING! %s" % warning_text,
		"コメント欄：ボスきたｗ"
	]

static func spawn_chats_for_boss(boss_id: String, boss_name: String) -> Array[String]:
	if boss_id == BOSS_KUSO_MARO_KING:
		return [
			"%sが出現！" % boss_name,
			"コメント欄：読むな読むな",
			"コメント欄：これは荒れる"
		]
	return ["%sが出現！" % boss_name, "コメント欄：逃げるな"]

static func speech_text_for_boss(boss_id: String) -> String:
	if boss_id == BOSS_KUSO_MARO_KING:
		return "未読にするな"
	return "戦え戦え"

static func retreat_chat_for_boss(boss_name: String) -> String:
	if boss_name.begins_with("クソマロキング"):
		return "クソマロキングは去っていった……"
	return "大荒れコメントは去っていった……"

static func death_text_for_boss(boss_id: String, has_heart: bool) -> String:
	if boss_id == BOSS_KUSO_MARO_KING:
		if has_heart:
			return "「ボスと戦え♡」でもクソマロキングの圧が強かった"
		return "「ボスと戦え」でクソマロキングに押し切られた"
	return ""

static func initial_attack_timers(data: Dictionary, interval_rate: float) -> Dictionary:
	var timers: Dictionary = {}
	for item in (data.get("attacks", []) as Array):
		var attack_id: String = String(item)
		if attack_id == ATTACK_KUSO_MARO_BARRAGE:
			timers[attack_id] = 2.0 * interval_rate
		elif attack_id == ATTACK_STICKY_MARO_FLOOR:
			timers[attack_id] = 4.0 * interval_rate
		elif attack_id == ATTACK_SUMMON_UNREAD_MARO:
			timers[attack_id] = 6.0 * interval_rate
	return timers

static func update_boss_attacks_for_target(target: Node, boss: Dictionary, delta: float, arena: Rect2, rng: RandomNumberGenerator, chats: Array[String], _toasts: Array[String]) -> void:
	if String(boss.get("bossId", "")) != BOSS_KUSO_MARO_KING:
		return
	var data: Dictionary = boss_data_for_target(target, String(boss.get("bossId", "")))
	var timers: Dictionary = boss.get("bossAttackTimers", {}) as Dictionary
	for key in timers.keys():
		timers[key] = float(timers[key]) - delta
	var cooldown: float = maxf(0.0, float(boss.get("bossAttackCooldown", 0.0)) - delta)
	if cooldown <= 0.0:
		for attack_id in BOSS_ATTACK_PRIORITY:
			if timers.has(attack_id) and float(timers[attack_id]) <= 0.0:
				perform_boss_attack_for_target(target, boss, data, String(attack_id), arena, rng, chats)
				timers[attack_id] = attack_interval(data, String(attack_id)) * maxf(0.1, float(boss.get("bossAttackIntervalRate", 1.0)))
				cooldown = 0.9
				break
	boss["bossAttackTimers"] = timers
	boss["bossAttackCooldown"] = cooldown

static func perform_boss_attack_for_target(target: Node, boss: Dictionary, data: Dictionary, attack_id: String, arena: Rect2, rng: RandomNumberGenerator, chats: Array[String]) -> void:
	if attack_id == ATTACK_KUSO_MARO_BARRAGE:
		spawn_kuso_maro_barrage_for_target(target, boss, data, rng)
		chats.append("クソマロキング：クソマロばらまき！")
	elif attack_id == ATTACK_STICKY_MARO_FLOOR:
		spawn_sticky_maro_floor_for_target(target, boss, data, arena, rng)
		chats.append("床がベタベタになった……")
	elif attack_id == ATTACK_SUMMON_UNREAD_MARO:
		spawn_unread_maro_adds_for_target(target, boss, data, arena, rng)
		chats.append("未読マロが増えた！")

static func attack_data(data: Dictionary, attack_id: String) -> Dictionary:
	var attack_map: Dictionary = data.get("attackData", {}) as Dictionary
	if attack_map.has(attack_id) and attack_map[attack_id] is Dictionary:
		return attack_map[attack_id] as Dictionary
	return {}

static func attack_interval(data: Dictionary, attack_id: String) -> float:
	var attack: Dictionary = attack_data(data, attack_id)
	if attack.has("interval"):
		return float(attack["interval"])
	if attack_id == ATTACK_KUSO_MARO_BARRAGE:
		return 6.0
	if attack_id == ATTACK_STICKY_MARO_FLOOR:
		return 10.0
	if attack_id == ATTACK_SUMMON_UNREAD_MARO:
		return 12.0
	return 8.0

static func heart_variant_value(boss: Dictionary, data: Dictionary, key: String, fallback: Variant) -> Variant:
	if not bool(boss.get("bossHeartVariant", false)):
		return fallback
	var variant: Dictionary = data.get("heartVariant", {}) as Dictionary
	return variant.get(key, fallback)

static func spawn_kuso_maro_barrage_for_target(target: Node, boss: Dictionary, data: Dictionary, rng: RandomNumberGenerator) -> void:
	var attack: Dictionary = attack_data(data, ATTACK_KUSO_MARO_BARRAGE)
	var bullet_count: int = int(heart_variant_value(boss, data, "kusoMaroBulletCount", int(attack.get("bulletCount", 6))))
	var speed: float = float(attack.get("bulletSpeed", 230.0))
	if speed <= 10.0:
		speed *= 78.0
	var lifetime: float = float(attack.get("bulletLifetime", 4.0))
	var damage: int = int(attack.get("damage", 1))
	var boss_pos: Vector2 = Vector2(boss.get("pos", Vector2.ZERO))
	var radius: float = float(boss.get("radius", 78.0))
	var bullets: Array = target.get("enemy_bullets") as Array
	var start_angle: float = rng.randf_range(0.0, TAU)
	for i in range(maxi(1, bullet_count)):
		var angle: float = start_angle + TAU * float(i) / float(maxi(1, bullet_count))
		var dir: Vector2 = Vector2(cos(angle), sin(angle))
		bullets.append({
			"pos": boss_pos + dir * radius * 0.42,
			"vel": dir * speed,
			"life": lifetime,
			"hitRadius": 19.0,
			"source": "クソマロ弾",
			"damage": damage,
			"visualKind": "kuso_maro"
		})
	target.set("enemy_bullets", bullets)

static func spawn_unread_maro_adds_for_target(target: Node, boss: Dictionary, data: Dictionary, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var attack: Dictionary = attack_data(data, ATTACK_SUMMON_UNREAD_MARO)
	var summon_count: int = int(heart_variant_value(boss, data, "unreadMaroSummonCount", int(attack.get("summonCount", 2))))
	var boss_pos: Vector2 = Vector2(boss.get("pos", Vector2.ZERO))
	var base_radius: float = float(boss.get("radius", 78.0))
	for i in range(maxi(1, summon_count)):
		var angle: float = rng.randf_range(0.0, TAU) + TAU * float(i) / float(maxi(1, summon_count))
		var distance: float = rng.randf_range(base_radius + 34.0, base_radius + 110.0)
		var pos: Vector2 = boss_pos + Vector2(cos(angle), sin(angle)) * distance
		pos.x = clampf(pos.x, arena.position.x + 32.0, arena.end.x - 32.0)
		pos.y = clampf(pos.y, arena.position.y + 32.0, arena.end.y - 32.0)
		spawn_unread_maro_for_target(target, pos, rng)

static func spawn_unread_maro_for_target(target: Node, pos: Vector2, rng: RandomNumberGenerator) -> void:
	var enemies: Array = target.get("enemies") as Array
	var next_uid: int = int(target.get("next_enemy_uid"))
	var speech_text: String = "読んで" if rng.randf() < 0.5 else "未読です"
	enemies.append({
		"uid": next_uid,
		"kind": "unread_maro",
		"pos": pos,
		"hp": 8.0,
		"max_hp": 8.0,
		"speed": 130.0,
		"radius": 19.0,
		"score": 20,
		"exp": 1,
		"expValue": 1,
		"behavior": "chase",
		"shoot": 1.0,
		"speechText": speech_text
	})
	target.set("enemies", enemies)
	target.set("next_enemy_uid", next_uid + 1)

static func spawn_sticky_maro_floor_for_target(target: Node, boss: Dictionary, data: Dictionary, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var attack: Dictionary = attack_data(data, ATTACK_STICKY_MARO_FLOOR)
	var field_count: int = int(attack.get("fieldCount", 2))
	var duration: float = float(heart_variant_value(boss, data, "stickyFloorDuration", float(attack.get("duration", 6.0))))
	var slow_rate: float = clampf(float(attack.get("slowRate", 0.4)), 0.0, 0.85)
	var radius: float = float(attack.get("radius", 1.6))
	if radius <= 10.0:
		radius *= 60.0
	var fields: Array = target.get("boss_slow_fields") as Array
	var player_pos: Vector2 = Vector2(target.get("player_pos"))
	var boss_pos: Vector2 = Vector2(boss.get("pos", Vector2.ZERO))
	for i in range(maxi(1, field_count)):
		var origin: Vector2 = player_pos if i == 0 else boss_pos
		var angle: float = rng.randf_range(0.0, TAU)
		var distance: float = rng.randf_range(26.0, 135.0)
		var pos: Vector2 = origin + Vector2(cos(angle), sin(angle)) * distance
		pos.x = clampf(pos.x, arena.position.x + radius, arena.end.x - radius)
		pos.y = clampf(pos.y, arena.position.y + radius, arena.end.y - radius)
		fields.append({
			"pos": pos,
			"radius": radius,
			"life": duration,
			"maxLife": duration,
			"slowRate": slow_rate
		})
	target.set("boss_slow_fields", fields)

static func update_slow_fields_for_target(target: Node, delta: float) -> void:
	if target.get("boss_slow_fields") == null:
		return
	var result: Array = []
	for item in (target.get("boss_slow_fields") as Array):
		var field: Dictionary = item as Dictionary
		field["life"] = float(field.get("life", 0.0)) - delta
		if float(field["life"]) > 0.0:
			result.append(field)
	target.set("boss_slow_fields", result)

static func spawn_position_for_target(target: Node, arena: Rect2, rng: RandomNumberGenerator, radius: float) -> Vector2:
	var player_pos: Vector2 = Vector2(target.get("player_pos"))
	for attempt in range(32):
		var angle: float = rng.randf_range(0.0, TAU)
		var distance: float = rng.randf_range(430.0, 620.0)
		var pos: Vector2 = player_pos + Vector2(cos(angle), sin(angle)) * distance
		pos.x = clampf(pos.x, arena.position.x + radius + 24.0, arena.end.x - radius - 24.0)
		pos.y = clampf(pos.y, arena.position.y + radius + 24.0, arena.end.y - radius - 24.0)
		if pos.distance_to(player_pos) < 340.0:
			continue
		if _blocked_by_walls(pos, radius, target.get("effect_walls") as Array):
			continue
		return pos
	return Vector2(
		clampf(player_pos.x + 480.0, arena.position.x + radius + 24.0, arena.end.x - radius - 24.0),
		clampf(player_pos.y, arena.position.y + radius + 24.0, arena.end.y - radius - 24.0)
	)

static func _blocked_by_walls(pos: Vector2, radius: float, walls: Array) -> bool:
	for item in walls:
		var rect: Rect2 = item as Rect2
		if rect.grow(radius + 12.0).has_point(pos):
			return true
	return false
