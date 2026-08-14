extends RefCounted
class_name CommentSystem

const PauseReasonSystemScript := preload("res://scripts/systems/pause_reason_system.gd")
const HardModeSystemScript := preload("res://scripts/systems/hard_mode_system.gd")

const DO_EVERYTHING_ID := "do_everything"
const DO_EVERYTHING_OFFER_CHANCE := 0.05
const DO_EVERYTHING_BUCKETS := [
	["attack_right_only", "reverse_control", "no_stop", "no_brake", "short_range"],
	["banana_floor", "damage_pits", "temp_walls", "camera_zoom", "hide_hp", "weapon_mute", "comment_barrage"],
	["enemy_speed_up", "giant_enemies", "enemy_spawn_up", "split_enemy"]
]
const SONG_INSTRUCTION_PICK_WEIGHT_MULTIPLIER := 1.6
const DRAWING_INSTRUCTION_PICK_WEIGHT_MULTIPLIER := 1.45
const COLLAB_INSTRUCTION_PICK_WEIGHT_MULTIPLIER := 1.45
const INSTRUCTION_COMMENT_ICON_DIRECTORY := "res://assets/generated/instruction_comment_icons_v1/"
const INSTRUCTION_COMMENT_ICON_IDS := [
	"banana_floor", "reverse_control", "no_dash", "no_brake", "no_stop",
	"giant_enemies", "enemy_speed_up", "enemy_spawn_up", "split_enemy",
	"short_range", "takeback", "attack_right_only", "weapon_mute", "temp_walls",
	"damage_pits", "hide_hp", "comment_barrage", "genre_change", "force_bullet_hell",
	"force_race", "force_horror", "kamiyoyaku", "camera_zoom", "summon_boss",
	"hard_reignition_boss", "hard_overclock", "hard_pressure_wave",
	"talk_comment_avalanche", "game_genre_mix", "song_tempo_up", "song_force_chorus",
	"song_mic_howling", "song_lighting_mistake", "song_lyrics_lost", "drawing_fast_dry",
	"drawing_too_much_paint", "drawing_palette_shuffle", "drawing_more_corrections",
	"drawing_spilled_bucket", "partner_take_over", "dont_fail_collab", "keep_sync",
	"out_of_sync", "fast_collab_pass", "boss_support_dont_lose",
	"boss_support_do_your_best", "relay_boss_attack_up", "relay_boss_projectiles_up",
	"relay_boss_movement_up", "relay_boss_no_dash", "relay_boss_partner_mute",
	"relay_boss_small_arena"
]
static var _empty_offer_warning_logged := false

## Shared source for the instruction-comment images used by the live choice UI.
## The codex reads this same path so a comment never gets a different image in
## the archive.  Special cards without an image intentionally return an empty
## path and use their existing card fallback.
static func instruction_comment_icon_path(comment_id: String) -> String:
	var normalized_id := comment_id.strip_edges()
	if normalized_id == "" or normalized_id == DO_EVERYTHING_ID:
		return ""
	if not INSTRUCTION_COMMENT_ICON_IDS.has(normalized_id):
		return ""
	return "%s%s_icon.png" % [INSTRUCTION_COMMENT_ICON_DIRECTORY, normalized_id]

static func build_offer(context: Dictionary) -> Array:
	var result: Array = []
	var comments: Array = context["comments"] as Array
	var comment_time: float = float(context["commentTime"])
	var pick_time: float = _debug_rare_comment_time(context, comment_time)
	if _debug_rare_comment_boost(context):
		result.append(_pick_for_slot(comments, context, pick_time, 2, 4, result))
		result.append(_pick_for_slot(comments, context, pick_time, 3, 4, result))
		result.append(_pick_for_slot(comments, context, pick_time, 3, 4, result))
		return result
	result.append(_pick_for_slot(comments, context, pick_time, 1, 2, result))
	result.append(_pick_for_slot(comments, context, pick_time, 2, 3, result))
	var max_risk: int = 4 if pick_time >= 60.0 else (3 if pick_time >= 30.0 else 2)
	result.append(_pick_for_slot(comments, context, pick_time, 1, max_risk, result))
	# do_everything is always the optional fourth card.  The first three cards
	# are the ordinary offer and remain selectable independently.
	if result.size() == 3 and _should_offer_do_everything(comments, context, pick_time):
		var special: Dictionary = _find_comment_by_id(comments, DO_EVERYTHING_ID)
		if not special.is_empty():
			result.append(special.duplicate(true))
	return result

static func build_offer_for_target(target: Node, comments: Array, rng: RandomNumberGenerator) -> Array:
	var frame: Dictionary = target.get("current_stream_frame") as Dictionary
	var difficulty_value: Variant = target.get("run_difficulty_id")
	var difficulty_id := String(difficulty_value if difficulty_value != null else "normal").strip_edges().to_lower()
	var frame_comments := comments_allowed_for_frame(frame, comments, difficulty_id)
	var hard_offer := HardModeSystemScript.build_offer_for_target(target, frame_comments, rng)
	if not hard_offer.is_empty():
		if _offer_has_do_everything(hard_offer):
			target.set("do_everything_offer_count", int(target.get("do_everything_offer_count")) + 1)
		return hard_offer
	var do_everything_count := int(target.get("do_everything_offer_count"))
	if bool(target.get("relay_mode")):
		do_everything_count = 999
	var offer: Array = build_offer({
		"comments": frame_comments,
		"commentTime": target.get("elapsed"),
		"streamFrame": target.get("current_stream_frame"),
		"lastCommentId": target.get("last_comment_id"),
		"recentCategories": target.get("recent_comment_categories"),
		"yesListener": target.get("yes_listener"),
		"expLevel": target.get("exp_level"),
		"bossRequested": target.get("boss_requested"),
		"bossActive": target.get("boss_active"),
		"bossSummonCount": target.get("boss_summon_count"),
		"doEverythingOfferCount": do_everything_count,
		"relayMode": target.get("relay_mode"),
		"activeGenreEvent": target.get("active_genre_event"),
		"songChorusActive": float(target.get("song_chorus_timer")) > 0.0 or float(target.get("song_chorus_telegraph_timer")) > 0.0,
		"collabChallengeActive": target.has_method("_collab_challenge_active") and bool(target.call("_collab_challenge_active")),
		"difficultyRuntime": target.get("difficulty_runtime"),
		"debugRareCommentBoost": target.get("debug_rare_comment_boost"),
		"rng": rng
	})
	if _offer_has_do_everything(offer):
		target.set("do_everything_offer_count", int(target.get("do_everything_offer_count")) + 1)
	return offer

static func build_forced_do_everything_offer_for_target(target: Node, comments: Array, rng: RandomNumberGenerator) -> Array:
	var frame: Dictionary = target.get("current_stream_frame") as Dictionary
	var difficulty_value: Variant = target.get("run_difficulty_id")
	var difficulty_id := String(difficulty_value if difficulty_value != null else "normal").strip_edges().to_lower()
	var frame_comments := comments_allowed_for_frame(frame, comments, difficulty_id)
	var comment_time: float = maxf(float(target.get("elapsed")), _do_everything_min_time(frame_comments))
	var context: Dictionary = {
		"comments": frame_comments,
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
		"activeGenreEvent": target.get("active_genre_event"),
		"difficultyRuntime": target.get("difficulty_runtime"),
		"rng": rng
	}
	var offer: Array = _build_do_everything_offer(frame_comments, context, comment_time)
	if offer.size() == 4:
		return offer
	return _build_do_everything_fallback_offer(frame_comments)

static func start_choice_for_target(target: Node, comments: Array, rng: RandomNumberGenerator, base_choice_time: float) -> Dictionary:
	# The card renderer is intentionally fixed at three slots.  Validate and
	# repair before changing the game state or adding a pause reason so an empty
	# candidate pool cannot expose stale/blank cards.
	var offer: Array = build_offer_for_target(target, comments, rng)
	if not _valid_three_card_offer(offer):
		offer = _repair_offer_for_target(target, comments, rng)
	if not _valid_three_card_offer(offer):
		if not _empty_offer_warning_logged:
			_empty_offer_warning_logged = true
			push_warning("CommentSystem: no safe three-card offer; retrying without opening the choice UI")
		target.set("offered_comments", [])
		var ng_cards: Variant = target.get("ng_cards")
		if ng_cards is Array:
			(ng_cards as Array).clear()
		var heart_cards: Variant = target.get("heart_cards")
		if heart_cards is Array:
			(heart_cards as Array).clear()
		target.set("comment_timer", 0.25)
		target.set("comment_warning_step", 0)
		return {"chat": "指示コメを準備中……", "opened": false, "retry": true}
	target.set("state", "comment_choice")
	PauseReasonSystemScript.add(target, "InstructionComment")
	target.set("previous_state", "playing")
	target.set("choice_timer", maxf(1.0, base_choice_time + float(target.get("choice_time_bonus")) - float(target.get("choice_time_penalty"))))
	target.set("selected_card", 0)
	target.set("special_choice_return_card", 0)
	target.set("comment_warning_step", 0)
	if bool(target.get("relay_mode")):
		offer = offer.slice(0, 3)
		var relay_config: Dictionary = target.get("relay_mode_config") as Dictionary
		var instruction: Dictionary = relay_config.get("instruction", {}) as Dictionary
		target.set("choice_timer", float(instruction.get("choiceTime", 10.0)))
	target.set("offered_comments", offer)
	discover_offered_comments_for_target(target)
	target.set("ng_cards", _bool_cards(false, offer.size()))
	var pending_heart: bool = bool(target.get("heart_pending"))
	target.set("heart_cards", _bool_cards(pending_heart, offer.size()))
	if pending_heart:
		target.set("heart_pending", false)
		target.set("heart_used_count", int(target.get("heart_used_count")) + 1)
		return {"chat": "♡発動！ 指示コメが全部ちょっと甘くなった", "opened": true}
	return {"chat": "指示コメが来た！", "opened": true}

static func start_choice_ui_for_target(target: Node, comments: Array, rng: RandomNumberGenerator, base_choice_time: float, choice_box: Control) -> Dictionary:
	var result: Dictionary = start_choice_for_target(target, comments, rng, base_choice_time)
	choice_box.visible = bool(result.get("opened", false))
	return result

static func _valid_three_card_offer(offer: Array) -> bool:
	if offer.size() != 3 and offer.size() != 4:
		return false
	var used_ids: Dictionary = {}
	for i in range(offer.size()):
		var item: Variant = offer[i]
		if not item is Dictionary:
			return false
		var comment_id := String((item as Dictionary).get("id", "")).strip_edges()
		if comment_id.is_empty() or (used_ids.has(comment_id) and not HardModeSystemScript.is_safe_offer_duplicate(item as Dictionary)):
			return false
		used_ids[comment_id] = true
		if i == 3 and comment_id != DO_EVERYTHING_ID:
			return false
	return true

static func _repair_offer_for_target(target: Node, comments: Array, rng: RandomNumberGenerator) -> Array:
	var frame: Dictionary = target.get("current_stream_frame") as Dictionary
	var difficulty_value: Variant = target.get("run_difficulty_id")
	var difficulty_id := String(difficulty_value if difficulty_value != null else "normal").strip_edges().to_lower()
	var frame_comments := comments_allowed_for_frame(frame, comments, difficulty_id)
	if difficulty_id == "hard" or difficulty_id == "expert":
		var hard_default := HardModeSystemScript.build_safe_default_offer_for_target(target, frame_comments, rng)
		if _valid_three_card_offer(hard_default):
			return hard_default
		# Do not fall through to the NORMAL repair path: it could duplicate a
		# HARD-only boss/complex card that HardModeSystem deliberately caps at one.
		return []
	var safe_candidates: Array = []
	var seen_ids: Dictionary = {}
	var elapsed := float(target.get("elapsed"))
	for item in frame_comments:
		if not item is Dictionary:
			continue
		var candidate: Dictionary = item as Dictionary
		var id := String(candidate.get("id", ""))
		if id.is_empty() or seen_ids.has(id) or bool(candidate.get("isSpecialChoice", false)) or bool(candidate.get("excludedFromNormalChoices", false)):
			continue
		if String(candidate.get("effectType", "")) == "summon_boss" or id == "summon_boss":
			continue
		if bool(candidate.get("hardOnly", false)) or elapsed < float(candidate.get("minTime", 0.0)):
			continue
		seen_ids[id] = true
		safe_candidates.append(candidate)
	if safe_candidates.size() < 3:
		return []
	var repaired: Array = []
	while repaired.size() < 3 and not safe_candidates.is_empty():
		var index := rng.randi_range(0, safe_candidates.size() - 1)
		repaired.append((safe_candidates[index] as Dictionary).duplicate(true))
		safe_candidates.remove_at(index)
	return repaired

static func finish_choice_for_target(target: Node, interval: float) -> String:
	target.set("comment_timer", interval)
	target.set("comment_warning_step", 0)
	target.set("state", "playing")
	PauseReasonSystemScript.remove(target, "InstructionComment")
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
	HardModeSystemScript.clear_active_comment_for_target(target)
	var result: Dictionary = ModifierSystem.start_comment_for_target(target, comment, view, has_heart, rng, sub_comments, sub_heart_cards)
	HardModeSystemScript.activate_comment_for_target(target, view, rng)
	HardModeSystemScript.mark_comment_selected_for_target(target, String(comment.get("id", "")))
	CodexManager.record_comment_selection(String(comment.get("id", "")), has_heart)
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
	for key in modifier_feedback.keys():
		if key == "chats" or key == "toasts":
			continue
		feedback[key] = modifier_feedback[key]
	feedback["commentId"] = String(result["commentId"])
	feedback["selected"] = true
	return feedback

static func apply_forced_offer_to_target(target: Node, offer: Dictionary) -> bool:
	if offer.is_empty():
		return false
	target.set("offered_comments", offer["comments"] as Array)
	discover_offered_comments_for_target(target)
	target.set("ng_cards", _bool_cards(false, 1))
	target.set("heart_cards", _bool_cards(bool(offer["heartCard"]), 1))
	return true

static func discover_offered_comments_for_target(target: Node) -> void:
	var offered_value: Variant = target.get("offered_comments")
	if not offered_value is Array:
		return
	var seen: Dictionary = {}
	for item in offered_value as Array:
		if item is Dictionary:
			var comment_id := String((item as Dictionary).get("id", ""))
			if comment_id != "" and not seen.has(comment_id):
				seen[comment_id] = true
				CodexManager.record_comment_appearance(comment_id)

static func _bool_cards(value: bool, count: int) -> Array[bool]:
	var cards: Array[bool] = []
	for i in range(count):
		cards.append(value)
	return cards

static func build_forced_offer(comments: Array, id: String, has_heart: bool, frame: Dictionary = {}, difficulty_id: String = "") -> Dictionary:
	for item in comments:
		var comment: Dictionary = item as Dictionary
		if String(comment["id"]) == id:
			if not _comment_allowed_for_difficulty(comment, difficulty_id) or (not frame.is_empty() and not _data_allowed_for_frame(frame, comment, "commentPoolTags")):
				return {}
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
	if has_heart and String(view.get("difficultyId", "")) in ["hard", "expert"]:
		view["scoreRate"] = HardModeSystemScript.score_rate_for_risk(int(view.get("riskLevel", 1)))
	return view

static func codex_comment_view(comment: Dictionary, has_heart: bool = false) -> Dictionary:
	# Public read-only alias so the codex and choice-card presentation use the
	# exact same heartVariant merge and do_everything handling.
	return comment_view(comment, has_heart)

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
		chats.append("時間切れ：カーソル位置の指示コメを選択")
		var selected_index: int = clampi(int(target.get("selected_card")), 0, offer_count - 1)
		# Timeout follows the visible cursor.  It is the same effect path as a
		# normal selection; no automatic multiplier substitution or penalty is
		# applied when the player did not press a button in time.
		choose_index = selected_index
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
		if _offer_contains_id(used, String(comment.get("id", ""))):
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
			if not _is_special_only_comment(fallback) and _data_allowed_for_frame(frame, fallback, "commentPoolTags") and _comment_allowed_for_context(fallback, context, comment_time) and comment_time >= float(fallback["minTime"]) and not _offer_contains_id(used, String(fallback.get("id", ""))):
				pool.append(fallback)
	if pool.is_empty():
		return {}
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
	if _should_boost_song_instruction_weight(comment, context):
		weight = maxi(weight + 1, ceili(float(weight) * SONG_INSTRUCTION_PICK_WEIGHT_MULTIPLIER))
	if _should_boost_drawing_instruction_weight(comment, context):
		weight = maxi(weight + 1, ceili(float(weight) * DRAWING_INSTRUCTION_PICK_WEIGHT_MULTIPLIER))
	if _should_boost_collab_instruction_weight(comment, context):
		weight = maxi(weight + 1, ceili(float(weight) * COLLAB_INSTRUCTION_PICK_WEIGHT_MULTIPLIER))
	var runtime_value: Variant = context.get("difficultyRuntime", {})
	if runtime_value is Dictionary:
		var stage_weight := HardModeSystemScript.stage_profile_comment_weight(runtime_value as Dictionary, String(comment.get("id", "")))
		if stage_weight > 1.0:
			weight = maxi(weight + 1, ceili(float(weight) * stage_weight))
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

static func _should_boost_song_instruction_weight(comment: Dictionary, context: Dictionary) -> bool:
	var frame: Dictionary = context.get("streamFrame", {}) as Dictionary
	return String(frame.get("id", "")) == "singing" and String(comment.get("effectType", "")) == "song_instruction"

static func _should_boost_drawing_instruction_weight(comment: Dictionary, context: Dictionary) -> bool:
	var frame: Dictionary = context.get("streamFrame", {}) as Dictionary
	return String(frame.get("id", "")) == "drawing" and String(comment.get("effectType", "")) == "drawing_instruction"

static func _should_boost_collab_instruction_weight(comment: Dictionary, context: Dictionary) -> bool:
	var frame: Dictionary = context.get("streamFrame", {}) as Dictionary
	return String(frame.get("id", "")) == "collab" and String(comment.get("effectType", "")) == "collab_instruction"

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
			if not comment.is_empty() and not _offer_contains_id(result, String(comment.get("id", ""))):
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
		if _offer_contains_id(used, id) or id == last_comment_id:
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

static func _offer_contains_id(offer: Array, id: String) -> bool:
	if id.is_empty():
		return false
	for item in offer:
		if item is Dictionary and String((item as Dictionary).get("id", "")) == id:
			return true
	return false

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
	if bool(context.get("relayMode", false)) and (String(comment.get("effectType", "")) == "summon_boss" or String(comment.get("id", "")) == "summon_boss"):
		return false
	if _is_matching_active_genre_comment(comment, context):
		return false
	if String(comment.get("id", "")) == "dont_fail_collab" and bool(context.get("collabChallengeActive", false)):
		return false
	if String(comment.get("id", "")) == "song_force_chorus" and bool(context.get("songChorusActive", false)):
		return false
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

static func _is_matching_active_genre_comment(comment: Dictionary, context: Dictionary) -> bool:
	var active_event := String(context.get("activeGenreEvent", ""))
	if active_event == "":
		return false
	var comment_id := String(comment.get("id", ""))
	if comment_id == "force_race":
		return active_event == "race"
	if comment_id == "force_bullet_hell":
		return active_event == "bullet_hell"
	if comment_id == "force_horror":
		return active_event == "horror"
	return false

static func _data_allowed_for_frame(frame: Dictionary, data: Dictionary, tag_key: String) -> bool:
	var explicit_stage_ids: Variant = data.get("stageIds", null)
	if explicit_stage_ids is Array and not (explicit_stage_ids as Array).is_empty():
		var current_stage := _normalize_stage_id(frame.get("id", ""))
		var stage_match := false
		for raw_stage in explicit_stage_ids as Array:
			if _normalize_stage_id(raw_stage) == current_stage:
				stage_match = true
				break
		if not stage_match:
			return false
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

static func _normalize_stage_id(value: Variant) -> String:
	var id := String(value).strip_edges().to_lower()
	if id == "talk":
		return "zatsudan"
	if id == "game":
		return "gameplay"
	if id == "song":
		return "singing"
	return id

## Absolute frame-pool filter shared by NORMAL, HARD and debug/forced offers.
## Callers must pass this filtered array into every later risk/fallback path;
## no shortage fallback is allowed to widen the frame's tag boundary.
static func comments_allowed_for_frame(frame: Dictionary, comments: Array, difficulty_id: String = "") -> Array:
	var effective_frame := frame
	if effective_frame.is_empty():
		# A missing frame must not widen the pool to every comment.  Preserve the
		# legacy default-tag behavior while keeping stage-specific comments out.
		effective_frame = {"id": "", "commentPoolTags": ["default"]}
	var result: Array = []
	for item in comments:
		if not item is Dictionary:
			continue
		var comment := item as Dictionary
		if _comment_allowed_for_difficulty(comment, difficulty_id) and _data_allowed_for_frame(effective_frame, comment, "commentPoolTags"):
			result.append(comment)
	return result

static func _comment_allowed_for_difficulty(comment: Dictionary, difficulty_id: String) -> bool:
	var difficulty := difficulty_id.strip_edges().to_lower()
	if difficulty == "" or difficulty == "normal":
		if bool(comment.get("hardOnly", false)):
			return false
	if difficulty == "expert" and bool(comment.get("expertDisabled", false)):
		return false
	var availability: Variant = comment.get("availability", null)
	if availability is Dictionary and availability.has(difficulty):
		return bool((availability as Dictionary).get(difficulty, true))
	return true

