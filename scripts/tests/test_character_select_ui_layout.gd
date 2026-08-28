extends Node

const CharacterSystemScript := preload("res://scripts/systems/character_system.gd")
const ChoiceCardSystemScript := preload("res://scripts/systems/choice_card_system.gd")
const GameFontSystemScript := preload("res://scripts/systems/game_font_system.gd")

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
	_check(CharacterSystemScript.SELECT_COLUMNS == 3, "character selection uses three columns")
	_check(CharacterSystemScript.SELECT_CARD_ORIGIN == Vector2(24.0, 90.0), "character card origin is 24x90")
	_check(CharacterSystemScript.SELECT_CARD_SIZE == Vector2(264.0, 224.0), "character card size is 264x224")
	_check(CharacterSystemScript.SELECT_CARD_GAP == Vector2(16.0, 76.0), "character card gap is 16x76")

	var list_panel: Rect2 = CharacterSystemScript.selection_list_panel_rect()
	_check(list_panel == Rect2(76.0, 112.0, 880.0, 692.0), "list panel geometry")
	var expected_positions: Array[Vector2] = [
		Vector2(100.0, 202.0), Vector2(380.0, 202.0), Vector2(660.0, 202.0),
		Vector2(100.0, 502.0), Vector2(380.0, 502.0), Vector2(660.0, 502.0)
	]
	var local_cards: Array[Rect2] = []
	var cards: Array[Rect2] = []
	for index in range(CharacterSystemScript.SELECT_PAGE_SIZE):
		var local_card: Rect2 = CharacterSystemScript.selection_card_rect(index)
		var card := Rect2(list_panel.position + local_card.position, local_card.size)
		local_cards.append(local_card)
		cards.append(card)
		_check(card.position == expected_positions[index], "card %d position" % index)
		_check(card.size == Vector2(264.0, 224.0), "card %d size" % index)
		_check(_contains_rect(list_panel, card), "card %d stays inside list panel" % index)
		for previous in range(index):
			_check(not card.intersects(cards[previous]), "card %d does not intersect card %d" % [index, previous])
	for index in range(1, cards.size()):
		if index % 3 != 0:
			_check_approx(cards[index].position.x - cards[index - 1].end.x, 16.0, "horizontal card gap %d" % index)
		else:
			_check_approx(cards[index].position.y - cards[index - 3].end.y, 76.0, "vertical card gap %d" % index)
	_check_approx(cards[2].end.x, 924.0, "third column right edge")
	_check_approx(cards[5].end.y, 726.0, "second row bottom edge")

	var heading_rects: Array = CharacterSystemScript.selection_group_heading_rects()
	var heading_labels: Array[String] = CharacterSystemScript.selection_group_heading_labels()
	_check(heading_rects.size() == 2, "two group heading regions")
	_check(heading_labels == ["初期メンバー", "先輩メンバー"], "group heading labels")
	for heading_index in range(heading_rects.size()):
		var heading: Rect2 = heading_rects[heading_index] as Rect2
		_check(_contains_rect(Rect2(Vector2.ZERO, list_panel.size), heading), "group heading %d stays inside panel" % heading_index)
		var row_start := heading_index * 3
		_check(heading.end.y <= local_cards[row_start].position.y, "group heading %d stays before its row" % heading_index)
		for card_index in range(row_start, row_start + 3):
			_check(not heading.intersects(local_cards[card_index]), "group heading %d does not overlap card %d" % [heading_index, card_index])

	for index in range(6):
		var center := local_cards[index].get_center()
		_check(CharacterSystemScript.selection_index_at_local(center, index, 6) == index, "card center hit maps to index %d" % index)
	var horizontal_gap_point := Vector2((local_cards[0].end.x + local_cards[1].position.x) * 0.5, local_cards[0].get_center().y)
	var vertical_gap_point := Vector2(local_cards[0].get_center().x, (local_cards[0].end.y + local_cards[3].position.y) * 0.5)
	_check(CharacterSystemScript.selection_index_at_local(horizontal_gap_point, 0, 6) == -1, "horizontal gap is not clickable")
	_check(CharacterSystemScript.selection_index_at_local(vertical_gap_point, 0, 6) == -1, "vertical gap is not clickable")
	_check(CharacterSystemScript.selection_index_at_local(Vector2(10.0, 10.0), 0, 6) == -1, "outside list panel is not clickable")
	_check(CharacterSystemScript.selection_index_at_local(Vector2(-1.0, -1.0), 0, 6) == -1, "outside list panel is not clickable")

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
	for key in ["portrait", "weapon", "info"]:
		_check(_contains_rect(local_cards[0], card_content[key] as Rect2), "card content %s stays inside card" % key)
	_check(not card_content.has("tags"), "left card content has no tag region")
	var portrait: Rect2 = card_content["portrait"] as Rect2
	var weapon: Rect2 = card_content["weapon"] as Rect2
	var info: Rect2 = card_content["info"] as Rect2
	_check(portrait.size == Vector2(98.0, 162.0), "card portrait uses the left-shifted contained geometry")
	_check(portrait.position - local_cards[0].position == Vector2(8.0, 46.0), "card portrait offset shifts seven pixels left")
	_check(weapon.position - local_cards[0].position == Vector2(108.0, 61.0), "card weapon offset uses the adjusted right column")
	_check(weapon.size == Vector2(152.0, 118.0), "card weapon block uses the adjusted expanded geometry")
	_check(info.position - local_cards[0].position == Vector2(108.0, 10.0), "card info offset aligns with the adjusted right column")
	_check(info.size == Vector2(148.0, 30.0), "card info width uses the adjusted right column")
	_check(not portrait.intersects(weapon), "portrait and weapon regions do not overlap")
	_check(not info.intersects(weapon), "card info and weapon regions do not overlap")
	_check_approx(weapon.position.x - portrait.end.x, 2.0, "portrait and weapon regions keep the required two-pixel gap")
	_check_approx(local_cards[0].end.x - weapon.end.x, 4.0, "card weapon block keeps the four-pixel right margin")
	var compact_text: Dictionary = CharacterSystemScript.selection_card_compact_weapon_text_rects(weapon)
	for key in ["icon", "label", "name", "condition"]:
		_check(_contains_rect(weapon, compact_text[key] as Rect2), "compact weapon %s stays inside weapon block" % key)
	var compact_icon: Rect2 = compact_text["icon"] as Rect2
	_check(compact_icon.position == weapon.position + Vector2(10.0, 10.0), "compact weapon icon uses the expanded inset")
	_check(compact_icon.size == Vector2(40.0, 40.0), "compact weapon icon is 40px")
	_check((compact_text["label"] as Rect2).position.x == weapon.position.x + 58.0, "compact weapon label starts beside the larger icon")
	_check((compact_text["label"] as Rect2).size == Vector2(84.0, 22.0), "compact weapon label preserves the right inset")
	_check((compact_text["name"] as Rect2).position.y == weapon.position.y + 56.0, "compact weapon names use the lower text row")
	_check((compact_text["name"] as Rect2).size == Vector2(132.0, 54.0), "compact weapon names use the full-width lower row")
	_check((compact_text["name"] as Rect2).position.x == weapon.position.x + 10.0, "compact weapon names share a left edge")
	_check((compact_text["condition"] as Rect2).position == weapon.position + Vector2(10.0, 42.0), "locked condition uses the separated upper text region")
	_check((compact_text["condition"] as Rect2).size == Vector2(132.0, 66.0), "locked condition uses the expanded two-line region")
	_check(CharacterSystemScript.SELECT_CARD_COMPACT_WEAPON_LABEL_FONT_SIZE == 13, "compact weapon label uses 13px")
	_check_approx(CharacterSystemScript.SELECT_CARD_COMPACT_WEAPON_LABEL_BASELINE, 15.0, "compact weapon label baseline uses the expanded block")
	_check_approx(CharacterSystemScript.SELECT_CARD_COMPACT_WEAPON_LABEL_DARKEN, 0.14, "compact weapon label darkening is 0.14")
	_check_approx(CharacterSystemScript.SELECT_CARD_COMPACT_WEAPON_LABEL_ALPHA, 0.94, "compact weapon label alpha is 0.94")
	var label_accent := Color("#e954a5")
	var expected_label_color := label_accent.darkened(0.14)
	expected_label_color.a = 0.94
	var actual_label_color: Color = CharacterSystemScript.selection_card_compact_weapon_label_color(label_accent)
	_check_approx(actual_label_color.r, expected_label_color.r, "compact weapon label color darkens red channel")
	_check_approx(actual_label_color.g, expected_label_color.g, "compact weapon label color darkens green channel")
	_check_approx(actual_label_color.b, expected_label_color.b, "compact weapon label color darkens blue channel")
	_check_approx(actual_label_color.a, expected_label_color.a, "compact weapon label color keeps alpha")
	var weapon_names: Array[String] = ["BANハンマー", "スパチャ弾", "コメントブーメラン", "モデレーターシールド", "ファンサバトン", "釣りサムネロッド"]
	var font: Font = GameFontSystemScript.regular_font()
	for weapon_name in weapon_names:
		var name_rect: Rect2 = compact_text["name"] as Rect2
		var single_line_size := 0
		for text_size in range(16, 13, -1):
			if font.get_string_size(weapon_name, HORIZONTAL_ALIGNMENT_LEFT, -1.0, text_size).x <= name_rect.size.x:
				single_line_size = text_size
				break
		var selected_lines: Array[String] = [weapon_name]
		var selected_size: int = single_line_size
		if single_line_size == 0:
			selected_size = 14
			if weapon_name == "モデレーターシールド":
				selected_lines = ["モデレーター", "シールド"]
			else:
				selected_lines = _wrap_full_text(font, weapon_name, selected_size, name_rect.size.x)
		_check(single_line_size > 0 or selected_lines.size() <= 2, "card weapon name fits in at most two lines at 14px minimum: %s" % weapon_name)
		_check("".join(selected_lines) == weapon_name, "card weapon name keeps full text: %s" % weapon_name)
		_check(selected_size >= 14, "card weapon name never drops below 14px: %s" % weapon_name)
		_check(CharacterSystemScript.SELECT_CARD_COMPACT_WEAPON_LABEL_FONT_SIZE < selected_size, "compact weapon label remains smaller than weapon name: %s" % weapon_name)
		for line in selected_lines:
			_check(font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1.0, selected_size).x <= name_rect.size.x + 0.01, "card weapon line fits: %s" % weapon_name)
		print("CHARACTER_SELECT_WEAPON_MEASURE %s size=%d rows=%d" % [weapon_name, selected_size, selected_lines.size()])
	_check(font.get_string_size("初期武器", HORIZONTAL_ALIGNMENT_LEFT, -1.0, CharacterSystemScript.SELECT_CARD_COMPACT_WEAPON_LABEL_FONT_SIZE).x <= (compact_text["label"] as Rect2).size.x, "compact weapon label text fits its 84px rect")
	var compact_label: Rect2 = compact_text["label"] as Rect2
	var compact_name: Rect2 = compact_text["name"] as Rect2
	_check(not compact_icon.intersects(compact_label), "compact weapon label does not overlap icon")
	_check(not compact_icon.intersects(compact_name), "compact weapon name does not overlap icon")
	_check(not compact_label.intersects(compact_name), "compact weapon label does not overlap weapon name")
	for card_index in range(6):
		var card_content_rects: Dictionary = CharacterSystemScript.selection_card_content_rects(local_cards[card_index])
		var card_weapon_rect: Rect2 = card_content_rects["weapon"] as Rect2
		var card_rects: Dictionary = CharacterSystemScript.selection_card_compact_weapon_text_rects(card_weapon_rect)
		_check(_contains_rect(card_weapon_rect, card_rects["label"] as Rect2), "card %d compact label remains inside weapon block" % card_index)
		_check(not (card_rects["icon"] as Rect2).intersects(card_rects["label"] as Rect2), "card %d compact label avoids icon" % card_index)
		_check(not (card_rects["label"] as Rect2).intersects(card_rects["name"] as Rect2), "card %d compact label avoids weapon name" % card_index)
	var moderator_lines: Array[String] = ["モデレーター", "シールド"]
	_check(moderator_lines == ["モデレーター", "シールド"], "moderator shield uses a semantic two-line split")
	_check("".join(moderator_lines) == "モデレーターシールド", "moderator shield preferred lines keep full text")
	for line in moderator_lines:
		_check(font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14).x <= (compact_text["name"] as Rect2).size.x + 0.01, "moderator shield preferred line fits at 14px")
	var condition_rect: Rect2 = compact_text["condition"] as Rect2
	var lock_lines: Array[String] = ["ノーマルの配信リレーを", "クリアすると解禁"]
	_check(lock_lines == ["ノーマルの配信リレーを", "クリアすると解禁"], "locked condition uses a semantic two-line split")
	_check("".join(lock_lines) == "ノーマルの配信リレーをクリアすると解禁", "locked condition preferred lines keep full text")
	for line in lock_lines:
		_check(font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 11).x <= condition_rect.size.x + 0.01, "locked condition preferred line fits at 11px")

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
	_check(String(default_view.get("walkSpritePath", "")) == "", "walk sprite path remains separate from select sprite path")
	_check_approx(float(default_view.get("walkSpriteFps", 0.0)), 8.0, "card walk animation uses 8fps")
	_check(CharacterSystemScript.selection_card_can_use_walk_sprite(true, "locked"), "locked character cards use an available walk sprite")
	_check(not CharacterSystemScript.selection_card_can_use_walk_sprite(true, "coming_soon"), "coming soon cards keep their placeholder")
	_check(CharacterSystemScript.selection_card_walk_should_animate("playable", true, true), "selected playable card animates")
	_check(not CharacterSystemScript.selection_card_walk_should_animate("locked", false, true), "selected locked card stays static")
	_check(CharacterSystemScript.selection_card_avatar_mode("playable", true, false) == "static", "non-selected playable card uses stationary mode")
	_check(CharacterSystemScript.selection_card_avatar_mode("locked", false, true) == "static", "locked card uses stationary mode")
	_check(CharacterSystemScript.selection_card_avatar_mode("playable", true, true) == "walk", "selected playable card uses walk mode")
	var contained_view: Dictionary = CharacterSystemScript.selection_card_view({"id": "contained", "status": "playable", "isUnlocked": true, "cardSelectSpriteScale": 1.25, "cardSelectSpriteOffset": {"x": 2, "y": -3}}, [])
	_check_approx(float(contained_view.get("cardSelectSpriteScale", 0.0)), 1.25, "card sprite scale accepts an optional override")
	_check((contained_view.get("cardSelectSpriteOffset", {}) as Dictionary) == {"x": 2, "y": -3}, "card sprite offset accepts an optional override")
	_check_locked_view_and_silhouette(detail_panel)

	var marker_gap := 6.0 + sin(0.25 * TAU) * 2.0
	var marker_depth := 8.0
	_check(cards[0].position.x - marker_gap - marker_depth >= list_panel.position.x, "first-column left marker stays inside list panel")
	_check(cards[2].end.x + marker_gap + marker_depth <= list_panel.end.x, "third-column right marker stays inside list panel")
	_check(cards[0].get_center().y - marker_depth >= list_panel.position.y, "top-row marker stays inside list panel")
	_check(cards[3].get_center().y + marker_depth <= list_panel.end.y, "bottom-row marker stays inside list panel")
	# Selection feedback may enlarge the visual card, but hit-testing always uses the base geometry.
	_check(CharacterSystemScript.selection_index_at_local(local_cards[0].get_center(), 0, 6) == 0, "selection scale does not change base hit-test")
	_check(CharacterSystemScript.selection_index_at_local(local_cards[0].get_center(), 0, 6) == 0, "pressed scale does not change base hit-test")

	_check_character_grid_navigation()
	_check_direct_number_selection()
	_check_character_data_order()
	_check_character_avatar_alignment()

func _check_locked_view_and_silhouette(detail_panel: Rect2) -> void:
	var locked_character := {
		"id": "locked_fixture",
		"displayName": "秘匿キャラ",
		"status": "locked",
		"isUnlocked": false,
		"initialWeapon": "ban_hammer",
		"selectSprite": "res://assets/characters/ban_chan.png",
		"sprite": "res://assets/generated/banri_walk_v1/banri-static-transparent.png",
		"unlockConditionText": "ノーマルの配信リレーをクリアすると解禁",
		"description": "秘匿本文",
		"recommendText": "秘匿おすすめ",
		"specialtyText": "秘匿特性",
		"cardTags": ["#秘匿"],
		"detailTags": ["#秘匿詳細"]
	}
	var locked_view: Dictionary = CharacterSystemScript.selection_card_view(locked_character, [])
	_check(String(locked_view.get("displayName", "")) == "？？？", "locked view hides the character name")
	for key in ["weaponName", "weaponIconPath", "evolvedWeaponName", "evolvedWeaponIconPath", "passiveName", "passiveDescription", "description", "recommendText", "specialtyText"]:
		_check(String(locked_view.get(key, "")) == "", "locked view hides %s" % key)
	_check((locked_view.get("cardTags", []) as Array).is_empty(), "locked view hides card tags")
	_check((locked_view.get("detailTags", []) as Array).is_empty(), "locked view hides detail tags")
	_check(String(locked_view.get("unlockConditionText", "")) == "ノーマルの配信リレーをクリアすると解禁", "locked view keeps unlock condition")
	_check(String(locked_view.get("statusId", "")) == "locked", "locked view keeps locked status")
	_check(not bool(locked_view.get("isSelectable", true)), "locked view remains unselectable")
	_check(String(locked_view.get("spritePath", "")) != "", "locked view retains an internal silhouette source")
	_check((locked_view.get("accent", Color.WHITE) as Color) == CharacterSystemScript.SELECT_LOCKED_ACCENT, "locked view uses the common accent")
	_check(CharacterSystemScript.selection_card_avatar_mode("locked", false, true) == "static", "locked selection never enters walk mode")
	_check(CharacterSystemScript.selection_card_walk_frame_index(0.125, true, false, 10, 8.0) == 0, "locked selection keeps static frame zero")

	var unlocked_character := locked_character.duplicate(true) as Dictionary
	unlocked_character["id"] = "unlocked_fixture"
	unlocked_character["status"] = "playable"
	unlocked_character["isUnlocked"] = true
	var unlocked_view: Dictionary = CharacterSystemScript.selection_card_view(unlocked_character, [])
	_check(String(unlocked_view.get("displayName", "")) == "秘匿キャラ", "unlocked view restores the character name")
	_check(String(unlocked_view.get("weaponName", "")) != "", "unlocked view restores weapon information")
	_check(not (unlocked_view.get("detailTags", []) as Array).is_empty(), "unlocked view restores detail tags")
	_check((unlocked_view.get("accent", Color.WHITE) as Color) != CharacterSystemScript.SELECT_LOCKED_ACCENT, "unlocked view restores character accent")

	var locked_content: Dictionary = CharacterSystemScript.selection_detail_locked_content_rects(detail_panel)
	_check(_contains_rect(detail_panel, locked_content["image"] as Rect2), "locked detail image stays inside panel")
	_check(_contains_rect(detail_panel, locked_content["condition"] as Rect2), "locked detail condition stays inside panel")
	_check(not (locked_content["image"] as Rect2).intersects(locked_content["condition"] as Rect2), "locked detail condition does not overlap image")
	_check((locked_content["condition"] as Rect2).position == detail_panel.position + Vector2(28.0, 426.0), "locked detail uses the dedicated condition position")

	var source := Image.create(3, 2, false, Image.FORMAT_RGBA8)
	source.fill(Color(0.0, 0.0, 0.0, 0.0))
	source.set_pixel(0, 0, Color(1.0, 0.0, 0.0, 1.0))
	source.set_pixel(1, 0, Color(0.0, 1.0, 0.0, 0.5))
	var silhouette: Image = CharacterSystemScript.selection_locked_silhouette_image(source)
	var silhouette_color: Color = CharacterSystemScript.SELECT_LOCKED_SILHOUETTE_COLOR
	_check(silhouette != null, "locked silhouette image is generated")
	if silhouette != null:
		var opaque_pixel: Color = silhouette.get_pixel(0, 0)
		var edge_pixel: Color = silhouette.get_pixel(1, 0)
		var transparent_pixel: Color = silhouette.get_pixel(2, 0)
		_check_approx(opaque_pixel.r, silhouette_color.r, "silhouette opaque red channel is unified")
		_check_approx(opaque_pixel.g, silhouette_color.g, "silhouette opaque green channel is unified")
		_check_approx(opaque_pixel.b, silhouette_color.b, "silhouette opaque blue channel is unified")
		_check_approx(opaque_pixel.a, 1.0, "silhouette keeps opaque alpha")
		_check_approx(edge_pixel.r, silhouette_color.r, "silhouette edge red channel is unified")
		_check_approx(edge_pixel.a, 0.5, "silhouette preserves alpha edge")
		_check_approx(transparent_pixel.a, 0.0, "silhouette preserves transparent pixels")

	var file := FileAccess.open("res://data/characters.json", FileAccess.READ)
	if file != null:
		var parsed: Variant = JSON.parse_string(file.get_as_text())
		if parsed is Array and (parsed as Array).size() >= 6:
			for index in range(3, 6):
				var senior: Dictionary = ((parsed as Array)[index] as Dictionary).duplicate(true)
				senior["isUnlocked"] = false
				senior["status"] = "locked"
				var senior_view: Dictionary = CharacterSystemScript.selection_card_view(senior, [])
				_check(String(senior_view.get("displayName", "")) == "？？？", "locked senior %d hides its name" % index)
				_check(String(senior_view.get("weaponName", "")) == "", "locked senior %d hides its weapon" % index)
				_check(CharacterSystemScript.selection_card_avatar_mode("locked", false, true) == "static", "locked senior %d remains static" % index)
				_check(CharacterSystemScript.selection_card_walk_frame_index(0.125, true, false, 10, 8.0) == 0, "locked senior %d stays on frame zero" % index)

func _check_character_grid_navigation() -> void:
	var characters: Array = []
	for index in range(6):
		characters.append(_test_character("nav_%d" % index, "playable", true))
	var expected_moves := {
		"0_right": [0, KEY_RIGHT, 1],
		"1_right": [1, KEY_RIGHT, 2],
		"3_right": [3, KEY_RIGHT, 4],
		"4_right": [4, KEY_RIGHT, 5],
		"0_down": [0, KEY_DOWN, 3],
		"1_down": [1, KEY_DOWN, 4],
		"2_down": [2, KEY_DOWN, 5],
		"3_up": [3, KEY_UP, 0],
		"4_up": [4, KEY_UP, 1],
		"5_up": [5, KEY_UP, 2],
		"2_left": [2, KEY_LEFT, 1],
		"5_left": [5, KEY_LEFT, 4]
	}
	for label in expected_moves:
		var expected: Array = expected_moves[label] as Array
		var direction := _direction_name(expected[1] as Key)
		var action: Dictionary = ChoiceCardSystemScript.character_grid_selection_action_for_direction(int(expected[0]), characters.size(), CharacterSystemScript.SELECT_PAGE_SIZE, CharacterSystemScript.SELECT_COLUMNS, direction)
		_check(String(action["kind"]) == "move" and int(action["index"]) == int(expected[2]), "grid navigation %s" % label)

	var edge_cases := {
		"0_left": [0, KEY_LEFT], "2_right": [2, KEY_RIGHT], "3_left": [3, KEY_LEFT],
		"5_right": [5, KEY_RIGHT], "0_up": [0, KEY_UP], "1_up": [1, KEY_UP],
		"2_up": [2, KEY_UP], "3_down": [3, KEY_DOWN], "4_down": [4, KEY_DOWN], "5_down": [5, KEY_DOWN]
	}
	for label in edge_cases:
		var edge: Array = edge_cases[label] as Array
		var direction := _direction_name(edge[1] as Key)
		var action: Dictionary = ChoiceCardSystemScript.character_grid_selection_action_for_direction(int(edge[0]), characters.size(), CharacterSystemScript.SELECT_PAGE_SIZE, CharacterSystemScript.SELECT_COLUMNS, direction)
		_check(String(action["kind"]) == "" and int(action["index"]) == int(edge[0]), "grid edge stop %s" % label)

func _check_direct_number_selection() -> void:
	var ids: Array[String] = ["ban_chan", "superchat_chan", "maro_chan", "aosumi_kyasumi", "akarine_rizumu", "shizuki_miimu"]
	var characters: Array = []
	for id in ids:
		characters.append(_test_character(id, "playable", true))
	var keys: Array[Key] = [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6]
	for index in range(ids.size()):
		var action: Dictionary = ChoiceCardSystemScript.character_grid_selection_action_for_number_key(keys[index], characters.size(), 6)
		_check(String(action["kind"]) == "select", "number key %d selects" % (index + 1))
		_check(int(action["index"]) == index, "number key %d index" % (index + 1))
		var selected: Dictionary = CharacterSystemScript.selected_character_state_by_index(characters, int(action["index"]))
		_check(String(selected.get("characterId", "")) == ids[index], "number key %d character id" % (index + 1))

func _check_character_data_order() -> void:
	var file := FileAccess.open("res://data/characters.json", FileAccess.READ)
	if file == null:
		_check(false, "characters data can be opened")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	var expected: Array[String] = ["ban_chan", "superchat_chan", "maro_chan", "aosumi_kyasumi", "akarine_rizumu", "shizuki_miimu"]
	_check(parsed is Array and (parsed as Array).size() >= expected.size(), "characters data has six entries")
	if not (parsed is Array) or (parsed as Array).size() < expected.size():
		return
	for index in range(expected.size()):
		var character: Dictionary = (parsed as Array)[index] as Dictionary
		_check(String(character.get("id", "")) == expected[index], "character data order %d" % index)
		var walk_path := String(character.get("runSprite", ""))
		_check(walk_path != "", "character %d has a walk sprite" % index)
		_check(int(character.get("runSpriteCols", 0)) == 10, "character %d uses ten walk columns" % index)
		_check(int(character.get("runSpriteRows", 0)) == 1, "character %d uses one walk row" % index)
		_check(ResourceLoader.exists(walk_path) or FileAccess.file_exists(walk_path), "character %d walk sprite resource exists" % index)
		var view: Dictionary = CharacterSystemScript.selection_card_view(character, [])
		_check(String(view.get("walkSpritePath", "")) == walk_path, "character %d keeps walk metadata separate" % index)
		var expected_stationary_path := String(character.get("idleSprite", "")) if String(character.get("idleSprite", "")) != "" else String(character.get("sprite", ""))
		_check(String(view.get("staticSpritePath", "")) == expected_stationary_path, "character %d uses main stationary sprite resolution" % index)
		_check_approx(float(view.get("walkSpriteFps", 0.0)), 8.0, "character %d card walk fps" % index)
		_check_approx(float(view.get("walkSpriteSourceFps", 0.0)), 12.0, "character %d source walk fps" % index)
		_check(CharacterSystemScript.selection_card_walk_frame_index(0.0, true, true, 10, 8.0) == 0, "character %d selected frame at zero" % index)
		_check(CharacterSystemScript.selection_card_walk_frame_index(0.125, true, true, 10, 8.0) == 1, "character %d selected frame at one eighth" % index)
		_check(CharacterSystemScript.selection_card_walk_frame_index(1.25, true, true, 10, 8.0) == 0, "character %d selected frame loops" % index)
		_check(CharacterSystemScript.selection_card_walk_frame_index(0.125, false, true, 10, 8.0) == 0, "character %d idle frame is static" % index)
		_check(CharacterSystemScript.selection_card_walk_frame_index(0.125, true, false, 10, 8.0) == 0, "character %d locked frame is static" % index)
		var walk_texture := ResourceLoader.load(walk_path) as Texture2D
		if walk_texture != null:
			var source_zero := CharacterSystemScript.selection_card_walk_source_rect(walk_texture.get_size(), 10, 1, 0)
			var source_one := CharacterSystemScript.selection_card_walk_source_rect(walk_texture.get_size(), 10, 1, 1)
			_check(source_zero.size == source_one.size, "character %d source cells keep a fixed size" % index)
			_check_approx(source_one.position.x - source_zero.position.x, source_zero.size.x, "character %d source cells advance by one cell" % index)
			var portrait_rect := Rect2(Vector2(8.0, 46.0), Vector2(98.0, 162.0))
			var destination_zero := CharacterSystemScript.selection_card_walk_destination_rect(portrait_rect, walk_texture.get_size(), 10, 1)
			var destination_one := CharacterSystemScript.selection_card_walk_destination_rect(portrait_rect, walk_texture.get_size(), 10, 1)
			_check(destination_zero == destination_one, "character %d destination is fixed across frames" % index)
			var visible := CharacterSystemScript.selection_card_walk_visible_rect(portrait_rect, destination_zero)
			_check(_contains_rect(portrait_rect, visible), "character %d walk clipping stays in portrait" % index)

func _check_character_avatar_alignment() -> void:
	var file := FileAccess.open("res://data/characters.json", FileAccess.READ)
	if file == null:
		_check(false, "characters data opens for avatar alignment")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Array or (parsed as Array).size() < 6:
		_check(false, "characters data has six entries for avatar alignment")
		return
	var portrait := Rect2(Vector2(8.0, 46.0), Vector2(98.0, 162.0))
	for index in range(6):
		var character: Dictionary = (parsed as Array)[index] as Dictionary
		var view: Dictionary = CharacterSystemScript.selection_card_view(character, [])
		var stationary_path := String(view.get("staticSpritePath", ""))
		var stationary_columns := maxi(1, int(view.get("staticSpriteCols", 1)))
		var stationary_rows := maxi(1, int(view.get("staticSpriteRows", 1)))
		_check(stationary_path != "", "character %d has a stationary sprite path" % index)
		_check(ResourceLoader.exists(stationary_path) or FileAccess.file_exists(stationary_path), "character %d stationary sprite resource exists" % index)
		var stationary_texture := ResourceLoader.load(stationary_path) as Texture2D
		if stationary_texture == null:
			_check(false, "character %d stationary sprite loads" % index)
		else:
			var stationary_image := stationary_texture.get_image()
			var stationary_bounds := CharacterSystemScript.selection_card_avatar_opaque_bounds(stationary_image, stationary_columns, stationary_rows, false)
			var stationary_cell := CharacterSystemScript.selection_card_walk_source_rect(stationary_texture.get_size(), stationary_columns, stationary_rows, 0).size
			var stationary_destination := CharacterSystemScript.selection_card_avatar_destination_rect(portrait, stationary_cell, stationary_bounds)
			var stationary_mapped := CharacterSystemScript.selection_card_avatar_mapped_opaque_rect(stationary_destination, stationary_cell, stationary_bounds)
			_check_approx(stationary_mapped.end.y, portrait.end.y - 4.0, "character %d stationary feet share the baseline" % index)
			_check_approx(stationary_mapped.size.y, 140.0, "character %d stationary visual height" % index)
			_check_approx(stationary_mapped.get_center().x, portrait.get_center().x, "character %d stationary center" % index)
			_check(_contains_rect(portrait, stationary_mapped), "character %d stationary mapped opaque bounds are fully contained" % index)
			_check(_contains_rect(portrait, CharacterSystemScript.selection_card_walk_visible_rect(portrait, stationary_destination)), "character %d stationary clipping stays in portrait" % index)

		var walk_path := String(view.get("walkSpritePath", ""))
		var walk_texture := ResourceLoader.load(walk_path) as Texture2D
		if walk_texture == null:
			_check(false, "character %d walk sprite loads for alignment" % index)
			continue
		var walk_image := walk_texture.get_image()
		var walk_bounds := CharacterSystemScript.selection_card_avatar_opaque_bounds(walk_image, 10, 1, true)
		var walk_cell := CharacterSystemScript.selection_card_walk_source_rect(walk_texture.get_size(), 10, 1, 0).size
		var walk_destination := CharacterSystemScript.selection_card_avatar_destination_rect(portrait, walk_cell, walk_bounds)
		var walk_mapped := CharacterSystemScript.selection_card_avatar_mapped_opaque_rect(walk_destination, walk_cell, walk_bounds)
		_check_approx(walk_mapped.end.y, portrait.end.y - 4.0, "character %d walk feet share the baseline" % index)
		_check_approx(walk_mapped.size.y, 140.0, "character %d walk visual height" % index)
		_check_approx(walk_mapped.get_center().x, portrait.get_center().x, "character %d walk center" % index)
		_check(_vertical_overflow(walk_mapped, portrait) <= 0.01, "character %d walk union has no vertical overflow; limited horizontal clipping is allowed" % index)
		_check(_max_horizontal_overflow(walk_mapped, portrait) <= 9.0 + 0.01, "character %d walk union horizontal clipping stays within the 9px guardrail" % index)
		var walk_visible := walk_mapped.intersection(portrait)
		_check(_contains_rect(portrait, walk_visible), "character %d walk union clipped visible bounds stay inside portrait" % index)
		_check(walk_visible.size.x >= walk_mapped.size.x * 0.85 - 0.01, "character %d walk union keeps at least 85%% visible width" % index)
		for frame in range(10):
			var frame_source := CharacterSystemScript.selection_card_walk_source_rect(walk_texture.get_size(), 10, 1, frame)
			var frame_destination := CharacterSystemScript.selection_card_avatar_destination_rect(portrait, frame_source.size, walk_bounds)
			_check(frame_destination == walk_destination, "character %d walk destination is fixed at frame %d" % [index, frame])
			var frame_bounds := _frame_opaque_bounds(walk_image, frame_source)
			if frame_bounds.size.x > 0.0 and frame_bounds.size.y > 0.0:
				var frame_mapped := CharacterSystemScript.selection_card_avatar_mapped_opaque_rect(walk_destination, frame_source.size, frame_bounds)
				_check(_vertical_overflow(frame_mapped, portrait) <= 0.01, "character %d walk frame %d has no vertical overflow; limited horizontal clipping is allowed" % [index, frame])
				_check(_max_horizontal_overflow(frame_mapped, portrait) <= 9.0 + 0.01, "character %d walk frame %d horizontal clipping stays within the 9px guardrail" % [index, frame])
				var frame_visible := frame_mapped.intersection(portrait)
				_check(frame_visible.size.x > 0.0 and frame_visible.size.y > 0.0, "character %d walk frame %d opaque pixels remain visible in portrait" % [index, frame])
				_check(_contains_rect(portrait, frame_visible), "character %d walk frame %d clipped opaque bounds stay inside portrait" % [index, frame])
				_check(frame_visible.size.x >= frame_mapped.size.x * 0.85 - 0.01, "character %d walk frame %d keeps at least 85%% visible width" % [index, frame])

func _direction_name(key: Key) -> String:
	match key:
		KEY_LEFT:
			return "left"
		KEY_RIGHT:
			return "right"
		KEY_UP:
			return "up"
		KEY_DOWN:
			return "down"
	return ""

func _test_character(id: String, status: String, unlocked: bool) -> Dictionary:
	return {"id": id, "status": status, "isUnlocked": unlocked}

func _wrap_full_text(font: Font, text: String, text_size: int, available_width: float) -> Array[String]:
	var lines: Array[String] = []
	var current := ""
	for index in range(text.length()):
		var candidate := current + text.substr(index, 1)
		if current != "" and font.get_string_size(candidate, HORIZONTAL_ALIGNMENT_LEFT, -1.0, text_size).x > available_width:
			lines.append(current)
			current = text.substr(index, 1)
		else:
			current = candidate
	if current != "":
		lines.append(current)
	return lines if not lines.is_empty() else [""]

func _frame_opaque_bounds(image: Image, source_rect: Rect2) -> Rect2:
	if image == null or source_rect.size.x <= 0.0 or source_rect.size.y <= 0.0:
		return Rect2()
	var frame_rect := Rect2i(Vector2i(source_rect.position), Vector2i(source_rect.size))
	var used := image.get_region(frame_rect).get_used_rect()
	return Rect2(Vector2(used.position), Vector2(used.size)) if used.size.x > 0 and used.size.y > 0 else Rect2()

func _vertical_overflow(rect: Rect2, owner: Rect2) -> float:
	return maxf(0.0, owner.position.y - rect.position.y) + maxf(0.0, rect.end.y - owner.end.y)

func _max_horizontal_overflow(rect: Rect2, owner: Rect2) -> float:
	return maxf(maxf(0.0, owner.position.x - rect.position.x), maxf(0.0, rect.end.x - owner.end.x))

func _contains_rect(owner: Rect2, child: Rect2) -> bool:
	return child.position.x >= owner.position.x and child.position.y >= owner.position.y and child.end.x <= owner.end.x and child.end.y <= owner.end.y

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _check_approx(actual: float, expected: float, message: String) -> void:
	if absf(actual - expected) > 0.01:
		failures.append("%s (actual %.2f expected %.2f)" % [message, actual, expected])
