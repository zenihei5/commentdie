extends Node

const Database := preload("res://scripts/systems/power_up_database.gd")
const SaveStore := preload("res://scripts/systems/power_up_save_store.gd")
const Manager := preload("res://scripts/systems/power_up_shop_manager.gd")
const RewardSystem := preload("res://scripts/systems/codex_reward_system.gd")
const CodexScreenScene := preload("res://scenes/ui/codex_screen.tscn")
const CodexMilestoneNoticeScript := preload("res://scripts/ui/codex_milestone_notice.gd")
const GameScene := preload("res://scenes/main.tscn")

class FakeCodexSource extends RefCounted:
	var totals: Dictionary = {}
	var found: Dictionary = {}

	func get_total_count(category: String) -> int:
		return int(totals.get(category, 0))

	func get_discovered_count(category: String) -> int:
		return int(found.get(category, 0))

var database
var test_root := ""
var failures: Array[String] = []
var checks := 0
var save_should_fail := false
var save_calls := 0
var entry_signal_count := 0
var evidence: Dictionary = {}

func _ready() -> void:
	test_root = OS.get_environment("COMMENTDIE_CODEX_TEST_ROOT").replace("\\", "/").trim_suffix("/")
	if test_root == "":
		test_root = OS.get_user_data_dir().replace("\\", "/")
	database = Database.load_default()
	if not CodexManager.entry_discovered.is_connected(_on_entry_discovered):
		CodexManager.entry_discovered.connect(_on_entry_discovered)
	_check(database.is_valid, "production PP database is valid")
	_test_master_and_boundaries()
	_test_real_codex_counts_and_filters()
	_test_initial_character_gate_and_claim()
	_test_save_failure_retry()
	_test_history_rotation_and_reload()
	_test_v3_copy_retrospective()
	await _test_ui_contract_and_capture()
	evidence["checks"] = checks
	evidence["failures"] = failures
	var report := FileAccess.open(test_root.path_join("codex-milestone-results.json"), FileAccess.WRITE)
	if report != null:
		report.store_string(JSON.stringify(evidence, "\t"))
		report.close()
	for failure in failures:
		push_error(failure)
	print("CODEX_MILESTONE_REWARD_TESTS: %s (%d checks, %d failures)" % ["PASS" if failures.is_empty() else "FAIL", checks, failures.size()])
	get_tree().quit(0 if failures.is_empty() else 1)

func _test_master_and_boundaries() -> void:
	var system = RewardSystem.new()
	_check(system.is_valid(), "reward master validates")
	_check(system.category_ids() == ["characters", "weapons", "accessories", "enemies", "comments"], "reward master categories use Codex IDs")
	var definitions: Array[Dictionary] = system.milestone_definitions()
	_check(definitions.size() == 4, "reward master has four milestones")
	var total_pp := 0
	for definition in definitions:
		total_pp += int(definition.get("pp", 0))
	_check(total_pp == 375, "one category totals 375 PP")
	_check(total_pp * system.category_ids().size() == 1875, "all twenty milestones total 1875 PP")
	var expected_totals := {"characters": 6, "weapons": 26, "accessories": 10, "enemies": 42, "comments": 44}
	var expected_required := {
		"characters": [2, 3, 5, 6],
		"weapons": [7, 13, 20, 26],
		"accessories": [3, 5, 8, 10],
		"enemies": [11, 21, 32, 42],
		"comments": [11, 22, 33, 44]
	}
	for category in system.category_ids():
		var total := int(expected_totals[category])
		var status: Dictionary = system.category_status(category, 0, total, [], true)
		var milestones: Array = status.get("milestones", []) as Array
		for index in range(definitions.size()):
			var required := int((expected_required[category] as Array)[index])
			var definition: Dictionary = definitions[index]
			_check(int((milestones[index] as Dictionary).get("requiredCount", -1)) == required, "%s %d%% uses ceil threshold" % [category, int(definition.get("percent", 0))])
			var before: Dictionary = system.category_status(category, required - 1, total, [], true)
			var before_milestone: Dictionary = (before.get("milestones", []) as Array)[index] as Dictionary
			_check(not bool(before_milestone.get("reached", false)), "%s required-1 is not reached at %d%%" % [category, int(definition.get("percent", 0))])
			var at: Dictionary = system.category_status(category, required, total, [], true)
			var at_milestone: Dictionary = (at.get("milestones", []) as Array)[index] as Dictionary
			_check(bool(at_milestone.get("reached", false)) and String(at_milestone.get("state", "")) == "claimable", "%s required is claimable at %d%%" % [category, int(definition.get("percent", 0))])
			if required < total:
				var after: Dictionary = system.category_status(category, required + 1, total, [], true)
				var after_milestone: Dictionary = (after.get("milestones", []) as Array)[index] as Dictionary
				_check(bool(after_milestone.get("reached", false)), "%s required+1 remains reached at %d%%" % [category, int(definition.get("percent", 0))])
		var crossed: Array[Dictionary] = system.crossed_milestones(category, 0, total, total)
		_check(crossed.size() == definitions.size(), "%s crosses all four milestones at completion" % category)
	var small: Dictionary = system.category_status("characters", 1, 1, [], true)
	var small_milestones: Array = small.get("milestones", []) as Array
	_check(small_milestones.size() == definitions.size() and small_milestones.all(func(value): return int((value as Dictionary).get("requiredCount", -1)) == 1 and bool((value as Dictionary).get("reached", false))), "small total uses ceil without zero threshold")
	var zero: Dictionary = system.category_status("characters", 0, 0, [], true)
	_check(not bool(zero.get("currentComplete", false)) and not bool(zero.get("claimEnabled", false)), "zero total is never complete or claimable")
	var invalid: Dictionary = system.category_status("not_a_codex_category", 1, 2, [], true)
	_check(not bool(invalid.get("ok", true)) and String(invalid.get("blockedReason", "")) == "invalid_category", "invalid category has no reward")
	var malformed = RewardSystem.new({"version": 1, "categories": ["characters", "characters"], "milestones": [{"percent": 25, "pp": 25}]})
	_check(not malformed.is_valid() and malformed.category_status("characters", 1, 6, [], true).get("eligibleIds", []) == [], "invalid master disables payouts")
	evidence["master"] = {"categories": system.category_ids(), "milestones": definitions, "categoryTotal": total_pp, "grandTotal": total_pp * system.category_ids().size(), "required": expected_required}

func _test_real_codex_counts_and_filters() -> void:
	entry_signal_count = 0
	CodexManager.initialize_empty()
	CodexManager.load_save_data({"characters": {"ban_chan": {"new": true}}})
	CodexManager.sync_legacy_unlocked_characters(["ban_chan"])
	CodexManager.debug_unlock_all()
	_check(entry_signal_count == 0, "load, legacy sync, and debug bulk do not emit new-discovery signal")
	CodexManager.initialize_empty()
	var expected := {"characters": 6, "weapons": 26, "accessories": 10, "enemies": 42, "comments": 44}
	for category in expected.keys():
		_check(CodexManager.get_total_count(category) == int(expected[category]), "real Codex total %s is dynamic and enabled-only" % category)
	_check(CodexManager.get_discovered_count(CodexManager.CATEGORY_CHARACTER) == 3, "new Codex starts with three characters")
	_check(not CodexManager.discover_weapon("phase1_null_weapon"), "disabled weapon cannot be discovered")
	CodexManager.load_save_data({"weapons": {"phase1_null_weapon": {"new": true}, "orphan_weapon": {"new": true}}})
	_check(CodexManager.get_discovered_count(CodexManager.CATEGORY_WEAPON) == 0, "disabled and orphan entries are excluded from discovered count")
	evidence["realCounts"] = expected.duplicate(true)

func _test_initial_character_gate_and_claim() -> void:
	var seed: Dictionary = SaveStore.new().default_data(database)
	seed["unlocked"] = false
	var manager = _new_manager("initial_gate", seed)
	var source := FakeCodexSource.new()
	source.totals["characters"] = 6
	source.found["characters"] = 3
	var status: Dictionary = manager.get_codex_category_reward_status("characters", source)
	_check(status.get("eligibleIds", []).size() == 2 and int(status.get("eligiblePp", 0)) == 75, "initial three characters expose 75 PP as eligible")
	var before: Dictionary = manager.profile.duplicate(true)
	var locked: Dictionary = manager.grant_codex_milestone_rewards("characters", source)
	_check(String(locked.get("state", "")) == "shop_locked" and manager.profile == before, "initial 75 PP stays gated before shop unlock")
	manager.profile["unlocked"] = true
	var granted: Dictionary = manager.grant_codex_milestone_rewards("characters", source)
	_check(bool(granted.get("ok", false)) and int(granted.get("totalPp", 0)) == 75, "initial 75 PP becomes claimable after formal shop unlock")
	_check(manager.profile.get("claimedCodexMilestones", []).size() == 2 and manager.current_points() == 75, "initial claim stores both permanent IDs and PP")
	var duplicate: Dictionary = manager.grant_codex_milestone_rewards("characters", source)
	_check(String(duplicate.get("state", "")) == "nothing_to_claim" and manager.current_points() == 75, "initial claim cannot repeat")
	_check(not manager.profile.get("rewardedRunIds", []).has("characters:25") and not manager.profile.get("rewardedRewardKeys", []).has("characters:25"), "Codex claim does not use general reward history")
	evidence["initialGate"] = {"locked": locked, "granted": granted, "duplicate": duplicate, "profile": manager.profile.duplicate(true)}

func _test_save_failure_retry() -> void:
	var seed: Dictionary = SaveStore.new().default_data(database)
	seed["unlocked"] = true
	seed["currentPoints"] = 17
	seed["totalEarnedPoints"] = 17
	var manager = _new_manager("save_failure", seed)
	var source := FakeCodexSource.new()
	source.totals["characters"] = 6
	source.found["characters"] = 3
	var before: Dictionary = manager.profile.duplicate(true)
	var disk_before := FileAccess.get_file_as_bytes(manager.store.path)
	save_should_fail = true
	save_calls = 0
	manager.store.save_override = Callable(self, "_save_override")
	var failed: Dictionary = manager.grant_codex_milestone_rewards("characters", source)
	_check(String(failed.get("state", "")) == "save_failed" and save_calls == 1, "batch claim uses one save call and reports failure")
	_check(manager.profile == before and FileAccess.get_file_as_bytes(manager.store.path) == disk_before and not manager.busy, "batch save failure preserves full profile and disk")
	_check(manager.profile.get("claimedCodexMilestones", []).is_empty() and manager.current_points() == 17, "failed batch has no partial claimed or PP")
	save_should_fail = false
	manager.store.save_override = Callable()
	var retry: Dictionary = manager.grant_codex_milestone_rewards("characters", source)
	_check(bool(retry.get("ok", false)) and retry.get("state") == "granted" and int(retry.get("totalPp", 0)) == 75, "same batch retries successfully after save recovery")
	_check(manager.current_points() == 92 and manager.profile.get("claimedCodexMilestones", []).size() == 2, "retry adds the batch exactly once")
	var reloaded = Manager.new(database, manager.store)
	_check(reloaded.current_points() == 92 and reloaded.profile.get("claimedCodexMilestones", []).size() == 2, "claimed Codex milestones persist after reload")
	var single_source := FakeCodexSource.new()
	single_source.totals["weapons"] = 26
	single_source.found["weapons"] = 7
	var single: Dictionary = reloaded.get_codex_category_reward_status("weapons", single_source)
	_check(single.get("claimableIds", []).size() == 1 and int(single.get("claimablePp", 0)) == 25, "single milestone status is isolated by category")
	evidence["saveFailureRetry"] = {"failed": failed, "retry": retry, "saveCalls": save_calls, "reloaded": reloaded.profile.duplicate(true)}

func _test_history_rotation_and_reload() -> void:
	var seed: Dictionary = SaveStore.new().default_data(database)
	seed["unlocked"] = true
	seed["rewardedRunIds"] = []
	seed["rewardedRewardKeys"] = []
	for index in range(100):
		seed["rewardedRunIds"].append("run_%d" % index)
	for index in range(200):
		seed["rewardedRewardKeys"].append("key_%d" % index)
	var manager = _new_manager("history_rotation", seed)
	var source := FakeCodexSource.new()
	source.totals["weapons"] = 26
	source.found["weapons"] = 26
	var result: Dictionary = manager.grant_codex_milestone_rewards("weapons", source)
	_check(bool(result.get("ok", false)) and int(result.get("totalPp", 0)) == 375, "completion claims all four weapon rewards")
	_check(manager.profile.get("rewardedRunIds", []).size() == 100 and manager.profile.get("rewardedRewardKeys", []).size() == 200, "general history limits remain unchanged after Codex claim")
	_check(manager.profile.get("claimedCodexMilestones", []).size() == 4, "permanent Codex history is not rotated")
	manager.profile["currentPoints"] = 0
	manager.profile["unlocked"] = true
	var no_duplicate: Dictionary = manager.grant_codex_milestone_rewards("weapons", source)
	_check(no_duplicate.get("state") == "nothing_to_claim" and manager.current_points() == 0, "general history rotation cannot re-enable Codex reward")
	evidence["historyRotation"] = {"result": result, "runHistory": manager.profile.get("rewardedRunIds", []).size(), "rewardKeyHistory": manager.profile.get("rewardedRewardKeys", []).size(), "claimed": manager.profile.get("claimedCodexMilestones", [])}

func _test_v3_copy_retrospective() -> void:
	var store = _new_store("v3_copy")
	var v3: Dictionary = SaveStore.new().default_data(database)
	v3["schemaVersion"] = 3
	v3["unlocked"] = true
	v3.erase("claimedCodexMilestones")
	var raw_file := FileAccess.open(store.path, FileAccess.WRITE)
	if raw_file != null:
		raw_file.store_string(JSON.stringify({"powerUpShop": v3}))
		raw_file.close()
	var manager = Manager.new(database, store)
	_check(manager.profile.get("schemaVersion", 0) == 5 and manager.profile.get("claimedCodexMilestones", []) == [] and manager.current_points() == 0, "v3 copy normalizes to schema5 without automatic PP")
	var source := FakeCodexSource.new()
	source.totals["weapons"] = 26
	source.found["weapons"] = 26
	var status: Dictionary = manager.get_codex_category_reward_status("weapons", source)
	_check(status.get("claimableIds", []).size() == 4, "v3 complete Codex copy exposes all retrospective rewards")
	var claimed: Dictionary = manager.grant_codex_milestone_rewards("weapons", source)
	_check(bool(claimed.get("ok", false)) and int(claimed.get("totalPp", 0)) == 375, "v3 complete Codex copy can claim after explicit receipt")
	evidence["v3Copy"] = {"beforeClaim": status, "claim": claimed, "profile": manager.profile.duplicate(true)}

func _test_ui_contract_and_capture() -> void:
	CodexManager.initialize_empty()
	var seed: Dictionary = SaveStore.new().default_data(database)
	var manager = _new_manager("ui_contract", seed)
	var screen: Control = CodexScreenScene.instantiate() as Control
	add_child(screen)
	screen.size = Vector2(1280, 720)
	screen.call("bind_reward_manager", manager)
	screen.call("open_screen", "title", {}, {"category": "characters"})
	await get_tree().process_frame
	await get_tree().process_frame
	var reward_status := screen.find_child("CodexRewardStatus", true, false) as Label
	var reward_button := screen.find_child("CodexRewardClaimButton", true, false) as Button
	var reward_badges := screen.find_children("CodexRewardBadge", "PanelContainer", true, false)
	_check(reward_status != null and reward_status.text.contains("解禁後"), "UI shows initial reward gate before shop unlock")
	_check(reward_button != null and reward_button.disabled, "UI disables claim while shop is locked")
	_check(reward_badges.size() == 5 and (reward_badges[0] as PanelContainer).visible, "reward badge is independent from NEW on the character tab")
	manager.profile["unlocked"] = true
	screen.call("_refresh_reward_panel")
	var selected_before: Dictionary = (screen.get("_selected_ids") as Dictionary).duplicate(true)
	var focus_before := int(screen.get("_input_focus"))
	var list_scroll := screen.find_child("EntryListScroll", true, false) as ScrollContainer
	var detail_scroll := screen.find_child("DetailInfoScroll", true, false) as ScrollContainer
	var list_before := list_scroll.scroll_vertical if list_scroll != null else -1
	var detail_before := detail_scroll.scroll_vertical if detail_scroll != null else -1
	var new_snapshot_before: Dictionary = (screen.get("_new_snapshot_ids") as Dictionary).duplicate(true)
	var key_event := InputEventKey.new()
	key_event.pressed = true
	key_event.keycode = KEY_R
	_check(bool(screen.call("handle_input", key_event)), "R invokes Codex reward claim")
	await get_tree().process_frame
	var reward_feedback := screen.find_child("CodexRewardFeedback", true, false) as Label
	_check(reward_feedback != null and reward_feedback.text.contains("+75 PP") and reward_feedback.text.contains("残高 75"), "UI shows actual claimed PP and latest balance")
	_check((screen.get("_selected_ids") as Dictionary) == selected_before and int(screen.get("_input_focus")) == focus_before, "claim preserves selection and input focus")
	_check((list_scroll.scroll_vertical if list_scroll != null else -1) == list_before and (detail_scroll.scroll_vertical if detail_scroll != null else -1) == detail_before, "claim preserves both scroll positions")
	_check((screen.get("_new_snapshot_ids") as Dictionary) == new_snapshot_before, "claim does not rebuild NEW snapshot")
	_check(not (reward_badges[0] as PanelContainer).visible, "claimed reward badge disappears without changing NEW state")
	var weapon_discovered := 0
	for weapon_value in CodexManager.get_master_entries(CodexManager.CATEGORY_WEAPON):
		var weapon_id := String((weapon_value as Dictionary).get("id", ""))
		if CodexManager.discover_weapon(weapon_id):
			weapon_discovered += 1
			if weapon_discovered >= 7:
				break
	screen.call("open_screen", "title", {}, {"category": "weapons"})
	await get_tree().process_frame
	reward_button = screen.find_child("CodexRewardClaimButton", true, false) as Button
	_check(weapon_discovered == 7 and reward_button != null and not reward_button.disabled, "single reached milestone enables the shared claim button")
	screen.call("_enter_detail_focus")
	var x_focus_before := int(screen.get("_input_focus"))
	var x_event := InputEventJoypadButton.new()
	x_event.pressed = true
	x_event.button_index = JOY_BUTTON_X
	_check(bool(screen.call("handle_input", x_event)), "gamepad X invokes the same Codex reward claim")
	await get_tree().process_frame
	_check(manager.current_points() == 100 and int(screen.get("_input_focus")) == x_focus_before, "X claim preserves detail focus and adds only the current milestone")
	var accessory_discovered := 0
	for accessory_value in CodexManager.get_master_entries(CodexManager.CATEGORY_ACCESSORY):
		var accessory_id := String((accessory_value as Dictionary).get("id", ""))
		if CodexManager.discover_accessory(accessory_id):
			accessory_discovered += 1
			if accessory_discovered >= 3:
				break
	screen.call("open_screen", "title", {}, {"category": "accessories"})
	await get_tree().process_frame
	reward_button = screen.find_child("CodexRewardClaimButton", true, false) as Button
	_check(accessory_discovered == 3 and reward_button != null and not reward_button.disabled, "mouse claim button is enabled for an accessory milestone")
	reward_button.emit_signal("pressed")
	await get_tree().process_frame
	_check(manager.current_points() == 125, "mouse claim button uses the same persisted reward path")
	var screen_source := FileAccess.get_file_as_string("res://scripts/ui/codex_screen.gd")
	_check(screen_source.contains("KEY_R") and screen_source.contains("JOY_BUTTON_X") and screen_source.contains("_claim_current_category_rewards"), "Codex reward input keeps R/X path explicit")
	screen.queue_free()
	await get_tree().process_frame
	var capture_dir := OS.get_environment("COMMENTDIE_CODEX_CAPTURE_DIR").replace("\\", "/").trim_suffix("/")
	if capture_dir == "":
		evidence["screenshots"] = "not requested"
		return
	DirAccess.make_dir_recursive_absolute(capture_dir)
	var capture_manager = Manager.new(database, SaveStore.new())
	capture_manager.profile = SaveStore.new().default_data(database)
	capture_manager.profile["unlocked"] = true
	CodexManager.initialize_empty()
	await _capture_codex_state(capture_dir, capture_manager, "codex-1600x900-characters-claimable.png", {"category": "characters"}, Vector2i(1600, 900), false)
	await _capture_codex_state(capture_dir, capture_manager, "codex-1280x720-weapons-next.png", {"category": "weapons"}, Vector2i(1280, 720), false)
	CodexManager.initialize_empty()
	for character_value in CodexManager.get_master_entries(CodexManager.CATEGORY_CHARACTER):
		CodexManager.discover_character(String((character_value as Dictionary).get("id", "")))
	capture_manager.profile["claimedCodexMilestones"] = ["characters:25", "characters:50", "characters:75", "characters:100"]
	await _capture_codex_state(capture_dir, capture_manager, "codex-1600x900-characters-complete.png", {"category": "characters"}, Vector2i(1600, 900), false)
	CodexManager.initialize_empty()
	await _capture_inplay_notice(capture_dir)
	evidence["screenshots"] = [
		capture_dir.path_join("codex-1600x900-characters-claimable.png"),
		capture_dir.path_join("codex-1280x720-weapons-next.png"),
		capture_dir.path_join("codex-1600x900-characters-complete.png"),
		capture_dir.path_join("codex-1600x900-inplay-achievement-notice.png")
	]

func _on_entry_discovered(_category: String, _id: String, _previous_found: int, _current_found: int, _total: int) -> void:
	entry_signal_count += 1

func _capture_inplay_notice(capture_dir: String) -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1600, 900)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	var game := GameScene.instantiate()
	viewport.add_child(game)
	await get_tree().process_frame
	await get_tree().process_frame
	var notice = game.get("codex_milestone_notice")
	_check(notice != null, "normal-play Game wires Codex milestone notice")
	game.set("state", "playing")
	game.set("previous_state", "playing")
	game.call("_update_ui")
	var discovered := 0
	for weapon_value in CodexManager.get_master_entries(CodexManager.CATEGORY_WEAPON):
		var weapon_id := String((weapon_value as Dictionary).get("id", ""))
		if CodexManager.discover_weapon(weapon_id):
			discovered += 1
			if discovered >= 7:
				break
	await get_tree().process_frame
	await get_tree().process_frame
	_check(discovered == 7, "normal-play discovery crosses weapon 25% threshold")
	_check(not bool(game.get("codex_screen").visible), "milestone notice is raised while Codex is closed")
	_check(notice != null and bool(notice.visible), "normal-play milestone notice becomes visible")
	if notice != null:
		var body = notice.get("_body_label")
		_check(body != null and String(body.text).contains("25%") and String(body.text).contains("25 PP"), "milestone notice names the crossed threshold and PP")
	var texture := viewport.get_texture()
	if texture == null:
		_check(false, "renderer exposes SubViewport texture for in-play notice")
	else:
		var image := texture.get_image()
		var path := capture_dir.path_join("codex-1600x900-inplay-achievement-notice.png")
		_check(image.save_png(path) == OK, "saved screenshot codex-1600x900-inplay-achievement-notice.png")
	game.queue_free()
	viewport.queue_free()
	await get_tree().process_frame

func _capture_codex_state(capture_dir: String, manager, file_name: String, options: Dictionary, target_size: Vector2i, include_notice: bool) -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1600, 900)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	var canvas := Control.new()
	canvas.size = Vector2(1600, 900)
	viewport.add_child(canvas)
	var screen: Control = CodexScreenScene.instantiate() as Control
	canvas.add_child(screen)
	screen.size = Vector2(1600, 900)
	var screen_manager = manager
	screen.call("bind_reward_manager", screen_manager)
	screen.call("open_screen", "title", {}, options)
	var notice = null
	if include_notice:
		notice = CodexMilestoneNoticeScript.new()
		canvas.add_child(notice)
		notice.show_milestones("武器図鑑", [{"percent": 75, "pp": 100}], true)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	var texture := viewport.get_texture()
	if texture == null:
		_check(false, "renderer exposes SubViewport texture for %s" % file_name)
		screen.queue_free()
		viewport.queue_free()
		await get_tree().process_frame
		return
	var image := texture.get_image()
	if image.get_size() != target_size:
		image.resize(target_size.x, target_size.y, Image.INTERPOLATE_LANCZOS)
	var path := capture_dir.path_join(file_name)
	var error := image.save_png(path)
	_check(error == OK, "saved screenshot %s" % file_name)
	screen.queue_free()
	viewport.queue_free()
	await get_tree().process_frame

func _new_store(id: String):
	var directory := test_root.path_join("saves")
	DirAccess.make_dir_recursive_absolute(directory)
	var store = SaveStore.new()
	store.path = directory.path_join(id + ".json")
	store.backup_path = store.path + ".bak"
	store.temp_path = store.path + ".tmp"
	return store

func _new_manager(id: String, seed: Dictionary):
	var store = _new_store(id)
	_check(store.save_data(seed, database), id + " seed save")
	return Manager.new(database, store)

func _save_override(_candidate: Dictionary) -> bool:
	save_calls += 1
	return not save_should_fail

func _check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures.append(label)
