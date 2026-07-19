extends Node

func _ready() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var failures: Array[String] = []
	var game := (load("res://scenes/main.tscn") as PackedScene).instantiate()
	add_child(game)
	await get_tree().process_frame
	game.call("_apply_debug_action", "relay_boss_direct")
	_check(String(game.get("state")) == "boss_cutin", "F10 did not enter boss_cutin", failures)
	_check(not bool(game.get("relay_boss_active")), "Last Offline spawned before the cut-in completed", failures)
	var runtime: Dictionary = game.get("boss_cutin_runtime") as Dictionary
	_check(String(runtime.get("completionAction", "")) == "start_relay_final_boss", "F10 cut-in completion action is wrong", failures)
	var data: Dictionary = runtime.get("data", {}) as Dictionary
	_check(String(data.get("bossId", "")) == "last_offline", "F10 cut-in boss id is wrong", failures)
	_check(int(data.get("version", 1)) == 3, "F10 did not use the V3 cut-in", failures)
	_check(bool(runtime.get("bossPrepared", false)), "F10 did not prepare a spawn reservation", failures)
	var presentation_comments: Array = runtime.get("selectedComments", []) as Array
	_check(presentation_comments.size() >= 4 and presentation_comments.size() <= 7, "FINAL presentation comment count is invalid", failures)
	_check(_unique_count(presentation_comments) == presentation_comments.size(), "FINAL presentation comments contain duplicates", failures)
	var stage_elapsed_before := float(game.get("elapsed"))
	var instruction_timer_before := float(game.get("relay_boss_comment_timer"))
	var score_before := int(game.get("score"))
	# FINAL V3 reserves the one real boss until its 3.047 second handoff.
	game.call("_update_boss_cutin", 3.04)
	_check(not bool(game.get("relay_boss_active")), "Last Offline spawned before the 90 percent handoff", failures)
	_check((game.get("enemies") as Array).is_empty(), "Enemy dictionary was added before the handoff", failures)
	_check(is_equal_approx(float(game.get("elapsed")), stage_elapsed_before), "stage elapsed advanced during FINAL cut-in", failures)
	_check(is_equal_approx(float(game.get("relay_boss_comment_timer")), instruction_timer_before), "instruction timer advanced during FINAL cut-in", failures)
	_check(int(game.get("score")) == score_before, "presentation comments changed score", failures)
	_check(float(game.get("boss_cutin_bgm_duck_scale")) < 1.0, "FINAL BGM was not ducked", failures)
	game.call("_update_boss_cutin", 0.02)
	_check(bool(game.get("relay_boss_active")), "Last Offline was not spawned at the 90 percent handoff", failures)
	var handoff_runtime: Dictionary = game.get("boss_cutin_runtime") as Dictionary
	var spawn_uid := int(handoff_runtime.get("spawnUid", -1))
	_check(spawn_uid >= 0, "F10 handoff did not record spawnUid", failures)
	var locked_count := 0
	for item in game.get("enemies") as Array:
		var enemy: Dictionary = item as Dictionary
		if int(enemy.get("uid", -1)) == spawn_uid and bool(enemy.get("cutinIntroLocked", false)):
			locked_count += 1
	_check(locked_count == 1, "F10 handoff did not create exactly one locked boss", failures)
	var locked_boss_pos := _boss_position(game.get("enemies") as Array, spawn_uid)
	var player_hp_before := int(game.get("player_hp"))
	game.call("_update_world_systems", 0.20, 0.20)
	_check(_boss_position(game.get("enemies") as Array, spawn_uid).is_equal_approx(locked_boss_pos), "locked FINAL boss AI moved", failures)
	_check(int(game.get("player_hp")) == player_hp_before, "locked FINAL boss dealt contact damage", failures)
	game.call("_update_boss_cutin", 0.23)
	var hp_view: Dictionary = (load("res://scripts/systems/boss_cutin_system.gd") as Script).build_view(game.get("boss_cutin_runtime") as Dictionary)
	_check(float(hp_view.get("hpBarProgress", 0.0)) > 0.0, "FINAL HP reveal did not start", failures)
	_check(is_equal_approx(float(game.get("relay_boss_hp")), float(game.get("relay_boss_max_hp"))), "FINAL HP bar did not begin at max HP", failures)
	game.call("_update_boss_cutin", 0.11)
	_check(String(game.get("state")) == "playing", "F10 did not return to playing after the cut-in", failures)
	_check(bool(game.get("relay_boss_active")), "Last Offline did not spawn after the cut-in", failures)
	_check(String(game.get("collab_partner_id")) != String(game.get("current_character_id")), "F10 selected the player as their own partner", failures)
	_check(not (game.get("pause_reasons") as Array).has("BossCutin"), "BossCutin pause reason remained after completion", failures)
	game.call("_sync_boss_bgm", 1.0)
	_check(String(game.get("boss_bgm_active_path")) == "res://assets/audio/action_battle.mp3", "F10 FINAL selected the normal boss BGM", failures)
	var player_pos := Vector2(game.get("player_pos")) + Vector2(260.0, 0.0)
	game.set("player_pos", player_pos)
	var partner_before := Vector2(game.get("collab_partner_pos"))
	game.set("relay_boss_phase_transition_timer", 1.0)
	game.call("_update_world_systems", 0.10, 0.10)
	var partner_after := Vector2(game.get("collab_partner_pos"))
	_check(partner_after.distance_to(player_pos) < partner_before.distance_to(player_pos), "Partner did not follow during the phase transition", failures)
	game.queue_free()
	await get_tree().process_frame
	if failures.is_empty():
		print("Relay boss F10 cut-in integration test passed")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	get_tree().quit(1)

func _check(condition: bool, message: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(message)

func _unique_count(values: Array) -> int:
	var unique: Dictionary = {}
	for value in values:
		unique[String(value)] = true
	return unique.size()

func _boss_position(enemies: Array, uid: int) -> Vector2:
	for item in enemies:
		var enemy: Dictionary = item as Dictionary
		if int(enemy.get("uid", -1)) == uid:
			return Vector2(enemy.get("pos", Vector2.ZERO))
	return Vector2.INF
