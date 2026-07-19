extends Node

const DatabaseScript := preload("res://scripts/systems/power_up_database.gd")
const SaveStoreScript := preload("res://scripts/systems/power_up_save_store.gd")
const ShopManagerScript := preload("res://scripts/systems/power_up_shop_manager.gd")
const EffectProviderScript := preload("res://scripts/systems/power_up_effect_provider.gd")
const RewardCalculatorScript := preload("res://scripts/systems/stream_point_reward_calculator.gd")
const GameScript := preload("res://scripts/game.gd")

var failures: Array[String] = []
var save_should_fail := false

func _ready() -> void:
	_run_all_tests()
	if failures.is_empty():
		print("POWER_UP_SHOP_TESTS: PASS")
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("POWER_UP_SHOP_TESTS: FAIL (%d)" % failures.size())
		get_tree().quit(1)

func _run_all_tests() -> void:
	var database = DatabaseScript.load_default()
	_check(bool(database.is_valid), "master data is valid")
	_check(GameScript != null, "full game script parsed")
	if not bool(database.is_valid):
		return
	_test_reward_expectations(database)
	_test_effect_snapshots(database)
	_test_purchase_reset_and_save_rollback(database)
	_test_reward_deduplication(database)
	_test_legacy_migration(database)

func _test_reward_expectations(_database) -> void:
	var first_boss := {
		"bossId": "boss_kuso_maro_king",
		"ppRewardId": "kusomaro_king",
		"basePpReward": 75,
		"isPpRewardTarget": true,
		"isFirstDefeatRewardTarget": true,
		"defeatReason": "player_side_damage",
		"rewardKey": "boss:test:kuso"
	}
	_check_equal("normal clear", _reward({"outcome": "completed", "rewardEligible": true, "isRelay": false, "activePlaySeconds": 180.0, "stageId": "zatsudan", "stageCleared": true}, {"zatsudan": true}, {"kusomaro_king": true}).total_pp, 150)
	_check_equal("normal clear with repeatable boss", _reward({"outcome": "completed", "rewardEligible": true, "isRelay": false, "activePlaySeconds": 180.0, "stageId": "zatsudan", "stageCleared": true, "defeatedBosses": [first_boss]}, {"zatsudan": true}, {"kusomaro_king": true}).total_pp, 225)
	_check_equal("normal first stage and boss", _reward({"outcome": "completed", "rewardEligible": true, "isRelay": false, "activePlaySeconds": 180.0, "stageId": "zatsudan", "stageCleared": true, "defeatedBosses": [first_boss]}).total_pp, 350)
	_check_equal("normal 90 second defeat", _reward({"outcome": "defeated", "rewardEligible": true, "isRelay": false, "activePlaySeconds": 90.0, "stageId": "zatsudan", "stageCleared": false}).total_pp, 35)
	_check_equal("relay five frames", _reward({"outcome": "defeated", "rewardEligible": true, "isRelay": true, "relayClearedFrameIds": ["zatsudan", "gameplay", "singing", "drawing", "collab"]}).total_pp, 610)
	_check_equal("relay final repeat", _reward({"outcome": "completed", "rewardEligible": true, "isRelay": true, "relayClearedFrameIds": ["zatsudan", "gameplay", "singing", "drawing", "collab"], "relayFinalReached": true, "relayFinalDefeated": true}, {}, {}, true).total_pp, 960)
	_check_equal("relay first clear", _reward({"outcome": "completed", "rewardEligible": true, "isRelay": true, "relayClearedFrameIds": ["zatsudan", "gameplay", "singing", "drawing", "collab"], "relayFinalReached": true, "relayFinalDefeated": true}).total_pp, 1160)

	var total_cost := 0
	for item in _database_upgrades():
		var upgrade: Dictionary = item as Dictionary
		for price in upgrade.get("prices", []) as Array:
			total_cost += int(price)
	_check_equal("all upgrade cost", total_cost, 14720)

func _test_effect_snapshots(database) -> void:
	var store = SaveStoreScript.new()
	var profile: Dictionary = store.default_data(database)
	var on = EffectProviderScript.create_snapshot(profile, database, true)
	var off = EffectProviderScript.create_snapshot(profile, database, false)
	_check_equal("Lv0 hp", EffectProviderScript.max_hp(100, on), 100)
	_check_approx("Lv0 damage", EffectProviderScript.damage(10.0, on), 10.0)
	_check_equal("OFF hp", EffectProviderScript.max_hp(100, off), 100)
	_check_approx("OFF damage", EffectProviderScript.damage(10.0, off), 10.0)
	var levels: Dictionary = profile["upgrades"] as Dictionary
	for id in levels.keys():
		levels[id] = 1
	var lv1 = EffectProviderScript.create_snapshot(profile, database, true)
	_check_equal("Lv1 hp", EffectProviderScript.max_hp(100, lv1), 104)
	_check_approx("Lv1 damage", EffectProviderScript.damage(100.0, lv1), 103.0)
	_check_approx("Lv1 move", EffectProviderScript.move_speed(100.0, lv1), 102.0)
	_check_approx("Lv1 pickup", EffectProviderScript.normal_pickup_radius(100.0, lv1), 106.0)
	_check_equal("Lv1 exp", EffectProviderScript.exp_amount(25, lv1), 26)
	_check(bool(EffectProviderScript.gift_weights(0.65, 0.35, 0.0, lv1).get("hit", 0.0) > 0.35), "Lv1 gift luck")
	levels["max_hp"] = 5
	levels["attack_power"] = 5
	var lv5 = EffectProviderScript.create_snapshot(profile, database, true)
	_check_equal("Lv5 hp", EffectProviderScript.max_hp(100, lv5), 120)
	_check_approx("Lv5 damage", EffectProviderScript.damage(100.0, lv5), 115.0)

func _test_purchase_reset_and_save_rollback(database) -> void:
	save_should_fail = false
	var store = SaveStoreScript.new()
	store.save_override = Callable(self, "_save_override")
	var manager = ShopManagerScript.new(database, store)
	manager.profile["unlocked"] = true
	manager.profile["currentPoints"] = 1000
	var initial_level: int = manager.get_upgrade_level("max_hp")
	_check_equal("purchase success", manager.purchase_upgrade("max_hp"), 0)
	_check_equal("purchase level", manager.get_upgrade_level("max_hp"), initial_level + 1)
	_check_equal("purchase balance", manager.current_points(), 880)
	save_should_fail = true
	var before_failed: String = JSON.stringify(manager.profile)
	_check_equal("purchase save failure", manager.purchase_upgrade("attack_power"), 6)
	_check_equal("purchase rollback", JSON.stringify(manager.profile), before_failed)
	save_should_fail = false
	_check_equal("reset success", manager.reset_all_upgrades(), 0)
	_check_equal("reset level", manager.get_upgrade_level("max_hp"), 0)
	_check_equal("reset refund", manager.current_points(), 1000)
	manager.profile["currentPoints"] = 1000
	manager.profile["upgrades"]["max_hp"] = 1
	save_should_fail = true
	var before_reset_failure: String = JSON.stringify(manager.profile)
	_check_equal("reset save failure", manager.reset_all_upgrades(), 6)
	_check_equal("reset rollback", JSON.stringify(manager.profile), before_reset_failure)
	save_should_fail = false
	var atomic_store = SaveStoreScript.new()
	atomic_store.path = "user://power_up_shop_atomic_test.json"
	atomic_store.backup_path = "user://power_up_shop_atomic_test.json.bak"
	atomic_store.temp_path = "user://power_up_shop_atomic_test.json.tmp"
	var atomic_data: Dictionary = atomic_store.default_data(database)
	atomic_data["unlocked"] = true
	atomic_data["currentPoints"] = 321
	_check(atomic_store.save_data(atomic_data, database), "atomic disk save")
	var atomic_loaded: Dictionary = atomic_store.load_data(database)
	_check_equal("atomic disk load", int(atomic_loaded.get("currentPoints", 0)), 321)
	_cleanup_user_file(atomic_store.path)
	_cleanup_user_file(atomic_store.backup_path)
	_cleanup_user_file(atomic_store.temp_path)

func _test_reward_deduplication(database) -> void:
	var store = SaveStoreScript.new()
	store.save_override = Callable(self, "_save_override")
	var manager = ShopManagerScript.new(database, store)
	var boss := {
		"bossId": "boss_kuso_maro_king",
		"ppRewardId": "kusomaro_king",
		"basePpReward": 75,
		"isPpRewardTarget": true,
		"isFirstDefeatRewardTarget": true,
		"defeatReason": "player_side_damage",
		"rewardKey": "boss:stable-test:kuso"
	}
	var reward = _reward({"outcome": "completed", "rewardEligible": true, "isRelay": false, "activePlaySeconds": 180.0, "stageId": "zatsudan", "stageCleared": true, "defeatedBosses": [boss]})
	var first = manager.grant_reward("run_test_once", reward)
	var balance_after_first: int = manager.current_points()
	var second = manager.grant_reward("run_test_other", reward)
	var balance_after_key_duplicate: int = manager.current_points()
	var third = manager.grant_reward("run_test_other", reward)
	_check(bool(first.get("ok", false)), "reward grant success")
	_check_equal("duplicate reward key points", balance_after_key_duplicate, balance_after_first + 150)
	_check_equal("duplicate reward state", String(third.get("state", "")), "already_granted")
	_check_equal("duplicate reward balance", manager.current_points(), balance_after_key_duplicate)

func _test_legacy_migration(database) -> void:
	var progress_path := "user://stream_frame_progress.json"
	var rankings_path := "user://rankings.json"
	var migration_path := "user://power_up_shop_migration_test.json"
	var old_progress := _read_user_text(progress_path)
	var old_rankings := _read_user_text(rankings_path)
	_write_user_text(progress_path, JSON.stringify({"streamFrameProgress": {"zatsudan": {"isCleared": true}}}))
	_write_user_text(rankings_path, JSON.stringify({
		"rankingEntries": [{"modeId": "normal_180", "endType": "completed", "bossDefeated": true, "bossId": "red_pen_review_chief"}],
		"relayRankingEntries": [{"isRelayCompleted": true}]
	}))
	var store = SaveStoreScript.new()
	store.path = migration_path
	store.backup_path = migration_path + ".bak"
	store.temp_path = migration_path + ".tmp"
	var migrated: Dictionary = store.load_data(database)
	_check(bool(migrated.get("unlocked", false)), "legacy unlock migration")
	_check(bool((migrated.get("firstStageClears", {}) as Dictionary).get("zatsudan", false)), "legacy stage migration")
	_check(bool((migrated.get("firstBossDefeats", {}) as Dictionary).get("redpen_retake_dragon", false)), "legacy boss alias migration")
	_check(bool(migrated.get("firstRelayClear", false)), "legacy relay migration")
	_cleanup_user_file(migration_path)
	_cleanup_user_file(migration_path + ".bak")
	_cleanup_user_file(migration_path + ".tmp")
	_restore_user_text(progress_path, old_progress)
	_restore_user_text(rankings_path, old_rankings)

func _reward(input: Dictionary, first_stages: Dictionary = {}, first_bosses: Dictionary = {}, first_relay: bool = false):
	return RewardCalculatorScript.calculate(input, first_stages, first_bosses, first_relay)

func _database_upgrades() -> Array:
	var database = DatabaseScript.load_default()
	return database.upgrades as Array

func _save_override(_data: Dictionary) -> bool:
	return not save_should_fail

func _check(condition: bool, label: String) -> void:
	if not condition:
		failures.append(label)

func _check_equal(label: String, actual, expected) -> void:
	_check(actual == expected, "%s: expected %s, got %s" % [label, str(expected), str(actual)])

func _check_approx(label: String, actual: float, expected: float, tolerance: float = 0.001) -> void:
	_check(absf(actual - expected) <= tolerance, "%s: expected %s, got %s" % [label, str(expected), str(actual)])

func _read_user_text(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	return FileAccess.get_file_as_string(path)

func _write_user_text(path: String, value: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_string(value)
		file.close()

func _restore_user_text(path: String, value: String) -> void:
	if value == "":
		_cleanup_user_file(path)
		return
	_write_user_text(path, value)

func _cleanup_user_file(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
