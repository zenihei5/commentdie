class_name HardModeSystem
extends RefCounted

const DangerEventSystemScript := preload("res://scripts/systems/danger_event_system.gd")
const ChatSystemScript := preload("res://scripts/systems/chat_system.gd")

## HARD combat runtime. The system is intentionally data-first: callers keep
## one normalized runtime dictionary for a run and use these helpers instead
## of branching on difficulty in every combat system.

const NORMAL := "normal"
const HARD := "hard"
const EXPERT := "expert"
const SINGLE := "single"
const RELAY_SECTION := "relaySection"
const RELAY_FINAL_BOSS := "relayFinalBoss"

const STANDARD_STAGE_IDS: Array[String] = ["zatsudan", "gameplay", "singing", "drawing", "collab"]

const SPAWN_PRIORITY := {
	"boss": 100,
	"boss_summon": 90,
	"comment_required": 80,
	"stage_gimmick": 70,
	"support_enemy": 60,
	"hard_wave": 55,
	"normal_wave": 50,
	"extra_swarm": 10
}

const CANONICAL_COMBAT_TYPES: Array[String] = ["swarm", "standard", "fast", "tank", "ranged", "support", "special"]
const HARD_ONLY_TARGET_RATE := 0.25
const HARD_COMMENT_DANGER_SCORE_RATES := {1: 1.00, 2: 1.10, 3: 1.25, 4: 1.45, 5: 1.55}
const COMMENT_CATEGORY_COOLDOWN_CYCLES := {"compound": 2, "stage_major_event": 2, "visibility": 1}
const COMMENT_FORBIDDEN_IN_REGULAR_HARD_SPECIAL := [
	"hard_overclock",
	"hard_pressure_wave",
	"talk_comment_avalanche",
	"hard_reignition_boss",
	"summon_boss",
	"game_genre_mix"
]

static func default_config() -> Dictionary:
	return {
		"implemented": true,
		"combatModifiersImplemented": true,
		"instructionCommentsImplemented": true,
		"enemy": {
			"hpRate": 1.20,
			"attackRate": 1.10,
			"moveSpeedRate": 1.08,
			"projectileSpeedRate": 1.10,
			"attackIntervalRate": 0.90,
			"activeEnemyLimitRate": 1.30
		},
		"experienceRate": 1.20,
		"bossBattleSpawnRate": 0.65,
		"collabChallengeSpawnRate": 0.50,
		"performanceSafetyRate": 1.0,
		"hardWaveSelectionRates": {"beforeProgress": 0.25, "middleProgress": 0.60, "earlyRate": 0.15, "middleRate": 0.25, "lateRate": 0.35, "bossRate": 0.30},
		"enemyFinalRates": {
			"swarm": {"hpRate": 1.10, "attackRate": 1.05, "moveSpeedRate": 1.10, "projectileSpeedRate": 1.10, "attackIntervalRate": 0.95},
			"standard": {"hpRate": 1.20, "attackRate": 1.10, "moveSpeedRate": 1.08, "projectileSpeedRate": 1.10, "attackIntervalRate": 0.90},
			"fast": {"hpRate": 1.10, "attackRate": 1.05, "moveSpeedRate": 1.15, "projectileSpeedRate": 1.10, "attackIntervalRate": 0.90},
			"tank": {"hpRate": 1.30, "attackRate": 1.10, "moveSpeedRate": 1.00, "projectileSpeedRate": 1.10, "attackIntervalRate": 0.95},
			"ranged": {"hpRate": 1.15, "attackRate": 1.10, "moveSpeedRate": 1.05, "projectileSpeedRate": 1.10, "attackIntervalRate": 0.90},
			"support": {"hpRate": 1.15, "attackRate": 1.00, "moveSpeedRate": 1.05, "projectileSpeedRate": 1.10, "attackIntervalRate": 0.90},
			"special": {"hpRate": 1.20, "attackRate": 1.10, "moveSpeedRate": 1.08, "projectileSpeedRate": 1.10, "attackIntervalRate": 0.90}
		},
		"singleSpawnPhases": [
			{"start": 0.0, "end": 30.0, "rate": 1.10},
			{"start": 30.0, "end": 90.0, "rate": 1.25},
			{"start": 90.0, "end": 150.0, "rate": 1.50},
			{"start": 150.0, "end": 180.0, "rate": 1.75}
		],
		"relayStageSpawnRates": {"zatsudan": 0.90, "gameplay": 0.95, "singing": 1.00, "drawing": 1.05, "collab": 1.10},
		"relayTimePhases": [
			{"start": 0.0, "end": 20.0, "rate": 1.00},
			{"start": 20.0, "end": 60.0, "rate": 1.20},
			{"start": 60.0, "end": 100.0, "rate": 1.45},
			{"start": 100.0, "end": 120.0, "rate": 1.70}
		],
		"score": {"baseRate": 1.20, "climaxRate": 1.20, "maxTemporaryRate": 2.00},
		"comment": {"poolId": "hard", "selectionSeconds": 10.0, "intervalSeconds": 15.0, "timeoutAutoSelect": true},
		"commentComposer": {
			"hardOnlyTargetRate": 0.25,
			"categoryCooldownCycles": {"compound": 2, "stage_major_event": 2, "visibility": 1},
			"dangerScoreRates": {"1": 1.00, "2": 1.10, "3": 1.25, "4": 1.45, "5": 1.55},
			"doEverythingChance": 0.05,
			"doEverythingMaxUses": 1
		},
		"commentCategories": {
			"reverse_control": ["control_restriction"], "no_dash": ["control_restriction"], "attack_right_only": ["control_restriction"], "no_stop": ["control_restriction"], "no_brake": ["control_restriction"],
			"hide_hp": ["visibility"], "comment_barrage": ["visibility"], "camera_zoom": ["visibility"],
			"enemy_speed_up": ["enemy_speed"], "enemy_spawn_up": ["enemy_spawn"], "split_enemy": ["enemy_spawn", "high_density"],
			"summon_boss": ["boss"], "hard_reignition_boss": ["boss"],
			"genre_change": ["stage_major_event", "forced_movement", "compound"], "force_bullet_hell": ["stage_major_event", "forced_movement", "compound"], "force_race": ["stage_major_event", "forced_movement", "compound"], "force_horror": ["stage_major_event", "forced_movement", "compound"],
			"hard_overclock": ["enemy_attack", "projectile_pressure", "compound"], "hard_pressure_wave": ["hard_wave", "stage_major_event", "high_density"], "talk_comment_avalanche": ["stage_major_event", "movement_hazard"], "game_genre_mix": ["stage_major_event", "forced_movement", "compound"]
		},
		"climax": {"singleStartRemainingSeconds": 30.0, "relayStartRemainingSeconds": 20.0},
		"boss": {
			"hpRate": 1.30,
			"attackRate": 1.10,
			"moveSpeedRate": 1.05,
			"actionIntervalRate": 0.85,
			"summonCountRate": 1.25,
			"projectileSpeedRate": 1.00,
			"phase2HpRate": 0.50,
			"transitionSeconds": 1.50,
			"firstBossScoreRate": 2.00,
			"reignitionScoreRate": 3.00,
			"hardActions": {
				"zatsudan": "sticky_maro_floor",
				"gameplay": "bugged_genre_rush",
				"singing": "pitch_wave",
				"drawing": "red_pen_review_line",
				"collab": "collab_crusher_rush"
			},
			"bossIds": {
				"zatsudan": "boss_kuso_maro_king",
				"gameplay": "bugged_final_boss",
				"singing": "pitch_police_chief",
				"drawing": "red_pen_review_chief",
				"collab": "collab_crusher"
			}
		},
		"finalBoss": {
			"hpRate": 1.35,
			"attackRate": 1.10,
			"moveSpeedRate": 1.08,
			"actionIntervalRate": 0.85,
			"summonCountRate": 1.40,
			"projectileSpeedRate": 1.10,
			"contactDamageEnabled": true,
			"phaseThresholds": [0.70, 0.30, 0.00],
			"phaseCount": 3,
			"supportChance": 0.25,
			"summonRewards": {"scoreEnabled": false, "scoreRate": 0.0, "expEnabled": false, "expRate": 0.0, "starDropEnabled": true, "healDropEnabled": true, "healDropRate": 0.10}
		},
		"hardWaves": _default_hard_waves(),
		"pressureWaveProfiles": _default_pressure_wave_profiles(),
		"relayStageModifiers": {
			"zatsudan": {"commentAvalancheMax": 1, "warningSeconds": 1.5},
			"gameplay": {"guaranteedMainEventCount": 1, "eventEnemySpawnRate": 0.55, "mixedEventEnemySpawnRate": 0.50},
			"singing": {"noteCountForCallWave": 8, "tensionDropGraceSeconds": 10.0, "warningSeconds": 2.0, "startProtectionSeconds": 8.0},
			"drawing": {"areaMoveIntervalSeconds": 20.0, "climaxAreaMoveIntervalSeconds": 15.0, "firstAreaMinimumSeconds": 15.0, "paintingTargetMode": "relay_120_seconds"},
			"collab": {"guaranteedChallengeCount": 2, "climaxAdditionalChallengeMax": 1, "minimumIntervalSeconds": 15.0, "challengeTimeScale": 0.50, "challengeSpawnRate": 0.50, "stopNewChallengeRemainingSeconds": 5.0}
		},
		"commentOverrides": {
			"banana_floor": {"params": {"slipRate": 1.10}},
			"no_brake": {"params": {"inertiaRate": 1.15}},
			"enemy_speed_up": {"scoreRate": 1.25, "riskLevel": 3, "params": {"enemySpeedRate": 1.15}},
			"enemy_spawn_up": {"scoreRate": 1.25, "riskLevel": 3, "params": {"enemySpawnRate": 1.20, "enemySpawnCountRate": 2.0}},
			"split_enemy": {"params": {"splitProbabilityRate": 1.20, "splitProbabilityCap": 1.0}},
			"short_range": {"scoreRate": 1.10, "riskLevel": 2},
			"comment_barrage": {"params": {"barrageCountRate": 1.20}},
			"temp_walls": {"params": {"wallCountAdd": 1}},
			"damage_pits": {"params": {"pitCountAdd": 1, "activeCap": 8}},
			"kamiyoyaku": {"riskLevel": 4, "params": {"enemySpawnAmountRate": 1.20}},
			"takeback": {"riskLevel": 4},
			"song_tempo_up": {"params": {"enemySpawnAmountRate": 1.20}},
			"song_force_chorus": {"params": {}},
			"song_mic_howling": {"params": {"waveIntervalRate": 0.90}},
			"song_lighting_mistake": {"params": {"badLightMoveSpeedRate": 1.10}},
			"song_lyrics_lost": {"params": {"minimumSpawnDistanceRate": 1.15}},
			"drawing_fast_dry": {"params": {"trailLifetime": 5.0}},
			"drawing_too_much_paint": {"params": {"paintCostMultiplier": 1.75}},
			"drawing_more_corrections": {"params": {"correctionBurst": 3}},
			"drawing_spilled_bucket": {"params": {"spillCount": 8}},
			"partner_take_over": {"params": {"playerWeaponDamageMultiplier": 0.40, "partnerDamageMultiplier": 2.0, "partnerAttackIntervalMultiplier": 0.70}},
			"keep_sync": {"params": {"starLossCooldown": 1.0}},
			"out_of_sync": {"params": {"interferenceIntervalRate": 0.85}},
			"fast_collab_pass": {"params": {"passDuration": 3.0, "spawnDistanceRate": 1.15}},
			"summon_boss": {"scoreRate": 1.45, "riskLevel": 4, "minTime": 45.0, "maxTime": 105.0}
		}
	}

static func normal_config() -> Dictionary:
	return {
		"implemented": true,
		"enemy": {"hpRate": 1.0, "attackRate": 1.0, "moveSpeedRate": 1.0, "projectileSpeedRate": 1.0, "attackIntervalRate": 1.0, "activeEnemyLimitRate": 1.0},
		"experienceRate": 1.0,
		"performanceSafetyRate": 1.0,
		"score": {"baseRate": 1.0, "climaxRate": 1.0, "maxTemporaryRate": 999.0},
		"comment": {"poolId": "normal", "selectionSeconds": 10.0, "intervalSeconds": 15.0, "timeoutAutoSelect": true},
		"climax": {"singleStartRemainingSeconds": 0.0, "relayStartRemainingSeconds": 0.0}
	}

static func _default_hard_waves() -> Array:
	# Fallback data is intentionally small. Project data can replace/extend it;
	# enemy IDs remain the project's real IDs and are never invented here.
	return [
		{"id": "hard_surround", "difficulty": HARD, "stageId": "zatsudan", "playModes": [SINGLE, RELAY_SECTION], "minElapsedSeconds": 20.0, "maxElapsedSeconds": 180.0, "minimumPlayerLevel": 1, "maximumPlayerLevel": 999, "cooldownSeconds": 25.0, "maximumUsesPerRun": 3, "activeEnemyLimitReserve": 3, "weight": 1.0, "dangerCategories": ["surround"], "blockedDangerCategories": ["forced_movement", "screen_restriction"], "groups": [{"enemyId": "troll", "count": 3, "spawnPattern": "outer_arc"}]},
		{"id": "hard_ranged_pressure", "difficulty": HARD, "stageId": "gameplay", "playModes": [SINGLE, RELAY_SECTION], "minElapsedSeconds": 30.0, "maxElapsedSeconds": 180.0, "minimumPlayerLevel": 2, "maximumPlayerLevel": 999, "cooldownSeconds": 30.0, "maximumUsesPerRun": 3, "activeEnemyLimitReserve": 2, "weight": 1.0, "dangerCategories": ["ranged_pressure"], "blockedDangerCategories": ["screen_restriction"], "groups": [{"enemyId": "shooter", "count": 2, "spawnPattern": "side_pair"}, {"enemyId": "troll", "count": 2, "spawnPattern": "player_front"}]},
		{"id": "hard_fast_mix", "difficulty": HARD, "stageId": "singing", "playModes": [SINGLE, RELAY_SECTION], "minElapsedSeconds": 45.0, "maxElapsedSeconds": 180.0, "minimumPlayerLevel": 3, "maximumPlayerLevel": 999, "cooldownSeconds": 35.0, "maximumUsesPerRun": 3, "activeEnemyLimitReserve": 3, "weight": 1.0, "dangerCategories": ["high_speed"], "blockedDangerCategories": ["collab_challenge"], "groups": [{"enemyId": "fast", "count": 3, "spawnPattern": "four_directions"}, {"enemyId": "song_noise_comment", "count": 1, "spawnPattern": "outer_ring"}]},
		{"id": "hard_tank_guard", "difficulty": HARD, "stageId": "drawing", "playModes": [SINGLE, RELAY_SECTION], "minElapsedSeconds": 60.0, "maxElapsedSeconds": 180.0, "minimumPlayerLevel": 4, "maximumPlayerLevel": 999, "cooldownSeconds": 40.0, "maximumUsesPerRun": 2, "activeEnemyLimitReserve": 3, "weight": 1.0, "dangerCategories": ["high_density"], "blockedDangerCategories": ["boss_major_attack", "collab_challenge"], "groups": [{"enemyId": "bucket_fill_slime", "count": 2, "spawnPattern": "side_pair"}, {"enemyId": "drawing_fix_note", "count": 2, "spawnPattern": "outer_arc"}]},
		{"id": "hard_climax_pressure", "difficulty": HARD, "stageId": "collab", "playModes": [SINGLE, RELAY_SECTION], "minElapsedSeconds": 100.0, "maxElapsedSeconds": 180.0, "minimumPlayerLevel": 5, "maximumPlayerLevel": 999, "cooldownSeconds": 45.0, "maximumUsesPerRun": 1, "activeEnemyLimitReserve": 4, "weight": 1.0, "dangerCategories": ["high_density", "ranged_pressure"], "blockedDangerCategories": ["boss_major_attack", "collab_challenge", "screen_restriction"], "groups": [{"enemyId": "collab_comparison_troll", "count": 2, "spawnPattern": "outer_arc"}, {"enemyId": "collab_messenger_pigeon", "count": 2, "spawnPattern": "side_pair"}]}
	]

static func _default_pressure_wave_profiles() -> Dictionary:
	return {
		"zatsudan": {"groups": [{"enemyId": "fast", "count": 2, "spawnPattern": "left_right"}, {"enemyId": "shooter", "count": 1, "spawnPattern": "player_back"}]},
		"gameplay": {"groups": [{"enemyId": "troll", "count": 2, "spawnPattern": "player_front"}, {"enemyId": "shooter", "count": 2, "spawnPattern": "left_right"}]},
		"singing": {"groups": [{"enemyId": "fast_call_fan", "count": 3, "spawnPattern": "note_route_cross"}, {"enemyId": "song_noise_comment", "count": 1, "spawnPattern": "outer_ring"}]},
		"drawing": {"groups": [{"enemyId": "drawing_fix_note", "count": 2, "spawnPattern": "paint_outer"}, {"enemyId": "red_pen_teacher", "count": 1, "spawnPattern": "outer_arc"}]},
		"collab": {"groups": [{"enemyId": "collab_division_noise", "count": 2, "spawnPattern": "partner_sandwich"}, {"enemyId": "collab_comparison_troll", "count": 2, "spawnPattern": "left_right"}]}
	}

static func config_for(difficulty_id: String, source: Dictionary) -> Dictionary:
	var difficulty := normalize_difficulty(difficulty_id)
	var modes: Dictionary = source.get("modes", source) as Dictionary
	if difficulty == EXPERT:
		var hard_config := _deep_merge(default_config(), _dict(modes.get(HARD, {})))
		return _resolve_expert_config(hard_config, _dict(modes.get(EXPERT, {})))
	if difficulty == HARD:
		return _deep_merge(default_config(), _dict(modes.get(HARD, {})))
	return _deep_merge(normal_config(), _dict(modes.get(NORMAL, {})))

static func _resolve_expert_config(hard_config: Dictionary, expert_source: Dictionary) -> Dictionary:
	var resolved := _deep_merge(hard_config, expert_source)
	var enabled := bool(expert_source.get("implemented", false))
	resolved["implemented"] = enabled
	resolved["combatModifiersImplemented"] = bool(expert_source.get("combatModifiersImplemented", enabled))
	resolved["instructionCommentsImplemented"] = bool(expert_source.get("instructionCommentsImplemented", enabled))
	resolved["baseDifficulty"] = HARD
	resolved["inheritFrom"] = HARD
	var relative := _deep_merge(_default_expert_relative_modifiers(), _dict(expert_source.get("relativeModifiers", {})))
	var enemy_relative := _dict(relative.get("enemy", {}))
	resolved["enemy"] = _multiply_rate_dict(_dict(hard_config.get("enemy", {})), enemy_relative, ["hpRate", "attackRate", "moveSpeedRate", "attackIntervalRate", "projectileSpeedRate", "activeEnemyLimitRate"])
	var resolved_enemy_rates: Dictionary = {}
	var type_relative_map := _dict(relative.get("enemyFinalRates", {}))
	var hard_enemy_rates := _dict(hard_config.get("enemyFinalRates", {}))
	for combat_type in CANONICAL_COMBAT_TYPES:
		var type_id := String(combat_type)
		var hard_rates := _dict(hard_enemy_rates.get(type_id, hard_enemy_rates.get("standard", {})))
		var type_relative := _deep_merge(enemy_relative, _dict(type_relative_map.get(type_id, {})))
		resolved_enemy_rates[type_id] = _multiply_rate_dict(hard_rates, type_relative, ["hpRate", "attackRate", "moveSpeedRate", "attackIntervalRate", "projectileSpeedRate"])
	resolved["enemyFinalRates"] = resolved_enemy_rates
	var hard_boss := _dict(hard_config.get("boss", {}))
	var boss_relative := _dict(relative.get("boss", {}))
	resolved["boss"] = _multiply_rate_dict(hard_boss, boss_relative, ["hpRate", "attackRate", "moveSpeedRate", "actionIntervalRate", "summonCountRate", "projectileSpeedRate"])
	var hard_final_boss := _dict(hard_config.get("finalBoss", {}))
	var final_boss_relative := _dict(relative.get("finalBoss", {}))
	resolved["finalBoss"] = _multiply_rate_dict(hard_final_boss, final_boss_relative, ["hpRate", "attackRate", "moveSpeedRate", "actionIntervalRate", "summonCountRate", "projectileSpeedRate"])
	var spawn_relative := _dict(relative.get("spawnPressure", {}))
	resolved["expertSpawnPressurePhases"] = _array(spawn_relative.get("timePhases", [])).duplicate(true)
	resolved["expertRelaySectionRates"] = _array(spawn_relative.get("relaySectionRates", [])).duplicate(true)
	resolved["expertHardWaveSelectionRateMultiplier"] = float(spawn_relative.get("hardWaveSelectionRateMultiplier", 1.0))
	resolved["expertGroupCountRate"] = float(spawn_relative.get("groupCountRate", 1.0))
	var lead := _dict(relative.get("strongEnemySelection", {}))
	resolved["strongEnemySelectionLeadSeconds"] = maxf(0.0, float(lead.get("leadSeconds", 0.0)))
	resolved["strongEnemySelectionLeadStartSeconds"] = maxf(0.0, float(lead.get("leadStartSeconds", 0.0)))
	var comment_relative := _dict(relative.get("comment", {}))
	var composer := _dict(resolved.get("commentComposer", {})).duplicate(true)
	composer["hardOnlyTargetRate"] = clampf(float(comment_relative.get("hardOnlyTargetRate", composer.get("hardOnlyTargetRate", HARD_ONLY_TARGET_RATE))), 0.0, 1.0)
	resolved["commentComposer"] = composer
	var stage_profiles := _deep_merge(_default_expert_stage_profiles(), _dict(relative.get("stageProfiles", {})))
	resolved["expertStageProfiles"] = stage_profiles
	var stage_waves: Dictionary = {}
	for stage_id in STANDARD_STAGE_IDS:
		stage_waves[stage_id] = _array(_dict(stage_profiles.get(stage_id, {})).get("hardWaves", [])).duplicate(true)
	resolved["expertStageHardWaves"] = stage_waves
	# EXPERT inherits HARD's experience multiplier exactly. The explicit data
	# value is retained for inspection, but relative experience is the only
	# optional adjustment and defaults to 1.0.
	resolved["experienceRate"] = float(hard_config.get("experienceRate", 1.20)) * float(relative.get("experienceRate", 1.0))
	return resolved

static func _default_expert_relative_modifiers() -> Dictionary:
	return {
		"experienceRate": 1.0,
		"enemy": {"hpRate": 1.15, "attackRate": 1.10, "moveSpeedRate": 1.08, "attackIntervalRate": 0.92, "projectileSpeedRate": 1.10, "activeEnemyLimitRate": 1.0},
		"boss": {"hpRate": 1.20, "attackRate": 1.10, "moveSpeedRate": 1.0, "actionIntervalRate": 0.90, "summonCountRate": 1.20, "projectileSpeedRate": 1.10},
		"finalBoss": {"hpRate": 1.20, "attackRate": 1.10, "moveSpeedRate": 1.0, "actionIntervalRate": 0.90, "summonCountRate": 1.20, "projectileSpeedRate": 1.10},
		"spawnPressure": {"timePhases": [{"start": 0.0, "end": 60.0, "rate": 1.05}, {"start": 60.0, "end": 120.0, "rate": 1.12}, {"start": 120.0, "end": 180.0, "rate": 1.20}], "relaySectionRates": [1.0, 1.05, 1.08, 1.12, 1.15], "hardWaveSelectionRateMultiplier": 1.20, "groupCountRate": 1.15},
		"strongEnemySelection": {"leadSeconds": 15.0, "leadStartSeconds": 30.0},
		"comment": {"hardOnlyTargetRate": 0.35},
		"stageProfiles": _default_expert_stage_profiles()
	}

static func _default_expert_stage_profiles() -> Dictionary:
	var result: Dictionary = {}
	for stage_id in STANDARD_STAGE_IDS:
		result[stage_id] = {
			"single": {},
			"relaySection": {},
			"hardWaves": []
		}
	return result

static func _multiply_rate_dict(base: Dictionary, relative: Dictionary, keys: Array) -> Dictionary:
	var result := base.duplicate(true)
	for key in keys:
		var name := String(key)
		if relative.has(name):
			result[name] = float(base.get(name, 1.0)) * float(relative.get(name, 1.0))
	return result

static func normalize_difficulty(value: Variant) -> String:
	var id := String(value).strip_edges().to_lower()
	return id if id in [NORMAL, HARD, EXPERT] else NORMAL

static func normalize_stage(value: Variant) -> String:
	var id := String(value).strip_edges().to_lower()
	if id == "talk":
		return "zatsudan"
	if id == "game":
		return "gameplay"
	return id if id in STANDARD_STAGE_IDS else "zatsudan"

static func build_runtime(difficulty_id: String, relay_mode: bool, stage_id: String, source: Dictionary, relay_config: Dictionary, final_boss: bool = false, relay_segment_index: int = -1) -> Dictionary:
	var difficulty := normalize_difficulty(difficulty_id)
	var config := config_for(difficulty, source)
	var hard_config := config_for(HARD, source)
	var mode := RELAY_FINAL_BOSS if final_boss else (RELAY_SECTION if relay_mode else SINGLE)
	var normalized_stage := normalize_stage(stage_id)
	var segment_index := relay_segment_index
	if mode == RELAY_SECTION and segment_index < 0:
		segment_index = STANDARD_STAGE_IDS.find(normalized_stage)
	segment_index = clampi(segment_index, 0, 4) if mode == RELAY_SECTION else -1
	var duration := 180.0
	if mode == RELAY_SECTION:
		duration = float(relay_config.get("segmentDuration", 120.0))
	elif mode == RELAY_FINAL_BOSS:
		duration = INF
	else:
		duration = float(config.get("singleDurationSeconds", 180.0))
	return {
		"difficulty": difficulty,
		"playMode": mode,
		"stageId": normalized_stage,
		"relaySegmentIndex": segment_index,
		"durationSeconds": duration,
		"elapsedSeconds": 0.0,
		"remainingSeconds": duration,
		"difficultyConfig": config.duplicate(true),
		"difficultyHardConfig": hard_config.duplicate(true),
		"stageConfig": _dict(_dict(config.get("relayStageModifiers", {})).get(normalized_stage, {})).duplicate(true),
		"climax": {"active": false, "started": false, "startRemainingSeconds": 0.0},
		"bossState": {"firstBossSpawned": false, "firstBossDefeated": false, "reignitionOfferShown": false, "secondBossSpawned": false, "secondBossDefeated": false, "activeBossCount": 0, "firstBossSpawnElapsedSeconds": null, "reignitionSpawnElapsedSeconds": null, "firstBossFinalHp": 0.0, "firstBossId": ""},
		"pendingSpawn": {},
		"pendingCommentWave": {},
		"pendingPressureWave": {},
		"lastPressureWave": {},
		"commentAvalanche": {},
		"dangerCategories": {},
		"activeComment": {},
		"scoreContext": {"baseRate": float(_dict(config.get("score", {})).get("baseRate", 1.0)), "climaxRate": 1.0, "temporaryRate": 1.0},
		"hardOverlay": {"base": 1.0, "overlay": 1.0, "final": 1.0},
		"spawnBreakdown": {"base": 1.0, "stage": 1.0, "time": 1.0, "commonExpert": 1.0, "expertTime": 1.0, "section": 1.0, "stageFlavor": 1.0, "boss": 1.0, "event": 1.0, "comment": 1.0, "safety": 1.0, "final": 1.0},
		"stageEventActive": false,
		"performanceSafetyRate": float(config.get("performanceSafetyRate", 1.0)),
		"currentSpawnRate": 1.0,
		"lastHardWaveId": "",
		"usedHardWaveCounts": {},
		"pendingSpawnRequests": [],
		"requestSerial": 0,
		"totalEnemiesSpawned": 0,
		"totalEnemiesDefeated": 0,
		"currentWave": "",
		"hardWaveCooldowns": {},
		"commentOfferCycle": 0,
		"commentOfferHistory": [],
		"commentCategoryCooldowns": {},
		"commentCooldowns": {},
		"commentUseCounts": {},
		"commentDebugLast": {},
		"genreLastEventId": "",
		"genreScheduleInitialized": false,
		"expStats": {"generated": 0, "collected": 0, "uncollected": 0, "expired": 0, "discarded": 0},
		"runExpStats": {"generated": 0, "collected": 0, "uncollected": 0, "expired": 0, "discarded": 0}
	}

static func is_hard_runtime(runtime: Dictionary) -> bool:
	return String(runtime.get("difficulty", NORMAL)) == HARD and bool(_dict(runtime.get("difficultyConfig", {})).get("implemented", false))

static func is_hard_target(target: Node) -> bool:
	var value: Variant = target.get("difficulty_runtime")
	return value is Dictionary and is_hard_runtime(value as Dictionary)

static func is_high_difficulty_runtime(runtime: Dictionary) -> bool:
	var difficulty := normalize_difficulty(runtime.get("difficulty", NORMAL))
	if difficulty not in [HARD, EXPERT]:
		return false
	var config := _dict(runtime.get("difficultyConfig", {}))
	return bool(config.get("implemented", false)) and bool(config.get("combatModifiersImplemented", true))

static func is_expert_runtime(runtime: Dictionary) -> bool:
	return String(runtime.get("difficulty", NORMAL)) == EXPERT and is_high_difficulty_runtime(runtime)

static func is_high_difficulty_target(target: Node) -> bool:
	var value: Variant = target.get("difficulty_runtime")
	return value is Dictionary and is_high_difficulty_runtime(value as Dictionary)

static func is_expert_target(target: Node) -> bool:
	var value: Variant = target.get("difficulty_runtime")
	return value is Dictionary and is_expert_runtime(value as Dictionary)

## Returns the resolved EXPERT-only flavor for the current stage and play mode.
## NORMAL/HARD deliberately return an empty dictionary so callers can use the
## same API without adding difficulty branches at every subsystem boundary.
static func expert_stage_profile(runtime: Dictionary) -> Dictionary:
	if not is_expert_runtime(runtime):
		return {}
	var mode := String(runtime.get("playMode", SINGLE))
	if mode == RELAY_FINAL_BOSS:
		return {}
	var config: Dictionary = _dict(runtime.get("difficultyConfig", {}))
	var profiles: Dictionary = _dict(config.get("expertStageProfiles", {}))
	var stage_id := normalize_stage(runtime.get("stageId", "zatsudan"))
	var root: Dictionary = _dict(profiles.get(stage_id, {})).duplicate(true)
	var mode_id := RELAY_SECTION if mode == RELAY_SECTION else SINGLE
	return _deep_merge(root, _dict(root.get(mode_id, {})))

static func stage_profile_spawn_interval_rate(runtime: Dictionary) -> float:
	var profile := expert_stage_profile(runtime)
	return clampf(float(profile.get("spawnIntervalRate", 1.0)), 0.25, 2.0)

static func stage_profile_spawn_pressure_rate(runtime: Dictionary, elapsed: float) -> float:
	var profile := expert_stage_profile(runtime)
	if profile.is_empty():
		return 1.0
	var phases: Array = _array(profile.get("spawnPressurePhases", []))
	return maxf(0.25, _phase_rate(phases, elapsed, float(profile.get("spawnPressureRate", 1.0))))

static func stage_profile_event_interval_rate(runtime: Dictionary) -> float:
	var profile := expert_stage_profile(runtime)
	return clampf(float(profile.get("eventIntervalRate", 1.0)), 0.25, 1.0)

static func stage_profile_event_config(runtime: Dictionary, event_id: String) -> Dictionary:
	var profile := expert_stage_profile(runtime)
	return _dict(_dict(profile.get("events", {})).get(event_id, {}))

static func stage_profile_event_value(runtime: Dictionary, event_id: String, key: String, fallback: Variant = null) -> Variant:
	var event_config := stage_profile_event_config(runtime, event_id)
	return event_config.get(key, fallback)

static func stage_profile_paint_interval_rate(runtime: Dictionary, elapsed: float) -> float:
	var profile := expert_stage_profile(runtime)
	var start := float(profile.get("paintEventStartSeconds", INF))
	if elapsed < start:
		return 1.0
	return clampf(float(profile.get("paintEventIntervalRate", 1.0)), 0.25, 1.0)

static func stage_profile_enemy_picker_lead(runtime: Dictionary, elapsed: float) -> float:
	var profile := expert_stage_profile(runtime)
	if elapsed < float(profile.get("enemyPickerLeadStartSeconds", INF)):
		return 0.0
	return maxf(0.0, float(profile.get("enemyPickerLeadSeconds", 0.0)))

static func stage_profile_hard_wave_selection_rate(runtime: Dictionary) -> float:
	var profile := expert_stage_profile(runtime)
	return clampf(float(profile.get("hardWaveSelectionRate", 1.0)), 0.0, 2.0)

static func stage_profile_hard_wave_group_count_rate(runtime: Dictionary) -> float:
	var profile := expert_stage_profile(runtime)
	return clampf(float(profile.get("hardWaveGroupCountRate", 1.0)), 0.1, 2.0)

static func stage_profile_hard_wave_maximum_uses(runtime: Dictionary) -> int:
	var profile := expert_stage_profile(runtime)
	return int(profile.get("hardWaveMaximumUses", -1))

static func stage_profile_comment_weight(runtime: Dictionary, comment_id: String) -> float:
	var profile := expert_stage_profile(runtime)
	var weights: Dictionary = _dict(profile.get("commentWeightMultipliers", {}))
	return clampf(float(weights.get(comment_id, 1.0)), 0.1, 3.0)

static func stage_profile_comment_high_risk_limit(runtime: Dictionary) -> int:
	var profile := expert_stage_profile(runtime)
	return maxi(0, int(profile.get("stageBoostedHighRiskLimit", 1)))

static func stage_profile_comment_is_boosted(runtime: Dictionary, comment_id: String) -> bool:
	var profile := expert_stage_profile(runtime)
	return _dict(profile.get("commentWeightMultipliers", {})).has(comment_id) and stage_profile_comment_weight(runtime, comment_id) > 1.0

static func runtime_for_target(target: Node) -> Dictionary:
	var value: Variant = target.get("difficulty_runtime")
	return value as Dictionary if value is Dictionary else {}

static func begin_danger_for_target(target: Node, category: String, owner: String = "", priority: int = 0) -> bool:
	var runtime := runtime_for_target(target)
	return false if runtime.is_empty() else DangerEventSystemScript.begin(runtime, category, owner, priority)

static func end_danger_for_target(target: Node, category: String, owner: String = "") -> void:
	var runtime := runtime_for_target(target)
	if not runtime.is_empty():
		DangerEventSystemScript.end(runtime, category, owner)

static func clear_dangers_for_target(target: Node) -> void:
	var runtime := runtime_for_target(target)
	if not runtime.is_empty():
		DangerEventSystemScript.clear(runtime)

static func advance_runtime_for_target(target: Node, elapsed: float, remaining: float, _delta: float, active_boss_count: int, boss_blocked: bool = false) -> Dictionary:
	var runtime := runtime_for_target(target)
	if runtime.is_empty():
		return {}
	runtime["elapsedSeconds"] = elapsed
	runtime["remainingSeconds"] = remaining
	var result := {"climaxStarted": false, "requestAutoBoss": false}
	if is_high_difficulty_runtime(runtime):
		var mode := String(runtime.get("playMode", SINGLE))
		if mode != RELAY_FINAL_BOSS:
			var threshold := float(_dict(runtime.get("difficultyConfig", {})).get("climax", {}).get("singleStartRemainingSeconds", 30.0))
			if mode == RELAY_SECTION:
				threshold = float(_dict(runtime.get("difficultyConfig", {})).get("climax", {}).get("relayStartRemainingSeconds", 20.0))
			var climax: Dictionary = runtime.get("climax", {}) as Dictionary
			climax["startRemainingSeconds"] = threshold
			if not bool(climax.get("active", false)) and remaining <= threshold:
				climax["active"] = true
				climax["started"] = true
				result["climaxStarted"] = true
			runtime["climax"] = climax
		if mode == SINGLE and elapsed >= 105.0:
			var boss_state: Dictionary = runtime.get("bossState", {}) as Dictionary
			var pending: Dictionary = runtime.get("pendingSpawn", {}) as Dictionary
			if not bool(boss_state.get("firstBossSpawned", false)) and active_boss_count <= 0 and pending.is_empty():
				runtime["pendingSpawn"] = {"type": "firstHardBoss", "requestedAt": elapsed, "source": "auto"}
				result["requestAutoBoss"] = not boss_blocked
			elif not bool(boss_state.get("firstBossSpawned", false)) and active_boss_count <= 0 and not pending.is_empty() and not boss_blocked:
				result["requestAutoBoss"] = true
	return result

static func consume_pending_spawn(target: Node) -> Dictionary:
	var runtime := runtime_for_target(target)
	var pending: Dictionary = runtime.get("pendingSpawn", {}) as Dictionary
	if pending.is_empty():
		return {}
	runtime["pendingSpawn"] = {}
	return pending.duplicate(true)

static func mark_boss_spawned(target: Node, role: String, elapsed: float) -> void:
	var runtime := runtime_for_target(target)
	if runtime.is_empty():
		return
	var state: Dictionary = runtime.get("bossState", {}) as Dictionary
	if role == "reignition":
		state["secondBossSpawned"] = true
		state["reignitionSpawnElapsedSeconds"] = elapsed
	else:
		state["firstBossSpawned"] = true
		state["firstBossSpawnElapsedSeconds"] = elapsed
	state["activeBossCount"] = 1
	runtime["bossState"] = state

static func mark_boss_defeated(target: Node, role: String) -> void:
	var runtime := runtime_for_target(target)
	if runtime.is_empty():
		return
	var state: Dictionary = runtime.get("bossState", {}) as Dictionary
	if role == "reignition":
		state["secondBossDefeated"] = true
	else:
		state["firstBossDefeated"] = true
	state["activeBossCount"] = 0
	runtime["bossState"] = state

static func can_offer_early_boss(runtime: Dictionary, elapsed: float, active_boss_count: int, blocking: bool) -> bool:
	if not is_high_difficulty_runtime(runtime) or String(runtime.get("playMode")) != SINGLE:
		return false
	var state: Dictionary = runtime.get("bossState", {}) as Dictionary
	return elapsed >= 45.0 and elapsed < 105.0 and not bool(state.get("firstBossSpawned", false)) and active_boss_count == 0 and not blocking

static func can_offer_reignition(runtime: Dictionary, remaining: float, active_boss_count: int) -> bool:
	if not is_high_difficulty_runtime(runtime) or String(runtime.get("playMode")) != SINGLE:
		return false
	var state: Dictionary = runtime.get("bossState", {}) as Dictionary
	return bool(state.get("firstBossDefeated", false)) and not bool(state.get("reignitionOfferShown", false)) and not bool(state.get("secondBossSpawned", false)) and remaining >= 45.0 and active_boss_count == 0

static func mark_reignition_offer_shown(runtime: Dictionary) -> void:
	var state: Dictionary = runtime.get("bossState", {}) as Dictionary
	state["reignitionOfferShown"] = true
	runtime["bossState"] = state

static func boss_role_for_target(target: Node) -> String:
	var value := String(target.get("hard_boss_role"))
	return value if not value.is_empty() else "firstHardBoss"

static func boss_id_for_stage(runtime: Dictionary, stage_id: String) -> String:
	var boss_config: Dictionary = _dict(_dict(runtime.get("difficultyConfig", {})).get("boss", {}))
	return String(_dict(boss_config.get("bossIds", {})).get(normalize_stage(stage_id), ""))

static func boss_rates(runtime: Dictionary, role: String = "firstHardBoss") -> Dictionary:
	var boss: Dictionary = _dict(_dict(runtime.get("difficultyConfig", {})).get("boss", {}))
	var hp := float(boss.get("hpRate", 1.0))
	# Reignition HP is replaced with the captured first HARD boss final HP in
	# apply_boss_runtime_stats. Keep this fallback at the normal HARD rate for
	# synthetic/legacy runtimes that have no capture yet.
	return {"hpRate": hp, "attackRate": float(boss.get("attackRate", 1.0)), "moveSpeedRate": float(boss.get("moveSpeedRate", 1.0)), "actionIntervalRate": float(boss.get("actionIntervalRate", 1.0)), "summonCountRate": float(boss.get("summonCountRate", 1.0)), "projectileSpeedRate": float(boss.get("projectileSpeedRate", 1.0)), "scoreRate": float(boss.get("reignitionScoreRate", 3.0) if role == "reignition" else boss.get("firstBossScoreRate", 2.0))}

static func final_boss_rates(runtime: Dictionary) -> Dictionary:
	return _dict(_dict(runtime.get("difficultyConfig", {})).get("finalBoss", {})).duplicate(true)

static func scaled_damage(base_damage: float, multiplier: float) -> int:
	if base_damage <= 0.0:
		return 0
	return maxi(1, roundi(base_damage * maxf(0.0, multiplier)))

static func regular_boss_damage_for_target(target: Node, base_damage: int) -> int:
	if base_damage <= 0 or target == null or not is_high_difficulty_target(target):
		return maxi(0, base_damage)
	var runtime := runtime_for_target(target)
	if String(runtime.get("playMode", SINGLE)) == RELAY_FINAL_BOSS:
		return base_damage
	var rates := boss_rates(runtime, boss_role_for_target(target))
	return scaled_damage(float(base_damage), float(rates.get("attackRate", 1.0)))

static func regular_boss_projectile_speed_for_target(target: Node, base_speed: float) -> float:
	var safe_speed := maxf(0.0, base_speed)
	if target == null or not is_high_difficulty_target(target):
		return safe_speed
	var runtime := runtime_for_target(target)
	if String(runtime.get("playMode", SINGLE)) == RELAY_FINAL_BOSS:
		return safe_speed
	var rates := boss_rates(runtime, boss_role_for_target(target))
	return safe_speed * maxf(0.0, float(rates.get("projectileSpeedRate", 1.0)))

static func regular_boss_summon_count_for_target(target: Node, base_count: int) -> int:
	var safe_count := maxi(0, base_count)
	# A one-enemy summon remains one; applying 1.25 must not turn every single
	# summon into two enemies. The relay final boss has its own stochastic 1.40
	# path and must not pass through this regular-boss helper.
	if safe_count <= 1 or target == null or not is_high_difficulty_target(target):
		return safe_count
	var runtime := runtime_for_target(target)
	if String(runtime.get("playMode", SINGLE)) == RELAY_FINAL_BOSS:
		return safe_count
	var rates := boss_rates(runtime, boss_role_for_target(target))
	return maxi(1, roundi(float(safe_count) * maxf(0.0, float(rates.get("summonCountRate", 1.0)))))

static func final_boss_phase_count(runtime: Dictionary) -> int:
	var config := _dict(_dict(runtime.get("difficultyConfig", {})).get("finalBoss", {}))
	var thresholds: Array = config.get("phaseThresholds", [0.70, 0.30, 0.00]) as Array
	return maxi(1, int(config.get("phaseCount", thresholds.size())))

static func final_boss_phase(runtime: Dictionary, hp_ratio: float) -> int:
	var thresholds: Array = _dict(_dict(runtime.get("difficultyConfig", {})).get("finalBoss", {})).get("phaseThresholds", [0.70, 0.30, 0.0]) as Array
	var phase_count := final_boss_phase_count(runtime)
	for phase_index in range(mini(maxi(0, phase_count - 1), thresholds.size())):
		if hp_ratio > float(thresholds[phase_index]):
			return phase_index
	return phase_count - 1

static func enemy_type_for_kind(kind: String, config: Dictionary = {}) -> String:
	var mapping: Dictionary = _dict(config.get("enemyKindTypes", {}))
	if mapping.has(kind):
		return normalize_combat_type(mapping[kind])
	# Compatibility for synthetic/test enemies that predate combatType. Real
	# enemies receive their type from EnemySystem.enemy_data().
	return normalize_combat_type(kind) if CANONICAL_COMBAT_TYPES.has(kind) else "standard"

static func normalize_combat_type(value: Variant) -> String:
	var combat_type := String(value).strip_edges().to_lower()
	if combat_type == "standardmelee" or combat_type == "standard_melee":
		return "standard"
	return combat_type if CANONICAL_COMBAT_TYPES.has(combat_type) else "standard"

static func combat_type_for_enemy(enemy: Dictionary, config: Dictionary = {}) -> String:
	if enemy.has("combatType"):
		return normalize_combat_type(enemy.get("combatType"))
	return enemy_type_for_kind(String(enemy.get("kind", "")), config)

static func apply_enemy_runtime_stats(enemy: Dictionary, runtime: Dictionary, role: String = "normal") -> Dictionary:
	if enemy.is_empty() or not is_high_difficulty_runtime(runtime) or bool(enemy.get("difficultyRuntimeApplied", false)) or role == "boss":
		return enemy
	var is_summon := bool(enemy.get("relayBossSummon", false)) or role == "finalBossSummon"
	var config: Dictionary = _dict(runtime.get("difficultyConfig", {}))
	var enemy_config: Dictionary = _dict(config.get("enemy", {}))
	var combat_type := combat_type_for_enemy(enemy, config)
	var rates: Dictionary = _dict(_dict(config.get("enemyFinalRates", {})).get(combat_type, {}))
	var base_hp := float(enemy.get("max_hp", enemy.get("hp", 1.0)))
	var base_attack := float(enemy.get("contactDamage", 0))
	var base_speed := float(enemy.get("speed", 0.0))
	var base_exp := float(enemy.get("baseExp", enemy.get("expValue", enemy.get("exp", 1))))
	enemy["difficultyBase"] = {"hp": base_hp, "contactDamage": base_attack, "speed": base_speed, "exp": base_exp}
	enemy["combatType"] = combat_type
	enemy["minimumAttackInterval"] = maxf(0.1, float(enemy.get("minimumAttackInterval", 0.1)))
	var hp_rate := float(rates.get("hpRate", enemy_config.get("hpRate", 1.0)))
	var attack_rate := float(rates.get("attackRate", enemy_config.get("attackRate", 1.0)))
	enemy["hp"] = maxf(1.0, ceilf(base_hp * hp_rate))
	enemy["max_hp"] = enemy["hp"]
	if enemy.has("currentHp"):
		enemy["currentHp"] = enemy["hp"]
	if enemy.has("maxHp"):
		enemy["maxHp"] = enemy["max_hp"]
	enemy["contactDamage"] = scaled_damage(base_attack, attack_rate)
	var active_move_rate := active_comment_param(runtime, "enemyMoveSpeedRate", active_comment_param(runtime, "enemySpeedRate", 1.0))
	if active_comment_id_is_active(runtime, "hard_overclock"):
		active_move_rate = active_comment_param_for_id(runtime, "hard_overclock", "enemyMoveSpeedRate", active_comment_param_for_id(runtime, "hard_overclock", "enemySpeedRate", active_move_rate))
	enemy["speed"] = base_speed * float(rates.get("moveSpeedRate", enemy_config.get("moveSpeedRate", 1.0))) * maxf(0.1, active_move_rate)
	enemy["projectileSpeedRate"] = float(rates.get("projectileSpeedRate", enemy_config.get("projectileSpeedRate", 1.0)))
	enemy["projectileDamageRate"] = attack_rate
	enemy["attackIntervalRate"] = float(rates.get("attackIntervalRate", enemy_config.get("attackIntervalRate", 1.0)))
	# EXP remains a base value on the enemy. ExpSystem applies difficulty and
	# reward multipliers once at defeat time.
	enemy["baseExp"] = base_exp
	enemy["expValue"] = base_exp
	enemy["exp"] = base_exp
	enemy["difficultyRuntimeApplied"] = true
	if is_summon:
		var rewards := normalized_summon_rewards(runtime)
		enemy["scoreDisabled"] = true
		enemy["scoreMultiplier"] = 0.0
		enemy["scoreEnabled"] = bool(rewards.get("scoreEnabled", false))
		enemy["expEnabled"] = bool(rewards.get("expEnabled", false))
		enemy["rewardConfig"] = rewards.duplicate(true)
		enemy["starDropEnabled"] = bool(rewards.get("starDropEnabled", true))
		enemy["healDropEnabled"] = bool(rewards.get("healDropEnabled", true))
		enemy["healDropRate"] = clampf(float(rewards.get("healDropRate", 0.10)), 0.0, 1.0)
	return enemy

static func normalized_summon_rewards(runtime: Dictionary) -> Dictionary:
	var raw: Variant = final_boss_rates(runtime).get("summonRewards", {})
	var source: Dictionary = raw as Dictionary if raw is Dictionary else {}
	var raw_heal_rate: Variant = source.get("healDropRate", 0.0)
	var heal_rate := 0.0
	if raw_heal_rate is int or raw_heal_rate is float:
		heal_rate = clampf(float(raw_heal_rate), 0.0, 1.0)
	elif String(raw_heal_rate).to_lower() == "low":
		heal_rate = 0.10
	return {
		"scoreEnabled": bool(source.get("scoreEnabled", not bool(source.get("scoreDisabled", true)))),
		"scoreRate": maxf(0.0, float(source.get("scoreRate", 0.0))),
		"expEnabled": bool(source.get("expEnabled", not bool(source.get("noRewards", false)))),
		"expRate": maxf(0.0, float(source.get("expRate", 1.0))),
		"starDropEnabled": bool(source.get("starDropEnabled", false)),
		"healDropEnabled": bool(source.get("healDropEnabled", source.has("healDropRate"))),
		"healDropRate": heal_rate
	}

static func attack_interval_for_enemy(enemy: Dictionary, base_interval: float, runtime: Dictionary = {}) -> float:
	var minimum := maxf(0.1, float(enemy.get("minimumAttackInterval", 0.1)))
	var rate := float(enemy.get("attackIntervalRate", 1.0))
	if not runtime.is_empty() and is_high_difficulty_runtime(runtime) and active_comment_id_is_active(runtime, "hard_overclock"):
		rate *= clampf(active_comment_param_for_id(runtime, "hard_overclock", "attackIntervalRate", 1.0), 0.1, 2.0)
	return maxf(minimum, maxf(0.0, base_interval) * rate)

static func projectile_speed_rate_for_enemy(enemy: Dictionary, runtime: Dictionary = {}) -> float:
	var rate := float(enemy.get("projectileSpeedRate", 1.0))
	if not runtime.is_empty() and is_high_difficulty_runtime(runtime) and active_comment_id_is_active(runtime, "hard_overclock"):
		rate *= clampf(active_comment_param_for_id(runtime, "hard_overclock", "projectileSpeedRate", 1.0), 0.25, 3.0)
	return rate

static func attack_interval_for_values(base_interval: float, attack_interval_rate: float, minimum_interval: float = 0.1) -> float:
	return maxf(maxf(0.1, minimum_interval), maxf(0.0, base_interval) * attack_interval_rate)

static func boss_action_delta_for_target(target: Node, boss: Dictionary, delta: float) -> float:
	var safe_delta := maxf(0.0, delta)
	if target == null or not is_high_difficulty_target(target):
		return safe_delta
	return safe_delta / maxf(0.1, float(boss.get("bossAttackIntervalRate", 1.0)))

static func apply_boss_runtime_stats(boss: Dictionary, runtime: Dictionary, role: String = "firstHardBoss") -> Dictionary:
	if boss.is_empty() or not is_high_difficulty_runtime(runtime) or bool(boss.get("difficultyRuntimeApplied", false)):
		return boss
	var rates := boss_rates(runtime, role)
	boss["difficultyBase"] = {"hp": float(boss.get("max_hp", boss.get("hp", 1.0))), "speed": float(boss.get("speed", 0.0)), "contactDamage": int(boss.get("contactDamage", 0))}
	var final_hp := float(boss.get("max_hp", boss.get("hp", 1.0))) * float(rates.get("hpRate", 1.0))
	var boss_state: Dictionary = _dict(runtime.get("bossState", {}))
	if role == "reignition":
		var captured_hp := float(boss_state.get("firstBossFinalHp", 0.0))
		var same_boss := String(boss_state.get("firstBossId", "")) == String(boss.get("bossId", boss.get("kind", "")))
		if captured_hp > 0.0 and same_boss:
			var heart_rate := active_comment_param_for_id(runtime, "hard_reignition_boss", "reignitionHpRate", 1.0)
			final_hp = captured_hp * 1.10 * heart_rate
	else:
		boss_state["firstBossFinalHp"] = final_hp
		boss_state["firstBossId"] = String(boss.get("bossId", boss.get("kind", "")))
		runtime["bossState"] = boss_state
	boss["hp"] = maxf(1.0, final_hp)
	boss["max_hp"] = boss["hp"]
	boss["speed"] = float(boss.get("speed", 0.0)) * float(rates.get("moveSpeedRate", 1.0))
	# Specialized bosses restore their movement speed from baseSpeed every
	# frame. Keep that authoritative base in sync so the HARD move multiplier
	# is not lost on the next specialized update.
	if boss.has("baseSpeed"):
		boss["baseSpeed"] = boss["speed"]
	boss["contactDamage"] = scaled_damage(float(boss.get("contactDamage", 0)), float(rates.get("attackRate", 1.0)))
	var hard_action_rate := float(rates.get("actionIntervalRate", 1.0))
	boss["bossAttackIntervalRate"] = float(boss.get("bossAttackIntervalRate", 1.0)) * hard_action_rate
	# Generic bosses create their first timer set before the HARD runtime is
	# applied. Rescale that existing set once; later resets already use the
	# stored bossAttackIntervalRate.
	if boss.get("bossAttackTimers") is Dictionary:
		var timers: Dictionary = boss.get("bossAttackTimers") as Dictionary
		for key in timers.keys():
			timers[key] = float(timers.get(key, 0.0)) * hard_action_rate
		boss["bossAttackTimers"] = timers
	boss["hardBossRole"] = role
	boss["hardPhase2HpRate"] = float(_dict(_dict(runtime.get("difficultyConfig", {})).get("boss", {})).get("phase2HpRate", 0.50))
	boss["difficultyRuntimeApplied"] = true
	return boss

static func effective_exp_rate(runtime: Dictionary) -> float:
	var difficulty := normalize_difficulty(runtime.get("difficulty", NORMAL))
	if difficulty in [HARD, EXPERT] and is_high_difficulty_runtime(runtime):
		return maxf(0.0, float(_dict(runtime.get("difficultyConfig", {})).get("experienceRate", 1.20)))
	return 1.0

static func active_comment_param(runtime: Dictionary, key: String, fallback: float = 1.0) -> float:
	if runtime.is_empty():
		return fallback
	var comment: Dictionary = _dict(runtime.get("activeComment", {}))
	var params: Dictionary = _dict(comment.get("params", {}))
	return float(params.get(key, fallback))

static func active_comment_id_is_active(runtime: Dictionary, comment_id: String) -> bool:
	if runtime.is_empty() or comment_id.is_empty():
		return false
	if String(_dict(runtime.get("activeComment", {})).get("id", "")) == comment_id:
		return true
	return _dict(runtime.get("activeCommentViews", {})).has(comment_id)

static func active_comment_param_for_id(runtime: Dictionary, comment_id: String, key: String, fallback: float = 1.0) -> float:
	if runtime.is_empty() or comment_id.is_empty():
		return fallback
	var views: Dictionary = _dict(runtime.get("activeCommentViews", {}))
	var selected: Dictionary = _dict(views.get(comment_id, {}))
	if selected.is_empty() and String(_dict(runtime.get("activeComment", {})).get("id", "")) == comment_id:
		selected = _dict(runtime.get("activeComment", {}))
	var params: Dictionary = _dict(selected.get("params", {}))
	return float(params.get(key, fallback))

static func active_comment_value_for_id(runtime: Dictionary, comment_id: String, key: String, fallback: Variant = null) -> Variant:
	if runtime.is_empty() or comment_id.is_empty():
		return fallback
	var views: Dictionary = _dict(runtime.get("activeCommentViews", {}))
	var selected: Dictionary = _dict(views.get(comment_id, {}))
	if selected.is_empty() and String(_dict(runtime.get("activeComment", {})).get("id", "")) == comment_id:
		selected = _dict(runtime.get("activeComment", {}))
	var params: Dictionary = _dict(selected.get("params", {}))
	return params.get(key, fallback)

static func spawn_rate(runtime: Dictionary, elapsed: float, boss_active: bool = false, collab_challenge_active: bool = false) -> float:
	return float(spawn_rate_breakdown(runtime, elapsed, boss_active, collab_challenge_active).get("final", 1.0))

static func spawn_rate_breakdown(runtime: Dictionary, elapsed: float, boss_active: bool = false, collab_challenge_active: bool = false) -> Dictionary:
	var breakdown := {"base": 1.0, "stage": 1.0, "time": 1.0, "commonExpert": 1.0, "expertTime": 1.0, "section": 1.0, "stageFlavor": 1.0, "boss": 1.0, "event": 1.0, "comment": 1.0, "safety": 1.0, "final": 1.0}
	if not is_high_difficulty_runtime(runtime):
		return breakdown
	var mode := String(runtime.get("playMode", SINGLE))
	var config: Dictionary = _dict(runtime.get("difficultyConfig", {}))
	if mode == SINGLE:
		breakdown["time"] = _phase_rate(config.get("singleSpawnPhases", []) as Array, elapsed, 1.0)
		breakdown["expertTime"] = expert_spawn_time_rate(runtime, elapsed)
		breakdown["commonExpert"] = breakdown["expertTime"]
		breakdown["stageFlavor"] = stage_profile_spawn_pressure_rate(runtime, elapsed)
	elif mode == RELAY_SECTION:
		breakdown["stage"] = float(_dict(config.get("relayStageSpawnRates", {})).get(normalize_stage(runtime.get("stageId", "zatsudan")), 1.0))
		breakdown["time"] = _phase_rate(config.get("relayTimePhases", []) as Array, elapsed, 1.0)
		breakdown["expertTime"] = expert_spawn_time_rate(runtime, elapsed)
		breakdown["commonExpert"] = breakdown["expertTime"]
		breakdown["section"] = expert_relay_section_rate(runtime)
		breakdown["stageFlavor"] = stage_profile_spawn_pressure_rate(runtime, elapsed)
	if not spawn_enabled(runtime, elapsed):
		breakdown["final"] = 0.0
		return breakdown
	breakdown["base"] = 1.0
	if boss_active and String(runtime.get("playMode", SINGLE)) == SINGLE:
		breakdown["boss"] = maxf(0.0, float(config.get("bossBattleSpawnRate", 0.65)))
	if collab_challenge_active and String(runtime.get("playMode", SINGLE)) == RELAY_SECTION and normalize_stage(runtime.get("stageId", "")) == "collab":
		breakdown["event"] = maxf(0.0, float(config.get("collabChallengeSpawnRate", 0.50)))
	if active_comment_id_is_active(runtime, "enemy_spawn_up") or active_comment_id_is_active(runtime, "kamiyoyaku"):
		var fallback_comment_rate := maxf(0.25, active_comment_param(runtime, "enemySpawnRate", active_comment_param(runtime, "enemySpawnAmountRate", 1.0)))
		breakdown["comment"] = fallback_comment_rate
		if active_comment_id_is_active(runtime, "enemy_spawn_up"):
			breakdown["comment"] = maxf(0.25, active_comment_param_for_id(runtime, "enemy_spawn_up", "enemySpawnRate", active_comment_param_for_id(runtime, "enemy_spawn_up", "enemySpawnAmountRate", fallback_comment_rate)))
		elif active_comment_id_is_active(runtime, "kamiyoyaku"):
			breakdown["comment"] = maxf(0.25, active_comment_param_for_id(runtime, "kamiyoyaku", "enemySpawnRate", active_comment_param_for_id(runtime, "kamiyoyaku", "enemySpawnAmountRate", fallback_comment_rate)))
	elif active_comment_id_is_active(runtime, "game_genre_mix"):
		var genre_spawn_rate := clampf(active_comment_param(runtime, "eventSpawnRate", 1.0), 0.25, 1.0)
		breakdown["comment"] = clampf(active_comment_param_for_id(runtime, "game_genre_mix", "eventSpawnRate", genre_spawn_rate), 0.25, 1.0)
	elif active_comment_id_is_active(runtime, "song_tempo_up"):
		var tempo_spawn_rate := maxf(0.25, active_comment_param(runtime, "enemySpawnAmountRate", 1.0))
		breakdown["comment"] = maxf(0.25, active_comment_param_for_id(runtime, "song_tempo_up", "enemySpawnAmountRate", tempo_spawn_rate))
	breakdown["safety"] = clampf(float(runtime.get("performanceSafetyRate", config.get("performanceSafetyRate", 1.0))), 0.0, 1.0)
	breakdown["final"] = float(breakdown["base"]) * float(breakdown["stage"]) * float(breakdown["time"]) * float(breakdown["expertTime"]) * float(breakdown["section"]) * float(breakdown["stageFlavor"]) * float(breakdown["boss"]) * float(breakdown["event"]) * float(breakdown["comment"]) * float(breakdown["safety"])
	return breakdown

static func expert_spawn_time_rate(runtime: Dictionary, elapsed: float) -> float:
	if not is_expert_runtime(runtime):
		return 1.0
	var phases: Array = _array(_dict(runtime.get("difficultyConfig", {})).get("expertSpawnPressurePhases", []))
	return _phase_rate(phases, elapsed, 1.0)

static func expert_relay_section_rate(runtime: Dictionary) -> float:
	if not is_expert_runtime(runtime) or String(runtime.get("playMode", SINGLE)) != RELAY_SECTION:
		return 1.0
	var rates: Array = _array(_dict(runtime.get("difficultyConfig", {})).get("expertRelaySectionRates", []))
	var index := clampi(int(runtime.get("relaySegmentIndex", 0)), 0, maxi(0, rates.size() - 1))
	return float(rates[index]) if not rates.is_empty() else 1.0

static func spawn_enabled(runtime: Dictionary, elapsed: float) -> bool:
	if runtime.is_empty():
		return true
	var mode := String(runtime.get("playMode", SINGLE))
	if not is_high_difficulty_runtime(runtime):
		return mode != RELAY_FINAL_BOSS
	if mode == RELAY_FINAL_BOSS:
		return false
	return elapsed < float(runtime.get("durationSeconds", INF))

static func active_enemy_cap(base_cap: int, runtime: Dictionary) -> int:
	if not is_high_difficulty_runtime(runtime):
		return base_cap
	return maxi(0, floori(float(base_cap) * float(_dict(_dict(runtime.get("difficultyConfig", {})).get("enemy", {})).get("activeEnemyLimitRate", 1.30))))

static func spawn_priority_for_source(source: String) -> int:
	var key := source.strip_edges().to_lower()
	if key == "boss" or key == "boss_spawn":
		return int(SPAWN_PRIORITY["boss"])
	if key == "boss_summon" or key == "relay_boss_summon":
		return int(SPAWN_PRIORITY["boss_summon"])
	if key == "comment_required" or key == "comment_linked":
		return int(SPAWN_PRIORITY["comment_required"])
	if key == "stage_gimmick" or key == "genre_event":
		return int(SPAWN_PRIORITY["stage_gimmick"])
	if key == "support_enemy" or key == "support":
		return int(SPAWN_PRIORITY["support_enemy"])
	if key == "hard_wave":
		return int(SPAWN_PRIORITY["hard_wave"])
	if key == "extra_swarm":
		return int(SPAWN_PRIORITY["extra_swarm"])
	return int(SPAWN_PRIORITY["normal_wave"])

static func make_spawn_request(enemy_id: String, count: int, source: String, expires_in_seconds: float = 0.0, extra: Dictionary = {}) -> Dictionary:
	var request := {
		"enemyId": enemy_id,
		"count": maxi(0, count),
		"priority": spawn_priority_for_source(source),
		"source": source,
		"expiresInSeconds": maxf(0.0, expires_in_seconds)
	}
	for key in extra.keys():
		request[key] = extra[key]
	return request

static func enqueue_spawn_request(runtime: Dictionary, request: Dictionary, now: float) -> Dictionary:
	if runtime.is_empty() or request.is_empty() or int(request.get("count", 0)) <= 0:
		return {}
	var serial := int(runtime.get("requestSerial", 0)) + 1
	request["serial"] = serial
	request["requestedAt"] = now
	request["expiresAt"] = INF if float(request.get("expiresInSeconds", 0.0)) <= 0.0 else now + float(request.get("expiresInSeconds", 0.0))
	var pending: Array = runtime.get("pendingSpawnRequests", []) as Array
	pending.append(request.duplicate(true))
	runtime["pendingSpawnRequests"] = pending
	runtime["requestSerial"] = serial
	return request

static func prune_spawn_requests(runtime: Dictionary, now: float) -> void:
	if runtime.is_empty():
		return
	var pending: Array = runtime.get("pendingSpawnRequests", []) as Array
	var kept: Array = []
	for raw in pending:
		if raw is Dictionary and now < float((raw as Dictionary).get("expiresAt", INF)):
			kept.append(raw)
	runtime["pendingSpawnRequests"] = kept

static func current_spawn_requests(runtime: Dictionary, now: float) -> Array:
	prune_spawn_requests(runtime, now)
	var pending: Array = runtime.get("pendingSpawnRequests", []) as Array
	pending.sort_custom(func(a: Variant, b: Variant) -> bool:
		return int((a as Dictionary).get("priority", 0)) > int((b as Dictionary).get("priority", 0))
	)
	return pending

static func resolve_spawn_requests(runtime: Dictionary, active_occupancy: int, cap: int, now: float) -> Array:
	var resolved: Array = []
	var available := maxi(0, cap - active_occupancy) if cap > 0 else 999999
	for raw in current_spawn_requests(runtime, now):
		var request: Dictionary = raw as Dictionary
		var requested := maxi(0, int(request.get("count", 0)))
		var reserve := int(request.get("activeEnemyLimitReserve", 0))
		var priority := int(request.get("priority", 0))
		var accepted := 0
		if priority >= int(SPAWN_PRIORITY["stage_gimmick"]) and available < reserve:
			accepted = 0
		elif priority >= int(SPAWN_PRIORITY["hard_wave"]) and bool(request.get("requireReserve", false)) and available < reserve:
			accepted = 0
		elif priority >= int(SPAWN_PRIORITY["stage_gimmick"]):
			accepted = requested if requested <= available else 0
		else:
			accepted = mini(requested, available)
		var view := request.duplicate(true)
		view["resolvedCount"] = accepted
		view["deferred"] = accepted == 0 and requested > 0
		resolved.append(view)
		available = maxi(0, available - accepted)
	return resolved

static func hard_wave_selection_rate(runtime: Dictionary, elapsed: float, boss_active: bool = false) -> float:
	if not is_high_difficulty_runtime(runtime) or String(runtime.get("playMode", SINGLE)) == RELAY_FINAL_BOSS:
		return 0.0
	var duration := maxf(1.0, float(runtime.get("durationSeconds", 180.0)))
	var progress := clampf(elapsed / duration, 0.0, 1.0)
	var selection: Dictionary = _dict(_dict(runtime.get("difficultyConfig", {})).get("hardWaveSelectionRates", {}))
	var rate := float(selection.get("earlyRate", 0.15)) if progress < float(selection.get("beforeProgress", 0.25)) else (float(selection.get("middleRate", 0.25)) if progress < float(selection.get("middleProgress", 0.60)) else float(selection.get("lateRate", 0.35)))
	var result := rate * float(selection.get("bossRate", 0.30)) if boss_active else rate
	if is_expert_runtime(runtime):
		result *= float(_dict(runtime.get("difficultyConfig", {})).get("expertHardWaveSelectionRateMultiplier", 1.0))
		result *= stage_profile_hard_wave_selection_rate(runtime)
	return clampf(result, 0.0, 1.0)

static func hard_wave_candidates(runtime: Dictionary, elapsed: float, player_level: int, active_dangers: Dictionary = {}, boss_active: bool = false) -> Array:
	if not is_high_difficulty_runtime(runtime) or not spawn_enabled(runtime, elapsed):
		return []
	var config: Dictionary = _dict(runtime.get("difficultyConfig", {}))
	var mode := String(runtime.get("playMode", SINGLE))
	var stage := normalize_stage(runtime.get("stageId", "zatsudan"))
	var used: Dictionary = runtime.get("usedHardWaveCounts", {}) as Dictionary
	var cooldowns: Dictionary = runtime.get("hardWaveCooldowns", {}) as Dictionary
	var result: Array = []
	var wave_sources: Array = _dict_array(config.get("hardWaves", [])).duplicate(true)
	if is_expert_runtime(runtime):
		var stage_waves: Dictionary = _dict(config.get("expertStageHardWaves", {}))
		wave_sources.append_array(_array(stage_waves.get(stage, [])))
	for raw in wave_sources:
		var wave: Dictionary = raw as Dictionary
		var expert_only := bool(wave.get("expertOnly", false))
		if expert_only and not is_expert_runtime(runtime):
			continue
		if not expert_only and normalize_difficulty(wave.get("difficulty", HARD)) != HARD:
			continue
		if normalize_stage(wave.get("stageId", stage)) != stage:
			continue
		var play_modes: Array = wave.get("playModes", []) as Array
		if not play_modes.is_empty() and not play_modes.has(mode):
			continue
		var minimum_elapsed := float(wave.get("minElapsedSeconds", 0.0))
		var mode_minimums: Dictionary = _dict(wave.get("minElapsedSecondsByMode", {}))
		if mode_minimums.has(mode):
			minimum_elapsed = float(mode_minimums.get(mode, minimum_elapsed))
		if elapsed < minimum_elapsed or elapsed >= float(wave.get("maxElapsedSeconds", INF)):
			continue
		if player_level < int(wave.get("minimumPlayerLevel", 1)) or player_level > int(wave.get("maximumPlayerLevel", 999)):
			continue
		var wave_id := String(wave.get("id", ""))
		var maximum_uses := int(wave.get("maximumUsesPerRun", 999999))
		if expert_only:
			var profile_maximum_uses := stage_profile_hard_wave_maximum_uses(runtime)
			if profile_maximum_uses >= 0:
				maximum_uses = mini(maximum_uses, profile_maximum_uses)
		if wave_id.is_empty() or int(used.get(wave_id, 0)) >= maximum_uses:
			continue
		if elapsed < float(cooldowns.get(wave_id, -INF)):
			continue
		if boss_active:
			var boss_blocked_categories: Array = ["surround", "high_density", "screen_restriction"]
			var wave_categories: Array = wave.get("dangerCategories", []) as Array
			var has_boss_blocked_category := false
			for category in wave_categories:
				if boss_blocked_categories.has(DangerEventSystemScript.normalize_category(String(category))):
					has_boss_blocked_category = true
					break
			if has_boss_blocked_category:
				continue
		if not DangerEventSystemScript.can_start_categories(active_dangers, wave.get("dangerCategories", []) as Array, wave.get("blockedDangerCategories", []) as Array):
			continue
		var candidate := wave.duplicate(true)
		candidate["maximumUsesPerRun"] = maximum_uses
		result.append(candidate)
	return result

static func choose_hard_wave(runtime: Dictionary, elapsed: float, player_level: int, active_enemy_count: int, active_dangers: Dictionary, boss_active: bool, rng: RandomNumberGenerator, available_cap: int = -1) -> Dictionary:
	if rng == null or rng.randf() >= hard_wave_selection_rate(runtime, elapsed, boss_active):
		return {}
	var candidates := hard_wave_candidates(runtime, elapsed, player_level, active_dangers, boss_active)
	if candidates.is_empty():
		return {}
	var last_id := String(runtime.get("lastHardWaveId", ""))
	var without_last: Array = []
	for wave in candidates:
		if String((wave as Dictionary).get("id", "")) != last_id:
			without_last.append(wave)
	if not without_last.is_empty():
		candidates = without_last
	var eligible: Array = []
	for wave in candidates:
		var required := int((wave as Dictionary).get("activeEnemyLimitReserve", 0))
		if available_cap < 0 or active_enemy_count + required <= available_cap or required <= 0:
			eligible.append(wave)
	if eligible.is_empty():
		return {}
	var total_weight := 0.0
	for wave in eligible:
		total_weight += maxf(0.0, float((wave as Dictionary).get("weight", 1.0)))
	if total_weight <= 0.0:
		return (eligible[0] as Dictionary).duplicate(true)
	var roll := rng.randf() * total_weight
	for wave in eligible:
		roll -= maxf(0.0, float((wave as Dictionary).get("weight", 1.0)))
		if roll <= 0.0:
			return (wave as Dictionary).duplicate(true)
	return (eligible.back() as Dictionary).duplicate(true)

static func mark_hard_wave_started(runtime: Dictionary, wave: Dictionary, now: float) -> void:
	if runtime.is_empty() or wave.is_empty():
		return
	var wave_id := String(wave.get("id", ""))
	if wave_id.is_empty():
		return
	var used: Dictionary = runtime.get("usedHardWaveCounts", {}) as Dictionary
	used[wave_id] = int(used.get(wave_id, 0)) + 1
	runtime["usedHardWaveCounts"] = used
	var cooldowns: Dictionary = runtime.get("hardWaveCooldowns", {}) as Dictionary
	cooldowns[wave_id] = now + float(wave.get("cooldownSeconds", 0.0))
	runtime["hardWaveCooldowns"] = cooldowns
	runtime["lastHardWaveId"] = wave_id
	runtime["currentWave"] = wave_id

static func apply_spawn_count_rate(base_count: int, rate: float, rng: RandomNumberGenerator) -> int:
	var exact := maxf(0.0, float(base_count) * maxf(0.0, rate))
	var whole := floori(exact)
	return whole + (1 if rng.randf() < exact - float(whole) else 0)

static func temporary_score_rate(runtime: Dictionary, comment_score_rate: float = 1.0) -> float:
	if not is_high_difficulty_runtime(runtime):
		return 1.0
	var config: Dictionary = _dict(runtime.get("difficultyConfig", {}))
	var score: Dictionary = _dict(config.get("score", {}))
	var climax_rate := float(score.get("climaxRate", 1.20)) if bool(_dict(runtime.get("climax", {})).get("active", false)) else 1.0
	return minf(float(score.get("maxTemporaryRate", 2.0)), float(score.get("baseRate", 1.20)) * maxf(1.0, comment_score_rate) * climax_rate)

static func resolve_comment(comment: Dictionary, runtime: Dictionary) -> Dictionary:
	if comment.is_empty():
		return {}
	var result := comment.duplicate(true)
	if not is_high_difficulty_runtime(runtime):
		return result
	var config: Dictionary = _dict(runtime.get("difficultyConfig", {}))
	var difficulty := normalize_difficulty(runtime.get("difficulty", NORMAL))
	var hard_config: Dictionary = _dict(runtime.get("difficultyHardConfig", {}))
	if hard_config.is_empty():
		hard_config = config if difficulty == HARD else {}
	var comment_id := String(comment.get("id", ""))
	var override: Dictionary = _dict(_dict(hard_config.get("commentOverrides", {})).get(comment_id, {})).duplicate(true)
	var own_overrides: Dictionary = _dict(comment.get("difficultyOverrides", {}))
	override = _deep_merge(override, _dict(own_overrides.get(HARD, {})))
	if difficulty == EXPERT:
		override = _deep_merge(override, _dict(_dict(config.get("expertCommentOverrides", {})).get(comment_id, {})))
		override = _deep_merge(override, _dict(own_overrides.get(EXPERT, {})))
	result = _deep_merge(result, override)
	result["difficultyId"] = difficulty
	var category_map: Dictionary = _dict(hard_config.get("commentCategories", {}))
	if category_map.is_empty():
		category_map = _dict(config.get("commentCategories", {}))
	if not comment.has("categories") and category_map.has(comment_id):
		result["categories"] = _array(category_map.get(comment_id))
	var explicit_score := override.has("scoreRate") or override.has("multiplier") or comment.has("scoreRate")
	var danger := clampi(int(result.get("riskLevel", 1)), 1, 5)
	if explicit_score:
		result["scoreRate"] = float(result.get("scoreRate", result.get("multiplier", 1.0)))
	else:
		result["scoreRate"] = float(HARD_COMMENT_DANGER_SCORE_RATES.get(danger, 1.0))
	result["categories"] = comment_categories(result)
	return result

static func score_rate_for_risk(risk: int) -> float:
	return float(HARD_COMMENT_DANGER_SCORE_RATES.get(clampi(risk, 1, 5), 1.0))

static func build_offer_for_target(target: Node, comments: Array, rng: RandomNumberGenerator) -> Array:
	var runtime := runtime_for_target(target)
	if not is_high_difficulty_runtime(runtime):
		return []
	var now := float(target.get("elapsed"))
	var last_id := String(target.get("last_comment_id"))
	var cycle := int(runtime.get("commentOfferCycle", 0)) + 1
	runtime["commentOfferCycle"] = cycle
	var candidates: Array = []
	var seen_ids: Dictionary = {}
	var exclusion_log: Dictionary = {}
	for item in comments:
		if not item is Dictionary:
			continue
		var comment := resolve_comment(item as Dictionary, runtime)
		var comment_id := String(comment.get("id", ""))
		if comment_id.is_empty() or seen_ids.has(comment_id):
			continue
		if comment_id == "do_everything" or bool(comment.get("isSpecialChoice", false)) or bool(comment.get("excludedFromNormalChoices", false)):
			continue
		var evaluation := comment_evaluation(comment, runtime, now, target)
		if not bool(evaluation.get("allowed", false)):
			exclusion_log[comment_id] = (evaluation.get("reasons", []) as Array).duplicate()
			continue
		seen_ids[comment_id] = true
		candidates.append(comment)
	var state: Dictionary = runtime.get("bossState", {}) as Dictionary
	var reignition_candidate := false
	var remaining := maxf(0.0, float(runtime.get("remainingSeconds", 180.0)))
	if can_offer_reignition(runtime, remaining, int(state.get("activeBossCount", 0))):
		candidates.append(_reignition_comment())
		reignition_candidate = true
	if candidates.is_empty():
		runtime["commentDebugLast"] = {"cycle": cycle, "candidates": [], "exclusions": exclusion_log}
		return []
	var recent_categories: Array = _array(target.get("recent_comment_categories"))
	var previous_offer: Array = _array(runtime.get("commentOfferHistory"))
	var category_cooldowns: Dictionary = _dict(runtime.get("commentCategoryCooldowns", {}))
	var comment_cooldowns: Dictionary = _dict(runtime.get("commentCooldowns", {}))
	var preferred_candidates: Array = []
	for item in candidates:
		var candidate: Dictionary = item as Dictionary
		var candidate_id := String(candidate.get("id", ""))
		var on_cooldown := false
		for category in comment_categories(candidate):
			if cycle < int(category_cooldowns.get(String(category), 0)):
				on_cooldown = true
				break
		if candidate_id != last_id and not previous_offer.has(candidate_id) and cycle >= int(comment_cooldowns.get(candidate_id, 0)) and not on_cooldown and not _candidate_category_is_recent(candidate, recent_categories):
			preferred_candidates.append(candidate)
	if preferred_candidates.is_empty():
		preferred_candidates = candidates.duplicate()
	var offer: Array = []
	var used_ids: Dictionary = {}
	var hard_only_added := false
	var composer_config: Dictionary = _dict(_dict(runtime.get("difficultyConfig", {})).get("commentComposer", {}))
	var want_hard_only := rng != null and rng.randf() < float(composer_config.get("hardOnlyTargetRate", HARD_ONLY_TARGET_RATE))
	# First pass: preserve the intended risk bands, category spread and ID
	# uniqueness.  last/recent are preference filters only; they are never a
	# reason to return fewer than three cards.
	for slot_index in range(3):
		var risk_range: Array = [[2, 3], [3, 3], [4, 5]][slot_index] as Array
		var pool: Array = []
		for item in preferred_candidates:
			var candidate: Dictionary = item as Dictionary
			var risk := int(candidate.get("riskLevel", 1))
			var candidate_id := String(candidate.get("id", ""))
			if risk < int(risk_range[0]) or risk > int(risk_range[1]) or used_ids.has(candidate_id) or not _offer_candidate_allowed(offer, candidate, runtime):
				continue
			if bool(candidate.get("hardOnly", false)) and hard_only_added:
				continue
			_append_weighted_comment(pool, candidate, runtime)
		if want_hard_only and not hard_only_added:
			var hard_pool: Array = []
			for item in pool:
				if bool((item as Dictionary).get("hardOnly", false)):
					hard_pool.append(item)
			if not hard_pool.is_empty():
				pool = hard_pool
		if pool.is_empty():
			continue
		var selected: Dictionary = pool[rng.randi_range(0, pool.size() - 1)] as Dictionary
		if _append_offer_card(offer, used_ids, selected):
			hard_only_added = hard_only_added or bool(selected.get("hardOnly", false))
	# Second pass: retain every safety predicate, but relax category and recent
	# history preferences before considering duplicate cards.
	while offer.size() < 3:
		var fallback: Array = []
		for item in candidates:
			var candidate: Dictionary = item as Dictionary
			var candidate_id := String(candidate.get("id", ""))
			if used_ids.has(candidate_id) or _is_non_repeatable_candidate(candidate) or not _offer_candidate_allowed(offer, candidate, runtime):
				continue
			if bool(candidate.get("hardOnly", false)) and hard_only_added:
				continue
			_append_weighted_comment(fallback, candidate, runtime)
		if fallback.is_empty():
			break
		var fallback_card: Dictionary = fallback[rng.randi_range(0, fallback.size() - 1)] as Dictionary
		if _append_offer_card(offer, used_ids, fallback_card):
			hard_only_added = hard_only_added or bool(fallback_card.get("hardOnly", false))
	# Final pass: preserve every already-resolved, selectable ID before applying
	# composition preferences.  Category/risk composition is only a preference
	# here; the candidate's availability and non-repeatable safety predicates
	# were already resolved above and remain enforced.
	while offer.size() < 3:
		var unique_pool: Array = []
		for item in candidates:
			var candidate: Dictionary = item as Dictionary
			var candidate_id := String(candidate.get("id", ""))
			if used_ids.has(candidate_id) or _is_non_repeatable_candidate(candidate):
				continue
			unique_pool.append(candidate)
		if unique_pool.is_empty():
			break
		_append_offer_card(offer, used_ids, unique_pool[rng.randi_range(0, unique_pool.size() - 1)] as Dictionary)
	var final_offer := offer.slice(0, 3)
	if final_offer.size() == 3 and _should_offer_hard_do_everything(target, runtime, now, final_offer, comments, rng):
		var special: Dictionary = resolve_comment(_find_comment_by_id(comments, "do_everything"), runtime)
		if not special.is_empty():
			final_offer.append(special.duplicate(true))
	if reignition_candidate:
		for item in final_offer:
			if String((item as Dictionary).get("id", "")) == "hard_reignition_boss":
				mark_reignition_offer_shown(runtime)
				break
	_record_comment_offer(runtime, final_offer, cycle)
	runtime["commentDebugLast"] = {
		"cycle": cycle,
		"candidates": _comment_debug_views(candidates),
		"offer": _comment_debug_views(final_offer),
		"hardOnlyCount": _count_hard_only(final_offer),
		"danger4PlusCount": _count_danger4_plus(final_offer),
		"doEverythingFourthEligible": final_offer.size() == 4,
		"exclusions": exclusion_log
	}
	return final_offer

static func build_safe_default_offer_for_target(target: Node, comments: Array, rng: RandomNumberGenerator) -> Array:
	var runtime := runtime_for_target(target)
	if not is_high_difficulty_runtime(runtime):
		return []
	var candidates: Array = []
	var seen_ids: Dictionary = {}
	var now := float(target.get("elapsed"))
	for item in comments:
		if not item is Dictionary:
			continue
		var candidate := resolve_comment(item as Dictionary, runtime)
		var candidate_id := String(candidate.get("id", ""))
		if candidate_id.is_empty() or seen_ids.has(candidate_id) or _is_non_repeatable_candidate(candidate):
			continue
		if bool(comment_evaluation(candidate, runtime, now, target).get("allowed", false)):
			seen_ids[candidate_id] = true
			candidates.append(candidate)
	if candidates.is_empty():
		return []
	var offer: Array = []
	var unique_candidates: Array = candidates.duplicate()
	while offer.size() < 3 and not unique_candidates.is_empty():
		var safe_pool: Array = []
		for item in unique_candidates:
			var candidate: Dictionary = item as Dictionary
			if _offer_candidate_allowed(offer, candidate, runtime):
				safe_pool.append(candidate)
		if safe_pool.is_empty():
			break
		var selected: Dictionary = safe_pool[rng.randi_range(0, safe_pool.size() - 1)] as Dictionary
		offer.append(selected.duplicate(true))
		for index in range(unique_candidates.size() - 1, -1, -1):
			if String((unique_candidates[index] as Dictionary).get("id", "")) == String(selected.get("id", "")):
				unique_candidates.remove_at(index)
				break
	# If category/risk composition left slots open, use the remaining resolved
	# candidates in their own IDs.  Do not synthesize duplicate cards; a true
	# shortage is returned to CommentSystem for its retry path.
	while offer.size() < 3 and not unique_candidates.is_empty():
		var selected_index := rng.randi_range(0, unique_candidates.size() - 1)
		var selected_candidate: Dictionary = unique_candidates[selected_index] as Dictionary
		offer.append(selected_candidate.duplicate(true))
		unique_candidates.remove_at(selected_index)
	return offer

static func _append_offer_card(offer: Array, used_ids: Dictionary, candidate: Dictionary) -> bool:
	var candidate_id := String(candidate.get("id", ""))
	if candidate.is_empty() or candidate_id.is_empty():
		return false
	if used_ids.has(candidate_id):
		return false
	offer.append(candidate.duplicate(true))
	used_ids[candidate_id] = true
	return true

static func _append_weighted_comment(pool: Array, candidate: Dictionary, runtime: Dictionary) -> void:
	var repeats := 1
	if is_expert_runtime(runtime):
		repeats = clampi(ceili(stage_profile_comment_weight(runtime, String(candidate.get("id", "")))), 1, 3)
	for _index in range(repeats):
		pool.append(candidate)

static func _offer_candidate_allowed(selected: Array, candidate: Dictionary, runtime: Dictionary) -> bool:
	return _categories_allowed(selected, candidate) and _stage_boosted_high_risk_allowed(selected, candidate, runtime)

static func _stage_boosted_high_risk_allowed(selected: Array, candidate: Dictionary, runtime: Dictionary) -> bool:
	if not is_expert_runtime(runtime) or not stage_profile_comment_is_boosted(runtime, String(candidate.get("id", ""))) or int(candidate.get("riskLevel", 1)) < 3:
		return true
	var limit := stage_profile_comment_high_risk_limit(runtime)
	if limit <= 0:
		return false
	var count := 0
	for item in selected:
		var selected_comment: Dictionary = item as Dictionary
		if int(selected_comment.get("riskLevel", 1)) >= 3 and stage_profile_comment_is_boosted(runtime, String(selected_comment.get("id", ""))):
			count += 1
	return count < limit

static func _candidate_category_is_recent(candidate: Dictionary, recent_categories: Array) -> bool:
	for category in comment_categories(candidate):
		for recent in recent_categories:
			if String(recent) == String(category):
				return true
	return false

static func _is_non_repeatable_candidate(candidate: Dictionary) -> bool:
	var candidate_id := String(candidate.get("id", ""))
	var effect_type := String(candidate.get("effectType", ""))
	var categories := comment_categories(candidate)
	if candidate_id == "hard_reignition_boss" or candidate_id == "do_everything":
		return true
	if effect_type == "summon_boss" or effect_type == "hard_reignition_boss" or candidate_id == "summon_boss":
		return true
	if categories.has("boss") or int(candidate.get("riskLevel", 1)) >= 4:
		return true
	return bool(candidate.get("hardOnly", false)) or categories.has("compound") or bool(candidate.get("highComplexity", false)) or bool(candidate.get("complex", false))

static func comment_categories(comment: Dictionary) -> Array:
	var explicit: Variant = comment.get("categories", null)
	if explicit is Array and not (explicit as Array).is_empty():
		return (explicit as Array).duplicate()
	var id := String(comment.get("id", ""))
	var mapped: Array = []
	match id:
		"reverse_control", "no_dash", "attack_right_only", "no_stop", "no_brake":
			mapped = ["control_restriction"]
		"hide_hp", "comment_barrage", "camera_zoom":
			mapped = ["visibility"]
		"enemy_speed_up":
			mapped = ["enemy_speed"]
		"enemy_spawn_up":
			mapped = ["enemy_spawn"]
		"split_enemy":
			mapped = ["enemy_spawn", "high_density"]
		"summon_boss", "hard_reignition_boss":
			mapped = ["boss"]
		"genre_change", "force_bullet_hell", "force_race", "force_horror":
			mapped = ["stage_major_event", "forced_movement", "compound"]
		"hard_overclock":
			mapped = ["enemy_attack", "projectile_pressure", "compound"]
		"hard_pressure_wave":
			mapped = ["hard_wave", "stage_major_event", "high_density"]
		"talk_comment_avalanche":
			mapped = ["stage_major_event", "movement_hazard"]
		"game_genre_mix":
			mapped = ["stage_major_event", "forced_movement", "compound"]
	if mapped.is_empty():
		mapped = [String(comment.get("category", "default"))]
	return mapped

static func comment_evaluation(comment: Dictionary, runtime: Dictionary, elapsed: float, target: Node) -> Dictionary:
	var reasons: Array[String] = []
	var comment_id := String(comment.get("id", ""))
	if comment_id.is_empty():
		reasons.append("missing_id")
	if not is_high_difficulty_runtime(runtime):
		reasons.append("not_high_difficulty")
	var stage_ids: Variant = comment.get("stageIds", null)
	if stage_ids is Array and not (stage_ids as Array).is_empty():
		var stage_match := false
		var current_stage := normalize_stage(runtime.get("stageId", "zatsudan"))
		for raw_stage in stage_ids as Array:
			if normalize_stage(raw_stage) == current_stage:
				stage_match = true
				break
		if not stage_match:
			reasons.append("stage")
	var availability: Dictionary = _dict(comment.get("availability", {}))
	var difficulty := normalize_difficulty(runtime.get("difficulty", NORMAL))
	if availability.has(difficulty) and not bool(availability.get(difficulty, true)):
		reasons.append("availability")
	if bool(comment.get("hardOnly", false)) and not is_high_difficulty_runtime(runtime):
		reasons.append("hard_only")
	if elapsed < float(comment.get("minTime", 0.0)):
		reasons.append("min_time")
	if elapsed >= float(comment.get("maxTime", INF)):
		reasons.append("max_time")
	var mode := String(runtime.get("playMode", SINGLE))
	var is_boss_comment := String(comment.get("effectType", "")) == "summon_boss" or comment_id == "summon_boss" or comment_id == "hard_reignition_boss"
	if mode == RELAY_SECTION and is_boss_comment:
		reasons.append("relay_intermediate_boss")
	if mode == RELAY_FINAL_BOSS and (comment_id == "summon_boss" or comment_id == "hard_reignition_boss"):
		reasons.append("final_boss_pool")
	var state: Dictionary = runtime.get("bossState", {}) as Dictionary
	var active_boss := int(state.get("activeBossCount", 0)) > 0 or bool(target.get("boss_active")) or bool(target.get("relay_boss_active"))
	if comment_id == "summon_boss" or String(comment.get("effectType", "")) == "summon_boss":
		if not can_offer_early_boss(runtime, elapsed, int(state.get("activeBossCount", 0)), bool(target.get("boss_requested")) or active_boss):
			reasons.append("boss_window")
	if comment_id == "hard_reignition_boss" and not can_offer_reignition(runtime, maxf(0.0, float(runtime.get("remainingSeconds", 180.0))), int(state.get("activeBossCount", 0))):
		reasons.append("reignition_state")
	var use_counts: Dictionary = _dict(runtime.get("commentUseCounts", {}))
	var max_uses := int(comment.get("maxUsesPerRun", comment.get("maxSelectCountPerRun", 999999)))
	if int(use_counts.get(comment_id, 0)) >= max_uses:
		reasons.append("max_uses")
	if is_boss_comment and int(target.get("boss_summon_count")) >= int(comment.get("maxSelectCountPerRun", max_uses)):
		reasons.append("boss_summon_limit")
	var active_genre := String(target.get("active_genre_event"))
	var collab_active := String(target.get("collab_challenge_status")) in ["starting", "active"]
	if comment_id in ["hard_overclock", "hard_pressure_wave", "talk_comment_avalanche", "game_genre_mix"] and active_boss:
		reasons.append("boss_event")
	if comment_id == "hard_overclock" and (collab_active or active_genre != ""):
		reasons.append("event_conflict")
	if comment_id == "hard_pressure_wave" and collab_active:
		reasons.append("collab_conflict")
	if comment_id == "talk_comment_avalanche" and active_genre != "":
		reasons.append("stage_event")
	if comment_id == "game_genre_mix" and (active_genre != "" or collab_active or maxf(0.0, float(runtime.get("remainingSeconds", 180.0))) < float(comment.get("minRemainingSeconds", 25.0))):
		reasons.append("genre_event")
	var requested_danger := _danger_categories_for_comment(comment)
	var blocked_danger := _array(comment.get("blockedDangerCategories", []))
	if not requested_danger.is_empty() and not DangerEventSystemScript.can_start_categories(_dict(runtime.get("dangerCategories", {})), requested_danger, blocked_danger):
		reasons.append("danger_conflict")
	return {"allowed": reasons.is_empty(), "reasons": reasons}

static func _danger_categories_for_comment(comment: Dictionary) -> Array:
	var result: Array = []
	for raw in comment_categories(comment):
		var category := DangerEventSystemScript.normalize_category(String(raw))
		if DangerEventSystemScript.CATEGORIES.has(category):
			result.append(category)
	return result

static func _comment_available(comment: Dictionary, runtime: Dictionary, elapsed: float, _last_id: String, target: Node) -> bool:
	return bool(comment_evaluation(comment, runtime, elapsed, target).get("allowed", false))

static func _categories_allowed(selected: Array, candidate: Dictionary) -> bool:
	var candidate_categories := comment_categories(candidate)
	var counts: Dictionary = {}
	for item in selected:
		var current: Dictionary = item as Dictionary
		for category in comment_categories(current):
			counts[String(category)] = int(counts.get(String(category), 0)) + 1
	for category in candidate_categories:
		var cap := 2
		if String(category) in ["control_restriction", "visibility", "stage_major_event", "boss", "compound", "hard_wave", "projectile_pressure", "movement_hazard"]:
			cap = 1
		if int(counts.get(String(category), 0)) >= cap:
			return false
	if bool(candidate.get("hardOnly", false)):
		for item in selected:
			if bool((item as Dictionary).get("hardOnly", false)):
				return false
	if int(candidate.get("riskLevel", 1)) >= 4:
		for item in selected:
			if int((item as Dictionary).get("riskLevel", 1)) >= 4:
				return false
	return true

static func _reignition_comment() -> Dictionary:
	return {"id": "hard_reignition_boss", "displayName": "再炎上", "description": "倒したボスが強化されて再登場する", "category": "boss", "categories": ["boss"], "riskLevel": 4, "multiplier": 3.0, "scoreRate": 1.45, "duration": 15.0, "minTime": 0.0, "effectType": "hard_reignition_boss", "hardOnly": true, "maxUsesPerRun": 1, "giftHypeOnSelect": 0, "giftHypeOnClear": 0, "deathText": "REIGNITION", "heartVariant": {"params": {"reignitionHpRate": 0.90}}}

static func mark_comment_selected_for_target(target: Node, comment_id: String) -> void:
	var runtime := runtime_for_target(target)
	if runtime.is_empty() or comment_id.is_empty():
		return
	var counts: Dictionary = _dict(runtime.get("commentUseCounts", {}))
	counts[comment_id] = int(counts.get(comment_id, 0)) + 1
	runtime["commentUseCounts"] = counts

static func clear_active_comment_for_target(target: Node) -> void:
	var runtime := runtime_for_target(target)
	if runtime.is_empty():
		return
	var active_comment_id := String(_dict(runtime.get("activeComment", {})).get("id", ""))
	var active: Dictionary = _dict(runtime.get("dangerCategories", {}))
	for key in active.keys():
		if String((active[key] as Dictionary).get("owner", "")) == "hard_comment":
			active.erase(key)
	runtime["dangerCategories"] = active
	if active_comment_id == "talk_comment_avalanche":
		_clear_comment_avalanche(target, runtime)
	if active_comment_id == "hard_pressure_wave":
		runtime["pendingPressureWave"] = {}
	runtime["activeComment"] = {}
	runtime["activeCommentView"] = {}
	runtime["activeCommentViews"] = {}
	runtime["pendingCommentWave"] = {}

static func activate_comment_for_target(target: Node, comment: Dictionary, rng: RandomNumberGenerator = null) -> void:
	var runtime := runtime_for_target(target)
	if runtime.is_empty() or not is_high_difficulty_runtime(runtime) or comment.is_empty():
		return
	clear_active_comment_for_target(target)
	runtime["activeComment"] = comment.duplicate(true)
	runtime["activeCommentView"] = comment.duplicate(true)
	var categories := _danger_categories_for_comment(comment)
	if not categories.is_empty():
		for category in categories:
			DangerEventSystemScript.begin(runtime, String(category), "hard_comment", 40)
	activate_comment_event_for_target(target, comment, rng)

static func activate_comment_event_for_target(target: Node, comment: Dictionary, rng: RandomNumberGenerator = null) -> void:
	var runtime := runtime_for_target(target)
	if runtime.is_empty() or comment.is_empty():
		return
	var comment_id := String(comment.get("id", ""))
	var params: Dictionary = _dict(comment.get("params", {}))
	if comment_id == "hard_pressure_wave":
		var stage_id := normalize_stage(runtime.get("stageId", "zatsudan"))
		var profiles: Dictionary = _dict(_dict(runtime.get("difficultyConfig", {})).get("pressureWaveProfiles", {}))
		var profile: Dictionary = _dict(profiles.get(stage_id, {})).duplicate(true)
		runtime["pendingPressureWave"] = {
			"id": "hard_pressure_wave",
			"stageId": stage_id,
			"state": "queued",
			"requestedAt": float(runtime.get("elapsedSeconds", 0.0)),
			"maxDelay": maxf(0.0, float(params.get("maxDelay", 3.0))),
			"countRate": clampf(float(params.get("countRate", 1.0)), 0.1, 2.0),
			"allowCountReduction": bool(params.get("allowCountReduction", true)),
			"groups": (_array(profile.get("groups", []))).duplicate(true),
			"plannedCount": 0,
			"actualCount": 0
		}
	elif comment_id == "talk_comment_avalanche":
		_start_comment_avalanche(target, runtime, params, rng)

static func _start_comment_avalanche(target: Node, runtime: Dictionary, params: Dictionary, rng: RandomNumberGenerator = null) -> void:
	var arena := Rect2(Vector2.ZERO, Vector2(1600.0, 900.0))
	if target.has_method("_current_arena"):
		arena = target.call("_current_arena") as Rect2
	var comment_count := maxi(1, int(params.get("commentCount", params.get("rowCount", 10))))
	var fallback_duration := maxf(0.1, float(target.get("effect_timer")))
	var event_duration := maxf(0.1, float(params.get("eventDuration", fallback_duration)))
	var avalanche := {
		"active": true,
		"elapsed": 0.0,
		"duration": event_duration,
		"rows": 0,
		"maxActiveComments": comment_count,
		"travelDuration": maxf(1.0, float(params.get("travelDuration", 7.5))),
		"spawnInterval": maxf(0.1, float(params.get("spawnInterval", 0.65))),
		"nextSpawnAt": maxf(0.1, float(params.get("spawnInterval", 0.65))),
		"laneCount": maxi(3, int(params.get("laneCount", 10))),
		"minVisualWidth": maxf(120.0, float(params.get("minVisualWidth", 180.0))),
		"maxVisualWidth": maxf(140.0, float(params.get("maxVisualWidth", 380.0))),
		"visualHeight": maxf(32.0, float(params.get("visualHeight", 46.0))),
		"collisionWidth": maxf(40.0, float(params.get("collisionWidth", 150.0))),
		"pushRate": float(params.get("pushRate", 1.0)),
		"knockbackSpeed": maxf(0.0, float(params.get("knockbackSpeed", 340.0))),
		"knockbackDuration": maxf(0.0, float(params.get("knockbackDuration", 0.20))),
		"knockbackVelocity": Vector2.ZERO,
		"knockbackRemaining": 0.0,
		"moveRate": float(params.get("moveRate", 0.75)),
		"slowDuration": float(params.get("slowDuration", 0.8)),
		"rehitInterval": float(params.get("rehitInterval", 0.6)),
		"playerHitCount": 0,
		"slowRemaining": 0.0,
		"slowRate": 1.0,
		"serial": 0,
		"totalSpawned": 0
	}
	for index in range(comment_count):
		# Seed the first set at different travel positions so the event starts as
		# a scattered comment stream instead of one rigid wall.
		var progress := clampf((float(index) + 0.20) / float(comment_count) * 0.78, 0.0, 0.78)
		_append_comment_avalanche_row(target, avalanche, arena, rng, progress)
	avalanche["rows"] = _comment_avalanche_row_count(target)
	runtime["commentAvalanche"] = avalanche

static func _comment_avalanche_text_pool(target: Node) -> Array[String]:
	var texts: Array[String] = []
	for raw_line in target.get("chat_lines") as Array:
		var text := ChatSystemScript.display_text_for_line(String(raw_line)).strip_edges()
		if text == "":
			continue
		if text.length() > 30:
			text = text.left(30) + "…"
		if not texts.has(text):
			texts.append(text)
	if texts.is_empty():
		texts.append("コメント欄が加速中！")
	return texts

static func _comment_avalanche_row_count(target: Node) -> int:
	var count := 0
	for item in target.get("hit_fx") as Array:
		if item is Dictionary and String((item as Dictionary).get("kind", "")) == "hard_comment_avalanche_row":
			count += 1
	return count

static func _comment_avalanche_spawn_y(target: Node, arena: Rect2, rng: RandomNumberGenerator, serial: int, lane_count: int) -> float:
	var top := arena.position.y + 34.0
	var bottom := arena.end.y - 34.0
	var lane_step := (bottom - top) / maxf(1.0, float(lane_count - 1))
	var best_y := top + lane_step * float(serial % lane_count)
	var best_spacing := -1.0
	for attempt in range(5):
		var lane := posmod(serial * 7 + attempt * 3, lane_count)
		if rng != null:
			lane = rng.randi_range(0, lane_count - 1)
		var jitter := rng.randf_range(-18.0, 18.0) if rng != null else 0.0
		var candidate := clampf(top + lane_step * float(lane) + jitter, top, bottom)
		var spacing := INF
		for item in target.get("hit_fx") as Array:
			if item is Dictionary and String((item as Dictionary).get("kind", "")) == "hard_comment_avalanche_row":
				spacing = minf(spacing, absf(candidate - Vector2((item as Dictionary).get("pos", Vector2.ZERO)).y))
		if spacing > best_spacing:
			best_spacing = spacing
			best_y = candidate
	return best_y

static func _append_comment_avalanche_row(target: Node, avalanche: Dictionary, arena: Rect2, rng: RandomNumberGenerator, initial_progress: float = 0.0) -> void:
	var serial := int(avalanche.get("serial", 0))
	var direction := -1.0 if rng != null and rng.randf() < 0.5 else 1.0
	var text_pool := _comment_avalanche_text_pool(target)
	var used_texts: Dictionary = {}
	for item in target.get("hit_fx") as Array:
		if item is Dictionary and String((item as Dictionary).get("kind", "")) == "hard_comment_avalanche_row":
			used_texts[String((item as Dictionary).get("text", ""))] = true
	var available_texts: Array[String] = []
	for text in text_pool:
		if not used_texts.has(text):
			available_texts.append(text)
	if available_texts.is_empty():
		available_texts = text_pool
	var text_index := posmod(serial, available_texts.size())
	if rng != null:
		text_index = rng.randi_range(0, available_texts.size() - 1)
	var text := available_texts[text_index]
	var min_width := float(avalanche.get("minVisualWidth", 180.0))
	var max_width := maxf(min_width, float(avalanche.get("maxVisualWidth", 380.0)))
	var visual_width := clampf(60.0 + float(text.length()) * 16.0, min_width, max_width)
	var visual_height := float(avalanche.get("visualHeight", 46.0))
	var travel_duration := float(avalanche.get("travelDuration", 7.5))
	var travel_distance := arena.size.x + visual_width + 80.0
	var start_x := arena.position.x - visual_width * 0.5 - 40.0 if direction > 0.0 else arena.end.x + visual_width * 0.5 + 40.0
	var progress := clampf(initial_progress, 0.0, 0.90)
	var y := _comment_avalanche_spawn_y(target, arena, rng, serial, int(avalanche.get("laneCount", 10)))
	var row := {
		"kind": "hard_comment_avalanche_row",
		"rowId": serial,
		"pos": Vector2(start_x + direction * travel_distance * progress, y),
		"vel": Vector2(direction * travel_distance / travel_duration, 0.0),
		"life": travel_duration * (1.0 - progress),
		"maxLife": travel_duration,
		"age": travel_duration * progress,
		"width": visual_width,
		"height": visual_height,
		"collisionWidth": float(avalanche.get("collisionWidth", 150.0)),
		"nextHitAt": 0.0,
		"direction": direction,
		"pushRate": float(avalanche.get("pushRate", 1.0)),
		"knockbackSpeed": float(avalanche.get("knockbackSpeed", 340.0)),
		"knockbackDuration": float(avalanche.get("knockbackDuration", 0.20)),
		"moveRate": float(avalanche.get("moveRate", 0.75)),
		"slowDuration": float(avalanche.get("slowDuration", 0.8)),
		"rehitInterval": float(avalanche.get("rehitInterval", 0.6)),
		"paletteIndex": serial % 4,
		"text": text
	}
	(target.get("hit_fx") as Array).append(row)
	avalanche["serial"] = serial + 1
	avalanche["totalSpawned"] = int(avalanche.get("totalSpawned", 0)) + 1

static func update_comment_avalanche_for_target(target: Node, delta: float, rng: RandomNumberGenerator = null) -> void:
	var runtime := runtime_for_target(target)
	var avalanche: Dictionary = _dict(runtime.get("commentAvalanche", {}))
	if avalanche.is_empty() or not bool(avalanche.get("active", false)):
		return
	var elapsed_now := float(runtime.get("elapsedSeconds", 0.0))
	avalanche["elapsed"] = float(avalanche.get("elapsed", 0.0)) + maxf(0.0, delta)
	avalanche["slowRemaining"] = maxf(0.0, float(avalanche.get("slowRemaining", 0.0)) - maxf(0.0, delta))
	var knockback_remaining := maxf(0.0, float(avalanche.get("knockbackRemaining", 0.0)) - maxf(0.0, delta))
	var knockback_velocity := Vector2(avalanche.get("knockbackVelocity", Vector2.ZERO))
	if knockback_remaining > 0.0:
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, minf(1.0, maxf(0.0, delta) * 8.0))
	else:
		knockback_velocity = Vector2.ZERO
	avalanche["knockbackRemaining"] = knockback_remaining
	avalanche["knockbackVelocity"] = knockback_velocity
	if float(avalanche.get("elapsed", 0.0)) >= float(avalanche.get("duration", 15.0)):
		_clear_comment_avalanche(target, runtime)
		return
	var arena := Rect2(Vector2.ZERO, Vector2(1600.0, 900.0))
	if target.has_method("_current_arena"):
		arena = target.call("_current_arena") as Rect2
	var active_rows := _comment_avalanche_row_count(target)
	var max_active := int(avalanche.get("maxActiveComments", 10))
	var next_spawn_at := float(avalanche.get("nextSpawnAt", 0.0))
	var spawn_interval := float(avalanche.get("spawnInterval", 0.65))
	while active_rows < max_active and float(avalanche.get("elapsed", 0.0)) >= next_spawn_at:
		_append_comment_avalanche_row(target, avalanche, arena, rng)
		active_rows += 1
		next_spawn_at += spawn_interval
	avalanche["nextSpawnAt"] = next_spawn_at
	avalanche["rows"] = active_rows
	var player_pos := Vector2(target.get("player_pos"))
	var hit_fx: Array = target.get("hit_fx") as Array
	for item in hit_fx:
		var row: Dictionary = item as Dictionary
		if String(row.get("kind", "")) != "hard_comment_avalanche_row":
			continue
		row["age"] = float(row.get("age", 0.0)) + maxf(0.0, delta)
		row["pos"] = Vector2(row.get("pos", Vector2.ZERO)) + Vector2(row.get("vel", Vector2.ZERO)) * maxf(0.0, delta)
		var row_pos := Vector2(row.get("pos", Vector2.ZERO))
		var half_size := Vector2(float(row.get("collisionWidth", 150.0)) * 0.5, float(row.get("height", 46.0)) * 0.5)
		if absf(row_pos.x - player_pos.x) > half_size.x + 22.0 or absf(row_pos.y - player_pos.y) > half_size.y + 24.0:
			continue
		if elapsed_now < float(row.get("nextHitAt", 0.0)):
			continue
		var direction := float(row.get("direction", avalanche.get("direction", 1.0)))
		var push_rate := float(row.get("pushRate", 1.0))
		var knockback_speed := float(row.get("knockbackSpeed", 340.0))
		var impulse := Vector2(direction, 0.0) * knockback_speed * push_rate
		var combined_knockback := Vector2(avalanche.get("knockbackVelocity", Vector2.ZERO)) + impulse
		var max_knockback_speed := maxf(knockback_speed, knockback_speed * 1.40)
		if combined_knockback.length() > max_knockback_speed:
			combined_knockback = combined_knockback.normalized() * max_knockback_speed
		avalanche["knockbackVelocity"] = combined_knockback
		avalanche["knockbackRemaining"] = maxf(float(avalanche.get("knockbackRemaining", 0.0)), float(row.get("knockbackDuration", 0.20)))
		row["nextHitAt"] = elapsed_now + maxf(0.05, float(row.get("rehitInterval", 0.6)))
		avalanche["slowRemaining"] = maxf(float(avalanche.get("slowRemaining", 0.0)), float(row.get("slowDuration", 0.8)))
		avalanche["slowRate"] = minf(float(avalanche.get("slowRate", 1.0)), float(row.get("moveRate", 0.75)))
		avalanche["playerHitCount"] = int(avalanche.get("playerHitCount", 0)) + 1
	runtime["commentAvalanche"] = avalanche

static func _clear_comment_avalanche(target: Node, runtime: Dictionary) -> void:
	var hit_fx: Array = target.get("hit_fx") as Array
	for index in range(hit_fx.size() - 1, -1, -1):
		if hit_fx[index] is Dictionary and String((hit_fx[index] as Dictionary).get("kind", "")) == "hard_comment_avalanche_row":
			hit_fx.remove_at(index)
	for category in ["stage_major_event", "movement_hazard"]:
		DangerEventSystemScript.end(runtime, category, "hard_comment")
	runtime["commentAvalanche"] = {}

static func comment_move_rate_for_target(target: Node) -> float:
	var runtime := runtime_for_target(target)
	var avalanche: Dictionary = _dict(runtime.get("commentAvalanche", {}))
	if bool(avalanche.get("active", false)) and float(avalanche.get("slowRemaining", 0.0)) > 0.0:
		return clampf(float(avalanche.get("slowRate", 1.0)), 0.1, 1.0)
	return 1.0

static func clear_hard_comment_events_for_target(target: Node, _reason: String = "") -> void:
	var runtime := runtime_for_target(target)
	if runtime.is_empty():
		return
	for category in ["stage_major_event", "high_density", "movement_hazard"]:
		DangerEventSystemScript.end(runtime, category, "hard_comment")
	_clear_comment_avalanche(target, runtime)
	runtime["pendingPressureWave"] = {}
	runtime["lastPressureWave"] = {}
	runtime["pendingCommentWave"] = {}

static func _should_offer_hard_do_everything(target: Node, runtime: Dictionary, elapsed: float, selected: Array, comments: Array, rng: RandomNumberGenerator) -> bool:
	if rng == null or selected.size() != 3:
		return false
	var special := _find_comment_by_id(comments, "do_everything")
	if special.is_empty() or elapsed < float(special.get("minTime", 60.0)):
		return false
	if int(target.get("do_everything_offer_count")) >= int(special.get("maxOfferCountPerRun", 1)):
		return false
	if bool(target.get("boss_requested")) or bool(target.get("boss_active")) or String(runtime.get("playMode", SINGLE)) != SINGLE:
		return false
	for item in selected:
		var id := String((item as Dictionary).get("id", ""))
		if COMMENT_FORBIDDEN_IN_REGULAR_HARD_SPECIAL.has(id):
			return false
	if rng.randf() >= float(_dict(_dict(runtime.get("difficultyConfig", {})).get("commentComposer", {})).get("doEverythingChance", 0.05)):
		return false
	return true

static func _record_comment_offer(runtime: Dictionary, offer: Array, cycle: int) -> void:
	var ids: Array = []
	var cooldowns: Dictionary = _dict(runtime.get("commentCategoryCooldowns", {}))
	var comment_cooldowns: Dictionary = _dict(runtime.get("commentCooldowns", {}))
	var configured: Dictionary = _dict(_dict(runtime.get("difficultyConfig", {})).get("commentComposer", {}))
	var cooldown_config: Dictionary = _dict(configured.get("categoryCooldownCycles", COMMENT_CATEGORY_COOLDOWN_CYCLES))
	for item in offer:
		if not item is Dictionary:
			continue
		var comment: Dictionary = item as Dictionary
		var id := String(comment.get("id", ""))
		if id.is_empty():
			continue
		ids.append(id)
		var offer_cooldown := int(comment.get("offerCooldownCycles", 0))
		if offer_cooldown > 0:
			comment_cooldowns[id] = cycle + offer_cooldown + 1
		for category in comment_categories(comment):
			var cycles := int(cooldown_config.get(String(category), 0))
			if cycles > 0:
				cooldowns[String(category)] = cycle + cycles + 1
	runtime["commentOfferHistory"] = ids
	runtime["commentCategoryCooldowns"] = cooldowns
	runtime["commentCooldowns"] = comment_cooldowns

static func _comment_debug_views(comments: Array) -> Array:
	var result: Array = []
	for item in comments:
		if not item is Dictionary:
			continue
		var comment: Dictionary = item as Dictionary
		result.append({"id": String(comment.get("id", "")), "risk": int(comment.get("riskLevel", 1)), "categories": comment_categories(comment), "hardOnly": bool(comment.get("hardOnly", false))})
	return result

static func _count_hard_only(comments: Array) -> int:
	var count := 0
	for item in comments:
		if item is Dictionary and bool((item as Dictionary).get("hardOnly", false)):
			count += 1
	return count

static func _count_danger4_plus(comments: Array) -> int:
	var count := 0
	for item in comments:
		if item is Dictionary and int((item as Dictionary).get("riskLevel", 1)) >= 4:
			count += 1
	return count

static func _phase_rate(phases: Array, elapsed: float, fallback: float) -> float:
	for item in phases:
		var phase: Dictionary = item as Dictionary
		if elapsed >= float(phase.get("start", 0.0)) and elapsed < float(phase.get("end", INF)):
			return float(phase.get("rate", fallback))
	return fallback if phases.is_empty() else float((phases.back() as Dictionary).get("rate", fallback))

static func _dict(value: Variant) -> Dictionary:
	return value as Dictionary if value is Dictionary else {}

static func _array(value: Variant) -> Array:
	return value as Array if value is Array else []

static func _dict_array(value: Variant) -> Array:
	var result: Array = []
	if not value is Array:
		return result
	for item in value as Array:
		if item is Dictionary:
			result.append(item)
	return result

static func _deep_merge(base: Dictionary, overlay: Dictionary) -> Dictionary:
	var result := base.duplicate(true)
	for key in overlay.keys():
		var value: Variant = overlay[key]
		if value is Dictionary and result.get(key) is Dictionary:
			result[key] = _deep_merge(result[key] as Dictionary, value as Dictionary)
		else:
			result[key] = value
	return result

static func _find_comment_by_id(comments: Array, id: String) -> Dictionary:
	for item in comments:
		if item is Dictionary and String((item as Dictionary).get("id", "")) == id:
			return (item as Dictionary).duplicate(true)
	return {}
