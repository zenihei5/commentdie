extends RefCounted
class_name EnemySystem

const BossSystemScript := preload("res://scripts/systems/boss_system.gd")
const RelayStageProfileSystemScript := preload("res://scripts/systems/relay_stage_profile_system.gd")
const PowerUpRunTrackerScript := preload("res://scripts/systems/power_up_run_tracker.gd")
const HardModeSystemScript := preload("res://scripts/systems/hard_mode_system.gd")
const KNOCKBACK_SPEED_SCALE := 13.0
const KNOCKBACK_DECAY_RATE := 13.0
const KNOCKBACK_STOP_SPEED := 8.0
const KNOCKBACK_MAX_SPEED := 1800.0
const SHOOTER_FIRE_INTERVAL_MIN := 2.35
const SHOOTER_FIRE_INTERVAL_MAX := 2.90
const SHOOTER_BULLET_LIFE := 2.7
const ARMCHAIR_FIRE_INTERVAL_MIN := 2.25
const ARMCHAIR_FIRE_INTERVAL_MAX := 2.85
const ARMCHAIR_BULLET_LIFE := 2.7
const DOT_INVADER_FIRE_INTERVAL_MIN := 1.85
const DOT_INVADER_FIRE_INTERVAL_MAX := 2.45
const DOT_INVADER_BULLET_LIFE := 2.8
const WIKI_FIRE_INTERVAL_MIN := 3.65
const WIKI_FIRE_INTERVAL_MAX := 4.45
const WIKI_BULLET_LIFE := 2.9
const DRONE_FIRE_INTERVAL_MIN := 2.55
const DRONE_FIRE_INTERVAL_MAX := 3.25
const DRONE_BULLET_LIFE := 2.9
static var _spawn_token_serial: int = 0
const DRAWING_MAX_NORMAL_ENEMY_PROJECTILES := 18
const DRAWING_MAX_SHOOTER_ENEMIES := 4
const DRAWING_LATE_MAX_SHOOTER_ENEMIES := 6
const DRAWING_LATE_SHOOTER_TIME := 120.0
const DRAWING_RED_PEN_FIRE_INTERVAL_MIN := 3.8
const DRAWING_RED_PEN_FIRE_INTERVAL_MAX := 4.6
const DRAWING_RED_PEN_PROJECTILE_SPEED := 170.0
const DRAWING_RED_PEN_PROJECTILE_DAMAGE := 5
const DRAWING_RED_PEN_BULLET_LIFE := 3.6
const DRAWING_RED_PEN_PRE_SHOT_WARNING_TIME := 0.45
const DRAWING_RED_PEN_MAX_PROJECTILES_PER_ENEMY := 1
const DRAWING_BUCKET_PUDDLE_INTERVAL := 7.5
const DRAWING_BUCKET_PUDDLE_LIFETIME := 6.0
const DRAWING_BUCKET_PUDDLE_RADIUS := 48.0
const DRAWING_BUCKET_PUDDLE_SLOW_RATE := 0.15
const DRAWING_BUCKET_MAX_PUDDLES_PER_ENEMY := 2
const COLLAB_MESSENGER_DASH_INTERVAL := 4.5
const COLLAB_MESSENGER_DASH_WARNING_DURATION := 0.55
const COLLAB_MESSENGER_DASH_SPEED := 320.0
const COLLAB_MESSENGER_TRAIL_LIFETIME := 2.5
const COLLAB_MESSENGER_TRAIL_WIDTH := 38.0
const COLLAB_DISCORD_PULSE_INTERVAL := 5.0
const COLLAB_DISCORD_PULSE_WARNING_DURATION := 0.6
const COLLAB_DISCORD_PULSE_RADIUS := 190.0
const COLLAB_VOLUME_FIELD_INTERVAL := 7.0
const COLLAB_VOLUME_FIELD_WARNING_DURATION := 0.7
const COLLAB_VOLUME_FIELD_RADIUS := 135.0
const COLLAB_VOLUME_FIELD_LIFETIME := 5.0
const COLLAB_EXCLUSIVE_ATTACH_DISTANCE := 54.0
const LAG_WARP_COOLDOWN_MIN := 4.45
const LAG_WARP_COOLDOWN_MAX := 5.45
const LAG_WARP_WARNING_TIME := 0.35
const LAG_WARP_DISTANCE_MIN := 76.0
const LAG_WARP_DISTANCE_MAX := 126.0
const MAX_ENEMY_BULLETS := 72
const SPAWN_EDGE_PADDING := 72.0
const SPAWN_WALL_CLEARANCE := 24.0
const SPAWN_POSITION_ATTEMPTS := 64
const SPAWN_OUTER_BAND_DEPTH := 280.0
const SPAWN_PLAYER_MIN_DISTANCE := 300.0
const SPAWN_SCREEN_MARGIN := 72.0
const SPAWN_FALLBACK_FIELD_VIEW := Rect2(Vector2(20.0, 190.0), Vector2(1200.0, 590.0))
const ENEMY_WALL_AVOIDANCE_MARGIN := 18.0
const ENEMY_WALL_AVOIDANCE_BLEND := 0.62
const ENEMY_WALL_AVOIDANCE_FALLBACK_DISTANCE := 420.0
const ENEMY_WALL_AVOIDANCE_MIN_FORWARD_DOT := 0.28
const ENEMY_WALL_AVOIDANCE_ROUTE_TURN_THRESHOLD := 160.0
const ENEMY_WALL_NAVIGATION_RADIUS_RATE := 0.72
const ENEMY_WALL_NAVIGATION_RADIUS_MIN := 14.0
const BOSS_WALL_NAVIGATION_RADIUS_RATE := 0.56
const BOSS_WALL_NAVIGATION_RADIUS_MIN := 46.0
const BOSS_WALL_UNSTICK_STEP_RATE := 0.58
const GAMEPLAY_MARSHMALLOW_DROP_CHANCE := 0.012
const GAMEPLAY_RACE_MARSHMALLOW_DROP_CHANCE := 0.006
const GAMEPLAY_BULLET_HELL_MARSHMALLOW_DROP_CHANCE := 0.004
const GAMEPLAY_HORROR_MARSHMALLOW_DROP_CHANCE := 0.010
const GAMEPLAY_FAKE_GIFT_MARSHMALLOW_DROP_CHANCE := 0.25
const LINKED_TROLL_DEFEAT_REWARD_ENABLED := true
const LINKED_TROLL_BONUS_EXP_MULTIPLIER := 0.5
const LINKED_TROLL_MINIMUM_BONUS_EXP := 1
const LINKED_TROLL_GIFT_EXPECTATION_GAIN := 1
const LINKED_TROLL_MAX_GIFT_EXPECTATION_GAIN_PER_RUN := 10

# These phase starts are shared by the runtime pickers and the codex read-only
# presentation model.  Keep the picker order/probabilities unchanged when
# extending this table.
const DEFAULT_WAVE_PHASE_STARTS: Array[float] = [0.0, 30.0, 60.0, 90.0, 120.0, 150.0]
const GAMEPLAY_WAVE_PHASE_STARTS: Array[float] = [0.0, 30.0, 75.0, 120.0]
const SONG_WAVE_PHASE_STARTS: Array[float] = [0.0, 30.0, 70.0, 120.0]
const DRAWING_WAVE_PHASE_STARTS: Array[float] = [0.0, 70.0]
const COLLAB_WAVE_PHASE_STARTS: Array[float] = [0.0, 36.0, 81.0, 126.0]
const BULLET_DRONE_STAGE_START_SECONDS := 75.0

static func wave_phase_start_seconds(stage_id: String, phase_index: int) -> float:
	var starts: Array[float] = DEFAULT_WAVE_PHASE_STARTS
	match stage_id.strip_edges().to_lower():
		"game", "gameplay": starts = GAMEPLAY_WAVE_PHASE_STARTS
		"song", "singing": starts = SONG_WAVE_PHASE_STARTS
		"drawing": starts = DRAWING_WAVE_PHASE_STARTS
		"collab": starts = COLLAB_WAVE_PHASE_STARTS
	if phase_index < 0 or phase_index >= starts.size():
		return -1.0
	return starts[phase_index]

static func codex_normal_spawn_conditions(enemy_id: String) -> Dictionary:
	var id := enemy_id.strip_edges()
	var conditions: Dictionary = {}
	match id:
		"troll": conditions = {"stages": ["zatsudan", "gameplay", "singing"], "startSeconds": {"zatsudan": wave_phase_start_seconds("zatsudan", 0), "gameplay": wave_phase_start_seconds("gameplay", 0), "singing": wave_phase_start_seconds("singing", 0)}}
		"fast": conditions = {"stages": ["zatsudan", "gameplay", "singing"], "startSeconds": {"zatsudan": wave_phase_start_seconds("zatsudan", 1), "gameplay": wave_phase_start_seconds("gameplay", 2), "singing": wave_phase_start_seconds("singing", 2)}}
		"shooter": conditions = {"stages": ["zatsudan", "gameplay", "singing"], "startSeconds": {"zatsudan": wave_phase_start_seconds("zatsudan", 2), "gameplay": wave_phase_start_seconds("gameplay", 3), "singing": wave_phase_start_seconds("singing", 3)}}
		"long_comment_guy": conditions = {"stages": ["zatsudan", "gameplay"], "startSeconds": {"zatsudan": wave_phase_start_seconds("zatsudan", 3), "gameplay": wave_phase_start_seconds("gameplay", 3)}}
		"clipper": conditions = {"stages": ["zatsudan"], "startSeconds": {"zatsudan": wave_phase_start_seconds("zatsudan", 4)}}
		"enemy_spoiler_comment": conditions = {"stages": ["gameplay"], "startSeconds": {"gameplay": wave_phase_start_seconds("gameplay", 0)}}
		"enemy_backseat_controller": conditions = {"stages": ["gameplay"], "startSeconds": {"gameplay": wave_phase_start_seconds("gameplay", 1)}}
		"enemy_armchair_strategist", "enemy_lag_comment", "enemy_fake_first_timer": conditions = {"stages": ["gameplay"], "startSeconds": {"gameplay": wave_phase_start_seconds("gameplay", 2)}}
		"enemy_strategy_wiki_ojisan": conditions = {"stages": ["gameplay"], "startSeconds": {"gameplay": wave_phase_start_seconds("gameplay", 3)}}
		"pitch_police", "request_spammer", "song_noise_comment": conditions = {"stages": ["singing"], "startSeconds": {"singing": wave_phase_start_seconds("singing", 0)}}
		"fast_call_fan", "song_lyric_spoiler_comment": conditions = {"stages": ["singing"], "startSeconds": {"singing": wave_phase_start_seconds("singing", 1)}}
		"drawing_fix_note", "layer_lost", "bucket_fill_slime", "red_pen_teacher": conditions = {"stages": ["drawing"], "startSeconds": {"drawing": wave_phase_start_seconds("drawing", 0)}}
		"collab_comparison_troll", "collab_messenger_pigeon": conditions = {"stages": ["collab"], "startSeconds": {"collab": wave_phase_start_seconds("collab", 0)}}
		"collab_discord_troll": conditions = {"stages": ["collab"], "startSeconds": {"collab": wave_phase_start_seconds("collab", 1)}}
		"collab_volume_police": conditions = {"stages": ["collab"], "startSeconds": {"collab": wave_phase_start_seconds("collab", 2)}}
		"collab_exclusive_listener": conditions = {"stages": ["collab"], "startSeconds": {"collab": wave_phase_start_seconds("collab", 3)}}
	return conditions

static var movement_wall_cache: Dictionary = {}

static func spawn_interval(context: Dictionary) -> float:
	var elapsed: float = float(context["elapsed"])
	if bool(context["quickTestMode"]):
		if elapsed >= 45.0:
			return 0.55
		if elapsed >= 30.0:
			return 0.75
		if elapsed >= 15.0:
			return 1.0
		return 1.25
	if elapsed >= 150.0:
		return 0.45
	if elapsed >= 120.0:
		return 0.6
	if elapsed >= 90.0:
		return 0.7
	if elapsed >= 60.0:
		return 0.8
	if elapsed >= 30.0:
		return 1.0
	return 1.3

static func effective_wave_time(elapsed: float, quick_test_mode: bool) -> float:
	return elapsed * 3.0 if quick_test_mode else elapsed

static func pick_wave_enemy(elapsed: float, quick_test_mode: bool, rng: RandomNumberGenerator, stream_frame_id: String = "", active_genre_event: String = "", upper_enemy_weight: float = 1.0, difficulty_runtime: Dictionary = {}) -> String:
	var picker_elapsed := elapsed
	var picker_quick_test_mode := quick_test_mode
	if HardModeSystemScript.is_expert_runtime(difficulty_runtime) and not quick_test_mode:
		var config: Dictionary = difficulty_runtime.get("difficultyConfig", {}) as Dictionary
		var lead_seconds := 0.0
		var lead_start := maxf(0.0, float(config.get("strongEnemySelectionLeadStartSeconds", 30.0)))
		if elapsed >= lead_start:
			lead_seconds = maxf(lead_seconds, float(config.get("strongEnemySelectionLeadSeconds", 15.0)))
		# A stage profile may move the picker phase independently of the shared
		# EXPERT lead.  Use the larger lead once so zatsudan does not receive a
		# hidden double lead at the generic threshold.
		lead_seconds = maxf(lead_seconds, HardModeSystemScript.stage_profile_enemy_picker_lead(difficulty_runtime, elapsed))
		picker_elapsed += lead_seconds
	var kind := _pick_wave_enemy_base(picker_elapsed, picker_quick_test_mode, rng, stream_frame_id, active_genre_event)
	if upper_enemy_weight < 1.0 and _is_upper_enemy_kind(kind) and rng.randf() >= upper_enemy_weight:
		return _fallback_wave_enemy(stream_frame_id, active_genre_event)
	if upper_enemy_weight <= 1.0:
		return kind
	var upper_chance := clampf((upper_enemy_weight - 1.0) * 0.45, 0.0, 0.45)
	if rng.randf() >= upper_chance:
		return kind
	return _relay_upper_enemy_kind(stream_frame_id, active_genre_event, kind)

static func _is_upper_enemy_kind(kind: String) -> bool:
	return kind == "long_comment_guy" or kind == "clipper" or kind == "enemy_backseat_controller" or kind == "enemy_armchair_strategist" or kind == "enemy_strategy_wiki_ojisan" or kind == "enemy_wrong_way_kart" or kind == "enemy_bullet_drone" or kind == "red_pen_teacher" or kind == "bucket_fill_slime" or kind == "collab_volume_police"

static func _fallback_wave_enemy(stream_frame_id: String, active_genre_event: String) -> String:
	if stream_frame_id == "gameplay":
		return "enemy_spoiler_comment"
	if stream_frame_id == "singing" or stream_frame_id == "song":
		return "pitch_police"
	if stream_frame_id == "drawing":
		return "drawing_fix_note"
	if stream_frame_id == "collab":
		return "collab_comparison_troll"
	return "troll"

static func _pick_wave_enemy_base(elapsed: float, quick_test_mode: bool, rng: RandomNumberGenerator, stream_frame_id: String = "", active_genre_event: String = "") -> String:
	if stream_frame_id == "gameplay" and active_genre_event == "":
		return pick_gameplay_normal_enemy(elapsed, quick_test_mode, rng)
	if stream_frame_id == "singing" or stream_frame_id == "song":
		return pick_song_enemy(elapsed, quick_test_mode, rng)
	if stream_frame_id == "drawing":
		return pick_drawing_enemy(elapsed, quick_test_mode, rng)
	if stream_frame_id == "collab":
		return pick_collab_enemy(elapsed, quick_test_mode, rng)
	return pick_default_wave_enemy(elapsed, quick_test_mode, rng)

static func _relay_upper_enemy_kind(stream_frame_id: String, active_genre_event: String, fallback: String) -> String:
	if stream_frame_id == "gameplay":
		match active_genre_event:
			"race": return "enemy_wrong_way_kart"
			"bullet_hell": return "enemy_bullet_drone"
			"horror": return "enemy_strategy_wiki_ojisan"
		return "enemy_strategy_wiki_ojisan"
	if stream_frame_id == "singing":
		return "request_spammer"
	if stream_frame_id == "drawing":
		return "red_pen_teacher" if fallback != "red_pen_teacher" else "bucket_fill_slime"
	if stream_frame_id == "collab":
		return "collab_volume_police"
	return "long_comment_guy"

static func pick_gameplay_normal_enemy(elapsed: float, quick_test_mode: bool, rng: RandomNumberGenerator) -> String:
	var t: float = effective_wave_time(elapsed, quick_test_mode)
	var roll: float = rng.randf()
	if t >= GAMEPLAY_WAVE_PHASE_STARTS[3]:
		if roll < 0.18:
			return "enemy_spoiler_comment"
		if roll < 0.35:
			return "enemy_backseat_controller"
		if roll < 0.50:
			return "enemy_armchair_strategist"
		if roll < 0.62:
			return "enemy_lag_comment"
		if roll < 0.74:
			return "enemy_strategy_wiki_ojisan"
		if roll < 0.82:
			return "enemy_fake_first_timer"
		if roll < 0.89:
			return "shooter"
		if roll < 0.96:
			return "fast"
		return "long_comment_guy"
	if t >= GAMEPLAY_WAVE_PHASE_STARTS[2]:
		if roll < 0.25:
			return "enemy_spoiler_comment"
		if roll < 0.45:
			return "enemy_backseat_controller"
		if roll < 0.61:
			return "enemy_armchair_strategist"
		if roll < 0.72:
			return "enemy_lag_comment"
		if roll < 0.80:
			return "enemy_fake_first_timer"
		if roll < 0.90:
			return "fast"
		return "troll"
	if t >= GAMEPLAY_WAVE_PHASE_STARTS[1]:
		if roll < 0.42:
			return "enemy_spoiler_comment"
		if roll < 0.62:
			return "enemy_backseat_controller"
		if roll < 0.74:
			return "fast"
		return "troll"
	if roll < 0.55:
		return "enemy_spoiler_comment"
	return "troll"

static func pick_bullet_hell_enemy(elapsed: float, quick_test_mode: bool, rng: RandomNumberGenerator) -> String:
	var t: float = effective_wave_time(elapsed, quick_test_mode)
	if t >= BULLET_DRONE_STAGE_START_SECONDS and rng.randf() < 0.22:
		return "enemy_bullet_drone"
	return "enemy_dot_invader"

static func pick_race_event_enemy(_elapsed: float, _quick_test_mode: bool, rng: RandomNumberGenerator, difficulty_runtime: Dictionary = {}) -> String:
	var wrong_way_weight := 0.62
	var jammer_weight := 0.38
	var event_config := HardModeSystemScript.stage_profile_event_config(difficulty_runtime, "race")
	var weights: Dictionary = event_config.get("enemyWeights", {}) as Dictionary
	if not weights.is_empty():
		wrong_way_weight = maxf(0.0, float(weights.get("wrongWay", wrong_way_weight)))
		jammer_weight = maxf(0.0, float(weights.get("jammer", jammer_weight)))
	var total_weight := wrong_way_weight + jammer_weight
	if total_weight <= 0.0:
		return "enemy_wrong_way_kart"
	return "enemy_wrong_way_kart" if rng.randf() < wrong_way_weight / total_weight else "enemy_jammer_cone"

static func pick_song_enemy(elapsed: float, quick_test_mode: bool, rng: RandomNumberGenerator) -> String:
	var t: float = effective_wave_time(elapsed, quick_test_mode)
	var roll: float = rng.randf()
	if t >= SONG_WAVE_PHASE_STARTS[3]:
		if roll < 0.24:
			return "pitch_police"
		if roll < 0.45:
			return "request_spammer"
		if roll < 0.63:
			return "fast_call_fan"
		if roll < 0.75:
			return "song_noise_comment"
		if roll < 0.86:
			return "song_lyric_spoiler_comment"
		if roll < 0.93:
			return "shooter"
		return "fast"
	if t >= SONG_WAVE_PHASE_STARTS[2]:
		if roll < 0.32:
			return "pitch_police"
		if roll < 0.52:
			return "request_spammer"
		if roll < 0.68:
			return "fast_call_fan"
		if roll < 0.80:
			return "song_noise_comment"
		if roll < 0.90:
			return "song_lyric_spoiler_comment"
		return "fast"
	if t >= SONG_WAVE_PHASE_STARTS[1]:
		if roll < 0.42:
			return "pitch_police"
		if roll < 0.58:
			return "request_spammer"
		if roll < 0.72:
			return "fast_call_fan"
		if roll < 0.82:
			return "song_noise_comment"
		if roll < 0.90:
			return "song_lyric_spoiler_comment"
		return "troll"
	if roll < 0.55:
		return "pitch_police"
	if roll < 0.68:
		return "song_noise_comment"
	if roll < 0.80:
		return "request_spammer"
	return "troll"

static func pick_drawing_enemy(elapsed: float, quick_test_mode: bool, rng: RandomNumberGenerator) -> String:
	var t: float = effective_wave_time(elapsed, quick_test_mode)
	var roll: float = rng.randf()
	if t >= DRAWING_WAVE_PHASE_STARTS[1]:
		if roll < 0.30:
			return "drawing_fix_note"
		if roll < 0.55:
			return "layer_lost"
		if roll < 0.80:
			return "bucket_fill_slime"
		return "red_pen_teacher"
	if roll < 0.35:
		return "drawing_fix_note"
	if roll < 0.60:
		return "layer_lost"
	if roll < 0.85:
		return "bucket_fill_slime"
	return "red_pen_teacher"

static func pick_collab_enemy(elapsed: float, quick_test_mode: bool, rng: RandomNumberGenerator) -> String:
	var t: float = effective_wave_time(elapsed, quick_test_mode)
	var roll: float = rng.randf()
	if t >= COLLAB_WAVE_PHASE_STARTS[3]:
		if roll < 0.25:
			return "collab_comparison_troll"
		if roll < 0.45:
			return "collab_messenger_pigeon"
		if roll < 0.65:
			return "collab_discord_troll"
		if roll < 0.85:
			return "collab_volume_police"
		return "collab_exclusive_listener"
	if t >= COLLAB_WAVE_PHASE_STARTS[2]:
		if roll < 0.30:
			return "collab_comparison_troll"
		if roll < 0.55:
			return "collab_messenger_pigeon"
		if roll < 0.80:
			return "collab_discord_troll"
		return "collab_volume_police"
	if t >= COLLAB_WAVE_PHASE_STARTS[1]:
		if roll < 0.40:
			return "collab_comparison_troll"
		if roll < 0.70:
			return "collab_messenger_pigeon"
		return "collab_discord_troll"
	return "collab_comparison_troll" if roll < 0.60 else "collab_messenger_pigeon"

static func pick_default_wave_enemy(elapsed: float, quick_test_mode: bool, rng: RandomNumberGenerator) -> String:
	var t: float = effective_wave_time(elapsed, quick_test_mode)
	var roll: float = rng.randf()
	if t >= DEFAULT_WAVE_PHASE_STARTS[5]:
		if roll < 0.20:
			return "clipper"
		if roll < 0.40:
			return "long_comment_guy"
		if roll < 0.62:
			return "shooter"
		if roll < 0.82:
			return "fast"
		return "troll"
	if t >= DEFAULT_WAVE_PHASE_STARTS[4]:
		if roll < 0.25:
			return "clipper"
		if roll < 0.45:
			return "long_comment_guy"
		if roll < 0.68:
			return "shooter"
		return "fast" if roll < 0.84 else "troll"
	if t >= DEFAULT_WAVE_PHASE_STARTS[3]:
		if roll < 0.35:
			return "long_comment_guy"
		if roll < 0.62:
			return "shooter"
		return "fast" if roll < 0.82 else "troll"
	if t >= DEFAULT_WAVE_PHASE_STARTS[2]:
		if roll < 0.38:
			return "shooter"
		return "fast" if roll < 0.68 else "troll"
	if t >= DEFAULT_WAVE_PHASE_STARTS[1]:
		return "fast" if roll < 0.45 else "troll"
	return "troll"

static func is_genre_event_enemy(kind: String) -> bool:
	return kind == "enemy_wrong_way_kart" or kind == "enemy_jammer_cone" or kind == "enemy_dot_invader" or kind == "enemy_bullet_drone" or kind == "enemy_fake_gift_box" or kind == "enemy_noise_ghost_comment"

static func is_boss_enemy(enemy: Dictionary) -> bool:
	var kind := String(enemy.get("kind", ""))
	var boss_id := String(enemy.get("bossId", ""))
	return bool(enemy.get("isBoss", false)) or boss_id != "" or kind.begins_with("boss_") or kind in [
		"bugged_final_boss", "bugged_final_boss_stun", "last_offline", "pitch_police_chief", "red_pen_review_chief", "red_pen_retake_dragon", "collab_crusher"
	]

static func canonical_codex_enemy_id(enemy: Dictionary) -> String:
	return CodexManager.canonical_enemy_id(enemy)

static func discover_spawned_enemies_for_target(target: Node) -> void:
	var enemies_value: Variant = target.get("enemies")
	if not enemies_value is Array:
		return
	for item in enemies_value as Array:
		if not item is Dictionary:
			continue
		var enemy: Dictionary = item as Dictionary
		if bool(enemy.get("_codex_spawn_processed", false)):
			continue
		enemy["_codex_spawn_processed"] = true
		var codex_id := canonical_codex_enemy_id(enemy)
		if codex_id != "":
			CodexManager.discover_enemy(codex_id)

static func weapon_hurt_radius(enemy: Dictionary) -> float:
	var explicit_value: Variant = enemy.get("hurtboxRadius", enemy.get("weaponHurtRadius", null))
	if explicit_value != null:
		return maxf(0.0, float(explicit_value))
	return maxf(0.0, float(enemy.get("radius", 20.0)))

static func is_large_enemy(enemy: Dictionary) -> bool:
	return is_boss_enemy(enemy) or float(enemy.get("radius", 20.0)) >= 38.0

static func _default_can_be_pulled(enemy: Dictionary) -> bool:
	var kind := String(enemy.get("kind", ""))
	if is_boss_enemy(enemy) or is_genre_event_enemy(kind):
		return false
	if bool(enemy.get("relayBossSummon", false)) or not bool(enemy.get("canBeKnockedBack", true)):
		return false
	if bool(enemy.get("isDashing", false)) or bool(enemy.get("dashing", false)) or float(enemy.get("dashTimer", 0.0)) > 0.0:
		return false
	if float(enemy.get("radius", 20.0)) >= 38.0:
		return false
	if kind.begins_with("collab_") or kind in [
		"enemy_backseat_controller", "enemy_strategy_wiki_ojisan", "enemy_wrong_way_kart",
		"enemy_jammer_cone", "enemy_lag_comment", "enemy_fake_first_timer",
		"song_noise_comment", "song_lyric_spoiler_comment", "layer_lost", "undo_ghost"
	]:
		return false
	if String(enemy.get("behavior", "")) in ["stationary", "stationary_obstacle", "fixed", "charge"]:
		return false
	return true

static func can_be_pulled(enemy: Dictionary) -> bool:
	if enemy.has("canBePulled"):
		return bool(enemy.get("canBePulled", false))
	return _default_can_be_pulled(enemy)

static func is_pullable_small_enemy(enemy: Dictionary) -> bool:
	return can_be_pulled(enemy) and not is_boss_enemy(enemy) and float(enemy.get("radius", 20.0)) < 38.0

static func is_collision_pullable_enemy(enemy: Dictionary) -> bool:
	if is_boss_enemy(enemy) or not can_be_pulled(enemy):
		return false
	var kind := String(enemy.get("kind", ""))
	if is_genre_event_enemy(kind) or bool(enemy.get("relayBossSummon", false)):
		return false
	if not bool(enemy.get("canBeKnockedBack", true)) or bool(enemy.get("isDashing", false)) or bool(enemy.get("dashing", false)) or float(enemy.get("dashTimer", 0.0)) > 0.0 or String(enemy.get("behavior", "")) in ["stationary", "stationary_obstacle", "fixed", "charge"]:
		return false
	return true

static func hit_flash_duration_for_kind(kind: String, is_boss: bool = false) -> float:
	if is_boss or kind.begins_with("boss_"):
		return 0.06
	if kind == "long_comment_guy":
		return 0.08
	return 0.10

static func knockback_resistance_for_kind(kind: String, is_boss: bool = false) -> float:
	if is_boss or kind.begins_with("boss_"):
		return 1.0
	if kind == "enemy_backseat_controller":
		return 0.35
	if kind == "enemy_strategy_wiki_ojisan":
		return 0.65
	if kind == "enemy_wrong_way_kart" or kind == "enemy_jammer_cone":
		return 0.45
	if kind == "enemy_armchair_strategist" or kind == "enemy_lag_comment" or kind == "enemy_dot_invader" or kind == "enemy_bullet_drone" or kind == "enemy_fake_gift_box" or kind == "enemy_noise_ghost_comment" or kind == "song_noise_comment" or kind == "song_lyric_spoiler_comment":
		return 0.2
	if kind == "request_spammer":
		return 0.25
	if kind == "pitch_police" or kind == "fast_call_fan":
		return 0.12
	if kind == "fast" or kind == "unread_maro":
		return 0.1
	if kind == "shooter" or kind == "ghost_comment":
		return 0.2
	if kind == "clipper":
		return 0.3
	if kind == "long_comment_guy":
		return 0.7
	return 0.0

static func can_knockback_kind(kind: String, is_boss: bool = false) -> bool:
	return knockback_resistance_for_kind(kind, is_boss) < 1.0

static func contact_damage_for_kind(kind: String, is_boss: bool = false) -> int:
	if is_boss or kind.begins_with("boss_"):
		return DamageSystem.BOSS_CONTACT_DAMAGE
	if kind == "long_comment_guy" or kind == "clipper" or kind == "ghost_comment":
		return DamageSystem.STRONG_CONTACT_DAMAGE
	if kind == "fast":
		return DamageSystem.FAST_CONTACT_DAMAGE
	return DamageSystem.DEFAULT_CONTACT_DAMAGE

static func enemy_data(kind: String) -> Dictionary:
	var data := _enemy_data_raw(kind)
	if not data.is_empty():
		data["combatType"] = HardModeSystemScript.normalize_combat_type(data.get("combatType", _fallback_combat_type(kind, data)))
		data["minimumAttackInterval"] = maxf(0.1, float(data.get("minimumAttackInterval", 0.1)))
	return data

static func _fallback_combat_type(kind: String, data: Dictionary) -> String:
	if kind in ["troll", "unread_maro", "enemy_dot_invader", "enemy_noise_ghost_comment", "layer_lost", "undo_ghost"]:
		return "swarm"
	if kind in ["fast", "enemy_backseat_controller", "enemy_lag_comment", "enemy_wrong_way_kart", "clipper", "collab_messenger_pigeon"]:
		return "fast"
	if kind in ["shooter", "enemy_armchair_strategist", "enemy_strategy_wiki_ojisan", "enemy_bullet_drone", "request_spammer", "red_pen_teacher"]:
		return "ranged"
	if kind in ["bucket_fill_slime", "enemy_exclusive_listener", "boss_super_long_comment"]:
		return "tank"
	if kind in ["collab_comparison_troll", "collab_discord_troll", "collab_volume_police", "collab_exclusive_listener", "drawing_fix_note"]:
		return "support"
	if kind in ["enemy_jammer_cone", "enemy_fake_gift_box", "collab_mute_core"]:
		return "special"
	var behavior := String(data.get("behavior", ""))
	if behavior == "chase_fast":
		return "fast"
	if behavior in ["shooter", "keep_distance_shooter", "slow_spread_shooter", "drone_keep_distance", "drawing_red_pen_teacher"]:
		return "ranged"
	if behavior in ["tank", "drawing_bucket_slime"]:
		return "tank"
	if behavior in ["collab_messenger_pigeon", "collab_discord_troll", "collab_volume_police", "collab_division_noise"]:
		return "support"
	if behavior in ["ghost_chase", "linear_pass", "stationary_obstacle"]:
		return "swarm"
	return "standard"

static func _enemy_data_raw(kind: String) -> Dictionary:
	if kind == "pitch_police":
		return {"displayName": "音程警察", "description": "音程チェックで近づいてくる歌枠の基本敵", "hp": 14.0, "speed": 110.0, "radius": 23.0, "score": 58, "exp": 2, "behavior": "chase", "contactDamage": 12}
	if kind == "request_spammer":
		return {"displayName": "リクエスト連投", "description": "曲リクエストを投げ続ける歌枠の遠距離敵", "hp": 18.0, "speed": 72.0, "radius": 25.0, "score": 84, "exp": 3, "behavior": "keep_distance_shooter", "contactDamage": 10}
	if kind == "fast_call_fan":
		return {"displayName": "早口コール勢", "description": "サビに合わせて高速で押し寄せるコール敵", "hp": 9.0, "speed": 166.0, "radius": 20.0, "score": 48, "exp": 2, "behavior": "chase_fast", "contactDamage": 14}
	if kind == "song_noise_comment":
		return {"displayName": "ノイズコメント", "description": "歌声にノイズを混ぜる変則コメント敵", "hp": 12.0, "speed": 96.0, "radius": 22.0, "score": 58, "exp": 2, "behavior": "chase_with_short_warp", "contactDamage": 10}
	if kind == "song_lyric_spoiler_comment":
		return {"displayName": "歌詞ネタバレコメント", "description": "先の歌詞を先回りして流す迷惑コメント敵", "hp": 13.0, "speed": 100.0, "radius": 23.0, "score": 62, "exp": 2, "behavior": "chase", "contactDamage": 10}
	if kind == "drawing_fix_note":
		return {"displayName": "修正指示コメント", "description": "赤字の修正メモで接近してくるお絵かき枠の妨害敵", "hp": 13.5, "speed": 72.0, "radius": 24.0, "score": 70, "exp": 3, "behavior": "chase", "contactDamage": 10}
	if kind == "red_pen_teacher":
		return {"displayName": "赤ペン先生", "description": "短い予告のあと赤ペン弾を撃つお絵かき枠の遠距離敵", "hp": 18.0, "speed": 104.0, "radius": 24.0, "score": 86, "exp": 3, "behavior": "drawing_red_pen_teacher", "contactDamage": 10}
	if kind == "layer_lost":
		return {"displayName": "レイヤー迷子", "description": "半透明に揺れながらゆっくり近づくレイヤー混乱敵", "hp": 13.0, "speed": 72.0, "radius": 23.0, "score": 64, "exp": 2, "behavior": "ghost_chase", "contactDamage": 5}
	if kind == "bucket_fill_slime":
		return {"displayName": "バケツ塗りスライム", "description": "ゆっくり近づきながら短時間の汚れペイントを残す敵", "hp": 30.0, "speed": 46.0, "radius": 31.0, "score": 96, "exp": 4, "behavior": "drawing_bucket_slime", "contactDamage": 12}
	if kind == "undo_ghost":
		return {"displayName": "Undo幽霊", "description": "戻る矢印をまとって半透明に揺れるお絵かき枠の幽霊敵", "hp": 12.0, "speed": 112.0, "radius": 23.0, "score": 62, "exp": 2, "behavior": "ghost_chase", "contactDamage": 10}
	if kind == "collab_comparison_troll":
		return {"displayName": "比較厨", "description": "プレイヤーへ接近し、近くにいる間だけ攻撃力を下げるコラボ枠の妨害敵", "hp": 15.0, "speed": 84.0, "radius": 24.0, "score": 70, "exp": 3, "behavior": "collab_comparison_chase", "contactDamage": 5}
	if kind == "collab_messenger_pigeon":
		return {"displayName": "伝書鳩", "description": "プレイヤーと相方の間を突進し、短時間のコメント跡を残すコラボ枠の妨害敵", "hp": 12.0, "speed": 78.0, "radius": 21.0, "score": 66, "exp": 2, "behavior": "collab_messenger_pigeon", "contactDamage": 5}
	if kind == "collab_discord_troll":
		return {"displayName": "不仲煽り", "description": "予告のあと押し出し波を放ち、相方との距離を乱すコラボ枠の妨害敵", "hp": 17.0, "speed": 72.0, "radius": 24.0, "score": 78, "exp": 3, "behavior": "collab_discord_troll", "contactDamage": 4}
	if kind == "collab_volume_police":
		return {"displayName": "音量警察", "description": "音声干渉エリアを作り、プレイヤーの攻撃間隔を悪化させるコラボ枠の妨害敵", "hp": 18.0, "speed": 68.0, "radius": 25.0, "score": 82, "exp": 3, "behavior": "collab_volume_police", "contactDamage": 4}
	if kind == "collab_exclusive_listener":
		return {"displayName": "独占リスナー", "description": "相方へ張り付き、通常支援を止める優先撃破のコラボ枠妨害敵", "hp": 14.0, "speed": 100.0, "radius": 22.0, "score": 76, "exp": 3, "behavior": "collab_exclusive_listener", "contactDamage": 0}
	if kind == "collab_division_noise":
		return {"displayName": "分断ノイズ", "description": "コラボクラッシャーが生むPASS供給用の赤青ノイズ", "hp": 23.0, "speed": 48.0, "radius": 25.0, "score": 90, "exp": 4, "behavior": "collab_division_noise", "contactDamage": 0}
	if kind == "collab_mute_core":
		return {"displayName": "ミュートコア", "description": "破壊すると相方の通常支援が再開する固定ノイズコア", "hp": 31.0, "speed": 0.0, "radius": 27.0, "score": 80, "exp": 3, "behavior": "collab_mute_core", "contactDamage": 0}
	if kind == "enemy_spoiler_comment":
		return {"displayName": "ネタバレコメント", "description": "ゲーム実況中にネタバレを書き込む迷惑コメント敵", "hp": 11.0, "speed": 108.0, "radius": 23.0, "score": 44, "exp": 2, "behavior": "chase", "contactDamage": 12}
	if kind == "enemy_backseat_controller":
		return {"displayName": "指示厨コントローラー", "description": "操作指示コメントがコントローラー型になった中型敵", "hp": 24.0, "speed": 104.0, "radius": 28.0, "score": 82, "exp": 3, "behavior": "zigzag_chase", "contactDamage": 14}
	if kind == "enemy_armchair_strategist":
		return {"displayName": "エアプ軍師", "description": "離れた位置から攻略コメント弾を撃つ遠距離敵", "hp": 18.0, "speed": 72.0, "radius": 25.0, "score": 86, "exp": 4, "behavior": "keep_distance_shooter", "contactDamage": 12}
	if kind == "enemy_dot_invader":
		return {"displayName": "ドットインベーダー", "description": "弾幕シューティング風イベントに出るレトロSTG敵", "hp": 12.0, "speed": 70.0, "radius": 22.0, "score": 72, "exp": 3, "behavior": "stg_side_move", "contactDamage": 12}
	if kind == "enemy_fake_gift_box":
		return {"displayName": "偽ギフトボックス", "description": "ホラーゲーム風イベントで正体を現す罠ギフト", "hp": 18.0, "speed": 126.0, "radius": 24.0, "score": 90, "exp": 3, "behavior": "chase", "contactDamage": 12}
	if kind == "enemy_lag_comment":
		return {"displayName": "ラグコメント", "description": "短距離ワープで画面にノイズを混ぜる変則コメント敵", "hp": 10.0, "speed": 106.0, "radius": 22.0, "score": 58, "exp": 2, "behavior": "chase_with_short_warp", "contactDamage": 10}
	if kind == "enemy_strategy_wiki_ojisan":
		return {"displayName": "攻略Wikiおじさん", "description": "攻略情報を抱えて低速で迫る硬めのゲーム実況敵", "hp": 52.0, "speed": 54.0, "radius": 34.0, "score": 130, "exp": 7, "behavior": "slow_spread_shooter", "contactDamage": 16}
	if kind == "enemy_fake_first_timer":
		return {"displayName": "初見詐欺", "description": "初見のふりをして近づくと急加速する奇襲コメント敵", "hp": 9.0, "speed": 54.0, "radius": 19.0, "score": 62, "exp": 2, "behavior": "ambush_chase", "contactDamage": 14}
	if kind == "enemy_wrong_way_kart":
		return {"displayName": "逆走カート", "description": "レースゲーム風イベントで直線的に走り抜ける妨害カート", "hp": 18.0, "speed": 292.0, "radius": 25.0, "score": 78, "exp": 2, "behavior": "linear_pass", "contactDamage": 16}
	if kind == "enemy_jammer_cone":
		return {"displayName": "じゃまコーン", "description": "レースゲーム風イベント中に短時間だけ残る壊せる障害物", "hp": 18.0, "speed": 0.0, "radius": 24.0, "score": 34, "exp": 1, "behavior": "stationary_obstacle", "contactDamage": 8, "lifeTime": 8.0}
	if kind == "enemy_bullet_drone":
		return {"displayName": "弾幕ドローン", "description": "弾幕シューティング風イベントで3方向弾を撃つ中型敵", "hp": 24.0, "speed": 86.0, "radius": 26.0, "score": 110, "exp": 4, "behavior": "drone_keep_distance", "contactDamage": 10}
	if kind == "enemy_noise_ghost_comment":
		return {"displayName": "ノイズ幽霊コメント", "description": "ホラーゲーム風イベントに現れる砂嵐混じりのコメント敵", "hp": 16.0, "speed": 88.0, "radius": 22.0, "score": 82, "exp": 3, "behavior": "ghost_chase", "contactDamage": 10}
	if kind == "fast":
		return {"displayName": "連投マン", "description": "高速で距離を詰める連投コメント敵", "hp": 8.0, "speed": 155.0, "radius": 20.0, "score": 40, "exp": 2, "behavior": "chase_fast", "contactDamage": 14}
	if kind == "shooter":
		return {"displayName": "指示厨", "description": "距離を取りながら指示弾を撃つ敵", "hp": 14.0, "speed": 95.0, "radius": 24.0, "score": 60, "exp": 3, "behavior": "shooter", "contactDamage": 12}
	if kind == "long_comment_guy":
		return {"displayName": "長文ニキ", "description": "遅いがしぶとく進路をふさぐ長文コメント敵", "hp": 40.0, "speed": 62.0, "radius": 34.0, "score": 80, "exp": 5, "behavior": "tank", "contactDamage": 18}
	if kind == "clipper":
		return {"displayName": "悪質切り抜き師", "description": "予告後に突進して事故シーンを狙う敵", "hp": 18.0, "speed": 120.0, "radius": 23.0, "score": 100, "exp": 4, "behavior": "charger", "contactDamage": 18}
	if kind == "unread_maro":
		return {"displayName": "未読マロ", "description": "放置されたマシュマロが荒らし化した敵", "hp": 8.0, "speed": 130.0, "radius": 19.0, "score": 20, "exp": 1, "behavior": "chase", "contactDamage": 12}
	if kind == "ghost_comment":
		return {"displayName": "幽霊コメント", "description": "ホラー風イベント中に現れる透明気味のコメント敵", "hp": 20.0, "speed": 122.0, "radius": 23.0, "score": 120, "exp": 3, "behavior": "ghost", "contactDamage": 14}
	if kind == "noise_ghost_comment":
		return {"displayName": "ラストオフライン召喚ノイズ", "description": "ラストオフラインが呼び出す報酬なしの召喚ノイズ", "hp": 16.0, "speed": 88.0, "radius": 22.0, "score": 0, "exp": 0, "expDrop": 0, "behavior": "ghost_chase", "contactDamage": 7, "noRewards": true, "relayBossSummon": true}
	if kind == "boss_super_long_comment":
		return {"displayName": "超長文ニキ", "description": "長文ニキの巨大版。大きなコメント塊でプレイヤーを追い詰める。", "hp": 400.0, "speed": 58.0, "radius": 78.0, "score": 3000, "exp": 20, "behavior": "tank"}
	if kind == "bugged_final_boss":
		return {"displayName": "バグったラスボス", "description": "ゲーム実況枠のジャンル変化を暴走させる専用ボス。", "hp": 1000.0, "speed": 52.0, "radius": 96.0, "score": 4200, "exp": 28, "behavior": "tank", "contactDamage": DamageSystem.BOSS_CONTACT_DAMAGE}
	return {"displayName": "荒らし", "description": "まっすぐ近づいてくる基本コメント敵", "hp": 10.0, "speed": 92.0, "radius": 21.0, "score": 20, "exp": 1, "behavior": "chase", "contactDamage": 12}

static func spawn_position(arena: Rect2, rng: RandomNumberGenerator, edge_padding: float = 20.0) -> Vector2:
	var rect := spawn_candidate_rect(arena, edge_padding)
	return spawn_position_on_rect_edge(rect, rng)

static func spawn_candidate_rect(arena: Rect2, edge_padding: float) -> Rect2:
	var rect := arena.grow(-edge_padding)
	if rect.size.x <= 1.0 or rect.size.y <= 1.0:
		return arena
	return rect

static func spawn_position_on_rect_edge(rect: Rect2, rng: RandomNumberGenerator) -> Vector2:
	var edge := rng.randi_range(0, 3)
	if edge == 0:
		return Vector2(rng.randf_range(rect.position.x, rect.end.x), rect.position.y)
	if edge == 1:
		return Vector2(rng.randf_range(rect.position.x, rect.end.x), rect.end.y)
	if edge == 2:
		return Vector2(rect.position.x, rng.randf_range(rect.position.y, rect.end.y))
	return Vector2(rect.end.x, rng.randf_range(rect.position.y, rect.end.y))

static func spawn_position_in_outer_band(rect: Rect2, rng: RandomNumberGenerator) -> Vector2:
	var band: float = minf(SPAWN_OUTER_BAND_DEPTH, minf(rect.size.x, rect.size.y) * 0.5)
	var edge := rng.randi_range(0, 3)
	if edge == 0:
		return Vector2(rng.randf_range(rect.position.x, rect.end.x), rng.randf_range(rect.position.y, rect.position.y + band))
	if edge == 1:
		return Vector2(rng.randf_range(rect.position.x, rect.end.x), rng.randf_range(rect.end.y - band, rect.end.y))
	if edge == 2:
		return Vector2(rng.randf_range(rect.position.x, rect.position.x + band), rng.randf_range(rect.position.y, rect.end.y))
	return Vector2(rng.randf_range(rect.end.x - band, rect.end.x), rng.randf_range(rect.position.y, rect.end.y))

static func spawn_walls_for_target(target: Node) -> Array:
	var effect_walls_value: Variant = target.get("effect_walls")
	var effect_walls: Array = []
	if effect_walls_value is Array:
		effect_walls = effect_walls_value as Array
	var walls: Array = DrawDataSystem.static_wall_rects_for_target(target)
	for effect_wall in effect_walls:
		walls.append(effect_wall as Rect2)
	return walls

static func spawn_position_blocked_by_walls(pos: Vector2, radius: float, walls: Array) -> bool:
	var clearance := radius + SPAWN_WALL_CLEARANCE
	for wall_value in walls:
		var wall := wall_value as Rect2
		if wall.grow(clearance).has_point(pos):
			return true
	return false

static func fallback_visible_world_rect_for_target(target: Node, arena: Rect2) -> Rect2:
	var zoom := maxf(0.1, float(target.get("world_zoom")))
	var field_center := SPAWN_FALLBACK_FIELD_VIEW.get_center()
	var player_pos := Vector2(target.get("player_pos"))
	var desired := player_pos - field_center
	var min_offset := arena.position - SPAWN_FALLBACK_FIELD_VIEW.position
	var max_offset := arena.end - SPAWN_FALLBACK_FIELD_VIEW.end
	var camera_offset := Vector2(
		roundf(clampf(desired.x, min_offset.x, max_offset.x)),
		roundf(clampf(desired.y, min_offset.y, max_offset.y))
	)
	var top_left := (SPAWN_FALLBACK_FIELD_VIEW.position - field_center) / zoom + camera_offset + field_center
	var bottom_right := (SPAWN_FALLBACK_FIELD_VIEW.end - field_center) / zoom + camera_offset + field_center
	return Rect2(top_left, bottom_right - top_left)

static func visible_world_rect_for_target(target: Node, arena: Rect2) -> Rect2:
	if target.has_method("_visible_world_rect_for_spawning"):
		var visible_value: Variant = target.call("_visible_world_rect_for_spawning")
		if visible_value is Rect2:
			return visible_value as Rect2
	return fallback_visible_world_rect_for_target(target, arena)

static func append_spawn_band_if_valid(bands: Array, rect: Rect2) -> void:
	if rect.size.x > 1.0 and rect.size.y > 1.0:
		bands.append(rect)

static func offscreen_spawn_bands(rect: Rect2, visible_rect: Rect2) -> Array:
	var blocked := visible_rect.grow(SPAWN_SCREEN_MARGIN)
	var bands: Array = []
	if blocked.end.x <= rect.position.x or blocked.position.x >= rect.end.x or blocked.end.y <= rect.position.y or blocked.position.y >= rect.end.y:
		bands.append(rect)
		return bands
	var top_end_y := minf(blocked.position.y, rect.end.y)
	append_spawn_band_if_valid(bands, Rect2(rect.position, Vector2(rect.size.x, top_end_y - rect.position.y)))
	var bottom_start_y := maxf(blocked.end.y, rect.position.y)
	append_spawn_band_if_valid(bands, Rect2(Vector2(rect.position.x, bottom_start_y), Vector2(rect.size.x, rect.end.y - bottom_start_y)))
	var middle_y := maxf(rect.position.y, blocked.position.y)
	var middle_end_y := minf(rect.end.y, blocked.end.y)
	if middle_end_y > middle_y:
		var left_end_x := minf(blocked.position.x, rect.end.x)
		append_spawn_band_if_valid(bands, Rect2(Vector2(rect.position.x, middle_y), Vector2(left_end_x - rect.position.x, middle_end_y - middle_y)))
		var right_start_x := maxf(blocked.end.x, rect.position.x)
		append_spawn_band_if_valid(bands, Rect2(Vector2(right_start_x, middle_y), Vector2(rect.end.x - right_start_x, middle_end_y - middle_y)))
	return bands

static func random_position_in_rect(rect: Rect2, rng: RandomNumberGenerator) -> Vector2:
	return Vector2(rng.randf_range(rect.position.x, rect.end.x), rng.randf_range(rect.position.y, rect.end.y))

static func random_position_in_weighted_bands(bands: Array, rng: RandomNumberGenerator) -> Vector2:
	var total_area := 0.0
	for band_item in bands:
		var band: Rect2 = band_item as Rect2
		total_area += maxf(0.0, band.size.x * band.size.y)
	if total_area <= 0.0:
		return Vector2.INF
	var roll := rng.randf() * total_area
	for band_item in bands:
		var band: Rect2 = band_item as Rect2
		roll -= maxf(0.0, band.size.x * band.size.y)
		if roll <= 0.0:
			return random_position_in_rect(band, rng)
	return random_position_in_rect(bands.back() as Rect2, rng)

static func spawn_position_too_close_to_player(pos: Vector2, radius: float, player_pos: Vector2) -> bool:
	var min_distance := SPAWN_PLAYER_MIN_DISTANCE + radius
	return pos.distance_squared_to(player_pos) < min_distance * min_distance

static func spawn_position_visible(pos: Vector2, radius: float, visible_rect: Rect2) -> bool:
	return visible_rect.grow(radius + SPAWN_SCREEN_MARGIN).has_point(pos)

static func spawn_position_allowed(pos: Vector2, radius: float, walls: Array, player_pos: Vector2, visible_rect: Rect2) -> bool:
	if spawn_position_blocked_by_walls(pos, radius, walls):
		return false
	if spawn_position_too_close_to_player(pos, radius, player_pos):
		return false
	if spawn_position_visible(pos, radius, visible_rect):
		return false
	return true

static func spawn_position_for_target(target: Node, arena: Rect2, rng: RandomNumberGenerator, radius: float) -> Vector2:
	var walls: Array = spawn_walls_for_target(target)
	var edge_padding := radius + SPAWN_EDGE_PADDING
	var rect := spawn_candidate_rect(arena, edge_padding)
	var player_pos := Vector2(target.get("player_pos"))
	var visible_rect := visible_world_rect_for_target(target, arena)
	var offscreen_bands := offscreen_spawn_bands(rect, visible_rect)
	for i in range(SPAWN_POSITION_ATTEMPTS):
		var pos := random_position_in_weighted_bands(offscreen_bands, rng)
		if pos != Vector2.INF and spawn_position_allowed(pos, radius, walls, player_pos, visible_rect):
			return pos
	for i in range(SPAWN_POSITION_ATTEMPTS):
		var pos := spawn_position_on_rect_edge(rect, rng)
		if spawn_position_allowed(pos, radius, walls, player_pos, visible_rect):
			return pos
	for i in range(SPAWN_POSITION_ATTEMPTS):
		var pos := spawn_position_in_outer_band(rect, rng)
		if spawn_position_allowed(pos, radius, walls, player_pos, visible_rect):
			return pos
	return Vector2.INF

static func resolve_pattern_spawn_position_for_target(target: Node, arena: Rect2, rng: RandomNumberGenerator, desired_pos: Vector2, radius: float) -> Vector2:
	# Patterned HARD waves provide an explicit position and therefore bypass the
	# normal off-screen spawn search.  Keep the requested formation, but move a
	# point that overlaps map/temporary walls to the nearest usable side instead
	# of leaving the enemy trapped behind an outer wall.
	var inset := radius + 2.0
	var usable_rect := arena.grow(-inset)
	if usable_rect.size.x <= 1.0 or usable_rect.size.y <= 1.0:
		usable_rect = arena
	var walls := spawn_walls_for_target(target)
	var clamped_desired := Vector2(
		clampf(desired_pos.x, usable_rect.position.x, usable_rect.end.x),
		clampf(desired_pos.y, usable_rect.position.y, usable_rect.end.y)
	)
	if not spawn_position_blocked_by_walls(clamped_desired, radius, walls):
		return clamped_desired
	var start_angle := rng.randf_range(0.0, TAU)
	for ring in range(1, 10):
		var distance := float(ring) * 48.0
		var sample_count := 8 + ring * 2
		for sample in range(sample_count):
			var angle := start_angle + TAU * float(sample) / float(sample_count)
			var candidate := clamped_desired + Vector2(cos(angle), sin(angle)) * distance
			candidate.x = clampf(candidate.x, usable_rect.position.x, usable_rect.end.x)
			candidate.y = clampf(candidate.y, usable_rect.position.y, usable_rect.end.y)
			if not spawn_position_blocked_by_walls(candidate, radius, walls):
				return candidate
	# If the formation point is completely enclosed, use the established safe
	# spawn search rather than creating an unreachable enemy.
	return spawn_position_for_target(target, arena, rng, radius)

static func speech_lines(kind: String) -> Array[String]:
	if kind == "pitch_police":
		return ["音程！", "そこ違う", "ピッチ見て", "赤チェック"]
	if kind == "request_spammer":
		return ["これ歌って", "次これ", "リク連投", "この曲まだ？"]
	if kind == "fast_call_fan":
		return ["はい！はい！", "コール中", "サビ来た", "早口失礼"]
	if kind == "song_noise_comment":
		return ["ザザッ", "音割れ", "ノイズ入った", "聞こえる？"]
	if kind == "song_lyric_spoiler_comment":
		return ["次の歌詞", "そこ先に言うな", "ネタバレ歌詞", "まだ早い"]
	if kind == "collab_comparison_troll":
		return ["相方の方がよくない？", "片方だけでいいよ", "どっちが人気なの？", "差ついてるね"]
	if kind == "collab_messenger_pigeon":
		return ["向こうで聞いたよ", "これ伝えておくね", "相方が言ってた", "あっちの枠ではさ"]
	if kind == "collab_discord_troll":
		return ["空気重くない？", "仲悪そう", "話合ってないよ", "無理してない？"]
	if kind == "collab_volume_police":
		return ["音量そろえて", "声かぶってる", "片方聞こえない", "マイク調整して"]
	if kind == "collab_exclusive_listener":
		return ["相方だけ見せて", "二人じゃなくていい", "相方だけでいいよ", "こっちは静かにして"]
	if kind == "drawing_fix_note":
		return ["そこ修正", "赤入れます", "線見て", "直して"]
	if kind == "red_pen_teacher":
		return ["赤ペンです", "添削します", "そこ違う", "要修正"]
	if kind == "layer_lost":
		return ["今どのレイヤー？", "線画どこ", "下に描いた", "結合しちゃった"]
	if kind == "bucket_fill_slime":
		return ["バケツでいこう", "全部塗る", "はみ出した", "塗り残し発見"]
	if kind == "undo_ghost":
		return ["戻して", "Undoします", "一手前へ", "消しすぎ注意"]
	if kind == "enemy_lag_comment":
		return ["止まった？", "ラグい", "今ワープした？", "回線大丈夫？"]
	if kind == "enemy_strategy_wiki_ojisan":
		return ["完全攻略", "最強ルート", "そこ違う", "Wiki見た？"]
	if kind == "enemy_fake_first_timer":
		return ["初見です", "ここ知ってる", "初見ですけど", "あっそこ罠"]
	if kind == "enemy_wrong_way_kart":
		return ["逆走中", "そっちじゃない", "ぶつかるぞ", "道あけて"]
	if kind == "enemy_jammer_cone":
		return ["通行止め", "工事中", "ここ邪魔", "止まれ"]
	if kind == "enemy_bullet_drone":
		return ["ロックオン", "3way", "弾幕開始", "避けて"]
	if kind == "enemy_noise_ghost_comment":
		return ["ザザッ", "見えてる？", "後ろ", "砂嵐"]
	if kind == "enemy_spoiler_comment":
		return ["そこ罠", "このあと...", "ラスボス...", "ネタバレ注意"]
	if kind == "enemy_backseat_controller":
		return ["右！", "避けろ！", "今だ！", "そこ左"]
	if kind == "enemy_armchair_strategist":
		return ["違う", "こうしろ", "なんで？", "右だろ"]
	if kind == "enemy_dot_invader":
		return ["撃て撃て", "急にSTG", "避けろ", "画面見て"]
	if kind == "enemy_fake_gift_box":
		return ["ギフト？", "開けて", "近づいて", "!? "]
	if kind == "fast":
		return ["連投失礼", "追いついた", "逃がさない", "連投マン参上"]
	if kind == "shooter":
		return ["指示します", "そこ避けて", "こう動いて", "弾幕いくぞ"]
	if kind == "long_comment_guy":
		return ["長文失礼します", "結論から言うと", "読んでください", "要約すると無理"]
	if kind == "clipper":
		return ["悪質切り抜き中", "今の切り取る", "サムネにする", "そこだけ使う"]
	if kind == "unread_maro":
		return ["未読です", "読んで", "マロ溜めるな", "返事まだ？"]
	if kind == "ghost_comment":
		return ["見てるよ", "うしろ", "消えないよ", "既読つけて"]
	return ["草", "それな〜", "逃げろ", "BANできる？", "右いけ右"]

static func random_speech(kind: String, rng: RandomNumberGenerator) -> String:
	var lines: Array[String] = speech_lines(kind)
	if lines.is_empty():
		return ""
	return lines[rng.randi_range(0, lines.size() - 1)]

static func build_enemy(kind: String, pos: Vector2, uid: int, shoot: float, giant_power: float = 0.0, speech_text: String = "") -> Dictionary:
	var data: Dictionary = enemy_data(kind)
	if kind == "noise_ghost_comment":
		data["displayName"] = "召喚ノイズ"
	var is_boss_kind: bool = bool(data.get("isBoss", false)) or kind.begins_with("boss_") or kind in [
		"bugged_final_boss", "bugged_final_boss_stun", "last_offline", "pitch_police_chief", "red_pen_review_chief", "red_pen_retake_dragon", "collab_crusher"
	]
	_spawn_token_serial += 1
	if giant_power > 0.0:
		data["hp"] = float(data["hp"]) * lerpf(1.25, 1.5, giant_power)
		data["radius"] = float(data["radius"]) * lerpf(1.5, 2.0, giant_power)
	var enemy: Dictionary = {
		"uid": uid,
		"kind": kind,
		"displayName": String(data.get("displayName", kind)),
		"pos": pos,
		"hp": data["hp"],
		"max_hp": data["hp"],
		"speed": data["speed"],
		"radius": data["radius"],
		"hurtboxRadius": maxf(0.0, float(data.get("hurtboxRadius", data.get("weaponHurtRadius", data.get("radius", 20.0))))),
		"combatType": HardModeSystemScript.normalize_combat_type(data.get("combatType", "standard")),
		"minimumAttackInterval": maxf(0.1, float(data.get("minimumAttackInterval", 0.1))),
		"isBoss": is_boss_kind,
		"bossId": String(data.get("bossId", kind if is_boss_kind else "")),
		"spawnToken": "%s:%d:%d" % [kind, uid, _spawn_token_serial],
		"score": data["score"],
		"exp": data["exp"],
		"expValue": data["exp"],
		"baseExp": data["exp"],
		"behavior": data["behavior"],
		"shoot": shoot,
		"speechText": speech_text,
		"hitFlashDuration": float(data.get("hitFlashDuration", hit_flash_duration_for_kind(kind, is_boss_kind))),
		"hitFlashTimer": 0.0,
		"knockbackResistance": float(data.get("knockbackResistance", knockback_resistance_for_kind(kind, is_boss_kind))),
		"canBeKnockedBack": bool(data.get("canBeKnockedBack", can_knockback_kind(kind, is_boss_kind))),
		"pullResistance": clampf(float(data.get("pullResistance", 0.0)), 0.0, 1.0),
		"contactDamage": int(data.get("contactDamage", contact_damage_for_kind(kind, is_boss_kind))),
		"knockbackVelocity": Vector2.ZERO,
		"stunTimer": 0.0,
		"defeatPending": false,
		"defeatDelay": 0.0,
		"defeatResolved": false,
		"spawnGraceTimer": 0.45,
		"lastHitOwner": "",
		"defeatOwner": "",
		"removeReason": ""
	}
	enemy["occupancyManaged"] = not is_boss_kind and not bool(data.get("fixedHazard", false))
	enemy["spawnPriority"] = HardModeSystemScript.spawn_priority_for_source("normal_wave")
	if bool(data.get("noRewards", false)):
		enemy["noRewards"] = true
	if bool(data.get("relayBossSummon", false)):
		enemy["relayBossSummon"] = true
	if data.has("canBePulled"):
		enemy["canBePulled"] = bool(data.get("canBePulled", false))
	else:
		enemy["canBePulled"] = _default_can_be_pulled(enemy)
	if kind == "enemy_backseat_controller" or kind == "enemy_dot_invader" or kind == "enemy_lag_comment" or kind == "enemy_strategy_wiki_ojisan" or kind == "enemy_bullet_drone" or kind == "enemy_noise_ghost_comment":
		enemy["movePhase"] = float(uid % 19) * 0.37
	if kind == "enemy_backseat_controller":
		enemy["dashTimer"] = 0.0
	if kind == "enemy_dot_invader":
		enemy["sideMoveDir"] = -1.0 if uid % 2 == 0 else 1.0
	if kind == "enemy_lag_comment":
		enemy["warpWarningTimer"] = 0.0
	if kind == "enemy_fake_first_timer":
		enemy["ambushActive"] = false
	if kind == "enemy_wrong_way_kart":
		enemy["ignoreMovementWalls"] = true
		enemy["lifeTimer"] = 5.4
	if kind == "enemy_jammer_cone":
		enemy["lifeTimer"] = float(data.get("lifeTime", 8.0))
	if kind == "enemy_noise_ghost_comment" or kind == "layer_lost" or kind == "undo_ghost":
		enemy["phaseTimer"] = float(uid % 13) * 0.21
	if kind == "red_pen_teacher":
		enemy["shotWarningTimer"] = 0.0
		enemy["shotWarningDuration"] = DRAWING_RED_PEN_PRE_SHOT_WARNING_TIME
		enemy["shotWarningDir"] = Vector2.ZERO
	if kind == "bucket_fill_slime":
		enemy["puddleTimer"] = DRAWING_BUCKET_PUDDLE_INTERVAL * 0.55
		enemy["puddleTimes"] = []
	if kind == "collab_messenger_pigeon":
		enemy["messengerWarningTimer"] = 0.0
		enemy["messengerDashTimer"] = 0.0
		enemy["messengerDashDir"] = Vector2.ZERO
		enemy["messengerDashTarget"] = Vector2.ZERO
		enemy["messengerTargetsPartner"] = uid % 2 == 0
	if kind == "collab_discord_troll":
		enemy["collabPulseWarningTimer"] = 0.0
	if kind == "collab_volume_police":
		enemy["collabFieldWarningTimer"] = 0.0
	if kind == "collab_exclusive_listener":
		enemy["collabPartnerAttached"] = false
	if kind == "collab_division_noise":
		enemy["canBecomeCollabPassTarget"] = true
		enemy["canBecomeLinkedTrollEnemy"] = false
		enemy["partnerTargetPriority"] = 3.0
		enemy["collabPassTargetPriority"] = 3.0
		enemy["divisionOrbitPhase"] = float(uid % 17) * 0.37
	if kind == "collab_mute_core":
		enemy["canBecomeCollabPassTarget"] = false
		enemy["canBecomeLinkedTrollEnemy"] = false
		enemy["hasSpecialTargetMarker"] = true
	if is_genre_event_enemy(kind):
		enemy["genreEventEnemy"] = true
	return enemy

static func drawing_non_shooter_enemy(rng: RandomNumberGenerator) -> String:
	var roll := rng.randf()
	if roll < 0.42:
		return "drawing_fix_note"
	if roll < 0.71:
		return "layer_lost"
	return "bucket_fill_slime"

static func drawing_shooter_limit_for_target(target: Node) -> int:
	var t := effective_wave_time(float(target.get("elapsed")), bool(target.get("quick_test_mode")))
	return DRAWING_LATE_MAX_SHOOTER_ENEMIES if t >= DRAWING_LATE_SHOOTER_TIME else DRAWING_MAX_SHOOTER_ENEMIES

static func drawing_shooter_count(enemies: Array) -> int:
	var count := 0
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item
		if String(enemy.get("kind", "")) == "red_pen_teacher" and not bool(enemy.get("defeatPending", false)) and not bool(enemy.get("defeatResolved", false)):
			count += 1
	return count

static func drawing_red_pen_projectile_count(bullets: Array, uid: int) -> int:
	var count := 0
	for bullet_item in bullets:
		var bullet: Dictionary = bullet_item
		if String(bullet.get("sourceKind", "")) == "red_pen_teacher" and int(bullet.get("sourceUid", -1)) == uid:
			count += 1
	return count

static func collab_enemy_limit(kind: String) -> int:
	match kind:
		"collab_comparison_troll":
			return 6
		"collab_messenger_pigeon":
			return 4
		"collab_discord_troll":
			return 4
		"collab_volume_police":
			return 3
		"collab_exclusive_listener":
			return 2
		"collab_division_noise":
			return 3
		"collab_mute_core":
			return 1
	return 99

static func collab_enemy_count(enemies: Array, kind: String) -> int:
	var count := 0
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if String(enemy.get("kind", "")) != kind:
			continue
		if bool(enemy.get("defeatPending", false)) or bool(enemy.get("defeatResolved", false)):
			continue
		count += 1
	return count

static func collab_spawn_kind_for_target(target: Node, requested_kind: String, rng: RandomNumberGenerator) -> String:
	if String(target.get("current_stream_frame_id")) != "collab":
		return requested_kind
	var enemies: Array = target.get("enemies") as Array
	if collab_enemy_count(enemies, requested_kind) < collab_enemy_limit(requested_kind):
		return requested_kind
	if bool(target.get("relay_mode")):
		var fallback_groups: Array = [["collab_comparison_troll", "collab_messenger_pigeon"]]
		if requested_kind == "collab_discord_troll" or requested_kind == "collab_volume_police" or requested_kind == "collab_exclusive_listener":
			fallback_groups.append(["collab_discord_troll", "collab_volume_police"])
		for group in fallback_groups:
			for candidate in group:
				if collab_enemy_count(enemies, String(candidate)) < collab_enemy_limit(String(candidate)):
					return String(candidate)
		return ""
	for _attempt in range(8):
		var candidate := pick_collab_enemy(float(target.get("elapsed")), bool(target.get("quick_test_mode")), rng)
		if collab_enemy_count(enemies, candidate) < collab_enemy_limit(candidate):
			return candidate
	return ""

static func dangerous_enemy_class(kind: String) -> String:
	if kind == "shooter" or kind == "enemy_armchair_strategist" or kind == "enemy_strategy_wiki_ojisan" or kind == "enemy_dot_invader" or kind == "enemy_bullet_drone" or kind == "request_spammer" or kind == "red_pen_teacher":
		return "ranged"
	if kind == "enemy_strategy_wiki_ojisan" or kind == "enemy_bullet_drone":
		return "spread"
	if kind == "clipper" or kind == "enemy_backseat_controller" or kind == "enemy_wrong_way_kart" or kind == "collab_messenger_pigeon":
		return "charge"
	if kind == "enemy_fake_first_timer" or kind == "enemy_fake_gift_box":
		return "ambush"
	return ""

static func _danger_caps_for_target(target: Node) -> Dictionary:
	var config: Dictionary = target.get("relay_mode_config") as Dictionary
	var caps: Dictionary = config.get("dangerEnemyCaps", {}) as Dictionary
	var mode := "relay" if bool(target.get("relay_mode")) else "normal"
	return caps.get(mode, {}) as Dictionary

static func _active_dangerous_enemy_count(enemies: Array, danger_class: String) -> int:
	var count := 0
	for item in enemies:
		var enemy: Dictionary = item as Dictionary
		if bool(enemy.get("defeatPending", false)) or bool(enemy.get("defeatResolved", false)):
			continue
		if _kind_belongs_to_danger_class(String(enemy.get("kind", "")), danger_class):
			count += 1
	return count

static func dangerous_enemy_count(enemies: Array, danger_class: String) -> int:
	return _active_dangerous_enemy_count(enemies, danger_class)

static func active_normal_wave_count(enemies: Array) -> int:
	var count := 0
	for item in enemies:
		var enemy: Dictionary = item as Dictionary
		if String(enemy.get("spawnSource", "")) != "normal_wave":
			continue
		if bool(enemy.get("defeatPending", false)) or bool(enemy.get("defeatResolved", false)):
			continue
		count += 1
	return count

static func active_enemy_occupancy(enemies: Array) -> int:
	var count := 0
	for item in enemies:
		if not item is Dictionary:
			continue
		var enemy: Dictionary = item as Dictionary
		if not bool(enemy.get("occupancyManaged", not bool(enemy.get("isBoss", false)))):
			continue
		if bool(enemy.get("defeatPending", false)) or bool(enemy.get("defeatResolved", false)):
			continue
		if bool(enemy.get("fixedHazard", false)) or bool(enemy.get("relayBossNoiseSummon", false)) and not bool(enemy.get("hardFinalBossSummonRewardable", false)):
			continue
		count += 1
	return count

static func _kind_belongs_to_danger_class(kind: String, danger_class: String) -> bool:
	if danger_class == "spread":
		return kind == "enemy_strategy_wiki_ojisan" or kind == "enemy_bullet_drone"
	return dangerous_enemy_class(kind) == danger_class

static func _safe_fallback_for_target(target: Node) -> String:
	var frame_id := String(target.get("current_stream_frame_id"))
	if frame_id == "gameplay":
		return "enemy_spoiler_comment"
	if frame_id == "singing" or frame_id == "song":
		return "pitch_police"
	if frame_id == "drawing":
		return "drawing_fix_note"
	if frame_id == "collab":
		return "collab_comparison_troll"
	return "troll"

static func _safe_kind_for_target(target: Node, requested_kind: String) -> String:
	var danger_class := dangerous_enemy_class(requested_kind)
	if danger_class == "":
		return requested_kind
	var enemies: Array = target.get("enemies") as Array
	var caps := _danger_caps_for_target(target)
	if (requested_kind == "enemy_strategy_wiki_ojisan" or requested_kind == "enemy_bullet_drone") and _active_dangerous_enemy_count(enemies, "spread") >= int(caps.get("maxActiveSpreadShooters", 2)):
		return _safe_fallback_for_target(target)
	if danger_class == "ranged" and _active_dangerous_enemy_count(enemies, "ranged") >= int(caps.get("maxActiveRangedEnemies", 6)):
		return _safe_fallback_for_target(target)
	if danger_class == "charge" and _active_dangerous_enemy_count(enemies, "charge") >= int(caps.get("maxSimultaneousChargeAttacks", 2)):
		return _safe_fallback_for_target(target)
	if danger_class == "ambush" and _active_dangerous_enemy_count(enemies, "ambush") >= int(caps.get("maxSimultaneousAmbushAttacks", 2)):
		return _safe_fallback_for_target(target)
	return requested_kind

static func linked_troll_enemy_kinds_for_tag(tag: String) -> Array[String]:
	match tag:
		"long_comment":
			return ["long_comment_guy"]
		"malicious_clipper":
			return ["clipper"]
		"unread_marshmallow":
			return ["unread_maro"]
		"comment_linked":
			return ["fast"]
		"skill_troll":
			return ["enemy_spoiler_comment", "fast"]
		"backseat_troll":
			return ["enemy_backseat_controller"]
		"spoiler_troll":
			return ["enemy_spoiler_comment"]
		"game_troll":
			return ["enemy_armchair_strategist", "enemy_lag_comment", "troll"]
		"pitch_police":
			return ["pitch_police"]
		"key_troll":
			return ["request_spammer"]
		"breath_troll":
			return ["fast_call_fan"]
		"lyrics_troll":
			return ["song_lyric_spoiler_comment"]
		"song_choice_troll":
			return ["song_noise_comment"]
		"comparison_troll":
			return ["long_comment_guy"]
		"collab_comparison_troll":
			return ["collab_comparison_troll"]
		"collab_messenger_pigeon":
			return ["collab_messenger_pigeon"]
		"collab_discord_troll":
			return ["collab_discord_troll"]
		"collab_volume_police":
			return ["collab_volume_police"]
		"collab_exclusive_listener":
			return ["collab_exclusive_listener"]
		"song_troll":
			return ["troll"]
		"correction_comment":
			return ["drawing_fix_note"]
		"red_pen_teacher":
			return ["red_pen_teacher"]
		"lost_layer":
			return ["layer_lost"]
		"paint_bucket_slime":
			return ["bucket_fill_slime"]
		"discord_troll":
			return ["enemy_backseat_controller"]
		"voice_troll":
			return ["shooter"]
		"collab_troll":
			return ["fast"]
		"fanbase_troll":
			return ["troll"]
	return []

static func pick_linked_troll_enemy_kind(enemy_tags: Array, rng: RandomNumberGenerator) -> String:
	var candidates: Array[String] = []
	for raw_tag in enemy_tags:
		for kind in linked_troll_enemy_kinds_for_tag(String(raw_tag)):
			if not candidates.has(kind):
				candidates.append(kind)
	if candidates.is_empty():
		return ""
	return candidates[rng.randi_range(0, candidates.size() - 1)]

static func spawn_enemy_for_target(target: Node, kind: String, arena: Rect2, rng: RandomNumberGenerator, pos: Vector2 = Vector2.INF, linked_comment_id: String = "", linked_speech_text: String = "", runtime_variant: String = "", spawn_source: String = "") -> int:
	var spawn_pos: Vector2 = pos
	var giant_power: float = 0.0
	if ModifierSystem.has_effect_for_target(target, "giant_enemies"):
		giant_power = ModifierSystem.effect_rate_for_target(target, "giant_enemies")
	var enemies: Array = target.get("enemies") as Array
	if String(target.get("current_stream_frame_id")) == "drawing" and kind == "red_pen_teacher" and linked_comment_id == "":
		if drawing_shooter_count(enemies) >= drawing_shooter_limit_for_target(target):
			kind = drawing_non_shooter_enemy(rng)
	if String(target.get("current_stream_frame_id")) == "collab":
		if linked_comment_id == "":
			kind = collab_spawn_kind_for_target(target, kind, rng)
			if kind == "":
				return -1
		elif collab_enemy_count(enemies, kind) >= collab_enemy_limit(kind):
			return -1
	kind = _safe_kind_for_target(target, kind)
	var data := enemy_data(kind)
	var spawn_radius := float(data.get("radius", 22.0))
	if giant_power > 0.0:
		spawn_radius *= lerpf(1.5, 2.0, giant_power)
	if spawn_pos == Vector2.INF:
		spawn_pos = spawn_position_for_target(target, arena, rng, spawn_radius)
		if spawn_pos == Vector2.INF:
			return -1
	elif spawn_source == "hard_wave":
		spawn_pos = resolve_pattern_spawn_position_for_target(target, arena, rng, spawn_pos, spawn_radius)
		if spawn_pos == Vector2.INF:
			return -1
	var shoot_seed: float = rng.randf_range(0.6, 1.4) if pos == Vector2.INF else 1.0
	if kind == "shooter":
		shoot_seed = rng.randf_range(1.4, SHOOTER_FIRE_INTERVAL_MAX)
	elif kind == "enemy_armchair_strategist":
		shoot_seed = rng.randf_range(1.3, ARMCHAIR_FIRE_INTERVAL_MAX)
	elif kind == "red_pen_teacher":
		shoot_seed = rng.randf_range(1.6, DRAWING_RED_PEN_FIRE_INTERVAL_MAX)
	elif kind == "enemy_dot_invader":
		shoot_seed = rng.randf_range(1.0, DOT_INVADER_FIRE_INTERVAL_MAX)
	elif kind == "enemy_strategy_wiki_ojisan":
		shoot_seed = rng.randf_range(1.4, WIKI_FIRE_INTERVAL_MAX)
	elif kind == "enemy_bullet_drone":
		shoot_seed = rng.randf_range(1.2, DRONE_FIRE_INTERVAL_MAX)
	elif kind == "enemy_lag_comment":
		shoot_seed = rng.randf_range(LAG_WARP_COOLDOWN_MIN, LAG_WARP_COOLDOWN_MAX)
	var next_uid: int = int(target.get("next_enemy_uid"))
	var normal_speech_rate := 0.20 if String(target.get("current_stream_frame_id")) == "collab" else 1.0
	var linked_comments: Variant = target.get("troll_linked_comments")
	if linked_comments is Dictionary:
		var active_linked_count := 0
		for raw_link in (linked_comments as Dictionary).values():
			if not (raw_link is Dictionary):
				continue
			var link: Dictionary = raw_link as Dictionary
			if String(link.get("state", "")) == "active" and bool(link.get("enemySpawned", false)):
				active_linked_count += 1
		if active_linked_count >= 3:
			normal_speech_rate *= 0.25
		elif active_linked_count >= 2:
			normal_speech_rate *= 0.50
	if String(target.get("current_stream_frame_id")) == "collab" and int(target.get("collab_pass_target_uid")) >= 0:
		normal_speech_rate *= 0.75
	var speech_text: String = ""
	if linked_comment_id == "" and rng.randf() < 0.33 * normal_speech_rate:
		speech_text = random_speech(kind, rng)
	var enemy := apply_runtime_variant(build_enemy(kind, spawn_pos, next_uid, shoot_seed, giant_power, speech_text), runtime_variant)
	if bool(target.get("relay_mode")) and not bool(enemy.get("relayBoss", false)) and not bool(enemy.get("relayBossSummon", false)):
		var profile := RelayStageProfileSystemScript.profile_for_target(target)
		var hp_rate := float(profile.get("hp", 1.0))
		enemy["hp"] = float(enemy.get("hp", 1.0)) * hp_rate
		enemy["max_hp"] = float(enemy.get("max_hp", enemy.get("hp", 1.0))) * hp_rate
		enemy["speed"] = float(enemy.get("speed", 0.0)) * float(profile.get("speed", 1.0))
		enemy["relayUpperWeight"] = float(profile.get("upperWeight", 1.0))
	if HardModeSystemScript.is_high_difficulty_target(target) and not bool(enemy.get("isBoss", false)):
		var hard_role := "finalBossSummon" if bool(enemy.get("relayBossSummon", false)) else "normal"
		var hard_runtime := HardModeSystemScript.runtime_for_target(target)
		HardModeSystemScript.apply_enemy_runtime_stats(enemy, hard_runtime, hard_role)
		enemy["shoot"] = HardModeSystemScript.attack_interval_for_enemy(enemy, float(enemy.get("shoot", 1.0)), hard_runtime)
		if enemy.has("puddleTimer"):
			enemy["puddleTimer"] = HardModeSystemScript.attack_interval_for_enemy(enemy, float(enemy.get("puddleTimer", DRAWING_BUCKET_PUDDLE_INTERVAL)), hard_runtime)
	if linked_comment_id != "":
		enemy["linkedTrollCommentId"] = linked_comment_id
		enemy["linkedSpeechText"] = linked_speech_text.strip_edges()
		enemy["linkedSpeechAge"] = 0.0
		enemy["linkedSpeechAlpha"] = 1.0
		enemy["speechText"] = ""
	if is_genre_event_enemy(kind):
		enemy["genreEventEnemy"] = true
	if spawn_source != "":
		enemy["spawnSource"] = spawn_source
	elif linked_comment_id != "":
		enemy["spawnSource"] = "comment_linked"
	elif is_genre_event_enemy(kind):
		enemy["spawnSource"] = "genre_event"
	else:
		enemy["spawnSource"] = "system"
	enemy["spawnPriority"] = HardModeSystemScript.spawn_priority_for_source(String(enemy.get("spawnSource", "system")))
	if bool(enemy.get("isBoss", false)):
		enemy["occupancyManaged"] = false
	enemies.append(enemy)
	target.set("enemies", enemies)
	target.set("next_enemy_uid", next_uid + 1)
	discover_spawned_enemies_for_target(target)
	return next_uid

static func apply_runtime_variant(enemy: Dictionary, runtime_variant: String) -> Dictionary:
	if runtime_variant != "comment_linked" or String(enemy.get("kind", "")) != "fast":
		return enemy
	enemy["runtimeVariant"] = "comment_linked"
	enemy["max_hp"] = maxf(1.0, float(roundi(float(enemy.get("max_hp", 1.0)) * 0.75)))
	enemy["hp"] = enemy["max_hp"]
	enemy["contactDamage"] = 10
	enemy["baseExp"] = 1
	enemy["exp"] = 1
	enemy["expValue"] = 1
	enemy["scoreMultiplier"] = 1.0
	return enemy

static func kill_events(enemy: Dictionary, split_enemy: bool, rng: RandomNumberGenerator, split_probability: float = 0.35) -> Dictionary:
	var pos: Vector2 = Vector2(enemy["pos"])
	var splits: Array = []
	if split_enemy and rng.randf() < clampf(split_probability, 0.0, 1.0) and String(enemy["kind"]) != "troll":
		splits.append(pos + Vector2(18, 0))
		splits.append(pos + Vector2(-18, 0))
	return {
		"splits": splits,
		"chat": "今のBANうまい" if rng.randf() < 0.16 else ""
	}

static func gameplay_marshmallow_drop_request_for_target(target: Node, enemy: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	if String(target.get("current_stream_frame_id")) != "gameplay":
		return {}
	if bool(enemy.get("isBoss", false)):
		return {}
	var active_genre_event := String(target.get("active_genre_event"))
	var chance := GAMEPLAY_MARSHMALLOW_DROP_CHANCE
	var source := "enemy_defeat"
	if active_genre_event == "race":
		chance = GAMEPLAY_RACE_MARSHMALLOW_DROP_CHANCE
	elif active_genre_event == "bullet_hell":
		chance = GAMEPLAY_BULLET_HELL_MARSHMALLOW_DROP_CHANCE
	elif active_genre_event == "horror":
		chance = GAMEPLAY_HORROR_MARSHMALLOW_DROP_CHANCE
		if String(enemy.get("source", "")) == "fake_gift":
			chance = GAMEPLAY_FAKE_GIFT_MARSHMALLOW_DROP_CHANCE
			source = "fake_gift_defeat"
	if rng.randf() >= chance:
		return {}
	return {
		"pos": Vector2(enemy.get("pos", Vector2.ZERO)),
		"source": source
	}

static func apply_kill_for_target(target: Node, enemy: Dictionary, arena: Rect2, rng: RandomNumberGenerator) -> Dictionary:
	target.set("kills", int(target.get("kills")) + 1)
	if not bool(enemy.get("_codex_defeat_recorded", false)):
		enemy["_codex_defeat_recorded"] = true
		var codex_id := canonical_codex_enemy_id(enemy)
		var difficulty_value: Variant = target.get("run_difficulty_id")
		var difficulty_id := String(difficulty_value if difficulty_value != null else "normal")
		if codex_id != "":
			CodexManager.record_enemy_defeat(codex_id, difficulty_id)
	if bool(enemy.get("noRewards", false)) and not bool(enemy.get("relayBoss", false)):
		return {"enemyDefeated": true, "noRewards": true}
	if target.has_method("get") and String(enemy.get("spawnSource", "")) == "normal_wave":
		var balance_stats: Dictionary = target.get("balance_debug_stats") as Dictionary
		balance_stats["defeats"] = int(balance_stats.get("defeats", 0)) + 1
		target.set("balance_debug_stats", balance_stats)
	if target.has_method("_on_enemy_defeated_for_collab_pass"):
		target.call("_on_enemy_defeated_for_collab_pass", enemy)
	if target.has_method("_on_enemy_defeated_for_collab_boss"):
		target.call("_on_enemy_defeated_for_collab_boss", enemy)
	if bool(enemy.get("relayBoss", false)):
		if target.has_method("_on_relay_boss_enemy_defeated"):
			target.call("_on_relay_boss_enemy_defeated", enemy)
		return {"enemyDefeated": true, "noRewards": true}
	if bool(enemy.get("noRewards", false)) or bool(enemy.get("relayBossSummon", false)):
		if bool(enemy.get("relayBossNoiseSummon", false)) and target.has_method("_on_relay_boss_noise_summon_defeated"):
			target.call("_on_relay_boss_noise_summon_defeated", enemy)
		if target.has_method("_on_enemy_defeated_for_collab_pass"):
			target.call("_on_enemy_defeated_for_collab_pass", enemy)
		ExpSystem.drop_from_enemy_for_target(target, enemy)
		return {"enemyDefeated": true, "noRewards": true}
	var active_genre_event := String(target.get("active_genre_event"))
	var comment_event_ids: Array[String] = []
	if active_genre_event == "bullet_hell" and String(enemy.get("defeatSource", enemy.get("lastHitSource", ""))) == "genre_stg_shot":
		target.set("genre_result_stg_shot_kill_count", int(target.get("genre_result_stg_shot_kill_count")) + 1)
	if active_genre_event == "horror" and String(enemy.get("source", "")) == "fake_gift":
		target.set("genre_result_fake_gift_defeat_count", int(target.get("genre_result_fake_gift_defeat_count")) + 1)
		comment_event_ids.append("gameplay_horror_fake_gift_defeated")
	var is_boss: bool = bool(enemy.get("isBoss", false)) or String(enemy.get("kind", "")) == "boss_super_long_comment"
	append_defeat_fx_for_target(target, enemy, is_boss)
	var linked_comment_id := String(enemy.get("linkedTrollCommentId", ""))
	if linked_comment_id != "":
		enemy["linkedSpeechText"] = ""
		append_linked_troll_ban_fx_for_target(target, enemy)
	_apply_song_live_heat_for_kill(target, enemy)
	_apply_drawing_progress_for_kill(target, enemy)
	if is_boss:
		var tracker_variant: Variant = target.get("power_up_run_tracker")
		if tracker_variant != null and tracker_variant.has_method("register_boss_defeat"):
			var defeat_owner := String(enemy.get("defeatOwner", ""))
			var pp_reward_id := String(enemy.get("ppRewardId", enemy.get("bossId", enemy.get("kind", ""))))
			var hard_boss_role := String(enemy.get("hardBossRole", ""))
			var reward_key := "boss:%s:%s" % [String(tracker_variant.run_id), pp_reward_id]
			if hard_boss_role != "":
				reward_key += ":" + hard_boss_role
			var defeat_data := {
				"bossId": String(enemy.get("bossId", enemy.get("kind", ""))),
				"ppRewardId": pp_reward_id,
				"basePpReward": int(enemy.get("basePpReward", 0)),
				"isPpRewardTarget": bool(enemy.get("isPpRewardTarget", false)),
				"isFirstDefeatRewardTarget": bool(enemy.get("isFirstDefeatRewardTarget", false)),
				"hardBossRole": hard_boss_role,
				"ppRate": float(enemy.get("hardPpRate", 1.0)),
				"defeatReason": "player_side_damage" if defeat_owner == "player" else defeat_owner,
				"rewardKey": reward_key
			}
			tracker_variant.register_boss_defeat(defeat_data)
		var boss_result := BossSystemScript.apply_defeat_for_target(target, enemy)
		if target.has_method("_on_regular_boss_defeated"):
			target.call("_on_regular_boss_defeated", enemy)
		return boss_result
	target.set("score", int(target.get("score")) + ScoreSystem.enemy_score_for_target(target, enemy))
	ExpSystem.drop_from_enemy_for_target(target, enemy)
	grant_linked_troll_defeat_reward_for_target(target, enemy)
	var marshmallow_drop_requests: Array = []
	var marshmallow_drop_request: Dictionary = gameplay_marshmallow_drop_request_for_target(target, enemy, rng)
	if not marshmallow_drop_request.is_empty():
		marshmallow_drop_requests.append(marshmallow_drop_request)
	var split_enemy: bool = ModifierSystem.has_effect_for_target(target, "split_enemy")
	var hard_split_rate := HardModeSystemScript.active_comment_param(HardModeSystemScript.runtime_for_target(target), "splitProbabilityRate", 1.0)
	var events: Dictionary = kill_events(enemy, split_enemy, rng, minf(1.0, 0.35 * hard_split_rate))
	var splits: Array = events["splits"] as Array
	for item in splits:
		spawn_enemy_for_target(target, "troll", arena, rng, Vector2(item))
	return {
		"chat": String(events["chat"]),
		"commentEventIds": comment_event_ids,
		"marshmallowDropRequests": marshmallow_drop_requests,
		"linkedTrollCommentIds": [linked_comment_id] if linked_comment_id != "" else [],
		"enemyDefeated": true
	}

static func _apply_song_live_heat_for_kill(target: Node, enemy: Dictionary) -> void:
	if not target.has_method("_add_song_live_heat"):
		return
	var stream_frame_id := String(target.get("current_stream_frame_id"))
	if stream_frame_id != "singing" and stream_frame_id != "song":
		return
	var radius := float(enemy.get("radius", 20.0))
	var max_hp := float(enemy.get("max_hp", enemy.get("maxHp", enemy.get("hp", 0.0))))
	var gain := 0.15
	if bool(enemy.get("isBoss", false)) or max_hp >= 90.0 or radius >= 44.0:
		gain = 1.2
	elif max_hp >= 18.0 or radius >= 26.0:
		gain = 0.5
	target.call("_add_song_live_heat", gain, "enemy_defeat")

static func _apply_drawing_progress_for_kill(target: Node, enemy: Dictionary) -> void:
	if not target.has_method("_add_drawing_progress_from_enemy_defeat"):
		return
	if String(target.get("current_stream_frame_id")) != "drawing":
		return
	if bool(enemy.get("isBoss", false)):
		return
	target.call("_add_drawing_progress_from_enemy_defeat", enemy)

static func defeat_delay_for_enemy(enemy: Dictionary) -> float:
	var base_delay: float = 0.55 if bool(enemy.get("isBoss", false)) else 0.12
	return maxf(base_delay, float(enemy.get("hitFlashDuration", 0.10)))

static func queue_defeat_for_enemy(enemy: Dictionary) -> void:
	if bool(enemy.get("defeatPending", false)) or bool(enemy.get("defeatResolved", false)):
		return
	var delay: float = defeat_delay_for_enemy(enemy)
	enemy["defeatPending"] = true
	enemy["defeatDelay"] = delay
	enemy["defeatDelayMax"] = delay
	enemy["killQueued"] = true
	if bool(enemy.get("isBoss", false)):
		enemy["hitFlashColor"] = Color(1.0, 0.96, 0.66, 1.0)
		enemy["hitFlashDuration"] = maxf(float(enemy.get("hitFlashDuration", 0.10)), 0.18)
		enemy["hitFlashTimer"] = maxf(float(enemy.get("hitFlashTimer", 0.0)), float(enemy["hitFlashDuration"]))

static func should_keep_enemy(enemy_value: Variant) -> bool:
	var enemy: Dictionary = enemy_value as Dictionary
	return not bool(enemy.get("defeatResolved", false))

static func add_knockback_for_enemy(enemy: Dictionary, direction: Vector2, distance: float) -> void:
	if distance <= 0.0:
		return
	var dir: Vector2 = direction.normalized()
	if dir.length() < 0.1:
		return
	var velocity: Vector2 = Vector2(enemy.get("knockbackVelocity", Vector2.ZERO))
	velocity += dir * distance * KNOCKBACK_SPEED_SCALE
	if velocity.length() > KNOCKBACK_MAX_SPEED:
		velocity = velocity.normalized() * KNOCKBACK_MAX_SPEED
	enemy["knockbackVelocity"] = velocity

static func clamp_enemy_pos_to_arena(pos: Vector2, arena: Rect2) -> Vector2:
	return Vector2(
		clampf(pos.x, arena.position.x + 15.0, arena.end.x - 15.0),
		clampf(pos.y, arena.position.y + 15.0, arena.end.y - 15.0)
	)

static func clamp_enemy_pos_to_arena_for_enemy(enemy: Dictionary, pos: Vector2, arena: Rect2) -> Vector2:
	var margin := 15.0
	if ignores_movement_walls(enemy) and (bool(enemy.get("isBoss", false)) or String(enemy.get("kind", "")) == BossSystemScript.BOSS_BUGGED_FINAL_BOSS):
		margin = maxf(margin, float(enemy.get("radius", 22.0)) + 2.0)
	return Vector2(
		clampf(pos.x, arena.position.x + margin, arena.end.x - margin),
		clampf(pos.y, arena.position.y + margin, arena.end.y - margin)
	)

static func apply_knockback_motion(enemy: Dictionary, enemy_pos: Vector2, previous_enemy_pos: Vector2, delta: float, arena: Rect2, effect_walls: Array, stream_frame_id: String) -> Vector2:
	var velocity: Vector2 = Vector2(enemy.get("knockbackVelocity", Vector2.ZERO))
	if velocity.length() <= KNOCKBACK_STOP_SPEED:
		enemy["knockbackVelocity"] = Vector2.ZERO
		return clamp_enemy_pos_to_arena_for_enemy(enemy, enemy_pos, arena) if ignores_movement_walls(enemy) else enemy_pos
	enemy_pos += velocity * delta
	enemy_pos = clamp_enemy_pos_to_arena_for_enemy(enemy, enemy_pos, arena) if ignores_movement_walls(enemy) else clamp_enemy_pos_to_arena(enemy_pos, arena)
	if not ignores_movement_walls(enemy):
		enemy_pos = PlayerSystem.resolve_wall_collision(enemy_pos, previous_enemy_pos, wall_navigation_radius(enemy), effect_walls, stream_frame_id)
	enemy_pos = clamp_enemy_pos_to_arena_for_enemy(enemy, enemy_pos, arena) if ignores_movement_walls(enemy) else clamp_enemy_pos_to_arena(enemy_pos, arena)
	velocity *= exp(-KNOCKBACK_DECAY_RATE * delta)
	if velocity.length() <= KNOCKBACK_STOP_SPEED:
		velocity = Vector2.ZERO
	enemy["knockbackVelocity"] = velocity
	return enemy_pos

static func ignores_movement_walls(enemy: Dictionary) -> bool:
	if bool(enemy.get("ignoreMovementWalls", false)):
		return true
	var boss_id: String = String(enemy.get("bossId", enemy.get("kind", "")))
	if bool(enemy.get("isBoss", false)) and (boss_id == BossSystemScript.BOSS_KUSO_MARO_KING or boss_id == BossSystemScript.BOSS_BUGGED_FINAL_BOSS or boss_id == BossSystemScript.BOSS_PITCH_POLICE_CHIEF):
		return true
	var kind := String(enemy.get("kind", ""))
	return kind == BossSystemScript.BOSS_BUGGED_FINAL_BOSS or kind == BossSystemScript.BOSS_PITCH_POLICE_CHIEF

static func wall_navigation_radius(enemy: Dictionary) -> float:
	var radius := float(enemy.get("radius", 22.0))
	if bool(enemy.get("isBoss", false)):
		return minf(radius, maxf(BOSS_WALL_NAVIGATION_RADIUS_MIN, radius * BOSS_WALL_NAVIGATION_RADIUS_RATE))
	return minf(radius, maxf(ENEMY_WALL_NAVIGATION_RADIUS_MIN, radius * ENEMY_WALL_NAVIGATION_RADIUS_RATE))

static func movement_wall_rects(effect_walls: Array, stream_frame_id: String) -> Array:
	var frame_id := stream_frame_id
	if frame_id == "":
		frame_id = "zatsudan"
	if not movement_wall_cache.has(frame_id):
		movement_wall_cache[frame_id] = DrawDataSystem.static_wall_rects(frame_id)
	var walls: Array = (movement_wall_cache[frame_id] as Array).duplicate()
	for effect_wall in effect_walls:
		walls.append(effect_wall as Rect2)
	return walls

static func resolve_enemy_wall_collision(pos: Vector2, previous_pos: Vector2, radius: float, walls: Array) -> Vector2:
	var resolved: Vector2 = pos
	for wall_item in walls:
		var wall: Rect2 = wall_item as Rect2
		var grown: Rect2 = wall.grow(radius)
		if not grown.has_point(resolved):
			continue
		if previous_pos.x <= wall.position.x:
			resolved.x = wall.position.x - radius
		elif previous_pos.x >= wall.end.x:
			resolved.x = wall.end.x + radius
		elif previous_pos.y <= wall.position.y:
			resolved.y = wall.position.y - radius
		elif previous_pos.y >= wall.end.y:
			resolved.y = wall.end.y + radius
		else:
			var left_push: float = absf(resolved.x - grown.position.x)
			var right_push: float = absf(grown.end.x - resolved.x)
			var top_push: float = absf(resolved.y - grown.position.y)
			var bottom_push: float = absf(grown.end.y - resolved.y)
			var min_push: float = minf(minf(left_push, right_push), minf(top_push, bottom_push))
			if min_push == left_push:
				resolved.x = grown.position.x
			elif min_push == right_push:
				resolved.x = grown.end.x
			elif min_push == top_push:
				resolved.y = grown.position.y
			else:
				resolved.y = grown.end.y
	return resolved

static func segment_intersects_rect(from_pos: Vector2, to_pos: Vector2, rect: Rect2) -> bool:
	if rect.has_point(from_pos) or rect.has_point(to_pos):
		return true
	var delta: Vector2 = to_pos - from_pos
	var t_min := 0.0
	var t_max := 1.0
	if absf(delta.x) < 0.001:
		if from_pos.x < rect.position.x or from_pos.x > rect.end.x:
			return false
	else:
		var tx1: float = (rect.position.x - from_pos.x) / delta.x
		var tx2: float = (rect.end.x - from_pos.x) / delta.x
		t_min = maxf(t_min, minf(tx1, tx2))
		t_max = minf(t_max, maxf(tx1, tx2))
	if absf(delta.y) < 0.001:
		if from_pos.y < rect.position.y or from_pos.y > rect.end.y:
			return false
	else:
		var ty1: float = (rect.position.y - from_pos.y) / delta.y
		var ty2: float = (rect.end.y - from_pos.y) / delta.y
		t_min = maxf(t_min, minf(ty1, ty2))
		t_max = minf(t_max, maxf(ty1, ty2))
	return t_max >= t_min and t_max >= 0.0 and t_min <= 1.0

static func point_distance_to_rect(pos: Vector2, rect: Rect2) -> float:
	var dx: float = maxf(maxf(rect.position.x - pos.x, 0.0), pos.x - rect.end.x)
	var dy: float = maxf(maxf(rect.position.y - pos.y, 0.0), pos.y - rect.end.y)
	return Vector2(dx, dy).length()

static func choose_vertical_avoidance(enemy: Dictionary, enemy_pos: Vector2, goal_pos: Vector2, rect: Rect2) -> Vector2:
	if goal_pos.y <= rect.position.y:
		enemy["wallAvoidY"] = -1
		return Vector2.UP
	if goal_pos.y >= rect.end.y:
		enemy["wallAvoidY"] = 1
		return Vector2.DOWN
	var desired_delta := goal_pos.y - enemy_pos.y
	if absf(desired_delta) > ENEMY_WALL_AVOIDANCE_ROUTE_TURN_THRESHOLD:
		var route := 1 if desired_delta > 0.0 else -1
		enemy["wallAvoidY"] = route
		return Vector2.DOWN if route > 0 else Vector2.UP
	var stored_route := int(enemy.get("wallAvoidY", 0))
	if stored_route != 0:
		return Vector2.DOWN if stored_route > 0 else Vector2.UP
	if absf(desired_delta) > 18.0:
		stored_route = 1 if desired_delta > 0.0 else -1
		enemy["wallAvoidY"] = stored_route
		return Vector2.DOWN if stored_route > 0 else Vector2.UP
	var top_cost: float = absf(enemy_pos.y - rect.position.y) + absf(goal_pos.y - rect.position.y) * 0.35
	var bottom_cost: float = absf(enemy_pos.y - rect.end.y) + absf(goal_pos.y - rect.end.y) * 0.35
	if absf(top_cost - bottom_cost) <= 8.0:
		stored_route = -1 if int(enemy.get("uid", 0)) % 2 == 0 else 1
	else:
		stored_route = -1 if top_cost < bottom_cost else 1
	enemy["wallAvoidY"] = stored_route
	return Vector2.DOWN if stored_route > 0 else Vector2.UP

static func choose_horizontal_avoidance(enemy: Dictionary, enemy_pos: Vector2, goal_pos: Vector2, rect: Rect2) -> Vector2:
	if goal_pos.x <= rect.position.x:
		enemy["wallAvoidX"] = -1
		return Vector2.LEFT
	if goal_pos.x >= rect.end.x:
		enemy["wallAvoidX"] = 1
		return Vector2.RIGHT
	var desired_delta := goal_pos.x - enemy_pos.x
	if absf(desired_delta) > ENEMY_WALL_AVOIDANCE_ROUTE_TURN_THRESHOLD:
		var route := 1 if desired_delta > 0.0 else -1
		enemy["wallAvoidX"] = route
		return Vector2.RIGHT if route > 0 else Vector2.LEFT
	var stored_route := int(enemy.get("wallAvoidX", 0))
	if stored_route != 0:
		return Vector2.RIGHT if stored_route > 0 else Vector2.LEFT
	if absf(desired_delta) > 18.0:
		stored_route = 1 if desired_delta > 0.0 else -1
		enemy["wallAvoidX"] = stored_route
		return Vector2.RIGHT if stored_route > 0 else Vector2.LEFT
	var left_cost: float = absf(enemy_pos.x - rect.position.x) + absf(goal_pos.x - rect.position.x) * 0.35
	var right_cost: float = absf(enemy_pos.x - rect.end.x) + absf(goal_pos.x - rect.end.x) * 0.35
	if absf(left_cost - right_cost) <= 8.0:
		stored_route = -1 if int(enemy.get("uid", 0)) % 2 == 0 else 1
	else:
		stored_route = -1 if left_cost < right_cost else 1
	enemy["wallAvoidX"] = stored_route
	return Vector2.RIGHT if stored_route > 0 else Vector2.LEFT

static func wall_avoidance_direction(enemy: Dictionary, enemy_pos: Vector2, goal_pos: Vector2, radius: float, walls: Array) -> Vector2:
	var best_dir := Vector2.ZERO
	var best_score := INF
	var desired: Vector2 = goal_pos - enemy_pos
	if desired.length() < 0.1:
		return best_dir
	for wall_item in walls:
		var wall: Rect2 = wall_item as Rect2
		var grown: Rect2 = wall.grow(radius + ENEMY_WALL_AVOIDANCE_MARGIN)
		if not segment_intersects_rect(enemy_pos, goal_pos, grown):
			continue
		var horizontal_block: bool = (
			(enemy_pos.x <= grown.position.x and goal_pos.x >= grown.position.x)
			or (enemy_pos.x >= grown.end.x and goal_pos.x <= grown.end.x)
		)
		var vertical_block: bool = (
			(enemy_pos.y <= grown.position.y and goal_pos.y >= grown.position.y)
			or (enemy_pos.y >= grown.end.y and goal_pos.y <= grown.end.y)
		)
		var enemy_y_inside: bool = enemy_pos.y >= grown.position.y and enemy_pos.y <= grown.end.y
		var enemy_x_inside: bool = enemy_pos.x >= grown.position.x and enemy_pos.x <= grown.end.x
		var candidate := Vector2.ZERO
		if (horizontal_block and enemy_y_inside) or (enemy_y_inside and absf(desired.x) >= absf(desired.y)):
			candidate = choose_vertical_avoidance(enemy, enemy_pos, goal_pos, grown)
		elif (vertical_block and enemy_x_inside) or (enemy_x_inside and absf(desired.y) > absf(desired.x)):
			candidate = choose_horizontal_avoidance(enemy, enemy_pos, goal_pos, grown)
		else:
			candidate = choose_vertical_avoidance(enemy, enemy_pos, goal_pos, grown) if absf(desired.x) >= absf(desired.y) else choose_horizontal_avoidance(enemy, enemy_pos, goal_pos, grown)
		var score := point_distance_to_rect(enemy_pos, grown)
		if score < best_score:
			best_score = score
			best_dir = candidate
	return best_dir

static func forward_safe_avoidance_dir(base_dir: Vector2, avoid_dir: Vector2) -> Vector2:
	if avoid_dir.length() < 0.1:
		return Vector2.ZERO
	var safe_dir := avoid_dir.normalized()
	var backward: float = safe_dir.dot(base_dir)
	if backward >= -0.05:
		return safe_dir
	safe_dir = safe_dir - base_dir * backward
	if safe_dir.length() < 0.1:
		return Vector2.ZERO
	return safe_dir.normalized()

static func blended_enemy_move_dir(base_dir: Vector2, avoid_dir: Vector2, dir_power: float) -> Vector2:
	var safe_avoid := forward_safe_avoidance_dir(base_dir, avoid_dir)
	if safe_avoid.length() < 0.1:
		return base_dir * dir_power
	var mixed := (base_dir * (1.0 - ENEMY_WALL_AVOIDANCE_BLEND) + safe_avoid * ENEMY_WALL_AVOIDANCE_BLEND)
	if mixed.length() < 0.1:
		return base_dir * dir_power
	mixed = mixed.normalized()
	if mixed.dot(base_dir) < ENEMY_WALL_AVOIDANCE_MIN_FORWARD_DOT:
		var side := safe_avoid - base_dir * safe_avoid.dot(base_dir)
		if side.length() < 0.1:
			return base_dir * dir_power
		var side_rate := sqrt(1.0 - ENEMY_WALL_AVOIDANCE_MIN_FORWARD_DOT * ENEMY_WALL_AVOIDANCE_MIN_FORWARD_DOT)
		mixed = (base_dir * ENEMY_WALL_AVOIDANCE_MIN_FORWARD_DOT + side.normalized() * side_rate).normalized()
	return mixed * dir_power

static func move_enemy_with_wall_avoidance(enemy: Dictionary, enemy_pos: Vector2, dir: Vector2, speed: float, delta: float, arena: Rect2, walls: Array, player_pos: Vector2) -> Vector2:
	var dir_power := dir.length()
	if dir_power < 0.1 or speed <= 0.0:
		return enemy_pos
	if ignores_movement_walls(enemy):
		enemy.erase("wallAvoidX")
		enemy.erase("wallAvoidY")
		return clamp_enemy_pos_to_arena_for_enemy(enemy, enemy_pos + dir * speed * delta, arena)
	var radius := wall_navigation_radius(enemy)
	var base_dir := dir / dir_power
	var to_player := player_pos - enemy_pos
	var goal_pos := enemy_pos + base_dir * ENEMY_WALL_AVOIDANCE_FALLBACK_DISTANCE
	var to_player_dist_sq := to_player.length_squared()
	if to_player_dist_sq > 0.01 and base_dir.dot(to_player / sqrt(to_player_dist_sq)) > 0.35:
		goal_pos = player_pos
	var avoid_dir := wall_avoidance_direction(enemy, enemy_pos, goal_pos, radius, walls)
	var safe_avoid_dir := forward_safe_avoidance_dir(base_dir, avoid_dir)
	var move_dir := blended_enemy_move_dir(base_dir, safe_avoid_dir, dir_power)
	if avoid_dir.length() <= 0.1:
		enemy.erase("wallAvoidX")
		enemy.erase("wallAvoidY")

	var previous_pos := enemy_pos
	var expected_distance := speed * delta * dir_power
	var moved_pos := enemy_pos + move_dir * speed * delta
	moved_pos = clamp_enemy_pos_to_arena(moved_pos, arena)
	moved_pos = resolve_enemy_wall_collision(moved_pos, previous_pos, radius, walls)
	moved_pos = clamp_enemy_pos_to_arena(moved_pos, arena)
	var moved_step := moved_pos - previous_pos
	var moved_forward_enough := moved_step.dot(base_dir) >= expected_distance * 0.18
	var moved_distance_sq := moved_pos.distance_squared_to(previous_pos)
	var moved_min_distance := expected_distance * 0.3
	if avoid_dir.length() <= 0.1 or (moved_distance_sq >= moved_min_distance * moved_min_distance and (not bool(enemy.get("isBoss", false)) or moved_forward_enough)):
		return moved_pos

	if safe_avoid_dir.length() <= 0.1:
		return moved_pos

	var fallback_pos := enemy_pos + safe_avoid_dir * speed * delta * dir_power
	fallback_pos = clamp_enemy_pos_to_arena(fallback_pos, arena)
	fallback_pos = resolve_enemy_wall_collision(fallback_pos, previous_pos, radius, walls)
	fallback_pos = clamp_enemy_pos_to_arena(fallback_pos, arena)
	var fallback_step := fallback_pos - previous_pos
	var best_pos := moved_pos
	if fallback_step.dot(base_dir) >= -0.01 and fallback_pos.distance_squared_to(previous_pos) > moved_distance_sq:
		best_pos = fallback_pos
	if bool(enemy.get("isBoss", false)):
		var unstick_pos := enemy_pos + base_dir * speed * delta * dir_power * BOSS_WALL_UNSTICK_STEP_RATE
		unstick_pos = clamp_enemy_pos_to_arena(unstick_pos, arena)
		var unstick_step := unstick_pos - previous_pos
		var best_step := best_pos - previous_pos
		if unstick_step.dot(base_dir) > best_step.dot(base_dir) + 0.01:
			return unstick_pos
	return best_pos

static func append_defeat_fx_for_target(target: Node, enemy: Dictionary, is_boss: bool = false) -> void:
	if bool(enemy.get("defeatFxSpawned", false)):
		return
	enemy["defeatFxSpawned"] = true
	var hit_fx: Array = target.get("hit_fx") as Array
	var radius: float = float(enemy.get("radius", 22.0))
	hit_fx.append({
		"kind": "enemy_defeat",
		"pos": Vector2(enemy.get("pos", Vector2.ZERO)),
		"radius": radius,
		"life": 0.44 if is_boss else 0.28,
		"maxLife": 0.44 if is_boss else 0.28,
		"boss": is_boss
	})
	target.set("hit_fx", hit_fx)

static func append_linked_troll_ban_fx_for_target(target: Node, enemy: Dictionary) -> void:
	var hit_fx: Array = target.get("hit_fx") as Array
	var pos := Vector2(enemy.get("pos", Vector2.ZERO))
	var to_enemy := pos - Vector2(target.get("player_pos"))
	var direction := to_enemy.normalized() if to_enemy.length_squared() > 0.01 else Vector2.RIGHT
	var radius := float(enemy.get("radius", 22.0))
	hit_fx.append({
		"kind": "ban_judgement_defeat",
		"pos": pos,
		"dir": direction,
		"life": 0.46,
		"maxLife": 0.46,
		"radius": radius,
		"boss": false
	})
	target.set("hit_fx", hit_fx)

static func grant_linked_troll_defeat_reward_for_target(target: Node, enemy: Dictionary) -> Dictionary:
	var reward := {"bonusExp": 0, "giftExpectationGain": 0}
	if not LINKED_TROLL_DEFEAT_REWARD_ENABLED:
		return reward
	if String(enemy.get("linkedTrollCommentId", "")) == "" or bool(enemy.get("linkedTrollRewardGranted", false)):
		return reward
	enemy["linkedTrollRewardGranted"] = true
	var base_exp := float(enemy.get("baseExp", enemy.get("expValue", enemy.get("exp", 1))))
	var bonus_exp := maxi(LINKED_TROLL_MINIMUM_BONUS_EXP, ExpSystem.drop_bonus_value_for_target(target, Vector2(enemy.get("pos", Vector2.ZERO)), base_exp, LINKED_TROLL_BONUS_EXP_MULTIPLIER, "linked_troll_bonus"))
	reward["bonusExp"] = bonus_exp
	var run_gain := int(target.get("linked_troll_gift_expectation_gain"))
	var remaining_gift_gain := maxi(0, LINKED_TROLL_MAX_GIFT_EXPECTATION_GAIN_PER_RUN - run_gain)
	var gift_gain := mini(LINKED_TROLL_GIFT_EXPECTATION_GAIN, remaining_gift_gain)
	if gift_gain > 0:
		target.set("gift_hype", clampi(int(target.get("gift_hype")) + gift_gain, 0, 100))
		target.set("max_gift_hype", maxi(int(target.get("max_gift_hype")), int(target.get("gift_hype"))))
		target.set("linked_troll_gift_expectation_gain", run_gain + gift_gain)
	reward["giftExpectationGain"] = gift_gain
	append_linked_troll_reward_popup_for_target(target, enemy, bonus_exp, gift_gain)
	return reward

static func append_linked_troll_reward_popup_for_target(target: Node, enemy: Dictionary, bonus_exp: int, gift_gain: int) -> void:
	var hit_fx: Array = target.get("hit_fx") as Array
	var pos := Vector2(enemy.get("pos", Vector2.ZERO))
	var radius := float(enemy.get("radius", 22.0))
	var popup_pos := pos + Vector2(-52.0, -radius - 76.0)
	hit_fx.append({
		"kind": "pickup_text",
		"pos": popup_pos,
		"vel": Vector2(0.0, -34.0),
		"life": 0.84,
		"maxLife": 0.84,
		"text": "BAN BONUS",
		"color": Color("#ff5a8f")
	})
	hit_fx.append({
		"kind": "pickup_text",
		"pos": popup_pos + Vector2(0.0, 18.0),
		"vel": Vector2(0.0, -30.0),
		"life": 0.76,
		"maxLife": 0.76,
		"text": "+%d EXP" % bonus_exp,
		"color": Color("#74dcff")
	})
	if gift_gain > 0:
		hit_fx.append({
			"kind": "pickup_text",
			"pos": popup_pos + Vector2(0.0, 36.0),
			"vel": Vector2(0.0, -26.0),
			"life": 0.72,
			"maxLife": 0.72,
			"text": "GIFT +%d" % gift_gain,
			"color": Color("#ffd66a")
		})
	target.set("hit_fx", hit_fx)

static func update_enemy_world(context: Dictionary) -> Dictionary:
	var result: Dictionary = {
		"bullets": context["bullets"],
		"damageEvents": []
	}
	var enemy_result: Dictionary = update_enemies(context)
	result["bullets"] = enemy_result["bullets"]
	_merge_damage_events(result, enemy_result)
	var bullet_result: Dictionary = update_enemy_bullets({
		"delta": context["delta"],
		"bullets": result["bullets"],
		"playerPos": context["playerPos"],
		"arena": context["arena"],
		"bulletHell": context["bulletHell"]
	})
	result["bullets"] = bullet_result["bullets"]
	_merge_damage_events(result, bullet_result)
	return result

static func update_world_for_target(target: Node, delta: float, rng: RandomNumberGenerator, arena: Rect2) -> Dictionary:
	# Special systems may append directly to target.enemies.  Keep codex
	# discovery at this shared world boundary instead of scattering calls.
	discover_spawned_enemies_for_target(target)
	var hard_runtime := HardModeSystemScript.runtime_for_target(target)
	var hard_comment_speed := HardModeSystemScript.active_comment_param(hard_runtime, "enemyMoveSpeedRate", HardModeSystemScript.active_comment_param(hard_runtime, "enemySpeedRate", 1.0))
	var result: Dictionary = update_enemy_world({
		"delta": delta,
		"rng": rng,
		"enemies": target.get("enemies"),
		"bullets": target.get("enemy_bullets"),
		"playerPos": target.get("player_pos"),
		"arena": arena,
		"enemySpeedRate": ModifierSystem.effect_rate_for_target(target, "enemy_speed") * maxf(0.1, hard_comment_speed),
		"godReservation": ModifierSystem.has_effect_for_target(target, "god_reservation"),
		"godReservationRate": ModifierSystem.effect_rate_for_target(target, "god_reservation"),
		"songEnemyMoveMultiplier": float(target.call("_song_enemy_move_speed_multiplier")) if target.has_method("_song_enemy_move_speed_multiplier") else 1.0,
		"bulletHell": String(target.get("active_genre_event")) == "bullet_hell",
		"effectWalls": target.get("effect_walls"),
		"streamFrameId": target.get("current_stream_frame_id"),
		"collisionFrameId": DrawDataSystem.collision_frame_id_for_target(target),
		"target": target
	})
	_apply_hard_projectile_rates_for_target(target, result["bullets"] as Array)
	target.set("enemy_bullets", result["bullets"])
	apply_pending_defeats_for_target(target, result, arena, rng)
	return result

static func _apply_hard_projectile_rates_for_target(target: Node, bullets: Array) -> void:
	if not HardModeSystemScript.is_high_difficulty_target(target):
		return
	var hard_runtime := HardModeSystemScript.runtime_for_target(target)
	var enemies: Array = target.get("enemies") as Array
	var by_uid: Dictionary = {}
	for item in enemies:
		var enemy: Dictionary = item as Dictionary
		by_uid[int(enemy.get("uid", -1))] = enemy
	for item in bullets:
		var bullet: Dictionary = item as Dictionary
		if bool(bullet.get("difficultyRuntimeApplied", false)):
			continue
		var source: Dictionary = by_uid.get(int(bullet.get("sourceUid", -1)), {}) as Dictionary
		if source.is_empty() or bool(source.get("isBoss", false)) or bool(source.get("relayBoss", false)):
			continue
		bullet["vel"] = Vector2(bullet.get("vel", Vector2.ZERO)) * HardModeSystemScript.projectile_speed_rate_for_enemy(source, hard_runtime)
		bullet["damage"] = HardModeSystemScript.scaled_damage(float(bullet.get("damage", 0)), float(source.get("projectileDamageRate", 1.0)))
		bullet["difficultyRuntimeApplied"] = true

static func apply_pending_defeats_for_target(target: Node, result: Dictionary, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var enemies: Array = target.get("enemies") as Array
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item
		if not bool(enemy.get("defeatPending", false)):
			continue
		if bool(enemy.get("defeatResolved", false)):
			continue
		if (bool(enemy.get("isBoss", false)) or bool(enemy.get("relayBoss", false))) and not bool(enemy.get("defeatReactionApplied", false)):
			enemy["defeatReactionApplied"] = true
			merge_kill_feedback(result, {
				"screenShakePower": 0.55,
				"screenShakeDuration": 0.25,
				"hitStop": 0.10,
				"screenFlashColor": Color(1.0, 0.94, 0.50, 0.34),
				"screenFlashDuration": 0.16
			})
		if float(enemy.get("defeatDelay", 0.0)) > 0.0:
			continue
		enemy["defeatResolved"] = true
		var kill_result: Dictionary = apply_kill_for_target(target, enemy, arena, rng)
		merge_kill_feedback(result, kill_result)
		var hard_runtime := HardModeSystemScript.runtime_for_target(target)
		if not hard_runtime.is_empty():
			hard_runtime["totalEnemiesDefeated"] = int(hard_runtime.get("totalEnemiesDefeated", 0)) + 1
	var current_enemies: Array = target.get("enemies") as Array
	var kept_enemies: Array = []
	for enemy_item in current_enemies:
		if should_keep_enemy(enemy_item):
			kept_enemies.append(enemy_item)
	target.set("enemies", kept_enemies)

static func merge_kill_feedback(target: Dictionary, source: Dictionary) -> void:
	var chats: Array = target.get("chats", []) as Array
	var chat: String = String(source.get("chat", ""))
	if chat != "":
		chats.append(chat)
	for item in (source.get("chats", []) as Array):
		chats.append(String(item))
	target["chats"] = chats
	var comment_event_ids: Array = target.get("commentEventIds", []) as Array
	for item in (source.get("commentEventIds", []) as Array):
		var event_id := String(item)
		if event_id != "" and not comment_event_ids.has(event_id):
			comment_event_ids.append(event_id)
	if not comment_event_ids.is_empty():
		target["commentEventIds"] = comment_event_ids
	var toasts: Array = target.get("toasts", []) as Array
	for item in (source.get("toasts", []) as Array):
		toasts.append(String(item))
	if not toasts.is_empty():
		target["toasts"] = toasts
	if float(source.get("screenShakePower", 0.0)) > float(target.get("screenShakePower", 0.0)):
		target["screenShakePower"] = float(source.get("screenShakePower", 0.0))
	if float(source.get("screenShakeDuration", 0.0)) > float(target.get("screenShakeDuration", 0.0)):
		target["screenShakeDuration"] = float(source.get("screenShakeDuration", 0.0))
	if float(source.get("hitStop", 0.0)) > float(target.get("hitStop", 0.0)):
		target["hitStop"] = float(source.get("hitStop", 0.0))
	if float(source.get("screenFlashDuration", 0.0)) > float(target.get("screenFlashDuration", 0.0)):
		target["screenFlashDuration"] = float(source.get("screenFlashDuration", 0.0))
		target["screenFlashColor"] = source.get("screenFlashColor", Color.WHITE)
	var marshmallow_drop_requests: Array = target.get("marshmallowDropRequests", []) as Array
	for item in (source.get("marshmallowDropRequests", []) as Array):
		marshmallow_drop_requests.append(item)
	if not marshmallow_drop_requests.is_empty():
		target["marshmallowDropRequests"] = marshmallow_drop_requests
	if bool(source.get("enemyDefeated", false)):
		target["enemyDefeated"] = true
	var linked_comment_ids: Array = target.get("linkedTrollCommentIds", []) as Array
	for item in (source.get("linkedTrollCommentIds", []) as Array):
		var linked_comment_id := String(item)
		if linked_comment_id != "" and not linked_comment_ids.has(linked_comment_id):
			linked_comment_ids.append(linked_comment_id)
	if not linked_comment_ids.is_empty():
		target["linkedTrollCommentIds"] = linked_comment_ids

static func _merge_damage_events(target: Dictionary, source: Dictionary) -> void:
	var target_items: Array = target.get("damageEvents", []) as Array
	var source_items: Array = source.get("damageEvents", []) as Array
	for item in source_items:
		target_items.append(item)

static func update_enemies(context: Dictionary) -> Dictionary:
	var result: Dictionary = {
		"bullets": context["bullets"],
		"damageEvents": [],
		"chats": []
	}
	var damage_events: Array = result["damageEvents"] as Array
	var bullets: Array = context["bullets"] as Array
	var enemies: Array = context["enemies"] as Array
	var rng: RandomNumberGenerator = context["rng"] as RandomNumberGenerator
	var delta: float = float(context["delta"])
	var player_pos: Vector2 = Vector2(context["playerPos"])
	var arena: Rect2 = context["arena"] as Rect2
	var effect_walls: Array = context["effectWalls"] as Array
	var stream_frame_id: String = String(context["streamFrameId"])
	var collision_frame_id: String = String(context.get("collisionFrameId", stream_frame_id))
	var max_enemy_bullets := DRAWING_MAX_NORMAL_ENEMY_PROJECTILES if stream_frame_id == "drawing" else MAX_ENEMY_BULLETS
	var target: Variant = context.get("target", null)
	var hard_runtime: Dictionary = {}
	if target != null:
		hard_runtime = HardModeSystemScript.runtime_for_target(target)
	var walls: Array = movement_wall_rects(effect_walls, collision_frame_id)
	var collab_partner_pos := player_pos
	var collab_partner_available := false
	if stream_frame_id == "collab" and target != null:
		var partner_id := String(target.get("collab_partner_id"))
		if partner_id != "":
			collab_partner_pos = Vector2(target.get("collab_partner_pos"))
			collab_partner_available = collab_partner_pos != Vector2.ZERO
	var speed_rate: float = 1.0 + 0.45 * float(context["enemySpeedRate"])
	if bool(context["godReservation"]):
		speed_rate += 0.10 * float(context["godReservationRate"])
	speed_rate *= maxf(0.1, float(context.get("songEnemyMoveMultiplier", 1.0)))
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item
		var enemy_pos: Vector2 = Vector2(enemy["pos"])
		var previous_enemy_pos: Vector2 = enemy_pos
		enemy["shieldContactSuppressTimer"] = maxf(0.0, float(enemy.get("shieldContactSuppressTimer", 0.0)) - delta)
		enemy["hitFlashTimer"] = maxf(0.0, float(enemy.get("hitFlashTimer", 0.0)) - delta)
		enemy["spawnGraceTimer"] = maxf(0.0, float(enemy.get("spawnGraceTimer", 0.0)) - delta)
		enemy["syncStarCarrierRevealTimer"] = maxf(0.0, float(enemy.get("syncStarCarrierRevealTimer", 0.0)) - delta)
		if bool(enemy.get("relayBossNoiseSummon", false)):
			var summon_lifetime := float(enemy.get("relayBossSummonLifetime", enemy.get("lifeTimer", 0.0))) - delta
			enemy["relayBossSummonLifetime"] = summon_lifetime
			enemy["lifeTimer"] = summon_lifetime
			if summon_lifetime <= 0.0:
				enemy["removeReason"] = "natural_despawn"
				enemy["defeatResolved"] = true
				continue
		if bool(enemy.get("defeatPending", false)):
			enemy_pos = apply_knockback_motion(enemy, enemy_pos, previous_enemy_pos, delta, arena, effect_walls, stream_frame_id)
			enemy["pos"] = enemy_pos
			enemy["defeatDelay"] = maxf(0.0, float(enemy.get("defeatDelay", 0.0)) - delta)
			continue
		var stun_timer: float = float(enemy.get("stunTimer", 0.0))
		if stun_timer > 0.0:
			enemy["stunTimer"] = maxf(0.0, stun_timer - delta)
			enemy_pos = apply_knockback_motion(enemy, enemy_pos, previous_enemy_pos, delta, arena, effect_walls, stream_frame_id)
			enemy["pos"] = enemy_pos
			continue
		var behavior: String = String(enemy["behavior"])
		var to_player: Vector2 = player_pos - enemy_pos
		var dist: float = to_player.length()
		var linked_speech_text := String(enemy.get("linkedSpeechText", ""))
		if linked_speech_text != "":
			var speech_age := float(enemy.get("linkedSpeechAge", 0.0)) + delta
			enemy["linkedSpeechAge"] = speech_age
			enemy["linkedSpeechAlpha"] = 1.0 if speech_age <= 1.5 or dist <= 260.0 else 0.78
		var to_player_dir := to_player / dist if dist > 0.1 else Vector2.ZERO
		var dir: Vector2 = to_player_dir
		var local_speed_rate: float = 1.0 if bool(enemy.get("isBoss", false)) else speed_rate
		var speed: float = float(enemy["speed"]) * local_speed_rate
		var slow_timer: float = float(enemy.get("slowTimer", 0.0))
		if slow_timer > 0.0:
			var slow_rate: float = clampf(float(enemy.get("slowRate", 0.0)), 0.0, 0.85)
			speed *= 1.0 - slow_rate
			enemy["slowTimer"] = maxf(0.0, slow_timer - delta)
		if behavior == "shooter":
			if dist < 250.0:
				dir *= -1.0
			elif dist < 360.0:
				dir = Vector2.ZERO
			enemy["shoot"] = float(enemy["shoot"]) - delta
			if float(enemy["shoot"]) <= 0.0 and dist < 650.0:
				enemy["shoot"] = HardModeSystemScript.attack_interval_for_enemy(enemy, rng.randf_range(SHOOTER_FIRE_INTERVAL_MIN, SHOOTER_FIRE_INTERVAL_MAX), hard_runtime)
				if bullets.size() < max_enemy_bullets:
					bullets.append({"pos": enemy_pos, "vel": to_player_dir * 260.0, "life": SHOOTER_BULLET_LIFE, "damage": DamageSystem.ENEMY_BULLET_DAMAGE, "source": "enemy bullet", "sourceKind": String(enemy["kind"]), "sourceUid": int(enemy.get("uid", -1)), "attackType": "projectile", "runtimeVariant": String(enemy.get("runtimeVariant", "")), "clearableByPlayerWeapon": true, "shieldBlockable": true, "erasableByPinkPaint": true})
		elif behavior == "zigzag_chase":
			var base_dir := to_player_dir
			if base_dir.length() < 0.1:
				base_dir = Vector2.RIGHT
			var phase := float(enemy.get("movePhase", 0.0)) + delta * 3.25
			enemy["movePhase"] = phase
			var side := Vector2(-base_dir.y, base_dir.x) * sin(phase) * 0.46
			dir = (base_dir + side).normalized()
			enemy["shoot"] = float(enemy["shoot"]) - delta
			var dash_timer := maxf(0.0, float(enemy.get("dashTimer", 0.0)) - delta)
			if float(enemy["shoot"]) <= 0.0 and dist < 540.0:
				enemy["shoot"] = HardModeSystemScript.attack_interval_for_enemy(enemy, rng.randf_range(3.7, 4.8), hard_runtime)
				dash_timer = 0.34
			if dash_timer > 0.0:
				dir = base_dir * 2.25
			enemy["dashTimer"] = dash_timer
		elif behavior == "keep_distance_shooter":
			var preferred_distance := 260.0
			if dist < preferred_distance - 45.0:
				dir *= -1.0
			elif dist > preferred_distance + 85.0:
				dir *= 0.72
			else:
				dir = Vector2.ZERO
			enemy["shoot"] = float(enemy["shoot"]) - delta
			if float(enemy["shoot"]) <= 0.0 and dist < 720.0:
				enemy["shoot"] = HardModeSystemScript.attack_interval_for_enemy(enemy, rng.randf_range(ARMCHAIR_FIRE_INTERVAL_MIN, ARMCHAIR_FIRE_INTERVAL_MAX), hard_runtime)
				if bullets.size() < max_enemy_bullets:
					var bullet_dir := to_player_dir
					if bullet_dir.length() < 0.1:
						bullet_dir = Vector2.RIGHT
					bullets.append({"pos": enemy_pos + bullet_dir * 18.0, "vel": bullet_dir * 245.0, "life": ARMCHAIR_BULLET_LIFE, "damage": DamageSystem.ENEMY_BULLET_DAMAGE, "hitRadius": 18.0, "source": "enemy bullet", "sourceKind": String(enemy["kind"]), "sourceUid": int(enemy.get("uid", -1)), "attackType": "projectile", "runtimeVariant": String(enemy.get("runtimeVariant", "")), "visualKind": "armchair_comment", "clearableByPlayerWeapon": true, "shieldBlockable": true, "erasableByPinkPaint": true})
		elif behavior == "drawing_red_pen_teacher":
			var red_pen_preferred_distance := 315.0
			var red_pen_base := to_player_dir
			if red_pen_base.length() < 0.1:
				red_pen_base = Vector2.RIGHT
			if dist < red_pen_preferred_distance - 70.0:
				dir = -red_pen_base * 0.72
			elif dist > red_pen_preferred_distance + 120.0:
				dir = red_pen_base * 0.62
			else:
				var red_pen_phase := float(enemy.get("movePhase", 0.0)) + delta * 1.85
				enemy["movePhase"] = red_pen_phase
				dir = Vector2(-red_pen_base.y, red_pen_base.x) * sin(red_pen_phase) * 0.42
			var shot_warning_timer := float(enemy.get("shotWarningTimer", 0.0))
			if shot_warning_timer > 0.0:
				shot_warning_timer = maxf(0.0, shot_warning_timer - delta)
				enemy["shotWarningTimer"] = shot_warning_timer
				dir *= 0.30
				if shot_warning_timer <= 0.0:
					var shot_dir := Vector2(enemy.get("shotWarningDir", red_pen_base))
					if shot_dir.length() < 0.1:
						shot_dir = red_pen_base
					shot_dir = shot_dir.normalized()
					var uid := int(enemy.get("uid", -1))
					if bullets.size() < max_enemy_bullets and drawing_red_pen_projectile_count(bullets, uid) < DRAWING_RED_PEN_MAX_PROJECTILES_PER_ENEMY:
						bullets.append({
							"pos": enemy_pos + shot_dir * 22.0,
							"vel": shot_dir * DRAWING_RED_PEN_PROJECTILE_SPEED,
							"life": DRAWING_RED_PEN_BULLET_LIFE,
							"damage": DRAWING_RED_PEN_PROJECTILE_DAMAGE,
							"hitRadius": 14.0,
							"source": "red pen bullet",
							"sourceKind": "red_pen_teacher",
							"sourceUid": uid,
							"visualKind": "red_pen_mark",
							"shieldBlockable": true,
							"erasableByPinkPaint": true
						})
					enemy["shoot"] = HardModeSystemScript.attack_interval_for_enemy(enemy, rng.randf_range(DRAWING_RED_PEN_FIRE_INTERVAL_MIN, DRAWING_RED_PEN_FIRE_INTERVAL_MAX), hard_runtime)
			else:
				enemy["shoot"] = float(enemy["shoot"]) - delta
				if float(enemy["shoot"]) <= 0.0 and dist < 760.0:
					var uid := int(enemy.get("uid", -1))
					if bullets.size() < max_enemy_bullets and drawing_red_pen_projectile_count(bullets, uid) < DRAWING_RED_PEN_MAX_PROJECTILES_PER_ENEMY:
						var warning_dir := red_pen_base
						if warning_dir.length() < 0.1:
							warning_dir = Vector2.RIGHT
						enemy["shotWarningDir"] = warning_dir.normalized()
						enemy["shotWarningTimer"] = DRAWING_RED_PEN_PRE_SHOT_WARNING_TIME
						enemy["shotWarningDuration"] = DRAWING_RED_PEN_PRE_SHOT_WARNING_TIME
					else:
						enemy["shoot"] = HardModeSystemScript.attack_interval_for_enemy(enemy, 0.45, hard_runtime)
		elif behavior == "stg_side_move":
			var side_dir := float(enemy.get("sideMoveDir", 1.0))
			if enemy_pos.x < arena.position.x + 90.0:
				side_dir = 1.0
			elif enemy_pos.x > arena.end.x - 90.0:
				side_dir = -1.0
			enemy["sideMoveDir"] = side_dir
			var phase := float(enemy.get("movePhase", 0.0)) + delta * 2.65
			enemy["movePhase"] = phase
			dir = (Vector2(side_dir, sin(phase) * 0.38).normalized() * 0.86) + to_player_dir * 0.18
			if dir.length() > 1.0:
				dir = dir.normalized()
			enemy["shoot"] = float(enemy["shoot"]) - delta
			if float(enemy["shoot"]) <= 0.0 and dist < 720.0:
				enemy["shoot"] = HardModeSystemScript.attack_interval_for_enemy(enemy, rng.randf_range(DOT_INVADER_FIRE_INTERVAL_MIN, DOT_INVADER_FIRE_INTERVAL_MAX), hard_runtime)
				if bullets.size() < max_enemy_bullets:
					var bullet_dir := to_player_dir
					if bullet_dir.length() < 0.1:
						bullet_dir = Vector2.DOWN
					bullets.append({"pos": enemy_pos + bullet_dir * 16.0, "vel": bullet_dir * 230.0, "life": DOT_INVADER_BULLET_LIFE, "damage": DamageSystem.ENEMY_BULLET_DAMAGE, "hitRadius": 15.0, "source": "enemy bullet", "sourceKind": String(enemy["kind"]), "sourceUid": int(enemy.get("uid", -1)), "attackType": "projectile", "runtimeVariant": String(enemy.get("runtimeVariant", "")), "visualKind": "dot_invader_bullet", "shieldBlockable": true, "erasableByPinkPaint": true})
		elif behavior == "chase_with_short_warp":
			var lag_base_dir := to_player_dir
			if lag_base_dir.length() < 0.1:
				lag_base_dir = Vector2.RIGHT
			var lag_phase := float(enemy.get("movePhase", 0.0)) + delta * 3.8
			enemy["movePhase"] = lag_phase
			var lag_side := Vector2(-lag_base_dir.y, lag_base_dir.x) * sin(lag_phase) * 0.22
			dir = (lag_base_dir + lag_side).normalized()
			var warp_warning_timer := float(enemy.get("warpWarningTimer", 0.0))
			if warp_warning_timer > 0.0:
				warp_warning_timer = maxf(0.0, warp_warning_timer - delta)
				enemy["warpWarningTimer"] = warp_warning_timer
				dir *= 0.28
				if warp_warning_timer <= 0.0:
					var orbit_sign := -1.0 if int(enemy.get("uid", 0)) % 2 == 0 else 1.0
					var orbit_dir := Vector2(-lag_base_dir.y, lag_base_dir.x) * orbit_sign
					var warp_dir := (lag_base_dir * 0.58 + orbit_dir * 0.42).normalized()
					var warp_distance := rng.randf_range(LAG_WARP_DISTANCE_MIN, LAG_WARP_DISTANCE_MAX)
					enemy_pos = clamp_enemy_pos_to_arena(enemy_pos + warp_dir * warp_distance, arena)
					enemy["hitFlashTimer"] = maxf(float(enemy.get("hitFlashTimer", 0.0)), 0.08)
					enemy["shoot"] = HardModeSystemScript.attack_interval_for_enemy(enemy, rng.randf_range(LAG_WARP_COOLDOWN_MIN, LAG_WARP_COOLDOWN_MAX), hard_runtime)
			else:
				enemy["shoot"] = float(enemy["shoot"]) - delta
				if float(enemy["shoot"]) <= 0.0 and dist < 620.0:
					enemy["warpWarningTimer"] = LAG_WARP_WARNING_TIME
		elif behavior == "slow_spread_shooter":
			var wiki_preferred_distance := 300.0
			if dist < wiki_preferred_distance - 50.0:
				dir *= -0.55
			elif dist > wiki_preferred_distance + 100.0:
				dir *= 0.48
			else:
				var wiki_phase := float(enemy.get("movePhase", 0.0)) + delta * 1.8
				enemy["movePhase"] = wiki_phase
				var wiki_base := to_player_dir
				if wiki_base.length() < 0.1:
					wiki_base = Vector2.RIGHT
				dir = Vector2(-wiki_base.y, wiki_base.x) * sin(wiki_phase) * 0.34
			enemy["shoot"] = float(enemy["shoot"]) - delta
			if float(enemy["shoot"]) <= 0.0 and dist < 740.0:
				enemy["shoot"] = HardModeSystemScript.attack_interval_for_enemy(enemy, rng.randf_range(WIKI_FIRE_INTERVAL_MIN, WIKI_FIRE_INTERVAL_MAX), hard_runtime)
				var wiki_bullet_dir := to_player_dir
				if wiki_bullet_dir.length() < 0.1:
					wiki_bullet_dir = Vector2.RIGHT
				for angle in [-0.18, 0.0, 0.18]:
					if bullets.size() >= max_enemy_bullets:
						break
					var spread_dir := wiki_bullet_dir.rotated(angle)
					bullets.append({"pos": enemy_pos + spread_dir * 22.0, "vel": spread_dir * 210.0, "life": WIKI_BULLET_LIFE, "damage": DamageSystem.SPREAD_ENEMY_BULLET_DAMAGE, "hitRadius": 15.0, "source": "enemy bullet", "sourceKind": String(enemy["kind"]), "sourceUid": int(enemy.get("uid", -1)), "attackType": "spreadProjectile", "runtimeVariant": String(enemy.get("runtimeVariant", "")), "visualKind": "wiki_comment", "shieldBlockable": true, "erasableByPinkPaint": true})
		elif behavior == "ambush_chase":
			var ambush_base_dir := to_player_dir
			if ambush_base_dir.length() < 0.1:
				ambush_base_dir = Vector2.RIGHT
			if dist < 180.0:
				enemy["ambushActive"] = true
			if bool(enemy.get("ambushActive", false)):
				speed *= 2.65
				enemy["hitFlashTimer"] = maxf(float(enemy.get("hitFlashTimer", 0.0)), 0.03)
			dir = ambush_base_dir
		elif behavior == "linear_pass":
			var pass_life := float(enemy.get("lifeTimer", 5.4)) - delta
			enemy["lifeTimer"] = pass_life
			if pass_life <= 0.0:
				enemy["defeatResolved"] = true
				enemy["pos"] = enemy_pos
				continue
			var pass_dir := Vector2(enemy.get("passDir", Vector2.ZERO))
			if pass_dir.length() < 0.1:
				var center := arena.get_center()
				var pass_noise := sin(float(int(enemy.get("uid", 0))) * 12.9898) * 0.16
				if absf(enemy_pos.x - center.x) >= absf(enemy_pos.y - center.y):
					pass_dir = Vector2(-1.0 if enemy_pos.x > center.x else 1.0, pass_noise).normalized()
				else:
					pass_dir = Vector2(pass_noise, -1.0 if enemy_pos.y > center.y else 1.0).normalized()
				enemy["passDir"] = pass_dir
			dir = pass_dir
		elif behavior == "stationary_obstacle":
			var obstacle_life := float(enemy.get("lifeTimer", 8.0)) - delta
			enemy["lifeTimer"] = obstacle_life
			if obstacle_life <= 0.0:
				enemy["defeatResolved"] = true
				enemy["pos"] = enemy_pos
				continue
			dir = Vector2.ZERO
		elif behavior == "drone_keep_distance":
			var drone_base := to_player_dir
			if drone_base.length() < 0.1:
				drone_base = Vector2.DOWN
			var drone_phase := float(enemy.get("movePhase", 0.0)) + delta * 2.25
			enemy["movePhase"] = drone_phase
			var drone_side := Vector2(-drone_base.y, drone_base.x) * sin(drone_phase) * 0.52
			var drone_preferred_distance := 320.0
			if dist < drone_preferred_distance - 60.0:
				dir = (-drone_base + drone_side * 0.55).normalized()
			elif dist > drone_preferred_distance + 110.0:
				dir = (drone_base * 0.65 + drone_side * 0.35).normalized()
			else:
				dir = drone_side.normalized() * 0.58
			enemy["shoot"] = float(enemy["shoot"]) - delta
			if float(enemy["shoot"]) <= 0.0 and dist < 760.0:
				enemy["shoot"] = HardModeSystemScript.attack_interval_for_enemy(enemy, rng.randf_range(DRONE_FIRE_INTERVAL_MIN, DRONE_FIRE_INTERVAL_MAX), hard_runtime)
				for angle in [-0.24, 0.0, 0.24]:
					if bullets.size() >= max_enemy_bullets:
						break
					var drone_bullet_dir := drone_base.rotated(angle)
					bullets.append({"pos": enemy_pos + drone_bullet_dir * 20.0, "vel": drone_bullet_dir * 250.0, "life": DRONE_BULLET_LIFE, "damage": DamageSystem.SPREAD_ENEMY_BULLET_DAMAGE, "hitRadius": 14.0, "source": "enemy bullet", "sourceKind": String(enemy["kind"]), "sourceUid": int(enemy.get("uid", -1)), "attackType": "spreadProjectile", "runtimeVariant": String(enemy.get("runtimeVariant", "")), "visualKind": "drone_bullet", "shieldBlockable": true, "erasableByPinkPaint": true})
		elif behavior == "collab_division_noise":
			var division_anchor := player_pos
			if collab_partner_available:
				division_anchor = (player_pos + collab_partner_pos) * 0.5
			var division_phase := float(enemy.get("divisionOrbitPhase", 0.0)) + delta * 0.72
			enemy["divisionOrbitPhase"] = division_phase
			var division_radius := 118.0 + float(int(enemy.get("uid", 0)) % 3) * 24.0
			var division_target := division_anchor + Vector2(cos(division_phase), sin(division_phase * 0.83)) * division_radius
			var division_delta := division_target - enemy_pos
			dir = division_delta.normalized() if division_delta.length_squared() > 16.0 else Vector2.ZERO
		elif behavior == "collab_mute_core":
			dir = Vector2.ZERO
		elif behavior == "collab_comparison_chase":
			dir = to_player_dir
		elif behavior == "collab_messenger_pigeon":
			var targets_partner := bool(enemy.get("messengerTargetsPartner", false)) and collab_partner_available
			var messenger_target := collab_partner_pos if targets_partner else player_pos
			var messenger_base := messenger_target - enemy_pos
			if messenger_base.length() < 0.1:
				messenger_base = to_player_dir
			if messenger_base.length() < 0.1:
				messenger_base = Vector2.RIGHT
			var messenger_dash_time := float(enemy.get("messengerDashTimer", 0.0))
			var messenger_warning := float(enemy.get("messengerWarningTimer", 0.0))
			if messenger_dash_time > 0.0:
				messenger_dash_time = maxf(0.0, messenger_dash_time - delta)
				enemy["messengerDashTimer"] = messenger_dash_time
				dir = Vector2(enemy.get("messengerDashDir", messenger_base.normalized()))
				if dir.length() < 0.1:
					dir = messenger_base.normalized()
				speed = COLLAB_MESSENGER_DASH_SPEED
				if messenger_dash_time <= 0.0:
					enemy["messengerTargetsPartner"] = not targets_partner
			elif messenger_warning > 0.0:
				messenger_warning = maxf(0.0, messenger_warning - delta)
				enemy["messengerWarningTimer"] = messenger_warning
				dir = messenger_base.normalized() * 0.24
				if messenger_warning <= 0.0:
					var dash_dir := messenger_base.normalized()
					var dash_target := Vector2(enemy.get("messengerDashTarget", messenger_target))
					var dash_distance := enemy_pos.distance_to(dash_target)
					enemy["messengerDashDir"] = dash_dir
					enemy["messengerDashTimer"] = clampf(dash_distance / COLLAB_MESSENGER_DASH_SPEED, 0.28, 0.85)
					if target != null and target.has_method("_spawn_collab_messenger_trail"):
						target.call("_spawn_collab_messenger_trail", enemy_pos, dash_target, COLLAB_MESSENGER_TRAIL_WIDTH, COLLAB_MESSENGER_TRAIL_LIFETIME)
			else:
				dir = messenger_base.normalized() * 0.85
				enemy["shoot"] = float(enemy.get("shoot", 0.0)) - delta
				if float(enemy["shoot"]) <= 0.0:
					enemy["messengerDashTarget"] = messenger_target
					enemy["messengerWarningTimer"] = COLLAB_MESSENGER_DASH_WARNING_DURATION
					enemy["shoot"] = HardModeSystemScript.attack_interval_for_enemy(enemy, COLLAB_MESSENGER_DASH_INTERVAL, hard_runtime)
		elif behavior == "collab_discord_troll":
			dir = to_player_dir
			var pulse_warning := float(enemy.get("collabPulseWarningTimer", 0.0))
			if pulse_warning > 0.0:
				pulse_warning = maxf(0.0, pulse_warning - delta)
				enemy["collabPulseWarningTimer"] = pulse_warning
				dir *= 0.28
				if pulse_warning <= 0.0 and target != null and target.has_method("_trigger_collab_discord_pulse"):
					target.call("_trigger_collab_discord_pulse", enemy_pos, COLLAB_DISCORD_PULSE_RADIUS)
			else:
				enemy["shoot"] = float(enemy.get("shoot", 0.0)) - delta
				if float(enemy["shoot"]) <= 0.0:
					enemy["collabPulseWarningTimer"] = COLLAB_DISCORD_PULSE_WARNING_DURATION
					enemy["shoot"] = HardModeSystemScript.attack_interval_for_enemy(enemy, COLLAB_DISCORD_PULSE_INTERVAL, hard_runtime)
		elif behavior == "collab_volume_police":
			var volume_base := to_player_dir
			if volume_base.length() < 0.1:
				volume_base = Vector2.RIGHT
			var volume_preferred_distance := 260.0
			if dist < volume_preferred_distance - 52.0:
				dir = -volume_base * 0.70
			elif dist > volume_preferred_distance + 98.0:
				dir = volume_base * 0.62
			else:
				dir = Vector2(-volume_base.y, volume_base.x) * 0.38
			var field_warning := float(enemy.get("collabFieldWarningTimer", 0.0))
			if field_warning > 0.0:
				field_warning = maxf(0.0, field_warning - delta)
				enemy["collabFieldWarningTimer"] = field_warning
				dir *= 0.25
				if field_warning <= 0.0 and target != null and target.has_method("_spawn_collab_volume_field"):
					target.call("_spawn_collab_volume_field", enemy_pos, COLLAB_VOLUME_FIELD_RADIUS, COLLAB_VOLUME_FIELD_LIFETIME, 1.25, "volume_police")
			else:
				enemy["shoot"] = float(enemy.get("shoot", 0.0)) - delta
				if float(enemy["shoot"]) <= 0.0:
					enemy["collabFieldWarningTimer"] = COLLAB_VOLUME_FIELD_WARNING_DURATION
					enemy["shoot"] = HardModeSystemScript.attack_interval_for_enemy(enemy, COLLAB_VOLUME_FIELD_INTERVAL, hard_runtime)
		elif behavior == "collab_exclusive_listener":
			if collab_partner_available:
				var partner_delta := collab_partner_pos - enemy_pos
				if bool(enemy.get("collabPartnerAttached", false)):
					var attach_side := -1.0 if int(enemy.get("uid", 0)) % 2 == 0 else 1.0
					enemy_pos = collab_partner_pos + Vector2(attach_side * 18.0, -4.0)
					dir = Vector2.ZERO
				elif partner_delta.length() <= COLLAB_EXCLUSIVE_ATTACH_DISTANCE:
					var attached := false
					if target != null and target.has_method("_try_attach_collab_exclusive_listener"):
						attached = bool(target.call("_try_attach_collab_exclusive_listener", int(enemy.get("uid", -1))))
					if attached:
						enemy["collabPartnerAttached"] = true
					dir = Vector2.ZERO
				else:
					dir = partner_delta.normalized()
			else:
				dir = to_player_dir
		elif behavior == "drawing_bucket_slime":
			var bucket_base := to_player_dir
			if bucket_base.length() < 0.1:
				bucket_base = Vector2.RIGHT
			var bucket_phase := float(enemy.get("movePhase", 0.0)) + delta * 1.35
			enemy["movePhase"] = bucket_phase
			var bucket_side := Vector2(-bucket_base.y, bucket_base.x) * sin(bucket_phase) * 0.22
			dir = (bucket_base + bucket_side).normalized()
			var puddle_times: Array = []
			var raw_puddle_times: Variant = enemy.get("puddleTimes", [])
			if raw_puddle_times is Array:
				for time_value in raw_puddle_times:
					var left := float(time_value) - delta
					if left > 0.0:
						puddle_times.append(left)
			var puddle_timer := float(enemy.get("puddleTimer", DRAWING_BUCKET_PUDDLE_INTERVAL)) - delta
			if puddle_timer <= 0.0:
				if puddle_times.size() < DRAWING_BUCKET_MAX_PUDDLES_PER_ENEMY and target != null and target.has_method("_spawn_drawing_enemy_spilled_paint"):
					var spawned := bool(target.call("_spawn_drawing_enemy_spilled_paint", enemy_pos, DRAWING_BUCKET_PUDDLE_RADIUS, DRAWING_BUCKET_PUDDLE_LIFETIME, DRAWING_BUCKET_PUDDLE_SLOW_RATE))
					if spawned:
						puddle_times.append(DRAWING_BUCKET_PUDDLE_LIFETIME)
				puddle_timer = HardModeSystemScript.attack_interval_for_enemy(enemy, DRAWING_BUCKET_PUDDLE_INTERVAL, hard_runtime)
			enemy["puddleTimer"] = puddle_timer
			enemy["puddleTimes"] = puddle_times
		elif behavior == "ghost_chase":
			var ghost_base := to_player_dir
			if ghost_base.length() < 0.1:
				ghost_base = Vector2.RIGHT
			var ghost_phase := float(enemy.get("phaseTimer", 0.0)) + delta * 2.2
			enemy["phaseTimer"] = ghost_phase
			var ghost_side := Vector2(-ghost_base.y, ghost_base.x) * sin(ghost_phase) * 0.30
			speed *= 0.86 + 0.12 * sin(ghost_phase * 0.7)
			dir = (ghost_base + ghost_side).normalized()
		elif behavior == "charger":
			enemy["shoot"] = float(enemy["shoot"]) - delta
			if float(enemy["shoot"]) < -0.35:
				enemy["shoot"] = HardModeSystemScript.attack_interval_for_enemy(enemy, rng.randf_range(1.2, 2.0), hard_runtime)
			elif float(enemy["shoot"]) <= 0.0:
				dir = to_player_dir * 3.2
			else:
				dir *= 0.55
		enemy_pos = move_enemy_with_wall_avoidance(enemy, enemy_pos, dir, speed, delta, arena, walls, player_pos)
		enemy_pos = apply_knockback_motion(enemy, enemy_pos, enemy_pos, delta, arena, effect_walls, stream_frame_id)
		enemy["pos"] = enemy_pos
		var is_last_offline_body := (bool(enemy.get("relayBoss", false)) or String(enemy.get("bossId", "")) == "last_offline" or String(enemy.get("kind", "")) == "last_offline") and not bool(enemy.get("relayBossSummon", false))
		var contact_radius: float = float(enemy["radius"]) + 22.0
		var summon_spawn_grace := bool(enemy.get("relayBossNoiseSummon", false)) and float(enemy.get("spawnGraceTimer", 0.0)) > 0.0
		var shield_contact_blocked := float(enemy.get("shieldContactSuppressTimer", 0.0)) > 0.0
		if target != null and target.has_method("_enemy_contact_blocked_by_shield"):
			shield_contact_blocked = bool(target.call("_enemy_contact_blocked_by_shield", enemy)) or shield_contact_blocked
		if not is_last_offline_body and not summon_spawn_grace and not shield_contact_blocked and enemy_pos.distance_squared_to(player_pos) < contact_radius * contact_radius:
			var contact_source: String = String(enemy["kind"]) + " contact"
			var contact_damage: int = int(enemy.get("contactDamage", contact_damage_for_kind(String(enemy["kind"]), bool(enemy.get("isBoss", false)))))
			damage_events.append({"source": contact_source, "damage": contact_damage, "enemyId": String(enemy.get("kind", "")), "runtimeVariant": String(enemy.get("runtimeVariant", "")), "attackType": "contact"})
	result["bullets"] = bullets
	return result

static func update_enemy_bullets(context: Dictionary) -> Dictionary:
	var result: Dictionary = {
		"bullets": context["bullets"],
		"damageEvents": []
	}
	var damage_events: Array = result["damageEvents"] as Array
	var bullets: Array = context["bullets"] as Array
	var delta: float = float(context["delta"])
	var player_pos: Vector2 = Vector2(context["playerPos"])
	var arena: Rect2 = context["arena"] as Rect2
	var bullet_hit_rate: float = 0.8 if bool(context["bulletHell"]) else 1.0
	for bullet_item in bullets:
		var bullet: Dictionary = bullet_item
		if float(bullet.get("life", 0.0)) <= 0.0:
			continue
		bullet["pos"] = Vector2(bullet["pos"]) + Vector2(bullet["vel"]) * delta
		bullet["life"] = float(bullet["life"]) - delta
		var hit_radius: float = float(bullet.get("hitRadius", 22.0)) * bullet_hit_rate
		var bullet_pos: Vector2 = Vector2(bullet["pos"])
		if bullet_pos.distance_squared_to(player_pos) < hit_radius * hit_radius:
			bullet["life"] = -1.0
			damage_events.append({"source": String(bullet.get("source", "enemy bullet")), "damage": int(bullet.get("damage", DamageSystem.ENEMY_BULLET_DAMAGE)), "enemyId": String(bullet.get("sourceKind", "")), "runtimeVariant": String(bullet.get("runtimeVariant", "")), "attackType": String(bullet.get("attackType", "projectile"))})
	var bullet_keep_area: Rect2 = arena.grow(80.0)
	var kept_bullets: Array = []
	for bullet_item in bullets:
		var bullet: Dictionary = bullet_item
		if float(bullet["life"]) > 0.0 and bullet_keep_area.has_point(Vector2(bullet["pos"])):
			kept_bullets.append(bullet)
	result["bullets"] = kept_bullets
	return result
