class_name RelayBreakSystem
extends RefCounted

const GiftSystemScript := preload("res://scripts/systems/gift_system.gd")
const WeaponEvolutionSystemScript := preload("res://scripts/systems/weapon_evolution_system.gd")

static func heal_preview(target: Node, config: Dictionary) -> Dictionary:
	var rate := float((config.get("break", {}) as Dictionary).get("healRate", 0.30))
	if bool(target.get("relay_mode")) and int(target.get("relay_break_count")) >= 5:
		rate = float((config.get("finalPreparation", {}) as Dictionary).get("healRate", 0.40))
	var max_hp := int(target.get("player_max_hp"))
	var current_hp := int(target.get("player_hp"))
	var amount := maxi(0, mini(max_hp - current_hp, maxi(0, int(floor(float(max_hp) * rate)))))
	return {"currentHp": current_hp, "maxHp": max_hp, "healAmount": amount, "afterHp": current_hp + amount}

static func build_gift_offer(target: Node, gifts: Array, rng: RandomNumberGenerator, config: Dictionary) -> Array:
	var source := "relay_final_preparation" if int(target.get("relay_break_count")) >= 5 else "relay_break"
	var request := GiftSystemScript.build_gift_request_for_target(target, source, "normal", true, false, true)
	var context := GiftSystemScript.build_offer_context_for_target(target, gifts, float(target.get("elapsed")), rng, request)
	var offer: Array = GiftSystemScript.build_offer(context)
	target.set("active_gift_request", request.duplicate(true))
	var guaranteed := false
	for item in offer:
		var gift: Dictionary = item as Dictionary
		if String(gift.get("type", gift.get("category", ""))) == "pp" or String(gift.get("category", "")) == "pp":
			continue
		if WeaponEvolutionSystemScript.is_evolution_gift(gift) or GiftSystemScript.gift_level_gain(gift) >= 2:
			guaranteed = true
			break
	if not guaranteed and offer.size() > 0:
		var replacement := GiftSystemScript.pick_gift_by_level_gain(context, 2, offer)
		if not replacement.is_empty() and not WeaponEvolutionSystemScript.is_evolution_gift(replacement) and String(replacement.get("type", replacement.get("category", ""))) != "pp":
			for index in range(offer.size() - 1, -1, -1):
				var current: Dictionary = offer[index] as Dictionary
				if WeaponEvolutionSystemScript.is_evolution_gift(current) or String(current.get("type", current.get("category", ""))) == "pp":
					continue
				offer[index] = replacement
				break
	var count := int((config.get("break", {}) as Dictionary).get("giftCandidateCount", 3))
	return offer.slice(0, count)
