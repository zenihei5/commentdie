extends Node

const Presentation := preload("res://scripts/systems/codex_presentation_system.gd")
const Audit := preload("res://scripts/systems/codex_audit_system.gd")

var failures: Array[String] = []
var completion_events: Array[String] = []

func _ready() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	CodexManager.initialize_empty()
	var audit_report := CodexManager.validate_masters()
	var audit_counts: Dictionary = audit_report.get("counts", {}) as Dictionary
	_check(int(audit_report.get("collectionTotal", 0)) == 84, "audit collection total is 84")
	_check(int((audit_counts.get("characters", {}) as Dictionary).get("raw", 0)) == 6, "audit character raw count is 6")
	_check(int((audit_counts.get("weapons", {}) as Dictionary).get("enabled", 0)) == 26, "audit weapon enabled count is 26")
	_check(int((audit_counts.get("accessories", {}) as Dictionary).get("enabled", 0)) == 10, "audit accessory enabled count is 10")
	_check(int((audit_counts.get("enemies", {}) as Dictionary).get("raw", 0)) == 44 and int((audit_counts.get("enemies", {}) as Dictionary).get("enabled", 0)) == 42, "audit enemy raw/effective counts are 44/42")
	_check(int((audit_counts.get("comments", {}) as Dictionary).get("enabled", 0)) == 44, "audit comment enabled count is 44")
	_check(bool(audit_report.get("valid", false)), "current masters audit clean")

	var enemy_master := _read_array("res://data/codex_enemies.json")
	var last_offline := _find(enemy_master, "last_offline")
	_check(enemy_master.size() == 44 and String(enemy_master.back().get("id", "")) == "last_offline", "last_offline is the final raw enemy row")
	_check((last_offline.get("codex", {}) as Dictionary).has("strategy"), "enemy codex sections are structured")
	var fast_master := _find(enemy_master, "fast")
	var fast_model := Presentation.build_enemy_model(fast_master, true, {}, Presentation.load_sources())
	_check(String(fast_model.get("kind", "")) == "normal" and not (fast_model.get("behaviorTagRows", []) as Array).is_empty(), "normal enemy exposes behavior tags")
	var boss_model := Presentation.build_enemy_model(_find(enemy_master, "boss_kuso_maro_king"), true, {}, Presentation.load_sources())
	_check(String(boss_model.get("kind", "")) == "boss" and String(boss_model.get("titleTag", "")) == "BOSS", "normal boss model is distinct")
	var special_model := Presentation.build_enemy_model(last_offline, false, {}, Presentation.load_sources())
	_check(String(special_model.get("kind", "")) == "" and String(special_model.get("titleTag", "")) == "", "undiscovered special boss masks classification")
	_check(String(special_model.get("displayName", "")) == "？？？" and String(special_model.get("imagePath", "")) == "" and (special_model.get("relatedEnemyIds", []) as Array).is_empty(), "undiscovered special boss masks identity")
	_check((special_model.get("hintLines", []) as Array).size() > 0 and (special_model.get("conditionLines", []) as Array).is_empty(), "undiscovered enemy keeps broad hints without exact conditions")
	var empty_sections := Presentation.build_enemy_model({"id":"synthetic","displayName":"Synthetic","isBoss":false,"codexEnabled":true,"codexStages":["gameplay"],"codexSpawnTypes":["normal_wave"],"codex":{},"behaviorTags":[]}, true, {}, {})
	_check(String(empty_sections.get("description", "")) == "" and String(empty_sections.get("strategy", "")) == "", "empty enemy sections stay hidden")
	var legacy_sections := Presentation.enemy_codex_text({"description":"legacy feature"})
	_check(String(legacy_sections.get("description", "")) == "legacy feature", "legacy enemy description falls back safely")

	completion_events.clear()
	if not CodexManager.completion_achieved.is_connected(_on_completion):
		CodexManager.completion_achieved.connect(_on_completion)
	CodexManager.initialize_empty()
	for item_value in CodexManager.get_master_entries(CodexManager.CATEGORY_COMMENT):
		CodexManager.discover_comment(String((item_value as Dictionary).get("id", "")))
	_check(completion_events.count("category:comments") == 1, "comment category completion emits once")
	var comment_summary := CodexManager.get_collection_summary()
	_check(bool((comment_summary.get("categories", {}).get("comments", {}) as Dictionary).get("completed", false)), "comment category is complete")
	_check(int(comment_summary.get("total", 0)) == 84, "comments do not enter collection total")
	var saved_before_summary := CodexManager.get_save_data()
	CodexManager.get_collection_summary()
	_check(saved_before_summary == CodexManager.get_save_data(), "summary getter does not mutate save state")

	completion_events.clear()
	for category in [CodexManager.CATEGORY_CHARACTER, CodexManager.CATEGORY_WEAPON, CodexManager.CATEGORY_ACCESSORY, CodexManager.CATEGORY_ENEMY]:
		for item_value in CodexManager.get_master_entries(category):
			CodexManager.discover(category, String((item_value as Dictionary).get("id", "")))
	_check(completion_events.count("collection:") == 1, "collection completion emits once")
	_check(completion_events.size() >= 2 and completion_events[-2] == "category:enemies" and completion_events[-1] == "collection:", "category and collection completion events keep queue order")
	_check(CodexManager.category_completed_once(CodexManager.CATEGORY_COMMENT), "comment completion history is saved")
	_check(CodexManager.collection_completed_once(), "collection completion history is saved")
	var completed_save := CodexManager.get_save_data()
	_check(int(completed_save.get("schemaVersion", 0)) == 4 and (completed_save.get("category_completed_once", {}) as Dictionary).size() == 5, "schema four saves five category histories")

	CodexManager.load_save_data({"schemaVersion":3,"collection_completed_once":true,"characters":{"ban_chan":{"discovered":true,"new":false}}})
	_check(CodexManager.collection_completed_once() and CodexManager.category_completed_once(CodexManager.CATEGORY_CHARACTER), "v0.4 aggregate completion migrates to category history")
	var orphan_value := {"discovered":true,"new":true,"kill_count":7,"custom":{"kept":true}}
	CodexManager.load_save_data({"schemaVersion":4,"enemies":{"future_enemy":orphan_value,"undo_ghost":{"discovered":true,"new":true,"kill_count":2},"troll":"broken"}})
	var orphans := CodexManager.get_orphan_entries()
	_check((orphans.get(CodexManager.CATEGORY_ENEMY, {}) as Dictionary).has("future_enemy") and (orphans.get(CodexManager.CATEGORY_ENEMY, {}) as Dictionary).has("undo_ghost"), "unknown and disabled dictionary entries are retained as orphans")
	_check(not CodexManager.is_discovered(CodexManager.CATEGORY_ENEMY, "future_enemy") and CodexManager.get_discovered_count(CodexManager.CATEGORY_ENEMY) == 0, "orphans stay outside UI counts")
	var orphan_save := CodexManager.get_save_data()
	_check((orphan_save.get(CodexManager.CATEGORY_ENEMY, {}) as Dictionary).has("future_enemy"), "orphans are merged back into save data")
	var orphan_copy := CodexManager.get_orphan_entries()
	(orphan_copy[CodexManager.CATEGORY_ENEMY] as Dictionary)["future_enemy"]["custom"]["kept"] = false
	_check(bool((((CodexManager.get_orphan_entries().get(CodexManager.CATEGORY_ENEMY, {}) as Dictionary).get("future_enemy", {}) as Dictionary).get("custom", {}) as Dictionary).get("kept", true)), "orphan getter is deep copied")

	CodexManager.initialize_empty()
	CodexManager.add_enemy_kill("troll")
	_check(CodexManager.debug_unlock_all(false), "debug unlock all is available in debug build")
	_check(CodexManager.get_new_count(CodexManager.CATEGORY_ENEMY) == 0 and int(CodexManager.get_entry(CodexManager.CATEGORY_ENEMY, "troll").get("kill_count", 0)) == 1, "debug unlock preserves counters and clears NEW")
	_check(CodexManager.debug_mark_all_new() and CodexManager.get_new_count(CodexManager.CATEGORY_WEAPON) == CodexManager.get_total_count(CodexManager.CATEGORY_WEAPON), "debug mark all new marks every enabled entry")
	_check(CodexManager.debug_reset_codex() and CodexManager.get_discovered_count(CodexManager.CATEGORY_CHARACTER) == 3 and CodexManager.get_discovered_count(CodexManager.CATEGORY_WEAPON) == 0, "debug reset only restores initial codex seed")

	var fixture := Audit.audit({"weapons":[{"id":"x","codexEnabled":true,"codexStats":["unknown","unknown"]}],"enemies":[{"id":"x","displayName":"x","codexEnabled":true,"order":1,"codex":{},"behaviorTags":["unknown"]}]},{"weapons":[{"id":"x"}],"enemies":[{"id":"x"}]},{})
	_check(not bool(fixture.get("valid", true)) and not (fixture.get("warnings", []) as Array).is_empty(), "audit fixture reports invalid metadata without stopping")

	if failures.is_empty():
		print("CODEX_V05_COMPLETION_AUDIT_TESTS: PASS")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("CODEX_V05_COMPLETION_AUDIT_TESTS: FAIL (%d)" % failures.size())
	get_tree().quit(1)

func _on_completion(scope: String, category: String) -> void:
	completion_events.append("%s:%s" % [scope, category])

func _read_array(path: String) -> Array:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Array if parsed is Array else []

func _find(items: Array, id: String) -> Dictionary:
	for item in items:
		if item is Dictionary and String((item as Dictionary).get("id", "")) == id:
			return item as Dictionary
	return {}

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
