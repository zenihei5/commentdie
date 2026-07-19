extends Node

const FINAL_BGM_PATH := "res://assets/audio/action_battle.mp3"

func _ready() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var failures: Array[String] = []
	var game := (load("res://scenes/main.tscn") as PackedScene).instantiate()
	add_child(game)
	await get_tree().process_frame
	game.call("_apply_debug_action", "relay_boss_direct")
	var runtime: Dictionary = game.get("boss_cutin_runtime") as Dictionary
	var data: Dictionary = runtime.get("data", {}) as Dictionary
	_check(String(game.get("state")) == "boss_cutin", "F10 path did not enter the cut-in", failures)
	_check(int(data.get("version", 0)) == 3, "F10 path did not use V3", failures)
	_check(is_equal_approx(float(runtime.get("duration", 0.0)), 3.40), "F10 FINAL duration is not 3.40s", failures)
	_check(String(data.get("customIntroId", "")) == "stream_shutdown", "F10 did not select stream_shutdown", failures)
	_check(bool(data.get("replaceCommonThemeIntro", false)), "FINAL did not replace the common relay theme intro", failures)
	var comments: Array = runtime.get("selectedComments", []) as Array
	_check(comments.size() >= 4 and comments.size() <= 7, "FINAL custom comment count is invalid", failures)
	_check(_unique_count(comments) == comments.size(), "FINAL custom comments contain duplicates", failures)
	var snapshot: Array = runtime.get("chatDisplaySnapshot", []) as Array
	var history_before: Array = (game.get("chat_lines") as Array).duplicate(true)
	var chat_timer_before := float(game.get("chat_timer"))
	game.call("_process", 0.12)
	_check(is_equal_approx(float(game.get("chat_timer")), chat_timer_before), "normal ChatSystem timer advanced during boss_cutin", failures)
	_check((game.get("chat_lines") as Array) == history_before, "stream_shutdown mutated chat history", failures)
	_check((game.get("boss_cutin_runtime") as Dictionary).get("chatDisplaySnapshot", []) == snapshot, "stream_shutdown mutated its display snapshot", failures)

	var score_before := int(game.get("score"))
	var hp_before := float(game.get("player_hp"))
	var bullets_before := (game.get("enemy_bullets") as Array).size()
	var challenge_before := str(game.get("collab_challenge_state"))
	var modifiers_before: Dictionary = (game.get("modifier_sources") as Dictionary).duplicate(true)
	game.call("_update_boss_cutin", 2.91)
	_check((game.get("enemies") as Array).is_empty(), "FINAL spawned before the 3.047s handoff", failures)
	game.call("_update_boss_cutin", 0.03)
	runtime = game.get("boss_cutin_runtime") as Dictionary
	var uid := int(runtime.get("spawnUid", -1))
	_check(uid >= 0, "FINAL handoff did not record spawnUid", failures)
	_check(_locked_boss_count(game.get("enemies") as Array, uid) == 1, "FINAL did not spawn exactly one locked boss", failures)
	_check(int(game.get("score")) == score_before, "cut-in changed score", failures)
	_check(is_equal_approx(float(game.get("player_hp")), hp_before), "cut-in changed player HP", failures)
	_check((game.get("enemy_bullets") as Array).size() == bullets_before, "cut-in created enemy bullets", failures)
	_check(str(game.get("collab_challenge_state")) == challenge_before, "cut-in changed collab challenge state", failures)
	_check((game.get("modifier_sources") as Dictionary) == modifiers_before, "cut-in changed active modifier sources", failures)
	game.call("_update_world_systems", 0.20, 0.20)
	_check(_locked_boss_count(game.get("enemies") as Array, uid) == 1, "FINAL intro lock was lost before finish", failures)
	game.call("_update_boss_cutin", 0.36)
	_check(String(game.get("state")) == "playing", "FINAL did not enter battle after 3.40s", failures)
	_check(bool(game.get("relay_boss_active")), "FINAL battle did not activate", failures)
	_check(_locked_boss_count(game.get("enemies") as Array, uid) == 0, "FINAL intro lock remained after finish", failures)
	_check(float(game.get("boss_cutin_bgm_release_timer")) > 0.0, "FINAL BGM release fade did not start", failures)
	_check(float(game.get("boss_cutin_bgm_duck_scale")) <= 0.121, "old BGM volume spiked at FINAL finish", failures)
	game.call("_sync_boss_bgm", 0.02)
	_check(String(game.get("boss_bgm_active_path")) == FINAL_BGM_PATH, "FINAL selected the normal boss BGM", failures)
	game.call("_update_boss_cutin_bgm_release", 0.10)
	_check(float(game.get("boss_cutin_bgm_duck_scale")) < 1.0, "FINAL BGM release jumped directly to full volume", failures)
	game.call("_update_boss_cutin_bgm_release", 0.30)
	_check(is_equal_approx(float(game.get("boss_cutin_bgm_duck_scale")), 1.0), "FINAL BGM release did not restore full volume", failures)

	game.call("_restart")
	game.set("state", "playing")
	game.call("_start_boss_cutin", "last_offline", "debug_return")
	game.call("_cancel_boss_cutin", true)
	_check(not (game.get("pause_reasons") as Array).has("BossCutin"), "cancel left BossCutin pause reason", failures)
	_check(is_equal_approx(float(game.get("boss_cutin_bgm_duck_scale")), 1.0), "cancel did not restore BGM immediately", failures)
	_check(float(game.get("boss_cutin_bgm_release_timer")) <= 0.0, "cancel left a BGM release timer", failures)
	game.set("chat_timer", 1.0)
	game.call("_process", 0.20)
	_check(float(game.get("chat_timer")) < 1.0, "normal ChatSystem did not resume after cancel", failures)

	var relay_config: Dictionary = game.get("relay_mode_config") as Dictionary
	var boss_config: Dictionary = relay_config.get("boss", {}) as Dictionary
	var original_cutin: Dictionary = (boss_config.get("cutin", {}) as Dictionary).duplicate(true)
	var fallback_cutin := original_cutin.duplicate(true)
	fallback_cutin["imagePath"] = "res://assets/generated/missing_v3_cutin.png"
	fallback_cutin["customIntroId"] = "unknown_v3_intro"
	fallback_cutin["customFinaleId"] = "unknown_v3_finale"
	boss_config["cutin"] = fallback_cutin
	relay_config["boss"] = boss_config
	game.set("relay_mode_config", relay_config)
	game.call("_start_boss_cutin", "last_offline", "start_relay_final_boss")
	game.call("_update_boss_cutin", 3.5)
	_check(String(game.get("state")) == "playing" and bool(game.get("relay_boss_active")), "missing asset/unknown IDs prevented battle start", failures)

	game.queue_free()
	await get_tree().process_frame
	if failures.is_empty():
		print("Boss cut-in V3 FINAL integration tests passed")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	get_tree().quit(1)

func _locked_boss_count(enemies: Array, uid: int) -> int:
	var count := 0
	for item in enemies:
		var enemy: Dictionary = item as Dictionary
		if int(enemy.get("uid", -1)) == uid and bool(enemy.get("cutinIntroLocked", false)):
			count += 1
	return count

func _unique_count(values: Array) -> int:
	var unique: Dictionary = {}
	for value in values:
		unique[String(value)] = true
	return unique.size()

func _check(condition: bool, message: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(message)
