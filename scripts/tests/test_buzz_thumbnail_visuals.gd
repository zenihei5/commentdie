extends Node

const REQUIRED_ROLES := ["body", "lure", "zone", "pull", "throw", "hit", "explosion", "targetMark", "bearFlash", "catchMark", "burstDeco"]

func _ready() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var failures: Array[String] = []
	var weapons: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/weapons.json")) as Array
	var weapon := WeaponSystem.find_weapon(weapons, "buzz_thumbnail_rod", {})
	var visuals: Dictionary = weapon.get("visuals", {}) as Dictionary
	_check(String(weapon.get("iconPath", "")) == "res://assets/weapons/buzz_thumbnail/icon_buzz_thumbnail.png", "buzz icon path is not registered", failures)
	_check(String((visuals.get("line", {}) as Dictionary).get("path", "non-empty")) == "", "dynamic fishing line was replaced by an image line", failures)
	for role in REQUIRED_ROLES:
		var config: Dictionary = visuals.get(role, {}) as Dictionary
		var path := String(config.get("path", ""))
		_check(not path.is_empty() and FileAccess.file_exists(path), "%s visual asset is missing" % role, failures)

	var player_pos := Vector2(100, 100)
	var lure_pos := Vector2(260, 145)
	var cast := _draw([{
		"kind": "buzz_thumbnail_rod_cast", "pos": lure_pos, "displayPlayerPos": player_pos,
		"reelDestination": Vector2(80, 80), "dir": (lure_pos - player_pos).normalized(), "phase": "casting",
		"life": 4.0, "maxLife": 10.0, "gatherRadius": 125.0, "visuals": visuals
	}])
	_check(_roles(cast).has("body") and _roles(cast).has("lure"), "buzz cast body/lure layers missing", failures)
	_check((_layer_by_role(cast, "body").get("pos", Vector2.ZERO) as Vector2) == player_pos, "buzz rod body left the player hand", failures)
	_check((_layer_by_role(cast, "lure").get("pos", Vector2.ZERO) as Vector2) == lure_pos, "buzz lure ignored runtime position", failures)
	var image_lines: Array = cast.get("imageLines", []) as Array
	_check(image_lines.size() == 1, "buzz cast did not produce exactly one dynamic line", failures)
	if image_lines.size() == 1:
		var line: Dictionary = image_lines[0] as Dictionary
		_check((line.get("to", Vector2.ZERO) as Vector2) == lure_pos, "buzz line does not end at lure", failures)
		_check((line.get("from", Vector2.ZERO) as Vector2) != player_pos, "buzz line does not use rotated rod tip", failures)
	var line_parts := DrawDataSystem.hit_fx_procedural_parts(cast, {}, {"line": true})
	for part_item in line_parts:
		var part: Dictionary = part_item as Dictionary
		_check(not ["line", "reel"].has(String(part.get("prefix", ""))), "buzz cast retained a second fishing line", failures)
	_check((_layer_by_role(cast, "body").get("fallbackConfig", {}) as Dictionary).has("path"), "buzz body fallback is not data-driven", failures)
	var missing_visuals: Dictionary = visuals.duplicate(true)
	(missing_visuals["lure"] as Dictionary)["path"] = "res://missing/buzz_thumbnail_lure.png"
	var missing_cast := _draw([{"kind": "buzz_thumbnail_rod_cast", "pos": lure_pos, "displayPlayerPos": player_pos, "reelDestination": player_pos, "dir": Vector2.RIGHT, "phase": "casting", "life": 4.0, "maxLife": 10.0, "gatherRadius": 125.0, "visuals": missing_visuals}])
	_check(not DrawDataSystem.hit_fx_procedural_parts(missing_cast, {}, {"line": true}).is_empty(), "missing lure image did not leave procedural fallback", failures)

	var short_fx := _draw([
		{"kind": "buzz_thumbnail_rod_target_mark", "pos": lure_pos, "dir": Vector2.RIGHT, "life": 0.35, "maxLife": 0.35, "visuals": visuals},
		{"kind": "buzz_thumbnail_rod_throw", "pos": player_pos + Vector2(28, 0), "dir": Vector2.RIGHT, "life": 0.25, "maxLife": 0.25, "visuals": visuals},
		{"kind": "buzz_thumbnail_rod_bear_flash", "pos": lure_pos, "dir": Vector2.RIGHT, "life": 0.20, "maxLife": 0.20, "visuals": visuals},
		{"kind": "buzz_thumbnail_rod_catch_mark", "pos": Vector2(220, 130), "dir": Vector2.RIGHT, "life": 0.22, "maxLife": 0.22, "visuals": visuals},
		{"kind": "buzz_thumbnail_rod_hit", "pos": Vector2(220, 130), "dir": Vector2.RIGHT, "life": 0.18, "maxLife": 0.18, "visuals": visuals}
	])
	for role in ["targetMark", "throw", "bearFlash", "catchMark", "hit"]:
		_check(_roles(short_fx).has(role), "%s event image missing" % role, failures)

	var gather := _draw([{"kind": "buzz_thumbnail_rod_gather", "pos": lure_pos, "radius": 125.0, "life": 0.80, "maxLife": 0.80, "visuals": visuals}])
	_check(_roles(gather).has("zone") and _roles(gather).has("pull"), "buzz gather zone/pull images missing", failures)
	_check((_layer_by_role(gather, "zone").get("size", Vector2.ZERO) as Vector2) == Vector2(250, 250), "zone image size changed the configured visual", failures)
	_check(DrawDataSystem.hit_fx_procedural_parts(gather, {"zone": true}, {}).is_empty(), "buzz gather fallback was not suppressed", failures)

	var explosion := _draw([{"kind": "buzz_thumbnail_rod_explosion", "pos": lure_pos, "radius": 78.0, "life": 0.30, "maxLife": 0.30, "visuals": visuals}])
	_check(_roles(explosion).has("explosion") and _roles(explosion).has("burstDeco"), "buzz explosion/deco images missing", failures)
	_check(DrawDataSystem.hit_fx_procedural_parts(explosion, {"explosion": true}, {}).is_empty(), "buzz explosion fallback was not suppressed", failures)

	if failures.is_empty():
		print("Buzz Thumbnail visual tests passed")
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
