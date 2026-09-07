extends Node

const DatabaseScript := preload("res://scripts/systems/power_up_database.gd")
const SaveStoreScript := preload("res://scripts/systems/power_up_save_store.gd")
const ShopManagerScript := preload("res://scripts/systems/power_up_shop_manager.gd")
const RewardCalculatorScript := preload("res://scripts/systems/stream_point_reward_calculator.gd")
const MissionSystemScript := preload("res://scripts/systems/stream_mission_system.gd")
const TrackerScript := preload("res://scripts/systems/stream_mission_run_tracker.gd")
const ResultSystemScript := preload("res://scripts/systems/result_system.gd")

var test_root := ""
var failures: Array[String] = []
var checks := 0
var save_calls := 0
var save_should_fail := false
var database
var mission_system

func _ready() -> void:
	test_root = OS.get_environment("COMMENTDIE_STREAM_MISSION_TEST_ROOT").replace("\\", "/").trim_suffix("/")
	if test_root == "":
		test_root = OS.get_user_data_dir().replace("\\", "/")
	if not test_root.is_absolute_path():
		test_root = ProjectSettings.globalize_path(test_root).replace("\\", "/")
	DirAccess.make_dir_recursive_absolute(test_root)
	database = DatabaseScript.load_default()
	mission_system = MissionSystemScript.load_default()
	_test_master_contract()
	_test_boundaries()
	_test_formal_guards()
	_test_tracker_recording()
	_test_transaction_retry_and_title()
	_test_schema_compatibility_and_economics()
	var report := {"checks": checks, "failures": failures}
	var report_file := FileAccess.open(test_root.path_join("stream-mission-results.json"), FileAccess.WRITE)
	if report_file != null:
		report_file.store_string(JSON.stringify(report, "\t"))
		report_file.close()
	for failure in failures:
		push_error(failure)
	print("STREAM_MISSION_V1_TESTS: %s (%d checks, %d failures)" % ["PASS" if failures.is_empty() else "FAIL", checks, failures.size()])
	get_tree().quit(0 if failures.is_empty() else 1)

func _check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures.append(label)

func _check_equal(actual: Variant, expected: Variant, label: String) -> void:
	_check(actual == expected, "%s (actual=%s expected=%s)" % [label, str(actual), str(expected)])

func _test_master_contract() -> void:
	_check(database.is_valid, "power-up database remains valid")
	_check(mission_system.is_valid, "stream mission master is valid")
	_check_equal(mission_system.mission_ids().size(), 18, "master has exactly 18 missions")
	_check_equal(mission_system.set_ids().size(), 6, "master has exactly 6 mission sets")
	_check_equal(mission_system.mission_ids(), [
		"TALK-1", "TALK-2", "TALK-3", "GAME-1", "GAME-2", "GAME-3",
		"SONG-1", "SONG-2", "SONG-3", "DRAW-1", "DRAW-2", "DRAW-3",
		"COLLAB-1", "COLLAB-2", "COLLAB-3", "RELAY-1", "RELAY-2", "RELAY-3"
	], "mission IDs match the frozen V1 list")
	_check_equal(mission_system.set_ids(), ["v1:talk", "v1:game", "v1:song", "v1:drawing", "v1:collab", "v1:relay"], "set IDs are versioned")
	for mission_id in mission_system.mission_ids():
		var mission: Dictionary = mission_system.get_mission(mission_id)
		_check_equal(int(mission.get("rewardPp", 0)), 50, "%s reward is 50 PP" % mission_id)
	for set_id in mission_system.set_ids():
		var mission_set: Dictionary = mission_system.get_set(set_id)
		_check_equal(int(mission_set.get("version", 0)), 1, "%s is version 1" % set_id)
		_check_equal(int(mission_set.get("rewardPp", 0)), 100, "%s reward is 100 PP" % set_id)

func _formal_snapshot(stage_id: String, difficulty_id: String = "normal", relay: bool = false) -> Dictionary:
	var snapshot := {
		"officialRunEligible": true,
		"debugContaminated": false,
		"formalMenuOrigin": true,
		"quickTestMode": false,
		"endType": "completed",
		"cleared": true,
		"stageId": stage_id,
		"difficultyId": difficulty_id,
		"relayMode": relay,
		"evaluationReferenceMaxMental": 100.0,
		"evaluationCumulativeDamageTaken": 0.0,
		"evaluationRank": "A",
		"relayCompletedFrameIds": []
	}
	if relay:
		snapshot["relayFinalBossPlayerDefeated"] = true
		snapshot["relayBossScoreAwarded"] = true
		snapshot["relayCompletedFrameIds"] = ["zatsudan", "gameplay", "singing", "drawing", "collab"]
	return snapshot

func _evaluate(mission_id: String, snapshot: Dictionary) -> bool:
	return mission_system.evaluate_mission(mission_id, snapshot)

func _test_boundaries() -> void:
	var snapshot := _formal_snapshot("zatsudan", "normal")
	snapshot["nonHeartCommentCount"] = 4
	_check(not _evaluate("TALK-1", snapshot), "TALK-1 before boundary fails")
	snapshot["nonHeartCommentCount"] = 5
	_check(_evaluate("TALK-1", snapshot), "TALK-1 exact boundary passes")
	snapshot["nonHeartCommentCount"] = 6
	_check(_evaluate("TALK-1", snapshot), "TALK-1 over boundary passes")
	snapshot["riskCommentCount"] = 4
	_check(not _evaluate("TALK-2", snapshot), "TALK-2 before boundary fails")
	snapshot["riskCommentCount"] = 5
	_check(_evaluate("TALK-2", snapshot), "TALK-2 exact boundary passes")
	snapshot["riskCommentCount"] = 6
	_check(_evaluate("TALK-2", snapshot), "TALK-2 over boundary passes")
	snapshot["difficultyId"] = "hard"
	snapshot["evaluationCumulativeDamageTaken"] = 50.01
	_check(not _evaluate("TALK-3", snapshot), "TALK-3 damage over 50 percent fails")
	snapshot["evaluationCumulativeDamageTaken"] = 50.0
	_check(_evaluate("TALK-3", snapshot), "TALK-3 exact 50 percent passes")
	snapshot["evaluationCumulativeDamageTaken"] = 49.99
	_check(_evaluate("TALK-3", snapshot), "TALK-3 under 50 percent passes")
	snapshot = _formal_snapshot("gameplay", "normal")
	snapshot["genreEventClearCount"] = 0
	_check(not _evaluate("GAME-1", snapshot), "GAME-1 before boundary fails")
	snapshot["genreEventClearCount"] = 1
	_check(_evaluate("GAME-1", snapshot), "GAME-1 exact boundary passes")
	snapshot["genreEventClearCount"] = 2
	_check(_evaluate("GAME-1", snapshot), "GAME-1 over boundary passes")
	snapshot["finalWeapons"] = [{"id": "ban_hammer"}, {"id": "comment_pin"}]
	_check(not _evaluate("GAME-2", snapshot), "GAME-2 two weapons fails")
	snapshot["finalWeapons"] = [{"id": "ban_hammer"}, {"id": "comment_pin"}, {"id": "ban_hammer", "level": 5}, {"id": "wide_angle"}]
	_check(_evaluate("GAME-2", snapshot), "GAME-2 counts distinct weapons, not duplicate levels")
	snapshot["finalWeapons"] = [{"id": "ban_hammer"}, {"id": "comment_pin"}, {"id": "wide_angle"}, {"id": "fansa_baton"}]
	_check(_evaluate("GAME-2", snapshot), "GAME-2 over boundary passes")
	snapshot["difficultyId"] = "hard"
	snapshot["genreEventClearCount"] = 0
	_check(not _evaluate("GAME-3", snapshot), "GAME-3 before event boundary fails")
	snapshot["genreEventClearCount"] = 1
	snapshot["evaluationRank"] = "B"
	_check(not _evaluate("GAME-3", snapshot), "GAME-3 rank below A fails")
	snapshot["evaluationRank"] = "A"
	_check(_evaluate("GAME-3", snapshot), "GAME-3 exact event plus A passes")
	snapshot["evaluationRank"] = "S"
	_check(_evaluate("GAME-3", snapshot), "GAME-3 S rank passes")
	snapshot = _formal_snapshot("singing", "normal")
	snapshot["songHeatLevelReached"] = 4
	_check(not _evaluate("SONG-1", snapshot), "SONG-1 Lv4 fails")
	snapshot["songHeatLevelReached"] = 5
	_check(_evaluate("SONG-1", snapshot), "SONG-1 Lv5 exact passes")
	snapshot["songHeatLevelReached"] = 6
	_check(_evaluate("SONG-1", snapshot), "SONG-1 over boundary passes")
	snapshot["songLv5PlayingSeconds"] = 19.99
	_check(not _evaluate("SONG-2", snapshot), "SONG-2 before 20 seconds fails")
	snapshot["songLv5PlayingSeconds"] = 20.0
	_check(_evaluate("SONG-2", snapshot), "SONG-2 exact 20 seconds passes")
	snapshot["songLv5PlayingSeconds"] = 20.01
	_check(_evaluate("SONG-2", snapshot), "SONG-2 over boundary passes")
	snapshot["difficultyId"] = "hard"
	snapshot["songLv5BossDefeated"] = true
	snapshot["songLv5BossHeatLevel"] = 4
	snapshot["playerSideBossDefeats"] = ["pitch_police_chief"]
	_check(not _evaluate("SONG-3", snapshot), "SONG-3 boss below Lv5 fails")
	snapshot["songLv5BossHeatLevel"] = 5
	_check(_evaluate("SONG-3", snapshot), "SONG-3 player-side Lv5 boss passes")
	snapshot = _formal_snapshot("drawing", "normal")
	snapshot["drawingColorBits"] = 1 | 2
	_check(not _evaluate("DRAW-1", snapshot), "DRAW-1 two normal colors fails")
	snapshot["drawingColorBits"] = 1 | 2 | 4
	_check(_evaluate("DRAW-1", snapshot), "DRAW-1 exact three colors passes")
	snapshot["drawingColorBits"] = 1 | 2 | 4 | 8
	_check(_evaluate("DRAW-1", snapshot), "DRAW-1 four colors passes")
	snapshot["drawingFillCount"] = 0
	_check(not _evaluate("DRAW-2", snapshot), "DRAW-2 before fill fails")
	snapshot["drawingFillCount"] = 1
	_check(_evaluate("DRAW-2", snapshot), "DRAW-2 exact fill passes")
	snapshot["drawingFillCount"] = 2
	_check(_evaluate("DRAW-2", snapshot), "DRAW-2 over fill passes")
	snapshot["difficultyId"] = "hard"
	snapshot["playerSideBossDefeats"] = []
	_check(not _evaluate("DRAW-3", snapshot), "DRAW-3 without boss fails")
	snapshot["playerSideBossDefeats"] = ["redpen_retake_dragon"]
	_check(_evaluate("DRAW-3", snapshot), "DRAW-3 colors plus player-side boss passes")
	snapshot = _formal_snapshot("collab", "normal")
	snapshot["collabChallengeSuccessCount"] = 0
	_check(not _evaluate("COLLAB-1", snapshot), "COLLAB-1 before boundary fails")
	snapshot["collabChallengeSuccessCount"] = 1
	_check(_evaluate("COLLAB-1", snapshot), "COLLAB-1 exact boundary passes")
	snapshot["collabChallengeSuccessCount"] = 2
	_check(_evaluate("COLLAB-1", snapshot), "COLLAB-1 over boundary passes")
	snapshot["collabPassSuccessCount"] = 2
	_check(not _evaluate("COLLAB-2", snapshot), "COLLAB-2 before boundary fails")
	snapshot["collabPassSuccessCount"] = 3
	_check(_evaluate("COLLAB-2", snapshot), "COLLAB-2 exact boundary passes")
	snapshot["collabPassSuccessCount"] = 4
	_check(_evaluate("COLLAB-2", snapshot), "COLLAB-2 over boundary passes")
	snapshot["difficultyId"] = "hard"
	snapshot["collabPairSkillCount"] = 1
	snapshot["playerSideBossDefeats"] = ["collab_crusher"]
	_check(_evaluate("COLLAB-3", snapshot), "COLLAB-3 pair skill plus player-side boss passes")
	snapshot["collabPairSkillCount"] = 0
	_check(not _evaluate("COLLAB-3", snapshot), "COLLAB-3 without pair skill fails")
	snapshot = _formal_snapshot("relay", "normal", true)
	snapshot["relayFinalPreparationReady"] = true
	snapshot["relayFinalPreparationSnapshot"] = {"weapons": [{"id": "ban_hammer", "level": 4}]}
	_check(not _evaluate("RELAY-1", snapshot), "RELAY-1 entry Lv4 fails")
	snapshot["relayFinalPreparationSnapshot"] = {"weapons": [{"id": "ban_hammer", "level": 5}]}
	_check(_evaluate("RELAY-1", snapshot), "RELAY-1 entry Lv5 passes")
	snapshot["relayFinalPreparationSnapshot"] = {"weapons": [{"id": "ban_hammer", "isEvolved": true}]}
	_check(_evaluate("RELAY-1", snapshot), "RELAY-1 evolved entry passes")
	snapshot["relayMiniConditionBits"] = 1 | 2
	_check(not _evaluate("RELAY-2", snapshot), "RELAY-2 two mini conditions fails")
	snapshot["relayMiniConditionBits"] = 1 | 2 | 4
	_check(_evaluate("RELAY-2", snapshot), "RELAY-2 exact three mini conditions passes")
	snapshot["relayMiniConditionBits"] = 1 | 2 | 4 | 8 | 16
	_check(_evaluate("RELAY-2", snapshot), "RELAY-2 five mini conditions passes")
	snapshot["difficultyId"] = "hard"
	snapshot["playerSideBossDefeats"] = []
	_check(not _evaluate("RELAY-3", snapshot), "RELAY-3 without final player-side boss fails")
	snapshot["playerSideBossDefeats"] = ["last_offline"]
	snapshot["evaluationRank"] = "B"
	_check(not _evaluate("RELAY-3", snapshot), "RELAY-3 rank below A fails")
	snapshot["evaluationRank"] = "A"
	_check(_evaluate("RELAY-3", snapshot), "RELAY-3 exact A rank passes")
	# Every normal mission is available on NORMAL; every third mission is HARD+ only.
	for mission_id in ["TALK-1", "TALK-2", "GAME-1", "GAME-2", "SONG-1", "SONG-2", "DRAW-1", "DRAW-2", "COLLAB-1", "COLLAB-2", "RELAY-1", "RELAY-2"]:
		var normal_snapshot := _formal_snapshot("relay" if mission_id.begins_with("RELAY") else String(mission_system.get_mission(mission_id).get("stageId", "")), "normal", mission_id.begins_with("RELAY"))
		var mission: Dictionary = mission_system.get_mission(mission_id)
		match String(mission.get("conditionType", "")):
			"non_heart_comments": normal_snapshot["nonHeartCommentCount"] = 5
			"risk_comments": normal_snapshot["riskCommentCount"] = 5
			"genre_no_hit": normal_snapshot["genreEventClearCount"] = 1
			"weapon_slots": normal_snapshot["finalWeapons"] = [{"id": "a"}, {"id": "b"}, {"id": "c"}]
			"song_heat_level": normal_snapshot["songHeatLevelReached"] = 5
			"song_heat_playing_seconds": normal_snapshot["songLv5PlayingSeconds"] = 20.0
			"drawing_colors": normal_snapshot["drawingColorBits"] = 1 | 2 | 4
			"drawing_fill": normal_snapshot["drawingFillCount"] = 1
			"collab_challenge": normal_snapshot["collabChallengeSuccessCount"] = 1
			"collab_pass": normal_snapshot["collabPassSuccessCount"] = 3
			"relay_final_preparation":
				normal_snapshot["relayFinalPreparationReady"] = true
				normal_snapshot["relayFinalPreparationSnapshot"] = {"weapons": [{"id": "a", "level": 5}]}
			"relay_mini_conditions": normal_snapshot["relayMiniConditionBits"] = 1 | 2 | 4
		_check(_evaluate(mission_id, normal_snapshot), "%s normal mission is available on normal" % mission_id)
	for mission_id in ["TALK-3", "GAME-3", "SONG-3", "DRAW-3", "COLLAB-3", "RELAY-3"]:
		var third: Dictionary = mission_system.get_mission(mission_id)
		var hard_stage := String(third.get("stageId", ""))
		var hard_snapshot := _formal_snapshot(hard_stage, "hard", hard_stage == "relay")
		var normal_snapshot := hard_snapshot.duplicate(true)
		normal_snapshot["difficultyId"] = "normal"
		_check(not _evaluate(mission_id, normal_snapshot), "%s fails on normal" % mission_id)
		_check(third.get("difficulty", []) == ["hard", "expert"], "%s is explicitly HARD+" % mission_id)

func _test_formal_guards() -> void:
	var snapshot := _formal_snapshot("zatsudan", "normal")
	snapshot["nonHeartCommentCount"] = 99
	_check(_evaluate("TALK-1", snapshot), "formal baseline passes")
	for field in ["debugContaminated", "quickTestMode", "formalMenuOrigin"]:
		var contaminated := snapshot.duplicate(true)
		contaminated[field] = false if field == "formalMenuOrigin" else true
		_check(not _evaluate("TALK-1", contaminated), "formal guard rejects %s" % field)
	var incomplete := snapshot.duplicate(true)
	incomplete["endType"] = "mental_breakdown"
	_check(not _evaluate("TALK-1", incomplete), "formal guard rejects non-completed end")
	incomplete = snapshot.duplicate(true)
	incomplete["cleared"] = false
	_check(not _evaluate("TALK-1", incomplete), "formal guard rejects uncleared normal result")
	incomplete = snapshot.duplicate(true)
	incomplete["difficultyId"] = "nightmare"
	_check(not _evaluate("TALK-1", incomplete), "formal guard rejects unknown difficulty")
	incomplete = _formal_snapshot("gameplay", "normal")
	incomplete["nonHeartCommentCount"] = 99
	_check(not _evaluate("TALK-1", incomplete), "normal mission cannot use another stage")
	var relay := _formal_snapshot("relay", "normal", true)
	relay["relayCompletedFrameIds"] = ["zatsudan"]
	relay["relayFinalBossPlayerDefeated"] = false
	_check(not _evaluate("RELAY-2", relay), "relay mission needs formal five-segment result")
	_check(not _evaluate("RELAY-3", relay), "relay boss mission needs formal final result")
	relay = _formal_snapshot("relay", "normal", true)
	relay["relayFinalBossPlayerDefeated"] = true
	relay["relayBossScoreAwarded"] = true
	relay["playerSideBossDefeats"] = ["last_offline"]
	relay["evaluationRank"] = "A"
	_check(not _evaluate("RELAY-3", relay), "normal relay does not satisfy HARD+ mission")

func _test_tracker_recording() -> void:
	var tracker = TrackerScript.start(true, "zatsudan", "normal", false, false)
	tracker.record_comment(2, false)
	tracker.record_comment(3, true)
	_check_equal(tracker.non_heart_comment_count, 1, "tracker counts non-heart applied comments")
	_check_equal(tracker.risk_comment_count, 1, "tracker counts actual risk comments")
	tracker.mark_debug_contaminated()
	_check(not tracker.official_run_eligible and tracker.debug_contaminated, "debug contamination invalidates tracker")
	var normal_drawing = TrackerScript.start(true, "drawing", "normal", false, false)
	for color in ["pink", "cyan", "green", "yellow", "red", "blue", "purple"]:
		normal_drawing.record_drawing_color(color)
	_check_equal(normal_drawing.drawing_color_bits, 15, "tracker accepts only four normal inks")
	var boss_tracker = TrackerScript.start(true, "singing", "hard", false, false)
	boss_tracker.register_boss_defeat({"bossId": "pitch_police_chief", "ppRewardId": "pitch_police_chief", "defeatReason": "partner"})
	boss_tracker.register_boss_defeat({"bossId": "pitch_police_chief", "ppRewardId": "pitch_police_chief", "defeatReason": "player_side_damage", "heatLevel": 5})
	_check(boss_tracker.song_lv5_boss_defeated and boss_tracker.player_side_boss_defeats.has("pitch_police_chief"), "tracker records player-side Lv5 boss only")
	var relay_tracker = TrackerScript.start(true, "relay", "hard", true, false)
	relay_tracker.begin_relay_segment("zatsudan")
	for index in range(3):
		relay_tracker.record_comment(3, false)
	relay_tracker.record_relay_segment("zatsudan", {"dangerousCommentCount": 3})
	_check((relay_tracker.relay_mini_condition_bits & 1) == 1, "relay tracker records talk mini condition")
	relay_tracker.begin_relay_segment("gameplay")
	relay_tracker.record_relay_genre_event_clear()
	relay_tracker.record_relay_segment("gameplay")
	_check((relay_tracker.relay_mini_condition_bits & 2) == 2, "relay tracker records gameplay no-hit mini condition only in gameplay")
	relay_tracker.begin_relay_segment("collab")
	relay_tracker.register_boss_defeat({"bossId": "collab_crusher", "ppRewardId": "collab_crusher", "defeatReason": "partner"})
	relay_tracker.register_boss_defeat({"bossId": "collab_crusher", "ppRewardId": "collab_crusher", "defeatReason": "collab_skill"})
	_check(relay_tracker.player_side_boss_defeats.has("collab_crusher"), "pair skill boss defeat remains player-side for mission tracking")
	var invalid_sequence := _formal_snapshot("relay", "normal", true)
	invalid_sequence["relayCompletedFrameIds"] = ["zatsudan", "gameplay", "gameplay", "drawing", "collab"]
	_check(not _evaluate("RELAY-2", invalid_sequence), "relay formal guard rejects duplicate segment sequence")

func _new_manager(seed: Dictionary = {}) -> RefCounted:
	var store := SaveStoreScript.new()
	var manager = ShopManagerScript.new(database, store)
	if not seed.is_empty():
		manager.profile = store.normalize(seed, database)
	return manager

func _save_override(_candidate: Dictionary) -> bool:
	save_calls += 1
	return not save_should_fail

func _simple_reward(is_relay: bool = false):
	return RewardCalculatorScript.calculate({
		"rewardEligible": true,
		"outcome": "completed",
		"isRelay": is_relay,
		"stageCleared": not is_relay,
		"activePlaySeconds": 0.0,
		"stageId": "zatsudan" if not is_relay else "relay",
		"difficultyId": "normal",
		"relayCompletedFrameIds": ["zatsudan", "gameplay", "singing", "drawing", "collab"] if is_relay else [],
		"relayFinalReached": is_relay,
		"relayFinalDefeated": is_relay,
		"evaluationRank": "D",
		"evaluationScore": 0
	})

func _test_transaction_retry_and_title() -> void:
	var seed := SaveStoreScript.new().default_data(database)
	var manager := _new_manager(seed)
	manager.store.save_override = Callable(self, "_save_override")
	var snapshot := _formal_snapshot("zatsudan", "normal")
	snapshot["nonHeartCommentCount"] = 5
	snapshot["riskCommentCount"] = 5
	var reward = _simple_reward(false)
	var pristine: Dictionary = reward.to_dictionary().duplicate(true)
	var context := {"snapshot": snapshot}
	save_calls = 0
	save_should_fail = true
	var before: Dictionary = manager.profile.duplicate(true)
	var failed: Dictionary = manager.grant_reward_with_stream_missions("mission_retry", reward, false, context)
	_check(not bool(failed.get("ok", true)) and failed.get("state", "") == "save_failed", "mission transaction failure is reported")
	_check_equal(manager.profile, before, "mission transaction failure leaves profile unchanged")
	var failed_again: Dictionary = manager.grant_reward_with_stream_missions("mission_retry", reward, false, context)
	_check(not bool(failed_again.get("ok", true)), "same pristine candidate can fail repeatedly")
	_check_equal(reward.to_dictionary(), pristine, "failed retries never mutate source reward")
	save_should_fail = false
	var granted: Dictionary = manager.grant_reward_with_stream_missions("mission_retry", reward, false, context)
	_check(bool(granted.get("ok", false)) and granted.get("state", "") == "granted", "mission transaction retries successfully")
	var points_after_success: int = manager.current_points()
	var duplicate: Dictionary = manager.grant_reward_with_stream_missions("mission_retry", reward, false, context)
	_check(duplicate.get("state", "") == "already_granted" and manager.current_points() == points_after_success, "mission transaction is idempotent")
	_check_equal(manager.completed_stream_mission_ids().size(), 2, "retry grants two newly qualified missions once")

	# The last mission and last set, plus the title, are committed in one candidate.
	var all_seed := SaveStoreScript.new().default_data(database)
	all_seed["currentPoints"] = 10
	all_seed["completedStreamMissions"] = mission_system.mission_ids().slice(0, 17)
	all_seed["completedStageMissionSets"] = mission_system.set_ids().slice(0, 5)
	var all_manager := _new_manager(all_seed)
	all_manager.store.save_override = Callable(self, "_save_override")
	save_calls = 0
	var final_snapshot := _formal_snapshot("relay", "hard", true)
	final_snapshot["playerSideBossDefeats"] = ["last_offline"]
	var final_grant: Dictionary = all_manager.grant_reward_with_stream_missions("all_18_once", _simple_reward(true), false, {"snapshot": final_snapshot})
	_check(bool(final_grant.get("ok", false)) and save_calls == 1, "all-18 completion uses one save transaction")
	_check_equal(all_manager.completed_stream_mission_ids().size(), 18, "all 18 missions are owned")
	_check_equal(all_manager.completed_stage_mission_set_ids().size(), 6, "all 6 mission sets are owned")
	_check(all_manager.purchased_customization_ids().has("title_perfect_streamer"), "perfect streamer title is direct ownership")
	_check_equal(all_manager.equipped_customizations().get("title", ""), "", "perfect streamer title is not auto-equipped")
	_check_equal(int(final_grant.get("streamMissionResult", {}).get("missionPp", 0)), 50, "last mission pays 50 PP")
	_check_equal(int(final_grant.get("streamMissionResult", {}).get("setPp", 0)), 100, "last set pays 100 PP")
	_check_equal(all_manager.current_points(), 10 + int(final_grant.get("totalPp", 0)), "mission and existing PP share one balance update")
	var reward_view := ResultSystemScript.build_point_reward_view(
		{"participationPp": 100, "totalPp": 100},
		"granted",
		0,
		250,
		250,
		false,
		{"missionPp": 50, "setPp": 100}
	)
	var mission_rows: Array = []
	for row_value in reward_view.get("rewardRows", []) as Array:
		if row_value is Dictionary and String((row_value as Dictionary).get("id", "")) == "stream_missions":
			mission_rows.append(row_value)
	_check_equal(mission_rows.size(), 1, "result PP view has one配信目標 subtotal row")
	var mission_row_amount := int((mission_rows[0] as Dictionary).get("amount", 0)) if not mission_rows.is_empty() else -1
	_check_equal(mission_row_amount, 150, "result PP view shows mission plus set subtotal")
	_check(bool((mission_rows[0] as Dictionary).get("isStreamMission", false)), "result PP view marks the 配信目標 row for plus-prefix rendering")
	_check_equal(int(reward_view.get("pointsEarned", 0)), 250, "result PP view keeps the single total unchanged")
	_check_equal(all_manager.purchase_customization("title_perfect_streamer"), ShopManagerScript.Result.INVALID_ID, "mission title cannot be purchased")
	_check_equal(all_manager.current_points(), 10 + int(final_grant.get("totalPp", 0)), "mission title purchase attempt has no cost")

func _test_schema_compatibility_and_economics() -> void:
	var store := SaveStoreScript.new()
	var legacy := store.default_data(database)
	legacy["schemaVersion"] = 5
	legacy.erase("completedStreamMissions")
	legacy.erase("completedStageMissionSets")
	var normalized := store.normalize(legacy, database)
	_check_equal(normalized.get("completedStreamMissions", []), [], "schema5 save has no retroactive missions")
	_check_equal(normalized.get("completedStageMissionSets", []), [], "schema5 save has no retroactive sets")
	legacy["completedStreamMissions"] = ["TALK-1"]
	legacy["completedStageMissionSets"] = ["v1:talk"]
	normalized = store.normalize(legacy, database)
	_check_equal(normalized.get("completedStreamMissions", []), [], "schema5 future mission fields are ignored")
	_check_equal(normalized.get("completedStageMissionSets", []), [], "schema5 future set fields are ignored")
	legacy["schemaVersion"] = 6
	legacy["completedStreamMissions"] = ["future:mission", "TALK-1", "TALK-1"]
	legacy["completedStageMissionSets"] = ["future:set", "v1:talk", "v1:talk"]
	normalized = store.normalize(legacy, database)
	_check(normalized["completedStreamMissions"].has("future:mission") and normalized["completedStreamMissions"].count("TALK-1") == 1, "unknown mission IDs survive normalization")
	_check(normalized["completedStageMissionSets"].has("future:set") and normalized["completedStageMissionSets"].count("v1:talk") == 1, "unknown set IDs survive normalization")
	_check_equal(SaveStoreScript.SCHEMA_VERSION, 6, "save schema is six")
	var pp_total := 18 * 50 + 6 * 100
	_check_equal(pp_total, 1500, "mission economy maximum is 1500 PP")
	_check_equal(RewardCalculatorScript.difficulty_multiplier_for("hard"), 1.2, "existing difficulty reward rules remain separate")
