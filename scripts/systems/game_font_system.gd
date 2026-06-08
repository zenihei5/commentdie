class_name GameFontSystem
extends RefCounted

const REGULAR_FONT: Font = preload("res://assets/fonts/MPLUSRounded1c-Regular.ttf")
const BLACK_FONT: Font = preload("res://assets/fonts/MPLUSRounded1c-Black.ttf")
const BLACK_SIZE_THRESHOLD := 28

static func regular_font() -> Font:
	return REGULAR_FONT if REGULAR_FONT != null else ThemeDB.fallback_font

static func black_font() -> Font:
	return BLACK_FONT if BLACK_FONT != null else regular_font()

static func font_for_weight(weight: String, size: int) -> Font:
	var normalized := weight.to_lower()
	if normalized == "black" or normalized == "bold" or normalized == "heavy":
		return black_font()
	if normalized == "regular":
		return regular_font()
	return black_font() if size >= BLACK_SIZE_THRESHOLD else regular_font()

static func font_for_item(item: Dictionary, prefix: String = "") -> Font:
	var size_key := prefix + "Size" if prefix != "" else "size"
	var weight_key := prefix + "FontWeight" if prefix != "" else "fontWeight"
	return font_for_weight(String(item.get(weight_key, "")), int(item.get(size_key, 16)))

static func apply_regular_font(control: Control) -> void:
	if control != null:
		control.add_theme_font_override("font", regular_font())

static func apply_black_font(control: Control) -> void:
	if control != null:
		control.add_theme_font_override("font", black_font())
