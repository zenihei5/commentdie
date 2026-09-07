class_name PowerUpShopCard
extends Button

signal card_selected(index: int)
signal hover_changed(index: int, hovering: bool)

const UiState := preload("res://scripts/ui/power_up_shop_ui_state.gd")
const VisualStyle := preload("res://scripts/ui/power_up_shop_visual_style.gd")
const CommonLightUiStyle := preload("res://scripts/ui/common_light_ui_style.gd")

@onready var card_icon: TextureRect = $VisualRoot/CardContent/VBox/HeaderRow/IconSlot/IconPlate/Icon
@onready var card_surface: PanelContainer = $VisualRoot/CardSurface
@onready var icon_plate: PanelContainer = $VisualRoot/CardContent/VBox/HeaderRow/IconSlot/IconPlate
@onready var title_label: Label = $VisualRoot/CardContent/VBox/HeaderRow/TextColumn/UpgradeName
@onready var level_label: Label = $VisualRoot/CardContent/VBox/HeaderRow/TextColumn/MetaRow/LevelLabel
@onready var price_capsule: PanelContainer = $VisualRoot/CardContent/VBox/PriceCapsule
@onready var price_label: Label = $VisualRoot/CardContent/VBox/PriceCapsule/PriceLabel
@onready var effect_summary: Label = $VisualRoot/CardContent/VBox/EffectSummary
@onready var selection_lamp: ColorRect = $VisualRoot/SelectionLamp
@onready var category_accent: ColorRect = $VisualRoot/CategoryAccent
@onready var tier_decoration: ColorRect = $VisualRoot/TierDecoration
@onready var card_pattern: Control = $VisualRoot/CardPattern
@onready var focus_ring: PanelContainer = $VisualRoot/FocusRing
@onready var max_ribbon: PanelContainer = $VisualRoot/CardContent/VBox/HeaderRow/TextColumn/MetaRow/MaxRibbon
@onready var max_ribbon_label: Label = $VisualRoot/CardContent/VBox/HeaderRow/TextColumn/MetaRow/MaxRibbon/Label
@onready var star_burst: Label = $VisualRoot/StarBurst
@onready var visual_root: Control = $VisualRoot

var upgrade_data: Dictionary = {}
var upgrade_index := 0
var selected := false
var hovered := false
var logical_focused := false
var cursor_visible := true
var last_input_device := "keyboard"
var affordable := true
var maxed := false
var visual_tier := UiState.UpgradeVisualTier.UNPURCHASED
var category_color := VisualStyle.COMBAT
var purchase_state := UiState.PurchaseState.PURCHASABLE
var purchase_view: Dictionary = {}
var visual_style: Dictionary = {}
var lamp_panels: Array[PanelContainer] = []
var purchase_animation_index := -1
var _level := 0
var _focus_tween: Tween
var _success_tween: Tween
var _transform_tween: Tween
var _base_visual_position := Vector2.ZERO

func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	card_icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	card_icon.texture_repeat = CanvasItem.TEXTURE_REPEAT_DISABLED
	_make_input_slot_transparent()
	_base_visual_position = visual_root.position
	visual_root.resized.connect(_on_visual_root_resized)
	_on_visual_root_resized()
	for index in range(5):
		lamp_panels.append(get_node("VisualRoot/CardContent/VBox/LevelIndicators/Lamp%d" % index) as PanelContainer)
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)
	if not mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)
	if not mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.connect(_on_mouse_exited)
	VisualStyle.apply_font(title_label, 18, true, VisualStyle.TEXT_DARK)
	VisualStyle.apply_font(level_label, 14, false, VisualStyle.SECONDARY)
	VisualStyle.apply_font(price_label, 14, true, VisualStyle.TEXT_DARK)
	VisualStyle.apply_font(effect_summary, 13, false, VisualStyle.SECONDARY)
	VisualStyle.apply_font(max_ribbon_label, 12, true, VisualStyle.TEXT_DARK)
	VisualStyle.apply_font(star_burst, 22, true, VisualStyle.PP)
	if not upgrade_data.is_empty():
		_update_visuals(purchase_view, selected)

func configure(data: Dictionary, index: int, view: Dictionary, is_selected: bool) -> void:
	upgrade_data = data.duplicate(true)
	upgrade_index = index
	selected = is_selected
	purchase_view = view
	category_color = VisualStyle.COMBAT if String(data.get("category", "combat")) == "combat" else VisualStyle.SUPPORT
	if is_node_ready():
		_update_visuals(view, is_selected)

func update_state(view: Dictionary, is_selected: bool) -> void:
	_update_visuals(view, is_selected)

func set_selected(value: bool) -> void:
	selected = value
	if is_node_ready():
		_apply_card_style()
		_apply_selection_transform()

func set_logical_focus(value: bool) -> void:
	if logical_focused == value:
		return
	logical_focused = value
	if is_node_ready():
		focus_ring.visible = cursor_visible and value
		focus_ring.add_theme_stylebox_override("panel", VisualStyle.focus_ring_style(CommonLightUiStyle.COMBAT_MAIN))
		_apply_card_style()
		_apply_selection_transform()

func set_cursor_visible(value: bool) -> void:
	cursor_visible = value
	if is_node_ready():
		focus_ring.visible = cursor_visible and logical_focused
		_apply_card_style()
		_apply_selection_transform()

func set_input_device(device: String) -> void:
	last_input_device = device
	if is_node_ready():
		_apply_card_style()
		_apply_selection_transform()

func stop_animations() -> void:
	if _focus_tween != null and is_instance_valid(_focus_tween):
		_focus_tween.kill()
	_focus_tween = null
	if _success_tween != null and is_instance_valid(_success_tween):
		_success_tween.kill()
	_success_tween = null
	if _transform_tween != null and is_instance_valid(_transform_tween):
		_transform_tween.kill()
	_transform_tween = null
	if is_node_ready():
		self_modulate = Color.WHITE
		_apply_selection_transform(true)
		star_burst.modulate = Color(1, 1, 1, 0)
		max_ribbon.visible = maxed
		max_ribbon_label.text = "MAX"
		max_ribbon.modulate = Color.WHITE
		for lamp in lamp_panels:
			lamp.scale = Vector2.ONE
		_apply_card_style()
		focus_ring.visible = cursor_visible and logical_focused

func play_purchase_success(new_level: int = -1) -> void:
	stop_animations()
	var target_index: int = new_level - 1 if new_level > 0 else maxi(0, _level - 1)
	if target_index < 0 or target_index >= lamp_panels.size():
		return
	purchase_animation_index = target_index
	var lamp := lamp_panels[target_index]
	_success_tween = create_tween()
	_success_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_success_tween.tween_property(lamp, "scale", Vector2(0.7, 0.7), 0.01)
	_success_tween.tween_property(lamp, "scale", Vector2(1.2, 1.2), 0.14)
	_success_tween.tween_property(lamp, "scale", Vector2.ONE, 0.14)
	_success_tween.parallel().tween_property(icon_plate, "position", Vector2(0, -4), 0.12)
	_success_tween.tween_property(icon_plate, "position", Vector2.ZERO, 0.18)
	_success_tween.parallel().tween_property(star_burst, "modulate", Color.WHITE, 0.08)
	_success_tween.tween_property(star_burst, "modulate", Color(1, 1, 1, 0), 0.24)
	if new_level >= int(purchase_view.get("maxLevel", 5)):
		max_ribbon.visible = true
		max_ribbon_label.text = "MAX"
		max_ribbon.modulate = Color(1, 1, 1, 0)
		max_ribbon.add_theme_stylebox_override("panel", VisualStyle.compact_panel(VisualStyle.TIER_MAX_FILL, VisualStyle.TIER_MAX_BORDER, 2, 10, 6, 2))
		_success_tween.parallel().tween_property(max_ribbon, "modulate", Color.WHITE, 0.12)

func _update_visuals(view: Dictionary, is_selected: bool) -> void:
	purchase_view = view
	visual_style = (purchase_view.get("visualStyle", upgrade_data.get("visualStyle", {})) as Dictionary).duplicate(true)
	_level = int(purchase_view.get("level", 0))
	purchase_state = int(purchase_view.get("state", UiState.PurchaseState.PURCHASABLE))
	affordable = purchase_state == UiState.PurchaseState.PURCHASABLE
	maxed = purchase_state == UiState.PurchaseState.MAX_LEVEL
	visual_tier = int(purchase_view.get("visualTier", UiState.UpgradeVisualTier.UNPURCHASED))
	selected = is_selected
	max_ribbon.visible = maxed
	max_ribbon_label.text = "MAX"
	max_ribbon.modulate = Color.WHITE
	title_label.text = String(upgrade_data.get("displayName", upgrade_data.get("id", "")))
	level_label.text = "Lv %d / %d" % [_level, int(purchase_view.get("maxLevel", 5))]
	effect_summary.text = String(purchase_view.get("cardEffectSummary", ""))
	effect_summary.add_theme_color_override("font_color", category_color.darkened(0.18) if visual_tier != UiState.UpgradeVisualTier.UNPURCHASED else VisualStyle.SECONDARY)
	var icon_path := String(upgrade_data.get("iconPath", ""))
	card_icon.texture = load(icon_path) as Texture2D if icon_path != "" else null
	_update_lamps()
	_update_price()
	_update_category_style()
	_apply_card_style()
	_apply_selection_transform()

func _update_lamps() -> void:
	for index in range(lamp_panels.size()):
		var lit := index < _level
		var fill := category_color if lit else VisualStyle.LAMP_OFF
		var border := category_color.darkened(0.12) if lit else VisualStyle.LAMP_BORDER
		if lit and maxed and index == lamp_panels.size() - 1:
			fill = VisualStyle.PP
			border = VisualStyle.PP_DARK
		lamp_panels[index].add_theme_stylebox_override("panel", VisualStyle.lamp_style(fill, border))

func _update_price() -> void:
	price_label.text = String(purchase_view.get("cardPriceText", ""))
	match purchase_state:
		UiState.PurchaseState.PURCHASABLE:
			price_label.add_theme_color_override("font_color", VisualStyle.TEXT_DARK)
			price_capsule.add_theme_stylebox_override("panel", VisualStyle.compact_panel(VisualStyle.PRICE_FILL, VisualStyle.PP, 1, 14, 8, 3))
		UiState.PurchaseState.NOT_ENOUGH_PP:
			price_label.add_theme_color_override("font_color", VisualStyle.WARNING)
			price_capsule.add_theme_stylebox_override("panel", VisualStyle.compact_panel(VisualStyle.INSUFFICIENT_FILL, VisualStyle.WARNING, 1, 14, 8, 3))
		_:
			price_label.add_theme_color_override("font_color", VisualStyle.PP_DARK)
			price_capsule.add_theme_stylebox_override("panel", VisualStyle.compact_panel(VisualStyle.MAX_FILL, VisualStyle.PP_DARK, 1, 14, 8, 3))

func _update_category_style() -> void:
	var base_color := Color(String(visual_style.get("baseColor", "#F7F3FF")))
	var accent_color := Color(String(visual_style.get("accentColor", category_color.to_html(false))))
	category_accent.color = accent_color
	var tier_fill := base_color.lerp(VisualStyle.tier_fill(visual_tier, category_color), 0.18)
	var tier_border := accent_color if visual_tier != UiState.UpgradeVisualTier.UNPURCHASED else VisualStyle.tier_border(visual_tier, category_color)
	tier_decoration.color = Color(tier_fill, 0.30)
	card_pattern.call("configure", visual_style, visual_tier)
	icon_plate.add_theme_stylebox_override("panel", VisualStyle.compact_panel(tier_fill, tier_border, 2, 16, 0, 0))
	max_ribbon.add_theme_stylebox_override("panel", VisualStyle.compact_panel(VisualStyle.TIER_MAX_FILL, VisualStyle.TIER_MAX_BORDER, 2, 10, 6, 2))
	focus_ring.add_theme_stylebox_override("panel", VisualStyle.focus_ring_style(CommonLightUiStyle.COMBAT_MAIN))

func _apply_card_style() -> void:
	if not is_node_ready():
		return
	var hover_visible := hovered and last_input_device == "mouse"
	var card_operation_focused := _has_card_operation_focus()
	_refresh_z_order()
	selection_lamp.visible = (cursor_visible and logical_focused) or hover_visible
	var accent_color := Color(String(visual_style.get("accentColor", category_color.to_html(false))))
	var selection_accent := CommonLightUiStyle.COMBAT_MAIN
	selection_lamp.color = selection_accent if card_operation_focused else accent_color
	var border := selection_accent if card_operation_focused else (accent_color if hover_visible else VisualStyle.tier_border(visual_tier, category_color))
	var border_width := 4 if card_operation_focused else (2 if hover_visible else 1)
	var fill := Color(String(visual_style.get("baseColor", "#F7F3FF")))
	fill = fill.lerp(VisualStyle.tier_fill(visual_tier, category_color), 0.18)
	if card_operation_focused:
		fill = fill.lerp(CommonLightUiStyle.COMBAT_PALE, 0.34)
	var normal_style := VisualStyle.button_style(fill, border, border_width, 16)
	if card_operation_focused:
		normal_style.shadow_color = Color(selection_accent, 0.18)
		normal_style.shadow_size = 7
		normal_style.shadow_offset = Vector2.ZERO
	card_surface.add_theme_stylebox_override("panel", normal_style)

func _has_card_operation_focus() -> bool:
	return selected and logical_focused and cursor_visible

func _make_input_slot_transparent() -> void:
	var empty_style := StyleBoxEmpty.new()
	for state_name in ["normal", "hover", "pressed", "focus", "disabled"]:
		add_theme_stylebox_override(state_name, empty_style)

func _refresh_z_order() -> void:
	var hover_visible := hovered and last_input_device == "mouse"
	z_index = 3 if _has_card_operation_focus() else (2 if hover_visible or (logical_focused and cursor_visible) else 0)

func _apply_selection_transform(instant: bool = false) -> void:
	if not is_node_ready():
		return
	if _transform_tween != null and is_instance_valid(_transform_tween):
		_transform_tween.kill()
		_transform_tween = null
	var hover_visible := hovered and last_input_device == "mouse"
	var target_scale := Vector2(1.025, 1.025) if _has_card_operation_focus() else (Vector2(1.01, 1.01) if hover_visible else Vector2.ONE)
	var target_position := _base_visual_position
	if instant:
		visual_root.scale = target_scale
		visual_root.position = target_position
		return
	_transform_tween = create_tween()
	_transform_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_transform_tween.parallel().tween_property(visual_root, "scale", target_scale, 0.16)
	_transform_tween.parallel().tween_property(visual_root, "position", target_position, 0.16)

func _on_visual_root_resized() -> void:
	if is_node_ready():
		visual_root.pivot_offset = visual_root.size * 0.5

func _on_pressed() -> void:
	card_selected.emit(upgrade_index)

func _on_mouse_entered() -> void:
	hovered = true
	_apply_card_style()
	_apply_selection_transform()
	hover_changed.emit(upgrade_index, true)

func _on_mouse_exited() -> void:
	hovered = false
	_apply_card_style()
	_apply_selection_transform()
	hover_changed.emit(upgrade_index, false)
