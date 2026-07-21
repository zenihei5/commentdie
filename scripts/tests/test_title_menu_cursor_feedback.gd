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
	_check(game._title_menu_action_for_index(2) == "open_title_ranking", "ranking action mapping")
	_check(game._title_menu_action_for_index(3) == "open_title_options", "options action mapping")
	_check(game._title_menu_action_for_index(4) == "quit_game", "quit action mapping")

	game.title_menu_press_active = false
	game.title_menu_press_timer = 0.0
	game._request_title_menu_activation(1, "open_power_up_shop")
	var pending_action := game.title_menu_pending_action
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
