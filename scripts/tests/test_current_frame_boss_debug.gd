extends Node

const DebugSystemScript := preload("res://scripts/systems/debug_system.gd")

const FRAME_CASES: Array[Dictionary] = [
	{"frameId": "zatsudan", "bossId": "boss_kuso_maro_king"},
	{"frameId": "gameplay", "bossId": "bugged_final_boss"},
	{"frameId": "singing", "bossId": "pitch_police_chief"},
	{"frameId": "drawing", "bossId": "red_pen_review_chief"},
	{"frameId": "collab", "bossId": "collab_crusher"}
]

func _ready() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var failures: Array[String] = []
	var game := (load("res://scenes/main.tscn") as PackedScene).instantiate()
	add_child(game)
	await get_tree().process_frame
	_check(DebugSystemScript.CURRENT_FRAME_BOSS_KEY == KEY_F7, "current-frame boss command is not assigned to F7", failures)
	_check(DebugSystemScript.CURRENT_FRAME_BOSS_KEY_LABEL == "F7", "current-frame boss command label does not match F7", failures)
	_check(DebugSystemScript.should_spawn_current_frame_boss("spawn_current_frame_boss"), "debug action was not registered", failures)
	for case_data in FRAME_CASES:
		game.set("relay_mode", false)
		game.call("_restart")
		game.set("state", "playing")
		game.set("previous_state", "playing")
		game.set("current_stream_frame_id", String(case_data["frameId"]))
		game.call("_apply_debug_action", "spawn_current_frame_boss")
		var expected_boss_id := String(case_data["bossId"])
		_check(String(game.get("state")) == "boss_cutin", "%s did not enter its boss cut-in" % case_data["frameId"], failures)
		var runtime: Dictionary = game.get("boss_cutin_runtime") as Dictionary
		var data: Dictionary = runtime.get("data", {}) as Dictionary
		_check(String(data.get("bossId", "")) == expected_boss_id, "%s selected the wrong boss" % case_data["frameId"], failures)
		_check(bool(runtime.get("bossPrepared", false)), "%s did not reserve one boss" % case_data["frameId"], failures)
		game.call("_update_boss_cutin", float(runtime.get("duration", 2.2)) + 0.05)
		_check(String(game.get("state")) == "playing" and bool(game.get("boss_active")), "%s boss did not enter battle" % case_data["frameId"], failures)
		_check(_boss_count(game.get("enemies") as Array, expected_boss_id) == 1, "%s did not create exactly one matching boss" % case_data["frameId"], failures)
		var enemy_count_before := (game.get("enemies") as Array).size()
		game.call("_apply_debug_action", "spawn_current_frame_boss")
		_check((game.get("enemies") as Array).size() == enemy_count_before, "%s allowed duplicate boss spawning" % case_data["frameId"], failures)
	game.set("relay_mode", true)
	game.call("_restart")
	game.set("state", "playing")
	game.set("previous_state", "playing")
	game.set("current_stream_frame_id", "gameplay")
	game.call("_apply_debug_action", "spawn_current_frame_boss")
	var relay_runtime: Dictionary = game.get("boss_cutin_runtime") as Dictionary
	var relay_data: Dictionary = relay_runtime.get("data", {}) as Dictionary
	_check(String(game.get("state")) == "boss_cutin" and String(relay_data.get("bossId", "")) == "bugged_final_boss", "relay gameplay did not use its regular frame boss", failures)
	game.call("_update_boss_cutin", float(relay_runtime.get("duration", 2.2)) + 0.05)
	_check(_boss_count(game.get("enemies") as Array, "bugged_final_boss") == 1, "relay frame command did not create exactly one boss", failures)
	game.queue_free()
	await get_tree().process_frame
	if failures.is_empty():
		print("Current-frame boss debug command tests passed")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	get_tree().quit(1)

func _boss_count(enemies: Array, boss_id: String) -> int:
	var count := 0
	for item in enemies:
		var enemy: Dictionary = item as Dictionary
		if bool(enemy.get("isBoss", false)) and String(enemy.get("bossId", "")) == boss_id:
			count += 1
	return count

func _check(condition: bool, message: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(message)
