extends Node

const PauseUiSystemScript := preload("res://scripts/systems/pause_ui_system.gd")
const CommonLightUiStyle := preload("res://scripts/ui/common_light_ui_style.gd")
const GameFontSystemScript := preload("res://scripts/systems/game_font_system.gd")

var failures: Array[String] = []

func _ready() -> void:
	_check_layout()
	_check_status_rows()
	_check_stream_rules()
	_check_instruction_styles()
	_check_equipment_geometry()
	_check_actions_and_input()
	_check_focus_and_stick_latch()
	_check_status_protection_and_markers()
	_check_description_and_instruction_layout()
	if failures.is_empty():
		print("PAUSE_UI_V1_TESTS: PASS")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("PAUSE_UI_V1_TESTS: FAIL (%d)" % failures.size())
	get_tree().quit(1)

func _check_layout() -> void:
	var layout: Dictionary = PauseUiSystemScript.layout()
	var panel: Rect2 = layout["panel"] as Rect2
	_check(panel == Rect2(188.0, 68.0, 1224.0, 744.0), "pause panel uses the fixed outer rect")
	var expected_regions := {
		"status": Rect2(224.0, 172.0, 1152.0, 116.0),
		"weapon": Rect2(224.0, 304.0, 560.0, 234.0),
		"accessory": Rect2(816.0, 304.0, 560.0, 234.0),
		"instruction": Rect2(224.0, 554.0, 356.0, 136.0),
		"rule": Rect2(604.0, 554.0, 356.0, 136.0),
		"controls": Rect2(984.0, 554.0, 392.0, 136.0),
		"actions": Rect2(224.0, 710.0, 1152.0, 84.0)
	}
	for key in expected_regions:
		_check((layout[key] as Rect2) == expected_regions[key], "pause %s uses the fixed rect" % key)
	var regions: Array[Rect2] = []
	for key in ["status", "weapon", "accessory", "instruction", "rule", "controls", "actions"]:
		var rect: Rect2 = layout[key] as Rect2
		_check(panel.encloses(rect), "pause %s stays inside panel" % key)
		for previous in regions:
			_check(not rect.intersects(previous), "pause %s does not overlap another region" % key)
		regions.append(rect)
	var cells: Array[Rect2] = PauseUiSystemScript.status_cell_rects(layout["status"] as Rect2)
	_check(cells.size() == 10, "pause status has ten cells")
	for index in range(cells.size()):
		_check((layout["status"] as Rect2).encloses(cells[index]), "status cell %d stays inside status" % index)
		for other_index in range(index):
			_check(not cells[index].intersects(cells[other_index]), "status cells do not overlap")
	_check(cells[0].position.y == cells[1].position.y and cells[0].position.x < cells[1].position.x, "status first row is horizontal")
	_check(cells[0].position.y < cells[5].position.y, "status cells have two rows")

func _check_status_rows() -> void:
	var expected_labels := ["配信者", "配信枠", "難易度", "残り時間", "視聴者数", "ボルテージ", "バズ度", "撃破スコア倍率", "ギフト期待度", "♡待機"]
	var cases := [
		{"difficultyId": "normal", "streamFrameId": "zatsudan", "name": "雑談枠", "accent": Color("#E954A5"), "tint": Color("#FFF2FA")},
		{"difficultyId": "hard", "streamFrameId": "singing", "name": "歌枠", "accent": Color("#D94B62"), "tint": Color("#FFF0F2")},
		{"difficultyId": "expert", "streamFrameId": "collab", "name": "コラボ枠", "accent": Color("#7A56C8"), "tint": Color("#F4EFFF")}
	]
	for item in cases:
		var rows: Array[Dictionary] = PauseUiSystemScript.status_rows({
			"characterName": "赤羽ばんり",
			"relayMode": false,
			"streamFrame": {"displayName": item["name"]},
			"streamFrameId": item["streamFrameId"],
			"difficultyId": item["difficultyId"],
			"runLength": 120.0,
			"elapsed": 12.0,
			"score": 123,
			"multiplier": 1.5,
			"burnCombo": 40,
			"giftHype": 80,
			"heartPending": true
		})
		_check(rows.size() == 10, "status rows contain ten entries")
		for index in range(expected_labels.size()):
			_check(String(rows[index]["label"]) == expected_labels[index], "status row order %d is fixed" % index)
		_check(String(rows[1]["value"]) == String(item["name"]), "status frame name is localized")
		_check(String(rows[2]["value"]) == String(item["difficultyId"]).to_upper(), "status difficulty label is normalized")
		var palette: Dictionary = rows[2]["palette"] as Dictionary
		_check(palette["accent"] == item["accent"] and palette["tint"] == item["tint"], "status difficulty uses the shared palette")
	_check(String((PauseUiSystemScript.status_rows({"runLength": 120.0, "elapsed": 140.0})[3] as Dictionary)["value"]) == "00:00", "remaining time clamps at zero")
	_check(String((PauseUiSystemScript.status_rows({"runLength": INF, "elapsed": 140.0})[3] as Dictionary)["value"]) == "制限なし", "infinite time stays unlimited")
	var relay_rows: Array[Dictionary] = PauseUiSystemScript.status_rows({"relayMode": true, "streamFrameId": "final_boss", "streamFrame": {"displayName": "ゲーム実況枠"}})
	_check(String(relay_rows[1]["value"]) == "配信リレー", "status relay name ignores the current segment")

func _check_stream_rules() -> void:
	var relay_body := "5つの配信枠を連続で進む特別モードです。\n区間の合間に休憩が入り、回復かギフトを選べます。\n最後に時間制限なしの最終ボスへ挑みます。"
	for frame_id in ["zatsudan", "gameplay", "singing", "drawing", "collab", "final_boss", "任意の区間"]:
		var relay_view: Dictionary = PauseUiSystemScript.stream_rule_view({"relayMode": true, "streamFrameId": frame_id, "streamFrame": {"displayName": "ゲーム実況枠"}})
		_check(String(relay_view["frameName"]) == "配信リレー", "relay rule name stays fixed")
		_check(String(relay_view["body"]) == relay_body, "relay rule body stays fixed")
	var names := {"zatsudan": "雑談枠", "gameplay": "ゲーム実況枠", "singing": "歌枠", "drawing": "お絵かき枠", "collab": "コラボ枠"}
	for frame_id in names:
		var normal_view: Dictionary = PauseUiSystemScript.stream_rule_view({"relayMode": false, "streamFrameId": frame_id, "streamFrame": {}})
		_check(String(normal_view["frameName"]) == String(names[frame_id]), "normal rule name is localized: %s" % frame_id)
	_check(String(PauseUiSystemScript.stream_rule_view({"relayMode": false, "streamFrameId": "", "streamFrame": {"displayName": "雑談枠"}})["frameName"]) == "雑談枠", "empty frame id keeps display fallback")

func _check_instruction_styles() -> void:
	var inactive: Dictionary = PauseUiSystemScript.instruction_view({"active": false})
	var active: Dictionary = PauseUiSystemScript.instruction_view({"active": true, "commentName": "指示コメ", "effectTimer": 4.0, "body": "効果：敵高速化"})
	_check(String(inactive["badge"]) == "なし" and String(inactive["body"]) == "現在、発動中の指示コメはありません。", "inactive instruction view is explicit")
	_check(String(active["badge"]) == "発動中" and String(active["body"]) == "効果：敵高速化", "active instruction view shows effect")
	_check(inactive["fill"] != active["fill"] and inactive["border"] != active["border"] and inactive["badgeFill"] != active["badgeFill"], "instruction styles distinguish active and inactive")

func _check_equipment_geometry() -> void:
	var layout: Dictionary = PauseUiSystemScript.layout()
	for key in ["weapon", "accessory"]:
		var equipment: Dictionary = PauseUiSystemScript.equipment_layout(layout[key] as Rect2)
		var panel: Rect2 = layout[key] as Rect2
		var slots: Array[Rect2] = equipment["slots"] as Array[Rect2]
		_check(slots.size() == 5, "%s has five equipment slots" % key)
		for index in range(slots.size()):
			_check(panel.encloses(slots[index]), "%s slot %d stays inside panel" % [key, index])
			for other_index in range(index):
				_check(not slots[index].intersects(slots[other_index]), "%s slots do not overlap" % key)
		var description: Rect2 = equipment["description"] as Rect2
		_check(panel.encloses(description), "%s description stays inside panel" % key)
		for slot in slots:
			_check(not description.intersects(slot), "%s description does not overlap slots" % key)
	_check(PauseUiSystemScript.equipment_description_source(0, true) == "weapon", "weapon explanation source is isolated")
	_check(PauseUiSystemScript.equipment_description_source(1, true) == "accessory", "accessory explanation source is isolated")
	_check(PauseUiSystemScript.equipment_description_source(0, false) == "default", "unfocused equipment uses default explanation")
	_check(String(PauseUiSystemScript.equipment_description({}, true, true)["title"]) == "空き武器スロット", "empty weapon slot uses the weapon explanation")
	_check(String(PauseUiSystemScript.equipment_description({}, false, true)["title"]) == "空きアクセサリスロット", "empty accessory slot uses the accessory explanation")
	_check(String(PauseUiSystemScript.equipment_description({}, true, false)["body"]) == "武器・アクセサリにカーソルを合わせると説明が表示されます", "unfocused equipment uses the shared explanation")

func _check_actions_and_input() -> void:
	var ids: Array[String] = PauseUiSystemScript.action_button_ids()
	_check(ids == ["continue", "retry", "options", "title"], "pause action order is fixed")
	var styles: Dictionary = {}
	for index in range(ids.size()):
		var selected_id := PauseUiSystemScript.selected_action_id(index)
		_check(ids.has(selected_id), "selected action is one of the four actions")
		_check(PauseUiSystemScript.selected_action_id(index) == selected_id, "exactly one selected action is stable")
		styles[selected_id] = PauseUiSystemScript.action_button_style(selected_id)
	_check((styles["continue"] as Dictionary)["fill"] == Color("#ff5aa5"), "continue has intrinsic pink style")
	_check((styles["retry"] as Dictionary)["text"] == Color("#7a56c8"), "retry has intrinsic purple style")
	_check((styles["options"] as Dictionary)["fill"] == Color("#f3eff7"), "options has intrinsic neutral style")
	_check((styles["title"] as Dictionary)["text"] == Color("#2587b8"), "title has intrinsic blue style")
	_check(PauseUiSystemScript.pause_input_action(KEY_1) == "pause_continue", "keyboard 1 maps to continue")
	_check(PauseUiSystemScript.pause_input_action(KEY_2) == "pause_retry", "keyboard 2 maps to retry")
	_check(PauseUiSystemScript.pause_input_action(KEY_3) == "pause_options", "keyboard 3 maps to options")
	_check(PauseUiSystemScript.pause_input_action(KEY_4) == "pause_title", "keyboard 4 maps to title")
	_check(PauseUiSystemScript.pause_input_action(-1, JOY_BUTTON_DPAD_UP) == "pause_up", "gamepad d-pad maps to up")
	_check(PauseUiSystemScript.pause_input_action(-1, JOY_BUTTON_A) == "pause_select", "gamepad A maps to select")
	_check(PauseUiSystemScript.pause_input_action(-1, JOY_BUTTON_B) == "pause_cancel", "gamepad B maps to cancel")
	_check(PauseUiSystemScript.pause_input_action(-1, -1, "ui_left") == "pause_left", "ui_left maps to pause navigation")
	_check(PauseUiSystemScript.pause_input_action(-1, -1, "ui_accept") == "pause_select", "ui_accept maps to pause select")
	_check(PauseUiSystemScript.pause_input_action(-1, -1, "ui_cancel") == "pause_cancel", "ui_cancel maps to pause cancel")

func _check_focus_and_stick_latch() -> void:
	var ids: Array[String] = PauseUiSystemScript.action_button_ids()
	var intrinsic_fills := {
		"continue": Color("#ff5aa5"),
		"retry": Color("#f8f2ff"),
		"options": Color("#f3eff7"),
		"title": Color("#e8f7ff")
	}
	var pulse_a: Dictionary = PauseUiSystemScript.action_focus_visual("continue", true, 0.25)
	var pulse_b: Dictionary = PauseUiSystemScript.action_focus_visual("continue", true, 0.75)
	_check(float(pulse_a["grow"]) != float(pulse_b["grow"]) and float(pulse_a["glowAlpha"]) != float(pulse_b["glowAlpha"]), "selected action pulse changes only with time phase")
	for index in range(ids.size()):
		var selected_id := PauseUiSystemScript.selected_action_id(index)
		var selected_count := 0
		for button_id in ids:
			var selected := button_id == selected_id
			var visual: Dictionary = PauseUiSystemScript.action_focus_visual(button_id, selected, 0.25)
			if bool(visual["selected"]):
				selected_count += 1
				_check(float(visual["glowAlpha"]) > 0.0 and float(visual["grow"]) > 0.0, "selected action has a weak glow and pulse")
			else:
				_check(float(visual["glowAlpha"]) == 0.0 and float(visual["grow"]) == 0.0, "unselected action has no glow")
			_check((PauseUiSystemScript.action_button_style(button_id)["fill"] as Color) == intrinsic_fills[button_id], "selected action keeps its intrinsic fill")
		_check(selected_count == 1, "selected action representation is exactly one")
	var engaged: Dictionary = PauseUiSystemScript.stick_latch_transition(0, 0.70)
	_check(int(engaged["latch"]) == 1 and int(engaged["direction"]) == 1 and bool(engaged["moved"]), "left stick engages once")
	var held: Dictionary = PauseUiSystemScript.stick_latch_transition(int(engaged["latch"]), 0.80)
	_check(int(held["latch"]) == 1 and not bool(held["moved"]), "left stick hold does not repeat")
	var released: Dictionary = PauseUiSystemScript.stick_latch_transition(int(held["latch"]), 0.0)
	_check(int(released["latch"]) == 0 and not bool(released["moved"]), "left stick releases below hysteresis threshold")
	var reengaged: Dictionary = PauseUiSystemScript.stick_latch_transition(int(released["latch"]), 0.70)
	_check(int(reengaged["latch"]) == 1 and bool(reengaged["moved"]), "left stick can re-engage after release")
	var opposite: Dictionary = PauseUiSystemScript.stick_latch_transition(int(reengaged["latch"]), -0.80)
	_check(int(opposite["latch"]) == -1 and int(opposite["direction"]) == -1 and bool(opposite["moved"]), "left stick opposite direction moves once")
	var equipment_top := PauseUiSystemScript.navigation_snapshot(0, "equipment", 0, 0, 0, 1)
	_check(not PauseUiSystemScript.navigation_changed(equipment_top, equipment_top), "navigation SE stays silent when state does not change")
	var action_focus := PauseUiSystemScript.navigation_snapshot(0, "actions", 0, 0, 0, 1)
	_check(PauseUiSystemScript.navigation_changed(equipment_top, action_focus), "navigation SE follows a real focus-area change")
	var confirm_changed := PauseUiSystemScript.navigation_snapshot(0, "actions", 0, 0, 0, 0)
	_check(PauseUiSystemScript.navigation_changed(action_focus, confirm_changed), "navigation snapshot includes confirmation cursor changes")

func _check_status_protection_and_markers() -> void:
	var layout: Dictionary = PauseUiSystemScript.layout()
	var status: Rect2 = layout["status"] as Rect2
	var cells: Array[Rect2] = PauseUiSystemScript.status_cell_rects(status)
	for cell in cells:
		var content: Dictionary = PauseUiSystemScript.status_cell_content_rects(cell, 2)
		var badge: Rect2 = content["badge"] as Rect2
		_check(status.encloses(badge), "protection badge stays inside status")
		_check(not badge.intersects(content["label"] as Rect2), "protection badge does not overlap the cell label")
		_check(not badge.intersects(content["value"] as Rect2), "protection badge does not overlap the cell value")
	var action_rects: Array[Rect2] = PauseUiSystemScript.action_button_rects(layout["actions"] as Rect2)
	for button_rect in action_rects:
		_check((layout["actions"] as Rect2).encloses(button_rect), "pause action button stays inside actions")
		var markers: Array[Rect2] = PauseUiSystemScript.action_focus_marker_rects(button_rect)
		for marker in markers:
			_check((layout["actions"] as Rect2).encloses(marker), "pause focus marker stays in outer action margin")
	for index in range(action_rects.size()):
		for other_index in range(index):
			_check(not action_rects[index].intersects(action_rects[other_index]), "pause action buttons do not overlap")

func _check_description_and_instruction_layout() -> void:
	var equipment: Dictionary = PauseUiSystemScript.equipment_layout(PauseUiSystemScript.layout()["weapon"] as Rect2)
	var description_rect: Rect2 = equipment["description"] as Rect2
	_check(description_rect.size == Vector2(524.0, 106.0), "equipment description has room for body and evolution guide")
	var description := {
		"title": "長い武器名 Lv5",
		"body": "通常の効果説明です。",
		"guide": "進化条件\n武器名 Lv5 ＋ ギフト名 Lv1\n→ 強化された武器\n※進化済みの武器も、元武器の進化条件を満たします"
	}
	var lines: Array[Dictionary] = PauseUiSystemScript.equipment_description_line_layout(description_rect, description)
	_check(lines.size() == 4, "equipment description keeps body plus the three forward guide lines")
	var expected_lines := ["通常の効果説明です。", "進化条件", "武器名 Lv5 ＋ ギフト名 Lv1", "→ 強化された武器"]
	for index in range(lines.size()):
		var line_rect: Rect2 = lines[index]["rect"] as Rect2
		_check(description_rect.encloses(line_rect), "equipment description baseline stays inside description")
		if index > 0:
			_check(not line_rect.intersects(lines[index - 1]["rect"] as Rect2), "equipment description lines do not overlap")
		var line_text := String(lines[index]["text"])
		_check(line_text == expected_lines[index], "equipment guide line %d keeps its source order" % index)
		var measured_width := GameFontSystemScript.regular_font().get_string_size(line_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, int(lines[index]["fontSize"])).x
		_check(measured_width <= description_rect.size.x - 32.0, "equipment description line fits measured width")
	var undiscovered_lines: Array[Dictionary] = PauseUiSystemScript.equipment_description_line_layout(description_rect, {
		"title": "武器 Lv1",
		"body": "通常の効果説明です。",
		"guide": "進化：？？？"
	})
	_check(undiscovered_lines.size() >= 2 and String(undiscovered_lines[0]["text"]) == "通常の効果説明です。" and String(undiscovered_lines[1]["text"]) == "進化：？？？", "undiscovered guide keeps the effect body first")
	var reverse_lines: Array[Dictionary] = PauseUiSystemScript.equipment_description_line_layout(description_rect, {
		"title": "ギフト Lv1",
		"body": "通常の効果説明です。",
		"guide": "進化素材\n元武器 → 進化武器"
	})
	_check(reverse_lines.size() >= 3, "reverse material guide keeps its rows")
	_check(String(reverse_lines[0]["text"]) == "通常の効果説明です。", "reverse guide keeps the effect body first")
	_check(String(reverse_lines[1]["text"]) == "進化素材" and String(reverse_lines[2]["text"]) == "元武器 → 進化武器", "reverse guide keeps source order")
	var instruction_lines: Array[String] = PauseUiSystemScript.instruction_body_lines("現在の指示コメ　残り09秒\n内訳：敵巨大化 / 操作混乱 / 床すべり / ダッシュ制限\n注意書きの長い効果説明", 300.0, 13, 4)
	_check(instruction_lines.size() <= 4, "multiple instruction effects stay within four lines")
	for line in instruction_lines:
		_check(GameFontSystemScript.regular_font().get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13).x <= 300.0, "instruction line fits measured width")

func _check(condition: bool, label: String) -> void:
	if not condition:
		failures.append(label)
