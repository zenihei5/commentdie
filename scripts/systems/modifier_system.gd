class_name ModifierSystem
extends RefCounted

static func aliases() -> Dictionary:
	return {
		"no_stop": "keep_moving",
		"enemy_speed_up": "enemy_speed",
		"enemy_spawn_up": "more_spawns",
		"comment_barrage": "comment_storm",
		"temp_walls": "random_walls",
		"camera_zoom": "zoom_in",
		"kamiyoyaku": "god_reservation"
	}

static func has_effect(active_effects: Array[String], id: String) -> bool:
	if active_effects.has(id):
		return true
	var alias_map: Dictionary = aliases()
	if alias_map.has(id) and active_effects.has(String(alias_map[id])):
		return true
	for alias_id in alias_map.keys():
		if String(alias_map[alias_id]) == id and active_effects.has(String(alias_id)):
			return true
	return false

static func effect_rate(active_effects: Array[String], active_effect_rates: Dictionary, id: String) -> float:
	if active_effect_rates.has(id):
		return float(active_effect_rates[id])
	var alias_map: Dictionary = aliases()
	if alias_map.has(id) and active_effect_rates.has(String(alias_map[id])):
		return float(active_effect_rates[String(alias_map[id])])
	for alias_id in alias_map.keys():
		if String(alias_map[alias_id]) == id and active_effect_rates.has(String(alias_id)):
			return float(active_effect_rates[String(alias_id)])
	return 1.0 if has_effect(active_effects, id) else 0.0

static func active_effects_for_target(target: Node) -> Array[String]:
	var result: Array[String] = []
	for item in target.get("active_effects") as Array:
		result.append(String(item))
	return result

static func has_effect_for_target(target: Node, id: String) -> bool:
	return has_effect(active_effects_for_target(target), id)

static func effect_rate_for_target(target: Node, id: String) -> float:
	return effect_rate(
		active_effects_for_target(target),
		target.get("active_effect_rates") as Dictionary,
		id
	)

static func build_activation(comment: Dictionary, has_heart: bool, rng: RandomNumberGenerator) -> Dictionary:
	var effects: Array[String] = []
	var rates: Dictionary = {}
	var rate: float = 0.7 if has_heart else 1.0
	if String(comment["id"]) == "do_everything":
		var candidates: Array[String] = ["banana_floor", "reverse_control", "giant_enemies", "no_dash", "attack_right_only", "enemy_speed", "short_range"]
		candidates.shuffle()
		effects.append(String(candidates[0]))
		effects.append(String(candidates[1]))
		rates[String(candidates[0])] = rate
		rates[String(candidates[1])] = rate
	else:
		effects.append(String(comment["id"]))
		rates[String(comment["id"])] = rate
	return {"effects": effects, "rates": rates}

static func updated_recent_categories(recent: Array[String], category: String) -> Array[String]:
	var result: Array[String] = recent.duplicate()
	result.append(category)
	while result.size() > 2:
		result.pop_front()
	return result

static func apply_choice_numbers(context: Dictionary) -> Dictionary:
	var view: Dictionary = context["view"] as Dictionary
	var multiplier: float = float(view["multiplier"]) * (1.2 if bool(context.get("commentBoost", false)) else 1.0)
	var max_multiplier: float = maxf(float(context.get("maxMultiplier", 1.0)), multiplier)
	var burn_combo: int = int(context.get("burnCombo", 0))
	var danger_comments_chosen: int = int(context.get("dangerCommentsChosen", 0))
	var risk: int = int(view["riskLevel"])
	if risk >= 2:
		burn_combo += 1
	if risk >= 3:
		danger_comments_chosen += 1
	var burn_combo_max: int = maxi(int(context.get("burnComboMax", 0)), burn_combo)
	var hype_gain: int = int(view["giftHypeOnSelect"])
	if bool(context.get("yesListener", false)):
		hype_gain = int(round(float(hype_gain) * 1.3))
	var gift_hype: int = clampi(int(context.get("giftHype", 0)) + hype_gain, 0, 100)
	var max_gift_hype: int = maxi(int(context.get("maxGiftHype", 0)), gift_hype)
	return {
		"multiplier": multiplier,
		"maxMultiplier": max_multiplier,
		"burnCombo": burn_combo,
		"burnComboMax": burn_combo_max,
		"dangerCommentsChosen": danger_comments_chosen,
		"giftHype": gift_hype,
		"maxGiftHype": max_gift_hype,
		"pendingClearHype": int(view["giftHypeOnClear"]),
		"activeCommentHurt": false
	}

static func apply_choice_numbers_to_target(target: Node, view: Dictionary) -> Dictionary:
	var number_state: Dictionary = apply_choice_numbers({
		"view": view,
		"commentBoost": target.get("comment_boost"),
		"maxMultiplier": target.get("max_multiplier"),
		"burnCombo": target.get("burn_combo"),
		"burnComboMax": target.get("burn_combo_max"),
		"dangerCommentsChosen": target.get("danger_comments_chosen"),
		"yesListener": target.get("yes_listener"),
		"giftHype": target.get("gift_hype"),
		"maxGiftHype": target.get("max_gift_hype")
	})
	target.set("multiplier", float(number_state["multiplier"]))
	target.set("max_multiplier", float(number_state["maxMultiplier"]))
	target.set("burn_combo", int(number_state["burnCombo"]))
	target.set("burn_combo_max", int(number_state["burnComboMax"]))
	target.set("danger_comments_chosen", int(number_state["dangerCommentsChosen"]))
	target.set("gift_hype", int(number_state["giftHype"]))
	target.set("max_gift_hype", int(number_state["maxGiftHype"]))
	target.set("pending_clear_hype", int(number_state["pendingClearHype"]))
	target.set("active_comment_hurt", bool(number_state["activeCommentHurt"]))
	return number_state

static func start_comment_for_target(target: Node, comment: Dictionary, view: Dictionary, has_heart: bool, rng: RandomNumberGenerator) -> Dictionary:
	var activation: Dictionary = build_activation(comment, has_heart, rng)
	target.set("active_effects", activation["effects"] as Array[String])
	target.set("active_effect_rates", activation["rates"] as Dictionary)
	target.set("current_comment", String(view["displayName"]))
	target.set("current_death_text", String(view["deathText"]))
	target.set("last_comment_id", String(comment["id"]))
	var recent: Array[String] = target.get("recent_comment_categories") as Array[String]
	target.set("recent_comment_categories", updated_recent_categories(recent, String(comment.get("category", "default"))))
	apply_choice_numbers_to_target(target, view)
	target.set("effect_timer", maxf(5.0, float(comment["duration"]) - float(target.get("moderator_level"))))
	if int(target.get("reentry_barrier_level")) > 0:
		var barrier_time: float = 0.8 + 0.3 * float(target.get("reentry_barrier_level"))
		target.set("invincible", maxf(float(target.get("invincible")), barrier_time))
	return {"commentId": String(comment["id"])}

static func setup_stage_effects_for_target(target: Node, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var walls: Array = target.get("effect_walls") as Array
	var pits: Array = target.get("effect_pits") as Array
	var active: Array[String] = target.get("active_effects") as Array[String]
	walls.clear()
	pits.clear()
	if has_effect(active, "random_walls"):
		for i in range(4):
			var p := Vector2(rng.randf_range(arena.position.x + 120, arena.end.x - 180), rng.randf_range(arena.position.y + 110, arena.end.y - 120))
			walls.append(Rect2(p, Vector2(rng.randf_range(70, 140), 28)))
	if has_effect(active, "damage_pits"):
		for i in range(7):
			var p := Vector2(rng.randf_range(arena.position.x + 80, arena.end.x - 80), rng.randf_range(arena.position.y + 80, arena.end.y - 80))
			pits.append({"pos": p, "radius": rng.randf_range(24, 42)})

static func update_stage_hazards_for_target(target: Node, arena: Rect2) -> Dictionary:
	var player_pos: Vector2 = Vector2(target.get("player_pos"))
	var walls: Array = target.get("effect_walls") as Array
	var pits: Array = target.get("effect_pits") as Array
	for wall in walls:
		var rect: Rect2 = wall
		if rect.has_point(player_pos):
			player_pos = player_pos.move_toward(arena.get_center(), -8.0)
	var hit_pit: bool = false
	for pit in pits:
		if player_pos.distance_to(Vector2(pit["pos"])) < float(pit["radius"]) + 16.0:
			hit_pit = true
			break
	target.set("player_pos", player_pos)
	return {"hitPit": hit_pit}

static func update_stage_hazard_damage_for_target(target: Node, arena: Rect2) -> Dictionary:
	var result: Dictionary = update_stage_hazards_for_target(target, arena)
	if bool(result["hitPit"]):
		return DamageSystem.apply_damage_sources_for_target(target, ["ダメージ床"])
	return {"chats": [], "dead": false, "deathReason": ""}

static func update_effect_timer_for_target(target: Node, delta: float) -> Dictionary:
	var timer: float = float(target.get("effect_timer"))
	if timer <= 0.0:
		return {"cleared": false, "clearBonus": false}
	timer -= delta
	target.set("effect_timer", timer)
	if timer > 0.0:
		return {"cleared": false, "clearBonus": false}
	var clear_result: Dictionary = clear_state_for_target(target)
	return {
		"cleared": true,
		"clearBonus": bool(clear_result["clearBonus"])
	}

static func clear_state(context: Dictionary) -> Dictionary:
	var gift_hype: int = int(context.get("giftHype", 0))
	var max_gift_hype: int = int(context.get("maxGiftHype", 0))
	var pending_clear_hype: int = int(context.get("pendingClearHype", 0))
	var clear_bonus := false
	if pending_clear_hype > 0 and not bool(context.get("activeCommentHurt", false)):
		gift_hype = clampi(gift_hype + pending_clear_hype, 0, 100)
		max_gift_hype = maxi(max_gift_hype, gift_hype)
		clear_bonus = true
	return {
		"giftHype": gift_hype,
		"maxGiftHype": max_gift_hype,
		"clearBonus": clear_bonus,
		"currentComment": "なし",
		"currentDeathText": "発動中の指示コメなし",
		"lastCommentId": "",
		"multiplier": 1.0,
		"pendingClearHype": 0,
		"activeCommentHurt": false
	}

static func clear_state_for_target(target: Node) -> Dictionary:
	var clear_state_result: Dictionary = clear_state({
		"giftHype": target.get("gift_hype"),
		"maxGiftHype": target.get("max_gift_hype"),
		"pendingClearHype": target.get("pending_clear_hype"),
		"activeCommentHurt": target.get("active_comment_hurt")
	})
	target.set("gift_hype", int(clear_state_result["giftHype"]))
	target.set("max_gift_hype", int(clear_state_result["maxGiftHype"]))
	(target.get("active_effects") as Array).clear()
	(target.get("active_effect_rates") as Dictionary).clear()
	(target.get("effect_walls") as Array).clear()
	(target.get("effect_pits") as Array).clear()
	target.set("current_comment", String(clear_state_result["currentComment"]))
	target.set("current_death_text", String(clear_state_result["currentDeathText"]))
	target.set("last_comment_id", String(clear_state_result["lastCommentId"]))
	(target.get("recent_comment_categories") as Array).clear()
	target.set("multiplier", float(clear_state_result["multiplier"]))
	target.set("pending_clear_hype", int(clear_state_result["pendingClearHype"]))
	target.set("active_comment_hurt", bool(clear_state_result["activeCommentHurt"]))
	return clear_state_result
