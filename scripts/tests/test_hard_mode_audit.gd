extends Node

const HardMode := preload("res://scripts/systems/hard_mode_system.gd")

class FakeTarget:
	extends Node
	var difficulty_runtime: Dictionary = {}
	var run_difficulty_id := "hard"
	var relay_mode := false
	var current_stream_frame_id := "zatsudan"
	var hard_boss_role := "firstHardBoss"
	var boss_active := false
	var relay_boss_active := false
	var boss_requested := false
	var active_genre_event := ""
	var collab_challenge_status := ""
	var boss_summon_count := 0

func _ready() -> void:
	var failures: Array[String] = []
	var source := {"modes": {"normal": {}, "hard": {}, "expert": {"implemented": false}}}
	var hard_runtime := HardMode.build_runtime("hard", false, "zatsudan", source, {"segmentDuration": 120.0})
	var normal_runtime := HardMode.build_runtime("normal", false, "zatsudan", source, {"segmentDuration": 120.0})
	var final_runtime := HardMode.build_runtime("hard", true, "collab", source, {"segmentDuration": 120.0}, true)
	var expert_source := {"modes": {"normal": {}, "hard": {}, "expert": {"implemented": true, "combatModifiersImplemented": true, "instructionCommentsImplemented": true}}}
	var expert_runtime := HardMode.build_runtime("expert", false, "zatsudan", expert_source, {"segmentDuration": 120.0})
	var expert_final_runtime := HardMode.build_runtime("expert", true, "collab", expert_source, {"segmentDuration": 120.0}, true, 4)
	_check(not HardMode.is_hard_runtime(expert_runtime) and HardMode.is_high_difficulty_runtime(expert_runtime), "EXPERT strict HARD compatibility and shared high runtime", failures)
	var expert_config: Dictionary = expert_runtime.get("difficultyConfig", {}) as Dictionary
	var expert_enemy_rates: Dictionary = expert_config.get("enemyFinalRates", {}) as Dictionary
	var expert_standard: Dictionary = expert_enemy_rates.get("standard", {}) as Dictionary
	_check(is_equal_approx(float(expert_standard.get("hpRate", 0.0)), 1.20 * 1.15) and is_equal_approx(float(expert_standard.get("attackIntervalRate", 0.0)), 0.90 * 0.92), "EXPERT enemy rates inherit HARD once", failures)
	_check(is_equal_approx(HardMode.effective_exp_rate(expert_runtime), 1.20), "EXPERT experience remains HARD rate", failures)
	_check(is_equal_approx(float((HardMode.boss_rates(expert_runtime)).get("projectileSpeedRate", 0.0)), 1.10), "EXPERT regular boss projectile speed rate", failures)
	_check(is_equal_approx(float((HardMode.final_boss_rates(expert_final_runtime)).get("hpRate", 0.0)), 1.35 * 1.20) and is_equal_approx(float((HardMode.final_boss_rates(expert_final_runtime)).get("attackRate", 0.0)), 1.10 * 1.10) and is_equal_approx(float((HardMode.final_boss_rates(expert_final_runtime)).get("actionIntervalRate", 0.0)), 0.85 * 0.90) and is_equal_approx(float((HardMode.final_boss_rates(expert_final_runtime)).get("projectileSpeedRate", 0.0)), 1.10 * 1.10), "EXPERT final boss rates inherit HARD once", failures)

	var hard_enemy := {"combatType": "standard", "hp": 10.0, "max_hp": 10.0, "speed": 100.0, "contactDamage": 10, "baseExp": 5.0}
	HardMode.apply_enemy_runtime_stats(hard_enemy, hard_runtime)
	_check(is_equal_approx(float(hard_enemy.get("max_hp")), 12.0), "HARD standard HP", failures)
	_check(int(hard_enemy.get("contactDamage")) == 11, "HARD standard damage", failures)
	_check(is_equal_approx(float(hard_enemy.get("speed")), 108.0), "HARD standard speed", failures)
	_check(is_equal_approx(float(hard_enemy.get("projectileSpeedRate")), 1.10), "HARD standard projectile speed", failures)
	_check(is_equal_approx(HardMode.attack_interval_for_enemy(hard_enemy, 1.0), 0.90), "HARD standard attack interval", failures)
	var once_hp := float(hard_enemy.get("max_hp"))
	HardMode.apply_enemy_runtime_stats(hard_enemy, hard_runtime)
	_check(is_equal_approx(float(hard_enemy.get("max_hp")), once_hp), "HARD enemy applies once", failures)

	var normal_enemy := {"combatType": "standard", "hp": 10.0, "max_hp": 10.0, "speed": 100.0, "contactDamage": 10, "baseExp": 5.0}
	HardMode.apply_enemy_runtime_stats(normal_enemy, normal_runtime)
	_check(is_equal_approx(float(normal_enemy.get("max_hp")), 10.0) and int(normal_enemy.get("contactDamage")) == 10 and is_equal_approx(float(normal_enemy.get("speed")), 100.0), "NORMAL enemy unchanged", failures)

	var expected_damage := [[1.0, 1.05, 1], [2.0, 1.05, 2], [3.0, 1.10, 3], [5.0, 1.10, 6], [10.0, 1.10, 11]]
	for row in expected_damage:
		_check(HardMode.scaled_damage(float(row[0]), float(row[1])) == int(row[2]), "safe damage rounding %s" % [row], failures)

	var target := FakeTarget.new()
	target.difficulty_runtime = hard_runtime
	_check(HardMode.regular_boss_summon_count_for_target(target, 1) == 1, "single boss summon remains one", failures)
	_check(HardMode.regular_boss_summon_count_for_target(target, 2) == 3, "regular HARD boss summon 2 to 3", failures)
	_check(HardMode.regular_boss_summon_count_for_target(target, 4) == 5, "regular HARD boss summon 4 to 5", failures)
	_check(HardMode.regular_boss_damage_for_target(target, 5) == 6, "regular HARD boss damage", failures)
	target.difficulty_runtime = normal_runtime
	_check(HardMode.regular_boss_summon_count_for_target(target, 2) == 2 and HardMode.regular_boss_damage_for_target(target, 5) == 5, "NORMAL boss unchanged", failures)
	_check(is_equal_approx(HardMode.regular_boss_projectile_speed_for_target(target, 245.0), 245.0), "NORMAL boss projectile speed unchanged", failures)
	target.difficulty_runtime = expert_runtime
	_check(is_equal_approx(HardMode.regular_boss_projectile_speed_for_target(target, 245.0), 245.0 * 1.10), "EXPERT regular boss projectile speed", failures)
	target.difficulty_runtime = final_runtime
	_check(HardMode.regular_boss_summon_count_for_target(target, 2) == 2, "final boss excludes regular summon rate", failures)
	var final_rng := RandomNumberGenerator.new()
	final_rng.seed = 5
	_check(HardMode.apply_spawn_count_rate(5, 1.40, final_rng) == 7, "final boss 1.40 path", failures)

	var boss := {"hp": 100.0, "max_hp": 100.0, "speed": 50.0, "contactDamage": 10, "bossAttackIntervalRate": 0.80, "bossAttackTimers": {"attack": 10.0}}
	HardMode.apply_boss_runtime_stats(boss, hard_runtime)
	_check(is_equal_approx(float(boss.get("bossAttackIntervalRate")), 0.68), "boss 0.85 times 0.80", failures)
	_check(is_equal_approx(float((boss.get("bossAttackTimers") as Dictionary).get("attack")), 8.5), "existing boss timer gets HARD 0.85 once", failures)

	var relay_collab := HardMode.build_runtime("hard", true, "collab", source, {"segmentDuration": 120.0})
	var relay_enemy := {"combatType": "standard", "hp": 160.0, "max_hp": 160.0, "speed": 110.0, "contactDamage": 10, "baseExp": 5.0}
	HardMode.apply_enemy_runtime_stats(relay_enemy, relay_collab)
	_check(is_equal_approx(float(relay_enemy.get("max_hp")), 192.0), "relay collab 1.60 times HARD 1.20", failures)
	_check(is_equal_approx(HardMode.spawn_rate(relay_collab, 100.0), 1.87), "relay collab late spawn 1.87", failures)
	_check(is_equal_approx(HardMode.spawn_rate(relay_collab, 100.0, false, true), 0.935), "collab challenge 0.50 once", failures)

	var cap_runtime := hard_runtime.duplicate(true)
	var selection: Dictionary = (cap_runtime.get("difficultyConfig", {}) as Dictionary).get("hardWaveSelectionRates", {}) as Dictionary
	selection["earlyRate"] = 1.0
	selection["middleRate"] = 1.0
	selection["lateRate"] = 1.0
	var cap_rng := RandomNumberGenerator.new()
	cap_rng.seed = 7
	_check(HardMode.choose_hard_wave(cap_runtime, 25.0, 5, 24, {}, false, cap_rng, 26).is_empty(), "mixed wave respects cap", failures)
	_check(HardMode.hard_wave_candidates(normal_runtime, 25.0, 5).is_empty(), "NORMAL has no HARD mixed wave", failures)

	target.difficulty_runtime = hard_runtime.duplicate(true)
	target.difficulty_runtime["activeComment"] = {"id": "hard_pressure_wave"}
	target.difficulty_runtime["pendingPressureWave"] = {"state": "queued"}
	HardMode.clear_active_comment_for_target(target)
	_check((target.difficulty_runtime.get("activeComment", {}) as Dictionary).is_empty() and (target.difficulty_runtime.get("pendingPressureWave", {}) as Dictionary).is_empty(), "instruction cleanup removes pending pressure wave", failures)
	target.free()

	if failures.is_empty():
		print("hard mode audit tests passed")
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error(failure)
		get_tree().quit(1)

func _check(condition: bool, message: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(message)
