class_name PlayerSystem
extends RefCounted

static func input_vector() -> Vector2:
	var input := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		input.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input.y += 1.0
	return input.normalized()

static func adjusted_input(input: Vector2, reverse_power: float, elapsed: float) -> Vector2:
	if reverse_power <= 0.0:
		return input
	if reverse_power >= 0.95:
		return input * -1.0
	if input != Vector2.ZERO:
		return input.rotated(sin(elapsed * 9.0) * 0.55)
	return input

static func friction(slide_power: float, active_genre_event: String, kusoge_resist_level: int) -> float:
	var value := 11.0
	if slide_power > 0.0:
		value = lerpf(7.0, 2.0, slide_power)
	if active_genre_event == "race":
		var resist: float = 0.35 * float(kusoge_resist_level)
		value = minf(value, 6.0 + resist)
	return value

static func speed_rate(move_slow_timer: float, active_genre_event: String) -> float:
	var value: float = 0.92 if move_slow_timer > 0.0 else 1.0
	if active_genre_event == "race":
		value *= 1.15
	return value

static func can_dash(no_dash_power: float, dash_cd: float) -> bool:
	return dash_cd <= 0.0 and no_dash_power < 0.95

static func dash_cooldown_rate(no_dash_power: float) -> float:
	return 2.0 if no_dash_power > 0.0 else 1.0

static func update_motion(context: Dictionary) -> Dictionary:
	var delta: float = float(context["delta"])
	var elapsed: float = float(context["elapsed"])
	var input: Vector2 = input_vector()
	var stop_timer_value: float = float(context["stopTimer"])
	if input.length() < 0.1:
		stop_timer_value += delta
	else:
		stop_timer_value = 0.0
	var stopped_damage: bool = false
	if bool(context["keepMoving"]) and stop_timer_value >= 1.0:
		stop_timer_value = 0.0
		stopped_damage = true

	input = adjusted_input(input, float(context["reversePower"]), elapsed)
	var friction_value: float = friction(float(context["slidePower"]), String(context["activeGenreEvent"]), int(context["kusogeResistLevel"]))
	var speed_rate_value: float = speed_rate(float(context["moveSlowTimer"]), String(context["activeGenreEvent"]))
	var player_vel: Vector2 = Vector2(context["playerVel"])
	var player_speed: float = float(context["playerSpeed"])
	player_vel = player_vel.lerp(input * player_speed * speed_rate_value, minf(1.0, delta * friction_value))

	var dash_cd_value: float = maxf(0.0, float(context["dashCd"]) - delta)
	var invincible_value: float = maxf(0.0, float(context["invincible"]) - delta)
	var no_dash_power: float = float(context["noDashPower"])
	if Input.is_key_pressed(KEY_SPACE) and can_dash(no_dash_power, dash_cd_value):
		var dash_dir: Vector2 = input
		if dash_dir == Vector2.ZERO:
			dash_dir = Vector2.RIGHT
		player_vel += dash_dir * 620.0
		dash_cd_value = float(context["dashCooldown"]) * dash_cooldown_rate(no_dash_power)

	var player_pos: Vector2 = Vector2(context["playerPos"]) + player_vel * delta
	var arena: Rect2 = context["arena"] as Rect2
	player_pos.x = clampf(player_pos.x, arena.position.x + 28.0, arena.end.x - 28.0)
	player_pos.y = clampf(player_pos.y, arena.position.y + 28.0, arena.end.y - 28.0)

	return {
		"playerPos": player_pos,
		"playerVel": player_vel,
		"dashCd": dash_cd_value,
		"invincible": invincible_value,
		"stopTimer": stop_timer_value,
		"stoppedDamage": stopped_damage
	}

static func update_for_target(target: Node, delta: float, arena: Rect2) -> Dictionary:
	var reverse_power: float = maxf(ModifierSystem.effect_rate_for_target(target, "reverse_control"), ModifierSystem.effect_rate_for_target(target, "takeback"))
	var slide_power: float = maxf(
		ModifierSystem.effect_rate_for_target(target, "banana_floor"),
		maxf(ModifierSystem.effect_rate_for_target(target, "no_brake"), ModifierSystem.effect_rate_for_target(target, "takeback"))
	)
	var no_dash_power: float = ModifierSystem.effect_rate_for_target(target, "no_dash")
	var result: Dictionary = update_motion({
		"delta": delta,
		"elapsed": target.get("elapsed"),
		"stopTimer": target.get("stop_timer"),
		"keepMoving": ModifierSystem.has_effect_for_target(target, "keep_moving"),
		"reversePower": reverse_power,
		"slidePower": slide_power,
		"moveSlowTimer": target.get("move_slow_timer"),
		"activeGenreEvent": target.get("active_genre_event"),
		"kusogeResistLevel": target.get("kusoge_resist_level"),
		"playerVel": target.get("player_vel"),
		"playerPos": target.get("player_pos"),
		"playerSpeed": target.get("player_speed"),
		"dashCd": target.get("dash_cd"),
		"invincible": target.get("invincible"),
		"noDashPower": no_dash_power,
		"dashCooldown": target.get("dash_cooldown"),
		"arena": arena
	})
	target.set("player_pos", Vector2(result["playerPos"]))
	target.set("player_vel", Vector2(result["playerVel"]))
	target.set("dash_cd", float(result["dashCd"]))
	target.set("invincible", float(result["invincible"]))
	target.set("stop_timer", float(result["stopTimer"]))
	return result
