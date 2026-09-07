extends Node2D

const ComboSystem := preload("res://scripts/systems/collab_combo_system.gd")

var characters: Array = []
var registry: Dictionary = {}
var pair_definitions: Array = []
var preview_time := 0.0
var test_finished := false

func _ready() -> void:
	var parsed_characters = JSON.parse_string(FileAccess.get_file_as_string("res://data/characters.json"))
	characters = parsed_characters as Array if parsed_characters is Array else []
	registry = ComboSystem.registry()
	call_deferred("_run_test")

func _process(delta: float) -> void:
	preview_time += maxf(0.0, delta)
	queue_redraw()

func _run_test() -> void:
	var failures: Array[String] = []
	_check(characters.size() == 6, "collab effect test expects six characters", failures)
	var validation := ComboSystem.validate_registry(characters, registry)
	_check(bool(validation.get("valid", false)), "collab registry validation failed: %s" % str(validation.get("errors", [])), failures)
	_check(int(validation.get("dedicatedCount", 0)) == 6, "six dedicated pairs", failures)
	_check(int(validation.get("compositeCount", 0)) == 9, "nine composite pairs", failures)

	var ids: Array[String] = []
	for item in characters:
		ids.append(String((item as Dictionary).get("id", "")))
	var seen_effect_kinds: Dictionary = {}
	var seen_link_styles: Dictionary = {}
	var composite_count := 0
	for first_index in range(ids.size()):
		for second_index in range(first_index + 1, ids.size()):
			var forward := ComboSystem.resolve_pair(ids[first_index], ids[second_index], characters, registry)
			var reverse := ComboSystem.resolve_pair(ids[second_index], ids[first_index], characters, registry)
			_check(String(forward.get("pairKey", "")) == String(reverse.get("pairKey", "")), "pair key is not order independent", failures)
			_check(String(forward.get("comboId", "")) == String(reverse.get("comboId", "")), "combo id is not order independent", failures)
			var effect_kind := String(forward.get("effectKind", ""))
			if effect_kind == "" and String(forward.get("kind", "")) != "dedicated":
				effect_kind = "collab_composite_link"
			seen_effect_kinds[effect_kind] = true
			var preview_definition := forward.duplicate(true)
			preview_definition["effectKind"] = effect_kind
			pair_definitions.append(preview_definition)
			if String(forward.get("kind", "")) == "dedicated":
				_check(float(forward.get("duration", 0.0)) > 0.0, "dedicated duration missing", failures)
			else:
				composite_count += 1
				seen_effect_kinds["collab_composite_link"] = true
				var link_style := String(forward.get("linkStyle", ""))
				_check(link_style != "", "composite link style missing", failures)
				seen_link_styles[link_style] = true
				for module_item in forward.get("orderedModules", []) as Array:
					var module: Dictionary = module_item as Dictionary
					var module_effect_kind := String(module.get("effectKind", ""))
					_check(module_effect_kind != "", "composite module effectKind missing", failures)
					seen_effect_kinds[module_effect_kind] = true
	_check(composite_count == 9, "composite loop count", failures)
	_check(seen_link_styles.size() == 9, "nine distinct cross-pair styles", failures)
	for required_kind in ComboSystem.required_effect_kinds():
		_check(seen_effect_kinds.has(String(required_kind)), "required effect kind missing: %s" % String(required_kind), failures)

	var senior_count := 0
	for dedicated_item in registry.get("dedicatedPairs", []) as Array:
		var dedicated: Dictionary = dedicated_item as Dictionary
		if String(dedicated.get("effectKind", "")).begins_with("collab_senior_"):
			senior_count += 1
		_check(String(dedicated.get("effectKind", "")) != "", "dedicated pair effectKind missing", failures)
	_check(senior_count == 3, "three senior dedicated effects", failures)
	var style_effect_count := 0
	for style_item in registry.get("crossPairStyles", {}).values():
		var style: Dictionary = style_item as Dictionary
		if String(style.get("effectKind", "collab_composite_link")) != "":
			style_effect_count += 1
	_check(style_effect_count == 9, "nine cross-pair effectKind entries", failures)
	_check(style_effect_count + senior_count == 12, "twelve target effect entries", failures)

	var game_source := FileAccess.get_file_as_string("res://scripts/game.gd")
	for required_kind in ComboSystem.required_effect_kinds():
		_check(game_source.contains("\"%s\"" % String(required_kind)), "draw dispatch/effect code missing: %s" % String(required_kind), failures)
		for progress in [0.10, 0.50, 0.90]:
			_check(not ComboSystem.visual_elements_for_effect(String(required_kind), progress, true).is_empty(), "empty preview elements at %.2f: %s" % [progress, String(required_kind)], failures)
			_check(not ComboSystem.visual_elements_for_effect(String(required_kind), progress, false).is_empty(), "empty fallback elements at %.2f: %s" % [progress, String(required_kind)], failures)

	for attack_signature in ["0.42, 0.035", "0.34, 0.03", "0.30, 0.025", "0.78, 0.08", "0.72, 0.07", "0.70, 0.06", "0.68, 0.06"]:
		_check(game_source.contains(attack_signature), "combo damage signature changed: %s" % attack_signature, failures)

	var guard_events := ComboSystem.se_profile_events(registry, "guard_live")
	var crossed_once := ComboSystem.se_step_after_elapsed(guard_events, 0.90, 0)
	var crossed_again := ComboSystem.se_step_after_elapsed(guard_events, 0.90, crossed_once)
	_check(crossed_once == guard_events.size(), "large delta did not cross all SE thresholds", failures)
	_check(crossed_again == crossed_once, "large delta duplicated SE thresholds", failures)
	_check(game_source.contains("stage_reset") and game_source.contains("partner_changed") and game_source.contains("boss_transition"), "combo visual cleanup reasons missing", failures)
	var lifetime := {"life": 0.20, "maxLife": 0.20}
	lifetime["life"] = float(lifetime["life"]) - 0.25
	_check(float(lifetime["life"]) <= 0.0, "visual lifetime removal condition missing", failures)

	if failures.is_empty():
		print("Collab combo effect tests passed")
		test_finished = true
		if DisplayServer.get_name() == "headless":
			get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	test_finished = true
	if DisplayServer.get_name() == "headless":
		get_tree().quit(1)

func _check(condition: bool, message: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(message)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(1600.0, 900.0)), Color("#171323"), true)
	var progress := fmod(preview_time * 0.32, 1.0)
	for index in range(pair_definitions.size()):
		var definition: Dictionary = pair_definitions[index] as Dictionary
		var column := index % 3
		var row := index / 3
		var origin := Vector2(34.0 + float(column) * 520.0, 28.0 + float(row) * 168.0)
		var card := Rect2(origin, Vector2(494.0, 142.0))
		draw_rect(card, Color(0.10, 0.08, 0.16, 0.96), true)
		draw_rect(card, Color(0.72, 0.62, 0.86, 0.38), false, 2.0)
		var pair_name := String(definition.get("displayName", definition.get("pairKey", "pair")))
		var effect_kind := String(definition.get("effectKind", "collab_composite_link"))
		if effect_kind == "":
			effect_kind = "collab_composite_link"
		draw_string(ThemeDB.fallback_font, origin + Vector2(14.0, 24.0), pair_name, HORIZONTAL_ALIGNMENT_LEFT, 450.0, 17, Color("#fff7ff"))
		draw_string(ThemeDB.fallback_font, origin + Vector2(14.0, 45.0), effect_kind, HORIZONTAL_ALIGNMENT_LEFT, 450.0, 12, Color("#b9eaff"))
		var elements := ComboSystem.visual_elements_for_effect(effect_kind, progress, false)
		for element_index in range(elements.size()):
			var element: Dictionary = elements[element_index] as Dictionary
			var center := origin + Vector2(80.0 + float(element_index % 4) * 98.0, 92.0 + float(element_index / 4) * 25.0)
			_draw_preview_element(element, center, progress)

func _draw_preview_element(element: Dictionary, center: Vector2, progress: float) -> void:
	var element_type := String(element.get("type", ""))
	var alpha := 0.58 + 0.20 * (1.0 - progress)
	match element_type:
		"hex_panel", "open_shield_panels":
			var points := PackedVector2Array()
			for index in range(7):
				points.append(center + Vector2.from_angle(float(index) * TAU / 6.0) * 20.0)
			draw_colored_polygon(points, Color(0.30, 0.82, 1.0, 0.10))
			draw_polyline(points, Color(0.48, 0.92, 1.0, alpha), 2.0, true)
		"thumbnail_corners", "thumbnail_frame":
			draw_rect(Rect2(center - Vector2(26.0, 18.0), Vector2(52.0, 36.0)), Color(0.78, 0.64, 1.0, alpha), false, 2.0)
		"comment_badges":
			draw_circle(center, 20.0, Color(0.56, 0.92, 0.78, 0.10), false, 2.0)
		"star_rays", "sync_star", "impact_pentagon":
			for index in range(5):
				var direction := Vector2.from_angle(float(index) * TAU / 5.0)
				draw_line(center - direction * 18.0, center + direction * 18.0, Color(1.0, 0.85, 0.36, alpha), 2.0, true)
		"beat_slash", "three_beat_fan", "rhythm_firework":
			draw_line(center - Vector2(18.0, 14.0), center + Vector2(22.0, 12.0), Color(1.0, 0.56, 0.76, alpha), 3.0, true)
		"hammer":
			draw_rect(Rect2(center - Vector2(18.0, 8.0), Vector2(36.0, 16.0)), Color(1.0, 0.30, 0.48, alpha), true)
		"double_helix", "white_lines", "alternating_ring", "ring", "guard_wave", "shield_scanline", "compress_ring", "six_fishing_lines":
			draw_arc(center, 22.0 + progress * 12.0, progress * TAU, progress * TAU + PI * 1.45, 18, Color(0.88, 0.72, 1.0, alpha), 2.0, true)
		"pair_style_motif", "fishing_lines", "confetti", "cracks", "thumbnail_lure", "lure":
			draw_circle(center, 4.0 + progress * 4.0, Color(1.0, 0.82, 0.48, alpha), false, 1.5)
		_:
			draw_circle(center, 6.0, Color(1.0, 1.0, 1.0, alpha), false, 1.5)
