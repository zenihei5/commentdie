class_name PowerUpEffectProvider
extends RefCounted

const SnapshotScript := preload("res://scripts/systems/permanent_upgrade_snapshot.gd")

static func create_snapshot(profile: Dictionary, database, enabled: bool):
	var snapshot = SnapshotScript.new()
	var levels: Dictionary = profile.get("upgrades", {}) as Dictionary
	for upgrade in database.upgrades:
		var data: Dictionary = upgrade as Dictionary
		snapshot.total_upgrade_level += clampi(int(levels.get(String(data.get("id", "")), 0)), 0, int(data.get("maxLevel", 5)))
	snapshot.enabled = enabled
	if not enabled:
		return snapshot
	for upgrade in database.upgrades:
		var data: Dictionary = upgrade as Dictionary
		var id := String(data.get("id", ""))
		var level := clampi(int(levels.get(id, 0)), 0, int(data.get("maxLevel", 5)))
		var values: Array = data.get("values", []) as Array
		var value := float(values[level]) if level < values.size() else 0.0
		match id:
			"max_hp": snapshot.max_hp_bonus = value
			"attack_power": snapshot.attack_power_bonus = value
			"attack_area": snapshot.attack_area_multiplier = 1.0 + value
			"attack_interval": snapshot.attack_interval_multiplier = 1.0 - value
			"move_speed": snapshot.move_speed_bonus = value
			"damage_reduction": snapshot.damage_reduction = value
			"exp_gain": snapshot.exp_gain_bonus = value
			"pickup_range": snapshot.pickup_range_bonus = value
			"healing_power": snapshot.healing_power_bonus = value
			"buzz_keep": snapshot.initial_buzz_keep_charges = maxi(0, roundi(value))
			"gift_reroll": snapshot.initial_gift_reroll_count = maxi(0, roundi(value))
			"gift_luck":
				var luck: Dictionary = data.get("giftLuck", {}) as Dictionary
				var hits: Array = luck.get("hitWeightMultipliers", []) as Array
				var jackpots: Array = luck.get("jackpotWeightMultipliers", []) as Array
				snapshot.gift_hit_weight_multiplier = float(hits[level]) if level < hits.size() else 1.0
				snapshot.gift_jackpot_weight_multiplier = float(jackpots[level]) if level < jackpots.size() else 1.0
	return snapshot

static func max_hp(base_hp: int, snapshot, other_percent_bonus: float = 0.0, existing_flat_bonus: int = 0) -> int:
	return maxi(1, roundi(float(base_hp) * (1.0 + snapshot.max_hp_bonus + other_percent_bonus)) + existing_flat_bonus)

static func damage(base_damage: float, snapshot, other_percent_bonus: float = 0.0, temporary_multiplier: float = 1.0) -> float:
	return base_damage * (1.0 + snapshot.attack_power_bonus + other_percent_bonus) * temporary_multiplier

static func move_speed(base_speed: float, snapshot, other_percent_bonus: float = 0.0, temporary_multiplier: float = 1.0) -> float:
	return base_speed * (1.0 + snapshot.move_speed_bonus + other_percent_bonus) * temporary_multiplier

static func dash_speed(base_speed: float, snapshot) -> float:
	return base_speed * (1.0 + snapshot.move_speed_bonus)

static func constant_damage_taken(raw_damage: int, snapshot, other_reduction: float = 0.0) -> int:
	var reduction: float = clampf(float(snapshot.damage_reduction) + other_reduction, 0.0, 0.40)
	return maxi(1, roundi(float(raw_damage) * (1.0 - reduction)))

static func exp_amount(amount: int, snapshot) -> int:
	if amount <= 0:
		return 0
	var scaled: float = float(amount) * (1.0 + float(snapshot.exp_gain_bonus)) + float(snapshot.exp_remainder)
	var granted := floori(scaled)
	snapshot.exp_remainder = scaled - float(granted)
	return granted

static func normal_pickup_radius(base_radius: float, snapshot) -> float:
	return base_radius * (1.0 + snapshot.pickup_range_bonus)

static func normal_attract_radius(base_radius: float, snapshot) -> float:
	return base_radius * (1.0 + snapshot.pickup_range_bonus)

static func scaled_heal_amount(base_amount: int, snapshot, source_id: String) -> int:
	const SOURCES := ["gift_heal", "drop_heal", "marshmallow_heal", "regeneration", "equipment_heal", "song_note_heal", "drawing_green_heal", "boss_support_dont_lose"]
	if base_amount <= 0 or not SOURCES.has(source_id):
		return base_amount
	var bonus_pool: float = float(base_amount) * float(snapshot.healing_power_bonus) + float(snapshot.healing_remainder)
	var bonus := floori(bonus_pool)
	snapshot.healing_remainder = bonus_pool - float(bonus)
	return base_amount + bonus

static func gift_weights(normal_weight: float, hit_weight: float, jackpot_weight: float, snapshot) -> Dictionary:
	var adjusted_hit: float = hit_weight * float(snapshot.gift_hit_weight_multiplier)
	var adjusted_jackpot: float = jackpot_weight * float(snapshot.gift_jackpot_weight_multiplier)
	var total: float = normal_weight + adjusted_hit + adjusted_jackpot
	if total <= 0.0:
		return {"normal": 1.0, "hit": 0.0, "jackpot": 0.0}
	return {"normal": normal_weight / total, "hit": adjusted_hit / total, "jackpot": adjusted_jackpot / total}
