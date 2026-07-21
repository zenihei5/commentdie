extends Node

const GameScript := preload("res://scripts/game.gd")
const ResultSystemScript := preload("res://scripts/systems/result_system.gd")

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
	_check_equal("mental trouble keeps culprit second", String((mental_rows[1] as Dictionary).get("label", "")), "戦犯指示コメ")
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
