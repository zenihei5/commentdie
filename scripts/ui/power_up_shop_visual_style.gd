class_name PowerUpShopVisualStyle
extends RefCounted

const GameFontSystemScript := preload("res://scripts/systems/game_font_system.gd")

const BACKGROUND_TOP := Color("#292252")
const BACKGROUND_BOTTOM := Color("#141226")
const PANEL := Color("#211B43")
const CARD := Color("#F7F3FF")
const CARD_SUBTLE := Color("#EDE6FA")
const DETAIL := Color("#FCF9FF")
const PRIMARY := Color("#302846")
const SECONDARY := Color("#746B8D")
const TEXT_DARK := Color("#292252")
const TEXT_LIGHT := Color("#FFF9FF")
const COMBAT := Color("#FF8FBD")
const COMBAT_DARK := Color("#D9699D")
const SUPPORT := Color("#79D9EF")
const SUPPORT_DARK := Color("#51B8D2")
const PP := Color("#FFD767")
const PP_DARK := Color("#E6B93B")
const WARNING := Color("#F16F87")
const DISABLED := Color("#AAA2BB")
const LAMP_OFF := Color("#F8F5FD")
const LAMP_BORDER := Color("#D0C4DF")
const PRICE_FILL := Color("#FFF3C4")
const INSUFFICIENT_FILL := Color("#FFE4EB")
const MAX_FILL := Color("#FFF1B8")
const TAG_FILL := Color("#EEE8F7")
const TAG_TEXT := Color("#665D7B")
const BUTTON_DISABLED_FILL := Color("#D8D2E2")
const BUTTON_DISABLED_BORDER := Color("#BDB4CA")
const BUTTON_DISABLED_TEXT := Color("#81788F")
const TIER_UNPURCHASED_FILL := Color("#F3EFF9")
const TIER_LOW_FILL := Color("#FFF4FA")
const TIER_HIGH_FILL := Color("#EFFBFF")
const TIER_MAX_FILL := Color("#FFF8D5")
const TIER_MAX_BORDER := Color("#E7B83D")
const PROGRESS_TRACK := Color("#4D456D")
const MASCOT_DIM := Color("#B8B0CB")

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
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 18.0
	style.content_margin_right = 18.0
	style.content_margin_top = 14.0
	style.content_margin_bottom = 14.0
	return style

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
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", hover)
	apply_font(button, 17, true, text_color)

static func apply_tab_theme(button: Button, active: bool, accent: Color, accent_dark: Color) -> void:
	var fill := accent.darkened(0.12) if active else PANEL.darkened(0.04)
	var border := accent if active else SECONDARY
	var normal := button_style(fill, border, 3 if active else 1, 14)
	var hover := button_style(fill.lightened(0.08), accent, 3, 14)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", button_style(accent_dark, accent, 3, 14))
	button.add_theme_stylebox_override("focus", hover)
	apply_font(button, 17, true, TEXT_LIGHT)
