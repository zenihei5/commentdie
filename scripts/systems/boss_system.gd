class_name BossSystem
extends RefCounted

const HardModeSystemScript := preload("res://scripts/systems/hard_mode_system.gd")
const GiftSystemScript := preload("res://scripts/systems/gift_system.gd")

const BOSS_SUPER_LONG_COMMENT := "boss_super_long_comment"
const BOSS_KUSO_MARO_KING := "boss_kuso_maro_king"
const BOSS_BUGGED_FINAL_BOSS := "bugged_final_boss"
const BOSS_PITCH_POLICE_CHIEF := "pitch_police_chief"
const BOSS_RED_PEN_REVIEW_CHIEF := "red_pen_review_chief"
const BOSS_COLLAB_CRUSHER := "collab_crusher"
const BOSS_KIND := BOSS_SUPER_LONG_COMMENT
const WARNING_DURATION := 3.0
const DEFAULT_MAX_SUMMONS := 1
const ATTACK_KUSO_MARO_BARRAGE := "kuso_maro_barrage"
const ATTACK_STICKY_MARO_FLOOR := "sticky_maro_floor"
const ATTACK_SUMMON_UNREAD_MARO := "summon_unread_maro"
const BOSS_ATTACK_PRIORITY := [ATTACK_KUSO_MARO_BARRAGE, ATTACK_STICKY_MARO_FLOOR, ATTACK_SUMMON_UNREAD_MARO]
const KUSO_MARO_BARRAGE_TELEGRAPH_DURATION := 0.46
const KUSO_MARO_BARRAGE_LAUNCH_FX_DURATION := 0.23
const KUSO_MARO_PROJECTILE_SPIN_SPEED_DEG := 480.0
const UNREAD_MARO_SUMMON_TELEGRAPH_DURATION := 0.50
const UNREAD_MARO_POP_IN_DURATION := 0.20
const UNREAD_MARO_SPEECH_DELAY := 0.12
const UNREAD_MARO_SPEECH_STAGGER := 0.015
const STICKY_MARO_FLOOR_TELEGRAPH_DURATION := 0.50
const STICKY_MARO_FLOOR_FORMATION_DURATION := 0.22
const STICKY_MARO_FLOOR_FADE_DURATION := 0.70
const STICKY_MARO_ENTRY_FX_DURATION := 0.16
const STICKY_MARO_EXIT_FX_DURATION := 0.14
const STICKY_MARO_PLAYER_RADIUS := 18.0
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
const BUGGED_SPOILER_TELEGRAPH_DURATION := 0.40
const BUGGED_SPOILER_LAUNCH_FX_DURATION := 0.15
const BUGGED_SPOILER_SPREAD := 0.34
const BUGGED_SPOILER_JITTER := 0.035
const BUGGED_LAG_WARP_WARNING_DURATION := 0.40
const BUGGED_LAG_WARP_REBUILD_DURATION := 0.15
const BUGGED_LAG_WARP_FRAME_DURATION := 0.033
const BUGGED_GENRES: Array[String] = ["race", "bullet_hell", "horror"]
const PITCH_CHIEF_STATE_NORMAL := "normal"
const PITCH_CHIEF_STATE_TELEGRAPH := "chorus_judge_telegraph"
const PITCH_CHIEF_STATE_JUDGE := "chorus_judge"
const PITCH_CHIEF_STATE_STUN := "stun"
const PITCH_CHIEF_JUDGE_TELEGRAPH := 1.2
const PITCH_CHIEF_JUDGE_DURATION := 10.0
const PITCH_CHIEF_JUDGE_REQUIRED := 6
const PITCH_CHIEF_SUCCESS_STUN := 2.0
const PITCH_CHIEF_FAILURE_STUN := 0.8
const PITCH_CHIEF_SUCCESS_DAMAGE_RATE := 1.2
const PITCH_CHIEF_BULLET_DAMAGE := 24
const PITCH_CHIEF_BULLET_SPEED := 245.0
const PITCH_CHIEF_BULLET_TELEGRAPH_DURATION := 0.40
const PITCH_CHIEF_BULLET_LAUNCH_FX_DURATION := 0.16
const PITCH_CHIEF_MEGAPHONE_DAMAGE := 28
const PITCH_CHIEF_MEGAPHONE_RANGE := 380.0
const PITCH_CHIEF_MEGAPHONE_ANGLE := PI / 3.0
const RED_PEN_BULLET_DAMAGE := 24
const RED_PEN_BULLET_SPEED := 255.0
const RED_PEN_BULLET_TELEGRAPH_DURATION := 0.38
const RED_PEN_BULLET_LAUNCH_FX_DURATION := 0.16
const RED_PEN_BULLET_HIT_FX_DURATION := 0.20
const RED_PEN_BULLET_SPAWN_DISTANCE := 70.0
const RED_PEN_BULLET_LIFE := 4.0
const RED_PEN_BULLET_HIT_RADIUS := 18.0
const RED_PEN_BULLET_SPREAD := PI / 180.0 * 24.0
const RED_PEN_BULLET_JITTER := 0.035
const RED_PEN_BULLET_DRAW_SIZE := 38.0
const RED_PEN_BULLET_TRAIL_LENGTH := 24.0
const RED_PEN_REVIEW_LINE_DAMAGE := 28
const RED_PEN_REVIEW_LINE_WIDTH := 74.0
const RED_PEN_LINE_CAST_FX_DURATION := 0.76
const RED_PEN_SUMMON_WARNING_DURATION := 0.50
const RED_PEN_SUMMON_CAST_FX_DURATION := 0.16
const RED_PEN_SUMMON_SPAWN_FX_DURATION := 0.24
const RED_PEN_SUMMON_POP_IN_DURATION := 0.20
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
	target.set("boss_cutin_pending", false)
	target.set("boss_cutin_started", false)
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
	clear_sticky_maro_floor_visual_state_for_target(target)
	clear_red_pen_pending_visual_state_for_boss(target, -1)
	if target.get("boss_guide_lines") != null:
		(target.get("boss_guide_lines") as Array).clear()
	clear_bugged_genre_visual_state_for_target(target)
	clear_pitch_police_chief_state_for_target(target)
	if target.has_method("_clear_collab_crusher_boss_state"):
		target.call("_clear_collab_crusher_boss_state", true)

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
	target.set("boss_cutin_pending", false)
	target.set("boss_cutin_started", false)
	target.set("boss_warning_timer", WARNING_DURATION)
	target.set("boss_warning_duration", WARNING_DURATION)
	target.set("boss_pending_id", boss_id)
	target.set("boss_warning_text", warning_text)
	target.set("boss_heart_variant", has_heart)
	var boss_death_text: String = death_text_for_boss(boss_id, has_heart)
	if boss_death_text != "":
		target.set("current_death_text", boss_death_text)
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
		"commentEventIds": comment_event_ids,
		"bossCutinRequest": {},
		"redPenReviewLineHit": false
	}
	update_sticky_maro_floor_fx_for_target(target, delta)
	update_slow_fields_for_target(target, delta)
	update_sticky_maro_floor_telegraphs_for_target(target, delta)
	update_sticky_maro_player_feedback_for_target(target)
	update_guide_lines_for_target(target, delta, damage_events, feedback)
	if bool(target.get("boss_requested")):
		var timer: float = maxf(0.0, float(target.get("boss_warning_timer")) - delta)
		target.set("boss_warning_timer", timer)
		if timer <= 0.0 and not bool(target.get("boss_cutin_started")):
			target.set("boss_cutin_pending", true)
			target.set("boss_cutin_started", true)
			feedback["bossCutinRequest"] = {
				"bossId": String(target.get("boss_pending_id")),
				"completionAction": "spawn_normal_boss"
			}
	if bool(target.get("boss_active")):
		var boss: Dictionary = active_boss_for_target(target)
		if boss.is_empty():
			target.set("boss_active", false)
			target.set("active_boss_uid", -1)
		elif bool(boss.get("cutinIntroLocked", false)):
			return feedback
		elif not bool(boss.get("defeatPending", false)):
			if HardModeSystemScript.is_high_difficulty_target(target):
				var hard_ratio := float(boss.get("hp", 1.0)) / maxf(1.0, float(boss.get("max_hp", 1.0)))
				boss["hardPhase"] = 2 if hard_ratio <= float(boss.get("hardPhase2HpRate", 0.50)) else 1
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

static func prepare_spawn_for_target(target: Node, arena: Rect2, rng: RandomNumberGenerator) -> Dictionary:
	if bool(target.get("boss_active")):
		return {}
	var boss_id: String = String(target.get("boss_pending_id"))
	if boss_id == "":
		boss_id = boss_id_for_target(target)
	var data: Dictionary = boss_data_for_target(target, boss_id)
	var hp_rate: float = maxf(0.1, float(target.get("boss_hp_rate")))
	var reward_rate: float = maxf(0.1, float(target.get("boss_reward_rate")))
	var boss_name: String = String(data.get("displayName", "超長文ニキ"))
	if bool(target.get("boss_heart_variant")) and boss_id != BOSS_KUSO_MARO_KING:
		boss_name += "♡"
	return {
		"bossId": boss_id,
		"data": data.duplicate(true),
		"hpRate": hp_rate,
		"rewardRate": reward_rate,
		"bossName": boss_name,
		"arena": arena,
		"spawnSeed": rng.randi(),
		"worldPosition": spawn_position_for_target(target, arena, rng, float(data.get("radius", 78.0))),
		"introLocked": false
	}

static func spawn_for_target(target: Node, arena: Rect2, rng: RandomNumberGenerator) -> Dictionary:
	return spawn_prepared_for_target(target, prepare_spawn_for_target(target, arena, rng))

static func spawn_prepared_for_target(target: Node, prepared: Dictionary) -> Dictionary:
	if prepared.is_empty() or bool(target.get("boss_active")):
		target.set("boss_requested", false)
		target.set("boss_cutin_pending", false)
		target.set("boss_cutin_started", false)
		return {"chats": [], "toasts": [], "spawnUid": -1}
	var boss_id := String(prepared.get("bossId", boss_id_for_target(target)))
	var data: Dictionary = (prepared.get("data", boss_data_for_target(target, boss_id)) as Dictionary).duplicate(true)
	var hp_rate := maxf(0.1, float(prepared.get("hpRate", target.get("boss_hp_rate"))))
	var reward_rate := maxf(0.1, float(prepared.get("rewardRate", target.get("boss_reward_rate"))))
	var base_hp: float = float(data.get("hp", 400.0))
	var max_hp: float = base_hp * hp_rate
	var next_uid: int = int(target.get("next_enemy_uid"))
	var boss_name := String(prepared.get("bossName", data.get("displayName", "BOSS")))
	var intro_locked := bool(prepared.get("introLocked", false))
	var arena: Rect2 = prepared.get("arena", Rect2(Vector2.ZERO, Vector2(1600.0, 900.0))) as Rect2
	var spawn_rng := RandomNumberGenerator.new()
	spawn_rng.seed = int(prepared.get("spawnSeed", 1))
	var boss := {
		"uid": next_uid,
		"kind": boss_id,
		"bossId": String(data.get("id", boss_id)),
		"ppRewardId": String(data.get("ppRewardId", data.get("id", boss_id))),
		"basePpReward": int(data.get("basePpReward", 0)),
		"isPpRewardTarget": bool(data.get("isPpRewardTarget", false)),
		"isFirstDefeatRewardTarget": bool(data.get("isFirstDefeatRewardTarget", false)),
		"isBoss": true,
		"displayName": boss_name,
		"pos": prepared.get("worldPosition", Vector2.ZERO) as Vector2,
		"hp": max_hp,
		"max_hp": max_hp,
		"speed": boss_speed(data),
		"radius": float(data.get("radius", 78.0)),
		"hurtboxRadius": maxf(0.0, float(data.get("hurtboxRadius", data.get("weaponHurtRadius", data.get("radius", 78.0))))),
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
		"knockbackVelocity": Vector2.ZERO,
		"cutinIntroLocked": intro_locked,
		"cutinVisualAlpha": 0.0 if intro_locked else 1.0,
		"cutinVisualScale": 0.94 if intro_locked else 1.0,
		"cutinVisualOffset": Vector2.ZERO,
		"cutinIntroPoseId": String(prepared.get("introPoseId", "generic")),
		"cutinIntroPoseProgress": 0.0
	}
	boss["spawnSource"] = "boss"
	boss["spawnPriority"] = HardModeSystemScript.spawn_priority_for_source("boss")
	boss["occupancyManaged"] = false
	if boss_id == BOSS_BUGGED_FINAL_BOSS:
		initialize_bugged_final_boss_state(boss, spawn_rng)
	if boss_id == BOSS_PITCH_POLICE_CHIEF:
		initialize_pitch_police_chief_state(boss, spawn_rng)
	if boss_id == BOSS_RED_PEN_REVIEW_CHIEF:
		initialize_red_pen_review_chief_state(boss, spawn_rng)
	if HardModeSystemScript.is_high_difficulty_target(target):
		var runtime := HardModeSystemScript.runtime_for_target(target)
		var hard_role := HardModeSystemScript.boss_role_for_target(target)
		HardModeSystemScript.apply_boss_runtime_stats(boss, runtime, hard_role)
		var boss_rates := HardModeSystemScript.boss_rates(runtime, hard_role)
		boss["bossViewerReward"] = int(round(float(boss.get("bossViewerReward", boss.get("score", 0))) * float(boss_rates.get("scoreRate", 1.0))))
		boss["hardPpRate"] = float(boss_rates.get("scoreRate", 1.0))
		var hard_actions: Dictionary = {}
		var runtime_config: Variant = runtime.get("difficultyConfig", {})
		if runtime_config is Dictionary:
			var boss_config: Variant = (runtime_config as Dictionary).get("boss", {})
			if boss_config is Dictionary:
				var configured_actions: Variant = (boss_config as Dictionary).get("hardActions", {})
				if configured_actions is Dictionary:
					hard_actions = configured_actions as Dictionary
		boss["hardPhase2ActionId"] = String(hard_actions.get(String(target.get("current_stream_frame_id")), ""))
		boss["bossLifetime"] = INF
		boss["hardPhase"] = 1
	var enemies: Array = target.get("enemies") as Array
	enemies.append(boss)
	target.set("enemies", enemies)
	target.set("next_enemy_uid", next_uid + 1)
	target.set("boss_requested", false)
	target.set("boss_cutin_pending", false)
	target.set("boss_cutin_started", false)
	target.set("boss_warning_timer", 0.0)
	target.set("boss_active", true)
	target.set("active_boss_uid", next_uid)
	target.set("boss_summon_count", int(target.get("boss_summon_count")) + 1)
	target.set("boss_summoned", true)
	target.set("boss_last_name", boss_name)
	target.set("boss_last_result", "active")
	if bool(boss.get("isPpRewardTarget", false)) and target.has_method("_record_evaluation_target_boss"):
		target.call("_record_evaluation_target_boss", true, false)
	if HardModeSystemScript.is_high_difficulty_target(target) and HardModeSystemScript.boss_role_for_target(target) == "reignition":
		target.set("boss_defeated", false)
	if boss_id == BOSS_COLLAB_CRUSHER and target.has_method("_on_collab_crusher_boss_started"):
		target.call("_on_collab_crusher_boss_started", boss, arena)
	var spawn_feedback: Dictionary = {
		"chats": spawn_chats_for_boss(boss_id, boss_name),
		"toasts": ["ボス出現：%s" % boss_name],
		"screenShakePower": 0.32,
		"screenShakeDuration": 0.20,
		"spawnUid": next_uid
	}
	return spawn_feedback

static func unlock_intro_for_target(target: Node, uid: int) -> void:
	for item in (target.get("enemies") as Array):
		var enemy: Dictionary = item as Dictionary
		if int(enemy.get("uid", -1)) != uid:
			continue
		enemy["cutinIntroLocked"] = false
		enemy["cutinVisualAlpha"] = 1.0
		enemy["cutinVisualScale"] = 1.0
		enemy["cutinVisualOffset"] = Vector2.ZERO
		enemy["cutinIntroPoseProgress"] = 1.0
		return

static func remove_intro_spawn_for_target(target: Node, uid: int) -> void:
	var remaining: Array = []
	for item in (target.get("enemies") as Array):
		var enemy: Dictionary = item as Dictionary
		if int(enemy.get("uid", -1)) == uid and bool(enemy.get("cutinIntroLocked", false)):
			continue
		remaining.append(enemy)
	target.set("enemies", remaining)
	clear_red_pen_pending_visual_state_for_boss(target, uid)
	if int(target.get("active_boss_uid")) == uid:
		target.set("boss_active", false)
		target.set("active_boss_uid", -1)
		target.set("boss_summoned", false)

static func retreat_for_target(target: Node) -> Dictionary:
	var boss_name: String = String(target.get("boss_last_name"))
	if boss_name == "":
		boss_name = "超長文ニキ"
	var active_uid: int = int(target.get("active_boss_uid"))
	clear_red_pen_pending_visual_state_for_boss(target, active_uid)
	var remaining: Array = []
	for item in (target.get("enemies") as Array):
		var enemy: Dictionary = item as Dictionary
		if bool(enemy.get("isBoss", false)) and int(enemy.get("uid", -1)) == active_uid:
			continue
		remaining.append(enemy)
	target.set("enemies", remaining)
	target.set("boss_requested", false)
	target.set("boss_cutin_pending", false)
	target.set("boss_cutin_started", false)
	target.set("boss_warning_timer", 0.0)
	target.set("boss_active", false)
	target.set("active_boss_uid", -1)
	target.set("boss_last_result", "retreated")
	if target.get("boss_slow_fields") != null:
		(target.get("boss_slow_fields") as Array).clear()
	clear_sticky_maro_floor_visual_state_for_target(target)
	clear_bugged_boss_state_for_target(target)
	clear_pitch_police_chief_state_for_target(target)
	if target.has_method("_clear_collab_crusher_boss_state"):
		target.call("_clear_collab_crusher_boss_state", true)
	return {
		"chats": [retreat_chat_for_boss(boss_name)],
		"toasts": ["ボスに逃げられた…"]
	}

static func apply_defeat_for_target(target: Node, boss: Dictionary) -> Dictionary:
	if int(target.get("active_boss_uid")) != int(boss.get("uid", -2)):
		return {"chat": ""}
	var boss_id: String = String(boss.get("bossId", boss.get("kind", "")))
	clear_red_pen_pending_visual_state_for_boss(target, int(boss.get("uid", -1)))
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
	if target.has_method("_enqueue_gift_request"):
		target.call("_enqueue_gift_request", "boss_defeat", "normal", true, false, true)
	else:
		GiftSystemScript.enqueue_gift_request(target, "boss_defeat", "normal", true, false, true)
	target.set("gift_choice_delay_timer", maxf(float(target.get("gift_choice_delay_timer")), BOSS_DEFEAT_GIFT_DELAY))
	target.set("boss_active", false)
	target.set("boss_requested", false)
	target.set("boss_cutin_pending", false)
	target.set("boss_cutin_started", false)
	target.set("active_boss_uid", -1)
	target.set("boss_defeated", true)
	target.set("boss_last_name", boss_name)
	target.set("boss_last_result", "defeated")
	target.set("boss_reward_viewers", int(target.get("boss_reward_viewers")) + viewer_reward)
	if target.get("boss_slow_fields") != null:
		(target.get("boss_slow_fields") as Array).clear()
	clear_sticky_maro_floor_visual_state_for_target(target)
	clear_bugged_boss_state_for_target(target)
	clear_pitch_police_chief_state_for_target(target)
	if target.has_method("_clear_collab_crusher_boss_state"):
		target.call("_clear_collab_crusher_boss_state", true)
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

static func cancel_cutin_for_target(target: Node) -> void:
	target.set("boss_requested", false)
	target.set("boss_warning_timer", 0.0)
	target.set("boss_cutin_pending", false)
	target.set("boss_cutin_started", false)

static func readable_boss_name(boss_id: String, fallback: String) -> String:
	if boss_id == BOSS_COLLAB_CRUSHER:
		return "コラボクラッシャー"
	if boss_id == BOSS_KUSO_MARO_KING:
		return "クソマロキング"
	if boss_id == BOSS_BUGGED_FINAL_BOSS:
		return "バグったラスボス"
	if boss_id == BOSS_PITCH_POLICE_CHIEF:
		return "音程警察長"
	if boss_id == BOSS_RED_PEN_REVIEW_CHIEF:
		return "赤ペンリテイクドラゴン"
	if boss_id == BOSS_SUPER_LONG_COMMENT:
		return "超長文ニキ"
	return fallback

static func defeat_effect_type_for_boss(boss_id: String) -> String:
	if boss_id == BOSS_COLLAB_CRUSHER:
		return "collab"
	if boss_id == BOSS_KUSO_MARO_KING:
		return "maro"
	if boss_id == BOSS_BUGGED_FINAL_BOSS:
		return "bugged"
	if boss_id == BOSS_PITCH_POLICE_CHIEF:
		return "song"
	if boss_id == BOSS_RED_PEN_REVIEW_CHIEF:
		return "drawing"
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
	if boss_id == BOSS_COLLAB_CRUSHER:
		specific = ["VSノイズ完全破壊！", "連携で勝った！", "不仲煽り終了", "コラボ大成功！"]
	elif boss_id == BOSS_KUSO_MARO_KING:
		specific = ["クソマロ鎮圧", "マロ欄救われた", "クソマロ成敗", "甘くない勝利"]
	elif boss_id == BOSS_BUGGED_FINAL_BOSS:
		specific = ["ラスボス停止！", "ジャンル暴走を止めた", "ゲーム実況枠クリア", "バグ修正完了"]
	elif boss_id == BOSS_PITCH_POLICE_CHIEF:
		specific = ["音程警察長、取り締まり終了！", "歌い切った！", "サビジャッジ突破", "ライブ続行！"]
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
	var stream_frame_id: String = String(target.get("current_stream_frame_id"))
	if HardModeSystemScript.is_high_difficulty_target(target):
		var configured_id := HardModeSystemScript.boss_id_for_stage(
			HardModeSystemScript.runtime_for_target(target),
			stream_frame_id
		)
		if configured_id != "":
			return configured_id
	if stream_frame_id == "zatsudan":
		return BOSS_KUSO_MARO_KING
	if stream_frame_id == "gameplay":
		return BOSS_BUGGED_FINAL_BOSS
	if stream_frame_id == "song" or stream_frame_id == "singing":
		return BOSS_PITCH_POLICE_CHIEF
	if stream_frame_id == "drawing":
		return BOSS_RED_PEN_REVIEW_CHIEF
	if stream_frame_id == "collab":
		return BOSS_COLLAB_CRUSHER
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
	if boss_id == BOSS_PITCH_POLICE_CHIEF:
		return "音程警察長 出現！"
	if boss_id == BOSS_COLLAB_CRUSHER:
		return "コラボクラッシャー 出現！"
	return "大荒れイベント発生！"

static func request_chats_for_boss(boss_id: String, warning_text: String) -> Array[String]:
	if boss_id == BOSS_COLLAB_CRUSHER:
		return [
			"WARNING! %s" % warning_text,
			"VSノイズ来るぞ",
			"二人で連携して倒せ！"
		]
	if boss_id == BOSS_RED_PEN_REVIEW_CHIEF:
		return [
			"WARNING! %s" % warning_text,
			"赤ペンリテイクドラゴンきた",
			"リテイクライン注意"
		]
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
	if boss_id == BOSS_PITCH_POLICE_CHIEF:
		return [
			"WARNING! %s" % warning_text,
			"音程チェック厳しそう",
			"赤チェック注意"
		]
	return [
		"WARNING! %s" % warning_text,
		"ボスきたｗ"
	]

static func spawn_chats_for_boss(boss_id: String, boss_name: String) -> Array[String]:
	if boss_id == BOSS_COLLAB_CRUSHER:
		return [
			"%sが出現！" % boss_name,
			"比較と不仲煽りの塊だ",
			"PASSを回してコンビ技を撃て！"
		]
	if boss_id == BOSS_RED_PEN_REVIEW_CHIEF:
		return [
			"%sが出現！" % boss_name,
			"赤ペンが太い",
			"修正コメント湧きそう"
		]
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
	if boss_id == BOSS_PITCH_POLICE_CHIEF:
		return [
			"%sが出現！" % boss_name,
			"音程警察きた",
			"サビジャッジされるぞ"
		]
	return ["%sが出現！" % boss_name, "逃げるな"]

static func speech_text_for_boss(boss_id: String) -> String:
	if boss_id == BOSS_COLLAB_CRUSHER:
		return "VS"
	if boss_id == BOSS_RED_PEN_REVIEW_CHIEF:
		return "要修正"
	if boss_id == BOSS_KUSO_MARO_KING:
		return "未読にするな"
	if boss_id == BOSS_BUGGED_FINAL_BOSS:
		return "ジャンル変更"
	if boss_id == BOSS_PITCH_POLICE_CHIEF:
		return "音程チェック"
	return "戦え戦え"

static func retreat_chat_for_boss(_boss_name: String) -> String:
	return "ボスに逃げられた…"

static func death_text_for_boss(boss_id: String, has_heart: bool) -> String:
	if boss_id == BOSS_COLLAB_CRUSHER:
		if has_heart:
			return "「ボスと戦え♡」でコラボクラッシャーの対立ノイズに押し切られた"
		return "「ボスと戦え」でコラボクラッシャーに二人の連携を分断された"
	if boss_id == BOSS_RED_PEN_REVIEW_CHIEF:
		if has_heart:
			return "「ボスと戦え♡」で赤ペンリテイクドラゴンの優しめリテイクに押し切られた"
		return "「ボスと戦え」で赤ペンリテイクドラゴンに画面中をリテイクされた"
	if boss_id == BOSS_KUSO_MARO_KING:
		if has_heart:
			return "「ボスと戦え♡」でもクソマロキングの圧が強かった"
		return "「ボスと戦え」でクソマロキングに押し切られた"
	if boss_id == BOSS_BUGGED_FINAL_BOSS:
		if has_heart:
			return "「ボスと戦え♡」でバグったラスボスのジャンル崩壊に飲まれた"
		return "「ボスと戦え」でバグったラスボスに押し切られた"
	if boss_id == BOSS_PITCH_POLICE_CHIEF:
		if has_heart:
			return "「ボスと戦え♡」で音程警察長のサビジャッジに押し切られた"
		return "「ボスと戦え」で音程警察長に音程チェックされた"
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
	clear_bugged_spoiler_telegraph(boss)
	boss["buggedGuideLineTimer"] = rng.randf_range(2.4, 3.4)
	boss["buggedLagWarpTimer"] = rng.randf_range(4.4, 6.2)
	clear_bugged_lag_warp_visual_state(boss)
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
	clear_bugged_genre_visual_state_for_target(target)

static func clear_bugged_genre_visual_state_for_target(target: Node) -> void:
	target.set("boss_genre_visual_active", false)
	target.set("boss_genre_visual_event", "")
	target.set("boss_genre_visual_phase", "")
	target.set("boss_genre_visual_seed", 0.0)
	target.set("boss_genre_break_visual_timer", 0.0)
	target.set("boss_genre_break_visual_duration", BUGGED_STUN_DURATION)

static func set_bugged_genre_visual_state_for_target(target: Node, event_id: String, phase: String, boss: Dictionary) -> void:
	target.set("boss_genre_visual_active", true)
	target.set("boss_genre_visual_event", event_id)
	target.set("boss_genre_visual_phase", phase)
	var pos := Vector2(boss.get("pos", Vector2.ZERO))
	var event_seed := float(abs(event_id.hash()) % 997) * 0.001
	target.set("boss_genre_visual_seed", fposmod(pos.x * 0.013 + pos.y * 0.019 + event_seed, TAU))

static func initialize_pitch_police_chief_state(boss: Dictionary, rng: RandomNumberGenerator) -> void:
	boss["baseSpeed"] = float(boss.get("speed", 52.0))
	boss["pitchChiefState"] = PITCH_CHIEF_STATE_NORMAL
	boss["pitchChiefStateTimer"] = pitch_chief_normal_duration(boss, rng)
	boss["pitchChiefBulletTimer"] = rng.randf_range(0.9, 1.5)
	boss["pitchChiefPitchWaveTimer"] = rng.randf_range(2.4, 3.8)
	boss["pitchChiefMegaphoneTimer"] = rng.randf_range(4.6, 6.0)
	boss["pitchChiefJudgeTimer"] = pitch_chief_judge_interval(boss, rng)
	boss["pitchChiefStunDamageRate"] = 1.0
	boss["damageTakenRate"] = 1.0
	boss["ignoreMovementWalls"] = true
	clear_pitch_chief_bullet_telegraph_state(boss)

static func pitch_chief_hp_phase(boss: Dictionary) -> int:
	var max_hp: float = maxf(1.0, float(boss.get("max_hp", boss.get("hp", 1.0))))
	var ratio: float = clampf(float(boss.get("hp", max_hp)) / max_hp, 0.0, 1.0)
	if ratio <= 0.40:
		return 3
	if ratio <= 0.70:
		return 2
	return 1

static func pitch_chief_normal_duration(boss: Dictionary, rng: RandomNumberGenerator) -> float:
	if pitch_chief_hp_phase(boss) >= 3:
		return rng.randf_range(4.5, 6.0)
	return rng.randf_range(6.0, 8.0)

static func pitch_chief_judge_interval(boss: Dictionary, rng: RandomNumberGenerator) -> float:
	if pitch_chief_hp_phase(boss) >= 3:
		return rng.randf_range(18.0, 24.0)
	return rng.randf_range(22.0, 32.0)

static func pitch_chief_bullet_count(boss: Dictionary) -> int:
	var phase := pitch_chief_hp_phase(boss)
	if phase >= 3:
		return 5
	if phase >= 2:
		return 4
	return 3

static func pitch_chief_pitch_wave_count(boss: Dictionary) -> int:
	return 2 if pitch_chief_hp_phase(boss) >= 3 else 1

static func clear_pitch_police_chief_state_for_target(target: Node) -> void:
	var enemies_value: Variant = target.get("enemies")
	if enemies_value is Array:
		for enemy_item in (enemies_value as Array):
			var enemy: Dictionary = enemy_item as Dictionary
			if String(enemy.get("bossId", enemy.get("kind", ""))) == BOSS_PITCH_POLICE_CHIEF or enemy.has("pitchChiefBulletTelegraphTimer"):
				clear_pitch_chief_bullet_telegraph_state(enemy)
	if target.has_method("_clear_song_boss_chorus_judge"):
		target.call("_clear_song_boss_chorus_judge")
	if target.has_method("_clear_song_boss_pitch_waves"):
		target.call("_clear_song_boss_pitch_waves")

static func clear_pitch_chief_bullet_telegraph_state(boss: Dictionary) -> void:
	boss.erase("pitchChiefBulletTelegraphTimer")
	boss.erase("pitchChiefBulletTelegraphMax")
	boss.erase("pitchChiefBulletTelegraphDirections")
	boss.erase("pitchChiefBulletTelegraphCount")
	boss.erase("pitchChiefBulletTelegraphPhase")

static func update_pitch_police_chief_for_target(
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
	var action_delta := HardModeSystemScript.boss_action_delta_for_target(target, boss, delta)
	var state := String(boss.get("pitchChiefState", PITCH_CHIEF_STATE_NORMAL))
	if state == PITCH_CHIEF_STATE_STUN:
		boss["speed"] = 0.0
		boss["damageTakenRate"] = float(boss.get("pitchChiefStunDamageRate", 1.0))
		boss["hitFlashTimer"] = maxf(float(boss.get("hitFlashTimer", 0.0)), 0.025)
		var stun_left := maxf(0.0, float(boss.get("pitchChiefStateTimer", 0.0)) - delta)
		boss["pitchChiefStateTimer"] = stun_left
		if stun_left <= 0.0:
			boss["damageTakenRate"] = 1.0
			boss["speed"] = base_speed
			boss["pitchChiefState"] = PITCH_CHIEF_STATE_NORMAL
			boss["pitchChiefStateTimer"] = pitch_chief_normal_duration(boss, rng)
			boss["pitchChiefStunDamageRate"] = 1.0
			boss["speechText"] = "チェック再開"
		return
	boss["damageTakenRate"] = 1.0
	if state == PITCH_CHIEF_STATE_TELEGRAPH:
		boss["speed"] = base_speed * 0.25
		var telegraph_left := maxf(0.0, float(boss.get("pitchChiefStateTimer", 0.0)) - delta)
		boss["pitchChiefStateTimer"] = telegraph_left
		if telegraph_left <= 0.0:
			start_pitch_chorus_judge_for_target(target, boss, arena, rng, chats, comment_event_ids)
		return
	if state == PITCH_CHIEF_STATE_JUDGE:
		boss["speed"] = base_speed * 0.35
		var judge_left := maxf(0.0, float(boss.get("pitchChiefStateTimer", 0.0)) - delta)
		boss["pitchChiefStateTimer"] = judge_left
		if int(target.get("song_boss_chorus_judge_collected")) >= PITCH_CHIEF_JUDGE_REQUIRED:
			finish_pitch_chorus_judge_for_target(target, boss, true, chats, toasts, comment_event_ids)
		elif judge_left <= 0.0:
			finish_pitch_chorus_judge_for_target(target, boss, false, chats, toasts, comment_event_ids)
		return
	boss["speed"] = base_speed
	update_pitch_chief_normal_attacks_for_target(target, boss, action_delta, delta, arena, rng, chats, comment_event_ids)
	var normal_left := maxf(0.0, float(boss.get("pitchChiefStateTimer", 0.0)) - action_delta)
	boss["pitchChiefStateTimer"] = normal_left
	if normal_left <= 0.0:
		enter_pitch_chorus_judge_telegraph(target, boss, rng, chats, toasts, comment_event_ids)

static func update_pitch_chief_normal_attacks_for_target(
	target: Node,
	boss: Dictionary,
	action_delta: float,
	frame_delta: float,
	arena: Rect2,
	rng: RandomNumberGenerator,
	chats: Array[String],
	comment_event_ids: Array[String]
) -> void:
	var telegraph_active := boss.has("pitchChiefBulletTelegraphDirections")
	if telegraph_active:
		var telegraph_left := maxf(0.0, float(boss.get("pitchChiefBulletTelegraphTimer", PITCH_CHIEF_BULLET_TELEGRAPH_DURATION)) - frame_delta)
		boss["pitchChiefBulletTelegraphTimer"] = telegraph_left
		if telegraph_left <= 0.0:
			var locked_directions: Array = boss.get("pitchChiefBulletTelegraphDirections", []) as Array
			var locked_phase := int(boss.get("pitchChiefBulletTelegraphPhase", pitch_chief_hp_phase(boss)))
			var locked_count := int(boss.get("pitchChiefBulletTelegraphCount", locked_directions.size()))
			fire_pitch_chief_red_check_bullets_for_target(target, boss, locked_directions, locked_phase, locked_count)
			clear_pitch_chief_bullet_telegraph_state(boss)
			telegraph_active = false
	var bullet_timer := float(boss.get("pitchChiefBulletTimer", 1.2)) - action_delta
	if bullet_timer <= 0.0 and not telegraph_active:
		var captured_phase := pitch_chief_hp_phase(boss)
		var captured_count := pitch_chief_bullet_count(boss)
		var current_bullets: Array = target.get("enemy_bullets") as Array
		var available_slots := maxi(0, EnemySystem.MAX_ENEMY_BULLETS - current_bullets.size())
		var captured_directions := pitch_chief_red_check_directions_for_target(target, boss, rng, captured_count, available_slots)
		if not captured_directions.is_empty():
			boss["pitchChiefBulletTelegraphTimer"] = PITCH_CHIEF_BULLET_TELEGRAPH_DURATION
			boss["pitchChiefBulletTelegraphMax"] = PITCH_CHIEF_BULLET_TELEGRAPH_DURATION
			boss["pitchChiefBulletTelegraphDirections"] = captured_directions
			boss["pitchChiefBulletTelegraphCount"] = captured_count
			boss["pitchChiefBulletTelegraphPhase"] = captured_phase
		bullet_timer = rng.randf_range(1.1, 1.55) if captured_phase >= 3 else rng.randf_range(1.45, 2.05)
	boss["pitchChiefBulletTimer"] = bullet_timer
	var pitch_timer := float(boss.get("pitchChiefPitchWaveTimer", 3.0)) - action_delta
	if pitch_timer <= 0.0:
		spawn_pitch_chief_pitch_waves_for_target(target, arena, pitch_chief_pitch_wave_count(boss), chats, comment_event_ids, boss)
		pitch_timer = rng.randf_range(5.4, 7.0) if pitch_chief_hp_phase(boss) >= 3 else rng.randf_range(7.2, 9.2)
	boss["pitchChiefPitchWaveTimer"] = pitch_timer
	if pitch_chief_hp_phase(boss) >= 2:
		var megaphone_timer := float(boss.get("pitchChiefMegaphoneTimer", 5.0)) - action_delta
		if megaphone_timer <= 0.0:
			spawn_pitch_chief_megaphone_wave_for_target(target, boss, chats, comment_event_ids)
			megaphone_timer = rng.randf_range(6.8, 8.4) if pitch_chief_hp_phase(boss) >= 3 else rng.randf_range(8.2, 10.4)
		boss["pitchChiefMegaphoneTimer"] = megaphone_timer

static func spawn_pitch_chief_red_check_bullets_for_target(target: Node, boss: Dictionary, rng: RandomNumberGenerator, count: int) -> void:
	var bullets: Array = target.get("enemy_bullets") as Array
	var available_slots := maxi(0, EnemySystem.MAX_ENEMY_BULLETS - bullets.size())
	if available_slots <= 0:
		return
	var directions := pitch_chief_red_check_directions_for_target(target, boss, rng, count, available_slots)
	fire_pitch_chief_red_check_bullets_for_target(target, boss, directions, pitch_chief_hp_phase(boss), maxi(1, count))

static func pitch_chief_red_check_directions_for_target(target: Node, boss: Dictionary, rng: RandomNumberGenerator, count: int, max_directions: int = -1) -> Array:
	var boss_pos := Vector2(boss.get("pos", Vector2.ZERO))
	var to_player := Vector2(target.get("player_pos")) - boss_pos
	var to_player_sq := to_player.length_squared()
	var base_dir := to_player / sqrt(to_player_sq) if to_player_sq >= 0.01 else Vector2.RIGHT
	if base_dir.length_squared() < 0.01:
		base_dir = Vector2.RIGHT
	var spread := deg_to_rad(18.0)
	var step := spread / maxf(1.0, float(count - 1))
	var start := -spread * 0.5
	var directions: Array = []
	var direction_count := maxi(1, count)
	if max_directions >= 0:
		direction_count = mini(direction_count, max_directions)
	for i in range(direction_count):
		var dir := base_dir.rotated(start + step * float(i) + rng.randf_range(-0.025, 0.025)).normalized()
		directions.append(dir)
	return directions

static func fire_pitch_chief_red_check_bullets_for_target(target: Node, boss: Dictionary, directions: Array, captured_phase: int, captured_count: int) -> void:
	var bullets: Array = target.get("enemy_bullets") as Array
	if bullets.size() >= EnemySystem.MAX_ENEMY_BULLETS:
		return
	var boss_pos := Vector2(boss.get("pos", Vector2.ZERO))
	var spawn_distance := float(boss.get("radius", 102.0)) * 0.62 + 12.0
	var spawned_directions: Array = []
	for i in range(directions.size()):
		if bullets.size() >= EnemySystem.MAX_ENEMY_BULLETS:
			break
		var dir := Vector2(directions[i])
		if dir.length_squared() < 0.01:
			dir = Vector2.RIGHT
		else:
			dir = dir.normalized()
		bullets.append({
			"pos": boss_pos + dir * spawn_distance,
			"vel": dir * HardModeSystemScript.regular_boss_projectile_speed_for_target(target, PITCH_CHIEF_BULLET_SPEED),
			"life": 4.2,
			"hitRadius": 18.0,
			"source": "boss_bullet",
			"damage": HardModeSystemScript.regular_boss_damage_for_target(target, PITCH_CHIEF_BULLET_DAMAGE),
			"visualKind": "pitch_police_note",
			"shieldBlockable": true,
			"pitchChiefPhase": clampi(captured_phase, 1, 3),
			"pitchChiefCount": maxi(1, captured_count),
			"pitchNoteSeed": fposmod(boss_pos.x * 0.013 + boss_pos.y * 0.017 + float(i) * 1.618, TAU)
		})
		spawned_directions.append(dir)
	target.set("enemy_bullets", bullets)
	append_pitch_chief_red_check_launch_fx_for_target(target, boss_pos, float(boss.get("radius", 102.0)), spawned_directions, captured_phase)

static func append_pitch_chief_red_check_launch_fx_for_target(target: Node, pos: Vector2, radius: float, directions: Array, captured_phase: int) -> void:
	if directions.is_empty():
		return
	var hit_fx: Array = target.get("hit_fx") as Array
	hit_fx.append({
		"kind": "pitch_police_note_launch",
		"pos": pos,
		"radius": radius,
		"directions": directions.duplicate(),
		"count": directions.size(),
		"phase": clampi(captured_phase, 1, 3),
		"life": PITCH_CHIEF_BULLET_LAUNCH_FX_DURATION,
		"maxLife": PITCH_CHIEF_BULLET_LAUNCH_FX_DURATION
	})
	target.set("hit_fx", hit_fx)

static func spawn_pitch_chief_pitch_waves_for_target(target: Node, arena: Rect2, count: int, chats: Array[String], comment_event_ids: Array[String], boss: Dictionary = {}) -> void:
	var band_count := maxi(1, count)
	for band_index in range(band_count):
		if target.has_method("_spawn_song_pitch_wave"):
			target.call("_spawn_song_pitch_wave", arena, true, band_index, band_count)
	if not boss.is_empty() and target.has_method("_append_pitch_wave_cast_fx"):
		target.call("_append_pitch_wave_cast_fx", Vector2(boss.get("pos", Vector2.ZERO)), float(boss.get("radius", 102.0)), band_count)
	if not comment_event_ids.has("song_boss_pitch_wave"):
		comment_event_ids.append("song_boss_pitch_wave")
	chats.append("! 音程ズレ波！")

static func spawn_pitch_chief_megaphone_wave_for_target(target: Node, boss: Dictionary, chats: Array[String], comment_event_ids: Array[String]) -> void:
	if not target.has_method("_spawn_song_boss_megaphone_wave"):
		return
	var origin := Vector2(boss.get("pos", Vector2.ZERO))
	var dir := Vector2(target.get("player_pos")) - origin
	if dir.length_squared() <= 0.01:
		dir = Vector2.RIGHT
	else:
		dir = dir.normalized()
	target.call("_spawn_song_boss_megaphone_wave", origin, dir, PITCH_CHIEF_MEGAPHONE_RANGE, PITCH_CHIEF_MEGAPHONE_ANGLE, 0.7, 0.5, HardModeSystemScript.regular_boss_damage_for_target(target, PITCH_CHIEF_MEGAPHONE_DAMAGE), 0.7)
	if not comment_event_ids.has("song_boss_megaphone_wave"):
		comment_event_ids.append("song_boss_megaphone_wave")
	chats.append("! メガホン注意！")

static func enter_pitch_chorus_judge_telegraph(
	target: Node,
	boss: Dictionary,
	rng: RandomNumberGenerator,
	chats: Array[String],
	toasts: Array[String],
	comment_event_ids: Array[String]
) -> void:
	boss["pitchChiefState"] = PITCH_CHIEF_STATE_TELEGRAPH
	boss["pitchChiefStateTimer"] = PITCH_CHIEF_JUDGE_TELEGRAPH
	boss["speechText"] = "サビジャッジ"
	if target.has_method("_prepare_song_boss_chorus_judge"):
		target.call("_prepare_song_boss_chorus_judge", PITCH_CHIEF_JUDGE_REQUIRED, PITCH_CHIEF_JUDGE_DURATION)
	if not comment_event_ids.has("song_boss_chorus_judge_prepare"):
		comment_event_ids.append("song_boss_chorus_judge_prepare")
	chats.append("* サビジャッジ予告！")
	toasts.append("サビジャッジ：音符を集めろ！")
	boss["pitchChiefJudgeTimer"] = pitch_chief_judge_interval(boss, rng)

static func start_pitch_chorus_judge_for_target(
	target: Node,
	boss: Dictionary,
	arena: Rect2,
	rng: RandomNumberGenerator,
	chats: Array[String],
	comment_event_ids: Array[String]
) -> void:
	boss["pitchChiefState"] = PITCH_CHIEF_STATE_JUDGE
	boss["pitchChiefStateTimer"] = PITCH_CHIEF_JUDGE_DURATION
	boss["speechText"] = "音符を集めろ"
	if target.has_method("_start_song_boss_chorus_judge"):
		target.call("_start_song_boss_chorus_judge", PITCH_CHIEF_JUDGE_REQUIRED, PITCH_CHIEF_JUDGE_DURATION)
	if target.has_method("_spawn_song_boss_chorus_judge_notes"):
		target.call("_spawn_song_boss_chorus_judge_notes", rng.randi_range(8, 12), arena)
	if not comment_event_ids.has("song_boss_chorus_judge_start"):
		comment_event_ids.append("song_boss_chorus_judge_start")
	chats.append("* サビジャッジ開始！")

static func finish_pitch_chorus_judge_for_target(
	target: Node,
	boss: Dictionary,
	success: bool,
	chats: Array[String],
	toasts: Array[String],
	comment_event_ids: Array[String]
) -> void:
	boss["pitchChiefState"] = PITCH_CHIEF_STATE_STUN
	boss["pitchChiefStateTimer"] = PITCH_CHIEF_SUCCESS_STUN if success else PITCH_CHIEF_FAILURE_STUN
	boss["pitchChiefStunDamageRate"] = PITCH_CHIEF_SUCCESS_DAMAGE_RATE if success else 1.0
	boss["damageTakenRate"] = float(boss["pitchChiefStunDamageRate"])
	boss["speed"] = 0.0
	boss["hitFlashTimer"] = maxf(float(boss.get("hitFlashTimer", 0.0)), 0.18 if success else 0.08)
	boss["speechText"] = "ジャッジ成功" if success else "ジャッジ未達"
	if target.has_method("_finish_song_boss_chorus_judge"):
		target.call("_finish_song_boss_chorus_judge", success)
	if success:
		chats.append("+ サビジャッジ成功！")
		toasts.append("サビジャッジ成功！ ボスが停止")
		if not comment_event_ids.has("song_boss_chorus_judge_success"):
			comment_event_ids.append("song_boss_chorus_judge_success")
	else:
		chats.append("! サビジャッジ失敗")
		toasts.append("サビジャッジ未達")
		if not comment_event_ids.has("song_boss_chorus_judge_fail"):
			comment_event_ids.append("song_boss_chorus_judge_fail")

static func initialize_red_pen_review_chief_state(boss: Dictionary, rng: RandomNumberGenerator) -> void:
	boss["baseSpeed"] = float(boss.get("speed", 54.0))
	boss["redPenBulletTimer"] = rng.randf_range(1.0, 1.6)
	boss["redPenLineTimer"] = rng.randf_range(3.2, 4.8)
	boss["redPenSummonTimer"] = rng.randf_range(6.0, 8.0)
	boss["redPenBulletTelegraphPending"] = false
	boss["redPenBulletTelegraphTimer"] = 0.0
	boss["redPenBulletTelegraphDuration"] = RED_PEN_BULLET_TELEGRAPH_DURATION
	boss["redPenBulletTelegraphCastSerial"] = 0
	boss["redPenBulletTelegraphCount"] = 0
	boss["redPenBulletTelegraphPhase"] = 1
	boss["redPenReviewCastSerial"] = 0
	boss["redPenLineCastFx"] = 0.0
	boss["redPenLineCastFxMax"] = RED_PEN_LINE_CAST_FX_DURATION
	boss["redPenSummonCastFx"] = 0.0
	boss["redPenSummonCastFxMax"] = RED_PEN_SUMMON_CAST_FX_DURATION
	boss["redPenSummonWarningActive"] = false
	boss["redPenSummonWarningRealLeft"] = 0.0
	boss["redPenSummonWarningDuration"] = RED_PEN_SUMMON_WARNING_DURATION
	boss["redPenSummonWarningCastSerial"] = 0
	boss["redPenSummonWarningCount"] = 0
	boss["redPenSummonWarningBossUid"] = int(boss.get("uid", -1))
	boss["redPenCastDir"] = Vector2.RIGHT
	boss["ignoreMovementWalls"] = true

static func red_pen_review_phase(boss: Dictionary) -> int:
	var max_hp: float = maxf(1.0, float(boss.get("max_hp", boss.get("hp", 1.0))))
	var ratio: float = clampf(float(boss.get("hp", max_hp)) / max_hp, 0.0, 1.0)
	if ratio <= 0.35:
		return 3
	if ratio <= 0.68:
		return 2
	return 1

static func red_pen_summon_visual_count_for_phase(target: Node, phase: int) -> int:
	var base_count := 2 if phase >= 2 else 1
	return HardModeSystemScript.regular_boss_summon_count_for_target(target, base_count)

static func clear_red_pen_summon_warning_visual_state(boss: Dictionary) -> void:
	boss["redPenSummonWarningActive"] = false
	boss["redPenSummonWarningRealLeft"] = 0.0
	boss["redPenSummonWarningCount"] = 0
	boss["redPenSummonWarningBossUid"] = -1

static func update_red_pen_summon_warning_visual_state(
	target: Node,
	boss: Dictionary,
	delta: float,
	action_delta: float,
	phase: int,
	summon_timer: float,
	spawned_this_update: bool
) -> void:
	if spawned_this_update:
		clear_red_pen_summon_warning_visual_state(boss)
		return
	var duration := maxf(0.01, float(boss.get("redPenSummonWarningDuration", RED_PEN_SUMMON_WARNING_DURATION)))
	var effective_action_scale := 1.0
	if delta > 0.0:
		effective_action_scale = action_delta / delta
		if effective_action_scale <= 0.0001:
			effective_action_scale = 1.0
	var real_left := maxf(0.0, summon_timer) / effective_action_scale
	var in_warning_window := real_left > 0.0 and real_left <= duration
	if not in_warning_window:
		clear_red_pen_summon_warning_visual_state(boss)
		return
	var visual_count := red_pen_summon_visual_count_for_phase(target, phase)
	if not bool(boss.get("redPenSummonWarningActive", false)):
		boss["redPenSummonWarningCastSerial"] = int(boss.get("redPenSummonWarningCastSerial", 0)) + 1
		boss["redPenSummonWarningBossUid"] = int(boss.get("uid", -1))
	boss["redPenSummonWarningActive"] = true
	boss["redPenSummonWarningRealLeft"] = real_left
	boss["redPenSummonWarningDuration"] = duration
	boss["redPenSummonWarningCount"] = visual_count

static func update_red_pen_review_chief_for_target(
	target: Node,
	boss: Dictionary,
	delta: float,
	arena: Rect2,
	rng: RandomNumberGenerator,
	chats: Array[String],
	comment_event_ids: Array[String]
) -> void:
	boss["ignoreMovementWalls"] = true
	boss["pos"] = EnemySystem.clamp_enemy_pos_to_arena_for_enemy(boss, Vector2(boss.get("pos", Vector2.ZERO)), arena)
	var base_speed: float = float(boss.get("baseSpeed", boss.get("speed", 54.0)))
	boss["speed"] = base_speed
	var action_delta := HardModeSystemScript.boss_action_delta_for_target(target, boss, delta)
	boss["redPenLineCastFx"] = maxf(0.0, float(boss.get("redPenLineCastFx", 0.0)) - delta)
	boss["redPenSummonCastFx"] = maxf(0.0, float(boss.get("redPenSummonCastFx", 0.0)) - delta)
	update_red_pen_bullet_telegraph_for_target(target, boss, delta)
	var phase := red_pen_review_phase(boss)
	var bullet_timer := float(boss.get("redPenBulletTimer", 1.2)) - action_delta
	if bullet_timer <= 0.0 and not bool(boss.get("redPenBulletTelegraphPending", false)):
		var requested_count := 5 if phase >= 3 else (4 if phase >= 2 else 3)
		start_red_pen_bullet_telegraph_for_target(target, boss, rng, requested_count, phase)
		bullet_timer = rng.randf_range(1.05, 1.45) if phase >= 3 else rng.randf_range(1.35, 1.95)
	boss["redPenBulletTimer"] = bullet_timer
	var line_timer := float(boss.get("redPenLineTimer", 4.0)) - action_delta
	if line_timer <= 0.0:
		spawn_red_pen_review_lines_for_target(target, boss, arena, rng, 2 if phase >= 3 else 1)
		boss["redPenLineCastFx"] = RED_PEN_LINE_CAST_FX_DURATION
		line_timer = rng.randf_range(4.2, 5.6) if phase >= 3 else rng.randf_range(5.4, 7.2)
		if not comment_event_ids.has("drawing_boss_review_line"):
			comment_event_ids.append("drawing_boss_review_line")
		chats.append("! 添削ライン注意")
	boss["redPenLineTimer"] = line_timer
	var summon_timer := float(boss.get("redPenSummonTimer", 7.0)) - action_delta
	var summon_spawned_this_update := false
	var summon_base_count := 2 if phase >= 2 else 1
	if summon_timer <= 0.0:
		spawn_red_pen_fix_notes_for_target(target, boss, arena, rng, summon_base_count)
		boss["redPenSummonCastFx"] = RED_PEN_SUMMON_CAST_FX_DURATION
		summon_timer = rng.randf_range(8.5, 11.0) if phase >= 3 else rng.randf_range(10.0, 13.0)
		summon_spawned_this_update = true
		if not comment_event_ids.has("drawing_boss_summon_fix_notes"):
			comment_event_ids.append("drawing_boss_summon_fix_notes")
		chats.append("! 修正コメント召喚")
	boss["redPenSummonTimer"] = summon_timer
	update_red_pen_summon_warning_visual_state(target, boss, delta, action_delta, phase, summon_timer, summon_spawned_this_update)

static func clear_red_pen_bullet_telegraph_state(boss: Dictionary) -> void:
	boss["redPenBulletTelegraphPending"] = false
	boss.erase("redPenBulletTelegraphTimer")
	boss.erase("redPenBulletTelegraphDuration")
	boss.erase("redPenBulletTelegraphCount")
	boss.erase("redPenBulletTelegraphPhase")
	boss.erase("redPenBulletTelegraphBossUid")

static func clear_red_pen_pending_visual_state_for_boss(target: Node, boss_uid: int) -> void:
	var bullets_value: Variant = target.get("enemy_bullets")
	if bullets_value is Array:
		var kept_bullets: Array = []
		for bullet_item in bullets_value as Array:
			var bullet: Dictionary = bullet_item as Dictionary
			var is_pending := bool(bullet.get("redPenTelegraphPending", false))
			var belongs_to_boss := boss_uid < 0 or int(bullet.get("redPenBossUid", -1)) == boss_uid
			if is_pending and belongs_to_boss:
				continue
			kept_bullets.append(bullet)
		target.set("enemy_bullets", kept_bullets)
	var hit_fx_value: Variant = target.get("hit_fx")
	if hit_fx_value is Array:
		var kept_fx: Array = []
		for fx_item in hit_fx_value as Array:
			var fx: Dictionary = fx_item as Dictionary
			var fx_kind := String(fx.get("kind", ""))
			var is_launch_fx := fx_kind == "red_pen_launch"
			var is_review_line_hit_fx := fx_kind == "red_pen_review_line_hit"
			var belongs_to_boss := boss_uid < 0 or int(fx.get("redPenBossUid", -1)) == boss_uid
			if (is_launch_fx or is_review_line_hit_fx) and belongs_to_boss:
				continue
			kept_fx.append(fx)
		target.set("hit_fx", kept_fx)
	var enemies_value: Variant = target.get("enemies")
	if enemies_value is Array:
		for enemy_item in enemies_value as Array:
			var enemy: Dictionary = enemy_item as Dictionary
			if boss_uid < 0 and not enemy.has("redPenBulletTelegraphPending") and not enemy.has("redPenSummonWarningActive"):
				continue
			if boss_uid >= 0 and int(enemy.get("uid", -1)) != boss_uid:
				continue
			clear_red_pen_bullet_telegraph_state(enemy)
			clear_red_pen_summon_warning_visual_state(enemy)

static func start_red_pen_bullet_telegraph_for_target(target: Node, boss: Dictionary, rng: RandomNumberGenerator, requested_count: int, captured_phase: int) -> int:
	var bullets_value: Variant = target.get("enemy_bullets")
	var bullets: Array = bullets_value as Array if bullets_value is Array else []
	var available_slots := maxi(0, EnemySystem.MAX_ENEMY_BULLETS - bullets.size())
	var spawn_count := mini(maxi(0, requested_count), available_slots)
	if spawn_count <= 0:
		return 0
	var boss_pos := Vector2(boss.get("pos", Vector2.ZERO))
	var to_player := Vector2(target.get("player_pos")) - boss_pos
	var to_player_sq := to_player.length_squared()
	var base_dir := to_player / sqrt(to_player_sq) if to_player_sq >= 0.01 else Vector2.RIGHT
	if base_dir.length_squared() < 0.01:
		base_dir = Vector2.RIGHT
	boss["redPenCastDir"] = base_dir
	var spread := RED_PEN_BULLET_SPREAD
	var step := spread / maxf(1.0, float(requested_count - 1))
	var start := -spread * 0.5
	var boss_uid := int(boss.get("uid", -1))
	var cast_serial := int(boss.get("redPenBulletTelegraphCastSerial", 0)) + 1
	boss["redPenBulletTelegraphCastSerial"] = cast_serial
	boss["redPenBulletTelegraphPending"] = true
	boss["redPenBulletTelegraphTimer"] = RED_PEN_BULLET_TELEGRAPH_DURATION
	boss["redPenBulletTelegraphDuration"] = RED_PEN_BULLET_TELEGRAPH_DURATION
	boss["redPenBulletTelegraphCount"] = spawn_count
	boss["redPenBulletTelegraphPhase"] = clampi(captured_phase, 1, 3)
	boss["redPenBulletTelegraphBossUid"] = boss_uid
	var damage := HardModeSystemScript.regular_boss_damage_for_target(target, RED_PEN_BULLET_DAMAGE)
	for shot_index in range(spawn_count):
		# Keep the baseline gameplay-RNG order: jitter first, stored visual phase second.
		var jitter := rng.randf_range(-RED_PEN_BULLET_JITTER, RED_PEN_BULLET_JITTER)
		var phase_seed := rng.randf_range(0.0, TAU)
		var dir := base_dir.rotated(start + step * float(shot_index) + jitter).normalized()
		bullets.append({
			"pos": boss_pos,
			"vel": Vector2.ZERO,
			"life": RED_PEN_BULLET_LIFE,
			"hitRadius": RED_PEN_BULLET_HIT_RADIUS,
			"source": "boss_bullet",
			"sourceKind": BOSS_RED_PEN_REVIEW_CHIEF,
			"sourceUid": boss_uid,
			"attackType": "projectile",
			"damage": damage,
			"visualKind": "red_pen_mark",
			"bossProjectile": true,
			"shieldBlockable": true,
			"erasableByPinkPaint": true,
			"redPenTelegraphPending": true,
			"redPenBossUid": boss_uid,
			"redPenCastSerial": cast_serial,
			"redPenShotIndex": shot_index,
			"redPenShotCount": spawn_count,
			"redPenDirection": dir,
			"redPenPhase": phase_seed,
			"phase": phase_seed,
			"redPenDrawSize": RED_PEN_BULLET_DRAW_SIZE,
			"redPenTrailLength": RED_PEN_BULLET_TRAIL_LENGTH,
			"redPenHitFxDuration": RED_PEN_BULLET_HIT_FX_DURATION
		})
	target.set("enemy_bullets", bullets)
	return spawn_count

static func update_red_pen_bullet_telegraph_for_target(target: Node, boss: Dictionary, delta: float) -> void:
	if not bool(boss.get("redPenBulletTelegraphPending", false)):
		return
	var telegraph_left := maxf(0.0, float(boss.get("redPenBulletTelegraphTimer", RED_PEN_BULLET_TELEGRAPH_DURATION)) - delta)
	boss["redPenBulletTelegraphTimer"] = telegraph_left
	if telegraph_left > 0.0:
		return
	var boss_uid := int(boss.get("uid", -1))
	var cast_serial := int(boss.get("redPenBulletTelegraphCastSerial", 0))
	var boss_pos := Vector2(boss.get("pos", Vector2.ZERO))
	var speed := HardModeSystemScript.regular_boss_projectile_speed_for_target(target, RED_PEN_BULLET_SPEED)
	var bullets_value: Variant = target.get("enemy_bullets")
	var bullets: Array = bullets_value as Array if bullets_value is Array else []
	var launched_directions: Array = []
	for bullet_item in bullets:
		var bullet: Dictionary = bullet_item as Dictionary
		if not bool(bullet.get("redPenTelegraphPending", false)):
			continue
		if int(bullet.get("redPenBossUid", -1)) != boss_uid or int(bullet.get("redPenCastSerial", -1)) != cast_serial:
			continue
		var dir := Vector2(bullet.get("redPenDirection", Vector2.RIGHT))
		if dir.length_squared() < 0.01:
			dir = Vector2.RIGHT
		dir = dir.normalized()
		bullet["redPenTelegraphPending"] = false
		bullet["pos"] = boss_pos + dir * RED_PEN_BULLET_SPAWN_DISTANCE
		bullet["vel"] = dir * speed
		bullet["life"] = RED_PEN_BULLET_LIFE
		launched_directions.append(dir)
	if not launched_directions.is_empty():
		var hit_fx_value: Variant = target.get("hit_fx")
		var hit_fx: Array = hit_fx_value as Array if hit_fx_value is Array else []
		hit_fx.append({
			"kind": "red_pen_launch",
			"pos": boss_pos,
			"directions": launched_directions.duplicate(),
			"count": launched_directions.size(),
			"phase": clampi(int(boss.get("redPenBulletTelegraphPhase", red_pen_review_phase(boss))), 1, 3),
			"redPenBossUid": boss_uid,
			"redPenCastSerial": cast_serial,
			"life": RED_PEN_BULLET_LAUNCH_FX_DURATION,
			"maxLife": RED_PEN_BULLET_LAUNCH_FX_DURATION
		})
		target.set("hit_fx", hit_fx)
	target.set("enemy_bullets", bullets)
	clear_red_pen_bullet_telegraph_state(boss)

static func spawn_red_pen_bullets_for_target(target: Node, boss: Dictionary, rng: RandomNumberGenerator, count: int) -> void:
	# Compatibility entry point: boss red-pen shots now reserve and telegraph
	# before launch, so callers receive the same cap/RNG-safe behavior.
	start_red_pen_bullet_telegraph_for_target(target, boss, rng, count, red_pen_review_phase(boss))

static func spawn_red_pen_review_lines_for_target(target: Node, boss: Dictionary, arena: Rect2, rng: RandomNumberGenerator, count: int) -> void:
	var lines: Array = target.get("boss_guide_lines") as Array
	var boss_pos := Vector2(boss.get("pos", Vector2.ZERO))
	var player_pos := Vector2(target.get("player_pos"))
	var to_player := player_pos - boss_pos
	var to_player_sq := to_player.length_squared()
	var base_dir := to_player / sqrt(to_player_sq) if to_player_sq >= 0.01 else Vector2.RIGHT
	if base_dir.length_squared() < 0.01:
		base_dir = Vector2.RIGHT
	boss["redPenCastDir"] = base_dir
	var length := maxf(arena.size.x, arena.size.y) * 1.55
	var line_count := maxi(1, count)
	var boss_uid := int(boss.get("uid", -1))
	var cast_serial := int(boss.get("redPenReviewCastSerial", 0)) + 1
	boss["redPenReviewCastSerial"] = cast_serial
	for i in range(maxi(1, count)):
		var dir := base_dir.rotated(rng.randf_range(-0.20, 0.20) + (float(i) - float(count - 1) * 0.5) * 0.34).normalized()
		var center := player_pos + dir * rng.randf_range(-70.0, 70.0)
		var saved_side := Vector2(-dir.y, dir.x)
		lines.append({
			"from": center - dir * length * 0.5,
			"to": center + dir * length * 0.5,
			"timer": 0.76,
		"maxTimer": 0.76,
			"flashLife": 0.16,
			"width": RED_PEN_REVIEW_LINE_WIDTH,
			"damage": HardModeSystemScript.regular_boss_damage_for_target(target, RED_PEN_REVIEW_LINE_DAMAGE),
			"visualKind": "red_pen_review",
			"dir": dir,
			"side": saved_side,
			"reviewLineIndex": i,
			"reviewLineCount": line_count,
			"redPenBossUid": boss_uid,
			"reviewCastSerial": cast_serial,
			"phase": rng.randf_range(0.0, TAU),
			"hit": false
		})
	target.set("boss_guide_lines", lines)

static func red_pen_summon_visual_seed(cast_serial: int, summon_index: int, pos: Vector2) -> float:
	var raw_seed := absi(cast_serial * 7919 + (summon_index + 1) * 104729 + int(round(pos.x)) * 31 + int(round(pos.y)) * 37)
	return fposmod(float(raw_seed), 100000.0) / 100000.0 * TAU

static func spawn_red_pen_fix_notes_for_target(target: Node, boss: Dictionary, arena: Rect2, rng: RandomNumberGenerator, count: int) -> Dictionary:
	var boss_pos := Vector2(boss.get("pos", Vector2.ZERO))
	var radius := float(boss.get("radius", 100.0))
	var hit_fx: Array = target.get("hit_fx") as Array
	var summon_count := HardModeSystemScript.regular_boss_summon_count_for_target(target, count)
	var cast_serial := int(boss.get("redPenSummonWarningCastSerial", 0))
	var success_count := 0
	var failed_count := 0
	for i in range(summon_count):
		var angle := rng.randf_range(0.0, TAU)
		var distance := rng.randf_range(radius + 54.0, radius + 150.0)
		var pos := boss_pos + Vector2(cos(angle), sin(angle)) * distance
		pos.x = clampf(pos.x, arena.position.x + 48.0, arena.end.x - 48.0)
		pos.y = clampf(pos.y, arena.position.y + 48.0, arena.end.y - 48.0)
		var uid := EnemySystem.spawn_enemy_for_target(target, "drawing_fix_note", arena, rng, pos, "", "", "", "boss_summon")
		if uid < 0:
			failed_count += 1
			continue
		success_count += 1
		var visual_seed := red_pen_summon_visual_seed(cast_serial, i, pos)
		hit_fx.append({
			"kind": "red_pen_summon_spawn",
			"pos": pos,
			"life": RED_PEN_SUMMON_SPAWN_FX_DURATION,
			"maxLife": RED_PEN_SUMMON_SPAWN_FX_DURATION,
			"redPenBossUid": int(boss.get("uid", -1)),
			"redPenSummonCastSerial": cast_serial,
			"redPenSummonIndex": i,
			"redPenSummonCount": summon_count,
			"visualSeed": visual_seed
		})
		for enemy_item in target.get("enemies") as Array:
			var enemy: Dictionary = enemy_item as Dictionary
			if int(enemy.get("uid", -1)) != uid or String(enemy.get("kind", "")) != "drawing_fix_note":
				continue
			enemy["redPenSummonVisual"] = true
			enemy["redPenSummonPopInTimer"] = RED_PEN_SUMMON_POP_IN_DURATION
			enemy["redPenSummonPopInDuration"] = RED_PEN_SUMMON_POP_IN_DURATION
			enemy["redPenSummonVisualSeed"] = visual_seed
			enemy["redPenSummonVisualVariant"] = posmod(cast_serial + i, 3)
			enemy["redPenSummonVisualOrigin"] = pos
			enemy["redPenSummonCastSerial"] = cast_serial
			enemy["redPenSummonIndex"] = i
			enemy["redPenSummonCount"] = summon_count
			break
	hit_fx.append({
		"kind": "pickup_text",
		"pos": boss_pos + Vector2(-54.0, -radius * 0.92),
		"life": 0.72,
		"maxLife": 0.72,
		"text": "RETAKE!",
		"color": Color("#ff3154")
	})
	target.set("hit_fx", hit_fx)
	return {"attempted": summon_count, "succeeded": success_count, "failed": failed_count}

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
	if boss_id == BOSS_PITCH_POLICE_CHIEF:
		update_pitch_police_chief_for_target(target, boss, delta, arena, rng, chats, toasts, damage_events, comment_event_ids)
		return
	if boss_id == BOSS_RED_PEN_REVIEW_CHIEF:
		update_red_pen_review_chief_for_target(target, boss, delta, arena, rng, chats, comment_event_ids)
		return
	if boss_id == BOSS_COLLAB_CRUSHER:
		if target.has_method("_update_collab_crusher_boss"):
			target.call("_update_collab_crusher_boss", boss, delta, arena)
		return
	if boss_id != BOSS_KUSO_MARO_KING:
		return
	var data: Dictionary = boss_data_for_target(target, String(boss.get("bossId", "")))
	var timers: Dictionary = boss.get("bossAttackTimers", {}) as Dictionary
	for key in timers.keys():
		timers[key] = float(timers[key]) - delta
	prepare_kuso_maro_barrage_telegraph(boss, data, timers, rng)
	prepare_unread_maro_summon_telegraph(target, boss, data, timers, arena, rng)
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

static func prepare_kuso_maro_barrage_telegraph(boss: Dictionary, data: Dictionary, timers: Dictionary, rng: RandomNumberGenerator) -> void:
	if not timers.has(ATTACK_KUSO_MARO_BARRAGE):
		return
	var timer := float(timers[ATTACK_KUSO_MARO_BARRAGE])
	if timer > KUSO_MARO_BARRAGE_TELEGRAPH_DURATION:
		return
	if not boss.has("kusoMaroBarrageStartAngle"):
		boss["kusoMaroBarrageStartAngle"] = rng.randf_range(0.0, TAU)
		boss["kusoMaroBarrageTelegraphCount"] = kuso_maro_barrage_bullet_count(boss, data)
	boss["kusoMaroBarrageTelegraphTimer"] = maxf(0.0, timer)
	boss["kusoMaroBarrageTelegraphDuration"] = KUSO_MARO_BARRAGE_TELEGRAPH_DURATION

static func prepare_unread_maro_summon_telegraph(target: Node, boss: Dictionary, data: Dictionary, timers: Dictionary, arena: Rect2, rng: RandomNumberGenerator) -> void:
	if not timers.has(ATTACK_SUMMON_UNREAD_MARO):
		return
	var timer := float(timers[ATTACK_SUMMON_UNREAD_MARO])
	if timer > UNREAD_MARO_SUMMON_TELEGRAPH_DURATION:
		return
	if not boss.has("unreadMaroSummonTelegraphPositions"):
		var count := unread_maro_summon_count(target, boss, data)
		boss["unreadMaroSummonTelegraphPositions"] = unread_maro_summon_positions(boss, count, arena, rng)
		boss["unreadMaroSummonTelegraphCount"] = count
	boss["unreadMaroSummonTelegraphTimer"] = maxf(0.0, timer)
	boss["unreadMaroSummonTelegraphDuration"] = UNREAD_MARO_SUMMON_TELEGRAPH_DURATION

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
	update_bugged_lag_warp_visual_timers(boss, delta)
	boss["pos"] = EnemySystem.clamp_enemy_pos_to_arena_for_enemy(boss, Vector2(boss.get("pos", Vector2.ZERO)), arena)
	var base_speed: float = float(boss.get("baseSpeed", boss.get("speed", 52.0)))
	var action_delta := HardModeSystemScript.boss_action_delta_for_target(target, boss, delta)
	var state: String = String(boss.get("buggedState", BUGGED_STATE_NORMAL))
	if state == BUGGED_STATE_STUN:
		boss["speed"] = 0.0
		boss["damageTakenRate"] = BUGGED_STUN_DAMAGE_RATE
		boss["hitFlashTimer"] = maxf(float(boss.get("hitFlashTimer", 0.0)), 0.025)
		var stun_left := maxf(0.0, float(boss.get("buggedStateTimer", 0.0)) - delta)
		boss["buggedStateTimer"] = stun_left
		target.set("boss_genre_break_visual_timer", stun_left)
		if stun_left <= 0.0:
			boss["damageTakenRate"] = 1.0
			boss["speed"] = base_speed
			boss["buggedState"] = BUGGED_STATE_NORMAL
			boss["buggedStateTimer"] = bugged_normal_duration(boss, rng)
			boss["speechText"] = "再起動"
			clear_bugged_genre_visual_state_for_target(target)
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
		update_bugged_genre_attacks_for_target(target, boss, action_delta, arena, rng, chats)
		var active_genre := String(target.get("active_genre_event"))
		var state_timer := maxf(0.0, float(boss.get("buggedStateTimer", BUGGED_GENRE_DURATION)) - delta)
		boss["buggedStateTimer"] = state_timer
		if active_genre == "" or state_timer <= 0.0:
			enter_bugged_stun_for_target(target, boss, chats)
		return
	boss["speed"] = base_speed
	if update_bugged_lag_warp_for_target(target, boss, delta, arena):
		return
	update_bugged_normal_attacks_for_target(target, boss, action_delta, delta, arena, rng)
	var normal_left := maxf(0.0, float(boss.get("buggedStateTimer", 0.0)) - action_delta)
	boss["buggedStateTimer"] = normal_left
	if normal_left <= 0.0:
		enter_bugged_genre_telegraph_for_target(target, boss, rng, chats, toasts)

static func enter_bugged_genre_telegraph_for_target(target: Node, boss: Dictionary, rng: RandomNumberGenerator, chats: Array[String], toasts: Array[String]) -> void:
	clear_bugged_spoiler_telegraph(boss)
	clear_bugged_lag_warp_visual_state(boss)
	var genre := choose_bugged_genre(boss, rng)
	boss["buggedTelegraphGenre"] = genre
	boss["buggedState"] = BUGGED_STATE_TELEGRAPH
	boss["buggedStateTimer"] = BUGGED_GENRE_TELEGRAPH
	boss["speechText"] = "次は%s" % bugged_genre_short_label(genre)
	set_bugged_genre_visual_state_for_target(target, genre, "telegraph", boss)
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
	set_bugged_genre_visual_state_for_target(target, genre, "active", boss)

static func enter_bugged_stun_for_target(target: Node, boss: Dictionary, chats: Array[String]) -> void:
	clear_bugged_boss_state_for_target(target)
	clear_bugged_spoiler_telegraph(boss)
	clear_bugged_lag_warp_visual_state(boss)
	boss["buggedState"] = BUGGED_STATE_STUN
	boss["buggedStateTimer"] = BUGGED_STUN_DURATION
	boss["speed"] = 0.0
	boss["damageTakenRate"] = BUGGED_STUN_DAMAGE_RATE
	boss["speechText"] = ""
	set_bugged_genre_visual_state_for_target(target, "", "break", boss)
	target.set("boss_genre_break_visual_timer", BUGGED_STUN_DURATION)
	target.set("boss_genre_break_visual_duration", BUGGED_STUN_DURATION)
	chats.append("バグったラスボスが停止した！")

static func update_bugged_normal_attacks_for_target(target: Node, boss: Dictionary, action_delta: float, frame_delta: float, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var phase: int = bugged_hp_phase(boss)
	var spoiler_was_telegraphing := boss.has("buggedSpoilerTelegraphDirections")
	if spoiler_was_telegraphing:
		var telegraph_left := maxf(0.0, float(boss.get("buggedSpoilerTelegraphTimer", BUGGED_SPOILER_TELEGRAPH_DURATION)) - frame_delta)
		if telegraph_left <= 0.0001:
			telegraph_left = 0.0
		boss["buggedSpoilerTelegraphTimer"] = telegraph_left
		if telegraph_left <= 0.0:
			var directions: Array = boss.get("buggedSpoilerTelegraphDirections", []) as Array
			spawn_bugged_spoiler_bullets_for_target(target, boss, directions)
			clear_bugged_spoiler_telegraph(boss)
	var spoiler_timer := float(boss.get("buggedSpoilerTimer", 1.2)) - action_delta
	if not spoiler_was_telegraphing and spoiler_timer <= 0.0:
		var count := 4 if phase >= 3 else 3
		start_bugged_spoiler_telegraph_for_target(target, boss, rng, count)
		spoiler_timer = bugged_spoiler_interval(phase, rng)
	boss["buggedSpoilerTimer"] = spoiler_timer
	var line_timer := float(boss.get("buggedGuideLineTimer", 3.0)) - action_delta
	if line_timer <= 0.0:
		var count := 2 if phase >= 3 else 1
		spawn_bugged_guide_lines_for_target(target, boss, arena, rng, count, 0.72, 58.0)
		line_timer = rng.randf_range(3.1, 4.1) if phase >= 3 else rng.randf_range(4.0, 5.2)
	boss["buggedGuideLineTimer"] = line_timer
	var warp_timer := float(boss.get("buggedLagWarpTimer", 5.0)) - action_delta
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

static func bugged_spoiler_interval(phase: int, rng: RandomNumberGenerator) -> float:
	return rng.randf_range(1.05, 1.55) if phase >= 3 else rng.randf_range(1.45, 2.15)

static func start_bugged_spoiler_telegraph_for_target(target: Node, boss: Dictionary, rng: RandomNumberGenerator, count: int) -> void:
	var boss_pos := Vector2(boss.get("pos", Vector2.ZERO))
	var to_player := Vector2(target.get("player_pos")) - boss_pos
	var to_player_sq := to_player.length_squared()
	var base_dir := to_player / sqrt(to_player_sq) if to_player_sq >= 0.01 else Vector2.RIGHT
	if base_dir.length_squared() < 0.01:
		base_dir = Vector2.RIGHT
	var directions: Array = []
	for i in range(maxi(1, count)):
		var offset := 0.0
		if count > 1:
			offset = lerpf(-BUGGED_SPOILER_SPREAD, BUGGED_SPOILER_SPREAD, float(i) / float(count - 1))
		var jitter := rng.randf_range(-BUGGED_SPOILER_JITTER, BUGGED_SPOILER_JITTER)
		directions.append(base_dir.rotated(offset + jitter).normalized())
	boss["buggedSpoilerTelegraphDirections"] = directions
	boss["buggedSpoilerTelegraphCount"] = directions.size()
	boss["buggedSpoilerTelegraphTimer"] = BUGGED_SPOILER_TELEGRAPH_DURATION
	boss["buggedSpoilerTelegraphDuration"] = BUGGED_SPOILER_TELEGRAPH_DURATION

static func clear_bugged_spoiler_telegraph(boss: Dictionary) -> void:
	boss.erase("buggedSpoilerTelegraphDirections")
	boss.erase("buggedSpoilerTelegraphCount")
	boss.erase("buggedSpoilerTelegraphTimer")
	boss.erase("buggedSpoilerTelegraphDuration")

static func spawn_bugged_spoiler_bullets_for_target(target: Node, boss: Dictionary, directions: Array) -> void:
	var bullets: Array = target.get("enemy_bullets") as Array
	if bullets.size() >= EnemySystem.MAX_ENEMY_BULLETS:
		return
	var boss_pos := Vector2(boss.get("pos", Vector2.ZERO))
	var spawned_directions: Array = []
	for direction_item in directions:
		if bullets.size() >= EnemySystem.MAX_ENEMY_BULLETS:
			break
		var dir := Vector2(direction_item)
		if dir.length_squared() < 0.01:
			continue
		dir = dir.normalized()
		bullets.append({
			"pos": boss_pos + dir * float(boss.get("radius", 96.0)) * 0.42,
			"vel": dir * HardModeSystemScript.regular_boss_projectile_speed_for_target(target, 250.0),
			"life": 3.4,
			"hitRadius": 17.0,
			"source": "boss_bullet",
			"damage": HardModeSystemScript.regular_boss_damage_for_target(target, 22),
			"visualKind": "bug_spoiler",
			"shieldBlockable": true
		})
		spawned_directions.append(dir)
	target.set("enemy_bullets", bullets)
	append_bugged_spoiler_launch_fx_for_target(target, boss_pos, float(boss.get("radius", 96.0)), spawned_directions)

static func append_bugged_spoiler_launch_fx_for_target(target: Node, pos: Vector2, radius: float, directions: Array) -> void:
	if directions.is_empty():
		return
	var hit_fx: Array = target.get("hit_fx") as Array
	hit_fx.append({
		"kind": "bug_spoiler_launch",
		"pos": pos,
		"radius": radius,
		"directions": directions.duplicate(),
		"count": directions.size(),
		"intensity": 1.14 if directions.size() >= 4 else 1.0,
		"life": BUGGED_SPOILER_LAUNCH_FX_DURATION,
		"maxLife": BUGGED_SPOILER_LAUNCH_FX_DURATION
	})
	target.set("hit_fx", hit_fx)

static func spawn_bugged_boss_pattern_bullets_for_target(target: Node, boss: Dictionary, rng: RandomNumberGenerator) -> void:
	var bullets: Array = target.get("enemy_bullets") as Array
	if bullets.size() >= EnemySystem.MAX_ENEMY_BULLETS:
		return
	var boss_pos := Vector2(boss.get("pos", Vector2.ZERO))
	var to_player := Vector2(target.get("player_pos")) - boss_pos
	var to_player_sq := to_player.length_squared()
	var base_dir := to_player / sqrt(to_player_sq) if to_player_sq >= 0.01 else Vector2.DOWN
	if base_dir.length_squared() < 0.01:
		base_dir = Vector2.DOWN
	for angle in [-0.34, 0.0, 0.34]:
		if bullets.size() >= EnemySystem.MAX_ENEMY_BULLETS:
			break
		var dir := base_dir.rotated(angle + rng.randf_range(-0.02, 0.02)).normalized()
		bullets.append({
			"pos": boss_pos + dir * 52.0,
			"vel": dir * HardModeSystemScript.regular_boss_projectile_speed_for_target(target, 235.0),
			"life": 3.0,
			"hitRadius": 15.0,
			"source": "boss_bullet",
			"damage": HardModeSystemScript.regular_boss_damage_for_target(target, 18),
			"visualKind": "drone_bullet",
			"genreEventOwned": String(target.get("genre_event_source")) == "boss" and String(target.get("active_genre_event")) == "bullet_hell",
			"bossGenreVisual": String(target.get("genre_event_source")) == "boss" and String(target.get("active_genre_event")) == "bullet_hell",
			"shieldBlockable": true
		})
	target.set("enemy_bullets", bullets)

static func start_bugged_lag_warp_for_target(target: Node, boss: Dictionary, arena: Rect2, rng: RandomNumberGenerator) -> void:
	clear_bugged_spoiler_telegraph(boss)
	var player_pos := Vector2(target.get("player_pos"))
	var angle := rng.randf_range(0.0, TAU)
	var distance := rng.randf_range(210.0, 270.0)
	var target_pos := player_pos + Vector2(cos(angle), sin(angle)) * distance
	var radius := float(boss.get("radius", 96.0))
	target_pos.x = clampf(target_pos.x, arena.position.x + radius + 16.0, arena.end.x - radius - 16.0)
	target_pos.y = clampf(target_pos.y, arena.position.y + radius + 16.0, arena.end.y - radius - 16.0)
	var origin := Vector2(boss.get("pos", Vector2.ZERO))
	boss["buggedLagWarpTarget"] = target_pos
	boss["buggedLagWarpOrigin"] = origin
	boss["buggedLagWarpWarning"] = BUGGED_LAG_WARP_WARNING_DURATION
	boss["buggedLagWarpWarningDuration"] = BUGGED_LAG_WARP_WARNING_DURATION
	boss["buggedLagWarpRebuildTimer"] = 0.0
	boss["buggedLagWarpRebuildDuration"] = BUGGED_LAG_WARP_REBUILD_DURATION
	boss["buggedLagWarpOldGhostTimer"] = 0.0
	boss["buggedLagWarpOldGhostDuration"] = BUGGED_LAG_WARP_FRAME_DURATION
	boss["buggedLagWarpVisualSeed"] = fposmod(
		origin.x * 0.013 + origin.y * 0.019 + target_pos.x * 0.023 + target_pos.y * 0.029,
		TAU
	)
	boss["speechText"] = "ラグ発生"

static func update_bugged_lag_warp_for_target(_target: Node, boss: Dictionary, delta: float, _arena: Rect2) -> bool:
	var warning := float(boss.get("buggedLagWarpWarning", 0.0))
	if warning <= 0.0:
		return false
	warning = maxf(0.0, warning - delta)
	boss["buggedLagWarpWarning"] = warning
	boss["speed"] = float(boss.get("baseSpeed", boss.get("speed", 52.0))) * 0.20
	if warning <= 0.0:
		boss["buggedLagWarpOrigin"] = Vector2(boss.get("pos", Vector2.ZERO))
		var next_pos := Vector2(boss.get("buggedLagWarpTarget", boss.get("pos", Vector2.ZERO)))
		boss["pos"] = next_pos
		boss["buggedLagWarpRebuildTimer"] = BUGGED_LAG_WARP_REBUILD_DURATION
		boss["buggedLagWarpOldGhostTimer"] = BUGGED_LAG_WARP_FRAME_DURATION
		boss["speechText"] = ""
	return true

static func update_bugged_lag_warp_visual_timers(boss: Dictionary, delta: float) -> void:
	var rebuild_timer := maxf(0.0, float(boss.get("buggedLagWarpRebuildTimer", 0.0)) - delta)
	var old_ghost_timer := maxf(0.0, float(boss.get("buggedLagWarpOldGhostTimer", 0.0)) - delta)
	boss["buggedLagWarpRebuildTimer"] = rebuild_timer
	boss["buggedLagWarpOldGhostTimer"] = old_ghost_timer

static func clear_bugged_lag_warp_visual_state(boss: Dictionary) -> void:
	boss["buggedLagWarpWarning"] = 0.0
	boss["buggedLagWarpWarningDuration"] = BUGGED_LAG_WARP_WARNING_DURATION
	boss["buggedLagWarpTarget"] = Vector2.ZERO
	boss["buggedLagWarpOrigin"] = Vector2.ZERO
	boss["buggedLagWarpVisualSeed"] = 0.0
	boss["buggedLagWarpRebuildTimer"] = 0.0
	boss["buggedLagWarpRebuildDuration"] = BUGGED_LAG_WARP_REBUILD_DURATION
	boss["buggedLagWarpOldGhostTimer"] = 0.0
	boss["buggedLagWarpOldGhostDuration"] = BUGGED_LAG_WARP_FRAME_DURATION

static func spawn_bugged_guide_lines_for_target(target: Node, boss: Dictionary, arena: Rect2, rng: RandomNumberGenerator, count: int, telegraph: float, width: float) -> void:
	var lines: Array = target.get("boss_guide_lines") as Array
	var boss_pos := Vector2(boss.get("pos", Vector2.ZERO))
	var player_pos := Vector2(target.get("player_pos"))
	var to_player := player_pos - boss_pos
	var to_player_sq := to_player.length_squared()
	var base_dir := to_player / sqrt(to_player_sq) if to_player_sq >= 0.01 else Vector2.RIGHT
	if base_dir.length_squared() < 0.01:
		base_dir = Vector2.RIGHT
	var length := maxf(arena.size.x, arena.size.y) * 1.55
	var line_count := maxi(1, count)
	var cast_directions: Array = []
	for i in range(line_count):
		var dir := base_dir.rotated(rng.randf_range(-0.25, 0.25) + (float(i) - float(count - 1) * 0.5) * 0.28).normalized()
		var center := player_pos + dir * rng.randf_range(-80.0, 72.0)
		var route_phase := fposmod(dir.angle() * 2.37 + center.x * 0.0031 + center.y * 0.0047 + float(i) * 1.91, TAU)
		var route_seed := fposmod(center.x * 0.017 + center.y * 0.013 + dir.angle() * 0.71 + float(i) * 2.57, TAU)
		lines.append({
			"from": center - dir * length * 0.5,
			"to": center + dir * length * 0.5,
			"timer": telegraph,
			"maxTimer": telegraph,
			"flashLife": 0.16,
			"width": width,
			"damage": HardModeSystemScript.regular_boss_damage_for_target(target, DamageSystem.BOSS_ATTACK_DAMAGE),
			"visualKind": "bug_guide",
			"routeIndex": i,
			"routeCount": line_count,
			"phase": route_phase,
			"routeSeed": route_seed,
			"hit": false
		})
		cast_directions.append(dir)
	target.set("boss_guide_lines", lines)
	append_bugged_guide_cast_fx_for_target(target, boss_pos, float(boss.get("radius", 96.0)), base_dir, cast_directions)

static func append_bugged_guide_cast_fx_for_target(target: Node, pos: Vector2, radius: float, base_dir: Vector2, directions: Array) -> void:
	var hit_fx: Array = target.get("hit_fx") as Array
	hit_fx.append({
		"kind": "bug_guide_cast",
		"pos": pos,
		"radius": radius,
		"dir": base_dir,
		"directions": directions.duplicate(),
		"count": directions.size(),
		"phase": fposmod(pos.x * 0.011 + pos.y * 0.017, TAU),
		"life": 0.22,
		"maxLife": 0.22
	})
	target.set("hit_fx", hit_fx)

static func update_guide_lines_for_target(target: Node, delta: float, damage_events: Array, feedback: Dictionary) -> void:
	if target.get("boss_guide_lines") == null:
		return
	var player_pos := Vector2(target.get("player_pos"))
	var kept: Array = []
	var bug_guide_hit_payload: Dictionary = {}
	var bug_guide_collision_count := 0
	var review_line_hit_payload: Dictionary = {}
	var review_line_collision_count := 0
	for item in (target.get("boss_guide_lines") as Array):
		var line: Dictionary = item as Dictionary
		var timer := float(line.get("timer", 0.0)) - delta
		line["timer"] = timer
		if timer <= 0.0 and not bool(line.get("hit", false)):
			line["hit"] = true
			if String(line.get("visualKind", "")) == "red_pen_review":
				feedback["redPenReviewLineHit"] = true
			var from_pos := Vector2(line.get("from", Vector2.ZERO))
			var to_pos := Vector2(line.get("to", Vector2.ZERO))
			var hit_width := float(line.get("width", 58.0)) * 0.5 + 13.0
			if distance_to_segment(player_pos, from_pos, to_pos) <= hit_width:
				damage_events.append({"source": "boss_attack", "damage": int(line.get("damage", DamageSystem.BOSS_ATTACK_DAMAGE))})
				var visual_kind := String(line.get("visualKind", "bug_guide"))
				if visual_kind == "red_pen_review":
					review_line_collision_count += 1
					if review_line_hit_payload.is_empty():
						var review_hit_dir := Vector2(line.get("dir", to_pos - from_pos))
						if review_hit_dir.length_squared() < 0.01:
							review_hit_dir = to_pos - from_pos
						if review_hit_dir.length_squared() < 0.01:
							review_hit_dir = Vector2.RIGHT
						var review_seed := fposmod(
							float(line.get("phase", 0.0))
							+ float(line.get("reviewLineIndex", 0)) * 1.73
							+ float(line.get("reviewCastSerial", 0)) * 0.91
							+ float(line.get("redPenBossUid", -1)) * 0.013,
							TAU
						)
						review_line_hit_payload = {
							"pos": player_pos,
							"dir": review_hit_dir.normalized(),
							"seed": review_seed,
							"redPenBossUid": int(line.get("redPenBossUid", -1)),
							"reviewCastSerial": int(line.get("reviewCastSerial", 0))
						}
				elif visual_kind == "bug_guide":
					bug_guide_collision_count += 1
					if bug_guide_hit_payload.is_empty():
						var hit_dir := to_pos - from_pos
						if hit_dir.length_squared() < 0.01:
							hit_dir = Vector2.RIGHT
						bug_guide_hit_payload = {
							"pos": player_pos,
							"dir": hit_dir.normalized(),
							"seed": float(line.get("routeSeed", line.get("phase", 0.0)))
						}
		if bool(line.get("hit", false)):
			line["flashLife"] = float(line.get("flashLife", 0.16)) - delta
			if float(line.get("flashLife", 0.0)) > 0.0:
				kept.append(line)
		else:
			kept.append(line)
	target.set("boss_guide_lines", kept)
	if not review_line_hit_payload.is_empty():
		var hit_fx: Array = target.get("hit_fx") as Array
		hit_fx.append({
			"kind": "red_pen_review_line_hit",
			"bossAttackId": "review_line",
			"pos": Vector2(review_line_hit_payload.get("pos", player_pos)),
			"dir": Vector2(review_line_hit_payload.get("dir", Vector2.RIGHT)),
			"seed": float(review_line_hit_payload.get("seed", 0.0)),
			"visualSeed": float(review_line_hit_payload.get("seed", 0.0)),
			"simultaneousCount": maxi(1, review_line_collision_count),
			"redPenBossUid": int(review_line_hit_payload.get("redPenBossUid", -1)),
			"reviewCastSerial": int(review_line_hit_payload.get("reviewCastSerial", 0)),
			"life": 0.20,
			"maxLife": 0.20
		})
		target.set("hit_fx", hit_fx)
	if not bug_guide_hit_payload.is_empty():
		append_bugged_guide_player_hit_fx_for_target(target, bug_guide_hit_payload, bug_guide_collision_count)

static func append_bugged_guide_player_hit_fx_for_target(target: Node, payload: Dictionary, collision_count: int) -> void:
	var hit_fx: Array = target.get("hit_fx") as Array
	hit_fx.append({
		"kind": "bug_guide_player_hit",
		"pos": Vector2(payload.get("pos", Vector2.ZERO)),
		"dir": Vector2(payload.get("dir", Vector2.RIGHT)),
		"seed": float(payload.get("seed", 0.0)),
		"simultaneousCount": maxi(1, collision_count),
		"life": 0.14,
		"maxLife": 0.14
	})
	target.set("hit_fx", hit_fx)

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
		start_sticky_maro_floor_telegraph_for_target(target, boss, data, arena, rng)
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

static func kuso_maro_barrage_bullet_count(boss: Dictionary, data: Dictionary) -> int:
	var attack: Dictionary = attack_data(data, ATTACK_KUSO_MARO_BARRAGE)
	return maxi(1, int(heart_variant_value(boss, data, "kusoMaroBulletCount", int(attack.get("bulletCount", 6)))))

static func unread_maro_summon_count(target: Node, boss: Dictionary, data: Dictionary) -> int:
	var attack: Dictionary = attack_data(data, ATTACK_SUMMON_UNREAD_MARO)
	var count := int(heart_variant_value(boss, data, "unreadMaroSummonCount", int(attack.get("summonCount", 2))))
	return HardModeSystemScript.regular_boss_summon_count_for_target(target, count)

static func unread_maro_summon_positions(boss: Dictionary, count: int, arena: Rect2, rng: RandomNumberGenerator) -> Array[Vector2]:
	var positions: Array[Vector2] = []
	var boss_pos := Vector2(boss.get("pos", Vector2.ZERO))
	var base_radius := float(boss.get("radius", 78.0))
	for i in range(maxi(1, count)):
		var angle := rng.randf_range(0.0, TAU) + TAU * float(i) / float(maxi(1, count))
		var distance := rng.randf_range(base_radius + 34.0, base_radius + 110.0)
		var pos := boss_pos + Vector2(cos(angle), sin(angle)) * distance
		pos.x = clampf(pos.x, arena.position.x + 32.0, arena.end.x - 32.0)
		pos.y = clampf(pos.y, arena.position.y + 32.0, arena.end.y - 32.0)
		positions.append(pos)
	return positions

static func spawn_kuso_maro_barrage_for_target(target: Node, boss: Dictionary, data: Dictionary, rng: RandomNumberGenerator) -> void:
	var attack: Dictionary = attack_data(data, ATTACK_KUSO_MARO_BARRAGE)
	var bullet_count: int = kuso_maro_barrage_bullet_count(boss, data)
	var speed: float = float(attack.get("bulletSpeed", 230.0))
	if speed <= 10.0:
		speed *= 78.0
	speed = HardModeSystemScript.regular_boss_projectile_speed_for_target(target, speed)
	var lifetime: float = float(attack.get("bulletLifetime", 4.0))
	var damage: int = HardModeSystemScript.regular_boss_damage_for_target(target, int(attack.get("damage", DamageSystem.BOSS_ATTACK_DAMAGE)))
	var boss_pos: Vector2 = Vector2(boss.get("pos", Vector2.ZERO))
	var radius: float = float(boss.get("radius", 78.0))
	var bullets: Array = target.get("enemy_bullets") as Array
	var start_angle: float
	if boss.has("kusoMaroBarrageStartAngle"):
		start_angle = float(boss["kusoMaroBarrageStartAngle"])
	else:
		start_angle = rng.randf_range(0.0, TAU)
	var visual_rng := RandomNumberGenerator.new()
	var visual_seed := absi(int(round(start_angle * 1000000.0)) + int(round(boss_pos.x * 101.0)) * 31 + int(round(boss_pos.y * 103.0)) * 37 + bullet_count * 7919)
	visual_rng.seed = maxi(1, visual_seed)
	var first_spin_direction := -1.0 if visual_rng.randi_range(0, 1) == 0 else 1.0
	for i in range(maxi(1, bullet_count)):
		var angle: float = start_angle + TAU * float(i) / float(maxi(1, bullet_count))
		var dir: Vector2 = Vector2(cos(angle), sin(angle))
		var spin_direction := first_spin_direction if i % 2 == 0 else -first_spin_direction
		bullets.append({
			"pos": boss_pos + dir * radius * 0.42,
			"vel": dir * speed,
			"life": lifetime,
			"hitRadius": 19.0,
			"source": "boss_bullet",
			"damage": damage,
			"visualKind": "kuso_maro",
			"visualRotation": visual_rng.randf_range(0.0, TAU),
			"visualSpinSpeed": deg_to_rad(KUSO_MARO_PROJECTILE_SPIN_SPEED_DEG) * spin_direction,
			"shieldBlockable": true
		})
	target.set("enemy_bullets", bullets)
	append_kuso_maro_barrage_launch_fx_for_target(target, boss_pos, radius, start_angle, bullet_count)
	boss.erase("kusoMaroBarrageStartAngle")
	boss.erase("kusoMaroBarrageTelegraphCount")
	boss.erase("kusoMaroBarrageTelegraphTimer")
	boss.erase("kusoMaroBarrageTelegraphDuration")

static func append_kuso_maro_barrage_launch_fx_for_target(target: Node, pos: Vector2, radius: float, start_angle: float, count: int) -> void:
	var hit_fx: Array = target.get("hit_fx") as Array
	hit_fx.append({
		"kind": "kuso_maro_launch",
		"pos": pos,
		"radius": radius,
		"startAngle": start_angle,
		"count": maxi(1, count),
		"life": KUSO_MARO_BARRAGE_LAUNCH_FX_DURATION,
		"maxLife": KUSO_MARO_BARRAGE_LAUNCH_FX_DURATION
	})
	target.set("hit_fx", hit_fx)

static func spawn_unread_maro_adds_for_target(target: Node, boss: Dictionary, data: Dictionary, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var summon_count := unread_maro_summon_count(target, boss, data)
	var positions: Array = boss.get("unreadMaroSummonTelegraphPositions", []) as Array
	if positions.size() != summon_count:
		positions = unread_maro_summon_positions(boss, summon_count, arena, rng)
	for i in range(summon_count):
		spawn_unread_maro_for_target(target, Vector2(positions[i]), arena, rng, i, summon_count)
	boss.erase("unreadMaroSummonTelegraphPositions")
	boss.erase("unreadMaroSummonTelegraphCount")
	boss.erase("unreadMaroSummonTelegraphTimer")
	boss.erase("unreadMaroSummonTelegraphDuration")

static func spawn_unread_maro_for_target(target: Node, pos: Vector2, arena: Rect2, rng: RandomNumberGenerator, summon_index: int = 0, summon_count: int = 1) -> void:
	var speech_text: String = "読んで" if rng.randf() < 0.5 else "未読です"
	var uid := EnemySystem.spawn_enemy_for_target(target, "unread_maro", arena, rng, pos, "", "", "", "boss_summon")
	if uid < 0:
		return
	for item in target.get("enemies") as Array:
		var enemy: Dictionary = item as Dictionary
		if int(enemy.get("uid", -1)) == uid:
			enemy["speechText"] = speech_text
			enemy["unreadMaroPopInTimer"] = UNREAD_MARO_POP_IN_DURATION
			enemy["unreadMaroPopInDuration"] = UNREAD_MARO_POP_IN_DURATION
			enemy["unreadMaroSpeechDelayTimer"] = UNREAD_MARO_SPEECH_DELAY + float(mini(2, summon_index)) * UNREAD_MARO_SPEECH_STAGGER
			enemy["unreadMaroSpeechOffsetY"] = unread_maro_speech_offset_for_index(summon_index, summon_count)
			enemy["unreadMaroSummonIndex"] = summon_index
			return

static func unread_maro_speech_offset_for_index(index: int, count: int) -> float:
	if count <= 1 or index <= 0:
		return 0.0
	return -12.0 if index % 3 == 1 else 12.0

static func start_sticky_maro_floor_telegraph_for_target(target: Node, boss: Dictionary, data: Dictionary, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var attack: Dictionary = attack_data(data, ATTACK_STICKY_MARO_FLOOR)
	var field_count: int = int(attack.get("fieldCount", 2))
	var duration: float = float(heart_variant_value(boss, data, "stickyFloorDuration", float(attack.get("duration", 6.0))))
	var slow_rate: float = clampf(float(attack.get("slowRate", 0.4)), 0.0, 0.85)
	var radius: float = float(attack.get("radius", 1.6))
	if radius <= 10.0:
		radius *= 60.0
	var positions := sticky_maro_floor_positions_for_target(target, boss, maxi(1, field_count), radius, arena, rng)
	var telegraphs: Array = target.get("boss_slow_field_telegraphs") as Array
	telegraphs.append({
		"positions": positions,
		"timer": STICKY_MARO_FLOOR_TELEGRAPH_DURATION,
		"maxTimer": STICKY_MARO_FLOOR_TELEGRAPH_DURATION,
		"radius": radius,
		"duration": duration,
		"slowRate": slow_rate
	})
	target.set("boss_slow_field_telegraphs", telegraphs)

static func sticky_maro_floor_positions_for_target(target: Node, boss: Dictionary, field_count: int, radius: float, arena: Rect2, rng: RandomNumberGenerator) -> Array[Vector2]:
	var positions: Array[Vector2] = []
	var player_pos: Vector2 = Vector2(target.get("player_pos"))
	var boss_pos: Vector2 = Vector2(boss.get("pos", Vector2.ZERO))
	for i in range(field_count):
		var origin: Vector2 = player_pos if i == 0 else boss_pos
		var angle: float = rng.randf_range(0.0, TAU)
		var distance: float = rng.randf_range(26.0, 135.0)
		var pos: Vector2 = origin + Vector2(cos(angle), sin(angle)) * distance
		pos.x = clampf(pos.x, arena.position.x + radius, arena.end.x - radius)
		pos.y = clampf(pos.y, arena.position.y + radius, arena.end.y - radius)
		positions.append(pos)
	return positions

static func update_sticky_maro_floor_telegraphs_for_target(target: Node, delta: float) -> void:
	if target.get("boss_slow_field_telegraphs") == null:
		return
	var remaining: Array = []
	for item in (target.get("boss_slow_field_telegraphs") as Array):
		var telegraph: Dictionary = item as Dictionary
		telegraph["timer"] = float(telegraph.get("timer", 0.0)) - delta
		if float(telegraph["timer"]) <= 0.0:
			materialize_sticky_maro_floor_for_target(target, telegraph)
		else:
			remaining.append(telegraph)
	target.set("boss_slow_field_telegraphs", remaining)

static func materialize_sticky_maro_floor_for_target(target: Node, telegraph: Dictionary) -> void:
	var fields: Array = target.get("boss_slow_fields") as Array
	var positions: Array = telegraph.get("positions", []) as Array
	var radius := float(telegraph.get("radius", 96.0))
	var duration := float(telegraph.get("duration", 6.0))
	var slow_rate := float(telegraph.get("slowRate", 0.4))
	for i in range(positions.size()):
		var pos := Vector2(positions[i])
		fields.append({
			"pos": pos,
			"radius": radius,
			"life": duration,
			"maxLife": duration,
			"slowRate": slow_rate,
			"visualKind": "sticky_maro",
			"formationTimer": STICKY_MARO_FLOOR_FORMATION_DURATION,
			"formationDuration": STICKY_MARO_FLOOR_FORMATION_DURATION,
			"fadeDuration": STICKY_MARO_FLOOR_FADE_DURATION,
			"visualSeed": pos.x * 0.013 + pos.y * 0.017 + float(i) * 1.73
		})
	target.set("boss_slow_fields", fields)

static func update_slow_fields_for_target(target: Node, delta: float) -> void:
	if target.get("boss_slow_fields") == null:
		return
	var result: Array = []
	for item in (target.get("boss_slow_fields") as Array):
		var field: Dictionary = item as Dictionary
		field["life"] = float(field.get("life", 0.0)) - delta
		if field.has("formationTimer"):
			field["formationTimer"] = maxf(0.0, float(field.get("formationTimer", 0.0)) - delta)
		if float(field["life"]) > 0.0:
			result.append(field)
	target.set("boss_slow_fields", result)

static func update_sticky_maro_floor_fx_for_target(target: Node, delta: float) -> void:
	if target.get("boss_slow_field_fx") == null:
		return
	var remaining: Array = []
	for item in (target.get("boss_slow_field_fx") as Array):
		var fx: Dictionary = item as Dictionary
		fx["life"] = float(fx.get("life", 0.0)) - delta
		if float(fx["life"]) > 0.0:
			remaining.append(fx)
	target.set("boss_slow_field_fx", remaining)

static func update_sticky_maro_player_feedback_for_target(target: Node) -> void:
	if target.get("boss_slow_fields") == null:
		return
	var player_pos := Vector2(target.get("player_pos"))
	var inside := false
	var nearest_field_pos := player_pos + Vector2.DOWN
	var nearest_distance_sq := INF
	for item in (target.get("boss_slow_fields") as Array):
		var field: Dictionary = item as Dictionary
		if String(field.get("visualKind", "")) != "sticky_maro" or float(field.get("life", 0.0)) <= 0.0:
			continue
		var field_pos := Vector2(field.get("pos", Vector2.ZERO))
		var contact_radius := float(field.get("radius", 0.0)) + STICKY_MARO_PLAYER_RADIUS
		var distance_sq := player_pos.distance_squared_to(field_pos)
		if distance_sq <= contact_radius * contact_radius:
			inside = true
			if distance_sq < nearest_distance_sq:
				nearest_distance_sq = distance_sq
				nearest_field_pos = field_pos
	var was_inside := bool(target.get("boss_slow_field_player_inside"))
	if inside != was_inside:
		append_sticky_maro_contact_fx_for_target(target, inside, player_pos, nearest_field_pos)
	target.set("boss_slow_field_player_inside", inside)

static func append_sticky_maro_contact_fx_for_target(target: Node, entering: bool, player_pos: Vector2, field_pos: Vector2) -> void:
	if target.get("boss_slow_field_fx") == null:
		return
	var direction := field_pos - player_pos
	if direction.length_squared() <= 0.01:
		direction = Vector2.DOWN
	else:
		direction = direction.normalized()
	var duration := STICKY_MARO_ENTRY_FX_DURATION if entering else STICKY_MARO_EXIT_FX_DURATION
	var fx: Array = target.get("boss_slow_field_fx") as Array
	fx.append({
		"kind": "sticky_maro_enter" if entering else "sticky_maro_exit",
		"pos": player_pos + Vector2(0.0, 20.0),
		"dir": direction,
		"life": duration,
		"maxLife": duration,
		"seed": player_pos.x * 0.019 + player_pos.y * 0.023
	})
	target.set("boss_slow_field_fx", fx)

static func clear_sticky_maro_floor_visual_state_for_target(target: Node) -> void:
	if target.get("boss_slow_field_telegraphs") != null:
		(target.get("boss_slow_field_telegraphs") as Array).clear()
	if target.get("boss_slow_field_fx") != null:
		(target.get("boss_slow_field_fx") as Array).clear()
	target.set("boss_slow_field_player_inside", false)

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
		if pos.distance_squared_to(player_pos) < 115600.0:
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
		var score := candidate.distance_squared_to(player_pos)
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
	var walls: Array = DrawDataSystem.static_wall_rects_for_target(target)
	var effect_walls_value: Variant = target.get("effect_walls")
	if effect_walls_value is Array:
		for wall in (effect_walls_value as Array):
			walls.append(wall as Rect2)
	return walls
