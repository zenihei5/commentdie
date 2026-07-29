extends Node

func _ready() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var failures: Array[String] = []
	var weapons: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/weapons.json")) as Array
	var fortress := WeaponSystem.find_weapon(weapons, "moderator_fortress", {})
	var visuals: Dictionary = fortress.get("visuals", {}) as Dictionary
	for role in ["body", "bodyCharged", "trail", "hit", "absorb", "bulletBreak", "shockwave", "shockwaveCharged"]:
		var config: Dictionary = visuals.get(role, {}) as Dictionary
		_check(String(config.get("path", "")).begins_with("res://assets/weapons/moderator_fortress/"), "%s path missing" % role, failures)
	_check(int(visuals.get("chargedBodyThreshold", 0)) == 4, "charged body threshold changed", failures)
	_check(int(visuals.get("chargedShockwaveThreshold", 0)) == 8, "charged shockwave threshold changed", failures)

	var active := _draw([{"kind": "moderator_fortress_active", "pos": Vector2(100, 100), "dir": Vector2.RIGHT, "progress": 0.4, "life": 0.4, "maxLife": 0.7, "width": 170.0, "thickness": 54.0, "bulletClears": 0, "level": 1, "visuals": visuals}])
	_check(_roles(active).has("body") and _roles(active).has("trail"), "normal fortress body/trail missing", failures)
	_check(not _roles(active).has("bodyCharged"), "normal fortress used charged body", failures)
	_check(DrawDataSystem.hit_fx_procedural_parts(active, {"body": true}, {}).is_empty(), "normal body fallback was not suppressed", failures)
	_check(DrawDataSystem.hit_fx_procedural_parts(active, {}, {}).size() == 3, "normal body fallback disappeared", failures)

	var charged := _draw([{"kind": "moderator_fortress_active", "pos": Vector2(100, 100), "dir": Vector2.DOWN, "progress": 0.4, "life": 0.4, "maxLife": 0.7, "width": 170.0, "thickness": 54.0, "bulletClears": 4, "level": 1, "visuals": visuals}])
	_check(_roles(charged).has("bodyCharged"), "charged fortress body missing at four absorbs", failures)
	_check(is_equal_approx(float(_layer_by_role(charged, "bodyCharged").get("rotation", 0.0)), PI * 0.5), "charged body direction rotation changed", failures)
	_check(DrawDataSystem.hit_fx_procedural_parts(charged, {"bodyCharged": true}, {}).is_empty(), "charged body fallback was not suppressed", failures)

	var hit := _draw([{"kind": "moderator_fortress_hit", "pos": Vector2(200, 120), "dir": Vector2.LEFT, "life": 0.19, "maxLife": 0.19, "visuals": visuals}])
	_check(_roles(hit).has("hit"), "fortress hit image missing", failures)
	_check((DrawDataSystem.hit_fx_procedural_parts(hit, {"hit": true}, {})).is_empty(), "fortress hit fallback was not suppressed", failures)

	var bullet_clear := _draw([{"kind": "moderator_fortress_bullet_clear", "pos": Vector2(210, 120), "shieldPos": Vector2(180, 120), "life": 0.18, "maxLife": 0.18, "visuals": visuals}])
	_check(_roles(bullet_clear).has("bulletBreak") and _roles(bullet_clear).has("absorb"), "bullet break/absorb images missing", failures)
	_check((_layer_by_role(bullet_clear, "bulletBreak").get("pos", Vector2.ZERO) as Vector2) == Vector2(210, 120), "bullet break anchor changed", failures)
	_check((_layer_by_role(bullet_clear, "absorb").get("pos", Vector2.ZERO) as Vector2) == Vector2(180, 120), "absorb anchor changed", failures)

	var wave_normal := _draw([{"kind": "moderator_fortress_shockwave", "pos": Vector2.ZERO, "dir": Vector2.RIGHT, "radius": 120.0, "absorbed": 7, "life": 0.28, "maxLife": 0.28, "visuals": visuals}])
	_check(_roles(wave_normal).has("shockwave") and not _roles(wave_normal).has("shockwaveCharged"), "normal shockwave threshold changed", failures)
	var wave_charged := _draw([{"kind": "moderator_fortress_shockwave", "pos": Vector2.ZERO, "dir": Vector2.RIGHT, "radius": 120.0, "absorbed": 8, "life": 0.32, "maxLife": 0.32, "visuals": visuals}])
	_check(_roles(wave_charged).has("shockwaveCharged"), "charged shockwave missing at eight absorbs", failures)
	_check(DrawDataSystem.hit_fx_procedural_parts(wave_charged, {"shockwaveCharged": true}, {}).is_empty(), "charged shockwave fallback was not suppressed", failures)

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

func _layer_by_role(data: Dictionary, role: String) -> Dictionary:
	for item in data.get("imageLayers", []) as Array:
		var layer: Dictionary = item as Dictionary
		if String(layer.get("role", "")) == role:
			return layer
	return {}

func _check(condition: bool, message: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(message)
