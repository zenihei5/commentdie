extends Node

const CodexScreenScene := preload("res://scenes/ui/codex_screen.tscn")
const GameScene := preload("res://scenes/main.tscn")
const CommentSystemScript := preload("res://scripts/systems/comment_system.gd")

var failures: Array[String] = []
var closed_seen := false
var confirm_events := 0
var cancel_events := 0
var focus_cursor_events := 0
var focus_confirm_events := 0
var focus_cancel_events := 0
var focus_closed_events := 0

func _ready() -> void:
	CodexManager.initialize_empty()
	CodexManager.discover_enemy("enemy_bullet_drone")
	var screen = CodexScreenScene.instantiate()
	add_child(screen)
	screen.size = Vector2(1280, 720)
	screen.closed.connect(func(_origin: String) -> void: closed_seen = true)
	var cursor_move_events: Array[bool] = []
	screen.cursor_moved.connect(func() -> void: cursor_move_events.append(true))
	screen.open_screen("title")
	_check(bool(screen.visible), "codex screen opens")
	_check(screen.get_child_count() >= 2, "codex screen builds overlay controls")
	_check(String(screen._collection_label.text).contains("COLLECTION"), "codex screen shows collection summary")
	_check(String(screen._comment_log_label.text).contains("COMMENT LOG"), "codex screen shows separate comment log")
	_check(screen._collection_bar != null, "codex screen builds collection progress bar")
	_check(screen._debug_row != null and screen._debug_row.get_child_count() >= 4, "debug codex controls are visible in debug build")
	_check(_codex_buttons_are_manual_focus_only(screen), "codex buttons do not steal arrow/D-pad input from logical focus")
	var game_source := FileAccess.get_file_as_string("res://scripts/game.gd")
	_check(game_source.contains("codex_screen.confirm_requested.connect(_on_codex_confirm_requested)"), "game connects codex confirm signal")
	_check(game_source.contains("codex_screen.cancel_requested.connect(_on_codex_cancel_requested)"), "game connects codex cancel signal")
	_check(game_source.contains("func _on_codex_confirm_requested()") and game_source.contains("func _on_codex_cancel_requested()"), "game exposes codex SE handlers")
	_test_focus_and_signal_contract()
	await _test_game_cursor_se_connection()
	var cursor_before_category := cursor_move_events.size()
	screen._select_category(1)
	_check(cursor_move_events.size() == cursor_before_category + 1, "codex emits cursor movement for category navigation")
	CodexManager.discover_weapon("ban_hammer")
	screen._select_category(1)
	screen._select_entry_by_id("ban_hammer")
	_check(String(screen._detail_body.text).contains("LEVEL"), "normal weapon detail shows level section")
	_check(String(screen._detail_body.text).contains("標準性能"), "weapon detail labels standard performance")
	CodexManager.discover_weapon("ban_judgement")
	screen._select_entry_by_id("ban_judgement")
	_check(not String(screen._detail_body.text).contains("LEVEL"), "evolved weapon detail hides level section")
	CodexManager.discover_accessory("mini_humidifier")
	screen._select_category(2)
	screen._select_entry_by_id("mini_humidifier")
	_check(String(screen._detail_body.text).contains("Lv3"), "accessory detail shows its real max level")
	CodexManager.discover_comment("short_range")
	screen._select_category(4)
	screen._select_entry_by_id("short_range")
	_check(String(screen._detail_body.text).contains("通常効果") and String(screen._detail_body.text).contains("♡効果"), "comment detail shows normal and heart effects")
	_check(screen._detail_image_holder.get_child_count() > 0 and screen._detail_image_holder.get_child(0) is TextureRect, "comment detail uses the choice-screen instruction icon")
	for comment_value in CodexManager.get_master_entries(CodexManager.CATEGORY_COMMENT):
		var comment_id := String((comment_value as Dictionary).get("id", ""))
		if comment_id == "do_everything":
			_check(CommentSystemScript.instruction_comment_icon_path(comment_id) == "", "special all-effects card keeps its image-free choice layout")
			continue
		var icon_path := CommentSystemScript.instruction_comment_icon_path(comment_id)
		_check(icon_path != "" and ResourceLoader.exists(icon_path), "choice icon exists for comment %s" % comment_id)
	screen._select_category(0)
	var down := InputEventKey.new()
	down.pressed = true
	down.keycode = KEY_DOWN
	_check(bool(screen.handle_input(down)), "codex screen handles list navigation")
	var enter := InputEventKey.new()
	enter.pressed = true
	enter.keycode = KEY_ENTER
	_check(bool(screen.handle_input(enter)), "codex screen handles explicit detail selection")
	screen._select_category(3)
	_check(screen._enemy_filter_buttons.size() == 7, "codex screen builds seven enemy filters")
	screen._toggle_new_filter()
	_check(screen._new_only and _contains_id(screen._visible_entries(), "enemy_bullet_drone"), "NEW filter keeps undiscovered-filter matches")
	screen._set_enemy_filter("gameplay")
	_check(not CodexManager.is_new(CodexManager.CATEGORY_ENEMY, "enemy_bullet_drone"), "formal filter selection clears the reached NEW item")
	screen._select_entry_by_id("enemy_bullet_drone")
	_check(not CodexManager.is_new(CodexManager.CATEGORY_ENEMY, "enemy_bullet_drone"), "explicit enemy detail selection preserves the read state")
	CodexManager.discover_enemy("last_offline")
	screen._set_enemy_filter("ALL")
	screen._select_entry_by_id("last_offline")
	_check(String(screen._detail_body.text).contains("SPECIAL BOSS"), "special boss detail has distinct title tag")
	_check(String(screen._detail_body.text).contains("特徴："), "enemy feature section uses codex model")
	_check(String(screen._detail_body.text).contains("基本特性") and String(screen._detail_body.text).contains("攻撃タイプ："), "enemy detail shows runtime profile labels")
	_check(not String(screen._detail_body.text).contains("攻略メモ："), "empty enemy strategy section is hidden")
	screen._set_enemy_filter("singing")
	_check(CodexManager.get_total_count(CodexManager.CATEGORY_ENEMY) == 42, "filter progress keeps full category total")
	screen._set_enemy_filter("gameplay")
	CodexManager.initialize_empty()
	screen.open_screen("title")
	for comment_value in CodexManager.get_master_entries(CodexManager.CATEGORY_COMMENT):
		CodexManager.discover_comment(String((comment_value as Dictionary).get("id", "")))
	_check(screen._completion_banner.visible, "completion banner is shown after live discovery")
	screen.close_screen()
	_check(not bool(screen.visible) and closed_seen, "codex screen closes and emits origin")
	if failures.is_empty():
		print("CODEX_SCREEN_TESTS: PASS")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("CODEX_SCREEN_TESTS: FAIL (%d)" % failures.size())
	get_tree().quit(1)

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _test_focus_and_signal_contract() -> void:
	var focus_screen = CodexScreenScene.instantiate()
	add_child(focus_screen)
	focus_screen.size = Vector2(1280, 720)
	focus_cursor_events = 0
	focus_confirm_events = 0
	focus_cancel_events = 0
	focus_closed_events = 0
	focus_screen.cursor_moved.connect(func() -> void: focus_cursor_events += 1)
	focus_screen.confirm_requested.connect(func() -> void: focus_confirm_events += 1)
	focus_screen.cancel_requested.connect(func() -> void: focus_cancel_events += 1)
	focus_screen.closed.connect(func(_origin: String) -> void: focus_closed_events += 1)

	CodexManager.initialize_empty()
	focus_screen.open_screen("title", {}, {"category": "characters"})
	var character_category := CodexManager.CATEGORY_CHARACTER
	var first_id := String((focus_screen._visible_entries()[0] as Dictionary).get("id", ""))
	var cursor_before := focus_cursor_events
	_check(bool(focus_screen.handle_input(_key_event(KEY_UP))), "first item accepts Up input")
	_check(int(focus_screen._focus_area) == 1 and String(focus_screen._selected_ids.get(character_category, "")) == first_id, "first item Up moves logical focus to BACK")
	_check(not _list_has_cursor(focus_screen) and _list_rows_are_normal(focus_screen), "BACK focus hides the list cursor and selected row style")
	_check(focus_cursor_events == cursor_before + 1, "entering BACK emits one cursor movement")
	cursor_before = focus_cursor_events
	_check(bool(focus_screen.handle_input(_key_event(KEY_DOWN))), "BACK accepts Down input")
	_check(int(focus_screen._focus_area) == 0 and String(focus_screen._selected_ids.get(character_category, "")) == first_id, "BACK Down returns to first list item")
	_check(_list_has_cursor(focus_screen) and not _list_rows_are_normal(focus_screen), "returning from BACK restores the list cursor")
	_check(focus_cursor_events == cursor_before + 1, "leaving BACK emits one cursor movement")
	focus_screen._selected_ids[character_category] = "shizuki_miimu"
	focus_screen._refresh_list_and_detail()
	cursor_before = focus_cursor_events
	_check(bool(focus_screen.handle_input(_key_event(KEY_DOWN))), "last item accepts Down input")
	_check(int(focus_screen._focus_area) == 1 and String(focus_screen._selected_ids.get(character_category, "")) == "shizuki_miimu", "last item Down moves logical focus to BACK")
	_check(not _list_has_cursor(focus_screen) and _list_rows_are_normal(focus_screen), "last-item BACK focus hides the list cursor")
	_check(focus_cursor_events == cursor_before + 1, "last item enters BACK once")
	cursor_before = focus_cursor_events
	_check(bool(focus_screen.handle_input(_key_event(KEY_UP))), "BACK accepts Up input")
	_check(int(focus_screen._focus_area) == 0 and String(focus_screen._selected_ids.get(character_category, "")) == "shizuki_miimu", "BACK Up returns to last list item")
	_check(_list_has_cursor(focus_screen), "BACK Up restores the last row cursor")
	_check(focus_cursor_events == cursor_before + 1, "BACK Up emits one cursor movement")
	var category_before: int = focus_screen._category_index
	cursor_before = focus_cursor_events
	focus_screen._move_selection(1)
	_check(int(focus_screen._focus_area) == 1, "last item can re-enter BACK")
	focus_screen.handle_input(_key_event(KEY_LEFT))
	_check(focus_screen._category_index == category_before and focus_cursor_events == cursor_before + 1, "BACK Left does not change category or emit extra movement")
	_check(bool(focus_screen.handle_input(_key_event(KEY_ENTER))), "BACK accepts Enter")
	_check(focus_closed_events == 1 and focus_cancel_events == 1, "BACK Enter closes once with one cancel signal")

	CodexManager.initialize_empty()
	focus_screen._selected_ids[CodexManager.CATEGORY_WEAPON] = "ban_hammer"
	focus_screen.open_screen("title", {}, {"category": "weapons"})
	var confirm_before := focus_confirm_events
	_check(bool(focus_screen.handle_input(_key_event(KEY_ENTER))), "list Enter opens detail")
	_check(focus_screen._detail_mode and focus_screen._detail_focus_ring.visible, "detail mode shows full panel focus ring")
	_check(not _list_has_cursor(focus_screen) and _list_rows_are_normal(focus_screen), "detail focus hides the list cursor and selected row style")
	_check(focus_confirm_events == confirm_before + 1, "opening detail emits one confirm signal")
	focus_screen.handle_input(_key_event(KEY_ENTER))
	_check(focus_confirm_events == confirm_before + 1, "detail Enter does not replay confirm signal")
	focus_screen._move_detail(1)
	_check(focus_confirm_events == confirm_before + 1, "detail next does not emit confirm signal")
	var cancel_before := focus_cancel_events
	focus_screen.handle_input(_key_event(KEY_ESCAPE))
	_check(not focus_screen._detail_mode and not focus_screen._detail_focus_ring.visible and focus_cancel_events == cancel_before + 1, "detail Escape exits with one cancel signal")
	_check(_list_has_cursor(focus_screen), "exiting detail restores the list cursor")
	confirm_before = focus_confirm_events
	focus_screen._select_entry_by_id("ban_hammer")
	_check(focus_screen._detail_mode and focus_confirm_events == confirm_before + 1, "mouse-style entry selection opens detail once")
	cancel_before = focus_cancel_events
	focus_screen._handle_back_button()
	_check(not focus_screen._detail_mode and focus_cancel_events == cancel_before + 1, "detail back button emits one cancel signal")
	cancel_before = focus_cancel_events
	focus_screen._handle_back_button()
	_check(not focus_screen.visible and focus_cancel_events == cancel_before + 1, "list back button emits one cancel signal")

	CodexManager.initialize_empty()
	focus_screen.open_screen("title", {}, {"category": "characters"})
	focus_screen._selected_ids[CodexManager.CATEGORY_CHARACTER] = "ban_chan"
	focus_screen._refresh_list_and_detail()
	_check(bool(focus_screen.handle_input(_pad_event(JOY_BUTTON_DPAD_UP))) and int(focus_screen._focus_area) == 1, "D-pad Up uses the BACK boundary")
	_check(bool(focus_screen.handle_input(_pad_event(JOY_BUTTON_DPAD_DOWN))) and int(focus_screen._focus_area) == 0, "D-pad Down returns to the first item")
	var analog_up := _motion_event(JOY_AXIS_LEFT_Y, -0.8)
	var analog_cursor_before := focus_cursor_events
	_check(bool(focus_screen.handle_input(analog_up)) and int(focus_screen._focus_area) == 1, "analog Up uses the BACK boundary")
	focus_screen.handle_input(analog_up)
	_check(focus_cursor_events == analog_cursor_before + 1, "analog latch prevents repeated boundary movement")
	focus_screen.handle_input(_motion_event(JOY_AXIS_LEFT_Y, 0.0))
	_check(bool(focus_screen.handle_input(_motion_event(JOY_AXIS_LEFT_Y, 0.8))) and int(focus_screen._focus_area) == 0, "analog Down returns to the first item")
	focus_screen.close_screen()

	CodexManager.initialize_empty()
	focus_screen.open_screen("title", {}, {"category": "weapons"})
	CodexManager.discover_weapon("ban_hammer")
	focus_screen._toggle_new_filter()
	_check(focus_screen._new_only and focus_screen._visible_entries().size() == 1, "single-item NEW snapshot is available for boundary focus")
	_check(bool(focus_screen.handle_input(_key_event(KEY_UP))) and int(focus_screen._focus_area) == 1, "single item Up moves to BACK")
	_check(bool(focus_screen.handle_input(_key_event(KEY_DOWN))) and int(focus_screen._focus_area) == 0, "single item BACK Down returns to list")
	_check(bool(focus_screen.handle_input(_key_event(KEY_DOWN))) and int(focus_screen._focus_area) == 1, "single item Down moves to BACK")
	focus_screen.close_screen()

	CodexManager.initialize_empty()
	focus_screen.open_screen("title", {}, {"category": "weapons"})
	var invalid_confirm_before := focus_confirm_events
	focus_screen._open_detail(-1)
	_check(focus_confirm_events == invalid_confirm_before, "invalid detail index does not emit confirm")
	focus_screen._new_only = true
	focus_screen._new_snapshot_ids[CodexManager.CATEGORY_WEAPON] = []
	focus_screen._refresh_list_and_detail()
	_check(bool(focus_screen.handle_input(_key_event(KEY_UP))) and int(focus_screen._focus_area) == 1, "empty list Up moves to BACK")
	focus_screen.handle_input(_key_event(KEY_DOWN))
	_check(int(focus_screen._focus_area) == 1, "empty list Down remains safely in BACK")
	focus_screen.close_screen()
	focus_screen.queue_free()
	CodexManager.initialize_empty()
	CodexManager.discover_enemy("enemy_bullet_drone")

func _key_event(keycode: Key) -> InputEventKey:
	var event := InputEventKey.new()
	event.pressed = true
	event.keycode = keycode
	return event

func _test_game_cursor_se_connection() -> void:
	var game = GameScene.instantiate()
	add_child(game)
	await get_tree().process_frame
	await get_tree().process_frame
	var runtime_screen = game.codex_screen
	var connected := false
	for connection in runtime_screen.get_signal_connection_list("cursor_moved"):
		var callable: Callable = connection.get("callable", Callable())
		if callable.is_valid() and callable.get_object() == game and callable.get_method() == "_on_codex_cursor_moved":
			connected = true
	_check(connected, "runtime cursor signal is connected to Game handler")
	_check(game.ui_se_player != null and game.ui_se_player.stream != null, "runtime cursor SE player has a stream")
	CodexManager.initialize_empty()
	game.state = "codex"
	runtime_screen.size = Vector2(1280, 720)
	runtime_screen.open_screen("title", {}, {"category": CodexManager.CATEGORY_CHARACTER})
	runtime_screen._selected_ids[CodexManager.CATEGORY_CHARACTER] = "ban_chan"
	runtime_screen._refresh_list_and_detail()
	runtime_screen.handle_input(_key_event(KEY_UP))
	_check(int(runtime_screen._focus_area) == 1, "runtime boundary input enters BACK")
	_check(game.ui_se_player.playing, "runtime boundary input starts cursor SE")
	game.queue_free()
	await get_tree().process_frame
	CodexManager.initialize_empty()
	CodexManager.discover_enemy("enemy_bullet_drone")

func _pad_event(button_index: int) -> InputEventJoypadButton:
	var event := InputEventJoypadButton.new()
	event.pressed = true
	event.button_index = button_index
	return event

func _motion_event(axis: int, value: float) -> InputEventJoypadMotion:
	var event := InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = value
	return event

func _list_has_cursor(screen: Control) -> bool:
	if screen._list_box == null:
		return false
	for child in screen._list_box.get_children():
		if child is Button and String((child as Button).text).begins_with("▶"):
			return true
	return false

func _list_rows_are_normal(screen: Control) -> bool:
	if screen._list_box == null:
		return true
	for child in screen._list_box.get_children():
		if child is Button:
			var style := (child as Button).get_theme_stylebox("normal") as StyleBoxFlat
			if style != null and style.border_width_left > 1:
				return false
	return true

func _codex_buttons_are_manual_focus_only(screen: Control) -> bool:
	var buttons: Array = []
	buttons.append_array(screen._category_buttons)
	buttons.append_array(screen._enemy_filter_buttons)
	buttons.append(screen._all_filter_button)
	buttons.append(screen._new_filter_button)
	buttons.append(screen._detail_back_button)
	buttons.append(screen._detail_prev_button)
	buttons.append(screen._detail_next_button)
	buttons.append_array(screen._list_box.get_children())
	for button_value in buttons:
		var button := button_value as Button
		if button == null or button.focus_mode != Control.FOCUS_NONE:
			return false
	return true

func _contains_id(items: Array, id: String) -> bool:
	for item in items:
		if item is Dictionary and String((item as Dictionary).get("id", "")) == id:
			return true
	return false
