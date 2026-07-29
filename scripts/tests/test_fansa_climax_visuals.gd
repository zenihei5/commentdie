extends Node

func _ready() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var failures: Array[String] = []
	var weapons: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/weapons.json")) as Array
	var climax := WeaponSystem.find_weapon(weapons, "fansa_climax", {})
	var visuals: Dictionary = climax.get("visuals", {}) as Dictionary
	for role in ["swingRight", "swingLeft", "echo", "finisher", "xSlash", "wave", "finisherBg", "confetti", "batonBodyLeft", "batonBodyRight", "batonGlowLeft", "batonGlowRight", "spark"]:
		var config: Dictionary = visuals.get(role, {}) as Dictionary
		_check(String(config.get("path", "")).begins_with("res://assets/weapons/fansa_climax/"), "%s path missing" % role, failures)
	_check(String(climax.get("iconPath", "")).ends_with("/fansa_climax/icon_fansa_climax.png"), "climax icon path changed", failures)
	_check(float((visuals.get("swingRight", {}) as Dictionary).get("attackForwardOffset", 0.0)) == 58.0, "right slash anchor tuning changed", failures)
	_check(float((visuals.get("swingLeft", {}) as Dictionary).get("attackForwardOffset", 0.0)) == 58.0, "left slash anchor tuning changed", failures)
	_check(float((visuals.get("finisher", {}) as Dictionary).get("attackForwardOffset", 0.0)) == 94.0, "finisher anchor tuning changed", failures)

	var main_right := _draw([{"kind": "fansa_climax_hit", "pos": Vector2.ZERO, "dir": Vector2.RIGHT, "comboStep": 0, "range": 125.0, "arcAngle": 55.0, "life": 0.18, "maxLife": 0.24, "visuals": visuals}])
	var right_layer := _layer_by_role(main_right, "swingRight")
	_check(not right_layer.is_empty(), "right slash layer missing", failures)
	_check(is_equal_approx(float((right_layer.get("pos", Vector2.ZERO) as Vector2).x), 58.0), "right slash is not in saved forward anchor", failures)
	_check(_roles(main_right).has("batonBodyLeft") and _roles(main_right).has("batonBodyRight"), "split baton body missing", failures)
	_check(not _roles(main_right).has("batonBody"), "whole baton sheet was used", failures)
	_check(DrawDataSystem.hit_fx_procedural_parts(main_right, {"swingRight": true}, {}).is_empty(), "right slash fallback was not suppressed", failures)

	var main_left := _draw([{"kind": "fansa_climax_hit", "pos": Vector2(50, 60), "dir": Vector2.DOWN, "comboStep": 1, "range": 125.0, "arcAngle": 55.0, "life": 0.18, "maxLife": 0.24, "visuals": visuals}])
	var left_layer := _layer_by_role(main_left, "swingLeft")
	_check(not left_layer.is_empty(), "left slash layer missing", failures)
	_check(is_equal_approx(float((left_layer.get("pos", Vector2.ZERO) as Vector2).y), 118.0), "left slash is not in saved forward anchor", failures)
	_check(int(float(left_layer.get("rotation", 0.0)) * 1000.0) != 0, "left slash direction correction missing", failures)

	var main_finisher := _draw([{"kind": "fansa_climax_hit", "pos": Vector2.ZERO, "dir": Vector2.RIGHT, "comboStep": 2, "range": 190.0, "arcAngle": 80.0, "life": 0.26, "maxLife": 0.34, "visuals": visuals}])
	var finisher_layer := _layer_by_role(main_finisher, "finisher")
	_check(is_equal_approx(float((finisher_layer.get("pos", Vector2.ZERO) as Vector2).x), 94.0), "finisher is centered on player", failures)
	_check(_roles(main_finisher).has("finisherBg") and _roles(main_finisher).has("confetti"), "finisher layers missing", failures)
	_check(String(_layer_by_role(main_finisher, "finisherBg").get("drawLayer", "")) == "back", "finisher background is not behind actor", failures)
	_check(int(_layer_by_role(main_finisher, "confetti").get("zIndex", 0)) > int(finisher_layer.get("zIndex", 0)), "confetti draw order changed", failures)

	var echo := _draw([{"kind": "fansa_climax_echo", "origin": Vector2(20, 30), "pos": Vector2(900, 900), "dir": Vector2.RIGHT, "range": 125.0, "arcAngle": 55.0, "delay": 0.0, "life": 0.19, "maxLife": 0.22, "visuals": visuals}])
	_check(_roles(echo).has("echo") and not _roles(echo).has("swingRight"), "echo did not use dedicated image", failures)
	_check(((_layer_by_role(echo, "echo").get("pos", Vector2.ZERO) as Vector2) - Vector2(20, 30)).length() > 0.1, "echo anchor was not derived from attack context", failures)

	var wave := _draw([{"kind": "fansa_climax_fan_wave", "pos": Vector2(120, 80), "radius": 105.0, "life": 0.20, "maxLife": 0.28, "visuals": visuals}])
	_check(_roles(wave).has("wave"), "fan wave image missing", failures)
	_check((_layer_by_role(wave, "wave").get("pos", Vector2.ZERO) as Vector2) == Vector2(120, 80), "fan wave did not use saved center", failures)
	_check(DrawDataSystem.hit_fx_procedural_parts(wave, {"wave": true}, {}).is_empty(), "fan wave fallback was not suppressed", failures)

	var spark := _draw([{"kind": "fansa_climax_spark", "pos": Vector2(240, 140), "life": 0.18, "maxLife": 0.18, "sparkMultiplier": 1.4, "visuals": visuals}])
	_check(_roles(spark).has("spark"), "hit spark image missing", failures)
	_check((_layer_by_role(spark, "spark").get("pos", Vector2.ZERO) as Vector2) == Vector2(240, 140), "hit spark anchor changed", failures)

	if failures.is_empty():
		print("Fansa Climax visual tests passed")
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
