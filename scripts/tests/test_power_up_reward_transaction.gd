extends Node

const Database := preload("res://scripts/systems/power_up_database.gd")
const SaveStore := preload("res://scripts/systems/power_up_save_store.gd")
const Manager := preload("res://scripts/systems/power_up_shop_manager.gd")
const Tracker := preload("res://scripts/systems/power_up_run_tracker.gd")
const Calculator := preload("res://scripts/systems/stream_point_reward_calculator.gd")
const ResultSystem := preload("res://scripts/systems/result_system.gd")
const FRAMES := ["zatsudan", "gameplay", "singing", "drawing", "collab"]

class RewardTarget extends Node:
	var power_up_run_tracker
	var power_up_shop_manager
	var run_difficulty_id := "normal"
	var pending_power_up_reward = null
	var last_result_data: Dictionary = {}
	var unlock_presentation_before: Dictionary = {}

var database
var test_root := ""
var failures: Array[String] = []
var checks := 0
var evidence: Dictionary = {"retryCases": [], "calculations": []}

func _ready() -> void:
	# Require an isolated APPDATA/user directory, including for CodexManager's
	# character discovery during the real ResultSystem relay retry path.
	test_root = OS.get_environment("COMMENTDIE_PP_TEST_ROOT").replace("\\", "/").trim_suffix("/")
	var user_dir := OS.get_user_data_dir().replace("\\", "/")
	if not test_root.is_absolute_path() or not user_dir.begins_with(test_root + "/"):
		push_error("Set COMMENTDIE_PP_TEST_ROOT and isolate APPDATA beneath it before running this test.")
		get_tree().quit(2)
		return
	database = Database.load_default()
	_check(database.is_valid, "production database valid")
	_test_normal_success()
	for scenario in [
		{"id": "first_stage", "expected": 200},
		{"id": "first_boss", "boss": true, "expected": 350},
		{"id": "first_relay", "relay": true, "expected": 1160},
		{"id": "gift", "gift": true, "expected": 230},
		{"id": "repeat", "repeat": true, "expected": 150},
		{"id": "history_limits", "historyFull": true, "expected": 200}
	]:
		_test_retry(scenario, false)
		_test_retry(scenario, true)
	_test_save_boundary()
	_test_reward_key_deduplication()
	_test_calculations()
	_test_purchase_and_refund()
	_test_existing_save_copy()
	evidence["checks"] = checks
	evidence["failures"] = failures
	var report := FileAccess.open(test_root.path_join("transaction-results.json"), FileAccess.WRITE)
	if report != null:
		report.store_string(JSON.stringify(evidence, "\t"))
		report.close()
	for failure in failures:
		push_error(failure)
	print("POWER_UP_REWARD_TRANSACTION_TESTS: %s (%d checks, %d failures)" % ["PASS" if failures.is_empty() else "FAIL", checks, failures.size()])
	get_tree().quit(0 if failures.is_empty() else 1)

func _seed_profile(repeat: bool = false) -> Dictionary:
	var seed: Dictionary = SaveStore.new().default_data(database)
	seed["currentPoints"] = 37
	seed["totalEarnedPoints"] = 157
	seed["totalSpentPoints"] = 120
	seed["upgrades"]["max_hp"] = 1
	seed["selectedCharacterId"] = "superchat_chan"
	seed["discoveredEvolutionRecipes"] = ["buzz_thumbnail_rod"]
	seed["rewardedRunIds"] = ["older_run"]
	seed["rewardedRewardKeys"] = ["older_reward_key"]
	seed["firstStageClears"]["gameplay"] = true
	seed["firstBossDefeats"]["bugged_final_boss"] = true
	if repeat:
		seed["unlocked"] = true
		for id in seed["firstStageClears"]:
			seed["firstStageClears"][id] = true
		for id in seed["firstBossDefeats"]:
			seed["firstBossDefeats"][id] = true
		seed["firstRelayClear"] = true
		seed["normalRelayCleared"] = true
		seed["unlockedCharacterIds"] = SaveStore.ALWAYS_UNLOCKED_CHARACTER_IDS.duplicate() + SaveStore.SENIOR_UNIT_CHARACTER_IDS.duplicate()
	return seed

func _new_store(id: String):
	var directory := test_root.path_join("saves").path_join(id)
	_check(DirAccess.make_dir_recursive_absolute(directory) == OK, id + " create save directory")
	var store = SaveStore.new()
	store.path = directory.path_join("power_up_shop.json")
	store.backup_path = store.path + ".bak"
	store.temp_path = store.path + ".tmp"
	return store

func _new_manager(id: String, seed: Dictionary):
	var store = _new_store(id)
	_check(store.save_data(seed, database), id + " seed saved")
	return Manager.new(database, store)

func _target(id: String, manager, scenario: Dictionary) -> RewardTarget:
	var target := RewardTarget.new()
	target.power_up_shop_manager = manager
	target.power_up_run_tracker = Tracker.start(true, manager.total_upgrade_level(), true)
	target.power_up_run_tracker.run_id = id
	target.run_difficulty_id = String(scenario.get("difficulty", "normal"))
	target.power_up_run_tracker.difficulty_id = target.run_difficulty_id
	if bool(scenario.get("boss", false)):
		_check(target.power_up_run_tracker.register_boss_defeat({
			"ppRewardId": "kusomaro_king", "basePpReward": 75,
			"ppRate": 1.0 if target.run_difficulty_id == "normal" else 2.0,
			"isPpRewardTarget": true, "isFirstDefeatRewardTarget": true,
			"defeatReason": "player_side_damage", "rewardKey": "boss:" + id
		}), id + " boss tracked")
	if bool(scenario.get("relay", false)):
		target.power_up_run_tracker.mark_relay_final_defeated()
	if bool(scenario.get("gift", false)):
		for gift in [[5, "field_random"], [10, "fallback"], [15, "full_build_conversion"]]:
			var grant: Dictionary = target.power_up_run_tracker.grant_direct_pp(gift[0], gift[1], id + ":" + gift[1])
			_check(bool(grant["granted"]), id + " gift tracked " + gift[1])
	return target

func _result(scenario: Dictionary) -> Dictionary:
	return {"endType": "completed", "relayMode": bool(scenario.get("relay", false)),
		"elapsed": 180.0, "stageId": "zatsudan", "cleared": true,
		"relayCompletedFrameIds": FRAMES.duplicate() if bool(scenario.get("relay", false)) else [],
		"evaluationVersion": 2, "evaluationScore": 0, "evaluationRank": scenario.get("rank", "D")}

func _reward(target: RewardTarget, result: Dictionary):
	var input: Dictionary = target.power_up_run_tracker.reward_input(result["relayMode"], "completed", result["elapsed"], result["stageId"], result["cleared"], result["relayCompletedFrameIds"])
	input["difficultyMultiplier"] = Calculator.difficulty_multiplier_for(target.run_difficulty_id)
	input["evaluationRank"] = result["evaluationRank"]
	var profile: Dictionary = target.power_up_shop_manager.profile
	return Calculator.calculate(input, profile["firstStageClears"], profile["firstBossDefeats"], profile["firstRelayClear"], database.reward_rules)

func _test_normal_success() -> void:
	var manager = _new_manager("normal_success", SaveStore.new().default_data(database))
	var target := _target("normal_success", manager, {})
	var reward = _reward(target, _result({}))
	var first: Dictionary = manager.grant_reward(target.power_up_run_tracker.run_id, reward)
	_check(first.get("state") == "granted" and first.get("totalPp") == 200, "normal initial grant 200")
	_check(manager.profile["firstStageClears"]["zatsudan"], "normal initial stage flag")
	var reloaded = Manager.new(database, manager.store)
	_check(reloaded.profile == manager.profile, "normal initial grant persisted")
	var duplicate: Dictionary = reloaded.grant_reward(target.power_up_run_tracker.run_id, reward)
	_check(duplicate.get("state") == "already_granted" and duplicate.get("totalPp") == 0 and reloaded.current_points() == 200, "normal duplicate adds zero after reload")
	evidence["normalSuccess"] = {"first": first, "duplicate": duplicate}
	target.free()

func _test_retry(scenario: Dictionary, via_result: bool) -> void:
	var id := String(scenario["id"]) + ("_result" if via_result else "_manager")
	var seed := _seed_profile(bool(scenario.get("repeat", false)))
	if bool(scenario.get("historyFull", false)):
		seed["rewardedRunIds"] = []
		seed["rewardedRewardKeys"] = []
		for index in range(100):
			seed["rewardedRunIds"].append("old_run_%d" % index)
		for index in range(200):
			seed["rewardedRewardKeys"].append("old_key_%d" % index)
	var manager = _new_manager(id, seed)
	var target := _target(id, manager, scenario)
	var result := _result(scenario)
	var reward = _reward(target, result)
	var expected := int(scenario["expected"])
	_check(reward.total_pp == expected, id + " expected calculation")
	var before: Dictionary = manager.profile.duplicate(true)
	var original_profile: Dictionary = manager.profile
	var tracker_before: Dictionary = target.power_up_run_tracker.to_dictionary()
	var disk_before := FileAccess.get_file_as_string(manager.store.path)
	var signals := {"reward": 0, "unlocked": 0}
	manager.reward_granted.connect(func(_run: String, _points: int): signals["reward"] += 1)
	manager.shop_unlocked.connect(func(): signals["unlocked"] += 1)
	var valid_temp: String = manager.store.temp_path
	# The main save is a file, so it cannot be the parent of a temporary file.
	manager.store.temp_path = manager.store.path.path_join("blocked.tmp")
	var failed: Dictionary
	if via_result:
		failed = ResultSystem._commit_power_up_reward(result, target)
		reward = failed["reward"]
		target.last_result_data = result.duplicate(true)
		target.last_result_data["ppGrantState"] = failed["state"]
		target.last_result_data["pointRewardView"] = ResultSystem.build_point_reward_view(reward.to_dictionary(), failed["state"], before["currentPoints"], 0, manager.current_points(), result["relayMode"])
		_check(not target.power_up_run_tracker.result_committed and target.pending_power_up_reward != null, id + " failed result stays pending")
	else:
		failed = manager.grant_reward(id, reward, bool(scenario.get("relay", false)))
		_check(not bool(failed.get("ok", true)) and failed.get("totalPp") == 0, id + " failure response")
	var after_failure: Dictionary = manager.profile.duplicate(true)
	_check(failed.get("state") == "save_failed", id + " reports save_failed")
	_check(manager.profile == before and original_profile == before, id + " failure preserves every profile field and original references")
	_check(FileAccess.get_file_as_string(manager.store.path) == disk_before, id + " failure preserves disk bytes")
	_check(signals["reward"] == 0 and signals["unlocked"] == 0 and not manager.busy, id + " failure emits no success signal and releases busy")
	_check(target.power_up_run_tracker.to_dictionary() == tracker_before, id + " failure preserves tracker including gifts")
	var failed_again: Dictionary = ResultSystem.retry_power_up_reward_for_target(target) if via_result else manager.grant_reward(id, reward, bool(scenario.get("relay", false)))
	_check(not bool(failed_again.get("ok", true)) and failed_again.get("state") == "save_failed", id + " retry while blocked still fails normally")
	_check(manager.profile == before, id + " repeated failure preserves profile")
	var blocked_result_state := {"committed": target.power_up_run_tracker.result_committed, "pendingCleared": target.pending_power_up_reward == null, "displayState": target.last_result_data.get("ppGrantState", "")}
	manager.store.temp_path = valid_temp
	var granted: Dictionary = ResultSystem.retry_power_up_reward_for_target(target) if via_result else manager.grant_reward(id, reward, bool(scenario.get("relay", false)))
	_check(bool(granted.get("ok", false)) and granted.get("state") == "granted", id + " same run retries successfully")
	_check(manager.current_points() == int(before["currentPoints"]) + expected, id + " balance gains exactly once")
	_check(manager.profile["totalEarnedPoints"] == int(before["totalEarnedPoints"]) + expected, id + " earned points gain exactly once")
	_check(manager.profile["totalSpentPoints"] == before["totalSpentPoints"] and manager.profile["upgrades"] == before["upgrades"], id + " spent and upgrades unchanged")
	_check(original_profile == before, id + " adoption leaves original profile references unchanged")
	_check(manager.profile["rewardedRunIds"].count(id) == 1, id + " run history recorded once")
	for key in reward.reward_keys:
		_check(manager.profile["rewardedRewardKeys"].count(key) == 1, id + " reward key recorded once: " + key)
	for stage in reward.newly_cleared_stage_ids:
		_check(manager.profile["firstStageClears"][stage], id + " stage first flag committed")
	for boss in reward.newly_defeated_boss_ids:
		_check(manager.profile["firstBossDefeats"][boss], id + " boss first flag committed")
	if bool(scenario.get("relay", false)):
		_check(manager.profile["firstRelayClear"] and manager.profile["normalRelayCleared"], id + " relay flags committed")
		_check(manager.profile["unlockedCharacterIds"].size() == 6, id + " relay character unlock committed")
	if bool(scenario.get("historyFull", false)):
		_check(manager.profile["rewardedRunIds"].size() == 100 and manager.profile["rewardedRunIds"][0] == "old_run_1", id + " run history limit unchanged")
		_check(manager.profile["rewardedRewardKeys"].size() == 200 and manager.profile["rewardedRewardKeys"][0] == "old_key_1", id + " reward key limit unchanged")
	if via_result:
		_check(target.power_up_run_tracker.result_committed and target.pending_power_up_reward == null, id + " successful result committed and pending cleared")
		_check(target.last_result_data.get("ppGrantState") == "granted", id + " display reports actual grant")
		_check(target.last_result_data.get("pointRewardView", {}).get("pointsEarned") == expected, id + " display reports expected PP")
	var committed: Dictionary = manager.profile.duplicate(true)
	var duplicate: Dictionary = manager.grant_reward(id, reward)
	_check(duplicate.get("state") == "already_granted" and duplicate.get("totalPp") == 0 and manager.profile == committed, id + " successful duplicate adds zero")
	var reloaded = Manager.new(database, manager.store)
	_check(reloaded.profile == committed, id + " all committed fields persisted")
	_check(reloaded.grant_reward(id, reward).get("state") == "already_granted" and reloaded.profile == committed, id + " duplicate prevented after reload")
	_check(signals["reward"] == 1, id + " success signal exactly once")
	evidence["retryCases"].append({"id": id, "expectedPp": expected, "before": before, "afterFailure": after_failure, "changedFieldsOnFailure": _changed_fields(before, after_failure), "firstFailureState": failed["state"], "retryWhileBlocked": failed_again, "blockedResultState": blocked_result_state, "retry": granted, "duplicate": duplicate, "afterSuccess": committed, "resultCommitted": target.power_up_run_tracker.result_committed, "displayState": target.last_result_data.get("ppGrantState", ""), "pendingCleared": target.pending_power_up_reward == null})
	target.free()

func _test_save_boundary() -> void:
	var manager = _new_manager("save_boundary", _seed_profile())
	var target := _target("save_boundary", manager, {"relay": true, "boss": true, "gift": true})
	var reward = _reward(target, _result({"relay": true}))
	var before: Dictionary = manager.profile.duplicate(true)
	var observed := {}
	manager.store.save_override = func(candidate: Dictionary) -> bool:
		observed["duringSave"] = manager.profile.duplicate(true)
		observed["candidate"] = candidate.duplicate(true)
		_check(manager.profile == before, "formal profile unchanged during save callback")
		return false
	var failed: Dictionary = manager.grant_reward("save_boundary", reward, true)
	manager.store.save_override = Callable()
	_check(failed.get("state") == "save_failed" and manager.profile == before, "save override failure preserves profile")
	_check(observed.has("candidate"), "save callback exercised")
	evidence["saveBoundary"] = {"before": before, "duringSave": observed.get("duringSave"), "candidate": observed.get("candidate"), "afterFailure": manager.profile.duplicate(true)}
	target.free()

func _test_reward_key_deduplication() -> void:
	var manager = _new_manager("key_dedup", SaveStore.new().default_data(database))
	var target := _target("key_dedup", manager, {"boss": true})
	var input := _result({})
	var first_reward = _reward(target, input)
	var stale_reward = _reward(target, input)
	_check(manager.grant_reward("key_first", first_reward).get("totalPp") == 350, "key first grant includes first bonuses")
	_check(manager.grant_reward("key_second", stale_reward).get("totalPp") == 150, "new run with duplicate boss and first keys only gets repeat stage PP")
	_check(manager.current_points() == 500, "duplicate reward keys do not pay twice")
	evidence["rewardKeyDedup"] = {"firstPp": first_reward.total_pp, "secondPp": stale_reward.total_pp, "balance": manager.current_points()}
	target.free()

func _test_calculations() -> void:
	# Fixed pre-fix expectations, exercised through the real ResultSystem path.
	var expected_normal := [[225, 236, 248, 270, 293], [360, 378, 396, 432, 468], [420, 441, 462, 504, 546]]
	var expected_relay := [[960, 1008, 1056, 1152, 1248], [1152, 1210, 1267, 1382, 1498], [1344, 1411, 1478, 1613, 1747]]
	for difficulty in range(3):
		for rank in range(5):
			for relay in [false, true]:
				var scenario := {"difficulty": ["normal", "hard", "expert"][difficulty], "rank": ["D", "C", "B", "A", "S"][rank], "relay": relay, "boss": not relay, "gift": true}
				var expected: int = int((expected_relay if relay else expected_normal)[difficulty][rank]) + 30
				_check_result_calculation("matrix_%d_%d_%s" % [difficulty, rank, str(relay)], scenario, true, expected)
	for scenario in [
		{"id": "hard_first_boss", "difficulty": "hard", "boss": true, "expected": 560},
		{"id": "expert_first_boss", "difficulty": "expert", "boss": true, "expected": 620},
		{"id": "hard_first_relay", "difficulty": "hard", "relay": true, "expected": 1352},
		{"id": "expert_first_relay", "difficulty": "expert", "relay": true, "expected": 1544}
	]:
		_check_result_calculation(scenario["id"], scenario, false, scenario["expected"])

func _check_result_calculation(id: String, scenario: Dictionary, repeat: bool, expected: int) -> void:
	var manager = _new_manager(id, _seed_profile(repeat))
	var target := _target(id, manager, scenario)
	var commit: Dictionary = ResultSystem._commit_power_up_reward(_result(scenario), target)
	_check(commit.get("state") == "granted" and commit.get("earnedPoints") == expected, id + " calculation unchanged")
	_check(is_equal_approx(commit["reward"].difficulty_multiplier, {"normal": 1.0, "hard": 1.2, "expert": 1.4}[scenario["difficulty"]]), id + " real difficulty multiplier")
	evidence["calculations"].append({"id": id, "expectedPp": expected, "reward": commit["reward"].to_dictionary(), "earnedPp": commit.get("earnedPoints")})
	target.free()

func _test_purchase_and_refund() -> void:
	var seed: Dictionary = SaveStore.new().default_data(database)
	seed["unlocked"] = true
	seed["currentPoints"] = 22080
	seed["totalEarnedPoints"] = 22080
	var manager = _new_manager("purchase_refund", seed)
	var before: Dictionary = manager.profile.duplicate(true)
	var valid_temp: String = manager.store.temp_path
	manager.store.temp_path = manager.store.path.path_join("blocked.tmp")
	_check(manager.purchase_upgrade("max_hp") == Manager.Result.SAVE_FAILED and manager.profile == before, "purchase failure rolls back")
	manager.store.temp_path = valid_temp
	var cost := 0
	for upgrade in database.upgrades:
		for price in upgrade["prices"]:
			var old_balance: int = manager.current_points()
			_check(manager.purchase_upgrade(upgrade["id"]) == Manager.Result.SUCCESS, "purchase " + upgrade["id"])
			_check(manager.current_points() == old_balance - int(price), "purchase price unchanged " + upgrade["id"])
			cost += int(price)
	_check(cost == 22080 and manager.current_points() == 0 and manager.total_upgrade_level() == 60, "all upgrades cost 22080 for 60 levels")
	_check(manager.calculate_refund_points() == 22080, "full refund unchanged")
	before = manager.profile.duplicate(true)
	manager.store.temp_path = manager.store.path.path_join("blocked.tmp")
	_check(manager.reset_all_upgrades() == Manager.Result.SAVE_FAILED and manager.profile == before, "refund failure rolls back")
	manager.store.temp_path = valid_temp
	_check(manager.reset_all_upgrades() == Manager.Result.SUCCESS, "full reset succeeds")
	_check(manager.current_points() == 22080 and manager.total_upgrade_level() == 0 and manager.profile["totalSpentPoints"] == 0 and manager.profile["totalEarnedPoints"] == 22080, "refund changes only balance levels and spent total")
	_check(manager.reset_all_upgrades() == Manager.Result.NOTHING_TO_RESET, "empty reset adds zero")
	_check(Manager.new(database, manager.store).profile == manager.profile, "purchase refund disk round trip")
	evidence["purchaseRefund"] = {"cost": cost, "refundedBalance": manager.current_points(), "totalLevelAfterReset": manager.total_upgrade_level()}

func _test_existing_save_copy() -> void:
	# Optional read-only fixture; only its copy in test_root is passed to the store.
	var source := OS.get_environment("COMMENTDIE_PP_COMPAT_SAVE")
	if source == "":
		evidence["existingSaveCompatibility"] = "not supplied"
		return
	var bytes := FileAccess.get_file_as_bytes(source)
	var parsed: Dictionary = JSON.parse_string(bytes.get_string_from_utf8())
	var store = _new_store("existing_save_copy")
	var copy := FileAccess.open(store.path, FileAccess.WRITE)
	copy.store_buffer(bytes)
	copy.close()
	var manager = Manager.new(database, store)
	var original: Dictionary = parsed.get("powerUpShop", parsed)
	# Compare JSON values with JSON values; parsing turns integer PP/Lv into floats.
	var loaded_json: Dictionary = JSON.parse_string(JSON.stringify(manager.profile))
	var old_fields_preserved := true
	for key in original.keys():
		if String(key) == "schemaVersion":
			continue
		if not loaded_json.has(key) or loaded_json[key] != original[key]:
			old_fields_preserved = false
	_check(old_fields_preserved, "existing normal save all legacy fields load unchanged")
	_check(FileAccess.get_file_as_bytes(store.path) == bytes and FileAccess.get_file_as_bytes(source) == bytes, "existing save and copied save bytes unchanged")
	_check(manager.profile["schemaVersion"] == 5, "v3 existing save normalizes to schema 5")
	_check(manager.profile.get("claimedCodexMilestones", []) == [], "v3 existing save defaults claimed Codex milestones to empty")
	evidence["existingSaveCompatibility"] = {"legacyFieldsPreserved": old_fields_preserved, "schemaVersion": manager.profile["schemaVersion"], "claimedCodexMilestones": manager.profile.get("claimedCodexMilestones", []), "balance": manager.current_points(), "totalUpgradeLevel": manager.total_upgrade_level(), "rewardedRuns": manager.profile["rewardedRunIds"].size(), "rewardedKeys": manager.profile["rewardedRewardKeys"].size()}

func _changed_fields(before: Dictionary, after: Dictionary) -> Array[String]:
	var changed: Array[String] = []
	for key in before:
		if not after.has(key) or before[key] != after[key]:
			changed.append(key)
	for key in after:
		if not before.has(key):
			changed.append(key)
	return changed

func _check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures.append(label)
