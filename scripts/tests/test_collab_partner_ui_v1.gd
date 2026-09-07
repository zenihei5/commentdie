extends Node

const CharacterSystemScript := preload("res://scripts/systems/character_system.gd")
const CollabPartnerUiSystemScript := preload("res://scripts/systems/collab_partner_ui_system.gd")
const CollabComboSystemScript := preload("res://scripts/systems/collab_combo_system.gd")

var failures: Array[String] = []

func _ready() -> void:
	_run_all_tests()
	if failures.is_empty():
		print("COLLAB_PARTNER_UI_V1_TESTS: PASS")
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("COLLAB_PARTNER_UI_V1_TESTS: FAIL (%d)" % failures.size())
		get_tree().quit(1)

func _run_all_tests() -> void:
	var list_panel := Rect2(500.0, 118.0, 996.0, 646.0)
	var cards: Array[Rect2] = []
	for index in range(6):
		var card: Rect2 = CollabPartnerUiSystemScript.card_rect(list_panel, index)
		cards.append(card)
		var expected_position := Vector2(528.0 + float(index % 3) * 316.0, 196.0 + float(int(index / 3)) * 292.0)
		_check(card.position == expected_position, "candidate card %d position" % index)
		_check(card.size == Vector2(300.0, 276.0), "candidate card %d keeps 300x276" % index)
		_check(_contains_rect(list_panel, card), "candidate card %d stays inside list panel" % index)
		for previous in range(index):
			_check(not card.intersects(cards[previous]), "candidate card %d does not overlap card %d" % [index, previous])
	var horizontal_gap := cards[1].position.x - cards[0].end.x
	var vertical_gap := cards[3].position.y - cards[0].end.y
	_check_approx(horizontal_gap, 16.0, "candidate horizontal gap")
	_check_approx(vertical_gap, 16.0, "candidate vertical gap")
	_check_approx(cards[5].end.y, list_panel.end.y, "candidate grid uses the list panel height")

	for card in cards:
		var content: Dictionary = CollabPartnerUiSystemScript.candidate_content_rects(card)
		for key in ["number", "name", "avatar", "support", "pair", "selectedBadge"]:
			_check(_contains_rect(card, content[key] as Rect2), "candidate %s stays inside card" % key)
		_check(not (content["name"] as Rect2).intersects(content["avatar"] as Rect2), "candidate name stays above avatar")
		_check(_contains_rect(content["avatar"] as Rect2, content["selectedBadge"] as Rect2), "selected badge stays inside avatar area")
		_check(not (content["support"] as Rect2).intersects(content["pair"] as Rect2), "support and pair sections do not overlap")
		_check((content["pair"] as Rect2).end.y <= card.end.y - 8.0 + 0.01, "pair section keeps the bottom margin")
		_check((content["avatar"] as Rect2).end.y <= (content["support"] as Rect2).position.y, "avatar and support sections do not overlap")

	var current_panel := Rect2(104.0, 118.0, 360.0, 646.0)
	var current_content: Dictionary = CollabPartnerUiSystemScript.current_content_rects(current_panel)
	for key in ["label", "name", "avatar", "intro"]:
		_check(_contains_rect(current_panel, current_content[key] as Rect2), "current %s stays inside panel" % key)
	_check(not (current_content["name"] as Rect2).intersects(current_content["avatar"] as Rect2), "current name stays above avatar")
	_check(not (current_content["avatar"] as Rect2).intersects(current_content["intro"] as Rect2), "current avatar stays above intro")
	_check_approx(CollabPartnerUiSystemScript.CURRENT_AVATAR_VISUAL_HEIGHT, 200.0, "current avatar target height")
	_check_approx(CollabPartnerUiSystemScript.CANDIDATE_AVATAR_VISUAL_HEIGHT, 92.0, "candidate avatar target height")

	var character_data_file := FileAccess.open("res://data/characters.json", FileAccess.READ)
	_check(character_data_file != null, "character data opens")
	if character_data_file == null:
		return
	var parsed: Variant = JSON.parse_string(character_data_file.get_as_text())
	_check(parsed is Array and (parsed as Array).size() >= 6, "character data has six partner candidates")
	if not parsed is Array or (parsed as Array).size() < 6:
		return
	var characters: Array = parsed as Array
	for index in range(6):
		var character: Dictionary = characters[index] as Dictionary
		var view: Dictionary = CharacterSystemScript.selection_card_view(character, [])
		var character_id := String(character.get("id", ""))
		var name := String(character.get("displayName", ""))
		var name_layout: Dictionary = CollabPartnerUiSystemScript.candidate_name_layout(name)
		var name_lines: Array = name_layout.get("lines", []) as Array
		var joined_name := ""
		for line_value in name_lines:
			joined_name += String(line_value)
		_check(joined_name == name, "partner name stays complete for %s" % character_id)
		for line_value in name_lines:
			_check(CollabPartnerUiSystemScript.text_width(String(line_value), int(name_layout.get("size", 16))) <= CollabPartnerUiSystemScript.CARD_NAME_RECT.size.x + 0.01, "partner name fits for %s" % character_id)
		_check(String(view.get("staticSpritePath", "")) != "", "partner %s has stationary metadata" % character_id)
		_check(String(view.get("walkSpritePath", "")) != "", "partner %s has walk metadata" % character_id)
		_check(CollabPartnerUiSystemScript.candidate_avatar_mode("playable", true, false) == "static", "partner %s unselected avatar is stationary" % character_id)
		_check(CollabPartnerUiSystemScript.candidate_avatar_mode("playable", true, true) == "walk", "partner %s selected avatar can walk" % character_id)
		_check(CollabPartnerUiSystemScript.candidate_walk_frame(0.0, "playable", true, true, 10, 8.0) == 0, "partner %s walk starts at frame zero" % character_id)
		_check(CollabPartnerUiSystemScript.candidate_walk_frame(0.125, "playable", true, true, 10, 8.0) == 1, "partner %s walk advances at 8fps" % character_id)
		_check(CollabPartnerUiSystemScript.candidate_walk_frame(1.25, "playable", true, true, 10, 8.0) == 0, "partner %s walk loops" % character_id)
		_check(CollabPartnerUiSystemScript.candidate_walk_frame(0.125, "playable", true, false, 10, 8.0) == 0, "partner %s unselected frame stays static" % character_id)
		_check(CollabPartnerUiSystemScript.candidate_walk_frame(0.125, "locked", false, true, 10, 8.0) == 0, "partner %s locked frame stays static" % character_id)
		var walk_path := String(view.get("walkSpritePath", ""))
		_check(ResourceLoader.exists(walk_path) or FileAccess.file_exists(walk_path), "partner %s walk resource exists" % character_id)
		var stationary_path := String(view.get("staticSpritePath", ""))
		_check(ResourceLoader.exists(stationary_path) or FileAccess.file_exists(stationary_path), "partner %s stationary resource exists" % character_id)

		var support_text := "%s / %s" % [String(character.get("partnerSupportType", "支援")), String(character.get("partnerSupportDescription", "一定間隔で支援"))]
		var support_layout: Dictionary = CollabPartnerUiSystemScript.candidate_section_text_layout(content_rect(cards[0], "support"), support_text, 14, 11, 2)
		_check_layout_keeps_text(support_layout, support_text, "support %s" % character_id)

	var combo_data: Dictionary = CollabComboSystemScript.registry()
	var pair_names: Array[String] = []
	for first_index in range(6):
		for second_index in range(6):
			if first_index == second_index:
				continue
			var first_id := String((characters[first_index] as Dictionary).get("id", ""))
			var second_id := String((characters[second_index] as Dictionary).get("id", ""))
			var definition: Dictionary = CollabComboSystemScript.resolve_pair(first_id, second_id, characters, combo_data)
			var pair_name := String(definition.get("displayName", ""))
			pair_names.append(pair_name)
			_check(pair_name != "", "pair %s+%s has a display name" % [first_id, second_id])
			var pair_layout: Dictionary = CollabPartnerUiSystemScript.candidate_section_text_layout(content_rect(cards[0], "pair"), pair_name, 13, 11, 1)
			_check_layout_keeps_text(pair_layout, pair_name, "pair %s+%s" % [first_id, second_id])
	_check(pair_names.size() == 30, "all 30 ordered candidate pair names are checked")

func content_rect(card: Rect2, key: String) -> Rect2:
	return CollabPartnerUiSystemScript.candidate_content_rects(card)[key] as Rect2

func _check_layout_keeps_text(layout: Dictionary, expected_text: String, label: String) -> void:
	var lines: Array = layout.get("lines", []) as Array
	var joined := ""
	for line_value in lines:
		joined += String(line_value)
		_check(CollabPartnerUiSystemScript.text_width(String(line_value), int(layout.get("size", 1))) <= (layout["bodyRect"] as Rect2).size.x + 0.01, "%s line fits" % label)
	_check(joined == expected_text, "%s keeps complete text" % label)
	_check(lines.size() <= 2, "%s uses at most two lines" % label)

func _contains_rect(owner: Rect2, child: Rect2) -> bool:
	return child.position.x >= owner.position.x and child.position.y >= owner.position.y and child.end.x <= owner.end.x and child.end.y <= owner.end.y

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _check_approx(actual: float, expected: float, message: String) -> void:
	if absf(actual - expected) > 0.01:
		failures.append("%s (actual %.2f expected %.2f)" % [message, actual, expected])
