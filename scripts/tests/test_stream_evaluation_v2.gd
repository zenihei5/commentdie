extends Node

const Evaluation := preload("res://scripts/systems/stream_evaluation_system.gd")
const RewardCalculator := preload("res://scripts/systems/stream_point_reward_calculator.gd")
const RewardResult := preload("res://scripts/systems/stream_point_reward_result.gd")
const ResultSystem := preload("res://scripts/systems/result_system.gd")
const Ranking := preload("res://scripts/systems/ranking_system.gd")
const DamageSystem := preload("res://scripts/systems/damage_system.gd")

class FakeDatabase extends RefCounted:
	var reward_rules: Dictionary = {}

class FakeTracker extends RefCounted:
	var run_id := "retry-evaluation-run"
	var result_committed := false

	func reward_input(is_relay: bool, outcome: String, active_seconds: float, stage_id: String, stage_cleared: bool, cleared_frame_ids: Array) -> Dictionary:
		return {
			"rewardEligible": true,
			"official": true,
			"isRelay": is_relay,
			"outcome": outcome,
			"activePlaySeconds": active_seconds,
			"stageId": stage_id,
			"stageCleared": stage_cleared,
			"difficultyId": "normal",
			"relayClearedFrameIds": cleared_frame_ids,
			"relayFinalReached": true,
			"relayFinalDefeated": true,
			"defeatedBosses": [],
			"fieldGiftPp": 0,
			"fallbackGiftPp": 0,
			"fullBuildConversionPp": 0
		}

	func should_unlock_senior_unit(_input: Dictionary) -> bool:
		return true

class FakeManager extends RefCounted:
	var database := FakeDatabase.new()
	var profile: Dictionary = {"firstStageClears": {}, "firstBossDefeats": {}, "firstRelayClear": true}
	var points := 0
	var grant_calls := 0
	var last_run_id := ""
	var last_senior_flag := false

	func current_points() -> int:
		return points

	func grant_reward(run_id: String, reward, senior_unlock: bool = false) -> Dictionary:
		grant_calls += 1
		last_run_id = run_id
		last_senior_flag = senior_unlock
		if grant_calls == 1:
			return {"ok": false, "state": "save_failed", "balance": points}
		points += int(reward.total_pp)
		return {"ok": true, "state": "granted", "balance": points, "seniorUnitUnlocked": senior_unlock}

class FakeTarget extends Node:
	var power_up_run_tracker = FakeTracker.new()
	var power_up_shop_manager = FakeManager.new()
	var run_difficulty_id := "normal"
	var pending_power_up_reward = null
	var last_result_data: Dictionary = {"relayMode": true, "pointRewardView": {"pointsBefore": 0}}

class FakeDamageTarget extends Node:
	var player_hp := 100
	var zero_taunt_resist := false
	var multiplier := 1.0
	var burn_resist_charges := 0
	var burn_combo := 0
	var gift_hype := 0
	var revive_available := false
	var player_base_invincible_time := 0.7
	var invincible := 0.0
	var debug_invincible := false
	var active_comment_hurt := false
	var current_comment := ""
	var current_death_text := ""
	var last_death_source := ""
	var evaluation_damage := 0

	func _record_evaluation_damage(amount: int) -> void:
		evaluation_damage += amount

var failures: Array[String] = []

func _ready() -> void:
	_run_tests()
	if failures.is_empty():
		print("STREAM_EVALUATION_V2_TESTS: PASS")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("STREAM_EVALUATION_V2_TESTS: FAIL (%d)" % failures.size())
	get_tree().quit(1)

func _run_tests() -> void:
	_check_category_formulae()
	_check_ranks()
	_check_game_over_ceiling()
	_check_sampling_and_counters()
	_check_boss_scoring()
	_check_reward_formulae()
	_check_retry_metadata()
	_check_ranking_versions()
	_check_result_contract()

func _check_category_formulae() -> void:
	var clear_stats := _max_stats(false, true)
	var clear_result: Dictionary = Evaluation.calculate(clear_stats)
	_check_equal("clear max evaluation score", int(clear_result["evaluationScore"]), 100)
	_check_equal("clear max evaluation rank", String(clear_result["evaluationRank"]), "S")
	var breakdown: Dictionary = clear_result["evaluationBreakdown"] as Dictionary
	for pair in [["challenge", 20], ["hype", 25], ["stability", 20], ["gifts", 10], ["combat", 5], ["completion", 20]]:
		_check_equal("category %s" % String(pair[0]), int(breakdown[pair[0]]), int(pair[1]))
	var game_over: Dictionary = Evaluation.calculate(_max_stats(false, false))
	_check_equal("game over theoretical maximum", int(game_over["evaluationScore"]), 80)
	_check_equal("game over maximum is A, not forced S", String(game_over["evaluationRank"]), "A")

func _check_ranks() -> void:
	var expected := {39: "D", 40: "C", 54: "C", 55: "B", 69: "B", 70: "A", 84: "A", 85: "S", 100: "S"}
	for score in expected.keys():
		_check_equal("rank boundary %d" % score, Evaluation.rank_for_score(int(score)), String(expected[score]))

func _check_game_over_ceiling() -> void:
	var stats := _max_stats(false, false)
	stats["evaluationDangerousCommentCount"] = 999
	stats["evaluationGiftCount"] = 999
	var result: Dictionary = Evaluation.calculate(stats)
	_check(int(result["evaluationScore"]) <= 80, "game over score cannot gain completion points")

func _check_sampling_and_counters() -> void:
	var initial := Evaluation.empty_state(100.0)
	var ten_steps := initial
	for _i in range(10):
		ten_steps = Evaluation.sample_state(ten_steps, 0.1, 60.0, 3.0)
	var one_step := Evaluation.sample_state(initial, 1.0, 60.0, 3.0)
	_check_approx("delta integral is FPS independent", float(ten_steps["evaluationBuzzIntegral"]), float(one_step["evaluationBuzzIntegral"]))
	_check_approx("voltage integral is FPS independent", float(ten_steps["evaluationVoltageIntegral"]), float(one_step["evaluationVoltageIntegral"]))
	var paused := Evaluation.sample_state(ten_steps, 0.0, 100.0, 5.0)
	_check_equal("paused/choice delta adds no active time", float(paused["evaluationActiveTime"]), float(ten_steps["evaluationActiveTime"]))
	var burst := Evaluation.sample_state(initial, 0.1, 100.0, 5.0)
	burst = Evaluation.sample_state(burst, 9.9, 0.0, 1.0)
	var burst_result: Dictionary = Evaluation.calculate(burst)
	_check(int((burst_result["evaluationBreakdown"] as Dictionary)["hype"]) < 25, "one short buzz/voltage burst does not create max hype")
	var counted := Evaluation.add_dangerous_comment(Evaluation.add_gift(Evaluation.add_damage(initial, 12.0)))
	_check_equal("actual damage counted once", float(counted["evaluationCumulativeDamageTaken"]), 12.0)
	_check_equal("gift count increments once", int(counted["evaluationGiftCount"]), 1)
	_check_equal("danger count increments once", int(counted["evaluationDangerousCommentCount"]), 1)
	var ignored := initial.duplicate(true)
	_check_equal("ignored hit stays zero", float(ignored["evaluationCumulativeDamageTaken"]), 0.0)
	var damage_target := FakeDamageTarget.new()
	var hit := DamageSystem.apply_damage_for_target(damage_target, "test", 12)
	_check_equal("central damage path returns actual damage", int(hit.get("actualDamage", 0)), 12)
	_check_equal("central damage path records actual damage once", damage_target.evaluation_damage, 12)
	damage_target.invincible = 1.0
	var ignored_hit := DamageSystem.apply_damage_for_target(damage_target, "ignored", 12)
	_check_equal("invincible damage is ignored", int(ignored_hit.get("actualDamage", 0)), 0)
	_check_equal("ignored damage does not increment evaluation", damage_target.evaluation_damage, 12)
	damage_target.invincible = 0.0
	damage_target.player_hp = 5
	damage_target.revive_available = true
	var revive_hit := DamageSystem.apply_damage_for_target(damage_target, "lethal", 12)
	_check(bool(revive_hit.get("revived", false)), "lethal hit can still trigger revive")
	_check_equal("revive lethal hit remains counted", damage_target.evaluation_damage, 24)
	damage_target.queue_free()

func _check_boss_scoring() -> void:
	var normal := Evaluation.mark_target_boss(Evaluation.empty_state())
	normal = Evaluation.mark_target_boss(normal, true)
	var normal_result: Dictionary = Evaluation.calculate(_max_stats(false, false).merged(normal))
	_check_equal("normal target boss gives 2 plus 3", int((normal_result["evaluationBreakdown"] as Dictionary)["combat"]), 5)
	var relay := Evaluation.mark_relay_final_boss(Evaluation.empty_state(), true)
	var relay_stats := _max_stats(true, true)
	for key in relay.keys():
		relay_stats[key] = relay[key]
	var relay_result: Dictionary = Evaluation.calculate(relay_stats)
	_check_equal("relay final boss gives 2 plus 3", int((relay_result["evaluationBreakdown"] as Dictionary)["combat"]), 5)

func _check_reward_formulae() -> void:
	for difficulty_id in ["normal", "hard", "expert"]:
		var base35: Object = RewardCalculator.calculate({"rewardEligible": true, "outcome": "defeated", "isRelay": false, "activePlaySeconds": 90.0, "stageId": "talk", "stageCleared": false, "difficultyId": difficulty_id, "evaluationScore": 55, "evaluationRank": "B"})
		var expected35: int = int({"normal": 39, "hard": 46, "expert": 54}[difficulty_id])
		_check_equal("base35 %s example" % difficulty_id, int(base35.get("total_pp")), expected35)
		var base150: Object = RewardCalculator.calculate({"rewardEligible": true, "outcome": "completed", "isRelay": false, "activePlaySeconds": 180.0, "stageId": "talk", "stageCleared": true, "difficultyId": difficulty_id, "evaluationScore": 85, "evaluationRank": "S"}, {"talk": true})
		var expected150: int = int({"normal": 195, "hard": 234, "expert": 273}[difficulty_id])
		_check_equal("base150 %s example" % difficulty_id, int(base150.get("total_pp")), expected150)
		var relay960: Object = RewardCalculator.calculate({"rewardEligible": true, "outcome": "completed", "isRelay": true, "difficultyId": difficulty_id, "relayClearedFrameIds": ["a", "b", "c", "d", "e"], "relayFinalReached": true, "relayFinalDefeated": true, "evaluationScore": 85, "evaluationRank": "S"}, {}, {}, true)
		var expected960: int = int({"normal": 1248, "hard": 1498, "expert": 1747}[difficulty_id])
		_check_equal("relay960 %s example" % difficulty_id, int(relay960.get("total_pp")), expected960)
	var direct: Object = RewardCalculator.calculate({"rewardEligible": true, "outcome": "defeated", "isRelay": false, "activePlaySeconds": 90.0, "stageId": "talk", "stageCleared": false, "difficultyId": "hard", "evaluationScore": 55, "evaluationRank": "B", "fieldGiftPp": 10})
	_check_equal("direct PP is outside difficulty/evaluation multiplier", int(direct.get("total_pp")), 56)
	var duplicate_sensitive := RewardResult.new()
	duplicate_sensitive.participation_pp = 5
	duplicate_sensitive.boss_defeat_pp = 50
	duplicate_sensitive.difficulty_multiplier = 1.2
	duplicate_sensitive.evaluation_rank = "S"
	duplicate_sensitive.evaluation_bonus_rate = 0.3
	RewardCalculator.recalculate_totals(duplicate_sensitive)
	var before_duplicate := duplicate_sensitive.total_pp
	duplicate_sensitive.boss_defeat_pp = 0
	RewardCalculator.recalculate_totals(duplicate_sensitive)
	_check(before_duplicate > duplicate_sensitive.total_pp, "duplicate removal recomputes adjusted/evaluation totals")
	_check_equal("negative reward rows remain visible", ResultSystem.point_reward_display_rows({"participationPp": -3}, false).size(), 1)

func _check_retry_metadata() -> void:
	var target := FakeTarget.new()
	add_child(target)
	var result := {"endType": "completed", "cleared": true, "relayMode": true, "difficultyId": "normal", "stageId": "relay"}
	var first: Dictionary = ResultSystem._commit_power_up_reward(result, target)
	_check_equal("first retry commit reports save failure", String(first.get("state", "")), "save_failed")
	var pending: Dictionary = target.pending_power_up_reward as Dictionary
	_check(bool(pending.get("seniorUnitUnlockEligible", false)), "pending commit keeps senior unlock eligibility")
	var second: Dictionary = ResultSystem.retry_power_up_reward_for_target(target)
	_check(bool(second.get("ok", false)), "save retry grants pending reward")
	_check_equal("retry uses original run id", target.power_up_shop_manager.last_run_id, "retry-evaluation-run")
	_check(target.power_up_shop_manager.last_senior_flag, "retry forwards senior unlock eligibility")
	_check_equal("retry clears pending commit", target.pending_power_up_reward, null)
	_check_equal("retry only calls grant twice", target.power_up_shop_manager.grant_calls, 2)
	remove_child(target)
	target.queue_free()

func _check_ranking_versions() -> void:
	var legacy := Ranking.normalize_entry({"runId": "legacy", "modeId": "normal_180", "stageId": "talk", "score": 100, "kamiPoint": 220, "kamiRank": "S", "survivalTime": 100.0})
	var current := Ranking.normalize_entry({"runId": "current", "modeId": "normal_180", "stageId": "talk", "score": 100, "evaluationVersion": 2, "evaluationScore": 0, "evaluationRank": "D", "survivalTime": 200.0})
	_check_equal("missing evaluation version reads v1", int(legacy.get("evaluationVersion", 0)), 1)
	var mixed := Ranking._sort_entries([legacy, current])
	_check_equal("mixed versions skip evaluation tie break", String((mixed[0] as Dictionary).get("runId", "")), "current")
	var v2_low := {"runId": "v2-low", "modeId": "normal_180", "stageId": "talk", "score": 100, "evaluationVersion": 2, "evaluationScore": 40, "evaluationRank": "C", "survivalTime": 100.0}
	var v2_high := {"runId": "v2-high", "modeId": "normal_180", "stageId": "talk", "score": 100, "evaluationVersion": 2, "evaluationScore": 80, "evaluationRank": "A", "survivalTime": 100.0}
	var same_version := Ranking._sort_entries([v2_low, v2_high])
	_check_equal("same v2 compares evaluation score", String((same_version[0] as Dictionary).get("runId", "")), "v2-high")
	var relay_v1 := {"runId": "relay-v1", "modeId": "relay", "stageId": "relay", "score": 100, "clearedFrameCount": 5, "totalViewerCount": 100, "maxVoltage": 2.0, "kamiPoint": 220, "kamiRank": "S", "playedAt": "2026-08-01T00:00:00"}
	var relay_v2 := {"runId": "relay-v2", "modeId": "relay", "stageId": "relay", "score": 100, "clearedFrameCount": 5, "totalViewerCount": 100, "maxVoltage": 2.0, "evaluationVersion": 2, "evaluationScore": 0, "evaluationRank": "D", "playedAt": "2026-08-02T00:00:00"}
	var mixed_relay := Ranking._sort_relay_entries([relay_v1, relay_v2])
	_check_equal("relay mixed versions skip evaluation tie break", String((mixed_relay[0] as Dictionary).get("runId", "")), "relay-v2")
	var relay_v2_high := relay_v2.duplicate(true)
	relay_v2_high["runId"] = "relay-v2-high"
	relay_v2_high["evaluationScore"] = 90
	var same_relay := Ranking._sort_relay_entries([relay_v2, relay_v2_high])
	_check_equal("relay same v2 compares evaluation score", String((same_relay[0] as Dictionary).get("runId", "")), "relay-v2-high")
	var legacy_detail := Ranking._board_detail_view(legacy, 1)
	var current_detail := Ranking._board_detail_view(Ranking.normalize_entry({"runId": "v2-detail", "modeId": "normal_180", "stageId": "talk", "score": 1, "evaluationVersion": 2, "evaluationScore": 85, "evaluationRank": "S", "evaluationBreakdown": {"challenge": 20}}), 1)
	_check_equal("v1 detail is labeled old version", String((legacy_detail.get("evaluation", {}) as Dictionary).get("label", "")), "旧バージョンの記録")
	_check_equal("v2 detail shows evaluation", String((current_detail.get("evaluation", {}) as Dictionary).get("label", "")), "配信評価")
	var normal_entry := ResultSystem.build_ranking_entry({"evaluationVersion": 2, "evaluationScore": 70, "evaluationRank": "A", "streamFrameId": "singing", "streamFrameName": "Legacy English"})
	_check_equal("new ranking entry preserves v2 score alias", int(normal_entry.get("kamiPoint", 0)), 70)
	_check_equal("new ranking entry preserves v2 rank alias", String(normal_entry.get("kamiRank", "")), "A")
	_check_equal("new ranking entry canonicalizes frame name", String(normal_entry.get("streamFrameName", "")), "歌枠")
	var relay_entry := ResultSystem.build_relay_ranking_entry({"evaluationVersion": 2, "evaluationScore": 55, "evaluationRank": "B", "relayMode": true, "streamFrameId": "gameplay", "currentFrameName": "Legacy English"})
	_check_equal("relay ranking entry keeps Japanese display name", String(relay_entry.get("streamFrameName", "")), "配信リレー")
	_check_equal("relay ranking entry keeps reached frame detail", String(relay_entry.get("currentFrameName", "")), "ゲーム実況枠")

func _check_result_contract() -> void:
	var rows: Array = ResultSystem.evaluation_breakdown_rows({"evaluationRank": "A", "evaluationBreakdown": {"challenge": 10, "hype": 20, "stability": 16, "gifts": 5, "combat": 3, "completion": 0}})
	_check_equal("result evaluation has six rows plus total/rank", rows.size(), 8)
	_check_equal("result evaluation total", int((rows[6] as Dictionary).get("points", 0)), 54)
	_check_equal("game over completion is explicit zero", int((rows[5] as Dictionary).get("points", -1)), 0)
	var data := ResultSystem.build_result_data({"endType": "mental_breakdown", "evaluationVersion": 2, "evaluationScore": 54, "evaluationRank": "B", "evaluationBreakdown": {"completion": 0}, "relayMode": false})
	_check_equal("result data stores v2 version", int(data.get("evaluationVersion", 0)), 2)
	_check_equal("result data stores evaluation alias", int(data.get("evaluationScore", 0)), 54)
	_check_equal("result data kamiPoint aliases v2 score", int(data.get("kamiPoint", 0)), 54)
	_check_equal("result data kamiRank aliases v2 rank", String(data.get("kamiRank", "")), "B")
	_check_equal("result data rank aliases v2 rank", String(data.get("rank", "")), "B")
	_check_equal("relay result display name is canonical", ResultSystem.result_stream_frame_display_name({"relayMode": true, "streamFrameId": "gameplay", "streamFrameName": "GAMEPLAY"}), "配信リレー")
	_check_equal("normal result display name is canonical", ResultSystem.result_stream_frame_display_name({"relayMode": false, "streamFrameId": "collab", "streamFrameName": "English"}), "コラボ枠")

func _max_stats(relay: bool, cleared: bool) -> Dictionary:
	return {
		"relayMode": relay,
		"cleared": cleared,
		"isRelayCompleted": cleared if relay else false,
		"evaluationActiveTime": 180.0,
		"evaluationBuzzIntegral": 18000.0,
		"evaluationVoltageIntegral": 900.0,
		"evaluationCumulativeDamageTaken": 0.0,
		"evaluationReferenceMaxMental": 100.0,
		"evaluationDangerousCommentCount": 5 if not relay else 12,
		"evaluationGiftCount": 5 if not relay else 12,
		"evaluationTargetBossReached": true,
		"evaluationTargetBossDefeated": true,
		"evaluationRelayFinalBossReached": true,
		"evaluationRelayFinalBossDefeated": true
	}

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _check_equal(message: String, actual: Variant, expected: Variant) -> void:
	_check(actual == expected, "%s (got %s, expected %s)" % [message, str(actual), str(expected)])

func _check_approx(message: String, actual: float, expected: float) -> void:
	_check(is_equal_approx(actual, expected), "%s (got %.4f, expected %.4f)" % [message, actual, expected])
