class_name PowerUpShopVisualStyle
extends RefCounted

const GameFontSystemScript := preload("res://scripts/systems/game_font_system.gd")
const CommonLightUiStyle := preload("res://scripts/ui/common_light_ui_style.gd")

const BACKGROUND_TOP := Color("#292252")
const BACKGROUND_BOTTOM := Color("#141226")
const PANEL := CommonLightUiStyle.MAIN_PANEL
const CARD := Color("#FFFFFF")
const CARD_SUBTLE := CommonLightUiStyle.LILAC
const DETAIL := Color("#FFFDFE")
const PRIMARY := CommonLightUiStyle.TEXT_PRIMARY
const SECONDARY := CommonLightUiStyle.TEXT_SECONDARY
const TEXT_DARK := CommonLightUiStyle.TEXT_PRIMARY
const TEXT_LIGHT := Color("#FFFFFF")
const COMBAT := CommonLightUiStyle.COMBAT_MAIN
const COMBAT_DARK := CommonLightUiStyle.COMBAT_DARK
const SUPPORT := CommonLightUiStyle.SUPPORT_MAIN
const SUPPORT_DARK := CommonLightUiStyle.SUPPORT_DARK
const PP := CommonLightUiStyle.PP_GOLD
const PP_DARK := CommonLightUiStyle.PP_TEXT
const WARNING := CommonLightUiStyle.SHORTAGE_TEXT
const DISABLED := CommonLightUiStyle.DISABLED_TEXT
const LAMP_OFF := Color("#FCF9FF")
const LAMP_BORDER := CommonLightUiStyle.LILAC_BORDER
const PRICE_FILL := CommonLightUiStyle.PP_PALE
const INSUFFICIENT_FILL := CommonLightUiStyle.SHORTAGE_PALE
const MAX_FILL := CommonLightUiStyle.MAX_PALE
const TAG_FILL := CommonLightUiStyle.LILAC
const TAG_TEXT := Color("#67556C")
const BUTTON_DISABLED_FILL := CommonLightUiStyle.DISABLED_FILL
const BUTTON_DISABLED_BORDER := CommonLightUiStyle.DISABLED_BORDER
const BUTTON_DISABLED_TEXT := CommonLightUiStyle.DISABLED_TEXT
const TIER_UNPURCHASED_FILL := Color("#F3EFF9")
const TIER_LOW_FILL := Color("#FFF4FA")
const TIER_HIGH_FILL := Color("#EFFBFF")
const TIER_MAX_FILL := Color("#FFF8D5")
const TIER_MAX_BORDER := Color("#E7B83D")
const PROGRESS_TRACK := Color("#E8DDEB")
const MASCOT_DIM := Color("#B9AABC")

static func tier_fill(tier: int, category_color: Color) -> Color:
	match tier:
		1:
			return TIER_LOW_FILL
		2:
			return TIER_HIGH_FILL
		3:
			return TIER_MAX_FILL
		_:
			return TIER_UNPURCHASED_FILL

static func tier_border(tier: int, category_color: Color) -> Color:
	match tier:
		1, 2:
			return category_color
		3:
			return TIER_MAX_BORDER
		_:
			return LAMP_BORDER

static func progress_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := compact_panel(fill, border, 1, 8, 0, 0)
	style.set_corner_radius_all(8)
	return style

static func focus_ring_style(accent: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 1, 0)
	style.border_color = Color(accent, 0.82)
	style.set_border_width_all(2)
	style.set_corner_radius_all(16)
	style.expand_margin_left = 4.0
	style.expand_margin_top = 4.0
	style.expand_margin_right = 4.0
	style.expand_margin_bottom = 4.0
	return style

static func background_texture() -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.set_colors(PackedColorArray([BACKGROUND_TOP, BACKGROUND_BOTTOM]))
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 64
	texture.height = 64
	texture.fill_from = Vector2(0.0, 0.0)
	texture.fill_to = Vector2(0.0, 1.0)
	return texture

static func rounded_panel(fill: Color, border: Color = Color.TRANSPARENT, border_width: int = 0, radius: int = 16) -> StyleBoxFlat:
	return CommonLightUiStyle.create_panel_style(fill, border, border_width, radius)

static func button_style(fill: Color, border: Color, border_width: int = 2, radius: int = 12) -> StyleBoxFlat:
	return rounded_panel(fill, border, border_width, radius)

static func lamp_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(9)
	return style

static func compact_panel(fill: Color, border: Color = Color.TRANSPARENT, border_width: int = 0, radius: int = 10, horizontal_margin: float = 8.0, vertical_margin: float = 4.0) -> StyleBoxFlat:
	var style := rounded_panel(fill, border, border_width, radius)
	style.content_margin_left = horizontal_margin
	style.content_margin_right = horizontal_margin
	style.content_margin_top = vertical_margin
	style.content_margin_bottom = vertical_margin
	return style

static func apply_font(control: Control, size: int = 16, black: bool = false, color: Color = TEXT_DARK) -> void:
	if black:
		GameFontSystemScript.apply_black_font(control)
	else:
		GameFontSystemScript.apply_regular_font(control)
	control.add_theme_font_size_override("font_size", size)
	control.add_theme_color_override("font_color", color)
	control.add_theme_color_override("font_hover_color", color)
	control.add_theme_color_override("font_pressed_color", color)
	control.add_theme_color_override("font_focus_color", color)

static func apply_button_theme(button: Button, fill: Color, accent: Color, text_color: Color = TEXT_LIGHT) -> void:
	var normal := button_style(fill, accent, 2, 12)
	var hover := button_style(fill.lightened(0.09), accent.lightened(0.08), 3, 12)
	var pressed := button_style(fill.darkened(0.08), accent, 3, 12)
	var disabled := button_style(BUTTON_DISABLED_FILL, BUTTON_DISABLED_BORDER, 2, 12)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", hover)
	button.add_theme_stylebox_override("disabled", disabled)
	apply_font(button, 17, true, text_color)
	button.add_theme_color_override("font_disabled_color", BUTTON_DISABLED_TEXT)

static func apply_tab_theme(button: Button, active: bool, _accent: Color, _accent_dark: Color) -> void:
	var selection_accent := CommonLightUiStyle.COMBAT_MAIN
	var selection_dark := CommonLightUiStyle.COMBAT_DARK
	var normal := CommonLightUiStyle.create_tab_style(active, selection_accent)
	var hover := CommonLightUiStyle.create_tab_style(true, selection_accent.lightened(0.04))
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", button_style(selection_dark, selection_accent, 3, 14))
	button.add_theme_stylebox_override("focus", hover)
	apply_font(button, 17, true, TEXT_LIGHT if active else TEXT_DARK)

static func apply_back_button_theme(button: Button, selected: bool = false) -> void:
	button.add_theme_stylebox_override("normal", CommonLightUiStyle.create_back_button_style(selected))
	button.add_theme_stylebox_override("hover", CommonLightUiStyle.create_back_button_style(true))
	button.add_theme_stylebox_override("pressed", CommonLightUiStyle.create_back_button_style(true))
	button.add_theme_stylebox_override("focus", CommonLightUiStyle.create_back_button_style(true))
	apply_font(button, 17, true, CommonLightUiStyle.BACK_BUTTON_BORDER)

static func apply_reset_button_theme(button: Button, selected: bool = false) -> void:
	button.add_theme_stylebox_override("normal", CommonLightUiStyle.create_reset_button_style(selected))
	button.add_theme_stylebox_override("hover", CommonLightUiStyle.create_reset_button_style(true))
	button.add_theme_stylebox_override("pressed", CommonLightUiStyle.create_reset_button_style(true))
	button.add_theme_stylebox_override("focus", CommonLightUiStyle.create_reset_button_style(true))
	apply_font(button, 17, true, CommonLightUiStyle.RESET_BUTTON_BORDER)
