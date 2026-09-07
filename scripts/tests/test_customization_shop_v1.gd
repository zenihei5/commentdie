extends Node

const PowerUpDatabaseScript := preload("res://scripts/systems/power_up_database.gd")
const SaveStoreScript := preload("res://scripts/systems/power_up_save_store.gd")
const ShopManagerScript := preload("res://scripts/systems/power_up_shop_manager.gd")
const CustomizationDatabaseScript := preload("res://scripts/systems/customization_database.gd")
const CustomizationProviderScript := preload("res://scripts/systems/customization_provider.gd")
const ScreenScene := preload("res://scripts/ui/power_up_shop_screen.tscn")
const GameScene := preload("res://scenes/main.tscn")

class FakeCodexSource extends RefCounted:
	var totals: Dictionary = {
		"characters": 6,
		"weapons": 26,
		"accessories": 10,
		"enemies": 42,
		"comments": 44,
	}
	var found: Dictionary = {
		"characters": 0,
		"weapons": 0,
		"accessories": 0,
		"enemies": 0,
		"comments": 0,
	}
	var completed_collection := false
	var completed_categories: Dictionary = {}

	func get_total_count(category: String) -> int:
		return int(totals.get(category, 0))

	func get_discovered_count(category: String) -> int:
		return int(found.get(category, 0))

	func collection_completed_once() -> bool:
		return completed_collection

	func category_completed_once(category: String) -> bool:
		return bool(completed_categories.get(category, false))

var failures: Array[String] = []
var checks := 0
var save_calls := 0
var save_should_fail := false
var test_root := ""
var power_database
var customization_database

func _ready() -> void:
	test_root = OS.get_environment("COMMENTDIE_CUSTOMIZATION_TEST_ROOT").replace("\\", "/").trim_suffix("/")
	if test_root == "":
		test_root = OS.get_user_data_dir().replace("\\", "/")
	if not test_root.is_absolute_path():
		test_root = ProjectSettings.globalize_path(test_root).replace("\\", "/")
	DirAccess.make_dir_recursive_absolute(test_root)
	power_database = PowerUpDatabaseScript.load_default()
	customization_database = CustomizationDatabaseScript.load_default()
	_test_master_contract()
	_test_boundary_and_history_logic()
	_test_transactions_and_reset()
	_test_schema5_compatibility()
	_test_notification_baseline()
	await _test_shop_ui_and_renderers()
	var report := {"checks": checks, "failures": failures}
	var report_file := FileAccess.open(test_root.path_join("customization-shop-results.json"), FileAccess.WRITE)
	if report_file != null:
		report_file.store_string(JSON.stringify(report, "\t"))
		report_file.close()
	for failure in failures:
		push_error(failure)
	print("CUSTOMIZATION_SHOP_V1_TESTS: %s (%d checks, %d failures)" % ["PASS" if failures.is_empty() else "FAIL", checks, failures.size()])
	get_tree().quit(0 if failures.is_empty() else 1)

func _test_master_contract() -> void:
	_check(power_database.is_valid, "power-up database remains valid")
	_check(customization_database.is_valid, "customization master is valid")
	_check(customization_database.items.size() == 21, "customization master has twenty-one catalog entries including the mission title")
	_check(customization_database.conditions.size() == 10, "customization master has ten conditions including the mission title condition")
	_check(customization_database.total_price_pp() == 7300, "customization products total 7300 PP")
	var expected_categories := {"title": 11, "theme": 5, "result_stamp": 5}
	for category in expected_categories.keys():
		_check(customization_database.items_for_category(String(category)).size() == int(expected_categories[category]), "product count for %s" % category)
	var expected_ids: Array[String] = [
		"title_comment_regular", "title_went_viral", "title_limit_streamer", "title_viewer_monster", "title_codex_master",
		"title_hako_oshi", "title_weapon_keeper", "title_fully_prepared", "title_troll_observer", "title_comment_ruler",
		"theme_neon_pink", "theme_cyan_light", "theme_lavender_night", "theme_live_gold", "theme_complete_neon",
		"stamp_otsu_stream", "stamp_stream_end", "stamp_archive", "stamp_viral", "stamp_commentdie"
	]
	var shop_items: Array = customization_database.items.filter(func(item: Dictionary) -> bool: return String(item.get("acquisitionType", "purchase")) != "mission_reward")
	_check(shop_items.size() == 20, "customization shop still has twenty purchasable products")
	var shop_ids: Array[String] = []
	for item in shop_items:
		shop_ids.append(String(item.get("id", "")))
	_check(shop_ids == expected_ids, "product IDs and sort order match the V1 contract")
	var theme := CustomizationProviderScript.theme_preset("theme_neon_pink")
	_check(bool(theme.get("enabled", false)) and theme.has("decorativeSecondary") and theme.has("decorativeTertiary"), "theme provider exposes decoration-only secondary colors")
	_check(not bool(CustomizationProviderScript.theme_preset("").get("enabled", true)), "default theme provider is disabled")
	var archive := CustomizationProviderScript.stamp_preset("stamp_archive")
	_check(String(archive.get("motif", "")) == "save_card", "archive stamp uses the save-card motif")

func _test_boundary_and_history_logic() -> void:
	var source := FakeCodexSource.new()
	var manager = _new_manager("boundaries", 0)
	manager.profile["unlocked"] = true
	for condition_id in customization_database.condition_ids():
		manager.profile["unlockedCustomizationConditions"].append(condition_id)
	source.found = {"characters": 6, "weapons": 9, "accessories": 5, "enemies": 0, "comments": 0}
	var collection_25: Dictionary = manager.get_customization_condition_status("collection:25", source)
	_check(int(collection_25.get("total", 0)) == 84 and int(collection_25.get("required", 0)) == 21, "collection 25% derives the official 84-item total")
	_check(not bool(collection_25.get("eligibleNow", true)), "collection 25% stays locked at 20 of 84")
	source.found["accessories"] = 6
	collection_25 = manager.get_customization_condition_status("collection:25", source)
	_check(bool(collection_25.get("eligibleNow", false)) and int(collection_25.get("required", 0)) == 21, "collection 25% unlocks at the ceil boundary")
	source.found["weapons"] = 26
	source.found["accessories"] = 9
	source.found["enemies"] = 0
	var collection_50: Dictionary = manager.get_customization_condition_status("collection:50", source)
	_check(int(collection_50.get("found", 0)) == 41 and int(collection_50.get("required", 0)) == 42, "collection progress excludes the comments category")
	source.found["accessories"] = 10
	collection_50 = manager.get_customization_condition_status("collection:50", source)
	_check(bool(collection_50.get("eligibleNow", false)), "collection 50% unlocks at the dynamic threshold")
	source.totals["weapons"] = 28
	source.found["weapons"] = 27
	var weapons_100: Dictionary = manager.get_customization_condition_status("category:weapons:100", source)
	_check(int(weapons_100.get("total", 0)) == 28 and int(weapons_100.get("required", 0)) == 28 and not bool(weapons_100.get("eligibleNow", true)), "category threshold follows future master totals")
	source.found["weapons"] = 28
	weapons_100 = manager.get_customization_condition_status("category:weapons:100", source)
	_check(bool(weapons_100.get("eligibleNow", false)), "category condition unlocks at the current total")
	source.completed_categories["weapons"] = true
	source.found["weapons"] = 0
	weapons_100 = manager.get_customization_condition_status("category:weapons:100", source)
	_check(bool(weapons_100.get("eligibleNow", false)) and bool(weapons_100.get("completedOnce", false)), "completedOnce preserves category eligibility")

func _test_transactions_and_reset() -> void:
	var source := _full_source()
	var manager = _new_manager("transactions", 10000)
	manager.profile["unlocked"] = true
	manager.profile["unlockedCustomizationConditions"] = customization_database.condition_ids()
	var before_points: int = int(manager.current_points())
	var result := int(manager.purchase_customization("title_comment_regular"))
	_check(result == ShopManagerScript.Result.SUCCESS, "customization purchase succeeds")
	_check(manager.current_points() == before_points - 150 and manager.total_customization_spent_points() == 150, "customization purchase spends only its own PP ledger")
	_check(not manager.equipped_customizations().get("title", "") == "title_comment_regular", "purchase does not auto-equip")
	_check(int(manager.purchase_customization("title_comment_regular")) == ShopManagerScript.Result.INVALID_ID, "duplicate customization purchase is rejected")
	_check(int(manager.equip_customization("title", "title_comment_regular")) == ShopManagerScript.Result.SUCCESS, "owned title equips")
	_check(manager.equipped_customizations().get("title", "") == "title_comment_regular", "title slot stores the owned item")
	_check(manager.current_points() == before_points - 150, "equip does not spend PP")
	_check(int(manager.equip_customization("title", "")) == ShopManagerScript.Result.SUCCESS, "title can be unequipped")
	var equip_guard_manager = _new_manager("equip_guards", 10000)
	equip_guard_manager.profile["unlocked"] = true
	equip_guard_manager.profile["unlockedCustomizationConditions"] = customization_database.condition_ids()
	_check(int(equip_guard_manager.equip_customization("title", "title_went_viral")) == ShopManagerScript.Result.LOCKED, "unowned customization cannot equip")
	_check(int(equip_guard_manager.equip_customization("theme", "title_comment_regular")) == ShopManagerScript.Result.INVALID_ID, "customization cannot equip into another category")
	_check(int(equip_guard_manager.equip_customization("title", "not_a_real_customization")) == ShopManagerScript.Result.INVALID_ID, "invalid customization ID is rejected")
	var failed_manager = _new_manager("transaction_failure", 10000)
	failed_manager.profile["unlocked"] = true
	failed_manager.profile["unlockedCustomizationConditions"] = customization_database.condition_ids()
	var failed_before: Dictionary = failed_manager.profile.duplicate(true)
	save_should_fail = true
	save_calls = 0
	var failed_result := int(failed_manager.purchase_customization("title_went_viral"))
	_check(failed_result == ShopManagerScript.Result.SAVE_FAILED and save_calls == 1, "failed customization purchase reports one save failure")
	_check(failed_manager.profile == failed_before and failed_manager.current_points() == 10000, "failed customization purchase preserves the full profile")
	save_should_fail = false
	_check(int(failed_manager.purchase_customization("title_went_viral")) == ShopManagerScript.Result.SUCCESS, "customization purchase retries after save recovery")
	var restart_directory := test_root.path_join("restart")
	DirAccess.make_dir_recursive_absolute(restart_directory)
	var restart_store = SaveStoreScript.new()
	restart_store.path = restart_directory.path_join("power_up_shop.json")
	restart_store.backup_path = restart_store.path + ".bak"
	restart_store.temp_path = restart_store.path + ".tmp"
	for restart_path in [restart_store.path, restart_store.backup_path, restart_store.temp_path]:
		if FileAccess.file_exists(restart_path):
			DirAccess.remove_absolute(restart_path)
	var restart_manager = ShopManagerScript.new(power_database, restart_store)
	restart_manager.profile["unlocked"] = true
	restart_manager.profile["currentPoints"] = 1000
	restart_manager.profile["unlockedCustomizationConditions"] = customization_database.condition_ids()
	_check(int(restart_manager.purchase_customization("theme_neon_pink")) == ShopManagerScript.Result.SUCCESS, "restart fixture purchases a theme")
	_check(int(restart_manager.equip_customization("theme", "theme_neon_pink")) == ShopManagerScript.Result.SUCCESS, "restart fixture equips a theme")
	var reloaded_manager = ShopManagerScript.new(power_database, restart_store)
	_check(reloaded_manager.purchased_customization_ids().has("theme_neon_pink") and reloaded_manager.equipped_customizations().get("theme", "") == "theme_neon_pink", "purchased and equipped customization survives reload")
	_check(reloaded_manager.current_points() == 650 and reloaded_manager.total_customization_spent_points() == 350, "customization balance and spend survive reload")
	var all_manager = _new_manager("all_customizations", 7300)
	all_manager.profile["unlocked"] = true
	all_manager.profile["unlockedCustomizationConditions"] = customization_database.condition_ids()
	var all_purchases_succeeded := true
	for item_id in customization_database.item_ids():
		if item_id == "title_perfect_streamer":
			continue
		if int(all_manager.purchase_customization(item_id)) != ShopManagerScript.Result.SUCCESS:
			all_purchases_succeeded = false
	_check(all_purchases_succeeded and all_manager.purchased_customization_ids().size() == 20 and all_manager.current_points() == 0 and all_manager.total_customization_spent_points() == 7300, "all twenty shop customizations purchase for exactly 7300 PP")
	var gate_manager = _new_manager("gate", 10000)
	gate_manager.profile["unlocked"] = true
	gate_manager.profile["unlockedCustomizationConditions"] = []
	_check(String(gate_manager.get_customization_status("title_comment_regular", source).get("lockedReason", "")) == "collection_gate", "common collection gate is enforced in status")
	_check(int(gate_manager.purchase_customization("title_comment_regular")) == ShopManagerScript.Result.LOCKED, "common collection gate is enforced in purchase")
	var reset_manager = _new_manager("reset_preserves_custom", 0)
	reset_manager.profile["unlocked"] = true
	reset_manager.profile["upgrades"]["attack_power"] = 2
	reset_manager.profile["purchasedCustomizations"] = ["title_comment_regular", "theme_neon_pink", "stamp_archive"]
	reset_manager.profile["equippedCustomizations"] = {"title": "title_comment_regular", "theme": "theme_neon_pink", "resultStamp": "stamp_archive"}
	reset_manager.profile["totalCustomizationSpentPoints"] = 800
	var reset_result := int(reset_manager.reset_all_upgrades())
	_check(reset_result == ShopManagerScript.Result.SUCCESS, "upgrade reset succeeds with customization data present")
	_check(int(reset_manager.profile["upgrades"]["attack_power"]) == 0, "upgrade reset clears upgrade levels")
	_check(reset_manager.profile["purchasedCustomizations"] == ["title_comment_regular", "theme_neon_pink", "stamp_archive"] and reset_manager.profile["equippedCustomizations"].get("theme", "") == "theme_neon_pink", "upgrade reset preserves purchased and equipped customizations")
	_check(int(reset_manager.profile.get("totalCustomizationSpentPoints", 0)) == 800, "upgrade reset preserves customization spend total")
	var zero_reset_manager = _new_manager("zero_reset", 777)
	zero_reset_manager.profile["unlocked"] = true
	var zero_reset_points: int = zero_reset_manager.current_points()
	_check(int(zero_reset_manager.reset_all_upgrades()) == ShopManagerScript.Result.NOTHING_TO_RESET and zero_reset_manager.current_points() == zero_reset_points, "zero-level reset does not refund or change PP")

func _test_schema5_compatibility() -> void:
	var directory := test_root.path_join("schema5")
	DirAccess.make_dir_recursive_absolute(directory)
	var store = SaveStoreScript.new()
	store.path = directory.path_join("power_up_shop.json")
	store.backup_path = store.path + ".bak"
	store.temp_path = store.path + ".tmp"
	var legacy: Dictionary = store.default_data(power_database)
	legacy["schemaVersion"] = 4
	legacy.erase("unlockedCustomizationConditions")
	legacy.erase("purchasedCustomizations")
	legacy.erase("equippedCustomizations")
	legacy.erase("totalCustomizationSpentPoints")
	legacy["claimedCodexMilestones"] = ["weapons:25"]
	var file := FileAccess.open(store.path, FileAccess.WRITE)
	file.store_string(JSON.stringify({"powerUpShop": legacy}))
	file.close()
	var bytes_before := FileAccess.get_file_as_bytes(store.path)
	var manager = ShopManagerScript.new(power_database, store)
	_check(int(manager.profile.get("schemaVersion", 0)) == 6, "v4 power-up save loads into the current schema in memory")
	_check(manager.profile.get("claimedCodexMilestones", []) == ["weapons:25"], "v4 Codex claim history is preserved")
	_check(manager.profile.get("unlockedCustomizationConditions", []) == [] and manager.profile.get("purchasedCustomizations", []) == [], "v4 save receives empty customization defaults")
	_check(FileAccess.get_file_as_bytes(store.path) == bytes_before, "v4 load does not write a migration file")

func _test_notification_baseline() -> void:
	var source := _full_source()
	for category in ["characters", "weapons", "accessories", "enemies"]:
		source.found[category] = 0
	source.found["characters"] = 6
	source.found["weapons"] = 14
	var manager = _new_manager("notification_baseline", 0)
	manager.profile["unlocked"] = true
	manager.initialize_customization_notification_baseline(source)
	source.found["accessories"] = 1
	save_should_fail = true
	var failed: Dictionary = manager.sync_customization_unlocks(source)
	_check(not bool(failed.get("ok", true)) and failed.get("newlyEligibleConditionIds", []).is_empty(), "failed unlock-history save emits no customization notification")
	save_should_fail = false
	var retry: Dictionary = manager.sync_customization_unlocks(source)
	_check(bool(retry.get("ok", false)) and retry.get("newlyEligibleConditionIds", []).has("collection:25"), "successful retry emits the newly saved customization condition")
	var repeat: Dictionary = manager.sync_customization_unlocks(source)
	_check(repeat.get("newlyEligibleConditionIds", []).is_empty(), "already synchronized customization condition does not notify again")
	var stored_manager = _new_manager("notification_stored_condition", 0)
	stored_manager.profile["unlocked"] = true
	stored_manager.profile["unlockedCustomizationConditions"] = ["category:weapons:100"]
	var dynamic_source := FakeCodexSource.new()
	dynamic_source.totals["weapons"] = 28
	dynamic_source.found["weapons"] = 27
	stored_manager.initialize_customization_notification_baseline(dynamic_source)
	dynamic_source.found["weapons"] = 28
	var stored_sync: Dictionary = stored_manager.sync_customization_unlocks(dynamic_source)
	_check(not (stored_sync.get("newlyEligibleConditionIds", []) as Array).has("category:weapons:100"), "stored category condition is excluded from a new notification")

func _test_shop_ui_and_renderers() -> void:
	save_should_fail = false
	var source := _full_source()
	var manager = _new_manager("ui", 10000)
	manager.profile["unlocked"] = true
	manager.profile["unlockedCustomizationConditions"] = customization_database.condition_ids()
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	var canvas := Control.new()
	canvas.size = Vector2(1280, 720)
	viewport.add_child(canvas)
	var screen: Control = ScreenScene.instantiate() as Control
	canvas.add_child(screen)
	screen.size = Vector2(1280, 720)
	screen.bind_manager(manager)
	screen.bind_codex_source(source)
	_check(screen.open_shop("title", manager), "customization shop opens through the shared screen")
	await _frames(3)
	var default_main_style: StyleBoxFlat = screen.main_panel_backdrop.get_theme_stylebox("panel") as StyleBoxFlat
	var default_main_border := default_main_style.border_color
	var default_combat_tab_style: StyleBoxFlat = screen.combat_tab.get_theme_stylebox("normal") as StyleBoxFlat
	var default_support_tab_style: StyleBoxFlat = screen.support_tab.get_theme_stylebox("normal") as StyleBoxFlat
	var default_pp_style: StyleBoxFlat = screen.pp_capsule.get_theme_stylebox("panel") as StyleBoxFlat
	var default_detail_accent: Color = screen.detail_accent_band.color
	manager.profile["purchasedCustomizations"] = ["theme_neon_pink"]
	_check(int(manager.equip_customization("theme", "theme_neon_pink")) == ShopManagerScript.Result.SUCCESS, "theme equips through the shared manager")
	var theme_preset := CustomizationProviderScript.theme_preset("theme_neon_pink")
	var themed_main_style: StyleBoxFlat = screen.main_panel_backdrop.get_theme_stylebox("panel") as StyleBoxFlat
	_check(themed_main_style.border_color == theme_preset.get("decorativeBorder", Color.WHITE), "equipped theme changes only the power-up outer frame")
	_check(screen.customization_decoration_layer.visible and screen.customization_decoration_lines[0].color == Color(theme_preset.get("decorativeAccent", Color.WHITE), 0.86), "equipped theme draws decorative frame lines")
	_check(screen.combat_tab.get_theme_stylebox("normal").bg_color == default_combat_tab_style.bg_color and screen.support_tab.get_theme_stylebox("normal").bg_color == default_support_tab_style.bg_color, "equipped theme preserves semantic category colors")
	_check(screen.pp_capsule.get_theme_stylebox("panel").bg_color == default_pp_style.bg_color and screen.detail_accent_band.color == default_detail_accent, "equipped theme preserves PP and detail semantic colors")
	var themed_line_color: Color = screen.customization_decoration_lines[0].color
	screen.size = Vector2(1600, 900)
	screen._layout_responsive()
	_check(screen.customization_decoration_layer.visible and screen.customization_decoration_lines[0].color == themed_line_color, "resize preserves the equipped theme decoration")
	screen.size = Vector2(1280, 720)
	screen._layout_responsive()
	await _capture_viewport(viewport, test_root.path_join("custom-power-up-theme-neon-pink-1280x720.png"))
	_check(int(manager.equip_customization("theme", "")) == ShopManagerScript.Result.SUCCESS, "theme can be unequipped through the shared screen")
	var restored_main_style: StyleBoxFlat = screen.main_panel_backdrop.get_theme_stylebox("panel") as StyleBoxFlat
	_check(restored_main_style.border_color == default_main_border and not screen.customization_decoration_layer.visible, "unequipping restores the default outer frame and removes decoration lines")
	screen._select_upper_tab(1, false)
	await _frames(3)
	var panel = screen.customization_panel
	_check(panel.visible and panel._category_buttons.size() == 3 and panel._items.size() == 10, "title customization panel exposes lower tabs and ten shop titles")
	_check(panel._grid.size.x <= panel._scroll.size.x + 1.0, "title grid stays inside the scroll viewport")
	_check(panel._list_rect.encloses(Rect2(panel._list_rect.position, panel._list_rect.size)), "title list rect is well formed")
	panel._select_category(1)
	await _frames(3)
	_check(panel._items.size() == 5 and panel._grid.size.x <= panel._scroll.size.x + 1.0, "theme grid stays inside the list after category refresh")
	await _capture_viewport(viewport, test_root.path_join("custom-shop-theme-1280x720.png"))
	panel._select_category(2)
	panel._on_item_pressed(2)
	await _frames(3)
	await _capture_viewport(viewport, test_root.path_join("custom-shop-stamp-archive-1280x720.png"))
	_check(String(panel._detail_name.text) == "アーカイブ残します", "archive stamp detail is selected")
	panel._select_category(0)
	panel._on_item_pressed(0)
	var points_before: int = int(manager.current_points())
	var purchase_calls_before := int(panel.purchase_api_call_count)
	screen._input(_key_event(KEY_ENTER))
	_check(manager.current_points() == points_before - 150 and manager.equipped_customizations().get("title", "") == "", "keyboard confirmation purchases without auto-equip")
	_check(int(panel.purchase_api_call_count) == purchase_calls_before + 1, "keyboard confirmation calls purchase once")
	screen._input(_key_event(KEY_ENTER))
	_check(manager.equipped_customizations().get("title", "") == "title_comment_regular" and manager.current_points() == points_before - 150, "second confirmation equips without another purchase")
	panel.focus_area = panel.FocusArea.BACK
	panel.handle_action("left")
	_check(screen.visible, "horizontal movement on Back does not close the shop")
	manager.profile["upgrades"]["attack_power"] = 1
	screen._show_power_up_view(true)
	screen._show_reset_dialog()
	await _frames(14)
	var tab_before := int(screen.upper_tab_index)
	screen._on_upper_tab_pressed(1)
	_check(int(screen.upper_tab_index) == tab_before and not panel.visible and screen.dialog_layer.visible, "reset modal blocks upper customization tab switching")
	_check(screen.dialog_layer.z_index > screen.upper_tab_bar.z_index, "reset modal is rendered above upper tabs")
	screen._hide_dialog()
	await _frames(2)
	viewport.queue_free()
	await get_tree().process_frame
	await _test_game_shop_navigation()
	await _capture_game_renderers(manager, source)

func _test_game_shop_navigation() -> void:
	var game = GameScene.instantiate()
	add_child(game)
	await _frames(3)
	var game_manager = game.power_up_shop_manager
	game_manager.profile["unlocked"] = true
	game_manager.profile["currentPoints"] = 1000
	game.state = "title"
	game._prepare_power_up_shop("title")
	await _frames(2)
	_check(game.state == "power_up_shop" and game.power_up_shop_screen.visible, "title route opens the shared customization shop")
	game.power_up_shop_screen.close_shop(false)
	await _frames(2)
	_check(game.state == "title" and not game.power_up_shop_screen.visible, "title shop route returns to title")
	game.state = "result"
	game.relay_mode = true
	game._prepare_power_up_shop("result")
	await _frames(2)
	game.power_up_shop_screen.close_shop(false)
	await _frames(2)
	_check(game.state == "stream_frame_select" and game.relay_mode, "relay result shop route returns to stream-frame selection")
	game.state = "title"
	game._prepare_title_ranking()
	await _frames(2)
	_check(game.state == "ranking", "ranking route remains reachable after shop navigation")
	game.queue_free()
	await get_tree().process_frame

func _capture_game_renderers(manager, _source) -> void:
	manager.profile["purchasedCustomizations"] = customization_database.item_ids()
	manager.profile["equippedCustomizations"] = {"title": "title_comment_ruler", "theme": "theme_complete_neon", "resultStamp": "stamp_archive"}
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1600, 900)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	var game = GameScene.instantiate()
	viewport.add_child(game)
	await _frames(3)
	game.power_up_shop_manager = manager
	game.state = "result"
	game.last_result_data = {
		"endType": "completed",
		"characterId": "ban_chan",
		"characterName": "ばんり",
		"streamFrameId": "zatsudan",
		"streamFrameName": "雑談枠",
		"difficultyId": "normal",
		"viewerCount": 1234,
		"survivalTime": 180.0,
		"maxVoltage": 1.4,
		"maxBurnCombo": 12,
		"giftCount": 2,
		"pointRewardView": {"grantState": "granted", "pointsBefore": 1000, "pointsEarned": 100, "pointsAfter": 1100, "rewardRows": []}
	}
	game.result_drop_timer = 0.0
	game.result_reveal_active = false
	game.result_reveal_complete = true
	game.queue_redraw()
	await _frames(3)
	await _capture_viewport(viewport, test_root.path_join("custom-result-1600x900.png"))
	game.state = "character_select"
	game.selected_character_index = 0
	game.queue_redraw()
	await _frames(3)
	await _capture_viewport(viewport, test_root.path_join("custom-character-select-1600x900.png"))
	viewport.queue_free()
	await get_tree().process_frame

func _new_manager(id: String, points: int):
	var directory := test_root.path_join("saves")
	DirAccess.make_dir_recursive_absolute(directory)
	var store = SaveStoreScript.new()
	store.path = directory.path_join(id + ".json")
	store.backup_path = store.path + ".bak"
	store.temp_path = store.path + ".tmp"
	store.save_override = Callable(self, "_save_override")
	var manager = ShopManagerScript.new(power_database, store)
	manager.profile = store.default_data(power_database)
	manager.profile["currentPoints"] = points
	return manager

func _full_source() -> FakeCodexSource:
	var source := FakeCodexSource.new()
	for category in ["characters", "weapons", "accessories", "enemies"]:
		source.found[category] = source.totals[category]
	return source

func _save_override(_candidate: Dictionary) -> bool:
	save_calls += 1
	return not save_should_fail

func _frames(count: int) -> void:
	for _index in range(count):
		await get_tree().process_frame

func _capture_viewport(viewport: SubViewport, path: String) -> void:
	if DisplayServer.get_name().to_lower() == "headless":
		return
	await _frames(2)
	var texture := viewport.get_texture()
	if texture == null:
		_check(false, "viewport texture exists for %s" % path.get_file())
		return
	var image := texture.get_image()
	_check(image != null and image.save_png(path) == OK, "saved %s" % path.get_file())

func _key_event(keycode: Key) -> InputEventKey:
	var event := InputEventKey.new()
	event.pressed = true
	event.keycode = keycode
	return event

func _check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures.append(label)
