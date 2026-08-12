extends Node

const StreamFrameSystemScript := preload("res://scripts/systems/stream_frame_system.gd")

var failures: Array[String] = []

func _ready() -> void:
	_check_target(2, 1, 0, "right from card 3 enters card 1")
	_check_target(5, 1, 3, "right from card 6 enters card 4")
	_check_target(0, -1, 2, "left from card 1 enters card 3")
	_check_target(3, -1, 5, "left from card 4 enters card 6")
	_check_target(1, 1, -1, "right inside a row stays in the current difficulty")
	_check_target(4, -1, -1, "left inside a row stays in the current difficulty")
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
