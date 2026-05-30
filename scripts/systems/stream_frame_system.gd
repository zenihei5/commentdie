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

static func selected_frame_state_by_index(frames: Array, index: int) -> Dictionary:
	if index < 0 or index >= frames.size():
		return {}
	var frame: Dictionary = frames[index] as Dictionary
	return {
		"frame": frame,
		"frameId": String(frame.get("id", "zatsudan"))
	}

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
