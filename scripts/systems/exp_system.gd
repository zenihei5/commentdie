class_name ExpSystem
extends RefCounted

const EXP_NEEDS := [5, 10, 18, 30, 45, 65, 90, 120, 155, 195]
const EXTRA_LEVEL_GROWTH_RATE := 1.18
const MAX_EXP_ORBS := 220
const EXP_ORB_MERGE_RADIUS := 56.0
const EXP_PICKUP_RADIUS := 24.0

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
	var pos := Vector2(enemy["pos"])
	if orbs.size() >= MAX_EXP_ORBS:
		_merge_exp_drop(orbs, pos, value)
		return
	orbs.append({
		"pos": pos,
		"value": value,
		"visualType": visual_type_for_value(value),
		"life": 20.0
	})

static func _merge_exp_drop(orbs: Array, pos: Vector2, value: int) -> void:
	var best_index := -1
	var best_distance := INF
	var oldest_index := 0
	var oldest_life := INF
	var merge_radius_sq := EXP_ORB_MERGE_RADIUS * EXP_ORB_MERGE_RADIUS
	for i in range(orbs.size()):
		var orb: Dictionary = orbs[i]
		var orb_life := float(orb.get("life", 0.0))
		if orb_life < oldest_life:
			oldest_life = orb_life
			oldest_index = i
		var distance_sq := Vector2(orb.get("pos", pos)).distance_squared_to(pos)
		if distance_sq < best_distance and distance_sq <= merge_radius_sq:
			best_distance = distance_sq
			best_index = i
	if best_index < 0:
		best_index = oldest_index
	var target_orb: Dictionary = orbs[best_index]
	var merged_value := int(target_orb.get("value", 1)) + value
	target_orb["value"] = merged_value
	target_orb["visualType"] = visual_type_for_value(merged_value)
	target_orb["life"] = maxf(float(target_orb.get("life", 0.0)), 12.0)
	target_orb["pos"] = Vector2(target_orb.get("pos", pos)).lerp(pos, 0.35)

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
	var magnet_range_sq := magnet_range * magnet_range
	var pickup_radius_sq := EXP_PICKUP_RADIUS * EXP_PICKUP_RADIUS
	var magnet_speed_rate: float = maxf(0.1, float(context.get("magnetSpeedRate", 1.0)))
	var delta: float = float(context["delta"])
	var collected_exp: int = 0
	var collected_count: int = 0
	var attracted_count: int = 0
	var kept_orbs: Array = []
	for orb_item in orbs:
		var orb: Dictionary = orb_item
		var pos: Vector2 = Vector2(orb["pos"])
		var life := float(orb["life"]) - delta
		if life <= 0.0:
			continue
		orb["life"] = life
		if pos.distance_squared_to(player_pos) <= magnet_range_sq:
			attracted_count += 1
			pos = pos.lerp(player_pos, minf(1.0, delta * 7.5 * magnet_speed_rate))
		orb["pos"] = pos
		if pos.distance_squared_to(player_pos) < pickup_radius_sq:
			collected_count += 1
			collected_exp += int(orb["value"])
			continue
		kept_orbs.append(orb)
	return {
		"orbs": kept_orbs,
		"collectedExp": collected_exp,
		"collectedCount": collected_count,
		"attractedCount": attracted_count
	}

static func update_orbs_for_target(target: Node, delta: float) -> Dictionary:
	var result: Dictionary = update_orbs({
		"orbs": target.get("exp_orbs"),
		"playerPos": target.get("player_pos"),
		"magnetRange": target.get("magnet_range"),
		"magnetSpeedRate": target.get("item_magnet_speed_rate"),
		"delta": delta
	})
	target.set("exp_orbs", result["orbs"] as Array)
	if int(result.get("attractedCount", 0)) > 0:
		_append_comment_radar_fx_for_target(target)
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
	var adjusted_amount: int = _exp_amount_with_notification_bonus_for_target(target, amount)
	target.set("exp_value", int(target.get("exp_value")) + adjusted_amount)
	var level_ups := 0
	while int(target.get("exp_value")) >= current_need(int(target.get("exp_level"))):
		var need: int = current_need(int(target.get("exp_level")))
		target.set("exp_value", int(target.get("exp_value")) - need)
		target.set("exp_level", int(target.get("exp_level")) + 1)
		level_ups += 1
	return level_ups

static func _exp_amount_with_notification_bonus_for_target(target: Node, amount: int) -> int:
	if amount <= 0:
		return 0
	var level: int = int(target.get("notification_bell_level"))
	if level <= 0:
		return amount
	var bonus_pool: float = float(amount) * GiftSystem.notification_bell_exp_rate(level) + float(target.get("exp_bonus_remainder"))
	var bonus: int = int(floor(bonus_pool))
	target.set("exp_bonus_remainder", bonus_pool - float(bonus))
	if bonus > 0:
		_append_notification_bell_fx_for_target(target, bonus)
	return amount + bonus

static func _append_notification_bell_fx_for_target(target: Node, bonus: int) -> void:
	var hit_fx: Array = target.get("hit_fx") as Array
	hit_fx.append({
		"kind": "notification_bell",
		"pos": Vector2(target.get("player_pos")) + Vector2(26.0, -46.0),
		"life": 0.46,
		"maxLife": 0.46,
		"bonus": bonus
	})

static func _append_comment_radar_fx_for_target(target: Node) -> void:
	if int(target.get("comment_radar_level")) <= 0:
		return
	if float(target.get("comment_radar_fx_timer")) > 0.0:
		return
	var hit_fx: Array = target.get("hit_fx") as Array
	hit_fx.append({
		"kind": "comment_radar_ping",
		"pos": Vector2(target.get("player_pos")),
		"life": 0.38,
		"maxLife": 0.38,
		"radius": float(target.get("magnet_range"))
	})
	target.set("comment_radar_fx_timer", GiftSystem.COMMENT_RADAR_FX_COOLDOWN)
