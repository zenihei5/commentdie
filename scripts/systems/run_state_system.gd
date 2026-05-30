class_name RunStateSystem
extends RefCounted

static func initial_values(character: Dictionary, weapon: Dictionary, stats: Dictionary, resources: Dictionary) -> Dictionary:
	var max_hp: int = int(stats.get("hp", character.get("initialHp", 5)))
	var move_speed: float = WeaponSystem.scaled_move_speed(float(stats.get("moveSpeed", character.get("moveSpeed", 5.0))))
	var weapon_range: float = WeaponSystem.range_base(weapon)
	var weapon_interval: float = WeaponSystem.attack_interval(weapon, 0.85)
	var pickup_rate: float = float(stats.get("pickupRange", 1.0))
	return {
		"playerPos": Vector2(580, 570),
		"playerVel": Vector2.ZERO,
		"playerMaxHp": max_hp,
		"playerHp": max_hp,
		"playerSpeed": move_speed,
		"hammerDamage": float(weapon.get("damage", 12.0)),
		"hammerRange": weapon_range,
		"hammerInterval": weapon_interval,
		"magnetRange": float(weapon.get("magnetRange", 95.0)) * pickup_rate,
		"dashCooldown": float(stats.get("dashCooldown", character.get("dashCooldown", 1.2))),
		"knockbackPower": WeaponSystem.scaled_knockback(float(weapon.get("knockback", 18.0))),
		"invincibleTime": float(stats.get("invincibleTime", 0.7)),
		"ngStock": clampi(int(resources.get("ngTickets", character.get("initialNgStock", 0))), 0, 3),
		"heartStock": clampi(int(resources.get("heartStock", character.get("initialHeartStock", 0))), 0, 3),
		"giftHype": clampi(int(resources.get("giftHype", 0)), 0, 100)
	}

static func gift_flags() -> Dictionary:
	return {
		"passiveScoreRate": 1.0,
		"passiveMaroGoodRate": 1.0,
		"passiveMaroPickupRate": 1.0,
		"likeScoreLevel": 0,
		"moderatorLevel": 0,
		"reentryBarrierLevel": 0,
		"reviveAvailable": false,
		"clipConfirmed": false,
		"expVacuumExtreme": false,
		"expVacuumTimer": 0.0,
		"zeroTauntResist": false,
		"commentBoost": false,
		"choiceTimeBonus": 0.0,
		"choiceTimePenalty": 0.0,
		"flameMarketing": false,
		"yesListener": false,
		"sweetToothLevel": 0,
		"maroMagnetRange": 0.0,
		"readManagerLevel": 0,
		"maroAppraisal": false,
		"blockFunctionStock": 0,
		"steelMentalLevel": 0,
		"superchatLevel": 0,
		"boomerangLevel": 0,
		"burnResistCharges": 0,
		"clipBonusLevel": 0,
		"heartUsedCount": 0
	}

static func timers() -> Dictionary:
	return {
		"elapsed": 0.0,
		"commentTimer": 15.0,
		"commentWarningStep": 0,
		"effectTimer": 0.0,
		"spawnTimer": 0.2,
		"attackTimer": 0.25,
		"superchatTimer": 0.4,
		"nextMallowTime": 30.0,
		"stopTimer": 0.0,
		"muteTimer": 0.0,
		"toastText": "",
		"toastTimer": 0.0,
		"kusoChatTimer": 0.0,
		"attackJitterTimer": 0.0,
		"moveSlowTimer": 0.0,
		"spawnRateTimer": 0.0,
		"supportAttackTimer": 0.0
	}

static func score_state(initial_gift_hype: int) -> Dictionary:
	return {
		"score": 0,
		"kills": 0,
		"expLevel": 1,
		"expValue": 0,
		"giftHype": initial_gift_hype,
		"giftsTaken": 0,
		"multiplier": 1.0,
		"maxMultiplier": 1.0,
		"burnCombo": 0,
		"burnComboMax": 0,
		"currentComment": "なし",
		"currentDeathText": "発動中の指示コメなし",
		"activeCommentHurt": false,
		"pendingClearHype": 0,
		"dangerCommentsChosen": 0,
		"maxGiftHype": initial_gift_hype,
		"runRank": "D"
	}

static func marshmallow_state() -> Dictionary:
	return {
		"answered": 0,
		"unread": 0,
		"good": 0,
		"god": 0,
		"kuso": 0,
		"lastType": "なし",
		"lastWasKuso": false
	}

static func genre_state() -> Dictionary:
	return {
		"nextGenreEventTime": 35.0,
		"genreEventTimer": 0.0,
		"activeGenreEvent": "",
		"nextKnownGenreEvent": "",
		"genreEventHurt": false,
		"genreRaceMoveTimer": 0.0,
		"genreBulletTimer": 0.0,
		"genreEventCount": 0,
		"raceEventCount": 0,
		"bulletHellEventCount": 0,
		"horrorEventCount": 0,
		"genreEventClearCount": 0,
		"strategyWiki": false,
		"firstPlayAdapt": false,
		"streamingSkillLevel": 0,
		"kusogeResistLevel": 0
	}

static func apply_initial_values(target: Node, initial: Dictionary) -> void:
	target.set("player_pos", initial["playerPos"] as Vector2)
	target.set("player_vel", initial["playerVel"] as Vector2)
	target.set("player_max_hp", int(initial["playerMaxHp"]))
	target.set("player_hp", int(initial["playerHp"]))
	target.set("player_speed", float(initial["playerSpeed"]))
	target.set("dash_cd", 0.0)
	target.set("invincible", 0.0)
	target.set("debug_invincible", false)
	target.set("hammer_damage", float(initial["hammerDamage"]))
	target.set("hammer_range", float(initial["hammerRange"]))
	target.set("hammer_interval", float(initial["hammerInterval"]))
	target.set("magnet_range", float(initial["magnetRange"]))
	target.set("dash_cooldown", float(initial["dashCooldown"]))
	target.set("knockback_power", float(initial["knockbackPower"]))
	target.set("player_base_invincible_time", float(initial["invincibleTime"]))
	target.set("ng_stock", int(initial["ngStock"]))
	target.set("heart_stock", int(initial["heartStock"]))

static func apply_gift_flags(target: Node, defaults: Dictionary) -> void:
	target.set("passive_score_rate", float(defaults["passiveScoreRate"]))
	target.set("passive_maro_good_rate", float(defaults["passiveMaroGoodRate"]))
	target.set("passive_maro_pickup_rate", float(defaults["passiveMaroPickupRate"]))
	target.set("like_score_level", int(defaults["likeScoreLevel"]))
	target.set("moderator_level", int(defaults["moderatorLevel"]))
	target.set("reentry_barrier_level", int(defaults["reentryBarrierLevel"]))
	target.set("revive_available", bool(defaults["reviveAvailable"]))
	target.set("clip_confirmed", bool(defaults["clipConfirmed"]))
	target.set("exp_vacuum_extreme", bool(defaults["expVacuumExtreme"]))
	target.set("exp_vacuum_timer", float(defaults["expVacuumTimer"]))
	target.set("zero_taunt_resist", bool(defaults["zeroTauntResist"]))
	target.set("comment_boost", bool(defaults["commentBoost"]))
	target.set("choice_time_bonus", float(defaults["choiceTimeBonus"]))
	target.set("choice_time_penalty", float(defaults["choiceTimePenalty"]))
	target.set("flame_marketing", bool(defaults["flameMarketing"]))
	target.set("yes_listener", bool(defaults["yesListener"]))
	target.set("sweet_tooth_level", int(defaults["sweetToothLevel"]))
	target.set("maro_magnet_range", float(defaults["maroMagnetRange"]))
	target.set("read_manager_level", int(defaults["readManagerLevel"]))
	target.set("maro_appraisal", bool(defaults["maroAppraisal"]))
	target.set("block_function_stock", int(defaults["blockFunctionStock"]))
	target.set("steel_mental_level", int(defaults["steelMentalLevel"]))
	target.set("superchat_level", int(defaults["superchatLevel"]))
	target.set("boomerang_level", int(defaults["boomerangLevel"]))
	target.set("burn_resist_charges", int(defaults["burnResistCharges"]))
	target.set("clip_bonus_level", int(defaults["clipBonusLevel"]))
	target.set("heart_used_count", int(defaults["heartUsedCount"]))

static func apply_timers(target: Node, defaults: Dictionary) -> void:
	target.set("elapsed", float(defaults["elapsed"]))
	target.set("comment_timer", float(defaults["commentTimer"]))
	target.set("comment_warning_step", int(defaults["commentWarningStep"]))
	target.set("effect_timer", float(defaults["effectTimer"]))
	target.set("spawn_timer", float(defaults["spawnTimer"]))
	target.set("attack_timer", float(defaults["attackTimer"]))
	target.set("superchat_timer", float(defaults["superchatTimer"]))
	target.set("next_mallow_time", float(defaults["nextMallowTime"]))
	target.set("stop_timer", float(defaults["stopTimer"]))
	target.set("mute_timer", float(defaults["muteTimer"]))
	target.set("toast_text", String(defaults["toastText"]))
	target.set("toast_timer", float(defaults["toastTimer"]))
	target.set("kuso_chat_timer", float(defaults["kusoChatTimer"]))
	target.set("attack_jitter_timer", float(defaults["attackJitterTimer"]))
	target.set("move_slow_timer", float(defaults["moveSlowTimer"]))
	target.set("spawn_rate_timer", float(defaults["spawnRateTimer"]))
	target.set("support_attack_timer", float(defaults["supportAttackTimer"]))

static func apply_score_state(target: Node, defaults: Dictionary) -> void:
	target.set("score", int(defaults["score"]))
	target.set("kills", int(defaults["kills"]))
	target.set("exp_level", int(defaults["expLevel"]))
	target.set("exp_value", int(defaults["expValue"]))
	target.set("gift_hype", int(defaults["giftHype"]))
	target.set("gifts_taken", int(defaults["giftsTaken"]))
	target.set("multiplier", float(defaults["multiplier"]))
	target.set("max_multiplier", float(defaults["maxMultiplier"]))
	target.set("burn_combo", int(defaults["burnCombo"]))
	target.set("burn_combo_max", int(defaults["burnComboMax"]))
	target.set("current_comment", String(defaults["currentComment"]))
	target.set("current_death_text", String(defaults["currentDeathText"]))
	target.set("active_comment_hurt", bool(defaults["activeCommentHurt"]))
	target.set("pending_clear_hype", int(defaults["pendingClearHype"]))
	target.set("danger_comments_chosen", int(defaults["dangerCommentsChosen"]))
	target.set("max_gift_hype", int(defaults["maxGiftHype"]))
	target.set("run_rank", String(defaults["runRank"]))

static func apply_marshmallow_state(target: Node, defaults: Dictionary) -> void:
	target.set("marshmallow_answered", int(defaults["answered"]))
	target.set("marshmallow_unread", int(defaults["unread"]))
	target.set("marshmallow_good", int(defaults["good"]))
	target.set("marshmallow_god", int(defaults["god"]))
	target.set("marshmallow_kuso", int(defaults["kuso"]))
	target.set("last_maro_type", String(defaults["lastType"]))
	target.set("last_maro_was_kuso", bool(defaults["lastWasKuso"]))

static func apply_genre_state(target: Node, defaults: Dictionary) -> void:
	target.set("next_genre_event_time", float(defaults["nextGenreEventTime"]))
	target.set("genre_event_timer", float(defaults["genreEventTimer"]))
	target.set("active_genre_event", String(defaults["activeGenreEvent"]))
	target.set("next_known_genre_event", String(defaults["nextKnownGenreEvent"]))
	target.set("genre_event_hurt", bool(defaults["genreEventHurt"]))
	target.set("genre_race_move_timer", float(defaults["genreRaceMoveTimer"]))
	target.set("genre_bullet_timer", float(defaults["genreBulletTimer"]))
	target.set("genre_event_count", int(defaults["genreEventCount"]))
	target.set("race_event_count", int(defaults["raceEventCount"]))
	target.set("bullet_hell_event_count", int(defaults["bulletHellEventCount"]))
	target.set("horror_event_count", int(defaults["horrorEventCount"]))
	target.set("genre_event_clear_count", int(defaults["genreEventClearCount"]))
	target.set("strategy_wiki", bool(defaults["strategyWiki"]))
	target.set("first_play_adapt", bool(defaults["firstPlayAdapt"]))
	target.set("streaming_skill_level", int(defaults["streamingSkillLevel"]))
	target.set("kusoge_resist_level", int(defaults["kusogeResistLevel"]))

static func clear_run_collections(target: Node) -> void:
	(target.get("taken_gift_names") as Array).clear()
	(target.get("enemies") as Array).clear()
	target.set("next_enemy_uid", 1)
	(target.get("enemy_bullets") as Array).clear()
	(target.get("exp_orbs") as Array).clear()
	(target.get("player_bullets") as Array).clear()
	(target.get("boomerang_hits") as Dictionary).clear()
	(target.get("hit_fx") as Array).clear()
	(target.get("active_effects") as Array).clear()
	(target.get("active_effect_rates") as Dictionary).clear()

static func clear_stage_effect_collections(target: Node) -> void:
	(target.get("effect_walls") as Array).clear()
	(target.get("effect_pits") as Array).clear()

static func reset_run_ui(result_panel: Control, choice_box: Control, heart_cards: Array, chat_lines: Array) -> void:
	result_panel.visible = false
	choice_box.visible = false
	heart_cards.clear()
	chat_lines.clear()
