class_name PermanentUpgradeSnapshot
extends RefCounted

const SnapshotScript := preload("res://scripts/systems/permanent_upgrade_snapshot.gd")

var enabled := false
var max_hp_bonus := 0.0
var attack_power_bonus := 0.0
var attack_area_multiplier := 1.0
var attack_interval_multiplier := 1.0
var move_speed_bonus := 0.0
var damage_reduction := 0.0
var exp_gain_bonus := 0.0
var pickup_range_bonus := 0.0
var healing_power_bonus := 0.0
var initial_buzz_keep_charges := 0
var initial_gift_reroll_count := 0
var gift_hit_weight_multiplier := 1.0
var gift_jackpot_weight_multiplier := 1.0
var total_upgrade_level := 0
var exp_remainder := 0.0
var healing_remainder := 0.0

func copy_snapshot():
	var result = SnapshotScript.new()
	result.enabled = enabled
	result.max_hp_bonus = max_hp_bonus
	result.attack_power_bonus = attack_power_bonus
	result.attack_area_multiplier = attack_area_multiplier
	result.attack_interval_multiplier = attack_interval_multiplier
	result.move_speed_bonus = move_speed_bonus
	result.damage_reduction = damage_reduction
	result.exp_gain_bonus = exp_gain_bonus
	result.pickup_range_bonus = pickup_range_bonus
	result.healing_power_bonus = healing_power_bonus
	result.initial_buzz_keep_charges = initial_buzz_keep_charges
	result.initial_gift_reroll_count = initial_gift_reroll_count
	result.gift_hit_weight_multiplier = gift_hit_weight_multiplier
	result.gift_jackpot_weight_multiplier = gift_jackpot_weight_multiplier
	result.total_upgrade_level = total_upgrade_level
	result.exp_remainder = exp_remainder
	result.healing_remainder = healing_remainder
	return result

func to_dictionary() -> Dictionary:
	return {
		"enabled": enabled,
		"maxHpBonus": max_hp_bonus,
		"attackPowerBonus": attack_power_bonus,
		"attackAreaMultiplier": attack_area_multiplier,
		"attackIntervalMultiplier": attack_interval_multiplier,
		"moveSpeedBonus": move_speed_bonus,
		"damageReduction": damage_reduction,
		"expGainBonus": exp_gain_bonus,
		"pickupRangeBonus": pickup_range_bonus,
		"healingPowerBonus": healing_power_bonus,
		"initialBuzzKeepCharges": initial_buzz_keep_charges,
		"initialGiftRerollCount": initial_gift_reroll_count,
		"giftHitWeightMultiplier": gift_hit_weight_multiplier,
		"giftJackpotWeightMultiplier": gift_jackpot_weight_multiplier,
		"totalUpgradeLevel": total_upgrade_level
	}
