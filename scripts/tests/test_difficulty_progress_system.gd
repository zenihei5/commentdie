extends Node

const Difficulty := preload("res://scripts/systems/difficulty_progress_system.gd")
const ResultSystem := preload("res://scripts/systems/result_system.gd")

func _ready() -> void:
	var failures: Array[String] = []
	var progress: Dictionary = Difficulty.create_default_save_data([])
	_check(Difficulty.selected_difficulty(progress) == "normal", "default difficulty", failures)
	_check(not Difficulty.can_unlock_relay(progress, "normal"), "default relay locked", failures)
	_check(Difficulty.stage_display_name(Difficulty.STAGE_RELAY) == "配信リレー", "relay stage display fallback", failures)
	_check_relay_views(failures)

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
	for stage_id in Difficulty.STANDARD_STAGE_IDS:
		var expert_card := Difficulty.get_stage_card_state(progress, "expert", stage_id)
		_check(bool(expert_card.get("selectable", false)), "expert standard stage selectable after unlock: %s" % stage_id, failures)
		Difficulty.record_single_stage_result(progress, {"difficulty": "expert", "stageId": stage_id, "cleared": true, "score": 300})
	Difficulty.evaluate_all_unlocks(progress)
	_check(Difficulty.can_unlock_relay(progress, "expert"), "expert 5 of 5 relay unlocked", failures)
	Difficulty.record_relay_result(progress, {"difficulty": "expert", "reachedSection": 4, "reachedStageId": "drawing", "finalBossPhase": 2, "finalBossDefeated": false})
	var expert_relay_after_game_over := Difficulty._dict(Difficulty._dict(progress.difficulties).expert.relay)
	_check(int(expert_relay_after_game_over.get("bestReachedSection", 0)) == 4 and int(expert_relay_after_game_over.get("bestFinalBossPhase", 0)) == 2 and not bool(expert_relay_after_game_over.get("cleared", false)), "expert relay game over progress is recorded", failures)
	Difficulty.record_relay_result(progress, {"difficulty": "expert", "reachedSection": 5, "reachedStageId": "collab", "finalBossPhase": 3, "finalBossDefeated": true})
	_check(bool(Difficulty._dict(Difficulty._dict(progress.difficulties).expert.relay).get("finalBossDefeated", false)) and bool(Difficulty._dict(Difficulty._dict(progress.difficulties).expert.relay).get("cleared", false)), "expert relay final boss clear is saved", failures)

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
	_check(not bool(Difficulty._dict(migrated.difficulties).expert.get("unlocked", false)) and not bool(Difficulty._dict(Difficulty._dict(migrated.difficulties).expert.relay).get("cleared", false)), "legacy missing expert initializes locked", failures)

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

func _check_relay_views(failures: Array[String]) -> void:
	var expected_description := "5つの配信枠を各120秒ずつ連続で進み、最後に時間制限なしの最終ボスへ挑みます。区間の合間には休憩が入り、回復やギフトを選択できます。"
	var expected_recommend := "5つの配信枠を連続で走り切る、総仕上げの特別モードです。"
	var expected_unlock := "通常5枠をすべてクリアすると解禁されます。"
	var forbidden := ["Relay", "RELAY", "sections", "transitions", "final boss", "HARD relay", "Clear all five", "Standard stages cleared"]
	for difficulty_id in Difficulty.DIFFICULTY_IDS:
		var progress: Dictionary = Difficulty.create_default_save_data([])
		var difficulties: Dictionary = progress["difficulties"] as Dictionary
		var data: Dictionary = difficulties[difficulty_id] as Dictionary
		var relay: Dictionary = data["relay"] as Dictionary
		data["unlocked"] = true
		relay["unlocked"] = false
		relay["cleared"] = false
		var locked: Dictionary = Difficulty._relay_frame(progress, difficulty_id, relay, {})
		_check_relay_view(locked, "relay_locked", "未解禁", expected_description, expected_unlock, "", failures)
		data["unlocked"] = true
		relay["unlocked"] = true
		relay["cleared"] = false
		var selectable: Dictionary = Difficulty._relay_frame(progress, difficulty_id, relay, {})
		_check_relay_view(selectable, "selectable", "挑戦可能", expected_description, "", expected_recommend, failures)
		relay["cleared"] = true
		var cleared: Dictionary = Difficulty._relay_frame(progress, difficulty_id, relay, {})
		_check_relay_view(cleared, "relay_cleared", "クリア", expected_description, "", expected_recommend, failures)
		for view in [locked, selectable, cleared]:
			for key in ["displayName", "plainName", "detailTitle", "description", "features", "shortFeatures", "mainGimmicks", "recommendText", "unlockConditionText", "disabledReason", "statusText"]:
				var visible := String(view.get(key, "")) if not (view.get(key, null) is Array) else " / ".join(view.get(key) as Array)
				for token in forbidden:
					_check(token not in visible, "%s relay view contains forbidden token %s" % [difficulty_id, token], failures)
		data["unlocked"] = false
		relay["unlocked"] = false
		relay["cleared"] = false
		var difficulty_locked: Dictionary = Difficulty._relay_frame(progress, difficulty_id, relay, {})
		var expected_condition := "NORMALの配信リレーをクリアするとHARDが解禁されます。" if difficulty_id == Difficulty.DIFFICULTY_HARD else ("HARDの配信リレーをクリアするとEXPERTが解禁されます。" if difficulty_id == Difficulty.DIFFICULTY_EXPERT else "NORMALは最初から解禁されています。")
		_check(String(difficulty_locked.get("statusText", "")) == "未解禁", "%s difficulty-locked relay status" % difficulty_id, failures)
		_check(String(difficulty_locked.get("unlockConditionText", "")) == expected_condition, "%s difficulty-locked relay condition" % difficulty_id, failures)
		_check(String(difficulty_locked.get("disabledReason", "")) == expected_condition, "%s difficulty-locked relay disabled reason" % difficulty_id, failures)

func _check_relay_view(view: Dictionary, expected_status_id: String, expected_status: String, expected_description: String, expected_unlock: String, expected_recommend: String, failures: Array[String]) -> void:
	_check(String(view.get("statusId", "")) == expected_status_id, "%s relay status id" % expected_status_id, failures)
	_check(String(view.get("statusText", "")) == expected_status, "%s relay status text" % expected_status_id, failures)
	_check(String(view.get("displayName", "")) == "配信リレー" and String(view.get("plainName", "")) == "配信リレー" and String(view.get("detailTitle", "")) == "配信リレー", "%s relay names" % expected_status_id, failures)
	_check(String(view.get("description", "")) == expected_description, "%s relay description" % expected_status_id, failures)
	_check((view.get("features", []) as Array) == ["5区間", "各120秒"] and (view.get("shortFeatures", []) as Array) == ["5区間", "各120秒"], "%s relay features" % expected_status_id, failures)
	_check((view.get("mainGimmicks", []) as Array) == ["5枠連続", "休憩", "最終ボス"], "%s relay gimmicks" % expected_status_id, failures)
	_check(String(view.get("unlockConditionText", "")) == expected_unlock, "%s relay unlock condition" % expected_status_id, failures)
	_check(String(view.get("disabledReason", "")) == expected_unlock, "%s relay disabled reason" % expected_status_id, failures)
	_check(String(view.get("recommendText", "")) == expected_recommend, "%s relay recommendation" % expected_status_id, failures)
