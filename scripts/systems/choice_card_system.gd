class_name ChoiceCardSystem
extends RefCounted

const GameFontSystemScript := preload("res://scripts/systems/game_font_system.gd")

static func hidden_card() -> Dictionary:
	return {"text": "", "fill": Color(1.0, 1.0, 1.0, 0.88), "border": Color("#c6dfff")}

static func selection_action(latch: Dictionary, current: int, count: int = 3) -> Dictionary:
	if _pressed(latch, KEY_LEFT) or _pressed(latch, KEY_UP):
		return {"kind": "move", "index": maxi(0, current - 1)}
	if _pressed(latch, KEY_RIGHT) or _pressed(latch, KEY_DOWN):
		return {"kind": "move", "index": mini(count - 1, current + 1)}
	var keys: Array = [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5]
	for i in range(mini(count, keys.size())):
		if _pressed(latch, keys[i]):
			return {"kind": "select", "index": i}
	if _pressed(latch, KEY_ENTER) or _pressed(latch, KEY_SPACE):
		return {"kind": "select", "index": current}
	return {"kind": "", "index": current}

static func menu_selection_action(latch: Dictionary, current: int, count: int, max_number_key: int) -> Dictionary:
	if _pressed(latch, KEY_ESCAPE):
		return {"kind": "escape", "index": current}
	if _pressed(latch, KEY_LEFT) or _pressed(latch, KEY_UP):
		return {"kind": "move", "index": posmod(current - 1, maxi(1, count))}
	if _pressed(latch, KEY_RIGHT) or _pressed(latch, KEY_DOWN):
		return {"kind": "move", "index": posmod(current + 1, maxi(1, count))}
	var keys: Array = [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6]
	for i in range(mini(max_number_key, keys.size())):
		if _pressed(latch, keys[i]):
			return {"kind": "select", "index": i if i < count else -1}
	if _pressed(latch, KEY_ENTER) or _pressed(latch, KEY_SPACE):
		return {"kind": "select", "index": current}
	return {"kind": "", "index": current}

static func character_grid_selection_action(latch: Dictionary, current: int, count: int, page_size: int, columns: int, max_number_key: int) -> Dictionary:
	if _pressed(latch, KEY_ESCAPE):
		return {"kind": "escape", "index": current}
	if count <= 0:
		return {"kind": "", "index": 0}
	var safe_page_size: int = maxi(1, page_size)
	var safe_columns: int = maxi(1, columns)
	var safe_current: int = clampi(current, 0, count - 1)
	var page: int = int(safe_current / safe_page_size)
	var page_count: int = int(ceil(float(count) / float(safe_page_size)))
	var local: int = safe_current - page * safe_page_size
	var col: int = local % safe_columns
	if _pressed(latch, KEY_A) or _pressed(latch, KEY_Q):
		if page > 0:
			return {"kind": "move", "index": _page_target(page - 1, local, count, safe_page_size)}
		return {"kind": "", "index": safe_current}
	if _pressed(latch, KEY_D) or _pressed(latch, KEY_E):
		if page + 1 < page_count:
			return {"kind": "move", "index": _page_target(page + 1, local, count, safe_page_size)}
		return {"kind": "", "index": safe_current}
	if _pressed(latch, KEY_LEFT):
		if col > 0:
			return {"kind": "move", "index": safe_current - 1}
		if page > 0:
			return {"kind": "move", "index": _page_target(page - 1, safe_columns - 1, count, safe_page_size)}
		return {"kind": "", "index": safe_current}
	if _pressed(latch, KEY_RIGHT):
		if col < safe_columns - 1 and safe_current + 1 < count and safe_current + 1 < (page + 1) * safe_page_size:
			return {"kind": "move", "index": safe_current + 1}
		if page + 1 < page_count:
			return {"kind": "move", "index": _page_target(page + 1, 0, count, safe_page_size)}
		return {"kind": "", "index": safe_current}
	if _pressed(latch, KEY_UP):
		if local >= safe_columns:
			return {"kind": "move", "index": safe_current - safe_columns}
		if page > 0:
			return {"kind": "move", "index": _page_target(page - 1, safe_columns + col, count, safe_page_size)}
		return {"kind": "", "index": safe_current}
	if _pressed(latch, KEY_DOWN):
		if local + safe_columns < safe_page_size and safe_current + safe_columns < count:
			return {"kind": "move", "index": safe_current + safe_columns}
		if page + 1 < page_count:
			return {"kind": "move", "index": _page_target(page + 1, col, count, safe_page_size)}
		return {"kind": "", "index": safe_current}
	var keys: Array = [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6]
	for i in range(mini(max_number_key, keys.size())):
		if _pressed(latch, keys[i]):
			return {"kind": "select", "index": i if i < count else -1}
	if _pressed(latch, KEY_ENTER) or _pressed(latch, KEY_SPACE):
		return {"kind": "select", "index": safe_current}
	return {"kind": "", "index": safe_current}

static func is_escape(action: Dictionary) -> bool:
	return String(action["kind"]) == "escape"

static func is_move(action: Dictionary) -> bool:
	return String(action["kind"]) == "move"

static func is_select(action: Dictionary) -> bool:
	return String(action["kind"]) == "select"

static func comment_card(index: int, view: Dictionary, has_heart: bool, choice_timer: float, elapsed: float) -> Dictionary:
	var risk: int = int(view["riskLevel"])
	var border: Color = Color("#60a5ff")
	if risk == 3:
		border = Color("#b768ff")
	elif risk >= 4:
		border = Color("#ff3333")
	if choice_timer <= 5.0:
		border = Color("#ff3333").lightened(0.18 + sin(elapsed * 12.0) * 0.08)
	if has_heart:
		border = border.lightened(0.35)
	return {
		"text": "[%d]\n%s\n\n%s\n\nボルテージ x%.1f\nギフト期待 +%d\n危険度 %d" % [
			index + 1,
			String(view["displayName"]),
			String(view["description"]),
			float(view["multiplier"]),
			int(view["giftHypeOnSelect"]),
			int(view["riskLevel"])
		],
		"fill": Color(1.0, 1.0, 1.0, 0.94),
		"border": border,
		"styleKey": "comment_image"
	}

static func gift_card(index: int, gift: Dictionary, gift_level: int) -> Dictionary:
	var rarity: String = String(gift["rarity"])
	var category: String = EquipmentSystem.category_label_for_card(gift, gift_level)
	var display_name: String = EquipmentSystem.display_name_for_card(gift, gift_level)
	var level_text: String = ""
	if not EquipmentSystem.is_instant(gift):
		level_text = "\nLv %d/%d" % [gift_level, int(gift["maxLevel"])]
	return {
		"text": "[%d]\n[%s]\n%s\n%s\n\n%s%s" % [
			index + 1,
			category,
			DisplayTextSystem.rarity_label(rarity),
			display_name,
			String(gift["description"]),
			level_text
		],
		"fill": Color(1.0, 1.0, 1.0, 0.98),
		"border": DisplayTextSystem.rarity_color(rarity),
		"styleKey": "gift_%s" % rarity
	}

static func refresh_buttons(buttons: Array, cards: Array, selected_index: int) -> void:
	for i in range(buttons.size()):
		var button: Button = buttons[i]
		GameFontSystemScript.apply_regular_font(button)
		button.add_theme_font_size_override("font_size", 19)
		var card: Dictionary = hidden_card()
		if i < cards.size():
			card = cards[i] as Dictionary
		button.text = String(card["text"])
		UiStyleSystem.apply_choice_button(button, card["fill"] as Color, card["border"] as Color, i == selected_index, String(card.get("styleKey", "")))

static func comment_cards(comments: Array, _ng_cards: Array, heart_cards: Array, choice_timer: float, elapsed: float) -> Array:
	var cards: Array = []
	for i in range(comments.size()):
		var comment: Dictionary = comments[i] as Dictionary
		var has_heart: bool = i < heart_cards.size() and bool(heart_cards[i])
		var view: Dictionary = CommentSystem.comment_view(comment, has_heart)
		cards.append(comment_card(i, view, has_heart, choice_timer, elapsed))
	return cards

static func gift_cards(gifts: Array, gift_levels: Dictionary) -> Array:
	var cards: Array = []
	for i in range(gifts.size()):
		var gift: Dictionary = gifts[i] as Dictionary
		cards.append(gift_card(i, gift, int(gift_levels.get(String(gift["id"]), 0))))
	return cards

static func gift_cards_for_target(target: Node, gifts: Array) -> Array:
	var levels: Dictionary = {}
	for gift_item in gifts:
		var gift: Dictionary = gift_item as Dictionary
		levels[String(gift["id"])] = GiftSystem.gift_level_for_target(target, String(gift["id"]))
	return gift_cards(gifts, levels)

static func cards_for_target(
	target: Node,
	state: String,
	offered_comments: Array,
	ng_cards: Array,
	heart_cards: Array,
	choice_timer: float,
	elapsed: float,
	offered_gifts: Array
) -> Array:
	if state == "comment_choice":
		return comment_cards(offered_comments, ng_cards, heart_cards, choice_timer, elapsed)
	if state == "gift_choice":
		return gift_cards_for_target(target, offered_gifts)
	return []

static func refresh_for_target(target: Node, buttons: Array, state: String) -> void:
	var cards: Array = cards_for_target(
		target,
		state,
		target.get("offered_comments") as Array,
		target.get("ng_cards") as Array,
		target.get("heart_cards") as Array,
		float(target.get("choice_timer")),
		float(target.get("elapsed")),
		target.get("offered_gifts") as Array
	)
	refresh_buttons(buttons, cards, int(target.get("selected_card")))

static func _pressed(latch: Dictionary, keycode: Key) -> bool:
	var down: bool = Input.is_key_pressed(keycode)
	var was_down: bool = bool(latch.get(keycode, false))
	latch[keycode] = down
	return down and not was_down

static func _page_target(page: int, local: int, count: int, page_size: int) -> int:
	if count <= 0:
		return 0
	var clamped_page: int = clampi(page, 0, maxi(0, int(ceil(float(count) / float(maxi(1, page_size)))) - 1))
	var start: int = clamped_page * page_size
	var end: int = mini(start + page_size, count)
	return clampi(start + local, start, end - 1)
