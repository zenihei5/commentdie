extends Node

const BossCutinSystemScript := preload("res://scripts/systems/boss_cutin_system.gd")
const ASSET_ROOT := "res://assets/generated/boss_cutin_v3_assets/"

func _ready() -> void:
	var failures: Array[String] = []
	_validate_manifest_assets(failures)
	var kusomaro_data := _data("boss_kuso_maro_king", 2.10, "marshmallow_pile", "marshmallow_crown_drop", 0.55)
	var kusomaro := _custom_view_at(kusomaro_data, 0.42)
	var kusomaro_crown := _custom_view_at(kusomaro_data, 0.87)
	var kusomaro_name := _custom_view_at(kusomaro_data, 0.96)
	var kusomaro_faded := _custom_view_at(kusomaro_data, 1.93)
	var bugged_data := _data("bugged_final_boss", 2.20, "bugged_game_final_boss", "bugged_name_correction", 0.65)
	var bugged := _custom_view_at(bugged_data, 0.54)
	var redpen := _custom_view_at(_data("red_pen_review_chief", 2.15, "redpen_rewrite", "", 0.60), 0.61)
	var collab := _custom_view_at(_data("collab_crusher", 2.20, "split_stream_crash", "", 0.65), 0.66)
	var pitch_data := _data("pitch_police_chief", 2.25, "pitch_violation_crackdown", "", 0.78)
	var pitch := _custom_view_at(pitch_data, 0.55)
	var pitch_exit := _custom_view_at(pitch_data, 0.79)
	var pitch_clear := _custom_view_at(pitch_data, 0.89)
	var final_data := _data("last_offline", 3.40, "stream_shutdown", "stream_shutdown_finale", 1.10)
	final_data["isFinalBoss"] = true
	var final_intro := _custom_view_at(final_data, 0.82)
	var final_finale := _custom_view_at(final_data, 1.68)
	_check(_texture_path_count(kusomaro, "marshmallows/marshmallow_") == 8, "marshmallow intro did not use eight unique cut PNGs", failures)
	_check(_unique_texture_path_count(kusomaro, "marshmallows/marshmallow_") == 8, "marshmallow cut PNGs contain duplicates", failures)
	_check(_fallback_path_count(kusomaro, ASSET_ROOT + "cutin_decor_marshmallow_small.png") == 8, "marshmallow atlas fallback/sourceUv is incomplete", failures)
	_check(not _has_top_level_type(kusomaro, "circle"), "marshmallow procedural circles are double-drawn", failures)
	_check(_texture_alpha(kusomaro_crown, "cutin_decor_kusomaro_crown.png") > 0.45, "kusomaro crown is not visible during its drop beat", failures)
	var crown_name_rect := _texture_rect(kusomaro_name, "cutin_decor_kusomaro_crown.png")
	_check(crown_name_rect.position.x >= 1280.0 and crown_name_rect.end.x <= 1530.0, "kusomaro crown is not on the empty right side of the name plate", failures)
	_check(_texture_alpha(kusomaro_name, "cutin_decor_kusomaro_crown.png") > 0.95, "kusomaro crown is not visible over the name presentation", failures)
	_check(_texture_alpha(kusomaro_faded, "cutin_decor_kusomaro_crown.png") <= 0.01, "kusomaro crown outlives the shared cut-in image fade", failures)
	for filename in ["cutin_bug_loading_bar.png", "cutin_bug_horizontal_noise.png", "cutin_bug_pixel_fragment.png", "boss_cutin_glitch_fragments.png"]:
		_check(_has_texture_suffix(bugged, filename), "bugged intro is missing %s" % filename, failures)
	for filename in ["cutin_redpen_line_set.png", "cutin_redpen_circle.png", "cutin_redpen_cross.png"]:
		_check(_has_texture_suffix(redpen, filename), "red-pen intro is missing %s" % filename, failures)
	_check(not _has_top_level_type(redpen, "line") and not _has_top_level_type(redpen, "arc"), "red-pen procedural strokes are double-drawn", failures)
	for filename in ["cutin_collab_vs_mark.png", "cutin_collab_crack.png", "cutin_collab_broken_heart.png"]:
		_check(_has_texture_suffix(collab, filename), "collab intro is missing %s" % filename, failures)
	_check(not _has_top_level_type(collab, "line") and not _has_top_level_type(collab, "heart") and not _has_top_level_type(collab, "text"), "collab procedural VS/crack/heart is double-drawn", failures)
	_check(_source_uv_texture_count(collab, "cutin_collab_broken_heart.png") == 2, "collab heart did not use two UV-cropped halves", failures)
	for filename in ["cutin_pitch_line.png", "cutin_pitch_violation_marker.png", "cutin_pitch_police_siren.png"]:
		_check(_has_texture_suffix(pitch, filename), "pitch-police intro is missing %s" % filename, failures)
	_check(_source_uv_texture_count(pitch, "cutin_pitch_line.png") == 2, "pitch guide/vocal lines do not share the supplied line with UV reveal", failures)
	_check(_source_uv_texture_count(pitch, "cutin_pitch_police_siren.png") == 2, "pitch siren did not use deterministic left/right UV halves", failures)
	_check(_source_uv_texture_count(pitch_exit, "cutin_pitch_line.png") >= 4, "pitch waveform did not split into pushed UV halves", failures)
	_check(_all_textures_have_fallback(pitch, ["cutin_pitch_line.png", "cutin_pitch_violation_marker.png", "cutin_pitch_police_siren.png"]), "pitch supplied assets do not all have per-part procedural fallback", failures)
	_check(_max_part_alpha(pitch_clear) <= 0.001, "pitch supplied assets remained over the shared name presentation", failures)
	for filename in ["cutin_lastoffline_power_icon.png", "cutin_lastoffline_eye_glow.png", "cutin_lastoffline_mouth_glow.png", "cutin_lastoffline_core_glow.png"]:
		_check(_has_texture_suffix(final_intro, filename), "FINAL intro is missing %s" % filename, failures)
	_check(_has_texture_suffix(final_finale, "boss_cutin_glitch_fragments.png"), "FINAL finale is missing supplied glitch fragments", failures)
	_check(not _has_top_level_type(final_intro, "circle") and not _has_top_level_type(final_intro, "power"), "FINAL procedural face/core is double-drawn", failures)
	var reduced_bug_data := bugged_data.duplicate(true)
	reduced_bug_data["reducedNoise"] = true
	reduced_bug_data["reducedFlash"] = true
	reduced_bug_data["reducedShake"] = true
	var reduced_bug := _custom_view_at(reduced_bug_data, 0.54)
	_check(_texture_alpha(reduced_bug, "cutin_bug_horizontal_noise.png") < _texture_alpha(bugged, "cutin_bug_horizontal_noise.png"), "reducedNoise did not lower supplied noise alpha", failures)
	_check(_texture_alpha(reduced_bug, "cutin_bug_pixel_fragment.png") < _texture_alpha(bugged, "cutin_bug_pixel_fragment.png"), "reducedNoise did not lower supplied pixel-fragment alpha", failures)
	_check(is_equal_approx(_texture_rect(reduced_bug, "cutin_bug_horizontal_noise.png").position.x, -20.0), "reducedShake did not remove supplied noise jitter", failures)
	var reduced_final_data := final_data.duplicate(true)
	reduced_final_data["reducedFlash"] = true
	var reduced_final := _custom_view_at(reduced_final_data, 0.55)
	var normal_final := _custom_view_at(final_data, 0.55)
	_check(_texture_alpha(reduced_final, "cutin_lastoffline_eye_glow.png") < _texture_alpha(normal_final, "cutin_lastoffline_eye_glow.png"), "reducedFlash did not lower supplied eye glow", failures)
	var reduced_pitch_data := pitch_data.duplicate(true)
	reduced_pitch_data["reducedFlash"] = true
	reduced_pitch_data["reducedNoise"] = true
	reduced_pitch_data["reducedShake"] = true
	var reduced_pitch := _custom_view_at(reduced_pitch_data, 0.55)
	_check(float(reduced_pitch.get("sirenAlpha", 1.0)) < float(pitch.get("sirenAlpha", 0.0)), "pitch accessibility options did not lower supplied siren alpha", failures)
	_check((reduced_pitch.get("pitchLineJitter", Vector2.ONE) as Vector2).is_zero_approx(), "pitch reducedShake did not remove supplied waveform jitter", failures)
	for custom in [kusomaro, kusomaro_crown, kusomaro_name, kusomaro_faded, bugged, redpen, collab, pitch, pitch_exit, pitch_clear, final_intro, final_finale]:
		_check(not _contains_damage_part((custom as Dictionary).get("parts", []) as Array), "supplied texture part exposed damage data", failures)
	if failures.is_empty():
		print("Boss cut-in supplied asset tests passed")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	get_tree().quit(1)

func _validate_manifest_assets(failures: Array[String]) -> void:
	var file := FileAccess.open("res://assets/generated/boss_cutin_v3_assets/manifest.json", FileAccess.READ)
	_check(file != null, "supplied asset manifest could not be opened", failures)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	_check(parsed is Dictionary, "supplied asset manifest is invalid", failures)
	if not parsed is Dictionary:
		return
	var assets: Array = (parsed as Dictionary).get("assets", []) as Array
	_check(assets.size() == 23, "manifest does not contain exactly 23 supplied assets", failures)
	for item in assets:
		var entry: Dictionary = item as Dictionary
		var path := "res://" + String(entry.get("output", ""))
		var image := Image.new()
		_check(image.load(path) == OK, "supplied asset could not be read: %s" % path, failures)
		if image.is_empty():
			continue
		var expected: Array = entry.get("outputSize", []) as Array
		if expected.size() == 2:
			_check(image.get_size() == Vector2i(int(expected[0]), int(expected[1])), "supplied asset size differs from manifest: %s" % path, failures)

func _data(boss_id: String, duration: float, intro_id: String, finale_id: String, custom_duration: float) -> Dictionary:
	return {
		"version": 3, "bossId": boss_id, "displayName": boss_id, "durationSeconds": duration,
		"customIntroId": intro_id, "customFinaleId": finale_id, "customIntroDurationSeconds": custom_duration,
		"useSilhouetteReveal": true, "useCommentBurst": true, "connectImageToBossSpawn": true, "useBossIntroPose": true
	}

func _custom_view_at(data: Dictionary, time: float) -> Dictionary:
	var runtime := BossCutinSystemScript.start(data, "debug_return", "playing")
	runtime = (BossCutinSystemScript.update(runtime, time).get("runtime", {}) as Dictionary)
	return BossCutinSystemScript.build_view(runtime).get("customView", {}) as Dictionary

func _has_texture_suffix(custom: Dictionary, suffix: String) -> bool:
	return _texture_part(custom, suffix) != null

func _texture_part(custom: Dictionary, suffix: String) -> Variant:
	for item in custom.get("parts", []) as Array:
		var part: Dictionary = item as Dictionary
		if String(part.get("type", "")) == "texture" and String(part.get("path", "")).ends_with(suffix):
			return part
	return null

func _texture_alpha(custom: Dictionary, suffix: String) -> float:
	var value: Variant = _texture_part(custom, suffix)
	if value == null:
		return -1.0
	return float(((value as Dictionary).get("color", Color.TRANSPARENT) as Color).a)

func _texture_rect(custom: Dictionary, suffix: String) -> Rect2:
	var value: Variant = _texture_part(custom, suffix)
	return Rect2() if value == null else (value as Dictionary).get("rect", Rect2()) as Rect2

func _texture_path_count(custom: Dictionary, fragment: String) -> int:
	var count := 0
	for item in custom.get("parts", []) as Array:
		var part: Dictionary = item as Dictionary
		if String(part.get("type", "")) == "texture" and String(part.get("path", "")).contains(fragment):
			count += 1
	return count

func _unique_texture_path_count(custom: Dictionary, fragment: String) -> int:
	var paths: Dictionary = {}
	for item in custom.get("parts", []) as Array:
		var part: Dictionary = item as Dictionary
		var path := String(part.get("path", ""))
		if String(part.get("type", "")) == "texture" and path.contains(fragment):
			paths[path] = true
	return paths.size()

func _fallback_path_count(custom: Dictionary, path: String) -> int:
	var count := 0
	for item in custom.get("parts", []) as Array:
		var part: Dictionary = item as Dictionary
		if String(part.get("fallbackPath", "")) == path and part.has("fallbackSourceUv"):
			count += 1
	return count

func _source_uv_texture_count(custom: Dictionary, suffix: String) -> int:
	var count := 0
	for item in custom.get("parts", []) as Array:
		var part: Dictionary = item as Dictionary
		if String(part.get("type", "")) == "texture" and String(part.get("path", "")).ends_with(suffix) and part.has("sourceUv"):
			count += 1
	return count

func _has_top_level_type(custom: Dictionary, type_id: String) -> bool:
	for item in custom.get("parts", []) as Array:
		if String((item as Dictionary).get("type", "")) == type_id:
			return true
	return false

func _all_textures_have_fallback(custom: Dictionary, suffixes: Array) -> bool:
	for item in custom.get("parts", []) as Array:
		var part: Dictionary = item as Dictionary
		if String(part.get("type", "")) != "texture":
			continue
		var path := String(part.get("path", ""))
		for suffix_value in suffixes:
			if path.ends_with(String(suffix_value)) and (part.get("fallbackParts", []) as Array).is_empty():
				return false
	return true

func _max_part_alpha(custom: Dictionary) -> float:
	var result := 0.0
	for item in custom.get("parts", []) as Array:
		var part: Dictionary = item as Dictionary
		result = maxf(result, float((part.get("color", Color.TRANSPARENT) as Color).a))
	return result

func _contains_damage_part(parts: Array) -> bool:
	for item in parts:
		var part: Dictionary = item as Dictionary
		for forbidden_key in ["damage", "hitbox", "attack", "collision", "projectile"]:
			if part.has(forbidden_key):
				return true
	return false

func _check(condition: bool, message: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(message)
