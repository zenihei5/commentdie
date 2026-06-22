extends RefCounted
class_name CommentSystem

const DO_EVERYTHING_ID := "do_everything"
const DO_EVERYTHING_OFFER_CHANCE := 0.05
const DO_EVERYTHING_BUCKETS := [
	["attack_right_only", "reverse_control", "no_stop", "no_brake", "short_range"],
	["banana_floor", "damage_pits", "temp_walls", "camera_zoom", "hide_hp", "weapon_mute", "comment_barrage"],
	["enemy_speed_up", "giant_enemies", "enemy_spawn_up", "split_enemy"]
]

static func build_offer(context: Dictionary) -> Array:
	var result: Array = []
	var comments: Array = context["comments"] as Array
	var comment_time: float = float(context["commentTime"])
	var pick_time: float = _debug_rare_comment_time(context, comment_time)
	if _should_offer_do_everything(comments, context, pick_time):
		var special_offer: Array = _build_do_everything_offer(comments, context, pick_time)
		if not special_offer.is_empty():
			return special_offer
	if _debug_rare_comment_boost(context):
		result.append(_pick_for_slot(comments, context, pick_time, 2, 4, result))
		result.append(_pick_for_slot(comments, context, pick_time, 3, 4, result))
		result.append(_pick_for_slot(comments, context, pick_time, 3, 4, result))
		return result
	result.append(_pick_for_slot(comments, context, pick_time, 1, 2, result))
	result.append(_pick_for_slot(comments, context, pick_time, 2, 3, result))
	var max_risk: int = 4 if pick_time >= 60.0 else (3 if pick_time >= 30.0 else 2)
	result.append(_pick_for_slot(comments, context, pick_time, 1, max_risk, result))
	return result

static func build_offer_for_target(target: Node, comments: Array, rng: RandomNumberGenerator) -> Array:
	var offer: Array = build_offer({
		"comments": comments,
		"commentTime": target.get("elapsed"),
		"streamFrame": target.get("current_stream_frame"),
		"lastCommentId": target.get("last_comment_id"),
		"recentCategories": target.get("recent_comment_categories"),
		"yesListener": target.get("yes_listener"),
		"expLevel": target.get("exp_level"),
		"bossRequested": target.get("boss_requested"),
		"bossActive": target.get("boss_active"),
		"bossSummonCount": target.get("boss_summon_count"),
		"doEverythingOfferCount": target.get("do_everything_offer_count"),
		"debugRareCommentBoost": target.get("debug_rare_comment_boost"),
		"rng": rng
	})
	if _offer_has_do_everything(offer):
		target.set("do_everything_offer_count", int(target.get("do_everything_offer_count")) + 1)
	return offer

static func build_forced_do_everything_offer_for_target(target: Node, comments: Array, rng: RandomNumberGenerator) -> Array:
	var comment_time: float = maxf(float(target.get("elapsed")), _do_everything_min_time(comments))
	var context: Dictionary = {
		"comments": comments,
		"commentTime": comment_time,
		"streamFrame": target.get("current_stream_frame"),
		"lastCommentId": target.get("last_comment_id"),
		"recentCategories": target.get("recent_comment_categories"),
		"yesListener": target.get("yes_listener"),
		"expLevel": target.get("exp_level"),
		"bossRequested": false,
		"bossActive": false,
		"bossSummonCount": target.get("boss_summon_count"),
		"doEverythingOfferCount": 0,
		"rng": rng
	}
	var offer: Array = _build_do_everything_offer(comments, context, comment_time)
	if offer.size() == 4:
		return offer
	return _build_do_everything_fallback_offer(comments)

static func start_choice_for_target(target: Node, comments: Array, rng: RandomNumberGenerator, base_choice_time: float) -> Dictionary:
	target.set("state", "comment_choice")
	target.set("previous_state", "playing")
	target.set("choice_timer", maxf(1.0, base_choice_time + float(target.get("choice_time_bonus")) - float(target.get("choice_time_penalty"))))
	target.set("selected_card", 0)
	target.set("special_choice_return_card", 0)
	target.set("comment_warning_step", 0)
	var offer: Array = build_offer_for_target(target, comments, rng)
	target.set("offered_comments", offer)
	target.set("ng_cards", _bool_cards(false, offer.size()))
	var pending_heart: bool = bool(target.get("heart_pending"))
	target.set("heart_cards", _bool_cards(pending_heart, offer.size()))
	if pending_heart:
		target.set("heart_pending", false)
		target.set("heart_used_count", int(target.get("heart_used_count")) + 1)
		return {"chat": "♡発動！ 指示コメが全部ちょっと甘くなった"}
	return {"chat": "指示コメが来た！"}

static func start_choice_ui_for_target(target: Node, comments: Array, rng: RandomNumberGenerator, base_choice_time: float, choice_box: Control) -> Dictionary:
	var result: Dictionary = start_choice_for_target(target, comments, rng, base_choice_time)
	choice_box.visible = true
	return result

static func finish_choice_for_target(target: Node, interval: float) -> String:
	target.set("comment_timer", interval)
	target.set("comment_warning_step", 0)
	target.set("state", "playing")
	(target.get("heart_cards") as Array).clear()
	return String(target.get("current_comment")) + " を選択"

static func finish_choice_ui_for_target(target: Node, interval: float, choice_box: Control) -> String:
	var chat: String = finish_choice_for_target(target, interval)
	choice_box.visible = false
	return chat

static func choose_comment_for_target(target: Node, index: int, rng: RandomNumberGenerator) -> Dictionary:
	var offered_comments: Array = target.get("offered_comments") as Array
	var heart_cards: Array = target.get("heart_cards") as Array
	if index < 0 or index >= offered_comments.size():
		return {"selected": false, "commentId": ""}
	var comment: Dictionary = offered_comments[index] as Dictionary
	var has_heart: bool = index < heart_cards.size() and bool(heart_cards[index])
	var view: Dictionary = comment_view(comment, has_heart)
	var sub_comments: Array = []
	var sub_heart_cards: Array = []
	if _is_do_everything_comment(comment):
		for i in range(mini(3, offered_comments.size())):
			sub_comments.append(offered_comments[i])
			sub_heart_cards.append(i < heart_cards.size() and bool(heart_cards[i]))
	var result: Dictionary = ModifierSystem.start_comment_for_target(target, comment, view, has_heart, rng, sub_comments, sub_heart_cards)
	var modifier_feedback: Dictionary = result.get("feedback", {"chats": [], "toasts": []}) as Dictionary
	return {
		"selected": true,
		"commentId": String(result["commentId"]),
		"feedback": modifier_feedback
	}

static func choose_comment_with_feedback_for_target(
	target: Node,
	index: int,
	rng: RandomNumberGenerator,
	arena: Rect2,
	interval: float,
	choice_box: Control,
	genre_events: Array
) -> Dictionary:
	var result: Dictionary = choose_comment_for_target(target, index, rng)
	if not bool(result["selected"]):
		return {"selected": false, "toasts": [], "chats": []}
	var feedback: Dictionary = GenreEventSystem.start_comment_event_if_enabled_for_target(
		target,
		target.get("current_stream_frame") as Dictionary,
		String(result["commentId"]),
		genre_events,
		arena,
		rng
	)
	ModifierSystem.setup_stage_effects_for_target(target, arena, rng)
	var chats: Array = feedback.get("chats", []) as Array
	var modifier_feedback: Dictionary = result.get("feedback", {"chats": [], "toasts": []}) as Dictionary
	for item in (modifier_feedback.get("chats", []) as Array):
		chats.append(String(item))
	chats.append(finish_choice_ui_for_target(target, interval, choice_box))
	feedback["chats"] = chats
	var toasts: Array = feedback.get("toasts", []) as Array
	for item in (modifier_feedback.get("toasts", []) as Array):
		toasts.append(String(item))
	feedback["toasts"] = toasts
	feedback["selected"] = true
	return feedback

static func apply_forced_offer_to_target(target: Node, offer: Dictionary) -> bool:
	if offer.is_empty():
		return false
	target.set("offered_comments", offer["comments"] as Array)
	target.set("ng_cards", _bool_cards(false, 1))
	target.set("heart_cards", _bool_cards(bool(offer["heartCard"]), 1))
	return true

static func _bool_cards(value: bool, count: int) -> Array[bool]:
	var cards: Array[bool] = []
	for i in range(count):
		cards.append(value)
	return cards

static func build_forced_offer(comments: Array, id: String, has_heart: bool) -> Dictionary:
	for item in comments:
		var comment: Dictionary = item as Dictionary
		if String(comment["id"]) == id:
			return {
				"comments": [comment],
				"heartCard": has_heart
			}
	return {}

static func comment_view(comment: Dictionary, has_heart: bool) -> Dictionary:
	var view: Dictionary = comment.duplicate(true)
	if has_heart:
		if comment.has("heartVariant") and comment["heartVariant"] is Dictionary:
			var variant: Dictionary = comment["heartVariant"] as Dictionary
			for key in variant.keys():
				view[key] = variant[key]
		else:
			var display_name: String = String(comment["displayName"]) + "♡"
			view["displayName"] = display_name
			view["riskLevel"] = maxi(1, int(comment["riskLevel"]) - 1)
			view["multiplier"] = snappedf(float(comment["multiplier"]) * 0.8, 0.1)
			view["giftHypeOnSelect"] = int(round(float(comment["giftHypeOnSelect"]) * 0.75))
			view["giftHypeOnClear"] = int(round(float(comment["giftHypeOnClear"]) * 0.75))
			view["deathText"] = String(comment["deathText"]).replace(String(comment["displayName"]), display_name)
	if _is_do_everything_comment(comment):
		view["riskLevel"] = 5
		view["multiplier"] = 4.0 if has_heart else 5.0
		view["giftHypeOnSelect"] = 50 if has_heart else 70
		view["giftHypeOnClear"] = 20 if has_heart else 30
	return view

static func highest_multiplier_card(offered_comments: Array, heart_cards: Array, include_special: bool = false) -> int:
	var best_index: int = 0
	var best_multiplier: float = -1.0
	for i in range(offered_comments.size()):
		var comment: Dictionary = offered_comments[i] as Dictionary
		if not include_special and _is_do_everything_comment(comment):
			continue
		var has_heart: bool = i < heart_cards.size() and bool(heart_cards[i])
		var view: Dictionary = comment_view(comment, has_heart)
		var multiplier: float = float(view["multiplier"])
		if multiplier > best_multiplier:
			best_index = i
			best_multiplier = multiplier
	return best_index

static func use_ng_for_target(_target: Node) -> Dictionary:
	return {"changed": false, "chat": ""}

static func update_choice_timer_for_target(target: Node, delta: float) -> Dictionary:
	var timer: float = float(target.get("choice_timer")) - delta
	var warning_step: int = int(target.get("comment_warning_step"))
	var chats: Array[String] = []
	if timer <= 5.0 and warning_step < 1:
		warning_step = 1
		chats.append("残り5秒！")
	if timer <= 3.0 and warning_step < 2:
		warning_step = 2
		chats.append("コメント欄がざわついている")
	target.set("choice_timer", timer)
	target.set("comment_warning_step", warning_step)
	return {
		"chats": chats,
		"timedOut": timer <= 0.0
	}

static func update_choice_input_for_target(target: Node, delta: float, latch: Dictionary, _rng: RandomNumberGenerator) -> Dictionary:
	var timer_result: Dictionary = update_choice_timer_for_target(target, delta)
	var chats: Array = timer_result["chats"] as Array
	var refresh: bool = false
	var choose_index: int = -1
	var offered_comments: Array = target.get("offered_comments") as Array
	var heart_cards: Array = target.get("heart_cards") as Array
	var offer_count: int = maxi(1, offered_comments.size())
	var action: Dictionary = {}
	if _has_do_everything_special_card(offered_comments):
		action = ChoiceCardSystem.special_card_selection_action(latch, int(target.get("selected_card")), 3, int(target.get("special_choice_return_card")))
	else:
		action = ChoiceCardSystem.selection_action(latch, int(target.get("selected_card")), offer_count)
	if ChoiceCardSystem.is_move(action):
		target.set("selected_card", int(action["index"]))
		if action.has("returnIndex"):
			target.set("special_choice_return_card", int(action["returnIndex"]))
		refresh = true
	elif ChoiceCardSystem.is_select(action):
		choose_index = int(action["index"])
	elif bool(timer_result["timedOut"]):
		chats.append("指示コメに押し切られた！")
		var selected_index: int = clampi(int(target.get("selected_card")), 0, offer_count - 1)
		var selected_comment: Dictionary = offered_comments[selected_index] as Dictionary
		choose_index = selected_index if _is_do_everything_comment(selected_comment) else highest_multiplier_card(offered_comments, heart_cards)
	return {
		"chats": chats,
		"refresh": refresh,
		"chooseIndex": choose_index
	}

static func update_spawn_timer_for_target(target: Node, delta: float) -> Dictionary:
	if bool(target.get("boss_requested")) or bool(target.get("boss_active")):
		return {"chats": [], "shouldStart": false}
	var previous_timer: float = float(target.get("comment_timer"))
	var timer: float = previous_timer - delta
	var warning_step: int = int(target.get("comment_warning_step"))
	var chats: Array[String] = []
	if timer <= 5.0 and warning_step < 1:
		warning_step = 1
		chats.append("あと5秒で指示コメが来る")
	if timer <= 3.0 and warning_step < 2:
		warning_step = 2
		chats.append("コメント欄、加速中")
	if timer <= 2.0 and previous_timer > 2.0:
		chats.append("指示コメがざわついている……")
	target.set("comment_timer", timer)
	target.set("comment_warning_step", warning_step)
	return {
		"chats": chats,
		"shouldStart": timer <= 0.0
	}

static func _pick_for_slot(comments: Array, context: Dictionary, comment_time: float, min_risk: int, max_risk: int, used: Array) -> Dictionary:
	var pool: Array = []
	var frame: Dictionary = context["streamFrame"] as Dictionary
	var last_comment_id: String = String(context["lastCommentId"])
	var recent_categories: Array = context["recentCategories"] as Array
	var yes_listener: bool = bool(context["yesListener"])
	for item in comments:
		var comment: Dictionary = item as Dictionary
		if _is_special_only_comment(comment):
			continue
		if not _data_allowed_for_frame(frame, comment, "commentPoolTags"):
			continue
		if not _comment_allowed_for_context(comment, context, comment_time):
			continue
		if comment_time < float(comment["minTime"]):
			continue
		var risk: int = int(comment["riskLevel"])
		if risk < min_risk or risk > max_risk:
			continue
		if risk >= 4 and comment_time < 60.0:
			continue
		if String(comment["id"]) == last_comment_id:
			continue
		if used.has(comment):
			continue
		if recent_categories.size() >= 2:
			var category: String = String(comment.get("category", "default"))
			if String(recent_categories[0]) == category and String(recent_categories[1]) == category:
				continue
		for i in range(_comment_pick_weight(comment, context)):
			if yes_listener and int(comment["riskLevel"]) >= 3:
				pool.append(comment)
			pool.append(comment)
	if pool.is_empty():
		for item in comments:
			var fallback: Dictionary = item as Dictionary
			if not _is_special_only_comment(fallback) and _data_allowed_for_frame(frame, fallback, "commentPoolTags") and _comment_allowed_for_context(fallback, context, comment_time) and comment_time >= float(fallback["minTime"]) and not used.has(fallback):
				pool.append(fallback)
	if pool.is_empty():
		return comments[0] as Dictionary
	var rng: RandomNumberGenerator = context["rng"] as RandomNumberGenerator
	return pool[rng.randi_range(0, pool.size() - 1)] as Dictionary

static func _debug_rare_comment_boost(context: Dictionary) -> bool:
	return bool(context.get("debugRareCommentBoost", false))

static func _debug_rare_comment_time(context: Dictionary, comment_time: float) -> float:
	if _debug_rare_comment_boost(context):
		return maxf(comment_time, 90.0)
	return comment_time

static func _comment_pick_weight(comment: Dictionary, context: Dictionary) -> int:
	var weight: int = maxi(1, int(comment.get("weight", 1)))
	if not _debug_rare_comment_boost(context):
		return weight
	var risk: int = int(comment.get("riskLevel", 1))
	if risk >= 4:
		return weight * 12
	if risk >= 3:
		return weight * 4
	if weight <= 5:
		return weight * 3
	return weight

static func _should_offer_do_everything(comments: Array, context: Dictionary, comment_time: float) -> bool:
	var comment: Dictionary = _find_comment_by_id(comments, DO_EVERYTHING_ID)
	if comment.is_empty():
		return false
	if comment_time < float(comment.get("minTime", 60.0)):
		return false
	if int(context.get("doEverythingOfferCount", 0)) >= int(comment.get("maxOfferCountPerRun", 1)):
		return false
	if bool(context.get("bossRequested", false)) or bool(context.get("bossActive", false)):
		return false
	var rng: RandomNumberGenerator = context["rng"] as RandomNumberGenerator
	var offer_chance: float = float(comment.get("offerChance", DO_EVERYTHING_OFFER_CHANCE))
	if _debug_rare_comment_boost(context):
		offer_chance = maxf(offer_chance, 0.45)
	return rng.randf() < offer_chance

static func _build_do_everything_offer(comments: Array, context: Dictionary, comment_time: float) -> Array:
	var result: Array = []
	for bucket in DO_EVERYTHING_BUCKETS:
		var bucket_ids: Array = bucket as Array
		var picked: Dictionary = _pick_from_id_pool(bucket_ids, comments, context, comment_time, result)
		if picked.is_empty():
			return []
		result.append(picked)
	var special: Dictionary = _find_comment_by_id(comments, DO_EVERYTHING_ID)
	if special.is_empty():
		return []
	result.append(special)
	return result

static func _build_do_everything_fallback_offer(comments: Array) -> Array:
	var result: Array = []
	for bucket in DO_EVERYTHING_BUCKETS:
		var bucket_ids: Array = bucket as Array
		var picked: Dictionary = {}
		for id in bucket_ids:
			var comment: Dictionary = _find_comment_by_id(comments, String(id))
			if not comment.is_empty() and not result.has(comment):
				picked = comment
				break
		if picked.is_empty():
			return []
		result.append(picked)
	var special: Dictionary = _find_comment_by_id(comments, DO_EVERYTHING_ID)
	if special.is_empty():
		return []
	result.append(special)
	return result

static func _do_everything_min_time(comments: Array) -> float:
	var comment: Dictionary = _find_comment_by_id(comments, DO_EVERYTHING_ID)
	if comment.is_empty():
		return 60.0
	return float(comment.get("minTime", 60.0))

static func _pick_from_id_pool(ids: Array, comments: Array, context: Dictionary, comment_time: float, used: Array) -> Dictionary:
	var pool: Array = []
	var frame: Dictionary = context["streamFrame"] as Dictionary
	var last_comment_id: String = String(context["lastCommentId"])
	var yes_listener: bool = bool(context["yesListener"])
	for item in comments:
		var comment: Dictionary = item as Dictionary
		var id: String = String(comment.get("id", ""))
		if not ids.has(id):
			continue
		if used.has(comment) or id == last_comment_id:
			continue
		if _is_special_only_comment(comment):
			continue
		if not _data_allowed_for_frame(frame, comment, "commentPoolTags"):
			continue
		if not _comment_allowed_for_context(comment, context, comment_time):
			continue
		if comment_time < float(comment.get("minTime", 0.0)):
			continue
		for i in range(_comment_pick_weight(comment, context)):
			if yes_listener and int(comment.get("riskLevel", 1)) >= 3:
				pool.append(comment)
			pool.append(comment)
	if pool.is_empty():
		return {}
	var rng: RandomNumberGenerator = context["rng"] as RandomNumberGenerator
	return pool[rng.randi_range(0, pool.size() - 1)] as Dictionary

static func _find_comment_by_id(comments: Array, id: String) -> Dictionary:
	for item in comments:
		var comment: Dictionary = item as Dictionary
		if String(comment.get("id", "")) == id:
			return comment
	return {}

static func _offer_has_do_everything(offer: Array) -> bool:
	for item in offer:
		if _is_do_everything_comment(item as Dictionary):
			return true
	return false

static func _has_do_everything_special_card(offer: Array) -> bool:
	return offer.size() > 3 and _is_do_everything_comment(offer[3] as Dictionary)

static func _is_do_everything_comment(comment: Dictionary) -> bool:
	return String(comment.get("id", "")) == DO_EVERYTHING_ID

static func _is_special_only_comment(comment: Dictionary) -> bool:
	return _is_do_everything_comment(comment) or bool(comment.get("isSpecialChoice", false)) or bool(comment.get("excludedFromNormalChoices", false))

static func _comment_allowed_for_context(comment: Dictionary, context: Dictionary, comment_time: float) -> bool:
	if String(comment.get("effectType", "")) != "summon_boss" and String(comment.get("id", "")) != "summon_boss":
		return true
	if comment_time < float(comment.get("minTime", 60.0)):
		return false
	if int(context.get("expLevel", 1)) < int(comment.get("requiredPlayerLevel", 3)):
		return false
	if int(context.get("bossSummonCount", 0)) >= int(comment.get("maxSelectCountPerRun", 1)):
		return false
	if bool(context.get("bossRequested", false)) or bool(context.get("bossActive", false)):
		return false
	return true

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

