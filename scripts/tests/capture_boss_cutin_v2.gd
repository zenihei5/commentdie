extends Node

var capture_size := Vector2i(1600, 900)
var render_viewport: SubViewport

func _ready() -> void:
	for argument in OS.get_cmdline_user_args():
		if String(argument).begins_with("--capture-size="):
			var parts := String(argument).trim_prefix("--capture-size=").split("x")
			if parts.size() == 2:
				capture_size = Vector2i(maxi(640, int(parts[0])), maxi(360, int(parts[1])))
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(capture_size)
	call_deferred("_capture_sequence")

func _capture_sequence() -> void:
	render_viewport = SubViewport.new()
	# The game is authored on a 1600x900 canvas. Render that canonical canvas,
	# then scale the captured image exactly as canvas_items stretch does.
	render_viewport.size = Vector2i(1600, 900)
	render_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(render_viewport)
	var game := (load("res://scenes/main.tscn") as PackedScene).instantiate()
	render_viewport.add_child(game)
	await get_tree().process_frame
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(capture_size)
	await get_tree().process_frame
	game.set("relay_mode", false)
	game.call("_restart")
	game.set("state", "playing")
	game.set("previous_state", "playing")
	game.set("boss_pending_id", "bugged_final_boss")
	game.set("boss_requested", true)
	game.set("boss_cutin_started", true)
	game.call("_start_boss_cutin", "bugged_final_boss", "spawn_normal_boss")
	game.call("_update_boss_cutin", 0.92)
	await _save_frame("normal")
	game.call("_cancel_boss_cutin", false)
	game.call("_apply_debug_action", "relay_boss_direct")
	game.call("_update_boss_cutin", 0.48)
	await _save_frame("final_motifs")
	game.call("_update_boss_cutin", 1.44)
	await _save_frame("final_reveal")
	game.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)

func _save_frame(label: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var image := render_viewport.get_texture().get_image()
	if image.get_size() != capture_size:
		image.resize(capture_size.x, capture_size.y, Image.INTERPOLATE_LANCZOS)
	var size := image.get_size()
	var path := "res://docs/images/boss_cutin_v2_%s_%dx%d.png" % [label, size.x, size.y]
	var error := image.save_png(path)
	if error != OK:
		push_error("Failed to save screenshot: %s (%s)" % [path, error_string(error)])
	else:
		print("Saved screenshot: %s" % path)
