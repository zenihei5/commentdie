class_name BossSystem
extends RefCounted

const BOSS_SUPER_LONG_COMMENT := "boss_super_long_comment"
const BOSS_KUSO_MARO_KING := "boss_kuso_maro_king"
const BOSS_BUGGED_FINAL_BOSS := "bugged_final_boss"
const BOSS_KIND := BOSS_SUPER_LONG_COMMENT
const WARNING_DURATION := 3.0
const DEFAULT_MAX_SUMMONS := 1
const ATTACK_KUSO_MARO_BARRAGE := "kuso_maro_barrage"
const ATTACK_STICKY_MARO_FLOOR := "sticky_maro_floor"
const ATTACK_SUMMON_UNREAD_MARO := "summon_unread_maro"
const BOSS_ATTACK_PRIORITY := [ATTACK_KUSO_MARO_BARRAGE, ATTACK_STICKY_MARO_FLOOR, ATTACK_SUMMON_UNREAD_MARO]
const BOSS_SPAWN_WALL_RADIUS_RATE := 0.62
const BOSS_SPAWN_WALL_RADIUS_MIN := 56.0
const BOSS_DEFEAT_BANNER := "大荒れ突破！"
const BOSS_DEFEAT_FX_LIFE := 1.65
const BOSS_DEFEAT_GIFT_DELAY := 0.45
const BUGGED_STATE_NORMAL := "normal"
const BUGGED_STATE_TELEGRAPH := "genre_telegraph"
const BUGGED_STATE_GENRE := "genre"
const BUGGED_STATE_STUN := "glitch_stun"
const BUGGED_GENRE_DURATION := 12.0
const BUGGED_GENRE_TELEGRAPH := 1.0
const BUGGED_STUN_DURATION := 1.2
const BUGGED_STUN_DAMAGE_RATE := 1.2
const BUGGED_GENRES: Array[String] = ["race", "bullet_hell", "horror"]
const BOSS_DEFEAT_COMMON_CHATS: Array[String] = [
	"ボス撃破きた！",
	"神回",
	"888888",
	"これは切り抜き",
	"よく倒した",
	"大荒れ突破",
	"ギフト投げろ",
	"今の熱い",
	"コメント欄も大盛り上がり"
]

static func default_boss_data() -> Dictionary:
	return {
		"id": BOSS_KIND,
		"displayName": "超長文ニキ",
		"description": "長文ニキの巨大版。大きなコメント塊でプレイヤーを追い詰める。",
		"hp": 400.0,
		"speed": 58.0,
		"radius": 78.0,
		"contactDamage": DamageSystem.BOSS_CONTACT_DAMAGE,
		"expValue": 20,
		"viewerValue": 3000,
		"giftHypeReward": 20,
		"lifetime": 45.0,
		"hitFlashDuration": 0.06,
		"knockbackResistance": 1.0,
		"canBeKnockedBack": false
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
	if target.get("boss_guide_lines") != null:
		(target.get("boss_guide_lines") as Array).clear()

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
		"toasts": ["WARNING! %s接近中！" % boss_name],
		"bossWarningStarted": true
	}

static func update_for_target(target: Node, delta: float, arena: Rect2, rng: RandomNumberGenerator) -> Dictionary:
	var chats: Array[String] = []
	var toasts: Array[String] = []
	var damage_events: Array = []
	var comment_event_ids: Array[String] = []
	var feedback: Dictionary = {
		"chats": chats,
		"toasts": toasts,
		"damageEvents": damage_events,
		"commentEventIds": comment_event_ids
	}
	update_slow_fields_for_target(target, delta)
	update_guide_lines_for_target(target, delta, damage_events)
	if bool(target.get("boss_requested")):
		var timer: float = maxf(0.0, float(target.get("boss_warning_timer")) - delta)
		target.set("boss_warning_timer", timer)
		if timer <= 0.0:
			var spawn_result: Dictionary = spawn_for_target(target, arena, rng)
			for item in (spawn_result.get("chats", []) as Array):
				chats.append(String(item))
			for item in (spawn_result.get("toasts", []) as Array):
				toasts.append(String(item))
			merge_reaction_feedback(feedback, spawn_result)
	if bool(target.get("boss_active")):
		var boss: Dictionary = active_boss_for_target(target)
		if boss.is_empty():
			target.set("boss_active", false)
			target.set("active_boss_uid", -1)
		elif not bool(boss.get("defeatPending", false)):
			var life: float = float(boss.get("bossLifetimeElapsed", 0.0)) + delta
			boss["bossLifetimeElapsed"] = life
			if life >= float(boss.get("bossLifetime", 45.0)):
				var retreat_result: Dictionary = retreat_for_target(target)
				for item in (retreat_result.get("chats", []) as Array):
					chats.append(String(item))
				for item in (retreat_result.get("toasts", []) as Array):
					toasts.append(String(item))
				merge_reaction_feedback(feedback, retreat_result)
			else:
				update_boss_attacks_for_target(target, boss, delta, arena, rng, chats, toasts, damage_events, comment_event_ids)
	return feedback

static func merge_reaction_feedback(target: Dictionary, source: Dictionary) -> void:
	if float(source.get("screenShakePower", 0.0)) > float(target.get("screenShakePower", 0.0)):
		target["screenShakePower"] = float(source.get("screenShakePower", 0.0))
	if float(source.get("screenShakeDuration", 0.0)) > float(target.get("screenShakeDuration", 0.0)):
		target["screenShakeDuration"] = float(source.get("screenShakeDuration", 0.0))
	if float(source.get("hitStop", 0.0)) > float(target.get("hitStop", 0.0)):
		target["hitStop"] = float(source.get("hitStop", 0.0))
	if float(source.get("screenFlashDuration", 0.0)) > float(target.get("screenFlashDuration", 0.0)):
		target["screenFlashDuration"] = float(source.get("screenFlashDuration", 0.0))
		target["screenFlashColor"] = source.get("screenFlashColor", Color.WHITE)

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
		"contactDamage": int(data.get("contactDamage", DamageSystem.BOSS_CONTACT_DAMAGE)),
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
		"bossGiftHypeReward": int(data.get("giftHypeReward", 20)),
		"hitFlashDuration": float(data.get("hitFlashDuration", 0.06)),
		"hitFlashTimer": 0.0,
		"knockbackResistance": float(data.get("knockbackResistance", 1.0)),
		"canBeKnockedBack": bool(data.get("canBeKnockedBack", false)),
		"knockbackVelocity": Vector2.ZERO
	}
	if boss_id == BOSS_BUGGED_FINAL_BOSS:
		initialize_bugged_final_boss_state(boss, rng)
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
	var spawn_feedback: Dictionary = {
		"chats": spawn_chats_for_boss(boss_id, boss_name),
		"toasts": ["ボス出現：%s" % boss_name],
		"screenShakePower": 0.32,
		"screenShakeDuration": 0.20
	}
	return spawn_feedback

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
	clear_bugged_boss_state_for_target(target)
	return {
		"chats": [retreat_chat_for_boss(boss_name)],
		"toasts": ["ボスに逃げられた…"]
	}

static func apply_defeat_for_target(target: Node, boss: Dictionary) -> Dictionary:
	if int(target.get("active_boss_uid")) != int(boss.get("uid", -2)):
		return {"chat": ""}
	var boss_id: String = String(boss.get("bossId", boss.get("kind", "")))
	var boss_name: String = String(boss.get("displayName", target.get("boss_last_name")))
	if boss_name == "":
		boss_name = "超長文ニキ"
	var readable_name: String = readable_boss_name(boss_id, boss_name)
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
	target.set("gift_choice_delay_timer", maxf(float(target.get("gift_choice_delay_timer")), BOSS_DEFEAT_GIFT_DELAY))
	target.set("boss_active", false)
	target.set("boss_requested", false)
	target.set("active_boss_uid", -1)
	target.set("boss_defeated", true)
	target.set("boss_last_name", boss_name)
	target.set("boss_last_result", "defeated")
	target.set("boss_reward_viewers", int(target.get("boss_reward_viewers")) + viewer_reward)
	if target.get("boss_slow_fields") != null:
		(target.get("boss_slow_fields") as Array).clear()
	clear_bugged_boss_state_for_target(target)
	append_boss_defeat_fx_for_target(target, boss, boss_id, readable_name, viewer_reward)
	var celebration_chats: Array[String] = defeat_chats_for_boss(boss_id, readable_name, viewer_reward, int(target.get("comment_barrage_setting")))
	return {
		"chat": celebration_chats[0] if celebration_chats.size() > 0 else "",
		"chats": celebration_chats.slice(1, celebration_chats.size()) if celebration_chats.size() > 1 else [],
		"toasts": [BOSS_DEFEAT_BANNER],
		"screenShakePower": 0.34,
		"screenShakeDuration": 0.14,
		"hitStop": 0.0,
		"screenFlashColor": Color(1.0, 0.94, 0.50, 0.18),
		"screenFlashDuration": 0.08
	}

static func readable_boss_name(boss_id: String, fallback: String) -> String:
	if boss_id == BOSS_KUSO_MARO_KING:
		return "クソマロキング"
	if boss_id == BOSS_BUGGED_FINAL_BOSS:
		return "バグったラスボス"
	if boss_id == BOSS_SUPER_LONG_COMMENT:
		return "超長文ニキ"
	return fallback

static func defeat_effect_type_for_boss(boss_id: String) -> String:
	if boss_id == BOSS_KUSO_MARO_KING:
		return "maro"
	if boss_id == BOSS_BUGGED_FINAL_BOSS:
		return "bugged"
	return "long_comment"

static func append_boss_defeat_fx_for_target(target: Node, boss: Dictionary, boss_id: String, boss_name: String, viewer_reward: int) -> void:
	var hit_fx: Array = target.get("hit_fx") as Array
	hit_fx.append({
		"kind": "boss_defeat",
		"pos": Vector2(boss.get("pos", Vector2.ZERO)),
		"radius": float(boss.get("radius", 78.0)),
		"life": BOSS_DEFEAT_FX_LIFE,
		"maxLife": BOSS_DEFEAT_FX_LIFE,
		"banner": BOSS_DEFEAT_BANNER,
		"bossName": boss_name,
		"effectType": defeat_effect_type_for_boss(boss_id),
		"viewerText": "+%d人" % viewer_reward,
		"seed": float(int(boss.get("uid", 0)) % 997)
	})
	target.set("hit_fx", hit_fx)

static func defeat_chats_for_boss(boss_id: String, boss_name: String, viewer_reward: int, comment_barrage_setting: int) -> Array[String]:
	var result: Array[String] = [
		"%s %s撃破！ 同時視聴者数 +%d人" % [BOSS_DEFEAT_BANNER, boss_name, viewer_reward]
	]
	var specific: Array[String] = []
	if boss_id == BOSS_KUSO_MARO_KING:
		specific = ["クソマロ鎮圧", "マロ欄救われた", "クソマロ成敗", "甘くない勝利"]
	elif boss_id == BOSS_BUGGED_FINAL_BOSS:
		specific = ["ラスボス停止！", "ジャンル暴走を止めた", "ゲーム実況枠クリア", "バグ修正完了"]
	else:
		specific = ["長文ニキ沈黙", "読まずに勝った", "要約成功", "長文、鎮圧！"]
	var target_total: int = defeat_comment_total_for_setting(comment_barrage_setting)
	for item in specific:
		if result.size() >= target_total:
			return result
		result.append(item)
	for item in BOSS_DEFEAT_COMMON_CHATS:
		if result.size() >= target_total:
			return result
		result.append(item)
	return result

static func defeat_comment_total_for_setting(setting: int) -> int:
	if setting <= 0:
		return 4
	if setting >= 2:
		return 8
	return 6

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
	if String(target.get("current_stream_frame_id")) == "gameplay":
		return BOSS_BUGGED_FINAL_BOSS
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
	if boss_id == BOSS_BUGGED_FINAL_BOSS:
		return "バグったラスボス出現！"
	return "大荒れイベント発生！"

static func request_chats_for_boss(boss_id: String, warning_text: String) -> Array[String]:
	if boss_id == BOSS_KUSO_MARO_KING:
		return [
			"WARNING! %s" % warning_text,
			"クソマロ王きた",
			"マロ欄終わった"
		]
	if boss_id == BOSS_BUGGED_FINAL_BOSS:
		return [
			"WARNING! %s" % warning_text,
			"ラスボス戦きた",
			"ジャンル変わりすぎ注意"
		]
	return [
		"WARNING! %s" % warning_text,
		"ボスきたｗ"
	]

static func spawn_chats_for_boss(boss_id: String, boss_name: String) -> Array[String]:
	if boss_id == BOSS_KUSO_MARO_KING:
		return [
			"%sが出現！" % boss_name,
			"読むな読むな",
			"これは荒れる"
		]
	if boss_id == BOSS_BUGGED_FINAL_BOSS:
		return [
			"%sが出現！" % boss_name,
			"ゲーム壊れた？",
			"ジャンルチェンジ連打してくるぞ"
		]
	return ["%sが出現！" % boss_name, "逃げるな"]

static func speech_text_for_boss(boss_id: String) -> String:
	if boss_id == BOSS_KUSO_MARO_KING:
		return "未読にするな"
	if boss_id == BOSS_BUGGED_FINAL_BOSS:
		return "ジャンル変更"
	return "戦え戦え"

static func retreat_chat_for_boss(_boss_name: String) -> String:
	return "ボスに逃げられた…"

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

static func initialize_bugged_final_boss_state(boss: Dictionary, rng: RandomNumberGenerator) -> void:
	boss["baseSpeed"] = float(boss.get("speed", 52.0))
	boss["buggedState"] = BUGGED_STATE_NORMAL
	boss["buggedStateTimer"] = bugged_normal_duration(boss, rng)
	boss["buggedTelegraphGenre"] = ""
	boss["buggedLastGenre"] = ""
	boss["buggedUsedGenres"] = []
	boss["buggedGenreCursor"] = rng.randi_range(0, BUGGED_GENRES.size() - 1)
	boss["buggedSpoilerTimer"] = rng.randf_range(1.1, 1.8)
	boss["buggedGuideLineTimer"] = rng.randf_range(2.4, 3.4)
	boss["buggedLagWarpTimer"] = rng.randf_range(4.4, 6.2)
	boss["buggedLagWarpWarning"] = 0.0
	boss["buggedLagWarpTarget"] = Vector2.ZERO
	boss["buggedBulletPatternTimer"] = 1.6
	boss["buggedRaceLineTimer"] = 2.1
	boss["damageTakenRate"] = 1.0
	boss["ignoreMovementWalls"] = true

static func bugged_hp_phase(boss: Dictionary) -> int:
	var max_hp: float = maxf(1.0, float(boss.get("max_hp", 1.0)))
	var ratio: float = clampf(float(boss.get("hp", max_hp)) / max_hp, 0.0, 1.0)
	if ratio <= 0.40:
		return 3
	if ratio <= 0.70:
		return 2
	return 1

static func bugged_normal_duration(boss: Dictionary, rng: RandomNumberGenerator) -> float:
	if bugged_hp_phase(boss) >= 3:
		return rng.randf_range(4.0, 5.5)
	return rng.randf_range(6.0, 8.0)

static func choose_bugged_genre(boss: Dictionary, rng: RandomNumberGenerator) -> String:
	var last_genre: String = String(boss.get("buggedLastGenre", ""))
	var phase: int = bugged_hp_phase(boss)
	var pool: Array[String] = []
	var used: Array = boss.get("buggedUsedGenres", []) as Array
	if phase >= 2:
		if used.size() >= BUGGED_GENRES.size():
			used.clear()
		for genre in BUGGED_GENRES:
			if genre != last_genre and not used.has(genre):
				pool.append(genre)
	if pool.is_empty():
		for genre in BUGGED_GENRES:
			if genre != last_genre:
				pool.append(genre)
	if pool.is_empty():
		pool = BUGGED_GENRES.duplicate()
	var selected := ""
	if phase >= 3:
		var cursor: int = int(boss.get("buggedGenreCursor", 0))
		for _i in range(BUGGED_GENRES.size() * 2):
			var candidate: String = BUGGED_GENRES[cursor % BUGGED_GENRES.size()]
			cursor += 1
			if candidate != last_genre:
				selected = candidate
				break
		boss["buggedGenreCursor"] = cursor
	if selected == "":
		selected = pool[rng.randi_range(0, pool.size() - 1)]
	used.append(selected)
	boss["buggedUsedGenres"] = used
	boss["buggedLastGenre"] = selected
	return selected

static func bugged_genre_short_label(genre: String) -> String:
	if genre == "race":
		return "レースゲー"
	if genre == "bullet_hell":
		return "弾幕STG"
	if genre == "horror":
		return "ホラゲ"
	return GenreEventSystem.label(genre)

static func clear_bugged_boss_state_for_target(target: Node) -> void:
	if target.get("boss_guide_lines") != null:
		(target.get("boss_guide_lines") as Array).clear()
	if String(target.get("genre_event_source")) == "boss":
		GenreEventSystem.clear_temp_objects_for_target(target)
		target.set("active_genre_event", "")
		target.set("genre_event_timer", 0.0)
		target.set("genre_event_duration", GenreEventSystem.GENRE_EVENT_DURATION)
		target.set("genre_event_source", "")

static func update_boss_attacks_for_target(
	target: Node,
	boss: Dictionary,
	delta: float,
	arena: Rect2,
	rng: RandomNumberGenerator,
	chats: Array[String],
	toasts: Array[String],
	damage_events: Array,
	comment_event_ids: Array[String]
) -> void:
	var boss_id := String(boss.get("bossId", ""))
	if boss_id == BOSS_BUGGED_FINAL_BOSS:
		update_bugged_final_boss_for_target(target, boss, delta, arena, rng, chats, toasts, damage_events, comment_event_ids)
		return
	if boss_id != BOSS_KUSO_MARO_KING:
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

static func update_bugged_final_boss_for_target(
	target: Node,
	boss: Dictionary,
	delta: float,
	arena: Rect2,
	rng: RandomNumberGenerator,
	chats: Array[String],
	toasts: Array[String],
	_damage_events: Array,
	comment_event_ids: Array[String]
) -> void:
	boss["ignoreMovementWalls"] = true
	boss["pos"] = EnemySystem.clamp_enemy_pos_to_arena_for_enemy(boss, Vector2(boss.get("pos", Vector2.ZERO)), arena)
	var base_speed: float = float(boss.get("baseSpeed", boss.get("speed", 52.0)))
	var state: String = String(boss.get("buggedState", BUGGED_STATE_NORMAL))
	if state == BUGGED_STATE_STUN:
		boss["speed"] = 0.0
		boss["damageTakenRate"] = BUGGED_STUN_DAMAGE_RATE
		boss["hitFlashTimer"] = maxf(float(boss.get("hitFlashTimer", 0.0)), 0.025)
		var stun_left := maxf(0.0, float(boss.get("buggedStateTimer", 0.0)) - delta)
		boss["buggedStateTimer"] = stun_left
		if stun_left <= 0.0:
			boss["damageTakenRate"] = 1.0
			boss["speed"] = base_speed
			boss["buggedState"] = BUGGED_STATE_NORMAL
			boss["buggedStateTimer"] = bugged_normal_duration(boss, rng)
			boss["speechText"] = "再起動"
		return
	boss["damageTakenRate"] = 1.0
	if state == BUGGED_STATE_TELEGRAPH:
		boss["speed"] = base_speed * 0.36
		var telegraph_left := maxf(0.0, float(boss.get("buggedStateTimer", 0.0)) - delta)
		boss["buggedStateTimer"] = telegraph_left
		if telegraph_left <= 0.0:
			start_bugged_genre_phase_for_target(target, boss, arena, rng, chats, toasts, comment_event_ids)
		return
	if state == BUGGED_STATE_GENRE:
		boss["speed"] = base_speed * 0.72
		update_bugged_genre_attacks_for_target(target, boss, delta, arena, rng, chats)
		var active_genre := String(target.get("active_genre_event"))
		var state_timer := maxf(0.0, float(boss.get("buggedStateTimer", BUGGED_GENRE_DURATION)) - delta)
		boss["buggedStateTimer"] = state_timer
		if active_genre == "" or state_timer <= 0.0:
			enter_bugged_stun_for_target(target, boss, chats)
		return
	boss["speed"] = base_speed
	if update_bugged_lag_warp_for_target(target, boss, delta, arena):
		return
	update_bugged_normal_attacks_for_target(target, boss, delta, arena, rng)
	var normal_left := maxf(0.0, float(boss.get("buggedStateTimer", 0.0)) - delta)
	boss["buggedStateTimer"] = normal_left
	if normal_left <= 0.0:
		enter_bugged_genre_telegraph(boss, rng, chats, toasts)

static func enter_bugged_genre_telegraph(boss: Dictionary, rng: RandomNumberGenerator, chats: Array[String], toasts: Array[String]) -> void:
	var genre := choose_bugged_genre(boss, rng)
	boss["buggedTelegraphGenre"] = genre
	boss["buggedState"] = BUGGED_STATE_TELEGRAPH
	boss["buggedStateTimer"] = BUGGED_GENRE_TELEGRAPH
	boss["speechText"] = "次は%s" % bugged_genre_short_label(genre)
	chats.append("バグったラスボス：ジャンルを書き換え中……")
	toasts.append("ジャンルチェンジ予告：%s" % GenreEventSystem.label(genre))

static func start_bugged_genre_phase_for_target(
	target: Node,
	boss: Dictionary,
	arena: Rect2,
	rng: RandomNumberGenerator,
	chats: Array[String],
	toasts: Array[String],
	comment_event_ids: Array[String]
) -> void:
	var genre := String(boss.get("buggedTelegraphGenre", ""))
	if genre == "":
		genre = choose_bugged_genre(boss, rng)
	var feedback: Dictionary = GenreEventSystem.start_world_event_for_target(target, genre, arena, rng, BUGGED_GENRE_DURATION, "boss")
	for item in (feedback.get("chats", []) as Array):
		chats.append(String(item))
	for item in (feedback.get("toasts", []) as Array):
		toasts.append(String(item))
	for item in (feedback.get("commentEventIds", []) as Array):
		var event_id := String(item)
		if event_id != "" and not comment_event_ids.has(event_id):
			comment_event_ids.append(event_id)
	boss["buggedState"] = BUGGED_STATE_GENRE
	boss["buggedStateTimer"] = BUGGED_GENRE_DURATION + 0.2
	boss["buggedBulletPatternTimer"] = 1.2
	boss["buggedRaceLineTimer"] = 1.4
	boss["speechText"] = GenreEventSystem.label(genre)

static func enter_bugged_stun_for_target(target: Node, boss: Dictionary, chats: Array[String]) -> void:
	clear_bugged_boss_state_for_target(target)
	boss["buggedState"] = BUGGED_STATE_STUN
	boss["buggedStateTimer"] = BUGGED_STUN_DURATION
	boss["speed"] = 0.0
	boss["damageTakenRate"] = BUGGED_STUN_DAMAGE_RATE
	boss["hitFlashTimer"] = maxf(float(boss.get("hitFlashTimer", 0.0)), 0.16)
	boss["speechText"] = "停止中"
	append_bugged_status_text_for_target(target, Vector2(boss.get("pos", Vector2.ZERO)), "BUG STOP")
	chats.append("バグったラスボスが停止した！")

static func update_bugged_normal_attacks_for_target(target: Node, boss: Dictionary, delta: float, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var phase: int = bugged_hp_phase(boss)
	var spoiler_timer := float(boss.get("buggedSpoilerTimer", 1.2)) - delta
	if spoiler_timer <= 0.0:
		var count := 4 if phase >= 3 else 3
		spawn_bugged_spoiler_bullets_for_target(target, boss, rng, count)
		spoiler_timer = rng.randf_range(1.05, 1.55) if phase >= 3 else rng.randf_range(1.45, 2.15)
	boss["buggedSpoilerTimer"] = spoiler_timer
	var line_timer := float(boss.get("buggedGuideLineTimer", 3.0)) - delta
	if line_timer <= 0.0:
		var count := 2 if phase >= 3 else 1
		spawn_bugged_guide_lines_for_target(target, boss, arena, rng, count, 0.72, 58.0)
		line_timer = rng.randf_range(3.1, 4.1) if phase >= 3 else rng.randf_range(4.0, 5.2)
	boss["buggedGuideLineTimer"] = line_timer
	var warp_timer := float(boss.get("buggedLagWarpTimer", 5.0)) - delta
	if warp_timer <= 0.0:
		start_bugged_lag_warp_for_target(target, boss, arena, rng)
		warp_timer = rng.randf_range(7.2, 9.2)
	boss["buggedLagWarpTimer"] = warp_timer

static func update_bugged_genre_attacks_for_target(target: Node, boss: Dictionary, delta: float, arena: Rect2, rng: RandomNumberGenerator, _chats: Array[String]) -> void:
	var active_genre := String(target.get("active_genre_event"))
	if active_genre == "race":
		var race_timer := float(boss.get("buggedRaceLineTimer", 1.4)) - delta
		if race_timer <= 0.0:
			spawn_bugged_guide_lines_for_target(target, boss, arena, rng, 1, 0.80, 72.0)
			race_timer = rng.randf_range(2.6, 3.5)
		boss["buggedRaceLineTimer"] = race_timer
	elif active_genre == "bullet_hell":
		var bullet_timer := float(boss.get("buggedBulletPatternTimer", 1.2)) - delta
		if bullet_timer <= 0.0:
			spawn_bugged_boss_pattern_bullets_for_target(target, boss, rng)
			bullet_timer = 2.0
		boss["buggedBulletPatternTimer"] = bullet_timer

static func spawn_bugged_spoiler_bullets_for_target(target: Node, boss: Dictionary, rng: RandomNumberGenerator, count: int) -> void:
	var bullets: Array = target.get("enemy_bullets") as Array
	if bullets.size() >= EnemySystem.MAX_ENEMY_BULLETS:
		return
	var boss_pos := Vector2(boss.get("pos", Vector2.ZERO))
	var to_player := Vector2(target.get("player_pos")) - boss_pos
	var base_dir := to_player.normalized()
	if base_dir.length() < 0.1:
		base_dir = Vector2.RIGHT
	var spread := 0.34
	for i in range(maxi(1, count)):
		if bullets.size() >= EnemySystem.MAX_ENEMY_BULLETS:
			break
		var offset := 0.0
		if count > 1:
			offset = lerpf(-spread, spread, float(i) / float(count - 1))
		var dir := base_dir.rotated(offset + rng.randf_range(-0.035, 0.035)).normalized()
		bullets.append({
			"pos": boss_pos + dir * float(boss.get("radius", 96.0)) * 0.42,
			"vel": dir * 250.0,
			"life": 3.4,
			"hitRadius": 17.0,
			"source": "boss_bullet",
			"damage": 22,
			"visualKind": "wiki_comment"
		})
	target.set("enemy_bullets", bullets)

static func spawn_bugged_boss_pattern_bullets_for_target(target: Node, boss: Dictionary, rng: RandomNumberGenerator) -> void:
	var bullets: Array = target.get("enemy_bullets") as Array
	if bullets.size() >= EnemySystem.MAX_ENEMY_BULLETS:
		return
	var boss_pos := Vector2(boss.get("pos", Vector2.ZERO))
	var to_player := Vector2(target.get("player_pos")) - boss_pos
	var base_dir := to_player.normalized()
	if base_dir.length() < 0.1:
		base_dir = Vector2.DOWN
	for angle in [-0.34, 0.0, 0.34]:
		if bullets.size() >= EnemySystem.MAX_ENEMY_BULLETS:
			break
		var dir := base_dir.rotated(angle + rng.randf_range(-0.02, 0.02)).normalized()
		bullets.append({
			"pos": boss_pos + dir * 52.0,
			"vel": dir * 235.0,
			"life": 3.0,
			"hitRadius": 15.0,
			"source": "boss_bullet",
			"damage": 18,
			"visualKind": "drone_bullet"
		})
	target.set("enemy_bullets", bullets)

static func start_bugged_lag_warp_for_target(target: Node, boss: Dictionary, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var player_pos := Vector2(target.get("player_pos"))
	var angle := rng.randf_range(0.0, TAU)
	var distance := rng.randf_range(210.0, 270.0)
	var target_pos := player_pos + Vector2(cos(angle), sin(angle)) * distance
	var radius := float(boss.get("radius", 96.0))
	target_pos.x = clampf(target_pos.x, arena.position.x + radius + 16.0, arena.end.x - radius - 16.0)
	target_pos.y = clampf(target_pos.y, arena.position.y + radius + 16.0, arena.end.y - radius - 16.0)
	boss["buggedLagWarpTarget"] = target_pos
	boss["buggedLagWarpWarning"] = 0.40
	boss["speechText"] = "ラグ発生"

static func update_bugged_lag_warp_for_target(target: Node, boss: Dictionary, delta: float, _arena: Rect2) -> bool:
	var warning := float(boss.get("buggedLagWarpWarning", 0.0))
	if warning <= 0.0:
		return false
	warning = maxf(0.0, warning - delta)
	boss["buggedLagWarpWarning"] = warning
	boss["speed"] = float(boss.get("baseSpeed", boss.get("speed", 52.0))) * 0.20
	if warning <= 0.0:
		var next_pos := Vector2(boss.get("buggedLagWarpTarget", boss.get("pos", Vector2.ZERO)))
		boss["pos"] = next_pos
		boss["hitFlashTimer"] = maxf(float(boss.get("hitFlashTimer", 0.0)), 0.11)
		append_bugged_status_text_for_target(target, next_pos, "LAG")
		boss["speechText"] = "ワープ"
	return true

static func spawn_bugged_guide_lines_for_target(target: Node, boss: Dictionary, arena: Rect2, rng: RandomNumberGenerator, count: int, telegraph: float, width: float) -> void:
	var lines: Array = target.get("boss_guide_lines") as Array
	var boss_pos := Vector2(boss.get("pos", Vector2.ZERO))
	var player_pos := Vector2(target.get("player_pos"))
	var base_dir := (player_pos - boss_pos).normalized()
	if base_dir.length() < 0.1:
		base_dir = Vector2.RIGHT
	var length := maxf(arena.size.x, arena.size.y) * 1.55
	for i in range(maxi(1, count)):
		var dir := base_dir.rotated(rng.randf_range(-0.25, 0.25) + (float(i) - float(count - 1) * 0.5) * 0.28).normalized()
		var center := player_pos + dir * rng.randf_range(-80.0, 72.0)
		lines.append({
			"from": center - dir * length * 0.5,
			"to": center + dir * length * 0.5,
			"timer": telegraph,
			"maxTimer": telegraph,
			"flashLife": 0.16,
			"width": width,
			"damage": DamageSystem.BOSS_ATTACK_DAMAGE,
			"hit": false
		})
	target.set("boss_guide_lines", lines)

static func update_guide_lines_for_target(target: Node, delta: float, damage_events: Array) -> void:
	if target.get("boss_guide_lines") == null:
		return
	var player_pos := Vector2(target.get("player_pos"))
	var kept: Array = []
	for item in (target.get("boss_guide_lines") as Array):
		var line: Dictionary = item as Dictionary
		var timer := float(line.get("timer", 0.0)) - delta
		line["timer"] = timer
		if timer <= 0.0 and not bool(line.get("hit", false)):
			line["hit"] = true
			var from_pos := Vector2(line.get("from", Vector2.ZERO))
			var to_pos := Vector2(line.get("to", Vector2.ZERO))
			var hit_width := float(line.get("width", 58.0)) * 0.5 + 13.0
			if distance_to_segment(player_pos, from_pos, to_pos) <= hit_width:
				damage_events.append({"source": "boss_attack", "damage": int(line.get("damage", DamageSystem.BOSS_ATTACK_DAMAGE))})
		if bool(line.get("hit", false)):
			line["flashLife"] = float(line.get("flashLife", 0.16)) - delta
			if float(line.get("flashLife", 0.0)) > 0.0:
				kept.append(line)
		else:
			kept.append(line)
	target.set("boss_guide_lines", kept)

static func distance_to_segment(point: Vector2, from_pos: Vector2, to_pos: Vector2) -> float:
	var segment := to_pos - from_pos
	var length_sq := segment.length_squared()
	if length_sq <= 0.01:
		return point.distance_to(from_pos)
	var t := clampf((point - from_pos).dot(segment) / length_sq, 0.0, 1.0)
	return point.distance_to(from_pos + segment * t)

static func append_bugged_status_text_for_target(target: Node, pos: Vector2, text: String) -> void:
	var hit_fx: Array = target.get("hit_fx") as Array
	hit_fx.append({
		"kind": "pickup_text",
		"pos": pos + Vector2(0.0, -64.0),
		"vel": Vector2(0.0, -28.0),
		"life": 0.58,
		"maxLife": 0.58,
		"text": text,
		"color": Color("#84f7ff")
	})
	target.set("hit_fx", hit_fx)

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
	var damage: int = int(attack.get("damage", DamageSystem.BOSS_ATTACK_DAMAGE))
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
			"source": "boss_bullet",
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
		"contactDamage": DamageSystem.DEFAULT_CONTACT_DAMAGE,
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
	var wall_radius := boss_spawn_wall_radius(radius)
	var walls: Array = boss_spawn_walls_for_target(target)
	for attempt in range(32):
		var angle: float = rng.randf_range(0.0, TAU)
		var distance: float = rng.randf_range(430.0, 620.0)
		var pos: Vector2 = player_pos + Vector2(cos(angle), sin(angle)) * distance
		pos.x = clampf(pos.x, arena.position.x + radius + 24.0, arena.end.x - radius - 24.0)
		pos.y = clampf(pos.y, arena.position.y + radius + 24.0, arena.end.y - radius - 24.0)
		if pos.distance_to(player_pos) < 340.0:
			continue
		if _blocked_by_walls(pos, wall_radius, walls):
			continue
		return pos
	var fallback := Vector2(
		clampf(player_pos.x + 480.0, arena.position.x + radius + 24.0, arena.end.x - radius - 24.0),
		clampf(player_pos.y, arena.position.y + radius + 24.0, arena.end.y - radius - 24.0)
	)
	if not _blocked_by_walls(fallback, wall_radius, walls):
		return fallback
	var fallback_candidates := [
		Vector2(arena.position.x + radius + 96.0, player_pos.y),
		Vector2(arena.end.x - radius - 96.0, player_pos.y),
		Vector2(player_pos.x, arena.position.y + radius + 146.0),
		Vector2(player_pos.x, arena.end.y - radius - 146.0)
	]
	var best_pos := fallback
	var best_score := -1.0
	for candidate_value in fallback_candidates:
		var candidate: Vector2 = candidate_value
		candidate.x = clampf(candidate.x, arena.position.x + radius + 24.0, arena.end.x - radius - 24.0)
		candidate.y = clampf(candidate.y, arena.position.y + radius + 24.0, arena.end.y - radius - 24.0)
		if _blocked_by_walls(candidate, wall_radius, walls):
			continue
		var score := candidate.distance_to(player_pos)
		if score > best_score:
			best_score = score
			best_pos = candidate
	return best_pos

static func _blocked_by_walls(pos: Vector2, radius: float, walls: Array) -> bool:
	for item in walls:
		var rect: Rect2 = item as Rect2
		if rect.grow(radius + 12.0).has_point(pos):
			return true
	return false

static func boss_spawn_wall_radius(radius: float) -> float:
	return minf(radius, maxf(BOSS_SPAWN_WALL_RADIUS_MIN, radius * BOSS_SPAWN_WALL_RADIUS_RATE))

static func boss_spawn_walls_for_target(target: Node) -> Array:
	var stream_frame_id := String(target.get("current_stream_frame_id"))
	if stream_frame_id == "":
		stream_frame_id = "zatsudan"
	var walls: Array = DrawDataSystem.static_wall_rects(stream_frame_id)
	var effect_walls_value: Variant = target.get("effect_walls")
	if effect_walls_value is Array:
		for wall in (effect_walls_value as Array):
			walls.append(wall as Rect2)
	return walls
