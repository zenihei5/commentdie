extends RefCounted
class_name CommentSystem

static func build_offer(context: Dictionary) -> Array:
	var result: Array = []
	var comments: Array = context["comments"] as Array
	var comment_time: float = float(context["commentTime"])
	result.append(_pick_for_slot(comments, context, comment_time, 1, 2, result))
	result.append(_pick_for_slot(comments, context, comment_time, 2, 3, result))
	var max_risk: int = 4 if comment_time >= 60.0 else (3 if comment_time >= 30.0 else 2)
	result.append(_pick_for_slot(comments, context, comment_time, 1, max_risk, result))
	return result

static func build_offer_for_target(target: Node, comments: Array, rng: RandomNumberGenerator) -> Array:
	return build_offer({
		"comments": comments,
		"commentTime": target.get("elapsed"),
		"streamFrame": target.get("current_stream_frame"),
		"lastCommentId": target.get("last_comment_id"),
		"recentCategories": target.get("recent_comment_categories"),
		"yesListener": target.get("yes_listener"),
		"rng": rng
	})

static func start_choice_for_target(target: Node, comments: Array, rng: RandomNumberGenerator, base_choice_time: float) -> Dictionary:
	target.set("state", "comment_choice")
	target.set("previous_state", "playing")
	target.set("choice_timer", maxf(1.0, base_choice_time + float(target.get("choice_time_bonus")) - float(target.get("choice_time_penalty"))))
	target.set("selected_card", 0)
	target.set("comment_warning_step", 0)
	target.set("offered_comments", build_offer_for_target(target, comments, rng))
	target.set("ng_cards", _bool_cards(false, 3))
	target.set("heart_cards", _bool_cards(false, 3))
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
	var ng_cards: Array = target.get("ng_cards") as Array
	var heart_cards: Array = target.get("heart_cards") as Array
	if index < 0 or index >= offered_comments.size():
		return {"selected": false, "commentId": ""}
	if index < ng_cards.size() and bool(ng_cards[index]):
		return {"selected": false, "commentId": ""}
	var comment: Dictionary = offered_comments[index] as Dictionary
	var has_heart: bool = index < heart_cards.size() and bool(heart_cards[index])
	var view: Dictionary = comment_view(comment, has_heart)
	var result: Dictionary = ModifierSystem.start_comment_for_target(target, comment, view, has_heart, rng)
	return {
		"selected": true,
		"commentId": String(result["commentId"])
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
	chats.append(finish_choice_ui_for_target(target, interval, choice_box))
	feedback["chats"] = chats
	feedback["selected"] = true
	return feedback

static func apply_forced_offer_to_target(target: Node, offer: Dictionary) -> bool:
	if offer.is_empty():
		return false
	target.set("offered_comments", offer["comments"] as Array)
	target.set("ng_cards", _bool_cards(bool(offer["ngCard"]), 1))
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
				"ngCard": false,
				"heartCard": has_heart
			}
	return {}

static func comment_view(comment: Dictionary, has_heart: bool) -> Dictionary:
	var view: Dictionary = comment.duplicate(true)
	if not has_heart:
		return view
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
	return view

static func highest_multiplier_card(offered_comments: Array, ng_cards: Array, heart_cards: Array) -> int:
	var best_index: int = 0
	var best_multiplier: float = -1.0
	for i in range(offered_comments.size()):
		if i < ng_cards.size() and bool(ng_cards[i]):
			continue
		var comment: Dictionary = offered_comments[i] as Dictionary
		var has_heart: bool = i < heart_cards.size() and bool(heart_cards[i])
		var view: Dictionary = comment_view(comment, has_heart)
		var multiplier: float = float(view["multiplier"])
		if multiplier > best_multiplier:
			best_index = i
			best_multiplier = multiplier
	return best_index

static func use_ng_for_target(target: Node) -> Dictionary:
	var selected_card: int = int(target.get("selected_card"))
	var ng_cards: Array = target.get("ng_cards") as Array
	if int(target.get("ng_stock")) <= 0 or selected_card >= ng_cards.size() or bool(ng_cards[selected_card]):
		return {"changed": false, "chat": ""}
	target.set("ng_stock", int(target.get("ng_stock")) - 1)
	ng_cards[selected_card] = true
	return {"changed": true, "chat": "その指示コメ、NGで"}

static func use_heart_for_target(target: Node, rng: RandomNumberGenerator) -> Dictionary:
	var selected_card: int = int(target.get("selected_card"))
	var heart_cards: Array = target.get("heart_cards") as Array
	var ng_cards: Array = target.get("ng_cards") as Array
	if int(target.get("heart_stock")) <= 0 or selected_card >= heart_cards.size():
		return {"changed": false, "chat": ""}
	if selected_card < ng_cards.size() and bool(ng_cards[selected_card]):
		return {"changed": false, "chat": ""}
	if bool(heart_cards[selected_card]):
		return {"changed": false, "chat": ""}
	target.set("heart_stock", int(target.get("heart_stock")) - 1)
	target.set("heart_used_count", int(target.get("heart_used_count")) + 1)
	heart_cards[selected_card] = true
	var heart_lines: Array[String] = ["語尾かわいい", "圧が抜けたｗ", "それならいけるか？", "♡つければ許されると思うな"]
	return {"changed": true, "chat": heart_lines[rng.randi_range(0, heart_lines.size() - 1)]}

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

static func update_choice_input_for_target(target: Node, delta: float, latch: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var timer_result: Dictionary = update_choice_timer_for_target(target, delta)
	var chats: Array = timer_result["chats"] as Array
	var refresh: bool = false
	var choose_index: int = -1
	var action: Dictionary = ChoiceCardSystem.selection_action(latch, int(target.get("selected_card")), 3)
	if ChoiceCardSystem.is_move(action):
		target.set("selected_card", int(action["index"]))
		refresh = true
	elif Input.is_key_pressed(KEY_Q):
		var ng_result: Dictionary = use_ng_for_target(target)
		if bool(ng_result["changed"]):
			chats.append(String(ng_result["chat"]))
			refresh = true
	elif Input.is_key_pressed(KEY_H):
		var heart_result: Dictionary = use_heart_for_target(target, rng)
		if bool(heart_result["changed"]):
			chats.append(String(heart_result["chat"]))
			refresh = true
	elif ChoiceCardSystem.is_select(action):
		choose_index = int(action["index"])
	elif bool(timer_result["timedOut"]):
		chats.append("指示コメに押し切られた！")
		choose_index = highest_multiplier_card(
			target.get("offered_comments") as Array,
			target.get("ng_cards") as Array,
			target.get("heart_cards") as Array
		)
	return {
		"chats": chats,
		"refresh": refresh,
		"chooseIndex": choose_index
	}

static func update_spawn_timer_for_target(target: Node, delta: float) -> Dictionary:
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
		if not _data_allowed_for_frame(frame, comment, "commentPoolTags"):
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
		if String(comment["id"]) == "do_everything" and last_comment_id == "do_everything":
			continue
		if used.has(comment):
			continue
		if recent_categories.size() >= 2:
			var category: String = String(comment.get("category", "default"))
			if String(recent_categories[0]) == category and String(recent_categories[1]) == category:
				continue
		for i in range(int(comment["weight"])):
			if yes_listener and int(comment["riskLevel"]) >= 3:
				pool.append(comment)
			pool.append(comment)
	if pool.is_empty():
		for item in comments:
			var fallback: Dictionary = item as Dictionary
			if _data_allowed_for_frame(frame, fallback, "commentPoolTags") and comment_time >= float(fallback["minTime"]) and not used.has(fallback):
				pool.append(fallback)
	if pool.is_empty():
		return comments[0] as Dictionary
	var rng: RandomNumberGenerator = context["rng"] as RandomNumberGenerator
	return pool[rng.randi_range(0, pool.size() - 1)] as Dictionary

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

