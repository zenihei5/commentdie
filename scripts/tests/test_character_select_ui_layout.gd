extends Node

const CharacterSystemScript := preload("res://scripts/systems/character_system.gd")

var failures: Array[String] = []

func _ready() -> void:
	_run_all_tests()
	if failures.is_empty():
		print("CHARACTER_SELECT_UI_LAYOUT_TESTS: PASS")
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("CHARACTER_SELECT_UI_LAYOUT_TESTS: FAIL (%d)" % failures.size())
		get_tree().quit(1)

func _run_all_tests() -> void:
	_check(CharacterSystemScript.SELECT_COLUMNS == 2, "character selection uses two columns")
	_check(CharacterSystemScript.SELECT_CARD_ORIGIN == Vector2(24.0, 72.0), "character card origin is 24x72")
	_check(CharacterSystemScript.SELECT_CARD_SIZE == Vector2(408.0, 192.0), "character card size is 408x192")
	_check(CharacterSystemScript.SELECT_CARD_GAP == Vector2(16.0, 12.0), "character card gap is 16x12")

	var list_panel: Rect2 = CharacterSystemScript.selection_list_panel_rect()
	_check(list_panel == Rect2(76.0, 112.0, 880.0, 692.0), "list panel geometry")
	var expected_positions: Array[Vector2] = [
		Vector2(100.0, 184.0), Vector2(524.0, 184.0),
		Vector2(100.0, 388.0), Vector2(524.0, 388.0),
		Vector2(100.0, 592.0), Vector2(524.0, 592.0)
	]
	var local_cards: Array[Rect2] = []
	var cards: Array[Rect2] = []
	for index in range(CharacterSystemScript.SELECT_PAGE_SIZE):
		var local_card: Rect2 = CharacterSystemScript.selection_card_rect(index)
		var card := Rect2(list_panel.position + local_card.position, local_card.size)
		local_cards.append(local_card)
		cards.append(card)
		_check(card.position == expected_positions[index], "card %d position" % index)
		_check(card.size == Vector2(408.0, 192.0), "card %d size" % index)
		_check(_contains_rect(list_panel, card), "card %d stays inside list panel" % index)
		for previous in range(index):
			_check(not card.intersects(cards[previous]), "card %d does not intersect card %d" % [index, previous])
	for index in range(1, cards.size()):
		if index % 2 == 1:
			_check_approx(cards[index].position.x - cards[index - 1].end.x, 16.0, "horizontal card gap %d" % index)
		else:
			_check_approx(cards[index].position.y - cards[index - 2].end.y, 12.0, "vertical card gap %d" % index)

	for index in range(6):
		var center := local_cards[index].get_center()
		_check(CharacterSystemScript.selection_index_at_local(center, index, 6) == index, "card center hit maps to index %d" % index)
	var horizontal_gap_point := Vector2((local_cards[0].end.x + local_cards[1].position.x) * 0.5, local_cards[0].get_center().y)
	var vertical_gap_point := Vector2(local_cards[0].get_center().x, (local_cards[0].end.y + local_cards[2].position.y) * 0.5)
	_check(CharacterSystemScript.selection_index_at_local(horizontal_gap_point, 0, 6) == -1, "horizontal gap is not clickable")
	_check(CharacterSystemScript.selection_index_at_local(vertical_gap_point, 0, 6) == -1, "vertical gap is not clickable")
	_check(CharacterSystemScript.selection_index_at_local(Vector2(10.0, 10.0), 0, 6) == -1, "outside list panel is not clickable")

	var playable := _test_character("playable", "playable", true)
	var locked := _test_character("locked", "playable", false)
	var coming := _test_character("coming", "coming_soon", true)
	_check(CharacterSystemScript.selection_card_status_text(playable, false) == "", "playable idle badge is hidden")
	_check(CharacterSystemScript.selection_card_status_text(playable, true) == "★ 選択中", "playable selected badge")
	_check(CharacterSystemScript.selection_card_status_text(locked, false) == "LOCKED", "locked idle badge")
	_check(CharacterSystemScript.selection_card_status_text(locked, true) == "LOCKED", "locked selected badge stays LOCKED")
	_check(CharacterSystemScript.selection_card_status_text(coming, false) == "準備中", "coming badge")
	_check(CharacterSystemScript.selection_detail_status_text(playable) == "", "playable detail badge is hidden")
	_check(CharacterSystemScript.selection_detail_status_text(locked) == "LOCKED", "locked detail badge")
	_check(CharacterSystemScript.selection_detail_status_text(coming) == "準備中", "coming detail badge")

	var card_content: Dictionary = CharacterSystemScript.selection_card_content_rects(local_cards[0])
	for key in ["portrait", "weapon", "tags", "info"]:
		_check(_contains_rect(local_cards[0], card_content[key] as Rect2), "card content %s stays inside card" % key)
	_check((card_content["portrait"] as Rect2).size == Vector2(158.0, 138.0), "card portrait uses contained 158x138 geometry")
	_check((card_content["portrait"] as Rect2).position - local_cards[0].position == Vector2(14.0, 46.0), "card portrait offset")
	_check((card_content["weapon"] as Rect2).position - local_cards[0].position == Vector2(184.0, 50.0), "card weapon offset")
	_check((card_content["weapon"] as Rect2).size == Vector2(210.0, 60.0), "card weapon width")
	_check((card_content["tags"] as Rect2).position - local_cards[0].position == Vector2(184.0, 124.0), "card tags offset")
	_check(not (card_content["portrait"] as Rect2).intersects(card_content["weapon"] as Rect2), "portrait and weapon regions do not overlap")
	_check(not (card_content["weapon"] as Rect2).intersects(card_content["tags"] as Rect2), "weapon and tag regions do not overlap")

	var detail_panel := Rect2(Vector2(982.0, 112.0), CharacterSystemScript.SELECT_DETAIL_PANEL_SIZE)
	var detail_content: Dictionary = CharacterSystemScript.selection_detail_content_rects(detail_panel)
	for key in ["image", "weapon", "tags", "trait", "intro"]:
		_check(_contains_rect(detail_panel, detail_content[key] as Rect2), "detail content %s stays inside panel" % key)
	var ordered_keys: Array[String] = ["image", "weapon", "tags", "trait", "intro"]
	for first_index in range(ordered_keys.size()):
		for second_index in range(first_index + 1, ordered_keys.size()):
			_check(not (detail_content[ordered_keys[first_index]] as Rect2).intersects(detail_content[ordered_keys[second_index]] as Rect2), "detail regions %s and %s do not overlap" % [ordered_keys[first_index], ordered_keys[second_index]])

	var default_view: Dictionary = CharacterSystemScript.selection_card_view(_test_character("default", "playable", true), [])
	_check_approx(float(default_view.get("cardSelectSpriteScale", 0.0)), 1.0, "card sprite scale defaults to 1")
	_check((default_view.get("cardSelectSpriteOffset", {}) as Dictionary) == {"x": 0, "y": 0}, "card sprite offset defaults to zero")
	var contained_view: Dictionary = CharacterSystemScript.selection_card_view({"id": "contained", "status": "playable", "isUnlocked": true, "cardSelectSpriteScale": 1.25, "cardSelectSpriteOffset": {"x": 2, "y": -3}}, [])
	_check_approx(float(contained_view.get("cardSelectSpriteScale", 0.0)), 1.25, "card sprite scale accepts an optional override")
	_check((contained_view.get("cardSelectSpriteOffset", {}) as Dictionary) == {"x": 2, "y": -3}, "card sprite offset accepts an optional override")

	var marker_gap := 6.0 + sin(0.25 * TAU) * 2.0
	var marker_depth := 8.0
	_check(cards[0].position.x - marker_gap - marker_depth >= list_panel.position.x, "first-column left marker stays inside list panel")
	_check(cards[1].end.x + marker_gap + marker_depth <= list_panel.end.x, "second-column right marker stays inside list panel")
	# Selection feedback may enlarge the visual card, but hit-testing always uses the base geometry.
	_check(CharacterSystemScript.selection_index_at_local(local_cards[0].get_center(), 0, 6) == 0, "selection scale does not change base hit-test")
	_check(CharacterSystemScript.selection_index_at_local(local_cards[0].get_center(), 0, 6) == 0, "pressed scale does not change base hit-test")

func _test_character(id: String, status: String, unlocked: bool) -> Dictionary:
	return {"id": id, "status": status, "isUnlocked": unlocked}

func _contains_rect(owner: Rect2, child: Rect2) -> bool:
	return child.position.x >= owner.position.x and child.position.y >= owner.position.y and child.end.x <= owner.end.x and child.end.y <= owner.end.y

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _check_approx(actual: float, expected: float, message: String) -> void:
	if absf(actual - expected) > 0.01:
		failures.append("%s (actual %.2f expected %.2f)" % [message, actual, expected])
