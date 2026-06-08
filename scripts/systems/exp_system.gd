class_name ExpSystem
extends RefCounted

const EXP_NEEDS := [5, 10, 18, 30, 45, 65, 90, 120, 155, 195]
const EXTRA_LEVEL_GROWTH_RATE := 1.18

static func current_need(level: int) -> int:
	var idx := maxi(0, level - 1)
	if idx < EXP_NEEDS.size():
		return int(EXP_NEEDS[idx])
	var need: int = int(EXP_NEEDS[EXP_NEEDS.size() - 1])
	for _i in range(EXP_NEEDS.size(), idx + 1):
		need = int(floor(float(need) * EXTRA_LEVEL_GROWTH_RATE))
	return need

static func drop_from_enemy_for_target(target: Node, enemy: Dictionary) -> void:
	var orbs: Array = target.get("exp_orbs") as Array
	var value: int = maxi(1, int(enemy.get("expValue", enemy.get("exp", 1))))
	orbs.append({
		"pos": Vector2(enemy["pos"]),
		"value": value,
		"visualType": visual_type_for_value(value),
		"life": 20.0
	})

static func visual_type_for_value(value: int) -> String:
	if value <= 1:
		return "small_blue"
	if value <= 3:
		return "medium_green"
	if value <= 6:
		return "large_red"
	return "gold_rainbow"

static func update_orbs(context: Dictionary) -> Dictionary:
	var orbs: Array = context["orbs"] as Array
	var player_pos: Vector2 = Vector2(context["playerPos"])
	var magnet_range: float = float(context["magnetRange"])
	var delta: float = float(context["delta"])
	var collected_exp: int = 0
	var collected_count: int = 0
	for orb_item in orbs:
		var orb: Dictionary = orb_item
		var pos: Vector2 = Vector2(orb["pos"])
		orb["life"] = float(orb["life"]) - delta
		if pos.distance_to(player_pos) <= magnet_range:
			pos = pos.lerp(player_pos, minf(1.0, delta * 7.5))
		orb["pos"] = pos
		if pos.distance_to(player_pos) < 24.0:
			orb["life"] = -1.0
			collected_count += 1
			collected_exp += int(orb["value"])
	return {
		"orbs": orbs.filter(func(o): return float(o["life"]) > 0.0),
		"collectedExp": collected_exp,
		"collectedCount": collected_count
	}

static func update_orbs_for_target(target: Node, delta: float) -> Dictionary:
	var result: Dictionary = update_orbs({
		"orbs": target.get("exp_orbs"),
		"playerPos": target.get("player_pos"),
		"magnetRange": target.get("magnet_range"),
		"delta": delta
	})
	target.set("exp_orbs", result["orbs"] as Array)
	var collected_count: int = int(result["collectedCount"])
	result["levelUp"] = false
	result["levelUps"] = 0
	if collected_count > 0:
		var bonus: int = ScoreSystem.exp_collect_bonus(int(target.get("like_score_level")), collected_count)
		target.set("score", int(target.get("score")) + bonus)
		var level_ups: int = add_exp_to_target(target, int(result["collectedExp"]))
		result["levelUps"] = level_ups
		result["levelUp"] = level_ups > 0
	return result

static func should_vacuum(enabled: bool, timer: float, delta: float) -> Dictionary:
	if not enabled:
		return {"timer": timer, "trigger": false}
	timer -= delta
	if timer > 0.0:
		return {"timer": timer, "trigger": false}
	return {"timer": 2.5, "trigger": true}

static func update_vacuum_for_target(target: Node, delta: float) -> bool:
	var result: Dictionary = should_vacuum(bool(target.get("exp_vacuum_extreme")), float(target.get("exp_vacuum_timer")), delta)
	target.set("exp_vacuum_timer", float(result["timer"]))
	if not bool(result["trigger"]):
		return false
	var orbs: Array = target.get("exp_orbs") as Array
	var player_pos: Vector2 = Vector2(target.get("player_pos"))
	for orb in orbs:
		orb["pos"] = player_pos
	return true

static func update_world_for_target(target: Node, delta: float) -> Dictionary:
	var result: Dictionary = update_orbs_for_target(target, delta)
	result["vacuumTriggered"] = update_vacuum_for_target(target, delta)
	return result

static func add_exp_to_target(target: Node, amount: int) -> int:
	target.set("exp_value", int(target.get("exp_value")) + amount)
	var level_ups := 0
	while int(target.get("exp_value")) >= current_need(int(target.get("exp_level"))):
		var need: int = current_need(int(target.get("exp_level")))
		target.set("exp_value", int(target.get("exp_value")) - need)
		target.set("exp_level", int(target.get("exp_level")) + 1)
		level_ups += 1
	return level_ups
