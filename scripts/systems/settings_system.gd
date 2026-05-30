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

static func normalized_comment_barrage(value: int) -> int:
	return clampi(value, 0, 2)

static func next_comment_barrage(current: int) -> int:
	return (normalized_comment_barrage(current) + 1) % 3

static func toggled_screen_shake(current: bool) -> bool:
	return not current

static func reset_tutorial_seen() -> bool:
	return false
