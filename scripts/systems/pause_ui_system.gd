class_name PauseUiSystem
extends RefCounted

const DifficultyProgressSystemScript := preload("res://scripts/systems/difficulty_progress_system.gd")
const HudTextSystemScript := preload("res://scripts/systems/hud_text_system.gd")
const BuzzSystemScript := preload("res://scripts/systems/buzz_system.gd")
const CommonLightUiStyle := preload("res://scripts/ui/common_light_ui_style.gd")
const GameFontSystemScript := preload("res://scripts/systems/game_font_system.gd")

const PANEL_RECT := Rect2(188.0, 68.0, 1224.0, 744.0)
const ACTION_IDS := ["continue", "retry", "options", "title"]
const STICK_ENGAGE_THRESHOLD := 0.60
const STICK_RELEASE_THRESHOLD := 0.35

static func panel_rect() -> Rect2:
	return PANEL_RECT

static func layout(panel: Rect2 = PANEL_RECT) -> Dictionary:
	return {
		"panel": panel,
		"status": Rect2(panel.position + Vector2(36.0, 104.0), Vector2(1152.0, 116.0)),
		"weapon": Rect2(panel.position + Vector2(36.0, 236.0), Vector2(560.0, 234.0)),
		"accessory": Rect2(panel.position + Vector2(628.0, 236.0), Vector2(560.0, 234.0)),
		"instruction": Rect2(panel.position + Vector2(36.0, 486.0), Vector2(356.0, 136.0)),
		"rule": Rect2(panel.position + Vector2(416.0, 486.0), Vector2(356.0, 136.0)),
		"controls": Rect2(panel.position + Vector2(796.0, 486.0), Vector2(392.0, 136.0)),
		"actions": Rect2(panel.position + Vector2(36.0, 642.0), Vector2(1152.0, 84.0))
	}

static func status_cell_rects(status_rect: Rect2) -> Array[Rect2]:
	var result: Array[Rect2] = []
	var padding := Vector2(14.0, 10.0)
	var gap_x := 8.0
	var gap_y := 6.0
	var cell_size := Vector2(
		(status_rect.size.x - padding.x * 2.0 - gap_x * 4.0) / 5.0,
		(status_rect.size.y - padding.y * 2.0 - gap_y) / 2.0
	)
	for row in range(2):
		for column in range(5):
			result.append(Rect2(
				status_rect.position + padding + Vector2(float(column) * (cell_size.x + gap_x), float(row) * (cell_size.y + gap_y)),
				cell_size
			))
	return result

static func status_protection_badge_rect(cell_rect: Rect2) -> Rect2:
	return Rect2(Vector2(cell_rect.end.x - 62.0, cell_rect.position.y + 5.0), Vector2(58.0, 17.0))

static func status_cell_content_rects(cell_rect: Rect2, protection_charges: int = 0) -> Dictionary:
	var badge_rect := status_protection_badge_rect(cell_rect) if protection_charges > 0 else Rect2()
	var label_width := cell_rect.size.x - 20.0
	if protection_charges > 0:
		label_width = badge_rect.position.x - cell_rect.position.x - 14.0
	return {
		"label": Rect2(cell_rect.position + Vector2(10.0, 2.0), Vector2(maxf(1.0, label_width), 18.0)),
		"value": Rect2(cell_rect.position + Vector2(10.0, 22.0), Vector2(cell_rect.size.x - 20.0, cell_rect.size.y - 28.0)),
		"badge": badge_rect
	}

static func status_rows(context: Dictionary) -> Array[Dictionary]:
	var difficulty_id := DifficultyProgressSystemScript.normalize_difficulty_id(context.get("difficultyId", "normal"))
	var difficulty_view := HudTextSystemScript.stream_frame_card_view({
		"relayMode": bool(context.get("relayMode", false)),
		"streamFrame": context.get("streamFrame", {}),
		"streamFrameId": String(context.get("streamFrameId", "")),
		"difficultyId": difficulty_id
	})
	var frame_view := stream_rule_view(context)
	var run_length := float(context.get("runLength", INF))
	var elapsed := maxf(0.0, float(context.get("elapsed", 0.0)))
	var remaining_text := "制限なし" if is_inf(run_length) else _format_time(maxf(0.0, run_length - elapsed))
	var burn_combo := BuzzSystemScript.clamp_percent(int(context.get("burnCombo", 0)))
	var palette: Dictionary = CommonLightUiStyle.difficulty_palette(difficulty_id)
	return [
		{"key": "character", "label": "配信者", "value": String(context.get("characterName", "赤羽ばんり"))},
		{"key": "frame", "label": "配信枠", "value": String(frame_view.get("frameName", "雑談枠"))},
		{"key": "difficulty", "label": "難易度", "value": String(difficulty_view.get("difficultyLabel", "NORMAL")), "difficultyId": difficulty_id, "palette": palette},
		{"key": "remaining", "label": "残り時間", "value": remaining_text},
		{"key": "viewers", "label": "視聴者数", "value": "%d人" % maxi(0, int(context.get("score", 0)))},
		{"key": "voltage", "label": "ボルテージ", "value": "x%.1f" % float(context.get("multiplier", 1.0))},
		{"key": "buzz", "label": "バズ度", "value": "%d%%" % burn_combo},
		{"key": "score_multiplier", "label": "撃破スコア倍率", "value": "×%.2f" % BuzzSystemScript.score_multiplier(burn_combo)},
		{"key": "gift_hype", "label": "ギフト期待度", "value": "%d%%" % clampi(int(context.get("giftHype", 0)), 0, 100)},
		{"key": "heart_pending", "label": "♡待機", "value": "あり" if bool(context.get("heartPending", false)) else "なし"}
	]

static func stream_rule_view(context: Dictionary) -> Dictionary:
	if bool(context.get("relayMode", false)):
		return {
			"frameName": "配信リレー",
			"body": "5つの配信枠を連続で進む特別モードです。\n区間の合間に休憩が入り、回復かギフトを選べます。\n最後に時間制限なしの最終ボスへ挑みます。"
		}
	var frame_value: Variant = context.get("streamFrame", {})
	var frame: Dictionary = frame_value as Dictionary if frame_value is Dictionary else {}
	var raw_id := String(context.get("streamFrameId", frame.get("id", ""))).strip_edges().to_lower()
	var frame_id := DifficultyProgressSystemScript.normalize_stage_id(raw_id) if raw_id != "" else ""
	var frame_name := String(frame.get("displayName", "")).strip_edges()
	var names: Dictionary = {
		"zatsudan": "雑談枠",
		"gameplay": "ゲーム実況枠",
		"singing": "歌枠",
		"drawing": "お絵かき枠",
		"collab": "コラボ枠"
	}
	var bodies: Dictionary = {
		"zatsudan": "マシュマロが届く基本配信枠です。\n拾うとメリット効果、たまにクソマロが混ざります。",
		"gameplay": "一定時間ごとにジャンルイベントが発生します。\nレース風、弾幕風、ホラー風などが一時的に混ざります。",
		"singing": "一定時間ごとにサビタイムが発生します。\n音符やスポットライトでライブ熱を高めます。",
		"drawing": "絵の具で線を描き、同じ色で囲うと内側を塗れます。\n塗った範囲で敵を足止めし、ダメージを与えます。",
		"collab": "相方支援とコラボパスで連携する配信枠です。\nシンクロスターを集めてペア技を狙います。"
	}
	if frame_id == "":
		frame_id = "zatsudan"
	var canonical_name := String(names.get(frame_id, frame_name if frame_name != "" else "雑談枠"))
	return {"frameName": canonical_name, "body": String(bodies.get(frame_id, bodies["zatsudan"])), "frameId": frame_id}

static func instruction_style(active: bool) -> Dictionary:
	if active:
		return {
			"fill": Color("#fff1f8"),
			"border": Color("#ff8fc4"),
			"text": Color("#6d214d"),
			"badgeFill": Color("#ff5aa5"),
			"badgeText": Color.WHITE,
			"badge": "発動中",
			"body": ""
		}
	return {
		"fill": Color("#f7f4fa"),
		"border": Color("#d6ccdf"),
		"text": Color("#81758b"),
		"badgeFill": Color("#e6e0eb"),
		"badgeText": Color("#75697e"),
		"badge": "なし",
		"body": "現在、発動中の指示コメはありません。"
	}

static func instruction_view(context: Dictionary) -> Dictionary:
	var active := bool(context.get("active", false))
	if not context.has("active"):
		active = String(context.get("currentComment", "なし")) != "なし" and float(context.get("effectTimer", 0.0)) > 0.0
	var view := instruction_style(active)
	view["active"] = active
	view["commentName"] = String(context.get("commentName", ""))
	view["remainingText"] = "%02d秒" % maxi(0, int(ceil(float(context.get("effectTimer", 0.0)))))
	if active:
		view["body"] = String(context.get("body", context.get("activeBody", "効果：なし")))
	return view

static func equipment_layout(panel: Rect2) -> Dictionary:
	var slot_size := Vector2(58.0, 58.0)
	var slot_gap := 10.0
	var total_width := slot_size.x * 5.0 + slot_gap * 4.0
	var start_x := (panel.size.x - total_width) * 0.5
	var slots: Array[Rect2] = []
	for index in range(5):
		slots.append(Rect2(panel.position + Vector2(start_x + float(index) * (slot_size.x + slot_gap), 54.0), slot_size))
	return {
		"slots": slots,
		"description": Rect2(panel.position + Vector2(18.0, 120.0), Vector2(panel.size.x - 36.0, 106.0)),
		"slotSize": slot_size,
		"slotGap": slot_gap
	}

static func equipment_description_source(row: int, active_row: bool) -> String:
	if not active_row:
		return "default"
	return "weapon" if row == 0 else "accessory"

static func equipment_description(selected_info: Dictionary, is_weapon: bool, active_row: bool) -> Dictionary:
	if not active_row:
		return {
			"title": "装備説明",
			"body": "武器・アクセサリにカーソルを合わせると説明が表示されます"
		}
	if selected_info.is_empty() or not bool(selected_info.get("filled", false)):
		return {
			"title": "空き武器スロット" if is_weapon else "空きアクセサリスロット",
			"body": "ギフトで武器を入手すると、ここに表示されます" if is_weapon else "ギフトでアクセサリを入手すると、ここに表示されます"
		}
	var level_text: String = "進化" if bool(selected_info.get("evolved", false)) else "Lv%d" % int(selected_info.get("level", 1))
	return {
		"title": "%s %s" % [String(selected_info.get("name", "")), level_text],
		"body": String(selected_info.get("description", "")),
		"guide": String(selected_info.get("recipeGuide", ""))
	}

static func equipment_description_line_layout(rect: Rect2, description: Dictionary) -> Array[Dictionary]:
	var title := String(description.get("title", ""))
	var has_detail_title := title != "" and title != "装備説明"
	var source_lines: Array[String] = []
	var body_lines := _description_lines(String(description.get("body", "")))
	if not body_lines.is_empty():
		var body_text := " ".join(body_lines)
		source_lines.append(body_text)
	var guide_lines := _description_lines(String(description.get("guide", "")))
	if not guide_lines.is_empty():
		if guide_lines[0] == "進化条件" and guide_lines.size() >= 3:
			# EvolutionRecipeGuideSystemScript emits these lines by position:
			# header, condition, destination, then an optional note.
			source_lines.append(guide_lines[0])
			source_lines.append(guide_lines[1])
			source_lines.append(guide_lines[2])
			for index in range(3, guide_lines.size()):
				source_lines.append(guide_lines[index])
		else:
			source_lines.append_array(guide_lines)
	var max_lines := 4 if has_detail_title else 5
	var line_height := 13.0
	var first_baseline := 52.0 if has_detail_title else 40.0
	var font_size := 11
	var available_width := maxf(1.0, rect.size.x - 32.0)
	var result: Array[Dictionary] = []
	for index in range(mini(max_lines, source_lines.size())):
		var baseline := rect.position.y + first_baseline + float(index) * line_height
		var line_rect := Rect2(Vector2(rect.position.x + 16.0, baseline - float(font_size)), Vector2(available_width, float(font_size) + 2.0))
		result.append({
			"text": _fit_measured_line(source_lines[index], font_size, available_width),
			"baseline": baseline,
			"rect": line_rect,
			"fontSize": font_size
		})
	return result

static func navigation_snapshot(menu_index: int, focus_area: String, equipment_row: int, weapon_index: int, accessory_index: int, confirm_index: int) -> Dictionary:
	return {
		"menuIndex": menu_index,
		"focusArea": focus_area,
		"equipmentRow": equipment_row,
		"weaponIndex": weapon_index,
		"accessoryIndex": accessory_index,
		"confirmIndex": confirm_index
	}

static func navigation_changed(before: Dictionary, after: Dictionary) -> bool:
	for key in ["menuIndex", "focusArea", "equipmentRow", "weaponIndex", "accessoryIndex", "confirmIndex"]:
		if before.get(key) != after.get(key):
			return true
	return false

static func instruction_body_lines(text: String, available_width: float, text_size: int = 13, max_lines: int = 4) -> Array[String]:
	var result: Array[String] = []
	for raw_line in text.replace("\r", "").split("\n"):
		var line := String(raw_line).strip_edges()
		if line == "":
			continue
		result.append(_fit_measured_line(line, text_size, available_width))
	if result.size() > max_lines:
		result = result.slice(0, max_lines)
		var last := result.size() - 1
		result[last] = _fit_measured_line(result[last].trim_suffix("…") + "…", text_size, available_width)
	return result

static func action_button_ids() -> Array[String]:
	return ["continue", "retry", "options", "title"]

static func action_button_rects(rect: Rect2) -> Array[Rect2]:
	var result: Array[Rect2] = []
	var gap := 20.0
	var button_width := (rect.size.x - 48.0 - gap * 3.0) / 4.0
	for index in range(4):
		result.append(Rect2(rect.position + Vector2(24.0 + float(index) * (button_width + gap), 17.0), Vector2(button_width, 50.0)))
	return result

static func action_button_style(button_id: String) -> Dictionary:
	var styles: Dictionary = {
		"continue": {"fill": Color("#ff5aa5"), "text": Color.WHITE, "border": Color("#e83d8b")},
		"retry": {"fill": Color("#f8f2ff"), "text": Color("#7a56c8"), "border": Color("#cdb7ef")},
		"options": {"fill": Color("#f3eff7"), "text": Color("#6b5f78"), "border": Color("#d7cde0")},
		"title": {"fill": Color("#e8f7ff"), "text": Color("#2587b8"), "border": Color("#9ed9f4")}
	}
	return styles.get(button_id, styles["options"])

static func action_focus_visual(_button_id: String, selected: bool, phase: float) -> Dictionary:
	if not selected:
		return {"selected": false, "pulse": 0.0, "glowAlpha": 0.0, "grow": 0.0}
	var pulse := (sin(fposmod(phase, 1.0) * TAU) + 1.0) * 0.5
	return {
		"selected": true,
		"pulse": pulse,
		"glowAlpha": lerpf(0.07, 0.13, pulse),
		"grow": lerpf(5.0, 6.5, pulse)
	}

static func action_focus_marker_rects(button_rect: Rect2) -> Array[Rect2]:
	var center_y := button_rect.get_center().y
	return [
		Rect2(Vector2(button_rect.position.x - 15.0, center_y - 9.0), Vector2(12.0, 18.0)),
		Rect2(Vector2(button_rect.end.x + 3.0, center_y - 9.0), Vector2(12.0, 18.0))
	]

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

static func selected_action_id(index: int) -> String:
	return String(action_button_ids()[posmod(index, 4)])

static func pause_input_action(keycode: int = -1, button_index: int = -1, action_name: String = "", pressed: bool = true) -> String:
	if not pressed:
		return ""
	if action_name == "ui_up":
		return "pause_up"
	if action_name == "ui_down":
		return "pause_down"
	if action_name == "ui_left":
		return "pause_left"
	if action_name == "ui_right":
		return "pause_right"
	if action_name == "ui_accept":
		return "pause_select"
	if action_name == "ui_cancel":
		return "pause_cancel"
	match button_index:
		JOY_BUTTON_DPAD_UP:
			return "pause_up"
		JOY_BUTTON_DPAD_DOWN:
			return "pause_down"
		JOY_BUTTON_DPAD_LEFT:
			return "pause_left"
		JOY_BUTTON_DPAD_RIGHT:
			return "pause_right"
		JOY_BUTTON_A:
			return "pause_select"
		JOY_BUTTON_B:
			return "pause_cancel"
	match keycode:
		KEY_UP, KEY_W:
			return "pause_up"
		KEY_DOWN, KEY_S:
			return "pause_down"
		KEY_LEFT, KEY_A:
			return "pause_left"
		KEY_RIGHT, KEY_D:
			return "pause_right"
		KEY_1:
			return "pause_continue"
		KEY_2:
			return "pause_retry"
		KEY_3:
			return "pause_options"
		KEY_4:
			return "pause_title"
		KEY_ENTER, KEY_SPACE:
			return "pause_select"
		KEY_ESCAPE:
			return "pause_cancel"
		KEY_Y:
			return "pause_confirm"
		KEY_N, KEY_BACKSPACE:
			return "pause_cancel"
	return ""

static func _fit_measured_line(text: String, text_size: int, available_width: float) -> String:
	var fitted := text.strip_edges()
	if fitted == "":
		return ""
	var font := GameFontSystemScript.regular_font()
	if font.get_string_size(fitted, HORIZONTAL_ALIGNMENT_LEFT, -1.0, text_size).x <= available_width:
		return fitted
	while fitted.length() > 1:
		var candidate := fitted.substr(0, fitted.length() - 1).strip_edges() + "…"
		if font.get_string_size(candidate, HORIZONTAL_ALIGNMENT_LEFT, -1.0, text_size).x <= available_width:
			return candidate
		fitted = fitted.substr(0, fitted.length() - 1).strip_edges()
	return "…"

static func _description_lines(text: String) -> Array[String]:
	var result: Array[String] = []
	for raw_line in text.replace("\r", "").split("\n"):
		var line := String(raw_line).strip_edges()
		if line != "":
			result.append(line)
	return result

static func _format_time(seconds: float) -> String:
	var total_seconds := maxi(0, int(ceil(seconds)))
	return "%02d:%02d" % [total_seconds / 60, total_seconds % 60]
