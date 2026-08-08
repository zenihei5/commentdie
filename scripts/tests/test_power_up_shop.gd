extends Node

const DatabaseScript := preload("res://scripts/systems/power_up_database.gd")
const SaveStoreScript := preload("res://scripts/systems/power_up_save_store.gd")
const ShopManagerScript := preload("res://scripts/systems/power_up_shop_manager.gd")
const EffectProviderScript := preload("res://scripts/systems/power_up_effect_provider.gd")
const RewardCalculatorScript := preload("res://scripts/systems/stream_point_reward_calculator.gd")
const ResultSystemScript := preload("res://scripts/systems/result_system.gd")
const GameScript := preload("res://scripts/game.gd")
const WeaponSystemScript := preload("res://scripts/systems/weapon_system.gd")
const GiftSystemScript := preload("res://scripts/systems/gift_system.gd")
const RelayRunDataScript := preload("res://scripts/systems/relay_run_data.gd")
const UiStateScript := preload("res://scripts/ui/power_up_shop_ui_state.gd")
const RunStateSystemScript := preload("res://scripts/systems/run_state_system.gd")

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
	_test_result_reward_view_adapter()
	_test_effect_snapshots(database)
	_test_new_lineup_helpers()
	_test_purchase_reset_and_save_rollback(database)
	_test_character_selection_save(database)
	_test_reward_deduplication(database)
	_test_direct_pp_reward_grant(database)
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
	var total_max_level := 0
	for item in _database_upgrades():
		var upgrade: Dictionary = item as Dictionary
		total_max_level += int(upgrade.get("maxLevel", 0))
		for price in upgrade.get("prices", []) as Array:
			total_cost += int(price)
	_check_equal("twelve upgrade master count", _database_upgrades().size(), 12)
	_check_equal("combat master count", _database.upgrades_for_category("combat").size(), 6)
	_check_equal("support master count", _database.upgrades_for_category("support").size(), 6)
	_check_equal("new lineup order", String((_database_upgrades()[2] as Dictionary).get("id", "")) + "," + String((_database_upgrades()[3] as Dictionary).get("id", "")) + "," + String((_database_upgrades()[10] as Dictionary).get("id", "")) + "," + String((_database_upgrades()[11] as Dictionary).get("id", "")), "attack_area,attack_interval,buzz_keep,gift_reroll")
	_check_equal("all upgrade cost", total_cost, 22080)
	_check_equal("dynamic maximum level", total_max_level, 60)
	var attack_area: Dictionary = _database_upgrades()[2] as Dictionary
	var attack_interval: Dictionary = _database_upgrades()[3] as Dictionary
	var buzz_keep: Dictionary = _database_upgrades()[10] as Dictionary
	var gift_reroll: Dictionary = _database_upgrades()[11] as Dictionary
	_check((attack_area.get("values", []) as Array) == [0.0, 0.02, 0.04, 0.06, 0.08, 0.10], "attack area values")
	_check((attack_interval.get("values", []) as Array) == [0.0, 0.02, 0.04, 0.06, 0.08, 0.10], "attack interval values")
	_check((buzz_keep.get("values", []) as Array) == [0, 1, 2, 3, 4, 5], "buzz keep values")
	_check((gift_reroll.get("values", []) as Array) == [0, 1, 2, 3, 4, 5], "gift reroll values")
	_check(String((attack_interval.get("cardSummary", {}) as Dictionary).get("format", "")) == "percent_down", "attack interval uses shortened-percent display")
	_check(String((buzz_keep.get("cardSummary", {}) as Dictionary).get("format", "")) == "count" and String((gift_reroll.get("cardSummary", {}) as Dictionary).get("format", "")) == "count", "charge upgrades use count display")

func _test_result_reward_view_adapter() -> void:
	var normal := {
		"participationPp": 5,
		"progressPp": 45,
		"clearPp": 100,
		"totalPp": 150
	}
	var normal_view: Dictionary = ResultSystemScript.build_point_reward_view(normal, "granted", 52, 150, 202, false)
	_check_equal("result view before", int(normal_view.get("pointsBefore", -1)), 52)
	_check_equal("result view earned", int(normal_view.get("pointsEarned", -1)), 150)
	_check_equal("result view after", int(normal_view.get("pointsAfter", -1)), 202)
	_check_equal("result view row count", (normal_view.get("rewardRows", []) as Array).size(), 3)
	_check_equal("result view row sum", _reward_row_sum(normal_view), 150)
	var relay := {
		"participationPp": 10,
		"relayStagePp": 250,
		"relayFinalReachedPp": 150,
		"relayFinalClearPp": 200,
		"bossDefeatPp": 150,
		"firstRelayClearPp": 200,
		"totalPp": 960
	}
	var relay_view: Dictionary = ResultSystemScript.build_point_reward_view(relay, "granted", 0, 960, 960, true)
	_check_equal("relay row sum", _reward_row_sum(relay_view), 960)
	var already: Dictionary = ResultSystemScript.build_point_reward_view(normal, "already_granted", 52, 0, 52, false)
	_check_equal("already granted rows hidden", (already.get("rewardRows", []) as Array).size(), 0)
	for row_value in normal_view.get("rewardRows", []) as Array:
		_check(int((row_value as Dictionary).get("amount", 0)) > 0, "result view excludes zero rows")

func _reward_row_sum(view: Dictionary) -> int:
	var total := 0
	for row_value in view.get("rewardRows", []) as Array:
		total += int((row_value as Dictionary).get("amount", 0))
	return total

func _test_effect_snapshots(database) -> void:
	var store = SaveStoreScript.new()
	var profile: Dictionary = store.default_data(database)
	var on = EffectProviderScript.create_snapshot(profile, database, true)
	var off = EffectProviderScript.create_snapshot(profile, database, false)
	_check_equal("Lv0 hp", EffectProviderScript.max_hp(100, on), 100)
	_check_approx("Lv0 damage", EffectProviderScript.damage(10.0, on), 10.0)
	_check_equal("OFF hp", EffectProviderScript.max_hp(100, off), 100)
	_check_approx("OFF damage", EffectProviderScript.damage(10.0, off), 10.0)
	_check_approx("OFF attack area", off.attack_area_multiplier, 1.0)
	_check_approx("OFF attack interval", off.attack_interval_multiplier, 1.0)
	_check_equal("OFF buzz keep", off.initial_buzz_keep_charges, 0)
	_check_equal("OFF gift reroll", off.initial_gift_reroll_count, 0)
	var levels: Dictionary = profile["upgrades"] as Dictionary
	for id in levels.keys():
		levels[id] = 1
	var lv1 = EffectProviderScript.create_snapshot(profile, database, true)
	_check_equal("Lv1 hp", EffectProviderScript.max_hp(100, lv1), 104)
	_check_approx("Lv1 damage", EffectProviderScript.damage(100.0, lv1), 103.0)
	_check_approx("Lv1 move", EffectProviderScript.move_speed(100.0, lv1), 102.0)
	_check_approx("Lv1 attack area", lv1.attack_area_multiplier, 1.02)
	_check_approx("Lv1 attack interval", lv1.attack_interval_multiplier, 0.98)
	_check_equal("Lv1 buzz keep", lv1.initial_buzz_keep_charges, 1)
	_check_equal("Lv1 gift reroll", lv1.initial_gift_reroll_count, 1)
	_check_approx("Lv1 pickup", EffectProviderScript.normal_pickup_radius(100.0, lv1), 106.0)
	_check_equal("Lv1 exp", EffectProviderScript.exp_amount(25, lv1), 26)
	_check(bool(EffectProviderScript.gift_weights(0.65, 0.35, 0.0, lv1).get("hit", 0.0) > 0.35), "Lv1 gift luck")
	levels["max_hp"] = 5
	levels["attack_power"] = 5
	levels["attack_area"] = 5
	levels["attack_interval"] = 5
	levels["buzz_keep"] = 5
	levels["gift_reroll"] = 5
	var lv5 = EffectProviderScript.create_snapshot(profile, database, true)
	_check_equal("Lv5 hp", EffectProviderScript.max_hp(100, lv5), 120)
	_check_approx("Lv5 damage", EffectProviderScript.damage(100.0, lv5), 115.0)
	_check_approx("Lv5 attack area", lv5.attack_area_multiplier, 1.10)
	_check_approx("Lv5 attack interval", lv5.attack_interval_multiplier, 0.90)
	_check_equal("Lv5 buzz keep", lv5.initial_buzz_keep_charges, 5)
	_check_equal("Lv5 gift reroll", lv5.initial_gift_reroll_count, 5)

func _test_new_lineup_helpers() -> void:
	_check_approx("attack interval base floor", WeaponSystemScript.player_attack_interval(1.0, 0.25), 0.50)
	_check_approx("attack interval keeps rate", WeaponSystemScript.player_attack_interval(1.0, 0.80), 0.80)
	_check_approx("attack area cap", WeaponSystemScript.attack_area_rate({"attackAreaRate": 2.0}), 1.60)
	var buzz_card := Rect2(440.0, 18.0, 220.0, 80.0)
	var protection_badge: Rect2 = GameScript._buzz_protection_badge_rect(buzz_card)
	_check(protection_badge.size.x >= 82.0 and protection_badge.size.x <= 88.0, "buzz protection badge width")
	_check(protection_badge.size.y >= 24.0 and protection_badge.size.y <= 28.0, "buzz protection badge height")
	_check(protection_badge.position.x >= buzz_card.position.x and protection_badge.end.x <= buzz_card.end.x, "buzz protection badge stays inside card")
	_check(protection_badge.end.y <= buzz_card.position.y + 32.0, "buzz protection badge avoids value row")
	var count_chip: Rect2 = GameScript._buzz_protection_badge_chip_rect(protection_badge, 0.0)
	_check(count_chip.size.x >= 26.0 and count_chip.size.x <= 30.0, "buzz protection count chip width")
	_check(count_chip.size.y >= 20.0 and count_chip.size.y <= 22.0, "buzz protection count chip height")
	for protection_count in [1, 3, 10, 99, 100, 125]:
		var expected_count_text := str(protection_count) if protection_count < 100 else "9+"
		_check_equal("protection count text %d" % protection_count, GameScript._buzz_protection_badge_count_text(protection_count), expected_count_text)
	var pulse_badge: Rect2 = GameScript._buzz_protection_badge_visual_rect(protection_badge, 1.0).grow(3.0)
	_check(pulse_badge.position.x >= buzz_card.position.x and pulse_badge.end.x <= buzz_card.end.x, "buzz protection pulse stays inside card horizontally")
	_check(pulse_badge.position.y >= buzz_card.position.y and pulse_badge.end.y <= buzz_card.end.y, "buzz protection pulse stays inside card vertically")
	var buzz_text_x := buzz_card.position.x + 72.0
	var normal_buzz_widths: Dictionary = GameScript._buzz_status_card_text_widths(buzz_card, buzz_text_x, 0)
	for protection_count in [0, 1, 12]:
		var buzz_widths: Dictionary = GameScript._buzz_status_card_text_widths(buzz_card, buzz_text_x, protection_count)
		_check_equal("bonus width keeps full card width (%d)" % protection_count, int(buzz_widths["bonusTextWidth"]), int(normal_buzz_widths["bonusTextWidth"]))
		_check_equal("base width stays stable (%d)" % protection_count, int(buzz_widths["baseTextWidth"]), int(normal_buzz_widths["baseTextWidth"]))
	_check(int((GameScript._buzz_status_card_text_widths(buzz_card, buzz_text_x, 1))["topTextWidth"]) < int(normal_buzz_widths["topTextWidth"]), "protected badge narrows top row only")
	var gift_panel := Rect2(270.0, 160.0, 890.0, 500.0)
	var reroll_bar: Rect2 = GameScript._gift_reroll_action_rect(gift_panel, 600.0)
	_check_equal("gift reroll bar width", reroll_bar.size.x, 340.0)
	_check_equal("gift reroll bar height", reroll_bar.size.y, 52.0)
	_check_equal("gift reroll bar centered", reroll_bar.get_center().x, gift_panel.get_center().x)
	_check(reroll_bar.position.y >= 606.0 and reroll_bar.end.y <= gift_panel.end.y, "gift reroll bar below cards and inside panel")
	var database = DatabaseScript.load_default()
	var interval_view: Dictionary = UiStateScript.build(database.get_upgrade("attack_interval"), 5, 10000)
	_check_equal("attack interval display reduction", String(interval_view.get("currentEffectText", "")), "-10%")
	var keep_view: Dictionary = UiStateScript.build(database.get_upgrade("buzz_keep"), 3, 10000)
	_check_equal("buzz keep display count", String(keep_view.get("currentEffectText", "")), "3回")
	var reroll_view: Dictionary = UiStateScript.build(database.get_upgrade("gift_reroll"), 5, 10000)
	_check_equal("gift reroll display count", String(reroll_view.get("currentEffectText", "")), "5回")
	var snapshot = EffectProviderScript.create_snapshot({"upgrades": {"buzz_keep": 2, "gift_reroll": 4}}, database, true)
	var run_flags: Dictionary = RunStateSystemScript.gift_flags(snapshot)
	_check_equal("run starts buzz keep charges", int(run_flags.get("burnResistCharges", -1)), 2)
	_check_equal("run starts gift rerolls", int(run_flags.get("giftRerollRemaining", -1)), 4)
	var snapshot_copy = snapshot.copy_snapshot()
	_check_approx("snapshot copy attack area default", snapshot_copy.attack_area_multiplier, 1.0)
	_check_equal("snapshot dictionary keeps rerolls", int(snapshot.to_dictionary().get("initialGiftRerollCount", -1)), 4)
	var gift := {"id": "gift_a", "effectType": "weapon", "levelGain": 2, "giftQuality": "hit"}
	_check_equal("gift reroll signature", GiftSystemScript.gift_offer_signature(gift), "weapon|gift_a|2|hit")
	var relay_probe = GameScript.new()
	relay_probe.burn_resist_charges = 3
	relay_probe.gift_reroll_remaining = 2
	var relay_snapshot: Dictionary = RelayRunDataScript.capture(relay_probe)
	_check_equal("relay captures buzz keep", int(relay_snapshot.get("burnResistCharges", -1)), 3)
	_check_equal("relay captures gift reroll", int(relay_snapshot.get("giftRerollRemaining", -1)), 2)
	relay_probe.burn_resist_charges = 0
	relay_probe.gift_reroll_remaining = 0
	RelayRunDataScript.apply(relay_probe, relay_snapshot)
	_check_equal("relay restores buzz keep", relay_probe.burn_resist_charges, 3)
	_check_equal("relay restores gift reroll", relay_probe.gift_reroll_remaining, 2)
	relay_probe.free()

func _test_purchase_reset_and_save_rollback(database) -> void:
	save_should_fail = false
	var store = SaveStoreScript.new()
	store.save_override = Callable(self, "_save_override")
	var manager = ShopManagerScript.new(database, store)
	manager.profile = store.default_data(database)
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
	var levels: Dictionary = manager.profile["upgrades"] as Dictionary
	levels["max_hp"] = 5
	levels["attack_power"] = 3
	manager.profile["currentPoints"] = 100
	var mixed_before := manager.current_points()
	var mixed_refund := manager.calculate_refund_points()
	_check(mixed_refund > 0, "mixed levels have a refund")
	_check_equal("mixed reset success", manager.reset_all_upgrades(), 0)
	_check_equal("mixed reset balance", manager.current_points(), mixed_before + mixed_refund)
	_check_equal("mixed reset max hp", manager.get_upgrade_level("max_hp"), 0)
	_check_equal("mixed reset attack", manager.get_upgrade_level("attack_power"), 0)
	_check_equal("second reset without levels", manager.reset_all_upgrades(), 7)
	levels = manager.profile["upgrades"] as Dictionary
	for id in levels.keys():
		levels[id] = 5
	manager.profile["currentPoints"] = 0
	var all_five_refund := manager.calculate_refund_points()
	_check_equal("all Lv5 refund total", all_five_refund, 22080)
	_check_equal("all Lv5 reset success", manager.reset_all_upgrades(), 0)
	_check_equal("all Lv5 reset balance", manager.current_points(), all_five_refund)
	_check_equal("all Lv5 reset total level", manager.total_upgrade_level(), 0)
	var inconsistent_store = SaveStoreScript.new()
	var inconsistent_manager = ShopManagerScript.new(database, inconsistent_store)
	inconsistent_manager.profile = inconsistent_store.default_data(database)
	inconsistent_manager.profile["unlocked"] = true
	inconsistent_manager.profile["currentPoints"] = 77
	var inconsistent_levels: Dictionary = inconsistent_manager.profile["upgrades"] as Dictionary
	inconsistent_levels["unknown_upgrade"] = 1
	var inconsistent_before := JSON.stringify(inconsistent_manager.profile)
	_check_equal("inconsistent refund is zero", inconsistent_manager.calculate_refund_points(), 0)
	_check_equal("inconsistent reset aborts", inconsistent_manager.reset_all_upgrades(), 7)
	_check_equal("inconsistent reset preserves profile", JSON.stringify(inconsistent_manager.profile), inconsistent_before)
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

func _test_direct_pp_reward_grant(database) -> void:
	var store = SaveStoreScript.new()
	store.save_override = Callable(self, "_save_override")
	var manager = ShopManagerScript.new(database, store)
	var reward = _reward({
		"outcome": "defeated",
		"rewardEligible": true,
		"isRelay": false,
		"activePlaySeconds": 0.0,
		"stageId": "zatsudan",
		"stageCleared": false,
		"fieldGiftPp": 5,
		"fallbackGiftPp": 10,
		"fullBuildConversionPp": 15
	})
	var expected_total := int(reward.total_pp)
	var before_balance := manager.current_points()
	var grant: Dictionary = manager.grant_reward("run_direct_pp_test", reward)
	_check(bool(grant.get("ok", false)), "direct PP reward grant succeeds")
	_check_equal("direct PP subtotal survives manager grant", reward.direct_pp_subtotal, 30)
	_check_equal("direct PP enters saved balance", manager.current_points(), before_balance + expected_total)

func _test_character_selection_save(database) -> void:
	save_should_fail = false
	var store = SaveStoreScript.new()
	store.save_override = Callable(self, "_save_override")
	var manager = ShopManagerScript.new(database, store)
	manager.profile = store.default_data(database)
	manager.profile["normalRelayCleared"] = true
	manager.profile["unlockedCharacterIds"] = (
		SaveStoreScript.ALWAYS_UNLOCKED_CHARACTER_IDS.duplicate()
		+ SaveStoreScript.SENIOR_UNIT_CHARACTER_IDS.duplicate()
	)
	_check(manager.save_selected_character_id("aosumi_kyasumi"), "save selected Kyuasmi")
	_check_equal("selected Kyuasmi persisted", manager.selected_character_id(), "aosumi_kyasumi")
	_check(manager.save_selected_character_id("aosumi_kyasumi"), "reselecting Kyuasmi is a successful no-op")
	save_should_fail = true
	_check(not manager.save_selected_character_id("akarine_rizumu"), "real character selection save failure is reported")
	_check_equal("failed character save keeps previous selection", manager.selected_character_id(), "aosumi_kyasumi")
	save_should_fail = false
	_check(not manager.save_selected_character_id("unknown_character"), "unknown character selection is rejected")

func _test_legacy_migration(database) -> void:
	var migration_store = SaveStoreScript.new()
	var old_profile := migration_store.default_data(database)
	old_profile["currentPoints"] = 4321
	var old_levels: Dictionary = old_profile["upgrades"] as Dictionary
	old_levels["max_hp"] = 2
	old_levels["attack_power"] = 1
	old_levels.erase("attack_area")
	old_levels.erase("attack_interval")
	old_levels.erase("buzz_keep")
	old_levels.erase("gift_reroll")
	var normalized := migration_store.normalize(old_profile, database)
	_check_equal("legacy new attack area defaults", int((normalized["upgrades"] as Dictionary).get("attack_area", -1)), 0)
	_check_equal("legacy new attack interval defaults", int((normalized["upgrades"] as Dictionary).get("attack_interval", -1)), 0)
	_check_equal("legacy new buzz keep defaults", int((normalized["upgrades"] as Dictionary).get("buzz_keep", -1)), 0)
	_check_equal("legacy new gift reroll defaults", int((normalized["upgrades"] as Dictionary).get("gift_reroll", -1)), 0)
	_check_equal("legacy PP preserved", int(normalized.get("currentPoints", -1)), 4321)
	_check_equal("legacy existing level preserved", int((normalized["upgrades"] as Dictionary).get("max_hp", -1)), 2)
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
