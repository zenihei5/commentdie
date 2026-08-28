extends Node

const OptionsUiSystemScript := preload("res://scripts/systems/options_ui_system.gd")
const SettingsSystemScript := preload("res://scripts/systems/settings_system.gd")
const StateFlowSystemScript := preload("res://scripts/systems/state_flow_system.gd")

var failures: Array[String] = []
var option_menu_index: int = 0

func _ready() -> void:
	_run_all_tests()
	if failures.is_empty():
		print("OPTIONS_UI_V1_TESTS: PASS")
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("OPTIONS_UI_V1_TESTS: FAIL (%d)" % failures.size())
		get_tree().quit(1)

func _run_all_tests() -> void:
	var panel := OptionsUiSystemScript.panel_rect()
	_check(panel == Rect2(230, 46, 1140, 812), "options panel geometry is stable")
	var cards: Array[Rect2] = []
	for index in range(OptionsUiSystemScript.OPTION_ITEM_COUNT):
		var card := OptionsUiSystemScript.card_rect(index)
		cards.append(card)
		_check(panel.encloses(card), "option card %d stays inside panel" % index)
		_check(card.size == Vector2(1036, 64), "option card %d uses the shared height" % index)
		var control := OptionsUiSystemScript.control_rect(index)
		_check(card.encloses(control), "option control %d stays inside card" % index)
		for sub_rect in [OptionsUiSystemScript.slider_rect(index), OptionsUiSystemScript.toggle_rect(index), OptionsUiSystemScript.selector_rect(index)]:
			_check(card.encloses(sub_rect), "option sub-control %d stays inside card" % index)
	for index in range(1, cards.size()):
		_check(not cards[index - 1].intersects(cards[index]), "option cards do not overlap")
		_check_approx(cards[index].position.y - cards[index - 1].end.y, 10.0, "option card vertical gap")

	var guide := OptionsUiSystemScript.guide_rect()
	var back := OptionsUiSystemScript.back_rect()
	var reset := OptionsUiSystemScript.reset_rect()
	_check(panel.encloses(guide) and panel.encloses(back) and panel.encloses(reset), "footer regions stay inside panel")
	_check(back.position.x < guide.position.x and guide.end.x < reset.position.x, "footer order is back, guide, reset")
	_check(not guide.intersects(back) and not guide.intersects(reset) and not back.intersects(reset), "footer regions do not overlap")
	_check(OptionsUiSystemScript.action_ids() == ["back", "reset"], "footer action order is stable")

	var modal := OptionsUiSystemScript.modal_rect()
	_check(panel.encloses(modal), "reset modal stays inside options panel")
	var modal_buttons: Array[Rect2] = []
	for index in range(2):
		var button := OptionsUiSystemScript.modal_button_rect(index)
		modal_buttons.append(button)
		_check(modal.encloses(button), "reset modal button %d stays inside modal" % index)
		_check(OptionsUiSystemScript.modal_choice_at(button.get_center()) == index, "reset modal button hit %d" % index)
	_check(not modal_buttons[0].intersects(modal_buttons[1]), "reset modal choices do not overlap")
	_check(OptionsUiSystemScript.reset_confirmation_action(0, "option_select") == "cancel", "reset modal defaults to cancel")
	_check(OptionsUiSystemScript.reset_confirmation_action(1, "option_select") == "reset", "reset modal confirm reaches reset action")
	_check(OptionsUiSystemScript.reset_confirmation_action(0, "back_to_title") == "cancel", "reset modal escape cancels")
	_check(OptionsUiSystemScript.reset_confirmation_action(0, "option_left") == "toggle", "reset modal left/right changes choice")

	_check(OptionsUiSystemScript.slider_value_from_position(0, OptionsUiSystemScript.slider_rect(0).position.x) == 0, "slider 0 percent reaches left edge")
	_check(OptionsUiSystemScript.slider_value_from_position(0, OptionsUiSystemScript.slider_rect(0).end.x) == 100, "slider 100 percent reaches right edge")
	_check(OptionsUiSystemScript.slider_label(0) == "0%" and OptionsUiSystemScript.slider_label(100) == "100%", "slider labels use percent format")
	_check(OptionsUiSystemScript.toggle_label(true) == "ON" and OptionsUiSystemScript.toggle_label(false) == "OFF", "toggle labels are stable")
	_check(OptionsUiSystemScript.selector_label("1920×1080") == "< 1920×1080 >", "window selector keeps multiplication sign")
	_check(OptionsUiSystemScript.footer_guide_text(OptionsUiSystemScript.return_label("title")).contains("Esc：戻る"), "title options guide returns to title")
	_check(OptionsUiSystemScript.footer_guide_text(OptionsUiSystemScript.return_label("pause")).contains("Esc：ポーズへ戻る"), "pause options guide returns to pause")
	for index in range(SettingsSystemScript.WINDOW_SIZE_LABELS.size()):
		var label := SettingsSystemScript.window_size_label(index).replace(" x ", "×")
		_check(label.length() <= 12, "window size %d stays compact" % index)

	for index in range(OptionsUiSystemScript.OPTION_ITEM_COUNT):
		var center := OptionsUiSystemScript.card_rect(index).get_center()
		_check(OptionsUiSystemScript.option_index_at(center) == index, "card center hit maps to option %d" % index)
		var gap_point := Vector2(center.x, OptionsUiSystemScript.card_rect(index).end.y + 5.0)
		_check(OptionsUiSystemScript.option_index_at(gap_point) == -1, "card gap is not clickable")
	_check(OptionsUiSystemScript.option_index_at(back.get_center()) == OptionsUiSystemScript.BACK_INDEX, "back hit maps to back")
	_check(OptionsUiSystemScript.option_index_at(reset.get_center()) == OptionsUiSystemScript.RESET_INDEX, "reset hit maps to reset")

	_check(OptionsUiSystemScript.pad_action(JOY_BUTTON_DPAD_UP) == "option_up", "pad up maps to option up")
	_check(OptionsUiSystemScript.pad_action(JOY_BUTTON_DPAD_DOWN) == "option_down", "pad down maps to option down")
	_check(OptionsUiSystemScript.pad_action(JOY_BUTTON_A) == "option_select", "pad A maps to option select")
	_check(OptionsUiSystemScript.pad_action(JOY_BUTTON_B) == "back_to_title", "pad B maps to back")
	_check(OptionsUiSystemScript.ui_action("ui_accept") == "option_select", "ui accept maps to option select")
	_check(OptionsUiSystemScript.ui_action("ui_cancel") == "back_to_title", "ui cancel maps to back")
	_check(OptionsUiSystemScript.vertical_navigation_index(5, 1) == OptionsUiSystemScript.BACK_INDEX, "last option moves to back")
	_check(OptionsUiSystemScript.vertical_navigation_index(0, -1) == OptionsUiSystemScript.BACK_INDEX, "first option wraps to back")
	_check(OptionsUiSystemScript.button_navigation_index(OptionsUiSystemScript.BACK_INDEX, 1) == OptionsUiSystemScript.RESET_INDEX, "back moves right to reset")
	_check(OptionsUiSystemScript.vertical_navigation_index(OptionsUiSystemScript.BACK_INDEX, -1) == 5, "back moves up to last option")
	_check(OptionsUiSystemScript.vertical_navigation_index(OptionsUiSystemScript.BACK_INDEX, 1) == 0, "back moves down to first option")
	_check(OptionsUiSystemScript.vertical_navigation_index(OptionsUiSystemScript.RESET_INDEX, -1) == 5, "reset moves up to last option")
	_check(OptionsUiSystemScript.vertical_navigation_index(OptionsUiSystemScript.RESET_INDEX, 1) == 0, "reset moves down to first option")
	_check(StateFlowSystemScript.OPTION_RESET_INDEX == OptionsUiSystemScript.RESET_INDEX, "state flow reset index matches shared helper")
	_check(StateFlowSystemScript.OPTION_BACK_INDEX == OptionsUiSystemScript.BACK_INDEX, "state flow back index matches shared helper")
	_check(StateFlowSystemScript.option_vertical_navigation_index(5, 1) == OptionsUiSystemScript.BACK_INDEX, "state flow last option moves to back")
	_check(StateFlowSystemScript.option_vertical_navigation_index(0, -1) == OptionsUiSystemScript.BACK_INDEX, "state flow first option wraps to back")
	_check(StateFlowSystemScript.option_vertical_navigation_index(OptionsUiSystemScript.BACK_INDEX, -1) == 5, "state flow back moves up to last option")
	_check(StateFlowSystemScript.option_vertical_navigation_index(OptionsUiSystemScript.RESET_INDEX, -1) == 5, "state flow reset moves up to last option")
	_check(StateFlowSystemScript.option_vertical_navigation_index(OptionsUiSystemScript.BACK_INDEX, 1) == 0, "state flow back moves down to first option")
	_check(StateFlowSystemScript.option_vertical_navigation_index(OptionsUiSystemScript.RESET_INDEX, 1) == 0, "state flow reset moves down to first option")
	_check(StateFlowSystemScript.option_button_navigation_index(OptionsUiSystemScript.BACK_INDEX, -1) == OptionsUiSystemScript.RESET_INDEX, "state flow back moves left to reset")
	_check(StateFlowSystemScript.option_button_navigation_index(OptionsUiSystemScript.RESET_INDEX, 1) == OptionsUiSystemScript.BACK_INDEX, "state flow reset moves right to back")
	option_menu_index = 5
	StateFlowSystemScript.apply_options_action_for_target(self, "option_down")
	_check(option_menu_index == OptionsUiSystemScript.BACK_INDEX, "state flow option_down reaches back in production path")
	_check(OptionsUiSystemScript.button_navigation_index(OptionsUiSystemScript.RESET_INDEX, 1) == OptionsUiSystemScript.BACK_INDEX, "reset moves horizontally to back")
	_check(OptionsUiSystemScript.button_navigation_index(OptionsUiSystemScript.BACK_INDEX, -1) == OptionsUiSystemScript.RESET_INDEX, "back moves horizontally to reset")

	var engaged := OptionsUiSystemScript.stick_latch_transition(0, 0.7)
	_check(bool(engaged["moved"]) and int(engaged["latch"]) == 1, "stick engages once")
	var held := OptionsUiSystemScript.stick_latch_transition(int(engaged["latch"]), 0.8)
	_check(not bool(held["moved"]) and int(held["latch"]) == 1, "held stick does not repeat")
	var released := OptionsUiSystemScript.stick_latch_transition(int(held["latch"]), 0.0)
	_check(not bool(released["moved"]) and int(released["latch"]) == 0, "stick releases below hysteresis")
	var reengaged := OptionsUiSystemScript.stick_latch_transition(int(released["latch"]), -0.7)
	_check(bool(reengaged["moved"]) and int(reengaged["direction"]) == -1, "opposite stick direction reengages once")

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _check_approx(actual: float, expected: float, message: String) -> void:
	if absf(actual - expected) > 0.01:
		failures.append("%s (actual %.2f expected %.2f)" % [message, actual, expected])
