extends Node

const GameScript := preload("res://scripts/game.gd")

var failures: Array[String] = []

func _ready() -> void:
	_run_all_tests()
	if failures.is_empty():
		print("TITLE_MENU_CURSOR_FEEDBACK_TESTS: PASS")
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("TITLE_MENU_CURSOR_FEEDBACK_TESTS: FAIL (%d)" % failures.size())
		get_tree().quit(1)

func _run_all_tests() -> void:
	var game = GameScript.new()
	game.state = "title"
	game.title_menu_index = 0
	game.title_menu_focus_timer = 0.14
	_check(GameScript.TITLE_MENU_BUTTON_SIZE == Vector2(306.0, 66.0), "title buttons use the shared 306x66 base size")
	var base_rects: Array[Rect2] = []
	for index in range(GameScript.TITLE_MENU_COUNT):
		var base_rect: Rect2 = game._title_menu_button_rect(index)
		base_rects.append(base_rect)
		_check(base_rect.size == Vector2(306.0, 66.0), "title button %d base size" % index)
		_check_approx(base_rect.get_center().x, 800.0, "title button %d center x" % index)
		var image_path := String(GameScript.TITLE_MENU_BUTTON_IMAGES[index])
		var source_image := Image.load_from_file(ProjectSettings.globalize_path(image_path))
		_check(source_image != null and not source_image.is_empty(), "title button %d source image loads" % index)
		var source_rect: Rect2 = GameScript.TITLE_MENU_BUTTON_SOURCE_RECTS[index]
		var image_size := Vector2(source_image.get_width(), source_image.get_height())
		_check(source_rect.position.x >= 0.0 and source_rect.position.y >= 0.0 and source_rect.end.x <= image_size.x and source_rect.end.y <= image_size.y, "title button %d source rect is inside texture" % index)
	for index in range(1, base_rects.size()):
		var previous_rect: Rect2 = base_rects[index - 1]
		var current_rect: Rect2 = base_rects[index]
		_check_approx(current_rect.position.y - previous_rect.end.y, 10.0, "title button %d gap" % index)
	_check_approx(base_rects[0].position.y, 444.0, "title menu first visible y")
	_check_approx(base_rects[5].end.y, 890.0, "title menu last visible bottom")
	_check(game._title_button_index_at(base_rects[2].get_center()) == 2, "codex mouse hit uses the shared base rect")
	var shop_status_rect := game._title_power_up_shop_status_rect(base_rects[1])
	_check(base_rects[1].encloses(shop_status_rect), "shop status stays inside the shop base rect")
	var codex_badge_rect := game._title_codex_new_badge_rect(base_rects[2])
	_check(not codex_badge_rect.intersects(base_rects[1]) and not codex_badge_rect.intersects(base_rects[3]), "codex NEW badge stays clear of adjacent buttons")
	game.title_menu_index = 2
	var selected_draw_rect: Rect2 = game._title_menu_button_draw_rect(2)
	_check_approx(selected_draw_rect.size.x / base_rects[2].size.x, 1.025, "selected title button keeps the existing 2.5 percent scale")
	_check_approx(selected_draw_rect.size.y / base_rects[2].size.y, 1.025, "selected title button keeps the existing vertical scale")
	for index in range(GameScript.TITLE_MENU_COUNT):
		_check(game._title_button_hit_rect(index) == base_rects[index], "title button %d hit rect ignores feedback scale" % index)
	game.title_menu_index = 0
	var settled: Dictionary = game._title_menu_feedback(0)
	_check_approx(float(settled.get("scale", 0.0)), 1.025, "selected scale settles at 1.025")
	_check_approx(float(settled.get("offsetY", 0.0)), -2.0, "selected offset settles at -2")
	_check_approx(float(game._title_menu_feedback(1).get("scale", 0.0)), 1.0, "non-selected scale stays at 1")
	_check_approx(float(game._title_menu_feedback(1).get("offsetY", 0.0)), 0.0, "non-selected offset stays at 0")
	game.title_menu_marker_time = 0.2
	_check_approx(float(game._title_menu_feedback(0).get("markerOffset", 0.0)), 2.0, "marker movement is capped at 2px")

	var selection_rect := Rect2(100.0, 200.0, 264.0, 276.0)
	var selection_focus: Dictionary = game._pre_run_selection_focus_feedback(selection_rect, true, 0.25)
	var selection_visual: Rect2 = selection_focus.get("visualRect", Rect2()) as Rect2
	_check(selection_visual.size.x > selection_rect.size.x, "pre-run selected card is enlarged")
	_check(selection_visual.position.y < selection_rect.position.y, "pre-run selected card lifts upward")
	_check_approx(float(selection_focus.get("markerOffset", 0.0)), 2.0, "pre-run marker movement matches title cursor")
	var selection_idle: Dictionary = game._pre_run_selection_focus_feedback(selection_rect, false, 0.25)
	_check((selection_idle.get("visualRect", Rect2()) as Rect2) == selection_rect, "pre-run non-selected card keeps its visual rect")
	_check_approx(float(selection_idle.get("glowAlpha", -1.0)), 0.0, "pre-run non-selected card has no cursor glow")
	game.pre_run_select_press_active = true
	game.pre_run_select_press_screen = "character_select"
	game.pre_run_select_pressed_index = 0
	game.pre_run_select_press_timer = 0.06
	var selection_pressed: Dictionary = game._pre_run_selection_focus_feedback(selection_rect, true, 0.25, true)
	_check_approx(float(selection_pressed.get("scale", 0.0)), 0.975, "pre-run press-down scale reaches 0.975")
	_check_approx(float(selection_pressed.get("offsetY", 0.0)), 4.0, "pre-run press-down sinks by 4px")
	_check((selection_pressed.get("visualRect", Rect2()) as Rect2).size.x < selection_rect.size.x, "pre-run press changes only the visual rect")
	_check(game._pre_run_select_card_is_pressed("character_select", 0), "character card reports active press")
	_check(not game._pre_run_select_card_is_pressed("stream_frame_select", 0), "press feedback does not leak to frame screen")
	game._reset_pre_run_select_press_feedback()
	_check(not game.pre_run_select_press_active and game.pre_run_select_pressed_index == -1, "pre-run press reset clears transient state")

	game.title_menu_press_active = true
	game.title_menu_pressed_index = 0
	game.title_menu_press_timer = 0.06
	var pressed: Dictionary = game._title_menu_feedback(0)
	_check_approx(float(pressed.get("scale", 0.0)), 0.970, "press-down scale reaches 0.970")
	_check_approx(float(pressed.get("offsetY", 0.0)), 4.0, "press-down offset reaches +4")

	var hit_before: Rect2 = game._title_button_hit_rect(0)
	var visual_during_press: Rect2 = game._title_menu_button_draw_visual_rect(0)
	_check(hit_before != visual_during_press, "press changes visual rect")
	_check(game._title_button_hit_rect(0) == hit_before, "press does not change hit rect")

	_check(game._title_menu_action_for_index(0) == "start_character_select", "new game action mapping")
	_check(game._title_menu_action_for_index(1) == "open_power_up_shop", "shop action mapping")
	_check(game._title_menu_action_for_index(2) == "open_codex", "codex action mapping")
	_check(game._title_menu_action_for_index(3) == "open_title_ranking", "ranking action mapping")
	_check(game._title_menu_action_for_index(4) == "open_title_options", "options action mapping")
	_check(game._title_menu_action_for_index(5) == "quit_game", "quit action mapping")
	_check(GameScript.TITLE_MENU_BUTTON_IMAGES[2] == "res://assets/title/menu_buttons_v2/title_menu_codex.png", "title codex button uses supplied image")
	_check(FileAccess.file_exists(GameScript.TITLE_MENU_BUTTON_IMAGES[2]), "title codex button image exists")
	_check(absf(game._title_menu_button_rect(2).size.y - game._title_menu_button_rect(0).size.y) < 0.5, "title codex button matches standard menu height")
	CodexManager.initialize_empty()
	_check(game._codex_title_new_badge_text() == "", "codex title badge hides at zero")
	CodexManager.discover_weapon("ban_hammer")
	_check(game._codex_title_new_badge_text() != "", "codex title badge appears for NEW")
	CodexManager.mark_read(CodexManager.CATEGORY_WEAPON, "ban_hammer")
	_check(game._codex_title_new_badge_text() == "", "codex title badge updates after read")

	game.title_menu_press_active = false
	game.title_menu_press_timer = 0.0
	game._request_title_menu_activation(1, "open_power_up_shop")
	var pending_action: String = String(game.title_menu_pending_action)
	game._request_title_menu_activation(2, "open_title_ranking")
	_check(game.title_menu_press_active, "activation enters press state")
	_check(game.title_menu_pending_action == pending_action, "second activation is ignored while pressing")
	_check(game._update_title_menu_feedback(0.14), "press completion commits once")
	_check(not game.title_menu_press_active and game.title_menu_pending_action == "", "commit clears pending press")
	_check(not game._update_title_menu_feedback(0.14), "completed press does not commit again")

func _check(condition: bool, label: String) -> void:
	if not condition:
		failures.append(label)

func _check_approx(actual: float, expected: float, label: String) -> void:
	if not is_equal_approx(actual, expected):
		failures.append("%s: got %f expected %f" % [label, actual, expected])
