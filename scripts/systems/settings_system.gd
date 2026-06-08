class_name SettingsSystem
extends RefCounted

const SETTINGS_PATH := "user://settings.json"
const DEFAULT_WINDOW_SIZE_INDEX := 1
const DEFAULT_BGM_VOLUME := 70
const DEFAULT_SE_VOLUME := 80
const DEFAULT_FULLSCREEN := true
const DEFAULT_COMMENT_BARRAGE := 1
const DEFAULT_SCREEN_SHAKE := true
const DEFAULT_SHOW_TUTORIAL := true
const BASE_CONTENT_SIZE := Vector2i(1600, 900)
const MIN_WINDOW_SIZE := Vector2i(640, 360)
const WINDOW_SIZE_LABELS := ["1280 x 720", "1600 x 900", "1920 x 1080"]
const WINDOW_SIZE_KEYS := ["1280x720", "1600x900", "1920x1080"]
const WINDOW_SIZE_VALUES := [Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080)]
const COMMENT_BARRAGE_KEYS := ["low", "normal", "high"]

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
	var show_tutorial := DEFAULT_SHOW_TUTORIAL
	if data.has("showTutorial"):
		show_tutorial = bool(data.get("showTutorial"))
	elif data.has("tutorialSeen"):
		show_tutorial = not bool(data.get("tutorialSeen"))
	return {
		"tutorialSeen": not show_tutorial,
		"bgmVolume": normalized_volume(data.get("bgmVolume", DEFAULT_BGM_VOLUME)),
		"seVolume": normalized_volume(data.get("seVolume", DEFAULT_SE_VOLUME)),
		"fullscreen": bool(data.get("fullscreen", DEFAULT_FULLSCREEN)),
		"windowSize": window_size_index_from_value(data.get("windowSize", data.get("windowSizeIndex", DEFAULT_WINDOW_SIZE_INDEX))),
		"commentBarrage": comment_barrage_index_from_value(data.get("commentDanmakuAmount", data.get("commentBarrage", DEFAULT_COMMENT_BARRAGE))),
		"screenShake": bool(data.get("screenShake", DEFAULT_SCREEN_SHAKE))
	}

static func build_save_data(
	tutorial_seen: bool,
	window_size: int,
	comment_barrage: int,
	screen_shake: bool,
	bgm_volume: int = DEFAULT_BGM_VOLUME,
	se_volume: int = DEFAULT_SE_VOLUME,
	fullscreen: bool = DEFAULT_FULLSCREEN
) -> Dictionary:
	var window_index := normalized_window_size(window_size)
	var barrage_index := normalized_comment_barrage(comment_barrage)
	return {
		"bgmVolume": normalized_volume(bgm_volume),
		"seVolume": normalized_volume(se_volume),
		"fullscreen": fullscreen,
		"windowSize": window_size_key(window_index),
		"windowSizeIndex": window_index,
		"commentDanmakuAmount": comment_barrage_key(barrage_index),
		"showTutorial": not tutorial_seen,
		"tutorialSeen": tutorial_seen,
		"commentBarrage": barrage_index,
		"screenShake": screen_shake
	}

static func load_for_target(target: Node) -> void:
	var settings: Dictionary = normalized_settings(load_settings())
	target.set("tutorial_seen", bool(settings["tutorialSeen"]))
	target.set("bgm_volume", int(settings["bgmVolume"]))
	target.set("se_volume", int(settings["seVolume"]))
	target.set("fullscreen_enabled", bool(settings["fullscreen"]))
	target.set("window_size_index", int(settings["windowSize"]))
	target.set("comment_barrage_setting", int(settings["commentBarrage"]))
	target.set("screen_shake_enabled", bool(settings["screenShake"]))
	apply_display_settings(bool(settings["fullscreen"]), int(settings["windowSize"]))
	if not bool(settings["fullscreen"]):
		schedule_window_resize_lock_for_target(target)
	else:
		target.set("pending_window_resize_lock_frames", 0)

static func save_for_target(target: Node) -> void:
	save_settings(build_save_data(
		bool(target.get("tutorial_seen")),
		int(target.get("window_size_index")),
		int(target.get("comment_barrage_setting")),
		bool(target.get("screen_shake_enabled")),
		int(target.get("bgm_volume")),
		int(target.get("se_volume")),
		bool(target.get("fullscreen_enabled"))
	))

static func normalized_volume(value: Variant) -> int:
	return clampi(int(value), 0, 100)

static func volume_db_from_percent(value: int) -> float:
	var normalized := float(normalized_volume(value)) / 100.0
	if normalized <= 0.0:
		return -80.0
	return linear_to_db(normalized)

static func normalized_window_size(value: int) -> int:
	return clampi(value, 0, WINDOW_SIZE_LABELS.size() - 1)

static func next_window_size(current: int) -> int:
	return (normalized_window_size(current) + 1) % WINDOW_SIZE_LABELS.size()

static func previous_window_size(current: int) -> int:
	return posmod(normalized_window_size(current) - 1, WINDOW_SIZE_LABELS.size())

static func window_size_label(index: int) -> String:
	return String(WINDOW_SIZE_LABELS[normalized_window_size(index)])

static func window_size_key(index: int) -> String:
	return String(WINDOW_SIZE_KEYS[normalized_window_size(index)])

static func window_size_index_from_value(value: Variant) -> int:
	if value is String:
		var key := String(value).replace("×", "x").replace(" ", "")
		var found := WINDOW_SIZE_KEYS.find(key)
		return DEFAULT_WINDOW_SIZE_INDEX if found < 0 else found
	return normalized_window_size(int(value))

static func apply_display_settings(fullscreen: bool, window_size_index: int) -> void:
	if fullscreen:
		apply_fullscreen()
	else:
		apply_window_size(window_size_index)

static func apply_fullscreen() -> void:
	var window := _root_window()
	if window != null:
		window.unresizable = false
		window.mode = Window.MODE_FULLSCREEN
		window.content_scale_size = BASE_CONTENT_SIZE
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, false)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

static func apply_window_size(index: int) -> void:
	var size := Vector2i(WINDOW_SIZE_VALUES[normalized_window_size(index)])
	var window := _root_window()
	if window == null:
		apply_window_size_with_display_server(size)
		return
	window.unresizable = false
	window.mode = Window.MODE_WINDOWED
	window.min_size = MIN_WINDOW_SIZE
	window.content_scale_size = BASE_CONTENT_SIZE
	window.size = size
	window.position = centered_window_position(size, window.current_screen)
	apply_window_size_with_display_server(size)

static func apply_window_size_with_display_server(size: Vector2i) -> void:
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, false)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_min_size(MIN_WINDOW_SIZE)
	DisplayServer.window_set_size(size)
	DisplayServer.window_set_position(centered_window_position(size, DisplayServer.window_get_current_screen()))

static func lock_window_resize() -> void:
	var window := _root_window()
	if window != null:
		window.unresizable = true
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, true)

static func schedule_window_resize_lock_for_target(target: Node) -> void:
	target.set("pending_window_resize_lock_frames", 2)

static func current_window_size() -> Vector2i:
	var window := _root_window()
	if window != null:
		return window.size
	return DisplayServer.window_get_size()

static func window_size_status(index: int, fullscreen: bool = false) -> String:
	var requested := Vector2i(WINDOW_SIZE_VALUES[normalized_window_size(index)])
	var actual := current_window_size()
	if fullscreen:
		return "フルスクリーン / ウィンドウ時 %d x %d / 現在 %d x %d" % [
			requested.x,
			requested.y,
			actual.x,
			actual.y
		]
	var status := "反映済み" if actual == requested else "未反映"
	return "希望 %d x %d / 実ウィンドウ %d x %d / %s" % [
		requested.x,
		requested.y,
		actual.x,
		actual.y,
		status
	]

static func centered_window_position(size: Vector2i, screen_id: int) -> Vector2i:
	var screen_pos := DisplayServer.screen_get_position(screen_id)
	var screen_size := DisplayServer.screen_get_size(screen_id)
	return Vector2i(
		screen_pos.x + maxi(0, int((screen_size.x - size.x) * 0.5)),
		screen_pos.y + maxi(0, int((screen_size.y - size.y) * 0.5))
	)

static func _root_window() -> Window:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	return tree.root

static func normalized_comment_barrage(value: int) -> int:
	return clampi(value, 0, 2)

static func next_comment_barrage(current: int) -> int:
	return (normalized_comment_barrage(current) + 1) % 3

static func previous_comment_barrage(current: int) -> int:
	return posmod(normalized_comment_barrage(current) - 1, 3)

static func comment_barrage_key(index: int) -> String:
	return String(COMMENT_BARRAGE_KEYS[normalized_comment_barrage(index)])

static func comment_barrage_index_from_value(value: Variant) -> int:
	if value is String:
		var found := COMMENT_BARRAGE_KEYS.find(String(value))
		return DEFAULT_COMMENT_BARRAGE if found < 0 else found
	return normalized_comment_barrage(int(value))

static func toggled_screen_shake(current: bool) -> bool:
	return not current

static func reset_tutorial_seen() -> bool:
	return false

static func apply_title_action(current: Dictionary, action: String) -> Dictionary:
	var result: Dictionary = {
		"tutorialSeen": bool(current.get("tutorialSeen", false)),
		"bgmVolume": normalized_volume(current.get("bgmVolume", DEFAULT_BGM_VOLUME)),
		"seVolume": normalized_volume(current.get("seVolume", DEFAULT_SE_VOLUME)),
		"fullscreen": bool(current.get("fullscreen", DEFAULT_FULLSCREEN)),
		"windowSize": normalized_window_size(int(current.get("windowSize", DEFAULT_WINDOW_SIZE_INDEX))),
		"commentBarrage": normalized_comment_barrage(int(current.get("commentBarrage", DEFAULT_COMMENT_BARRAGE))),
		"screenShake": bool(current.get("screenShake", DEFAULT_SCREEN_SHAKE)),
		"changed": false
	}
	if action == "bgm_volume_up":
		result["bgmVolume"] = normalized_volume(int(result["bgmVolume"]) + 10)
		result["changed"] = true
	elif action == "bgm_volume_down":
		result["bgmVolume"] = normalized_volume(int(result["bgmVolume"]) - 10)
		result["changed"] = true
	elif action == "se_volume_up":
		result["seVolume"] = normalized_volume(int(result["seVolume"]) + 10)
		result["changed"] = true
	elif action == "se_volume_down":
		result["seVolume"] = normalized_volume(int(result["seVolume"]) - 10)
		result["changed"] = true
	elif action == "fullscreen_toggle":
		result["fullscreen"] = not bool(result["fullscreen"])
		result["changed"] = true
	elif action == "window_size" or action == "window_size_right":
		result["windowSize"] = next_window_size(int(result["windowSize"]))
		result["changed"] = true
	elif action == "window_size_left":
		result["windowSize"] = previous_window_size(int(result["windowSize"]))
		result["changed"] = true
	elif action == "comment_barrage" or action == "comment_barrage_right":
		result["commentBarrage"] = next_comment_barrage(int(result["commentBarrage"]))
		result["changed"] = true
	elif action == "comment_barrage_left":
		result["commentBarrage"] = previous_comment_barrage(int(result["commentBarrage"]))
		result["changed"] = true
	elif action == "screen_shake":
		result["screenShake"] = toggled_screen_shake(bool(result["screenShake"]))
		result["changed"] = true
	elif action == "tutorial_toggle":
		result["tutorialSeen"] = not bool(result["tutorialSeen"])
		result["changed"] = true
	elif action == "reset_tutorial":
		result["tutorialSeen"] = reset_tutorial_seen()
		result["changed"] = true
	elif action == "reset_options":
		result["tutorialSeen"] = not DEFAULT_SHOW_TUTORIAL
		result["bgmVolume"] = DEFAULT_BGM_VOLUME
		result["seVolume"] = DEFAULT_SE_VOLUME
		result["fullscreen"] = DEFAULT_FULLSCREEN
		result["windowSize"] = DEFAULT_WINDOW_SIZE_INDEX
		result["commentBarrage"] = DEFAULT_COMMENT_BARRAGE
		result["screenShake"] = DEFAULT_SCREEN_SHAKE
		result["changed"] = true
	return result

static func apply_title_action_for_target(target: Node, action: String) -> Dictionary:
	var result: Dictionary = apply_title_action({
		"tutorialSeen": target.get("tutorial_seen"),
		"bgmVolume": target.get("bgm_volume"),
		"seVolume": target.get("se_volume"),
		"fullscreen": target.get("fullscreen_enabled"),
		"windowSize": target.get("window_size_index"),
		"commentBarrage": target.get("comment_barrage_setting"),
		"screenShake": target.get("screen_shake_enabled")
	}, action)
	if bool(result["changed"]):
		target.set("tutorial_seen", bool(result["tutorialSeen"]))
		target.set("bgm_volume", int(result["bgmVolume"]))
		target.set("se_volume", int(result["seVolume"]))
		target.set("fullscreen_enabled", bool(result["fullscreen"]))
		target.set("window_size_index", int(result["windowSize"]))
		target.set("comment_barrage_setting", int(result["commentBarrage"]))
		target.set("screen_shake_enabled", bool(result["screenShake"]))
		apply_display_settings(bool(result["fullscreen"]), int(result["windowSize"]))
		if not bool(result["fullscreen"]):
			schedule_window_resize_lock_for_target(target)
		else:
			target.set("pending_window_resize_lock_frames", 0)
		save_for_target(target)
	return result
