extends RefCounted
class_name StreamFrameSystem

const DifficultyProgressSystemScript := preload("res://scripts/systems/difficulty_progress_system.gd")
const PROGRESS_PATH := "user://stream_frame_progress.json"
const SELECT_PAGE_SIZE := 6
const SELECT_COLUMNS := 3

static func fallback_frame() -> Dictionary:
	return {"id": "zatsudan", "displayName": "雑談枠", "isUnlocked": true, "isCleared": false}

static func default_progress(frames: Array) -> Dictionary:
	return DifficultyProgressSystemScript.create_default_save_data(frames)

static func load_progress(frames: Array) -> Dictionary:
	return DifficultyProgressSystemScript.load_progress(frames)

static func save_progress(progress: Dictionary) -> void:
	DifficultyProgressSystemScript.save_progress(progress)

static func _merge_progress(default_data: Dictionary, saved_data: Dictionary) -> Dictionary:
	var merged: Dictionary = default_data.duplicate(true)
	var merged_frames: Dictionary = merged["streamFrameProgress"] as Dictionary
	var saved_frames: Dictionary = saved_data.get("streamFrameProgress", {}) as Dictionary
	for id in saved_frames.keys():
		var saved_entry: Dictionary = saved_frames[id] as Dictionary
		var entry: Dictionary = merged_frames.get(id, {}) as Dictionary
		for key in saved_entry.keys():
			entry[key] = saved_entry[key]
		merged_frames[id] = entry
	merged["relayModeUnlocked"] = bool(saved_data.get("relayModeUnlocked", merged.get("relayModeUnlocked", false)))
	return merged

static func _ensure_initial_unlocks(frames: Array, progress: Dictionary) -> Dictionary:
	var frame_progress: Dictionary = progress["streamFrameProgress"] as Dictionary
	for item in frames:
		var frame: Dictionary = item as Dictionary
		var frame_id: String = String(frame.get("id", ""))
		if frame_id == "":
			continue
		if not frame_progress.has(frame_id):
			frame_progress[frame_id] = {
				"isUnlocked": bool(frame.get("initialUnlocked", false)),
				"isCleared": false,
				"bestViewerCount": 0,
				"bestKamiRank": null
			}
		if bool(frame.get("initialUnlocked", false)):
			var entry: Dictionary = frame_progress[frame_id] as Dictionary
			entry["isUnlocked"] = true
	return progress

static func frames_with_progress(frames: Array, progress: Dictionary) -> Array:
	if progress.has("difficulties"):
		return DifficultyProgressSystemScript.frames_with_legacy_progress(frames, progress)
	var result: Array = []
	var frame_progress: Dictionary = progress.get("streamFrameProgress", {}) as Dictionary
	for item in frames:
		var frame: Dictionary = (item as Dictionary).duplicate(true)
		var frame_id: String = String(frame.get("id", ""))
		var entry: Dictionary = frame_progress.get(frame_id, {}) as Dictionary
		frame["isUnlocked"] = bool(entry.get("isUnlocked", frame.get("initialUnlocked", false)))
		frame["isCleared"] = bool(entry.get("isCleared", false))
		frame["bestViewerCount"] = int(entry.get("bestViewerCount", 0))
		frame["bestKamiRank"] = entry.get("bestKamiRank", null)
		result.append(frame)
	return result

static func load_progress_for_target(target: Node) -> void:
	DifficultyProgressSystemScript.load_progress_for_target(target)

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
	var view: Dictionary = {
		"frame": frame,
		"frameId": String(frame.get("id", "zatsudan"))
	}
	return view

static func apply_selected_frame_for_target(target: Node, frames: Array, id: String) -> void:
	var selected: Dictionary = selected_frame_state(frames, id)
	var frame: Dictionary = selected["frame"] as Dictionary
	if not is_unlocked(frame):
		selected = first_unlocked_frame_state(frames)
	target.set("current_stream_frame", selected["frame"] as Dictionary)
	target.set("current_stream_frame_id", String(selected["frameId"]))

static func first_unlocked_frame_state(frames: Array) -> Dictionary:
	for item in frames:
		var frame: Dictionary = item as Dictionary
		if is_unlocked(frame):
			return {
				"frame": frame,
				"frameId": String(frame.get("id", "zatsudan"))
			}
	return selected_frame_state(frames, "zatsudan")

static func selected_frame_state_by_index(frames: Array, index: int) -> Dictionary:
	if index < 0 or index >= frames.size():
		return {}
	var frame: Dictionary = frames[index] as Dictionary
	return {
		"frame": frame,
		"frameId": String(frame.get("id", "zatsudan"))
	}

static func is_unlocked(frame: Dictionary) -> bool:
	return bool(frame.get("isUnlocked", frame.get("initialUnlocked", false)))

static func is_selectable(frame: Dictionary) -> bool:
	return _is_playable(frame)

static func relay_selection_frame(relay_mode_unlocked: bool) -> Dictionary:
	var status_id := "relay_available" if relay_mode_unlocked else "locked"
	var status_text := "挑戦可能" if relay_mode_unlocked else "未解禁"
	var unlock_condition := "通常5枠をすべてクリアすると解禁されます。"
	var description := "5つの配信枠を各120秒ずつ連続で進み、最後に時間制限なしの最終ボスへ挑みます。区間の合間には休憩が入り、回復やギフトを選択できます。"
	return {
		"id": "relay",
		"displayName": "配信リレー",
		"plainName": "配信リレー",
		"detailTitle": "配信リレー",
		"iconId": "stream_icon_relay",
		"iconPath": "res://assets/generated/stream_frame_icons_v1/relay/clean.png",
		"themeColor": "relay",
		"description": description,
		"difficultyText": "枠難度：★★★★★",
		"difficultyStars": "★★★★★",
		"difficulty": 5,
		"status": status_id,
		"statusId": status_id,
		"statusText": status_text,
		"isPlayable": relay_mode_unlocked,
		"features": ["5区間", "各120秒"],
		"shortFeatures": ["5区間", "各120秒"],
		"mainGimmicks": ["5枠連続", "休憩", "最終ボス"],
		"recommendText": "5つの配信枠を連続で走り切る、総仕上げの特別モードです。" if relay_mode_unlocked else "",
		"unlockConditionText": unlock_condition if not relay_mode_unlocked else "",
		"disabledReason": unlock_condition if not relay_mode_unlocked else "",
		"isUnlocked": relay_mode_unlocked,
		"isCleared": false,
		"isRelayMode": true
	}

static func selection_frames(frames: Array, relay_mode_unlocked: bool, difficulty_id: String = "normal", progress: Dictionary = {}, relay_config: Dictionary = {}) -> Array:
	if progress.has("difficulties"):
		return DifficultyProgressSystemScript.selection_frames_for_progress(frames, progress, difficulty_id, relay_config)
	var result: Array = []
	for item in frames:
		result.append((item as Dictionary).duplicate(true))
	result.append(relay_selection_frame(relay_mode_unlocked))
	return result

static func selection_page_count(frame_count: int) -> int:
	return maxi(1, int(ceil(float(maxi(1, frame_count)) / float(SELECT_PAGE_SIZE))))

static func selection_page_for_index(index: int, frame_count: int) -> int:
	var page_count: int = selection_page_count(frame_count)
	if frame_count <= 0:
		return 0
	return clampi(int(clampi(index, 0, frame_count - 1) / SELECT_PAGE_SIZE), 0, page_count - 1)

static func selection_index_for_page(frames: Array, page: int, local_index: int = 0) -> int:
	if frames.is_empty():
		return 0
	var page_count: int = selection_page_count(frames.size())
	var clamped_page: int = clampi(page, 0, page_count - 1)
	var start: int = clamped_page * SELECT_PAGE_SIZE
	var end: int = mini(start + SELECT_PAGE_SIZE, frames.size())
	return clampi(start + local_index, start, end - 1)

static func horizontal_difficulty_edge_target_index(current_index: int, current_count: int, target_count: int, direction: int) -> int:
	if current_count <= 0 or target_count <= 0 or direction == 0:
		return -1
	var safe_current: int = clampi(current_index, 0, current_count - 1)
	var local_index: int = safe_current % SELECT_PAGE_SIZE
	var column: int = local_index % SELECT_COLUMNS
	var row_start: int = int(local_index / SELECT_COLUMNS) * SELECT_COLUMNS
	if direction > 0 and column == SELECT_COLUMNS - 1:
		return mini(row_start, target_count - 1)
	if direction < 0 and column == 0:
		return mini(row_start + SELECT_COLUMNS - 1, target_count - 1)
	return -1

static func difficulty_scroll_offsets(progress: float, direction: int, distance: float) -> Vector2:
	var eased_progress := smoothstep(0.0, 1.0, clampf(progress, 0.0, 1.0))
	var direction_sign := 1.0 if direction >= 0 else -1.0
	var safe_distance := maxf(0.0, distance)
	return Vector2(
		-direction_sign * safe_distance * eased_progress,
		direction_sign * safe_distance * (1.0 - eased_progress)
	)

static func locked_message(frame: Dictionary, frames: Array) -> String:
	var disabled_reason: String = _disabled_reason(frame)
	if disabled_reason != "":
		return disabled_reason
	if bool(frame.get("isRelayMode", false)):
		return String(frame.get("unlockConditionText", "通常5枠をすべてクリアすると解禁されます。"))
	var condition: Dictionary = _condition_dict(frame)
	var target_id: String = String(condition.get("targetFrameId", ""))
	var target_frame: Dictionary = find_frame(frames, target_id)
	var target_name: String = String(target_frame.get("displayName", "前の配信枠"))
	return "この配信枠はまだ開放されていません。%sをクリアすると開放されます。" % target_name

static func update_selection_action(latch: Dictionary, frames: Array, current_index: int) -> Dictionary:
	var action: Dictionary = ChoiceCardSystem.character_grid_selection_action(latch, current_index, frames.size(), SELECT_PAGE_SIZE, SELECT_COLUMNS, 6)
	if ChoiceCardSystem.is_escape(action):
		return {"kind": "escape", "index": current_index}
	if ChoiceCardSystem.is_move(action):
		return {"kind": "move", "index": int(action["index"])}
	if ChoiceCardSystem.is_select(action):
		var selected: Dictionary = selected_frame_state_by_index(frames, int(action["index"]))
		if selected.is_empty():
			return {"kind": "", "index": current_index}
		var frame: Dictionary = selected["frame"] as Dictionary
		if not is_selectable(frame):
			return {
				"kind": "locked",
				"index": int(action["index"]),
				"chat": locked_message(frame, frames)
			}
		return {
			"kind": "select",
			"index": int(action["index"]),
			"frame": frame,
			"frameId": String(selected["frameId"])
		}
	return {"kind": "", "index": current_index}

static func update_selection_for_target(target: Node, latch: Dictionary, frames: Array) -> Dictionary:
	var progress: Dictionary = target.get("difficulty_progress") as Dictionary
	var selection_items: Array = DifficultyProgressSystemScript.selection_frames_for_target(target, frames, target.get("relay_mode_config") as Dictionary) if not progress.is_empty() else selection_frames(frames, bool(target.get("relay_mode_unlocked")))
	var action: Dictionary = update_selection_action(latch, selection_items, int(target.get("selected_stream_frame_index")))
	var kind: String = String(action["kind"])
	if kind == "escape":
		return {"backToCharacterSelect": true, "restart": false, "locked": false, "chat": ""}
	if kind == "move":
		target.set("selected_stream_frame_index", int(action["index"]))
	elif kind == "locked":
		target.set("selected_stream_frame_index", int(action["index"]))
		return {"backToCharacterSelect": false, "restart": false, "locked": true, "chat": String(action.get("chat", ""))}
	elif kind == "select":
		var frame: Dictionary = action["frame"] as Dictionary
		var frame_id: String = String(action["frameId"])
		if bool(frame.get("isRelayMode", false)):
			target.set("relay_mode", true)
			target.set("quick_test_mode", false)
		else:
			target.set("relay_mode", false)
			target.set("current_stream_frame", frame)
			target.set("current_stream_frame_id", frame_id)
		return {"backToCharacterSelect": false, "restart": true, "locked": false, "chat": ""}
	return {"backToCharacterSelect": false, "restart": false, "locked": false, "chat": ""}

static func start_selection_for_target(target: Node, choice_box: Control, result_panel: Control, frames: Array) -> Dictionary:
	StateFlowSystem.open_pre_run_select_for_target(target, "stream_frame_select", choice_box, result_panel)
	var progress: Dictionary = target.get("difficulty_progress") as Dictionary
	var selection_items: Array = DifficultyProgressSystemScript.selection_frames_for_target(target, frames, target.get("relay_mode_config") as Dictionary) if not progress.is_empty() else selection_frames(frames, bool(target.get("relay_mode_unlocked")))
	var current_id: String = "relay" if bool(target.get("relay_mode")) else String(target.get("current_stream_frame_id"))
	if selection_items.is_empty():
		var fallback: Dictionary = selected_frame_state(frames, String(target.get("current_stream_frame_id")))
		target.set("current_stream_frame", fallback["frame"] as Dictionary)
		target.set("current_stream_frame_id", String(fallback["frameId"]))
		return {"restart": true, "chat": "今日の配信枠を選べ"}
	target.set("selected_stream_frame_index", selected_index(selection_items, current_id))
	return {"restart": false, "chat": "今日の配信枠を選べ"}

static func feature_labels(frame: Dictionary) -> Array[String]:
	var labels: Array[String] = []
	if frame.has("shortFeatures") and frame["shortFeatures"] is Array:
		for feature in frame["shortFeatures"]:
			labels.append(String(feature))
		return labels
	if frame.has("features") and frame["features"] is Array:
		for feature in frame["features"]:
			labels.append(String(feature))
		return labels
	for event in frame.get("events", []):
		labels.append(String(event))
	return labels

static func main_gimmick_labels(frame: Dictionary) -> Array[String]:
	var labels: Array[String] = []
	if frame.has("mainGimmicks") and frame["mainGimmicks"] is Array:
		for gimmick in frame["mainGimmicks"]:
			labels.append(String(gimmick))
		return labels
	for event in frame.get("events", []):
		labels.append(String(event))
	if labels.is_empty():
		labels = feature_labels(frame)
	return labels

static func selection_card_view(frame: Dictionary) -> Dictionary:
	var unlocked: bool = is_unlocked(frame)
	var cleared: bool = bool(frame.get("isCleared", false))
	var status_id: String = String(frame.get("statusId", _status_id(frame)))
	var coming_soon: bool = status_id == "coming_soon"
	var is_relay_frame: bool = String(frame.get("id", "")) == "relay" or bool(frame.get("isRelayMode", false))
	var status: String = _relay_status_text(status_id) if is_relay_frame else String(frame.get("statusText", _status_text(frame)))
	var display_name: String = String(frame.get("displayName", "配信枠"))
	var accent: Color = _accent_color(frame)
	var features: Array[String] = feature_labels(frame)
	var gimmicks: Array[String] = main_gimmick_labels(frame)
	var selectable: bool = is_selectable(frame)
	var view: Dictionary = {
		"id": String(frame.get("id", "")),
		"displayName": display_name,
		"plainName": display_name,
		"description": String(frame.get("description", "")) if status_id != "locked" or is_relay_frame else _locked_description(frame),
		"difficultyText": "難易度：%s" % _difficulty_stars(frame),
		"difficultyStars": _difficulty_stars(frame),
		"statusId": status_id,
		"statusText": status,
		"features": features,
		"featureText": " / ".join(features),
		"mainGimmicks": gimmicks,
		"mainGimmickText": " / ".join(gimmicks),
		"iconText": _icon_text(frame),
		"iconId": String(frame.get("iconId", _icon_id(frame))),
		"iconPath": String(frame.get("iconPath", "")),
		"accent": accent,
		"accent2": _secondary_accent_color(frame),
		"statusFill": _status_fill_color(status_id, accent),
		"statusTextColor": _status_text_color(status_id, accent),
		"statusBorder": _status_border_color(status_id, accent),
		"recommendText": _recommend_text(frame),
		"unlockConditionText": _unlock_condition_text(frame),
		"disabledReason": _disabled_reason(frame),
		"isUnlocked": unlocked,
		"isCleared": cleared,
		"isComingSoon": coming_soon,
		"isSelectable": selectable,
		"isRelayMode": bool(frame.get("isRelayMode", false))
	}
	view["difficultyText"] = "枠難度：%s" % _difficulty_stars(frame)
	view["unlockConditionText"] = String(frame.get("unlockConditionText", view.get("unlockConditionText", "")))
	view["disabledReason"] = String(frame.get("disabledReason", view.get("disabledReason", "")))
	return view

static func _relay_status_text(status_id: String) -> String:
	match status_id:
		"difficulty_locked", "relay_locked", "locked":
			return "未解禁"
		"relay_cleared", "cleared":
			return "クリア"
		"selectable", "relay_available", "unlocked":
			return "挑戦可能"
	return "未解禁"

static func _locked_description(frame: Dictionary) -> String:
	if bool(frame.get("isRelayMode", false)):
		return String(frame.get("unlockConditionText", "通常5枠をすべてクリアすると解禁されます。"))
	var condition: Dictionary = _condition_dict(frame)
	var target_id: String = String(condition.get("targetFrameId", ""))
	if target_id == "":
		return "この配信枠はまだ開放されていません。"
	return "%sをクリアすると開放されます。" % _display_name_for_id(target_id)

static func _unlock_condition_text(frame: Dictionary) -> String:
	if bool(frame.get("isRelayMode", false)):
		return String(frame.get("unlockConditionText", "すべての配信枠を開放すると選択できます。"))
	var condition: Dictionary = _condition_dict(frame)
	var target_id: String = String(condition.get("targetFrameId", ""))
	if target_id == "":
		return "最初から選択できます。"
	return "%sをクリアすると開放されます。" % _display_name_for_id(target_id)

static func _disabled_reason(frame: Dictionary) -> String:
	if _is_playable(frame):
		return ""
	var existing: String = String(frame.get("disabledReason", "")).strip_edges()
	if existing != "":
		return existing
	var status_id: String = _status_id(frame)
	if status_id == "coming_soon":
		return "この配信枠は現在準備中です。今後のアップデートで追加予定です。"
	if status_id == "locked":
		return "この配信枠はまだ開放されていません。%s" % _unlock_condition_text(frame)
	return "この配信枠は現在選択できません。"

static func _condition_dict(frame: Dictionary) -> Dictionary:
	var value: Variant = frame.get("unlockCondition", {})
	if value is Dictionary:
		return value as Dictionary
	return {}

static func _status_id(frame: Dictionary) -> String:
	var configured: String = String(frame.get("status", "")).strip_edges()
	if configured == "coming_soon" or bool(frame.get("isComingSoon", false)):
		return "coming_soon"
	if configured == "locked":
		return "locked"
	if not is_unlocked(frame):
		return "locked"
	if bool(frame.get("isRelayMode", false)):
		return "relay_available"
	if bool(frame.get("isCleared", false)):
		return "cleared"
	if configured == "relay_available":
		return "relay_available"
	return "unlocked"

static func _is_playable(frame: Dictionary) -> bool:
	var status_id: String = _status_id(frame)
	if status_id == "locked" or status_id == "coming_soon":
		return false
	if not is_unlocked(frame):
		return false
	return bool(frame.get("isPlayable", true))

static func _status_text(frame: Dictionary) -> String:
	var status_id: String = _status_id(frame)
	if status_id == "coming_soon":
		return "準備中"
	if status_id == "locked":
		return "LOCK"
	if status_id == "cleared":
		return "クリア済み"
	if status_id == "relay_available":
		return "挑戦可"
	return "解放済み"

static func _status_fill_color(status_id: String, accent: Color) -> Color:
	if status_id == "cleared":
		return Color("#fff2fa")
	if status_id == "unlocked":
		return Color("#e8f7ff")
	if status_id == "relay_available":
		return Color("#fff4d6")
	return Color("#eee9ef")

static func _status_text_color(status_id: String, accent: Color) -> Color:
	if status_id == "cleared":
		return Color("#f05aa5")
	if status_id == "unlocked":
		return Color("#247fd6")
	if status_id == "relay_available":
		return Color("#7a56c8")
	return Color("#8f8793")

static func _status_border_color(status_id: String, accent: Color) -> Color:
	if status_id == "relay_available":
		return Color("#f0b73a")
	if status_id == "locked" or status_id == "coming_soon":
		return Color("#cfc8d6")
	return accent

static func _difficulty_stars(frame: Dictionary) -> String:
	var level: int = int(frame.get("difficulty", 0))
	if level <= 0:
		var frame_id: String = String(frame.get("id", ""))
		var levels := {
			"zatsudan": 1,
			"gameplay": 2,
			"singing": 3,
			"drawing": 2,
			"collab": 3,
			"relay": 5
		}
		level = int(levels.get(frame_id, 1))
	var stars := ""
	for _i in range(clampi(level, 1, 5)):
		stars += "★"
	return stars

static func _icon_id(frame: Dictionary) -> String:
	var frame_id: String = String(frame.get("id", ""))
	return "stream_icon_%s" % frame_id

static func _icon_text(frame: Dictionary) -> String:
	return ""

static func _accent_color(frame: Dictionary) -> Color:
	var theme: String = String(frame.get("themeColor", "")).strip_edges()
	if theme == "blue":
		return Color("#438ee8")
	if theme == "purple":
		return Color("#9a6be8")
	if theme == "mint":
		return Color("#24b8bd")
	if theme == "orange":
		return Color("#f07d45")
	if theme == "relay":
		return Color("#7a56c8")
	var frame_id: String = String(frame.get("id", ""))
	if frame_id == "gameplay":
		return Color("#438ee8")
	if frame_id == "singing":
		return Color("#9a6be8")
	if frame_id == "drawing":
		return Color("#24b8bd")
	if frame_id == "collab":
		return Color("#f07d45")
	if frame_id == "relay":
		return Color("#7a56c8")
	return Color("#f05aa5")

static func _secondary_accent_color(frame: Dictionary) -> Color:
	if String(frame.get("themeColor", "")) == "relay" or bool(frame.get("isRelayMode", false)):
		return Color("#f0b73a")
	return _accent_color(frame)

static func _recommend_text(frame: Dictionary) -> String:
	var existing: String = String(frame.get("recommendText", ""))
	if existing != "":
		return existing
	var frame_id: String = String(frame.get("id", ""))
	if frame_id == "zatsudan":
		return "最初に遊ぶのにおすすめの標準配信枠です。"
	if frame_id == "gameplay":
		return "変化のある配信を楽しみたい方向けです。"
	if frame_id == "singing":
		return "盛り上がり重視の配信枠です。"
	if frame_id == "drawing":
		return "お絵かきや制作の変化を楽しむ配信枠です。"
	if frame_id == "collab":
		return "掛け合いと変化を楽しむ配信枠です。"
	if frame_id == "relay":
		return "5つの配信枠を連続で走り切る、総仕上げの特別モードです。"
	return "今日の配信に合わせて選べる配信枠です。"

static func _display_name_for_id(id: String) -> String:
	if id == "zatsudan":
		return "雑談枠"
	if id == "gameplay":
		return "ゲーム実況枠"
	if id == "singing":
		return "歌枠"
	if id == "drawing":
		return "お絵かき枠"
	if id == "collab":
		return "コラボ枠"
	if id == "relay":
		return "配信リレー"
	return id

static func clear_frame_for_target(target: Node, stats: Dictionary) -> Dictionary:
	# DifficultyProgressSystem records hard/expert runs separately.  The legacy
	# projection is intentionally updated only by NORMAL single-stage results so
	# a hard clear cannot silently unlock the normal sequence.
	if DifficultyProgressSystemScript.normalize_difficulty_id(stats.get("difficultyId", "normal")) != DifficultyProgressSystemScript.DIFFICULTY_NORMAL:
		return {"changed": false, "message": "", "saved": true}
	if bool(stats.get("isRankingEligible", false)) == false:
		return {"changed": false, "message": "", "saved": true}
	if bool(stats.get("cleared", false)) == false:
		return {"changed": false, "message": "", "saved": true}
	var frames: Array = target.get("stream_frames") as Array
	var current_id: String = String(target.get("current_stream_frame_id"))
	var current_frame: Dictionary = find_frame(frames, current_id)
	var progress: Dictionary = target.get("stream_frame_progress") as Dictionary
	if progress.is_empty():
		progress = load_progress(frames)
	var frame_progress: Dictionary = progress.get("streamFrameProgress", {}) as Dictionary
	var current_entry: Dictionary = frame_progress.get(current_id, {}) as Dictionary
	var changed: bool = false
	if not bool(current_entry.get("isCleared", false)):
		current_entry["isCleared"] = true
		changed = true
	current_entry["isUnlocked"] = true
	current_entry["bestViewerCount"] = maxi(int(current_entry.get("bestViewerCount", 0)), int(stats.get("score", 0)))
	current_entry["bestKamiRank"] = String(stats.get("rank", current_entry.get("bestKamiRank", "D")))
	frame_progress[current_id] = current_entry
	var message: String = ""
	var next_id := ""
	var next_unlock_value: Variant = current_frame.get("nextUnlockFrameId", "")
	if next_unlock_value != null:
		next_id = String(next_unlock_value)
	if next_id != "":
		var next_entry: Dictionary = frame_progress.get(next_id, {}) as Dictionary
		if not bool(next_entry.get("isUnlocked", false)):
			next_entry["isUnlocked"] = true
			next_entry["isCleared"] = bool(next_entry.get("isCleared", false))
			next_entry["bestViewerCount"] = int(next_entry.get("bestViewerCount", 0))
			next_entry["bestKamiRank"] = next_entry.get("bestKamiRank", null)
			frame_progress[next_id] = next_entry
			var next_frame: Dictionary = find_frame(frames, next_id)
			message = "新しい配信枠が解放されました！\n%s" % String(next_frame.get("displayName", next_id))
			changed = true
	if _all_frames_cleared(frames, frame_progress) and not bool(progress.get("relayModeUnlocked", false)):
		progress["relayModeUnlocked"] = true
		message = "全配信枠が解放されました！\n新モード解放：配信リレー"
		changed = true
	var saved := DifficultyProgressSystemScript.save_progress(progress)
	target.set("stream_frame_progress", progress)
	target.set("relay_mode_unlocked", bool(progress.get("relayModeUnlocked", false)))
	target.set("stream_frames", frames_with_progress(frames, progress))
	return {"changed": changed, "message": message, "saved": saved}

static func _all_frames_cleared(frames: Array, frame_progress: Dictionary) -> bool:
	for item in frames:
		var frame: Dictionary = item as Dictionary
		var frame_id: String = String(frame.get("id", ""))
		var entry: Dictionary = frame_progress.get(frame_id, {}) as Dictionary
		if not bool(entry.get("isCleared", false)):
			return false
	return true

static func _all_frames_unlocked(frames: Array, frame_progress: Dictionary) -> bool:
	# Kept as a compatibility helper for older callers.  Relay unlock itself is
	# now based on cleared frames, not merely on the old unlock flags.
	return _all_frames_cleared(frames, frame_progress)

static func unlock_all_for_target(target: Node) -> void:
	DifficultyProgressSystemScript.unlock_all_for_target(target)

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
