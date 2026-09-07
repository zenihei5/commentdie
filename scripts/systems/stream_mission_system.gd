class_name StreamMissionSystem
extends RefCounted

const DatabaseScript := preload("res://scripts/systems/stream_mission_system.gd")
const MASTER_PATH := "res://data/stream_missions.json"
const EXPECTED_MISSION_IDS := [
	"TALK-1", "TALK-2", "TALK-3", "GAME-1", "GAME-2", "GAME-3",
	"SONG-1", "SONG-2", "SONG-3", "DRAW-1", "DRAW-2", "DRAW-3",
	"COLLAB-1", "COLLAB-2", "COLLAB-3", "RELAY-1", "RELAY-2", "RELAY-3"
]
const EXPECTED_SET_IDS := ["v1:talk", "v1:game", "v1:song", "v1:drawing", "v1:collab", "v1:relay"]
const VALID_DIFFICULTIES := ["normal", "hard", "expert"]
const VALID_NORMAL_STAGES := ["zatsudan", "gameplay", "singing", "drawing", "collab"]
const EXPECTED_RELAY_FRAME_IDS := ["zatsudan", "gameplay", "singing", "drawing", "collab"]
const NORMAL_INK_BITS := {"pink": 1, "cyan": 2, "green": 4, "yellow": 8}

var is_valid := false
var version := 0
var title_id := "title_perfect_streamer"
var missions: Array[Dictionary] = []
var sets: Array[Dictionary] = []
var validation_errors: Array[String] = []
var _missions_by_id: Dictionary = {}
var _sets_by_id: Dictionary = {}
var _sets_by_stage: Dictionary = {}

static func load_default():
	var database := DatabaseScript.new()
	var file := FileAccess.open(MASTER_PATH, FileAccess.READ)
	if file == null:
		database.validation_errors.append("missing master: %s" % MASTER_PATH)
		return database
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		database.validation_errors.append("master root is not an object")
		return database
	database._load(parsed as Dictionary)
	return database

func _load(root: Dictionary) -> void:
	version = int(root.get("version", 0))
	title_id = String(root.get("titleId", "title_perfect_streamer"))
	if version <= 0:
		validation_errors.append("master version is invalid")
	if title_id != "title_perfect_streamer":
		validation_errors.append("title id is invalid")
	var raw_missions: Variant = root.get("missions", [])
	if not raw_missions is Array:
		validation_errors.append("missions is not an array")
		raw_missions = []
	for raw_value in raw_missions as Array:
		if not raw_value is Dictionary:
			validation_errors.append("mission is not an object")
			continue
		var mission := (raw_value as Dictionary).duplicate(true)
		var id := String(mission.get("id", "")).strip_edges()
		if id == "" or _missions_by_id.has(id):
			validation_errors.append("duplicate or empty mission id: %s" % id)
			continue
		if not EXPECTED_MISSION_IDS.has(id):
			validation_errors.append("unknown mission id: %s" % id)
			continue
		var stage_id := String(mission.get("stageId", "")).strip_edges().to_lower()
		var difficulty_value: Variant = mission.get("difficulty", [])
		if not difficulty_value is Array or (difficulty_value as Array).is_empty():
			validation_errors.append("mission difficulty is invalid: %s" % id)
			continue
		var normalized_difficulties: Array[String] = []
		for difficulty_value_item in difficulty_value as Array:
			var difficulty_id := String(difficulty_value_item).strip_edges().to_lower()
			if not VALID_DIFFICULTIES.has(difficulty_id) or normalized_difficulties.has(difficulty_id):
				validation_errors.append("mission difficulty is invalid: %s" % id)
				normalized_difficulties.clear()
				break
			normalized_difficulties.append(difficulty_id)
		if normalized_difficulties.is_empty():
			continue
		if stage_id != "relay" and not VALID_NORMAL_STAGES.has(stage_id):
			validation_errors.append("mission stage is invalid: %s" % id)
			continue
		if stage_id == "relay" and id not in ["RELAY-1", "RELAY-2", "RELAY-3"]:
			validation_errors.append("relay stage mismatch: %s" % id)
			continue
		if stage_id != "relay" and id.begins_with("RELAY-"):
			validation_errors.append("non-relay stage mismatch: %s" % id)
			continue
		if not mission.has("conditionType") or not mission.get("params", {}) is Dictionary:
			validation_errors.append("mission condition is invalid: %s" % id)
			continue
		mission["id"] = id
		mission["stageId"] = stage_id
		mission["difficulty"] = normalized_difficulties
		mission["rewardPp"] = int(mission.get("rewardPp", 0))
		mission["params"] = (mission.get("params", {}) as Dictionary).duplicate(true)
		missions.append(mission)
		_missions_by_id[id] = mission
	var raw_sets: Variant = root.get("sets", [])
	if not raw_sets is Array:
		validation_errors.append("sets is not an array")
		raw_sets = []
	for raw_value in raw_sets as Array:
		if not raw_value is Dictionary:
			validation_errors.append("set is not an object")
			continue
		var mission_set := (raw_value as Dictionary).duplicate(true)
		var id := String(mission_set.get("id", "")).strip_edges()
		if id == "" or _sets_by_id.has(id):
			validation_errors.append("duplicate or empty set id: %s" % id)
			continue
		if not EXPECTED_SET_IDS.has(id):
			validation_errors.append("unknown set id: %s" % id)
			continue
		var stage_id := String(mission_set.get("stageId", "")).strip_edges().to_lower()
		var mission_ids: Array = mission_set.get("missionIds", []) as Array
		if not VALID_NORMAL_STAGES.has(stage_id) and stage_id != "relay":
			validation_errors.append("set stage is invalid: %s" % id)
			continue
		if mission_ids.size() != 3:
			validation_errors.append("set mission count is invalid: %s" % id)
			continue
		var valid_mission_ids := true
		for mission_id_value in mission_ids:
			var mission_id := String(mission_id_value)
			if not _missions_by_id.has(mission_id) or String((_missions_by_id[mission_id] as Dictionary).get("stageId", "")) != stage_id:
				valid_mission_ids = false
		if not valid_mission_ids:
			validation_errors.append("set mission references are invalid: %s" % id)
			continue
		mission_set["id"] = id
		mission_set["version"] = int(mission_set.get("version", 0))
		mission_set["stageId"] = stage_id
		mission_set["missionIds"] = mission_ids.duplicate()
		mission_set["rewardPp"] = int(mission_set.get("rewardPp", 0))
		sets.append(mission_set)
		_sets_by_id[id] = mission_set
		_sets_by_stage[stage_id] = mission_set
	missions.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a.get("sortOrder", 0)) < int(b.get("sortOrder", 0)))
	sets.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a.get("sortOrder", 0)) < int(b.get("sortOrder", 0)))
	for id in EXPECTED_MISSION_IDS:
		if not _missions_by_id.has(id):
			validation_errors.append("missing mission id: %s" % id)
	for id in EXPECTED_SET_IDS:
		if not _sets_by_id.has(id):
			validation_errors.append("missing set id: %s" % id)
	is_valid = validation_errors.is_empty() and missions.size() == EXPECTED_MISSION_IDS.size() and sets.size() == EXPECTED_SET_IDS.size()

func mission_ids() -> Array[String]:
	var result: Array[String] = []
	for id in EXPECTED_MISSION_IDS:
		result.append(String(id))
	return result

func set_ids() -> Array[String]:
	var result: Array[String] = []
	for id in EXPECTED_SET_IDS:
		result.append(String(id))
	return result

func get_mission(id: String) -> Dictionary:
	var value: Variant = _missions_by_id.get(id.strip_edges(), {})
	return value.duplicate(true) as Dictionary if value is Dictionary else {}

func get_set(id: String) -> Dictionary:
	var value: Variant = _sets_by_id.get(id.strip_edges(), {})
	return value.duplicate(true) as Dictionary if value is Dictionary else {}

func stage_set(stage_id: String) -> Dictionary:
	var value: Variant = _sets_by_stage.get(stage_id.strip_edges().to_lower(), {})
	return value.duplicate(true) as Dictionary if value is Dictionary else {}

func missions_for_stage(stage_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for mission in missions:
		if String(mission.get("stageId", "")) == stage_id.strip_edges().to_lower():
			result.append(mission.duplicate(true))
	return result

func evaluate_mission(id: String, snapshot: Dictionary) -> bool:
	return evaluate_mission_data(get_mission(id), snapshot)

func evaluate_mission_data(mission: Dictionary, snapshot: Dictionary) -> bool:
	if mission.is_empty() or not is_valid:
		return false
	if not _official_formal_completion(snapshot):
		return false
	var difficulty_id := String(snapshot.get("difficultyId", snapshot.get("runDifficultyId", "normal"))).strip_edges().to_lower()
	var allowed: Array = mission.get("difficulty", []) as Array
	if not allowed.has(difficulty_id):
		return false
	var mission_stage := String(mission.get("stageId", "")).strip_edges().to_lower()
	var result_stage := String(snapshot.get("stageId", snapshot.get("streamFrameId", ""))).strip_edges().to_lower()
	if bool(snapshot.get("relayMode", false)) != (mission_stage == "relay"):
		return false
	if mission_stage == "relay":
		if result_stage != "relay":
			return false
	else:
		if result_stage == "" or result_stage != mission_stage:
			return false
	var params: Dictionary = mission.get("params", {}) as Dictionary
	match String(mission.get("conditionType", "")):
		"non_heart_comments":
			return int(snapshot.get("nonHeartCommentCount", 0)) >= int(params.get("count", 5))
		"risk_comments":
			return int(snapshot.get("riskCommentCount", snapshot.get("evaluationDangerousCommentCount", 0))) >= int(params.get("count", 5))
		"cumulative_damage_ratio":
			var reference := float(snapshot.get("evaluationReferenceMaxMental", 0.0))
			var damage := float(snapshot.get("evaluationCumulativeDamageTaken", -1.0))
			return reference > 0.0 and damage >= 0.0 and damage <= reference * float(params.get("maxRatio", 0.5)) + 0.0001
		"genre_no_hit":
			return int(snapshot.get("genreEventClearCount", 0)) >= int(params.get("count", 1))
		"weapon_slots":
			return _unique_weapon_count(snapshot) >= int(params.get("count", 3))
		"genre_no_hit_rank":
			return int(snapshot.get("genreEventClearCount", 0)) >= int(params.get("count", 1)) and _rank_in(snapshot, params.get("ranks", ["A", "S"]) as Array)
		"song_heat_level":
			return int(snapshot.get("songHeatLevelReached", snapshot.get("songMaxLiveHeatLevel", 0))) >= int(params.get("level", 5))
		"song_heat_playing_seconds":
			return float(snapshot.get("songLv5PlayingSeconds", 0.0)) >= float(params.get("seconds", 20.0)) - 0.0001
		"song_heat_boss":
			return bool(snapshot.get("songLv5BossDefeated", false)) and int(snapshot.get("songLv5BossHeatLevel", 0)) >= int(params.get("level", 5)) and _has_player_side_boss(snapshot, String(params.get("bossId", "pitch_police_chief")))
		"drawing_colors":
			return _bit_count(int(snapshot.get("drawingColorBits", 0))) >= int(params.get("count", 3))
		"drawing_fill":
			return int(snapshot.get("drawingFillCount", 0)) >= int(params.get("count", 1))
		"drawing_colors_boss":
			return _bit_count(int(snapshot.get("drawingColorBits", 0))) >= int(params.get("count", 3)) and _has_player_side_boss(snapshot, String(params.get("bossId", "redpen_retake_dragon")))
		"collab_challenge":
			return int(snapshot.get("collabChallengeSuccessCount", 0)) >= int(params.get("count", 1))
		"collab_pass":
			return int(snapshot.get("collabPassSuccessCount", 0)) >= int(params.get("count", 3))
		"collab_pair_boss":
			return int(snapshot.get("collabPairSkillCount", 0)) >= int(params.get("count", 1)) and _has_player_side_boss(snapshot, String(params.get("bossId", "collab_crusher")))
		"relay_final_preparation":
			return bool(snapshot.get("relayFinalPreparationReady", false)) and _snapshot_has_ready_weapon(snapshot, int(params.get("weaponLevel", 5)))
		"relay_mini_conditions":
			return _bit_count(int(snapshot.get("relayMiniConditionBits", 0))) >= int(params.get("count", 3))
		"relay_final_boss_rank":
			return _has_player_side_boss(snapshot, String(params.get("bossId", "last_offline"))) and _rank_in(snapshot, params.get("ranks", ["A", "S"]) as Array)
	return false

func evaluate_new(snapshot: Dictionary, completed_missions: Array, completed_sets: Array) -> Dictionary:
	var missions_after: Array = []
	for value in completed_missions:
		var id := String(value).strip_edges()
		if id != "" and not missions_after.has(id):
			missions_after.append(id)
	var newly_completed: Array[String] = []
	for id in EXPECTED_MISSION_IDS:
		if missions_after.has(id) or not evaluate_mission(id, snapshot):
			continue
		missions_after.append(id)
		newly_completed.append(id)
	var sets_after: Array = []
	for value in completed_sets:
		var id := String(value).strip_edges()
		if id != "" and not sets_after.has(id):
			sets_after.append(id)
	var newly_completed_sets: Array[String] = []
	for id in EXPECTED_SET_IDS:
		if sets_after.has(id):
			continue
		var mission_set := get_set(id)
		var all_set_missions := true
		for mission_id_value in mission_set.get("missionIds", []) as Array:
			if not missions_after.has(String(mission_id_value)):
				all_set_missions = false
		if all_set_missions:
			sets_after.append(id)
			newly_completed_sets.append(id)
	var progress := stage_progress_for_snapshot(snapshot, missions_after)
	var all_complete := true
	for id in EXPECTED_MISSION_IDS:
		if not missions_after.has(id):
			all_complete = false
	return {
		"newMissionIds": newly_completed,
		"newSetIds": newly_completed_sets,
		"completedStreamMissions": missions_after,
		"completedStageMissionSets": sets_after,
		"allMissionsComplete": all_complete,
		"missionPp": newly_completed.size() * 50,
		"setPp": newly_completed_sets.size() * 100,
		"stageProgress": progress
	}

func stage_progress(stage_id: String, completed_missions: Array) -> Dictionary:
	var normalized_stage := stage_id.strip_edges().to_lower()
	var mission_set := stage_set(normalized_stage)
	var completed := 0
	for id_value in mission_set.get("missionIds", []) as Array:
		if completed_missions.has(String(id_value)):
			completed += 1
	return {"stageId": normalized_stage, "completed": completed, "total": 3, "complete": completed >= 3}

func stage_progress_for_snapshot(_snapshot: Dictionary, completed_missions: Array) -> Dictionary:
	var result := {}
	for stage_id in ["zatsudan", "gameplay", "singing", "drawing", "collab", "relay"]:
		result[stage_id] = stage_progress(stage_id, completed_missions)
	return result

func build_result_snapshot(result: Dictionary, tracker) -> Dictionary:
	var snapshot := result.duplicate(true)
	if tracker != null and tracker.has_method("to_dictionary"):
		snapshot.merge(tracker.to_dictionary(), true)
	# Result scope is authoritative: a relay tracker moves through segment IDs,
	# while the formal result must evaluate the run as the relay as a whole.
	snapshot["stageId"] = String(result.get("stageId", result.get("streamFrameId", snapshot.get("stageId", ""))))
	snapshot["difficultyId"] = String(result.get("difficultyId", result.get("runDifficultyId", snapshot.get("difficultyId", "normal"))))
	snapshot["relayMode"] = bool(result.get("relayMode", snapshot.get("relayMode", false)))
	var weapons: Variant = result.get("weapons", [])
	if weapons is Array:
		snapshot["finalWeapons"] = (weapons as Array).duplicate(true)
	# The final relay boss is a formal player-side record, not merely a result
	# label.  Derive this convenience flag from the immutable tracker snapshot.
	snapshot["relayFinalBossPlayerDefeated"] = _has_player_side_boss(snapshot, "last_offline")
	return snapshot

func _official_formal_completion(snapshot: Dictionary) -> bool:
	if not bool(snapshot.get("officialRunEligible", false)) or bool(snapshot.get("debugContaminated", false)) or bool(snapshot.get("quickTestMode", false)) or not bool(snapshot.get("formalMenuOrigin", false)):
		return false
	var difficulty_id := String(snapshot.get("difficultyId", snapshot.get("runDifficultyId", "normal"))).strip_edges().to_lower()
	if not VALID_DIFFICULTIES.has(difficulty_id):
		return false
	if String(snapshot.get("endType", "")) != "completed":
		return false
	if bool(snapshot.get("relayMode", false)):
		var completed_frames: Variant = snapshot.get("relayCompletedFrameIds", [])
		return bool(snapshot.get("relayFinalBossPlayerDefeated", false)) and bool(snapshot.get("relayBossScoreAwarded", snapshot.get("relayFinalBossDefeated", false))) and completed_frames is Array and (completed_frames as Array) == EXPECTED_RELAY_FRAME_IDS
	return bool(snapshot.get("cleared", false))

func _unique_weapon_count(snapshot: Dictionary) -> int:
	var values: Variant = snapshot.get("finalWeapons", snapshot.get("weapons", []))
	if not values is Array:
		return 0
	var ids: Dictionary = {}
	for value in values as Array:
		if not value is Dictionary:
			continue
		var entry := value as Dictionary
		var id := String(entry.get("id", "")).strip_edges()
		if id == "":
			continue
		var base_id := String(entry.get("baseWeaponId", "")).strip_edges()
		var key := base_id if base_id != "" else id
		ids[key] = true
	return ids.size()

func _snapshot_has_ready_weapon(snapshot: Dictionary, required_level: int) -> bool:
	if not bool(snapshot.get("relayFinalPreparationReady", false)):
		return false
	var prep: Variant = snapshot.get("relayFinalPreparationSnapshot", {})
	if not prep is Dictionary:
		return false
	var entries: Variant = (prep as Dictionary).get("weapons", [])
	if not entries is Array:
		return false
	for value in entries as Array:
		if not value is Dictionary:
			continue
		var entry := value as Dictionary
		var level_text := str(entry.get("level", ""))
		if bool(entry.get("isEvolved", false)) or level_text in ["evolved", "進化"] or int(entry.get("level", 0)) >= required_level:
			return true
	return false

func _has_player_side_boss(snapshot: Dictionary, boss_id: String) -> bool:
	var values: Variant = snapshot.get("playerSideBossDefeats", [])
	if values is Array:
		for value in values as Array:
			if String(value) == boss_id:
				return true
	return false

func _rank_in(snapshot: Dictionary, allowed: Array) -> bool:
	var rank := String(snapshot.get("evaluationRank", snapshot.get("rank", "D"))).strip_edges().to_upper()
	return allowed.has(rank)

func _bit_count(value: int) -> int:
	var count := 0
	var bits := value
	while bits != 0:
		count += bits & 1
		bits = bits >> 1
	return count
