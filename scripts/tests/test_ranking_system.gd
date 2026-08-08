extends Node

const Ranking := preload("res://scripts/systems/ranking_system.gd")
const Difficulty := preload("res://scripts/systems/difficulty_progress_system.gd")

func _ready() -> void:
	var failures: Array[String] = []
	_check(Ranking.create_board_key("hard", "zatsudan") == "hard:talk", "hard talk board key", failures)
	_check(Ranking.create_board_key("normal", "gameplay") == "normal:game", "game alias board key", failures)
	_check(Ranking.ranking_character_sprite_path({"id": "existing", "idleSprite": "res://field_idle.png", "sprite": "res://field.png", "selectSprite": "res://standing.png"}) == "res://field_idle.png", "ranking prefers field idle sprite", failures)
	_check(Ranking.ranking_character_sprite_path({"id": "new", "idleSprite": "", "sprite": "res://field.png", "selectSprite": "res://standing.png"}) == "res://field.png", "ranking uses field sprite before standing art", failures)
	var character_data: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/characters.json"))
	_check(character_data is Array, "character data loads for ranking sprite validation", failures)
	if character_data is Array:
		for character_item in character_data as Array:
			if not (character_item is Dictionary):
				continue
			var character := character_item as Dictionary
			var expected_field_path := String(character.get("idleSprite", "")).strip_edges()
			if expected_field_path == "":
				expected_field_path = String(character.get("sprite", "")).strip_edges()
			_check(Ranking.ranking_character_sprite_path(character) == expected_field_path, "ranking uses field sprite for %s" % String(character.get("id", "")), failures)
	var legacy_single := Ranking.normalize_entry({"runId": "single-1", "modeId": "normal_180", "streamFrameId": "zatsudan", "viewerCount": 44, "characterId": "ban_chan"})
	_check(String(legacy_single.get("difficulty", "")) == "normal", "missing difficulty fallback", failures)
	_check(String(legacy_single.get("stageId", "")) == "talk", "canonical single stage", failures)
	_check(int(legacy_single.get("score", 0)) == 44, "legacy score fallback", failures)
	var legacy_relay := Ranking.normalize_entry({"runId": "relay-1", "modeId": "relay", "stageId": "collab", "maxViewerCount": 120, "characterId": "ban_chan"}, true)
	_check(Ranking.board_key_for_entry(legacy_relay) == "normal:relay", "legacy relay board", failures)
	var legacy_completed_relay := Ranking.normalize_entry({"runId": "relay-null-comment", "modeId": "relay", "stageId": "relay", "isRelayCompleted": true, "culpritInstructionComment": null, "lastInstructionComment": "最後の指示", "deathText": null, "characterId": "ban_chan"}, true)
	_check(legacy_completed_relay.get("culpritInstructionComment") is String and String(legacy_completed_relay.get("culpritInstructionComment")) == "なし", "legacy null culprit comment is migrated", failures)
	_check(legacy_completed_relay.get("deathText") is String and String(legacy_completed_relay.get("deathText")) == "", "legacy null death text is migrated", failures)
	var legacy_completed_relay_detail := Ranking._board_detail_view(legacy_completed_relay, 1)
	_check(_instruction_contains(legacy_completed_relay_detail, "最後の指示"), "completed relay with legacy null comment opens detail", failures)
	var merged := Ranking.normalize_entries([{"runId": "same", "modeId": "normal_180", "stageId": "talk", "score": 3, "characterId": "a"}, {"runId": "same", "modeId": "normal_180", "stageId": "talk", "score": 8, "characterId": "b"}, {"runId": "same", "modeId": "normal_180", "stageId": "gameplay", "score": 7, "characterId": "c"}])
	_check(merged.size() == 2, "same run deduped per board", failures)
	var sorted := Ranking._sort_entries([{"runId": "low-clear", "modeId": "normal_180", "stageId": "talk", "score": 10, "viewerCount": 999, "characterId": "a"}, {"runId": "high-gameover", "modeId": "normal_180", "stageId": "talk", "score": 20, "viewerCount": 1, "characterId": "b"}])
	_check(String((sorted[0] as Dictionary).get("runId", "")) == "high-gameover", "score is primary sort", failures)
	var progress := Difficulty.create_default_save_data([])
	var normal_stage_tabs := Ranking.ranking_stage_tabs(progress, "normal")
	_check(not bool((normal_stage_tabs[0] as Dictionary).get("locked", true)), "normal talk ranking stage is selectable", failures)
	_check(bool((normal_stage_tabs[1] as Dictionary).get("locked", false)), "uncleared normal game ranking stage is locked", failures)
	_check(bool((normal_stage_tabs[5] as Dictionary).get("locked", false)), "uncleared normal relay ranking stage is locked", failures)
	var locked_view := Ranking.ranking_view_for_board(progress, "hard", "talk")
	_check(bool(locked_view.get("locked", false)), "locked difficulty view", failures)
	_check((locked_view.get("rows", []) as Array).is_empty(), "locked view does not enumerate entries", failures)
	var hard_stage_tabs: Array = locked_view.get("stageTabs", []) as Array
	_check(hard_stage_tabs.size() == 6, "locked difficulty exposes all stage tabs", failures)
	_check(bool((hard_stage_tabs[0] as Dictionary).get("locked", false)), "locked difficulty marks stage tabs locked", failures)
	var display_entry := {"runId": "display", "modeId": "normal_180", "stageId": "talk", "score": 152400, "characterId": "ban_chan", "cleared": true, "kamiRank": "S", "kamiPoint": 88, "survivalTime": 180.0, "maxVoltage": 4.2, "maxBurnCombo": 96, "giftCount": 7}
	var display_row := Ranking._board_row_view(display_entry, 1, true)
	_check(String(display_row.get("scoreLabel", "")) == "最大同時視聴者数", "display score label", failures)
	_check(String(display_row.get("scoreText", "")) == "152,400人", "display score value", failures)
	var display_detail := Ranking._board_detail_view(display_entry, 1)
	_check(not _summary_contains(display_detail, "partner"), "single detail hides partner", failures)
	_check((display_detail.get("stats", []) as Array).size() == 6, "normal detail keeps legacy statistics", failures)
	_check(_stat_equals(display_detail, "最大同時視聴者数", "152,400人"), "normal detail shows max viewers", failures)
	_check(_stat_equals(display_detail, "ギフト数", "7"), "normal detail shows gift count", failures)
	_check(String(display_detail.get("instructionTitle", "")) == "配信ハイライト", "completed detail restores legacy result title", failures)
	_check(_instruction_contains(display_detail, "最後まで配信を走り切った記録です。"), "completed detail restores legacy result text", failures)
	var collab_detail := Ranking._board_detail_view({"runId": "collab-display", "modeId": "normal_180", "stageId": "collab", "score": 10, "characterId": "ban_chan", "partnerId": "partner-1"}, 1)
	_check(_summary_contains(collab_detail, "相方: partner-1"), "collab detail uses Japanese partner label", failures)
	var relay_detail := Ranking._board_detail_view({"runId": "relay-display", "modeId": "relay", "stageId": "relay", "score": 10, "maxViewerCount": 10, "characterId": "ban_chan", "partnerId": "partner-2"}, 1)
	_check(_summary_contains(relay_detail, "相方: partner-2"), "relay detail uses Japanese partner label", failures)
	_check((relay_detail.get("stats", []) as Array).size() == 6, "relay detail keeps legacy statistics", failures)
	var hard_single_detail := Ranking._board_detail_view({"runId": "hard-single", "modeId": "normal_180", "difficulty": "hard", "stageId": "talk", "score": 100, "characterId": "ban_chan", "boss": {"firstBossSpawned": true, "firstBossDefeated": true, "reignitionBossSpawned": true, "reignitionBossDefeated": false}, "selectedHighDifficultyCommentCount": 4}, 2)
	_check(String(hard_single_detail.get("bossLabel", "")) == "HARD情報", "hard single uses hard detail label", failures)
	_check(String(hard_single_detail.get("bossText", "")).contains("ハードボス 撃破"), "hard single shows first boss result", failures)
	_check(String(hard_single_detail.get("bossText", "")).contains("再炎上ボス 未撃破"), "hard single shows reignition boss result", failures)
	_check(_instruction_contains(hard_single_detail, "高難度指示コメ：4回"), "hard single shows danger comment count", failures)
	var hard_relay_detail := Ranking._board_detail_view({"runId": "hard-relay", "modeId": "relay", "difficulty": "hard", "stageId": "relay", "score": 100, "maxViewerCount": 100, "characterId": "ban_chan", "partnerId": "aosumi_kyasumi", "partnerName": "青澄きゃすみ", "relay": {"reachedStageId": "collab", "reachedFinalBoss": true, "finalBossPhase": 3, "finalBossDefeated": false}}, 3)
	_check(_summary_contains(hard_relay_detail, "相方: 青澄きゃすみ"), "hard relay shows partner name", failures)
	_check(String(hard_relay_detail.get("bossText", "")).contains("最高到達 FINAL P3"), "hard relay shows final boss phase", failures)
	_check(String(hard_relay_detail.get("bossText", "")).contains("最終ボス撃破 未達成"), "hard relay shows final boss result", failures)
	_check(String((display_detail.get("summaryLines", []) as Array)[1]).contains("最大同時視聴者数：152,400人"), "always available detail", failures)
	if failures.is_empty():
		print("ranking system tests passed")
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error(failure)
		get_tree().quit(1)

func _check(condition: bool, message: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(message)

func _summary_contains(detail: Dictionary, needle: String) -> bool:
	for line in detail.get("summaryLines", []) as Array:
		if String(line).contains(needle):
			return true
	return false

func _instruction_contains(detail: Dictionary, needle: String) -> bool:
	for line in detail.get("instructionLines", []) as Array:
		if String(line).contains(needle):
			return true
	return false

func _stat_equals(detail: Dictionary, label: String, value: String) -> bool:
	for item in detail.get("stats", []) as Array:
		if item is Dictionary and String((item as Dictionary).get("label", "")) == label:
			return String((item as Dictionary).get("value", "")) == value
	return false
