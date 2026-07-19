extends Node

const NORMAL_BOSS_IDS: Array[String] = [
	"boss_super_long_comment",
	"boss_kuso_maro_king",
	"bugged_final_boss",
	"pitch_police_chief",
	"red_pen_review_chief",
	"collab_crusher"
]

func _ready() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var failures: Array[String] = []
	var game := (load("res://scenes/main.tscn") as PackedScene).instantiate()
	add_child(game)
	await get_tree().process_frame
	for boss_id in NORMAL_BOSS_IDS:
		_prepare_normal_case(game, boss_id)
		var history_before: Array = (game.get("chat_lines") as Array).duplicate(true)
		_check(bool(game.call("_start_boss_cutin", boss_id, "spawn_normal_boss")), "%s did not start" % boss_id, failures)
		var runtime: Dictionary = game.get("boss_cutin_runtime") as Dictionary
		var data: Dictionary = runtime.get("data", {}) as Dictionary
		var expected_version := 3 if boss_id in ["boss_kuso_maro_king", "bugged_final_boss", "pitch_police_chief", "red_pen_review_chief", "collab_crusher"] else 2
		_check(int(data.get("version", 1)) == expected_version, "%s used the wrong cut-in version" % boss_id, failures)
		var name_text_x := 650.0 if String(data.get("imageSide", "left")) == "left" else 90.0
		var name_plate: Rect2 = game.call("_boss_cutin_name_plate_rect", data, name_text_x) as Rect2
		var name_layout: Dictionary = game.call("_boss_cutin_name_text_layout", data, name_text_x, 1.0, true, 860) as Dictionary
		var name_position: Vector2 = name_layout.get("position", Vector2.ZERO) as Vector2
		var name_center_x := name_position.x + float(name_layout.get("width", 0)) * 0.5
		_check(is_equal_approx(name_center_x, name_plate.get_center().x) and int(name_layout.get("alignment", -1)) == HORIZONTAL_ALIGNMENT_CENTER, "%s name is not centered in its supplied plate" % boss_id, failures)
		_check(bool(runtime.get("bossPrepared", false)), "%s did not reserve its spawn" % boss_id, failures)
		var comments: Array = runtime.get("selectedComments", []) as Array
		_check(comments.size() >= 3 and comments.size() <= 5, "%s comment burst count is invalid" % boss_id, failures)
		_check(_unique_count(comments) == comments.size(), "%s comment burst contains duplicates" % boss_id, failures)
		if boss_id == "bugged_final_boss":
			_check(String(data.get("customIntroId", "")) == "bugged_game_final_boss" and String(data.get("customFinaleId", "")) == "bugged_name_correction", "bugged final boss did not select its V3 handlers", failures)
			var expected_comments: Array[String] = ["ラスボスきた！", "なんかバグってない？", "表示おかしいぞ", "これ仕様？", "ボス増えてる！", "ゲーム壊れた？", "そのラスボス大丈夫？"]
			for comment in comments:
				_check(expected_comments.has(String(comment)), "bugged final boss used the wrong comment pool", failures)
		if boss_id == "pitch_police_chief":
			_check(String(data.get("displayName", "")) == "音程警察長" and String(data.get("subTitle", "x")) == "", "pitch-police display name/subtitle is inconsistent", failures)
			_check(is_equal_approx(float(data.get("durationSeconds", 0.0)), 2.25) and is_equal_approx(float(data.get("customIntroDurationSeconds", 0.0)), 0.78), "pitch-police V3 timing is incorrect", failures)
			_check(String(data.get("customIntroId", "")) == "pitch_violation_crackdown" and String(data.get("customFinaleId", "x")) == "", "pitch-police did not select its V3 handlers", failures)
			_check(String(data.get("introPoseId", "")) == "pitch_police_crackdown" and String(data.get("customSeType", "")) == "pitch_police_boss", "pitch-police pose/sound hook is incorrect", failures)
			_check(String(data.get("imageSide", "")) == "left" and String(data.get("entryDirection", "")) == "right", "pitch-police silhouette side/entry direction was collapsed", failures)
			var expected_pitch_comments: Array[String] = ["音程警察きた！", "取り締まり始まった", "音外したら捕まる？", "警察長でかい！", "採点厳しそう", "歌い直しですか？", "サイレン鳴ってる！", "音程見られてる！"]
			for comment in comments:
				_check(expected_pitch_comments.has(String(comment)), "pitch-police used the wrong comment pool", failures)
		var duration := float(runtime.get("duration", 1.8))
		var spawn_time := duration - 0.335 if expected_version >= 3 else 1.465
		game.call("_update_boss_cutin", spawn_time - 0.01)
		_check((game.get("enemies") as Array).is_empty(), "%s spawned before 90 percent handoff" % boss_id, failures)
		_check((game.get("chat_lines") as Array) == history_before, "%s presentation comments entered chat history" % boss_id, failures)
		game.call("_update_boss_cutin", 0.02)
		var handoff_runtime: Dictionary = game.get("boss_cutin_runtime") as Dictionary
		var uid := int(handoff_runtime.get("spawnUid", -1))
		_check(uid >= 0, "%s did not record spawnUid" % boss_id, failures)
		_check(_locked_boss_count(game.get("enemies") as Array, uid) == 1, "%s did not spawn exactly one locked boss" % boss_id, failures)
		if boss_id == "bugged_final_boss":
			_check((game.get("enemies") as Array).size() == 1, "bugged handoff ghosts created extra enemy dictionaries", failures)
		if boss_id == "pitch_police_chief":
			_check((game.get("enemies") as Array).size() == 1, "pitch-police draw effects created extra enemy dictionaries", failures)
		var hp_before := _boss_hp(game.get("enemies") as Array, uid)
		var state_timer_before := _boss_state_timer(game.get("enemies") as Array, uid)
		var elapsed_after_spawn := spawn_time + 0.01
		if boss_id == "bugged_final_boss":
			game.call("_update_boss_cutin", 0.08)
			elapsed_after_spawn += 0.08
			var field_boss := _boss_by_uid(game.get("enemies") as Array, uid)
			_check(not field_boss.is_empty() and String(field_boss.get("cutinIntroPoseId", "")) == "bugged_glitch_settle", "bugged field pose was not connected", failures)
		if boss_id == "pitch_police_chief":
			game.call("_update_boss_cutin", 0.08)
			elapsed_after_spawn += 0.08
			var pitch_field_boss := _boss_by_uid(game.get("enemies") as Array, uid)
			_check(not pitch_field_boss.is_empty() and String(pitch_field_boss.get("cutinIntroPoseId", "")) == "pitch_police_crackdown", "pitch-police field ring pose was not connected", failures)
		game.call("_update_world_systems", 0.20, 0.20)
		_check(is_equal_approx(_boss_hp(game.get("enemies") as Array, uid), hp_before), "%s took damage while intro locked" % boss_id, failures)
		_check(is_equal_approx(_boss_state_timer(game.get("enemies") as Array, uid), state_timer_before), "%s AI timer advanced while intro locked" % boss_id, failures)
		game.call("_update_boss_cutin", duration - elapsed_after_spawn + 0.03)
		_check(String(game.get("state")) == "playing", "%s did not finish at its configured duration" % boss_id, failures)
		_check(bool(game.get("boss_active")), "%s was not active after finish" % boss_id, failures)
		_check(_locked_boss_count(game.get("enemies") as Array, uid) == 0, "%s intro lock remained after finish" % boss_id, failures)
		_check(is_equal_approx(float(game.get("boss_cutin_bgm_duck_scale")), 1.0), "%s BGM duck did not restore" % boss_id, failures)
		_check(not (game.get("pause_reasons") as Array).has("BossCutin"), "%s pause reason remained" % boss_id, failures)
		game.call("_sync_boss_bgm", 1.0)
		_check(String(game.get("boss_bgm_active_path")) == "res://assets/audio/boss_battle_bgm.mp3", "%s selected the FINAL boss BGM" % boss_id, failures)

	_prepare_normal_case(game, NORMAL_BOSS_IDS[0])
	game.call("_start_boss_cutin", NORMAL_BOSS_IDS[0], "spawn_normal_boss")
	game.call("_cancel_boss_cutin", true)
	_check((game.get("enemies") as Array).is_empty(), "pre-handoff cancel left a boss", failures)
	_prepare_normal_case(game, NORMAL_BOSS_IDS[0])
	game.call("_start_boss_cutin", NORMAL_BOSS_IDS[0], "spawn_normal_boss")
	game.call("_update_boss_cutin", 1.48)
	game.call("_cancel_boss_cutin", true)
	_check((game.get("enemies") as Array).is_empty(), "post-handoff cancel left a boss", failures)
	_check(not bool(game.get("boss_active")), "post-handoff cancel left boss_active", failures)

	var normalized: Dictionary = (load("res://scripts/systems/boss_cutin_system.gd") as Script).normalize_data({"version": 2, "displayName": "FALLBACK"}, {"id": "fallback"})
	_check(String(normalized.get("commentPoolId", "")) == "default_boss", "fallback comment pool is wrong", failures)
	_check(String(normalized.get("introPoseId", "")) == "generic", "fallback intro pose is wrong", failures)
	_check(String(normalized.get("entryDirection", "")) == "left", "fallback entry direction is wrong", failures)

	game.set("relay_mode", false)
	game.call("_restart")
	game.set("state", "playing")
	_check(bool(game.call("debug_play_boss_cutin", NORMAL_BOSS_IDS[0])), "visual-only debug did not start", failures)
	game.call("_update_ui")
	var chat_box: Control = game.get("chat_box") as Control
	_check(chat_box != null and not chat_box.visible, "normal comment panel appeared above the cut-in", failures)
	game.call("_update_boss_cutin", 2.0)
	_check((game.get("enemies") as Array).is_empty(), "visual-only debug spawned a boss", failures)

	game.queue_free()
	await get_tree().process_frame
	if failures.is_empty():
		print("Boss cut-in V2 normal integration tests passed")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	get_tree().quit(1)

func _prepare_normal_case(game: Node, boss_id: String) -> void:
	game.set("relay_mode", false)
	game.call("_restart")
	game.set("state", "playing")
	game.set("previous_state", "playing")
	game.set("boss_pending_id", boss_id)
	game.set("boss_requested", true)
	game.set("boss_cutin_started", true)

func _unique_count(values: Array) -> int:
	var unique: Dictionary = {}
	for value in values:
		unique[String(value)] = true
	return unique.size()

func _locked_boss_count(enemies: Array, uid: int) -> int:
	var count := 0
	for item in enemies:
		var enemy: Dictionary = item as Dictionary
		if int(enemy.get("uid", -1)) == uid and bool(enemy.get("cutinIntroLocked", false)):
			count += 1
	return count

func _boss_hp(enemies: Array, uid: int) -> float:
	for item in enemies:
		var enemy: Dictionary = item as Dictionary
		if int(enemy.get("uid", -1)) == uid:
			return float(enemy.get("hp", -1.0))
	return -1.0

func _boss_by_uid(enemies: Array, uid: int) -> Dictionary:
	for item in enemies:
		var enemy: Dictionary = item as Dictionary
		if int(enemy.get("uid", -1)) == uid:
			return enemy
	return {}

func _boss_state_timer(enemies: Array, uid: int) -> float:
	var enemy := _boss_by_uid(enemies, uid)
	if enemy.is_empty():
		return -1.0
	return float(enemy.get("buggedStateTimer", enemy.get("attackTimer", 0.0)))

func _check(condition: bool, message: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(message)
