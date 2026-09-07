class_name CollabPartnerUiSystem
extends RefCounted

const CharacterSystemScript := preload("res://scripts/systems/character_system.gd")
const GameFontSystemScript := preload("res://scripts/systems/game_font_system.gd")

const CARD_COLUMNS := 3
const CARD_SIZE := Vector2(300.0, 276.0)
const CARD_GAP := Vector2(16.0, 16.0)
const CARD_GRID_ORIGIN := Vector2(28.0, 78.0)
const CARD_NUMBER_RECT := Rect2(18.0, 12.0, 42.0, 28.0)
const CARD_NAME_RECT := Rect2(64.0, 12.0, 218.0, 28.0)
const CARD_AVATAR_RECT := Rect2(18.0, 52.0, 264.0, 100.0)
const CARD_SUPPORT_RECT := Rect2(18.0, 156.0, 264.0, 60.0)
const CARD_PAIR_RECT := Rect2(18.0, 220.0, 264.0, 48.0)
const CARD_SELECTED_BADGE_RECT := Rect2(192.0, 56.0, 90.0, 28.0)
const CURRENT_AVATAR_VISUAL_HEIGHT := 200.0
const CANDIDATE_AVATAR_VISUAL_HEIGHT := 92.0
const CONTENT_INSET := 12.0

static func card_rect(panel: Rect2, index: int) -> Rect2:
	var safe_index: int = maxi(0, index)
	var col: int = safe_index % CARD_COLUMNS
	var row: int = int(safe_index / CARD_COLUMNS)
	return Rect2(
		panel.position + CARD_GRID_ORIGIN + Vector2(
			float(col) * (CARD_SIZE.x + CARD_GAP.x),
			float(row) * (CARD_SIZE.y + CARD_GAP.y)
		),
		CARD_SIZE
	)

static func candidate_content_rects(card: Rect2) -> Dictionary:
	return {
		"number": Rect2(card.position + CARD_NUMBER_RECT.position, CARD_NUMBER_RECT.size),
		"name": Rect2(card.position + CARD_NAME_RECT.position, CARD_NAME_RECT.size),
		"avatar": Rect2(card.position + CARD_AVATAR_RECT.position, CARD_AVATAR_RECT.size),
		"support": Rect2(card.position + CARD_SUPPORT_RECT.position, CARD_SUPPORT_RECT.size),
		"pair": Rect2(card.position + CARD_PAIR_RECT.position, CARD_PAIR_RECT.size),
		"selectedBadge": Rect2(card.position + CARD_SELECTED_BADGE_RECT.position, CARD_SELECTED_BADGE_RECT.size)
	}

static func current_content_rects(panel: Rect2) -> Dictionary:
	return {
		"label": Rect2(panel.position + Vector2(30.0, 24.0), Vector2(panel.size.x - 60.0, 30.0)),
		"name": Rect2(panel.position + Vector2(24.0, 58.0), Vector2(panel.size.x - 48.0, 36.0)),
		"avatar": Rect2(panel.position + Vector2(34.0, 122.0), Vector2(panel.size.x - 68.0, 318.0)),
		"intro": Rect2(panel.position + Vector2(30.0, 474.0), Vector2(panel.size.x - 60.0, 116.0))
	}

static func candidate_avatar_mode(status: String, selectable: bool, selected: bool) -> String:
	return CharacterSystemScript.selection_card_avatar_mode(status, selectable, selected)

static func candidate_walk_frame(time: float, status: String, selectable: bool, selected: bool, columns: int = 10, fps: float = CharacterSystemScript.SELECT_CARD_WALK_FPS) -> int:
	var animate: bool = CharacterSystemScript.selection_card_walk_should_animate(status, selectable, selected)
	return CharacterSystemScript.selection_card_walk_frame_index(time, animate, selectable, columns, fps)

static func text_width(text: String, text_size: int) -> float:
	return GameFontSystemScript.regular_font().get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, text_size).x

static func wrap_text_full(text: String, text_size: int, available_width: float) -> Array[String]:
	var lines: Array[String] = []
	var current := ""
	for index in range(text.length()):
		var candidate := current + text.substr(index, 1)
		if current != "" and text_width(candidate, text_size) > available_width:
			lines.append(current)
			current = text.substr(index, 1)
		else:
			current = candidate
	if current != "":
		lines.append(current)
	return lines if not lines.is_empty() else [""]

static func text_layout(text: String, available_width: float, desired_size: int, minimum_size: int, max_lines: int) -> Dictionary:
	var safe_width: float = maxf(1.0, available_width)
	var top_size: int = maxi(minimum_size, desired_size)
	for text_size in range(top_size, minimum_size - 1, -1):
		if text_width(text, text_size) <= safe_width:
			return {"lines": [text], "size": text_size}
	var lines: Array[String] = wrap_text_full(text, minimum_size, safe_width)
	if lines.size() <= maxi(1, max_lines):
		return {"lines": lines, "size": minimum_size}
	return {"lines": lines, "size": minimum_size}

static func candidate_section_text_layout(rect: Rect2, text: String, desired_size: int, minimum_size: int, max_lines: int) -> Dictionary:
	var body_rect := Rect2(
		rect.position + Vector2(CONTENT_INSET, 24.0),
		Vector2(maxf(1.0, rect.size.x - CONTENT_INSET * 2.0), maxf(1.0, rect.size.y - 28.0))
	)
	var layout: Dictionary = text_layout(text, body_rect.size.x, desired_size, minimum_size, max_lines)
	var line_size: int = int(layout.get("size", minimum_size))
	var first_baseline: float = rect.position.y + (38.0 if rect.size.y >= 56.0 else 34.0)
	return {
		"titleRect": Rect2(rect.position + Vector2(CONTENT_INSET, 6.0), Vector2(rect.size.x - CONTENT_INSET * 2.0, 20.0)),
		"bodyRect": body_rect,
		"lines": layout.get("lines", []),
		"size": line_size,
		"firstBaseline": first_baseline,
		"lineHeight": float(line_size + 2)
	}

static func candidate_name_layout(name: String) -> Dictionary:
	return text_layout(name, CARD_NAME_RECT.size.x, 29, 16, 1)
