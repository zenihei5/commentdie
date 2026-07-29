extends Node

const WEAPON_IDS := ["moderator_shield", "fansa_baton", "tsuri_thumbnail_rod"]

func _ready() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var failures: Array[String] = []
	var weapons: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/weapons.json")) as Array
	var registry: Dictionary = {}
	for item in weapons:
		var weapon: Dictionary = item as Dictionary
		if WEAPON_IDS.has(String(weapon.get("id", ""))):
			registry[String(weapon.get("id", ""))] = weapon
	_check(registry.size() == 3, "visual weapon registry incomplete", failures)

	var shield_visuals: Dictionary = (registry["moderator_shield"] as Dictionary).get("visuals", {}) as Dictionary
	var shield := DrawDataSystem.hit_fx_draw_data([{
		"kind": "moderator_shield_active", "pos": Vector2.ZERO, "dir": Vector2.RIGHT,
		"progress": 0.5, "life": 0.5, "maxLife": 0.7, "width": 130.0, "thickness": 48.0, "visuals": shield_visuals
	}])
	var shield_data: Dictionary = shield[0] as Dictionary
	var shield_roles := _roles(shield_data)
	_check(shield_roles.has("trail") and shield_roles.has("body"), "shield body/trail layers missing", failures)
	_check(String(_layer_by_role(shield_data, "trail").get("drawLayer", "")) == "back", "shield trail layer is not back", failures)
	_check(is_equal_approx(float(_layer_by_role(shield_data, "body").get("rotation", 0.0)), 0.0), "shield right-facing rotation changed", failures)
	var shield_image_parts := DrawDataSystem.hit_fx_procedural_parts(shield_data, {"body": true}, {})
	_check(shield_image_parts.is_empty(), "shield procedural frame was not suppressed after body image load", failures)
	var shield_fallback_parts := DrawDataSystem.hit_fx_procedural_parts(shield_data, {}, {})
	_check(shield_fallback_parts.size() == 3, "shield procedural fallback disappeared when body image is missing", failures)
	var shield_down := DrawDataSystem.hit_fx_draw_data([{
		"kind": "moderator_shield_active", "pos": Vector2.ZERO, "dir": Vector2.DOWN,
		"progress": 0.5, "life": 0.5, "maxLife": 0.7, "width": 130.0, "thickness": 48.0, "visuals": shield_visuals
	}])
	_check(is_equal_approx(float((_layer_by_role(shield_down[0] as Dictionary, "body")).get("rotation", 0.0)), PI * 0.5), "shield direction rotation missing", failures)
	var wave_level_1 := DrawDataSystem.hit_fx_draw_data([{"kind": "moderator_shield_end_wave", "pos": Vector2.ZERO, "dir": Vector2.RIGHT, "level": 1, "life": 0.20, "maxLife": 0.24, "width": 150.0, "depth": 26.0, "visuals": shield_visuals}])
	_check(not _roles(wave_level_1[0] as Dictionary).has("endShockwave"), "Lv1 shield showed end shockwave", failures)
	var wave_level_5 := DrawDataSystem.hit_fx_draw_data([{"kind": "moderator_shield_end_wave", "pos": Vector2.ZERO, "dir": Vector2.RIGHT, "level": 5, "life": 0.20, "maxLife": 0.24, "width": 150.0, "depth": 26.0, "visuals": shield_visuals}])
	_check(_roles(wave_level_5[0] as Dictionary).has("endShockwave"), "Lv5 shield end shockwave missing", failures)

	var baton_visuals: Dictionary = (registry["fansa_baton"] as Dictionary).get("visuals", {}) as Dictionary
	for step in range(3):
		var baton_fx := DrawDataSystem.hit_fx_draw_data([{"kind": "fansa_baton_hit", "pos": Vector2.ZERO, "dir": Vector2.RIGHT, "comboStep": step, "level": 3, "range": 110.0 if step < 2 else 170.0, "life": 0.12, "maxLife": 0.24, "visuals": baton_visuals}])
		var expected_role := "swingRight" if step == 0 else ("swingLeft" if step == 1 else "finisher")
		_check(_roles(baton_fx[0] as Dictionary).has(expected_role), "baton step %d image missing" % step, failures)
		var baton_data: Dictionary = baton_fx[0] as Dictionary
		var baton_range := 110.0 if step < 2 else 170.0
		var baton_ratio := 0.52 if step < 2 else 0.55
		var baton_side_offset := -4.0 if step == 0 else (4.0 if step == 1 else 0.0)
		var expected_anchor := Vector2.ZERO + Vector2.RIGHT * baton_range * baton_ratio + Vector2.DOWN * baton_side_offset
		_check((_layer_by_role(baton_data, expected_role).get("pos", Vector2.ZERO) as Vector2) == expected_anchor, "baton step %d image anchor is not forward of player" % step, failures)
		var baton_parts := DrawDataSystem.hit_fx_procedural_parts(baton_data, {expected_role: true}, {})
		_check(baton_parts.is_empty(), "baton step %d procedural trail was not suppressed after image load" % step, failures)
	var cross_fx := DrawDataSystem.hit_fx_draw_data([{"kind": "fansa_baton_cross_followup", "pos": Vector2.ZERO, "dir": Vector2.RIGHT, "level": 5, "life": 0.20, "maxLife": 0.30, "visuals": baton_visuals}])
	_check(_roles(cross_fx[0] as Dictionary).has("xSlash"), "Lv5 baton X slash missing", failures)
	_check(DrawDataSystem.hit_fx_procedural_parts(cross_fx[0] as Dictionary, {"xSlash": true}, {}).is_empty(), "baton X procedural trail was not suppressed after image load", failures)
	var cross_level_1 := DrawDataSystem.hit_fx_draw_data([{"kind": "fansa_baton_cross_followup", "pos": Vector2.ZERO, "dir": Vector2.RIGHT, "level": 1, "life": 0.20, "maxLife": 0.30, "visuals": baton_visuals}])
	_check(not _roles(cross_level_1[0] as Dictionary).has("xSlash"), "Lv1 baton X slash was shown", failures)

	var rod_visuals: Dictionary = (registry["tsuri_thumbnail_rod"] as Dictionary).get("visuals", {}) as Dictionary
	var player_pos := Vector2(100, 100)
	var lure_pos := Vector2(220, 130)
	var rod_fx := DrawDataSystem.hit_fx_draw_data([{
		"kind": "tsuri_rod_cast", "pos": lure_pos, "displayPlayerPos": player_pos, "reelDestination": player_pos,
		"dir": (lure_pos - player_pos).normalized(), "phase": "casting", "life": 4.0, "maxLife": 8.0,
		"pathWidth": 22.0, "gatherRadius": 90.0, "visuals": rod_visuals
	}])
	var rod_data: Dictionary = rod_fx[0] as Dictionary
	var rod_body := _layer_by_role(rod_data, "body")
	_check((rod_body.get("pos", Vector2.ZERO) as Vector2) == player_pos, "rod body pivot moved from hand", failures)
	var line: Dictionary = (rod_data.get("imageLines", []) as Array)[0] as Dictionary
	_check((line.get("to", Vector2.ZERO) as Vector2) == lure_pos, "rod line does not end at lure", failures)
	_check((line.get("from", Vector2.ZERO) as Vector2) != player_pos, "rod line ignores rotated tip", failures)
	_check(((_layer_by_role(rod_data, "lure")).get("pos", Vector2.ZERO) as Vector2) == lure_pos, "rod lure is not at runtime position", failures)
	var rod_line_parts := DrawDataSystem.hit_fx_procedural_parts(rod_data, {}, {"line": true})
	for part_item in rod_line_parts:
		var part: Dictionary = part_item as Dictionary
		_check(not ["line", "reel"].has(String(part.get("prefix", ""))), "rod procedural line/reel was not suppressed", failures)
	var rod_lure_parts := DrawDataSystem.hit_fx_procedural_parts(rod_data, {"lure": true}, {})
	for part_item in rod_lure_parts:
		var part: Dictionary = part_item as Dictionary
		_check(String(part.get("prefix", "")) != "lure", "rod procedural lure circle was not suppressed", failures)
	var moved_lure := Vector2(260, 145)
	var moved_rod_fx := DrawDataSystem.hit_fx_draw_data([{
		"kind": "tsuri_rod_cast", "pos": moved_lure, "displayPlayerPos": Vector2(150, 130), "reelDestination": Vector2(80, 80),
		"dir": (moved_lure - Vector2(150, 130)).normalized(), "phase": "reeling", "life": 1.0, "maxLife": 8.0,
		"pathWidth": 22.0, "gatherRadius": 90.0, "visuals": rod_visuals
	}])
	var moved_line: Dictionary = ((moved_rod_fx[0] as Dictionary).get("imageLines", []) as Array)[0] as Dictionary
	_check((moved_line.get("to", Vector2.ZERO) as Vector2) == moved_lure, "rod line retained stale reel destination", failures)
	var gather_fx := DrawDataSystem.hit_fx_draw_data([{"kind": "tsuri_rod_gather", "pos": lure_pos, "radius": 90.0, "life": 0.22, "maxLife": 0.22, "visuals": rod_visuals}])
	_check((_layer_by_role(gather_fx[0] as Dictionary, "gather").get("size", Vector2.ZERO) as Vector2) == Vector2(180, 180), "rod gather image size changed", failures)
	var reel_fx := DrawDataSystem.hit_fx_draw_data([{"kind": "tsuri_rod_reel_hit", "pos": lure_pos, "dir": Vector2.LEFT, "life": 0.20, "maxLife": 0.20, "visuals": rod_visuals}])
	_check(_roles(reel_fx[0] as Dictionary).has("reelHit"), "rod reel-hit image missing", failures)

	if failures.is_empty():
		print("Stage2 weapon visual tests passed")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	get_tree().quit(1)

func _roles(data: Dictionary) -> Dictionary:
	var roles: Dictionary = {}
	for item in data.get("imageLayers", []) as Array:
		var layer: Dictionary = item as Dictionary
		roles[String(layer.get("role", ""))] = true
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
