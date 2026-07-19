class_name RelayBreakSystem
extends RefCounted

const GiftSystemScript := preload("res://scripts/systems/gift_system.gd")
const WeaponEvolutionSystemScript := preload("res://scripts/systems/weapon_evolution_system.gd")

static func heal_preview(target: Node, config: Dictionary) -> Dictionary:
	var rate := float((config.get("break", {}) as Dictionary).get("healRate", 0.30))
	var max_hp := int(target.get("player_max_hp"))
	var current_hp := int(target.get("player_hp"))
	var amount := maxi(0, mini(max_hp - current_hp, maxi(0, int(floor(float(max_hp) * rate)))))
	return {"currentHp": current_hp, "maxHp": max_hp, "healAmount": amount, "afterHp": current_hp + amount}

static func build_gift_offer(target: Node, gifts: Array, rng: RandomNumberGenerator, config: Dictionary) -> Array:
	var context := GiftSystemScript.build_offer_context_for_target(target, gifts, float(target.get("elapsed")), rng)
	var offer: Array = GiftSystemScript.build_offer(context)
	var guaranteed := false
	for item in offer:
		var gift: Dictionary = item as Dictionary
		if WeaponEvolutionSystemScript.is_evolution_gift(gift) or GiftSystemScript.gift_level_gain(gift) >= 2:
			guaranteed = true
			break
	if not guaranteed and offer.size() > 0:
		var replacement := GiftSystemScript.pick_gift_by_level_gain(context, 2, offer)
		if not replacement.is_empty():
			offer[offer.size() - 1] = replacement
	var count := int((config.get("break", {}) as Dictionary).get("giftCandidateCount", 3))
	return offer.slice(0, count)
