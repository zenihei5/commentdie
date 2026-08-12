extends Node

const HardMode := preload("res://scripts/systems/hard_mode_system.gd")
const DangerEvent := preload("res://scripts/systems/danger_event_system.gd")
const Comment := preload("res://scripts/systems/comment_system.gd")
const Modifier := preload("res://scripts/systems/modifier_system.gd")
const Spawner := preload("res://scripts/systems/spawner_system.gd")
const Exp := preload("res://scripts/systems/exp_system.gd")
const Enemy := preload("res://scripts/systems/enemy_system.gd")
const DrawData := preload("res://scripts/systems/draw_data_system.gd")

class FakeTarget:
	extends Node
	var difficulty_runtime: Dictionary = {}
	var elapsed := 0.0
	var last_comment_id := ""
	var relay_mode := false
	var boss_requested := false
	var boss_active := false
	var relay_boss_active := false
	var hard_boss_role := "firstHardBoss"
	var run_difficulty_id := "hard"
	var current_stream_frame: Dictionary = {}
	var current_stream_frame_id := "zatsudan"
	var player_pos := Vector2(1120.0, 870.0)
	var world_zoom := 1.0
	var do_everything_offer_count := 0
	var recent_comment_categories: Array = []
	var yes_listener := false
	var exp_level := 5
	var boss_summon_count := 0
	var active_genre_event := ""
	var collab_challenge_status := ""
	var collab_partner_pos := Vector2.ZERO
	var song_chorus_timer := 0.0
	var song_chorus_telegraph_timer := 0.0
	var debug_rare_comment_boost := false
	var gift_hype := 44
	var max_gift_hype := 61
	var pending_clear_hype := 18
	var active_comment_hurt := false
	var effect_timer := 8.0
	var active_effects: Array[String] = ["test_effect"]
	var active_effect_rates: Dictionary = {"test_effect": 1.0}
	var active_sub_comment_ids: Array[String] = ["test_sub"]
	var effect_walls: Array = [{"kind": "wall"}]
	var effect_pits: Array = [{"kind": "pit"}]
	var hit_fx: Array = []
	var chat_lines: Array[String] = ["今のうまい", "敵多くない？", "コメント欄が盛り上がってきた"]
	var player_vel := Vector2.ZERO
	var current_comment := "test"
	var current_death_text := "test death"
	var multiplier := 3.0
	var relay_base_multiplier := 1.0
	var active_comment_score_rate := 1.8
	var exp_orbs: Array = []
	var balance_debug_stats: Dictionary = {}
	var hard_run_exp_stats: Dictionary = {}
	var enemies: Array = []
	var enemy_bullets: Array = []
	var next_enemy_uid := 1

func _ready() -> void:
	var failures: Array[String] = []
	var source := {"modes": {"normal": {}, "hard": {}, "expert": {"implemented": false}}}
	var hard_runtime := HardMode.build_runtime("hard", false, "talk", source, {"segmentDuration": 120.0})
	_check(HardMode.is_hard_runtime(hard_runtime), "hard runtime implemented", failures)
	_check(String(hard_runtime.get("stageId")) == "zatsudan", "talk alias", failures)
	_check(is_equal_approx(HardMode.effective_exp_rate(hard_runtime), 1.20), "single exp rate", failures)
	_check(is_equal_approx(HardMode.spawn_rate(hard_runtime, 0.0), 1.10), "single spawn phase 0", failures)
	_check(is_equal_approx(HardMode.spawn_rate(hard_runtime, 30.0), 1.25), "single spawn phase 30", failures)
	_check(is_equal_approx(HardMode.spawn_rate(hard_runtime, 90.0), 1.50), "single spawn phase 90", failures)
	_check(is_equal_approx(HardMode.spawn_rate(hard_runtime, 150.0), 1.75), "single spawn phase 150", failures)
	hard_runtime["climax"] = {"active": true}
	_check(is_equal_approx(HardMode.spawn_rate(hard_runtime, 150.0), 1.75), "climax does not double spawn rate", failures)
	_check(is_equal_approx(HardMode.spawn_rate(hard_runtime, 150.0, true), 1.75 * 0.65), "boss suppression only single normal spawn", failures)
	_check(HardMode.active_enemy_cap(20, hard_runtime) == 26, "active cap floor", failures)
	_check(is_equal_approx(HardMode.spawn_rate(hard_runtime, 180.0), 0.0), "single spawn stops at duration", failures)
	_check(not HardMode.spawn_enabled(HardMode.build_runtime("hard", true, "collab", source, {"segmentDuration": 120.0}, true), 0.0), "final boss disables normal spawn", failures)
	var relay_runtime := HardMode.build_runtime("hard", true, "gameplay", source, {"segmentDuration": 120.0})
	_check(is_equal_approx(HardMode.spawn_rate(relay_runtime, 0.0), 0.95 * 1.00), "relay stage and time rates", failures)
	_check(is_equal_approx(HardMode.spawn_rate(relay_runtime, 20.0), 0.95 * 1.20), "relay time boundary", failures)
	_check(is_equal_approx(HardMode.spawn_rate(relay_runtime, 100.0), 0.95 * 1.70), "relay late time boundary", failures)
	_check(is_equal_approx(HardMode.effective_exp_rate(relay_runtime), 1.20), "relay exp rate", failures)
	_check(is_equal_approx(HardMode.spawn_rate(relay_runtime, 20.0, false, true), 0.95 * 1.20), "collab event is stage gated", failures)
	var collab_runtime := HardMode.build_runtime("hard", true, "collab", source, {"segmentDuration": 120.0})
	_check(is_equal_approx(HardMode.spawn_rate(collab_runtime, 20.0, false, true), 1.10 * 1.20 * 0.50), "collab event spawn suppression", failures)
	_check(is_equal_approx(HardMode.spawn_rate(collab_runtime, 100.0), 1.10 * 1.70), "relay collab late spawn pressure is 1.87", failures)
	_check(is_equal_approx(HardMode.spawn_rate(collab_runtime, 100.0, false, true), 1.10 * 1.70 * 0.50), "relay collab challenge adds one 0.50 suppression", failures)
	var step := Spawner.spawn_step({"spawnTimer": 0.0, "delta": 0.0, "baseInterval": 1.0, "hardSpawnRate": 2.0, "spawnMultiplier": 1.0, "songInstructionSpawnMultiplier": 1.0})
	_check(is_equal_approx(float(step.get("spawnTimer", 0.0)), 0.5) and int(step.get("spawnCount", 0)) == 1, "hard spawn rate applies to interval only", failures)
	var rate_config: Dictionary = HardMode.default_config().get("enemyFinalRates", {}) as Dictionary
	_check(is_equal_approx(float((rate_config["standard"] as Dictionary)["attackIntervalRate"]), 0.90), "standard attack interval rate", failures)
	_check(is_equal_approx(float((rate_config["tank"] as Dictionary)["hpRate"]), 1.30), "tank hp rate", failures)
	_check(is_equal_approx(float((rate_config["ranged"] as Dictionary)["projectileSpeedRate"]), 1.10), "ranged projectile rate", failures)
	var summon_rewards: Dictionary = (HardMode.default_config().get("finalBoss", {}) as Dictionary).get("summonRewards", {}) as Dictionary
	_check(is_equal_approx(float(summon_rewards.get("healDropRate", 0.0)), 0.10) and bool(summon_rewards.get("starDropEnabled", false)) and not bool(summon_rewards.get("expEnabled", true)) and not bool(summon_rewards.get("scoreEnabled", true)), "final summon reward split", failures)
	_check(HardMode.hard_wave_candidates(hard_runtime, 25.0, 5).size() == 1, "hard wave stage/time filter", failures)
	_check(is_equal_approx(HardMode.hard_wave_selection_rate(hard_runtime, 43.2), 0.15) and is_equal_approx(HardMode.hard_wave_selection_rate(hard_runtime, 45.0), 0.25) and is_equal_approx(HardMode.hard_wave_selection_rate(hard_runtime, 108.0), 0.35), "hard wave progress boundaries", failures)
	_check(HardMode.hard_wave_candidates(relay_runtime, 121.0, 5).is_empty(), "relay wave stops after section", failures)
	_check(HardMode.temporary_score_rate(hard_runtime, 1.55) <= 2.0, "temporary score cap", failures)
	var final_runtime := HardMode.build_runtime("hard", true, "collab", source, {"segmentDuration": 120.0}, true)
	_check(HardMode.final_boss_phase_count(final_runtime) == 3, "final boss phase count", failures)
	_check(HardMode.final_boss_phase(final_runtime, 0.80) == 0, "final phase 1", failures)
	_check(HardMode.final_boss_phase(final_runtime, 0.50) == 1, "final phase 2", failures)
	_check(HardMode.final_boss_phase(final_runtime, 0.20) == 2, "final phase 3", failures)
	_check(not HardMode.is_hard_runtime(HardMode.build_runtime("expert", false, "zatsudan", source, {})), "expert does not inherit hard", failures)

	var enemy := {"kind": "fast", "hp": 10.0, "max_hp": 10.0, "speed": 100.0, "contactDamage": 10, "exp": 10, "expValue": 10}
	HardMode.apply_enemy_runtime_stats(enemy, hard_runtime)
	_check(is_equal_approx(float(enemy.get("max_hp")), 11.0), "fast hp rate", failures)
	_check(is_equal_approx(float(enemy.get("speed")), 115.0), "fast move rate", failures)
	_check(is_equal_approx(float(enemy.get("expValue")), 10.0) and is_equal_approx(float(enemy.get("baseExp")), 10.0), "spawn keeps base exp", failures)
	_check(bool(enemy.get("difficultyRuntimeApplied", false)), "enemy applied once", failures)
	_check(int(enemy.get("contactDamage")) == 11, "attack uses nearest integer rounding", failures)
	_check(HardMode.scaled_damage(1.0, 1.05) == 1, "one damage is not doubled by 1.05", failures)
	_check(HardMode.scaled_damage(2.0, 1.05) == 2, "two damage remains two at 1.05", failures)
	_check(HardMode.scaled_damage(3.0, 1.10) == 3, "three damage remains three at 1.10", failures)
	_check(HardMode.scaled_damage(5.0, 1.10) == 6, "five damage rounds to six at 1.10", failures)
	_check(HardMode.scaled_damage(10.0, 1.10) == 11, "ten damage becomes eleven at 1.10", failures)
	var low_damage_enemy := {"combatType": "swarm", "hp": 1.0, "max_hp": 1.0, "speed": 10.0, "contactDamage": 1, "baseExp": 1.0}
	HardMode.apply_enemy_runtime_stats(low_damage_enemy, hard_runtime)
	_check(int(low_damage_enemy.get("contactDamage")) == 1, "low HARD contact damage uses safe rounding", failures)
	_check(is_equal_approx(HardMode.attack_interval_for_values(0.05, 0.5, 0.1), 0.1), "minimum attack interval", failures)
	var before_hp := float(enemy.get("max_hp"))
	HardMode.apply_enemy_runtime_stats(enemy, hard_runtime)
	_check(is_equal_approx(float(enemy.get("max_hp")), before_hp), "enemy no double apply", failures)
	var standard_enemy := {"combatType": "standard", "hp": 10.0, "max_hp": 10.0, "speed": 100.0, "contactDamage": 10, "baseExp": 5.0}
	HardMode.apply_enemy_runtime_stats(standard_enemy, hard_runtime)
	_check(is_equal_approx(float(standard_enemy.get("max_hp")), 12.0) and int(standard_enemy.get("contactDamage")) == 11, "standard final rates", failures)
	var relay_collab_standard := {"combatType": "standard", "hp": 160.0, "max_hp": 160.0, "speed": 110.0, "contactDamage": 10, "baseExp": 5.0}
	HardMode.apply_enemy_runtime_stats(relay_collab_standard, collab_runtime)
	_check(is_equal_approx(float(relay_collab_standard.get("max_hp")), 192.0), "relay collab HP 1.60 composes once with HARD standard 1.20", failures)
	var tank_enemy := {"combatType": "tank", "hp": 10.0, "max_hp": 10.0, "speed": 100.0, "contactDamage": 10, "baseExp": 5.0}
	HardMode.apply_enemy_runtime_stats(tank_enemy, hard_runtime)
	_check(is_equal_approx(float(tank_enemy.get("max_hp")), 13.0), "tank final hp rate", failures)
	var ranged_enemy := {"combatType": "ranged", "hp": 10.0, "max_hp": 10.0, "speed": 100.0, "contactDamage": 10, "baseExp": 5.0}
	HardMode.apply_enemy_runtime_stats(ranged_enemy, hard_runtime)
	_check(is_equal_approx(float(ranged_enemy.get("projectileSpeedRate")), 1.10) and is_equal_approx(HardMode.attack_interval_for_enemy(ranged_enemy, 1.0), 0.90), "ranged projectile and interval rates", failures)
	fake_for_exp(hard_runtime, failures)
	var normal_enemy := {"kind": "standard", "hp": 10.0, "max_hp": 10.0, "speed": 100.0, "contactDamage": 10, "exp": 10, "expValue": 10}
	var normal_runtime := HardMode.build_runtime("normal", false, "zatsudan", source, {})
	HardMode.apply_enemy_runtime_stats(normal_enemy, normal_runtime)
	_check(is_equal_approx(float(normal_enemy.get("max_hp")), 10.0) and int(normal_enemy.get("contactDamage")) == 10, "normal has no hard correction", failures)
	_check(is_equal_approx(HardMode.spawn_rate(normal_runtime, 150.0), 1.0) and is_equal_approx(HardMode.effective_exp_rate(normal_runtime), 1.0) and HardMode.active_enemy_cap(20, normal_runtime) == 20, "normal all hard rates are one", failures)
	var summon_target := FakeTarget.new()
	summon_target.difficulty_runtime = hard_runtime
	_check(HardMode.regular_boss_summon_count_for_target(summon_target, 1) == 1 and HardMode.regular_boss_summon_count_for_target(summon_target, 2) == 3 and HardMode.regular_boss_summon_count_for_target(summon_target, 4) == 5, "regular HARD boss summon count uses 1.25 without inflating a single summon", failures)
	summon_target.difficulty_runtime = normal_runtime
	_check(HardMode.regular_boss_summon_count_for_target(summon_target, 2) == 2, "normal boss summon count remains unchanged", failures)
	summon_target.difficulty_runtime = final_runtime
	_check(HardMode.regular_boss_summon_count_for_target(summon_target, 2) == 2, "regular summon helper does not stack onto final boss summons", failures)
	var final_summon_rng := RandomNumberGenerator.new()
	final_summon_rng.seed = 73
	_check(HardMode.regular_boss_summon_count_for_target(summon_target, 0) == 0 and HardMode.apply_spawn_count_rate(5, 1.40, final_summon_rng) == 7, "zero regular summons stay zero and final boss 1.40 path remains intact", failures)
	var boss_stats := {"hp": 100.0, "max_hp": 100.0, "speed": 50.0, "contactDamage": 10, "bossAttackIntervalRate": 0.80, "bossAttackTimers": {"test": 10.0}}
	HardMode.apply_boss_runtime_stats(boss_stats, hard_runtime)
	_check(is_equal_approx(float(boss_stats.get("bossAttackIntervalRate")), 0.68) and is_equal_approx(float((boss_stats.get("bossAttackTimers") as Dictionary).get("test")), 8.5), "boss action interval composes 0.85 with existing 0.80 once", failures)
	var normal_action_target := FakeTarget.new()
	normal_action_target.difficulty_runtime = normal_runtime
	_check(is_equal_approx(HardMode.boss_action_delta_for_target(normal_action_target, {"bossAttackIntervalRate": 0.80}, 1.0), 1.0), "normal specialized boss timing remains unchanged", failures)
	var boss_hp_once := float(boss_stats.get("max_hp"))
	HardMode.apply_boss_runtime_stats(boss_stats, hard_runtime)
	_check(is_equal_approx(float(boss_stats.get("max_hp")), boss_hp_once) and is_equal_approx(float(boss_stats.get("bossAttackIntervalRate")), 0.68), "boss HARD stats do not double apply", failures)
	var unknown_runtime := HardMode.build_runtime("unknown", false, "zatsudan", source, {})
	_check(is_equal_approx(HardMode.spawn_rate(unknown_runtime, 150.0), 1.0) and is_equal_approx(HardMode.effective_exp_rate(unknown_runtime), 1.0), "unknown difficulty falls back to normal", failures)
	var request_runtime := hard_runtime.duplicate(true)
	var request := HardMode.enqueue_spawn_request(request_runtime, HardMode.make_spawn_request("troll", 2, "hard_wave", 1.0), 10.0)
	_check(int(request.get("serial", 0)) == 1 and (request_runtime.get("pendingSpawnRequests", []) as Array).size() == 1, "spawn request serial and queue", failures)
	HardMode.prune_spawn_requests(request_runtime, 11.1)
	_check((request_runtime.get("pendingSpawnRequests", []) as Array).is_empty(), "spawn request expiry", failures)
	var cap_runtime := hard_runtime.duplicate(true)
	var cap_selection: Dictionary = (cap_runtime.get("difficultyConfig", {}) as Dictionary).get("hardWaveSelectionRates", {}) as Dictionary
	cap_selection["earlyRate"] = 1.0
	cap_selection["middleRate"] = 1.0
	cap_selection["lateRate"] = 1.0
	var cap_rng := RandomNumberGenerator.new()
	cap_rng.seed = 91
	_check(HardMode.choose_hard_wave(cap_runtime, 25.0, 5, 24, {}, false, cap_rng, 26).is_empty(), "mixed HARD wave is rejected when its reserve would exceed the cap", failures)
	cap_rng.seed = 91
	_check(not HardMode.choose_hard_wave(cap_runtime, 25.0, 5, 23, {}, false, cap_rng, 26).is_empty(), "mixed HARD wave can use exactly the remaining cap", failures)
	_check(HardMode.hard_wave_candidates(normal_runtime, 25.0, 5).is_empty(), "normal mode has no HARD mixed wave", failures)
	_check(String(Enemy.enemy_data("long_comment_guy").get("combatType")) == "tank", "long comment enemy uses tank classification", failures)
	_check(String(Enemy.enemy_data("pitch_police").get("combatType")) == "standard", "melee pitch police is not ranged", failures)
	_check(String(Enemy.enemy_data("collab_exclusive_listener").get("combatType")) == "support", "zero-damage partner blocker uses support classification", failures)
	_check(String(Enemy.enemy_data("enemy_jammer_cone").get("combatType")) == "special" and String(Enemy.enemy_data("collab_mute_core").get("combatType")) == "special", "stage and boss objects use special classification", failures)

	var fake := FakeTarget.new()
	fake.difficulty_runtime = hard_runtime
	fake.elapsed = 44.9
	HardMode.advance_runtime_for_target(fake, 44.9, 135.1, 0.1, 0, false)
	_check((fake.difficulty_runtime.get("pendingSpawn", {}) as Dictionary).is_empty(), "auto boss before 105", failures)
	fake.elapsed = 105.0
	HardMode.advance_runtime_for_target(fake, 105.0, 75.0, 0.1, 0, false)
	_check(not (fake.difficulty_runtime.get("pendingSpawn", {}) as Dictionary).is_empty(), "auto boss at 105", failures)
	HardMode.mark_boss_spawned(fake, "firstHardBoss", 105.0)
	HardMode.mark_boss_defeated(fake, "firstHardBoss")
	_check(HardMode.can_offer_reignition(fake.difficulty_runtime, 45.0, 0), "reignition at 45 remaining", failures)
	var reignition_comment := HardMode._reignition_comment()
	_check(String(reignition_comment.get("displayName", "")) == "再炎上", "reignition uses the formal Japanese display name", failures)
	_check(String(reignition_comment.get("description", "")) == "倒したボスが強化されて再登場する", "reignition uses the formal Japanese description", failures)
	_check(ResourceLoader.exists("res://assets/generated/instruction_comment_icons_v1/hard_reignition_boss_icon.png"), "reignition icon resource exists", failures)

	var comment := {"id": "enemy_speed_up", "multiplier": 2.0, "riskLevel": 2, "difficultyOverrides": {"hard": {"riskLevel": 4, "params": {"rate": 1.25}}}}
	var resolved := HardMode.resolve_comment(comment, hard_runtime)
	_check(int(resolved.get("riskLevel")) == 4, "comment deep merge", failures)
	_check(is_equal_approx(float(resolved.get("params", {}).get("rate", 0.0)), 1.25), "comment params merge", failures)
	var danger_fallback := HardMode.resolve_comment({"id": "fallback", "riskLevel": 4, "multiplier": 9.0}, hard_runtime)
	_check(is_equal_approx(float(danger_fallback.get("scoreRate", 0.0)), 1.45), "hard danger score fallback", failures)
	_check(HardMode.comment_categories({"id": "reverse_control"}).has("control_restriction"), "legacy comment category map", failures)
	_check(HardMode.comment_categories({"id": "hard_overclock", "categories": ["enemy_attack", "projectile_pressure", "compound"]}).has("projectile_pressure"), "hard comment categories", failures)
	var single_safe_offer := HardMode.build_safe_default_offer_for_target(fake, [{"id": "safe_default", "riskLevel": 1, "multiplier": 1.0, "minTime": 0.0, "tags": ["default"]}], RandomNumberGenerator.new())
	_check(single_safe_offer.size() == 3 and single_safe_offer[0] is Dictionary and single_safe_offer[1] is Dictionary and single_safe_offer[2] is Dictionary, "safe candidate shortage fills three deep-copied cards", failures)
	_check(HardMode.is_safe_offer_duplicate(single_safe_offer[0] as Dictionary), "ordinary comment is duplicate eligible", failures)
	var overclock_runtime: Dictionary = hard_runtime.duplicate(true)
	overclock_runtime["activeComment"] = {"id": "hard_overclock", "params": {"attackIntervalRate": 0.80, "projectileSpeedRate": 1.20}}
	var overclock_enemy := {"attackIntervalRate": 0.90, "projectileSpeedRate": 1.10, "minimumAttackInterval": 0.10}
	_check(is_equal_approx(HardMode.attack_interval_for_enemy(overclock_enemy, 1.0, overclock_runtime), 0.72), "overclock applies to current enemy interval", failures)
	_check(is_equal_approx(HardMode.projectile_speed_rate_for_enemy(overclock_enemy, overclock_runtime), 1.32), "overclock applies to newly spawned projectile rate", failures)
	var resolved_overclock := HardMode.resolve_comment({"id": "hard_overclock", "displayName": "Overclock", "riskLevel": 4, "multiplier": 4.5, "giftHypeOnSelect": 0, "giftHypeOnClear": 0, "deathText": "Overclock"}, overclock_runtime)
	var heart_overclock := Comment.comment_view(resolved_overclock, true)
	_check(is_equal_approx(float(resolved_overclock.get("scoreRate", 0.0)), 1.45) and is_equal_approx(float(heart_overclock.get("scoreRate", 0.0)), 1.25), "overclock score and heart score use danger rates", failures)
	_check(is_equal_approx(HardMode.spawn_rate(overclock_runtime, 60.0), HardMode.spawn_rate(hard_runtime, 60.0)), "overclock does not alter spawn rate", failures)
	var overclock_target := FakeTarget.new()
	overclock_target.difficulty_runtime = overclock_runtime
	HardMode.clear_active_comment_for_target(overclock_target)
	_check(is_equal_approx(HardMode.attack_interval_for_enemy(overclock_enemy, 1.0, overclock_target.difficulty_runtime), 0.90), "temporary attack interval clears with the instruction", failures)
	var pressure_profiles: Dictionary = (hard_runtime.get("difficultyConfig", {}) as Dictionary).get("pressureWaveProfiles", {}) as Dictionary
	_check(pressure_profiles.size() == 5 and (pressure_profiles.get("zatsudan", {}) as Dictionary).get("groups", []).size() >= 2 and (pressure_profiles.get("collab", {}) as Dictionary).get("groups", []).size() >= 2, "pressure wave uses stage profiles", failures)
	var pressure_target := FakeTarget.new()
	pressure_target.difficulty_runtime = hard_runtime.duplicate(true)
	pressure_target.difficulty_runtime["elapsedSeconds"] = 60.0
	HardMode.activate_comment_for_target(pressure_target, {"id": "hard_pressure_wave", "params": {"maxDelay": 3.0, "countRate": 1.0}}, RandomNumberGenerator.new())
	_check(not (pressure_target.difficulty_runtime.get("pendingPressureWave", {}) as Dictionary).is_empty(), "pressure instruction keeps at most one pending wave dictionary", failures)
	pressure_target.elapsed = 63.1
	Spawner._process_pending_pressure_wave(pressure_target, Rect2(Vector2.ZERO, Vector2(1600.0, 900.0)), RandomNumberGenerator.new(), pressure_target.difficulty_runtime, 0)
	_check((pressure_target.difficulty_runtime.get("pendingPressureWave", {}) as Dictionary).is_empty() and String((pressure_target.difficulty_runtime.get("lastPressureWave", {}) as Dictionary).get("state", "")) == "canceled", "pressure wave cancels after its bounded wait when no slot is free", failures)
	pressure_target.difficulty_runtime["elapsedSeconds"] = 64.0
	HardMode.activate_comment_for_target(pressure_target, {"id": "hard_pressure_wave", "params": {"maxDelay": 3.0, "countRate": 1.0}}, RandomNumberGenerator.new())
	HardMode.clear_active_comment_for_target(pressure_target)
	_check((pressure_target.difficulty_runtime.get("pendingPressureWave", {}) as Dictionary).is_empty(), "instruction end discards its pending pressure wave", failures)
	var avalanche_comment := {"id": "talk_comment_avalanche", "params": {"commentCount": 16, "eventDuration": 15.0, "travelDuration": 7.5, "spawnInterval": 0.35, "laneCount": 12, "pushRate": 1.0, "knockbackSpeed": 340.0, "knockbackDuration": 0.20, "moveRate": 0.75, "slowDuration": 0.8, "rehitInterval": 0.6}}
	fake.difficulty_runtime = hard_runtime
	fake.elapsed = 60.0
	var avalanche_rng := RandomNumberGenerator.new()
	avalanche_rng.seed = 42
	HardMode.activate_comment_for_target(fake, avalanche_comment, avalanche_rng)
	var avalanche_state: Dictionary = fake.difficulty_runtime.get("commentAvalanche", {}) as Dictionary
	var first_avalanche_text := String((fake.hit_fx[0] as Dictionary).get("text", "")) if not fake.hit_fx.is_empty() else ""
	_check(bool(avalanche_state.get("active", false)) and int(avalanche_state.get("rows", 0)) == 16 and fake.hit_fx.size() == 16 and fake.chat_lines.has(first_avalanche_text) and DangerEvent.is_active(fake.difficulty_runtime, "stage_major_event"), "avalanche creates dense scattered chat-sourced comments", failures)
	var avalanche_draw_items := DrawData.hit_fx_draw_data(fake.hit_fx)
	_check(not avalanche_draw_items.is_empty() and float((avalanche_draw_items[0] as Dictionary).get("age", 0.0)) > 0.0 and String((avalanche_draw_items[0] as Dictionary).get("text", "")) == first_avalanche_text, "avalanche draw data preserves visibility and chat text", failures)
	var collision_row: Dictionary = fake.hit_fx[0] as Dictionary
	collision_row["pos"] = fake.player_pos
	collision_row["vel"] = Vector2.ZERO
	collision_row["nextHitAt"] = 0.0
	for row_index in range(1, fake.hit_fx.size()):
		(fake.hit_fx[row_index] as Dictionary)["nextHitAt"] = INF
	fake.difficulty_runtime["elapsedSeconds"] = 60.0
	HardMode.update_comment_avalanche_for_target(fake, 0.01, avalanche_rng)
	avalanche_state = fake.difficulty_runtime.get("commentAvalanche", {}) as Dictionary
	_check(float(avalanche_state.get("knockbackRemaining", 0.0)) > 0.0 and Vector2(avalanche_state.get("knockbackVelocity", Vector2.ZERO)).length() >= 300.0, "avalanche collision starts persistent player knockback", failures)
	fake.hit_fx.pop_back()
	avalanche_state["nextSpawnAt"] = 0.0
	HardMode.update_comment_avalanche_for_target(fake, 0.1, avalanche_rng)
	avalanche_state = fake.difficulty_runtime.get("commentAvalanche", {}) as Dictionary
	_check(fake.hit_fx.size() == 16 and int(avalanche_state.get("totalSpawned", 0)) > 16, "avalanche replenishes comments throughout its duration", failures)
	HardMode.clear_hard_comment_events_for_target(fake, "test_cleanup")
	_check((fake.difficulty_runtime.get("commentAvalanche", {}) as Dictionary).is_empty() and fake.hit_fx.is_empty() and not DangerEvent.is_active(fake.difficulty_runtime, "stage_major_event"), "avalanche cleanup removes only its rows", failures)
	var boss_window_runtime := HardMode.build_runtime("hard", false, "zatsudan", source, {})
	var boss_window_target := FakeTarget.new()
	boss_window_target.difficulty_runtime = boss_window_runtime
	boss_window_target.elapsed = 44.9
	var early_boss_comment := {"id": "summon_boss", "effectType": "summon_boss", "riskLevel": 4, "minTime": 0.0, "maxTime": 180.0}
	_check(not bool(HardMode.comment_evaluation(early_boss_comment, boss_window_runtime, 44.9, boss_window_target).get("allowed", false)), "hard summon boss before window", failures)
	_check(bool(HardMode.comment_evaluation(early_boss_comment, boss_window_runtime, 45.0, boss_window_target).get("allowed", false)), "hard summon boss at window", failures)
	_check(bool(HardMode.comment_evaluation(early_boss_comment, boss_window_runtime, 104.9, boss_window_target).get("allowed", false)), "hard summon boss before auto boundary", failures)
	_check(not bool(HardMode.comment_evaluation(early_boss_comment, boss_window_runtime, 105.0, boss_window_target).get("allowed", false)), "hard summon boss at auto boundary", failures)
	var relay_boss_runtime := HardMode.build_runtime("hard", true, "zatsudan", source, {"segmentDuration": 120.0})
	var relay_boss_target := FakeTarget.new()
	relay_boss_target.difficulty_runtime = relay_boss_runtime
	relay_boss_target.relay_mode = true
	_check(not bool(HardMode.comment_evaluation(early_boss_comment, relay_boss_runtime, 60.0, relay_boss_target).get("allowed", false)), "relay intermediate summon boss blocked", failures)

	var frame_comments := [
		{"id": "safe_default", "riskLevel": 1, "multiplier": 1.0, "minTime": 0.0, "tags": ["default"]},
		{"id": "safe_default_two", "riskLevel": 2, "multiplier": 1.1, "minTime": 0.0, "tags": ["default"]},
		{"id": "safe_default_three", "riskLevel": 3, "multiplier": 1.25, "minTime": 0.0, "tags": ["default"]},
		{"id": "drawing_too_much_paint", "riskLevel": 2, "multiplier": 2.0, "minTime": 0.0, "tags": ["drawing"]},
		{"id": "partner_take_over", "riskLevel": 2, "multiplier": 2.0, "minTime": 0.0, "tags": ["collab"]},
		{"id": "song_only", "riskLevel": 2, "multiplier": 2.0, "minTime": 0.0, "tags": ["song"]}
	]
	var zatsudan_frame := {"id": "zatsudan", "commentPoolTags": ["default", "zatsudan"]}
	var drawing_frame := {"id": "drawing", "commentPoolTags": ["default", "drawing"]}
	var collab_frame := {"id": "collab", "commentPoolTags": ["default", "collab"]}
	var zatsudan_filtered := Comment.comments_allowed_for_frame(zatsudan_frame, frame_comments)
	var drawing_filtered := Comment.comments_allowed_for_frame(drawing_frame, frame_comments)
	var collab_filtered := Comment.comments_allowed_for_frame(collab_frame, frame_comments)
	_check(zatsudan_filtered.size() == 3 and String((zatsudan_filtered[0] as Dictionary).get("id")) == "safe_default", "zatsudan frame filter", failures)
	_check(drawing_filtered.size() == 4 and _contains_id(drawing_filtered, "drawing_too_much_paint") and not _contains_id(drawing_filtered, "partner_take_over"), "drawing frame filter", failures)
	_check(collab_filtered.size() == 4 and _contains_id(collab_filtered, "partner_take_over") and not _contains_id(collab_filtered, "drawing_too_much_paint"), "collab frame filter", failures)
	fake.current_stream_frame = zatsudan_frame
	fake.elapsed = 60.0
	fake.last_comment_id = "safe_default"
	fake.recent_comment_categories = ["default"]
	var offer := Comment.build_offer_for_target(fake, frame_comments, RandomNumberGenerator.new())
	_check(offer.size() == 3, "hard offer fills three cards after last/recent history", failures)
	_check(_offer_ids_are_unique(offer), "hard offer never duplicates a choice id", failures)
	for item in offer:
		_check(item is Dictionary and not String((item as Dictionary).get("id", "")).is_empty(), "hard offer cards are valid", failures)
	for item in offer:
		_check(String((item as Dictionary).get("id", "")) != "drawing_too_much_paint", "hard offer keeps drawing out of zatsudan", failures)
		_check(String((item as Dictionary).get("id", "")) != "partner_take_over", "hard offer keeps collab out of zatsudan", failures)
	for i in range(mini(3, offer.size())):
		_check(String((offer[i] as Dictionary).get("id", "")) != "do_everything", "do everything is not in regular hard slots", failures)
	if offer.size() == 4:
		_check(String((offer[3] as Dictionary).get("id", "")) == "do_everything", "do everything is fourth card only", failures)
	var hard_only_count := 0
	var danger4_count := 0
	for item in offer:
		if bool((item as Dictionary).get("hardOnly", false)):
			hard_only_count += 1
		if int((item as Dictionary).get("riskLevel", 1)) >= 4:
			danger4_count += 1
	_check(hard_only_count <= 1 and danger4_count <= 1, "hard offer danger caps", failures)
	fake.difficulty_runtime = HardMode.build_runtime("normal", false, "zatsudan", source, {})
	fake.run_difficulty_id = "normal"
	fake.relay_mode = false
	var normal_offer := Comment.build_offer_for_target(fake, frame_comments, RandomNumberGenerator.new())
	_check(_offer_ids_are_unique(normal_offer), "normal offer never duplicates a choice id", failures)
	for item in normal_offer:
		_check(String((item as Dictionary).get("id", "")) != "drawing_too_much_paint", "normal offer keeps drawing out of zatsudan", failures)
		_check(String((item as Dictionary).get("id", "")) != "partner_take_over", "normal offer keeps collab out of zatsudan", failures)
	fake.difficulty_runtime = HardMode.build_runtime("hard", true, "zatsudan", source, {"segmentDuration": 120.0})
	fake.run_difficulty_id = "hard"
	fake.relay_mode = true
	for relay_frame in [zatsudan_frame, {"id": "gameplay", "commentPoolTags": ["default", "gameplay"]}, {"id": "singing", "commentPoolTags": ["default", "song", "singing"]}, drawing_frame, collab_frame]:
		fake.current_stream_frame = relay_frame
		var relay_offer := Comment.build_offer_for_target(fake, frame_comments, RandomNumberGenerator.new())
		_check(relay_offer.size() == 3, "hard relay offer always has three cards", failures)
		_check(_offer_ids_are_unique(relay_offer), "hard relay offer never duplicates a choice id", failures)
		var allowed_tags: Array = relay_frame.get("commentPoolTags", []) as Array
		for item in relay_offer:
			for raw_tag in (item as Dictionary).get("tags", ["default"]) as Array:
				_check(allowed_tags.has(raw_tag), "relay offer follows current frame tags", failures)

	var gameplay_wave_target := FakeTarget.new()
	gameplay_wave_target.current_stream_frame_id = "gameplay"
	gameplay_wave_target.effect_walls = []
	var gameplay_arena := Rect2(Vector2(20.0, 120.0), Vector2(2200.0, 1500.0))
	var gameplay_side_pair_pos := Vector2(gameplay_arena.get_center().x, gameplay_arena.get_center().y + 570.0)
	var resolved_wave_pos := Enemy.resolve_pattern_spawn_position_for_target(gameplay_wave_target, gameplay_arena, RandomNumberGenerator.new(), gameplay_side_pair_pos, 24.0)
	_check(resolved_wave_pos != Vector2.INF, "gameplay hard wave finds an accessible spawn position", failures)
	for wall_value in DrawData.static_wall_rects_for_target(gameplay_wave_target):
		_check(not (wall_value as Rect2).grow(48.0).has_point(resolved_wave_pos), "gameplay hard wave does not spawn beyond the outer wall", failures)

	var danger_runtime := {"dangerCategories": {}}
	_check(DangerEvent.begin(danger_runtime, "boss_major_attack", "boss", 100), "danger begin", failures)
	_check(not DangerEvent.can_start(danger_runtime, "collab_challenge", 60), "danger priority conflict", failures)
	DangerEvent.end(danger_runtime, "boss_major_attack", "boss")
	_check(DangerEvent.can_start(danger_runtime, "collab_challenge", 60), "danger release", failures)
	var symmetric_danger := {"dangerCategories": {}}
	_check(DangerEvent.begin(symmetric_danger, "screen_restriction", "screen", 100), "danger category begin", failures)
	_check(not DangerEvent.begin(symmetric_danger, "surround", "wave", 10), "danger conflict is symmetric", failures)
	DangerEvent.clear(symmetric_danger)
	_check(DangerEvent.begin(symmetric_danger, "high_density_wave", "wave", 10), "danger alias begin", failures)
	_check(DangerEvent.is_active(symmetric_danger, "high_density"), "danger alias normalized", failures)
	var clear_fake := FakeTarget.new()
	var clear_hype_before := clear_fake.gift_hype
	var clear_result := Modifier.clear_state_for_target(clear_fake, true)
	_check(not bool(clear_result.get("clearBonus", true)), "forced clear suppresses completion bonus", failures)
	_check(clear_fake.gift_hype == clear_hype_before, "forced clear does not grant gift hype", failures)
	_check(clear_fake.current_comment == "なし" and clear_fake.current_death_text == "発動中の指示コメなし", "forced clear resets HUD text", failures)
	_check(clear_fake.active_effects.is_empty() and clear_fake.active_effect_rates.is_empty() and clear_fake.active_sub_comment_ids.is_empty(), "forced clear removes modifier arrays", failures)
	_check(clear_fake.effect_walls.is_empty() and clear_fake.effect_pits.is_empty() and clear_fake.last_comment_id == "" and clear_fake.recent_comment_categories.is_empty(), "forced clear removes instruction-owned state", failures)
	_check(is_zero_approx(clear_fake.effect_timer) and is_equal_approx(clear_fake.active_comment_score_rate, 1.0) and is_equal_approx(clear_fake.multiplier, 1.0), "forced clear resets timers and multiplier", failures)

	if failures.is_empty():
		print("hard mode tests passed")
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error(failure)
		get_tree().quit(1)

func _check(condition: bool, message: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(message)

func fake_for_exp(runtime: Dictionary, failures: Array[String]) -> void:
	var target := FakeTarget.new()
	target.difficulty_runtime = runtime
	var result := Exp.drop_from_enemy_for_target(target, {"pos": Vector2.ZERO, "baseExp": 10.0})
	_check(int(result.get("generatedExp", 0)) == 12 and int(target.exp_orbs[0].get("value", 0)) == 12, "hard exp is applied once at drop", failures)
	var normal_target := FakeTarget.new()
	normal_target.difficulty_runtime = HardMode.build_runtime("normal", false, "zatsudan", {"modes": {"normal": {}, "hard": {}}}, {})
	var normal_result := Exp.drop_from_enemy_for_target(normal_target, {"pos": Vector2.ZERO, "baseExp": 10.0})
	_check(int(normal_result.get("generatedExp", 0)) == 10, "normal exp remains unchanged", failures)
	var disabled := Exp.reward_config_for_enemy({"rewardConfig": {"expEnabled": false}, "baseExp": 10.0})
	_check(not bool(disabled.get("expEnabled", true)), "disabled exp does not get minimum one", failures)

func _contains_id(items: Array, id: String) -> bool:
	for item in items:
		if String((item as Dictionary).get("id", "")) == id:
			return true
	return false

func _offer_ids_are_unique(items: Array) -> bool:
	var ids: Dictionary = {}
	for item in items:
		if not item is Dictionary:
			return false
		var id := String((item as Dictionary).get("id", ""))
		if id.is_empty() or ids.has(id):
			return false
		ids[id] = true
	return true
