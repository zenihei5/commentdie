class_name CustomizationShopPanel
extends Control

const CommonLightUiStyleScript := preload("res://scripts/ui/common_light_ui_style.gd")
const CustomizationProviderScript := preload("res://scripts/systems/customization_provider.gd")
const CustomizationPreviewScript := preload("res://scripts/ui/customization_preview.gd")
const GameFontSystemScript := preload("res://scripts/systems/game_font_system.gd")
const PowerUpShopManagerScript := preload("res://scripts/systems/power_up_shop_manager.gd")

signal back_requested
signal upper_focus_requested
signal body_focus_requested

const CATEGORY_IDS := ["title", "theme", "result_stamp"]
const CATEGORY_LABELS := ["肩書き", "テーマ", "スタンプ"]

enum FocusArea {
	CATEGORIES,
	ITEMS,
	ACTION,
	BACK,
}

var manager
var codex_source
var category_index := 0
var selected_indices := [0, 0, 0]
var focus_area := FocusArea.ITEMS
var last_input_device := "keyboard"
var purchase_api_call_count := 0

var _main_rect := Rect2()
var _list_rect := Rect2()
var _detail_rect := Rect2()
var _compact := false
var _items: Array[Dictionary] = []
var _item_buttons: Array[Button] = []
var _category_buttons: Array[Button] = []
var _grid: GridContainer
var _scroll: ScrollContainer
var _preview
var _title_label: Label
var _english_title: Label
var _description_label: Label
var _gate_label: Label
var _pp_label: Label
var _detail_category_label: Label
var _detail_name: Label
var _detail_description: Label
var _detail_condition: Label
var _detail_price: Label
var _detail_state: Label
var _action_button: Button
var _back_button: Button
var _hint_label: Label
var _feedback_label: Label

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 12
	_build_controls()
	call_deferred("layout_customization", size)
	hide()

func _build_controls() -> void:
	_english_title = _new_label("CUSTOMIZATION SHOP", 12, true, CommonLightUiStyleScript.ENGLISH_TITLE)
	_title_label = _new_label("配信カスタム", 29, true, CommonLightUiStyleScript.TEXT_PRIMARY)
	_description_label = _new_label("購入と装備は別々です。性能には影響しません。", 14, false, CommonLightUiStyleScript.TEXT_SECONDARY)
	_gate_label = _new_label("", 14, true, CommonLightUiStyleScript.COMBAT_DARK)
	_pp_label = _new_label("所持PP 0", 22, true, CommonLightUiStyleScript.PP_TEXT)
	_detail_category_label = _new_label("", 13, true, CommonLightUiStyleScript.COMBAT_DARK)
	_detail_name = _new_label("商品を選択", 24, true, CommonLightUiStyleScript.TEXT_PRIMARY)
	_detail_description = _new_label("", 14, false, CommonLightUiStyleScript.TEXT_SECONDARY)
	_detail_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_condition = _new_label("", 14, false, CommonLightUiStyleScript.TEXT_SECONDARY)
	_detail_condition.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_price = _new_label("", 17, true, CommonLightUiStyleScript.PP_TEXT)
	_detail_state = _new_label("", 16, true, CommonLightUiStyleScript.TEXT_PRIMARY)
	_feedback_label = _new_label("", 13, true, CommonLightUiStyleScript.COMBAT_DARK)
	_hint_label = _new_label("Q / E: カテゴリ　WASD / 十字キー: 選択　Enter / A: 決定　Esc / B: 戻る", 13, false, CommonLightUiStyleScript.TEXT_SECONDARY)
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	for index in range(CATEGORY_IDS.size()):
		var button := Button.new()
		button.name = "CategoryTab%d" % index
		button.text = CATEGORY_LABELS[index]
		button.focus_mode = Control.FOCUS_ALL
		button.pressed.connect(_on_category_pressed.bind(index))
		add_child(button)
		_category_buttons.append(button)

	_scroll = ScrollContainer.new()
	_scroll.name = "CustomizationItemScroll"
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_scroll.clip_contents = true
	add_child(_scroll)
	_grid = GridContainer.new()
	_grid.name = "CustomizationItemGrid"
	_grid.columns = 2
	_grid.add_theme_constant_override("h_separation", 12)
	_grid.add_theme_constant_override("v_separation", 10)
	_scroll.add_child(_grid)

	_preview = CustomizationPreviewScript.new()
	_preview.name = "CustomizationPreview"
	add_child(_preview)

	_action_button = Button.new()
	_action_button.name = "CustomizationAction"
	_action_button.focus_mode = Control.FOCUS_ALL
	_action_button.pressed.connect(_on_action_pressed)
	add_child(_action_button)
	_back_button = Button.new()
	_back_button.name = "CustomizationBack"
	_back_button.text = "戻る"
	_back_button.focus_mode = Control.FOCUS_ALL
	_back_button.pressed.connect(_on_back_pressed)
	add_child(_back_button)

func bind_manager(value) -> void:
	manager = value
	if manager == null:
		return
	if not manager.points_changed.is_connected(_on_points_changed):
		manager.points_changed.connect(_on_points_changed)
	if manager.has_signal("customization_purchased") and not manager.customization_purchased.is_connected(_on_customization_changed):
		manager.customization_purchased.connect(_on_customization_changed)
	if manager.has_signal("customization_equipped") and not manager.customization_equipped.is_connected(_on_customization_changed):
		manager.customization_equipped.connect(_on_customization_changed)
	if manager.has_signal("customization_conditions_unlocked") and not manager.customization_conditions_unlocked.is_connected(_on_conditions_changed):
		manager.customization_conditions_unlocked.connect(_on_conditions_changed)
	if manager.has_signal("upgrades_reset") and not manager.upgrades_reset.is_connected(_on_upgrades_reset):
		manager.upgrades_reset.connect(_on_upgrades_reset)
	if manager.has_signal("purchase_failed") and not manager.purchase_failed.is_connected(_on_purchase_failed):
		manager.purchase_failed.connect(_on_purchase_failed)
	_refresh()

func bind_codex_source(value) -> void:
	codex_source = value
	_refresh()

func open_panel() -> void:
	show()
	focus_area = FocusArea.ITEMS
	_refresh()
	call_deferred("_ensure_selected_visible")

func close_panel() -> void:
	hide()

func layout_customization(viewport_size: Vector2 = Vector2.ZERO) -> void:
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = size if size.x > 0.0 and size.y > 0.0 else get_viewport_rect().size
	_compact = viewport_size.x < 1440.0 or viewport_size.y < 820.0
	var horizontal_margin := 24.0 if _compact else 48.0
	var content_width := minf(viewport_size.x - horizontal_margin * 2.0, 1360.0)
	var content_height := maxf(0.0, viewport_size.y - (28.0 if _compact else 42.0))
	_main_rect = Rect2(Vector2((viewport_size.x - content_width) * 0.5, 14.0 if _compact else 21.0), Vector2(content_width, content_height))
	var inner_gap := 22.0 if _compact else 26.0
	var list_width := minf(650.0 if not _compact else 602.0, _main_rect.size.x * 0.49)
	var body_top := _main_rect.position.y + (202.0 if _compact else 202.0)
	var footer_height := 54.0
	var body_height := maxf(300.0, _main_rect.end.y - body_top - footer_height - 14.0)
	_list_rect = Rect2(Vector2(_main_rect.position.x + 24.0, body_top), Vector2(list_width, body_height))
	_detail_rect = Rect2(Vector2(_list_rect.end.x + inner_gap, body_top), Vector2(_main_rect.end.x - 24.0 - (_list_rect.end.x + inner_gap), body_height))
	_place(_english_title, Rect2(_main_rect.position + Vector2(28.0, 17.0), Vector2(300.0, 18.0)))
	_place(_title_label, Rect2(_main_rect.position + Vector2(28.0, 34.0), Vector2(410.0, 38.0)))
	_place(_description_label, Rect2(_main_rect.position + Vector2(28.0, 76.0), Vector2(510.0, 24.0)))
	_place(_gate_label, Rect2(_main_rect.position + Vector2(28.0, 101.0), Vector2(maxf(380.0, list_width), 45.0)))
	_place(_pp_label, Rect2(Vector2(_main_rect.end.x - 270.0, _main_rect.position.y + 28.0), Vector2(240.0, 42.0)))
	for index in range(_category_buttons.size()):
		var button: Button = _category_buttons[index]
		_place(button, Rect2(Vector2(_main_rect.position.x + 24.0 + float(index) * (150.0 if _compact else 164.0), _main_rect.position.y + 151.0), Vector2(142.0 if _compact else 154.0, 34.0)))
	_place(_scroll, _list_rect.grow(-10.0))
	_grid.custom_minimum_size = Vector2(maxf(0.0, _scroll.size.x - 4.0), 0.0)
	var card_width := maxf(120.0, (_scroll.size.x - 12.0) * 0.5)
	for button in _item_buttons:
		button.custom_minimum_size = Vector2(card_width, 72.0 if _compact else 80.0)
		button.size = button.custom_minimum_size
	var preview_height := 118.0 if _compact else 150.0
	_place(_preview, Rect2(_detail_rect.position + Vector2(12.0, 12.0), Vector2(_detail_rect.size.x - 24.0, preview_height)))
	var detail_x := _detail_rect.position.x + 22.0
	var detail_width := _detail_rect.size.x - 44.0
	var y := _detail_rect.position.y + preview_height + 22.0
	_place(_detail_category_label, Rect2(Vector2(detail_x, y), Vector2(detail_width, 20.0)))
	_place(_detail_name, Rect2(Vector2(detail_x, y + 20.0), Vector2(detail_width, 36.0)))
	_place(_detail_description, Rect2(Vector2(detail_x, y + 60.0), Vector2(detail_width, 46.0 if _compact else 52.0)))
	_place(_detail_condition, Rect2(Vector2(detail_x, y + 112.0), Vector2(detail_width, 42.0)))
	_place(_detail_price, Rect2(Vector2(detail_x, y + 158.0), Vector2(detail_width, 28.0)))
	_place(_detail_state, Rect2(Vector2(detail_x, y + 188.0), Vector2(detail_width, 28.0)))
	_place(_action_button, Rect2(Vector2(detail_x, y + 222.0), Vector2(detail_width, 54.0 if _compact else 58.0)))
	_place(_feedback_label, Rect2(Vector2(detail_x, y + 280.0), Vector2(detail_width, 30.0)))
	_place(_back_button, Rect2(Vector2(_main_rect.position.x + 24.0, _main_rect.end.y - 49.0), Vector2(130.0, 38.0)))
	_place(_hint_label, Rect2(Vector2(_main_rect.position.x + 180.0, _main_rect.end.y - 47.0), Vector2(_main_rect.size.x - 204.0, 36.0)))
	queue_redraw()

func handle_action(action: String, device: String = "keyboard") -> void:
	if not visible:
		return
	last_input_device = device
	match action:
		"back":
			_on_back_pressed()
		"category_left":
			_select_category(posmod(category_index - 1, CATEGORY_IDS.size()))
		"category_right":
			_select_category(posmod(category_index + 1, CATEGORY_IDS.size()))
		"left", "right", "up", "down":
			_move_focus(Vector2i.LEFT if action == "left" else Vector2i.RIGHT if action == "right" else Vector2i.UP if action == "up" else Vector2i.DOWN)
		"confirm":
			_activate_focus()

func _draw() -> void:
	if _main_rect.size.x <= 0.0 or _main_rect.size.y <= 0.0:
		return
	var theme := _current_theme()
	var fill: Color = theme.get("decorativeFill", CommonLightUiStyleScript.MAIN_PANEL) as Color
	var border: Color = theme.get("decorativeBorder", CommonLightUiStyleScript.MAIN_PANEL_BORDER) as Color
	var accent: Color = theme.get("decorativeAccent", CommonLightUiStyleScript.COMBAT_MAIN) as Color
	var secondary: Color = theme.get("decorativeSecondary", CommonLightUiStyleScript.SUPPORT_MAIN) as Color
	var tertiary: Color = theme.get("decorativeTertiary", Color("#a875e8")) as Color
	draw_style_box(_style(Color(fill, 0.96), border, 3, 28), _main_rect)
	draw_style_box(_style(Color(1.0, 1.0, 1.0, 0.82), Color(accent, 0.34), 2, 20), _list_rect)
	draw_style_box(_style(Color(1.0, 1.0, 1.0, 0.90), Color(border, 0.68), 2, 20), _detail_rect)
	if bool(theme.get("enabled", false)):
		draw_line(_main_rect.position + Vector2(26.0, 12.0), Vector2(_main_rect.end.x - 26.0, _main_rect.position.y + 12.0), Color(accent, 0.84), 3.0, true)
		draw_line(_main_rect.position + Vector2(26.0, _main_rect.size.y - 12.0), Vector2(_main_rect.end.x - 26.0, _main_rect.end.y - 12.0), Color(secondary, 0.68), 2.0, true)
		draw_circle(_main_rect.position + Vector2(_main_rect.size.x - 35.0, 29.0), 10.0, Color(tertiary, 0.34))

func _refresh() -> void:
	if not is_node_ready() or manager == null:
		return
	_refresh_header()
	_refresh_items()
	_refresh_detail()
	layout_customization(size)
	_refresh_focus_visuals()

func _refresh_header() -> void:
	var gate: Dictionary = manager.customization_shop_gate_status(codex_source)
	var condition: Dictionary = gate.get("condition", {}) as Dictionary
	if not bool(gate.get("shopUnlocked", false)):
		_gate_label.text = "配信カスタム / LOCKED\nパワーアップショップ解禁後に利用できます"
		_gate_label.add_theme_color_override("font_color", CommonLightUiStyleScript.SHORTAGE_TEXT)
	elif not bool(gate.get("conditionUnlocked", false)):
		_gate_label.text = "配信カスタム / LOCKED\n%s" % String(condition.get("label", "配信図鑑 COLLECTION 21 / 84で解禁"))
		_gate_label.add_theme_color_override("font_color", CommonLightUiStyleScript.SHORTAGE_TEXT)
	else:
		_gate_label.text = "配信カスタム / 解禁済み\n商品を選んで購入・装備できます"
		_gate_label.add_theme_color_override("font_color", CommonLightUiStyleScript.COMBAT_DARK)
	_pp_label.text = "所持PP %s" % _format_points(manager.current_points())

func _refresh_items() -> void:
	for child in _grid.get_children():
		_grid.remove_child(child)
		child.queue_free()
	_item_buttons.clear()
	_items = manager.customization_items_for_category(CATEGORY_IDS[category_index])
	var selected := clampi(int(selected_indices[category_index]), 0, maxi(0, _items.size() - 1))
	selected_indices[category_index] = selected
	for index in range(_items.size()):
		var item: Dictionary = _items[index]
		var status: Dictionary = manager.get_customization_status(String(item.get("id", "")), codex_source)
		var button := Button.new()
		button.name = "CustomizationItem%d" % index
		button.text = "%s\n%s" % [String(item.get("displayName", item.get("id", ""))), String(status.get("state", "LOCKED"))]
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.focus_mode = Control.FOCUS_ALL
		button.pressed.connect(_on_item_pressed.bind(index))
		_grid.add_child(button)
		_item_buttons.append(button)
		_apply_item_button_style(button, status, index == selected)

func _refresh_detail() -> void:
	if _items.is_empty():
		_detail_category_label.text = ""
		_detail_name.text = "商品を選択"
		_detail_description.text = ""
		_detail_condition.text = ""
		_detail_price.text = ""
		_detail_state.text = ""
		_action_button.text = ""
		_action_button.disabled = true
		_preview.configure({}, {}, _current_theme())
		return
	var selected := clampi(int(selected_indices[category_index]), 0, _items.size() - 1)
	selected_indices[category_index] = selected
	var item: Dictionary = _items[selected]
	var status: Dictionary = manager.get_customization_status(String(item.get("id", "")), codex_source)
	var condition: Dictionary = status.get("condition", {}) as Dictionary
	_detail_category_label.text = CustomizationProviderScript.category_label(String(item.get("category", "")))
	_detail_name.text = String(item.get("displayName", item.get("id", "")))
	_detail_description.text = String(item.get("description", ""))
	_detail_condition.text = "解禁条件：%s\n進捗：%s" % [String(condition.get("label", status.get("unlockConditionId", ""))), String(condition.get("progressText", "—"))]
	_detail_price.text = "価格  %s PP" % _format_points(int(status.get("price", item.get("pricePp", 0))))
	var state := String(status.get("state", "LOCKED"))
	_detail_state.text = state
	if bool(status.get("insufficientPoints", false)):
		_detail_state.text += "　（あと%s PP）" % _format_points(int(status.get("shortage", 0)))
	var can_purchase := bool(status.get("canPurchase", false))
	_action_button.disabled = false
	if state == "LOCKED":
		_action_button.text = "条件未達"
		_action_button.disabled = true
	elif state == "AVAILABLE":
		_action_button.text = "購入する\n%s PP" % _format_points(int(status.get("price", 0)))
		_action_button.disabled = not can_purchase
	elif state == "OWNED":
		_action_button.text = "使用する"
	elif state == "EQUIPPED":
		_action_button.text = "使用をやめる"
	else:
		_action_button.text = "利用できません"
		_action_button.disabled = true
	_detail_state.add_theme_color_override("font_color", _state_color(state, bool(status.get("insufficientPoints", false))))
	var preview_theme := _current_theme()
	if String(item.get("category", "")) == "theme":
		preview_theme = CustomizationProviderScript.theme_preset(String(item.get("presentationId", item.get("id", ""))))
	_preview.configure(item, status, preview_theme)
	for index in range(_item_buttons.size()):
		var button: Button = _item_buttons[index]
		_apply_item_button_style(button, manager.get_customization_status(String((_items[index] as Dictionary).get("id", "")), codex_source), index == selected)

func _refresh_focus_visuals() -> void:
	for index in range(_category_buttons.size()):
		var active := index == category_index
		var focused := focus_area == FocusArea.CATEGORIES and active
		_category_buttons[index].add_theme_stylebox_override("focus", _style(CommonLightUiStyleScript.COMBAT_PALE, CommonLightUiStyleScript.COMBAT_MAIN, 3, 14))
		_apply_category_style(_category_buttons[index], active, focused)
	for index in range(_item_buttons.size()):
		var item_status: Dictionary = manager.get_customization_status(String((_items[index] as Dictionary).get("id", "")), codex_source)
		_apply_item_button_style(_item_buttons[index], item_status, focus_area == FocusArea.ITEMS and index == int(selected_indices[category_index]))
	_apply_action_style()
	var back_selected := focus_area == FocusArea.BACK
	_back_button.add_theme_stylebox_override("normal", CommonLightUiStyleScript.create_back_button_style(back_selected))
	_back_button.add_theme_stylebox_override("hover", CommonLightUiStyleScript.create_back_button_style(true))
	_back_button.add_theme_stylebox_override("pressed", CommonLightUiStyleScript.create_back_button_style(true))
	_back_button.add_theme_stylebox_override("focus", CommonLightUiStyleScript.create_back_button_style(true))
	CommonLightUiStyleScript.apply_font(_back_button, 16, true, CommonLightUiStyleScript.BACK_BUTTON_BORDER)

func _apply_category_style(button: Button, active: bool, focused: bool) -> void:
	var fill := CommonLightUiStyleScript.COMBAT_MAIN if active else CommonLightUiStyleScript.MAIN_PANEL
	var border := CommonLightUiStyleScript.COMBAT_MAIN if active or focused else CommonLightUiStyleScript.LILAC_BORDER
	button.add_theme_stylebox_override("normal", _style(fill, border, 3 if active or focused else 1, 14))
	button.add_theme_stylebox_override("hover", _style(fill.lightened(0.06), border, 3, 14))
	button.add_theme_stylebox_override("pressed", _style(CommonLightUiStyleScript.COMBAT_DARK, border, 3, 14))
	CommonLightUiStyleScript.apply_font(button, 16, true, Color.WHITE if active else CommonLightUiStyleScript.TEXT_PRIMARY)

func _apply_item_button_style(button: Button, status: Dictionary, selected: bool) -> void:
	var state := String(status.get("state", "LOCKED"))
	var fill := Color("#f4eff8")
	var border := CommonLightUiStyleScript.LILAC_BORDER
	var text := CommonLightUiStyleScript.TEXT_SECONDARY
	match state:
		"AVAILABLE":
			fill = CommonLightUiStyleScript.COMBAT_PALE
			border = CommonLightUiStyleScript.COMBAT_LIGHT if not selected else CommonLightUiStyleScript.COMBAT_MAIN
			text = CommonLightUiStyleScript.TEXT_PRIMARY
		"OWNED":
			fill = CommonLightUiStyleScript.SUPPORT_PALE
			border = CommonLightUiStyleScript.SUPPORT_LIGHT if not selected else CommonLightUiStyleScript.SUPPORT_MAIN
			text = CommonLightUiStyleScript.SUPPORT_DARK
		"EQUIPPED":
			fill = CommonLightUiStyleScript.PP_PALE
			border = CommonLightUiStyleScript.PP_GOLD
			text = CommonLightUiStyleScript.PP_TEXT
		"LOCKED":
			fill = CommonLightUiStyleScript.DISABLED_FILL
			border = CommonLightUiStyleScript.DISABLED_BORDER
			text = CommonLightUiStyleScript.DISABLED_TEXT
	if selected:
		border = CommonLightUiStyleScript.COMBAT_MAIN
		fill = fill.lightened(0.04)
	button.add_theme_stylebox_override("normal", _style(fill, border, 3 if selected else 2, 14))
	button.add_theme_stylebox_override("hover", _style(fill.lightened(0.06), border, 3, 14))
	button.add_theme_stylebox_override("pressed", _style(fill.darkened(0.04), border, 3, 14))
	button.add_theme_stylebox_override("focus", _style(fill.lightened(0.06), CommonLightUiStyleScript.COMBAT_MAIN, 3, 14))
	CommonLightUiStyleScript.apply_font(button, 14 if _compact else 15, true, text)

func _apply_action_style() -> void:
	if _action_button.disabled:
		CommonLightUiStyleScript.apply_font(_action_button, 16, true, CommonLightUiStyleScript.DISABLED_TEXT)
		_action_button.add_theme_stylebox_override("normal", _style(CommonLightUiStyleScript.DISABLED_FILL, CommonLightUiStyleScript.DISABLED_BORDER, 2, 14))
		_action_button.add_theme_stylebox_override("disabled", _style(CommonLightUiStyleScript.DISABLED_FILL, CommonLightUiStyleScript.DISABLED_BORDER, 2, 14))
	else:
		var state := String(_detail_state.text).split("　")[0]
		if state == "OWNED" or state == "EQUIPPED":
			CommonLightUiStyleScript.apply_font(_action_button, 16, true, CommonLightUiStyleScript.SUPPORT_DARK)
			_action_button.add_theme_stylebox_override("normal", _style(CommonLightUiStyleScript.SUPPORT_PALE, CommonLightUiStyleScript.SUPPORT_MAIN, 2, 14))
		else:
			CommonLightUiStyleScript.apply_font(_action_button, 16, true, Color.WHITE)
			_action_button.add_theme_stylebox_override("normal", _style(CommonLightUiStyleScript.COMBAT_MAIN, CommonLightUiStyleScript.COMBAT_DARK, 2, 14))
		_action_button.add_theme_stylebox_override("hover", _style(CommonLightUiStyleScript.COMBAT_MAIN.lightened(0.08), CommonLightUiStyleScript.COMBAT_DARK, 3, 14))
		_action_button.add_theme_stylebox_override("pressed", _style(CommonLightUiStyleScript.COMBAT_DARK, CommonLightUiStyleScript.COMBAT_DARK, 3, 14))
		_action_button.add_theme_stylebox_override("focus", _style(CommonLightUiStyleScript.COMBAT_MAIN.lightened(0.08), CommonLightUiStyleScript.COMBAT_DARK, 3, 14))

func _on_category_pressed(index: int) -> void:
	_select_category(index)

func _select_category(index: int) -> void:
	body_focus_requested.emit()
	if index == category_index:
		focus_area = FocusArea.CATEGORIES
		_refresh_focus_visuals()
		return
	category_index = clampi(index, 0, CATEGORY_IDS.size() - 1)
	focus_area = FocusArea.CATEGORIES
	_feedback_label.text = ""
	_refresh()
	call_deferred("_ensure_selected_visible")

func _on_item_pressed(index: int) -> void:
	if index < 0 or index >= _items.size():
		return
	body_focus_requested.emit()
	selected_indices[category_index] = index
	focus_area = FocusArea.ITEMS
	_feedback_label.text = ""
	_refresh_detail()
	_refresh_focus_visuals()
	call_deferred("_ensure_selected_visible")

func _on_action_pressed() -> void:
	if manager == null or _items.is_empty() or _action_button.disabled:
		return
	body_focus_requested.emit()
	var index := clampi(int(selected_indices[category_index]), 0, _items.size() - 1)
	var id := String((_items[index] as Dictionary).get("id", ""))
	var status: Dictionary = manager.get_customization_status(id, codex_source)
	var state := String(status.get("state", "LOCKED"))
	if state == "AVAILABLE" and bool(status.get("canPurchase", false)):
		purchase_api_call_count += 1
		var result := int(manager.purchase_customization(id))
		if result == PowerUpShopManagerScript.Result.SUCCESS:
			_feedback_label.text = "購入しました。『使用する』で装備できます"
		else:
			_refresh()
	elif state == "OWNED":
		var equip_result := int(manager.equip_customization(String((_items[index] as Dictionary).get("category", "")), id))
		_feedback_label.text = "装備しました" if equip_result == PowerUpShopManagerScript.Result.SUCCESS else "装備に失敗しました。もう一度試してください"
		_refresh()
	elif state == "EQUIPPED":
		var unequip_result := int(manager.equip_customization(String((_items[index] as Dictionary).get("category", "")), ""))
		_feedback_label.text = "デフォルトに戻しました" if unequip_result == PowerUpShopManagerScript.Result.SUCCESS else "変更に失敗しました。もう一度試してください"
		_refresh()

func _on_purchase_failed(reason: int) -> void:
	if not visible:
		return
	match reason:
		0:
			_feedback_label.text = ""
		PowerUpShopManagerScript.Result.NOT_ENOUGH_POINTS:
			_feedback_label.text = "PPが不足しています"
		PowerUpShopManagerScript.Result.SAVE_FAILED:
			_feedback_label.text = "保存に失敗しました。もう一度実行できます"
		PowerUpShopManagerScript.Result.LOCKED:
			_feedback_label.text = "解禁条件を満たしていません"
		PowerUpShopManagerScript.Result.BUSY:
			_feedback_label.text = "処理中です。少し待ってから実行してください"
		_:
			_feedback_label.text = "購入できません"
	_refresh()

func _on_points_changed(_previous: int, _current: int) -> void:
	_refresh()

func _on_customization_changed(_value = null, _extra = null) -> void:
	_refresh()

func _on_conditions_changed(_value = null) -> void:
	_refresh()

func _on_upgrades_reset(_refund: int) -> void:
	_refresh()

func _on_back_pressed() -> void:
	back_requested.emit()

func _move_focus(direction: Vector2i) -> void:
	if focus_area == FocusArea.CATEGORIES:
		if direction.x != 0:
			_select_category(posmod(category_index + direction.x, CATEGORY_IDS.size()))
		elif direction.y > 0:
			focus_area = FocusArea.ITEMS
			_refresh_focus_visuals()
		elif direction.y < 0:
			upper_focus_requested.emit()
		return
	if focus_area == FocusArea.ACTION:
		if direction.y < 0:
			focus_area = FocusArea.ITEMS
			_refresh_focus_visuals()
		elif direction.y > 0:
			focus_area = FocusArea.BACK
			_refresh_focus_visuals()
		return
	if focus_area == FocusArea.BACK:
		if direction.y < 0:
			focus_area = FocusArea.ITEMS if _action_button.disabled else FocusArea.ACTION
			_refresh_focus_visuals()
		# Horizontal movement must not close the screen accidentally.  The
		# footer has a single Back action; confirm or the platform back button
		# performs the close explicitly.
		return
	if _items.is_empty():
		return
	var current := clampi(int(selected_indices[category_index]), 0, _items.size() - 1)
	var next := current
	if direction.x != 0:
		var column := current % 2
		var candidate := current + direction.x
		if direction.x < 0 and column == 0:
			candidate = current
		if direction.x > 0 and column == 1:
			candidate = current
		if candidate >= 0 and candidate < _items.size():
			next = candidate
	elif direction.y < 0:
		if current >= 2:
			next = current - 2
		else:
			focus_area = FocusArea.CATEGORIES
			_refresh_focus_visuals()
			return
	else:
		if current + 2 < _items.size():
			next = current + 2
		else:
			focus_area = FocusArea.BACK if _action_button.disabled else FocusArea.ACTION
			_refresh_focus_visuals()
			return
	if next != current:
		selected_indices[category_index] = next
		_refresh_detail()
		_refresh_focus_visuals()
		call_deferred("_ensure_selected_visible")

func _activate_focus() -> void:
	match focus_area:
		FocusArea.CATEGORIES:
			focus_area = FocusArea.ITEMS
			_refresh_focus_visuals()
		FocusArea.ITEMS, FocusArea.ACTION:
			_on_action_pressed()
		FocusArea.BACK:
			_on_back_pressed()

func focus_categories() -> void:
	focus_area = FocusArea.CATEGORIES
	_refresh_focus_visuals()

func focus_items() -> void:
	focus_area = FocusArea.ITEMS
	_refresh_focus_visuals()

func _ensure_selected_visible() -> void:
	if _item_buttons.is_empty() or not is_instance_valid(_item_buttons[0]):
		return
	var index := clampi(int(selected_indices[category_index]), 0, _item_buttons.size() - 1)
	_scroll.ensure_control_visible(_item_buttons[index])

func _current_theme() -> Dictionary:
	if manager == null:
		return CustomizationProviderScript.theme_preset("")
	var equipped: Dictionary = manager.equipped_customizations()
	return CustomizationProviderScript.theme_preset(String(equipped.get("theme", "")))

func _state_color(state: String, insufficient: bool) -> Color:
	if insufficient:
		return CommonLightUiStyleScript.SHORTAGE_TEXT
	match state:
		"LOCKED": return CommonLightUiStyleScript.DISABLED_TEXT
		"OWNED": return CommonLightUiStyleScript.SUPPORT_DARK
		"EQUIPPED": return CommonLightUiStyleScript.PP_TEXT
		_: return CommonLightUiStyleScript.COMBAT_DARK

func _new_label(text: String, font_size: int, black: bool, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if black:
		GameFontSystemScript.apply_black_font(label)
	else:
		GameFontSystemScript.apply_regular_font(label)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	add_child(label)
	return label

func _place(control: Control, rect: Rect2) -> void:
	if control == null:
		return
	control.position = rect.position
	control.size = rect.size

func _format_points(value: int) -> String:
	var digits := str(maxi(0, value))
	var result := ""
	var count := 0
	for index in range(digits.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = digits.substr(index, 1) + result
		count += 1
	return result

func _style(fill: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	return CommonLightUiStyleScript.create_panel_style(fill, border, width, radius, 12.0, 8.0)
