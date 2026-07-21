class_name ModifierSystem
extends RefCounted

const BossSystemScript := preload("res://scripts/systems/boss_system.gd")
const BuzzSystemScript := preload("res://scripts/systems/buzz_system.gd")

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

static func set_multiplier_source_for_target(target: Node, source_id: String, multipliers: Dictionary) -> void:
	if source_id == "":
		return
	var sources: Dictionary = {}
	var current: Variant = target.get("modifier_sources")
	if current is Dictionary:
		sources = current as Dictionary
	sources[source_id] = multipliers.duplicate(true)
	target.set("modifier_sources", sources)

static func remove_multiplier_source_for_target(target: Node, source_id: String) -> void:
	var current: Variant = target.get("modifier_sources")
	if not current is Dictionary:
		return
	var sources: Dictionary = current as Dictionary
	sources.erase(source_id)
	target.set("modifier_sources", sources)

static func combined_multiplier_for_target(target: Node, key: String, fallback: float = 1.0) -> float:
	var current: Variant = target.get("modifier_sources")
	if not current is Dictionary:
		return fallback
	var result := fallback
	var found := false
	for source_value in (current as Dictionary).values():
		if not source_value is Dictionary:
			continue
		var source: Dictionary = source_value as Dictionary
		if not source.has(key):
			continue
		result *= float(source.get(key, fallback))
		found = true
	return result if found else fallback

static func build_activation(comment: Dictionary, has_heart: bool, rng: RandomNumberGenerator, sub_comments: Array = [], _sub_heart_cards: Array = []) -> Dictionary:
	var effects: Array[String] = []
	var rates: Dictionary = {}
	var rate: float = 0.7 if has_heart else 1.0
	if String(comment["id"]) == "do_everything":
		if sub_comments.is_empty():
			var candidates: Array[String] = ["attack_right_only", "reverse_control", "no_stop", "banana_floor", "camera_zoom", "enemy_speed_up"]
			candidates.shuffle()
			for i in range(3):
				effects.append(String(candidates[i]))
				rates[String(candidates[i])] = rate
		else:
			for item in sub_comments:
				var sub_comment: Dictionary = item as Dictionary
				var id: String = String(sub_comment.get("id", ""))
				if id == "" or id == "do_everything" or id == "summon_boss" or effects.has(id):
					continue
				effects.append(id)
				rates[id] = rate
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

static func buzz_gain_for_risk(risk: int) -> int:
	return BuzzSystemScript.gain_for_risk(risk)

static func apply_choice_numbers(context: Dictionary) -> Dictionary:
	var view: Dictionary = context["view"] as Dictionary
	var multiplier: float = float(view["multiplier"]) * (1.2 if bool(context.get("commentBoost", false)) else 1.0)
	var max_multiplier: float = maxf(float(context.get("maxMultiplier", 1.0)), multiplier)
	var danger_comments_chosen: int = int(context.get("dangerCommentsChosen", 0))
	var risk: int = int(view["riskLevel"])
	var buzz_state: Dictionary = BuzzSystemScript.instruction_transition(int(context.get("burnCombo", 0)), int(context.get("burnComboMax", 0)), risk)
	var buzz_before: int = int(buzz_state["buzzBefore"])
	var burn_combo: int = int(buzz_state["buzzAfter"])
	if risk >= 3:
		danger_comments_chosen += 1
	var burn_combo_max: int = int(buzz_state["burnComboMax"])
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
		"buzzBefore": buzz_before,
		"buzzAfter": burn_combo,
		"buzzDelta": burn_combo - buzz_before,
		"buzzGainRequested": int(buzz_state["buzzGainRequested"]),
		"buzzChanged": bool(buzz_state["buzzChanged"]),
		"buzzReachedMax": bool(buzz_state["buzzReachedMax"]),
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
	if bool(target.get("relay_mode")):
		target.set("multiplier", maxf(float(target.get("relay_base_multiplier")), float(number_state["multiplier"])))
	else:
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

static func start_comment_for_target(target: Node, comment: Dictionary, view: Dictionary, has_heart: bool, rng: RandomNumberGenerator, sub_comments: Array = [], sub_heart_cards: Array = []) -> Dictionary:
	var activation: Dictionary = build_activation(comment, has_heart, rng, sub_comments, sub_heart_cards)
	target.set("active_effects", activation["effects"] as Array[String])
	target.set("active_effect_rates", activation["rates"] as Dictionary)
	if String(comment["id"]) == "do_everything":
		var sub_ids: Array[String] = []
		for item in sub_comments:
			var sub_comment: Dictionary = item as Dictionary
			var id: String = String(sub_comment.get("id", ""))
			if id != "" and id != "do_everything" and id != "summon_boss":
				sub_ids.append(id)
		target.set("active_sub_comment_ids", sub_ids)
	elif target.get("active_sub_comment_ids") != null:
		(target.get("active_sub_comment_ids") as Array).clear()
	target.set("current_comment", String(view["displayName"]))
	target.set("current_death_text", String(view["deathText"]))
	target.set("last_comment_id", String(comment["id"]))
	var recent: Array[String] = target.get("recent_comment_categories") as Array[String]
	target.set("recent_comment_categories", updated_recent_categories(recent, String(comment.get("category", "default"))))
	var number_state: Dictionary = apply_choice_numbers_to_target(target, view)
	var effect_duration := _effect_duration_for_target(target, comment)
	if bool(target.get("relay_mode")):
		var relay_config: Dictionary = target.get("relay_mode_config") as Dictionary
		var instruction: Dictionary = relay_config.get("instruction", {}) as Dictionary
		effect_duration = float(instruction.get("effectTime", 15.0))
	target.set("effect_timer", effect_duration)
	if int(target.get("reentry_barrier_level")) > 0:
		var barrier_time: float = 0.8 + 0.3 * float(target.get("reentry_barrier_level"))
		target.set("invincible", maxf(float(target.get("invincible")), barrier_time))
	var feedback: Dictionary = {"chats": [], "toasts": []}
	if String(comment.get("effectType", "")) == "summon_boss" or String(comment.get("id", "")) == "summon_boss":
		feedback = BossSystemScript.request_summon_for_target(target, view, has_heart)
	elif String(comment.get("effectType", "")) == "song_instruction":
		var event_id := _song_instruction_event_id(String(comment.get("id", "")))
		if event_id != "":
			feedback["commentEventIds"] = [event_id]
	elif String(comment.get("effectType", "")) == "drawing_instruction":
		var event_id := _drawing_instruction_event_id(String(comment.get("id", "")))
		if event_id != "":
			feedback["commentEventIds"] = [event_id]
	elif String(comment.get("effectType", "")) == "collab_instruction":
		var event_id := _collab_instruction_event_id(String(comment.get("id", "")))
		if event_id != "":
			feedback["commentEventIds"] = [event_id]
	feedback["buzzBefore"] = int(number_state.get("buzzBefore", target.get("burn_combo")))
	feedback["buzzAfter"] = int(number_state.get("buzzAfter", target.get("burn_combo")))
	feedback["buzzDelta"] = int(number_state.get("buzzDelta", 0))
	feedback["buzzGainRequested"] = int(number_state.get("buzzGainRequested", 0))
	feedback["buzzChanged"] = bool(number_state.get("buzzChanged", false))
	feedback["buzzReachedMax"] = bool(number_state.get("buzzReachedMax", false))
	return {"commentId": String(comment["id"]), "feedback": feedback}

static func _song_instruction_event_id(comment_id: String) -> String:
	match comment_id:
		"song_tempo_up":
			return "song_instruction_tempo_up"
		"song_force_chorus":
			return "song_instruction_force_chorus"
		"song_mic_howling":
			return "song_instruction_mic_howling"
		"song_lighting_mistake":
			return "song_instruction_lighting_mistake"
		"song_lyrics_lost":
			return "song_instruction_lyrics_lost"
	return ""

static func _drawing_instruction_event_id(comment_id: String) -> String:
	match comment_id:
		"drawing_paint_rush":
			return "drawing_instruction_paint_rush"
		"drawing_fix_here":
			return "drawing_instruction_fix_here"
		"drawing_clean_screen":
			return "drawing_instruction_clean_screen"
		"drawing_fast_dry":
			return "drawing_instruction_fast_dry"
		"drawing_too_much_paint":
			return "drawing_instruction_too_much_paint"
		"drawing_palette_shuffle":
			return "drawing_instruction_palette_shuffle"
		"drawing_more_corrections":
			return "drawing_instruction_more_corrections"
		"drawing_spilled_bucket":
			return "drawing_instruction_spilled_bucket"
	return ""

static func _collab_instruction_event_id(comment_id: String) -> String:
	match comment_id:
		"partner_take_over":
			return "collab_instruction_partner_take_over"
		"dont_fail_collab":
			return "collab_instruction_dont_fail"
		"keep_sync":
			return "collab_instruction_keep_sync"
		"out_of_sync":
			return "collab_instruction_out_of_sync"
		"fast_collab_pass":
			return "collab_instruction_fast_pass"
	return ""

static func _effect_duration_for_target(_target: Node, comment: Dictionary) -> float:
	var duration := float(comment["duration"])
	var comment_id := String(comment.get("id", ""))
	if comment_id == "song_lyrics_lost":
		var params: Dictionary = comment.get("params", {}) as Dictionary
		return maxf(duration, float(params.get("lyricsCardLifetime", duration)))
	return maxf(5.0, duration)

static func setup_stage_effects_for_target(target: Node, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var walls: Array = target.get("effect_walls") as Array
	var pits: Array = target.get("effect_pits") as Array
	var active: Array[String] = target.get("active_effects") as Array[String]
	walls.clear()
	pits.clear()
	if has_effect(active, "random_walls"):
		var player_pos: Vector2 = Vector2(target.get("player_pos"))
		var wall_count: int = rng.randi_range(7, 9)
		var min_player_distance: float = 150.0
		for i in range(wall_count):
			var wall_size: Vector2 = Vector2.ZERO
			if rng.randf() < 0.72:
				wall_size = Vector2(rng.randf_range(190.0, 420.0), rng.randf_range(34.0, 46.0))
			else:
				wall_size = Vector2(rng.randf_range(38.0, 52.0), rng.randf_range(150.0, 300.0))
			var wall_pos: Vector2 = Vector2.ZERO
			for attempt in range(18):
				wall_pos = Vector2(
					rng.randf_range(arena.position.x + 90.0, arena.end.x - wall_size.x - 90.0),
					rng.randf_range(arena.position.y + 90.0, arena.end.y - wall_size.y - 90.0)
				)
				if Rect2(wall_pos, wall_size).get_center().distance_to(player_pos) >= min_player_distance:
					break
			walls.append(Rect2(wall_pos, wall_size))
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
		return DamageSystem.apply_damage_events_for_target(target, [{"source": "damage_pit", "damage": DamageSystem.STAGE_HAZARD_DAMAGE}])
	return {"chats": [], "dead": false, "deathReason": ""}

static func update_effect_timer_for_target(target: Node, delta: float) -> Dictionary:
	var timer: float = float(target.get("effect_timer"))
	if timer <= 0.0:
		return {"cleared": false, "clearBonus": false}
	timer -= delta
	target.set("effect_timer", timer)
	if timer > 0.0:
		return {"cleared": false, "clearBonus": false}
	if target.has_method("_should_suppress_instruction_clear_bonus") and bool(target.call("_should_suppress_instruction_clear_bonus")):
		target.set("active_comment_hurt", true)
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
	if bool(target.get("relay_mode")):
		clear_state_result["clearBonus"] = false
		clear_state_result["pendingClearHype"] = 0
		clear_state_result["multiplier"] = maxf(1.0, float(target.get("relay_base_multiplier")))
	target.set("gift_hype", int(clear_state_result["giftHype"]))
	target.set("max_gift_hype", int(clear_state_result["maxGiftHype"]))
	target.set("effect_timer", 0.0)
	(target.get("active_effects") as Array).clear()
	(target.get("active_effect_rates") as Dictionary).clear()
	(target.get("effect_walls") as Array).clear()
	(target.get("effect_pits") as Array).clear()
	target.set("current_comment", String(clear_state_result["currentComment"]))
	target.set("current_death_text", String(clear_state_result["currentDeathText"]))
	target.set("last_comment_id", String(clear_state_result["lastCommentId"]))
	if target.get("active_sub_comment_ids") != null:
		(target.get("active_sub_comment_ids") as Array).clear()
	(target.get("recent_comment_categories") as Array).clear()
	target.set("multiplier", float(clear_state_result["multiplier"]))
	target.set("pending_clear_hype", int(clear_state_result["pendingClearHype"]))
	target.set("active_comment_hurt", bool(clear_state_result["activeCommentHurt"]))
	return clear_state_result
