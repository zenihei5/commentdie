extends Node

const Difficulty := preload("res://scripts/systems/difficulty_progress_system.gd")
const ResultSystem := preload("res://scripts/systems/result_system.gd")

func _ready() -> void:
	var failures: Array[String] = []
	var progress: Dictionary = Difficulty.create_default_save_data([])
	_check(Difficulty.selected_difficulty(progress) == "normal", "default difficulty", failures)
	_check(not Difficulty.can_unlock_relay(progress, "normal"), "default relay locked", failures)

	for stage_id in Difficulty.STANDARD_STAGE_IDS:
		if stage_id == Difficulty.STAGE_COLLAB:
			break
		Difficulty.record_single_stage_result(progress, {"difficulty": "normal", "stageId": stage_id, "cleared": true, "score": 100})
	Difficulty.evaluate_all_unlocks(progress)
	_check(not Difficulty.can_unlock_relay(progress, "normal"), "normal 4 of 5 relay locked", failures)
	Difficulty.record_single_stage_result(progress, {"difficulty": "normal", "stageId": Difficulty.STAGE_COLLAB, "cleared": true, "score": 200})
	Difficulty.evaluate_all_unlocks(progress)
	_check(Difficulty.can_unlock_relay(progress, "normal"), "normal 5 of 5 relay unlocked", failures)

	Difficulty.record_relay_result(progress, {"difficulty": "normal", "reachedSection": 5, "finalBossDefeated": false})
	Difficulty.evaluate_all_unlocks(progress)
	_check(not Difficulty.can_unlock_hard(progress), "relay reach does not unlock hard", failures)
	Difficulty.record_relay_result(progress, {"difficulty": "normal", "reachedSection": 5, "finalBossDefeated": true})
	Difficulty.evaluate_all_unlocks(progress)
	_check(bool(Difficulty._dict(progress.difficulties.hard).get("unlocked", false)), "normal relay boss unlocks hard", failures)

	for stage_id in Difficulty.STANDARD_STAGE_IDS:
		Difficulty.record_single_stage_result(progress, {"difficulty": "hard", "stageId": stage_id, "cleared": true})
	Difficulty.evaluate_all_unlocks(progress)
	_check(Difficulty.can_unlock_relay(progress, "hard"), "hard 5 of 5 relay unlocked", failures)
	Difficulty.record_relay_result(progress, {"difficulty": "hard", "reachedSection": 5, "finalBossDefeated": false})
	Difficulty.evaluate_all_unlocks(progress)
	_check(not bool(Difficulty._dict(progress.difficulties.expert).get("unlocked", false)), "hard relay reach keeps expert locked", failures)
	Difficulty.record_relay_result(progress, {"difficulty": "hard", "reachedSection": 5, "finalBossDefeated": true})
	Difficulty.evaluate_all_unlocks(progress)
	_check(bool(Difficulty._dict(progress.difficulties.expert).get("unlocked", false)), "hard relay boss unlocks expert", failures)

	var config := {"modes": {"normal": {"implemented": true}, "hard": {"implemented": true}, "expert": {"implemented": false}}}
	_check(not Difficulty.gameplay_implemented(config, "expert"), "expert combat gate", failures)
	_check(is_equal_approx(Difficulty.duration_for("normal", false, false, {}, {"modes": {"normal": {"singleDurationSeconds": 180.0}}}), 180.0), "single duration", failures)
	_check(is_equal_approx(Difficulty.duration_for("hard", true, false, {"segmentDuration": 120.0}, {}), 120.0), "relay section duration", failures)
	_check(is_inf(Difficulty.duration_for("hard", true, true, {"segmentDuration": 120.0}, {})), "relay final boss unlimited", failures)
	_check(not ResultSystem._is_relay_completed({"relayClearedFrameCount": 5, "streamFrameId": "collab", "relayBossScoreAwarded": false}), "relay arrival is not clear", failures)
	_check(ResultSystem._is_relay_completed({"relayBossScoreAwarded": true}), "relay boss defeat is clear", failures)

	var ui: Dictionary = progress.stageSelectUi
	ui["selectedDifficulty"] = "hard"
	var last: Dictionary = ui.lastSelectedStageByDifficulty
	last["hard"] = "gameplay"
	ui["lastSelectedStageByDifficulty"] = last
	progress["stageSelectUi"] = ui
	_check(Difficulty.last_selected_stage(progress, "hard") == "gameplay", "difficulty-specific selection position", failures)
	_check(Difficulty.last_selected_stage(progress, "normal") == "zatsudan", "normal position does not mix", failures)
	_check(int(Difficulty._dict(Difficulty._dict(progress.difficulties).normal.stages.zatsudan).get("bestScore", 0)) == 100, "normal best score", failures)
	_check(int(Difficulty._dict(Difficulty._dict(progress.difficulties).hard.stages.zatsudan).get("bestScore", 0)) == 0, "difficulty best scores isolated", failures)

	var first_relay_progress := Difficulty.create_default_save_data([])
	Difficulty.record_relay_result(first_relay_progress, {"difficulty": "normal", "reachedSection": 1, "reachedStageId": "gameplay"})
	var first_relay_state := Difficulty._dict(Difficulty._dict(first_relay_progress.difficulties).normal.relay)
	_check(String(first_relay_state.get("bestReachedStageId", "")) == "gameplay", "first relay stage stores over the null default", failures)
	var repeated_relay_record := Difficulty.record_relay_result(first_relay_progress, {"difficulty": "normal", "reachedSection": 1, "reachedStageId": "gameplay"})
	_check(not bool(repeated_relay_record.get("changed", true)), "same relay stage does not record twice", failures)

	var legacy := {"streamFrameProgress": {"talk": {"isUnlocked": true, "isCleared": true, "bestViewerCount": 42}}, "relayModeUnlocked": true}
	var migrated: Dictionary = Difficulty.migrate_save_data(legacy, [])
	_check(bool(Difficulty._dict(Difficulty._dict(migrated.difficulties).normal.stages.zatsudan).get("cleared", false)), "legacy talk alias migration", failures)
	_check(bool(Difficulty._dict(Difficulty._dict(migrated.difficulties).normal.relay).get("unlocked", false)), "legacy relay flag migration", failures)

	var corrupted := {"difficulties": {"normal": {"unlocked": "not-a-bool", "stages": {"talk": {"cleared": "yes", "bestScore": -99, "clearCharacterIds": ["a", "a", 7]}}}}, "stageSelectUi": {"selectedDifficulty": "unknown", "lastSelectedStageByDifficulty": {"hard": "unknown"}}}
	var normalized: Dictionary = Difficulty._normalize_save(Difficulty.create_default_save_data([]), corrupted)
	_check(bool(Difficulty._dict(Difficulty._dict(normalized.difficulties).normal.stages.zatsudan).get("cleared", false)), "corrupt boolean normalization", failures)
	_check(int(Difficulty._dict(Difficulty._dict(normalized.difficulties).normal.stages.zatsudan).get("bestScore", 0)) == 0, "negative score normalization", failures)
	_check(Difficulty.last_selected_stage(normalized, "hard") == "zatsudan", "missing selection normalization", failures)

	if failures.is_empty():
		print("difficulty progress tests passed")
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error(failure)
		get_tree().quit(1)

func _check(condition: bool, message: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(message)
