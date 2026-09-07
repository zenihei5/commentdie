extends Node

const GameScript := preload("res://scripts/game.gd")

func _ready() -> void:
	var source := FileAccess.get_file_as_string("res://scripts/game.gd")
	var start := source.find("func _draw_collab_division_noise_overlay(")
	var finish := source.find("\nfunc ", start + 1)
	var failures: Array[String] = []
	if start < 0 or finish <= start:
		failures.append("division-noise overlay function missing")
	else:
		var block := source.substr(start, finish - start)
		if block.contains("edge_radius") or block.contains("cyan_strength") or block.contains("pink_strength"):
			failures.append("pink/cyan decorative rim arcs must remain removed")
		if block.count("draw_arc(") != 1 or not block.contains("draw_arc(pos, broken_radius"):
			failures.append("only the existing dark fracture arc should remain")
		for preserved in ["_draw_collab_division_noise_fracture(", "draw_rect(", "draw_line(", "crowd_alpha"]:
			if not block.contains(preserved):
				failures.append("unrelated overlay detail removed: " + preserved)
	if failures.is_empty():
		print("DIVISION_NOISE_OVERLAY_TESTS: PASS")
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error(failure)
		get_tree().quit(1)
