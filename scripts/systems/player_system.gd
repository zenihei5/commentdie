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
