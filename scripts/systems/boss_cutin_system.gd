class_name BossCutinSystem
extends RefCounted

const BossCutinCustomIntroSystemScript := preload("res://scripts/systems/boss_cutin_custom_intro_system.gd")

const NORMAL_DURATION := 1.5
const FINAL_DURATION := 2.4
const V2_NORMAL_DURATION := 1.8
const V2_FINAL_DURATION := 2.8
const V3_NORMAL_DURATION := 2.15
const V3_FINAL_DURATION := 3.4
const WATCHDOG_MARGIN := 0.5

const PHASE_PREPARING := "PREPARING"
const PHASE_THEME_INTRO := "THEME_INTRO"
const PHASE_CUSTOM_INTRO := "CUSTOM_INTRO"
const PHASE_SILHOUETTE := "SILHOUETTE"
const PHASE_REVEAL := "REVEAL"
const PHASE_CUSTOM_FINALE := "CUSTOM_FINALE"
const PHASE_NAME_IMPACT := "NAME_IMPACT"
const PHASE_COMMENT_BURST := "COMMENT_BURST"
const PHASE_CONNECTING := "CONNECTING_TO_BOSS"
const PHASE_INTRO_POSE := "BOSS_INTRO_POSE"
const PHASE_HP_BAR := "SHOWING_HP_BAR"
const PHASE_FINISHING := "FINISHING"

static func empty_runtime() -> Dictionary:
	return {
		"active": false,
		"elapsed": 0.0,
		"duration": NORMAL_DURATION,
		"data": {},
		"completionAction": "",
		"previousState": "playing",
		"revealSePlayed": false,
		"completionDispatched": false,
		"version": 1,
		"phase": PHASE_PREPARING,
		"firedEvents": {},
		"selectedComments": [],
		"bossPrepared": false,
		"bossSpawned": false,
		"spawnUid": -1,
		"spawnWorldPosition": Vector2.ZERO,
		"spawnScreenPosition": Vector2.ZERO,
		"bgmDuckRestored": false,
		"handoffFallback": false
	}

static func normalize_data(raw: Dictionary, fallback: Dictionary = {}) -> Dictionary:
	var is_final := bool(raw.get("isFinalBoss", fallback.get("isFinalBoss", false)))
	var offset_value: Variant = raw.get("imageOffset", fallback.get("imageOffset", {}))
	var image_offset := Vector2.ZERO
	if offset_value is Vector2:
		image_offset = offset_value as Vector2
	elif offset_value is Dictionary:
		var offset_raw := offset_value as Dictionary
		image_offset = Vector2(float(offset_raw.get("x", 0.0)), float(offset_raw.get("y", 0.0)))
	var image_side := String(raw.get("imageSide", raw.get("entryDirection", "left")))
	if not image_side in ["left", "right"]:
		image_side = "left"
	var entry_direction := String(raw.get("entryDirection", image_side))
	if not entry_direction in ["left", "right", "top", "bottom"]:
		entry_direction = image_side
	var use_silhouette := bool(raw.get("useSilhouetteReveal", false))
	var use_comments := bool(raw.get("useCommentBurst", false))
	var connect_spawn := bool(raw.get("connectImageToBossSpawn", false))
	var use_pose := bool(raw.get("useBossIntroPose", false))
	var use_relay_sequence := bool(raw.get("useRelayThemeSequence", false))
	var custom_intro_id := String(raw.get("customIntroId", "")).strip_edges()
	var custom_finale_id := String(raw.get("customFinaleId", "")).strip_edges()
	var version := int(raw.get("version", 1))
	if version < 3 and (custom_intro_id != "" or custom_finale_id != ""):
		version = 3
	if version < 2 and (use_silhouette or use_comments or connect_spawn or use_pose or use_relay_sequence):
		version = 2
	var default_duration := V3_FINAL_DURATION if is_final else V3_NORMAL_DURATION
	if version == 2:
		default_duration = V2_FINAL_DURATION if is_final else V2_NORMAL_DURATION
	if version < 2:
		default_duration = FINAL_DURATION if is_final else NORMAL_DURATION
	return {
		"bossId": String(raw.get("bossId", fallback.get("id", ""))),
		"displayName": String(raw.get("displayName", fallback.get("displayName", "BOSS"))),
		"subTitle": String(raw.get("subTitle", fallback.get("subTitle", ""))),
		"labelType": String(raw.get("labelType", "final_boss" if is_final else "boss")),
		"imagePath": String(raw.get("cutinImage", raw.get("imagePath", fallback.get("imagePath", fallback.get("spritePath", fallback.get("sprite", "")))))),
		"themeColor": String(raw.get("themeColor", "#8a5cff" if is_final else "#ff5ca8")),
		"accentColor": String(raw.get("accentColor", "#ff6ecf" if is_final else "#70e8ff")),
		"noiseColor": String(raw.get("noiseColor", "#f5f7ff")),
		"bgStyle": String(raw.get("bgStyle", "final" if is_final else "default")),
		"durationSeconds": clampf(float(raw.get("durationSeconds", default_duration)), 0.5, 10.0),
		"imageSide": "right" if image_side == "right" else "left",
		"entryDirection": entry_direction,
		"flipH": bool(raw.get("flipImageX", raw.get("flipH", false))),
		"flipImageX": bool(raw.get("flipImageX", raw.get("flipH", false))),
		"imageScale": clampf(float(raw.get("imageScale", 1.0)), 0.25, 2.0),
		"imageOffset": image_offset,
		"seType": String(raw.get("seType", "boss_final" if is_final else "boss_normal")),
		"isFinalBoss": is_final,
		"version": version,
		"useSilhouetteReveal": use_silhouette,
		"useCommentBurst": use_comments,
		"commentPoolId": String(raw.get("commentPoolId", "last_offline" if is_final else "default_boss")),
		"customCommentPoolId": String(raw.get("customCommentPoolId", "")),
		"customIntroId": custom_intro_id,
		"customFinaleId": custom_finale_id,
		"customIntroDurationSeconds": clampf(float(raw.get("customIntroDurationSeconds", 0.0)), 0.0, 2.0),
		"replaceCommonThemeIntro": bool(raw.get("replaceCommonThemeIntro", false)),
		"useFakeNameCorrection": bool(raw.get("useFakeNameCorrection", false)),
		"customSeType": String(raw.get("customSeType", "")),
		"reducedFlash": bool(raw.get("reducedFlash", false)),
		"reducedNoise": bool(raw.get("reducedNoise", false)),
		"reducedShake": bool(raw.get("reducedShake", false)),
		"connectImageToBossSpawn": connect_spawn,
		"useBossIntroPose": use_pose,
		"introPoseId": String(raw.get("introPoseId", "last_offline_boot" if is_final else "generic")),
		"useRelayThemeSequence": use_relay_sequence,
		"bgmDuckVolumeMultiplier": clampf(float(raw.get("bgmDuckVolumeMultiplier", 0.40 if is_final else 0.55)), 0.0, 1.0),
		"preRevealAccents": (raw.get("preRevealAccents", []) as Array).duplicate(true)
	}

static func start(data: Dictionary, completion_action: String, previous_state: String) -> Dictionary:
	var normalized := normalize_data(data)
	var runtime := empty_runtime()
	runtime["active"] = true
	runtime["duration"] = float(normalized["durationSeconds"])
	runtime["data"] = normalized
	runtime["completionAction"] = completion_action
	runtime["previousState"] = previous_state
	runtime["version"] = int(normalized.get("version", 1))
	return runtime

static func update(runtime: Dictionary, delta: float) -> Dictionary:
	var next := runtime.duplicate(true)
	var result := {"runtime": next, "playRevealSe": false, "finished": false, "events": []}
	if not bool(next.get("active", false)):
		return result
	var data: Dictionary = next.get("data", {}) as Dictionary
	var duration := maxf(0.01, float(next.get("duration", NORMAL_DURATION)))
	var previous_elapsed := float(next.get("elapsed", 0.0))
	var elapsed := previous_elapsed + maxf(0.0, delta)
	next["elapsed"] = elapsed
	var version := int(next.get("version", 1))
	if version >= 2:
		var events: Array = result["events"] as Array
		var timings := _v3_timings(data, duration) if version >= 3 else _v2_timings(bool(data.get("isFinalBoss", false)), duration)
		_fire_event(next, events, previous_elapsed, elapsed, "theme_sweep", float(timings["theme"]))
		if version >= 3 and String(data.get("customIntroId", "")) != "":
			_fire_event(next, events, previous_elapsed, elapsed, "custom_intro_start", float(timings["customStart"]))
			_fire_event(next, events, previous_elapsed, elapsed, "custom_intro_impact", float(timings["customImpact"]))
			_fire_event(next, events, previous_elapsed, elapsed, "custom_intro_finish", float(timings["customEnd"]))
		if bool(data.get("isFinalBoss", false)) and version < 3:
			_fire_event(next, events, previous_elapsed, elapsed, "final_core", float(timings["core"]))
		_fire_event(next, events, previous_elapsed, elapsed, "reveal_flash", float(timings["reveal"]))
		if version >= 3 and String(data.get("customFinaleId", "")) != "":
			_fire_event(next, events, previous_elapsed, elapsed, "custom_finale_start", float(timings["finaleStart"]))
			_fire_event(next, events, previous_elapsed, elapsed, "custom_finale_impact", float(timings["finaleImpact"]))
		_fire_event(next, events, previous_elapsed, elapsed, "name_impact", float(timings["name"]))
		_fire_event(next, events, previous_elapsed, elapsed, "comment_burst", float(timings["comments"]))
		_fire_event(next, events, previous_elapsed, elapsed, "spawn_boss_locked", float(timings["spawn"]))
		_fire_event(next, events, previous_elapsed, elapsed, "reveal_field_boss", float(timings["field"]))
		_fire_event(next, events, previous_elapsed, elapsed, "show_hp_bar", float(timings["hp"]))
		next["phase"] = _v3_phase(elapsed, timings, data) if version >= 3 else _v2_phase(elapsed, timings)
		if (result["events"] as Array).has("reveal_flash"):
			next["revealSePlayed"] = true
			result["playRevealSe"] = true
	else:
		var reveal_time := 1.10 if bool(data.get("isFinalBoss", false)) else 0.65
		if not bool(next.get("revealSePlayed", false)) and elapsed >= reveal_time:
			next["revealSePlayed"] = true
			result["playRevealSe"] = true
	if elapsed >= duration:
		next["active"] = false
		if not bool(next.get("completionDispatched", false)):
			next["completionDispatched"] = true
			result["finished"] = true
			(result["events"] as Array).append("finish")
	return result

static func build_view(runtime: Dictionary) -> Dictionary:
	if int(runtime.get("version", 1)) >= 3:
		var view := _build_v3_view(runtime)
		view["customView"] = BossCutinCustomIntroSystemScript.build_view(view.get("data", {}) as Dictionary, runtime, view)
		return view
	if int(runtime.get("version", 1)) >= 2:
		return _build_v2_view(runtime)
	return _build_v1_view(runtime)

static func cancel(runtime: Dictionary) -> Dictionary:
	var next := runtime.duplicate(true)
	next["active"] = false
	next["completionDispatched"] = true
	next["bgmDuckRestored"] = true
	return next

static func _build_v1_view(runtime: Dictionary) -> Dictionary:
	var data: Dictionary = runtime.get("data", {}) as Dictionary
	var elapsed := maxf(0.0, float(runtime.get("elapsed", 0.0)))
	var duration := maxf(0.01, float(runtime.get("duration", NORMAL_DURATION)))
	var is_final := bool(data.get("isFinalBoss", false))
	var image_progress := _smooth_range(elapsed, 0.22 if is_final else 0.18, 0.58 if is_final else 0.45)
	var label_alpha := _smooth_range(elapsed, 0.45 if is_final else 0.28, 0.65 if is_final else 0.42)
	var subtitle_alpha := _smooth_range(elapsed, 0.65 if is_final else 0.35, 0.86 if is_final else 0.52)
	var name_progress := _smooth_range(elapsed, 0.82 if is_final else 0.45, 1.16 if is_final else 0.72)
	var flash_start := 1.10 if is_final else 0.65
	var flash_end := 1.20 if is_final else 0.73
	var flash_alpha := _pulse_between(elapsed, flash_start, flash_end)
	var fade_start := 2.0 if is_final else 1.18
	var exit_alpha := 1.0 - _smooth_range(elapsed, minf(fade_start, duration), duration)
	return {
		"active": bool(runtime.get("active", false)), "data": data, "elapsed": elapsed, "duration": duration,
		"phase": "V1", "imageProgress": image_progress, "labelAlpha": label_alpha,
		"subtitleAlpha": subtitle_alpha, "nameProgress": name_progress, "nameImpactScale": 1.0,
		"flashAlpha": flash_alpha, "noiseIntensity": clampf(0.12 + flash_alpha * 0.55 + (1.0 - exit_alpha) * 0.12, 0.0, 1.0),
		"exitAlpha": exit_alpha, "frame": int(floor(elapsed * 60.0)), "silhouetteAlpha": 0.0,
		"colorRevealProgress": 1.0, "imageEntryScale": 1.0, "imageEntryOffset": Vector2.ZERO,
		"commentBurstAlpha": 0.0, "connectProgress": 0.0, "cutinImageAlpha": exit_alpha,
		"fieldBossAlpha": 0.0, "fieldBossIntroProgress": 0.0, "hpBarProgress": 0.0,
		"bgmDuckProgress": 0.0, "bgmDuckScale": 1.0, "relayMotifProgresses": [0.0, 0.0, 0.0, 0.0, 0.0],
		"relayAbsorbProgress": 0.0, "preRevealCoreAlpha": 0.0
	}

static func _build_v2_view(runtime: Dictionary) -> Dictionary:
	var data: Dictionary = runtime.get("data", {}) as Dictionary
	var elapsed := maxf(0.0, float(runtime.get("elapsed", 0.0)))
	var duration := maxf(0.01, float(runtime.get("duration", V2_NORMAL_DURATION)))
	var is_final := bool(data.get("isFinalBoss", false))
	var timings := _v2_timings(is_final, duration)
	var entry_start := float(timings["silhouette"])
	var entry_end := float(timings["reveal"]) + 0.10
	var entry_progress := _smooth_range(elapsed, entry_start, entry_end)
	var color_progress := _smooth_range(elapsed, float(timings["reveal"]), float(timings["reveal"]) + 0.10)
	var silhouette_alpha := entry_progress * (1.0 - color_progress)
	var name_progress := _smooth_range(elapsed, float(timings["name"]), float(timings["name"]) + 0.20)
	var impact_scale := _impact_scale(name_progress)
	var connect_progress := _smooth_range(elapsed, float(timings["connect"]), float(timings["field"]) + 0.04)
	var field_alpha := _smooth_range(elapsed, float(timings["field"]), float(timings["field"]) + 0.08)
	var cutin_alpha := 1.0 - _smooth_range(elapsed, float(timings["field"]), float(timings["field"]) + 0.12)
	var pose_progress := _smooth_range(elapsed, float(timings["field"]), float(timings["hp"]) + 0.04)
	var hp_progress := _smooth_range(elapsed, float(timings["hp"]), duration)
	var comment_alpha := _smooth_range(elapsed, float(timings["comments"]), float(timings["comments"]) + 0.10)
	comment_alpha *= 1.0 - _smooth_range(elapsed, float(timings["connect"]), float(timings["field"]))
	var restore_duration := 0.35 if is_final else 0.30
	var duck_in := _smooth_range(elapsed, 0.0, 0.15)
	var duck_out := _smooth_range(elapsed, duration - restore_duration, duration)
	var duck_progress := duck_in * (1.0 - duck_out)
	var duck_scale := lerpf(1.0, float(data.get("bgmDuckVolumeMultiplier", 0.40 if is_final else 0.55)), duck_progress)
	var motif_progresses: Array[float] = []
	var absorb := _smooth_range(elapsed, 0.55, 0.70) if is_final and bool(data.get("useRelayThemeSequence", false)) else 0.0
	for i in range(5):
		var appear := _smooth_range(elapsed, 0.10 + float(i) * 0.08, 0.17 + float(i) * 0.08)
		motif_progresses.append(appear * (1.0 - absorb))
	var exit_alpha := 1.0 - _smooth_range(elapsed, duration - 0.08, duration)
	var entry_offset := _entry_offset(String(data.get("entryDirection", data.get("imageSide", "left"))), entry_progress)
	return {
		"active": bool(runtime.get("active", false)), "data": data, "elapsed": elapsed, "duration": duration,
		"phase": _v2_phase(elapsed, timings), "themeIntroProgress": _smooth_range(elapsed, float(timings["theme"]), float(timings["silhouette"])),
		"imageProgress": entry_progress, "silhouetteAlpha": silhouette_alpha,
		"colorRevealProgress": color_progress, "imageEntryScale": _entry_scale(entry_progress), "imageEntryOffset": entry_offset,
		"labelAlpha": _smooth_range(elapsed, float(timings["label"]), float(timings["label"]) + 0.14),
		"subtitleAlpha": _smooth_range(elapsed, float(timings["subtitle"]), float(timings["subtitle"]) + 0.14),
		"nameProgress": name_progress, "nameImpactProgress": name_progress, "nameImpactScale": impact_scale,
		"commentBurstAlpha": comment_alpha, "connectProgress": connect_progress, "cutinImageAlpha": cutin_alpha,
		"fieldBossAlpha": field_alpha, "fieldBossIntroProgress": pose_progress, "hpBarProgress": hp_progress,
		"bgmDuckProgress": duck_progress, "bgmDuckScale": duck_scale, "relayMotifProgresses": motif_progresses,
		"relayAbsorbProgress": absorb, "preRevealCoreAlpha": _smooth_range(elapsed, float(timings["core"]), float(timings["reveal"])) * (1.0 - color_progress) if is_final else 0.0,
		"flashAlpha": minf(0.70 if is_final else 0.55, _pulse_between(elapsed, float(timings["reveal"]), float(timings["reveal"]) + 0.10)),
		"noiseIntensity": clampf(0.14 + (0.28 if is_final else 0.10) * color_progress + absorb * 0.22, 0.0, 1.0),
		"exitAlpha": exit_alpha, "frame": int(floor(elapsed * 60.0))
	}

static func _build_v3_view(runtime: Dictionary) -> Dictionary:
	var data: Dictionary = runtime.get("data", {}) as Dictionary
	var elapsed := maxf(0.0, float(runtime.get("elapsed", 0.0)))
	var duration := maxf(0.01, float(runtime.get("duration", V3_NORMAL_DURATION)))
	var is_final := bool(data.get("isFinalBoss", false))
	var timings := _v3_timings(data, duration)
	var entry_progress := _smooth_range(elapsed, float(timings["silhouette"]), float(timings["reveal"]) + 0.10)
	var color_progress := _smooth_range(elapsed, float(timings["reveal"]), float(timings["reveal"]) + 0.10)
	var name_progress := _smooth_range(elapsed, float(timings["name"]), float(timings["name"]) + 0.20)
	var connect_progress := _smooth_range(elapsed, float(timings["connect"]), float(timings["field"]) + 0.04)
	var field_alpha := _smooth_range(elapsed, float(timings["field"]), float(timings["field"]) + 0.08)
	var cutin_alpha := 1.0 - _smooth_range(elapsed, float(timings["field"]), float(timings["field"]) + 0.12)
	var comment_alpha := _smooth_range(elapsed, float(timings["comments"]), float(timings["comments"]) + 0.10)
	comment_alpha *= 1.0 - _smooth_range(elapsed, float(timings["connect"]), float(timings["field"]))
	var motif_progresses: Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0]
	var absorb := 0.0
	if is_final and bool(data.get("useRelayThemeSequence", false)) and not bool(data.get("replaceCommonThemeIntro", false)):
		absorb = _smooth_range(elapsed, 0.55, 0.70)
		for i in range(5):
			var appear := _smooth_range(elapsed, 0.10 + float(i) * 0.08, 0.17 + float(i) * 0.08)
			motif_progresses[i] = appear * (1.0 - absorb)
	var duck_scale := _v3_bgm_duck_scale(elapsed, duration, data, timings)
	var exit_alpha := 1.0 - _smooth_range(elapsed, duration - 0.08, duration)
	var flash_alpha := minf(0.70 if is_final else 0.55, _pulse_between(elapsed, float(timings["reveal"]), float(timings["reveal"]) + 0.10))
	if bool(data.get("reducedFlash", false)):
		flash_alpha = 0.0
	return {
		"active": bool(runtime.get("active", false)), "data": data, "elapsed": elapsed, "duration": duration,
		"phase": _v3_phase(elapsed, timings, data), "timings": timings,
		"themeIntroProgress": _smooth_range(elapsed, float(timings["theme"]), float(timings["customStart"])),
		"customIntroProgress": _smooth_range(elapsed, float(timings["customStart"]), float(timings["customEnd"])),
		"customFinaleProgress": _smooth_range(elapsed, float(timings["finaleStart"]), float(timings["finaleImpact"])),
		"imageProgress": entry_progress, "silhouetteAlpha": entry_progress * (1.0 - color_progress),
		"colorRevealProgress": color_progress, "imageEntryScale": _entry_scale(entry_progress),
		"imageEntryOffset": _entry_offset(String(data.get("entryDirection", data.get("imageSide", "left"))), entry_progress),
		"labelAlpha": _smooth_range(elapsed, float(timings["label"]), float(timings["label"]) + 0.14),
		"subtitleAlpha": _smooth_range(elapsed, float(timings["subtitle"]), float(timings["subtitle"]) + 0.14),
		"nameProgress": name_progress, "nameImpactProgress": name_progress, "nameImpactScale": _impact_scale(name_progress),
		"commentBurstAlpha": comment_alpha, "connectProgress": connect_progress, "cutinImageAlpha": cutin_alpha,
		"fieldBossAlpha": field_alpha, "fieldBossIntroProgress": _smooth_range(elapsed, float(timings["field"]), float(timings["hp"]) + 0.04),
		"hpBarProgress": _smooth_range(elapsed, float(timings["hp"]), duration),
		"bgmDuckProgress": 1.0 - duck_scale, "bgmDuckScale": duck_scale,
		"relayMotifProgresses": motif_progresses, "relayAbsorbProgress": absorb,
		"preRevealCoreAlpha": _smooth_range(elapsed, float(timings["customStart"]), float(timings["reveal"])) * (1.0 - color_progress) if is_final else 0.0,
		"flashAlpha": flash_alpha,
		"noiseIntensity": clampf(0.14 + (0.28 if is_final else 0.10) * color_progress + absorb * 0.22, 0.0, 1.0),
		"exitAlpha": exit_alpha, "frame": int(floor(elapsed * 60.0))
	}

static func _v3_timings(data: Dictionary, duration: float) -> Dictionary:
	if bool(data.get("isFinalBoss", false)):
		return {
			"theme": 0.08, "core": 0.72, "customStart": 0.10, "customImpact": 1.02, "customEnd": 1.20,
			"silhouette": 1.08, "reveal": 1.25, "label": 1.42, "subtitle": 1.58, "name": 1.75,
			"finaleStart": 1.59, "finaleImpact": 1.75, "comments": 1.98, "connect": 2.75,
			"spawn": 3.047, "field": 3.08, "hp": 3.28, "finish": duration
		}
	var custom_duration := clampf(float(data.get("customIntroDurationSeconds", 0.60)), 0.20, 1.20)
	var custom_start := 0.10
	var custom_end := custom_start + custom_duration
	var silhouette := custom_end - 0.10
	var reveal := silhouette + 0.17
	var name := reveal + 0.23
	return {
		"theme": 0.08, "core": 0.0, "customStart": custom_start,
		"customImpact": maxf(custom_start, custom_end - 0.14), "customEnd": custom_end,
		"silhouette": silhouette, "reveal": reveal, "label": reveal + 0.10, "subtitle": reveal + 0.14,
		"name": name, "finaleStart": maxf(custom_end, name - 0.16), "finaleImpact": name,
		"comments": name + 0.17, "connect": duration - 0.65, "spawn": duration - 0.335,
		"field": duration - 0.30, "hp": duration - 0.12, "finish": duration
	}

static func _v3_bgm_duck_scale(elapsed: float, duration: float, data: Dictionary, timings: Dictionary) -> float:
	if bool(data.get("isFinalBoss", false)) and String(data.get("customIntroId", "")) == "stream_shutdown":
		if elapsed < 0.15:
			return lerpf(1.0, 0.20, _smooth_range(elapsed, 0.0, 0.15))
		if elapsed < 0.35:
			return lerpf(0.20, 0.08, _smooth_range(elapsed, 0.15, 0.35))
		if elapsed < float(timings["name"]):
			return lerpf(0.08, 0.12, _smooth_range(elapsed, float(timings["customEnd"]), float(timings["name"])))
		return lerpf(0.12, 0.08, _smooth_range(elapsed, float(timings["name"]), duration))
	var duck_in := _smooth_range(elapsed, 0.0, 0.15)
	var duck_out := _smooth_range(elapsed, duration - 0.30, duration)
	return lerpf(1.0, float(data.get("bgmDuckVolumeMultiplier", 0.55)), duck_in * (1.0 - duck_out))

static func _v3_phase(elapsed: float, timings: Dictionary, data: Dictionary) -> String:
	if elapsed < float(timings["theme"]): return PHASE_PREPARING
	if elapsed < float(timings["customStart"]): return PHASE_THEME_INTRO
	if elapsed < float(timings["silhouette"]): return PHASE_CUSTOM_INTRO
	if elapsed < float(timings["reveal"]): return PHASE_SILHOUETTE
	if elapsed < float(timings["finaleStart"]): return PHASE_REVEAL
	if elapsed < float(timings["name"]) and String(data.get("customFinaleId", "")) != "": return PHASE_CUSTOM_FINALE
	if elapsed < float(timings["comments"]): return PHASE_NAME_IMPACT
	if elapsed < float(timings["connect"]): return PHASE_COMMENT_BURST
	if elapsed < float(timings["field"]): return PHASE_CONNECTING
	if elapsed < float(timings["hp"]): return PHASE_INTRO_POSE
	if elapsed < float(timings["finish"]): return PHASE_HP_BAR
	return PHASE_FINISHING

static func _v2_timings(is_final: bool, duration: float) -> Dictionary:
	if is_final:
		return {"theme": 0.10, "core": 0.72, "silhouette": 0.88, "reveal": 1.05, "label": 1.22, "subtitle": 1.38, "name": 1.55, "comments": 1.78, "connect": 2.15, "spawn": 2.447, "field": 2.48, "hp": 2.68, "finish": duration}
	return {"theme": 0.08, "core": 0.0, "silhouette": 0.15, "reveal": 0.32, "label": 0.42, "subtitle": 0.46, "name": 0.55, "comments": 0.72, "connect": 1.15, "spawn": 1.465, "field": 1.50, "hp": 1.68, "finish": duration}

static func _v2_phase(elapsed: float, timings: Dictionary) -> String:
	if elapsed < float(timings["theme"]): return PHASE_PREPARING
	if elapsed < float(timings["silhouette"]): return PHASE_THEME_INTRO
	if elapsed < float(timings["reveal"]): return PHASE_SILHOUETTE
	if elapsed < float(timings["name"]): return PHASE_REVEAL
	if elapsed < float(timings["comments"]): return PHASE_NAME_IMPACT
	if elapsed < float(timings["connect"]): return PHASE_COMMENT_BURST
	if elapsed < float(timings["field"]): return PHASE_CONNECTING
	if elapsed < float(timings["hp"]): return PHASE_INTRO_POSE
	if elapsed < float(timings["finish"]): return PHASE_HP_BAR
	return PHASE_FINISHING

static func _fire_event(runtime: Dictionary, events: Array, previous: float, elapsed: float, event_id: String, event_time: float) -> void:
	var fired: Dictionary = runtime.get("firedEvents", {}) as Dictionary
	if bool(fired.get(event_id, false)):
		return
	if previous < event_time and elapsed >= event_time:
		fired[event_id] = true
		runtime["firedEvents"] = fired
		events.append(event_id)

static func _entry_scale(progress: float) -> float:
	if progress <= 0.72:
		return lerpf(1.15, 0.98, _smooth_range(progress, 0.0, 0.72))
	return lerpf(0.98, 1.0, _smooth_range(progress, 0.72, 1.0))

static func _impact_scale(progress: float) -> float:
	if progress <= 0.60:
		return lerpf(1.40, 0.95, _smooth_range(progress, 0.0, 0.60))
	return lerpf(0.95, 1.0, _smooth_range(progress, 0.60, 1.0))

static func _entry_offset(direction: String, progress: float) -> Vector2:
	var axis := Vector2.LEFT
	match direction:
		"right": axis = Vector2.RIGHT
		"top": axis = Vector2.UP
		"bottom": axis = Vector2.DOWN
	var overshoot := sin(clampf(progress, 0.0, 1.0) * PI) * -30.0
	return axis * (260.0 * (1.0 - progress) + overshoot)

static func _pulse_between(value: float, from: float, to: float) -> float:
	if value < from or value > to or to <= from:
		return 0.0
	return 1.0 - absf(inverse_lerp(from, to, value) * 2.0 - 1.0)

static func _smooth_range(value: float, from: float, to: float) -> float:
	if to <= from:
		return 1.0 if value >= to else 0.0
	var t := clampf(inverse_lerp(from, to, value), 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)
