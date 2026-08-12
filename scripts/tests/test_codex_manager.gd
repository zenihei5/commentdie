extends Node

var failures: Array[String] = []

func _ready() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	CodexManager.initialize_empty()
	_check(CodexManager.get_total_count(CodexManager.CATEGORY_CHARACTER) == _enabled_count("res://data/characters.json"), "characters total follows current master")
	_check(CodexManager.get_total_count(CodexManager.CATEGORY_WEAPON) == _enabled_count("res://data/weapons.json", "weapon"), "weapons total follows current master")
	_check(CodexManager.get_total_count(CodexManager.CATEGORY_ACCESSORY) == _enabled_count("res://data/gifts.json", "accessory"), "accessories total follows current master")
	_check(CodexManager.get_total_count(CodexManager.CATEGORY_ENEMY) == 42, "enemies total is 42")
	_check(CodexManager.get_total_count(CodexManager.CATEGORY_COMMENT) == _enabled_count("res://data/comments.json"), "comments total follows current master")
	_check(CodexManager.get_total_count(CodexManager.CATEGORY_CHARACTER) == 6, "current character snapshot is 6")
	_check(CodexManager.get_total_count(CodexManager.CATEGORY_WEAPON) == 26, "current weapon snapshot is 26")
	_check(CodexManager.get_total_count(CodexManager.CATEGORY_ACCESSORY) == 10, "current accessory snapshot is 10")
	_check(CodexManager.get_total_count(CodexManager.CATEGORY_COMMENT) == 44, "current comment snapshot is 44")
	_check(not CodexManager.discover("invalid", "x"), "invalid category is rejected")
	_check(not CodexManager.discover_character(""), "empty id is rejected")
	_check(not CodexManager.discover_character("unknown_character"), "unknown id is rejected")
	_check(not CodexManager.discover_weapon("phase1_null_weapon"), "disabled placeholder weapon is rejected")
	_check(CodexManager.is_discovered(CodexManager.CATEGORY_CHARACTER, "ban_chan"), "default character is discovered")
	_check(not CodexManager.is_new(CodexManager.CATEGORY_CHARACTER, "ban_chan"), "default character is not new")
	_check(CodexManager.discover_character("aosumi_kyasumi"), "first discovery returns true")
	_check(CodexManager.is_new(CodexManager.CATEGORY_CHARACTER, "aosumi_kyasumi"), "first discovery is new")
	_check(not CodexManager.discover_character("aosumi_kyasumi"), "rediscovery returns false")
	_check(CodexManager.is_new(CodexManager.CATEGORY_CHARACTER, "aosumi_kyasumi"), "rediscovery does not revive new")
	_check(CodexManager.mark_read(CodexManager.CATEGORY_CHARACTER, "aosumi_kyasumi"), "mark read changes new")
	_check(not CodexManager.is_new(CodexManager.CATEGORY_CHARACTER, "aosumi_kyasumi"), "mark read clears new")

	_check(CodexManager.add_enemy_kill("troll"), "normal enemy kill is recorded")
	_check(int(CodexManager.get_entry(CodexManager.CATEGORY_ENEMY, "troll").get("kill_count", 0)) == 1, "normal kill count is one")
	_check(CodexManager.record_boss_defeat("boss_kuso_maro_king", "normal"), "normal boss defeat is recorded")
	_check(CodexManager.record_boss_defeat("boss_kuso_maro_king", "hard"), "hard boss defeat is recorded")
	var boss_entry := CodexManager.get_entry(CodexManager.CATEGORY_ENEMY, "boss_kuso_maro_king")
	var defeated: Dictionary = boss_entry.get("defeated", {}) as Dictionary
	_check(int(boss_entry.get("kill_count", 0)) == 2, "boss kill count increments once per difficulty defeat")
	_check(bool(defeated.get("normal", false)) and bool(defeated.get("hard", false)) and not bool(defeated.get("expert", false)), "boss difficulty flags are limited and normalized")

	var saved := CodexManager.get_save_data()
	(saved[CodexManager.CATEGORY_CHARACTER] as Dictionary)["ban_chan"]["new"] = true
	_check(not CodexManager.is_new(CodexManager.CATEGORY_CHARACTER, "ban_chan"), "save data is a deep copy")
	var ui_entries := CodexManager.get_entries_for_ui(CodexManager.CATEGORY_ENEMY)
	(ui_entries[0] as Dictionary)["displayName"] = "mutated"
	_check(String((CodexManager.get_entries_for_ui(CodexManager.CATEGORY_ENEMY)[0] as Dictionary).get("displayName", "")) != "mutated", "ui data is a deep copy")

	CodexManager.load_save_data({
		"characters": {"aosumi_kyasumi": {"discovered": true, "new": 1}},
		"enemies": {
			"troll": {"discovered": true, "kill_count": -9},
			"boss_kuso_maro_king": {"discovered": true, "kill_count": "2", "defeated": {"normal": true, "invalid": true}}
		}
	})
	_check(int(CodexManager.get_entry(CodexManager.CATEGORY_ENEMY, "troll").get("kill_count", -1)) == 0, "negative kill count is clamped")
	var normalized_boss := CodexManager.get_entry(CodexManager.CATEGORY_ENEMY, "boss_kuso_maro_king")
	var normalized_defeated: Dictionary = normalized_boss.get("defeated", {}) as Dictionary
	_check(not normalized_defeated.has("invalid") and bool(normalized_defeated.get("normal", false)), "invalid difficulty keys are discarded")

	var master_value: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/codex_enemies.json"))
	_check(master_value is Array and (master_value as Array).size() == 44, "enemy master has 44 rows")
	var ids: Dictionary = {}
	var disabled: Array[String] = []
	if master_value is Array:
		for item in master_value as Array:
			if not item is Dictionary:
				continue
			var row: Dictionary = item as Dictionary
			var id := String(row.get("id", ""))
			_check(not ids.has(id), "enemy master has no duplicate: %s" % id)
			ids[id] = true
			if not bool(row.get("codexEnabled", true)):
				disabled.append(id)
	_check(disabled.size() == 2 and disabled.has("undo_ghost") and disabled.has("boss_super_long_comment"), "enemy master has exactly two disabled rows")
	_check(CodexManager.canonical_enemy_id({"kind": "red_pen_retake_dragon"}) == "red_pen_review_chief", "red pen alias canonicalizes")
	_check(CodexManager.canonical_enemy_id({"isBoss": true, "bossId": "bugged_final_boss_stun"}) == "bugged_final_boss", "bugged boss alias canonicalizes")

	if failures.is_empty():
		print("CODEX_MANAGER_TESTS: PASS")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("CODEX_MANAGER_TESTS: FAIL (%d)" % failures.size())
	get_tree().quit(1)

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _enabled_count(path: String, required_type: String = "") -> int:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not parsed is Array:
		return 0
	var count := 0
	for item in parsed as Array:
		if not item is Dictionary:
			continue
		var row: Dictionary = item as Dictionary
		if required_type != "" and String(row.get("equipmentType", "")) != required_type:
			continue
		if bool(row.get("codexEnabled", true)):
			count += 1
	return count
