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

static func friction(banana_power: float, no_brake_power: float, input: Vector2, player_vel: Vector2, active_genre_event: String, kusoge_resist_level: int) -> float:
	var value := 11.0
	if banana_power > 0.0:
		value = lerpf(value, 3.4, banana_power)
	if no_brake_power > 0.0:
		var braking: bool = input.length() < 0.1
		if input.length() >= 0.1 and player_vel.length() >= 20.0:
			braking = input.dot(player_vel.normalized()) < -0.35
		if braking:
			value = minf(value, lerpf(11.0, 0.85, no_brake_power))
		else:
			value = minf(value, lerpf(11.0, 5.8, no_brake_power))
	if active_genre_event == "race":
		var resist: float = 0.35 * float(kusoge_resist_level)
		value = minf(value, 6.0 + resist)
	return value

static func speed_rate(move_slow_timer: float, active_genre_event: String, banana_power: float, no_brake_power: float, field_slow_rate: float = 0.0) -> float:
	var value: float = 0.92 if move_slow_timer > 0.0 else 1.0
	if field_slow_rate > 0.0:
		value *= 1.0 - clampf(field_slow_rate, 0.0, 0.85)
	if banana_power > 0.0:
		value *= lerpf(1.0, 0.96, banana_power)
	if no_brake_power > 0.0:
		value *= lerpf(1.0, 1.08, no_brake_power)
	if active_genre_event == "race":
		value *= 1.15
	return value

static func no_brake_sliding(no_brake_power: float, input: Vector2, player_vel: Vector2) -> bool:
	if no_brake_power <= 0.0 or player_vel.length() < 82.0:
		return false
	if input.length() < 0.1:
		return true
	return input.dot(player_vel.normalized()) < -0.35

static func banana_input(input: Vector2, banana_power: float, elapsed: float) -> Vector2:
	if banana_power <= 0.0 or input.length() < 0.1:
		return input
	return input.rotated(sin(elapsed * 7.0) * 0.28 * banana_power)

static func banana_floor_drift(player_vel: Vector2, banana_power: float, elapsed: float, player_pos: Vector2, delta: float) -> Vector2:
	if banana_power <= 0.0 or player_vel.length() < 38.0:
		return player_vel
	var dir: Vector2 = player_vel.normalized()
	var side: Vector2 = Vector2(-dir.y, dir.x)
	var wave: float = sin(elapsed * 9.0 + player_pos.x * 0.025 + player_pos.y * 0.017)
	return player_vel + side * wave * 118.0 * banana_power * delta

static func can_dash(no_dash_power: float, dash_cd: float) -> bool:
	return dash_cd <= 0.0 and no_dash_power < 0.95

static func dash_cooldown_rate(no_dash_power: float) -> float:
	return 2.0 if no_dash_power > 0.0 else 1.0

static func dash_tap_dirs(context: Dictionary) -> Array[Vector2]:
	var left_down: bool = Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT)
	var right_down: bool = Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)
	var up_down: bool = Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)
	var down_down: bool = Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)
	var dirs: Array[Vector2] = []
	if left_down and not bool(context.get("dashLeftDown", false)):
		dirs.append(Vector2.LEFT)
	if right_down and not bool(context.get("dashRightDown", false)):
		dirs.append(Vector2.RIGHT)
	if up_down and not bool(context.get("dashUpDown", false)):
		dirs.append(Vector2.UP)
	if down_down and not bool(context.get("dashDownDown", false)):
		dirs.append(Vector2.DOWN)
	context["dashLeftDown"] = left_down
	context["dashRightDown"] = right_down
	context["dashUpDown"] = up_down
	context["dashDownDown"] = down_down
	return dirs

static func dash_tap_result(context: Dictionary, delta: float, elapsed: float, reverse_power: float) -> Dictionary:
	var tap_window := 0.28
	var last_dir: Vector2 = Vector2(context.get("dashTapLastDir", Vector2.ZERO))
	var timer: float = maxf(0.0, float(context.get("dashTapTimer", 0.0)) - delta)
	var dash_dir: Vector2 = Vector2.ZERO
	for raw_dir in dash_tap_dirs(context):
		var dir: Vector2 = raw_dir
		if last_dir == raw_dir and timer > 0.0:
			dash_dir = adjusted_input(dir, reverse_power, elapsed)
			timer = 0.0
			last_dir = Vector2.ZERO
			break
		last_dir = raw_dir
		timer = tap_window
	return {
		"dashDir": dash_dir,
		"dashTapTimer": timer,
		"dashTapLastDir": last_dir,
		"dashLeftDown": bool(context["dashLeftDown"]),
		"dashRightDown": bool(context["dashRightDown"]),
		"dashUpDown": bool(context["dashUpDown"]),
		"dashDownDown": bool(context["dashDownDown"])
	}

static func dash_button_result(context: Dictionary, input: Vector2) -> Dictionary:
	var button_down: bool = Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_SPACE)
	var dash_dir: Vector2 = Vector2.ZERO
	if button_down and not bool(context.get("dashEnterDown", false)):
		if input.length() >= 0.1:
			dash_dir = input
		else:
			var facing_x: float = float(context.get("playerFacingX", 1.0))
			dash_dir = Vector2.LEFT if facing_x < 0.0 else Vector2.RIGHT
	context["dashEnterDown"] = button_down
	return {
		"dashDir": dash_dir,
		"dashEnterDown": button_down
	}

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
	var banana_power: float = float(context["bananaPower"])
	var no_brake_power: float = float(context["noBrakePower"])
	input = banana_input(input, banana_power, elapsed)
	var player_vel: Vector2 = Vector2(context["playerVel"])
	var no_brake_sliding_value: bool = no_brake_sliding(no_brake_power, input, player_vel)
	var player_speed: float = float(context["playerSpeed"])
	var friction_value: float = friction(banana_power, no_brake_power, input, player_vel, String(context["activeGenreEvent"]), int(context["kusogeResistLevel"]))
	var speed_rate_value: float = speed_rate(float(context["moveSlowTimer"]), String(context["activeGenreEvent"]), banana_power, no_brake_power, float(context.get("fieldSlowRate", 0.0)))
	player_vel = player_vel.lerp(input * player_speed * speed_rate_value, minf(1.0, delta * friction_value))
	player_vel = banana_floor_drift(player_vel, banana_power, elapsed, Vector2(context["playerPos"]), delta)

	var dash_cd_value: float = maxf(0.0, float(context["dashCd"]) - delta)
	var invincible_value: float = maxf(0.0, float(context["invincible"]) - delta)
	var no_dash_power: float = float(context["noDashPower"])
	var tap_result: Dictionary = dash_tap_result(context, delta, elapsed, float(context["reversePower"]))
	var dash_dir: Vector2 = Vector2(tap_result["dashDir"])
	var button_result: Dictionary = dash_button_result(context, input)
	if dash_dir.length() < 0.1:
		dash_dir = Vector2(button_result["dashDir"])
	if dash_dir.length() >= 0.1 and can_dash(no_dash_power, dash_cd_value):
		dash_dir = dash_dir.normalized()
		player_vel += dash_dir * 760.0
		dash_cd_value = float(context["dashCooldown"]) * dash_cooldown_rate(no_dash_power)

	var previous_pos: Vector2 = Vector2(context["playerPos"])
	var player_pos: Vector2 = previous_pos + player_vel * delta
	var arena: Rect2 = context["arena"] as Rect2
	player_pos.x = clampf(player_pos.x, arena.position.x + 28.0, arena.end.x - 28.0)
	player_pos.y = clampf(player_pos.y, arena.position.y + 28.0, arena.end.y - 28.0)
	var effect_wall_list: Array = context["effectWalls"] as Array if context.has("effectWalls") else []
	player_pos = resolve_wall_collision(player_pos, previous_pos, 24.0, effect_wall_list, String(context["streamFrameId"]))

	return {
		"playerPos": player_pos,
		"playerVel": player_vel,
		"dashCd": dash_cd_value,
		"dashTapTimer": float(tap_result["dashTapTimer"]),
		"dashTapLastDir": Vector2(tap_result["dashTapLastDir"]),
		"dashLeftDown": bool(tap_result["dashLeftDown"]),
		"dashRightDown": bool(tap_result["dashRightDown"]),
		"dashUpDown": bool(tap_result["dashUpDown"]),
		"dashDownDown": bool(tap_result["dashDownDown"]),
		"dashEnterDown": bool(button_result["dashEnterDown"]),
		"invincible": invincible_value,
		"stopTimer": stop_timer_value,
		"stoppedDamage": stopped_damage,
		"noBrakeSliding": no_brake_sliding_value
	}

static func resolve_wall_collision(pos: Vector2, previous_pos: Vector2, radius: float, effect_walls: Array, stream_frame_id: String = "zatsudan") -> Vector2:
	var walls: Array = DrawDataSystem.static_wall_rects(stream_frame_id)
	for effect_wall in effect_walls:
		walls.append(effect_wall as Rect2)
	var resolved: Vector2 = pos
	for wall_item in walls:
		var wall: Rect2 = wall_item as Rect2
		var grown: Rect2 = wall.grow(radius)
		if not grown.has_point(resolved):
			continue
		if previous_pos.x <= wall.position.x:
			resolved.x = wall.position.x - radius
		elif previous_pos.x >= wall.end.x:
			resolved.x = wall.end.x + radius
		elif previous_pos.y <= wall.position.y:
			resolved.y = wall.position.y - radius
		elif previous_pos.y >= wall.end.y:
			resolved.y = wall.end.y + radius
		else:
			var left_push: float = absf(resolved.x - grown.position.x)
			var right_push: float = absf(grown.end.x - resolved.x)
			var top_push: float = absf(resolved.y - grown.position.y)
			var bottom_push: float = absf(grown.end.y - resolved.y)
			var min_push: float = minf(minf(left_push, right_push), minf(top_push, bottom_push))
			if min_push == left_push:
				resolved.x = grown.position.x
			elif min_push == right_push:
				resolved.x = grown.end.x
			elif min_push == top_push:
				resolved.y = grown.position.y
			else:
				resolved.y = grown.end.y
	return resolved

static func boss_field_slow_rate(player_pos: Vector2, fields: Array) -> float:
	var value: float = 0.0
	for item in fields:
		var field: Dictionary = item as Dictionary
		if float(field.get("life", 0.0)) <= 0.0:
			continue
		if player_pos.distance_to(Vector2(field.get("pos", Vector2.ZERO))) <= float(field.get("radius", 0.0)) + 18.0:
			value = maxf(value, float(field.get("slowRate", 0.0)))
	return clampf(value, 0.0, 0.85)

static func update_for_target(target: Node, delta: float, arena: Rect2) -> Dictionary:
	var reverse_power: float = maxf(ModifierSystem.effect_rate_for_target(target, "reverse_control"), ModifierSystem.effect_rate_for_target(target, "takeback"))
	var banana_power: float = ModifierSystem.effect_rate_for_target(target, "banana_floor")
	var no_brake_power: float = maxf(ModifierSystem.effect_rate_for_target(target, "no_brake"), ModifierSystem.effect_rate_for_target(target, "takeback"))
	var no_dash_power: float = ModifierSystem.effect_rate_for_target(target, "no_dash")
	var result: Dictionary = update_motion({
		"delta": delta,
		"elapsed": target.get("elapsed"),
		"stopTimer": target.get("stop_timer"),
		"keepMoving": ModifierSystem.has_effect_for_target(target, "keep_moving"),
		"reversePower": reverse_power,
		"bananaPower": banana_power,
		"noBrakePower": no_brake_power,
		"moveSlowTimer": target.get("move_slow_timer"),
		"fieldSlowRate": boss_field_slow_rate(Vector2(target.get("player_pos")), target.get("boss_slow_fields") as Array),
		"activeGenreEvent": target.get("active_genre_event"),
		"kusogeResistLevel": target.get("kusoge_resist_level"),
		"playerVel": target.get("player_vel"),
		"playerPos": target.get("player_pos"),
		"playerSpeed": target.get("player_speed"),
		"playerFacingX": target.get("player_facing_x"),
		"dashCd": target.get("dash_cd"),
		"dashTapTimer": target.get("dash_tap_timer"),
		"dashTapLastDir": target.get("dash_tap_last_dir"),
		"dashLeftDown": target.get("dash_left_down"),
		"dashRightDown": target.get("dash_right_down"),
		"dashUpDown": target.get("dash_up_down"),
		"dashDownDown": target.get("dash_down_down"),
		"dashEnterDown": target.get("dash_enter_down"),
		"invincible": target.get("invincible"),
		"noDashPower": no_dash_power,
		"dashCooldown": target.get("dash_cooldown"),
		"arena": arena,
		"effectWalls": target.get("effect_walls"),
		"streamFrameId": target.get("current_stream_frame_id")
	})
	target.set("player_pos", Vector2(result["playerPos"]))
	target.set("player_vel", Vector2(result["playerVel"]))
	var new_velocity: Vector2 = Vector2(result["playerVel"])
	if absf(new_velocity.x) > 18.0:
		target.set("player_facing_x", -1.0 if new_velocity.x < 0.0 else 1.0)
	target.set("dash_cd", float(result["dashCd"]))
	target.set("dash_tap_timer", float(result["dashTapTimer"]))
	target.set("dash_tap_last_dir", Vector2(result["dashTapLastDir"]))
	target.set("dash_left_down", bool(result["dashLeftDown"]))
	target.set("dash_right_down", bool(result["dashRightDown"]))
	target.set("dash_up_down", bool(result["dashUpDown"]))
	target.set("dash_down_down", bool(result["dashDownDown"]))
	target.set("dash_enter_down", bool(result["dashEnterDown"]))
	target.set("invincible", float(result["invincible"]))
	target.set("stop_timer", float(result["stopTimer"]))
	target.set("player_no_brake_sliding", bool(result["noBrakeSliding"]))
	return result
