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
	_check(screen._detail_info_content_host != null and screen._detail_info_content_host.get_parent() is MarginContainer and screen._detail_scroll.is_ancestor_of(screen._detail_info_content_host), "detail info uses one scrollable content host")
	_check(screen._character_profile_content != null and screen._character_profile_content.get_parent() == screen._detail_info_content_host, "character profile content stays inside the shared host")
	_check(screen._character_overview_row != null and screen._detail_scroll.is_ancestor_of(screen._character_overview_row), "character overview row stays inside the shared detail scroll")
	_check(screen._character_overview_image_frame != null and screen._character_overview_image_frame.get_parent() == screen._character_overview_row, "character overview image frame is the left overview column")
	_check(screen._character_overview_image_holder != null and screen._character_overview_image_frame.is_ancestor_of(screen._character_overview_image_holder), "character overview image holder stays inside its dedicated frame")
	_check(not screen._detail_scroll.is_ancestor_of(screen._detail_image_frame), "visual area is outside info scroll")
	var detail_ring := screen._detail_panel.find_child("DetailFocusRing", true, false) as PanelContainer
	var detail_ring_style := detail_ring.get_theme_stylebox("panel") as StyleBoxFlat if detail_ring != null else null
	_check(detail_ring != null and detail_ring.mouse_filter == Control.MOUSE_FILTER_IGNORE and not detail_ring.visible, "detail focus ring exists but is hidden in LIST focus")
	_check(detail_ring_style != null and not detail_ring_style.draw_center and detail_ring_style.bg_color.a == 0.0 and detail_ring_style.shadow_size == 0 and detail_ring_style.shadow_color.a == 0.0, "detail focus ring is outline-only")
	_check(detail_ring_style != null and detail_ring_style.border_width_left >= 3 and detail_ring_style.border_width_left <= 4 and detail_ring_style.border_width_top >= 3 and detail_ring_style.border_width_top <= 4, "detail focus ring uses a three-to-four pixel outline")
	var header_icon := screen._header_panel.find_child("CodexHeaderIcon", true, false) as TextureRect
	_check(header_icon != null and header_icon.texture != null, "codex header icon is loaded")
	_check(header_icon != null and header_icon.get_parent() != null and header_icon.mouse_filter == Control.MOUSE_FILTER_IGNORE, "codex header icon is a non-interactive header element")
	var header_rect := screen._header_panel.get_global_rect()
	var category_rect := screen._category_row.get_global_rect()
	var body_rect := screen._body.get_global_rect()
	var icon_rect := header_icon.get_global_rect() if header_icon != null else Rect2()
	_check(header_icon != null and header_icon.expand_mode == TextureRect.EXPAND_IGNORE_SIZE and header_icon.anchor_left == 0.0 and header_icon.anchor_top == 0.0, "codex header icon ignores source size and uses top-left anchors")
	_check(header_icon != null and header_icon.size.x >= 76.0 and header_icon.size.x <= 82.0 and header_icon.size.y >= 50.0 and header_icon.size.y <= 56.0, "codex header icon stays near the intended 78x52 size")
	_check(header_icon != null and icon_rect.position.x >= header_rect.position.x - 4.0 and icon_rect.position.x <= header_rect.position.x + 120.0, "codex header icon stays near the header left")
	_check(header_icon != null and icon_rect.position.y >= header_rect.position.y - 4.0 and icon_rect.end.y <= header_rect.end.y + 4.0, "codex header icon has only a small vertical bleed")
	_check(header_icon != null and icon_rect.end.y < category_rect.position.y and icon_rect.end.y < body_rect.position.y, "codex header icon does not reach tabs or body")
	var transition_root := screen.get_node_or_null("TransitionVisualRoot") as Control
	var transition_veil := screen.get_node_or_null("TransitionVeil") as ColorRect
	_check(transition_root != null and transition_veil != null, "codex exposes a visual transition root and fixed veil")
	_check(transition_veil != null and transition_veil.get_parent() == screen, "codex transition veil stays fixed outside the moving visual root")
	var background := screen.get_node_or_null("TransitionVisualRoot/FullScreenBackground") as TextureRect
	_check(background != null and background.texture != null and String(background.texture.resource_path) == "res://assets/title/title_back.png", "codex keeps title background source")
	_check(screen._detail_panel.find_child("DetailFocusRing", true, false) != null, "detail panel retains the input-only detail focus overlay")
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
	_check(screen._item_profile_content.visible and not screen._detail_image_frame.visible, "discovered enemy uses the structured visual area")
	_check(screen._item_overview_row.size.y >= 220.0, "enemy Lore overview has readable height")
	_check(screen._item_visual_frame.size.y >= 220.0, "enemy visual panel has readable height")
	_check_new_badge_layout(screen, false)
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
	_check(screen._character_profile_content.visible and not screen._detail_body.visible, "compact discovered character uses profile cards")
	_check(screen._character_unit_badge.visible and screen._character_unit_badge_label.text == "初期メンバー", "compact character header shows the unit badge")
	_check(screen._character_summary_primary_row.get_child_count() == 1 and screen._character_summary_secondary_row.get_child_count() == 2, "compact profile uses one full-width style card and a two-card row")
	_check(not screen._detail_image_frame.visible and screen._character_overview_image_frame.visible, "compact formal character detail swaps in the overview image frame")
	_check(screen._character_overview_row.size.y >= 205.0 and screen._character_overview_row.size.y <= 225.0, "compact character overview row stays within the target height")
	_check(screen._character_overview_row.size.x > 0.0 and screen._character_overview_image_frame.size.x < screen._character_overview_row.size.x, "compact character overview keeps two columns")
	var compact_profile_body := screen._character_profile_card.get_meta("character_card_body", null) as Label
	_check(compact_profile_body != null and compact_profile_body.get_theme_font_size("font_size") >= 17, "compact profile keeps a readable minimum font size")
	_check(screen._detail_scroll.is_ancestor_of(screen._character_profile_card) and screen._detail_scroll.is_ancestor_of(screen._character_play_record_card), "compact profile cards remain scrollable")
	_check_new_badge_layout(screen, true)
	_check(screen._detail_panel.get_global_rect().position.x >= 0.0 and screen._detail_panel.get_global_rect().end.x <= 1280.0 and screen._detail_panel.get_global_rect().position.y >= 0.0 and screen._detail_panel.get_global_rect().end.y <= 720.0, "compact detail panel stays inside viewport")
	CodexManager.initialize_empty()
	CodexManager.discover_character("ban_chan")
	CodexManager.discover_weapon("ban_hammer")
	screen.size = Vector2(1600, 900)
	screen.open_screen("title", {}, {"category": CodexManager.CATEGORY_CHARACTER})
	screen._select_entry_by_id("ban_chan")
	await get_tree().process_frame
	_check(screen._character_profile_content.visible and not screen._detail_body.visible, "normal discovered character uses profile cards")
	_check(screen._character_unit_badge.visible and screen._character_unit_badge_label.text == "初期メンバー", "normal character header shows the unit badge")
	_check(not screen._detail_image_frame.visible and screen._character_overview_image_frame.visible, "normal formal character detail hides the fixed visual area")
	_check(screen._character_overview_row.size.y >= 225.0 and screen._character_overview_row.size.y <= 250.0, "normal character overview row stays within the target height")
	_check(screen._character_summary_primary_row.get_child_count() == 1 and screen._character_summary_secondary_row.get_child_count() == 2, "normal profile uses a style row and likes/dislikes row")
	var overview_width := screen._character_overview_row.size.x
	var image_ratio := screen._character_overview_image_frame.size.x / overview_width if overview_width > 0.0 else 0.0
	var summary_ratio := screen._character_summary_area.size.x / overview_width if overview_width > 0.0 else 0.0
	_check(overview_width > 0.0 and image_ratio >= 0.38 and image_ratio <= 0.42, "normal character overview keeps the 40/60 column ratio")
	_check(overview_width > 0.0 and summary_ratio >= 0.58 and summary_ratio <= 0.62, "normal character summary column stays near 60 percent")
	_check(screen._character_overview_row.get_theme_constant("separation") >= 12 and screen._character_overview_row.get_theme_constant("separation") <= 16, "normal character overview keeps the requested column gap")
	var summary_cards: Array = [screen._character_stream_card, screen._character_likes_card, screen._character_dislikes_card]
	for card_value in summary_cards:
		var summary_card := card_value as Control
		_check(summary_card != null and summary_card.size_flags_horizontal == Control.SIZE_EXPAND_FILL, "normal summary card expands horizontally")
	_check(screen._character_stream_card.get_parent() == screen._character_summary_primary_row, "stream style card occupies the top summary row")
	_check(screen._character_likes_card.get_parent() == screen._character_summary_secondary_row and screen._character_dislikes_card.get_parent() == screen._character_summary_secondary_row, "likes and dislikes cards occupy the lower summary row")
	var lower_summary_bottom := screen._character_likes_card.global_position.y + screen._character_likes_card.size.y
	_check(absf((screen._character_dislikes_card.global_position.y + screen._character_dislikes_card.size.y) - lower_summary_bottom) <= 2.0, "likes and dislikes cards share a bottom edge")
	var profile_body := screen._character_profile_card.get_meta("character_card_body", null) as Label
	var profile_margin := screen._character_profile_card.get_meta("character_card_margin", null) as MarginContainer
	_check(profile_body != null and profile_body.text.contains("\n\n") and profile_body.get_theme_constant("line_spacing") >= 5 and profile_body.get_theme_font_size("font_size") >= 18, "profile card preserves paragraphs, readable font, and line spacing")
	_check(profile_margin != null and profile_margin.get_theme_constant("margin_left") >= 24, "profile card uses wider horizontal padding")
	_check(screen._detail_scroll.max_value > 0.0, "long character profile remains scrollable")
	var character_rect := screen._character_overview_image_holder.get_child(0) as TextureRect
	_check(character_rect != null and character_rect.texture is AtlasTexture, "character image uses content-bounds fit")
	_check(character_rect != null and character_rect.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "character image preserves aspect")
	_check(character_rect != null and screen._character_overview_image_holder.get_global_rect().encloses(character_rect.get_global_rect()), "character image stays inside overview holder")
	_check(screen._character_content_cache.size() == 1, "character bounds are cached by path")
	_check(screen._detail_panel.get_global_rect().size.x > 0.0 and screen._detail_panel.get_global_rect().size.y > 0.0, "detail panel remains available without a separate detail focus state")
	screen._select_entry_by_id("aosumi_kyasumi")
	_check(not screen._character_profile_content.visible and not screen._character_unit_badge.visible and screen._detail_body.visible and screen._detail_image_frame.visible and not screen._character_overview_image_frame.visible, "undiscovered character falls back to the generic detail body and visual area")
	screen._select_entry_by_id("ban_chan")
	var character_units := {
		"ban_chan": "初期メンバー",
		"superchat_chan": "初期メンバー",
		"maro_chan": "初期メンバー",
		"aosumi_kyasumi": "先輩メンバー",
		"akarine_rizumu": "先輩メンバー",
		"shizuki_miimu": "先輩メンバー"
	}
	for character_id_value in character_units.keys():
		var character_id := String(character_id_value)
		CodexManager.discover_character(character_id)
		screen._select_entry_by_id(character_id)
		_check(screen._character_profile_content.visible and screen._character_unit_badge.visible and screen._character_unit_badge_label.text == String(character_units[character_id]), "all six characters render their unit badge and profile cards: %s" % character_id)
		_check(screen._character_stream_card.visible and screen._character_likes_card.visible and screen._character_dislikes_card.visible and screen._character_profile_card.visible, "all six characters render the structured cards: %s" % character_id)
		_check(not screen._detail_image_frame.visible and screen._character_overview_image_frame.visible and screen._character_overview_image_holder.get_child_count() == 1, "all six characters use one dedicated overview image: %s" % character_id)
		var overview_texture_rect := screen._character_overview_image_holder.get_child(0) as TextureRect
		_check(overview_texture_rect != null and overview_texture_rect.texture is AtlasTexture and screen._character_overview_image_holder.get_global_rect().encloses(overview_texture_rect.get_global_rect()), "all six character images stay cropped inside the overview frame: %s" % character_id)
		var current_profile_body := screen._character_profile_card.get_meta("character_card_body", null) as Label
		if character_id in ["aosumi_kyasumi", "akarine_rizumu", "shizuki_miimu"]:
			_check(current_profile_body != null and not current_profile_body.text.contains("ほぼ同じ時期にデビューした"), "senior profile does not include the rookie unit description: %s" % character_id)
	screen._select_category(1)
	screen._select_entry_by_id("ban_hammer")
	await get_tree().process_frame
	_check(not screen._character_profile_content.visible and not screen._character_unit_badge.visible and screen._detail_body.visible and screen._detail_image_frame.visible and not screen._character_overview_image_frame.visible, "switching to weapon clears character-only content")
	var weapon_rect := screen._detail_image_holder.get_child(0) as TextureRect
	_check(weapon_rect != null and not weapon_rect.texture is AtlasTexture, "weapon image keeps common fit")
	var focus_ring := screen._detail_focus_ring
	_check(not focus_ring.visible and int(screen._input_focus) == 0, "complete detail remains in LIST focus until explicitly entered")
	if screen._detail_is_scrollable():
		screen._enter_detail_focus()
		_check(focus_ring.visible and screen._detail_back_button.text == "一覧へ戻る", "scrollable detail enters DETAIL focus with its outline")
		_check(screen.find_child("DetailNavigation", true, false) == null, "DETAIL focus has no previous/next navigation row")
		_check(String(screen._footer_label.text) == "↑↓ スクロール　PgUp/PgDn ページ　右スティック スクロール　Esc 一覧へ", "DETAIL footer uses the scroll-only guidance")
		screen._cancel_current_layer()
		_check(not focus_ring.visible and int(screen._input_focus) == 0 and screen._detail_back_button.text == "戻る", "DETAIL cancel returns to LIST without hiding the screen")
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

func _check_new_badge_layout(screen: Control, compact: bool) -> void:
	var expected_height := 36.0 if compact else 40.0
	var aligned_right := -1.0
	var badge_count := 0
	for child in screen._list_box.get_children():
		var button := child as Button
		if button == null:
			continue
		_check(absf(button.size.y - expected_height) <= 1.0, "codex list row keeps its standard height")
		var badge := button.find_child("NewBadge", true, false) as PanelContainer
		if badge == null:
			continue
		badge_count += 1
		var badge_rect := badge.get_global_rect()
		var name_label := button.find_child("ItemNameLabel", true, false) as Label
		var name_rect := name_label.get_global_rect() if name_label != null else Rect2()
		var button_rect := button.get_global_rect()
		_check(badge_rect.size.y >= 20.0 and badge_rect.size.y <= 24.0, "NEW badge keeps compact height")
		_check(button_rect.encloses(badge_rect), "NEW badge stays inside its list row")
		_check(name_label != null and name_rect.end.x <= badge_rect.position.x - 7.0, "item name reserves a gap before NEW badge")
		if aligned_right < 0.0:
			aligned_right = badge_rect.end.x
		else:
			_check(absf(badge_rect.end.x - aligned_right) <= 1.0, "NEW badges align to a common right edge")
	_check(badge_count > 0, "visible NEW rows contain dedicated badges")

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
