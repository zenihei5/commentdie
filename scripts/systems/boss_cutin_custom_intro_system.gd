class_name BossCutinCustomIntroSystem
extends RefCounted

const NORMAL_PART_LIMIT := 24
const FINAL_PART_LIMIT := 40
const ASSET_ROOT := "res://assets/generated/boss_cutin_v3_assets/"
const MARSHMALLOW_ATLAS := ASSET_ROOT + "cutin_decor_marshmallow_small.png"
const MARSHMALLOW_IDS: Array[String] = ["01", "03", "07", "09", "12", "14", "18", "22"]
const MARSHMALLOW_SIZES: Array[Vector2] = [Vector2(152, 156), Vector2(156, 155), Vector2(138, 147), Vector2(146, 154), Vector2(153, 163), Vector2(159, 160), Vector2(137, 133), Vector2(162, 153)]
const MARSHMALLOW_ATLAS_UVS: Array[Rect2] = [
	Rect2(0, 0, 281, 293), Rect2(516, 0, 236, 293), Rect2(281, 293, 235, 232), Rect2(752, 293, 234, 232),
	Rect2(281, 525, 235, 231), Rect2(752, 525, 234, 231), Rect2(516, 756, 236, 224), Rect2(281, 980, 235, 274)
]

const INTRO_IDS: Array[String] = [
	"marshmallow_pile",
	"pitch_violation_crackdown",
	"redpen_rewrite",
	"split_stream_crash",
	"bugged_game_final_boss",
	"stream_shutdown"
]
const FINALE_IDS: Array[String] = [
	"marshmallow_crown_drop",
	"bugged_name_correction",
	"stream_shutdown_finale"
]

static func supports_intro(intro_id: String) -> bool:
	return intro_id == "" or INTRO_IDS.has(intro_id)

static func supports_finale(finale_id: String) -> bool:
	return finale_id == "" or FINALE_IDS.has(finale_id)

static func build_view(data: Dictionary, runtime: Dictionary, common_view: Dictionary) -> Dictionary:
	# Custom effects are reconstructed from the active runtime every frame.  An
	# inactive/cancelled/watchdog-completed runtime must not retain glitch parts.
	if not bool(runtime.get("active", false)):
		return {}
	var intro_id := String(data.get("customIntroId", ""))
	var finale_id := String(data.get("customFinaleId", ""))
	var intro_supported := supports_intro(intro_id)
	var finale_supported := supports_finale(finale_id)
	var parts: Array[Dictionary] = []
	if intro_supported:
		match intro_id:
			"marshmallow_pile":
				parts = _marshmallow_parts(common_view)
			"pitch_violation_crackdown":
				parts = _pitch_police_parts(common_view, data)
			"redpen_rewrite":
				parts = _redpen_parts(common_view, data)
			"split_stream_crash":
				parts = _collab_parts(common_view)
			"bugged_game_final_boss":
				parts = _bugged_game_parts(common_view, data)
			"stream_shutdown":
				parts = _shutdown_parts(common_view, runtime, data)
	if finale_supported:
		match finale_id:
			"marshmallow_crown_drop":
				parts.append_array(_marshmallow_crown_parts(common_view))
			"bugged_name_correction":
				parts.append_array(_bugged_name_parts(common_view, data))
			"stream_shutdown_finale":
				parts.append_array(_shutdown_finale_parts(common_view, data))
	var is_final := bool(data.get("isFinalBoss", false))
	var limit := FINAL_PART_LIMIT if is_final else NORMAL_PART_LIMIT
	if parts.size() > limit:
		parts.resize(limit)
	var result := {
		"introId": intro_id,
		"finaleId": finale_id,
		"introSupported": intro_supported,
		"finaleSupported": finale_supported,
		"fallbackToCommon": not intro_supported or not finale_supported,
		"partLimit": limit,
		"partCount": parts.size(),
		"parts": parts
	}
	if intro_id == "bugged_game_final_boss" and intro_supported:
		result.merge(_bugged_game_metrics(common_view, data), true)
	if intro_id == "pitch_violation_crackdown" and intro_supported:
		result.merge(_pitch_police_metrics(common_view, data), true)
	return result

static func effect_parts(custom_view: Dictionary) -> Array:
	return custom_view.get("parts", []) as Array

static func _marshmallow_parts(view: Dictionary) -> Array[Dictionary]:
	var parts: Array[Dictionary] = []
	var p := clampf(float(view.get("customIntroProgress", 0.0)), 0.0, 1.0)
	var eased := _smooth(p)
	var reveal_fade := lerpf(1.0, 0.28, clampf(float(view.get("colorRevealProgress", 0.0)), 0.0, 1.0))
	for i in range(8):
		var column := float(i % 4)
		var row := float(i / 4)
		var landing := Vector2(165.0 + column * 118.0 + row * 34.0, 660.0 - row * 86.0 + sin(float(i) * 1.7) * 12.0)
		var start := Vector2(110.0 + column * 145.0, -90.0 - float(i) * 38.0)
		var pos := start.lerp(landing, eased)
		var landing_pulse := sin(clampf((p - 0.68) / 0.32, 0.0, 1.0) * PI)
		var width := 62.0 + float(i % 4) * 8.0
		var source_size := MARSHMALLOW_SIZES[i]
		var size := Vector2(width, width * source_size.y / source_size.x)
		var rect := Rect2(pos - size * 0.5, size)
		var fallback_circle := {"type": "circle", "pos": pos, "radius": width * 0.43, "color": Color(1.0, 0.90 + float(i % 2) * 0.05, 0.97, 0.92 * p * reveal_fade), "outline": Color(1.0, 0.34, 0.68, 0.82 * p * reveal_fade)}
		parts.append({
			"type": "texture", "layer": "intro_front",
			"path": ASSET_ROOT + "marshmallows/marshmallow_%s.png" % MARSHMALLOW_IDS[i],
			"fallbackPath": MARSHMALLOW_ATLAS, "fallbackSourceUv": MARSHMALLOW_ATLAS_UVS[i],
			"rect": rect, "scaleCenter": pos, "scale": Vector2(1.0 + landing_pulse * 0.16, 1.0 - landing_pulse * 0.18),
			"color": Color(1.0, 1.0, 1.0, 0.92 * p * reveal_fade), "fallbackParts": [fallback_circle]
		})
	return parts

static func _marshmallow_crown_parts(view: Dictionary) -> Array[Dictionary]:
	var p := clampf(float(view.get("customFinaleProgress", 0.0)), 0.0, 1.0)
	if p <= 0.0:
		return []
	var fall := _smooth(p)
	# Land the badge over the empty right side of the common name plate.  The
	# finale layer is drawn after the name, so the crown remains crisp without
	# covering the boss text itself.
	var y := lerpf(300.0, 365.0, fall) - sin(p * PI) * 10.0
	var rect := Rect2(1375.0, y, 145.0, 107.0)
	var center := rect.get_center()
	var appear := _smooth(clampf(p / 0.20, 0.0, 1.0))
	# Match the same field-handoff fade used by the boss image/name presentation,
	# rather than giving the crown a separate early disappearance.
	var alpha := appear * clampf(float(view.get("cutinImageAlpha", 1.0)), 0.0, 1.0)
	return [
		{"type": "texture", "layer": "finale", "path": ASSET_ROOT + "cutin_decor_kusomaro_crown.png", "rect": rect, "scaleCenter": center, "scale": Vector2.ONE, "color": Color(1, 1, 1, alpha), "fallbackParts": [
			{"type": "poly", "points": PackedVector2Array([center + Vector2(-65, 28), center + Vector2(-51, -33), center + Vector2(-14, 5), center + Vector2(19, -45), center + Vector2(49, 5), center + Vector2(69, -28), center + Vector2(61, 32)]), "color": Color(1.0, 0.72, 0.18, alpha), "outline": Color(1.0, 0.97, 0.65, alpha)}
		]}
	]

static func _pitch_police_metrics(view: Dictionary, data: Dictionary) -> Dictionary:
	var elapsed := float(view.get("elapsed", 0.0))
	var reduced_flash := bool(data.get("reducedFlash", false))
	var reduced_noise := bool(data.get("reducedNoise", false))
	var reduced_shake := bool(data.get("reducedShake", false))
	var line_reveal := _time_progress(elapsed, 0.06, 0.25)
	var deviation := _time_progress(elapsed, 0.27, 0.35)
	var push := _time_progress(elapsed, 0.70, 0.88)
	var exit_alpha := 1.0 - push
	var marker_appear := _time_progress(elapsed, 0.43, 0.51)
	var marker_scale := lerpf(1.40, 0.92, _time_progress(elapsed, 0.43, 0.51))
	if elapsed >= 0.51:
		marker_scale = lerpf(0.92, 1.0, _time_progress(elapsed, 0.51, 0.56))
	var marker_brightness := 1.0
	if not reduced_flash and elapsed >= 0.51 and elapsed < 0.69:
		var pulse_index := int(floor((elapsed - 0.51) / 0.09))
		marker_brightness = 0.62 if pulse_index % 2 == 1 else 1.0
	var marker_alpha := marker_appear * exit_alpha * marker_brightness
	var siren_cycle_seconds := 0.18 if reduced_noise else 0.11
	var siren_side := 0
	if elapsed >= 0.50:
		siren_side = int(floor((elapsed - 0.50) / siren_cycle_seconds)) % 2
	var siren_cap := 1.0
	if reduced_noise:
		siren_cap = minf(siren_cap, 0.62)
	if reduced_flash:
		siren_cap = minf(siren_cap, 0.58)
	var siren_alpha := _time_progress(elapsed, 0.50, 0.54) * exit_alpha * siren_cap
	var impact_envelope := _time_progress(elapsed, 0.30, 0.35) * (1.0 - _time_progress(elapsed, 0.42, 0.48))
	var jitter_scale := 0.0 if reduced_shake else (0.5 if reduced_noise else 1.0)
	var frame := float(view.get("frame", 0))
	var line_jitter := Vector2(sin(frame * 1.37) * 4.0, cos(frame * 1.91) * 8.0) * impact_envelope * jitter_scale
	return {
		"pitchLineReveal": line_reveal,
		"pitchLineAlpha": line_reveal * exit_alpha,
		"pitchDeviationProgress": deviation,
		"pitchPushProgress": push,
		"pitchLineJitter": line_jitter,
		"violationMarkerAlpha": marker_alpha,
		"violationMarkerScale": marker_scale,
		"sirenAlpha": siren_alpha,
		"sirenSide": siren_side,
		"sirenCycleSeconds": siren_cycle_seconds,
		"reducedFlashApplied": reduced_flash,
		"reducedNoiseApplied": reduced_noise,
		"reducedShakeApplied": reduced_shake
	}

static func _pitch_police_parts(view: Dictionary, data: Dictionary) -> Array[Dictionary]:
	var metrics := _pitch_police_metrics(view, data)
	var reveal := float(metrics.get("pitchLineReveal", 0.0))
	var push := float(metrics.get("pitchPushProgress", 0.0))
	var line_alpha := float(metrics.get("pitchLineAlpha", 0.0))
	var jitter: Vector2 = metrics.get("pitchLineJitter", Vector2.ZERO) as Vector2
	var parts: Array[Dictionary] = []
	var line_path := ASSET_ROOT + "cutin_pitch_line.png"
	var source_width := 2099.0 * reveal
	var guide_rect := Rect2(130, 392, 1340.0 * reveal, 120)
	var vocal_rect := Rect2(Vector2(130, 300) + jitter, Vector2(1340.0 * reveal, 280))
	var guide_fallback: Array[Dictionary] = [
		{"type": "line", "from": Vector2(130, 452), "to": Vector2(130 + 1340.0 * reveal, 452), "color": Color(0.70, 0.96, 1.0, line_alpha * 0.58), "width": 4.0}
	]
	var vocal_fallback: Array[Dictionary] = [
		{"type": "line", "from": Vector2(130, 438) + jitter, "to": Vector2(560, 438) + jitter, "color": Color(1.0, 0.30, 0.63, line_alpha * 0.96), "width": 7.0},
		{"type": "line", "from": Vector2(560, 438) + jitter, "to": Vector2(650, 318) + jitter, "color": Color(1.0, 0.30, 0.63, line_alpha * 0.96), "width": 7.0},
		{"type": "line", "from": Vector2(650, 318) + jitter, "to": Vector2(760, 510) + jitter, "color": Color(1.0, 0.30, 0.63, line_alpha * 0.96), "width": 7.0},
		{"type": "line", "from": Vector2(760, 510) + jitter, "to": Vector2(1470, 438) + jitter, "color": Color(1.0, 0.30, 0.63, line_alpha * 0.96), "width": 7.0}
	]
	parts.append({"type": "texture", "layer": "intro_back", "path": line_path, "rect": guide_rect, "sourceUv": Rect2(0, 0, source_width, 453), "color": Color(0.70, 0.96, 1.0, line_alpha * 0.58 * (1.0 - push)), "fallbackParts": guide_fallback})
	parts.append({"type": "texture", "layer": "intro_front", "path": line_path, "rect": vocal_rect, "sourceUv": Rect2(0, 0, source_width, 453), "color": Color(1.0, 0.48, 0.78, line_alpha * 0.96 * (1.0 - push)), "fallbackParts": vocal_fallback})
	var split_alpha := sin(push * PI)
	if split_alpha > 0.001:
		var split_offset := 140.0 * push
		var half_source_width := 1049.5
		parts.append({"type": "texture", "layer": "intro_back", "path": line_path, "rect": Rect2(130 - split_offset, 392, 670, 120), "sourceUv": Rect2(0, 0, half_source_width, 453), "color": Color(0.70, 0.96, 1.0, split_alpha * 0.58), "fallbackParts": [{"type": "line", "from": Vector2(130 - split_offset, 452), "to": Vector2(800 - split_offset, 452), "color": Color(0.70, 0.96, 1.0, split_alpha * 0.58), "width": 4.0}]})
		parts.append({"type": "texture", "layer": "intro_back", "path": line_path, "rect": Rect2(800 + split_offset, 392, 670, 120), "sourceUv": Rect2(half_source_width, 0, half_source_width, 453), "color": Color(0.70, 0.96, 1.0, split_alpha * 0.58), "fallbackParts": [{"type": "line", "from": Vector2(800 + split_offset, 452), "to": Vector2(1470 + split_offset, 452), "color": Color(0.70, 0.96, 1.0, split_alpha * 0.58), "width": 4.0}]})
		parts.append({"type": "texture", "layer": "intro_front", "path": line_path, "rect": Rect2(Vector2(130 - split_offset, 300) + jitter, Vector2(670, 280)), "sourceUv": Rect2(0, 0, half_source_width, 453), "color": Color(1.0, 0.48, 0.78, split_alpha * 0.96), "fallbackParts": [{"type": "line", "from": Vector2(130 - split_offset, 438) + jitter, "to": Vector2(800 - split_offset, 438) + jitter, "color": Color(1.0, 0.30, 0.63, split_alpha * 0.96), "width": 7.0}]})
		parts.append({"type": "texture", "layer": "intro_front", "path": line_path, "rect": Rect2(Vector2(800 + split_offset, 300) + jitter, Vector2(670, 280)), "sourceUv": Rect2(half_source_width, 0, half_source_width, 453), "color": Color(1.0, 0.48, 0.78, split_alpha * 0.96), "fallbackParts": [{"type": "line", "from": Vector2(800 + split_offset, 438) + jitter, "to": Vector2(1470 + split_offset, 438) + jitter, "color": Color(1.0, 0.30, 0.63, split_alpha * 0.96), "width": 7.0}]})
	var marker_alpha := float(metrics.get("violationMarkerAlpha", 0.0))
	var marker_rect := Rect2(525, 185, 250, 234)
	var marker_color := Color(1, 1, 1, marker_alpha)
	parts.append({"type": "texture", "layer": "intro_front", "path": ASSET_ROOT + "cutin_pitch_violation_marker.png", "rect": marker_rect, "scaleCenter": marker_rect.get_center(), "scale": Vector2.ONE * float(metrics.get("violationMarkerScale", 1.0)), "color": marker_color, "fallbackParts": [
		{"type": "line", "from": Vector2(525, 255), "to": Vector2(525, 185), "color": Color(1.0, 0.20, 0.35, marker_alpha), "width": 9.0},
		{"type": "line", "from": Vector2(525, 185), "to": Vector2(600, 185), "color": Color(1.0, 0.74, 0.18, marker_alpha), "width": 9.0},
		{"type": "line", "from": Vector2(775, 350), "to": Vector2(775, 419), "color": Color(1.0, 0.20, 0.35, marker_alpha), "width": 9.0},
		{"type": "line", "from": Vector2(700, 419), "to": Vector2(775, 419), "color": Color(1.0, 0.74, 0.18, marker_alpha), "width": 9.0}
	]})
	var siren_alpha := float(metrics.get("sirenAlpha", 0.0))
	var siren_side := int(metrics.get("sirenSide", 0))
	var siren_path := ASSET_ROOT + "cutin_pitch_police_siren.png"
	parts.append({"type": "texture", "layer": "intro_back", "path": siren_path, "rect": Rect2(650, 72, 300, 213), "color": Color(1, 1, 1, siren_alpha * 0.32), "fallbackParts": [
		{"type": "poly", "points": PackedVector2Array([Vector2(650, 225), Vector2(725, 72), Vector2(800, 225)]), "color": Color(1.0, 0.18, 0.34, siren_alpha * 0.24)},
		{"type": "poly", "points": PackedVector2Array([Vector2(800, 225), Vector2(875, 72), Vector2(950, 225)]), "color": Color(0.18, 0.78, 1.0, siren_alpha * 0.24)}
	]})
	var left_alpha := siren_alpha * (1.0 if siren_side == 0 else 0.20)
	var right_alpha := siren_alpha * (1.0 if siren_side == 1 else 0.20)
	parts.append({"type": "texture", "layer": "intro_front", "path": siren_path, "rect": Rect2(650, 72, 150, 213), "sourceUv": Rect2(0, 0, 464, 660), "color": Color(1, 1, 1, left_alpha), "fallbackParts": [{"type": "poly", "points": PackedVector2Array([Vector2(650, 225), Vector2(725, 72), Vector2(800, 225)]), "color": Color(1.0, 0.18, 0.34, left_alpha)}]})
	parts.append({"type": "texture", "layer": "intro_front", "path": siren_path, "rect": Rect2(800, 72, 150, 213), "sourceUv": Rect2(464, 0, 464, 660), "color": Color(1, 1, 1, right_alpha), "fallbackParts": [{"type": "poly", "points": PackedVector2Array([Vector2(800, 225), Vector2(875, 72), Vector2(950, 225)]), "color": Color(0.18, 0.78, 1.0, right_alpha)}]})
	parts.append({"type": "poly", "layer": "intro_back", "points": PackedVector2Array([Vector2(0, 0), Vector2(800, 0), Vector2(650, 270), Vector2(0, 230)]), "color": Color(1.0, 0.12, 0.28, left_alpha * 0.16)})
	parts.append({"type": "poly", "layer": "intro_back", "points": PackedVector2Array([Vector2(800, 0), Vector2(1600, 0), Vector2(1600, 230), Vector2(950, 270)]), "color": Color(0.12, 0.72, 1.0, right_alpha * 0.16)})
	return parts

static func _redpen_parts(view: Dictionary, data: Dictionary) -> Array[Dictionary]:
	var p := clampf(float(view.get("customIntroProgress", 0.0)), 0.0, 1.0)
	var reveal := clampf(float(view.get("colorRevealProgress", 0.0)), 0.0, 1.0)
	var parts: Array[Dictionary] = []
	var marks: Array[PackedVector2Array] = [
		PackedVector2Array([Vector2(90, 210), Vector2(580, 210)]),
		PackedVector2Array([Vector2(160, 310), Vector2(630, 360)]),
		PackedVector2Array([Vector2(95, 485), Vector2(510, 430)]),
		PackedVector2Array([Vector2(170, 630), Vector2(620, 610)])
	]
	var line_clip := clampf(p * 1.45, 0.0, 1.0)
	var line_fallbacks: Array[Dictionary] = []
	for i in range(marks.size()):
		var mark_reveal := clampf(p * 1.8 - float(i) * 0.18, 0.0, 1.0)
		var points: PackedVector2Array = marks[i]
		line_fallbacks.append({"type": "line", "from": points[0], "to": points[0].lerp(points[1], mark_reveal), "color": Color(1.0, 0.12, 0.28, 0.92 * mark_reveal), "width": 9.0})
	parts.append({"type": "texture", "layer": "intro_back", "path": ASSET_ROOT + "cutin_redpen_line_set.png", "rect": Rect2(55, 205, 650.0 * line_clip, 366), "sourceUv": Rect2(0, 0, 1672.0 * line_clip, 941), "color": Color(1, 1, 1, 0.48 * p), "fallbackParts": line_fallbacks})
	var circle_progress := _smooth(clampf((p - 0.16) / 0.42, 0.0, 1.0))
	parts.append({"type": "texture", "layer": "intro_front", "path": ASSET_ROOT + "cutin_redpen_circle.png", "rect": Rect2(105, 130, 570, 564), "scaleCenter": Vector2(390, 412), "scale": Vector2.ONE * lerpf(0.92, 1.0, circle_progress), "color": Color(1, 1, 1, 0.86 * circle_progress * lerpf(1.0, 0.52, reveal)), "fallbackParts": [
		{"type": "arc", "pos": Vector2(390, 412), "radius": 250.0, "from": -0.35, "to": TAU - 0.48, "color": Color(1.0, 0.08, 0.16, 0.86 * circle_progress), "width": 13.0}
	]})
	var cross_progress := _smooth(clampf((p - 0.56) / 0.22, 0.0, 1.0))
	var cross_alpha := 0.88 * cross_progress * lerpf(1.0, 0.205, reveal)
	parts.append({"type": "texture", "layer": "intro_front", "path": ASSET_ROOT + "cutin_redpen_cross.png", "rect": Rect2(105, 145, 570, 524), "scaleCenter": Vector2(390, 407), "scale": Vector2.ONE, "color": Color(1, 1, 1, cross_alpha), "fallbackParts": [
		{"type": "line", "from": Vector2(180, 190), "to": Vector2(620, 670), "color": Color(1.0, 0.07, 0.22, cross_alpha), "width": 18.0},
		{"type": "line", "from": Vector2(620, 190), "to": Vector2(180, 670), "color": Color(1.0, 0.07, 0.22, cross_alpha), "width": 18.0}
	]})
	if bool(data.get("useFakeNameCorrection", false)):
		parts.append({"type": "text", "layer": "finale", "pos": Vector2(740, 535), "text": "修正！", "width": 300, "size": 44, "color": Color(1.0, 0.16, 0.33, cross_alpha)})
	return parts

static func _collab_parts(view: Dictionary) -> Array[Dictionary]:
	var p := clampf(float(view.get("customIntroProgress", 0.0)), 0.0, 1.0)
	var impact := clampf((p - 0.42) * 1.8, 0.0, 1.0)
	var name_progress := clampf(float(view.get("nameProgress", 0.0)), 0.0, 1.0)
	var parts: Array[Dictionary] = [
		{"type": "rect", "layer": "intro_back", "rect": Rect2(0, 0, 800, 900), "color": Color(1.0, 0.18, 0.48, 0.16 * p)},
		{"type": "rect", "layer": "intro_back", "rect": Rect2(800, 0, 800, 900), "color": Color(0.18, 0.78, 1.0, 0.16 * p)}
	]
	var vs_progress := _smooth(clampf(p / 0.34, 0.0, 1.0))
	var vs_alpha := vs_progress * (1.0 - impact * 0.76) * (1.0 - name_progress)
	parts.append({"type": "texture", "layer": "intro_front", "path": ASSET_ROOT + "cutin_collab_vs_mark.png", "rect": Rect2(675, 270, 250, 264), "scaleCenter": Vector2(800, 402), "scale": Vector2.ONE * lerpf(0.85, 1.0, vs_progress), "color": Color(1, 1, 1, vs_alpha), "fallbackParts": [
		{"type": "text", "pos": Vector2(680, 455), "text": "VS", "width": 240, "size": 76, "color": Color(1, 1, 1, vs_alpha)}
	]})
	var crack_reveal := _smooth(clampf((p - 0.42) / 0.34, 0.0, 1.0))
	var crack_height := 827.0 * crack_reveal
	parts.append({"type": "texture", "layer": "intro_front", "path": ASSET_ROOT + "cutin_collab_crack.png", "rect": Rect2(685, 418.5 - crack_height * 0.5, 230, crack_height), "sourceUv": Rect2(0, 752.5 - 1505.0 * crack_reveal * 0.5, 419, 1505.0 * crack_reveal), "color": Color(1, 1, 1, crack_reveal * lerpf(0.95, 0.30, name_progress)), "fallbackParts": [
		{"type": "line", "from": Vector2(800, 5), "to": Vector2(800, 832), "color": Color(1, 1, 1, crack_reveal * 0.90), "width": 4.0}
	]})
	var heart_progress := _smooth(clampf((p - 0.52) / 0.28, 0.0, 1.0))
	var heart_alpha := heart_progress * (1.0 - name_progress * 0.72)
	var split_offset := 24.0 * impact
	parts.append({"type": "texture", "layer": "finale", "path": ASSET_ROOT + "cutin_collab_broken_heart.png", "rect": Rect2(735 - split_offset, 492, 65, 114), "sourceUv": Rect2(0, 0, 530, 930), "color": Color(1, 1, 1, heart_alpha), "fallbackParts": [
		{"type": "heart", "pos": Vector2(800, 545), "size": 104.0, "leftColor": Color(1.0, 0.30, 0.62, heart_alpha), "rightColor": Color(0.25, 0.86, 1.0, heart_alpha)}
	]})
	parts.append({"type": "texture", "layer": "finale", "path": ASSET_ROOT + "cutin_collab_broken_heart.png", "rect": Rect2(800 + split_offset, 492, 65, 114), "sourceUv": Rect2(530, 0, 530, 930), "color": Color(1, 1, 1, heart_alpha)})
	return parts

static func _shutdown_parts(view: Dictionary, runtime: Dictionary, data: Dictionary) -> Array[Dictionary]:
	var elapsed := float(view.get("elapsed", 0.0))
	var parts: Array[Dictionary] = []
	var snapshot: Array = runtime.get("chatDisplaySnapshot", []) as Array
	for i in range(mini(7, snapshot.size())):
		var disappear := _smooth(clampf((elapsed - float(i) * 0.035) / 0.11, 0.0, 1.0))
		parts.append({
			"type": "chat", "layer": "intro_front", "rect": Rect2(1190, 96 + float(i) * 72.0, 350, 54),
			"text": String(snapshot[i]), "alpha": 1.0 - disappear
		})
	var core := Vector2(800, 408)
	for i in range(5):
		var appear := _smooth(clampf((elapsed - (0.08 + float(i) * 0.08)) / 0.09, 0.0, 1.0))
		var absorb := _smooth(clampf((elapsed - 0.56) / 0.24, 0.0, 1.0))
		var start := Vector2(470 + float(i) * 165, 210 + absf(float(i) - 2.0) * 34)
		var pos := start.lerp(core, absorb)
		parts.append({"type": "diamond", "layer": "intro_front", "pos": pos, "size": 58.0 * appear * lerpf(1.0, 0.12, absorb), "color": Color(0.58 + float(i) * 0.06, 0.34, 1.0 - float(i) * 0.07, appear * (1.0 - absorb))})
		parts.append({"type": "line", "layer": "intro_back", "from": start, "to": pos, "color": Color(0.72, 0.42, 1.0, 0.24 * appear * (1.0 - absorb)), "width": 3.0})
	var reduced_flash := bool(data.get("reducedFlash", false))
	var power_alpha := _time_progress(elapsed, 0.10, 0.20) * (1.0 - _time_progress(elapsed, 0.55, 0.60))
	var power_scale := lerpf(0.82, 1.0, _time_progress(elapsed, 0.10, 0.28))
	parts.append({"type": "texture", "layer": "intro_front", "path": ASSET_ROOT + "cutin_lastoffline_power_icon.png", "rect": Rect2(710, 315, 180, 179), "scaleCenter": Vector2(800, 404.5), "scale": Vector2.ONE * power_scale, "color": Color(1, 1, 1, power_alpha), "fallbackParts": [
		{"type": "power", "pos": core, "size": 78.0 * power_scale, "color": Color(1.0, 0.72, 0.94, power_alpha)}
	]})
	var eye_alpha := _time_progress(elapsed, 0.26, 0.38) * (1.0 - _time_progress(elapsed, 0.84, 0.92)) * (0.52 if reduced_flash else 0.78)
	parts.append({"type": "texture", "layer": "intro_front", "path": ASSET_ROOT + "cutin_lastoffline_eye_glow.png", "rect": Rect2(470, 180, 660, 198), "color": Color(1, 1, 1, eye_alpha), "fallbackParts": [
		{"type": "circle", "pos": core + Vector2(-85, -62), "radius": 18.0, "color": Color(1.0, 0.34, 0.80, eye_alpha)},
		{"type": "circle", "pos": core + Vector2(85, -62), "radius": 18.0, "color": Color(0.52, 0.76, 1.0, eye_alpha)}
	]})
	var mouth_alpha := _time_progress(elapsed, 0.45, 0.59) * (1.0 - _time_progress(elapsed, 0.96, 1.05)) * 0.72
	parts.append({"type": "texture", "layer": "intro_front", "path": ASSET_ROOT + "cutin_lastoffline_mouth_glow.png", "rect": Rect2(520, 380, 560, 200), "color": Color(1, 1, 1, mouth_alpha), "fallbackParts": [
		{"type": "arc", "pos": core + Vector2(0, 45), "radius": 108.0, "from": 0.20, "to": PI - 0.20, "color": Color(0.92, 0.42, 1.0, mouth_alpha), "width": 14.0}
	]})
	var core_appear := _time_progress(elapsed, 0.72, 0.86)
	var core_absorb := _time_progress(elapsed, 1.08, 1.25)
	var core_alpha := core_appear * (1.0 - core_absorb) * (0.68 if reduced_flash else 1.0)
	parts.append({"type": "texture", "layer": "intro_front", "path": ASSET_ROOT + "cutin_lastoffline_core_glow.png", "rect": Rect2(690, 570, 220, 216), "scaleCenter": Vector2(800, 678), "scale": Vector2.ONE * lerpf(1.0, 0.34, core_absorb), "color": Color(1, 1, 1, core_alpha), "fallbackParts": [
		{"type": "circle", "pos": Vector2(800, 678), "radius": lerpf(94.0, 30.0, core_absorb), "color": Color(1.0, 0.18, 0.62, 0.24 * core_alpha), "outline": Color(0.65, 0.36, 1.0, core_alpha)}
	]})
	return parts

static func _shutdown_finale_parts(view: Dictionary, data: Dictionary) -> Array[Dictionary]:
	var p := clampf(float(view.get("customFinaleProgress", 0.0)), 0.0, 1.0)
	if p <= 0.0:
		return []
	var fragment_alpha := (0.11 if bool(data.get("reducedNoise", false)) else 0.22) * sin(p * PI)
	return [
		{"type": "texture", "layer": "finale", "path": ASSET_ROOT + "boss_cutin_glitch_fragments.png", "rect": Rect2(520, -40, 940, 940), "color": Color(1, 1, 1, fragment_alpha), "fallbackParts": [
			{"type": "arc", "pos": Vector2(800, 408), "radius": lerpf(165.0, 235.0, p), "from": -1.1, "to": 4.8, "color": Color(0.68, 0.42, 1.0, 0.60 * (1.0 - p)), "width": 8.0},
			{"type": "line", "from": Vector2(620, 408), "to": Vector2(980, 408), "color": Color(1.0, 0.34, 0.76, 0.55 * (1.0 - p)), "width": 3.0}
		]}
	]

static func _bugged_game_metrics(view: Dictionary, data: Dictionary) -> Dictionary:
	var elapsed := float(view.get("elapsed", 0.0))
	var frame := int(view.get("frame", 0))
	var reduced_noise := bool(data.get("reducedNoise", false))
	var reduced_flash := bool(data.get("reducedFlash", false))
	var reduced_shake := bool(data.get("reducedShake", false))
	var loading := 0.0
	if elapsed >= 0.10 and elapsed < 0.27:
		loading = lerpf(0.0, 0.82, _time_progress(elapsed, 0.10, 0.27))
	elif elapsed < 0.33:
		loading = 0.82 if elapsed >= 0.27 else 0.0
	elif elapsed < 0.39:
		loading = lerpf(0.82, 0.74, _time_progress(elapsed, 0.33, 0.39))
	elif elapsed >= 0.39:
		loading = 0.74
	var intro_visible := _time_progress(elapsed, 0.10, 0.16) * (1.0 - _time_progress(elapsed, 0.68, 0.75))
	var slice_strength := _time_progress(elapsed, 0.34, 0.42) * (1.0 - _time_progress(elapsed, 0.62, 0.75))
	var rgb_strength := _time_progress(elapsed, 0.42, 0.48) * (1.0 - _time_progress(elapsed, 0.58, 0.70))
	var ghost_strength := _time_progress(elapsed, 0.50, 0.56) * (1.0 - _time_progress(elapsed, 0.70, 0.75))
	var scanline := _time_progress(elapsed, 0.36, 0.42) * (1.0 - _time_progress(elapsed, 0.67, 0.75))
	var slice_count := 3 if reduced_noise else 5
	var slice_offsets: Array[float] = []
	for i in range(slice_count):
		var direction := -1.0 if i % 2 == 0 else 1.0
		var amount := (2.0 + float((i * 3 + frame) % 9)) * direction * slice_strength
		slice_offsets.append(amount * (0.55 if reduced_noise else 1.0))
	var ghost_count := 2 if reduced_noise else 3
	var ghost_offsets: Array[Vector2] = []
	for i in range(ghost_count):
		var ratio := 0.0 if ghost_count <= 1 else float(i) / float(ghost_count - 1)
		ghost_offsets.append(Vector2(lerpf(-26.0, 24.0, ratio) * ghost_strength * (0.50 if reduced_noise else 1.0), 0.0))
	var dropouts: Array[Rect2] = []
	var dropout_count := 4 if reduced_noise else 8
	for i in range(dropout_count):
		var x := 112.0 + float(posmod(i * 97 + frame * 3, 480))
		var y := 172.0 + float(posmod(i * 71 + frame * 2, 470))
		dropouts.append(Rect2(x, y, 10.0 + float(i % 3) * 8.0, 4.0 + float(i % 2) * 4.0))
	var garbled := _time_progress(elapsed, 0.89, 0.93) * (1.0 - _time_progress(elapsed, 0.97, 1.05))
	var handoff := _time_progress(elapsed, 1.55, 1.64) * (1.0 - _time_progress(elapsed, 1.82, 1.90))
	return {
		"loadingProgress": loading,
		"loadingBrokenProgress": _time_progress(elapsed, 0.33, 0.55),
		"normalSilhouetteAlpha": 0.78 * intro_visible,
		"scanlineAlpha": (0.26 if reduced_noise else 0.42) * scanline,
		"rgbSplitAmount": (3.0 if reduced_noise else 6.0) * rgb_strength,
		"sliceOffsets": slice_offsets,
		"sliceStrength": slice_strength,
		"ghostOffsets": ghost_offsets,
		"ghostAlpha": (0.16 if reduced_noise else 0.26) * ghost_strength,
		"pixelDropouts": dropouts,
		"invertPulse": 0.0 if reduced_flash else (0.20 if elapsed >= 0.58 and elapsed <= 0.61 and frame % 2 == 0 else 0.0),
		"garbledNameAlpha": garbled,
		"stableNameAlpha": _time_progress(elapsed, 1.05, 1.09),
		"edgeNoiseAlpha": 0.18 * _time_progress(elapsed, 1.05, 1.12) * (1.0 - _time_progress(elapsed, 1.55, 1.72)),
		"handoffGhostProgress": handoff,
		"handoffGhostCount": 3 if handoff > 0.0 else 0,
		"outlineVisibleRatio": 0.78,
		"activeEffectCount": int(slice_strength > 0.01) + int(rgb_strength > 0.01) + int(ghost_strength > 0.01) + int(scanline > 0.01),
		"reducedNoiseApplied": reduced_noise,
		"reducedFlashApplied": reduced_flash,
		"reducedShakeApplied": reduced_shake
	}

static func _bugged_game_parts(view: Dictionary, data: Dictionary) -> Array[Dictionary]:
	var metrics := _bugged_game_metrics(view, data)
	var elapsed := float(view.get("elapsed", 0.0))
	var intro_alpha := _time_progress(elapsed, 0.10, 0.15) * (1.0 - _time_progress(elapsed, 0.68, 0.75))
	var parts: Array[Dictionary] = []
	parts.append({"type": "texture", "layer": "intro_front", "path": ASSET_ROOT + "cutin_bug_loading_bar.png", "rect": Rect2(90, 650, 620, 71), "color": Color(1, 1, 1, intro_alpha), "fallbackParts": [
		{"type": "rect", "rect": Rect2(176, 668, 440, 42), "color": Color(0.03, 0.04, 0.10, 0.82 * intro_alpha)}
	]})
	var bar := Rect2(184, 675, 432, 18)
	var loading := float(metrics.get("loadingProgress", 0.0))
	var broken := float(metrics.get("loadingBrokenProgress", 0.0))
	for i in range(10):
		var threshold := float(i + 1) / 10.0 * 0.82
		var filled := loading >= threshold
		var block_alpha := (0.92 if filled else 0.18) * intro_alpha
		var offset := Vector2.ZERO
		if broken > 0.0 and i >= 8:
			offset = Vector2(float(i - 8) * 5.0, (1.0 if i % 2 == 0 else -1.0) * broken * 7.0)
			block_alpha *= 1.0 - broken * (0.65 if i == 9 else 0.35)
		parts.append({"type": "rect", "layer": "intro_front", "rect": Rect2(bar.position + Vector2(float(i) * 43.2, 0.0) + offset, Vector2(37.0, 18.0)), "color": Color(0.32, 0.82, 1.0, block_alpha)})
	var scanline_alpha := float(metrics.get("scanlineAlpha", 0.0))
	var noise_alpha := scanline_alpha * (1.075 if bool(data.get("reducedNoise", false)) else 1.476)
	var jitter_limit := 6.0 if bool(data.get("reducedNoise", false)) else 12.0
	var jitter := 0.0 if bool(data.get("reducedShake", false)) else sin(float(view.get("frame", 0)) * 1.71) * jitter_limit
	var noise_fallbacks: Array[Dictionary] = []
	for i in range(3):
		var y := 230.0 + float(i) * 172.0 + float(posmod(int(view.get("frame", 0)) * 7 + i * 31, 54))
		noise_fallbacks.append({"type": "line", "from": Vector2(72, y), "to": Vector2(692, y), "color": Color(0.48, 0.62, 1.0, scanline_alpha), "width": 3.0})
	parts.append({"type": "texture", "layer": "intro_front", "path": ASSET_ROOT + "cutin_bug_horizontal_noise.png", "rect": Rect2(-20 + jitter, 334, 1640, 250), "color": Color(1, 1, 1, noise_alpha), "fallbackParts": noise_fallbacks})
	var dropouts: Array = metrics.get("pixelDropouts", []) as Array
	var dropout_fallbacks: Array[Dictionary] = []
	for i in range(mini(4, dropouts.size())):
		dropout_fallbacks.append({"type": "rect", "rect": dropouts[i] as Rect2, "color": Color(0.025, 0.012, 0.06, scanline_alpha * 0.82)})
	var fragment_alpha := minf(0.34, maxf(float(metrics.get("sliceStrength", 0.0)) * 0.34, float(metrics.get("ghostAlpha", 0.0))))
	if bool(data.get("reducedNoise", false)):
		fragment_alpha *= 0.5
	parts.append({"type": "texture", "layer": "intro_front", "path": ASSET_ROOT + "cutin_bug_pixel_fragment.png", "rect": Rect2(50, 100, 650, 650), "color": Color(1, 1, 1, fragment_alpha), "fallbackParts": dropout_fallbacks})
	var reveal_fragment := _time_progress(elapsed, 0.68, 0.75) * (1.0 - _time_progress(elapsed, 0.94, 1.05))
	var handoff_fragment := float(metrics.get("handoffGhostProgress", 0.0))
	var glitch_alpha := maxf(reveal_fragment, handoff_fragment) * (0.12 if bool(data.get("reducedNoise", false)) else 0.24)
	if elapsed >= 0.89 and elapsed <= 1.55:
		glitch_alpha *= 0.5
	parts.append({"type": "texture", "layer": "intro_front", "path": ASSET_ROOT + "boss_cutin_glitch_fragments.png", "rect": Rect2(520, -40, 940, 940), "color": Color(1, 1, 1, glitch_alpha)})
	parts.append({"type": "text", "layer": "intro_front", "pos": Vector2(176, 664), "text": "LOADING", "width": 220, "size": 18, "color": Color(0.65, 0.90, 1.0, intro_alpha)})
	return parts

static func _bugged_name_parts(view: Dictionary, data: Dictionary) -> Array[Dictionary]:
	var metrics := _bugged_game_metrics(view, data)
	var alpha := float(metrics.get("garbledNameAlpha", 0.0))
	var edge := float(metrics.get("edgeNoiseAlpha", 0.0))
	return [
		{"type": "text", "layer": "finale", "pos": Vector2(650, 445), "text": "##? // B0SS _", "width": 860, "size": 62, "color": Color(0.76, 0.88, 1.0, alpha)},
		{"type": "line", "layer": "finale", "from": Vector2(650, 475), "to": Vector2(1410, 475), "color": Color(0.36, 0.82, 1.0, maxf(alpha * 0.72, edge)), "width": 4.0},
		{"type": "line", "layer": "finale", "from": Vector2(780, 486), "to": Vector2(1180, 486), "color": Color(0.72, 0.38, 1.0, edge), "width": 2.0}
	]

static func _time_progress(value: float, from: float, to: float) -> float:
	if to <= from:
		return 1.0 if value >= to else 0.0
	return _smooth(clampf(inverse_lerp(from, to, value), 0.0, 1.0))

static func _smooth(value: float) -> float:
	var t := clampf(value, 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)
