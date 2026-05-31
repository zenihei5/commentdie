extends RefCounted
class_name StreamFrameSystem

static func fallback_frame() -> Dictionary:
	return {"id": "zatsudan", "displayName": "雑談枠"}

static func find_frame(frames: Array, id: String) -> Dictionary:
	for item in frames:
		var frame: Dictionary = item as Dictionary
		if String(frame.get("id", "")) == id:
			return frame
	if not frames.is_empty():
		return frames[0] as Dictionary
	return fallback_frame()

static func selected_index(frames: Array, id: String) -> int:
	for i in range(frames.size()):
		var frame: Dictionary = frames[i] as Dictionary
		if String(frame.get("id", "")) == id:
			return i
	return 0

static func selected_frame_state(frames: Array, id: String) -> Dictionary:
	var frame: Dictionary = find_frame(frames, id)
	return {
		"frame": frame,
		"frameId": String(frame.get("id", "zatsudan"))
	}

static func apply_selected_frame_for_target(target: Node, frames: Array, id: String) -> void:
	var selected: Dictionary = selected_frame_state(frames, id)
	target.set("current_stream_frame", selected["frame"] as Dictionary)
	target.set("current_stream_frame_id", String(selected["frameId"]))

static func selected_frame_state_by_index(frames: Array, index: int) -> Dictionary:
	if index < 0 or index >= frames.size():
		return {}
	var frame: Dictionary = frames[index] as Dictionary
	return {
		"frame": frame,
		"frameId": String(frame.get("id", "zatsudan"))
	}

static func update_selection_action(latch: Dictionary, frames: Array, current_index: int) -> Dictionary:
	var action: Dictionary = ChoiceCardSystem.menu_selection_action(latch, current_index, frames.size(), 2)
	if ChoiceCardSystem.is_escape(action):
		return {"kind": "escape", "index": current_index}
	if ChoiceCardSystem.is_move(action):
		return {"kind": "move", "index": int(action["index"])}
	if ChoiceCardSystem.is_select(action):
		var selected: Dictionary = selected_frame_state_by_index(frames, int(action["index"]))
		if selected.is_empty():
			return {"kind": "", "index": current_index}
		return {
			"kind": "select",
			"index": int(action["index"]),
			"frame": selected["frame"] as Dictionary,
			"frameId": String(selected["frameId"])
		}
	return {"kind": "", "index": current_index}

static func update_selection_for_target(target: Node, latch: Dictionary, frames: Array) -> Dictionary:
	var action: Dictionary = update_selection_action(latch, frames, int(target.get("selected_stream_frame_index")))
	var kind: String = String(action["kind"])
	if kind == "escape":
		return {"backToCharacterSelect": true, "restart": false}
	if kind == "move":
		target.set("selected_stream_frame_index", int(action["index"]))
	elif kind == "select":
		target.set("current_stream_frame", action["frame"] as Dictionary)
		target.set("current_stream_frame_id", String(action["frameId"]))
		return {"backToCharacterSelect": false, "restart": true}
	return {"backToCharacterSelect": false, "restart": false}

static func start_selection_for_target(target: Node, choice_box: Control, result_panel: Control, frames: Array) -> Dictionary:
	StateFlowSystem.open_pre_run_select_for_target(target, "stream_frame_select", choice_box, result_panel)
	var current_id: String = String(target.get("current_stream_frame_id"))
	if frames.is_empty():
		var fallback: Dictionary = selected_frame_state(frames, current_id)
		target.set("current_stream_frame", fallback["frame"] as Dictionary)
		target.set("current_stream_frame_id", String(fallback["frameId"]))
		return {"restart": true, "chat": "今日の配信枠を選べ"}
	target.set("selected_stream_frame_index", selected_index(frames, current_id))
	return {"restart": false, "chat": "今日の配信枠を選べ"}

static func feature_labels(frame: Dictionary) -> Array[String]:
	var labels: Array[String] = []
	for event in frame.get("events", []):
		labels.append(String(event))
	return labels

static func selection_card_view(frame: Dictionary) -> Dictionary:
	return {
		"displayName": String(frame.get("displayName", "配信枠")),
		"description": String(frame.get("description", "")),
		"difficultyText": String(frame.get("difficultyText", "標準")),
		"features": feature_labels(frame)
	}

static func has_event(frame: Dictionary, event_id: String) -> bool:
	var events: Array = frame.get("events", []) as Array
	return events.has(event_id)

static func event_flags(frame: Dictionary) -> Dictionary:
	return {
		"marshmallow": has_event(frame, "marshmallow"),
		"gameGenreEvent": has_event(frame, "game_genre_event")
	}

static func data_allowed(frame: Dictionary, data: Dictionary, tag_key: String) -> bool:
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
