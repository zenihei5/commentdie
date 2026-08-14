extends Node

const StreamFrameSystemScript := preload("res://scripts/systems/stream_frame_system.gd")
const CommonLightUiStyle := preload("res://scripts/ui/common_light_ui_style.gd")
const HudTextSystemScript := preload("res://scripts/systems/hud_text_system.gd")

var failures: Array[String] = []

func _ready() -> void:
	_check_target(2, 1, 0, "right from card 3 enters card 1")
	_check_target(5, 1, 3, "right from card 6 enters card 4")
	_check_target(0, -1, 2, "left from card 1 enters card 3")
	_check_target(3, -1, 5, "left from card 4 enters card 6")
	_check_target(1, 1, -1, "right inside a row stays in the current difficulty")
	_check_target(4, -1, -1, "left inside a row stays in the current difficulty")
	_check_scroll_offsets()
	_check_difficulty_palette()
	_check_legacy_relay_views()
	_check_stream_frame_card_view()
	if failures.is_empty():
		print("STREAM_FRAME_DIFFICULTY_NAVIGATION_TESTS: PASS")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("STREAM_FRAME_DIFFICULTY_NAVIGATION_TESTS: FAIL (%d)" % failures.size())
	get_tree().quit(1)

func _check_target(current_index: int, direction: int, expected: int, label: String) -> void:
	var actual := StreamFrameSystemScript.horizontal_difficulty_edge_target_index(current_index, 6, 6, direction)
	if actual != expected:
		failures.append("%s: got %d expected %d" % [label, actual, expected])

func _check_scroll_offsets() -> void:
	var forward_start := StreamFrameSystemScript.difficulty_scroll_offsets(0.0, 1, 100.0)
	var forward_end := StreamFrameSystemScript.difficulty_scroll_offsets(1.0, 1, 100.0)
	var backward_start := StreamFrameSystemScript.difficulty_scroll_offsets(0.0, -1, 100.0)
	var backward_end := StreamFrameSystemScript.difficulty_scroll_offsets(1.0, -1, 100.0)
	_check_vector(forward_start, Vector2(0.0, 100.0), "forward scroll starts with the next cards on the right")
	_check_vector(forward_end, Vector2(-100.0, 0.0), "forward scroll moves the old cards left")
	_check_vector(backward_start, Vector2(0.0, -100.0), "backward scroll starts with the previous cards on the left")
	_check_vector(backward_end, Vector2(100.0, 0.0), "backward scroll moves the old cards right")

func _check_difficulty_palette() -> void:
	var normal: Dictionary = CommonLightUiStyle.difficulty_palette("NORMAL")
	var hard: Dictionary = CommonLightUiStyle.difficulty_palette("hard")
	var expert: Dictionary = CommonLightUiStyle.difficulty_palette(" expert ")
	_check(normal.get("id", "") == "normal", "normal difficulty palette normalizes ids")
	_check(hard.get("id", "") == "hard", "hard difficulty palette id")
	_check(expert.get("id", "") == "expert", "expert difficulty palette id")
	_check(normal.get("accent", Color.BLACK) == Color("#E954A5") and normal.get("tint", Color.BLACK) == Color("#FFF2FA"), "normal difficulty palette colors")
	_check(hard.get("accent", Color.BLACK) == Color("#D94B62") and hard.get("tint", Color.BLACK) == Color("#FFF0F2"), "hard difficulty palette colors")
	_check(expert.get("accent", Color.BLACK) == Color("#7A56C8") and expert.get("tint", Color.BLACK) == Color("#F4EFFF"), "expert difficulty palette colors")

func _check_legacy_relay_views() -> void:
	var forbidden := ["Relay", "RELAY", "sections", "transitions", "final boss", "HARD relay", "Clear all five", "Standard stages cleared"]
	for unlocked in [false, true]:
		var view: Dictionary = StreamFrameSystemScript.selection_card_view(StreamFrameSystemScript.relay_selection_frame(unlocked))
		_check(String(view.get("description", "")) == "5つの配信枠を各120秒ずつ連続で進み、最後に時間制限なしの最終ボスへ挑みます。区間の合間には休憩が入り、回復やギフトを選択できます。", "legacy relay description")
		_check(String(view.get("displayName", "")) == "配信リレー" and String(view.get("plainName", "")) == "配信リレー", "legacy relay name")
		_check(String(view.get("difficultyText", "")) == "枠難度：★★★★★", "legacy relay difficulty text")
		_check(String(view.get("statusText", "")) == ("挑戦可能" if unlocked else "未解禁"), "legacy relay status")
		_check(String(view.get("statusId", "")) == ("relay_available" if unlocked else "locked"), "legacy relay status id")
		_check((view.get("features", []) as Array) == ["5区間", "各120秒"], "legacy relay features")
		_check((view.get("mainGimmicks", []) as Array) == ["5枠連続", "休憩", "最終ボス"], "legacy relay gimmicks")
		_check(String(view.get("unlockConditionText", "")) == ("" if unlocked else "通常5枠をすべてクリアすると解禁されます。"), "legacy relay unlock condition")
		_check(String(view.get("disabledReason", "")) == ("" if unlocked else "通常5枠をすべてクリアすると解禁されます。"), "legacy relay disabled reason")
		for key in ["displayName", "plainName", "description", "features", "mainGimmicks", "recommendText", "unlockConditionText", "disabledReason", "statusText"]:
			var visible := String(view.get(key, "")) if not (view.get(key, null) is Array) else " / ".join(view.get(key) as Array)
			for token in forbidden:
				_check(token not in visible, "legacy relay view contains forbidden token %s" % token)

func _check_stream_frame_card_view() -> void:
	var names := {
		"zatsudan": "雑談枠",
		"gameplay": "ゲーム実況枠",
		"singing": "歌枠",
		"drawing": "お絵かき枠",
		"collab": "コラボ枠"
	}
	for frame_id in names:
		var normal_view: Dictionary = HudTextSystemScript.stream_frame_card_view({"relayMode": false, "streamFrame": {"displayName": String(names[frame_id])}, "streamFrameId": frame_id, "difficultyId": "normal"})
		_check(String(normal_view.get("frameName", "")) == String(names[frame_id]), "normal HUD frame name: %s" % frame_id)
		var fallback_view: Dictionary = HudTextSystemScript.stream_frame_card_view({"relayMode": false, "streamFrame": {}, "streamFrameId": frame_id, "difficultyId": "normal"})
		_check(String(fallback_view.get("frameName", "")) == String(names[frame_id]), "normal HUD frame fallback: %s" % frame_id)
	for difficulty_id in ["normal", "hard", "expert"]:
		var difficulty_view: Dictionary = HudTextSystemScript.stream_frame_card_view({"relayMode": false, "streamFrame": {"displayName": "雑談枠"}, "streamFrameId": "zatsudan", "difficultyId": difficulty_id})
		_check(String(difficulty_view.get("difficultyId", "")) == difficulty_id and String(difficulty_view.get("difficultyLabel", "")) == difficulty_id.to_upper(), "HUD difficulty label: %s" % difficulty_id)
	for frame_id in ["zatsudan", "gameplay", "singing", "drawing", "collab", "final_boss", "last_offline", "unknown"]:
		var relay_view: Dictionary = HudTextSystemScript.stream_frame_card_view({"relayMode": true, "streamFrame": {"displayName": "EnglishFrameName"}, "streamFrameId": frame_id, "difficultyId": "expert"})
		_check(String(relay_view.get("frameName", "")) == "配信リレー", "relay HUD frame name: %s" % frame_id)
	var gameplay_fallback_view: Dictionary = HudTextSystemScript.stream_frame_card_view({"relayMode": false, "streamFrame": {}, "streamFrameId": "gameplay", "difficultyId": "hard"})
	_check(String(gameplay_fallback_view.get("frameName", "")) == "ゲーム実況枠", "HUD frame name fallback by id")
	var card_rect := Rect2(20, 18, 198, 80)
	var badge_rect: Rect2 = HudTextSystemScript.stream_frame_card_badge_rect(card_rect)
	var next_card_rect := Rect2(230, 18, 198, 80)
	_check(badge_rect.size == Vector2(58, 20), "HUD difficulty badge size")
	_check(badge_rect.position == Vector2(142, 28), "HUD difficulty badge anchor")
	_check(card_rect.encloses(badge_rect) and not badge_rect.intersects(next_card_rect), "HUD difficulty badge stays inside card")

func _check(condition: bool, label: String) -> void:
	if not condition:
		failures.append(label)

func _check_vector(actual: Vector2, expected: Vector2, label: String) -> void:
	if not actual.is_equal_approx(expected):
		failures.append("%s: got %s expected %s" % [label, actual, expected])
