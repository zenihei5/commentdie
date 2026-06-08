class_name UiBuilderSystem
extends RefCounted

const GameFontSystemScript := preload("res://scripts/systems/game_font_system.gd")

static func build_ui(target: Node, choose_callable: Callable, result_style: StyleBoxFlat) -> Dictionary:
	var ui := CanvasLayer.new()
	target.add_child(ui)
	var title_nodes: Dictionary = build_title_ui(ui)
	var choice_nodes: Dictionary = build_choice_ui(ui, choose_callable)
	var chat_nodes: Dictionary = build_chat_ui(ui)
	var status_nodes: Dictionary = build_status_ui(ui)
	var result_nodes: Dictionary = build_result_ui(ui, result_style)
	return {
		"titleLabel": title_nodes["titleLabel"],
		"bannerLabel": title_nodes["bannerLabel"],
		"choiceBox": choice_nodes["choiceBox"],
		"choiceButtons": choice_nodes["choiceButtons"],
		"chatTitleLabel": chat_nodes["chatTitleLabel"],
		"chatBox": chat_nodes["chatBox"],
		"statusLabel": status_nodes["statusLabel"],
		"resultPanel": result_nodes["resultPanel"],
		"resultLabel": result_nodes["resultLabel"]
	}

static func build_title_ui(ui: CanvasLayer) -> Dictionary:
	var title := Label.new()
	title.position = Vector2(32, 28)
	title.text = "ぜんぶコメントのせいだ"
	title.visible = false
	GameFontSystemScript.apply_black_font(title)
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", Color.WHITE)
	title.add_theme_color_override("font_shadow_color", Color.BLACK)
	title.add_theme_constant_override("shadow_offset_x", 4)
	title.add_theme_constant_override("shadow_offset_y", 4)
	ui.add_child(title)

	var banner := PanelContainer.new()
	banner.position = Vector2(430, 22)
	banner.size = Vector2(700, 90)
	ui.add_child(banner)
	var banner_label := Label.new()
	banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	GameFontSystemScript.apply_black_font(banner_label)
	banner_label.add_theme_font_size_override("font_size", 30)
	banner.add_child(banner_label)
	return {"titleLabel": title, "bannerLabel": banner_label}

static func build_choice_ui(ui: CanvasLayer, choose_callable: Callable) -> Dictionary:
	var choice_box := HBoxContainer.new()
	choice_box.position = Vector2(455, 150)
	choice_box.add_theme_constant_override("separation", 22)
	choice_box.visible = false
	ui.add_child(choice_box)
	var buttons: Array = []
	for i in range(3):
		var button := Button.new()
		button.custom_minimum_size = Vector2(240, 315)
		button.focus_mode = Control.FOCUS_NONE
		button.clip_text = true
		GameFontSystemScript.apply_regular_font(button)
		button.pressed.connect(choose_callable.bind(i))
		choice_box.add_child(button)
		buttons.append(button)
	return {"choiceBox": choice_box, "choiceButtons": buttons}

static func build_chat_ui(ui: CanvasLayer) -> Dictionary:
	var comment_title := Label.new()
	comment_title.position = Vector2(1274, 206)
	comment_title.text = "COMMENT"
	comment_title.visible = false
	GameFontSystemScript.apply_black_font(comment_title)
	comment_title.add_theme_font_size_override("font_size", 28)
	comment_title.add_theme_color_override("font_color", Color("#c85cff"))
	ui.add_child(comment_title)

	var chat_box := VBoxContainer.new()
	chat_box.position = Vector2(1246, 270)
	chat_box.size = Vector2(292, 288)
	chat_box.clip_contents = true
	chat_box.add_theme_constant_override("separation", 6)
	ui.add_child(chat_box)
	return {"chatTitleLabel": comment_title, "chatBox": chat_box}

static func build_status_ui(ui: CanvasLayer) -> Dictionary:
	var status_label := Label.new()
	status_label.position = Vector2(705, 866)
	status_label.size = Vector2(820, 24)
	GameFontSystemScript.apply_regular_font(status_label)
	status_label.add_theme_font_size_override("font_size", 14)
	status_label.add_theme_color_override("font_color", Color("#cfc7ff"))
	ui.add_child(status_label)
	return {"statusLabel": status_label}

static func build_result_ui(ui: CanvasLayer, result_style: StyleBoxFlat) -> Dictionary:
	var result_panel := PanelContainer.new()
	result_panel.position = Vector2(240, 78)
	result_panel.size = Vector2(1120, 735)
	result_panel.visible = false
	result_panel.add_theme_stylebox_override("panel", result_style)
	ui.add_child(result_panel)
	var result_label := Label.new()
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	result_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	GameFontSystemScript.apply_regular_font(result_label)
	result_label.add_theme_font_size_override("font_size", 16)
	result_panel.add_child(result_label)
	return {"resultPanel": result_panel, "resultLabel": result_label}
