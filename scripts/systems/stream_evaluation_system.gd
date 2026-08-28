class_name StreamEvaluationSystem
extends RefCounted

## Versioned, run-local evaluation rules.  This file intentionally has no
## dependency on GameScript so the score contract can be tested in isolation.
const EVALUATION_VERSION := 2
const RANK_ORDER := ["D", "C", "B", "A", "S"]
const RANK_RATES := {"S": 0.30, "A": 0.20, "B": 0.10, "C": 0.05, "D": 0.0}

static func empty_state(reference_max_mental: float = 1.0) -> Dictionary:
	return {
		"evaluationActiveTime": 0.0,
		"evaluationBuzzIntegral": 0.0,
		"evaluationVoltageIntegral": 0.0,
		"evaluationCumulativeDamageTaken": 0.0,
		"evaluationDangerousCommentCount": 0,
		"evaluationGiftCount": 0,
		"evaluationTargetBossReached": false,
		"evaluationTargetBossDefeated": false,
		"evaluationRelayFinalBossReached": false,
		"evaluationRelayFinalBossDefeated": false,
		"evaluationReferenceMaxMental": maxf(1.0, reference_max_mental)
	}

static func sample_state(state: Dictionary, sample_delta: float, burn_combo: float, voltage: float) -> Dictionary:
	var result := state.duplicate(true)
	var delta := maxf(0.0, sample_delta)
	if delta <= 0.0:
		return result
	result["evaluationActiveTime"] = float(result.get("evaluationActiveTime", 0.0)) + delta
	result["evaluationBuzzIntegral"] = float(result.get("evaluationBuzzIntegral", 0.0)) + clampf(burn_combo, 0.0, 100.0) * delta
	result["evaluationVoltageIntegral"] = float(result.get("evaluationVoltageIntegral", 0.0)) + clampf(voltage, 1.0, 5.0) * delta
	return result

static func add_damage(state: Dictionary, actual_damage: float) -> Dictionary:
	var result := state.duplicate(true)
	result["evaluationCumulativeDamageTaken"] = float(result.get("evaluationCumulativeDamageTaken", 0.0)) + maxf(0.0, actual_damage)
	return result

static func add_gift(state: Dictionary, amount: int = 1) -> Dictionary:
	var result := state.duplicate(true)
	result["evaluationGiftCount"] = maxi(0, int(result.get("evaluationGiftCount", 0)) + maxi(0, amount))
	return result

static func add_dangerous_comment(state: Dictionary, amount: int = 1) -> Dictionary:
	var result := state.duplicate(true)
	result["evaluationDangerousCommentCount"] = maxi(0, int(result.get("evaluationDangerousCommentCount", 0)) + maxi(0, amount))
	return result

static func mark_target_boss(state: Dictionary, defeated: bool = false) -> Dictionary:
	var result := state.duplicate(true)
	result["evaluationTargetBossReached"] = true
	if defeated:
		result["evaluationTargetBossDefeated"] = true
	return result

static func mark_relay_final_boss(state: Dictionary, defeated: bool = false) -> Dictionary:
	var result := state.duplicate(true)
	result["evaluationRelayFinalBossReached"] = true
	result["evaluationTargetBossReached"] = true
	if defeated:
		result["evaluationRelayFinalBossDefeated"] = true
		result["evaluationTargetBossDefeated"] = true
	return result

static func rank_for_score(score: int) -> String:
	var clamped := clampi(score, 0, 100)
	if clamped >= 85:
		return "S"
	if clamped >= 70:
		return "A"
	if clamped >= 55:
		return "B"
	if clamped >= 40:
		return "C"
	return "D"

static func rank_rate(rank: String) -> float:
	return float(RANK_RATES.get(rank.strip_edges().to_upper(), 0.0))

static func metrics_for_stats(stats: Dictionary) -> Dictionary:
	var relay := bool(stats.get("relayMode", false))
	var active_time := maxf(0.0, float(stats.get("evaluationActiveTime", stats.get("activeTime", 0.0))))
	var danger_count := maxi(0, int(stats.get("evaluationDangerousCommentCount", stats.get("dangerousCommentCount", stats.get("dangerCommentsChosen", 0)))))
	var gift_count := maxi(0, int(stats.get("evaluationGiftCount", stats.get("giftCount", stats.get("giftsTaken", 0)))))
	var buzz_integral := maxf(0.0, float(stats.get("evaluationBuzzIntegral", stats.get("buzzIntegral", 0.0))))
	var voltage_integral := maxf(0.0, float(stats.get("evaluationVoltageIntegral", stats.get("voltageIntegral", 0.0))))
	var average_buzz := clampf(buzz_integral / maxf(active_time, 1.0), 0.0, 100.0)
	var average_voltage := clampf(voltage_integral / maxf(active_time, 1.0), 1.0, 5.0)
	var normalized_voltage := clampf((average_voltage - 1.0) / 4.0, 0.0, 1.0)
	var cumulative_damage := maxf(0.0, float(stats.get("evaluationCumulativeDamageTaken", stats.get("cumulativeDamageTaken", 0.0))))
	var reference_mental := maxf(1.0, float(stats.get("evaluationReferenceMaxMental", stats.get("referenceMaxMental", 1.0))))
	return {
		"activeTime": active_time,
		"averageBuzz": average_buzz,
		"averageVoltage": average_voltage,
		"normalizedDamageRatio": (cumulative_damage / reference_mental) * (180.0 / maxf(active_time, 1.0)),
		"dangerousCommentCount": danger_count,
		"giftCount": gift_count,
		"normalizedVoltage": normalized_voltage,
		"relay": relay
	}

static func breakdown_for_stats(stats: Dictionary) -> Dictionary:
	var metrics := metrics_for_stats(stats)
	var relay := bool(metrics.get("relay", false))
	var danger_count := int(metrics.get("dangerousCommentCount", 0))
	var gift_count := int(metrics.get("giftCount", 0))
	var challenge_target := 12 if relay else 5
	var challenge := roundi(20.0 * minf(1.0, float(danger_count) / float(challenge_target)))
	var hype := roundi(15.0 * float(metrics.get("averageBuzz", 0.0)) / 100.0) + roundi(10.0 * float(metrics.get("normalizedVoltage", 0.0)))
	var damage_ratio := float(metrics.get("normalizedDamageRatio", 0.0))
	var stability := 0
	if damage_ratio <= 0.25:
		stability = 20
	elif damage_ratio <= 0.50:
		stability = 16
	elif damage_ratio <= 1.00:
		stability = 11
	elif damage_ratio <= 1.50:
		stability = 6
	elif damage_ratio <= 2.00:
		stability = 3
	var gift_target := 12 if relay else 5
	var gifts := roundi(10.0 * minf(1.0, float(gift_count) / float(gift_target)))
	var target_reached := bool(stats.get("evaluationRelayFinalBossReached", stats.get("relayFinalBossReached", false))) if relay else bool(stats.get("evaluationTargetBossReached", stats.get("targetBossReached", false)))
	var target_defeated := bool(stats.get("evaluationRelayFinalBossDefeated", stats.get("relayFinalBossDefeated", false))) if relay else bool(stats.get("evaluationTargetBossDefeated", stats.get("targetBossDefeated", false)))
	var combat := (2 if target_reached else 0) + (3 if target_defeated else 0)
	var completion := 20 if bool(stats.get("cleared", false)) or (relay and bool(stats.get("isRelayCompleted", false))) else 0
	return {
		"challenge": clampi(challenge, 0, 20),
		"hype": clampi(hype, 0, 25),
		"stability": clampi(stability, 0, 20),
		"gifts": clampi(gifts, 0, 10),
		"combat": clampi(combat, 0, 5),
		"completion": clampi(completion, 0, 20)
	}

static func calculate(stats: Dictionary) -> Dictionary:
	var breakdown := breakdown_for_stats(stats)
	var metrics := metrics_for_stats(stats)
	var score := 0
	for key in ["challenge", "hype", "stability", "gifts", "combat", "completion"]:
		score += int(breakdown.get(key, 0))
	score = clampi(score, 0, 100)
	var rank := rank_for_score(score)
	return {
		"evaluationVersion": EVALUATION_VERSION,
		"evaluationScore": score,
		"evaluationRank": rank,
		"evaluationBreakdown": breakdown,
		"evaluationMetrics": metrics,
		"averageBuzz": float(metrics.get("averageBuzz", 0.0)),
		"averageVoltage": float(metrics.get("averageVoltage", 1.0)),
		"normalizedDamageRatio": float(metrics.get("normalizedDamageRatio", 0.0)),
		"dangerousCommentCount": int(metrics.get("dangerousCommentCount", 0)),
		"giftCount": int(metrics.get("giftCount", 0)),
		"kamiPoint": score,
		"kamiRank": rank,
		"rank": rank
	}
