extends Node

const GameScript := preload("res://scripts/game.gd")
const CodexScreenScene := preload("res://scenes/ui/codex_screen.tscn")

var failures: Array[String] = []
var closed_origin := ""

func _ready() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	_test_aggregate_getters()
	_test_result_layout_and_summary()
	_test_screen_modes_and_input()
	_test_audit_and_dynamic_totals()
	if failures.is_empty():
		print("CODEX_V07_FINAL_TESTS: PASS")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("CODEX_V07_FINAL_TESTS: FAIL (%d)" % failures.size())
	get_tree().quit(1)

func _test_aggregate_getters() -> void:
	CodexManager.initialize_empty()
	_check(CodexManager.get_total_new_count() == 0, "empty codex has no NEW entries")
	var empty_summary := CodexManager.get_new_summary()
	_check(int(empty_summary.get("total", -1)) == 0, "empty NEW summary total is zero")

	CodexManager.discover_weapon("ban_hammer")
	CodexManager.discover_comment("short_range")
	var summary := CodexManager.get_new_summary()
	_check(CodexManager.get_total_new_count() == 2 and int(summary.get("total", 0)) == 2, "aggregate NEW count spans categories")
	var category_summary: Dictionary = summary.get("categories", {}) as Dictionary
	_check(int((category_summary.get("weapons", {}) as Dictionary).get("count", 0)) == 1, "weapon NEW subtotal is one")
	_check(int((category_summary.get("comments", {}) as Dictionary).get("count", 0)) == 1, "comment NEW subtotal is one")
	var copied_ids: Array = ((category_summary.get("weapons", {}) as Dictionary).get("ids", []) as Array)
	copied_ids.clear()
	_check(CodexManager.get_total_new_count() == 2, "NEW aggregate getter is non-destructive")

	var session := {
		"characters": ["ban_chan", "ban_chan"],
		"weapons": ["ban_hammer"],
		"comments": ["short_range", "short_range"]
	}
	var session_summary := CodexManager.summarize_session_discoveries(session)
	_check(int(session_summary.get("total", 0)) == 3, "session summary de-duplicates IDs")
	var session_groups: Dictionary = session_summary.get("categories", {}) as Dictionary
	_check(int((session_groups.get("characters", {}) as Dictionary).get("count", 0)) == 1 and int((session_groups.get("comments", {}) as Dictionary).get("count", 0)) == 1, "session summary preserves category counts")
	var session_copy: Dictionary = CodexManager.summarize_session_discoveries(session)
	((session_copy.get("categories", {}) as Dictionary).get("weapons", {}) as Dictionary)["names"] = []
	_check(int(CodexManager.summarize_session_discoveries(session).get("total", 0)) == 3, "session summary is a fresh copy")

func _test_result_layout_and_summary() -> void:
	CodexManager.initialize_empty()
	var game := GameScript.new()
	game.last_result_data = {
		"endType": "completed",
		"sessionDiscoveries": {"weapons": ["ban_hammer"]}
	}
	_check(game._has_result_codex_updates(), "result detects a non-empty session snapshot")
	var ids := game._result_button_ids()
	_check(ids.size() == 5 and ids.has("codex"), "result adds the codex button dynamically")
	var layout := game._result_layout()
	_check(layout.has("codexButton"), "result layout contains codex button rect")
	_check(game._result_button_at((layout["codexButton"] as Rect2).get_center()) == "codex", "result codex hit target follows dynamic ID")
	var button_rects: Array[Rect2] = []
	for button_id in ids:
		var rect: Rect2 = layout[game._result_button_rect_key(button_id)] as Rect2
		for previous in button_rects:
			_check(not rect.intersects(previous), "result buttons do not overlap: %s" % button_id)
		button_rects.append(rect)
	var snapshot_before := game.last_result_data.duplicate(true)
	CodexManager.get_new_summary()
	_check(game.last_result_data == snapshot_before, "result summary read does not mutate result data")

	game.last_result_data = {"endType": "completed", "sessionDiscoveries": {}}
	_check(game._result_button_ids().size() == 4 and not game._result_layout().has("codexButton"), "empty result keeps the four legacy buttons")

func _test_screen_modes_and_input() -> void:
	# A formal list selection confirms a discovered NEW item while the right
	# panel remains the single complete detail view.
	CodexManager.initialize_empty()
	var formal_cases := [
		[CodexManager.CATEGORY_CHARACTER, "aosumi_kyasumi"],
		[CodexManager.CATEGORY_WEAPON, "ban_hammer"],
		[CodexManager.CATEGORY_ACCESSORY, "mini_humidifier"],
		[CodexManager.CATEGORY_ENEMY, "enemy_bullet_drone"],
		[CodexManager.CATEGORY_COMMENT, "short_range"]
	]
	var screen = CodexScreenScene.instantiate()
	add_child(screen)
	screen.set_anchors_preset(Control.PRESET_TOP_LEFT)
	screen.size = Vector2(1280, 720)
	screen.closed.connect(func(origin: String) -> void: closed_origin = origin)
	for case_value in formal_cases:
		var case_data: Array = case_value as Array
		var case_category := String(case_data[0])
		var case_id := String(case_data[1])
		CodexManager.initialize_empty()
		_check(CodexManager.discover(case_category, case_id), "formal selection fixture discovers %s" % case_id)
		screen.open_screen("title", {}, {"category": case_category})
		screen._select_entry_by_id(case_id)
		_check(not CodexManager.is_new(case_category, case_id), "formal selection clears NEW without requiring detail: %s" % case_category)
		_check(not String(screen._detail_body.text).contains("決定で詳細") and not String(screen._detail_body.text).contains("選択でNEW確認済み"), "formal selection shows the complete detail model: %s" % case_category)
		if case_category == CodexManager.CATEGORY_CHARACTER:
			_check(screen._character_profile_content.visible, "character selection shows the structured profile immediately")

	# The right panel is always the complete detail.  Enter only changes the
	# input destination when the detail has a scroll range.
	CodexManager.initialize_empty()
	CodexManager.discover_weapon("ban_hammer")
	screen.open_screen("title", {}, {"category": "weapons"})
	screen._select_entry_by_id("ban_hammer")
	_check(String(screen._detail_body.text).contains("標準性能"), "right panel renders the complete discovered detail from the initial selection")
	_check(int(screen._input_focus) == 0, "opening a complete detail starts in LIST focus")
	var detail_scrollable := screen._detail_is_scrollable()
	_check(bool(screen.handle_input(_key_event(KEY_ENTER))), "list Enter is consumed")
	if detail_scrollable:
		_check(int(screen._input_focus) == 1, "scrollable detail enters DETAIL focus")
		_check(screen._detail_focus_ring.visible and screen._detail_back_button.text == "一覧へ戻る", "DETAIL focus updates its outline and back action")
		var detail_scroll_before := screen._detail_scroll.scroll_vertical
		screen.handle_input(_key_event(KEY_PAGEDOWN))
		_check(screen._detail_scroll.scroll_vertical >= detail_scroll_before, "DETAIL PageDown routes to the right detail scroll")
		var detail_scroll_after_page := screen._detail_scroll.scroll_vertical
		var horizontal_before := String(screen._selected_ids.get(CodexManager.CATEGORY_WEAPON, ""))
		var horizontal_event := InputEventKey.new()
		horizontal_event.pressed = true
		horizontal_event.keycode = KEY_RIGHT
		_check(bool(screen.handle_input(horizontal_event)), "DETAIL horizontal input is consumed")
		_check(int(screen._input_focus) == 1 and String(screen._selected_ids.get(CodexManager.CATEGORY_WEAPON, "")) == horizontal_before and screen._detail_scroll.scroll_vertical == detail_scroll_after_page, "DETAIL horizontal input is reserved and does not move or scroll")
		screen.handle_input(_key_event(KEY_ESCAPE))
		_check(int(screen._input_focus) == 0 and screen._detail_focus_ring.visible == false, "DETAIL Escape returns to LIST")
	else:
		_check(int(screen._input_focus) == 0, "short detail keeps LIST focus")
	screen._select_entry_by_id("ban_hammer")
	_check(not CodexManager.is_new(CodexManager.CATEGORY_WEAPON, "ban_hammer"), "formal click clears the selected NEW item")

	# Directional selection clears only the item reached, in order.
	CodexManager.initialize_empty()
	screen.open_screen("title", {}, {"category": "weapons"})
	for weapon_id in ["ban_hammer", "superchat_shot", "comment_boomerang"]:
		CodexManager.discover_weapon(weapon_id)
	var ordered_entries: Array = screen._visible_entries()
	var ordered_ids := _entry_ids(ordered_entries)
	screen._toggle_new_filter()
	var snapshot_ids: Array = _entry_ids(screen._visible_entries())
	_check(screen._new_only and snapshot_ids == ["ban_hammer", "superchat_shot", "comment_boomerang"], "NEW filter captures a stable ID snapshot")
	var scroll_before: int = screen._list_scroll.scroll_vertical
	screen._move_selection(1)
	_check(not CodexManager.is_new(CodexManager.CATEGORY_WEAPON, "ban_hammer") and not CodexManager.is_new(CodexManager.CATEGORY_WEAPON, "superchat_shot"), "directional selection reads only the reached NEW item")
	_check(_entry_ids(screen._visible_entries()) == snapshot_ids and String(screen._selected_ids.get(CodexManager.CATEGORY_WEAPON, "")) == "superchat_shot", "read NEW row remains in snapshot with selection intact")
	_check(screen._list_scroll.scroll_vertical == scroll_before, "mark_read does not move list scroll")
	screen._move_selection(1)
	_check(not CodexManager.is_new(CodexManager.CATEGORY_WEAPON, "comment_boomerang") and screen._new_only and screen._visible_entries().size() == 3, "last NEW stays in the active snapshot")
	_check(not screen._new_filter_button.disabled, "active empty NEW filter remains switchable to ALL")
	screen._toggle_new_filter()
	_check(not screen._new_only and screen._visible_entries().size() >= ordered_ids.size(), "NEW filter can be turned off after the last item is read")

	# Reapplying NEW builds only the current live NEW IDs.
	CodexManager.initialize_empty()
	screen.open_screen("title", {}, {"category": "weapons"})
	CodexManager.discover_weapon("ban_hammer")
	CodexManager.discover_weapon("superchat_shot")
	screen._toggle_new_filter()
	screen._toggle_new_filter()
	screen._toggle_new_filter()
	_check(screen._new_only and _entry_ids(screen._visible_entries()) == ["superchat_shot"], "NEW reapply excludes the previously read ID")

	# Hover and refresh do not read; an explicit entry selection does.
	CodexManager.initialize_empty()
	screen.open_screen("title", {}, {"category": "weapons"})
	CodexManager.discover_weapon("ban_hammer")
	var hover_motion := InputEventMouseMotion.new()
	hover_motion.position = Vector2(50, 50)
	screen.handle_input(hover_motion)
	_check(CodexManager.is_new(CodexManager.CATEGORY_WEAPON, "ban_hammer"), "mouse hover does not clear NEW")
	screen._refresh()
	_check(CodexManager.is_new(CodexManager.CATEGORY_WEAPON, "ban_hammer"), "plain refresh does not clear NEW")

	# Unknown/undiscovered rows remain untouched.
	CodexManager.initialize_empty()
	screen.open_screen("title", {}, {"category": "enemies"})
	var hidden_before := CodexManager.get_save_data()
	screen._select_entry_by_id("troll")
	_check(not CodexManager.is_discovered(CodexManager.CATEGORY_ENEMY, "troll"), "undiscovered selection remains undiscovered")
	_check(CodexManager.get_save_data() == hidden_before, "undiscovered selection does not mutate save data")

	var result_game := GameScript.new()
	result_game.state = "result"
	result_game.last_result_data = {"endType": "completed", "sessionDiscoveries": {"weapons": ["ban_hammer"]}}
	result_game.codex_screen = screen
	result_game.choice_box = HBoxContainer.new()
	result_game.result_panel = PanelContainer.new()
	result_game.result_label = Label.new()
	result_game.title_label = Label.new()
	result_game.chat_title_label = Label.new()
	result_game.chat_box = VBoxContainer.new()
	result_game.status_label = Label.new()
	result_game.banner_label = Label.new()
	result_game.player_weapons = []
	result_game.player_accessories = []
	result_game.weapons = []
	result_game.gifts = []
	result_game.current_character = {}
	result_game.current_stream_frame = {}
	result_game.current_weapon = {}
	result_game.codex_screen.closed.connect(result_game._on_codex_closed)
	var result_snapshot := result_game.last_result_data.duplicate(true)
	result_game._open_codex_from_result()
	_check(result_game.state == "codex" and bool(screen.visible) and screen._origin == "result", "result opens codex with result origin")
	screen.close_screen()
	_check(result_game.state == "result" and result_game.last_result_data == result_snapshot, "closing result codex restores result without mutation")

	CodexManager.initialize_empty()
	CodexManager.discover_weapon("ban_hammer")
	screen.open_screen("result", {}, {"category": "weapons", "newOnly": true})
	_check(screen._new_only, "result codex can open in NEW-only mode")
	_check(not CodexManager.is_new(CodexManager.CATEGORY_WEAPON, "ban_hammer"), "result codex reads only when it opens the formal initial selection")
	screen._select_entry_by_id("ban_hammer")
	_check(screen._new_only, "reading the final NEW keeps the snapshot in NEW mode")
	var escape := InputEventKey.new()
	escape.pressed = true
	escape.keycode = KEY_ESCAPE
	_check(bool(screen.handle_input(escape)) and not bool(screen.visible) and closed_origin == "result", "Escape closes directly and preserves origin")

	screen.open_screen("title", {}, {"category": "characters"})
	var before_category: int = screen._category_index
	var motion := InputEventJoypadMotion.new()
	motion.axis = JOY_AXIS_LEFT_X
	motion.axis_value = 0.8
	screen.handle_input(motion)
	var after_first_motion: int = screen._category_index
	screen.handle_input(motion)
	_check(after_first_motion != before_category and screen._category_index == after_first_motion, "analog stick latch prevents repeat movement")
	motion.axis_value = 0.0
	screen.handle_input(motion)
	screen.close_screen()
	screen.queue_free()
	result_game.free()

func _test_audit_and_dynamic_totals() -> void:
	CodexManager.initialize_empty()
	var summary := CodexManager.get_collection_summary()
	_check(int(summary.get("total", 0)) == CodexManager.get_total_count(CodexManager.CATEGORY_CHARACTER) + CodexManager.get_total_count(CodexManager.CATEGORY_WEAPON) + CodexManager.get_total_count(CodexManager.CATEGORY_ACCESSORY) + CodexManager.get_total_count(CodexManager.CATEGORY_ENEMY), "collection total is derived from four enabled categories")
	_check(int((summary.get("commentLog", {}) as Dictionary).get("total", 0)) == CodexManager.get_total_count(CodexManager.CATEGORY_COMMENT), "comment log remains separate from collection")
	var report := CodexManager.validate_masters()
	var counts: Dictionary = report.get("counts", {}) as Dictionary
	var enemies: Dictionary = counts.get("enemies", {}) as Dictionary
	_check(int(enemies.get("raw", 0)) == 44 and int(enemies.get("enabled", 0)) == 42, "v0.7 audit keeps enemy raw/effective counts")
	_check(int(enemies.get("bossRaw", 0)) == 7 and int(enemies.get("bossEnabled", 0)) == 6, "v0.7 audit keeps boss raw/effective counts")
	var comment_counts: Dictionary = counts.get("comments", {}) as Dictionary
	_check(int(comment_counts.get("enabled", 0)) == 44, "v0.7 audit checks all standard comments")
	_check(int(comment_counts.get("reachable", 0)) == 44, "all standard comments have a normal/hard frame path")
	var comment_boundary: Dictionary = report.get("commentBoundary", {}) as Dictionary
	_check(String(comment_boundary.get("mechanic", "")) == "relay_boss_private_choice" and int(comment_boundary.get("standardCommentCount", 0)) == 44 and int(comment_boundary.get("relayPrivateCount", 0)) > 0, "relay boss private choices stay outside standard comment count")
	_check(int(report.get("collectionTotal", 0)) == 84, "current collection total remains 84")
	_check(bool(report.get("valid", false)), "current master audit remains valid")

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _key_event(keycode: Key) -> InputEventKey:
	var event := InputEventKey.new()
	event.pressed = true
	event.keycode = keycode
	return event

func _entry_ids(entries: Array) -> Array:
	var ids: Array = []
	for item in entries:
		if item is Dictionary:
			ids.append(String((item as Dictionary).get("id", "")))
	return ids
