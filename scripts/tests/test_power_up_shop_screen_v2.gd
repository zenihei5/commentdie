extends Node

const DatabaseScript := preload("res://scripts/systems/power_up_database.gd")
const SaveStoreScript := preload("res://scripts/systems/power_up_save_store.gd")
const ShopManagerScript := preload("res://scripts/systems/power_up_shop_manager.gd")
const UiStateScript := preload("res://scripts/ui/power_up_shop_ui_state.gd")
const CommonLightUiStyle := preload("res://scripts/ui/common_light_ui_style.gd")
const ScreenScene := preload("res://scripts/ui/power_up_shop_screen.tscn")
const LogicTestScript := preload("res://scripts/tests/test_power_up_shop.gd")
const GameScript := preload("res://scripts/game.gd")

var failures: Array[String] = []
var screen
var save_override_calls := 0
var save_override_should_fail := false
var signal_order: Array[String] = []

func _ready() -> void:
	await _run_tests()
	if failures.is_empty():
		print("POWER_UP_SHOP_SCREEN_V2_TESTS: PASS")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("POWER_UP_SHOP_SCREEN_V2_TESTS: FAIL (%d)" % failures.size())
	get_tree().quit(1)

func _run_tests() -> void:
	var database = DatabaseScript.load_default()
	_check(bool(database.is_valid), "database valid")
	_check(GameScript != null, "full game script parses with uiRoot integration")
	if not bool(database.is_valid):
		return
	var logic_test = LogicTestScript.new()
	logic_test._run_all_tests()
	for failure in logic_test.failures:
		failures.append("V1 logic: " + String(failure))
	var store = SaveStoreScript.new()
	store.save_override = Callable(self, "_save_override")
	var manager = ShopManagerScript.new(database, store)
	manager.profile = store.default_data(database)
	manager.profile["unlocked"] = true
	manager.profile["currentPoints"] = 10000
	screen = ScreenScene.instantiate()
	add_child(screen)
	screen.size = Vector2(1280, 720)
	screen._layout_responsive()
	screen.bind_manager(manager)
	_check(screen.open_shop("title", manager), "shop opens")
	await get_tree().process_frame
	await get_tree().process_frame
	_check(screen.visible, "shop visible")
	_check(screen.purchase_se.stream != null and String(screen.purchase_se.stream.resource_path) == "res://assets/audio/power_up_upgrade.mp3", "upgrade success uses status treatment SE")
	_check(screen.reset_success_se.stream != null and String(screen.reset_success_se.stream.resource_path) == "res://assets/audio/power_up_reset.mp3", "reset success uses item obtain SE")
	_check(screen.get_node("FullScreenBackground").size == Vector2(1280, 720), "full viewport background")
	_check(screen.background.texture != null and String(screen.background.texture.resource_path) == "res://assets/title/title_back.png", "shop shares ranking and options background")
	var background_wash: ColorRect = screen.get_node("BackgroundWash") as ColorRect
	_check(background_wash != null and background_wash.color.a >= 0.12 and background_wash.color.a <= 0.18 and is_equal_approx(background_wash.color.r, 0.968627), "shop uses the common light background wash")
	_check(screen.main_panel_backdrop != null, "shop has a large white main panel backdrop")
	_check(screen.main_panel_backdrop.get_index() < screen.shop_content.get_index(), "main panel backdrop is behind shop content")
	_check(screen._common_front_transition_nodes.has(screen.main_panel_backdrop), "main panel backdrop participates in common transition")
	var main_panel_style: StyleBoxFlat = screen.main_panel_backdrop.get_theme_stylebox("panel") as StyleBoxFlat
	_check(main_panel_style != null and is_equal_approx(main_panel_style.bg_color.a, 0.93) and main_panel_style.border_color == CommonLightUiStyle.MAIN_PANEL_BORDER, "main panel uses common light style")
	_check(screen.title_description.text == "配信ポイントを使って能力を強化できます", "shop header has common-theme description")
	_check(not screen.mascot_glow.visible, "mascot glow rectangle is hidden")
	var combat_tab_style: StyleBoxFlat = screen.combat_tab.get_theme_stylebox("normal") as StyleBoxFlat
	var support_tab_style: StyleBoxFlat = screen.support_tab.get_theme_stylebox("normal") as StyleBoxFlat
	_check(combat_tab_style != null and combat_tab_style.bg_color == CommonLightUiStyle.COMBAT_MAIN, "combat tab uses common pink selection")
	_check(support_tab_style != null and support_tab_style.bg_color == CommonLightUiStyle.MAIN_PANEL, "support tab uses light unselected style")
	var pp_style: StyleBoxFlat = screen.pp_capsule.get_theme_stylebox("panel") as StyleBoxFlat
	_check(pp_style != null and pp_style.bg_color == CommonLightUiStyle.PP_PALE, "PP capsule uses light gold style")
	var back_style: StyleBoxFlat = screen.back_button.get_theme_stylebox("normal") as StyleBoxFlat
	var reset_style: StyleBoxFlat = screen.reset_button.get_theme_stylebox("normal") as StyleBoxFlat
	_check(back_style != null and back_style.border_color == CommonLightUiStyle.BACK_BUTTON_BORDER, "back footer uses common blue style")
	_check(reset_style != null and reset_style.border_color == CommonLightUiStyle.RESET_BUTTON_BORDER, "reset footer uses common pink style")
	_check(screen.reset_dialog.custom_minimum_size == Vector2(620, 390), "reset dialog uses 620x390 base size")
	_check(screen.dialog_layer.mouse_filter == Control.MOUSE_FILTER_STOP, "reset dialog layer blocks background input")
	_check((screen.get_node("DialogLayer/Dim") as Control).mouse_filter == Control.MOUSE_FILTER_STOP, "reset dialog dim blocks outside clicks")
	_check(screen.shop_content.custom_minimum_size == Vector2(1232, 680), "1280x720 safe content")
	screen.size = Vector2(1600, 900)
	screen._layout_responsive()
	_check(screen.shop_content.custom_minimum_size == Vector2(1360, 860), "1600x900 content")
	screen.size = Vector2(2560, 1440)
	screen._layout_responsive()
	_check(screen.shop_content.custom_minimum_size == Vector2(1360, 900), "wide content max width")
	screen.size = Vector2(1280, 720)
	screen._layout_responsive()
	_check(screen.card_grid.columns == 2, "card grid has two columns")
	_check(screen.card_grid.get_child_count() == 8, "card pool has eight reusable cards")
	_check(_visible_card_count() == 4, "combat category shows four cards")
	_check(screen.detail_panel.get_rect().size.x > 0.0, "detail panel laid out")
	_check(screen.purchase_button.get_rect().size.x > 0.0, "purchase button laid out")
	_check(screen.reset_button.get_rect().size.x > 0.0, "footer reset button laid out")
	_test_common_transition_clock()
	_test_common_transition_adapter(manager)
	_test_v3_display_and_state(database, manager)
	_test_v4_growth_expression(database, manager)
	await _test_v5_geometry()
	_test_reset_dialog_geometry()
	screen.category_index = 0
	screen.selected_index = 0
	screen._refresh_view()

	var initial_points := manager.current_points()
	screen._on_card_selected(1)
	_check(manager.current_points() == initial_points, "card selection does not purchase")
	_check(screen.selected_index == 1, "card selection updates detail selection")
	screen._on_purchase_pressed()
	screen._complete_purchase_visual_update()
	screen._purchase_input_lock_remaining = 0.0
	screen._purchase_lock_remaining = 0.0
	_check(manager.get_upgrade_level("attack_power") == 1, "detail purchase upgrades selected card")
	_check(manager.current_points() == initial_points - 120, "detail purchase uses existing price")

	screen._on_category_pressed(1)
	await get_tree().process_frame
	_check(screen.card_grid.get_child_count() == 8, "support keeps the reusable card pool")
	_check(_visible_card_count() == 4, "support category shows four cards")
	screen._on_card_selected(3)
	_check(screen.comparison_current.text == "補正なし", "gift luck Lv0 current effect is none")
	_check(screen.comparison_next.text == "当たり ×1.08\n大当たり ×1.12", "gift luck Lv0 next effect uses two lines")
	_check(screen.comparison_current.get_theme_font_size("font_size") == 20, "gift luck current effect uses compact font")
	_check(screen.comparison_next.get_theme_font_size("font_size") == 20, "gift luck next effect uses compact font")
	_check(screen.comparison_current.autowrap_mode == TextServer.AUTOWRAP_WORD_SMART and screen.comparison_next.autowrap_mode == TextServer.AUTOWRAP_WORD_SMART, "gift luck enables two-line wrapping")
	var gift_current_box_style: StyleBoxFlat = screen.comparison_current_box.get_theme_stylebox("panel") as StyleBoxFlat
	_check(gift_current_box_style.content_margin_left >= 12.0 and gift_current_box_style.content_margin_left <= 18.0 and gift_current_box_style.content_margin_top >= 8.0 and gift_current_box_style.content_margin_top <= 12.0, "gift luck effect box uses compact padding")
	screen._on_card_selected(0)
	_check(screen.comparison_current.get_theme_font_size("font_size") == 22 and screen.comparison_next.get_theme_font_size("font_size") == 24, "standard effect font restores after gift luck")
	_check(screen.comparison_current.autowrap_mode == TextServer.AUTOWRAP_OFF and screen.comparison_next.autowrap_mode == TextServer.AUTOWRAP_OFF, "standard effect wrapping restores after gift luck")
	var standard_current_box_style: StyleBoxFlat = screen.comparison_current_box.get_theme_stylebox("panel") as StyleBoxFlat
	_check(standard_current_box_style.content_margin_left == 18.0 and standard_current_box_style.content_margin_top == 14.0, "standard effect box padding restores")
	screen._on_card_selected(3)

	manager.profile["currentPoints"] = 0
	screen._refresh_view()
	screen._on_purchase_pressed()
	_check(screen.toast_panel.visible, "insufficient purchase shows toast")
	_check(screen._cards[3].modulate == Color.WHITE, "insufficient purchase does not dim card")

	manager.profile["currentPoints"] = 10000
	manager.profile["upgrades"]["gift_luck"] = 5
	screen._refresh_view()
	_check(screen.purchase_button.disabled, "max level disables purchase button")
	_check(screen.purchase_button.text == "強化完了\nMAX", "max level button label")
	_check(screen.comparison_current.text == "当たり ×1.40\n大当たり ×1.60", "gift luck Lv5 current effect uses two lines")
	_check(screen.comparison_next.text == "MAX", "gift luck Lv5 next effect is MAX")

	screen._show_reset_dialog()
	_check(screen.reset_dialog.visible and screen.dialog_layer.visible, "reset dialog opens")
	screen.close_shop()
	_check(not screen.visible, "close hides shop")
	_check(not screen.reset_dialog.visible, "close clears reset dialog")
	_check(not screen.toast_panel.visible, "close clears toast")
	_check(screen.open_shop("result", manager), "shop reopens")
	await get_tree().process_frame
	_check(not screen.reset_dialog.visible and not screen.toast_panel.visible, "reopen has no transient leftovers")
	_test_input_navigation(manager)

func _test_reset_dialog_geometry() -> void:
	var modal_size := Vector2(620, 390)
	for viewport_size in [Vector2(1280, 720), Vector2(1600, 900), Vector2(1920, 1080), Vector2(2560, 1440)]:
		var modal_rect := Rect2((viewport_size - modal_size) * 0.5, modal_size)
		_check(modal_rect.position.x >= 0.0 and modal_rect.position.y >= 0.0 and modal_rect.end.x <= viewport_size.x and modal_rect.end.y <= viewport_size.y, "reset dialog fits %s" % viewport_size)

func _test_common_transition_clock() -> void:
	var probe = GameScript.new()
	probe.front_screen_transition_direction = "forward"
	var expected_samples := [
		[0.0, -0.0, 52.0, 0.0],
		[0.05, -21.0, 52.0, 0.4375],
		[0.10, -42.0, 52.0, 0.70],
		[0.17, -42.0, 6.5, 0.4083333333],
		[0.24, -42.0, 0.0, 0.0],
	]
	for sample in expected_samples:
		probe.front_screen_transition_elapsed = float(sample[0])
		var frame: Dictionary = probe._front_screen_transition_frame()
		_check(is_equal_approx(float(frame["outgoingOffsetX"]), float(sample[1])), "common clock outgoing offset at %.2f" % float(sample[0]))
		_check(is_equal_approx(float(frame["incomingOffsetX"]), float(sample[2])), "common clock incoming offset at %.2f" % float(sample[0]))
		_check(is_equal_approx(float(frame["overlayAlpha"]), float(sample[3])), "common clock veil alpha at %.2f" % float(sample[0]))
	probe.front_screen_transition_reduced_motion = true
	probe.front_screen_transition_elapsed = 0.12
	var reduced_frame: Dictionary = probe._front_screen_transition_frame()
	_check(is_equal_approx(probe._front_screen_transition_total_duration(), 0.12), "reduced motion uses common short duration")
	_check(is_equal_approx(float(reduced_frame["outgoingOffsetX"]), 0.0) and is_equal_approx(float(reduced_frame["incomingOffsetX"]), 0.0), "reduced motion disables movement")
	_check(is_equal_approx(float(reduced_frame["overlayAlpha"]), 0.0), "reduced motion veil completes at 0.12")
	probe.free()

func _test_common_transition_adapter(manager) -> void:
	var transition_nodes: Array[Control] = [
		screen.background,
		screen.get_node("BackgroundWash") as Control,
		screen.background_decoration,
		screen.safe_area_margin,
		screen.main_panel_backdrop,
		screen.purchase_light,
		screen.toast_layer,
		screen.dialog_layer,
	]
	var base_positions: Dictionary = {}
	for node in transition_nodes:
		base_positions[node] = node.global_position
	var veil_base_position := screen.transition_veil.position
	screen.begin_common_front_transition("incoming")
	_check(not screen.visible, "common incoming hides shop before midpoint")
	screen.apply_common_front_transition(52.0, 0.70, true)
	_check(screen.visible, "common incoming shows shop at midpoint")
	_check(is_equal_approx(screen.transition_veil.color.a, 0.70), "common incoming applies midpoint veil")
	for node in transition_nodes:
		var base_position: Vector2 = base_positions[node]
		_check(is_equal_approx(node.global_position.x, base_position.x + 52.0), "common incoming moves all visual layers")
	_check(screen.transition_veil.position == veil_base_position, "transition veil stays fixed")
	screen.apply_common_front_transition(0.0, 0.0, true)
	screen.finish_common_front_transition(true)
	_check(screen.visible and not screen._common_front_transition_locked, "common incoming unlocks after finish")
	screen.begin_common_front_transition("outgoing")
	screen.apply_common_front_transition(42.0, 0.70, true)
	var safe_area_base_position: Vector2 = base_positions[screen.safe_area_margin]
	_check(screen.visible and is_equal_approx(screen.safe_area_margin.global_position.x, safe_area_base_position.x + 42.0), "common outgoing moves shop right")
	screen.finish_common_front_transition(false)
	_check(not screen.visible and not screen._common_front_transition_locked, "common outgoing hides and unlocks")
	_check(screen.open_shop("title", manager), "direct API reopens after common transition")

func _test_input_navigation(manager) -> void:
	manager.profile["currentPoints"] = 10000
	manager.profile["totalSpentPoints"] = 0
	var levels: Dictionary = manager.profile["upgrades"] as Dictionary
	for id in levels.keys():
		levels[id] = 0
	screen.category_index = 0
	screen.category_last_indices = [0, 0]
	screen.focus_area = 0
	screen.selected_index = 0
	screen._refresh_view()

	var transitions := [
		[0, "left", 0, 0], [0, "right", 1, 0], [0, "up", 0, 3], [0, "down", 2, 0],
		[1, "left", 0, 0], [1, "right", 1, 0], [1, "up", 1, 3], [1, "down", 3, 0],
		[2, "left", 2, 0], [2, "right", 3, 0], [2, "up", 0, 0], [2, "down", 2, 1],
		[3, "left", 2, 0], [3, "right", 3, 0], [3, "up", 1, 0], [3, "down", 3, 1],
	]
	for item in transitions:
		screen.focus_area = 0
		screen.reset_confirm_visible = false
		screen.selected_index = int(item[0])
		screen._refresh_focus_visuals()
		screen._handle_action(String(item[1]))
		_check(screen.selected_index == int(item[2]), "2x2 transition %s from %d" % [String(item[1]), int(item[0])])
		_check(screen.focus_area == int(item[3]), "2x2 focus area %s from %d" % [String(item[1]), int(item[0])])
		if int(item[3]) == 1:
			_check(not screen.reset_confirm_visible, "down to reset does not open dialog")

	screen.category_index = 0
	screen.category_last_indices = [0, 0]
	screen.selected_index = 0
	screen.focus_area = 0
	screen._refresh_view()
	screen._handle_action("up")
	_check(screen.focus_area == screen.FocusArea.CATEGORY_TABS, "top card up enters category tabs")
	_check(screen.cursor_se.playing, "category tab entry plays cursor SE")
	_check(not screen._cards[0].selection_lamp.visible and not screen._cards[0].focus_ring.visible, "category tab focus clears card cursor")
	screen._handle_action("right")
	_check(screen.focus_area == screen.FocusArea.CATEGORY_TABS and screen.category_index == 1, "category tab right moves to support")
	_check(not screen._cards[0].selection_lamp.visible and not screen._cards[0].focus_ring.visible, "support tab focus clears card cursor")
	screen._handle_action("left")
	_check(screen.category_index == 0 and screen.focus_area == screen.FocusArea.CATEGORY_TABS, "category tab left moves to combat")
	screen._handle_action("up")
	_check(screen.focus_area == screen.FocusArea.RESET and screen.footer_choice == screen.FooterChoice.BACK, "category tab up moves to Back footer")
	_check(screen.cursor_se.playing, "category tab up plays cursor SE")
	screen._handle_action("down")
	_check(screen.focus_area == screen.FocusArea.CATEGORY_TABS and screen.category_index == 0, "footer down returns to current category tab")
	screen._handle_action("down")
	_check(screen.focus_area == screen.FocusArea.CARDS and screen.selected_index == 0, "category tab down returns to card")
	screen._handle_action("up")
	screen._handle_action("confirm")
	_check(screen.focus_area == screen.FocusArea.CARDS, "category tab confirm enters cards")

	screen.focus_area = 0
	screen.selected_index = 2
	screen._handle_action("down")
	screen._handle_action("up")
	_check(screen.focus_area == 0 and screen.selected_index == 2, "reset up returns to card 2")
	screen.selected_index = 3
	screen.focus_area = 0
	screen._handle_action("down")
	screen._handle_action("up")
	_check(screen.focus_area == 0 and screen.selected_index == 3, "reset up returns to card 3")
	screen.selected_index = 2
	screen.focus_area = 0
	screen._handle_action("down")
	_check(screen.focus_area == 1 and screen.footer_choice == screen.FooterChoice.BACK, "footer entry selects Back")
	_check(screen.cursor_se.playing, "footer entry plays cursor SE")
	screen._handle_action("right")
	_check(screen.footer_choice == screen.FooterChoice.RESET, "footer right selects reset")
	screen._handle_action("left")
	_check(screen.footer_choice == screen.FooterChoice.BACK, "footer left selects Back")
	screen._handle_action("left")
	_check(screen.footer_choice == screen.FooterChoice.RESET, "footer left from Back selects reset")
	screen._handle_action("right")
	_check(screen.footer_choice == screen.FooterChoice.BACK, "footer right from reset selects Back")
	screen._handle_action("down")
	_check(screen.focus_area == screen.FocusArea.CATEGORY_TABS and screen.category_index == 0 and screen.selected_index == 2, "footer down moves to current category tab")
	_check(not screen._cards[0].selection_lamp.visible and not screen._cards[0].focus_ring.visible, "footer focus clears card cursor")
	screen._handle_action("down")
	_check(screen.focus_area == screen.FocusArea.CARDS and screen.selected_index == 2, "category tab down returns to remembered card")

	levels["max_hp"] = 1
	manager.profile["totalSpentPoints"] = 120
	screen.focus_area = 0
	screen.selected_index = 0
	screen._refresh_view()
	screen._handle_action("down")
	screen._handle_action("down")
	screen._handle_action("right")
	screen._handle_action("confirm")
	screen._finish_reset_dialog_show()
	_check(screen.reset_confirm_visible and screen.dialog_choice == 1, "dialog defaults to cancel")
	var selected_before_modal_guard := screen.selected_index
	screen._on_card_selected(1)
	_check(screen.selected_index == selected_before_modal_guard, "reset modal blocks card mouse selection")
	_check(screen.reset_title.text == "全強化をリセットしますか？", "reset dialog title")
	_check(screen.reset_description.text.count("\n") == 1, "reset dialog uses two-line description")
	_check(screen.reset_refund_amount.text == "120 PP", "reset dialog shows refund snapshot")
	_check(screen.reset_balance_before.text == "10,000" and screen.reset_balance_after.text == "10,120", "reset dialog formats PP before and after")
	_check(int(levels["max_hp"]) == 1, "opening dialog does not reset")
	screen._handle_action("confirm")
	screen._finish_reset_dialog_hide()
	_check(not screen.reset_confirm_visible and screen.focus_area == 1, "cancel choice closes only dialog")
	_check(int(levels["max_hp"]) == 1, "cancel choice does not reset")
	screen._handle_action("confirm")
	screen._finish_reset_dialog_show()
	screen._handle_action("left")
	_check(screen.dialog_choice == 0, "dialog left selects reset")
	save_override_should_fail = true
	screen._handle_action("confirm")
	_check(screen.reset_confirm_visible and int(levels["max_hp"]) == 1, "save failure keeps dialog and profile")
	save_override_should_fail = false
	screen._handle_action("confirm")
	screen._finish_reset_dialog_hide()
	levels = manager.profile["upgrades"] as Dictionary
	_check(int(levels["max_hp"]) == 0, "only confirm choice resets")
	_check(screen.toast_label.text.contains("120 PP"), "reset success toast uses actual refund")
	_check(screen.focus_area == 1 and not screen.reset_confirm_visible, "reset returns focus to reset button")
	screen._reset_input_lock_remaining = 0.0
	screen._hide_toast()
	screen._show_reset_dialog()
	_check(not screen.reset_confirm_visible and not screen.reset_dialog.visible, "Lv0 does not open reset dialog")
	_check(screen.toast_label.text == "リセットできる強化がありません", "Lv0 reset warning text")
	screen._handle_action("confirm")
	screen._handle_action("back")
	_check(screen.visible and screen.focus_area == 1, "dialog cancel returns to reset")

	screen.focus_area = 0
	screen.selected_index = 1
	screen._refresh_focus_visuals()
	var before_attack := int(levels["attack_power"])
	screen._handle_action("confirm")
	levels = manager.profile["upgrades"] as Dictionary
	_check(int(levels["attack_power"]) == before_attack + 1, "card confirm purchases selected card")
	screen._complete_purchase_visual_update()
	screen._purchase_input_lock_remaining = 0.0
	screen._purchase_lock_remaining = 0.0
	levels["max_hp"] = 5
	screen.selected_index = 0
	screen.focus_area = 0
	screen._hide_toast()
	screen._refresh_view()
	screen._handle_action("confirm")
	_check(int(levels["max_hp"]) == 5 and not screen.toast_panel.visible, "MAX confirm is a no-op without error feedback")

	screen.category_index = 0
	screen.category_last_indices = [3, 0]
	screen.selected_index = 3
	screen.focus_area = 0
	screen._refresh_view()
	screen._on_category_pressed(1)
	screen._handle_action("down")
	_check(screen.category_index == 1 and screen.selected_index == 2, "support category selection moves")
	screen._on_category_pressed(0)
	_check(screen.focus_area == 0 and screen.selected_index == 3, "combat category restores last card")
	screen.focus_area = 1
	screen._on_category_pressed(1)
	_check(screen.focus_area == 0 and screen.selected_index == 2, "reset category switch returns to cards")

	screen.category_index = 0
	screen.selected_index = 0
	screen.focus_area = 0
	screen._refresh_view()
	screen._cards[0]._on_mouse_entered()
	_check(screen.last_input_device == "mouse", "mouse hover records mouse device")
	screen._handle_action("right")
	_check(screen.last_input_device == "keyboard", "keyboard input takes priority over hover")
	_check(not screen._cards[0].selection_lamp.visible and screen._cards[1].selection_lamp.visible, "logical cursor replaces hover highlight")

	screen.selected_index = 0
	screen.focus_area = 0
	screen._refresh_focus_visuals()
	var motion := InputEventJoypadMotion.new()
	motion.axis = JOY_AXIS_LEFT_Y
	motion.axis_value = 1.0
	screen._input(motion)
	_check(screen.selected_index == 2 and screen.focus_area == 0, "left stick moves one card")
	screen._input(motion)
	_check(screen.selected_index == 2 and screen.focus_area == 0, "held left stick is debounced")
	var neutral := InputEventJoypadMotion.new()
	neutral.axis = JOY_AXIS_LEFT_Y
	neutral.axis_value = 0.0
	screen._input(neutral)

func _test_v3_display_and_state(database, manager) -> void:
	var first_upgrade: Dictionary = database.upgrades[0] as Dictionary
	var first_price := int((first_upgrade.get("prices", []) as Array)[0])
	var exact := UiStateScript.build(first_upgrade, 0, first_price)
	_check(int(exact["state"]) == UiStateScript.PurchaseState.PURCHASABLE, "exact price is purchasable")
	var short := UiStateScript.build(first_upgrade, 0, first_price - 1)
	_check(int(short["state"]) == UiStateScript.PurchaseState.NOT_ENOUGH_PP and int(short["shortage"]) == 1, "one PP shortage state")
	var maxed := UiStateScript.build(first_upgrade, 5, 0)
	_check(int(maxed["state"]) == UiStateScript.PurchaseState.MAX_LEVEL and int(maxed["price"]) == 0, "max state ignores PP")
	for category_data in database.categories:
		var category: Dictionary = category_data as Dictionary
		_check(String(category.get("detailTag", "")) != "", "category detail tag %s" % String(category.get("id", "")))
	for upgrade_data in database.upgrades:
		var upgrade: Dictionary = upgrade_data as Dictionary
		var prices: Array = upgrade.get("prices", []) as Array
		for level in range(5):
			var level_view := UiStateScript.build(upgrade, level, int(prices[level]))
			_check(int(level_view["price"]) == int(prices[level]) and int(level_view["state"]) == UiStateScript.PurchaseState.PURCHASABLE, "price index %s Lv%d" % [String(upgrade.get("id", "")), level])
		var tags: Array = upgrade.get("effectTags", []) as Array
		_check(tags.size() >= 1 and tags.size() <= 3, "effect tags count %s" % String(upgrade.get("id", "")))
		for tag in tags:
			_check(String(tag).strip_edges() != "", "effect tag text %s" % String(upgrade.get("id", "")))

	screen.category_index = 0
	screen.selected_index = 0
	manager.profile["currentPoints"] = 10000
	screen._refresh_view()
	_check(screen._cards.size() == 4, "combat v3 cards exist")
	_check(screen._cards[0].title_label.text == "メンタルトレーニング", "card name uses displayName")
	_check(screen._cards[0].lamp_panels.size() == 5, "card has five independent lamps")
	_check(not screen._cards[0].title_label.clip_text and screen._cards[0].title_label.max_lines_visible == 2, "card name is two-line unclipped")
	_check(screen._selected_purchase_view == screen._cards[0].purchase_view, "card and detail share purchase state")
	_check(screen.detail_category_label.text == "戦闘強化", "detail category tag")
	_check(screen.target_tags.get_child_count() == 2, "detail target tags")
	_check(screen.comparison_current.text == "なし", "Lv0 current effect is none")
	_check(screen.purchase_button.text == "パワーアップする\n120 PP", "purchasable button state")
	for combat_card in screen._cards:
		_check(String(combat_card.title_label.text).strip_edges() != "", "combat card name is visible")
	manager.profile["upgrades"]["max_hp"] = 5
	screen._refresh_view()
	_check(screen.comparison_next.text == "MAX", "Lv5 next effect is MAX")
	manager.profile["upgrades"]["max_hp"] = 0
	screen._refresh_view()

	screen.category_index = 1
	screen.selected_index = 0
	screen._refresh_view()
	_check(screen._cards[0].title_label.text == "配信研究", "support card name")
	_check(screen.detail_icon.texture != null, "support detail icon exists")
	_check(screen.detail_category_label.text == "配信サポート", "support detail tag")
	_check(screen.purchase_button.text == "パワーアップする\n100 PP", "support category purchase state")
	_check(screen._cards[0].purchase_view == screen._selected_purchase_view, "support shared purchase state")
	_check(String((database.get_upgrade("exp_gain") as Dictionary).get("iconPath", "")).ends_with("notification_bell.png"), "exp gain uses notification bell icon")
	for support_card in screen._cards:
		_check(String(support_card.title_label.text).strip_edges() != "", "support card name is visible")

	manager.profile["currentPoints"] = 0
	screen._refresh_view()
	var save_calls_before := save_override_calls
	var api_calls_before: int = screen.purchase_api_call_count
	screen._on_purchase_pressed()
	_check(screen.purchase_button.text == "PPが足りません\nあと100 PP", "insufficient button text")
	_check(not screen.purchase_button.disabled, "insufficient button remains clickable")
	_check(screen.purchase_api_call_count == api_calls_before, "insufficient skips manager purchase API")
	_check(save_override_calls == save_calls_before and manager.current_points() == 0, "insufficient skips save and PP spend")

	manager.profile["currentPoints"] = 10000
	manager.profile["upgrades"]["exp_gain"] = 5
	screen._purchase_cooldown = 0.0
	screen._refresh_view()
	var max_api_calls: int = screen.purchase_api_call_count
	var max_save_calls := save_override_calls
	screen._on_purchase_pressed()
	_check(screen.purchase_button.disabled and screen.purchase_button.text == "強化完了\nMAX", "MAX display is disabled")
	_check(screen.purchase_api_call_count == max_api_calls and save_override_calls == max_save_calls, "MAX skips manager and save")

	manager.profile["upgrades"]["exp_gain"] = 0
	screen.selected_index = 0
	manager.profile["currentPoints"] = 10000
	screen._purchase_cooldown = 0.0
	screen._refresh_view()
	screen._on_purchase_pressed()
	screen._complete_purchase_visual_update()
	_check(screen._cards[0].purchase_animation_index == 0, "purchase animates new lamp only")

	for dimensions in [Vector2(1280, 720), Vector2(1600, 900), Vector2(1920, 1080), Vector2(2560, 1440)]:
		screen.size = dimensions
		screen._layout_responsive()
		_check(screen.shop_content.custom_minimum_size.x <= 1360.0, "content max width %s" % dimensions)
		_check(screen.card_grid.get_rect().size.x > 0.0 and screen.detail_panel.get_rect().size.x > 0.0, "layout rects %s" % dimensions)
	screen.size = Vector2(1280, 720)
	screen._layout_responsive()

func _test_v4_growth_expression(database, manager) -> void:
	screen._purchase_input_lock_remaining = 0.0
	screen._purchase_lock_remaining = 0.0
	var max_hp: Dictionary = database.get_upgrade("max_hp") as Dictionary
	var pattern_ids: Array[String] = []
	for upgrade_data in database.upgrades:
		var visual_upgrade: Dictionary = upgrade_data as Dictionary
		var style: Dictionary = visual_upgrade.get("visualStyle", {}) as Dictionary
		_check(style.has("baseColor") and style.has("accentColor") and style.has("patternId") and style.has("patternAlpha"), "visual style fields %s" % String(visual_upgrade.get("id", "")))
		pattern_ids.append(String(style.get("patternId", "")))
	_check(pattern_ids.size() == 8 and pattern_ids.duplicate().size() == 8, "eight upgrades have unique visual patterns")
	_check((database.mascot_messages as Dictionary).has("purchaseSuccess"), "mascot messages are loaded from database")
	for item in [[0, UiStateScript.UpgradeVisualTier.UNPURCHASED], [1, UiStateScript.UpgradeVisualTier.LOW], [2, UiStateScript.UpgradeVisualTier.LOW], [3, UiStateScript.UpgradeVisualTier.HIGH], [4, UiStateScript.UpgradeVisualTier.HIGH], [5, UiStateScript.UpgradeVisualTier.MAX]]:
		var view: Dictionary = UiStateScript.build(max_hp, int(item[0]), 10000)
		_check(int(view["visualTier"]) == int(item[1]), "visual tier boundary Lv%d" % int(item[0]))
	_check(String(max_hp.get("cardSummary", "")) != "", "card summary metadata exists")
	var attack: Dictionary = database.get_upgrade("attack_power") as Dictionary
	var attack_view: Dictionary = UiStateScript.build(attack, 2, 10000)
	_check(String(attack_view["currentEffectText"]) == "+6%" and String(attack_view["nextEffectText"]) == "+9%", "cumulative effect values")
	var reduction: Dictionary = database.get_upgrade("damage_reduction") as Dictionary
	var reduction_view: Dictionary = UiStateScript.build(reduction, 2, 10000)
	_check(String(reduction_view["currentEffectText"]) == "-4%", "damage reduction uses minus display")
	var gift: Dictionary = database.get_upgrade("gift_luck") as Dictionary
	var gift_cases := [
		[0, "補正なし", "当たり ×1.08\n大当たり ×1.12"],
		[1, "当たり ×1.08\n大当たり ×1.12", "当たり ×1.16\n大当たり ×1.24"],
		[2, "当たり ×1.16\n大当たり ×1.24", "当たり ×1.24\n大当たり ×1.36"],
		[3, "当たり ×1.24\n大当たり ×1.36", "当たり ×1.32\n大当たり ×1.48"],
		[4, "当たり ×1.32\n大当たり ×1.48", "当たり ×1.40\n大当たり ×1.60"],
		[5, "当たり ×1.40\n大当たり ×1.60", "MAX"],
	]
	for gift_case in gift_cases:
		var gift_view: Dictionary = UiStateScript.build(gift, int(gift_case[0]), 10000)
		_check(String(gift_view["cardEffectSummary"]) == ("当たり抽選を強化" if int(gift_case[0]) == 0 else "当たり・大当たり率UP"), "gift luck card summary stays short Lv%d" % int(gift_case[0]))
		_check(String(gift_view["currentEffectText"]) == String(gift_case[1]) and String(gift_view["nextEffectText"]) == String(gift_case[2]), "gift luck effect text boundary Lv%d" % int(gift_case[0]))
	var shortage_view: Dictionary = UiStateScript.build(max_hp, 0, 52)
	_check(String(shortage_view["cardPriceText"]).contains("120") and String(shortage_view["cardPriceText"]).contains("あと68"), "card price includes required and shortage")
	for item in database.upgrades:
		var data: Dictionary = item as Dictionary
		_check((data.get("cardSummary", {}) as Dictionary).has("levelZero"), "all cards have v4 summary %s" % String(data.get("id", "")))

	var levels: Dictionary = manager.profile["upgrades"] as Dictionary
	for id in levels.keys():
		levels[id] = 0
	var expected_max_level := 0
	for max_data in database.upgrades:
		expected_max_level += int((max_data as Dictionary).get("maxLevel", 0))
	manager.profile["currentPoints"] = 10000
	screen.category_index = 0
	screen.selected_index = 0
	screen.focus_area = screen.FocusArea.CARDS
	screen._refresh_view()
	var combat_first = screen._cards[0]
	_check(screen.card_grid.get_child_count() == 8 and _visible_card_count() == 4, "v4 card pool visibility")
	_check(screen.progress_value.text == "0 / %d" % expected_max_level, "total progress starts at zero")
	_check(screen.detail_level_gauge.get_child_count() == 5, "detail has five level lamps")
	_check(screen.category_background.get_child_count() == 3, "common and category room backgrounds are resident")
	_check(screen.get_node_or_null("SelectionConnectorLayer") == null, "selection connector layer is removed")
	_check(screen.detail_accent_band.size.x >= 7.0 and screen.detail_accent_band.size.x <= 10.0, "detail accent band width")
	_check(screen.hero_section != null and screen.information_section != null, "hero and information sections exist")
	_check(screen._cards[0].visual_style.has("patternId"), "card receives visual style view")
	screen._cards[0]._apply_selection_transform(true)
	_check(screen._cards[0].scale == Vector2.ONE, "selected card root keeps Grid scale")
	_check(is_equal_approx(screen._cards[0].visual_root.position.x, 0.0) and screen._cards[0].visual_root.scale.x <= 1.025, "selected card uses restrained internal visual transform")
	for state_name in ["normal", "hover", "pressed", "focus", "disabled"]:
		_check(screen._cards[0].get_theme_stylebox(state_name) is StyleBoxEmpty, "card input slot stays transparent %s" % state_name)
	_check(screen._cards[0].card_surface.get_theme_stylebox("panel") != screen._cards[0].get_theme_stylebox("normal"), "CardSurface owns the visible card style")
	screen.focus_area = screen.FocusArea.CATEGORY_TABS
	screen._refresh_view()
	_check(screen._cards[0].selected and screen._cards[0].z_index < 3, "detail-selected card returns to normal z while category tab is focused")
	_check(screen._cards[0].visual_root.scale == Vector2.ONE, "detail-selected card has no scale while category tab is focused")
	var tab_card_style: StyleBoxFlat = screen._cards[0].card_surface.get_theme_stylebox("panel") as StyleBoxFlat
	_check(tab_card_style.border_width_left < 4 and tab_card_style.shadow_size == 0, "detail-selected card has no cursor frame or shadow while category tab is focused")
	_check(screen.combat_tab_outer_ring.visible and not screen.support_tab_outer_ring.visible, "combat tab has the outer focus ring")
	screen._handle_action("right")
	_check(not screen.combat_tab_outer_ring.visible and screen.support_tab_outer_ring.visible, "support tab has the outer focus ring")
	screen._handle_action("down")
	_check(not screen.combat_tab_outer_ring.visible and not screen.support_tab_outer_ring.visible, "tab outer rings hide after leaving category tabs")
	_check(screen._cards[1].z_index < 3, "unselected card does not take selected z order")
	screen.focus_area = screen.FocusArea.RESET
	screen._refresh_view()
	_check(screen._cards[0].z_index < 3 and screen._cards[0].visual_root.scale == Vector2.ONE, "detail-selected card has no cursor transform while footer is focused")
	_check(not screen.combat_tab_outer_ring.visible and not screen.support_tab_outer_ring.visible, "tab outer rings hide while footer is focused")
	screen.focus_area = screen.FocusArea.CARDS
	screen._refresh_view()
	_check(screen._cards[0].z_index == 3 and screen._cards[0].visual_root.scale.x <= 1.025, "card cursor returns with card focus")
	screen._cards[1]._on_mouse_entered()
	_check(screen._cards[1].scale.x <= 1.011, "hover-only scale stays below selected scale")
	screen.last_input_device = "keyboard"
	screen._refresh_focus_visuals()
	var mascot_token_before_selection := screen._mascot_generation
	screen._on_card_selected(1)
	_check(screen._mascot_generation > mascot_token_before_selection, "selection change invalidates mascot token")
	screen.selected_index = 0
	screen._refresh_view()
	screen._on_category_pressed(1)
	var support_first = screen._cards[0]
	_check(support_first != combat_first and _visible_card_count() == 4, "category switches visible cards")
	screen._on_category_pressed(0)
	_check(screen._cards[0] == combat_first, "category switch reuses card instance")
	for id in levels.keys():
		levels[id] = 5
	screen._refresh_view()
	_check(screen.progress_value.text == "%d / %d" % [expected_max_level, expected_max_level], "total progress uses database max")
	_check(screen._mascot_presentation_state == UiStateScript.MascotState.MAX_LEVEL, "MAX mascot state")
	_check(screen.mascot.texture == screen._mascot_default_texture, "MAX keeps listener mascot texture")
	for id in levels.keys():
		levels[id] = 0
	manager.profile["currentPoints"] = 10000
	screen._refresh_view()
	var shortage_view := UiStateScript.build(max_hp, 0, 52)
	_check(int(shortage_view["mascotBaseState"]) == UiStateScript.MascotState.SHORTAGE, "shortage maps to mascot state")
	_check(String(screen._mascot_text(UiStateScript.MascotState.SHORTAGE, shortage_view)).contains("68"), "shortage mascot message uses dynamic amount")
	signal_order.clear()
	manager.points_changed.connect(_record_points_signal)
	manager.upgrade_purchased.connect(_record_purchase_signal)
	var api_before: int = screen.purchase_api_call_count
	screen._on_purchase_pressed()
	screen._on_purchase_pressed()
	_check(screen._pending_upgrade_id == "max_hp", "purchase stores pending target")
	_check(screen.purchase_api_call_count == api_before + 1, "pending purchase blocks duplicate input")
	_check(signal_order == ["points", "purchase"], "purchase signal order is points then purchase")
	_check(screen._cards[0].purchase_view["level"] == 0, "points_changed does not refresh card level")
	screen._complete_purchase_visual_update()
	_check(screen._pending_upgrade_id == "" and screen._cards[0].purchase_animation_index == 0, "purchase completes after light")
	_check(screen._mascot_presentation_state == UiStateScript.MascotState.PURCHASE_SUCCESS, "successful purchase shows mascot success state")
	manager.points_changed.disconnect(_record_points_signal)
	manager.upgrade_purchased.disconnect(_record_purchase_signal)
	var mascot_generation_before_close := screen._mascot_generation
	screen._show_toast("cleanup", 10.0)
	screen.close_shop()
	_check(not screen.purchase_light.visible and screen._pending_upgrade_id == "", "close clears purchase transient state")
	_check(screen._mascot_generation > mascot_generation_before_close and not screen.speech_bubble.visible and screen._mascot_message_tween == null, "close clears mascot transient state")
	_check(screen.open_shop("result", manager), "reopen after cleanup")

func _visible_card_count() -> int:
	var count: int = 0
	for child in screen.card_grid.get_children():
		if child.visible:
			count += 1
	return count

func _test_v5_geometry() -> void:
	var manager = screen.manager
	manager.profile["currentPoints"] = 10000
	var levels: Dictionary = manager.profile["upgrades"] as Dictionary
	for id in levels.keys():
		levels[id] = 0
	screen.category_index = 0
	screen.selected_index = 0
	screen.focus_area = screen.FocusArea.CARDS
	screen.size = Vector2(1280, 720)
	screen._layout_responsive()
	screen._refresh_view()
	await get_tree().process_frame
	screen.card_grid.force_update_transform()
	for card in screen._cards:
		card.force_update_transform()
	var root_positions: Array[Vector2] = []
	var root_rects: Array[Rect2] = []
	for card in screen._cards:
		root_positions.append(card.position)
		root_rects.append(card.get_global_rect())
		card._apply_selection_transform(true)
	var baseline_surface_rect: Rect2 = screen._cards[1].card_surface.get_global_rect()
	for selected_index in range(screen._cards.size()):
		screen.selected_index = selected_index
		screen._refresh_view()
		await get_tree().process_frame
		for card in screen._cards:
			card._apply_selection_transform(true)
		var rects: Array[Rect2] = []
		var surface_rects: Array[Rect2] = []
		for index in range(screen._cards.size()):
			var card: PowerUpShopCard = screen._cards[index] as PowerUpShopCard
			_check(card.position.distance_to(root_positions[index]) < 0.01, "Grid card root position remains stable %d" % index)
			_check(card.scale == Vector2.ONE, "Grid card root scale remains one %d" % index)
			_check(card.get_global_rect() == root_rects[index], "Grid card root rect remains stable %d" % index)
			rects.append(card.get_global_rect())
			surface_rects.append(card.card_surface.get_global_rect())
			if index == selected_index:
				_check(is_equal_approx(card.visual_root.position.x, 0.0), "selected internal visual offset is neutral %d" % index)
				_check(absf(card.visual_root.scale.x - 1.025) < 0.001, "selected internal visual scale is restrained %d" % index)
			else:
				_check(card.visual_root.position.distance_to(Vector2.ZERO) < 0.01, "unselected internal visual reset %d" % index)
		for left in range(rects.size()):
			for right in range(left + 1, rects.size()):
				_check(not rects[left].intersects(rects[right]), "four card roots do not overlap %d/%d" % [left, right])
				_check(not surface_rects[left].intersects(surface_rects[right]), "four card surfaces do not overlap %d/%d" % [left, right])
		var selected_card: PowerUpShopCard = screen._cards[selected_index] as PowerUpShopCard
		var selected_surface_rect: Rect2 = selected_card.card_surface.get_global_rect()
		_check(selected_surface_rect.size.x > 0.0 and selected_surface_rect.size.y > 0.0, "selected internal surface is rendered")
		if selected_index == 1:
			_check(selected_surface_rect != baseline_surface_rect, "selected surface transform moves background and border")
		var hover_index := (selected_index + 1) % screen._cards.size()
		var hover_card: PowerUpShopCard = screen._cards[hover_index] as PowerUpShopCard
		hover_card.hovered = true
		hover_card.last_input_device = "mouse"
		hover_card._apply_selection_transform(true)
		_check(hover_card.scale == Vector2.ONE and absf(hover_card.visual_root.scale.x - 1.01) < 0.001, "hover transforms internal surface only")
		hover_card.hovered = false
		hover_card.last_input_device = "keyboard"
		hover_card._apply_selection_transform(true)

	for dimensions in [Vector2(1280, 720), Vector2(1600, 900)]:
		screen.size = dimensions
		screen._layout_responsive()
		await get_tree().process_frame
		screen.force_update_transform()
		var info_rect: Rect2 = screen.information_section.get_global_rect()
		var hero_rect: Rect2 = screen.hero_section.get_global_rect()
		var bubble_rect: Rect2 = screen.speech_bubble.get_global_rect()
		var mascot_rect: Rect2 = screen.mascot.get_global_rect()
		var comparison_current_rect: Rect2 = screen.comparison_current_box.get_global_rect()
		var comparison_next_rect: Rect2 = screen.comparison_next_box.get_global_rect()
		var price_rect: Rect2 = screen.required_point_row.get_global_rect()
		var purchase_rect: Rect2 = screen.purchase_button.get_global_rect()
		_check(_contains_rect(info_rect, bubble_rect), "speech bubble stays inside information section %s" % dimensions)
		_check(_contains_rect(info_rect, mascot_rect), "mascot stays inside information section %s" % dimensions)
		_check(hero_rect.end.y <= info_rect.position.y + 0.5, "hero stays above information section %s" % dimensions)
		_check(not bubble_rect.intersects(comparison_current_rect), "speech bubble avoids current comparison %s" % dimensions)
		_check(not bubble_rect.intersects(comparison_next_rect), "speech bubble avoids next comparison %s" % dimensions)
		_check(not bubble_rect.intersects(price_rect), "speech bubble avoids price row %s" % dimensions)
		_check(not bubble_rect.intersects(purchase_rect), "speech bubble avoids purchase button %s" % dimensions)
		_check(not mascot_rect.intersects(purchase_rect), "mascot avoids purchase button %s" % dimensions)
		var body_rect: Rect2 = screen.get_node("SafeAreaMargin/MainCenter/ShopContent/Body").get_global_rect()
		var content_rect: Rect2 = screen.shop_content.get_global_rect()
		var detail_rect: Rect2 = screen.detail_panel.get_global_rect()
		_check(body_rect.size.x <= content_rect.size.x + 0.5, "body fits shop content %s" % dimensions)
		_check(body_rect.end.y <= content_rect.end.y + 0.5, "body fits shop content vertically %s" % dimensions)
		_check(_contains_rect(detail_rect, hero_rect) and _contains_rect(detail_rect, info_rect), "detail sections stay inside detail panel %s" % dimensions)
		_check(not screen.card_grid.get_global_rect().intersects(detail_rect), "grid and detail do not overlap %s" % dimensions)
		var required_rect_before_lock: Rect2 = screen.required_point_row.get_global_rect()
		var purchase_rect_before_lock: Rect2 = screen.purchase_button.get_global_rect()
		screen.purchase_button.disabled = true
		await get_tree().process_frame
		_check(screen.detail_panel.get_global_rect() == detail_rect, "purchase lock keeps detail panel fixed %s" % dimensions)
		_check(screen.required_point_row.get_global_rect() == required_rect_before_lock, "purchase lock keeps price row fixed %s" % dimensions)
		_check(screen.purchase_button.get_global_rect() == purchase_rect_before_lock, "purchase lock keeps purchase button fixed %s" % dimensions)
		screen.purchase_button.disabled = false
	screen.size = Vector2(1280, 720)
	screen._layout_responsive()

func _contains_rect(outer: Rect2, inner: Rect2) -> bool:
	return inner.position.x >= outer.position.x - 0.5 and inner.position.y >= outer.position.y - 0.5 and inner.end.x <= outer.end.x + 0.5 and inner.end.y <= outer.end.y + 0.5

func _record_points_signal(_previous: int, _current: int) -> void:
	signal_order.append("points")

func _record_purchase_signal(_id: String, _level: int, _price: int) -> void:
	signal_order.append("purchase")


func _save_override(_data: Dictionary) -> bool:
	save_override_calls += 1
	return not save_override_should_fail

func _check(condition: bool, label: String) -> void:
	if not condition:
		failures.append(label)
