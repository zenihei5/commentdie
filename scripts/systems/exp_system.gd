class_name ExpSystem
extends RefCounted

const EXP_NEEDS := [6, 13, 23, 36]

static func current_need(level: int) -> int:
	var idx := clampi(level - 1, 0, EXP_NEEDS.size() - 1)
	return int(EXP_NEEDS[idx])

static func drop_from_enemy_for_target(target: Node, enemy: Dictionary) -> void:
	var orbs: Array = target.get("exp_orbs") as Array
	orbs.append({"pos": Vector2(enemy["pos"]), "value": int(enemy["exp"]), "life": 20.0})

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
	if collected_count > 0:
		var bonus: int = ScoreSystem.exp_collect_bonus(int(target.get("like_score_level")), collected_count)
		target.set("score", int(target.get("score")) + bonus)
		result["levelUp"] = add_exp_to_target(target, int(result["collectedExp"]))
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

static func add_exp_to_target(target: Node, amount: int) -> bool:
	target.set("exp_value", int(target.get("exp_value")) + amount)
	var need: int = current_need(int(target.get("exp_level")))
	if int(target.get("exp_value")) < need:
		return false
	target.set("exp_value", int(target.get("exp_value")) - need)
	target.set("exp_level", int(target.get("exp_level")) + 1)
	return true
