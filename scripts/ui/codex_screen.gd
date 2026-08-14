extends Control

## Codex overlay.  Rendering and input live here; discovery state remains in
## CodexManager and read-only display rules live in CodexPresentationSystem.

const CodexPresentationSystemScript := preload("res://scripts/systems/codex_presentation_system.gd")
const CommonLightUiStyleScript := preload("res://scripts/ui/common_light_ui_style.gd")
const FRONT_SCREEN_BACKGROUND_PATH := "res://assets/title/title_back.png"
const CODEX_HEADER_ICON_PATH := "res://assets/generated/codex_icons_v1/codex_header_icon.png"
const CODEX_HEADER_ICON_PADDING_RATIO := 0.02
const NORMAL_LAYOUT_MIN_WIDTH := 1400.0
const CHARACTER_CONTENT_PADDING_RATIO := 0.04

signal closed(origin: String)
signal debug_save_requested
signal completion_notice_requested(text: String)
signal cursor_moved
signal confirm_requested
signal cancel_requested

enum FocusArea {
	LIST,
	BACK
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
var _detail_body: Label
var _detail_image_frame: PanelContainer
var _detail_image_holder: Control
var _detail_nav_row: HBoxContainer
var _detail_prev_button: Button
var _detail_next_button: Button
var _detail_back_button: Button
var _detail_hint_label: Label
var _footer_label: Label
var _debug_row: HBoxContainer
var _debug_status_label: Label
var _debug_reset_armed := false
var _completion_banner: Label
var _completion_queue: Array[String] = []
var _completion_timer := 0.0
var _enemy_sources: Dictionary = {}
var _detail_mode := false
var _open_options: Dictionary = {}
var _new_snapshot_ids: Dictionary = {}
var _local_mark_read_in_progress := false
var _analog_x_latched := false
var _analog_y_latched := false
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
var _detail_focus_ring: Panel
var _footer_panel: PanelContainer
var _debug_overlay: PanelContainer
var _layout_spacers: Array[Control] = []
var _compact_layout := false
var _last_layout_size := Vector2(-1.0, -1.0)
var _character_content_cache: Dictionary = {}
var _focus_area := FocusArea.LIST

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
	if _completion_banner == null:
		return
	if _completion_timer > 0.0:
		_completion_timer = maxf(0.0, _completion_timer - delta)
		if _completion_timer <= 0.0:
			_completion_banner.visible = false
			_show_next_completion_notice()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and _built:
		_apply_layout_metrics()

func open_screen(origin: String = "title", difficulty_progress: Dictionary = {}, options: Dictionary = {}) -> void:
	_origin = origin
	_difficulty_progress = difficulty_progress.duplicate(true)
	_open_options = options.duplicate(true)
	_detail_mode = false
	_focus_area = FocusArea.LIST
	_analog_x_latched = false
	_analog_y_latched = false
	_new_snapshot_ids.clear()
	_apply_open_options(options)
	if _new_only and not _rebuild_new_snapshot():
		_new_only = false
	show()
	_refresh()
	_confirm_current_selection()
	_refresh_list_and_detail(true, false)

func bind_difficulty_progress(difficulty_progress: Dictionary) -> void:
	_difficulty_progress = difficulty_progress.duplicate(true)
	if visible:
		_refresh()

func close_screen() -> void:
	if not visible:
		return
	_detail_mode = false
	_focus_area = FocusArea.LIST
	_new_snapshot_ids.clear()
	hide()
	closed.emit(_origin)

func hide_screen() -> void:
	hide()

func _get_enemy_sources() -> Dictionary:
	if _enemy_sources.is_empty():
		_enemy_sources = CodexPresentationSystemScript.load_sources()
	return _enemy_sources

func _legacy_handle_input(event: InputEvent) -> bool:
	return handle_input(event)

func handle_input(event: InputEvent) -> bool:
	if not visible:
		return false
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if not mouse.pressed:
			return false
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
	var filter_direction := 0
	var detail_direction := 0
	var select := false
	var back := false
	var toggle_new := false
	if event is InputEventKey:
		var key := event as InputEventKey
		if not key.pressed or key.echo:
			return false
		back = key.keycode == KEY_ESCAPE or key.keycode == KEY_BACKSPACE
		if _detail_mode:
			detail_direction = -1 if key.keycode == KEY_LEFT else (1 if key.keycode == KEY_RIGHT else 0)
			if detail_direction == 0:
				direction = -1 if key.keycode == KEY_UP else (1 if key.keycode == KEY_DOWN else 0)
			filter_direction = -1 if key.keycode == KEY_PAGEUP else (1 if key.keycode == KEY_PAGEDOWN else 0)
		else:
			category_direction = -1 if key.keycode == KEY_LEFT else (1 if key.keycode == KEY_RIGHT else 0)
			direction = -1 if key.keycode == KEY_UP else (1 if key.keycode == KEY_DOWN else 0)
			filter_direction = -1 if key.keycode == KEY_PAGEUP else (1 if key.keycode == KEY_PAGEDOWN else 0)
		toggle_new = key.keycode == KEY_N
		select = key.keycode == KEY_ENTER or key.keycode == KEY_SPACE or key.is_action_pressed("ui_accept")
	elif event is InputEventJoypadButton:
		var pad := event as InputEventJoypadButton
		if not pad.pressed:
			return false
		back = pad.button_index == JOY_BUTTON_B
		select = pad.button_index == JOY_BUTTON_A
		if _detail_mode:
			detail_direction = -1 if pad.button_index in [JOY_BUTTON_LEFT_SHOULDER, JOY_BUTTON_DPAD_LEFT] else (1 if pad.button_index in [JOY_BUTTON_RIGHT_SHOULDER, JOY_BUTTON_DPAD_RIGHT] else 0)
			direction = -1 if pad.button_index == JOY_BUTTON_DPAD_UP else (1 if pad.button_index == JOY_BUTTON_DPAD_DOWN else 0)
		else:
			category_direction = -1 if pad.button_index in [JOY_BUTTON_LEFT_SHOULDER, JOY_BUTTON_DPAD_LEFT] else (1 if pad.button_index in [JOY_BUTTON_RIGHT_SHOULDER, JOY_BUTTON_DPAD_RIGHT] else 0)
			direction = -1 if pad.button_index == JOY_BUTTON_DPAD_UP else (1 if pad.button_index == JOY_BUTTON_DPAD_DOWN else 0)
		toggle_new = pad.button_index == JOY_BUTTON_Y
	else:
		return false
	if back:
		_cancel_current_layer()
		return true
	if _detail_mode:
		if detail_direction != 0:
			_move_detail(detail_direction)
			return true
		if filter_direction != 0 or direction != 0:
			_scroll_detail(filter_direction if filter_direction != 0 else direction)
			return true
		return select
	if toggle_new:
		_toggle_new_filter()
		return true
	if filter_direction != 0 and CATEGORIES[_category_index] == CodexManager.CATEGORY_ENEMY:
		_move_enemy_filter(filter_direction)
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
		_select_entry(_selected_index(_visible_entries()))
		return true
	return false

func _handle_analog_motion(event: InputEventJoypadMotion) -> bool:
	var value := float(event.axis_value)
	var deadzone := 0.35
	if event.axis == JOY_AXIS_LEFT_X:
		if absf(value) < deadzone:
			_analog_x_latched = false
			return false
		if _analog_x_latched:
			return true
		_analog_x_latched = true
		if _detail_mode:
			_move_detail(-1 if value < 0.0 else 1)
		elif _focus_area == FocusArea.BACK:
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
		if _detail_mode:
			_scroll_detail(-1 if value < 0.0 else 1)
		elif _focus_area == FocusArea.BACK:
			_move_from_back(-1 if value < 0.0 else 1)
		else:
			_move_selection(-1 if value < 0.0 else 1)
		return true
	return false

func _build_ui() -> void:
	if _built:
		return
	_built = true
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var background := TextureRect.new()
	background.name = "FullScreenBackground"
	background.texture = load(FRONT_SCREEN_BACKGROUND_PATH) as Texture2D
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.z_index = -20
	add_child(background)
	var wash := ColorRect.new()
	wash.name = "LightBackgroundWash"
	wash.color = Color(0.98, 0.96, 1.0, 0.80)
	wash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wash.z_index = -19
	add_child(wash)
	var cool_wash := ColorRect.new()
	cool_wash.name = "CoolBackgroundWash"
	cool_wash.color = Color(0.82, 0.94, 1.0, 0.10)
	cool_wash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cool_wash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cool_wash.z_index = -18
	add_child(cool_wash)

	_layout_margin = MarginContainer.new()
	_layout_margin.name = "SafeAreaMargin"
	_layout_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_layout_margin)
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
	var detail_margin := MarginContainer.new()
	detail_margin.add_theme_constant_override("margin_left", 16)
	detail_margin.add_theme_constant_override("margin_top", 10)
	detail_margin.add_theme_constant_override("margin_right", 16)
	detail_margin.add_theme_constant_override("margin_bottom", 10)
	_detail_panel.add_child(detail_margin)
	_detail_focus_ring = Panel.new()
	_detail_focus_ring.name = "DetailFocusRing"
	_detail_focus_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_detail_focus_ring.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_detail_focus_ring.z_index = 20
	_detail_focus_ring.visible = false
	_detail_panel.add_child(_detail_focus_ring)
	_detail_shell = VBoxContainer.new()
	_detail_shell.name = "DetailShell"
	_detail_shell.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_detail_shell.add_theme_constant_override("separation", 8)
	detail_margin.add_child(_detail_shell)
	_detail_header_panel = PanelContainer.new()
	_detail_header_panel.name = "DetailHeader"
	_detail_header_panel.custom_minimum_size = Vector2(0, 42)
	_detail_header_panel.add_theme_stylebox_override("panel", _panel_style(CommonLightUiStyleScript.SUPPORT_PALE, CommonLightUiStyleScript.SUPPORT_LIGHT))
	_detail_shell.add_child(_detail_header_panel)
	var detail_header_margin := MarginContainer.new()
	detail_header_margin.add_theme_constant_override("margin_left", 14)
	detail_header_margin.add_theme_constant_override("margin_right", 14)
	detail_header_margin.add_theme_constant_override("margin_top", 2)
	detail_header_margin.add_theme_constant_override("margin_bottom", 2)
	_detail_header_panel.add_child(detail_header_margin)
	_detail_title = Label.new()
	CommonLightUiStyleScript.apply_font(_detail_title, 25, true, CommonLightUiStyleScript.TEXT_PRIMARY)
	_detail_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	detail_header_margin.add_child(_detail_title)
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
	_detail_info_panel.add_theme_stylebox_override("panel", _panel_style(Color(1, 1, 1, 0.62), CommonLightUiStyleScript.DIVIDER))
	_detail_scroll.add_child(_detail_info_panel)
	var detail_info_margin := MarginContainer.new()
	detail_info_margin.add_theme_constant_override("margin_left", 18)
	detail_info_margin.add_theme_constant_override("margin_top", 14)
	detail_info_margin.add_theme_constant_override("margin_right", 18)
	detail_info_margin.add_theme_constant_override("margin_bottom", 14)
	_detail_info_panel.add_child(detail_info_margin)
	_detail_body = Label.new()
	_detail_body.name = "DetailInfoBody"
	_detail_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	CommonLightUiStyleScript.apply_font(_detail_body, 16, false, CommonLightUiStyleScript.TEXT_PRIMARY)
	_detail_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_info_margin.add_child(_detail_body)

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
	_footer_label.text = "↑↓ 項目/戻る　←→ カテゴリ　N NEW　Enter 詳細　Esc 戻る"
	_footer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_footer_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_footer_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	CommonLightUiStyleScript.apply_font(_footer_label, 15, false, CommonLightUiStyleScript.TEXT_SECONDARY)
	footer_row.add_child(_footer_label)
	_detail_nav_row = HBoxContainer.new()
	_detail_nav_row.add_theme_constant_override("separation", 6)
	footer_row.add_child(_detail_nav_row)
	_detail_prev_button = Button.new()
	_detail_prev_button.text = "前へ"
	_detail_prev_button.custom_minimum_size = Vector2(82, 40)
	_detail_prev_button.focus_mode = Control.FOCUS_NONE
	CommonLightUiStyleScript.apply_font(_detail_prev_button, 15, true, CommonLightUiStyleScript.TEXT_PRIMARY)
	_detail_prev_button.add_theme_stylebox_override("normal", CommonLightUiStyleScript.create_back_button_style(false))
	_detail_prev_button.add_theme_stylebox_override("hover", CommonLightUiStyleScript.create_back_button_style(true))
	_detail_prev_button.pressed.connect(func() -> void: _move_detail(-1))
	_detail_nav_row.add_child(_detail_prev_button)
	_detail_next_button = Button.new()
	_detail_next_button.text = "次へ"
	_detail_next_button.custom_minimum_size = Vector2(82, 40)
	_detail_next_button.focus_mode = Control.FOCUS_NONE
	CommonLightUiStyleScript.apply_font(_detail_next_button, 15, true, CommonLightUiStyleScript.TEXT_PRIMARY)
	_detail_next_button.add_theme_stylebox_override("normal", CommonLightUiStyleScript.create_back_button_style(false))
	_detail_next_button.add_theme_stylebox_override("hover", CommonLightUiStyleScript.create_back_button_style(true))
	_detail_next_button.pressed.connect(func() -> void: _move_detail(1))
	_detail_nav_row.add_child(_detail_next_button)
	_detail_hint_label = Label.new()
	_detail_hint_label.visible = false
	_detail_nav_row.add_child(_detail_hint_label)

	if OS.is_debug_build():
		_debug_overlay = PanelContainer.new()
		_debug_overlay.name = "DebugOverlay"
		_debug_overlay.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
		_debug_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
		_debug_overlay.z_index = 30
		_debug_overlay.add_theme_stylebox_override("panel", _panel_style(Color(CommonLightUiStyleScript.PP_PALE, 0.96), CommonLightUiStyleScript.PP_GOLD))
		add_child(_debug_overlay)
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
	add_child(_completion_banner)
	_apply_layout_metrics()

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
	_detail_prev_button.custom_minimum_size = Vector2(74 if _compact_layout else 82, 36 if _compact_layout else 40)
	_detail_next_button.custom_minimum_size = Vector2(74 if _compact_layout else 82, 36 if _compact_layout else 40)
	CommonLightUiStyleScript.apply_font(_footer_label, 14 if _compact_layout else 15, false, CommonLightUiStyleScript.TEXT_SECONDARY)
	CommonLightUiStyleScript.apply_font(_detail_body, 15 if _compact_layout else 16, false, CommonLightUiStyleScript.TEXT_PRIMARY)
	for spacer_index in range(_layout_spacers.size()):
		var spacer := _layout_spacers[spacer_index]
		spacer.custom_minimum_size.y = 6.0 if spacer_index < 2 else 2.0
	_apply_visual_area_metrics()

func _apply_visual_area_metrics() -> void:
	if _detail_image_frame == null:
		return
	var category := CATEGORIES[_category_index]
	var visual_height := 180.0
	if not _compact_layout:
		match category:
			CodexManager.CATEGORY_CHARACTER:
				visual_height = 300.0
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
				visual_height = 210.0
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

func _apply_list_button_style(button: Button, category_index: int, selected: bool) -> void:
	var accent := _category_accent(category_index)
	var normal_style := CommonLightUiStyleScript.create_panel_style(Color(1, 1, 1, 0.88), CommonLightUiStyleScript.LILAC_BORDER, 1, 12, 12.0, 6.0)
	var selected_style := CommonLightUiStyleScript.create_panel_style(Color(accent, 0.18), accent, 2, 12, 12.0, 6.0)
	selected_style.shadow_color = Color(accent, 0.16)
	selected_style.shadow_size = 5
	button.add_theme_stylebox_override("normal", selected_style if selected else normal_style)
	button.add_theme_stylebox_override("hover", selected_style)
	button.add_theme_stylebox_override("pressed", selected_style)
	button.add_theme_stylebox_override("focus", CommonLightUiStyleScript.create_outer_focus_ring_style(accent))

func _refresh_list_focus_visuals() -> void:
	if _list_box == null:
		return
	var entries := _visible_entries()
	var selected := _selected_index(entries)
	var cursor_visible := _focus_area == FocusArea.LIST and not _detail_mode
	var children := _list_box.get_children()
	for index in range(children.size()):
		var button := children[index] as Button
		if button == null or not button.has_meta("codex_base_text"):
			continue
		var active_row := cursor_visible and index == selected
		var base_text := String(button.get_meta("codex_base_text", ""))
		button.text = ("▶ " if active_row else "  ") + base_text
		_apply_list_button_style(button, _category_index, active_row)

func _refresh_focus_visuals() -> void:
	var accent := _category_accent(_category_index)
	if _detail_focus_ring != null:
		var ring_style := CommonLightUiStyleScript.create_panel_style(Color(1, 1, 1, 0.0), Color(accent, 0.96), 3, 16, 0.0, 0.0)
		ring_style.bg_color = Color.TRANSPARENT
		ring_style.draw_center = false
		ring_style.shadow_color = Color.TRANSPARENT
		ring_style.shadow_size = 0
		ring_style.set_border_width_all(3)
		_detail_focus_ring.add_theme_stylebox_override("panel", ring_style)
		_detail_focus_ring.visible = _detail_mode
	_refresh_list_focus_visuals()
	if _detail_back_button != null:
		var back_active := _focus_area == FocusArea.BACK
		_detail_back_button.add_theme_stylebox_override("normal", CommonLightUiStyleScript.create_back_button_style(back_active))
		_detail_back_button.add_theme_stylebox_override("hover", CommonLightUiStyleScript.create_back_button_style(true))
		_detail_back_button.add_theme_stylebox_override("pressed", CommonLightUiStyleScript.create_back_button_style(true))
		_detail_back_button.add_theme_stylebox_override("focus", CommonLightUiStyleScript.create_back_button_style(true))

func _apply_filter_button_style(button: Button, active: bool) -> void:
	var style := CommonLightUiStyleScript.create_panel_style(CommonLightUiStyleScript.SUPPORT_PALE if active else Color(1, 1, 1, 0.70), CommonLightUiStyleScript.SUPPORT_MAIN if active else CommonLightUiStyleScript.LILAC_BORDER, 2 if active else 1, 10, 8.0, 5.0)
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", CommonLightUiStyleScript.create_panel_style(CommonLightUiStyleScript.SUPPORT_PALE, CommonLightUiStyleScript.SUPPORT_MAIN, 2, 10, 8.0, 5.0))
	button.add_theme_stylebox_override("pressed", style)

func _panel_style(background: Color, border: Color) -> StyleBoxFlat:
	return CommonLightUiStyleScript.create_panel_style(background, border, 2, 14, 0.0, 0.0)

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
	if _detail_mode:
		_exit_detail()
	else:
		close_screen()

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
	_detail_mode = false
	_set_focus_area(FocusArea.LIST, false)
	_refresh_after_scope_change()
	if _category_index != previous_index:
		cursor_moved.emit()

func _move_category(direction: int) -> void:
	_category_index = posmod(_category_index + direction, CATEGORIES.size())
	_detail_mode = false
	_set_focus_area(FocusArea.LIST, false)
	_refresh_after_scope_change()
	cursor_moved.emit()

func _set_enemy_filter(filter_id: String) -> void:
	if not CodexPresentationSystemScript.filter_ids().has(filter_id):
		filter_id = "ALL"
	var previous_filter := _enemy_filter_id
	_enemy_filter_id = filter_id
	_detail_mode = false
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
	_detail_mode = false
	_set_focus_area(FocusArea.LIST, false)
	_refresh_after_scope_change()
	if _new_only != previous_new_only:
		cursor_moved.emit()

func _move_enemy_filter(direction: int) -> void:
	var filters := CodexPresentationSystemScript.filter_ids()
	var index := filters.find(_enemy_filter_id)
	_enemy_filter_id = filters[posmod(index + direction, filters.size())]
	_detail_mode = false
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
	_selected_ids[CATEGORIES[_category_index]] = String((entries[next] as Dictionary).get("id", ""))
	_confirm_selection(next)
	_refresh_list_and_detail(true, false)
	if next != selected:
		cursor_moved.emit()

func _move_from_back(direction: int) -> void:
	var entries := _visible_entries()
	if entries.is_empty():
		return
	var target_index := 0 if direction > 0 else entries.size() - 1
	_set_focus_area(FocusArea.LIST, false)
	_selected_ids[CATEGORIES[_category_index]] = String((entries[target_index] as Dictionary).get("id", ""))
	_confirm_selection(target_index)
	_refresh_list_and_detail(false, false)
	cursor_moved.emit()

func _open_detail(index: int, _preferred_direction: int = 0) -> void:
	var entries := _visible_entries()
	if index < 0 or index >= entries.size():
		return
	var item: Dictionary = entries[index] as Dictionary
	var category := CATEGORIES[_category_index]
	_selected_ids[category] = String(item.get("id", ""))
	_set_focus_area(FocusArea.LIST, false)
	var was_detail_mode := _detail_mode
	_detail_mode = true
	_refresh_list_and_detail()
	if not was_detail_mode:
		confirm_requested.emit()

func _select_entry(index: int) -> void:
	_set_focus_area(FocusArea.LIST, false)
	_confirm_selection(index)
	_open_detail(index)

func _exit_detail() -> void:
	_detail_mode = false
	_set_focus_area(FocusArea.LIST, false)
	_refresh_list_and_detail()

func _move_detail(direction: int) -> void:
	var entries := _visible_entries()
	if entries.is_empty():
		return
	var current := _selected_index(entries)
	var next := posmod(current + direction, entries.size())
	_confirm_selection(next)
	_open_detail(next, direction)
	if next != current:
		cursor_moved.emit()

func _scroll_detail(direction: int) -> void:
	if _detail_scroll == null:
		return
	var step := 120 if direction > 0 else -120
	_detail_scroll.scroll_vertical = maxi(0, _detail_scroll.scroll_vertical + step)

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
		_refresh()
	else:
		_refresh_category_buttons()

func _on_codex_bulk_changed(_category: String) -> void:
	if visible:
		if _new_only and not _rebuild_new_snapshot():
			_new_only = false
		_refresh()

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

func _refresh() -> void:
	_refresh_category_buttons()
	_refresh_collection()
	_refresh_new_filter_button()
	_refresh_enemy_filter_buttons()
	_refresh_list_and_detail()
	_show_next_completion_notice()

func _refresh_after_scope_change() -> void:
	var category := CATEGORIES[_category_index]
	if _new_only and not _rebuild_new_snapshot():
		_new_only = false
		_new_snapshot_ids.erase(category)
	_refresh()
	_confirm_current_selection()
	_refresh_list_and_detail(true, false)

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

func _confirm_current_selection() -> bool:
	var entries := _visible_entries()
	var selected := _selected_index(entries)
	return _confirm_selection(selected)

func _confirm_selection(index: int) -> bool:
	var entries := _visible_entries()
	if index < 0 or index >= entries.size():
		return false
	var item: Dictionary = entries[index] as Dictionary
	var category := CATEGORIES[_category_index]
	var item_id := String(item.get("id", "")).strip_edges()
	if item_id == "":
		return false
	_selected_ids[category] = item_id
	if not bool(item.get("discovered", false)) or not CodexManager.is_new(category, item_id):
		return false
	_local_mark_read_in_progress = true
	CodexManager.mark_read(category, item_id)
	_local_mark_read_in_progress = false
	return true

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

func _refresh_list_and_detail(preserve_detail_scroll: bool = false, preserve_list_scroll: bool = false) -> void:
	if _list_box == null:
		return
	var saved_list_scroll := _list_scroll.scroll_vertical if preserve_list_scroll and _list_scroll != null else 0
	var saved_detail_scroll := _detail_scroll.scroll_vertical if preserve_detail_scroll and _detail_scroll != null else 0
	if _detail_scroll != null and not preserve_detail_scroll:
		_detail_scroll.scroll_vertical = 0
	var category := CATEGORIES[_category_index]
	var entries := _visible_entries()
	var selected := _selected_index(entries)
	var list_cursor_visible := _focus_area == FocusArea.LIST and not _detail_mode
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
			var label := _display_name(item) if discovered else "？？？"
			if not discovered:
				label += "  ?"
			if category == CodexManager.CATEGORY_ENEMY and discovered:
				var preview_entry: Dictionary = item.get("entry", {}) as Dictionary
				var preview_model := CodexPresentationSystemScript.build_enemy_model(item, true, preview_entry, _get_enemy_sources())
				var primary_tag := String(preview_model.get("primaryTag", ""))
				if primary_tag != "":
					label += "  [%s]" % CodexPresentationSystemScript.enemy_tag_label(primary_tag)
			if bool(item.get("new", false)):
				label += "  NEW"
			var active_row := list_cursor_visible and index == selected
			button.set_meta("codex_base_text", label)
			button.focus_mode = Control.FOCUS_NONE
			button.text = ("▶ " if active_row else "  ") + label
			button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			button.custom_minimum_size = Vector2(0, 36 if _compact_layout else 40)
			button.clip_text = true
			button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			CommonLightUiStyleScript.apply_font(button, 15 if _compact_layout else 16, false, CommonLightUiStyleScript.TEXT_PRIMARY)
			_apply_list_button_style(button, _category_index, active_row)
			var item_id := String(item.get("id", ""))
			button.pressed.connect(func() -> void: _select_entry_by_id(item_id))
			_list_box.add_child(button)
			if index == selected:
				call_deferred("_ensure_selected_visible", button)
	if _progress_label != null:
		_progress_label.text = "%s  %d / %d" % [CATEGORY_LABELS[_category_index], CodexManager.get_discovered_count(category), CodexManager.get_total_count(category)]
	_apply_visual_area_metrics()
	_render_detail(entries, selected)
	_refresh_detail_controls(entries)
	if preserve_list_scroll and _list_scroll != null:
		_list_scroll.scroll_vertical = saved_list_scroll
		call_deferred("_restore_codex_scroll", saved_list_scroll, saved_detail_scroll, preserve_detail_scroll)
	elif preserve_detail_scroll and _detail_scroll != null:
		_detail_scroll.scroll_vertical = saved_detail_scroll

func _restore_codex_scroll(list_scroll: int, detail_scroll: int, restore_detail: bool) -> void:
	if _list_scroll != null:
		_list_scroll.scroll_vertical = list_scroll
	if restore_detail and _detail_scroll != null:
		_detail_scroll.scroll_vertical = detail_scroll

func _ensure_selected_visible(button: Control) -> void:
	if _list_scroll != null and is_instance_valid(button) and button.is_inside_tree() and _list_scroll.is_ancestor_of(button):
		_list_scroll.ensure_control_visible(button)

func _select_entry_by_id(item_id: String) -> void:
	var entries := _visible_entries()
	_set_focus_area(FocusArea.LIST, false)
	for index in range(entries.size()):
		if String((entries[index] as Dictionary).get("id", "")) == item_id:
			_select_entry(index)
			return

func _refresh_detail_controls(entries: Array) -> void:
	if _detail_nav_row == null:
		return
	_detail_nav_row.visible = true
	var has_entries := not entries.is_empty()
	_detail_prev_button.visible = _detail_mode and entries.size() > 1
	_detail_next_button.visible = _detail_mode and entries.size() > 1
	_detail_back_button.text = "一覧へ戻る" if _detail_mode else "戻る"
	_detail_back_button.disabled = false
	_detail_hint_label.visible = _detail_mode and has_entries
	_detail_hint_label.text = "前へ / 次へ"
	_footer_label.text = "←→ 前後　↑↓ 詳細スクロール　Esc 一覧" if _detail_mode else "↑↓ 項目/戻る　←→ カテゴリ　N NEW　Enter 詳細　Esc 戻る"
	_refresh_focus_visuals()

func _render_detail(entries: Array, selected: int) -> void:
	if not _detail_mode and not entries.is_empty() and selected >= 0 and selected < entries.size():
		_render_preview(entries[selected] as Dictionary)
		return
	_render_full_detail(entries, selected)

func _render_preview(item: Dictionary) -> void:
	var category := CATEGORIES[_category_index]
	var discovered := bool(item.get("discovered", false))
	var title := _display_name(item) if discovered else "？？？"
	_detail_title.text = title + ("  NEW" if bool(item.get("new", false)) else "")
	_detail_title.add_theme_font_size_override("font_size", 26)
	_detail_title.add_theme_color_override("font_color", Color("#1e293b"))
	var lines: Array[String] = ["選択でNEW確認済み / 決定で詳細"]
	var image_path := ""
	if discovered:
		if category == CodexManager.CATEGORY_ENEMY:
			var enemy_model := CodexPresentationSystemScript.build_enemy_model(item, true, item.get("entry", {}) as Dictionary, _get_enemy_sources())
			var stage_text := _join_strings(enemy_model.get("stageLabels", []), " / ", "")
			if stage_text != "":
				lines.append("出現枠: %s" % stage_text)
			image_path = String(enemy_model.get("imagePath", ""))
		else:
			var description := String(item.get("description", item.get("text", ""))).strip_edges()
			if description != "":
				lines.append(description)
			image_path = CodexPresentationSystemScript.image_path_for(category, item, true)
	else:
		lines.append("まだ発見していません")
		lines.append_array(CodexPresentationSystemScript.undiscovered_hint(category, item))
		image_path = ""
	if category == CodexManager.CATEGORY_COMMENT and discovered and CodexPresentationSystemScript.safe_resource_path(image_path) == "":
		_set_comment_card(String(item.get("text", item.get("body", _display_name(item)))))
	else:
		_set_detail_image(image_path, category)
	_detail_body.text = "\n\n".join(lines)

func _render_full_detail(entries: Array, selected: int) -> void:
	if entries.is_empty() or selected < 0 or selected >= entries.size():
		_detail_title.text = "---"
		_detail_body.text = "このフィルターに該当する項目はありません。"
		_set_detail_image("", CATEGORIES[_category_index])
		return
	var item: Dictionary = entries[selected] as Dictionary
	var discovered := bool(item.get("discovered", false))
	var category := CATEGORIES[_category_index]
	var title := _display_name(item) if discovered else "？？？"
	_detail_title.text = title + ("  NEW" if bool(item.get("new", false)) else "")
	_detail_title.add_theme_font_size_override("font_size", 26)
	_detail_title.add_theme_color_override("font_color", Color("#1e293b"))
	var lines: Array[String] = []
	var image_path := ""
	if not discovered:
		lines.append("この項目は未発見です。")
		lines.append_array(CodexPresentationSystemScript.undiscovered_hint(category, item))
		if category == CodexManager.CATEGORY_ENEMY:
			var hidden_enemy := CodexPresentationSystemScript.build_enemy_model(item, false, {}, _get_enemy_sources())
			if String(hidden_enemy.get("titleTag", "")) != "":
				lines.append(String(hidden_enemy.get("titleTag", "")))
			var hidden_stage_text := _join_strings(hidden_enemy.get("stageLabels", []), "、", "")
			if hidden_stage_text != "":
				lines.append("出現枠：%s" % hidden_stage_text)
		_set_detail_image("", category)
		_detail_body.text = "\n\n".join(lines)
		return
	var entry: Dictionary = item.get("entry", {}) as Dictionary
	var description := String(item.get("description", "")).strip_edges()
	_detail_title.add_theme_font_size_override("font_size", 26)
	_detail_title.add_theme_color_override("font_color", Color("#1e293b"))
	match category:
		CodexManager.CATEGORY_CHARACTER:
			var character_model := CodexPresentationSystemScript.character_profile_model(item, CodexManager.get_master_entries(CodexManager.CATEGORY_WEAPON), _discovered_weapon_ids())
			var character_type := String(character_model.get("type", "")).strip_edges()
			if character_type != "":
				lines.append("タイプ：%s" % character_type)
			var character_description := String(character_model.get("description", description)).strip_edges()
			if character_description != "":
				lines.append(character_description)
			var initial_weapon_name := String(character_model.get("initialWeaponName", "")).strip_edges()
			if initial_weapon_name != "":
				lines.append("初期武器：%s" % initial_weapon_name)
			var initial_evolution_name := String(character_model.get("initialEvolutionName", "")).strip_edges()
			if initial_evolution_name != "" and initial_evolution_name != "進化なし":
				lines.append("初期武器の進化先：%s" % initial_evolution_name)
			var character_record := CodexPresentationSystemScript.character_record_model(item, entry, _difficulty_progress)
			lines.append("PLAY RECORD")
			lines.append("play %d / clear %d / best score %s" % [int(character_record.get("playCount", 0)), int(character_record.get("clearCount", 0)), _number_with_commas(int(character_record.get("bestScore", 0)))])
			for stage_value in character_record.get("stageClears", []) as Array:
				var stage_record: Dictionary = stage_value as Dictionary
				var status_values: Array[String] = []
				for state_value in stage_record.get("states", []) as Array:
					var state: Dictionary = state_value as Dictionary
					status_values.append("%s:%s" % [String(state.get("label", "")), String(state.get("status", "---"))])
				lines.append("%s  %s" % [String(stage_record.get("label", "")), " / ".join(status_values)])
			for relay_value in character_record.get("relayRecords", []) as Array:
				var relay_record: Dictionary = relay_value as Dictionary
				lines.append("RELAY %s: %s / %s" % [String(relay_record.get("label", "")), String(relay_record.get("status", "---")), String(relay_record.get("bestSectionLabel", "---"))])
			image_path = String(character_model.get("imagePath", ""))
		CodexManager.CATEGORY_WEAPON:
			lines.append("表示名：%s" % _display_name(item))
			if description != "":
				lines.append(description)
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
			image_path = CodexPresentationSystemScript.image_path_for(CodexManager.CATEGORY_WEAPON, item, true)
		CodexManager.CATEGORY_ACCESSORY:
			if description != "":
				lines.append("効果：%s" % description)
			var accessory_max_level: Variant = item.get("maxLevel", item.get("maxLv", null))
			if accessory_max_level is int or accessory_max_level is float:
				lines.append("最大Lv：%d" % int(accessory_max_level))
			var accessory_performance := CodexPresentationSystemScript.accessory_performance_model(item)
			_append_performance_lines(lines, accessory_performance)
			lines.append_array(_accessory_detail(item).get("lines", []) as Array)
			image_path = CodexPresentationSystemScript.image_path_for(CodexManager.CATEGORY_ACCESSORY, item, true)
		CodexManager.CATEGORY_ENEMY:
			var enemy_model := CodexPresentationSystemScript.build_enemy_model(item, true, entry, _get_enemy_sources())
			_detail_title.add_theme_font_size_override("font_size", 30 if String(enemy_model.get("kind", "")) != "normal" else 26)
			_detail_title.add_theme_color_override("font_color", Color("#be123c") if String(enemy_model.get("kind", "")) == "specialBoss" else (Color("#7c3aed") if String(enemy_model.get("kind", "")) == "boss" else Color("#1e293b")))
			var enemy_title_tag := String(enemy_model.get("titleTag", ""))
			if enemy_title_tag != "":
				lines.append(enemy_title_tag)
			var badge_text := _join_strings(enemy_model.get("badges", []), " / ", "")
			if badge_text != "":
				lines.append("種別：%s" % badge_text)
			var durability_rating: Dictionary = enemy_model.get("durabilityRating", {}) as Dictionary
			var speed_rating: Dictionary = enemy_model.get("speedRating", {}) as Dictionary
			if not durability_rating.is_empty() or not speed_rating.is_empty():
				lines.append("基本特性")
				lines.append("耐久：%s" % String(durability_rating.get("label", "---")))
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
			var stage_text := _join_strings(enemy_model.get("stageLabels", []), "、", "")
			if stage_text != "":
				lines.append("出現枠：%s" % stage_text)
			lines.append_array(enemy_model.get("conditionLines", enemy_model.get("conditions", [])) as Array)
			lines.append("撃破数：%d" % int(enemy_model.get("killCount", 0)))
			if String(enemy_model.get("kind", "")) != "normal":
				var boss_record := CodexPresentationSystemScript.boss_record_model(item, entry, _difficulty_progress, _get_enemy_sources())
				lines.append("BOSS STATUS")
				for state_value in boss_record.get("states", []) as Array:
					var state: Dictionary = state_value as Dictionary
					lines.append("%s: %s" % [String(state.get("label", "")), String(state.get("status", "---"))])
				var related_names: Array[String] = []
				for related_id in boss_record.get("relatedEnemyIds", []) as Array:
					related_names.append(_related_enemy_name(String(related_id)))
				if not related_names.is_empty():
					lines.append("RELATED: %s" % ", ".join(related_names))
			for section_value in [["特徴", enemy_model.get("description", "")], ["攻略メモ", enemy_model.get("strategy", "")], ["COMMENT", enemy_model.get("flavor", "")]]:
				var section_text := String(section_value[1]).strip_edges()
				if section_text != "":
					lines.append("%s：%s" % [String(section_value[0]), section_text])
			image_path = String(enemy_model.get("imagePath", ""))
		CodexManager.CATEGORY_COMMENT:
			var comment_record := CodexPresentationSystemScript.comment_record_model(item, entry)
			var comment_tags := _join_strings(comment_record.get("tags", []), ", ", "")
			if comment_tags != "":
				lines.append("TAGS: %s" % comment_tags)
			var heart_description := String(comment_record.get("heartDescription", "")).strip_edges()
			if heart_description != "":
				lines.append("♡使用時: %s" % heart_description)
			lines.append("appeared %d / selected %d / heart %d" % [int(comment_record.get("appearedCount", 0)), int(comment_record.get("selectedCount", 0)), int(comment_record.get("heartCount", 0))])
			lines.append("本文：%s" % String(item.get("text", item.get("body", _display_name(item)))))
			var comment_category := String(comment_record.get("category", "")).strip_edges()
			if comment_category != "":
				lines.append("出現区分：%s" % comment_category)
			var comment_stages := _join_strings(comment_record.get("stageIds", []), "、", "")
			if comment_stages != "":
				lines.append("出現枠：%s" % comment_stages)
			_append_comment_effect_lines(lines, comment_record.get("effectModel", {}))
			image_path = CodexPresentationSystemScript.image_path_for(CodexManager.CATEGORY_COMMENT, item, true)
	if category == CodexManager.CATEGORY_COMMENT and CodexPresentationSystemScript.safe_resource_path(image_path) == "":
		_set_comment_card(String(item.get("text", item.get("body", _display_name(item)))))
	else:
		_set_detail_image(image_path, category)
	_detail_body.text = "\n\n".join(lines)

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
	if _detail_image_holder == null:
		return
	for child in _detail_image_holder.get_children():
		_detail_image_holder.remove_child(child)
		child.queue_free()
	var safe_path := CodexPresentationSystemScript.safe_resource_path(path)
	if safe_path == "":
		var fallback := Label.new()
		fallback.text = "?"
		fallback.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		fallback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		fallback.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		fallback.add_theme_font_size_override("font_size", 44)
		fallback.add_theme_color_override("font_color", Color("#64748b"))
		_detail_image_holder.add_child(fallback)
		return
	var texture := load(safe_path) as Texture2D
	if texture == null:
		_set_detail_image("", display_category)
		return
	var resolved_category := display_category if display_category != "" else CATEGORIES[_category_index]
	if resolved_category == CodexManager.CATEGORY_CHARACTER:
		texture = _character_content_texture(safe_path, texture)
	var rect := TextureRect.new()
	rect.texture = texture
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.clip_contents = true
	_detail_image_holder.add_child(rect)

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

func _set_comment_card(text: String) -> void:
	if _detail_image_holder == null:
		return
	for child in _detail_image_holder.get_children():
		_detail_image_holder.remove_child(child)
		child.queue_free()
	var card_panel := PanelContainer.new()
	card_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	card_panel.add_theme_stylebox_override("panel", CommonLightUiStyleScript.create_panel_style(CommonLightUiStyleScript.COMBAT_PALE, CommonLightUiStyleScript.COMBAT_MAIN, 2, 18, 24.0, 16.0))
	_detail_image_holder.add_child(card_panel)
	var card_margin := MarginContainer.new()
	card_margin.add_theme_constant_override("margin_left", 24)
	card_margin.add_theme_constant_override("margin_right", 24)
	card_margin.add_theme_constant_override("margin_top", 14)
	card_margin.add_theme_constant_override("margin_bottom", 14)
	card_panel.add_child(card_margin)
	var card := Label.new()
	card.text = "「%s」" % text.strip_edges()
	card.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	CommonLightUiStyleScript.apply_font(card, 18 if not _compact_layout else 16, true, CommonLightUiStyleScript.TEXT_PRIMARY)
	card_margin.add_child(card)

func _display_name(item: Dictionary) -> String:
	var name := String(item.get("displayName", "")).strip_edges()
	return name if name != "" else String(item.get("id", "?"))

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
		return _display_name(item as Dictionary) if bool((item as Dictionary).get("discovered", false)) else "???"
	return "???"
