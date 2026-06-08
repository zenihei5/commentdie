class_name StateFlowSystem
extends RefCounted

const OPTION_ITEM_COUNT := 9

static func toggle_pause_state(state: String, previous_state: String) -> Dictionary:
	if state == "pause":
		return {"state": previous_state, "previousState": previous_state}
	if state == "playing":
		return {"state": "pause", "previousState": state}
	return {"state": state, "previousState": previous_state}

static func toggle_pause_for_target(target: Node) -> Dictionary:
	var result: Dictionary = toggle_pause_state(String(target.get("state")), String(target.get("previous_state")))
	target.set("state", String(result["state"]))
	target.set("previous_state", String(result["previousState"]))
	if String(result["state"]) == "pause":
		target.set("pause_menu_index", 0)
		target.set("pause_confirm_action", "")
	else:
		target.set("pause_confirm_action", "")
	return result

static func update_pause_input_for_target(target: Node) -> void:
	var down: bool = Input.is_key_pressed(KEY_ESCAPE)
	var was_down: bool = bool(target.get("pause_escape_down"))
	target.set("pause_escape_down", down)
	if was_down and not down:
		toggle_pause_for_target(target)

static func apply_title_action_for_target(target: Node, action: String) -> Dictionary:
	var start_character_select := false
	var open_ranking := false
	var open_options := false
	if action == "title_up":
		target.set("title_menu_index", posmod(int(target.get("title_menu_index")) - 1, 3))
	if action == "title_down":
		target.set("title_menu_index", posmod(int(target.get("title_menu_index")) + 1, 3))
	if action == "title_new_game":
		target.set("title_menu_index", 0)
		start_character_select = true
	if action == "title_ranking":
		target.set("title_menu_index", 1)
		open_ranking = true
	if action == "title_options":
		target.set("title_menu_index", 2)
		open_options = true
	if action == "title_select" or action == "start":
		var index: int = int(target.get("title_menu_index"))
		start_character_select = index == 0
		open_ranking = index == 1
		open_options = index == 2
	if action == "toggle_mode":
		target.set("quick_test_mode", not bool(target.get("quick_test_mode")))
		target.set("relay_mode", false)
	if action == "unlock_stream_frames":
		StreamFrameSystem.unlock_all_for_target(target)
	if action == "toggle_relay" and bool(target.get("relay_mode_unlocked")):
		target.set("relay_mode", not bool(target.get("relay_mode")))
		if bool(target.get("relay_mode")):
			target.set("quick_test_mode", false)
	SettingsSystem.apply_title_action_for_target(target, action)
	return {
		"startCharacterSelect": start_character_select,
		"openRanking": open_ranking,
		"openOptions": open_options
	}

static func option_action_for_index(index: int, direction: int) -> String:
	var normalized := posmod(index, OPTION_ITEM_COUNT)
	if normalized == 0:
		return "bgm_volume_down" if direction < 0 else "bgm_volume_up"
	if normalized == 1:
		return "se_volume_down" if direction < 0 else "se_volume_up"
	if normalized == 2:
		return "fullscreen_toggle"
	if normalized == 3:
		return "window_size_left" if direction < 0 else "window_size_right"
	if normalized == 4:
		return "comment_barrage_left" if direction < 0 else "comment_barrage_right"
	if normalized == 5:
		return "screen_shake"
	if normalized == 6:
		return "tutorial_toggle"
	if normalized == 7:
		return "reset_options" if direction == 0 else ""
	if normalized == 8:
		return "back_to_title" if direction == 0 else ""
	return ""

static func apply_options_action_for_target(target: Node, action: String) -> Dictionary:
	if action == "option_up":
		target.set("option_menu_index", posmod(int(target.get("option_menu_index")) - 1, OPTION_ITEM_COUNT))
	if action == "option_down":
		target.set("option_menu_index", posmod(int(target.get("option_menu_index")) + 1, OPTION_ITEM_COUNT))
	var selected_action := ""
	if action == "option_left":
		selected_action = option_action_for_index(int(target.get("option_menu_index")), -1)
	elif action == "option_right":
		selected_action = option_action_for_index(int(target.get("option_menu_index")), 1)
	elif action == "option_select":
		selected_action = option_action_for_index(int(target.get("option_menu_index")), 0)
	elif action == "back_to_title":
		selected_action = "back_to_title"
	elif action == "option_bgm_volume":
		target.set("option_menu_index", 0)
		selected_action = "bgm_volume_up"
	elif action == "option_se_volume":
		target.set("option_menu_index", 1)
		selected_action = "se_volume_up"
	elif action == "option_fullscreen":
		target.set("option_menu_index", 2)
		selected_action = "fullscreen_toggle"
	elif action == "option_window_size":
		target.set("option_menu_index", 3)
		selected_action = "window_size_right"
	elif action == "option_comment_barrage":
		target.set("option_menu_index", 4)
		selected_action = "comment_barrage_right"
	elif action == "option_screen_shake":
		target.set("option_menu_index", 5)
		selected_action = "screen_shake"
	elif action == "option_tutorial":
		target.set("option_menu_index", 6)
		selected_action = "tutorial_toggle"
	elif action == "option_reset_tutorial":
		target.set("option_menu_index", 6)
		selected_action = "reset_tutorial"
	elif action == "option_reset":
		target.set("option_menu_index", 7)
		selected_action = "reset_options"
	if selected_action != "" and selected_action != "back_to_title":
		SettingsSystem.apply_title_action_for_target(target, selected_action)
	return {"backToTitle": selected_action == "back_to_title"}

static func front_state_action_for_target(target: Node, delta: float, title_action: String, result_action: String = "", ranking_action: String = "", options_action: String = "") -> Dictionary:
	var state: String = String(target.get("state"))
	if state == "title":
		var title_result: Dictionary = apply_title_action_for_target(target, title_action)
		if bool(title_result["startCharacterSelect"]):
			return {"handled": true, "action": "start_character_select"}
		if bool(title_result["openRanking"]):
			return {"handled": true, "action": "open_title_ranking"}
		if bool(title_result["openOptions"]):
			return {"handled": true, "action": "open_title_options"}
		return {"handled": true, "action": ""}
	if state == "ranking":
		if ranking_action == "reset_ranking":
			return {"handled": true, "action": "reset_title_ranking"}
		if ranking_action == "back_to_title":
			return {"handled": true, "action": "back_to_title"}
		if ranking_action.begins_with("ranking_"):
			return {"handled": true, "action": ranking_action}
		return {"handled": true, "action": ""}
	if state == "options":
		var option_result: Dictionary = apply_options_action_for_target(target, options_action)
		if bool(option_result["backToTitle"]):
			return {"handled": true, "action": "back_to_title"}
		return {"handled": true, "action": ""}
	if state == "character_select":
		return {"handled": true, "action": "update_character_select"}
	if state == "stream_frame_select":
		return {"handled": true, "action": "update_stream_frame_select"}
	if state == "stream_start_intro":
		return {"handled": true, "action": ""}
	if state == "game_over_intro":
		return {"handled": true, "action": ""}
	if state == "tutorial":
		update_tutorial_for_target(target, delta)
		return {"handled": true, "action": ""}
	if state == "result":
		if bool(target.get("result_showing_ranking")):
			if ranking_action == "back_to_title":
				return {"handled": true, "action": "back_to_title"}
			if ranking_action == "reset_ranking":
				return {"handled": true, "action": "toggle_ranking"}
			if ranking_action == "ranking_select":
				return {"handled": true, "action": "result_select_button"}
			if (
				ranking_action == "ranking_tab_left"
				or ranking_action == "ranking_tab_right"
				or ranking_action == "ranking_up"
				or ranking_action == "ranking_down"
			):
				return {"handled": true, "action": ranking_action}
			return {"handled": true, "action": ""}
		return {"handled": true, "action": result_action}
	if state == "pause":
		return {"handled": true, "action": ""}
	return {"handled": false, "action": ""}

static func apply_front_action(action: String, handlers: Dictionary) -> void:
	if action == "":
		return
	if not handlers.has(action):
		return
	var handler: Callable = handlers[action] as Callable
	if handler.is_valid():
		handler.call()

static func active_update_action(state: String) -> String:
	if state == "game_over_intro":
		return ""
	if state == "comment_choice":
		return "comment_choice"
	if state == "gift_choice":
		return "gift_choice"
	return "world"

static func apply_active_update(state: String, handlers: Dictionary) -> void:
	var action: String = active_update_action(state)
	if not handlers.has(action):
		return
	var handler: Callable = handlers[action] as Callable
	if handler.is_valid():
		handler.call()

static func has_modal_overlay(state: String) -> bool:
	return state in ["comment_choice", "gift_choice", "pause", "title", "ranking", "options", "character_select", "stream_frame_select", "stream_start_intro", "tutorial", "result"]

static func has_choice_backplate(state: String) -> bool:
	return state == "comment_choice" or state == "gift_choice"

static func overlay_view(state: String) -> String:
	if state == "title":
		return "title"
	if state == "ranking":
		return "ranking"
	if state == "options":
		return "options"
	if state == "character_select":
		return "character_select"
	if state == "stream_frame_select":
		return "stream_frame_select"
	if state == "stream_start_intro":
		return "stream_start_intro"
	if state == "game_over_intro":
		return "game_over_intro"
	if state == "tutorial":
		return "tutorial"
	if state == "pause":
		return "pause"
	if has_choice_backplate(state):
		return "choice"
	return ""

static func shows_comment_countdown(state: String) -> bool:
	return not (state in ["title", "ranking", "options", "character_select", "stream_frame_select", "stream_start_intro", "game_over_intro", "tutorial", "result", "pause"])

static func update_tutorial_state(tutorial_grace: float, delta: float) -> Dictionary:
	var next_grace: float = maxf(0.0, tutorial_grace - delta)
	var done: bool = false
	if next_grace <= 0.0:
		done = Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_ESCAPE)
	return {
		"tutorialInputGrace": next_grace,
		"state": "playing" if done else "tutorial"
	}

static func update_tutorial_for_target(target: Node, delta: float) -> Dictionary:
	var result: Dictionary = update_tutorial_state(float(target.get("tutorial_input_grace")), delta)
	target.set("tutorial_input_grace", float(result["tutorialInputGrace"]))
	target.set("state", String(result["state"]))
	return result

static func result_restart_pressed() -> bool:
	return Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_SPACE)

static func open_pre_run_select_for_target(target: Node, next_state: String, choice_box: Control, result_panel: Control) -> void:
	target.set("state", next_state)
	choice_box.visible = false
	result_panel.visible = false

static func post_restart_state(tutorial_seen: bool) -> Dictionary:
	if not tutorial_seen:
		return {
			"tutorialSeen": true,
			"tutorialInputGrace": 0.25,
			"state": "tutorial",
			"saveSettings": true
		}
	return {
		"tutorialSeen": tutorial_seen,
		"tutorialInputGrace": 0.0,
		"state": "playing",
		"saveSettings": false
	}

static func apply_post_restart_state_for_target(target: Node, tutorial_seen: bool) -> Dictionary:
	var result: Dictionary = post_restart_state(tutorial_seen)
	target.set("tutorial_seen", bool(result["tutorialSeen"]))
	target.set("tutorial_input_grace", float(result["tutorialInputGrace"]))
	target.set("state", String(result["state"]))
	return result
