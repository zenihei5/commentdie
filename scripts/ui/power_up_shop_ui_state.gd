class_name PowerUpShopUiState
extends RefCounted

enum PurchaseState {
	PURCHASABLE,
	NOT_ENOUGH_PP,
	MAX_LEVEL,
}

enum UpgradeVisualTier {
	UNPURCHASED,
	LOW,
	HIGH,
	MAX,
}

enum MascotState {
	IDLE,
	PURCHASABLE,
	SHORTAGE,
	PURCHASE_SUCCESS,
	MAX_LEVEL,
}

static func mascot_state_for_purchase_state(state: int) -> int:
	match state:
		PurchaseState.MAX_LEVEL:
			return MascotState.MAX_LEVEL
		PurchaseState.NOT_ENOUGH_PP:
			return MascotState.SHORTAGE
		PurchaseState.PURCHASABLE:
			return MascotState.PURCHASABLE
		_:
			return MascotState.IDLE

static func visual_tier_for_level(level: int, max_level: int) -> int:
	if level >= max_level:
		return UpgradeVisualTier.MAX
	if level >= 3:
		return UpgradeVisualTier.HIGH
	if level >= 1:
		return UpgradeVisualTier.LOW
	return UpgradeVisualTier.UNPURCHASED

static func get_gift_luck_effect_text(upgrade: Dictionary, level: int, is_next_level: bool) -> String:
	var target_level: int = level + 1 if is_next_level else level
	var max_level: int = int(upgrade.get("maxLevel", 5))
	if not is_next_level and level <= 0:
		return "補正なし"
	if is_next_level and target_level > max_level:
		return "MAX"
	var luck: Dictionary = upgrade.get("giftLuck", {}) as Dictionary
	var hit_weights: Array = luck.get("hitWeightMultipliers", []) as Array
	var jackpot_weights: Array = luck.get("jackpotWeightMultipliers", []) as Array
	if hit_weights.is_empty() or jackpot_weights.is_empty():
		return "MAX" if is_next_level else "補正なし"
	var last_index: int = mini(hit_weights.size(), jackpot_weights.size()) - 1
	var index: int = clampi(target_level, 0, maxi(0, last_index))
	return "当たり ×%.2f\n大当たり ×%.2f" % [float(hit_weights[index]), float(jackpot_weights[index])]

static func get_standard_upgrade_effect_text(upgrade: Dictionary, level: int, is_next_level: bool) -> String:
	var target_level: int = level + 1 if is_next_level else level
	var max_level: int = int(upgrade.get("maxLevel", 5))
	if is_next_level and target_level > max_level:
		return "MAX"
	var values: Array = upgrade.get("values", []) as Array
	var value: Variant = values[clampi(target_level, 0, maxi(0, values.size() - 1))] if not values.is_empty() else 0.0
	return _format_effect(upgrade, target_level, value)

static func get_shop_effect_text(upgrade: Dictionary, level: int, is_next_level: bool) -> String:
	if String(upgrade.get("id", "")) == "gift_luck":
		return get_gift_luck_effect_text(upgrade, level, is_next_level)
	return get_standard_upgrade_effect_text(upgrade, level, is_next_level)

static func _format_effect(upgrade: Dictionary, level: int, value: Variant) -> String:
	var number: float = float(value)
	if is_zero_approx(number):
		return "なし"
	var summary: Dictionary = upgrade.get("cardSummary", {}) as Dictionary
	if String(summary.get("format", "")) == "count":
		return "%d回" % roundi(absf(number))
	var prefix: String = "-" if String(summary.get("format", "")) == "percent_down" or String(upgrade.get("id", "")) == "damage_reduction" else "+"
	return "%s%d%%" % [prefix, roundi(absf(number) * 100.0)]

static func _card_effect_summary(upgrade: Dictionary, level: int, max_level: int) -> String:
	var summary: Dictionary = upgrade.get("cardSummary", {}) as Dictionary
	if level <= 0:
		return String(summary.get("levelZero", upgrade.get("description", "")))
	if String(upgrade.get("id", "")) == "gift_luck":
		return String(summary.get("levelOnePlus", "当たり・大当たり率UP"))
	var value_label: String = String(summary.get("valueLabel", "効果"))
	var values: Array = upgrade.get("values", []) as Array
	var value: Variant = values[clampi(level, 0, maxi(0, values.size() - 1))] if not values.is_empty() else 0.0
	return "%s %s" % [value_label, _format_effect(upgrade, level, value)]

static func build(upgrade: Dictionary, level: int, points: int) -> Dictionary:
	var max_level: int = int(upgrade.get("maxLevel", 5))
	var maxed: bool = level >= max_level
	var prices: Array = upgrade.get("prices", []) as Array
	var price: int = int(prices[level]) if not maxed and level >= 0 and level < prices.size() else 0
	var shortage: int = maxi(0, price - points)
	var state: int = PurchaseState.MAX_LEVEL if maxed else (
		PurchaseState.NOT_ENOUGH_PP if shortage > 0 else PurchaseState.PURCHASABLE
	)
	var values: Array = upgrade.get("values", []) as Array
	var current_value: Variant = values[clampi(level, 0, maxi(0, values.size() - 1))] if not values.is_empty() else 0.0
	var next_value: Variant = values[clampi(level + 1, 0, maxi(0, values.size() - 1))] if not values.is_empty() else 0.0
	var current_effect: String = get_shop_effect_text(upgrade, level, false)
	var next_effect: String = get_shop_effect_text(upgrade, level, true)
	var card_price_text: String = "強化完了 MAX"
	if state == PurchaseState.PURCHASABLE:
		card_price_text = "次の強化 %d PP" % price
	elif state == PurchaseState.NOT_ENOUGH_PP:
		card_price_text = "必要 %d PP　あと%d PP" % [price, shortage]
	return {
		"id": String(upgrade.get("id", "")),
		"displayName": String(upgrade.get("displayName", upgrade.get("id", ""))),
		"category": String(upgrade.get("category", "combat")),
		"iconPath": String(upgrade.get("iconPath", "")),
		"description": String(upgrade.get("description", "")),
		"effectTags": (upgrade.get("effectTags", []) as Array).duplicate(),
		"state": state,
		"price": price,
		"shortage": shortage,
		"level": level,
		"maxLevel": max_level,
		"points": points,
		"visualTier": visual_tier_for_level(level, max_level),
		"visualStyle": (upgrade.get("visualStyle", {}) as Dictionary).duplicate(true),
		"mascotBaseState": mascot_state_for_purchase_state(state),
		"mascotMessageArgs": {"shortage": shortage},
		"effectLabel": String((upgrade.get("cardSummary", {}) as Dictionary).get("valueLabel", "効果")),
		"cardEffectSummary": _card_effect_summary(upgrade, level, max_level),
		"cardPriceText": card_price_text,
		"currentEffectText": current_effect,
		"nextEffectText": next_effect,
		"currentValue": current_value,
		"nextValue": next_value,
	}
