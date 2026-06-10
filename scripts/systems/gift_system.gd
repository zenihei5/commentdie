extends RefCounted
class_name GiftSystem

const WeaponEvolutionSystemScript := preload("res://scripts/systems/weapon_evolution_system.gd")

static func arrival_text(gift_hype: int) -> String:
	if gift_hype >= 90:
		return "神ギフトの予感……！"
	if gift_hype >= 70:
		return "豪華ギフトが届いた！"
	if gift_hype >= 40:
		return "いいギフトが届いた！"
	return "ギフトが届いた！"

static func build_offer(context: Dictionary) -> Array:
	var rng: RandomNumberGenerator = context["rng"] as RandomNumberGenerator
	var gift_hype: int = int(context["giftHype"])
	var gift_time: float = float(context["giftTime"])
	var rarities: Array[String] = []
	for i in range(3):
		rarities.append(roll_rarity(gift_hype, gift_time, rng))
	if gift_time >= 60.0 and gift_hype >= 90 and not (rarities.has("god") or rarities.has("flame")):
		rarities[2] = "god" if rng.randf() < 0.65 else "flame"
	elif gift_hype >= 70 and not (rarities.has("rare") or rarities.has("god") or rarities.has("flame")):
		rarities[2] = "rare"
	elif gift_hype >= 40 and not rarities.has("rare"):
		rarities[2] = "rare"
	var result: Array = []
	var evolution_gift: Dictionary = context.get("evolutionGift", {}) as Dictionary
	if not evolution_gift.is_empty():
		result.append(evolution_gift)
	for rarity in rarities:
		if result.size() >= 3:
			break
		result.append(pick_gift(context, rarity, result))
	while result.size() < 3:
		result.append(pick_gift(context, "common", result))
	return result

static func build_forced_offer(context: Dictionary, rarity: String, count: int = 3) -> Array:
	var result: Array = []
	for i in range(count):
		result.append(pick_gift(context, rarity, result))
	return result

static func build_offer_context_for_target(target: Node, gifts: Array, gift_time: float, rng: RandomNumberGenerator) -> Dictionary:
	return {
		"gifts": gifts,
		"streamFrame": target.get("current_stream_frame"),
		"giftHype": target.get("gift_hype"),
		"giftTime": gift_time,
		"availableIds": available_gift_ids_for_target(target, gifts, gift_time),
		"evolutionGift": WeaponEvolutionSystemScript.evolution_gift_for_target(target, target.get("weapons") as Array),
		"rng": rng
	}

static func start_offer_for_target(target: Node, gifts: Array, rng: RandomNumberGenerator) -> Dictionary:
	target.set("state", "gift_choice")
	target.set("selected_card", 0)
	var elapsed: float = float(target.get("elapsed"))
	var quick_test: bool = bool(target.get("quick_test_mode"))
	var gift_time: float = elapsed * (3.0 if quick_test else 1.0)
	var context: Dictionary = build_offer_context_for_target(target, gifts, gift_time, rng)
	target.set("offered_gifts", build_offer(context))
	return {"arrivalText": arrival_text(int(target.get("gift_hype")))}

static func start_offer_ui_for_target(target: Node, gifts: Array, rng: RandomNumberGenerator, choice_box: Control) -> Dictionary:
	var result: Dictionary = start_offer_for_target(target, gifts, rng)
	choice_box.visible = true
	return result

static func roll_rarity(gift_hype: int, gift_time: float, rng: RandomNumberGenerator) -> String:
	var roll: float = rng.randf()
	if gift_hype < 40:
		return "rare" if roll < 0.15 else "common"
	if gift_hype < 70 or gift_time < 60.0:
		return "rare" if roll < 0.35 else "common"
	if gift_hype < 90:
		if roll < 0.35:
			return "common"
		if roll < 0.80:
			return "rare"
		if roll < 0.95:
			return "god"
		return "flame"
	if roll < 0.20:
		return "common"
	if roll < 0.60:
		return "rare"
	if roll < 0.85:
		return "god"
	return "flame"

static func pick_gift(context: Dictionary, rarity: String, used: Array) -> Dictionary:
	var pool: Array = []
	var gifts: Array = context["gifts"] as Array
	var available_ids: Array = context["availableIds"] as Array
	var frame: Dictionary = context["streamFrame"] as Dictionary
	for item in gifts:
		var gift: Dictionary = item as Dictionary
		if String(gift["rarity"]) != rarity:
			continue
		if not _data_allowed_for_frame(frame, gift, "giftPoolTags"):
			continue
		if used.has(gift):
			continue
		if not available_ids.has(String(gift["id"])):
			continue
		for i in range(int(gift["weight"])):
			pool.append(gift)
	if pool.is_empty():
		for item in gifts:
			var fallback: Dictionary = item as Dictionary
			if _data_allowed_for_frame(frame, fallback, "giftPoolTags") and available_ids.has(String(fallback["id"])):
				pool.append(fallback)
	if pool.is_empty():
		return {"id": "rest", "displayName": "休憩", "description": "メンタルを回復", "rarity": "common", "maxLevel": 0, "effectType": "heal", "weight": 1}
	var rng: RandomNumberGenerator = context["rng"] as RandomNumberGenerator
	return pool[rng.randi_range(0, pool.size() - 1)] as Dictionary

static func consume_for_rarity(rarity: String) -> int:
	if rarity == "evolution":
		return 0
	if rarity == "rare":
		return 40
	if rarity == "god" or rarity == "flame":
		return 70
	return 20

static func available_gift_ids_for_target(target: Node, gifts: Array, gift_time: float) -> Array:
	var result: Array = []
	for item in gifts:
		var gift: Dictionary = item as Dictionary
		if gift_available_for_target(target, gift, gift_time):
			result.append(String(gift["id"]))
	return result

static func gift_available_for_target(target: Node, gift: Dictionary, gift_time: float) -> bool:
	if gift_time < float(gift.get("minTime", 0.0)):
		return false
	if not EquipmentSystem.is_instant(gift):
		return EquipmentSystem.can_offer(target, gift, gift_time)
	if String(gift["id"]) == "rest":
		return int(target.get("player_hp")) < int(target.get("player_max_hp"))
	var max_level: int = int(gift["maxLevel"])
	if max_level <= 0:
		return true
	return gift_level_for_target(target, String(gift["id"])) < max_level

static func choose_gift_for_target(target: Node, gift: Dictionary) -> Dictionary:
	var result: Dictionary = apply_gift_to_target(target, gift)
	var names: Array = target.get("taken_gift_names") as Array
	names.append(_taken_name_for_target(target, gift))
	target.set("gifts_taken", int(target.get("gifts_taken")) + 1)
	var consume: int = consume_for_rarity(String(gift["rarity"]))
	target.set("gift_hype", maxi(0, int(target.get("gift_hype")) - consume))
	if bool(result.get("heartPendingDuplicate", false)):
		var bonus_hype: int = clampi(int(target.get("gift_hype")) + 15, 0, 100)
		target.set("gift_hype", bonus_hype)
		target.set("max_gift_hype", maxi(int(target.get("max_gift_hype")), bonus_hype))
	return result

static func choose_offer_index_for_target(target: Node, index: int) -> Dictionary:
	var offered_gifts: Array = target.get("offered_gifts") as Array
	if index < 0 or index >= offered_gifts.size():
		return {"selected": false, "giftName": "", "rollGenreEvent": false}
	var gift: Dictionary = offered_gifts[index] as Dictionary
	var result: Dictionary = choose_gift_for_target(target, gift)
	target.set("state", "playing")
	return {
		"selected": true,
		"giftName": String(gift["displayName"]),
		"rollGenreEvent": bool(result.get("rollGenreEvent", false)),
		"heartPendingActivated": bool(result.get("heartPendingActivated", false)),
		"heartPendingDuplicate": bool(result.get("heartPendingDuplicate", false)),
		"weaponEvolution": result.get("weaponEvolution", {})
	}

static func choose_offer_index_ui_for_target(target: Node, index: int, choice_box: Control) -> Dictionary:
	var result: Dictionary = choose_offer_index_for_target(target, index)
	if bool(result["selected"]):
		choice_box.visible = false
	return result

static func choose_offer_index_with_feedback_for_target(
	target: Node,
	index: int,
	choice_box: Control,
	genre_events: Array,
	rng: RandomNumberGenerator
) -> Dictionary:
	var result: Dictionary = choose_offer_index_ui_for_target(target, index, choice_box)
	if not bool(result["selected"]):
		return {"selected": false, "chats": []}
	if bool(result.get("rollGenreEvent", false)):
		GenreEventSystem.set_next_known_event_for_target(target, genre_events, rng)
	var chats: Array[String] = []
	chats.append(String(result["giftName"]) + " を取得")
	if bool(result.get("heartPendingActivated", false)):
		chats.append("♡を受け取った！ 次の指示コメが全部ちょっと甘くなる")
	if bool(result.get("heartPendingDuplicate", false)):
		chats.append("♡はすでに待機中！ ギフト期待度 +15")
	var weapon_evolution: Dictionary = result.get("weaponEvolution", {}) as Dictionary
	if not weapon_evolution.is_empty():
		chats.append("武器進化！ %s → %s" % [
			String(weapon_evolution.get("baseDisplayName", "")),
			String(weapon_evolution.get("evolvedDisplayName", ""))
		])
	return {
		"selected": true,
		"chats": chats
	}

static func update_choice_input_for_target(target: Node, latch: Dictionary) -> Dictionary:
	var action: Dictionary = ChoiceCardSystem.selection_action(latch, int(target.get("selected_card")), 3)
	if ChoiceCardSystem.is_move(action):
		target.set("selected_card", int(action["index"]))
		return {"refresh": true, "chooseIndex": -1}
	if ChoiceCardSystem.is_select(action):
		return {"refresh": false, "chooseIndex": int(action["index"])}
	return {"refresh": false, "chooseIndex": -1}

static func apply_gift_to_target(target: Node, gift: Dictionary) -> Dictionary:
	if WeaponEvolutionSystemScript.is_evolution_gift(gift):
		var evolution_result: Dictionary = WeaponEvolutionSystemScript.apply_evolution_gift_for_target(target, gift)
		_apply_equipment_stats_to_target(target)
		return evolution_result
	if not EquipmentSystem.is_instant(gift):
		return apply_equipment_to_target(target, gift)
	var effect: String = String(gift["effectType"])
	var result: Dictionary = apply_effect(effect, build_effect_context_from_target(target))
	apply_effect_result_to_target(target, result)
	return result

static func apply_equipment_to_target(target: Node, gift: Dictionary) -> Dictionary:
	var equipment_type: String = EquipmentSystem.equipment_type(gift)
	var items: Array = target.get("player_accessories") as Array
	if equipment_type == "weapon":
		items = target.get("player_weapons") as Array
	EquipmentSystem.add_or_level(items, String(gift["id"]), int(gift.get("maxLevel", 1)))
	if equipment_type == "weapon":
		target.set("player_weapons", items)
	else:
		target.set("player_accessories", items)
	_apply_equipment_stats_to_target(target)
	return {"rollGenreEvent": false, "heartPendingActivated": false, "heartPendingDuplicate": false}

static func _taken_name_for_target(target: Node, gift: Dictionary) -> String:
	if WeaponEvolutionSystemScript.is_evolution_gift(gift):
		return "%s 進化" % String(gift.get("evolvedDisplayName", gift.get("displayName", "武器進化")))
	if EquipmentSystem.is_instant(gift):
		return String(gift["displayName"])
	var level_value: int = EquipmentSystem.level_for_target(target, String(gift["id"]))
	return "%s Lv%d" % [String(gift["displayName"]), level_value]

static func _apply_equipment_stats_to_target(target: Node) -> void:
	var weapons: Array = target.get("player_weapons") as Array
	var accessories: Array = target.get("player_accessories") as Array
	var current_weapon: Dictionary = target.get("current_weapon") as Dictionary
	var current_character: Dictionary = target.get("current_character") as Dictionary
	var stats: Dictionary = CharacterSystem.base_stats(current_character)
	var main_weapon_id: String = String(current_weapon.get("id", "ban_hammer"))
	var main_weapon_level: int = maxi(1, EquipmentSystem.level(weapons, main_weapon_id))
	var stream_power_level: int = EquipmentSystem.level(accessories, "stream_power")
	var high_speed_level: int = EquipmentSystem.level(accessories, "high_speed_connection")
	var wide_angle_level: int = EquipmentSystem.level(accessories, "wide_angle")
	var sneaker_level: int = EquipmentSystem.level(accessories, "light_sneakers")
	var bullet_support_level: int = EquipmentSystem.level(accessories, "bullet_support")
	var sweet_level: int = EquipmentSystem.level(accessories, "sweet_tooth")
	var main_damage_rate: float = 1.0 + 0.10 * float(stream_power_level) + 0.10 * float(main_weapon_level - 1)
	var main_range_rate: float = 1.0 + 0.10 * float(wide_angle_level) + 0.08 * float(main_weapon_level - 1)
	var main_interval_rate: float = pow(0.92, float(high_speed_level)) * pow(0.94, float(main_weapon_level - 1))
	target.set("equipment_damage_rate", 1.0 + 0.10 * float(stream_power_level))
	target.set("equipment_range_rate", 1.0 + 0.10 * float(wide_angle_level))
	target.set("equipment_interval_rate", pow(0.92, float(high_speed_level)))
	target.set("equipment_bullet_support_level", bullet_support_level)
	target.set("hammer_damage", float(current_weapon.get("damage", 12.0)) * main_damage_rate)
	target.set("hammer_range", WeaponSystem.range_base(current_weapon) * main_range_rate)
	target.set("hammer_interval", maxf(0.28, WeaponSystem.attack_interval(current_weapon, 0.85) * main_interval_rate))
	target.set("knockback_power", WeaponSystem.scaled_knockback(float(current_weapon.get("knockback", 1.0))) * (1.0 + 0.10 * float(main_weapon_level - 1)))
	target.set("player_speed", WeaponSystem.scaled_move_speed(float(stats.get("moveSpeed", 5.0))) * (1.0 + 0.05 * float(sneaker_level)))
	target.set("dash_cooldown", float(stats.get("dashCooldown", current_character.get("dashCooldown", 1.2))) * pow(0.95, float(sneaker_level)))
	target.set("sweet_tooth_level", sweet_level)
	var superchat_weapon_level: int = EquipmentSystem.level(weapons, "superchat_shot")
	var boomerang_weapon_level: int = EquipmentSystem.level(weapons, "comment_boomerang")
	var superchat_evolved: bool = EquipmentSystem.has_evolved_from(weapons, "superchat_shot")
	var boomerang_evolved: bool = EquipmentSystem.has_evolved_from(weapons, "comment_boomerang")
	var superchat_level: int = maxi(0, superchat_weapon_level)
	var boomerang_level: int = maxi(0, boomerang_weapon_level)
	if main_weapon_id == "superchat_shot":
		superchat_level = maxi(0, superchat_weapon_level - 1)
	if main_weapon_id == "comment_boomerang":
		boomerang_level = maxi(0, boomerang_weapon_level - 1)
	if superchat_weapon_level > 0:
		superchat_level += bullet_support_level
	if boomerang_weapon_level > 0:
		boomerang_level += bullet_support_level
	if superchat_evolved:
		superchat_level = bullet_support_level
	if boomerang_evolved:
		boomerang_level = bullet_support_level
	target.set("superchat_level", superchat_level)
	target.set("boomerang_level", boomerang_level)

static func apply_effect(effect: String, context: Dictionary) -> Dictionary:
	var result: Dictionary = context.duplicate()
	result["rollGenreEvent"] = false
	result["heartPendingActivated"] = false
	result["heartPendingDuplicate"] = false
	if effect == "hammer_damage":
		result["hammerDamage"] = float(result.get("hammerDamage", 0.0)) * 1.15
	elif effect == "hammer_size":
		result["hammerRange"] = float(result.get("hammerRange", 0.0)) * 1.12
	elif effect == "hammer_rate":
		result["hammerInterval"] = maxf(0.35, float(result.get("hammerInterval", 0.85)) * 0.92)
	elif effect == "move_speed":
		result["playerSpeed"] = float(result.get("playerSpeed", 0.0)) * 1.07
	elif effect == "max_hp":
		result["playerMaxHp"] = int(result.get("playerMaxHp", 5)) + 1
		result["playerHp"] = mini(int(result["playerMaxHp"]), int(result.get("playerHp", 5)) + 1)
	elif effect == "heal":
		result["playerHp"] = mini(int(result.get("playerMaxHp", 5)), int(result.get("playerHp", 5)) + 2)
	elif effect == "gift_hype_boost":
		result["giftHype"] = clampi(int(result.get("giftHype", 0)) + 25, 0, 100)
		result["maxGiftHype"] = maxi(int(result.get("maxGiftHype", 0)), int(result["giftHype"]))
	elif effect == "viewer_burst":
		result["score"] = int(result.get("score", 0)) + 800
	elif effect == "magnet":
		result["magnetRange"] = float(result.get("magnetRange", 95.0)) * 1.3
	elif effect == "add_heart_stock":
		if bool(result.get("heartPending", false)):
			result["heartPendingDuplicate"] = true
		else:
			result["heartPending"] = true
			result["heartPendingActivated"] = true
	elif effect == "superchat":
		result["superchatLevel"] = int(result.get("superchatLevel", 0)) + 1
	elif effect == "boomerang":
		result["boomerangLevel"] = int(result.get("boomerangLevel", 0)) + 1
	elif effect == "burn_resist":
		result["burnResistCharges"] = int(result.get("burnResistCharges", 0)) + 1
	elif effect == "clip_bonus":
		result["clipBonusLevel"] = int(result.get("clipBonusLevel", 0)) + 1
	elif effect == "clip_confirmed":
		result["clipConfirmed"] = true
	elif effect == "exp_vacuum_extreme":
		result["expVacuumExtreme"] = true
	elif effect == "zero_taunt_resist":
		result["zeroTauntResist"] = true
	elif effect == "comment_boost":
		result["commentBoost"] = true
		result["choiceTimePenalty"] = float(result.get("choiceTimePenalty", 0.0)) + 0.5
	elif effect == "sweet_tooth":
		result["sweetToothLevel"] = int(result.get("sweetToothLevel", 0)) + 1
	elif effect == "maro_magnet":
		result["maroMagnetRange"] = float(result.get("maroMagnetRange", 0.0)) + 42.0
	elif effect == "read_manager":
		result["readManagerLevel"] = int(result.get("readManagerLevel", 0)) + 1
	elif effect == "maro_appraisal":
		result["maroAppraisal"] = true
	elif effect == "block_function":
		result["blockFunctionStock"] = mini(3, int(result.get("blockFunctionStock", 0)) + 1)
	elif effect == "steel_mental":
		result["steelMentalLevel"] = int(result.get("steelMentalLevel", 0)) + 1
	elif effect == "like_score":
		result["likeScoreLevel"] = int(result.get("likeScoreLevel", 0)) + 1
	elif effect == "dash_cooldown":
		result["dashCooldown"] = maxf(0.55, float(result.get("dashCooldown", 1.2)) * 0.88)
	elif effect == "knockback":
		result["knockbackPower"] = float(result.get("knockbackPower", 18.0)) * 1.2
	elif effect == "moderator":
		result["moderatorLevel"] = int(result.get("moderatorLevel", 0)) + 1
	elif effect == "reentry_barrier":
		result["reentryBarrierLevel"] = int(result.get("reentryBarrierLevel", 0)) + 1
	elif effect == "golden_hammer":
		result["hammerDamage"] = float(result.get("hammerDamage", 0.0)) * 1.4
		result["hammerRange"] = float(result.get("hammerRange", 0.0)) * 1.25
	elif effect == "god_moderator":
		result["moderatorLevel"] = int(result.get("moderatorLevel", 0)) + 5
		result["choiceTimeBonus"] = float(result.get("choiceTimeBonus", 0.0)) + 1.0
	elif effect == "revive":
		result["reviveAvailable"] = true
	elif effect == "flame_marketing":
		result["flameMarketing"] = true
	elif effect == "yes_listener":
		result["yesListener"] = true
	elif effect == "cant_stop":
		result["playerSpeed"] = float(result.get("playerSpeed", 0.0)) * 1.2
		result["hammerInterval"] = float(result.get("hammerInterval", 0.85)) * 0.8
	elif effect == "strategy_wiki":
		result["strategyWiki"] = true
		result["rollGenreEvent"] = true
	elif effect == "first_play_adapt":
		result["firstPlayAdapt"] = true
	elif effect == "streaming_skill":
		result["streamingSkillLevel"] = int(result.get("streamingSkillLevel", 0)) + 1
	elif effect == "kusoge_resist":
		result["kusogeResistLevel"] = int(result.get("kusogeResistLevel", 0)) + 1
	return result

static func build_effect_context_from_target(target: Node) -> Dictionary:
	return {
		"hammerDamage": target.get("hammer_damage"),
		"hammerRange": target.get("hammer_range"),
		"hammerInterval": target.get("hammer_interval"),
		"playerSpeed": target.get("player_speed"),
		"playerMaxHp": target.get("player_max_hp"),
		"playerHp": target.get("player_hp"),
		"magnetRange": target.get("magnet_range"),
		"heartStock": target.get("heart_stock"),
		"heartPending": target.get("heart_pending"),
		"giftHype": target.get("gift_hype"),
		"maxGiftHype": target.get("max_gift_hype"),
		"score": target.get("score"),
		"superchatLevel": target.get("superchat_level"),
		"boomerangLevel": target.get("boomerang_level"),
		"burnResistCharges": target.get("burn_resist_charges"),
		"clipBonusLevel": target.get("clip_bonus_level"),
		"clipConfirmed": target.get("clip_confirmed"),
		"expVacuumExtreme": target.get("exp_vacuum_extreme"),
		"zeroTauntResist": target.get("zero_taunt_resist"),
		"commentBoost": target.get("comment_boost"),
		"choiceTimePenalty": target.get("choice_time_penalty"),
		"sweetToothLevel": target.get("sweet_tooth_level"),
		"maroMagnetRange": target.get("maro_magnet_range"),
		"readManagerLevel": target.get("read_manager_level"),
		"maroAppraisal": target.get("maro_appraisal"),
		"blockFunctionStock": target.get("block_function_stock"),
		"steelMentalLevel": target.get("steel_mental_level"),
		"likeScoreLevel": target.get("like_score_level"),
		"dashCooldown": target.get("dash_cooldown"),
		"knockbackPower": target.get("knockback_power"),
		"moderatorLevel": target.get("moderator_level"),
		"reentryBarrierLevel": target.get("reentry_barrier_level"),
		"choiceTimeBonus": target.get("choice_time_bonus"),
		"reviveAvailable": target.get("revive_available"),
		"flameMarketing": target.get("flame_marketing"),
		"yesListener": target.get("yes_listener"),
		"strategyWiki": target.get("strategy_wiki"),
		"firstPlayAdapt": target.get("first_play_adapt"),
		"streamingSkillLevel": target.get("streaming_skill_level"),
		"kusogeResistLevel": target.get("kusoge_resist_level")
	}

static func apply_effect_result_to_target(target: Node, result: Dictionary) -> void:
	target.set("hammer_damage", float(result["hammerDamage"]))
	target.set("hammer_range", float(result["hammerRange"]))
	target.set("hammer_interval", float(result["hammerInterval"]))
	target.set("player_speed", float(result["playerSpeed"]))
	target.set("player_max_hp", int(result["playerMaxHp"]))
	target.set("player_hp", int(result["playerHp"]))
	target.set("magnet_range", float(result["magnetRange"]))
	target.set("heart_stock", int(result["heartStock"]))
	target.set("heart_pending", bool(result["heartPending"]))
	target.set("gift_hype", int(result["giftHype"]))
	target.set("max_gift_hype", int(result["maxGiftHype"]))
	target.set("score", int(result["score"]))
	target.set("superchat_level", int(result["superchatLevel"]))
	target.set("boomerang_level", int(result["boomerangLevel"]))
	target.set("burn_resist_charges", int(result["burnResistCharges"]))
	target.set("clip_bonus_level", int(result["clipBonusLevel"]))
	target.set("clip_confirmed", bool(result["clipConfirmed"]))
	target.set("exp_vacuum_extreme", bool(result["expVacuumExtreme"]))
	target.set("zero_taunt_resist", bool(result["zeroTauntResist"]))
	target.set("comment_boost", bool(result["commentBoost"]))
	target.set("choice_time_penalty", float(result["choiceTimePenalty"]))
	target.set("sweet_tooth_level", int(result["sweetToothLevel"]))
	target.set("maro_magnet_range", float(result["maroMagnetRange"]))
	target.set("read_manager_level", int(result["readManagerLevel"]))
	target.set("maro_appraisal", bool(result["maroAppraisal"]))
	target.set("block_function_stock", int(result["blockFunctionStock"]))
	target.set("steel_mental_level", int(result["steelMentalLevel"]))
	target.set("like_score_level", int(result["likeScoreLevel"]))
	target.set("dash_cooldown", float(result["dashCooldown"]))
	target.set("knockback_power", float(result["knockbackPower"]))
	target.set("moderator_level", int(result["moderatorLevel"]))
	target.set("reentry_barrier_level", int(result["reentryBarrierLevel"]))
	target.set("choice_time_bonus", float(result["choiceTimeBonus"]))
	target.set("revive_available", bool(result["reviveAvailable"]))
	target.set("flame_marketing", bool(result["flameMarketing"]))
	target.set("yes_listener", bool(result["yesListener"]))
	target.set("strategy_wiki", bool(result["strategyWiki"]))
	target.set("first_play_adapt", bool(result["firstPlayAdapt"]))
	target.set("streaming_skill_level", int(result["streamingSkillLevel"]))
	target.set("kusoge_resist_level", int(result["kusogeResistLevel"]))

static func gift_level_for_target(target: Node, id: String) -> int:
	var equipment_level: int = EquipmentSystem.level_for_target(target, id)
	if equipment_level > 0:
		return equipment_level
	return gift_level(id, build_level_context_from_target(target))

static func build_level_context_from_target(target: Node) -> Dictionary:
	var character: Dictionary = target.get("current_character") as Dictionary
	var weapon: Dictionary = target.get("current_weapon") as Dictionary
	var stats: Dictionary = CharacterSystem.base_stats(character)
	var context: Dictionary = build_effect_context_from_target(target)
	context["baseWeaponDamage"] = float(weapon.get("damage", 12.0))
	context["baseWeaponRange"] = WeaponSystem.range_base(weapon)
	context["baseWeaponInterval"] = WeaponSystem.attack_interval(weapon, 0.85)
	context["basePlayerSpeed"] = WeaponSystem.scaled_move_speed(float(stats.get("moveSpeed", 5.0)))
	context["baseHp"] = int(stats.get("hp", character.get("initialHp", 5)))
	context["baseDashCooldown"] = float(stats.get("dashCooldown", character.get("dashCooldown", 1.2)))
	context["baseKnockback"] = float(weapon.get("knockback", 18.0))
	context["heartUsedCount"] = int(target.get("heart_used_count"))
	context["heartPending"] = bool(target.get("heart_pending"))
	return context

static func gift_level(id: String, context: Dictionary) -> int:
	if id == "ban_hammer_damage":
		var base_damage: float = float(context.get("baseWeaponDamage", 12.0))
		return int(round((float(context.get("hammerDamage", base_damage)) / base_damage - 1.0) / 0.15))
	if id == "hammer_size":
		var base_range: float = float(context.get("baseWeaponRange", 1.0))
		return int(round((float(context.get("hammerRange", base_range)) / base_range - 1.0) / 0.12))
	if id == "rapid_ban":
		var base_interval: float = float(context.get("baseWeaponInterval", 0.85))
		return int(round((1.0 - float(context.get("hammerInterval", base_interval)) / base_interval) / 0.08))
	if id == "move_speed":
		var base_speed: float = float(context.get("basePlayerSpeed", 1.0))
		return int(round((float(context.get("playerSpeed", base_speed)) / base_speed - 1.0) / 0.07))
	if id == "mental":
		return int(context.get("playerMaxHp", 5)) - int(context.get("baseHp", 5))
	if id == "exp_magnet":
		return int(round((float(context.get("magnetRange", 95.0)) / 95.0 - 1.0) / 0.30))
	if id == "heart_mark":
		return int(context.get("heartUsedCount", 0)) + (1 if bool(context.get("heartPending", false)) else 0)
	if id == "superchat_shot":
		return int(context.get("superchatLevel", 0))
	if id == "comment_boomerang":
		return int(context.get("boomerangLevel", 0))
	if id == "burn_resist":
		return int(context.get("burnResistCharges", 0))
	if id == "clip_bonus":
		return int(context.get("clipBonusLevel", 0))
	if id == "clip_confirmed":
		return 1 if bool(context.get("clipConfirmed", false)) else 0
	if id == "exp_vacuum_extreme":
		return 1 if bool(context.get("expVacuumExtreme", false)) else 0
	if id == "zero_taunt_resist":
		return 1 if bool(context.get("zeroTauntResist", false)) else 0
	if id == "comment_boost":
		return 1 if bool(context.get("commentBoost", false)) else 0
	if id == "sweet_tooth":
		return int(context.get("sweetToothLevel", 0))
	if id == "maro_magnet":
		return int(round(float(context.get("maroMagnetRange", 0.0)) / 42.0))
	if id == "read_manager":
		return int(context.get("readManagerLevel", 0))
	if id == "maro_appraisal":
		return 1 if bool(context.get("maroAppraisal", false)) else 0
	if id == "block_function":
		return int(context.get("blockFunctionStock", 0))
	if id == "steel_mental":
		return int(context.get("steelMentalLevel", 0))
	if id == "like_score":
		return int(context.get("likeScoreLevel", 0))
	if id == "dash_cooldown":
		var base_dash: float = float(context.get("baseDashCooldown", 1.2))
		return int(round((base_dash - float(context.get("dashCooldown", base_dash))) / 0.12))
	if id == "knockback":
		var base_knockback: float = float(context.get("baseKnockback", 18.0))
		return int(round((float(context.get("knockbackPower", base_knockback)) / base_knockback - 1.0) / 0.20))
	if id == "moderator":
		return int(context.get("moderatorLevel", 0))
	if id == "reentry_barrier":
		return int(context.get("reentryBarrierLevel", 0))
	if id == "golden_hammer" or id == "golden_ban_hammer":
		return 1 if float(context.get("hammerDamage", 0.0)) > 16.0 else 0
	if id == "god_moderator":
		return 1 if int(context.get("moderatorLevel", 0)) >= 5 else 0
	if id == "low_rating_escape" or id == "low_rating_guard":
		return 1 if bool(context.get("reviveAvailable", false)) else 0
	if id == "flame_marketing":
		return 1 if bool(context.get("flameMarketing", false)) else 0
	if id == "yes_listener" or id == "all_positive_listener":
		return 1 if bool(context.get("yesListener", false)) else 0
	if id == "cant_stop" or id == "cant_stop_now":
		return 1 if float(context.get("playerSpeed", 0.0)) > 300.0 and float(context.get("hammerInterval", 1.0)) < 0.72 else 0
	if id == "strategy_wiki":
		return 1 if bool(context.get("strategyWiki", false)) else 0
	if id == "first_play_adapt":
		return 1 if bool(context.get("firstPlayAdapt", false)) else 0
	if id == "streaming_skill":
		return int(context.get("streamingSkillLevel", 0))
	if id == "kusoge_resist":
		return int(context.get("kusogeResistLevel", 0))
	return 0

static func _data_allowed_for_frame(frame: Dictionary, data: Dictionary, tag_key: String) -> bool:
	var item_tags: Array = []
	if data.has("tags") and data["tags"] is Array:
		item_tags = data["tags"] as Array
	elif data.has(tag_key) and data[tag_key] is Array:
		item_tags = data[tag_key] as Array
	if item_tags.is_empty():
		item_tags = ["default"]
	var frame_tags: Array = frame.get(tag_key, []) as Array
	for tag in item_tags:
		if frame_tags.has(tag):
			return true
	return false

