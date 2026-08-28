extends Node

## Persistent discovery state for the in-game stream codex.
##
## The manager owns only master data and saved discovery state.  Rendering and
## screen navigation live in scripts/ui/codex_screen.gd.

const CodexAuditSystemScript := preload("res://scripts/systems/codex_audit_system.gd")
const EnemyCodexProfileSystemScript := preload("res://scripts/systems/enemy_codex_profile_system.gd")
const CommentSystemScript := preload("res://scripts/systems/comment_system.gd")

signal codex_changed(category: String, id: String)
signal codex_bulk_changed(category: String)
signal completion_achieved(scope: String, category: String)

const CATEGORY_CHARACTER: String = "characters"
const CATEGORY_WEAPON: String = "weapons"
const CATEGORY_ACCESSORY: String = "accessories"
const CATEGORY_ENEMY: String = "enemies"
const CATEGORY_COMMENT: String = "comments"
const CATEGORIES: Array[String] = [
	CATEGORY_CHARACTER,
	CATEGORY_WEAPON,
	CATEGORY_ACCESSORY,
	CATEGORY_ENEMY,
	CATEGORY_COMMENT
]
const COLLECTION_CATEGORIES: Array[String] = [
	CATEGORY_CHARACTER,
	CATEGORY_WEAPON,
	CATEGORY_ACCESSORY,
	CATEGORY_ENEMY
]
const SCHEMA_VERSION: int = 4

const CODEX_ENEMY_MASTER_PATH := "res://data/codex_enemies.json"
const CHARACTER_MASTER_PATH := "res://data/characters.json"
const WEAPON_MASTER_PATH := "res://data/weapons.json"
const GIFT_MASTER_PATH := "res://data/gifts.json"
const COMMENT_MASTER_PATH := "res://data/comments.json"
const DEFAULT_CHARACTER_IDS: Array[String] = ["ban_chan", "superchat_chan", "maro_chan"]
const BOSS_DIFFICULTIES: Array[String] = ["normal", "hard", "expert"]
const RECORD_DIFFICULTIES: Array[String] = ["normal", "hard", "expert"]
const RECORD_STAGES: Array[String] = ["zatsudan", "gameplay", "singing", "drawing", "collab"]
const STAGE_ALIASES: Dictionary = {
	"talk": "zatsudan",
	"chat": "zatsudan",
	"zatsudan": "zatsudan",
	"game": "gameplay",
	"gameplay": "gameplay",
	"song": "singing",
	"singing": "singing",
	"drawing": "drawing",
	"collab": "collab"
}

var _masters: Dictionary = {}
var _master_by_id: Dictionary = {}
var _disabled_ids: Dictionary = {}
var _raw_masters: Dictionary = {}
var _entries: Dictionary = {}
var _orphan_entries: Dictionary = {}
var _warning_keys: Dictionary = {}
var _initialized := false
var _legacy_import_pending := false
var _active_run_id := ""
var _active_run_play_recorded := false
var _active_run_result_recorded := false
var _last_finished_run_id := ""
var _last_finished_snapshot: Dictionary = {}
var _session_discoveries: Dictionary = {}
var _collection_completed_once := false
var _category_completed_once: Dictionary = {}

func _ready() -> void:
	initialize_empty()

func initialize_empty() -> void:
	_load_masters()
	_entries.clear()
	_orphan_entries.clear()
	_collection_completed_once = false
	_category_completed_once.clear()
	for category in CATEGORIES:
		_category_completed_once[category] = false
	_reset_session_state()
	for category in CATEGORIES:
		_entries[category] = {}
		_orphan_entries[category] = {}
	for character_id in DEFAULT_CHARACTER_IDS:
		if _has_enabled_master(CATEGORY_CHARACTER, character_id):
			_entries[CATEGORY_CHARACTER][character_id] = _new_character_entry(false)
	_initialized = true
	_legacy_import_pending = false

func begin_run(run_id: String) -> void:
	_ensure_initialized()
	_active_run_id = run_id.strip_edges()
	_active_run_play_recorded = false
	_active_run_result_recorded = false
	_last_finished_run_id = ""
	_last_finished_snapshot = {}
	_reset_session_discoveries()

func has_active_run() -> bool:
	_ensure_initialized()
	return _active_run_id != ""

func active_run_id() -> String:
	_ensure_initialized()
	return _active_run_id

func abandon_run(run_id: String = "") -> void:
	_ensure_initialized()
	if run_id.strip_edges() != "" and run_id.strip_edges() != _active_run_id:
		return
	_active_run_id = ""
	_active_run_play_recorded = false
	_active_run_result_recorded = false
	_reset_session_discoveries()

func finish_run(run_id: String = "") -> Dictionary:
	_ensure_initialized()
	var requested_id := run_id.strip_edges()
	if requested_id != "" and requested_id == _last_finished_run_id:
		return _last_finished_snapshot.duplicate(true)
	if requested_id != "" and requested_id != _active_run_id:
		return {}
	var effective_id := _active_run_id if requested_id == "" else requested_id
	if effective_id == "":
		return {}
	var snapshot := _session_discoveries.duplicate(true)
	_last_finished_run_id = effective_id
	_last_finished_snapshot = snapshot.duplicate(true)
	_active_run_id = ""
	_active_run_play_recorded = false
	_active_run_result_recorded = true
	_reset_session_discoveries()
	return snapshot.duplicate(true)

func get_session_discoveries() -> Dictionary:
	_ensure_initialized()
	return _session_discoveries.duplicate(true)

func has_session_discoveries() -> bool:
	_ensure_initialized()
	for category in CATEGORIES:
		if not (_session_discoveries.get(category, []) as Array).is_empty():
			return true
	return false

func record_character_play(character_id: String, run_id: String = "") -> bool:
	_ensure_initialized()
	var id := _normalize_id(CATEGORY_CHARACTER, character_id)
	if not _is_known_enabled_id(CATEGORY_CHARACTER, id):
		_warn_once("play:%s" % id, "Codex unknown character play: %s" % id)
		return false
	if _active_run_id == "" or (run_id.strip_edges() != "" and run_id.strip_edges() != _active_run_id):
		return false
	if _active_run_play_recorded:
		return false
	var entry := _ensure_character_entry(id, false)
	entry["play_count"] = maxi(0, int(entry.get("play_count", 0))) + 1
	_entries[CATEGORY_CHARACTER][id] = entry
	_active_run_play_recorded = true
	codex_changed.emit(CATEGORY_CHARACTER, id)
	return true

func record_character_result(result: Dictionary) -> bool:
	_ensure_initialized()
	var run_id := String(result.get("runId", result.get("run_id", ""))).strip_edges()
	if run_id == "" or run_id == _last_finished_run_id:
		return false
	if _active_run_id == "":
		begin_run(run_id)
	if run_id != _active_run_id or _active_run_result_recorded:
		return false
	var id := _normalize_id(CATEGORY_CHARACTER, String(result.get("characterId", result.get("character_id", ""))))
	if not _is_known_enabled_id(CATEGORY_CHARACTER, id):
		_warn_once("result:%s" % id, "Codex unknown character result: %s" % id)
		return false
	var entry := _ensure_character_entry(id, false)
	var difficulty_id := _normalize_record_difficulty(result.get("difficultyId", result.get("difficulty", "normal")))
	var cleared := bool(result.get("cleared", false))
	var score := maxi(0, int(result.get("score", 0)))
	var relay_mode := bool(result.get("relayMode", false)) or String(result.get("stageId", "")) == "relay"
	var relay_section := clampi(int(result.get("relayClearedFrameCount", result.get("reachedSectionIndex", 0))), 0, 5)
	var stage_id := _normalize_record_stage(result.get("stageId", result.get("streamFrameId", "")))
	if relay_mode:
		var relay_records := _normalize_relay_records(entry.get("relay_records", {}))
		var relay_record := relay_records[difficulty_id] as Dictionary
		relay_record["best_section"] = maxi(int(relay_record.get("best_section", 0)), relay_section)
		if cleared:
			relay_record["cleared"] = true
			entry["clear_count"] = maxi(0, int(entry.get("clear_count", 0))) + 1
			entry["best_score"] = maxi(int(entry.get("best_score", 0)), score)
		relay_records[difficulty_id] = relay_record
		entry["relay_records"] = relay_records
	else:
		if cleared:
			entry["clear_count"] = maxi(0, int(entry.get("clear_count", 0))) + 1
			entry["best_score"] = maxi(int(entry.get("best_score", 0)), score)
			if RECORD_STAGES.has(stage_id):
				var stage_clears := _normalize_stage_clears(entry.get("stage_clears", {}))
				var stage_flags := stage_clears[stage_id] as Dictionary
				stage_flags[difficulty_id] = true
				stage_clears[stage_id] = stage_flags
				entry["stage_clears"] = stage_clears
	_entries[CATEGORY_CHARACTER][id] = entry
	_active_run_result_recorded = true
	codex_changed.emit(CATEGORY_CHARACTER, id)
	return true

func record_comment_appearance(comment_id: String) -> bool:
	_ensure_initialized()
	var id := _normalize_id(CATEGORY_COMMENT, comment_id)
	if not _is_known_enabled_id(CATEGORY_COMMENT, id):
		_warn_once("appearance:%s" % id, "Codex unknown comment appearance: %s" % id)
		return false
	discover_comment(id)
	var entry := _ensure_comment_entry(id)
	entry["appeared_count"] = maxi(0, int(entry.get("appeared_count", 0))) + 1
	_entries[CATEGORY_COMMENT][id] = entry
	codex_changed.emit(CATEGORY_COMMENT, id)
	return true

func record_comment_selection(comment_id: String, heart_used: bool = false) -> bool:
	_ensure_initialized()
	var id := _normalize_id(CATEGORY_COMMENT, comment_id)
	if not _is_known_enabled_id(CATEGORY_COMMENT, id):
		_warn_once("selection:%s" % id, "Codex unknown comment selection: %s" % id)
		return false
	discover_comment(id)
	var entry := _ensure_comment_entry(id)
	entry["selected_count"] = maxi(0, int(entry.get("selected_count", 0))) + 1
	if heart_used:
		entry["heart_count"] = maxi(0, int(entry.get("heart_count", 0))) + 1
	_entries[CATEGORY_COMMENT][id] = entry
	codex_changed.emit(CATEGORY_COMMENT, id)
	return true

func sync_legacy_character_records(progress: Dictionary) -> bool:
	_ensure_initialized()
	var changed := false
	var difficulties: Variant = progress.get("difficulties", {})
	if not difficulties is Dictionary:
		return false
	for difficulty_id in RECORD_DIFFICULTIES:
		var difficulty_data: Variant = (difficulties as Dictionary).get(difficulty_id, {})
		if not difficulty_data is Dictionary:
			continue
		var stages: Variant = (difficulty_data as Dictionary).get("stages", {})
		if stages is Dictionary:
			for raw_stage in (stages as Dictionary).keys():
				var stage_id := _normalize_record_stage(raw_stage)
				if not RECORD_STAGES.has(stage_id):
					continue
				var stage_data: Variant = (stages as Dictionary)[raw_stage]
				if not stage_data is Dictionary:
					continue
				for raw_character in (stage_data as Dictionary).get("clearCharacterIds", []):
					changed = _sync_legacy_stage_clear(String(raw_character), stage_id, difficulty_id) or changed
		var relay_data: Variant = (difficulty_data as Dictionary).get("relay", {})
		if relay_data is Dictionary:
			for raw_character in (relay_data as Dictionary).get("clearCharacterIds", []):
				changed = _sync_legacy_relay_clear(String(raw_character), difficulty_id) or changed
	_sync_completion_state(false)
	return changed

func set_legacy_import_pending(value: bool) -> void:
	_legacy_import_pending = value

func is_legacy_import_pending() -> bool:
	return _legacy_import_pending

func clear_legacy_import_pending() -> void:
	_legacy_import_pending = false

func discover(category: String, id: String) -> bool:
	_ensure_initialized()
	var normalized_category := category.strip_edges().to_lower()
	if not CATEGORIES.has(normalized_category):
		_warn_once("category:%s" % normalized_category, "Codex unknown category: %s" % normalized_category)
		return false
	var normalized_id := _normalize_id(normalized_category, id)
	if normalized_id == "":
		_warn_once("empty:%s" % normalized_category, "Codex empty id for category: %s" % normalized_category)
		return false
	if _disabled_ids.get(normalized_category, {}).has(normalized_id):
		if normalized_category == CATEGORY_ENEMY:
			_warn_once("disabled_enemy:%s" % normalized_id, "Codex disabled enemy spawned: %s" % normalized_id)
		else:
			_warn_once("disabled:%s:%s" % [normalized_category, normalized_id], "Codex disabled entry: %s/%s" % [normalized_category, normalized_id])
		return false
	if not _has_enabled_master(normalized_category, normalized_id):
		_warn_once("unknown:%s:%s" % [normalized_category, normalized_id], "Codex unknown id: %s/%s" % [normalized_category, normalized_id])
		return false
	var category_entries: Dictionary = _entries[normalized_category] as Dictionary
	if category_entries.has(normalized_id):
		return false
	var entry: Dictionary = _new_entry_for_category(normalized_category, normalized_id, true)
	category_entries[normalized_id] = entry
	_entries[normalized_category] = category_entries
	_record_session_discovery(normalized_category, normalized_id)
	_sync_completion_state(true)
	codex_changed.emit(normalized_category, normalized_id)
	return true

func discover_character(id: String) -> bool:
	return discover(CATEGORY_CHARACTER, id)

func discover_weapon(id: String) -> bool:
	return discover(CATEGORY_WEAPON, id)

func discover_accessory(id: String) -> bool:
	return discover(CATEGORY_ACCESSORY, id)

func discover_enemy(id: String) -> bool:
	return discover(CATEGORY_ENEMY, id)

func discover_comment(id: String) -> bool:
	return discover(CATEGORY_COMMENT, id)

func sync_legacy_unlocked_characters(unlocked_ids: Array) -> int:
	_ensure_initialized()
	var changed_count := 0
	for raw_id in unlocked_ids:
		var id := String(raw_id).strip_edges()
		if id == "" or not _has_enabled_master(CATEGORY_CHARACTER, id):
			continue
		var category_entries: Dictionary = _entries[CATEGORY_CHARACTER] as Dictionary
		if category_entries.has(id):
			continue
		category_entries[id] = _new_character_entry(false)
		_entries[CATEGORY_CHARACTER] = category_entries
		codex_changed.emit(CATEGORY_CHARACTER, id)
		changed_count += 1
	_sync_completion_state(false)
	return changed_count

func mark_read(category: String, id: String) -> bool:
	_ensure_initialized()
	var normalized_category := category.strip_edges().to_lower()
	var normalized_id := _normalize_id(normalized_category, id)
	if not _is_known_enabled_id(normalized_category, normalized_id):
		return false
	var category_entries: Dictionary = _entries[normalized_category] as Dictionary
	if not category_entries.has(normalized_id):
		return false
	var entry: Dictionary = category_entries[normalized_id] as Dictionary
	if not bool(entry.get("new", false)):
		return false
	entry["new"] = false
	category_entries[normalized_id] = entry
	_entries[normalized_category] = category_entries
	codex_changed.emit(normalized_category, normalized_id)
	return true

func is_discovered(category: String, id: String) -> bool:
	_ensure_initialized()
	var normalized_category := category.strip_edges().to_lower()
	var normalized_id := _normalize_id(normalized_category, id)
	return _is_known_enabled_id(normalized_category, normalized_id) and (_entries[normalized_category] as Dictionary).has(normalized_id)

func is_new(category: String, id: String) -> bool:
	_ensure_initialized()
	var normalized_category := category.strip_edges().to_lower()
	var normalized_id := _normalize_id(normalized_category, id)
	if not _is_known_enabled_id(normalized_category, normalized_id):
		return false
	var entry: Dictionary = (_entries[normalized_category] as Dictionary).get(normalized_id, {}) as Dictionary
	return bool(entry.get("new", false))

func add_enemy_kill(enemy_id: String) -> bool:
	_ensure_initialized()
	var id := _normalize_id(CATEGORY_ENEMY, enemy_id)
	if not _is_known_enabled_id(CATEGORY_ENEMY, id):
		# Discover performs the stable warning and keeps invalid runtime IDs out
		# of the saved counters.
		discover_enemy(id)
		return false
	if not is_discovered(CATEGORY_ENEMY, id) and not discover_enemy(id):
		return false
	var category_entries: Dictionary = _entries[CATEGORY_ENEMY] as Dictionary
	var entry: Dictionary = category_entries[id] as Dictionary
	entry["kill_count"] = maxi(0, int(entry.get("kill_count", 0))) + 1
	category_entries[id] = entry
	_entries[CATEGORY_ENEMY] = category_entries
	codex_changed.emit(CATEGORY_ENEMY, id)
	return true

func record_boss_defeat(boss_id: String, difficulty: String) -> bool:
	_ensure_initialized()
	var id := _normalize_id(CATEGORY_ENEMY, boss_id)
	var difficulty_id := _normalize_boss_difficulty(difficulty)
	if difficulty_id == "":
		_warn_once("difficulty:%s" % String(difficulty), "Codex invalid boss difficulty: %s" % String(difficulty))
		return false
	if not _is_boss_master(id):
		_warn_once("not_boss:%s" % id, "Codex non-boss defeat recorded as boss: %s" % id)
		return false
	if not is_discovered(CATEGORY_ENEMY, id) and not discover_enemy(id):
		return false
	var category_entries: Dictionary = _entries[CATEGORY_ENEMY] as Dictionary
	var entry: Dictionary = category_entries[id] as Dictionary
	entry["kill_count"] = maxi(0, int(entry.get("kill_count", 0))) + 1
	var defeated: Dictionary = _normalize_defeated(entry.get("defeated", {}))
	defeated[difficulty_id] = true
	entry["defeated"] = defeated
	category_entries[id] = entry
	_entries[CATEGORY_ENEMY] = category_entries
	codex_changed.emit(CATEGORY_ENEMY, id)
	return true

func record_enemy_defeat(enemy_id: String, difficulty: String = "normal") -> bool:
	var id := _normalize_id(CATEGORY_ENEMY, enemy_id)
	if _is_boss_master(id):
		return record_boss_defeat(id, difficulty)
	return add_enemy_kill(id)

func get_entry(category: String, id: String) -> Dictionary:
	_ensure_initialized()
	var normalized_category := category.strip_edges().to_lower()
	var normalized_id := _normalize_id(normalized_category, id)
	if not _is_known_enabled_id(normalized_category, normalized_id):
		return {}
	var entry: Dictionary = (_entries[normalized_category] as Dictionary).get(normalized_id, {}) as Dictionary
	return entry.duplicate(true)

func get_save_data() -> Dictionary:
	_ensure_initialized()
	var result: Dictionary = {
		"schemaVersion": SCHEMA_VERSION,
		"collection_completed_once": _collection_completed_once,
		"category_completed_once": _category_completed_once.duplicate(true)
	}
	for category in CATEGORIES:
		var category_entries: Dictionary = (_entries[category] as Dictionary).duplicate(true)
		for orphan_id in (_orphan_entries.get(category, {}) as Dictionary).keys():
			if not category_entries.has(orphan_id):
				category_entries[orphan_id] = ((_orphan_entries[category] as Dictionary)[orphan_id] as Dictionary).duplicate(true)
		result[category] = category_entries
	return result

func load_save_data(data: Variant) -> void:
	_ensure_initialized()
	_entries.clear()
	_orphan_entries.clear()
	_collection_completed_once = false
	_category_completed_once.clear()
	for category in CATEGORIES:
		_entries[category] = {}
		_orphan_entries[category] = {}
		_category_completed_once[category] = false
	for character_id in DEFAULT_CHARACTER_IDS:
		if _has_enabled_master(CATEGORY_CHARACTER, character_id):
			_entries[CATEGORY_CHARACTER][character_id] = _new_character_entry(false)
	if not data is Dictionary:
		_legacy_import_pending = false
		_reset_session_state()
		return
	var source: Dictionary = data as Dictionary
	_collection_completed_once = _safe_bool(source.get("collection_completed_once", source.get("collectionCompletedOnce", false)), false)
	var category_once_value: Variant = source.get("category_completed_once", source.get("categoryCompletedOnce", {}))
	if category_once_value is Dictionary:
		for category in CATEGORIES:
			_category_completed_once[category] = _safe_bool((category_once_value as Dictionary).get(category, false), false)
	var nested_value: Variant = source.get("entries", {})
	var nested: Dictionary = nested_value as Dictionary if nested_value is Dictionary else {}
	for category in CATEGORIES:
		var raw_entries: Variant = source.get(category, nested.get(category, {}))
		if not raw_entries is Dictionary:
			continue
		for raw_id in (raw_entries as Dictionary).keys():
			var id := _normalize_id(category, String(raw_id))
			var raw_entry: Variant = (raw_entries as Dictionary)[raw_id]
			if not raw_entry is Dictionary:
				_warn_once("invalid_save_entry:%s:%s" % [category, id], "Codex invalid saved entry discarded: %s/%s" % [category, id])
				continue
			if not _is_known_enabled_id(category, id):
				(_orphan_entries[category] as Dictionary)[id] = (raw_entry as Dictionary).duplicate(true)
				continue
			var normalized := _normalize_saved_entry(category, id, raw_entry as Dictionary)
			if normalized.is_empty():
				continue
			_entries[category][id] = normalized
	for character_id in DEFAULT_CHARACTER_IDS:
		if _entries[CATEGORY_CHARACTER].has(character_id):
			var default_entry := _ensure_character_entry(character_id, false)
			default_entry["new"] = false
			_entries[CATEGORY_CHARACTER][character_id] = default_entry
	_legacy_import_pending = false
	_reset_session_state()
	# v0.4 only had an aggregate collection flag.  Its truth implies that
	# every collection category had previously been complete, so migrate those
	# four histories silently.  COMMENT can only be inferred when it is complete
	# in the current master.
	if _collection_completed_once:
		for category in COLLECTION_CATEGORIES:
			_category_completed_once[category] = true
	_sync_completion_state(false)

func get_collection_summary() -> Dictionary:
	_ensure_initialized()
	var categories: Dictionary = {}
	var found_total := 0
	var total_total := 0
	var all_complete := true
	for category in COLLECTION_CATEGORIES:
		var found := get_discovered_count(category)
		var total := get_total_count(category)
		var complete := total > 0 and found == total
		categories[category] = {
			"found": found,
			"total": total,
			"completed": complete,
			"completedOnce": bool(_category_completed_once.get(category, false))
		}
		found_total += found
		total_total += total
		all_complete = all_complete and complete
	var current_complete := total_total > 0 and all_complete
	var comment_found := get_discovered_count(CATEGORY_COMMENT)
	var comment_total := get_total_count(CATEGORY_COMMENT)
	categories[CATEGORY_COMMENT] = {
		"found": comment_found,
		"total": comment_total,
		"completed": comment_total > 0 and comment_found == comment_total,
		"completedOnce": bool(_category_completed_once.get(CATEGORY_COMMENT, false))
	}
	var rate_percent := floori(float(found_total) * 100.0 / float(total_total)) if total_total > 0 else 0
	return {
		"found": found_total,
		"total": total_total,
		"rate": float(found_total) / float(total_total) if total_total > 0 else 0.0,
		"ratePercent": rate_percent,
		"completed": current_complete,
		"completedOnce": _collection_completed_once,
		"categories": categories,
		"commentLog": {
			"found": comment_found,
			"total": comment_total,
			"completed": bool(categories[CATEGORY_COMMENT].get("completed", false))
		}
	}

func collection_completed_once() -> bool:
	_ensure_initialized()
	return _collection_completed_once

func category_completed_once(category: String) -> bool:
	_ensure_initialized()
	return bool(_category_completed_once.get(category.strip_edges().to_lower(), false))

func get_discovered_count(category: String) -> int:
	_ensure_initialized()
	var normalized_category := category.strip_edges().to_lower()
	if not CATEGORIES.has(normalized_category):
		return 0
	var total := 0
	for id in (_entries[normalized_category] as Dictionary).keys():
		if _has_enabled_master(normalized_category, String(id)):
			total += 1
	return total

func get_total_count(category: String) -> int:
	_ensure_initialized()
	var normalized_category := category.strip_edges().to_lower()
	return (_masters.get(normalized_category, []) as Array).size() if CATEGORIES.has(normalized_category) else 0

func get_new_count(category: String) -> int:
	_ensure_initialized()
	var normalized_category := category.strip_edges().to_lower()
	if not CATEGORIES.has(normalized_category):
		return 0
	var count := 0
	for id in (_entries[normalized_category] as Dictionary).keys():
		if _has_enabled_master(normalized_category, String(id)) and bool((_entries[normalized_category] as Dictionary)[id].get("new", false)):
			count += 1
	return count

func get_total_new_count() -> int:
	var summary := get_new_summary()
	return int(summary.get("total", 0))

func get_new_summary() -> Dictionary:
	_ensure_initialized()
	var categories: Dictionary = {}
	var total := 0
	for category in CATEGORIES:
		var ids: Array[String] = []
		var names: Array[String] = []
		var entries: Dictionary = _entries.get(category, {}) as Dictionary
		for master_value in _masters.get(category, []) as Array:
			if not master_value is Dictionary:
				continue
			var master := master_value as Dictionary
			var id := String(master.get("id", ""))
			if id == "" or not bool(entries.get(id, {}).get("new", false)):
				continue
			ids.append(id)
			names.append(_master_display_name(master, id))
		categories[category] = {
			"count": ids.size(),
			"ids": ids,
			"names": names
		}
		total += ids.size()
	return {"total": total, "categories": categories}.duplicate(true)

func summarize_session_discoveries(snapshot: Variant) -> Dictionary:
	_ensure_initialized()
	var categories: Dictionary = {}
	var total := 0
	var source: Dictionary = snapshot as Dictionary if snapshot is Dictionary else {}
	for category in CATEGORIES:
		var ids: Array[String] = []
		var names: Array[String] = []
		var raw_ids: Variant = source.get(category, [])
		if raw_ids is Dictionary:
			raw_ids = (raw_ids as Dictionary).get("ids", [])
		if raw_ids is Array:
			for raw_id in raw_ids as Array:
				var id := _normalize_id(category, String(raw_id))
				if id == "" or ids.has(id):
					continue
				ids.append(id)
				var master: Dictionary = (_master_by_id.get(category, {}) as Dictionary).get(id, {}) as Dictionary
				names.append(_master_display_name(master, id))
		categories[category] = {"count": ids.size(), "ids": ids, "names": names}
		total += ids.size()
	return {"total": total, "categories": categories}.duplicate(true)

func get_master_entries(category: String) -> Array:
	_ensure_initialized()
	var normalized_category := category.strip_edges().to_lower()
	var result: Array = []
	for item in (_masters.get(normalized_category, []) as Array):
		result.append((item as Dictionary).duplicate(true))
	return result

func get_entries_for_ui(category: String) -> Array:
	_ensure_initialized()
	var normalized_category := category.strip_edges().to_lower()
	var result: Array = []
	for master_item in (_masters.get(normalized_category, []) as Array):
		var master: Dictionary = master_item as Dictionary
		var id := String(master.get("id", ""))
		var view := master.duplicate(true)
		view["discovered"] = is_discovered(normalized_category, id)
		view["new"] = is_new(normalized_category, id)
		view["entry"] = get_entry(normalized_category, id)
		result.append(view)
	return result

func canonical_enemy_id(enemy: Dictionary) -> String:
	var boss_id := String(enemy.get("bossId", ""))
	var raw_id := boss_id if boss_id != "" else String(enemy.get("kind", ""))
	if raw_id == "":
		raw_id = String(enemy.get("kind", ""))
	return _normalize_id(CATEGORY_ENEMY, raw_id)

func get_orphan_entries() -> Dictionary:
	_ensure_initialized()
	return _orphan_entries.duplicate(true)

func debug_unlock_all(emit_completion_events: bool = false) -> bool:
	if not OS.is_debug_build():
		return false
	_ensure_initialized()
	for category in CATEGORIES:
		for master_value in _masters.get(category, []) as Array:
			if not master_value is Dictionary:
				continue
			var master: Dictionary = master_value as Dictionary
			var id := String(master.get("id", ""))
			var source: Dictionary = (_entries[category] as Dictionary).get(id, {}) as Dictionary
			_entries[category][id] = _new_entry_for_category(category, id, false, source)
	_sync_completion_state(emit_completion_events)
	codex_bulk_changed.emit("all")
	return true

func debug_mark_all_new() -> bool:
	if not OS.is_debug_build():
		return false
	_ensure_initialized()
	for category in CATEGORIES:
		for master_value in _masters.get(category, []) as Array:
			if not master_value is Dictionary:
				continue
			var master: Dictionary = master_value as Dictionary
			var id := String(master.get("id", ""))
			var source: Dictionary = (_entries[category] as Dictionary).get(id, {}) as Dictionary
			_entries[category][id] = _new_entry_for_category(category, id, true, source)
	_sync_completion_state(false)
	codex_bulk_changed.emit("all")
	return true

func debug_reset_codex() -> bool:
	if not OS.is_debug_build():
		return false
	initialize_empty()
	codex_bulk_changed.emit("all")
	return true

func validate_masters() -> Dictionary:
	_ensure_initialized()
	var report := CodexAuditSystemScript.audit(_raw_masters, _masters, _disabled_ids, EnemyCodexProfileSystemScript.load_sources())
	for warning_value in report.get("warnings", []) as Array:
		var warning := String(warning_value)
		_warn_once("audit:%s" % warning, "[Codex Audit] %s" % warning)
	return report.duplicate(true)

func write_enemy_audit_report() -> Dictionary:
	if not OS.is_debug_build():
		return {"written": false, "path": "", "warnings": 0}
	_ensure_initialized()
	var sources := EnemyCodexProfileSystemScript.load_sources()
	var raw_enemies: Array = _raw_masters.get(CATEGORY_ENEMY, []) as Array
	var catalog := EnemyCodexProfileSystemScript.build_catalog(raw_enemies, sources)
	var report := validate_masters()
	var path := "user://enemy_codex_audit.txt"
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return {"written": false, "path": ProjectSettings.globalize_path(path), "warnings": (report.get("warnings", []) as Array).size()}
	file.store_string(EnemyCodexProfileSystemScript.build_report_text(catalog))
	file.close()
	return {
		"written": true,
		"path": ProjectSettings.globalize_path(path),
		"warnings": (report.get("warnings", []) as Array).size(),
		"counts": (report.get("counts", {}) as Dictionary).duplicate(true)
	}

func _ensure_initialized() -> void:
	if not _initialized:
		initialize_empty()

func _normalize_id(category: String, id: String) -> String:
	var normalized := id.strip_edges()
	if category == CATEGORY_ENEMY:
		match normalized:
			"red_pen_retake_dragon":
				return "red_pen_review_chief"
			"bugged_final_boss_stun":
				return "bugged_final_boss"
	return normalized

func _master_display_name(master: Dictionary, fallback_id: String) -> String:
	var display_name := String(master.get("displayName", master.get("name", ""))).strip_edges()
	if display_name == "":
		display_name = String(master.get("text", master.get("body", ""))).strip_edges()
	return display_name if display_name != "" else fallback_id

func _normalize_boss_difficulty(value: String) -> String:
	var normalized := value.strip_edges().to_lower()
	return normalized if BOSS_DIFFICULTIES.has(normalized) else ""

func _is_known_enabled_id(category: String, id: String) -> bool:
	return CATEGORIES.has(category) and id != "" and _has_enabled_master(category, id)

func _has_enabled_master(category: String, id: String) -> bool:
	return (_master_by_id.get(category, {}) as Dictionary).has(id)

func _is_boss_master(id: String) -> bool:
	var master: Dictionary = (_master_by_id.get(CATEGORY_ENEMY, {}) as Dictionary).get(id, {}) as Dictionary
	return bool(master.get("isBoss", false)) or bool(master.get("relayBoss", false))

func _empty_defeated_state() -> Dictionary:
	return {"normal": false, "hard": false, "expert": false}

func _normalize_defeated(value: Variant) -> Dictionary:
	var result := _empty_defeated_state()
	if not value is Dictionary:
		return result
	for difficulty_id in BOSS_DIFFICULTIES:
		result[difficulty_id] = _safe_bool((value as Dictionary).get(difficulty_id, false), false)
	return result

func _normalize_saved_entry(category: String, id: String, raw: Dictionary) -> Dictionary:
	if not _safe_bool(raw.get("discovered", true), true):
		return {}
	return _new_entry_for_category(category, id, _safe_bool(raw.get("new", false), false), raw)

func _new_entry_for_category(category: String, id: String, is_new: bool, source: Dictionary = {}) -> Dictionary:
	var result: Dictionary = {"discovered": true, "new": is_new}
	if category == CATEGORY_CHARACTER:
		result = _normalize_character_entry(source, is_new)
	elif category == CATEGORY_COMMENT:
		result = _normalize_comment_entry(source, is_new)
	elif category == CATEGORY_ENEMY:
		result["kill_count"] = maxi(0, int(source.get("kill_count", 0)))
		if _is_boss_master(id):
			result["defeated"] = _normalize_defeated(source.get("defeated", {}))
	return result

func _new_character_entry(is_new: bool) -> Dictionary:
	return _normalize_character_entry({}, is_new)

func _normalize_character_entry(source: Dictionary, is_new: bool) -> Dictionary:
	return {
		"discovered": true,
		"new": is_new,
		"play_count": maxi(0, int(source.get("play_count", 0))),
		"clear_count": maxi(0, int(source.get("clear_count", 0))),
		"best_score": maxi(0, int(source.get("best_score", 0))),
		"stage_clears": _normalize_stage_clears(source.get("stage_clears", {})),
		"relay_records": _normalize_relay_records(source.get("relay_records", {}))
	}

func _new_comment_entry(is_new: bool) -> Dictionary:
	return _normalize_comment_entry({}, is_new)

func _normalize_comment_entry(source: Dictionary, is_new: bool) -> Dictionary:
	return {
		"discovered": true,
		"new": is_new,
		"appeared_count": maxi(0, int(source.get("appeared_count", 0))),
		"selected_count": maxi(0, int(source.get("selected_count", 0))),
		"heart_count": maxi(0, int(source.get("heart_count", 0)))
	}

func _ensure_character_entry(id: String, is_new: bool) -> Dictionary:
	var raw: Variant = (_entries[CATEGORY_CHARACTER] as Dictionary).get(id, {})
	var source: Dictionary = raw as Dictionary if raw is Dictionary else {}
	var entry := _normalize_character_entry(source, _safe_bool(source.get("new", is_new), is_new))
	(_entries[CATEGORY_CHARACTER] as Dictionary)[id] = entry
	return entry

func _ensure_comment_entry(id: String) -> Dictionary:
	var raw: Variant = (_entries[CATEGORY_COMMENT] as Dictionary).get(id, {})
	var source: Dictionary = raw as Dictionary if raw is Dictionary else {}
	var entry := _normalize_comment_entry(source, _safe_bool(source.get("new", true), true))
	(_entries[CATEGORY_COMMENT] as Dictionary)[id] = entry
	return entry

func _normalize_stage_clears(value: Variant) -> Dictionary:
	var result: Dictionary = {}
	for stage_id in RECORD_STAGES:
		var flags: Dictionary = {}
		for difficulty_id in RECORD_DIFFICULTIES:
			flags[difficulty_id] = false
		result[stage_id] = flags
	if not value is Dictionary:
		return result
	for raw_stage in (value as Dictionary).keys():
		var stage_id := _normalize_record_stage(raw_stage)
		if not RECORD_STAGES.has(stage_id):
			continue
		var raw_flags: Variant = (value as Dictionary)[raw_stage]
		if not raw_flags is Dictionary:
			continue
		var flags := result[stage_id] as Dictionary
		for difficulty_id in RECORD_DIFFICULTIES:
			flags[difficulty_id] = _safe_bool((raw_flags as Dictionary).get(difficulty_id, false), false)
		result[stage_id] = flags
	return result

func _normalize_relay_records(value: Variant) -> Dictionary:
	var result: Dictionary = {}
	for difficulty_id in RECORD_DIFFICULTIES:
		result[difficulty_id] = {"cleared": false, "best_section": 0}
	if not value is Dictionary:
		return result
	for difficulty_id in RECORD_DIFFICULTIES:
		var raw_record: Variant = (value as Dictionary).get(difficulty_id, {})
		if not raw_record is Dictionary:
			continue
		var raw_record_dict := raw_record as Dictionary
		result[difficulty_id] = {
			"cleared": _safe_bool(raw_record_dict.get("cleared", false), false),
			"best_section": clampi(int(raw_record_dict.get("best_section", raw_record_dict.get("bestSection", 0))), 0, 5)
		}
	return result

func _normalize_record_stage(value: Variant) -> String:
	var id := String(value).strip_edges().to_lower()
	return String(STAGE_ALIASES.get(id, id))

func _normalize_record_difficulty(value: Variant) -> String:
	var id := String(value).strip_edges().to_lower()
	return id if RECORD_DIFFICULTIES.has(id) else "normal"

func _sync_legacy_stage_clear(character_id: String, stage_id: String, difficulty_id: String) -> bool:
	var id := _normalize_id(CATEGORY_CHARACTER, character_id)
	if not _is_known_enabled_id(CATEGORY_CHARACTER, id):
		return false
	var entry := _ensure_character_entry(id, false)
	var stage_clears := _normalize_stage_clears(entry.get("stage_clears", {}))
	var flags := stage_clears[stage_id] as Dictionary
	if bool(flags.get(difficulty_id, false)):
		return false
	flags[difficulty_id] = true
	stage_clears[stage_id] = flags
	entry["stage_clears"] = stage_clears
	entry["new"] = false
	_entries[CATEGORY_CHARACTER][id] = entry
	codex_changed.emit(CATEGORY_CHARACTER, id)
	return true

func _sync_legacy_relay_clear(character_id: String, difficulty_id: String) -> bool:
	var id := _normalize_id(CATEGORY_CHARACTER, character_id)
	if not _is_known_enabled_id(CATEGORY_CHARACTER, id):
		return false
	var entry := _ensure_character_entry(id, false)
	var relay_records := _normalize_relay_records(entry.get("relay_records", {}))
	var record := relay_records[difficulty_id] as Dictionary
	var changed := not bool(record.get("cleared", false)) or int(record.get("best_section", 0)) < 5
	record["cleared"] = true
	record["best_section"] = 5
	relay_records[difficulty_id] = record
	entry["relay_records"] = relay_records
	entry["new"] = false
	_entries[CATEGORY_CHARACTER][id] = entry
	if changed:
		codex_changed.emit(CATEGORY_CHARACTER, id)
	return changed

func _sync_completion_state(emit_signals: bool) -> void:
	for category in CATEGORIES:
		var total := get_total_count(category)
		var found := get_discovered_count(category)
		if total <= 0 or found != total or bool(_category_completed_once.get(category, false)):
			continue
		_category_completed_once[category] = true
		if emit_signals:
			completion_achieved.emit("category", category)
	var all_complete := true
	for category in COLLECTION_CATEGORIES:
		var category_total := get_total_count(category)
		var category_found := get_discovered_count(category)
		if category_total <= 0 or category_found != category_total:
			all_complete = false
			break
	var total_collection := 0
	for category in COLLECTION_CATEGORIES:
		total_collection += get_total_count(category)
	if total_collection > 0 and all_complete and not _collection_completed_once:
		_collection_completed_once = true
		if emit_signals:
			completion_achieved.emit("collection", "")

func _update_collection_completed_once() -> void:
	# Compatibility shim for older callers in the v0.1-v0.4 integration.
	_sync_completion_state(false)

func _reset_session_state() -> void:
	_active_run_id = ""
	_active_run_play_recorded = false
	_active_run_result_recorded = false
	_last_finished_run_id = ""
	_last_finished_snapshot = {}
	_reset_session_discoveries()

func _reset_session_discoveries() -> void:
	_session_discoveries.clear()
	for category in CATEGORIES:
		_session_discoveries[category] = []

func _record_session_discovery(category: String, id: String) -> void:
	if _active_run_id == "" or _last_finished_run_id != "":
		return
	var values: Array = _session_discoveries.get(category, []) as Array
	if values.has(id):
		return
	values.append(id)
	_session_discoveries[category] = values

func _warn_once(key: String, message: String) -> void:
	if _warning_keys.has(key):
		return
	_warning_keys[key] = true
	push_warning(message)

func _safe_bool(value: Variant, fallback: bool = false) -> bool:
	if value is bool:
		return bool(value)
	if value is int or value is float:
		return float(value) != 0.0
	return fallback

func _load_masters() -> void:
	_masters.clear()
	_master_by_id.clear()
	_disabled_ids.clear()
	_raw_masters.clear()
	for category in CATEGORIES:
		_masters[category] = []
		_master_by_id[category] = {}
		_disabled_ids[category] = {}
	_load_standard_master(CATEGORY_CHARACTER, CHARACTER_MASTER_PATH, "")
	_load_standard_master(CATEGORY_WEAPON, WEAPON_MASTER_PATH, "weapon")
	_load_standard_master(CATEGORY_ACCESSORY, GIFT_MASTER_PATH, "accessory")
	_load_standard_master(CATEGORY_COMMENT, COMMENT_MASTER_PATH, "")
	_load_enemy_master()
	# A damaged or empty master may use the defensive fallback below.  A valid
	# master is authoritative even when its size changes in a future build.
	if (_masters[CATEGORY_CHARACTER] as Array).is_empty():
		_set_fallback_master(CATEGORY_CHARACTER, _fallback_characters())
	if (_masters[CATEGORY_WEAPON] as Array).is_empty():
		_set_fallback_master(CATEGORY_WEAPON, _fallback_weapons())
	if (_masters[CATEGORY_ACCESSORY] as Array).is_empty():
		_set_fallback_master(CATEGORY_ACCESSORY, _fallback_accessories())
	if (_masters[CATEGORY_COMMENT] as Array).is_empty():
		# comments.json is the source of truth; keep a safe minimal fallback only
		# for damaged development copies so the manager remains usable.
		_set_fallback_master(CATEGORY_COMMENT, _fallback_comments())

func _load_standard_master(category: String, path: String, required_type: String) -> void:
	var parsed := _read_array(path)
	var relevant_raw: Array = []
	var comment_reachability: Dictionary = {}
	if category == CATEGORY_COMMENT:
		comment_reachability = CommentSystemScript.codex_reachable_standard_comment_ids(parsed)
	for index in range(parsed.size()):
		var raw: Dictionary = parsed[index] as Dictionary
		if raw.is_empty():
			continue
		if required_type != "" and String(raw.get("equipmentType", "")) != required_type:
			continue
		relevant_raw.append(raw.duplicate(true))
		var raw_id := String(raw.get("id", "")).strip_edges()
		if category == CATEGORY_COMMENT and not bool(raw.get("codexEnabled", true)):
			_add_master(category, raw, index)
			continue
		# Keep the source array intact for audit/save compatibility, while the
		# visible codex master contains only comments reachable from a standard
		# NORMAL/HARD stream frame.  An empty reachability map means the source
		# could not be inspected, so fail open rather than hiding the catalogue.
		if category == CATEGORY_COMMENT and not comment_reachability.is_empty() and not bool(comment_reachability.get(raw_id, false)):
			continue
		_add_master(category, raw, index)
	_raw_masters[category] = relevant_raw

func _load_enemy_master() -> void:
	var parsed := _read_array(CODEX_ENEMY_MASTER_PATH)
	_raw_masters[CATEGORY_ENEMY] = parsed.duplicate(true)
	for index in range(parsed.size()):
		var raw: Dictionary = parsed[index] as Dictionary
		if raw.is_empty():
			continue
		_add_master(CATEGORY_ENEMY, raw, int(raw.get("order", index)))
	if (_masters[CATEGORY_ENEMY] as Array).is_empty():
		_set_fallback_master(CATEGORY_ENEMY, _fallback_enemies())

func _add_master(category: String, raw: Dictionary, order: int) -> void:
	var id := String(raw.get("id", "")).strip_edges()
	if id == "":
		return
	var normalized_id := _normalize_id(category, id)
	var enabled := bool(raw.get("codexEnabled", true))
	if not enabled:
		(_disabled_ids[category] as Dictionary)[normalized_id] = true
		return
	if (_master_by_id[category] as Dictionary).has(normalized_id):
		return
	var master := raw.duplicate(true)
	master["id"] = normalized_id
	master["order"] = order
	(_masters[category] as Array).append(master)
	(_master_by_id[category] as Dictionary)[normalized_id] = master
	(_masters[category] as Array).sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("order", 0)) < int(b.get("order", 0))
	)

func _set_fallback_master(category: String, entries: Array) -> void:
	_masters[category] = []
	_master_by_id[category] = {}
	_disabled_ids[category] = {}
	for index in range(entries.size()):
		_add_master(category, entries[index] as Dictionary, index)

func _read_array(path: String) -> Array:
	if not FileAccess.file_exists(path):
		return []
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return []
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Array:
		return parsed as Array
	if parsed is Dictionary:
		var entries: Variant = (parsed as Dictionary).get("entries", (parsed as Dictionary).get("items", []))
		return entries as Array if entries is Array else []
	return []

func _fallback_characters() -> Array:
	return [
		{"id": "ban_chan", "displayName": "ばんちゃん", "initialWeapon": "ban_hammer"},
		{"id": "superchat_chan", "displayName": "スパチャちゃん", "initialWeapon": "superchat_shot"},
		{"id": "maro_chan", "displayName": "マロちゃん", "initialWeapon": "comment_boomerang"},
		{"id": "aosumi_kyasumi", "displayName": "青澄キャスミ", "initialWeapon": "phase1_null_weapon"},
		{"id": "akarine_rizumu", "displayName": "赤音リズム", "initialWeapon": "phase1_null_weapon"},
		{"id": "shizuki_miimu", "displayName": "雫木ミーム", "initialWeapon": "phase1_null_weapon"}
	]

func _fallback_weapons() -> Array:
	var ids: Array[String] = [
		"ban_hammer", "superchat_shot", "comment_boomerang", "ban_judgement", "starlight_superchat",
		"maro_comment_ring", "mic_barrier", "spotlight", "kusa_wave", "comment_pin", "emote_mine",
		"ng_word_laser", "listener_summon", "full_voice_dome", "center_stage", "great_grassland",
		"comment_lockdown", "emote_festival", "all_block_laser", "listener_assembly", "moderator_shield",
		"fansa_baton", "tsuri_thumbnail_rod", "moderator_fortress", "fansa_climax", "buzz_thumbnail_rod"
	]
	var result: Array = []
	for id in ids:
		result.append({"id": id, "displayName": id, "equipmentType": "weapon", "maxLevel": 5})
	result.append({"id": "phase1_null_weapon", "displayName": "Reserved weapon", "equipmentType": "weapon", "maxLevel": 1, "codexEnabled": false})
	return result

func _fallback_accessories() -> Array:
	var ids: Array[String] = ["stream_power", "bullet_support", "high_speed_connection", "wide_angle", "light_sneakers", "sweet_tooth", "mental_care", "notification_bell", "comment_radar", "mini_humidifier"]
	var result: Array = []
	for id in ids:
		result.append({"id": id, "displayName": id, "equipmentType": "accessory", "maxLevel": 5})
	return result

func _fallback_comments() -> Array:
	var result: Array = []
	for index in range(44):
		result.append({"id": "comment_%02d" % index, "displayName": "コメント %02d" % index, "description": ""})
	return result

func _fallback_enemies() -> Array:
	var ids: Array[String] = [
		"troll", "fast", "shooter", "long_comment_guy", "clipper", "unread_maro", "ghost_comment",
		"enemy_spoiler_comment", "enemy_backseat_controller", "enemy_armchair_strategist", "enemy_lag_comment",
		"enemy_strategy_wiki_ojisan", "enemy_fake_first_timer", "enemy_wrong_way_kart", "enemy_jammer_cone",
		"enemy_dot_invader", "enemy_bullet_drone", "enemy_fake_gift_box", "enemy_noise_ghost_comment",
		"pitch_police", "request_spammer", "fast_call_fan", "song_noise_comment", "song_lyric_spoiler_comment",
		"drawing_fix_note", "red_pen_teacher", "layer_lost", "bucket_fill_slime", "undo_ghost",
		"collab_comparison_troll", "collab_messenger_pigeon", "collab_discord_troll", "collab_volume_police",
		"collab_exclusive_listener", "collab_division_noise", "collab_mute_core", "noise_ghost_comment",
		"boss_super_long_comment", "boss_kuso_maro_king", "bugged_final_boss", "pitch_police_chief",
		"red_pen_review_chief", "collab_crusher", "last_offline"
	]
	var result: Array = []
	for index in range(ids.size()):
		var id := ids[index]
		result.append({
			"id": id,
			"displayName": id,
			"description": "",
			"spawnFrames": [],
			"isBoss": id in ["boss_super_long_comment", "boss_kuso_maro_king", "bugged_final_boss", "pitch_police_chief", "red_pen_review_chief", "collab_crusher", "last_offline"],
			"codexEnabled": not (id == "undo_ghost" or id == "boss_super_long_comment"),
			"order": index
		})
	return result
