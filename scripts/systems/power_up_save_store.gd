class_name PowerUpSaveStore
extends RefCounted

const SAVE_PATH := "user://power_up_shop.json"
const BACKUP_PATH := "user://power_up_shop.json.bak"
const TEMP_PATH := "user://power_up_shop.json.tmp"
const SCHEMA_VERSION := 2
const MAX_REWARDED_RUN_IDS := 100
const MAX_REWARDED_REWARD_KEYS := 200
const DEFAULT_CHARACTER_ID := "ban_chan"
const ALWAYS_UNLOCKED_CHARACTER_IDS := ["ban_chan", "superchat_chan", "maro_chan"]
const SENIOR_UNIT_CHARACTER_IDS := ["aosumi_kyasumi", "akarine_rizumu", "shizuki_miimu"]

var path := SAVE_PATH
var backup_path := BACKUP_PATH
var temp_path := TEMP_PATH
var save_override: Callable

func load_data(database) -> Dictionary:
	var loaded := _read_root(path)
	if loaded.is_empty():
		loaded = _read_root(backup_path)
	if loaded.is_empty():
		loaded = _migrate_legacy(database)
	return normalize(loaded, database)

func save_data(data: Dictionary, database) -> bool:
	var candidate := normalize(data, database)
	if save_override.is_valid():
		return bool(save_override.call(candidate.duplicate(true)))
	var payload := {"powerUpShop": candidate}
	var file := FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(payload))
	file.flush()
	file.close()
	var verify := _read_root(temp_path)
	if verify.is_empty() or not _data_matches(verify, candidate, database):
		_remove_file(temp_path)
		return false
	if FileAccess.file_exists(path):
		_remove_file(backup_path)
		if not _rename_file(path, backup_path):
			_remove_file(temp_path)
			return false
	if not _rename_file(temp_path, path):
		if FileAccess.file_exists(backup_path):
			_rename_file(backup_path, path)
		return false
	return true

func default_data(database) -> Dictionary:
	var levels: Dictionary = {}
	for item in database.upgrades:
		levels[String((item as Dictionary).get("id", ""))] = 0
	var stage_flags := {"zatsudan": false, "gameplay": false, "singing": false, "drawing": false, "collab": false}
	var boss_flags := {
		"kusomaro_king": false,
		"bugged_final_boss": false,
		"pitch_police_chief": false,
		"redpen_retake_dragon": false,
		"collab_crusher": false,
		"last_offline": false
	}
	return {
		"schemaVersion": SCHEMA_VERSION,
		"unlocked": false,
		"currentPoints": 0,
		"totalEarnedPoints": 0,
		"totalSpentPoints": 0,
		"upgrades": levels,
		"firstStageClears": stage_flags,
		"firstBossDefeats": boss_flags,
		"firstRelayClear": false,
		"selectedCharacterId": DEFAULT_CHARACTER_ID,
		"unlockedCharacterIds": ALWAYS_UNLOCKED_CHARACTER_IDS.duplicate(),
		"seniorUnitUnlockShown": false,
		"normalRelayCleared": false,
		"rewardedRunIds": [],
		"rewardedRewardKeys": []
	}

func normalize(data: Dictionary, database) -> Dictionary:
	var result := default_data(database)
	var source: Dictionary = data.get("powerUpShop", data) as Dictionary
	result["schemaVersion"] = SCHEMA_VERSION
	result["unlocked"] = bool(source.get("unlocked", false))
	result["currentPoints"] = maxi(0, int(source.get("currentPoints", 0)))
	result["totalEarnedPoints"] = maxi(0, int(source.get("totalEarnedPoints", 0)))
	result["totalSpentPoints"] = maxi(0, int(source.get("totalSpentPoints", 0)))
	var levels: Dictionary = result["upgrades"] as Dictionary
	var source_levels: Dictionary = source.get("upgrades", {}) as Dictionary
	for id in levels.keys():
		var max_level: int = int(database.max_level_for(String(id)))
		levels[id] = clampi(int(source_levels.get(id, 0)), 0, max_level)
	result["upgrades"] = levels
	result["firstStageClears"] = _normalize_flags(source.get("firstStageClears", {}), result["firstStageClears"] as Dictionary)
	result["firstBossDefeats"] = _normalize_flags(source.get("firstBossDefeats", {}), result["firstBossDefeats"] as Dictionary)
	result["firstRelayClear"] = bool(source.get("firstRelayClear", false))
	var unlocked_ids := _normalize_character_ids(source.get("unlockedCharacterIds", source.get("unlocked_character_ids", [])))
	var normal_relay_cleared := bool(source.get("normalRelayCleared", source.get("normal_relay_cleared", false)))
	var source_schema := int(source.get("schemaVersion", 0))
	if source_schema < SCHEMA_VERSION and bool(result.get("firstRelayClear", false)):
		normal_relay_cleared = true
	if source_schema < SCHEMA_VERSION and _legacy_rankings_normal_relay_clear():
		normal_relay_cleared = true
	if SENIOR_UNIT_CHARACTER_IDS.all(func(id: String) -> bool: return unlocked_ids.has(id)):
		normal_relay_cleared = true
	if normal_relay_cleared:
		for id in SENIOR_UNIT_CHARACTER_IDS:
			if not unlocked_ids.has(id):
				unlocked_ids.append(id)
	result["unlockedCharacterIds"] = unlocked_ids
	result["normalRelayCleared"] = normal_relay_cleared
	result["seniorUnitUnlockShown"] = bool(source.get("seniorUnitUnlockShown", source.get("senior_unit_unlock_shown", false)))
	var selected_id := String(source.get("selectedCharacterId", source.get("selected_character_id", DEFAULT_CHARACTER_ID)))
	result["selectedCharacterId"] = selected_id if unlocked_ids.has(selected_id) else DEFAULT_CHARACTER_ID
	result["rewardedRunIds"] = _normalize_string_list(source.get("rewardedRunIds", []), MAX_REWARDED_RUN_IDS)
	result["rewardedRewardKeys"] = _normalize_string_list(source.get("rewardedRewardKeys", []), MAX_REWARDED_REWARD_KEYS)
	return result

func _migrate_legacy(database) -> Dictionary:
	var result := default_data(database)
	var progress := _read_json("user://stream_frame_progress.json")
	var progress_source: Dictionary = progress.get("streamFrameProgress", progress) as Dictionary
	var first_stage: Dictionary = result["firstStageClears"] as Dictionary
	for stage_id in first_stage.keys():
		var item: Variant = progress_source.get(stage_id, {})
		if item is Dictionary:
			first_stage[stage_id] = bool((item as Dictionary).get("isCleared", false))
		else:
			first_stage[stage_id] = bool(item)
	result["firstStageClears"] = first_stage
	var rankings := _read_json("user://rankings.json")
	var normal_entries: Array = rankings.get("rankingEntries", rankings.get("entries", [])) as Array
	for item in normal_entries:
		if not (item is Dictionary):
			continue
		var entry: Dictionary = item as Dictionary
		if not bool(entry.get("isDebug", false)) and String(entry.get("modeId", "")) != "debug" and String(entry.get("endType", "")) != "debug":
			result["unlocked"] = true
			var boss_id := _legacy_boss_id(entry)
			if bool(entry.get("bossDefeated", false)) and boss_id != "":
				var boss_flags: Dictionary = result["firstBossDefeats"] as Dictionary
				boss_flags[boss_id] = true
				result["firstBossDefeats"] = boss_flags
	var relay_entries: Array = rankings.get("relayRankingEntries", []) as Array
	for item in relay_entries:
		if not (item is Dictionary):
			continue
		var entry: Dictionary = item as Dictionary
		if bool(entry.get("isRelayCompleted", false)) or String(entry.get("endedReason", "")) == "completed":
			result["firstRelayClear"] = true
		if _legacy_normal_relay_clear(entry):
			result["normalRelayCleared"] = true
		if bool(entry.get("bossDefeated", false)) and String(entry.get("bossName", "")) != "":
			var boss_flags: Dictionary = result["firstBossDefeats"] as Dictionary
			boss_flags["last_offline"] = true
			result["firstBossDefeats"] = boss_flags
	if bool(result.get("normalRelayCleared", false)):
		result["unlockedCharacterIds"] = ALWAYS_UNLOCKED_CHARACTER_IDS.duplicate() + SENIOR_UNIT_CHARACTER_IDS.duplicate()
	return result

func _normalize_character_ids(value: Variant) -> Array[String]:
	var result: Array[String] = []
	for id in ALWAYS_UNLOCKED_CHARACTER_IDS:
		result.append(String(id))
	if value is Array:
		for item in value as Array:
			var id := String(item)
			if SENIOR_UNIT_CHARACTER_IDS.has(id) and not result.has(id):
				result.append(id)
	return result

func _legacy_normal_relay_clear(entry: Dictionary) -> bool:
	if bool(entry.get("isDebug", false)) or String(entry.get("modeId", "")) == "debug" or String(entry.get("endType", "")) == "debug":
		return false
	var is_relay := String(entry.get("modeId", "")) == "relay" or String(entry.get("stageId", "")) == "relay"
	var difficulty_id := String(entry.get("difficultyId", entry.get("difficulty_id", "normal")))
	var completed := bool(entry.get("isRelayCompleted", false)) or String(entry.get("endedReason", "")) == "completed"
	var final_defeated := bool(entry.get("finalDefeated", entry.get("bossDefeated", false)))
	return is_relay and difficulty_id == "normal" and completed and final_defeated

func _legacy_rankings_normal_relay_clear() -> bool:
	var rankings := _read_json("user://rankings.json")
	var relay_entries: Array = rankings.get("relayRankingEntries", []) as Array
	for item in relay_entries:
		if item is Dictionary and _legacy_normal_relay_clear(item as Dictionary):
			return true
	return false

func _legacy_boss_id(entry: Dictionary) -> String:
	var id := String(entry.get("bossPpRewardId", entry.get("ppRewardId", "")))
	if ["kusomaro_king", "bugged_final_boss", "pitch_police_chief", "redpen_retake_dragon", "collab_crusher"].has(id):
		return id
	var runtime_id := String(entry.get("bossId", ""))
	var aliases := {
		"boss_kuso_maro_king": "kusomaro_king",
		"bugged_final_boss": "bugged_final_boss",
		"pitch_police_chief": "pitch_police_chief",
		"red_pen_review_chief": "redpen_retake_dragon",
		"collab_crusher": "collab_crusher"
	}
	return String(aliases.get(runtime_id, ""))

func _data_matches(root: Dictionary, expected: Dictionary, database) -> bool:
	var actual := normalize(root, database)
	return JSON.stringify(actual) == JSON.stringify(expected)

func _read_root(file_path: String) -> Dictionary:
	var parsed := _read_json(file_path)
	return parsed.get("powerUpShop", {}) as Dictionary

func _read_json(file_path: String) -> Dictionary:
	if not FileAccess.file_exists(file_path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(file_path))
	return parsed as Dictionary if parsed is Dictionary else {}

func _normalize_flags(value: Variant, defaults: Dictionary) -> Dictionary:
	var result := defaults.duplicate(true)
	if not (value is Dictionary):
		return result
	var source: Dictionary = value as Dictionary
	for key in result.keys():
		result[key] = bool(source.get(key, result[key]))
	return result

func _normalize_string_list(value: Variant, limit: int) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for item in value as Array:
			var text := String(item)
			if text != "" and not result.has(text):
				result.append(text)
	while result.size() > limit:
		result.pop_front()
	return result

func _remove_file(file_path: String) -> void:
	if FileAccess.file_exists(file_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(file_path))

func _rename_file(from_path: String, to_path: String) -> bool:
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(from_path), ProjectSettings.globalize_path(to_path)) == OK
