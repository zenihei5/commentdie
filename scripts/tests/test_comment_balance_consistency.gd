extends Node

const HardMode := preload("res://scripts/systems/hard_mode_system.gd")
const Comment := preload("res://scripts/systems/comment_system.gd")
const Balance := preload("res://scripts/systems/comment_balance_system.gd")
const Modifier := preload("res://scripts/systems/modifier_system.gd")
const Repository := preload("res://scripts/systems/data_repository.gd")
const Enemy := preload("res://scripts/systems/enemy_system.gd")
const Collab := preload("res://scripts/systems/collab_challenge_system.gd")

var failures: Array[String] = []

func _ready() -> void:
	_test_text_overrides()
	_test_heart_benefits_and_variants()
	_test_do_everything_sub_views()
	_test_hard_partner_override()
	_test_corrected_runtime_values()
	_test_reignition_hp_reference()
	_test_removed_legacy_profiles()
	_test_collab_challenge_profiles()
	_test_drawing_more_corrections_matrix()
	_test_heart_presentation_state()
	_test_duplicate_param_sources()
	_test_removed_hard_support_comments()
	if failures.is_empty():
		print("COMMENT_BALANCE_CONSISTENCY_TESTS: PASS")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("COMMENT_BALANCE_CONSISTENCY_TESTS: FAIL (%d)" % failures.size())
	get_tree().quit(1)

func _test_text_overrides() -> void:
	var expected := {
		"hard_overclock": "敵の攻撃が激しくなる",
		"hard_pressure_wave": "いろんな敵が一気に押し寄せる",
		"talk_comment_avalanche": "流れるコメントに押し流される",
		"game_genre_mix": "短いジャンル変化が2回続く",
		"drawing_fast_dry": "線がすぐ消える",
		"drawing_too_much_paint": "線が太くなり絵具消費が増える",
		"drawing_more_corrections": "修正指示と報酬が増える",
		"drawing_spilled_bucket": "汚れが出現・踏むと減速"
	}
	var loaded_comments: Array = Repository.loaded().comments
	for item_id in expected.keys():
		var raw := _comment_from_data(String(item_id))
		var normalized := Balance.normalize_comment(raw)
		_check(String(normalized.get("description", "")) == String(expected[item_id]), "%s description" % item_id)
		var normal_view := Comment.comment_view(raw, false)
		var heart_view := Comment.comment_view(raw, true)
		_check(String(normal_view.get("description", "")) == String(expected[item_id]), "%s normal view text" % item_id)
		_check(String(heart_view.get("description", "")) == String(expected[item_id]), "%s heart view text" % item_id)
		for loaded_value in loaded_comments:
			if loaded_value is Dictionary and String((loaded_value as Dictionary).get("id", "")) == String(item_id):
				_check(String((loaded_value as Dictionary).get("description", "")) == String(expected[item_id]), "%s repository text" % item_id)
				break

func _test_heart_benefits_and_variants() -> void:
	var base := {
		"id": "synthetic_benefit",
		"displayName": "利益",
		"description": "効果",
		"riskLevel": 4,
		"multiplier": 3.0,
		"scoreRate": 1.4,
		"giftHypeOnSelect": 35,
		"giftHypeOnClear": 17,
		"deathText": "失敗",
		"params": {"damage": 1.0},
		"heartVariant": {
			"riskLevel": 3,
			"multiplier": 2.0,
			"scoreRate": 0.8,
			"giftHypeOnSelect": 10,
			"giftHypeOnClear": 5,
			"params": {"damage": 0.7}
		}
	}
	var heart := Comment.comment_view(base, true)
	_check(float(heart.get("multiplier", 0.0)) >= 3.0, "heart keeps multiplier benefit")
	_check(float(heart.get("scoreRate", 0.0)) >= 1.4, "heart keeps score benefit")
	_check(int(heart.get("giftHypeOnSelect", 0)) >= 35 and int(heart.get("giftHypeOnClear", 0)) >= 17, "heart keeps gift benefits")
	_check(float((heart.get("params", {}) as Dictionary).get("damage", 0.0)) < 1.0, "heart may soften penalty params")
	var special := Comment.comment_view({"id": "do_everything", "displayName": "全部", "riskLevel": 5, "multiplier": 5.0, "giftHypeOnSelect": 70, "giftHypeOnClear": 30, "deathText": "全部"}, true)
	_check(int(special.get("riskLevel", 0)) == 5 and is_equal_approx(float(special.get("multiplier", 0.0)), 5.0), "do everything heart risk and multiplier")
	_check(int(special.get("giftHypeOnSelect", 0)) == 70 and int(special.get("giftHypeOnClear", 0)) == 30, "do everything heart reward benefit preserved")
	var boss := Comment.comment_view(_comment_from_data("summon_boss"), true)
	_check(not (boss.get("params", {}) as Dictionary).has("bossRewardRate"), "heart boss does not decay reward")
	var pass_view := Comment.comment_view(_comment_from_data("fast_collab_pass"), true)
	_check(String(pass_view.get("description", "")) == "コラボパスが4秒制限", "heart pass description matches four-second limit")
	_check(is_equal_approx(float((pass_view.get("params", {}) as Dictionary).get("passDuration", 0.0)), 4.0), "heart pass duration is four seconds")
	var lyrics_view := Comment.comment_view(_comment_from_data("song_lyrics_lost"), true)
	_check(is_equal_approx(float(lyrics_view.get("duration", 0.0)), 10.0), "heart lyrics duration is shortened")
	_check(is_equal_approx(Modifier._effect_duration_for_target(null, lyrics_view), 10.0), "live effect duration uses resolved heart view")

func _test_do_everything_sub_views() -> void:
	var sub_comments: Array = [
		_comment_from_data("hard_overclock"),
		_comment_from_data("game_genre_mix"),
		_comment_from_data("fast_collab_pass")
	]
	var activation := Modifier.build_activation({"id": "do_everything"}, true, RandomNumberGenerator.new(), sub_comments, [true, false, true])
	var effects: Array = activation.get("effects", []) as Array
	var rates: Dictionary = activation.get("rates", {}) as Dictionary
	_check(effects == ["hard_overclock", "game_genre_mix", "fast_collab_pass"], "do everything activates all three source cards")
	_check(is_equal_approx(float(rates.get("hard_overclock", 0.0)), 0.70), "do everything applies first heart rate")
	_check(is_equal_approx(float(rates.get("game_genre_mix", 0.0)), 1.0), "do everything preserves non-heart source rate")
	_check(is_equal_approx(float(rates.get("fast_collab_pass", 0.0)), 0.70), "do everything applies third heart rate")
	var runtime := HardMode.build_runtime("hard", false, "gameplay", _json_dictionary("res://data/difficulty_modes.json"), {})
	runtime["activeComment"] = {"id": "do_everything"}
	runtime["activeCommentViews"] = {
		"hard_overclock": Comment.comment_view(sub_comments[0] as Dictionary, true),
		"game_genre_mix": Comment.comment_view(sub_comments[1] as Dictionary, false),
		"fast_collab_pass": Comment.comment_view(sub_comments[2] as Dictionary, true)
	}
	_check(HardMode.active_comment_id_is_active(runtime, "hard_overclock"), "do everything hard sub is active")
	_check(is_equal_approx(HardMode.active_comment_param_for_id(runtime, "hard_overclock", "attackIntervalRate", 1.0), 0.90), "do everything uses hard sub view")
	_check(is_equal_approx(HardMode.active_comment_param_for_id(runtime, "fast_collab_pass", "passDuration", 0.0), 4.0), "do everything uses collab sub heart view")

func _test_hard_partner_override() -> void:
	var source := _json_dictionary("res://data/difficulty_modes.json")
	var runtime := HardMode.build_runtime("hard", false, "zatsudan", source, {})
	var resolved := HardMode.resolve_comment(_comment_from_data("partner_take_over"), runtime)
	var params: Dictionary = resolved.get("params", {}) as Dictionary
	_check(is_equal_approx(float(params.get("playerWeaponDamageMultiplier", 0.0)), 0.40), "HARD partner player damage override")
	_check(is_equal_approx(float(params.get("partnerDamageMultiplier", 0.0)), 2.0), "partner benefit stays x2")
	_check(is_equal_approx(float(params.get("partnerAttackIntervalMultiplier", 0.0)), 0.70), "HARD partner interval override")
	var heart := Comment.comment_view(resolved, true)
	var heart_params: Dictionary = heart.get("params", {}) as Dictionary
	_check(is_equal_approx(float(heart_params.get("playerWeaponDamageMultiplier", 0.0)), 0.70), "HARD heart player damage override")
	_check(is_equal_approx(float(heart_params.get("partnerDamageMultiplier", 0.0)), 2.0), "HARD heart partner benefit stays x2")
	_check(is_equal_approx(float(heart_params.get("partnerAttackIntervalMultiplier", 0.0)), 0.70), "HARD heart partner interval")

func _test_corrected_runtime_values() -> void:
	var source := _json_dictionary("res://data/difficulty_modes.json")
	var hard_runtime := HardMode.build_runtime("hard", false, "zatsudan", source, {})
	var normal_runtime := HardMode.build_runtime("normal", false, "zatsudan", source, {})
	var normal_takeback := Comment.comment_view(_comment_from_data("takeback"), false)
	normal_runtime["activeComment"] = normal_takeback
	_check(is_equal_approx(HardMode.active_comment_param_for_id(normal_runtime, "takeback", "takebackRate", 1.0), 1.0), "NORMAL takeback direction randomization is 100 percent")
	var heart_takeback := Comment.comment_view(HardMode.resolve_comment(_comment_from_data("takeback"), hard_runtime), true)
	hard_runtime["activeComment"] = heart_takeback
	_check(is_equal_approx(HardMode.active_comment_param_for_id(hard_runtime, "takeback", "takebackRate", 1.0), 0.70), "heart takeback direction randomization is 70 percent")
	var heart_keep_sync := Comment.comment_view(HardMode.resolve_comment(_comment_from_data("keep_sync"), hard_runtime), true)
	hard_runtime["activeComment"] = heart_keep_sync
	_check(is_equal_approx(HardMode.active_comment_param_for_id(hard_runtime, "keep_sync", "starLossCooldown", 1.0), 4.0), "HARD heart keep sync explicitly prefers four second cooldown")
	var base_enemy := Enemy.enemy_data("troll")
	var normal_giant := Enemy.build_enemy("troll", Vector2.ZERO, 1, 1.0, 1.0)
	_check(is_equal_approx(float(normal_giant.get("hp", 0.0)) / float(base_enemy.get("hp", 1.0)), 1.50) and is_equal_approx(float(normal_giant.get("radius", 0.0)) / float(base_enemy.get("radius", 1.0)), 2.00), "NORMAL giant enemy fallback rates")
	var heart_giant_view := Comment.comment_view(HardMode.resolve_comment(_comment_from_data("giant_enemies"), hard_runtime), true)
	var heart_giant_params: Dictionary = heart_giant_view.get("params", {}) as Dictionary
	var heart_giant := Enemy.build_enemy("troll", Vector2.ZERO, 2, 1.0, 1.0, "", float(heart_giant_params.get("giantHpRate", 0.0)), float(heart_giant_params.get("giantRadiusRate", 0.0)))
	_check(is_equal_approx(float(heart_giant.get("hp", 0.0)) / float(base_enemy.get("hp", 1.0)), 1.35) and is_equal_approx(float(heart_giant.get("radius", 0.0)) / float(base_enemy.get("radius", 1.0)), 1.70), "heart giant enemy explicit rates")

func _test_reignition_hp_reference() -> void:
	var source := _json_dictionary("res://data/difficulty_modes.json")
	var runtime := HardMode.build_runtime("hard", false, "zatsudan", source, {})
	var first := {"kind": "test_boss", "bossId": "test_boss", "max_hp": 100.0, "hp": 100.0, "speed": 20.0, "contactDamage": 10, "bossAttackIntervalRate": 1.0, "bossAttackTimers": {}}
	HardMode.apply_boss_runtime_stats(first, runtime, "firstHardBoss")
	var first_final_hp := float(first.get("max_hp", 0.0))
	runtime["activeComment"] = {"id": "hard_reignition_boss", "params": {}}
	var second := {"kind": "test_boss", "bossId": "test_boss", "max_hp": 100.0, "hp": 100.0, "speed": 20.0, "contactDamage": 10, "bossAttackIntervalRate": 1.0, "bossAttackTimers": {}}
	HardMode.apply_boss_runtime_stats(second, runtime, "reignition")
	_check(is_equal_approx(float(second.get("max_hp", 0.0)), first_final_hp * 1.10), "reignition uses first HARD final HP")
	runtime["activeComment"] = {"id": "hard_reignition_boss", "params": {"reignitionHpRate": 0.90}}
	var heart_second := {"kind": "test_boss", "bossId": "test_boss", "max_hp": 100.0, "hp": 100.0, "speed": 20.0, "contactDamage": 10, "bossAttackIntervalRate": 1.0, "bossAttackTimers": {}}
	HardMode.apply_boss_runtime_stats(heart_second, runtime, "reignition")
	_check(is_equal_approx(float(heart_second.get("max_hp", 0.0)), first_final_hp * 1.10 * 0.90), "reignition heart softens only applicable HP")

func _test_removed_legacy_profiles() -> void:
	var hard_text := FileAccess.get_file_as_string("res://scripts/systems/hard_mode_system.gd")
	var data_text := FileAccess.get_file_as_string("res://data/difficulty_modes.json")
	_check(not hard_text.contains("forcedChorusProfile") and not hard_text.contains("hard_short"), "legacy forced chorus profiles removed")
	_check(not data_text.contains("forcedChorusProfile") and not data_text.contains("hard_short"), "legacy profile data removed")
	_check(not data_text.contains("partnerDamageMultiplier\\\": 1.10"), "legacy partner final multiplier removed")

func _test_collab_challenge_profiles() -> void:
	var expected := {
		"collab_chain": {"required": 4, "highDuration": 12.0, "heartDuration": 14.0},
		"comment_catch": {"required": 5, "spawn": 7, "highDuration": 8.0, "heartDuration": 9.0, "highPickup": 42.0, "heartPickup": 48.0},
		"dash_sync": {"required": 3, "highDuration": 8.0, "heartDuration": 9.0, "highWindow": 0.40, "heartWindow": 0.48},
		"thumbnail_time": {"required": 3, "highDuration": 8.0, "heartDuration": 9.0, "highSpeed": 28.0, "heartSpeed": 32.0, "highDistance": 8.0, "heartDistance": 10.0},
		"troll_focus": {"highDuration": 8.0, "heartDuration": 9.0, "highHp": 40.0, "heartHp": 36.0, "speed": 48.0, "contactDamage": 5},
		"line_defense": {"highDuration": 10.0, "heartDuration": 9.0, "highSuccessHp": 70.0, "heartSuccessHp": 60.0, "terminalHp": 100.0, "initialEnemies": 3, "maxEnemies": 6, "replenish": 1.65, "enemyHp": 18.0, "enemySpeed": 62.0, "terminalDamage": 10.0}
	}
	for raw_type in expected.keys():
		var challenge_type := String(raw_type)
		var high := Collab.challenge_parameters(challenge_type, Collab.PROFILE_HIGH)
		var heart_high := Collab.challenge_parameters(challenge_type, Collab.PROFILE_HEART_HIGH)
		var values: Dictionary = expected[challenge_type] as Dictionary
		_check(int(high.get("required", values.get("required", 1))) == int(values.get("required", int(high.get("required", 1)))), "%s high required" % challenge_type)
		_check(is_equal_approx(float(high.get("duration", 0.0)), float(values.get("highDuration", 0.0))) and is_equal_approx(float(heart_high.get("duration", 0.0)), float(values.get("heartDuration", 0.0))), "%s profile duration" % challenge_type)
		if challenge_type == "comment_catch":
			_check(int(high.get("spawn", 0)) == 7 and int(heart_high.get("spawn", 0)) == 7 and is_equal_approx(float(high.get("pickupRadius", 0.0)), 42.0) and is_equal_approx(float(heart_high.get("pickupRadius", 0.0)), 48.0), "comment catch target and radius")
		elif challenge_type == "dash_sync":
			_check(int(high.get("required", 0)) == 3 and int(heart_high.get("required", 0)) == 3, "dash sync required progress is 3 for high and heart_high")
			_check(is_equal_approx(float(high.get("duration", 0.0)), 8.0) and is_equal_approx(float(heart_high.get("duration", 0.0)), 9.0), "dash sync durations are 8 and 9 seconds")
			_check(is_equal_approx(float(high.get("inputWindow", 0.0)), 0.40) and is_equal_approx(float(heart_high.get("inputWindow", 0.0)), 0.48), "dash sync input windows are 0.40 and 0.48 seconds")
		elif challenge_type == "thumbnail_time":
			_check(is_equal_approx(float(high.get("maxSpeed", 0.0)), 28.0) and is_equal_approx(float(heart_high.get("maxSpeed", 0.0)), 32.0) and is_equal_approx(float(high.get("maxDistance", 0.0)), 8.0) and is_equal_approx(float(heart_high.get("maxDistance", 0.0)), 10.0), "thumbnail limits")
		elif challenge_type == "troll_focus":
			_check(is_equal_approx(float(high.get("hp", 0.0)), 40.0) and is_equal_approx(float(heart_high.get("hp", 0.0)), 36.0) and is_equal_approx(float(high.get("speed", 0.0)), 48.0) and int(high.get("contactDamage", 0)) == 5, "troll profile values")
		elif challenge_type == "line_defense":
			_check(is_equal_approx(float(high.get("successTerminalHp", 0.0)), 70.0) and is_equal_approx(float(heart_high.get("successTerminalHp", 0.0)), 60.0) and is_equal_approx(float(high.get("terminalHp", 0.0)), 100.0) and int(high.get("initialEnemies", 0)) == 3 and int(high.get("maxEnemies", 0)) == 6 and is_equal_approx(float(high.get("replenishInterval", 0.0)), 1.65) and is_equal_approx(float(heart_high.get("replenishInterval", 0.0)), 1.65) and is_equal_approx(float(high.get("enemyHp", 0.0)), 18.0) and is_equal_approx(float(high.get("enemySpeed", 0.0)), 62.0) and is_equal_approx(float(high.get("terminalDamage", 0.0)), 10.0), "line defense resolved enemy and terminal values")
	var standard_comment := Collab.challenge_parameters("comment_catch", Collab.PROFILE_STANDARD)
	var standard_dash := Collab.challenge_parameters("dash_sync", Collab.PROFILE_STANDARD)
	var standard_troll := Collab.challenge_parameters("troll_focus", Collab.PROFILE_STANDARD)
	var standard_line := Collab.challenge_parameters("line_defense", Collab.PROFILE_STANDARD)
	_check(int(standard_comment.get("required", 0)) == 5 and is_equal_approx(float(standard_comment.get("duration", 0.0)), 10.0), "standard comment catch remains unchanged")
	_check(int(standard_dash.get("required", 0)) == 2 and is_equal_approx(float(standard_dash.get("inputWindow", 0.0)), 0.60), "standard dash sync remains unchanged")
	_check(is_equal_approx(float(standard_troll.get("hp", 0.0)), 32.0) and is_equal_approx(float(standard_troll.get("duration", 0.0)), 10.0), "standard troll focus remains unchanged")
	_check(is_equal_approx(float(standard_line.get("successTerminalHp", 0.0)), 50.0) and is_equal_approx(float(standard_line.get("replenishInterval", 0.0)), 2.2), "standard line defense remains unchanged")
	var defense_count := 3
	for expected_count in [4, 5, 6, 6]:
		defense_count = Collab.line_defense_replenish_count(defense_count, 6)
		_check(defense_count == expected_count, "line defense replenishes 3 to 4 to 6 and clamps")
	var raw := _comment_from_data("dont_fail_collab")
	var normal_view := Comment.comment_view(raw, false)
	var heart_view := Comment.comment_view(raw, true)
	for difficulty in ["normal", "hard"]:
		_check(Collab.profile_for_comment("dont_fail_collab", normal_view.get("params", {}) as Dictionary) == Collab.PROFILE_HIGH, "%s dont-fail uses high profile" % difficulty)
		_check(Collab.profile_for_comment("dont_fail_collab", heart_view.get("params", {}) as Dictionary) == Collab.PROFILE_HEART_HIGH, "%s heart dont-fail uses heart_high profile" % difficulty)
	_check(is_equal_approx(float(heart_view.get("multiplier", 0.0)), float(normal_view.get("multiplier", 0.0))) and int(heart_view.get("giftHypeOnSelect", 0)) >= int(normal_view.get("giftHypeOnSelect", 0)) and int(heart_view.get("giftHypeOnClear", 0)) >= int(normal_view.get("giftHypeOnClear", 0)), "dont-fail reward benefits are not reduced by heart")

func _test_drawing_more_corrections_matrix() -> void:
	var difficulty_source := _json_dictionary("res://data/difficulty_modes.json")
	var hard_runtime := HardMode.build_runtime("hard", false, "drawing", difficulty_source, {})
	var raw := _comment_from_data("drawing_more_corrections")
	var hard_raw := HardMode.resolve_comment(raw, hard_runtime)
	var normal := Comment.comment_view(raw, false)
	var hard := Comment.comment_view(hard_raw, false)
	var heart := Comment.comment_view(raw, true)
	var hard_heart := Comment.comment_view(hard_raw, true)
	var views: Array[Dictionary] = [normal, hard, heart, hard_heart]
	var expected_bursts := [2, 3, 1, 1]
	for index in range(views.size()):
		var params: Dictionary = views[index].get("params", {}) as Dictionary
		_check(int(params.get("correctionBurst", 0)) == int(expected_bursts[index]), "drawing corrections burst matrix index %d" % index)
		_check(is_equal_approx(float(params.get("correctionRewardMultiplier", 0.0)), 1.20), "drawing corrections reward x1.20 matrix index %d" % index)
	var balance_source := _json_dictionary("res://data/comment_balance_overrides.json")
	_check(not balance_source.has("drawing_more_corrections"), "drawing corrections has one authoritative balance source")
	var hard_mode_text := FileAccess.get_file_as_string("res://scripts/systems/hard_mode_system.gd")
	_check(not hard_mode_text.contains("\"drawing_more_corrections\": {\"params\": {\"correctionBurst\": 3, \"correctionRewardMultiplier\": 1.10}}"), "drawing corrections legacy HARD reward x1.10 removed")

func _test_heart_presentation_state() -> void:
	var missing_before_ids := [
		"no_stop", "no_brake", "enemy_spawn_up", "split_enemy", "hide_hp", "comment_barrage",
		"temp_walls", "damage_pits", "takeback", "genre_change", "force_bullet_hell", "force_race",
		"force_horror", "song_force_chorus", "song_mic_howling", "song_lighting_mistake",
		"song_lyrics_lost", "hard_reignition_boss"
	]
	var sources: Array = _json_array("res://data/comments.json")
	sources.append(HardMode._reignition_comment())
	for item_id in missing_before_ids:
		var raw := _comment_from_array(sources, String(item_id))
		var normal := Comment.comment_view(raw, false)
		var heart := Comment.comment_view(raw, true)
		_check(not bool(normal.get("isHeartVariant", true)), "%s normal heart marker hidden" % item_id)
		_check(bool(heart.get("isHeartVariant", false)), "%s resolved heart marker shown" % item_id)
		_check(not String(heart.get("displayName", "")).ends_with("♡"), "%s heart marker separated from title" % item_id)
	var difficulty_source := _json_dictionary("res://data/difficulty_modes.json")
	var hard_runtime := HardMode.build_runtime("hard", false, "gameplay", difficulty_source, {})
	for item_id in ["hide_hp", "song_force_chorus", "hard_reignition_boss"]:
		var raw := _comment_from_array(sources, String(item_id))
		var hard_heart := Comment.comment_view(HardMode.resolve_comment(raw, hard_runtime), true)
		_check(bool(hard_heart.get("isHeartVariant", false)), "%s HARD heart marker shown" % item_id)
		_check(not String(hard_heart.get("displayName", "")).contains("♡"), "%s HARD heart title stays canonical" % item_id)

func _test_duplicate_param_sources() -> void:
	var removed_keys := {
		"short_range": ["collectRangeRate"],
		"song_mic_howling": ["knockback"],
		"song_lighting_mistake": ["disableNormalWeaponsWhileInside", "disableLiveHeatSupportWhileInside"],
		"song_lyrics_lost": ["spawnLyricsCard", "lyricsCardCount", "pauseScaleCombo", "disableOctaveBonus", "clearOnPickup"],
		"game_genre_mix": ["genreMix"]
	}
	for item_id in removed_keys.keys():
		var raw := _comment_from_data(String(item_id))
		var params: Dictionary = raw.get("params", {}) as Dictionary
		var heart_params: Dictionary = (raw.get("heartVariant", {}) as Dictionary).get("params", {}) as Dictionary
		for key in removed_keys[item_id]:
			_check(not params.has(key) and not heart_params.has(key), "%s duplicate key %s removed from data" % [item_id, key])
	var game_text := FileAccess.get_file_as_string("res://scripts/game.gd")
	var weapon_text := FileAccess.get_file_as_string("res://scripts/systems/weapon_system.gd")
	for key in ["playerMoveSpeedMultiplier", "enemyMoveSpeedMultiplier", "enemySpawnMultiplier", "noteLifetimeMultiplier", "forcedChorusDuration", "forcedChorusEnemySpawnMultiplier", "forcedChorusNoteCountMultiplier", "forcedChorusSpotlightMax", "forcedChorusResultRewardMultiplier", "telegraphDuration", "waveExpandDuration", "waveStartRadius", "waveEndRadius", "badLightRadius", "badLightRespawnDelay", "grayPaintRate", "moveSpeedMultiplier", "slowDuration", "warningDuration", "projectileGraceDuration"]:
		_check(game_text.contains(String(key)), "runtime reads JSON parameter %s" % key)
	for key in ["rangeRate", "areaRate", "searchRate", "explosionAreaRate"]:
		_check(weapon_text.contains(String(key)), "weapon runtime reads JSON parameter %s" % key)
	for constant_name in ["OUT_OF_SYNC_MOVE_SPEED_MULTIPLIER", "OUT_OF_SYNC_SLOW_DURATION", "OUT_OF_SYNC_WARNING_DURATION", "OUT_OF_SYNC_PROJECTILE_GRACE_DURATION", "HOWLING_TELEGRAPH_DURATION", "HOWLING_WAVE_EXPAND_DURATION", "HOWLING_WAVE_START_RADIUS", "HOWLING_WAVE_END_RADIUS", "HOWLING_DAMAGE", "BAD_LIGHT_RADIUS", "BAD_LIGHT_RESPAWN_DELAY", "PALETTE_WEAK_GRAY_RATE"]:
		_check(not game_text.contains(String(constant_name)), "duplicate code constant %s removed" % constant_name)

func _test_removed_hard_support_comments() -> void:
	var difficulty_source := _json_dictionary("res://data/difficulty_modes.json")
	var final_boss: Dictionary = difficulty_source.get("finalBoss", {}) as Dictionary
	_check(not final_boss.has("supportComments"), "unused HARD support comment definitions removed")
	var relay_source := _json_dictionary("res://data/relay_mode.json")
	var relay_boss: Dictionary = relay_source.get("boss", {}) as Dictionary
	var relay_comments: Array = relay_boss.get("comments", []) as Array
	_check(not _comment_from_array(relay_comments, "boss_support_dont_lose").is_empty(), "active relay dont-lose support remains")
	_check(not _comment_from_array(relay_comments, "boss_support_do_your_best").is_empty(), "active relay do-your-best support remains")

func _comment_from_data(item_id: String) -> Dictionary:
	return _comment_from_array(_json_array("res://data/comments.json"), item_id)

func _comment_from_array(source: Array, item_id: String) -> Dictionary:
	for item in source:
		if item is Dictionary and String((item as Dictionary).get("id", "")) == item_id:
			return (item as Dictionary).duplicate(true)
	return {"id": item_id, "description": ""}

func _json_array(path: String) -> Array:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Array if parsed is Array else []

func _json_dictionary(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}

func _check(condition: bool, label: String) -> void:
	if not condition:
		failures.append(label)
