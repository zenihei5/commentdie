class_name RunStateSystem
extends RefCounted

const PowerUpEffectProviderScript := preload("res://scripts/systems/power_up_effect_provider.gd")

const MapBackgroundSystemScript := preload("res://scripts/systems/map_background_system.gd")
const GenreEventSystemScript := preload("res://scripts/systems/genre_event_system.gd")
const ExpSystemScript := preload("res://scripts/systems/exp_system.gd")

static func run_length(quick_test_mode: bool, quick_length: float, normal_length: float) -> float:
	return quick_length if quick_test_mode else normal_length

static func load_boot_data_for_target(target: Node, sprite_cache: Dictionary) -> DataRepository:
	var repository: DataRepository = DataRepository.loaded()
	repository.apply_to_target(target)
	StreamFrameSystem.load_progress_for_target(target)
	StreamFrameSystem.apply_selected_frame_for_target(
		target,
		target.get("stream_frames") as Array,
		String(target.get("current_stream_frame_id"))
	)
	CharacterSystem.apply_selected_character_for_target(
		target,
		target.get("characters") as Array,
		target.get("weapons") as Array,
		String(target.get("current_character_id")),
		sprite_cache
	)
	SettingsSystem.load_for_target(target)
	return repository

static func initial_values(character: Dictionary, weapon: Dictionary, stats: Dictionary, resources: Dictionary, start_arena: Rect2 = Rect2(), snapshot = null) -> Dictionary:
	var max_hp: int = _scaled_player_hp(int(stats.get("hp", character.get("initialHp", 100))))
	var move_speed: float = WeaponSystem.scaled_move_speed(float(stats.get("moveSpeed", character.get("moveSpeed", 5.0)))) * CharacterSystem.move_speed_multiplier(character)
	var weapon_range: float = WeaponSystem.range_base(weapon)
	var weapon_interval: float = WeaponSystem.attack_interval(weapon, 0.85)
	var pickup_rate: float = float(stats.get("pickupRange", 1.0))
	var hammer_damage: float = float(weapon.get("damage", 12.0))
	var magnet_range: float = float(weapon.get("magnetRange", 95.0)) * pickup_rate
	if snapshot != null:
		max_hp = PowerUpEffectProviderScript.max_hp(max_hp, snapshot)
		move_speed = PowerUpEffectProviderScript.move_speed(move_speed, snapshot)
		hammer_damage = PowerUpEffectProviderScript.damage(hammer_damage, snapshot)
		weapon_interval = WeaponSystem.player_attack_interval(weapon_interval, float(snapshot.attack_interval_multiplier))
		magnet_range = PowerUpEffectProviderScript.normal_attract_radius(magnet_range, snapshot)
	if start_arena.size == Vector2.ZERO:
		start_arena = MapBackgroundSystemScript.zatsudan_world_rect()
	var start_pos: Vector2 = start_arena.get_center()
	return {
		"playerPos": start_pos,
		"playerVel": Vector2.ZERO,
		"playerMaxHp": max_hp,
		"playerHp": max_hp,
		"playerSpeed": move_speed,
		"characterAttackMultiplier": CharacterSystem.attack_multiplier(character),
		"hammerDamage": hammer_damage,
		"hammerRange": weapon_range,
		"hammerInterval": weapon_interval,
		"magnetRange": magnet_range,
		"dashCooldown": float(stats.get("dashCooldown", character.get("dashCooldown", 1.2))),
		"knockbackPower": WeaponSystem.scaled_knockback(float(weapon.get("knockback", 18.0))),
		"invincibleTime": float(stats.get("invincibleTime", 0.7)),
		"ngStock": 0,
		"heartStock": clampi(int(resources.get("heartStock", character.get("initialHeartStock", 0))), 0, 3),
		"giftHype": clampi(int(resources.get("giftHype", 0)), 0, 100)
	}

static func _scaled_player_hp(value: int) -> int:
	if value <= 10:
		return maxi(1, value * 20)
	return value

static func gift_flags(snapshot = null) -> Dictionary:
	var initial_buzz_keep := 0
	var initial_gift_reroll := 0
	if snapshot != null and bool(snapshot.enabled):
		initial_buzz_keep = maxi(0, int(snapshot.initial_buzz_keep_charges))
		initial_gift_reroll = maxi(0, int(snapshot.initial_gift_reroll_count))
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
		"mentalCareLevel": 0,
		"notificationBellLevel": 0,
		"expBonusRemainder": 0.0,
		"commentRadarLevel": 0,
		"commentRadarRangeBonus": 0.0,
		"itemMagnetSpeedRate": 1.0,
		"commentRadarFxTimer": 0.0,
		"miniHumidifierLevel": 0,
		"miniHumidifierTimer": 0.0,
		"miniHumidifierHurtCooldown": 0.0,
		"equipmentDamageRate": 1.0,
		"equipmentRangeRate": 1.0,
		"equipmentIntervalRate": 1.0,
		"equipmentBulletSupportLevel": 0,
		"superchatLevel": 0,
		"boomerangLevel": 0,
		"burnResistCharges": initial_buzz_keep,
		"giftRerollRemaining": initial_gift_reroll,
		"clipBonusLevel": 0,
		"heartPending": false,
		"heartUsedCount": 0,
		"ngUsedCount": 0
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
		"nextGenreEventTime": GenreEventSystemScript.FIRST_GENRE_EVENT_TIME,
		"genreEventTimer": 0.0,
		"genreEventDuration": GenreEventSystemScript.GENRE_EVENT_DURATION,
		"genreEventSource": "",
		"activeGenreEvent": "",
		"nextKnownGenreEvent": "",
		"genreEventHurt": false,
		"genreRaceMoveTimer": 0.0,
		"genreBulletTimer": 0.0,
		"genreRaceDashBoostTimer": 0.0,
		"genreStgShotTimer": 0.0,
		"genreStgSpawnTimer": 0.0,
		"genreStgLastDir": Vector2.RIGHT,
		"genreResultCoinCount": 0,
		"genreResultDashPadCount": 0,
		"genreEventStartKills": 0,
		"genreResultStgShotKillCount": 0,
		"genreResultFakeGiftDefeatCount": 0,
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

static func start_run_for_target(target: Node, character: Dictionary, weapon: Dictionary, stats: Dictionary, resources: Dictionary) -> Dictionary:
	var frame_id := String(target.get("current_stream_frame_id"))
	var map_data := MapBackgroundSystemScript.background_data_for_stream_frame(frame_id)
	var initial: Dictionary = initial_values(character, weapon, stats, resources, MapBackgroundSystemScript.world_rect(map_data), target.get("permanent_upgrade_snapshot"))
	apply_initial_values(target, initial)
	apply_gift_flags(target, gift_flags(target.get("permanent_upgrade_snapshot")))
	clear_run_collections(target)
	apply_timers(target, timers())
	(target.get("marshmallows") as Array).clear()
	apply_score_state(target, score_state(int(initial["giftHype"])))
	reset_comment_state_for_target(target, false)
	target.set("pending_gift_choices", 0)
	target.set("pending_gift_requests", [])
	target.set("active_gift_request", {})
	target.set("gift_request_serial", 0)
	target.set("gift_debug_last", {})
	target.set("gift_choice_delay_timer", 0.0)
	target.set("do_everything_offer_count", 0)
	apply_marshmallow_state(target, marshmallow_state())
	target.set("player_weapons", EquipmentSystem.initial_weapons(String(weapon.get("id", "ban_hammer"))))
	target.set("player_accessories", EquipmentSystem.empty_accessories())
	target.set("last_death_source", "接触")
	target.set("last_hammer_dir", Vector2.RIGHT)
	target.set("player_facing_x", 1.0)
	clear_stage_effect_collections(target)
	apply_genre_state(target, genre_state())
	return initial

static func restart_run_for_target(
	target: Node,
	characters: Array,
	weapons: Array,
	sprite_cache: Dictionary,
	tutorial_seen: bool
) -> Dictionary:
	CharacterSystem.apply_selected_character_for_target(
		target,
		characters,
		weapons,
		String(target.get("current_character_id")),
		sprite_cache
	)
	var character: Dictionary = target.get("current_character") as Dictionary
	var weapon: Dictionary = target.get("current_weapon") as Dictionary
	var stats: Dictionary = CharacterSystem.base_stats(character)
	var resources: Dictionary = CharacterSystem.initial_resources(character)
	start_run_for_target(target, character, weapon, stats, resources)
	CharacterSystem.apply_passive_for_target(target, character)
	return StateFlowSystem.apply_post_restart_state_for_target(target, tutorial_seen)

static func apply_initial_values(target: Node, initial: Dictionary) -> void:
	target.set("player_pos", initial["playerPos"] as Vector2)
	target.set("player_vel", initial["playerVel"] as Vector2)
	target.set("player_max_hp", int(initial["playerMaxHp"]))
	target.set("player_hp", int(initial["playerHp"]))
	target.set("player_speed", float(initial["playerSpeed"]))
	target.set("character_attack_multiplier", float(initial.get("characterAttackMultiplier", 1.0)))
	target.set("dash_cd", 0.0)
	target.set("dash_tap_timer", 0.0)
	target.set("dash_tap_last_dir", Vector2.ZERO)
	target.set("dash_left_down", false)
	target.set("dash_right_down", false)
	target.set("dash_up_down", false)
	target.set("dash_down_down", false)
	target.set("dash_enter_down", false)
	target.set("invincible", 0.0)
	target.set("debug_invincible", false)
	target.set("debug_rare_comment_boost", false)
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
	target.set("mental_care_level", int(defaults["mentalCareLevel"]))
	target.set("notification_bell_level", int(defaults["notificationBellLevel"]))
	target.set("exp_bonus_remainder", float(defaults["expBonusRemainder"]))
	target.set("comment_radar_level", int(defaults["commentRadarLevel"]))
	target.set("comment_radar_range_bonus", float(defaults["commentRadarRangeBonus"]))
	target.set("item_magnet_speed_rate", float(defaults["itemMagnetSpeedRate"]))
	target.set("comment_radar_fx_timer", float(defaults["commentRadarFxTimer"]))
	target.set("mini_humidifier_level", int(defaults["miniHumidifierLevel"]))
	target.set("mini_humidifier_timer", float(defaults["miniHumidifierTimer"]))
	target.set("mini_humidifier_hurt_cooldown", float(defaults["miniHumidifierHurtCooldown"]))
	target.set("equipment_damage_rate", float(defaults["equipmentDamageRate"]))
	target.set("equipment_range_rate", float(defaults["equipmentRangeRate"]))
	target.set("equipment_interval_rate", float(defaults["equipmentIntervalRate"]))
	target.set("equipment_bullet_support_level", int(defaults["equipmentBulletSupportLevel"]))
	target.set("superchat_level", int(defaults["superchatLevel"]))
	target.set("boomerang_level", int(defaults["boomerangLevel"]))
	target.set("burn_resist_charges", int(defaults["burnResistCharges"]))
	target.set("gift_reroll_remaining", int(defaults.get("giftRerollRemaining", 0)))
	target.set("clip_bonus_level", int(defaults["clipBonusLevel"]))
	target.set("heart_pending", bool(defaults["heartPending"]))
	target.set("heart_used_count", int(defaults["heartUsedCount"]))
	target.set("ng_used_count", int(defaults["ngUsedCount"]))

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
	# These are run-local comment selection preferences.  They must never leak
	# from a completed run into the first offer of a new/retried run.
	target.set("last_comment_id", "")
	var recent_categories: Variant = target.get("recent_comment_categories")
	if recent_categories is Array:
		(recent_categories as Array).clear()
	else:
		target.set("recent_comment_categories", [])

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
	target.set("genre_event_duration", float(defaults["genreEventDuration"]))
	target.set("genre_event_source", String(defaults["genreEventSource"]))
	target.set("active_genre_event", String(defaults["activeGenreEvent"]))
	target.set("next_known_genre_event", String(defaults["nextKnownGenreEvent"]))
	target.set("genre_event_hurt", bool(defaults["genreEventHurt"]))
	target.set("genre_race_move_timer", float(defaults["genreRaceMoveTimer"]))
	target.set("genre_bullet_timer", float(defaults["genreBulletTimer"]))
	target.set("genre_race_dash_boost_timer", float(defaults["genreRaceDashBoostTimer"]))
	target.set("genre_stg_shot_timer", float(defaults["genreStgShotTimer"]))
	target.set("genre_stg_spawn_timer", float(defaults["genreStgSpawnTimer"]))
	target.set("genre_stg_last_dir", defaults["genreStgLastDir"] as Vector2)
	target.set("genre_result_coin_count", int(defaults["genreResultCoinCount"]))
	target.set("genre_result_dash_pad_count", int(defaults["genreResultDashPadCount"]))
	target.set("genre_event_start_kills", int(defaults["genreEventStartKills"]))
	target.set("genre_result_stg_shot_kill_count", int(defaults["genreResultStgShotKillCount"]))
	target.set("genre_result_fake_gift_defeat_count", int(defaults["genreResultFakeGiftDefeatCount"]))
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
	clear_comment_offer_state(target)
	ExpSystemScript.discard_orbs_for_target(target)
	(target.get("taken_gift_names") as Array).clear()
	(target.get("player_weapons") as Array).clear()
	(target.get("player_accessories") as Array).clear()
	(target.get("enemies") as Array).clear()
	target.set("next_enemy_uid", 1)
	(target.get("enemy_bullets") as Array).clear()
	(target.get("exp_orbs") as Array).clear()
	(target.get("player_bullets") as Array).clear()
	(target.get("boomerang_hits") as Dictionary).clear()
	(target.get("equipment_weapon_timers") as Dictionary).clear()
	(target.get("hit_fx") as Array).clear()
	(target.get("active_effects") as Array).clear()
	(target.get("active_effect_rates") as Dictionary).clear()
	if target.get("active_sub_comment_ids") != null:
		(target.get("active_sub_comment_ids") as Array).clear()
	if target.get("destructibles") != null:
		(target.get("destructibles") as Array).clear()
	if target.get("drop_items") != null:
		(target.get("drop_items") as Array).clear()
	if target.get("genre_race_dash_pads") != null:
		(target.get("genre_race_dash_pads") as Array).clear()
	if target.get("genre_race_coins") != null:
		(target.get("genre_race_coins") as Array).clear()
	if target.get("genre_horror_fake_gifts") != null:
		(target.get("genre_horror_fake_gifts") as Array).clear()
	target.set("next_destructible_uid", 1)
	target.set("next_care_package_time", 15.0)

static func clear_comment_offer_state(target: Node) -> void:
	for property_name in ["offered_comments", "heart_cards", "ng_cards"]:
		var value: Variant = target.get(property_name)
		if value is Array:
			(value as Array).clear()
	target.set("selected_card", 0)
	target.set("special_choice_return_card", 0)
	target.set("choice_timer", 0.0)

static func reset_comment_state_for_target(target: Node, reset_timer: bool = true) -> void:
	target.set("last_comment_id", "")
	var recent_categories: Variant = target.get("recent_comment_categories")
	if recent_categories is Array:
		(recent_categories as Array).clear()
	else:
		target.set("recent_comment_categories", [])
	clear_comment_offer_state(target)
	target.set("comment_warning_step", 0)
	if reset_timer:
		target.set("comment_timer", 15.0)

static func clear_stage_effect_collections(target: Node) -> void:
	(target.get("effect_walls") as Array).clear()
	(target.get("effect_pits") as Array).clear()

static func reset_run_ui(result_panel: Control, choice_box: Control, heart_cards: Array, chat_lines: Array) -> void:
	result_panel.visible = false
	choice_box.visible = false
	heart_cards.clear()
	chat_lines.clear()

static func reset_run_ui_and_seed_chat(result_panel: Control, choice_box: Control, heart_cards: Array, chat_lines: Array, chat_box: Control) -> Array[String]:
	reset_run_ui(result_panel, choice_box, heart_cards, chat_lines)
	return ChatSystem.seed_box(chat_box, "normal")
