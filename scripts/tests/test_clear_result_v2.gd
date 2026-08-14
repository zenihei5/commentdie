extends Node

const GameScript := preload("res://scripts/game.gd")
const ResultSystemScript := preload("res://scripts/systems/result_system.gd")
const CommonLightUiStyleScript := preload("res://scripts/ui/common_light_ui_style.gd")
const GameFontSystemScript := preload("res://scripts/systems/game_font_system.gd")

var failures: Array[String] = []

func _ready() -> void:
	_run_tests()
	if failures.is_empty():
		print("CLEAR_RESULT_V2_TESTS: PASS")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("CLEAR_RESULT_V2_TESTS: FAIL (%d)" % failures.size())
	get_tree().quit(1)

func _run_tests() -> void:
	var game = GameScript.new()
	game.state = "result"
	game.last_result_data = {
		"endType": "completed",
		"pointRewardView": {
			"grantState": "granted",
			"pointsBefore": 52,
			"pointsEarned": 225,
			"pointsAfter": 277,
			"rewardRows": [{"id": "clear", "displayName": "配信クリア", "amount": 100, "isOneTimeBonus": false}]
		}
	}
	var view: Dictionary = game.last_result_data.get("pointRewardView", {}) as Dictionary
	var at_start: Dictionary = game._result_reveal_snapshot(0.0, view)
	_check_equal("reveal starts hidden", float(at_start.get("rankAlpha", 1.0)), 0.0)
	_check_equal("evaluation panel starts hidden", float(at_start.get("evaluationPanelAlpha", 1.0)), 0.0)
	var after_drop: Dictionary = game._result_reveal_snapshot(0.78, view)
	_check_approx("earned follows the 0.38-0.93 timeline", float(after_drop.get("earnedProgress", 0.0)), 0.40 / 0.55)
	_check_equal("owned remains hidden before 0.82", float(after_drop.get("ownedProgress", 0.0)), 0.0)
	var metrics_settled: Dictionary = game._result_reveal_snapshot(1.40, view)
	_check(bool(metrics_settled.get("metricSettled", false)), "top metrics settle by 1.4 seconds")
	_check_equal("evaluation panel settles by 1.4 seconds", float(metrics_settled.get("evaluationPanelAlpha", 0.0)), 1.0)
	_check_equal("earned panel settles by 1.4 seconds", float(metrics_settled.get("earnedProgress", 0.0)), 1.0)
	_check_equal("owned panel settles by 1.4 seconds", float(metrics_settled.get("ownedProgress", 0.0)), 1.0)
	var final: Dictionary = game._result_reveal_snapshot(1.67, view)
	var final_row_alphas: Array = final.get("rowAlphas", []) as Array
	_check_equal("reveal rows final", float(final_row_alphas[0]), 1.0)
	_check_equal("button reveal final", float(final.get("buttonsAlpha", 0.0)), 1.0)
	var layout: Dictionary = game._result_layout()
	_check_equal("result button order", game._result_button_ids(), ["retry", "ranking", "shop", "title"])
	_check((layout["shopButton"] as Rect2).position.x < (layout["titleButton"] as Rect2).position.x, "shop button precedes title")
	_check_equal("completed detail base position", (layout["detailPanel"] as Rect2).position, Vector2(570, 238))
	_check_equal("completed detail base size", (layout["detailPanel"] as Rect2).size, Vector2(520, 480))
	_check(not (layout["detailPanel"] as Rect2).intersects(layout["characterPanel"] as Rect2), "detail and character do not overlap")
	_check(not (layout["detailPanel"] as Rect2).intersects(layout["shopButton"] as Rect2), "detail and buttons do not overlap")
	var summary_rows: Array = game._result_summary_rows({
		"characterName": "赤羽ばんり",
		"streamFrameId": "gameplay",
		"streamFrameName": "英語名は表示しない",
		"difficultyId": "hard",
		"viewerCount": 1234,
		"survivalTime": 120.0,
		"maxVoltage": 2.0,
		"maxBurnCombo": 50,
		"giftCount": 3
	})
	_check_equal("result summary has eight rows", summary_rows.size(), 8)
	_check_equal("summary row order starts with streamer", String((summary_rows[0] as Dictionary).get("label", "")), "配信者")
	_check_equal("summary row order keeps frame second", String((summary_rows[1] as Dictionary).get("label", "")), "配信枠")
	_check_equal("difficulty is third summary row", String((summary_rows[2] as Dictionary).get("label", "")), "難易度")
	_check_equal("summary row order ends with gift", String((summary_rows[7] as Dictionary).get("label", "")), "ギフト")
	_check_equal("summary difficulty label", String((summary_rows[2] as Dictionary).get("difficultyLabel", "")), "HARD")
	var summary_rects: Array = game._result_summary_row_rects(layout["summaryPanel"] as Rect2)
	for index in range(summary_rects.size()):
		var summary_row_rect: Rect2 = summary_rects[index] as Rect2
		_check((layout["summaryPanel"] as Rect2).encloses(summary_row_rect), "summary row stays inside panel %d" % index)
		if index > 0:
			_check(not summary_row_rect.intersects(summary_rects[index - 1] as Rect2), "summary rows do not overlap %d" % index)
	var summary_palette: Dictionary = (summary_rows[2] as Dictionary).get("difficultyPalette", {}) as Dictionary
	_check_equal("hard summary uses hard accent", summary_palette.get("accent"), Color("#D94B62"))
	_check_equal("hard summary uses hard tint", summary_palette.get("tint"), Color("#FFF0F2"))
	for difficulty_id in ["normal", "hard", "expert"]:
		var difficulty_rows: Array = game._result_summary_rows({"difficultyId": difficulty_id})
		_check_equal("difficulty display %s" % difficulty_id, String((difficulty_rows[2] as Dictionary).get("difficultyLabel", "")), difficulty_id.to_upper())
		var expected_palette: Dictionary = CommonLightUiStyleScript.difficulty_palette(difficulty_id)
		var actual_palette: Dictionary = (difficulty_rows[2] as Dictionary).get("difficultyPalette", {}) as Dictionary
		_check_equal("difficulty palette accent %s" % difficulty_id, actual_palette.get("accent"), expected_palette.get("accent"))
		_check_equal("difficulty palette tint %s" % difficulty_id, actual_palette.get("tint"), expected_palette.get("tint"))
	var summary_labels: Array[String] = []
	for row_value in summary_rows:
		summary_labels.append(String((row_value as Dictionary).get("label", "")))
	for end_type in ["completed", "mental_breakdown"]:
		for difficulty_id in ["normal", "hard", "expert"]:
			var result_rows: Array = game._result_summary_rows({"endType": end_type, "difficultyId": difficulty_id, "streamFrameId": "zatsudan", "viewerCount": 12, "maxVoltage": 1.2})
			var result_labels: Array[String] = []
			for row_value in result_rows:
				result_labels.append(String((row_value as Dictionary).get("label", "")))
			_check_equal("summary order is stable for %s/%s" % [end_type, difficulty_id], result_labels, summary_labels)
			_check_equal("summary difficulty label is stable for %s/%s" % [end_type, difficulty_id], String((result_rows[2] as Dictionary).get("difficultyLabel", "")), difficulty_id.to_upper())
			var result_palette: Dictionary = (result_rows[2] as Dictionary).get("difficultyPalette", {}) as Dictionary
			var expected_result_palette: Dictionary = CommonLightUiStyleScript.difficulty_palette(difficulty_id)
			_check_equal("summary palette is stable for %s/%s" % [end_type, difficulty_id], result_palette, expected_result_palette)
			_check_equal("summary text layout is end-type independent for %s/%s" % [end_type, difficulty_id], game._result_summary_row_text_layout(layout["summaryPanel"] as Rect2, result_rows[3] as Dictionary), game._result_summary_row_text_layout(layout["summaryPanel"] as Rect2, summary_rows[3] as Dictionary))
	var relay_summary_rows: Array = game._result_summary_rows({
		"relayMode": true,
		"streamFrameId": "gameplay",
		"relayMaxViewerCount": 987654,
		"viewerCount": 1,
		"relayMaxVoltage": 4.5,
		"maxVoltage": 1.0
	})
	_check_equal("relay summary uses run-wide viewer maximum", String((relay_summary_rows[3] as Dictionary).get("value", "")), "987,654 人")
	_check_equal("relay summary uses run-wide voltage maximum", String((relay_summary_rows[5] as Dictionary).get("value", "")), "x4.5")
	_check_equal("result evaluation label is shared", game._result_evaluation_label(), "配信評価")
	_check(game._result_pp_font_size(0) >= game._result_pp_font_size(99), "PP zero uses a safe normal font size")
	_check(game._result_pp_font_size(99) >= game._result_pp_font_size(999), "PP two and three digits remain monotonic")
	_check(game._result_pp_font_size(999) >= game._result_pp_font_size(9999), "PP four digits shrink when needed")
	_check(game._result_pp_font_size(9999) >= game._result_pp_font_size(99999), "PP long values never grow")
	var result_character_rect := layout["characterPanel"] as Rect2
	for character_id in ["banri", "supana", "maron"]:
		var completed_character_rect: Rect2 = game._result_character_content_rect(result_character_rect, character_id)
		var defeat_character_rect: Rect2 = game._result_character_content_rect(result_character_rect, character_id)
		_check_equal("character content geometry is shared for %s" % character_id, completed_character_rect, defeat_character_rect)
		_check(completed_character_rect.size.x > 0.0 and completed_character_rect.size.y > 0.0, "character content geometry is positive for %s" % character_id)
	_check_equal("unknown character keeps the fallback rect", game._result_character_content_rect(result_character_rect, "unknown_character"), result_character_rect)
	for retry_difficulty_id in ["hard", "expert"]:
		game.run_difficulty_id = retry_difficulty_id
		_check_equal("retry keeps %s difficulty" % retry_difficulty_id, game._result_retry_difficulty_id(), retry_difficulty_id)
	game.run_difficulty_id = "normal"
	var completed_subtitle_baseline := (layout["panel"] as Rect2).position.y + 138.0
	var summary_band_top := (layout["summaryPanel"] as Rect2).position.y - 18.0
	_check(summary_band_top - completed_subtitle_baseline >= 6.0, "completed subtitle clears summary ribbon")
	var metric_rect := Rect2(Vector2.ZERO, Vector2(800, 86))
	var metric_layout: Dictionary = game._completed_metric_card_layout(metric_rect)
	var evaluation_card: Rect2 = metric_layout["evaluation"] as Rect2
	var earned_card: Rect2 = metric_layout["earned"] as Rect2
	var owned_card: Rect2 = metric_layout["owned"] as Rect2
	_check_equal("metric card gap", float(metric_layout["gap"]), 12.0)
	_check_equal("metric cards share width", evaluation_card.size.x, earned_card.size.x)
	_check_equal("metric cards share height", evaluation_card.size.y, 86.0)
	_check_approx("metric cards fit 800px row", owned_card.end.x, metric_rect.end.x)
	_check(not evaluation_card.intersects(earned_card), "evaluation and earned cards do not overlap")
	_check(not earned_card.intersects(owned_card), "earned and owned cards do not overlap")
	var result_font := GameFontSystemScript.regular_font()
	var owned_value_width := owned_card.size.x - 149.0
	for pp_value in [0, 99, 999, 9999, 99999]:
		var earned_text := "+%d" % pp_value
		var owned_text := str(pp_value)
		var earned_font_size := game._result_pp_font_size(pp_value)
		var owned_before_font_size := game._result_pp_font_size(pp_value, 23)
		var owned_after_font_size := game._result_pp_font_size(pp_value, 28)
		_check(result_font.get_string_size(earned_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, earned_font_size).x <= 128.0, "earned PP text fits for %d" % pp_value)
		_check(result_font.get_string_size(owned_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, owned_before_font_size).x <= 58.0, "owned before PP text fits for %d" % pp_value)
		_check(result_font.get_string_size(owned_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, owned_after_font_size).x <= owned_value_width, "owned after PP text fits for %d" % pp_value)
	var build_card := Rect2(Vector2.ZERO, Vector2(472.0, 128.0))
	var build_slot_rows: Array = [
		game._result_equipment_slot_rects(Vector2(76.0, 28.0), 5, 36.0, 44.0),
		game._result_equipment_slot_rects(Vector2(76.0, 78.0), 5, 36.0, 44.0)
	]
	var all_build_slots: Array = []
	for slot_row_value in build_slot_rows:
		var slot_row: Array = slot_row_value as Array
		_check_equal("build row has five slots", slot_row.size(), 5)
		for slot_value in slot_row:
			var slot: Rect2 = slot_value as Rect2
			_check(build_card.encloses(slot), "build slot stays inside card")
			all_build_slots.append(slot)
	for slot_index in range(all_build_slots.size()):
		for other_index in range(slot_index):
			_check(not (all_build_slots[slot_index] as Rect2).intersects(all_build_slots[other_index] as Rect2), "build slots do not overlap")
	var earned_coin_rect: Rect2 = game._completed_metric_pp_coin_rect(earned_card)
	var owned_coin_rect: Rect2 = game._completed_metric_pp_coin_rect(owned_card)
	_check_equal("earned and owned PP icons share size", earned_coin_rect.size, owned_coin_rect.size)
	_check_equal("completed metric PP icon size", earned_coin_rect.size, Vector2(30.0, 30.0))
	_check_approx("earned PP icon vertical center", earned_coin_rect.get_center().y, earned_card.get_center().y + 1.0)
	_check_approx("owned PP icon vertical center", owned_coin_rect.get_center().y, owned_card.get_center().y + 1.0)
	_check(bool(game._completed_evaluation_style("S")["gold"]), "S evaluation uses gold accent")
	_check(not bool(game._completed_evaluation_style("A")["gold"]), "A evaluation does not use gold accent")
	_check_equal("B evaluation rank color", (game._completed_evaluation_style("B")["rank"] as Color), Color("#5baec7"))
	_check_equal("C evaluation rank color", (game._completed_evaluation_style("C")["rank"] as Color), Color("#8a76a8"))
	var detail_rect := Rect2(Vector2(570, 238), Vector2(520, 480))
	var detail_layout: Dictionary = game._completed_result_detail_layout(detail_rect)
	var highlight: Rect2 = detail_layout["highlight"] as Rect2
	var reward: Rect2 = detail_layout["reward"] as Rect2
	var build: Rect2 = detail_layout["build"] as Rect2
	var ranking: Rect2 = detail_layout["ranking"] as Rect2
	_check_equal("completed highlight height", highlight.size.y, 104.0)
	_check_equal("completed reward height", reward.size.y, 116.0)
	_check_equal("completed build height", build.size.y, 128.0)
	_check_equal("completed ranking height", ranking.size.y, 60.0)
	_check_equal("completed detail gap", float(detail_layout["gap"]), 8.0)
	_check(not highlight.intersects(reward), "highlight and reward do not overlap")
	_check(not reward.intersects(build), "reward and build do not overlap")
	_check(not build.intersects(ranking), "build and ranking do not overlap")
	_check(ranking.end.y <= detail_rect.end.y and detail_rect.end.y - ranking.end.y >= 16.0, "completed detail keeps bottom breathing room")
	var highlight_rows: Array = game._completed_result_highlight_rows({
		"lastInstructionComment": "ラストコメント",
		"bossSummoned": true,
		"bossName": "指示コメボス",
		"bossDefeated": true
	})
	_check_equal("completed highlight rows are capped at three", highlight_rows.size(), 3)
	_check_equal("completed highlight last row is boss", String((highlight_rows[2] as Dictionary).get("label", "")), "挑戦ボス")
	var reward_card := Rect2(Vector2.ZERO, Vector2(472, 116))
	var reward_grid_small: Dictionary = game._completed_reward_grid_layout(reward_card, 3)
	var reward_grid_large: Dictionary = game._completed_reward_grid_layout(reward_card, 6)
	_check_equal("three reward rows use one column", int(reward_grid_small["columns"]), 1)
	_check_equal("six reward rows use two columns", int(reward_grid_large["columns"]), 2)
	_check(float(reward_grid_large["rowStep"]) >= 18.0, "reward row spacing remains readable")
	var reward_metrics: Dictionary = game._completed_reward_card_metrics(reward_card)
	_check_equal("reward divider baseline", float(reward_metrics["dividerY"]), 93.0)
	_check_equal("reward total baseline", float(reward_metrics["totalBaseline"]), 109.0)
	_check(float(reward_metrics["totalArea"]) >= 22.0, "reward total area is dedicated")
	var registered_data := {"isRankingEligible": true, "rankingRegistered": true}
	_check(game._result_ranking_registered(registered_data), "ranking registration uses explicit data flag")
	var registered_visual: Dictionary = game._completed_ranking_visual_metrics(true)
	var unregistered_visual: Dictionary = game._completed_ranking_visual_metrics(false)
	_check(bool(registered_visual["glow"]), "registered ranking has gold glow")
	_check_equal("registered ranking border width", int(registered_visual["borderWidth"]), 3)
	_check_equal("registered ranking icon size", float(registered_visual["iconSize"]), 40.0)
	_check_equal("registered ranking title size", int(registered_visual["titleFontSize"]), 16)
	_check(not bool(unregistered_visual["glow"]), "unregistered ranking has no gold glow")
	_check_equal("unregistered ranking remains purple border", int(unregistered_visual["borderWidth"]), 2)
	var podium_sizes := [32.0, 40.0, 48.0]
	for podium_size in podium_sizes:
		var podium_rect := Rect2(Vector2(10, 10), Vector2(podium_size, podium_size))
		var segments: Array = game._result_podium_segments(podium_rect)
		_check_equal("podium has three segments", segments.size(), 3)
		var previous_bottom := -1.0
		var min_x := podium_rect.end.x
		var max_x := podium_rect.position.x
		for segment_value in segments:
			var segment: Rect2 = segment_value as Rect2
			_check(segment.position.x >= podium_rect.position.x and segment.position.y >= podium_rect.position.y, "podium segment starts inside parent")
			_check(segment.end.x <= podium_rect.end.x and segment.end.y <= podium_rect.end.y, "podium segment ends inside parent")
			if previous_bottom >= 0.0:
				_check_approx("podium bottoms align", segment.end.y, previous_bottom)
			previous_bottom = segment.end.y
			min_x = minf(min_x, segment.position.x)
			max_x = maxf(max_x, segment.end.x)
		_check_approx("podium horizontal center", (min_x + max_x) * 0.5, podium_rect.get_center().x)
	var registered_view: Dictionary = game._result_ranking_card_view("通常ランキング登録：3位 / 最大31,148人", true)
	_check_equal("registered ranking view title", String(registered_view["title"]), "ランキング登録！")
	var out_view: Dictionary = game._result_ranking_card_view("ランキング対象外：テスト配信", false)
	_check_equal("out-of-range ranking view title", String(out_view["title"]), "ランキング圏外")
	game.result_reveal_active = true
	game.result_reveal_complete = false
	game.result_drop_timer = 0.0
	game._complete_result_reveal()
	_check(bool(game.result_reveal_complete), "skip completes reveal")
	_check_equal("skip does not change state", String(game.state), "result")
	var skipped_final: Dictionary = game._result_reveal_snapshot(game.result_reveal_elapsed, view)
	_check_equal("skip settles evaluation panel", float(skipped_final.get("evaluationPanelAlpha", 0.0)), 1.0)
	_check_equal("skip settles earned value", float(skipped_final.get("earnedProgress", 0.0)), 1.0)
	_check_equal("skip settles owned value", float(skipped_final.get("ownedProgress", 0.0)), 1.0)
	var normal_view: Dictionary = ResultSystemScript.build_point_reward_view({"clearPp": 150, "totalPp": 150}, "granted", 0, 150, 150, false)
	var normal_rows: Array = normal_view.get("rewardRows", []) as Array
	var normal_row: Dictionary = normal_rows[0] as Dictionary
	_check_equal("normal adapter row amount", int(normal_row.get("amount", 0)), 150)
	var result_data := ResultSystemScript.build_result_data({"endType": "completed", "isRankingEligible": true})
	_check(bool(result_data.get("rankingRegistered", false)), "result data carries ranking registration state")
	var normalized_difficulty_data: Dictionary = ResultSystemScript.build_result_data({"endType": "completed", "difficultyId": "EXPERT"})
	_check_equal("result keeps canonical run difficulty", String(normalized_difficulty_data.get("runDifficultyId", "")), "expert")
	var expected_frame_names := {
		"zatsudan": "雑談枠",
		"gameplay": "ゲーム実況枠",
		"singing": "歌枠",
		"drawing": "お絵かき枠",
		"collab": "コラボ枠"
	}
	for frame_id in expected_frame_names.keys():
		var frame_view: Dictionary = ResultSystemScript.build_result_data({
			"endType": "completed",
			"streamFrameId": frame_id,
			"streamFrameName": "Legacy English name"
		})
		_check_equal("result frame display %s" % frame_id, String(frame_view.get("streamFrameName", "")), expected_frame_names[frame_id])
	var missing_frame_id_view: Dictionary = ResultSystemScript.build_result_data({"endType": "completed", "streamFrameId": "", "stageId": "singing", "streamFrameName": ""})
	_check_equal("result frame display falls back to stage id", String(missing_frame_id_view.get("streamFrameName", "")), "歌枠")
	var empty_frame_id_view: Dictionary = ResultSystemScript.build_result_data({"endType": "completed", "streamFrameId": "", "stageId": "", "streamFrameName": "過去の枠名"})
	_check_equal("empty result frame id keeps fallback name", String(empty_frame_id_view.get("streamFrameName", "")), "過去の枠名")
	var frame_aliases := {"talk": "雑談枠", "chat": "雑談枠", "game": "ゲーム実況枠", "song": "歌枠"}
	for alias in frame_aliases.keys():
		var alias_view: Dictionary = ResultSystemScript.build_result_data({"endType": "completed", "streamFrameId": alias})
		_check_equal("result frame alias %s" % alias, String(alias_view.get("streamFrameName", "")), frame_aliases[alias])
	for relay_end_type in ["completed", "mental_breakdown"]:
		var relay_view: Dictionary = ResultSystemScript.build_result_data({
			"endType": relay_end_type,
			"relayMode": true,
			"streamFrameId": "gameplay",
			"streamFrameName": "通常枠の名前"
		})
		_check_equal("relay result name is stable for %s" % relay_end_type, String(relay_view.get("streamFrameName", "")), "配信リレー")

	var clear_highlight_style: Dictionary = game._result_highlight_style("highlight", true)
	var trouble_style: Dictionary = game._result_highlight_style("trouble", true)
	_check_equal("game over trouble uses cross icon", String(trouble_style.get("icon", "")), "cross")
	_check(trouble_style.get("border") != clear_highlight_style.get("border"), "game over trouble does not use clear gold border")
	var fitted_trouble_text := game._result_fit_text("これはとても長いトラブル理由がカード幅を超えないように短縮される文章です", 14, 120.0)
	_check(fitted_trouble_text.length() < 50, "long trouble value is shortened")
	_check(GameFontSystemScript.regular_font().get_string_size(fitted_trouble_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14).x <= 120.0, "long trouble value fits measured width")
	for button_id in ["retry", "ranking", "shop", "title"]:
		var completed_button_style: Dictionary = game._result_button_style(button_id)
		game.last_result_data["endType"] = "mental_breakdown"
		var defeat_button_style: Dictionary = game._result_button_style(button_id)
		_check_equal("button color is result independent %s" % button_id, completed_button_style, defeat_button_style)
		game.result_hover_button = button_id
		var selected_button_count := 0
		for selected_button_id in game._result_button_ids():
			if game.result_hover_button == selected_button_id:
				selected_button_count += 1
		_check_equal("result selection has one focused button: %s" % button_id, selected_button_count, 1)
	game.result_hover_button = ""
	_check(game._result_button_style("codex").has("fill"), "optional Codex button keeps a shared style")

	var mental_point_view := {
		"grantState": "granted",
		"pointsBefore": 52,
		"pointsEarned": 75,
		"pointsAfter": 127,
		"rewardRows": [{"id": "first_boss", "displayName": "初回ボス", "amount": 75, "isOneTimeBonus": true}]
	}
	game.last_result_data = {
		"endType": "mental_breakdown",
		"kamiRank": "A",
		"kamiPoint": 342,
		"characterId": "banri",
		"pointRewardView": mental_point_view,
		"deathReasonText": "HPが尽きた",
		"culpritInstructionComment": "右へ逃げて！",
		"finalBlowText": "コメントの一撃",
		"bossSummoned": true,
		"bossName": "テストボス",
		"bossDefeated": false,
		"bossResult": "retreated"
	}
	game.result_reveal_elapsed = 0.0
	game.result_reveal_active = true
	game.result_reveal_complete = false
	game.result_drop_timer = 0.0
	var mental_layout: Dictionary = game._result_layout()
	for key in ["panel", "summaryPanel", "detailPanel", "characterPanel", "retryButton", "rankingButton", "shopButton", "titleButton"]:
		_check_equal("mental layout matches completed layout: %s" % key, mental_layout[key], layout[key])
	var mental_detail: Dictionary = game._completed_result_detail_layout(mental_layout["detailPanel"] as Rect2)
	_check_equal("mental highlight height", (mental_detail["highlight"] as Rect2).size.y, 104.0)
	_check_equal("mental reward height", (mental_detail["reward"] as Rect2).size.y, 116.0)
	_check_equal("mental build height", (mental_detail["build"] as Rect2).size.y, 128.0)
	_check_equal("mental ranking height", (mental_detail["ranking"] as Rect2).size.y, 60.0)
	var mental_rows: Array = game._mental_breakdown_trouble_rows(game.last_result_data)
	_check_equal("mental trouble rows are capped at three", mental_rows.size(), 3)
	_check_equal("mental trouble starts with death reason", String((mental_rows[0] as Dictionary).get("label", "")), "終了理由")
	_check_equal("mental trouble keeps culprit second", String((mental_rows[1] as Dictionary).get("label", "")), "挑戦指示コメ")
	_check_equal("mental trouble starts with cross", String((mental_rows[0] as Dictionary).get("icon", "")), "cross")
	_check_equal("mental trouble uses rose variant", String((mental_rows[0] as Dictionary).get("variant", "")), "trouble")
	_check_equal("mental trouble keeps final blow third", String((mental_rows[2] as Dictionary).get("label", "")), "最後の一撃")
	var visible_reward_rows: Array = game._completed_visible_reward_rows({"rewardRows": [{"amount": 0}, {"amount": 75}]})
	_check_equal("zero PP reward rows are hidden", visible_reward_rows.size(), 1)
	var hidden_rows: Array = game._mental_breakdown_trouble_rows({
		"deathReasonText": "なし",
		"culpritInstructionComment": "縺ｪ縺・",
		"finalBlowText": "None",
		"bossSummoned": true,
		"bossName": "null"
	})
	_check_equal("mental trouble hides empty and mojibake values", hidden_rows.size(), 0)
	_check(not bool(game._completed_evaluation_style("S", true).get("gold", true)), "mental S evaluation has no gold blessing")
	_check_equal("mental defeat character line", game._result_defeat_character_line("banri"), "やっちゃった……")
	_check(game._result_reveal_is_playing(), "mental result participates in reveal")
	game.result_reveal_elapsed = 1.55
	_check(not game._result_buttons_are_visible(), "mental buttons stay hidden until reveal completes")
	var mental_before: Dictionary = mental_point_view.duplicate(true)
	game._complete_result_reveal()
	_check(bool(game.result_reveal_complete), "mental skip completes reveal")
	_check(game._result_buttons_are_visible(), "mental buttons show after reveal completes")
	_check_equal("mental skip keeps PP view", mental_point_view, mental_before)
	_check_equal("mental skip keeps result state", String(game.state), "result")

func _check(condition: bool, label: String) -> void:
	if not condition:
		failures.append(label)

func _check_equal(label: String, actual: Variant, expected: Variant) -> void:
	_check(actual == expected, "%s: expected %s, got %s" % [label, str(expected), str(actual)])

func _check_approx(label: String, actual: float, expected: float) -> void:
	_check(absf(actual - expected) <= 0.001, "%s: expected %s, got %s" % [label, str(expected), str(actual)])
