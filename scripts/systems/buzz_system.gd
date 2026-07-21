class_name BuzzSystem
extends RefCounted

const MIN_PERCENT := 0
const MAX_PERCENT := 100
const DAMAGE_LOSS_PERCENT := 5
const HIGH_BUZZ_THRESHOLD := 80

static func clamp_percent(value: int) -> int:
	return clampi(value, MIN_PERCENT, MAX_PERCENT)

static func gain_for_risk(risk: int) -> int:
	if risk >= 4:
		return 20
	if risk >= 2:
		return 10
	return 5

static func score_multiplier(value: int) -> float:
	return clampf(1.0 + float(clamp_percent(value)) / 100.0, 1.0, 2.0)

static func result_points(max_value: int) -> int:
	return mini(50, maxi(0, roundi(float(clamp_percent(max_value)) * 0.5)))

static func is_high(value: int) -> bool:
	return clamp_percent(value) >= HIGH_BUZZ_THRESHOLD

static func instruction_transition(current: int, previous_max: int, risk: int) -> Dictionary:
	var before := clamp_percent(current)
	var requested_gain := gain_for_risk(risk)
	var after := clamp_percent(before + requested_gain)
	var maximum := maxi(clamp_percent(previous_max), after)
	return {"buzzBefore": before, "buzzAfter": after, "buzzDelta": after - before, "buzzGainRequested": requested_gain, "buzzChanged": after != before, "buzzReachedMax": before < MAX_PERCENT and after == MAX_PERCENT, "burnComboMax": maximum}

static func damage_transition(current: int, protection_charges: int, formal_damage: bool = true) -> Dictionary:
	var before := clamp_percent(current)
	var charges := maxi(0, protection_charges)
	if not formal_damage or before <= MIN_PERCENT:
		return {"buzzBefore": before, "buzzAfter": before, "buzzDelta": 0, "buzzChanged": false, "buzzProtected": false, "buzzProtectionConsumed": false, "burnResistChargesAfter": charges}
	if charges > 0:
		return {"buzzBefore": before, "buzzAfter": before, "buzzDelta": 0, "buzzChanged": false, "buzzProtected": true, "buzzProtectionConsumed": true, "burnResistChargesAfter": charges - 1}
	var after := clamp_percent(before - DAMAGE_LOSS_PERCENT)
	return {"buzzBefore": before, "buzzAfter": after, "buzzDelta": after - before, "buzzChanged": after != before, "buzzProtected": false, "buzzProtectionConsumed": false, "burnResistChargesAfter": charges}
