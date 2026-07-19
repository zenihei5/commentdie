extends Node

var render_viewport: SubViewport
var capture_game: Node

func _ready() -> void:
	call_deferred("_capture_sequence")

func _capture_sequence() -> void:
	render_viewport = SubViewport.new()
	render_viewport.size = Vector2i(1600, 900)
	render_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(render_viewport)
	var game := (load("res://scenes/main.tscn") as PackedScene).instantiate()
	capture_game = game
	render_viewport.add_child(game)
	await get_tree().process_frame
	# Capture timestamps are driven explicitly below.  Keeping the scene's normal
	# process loop enabled would advance the cut-in again while images are saved.
	game.set_process(false)
	await _capture_normal_dual(game, "boss_kuso_maro_king", 0.42, "supplied_kusomaro_intro")
	await _capture_normal_dual(game, "boss_kuso_maro_king", 0.87, "supplied_kusomaro_crown")
	await _capture_normal_dual(game, "boss_kuso_maro_king", 1.10, "supplied_kusomaro_name")
	await _capture_normal_dual(game, "boss_kuso_maro_king", 1.88, "supplied_kusomaro_fade")
	await _capture_normal_dual(game, "red_pen_review_chief", 0.61, "supplied_redpen_intro")
	await _capture_normal_dual(game, "collab_crusher", 0.66, "supplied_collab_intro")
	await _capture_pitch_police(game)
	await _capture_bugged_final_boss(game)
	game.call("_restart")
	game.set("state", "playing")
	game.call("_apply_debug_action", "relay_boss_direct")
	game.call("_update_boss_cutin", 0.82)
	await _save_frame("supplied_last_offline_intro_1600x900", Vector2i(1600, 900))
	await _save_frame("supplied_last_offline_intro_1280x720", Vector2i(1280, 720))
	game.call("_update_boss_cutin", 1.30)
	await _save_frame("supplied_last_offline_name_1600x900", Vector2i(1600, 900))
	await _save_frame("supplied_last_offline_name_1280x720", Vector2i(1280, 720))
	game.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)

func _capture_normal_dual(game: Node, boss_id: String, elapsed: float, label: String) -> void:
	game.call("_restart")
	game.set("state", "playing")
	game.set("previous_state", "playing")
	game.call("_start_boss_cutin", boss_id, "debug_return")
	game.call("_update_boss_cutin", elapsed)
	await _save_frame(label + "_1600x900", Vector2i(1600, 900))
	await _save_frame(label + "_1280x720", Vector2i(1280, 720))
	game.call("_cancel_boss_cutin", false)

func _capture_bugged_final_boss(game: Node) -> void:
	game.call("_restart")
	game.set("state", "playing")
	game.set("previous_state", "playing")
	game.set("boss_pending_id", "bugged_final_boss")
	game.set("boss_requested", true)
	game.set("boss_cutin_started", true)
	game.call("_start_boss_cutin", "bugged_final_boss", "spawn_normal_boss")
	game.call("_update_boss_cutin", 0.54)
	await _save_frame("supplied_bugged_intro_1600x900", Vector2i(1600, 900))
	await _save_frame("supplied_bugged_intro_1280x720", Vector2i(1280, 720))
	game.call("_update_boss_cutin", 0.58)
	await _save_frame("supplied_bugged_name_1600x900", Vector2i(1600, 900))
	await _save_frame("supplied_bugged_name_1280x720", Vector2i(1280, 720))
	game.call("_update_boss_cutin", 0.66)
	await _save_frame("supplied_bugged_handoff_1600x900", Vector2i(1600, 900))
	await _save_frame("supplied_bugged_handoff_1280x720", Vector2i(1280, 720))
	game.call("_cancel_boss_cutin", false)

func _capture_pitch_police(game: Node) -> void:
	game.call("_restart")
	game.set("state", "playing")
	game.set("previous_state", "playing")
	game.set("boss_pending_id", "pitch_police_chief")
	game.set("boss_requested", true)
	game.set("boss_cutin_started", true)
	game.call("_start_boss_cutin", "pitch_police_chief", "spawn_normal_boss")
	game.call("_update_boss_cutin", 0.55)
	await _save_frame("supplied_pitch_police_intro_1600x900", Vector2i(1600, 900))
	await _save_frame("supplied_pitch_police_intro_1280x720", Vector2i(1280, 720))
	game.call("_update_boss_cutin", 0.75)
	await _save_frame("supplied_pitch_police_name_1600x900", Vector2i(1600, 900))
	await _save_frame("supplied_pitch_police_name_1280x720", Vector2i(1280, 720))
	game.call("_update_boss_cutin", 0.73)
	await _save_frame("supplied_pitch_police_field_1600x900", Vector2i(1600, 900))
	await _save_frame("supplied_pitch_police_field_1280x720", Vector2i(1280, 720))
	game.call("_cancel_boss_cutin", false)

func _save_frame(label: String, output_size: Vector2i) -> void:
	if is_instance_valid(capture_game):
		capture_game.call("_update_ui")
		capture_game.queue_redraw()
	await get_tree().process_frame
	await get_tree().process_frame
	var image := render_viewport.get_texture().get_image()
	if image.get_size() != output_size:
		image.resize(output_size.x, output_size.y, Image.INTERPOLATE_LANCZOS)
	var path := "res://docs/images/boss_cutin_v3_%s.png" % label
	var error := image.save_png(path)
	if error != OK:
		push_error("Failed to save screenshot: %s (%s)" % [path, error_string(error)])
	else:
		print("Saved screenshot: %s" % path)
