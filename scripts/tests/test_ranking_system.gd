extends Node

const Ranking := preload("res://scripts/systems/ranking_system.gd")
const Difficulty := preload("res://scripts/systems/difficulty_progress_system.gd")
const CommonStyle := preload("res://scripts/ui/common_light_ui_style.gd")

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
	_check(not _summary_contains(collab_detail, "相方: partner-1") and _instruction_contains(collab_detail, "相方: partner-1"), "collab partner moves to detail highlight", failures)
	var relay_detail := Ranking._board_detail_view({"runId": "relay-display", "modeId": "relay", "stageId": "relay", "score": 10, "maxViewerCount": 10, "characterId": "ban_chan", "partnerId": "partner-2"}, 1)
	_check(not _summary_contains(relay_detail, "相方: partner-2") and _instruction_contains(relay_detail, "相方: partner-2"), "relay partner moves to detail highlight", failures)
	_check((relay_detail.get("stats", []) as Array).size() == 6, "relay detail keeps legacy statistics", failures)
	_check(Ranking._instruction_title("completed") == "配信ハイライト", "completed instruction title remains stable", failures)
	_check(Ranking._instruction_title("relay_failed") == "中断時の指示コメ", "relay failure instruction title remains stable", failures)
	_check(Ranking._instruction_title("mental_breakdown") == "戦犯指示コメ", "mental breakdown instruction title remains stable", failures)
	var hard_single_detail := Ranking._board_detail_view({"runId": "hard-single", "modeId": "normal_180", "difficulty": "hard", "stageId": "talk", "score": 100, "characterId": "ban_chan", "boss": {"firstBossSpawned": true, "firstBossDefeated": true, "reignitionBossSpawned": true, "reignitionBossDefeated": false}, "selectedHighDifficultyCommentCount": 4}, 2)
	_check(String(hard_single_detail.get("bossLabel", "")) == "HARD情報", "hard single uses hard detail label", failures)
	_check(String(hard_single_detail.get("bossText", "")).contains("ハードボス 撃破"), "hard single shows first boss result", failures)
	_check(String(hard_single_detail.get("bossText", "")).contains("再炎上ボス 未撃破"), "hard single shows reignition boss result", failures)
	_check(_instruction_contains(hard_single_detail, "高難度指示コメ：4回"), "hard single shows danger comment count", failures)
	var expert_single_detail := Ranking._board_detail_view({"runId": "expert-single", "modeId": "normal_180", "difficulty": "expert", "stageId": "talk", "score": 120, "characterId": "ban_chan", "boss": {"firstBossSpawned": true, "firstBossDefeated": false, "reignitionBossSpawned": false, "reignitionBossDefeated": false}, "dangerCommentsChosen": 6}, 1)
	_check(String(expert_single_detail.get("bossLabel", "")) == "EXPERT情報", "expert single uses expert detail label", failures)
	_check(String(expert_single_detail.get("bossText", "")).contains("EXPERTボス"), "expert single shows expert boss information", failures)
	_check(_instruction_contains(expert_single_detail, "高難度指示コメ：6回"), "expert single shows danger comment count", failures)
	var hard_relay_detail := Ranking._board_detail_view({"runId": "hard-relay", "modeId": "relay", "difficulty": "hard", "stageId": "relay", "score": 100, "maxViewerCount": 100, "characterId": "ban_chan", "partnerId": "aosumi_kyasumi", "partnerName": "青澄きゃすみ", "relay": {"reachedStageId": "collab", "reachedFinalBoss": true, "finalBossPhase": 3, "finalBossDefeated": false}}, 3)
	_check(not _summary_contains(hard_relay_detail, "相方: 青澄きゃすみ") and _instruction_contains(hard_relay_detail, "相方: 青澄きゃすみ"), "hard relay partner moves to detail highlight", failures)
	_check(String(hard_relay_detail.get("bossText", "")).contains("最高到達 最終ボス P3"), "hard relay shows final boss phase", failures)
	_check(String(hard_relay_detail.get("bossText", "")).contains("最終ボス撃破 未達成"), "hard relay shows final boss result", failures)
	var expert_relay_detail := Ranking._board_detail_view({"runId": "expert-relay", "modeId": "relay", "difficulty": "expert", "stageId": "relay", "score": 140, "maxViewerCount": 140, "characterId": "ban_chan", "relay": {"reachedStageId": "drawing", "reachedFinalBoss": true, "finalBossPhase": 2, "finalBossDefeated": false}}, 1)
	_check(String(expert_relay_detail.get("bossLabel", "")) == "EXPERT情報", "expert relay uses expert detail label", failures)
	_check(String(expert_relay_detail.get("bossText", "")).contains("配信リレー") and not String(expert_relay_detail.get("bossText", "")).contains("EXPERTリレー") and String(expert_relay_detail.get("bossText", "")).contains("最終ボス撃破 未達成"), "expert relay shows reach and final boss information", failures)
	_check(String((display_detail.get("summaryLines", []) as Array)[1]).contains("最大同時視聴者数：152,400人"), "always available detail", failures)
	_check(String(display_row.get("endTypeLabel", "")) == "完走", "board completed label is Japanese", failures)
	for failed_end_type in ["mental_breakdown", "relay_failed", "quit", "debug"]:
		var failed_row := Ranking._board_row_view({"runId": "failed-display-%s" % failed_end_type, "modeId": "normal_180", "stageId": "talk", "score": 100, "characterId": "ban_chan", "endType": failed_end_type}, 2, true)
		_check(String(failed_row.get("endTypeLabel", "")) == "GAME OVER", "board failed label %s" % failed_end_type, failures)
	_check(String(Ranking._board_detail_view({"runId": "failed-detail", "modeId": "normal_180", "stageId": "talk", "score": 100, "characterId": "ban_chan", "endType": "mental_breakdown"}, 1).get("endTypeLabel", "")) == "GAME OVER", "detail failed label is GAME OVER", failures)
	_check(String(Ranking.stage_label("relay")) == "配信リレー", "relay stage label is Japanese", failures)
	var expected_stage_labels := {"talk": "雑談枠", "game": "ゲーム実況枠", "singing": "歌枠", "drawing": "お絵かき枠", "collab": "コラボ枠"}
	for stage_id in expected_stage_labels.keys():
		_check(String(Ranking.stage_label(stage_id)) == String(expected_stage_labels[stage_id]), "stage label %s" % stage_id, failures)
	_check(CommonStyle.difficulty_palette("normal").get("accent", Color()) == Color("#E954A5"), "normal difficulty palette", failures)
	_check(CommonStyle.difficulty_palette("hard").get("accent", Color()) == Color("#D94B62"), "hard difficulty palette", failures)
	_check(CommonStyle.difficulty_palette("expert").get("accent", Color()) == Color("#7A56C8"), "expert difficulty palette", failures)
	_check(CommonStyle.difficulty_palette("normal").get("tint", Color()) == Color("#FFF2FA"), "normal difficulty tint", failures)
	_check(CommonStyle.difficulty_palette("hard").get("tint", Color()) == Color("#FFF0F2"), "hard difficulty tint", failures)
	_check(CommonStyle.difficulty_palette("expert").get("tint", Color()) == Color("#F4EFFF"), "expert difficulty tint", failures)
	_check(_check_board_views_and_empty(failures), "board view audit completed", failures)
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

func _check_board_views_and_empty(failures: Array[String]) -> bool:
	var progress := _fully_unlocked_progress()
	var entries: Array = []
	for difficulty_id in Difficulty.DIFFICULTY_IDS:
		entries.append({
			"runId": "board-%s" % difficulty_id,
			"modeId": "normal_180",
			"difficulty": difficulty_id,
			"stageId": "talk",
			"streamFrameId": "zatsudan",
			"streamFrameName": "雑談枠",
			"score": 924973,
			"viewerCount": 924973,
			"characterId": "ban_chan",
			"cleared": true,
			"endType": "completed"
		})
	var normalized := Ranking.normalize_entries(entries)
	Ranking._set_ranking_data_cache({"dataVersion": Ranking.RANKING_DATA_VERSION, "entries": normalized, "rankingEntries": normalized, "relayRankingEntries": [], "uiState": {}})
	for difficulty_id in Difficulty.DIFFICULTY_IDS:
		var view := Ranking.ranking_view_for_board(progress, difficulty_id, "talk")
		_check(String(view.get("title", "")) == "%s・%sランキング" % ["雑談枠", difficulty_id.to_upper()], "board header title %s" % difficulty_id, failures)
		_check(String(view.get("subtitle", "")) == "最大同時視聴者数ランキング", "board subtitle %s" % difficulty_id, failures)
		_check(String(view.get("difficultyLabel", "")) == difficulty_id.to_upper(), "board difficulty label %s" % difficulty_id, failures)
		var rows: Array = view.get("rows", []) as Array
		_check(rows.size() == 1, "board row count %s" % difficulty_id, failures)
		var selected_count := 0
		if not rows.is_empty():
			_check(String((rows[0] as Dictionary).get("endTypeLabel", "")) == "完走", "board completed row %s" % difficulty_id, failures)
			selected_count = 1 if bool((rows[0] as Dictionary).get("selected", false)) else 0
		_check(selected_count == 1, "board has one selected row %s" % difficulty_id, failures)
		var detail: Dictionary = view.get("detail", {}) as Dictionary
		_check(String(detail.get("title", "")) == "%s・%s" % ["雑談枠", difficulty_id.to_upper()], "board detail title %s" % difficulty_id, failures)
	var relay_entries: Array = [
		{
			"runId": "relay-complete",
			"modeId": "relay",
			"difficulty": "expert",
			"stageId": "relay",
			"score": 300,
			"maxViewerCount": 300,
			"characterId": "ban_chan",
			"isRelayCompleted": true,
			"endType": "completed",
			"relay": {"finalBossDefeated": true, "reachedStageId": "relay"}
		},
		{
			"runId": "relay-failed",
			"modeId": "relay",
			"difficulty": "expert",
			"stageId": "relay",
			"score": 200,
			"maxViewerCount": 200,
			"characterId": "ban_chan",
			"isRelayCompleted": false,
			"endType": "relay_failed",
			"relay": {"finalBossDefeated": false, "reachedStageId": "collab"}
		}
	]
	var relay_normalized := Ranking.normalize_entries(relay_entries)
	Ranking._set_ranking_data_cache({"dataVersion": Ranking.RANKING_DATA_VERSION, "entries": relay_normalized, "rankingEntries": [], "relayRankingEntries": relay_normalized, "uiState": {}})
	var relay_view := Ranking.ranking_view_for_board(progress, "expert", "relay")
	_check(String(relay_view.get("stageLabel", "")) == "配信リレー", "relay view stage label", failures)
	var relay_rows: Array = relay_view.get("rows", []) as Array
	_check(relay_rows.size() == 2, "relay view keeps completed and game over rows", failures)
	for relay_row in relay_rows:
		_check(not String((relay_row as Dictionary).get("title", "")).contains("Relay"), "relay row has no English stage token", failures)
		_check(String((relay_row as Dictionary).get("endTypeLabel", "")) in ["完走", "GAME OVER"], "relay row end state", failures)
	var relay_detail: Dictionary = relay_view.get("detail", {}) as Dictionary
	_check(String(relay_detail.get("title", "")).begins_with("配信リレー・"), "relay detail uses Japanese stage title", failures)
	_check(_stat_equals(relay_detail, "最大同時視聴者数", "300人"), "relay detail shows max viewers", failures)
	_check(_dictionary_values_have_no_relay_token(relay_view), "relay view has no user-facing Relay token", failures)
	Ranking._set_ranking_data_cache({"dataVersion": Ranking.RANKING_DATA_VERSION, "entries": [], "rankingEntries": [], "relayRankingEntries": [], "uiState": {}})
	var empty_view := Ranking.ranking_view_for_board(progress, "normal", "talk")
	_check(bool(empty_view.get("empty", false)), "empty board state", failures)
	_check((empty_view.get("messageLines", []) as Array).size() == 2, "empty board has prompt", failures)
	_check(String((empty_view.get("messageLines", []) as Array)[0]) == "まだ記録がありません", "empty board primary text", failures)
	_check(String((empty_view.get("emptyDetailLines", []) as Array)[0]) == "記録を残すと、ここで配信を振り返れます", "empty detail text", failures)
	return true

func _dictionary_values_have_no_relay_token(value: Variant) -> bool:
	if value is Dictionary:
		for key in (value as Dictionary).keys():
			if not _dictionary_values_have_no_relay_token((value as Dictionary)[key]):
				return false
		return true
	if value is Array:
		for item in value as Array:
			if not _dictionary_values_have_no_relay_token(item):
				return false
		return true
	if value is String:
		return not String(value).contains("Relay") and not String(value).contains("RELAY")
	return true

func _fully_unlocked_progress() -> Dictionary:
	var progress := Difficulty.create_default_save_data([])
	var difficulties: Dictionary = progress.get("difficulties", {}) as Dictionary
	for difficulty_id in Difficulty.DIFFICULTY_IDS:
		var difficulty_data: Dictionary = (difficulties.get(difficulty_id, Difficulty.create_default_difficulty_progress()) as Dictionary).duplicate(true)
		difficulty_data["unlocked"] = true
		var stages: Dictionary = difficulty_data.get("stages", {}) as Dictionary
		for stage_id in Difficulty.STANDARD_STAGE_IDS:
			var stage_data: Dictionary = (stages.get(stage_id, Difficulty.create_default_stage_progress()) as Dictionary).duplicate(true)
			stage_data["played"] = true
			stage_data["cleared"] = true
			stage_data["firstBossDefeated"] = true
			stage_data["reignitionBossDefeated"] = true
			stages[stage_id] = stage_data
		difficulty_data["stages"] = stages
		var relay_data: Dictionary = (difficulty_data.get("relay", Difficulty.create_default_relay_progress()) as Dictionary).duplicate(true)
		relay_data["unlocked"] = true
		relay_data["played"] = true
		relay_data["cleared"] = true
		relay_data["finalBossDefeated"] = true
		difficulty_data["relay"] = relay_data
		difficulties[difficulty_id] = difficulty_data
	progress["difficulties"] = difficulties
	progress["relayModeUnlocked"] = true
	return progress
