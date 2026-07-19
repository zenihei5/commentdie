extends Node

const BossCutinSystemScript := preload("res://scripts/systems/boss_cutin_system.gd")

func _ready() -> void:
	var failures: Array[String] = []
	var normal := BossCutinSystemScript.start({"displayName": "TEST", "durationSeconds": 1.5}, "spawn_normal_boss", "playing")
	var step: Dictionary = BossCutinSystemScript.update(normal, 0.64)
	_check(not bool(step.get("playRevealSe", false)), "normal reveal fired too early", failures)
	normal = step["runtime"] as Dictionary
	step = BossCutinSystemScript.update(normal, 0.02)
	_check(bool(step.get("playRevealSe", false)), "normal reveal did not fire at 0.65s", failures)
	normal = step["runtime"] as Dictionary
	step = BossCutinSystemScript.update(normal, 0.20)
	_check(not bool(step.get("playRevealSe", false)), "normal reveal fired more than once", failures)
	normal = step["runtime"] as Dictionary
	step = BossCutinSystemScript.update(normal, 1.0)
	_check(bool(step.get("finished", false)), "normal cut-in did not finish", failures)
	normal = step["runtime"] as Dictionary
	step = BossCutinSystemScript.update(normal, 1.0)
	_check(not bool(step.get("finished", false)), "normal completion dispatched more than once", failures)

	var final_runtime := BossCutinSystemScript.start({"displayName": "FINAL", "durationSeconds": 2.4, "isFinalBoss": true}, "start_relay_final_boss", "stream_start_intro")
	step = BossCutinSystemScript.update(final_runtime, 1.09)
	_check(not bool(step.get("playRevealSe", false)), "final reveal fired too early", failures)
	final_runtime = step["runtime"] as Dictionary
	step = BossCutinSystemScript.update(final_runtime, 0.02)
	_check(bool(step.get("playRevealSe", false)), "final reveal did not fire at 1.10s", failures)
	final_runtime = step["runtime"] as Dictionary
	var view: Dictionary = BossCutinSystemScript.build_view(final_runtime)
	_check(float(view.get("nameProgress", 0.0)) > 0.0, "final name timeline did not advance", failures)
	final_runtime = BossCutinSystemScript.cancel(final_runtime)
	step = BossCutinSystemScript.update(final_runtime, 10.0)
	_check(not bool(step.get("finished", false)), "cancelled cut-in dispatched completion", failures)

	var v2_data := {
		"version": 2,
		"bossId": "test_v2",
		"displayName": "V2 TEST",
		"durationSeconds": 1.8,
		"useSilhouetteReveal": true,
		"useCommentBurst": true,
		"connectImageToBossSpawn": true,
		"useBossIntroPose": true,
		"introPoseId": "generic"
	}
	var v2_runtime := BossCutinSystemScript.start(v2_data, "spawn_normal_boss", "playing")
	_check(int(v2_runtime.get("version", 1)) == 2, "V2 runtime did not activate", failures)
	step = BossCutinSystemScript.update(v2_runtime, 1.47)
	var v2_events: Array = step.get("events", []) as Array
	_check(v2_events.has("theme_sweep") and v2_events.has("reveal_flash") and v2_events.has("name_impact"), "V2 large delta lost early events", failures)
	_check(v2_events.has("comment_burst") and v2_events.has("spawn_boss_locked"), "V2 large delta lost handoff events", failures)
	_check(not v2_events.has("reveal_field_boss"), "V2 field reveal fired before 1.50s", failures)
	v2_runtime = step["runtime"] as Dictionary
	var pre_field_view: Dictionary = BossCutinSystemScript.build_view(v2_runtime)
	_check(is_zero_approx(float(pre_field_view.get("fieldBossAlpha", -1.0))), "V2 field boss became visible before 1.50s", failures)
	step = BossCutinSystemScript.update(v2_runtime, 0.04)
	_check((step.get("events", []) as Array).has("reveal_field_boss"), "V2 field reveal did not fire at 1.50s", failures)
	v2_runtime = step["runtime"] as Dictionary
	var v2_view: Dictionary = BossCutinSystemScript.build_view(v2_runtime)
	_check(float(v2_view.get("connectProgress", 0.0)) > 0.9, "V2 connection did not reach field handoff", failures)
	step = BossCutinSystemScript.update(v2_runtime, 0.29)
	_check(bool(step.get("finished", false)), "V2 normal cut-in did not finish at 1.80s", failures)
	_check((step.get("events", []) as Array).has("show_hp_bar"), "V2 HP bar event was not delivered", failures)

	var final_v2_data := v2_data.duplicate(true)
	final_v2_data["bossId"] = "last_offline"
	final_v2_data["isFinalBoss"] = true
	final_v2_data["durationSeconds"] = 2.8
	final_v2_data["useRelayThemeSequence"] = true
	var final_v2 := BossCutinSystemScript.start(final_v2_data, "start_relay_final_boss", "stream_start_intro")
	step = BossCutinSystemScript.update(final_v2, 2.45)
	_check((step.get("events", []) as Array).has("spawn_boss_locked"), "FINAL V2 did not hand off at 90 percent", failures)
	_check(not (step.get("events", []) as Array).has("reveal_field_boss"), "FINAL V2 revealed field boss before 2.48s", failures)
	final_v2 = step["runtime"] as Dictionary
	var final_v2_view := BossCutinSystemScript.build_view(final_v2)
	_check((final_v2_view.get("relayMotifProgresses", []) as Array).size() == 5, "FINAL V2 did not expose five relay motifs", failures)
	step = BossCutinSystemScript.update(final_v2, 0.35)
	_check(bool(step.get("finished", false)), "FINAL V2 did not finish at 2.80s", failures)

	if failures.is_empty():
		print("BossCutinSystem timeline tests passed")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	get_tree().quit(1)

func _check(condition: bool, message: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(message)
