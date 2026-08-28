class_name OptionsUiSystem
extends RefCounted

const PANEL_RECT := Rect2(230, 46, 1140, 812)
const OPTION_ITEM_COUNT := 6
const RESET_INDEX := 6
const BACK_INDEX := 7
const CARD_SIZE := Vector2(1036, 64)
const CARD_STEP_Y := 74.0
const CONTROL_SIZE := Vector2(298, 40)
const SLIDER_SIZE := Vector2(202, 18)
const TOGGLE_SIZE := Vector2(136, 36)
const SELECTOR_SIZE := Vector2(242, 36)
const STICK_ENGAGE_THRESHOLD := 0.60
const STICK_RELEASE_THRESHOLD := 0.35

static func panel_rect() -> Rect2:
	return PANEL_RECT

static func card_rect(index: int) -> Rect2:
	return Rect2(
		Vector2(PANEL_RECT.position.x + 52.0, PANEL_RECT.position.y + 136.0 + float(index) * CARD_STEP_Y),
		CARD_SIZE
	)

static func control_rect_for_card(card: Rect2) -> Rect2:
	return Rect2(card.position + Vector2(card.size.x - CONTROL_SIZE.x - 32.0, 12.0), CONTROL_SIZE)

static func control_rect(index: int) -> Rect2:
	return control_rect_for_card(card_rect(index))

static func slider_rect(index: int) -> Rect2:
	return Rect2(control_rect(index).position + Vector2(0, 11), SLIDER_SIZE)

static func toggle_rect(index: int) -> Rect2:
	return Rect2(control_rect(index).position + Vector2(106, 2), TOGGLE_SIZE)

static func selector_rect(index: int) -> Rect2:
	return Rect2(control_rect(index).position + Vector2(0, 2), SELECTOR_SIZE)

static func guide_rect() -> Rect2:
	return Rect2(PANEL_RECT.position + Vector2(250, 670), Vector2(560, 42))

static func reset_rect() -> Rect2:
	return Rect2(PANEL_RECT.position + Vector2(PANEL_RECT.size.x - 52.0 - 250.0, 724), Vector2(250, 54))

static func back_rect() -> Rect2:
	return Rect2(PANEL_RECT.position + Vector2(52, 724), Vector2(160, 54))

static func modal_rect() -> Rect2:
	return Rect2(PANEL_RECT.position + Vector2(230, 226), Vector2(680, 286))

static func modal_button_rect(index: int) -> Rect2:
	return Rect2(modal_rect().position + Vector2(96.0 + float(index) * 280.0, 206), Vector2(220, 50))

static func option_index_at(pos: Vector2) -> int:
	if reset_rect().has_point(pos):
		return RESET_INDEX
	if back_rect().has_point(pos):
		return BACK_INDEX
	for index in range(OPTION_ITEM_COUNT):
		if card_rect(index).has_point(pos):
			return index
	return -1

static func modal_choice_at(pos: Vector2) -> int:
	for index in range(2):
		if modal_button_rect(index).has_point(pos):
			return index
	return -1

static func slider_value_from_position(index: int, mouse_x: float) -> int:
	var rect := slider_rect(index)
	var ratio := clampf((mouse_x - rect.position.x) / rect.size.x, 0.0, 1.0)
	return clampi(roundi(ratio * 10.0) * 10, 0, 100)

static func vertical_navigation_index(index: int, direction: int) -> int:
	var normalized := posmod(index, OPTION_ITEM_COUNT + 2)
	if normalized == OPTION_ITEM_COUNT - 1 and direction > 0:
		return BACK_INDEX
	if normalized == RESET_INDEX or normalized == BACK_INDEX:
		return OPTION_ITEM_COUNT - 1 if direction < 0 else 0
	return posmod(normalized + direction, OPTION_ITEM_COUNT + 2)

static func button_navigation_index(index: int, direction: int) -> int:
	var normalized := posmod(index, OPTION_ITEM_COUNT + 2)
	if normalized == RESET_INDEX and direction != 0:
		return BACK_INDEX
	if normalized == BACK_INDEX and direction != 0:
		return RESET_INDEX
	return normalized

static func pad_action(button_index: int) -> String:
	match button_index:
		JOY_BUTTON_DPAD_UP:
			return "option_up"
		JOY_BUTTON_DPAD_DOWN:
			return "option_down"
		JOY_BUTTON_DPAD_LEFT:
			return "option_left"
		JOY_BUTTON_DPAD_RIGHT:
			return "option_right"
		JOY_BUTTON_A:
			return "option_select"
		JOY_BUTTON_B:
			return "back_to_title"
	return ""

static func ui_action(action: String) -> String:
	match action:
		"ui_up":
			return "option_up"
		"ui_down":
			return "option_down"
		"ui_left":
			return "option_left"
		"ui_right":
			return "option_right"
		"ui_accept":
			return "option_select"
		"ui_cancel":
			return "back_to_title"
	return ""

static func stick_latch_transition(previous_latch: int, axis_value: float) -> Dictionary:
	var current_latch := clampi(previous_latch, -1, 1)
	var magnitude := absf(axis_value)
	if current_latch == 0:
		if magnitude >= STICK_ENGAGE_THRESHOLD:
			var engaged := 1 if axis_value > 0.0 else -1
			return {"latch": engaged, "direction": engaged, "moved": true}
		return {"latch": 0, "direction": 0, "moved": false}
	if magnitude <= STICK_RELEASE_THRESHOLD:
		return {"latch": 0, "direction": 0, "moved": false}
	if magnitude >= STICK_ENGAGE_THRESHOLD:
		var direction := 1 if axis_value > 0.0 else -1
		if direction != current_latch:
			return {"latch": direction, "direction": direction, "moved": true}
	return {"latch": current_latch, "direction": 0, "moved": false}

static func toggle_label(enabled: bool) -> String:
	return "ON" if enabled else "OFF"

static func slider_label(value: int) -> String:
	return "%d%%" % clampi(value, 0, 100)

static func selector_label(value: String) -> String:
	return "< %s >" % value

static func reset_confirmation_action(index: int, action: String) -> String:
	if action == "option_left" or action == "option_right":
		return "toggle"
	if action == "option_select":
		return "reset" if index == 1 else "cancel"
	if action == "back_to_title":
		return "cancel"
	return "ignore"

static func footer_guide_text(back_label: String) -> String:
	return "↑↓：選択　←→：変更　Enter：決定　Esc：%s" % back_label

static func return_label(origin: String) -> String:
	return "ポーズへ戻る" if origin == "pause" else "戻る"

static func action_ids() -> Array[String]:
	return ["back", "reset"]
