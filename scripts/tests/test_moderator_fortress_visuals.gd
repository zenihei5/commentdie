extends Node

func _ready() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var failures: Array[String] = []
	var weapons: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/weapons.json")) as Array
	var fortress := WeaponSystem.find_weapon(weapons, "moderator_fortress", {})
	var visuals: Dictionary = fortress.get("visuals", {}) as Dictionary
	for role in ["body", "bodyCharged", "panelCenter", "panelSide", "hit", "absorb", "bulletBreak", "shockwave", "shockwaveCharged"]:
		var config: Dictionary = visuals.get(role, {}) as Dictionary
		_check(String(config.get("path", "")).begins_with("res://assets/weapons/moderator_fortress/"), "%s path missing" % role, failures)
	_check(not visuals.has("trail"), "fortress retained its legacy projectile trail", failures)
	for phase_role in ["deployEffect", "idleEffect", "enemyHitEffect", "projectileBlockEffect", "endEffect"]:
		_check(visuals.has(phase_role), "fortress %s data missing" % phase_role, failures)
	var panels: Dictionary = visuals.get("panels", {}) as Dictionary
	_check(panels.has("center") and panels.has("upper") and panels.has("lower"), "fortress center/side panel visual data missing", failures)
	_check(not panels.has("main") and not panels.has("left") and not panels.has("right"), "fortress retained legacy panel slots", failures)
	_check(String((panels.get("center", {}) as Dictionary).get("visualRole", "")) == "panelCenter", "fortress center texture role missing", failures)
	var upper_panel := panels.get("upper", {}) as Dictionary
	var lower_panel := panels.get("lower", {}) as Dictionary
	_check(String(upper_panel.get("visualRole", "")) == "panelSide" and String(lower_panel.get("visualRole", "")) == "panelSide", "fortress side texture is not reused", failures)
	_check(is_equal_approx(float(upper_panel.get("localForwardOffset", 0.0)), -14.0) and is_equal_approx(float(lower_panel.get("localForwardOffset", 0.0)), -14.0), "fortress side forward offsets are not equal in data", failures)
	_check(is_zero_approx(float(upper_panel.get("localSideOffset", 1.0))) and is_zero_approx(float(lower_panel.get("localSideOffset", 1.0))), "fortress side offsets retained direction-relative separation", failures)
	_check(String(upper_panel.get("rotationMode", "")) == "screen" and String(lower_panel.get("rotationMode", "")) == "screen" and is_equal_approx(float(upper_panel.get("screenRotationDegrees", 0.0)), 90.0) and is_equal_approx(float(lower_panel.get("screenRotationDegrees", 0.0)), 90.0), "fortress side screen rotation data missing", failures)
	_check(float((visuals.get("panelCenter", {}) as Dictionary).get("size", [0, 0])[0]) > float((visuals.get("panelSide", {}) as Dictionary).get("size", [0, 0])[0]), "fortress center is not wider than side", failures)

	var active := _draw([{"kind": "moderator_fortress_active", "pos": Vector2(100, 100), "dir": Vector2.RIGHT, "progress": 0.4, "life": 0.4, "maxLife": 7.0, "arcDegrees": 220.0, "radius": 100.0, "visuals": visuals}])
	_check(_roles(active).has("center") and _roles(active).has("upper") and _roles(active).has("lower"), "fortress center/side panel layers missing", failures)
	_check(_count_role(active, "center") == 1 and _count_role(active, "upper") == 1 and _count_role(active, "lower") == 1, "fortress panel layer was duplicated", failures)
	_check(not _roles(active).has("trail") and not bool(active.get("legacyTrailEffect", true)), "fortress active draw data retained a projectile trail", failures)
	var center_pos := _layer_by_role(active, "center").get("pos", Vector2.ZERO) as Vector2
	var upper_pos := _layer_by_role(active, "upper").get("pos", Vector2.ZERO) as Vector2
	var lower_pos := _layer_by_role(active, "lower").get("pos", Vector2.ZERO) as Vector2
	_check(center_pos == Vector2(100, 100) and upper_pos == Vector2(86, 6) and lower_pos == Vector2(86, 194), "fortress screen-fixed panel offsets were not applied", failures)
	_check(int(_layer_by_role(active, "upper").get("zIndex", 0)) < int(_layer_by_role(active, "center").get("zIndex", 0)) and int(_layer_by_role(active, "center").get("zIndex", 0)) < int(_layer_by_role(active, "lower").get("zIndex", 0)), "fortress panel z-order changed", failures)
	_check(_is_screen_horizontal_rotation(float(_layer_by_role(active, "upper").get("rotation", 0.0))) and is_equal_approx(float(_layer_by_role(active, "upper").get("rotation", 0.0)), float(_layer_by_role(active, "lower").get("rotation", 0.0))), "fortress side panels are not parallel screen-horizontal shields", failures)
	_check(not bool(_layer_by_role(active, "upper").get("flipX", false)) and bool(_layer_by_role(active, "lower").get("flipX", false)), "fortress side reflection is not an explicit horizontal transform", failures)
	_check(not _roles(active).has("bodyCharged"), "fortress retained charged-body selection", failures)
	var loaded_active_parts := DrawDataSystem.hit_fx_procedural_parts(active, {"center": true, "upper": true, "lower": true}, {})
	_check(loaded_active_parts.is_empty(), "fortress procedural panel fallback was not suppressed", failures)
	_check(DrawDataSystem.hit_fx_procedural_parts(active, {}, {}).size() > loaded_active_parts.size(), "fortress missing-image fallback disappeared", failures)
	_check(not _has_fallback_role(DrawDataSystem.hit_fx_procedural_parts(active, {"center": true}, {}), "center"), "fortress center fallback remained with center image", failures)
	var stage_zero := _draw([{"kind": "moderator_fortress_active", "pos": Vector2.ZERO, "dir": Vector2.RIGHT, "progress": 0.0, "life": 7.0, "maxLife": 7.0, "arcDegrees": 220.0, "radius": 100.0, "visuals": visuals}])
	var stage_upper := _draw([{"kind": "moderator_fortress_active", "pos": Vector2.ZERO, "dir": Vector2.RIGHT, "progress": 0.04 / 7.0, "life": 7.0, "maxLife": 7.0, "arcDegrees": 220.0, "radius": 100.0, "visuals": visuals}])
	var stage_lower := _draw([{"kind": "moderator_fortress_active", "pos": Vector2.ZERO, "dir": Vector2.RIGHT, "progress": 0.08 / 7.0, "life": 7.0, "maxLife": 7.0, "arcDegrees": 220.0, "radius": 100.0, "visuals": visuals}])
	_check(float(_layer_by_role(stage_zero, "center").get("alpha", 0.0)) > 0.0 and is_zero_approx(float(_layer_by_role(stage_zero, "upper").get("alpha", 0.0))) and is_zero_approx(float(_layer_by_role(stage_zero, "lower").get("alpha", 0.0))), "fortress center did not deploy first", failures)
	_check(float(_layer_by_role(stage_upper, "center").get("alpha", 0.0)) > float(_layer_by_role(stage_upper, "upper").get("alpha", 0.0)) and float(_layer_by_role(stage_lower, "upper").get("alpha", 0.0)) > float(_layer_by_role(stage_lower, "lower").get("alpha", 0.0)), "fortress side deployment order changed", failures)

	var deploy := _draw([{"kind": "moderator_fortress_deploy", "pos": Vector2(100, 100), "dir": Vector2.RIGHT, "life": 0.18, "maxLife": 0.18, "visuals": visuals}])
	_check(DrawDataSystem.hit_fx_procedural_parts(deploy).size() == 4 and bool(deploy.get("deployEffectPlayed", false)), "fortress construction effect missing", failures)
	var end_fx := _draw([{"kind": "moderator_fortress_end", "pos": Vector2(100, 100), "dir": Vector2.RIGHT, "life": 0.09, "maxLife": 0.18, "arcDegrees": 220.0, "radius": 100.0, "visuals": visuals}])
	_check(_roles(end_fx).has("center") and float(_layer_by_role(end_fx, "center").get("alpha", 1.0)) < 1.0 and float(_layer_by_role(end_fx, "upper").get("alpha", 1.0)) < float(_layer_by_role(end_fx, "center").get("alpha", 1.0)), "fortress side-first end fade missing", failures)

	var directions: Array[Vector2] = [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]
	var side_rotation := float(_layer_by_role(active, "upper").get("rotation", 0.0))
	for direction in directions:
		var directional := _draw([{"kind": "moderator_fortress_active", "pos": Vector2(100, 100), "dir": direction, "progress": 0.4, "life": 0.4, "maxLife": 7.0, "arcDegrees": 220.0, "radius": 100.0, "visuals": visuals}])
		var directional_center := _layer_by_role(directional, "center")
		var directional_upper := _layer_by_role(directional, "upper")
		var directional_lower := _layer_by_role(directional, "lower")
		var expected_center := Vector2(100, 100)
		var expected_upper := expected_center + direction * -14.0 + Vector2(0, -94)
		var expected_lower := expected_center + direction * -14.0 + Vector2(0, 94)
		_check((directional_center.get("pos", Vector2.ZERO) as Vector2).is_equal_approx(expected_center) and (directional_upper.get("pos", Vector2.ZERO) as Vector2).is_equal_approx(expected_upper) and (directional_lower.get("pos", Vector2.ZERO) as Vector2).is_equal_approx(expected_lower), "fortress panel screen offsets changed by facing direction", failures)
		_check((directional_upper.get("pos", Vector2.ZERO) as Vector2).y < (directional_center.get("pos", Vector2.ZERO) as Vector2).y and (directional_center.get("pos", Vector2.ZERO) as Vector2).y < (directional_lower.get("pos", Vector2.ZERO) as Vector2).y, "fortress panels are not ordered upper/center/lower on screen", failures)
		_check(is_equal_approx(float(directional_upper.get("rotation", 0.0)), side_rotation) and is_equal_approx(float(directional_lower.get("rotation", 0.0)), side_rotation), "fortress side rotation changed with facing direction", failures)
		_check(is_equal_approx(float(directional_center.get("rotation", 0.0)), direction.angle()), "fortress center rotation stopped following facing direction", failures)
		var upper_forward := (((directional_upper.get("pos", Vector2.ZERO) as Vector2) - Vector2(0, -94)) - (directional_center.get("pos", Vector2.ZERO) as Vector2)).dot(direction)
		var lower_forward := (((directional_lower.get("pos", Vector2.ZERO) as Vector2) - Vector2(0, 94)) - (directional_center.get("pos", Vector2.ZERO) as Vector2)).dot(direction)
		_check(is_equal_approx(upper_forward, -14.0) and is_equal_approx(lower_forward, -14.0), "fortress side forward offsets are not equal", failures)
		_check((directional_upper.get("pos", Vector2.ZERO) as Vector2).distance_to(directional_lower.get("pos", Vector2.ZERO) as Vector2) >= 150.0, "fortress side panels are too close together", failures)
		var upper_span := _outline_span(directional, "upper")
		var lower_span := _outline_span(directional, "lower")
		_check(upper_span.x > upper_span.y and lower_span.x > lower_span.y, "fortress procedural side fallback is not horizontal", failures)

	var hit := _draw([{"kind": "moderator_fortress_hit", "pos": Vector2(200, 120), "dir": Vector2.LEFT, "life": 0.19, "maxLife": 0.19, "visuals": visuals}])
	_check(_roles(hit).has("hit"), "fortress hit image missing", failures)
	_check((DrawDataSystem.hit_fx_procedural_parts(hit, {"hit": true}, {})).size() == 3, "fortress contact fracture detail missing", failures)

	var bullet_clear := _draw([{"kind": "moderator_fortress_bullet_clear", "pos": Vector2(210, 120), "shieldPos": Vector2(180, 120), "life": 0.18, "maxLife": 0.18, "visuals": visuals}])
	_check(_roles(bullet_clear).has("bulletBreak") and _roles(bullet_clear).has("absorb"), "bullet break/absorb images missing", failures)
	_check((_layer_by_role(bullet_clear, "bulletBreak").get("pos", Vector2.ZERO) as Vector2) == Vector2(210, 120), "bullet break anchor changed", failures)
	_check((_layer_by_role(bullet_clear, "absorb").get("pos", Vector2.ZERO) as Vector2) == Vector2(180, 120), "absorb anchor changed", failures)
	_check(not (bullet_clear.get("blockHexPoints", PackedVector2Array()) as PackedVector2Array).is_empty(), "fortress projectile-block hex missing", failures)

	var wave := _draw([{"kind": "moderator_fortress_shockwave", "pos": Vector2.ZERO, "dir": Vector2.RIGHT, "radius": 100.0, "arcDegrees": 220.0, "life": 0.28, "maxLife": 0.28, "visuals": visuals}])
	_check(_roles(wave).has("shockwave"), "fortress deployment shockwave image missing", failures)
	_check(not _roles(wave).has("shockwaveCharged"), "fortress retained charged shockwave selection", failures)

	if failures.is_empty():
		print("Moderator Fortress visual tests passed")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	get_tree().quit(1)

func _draw(items: Array) -> Dictionary:
	return (DrawDataSystem.hit_fx_draw_data(items) as Array)[0] as Dictionary

func _roles(data: Dictionary) -> Dictionary:
	var roles: Dictionary = {}
	for item in data.get("imageLayers", []) as Array:
		roles[String((item as Dictionary).get("role", ""))] = true
	return roles

func _count_role(data: Dictionary, role: String) -> int:
	var count := 0
	for item in data.get("imageLayers", []) as Array:
		if String((item as Dictionary).get("role", "")) == role:
			count += 1
	return count

func _has_fallback_role(parts: Array, role: String) -> bool:
	for item in parts:
		if String((item as Dictionary).get("fallbackRole", "")) == role:
			return true
	return false

func _is_screen_horizontal_rotation(rotation: float) -> bool:
	return is_equal_approx(absf(sin(rotation)), 1.0) and is_zero_approx(cos(rotation))

func _outline_span(data: Dictionary, role: String) -> Vector2:
	var roles: Array = data.get("idleOutlineRoles", []) as Array
	var index := roles.find(role)
	if index < 0:
		return Vector2.ZERO
	var points: PackedVector2Array = data.get("idleEdge%dPoints" % (index + 1), PackedVector2Array()) as PackedVector2Array
	if points.is_empty():
		return Vector2.ZERO
	var minimum := points[0]
	var maximum := points[0]
	for point_value in points:
		var point: Vector2 = point_value
		minimum.x = minf(minimum.x, point.x)
		minimum.y = minf(minimum.y, point.y)
		maximum.x = maxf(maximum.x, point.x)
		maximum.y = maxf(maximum.y, point.y)
	return maximum - minimum

func _layer_by_role(data: Dictionary, role: String) -> Dictionary:
	for item in data.get("imageLayers", []) as Array:
		var layer: Dictionary = item as Dictionary
		if String(layer.get("role", "")) == role:
			return layer
	return {}

func _check(condition: bool, message: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(message)
