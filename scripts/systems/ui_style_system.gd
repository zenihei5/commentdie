class_name UiStyleSystem
extends RefCounted

static func result_panel_style(rank: String = "S") -> StyleBoxFlat:
	var color: Color = Color("#8e36e8")
	if rank == "S":
		color = Color("#ffdf5a")
	elif rank == "A":
		color = Color("#ff6a6a")
	elif rank == "B":
		color = Color("#6ed3ff")

	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.025, 0.022, 0.035, 0.97)
	style.border_color = color
	style.set_border_width_all(6)
	style.set_corner_radius_all(8)
	style.content_margin_left = 22
	style.content_margin_right = 22
	style.content_margin_top = 18
	style.content_margin_bottom = 18
	return style

static func initial_result_panel_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = result_panel_style("S")
	style.bg_color = Color(0.025, 0.022, 0.035, 0.96)
	style.set_border_width_all(5)
	return style

static func apply_choice_button(button: Button, fill: Color, border: Color, selected: bool) -> void:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(5 if selected else 3)
	style.set_corner_radius_all(8)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 14
	style.content_margin_bottom = 14

	var hover: StyleBoxFlat = style.duplicate() as StyleBoxFlat
	hover.bg_color = fill.lightened(0.08)
	var pressed: StyleBoxFlat = style.duplicate() as StyleBoxFlat
	pressed.bg_color = fill.darkened(0.08)

	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", style)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color("#fff45c"))
