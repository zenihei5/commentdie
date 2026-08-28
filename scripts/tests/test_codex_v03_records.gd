extends Node

const Presentation := preload("res://scripts/systems/codex_presentation_system.gd")
const ResultSystemScript := preload("res://scripts/systems/result_system.gd")
const DifficultyProgressSystemScript := preload("res://scripts/systems/difficulty_progress_system.gd")
const CommentSystemScript := preload("res://scripts/systems/comment_system.gd")

class CommentTarget:
	extends Node
	var offered_comments: Array = []

var failures: Array[String] = []

func _ready() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	CodexManager.initialize_empty()
	_check(DifficultyProgressSystemScript.SAVE_VERSION == 6, "outer save version includes unlock presentation state")
	var migrated_outer := DifficultyProgressSystemScript.migrate_save_data({"saveVersion": 2, "streamFrameProgress": {"talk": {"isCleared": true}}})
	_check(int(migrated_outer.get("saveVersion", 0)) == 6 and migrated_outer.has("codex") and migrated_outer.has("unlockPresentation"), "save version two migrates without dropping codex or presentation state")
	CodexManager.begin_run("v03_play")
	_check(CodexManager.record_character_play("ban_chan", "v03_play"), "formal run records one character play")
	_check(not CodexManager.record_character_play("ban_chan", "v03_play"), "same run does not double record play")
	_check(CodexManager.discover_weapon("ban_judgement"), "first discovery enters session")
	_check(CodexManager.discover_weapon("ban_judgement") == false, "rediscovery is not a second session discovery")
	var clear_result := {"runId": "v03_play", "characterId": "ban_chan", "difficultyId": "normal", "stageId": "zatsudan", "score": 1234, "cleared": true, "relayMode": false}
	_check(CodexManager.record_character_result(clear_result), "clear result records")
	_check(not CodexManager.record_character_result(clear_result), "same run does not double record result")
	var character_entry := CodexManager.get_entry(CodexManager.CATEGORY_CHARACTER, "ban_chan")
	_check(int(character_entry.get("play_count", 0)) == 1 and int(character_entry.get("clear_count", 0)) == 1, "play and clear counters are saved")
	_check(int(character_entry.get("best_score", 0)) == 1234, "best score is updated by clear")
	_check(bool(((character_entry.get("stage_clears", {}) as Dictionary).get("zatsudan", {}) as Dictionary).get("normal", false)), "stage clear flag is updated")
	var first_snapshot := CodexManager.finish_run("v03_play")
	var second_snapshot := CodexManager.finish_run("v03_play")
	_check(first_snapshot == second_snapshot, "finish is idempotent and stable")
	_check((first_snapshot.get("weapons", []) as Array).has("ban_judgement"), "session discovery keeps first discovery order")
	_check(CodexManager.is_new(CodexManager.CATEGORY_WEAPON, "ban_judgement"), "NEW remains until explicit read")

	CodexManager.begin_run("v03_fail")
	var failed_result := clear_result.duplicate(true)
	failed_result["runId"] = "v03_fail"
	failed_result["cleared"] = false
	failed_result["score"] = 999999
	_check(CodexManager.record_character_result(failed_result), "failed result records once")
	CodexManager.finish_run("v03_fail")
	var after_failure := CodexManager.get_entry(CodexManager.CATEGORY_CHARACTER, "ban_chan")
	_check(int(after_failure.get("clear_count", 0)) == 1 and int(after_failure.get("best_score", 0)) == 1234, "failure does not change clear or best score")

	CodexManager.begin_run("v03_relay_fail")
	_check(CodexManager.record_character_result({"runId":"v03_relay_fail", "characterId":"ban_chan", "difficultyId":"hard", "stageId":"relay", "score":10, "cleared":false, "relayMode":true, "relayClearedFrameCount":3}), "relay failure records section")
	CodexManager.finish_run("v03_relay_fail")
	CodexManager.begin_run("v03_relay_clear")
	_check(CodexManager.record_character_result({"runId":"v03_relay_clear", "characterId":"ban_chan", "difficultyId":"hard", "stageId":"relay", "score":20, "cleared":true, "relayMode":true, "relayClearedFrameCount":5}), "relay clear records")
	CodexManager.finish_run("v03_relay_clear")
	var relay_entry := CodexManager.get_entry(CodexManager.CATEGORY_CHARACTER, "ban_chan")
	var relay_records := relay_entry.get("relay_records", {}) as Dictionary
	_check(int((relay_records.get("hard", {}) as Dictionary).get("best_section", 0)) == 5 and bool((relay_records.get("hard", {}) as Dictionary).get("cleared", false)), "relay best section and clear state are retained")
	_check(int(relay_entry.get("clear_count", 0)) == 2, "relay clear increments clear count once")

	CodexManager.begin_run("v03_comments")
	_check(CodexManager.record_comment_appearance("do_everything"), "comment appearance records")
	_check(CodexManager.record_comment_appearance("do_everything"), "same comment can appear again")
	_check(CodexManager.record_comment_selection("do_everything", false), "comment selection records")
	_check(CodexManager.record_comment_selection("do_everything", true), "heart selection records")
	var comment_entry := CodexManager.get_entry(CodexManager.CATEGORY_COMMENT, "do_everything")
	_check(int(comment_entry.get("appeared_count", 0)) == 2 and int(comment_entry.get("selected_count", 0)) == 2 and int(comment_entry.get("heart_count", 0)) == 1, "comment counters distinguish appearance selection and heart")
	var special_comment_model := Presentation.comment_record_model(_find(CodexManager.get_master_entries(CodexManager.CATEGORY_COMMENT), "do_everything"), comment_entry)
	_check((special_comment_model.get("stageIds", []) as Array).size() == 5 and (special_comment_model.get("tags", []) as Array).has("SPECIAL"), "comment presentation derives default stages and SPECIAL tag")
	var hard_comment_model := Presentation.comment_record_model(_find(CodexManager.get_master_entries(CodexManager.CATEGORY_COMMENT), "hard_overclock"), {})
	_check((hard_comment_model.get("tags", []) as Array).has("HARD") and String(hard_comment_model.get("heartDescription", "")) != "---", "comment presentation exposes HARD and heart fallback")
	var comment_session := CodexManager.get_session_discoveries()
	_check((comment_session.get("comments", []) as Array).size() == 1, "session comments contain one first discovery")
	CodexManager.finish_run("v03_comments")

	CodexManager.begin_run("v03_offer")
	var offer_target := CommentTarget.new()
	offer_target.offered_comments = [{"id": "do_everything"}, {"id": "banana_floor"}, {"id": "reverse_control"}, {"id": "banana_floor"}]
	CommentSystemScript.discover_offered_comments_for_target(offer_target)
	var offer_do_everything := CodexManager.get_entry(CodexManager.CATEGORY_COMMENT, "do_everything")
	var offer_banana := CodexManager.get_entry(CodexManager.CATEGORY_COMMENT, "banana_floor")
	_check(int(offer_do_everything.get("appeared_count", 0)) == 3 and int(offer_banana.get("appeared_count", 0)) == 1, "comment offer helper counts each unique displayed card")
	offer_target.queue_free()
	CodexManager.finish_run("v03_offer")

	var saved := CodexManager.get_save_data()
	_check(int(saved.get("schemaVersion", 0)) == 4, "codex schema is version four")
	(saved[CodexManager.CATEGORY_CHARACTER] as Dictionary)["ban_chan"]["play_count"] = 999
	_check(int(CodexManager.get_entry(CodexManager.CATEGORY_CHARACTER, "ban_chan").get("play_count", 0)) != 999, "record save is a deep copy")
	CodexManager.load_save_data({"schemaVersion": 1, "characters": {"ban_chan": {"discovered": true, "new": false}}, "comments": {"do_everything": {"discovered": true, "new": true}}, "enemies": {"troll": {"discovered": true, "kill_count": -4}}})
	var old_character := CodexManager.get_entry(CodexManager.CATEGORY_CHARACTER, "ban_chan")
	_check(int(old_character.get("play_count", -1)) == 0 and (old_character.get("stage_clears", {}) as Dictionary).has("zatsudan"), "old character entry is upgraded with zero records")
	_check(int(CodexManager.get_entry(CodexManager.CATEGORY_ENEMY, "troll").get("kill_count", -1)) == 0, "old enemy count stays normalized")
	_check(int(CodexManager.get_entry(CodexManager.CATEGORY_COMMENT, "do_everything").get("appeared_count", -1)) == 0, "old comment entry gets zero counters")

	var legacy_progress := {"difficulties": {"normal": {"stages": {"zatsudan": {"clearCharacterIds": ["aosumi_kyasumi"]}}, "relay": {"clearCharacterIds": ["aosumi_kyasumi"]}}}}
	_check(CodexManager.sync_legacy_character_records(legacy_progress), "legacy clear history is synced")
	_check(not CodexManager.sync_legacy_character_records(legacy_progress), "legacy sync is idempotent")
	var legacy_entry := CodexManager.get_entry(CodexManager.CATEGORY_CHARACTER, "aosumi_kyasumi")
	_check(not bool(legacy_entry.get("new", true)) and int(legacy_entry.get("clear_count", 0)) == 0 and int(((legacy_entry.get("relay_records", {}) as Dictionary).get("normal", {}) as Dictionary).get("best_section", 0)) == 5, "legacy sync does not invent counters and clears NEW")

	var progress := {"difficulties": {"normal": {"unlocked": true, "relay": {"unlocked": true}}, "hard": {"unlocked": true, "relay": {"unlocked": true}}, "expert": {"unlocked": false, "relay": {"unlocked": false}}}}
	var record_model := Presentation.character_record_model(CodexManager.get_master_entries(CodexManager.CATEGORY_CHARACTER)[0], relay_entry, progress)
	_check((record_model.get("stageClears", []) as Array).size() == 5 and (record_model.get("relayRecords", []) as Array).size() == 3, "character presentation exposes five stages and relay difficulties")
	var boss_master := _find(CodexManager.get_master_entries(CodexManager.CATEGORY_ENEMY), "last_offline")
	var boss_model := Presentation.boss_record_model(boss_master, {"kill_count": 2, "defeated": {"normal": true}}, progress, Presentation.load_sources())
	_check((boss_model.get("states", []) as Array).size() >= 2, "boss model exposes normal and hard states")
	_check(String(((boss_model.get("states", []) as Array)[0] as Dictionary).get("status", "")) == "CLEAR", "boss clear status is explicit")
	_check(String(((boss_model.get("states", []) as Array)[1] as Dictionary).get("status", "")) == "---", "boss un defeated status is explicit")
	for state_value in boss_model.get("states", []) as Array:
		var state := state_value as Dictionary
		if String(state.get("difficulty", "")) == "expert":
			_check(String(state.get("status", "")) == "LOCK", "expert is locked when not implemented or unlocked")

	var result_text := ResultSystemScript.build_result_text({"endType":"mental_breakdown", "rank":"D", "kamiPoint":0, "modeName":"normal", "characterName":"ban", "streamFrameName":"chat", "score":0, "maxMultiplier":1.0, "giftsTaken":0, "maxGiftHype":0, "dangerCommentsChosen":0, "heartUsedCount":0, "currentComment":"none", "reason":"test", "lastDeathSource":"test", "weaponEquipmentText":"", "accessoryEquipmentText":"", "giftSummary":"", "sessionDiscoveries":{"weapons":["ban_judgement"]}})
	_check(result_text.contains("NEW DISCOVERIES"), "result text contains discovery block")
	var result_data := ResultSystemScript.build_result_data({"endType":"mental_breakdown", "sessionDiscoveries":{"weapons":["ban_judgement"]}})
	_check((result_data.get("sessionDiscoveries", {}) as Dictionary).has("weapons"), "result data carries discovery snapshot")

	if failures.is_empty():
		print("CODEX_V03_RECORD_TESTS: PASS")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("CODEX_V03_RECORD_TESTS: FAIL (%d)" % failures.size())
	get_tree().quit(1)

func _find(items: Array, id: String) -> Dictionary:
	for item_value in items:
		if item_value is Dictionary and String((item_value as Dictionary).get("id", "")) == id:
			return item_value as Dictionary
	return {}

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
