class_name SettingsSystem
extends RefCounted

const SETTINGS_PATH := "user://settings.json"

static func load_settings() -> Dictionary:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return {}
	var text: String = FileAccess.get_file_as_string(SETTINGS_PATH)
	var parsed: Variant = JSON.parse_string(text)
	return parsed if parsed is Dictionary else {}

static func save_settings(data: Dictionary) -> void:
	var file: FileAccess = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data))

static func normalized_settings(data: Dictionary) -> Dictionary:
	return {
		"tutorialSeen": bool(data.get("tutorialSeen", false)),
		"commentBarrage": normalized_comment_barrage(int(data.get("commentBarrage", 1))),
		"screenShake": bool(data.get("screenShake", true))
	}

static func build_save_data(tutorial_seen: bool, comment_barrage: int, screen_shake: bool) -> Dictionary:
	return {
		"tutorialSeen": tutorial_seen,
		"commentBarrage": normalized_comment_barrage(comment_barrage),
		"screenShake": screen_shake
	}

static func load_for_target(target: Node) -> void:
	var data: Dictionary = load_settings()
	if data.is_empty():
		return
	var settings: Dictionary = normalized_settings(data)
	target.set("tutorial_seen", bool(settings["tutorialSeen"]))
	target.set("comment_barrage_setting", int(settings["commentBarrage"]))
	target.set("screen_shake_enabled", bool(settings["screenShake"]))

static func save_for_target(target: Node) -> void:
	save_settings(build_save_data(
		bool(target.get("tutorial_seen")),
		int(target.get("comment_barrage_setting")),
		bool(target.get("screen_shake_enabled"))
	))

static func normalized_comment_barrage(value: int) -> int:
	return clampi(value, 0, 2)

static func next_comment_barrage(current: int) -> int:
	return (normalized_comment_barrage(current) + 1) % 3

static func toggled_screen_shake(current: bool) -> bool:
	return not current

static func reset_tutorial_seen() -> bool:
	return false

static func apply_title_action(current: Dictionary, action: String) -> Dictionary:
	var result: Dictionary = {
		"tutorialSeen": bool(current.get("tutorialSeen", false)),
		"commentBarrage": normalized_comment_barrage(int(current.get("commentBarrage", 1))),
		"screenShake": bool(current.get("screenShake", true)),
		"changed": false
	}
	if action == "comment_barrage":
		result["commentBarrage"] = next_comment_barrage(int(result["commentBarrage"]))
		result["changed"] = true
	elif action == "screen_shake":
		result["screenShake"] = toggled_screen_shake(bool(result["screenShake"]))
		result["changed"] = true
	elif action == "reset_tutorial":
		result["tutorialSeen"] = reset_tutorial_seen()
		result["changed"] = true
	return result

static func apply_title_action_for_target(target: Node, action: String) -> Dictionary:
	var result: Dictionary = apply_title_action({
		"tutorialSeen": target.get("tutorial_seen"),
		"commentBarrage": target.get("comment_barrage_setting"),
		"screenShake": target.get("screen_shake_enabled")
	}, action)
	if bool(result["changed"]):
		target.set("tutorial_seen", bool(result["tutorialSeen"]))
		target.set("comment_barrage_setting", int(result["commentBarrage"]))
		target.set("screen_shake_enabled", bool(result["screenShake"]))
		save_for_target(target)
	return result
