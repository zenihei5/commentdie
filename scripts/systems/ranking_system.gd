class_name RankingSystem
extends RefCounted

const DifficultyProgressSystemScript := preload("res://scripts/systems/difficulty_progress_system.gd")

const RANKINGS_PATH: String = "user://rankings.json"
const MAX_SAVED_ENTRIES: int = 100
const MAX_TAB_ENTRIES: int = 10
const RANK_ORDER: Dictionary = {"S": 5, "A": 4, "B": 3, "C": 2, "D": 1}

const RANKING_DATA_VERSION: int = 2
const DIFFICULTY_IDS: Array[String] = ["normal", "hard", "expert"]
const RANKING_STAGE_IDS: Array[String] = ["talk", "game", "singing", "drawing", "collab", "relay"]
const STAGE_TO_RANKING_STAGE: Dictionary = {
	"talk": "talk",
	"zatsudan": "talk",
	"game": "game",
	"gameplay": "game",
	"singing": "singing",
	"drawing": "drawing",
	"collab": "collab",
	"relay": "relay"
}
const RANKING_STAGE_TO_STREAM: Dictionary = {
	"talk": "zatsudan",
	"game": "gameplay",
	"singing": "singing",
	"drawing": "drawing",
	"collab": "collab",
	"relay": "relay"
}
const RANKING_STAGE_LABELS: Dictionary = {
	"talk": "雑談枠",
	"game": "ゲーム実況枠",
	"singing": "歌枠",
	"drawing": "お絵かき枠",
	"collab": "コラボ枠",
	"relay": "配信リレー"
}

static var _last_save_failed: bool = false
static var _ranking_data_cache: Dictionary = {}
static var _ranking_data_cache_loaded: bool = false


static func _safe_text(value: Variant, fallback: String = "") -> String:
	if value == null:
		return fallback
	if value is String or value is StringName:
		var text := str(value).strip_edges()
		return fallback if text == "" or text == "<null>" else text
	if value is int or value is float or value is bool:
		return str(value)
	return fallback


static func normalize_difficulty_id(value: Variant) -> String:
	var id := String(value).strip_edges().to_lower()
	return id if DIFFICULTY_IDS.has(id) else "normal"


static func normalize_ranking_stage_id(value: Variant) -> String:
	var id := String(value).strip_edges().to_lower()
	if STAGE_TO_RANKING_STAGE.has(id):
		return String(STAGE_TO_RANKING_STAGE[id])
	return "talk" if id == "" else id


static func create_board_key(difficulty: Variant, stage: Variant) -> String:
	return "%s:%s" % [normalize_difficulty_id(difficulty), normalize_ranking_stage_id(stage)]


static func board_key_for_entry(entry: Dictionary) -> String:
	return create_board_key(entry_difficulty(entry), entry_stage(entry))


static func entry_difficulty(entry: Dictionary) -> String:
	return normalize_difficulty_id(entry.get("difficulty", entry.get("difficultyId", "normal")))


static func entry_stage(entry: Dictionary) -> String:
	if String(entry.get("modeId", "")) == "relay":
		return "relay"
	var raw_stage: Variant = entry.get("stageId", entry.get("streamFrameId", "talk"))
	return normalize_ranking_stage_id(raw_stage)


static func stage_index(stage: Variant) -> int:
	return maxi(0, RANKING_STAGE_IDS.find(normalize_ranking_stage_id(stage)))


static func stream_frame_id_for_stage(stage: Variant) -> String:
	return String(RANKING_STAGE_TO_STREAM.get(normalize_ranking_stage_id(stage), "zatsudan"))


static func stage_label(stage: Variant) -> String:
	return String(RANKING_STAGE_LABELS.get(normalize_ranking_stage_id(stage), "配信枠"))


static func ranking_character_sprite_path(character: Dictionary) -> String:
	var idle_path := String(character.get("idleSprite", "")).strip_edges()
	if idle_path == "" and String(character.get("id", "")) == "ban_chan":
		idle_path = "res://assets/generated/ban_chan_idle_3x3/sheet-transparent.png"
	for path_value in [
		idle_path,
		String(character.get("sprite", "")),
		String(character.get("rankingSprite", "")),
		String(character.get("resultSprite", "")),
		String(character.get("selectSprite", ""))
	]:
		var path := String(path_value).strip_edges()
		if path != "":
			return path
	return ""


static func normalize_entry(raw_value: Variant, legacy_relay: bool = false) -> Dictionary:
	if not (raw_value is Dictionary):
		return {}
	var source: Dictionary = (raw_value as Dictionary).duplicate(true)
	var result: Dictionary = source.duplicate(true)
	var relay := legacy_relay or String(source.get("modeId", "")) == "relay" or normalize_ranking_stage_id(source.get("stageId", "")) == "relay"
	var difficulty := normalize_difficulty_id(source.get("difficulty", source.get("difficultyId", "normal")))
	var stage := "relay" if relay else normalize_ranking_stage_id(source.get("stageId", source.get("streamFrameId", "talk")))
	result["dataVersion"] = RANKING_DATA_VERSION
	result["difficulty"] = difficulty
	result["difficultyId"] = difficulty
	result["stageId"] = stage
	if not result.has("streamFrameId") or String(result.get("streamFrameId", "")).strip_edges() == "":
		result["streamFrameId"] = stream_frame_id_for_stage(stage)
	if relay:
		result["modeId"] = "relay"
		result["playMode"] = "relay"
	else:
		result["playMode"] = String(result.get("playMode", "single"))
	if not result.has("score"):
		result["score"] = int(source.get("maxViewerCount", source.get("viewerCount", 0)))
	result["score"] = maxi(0, int(result.get("score", 0)))
	result["characterId"] = String(result.get("characterId", source.get("character", "")))
	result["cleared"] = bool(result.get("cleared", result.get("isRelayCompleted", false)))
	result["gameOver"] = bool(result.get("gameOver", String(result.get("endType", "")) == "mental_breakdown"))
	result["lastInstructionComment"] = _safe_text(result.get("lastInstructionComment", null), "なし")
	result["culpritInstructionComment"] = _safe_text(result.get("culpritInstructionComment", null), "なし")
	result["deathText"] = _safe_text(result.get("deathText", null), "")
	if result.get("relay", {}) is Dictionary:
		var relay_data: Dictionary = (result.get("relay", {}) as Dictionary).duplicate(true)
		relay_data["reachedStageId"] = normalize_ranking_stage_id(relay_data.get("reachedStageId", source.get("streamFrameId", "talk")))
		relay_data["reachedSectionIndex"] = clampi(int(relay_data.get("reachedSectionIndex", source.get("clearedFrameCount", 0))), 0, 5)
		relay_data["finalBossPhase"] = clampi(int(relay_data.get("finalBossPhase", 0)), 0, 3)
		result["relay"] = relay_data
	return result


static func normalize_entries(raw_entries: Array, legacy_relay: bool = false) -> Array:
	var result: Array = []
	var seen: Dictionary = {}
	for item in raw_entries:
		var entry := normalize_entry(item, legacy_relay)
		if entry.is_empty():
			continue
		var run_id := String(entry.get("runId", "")).strip_edges()
		var key := "%s|%s" % [board_key_for_entry(entry), run_id] if run_id != "" else "entry|%d" % result.size()
		if seen.has(key):
			continue
		seen[key] = true
		result.append(entry)
	return result


static func load_all_entries() -> Array:
	return _safe_array(_load_ranking_data().get("entries", [])).duplicate(true)


static func load_rankings() -> Array:
	return load_all_entries()


static func load_relay_rankings() -> Array:
	var result: Array = []
	for item in load_all_entries():
		if item is Dictionary and entry_stage(item as Dictionary) == "relay":
			result.append(item)
	return result


static func _load_ranking_data() -> Dictionary:
	if _ranking_data_cache_loaded:
		return _ranking_data_cache
	if not FileAccess.file_exists(RANKINGS_PATH):
		return _set_ranking_data_cache({"dataVersion": RANKING_DATA_VERSION, "entries": [], "rankingEntries": [], "relayRankingEntries": [], "uiState": {}})
	var file: FileAccess = FileAccess.open(RANKINGS_PATH, FileAccess.READ)
	if file == null:
		return _set_ranking_data_cache({"dataVersion": RANKING_DATA_VERSION, "entries": [], "rankingEntries": [], "relayRankingEntries": [], "uiState": {}})
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Array:
		var legacy_entries: Array = parsed as Array
		var normalized_legacy := normalize_entries(legacy_entries)
		return _set_ranking_data_cache({
			"dataVersion": RANKING_DATA_VERSION,
			"entries": normalized_legacy,
			"rankingEntries": normalized_legacy.filter(func(item: Variant) -> bool: return item is Dictionary and entry_stage(item as Dictionary) != "relay"),
			"relayRankingEntries": normalized_legacy.filter(func(item: Variant) -> bool: return item is Dictionary and entry_stage(item as Dictionary) == "relay"),
			"uiState": {}
		})
	if parsed is Dictionary:
		var data: Dictionary = (parsed as Dictionary).duplicate(true)
		var raw_entries: Array = []
		for item in _safe_array(data.get("entries", [])):
			raw_entries.append(item)
		for item in _safe_array(data.get("rankingEntries", [])):
			raw_entries.append(item)
		for item in _safe_array(data.get("relayRankingEntries", [])):
			raw_entries.append(item)
		var normalized := normalize_entries(raw_entries)
		data["dataVersion"] = RANKING_DATA_VERSION
		data["entries"] = normalized
		data["rankingEntries"] = normalized.filter(func(item: Variant) -> bool: return item is Dictionary and entry_stage(item as Dictionary) != "relay")
		data["relayRankingEntries"] = normalized.filter(func(item: Variant) -> bool: return item is Dictionary and entry_stage(item as Dictionary) == "relay")
		if not data.has("uiState") or not (data.get("uiState") is Dictionary):
			data["uiState"] = {}
		return _set_ranking_data_cache(data)
	return _set_ranking_data_cache({"dataVersion": RANKING_DATA_VERSION, "entries": [], "rankingEntries": [], "relayRankingEntries": [], "uiState": {}})


static func _set_ranking_data_cache(data: Dictionary) -> Dictionary:
	_ranking_data_cache = data
	_ranking_data_cache_loaded = true
	return _ranking_data_cache


static func save_rankings(entries: Array) -> void:
	save_all_rankings(entries, load_relay_rankings())


static func save_relay_rankings(entries: Array) -> void:
	save_all_rankings(load_rankings(), entries)


static func reset_rankings() -> void:
	save_all_rankings([], [])


static func reset_board(difficulty: Variant, stage: Variant) -> bool:
	var board_key := create_board_key(difficulty, stage)
	var entries: Array = []
	for item in load_all_entries():
		if not (item is Dictionary) or board_key_for_entry(item as Dictionary) != board_key:
			entries.append(item)
	return _save_entries_with_ui_state(entries, _load_ranking_data().get("uiState", {}))


static func ranking_ui_state() -> Dictionary:
	return _dict(_load_ranking_data().get("uiState", {})).duplicate(true)


static func save_ranking_ui_state(state: Dictionary) -> bool:
	var loaded := _load_ranking_data()
	var current_state := _dict(loaded.get("uiState", {}))
	if current_state == state:
		return true
	var payload := loaded.duplicate(true)
	payload["uiState"] = state.duplicate(true)
	return _write_ranking_payload(payload)


static func reset_tab(tab_index: int = 0, relay_mode_unlocked: bool = false) -> void:
	var clamped_tab: int = clamp_tab_index(tab_index, relay_mode_unlocked)
	var tab: Dictionary = _tabs(relay_mode_unlocked)[clamped_tab] as Dictionary
	var tab_id: String = String(tab.get("id", "all"))
	if tab_id == "relay":
		save_relay_rankings([])
		return
	if tab_id == "all":
		var kept_difficulty_entries: Array = []
		for entry_item in load_rankings():
			if entry_item is Dictionary and _entry_difficulty_id(entry_item as Dictionary) != "normal":
				kept_difficulty_entries.append(entry_item)
		save_rankings(kept_difficulty_entries)
		return
	var kept_entries: Array = []
	for entry_item in load_rankings():
		if not (entry_item is Dictionary):
			continue
		var entry: Dictionary = entry_item as Dictionary
		if _entry_difficulty_id(entry) != "normal":
			kept_entries.append(entry)
			continue
		if String(entry.get("streamFrameId", "")) != tab_id:
			kept_entries.append(entry)
	save_rankings(kept_entries)


static func tab_reset_label(tab_index: int = 0, relay_mode_unlocked: bool = false) -> String:
	var tab: Dictionary = _tabs(relay_mode_unlocked)[clamp_tab_index(tab_index, relay_mode_unlocked)] as Dictionary
	return String(tab.get("label", "ランキング")).replace(" 未開放", "")


static func save_all_rankings(entries: Array, relay_entries: Array) -> void:
	var combined: Array = []
	combined.append_array(entries)
	combined.append_array(relay_entries)
	_save_entries_with_ui_state(normalize_entries(combined), _load_ranking_data().get("uiState", {}))


static func _save_entries_with_ui_state(raw_entries: Array, ui_state_value: Variant) -> bool:
	var by_board: Dictionary = {}
	for item in normalize_entries(raw_entries):
		if not (item is Dictionary):
			continue
		var entry: Dictionary = item as Dictionary
		var board_key := board_key_for_entry(entry)
		if not by_board.has(board_key):
			by_board[board_key] = []
		(by_board[board_key] as Array).append(entry)
	var entries: Array = []
	for board_key in by_board.keys():
		var board_entries: Array = _sort_entries(by_board[board_key] as Array)
		entries.append_array(board_entries.slice(0, MAX_SAVED_ENTRIES))
	var payload: Dictionary = _load_ranking_data().duplicate(true)
	payload["dataVersion"] = RANKING_DATA_VERSION
	payload["entries"] = entries
	payload["rankingEntries"] = entries.filter(func(item: Variant) -> bool: return item is Dictionary and entry_stage(item as Dictionary) != "relay")
	payload["relayRankingEntries"] = entries.filter(func(item: Variant) -> bool: return item is Dictionary and entry_stage(item as Dictionary) == "relay")
	payload["uiState"] = _dict(ui_state_value).duplicate(true)
	return _write_ranking_payload(payload)


static func _write_ranking_payload(payload: Dictionary) -> bool:
	var temp_path := RANKINGS_PATH + ".tmp"
	var file: FileAccess = FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		_last_save_failed = true
		return false
	file.store_string(JSON.stringify(payload, "\t"))
	file.flush()
	file.close()
	if DirAccess.rename_absolute(temp_path, RANKINGS_PATH) != OK:
		var fallback: FileAccess = FileAccess.open(RANKINGS_PATH, FileAccess.WRITE)
		if fallback == null:
			_last_save_failed = true
			return false
		fallback.store_string(JSON.stringify(payload, "\t"))
		fallback.flush()
		fallback.close()
	_last_save_failed = false
	_set_ranking_data_cache(payload)
	return true


static func save_and_format_ranking(entry: Dictionary, is_ranking_eligible: bool) -> String:
	if not is_ranking_eligible or not ["normal_180", "relay"].has(String(entry.get("modeId", ""))):
		return "ランキング対象外：テスト配信の記録は保存されません。"
	var entries: Array = load_rankings()
	entries.append(entry)
	var sorted_entries: Array = _sort_entries(entries)
	if sorted_entries.size() > MAX_SAVED_ENTRIES:
		sorted_entries = sorted_entries.slice(0, MAX_SAVED_ENTRIES)
	save_rankings(sorted_entries)
	var scoped_entries: Array = _ranking_scope_entries(sorted_entries, String(entry.get("streamFrameId", "")), _entry_difficulty_id(entry))
	var rank_index: int = _rank_position(scoped_entries, entry)
	var viewer_count: int = int(entry.get("viewerCount", entry.get("score", 0)))
	return "%s登録：%d位 / 最大同時視聴者数 %s人" % [
		_ranking_scope_label(entry),
		rank_index,
		_format_number(viewer_count)
	]


static func save_and_format_relay_ranking(entry: Dictionary, is_ranking_eligible: bool) -> String:
	if not is_ranking_eligible or String(entry.get("modeId", "")) != "relay":
		return "ランキング対象外：配信リレー以外の記録は保存されません。"
	var entries: Array = load_relay_rankings()
	entries.append(entry)
	var sorted_entries: Array = _sort_relay_entries(entries)
	if sorted_entries.size() > MAX_SAVED_ENTRIES:
		sorted_entries = sorted_entries.slice(0, MAX_SAVED_ENTRIES)
	save_relay_rankings(sorted_entries)
	var rank_index: int = _relay_rank_position(sorted_entries, entry)
	return "配信リレーランキング登録：%d位 / %s / 最大%s人" % [
		rank_index,
		_relay_progress_text(entry),
		_format_number(int(entry.get("maxViewerCount", 0)))
	]


static func save_entry_and_format(entry: Dictionary, eligible: bool) -> String:
	if not eligible or not ["normal_180", "relay"].has(String(entry.get("modeId", ""))):
		return "ランキング対象外です"
	var normalized := normalize_entry(entry)
	var entries: Array = load_all_entries()
	var board_key := board_key_for_entry(normalized)
	var replaced := false
	for index in range(entries.size()):
		if entries[index] is Dictionary and String((entries[index] as Dictionary).get("runId", "")) == String(normalized.get("runId", "")) and board_key_for_entry(entries[index] as Dictionary) == board_key:
			entries[index] = normalized
			replaced = true
			break
	if not replaced:
		entries.append(normalized)
	if not _save_entries_with_ui_state(entries, _load_ranking_data().get("uiState", {})):
		return "ランキングを保存できませんでした"
	var board_entries := _sorted_entries_for_board(entry_difficulty(normalized), entry_stage(normalized))
	var rank_index := _rank_position(board_entries, normalized)
	return "%sランキング登録: %d位 / 最大同時視聴者数 %s人" % [stage_label(entry_stage(normalized)), rank_index, _format_number(_entry_score(normalized))]


static func _sorted_entries_for_board(difficulty: Variant, stage: Variant) -> Array:
	var board_key := create_board_key(difficulty, stage)
	var result: Array = []
	for item in load_all_entries():
		if item is Dictionary and board_key_for_entry(item as Dictionary) == board_key:
			result.append(item)
	return _sort_entries(result)


static func entries_for_board(difficulty: Variant, stage: Variant) -> Array:
	return _sorted_entries_for_board(difficulty, stage)


static func ranking_stage_tabs(progress: Dictionary, difficulty: Variant) -> Array:
	var result: Array = []
	var difficulty_id := normalize_difficulty_id(difficulty)
	var effective_progress := progress
	if effective_progress.is_empty():
		effective_progress = DifficultyProgressSystemScript.create_default_save_data([])
	for stage_id in RANKING_STAGE_IDS:
		var internal_stage := "relay" if stage_id == "relay" else String(RANKING_STAGE_TO_STREAM.get(stage_id, "zatsudan"))
		var state := DifficultyProgressSystemScript.get_stage_card_state(effective_progress, difficulty_id, internal_stage)
		var locked := not bool(state.get("selectable", false))
		result.append({
			"id": stage_id,
			"label": stage_label(stage_id),
			"locked": locked,
			"selectable": not locked,
			"status": String(state.get("status", "")),
			"unlockText": _ranking_stage_unlock_text(state, difficulty_id, stage_id),
			"selected": false
		})
	return result


static func _ranking_stage_unlock_text(state: Dictionary, difficulty_id: String, stage_id: String) -> String:
	if bool(state.get("selectable", false)):
		return ""
	var status := String(state.get("status", ""))
	if status == "relay_locked":
		return "%sの通常5枠をクリア" % difficulty_id.to_upper()
	if status == "difficulty_locked":
		return "%sが未解禁です" % difficulty_id.to_upper()
	if status == "stage_locked":
		var stage_position := RANKING_STAGE_IDS.find(stage_id)
		if stage_position > 0:
			return "%s・%sをクリア" % [stage_label(RANKING_STAGE_IDS[stage_position - 1]), difficulty_id.to_upper()]
	var condition := String(state.get("condition", "")).strip_edges()
	if condition != "":
		return condition
	return "%sはまだ解禁されていません" % stage_label(stage_id)


static func difficulty_tabs(progress: Dictionary) -> Array:
	var result: Array = []
	for difficulty_id in DIFFICULTY_IDS:
		result.append(_difficulty_tab_state(progress, difficulty_id))
	return result


static func _difficulty_tab_state(progress: Dictionary, difficulty_id: String) -> Dictionary:
	var unlocked := difficulty_id == "normal"
	if difficulty_id == "hard":
		unlocked = DifficultyProgressSystemScript.can_unlock_hard(progress)
	if difficulty_id == "expert":
		unlocked = DifficultyProgressSystemScript.can_unlock_expert(progress)
	return {"id": difficulty_id, "label": difficulty_id.to_upper(), "locked": not unlocked, "selected": false, "unlockText": "NORMAL配信リレーをクリア" if difficulty_id == "hard" else ("HARD配信リレーをクリア" if difficulty_id == "expert" else "")}


static func _progress_bool(progress: Dictionary, path: Array) -> bool:
	var current: Variant = progress
	for key in path:
		if not (current is Dictionary):
			return false
		current = (current as Dictionary).get(key, {})
	return bool(current)


static func ranking_view_for_board(progress: Dictionary, difficulty: Variant, stage: Variant, page: int = 0, row: int = 0, detail_visible: bool = false) -> Dictionary:
	var difficulty_id := normalize_difficulty_id(difficulty)
	var stage_id := normalize_ranking_stage_id(stage)
	var tabs := difficulty_tabs(progress)
	for tab in tabs:
		if tab is Dictionary and String((tab as Dictionary).get("id", "")) == difficulty_id:
			(tab as Dictionary)["selected"] = true
	var stage_tabs := ranking_stage_tabs(progress, difficulty_id)
	for tab in stage_tabs:
		if tab is Dictionary and String((tab as Dictionary).get("id", "")) == stage_id:
			(tab as Dictionary)["selected"] = true
	var locked := false
	var lock_text := ""
	for tab in tabs:
		if tab is Dictionary and String((tab as Dictionary).get("id", "")) == difficulty_id:
			locked = bool((tab as Dictionary).get("locked", false))
			lock_text = String((tab as Dictionary).get("unlockText", ""))
			break
	if not locked and _ranking_stage_locked(progress, difficulty_id, stage_id):
		locked = true
		lock_text = "この枠はまだ解禁されていません"
	var view: Dictionary = {"title": "%s・%sランキング" % [stage_label(stage_id), difficulty_id.to_upper()], "subtitle": "%s / %s" % [stage_label(stage_id), difficulty_id.to_upper()], "difficultyId": difficulty_id, "stageId": stage_id, "boardKey": create_board_key(difficulty_id, stage_id), "tabs": tabs, "stageTabs": stage_tabs, "locked": locked, "empty": false, "messageLines": [], "rows": [], "selectedIndex": 0, "pageIndex": maxi(0, page), "pageCount": 1, "detailVisible": true, "detail": {}}
	if locked:
		view["messageLines"] = ["この難易度は未解禁です", lock_text]
		return view
	var all_entries := _sorted_entries_for_board(difficulty_id, stage_id)
	if all_entries.is_empty():
		view["empty"] = true
		view["messageLines"] = ["まだランキング記録がありません"]
		return view
	var page_count := maxi(1, int(ceil(float(all_entries.size()) / float(MAX_TAB_ENTRIES))))
	var page_index := clampi(page, 0, page_count - 1)
	var page_entries := all_entries.slice(page_index * MAX_TAB_ENTRIES, mini(all_entries.size(), (page_index + 1) * MAX_TAB_ENTRIES))
	var selected := clampi(row, 0, maxi(0, page_entries.size() - 1))
	view["pageIndex"] = page_index
	view["pageCount"] = page_count
	view["selectedIndex"] = selected
	for index in range(page_entries.size()):
		var entry: Dictionary = page_entries[index] as Dictionary
		view["rows"].append(_board_row_view(entry, page_index * MAX_TAB_ENTRIES + index + 1, index == selected))
	view["detail"] = _board_detail_view(page_entries[selected] as Dictionary, page_index * MAX_TAB_ENTRIES + selected + 1)
	return view


static func _ranking_stage_locked(progress: Dictionary, difficulty_id: String, stage_id: String) -> bool:
	for tab_item in ranking_stage_tabs(progress, difficulty_id):
		if tab_item is Dictionary and String((tab_item as Dictionary).get("id", "")) == stage_id:
			return bool((tab_item as Dictionary).get("locked", false))
	return true


static func _board_row_view(entry: Dictionary, rank: int, selected: bool) -> Dictionary:
	var relay := entry_stage(entry) == "relay"
	var status := "CLEAR" if bool(entry.get("cleared", entry.get("isRelayCompleted", false))) else _ranking_reach_text(entry)
	var boss_source: Dictionary = entry.get("boss", {}) as Dictionary if entry.get("boss", {}) is Dictionary else {}
	var boss_count := clampi(int(boss_source.get("defeatedCount", entry.get("bossCount", 0))), 0, 2)
	return {"rank": rank, "selected": selected, "characterId": _character_id(entry), "character": _character_nickname(entry), "title": _character_nickname(entry), "scoreLabel": "最大同時視聴者数", "scoreText": "%s人" % _format_number(_entry_score(entry)), "summary": ("BOSS×%d / %s" % [boss_count, status]) if not relay else ("%s / %s" % [status, _ranking_reach_text(entry)]), "build": _format_build_short(entry), "weapons": _slice_items(_safe_array(entry.get("weapons", [])), 5), "accessories": _slice_items(_safe_array(entry.get("accessories", [])), 5), "endType": _entry_end_type(entry), "endTypeLabel": _end_type_label(entry), "accent": _rank_accent(rank - 1)}


static func _ranking_reach_text(entry: Dictionary) -> String:
	var relay: Dictionary = entry.get("relay", {}) as Dictionary if entry.get("relay", {}) is Dictionary else {}
	if bool(relay.get("finalBossDefeated", entry.get("finalBossDefeated", false))):
		return "CLEAR"
	if bool(relay.get("reachedFinalBoss", entry.get("reachedFinalBoss", false))):
		return "FINAL P%d" % clampi(int(relay.get("finalBossPhase", entry.get("finalBossPhase", 1))), 1, 3)
	return stage_label(relay.get("reachedStageId", entry.get("stageId", "talk")))


static func _board_detail_view(entry: Dictionary, rank: int) -> Dictionary:
	var relay := entry_stage(entry) == "relay"
	var difficulty_id := entry_difficulty(entry)
	var stage_id := entry_stage(entry)
	var end_type := _entry_end_type(entry)
	var detail: Dictionary = _relay_detail_view(entry, rank) if relay else _normal_detail_view(entry, rank)
	var summary_lines: Array = [
		"%s / %s・%s" % [_character_nickname(entry), stage_label(stage_id), difficulty_id.to_upper()],
		"最大同時視聴者数：%s人" % _format_number(_entry_score(entry))
	]
	if relay:
		summary_lines.append("最高到達：%s / 終了：%s" % [_ranking_reach_text(entry), _end_type_label(entry)])
	else:
		summary_lines.append("神回度：%s / 終了：%s" % [String(entry.get("kamiRank", entry.get("rank", "D"))), _end_type_label(entry)])
	var partner_text := ""
	if stage_id == "collab" or relay:
		partner_text = "相方: %s" % _ranking_partner_name(entry)
		summary_lines[2] = "%s / %s" % [String(summary_lines[2]), partner_text]
	var instruction_lines: Array = _instruction_lines(entry, end_type)
	var extra_result_parts: Array[String] = []
	if partner_text != "":
		extra_result_parts.append(partner_text)
	if difficulty_id == "hard" and not relay:
		extra_result_parts.append("高難度指示コメ：%d回" % int(entry.get("selectedHighDifficultyCommentCount", entry.get("dangerCommentsChosen", 0))))
	if not extra_result_parts.is_empty():
		instruction_lines.append(" / ".join(extra_result_parts))
	detail["title"] = "%s・%s" % [stage_label(stage_id), difficulty_id.to_upper()]
	detail["rankLabel"] = "%d位記録" % rank
	detail["summaryLines"] = summary_lines
	detail["instructionTitle"] = _instruction_title(end_type)
	detail["instructionLines"] = instruction_lines
	detail["playedAtText"] = _format_played_at(String(entry.get("playedAt", entry.get("createdAt", ""))))
	detail["endTypeLabel"] = _end_type_label(entry)
	detail["endType"] = end_type
	if difficulty_id == "hard":
		detail["bossLabel"] = "HARD情報"
		detail["bossText"] = _hard_relay_detail_text(entry) if relay else _hard_single_detail_text(entry)
	return detail


static func _ranking_partner_name(entry: Dictionary) -> String:
	var name := String(entry.get("partnerName", entry.get("collabPartnerName", ""))).strip_edges()
	if name != "":
		return name
	var partner_id := String(entry.get("partnerId", "")).strip_edges()
	if partner_id == "":
		return "なし"
	var nickname := _character_nickname({"characterId": partner_id})
	return partner_id if nickname == "配信者" else nickname


static func _hard_single_detail_text(entry: Dictionary) -> String:
	var boss_data: Dictionary = entry.get("boss", {}) as Dictionary if entry.get("boss", {}) is Dictionary else {}
	var first_defeated := bool(boss_data.get("firstBossDefeated", entry.get("firstBossDefeated", false)))
	var first_spawned := bool(boss_data.get("firstBossSpawned", entry.get("firstBossSpawned", first_defeated)))
	var reignition_defeated := bool(boss_data.get("reignitionBossDefeated", entry.get("reignitionBossDefeated", false)))
	var reignition_spawned := bool(boss_data.get("reignitionBossSpawned", entry.get("reignitionBossSpawned", reignition_defeated)))
	return "ハードボス %s / 再炎上ボス %s" % [
		_boss_state_text(first_spawned, first_defeated),
		_boss_state_text(reignition_spawned, reignition_defeated)
	]


static func _hard_relay_detail_text(entry: Dictionary) -> String:
	var relay_data: Dictionary = entry.get("relay", {}) as Dictionary if entry.get("relay", {}) is Dictionary else {}
	var final_boss_defeated := bool(relay_data.get("finalBossDefeated", entry.get("finalBossDefeated", false)))
	return "最高到達 %s / 最終ボス撃破 %s" % [_ranking_reach_text(entry), "達成" if final_boss_defeated else "未達成"]


static func _boss_state_text(spawned: bool, defeated: bool) -> String:
	if defeated:
		return "撃破"
	return "未撃破" if spawned else "未出現"


static func tab_count(relay_mode_unlocked: bool = false) -> int:
	return _tabs(relay_mode_unlocked).size()


static func clamp_tab_index(tab_index: int, relay_mode_unlocked: bool = false) -> int:
	return clampi(tab_index, 0, maxi(0, tab_count(relay_mode_unlocked) - 1))


static func entry_count_for_tab(tab_index: int, relay_mode_unlocked: bool = false) -> int:
	return _sorted_entries_for_tab(tab_index, relay_mode_unlocked).size()


static func format_ranking_screen(tab_index: int = 0, selected_index: int = 0, relay_mode_unlocked: bool = false) -> String:
	var tab: Dictionary = _tabs(relay_mode_unlocked)[clamp_tab_index(tab_index, relay_mode_unlocked)] as Dictionary
	var tab_id: String = String(tab.get("id", "all"))
	var lines: Array[String] = []
	lines.append("配信リレーランキング" if tab_id == "relay" else "神回ランキング")
	lines.append(_format_tabs(tab_index, relay_mode_unlocked))
	lines.append("")
	if bool(tab.get("locked", false)):
		if tab_id == "relay":
			lines.append("配信リレーはまだ開放されていません。")
			lines.append("すべての配信枠を開放すると選択できます。")
		else:
			lines.append("この配信枠はまだ開放されていません。")
			lines.append(String(tab.get("unlockText", "ゲーム実況枠をクリアすると開放されます。")))
		return "\n".join(lines)

	var entries: Array = _sorted_entries_for_tab(tab_index, relay_mode_unlocked)
	if entries.is_empty():
		if tab_id == "relay":
			lines.append("まだ配信リレーの記録がありません。")
			lines.append("全配信枠を突破して、神回リレーを目指そう！")
		else:
			lines.append("まだ記録がありません。")
			if tab_id == "all":
				lines.append("ニューゲームから配信を始めよう！")
			else:
				lines.append("この配信枠で神回を目指そう！")
		return "\n".join(lines)

	var clamped_selected: int = clampi(selected_index, 0, entries.size() - 1)
	for index in range(entries.size()):
		var entry: Dictionary = entries[index] as Dictionary
		if tab_id == "relay":
			lines.append(_format_relay_entry_row(entry, index, index == clamped_selected))
		else:
			lines.append(_format_entry_row(entry, index, index == clamped_selected, tab_id == "all"))
	lines.append("")
	if tab_id == "relay":
		lines.append(_format_relay_detail(entries[clamped_selected] as Dictionary, clamped_selected + 1))
	else:
		lines.append(_format_detail(entries[clamped_selected] as Dictionary, clamped_selected + 1))
	return "\n".join(lines)


static func ranking_view(tab_index: int = 0, selected_index: int = 0, relay_mode_unlocked: bool = false) -> Dictionary:
	var clamped_tab: int = clamp_tab_index(tab_index, relay_mode_unlocked)
	var tabs: Array = _tabs(relay_mode_unlocked)
	var tab: Dictionary = tabs[clamped_tab] as Dictionary
	var tab_id: String = String(tab.get("id", "all"))
	var tab_views: Array = []
	for index in range(tabs.size()):
		var source_tab: Dictionary = tabs[index] as Dictionary
		tab_views.append({
			"id": String(source_tab.get("id", "")),
			"label": String(source_tab.get("label", "")),
			"locked": bool(source_tab.get("locked", false)),
			"selected": index == clamped_tab
		})
	var view: Dictionary = {
		"title": "ランキング",
		"subtitle": "最大同時視聴者数ランキング",
		"tabId": tab_id,
		"tabIndex": clamped_tab,
		"tabs": tab_views,
		"locked": bool(tab.get("locked", false)),
		"empty": false,
		"messageLines": [],
		"rows": [],
		"selectedIndex": 0,
		"detailCards": [],
		"detail": {}
	}
	if bool(view["locked"]):
		if tab_id == "relay":
			view["messageLines"] = ["配信リレーランキングはまだ開放されていません。", "すべての配信枠を開放するとランキングが表示されます。"]
		else:
			view["messageLines"] = ["この配信枠はまだ開放されていません。", "解放条件：%s" % String(tab.get("unlockText", "ゲーム実況枠をクリアすると開放されます。"))]
		return view
	var entries: Array = _sorted_entries_for_tab(clamped_tab, relay_mode_unlocked)
	if entries.is_empty():
		view["empty"] = true
		if tab_id == "relay":
			view["messageLines"] = ["まだ配信リレーの記録がありません。", "配信リレーを遊ぶと、最大同時視聴者数ランキングに登録されます。"]
		elif tab_id == "all":
			view["messageLines"] = ["まだ記録がありません。", "配信を遊ぶと、最大同時視聴者数ランキングに登録されます。"]
		else:
			view["messageLines"] = ["まだ記録がありません。", "この配信枠を遊ぶと、最大同時視聴者数ランキングに登録されます。"]
		return view
	var clamped_selected: int = clampi(selected_index, 0, entries.size() - 1)
	view["selectedIndex"] = clamped_selected
	var rows: Array = []
	for index in range(entries.size()):
		var entry: Dictionary = entries[index] as Dictionary
		rows.append(_relay_row_view(entry, index, index == clamped_selected) if tab_id == "relay" else _normal_row_view(entry, index, index == clamped_selected, tab_id == "all"))
	view["rows"] = rows
	var selected_entry: Dictionary = entries[clamped_selected] as Dictionary
	view["detailCards"] = _relay_detail_cards(selected_entry) if tab_id == "relay" else _normal_detail_cards(selected_entry)
	view["detail"] = _relay_detail_view(selected_entry, clamped_selected + 1) if tab_id == "relay" else _normal_detail_view(selected_entry, clamped_selected + 1)
	return view


static func _tabs(relay_mode_unlocked: bool = false) -> Array:
	return [
		{"id": "all", "label": "総合"},
		{"id": "zatsudan", "label": "雑談枠"},
		{"id": "gameplay", "label": "ゲーム実況枠"},
		{"id": "singing", "label": "歌枠"},
		{"id": "drawing", "label": "お絵かき枠 未開放", "locked": true, "unlockText": "歌枠をクリアすると開放されます。"},
		{"id": "collab", "label": "コラボ枠 未開放", "locked": true, "unlockText": "お絵かき枠をクリアすると開放されます。"},
		{"id": "relay", "label": "配信リレー" if relay_mode_unlocked else "配信リレー 未開放", "locked": not relay_mode_unlocked}
	]


static func _format_tabs(tab_index: int, relay_mode_unlocked: bool = false) -> String:
	var labels: Array[String] = []
	var tabs: Array = _tabs(relay_mode_unlocked)
	for index in range(tabs.size()):
		var tab: Dictionary = tabs[index] as Dictionary
		var label: String = String(tab.get("label", ""))
		if index == clamp_tab_index(tab_index, relay_mode_unlocked):
			labels.append("[%s]" % label)
		else:
			labels.append(label)
	return " / ".join(labels)


static func _sorted_entries_for_tab(tab_index: int, relay_mode_unlocked: bool = false) -> Array:
	var tab: Dictionary = _tabs(relay_mode_unlocked)[clamp_tab_index(tab_index, relay_mode_unlocked)] as Dictionary
	if bool(tab.get("locked", false)):
		return []
	var tab_id: String = String(tab.get("id", "all"))
	if tab_id == "relay":
		var relay_entries: Array = []
		for entry_item in load_rankings():
			if not (entry_item is Dictionary):
				continue
			var relay_entry: Dictionary = entry_item as Dictionary
			if _entry_difficulty_id(relay_entry) == "normal" and (String(relay_entry.get("modeId", "")) == "relay" or String(relay_entry.get("stageId", "")) == "relay"):
				relay_entries.append(relay_entry)
		var sorted_relay_entries: Array = _sort_entries(relay_entries)
		if sorted_relay_entries.size() > MAX_TAB_ENTRIES:
			return sorted_relay_entries.slice(0, MAX_TAB_ENTRIES)
		return sorted_relay_entries
	var entries: Array = []
	for entry_item in load_rankings():
		if not (entry_item is Dictionary):
			continue
		var entry: Dictionary = entry_item as Dictionary
		if not ["normal_180", "relay"].has(String(entry.get("modeId", ""))):
			continue
		if _entry_difficulty_id(entry) != "normal":
			continue
		if tab_id != "all" and String(entry.get("streamFrameId", "")) != tab_id:
			continue
		entries.append(entry)
	var sorted_entries: Array = _sort_entries(entries)
	if sorted_entries.size() > MAX_TAB_ENTRIES:
		return sorted_entries.slice(0, MAX_TAB_ENTRIES)
	return sorted_entries


static func _sort_entries(entries: Array) -> Array:
	var sorted_entries: Array = entries.duplicate()
	sorted_entries.sort_custom(func(a: Variant, b: Variant) -> bool:
		if not (a is Dictionary) or not (b is Dictionary):
			return false
		return _entry_is_higher(a as Dictionary, b as Dictionary)
	)
	return sorted_entries


static func _sort_relay_entries(entries: Array) -> Array:
	var sorted_entries: Array = entries.duplicate()
	sorted_entries.sort_custom(func(a: Variant, b: Variant) -> bool:
		if not (a is Dictionary) or not (b is Dictionary):
			return false
		return _relay_entry_is_higher(a as Dictionary, b as Dictionary)
	)
	return sorted_entries


static func _format_entry_row(entry: Dictionary, index: int, selected: bool, show_frame: bool) -> String:
	var marker: String = ">" if selected else " "
	var viewer_count: int = int(entry.get("viewerCount", entry.get("score", 0)))
	var parts: Array[String] = [
		"%s%2d." % [marker, index + 1],
		_character_nickname(entry),
		"%s人" % _format_number(viewer_count),
		"神回度%s" % String(entry.get("kamiRank", entry.get("rank", "D")))
	]
	if show_frame:
		parts.append(String(entry.get("streamFrameName", "配信枠")))
	parts.append("x%.1f" % float(entry.get("maxVoltage", entry.get("maxMultiplier", 1.0))))
	parts.append(_format_time(float(entry.get("survivalTime", entry.get("time", 0)))))
	parts.append(_format_build_short(entry))
	return "  ".join(parts)


static func _format_relay_entry_row(entry: Dictionary, index: int, selected: bool) -> String:
	var marker: String = ">" if selected else " "
	var lines: Array[String] = [
		"%s%2d. [%s] %s" % [marker, index + 1, _character_nickname(entry), _relay_progress_text(entry)]
	]
	if not bool(entry.get("isRelayCompleted", false)):
		lines.append("     到達：%s" % String(entry.get("currentFrameName", "配信枠")))
	lines.append("     最大%s人 / 合計%s人 / 最大ボルテージ x%.1f" % [
		_format_number(int(entry.get("maxViewerCount", 0))),
		_format_number(int(entry.get("totalViewerCount", 0))),
		float(entry.get("maxVoltage", 1.0))
	])
	lines.append("     武器：%s" % _equipment_summary(_safe_array(entry.get("weapons", [])), "なし"))
	lines.append("     アクセ：%s" % _equipment_summary(_safe_array(entry.get("accessories", [])), "なし"))
	return "\n".join(lines)


static func _normal_row_view(entry: Dictionary, index: int, selected: bool, _show_frame: bool) -> Dictionary:
	var viewer_count: int = _viewer_count(entry)
	var meta_parts: Array[String] = [
		"神回度 %s" % String(entry.get("kamiRank", entry.get("rank", "D"))),
		"x%.1f" % float(entry.get("maxVoltage", entry.get("maxMultiplier", 1.0))),
		_format_time(float(entry.get("survivalTime", entry.get("time", 0))))
	]
	meta_parts.insert(1, String(entry.get("streamFrameName", "配信枠")))
	return {
		"rank": index + 1,
		"selected": selected,
		"characterId": _character_id(entry),
		"character": _character_nickname(entry),
		"title": _character_nickname(entry),
		"scoreText": "%s人" % _format_number(viewer_count),
		"summary": " / ".join(meta_parts),
		"build": _format_build_short(entry),
		"weapons": _slice_items(_safe_array(entry.get("weapons", [])), 5),
		"accessories": _slice_items(_safe_array(entry.get("accessories", [])), 5),
		"endType": _entry_end_type(entry),
		"endTypeLabel": _end_type_label(entry),
		"accent": _rank_accent(index)
	}


static func _relay_row_view(entry: Dictionary, index: int, selected: bool) -> Dictionary:
	var summary: String = _relay_progress_text(entry)
	if not bool(entry.get("isRelayCompleted", false)):
		summary += " / 到達 %s" % String(entry.get("currentFrameName", "配信枠"))
	return {
		"rank": index + 1,
		"selected": selected,
		"characterId": _character_id(entry),
		"character": _character_nickname(entry),
		"title": _character_nickname(entry),
		"scoreText": "最大%s人" % _format_number(int(entry.get("maxViewerCount", 0))),
		"summary": "%s / 合計%s人 / x%.1f" % [
			summary,
			_format_number(int(entry.get("totalViewerCount", 0))),
			float(entry.get("maxVoltage", 1.0))
		],
		"build": "武器 %s / アクセ %s" % [
			_equipment_summary(_safe_array(entry.get("weapons", [])), "なし"),
			_equipment_summary(_safe_array(entry.get("accessories", [])), "なし")
		],
		"weapons": _slice_items(_safe_array(entry.get("weapons", [])), 5),
		"accessories": _slice_items(_safe_array(entry.get("accessories", [])), 5),
		"endType": _entry_end_type(entry),
		"endTypeLabel": _end_type_label(entry),
		"accent": _rank_accent(index)
	}


static func _normal_detail_view(entry: Dictionary, rank_index: int) -> Dictionary:
	var end_type: String = _entry_end_type(entry)
	return {
		"title": "記録詳細",
		"rankLabel": "%d位記録" % rank_index,
		"summaryLines": [
			"%s / %s" % [_character_nickname(entry), String(entry.get("streamFrameName", "配信枠"))],
			"最大同時視聴者数：%s人" % _format_number(_viewer_count(entry)),
			"神回度：%s / 終了：%s" % [String(entry.get("kamiRank", entry.get("rank", "D"))), _end_type_label(entry)]
		],
		"stats": [
			{"label": "最大同時視聴者数", "value": "%s人" % _format_number(_viewer_count(entry))},
			{"label": "神回度", "value": "%s  %dpt" % [String(entry.get("kamiRank", entry.get("rank", "D"))), _god_point(entry)]},
			{"label": "生存時間", "value": _format_time(float(entry.get("survivalTime", entry.get("time", 0))))},
			{"label": "最大ボルテージ", "value": "x%.1f" % float(entry.get("maxVoltage", entry.get("maxMultiplier", 1.0)))},
			{"label": "最大バズ度", "value": "%d%%" % int(entry.get("maxBurnCombo", 0))},
			{"label": "ギフト数", "value": "%d" % int(entry.get("giftCount", 0))}
		],
		"weapons": _safe_array(entry.get("weapons", [])),
		"accessories": _safe_array(entry.get("accessories", [])),
		"instructionTitle": _instruction_title(end_type),
		"instructionLines": _instruction_lines(entry, end_type),
		"bossText": _boss_detail_text(entry) if _boss_detail_text(entry) != "" else "なし",
		"playedAtText": _format_played_at(String(entry.get("playedAt", ""))),
		"endTypeLabel": _end_type_label(entry)
	}


static func _relay_detail_view(entry: Dictionary, rank_index: int) -> Dictionary:
	var end_type: String = _entry_end_type(entry)
	var completed_names: Array[String] = _string_array(entry.get("completedFrameNames", []))
	var completed_text: String = "なし" if completed_names.is_empty() else " / ".join(completed_names)
	return {
		"title": "配信リレー詳細",
		"rankLabel": "%d位記録" % rank_index,
		"summaryLines": [
			"%s / 配信リレー" % _character_nickname(entry),
			"最大同時視聴者数：%s人" % _format_number(int(entry.get("maxViewerCount", 0))),
			"突破：%s / 終了：%s" % [_relay_progress_text(entry), _end_type_label(entry)]
		],
		"stats": [
			{"label": "最大同時視聴者数", "value": "%s人" % _format_number(int(entry.get("maxViewerCount", 0)))},
			{"label": "合計視聴者数", "value": "%s人" % _format_number(int(entry.get("totalViewerCount", 0)))},
			{"label": "到達枠", "value": String(entry.get("currentFrameName", "配信枠"))},
			{"label": "突破枠", "value": completed_text},
			{"label": "最大ボルテージ", "value": "x%.1f" % float(entry.get("maxVoltage", 1.0))},
			{"label": "最大バズ度", "value": "%d%%" % int(entry.get("maxBurnCombo", 0))}
		],
		"weapons": _safe_array(entry.get("weapons", [])),
		"accessories": _safe_array(entry.get("accessories", [])),
		"instructionTitle": _instruction_title(end_type),
		"instructionLines": _instruction_lines(entry, end_type),
		"bossText": _boss_detail_text(entry) if _boss_detail_text(entry) != "" else "なし",
		"playedAtText": _format_played_at(String(entry.get("playedAt", ""))),
		"endTypeLabel": _end_type_label(entry)
	}


static func _format_detail(entry: Dictionary, rank_index: int) -> String:
	var lines: Array[String] = [
		"詳細：%d位" % rank_index,
		"配信者：%s" % _character_nickname(entry),
		"配信枠：%s" % String(entry.get("streamFrameName", "配信枠")),
		"最大同時視聴者数：%s人" % _format_number(int(entry.get("viewerCount", entry.get("score", 0)))),
		"神回度：%s" % String(entry.get("kamiRank", entry.get("rank", "D"))),
		"生存時間：%s" % _format_time(float(entry.get("survivalTime", entry.get("time", 0)))),
		"最大ボルテージ：x%.1f" % float(entry.get("maxVoltage", entry.get("maxMultiplier", 1.0))),
		"最大バズ度：%d%%" % int(entry.get("maxBurnCombo", 0)),
		"武器：%s" % _equipment_summary(_safe_array(entry.get("weapons", [])), String(entry.get("weaponEquipmentText", "なし"))),
		"アクセサリ：%s" % _equipment_summary(_safe_array(entry.get("accessories", [])), String(entry.get("accessoryEquipmentText", "なし"))),
		"戦犯指示コメ：%s" % _safe_text(entry.get("culpritInstructionComment", null), "なし"),
		"死因：%s" % _safe_text(entry.get("deathText", null), ""),
		"日時：%s" % String(entry.get("playedAt", ""))
	]
	var boss_text: String = _boss_detail_text(entry)
	if boss_text != "":
		lines.insert(lines.size() - 1, "ボス：%s" % boss_text)
	return "\n".join(lines)


static func _normal_detail_cards(entry: Dictionary) -> Array:
	var cards: Array = [
		{
			"title": "配信者",
			"lines": [
				_character_nickname(entry),
				String(entry.get("streamFrameName", "配信枠"))
			]
		},
		{
			"title": "統計情報",
			"lines": [
				"最大同時視聴者数 %s人" % _format_number(int(entry.get("viewerCount", entry.get("score", 0)))),
				"神回度 %s" % String(entry.get("kamiRank", entry.get("rank", "D"))),
				"生存時間 %s" % _format_time(float(entry.get("survivalTime", entry.get("time", 0)))),
				"最大ボルテージ x%.1f" % float(entry.get("maxVoltage", entry.get("maxMultiplier", 1.0))),
				"最大バズ度 %d%%" % int(entry.get("maxBurnCombo", 0))
			]
		},
		{
			"title": "ビルド構成",
			"lines": [
				"武器：%s" % _equipment_summary(_safe_array(entry.get("weapons", [])), String(entry.get("weaponEquipmentText", "なし"))),
				"アクセ：%s" % _equipment_summary(_safe_array(entry.get("accessories", [])), String(entry.get("accessoryEquipmentText", "なし")))
			]
		},
		{
			"title": "戦犯指示コメ",
			"lines": [
				_safe_text(entry.get("culpritInstructionComment", null), "なし"),
				"死因：%s" % _safe_text(entry.get("deathText", null), "")
			]
		},
		{
			"title": "記録日時",
			"lines": [String(entry.get("playedAt", ""))]
		}
	]
	var boss_text: String = _boss_detail_text(entry)
	if boss_text != "":
		cards.insert(3, {
			"title": "ボス結果",
			"lines": [boss_text]
		})
	return cards


static func _format_relay_detail(entry: Dictionary, rank_index: int) -> String:
	var completed_names: Array[String] = _string_array(entry.get("completedFrameNames", []))
	var completed_text: String = "なし" if completed_names.is_empty() else "\n".join(completed_names)
	var ended_reason: String = _relay_ended_reason_text(String(entry.get("endedReason", "")))
	var culprit := _safe_text(entry.get("culpritInstructionComment", null), "なし")
	var lines: Array[String] = [
		"配信リレー詳細：%d位" % rank_index,
		"配信者：%s" % _character_nickname(entry),
		"モード：配信リレー",
		"突破数：%s" % _relay_progress_text(entry),
		"到達配信枠：%s" % String(entry.get("currentFrameName", "配信枠")),
		"突破した配信枠：\n%s" % completed_text,
		"最大同時視聴者数：%s人" % _format_number(int(entry.get("maxViewerCount", 0))),
		"合計同時視聴者数：%s人" % _format_number(int(entry.get("totalViewerCount", 0))),
		"最大ボルテージ：x%.1f" % float(entry.get("maxVoltage", 1.0)),
		"最大バズ度：%d%%" % int(entry.get("maxBurnCombo", 0)),
		"最終武器ビルド：\n%s" % _equipment_detail(_safe_array(entry.get("weapons", []))),
		"最終アクセサリビルド：\n%s" % _equipment_detail(_safe_array(entry.get("accessories", []))),
		"終了理由：%s" % ended_reason,
		"戦犯指示コメ：%s" % culprit,
		"死因：%s" % _safe_text(entry.get("deathText", null), ""),
		"日時：%s" % String(entry.get("playedAt", ""))
	]
	var boss_text: String = _boss_detail_text(entry)
	if boss_text != "":
		lines.insert(lines.size() - 1, "ボス：%s" % boss_text)
	return "\n".join(lines)


static func _relay_detail_cards(entry: Dictionary) -> Array:
	var completed_names: Array[String] = _string_array(entry.get("completedFrameNames", []))
	var completed_text: String = "なし" if completed_names.is_empty() else " / ".join(completed_names)
	var culprit := _safe_text(entry.get("culpritInstructionComment", null), "なし")
	var cards: Array = [
		{
			"title": "配信者",
			"lines": [
				_character_nickname(entry),
				"配信リレー"
			]
		},
		{
			"title": "突破状況",
			"lines": [
				_relay_progress_text(entry),
				"到達：%s" % String(entry.get("currentFrameName", "配信枠")),
				"突破：%s" % completed_text,
				"終了理由：%s" % _relay_ended_reason_text(String(entry.get("endedReason", "")))
			]
		},
		{
			"title": "統計情報",
			"lines": [
				"最大同時視聴者数 %s人" % _format_number(int(entry.get("maxViewerCount", 0))),
				"合計同時視聴者数 %s人" % _format_number(int(entry.get("totalViewerCount", 0))),
				"最大ボルテージ x%.1f" % float(entry.get("maxVoltage", 1.0)),
				"最大バズ度 %d%%" % int(entry.get("maxBurnCombo", 0))
			]
		},
		{
			"title": "最終ビルド",
			"lines": [
				"武器：%s" % _equipment_summary(_safe_array(entry.get("weapons", [])), "なし"),
				"アクセ：%s" % _equipment_summary(_safe_array(entry.get("accessories", [])), "なし")
			]
		},
		{
			"title": "戦犯指示コメ",
			"lines": [
				culprit,
				"死因：%s" % String(entry.get("deathText", ""))
			]
		},
		{
			"title": "記録日時",
			"lines": [String(entry.get("playedAt", ""))]
		}
	]
	var boss_text: String = _boss_detail_text(entry)
	if boss_text != "":
		cards.insert(4, {
			"title": "ボス結果",
			"lines": [boss_text]
		})
	return cards


static func _format_build_short(entry: Dictionary) -> String:
	var weapon_text: String = _equipment_summary(_safe_array(entry.get("weapons", [])), String(entry.get("weaponEquipmentText", "なし")))
	var accessory_text: String = _equipment_summary(_safe_array(entry.get("accessories", [])), String(entry.get("accessoryEquipmentText", "なし")))
	if accessory_text == "なし":
		return "武器 %s" % weapon_text
	return "武器 %s / アクセ %s" % [weapon_text, accessory_text]


static func _boss_detail_text(entry: Dictionary) -> String:
	if not bool(entry.get("bossSummoned", false)):
		return ""
	var boss_name: String = String(entry.get("bossName", "ボス"))
	var status: String = "撃破" if bool(entry.get("bossDefeated", false)) else ("撤退" if String(entry.get("bossResult", "")) == "retreated" else "出現")
	var reward: int = int(entry.get("bossRewardViewer", 0))
	if reward > 0:
		return "%s：%s / +%s人" % [boss_name, status, _format_number(reward)]
	return "%s：%s" % [boss_name, status]


static func _equipment_summary(items: Array, fallback: String) -> String:
	var names: Array[String] = []
	for item in items:
		if not (item is Dictionary):
			continue
		var data: Dictionary = item as Dictionary
		var name: String = String(data.get("displayName", data.get("id", "")))
		if name != "":
			names.append("%s %s" % [name, _equipment_level_label(data)])
	if not names.is_empty():
		return "、".join(names)
	if fallback.strip_edges() != "":
		return fallback
	return "なし"


static func _equipment_detail(items: Array) -> String:
	var lines: Array[String] = []
	for item in items:
		if not (item is Dictionary):
			continue
		var data: Dictionary = item as Dictionary
		var name: String = String(data.get("displayName", data.get("id", "")))
		if name != "":
			lines.append("%s %s" % [name, _equipment_level_label(data)])
	if lines.is_empty():
		return "なし"
	return "\n".join(lines)


static func _equipment_level_label(data: Dictionary) -> String:
	var label: String = String(data.get("levelLabel", ""))
	if label != "":
		return label
	if bool(data.get("isEvolved", false)):
		return "進化"
	return "Lv%d" % int(data.get("level", 1))


static func _character_nickname(entry: Dictionary) -> String:
	var id: String = _character_id(entry)
	if id == "ban_chan" or id == "banri":
		return "ばんちゃん"
	if id == "superchat_chan" or id == "supana":
		return "すぱなちゃん"
	if id == "maro_chan" or id == "maron":
		return "まろんちゃん"
	var name: String = String(entry.get("characterName", ""))
	if name == "赤羽ばんり":
		return "ばんちゃん"
	if name == "星投すぱな":
		return "すぱなちゃん"
	if name == "白綿まろん":
		return "まろんちゃん"
	if name != "":
		return name
	return "配信者"


static func _character_id(entry: Dictionary) -> String:
	var id: String = String(entry.get("characterId", "")).strip_edges()
	if id == "banri":
		return "ban_chan"
	if id == "supana":
		return "superchat_chan"
	if id == "maron":
		return "maro_chan"
	if id != "":
		return id
	var name: String = String(entry.get("characterName", "")).strip_edges()
	if name == "赤羽ばんり" or name == "ばんちゃん":
		return "ban_chan"
	if name == "星投すぱな" or name == "すぱなちゃん":
		return "superchat_chan"
	if name == "白綿まろん" or name == "まろんちゃん":
		return "maro_chan"
	return ""


static func _rank_position(entries: Array, entry: Dictionary) -> int:
	var run_id: String = String(entry.get("runId", ""))
	for index in range(entries.size()):
		var current_item: Variant = entries[index]
		if not (current_item is Dictionary):
			continue
		var current: Dictionary = current_item as Dictionary
		if run_id != "" and String(current.get("runId", "")) == run_id:
			return index + 1
		if _entry_is_same(current, entry):
			return index + 1
	return entries.size()


static func _ranking_scope_entries(entries: Array, stream_frame_id: String, difficulty_id: String = "normal") -> Array:
	var frame_id := stream_frame_id.strip_edges()
	if frame_id == "":
		return entries
	var scoped_entries: Array = []
	for entry_item in entries:
		if not (entry_item is Dictionary):
			continue
		var entry: Dictionary = entry_item as Dictionary
		if _entry_difficulty_id(entry) != difficulty_id:
			continue
		if not ["normal_180", "relay"].has(String(entry.get("modeId", ""))):
			continue
		if String(entry.get("modeId", "")) != "relay" and String(entry.get("streamFrameId", "")) != frame_id:
			continue
		scoped_entries.append(entry)
	if scoped_entries.is_empty():
		return entries
	return _sort_entries(scoped_entries)


static func _entry_difficulty_id(entry: Dictionary) -> String:
	var id := String(entry.get("difficultyId", "normal")).strip_edges().to_lower()
	if id == "hard" or id == "expert":
		return id
	return "normal"


static func _ranking_scope_label(entry: Dictionary) -> String:
	var frame_name := String(entry.get("streamFrameName", "")).strip_edges()
	if frame_name == "":
		return "ランキング"
	return "%sランキング" % frame_name


static func _relay_rank_position(entries: Array, entry: Dictionary) -> int:
	var run_id: String = String(entry.get("runId", ""))
	for index in range(entries.size()):
		var current_item: Variant = entries[index]
		if not (current_item is Dictionary):
			continue
		var current: Dictionary = current_item as Dictionary
		if run_id != "" and String(current.get("runId", "")) == run_id:
			return index + 1
		if _relay_entry_is_same(current, entry):
			return index + 1
	return entries.size()


static func _entry_is_same(a: Dictionary, b: Dictionary) -> bool:
	return (
		_viewer_count(a) == _viewer_count(b)
		and String(a.get("playedAt", "")) == String(b.get("playedAt", ""))
		and String(a.get("characterId", "")) == String(b.get("characterId", ""))
	)


static func _relay_entry_is_same(a: Dictionary, b: Dictionary) -> bool:
	return (
		int(a.get("clearedFrameCount", 0)) == int(b.get("clearedFrameCount", 0))
		and int(a.get("maxViewerCount", 0)) == int(b.get("maxViewerCount", 0))
		and int(a.get("totalViewerCount", 0)) == int(b.get("totalViewerCount", 0))
		and String(a.get("playedAt", "")) == String(b.get("playedAt", ""))
		and String(a.get("characterId", "")) == String(b.get("characterId", ""))
	)


static func _entry_is_higher(a: Dictionary, b: Dictionary) -> bool:
	var score_a: int = _entry_score(a)
	var score_b: int = _entry_score(b)
	if score_a != score_b:
		return score_a > score_b
	var point_a: int = _god_point(a)
	var point_b: int = _god_point(b)
	if point_a != point_b:
		return point_a > point_b
	var a_rank: int = _rank_value(String(a.get("kamiRank", a.get("rank", "D"))))
	var b_rank: int = _rank_value(String(b.get("kamiRank", b.get("rank", "D"))))
	if a_rank != b_rank:
		return a_rank > b_rank
	var a_time: float = float(a.get("survivalTime", a.get("time", 0)))
	var b_time: float = float(b.get("survivalTime", b.get("time", 0)))
	if not is_equal_approx(a_time, b_time):
		return a_time > b_time
	var voltage_a: float = float(a.get("maxVoltage", a.get("maxMultiplier", 1.0)))
	var voltage_b: float = float(b.get("maxVoltage", b.get("maxMultiplier", 1.0)))
	if not is_equal_approx(voltage_a, voltage_b):
		return voltage_a > voltage_b
	return String(a.get("playedAt", "")) > String(b.get("playedAt", ""))


static func _relay_entry_is_higher(a: Dictionary, b: Dictionary) -> bool:
	var score_a: int = _entry_score(a)
	var score_b: int = _entry_score(b)
	if score_a != score_b:
		return score_a > score_b
	var cleared_a: int = int(a.get("clearedFrameCount", 0))
	var cleared_b: int = int(b.get("clearedFrameCount", 0))
	if cleared_a != cleared_b:
		return cleared_a > cleared_b
	var total_viewers_a: int = int(a.get("totalViewerCount", 0))
	var total_viewers_b: int = int(b.get("totalViewerCount", 0))
	if total_viewers_a != total_viewers_b:
		return total_viewers_a > total_viewers_b
	var voltage_a: float = float(a.get("maxVoltage", 1.0))
	var voltage_b: float = float(b.get("maxVoltage", 1.0))
	if not is_equal_approx(voltage_a, voltage_b):
		return voltage_a > voltage_b
	return String(a.get("playedAt", "")) > String(b.get("playedAt", ""))


static func _relay_progress_text(entry: Dictionary) -> String:
	var cleared_count: int = int(entry.get("clearedFrameCount", 0))
	if bool(entry.get("isRelayCompleted", false)):
		return "%d枠突破 / 完走" % cleared_count
	return "%d枠突破" % cleared_count


static func _relay_ended_reason_text(reason: String) -> String:
	if reason == "completed":
		return "完走"
	if reason == "interrupted":
		return "中断"
	if reason == "death":
		return "死亡"
	if reason != "":
		return reason
	return "死亡"


static func _rank_accent(index: int) -> Color:
	if index == 0:
		return Color("#f4b83f")
	if index == 1:
		return Color("#8fa2d4")
	if index == 2:
		return Color("#df8b3f")
	return Color("#8d6be8")


static func _rank_value(rank: String) -> int:
	return int(RANK_ORDER.get(rank, 0))


static func _viewer_count(entry: Dictionary) -> int:
	return int(entry.get("maxViewerCount", entry.get("viewerCount", entry.get("score", 0))))


static func _entry_score(entry: Dictionary) -> int:
	if entry.has("score"):
		return maxi(0, int(entry.get("score", 0)))
	if entry_stage(entry) == "relay":
		return maxi(0, int(entry.get("maxViewerCount", entry.get("totalViewerCount", 0))))
	return maxi(0, int(entry.get("viewerCount", 0)))


static func _god_point(entry: Dictionary) -> int:
	return int(entry.get("godPoint", entry.get("kamiPoint", 0)))


static func _slice_items(items: Array, max_count: int) -> Array:
	if items.size() <= max_count:
		return items
	return items.slice(0, max_count)


static func _entry_end_type(entry: Dictionary) -> String:
	var end_type: String = String(entry.get("endType", "")).strip_edges()
	if end_type != "":
		return end_type
	if bool(entry.get("isRelayCompleted", false)) or String(entry.get("endedReason", "")) == "completed":
		return "completed"
	if String(entry.get("endedReason", "")) == "interrupted":
		return "relay_failed"
	if String(entry.get("modeId", "")) == "relay":
		return "relay_failed"
	if String(entry.get("deathText", "")).strip_edges() != "":
		return "mental_breakdown"
	return "completed"


static func _end_type_label(entry: Dictionary) -> String:
	var end_type: String = _entry_end_type(entry)
	if end_type == "completed":
		return "完走"
	if end_type == "mental_breakdown":
		return "崩壊"
	if end_type == "relay_failed" or end_type == "quit" or end_type == "debug":
		return "中断"
	return "記録"


static func _instruction_title(end_type: String) -> String:
	if end_type == "completed":
		return "配信ハイライト"
	if end_type == "relay_failed":
		return "中断時の指示コメ"
	return "戦犯指示コメ"


static func _instruction_lines(entry: Dictionary, end_type: String) -> Array[String]:
	var comment := _safe_text(entry.get("culpritInstructionComment", null), "なし")
	var death := _safe_text(entry.get("deathText", entry.get("deathReason", null)), "")
	if end_type == "completed":
		if comment == "なし":
			comment = _safe_text(entry.get("lastInstructionComment", null), "最後まで走り切った！")
		return [comment, "最後まで配信を走り切った記録です。"]
	if end_type == "relay_failed":
		if death == "":
			death = _relay_ended_reason_text(String(entry.get("endedReason", "")))
		return [comment, "中断理由：%s" % death]
	if death == "":
		death = "通常被弾でメンタル崩壊"
	return [comment, "死因：%s" % death]


static func _format_played_at(text: String) -> String:
	var value: String = text.strip_edges()
	if value == "":
		return "不明"
	value = value.replace("T", " ").replace("-", "/")
	if value.length() >= 16:
		return value.substr(0, 16)
	return value


static func _format_time(seconds: float) -> String:
	var total_seconds: int = int(seconds)
	var minutes: int = int(total_seconds / 60)
	var secs: int = total_seconds % 60
	return "%02d:%02d" % [minutes, secs]


static func _format_number(value: int) -> String:
	var text: String = str(value)
	var result: String = ""
	var count: int = 0
	for i in range(text.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = text.substr(i, 1) + result
		count += 1
	return result


static func _dict(value: Variant) -> Dictionary:
	return value as Dictionary if value is Dictionary else {}


static func _safe_array(value: Variant) -> Array:
	if value is Array:
		return value as Array
	return []


static func _string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if not (value is Array):
		return result
	for item in (value as Array):
		result.append(String(item))
	return result
