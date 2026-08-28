extends Control

## Codex overlay.  Rendering and input live here; discovery state remains in
## CodexManager and read-only display rules live in CodexPresentationSystem.

const CodexPresentationSystemScript := preload("res://scripts/systems/codex_presentation_system.gd")
const CommonLightUiStyleScript := preload("res://scripts/ui/common_light_ui_style.gd")
const FRONT_SCREEN_BACKGROUND_PATH := "res://assets/title/title_back.png"
const CODEX_HEADER_ICON_PATH := "res://assets/generated/codex_icons_v1/codex_header_icon.png"
const CODEX_HEADER_ICON_PADDING_RATIO := 0.02
const COMMENT_CONTENT_PADDING_RATIO := 0.06
const NORMAL_LAYOUT_MIN_WIDTH := 1400.0
const CHARACTER_CONTENT_PADDING_RATIO := 0.04
const FRONT_SCREEN_TRANSITION_OVERLAY_COLOR := Color(0.965, 0.95, 1.0, 1.0)

signal closed(origin: String)
signal debug_save_requested
signal completion_notice_requested(text: String)
signal cursor_moved
signal confirm_requested
signal cancel_requested
signal read_state_save_requested(category: String, item_id: String)

enum FocusArea {
	LIST,
	BACK
}

enum InputFocus {
	LIST,
	DETAIL
}

const CATEGORIES: Array[String] = [
	CodexManager.CATEGORY_CHARACTER,
	CodexManager.CATEGORY_WEAPON,
	CodexManager.CATEGORY_ACCESSORY,
	CodexManager.CATEGORY_ENEMY,
	CodexManager.CATEGORY_COMMENT
]
const CATEGORY_LABELS: Array[String] = ["キャラクター", "武器", "アクセサリー", "敵", "指示コメ"]

var _origin := "title"
var _difficulty_progress: Dictionary = {}
var _category_index := 0
var _selected_ids: Dictionary = {}
var _enemy_filter_id := "ALL"
var _new_only := false
var _category_buttons: Array[Button] = []
var _enemy_filter_buttons: Array[Button] = []
var _enemy_filter_row: HBoxContainer
var _new_filter_row: HBoxContainer
var _all_filter_button: Button
var _new_filter_button: Button
var _list_box: VBoxContainer
var _list_scroll: ScrollContainer
var _detail_scroll: ScrollContainer
var _progress_label: Label
var _collection_label: Label
var _comment_log_label: Label
var _collection_bar: ProgressBar
var _detail_title: Label
var _detail_header_row: HBoxContainer
var _detail_badge_row: HBoxContainer
var _character_unit_badge: PanelContainer
var _character_unit_badge_label: Label
var _detail_extra_badges: Array[PanelContainer] = []
var _detail_body: Label
var _detail_image_frame: PanelContainer
var _detail_image_holder: Control
var _detail_back_button: Button
var _detail_focus_ring: PanelContainer
var _footer_label: Label
var _debug_row: HBoxContainer
var _debug_status_label: Label
var _debug_reset_armed := false
var _completion_banner: Label
var _completion_queue: Array[String] = []
var _completion_timer := 0.0
var _enemy_sources: Dictionary = {}
var _open_options: Dictionary = {}
var _new_snapshot_ids: Dictionary = {}
var _local_mark_read_in_progress := false
var _analog_x_latched := false
var _analog_y_latched := false
var _right_stick_y_value := 0.0
var _last_input_device := "KEYBOARD_GAMEPAD"
var _built := false
var _layout_margin: MarginContainer
var _layout_root: VBoxContainer
var _header_panel: PanelContainer
var _category_row: HBoxContainer
var _stats_panel: PanelContainer
var _filter_band: PanelContainer
var _body: HBoxContainer
var _list_panel: PanelContainer
var _detail_panel: PanelContainer
var _detail_header_panel: PanelContainer
var _detail_shell: VBoxContainer
var _detail_info_panel: PanelContainer
var _footer_panel: PanelContainer
var _debug_overlay: PanelContainer
var _transition_visual_root: Control
var _transition_veil: ColorRect
var _common_front_transition_locked := false
var _common_front_transition_base_position := Vector2.ZERO
var _layout_spacers: Array[Control] = []
var _compact_layout := false
var _last_layout_size := Vector2(-1.0, -1.0)
var _character_content_cache: Dictionary = {}
var _comment_content_cache: Dictionary = {}
var _detail_info_content_host: VBoxContainer
var _character_profile_content: VBoxContainer
var _character_overview_row: HBoxContainer
var _character_overview_image_frame: PanelContainer
var _character_overview_image_holder: Control
var _character_summary_area: VBoxContainer
var _character_summary_primary_row: HBoxContainer
var _character_summary_secondary_row: HBoxContainer
var _character_stream_card: PanelContainer
var _character_likes_card: PanelContainer
var _character_dislikes_card: PanelContainer
var _character_profile_card: PanelContainer
var _character_secondary_info: VBoxContainer
var _character_game_info_card: PanelContainer
var _character_play_record_card: PanelContainer
var _item_profile_content: VBoxContainer
var _item_overview_row: HBoxContainer
var _item_visual_frame: PanelContainer
var _item_visual_holder: Control
var _item_summary_area: VBoxContainer
var _item_summary_primary_row: HBoxContainer
var _item_summary_secondary_row: HBoxContainer
var _item_comment_wide_column: VBoxContainer
var _item_comment_effect_card: PanelContainer
var _item_card_by_id: Dictionary = {}
var _item_archive_card: PanelContainer
var _item_game_data_card: PanelContainer
var _focus_area := FocusArea.LIST
var _input_focus := InputFocus.LIST

func _ready() -> void:
	_build_ui()
	if not CodexManager.codex_changed.is_connected(_on_codex_changed):
		CodexManager.codex_changed.connect(_on_codex_changed)
	if not CodexManager.codex_bulk_changed.is_connected(_on_codex_bulk_changed):
		CodexManager.codex_bulk_changed.connect(_on_codex_bulk_changed)
	if not CodexManager.completion_achieved.is_connected(_on_completion_achieved):
		CodexManager.completion_achieved.connect(_on_completion_achieved)
	hide()
	set_process(true)

func _process(delta: float) -> void:
	if _completion_banner != null and _completion_timer > 0.0:
		_completion_timer = maxf(0.0, _completion_timer - delta)
		if _completion_timer <= 0.0:
			_completion_banner.visible = false
			_show_next_completion_notice()
	if not visible or _common_front_transition_locked or _input_focus != InputFocus.DETAIL:
		return
	if absf(_right_stick_y_value) <= 0.35 or not _detail_is_scrollable():
		return
	var normalized := clampf((absf(_right_stick_y_value) - 0.35) / 0.65, 0.0, 1.0)
	var speed := lerpf(180.0, 560.0, normalized)
	var direction := 1.0 if _right_stick_y_value > 0.0 else -1.0
	_set_detail_scroll_value(float(_detail_scroll.scroll_vertical) + direction * speed * delta)

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and _built:
		_apply_layout_metrics()

func open_screen(origin: String = "title", difficulty_progress: Dictionary = {}, options: Dictionary = {}) -> void:
	_reset_common_front_transition(true)
	_origin = origin
	_difficulty_progress = difficulty_progress.duplicate(true)
	_open_options = options.duplicate(true)
	_focus_area = FocusArea.LIST
	_input_focus = InputFocus.LIST
	_analog_x_latched = false
	_analog_y_latched = false
	_right_stick_y_value = 0.0
	_new_snapshot_ids.clear()
	_apply_open_options(options)
	if _new_only and not _rebuild_new_snapshot():
		_new_only = false
	show()
	var initial_entries := _visible_entries()
	var initial_selected := _selected_index(initial_entries)
	if initial_selected >= 0:
		_formal_select(initial_selected, false, false, true)
	_refresh(false, false, true)

func bind_difficulty_progress(difficulty_progress: Dictionary) -> void:
	_difficulty_progress = difficulty_progress.duplicate(true)
	if visible:
		_refresh()

func close_screen() -> void:
	if not visible:
		return
	var closing_origin := _origin
	_focus_area = FocusArea.LIST
	_input_focus = InputFocus.LIST
	_right_stick_y_value = 0.0
	_new_snapshot_ids.clear()
	finish_common_front_transition(false)
	closed.emit(closing_origin)

func hide_screen() -> void:
	_focus_area = FocusArea.LIST
	_input_focus = InputFocus.LIST
	_right_stick_y_value = 0.0
	finish_common_front_transition(false)
	hide()

func _reset_common_front_transition(keep_open: bool) -> void:
	if not _built or _transition_visual_root == null:
		return
	_apply_common_front_transition_offset(0.0)
	_transition_visual_root.visible = keep_open
	_set_transition_veil_alpha(0.0)
	if _transition_veil != null:
		_transition_veil.hide()
		_transition_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_common_front_transition_locked = false
	if keep_open:
		show()
	else:
		hide()

func _apply_common_front_transition_offset(offset_x: float) -> void:
	if _transition_visual_root == null:
		return
	_transition_visual_root.position = _common_front_transition_base_position + Vector2(offset_x, 0.0)

func _set_transition_veil_alpha(alpha: float) -> void:
	if _transition_veil == null:
		return
	var veil_color := FRONT_SCREEN_TRANSITION_OVERLAY_COLOR
	veil_color.a = clampf(alpha, 0.0, 1.0)
	_transition_veil.color = veil_color

func begin_common_front_transition(role: String) -> void:
	if not is_node_ready() or _transition_visual_root == null:
		return
	_common_front_transition_locked = true
	_apply_common_front_transition_offset(0.0)
	_set_transition_veil_alpha(0.0)
	_transition_veil.hide()
	_transition_veil.mouse_filter = Control.MOUSE_FILTER_STOP
	_transition_visual_root.visible = role != "incoming"
	if role == "incoming":
		hide()
	else:
		show()

func apply_common_front_transition(offset_x: float, overlay_alpha: float, should_show: bool) -> void:
	if not is_node_ready() or _transition_visual_root == null:
		return
	_apply_common_front_transition_offset(offset_x)
	_transition_visual_root.visible = should_show
	_set_transition_veil_alpha(overlay_alpha)
	_transition_veil.mouse_filter = Control.MOUSE_FILTER_STOP if _common_front_transition_locked else Control.MOUSE_FILTER_IGNORE
	_transition_veil.visible = should_show and overlay_alpha > 0.0
	if should_show and not visible:
		show()
	elif not should_show and visible:
		hide()

func finish_common_front_transition(keep_open: bool) -> void:
	if not is_node_ready() or _transition_visual_root == null:
		return
	_apply_common_front_transition_offset(0.0)
	_transition_visual_root.visible = keep_open
	_set_transition_veil_alpha(0.0)
	_transition_veil.hide()
	_transition_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_common_front_transition_locked = false
	if keep_open:
		show()
	else:
		hide()

func _get_enemy_sources() -> Dictionary:
	if _enemy_sources.is_empty():
		_enemy_sources = CodexPresentationSystemScript.load_sources()
	return _enemy_sources

func _legacy_handle_input(event: InputEvent) -> bool:
	return handle_input(event)

func handle_input(event: InputEvent) -> bool:
	if _common_front_transition_locked:
		get_viewport().set_input_as_handled()
		return true
	if not visible:
		return false
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if not mouse.pressed:
			return false
		_last_input_device = "MOUSE"
		if mouse.button_index == MOUSE_BUTTON_LEFT:
			var detail_rect := _detail_panel.get_global_rect() if _detail_panel != null else Rect2()
			var scrollbar_rect := _detail_scroll.get_v_scroll_bar().get_global_rect() if _detail_scroll != null and _detail_scroll.get_v_scroll_bar() != null else Rect2()
			if detail_rect.has_point(mouse.position) and not scrollbar_rect.has_point(mouse.position):
				if _input_focus != InputFocus.DETAIL and _detail_is_scrollable():
					_enter_detail_focus()
				return true
		var scroll_delta := 0
		if mouse.button_index == MOUSE_BUTTON_WHEEL_UP:
			scroll_delta = -120
		elif mouse.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			scroll_delta = 120
		if scroll_delta != 0:
			var detail_hovered := _detail_scroll != null and _detail_scroll.get_global_rect().has_point(mouse.position)
			var list_hovered := _list_scroll != null and _list_scroll.get_global_rect().has_point(mouse.position)
			if detail_hovered:
				_detail_scroll.scroll_vertical = maxi(0, _detail_scroll.scroll_vertical + scroll_delta)
			elif list_hovered:
				_list_scroll.scroll_vertical = maxi(0, _list_scroll.scroll_vertical + scroll_delta)
			return detail_hovered or list_hovered
		return false
	if event is InputEventJoypadMotion:
		return _handle_analog_motion(event as InputEventJoypadMotion)
	var direction := 0
	var category_direction := 0
	var page_direction := 0
	var select := false
	var back := false
	var toggle_new := false
	if event is InputEventKey:
		var key := event as InputEventKey
		if not key.pressed or key.echo:
			return false
		_last_input_device = "KEYBOARD_GAMEPAD"
		back = key.keycode == KEY_ESCAPE or key.keycode == KEY_BACKSPACE
		category_direction = -1 if key.keycode == KEY_LEFT else (1 if key.keycode == KEY_RIGHT else 0)
		direction = -1 if key.keycode == KEY_UP else (1 if key.keycode == KEY_DOWN else 0)
		page_direction = -1 if key.keycode == KEY_PAGEUP else (1 if key.keycode == KEY_PAGEDOWN else 0)
		toggle_new = key.keycode == KEY_N
		select = key.keycode == KEY_ENTER or key.keycode == KEY_SPACE or key.is_action_pressed("ui_accept")
	elif event is InputEventJoypadButton:
		var pad := event as InputEventJoypadButton
		if not pad.pressed:
			return false
		_last_input_device = "KEYBOARD_GAMEPAD"
		back = pad.button_index == JOY_BUTTON_B
		select = pad.button_index == JOY_BUTTON_A
		category_direction = -1 if pad.button_index in [JOY_BUTTON_LEFT_SHOULDER, JOY_BUTTON_DPAD_LEFT] else (1 if pad.button_index in [JOY_BUTTON_RIGHT_SHOULDER, JOY_BUTTON_DPAD_RIGHT] else 0)
		direction = -1 if pad.button_index == JOY_BUTTON_DPAD_UP else (1 if pad.button_index == JOY_BUTTON_DPAD_DOWN else 0)
		toggle_new = pad.button_index == JOY_BUTTON_Y
	else:
		return false
	if back:
		_cancel_current_layer()
		return true
	if _input_focus == InputFocus.DETAIL:
		if toggle_new:
			return true
		if page_direction != 0:
			_scroll_detail_page(page_direction)
			return true
		if category_direction != 0:
			# Horizontal input is reserved for future detail sub-tabs.  Consume it
			# here so it cannot fall through to category or item navigation.
			return true
		if direction != 0:
			_scroll_detail_small(direction)
			return true
		if select:
			return true
		return false
	if toggle_new:
		_toggle_new_filter()
		return true
	if page_direction != 0:
		return true
	if _focus_area == FocusArea.BACK:
		if direction != 0:
			_move_from_back(direction)
		elif select:
			_cancel_current_layer()
		return true
	if category_direction != 0:
		_move_category(category_direction)
		return true
	if direction != 0:
		_move_selection(direction)
		return true
	if select:
		_enter_detail_focus()
		return true
	return false

func _handle_analog_motion(event: InputEventJoypadMotion) -> bool:
	var value := float(event.axis_value)
	var deadzone := 0.35
	if event.axis in [JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y, JOY_AXIS_RIGHT_Y] and absf(value) >= deadzone:
		_last_input_device = "KEYBOARD_GAMEPAD"
	if event.axis == JOY_AXIS_LEFT_X:
		if absf(value) < deadzone:
			_analog_x_latched = false
			return false
		if _analog_x_latched:
			return true
		_analog_x_latched = true
		if _input_focus == InputFocus.DETAIL:
			return true
		if _focus_area == FocusArea.BACK:
			return true
		else:
			_move_category(-1 if value < 0.0 else 1)
		return true
	if event.axis == JOY_AXIS_LEFT_Y:
		if absf(value) < deadzone:
			_analog_y_latched = false
			return false
		if _analog_y_latched:
			return true
		_analog_y_latched = true
		if _input_focus == InputFocus.DETAIL:
			_scroll_detail_small(-1 if value < 0.0 else 1)
			return true
		if _focus_area == FocusArea.BACK:
			_move_from_back(-1 if value < 0.0 else 1)
		else:
			_move_selection(-1 if value < 0.0 else 1)
		return true
	if event.axis == JOY_AXIS_RIGHT_Y:
		if absf(value) < deadzone:
			_right_stick_y_value = 0.0
			return false
		_right_stick_y_value = value
		return true
	return false

func _build_ui() -> void:
	if _built:
		return
	_built = true
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_transition_visual_root = Control.new()
	_transition_visual_root.name = "TransitionVisualRoot"
	_transition_visual_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_transition_visual_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_transition_visual_root.z_index = 0
	add_child(_transition_visual_root)
	_common_front_transition_base_position = _transition_visual_root.position

	var background := TextureRect.new()
	background.name = "FullScreenBackground"
	background.texture = load(FRONT_SCREEN_BACKGROUND_PATH) as Texture2D
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.z_index = -20
	_transition_visual_root.add_child(background)
	var wash := ColorRect.new()
	wash.name = "LightBackgroundWash"
	wash.color = Color(0.98, 0.96, 1.0, 0.80)
	wash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wash.z_index = -19
	_transition_visual_root.add_child(wash)
	var cool_wash := ColorRect.new()
	cool_wash.name = "CoolBackgroundWash"
	cool_wash.color = Color(0.82, 0.94, 1.0, 0.10)
	cool_wash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cool_wash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cool_wash.z_index = -18
	_transition_visual_root.add_child(cool_wash)

	_layout_margin = MarginContainer.new()
	_layout_margin.name = "SafeAreaMargin"
	_layout_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_transition_visual_root.add_child(_layout_margin)
	_transition_veil = ColorRect.new()
	_transition_veil.name = "TransitionVeil"
	_transition_veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_transition_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_transition_veil.z_index = 100
	_transition_veil.color = Color(FRONT_SCREEN_TRANSITION_OVERLAY_COLOR, 0.0)
	_transition_veil.visible = false
	add_child(_transition_veil)
	_layout_root = VBoxContainer.new()
	_layout_root.name = "CodexLayout"
	_layout_root.add_theme_constant_override("separation", 0)
	_layout_margin.add_child(_layout_root)

	_header_panel = PanelContainer.new()
	_header_panel.name = "HeaderPanel"
	_header_panel.add_theme_stylebox_override("panel", _panel_style(Color(CommonLightUiStyleScript.MAIN_PANEL, 0.92), CommonLightUiStyleScript.MAIN_PANEL_BORDER))
	_layout_root.add_child(_header_panel)
	var header_margin := MarginContainer.new()
	header_margin.add_theme_constant_override("margin_left", 18)
	header_margin.add_theme_constant_override("margin_right", 18)
	header_margin.add_theme_constant_override("margin_top", 0)
	header_margin.add_theme_constant_override("margin_bottom", 0)
	_header_panel.add_child(header_margin)
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	header_margin.add_child(header)
	var header_icon_slot := Control.new()
	header_icon_slot.name = "CodexHeaderIconSlot"
	header_icon_slot.custom_minimum_size = Vector2(74, 46)
	header_icon_slot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	header_icon_slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header_icon_slot.clip_contents = false
	header_icon_slot.z_index = 2
	header.add_child(header_icon_slot)
	var header_icon := TextureRect.new()
	header_icon.name = "CodexHeaderIcon"
	header_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	header_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	header_icon.set_anchors_preset(Control.PRESET_TOP_LEFT)
	header_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header_icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	header_icon.z_index = 2
	header_icon.texture = _load_codex_header_icon()
	header_icon.position = Vector2(-2, -3)
	header_icon.size = Vector2(78, 52)
	header_icon_slot.add_child(header_icon)
	var heading := Label.new()
	heading.text = "配信図鑑"
	CommonLightUiStyleScript.apply_font(heading, 32, true, CommonLightUiStyleScript.TEXT_PRIMARY)
	heading.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	header.add_child(heading)
	var header_spacer := Control.new()
	header_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(header_spacer)
	_progress_label = Label.new()
	CommonLightUiStyleScript.apply_font(_progress_label, 18, true, CommonLightUiStyleScript.SUPPORT_DARK)
	_progress_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	header.add_child(_progress_label)
	_add_layout_spacer(6)

	_category_row = HBoxContainer.new()
	_category_row.name = "CategoryTabs"
	_category_row.add_theme_constant_override("separation", 7)
	_layout_root.add_child(_category_row)
	for index in range(CATEGORIES.size()):
		var button := Button.new()
		button.custom_minimum_size = Vector2(0, 42)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.focus_mode = Control.FOCUS_NONE
		CommonLightUiStyleScript.apply_font(button, 16, true, CommonLightUiStyleScript.TEXT_PRIMARY)
		var category_index := index
		button.pressed.connect(func() -> void: _select_category(category_index))
		_category_buttons.append(button)
		_category_row.add_child(button)
	_add_layout_spacer(6)

	_stats_panel = PanelContainer.new()
	_stats_panel.name = "CollectionStats"
	_stats_panel.add_theme_stylebox_override("panel", _panel_style(Color(CommonLightUiStyleScript.MAIN_PANEL, 0.93), CommonLightUiStyleScript.DIVIDER))
	_layout_root.add_child(_stats_panel)
	var stats_margin := MarginContainer.new()
	stats_margin.add_theme_constant_override("margin_left", 16)
	stats_margin.add_theme_constant_override("margin_right", 16)
	stats_margin.add_theme_constant_override("margin_top", 6)
	stats_margin.add_theme_constant_override("margin_bottom", 6)
	_stats_panel.add_child(stats_margin)
	var collection_row := HBoxContainer.new()
	collection_row.add_theme_constant_override("separation", 12)
	collection_row.alignment = BoxContainer.ALIGNMENT_CENTER
	stats_margin.add_child(collection_row)
	_collection_label = Label.new()
	_collection_label.custom_minimum_size = Vector2(330, 0)
	CommonLightUiStyleScript.apply_font(_collection_label, 15, true, CommonLightUiStyleScript.TEXT_PRIMARY)
	_collection_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	collection_row.add_child(_collection_label)
	_collection_bar = ProgressBar.new()
	_collection_bar.custom_minimum_size = Vector2(290, 14)
	_collection_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_collection_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_collection_bar.show_percentage = false
	_collection_bar.max_value = 100.0
	_collection_bar.add_theme_stylebox_override("background", _panel_style(CommonLightUiStyleScript.LILAC, CommonLightUiStyleScript.LILAC_BORDER))
	_collection_bar.add_theme_stylebox_override("fill", _panel_style(CommonLightUiStyleScript.SUPPORT_LIGHT, CommonLightUiStyleScript.SUPPORT_MAIN))
	collection_row.add_child(_collection_bar)
	_comment_log_label = Label.new()
	_comment_log_label.custom_minimum_size = Vector2(360, 0)
	CommonLightUiStyleScript.apply_font(_comment_log_label, 14, false, CommonLightUiStyleScript.TEXT_SECONDARY)
	_comment_log_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	collection_row.add_child(_comment_log_label)

	_filter_band = PanelContainer.new()
	_filter_band.name = "FilterBand"
	_filter_band.add_theme_stylebox_override("panel", _panel_style(Color(CommonLightUiStyleScript.SUPPORT_PALE, 0.82), CommonLightUiStyleScript.SUPPORT_LIGHT))
	_layout_root.add_child(_filter_band)
	var filter_margin := MarginContainer.new()
	filter_margin.add_theme_constant_override("margin_left", 12)
	filter_margin.add_theme_constant_override("margin_right", 12)
	filter_margin.add_theme_constant_override("margin_top", 3)
	filter_margin.add_theme_constant_override("margin_bottom", 3)
	_filter_band.add_child(filter_margin)
	var filter_inner := HBoxContainer.new()
	filter_inner.add_theme_constant_override("separation", 8)
	filter_margin.add_child(filter_inner)
	_new_filter_row = HBoxContainer.new()
	_new_filter_row.add_theme_constant_override("separation", 5)
	_new_filter_row.custom_minimum_size = Vector2(180, 0)
	filter_inner.add_child(_new_filter_row)
	_all_filter_button = Button.new()
	_all_filter_button.name = "AllEntriesFilter"
	_all_filter_button.text = "ALL"
	_all_filter_button.custom_minimum_size = Vector2(84, 32)
	_all_filter_button.focus_mode = Control.FOCUS_NONE
	CommonLightUiStyleScript.apply_font(_all_filter_button, 14, true, CommonLightUiStyleScript.TEXT_PRIMARY)
	_all_filter_button.pressed.connect(func() -> void: _set_new_filter_requested(false))
	_new_filter_row.add_child(_all_filter_button)
	_new_filter_button = Button.new()
	_new_filter_button.name = "NewEntriesFilter"
	_new_filter_button.text = "NEW"
	_new_filter_button.custom_minimum_size = Vector2(92, 32)
	_new_filter_button.focus_mode = Control.FOCUS_NONE
	CommonLightUiStyleScript.apply_font(_new_filter_button, 14, true, CommonLightUiStyleScript.TEXT_PRIMARY)
	_new_filter_button.pressed.connect(func() -> void: _set_new_filter_requested(true))
	_new_filter_row.add_child(_new_filter_button)
	var filter_spacer := Control.new()
	filter_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	filter_inner.add_child(filter_spacer)
	_enemy_filter_row = HBoxContainer.new()
	_enemy_filter_row.name = "EnemyStageFilters"
	_enemy_filter_row.add_theme_constant_override("separation", 5)
	_enemy_filter_row.custom_minimum_size = Vector2(0, 32)
	_enemy_filter_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	filter_inner.add_child(_enemy_filter_row)
	var filter_labels := CodexPresentationSystemScript.filter_labels()
	var filter_ids := CodexPresentationSystemScript.filter_ids()
	for index in range(filter_ids.size()):
		var filter_button := Button.new()
		filter_button.text = String(filter_labels[index])
		filter_button.custom_minimum_size = Vector2(0, 32)
		filter_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		filter_button.focus_mode = Control.FOCUS_NONE
		CommonLightUiStyleScript.apply_font(filter_button, 13, false, CommonLightUiStyleScript.TEXT_SECONDARY)
		var filter_id := String(filter_ids[index])
		filter_button.pressed.connect(func() -> void: _set_enemy_filter(filter_id))
		_enemy_filter_buttons.append(filter_button)
		_enemy_filter_row.add_child(filter_button)
	_add_layout_spacer(2)

	_body = HBoxContainer.new()
	_body.name = "MainBody"
	_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body.add_theme_constant_override("separation", 14)
	_layout_root.add_child(_body)

	_list_panel = PanelContainer.new()
	_list_panel.name = "EntryListPanel"
	_list_panel.custom_minimum_size = Vector2(360, 0)
	_list_panel.add_theme_stylebox_override("panel", _panel_style(Color(CommonLightUiStyleScript.MAIN_PANEL, 0.94), CommonLightUiStyleScript.LILAC_BORDER))
	_body.add_child(_list_panel)
	var list_margin := MarginContainer.new()
	list_margin.add_theme_constant_override("margin_left", 10)
	list_margin.add_theme_constant_override("margin_top", 10)
	list_margin.add_theme_constant_override("margin_right", 10)
	list_margin.add_theme_constant_override("margin_bottom", 10)
	_list_panel.add_child(list_margin)
	_list_scroll = ScrollContainer.new()
	_list_scroll.name = "EntryListScroll"
	_list_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_list_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	list_margin.add_child(_list_scroll)
	_list_box = VBoxContainer.new()
	_list_box.add_theme_constant_override("separation", 4)
	_list_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list_scroll.add_child(_list_box)

	_detail_panel = PanelContainer.new()
	_detail_panel.name = "DetailPanel"
	_detail_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail_panel.add_theme_stylebox_override("panel", _panel_style(Color(CommonLightUiStyleScript.MAIN_PANEL, 0.96), CommonLightUiStyleScript.MAIN_PANEL_BORDER))
	_body.add_child(_detail_panel)
	_detail_focus_ring = PanelContainer.new()
	_detail_focus_ring.name = "DetailFocusRing"
	_detail_focus_ring.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_detail_focus_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_detail_focus_ring.z_index = 20
	_detail_focus_ring.add_theme_stylebox_override("panel", _create_detail_focus_ring_style())
	_detail_focus_ring.visible = false
	_detail_panel.add_child(_detail_focus_ring)
	var detail_margin := MarginContainer.new()
	detail_margin.add_theme_constant_override("margin_left", 16)
	detail_margin.add_theme_constant_override("margin_top", 10)
	detail_margin.add_theme_constant_override("margin_right", 16)
	detail_margin.add_theme_constant_override("margin_bottom", 10)
	_detail_panel.add_child(detail_margin)
	_detail_shell = VBoxContainer.new()
	_detail_shell.name = "DetailShell"
	_detail_shell.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_detail_shell.add_theme_constant_override("separation", 8)
	detail_margin.add_child(_detail_shell)
	_detail_header_panel = PanelContainer.new()
	_detail_header_panel.name = "DetailHeader"
	_detail_header_panel.custom_minimum_size = Vector2(0, 56)
	_detail_header_panel.add_theme_stylebox_override("panel", _panel_style(CommonLightUiStyleScript.SUPPORT_PALE, CommonLightUiStyleScript.SUPPORT_LIGHT))
	_detail_shell.add_child(_detail_header_panel)
	var detail_header_margin := MarginContainer.new()
	detail_header_margin.add_theme_constant_override("margin_left", 14)
	detail_header_margin.add_theme_constant_override("margin_right", 14)
	detail_header_margin.add_theme_constant_override("margin_top", 2)
	detail_header_margin.add_theme_constant_override("margin_bottom", 2)
	_detail_header_panel.add_child(detail_header_margin)
	_detail_header_row = HBoxContainer.new()
	_detail_header_row.name = "DetailHeaderRow"
	_detail_header_row.add_theme_constant_override("separation", 8)
	detail_header_margin.add_child(_detail_header_row)
	_detail_title = Label.new()
	CommonLightUiStyleScript.apply_font(_detail_title, 25, true, CommonLightUiStyleScript.TEXT_PRIMARY)
	_detail_title.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_detail_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_title.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	_detail_title.max_lines_visible = 2
	_detail_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail_header_row.add_child(_detail_title)
	_detail_badge_row = HBoxContainer.new()
	_detail_badge_row.name = "DetailBadgeRow"
	_detail_badge_row.size_flags_horizontal = Control.SIZE_SHRINK_END
	_detail_badge_row.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_detail_badge_row.add_theme_constant_override("separation", 4)
	_detail_badge_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_detail_header_row.add_child(_detail_badge_row)
	_character_unit_badge = PanelContainer.new()
	_character_unit_badge.name = "CharacterUnitBadge"
	_character_unit_badge.custom_minimum_size = Vector2(0, 26)
	_character_unit_badge.size_flags_horizontal = Control.SIZE_SHRINK_END
	_character_unit_badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_character_unit_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_character_unit_badge.add_theme_stylebox_override("panel", _character_card_style(CommonLightUiStyleScript.COMBAT_PALE, CommonLightUiStyleScript.COMBAT_LIGHT, 1, 12, 11.0, 3.0))
	_character_unit_badge_label = Label.new()
	_character_unit_badge_label.name = "CharacterUnitBadgeLabel"
	_character_unit_badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_character_unit_badge_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_character_unit_badge_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	CommonLightUiStyleScript.apply_font(_character_unit_badge_label, 13, true, CommonLightUiStyleScript.TEXT_SECONDARY)
	_character_unit_badge.add_child(_character_unit_badge_label)
	_detail_badge_row.add_child(_character_unit_badge)
	_character_unit_badge.visible = false
	_detail_image_frame = PanelContainer.new()
	_detail_image_frame.name = "DetailVisualArea"
	_detail_image_frame.add_theme_stylebox_override("panel", _panel_style(Color(CommonLightUiStyleScript.SUPPORT_PALE, 0.86), CommonLightUiStyleScript.SUPPORT_LIGHT))
	_detail_shell.add_child(_detail_image_frame)
	_detail_image_holder = Control.new()
	_detail_image_holder.name = "VisualHolder"
	_detail_image_holder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail_image_holder.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_detail_image_frame.add_child(_detail_image_holder)
	_detail_scroll = ScrollContainer.new()
	_detail_scroll.name = "DetailInfoScroll"
	_detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_detail_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_detail_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail_shell.add_child(_detail_scroll)
	_detail_info_panel = PanelContainer.new()
	_detail_info_panel.name = "DetailInfoPanel"
	_detail_info_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail_info_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_detail_info_panel.add_theme_stylebox_override("panel", _panel_style(Color(1, 1, 1, 0.62), CommonLightUiStyleScript.DIVIDER))
	_detail_scroll.add_child(_detail_info_panel)
	var detail_info_margin := MarginContainer.new()
	detail_info_margin.add_theme_constant_override("margin_left", 18)
	detail_info_margin.add_theme_constant_override("margin_top", 14)
	detail_info_margin.add_theme_constant_override("margin_right", 18)
	detail_info_margin.add_theme_constant_override("margin_bottom", 14)
	_detail_info_panel.add_child(detail_info_margin)
	_detail_info_content_host = VBoxContainer.new()
	_detail_info_content_host.name = "DetailInfoContentHost"
	_detail_info_content_host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail_info_content_host.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_detail_info_content_host.add_theme_constant_override("separation", 12)
	detail_info_margin.add_child(_detail_info_content_host)
	_detail_body = Label.new()
	_detail_body.name = "DetailInfoBody"
	_detail_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	CommonLightUiStyleScript.apply_font(_detail_body, 16, false, CommonLightUiStyleScript.TEXT_PRIMARY)
	_detail_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail_info_content_host.add_child(_detail_body)
	_build_character_profile_content()
	_build_item_profile_content()

	_footer_panel = PanelContainer.new()
	_footer_panel.name = "FooterNavigation"
	_footer_panel.custom_minimum_size = Vector2(0, 62)
	_footer_panel.add_theme_stylebox_override("panel", CommonLightUiStyleScript.create_panel_style(Color(CommonLightUiStyleScript.MAIN_PANEL, 0.26), CommonLightUiStyleScript.DIVIDER, 0, 12, 0.0, 0.0))
	_layout_root.add_child(_footer_panel)
	var footer_margin := MarginContainer.new()
	footer_margin.add_theme_constant_override("margin_left", 0)
	footer_margin.add_theme_constant_override("margin_right", 0)
	footer_margin.add_theme_constant_override("margin_top", 5)
	footer_margin.add_theme_constant_override("margin_bottom", 5)
	_footer_panel.add_child(footer_margin)
	var footer_row := HBoxContainer.new()
	footer_row.add_theme_constant_override("separation", 8)
	footer_margin.add_child(footer_row)
	_detail_back_button = Button.new()
	_detail_back_button.text = "戻る"
	_detail_back_button.custom_minimum_size = Vector2(168, 46)
	_detail_back_button.focus_mode = Control.FOCUS_NONE
	CommonLightUiStyleScript.apply_font(_detail_back_button, 17, true, CommonLightUiStyleScript.TEXT_PRIMARY)
	_detail_back_button.add_theme_stylebox_override("normal", CommonLightUiStyleScript.create_back_button_style(false))
	_detail_back_button.add_theme_stylebox_override("hover", CommonLightUiStyleScript.create_back_button_style(true))
	_detail_back_button.add_theme_stylebox_override("pressed", CommonLightUiStyleScript.create_back_button_style(true))
	_detail_back_button.add_theme_stylebox_override("focus", CommonLightUiStyleScript.create_back_button_style(true))
	_detail_back_button.pressed.connect(_handle_back_button)
	footer_row.add_child(_detail_back_button)
	var footer_spacer := Control.new()
	footer_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer_row.add_child(footer_spacer)
	_footer_label = Label.new()
	_footer_label.text = "↑↓ 項目　←→ カテゴリ　Enter: 詳細操作　N NEW　Esc 戻る"
	_footer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_footer_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_footer_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	CommonLightUiStyleScript.apply_font(_footer_label, 15, false, CommonLightUiStyleScript.TEXT_SECONDARY)
	footer_row.add_child(_footer_label)

	if OS.is_debug_build():
		_debug_overlay = PanelContainer.new()
		_debug_overlay.name = "DebugOverlay"
		_debug_overlay.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
		_debug_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
		_debug_overlay.z_index = 30
		_debug_overlay.add_theme_stylebox_override("panel", _panel_style(Color(CommonLightUiStyleScript.PP_PALE, 0.96), CommonLightUiStyleScript.PP_GOLD))
		_transition_visual_root.add_child(_debug_overlay)
		_debug_row = HBoxContainer.new()
		_debug_row.add_theme_constant_override("separation", 5)
		_debug_overlay.add_child(_debug_row)
		var unlock_button := Button.new()
		unlock_button.text = "DEBUG 全解禁"
		unlock_button.focus_mode = Control.FOCUS_NONE
		unlock_button.pressed.connect(_debug_unlock_all)
		_debug_row.add_child(unlock_button)
		var new_button := Button.new()
		new_button.text = "全NEW"
		new_button.focus_mode = Control.FOCUS_NONE
		new_button.pressed.connect(_debug_mark_all_new)
		_debug_row.add_child(new_button)
		var reset_button := Button.new()
		reset_button.text = "図鑑リセット"
		reset_button.focus_mode = Control.FOCUS_NONE
		reset_button.pressed.connect(_debug_reset_codex)
		_debug_row.add_child(reset_button)
		var audit_button := Button.new()
		audit_button.text = "監査"
		audit_button.focus_mode = Control.FOCUS_NONE
		audit_button.pressed.connect(_debug_audit)
		_debug_row.add_child(audit_button)
		_debug_status_label = Label.new()
		CommonLightUiStyleScript.apply_font(_debug_status_label, 12, false, CommonLightUiStyleScript.PP_TEXT)
		_debug_row.add_child(_debug_status_label)
	_refresh_focus_visuals()
	_completion_banner = Label.new()
	_completion_banner.text = ""
	_completion_banner.visible = false
	_completion_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_completion_banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	CommonLightUiStyleScript.apply_font(_completion_banner, 20, true, CommonLightUiStyleScript.TEXT_PRIMARY)
	_completion_banner.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_completion_banner.offset_left = -260.0
	_completion_banner.offset_top = 78.0
	_completion_banner.offset_right = 260.0
	_completion_banner.offset_bottom = 122.0
	_completion_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_transition_visual_root.add_child(_completion_banner)
	_apply_layout_metrics()

func _character_card_style(fill: Color, border: Color, border_width: int, radius: int, horizontal_margin: float, vertical_margin: float) -> StyleBoxFlat:
	return CommonLightUiStyleScript.create_panel_style(fill, border, border_width, radius, horizontal_margin, vertical_margin)

func _build_character_profile_content() -> void:
	if _detail_info_content_host == null:
		return
	_character_profile_content = VBoxContainer.new()
	_character_profile_content.name = "CharacterProfileContent"
	_character_profile_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_character_profile_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_character_profile_content.add_theme_constant_override("separation", 12)
	_character_profile_content.visible = false
	_detail_info_content_host.add_child(_character_profile_content)

	_character_overview_row = HBoxContainer.new()
	_character_overview_row.name = "CharacterOverviewRow"
	_character_overview_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_character_overview_row.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_character_overview_row.add_theme_constant_override("separation", 14)
	_character_profile_content.add_child(_character_overview_row)
	_character_overview_image_frame = PanelContainer.new()
	_character_overview_image_frame.name = "CharacterOverviewImageFrame"
	_character_overview_image_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_character_overview_image_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_character_overview_image_frame.size_flags_stretch_ratio = 2.0
	_character_overview_image_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_character_overview_image_frame.add_theme_stylebox_override("panel", _panel_style(Color(CommonLightUiStyleScript.SUPPORT_PALE, 0.86), CommonLightUiStyleScript.SUPPORT_LIGHT))
	_character_overview_row.add_child(_character_overview_image_frame)
	_character_overview_image_holder = Control.new()
	_character_overview_image_holder.name = "CharacterOverviewImageHolder"
	_character_overview_image_holder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_character_overview_image_holder.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_character_overview_image_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_character_overview_image_frame.add_child(_character_overview_image_holder)

	_character_summary_area = VBoxContainer.new()
	_character_summary_area.name = "CharacterSummaryArea"
	_character_summary_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_character_summary_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_character_summary_area.size_flags_stretch_ratio = 3.0
	_character_summary_area.add_theme_constant_override("separation", 10)
	_character_overview_row.add_child(_character_summary_area)
	_character_summary_primary_row = HBoxContainer.new()
	_character_summary_primary_row.name = "CharacterSummaryPrimaryRow"
	_character_summary_primary_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_character_summary_primary_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_character_summary_primary_row.add_theme_constant_override("separation", 12)
	_character_summary_area.add_child(_character_summary_primary_row)
	_character_summary_secondary_row = HBoxContainer.new()
	_character_summary_secondary_row.name = "CharacterSummarySecondaryRow"
	_character_summary_secondary_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_character_summary_secondary_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_character_summary_secondary_row.add_theme_constant_override("separation", 12)
	_character_summary_area.add_child(_character_summary_secondary_row)

	_character_stream_card = _create_character_info_card("StreamStyleCard", "活動スタイル")
	_character_likes_card = _create_character_info_card("LikesCard", "好きなもの")
	_character_dislikes_card = _create_character_info_card("DislikesCard", "苦手なもの")

	_character_profile_card = _create_character_info_card("CharacterProfileCard", "PROFILE")
	_character_profile_content.add_child(_character_profile_card)

	_character_secondary_info = VBoxContainer.new()
	_character_secondary_info.name = "CharacterSecondaryInfo"
	_character_secondary_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_character_secondary_info.add_theme_constant_override("separation", 10)
	_character_profile_content.add_child(_character_secondary_info)
	_character_game_info_card = _create_character_info_card("CharacterGameInfoCard", "GAME INFO")
	_character_play_record_card = _create_character_info_card("CharacterPlayRecordCard", "PLAY RECORD")
	_character_secondary_info.add_child(_character_game_info_card)
	_character_secondary_info.add_child(_character_play_record_card)

	_set_character_card_body(_character_stream_card, "", false)
	_set_character_card_body(_character_likes_card, "", false)
	_set_character_card_body(_character_dislikes_card, "", false)
	_set_character_card_body(_character_profile_card, "", false)
	_set_character_card_body(_character_game_info_card, "", false)
	_set_character_card_body(_character_play_record_card, "", false)
	_character_profile_card.visible = false
	_character_secondary_info.visible = false
	_character_summary_area.visible = false
	_character_overview_row.visible = false
	_character_overview_image_frame.visible = false
	_apply_character_profile_layout()

func _build_item_profile_content() -> void:
	if _detail_info_content_host == null:
		return
	_item_profile_content = VBoxContainer.new()
	_item_profile_content.name = "ItemProfileContent"
	_item_profile_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_item_profile_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_item_profile_content.add_theme_constant_override("separation", 12)
	_item_profile_content.visible = false
	_detail_info_content_host.add_child(_item_profile_content)

	_item_overview_row = HBoxContainer.new()
	_item_overview_row.name = "ItemOverviewRow"
	_item_overview_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_item_overview_row.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_item_overview_row.add_theme_constant_override("separation", 14)
	_item_profile_content.add_child(_item_overview_row)
	_item_visual_frame = PanelContainer.new()
	_item_visual_frame.name = "CodexVisualPanel"
	_item_visual_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_item_visual_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_item_visual_frame.size_flags_stretch_ratio = 2.0
	_item_visual_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_item_visual_frame.add_theme_stylebox_override("panel", _panel_style(Color(CommonLightUiStyleScript.SUPPORT_PALE, 0.86), CommonLightUiStyleScript.SUPPORT_LIGHT))
	_item_overview_row.add_child(_item_visual_frame)
	_item_visual_holder = Control.new()
	_item_visual_holder.name = "CodexVisualHolder"
	_item_visual_holder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_item_visual_holder.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_item_visual_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_item_visual_holder.clip_contents = true
	_item_visual_holder.resized.connect(_on_item_visual_holder_resized)
	_item_visual_frame.add_child(_item_visual_holder)

	_item_summary_area = VBoxContainer.new()
	_item_summary_area.name = "ItemSummaryArea"
	_item_summary_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_item_summary_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_item_summary_area.size_flags_stretch_ratio = 3.0
	_item_summary_area.add_theme_constant_override("separation", 10)
	_item_overview_row.add_child(_item_summary_area)
	_item_summary_primary_row = HBoxContainer.new()
	_item_summary_primary_row.name = "ItemSummaryPrimaryRow"
	_item_summary_primary_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_item_summary_primary_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_item_summary_area.add_child(_item_summary_primary_row)
	_item_comment_wide_column = VBoxContainer.new()
	_item_comment_wide_column.name = "CommentSummaryWideColumn"
	_item_comment_wide_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_item_comment_wide_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_item_comment_wide_column.add_theme_constant_override("separation", 8)
	_item_comment_wide_column.visible = false
	_item_summary_area.add_child(_item_comment_wide_column)
	_item_summary_secondary_row = HBoxContainer.new()
	_item_summary_secondary_row.name = "ItemSummarySecondaryRow"
	_item_summary_secondary_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_item_summary_secondary_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_item_summary_secondary_row.add_theme_constant_override("separation", 10)
	_item_summary_area.add_child(_item_summary_secondary_row)
	_item_comment_effect_card = _create_character_info_card("CommentEffectSummaryCard", "効果概要")
	_item_comment_effect_card.set_meta("item_lore_id", "effect_summary")
	_item_comment_effect_card.set_meta("item_lore_span", 2)
	_item_comment_effect_card.visible = false
	_item_comment_wide_column.add_child(_item_comment_effect_card)

	for card_id in ["origin", "usage", "rumor", "evolution_trigger", "evolution_from", "reputation", "popularity", "streamer_memo"]:
		var card := _create_character_info_card("ItemLoreCard_%s" % card_id, "")
		card.set_meta("item_lore_id", card_id)
		card.visible = false
		_item_card_by_id[card_id] = card

	_item_archive_card = _create_character_info_card("ItemArchiveCard", "")
	_item_game_data_card = _create_character_info_card("ItemGameDataCard", "GAME DATA")
	_item_profile_content.add_child(_item_archive_card)
	_item_profile_content.add_child(_item_game_data_card)
	for card_value in _item_card_by_id.values():
		_set_character_card_body(card_value as PanelContainer, "", false)
	_item_archive_card.visible = false
	_item_game_data_card.visible = false
	_set_character_card_body(_item_comment_effect_card, "", false)
	_apply_item_profile_layout()

func _ensure_item_lore_card(card_id: String) -> PanelContainer:
	var normalized_id := card_id.strip_edges()
	if normalized_id == "":
		return null
	var existing := _item_card_by_id.get(normalized_id, null) as PanelContainer
	if existing != null:
		return existing
	var card := _create_character_info_card("ItemLoreCard_%s" % normalized_id, "")
	card.set_meta("item_lore_id", normalized_id)
	card.visible = false
	_item_card_by_id[normalized_id] = card
	_set_character_card_body(card, "", false)
	return card

func _apply_item_profile_layout() -> void:
	if _item_summary_area == null:
		return
	var is_comment := _category_index >= 0 and _category_index < CATEGORIES.size() and CATEGORIES[_category_index] == CodexManager.CATEGORY_COMMENT
	for row in [_item_summary_primary_row, _item_summary_secondary_row, _item_comment_wide_column]:
		if row == null:
			continue
		for child in row.get_children():
			row.remove_child(child)
	var wide_cards: Array[PanelContainer] = []
	var half_cards: Array[PanelContainer] = []
	for card_value in _item_card_by_id.values():
		var card := card_value as PanelContainer
		if card == null or not card.visible:
			continue
		var span := int(card.get_meta("item_lore_span", 1))
		if span == 2:
			wide_cards.append(card)
		else:
			half_cards.append(card)
	if is_comment:
		var effect_visible := _item_comment_effect_card != null and _item_comment_effect_card.visible
		if effect_visible:
			_item_comment_wide_column.add_child(_item_comment_effect_card)
		var writer := _item_card_by_id.get("writer", null) as PanelContainer
		if writer != null and writer.visible:
			_item_comment_wide_column.add_child(writer)
		for card_id in ["posting_moment", "observation_note"]:
			var half_card := _item_card_by_id.get(card_id, null) as PanelContainer
			if half_card != null and half_card.visible:
				_item_summary_secondary_row.add_child(half_card)
		_item_summary_primary_row.visible = false
		_item_comment_wide_column.visible = _item_comment_wide_column.get_child_count() > 0
		_item_summary_secondary_row.visible = _item_summary_secondary_row.get_child_count() > 0
	else:
		for card in wide_cards:
			_item_summary_primary_row.add_child(card)
		for card in half_cards:
			_item_summary_secondary_row.add_child(card)
		_item_summary_primary_row.visible = not wide_cards.is_empty()
		_item_comment_wide_column.visible = false
		_item_summary_secondary_row.visible = not half_cards.is_empty()
	_item_summary_area.visible = _item_summary_primary_row.visible or _item_summary_secondary_row.visible
	if is_comment:
		_item_summary_area.visible = _item_comment_wide_column.visible or _item_summary_secondary_row.visible
	_item_summary_primary_row.add_theme_constant_override("separation", 10 if not _compact_layout else 8)
	_item_summary_secondary_row.add_theme_constant_override("separation", 10 if not _compact_layout else 8)
	_item_comment_wide_column.add_theme_constant_override("separation", 8 if _compact_layout else 10)
	for card_value in _item_card_by_id.values():
		_apply_character_card_metrics(card_value as PanelContainer)
	_apply_character_card_metrics(_item_comment_effect_card)
	_apply_character_card_metrics(_item_archive_card, true)
	_apply_character_card_metrics(_item_game_data_card)
	_apply_item_overview_metrics()

func _apply_item_overview_metrics() -> void:
	if _item_overview_row == null:
		return
	var height := 215.0 if _compact_layout else 235.0
	if _category_index >= 0 and _category_index < CATEGORIES.size() and CATEGORIES[_category_index] == CodexManager.CATEGORY_COMMENT:
		height = 250.0 if _compact_layout else 280.0
	if _category_index >= 0 and _category_index < CATEGORIES.size() and CATEGORIES[_category_index] == CodexManager.CATEGORY_ENEMY:
		height = 220.0 if _compact_layout else 235.0
		var enemy_entries := _visible_entries()
		var enemy_selected := _selected_index(enemy_entries)
		if enemy_selected >= 0 and enemy_selected < enemy_entries.size():
			var enemy_item := enemy_entries[enemy_selected] as Dictionary
			if bool(enemy_item.get("isBoss", false)) or bool(enemy_item.get("relayBoss", false)):
				height = 225.0 if _compact_layout else 250.0
	_item_overview_row.custom_minimum_size = Vector2(0, height)
	_item_visual_frame.custom_minimum_size = Vector2(0, height)
	_item_visual_holder.custom_minimum_size = Vector2(0, height)
	_item_overview_row.add_theme_constant_override("separation", 10 if _compact_layout else 14)
	_item_summary_area.add_theme_constant_override("separation", 8 if _compact_layout else 10)

func _create_character_info_card(card_name: String, heading: String) -> PanelContainer:
	var card := PanelContainer.new()
	card.name = card_name
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", _character_card_style(Color(CommonLightUiStyleScript.MAIN_PANEL, 0.92), CommonLightUiStyleScript.DIVIDER, 1, 12, 0.0, 0.0))
	var margin := MarginContainer.new()
	margin.name = "CardMargin"
	card.add_child(margin)
	var content := VBoxContainer.new()
	content.name = "CardContent"
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 7)
	margin.add_child(content)
	var heading_label := Label.new()
	heading_label.name = "CardHeading"
	heading_label.text = heading
	heading_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	CommonLightUiStyleScript.apply_font(heading_label, 14, true, CommonLightUiStyleScript.COMBAT_DARK)
	content.add_child(heading_label)
	var separator := ColorRect.new()
	separator.name = "CardSeparator"
	separator.custom_minimum_size = Vector2(0, 1)
	separator.color = Color(CommonLightUiStyleScript.DIVIDER, 0.90)
	separator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(separator)
	var body := Label.new()
	body.name = "CardBody"
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	CommonLightUiStyleScript.apply_font(body, 16, false, CommonLightUiStyleScript.TEXT_PRIMARY)
	content.add_child(body)
	card.set_meta("character_card_body", body)
	card.set_meta("character_card_margin", margin)
	card.set_meta("character_card_heading", heading_label)
	return card

func _set_character_card_body(card: PanelContainer, text: String, card_visible: bool = true) -> void:
	if card == null:
		return
	var body := card.get_meta("character_card_body", null) as Label
	if body != null:
		body.text = text
	card.visible = card_visible and text.strip_edges() != ""

func _apply_character_card_metrics(card: PanelContainer, profile_card: bool = false) -> void:
	if card == null:
		return
	var margin := card.get_meta("character_card_margin", null) as MarginContainer
	if margin != null:
		var horizontal := (22 if profile_card else 13) if _compact_layout else (30 if profile_card else 15)
		var vertical := (11 if profile_card else 11) if _compact_layout else (20 if profile_card else 12)
		margin.add_theme_constant_override("margin_left", horizontal)
		margin.add_theme_constant_override("margin_right", horizontal)
		margin.add_theme_constant_override("margin_top", vertical)
		margin.add_theme_constant_override("margin_bottom", vertical)
	var heading := card.get_meta("character_card_heading", null) as Label
	if heading != null:
		CommonLightUiStyleScript.apply_font(heading, 13 if _compact_layout else 14, true, CommonLightUiStyleScript.COMBAT_DARK)
	var body := card.get_meta("character_card_body", null) as Label
	if body != null:
		CommonLightUiStyleScript.apply_font(body, (17 if profile_card else 16) if _compact_layout else (18 if profile_card else 16), false, CommonLightUiStyleScript.TEXT_PRIMARY)
		body.add_theme_constant_override("line_spacing", (5 if profile_card else 2) if _compact_layout else (6 if profile_card else 2))

func _apply_character_profile_layout() -> void:
	if _character_summary_area == null or _character_overview_row == null:
		return
	var cards: Array[PanelContainer] = [_character_stream_card, _character_likes_card, _character_dislikes_card]
	for row in [_character_summary_primary_row, _character_summary_secondary_row]:
		if row == null:
			continue
		for child in row.get_children():
			row.remove_child(child)
	for card in cards:
		if card == null or not card.visible:
			continue
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.size_flags_vertical = Control.SIZE_EXPAND_FILL
		var target_row := _character_summary_primary_row
		if card != _character_stream_card:
			target_row = _character_summary_secondary_row
		target_row.add_child(card)
	_character_summary_primary_row.visible = _character_summary_primary_row.get_child_count() > 0
	_character_summary_secondary_row.visible = _character_summary_secondary_row.get_child_count() > 0
	_character_summary_area.visible = _character_summary_primary_row.visible or _character_summary_secondary_row.visible
	_apply_character_card_metrics(_character_stream_card)
	_apply_character_card_metrics(_character_likes_card)
	_apply_character_card_metrics(_character_dislikes_card)
	_apply_character_card_metrics(_character_profile_card, true)
	_apply_character_card_metrics(_character_game_info_card)
	_apply_character_card_metrics(_character_play_record_card)
	_apply_character_overview_metrics()

func _apply_character_overview_metrics() -> void:
	if _character_overview_row == null:
		return
	var overview_height := 220.0 if _compact_layout else 235.0
	var separation := 10 if _compact_layout else 14
	_character_overview_row.custom_minimum_size = Vector2(0, overview_height)
	_character_overview_row.add_theme_constant_override("separation", separation)
	_character_overview_image_frame.custom_minimum_size = Vector2(0, overview_height)
	_character_overview_image_holder.custom_minimum_size = Vector2(0, overview_height)
	_character_summary_area.add_theme_constant_override("separation", 8 if _compact_layout else 10)
	_character_summary_primary_row.add_theme_constant_override("separation", 8 if _compact_layout else 10)
	_character_summary_secondary_row.add_theme_constant_override("separation", 8 if _compact_layout else 10)

func _is_character_structured_detail_active() -> bool:
	if _category_index < 0 or _category_index >= CATEGORIES.size():
		return false
	if CATEGORIES[_category_index] != CodexManager.CATEGORY_CHARACTER:
		return false
	if _character_profile_content == null or not _character_profile_content.visible:
		return false
	var entries := _visible_entries()
	var selected := _selected_index(entries)
	return selected >= 0 and selected < entries.size() and bool((entries[selected] as Dictionary).get("discovered", false))

func _is_item_structured_detail_active() -> bool:
	if _category_index < 0 or _category_index >= CATEGORIES.size():
		return false
	if CATEGORIES[_category_index] not in [CodexManager.CATEGORY_WEAPON, CodexManager.CATEGORY_ACCESSORY, CodexManager.CATEGORY_ENEMY, CodexManager.CATEGORY_COMMENT]:
		return false
	if _item_profile_content == null or not _item_profile_content.visible:
		return false
	var entries := _visible_entries()
	var selected := _selected_index(entries)
	return selected >= 0 and selected < entries.size() and bool((entries[selected] as Dictionary).get("discovered", false))

func _set_character_structured_detail_visible(enabled: bool) -> void:
	if _character_profile_content == null or _detail_body == null:
		return
	_character_profile_content.visible = enabled
	if enabled and _item_profile_content != null:
		_item_profile_content.visible = false
	_detail_body.visible = not enabled and not _is_item_structured_detail_active()
	if _detail_image_frame != null:
		_detail_image_frame.visible = not enabled and not _is_item_structured_detail_active()
	if _character_overview_image_frame != null:
		_character_overview_image_frame.visible = enabled
	if _character_overview_row != null:
		_character_overview_row.visible = enabled
	if not enabled and _character_overview_image_holder != null:
		_clear_image_holder(_character_overview_image_holder)
	_apply_character_overview_metrics()

func _set_item_structured_detail_visible(enabled: bool) -> void:
	if _item_profile_content == null or _detail_body == null:
		return
	_item_profile_content.visible = enabled
	if enabled and _character_profile_content != null:
		_character_profile_content.visible = false
		_character_overview_row.visible = false
		_character_overview_image_frame.visible = false
		_clear_image_holder(_character_overview_image_holder)
	_detail_body.visible = not enabled
	if _detail_image_frame != null:
		_detail_image_frame.visible = not enabled
	if _item_visual_frame != null:
		_item_visual_frame.visible = enabled
	if not enabled and _item_visual_holder != null:
		_clear_image_holder(_item_visual_holder)
	_apply_item_overview_metrics()

func _set_generic_detail_content() -> void:
	_set_character_structured_detail_visible(false)
	_set_item_structured_detail_visible(false)
	_detail_body.visible = true
	_detail_image_frame.visible = true

func _set_character_profile_visible(visible_state: bool) -> void:
	_set_character_structured_detail_visible(visible_state)

func _update_detail_header(item: Dictionary, discovered: bool, category: String) -> void:
	if _character_unit_badge == null or _character_unit_badge_label == null:
		return
	var unit_name := ""
	if category == CodexManager.CATEGORY_CHARACTER and discovered:
		var character_model := CodexPresentationSystemScript.character_profile_model(item, CodexManager.get_master_entries(CodexManager.CATEGORY_WEAPON), _discovered_weapon_ids(), true, _get_enemy_sources())
		unit_name = String(character_model.get("unitDisplayName", "")).strip_edges()
	elif discovered and category in [CodexManager.CATEGORY_WEAPON, CodexManager.CATEGORY_ACCESSORY]:
		var item_model := CodexPresentationSystemScript.item_lore_model(item, category, true, CodexManager.get_master_entries(CodexManager.CATEGORY_WEAPON), CodexManager.get_master_entries(CodexManager.CATEGORY_CHARACTER))
		unit_name = String(item_model.get("classificationLabel", "")).strip_edges()
	_set_detail_badges([unit_name] if unit_name != "" else [])

func _set_detail_badges(raw_labels: Array) -> void:
	if _character_unit_badge == null or _character_unit_badge_label == null:
		return
	for badge in _detail_extra_badges:
		if is_instance_valid(badge):
			badge.queue_free()
	_detail_extra_badges.clear()
	var labels: Array[String] = []
	for raw_label in raw_labels:
		var label := String(raw_label).strip_edges()
		if label != "" and not labels.has(label):
			labels.append(label)
	if labels.size() > 3:
		var limited_labels: Array[String] = []
		for index in range(3):
			limited_labels.append(labels[index])
		labels = limited_labels
	_character_unit_badge_label.text = labels[0] if not labels.is_empty() else ""
	_character_unit_badge.visible = not labels.is_empty()
	if _detail_badge_row == null:
		return
	for index in range(1, labels.size()):
		var badge := PanelContainer.new()
		badge.name = "DetailBadge_%d" % index
		badge.custom_minimum_size = Vector2(0, 26)
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		badge.add_theme_stylebox_override("panel", _character_card_style(CommonLightUiStyleScript.COMBAT_PALE, CommonLightUiStyleScript.COMBAT_LIGHT, 1, 12, 11.0, 3.0))
		var badge_label := Label.new()
		badge_label.text = labels[index]
		badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		badge_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		badge_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		CommonLightUiStyleScript.apply_font(badge_label, 13, true, CommonLightUiStyleScript.TEXT_SECONDARY)
		badge.add_child(badge_label)
		_detail_badge_row.add_child(badge)
		_detail_extra_badges.append(badge)

func _render_character_profile(model: Dictionary, entry: Dictionary) -> void:
	var stream_style := String(model.get("streamStyle", "")).strip_edges()
	var likes: Array = model.get("likes", []) as Array
	var dislikes: Array = model.get("dislikes", []) as Array
	var likes_lines: Array[String] = []
	for value in likes:
		var like := String(value).strip_edges()
		if like != "":
			likes_lines.append("・" + like)
	var dislikes_lines: Array[String] = []
	for value in dislikes:
		var dislike := String(value).strip_edges()
		if dislike != "":
			dislikes_lines.append("・" + dislike)
	_set_character_card_body(_character_stream_card, stream_style)
	_set_character_card_body(_character_likes_card, "\n".join(likes_lines))
	_set_character_card_body(_character_dislikes_card, "\n".join(dislikes_lines))
	_set_character_card_body(_character_profile_card, String(model.get("description", "")).strip_edges())
	var game_lines: Array[String] = []
	var character_type := String(model.get("type", "")).strip_edges()
	if character_type != "":
		game_lines.append("タイプ：%s" % character_type)
	var initial_weapon_name := String(model.get("initialWeaponName", "")).strip_edges()
	if initial_weapon_name != "":
		game_lines.append("初期武器：%s" % initial_weapon_name)
	var initial_evolution_name := String(model.get("initialEvolutionName", "")).strip_edges()
	if initial_evolution_name != "" and initial_evolution_name != "進化なし":
		game_lines.append("初期武器の進化先：%s" % initial_evolution_name)
	_set_character_card_body(_character_game_info_card, "\n".join(game_lines))
	var record_lines: Array[String] = []
	var character_record := CodexPresentationSystemScript.character_record_model(model, entry, _difficulty_progress)
	record_lines.append("play %d / clear %d / best score %s" % [int(character_record.get("playCount", 0)), int(character_record.get("clearCount", 0)), _number_with_commas(int(character_record.get("bestScore", 0)))])
	for stage_value in character_record.get("stageClears", []) as Array:
		var stage_record: Dictionary = stage_value as Dictionary
		var status_values: Array[String] = []
		for state_value in stage_record.get("states", []) as Array:
			var state: Dictionary = state_value as Dictionary
			status_values.append("%s:%s" % [String(state.get("label", "")), String(state.get("status", "---"))])
		record_lines.append("%s  %s" % [String(stage_record.get("label", "")), " / ".join(status_values)])
	for relay_value in character_record.get("relayRecords", []) as Array:
		var relay_record: Dictionary = relay_value as Dictionary
		record_lines.append("RELAY %s: %s / %s" % [String(relay_record.get("label", "")), String(relay_record.get("status", "---")), String(relay_record.get("bestSectionLabel", "---"))])
	_set_character_card_body(_character_play_record_card, "\n".join(record_lines))
	_character_secondary_info.visible = _character_game_info_card.visible or _character_play_record_card.visible
	_set_character_structured_detail_visible(true)
	_apply_character_profile_layout()

func _load_codex_header_icon() -> Texture2D:
	var source_texture := load(CODEX_HEADER_ICON_PATH) as Texture2D
	if source_texture == null:
		return null
	var source_image := source_texture.get_image()
	if source_image == null or source_image.is_empty():
		return source_texture
	var used_rect := source_image.get_used_rect()
	if used_rect.size.x <= 0 or used_rect.size.y <= 0:
		return source_texture
	var padding_x := maxi(2, ceili(float(used_rect.size.x) * CODEX_HEADER_ICON_PADDING_RATIO))
	var padding_y := maxi(2, ceili(float(used_rect.size.y) * CODEX_HEADER_ICON_PADDING_RATIO))
	var region_start := Vector2i(maxi(0, used_rect.position.x - padding_x), maxi(0, used_rect.position.y - padding_y))
	var region_end := Vector2i(mini(source_image.get_width(), used_rect.end.x + padding_x), mini(source_image.get_height(), used_rect.end.y + padding_y))
	var region := Rect2i(region_start, region_end - region_start)
	if region.size.x <= 0 or region.size.y <= 0:
		return source_texture
	var atlas := AtlasTexture.new()
	atlas.atlas = source_texture
	atlas.region = Rect2(region)
	return atlas

func _add_layout_spacer(height: float) -> void:
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, height)
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layout_spacers.append(spacer)
	_layout_root.add_child(spacer)

func _apply_layout_metrics() -> void:
	if not _built or _layout_margin == null or _header_panel == null or _footer_panel == null:
		return
	if size == _last_layout_size:
		return
	_last_layout_size = size
	_compact_layout = size.x > 0.0 and size.x < NORMAL_LAYOUT_MIN_WIDTH
	var margin_left := 20 if _compact_layout else 32
	var margin_top := 14 if _compact_layout else 20
	var margin_right := 20 if _compact_layout else 32
	var margin_bottom := 14 if _compact_layout else 18
	_layout_margin.add_theme_constant_override("margin_left", margin_left)
	_layout_margin.add_theme_constant_override("margin_top", margin_top)
	_layout_margin.add_theme_constant_override("margin_right", margin_right)
	_layout_margin.add_theme_constant_override("margin_bottom", margin_bottom)
	var header_height := 46 if _compact_layout else 52
	var tab_height := 40 if _compact_layout else 44
	var stats_height := 48 if _compact_layout else 52
	var filter_height := 36 if _compact_layout else 40
	var footer_height := 52 if _compact_layout else 62
	_header_panel.custom_minimum_size = Vector2(0, header_height)
	_category_row.custom_minimum_size = Vector2(0, tab_height)
	_stats_panel.custom_minimum_size = Vector2(0, stats_height)
	_filter_band.custom_minimum_size = Vector2(0, filter_height)
	_footer_panel.custom_minimum_size = Vector2(0, footer_height)
	if _debug_overlay != null:
		_debug_overlay.offset_left = 190.0 if _compact_layout else 212.0
		_debug_overlay.offset_top = -58.0 if _compact_layout else -70.0
		_debug_overlay.offset_right = 640.0 if _compact_layout else 662.0
		_debug_overlay.offset_bottom = -10.0 if _compact_layout else -18.0
	_body.add_theme_constant_override("separation", 10 if _compact_layout else 14)
	_list_panel.custom_minimum_size.x = 300 if _compact_layout else 360
	var list_margin := _list_panel.get_child(0) as MarginContainer
	if list_margin != null:
		var list_padding := 8 if _compact_layout else 10
		list_margin.add_theme_constant_override("margin_left", list_padding)
		list_margin.add_theme_constant_override("margin_top", list_padding)
		list_margin.add_theme_constant_override("margin_right", list_padding)
		list_margin.add_theme_constant_override("margin_bottom", list_padding)
	_detail_back_button.custom_minimum_size = Vector2(150 if _compact_layout else 168, 42 if _compact_layout else 46)
	if _character_unit_badge != null:
		_character_unit_badge.custom_minimum_size.y = 24 if _compact_layout else 26
	if _character_unit_badge_label != null:
		CommonLightUiStyleScript.apply_font(_character_unit_badge_label, 12 if _compact_layout else 13, true, CommonLightUiStyleScript.TEXT_SECONDARY)
	CommonLightUiStyleScript.apply_font(_footer_label, 14 if _compact_layout else 15, false, CommonLightUiStyleScript.TEXT_SECONDARY)
	CommonLightUiStyleScript.apply_font(_detail_body, 15 if _compact_layout else 16, false, CommonLightUiStyleScript.TEXT_PRIMARY)
	_apply_character_profile_layout()
	_apply_item_profile_layout()
	for spacer_index in range(_layout_spacers.size()):
		var spacer := _layout_spacers[spacer_index]
		spacer.custom_minimum_size.y = 6.0 if spacer_index < 2 else 2.0
	_apply_visual_area_metrics()
	_refresh_detail_controls()

func _apply_visual_area_metrics() -> void:
	if _detail_image_frame == null:
		return
	if _is_character_structured_detail_active():
		_detail_image_frame.custom_minimum_size = Vector2.ZERO
		_detail_image_holder.custom_minimum_size = Vector2.ZERO
		_apply_character_overview_metrics()
		return
	if _is_item_structured_detail_active():
		_detail_image_frame.custom_minimum_size = Vector2.ZERO
		_detail_image_holder.custom_minimum_size = Vector2.ZERO
		_apply_item_overview_metrics()
		_apply_comment_illustration_metrics()
		return
	var category := CATEGORIES[_category_index]
	var visual_height := 180.0
	if not _compact_layout:
		match category:
			CodexManager.CATEGORY_CHARACTER:
				visual_height = 270.0
			CodexManager.CATEGORY_WEAPON:
				visual_height = 240.0
			CodexManager.CATEGORY_ACCESSORY:
				visual_height = 220.0
			CodexManager.CATEGORY_ENEMY:
				visual_height = 230.0
				var enemy_entries := _visible_entries()
				var selected := _selected_index(enemy_entries)
				if selected >= 0 and selected < enemy_entries.size():
					var selected_item: Dictionary = enemy_entries[selected] as Dictionary
					if bool(selected_item.get("discovered", false)):
						var enemy_model := CodexPresentationSystemScript.build_enemy_model(selected_item, true, selected_item.get("entry", {}) as Dictionary, _get_enemy_sources())
						if String(enemy_model.get("kind", "")) != "normal":
							visual_height = 300.0
			CodexManager.CATEGORY_COMMENT:
				visual_height = 240.0
	else:
		match category:
			CodexManager.CATEGORY_CHARACTER:
				visual_height = 180.0
			CodexManager.CATEGORY_WEAPON:
				visual_height = 170.0
			CodexManager.CATEGORY_ACCESSORY:
				visual_height = 160.0
			CodexManager.CATEGORY_ENEMY:
				visual_height = 190.0
				var compact_enemy_entries := _visible_entries()
				var compact_selected := _selected_index(compact_enemy_entries)
				if compact_selected >= 0 and compact_selected < compact_enemy_entries.size():
					var compact_item: Dictionary = compact_enemy_entries[compact_selected] as Dictionary
					if bool(compact_item.get("discovered", false)):
						var compact_model := CodexPresentationSystemScript.build_enemy_model(compact_item, true, compact_item.get("entry", {}) as Dictionary, _get_enemy_sources())
						if String(compact_model.get("kind", "")) != "normal":
							visual_height = 220.0
			CodexManager.CATEGORY_COMMENT:
				visual_height = 180.0
	_detail_image_frame.custom_minimum_size = Vector2(0, visual_height)
	_detail_image_holder.custom_minimum_size = Vector2(0, visual_height)

func _category_accent(index: int) -> Color:
	match index:
		0:
			return CommonLightUiStyleScript.COMBAT_MAIN
		1:
			return CommonLightUiStyleScript.SUPPORT_MAIN
		2:
			return CommonLightUiStyleScript.PP_GOLD
		3:
			return Color("#9D7AD6")
		_:
			return CommonLightUiStyleScript.OPTION_ACCENT_TEAL

func _apply_category_button_style(button: Button, index: int, active: bool) -> void:
	var accent := _category_accent(index)
	var active_style := CommonLightUiStyleScript.create_tab_style(true, accent.lightened(0.28))
	var normal_style := CommonLightUiStyleScript.create_tab_style(false, accent)
	button.add_theme_stylebox_override("normal", active_style if active else normal_style)
	button.add_theme_stylebox_override("hover", active_style)
	button.add_theme_stylebox_override("pressed", active_style)
	button.add_theme_stylebox_override("focus", CommonLightUiStyleScript.create_outer_focus_ring_style(accent))

func _apply_list_button_style(button: Button, category_index: int, selected: bool, weak_selected: bool = false) -> void:
	var accent := _category_accent(category_index)
	var normal_style := CommonLightUiStyleScript.create_panel_style(Color(1, 1, 1, 0.88), CommonLightUiStyleScript.LILAC_BORDER, 1, 12, 12.0, 6.0)
	var selected_style := CommonLightUiStyleScript.create_panel_style(Color(accent, 0.18), accent, 2, 12, 12.0, 6.0)
	selected_style.shadow_color = Color(accent, 0.16)
	selected_style.shadow_size = 5
	var weak_style := CommonLightUiStyleScript.create_panel_style(Color(accent, 0.07), Color(accent, 0.55), 1, 12, 12.0, 6.0)
	weak_style.shadow_color = Color.TRANSPARENT
	weak_style.shadow_size = 0
	var normal_or_weak := weak_style if weak_selected and not selected else normal_style
	button.add_theme_stylebox_override("normal", selected_style if selected else normal_or_weak)
	button.add_theme_stylebox_override("hover", selected_style if selected else (weak_style if weak_selected else normal_style))
	button.add_theme_stylebox_override("pressed", selected_style if selected else (weak_style if weak_selected else normal_style))
	button.add_theme_stylebox_override("focus", CommonLightUiStyleScript.create_outer_focus_ring_style(accent))

func _refresh_list_focus_visuals() -> void:
	if _list_box == null:
		return
	var entries := _visible_entries()
	var selected := _selected_index(entries)
	var strong_cursor_visible := _focus_area == FocusArea.LIST and _input_focus == InputFocus.LIST
	var weak_cursor_visible := _focus_area == FocusArea.LIST and _input_focus == InputFocus.DETAIL
	var children := _list_box.get_children()
	for index in range(children.size()):
		var button := children[index] as Button
		if button == null:
			continue
		var active_row := strong_cursor_visible and index == selected
		var weak_row := weak_cursor_visible and index == selected
		var marker := button.get_meta("codex_selection_marker", null) as Label
		if marker != null and is_instance_valid(marker):
			marker.text = "▶" if active_row else ""
		_apply_list_button_style(button, _category_index, active_row, weak_row)

func _refresh_focus_visuals() -> void:
	_refresh_list_focus_visuals()
	if _detail_back_button != null:
		var back_active := _focus_area == FocusArea.BACK and _input_focus == InputFocus.LIST
		_detail_back_button.add_theme_stylebox_override("normal", CommonLightUiStyleScript.create_back_button_style(back_active))
		_detail_back_button.add_theme_stylebox_override("hover", CommonLightUiStyleScript.create_back_button_style(true))
		_detail_back_button.add_theme_stylebox_override("pressed", CommonLightUiStyleScript.create_back_button_style(true))
		_detail_back_button.add_theme_stylebox_override("focus", CommonLightUiStyleScript.create_back_button_style(true))
	if _detail_focus_ring != null:
		_detail_focus_ring.visible = visible and _input_focus == InputFocus.DETAIL
		_detail_focus_ring.add_theme_stylebox_override("panel", _create_detail_focus_ring_style())
	_apply_detail_scrollbar_style()

func _apply_filter_button_style(button: Button, active: bool) -> void:
	var style := CommonLightUiStyleScript.create_panel_style(CommonLightUiStyleScript.SUPPORT_PALE if active else Color(1, 1, 1, 0.70), CommonLightUiStyleScript.SUPPORT_MAIN if active else CommonLightUiStyleScript.LILAC_BORDER, 2 if active else 1, 10, 8.0, 5.0)
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", CommonLightUiStyleScript.create_panel_style(CommonLightUiStyleScript.SUPPORT_PALE, CommonLightUiStyleScript.SUPPORT_MAIN, 2, 10, 8.0, 5.0))
	button.add_theme_stylebox_override("pressed", style)

func _panel_style(background: Color, border: Color) -> StyleBoxFlat:
	return CommonLightUiStyleScript.create_panel_style(background, border, 2, 14, 0.0, 0.0)

func _create_detail_focus_ring_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color.TRANSPARENT
	style.draw_center = false
	style.shadow_size = 0
	style.shadow_color = Color.TRANSPARENT
	style.border_color = _category_accent(_category_index)
	style.set_border_width_all(3)
	style.set_corner_radius_all(14)
	return style

func _apply_detail_scrollbar_style() -> void:
	if _detail_scroll == null:
		return
	var scrollbar := _detail_scroll.get_v_scroll_bar()
	if scrollbar == null:
		return
	var accent := _category_accent(_category_index)
	var track := CommonLightUiStyleScript.create_panel_style(Color(accent, 0.08), Color(accent, 0.22), 1, 6, 0.0, 0.0)
	var grabber := CommonLightUiStyleScript.create_panel_style(Color(accent, 0.48), Color(accent, 0.68), 1, 6, 0.0, 0.0)
	var grabber_hover := CommonLightUiStyleScript.create_panel_style(Color(accent, 0.68), accent, 1, 6, 0.0, 0.0)
	scrollbar.add_theme_stylebox_override("scroll", track)
	scrollbar.add_theme_stylebox_override("scroll_focus", track)
	scrollbar.add_theme_stylebox_override("grabber", grabber)
	scrollbar.add_theme_stylebox_override("grabber_highlight", grabber_hover)

func _apply_open_options(options: Dictionary) -> void:
	if options.has("category"):
		var requested: Variant = options.get("category")
		if requested is int:
			_category_index = clampi(int(requested), 0, CATEGORIES.size() - 1)
		else:
			var category_id := String(requested).strip_edges().to_lower()
			var category_index := CATEGORIES.find(category_id)
			if category_index >= 0:
				_category_index = category_index
	if options.has("newOnly"):
		_new_only = bool(options.get("newOnly", false))
	if _new_only and CodexManager.get_new_count(CATEGORIES[_category_index]) <= 0:
		_new_only = false

func _handle_back_button() -> void:
	_cancel_current_layer()

func _cancel_current_layer() -> void:
	cancel_requested.emit()
	if _input_focus == InputFocus.DETAIL:
		_input_focus = InputFocus.LIST
		_focus_area = FocusArea.LIST
		_refresh_focus_visuals()
		_refresh_detail_controls()
		return
	close_screen()

func _enter_detail_focus() -> bool:
	if _input_focus == InputFocus.DETAIL or not _detail_is_scrollable():
		return false
	_input_focus = InputFocus.DETAIL
	_focus_area = FocusArea.LIST
	_right_stick_y_value = 0.0
	_refresh_focus_visuals()
	_refresh_detail_controls()
	confirm_requested.emit()
	return true

func _scroll_detail_small(direction: int) -> void:
	if _detail_scroll == null or not _detail_is_scrollable():
		return
	_set_detail_scroll_value(float(_detail_scroll.scroll_vertical) + 100.0 * float(direction))

func _set_detail_scroll_value(value: float) -> void:
	if _detail_scroll == null:
		return
	_detail_scroll.scroll_vertical = int(round(clampf(value, 0.0, _detail_scroll_range())))

func _set_focus_area(area: int, emit_cursor: bool = true) -> bool:
	var changed := _focus_area != area
	_focus_area = area
	_refresh_focus_visuals()
	if changed and emit_cursor:
		cursor_moved.emit()
	return changed

func _move_focus_to_back() -> void:
	if _focus_area == FocusArea.BACK:
		return
	_focus_area = FocusArea.BACK
	_refresh_focus_visuals()
	cursor_moved.emit()

func _select_category(index: int) -> void:
	var previous_index := _category_index
	_category_index = clampi(index, 0, CATEGORIES.size() - 1)
	_input_focus = InputFocus.LIST
	_set_focus_area(FocusArea.LIST, false)
	_refresh_after_scope_change()
	if _category_index != previous_index:
		cursor_moved.emit()

func _move_category(direction: int) -> void:
	_category_index = posmod(_category_index + direction, CATEGORIES.size())
	_input_focus = InputFocus.LIST
	_set_focus_area(FocusArea.LIST, false)
	_refresh_after_scope_change()
	cursor_moved.emit()

func _set_enemy_filter(filter_id: String) -> void:
	if not CodexPresentationSystemScript.filter_ids().has(filter_id):
		filter_id = "ALL"
	var previous_filter := _enemy_filter_id
	_enemy_filter_id = filter_id
	_input_focus = InputFocus.LIST
	_set_focus_area(FocusArea.LIST, false)
	_refresh_after_scope_change()
	if _enemy_filter_id != previous_filter:
		cursor_moved.emit()

func _set_new_filter_requested(enabled: bool) -> void:
	if enabled == _new_only:
		return
	_toggle_new_filter()

func _toggle_new_filter() -> void:
	var previous_new_only := _new_only
	var category := CATEGORIES[_category_index]
	if _new_only:
		_new_only = false
		_new_snapshot_ids.erase(category)
	elif _rebuild_new_snapshot():
		_new_only = true
	else:
		_new_only = false
	_input_focus = InputFocus.LIST
	_set_focus_area(FocusArea.LIST, false)
	_refresh_after_scope_change()
	if _new_only != previous_new_only:
		cursor_moved.emit()

func _move_enemy_filter(direction: int) -> void:
	var filters := CodexPresentationSystemScript.filter_ids()
	var index := filters.find(_enemy_filter_id)
	_enemy_filter_id = filters[posmod(index + direction, filters.size())]
	_input_focus = InputFocus.LIST
	_set_focus_area(FocusArea.LIST, false)
	_refresh_after_scope_change()
	cursor_moved.emit()

func _selected_index(entries: Array) -> int:
	if entries.is_empty():
		return -1
	var category := CATEGORIES[_category_index]
	var selected_id := String(_selected_ids.get(category, ""))
	if selected_id != "":
		for index in range(entries.size()):
			if String((entries[index] as Dictionary).get("id", "")) == selected_id:
				return index
	return 0

func _move_selection(direction: int) -> void:
	var entries := _visible_entries()
	if entries.is_empty():
		_move_focus_to_back()
		return
	var selected := _selected_index(entries)
	if (direction < 0 and selected <= 0) or (direction > 0 and selected >= entries.size() - 1):
		_move_focus_to_back()
		return
	var next := selected + direction
	var changed := _formal_select(next, true, true, false, true)
	if changed:
		cursor_moved.emit()

func _move_from_back(direction: int) -> void:
	var entries := _visible_entries()
	if entries.is_empty():
		return
	var target_index := 0 if direction > 0 else entries.size() - 1
	var focus_changed := _set_focus_area(FocusArea.LIST, false)
	var changed := _formal_select(target_index, true, false, false, true)
	_refresh_list_and_detail(true, true, true)
	if focus_changed or changed:
		cursor_moved.emit()

func _select_entry(index: int) -> void:
	var entries := _visible_entries()
	if index < 0 or index >= entries.size():
		return
	_input_focus = InputFocus.LIST
	var focus_changed := _set_focus_area(FocusArea.LIST, false)
	var target_item: Dictionary = entries[index] as Dictionary
	var was_new := bool(target_item.get("discovered", false)) and CodexManager.is_new(CATEGORIES[_category_index], String(target_item.get("id", "")))
	var changed := _formal_select(index, true, false, false, true)
	if changed or was_new:
		_refresh_list_and_detail(true, true, true)
	else:
		_refresh_detail_controls()
	if focus_changed or changed:
		cursor_moved.emit()

func _scroll_detail_page(direction: int) -> void:
	if _detail_scroll == null:
		return
	var viewport_height := maxf(1.0, _detail_scroll.size.y)
	var step := maxf(80.0, viewport_height * 0.80)
	_set_detail_scroll_value(float(_detail_scroll.scroll_vertical) + step * float(direction))

func _detail_scroll_range() -> float:
	if _detail_scroll == null:
		return 0.0
	var range := 0.0
	var scrollbar := _detail_scroll.get_v_scroll_bar()
	if scrollbar != null:
		range = maxf(range, float(scrollbar.max_value) - float(scrollbar.page))
	if _detail_info_panel != null:
		range = maxf(range, _detail_info_panel.get_combined_minimum_size().y - _detail_scroll.size.y)
	return maxf(0.0, range)

func _detail_is_scrollable() -> bool:
	return _detail_scroll_range() > 1.0

func _on_codex_changed(category: String, _id: String) -> void:
	if not visible:
		return
	if _local_mark_read_in_progress:
		_refresh_collection()
		_refresh_category_buttons()
		_refresh_new_filter_button()
		return
	_refresh_collection()
	if category == CATEGORIES[_category_index]:
		_prepare_focus_for_external_refresh()
		_refresh()
	else:
		_refresh_category_buttons()

func _on_codex_bulk_changed(_category: String) -> void:
	if visible:
		var was_new_only := _new_only
		if _new_only and not _rebuild_new_snapshot():
			_new_only = false
		_prepare_focus_for_external_refresh()
		_refresh(true, true, was_new_only)

func _prepare_focus_for_external_refresh() -> void:
	var entries := _visible_entries()
	if entries.is_empty():
		if _input_focus == InputFocus.DETAIL:
			_input_focus = InputFocus.LIST
			_focus_area = FocusArea.LIST
			_right_stick_y_value = 0.0
		return
	var selected := _selected_index(entries)
	if selected < 0 or selected >= entries.size() or _detail_scroll == null:
		return
	var current_id := String(_selected_ids.get(CATEGORIES[_category_index], ""))
	var visible_id := String((entries[selected] as Dictionary).get("id", ""))
	if current_id != "" and visible_id != "" and current_id != visible_id:
		_detail_scroll.scroll_vertical = 0

func _on_completion_achieved(scope: String, category: String) -> void:
	var message := "COLLECTION COMPLETE!" if scope == "collection" else "%s COMPLETE!" % _category_completion_label(category)
	_completion_queue.append(message)
	_show_next_completion_notice()

func _show_next_completion_notice() -> void:
	if _completion_banner == null or not visible or _completion_timer > 0.0 or _completion_queue.is_empty():
		return
	_completion_banner.text = _completion_queue.pop_front()
	_completion_banner.visible = true
	_completion_timer = 2.2
	completion_notice_requested.emit(_completion_banner.text)

func _category_completion_label(category: String) -> String:
	var index := CATEGORIES.find(category)
	return CATEGORY_LABELS[index] if index >= 0 else category

func _debug_unlock_all() -> void:
	if CodexManager.debug_unlock_all(false):
		_debug_reset_armed = false
		_debug_status_label.text = "全有効項目を解禁しました"
		debug_save_requested.emit()

func _debug_mark_all_new() -> void:
	if CodexManager.debug_mark_all_new():
		_debug_reset_armed = false
		_debug_status_label.text = "全有効項目をNEWにしました"
		debug_save_requested.emit()

func _debug_reset_codex() -> void:
	if not _debug_reset_armed:
		_debug_reset_armed = true
		_debug_status_label.text = "もう一度押すと図鑑だけリセット"
		return
	if CodexManager.debug_reset_codex():
		_debug_reset_armed = false
		_debug_status_label.text = "図鑑データをリセットしました"
		debug_save_requested.emit()

func _debug_audit() -> void:
	var file_result := CodexManager.write_enemy_audit_report()
	if bool(file_result.get("written", false)):
		_debug_status_label.text = "監査出力: %s / warnings %d" % [String(file_result.get("path", "")), int(file_result.get("warnings", 0))]
		return
	var report := CodexManager.validate_masters()
	var counts: Dictionary = report.get("counts", {}) as Dictionary
	var enemy_counts: Dictionary = counts.get("enemies", {}) as Dictionary
	_debug_status_label.text = "監査: %s / warnings %d" % [str(enemy_counts.get("enabled", "---")), (report.get("warnings", []) as Array).size()]

func _refresh(preserve_detail_scroll: bool = true, preserve_list_scroll: bool = true, reveal_selected: bool = false) -> void:
	_refresh_category_buttons()
	_refresh_collection()
	_refresh_new_filter_button()
	_refresh_enemy_filter_buttons()
	_refresh_list_and_detail(preserve_detail_scroll, preserve_list_scroll, reveal_selected)
	_show_next_completion_notice()

func _refresh_after_scope_change() -> void:
	var category := CATEGORIES[_category_index]
	if _new_only and not _rebuild_new_snapshot():
		_new_only = false
		_new_snapshot_ids.erase(category)
	var entries := _visible_entries()
	var selected := _selected_index(entries)
	if selected >= 0:
		_formal_select(selected, true, false, true, true)
	else:
		_selected_ids.erase(category)
		if _detail_scroll != null:
			_detail_scroll.scroll_vertical = 0
	_refresh(false, true, true)

func _base_visible_entries() -> Array:
	var category := CATEGORIES[_category_index]
	var entries := CodexManager.get_entries_for_ui(category)
	if category == CodexManager.CATEGORY_ENEMY:
		entries = CodexPresentationSystemScript.filtered_entries(entries, _enemy_filter_id)
	return entries

func _rebuild_new_snapshot() -> bool:
	var category := CATEGORIES[_category_index]
	var snapshot: Array = []
	for item in _base_visible_entries():
		if item is Dictionary and bool((item as Dictionary).get("new", false)):
			snapshot.append(String((item as Dictionary).get("id", "")))
	if snapshot.is_empty():
		_new_snapshot_ids.erase(category)
		return false
	_new_snapshot_ids[category] = snapshot
	return true

func _formal_select(index: int, preserve_list_scroll: bool = true, render: bool = true, force_detail_reset: bool = false, reveal_selected: bool = false) -> bool:
	var entries := _visible_entries()
	if index < 0 or index >= entries.size():
		return false
	var item: Dictionary = entries[index] as Dictionary
	var category := CATEGORIES[_category_index]
	var item_id := String(item.get("id", "")).strip_edges()
	if item_id == "":
		return false
	var old_id := String(_selected_ids.get(category, ""))
	var changed := old_id != item_id
	var read_state_changed := false
	_selected_ids[category] = item_id
	if changed or force_detail_reset:
		if _detail_scroll != null:
			_detail_scroll.scroll_vertical = 0
	if bool(item.get("discovered", false)) and CodexManager.is_new(category, item_id):
		_local_mark_read_in_progress = true
		read_state_changed = CodexManager.mark_read(category, item_id)
		_local_mark_read_in_progress = false
	if read_state_changed:
		read_state_save_requested.emit(category, item_id)
	if render:
		_refresh_list_and_detail(not (changed or force_detail_reset), preserve_list_scroll, reveal_selected)
	return changed

func _refresh_category_buttons() -> void:
	for index in range(_category_buttons.size()):
		var category := CATEGORIES[index]
		_category_buttons[index].text = "%s %d/%d" % [CATEGORY_LABELS[index], CodexManager.get_discovered_count(category), CodexManager.get_total_count(category)]
		_apply_category_button_style(_category_buttons[index], index, index == _category_index)
		_category_buttons[index].modulate = Color.WHITE

func _refresh_collection() -> void:
	if _collection_label == null or _comment_log_label == null:
		return
	var summary := CodexManager.get_collection_summary()
	_collection_label.text = "COLLECTION  %d / %d  (%d%%)%s%s" % [int(summary.get("found", 0)), int(summary.get("total", 0)), int(summary.get("ratePercent", 0)), "  COMPLETE!" if bool(summary.get("completed", false)) else "", "  過去にコンプリート済み" if bool(summary.get("completedOnce", false)) and not bool(summary.get("completed", false)) else ""]
	if _collection_bar != null:
		_collection_bar.value = int(summary.get("ratePercent", 0))
	var comment_log: Dictionary = summary.get("commentLog", {}) as Dictionary
	_comment_log_label.text = "COMMENT LOG  %d / %d  （総合収集率には含まれません）" % [int(comment_log.get("found", 0)), int(comment_log.get("total", 0))]

func _refresh_enemy_filter_buttons() -> void:
	if _enemy_filter_row == null:
		return
	_enemy_filter_row.visible = CATEGORIES[_category_index] == CodexManager.CATEGORY_ENEMY
	var filters := CodexPresentationSystemScript.filter_ids()
	for index in range(_enemy_filter_buttons.size()):
		_apply_filter_button_style(_enemy_filter_buttons[index], filters[index] == _enemy_filter_id)
		_enemy_filter_buttons[index].modulate = Color.WHITE

func _refresh_new_filter_button() -> void:
	if _new_filter_button == null or _all_filter_button == null:
		return
	var new_count := CodexManager.get_new_count(CATEGORIES[_category_index])
	_new_filter_button.text = "NEW %d" % new_count if new_count > 0 else "NEW"
	_new_filter_button.disabled = not _new_only and new_count <= 0
	_all_filter_button.disabled = false
	var all_active_style := CommonLightUiStyleScript.create_panel_style(CommonLightUiStyleScript.SUPPORT_PALE if not _new_only else Color(1, 1, 1, 0.82), CommonLightUiStyleScript.SUPPORT_MAIN if not _new_only else CommonLightUiStyleScript.LILAC_BORDER, 2 if not _new_only else 1, 10, 10.0, 5.0)
	var new_active_style := CommonLightUiStyleScript.create_panel_style(CommonLightUiStyleScript.COMBAT_PALE if _new_only else Color(1, 1, 1, 0.82), CommonLightUiStyleScript.COMBAT_MAIN if _new_only else CommonLightUiStyleScript.LILAC_BORDER, 2 if _new_only else 1, 10, 10.0, 5.0)
	_all_filter_button.add_theme_stylebox_override("normal", all_active_style)
	_all_filter_button.add_theme_stylebox_override("hover", CommonLightUiStyleScript.create_panel_style(CommonLightUiStyleScript.SUPPORT_PALE, CommonLightUiStyleScript.SUPPORT_MAIN, 2, 10, 10.0, 5.0))
	_all_filter_button.add_theme_stylebox_override("pressed", all_active_style)
	_all_filter_button.add_theme_stylebox_override("focus", CommonLightUiStyleScript.create_outer_focus_ring_style(CommonLightUiStyleScript.SUPPORT_MAIN))
	_new_filter_button.add_theme_stylebox_override("normal", new_active_style)
	_new_filter_button.add_theme_stylebox_override("hover", CommonLightUiStyleScript.create_panel_style(CommonLightUiStyleScript.COMBAT_PALE, CommonLightUiStyleScript.COMBAT_MAIN, 2, 10, 10.0, 5.0))
	_new_filter_button.add_theme_stylebox_override("pressed", new_active_style)
	_new_filter_button.add_theme_stylebox_override("focus", CommonLightUiStyleScript.create_outer_focus_ring_style(CommonLightUiStyleScript.COMBAT_MAIN))
	_all_filter_button.modulate = Color.WHITE
	_new_filter_button.modulate = Color.WHITE

func _visible_entries() -> Array:
	var category := CATEGORIES[_category_index]
	var entries := _base_visible_entries()
	if not _new_only:
		return entries
	var snapshot_ids: Array = _new_snapshot_ids.get(category, []) as Array
	if snapshot_ids.is_empty():
		return []
	var entries_by_id: Dictionary = {}
	for item in entries:
		if item is Dictionary:
			entries_by_id[String((item as Dictionary).get("id", ""))] = (item as Dictionary).duplicate(true)
	var snapshot_entries: Array = []
	for item_id_value in snapshot_ids:
		var item_id := String(item_id_value)
		if entries_by_id.has(item_id):
			snapshot_entries.append((entries_by_id[item_id] as Dictionary).duplicate(true))
	return snapshot_entries

func _refresh_list_and_detail(preserve_detail_scroll: bool = false, preserve_list_scroll: bool = false, reveal_selected: bool = false) -> void:
	if _list_box == null:
		return
	var saved_list_scroll := _list_scroll.scroll_vertical if preserve_list_scroll and _list_scroll != null else 0
	var saved_detail_scroll := _detail_scroll.scroll_vertical if preserve_detail_scroll and _detail_scroll != null else 0
	if _detail_scroll != null and not preserve_detail_scroll:
		_detail_scroll.scroll_vertical = 0
	var category := CATEGORIES[_category_index]
	var entries := _visible_entries()
	var selected := _selected_index(entries)
	var selected_button: Control = null
	var list_cursor_visible := _focus_area == FocusArea.LIST and _input_focus == InputFocus.LIST
	if selected >= 0:
		_selected_ids[category] = String((entries[selected] as Dictionary).get("id", ""))
	for child in _list_box.get_children():
		_list_box.remove_child(child)
		child.queue_free()
	if entries.is_empty():
		var empty := Label.new()
		empty.text = "このフィルターに該当する項目はありません。"
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		CommonLightUiStyleScript.apply_font(empty, 15 if _compact_layout else 16, false, CommonLightUiStyleScript.TEXT_MUTED)
		_list_box.add_child(empty)
	else:
		for index in range(entries.size()):
			var item: Dictionary = entries[index] as Dictionary
			var button := Button.new()
			var discovered := bool(item.get("discovered", false))
			var label := "？？？"
			if discovered:
				label = _enemy_display_name(item) if category == CodexManager.CATEGORY_ENEMY else _display_name(item)
			else:
				label += "  ?"
			if category == CodexManager.CATEGORY_ENEMY and discovered:
				var preview_entry: Dictionary = item.get("entry", {}) as Dictionary
				var preview_model := CodexPresentationSystemScript.build_enemy_model(item, true, preview_entry, _get_enemy_sources())
				var primary_tag := String(preview_model.get("primaryTag", ""))
				if primary_tag != "":
					label += "  [%s]" % CodexPresentationSystemScript.enemy_tag_label(primary_tag)
			var active_row := list_cursor_visible and index == selected
			var item_id := String(item.get("id", ""))
			button.set_meta("codex_item_id", item_id)
			button.focus_mode = Control.FOCUS_NONE
			button.text = ""
			button.custom_minimum_size = Vector2(0, 36 if _compact_layout else 40)
			button.clip_contents = true
			var weak_row := _focus_area == FocusArea.LIST and _input_focus == InputFocus.DETAIL and index == selected
			_apply_list_button_style(button, _category_index, active_row, weak_row)
			_build_list_item_content(button, label, bool(item.get("new", false)), active_row)
			button.pressed.connect(func() -> void: _select_entry_by_id(item_id))
			_list_box.add_child(button)
			if index == selected:
				selected_button = button
	if _progress_label != null:
		_progress_label.text = "%s  %d / %d" % [CATEGORY_LABELS[_category_index], CodexManager.get_discovered_count(category), CodexManager.get_total_count(category)]
	_render_detail(entries, selected)
	_apply_visual_area_metrics()
	_refresh_detail_controls()
	if preserve_list_scroll and _list_scroll != null:
		_list_scroll.scroll_vertical = saved_list_scroll
	if reveal_selected and selected_button != null:
		call_deferred("_ensure_selected_visible", selected_button)
		if preserve_detail_scroll and _detail_scroll != null:
			_detail_scroll.scroll_vertical = saved_detail_scroll
	elif preserve_list_scroll and _list_scroll != null:
		call_deferred("_restore_codex_scroll", saved_list_scroll, saved_detail_scroll, preserve_detail_scroll)
	elif preserve_detail_scroll and _detail_scroll != null:
		_detail_scroll.scroll_vertical = saved_detail_scroll

func _build_list_item_content(button: Button, item_label: String, has_new: bool, active_row: bool) -> void:
	var content := MarginContainer.new()
	content.name = "CodexListItemContent"
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content.add_theme_constant_override("margin_left", 8)
	content.add_theme_constant_override("margin_right", 10)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(content)

	var row := HBoxContainer.new()
	row.name = "CodexListItemRow"
	row.add_theme_constant_override("separation", 8)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(row)

	var marker := Label.new()
	marker.name = "SelectionMarker"
	marker.custom_minimum_size = Vector2(22, 0)
	marker.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	marker.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	marker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	marker.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	marker.text = "▶" if active_row else ""
	marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	CommonLightUiStyleScript.apply_font(marker, 15 if _compact_layout else 16, true, CommonLightUiStyleScript.COMBAT_MAIN)
	row.add_child(marker)

	var name_label := Label.new()
	name_label.name = "ItemNameLabel"
	name_label.text = item_label
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	name_label.clip_text = true
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	CommonLightUiStyleScript.apply_font(name_label, 15 if _compact_layout else 16, false, CommonLightUiStyleScript.TEXT_PRIMARY)
	row.add_child(name_label)

	button.set_meta("codex_selection_marker", marker)
	button.set_meta("codex_item_name_label", name_label)
	if has_new:
		var badge := PanelContainer.new()
		badge.name = "NewBadge"
		badge.custom_minimum_size = Vector2(54, 22)
		badge.size_flags_horizontal = Control.SIZE_SHRINK_END
		badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		badge.add_theme_stylebox_override("panel", CommonLightUiStyleScript.create_new_badge_style())
		var badge_label := Label.new()
		badge_label.name = "NewBadgeLabel"
		badge_label.text = "NEW"
		badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		badge_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		badge_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		CommonLightUiStyleScript.apply_font(badge_label, 13, true, CommonLightUiStyleScript.NEW_BADGE_TEXT)
		badge.add_child(badge_label)
		row.add_child(badge)
		button.set_meta("codex_new_badge", badge)

func _restore_codex_scroll(list_scroll: int, detail_scroll: int, restore_detail: bool) -> void:
	if _list_scroll != null:
		_list_scroll.scroll_vertical = list_scroll
	if restore_detail and _detail_scroll != null:
		_detail_scroll.scroll_vertical = detail_scroll

func _ensure_selected_visible(button: Control) -> void:
	if _list_scroll == null or not is_instance_valid(button) or not button.is_inside_tree() or not _list_scroll.is_ancestor_of(button):
		return
	_list_scroll.ensure_control_visible(button)
	var viewport_rect := _list_scroll.get_global_rect()
	var row_rect := button.get_global_rect()
	var edge_padding := 2.0
	var target_scroll := float(_list_scroll.scroll_vertical)
	if row_rect.position.y < viewport_rect.position.y + edge_padding:
		target_scroll -= viewport_rect.position.y + edge_padding - row_rect.position.y
	elif row_rect.end.y > viewport_rect.end.y - edge_padding:
		target_scroll += row_rect.end.y - (viewport_rect.end.y - edge_padding)
	var max_scroll := 0.0
	var scrollbar := _list_scroll.get_v_scroll_bar()
	if scrollbar != null:
		max_scroll = maxf(0.0, float(scrollbar.max_value) - float(scrollbar.page))
	elif _list_box != null:
		max_scroll = maxf(0.0, _list_box.get_combined_minimum_size().y - _list_scroll.size.y)
	_list_scroll.scroll_vertical = int(round(clampf(target_scroll, 0.0, max_scroll)))

func _select_entry_by_id(item_id: String) -> void:
	var entries := _visible_entries()
	_input_focus = InputFocus.LIST
	_set_focus_area(FocusArea.LIST, false)
	for index in range(entries.size()):
		if String((entries[index] as Dictionary).get("id", "")) == item_id:
			_select_entry(index)
			return

func _refresh_detail_controls(schedule_deferred: bool = true) -> void:
	var detail_focus := _input_focus == InputFocus.DETAIL
	var scrollable := _detail_is_scrollable()
	if _detail_back_button != null:
		_detail_back_button.text = "一覧へ戻る" if detail_focus else "戻る"
		_detail_back_button.disabled = false
	if _footer_label != null:
		if detail_focus:
			_footer_label.text = "↑↓ スクロール　PgUp/PgDn ページ　右スティック スクロール　Esc 一覧へ"
			_footer_label.add_theme_color_override("font_color", CommonLightUiStyleScript.TEXT_SECONDARY)
		else:
			_footer_label.text = "↑↓ 項目　←→ カテゴリ　Enter: 詳細操作　N NEW　Esc 戻る"
			_footer_label.add_theme_color_override("font_color", CommonLightUiStyleScript.TEXT_SECONDARY if scrollable else CommonLightUiStyleScript.TEXT_MUTED)
	_refresh_focus_visuals()
	if schedule_deferred:
		call_deferred("_refresh_detail_controls_deferred")

func _refresh_detail_controls_deferred() -> void:
	if not is_instance_valid(self) or not visible:
		return
	_refresh_detail_controls(false)

func _render_detail(entries: Array, selected: int) -> void:
	_render_full_detail(entries, selected)

func _render_full_detail(entries: Array, selected: int) -> void:
	if entries.is_empty() or selected < 0 or selected >= entries.size():
		_update_detail_header({}, false, CATEGORIES[_category_index])
		_set_generic_detail_content()
		_detail_title.text = "---"
		_detail_title.add_theme_font_size_override("font_size", 26)
		_detail_title.add_theme_color_override("font_color", Color("#1e293b"))
		_detail_body.text = "このフィルターに該当する項目はありません。"
		_set_detail_image("", CATEGORIES[_category_index])
		return
	var item: Dictionary = entries[selected] as Dictionary
	var discovered := bool(item.get("discovered", false))
	var category := CATEGORIES[_category_index]
	_update_detail_header(item, discovered, category)
	var title := "？？？"
	if discovered:
		title = _enemy_display_name(item) if category == CodexManager.CATEGORY_ENEMY else _display_name(item)
	_detail_title.text = title + ("  NEW" if bool(item.get("new", false)) else "")
	_detail_title.add_theme_font_size_override("font_size", 26)
	_detail_title.add_theme_color_override("font_color", Color("#1e293b"))
	var lines: Array[String] = []
	var image_path := ""
	if not discovered:
		_set_generic_detail_content()
		lines.append("この項目は未発見です。")
		lines.append_array(CodexPresentationSystemScript.undiscovered_hint(category, item))
		_set_detail_image("", category)
		_detail_body.text = "\n\n".join(lines)
		return
	_set_generic_detail_content()
	var entry: Dictionary = item.get("entry", {}) as Dictionary
	var description := String(item.get("description", "")).strip_edges()
	_detail_title.add_theme_font_size_override("font_size", 26)
	_detail_title.add_theme_color_override("font_color", Color("#1e293b"))
	match category:
		CodexManager.CATEGORY_CHARACTER:
			var character_model := CodexPresentationSystemScript.character_profile_model(item, CodexManager.get_master_entries(CodexManager.CATEGORY_WEAPON), _discovered_weapon_ids(), true, _get_enemy_sources())
			_render_character_profile(character_model, entry)
			image_path = String(character_model.get("imagePath", ""))
		CodexManager.CATEGORY_WEAPON:
			var weapon_game_lines := _weapon_game_data_lines(item)
			var weapon_lore := CodexPresentationSystemScript.item_lore_model(item, category, true, CodexManager.get_master_entries(CodexManager.CATEGORY_WEAPON), CodexManager.get_master_entries(CodexManager.CATEGORY_CHARACTER))
			if bool(weapon_lore.get("hasLore", false)):
				_render_item_lore_detail(item, category, weapon_lore, weapon_game_lines)
				return
			lines.append_array(weapon_game_lines)
			image_path = CodexPresentationSystemScript.image_path_for(CodexManager.CATEGORY_WEAPON, item, true)
		CodexManager.CATEGORY_ACCESSORY:
			var accessory_game_lines := _accessory_game_data_lines(item)
			var accessory_lore := CodexPresentationSystemScript.item_lore_model(item, category, true, CodexManager.get_master_entries(CodexManager.CATEGORY_WEAPON), CodexManager.get_master_entries(CodexManager.CATEGORY_CHARACTER))
			if bool(accessory_lore.get("hasLore", false)):
				_render_item_lore_detail(item, category, accessory_lore, accessory_game_lines)
				return
			lines.append_array(accessory_game_lines)
			image_path = CodexPresentationSystemScript.image_path_for(CodexManager.CATEGORY_ACCESSORY, item, true)
		CodexManager.CATEGORY_ENEMY:
			var enemy_model := CodexPresentationSystemScript.build_enemy_model(item, true, entry, _get_enemy_sources())
			_detail_title.add_theme_font_size_override("font_size", 30 if String(enemy_model.get("kind", "")) != "normal" else 26)
			_detail_title.add_theme_color_override("font_color", Color("#be123c") if String(enemy_model.get("kind", "")) == "specialBoss" else (Color("#7c3aed") if String(enemy_model.get("kind", "")) == "boss" else Color("#1e293b")))
			var enemy_game_lines := _enemy_game_data_lines(item, enemy_model, entry)
			if bool(enemy_model.get("hasLore", false)):
				_render_item_lore_detail(item, category, enemy_model, enemy_game_lines)
				return
			lines.append_array(enemy_game_lines)
			image_path = String(enemy_model.get("imagePath", ""))
		CodexManager.CATEGORY_COMMENT:
			var comment_model := CodexPresentationSystemScript.comment_lore_model(item, entry, true)
			_render_comment_detail(item, comment_model)
			return
	if category == CodexManager.CATEGORY_CHARACTER:
		_set_character_structured_detail_visible(true)
		_set_character_overview_image(image_path)
		return
	_set_detail_image(image_path, category)
	_detail_body.text = "\n\n".join(lines)

func _render_comment_detail(item: Dictionary, comment_model: Dictionary) -> void:
	var render_model := comment_model.duplicate(true)
	if not bool(render_model.get("hasLore", false)):
		render_model["archiveTitle"] = "COMMENT ARCHIVE"
		render_model["archiveParagraphs"] = ["記録文章は準備中です。"]
	_render_item_lore_detail(item, CodexManager.CATEGORY_COMMENT, render_model, _comment_game_data_lines(comment_model))

func _comment_game_data_lines(model: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	var stage_labels := model.get("stageLabels", []) as Array
	var stage_text := _join_strings(stage_labels, "、", "")
	if stage_text != "":
		lines.append("出現枠：%s" % stage_text)
	var effect_model: Dictionary = model.get("effectModel", {}) as Dictionary
	_append_comment_effect_block(lines, "通常効果", effect_model.get("normal", {}))
	if bool(model.get("hasHeart", false)):
		_append_comment_effect_block(lines, "♡効果", effect_model.get("heart", {}))
	_append_comment_effect_block(lines, "HARD時", effect_model.get("hard", {}))
	lines.append("出現回数：%d" % int(model.get("appearedCount", 0)))
	lines.append("選択回数：%d" % int(model.get("selectedCount", 0)))
	if bool(model.get("hasHeart", false)):
		lines.append("♡選択回数：%d" % int(model.get("heartCount", 0)))
	if model.has("selectionRate"):
		lines.append("選択率：%.1f%%" % float(model.get("selectionRate", 0.0)))
	return lines

func _enemy_game_data_lines(item: Dictionary, enemy_model: Dictionary, entry: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	var stage_text := _join_strings(enemy_model.get("stageLabels", []), "、", "")
	if stage_text != "":
		lines.append("出現枠：%s" % stage_text)
	for condition_value in enemy_model.get("conditionLines", enemy_model.get("conditions", [])) as Array:
		var condition := String(condition_value).strip_edges()
		if condition != "":
			lines.append(condition)
	lines.append("撃破数：%d" % int(enemy_model.get("killCount", 0)))
	var durability_rating: Dictionary = enemy_model.get("durabilityRating", {}) as Dictionary
	var speed_rating: Dictionary = enemy_model.get("speedRating", {}) as Dictionary
	if not durability_rating.is_empty() or not speed_rating.is_empty():
		lines.append("基本特性")
		if not durability_rating.is_empty():
			lines.append("耐久：%s" % String(durability_rating.get("label", "---")))
		if not speed_rating.is_empty():
			lines.append("速度：%s" % String(speed_rating.get("label", "---")))
	var attack_type_labels: Array = enemy_model.get("attackTypeLabels", []) as Array
	if not attack_type_labels.is_empty():
		lines.append("攻撃タイプ：%s" % _join_strings(attack_type_labels, " / ", "---"))
	if String(enemy_model.get("kind", "")) != "normal":
		var attack_lines: Array = enemy_model.get("attackLines", []) as Array
		if not attack_lines.is_empty():
			lines.append("主な攻撃：%s" % _join_strings(attack_lines, " / ", "---"))
		var summon_ids: Array = enemy_model.get("summonIds", []) as Array
		if not summon_ids.is_empty():
			var summon_names: Array[String] = []
			for summon_id in summon_ids:
				summon_names.append(_related_enemy_name(String(summon_id)))
			lines.append("召喚・関連敵：%s" % _join_strings(summon_names, " / ", "---"))
	var behavior_rows: Array = enemy_model.get("behaviorTagRows", []) as Array
	if not behavior_rows.is_empty():
		var behavior_labels: Array[String] = []
		for behavior_value in behavior_rows:
			if behavior_value is Dictionary:
				behavior_labels.append(String((behavior_value as Dictionary).get("label", "")))
		lines.append("特徴タグ：%s" % _join_strings(behavior_labels, " / ", "---"))
	if String(enemy_model.get("kind", "")) != "normal":
		var boss_record := CodexPresentationSystemScript.boss_record_model(item, entry, _difficulty_progress, _get_enemy_sources())
		lines.append("BOSS STATUS")
		for state_value in boss_record.get("states", []) as Array:
			if state_value is Dictionary:
				var state := state_value as Dictionary
				lines.append("%s: %s" % [String(state.get("label", "")), String(state.get("status", "---"))])
		var related_names: Array[String] = []
		for related_id in boss_record.get("relatedEnemyIds", []) as Array:
			related_names.append(_related_enemy_name(String(related_id)))
		if not related_names.is_empty():
			lines.append("RELATED: %s" % ", ".join(related_names))
	return lines

func _weapon_game_data_lines(item: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	var description := String(item.get("description", "")).strip_edges()
	if description != "":
		lines.append("概要：%s" % description)
	if not bool(item.get("isEvolved", false)):
		var max_level_value: Variant = item.get("maxLevel", item.get("maxLv", null))
		if max_level_value is int or max_level_value is float:
			lines.append("最大Lv：%d" % int(max_level_value))
	var weapon_attribute := String(item.get("attribute", item.get("weaponType", ""))).strip_edges()
	if weapon_attribute != "":
		lines.append("区分：%s" % weapon_attribute)
	var performance := CodexPresentationSystemScript.weapon_performance_model(item, _is_initial_weapon(item))
	_append_performance_lines(lines, performance)
	var weapon_model := _weapon_detail(item)
	lines.append_array(weapon_model.get("lines", []) as Array)
	return lines

func _accessory_game_data_lines(item: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	var description := String(item.get("description", "")).strip_edges()
	if description != "":
		lines.append("効果：%s" % description)
	var accessory_max_level: Variant = item.get("maxLevel", item.get("maxLv", null))
	if accessory_max_level is int or accessory_max_level is float:
		lines.append("最大Lv：%d" % int(accessory_max_level))
	var accessory_performance := CodexPresentationSystemScript.accessory_performance_model(item)
	_append_performance_lines(lines, accessory_performance)
	lines.append_array(_accessory_detail(item).get("lines", []) as Array)
	return lines

func _render_item_lore_detail(item: Dictionary, category: String, lore_model: Dictionary, game_lines: Array[String]) -> void:
	_set_item_structured_detail_visible(true)
	var classification := String(lore_model.get("classificationLabel", "")).strip_edges()
	var classification_labels: Array = lore_model.get("classificationLabels", []) as Array
	if classification_labels.is_empty() and classification != "":
		classification_labels = [classification]
	_set_detail_badges(classification_labels)
	var lore_visual: Dictionary = lore_model.get("codexVisual", {}) as Dictionary
	if category == CodexManager.CATEGORY_COMMENT:
		_set_comment_illustration(item, lore_model)
	else:
		_set_image_in_holder(_item_visual_holder, String(lore_model.get("imagePath", "")), category, 6.0 if category == CodexManager.CATEGORY_ACCESSORY else 12.0, lore_visual)
	_set_character_card_body(_item_comment_effect_card, "", false)
	for card_value in _item_card_by_id.values():
		var card := card_value as PanelContainer
		if card == null:
			continue
		_set_character_card_body(card, "", false)
		card.set_meta("item_lore_span", 1)
	var raw_cards: Variant = lore_model.get("cards", [])
	if raw_cards is Array:
		for card_value in raw_cards as Array:
			if not card_value is Dictionary:
				continue
			var card_model := card_value as Dictionary
			var card_id := String(card_model.get("id", ""))
			var card := _ensure_item_lore_card(card_id)
			if card == null:
				continue
			var heading := card.get_meta("character_card_heading", null) as Label
			if heading != null:
				heading.text = String(card_model.get("title", ""))
			_set_character_card_body(card, String(card_model.get("text", "")), true)
			card.set_meta("item_lore_span", int(card_model.get("span", 1)))
	if category == CodexManager.CATEGORY_COMMENT:
		var effect_summary := String(lore_model.get("effectSummary", "")).strip_edges()
		if effect_summary == "":
			effect_summary = "効果情報は準備中です。"
		_set_character_card_body(_item_comment_effect_card, effect_summary, true)
	var archive_title := String(lore_model.get("archiveTitle", "")).strip_edges()
	var archive_paragraphs: Array = lore_model.get("archiveParagraphs", []) as Array
	var archive_heading := _item_archive_card.get_meta("character_card_heading", null) as Label
	if archive_heading != null:
		archive_heading.text = archive_title
	_set_character_card_body(_item_archive_card, "\n\n".join(archive_paragraphs), archive_title != "" and not archive_paragraphs.is_empty())
	_set_character_card_body(_item_game_data_card, "\n\n".join(game_lines), not game_lines.is_empty())
	_apply_item_profile_layout()
	_apply_visual_area_metrics()
	_refresh_detail_controls()

func _append_performance_lines(lines: Array[String], model: Dictionary) -> void:
	if model.is_empty():
		return
	var standard_label := String(model.get("standardLabel", "")).strip_edges()
	if standard_label != "":
		lines.append("標準性能：%s" % standard_label)
	var basic_stats: Array = model.get("basicStats", []) as Array
	if not basic_stats.is_empty():
		lines.append("基本性能")
		for row_value in basic_stats:
			if row_value is Dictionary:
				var row: Dictionary = row_value as Dictionary
				lines.append("%s：%s" % [String(row.get("label", row.get("key", "---"))), String(row.get("text", "---"))])
	var performance_stats: Array = model.get("performanceStats", []) as Array
	if not performance_stats.is_empty():
		lines.append("性能")
		for row_value in performance_stats:
			if row_value is Dictionary:
				var row: Dictionary = row_value as Dictionary
				lines.append("%s：%s" % [String(row.get("label", row.get("key", "---"))), String(row.get("text", "---"))])
	if bool(model.get("showLevels", false)):
		lines.append("LEVEL")
		for level_value in model.get("levelRows", []) as Array:
			if not level_value is Dictionary:
				continue
			var level_row: Dictionary = level_value as Dictionary
			var stats: Array = level_row.get("stats", []) as Array
			var stat_text: Array[String] = []
			for row_value in stats:
				if row_value is Dictionary:
					var row: Dictionary = row_value as Dictionary
					stat_text.append("%s：%s" % [String(row.get("label", row.get("key", "---"))), String(row.get("text", "---"))])
			if not stat_text.is_empty():
				lines.append("Lv%d  %s" % [int(level_row.get("level", 0)), " / ".join(stat_text)])
	for special_value in model.get("specials", []) as Array:
		var special := String(special_value).strip_edges()
		if special != "":
			lines.append("・%s" % special)

func _append_comment_effect_lines(lines: Array[String], model_value: Variant) -> void:
	if not model_value is Dictionary:
		return
	var model: Dictionary = model_value as Dictionary
	_append_comment_effect_block(lines, "通常効果", model.get("normal", {}))
	_append_comment_effect_block(lines, "♡効果", model.get("heart", {}))
	_append_comment_effect_block(lines, "HARD時", model.get("hard", {}))

func _append_comment_effect_block(lines: Array[String], heading: String, block_value: Variant) -> void:
	if not block_value is Dictionary:
		return
	var block: Dictionary = block_value as Dictionary
	if block.is_empty():
		return
	var description := String(block.get("description", "")).strip_edges()
	var block_lines: Array = block.get("lines", []) as Array
	var block_params: Array = block.get("params", []) as Array
	if description == "" and block_lines.is_empty() and block_params.is_empty():
		return
	lines.append(heading)
	if description != "":
		lines.append(description)
	for line_value in block_lines:
		lines.append(String(line_value))
	for row_value in block_params:
		if row_value is Dictionary:
			var row: Dictionary = row_value as Dictionary
			lines.append("%s：%s" % [String(row.get("label", row.get("key", "---"))), String(row.get("text", "---"))])

func _is_initial_weapon(item: Dictionary) -> bool:
	return String(item.get("id", "")) in ["ban_hammer", "superchat_shot", "comment_boomerang", "moderator_shield", "fansa_baton", "tsuri_thumbnail_rod"]

func _weapon_detail(item: Dictionary) -> Dictionary:
	var lines: Array[String] = []
	var weapons := CodexManager.get_master_entries(CodexManager.CATEGORY_WEAPON)
	var gifts := CodexManager.get_master_entries(CodexManager.CATEGORY_ACCESSORY)
	var catalog := CodexPresentationSystemScript.evolution_catalog(weapons, gifts, _discovered_weapon_ids())
	var item_id := String(item.get("id", ""))
	for recipe_value in catalog:
		var recipe: Dictionary = recipe_value as Dictionary
		if String(recipe.get("baseWeaponId", "")) == item_id:
			if bool(recipe.get("evolvedDiscovered", false)):
				lines.append("進化先：%s → %s" % [String(recipe.get("baseDisplayName", "")), String(recipe.get("evolvedDisplayName", ""))])
				if String(recipe.get("requiredCharacterId", "")) != "":
					lines.append("必要キャラクター：%s" % _character_name(String(recipe.get("requiredCharacterId", ""))))
				lines.append("必要武器Lv：%d" % int(recipe.get("requiredWeaponLevel", 1)))
				lines.append("本人使用時：%s" % _join_strings(recipe.get("selfRequirements", []), " ＋ ", "---"))
				lines.append("その他キャラクター：%s" % _join_strings(recipe.get("otherRequirements", []), " ＋ ", "---"))
				if bool(recipe.get("matchingCharacterBypassesAdditionalRequirements", false)):
					lines.append("本人使用時は追加条件不要")
			else:
				lines.append("進化先：？？？？？")
				lines.append("進化条件：？？？？？")
		if String(recipe.get("evolvedWeaponId", "")) == item_id:
			lines.append("進化元：%s" % String(recipe.get("baseDisplayName", "---")))
	return {"lines": lines}

func _accessory_detail(item: Dictionary) -> Dictionary:
	var lines: Array[String] = []
	var guides := CodexPresentationSystemScript.accessory_reverse_guides(CodexManager.get_master_entries(CodexManager.CATEGORY_WEAPON), CodexManager.get_master_entries(CodexManager.CATEGORY_ACCESSORY), _discovered_weapon_ids())
	for guide_value in guides:
		var guide: Dictionary = guide_value as Dictionary
		if String(guide.get("accessoryId", "")) != String(item.get("id", "")):
			continue
		var base_name := String(guide.get("baseDisplayName", "")) if bool(guide.get("baseDiscovered", false)) else "？？？"
		var evolved_name := String(guide.get("evolvedDisplayName", "？？？？？"))
		lines.append("進化に使用：%s → %s（必要%s）" % [base_name, evolved_name, _level_label(guide.get("requiredLevel", 1))])
		if bool(guide.get("matchingCharacterBypassesAdditionalRequirements", false)) and String(guide.get("requiredCharacterId", "")) != "":
			lines.append("※%s使用時は不要" % _character_name(String(guide.get("requiredCharacterId", ""))))
	return {"lines": lines}

func _discovered_weapon_ids() -> Array[String]:
	var ids: Array[String] = []
	for item in CodexManager.get_entries_for_ui(CodexManager.CATEGORY_WEAPON):
		if bool((item as Dictionary).get("discovered", false)):
			ids.append(String((item as Dictionary).get("id", "")))
	return ids

func _character_name(id: String) -> String:
	for item in CodexManager.get_master_entries(CodexManager.CATEGORY_CHARACTER):
		if String((item as Dictionary).get("id", "")) == id:
			return _display_name(item as Dictionary)
	return id

func _set_detail_image(path: String, display_category: String = "") -> void:
	_set_image_in_holder(_detail_image_holder, path, display_category, 0.0)

func _set_comment_illustration(master: Dictionary, comment_model: Dictionary) -> void:
	if _item_visual_holder == null:
		return
	var path := String(comment_model.get("imagePath", "")).strip_edges()
	if path == "":
		path = CodexPresentationSystemScript.image_path_for(CodexManager.CATEGORY_COMMENT, master, true)
	var visual := comment_model.get("codexVisual", {}) as Dictionary
	_set_image_in_holder(_item_visual_holder, path, CodexManager.CATEGORY_COMMENT, _comment_visual_inset(), visual)
	_apply_comment_illustration_metrics()

func _comment_visual_inset() -> float:
	if _item_visual_holder == null or _item_visual_holder.size.y <= 0.0:
		return 12.0
	return maxf(12.0, floorf(_item_visual_holder.size.y * 0.10))

func _on_item_visual_holder_resized() -> void:
	_apply_comment_illustration_metrics()

func _apply_comment_illustration_metrics() -> void:
	if _item_visual_holder == null or not _is_item_structured_detail_active():
		return
	if _category_index < 0 or _category_index >= CATEGORIES.size() or CATEGORIES[_category_index] != CodexManager.CATEGORY_COMMENT:
		return
	if _item_visual_holder.get_child_count() <= 0:
		return
	var rect := _item_visual_holder.get_child(0) as TextureRect
	if rect == null:
		return
	var inset := _comment_visual_inset()
	var raw_offset_x: Variant = rect.get_meta("codex_visual_offset_x", 0.0)
	var raw_offset_y: Variant = rect.get_meta("codex_visual_offset_y", 0.0)
	var offset_x := float(raw_offset_x) if raw_offset_x is int or raw_offset_x is float else 0.0
	var offset_y := float(raw_offset_y) if raw_offset_y is int or raw_offset_y is float else 0.0
	if not is_finite(offset_x):
		offset_x = 0.0
	if not is_finite(offset_y):
		offset_y = 0.0
	offset_x = clampf(offset_x, -1.0, 1.0)
	offset_y = clampf(offset_y, -1.0, 1.0)
	var dx := offset_x * _item_visual_holder.size.x
	var dy := offset_y * _item_visual_holder.size.y
	rect.offset_left = inset + dx
	rect.offset_top = inset + dy
	rect.offset_right = -inset + dx
	rect.offset_bottom = -inset + dy
	var raw_scale: Variant = rect.get_meta("codex_visual_scale", 1.0)
	var scale := float(raw_scale) if raw_scale is int or raw_scale is float else 1.0
	if not is_finite(scale):
		scale = 1.0
	scale = clampf(scale, 0.5, 2.5)
	rect.pivot_offset = _item_visual_holder.size * 0.5
	rect.scale = Vector2(scale, scale)

func _set_character_overview_image(path: String) -> void:
	var inset := 8.0 if _compact_layout else 12.0
	_set_image_in_holder(_character_overview_image_holder, path, CodexManager.CATEGORY_CHARACTER, inset)

func _clear_image_holder(holder: Control) -> void:
	if holder == null:
		return
	for child in holder.get_children():
		holder.remove_child(child)
		child.queue_free()

func _set_image_in_holder(holder: Control, path: String, display_category: String = "", inset: float = 0.0, visual: Dictionary = {}) -> void:
	if holder == null:
		return
	_clear_image_holder(holder)
	var safe_path := CodexPresentationSystemScript.safe_resource_path(path)
	var texture: Texture2D = null
	if safe_path != "":
		texture = load(safe_path) as Texture2D
	if texture == null:
		var fallback := Label.new()
		fallback.text = "?"
		fallback.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		fallback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		fallback.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		fallback.add_theme_font_size_override("font_size", 44)
		fallback.add_theme_color_override("font_color", Color("#64748b"))
		holder.add_child(fallback)
		return
	var resolved_category := display_category if display_category != "" else CATEGORIES[_category_index]
	if resolved_category == CodexManager.CATEGORY_CHARACTER:
		texture = _character_content_texture(safe_path, texture)
	elif resolved_category == CodexManager.CATEGORY_COMMENT:
		texture = _comment_content_texture(safe_path, texture)
	var rect := TextureRect.new()
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.clip_contents = true
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rect.offset_left = inset
	rect.offset_top = inset
	rect.offset_right = -inset
	rect.offset_bottom = -inset
	rect.texture = texture
	var raw_visual_scale: Variant = visual.get("scale", 1.0)
	var raw_visual_offset_x: Variant = visual.get("offsetX", 0.0)
	var raw_visual_offset_y: Variant = visual.get("offsetY", 0.0)
	var visual_scale := clampf(float(raw_visual_scale), 0.5, 2.5) if raw_visual_scale is int or raw_visual_scale is float else 1.0
	var visual_offset_x := clampf(float(raw_visual_offset_x), -1.0, 1.0) if raw_visual_offset_x is int or raw_visual_offset_x is float else 0.0
	var visual_offset_y := clampf(float(raw_visual_offset_y), -1.0, 1.0) if raw_visual_offset_y is int or raw_visual_offset_y is float else 0.0
	rect.set_meta("codex_visual_scale", visual_scale)
	rect.set_meta("codex_visual_offset_x", visual_offset_x)
	rect.set_meta("codex_visual_offset_y", visual_offset_y)
	if is_finite(visual_scale) and visual_scale != 1.0:
		rect.pivot_offset = holder.size * 0.5
		rect.scale = Vector2(visual_scale, visual_scale)
	if resolved_category != CodexManager.CATEGORY_COMMENT and is_finite(visual_offset_x) and is_finite(visual_offset_y):
		rect.position += Vector2(visual_offset_x * holder.size.x, visual_offset_y * holder.size.y)
	holder.add_child(rect)

func _character_content_texture(path: String, source_texture: Texture2D) -> Texture2D:
	if _character_content_cache.has(path):
		return _character_content_cache[path] as Texture2D
	var source_image := source_texture.get_image()
	if source_image == null or source_image.is_empty():
		_character_content_cache[path] = source_texture
		return source_texture
	var used_rect := source_image.get_used_rect()
	if used_rect.size.x <= 0 or used_rect.size.y <= 0:
		_character_content_cache[path] = source_texture
		return source_texture
	var padding_x := maxi(2, ceili(float(used_rect.size.x) * CHARACTER_CONTENT_PADDING_RATIO))
	var padding_y := maxi(2, ceili(float(used_rect.size.y) * CHARACTER_CONTENT_PADDING_RATIO))
	var region_start := Vector2i(maxi(0, used_rect.position.x - padding_x), maxi(0, used_rect.position.y - padding_y))
	var region_end := Vector2i(mini(source_image.get_width(), used_rect.end.x + padding_x), mini(source_image.get_height(), used_rect.end.y + padding_y))
	var content_region := Rect2i(region_start, region_end - region_start)
	if content_region.size.x <= 0 or content_region.size.y <= 0:
		_character_content_cache[path] = source_texture
		return source_texture
	var atlas := AtlasTexture.new()
	atlas.atlas = source_texture
	atlas.region = Rect2(content_region)
	_character_content_cache[path] = atlas
	return atlas

func _comment_content_texture(path: String, source_texture: Texture2D) -> Texture2D:
	if _comment_content_cache.has(path):
		return _comment_content_cache[path] as Texture2D
	var source_image := source_texture.get_image()
	if source_image == null or source_image.is_empty():
		_comment_content_cache[path] = source_texture
		return source_texture
	var used_rect := source_image.get_used_rect()
	if used_rect.size.x <= 0 or used_rect.size.y <= 0:
		_comment_content_cache[path] = source_texture
		return source_texture
	var padding_x := maxi(2, ceili(float(used_rect.size.x) * COMMENT_CONTENT_PADDING_RATIO))
	var padding_y := maxi(2, ceili(float(used_rect.size.y) * COMMENT_CONTENT_PADDING_RATIO))
	var region_start := Vector2i(maxi(0, used_rect.position.x - padding_x), maxi(0, used_rect.position.y - padding_y))
	var region_end := Vector2i(mini(source_image.get_width(), used_rect.end.x + padding_x), mini(source_image.get_height(), used_rect.end.y + padding_y))
	var content_region := Rect2i(region_start, region_end - region_start)
	if content_region.size.x <= 0 or content_region.size.y <= 0:
		_comment_content_cache[path] = source_texture
		return source_texture
	var atlas := AtlasTexture.new()
	atlas.atlas = source_texture
	atlas.region = Rect2(content_region)
	_comment_content_cache[path] = atlas
	return atlas

func _display_name(item: Dictionary) -> String:
	var name := String(item.get("displayName", "")).strip_edges()
	return name if name != "" else String(item.get("id", "?"))

func _enemy_display_name(item: Dictionary) -> String:
	return CodexPresentationSystemScript.canonical_enemy_display_name(item, _get_enemy_sources())

func _join_strings(value: Variant, separator: String, fallback: String) -> String:
	if not value is Array or (value as Array).is_empty():
		return fallback
	var values: Array[String] = []
	for item in value as Array:
		values.append(String(item))
	return separator.join(values) if not values.is_empty() else fallback

func _level_label(value: Variant) -> String:
	return "LvMAX" if str(value).to_lower() == "max" else "Lv%d" % int(value)

func _number_with_commas(value: int) -> String:
	var raw := str(maxi(0, value))
	var result := ""
	var count := 0
	for index in range(raw.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = raw.substr(index, 1) + result
		count += 1
	return result

func _related_enemy_name(enemy_id: String) -> String:
	for item in CodexManager.get_entries_for_ui(CodexManager.CATEGORY_ENEMY):
		if String((item as Dictionary).get("id", "")) != enemy_id:
			continue
		return _enemy_display_name(item as Dictionary) if bool((item as Dictionary).get("discovered", false)) else "???"
	return "???"
