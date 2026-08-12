class_name ChoiceCardSystem
extends RefCounted

const GameFontSystemScript := preload("res://scripts/systems/game_font_system.gd")
const BuzzSystemScript := preload("res://scripts/systems/buzz_system.gd")
const EvolutionRecipeGuideSystemScript := preload("res://scripts/systems/evolution_recipe_guide_system.gd")

static func hidden_card() -> Dictionary:
	return {"text": "", "fill": Color(1.0, 1.0, 1.0, 0.88), "border": Color("#c6dfff")}

static func selection_action(latch: Dictionary, current: int, count: int = 3) -> Dictionary:
	var safe_count: int = maxi(1, count)
	var safe_current: int = clampi(current, 0, safe_count - 1)
	var wrap_edges: bool = safe_count == 3
	if _pressed(latch, KEY_LEFT) or _pressed(latch, KEY_UP):
		var previous_index: int = posmod(safe_current - 1, safe_count) if wrap_edges else maxi(0, safe_current - 1)
		return {"kind": "move", "index": previous_index}
	if _pressed(latch, KEY_RIGHT) or _pressed(latch, KEY_DOWN):
		var next_index: int = posmod(safe_current + 1, safe_count) if wrap_edges else mini(safe_count - 1, safe_current + 1)
		return {"kind": "move", "index": next_index}
	var keys: Array = [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5]
	for i in range(mini(safe_count, keys.size())):
		if _pressed(latch, keys[i]):
			return {"kind": "select", "index": i}
	if _pressed(latch, KEY_ENTER) or _pressed(latch, KEY_SPACE):
		return {"kind": "select", "index": safe_current}
	return {"kind": "", "index": safe_current}

static func special_card_selection_action(latch: Dictionary, current: int, normal_count: int = 3, return_index: int = 0) -> Dictionary:
	var safe_normal_count: int = maxi(1, normal_count)
	var special_index: int = safe_normal_count
	var safe_current: int = clampi(current, 0, special_index)
	var safe_return: int = clampi(return_index, 0, safe_normal_count - 1)
	if safe_current < safe_normal_count:
		safe_return = safe_current
	if _pressed(latch, KEY_LEFT):
		if safe_current < safe_normal_count:
			var previous_index: int = posmod(safe_current - 1, safe_normal_count)
			return {"kind": "move", "index": previous_index, "returnIndex": previous_index}
		return {"kind": "", "index": safe_current, "returnIndex": safe_return}
	if _pressed(latch, KEY_RIGHT):
		if safe_current < safe_normal_count:
			var next_index: int = posmod(safe_current + 1, safe_normal_count)
			return {"kind": "move", "index": next_index, "returnIndex": next_index}
		return {"kind": "", "index": safe_current, "returnIndex": safe_return}
	if _pressed(latch, KEY_UP) or _pressed(latch, KEY_DOWN):
		if safe_current == special_index:
			return {"kind": "move", "index": safe_return, "returnIndex": safe_return}
		return {"kind": "move", "index": special_index, "returnIndex": safe_current}
	var keys: Array = [KEY_1, KEY_2, KEY_3, KEY_4]
	for i in range(keys.size()):
		if _pressed(latch, keys[i]):
			return {"kind": "select", "index": i, "returnIndex": safe_return}
	if _pressed(latch, KEY_ENTER) or _pressed(latch, KEY_SPACE):
		return {"kind": "select", "index": safe_current, "returnIndex": safe_return}
	return {"kind": "", "index": safe_current, "returnIndex": safe_return}

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
	if _pressed(latch, KEY_UP) or _pressed(latch, KEY_W):
		if local >= safe_columns:
			return {"kind": "move", "index": safe_current - safe_columns}
		if page > 0:
			return {"kind": "move", "index": _page_target(page - 1, safe_columns + col, count, safe_page_size)}
		return {"kind": "", "index": safe_current}
	if _pressed(latch, KEY_DOWN) or _pressed(latch, KEY_S):
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

static func buzz_gain_for_risk(risk: int) -> int:
	return BuzzSystemScript.gain_for_risk(risk)

static func buzz_gain_text(risk: int) -> String:
	var gain := buzz_gain_for_risk(risk)
	return "📈 バズ度 +%d%%" % gain

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
		"text": "[%d]\n%s\n\n%s\n\n%s\nボルテージ x%.1f\nギフト期待 +%d\n危険度 %d" % [
			index + 1,
			String(view["displayName"]),
			String(view["description"]),
			buzz_gain_text(risk),
			float(view["multiplier"]),
			int(view["giftHypeOnSelect"]),
			int(view["riskLevel"])
		],
		"fill": Color(1.0, 1.0, 1.0, 0.94),
		"border": border,
		"styleKey": "comment_image"
	}

static func gift_card(index: int, gift: Dictionary, gift_level: int, guide_context: Dictionary = {}) -> Dictionary:
	var is_pp := String(gift.get("type", gift.get("category", ""))) == "pp" or String(gift.get("category", "")) == "pp"
	var quality_label: String = GiftSystem.gift_quality_label(gift).replace("\n", " ")
	var category: String = GiftSystem.gift_category_tag(gift)
	var display_name: String = String(gift.get("displayName", "パワーアップポイント")) if is_pp else EquipmentSystem.display_name_for_card(gift, gift_level)
	var stamp_line: String = "%s\n" % quality_label if quality_label != "" else ""
	var level_text: String = GiftSystem.gift_level_change_text(gift, gift_level)
	var summary: String = GiftSystem.gift_card_summary(gift)
	var status: String = GiftSystem.gift_level_status_text(gift, gift_level)
	var recipe_line := EvolutionRecipeGuideSystemScript.card_line_for_gift(gift, guide_context)
	if recipe_line != "":
		status = recipe_line
	return {
		"text": "[%d]\n%s[%s]\n%s\n%s\n%s\n%s" % [
			index + 1,
			stamp_line,
			category,
			display_name,
			level_text,
			summary,
			status
		],
		"fill": Color(1.0, 1.0, 1.0, 0.98),
		"border": GiftSystem.gift_quality_color(gift),
		"styleKey": "gift_quality" if not is_pp else "gift_pp"
	}

static func refresh_buttons(buttons: Array, cards: Array, selected_index: int) -> void:
	for i in range(buttons.size()):
		var button: Button = buttons[i]
		var has_card := i < cards.size()
		button.visible = has_card
		button.disabled = not has_card
		button.icon = null
		if not has_card:
			button.text = ""
			continue
		GameFontSystemScript.apply_regular_font(button)
		button.add_theme_font_size_override("font_size", 19)
		var card: Dictionary = cards[i] as Dictionary
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

static func gift_cards(gifts: Array, gift_levels: Dictionary, guide_context: Dictionary = {}) -> Array:
	var cards: Array = []
	for i in range(gifts.size()):
		var gift: Dictionary = gifts[i] as Dictionary
		cards.append(gift_card(i, gift, int(gift_levels.get(String(gift["id"]), 0)), guide_context))
	return cards

static func gift_cards_for_target(target: Node, gifts: Array) -> Array:
	var levels: Dictionary = {}
	for gift_item in gifts:
		var gift: Dictionary = gift_item as Dictionary
		levels[String(gift["id"])] = GiftSystem.gift_level_for_target(target, String(gift["id"]))
	return gift_cards(gifts, levels, EvolutionRecipeGuideSystemScript.context_for_target(target))

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
