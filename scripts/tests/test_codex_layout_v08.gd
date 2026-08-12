extends Node

const CodexScreenScene := preload("res://scenes/ui/codex_screen.tscn")

var failures: Array[String] = []

func _ready() -> void:
	CodexManager.initialize_empty()
	var screen = CodexScreenScene.instantiate()
	add_child(screen)
	screen.size = Vector2(1600, 900)
	screen.open_screen("title")
	await get_tree().process_frame
	await get_tree().process_frame
	_check(absf(screen._list_panel.size.x - 360.0) <= 2.0, "normal layout keeps 360px list")
	_check(absf(screen._detail_panel.position.x - (screen._list_panel.position.x + screen._list_panel.size.x + 14.0)) <= 2.0, "normal layout keeps 14px body gap")
	_check(screen._body.global_position.y >= 220.0 and screen._body.global_position.y <= 224.0, "normal body starts near y=222")
	_check(screen._footer_panel.global_position.y >= 818.0 and screen._footer_panel.global_position.y <= 824.0, "normal footer starts near y=820")
	_check(screen._detail_back_button.global_position.x >= 30.0 and screen._detail_back_button.global_position.y >= screen._footer_panel.global_position.y and screen._detail_back_button.global_position.y + screen._detail_back_button.size.y <= screen._footer_panel.global_position.y + screen._footer_panel.size.y, "back button is in bottom-left footer")
	_check(screen._header_panel.find_children("*", "Button", true, false).is_empty(), "header has no back button")
	_check(screen._detail_image_frame.get_parent() == screen._detail_shell, "visual area is fixed in detail shell")
	_check(screen._detail_scroll.is_ancestor_of(screen._detail_body), "only info body is inside detail scroll")
	_check(not screen._detail_scroll.is_ancestor_of(screen._detail_image_frame), "visual area is outside info scroll")
	_check(screen._detail_focus_ring != null and screen._detail_focus_ring.get_parent() == screen._detail_panel and screen._detail_focus_ring.mouse_filter == Control.MOUSE_FILTER_IGNORE, "detail focus ring overlays the full detail panel")
	_check(not screen._detail_focus_ring.visible, "detail focus ring is hidden in preview mode")
	var ring_style := screen._detail_focus_ring.get_theme_stylebox("panel") as StyleBoxFlat
	_check(ring_style != null and not ring_style.draw_center and is_zero_approx(ring_style.bg_color.a) and ring_style.shadow_size == 0 and is_zero_approx(ring_style.shadow_color.a), "detail focus ring is outline-only")
	_check(ring_style != null and ring_style.border_width_left >= 3 and ring_style.border_width_left <= 4 and ring_style.border_width_top >= 3 and ring_style.border_width_top <= 4 and ring_style.border_width_right >= 3 and ring_style.border_width_right <= 4 and ring_style.border_width_bottom >= 3 and ring_style.border_width_bottom <= 4, "detail focus ring uses a 3-4px border")
	_check(screen._debug_overlay.global_position.y >= screen._footer_panel.global_position.y - 4.0 and screen._debug_overlay.global_position.y <= screen._footer_panel.global_position.y + screen._footer_panel.size.y, "debug overlay stays near footer")
	_check(not screen._layout_root.is_ancestor_of(screen._debug_row), "debug overlay is outside layout root")
	_check(_tabs_are_even(screen), "five category tabs are even")
	_check(_category_tabs_are_compact(screen), "category tabs show only name and found total")
	CodexManager.debug_unlock_all()
	await get_tree().process_frame
	var tab_texts: Array[String] = []
	for tab in screen._category_buttons:
		tab_texts.append(String((tab as Button).text))
	CodexManager.debug_mark_all_new()
	await get_tree().process_frame
	for index in range(screen._category_buttons.size()):
		_check(String(screen._category_buttons[index].text) == tab_texts[index], "category tab text is stable when NEW changes")
	_check(screen._all_filter_button != null and screen._new_filter_button != null, "ALL and NEW segment buttons exist")
	_check(screen._all_filter_button.get_parent() == screen._new_filter_row and screen._new_filter_button.get_parent() == screen._new_filter_row, "ALL and NEW share the filter row")
	_check(String(screen._new_filter_button.text).begins_with("NEW"), "NEW segment shows the selected category count")
	_check(screen._all_filter_button.disabled == false, "ALL segment is always operable")
	var body_y_before: float = screen._body.position.y
	screen._select_category(3)
	await get_tree().process_frame
	_check(absf(screen._body.position.y - body_y_before) <= 1.0, "enemy filter row does not move body")
	_check(screen._detail_image_frame.size.y >= 220.0, "enemy visual area has readable height")
	screen.size = Vector2(1280, 720)
	await get_tree().process_frame
	await get_tree().process_frame
	_check(screen._list_panel.size.x >= 298.0 and screen._list_panel.size.x <= 302.0, "compact layout uses 300px list")
	_check(screen._footer_panel.position.y + screen._footer_panel.size.y <= 720.0, "compact footer fits in 720px")
	_check(screen._detail_back_button.global_position.y + screen._detail_back_button.size.y <= 720.0, "compact back button remains visible")
	_check(screen._debug_overlay.global_position.y >= screen._footer_panel.global_position.y - 4.0, "compact debug overlay stays near footer")
	screen._select_category(0)
	screen._select_entry_by_id("ban_chan")
	await get_tree().process_frame
	_check(screen._detail_focus_ring.visible, "detail focus ring appears at compact size")
	_check(screen._detail_focus_ring.get_global_rect().position.x >= 0.0 and screen._detail_focus_ring.get_global_rect().end.x <= 1280.0 and screen._detail_focus_ring.get_global_rect().position.y >= 0.0 and screen._detail_focus_ring.get_global_rect().end.y <= 720.0, "compact detail focus ring stays inside viewport")
	screen._exit_detail()
	CodexManager.initialize_empty()
	CodexManager.discover_character("ban_chan")
	CodexManager.discover_weapon("ban_hammer")
	screen.size = Vector2(1600, 900)
	screen.open_screen("title", {}, {"category": CodexManager.CATEGORY_CHARACTER})
	screen._select_entry_by_id("ban_chan")
	await get_tree().process_frame
	var character_rect := screen._detail_image_holder.get_child(0) as TextureRect
	_check(character_rect != null and character_rect.texture is AtlasTexture, "character image uses content-bounds fit")
	_check(character_rect != null and character_rect.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "character image preserves aspect")
	_check(character_rect != null and screen._detail_image_holder.get_global_rect().encloses(character_rect.get_global_rect()), "character image stays inside visual holder")
	_check(screen._character_content_cache.size() == 1, "character bounds are cached by path")
	_check(screen._detail_focus_ring.visible, "detail focus ring appears for explicit detail")
	_check(screen._detail_focus_ring.get_global_rect().size.x >= screen._detail_panel.get_global_rect().size.x - 2.0 and screen._detail_focus_ring.get_global_rect().size.y >= screen._detail_panel.get_global_rect().size.y - 2.0, "detail focus ring covers the whole panel")
	screen._select_category(1)
	screen._select_entry_by_id("ban_hammer")
	await get_tree().process_frame
	var weapon_rect := screen._detail_image_holder.get_child(0) as TextureRect
	_check(weapon_rect != null and not weapon_rect.texture is AtlasTexture, "weapon image keeps common fit")
	if failures.is_empty():
		print("CODEX_LAYOUT_V08_TESTS: PASS")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("CODEX_LAYOUT_V08_TESTS: FAIL (%d)" % failures.size())
	get_tree().quit(1)

func _tabs_are_even(screen: Control) -> bool:
	if screen._category_buttons.size() != 5:
		return false
	var expected_width: float = screen._category_buttons[0].size.x
	for index in range(screen._category_buttons.size()):
		var tab: Control = screen._category_buttons[index]
		if absf(tab.size.x - expected_width) > 1.0:
			return false
		if index > 0:
			var previous: Control = screen._category_buttons[index - 1]
			if absf(tab.position.x - (previous.position.x + previous.size.x + 7.0)) > 1.0:
				return false
	return true

func _category_tabs_are_compact(screen: Control) -> bool:
	for index in range(screen._category_buttons.size()):
		var category: String = screen.CATEGORIES[index]
		var expected := "%s %d/%d" % [screen.CATEGORY_LABELS[index], CodexManager.get_discovered_count(category), CodexManager.get_total_count(category)]
		var text := String((screen._category_buttons[index] as Button).text)
		if text != expected or text.contains("NEW") or text.contains("COMPLETE"):
			return false
	return true

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
