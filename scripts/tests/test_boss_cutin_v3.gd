extends Node

const BossCutinSystemScript := preload("res://scripts/systems/boss_cutin_system.gd")

const NORMAL_CASES: Array[Dictionary] = [
	{"bossId": "boss_kuso_maro_king", "duration": 2.10, "customIntroId": "marshmallow_pile", "customFinaleId": "marshmallow_crown_drop", "customIntroDurationSeconds": 0.55},
	{"bossId": "red_pen_review_chief", "duration": 2.15, "customIntroId": "redpen_rewrite", "customFinaleId": "", "customIntroDurationSeconds": 0.60},
	{"bossId": "collab_crusher", "duration": 2.20, "customIntroId": "split_stream_crash", "customFinaleId": "", "customIntroDurationSeconds": 0.65},
	{"bossId": "bugged_final_boss", "duration": 2.20, "customIntroId": "bugged_game_final_boss", "customFinaleId": "bugged_name_correction", "customIntroDurationSeconds": 0.65},
	{"bossId": "pitch_police_chief", "duration": 2.25, "customIntroId": "pitch_violation_crackdown", "customFinaleId": "", "customIntroDurationSeconds": 0.78}
]

func _ready() -> void:
	var failures: Array[String] = []
	for case_data in NORMAL_CASES:
		var data := _base_v3_data(case_data)
		var runtime := BossCutinSystemScript.start(data, "spawn_normal_boss", "playing")
		_check(int(runtime.get("version", 0)) == 3, "%s did not start V3" % case_data["bossId"], failures)
		_check(is_equal_approx(float(runtime.get("duration", 0.0)), float(case_data["duration"])), "%s duration mismatch" % case_data["bossId"], failures)
		var mid_step: Dictionary = BossCutinSystemScript.update(runtime, 0.42)
		var mid_view: Dictionary = BossCutinSystemScript.build_view(mid_step.get("runtime", {}) as Dictionary)
		var custom: Dictionary = mid_view.get("customView", {}) as Dictionary
		_check(not bool(custom.get("fallbackToCommon", true)), "%s unexpectedly used fallback" % case_data["bossId"], failures)
		_check(int(custom.get("partCount", 0)) > 0 and int(custom.get("partCount", 0)) <= 24, "%s part count exceeded normal limit" % case_data["bossId"], failures)
		_check(not _contains_damage_part(custom.get("parts", []) as Array), "%s custom art exposed damage data" % case_data["bossId"], failures)
		var full_step: Dictionary = BossCutinSystemScript.update(runtime, float(case_data["duration"]) + 0.01)
		var events: Array = full_step.get("events", []) as Array
		for required_event in ["custom_intro_start", "custom_intro_impact", "custom_intro_finish", "reveal_flash", "name_impact", "comment_burst", "spawn_boss_locked", "reveal_field_boss", "show_hp_bar", "finish"]:
			_check(events.has(required_event), "%s missed %s" % [case_data["bossId"], required_event], failures)
		_check(_unique_count(events) == events.size(), "%s emitted a duplicate event" % case_data["bossId"], failures)
		_check(_event_before(events, "custom_intro_start", "custom_intro_impact") and _event_before(events, "custom_intro_impact", "custom_intro_finish") and _event_before(events, "custom_intro_finish", "reveal_flash"), "%s custom intro event order changed" % case_data["bossId"], failures)
		if String(case_data["customFinaleId"]) != "":
			_check(_event_before(events, "reveal_flash", "custom_finale_start") and _event_before(events, "custom_finale_start", "custom_finale_impact") and _event_before(events, "custom_finale_impact", "name_impact"), "%s custom finale event order changed" % case_data["bossId"], failures)

	var bugged_data := _base_v3_data(NORMAL_CASES[3])
	var loading_hold := _custom_view_at(bugged_data, 0.30)
	var loading_reverse := _custom_view_at(bugged_data, 0.38)
	_check(absf(float(loading_hold.get("loadingProgress", 0.0)) - 0.82) <= 0.015, "bugged loading bar did not hold near 0.82", failures)
	_check(float(loading_reverse.get("loadingProgress", 0.0)) < float(loading_hold.get("loadingProgress", 0.0)) and absf(float(loading_reverse.get("loadingProgress", 0.0)) - 0.74) <= 0.025, "bugged loading bar did not reverse toward 0.74", failures)
	var broken_view := _custom_view_at(bugged_data, 0.54)
	_check(int(broken_view.get("activeEffectCount", 0)) >= 3, "bugged intro did not activate at least three glitch families", failures)
	_check(float(broken_view.get("normalSilhouetteAlpha", 0.0)) > 0.50 and float(broken_view.get("outlineVisibleRatio", 0.0)) >= 0.50, "bugged silhouette became unreadable", failures)
	_check((broken_view.get("sliceOffsets", []) as Array).size() >= 3 and float(broken_view.get("rgbSplitAmount", 0.0)) > 0.0 and (broken_view.get("ghostOffsets", []) as Array).size() >= 2, "bugged slice/RGB/ghost data is incomplete", failures)
	_check(not _contains_damage_part(broken_view.get("parts", []) as Array), "bugged glitch parts exposed damage data", failures)
	var garbled_view := _custom_view_at(bugged_data, 0.94)
	var stable_view := _custom_view_at(bugged_data, 1.06)
	var handoff_view := _custom_view_at(bugged_data, 1.70)
	_check(float(garbled_view.get("garbledNameAlpha", 0.0)) > 0.0, "bugged finale did not show the fixed symbol string", failures)
	_check(float(stable_view.get("garbledNameAlpha", 1.0)) <= 0.001 and float(stable_view.get("stableNameAlpha", 0.0)) > 0.0, "bugged finale did not settle on the normal name", failures)
	_check(int(handoff_view.get("handoffGhostCount", 0)) == 3, "bugged handoff did not expose exactly three draw images", failures)
	var reduced_data := bugged_data.duplicate(true)
	reduced_data["reducedNoise"] = true
	reduced_data["reducedFlash"] = true
	var reduced_view := _custom_view_at(reduced_data, 0.54)
	var reduced_reveal_runtime := BossCutinSystemScript.start(reduced_data, "debug_return", "playing")
	reduced_reveal_runtime = (BossCutinSystemScript.update(reduced_reveal_runtime, 0.86).get("runtime", {}) as Dictionary)
	var reduced_reveal := BossCutinSystemScript.build_view(reduced_reveal_runtime)
	_check((reduced_view.get("sliceOffsets", []) as Array).size() <= 3 and (reduced_view.get("ghostOffsets", []) as Array).size() <= 2 and float(reduced_view.get("rgbSplitAmount", 99.0)) <= 3.0, "reducedNoise did not lower bugged glitch strength", failures)
	_check(is_zero_approx(float(reduced_reveal.get("flashAlpha", -1.0))) and is_zero_approx(float(reduced_view.get("invertPulse", -1.0))), "reducedFlash left a full-screen/invert flash", failures)

	var pitch_data := _base_v3_data(NORMAL_CASES[4])
	var pitch_line := _custom_view_at(pitch_data, 0.25)
	var pitch_peak := _custom_view_at(pitch_data, 0.35)
	var pitch_marker := _custom_view_at(pitch_data, 0.46)
	var pitch_siren := _custom_view_at(pitch_data, 0.55)
	var pitch_push := _custom_view_at(pitch_data, 0.79)
	var pitch_clear := _custom_view_at(pitch_data, 0.89)
	_check(float(pitch_line.get("pitchLineReveal", 0.0)) >= 0.99, "pitch waveform did not finish its deterministic reveal", failures)
	_check(float(pitch_peak.get("pitchDeviationProgress", 0.0)) >= 0.99, "pitch deviation did not peak at 0.35 seconds", failures)
	_check(float(pitch_marker.get("violationMarkerAlpha", 0.0)) > 0.0 and float(pitch_marker.get("violationMarkerScale", 1.0)) > 1.0, "pitch violation marker did not catch the peak", failures)
	_check(float(pitch_siren.get("sirenAlpha", 0.0)) > 0.0 and int(pitch_siren.get("sirenSide", -1)) in [0, 1], "pitch siren did not start deterministically", failures)
	_check(float(pitch_push.get("pitchPushProgress", 0.0)) > 0.0, "pitch assets did not begin their 0.70-0.88 exit", failures)
	_check(_max_part_alpha(pitch_clear.get("parts", []) as Array) <= 0.001, "pitch custom assets obscured the shared name presentation", failures)
	var reduced_pitch_data := pitch_data.duplicate(true)
	reduced_pitch_data["reducedFlash"] = true
	reduced_pitch_data["reducedNoise"] = true
	reduced_pitch_data["reducedShake"] = true
	var reduced_pitch := _custom_view_at(reduced_pitch_data, 0.55)
	_check(is_equal_approx(float(reduced_pitch.get("sirenCycleSeconds", 0.0)), 0.18) and float(reduced_pitch.get("sirenAlpha", 1.0)) <= 0.58, "pitch reducedNoise/reducedFlash limits were not applied", failures)
	_check((reduced_pitch.get("pitchLineJitter", Vector2.ONE) as Vector2).is_zero_approx(), "pitch reducedShake left waveform jitter", failures)
	_check(bool(reduced_pitch.get("reducedFlashApplied", false)) and bool(reduced_pitch.get("reducedNoiseApplied", false)) and bool(reduced_pitch.get("reducedShakeApplied", false)), "pitch accessibility metrics are incomplete", failures)

	var final_data := _base_v3_data({
		"bossId": "last_offline", "duration": 3.40, "customIntroId": "stream_shutdown",
		"customFinaleId": "stream_shutdown_finale", "customIntroDurationSeconds": 1.10
	})
	final_data["isFinalBoss"] = true
	final_data["replaceCommonThemeIntro"] = true
	final_data["useRelayThemeSequence"] = true
	final_data["bgmDuckVolumeMultiplier"] = 0.08
	var final_runtime := BossCutinSystemScript.start(final_data, "start_relay_final_boss", "stream_start_intro")
	var original_snapshot: Array[String] = ["コメントA", "コメントB", "コメントC", "コメントD", "コメントE", "コメントF", "コメントG"]
	final_runtime["chatDisplaySnapshot"] = original_snapshot.duplicate()
	var final_step: Dictionary = BossCutinSystemScript.update(final_runtime, 0.35)
	var final_view: Dictionary = BossCutinSystemScript.build_view(final_step.get("runtime", {}) as Dictionary)
	_check(is_equal_approx(float(final_view.get("bgmDuckScale", -1.0)), 0.08), "FINAL BGM did not reach 8 percent at 0.35s", failures)
	_check(_all_zero(final_view.get("relayMotifProgresses", []) as Array), "stream_shutdown double-drew V2 relay motifs", failures)
	var final_custom: Dictionary = final_view.get("customView", {}) as Dictionary
	_check(int(final_custom.get("partCount", 0)) > 0 and int(final_custom.get("partCount", 0)) <= 40, "FINAL part count exceeded 40", failures)
	_check(original_snapshot == final_runtime.get("chatDisplaySnapshot", []), "FINAL view mutated its chat snapshot", failures)
	final_step = BossCutinSystemScript.update(final_step.get("runtime", {}) as Dictionary, 3.10)
	var final_events: Array = final_step.get("events", []) as Array
	for required_event in ["custom_intro_impact", "custom_intro_finish", "custom_finale_start", "custom_finale_impact", "spawn_boss_locked", "reveal_field_boss", "show_hp_bar", "finish"]:
		_check(final_events.has(required_event), "FINAL missed %s" % required_event, failures)
	_check(_event_before(final_events, "custom_intro_finish", "reveal_flash") and _event_before(final_events, "reveal_flash", "custom_finale_start") and _event_before(final_events, "custom_finale_impact", "name_impact"), "FINAL large-delta event order changed", failures)

	var unknown := BossCutinSystemScript.start(_base_v3_data({"bossId": "unknown", "duration": 2.10, "customIntroId": "missing_intro", "customFinaleId": "missing_finale", "customIntroDurationSeconds": 0.55}), "debug_return", "playing")
	var unknown_view := BossCutinSystemScript.build_view(unknown)
	_check(bool((unknown_view.get("customView", {}) as Dictionary).get("fallbackToCommon", false)), "unknown custom IDs did not fall back", failures)
	_check(not unknown_view.is_empty() and String(unknown_view.get("phase", "")) != "", "unknown custom IDs aborted the common cut-in", failures)

	var cancelled := BossCutinSystemScript.cancel(BossCutinSystemScript.start(bugged_data, "debug_return", "playing"))
	_check((BossCutinSystemScript.build_view(cancelled).get("customView", {}) as Dictionary).is_empty(), "cancel left bugged custom draw state", failures)
	var watchdog_runtime := BossCutinSystemScript.start(bugged_data, "debug_return", "playing")
	var watchdog_step: Dictionary = BossCutinSystemScript.update(watchdog_runtime, 2.20 + BossCutinSystemScript.WATCHDOG_MARGIN)
	_check(bool(watchdog_step.get("finished", false)), "watchdog overshoot did not finish the bugged cut-in", failures)
	_check((BossCutinSystemScript.build_view(watchdog_step.get("runtime", {}) as Dictionary).get("customView", {}) as Dictionary).is_empty(), "watchdog finish left bugged custom draw state", failures)
	var cancelled_pitch := BossCutinSystemScript.cancel(BossCutinSystemScript.start(pitch_data, "debug_return", "playing"))
	_check((BossCutinSystemScript.build_view(cancelled_pitch).get("customView", {}) as Dictionary).is_empty(), "cancel left pitch-police custom draw state", failures)
	var pitch_watchdog_runtime := BossCutinSystemScript.start(pitch_data, "debug_return", "playing")
	var pitch_watchdog_step: Dictionary = BossCutinSystemScript.update(pitch_watchdog_runtime, 2.25 + BossCutinSystemScript.WATCHDOG_MARGIN)
	_check(bool(pitch_watchdog_step.get("finished", false)), "watchdog overshoot did not finish the pitch-police cut-in", failures)
	_check((BossCutinSystemScript.build_view(pitch_watchdog_step.get("runtime", {}) as Dictionary).get("customView", {}) as Dictionary).is_empty(), "watchdog finish left pitch-police custom draw state", failures)

	if failures.is_empty():
		print("Boss cut-in V3 deterministic tests passed")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	get_tree().quit(1)

func _base_v3_data(case_data: Dictionary) -> Dictionary:
	return {
		"version": 3,
		"bossId": String(case_data.get("bossId", "test")),
		"displayName": "V3 TEST",
		"durationSeconds": float(case_data.get("duration", 2.15)),
		"customIntroId": String(case_data.get("customIntroId", "")),
		"customFinaleId": String(case_data.get("customFinaleId", "")),
		"customIntroDurationSeconds": float(case_data.get("customIntroDurationSeconds", 0.60)),
		"useSilhouetteReveal": true,
		"useCommentBurst": true,
		"connectImageToBossSpawn": true,
		"useBossIntroPose": true
	}

func _custom_view_at(data: Dictionary, time: float) -> Dictionary:
	var runtime := BossCutinSystemScript.start(data, "debug_return", "playing")
	runtime = (BossCutinSystemScript.update(runtime, time).get("runtime", {}) as Dictionary)
	return (BossCutinSystemScript.build_view(runtime).get("customView", {}) as Dictionary)

func _contains_damage_part(parts: Array) -> bool:
	for item in parts:
		var part: Dictionary = item as Dictionary
		for forbidden_key in ["damage", "hitbox", "attack", "collision", "projectile"]:
			if part.has(forbidden_key):
				return true
	return false

func _max_part_alpha(parts: Array) -> float:
	var result := 0.0
	for item in parts:
		var part: Dictionary = item as Dictionary
		result = maxf(result, float((part.get("color", Color.TRANSPARENT) as Color).a))
	return result

func _unique_count(values: Array) -> int:
	var unique: Dictionary = {}
	for value in values:
		unique[String(value)] = true
	return unique.size()

func _all_zero(values: Array) -> bool:
	for value in values:
		if not is_zero_approx(float(value)):
			return false
	return true

func _event_before(events: Array, first: String, second: String) -> bool:
	var first_index := events.find(first)
	var second_index := events.find(second)
	return first_index >= 0 and second_index >= 0 and first_index < second_index

func _check(condition: bool, message: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(message)
