extends Node

const GameScene := preload("res://scenes/main.tscn")
const MissionSystemScript := preload("res://scripts/systems/stream_mission_system.gd")
const ResultSystemScript := preload("res://scripts/systems/result_system.gd")

var test_root := ""
var failures: Array[String] = []
var checks := 0

func _ready() -> void:
	test_root = OS.get_environment("COMMENTDIE_STREAM_MISSION_UI_TEST_ROOT").replace("\\", "/").trim_suffix("/")
	if test_root == "":
		test_root = OS.get_user_data_dir().replace("\\", "/")
	if not test_root.is_absolute_path():
		test_root = ProjectSettings.globalize_path(test_root).replace("\\", "/")
	DirAccess.make_dir_recursive_absolute(test_root)
	await _test_stream_mission_renderers()
	var report := {"checks": checks, "failures": failures}
	var report_file := FileAccess.open(test_root.path_join("stream-mission-ui-results.json"), FileAccess.WRITE)
	if report_file != null:
		report_file.store_string(JSON.stringify(report, "\t"))
		report_file.close()
	for failure in failures:
		push_error(failure)
	print("STREAM_MISSION_UI_V1_TESTS: %s (%d checks, %d failures)" % ["PASS" if failures.is_empty() else "FAIL", checks, failures.size()])
	get_tree().quit(0 if failures.is_empty() else 1)

func _test_stream_mission_renderers() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1600, 900)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	var game = GameScene.instantiate()
	viewport.add_child(game)
	await _frames(3)
	game.stream_mission_system = MissionSystemScript.load_default()
	game.state = "stream_frame_select"
	game.run_difficulty_id = "hard"
	game.selected_stream_frame_index = 0
	game.stream_frame_select_focus_area = game.PRE_RUN_SELECT_FOCUS_DETAIL
	game.stream_frame_select_detail_tab = 1
	game.front_screen_transition_active = false
	game.front_screen_transition_frame.clear()
	if game.power_up_shop_manager != null:
		game.power_up_shop_manager.profile["completedStreamMissions"] = ["TALK-1"]
		game.power_up_shop_manager.profile["completedStageMissionSets"] = []
	_check(String(game.state) == "stream_frame_select", "stream select renderer is in the intended state")
	_check(game._stream_frame_select_layout()["detailPanel"].size == Vector2(542, 692), "stream select detail panel keeps the 1600 layout")
	_check(game._stream_mission_stage_rows("zatsudan").size() == 3, "stream mission detail exposes three stage missions")
	_check(game._stream_frame_select_detail_tab_rect(1).position.y == 514, "mission tab remains in the detail panel")
	game.queue_redraw()
	await _frames(3)
	await _capture_viewport(viewport, test_root.path_join("stream-frame-select-missions-1600x900.png"))
	# The game uses a fixed 1600x900 canvas with project stretch.  Scale the
	# same scene to the 1280x720 runtime size for a second visual boundary check.
	viewport.size = Vector2i(1280, 720)
	game.scale = Vector2(0.8, 0.8)
	game.queue_redraw()
	await _frames(3)
	await _capture_viewport(viewport, test_root.path_join("stream-frame-select-missions-1280x720.png"))
	viewport.size = Vector2i(1600, 900)
	game.scale = Vector2.ONE
	game.queue_redraw()
	await _frames(2)

	var reward_view := ResultSystemScript.build_point_reward_view(
		{
			"participationPp": 100,
			"progressPp": 30,
			"clearPp": 50,
			"bossDefeatPp": 40,
			"firstStageClearPp": 80,
			"firstBossDefeatPp": 60,
			"fieldGiftPp": 20,
			"fallbackGiftPp": 10,
			"difficultyAdjustment": 12,
			"evaluationBonusPp": 18
		},
		"granted",
		1000,
		420,
		1420,
		false,
		{"missionPp": 100, "setPp": 100}
	)
	_check((reward_view.get("rewardRows", []) as Array).size() == 11, "result reward data keeps one mission subtotal after existing rows")
	var reward_grid: Dictionary = game._completed_reward_grid_layout(Rect2(Vector2.ZERO, Vector2(472, 116)), 11)
	_check(int(reward_grid.get("visibleRows", 0)) == 11 and int(reward_grid.get("columns", 0)) == 3 and int(reward_grid.get("rowsPerColumn", 0)) == 4, "eleven reward rows fit in three compact columns")
	var mission_row_count := 0
	for row_value in reward_view.get("rewardRows", []) as Array:
		if row_value is Dictionary and String((row_value as Dictionary).get("id", "")) == "stream_missions":
			mission_row_count += 1
	_check(mission_row_count == 1, "result reward data has exactly one 配信目標 row")
	game.state = "result"
	game.relay_mode = false
	game.last_result_data = {
		"endType": "completed",
		"characterId": "ban_chan",
		"characterName": "ばんり",
		"streamFrameId": "zatsudan",
		"streamFrameName": "雑談枠",
		"difficultyId": "hard",
		"viewerCount": 1234,
		"survivalTime": 180.0,
		"maxVoltage": 1.4,
		"maxBurnCombo": 12,
		"giftCount": 2,
		"evaluationRank": "A",
		"pointRewardView": reward_view,
		"streamMissionResult": {"missionPp": 100, "setPp": 100}
	}
	game.result_drop_timer = 0.0
	game.result_reveal_active = false
	game.result_reveal_complete = true
	game.queue_redraw()
	await _frames(3)
	await _capture_viewport(viewport, test_root.path_join("stream-result-mission-breakdown-1600x900.png"))
	viewport.queue_free()
	await get_tree().process_frame

func _check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures.append(label)

func _frames(count: int) -> void:
	for _index in range(count):
		await get_tree().process_frame

func _capture_viewport(viewport: SubViewport, path: String) -> void:
	if DisplayServer.get_name().to_lower() == "headless":
		return
	await _frames(2)
	var texture := viewport.get_texture()
	_check(texture != null, "viewport texture exists for %s" % path.get_file())
	if texture == null:
		return
	var image := texture.get_image()
	_check(image != null and image.save_png(path) == OK, "saved %s" % path.get_file())
