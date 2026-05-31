class_name StateFlowSystem
extends RefCounted

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
	return result

static func update_pause_input_for_target(target: Node) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		toggle_pause_for_target(target)

static func apply_title_action_for_target(target: Node, action: String) -> Dictionary:
	if action == "toggle_mode":
		target.set("quick_test_mode", not bool(target.get("quick_test_mode")))
	SettingsSystem.apply_title_action_for_target(target, action)
	return {
		"startCharacterSelect": action == "start"
	}

static func front_state_action_for_target(target: Node, delta: float, title_action: String) -> Dictionary:
	var state: String = String(target.get("state"))
	if state == "title":
		var title_result: Dictionary = apply_title_action_for_target(target, title_action)
		return {"handled": true, "action": "start_character_select" if bool(title_result["startCharacterSelect"]) else ""}
	if state == "character_select":
		return {"handled": true, "action": "update_character_select"}
	if state == "stream_frame_select":
		return {"handled": true, "action": "update_stream_frame_select"}
	if state == "tutorial":
		update_tutorial_for_target(target, delta)
		return {"handled": true, "action": ""}
	if state == "result":
		return {"handled": true, "action": "restart" if result_restart_pressed() else ""}
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
	return state in ["comment_choice", "gift_choice", "pause", "title", "character_select", "stream_frame_select", "tutorial", "result"]

static func has_choice_backplate(state: String) -> bool:
	return state == "comment_choice" or state == "gift_choice"

static func overlay_view(state: String) -> String:
	if state == "title":
		return "title"
	if state == "character_select":
		return "character_select"
	if state == "stream_frame_select":
		return "stream_frame_select"
	if state == "tutorial":
		return "tutorial"
	if has_choice_backplate(state):
		return "choice"
	return ""

static func shows_comment_countdown(state: String) -> bool:
	return not (state in ["title", "character_select", "stream_frame_select", "tutorial", "result"])

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
