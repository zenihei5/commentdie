class_name SpawnerSystem
extends RefCounted

static func spawn_step(context: Dictionary) -> Dictionary:
	var timer: float = float(context["spawnTimer"]) - float(context["delta"])
	if timer > 0.0:
		return {"spawnTimer": timer, "spawnCount": 0}

	var interval: float = float(context["baseInterval"])
	if int(context.get("marshmallowCount", 0)) > 0:
		interval *= 0.96

	var more_spawns: bool = bool(context.get("moreSpawns", false))
	var god_reservation: bool = bool(context.get("godReservation", false))
	var god_power: float = float(context.get("godReservationPower", 0.0))
	if more_spawns or god_reservation:
		var spawn_power: float = maxf(float(context.get("moreSpawnsPower", 0.0)), god_power)
		interval *= lerpf(0.82, 0.65, spawn_power)
	if bool(context.get("flameMarketing", false)):
		interval *= 0.8
	if float(context.get("spawnRateTimer", 0.0)) > 0.0:
		interval *= 0.9

	var count: int = 2 if (more_spawns or (god_reservation and god_power >= 0.95)) else 1
	return {"spawnTimer": interval, "spawnCount": count}

static func spawn_kinds(context: Dictionary) -> Dictionary:
	var base_interval: float = EnemySystem.spawn_interval({
		"elapsed": context["elapsed"],
		"quickTestMode": context["quickTestMode"]
	})
	var step: Dictionary = spawn_step({
		"spawnTimer": context["spawnTimer"],
		"delta": context["delta"],
		"baseInterval": base_interval,
		"marshmallowCount": context["marshmallowCount"],
		"moreSpawns": context["moreSpawns"],
		"moreSpawnsPower": context["moreSpawnsPower"],
		"godReservation": context["godReservation"],
		"godReservationPower": context["godReservationPower"],
		"flameMarketing": context["flameMarketing"],
		"spawnRateTimer": context["spawnRateTimer"]
	})
	var rng: RandomNumberGenerator = context["rng"] as RandomNumberGenerator
	var kinds: Array = []
	for i in range(int(step["spawnCount"])):
		kinds.append(EnemySystem.pick_wave_enemy(float(context["elapsed"]), bool(context["quickTestMode"]), rng))
	return {
		"spawnTimer": step["spawnTimer"],
		"kinds": kinds
	}

static func spawn_context_for_target(target: Node, delta: float, rng: RandomNumberGenerator) -> Dictionary:
	var marshmallows: Array = target.get("marshmallows") as Array
	return {
		"spawnTimer": target.get("spawn_timer"),
		"delta": delta,
		"elapsed": target.get("elapsed"),
		"quickTestMode": target.get("quick_test_mode"),
		"rng": rng,
		"marshmallowCount": marshmallows.size(),
		"moreSpawns": ModifierSystem.has_effect_for_target(target, "more_spawns"),
		"moreSpawnsPower": ModifierSystem.effect_rate_for_target(target, "more_spawns"),
		"godReservation": ModifierSystem.has_effect_for_target(target, "god_reservation"),
		"godReservationPower": ModifierSystem.effect_rate_for_target(target, "god_reservation"),
		"flameMarketing": target.get("flame_marketing"),
		"spawnRateTimer": target.get("spawn_rate_timer")
	}

static func update_for_target(target: Node, delta: float, arena: Rect2, rng: RandomNumberGenerator) -> Dictionary:
	var result: Dictionary = spawn_kinds(spawn_context_for_target(target, delta, rng))
	target.set("spawn_timer", float(result["spawnTimer"]))
	var kinds: Array = result["kinds"] as Array
	for item in kinds:
		EnemySystem.spawn_enemy_for_target(target, String(item), arena, rng)
	return result
