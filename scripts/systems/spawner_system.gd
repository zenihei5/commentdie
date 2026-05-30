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
