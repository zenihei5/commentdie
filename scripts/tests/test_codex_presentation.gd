extends Node

const Presentation := preload("res://scripts/systems/codex_presentation_system.gd")
const EnemySystemScript := preload("res://scripts/systems/enemy_system.gd")

var failures: Array[String] = []

func _ready() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	CodexManager.initialize_empty()
	var enemy_master: Array = _read_array("res://data/codex_enemies.json")
	_check(enemy_master.size() == 44, "enemy metadata has 44 rows")
	var ids: Dictionary = {}
	var disabled: Array[String] = []
	var special: Array[String] = []
	for item_value in enemy_master:
		if not item_value is Dictionary:
			continue
		var item: Dictionary = item_value as Dictionary
		var id := String(item.get("id", ""))
		_check(not ids.has(id), "enemy metadata has no duplicate: %s" % id)
		_check(not item.has("start_time") and not item.has("startTime"), "enemy metadata does not duplicate numeric time: %s" % id)
		ids[id] = true
		if not bool(item.get("codexEnabled", true)):
			disabled.append(id)
			continue
		_check(not Presentation.stage_ids(item).is_empty(), "enabled enemy has stage: %s" % id)
		_check(not Presentation.spawn_types(item).is_empty(), "enabled enemy has known spawn type: %s" % id)
		if bool(item.get("codexSpecial", false)):
			special.append(id)
	_check(disabled.size() == 2 and disabled.has("undo_ghost") and disabled.has("boss_super_long_comment"), "disabled enemy set is exact")
	special.sort()
	var expected_special := Presentation.SPECIAL_IDS.duplicate()
	expected_special.sort()
	_check(special == expected_special, "SPECIAL enemy set is exact")

	_check(EnemySystemScript.wave_phase_start_seconds("zatsudan", 1) == 30.0, "zatsudan phase start is shared")
	_check(EnemySystemScript.wave_phase_start_seconds("gameplay", 2) == 75.0, "gameplay phase start is shared")
	_check(EnemySystemScript.wave_phase_start_seconds("singing", 2) == 70.0, "singing phase start is shared")
	_check(EnemySystemScript.wave_phase_start_seconds("collab", 3) == 126.0, "collab phase start is shared")
	var troll_conditions := EnemySystemScript.codex_normal_spawn_conditions("troll")
	_check(float((troll_conditions.get("startSeconds", {}) as Dictionary).get("zatsudan", -1.0)) == 0.0, "troll zatsudan condition is 0 seconds")
	_check(float((troll_conditions.get("startSeconds", {}) as Dictionary).get("singing", -1.0)) == 0.0, "troll singing condition is 0 seconds")
	var long_master := _find(enemy_master, "long_comment_guy")
	_check(Presentation.stage_ids(long_master).has("zatsudan") and Presentation.stage_ids(long_master).has("gameplay") and not Presentation.stage_ids(long_master).has("singing"), "long comment stage metadata is normalized")
	var drone_master := _find(enemy_master, "enemy_bullet_drone")
	_check(Presentation.enemy_filter_matches(drone_master, "gameplay") and Presentation.enemy_filter_matches(drone_master, "SPECIAL"), "bullet drone is in game and SPECIAL filters")
	var hidden_drone := Presentation.build_enemy_model(drone_master, false, {}, Presentation.load_sources())
	_check(String(hidden_drone.get("displayName", "")) == "？？？" and String(hidden_drone.get("imagePath", "")) == "" and Presentation.enemy_filter_matches(drone_master, "gameplay"), "undiscovered bullet drone stays filterable but masked")
	var invalid_master := {"id": "invalid", "spawnFrames": ["gameplay"], "codexStages": ["unknown_stage"], "codexSpawnTypes": ["unknown_type"]}
	_check(Presentation.stage_ids(invalid_master).has("gameplay") and Presentation.spawn_types(invalid_master).is_empty(), "invalid metadata safely falls back")
	_check(Presentation.enemy_condition_lines(invalid_master).has("出現条件：---"), "unknown spawn type falls back to placeholder condition")
	var hard_lines := Presentation.hard_wave_condition_lines("troll", Presentation.load_sources().get("difficultyModes", {}))
	_check(not hard_lines.is_empty(), "HARD waves are derived from difficulty data")
	var pressure_lines := Presentation.hard_wave_condition_lines("collab_division_noise", Presentation.load_sources().get("difficultyModes", {}))
	_check(not pressure_lines.is_empty(), "HARD pressure wave profiles are derived from difficulty data")
	var relay_master := _find(enemy_master, "last_offline")
	var relay_model := Presentation.build_enemy_model(relay_master, true, {}, Presentation.load_sources())
	_check(String(relay_model.get("stageLabels", []).front()) == "配信リレー", "last offline uses relay stage")
	_check((relay_model.get("conditions", []) as Array).has("配信リレーの最終戦で出現（NORMAL / HARD）"), "last offline condition states NORMAL and HARD")
	var noise_model := Presentation.build_enemy_model(_find(enemy_master, "noise_ghost_comment"), true, {}, Presentation.load_sources())
	_check((noise_model.get("conditions", []) as Array).has("ラストオフラインの召喚で出現"), "relay noise condition names its summon route")

	var weapons := CodexManager.get_master_entries(CodexManager.CATEGORY_WEAPON)
	var accessories := CodexManager.get_master_entries(CodexManager.CATEGORY_ACCESSORY)
	var catalog := Presentation.evolution_catalog(weapons, accessories, [])
	_check(catalog.size() == 13, "active evolution catalog has 13 recipes")
	var evolved_ids: Dictionary = {}
	for recipe_value in catalog:
		var recipe: Dictionary = recipe_value as Dictionary
		var evolved_id := String(recipe.get("evolvedWeaponId", ""))
		_check(not evolved_ids.has(evolved_id), "evolved ids are unique")
		evolved_ids[evolved_id] = true
	var ban_recipe := _find_dict(catalog, "baseWeaponId", "ban_hammer")
	_check((ban_recipe.get("selfRequirements", []) as Array).size() == 1, "BAN self condition bypasses accessory")
	_check((ban_recipe.get("otherRequirements", []) as Array).size() == 2, "BAN other-character condition includes accessory")
	var hidden_accessory_guides := Presentation.accessory_reverse_guides(weapons, accessories, [])
	var stream_guide := _find_dict(hidden_accessory_guides, "accessoryId", "stream_power")
	_check(String(stream_guide.get("evolvedDisplayName", "")) == "？？？？？", "undiscovered accessory reverse lookup masks evolved name")
	var revealed_catalog := Presentation.evolution_catalog(weapons, accessories, ["ban_judgement"])
	var revealed_ban := _find_dict(revealed_catalog, "baseWeaponId", "ban_hammer")
	_check(bool(revealed_ban.get("evolvedDiscovered", false)) and String(revealed_ban.get("evolvedDisplayName", "")) != "？？？？？", "Codex weapon discovery reveals evolution")
	var character_master := CodexManager.get_master_entries(CodexManager.CATEGORY_CHARACTER)
	var expected_types := {"ban_chan":"近距離", "superchat_chan":"遠距離", "maro_chan":"支援", "aosumi_kyasumi":"防御", "akarine_rizumu":"高機動", "shizuki_miimu":"テクニカル"}
	for character_value in character_master:
		var character: Dictionary = character_value as Dictionary
		_check(String(character.get("codexType", "")) == String(expected_types.get(String(character.get("id", "")), "")), "character codexType is data-driven")
	var character_model := Presentation.character_model(_find(character_master, "ban_chan"), weapons, [])
	_check(String(character_model.get("initialEvolutionName", "")) == "？？？？？", "character evolution is masked by Codex discovery")
	var fake_weapon := {"id":"missing", "iconPath":"res://missing/icon.png"}
	_check(Presentation.image_path_for("weapons", fake_weapon, true) == "", "missing image path falls back safely")
	_check(Presentation.filter_ids().size() == 7, "enemy UI exposes seven filters")

	if failures.is_empty():
		print("CODEX_PRESENTATION_TESTS: PASS")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("CODEX_PRESENTATION_TESTS: FAIL (%d)" % failures.size())
	get_tree().quit(1)

func _read_array(path: String) -> Array:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Array if parsed is Array else []

func _find(items: Array, id: String) -> Dictionary:
	for item in items:
		if item is Dictionary and String((item as Dictionary).get("id", "")) == id:
			return item as Dictionary
	return {}

func _find_dict(items: Array, key: String, value: String) -> Dictionary:
	for item in items:
		if item is Dictionary and String((item as Dictionary).get(key, "")) == value:
			return item as Dictionary
	return {}

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
