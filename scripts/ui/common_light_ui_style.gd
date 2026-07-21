class_name CommonLightUiStyle
extends RefCounted

const GameFontSystemScript := preload("res://scripts/systems/game_font_system.gd")

# Shared light-theme palette. Canvas-drawn screens use these values directly;
# Control-based screens use the StyleBox factories below.
const BACKGROUND_WASH := Color("#F7EEFF")
const MAIN_PANEL := Color("#FFF9FD")
const MAIN_PANEL_BORDER := Color("#F0A3C9")
const TEXT_PRIMARY := Color("#3F2C4E")
const TEXT_SECONDARY := Color("#765F78")
const TEXT_MUTED := Color("#96839A")
const DIVIDER := Color("#E8D5E5")
const ENGLISH_TITLE := Color("#EF6BA4")
const COMBAT_MAIN := Color("#EE75AA")
const COMBAT_LIGHT := Color("#F7B7D3")
const COMBAT_PALE := Color("#FFF0F6")
const COMBAT_DARK := Color("#D85E91")
const COMBAT_HERO := Color("#F0A4C6")
const SUPPORT_MAIN := Color("#62BED8")
const SUPPORT_LIGHT := Color("#A7DDEA")
const SUPPORT_PALE := Color("#EEF9FC")
const SUPPORT_DARK := Color("#2586B5")
const SUPPORT_HERO := Color("#A7DDEB")
const LILAC := Color("#EEE8F3")
const LILAC_BORDER := Color("#DCCCE4")
const PP_GOLD := Color("#EFCB47")
const PP_TEXT := Color("#B77E16")
const PP_PALE := Color("#FFF8D9")
const SHORTAGE_TEXT := Color("#DF678F")
const SHORTAGE_PALE := Color("#FFF0F4")
const SHORTAGE_BORDER := Color("#F3A0BD")
const MAX_PALE := Color("#FFF6CF")
const MAX_BORDER := Color("#E6C24A")
const DISABLED_FILL := Color("#EEE8F0")
const DISABLED_BORDER := Color("#D6CADC")
const DISABLED_TEXT := Color("#8B8090")
const BACK_BUTTON_FILL := Color("#EEF8FF")
const BACK_BUTTON_SELECTED_FILL := Color("#DDF3FC")
const BACK_BUTTON_BORDER := Color("#258EBE")
const RESET_BUTTON_FILL := Color("#FFF4F8")
const RESET_BUTTON_SELECTED_FILL := Color("#FFE5F0")
const RESET_BUTTON_BORDER := Color("#E93681")
const OPTION_BACKGROUND_FALLBACK := Color("#FFF3FA")
const OPTION_BACKGROUND_TOP := Color("#F4E7FF")
const OPTION_WASH := Color(1.0, 0.94, 0.98, 0.42)
const OPTION_PANEL_FILL := Color(1.0, 0.992, 1.0, 0.97)
const OPTION_PANEL_BORDER := Color("#FFBAD8")
const OPTION_HEADER := Color("#E73778")
const OPTION_TEXT := Color("#6B4A63")
const OPTION_CARD_FILL := Color("#FFF5FB")
const OPTION_CARD_BORDER := Color("#F2D7E8")
const OPTION_CONTROL_TRACK := Color("#F6EAF2")
const OPTION_CONTROL_BORDER := Color("#EAD4E4")
const OPTION_ACCENT_PINK := Color("#F25A9B")
const OPTION_ACCENT_BLUE := Color("#4FB8DF")
const OPTION_ACCENT_PURPLE := Color("#A768DC")
const OPTION_ACCENT_INDIGO := Color("#6D8DDE")
const OPTION_ACCENT_TEAL := Color("#2FBFB6")
const OPTION_ACCENT_MAGENTA := Color("#D673C4")

static func _style(fill: Color, border: Color = Color.TRANSPARENT, border_width: int = 0, radius: int = 16) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	return style

static func create_panel_style(fill: Color, border: Color = Color.TRANSPARENT, border_width: int = 0, radius: int = 16, horizontal_margin: float = 18.0, vertical_margin: float = 14.0) -> StyleBoxFlat:
	var style := _style(fill, border, border_width, radius)
	style.content_margin_left = horizontal_margin
	style.content_margin_right = horizontal_margin
	style.content_margin_top = vertical_margin
	style.content_margin_bottom = vertical_margin
	return style

static func create_large_panel_style() -> StyleBoxFlat:
	var style := create_panel_style(Color(MAIN_PANEL, 0.93), MAIN_PANEL_BORDER, 3, 30, 28.0, 24.0)
	style.shadow_color = Color(0.46, 0.37, 0.49, 0.12)
	style.shadow_size = 10
	style.shadow_offset = Vector2(0, 4)
	return style

static func create_row_normal_style() -> StyleBoxFlat:
	return create_panel_style(Color(1, 1, 1, 0.88), LILAC_BORDER, 2, 20, 18.0, 12.0)

static func create_row_selected_pink_style() -> StyleBoxFlat:
	var style := create_panel_style(COMBAT_PALE, COMBAT_MAIN, 3, 20, 18.0, 12.0)
	style.shadow_color = Color(COMBAT_MAIN, 0.18)
	style.shadow_size = 7
	return style

static func create_row_selected_blue_style() -> StyleBoxFlat:
	var style := create_panel_style(SUPPORT_PALE, SUPPORT_MAIN, 3, 20, 18.0, 12.0)
	style.shadow_color = Color(SUPPORT_MAIN, 0.18)
	style.shadow_size = 7
	return style

static func create_back_button_style(selected: bool = false) -> StyleBoxFlat:
	var fill := BACK_BUTTON_SELECTED_FILL if selected else BACK_BUTTON_FILL
	var style := create_panel_style(fill, BACK_BUTTON_BORDER, 3 if selected else 2, 16, 14.0, 8.0)
	if selected:
		style.shadow_color = Color(SUPPORT_MAIN, 0.22)
		style.shadow_size = 6
	return style

static func create_reset_button_style(selected: bool = false) -> StyleBoxFlat:
	var fill := RESET_BUTTON_SELECTED_FILL if selected else RESET_BUTTON_FILL
	var style := create_panel_style(fill, RESET_BUTTON_BORDER, 3 if selected else 2, 16, 14.0, 8.0)
	if selected:
		style.shadow_color = Color(COMBAT_MAIN, 0.20)
		style.shadow_size = 6
	return style

static func create_value_field_style() -> StyleBoxFlat:
	return create_panel_style(Color("#FFFDFE"), LILAC_BORDER, 2, 18, 14.0, 8.0)

static func create_tab_style(active: bool, accent: Color) -> StyleBoxFlat:
	var fill := accent if active else MAIN_PANEL
	var border := accent.lightened(0.12) if active else LILAC_BORDER
	var style := create_panel_style(fill, border, 3 if active else 1, 16, 16.0, 8.0)
	if active:
		style.shadow_color = Color(accent, 0.16)
		style.shadow_size = 5
	return style

static func create_outer_focus_ring_style(accent: Color) -> StyleBoxFlat:
	var style := create_panel_style(Color(1, 1, 1, 0), Color(accent, 0.94), 2, 20, 0.0, 0.0)
	return style

static func create_footer_style() -> StyleBoxFlat:
	var style := create_panel_style(Color(MAIN_PANEL, 0.26), DIVIDER, 0, 12, 12.0, 8.0)
	style.border_width_top = 2
	return style

static func apply_font(control: Control, size: int = 16, black: bool = false, color: Color = TEXT_PRIMARY) -> void:
	if black:
		GameFontSystemScript.apply_black_font(control)
	else:
		GameFontSystemScript.apply_regular_font(control)
	control.add_theme_font_size_override("font_size", size)
	control.add_theme_color_override("font_color", color)
	control.add_theme_color_override("font_hover_color", color)
	control.add_theme_color_override("font_pressed_color", color)
	control.add_theme_color_override("font_focus_color", color)
