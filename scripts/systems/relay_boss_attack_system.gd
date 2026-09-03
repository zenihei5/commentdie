class_name RelayBossAttackSystem
extends RefCounted

const EnemySystemScript := preload("res://scripts/systems/enemy_system.gd")
const HardModeSystemScript := preload("res://scripts/systems/hard_mode_system.gd")

const STATE_IDLE := "idle"
const STATE_TELEGRAPH := "telegraph"
const STATE_ACTIVE := "active"
const STATE_RECOVERY := "recovery"

const ATTACK_IDS: Array[String] = [
	"comment_shotgun", "offline_laser", "noise_summon",
	"kuso_maro_drop", "long_comment_line",
	"race_lane_charge", "game_over_barrage", "fake_gift_trap",
	"howling_ring", "pitch_wave", "rhythm_explosion",
	"dirty_paint", "eraser_sweep", "paint_warning",
	"division_noise", "collab_break", "all_genre_rush"
]

const LARGE_ATTACK_IDS := [
	"offline_laser", "game_over_barrage", "rhythm_explosion",
	"eraser_sweep", "paint_warning", "collab_break", "all_genre_rush"
]

const OFFLINE_LASER_LENGTH := 900.0
const OFFLINE_LASER_HIT_WIDTH := 26.0
const FAKE_GIFT_TRAP_SOURCE := "relay_boss_fake_gift_trap"
const FAKE_GIFT_TRAP_TRIGGER_RADIUS := 40.0
const FAKE_GIFT_TRAP_DEFAULT_LIFETIME := 10.0
const FAKE_GIFT_TRAP_DEFAULT_WARNING := 0.45
const FAKE_GIFT_TRAP_PLAYER_CLEARANCE := 115.0
const FAKE_GIFT_TRAP_PLACEMENT_MARGIN := 45.0
const FAKE_GIFT_TRAP_VISUAL_RADIUS := 34.0
const FAKE_GIFT_TRAP_SPACING := 84.0
const FAKE_GIFT_TRAP_DETONATION_DURATION := 0.20
const FAKE_GIFT_TRAP_MATERIALIZE_DURATION := 0.18
const HOWLING_RING_DEFAULT_COUNT := 3
const HOWLING_RING_DEFAULT_INTERVAL := 0.75
const HOWLING_RING_DEFAULT_DAMAGE := 11
const HOWLING_RING_DEFAULT_ACTIVE_DURATION := 2.25
const HOWLING_RING_BAND_HALF_WIDTH := 18.0
const PITCH_WAVE_DEFAULT_COUNT := 2
const PITCH_WAVE_DEFAULT_DAMAGE := 11
const PITCH_WAVE_RADIUS := 42.0
const PITCH_WAVE_SPEED := 300.0
const PITCH_WAVE_VISUAL_FX_DURATION := 0.18
const PITCH_WAVE_HIT_FX_DURATION := 0.20
const RHYTHM_EXPLOSION_DEFAULT_COUNT := 6
const RHYTHM_EXPLOSION_DEFAULT_FIRST_EXPLOSION := 1.40
const RHYTHM_EXPLOSION_DEFAULT_INTERVAL := 0.25
const RHYTHM_EXPLOSION_DEFAULT_DAMAGE := 16
const RHYTHM_EXPLOSION_PLACEMENT_DISTANCE := 190.0
const RHYTHM_EXPLOSION_PLACEMENT_MARGIN := 50.0
const RHYTHM_EXPLOSION_RADIUS := 58.0
const RHYTHM_EXPLOSION_ACTIVATION_FX_DURATION := 0.20
const RHYTHM_EXPLOSION_HIT_FX_DURATION := 0.20
const DIRTY_PAINT_RADIUS := 145.0
const DIRTY_PAINT_WARNING_DURATION := 0.90
const DIRTY_PAINT_SPAWN_FX_DURATION := 0.18
const DIRTY_PAINT_CONTACT_ENTER_FX_DURATION := 0.16
const DIRTY_PAINT_CONTACT_EXIT_FX_DURATION := 0.14
const DIRTY_PAINT_EXPIRY_FX_DURATION := 0.18
const ERASER_SWEEP_WIDTH := 128.0
const ERASER_SAFE_MARGIN_Y := 128.0
const ERASER_SWEEP_START_OFFSET_X := -80.0
const ERASER_SWEEP_TRAVEL_TIME := 1.0
const ERASER_SWEEP_ENTRY_FX_DURATION := 0.18
const ERASER_SWEEP_WAKE_FX_DURATION := 0.16
const ERASER_SWEEP_HIT_FX_DURATION := 0.20
const PAINT_WARNING_RADIUS_RATE := 0.24
const PAINT_WARNING_DEFAULT_COUNT := 1
const PAINT_WARNING_DEFAULT_WARNING_DURATION := 1.40
const PAINT_WARNING_ACTIVATION_FX_DURATION := 0.20
const PAINT_WARNING_CADENCE_FX_DURATION := 0.12
const PAINT_WARNING_HIT_FX_DURATION := 0.20
const DIVISION_NOISE_ANCHOR_RADIUS := 46.0
const DIVISION_NOISE_WARNING_LOCK_REMAINING := 0.45
const DIVISION_NOISE_CHILD_GRACE_DURATION := 0.45
const DIVISION_NOISE_CHILD_LIFETIME := 8.0
const DIVISION_NOISE_ANCHOR_FX_DURATION := 0.18
const DIVISION_NOISE_CHILD_SPAWN_FX_DURATION := 0.20
const DIVISION_NOISE_CHILD_CONTACT_FX_DURATION := 0.16
const DIVISION_NOISE_CHILD_DEFEAT_FX_DURATION := 0.18
const COLLAB_BREAK_CORE_HP_RATE := 0.03
const COLLAB_BREAK_CORE_RADIUS := 27.0
const COLLAB_BREAK_CORE_LIFETIME := 10.0
const COLLAB_BREAK_CORE_SPAWN_FX_DURATION := 0.20
const COLLAB_BREAK_CORE_HIT_FX_DURATION := 0.18
const COLLAB_BREAK_CORE_FINISH_FX_DURATION := 0.20
const ALL_GENRE_RUSH_OWNER_ID := "all_genre_rush"
const ALL_GENRE_RUSH_STEP_IDS := ["kuso_maro_drop", "long_comment_line", "howling_ring", "dirty_paint"]
const ALL_GENRE_RUSH_STEP_OFFSETS := [0.0, 0.6, 1.2, 1.8]
const ALL_GENRE_RUSH_STEP_COUNT := 4
const TRAVEL_COMMENT_SALVO_SOURCE := "relay_boss_travel_comment"
const TRAVEL_COMMENT_SALVO_KIND := "travel_comment_salvo"
const TRAVEL_COMMENT_SALVO_COUNT := 3
const TRAVEL_COMMENT_SALVO_SPEED := 230.0
const TRAVEL_COMMENT_SALVO_LIFE := 3.5
const TRAVEL_COMMENT_SALVO_DAMAGE := 5
const TRAVEL_COMMENT_SALVO_HIT_RADIUS := 22.0
const TRAVEL_COMMENT_SALVO_LAUNCH_FX_DURATION := 0.16
const TRAVEL_COMMENT_SALVO_FOREGROUND_DURATION := 0.40
const TRAVEL_NOISE_SHOT_SOURCE := "relay_boss_travel_noise"
const TRAVEL_NOISE_SHOT_KIND := "travel_noise_shot"
const TRAVEL_NOISE_SHOT_COUNT := 2
const TRAVEL_NOISE_SHOT_SPEED := 265.0
const TRAVEL_NOISE_SHOT_LIFE := 3.0
const TRAVEL_NOISE_SHOT_DAMAGE := 4
const TRAVEL_NOISE_SHOT_HIT_RADIUS := 22.0
const TRAVEL_NOISE_SHOT_LAUNCH_FX_DURATION := 0.16
const TRAVEL_NOISE_SHOT_FOREGROUND_DURATION := 1.60
const TRAVEL_NOISE_SUMMON_SOURCE := "travel_support"
const TRAVEL_NOISE_SUMMON_KIND := "travel_noise_summon"
const TRAVEL_NOISE_SUMMON_WARNING_SECONDS := 0.60
const TRAVEL_NOISE_SUMMON_CUE_DURATION := 0.18
const TRAVEL_NOISE_SUMMON_SPAWN_FX_DURATION := 0.22
const TRAVEL_NOISE_SUMMON_SPAWN_FX_STRENGTH := 0.94

static func empty_runtime() -> Dictionary:
	return {
		"active_attack": _empty_attack(),
		"hazards": [],
		"reuse_cooldowns": {},
		"last_attack_id": "",
		"last_attack_was_large": false,
		"pending_comment": false,
		"pending_phase": -1,
		"gameplay_variant": "",
		"arena_warning_timer": 0.0,
		"collab_break_uid": -1,
		"serial": 0,
		"debug_overlay": false,
		"debug_forced_attack": ""
		,"pending_attack": {},
		"allGenreRushCastSerial": 0,
		"allGenreRushStepIndex": -1,
		"allGenreRushCompletedMask": 0,
		"allGenreRushElapsed": 0.0,
		"noise_summon_cooldown": 0.0,
		"noise_summon_after_wave_lock": 0.0,
		"noise_summon_after_protected_attack_lock": 0.0,
		"noise_summon_wave_serial": 0,
		"travelCommentSalvoSerial": 0,
		"travelNoiseShotSerial": 0,
		"travelNoiseSummonSerial": 0,
		"noise_summon_pending_wave": {},
	"noise_summon_visual_effects": [],
	"travelNoiseSummonLastResolution": "",
	"travelNoiseSummonLastResolutionReason": "",
	"kuso_maro_drop_visual_effects": [],
	"long_comment_line_visual_effects": [],
	"race_lane_charge_visual_effects": [],
	"howling_ring_visual_effects": [],
	"pitch_wave_visual_effects": [],
	"rhythm_explosion_visual_effects": [],
	"dirty_paint_visual_effects": [],
	"eraser_sweep_visual_effects": [],
	"paint_warning_visual_effects": [],
	"division_noise_visual_effects": [],
	"collab_break_visual_effects": [],
	"dirty_paint_contact_state": {"inside": false, "stayTimer": 0.0, "center": Vector2.ZERO, "radius": DIRTY_PAINT_RADIUS, "visualSeed": 0.0},
	"kuso_maro_drop_visual_batch_serial": 0,
	"fake_gift_traps": [],
	"fake_gift_trap_visual_effects": [],
	"fake_gift_trap_uid_counter": 0,
		"sync_star_drop_cooldown": 0.0,
		"sync_star_carrier_uid": -1
	}

static func reset_for_target(target: Node) -> void:
	target.set("relay_boss_runtime", empty_runtime())
	target.set("relay_boss_active_attack", {})

static func ensure_for_target(target: Node) -> Dictionary:
	var value: Variant = target.get("relay_boss_runtime")
	if value is Dictionary and not (value as Dictionary).is_empty():
		return value as Dictionary
	var runtime := empty_runtime()
	target.set("relay_boss_runtime", runtime)
	return runtime

static func active_attack_for_target(target: Node) -> Dictionary:
	return ensure_for_target(target).get("active_attack", {}) as Dictionary

static func is_busy_for_target(target: Node) -> bool:
	var state := String(active_attack_for_target(target).get("state", STATE_IDLE))
	return state == STATE_TELEGRAPH or state == STATE_ACTIVE

static func is_attack_in_progress_for_target(target: Node) -> bool:
	return String(active_attack_for_target(target).get("state", STATE_IDLE)) != STATE_IDLE

static func can_open_instruction_for_target(target: Node) -> bool:
	var state := String(active_attack_for_target(target).get("state", STATE_IDLE))
	return state == STATE_IDLE or state == STATE_RECOVERY

static func update_for_target(target: Node, delta: float, arena: Rect2, rng: RandomNumberGenerator, freeze_gameplay: bool = false) -> Dictionary:
	var runtime := ensure_for_target(target)
	var feedback := {"damageEvents": [], "chats": [], "toasts": []}
	if not bool(target.get("relay_boss_active")):
		return feedback
	if freeze_gameplay:
		_sync_legacy_attack_field(target, runtime)
		return feedback
	_decay_reuse_cooldowns(runtime, delta)
	_decay_noise_runtime(target, runtime, delta)
	_decay_kuso_maro_drop_visual_effects(runtime, delta)
	_decay_long_comment_line_visual_effects(runtime, delta)
	_decay_race_lane_charge_visual_effects(runtime, delta)
	_decay_howling_ring_visual_effects(runtime, delta)
	_decay_pitch_wave_visual_effects(runtime, delta)
	_decay_rhythm_explosion_visual_effects(runtime, delta)
	_decay_fake_gift_trap_visual_effects(runtime, delta)
	_decay_dirty_paint_visual_effects(runtime, delta)
	_decay_eraser_sweep_visual_effects(runtime, delta)
	_decay_paint_warning_visual_effects(runtime, delta)
	_decay_division_noise_visual_effects(runtime, delta)
	_decay_collab_break_visual_effects(runtime, delta)
	_update_fake_gift_traps(target, runtime, delta, arena, feedback)
	_sync_noise_carrier_uid(target, runtime)
	_cancel_travel_noise_summon_if_travel_ended(target, runtime, arena)
	_update_pending_noise_wave(target, runtime, delta, arena, rng)
	var active := runtime.get("active_attack", {}) as Dictionary
	var state := String(active.get("state", STATE_IDLE))
	var movement_state := RelayBossMovementSystem.state_for_target(target)
	if state == STATE_IDLE and movement_state != RelayBossMovementSystem.STATE_HOVER and movement_state != RelayBossMovementSystem.STATE_CRUISING:
		_sync_legacy_attack_field(target, runtime)
		return feedback
	if state == STATE_IDLE and float((RelayBossMovementSystem.ensure_for_target(target)).get("resume_timer", 0.0)) > 0.0:
		_sync_legacy_attack_field(target, runtime)
		return feedback
	match state:
		STATE_TELEGRAPH:
			_update_telegraph(target, runtime, active, delta, arena, rng)
		STATE_ACTIVE:
			_update_active(target, runtime, active, delta, arena, rng, feedback)
		STATE_RECOVERY:
			_update_recovery(target, runtime, active, delta)
		_:
			var pending: Dictionary = runtime.get("pending_attack", {}) as Dictionary
			if not pending.is_empty():
				_start_or_queue_attack(target, runtime, String(pending.get("id", "")), arena, rng, bool(pending.get("forced", false)))
				var pending_active: Dictionary = runtime.get("active_attack", {}) as Dictionary
				if String(pending_active.get("state", STATE_IDLE)) != STATE_IDLE:
					runtime["pending_attack"] = {}
			else:
				_pick_and_begin(target, runtime, arena, rng)
	_update_dirty_paint_contact_visual_state(target, runtime, delta)
	_sync_legacy_attack_field(target, runtime)
	return feedback

static func force_attack_for_target(target: Node, attack_id: String) -> bool:
	if not ATTACK_IDS.has(attack_id):
		return false
	var runtime := ensure_for_target(target)
	clear_runtime_objects_for_target(target, false)
	var arena: Rect2 = target.call("_current_arena")
	var rng: RandomNumberGenerator = target.get("rng")
	_start_or_queue_attack(target, runtime, attack_id, arena, rng, true)
	runtime["debug_forced_attack"] = attack_id
	_sync_legacy_attack_field(target, runtime)
	return true

static func resume_after_phase_transition_for_target(target: Node, arena: Rect2, rng: RandomNumberGenerator) -> bool:
	if not bool(target.get("relay_boss_active")):
		return false
	var runtime := ensure_for_target(target)
	var active: Dictionary = runtime.get("active_attack", {}) as Dictionary
	var state := String(active.get("state", STATE_IDLE))
	if state != STATE_IDLE and state != STATE_RECOVERY:
		return false
	if RelayBossMovementSystem.state_for_target(target) != RelayBossMovementSystem.STATE_HOVER:
		return false
	var movement := RelayBossMovementSystem.ensure_for_target(target)
	if float(movement.get("resume_timer", 0.0)) > 0.0:
		return false
	runtime["active_attack"] = _empty_attack()
	runtime["pending_attack"] = {}
	runtime["last_attack_was_large"] = false
	_pick_and_begin(target, runtime, arena, rng)
	var started: Dictionary = runtime.get("active_attack", {}) as Dictionary
	if String(started.get("state", STATE_IDLE)) == STATE_IDLE:
		# This is only reached when every weighted candidate is filtered out.
		# Keep the boss active rather than leaving an invisible, invulnerable
		# looking idle state after a phase transition.
		_start_or_queue_attack(target, runtime, "comment_shotgun", arena, rng, true)
	_sync_legacy_attack_field(target, runtime)
	return String((runtime.get("active_attack", {}) as Dictionary).get("state", STATE_IDLE)) != STATE_IDLE

static func clear_all_genre_rush_for_target(target: Node, _reason: String = "forced_cleanup") -> void:
	var runtime := ensure_for_target(target)
	var active: Dictionary = runtime.get("active_attack", {}) as Dictionary
	var pending: Dictionary = runtime.get("pending_attack", {}) as Dictionary
	var active_is_all_genre := String(active.get("id", "")) == ALL_GENRE_RUSH_OWNER_ID
	var pending_is_all_genre := String(pending.get("id", "")) == ALL_GENRE_RUSH_OWNER_ID
	var variant_is_all_genre := String(runtime.get("gameplay_variant", "")) == ALL_GENRE_RUSH_OWNER_ID
	if not active_is_all_genre and not pending_is_all_genre and not variant_is_all_genre and int(runtime.get("allGenreRushCastSerial", 0)) <= 0:
		return
	var cast_serial := int(active.get("allGenreRushCastSerial", runtime.get("allGenreRushCastSerial", -1))) if active_is_all_genre else int(runtime.get("allGenreRushCastSerial", -1))
	_clear_all_genre_rush_owned_runtime(target, runtime, cast_serial, true)
	if active_is_all_genre:
		runtime["active_attack"] = _empty_attack()
	if pending_is_all_genre:
		runtime["pending_attack"] = {}
	if active_is_all_genre or pending_is_all_genre or variant_is_all_genre:
		runtime["gameplay_variant"] = ""
	if String(runtime.get("last_attack_id", "")) == ALL_GENRE_RUSH_OWNER_ID:
		runtime["last_attack_id"] = ""
		runtime["last_attack_was_large"] = false
	if String(runtime.get("debug_forced_attack", "")) == ALL_GENRE_RUSH_OWNER_ID:
		runtime["debug_forced_attack"] = ""
	runtime["allGenreRushCastSerial"] = 0
	runtime["allGenreRushStepIndex"] = -1
	runtime["allGenreRushCompletedMask"] = 0
	runtime["allGenreRushElapsed"] = 0.0
	_sync_legacy_attack_field(target, runtime)
	target.set("relay_boss_runtime", runtime)

static func interrupt_for_target(target: Node, reason: String = "") -> void:
	var runtime := ensure_for_target(target)
	var active := runtime.get("active_attack", {}) as Dictionary
	var active_is_all_genre := String(active.get("id", "")) == ALL_GENRE_RUSH_OWNER_ID
	var pending_is_all_genre := String((runtime.get("pending_attack", {}) as Dictionary).get("id", "")) == ALL_GENRE_RUSH_OWNER_ID
	if active_is_all_genre or pending_is_all_genre or String(runtime.get("gameplay_variant", "")) == ALL_GENRE_RUSH_OWNER_ID:
		clear_all_genre_rush_for_target(target, reason)
		runtime = ensure_for_target(target)
		if active_is_all_genre:
			if reason == "combo" or reason == "combo_ready":
				RelayBossMovementSystem.interrupt_for_target(target, RelayBossMovementSystem.STATE_STUNNED)
			else:
				RelayBossMovementSystem.on_attack_finished(target)
			_sync_legacy_attack_field(target, runtime)
			return
		# A queued all-genre request can coexist with another attack while the
		# required center anchor is unavailable. Removing that pending request
		# must not interrupt or rewrite the unrelated active attack.
		_sync_legacy_attack_field(target, runtime)
		return
	var was_collab_break := String(active.get("id", "")) == "collab_break"
	if was_collab_break:
		_finish_collab_break_for_target(target, "forced_cleanup")
		runtime = ensure_for_target(target)
		active = runtime.get("active_attack", {}) as Dictionary
	active["state"] = STATE_RECOVERY
	active["timer"] = 0.0
	active["elapsed"] = 0.0
	runtime["active_attack"] = active
	# A collab_break interrupt releases only its own ownership.  Its targeted
	# finish path above already removed its core/sidecar hazards, so do not send
	# the interrupt through the generic all-hazard clear.  Other attacks retain
	# the pre-existing broad interrupt cleanup semantics.
	if not was_collab_break:
		clear_runtime_objects_for_target(target, false, true)
	if not was_collab_break and target.has_method("_clear_all_collab_partner_mute_sources"):
		target.call("_clear_all_collab_partner_mute_sources")
	elif not was_collab_break:
		target.set("collab_boss_partner_muted", false)
	if reason == "combo" or reason == "combo_ready":
		RelayBossMovementSystem.interrupt_for_target(target, RelayBossMovementSystem.STATE_STUNNED)
	else:
		RelayBossMovementSystem.on_attack_finished(target)
	_sync_legacy_attack_field(target, runtime)

static func clear_runtime_objects_for_target(target: Node, clear_attack: bool = true, clear_partner_sources: bool = true) -> void:
	var runtime := ensure_for_target(target)
	runtime["hazards"] = []
	runtime["noise_summon_pending_wave"] = {}
	runtime["noise_summon_visual_effects"] = []
	runtime["kuso_maro_drop_visual_effects"] = []
	runtime["long_comment_line_visual_effects"] = []
	runtime["race_lane_charge_visual_effects"] = []
	runtime["howling_ring_visual_effects"] = []
	runtime["pitch_wave_visual_effects"] = []
	runtime["rhythm_explosion_visual_effects"] = []
	runtime["dirty_paint_visual_effects"] = []
	runtime["eraser_sweep_visual_effects"] = []
	runtime["paint_warning_visual_effects"] = []
	runtime["division_noise_visual_effects"] = []
	runtime["collab_break_visual_effects"] = []
	runtime["dirty_paint_contact_state"] = {"inside": false, "stayTimer": 0.0, "center": Vector2.ZERO, "radius": DIRTY_PAINT_RADIUS, "visualSeed": 0.0}
	if clear_attack:
		runtime["fake_gift_traps"] = []
		runtime["fake_gift_trap_visual_effects"] = []
	runtime["collab_break_uid"] = -1
	if clear_attack:
		runtime["active_attack"] = _empty_attack()
		runtime["pending_attack"] = {}
	var bullets: Array = target.get("enemy_bullets")
	var kept: Array = []
	for item in bullets:
		var bullet: Dictionary = item as Dictionary
		if not bool(bullet.get("relayBossProjectile", false)):
			kept.append(bullet)
	target.set("enemy_bullets", kept)
	if clear_partner_sources and target.has_method("_clear_all_collab_partner_mute_sources"):
		target.call("_clear_all_collab_partner_mute_sources")
	elif clear_partner_sources:
		target.set("collab_boss_partner_muted", false)
	_sync_legacy_attack_field(target, runtime)

static func _collab_break_visual_seed(serial: int, pos: Vector2, salt: float = 0.0) -> float:
	var raw := sin(float(serial) * 17.173 + pos.x * 0.0137 + pos.y * 0.0193 + salt * 41.719) * 43758.5453
	return fposmod(raw, 1.0)

static func _append_collab_break_visual_effect(runtime: Dictionary, effect: Dictionary) -> void:
	var effects: Array = runtime.get("collab_break_visual_effects", []) as Array
	effects.append(effect)
	runtime["collab_break_visual_effects"] = effects

static func _enemy_by_uid(target: Node, uid: int) -> Dictionary:
	if uid < 0:
		return {}
	for item in target.get("enemies") as Array:
		var enemy: Dictionary = item as Dictionary
		if int(enemy.get("uid", -1)) == uid:
			return enemy
	return {}

static func _is_collab_break_core(enemy: Dictionary) -> bool:
	return bool(enemy.get("collabBreakCore", false)) \
		and String(enemy.get("attackId", enemy.get("bossAttackId", ""))) == "collab_break" \
		and String(enemy.get("source", "")) == "relay_collab_break_core"

static func _is_collab_break_sidecar(enemy: Dictionary) -> bool:
	return String(enemy.get("kind", "")) == "noise_ghost_comment" \
		and bool(enemy.get("relayBossNoiseSummon", false)) \
		and bool(enemy.get("collabBreakSidecar", false)) \
		and String(enemy.get("relayNoiseOwnerAttackId", enemy.get("ownerAttackId", ""))) == "collab_break"

static func _is_collab_break_visual_effect(effect: Dictionary) -> bool:
	var kind := String(effect.get("kind", ""))
	return kind.begins_with("collab_break_") \
		or String(effect.get("bossAttackId", effect.get("attackId", ""))) == "collab_break" \
		or String(effect.get("ownerAttackId", "")) == "collab_break"

static func _collab_break_cast_matches(value: Variant, cast_serial: int) -> bool:
	return cast_serial < 0 or int(value) == cast_serial

static func _remove_collab_break_owned_runtime(target: Node, runtime: Dictionary, cast_serial: int, core_uid: int, remove_spawned_children: bool = true) -> Vector2:
	var release_pos := Vector2(target.get("collab_partner_pos"))
	var tracked_core := _enemy_by_uid(target, core_uid)
	if not tracked_core.is_empty():
		release_pos = Vector2(tracked_core.get("pos", release_pos))
	var pending: Dictionary = runtime.get("noise_summon_pending_wave", {}) as Dictionary
	if not pending.is_empty() and String(pending.get("source", "")) == "collab_break_sidecar" and _collab_break_cast_matches(pending.get("ownerCastSerial", -1), cast_serial):
		runtime["noise_summon_pending_wave"] = {}
	var kept_hazards: Array = []
	for item in runtime.get("hazards", []) as Array:
		var hazard: Dictionary = item as Dictionary
		var hazard_id := String(hazard.get("attackId", hazard.get("bossAttackId", "")))
		if hazard_id == "collab_break" or String(hazard.get("source", "")) == "relay_boss_collab_break":
			continue
		kept_hazards.append(hazard)
	runtime["hazards"] = kept_hazards
	var kept_enemies: Array = []
	for item in target.get("enemies") as Array:
		var enemy: Dictionary = item as Dictionary
		var remove_core := core_uid >= 0 and int(enemy.get("uid", -1)) == core_uid
		var remove_sidecar := remove_spawned_children and _is_collab_break_sidecar(enemy) and _collab_break_cast_matches(enemy.get("relayNoiseOwnerCastSerial", enemy.get("collabBreakCastSerial", -1)), cast_serial)
		if remove_core or remove_sidecar:
			continue
		kept_enemies.append(enemy)
	target.set("enemies", kept_enemies)
	runtime["collab_break_uid"] = -1
	runtime["collab_break_visual_effects"] = []
	var noise_visual_value: Variant = runtime.get("noise_summon_visual_effects")
	if noise_visual_value is Array:
		var kept_noise_visuals: Array = []
		for item in noise_visual_value as Array:
			var noise_effect: Dictionary = item as Dictionary
			if String(noise_effect.get("spawnSource", noise_effect.get("source", ""))) == "collab_break_sidecar":
				continue
			kept_noise_visuals.append(noise_effect)
		runtime["noise_summon_visual_effects"] = kept_noise_visuals
	var collab_effects_value: Variant = target.get("collab_effects")
	if collab_effects_value is Array:
		var kept_effects: Array = []
		for item in collab_effects_value as Array:
			var effect: Dictionary = item as Dictionary
			if _is_collab_break_visual_effect(effect):
				continue
			kept_effects.append(effect)
		target.set("collab_effects", kept_effects)
	var hit_fx_value: Variant = target.get("hit_fx")
	if hit_fx_value is Array:
		var kept_hit_fx: Array = []
		for item in hit_fx_value as Array:
			var hit: Dictionary = item as Dictionary
			if _is_collab_break_visual_effect(hit):
				continue
			kept_hit_fx.append(hit)
		target.set("hit_fx", kept_hit_fx)
	return release_pos

static func _finish_collab_break_for_target(target: Node, reason: String = "timeout") -> void:
	var runtime := ensure_for_target(target)
	var active: Dictionary = runtime.get("active_attack", {}) as Dictionary
	if String(active.get("id", "")) != "collab_break":
		return
	var cast_serial := int(active.get("collabBreakCoreCastSerial", active.get("serial", -1)))
	var core_uid := int(active.get("collabBreakCoreUid", runtime.get("collab_break_uid", -1)))
	var release_pos := _remove_collab_break_owned_runtime(target, runtime, cast_serial, core_uid)
	if target.has_method("_clear_collab_partner_mute_source"):
		target.call("_clear_collab_partner_mute_source", "collab_break")
	if target.has_method("_clear_collab_pass_source"):
		target.call("_clear_collab_pass_source", "collab_break")
	elif target.has_method("_clear_collab_pass") and String(reason) == "forced_cleanup":
		# Legacy PASS has no source registry; only the existing explicit break
		# cleanup may clear its current target.
		target.call("_clear_collab_pass", false)
	var emit_fx := reason == "destroy" or reason == "timeout"
	if emit_fx:
		var fx_kind := "collab_break_destroy_fx" if reason == "destroy" else "collab_break_timeout_fx"
		_append_collab_break_visual_effect(runtime, {
			"kind": fx_kind,
			"bossAttackId": "collab_break",
			"castSerial": cast_serial,
			"pos": release_pos,
			"visualSeed": _collab_break_visual_seed(cast_serial, release_pos, 4.0),
			"life": COLLAB_BREAK_CORE_FINISH_FX_DURATION,
			"maxLife": COLLAB_BREAK_CORE_FINISH_FX_DURATION
		})
		_append_collab_break_visual_effect(runtime, {
			"kind": "collab_break_restore_fx",
			"bossAttackId": "collab_break",
			"castSerial": cast_serial,
			"pos": Vector2(target.get("collab_partner_pos")),
			"visualSeed": _collab_break_visual_seed(cast_serial, Vector2(target.get("collab_partner_pos")), 5.0),
			"life": COLLAB_BREAK_CORE_FINISH_FX_DURATION,
			"maxLife": COLLAB_BREAK_CORE_FINISH_FX_DURATION
		})
	active["collabBreakCoreUid"] = -1
	active["collabBreakCoreSnapshotValid"] = false
	active["state"] = STATE_RECOVERY
	active["timer"] = float((active.get("payload", {}) as Dictionary).get("recovery", 1.0))
	active["elapsed"] = 0.0
	runtime["active_attack"] = active
	_sync_legacy_attack_field(target, runtime)
	target.set("relay_boss_runtime", runtime)

static func finish_collab_break_for_target(target: Node, reason: String = "timeout") -> void:
	_finish_collab_break_for_target(target, reason)

static func clear_collab_break_visuals_for_target(target: Node, remove_spawned_children: bool = true, reason: String = "forced_cleanup") -> void:
	var runtime := ensure_for_target(target)
	var active: Dictionary = runtime.get("active_attack", {}) as Dictionary
	var cast_serial := int(active.get("collabBreakCoreCastSerial", active.get("serial", -1))) if String(active.get("id", "")) == "collab_break" else -1
	var core_uid := int(active.get("collabBreakCoreUid", runtime.get("collab_break_uid", -1)))
	if remove_spawned_children or core_uid >= 0:
		_remove_collab_break_owned_runtime(target, runtime, cast_serial, core_uid, remove_spawned_children)
	else:
		runtime["collab_break_visual_effects"] = []
	if String(active.get("id", "")) == "collab_break":
		runtime["active_attack"] = _empty_attack()
	var pending_attack: Dictionary = runtime.get("pending_attack", {}) as Dictionary
	if String(pending_attack.get("id", "")) == "collab_break":
		runtime["pending_attack"] = {}
	if target.has_method("_clear_collab_partner_mute_source"):
		target.call("_clear_collab_partner_mute_source", "collab_break")
	if target.has_method("_clear_collab_pass_source"):
		target.call("_clear_collab_pass_source", "collab_break")
	var effects_value: Variant = target.get("collab_effects")
	if effects_value is Array:
		var kept_effects: Array = []
		for item in effects_value as Array:
			var effect: Dictionary = item as Dictionary
			if _is_collab_break_visual_effect(effect):
				continue
			kept_effects.append(effect)
		target.set("collab_effects", kept_effects)
	var hit_fx_value: Variant = target.get("hit_fx")
	if hit_fx_value is Array:
		var kept_hit_fx: Array = []
		for item in hit_fx_value as Array:
			var hit: Dictionary = item as Dictionary
			if _is_collab_break_visual_effect(hit):
				continue
			kept_hit_fx.append(hit)
		target.set("hit_fx", kept_hit_fx)
	_sync_legacy_attack_field(target, runtime)
	target.set("relay_boss_runtime", runtime)

static func clear_fake_gift_traps_for_target(target: Node, _reason: String = "forced_cleanup") -> void:
	# Fake gifts are intentionally not part of the generic boss hazard array.
	# Keep this filter explicit so normal care packages, horror mimics, and
	# every other relay attack survive targeted lifecycle cleanup.
	var runtime := ensure_for_target(target)
	runtime["fake_gift_traps"] = []
	runtime["fake_gift_trap_visual_effects"] = []
	var active: Dictionary = runtime.get("active_attack", {}) as Dictionary
	if String(active.get("id", "")) == "fake_gift_trap":
		runtime["active_attack"] = _empty_attack()
	var pending: Dictionary = runtime.get("pending_attack", {}) as Dictionary
	if String(pending.get("id", "")) == "fake_gift_trap":
		runtime["pending_attack"] = {}
	var collab_effects_value: Variant = target.get("collab_effects")
	if collab_effects_value is Array:
		var kept_effects: Array = []
		for item in collab_effects_value as Array:
			var effect: Dictionary = item as Dictionary
			var effect_kind := String(effect.get("kind", ""))
			var effect_attack_id := String(effect.get("bossAttackId", effect.get("attackId", "")))
			if effect_kind.begins_with("fake_gift_trap_") or effect_attack_id == "fake_gift_trap":
				continue
			kept_effects.append(effect)
		target.set("collab_effects", kept_effects)
	var hit_fx_value: Variant = target.get("hit_fx")
	if hit_fx_value is Array:
		var kept_hit_fx: Array = []
		for item in hit_fx_value as Array:
			var fx: Dictionary = item as Dictionary
			var fx_kind := String(fx.get("kind", ""))
			var fx_attack_id := String(fx.get("bossAttackId", fx.get("attackId", "")))
			if fx_kind.begins_with("fake_gift_trap_") or fx_attack_id == "fake_gift_trap":
				continue
			kept_hit_fx.append(fx)
		target.set("hit_fx", kept_hit_fx)
	_sync_legacy_attack_field(target, runtime)
	target.set("relay_boss_runtime", runtime)

static func clear_howling_ring_visuals_for_target(target: Node, _reason: String = "forced_cleanup") -> void:
	# Howling rings share the relay hazard array with composite attacks.  Keep
	# this filter provenance-based so game-over/title cleanup never removes a
	# different relay hazard or the all_genre_rush state that owns it.
	var runtime := ensure_for_target(target)
	var kept_hazards: Array = []
	for item in runtime.get("hazards", []) as Array:
		var hazard: Dictionary = item as Dictionary
		if _is_howling_ring_hazard(hazard):
			continue
		kept_hazards.append(hazard)
	runtime["hazards"] = kept_hazards
	runtime["howling_ring_visual_effects"] = []

	var active: Dictionary = runtime.get("active_attack", {}) as Dictionary
	if String(active.get("id", "")) == "howling_ring":
		runtime["active_attack"] = _empty_attack()
	var pending: Dictionary = runtime.get("pending_attack", {}) as Dictionary
	if String(pending.get("id", "")) == "howling_ring":
		runtime["pending_attack"] = {}

	var effects_value: Variant = target.get("collab_effects")
	if effects_value is Array:
		var kept_effects: Array = []
		for item in effects_value as Array:
			var effect: Dictionary = item as Dictionary
			if _is_howling_ring_visual_effect(effect):
				continue
			kept_effects.append(effect)
		target.set("collab_effects", kept_effects)
	var hit_fx_value: Variant = target.get("hit_fx")
	if hit_fx_value is Array:
		var kept_hit_fx: Array = []
		for item in hit_fx_value as Array:
			var hit: Dictionary = item as Dictionary
			if _is_howling_ring_visual_effect(hit):
				continue
			kept_hit_fx.append(hit)
		target.set("hit_fx", kept_hit_fx)
	_sync_legacy_attack_field(target, runtime)
	target.set("relay_boss_runtime", runtime)

static func _is_howling_ring_hazard(hazard: Dictionary) -> bool:
	return bool(hazard.get("howlingRingVisual", false)) \
		or String(hazard.get("kind", "")) == "howling_ring" \
		or String(hazard.get("source", "")) == "relay_boss_howling_ring" \
		or String(hazard.get("attackId", hazard.get("bossAttackId", ""))) == "howling_ring"

static func _is_howling_ring_visual_effect(effect: Dictionary) -> bool:
	var kind := String(effect.get("kind", ""))
	return kind.begins_with("howling_ring_") \
		or String(effect.get("bossAttackId", effect.get("attackId", ""))) == "howling_ring"

static func _clear_howling_ring_runtime_objects(runtime: Dictionary) -> void:
	var kept_hazards: Array = []
	for item in runtime.get("hazards", []) as Array:
		var hazard: Dictionary = item as Dictionary
		if not _is_howling_ring_hazard(hazard):
			kept_hazards.append(hazard)
	runtime["hazards"] = kept_hazards
	runtime["howling_ring_visual_effects"] = []

static func clear_pitch_wave_visuals_for_target(target: Node, _reason: String = "forced_cleanup") -> void:
	# Relay pitch packets share the runtime hazard array with composite attacks.
	# Filter only the explicit pitch provenance so lifecycle cleanup cannot
	# remove howling/rhythm or another relay hazard.
	var runtime := ensure_for_target(target)
	var kept_hazards: Array = []
	for item in runtime.get("hazards", []) as Array:
		var hazard: Dictionary = item as Dictionary
		var is_pitch := bool(hazard.get("pitchWaveVisual", false)) \
			or String(hazard.get("kind", "")) == "pitch_wave" \
			or String(hazard.get("source", "")) == "relay_boss_pitch_wave" \
			or String(hazard.get("attackId", hazard.get("bossAttackId", ""))) == "pitch_wave"
		if not is_pitch:
			kept_hazards.append(hazard)
	runtime["hazards"] = kept_hazards
	runtime["pitch_wave_visual_effects"] = []
	var active: Dictionary = runtime.get("active_attack", {}) as Dictionary
	if String(active.get("id", "")) == "pitch_wave":
		runtime["active_attack"] = _empty_attack()
	var pending: Dictionary = runtime.get("pending_attack", {}) as Dictionary
	if String(pending.get("id", "")) == "pitch_wave":
		runtime["pending_attack"] = {}
	var effects_value: Variant = target.get("collab_effects")
	if effects_value is Array:
		var kept_effects: Array = []
		for item in effects_value as Array:
			var effect: Dictionary = item as Dictionary
			var effect_kind := String(effect.get("kind", ""))
			var effect_attack_id := String(effect.get("bossAttackId", effect.get("attackId", "")))
			if effect_kind.begins_with("relay_pitch_wave_") or effect_attack_id == "pitch_wave":
				continue
			kept_effects.append(effect)
		target.set("collab_effects", kept_effects)
	var hit_fx_value: Variant = target.get("hit_fx")
	if hit_fx_value is Array:
		var kept_hit_fx: Array = []
		for item in hit_fx_value as Array:
			var hit: Dictionary = item as Dictionary
			var hit_kind := String(hit.get("kind", ""))
			var hit_attack_id := String(hit.get("bossAttackId", hit.get("attackId", "")))
			if hit_kind.begins_with("relay_pitch_wave_") or hit_attack_id == "pitch_wave":
				continue
			kept_hit_fx.append(hit)
		target.set("hit_fx", kept_hit_fx)
	_sync_legacy_attack_field(target, runtime)
	target.set("relay_boss_runtime", runtime)

static func clear_rhythm_explosion_visuals_for_target(target: Node, _reason: String = "forced_cleanup") -> void:
	# Rhythm markers share the relay hazard array with composite attacks. Keep
	# this cleanup provenance-based so only rhythm_explosion-owned state is
	# removed during game-over/title/reset transitions.
	var runtime := ensure_for_target(target)
	var kept_hazards: Array = []
	for item in runtime.get("hazards", []) as Array:
		var hazard: Dictionary = item as Dictionary
		if not _is_rhythm_explosion_hazard(hazard):
			kept_hazards.append(hazard)
	runtime["hazards"] = kept_hazards
	runtime["rhythm_explosion_visual_effects"] = []
	var active: Dictionary = runtime.get("active_attack", {}) as Dictionary
	if String(active.get("id", "")) == "rhythm_explosion":
		runtime["active_attack"] = _empty_attack()
	var pending: Dictionary = runtime.get("pending_attack", {}) as Dictionary
	if String(pending.get("id", "")) == "rhythm_explosion":
		runtime["pending_attack"] = {}
	var effects_value: Variant = target.get("collab_effects")
	if effects_value is Array:
		var kept_effects: Array = []
		for item in effects_value as Array:
			var effect: Dictionary = item as Dictionary
			if _is_rhythm_explosion_visual_effect(effect):
				continue
			kept_effects.append(effect)
		target.set("collab_effects", kept_effects)
	var hit_fx_value: Variant = target.get("hit_fx")
	if hit_fx_value is Array:
		var kept_hit_fx: Array = []
		for item in hit_fx_value as Array:
			var hit: Dictionary = item as Dictionary
			if _is_rhythm_explosion_visual_effect(hit):
				continue
			kept_hit_fx.append(hit)
		target.set("hit_fx", kept_hit_fx)
	_sync_legacy_attack_field(target, runtime)
	target.set("relay_boss_runtime", runtime)

static func clear_dirty_paint_visuals_for_target(target: Node, _reason: String = "forced_cleanup") -> void:
	# Dirty paint can be appended by the all_genre_rush composite, so cleanup
	# removes only its explicit provenance and never clears the composite attack.
	var runtime := ensure_for_target(target)
	var kept_hazards: Array = []
	for item in runtime.get("hazards", []) as Array:
		var hazard: Dictionary = item as Dictionary
		if _is_dirty_paint_hazard(hazard):
			continue
		kept_hazards.append(hazard)
	runtime["hazards"] = kept_hazards
	runtime["dirty_paint_visual_effects"] = []
	runtime["dirty_paint_contact_state"] = {"inside": false, "stayTimer": 0.0, "center": Vector2.ZERO, "radius": DIRTY_PAINT_RADIUS, "visualSeed": 0.0}
	var active: Dictionary = runtime.get("active_attack", {}) as Dictionary
	if String(active.get("id", "")) == "dirty_paint":
		runtime["active_attack"] = _empty_attack()
	var pending: Dictionary = runtime.get("pending_attack", {}) as Dictionary
	if String(pending.get("id", "")) == "dirty_paint":
		runtime["pending_attack"] = {}
	var effects_value: Variant = target.get("collab_effects")
	if effects_value is Array:
		var kept_effects: Array = []
		for item in effects_value as Array:
			var effect: Dictionary = item as Dictionary
			if _is_dirty_paint_visual_effect(effect):
				continue
			kept_effects.append(effect)
		target.set("collab_effects", kept_effects)
	var hit_fx_value: Variant = target.get("hit_fx")
	if hit_fx_value is Array:
		var kept_hit_fx: Array = []
		for item in hit_fx_value as Array:
			var hit: Dictionary = item as Dictionary
			if _is_dirty_paint_visual_effect(hit):
				continue
			kept_hit_fx.append(hit)
		target.set("hit_fx", kept_hit_fx)
	_sync_legacy_attack_field(target, runtime)
	target.set("relay_boss_runtime", runtime)

static func _is_rhythm_explosion_hazard(hazard: Dictionary) -> bool:
	return bool(hazard.get("rhythmExplosionVisual", false)) \
		or String(hazard.get("kind", "")) == "rhythm_explosion" \
		or String(hazard.get("source", "")) == "relay_boss_rhythm_explosion" \
		or String(hazard.get("attackId", hazard.get("bossAttackId", ""))) == "rhythm_explosion"

static func _is_rhythm_explosion_visual_effect(effect: Dictionary) -> bool:
	var kind := String(effect.get("kind", ""))
	return kind.begins_with("relay_rhythm_explosion_") \
		or String(effect.get("bossAttackId", effect.get("attackId", ""))) == "rhythm_explosion"

static func clear_kuso_maro_drop_visuals_for_target(target: Node, _reason: String = "forced_cleanup") -> void:
	# Drop hazards are runtime-owned and can also be created by the
	# all_genre_rush composite. Filter only drop provenance here: when the
	# composite is active, its other hazards and active attack state remain.
	var runtime := ensure_for_target(target)
	var kept_hazards: Array = []
	for item in runtime.get("hazards", []) as Array:
		var hazard: Dictionary = item as Dictionary
		var kind := String(hazard.get("kind", ""))
		var source := String(hazard.get("source", ""))
		var attack_id := String(hazard.get("attackId", hazard.get("bossAttackId", "")))
		var is_drop := kind == "kuso_maro_drop" or source == "relay_boss_kuso_maro_drop" or attack_id == "kuso_maro_drop" or bool(hazard.get("kusoMaroDropVisual", false))
		if is_drop:
			continue
		kept_hazards.append(hazard)
	runtime["hazards"] = kept_hazards
	runtime["kuso_maro_drop_visual_effects"] = []
	var active: Dictionary = runtime.get("active_attack", {}) as Dictionary
	if String(active.get("id", "")) == "kuso_maro_drop":
		runtime["active_attack"] = _empty_attack()
	var pending: Dictionary = runtime.get("pending_attack", {}) as Dictionary
	if String(pending.get("id", "")) == "kuso_maro_drop":
		runtime["pending_attack"] = {}

	var effects_value: Variant = target.get("collab_effects")
	if effects_value is Array:
		var kept_effects: Array = []
		for item in effects_value as Array:
			var effect: Dictionary = item as Dictionary
			var effect_kind := String(effect.get("kind", ""))
			var effect_attack_id := String(effect.get("bossAttackId", ""))
			if effect_kind.begins_with("kuso_maro_drop_") or effect_attack_id == "kuso_maro_drop":
				continue
			kept_effects.append(effect)
		target.set("collab_effects", kept_effects)
	var hit_fx_value: Variant = target.get("hit_fx")
	if hit_fx_value is Array:
		var kept_hit_fx: Array = []
		for item in hit_fx_value as Array:
			var hit: Dictionary = item as Dictionary
			var hit_kind := String(hit.get("kind", ""))
			var hit_attack_id := String(hit.get("bossAttackId", ""))
			if hit_kind.begins_with("kuso_maro_drop_") or hit_attack_id == "kuso_maro_drop":
				continue
			kept_hit_fx.append(hit)
		target.set("hit_fx", kept_hit_fx)
	_sync_legacy_attack_field(target, runtime)
	target.set("relay_boss_runtime", runtime)

static func clear_noise_summon_visuals_for_target(target: Node, remove_spawned_children: bool = false, _reason: String = "forced_cleanup") -> void:
	# This is deliberately narrower than clear_runtime_objects_for_target.  It
	# is used by game-over/title/direct-stage cleanup and must not touch other
	# relay attacks, ordinary non-summon enemies, or unrelated relay projectiles.
	var runtime := ensure_for_target(target)
	runtime["noise_summon_pending_wave"] = {}
	runtime["noise_summon_visual_effects"] = []
	var active: Dictionary = runtime.get("active_attack", {}) as Dictionary
	if String(active.get("id", "")) == "noise_summon":
		runtime["active_attack"] = _empty_attack()
	var pending_attack: Dictionary = runtime.get("pending_attack", {}) as Dictionary
	if String(pending_attack.get("id", "")) == "noise_summon":
		runtime["pending_attack"] = {}

	var hit_fx_value: Variant = target.get("hit_fx")
	if hit_fx_value is Array:
		var kept_hit_fx: Array = []
		for item in hit_fx_value as Array:
			var hit: Dictionary = item as Dictionary
			var hit_kind := String(hit.get("kind", ""))
			if hit_kind.begins_with("relay_noise_summon_"):
				continue
			kept_hit_fx.append(hit)
		target.set("hit_fx", kept_hit_fx)

	var collab_effects_value: Variant = target.get("collab_effects")
	if collab_effects_value is Array:
		var kept_effects: Array = []
		for item in collab_effects_value as Array:
			var effect: Dictionary = item as Dictionary
			var effect_kind := String(effect.get("kind", ""))
			if effect_kind.begins_with("relay_noise_summon_"):
				continue
			kept_effects.append(effect)
		target.set("collab_effects", kept_effects)

	if remove_spawned_children:
		var kept_enemies: Array = []
		var carrier_uid := int(runtime.get("sync_star_carrier_uid", -1))
		for item in target.get("enemies") as Array:
			var enemy: Dictionary = item as Dictionary
			var is_noise_child := String(enemy.get("kind", "")) == "noise_ghost_comment" and bool(enemy.get("relayBossNoiseSummon", false))
			if is_noise_child:
				if int(enemy.get("uid", -1)) == carrier_uid:
					runtime["sync_star_carrier_uid"] = -1
				continue
			kept_enemies.append(enemy)
		target.set("enemies", kept_enemies)
	_sync_legacy_attack_field(target, runtime)
	target.set("relay_boss_runtime", runtime)

static func reset_noise_runtime_for_run_end(target: Node, _reason: String = "run_end") -> void:
	# Run ending is the one explicit boundary allowed to reset the shared noise
	# summon timers. Ordinary travel cleanup must leave common noise_summon
	# cooldowns and protected locks untouched.
	var runtime := ensure_for_target(target)
	runtime["noise_summon_cooldown"] = 0.0
	runtime["noise_summon_after_wave_lock"] = 0.0
	runtime["noise_summon_after_protected_attack_lock"] = 0.0
	runtime["noise_summon_pending_wave"] = {}
	runtime["noise_summon_visual_effects"] = []
	runtime["travelNoiseSummonLastResolution"] = "reset"
	runtime["travelNoiseSummonLastResolutionReason"] = _reason
	runtime["sync_star_carrier_uid"] = -1
	target.set("relay_boss_runtime", runtime)
	RelayBossMovementSystem.clear_travel_support_for_target(target, "run_end")

static func set_debug_overlay_for_target(target: Node, enabled: bool) -> void:
	var runtime := ensure_for_target(target)
	runtime["debug_overlay"] = enabled

static func clear_long_comment_line_visuals_for_target(target: Node, _reason: String = "forced_cleanup") -> void:
	# Keep this cleanup narrower than clear_runtime_objects_for_target.  The
	# composite all_genre_rush may own other hazards in the same array, so only
	# long-comment provenance is removed here.
	var runtime := ensure_for_target(target)
	var kept_hazards: Array = []
	for item in runtime.get("hazards", []) as Array:
		var hazard: Dictionary = item as Dictionary
		var kind := String(hazard.get("kind", ""))
		var source := String(hazard.get("source", ""))
		var attack_id := String(hazard.get("attackId", hazard.get("bossAttackId", "")))
		var is_long_comment_line := bool(hazard.get("longCommentLineVisual", false)) or kind == "long_comment_line" or source == "relay_boss_long_comment_line" or attack_id == "long_comment_line"
		if is_long_comment_line:
			continue
		kept_hazards.append(hazard)
	runtime["hazards"] = kept_hazards
	runtime["long_comment_line_visual_effects"] = []

	var active: Dictionary = runtime.get("active_attack", {}) as Dictionary
	if String(active.get("id", "")) == "long_comment_line":
		runtime["active_attack"] = _empty_attack()
	var pending: Dictionary = runtime.get("pending_attack", {}) as Dictionary
	if String(pending.get("id", "")) == "long_comment_line":
		runtime["pending_attack"] = {}

	var effects_value: Variant = target.get("collab_effects")
	if effects_value is Array:
		var kept_effects: Array = []
		for item in effects_value as Array:
			var effect: Dictionary = item as Dictionary
			var effect_kind := String(effect.get("kind", ""))
			var effect_attack_id := String(effect.get("bossAttackId", ""))
			if effect_kind.begins_with("long_comment_line") or effect_attack_id == "long_comment_line":
				continue
			kept_effects.append(effect)
		target.set("collab_effects", kept_effects)

	var hit_fx_value: Variant = target.get("hit_fx")
	if hit_fx_value is Array:
		var kept_hit_fx: Array = []
		for item in hit_fx_value as Array:
			var hit: Dictionary = item as Dictionary
			var hit_kind := String(hit.get("kind", ""))
			if hit_kind == "long_comment_line_hit" or String(hit.get("bossAttackId", "")) == "long_comment_line":
				continue
			kept_hit_fx.append(hit)
		target.set("hit_fx", kept_hit_fx)
	_sync_legacy_attack_field(target, runtime)
	target.set("relay_boss_runtime", runtime)

static func clear_race_lane_charge_visuals_for_target(target: Node, _reason: String = "forced_cleanup") -> void:
	# Race lanes are relay hazards, but this cleanup is intentionally narrower
	# than clear_runtime_objects_for_target so game-over does not remove another
	# relay attack that happens to share the runtime arrays.
	var runtime := ensure_for_target(target)
	var kept_hazards: Array = []
	for item in runtime.get("hazards", []) as Array:
		var hazard: Dictionary = item as Dictionary
		var kind := String(hazard.get("kind", ""))
		var source := String(hazard.get("source", ""))
		var attack_id := String(hazard.get("attackId", hazard.get("bossAttackId", "")))
		var is_race_lane := bool(hazard.get("raceLaneChargeVisual", false)) or kind == "race_lane_charge" or source == "relay_boss_race_lane_charge" or attack_id == "race_lane_charge"
		if is_race_lane:
			continue
		kept_hazards.append(hazard)
	runtime["hazards"] = kept_hazards
	runtime["race_lane_charge_visual_effects"] = []

	var active: Dictionary = runtime.get("active_attack", {}) as Dictionary
	if String(active.get("id", "")) == "race_lane_charge":
		runtime["active_attack"] = _empty_attack()
	var pending: Dictionary = runtime.get("pending_attack", {}) as Dictionary
	if String(pending.get("id", "")) == "race_lane_charge":
		runtime["pending_attack"] = {}

	var effects_value: Variant = target.get("collab_effects")
	if effects_value is Array:
		var kept_effects: Array = []
		for item in effects_value as Array:
			var effect: Dictionary = item as Dictionary
			var effect_kind := String(effect.get("kind", ""))
			var effect_attack_id := String(effect.get("bossAttackId", effect.get("attackId", "")))
			if effect_kind.begins_with("race_lane_charge_") or effect_attack_id == "race_lane_charge":
				continue
			kept_effects.append(effect)
		target.set("collab_effects", kept_effects)

	var hit_fx_value: Variant = target.get("hit_fx")
	if hit_fx_value is Array:
		var kept_hit_fx: Array = []
		for item in hit_fx_value as Array:
			var hit: Dictionary = item as Dictionary
			var hit_kind := String(hit.get("kind", ""))
			var hit_attack_id := String(hit.get("bossAttackId", hit.get("attackId", "")))
			if hit_kind.begins_with("race_lane_charge_") or hit_attack_id == "race_lane_charge":
				continue
			kept_hit_fx.append(hit)
		target.set("hit_fx", kept_hit_fx)
	_sync_legacy_attack_field(target, runtime)
	target.set("relay_boss_runtime", runtime)

static func clear_game_over_barrage_visuals_for_target(target: Node, _reason: String = "forced_cleanup") -> void:
	# Game-over cleanup must not clear the shared enemy_bullets array.  Keep
	# ordinary enemy bullets and every other relay projectile, and filter only
	# this attack's explicit provenance/visual identity.
	var runtime := ensure_for_target(target)
	var active: Dictionary = runtime.get("active_attack", {}) as Dictionary
	if String(active.get("id", "")) == "game_over_barrage":
		runtime["active_attack"] = _empty_attack()
	var pending: Dictionary = runtime.get("pending_attack", {}) as Dictionary
	if String(pending.get("id", "")) == "game_over_barrage":
		runtime["pending_attack"] = {}
	var bullets_value: Variant = target.get("enemy_bullets")
	if bullets_value is Array:
		var kept_bullets: Array = []
		for item in bullets_value as Array:
			var bullet: Dictionary = item as Dictionary
			if _is_game_over_barrage_bullet(bullet):
				continue
			kept_bullets.append(bullet)
		target.set("enemy_bullets", kept_bullets)

	var hit_fx_value: Variant = target.get("hit_fx")
	if hit_fx_value is Array:
		var kept_hit_fx: Array = []
		for item in hit_fx_value as Array:
			var fx: Dictionary = item as Dictionary
			if _is_game_over_barrage_visual_fx(fx):
				continue
			kept_hit_fx.append(fx)
		target.set("hit_fx", kept_hit_fx)

	var collab_effects_value: Variant = target.get("collab_effects")
	if collab_effects_value is Array:
		var kept_effects: Array = []
		for item in collab_effects_value as Array:
			var effect: Dictionary = item as Dictionary
			if _is_game_over_barrage_visual_fx(effect):
				continue
			kept_effects.append(effect)
		target.set("collab_effects", kept_effects)
	_sync_legacy_attack_field(target, runtime)
	target.set("relay_boss_runtime", runtime)

static func _is_game_over_barrage_bullet(bullet: Dictionary) -> bool:
	if not bool(bullet.get("relayBossProjectile", false)):
		return false
	return String(bullet.get("visualKind", "")) == "game_over_barrage" \
		or String(bullet.get("sourceKind", "")) == "game_over_barrage" \
		or String(bullet.get("source", "")) == "relay_boss_game_over_barrage"

static func _is_game_over_barrage_visual_fx(fx: Dictionary) -> bool:
	var kind := String(fx.get("kind", ""))
	return kind == "game_over_barrage_launch" or kind == "game_over_barrage_hit" \
		or String(fx.get("bossAttackId", "")) == "game_over_barrage" \
		or String(fx.get("source", "")) == "relay_boss_game_over_barrage"

static func clear_travel_comment_salvo_for_target(target: Node, _reason: String = "forced_cleanup") -> void:
	# Travel comment salvos share enemy_bullets with every other enemy and relay
	# projectile.  Filter only their exact provenance so natural arrival
	# carry-over remains intact until an explicit ending/reset boundary.
	var bullets_value: Variant = target.get("enemy_bullets")
	if bullets_value is Array:
		var kept_bullets: Array = []
		for item in bullets_value as Array:
			var bullet: Dictionary = item as Dictionary
			if _is_travel_comment_salvo_bullet(bullet):
				continue
			kept_bullets.append(bullet)
		target.set("enemy_bullets", kept_bullets)

	var hit_fx_value: Variant = target.get("hit_fx")
	if hit_fx_value is Array:
		var kept_hit_fx: Array = []
		for item in hit_fx_value as Array:
			var fx: Dictionary = item as Dictionary
			if _is_travel_comment_salvo_visual_fx(fx):
				continue
			kept_hit_fx.append(fx)
		target.set("hit_fx", kept_hit_fx)

	var collab_effects_value: Variant = target.get("collab_effects")
	if collab_effects_value is Array:
		var kept_effects: Array = []
		for item in collab_effects_value as Array:
			var effect: Dictionary = item as Dictionary
			if _is_travel_comment_salvo_visual_fx(effect):
				continue
			kept_effects.append(effect)
		target.set("collab_effects", kept_effects)

static func _is_travel_comment_salvo_bullet(bullet: Dictionary) -> bool:
	return String(bullet.get("sourceKind", "")) == TRAVEL_COMMENT_SALVO_KIND \
		or String(bullet.get("source", "")) == TRAVEL_COMMENT_SALVO_SOURCE \
		or String(bullet.get("visualKind", "")) == TRAVEL_COMMENT_SALVO_KIND

static func _is_travel_comment_salvo_visual_fx(fx: Dictionary) -> bool:
	var kind := String(fx.get("kind", ""))
	return kind in ["travel_comment_launch", "travel_comment_hit"] \
		or String(fx.get("bossAttackId", "")) == TRAVEL_COMMENT_SALVO_KIND \
		or String(fx.get("source", "")) == TRAVEL_COMMENT_SALVO_SOURCE \
		or String(fx.get("sourceKind", "")) == TRAVEL_COMMENT_SALVO_KIND

static func clear_travel_noise_shot_for_target(target: Node, _reason: String = "forced_cleanup") -> void:
	# Travel noise shots deliberately share enemy_bullets with every other
	# projectile.  Remove only the exact noise provenance; natural anchor arrival
	# and unrelated relay/travel bullets must remain untouched.
	var bullets_value: Variant = target.get("enemy_bullets")
	if bullets_value is Array:
		var kept_bullets: Array = []
		for item in bullets_value as Array:
			var bullet: Dictionary = item as Dictionary
			if _is_travel_noise_shot_bullet(bullet):
				continue
			kept_bullets.append(bullet)
		target.set("enemy_bullets", kept_bullets)

	var hit_fx_value: Variant = target.get("hit_fx")
	if hit_fx_value is Array:
		var kept_hit_fx: Array = []
		for item in hit_fx_value as Array:
			var fx: Dictionary = item as Dictionary
			if _is_travel_noise_shot_visual_fx(fx):
				continue
			kept_hit_fx.append(fx)
		target.set("hit_fx", kept_hit_fx)

	var collab_effects_value: Variant = target.get("collab_effects")
	if collab_effects_value is Array:
		var kept_effects: Array = []
		for item in collab_effects_value as Array:
			var effect: Dictionary = item as Dictionary
			if _is_travel_noise_shot_visual_fx(effect):
				continue
			kept_effects.append(effect)
		target.set("collab_effects", kept_effects)

static func _is_travel_noise_shot_bullet(bullet: Dictionary) -> bool:
	return String(bullet.get("source", "")) == TRAVEL_NOISE_SHOT_SOURCE \
		or String(bullet.get("sourceKind", "")) == TRAVEL_NOISE_SHOT_KIND \
		or String(bullet.get("visualKind", "")) == TRAVEL_NOISE_SHOT_KIND \
		or String(bullet.get("attackId", "")) == TRAVEL_NOISE_SHOT_KIND

static func _is_travel_noise_shot_visual_fx(fx: Dictionary) -> bool:
	var kind := String(fx.get("kind", ""))
	return kind in ["travel_noise_launch", "travel_noise_hit"] \
		or String(fx.get("bossAttackId", "")) == TRAVEL_NOISE_SHOT_KIND \
		or String(fx.get("attackId", "")) == TRAVEL_NOISE_SHOT_KIND \
		or String(fx.get("source", "")) == TRAVEL_NOISE_SHOT_SOURCE \
		or String(fx.get("sourceKind", "")) == TRAVEL_NOISE_SHOT_KIND \
		or String(fx.get("visualKind", "")) == TRAVEL_NOISE_SHOT_KIND

static func clear_eraser_sweep_visuals_for_target(target: Node, _reason: String = "forced_cleanup") -> void:
	# Eraser sweep is a relay runtime hazard, so cleanup is provenance-based and
	# deliberately narrower than clear_runtime_objects_for_target.  This keeps
	# dirty paint, guide lines, and every other relay hazard intact.
	var runtime := ensure_for_target(target)
	var kept_hazards: Array = []
	for item in runtime.get("hazards", []) as Array:
		var hazard: Dictionary = item as Dictionary
		if _is_eraser_sweep_hazard(hazard):
			continue
		kept_hazards.append(hazard)
	runtime["hazards"] = kept_hazards
	runtime["eraser_sweep_visual_effects"] = []
	var active: Dictionary = runtime.get("active_attack", {}) as Dictionary
	if String(active.get("id", "")) == "eraser_sweep":
		runtime["active_attack"] = _empty_attack()
	var pending: Dictionary = runtime.get("pending_attack", {}) as Dictionary
	if String(pending.get("id", "")) == "eraser_sweep":
		runtime["pending_attack"] = {}

	var effects_value: Variant = target.get("collab_effects")
	if effects_value is Array:
		var kept_effects: Array = []
		for item in effects_value as Array:
			var effect: Dictionary = item as Dictionary
			if _is_eraser_sweep_visual_effect(effect):
				continue
			kept_effects.append(effect)
		target.set("collab_effects", kept_effects)
	var hit_fx_value: Variant = target.get("hit_fx")
	if hit_fx_value is Array:
		var kept_hit_fx: Array = []
		for item in hit_fx_value as Array:
			var hit: Dictionary = item as Dictionary
			if _is_eraser_sweep_visual_effect(hit):
				continue
			kept_hit_fx.append(hit)
		target.set("hit_fx", kept_hit_fx)
	_sync_legacy_attack_field(target, runtime)
	target.set("relay_boss_runtime", runtime)

static func _is_eraser_sweep_hazard(hazard: Dictionary) -> bool:
	return String(hazard.get("kind", "")) == "eraser_sweep" \
		or bool(hazard.get("eraserSweepVisual", false)) \
		or String(hazard.get("source", "")) == "relay_boss_eraser_sweep" \
		or String(hazard.get("attackId", hazard.get("bossAttackId", ""))) == "eraser_sweep"

static func _is_eraser_sweep_visual_effect(effect: Dictionary) -> bool:
	var kind := String(effect.get("kind", ""))
	return kind.begins_with("eraser_sweep_") \
		or String(effect.get("bossAttackId", effect.get("attackId", ""))) == "eraser_sweep" \
		or String(effect.get("source", "")) == "relay_boss_eraser_sweep"

static func clear_paint_warning_visuals_for_target(target: Node, _reason: String = "forced_cleanup") -> void:
	# Paint warning is a relay hazard, but its lifecycle cleanup is deliberately
	# provenance-scoped so dirty paint, paint orbs, and every other relay attack
	# remain untouched during ending/title/reset transitions.
	var runtime := ensure_for_target(target)
	var kept_hazards: Array = []
	for item in runtime.get("hazards", []) as Array:
		var hazard: Dictionary = item as Dictionary
		if _is_paint_warning_hazard(hazard):
			continue
		kept_hazards.append(hazard)
	runtime["hazards"] = kept_hazards
	runtime["paint_warning_visual_effects"] = []
	var active: Dictionary = runtime.get("active_attack", {}) as Dictionary
	if String(active.get("id", "")) == "paint_warning":
		runtime["active_attack"] = _empty_attack()
	var pending: Dictionary = runtime.get("pending_attack", {}) as Dictionary
	if String(pending.get("id", "")) == "paint_warning":
		runtime["pending_attack"] = {}

	var collab_effects_value: Variant = target.get("collab_effects")
	if collab_effects_value is Array:
		var kept_effects: Array = []
		for item in collab_effects_value as Array:
			var effect: Dictionary = item as Dictionary
			if _is_paint_warning_visual_effect(effect):
				continue
			kept_effects.append(effect)
		target.set("collab_effects", kept_effects)
	var hit_fx_value: Variant = target.get("hit_fx")
	if hit_fx_value is Array:
		var kept_hit_fx: Array = []
		for item in hit_fx_value as Array:
			var hit: Dictionary = item as Dictionary
			if _is_paint_warning_visual_effect(hit):
				continue
			kept_hit_fx.append(hit)
		target.set("hit_fx", kept_hit_fx)
	_sync_legacy_attack_field(target, runtime)
	target.set("relay_boss_runtime", runtime)

static func clear_division_noise_visuals_for_target(target: Node, remove_spawned_children: bool = true, _reason: String = "forced_cleanup") -> void:
	# division_noise has two independent runtime layers: the fixed player/
	# partner anchors and the explicitly tagged noise_ghost_comment children.
	# Keep this filter narrower than clear_runtime_objects_for_target so another
	# relay attack, collab_division_noise, or a normal noise enemy survives.
	var runtime := ensure_for_target(target)
	var kept_hazards: Array = []
	for item in runtime.get("hazards", []) as Array:
		var hazard: Dictionary = item as Dictionary
		if _is_division_noise_anchor_hazard(hazard):
			continue
		kept_hazards.append(hazard)
	runtime["hazards"] = kept_hazards
	runtime["division_noise_visual_effects"] = []
	var active: Dictionary = runtime.get("active_attack", {}) as Dictionary
	if String(active.get("id", "")) == "division_noise":
		runtime["active_attack"] = _empty_attack()
	var pending: Dictionary = runtime.get("pending_attack", {}) as Dictionary
	if String(pending.get("id", "")) == "division_noise":
		runtime["pending_attack"] = {}

	var collab_effects_value: Variant = target.get("collab_effects")
	if collab_effects_value is Array:
		var kept_effects: Array = []
		for item in collab_effects_value as Array:
			var effect: Dictionary = item as Dictionary
			if _is_division_noise_visual_effect(effect):
				continue
			kept_effects.append(effect)
		target.set("collab_effects", kept_effects)
	var hit_fx_value: Variant = target.get("hit_fx")
	if hit_fx_value is Array:
		var kept_hit_fx: Array = []
		for item in hit_fx_value as Array:
			var hit: Dictionary = item as Dictionary
			if _is_division_noise_visual_effect(hit):
				continue
			kept_hit_fx.append(hit)
		target.set("hit_fx", kept_hit_fx)
	if remove_spawned_children:
		var kept_enemies: Array = []
		for item in target.get("enemies") as Array:
			var enemy: Dictionary = item as Dictionary
			if String(enemy.get("kind", "")) == "noise_ghost_comment" and bool(enemy.get("divisionNoiseChild", false)):
				continue
			kept_enemies.append(enemy)
		target.set("enemies", kept_enemies)
	_sync_legacy_attack_field(target, runtime)
	target.set("relay_boss_runtime", runtime)

static func _is_division_noise_anchor_hazard(hazard: Dictionary) -> bool:
	return bool(hazard.get("divisionNoiseAnchor", false)) \
		or (String(hazard.get("kind", "")) == "division_noise" and String(hazard.get("source", "")) == "relay_boss_division_noise") \
		or (String(hazard.get("attackId", hazard.get("bossAttackId", ""))) == "division_noise" and String(hazard.get("kind", "")) == "division_noise")

static func _is_division_noise_visual_effect(effect: Dictionary) -> bool:
	var kind := String(effect.get("kind", ""))
	return kind.begins_with("relay_division_noise_") \
		or String(effect.get("source", "")) == "relay_boss_division_noise"

static func _is_paint_warning_hazard(hazard: Dictionary) -> bool:
	return bool(hazard.get("paintWarningVisual", false)) \
		or String(hazard.get("kind", "")) == "paint_warning" \
		or String(hazard.get("source", "")) == "relay_boss_paint_warning" \
		or String(hazard.get("attackId", hazard.get("bossAttackId", ""))) == "paint_warning"

static func _is_paint_warning_visual_effect(effect: Dictionary) -> bool:
	var kind := String(effect.get("kind", ""))
	return kind.begins_with("paint_warning_") \
		or String(effect.get("bossAttackId", effect.get("attackId", ""))) == "paint_warning" \
		or String(effect.get("source", "")) == "relay_boss_paint_warning"

static func has_handler(attack_id: String) -> bool:
	return ATTACK_IDS.has(attack_id)

static func handler_name(attack_id: String) -> String:
	return "_handle_" + attack_id if ATTACK_IDS.has(attack_id) else ""

static func _empty_attack() -> Dictionary:
	return {
		"id": "",
		"state": STATE_IDLE,
		"timer": 0.0,
		"elapsed": 0.0,
		"serial": 0,
		"large": false,
		"payload": {},
		"allGenreRushCastSerial": 0,
		"allGenreRushStepIndex": -1,
		"allGenreRushCompletedMask": 0
	}

static func _sync_legacy_attack_field(target: Node, runtime: Dictionary) -> void:
	target.set("relay_boss_active_attack", (runtime.get("active_attack", {}) as Dictionary).duplicate(true))

static func _decay_reuse_cooldowns(runtime: Dictionary, delta: float) -> void:
	var cooldowns: Dictionary = runtime.get("reuse_cooldowns", {}) as Dictionary
	for key in cooldowns.keys():
		cooldowns[key] = maxf(0.0, float(cooldowns[key]) - delta)
	runtime["reuse_cooldowns"] = cooldowns

static func _decay_noise_runtime(_target: Node, runtime: Dictionary, delta: float) -> void:
	runtime["noise_summon_cooldown"] = maxf(0.0, float(runtime.get("noise_summon_cooldown", 0.0)) - delta)
	runtime["noise_summon_after_wave_lock"] = maxf(0.0, float(runtime.get("noise_summon_after_wave_lock", 0.0)) - delta)
	runtime["noise_summon_after_protected_attack_lock"] = maxf(0.0, float(runtime.get("noise_summon_after_protected_attack_lock", 0.0)) - delta)
	runtime["sync_star_drop_cooldown"] = maxf(0.0, float(runtime.get("sync_star_drop_cooldown", 0.0)) - delta)
	var kept_effects: Array = []
	for item in runtime.get("noise_summon_visual_effects", []) as Array:
		var effect: Dictionary = item as Dictionary
		effect["life"] = maxf(0.0, float(effect.get("life", 0.0)) - delta)
		if float(effect.get("life", 0.0)) > 0.0:
			kept_effects.append(effect)
	runtime["noise_summon_visual_effects"] = kept_effects

static func _decay_kuso_maro_drop_visual_effects(runtime: Dictionary, delta: float) -> void:
	var kept_effects: Array = []
	for item in runtime.get("kuso_maro_drop_visual_effects", []) as Array:
		var effect: Dictionary = item as Dictionary
		effect["life"] = maxf(0.0, float(effect.get("life", 0.0)) - delta)
		if float(effect.get("life", 0.0)) > 0.0:
			kept_effects.append(effect)
	runtime["kuso_maro_drop_visual_effects"] = kept_effects

static func _decay_long_comment_line_visual_effects(runtime: Dictionary, delta: float) -> void:
	var kept_effects: Array = []
	for item in runtime.get("long_comment_line_visual_effects", []) as Array:
		var effect: Dictionary = item as Dictionary
		effect["life"] = maxf(0.0, float(effect.get("life", 0.0)) - delta)
		if float(effect.get("life", 0.0)) > 0.0:
			kept_effects.append(effect)
	runtime["long_comment_line_visual_effects"] = kept_effects

static func _decay_race_lane_charge_visual_effects(runtime: Dictionary, delta: float) -> void:
	var kept_effects: Array = []
	for item in runtime.get("race_lane_charge_visual_effects", []) as Array:
		var effect: Dictionary = item as Dictionary
		effect["life"] = maxf(0.0, float(effect.get("life", 0.0)) - delta)
		if float(effect.get("life", 0.0)) > 0.0:
			kept_effects.append(effect)
	runtime["race_lane_charge_visual_effects"] = kept_effects

static func _decay_howling_ring_visual_effects(runtime: Dictionary, delta: float) -> void:
	var kept_effects: Array = []
	for item in runtime.get("howling_ring_visual_effects", []) as Array:
		var effect: Dictionary = item as Dictionary
		effect["life"] = maxf(0.0, float(effect.get("life", 0.0)) - delta)
		if float(effect.get("life", 0.0)) > 0.0:
			kept_effects.append(effect)
	runtime["howling_ring_visual_effects"] = kept_effects

static func _decay_pitch_wave_visual_effects(runtime: Dictionary, delta: float) -> void:
	var kept_effects: Array = []
	for item in runtime.get("pitch_wave_visual_effects", []) as Array:
		var effect: Dictionary = item as Dictionary
		effect["life"] = maxf(0.0, float(effect.get("life", 0.0)) - delta)
		if float(effect.get("life", 0.0)) > 0.0:
			kept_effects.append(effect)
	runtime["pitch_wave_visual_effects"] = kept_effects

static func _decay_rhythm_explosion_visual_effects(runtime: Dictionary, delta: float) -> void:
	var kept_effects: Array = []
	for item in runtime.get("rhythm_explosion_visual_effects", []) as Array:
		var effect: Dictionary = item as Dictionary
		effect["life"] = maxf(0.0, float(effect.get("life", 0.0)) - delta)
		if float(effect.get("life", 0.0)) > 0.0:
			kept_effects.append(effect)
	runtime["rhythm_explosion_visual_effects"] = kept_effects

static func _decay_fake_gift_trap_visual_effects(runtime: Dictionary, delta: float) -> void:
	var kept_effects: Array = []
	for item in runtime.get("fake_gift_trap_visual_effects", []) as Array:
		var effect: Dictionary = item as Dictionary
		effect["life"] = maxf(0.0, float(effect.get("life", 0.0)) - delta)
		if float(effect.get("life", 0.0)) > 0.0:
			kept_effects.append(effect)
	runtime["fake_gift_trap_visual_effects"] = kept_effects

static func _decay_dirty_paint_visual_effects(runtime: Dictionary, delta: float) -> void:
	var kept_effects: Array = []
	for item in runtime.get("dirty_paint_visual_effects", []) as Array:
		var effect: Dictionary = item as Dictionary
		effect["life"] = maxf(0.0, float(effect.get("life", 0.0)) - delta)
		if float(effect.get("life", 0.0)) > 0.0:
			kept_effects.append(effect)
	runtime["dirty_paint_visual_effects"] = kept_effects

static func _decay_eraser_sweep_visual_effects(runtime: Dictionary, delta: float) -> void:
	var kept_effects: Array = []
	for item in runtime.get("eraser_sweep_visual_effects", []) as Array:
		var effect: Dictionary = item as Dictionary
		effect["life"] = maxf(0.0, float(effect.get("life", 0.0)) - delta)
		if float(effect.get("life", 0.0)) > 0.0:
			kept_effects.append(effect)
	runtime["eraser_sweep_visual_effects"] = kept_effects

static func _decay_paint_warning_visual_effects(runtime: Dictionary, delta: float) -> void:
	var kept_effects: Array = []
	for item in runtime.get("paint_warning_visual_effects", []) as Array:
		var effect: Dictionary = item as Dictionary
		effect["life"] = maxf(0.0, float(effect.get("life", 0.0)) - delta)
		if float(effect.get("life", 0.0)) > 0.0:
			kept_effects.append(effect)
	runtime["paint_warning_visual_effects"] = kept_effects

static func _decay_division_noise_visual_effects(runtime: Dictionary, delta: float) -> void:
	var kept_effects: Array = []
	for item in runtime.get("division_noise_visual_effects", []) as Array:
		var effect: Dictionary = item as Dictionary
		effect["life"] = maxf(0.0, float(effect.get("life", 0.0)) - delta)
		if float(effect.get("life", 0.0)) > 0.0:
			kept_effects.append(effect)
	runtime["division_noise_visual_effects"] = kept_effects

static func _decay_collab_break_visual_effects(runtime: Dictionary, delta: float) -> void:
	var kept_effects: Array = []
	for item in runtime.get("collab_break_visual_effects", []) as Array:
		var effect: Dictionary = item as Dictionary
		effect["life"] = maxf(0.0, float(effect.get("life", 0.0)) - delta)
		if float(effect.get("life", 0.0)) > 0.0:
			kept_effects.append(effect)
	runtime["collab_break_visual_effects"] = kept_effects

static func _fake_gift_trap_visual_seed(attack_serial: int, slot_index: int, pos: Vector2) -> float:
	var raw := sin(
		float(attack_serial) * 17.173
		+ float(slot_index) * 43.917
		+ pos.x * 0.0137
		+ pos.y * 0.0193
	) * 43758.5453
	return fposmod(raw, 1.0)

static func _fake_gift_trap_walls_for_target(target: Node) -> Array:
	var effect_walls: Array = []
	var effect_walls_value: Variant = target.get("effect_walls")
	if effect_walls_value is Array:
		effect_walls = effect_walls_value as Array
	var frame_id := "relay_boss"
	return EnemySystemScript.movement_wall_rects(effect_walls, frame_id)

static func _fake_gift_trap_candidate_is_safe(target: Node, runtime: Dictionary, candidate: Vector2, arena: Rect2, placed: Array) -> bool:
	var player_pos := Vector2(target.get("player_pos"))
	if candidate.distance_squared_to(player_pos) < FAKE_GIFT_TRAP_PLAYER_CLEARANCE * FAKE_GIFT_TRAP_PLAYER_CLEARANCE:
		return false
	for raw_wall in _fake_gift_trap_walls_for_target(target):
		var wall: Rect2 = raw_wall as Rect2
		if wall.grow(FAKE_GIFT_TRAP_VISUAL_RADIUS).has_point(candidate):
			return false
	for item in runtime.get("fake_gift_traps", []) as Array:
		var trap: Dictionary = item as Dictionary
		if String(trap.get("state", "WAITING")) == "DONE":
			continue
		if candidate.distance_squared_to(Vector2(trap.get("pos", Vector2.ZERO))) < FAKE_GIFT_TRAP_SPACING * FAKE_GIFT_TRAP_SPACING:
			return false
	for item in placed:
		var placed_pos := Vector2(item)
		if candidate.distance_squared_to(placed_pos) < FAKE_GIFT_TRAP_SPACING * FAKE_GIFT_TRAP_SPACING:
			return false
	var destructibles_value: Variant = target.get("destructibles")
	if destructibles_value is Array:
		for item in destructibles_value as Array:
			var box: Dictionary = item as Dictionary
			if float(box.get("hp", 0.0)) <= 0.0:
				continue
			if candidate.distance_squared_to(Vector2(box.get("pos", Vector2.ZERO))) < 86.0 * 86.0:
				return false
	return true

static func _fake_gift_trap_position_for_slot(target: Node, runtime: Dictionary, raw_pos: Vector2, base_angle: float, arena: Rect2, placed: Array) -> Vector2:
	var raw_clamped := _clamp_point_to_arena(raw_pos, arena, FAKE_GIFT_TRAP_PLACEMENT_MARGIN)
	if _fake_gift_trap_candidate_is_safe(target, runtime, raw_clamped, arena, placed):
		return raw_clamped
	var radii := [170.0, 150.0, 130.0]
	var angle_offsets := [0.0, deg_to_rad(12.0), deg_to_rad(-12.0), deg_to_rad(24.0), deg_to_rad(-24.0)]
	var best := Vector2(INF, INF)
	var best_score := INF
	var candidate_order := 0
	for radius in radii:
		for angle_offset in angle_offsets:
			var candidate := _clamp_point_to_arena(Vector2(target.get("player_pos")) + Vector2.from_angle(base_angle + float(angle_offset)) * float(radius), arena, FAKE_GIFT_TRAP_PLACEMENT_MARGIN)
			if _fake_gift_trap_candidate_is_safe(target, runtime, candidate, arena, placed):
				var score := candidate.distance_squared_to(raw_clamped) + float(candidate_order) * 0.001
				if score < best_score:
					best = candidate
					best_score = score
			candidate_order += 1
		if best_score < INF:
			break
	# A fixed lattice is a last deterministic fallback for an unusually dense
	# arena. It never changes the RNG loop and may legitimately leave a slot
	# unplaced if no safe point exists.
	if is_inf(best.x):
		var grid_step := 64.0
		var start_x := arena.position.x + FAKE_GIFT_TRAP_PLACEMENT_MARGIN
		var start_y := arena.position.y + FAKE_GIFT_TRAP_PLACEMENT_MARGIN
		var y := start_y
		while y <= arena.end.y - FAKE_GIFT_TRAP_PLACEMENT_MARGIN and is_inf(best.x):
			var x := start_x
			while x <= arena.end.x - FAKE_GIFT_TRAP_PLACEMENT_MARGIN:
				var grid_candidate := Vector2(x, y)
				if _fake_gift_trap_candidate_is_safe(target, runtime, grid_candidate, arena, placed):
					best = grid_candidate
					break
				x += grid_step
			y += grid_step
	return best

static func _update_fake_gift_traps(target: Node, runtime: Dictionary, delta: float, _arena: Rect2, feedback: Dictionary) -> void:
	var traps: Array = runtime.get("fake_gift_traps", []) as Array
	if traps.is_empty():
		return
	var player_pos := Vector2(target.get("player_pos"))
	var kept_traps: Array = []
	for item in traps:
		var trap: Dictionary = item as Dictionary
		trap["materializeTimer"] = maxf(0.0, float(trap.get("materializeTimer", 0.0)) - delta)
		var state := String(trap.get("state", "WAITING"))
		if state == "WAITING":
			trap["life"] = maxf(0.0, float(trap.get("life", FAKE_GIFT_TRAP_DEFAULT_LIFETIME)) - delta)
			var trigger_radius := maxf(0.0, float(trap.get("triggerRadius", FAKE_GIFT_TRAP_TRIGGER_RADIUS)))
			if player_pos.distance_squared_to(Vector2(trap.get("pos", Vector2.ZERO))) <= trigger_radius * trigger_radius or float(trap.get("life", 0.0)) <= 0.0:
				# Entering ARMED never detonates on the same update. The player gets
				# the full warning window even when proximity caused the transition.
				trap["state"] = "ARMED"
				trap["warningTimer"] = float(trap.get("warningMaxTime", FAKE_GIFT_TRAP_DEFAULT_WARNING))
				trap["warningStarted"] = true
				kept_traps.append(trap)
				continue
			kept_traps.append(trap)
			continue
		if state == "ARMED":
			trap["warningTimer"] = float(trap.get("warningTimer", FAKE_GIFT_TRAP_DEFAULT_WARNING)) - delta
			if float(trap.get("warningTimer", 0.0)) > 0.0:
				kept_traps.append(trap)
				continue
			trap["state"] = "DETONATE"
			trap["consumed"] = true
			var trap_pos := Vector2(trap.get("pos", Vector2.ZERO))
			var trigger_radius := maxf(0.0, float(trap.get("triggerRadius", FAKE_GIFT_TRAP_TRIGGER_RADIUS)))
			var inside := player_pos.distance_squared_to(trap_pos) <= trigger_radius * trigger_radius
			if inside:
				var trap_damage := int(trap.get("damage", 11))
				if HardModeSystemScript.is_high_difficulty_target(target):
					trap_damage = roundi(float(trap_damage) * float(HardModeSystemScript.final_boss_rates(HardModeSystemScript.runtime_for_target(target)).get("attackRate", 1.10)))
				(feedback["damageEvents"] as Array).append({
					"source": FAKE_GIFT_TRAP_SOURCE,
					"damage": trap_damage,
					"attackId": "fake_gift_trap",
					"attackType": "fake_gift_trap"
				})
			var effects: Array = runtime.get("fake_gift_trap_visual_effects", []) as Array
			effects.append({
				"kind": "fake_gift_trap_detonate",
				"bossAttackId": "fake_gift_trap",
				"pos": trap_pos,
				"visualSeed": float(trap.get("visualSeed", 0.0)),
				"slotIndex": int(trap.get("slotIndex", 0)),
				"attackSerial": int(trap.get("attackSerial", 0)),
				"hit": inside,
				"life": FAKE_GIFT_TRAP_DETONATION_DURATION,
				"maxLife": FAKE_GIFT_TRAP_DETONATION_DURATION
			})
			runtime["fake_gift_trap_visual_effects"] = effects
			continue
		# DONE/DETONATE are one-shot states and are not retained as gameplay
		# traps. The detonation visual above owns the short after-effect.
	runtime["fake_gift_traps"] = kept_traps

static func _sync_noise_carrier_uid(target: Node, runtime: Dictionary) -> void:
	var carrier_uid := int(runtime.get("sync_star_carrier_uid", -1))
	if carrier_uid < 0:
		return
	for item in target.get("enemies") as Array:
		var enemy: Dictionary = item as Dictionary
		if int(enemy.get("uid", -1)) != carrier_uid:
			continue
		if bool(enemy.get("syncStarCarrier", false)) and not bool(enemy.get("defeatResolved", false)) and float(enemy.get("relayBossSummonLifetime", 1.0)) > 0.0:
			return
	runtime["sync_star_carrier_uid"] = -1

static func _cancel_travel_noise_summon_if_travel_ended(target: Node, runtime: Dictionary, arena: Rect2) -> void:
	var pending: Dictionary = runtime.get("noise_summon_pending_wave", {}) as Dictionary
	if pending.is_empty() or String(pending.get("source", "")) != TRAVEL_NOISE_SUMMON_SOURCE:
		return
	var movement_state := RelayBossMovementSystem.state_for_target(target)
	if movement_state == RelayBossMovementSystem.STATE_REPOSITION or movement_state == RelayBossMovementSystem.STATE_REPOSITION_WARNING:
		return
	# A travel warning is valid only while the repositioning movement owns the
	# event. Normal arrival still has a valid travel-shot frame, while phase
	# movement, stun, defeat, and ending paths cannot safely emit a new shot.
	var travel_summon_serial := int(pending.get("travelNoiseSummonSerial", -1))
	var kept_effects: Array = []
	for item in runtime.get("noise_summon_visual_effects", []) as Array:
		var effect: Dictionary = item as Dictionary
		if int(effect.get("travelNoiseSummonSerial", -2)) == travel_summon_serial:
			continue
		kept_effects.append(effect)
	runtime["noise_summon_visual_effects"] = kept_effects
	runtime["noise_summon_pending_wave"] = {}
	var fallback_allowed := bool(target.get("relay_boss_active")) \
		and String(target.get("state")) == "playing" \
		and not bool(target.get("relay_boss_defeat_pending")) \
		and not bool(target.get("relay_boss_score_awarded")) \
		and movement_state != RelayBossMovementSystem.STATE_PHASE_TRANSITION \
		and movement_state != RelayBossMovementSystem.STATE_STUNNED \
		and movement_state != RelayBossMovementSystem.STATE_DEAD
	if fallback_allowed:
		runtime["travelNoiseSummonLastResolution"] = "fallback_noise_shot"
		runtime["travelNoiseSummonLastResolutionReason"] = "reposition_ended_%s" % movement_state
		emit_travel_attack_for_target(target, "travel_noise_shot", arena, pending.get("travelContext", {}) as Dictionary)
	else:
		runtime["travelNoiseSummonLastResolution"] = "cancel"
		runtime["travelNoiseSummonLastResolutionReason"] = "reposition_ended_%s" % movement_state

static func _pick_and_begin(target: Node, runtime: Dictionary, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var boss_config: Dictionary = target.get("relay_mode_config").get("boss", {}) as Dictionary
	var attacks: Dictionary = boss_config.get("attacks", {}) as Dictionary
	var phase := int(target.get("relay_boss_phase"))
	var phase_names: Array[String] = ["zatsudan", "gameplay", "singing", "drawing", "collab_final"]
	if HardModeSystemScript.is_high_difficulty_target(target) and String(HardModeSystemScript.runtime_for_target(target).get("playMode", "")) == HardModeSystemScript.RELAY_FINAL_BOSS:
		phase_names = ["zatsudan", "gameplay", "collab_final"]
	var phase_name := phase_names[clampi(phase, 0, phase_names.size() - 1)]
	var previous := String(runtime.get("last_attack_id", ""))
	var previous_large := bool(runtime.get("last_attack_was_large", false))
	var movement_state := RelayBossMovementSystem.state_for_target(target)
	var candidates: Array = []
	var total := 0.0
	for attack_id in ATTACK_IDS:
		var payload: Dictionary = _normalized_payload(attack_id, attacks.get(attack_id, {}) as Dictionary)
		var stage := String(payload.get("stage", "common"))
		if stage != "common" and stage != phase_name:
			continue
		if float((runtime.get("reuse_cooldowns", {}) as Dictionary).get(attack_id, 0.0)) > 0.0:
			continue
		if attack_id == previous:
			continue
		if movement_state == RelayBossMovementSystem.STATE_CRUISING and RelayBossMovementSystem.movement_policy_for_attack(attack_id) != "mobile":
			continue
		if previous_large and bool(payload.get("large", false)):
			continue
		if attack_id == "noise_summon" and not can_start_noise_summon_for_target(target, runtime, payload, movement_state):
			continue
		var noise_payload: Dictionary = _noise_payload_for_target(target)
		var protected_ids: Array = noise_payload.get("protectedAttackIds", []) as Array
		if protected_ids.has(attack_id) and float(runtime.get("noise_summon_after_wave_lock", 0.0)) > 0.0:
			continue
		if attack_id == "noise_summon" and float(runtime.get("noise_summon_after_protected_attack_lock", 0.0)) > 0.0:
			continue
		if bool(payload.get("requiresFullArena", false)) and arena.size.x < 600.0:
			continue
		var allowed_phases: Array = payload.get("phases", []) as Array
		if not allowed_phases.is_empty() and not allowed_phases.has(phase):
			continue
		var weight := maxf(0.01, float(payload.get("weight", 1.0)))
		candidates.append({"id": attack_id, "weight": weight})
		total += weight
	if candidates.is_empty():
		runtime["last_attack_was_large"] = false
		# Cooldowns and phase filters may temporarily remove every weighted
		# candidate. Keep the boss active instead of leaving it permanently idle.
		_start_or_queue_attack(target, runtime, "comment_shotgun", arena, rng, true)
		return
	var roll := rng.randf_range(0.0, total)
	for candidate in candidates:
		roll -= float((candidate as Dictionary).get("weight", 0.0))
		if roll <= 0.0:
			_start_or_queue_attack(target, runtime, String((candidate as Dictionary).get("id", "")), arena, rng)
			return
	_start_or_queue_attack(target, runtime, String((candidates.back() as Dictionary).get("id", "")), arena, rng)

static func _start_or_queue_attack(target: Node, runtime: Dictionary, attack_id: String, arena: Rect2, rng: RandomNumberGenerator, forced: bool = false) -> void:
	var policy := RelayBossMovementSystem.movement_policy_for_attack(attack_id)
	if policy == "reposition_then_lock":
		var movement := RelayBossMovementSystem.ensure_for_target(target)
		var current_anchor := String(movement.get("anchor_id", "center"))
		var queued: Dictionary = runtime.get("pending_attack", {}) as Dictionary
		var required_anchor := String(queued.get("requiredAnchor", ""))
		if required_anchor == "":
			required_anchor = RelayBossMovementSystem.required_anchor_for_attack(attack_id, target, rng)
		var safe_required_anchor := RelayBossMovementSystem.safe_anchor_for_target(target, arena, required_anchor)
		if safe_required_anchor == "":
			# Central all-genre rushes wait until the player leaves the unsafe
			# center; other required attacks may use a safe alternate anchor.
			return
		required_anchor = safe_required_anchor
		var boss_pos := _boss_origin(target, arena)
		var required_pos := RelayBossMovementSystem.anchor_position_for_target(target, arena, required_anchor)
		if current_anchor != required_anchor or boss_pos.distance_to(required_pos) > 8.0:
			runtime["pending_attack"] = {"id": attack_id, "forced": forced, "requiredAnchor": required_anchor}
			RelayBossMovementSystem.request_anchor(target, arena, required_anchor)
			return
	_begin_attack(target, runtime, attack_id, arena, rng, forced)

static func _begin_attack(target: Node, runtime: Dictionary, attack_id: String, arena: Rect2, rng: RandomNumberGenerator, forced: bool = false) -> void:
	var boss_config: Dictionary = target.get("relay_mode_config").get("boss", {}) as Dictionary
	var attacks: Dictionary = boss_config.get("attacks", {}) as Dictionary
	var payload := _normalized_payload(attack_id, attacks.get(attack_id, {}) as Dictionary)
	if HardModeSystemScript.is_high_difficulty_target(target) and String(HardModeSystemScript.runtime_for_target(target).get("playMode", "")) == HardModeSystemScript.RELAY_FINAL_BOSS:
		var interval_rate := float(HardModeSystemScript.final_boss_rates(HardModeSystemScript.runtime_for_target(target)).get("actionIntervalRate", 0.85))
		payload["recovery"] = float(payload.get("recovery", 0.6)) * interval_rate
		payload["reuseCooldown"] = float(payload.get("reuseCooldown", 8.0)) * interval_rate
	var serial := int(runtime.get("serial", 0)) + 1
	var active := _empty_attack()
	active["id"] = attack_id
	active["state"] = STATE_TELEGRAPH
	active["timer"] = float(payload.get("telegraph", 0.8))
	active["elapsed"] = 0.0
	active["serial"] = serial
	active["payload"] = payload
	active["movementPolicy"] = String(payload.get("movementPolicy", RelayBossMovementSystem.movement_policy_for_attack(attack_id)))
	active["large"] = bool(payload.get("large", attack_id in LARGE_ATTACK_IDS))
	if attack_id == ALL_GENRE_RUSH_OWNER_ID:
		active["allGenreRushCastSerial"] = serial
		active["allGenreRushStepIndex"] = -1
		active["allGenreRushCompletedMask"] = 0
		runtime["allGenreRushCastSerial"] = serial
		runtime["allGenreRushStepIndex"] = -1
		runtime["allGenreRushCompletedMask"] = 0
		runtime["allGenreRushElapsed"] = 0.0
	runtime["serial"] = serial
	runtime["active_attack"] = active
	runtime["last_attack_id"] = attack_id
	runtime["last_attack_was_large"] = false
	runtime["hazards"] = []
	var attack_origin := _attack_marker_origin(target, attack_id, arena)
	RelayBossMovementSystem.on_attack_started(target, attack_id, attack_origin)
	if attack_id == "noise_summon":
		# Warning geometry is intentionally boss-side only.  The gameplay
		# reservation below remains untouched; this serial is visual metadata,
		# not a position/count reservation and never consumes RNG.
		active["noiseSummonWarningVisualActive"] = true
		active["noiseSummonWarningVisualSeed"] = _noise_summon_warning_visual_seed(serial)
		active["noiseSummonWarningVisualDuration"] = float(payload.get("telegraph", 1.0))
	if attack_id == "kuso_maro_drop":
		# The four actual positions are deliberately not known until the
		# existing activation-time jitter calls. This seed is only for the
		# boss-side warning and never participates in gameplay.
		active["kusoMaroDropWarningVisualSeed"] = _kuso_maro_drop_warning_visual_seed(serial)
		active["kusoMaroDropWarningVisualDuration"] = float(payload.get("telegraph", 1.2))
	if attack_id == "offline_laser":
		_capture_offline_laser_snapshot(target, active, arena)
	if attack_id == "paint_warning":
		_capture_paint_warning_snapshot(target, active, arena)
	if attack_id == "division_noise":
		# The warning tracks both authoritative endpoints until the .45 s lock
		# boundary.  These fields are visual/gameplay attack-local state only;
		# they never participate in RNG, selection, or movement.
		var division_anchors := _division_noise_live_anchor_positions(target)
		active["divisionNoiseAnchorLocked"] = false
		active["divisionNoiseAnchorLockRemaining"] = DIVISION_NOISE_WARNING_LOCK_REMAINING
		active["divisionNoiseWarningPlayerAnchor"] = division_anchors[0]
		active["divisionNoiseWarningPartnerAnchor"] = division_anchors[1]
		active["divisionNoiseAnchorPlayer"] = division_anchors[0]
		active["divisionNoiseAnchorPartner"] = division_anchors[1]
		active["divisionNoiseVisualSeed"] = _division_noise_visual_seed(serial, division_anchors[0], division_anchors[1])
		active["divisionNoiseWarningDuration"] = float(payload.get("telegraph", 0.8))
	if attack_id == "collab_break":
		# The core position is a visual/gameplay-independent snapshot of the
		# authoritative CollabModule marker.  Sidecar positions remain in the
		# existing shared-RNG reservation path and are never exposed here.
		var core_snapshot := _attack_marker_origin(target, attack_id, arena)
		active["collabBreakCoreSnapshotValid"] = true
		active["collabBreakCorePosition"] = core_snapshot
		active["collabBreakCoreRadius"] = COLLAB_BREAK_CORE_RADIUS
		active["collabBreakCoreWarningDuration"] = float(payload.get("telegraph", 1.0))
		active["collabBreakCoreCastSerial"] = serial
		active["collabBreakCoreVisualSeed"] = _collab_break_visual_seed(serial, core_snapshot)
		active["collabBreakCoreUid"] = -1
	if not forced:
		var cooldowns: Dictionary = runtime.get("reuse_cooldowns", {}) as Dictionary
		cooldowns[attack_id] = float(payload.get("reuseCooldown", 8.0))
		runtime["reuse_cooldowns"] = cooldowns

static func _normalized_payload(attack_id: String, source: Dictionary) -> Dictionary:
	var payload := _default_payload(attack_id)
	for key in source.keys():
		payload[key] = source[key]
	if source.has("warning") and not source.has("telegraph"):
		payload["telegraph"] = float(source.get("warning", 0.8))
	if source.has("duration") and not source.has("activeDuration"):
		payload["activeDuration"] = float(source.get("duration", 1.0))
	if source.has("cooldown") and not source.has("reuseCooldown"):
		payload["reuseCooldown"] = float(source.get("cooldown", 8.0))
	return payload

static func _default_payload(attack_id: String) -> Dictionary:
	var result := {"weight": 1.0, "telegraph": 0.8, "activeDuration": 1.0, "recovery": 0.6, "reuseCooldown": 8.0, "large": attack_id in LARGE_ATTACK_IDS, "requiresFullArena": false}
	match attack_id:
		"offline_laser": result["telegraph"] = 1.1; result["activeDuration"] = 0.8; result["recovery"] = 0.8; result["large"] = true
		"noise_summon": result["telegraph"] = 1.0; result["activeDuration"] = 0.1
		"race_lane_charge": result["telegraph"] = 1.2; result["activeDuration"] = 1.8
		"game_over_barrage": result["activeDuration"] = 4.5; result["recovery"] = 1.0; result["large"] = true
		"howling_ring": result["activeDuration"] = 2.25
		"pitch_wave": result["activeDuration"] = 3.0
		"rhythm_explosion": result["telegraph"] = 1.4; result["activeDuration"] = 2.65; result["recovery"] = 1.0; result["large"] = true
		"dirty_paint": result["activeDuration"] = 7.0
		"eraser_sweep": result["telegraph"] = 1.2; result["recovery"] = 0.9; result["large"] = true
		"paint_warning": result["telegraph"] = 1.4; result["activeDuration"] = 2.5; result["recovery"] = 1.0; result["large"] = true
		"division_noise": result["activeDuration"] = 4.0
		"collab_break": result["activeDuration"] = 10.0; result["recovery"] = 1.0; result["large"] = true
		"all_genre_rush": result["telegraph"] = 1.2; result["activeDuration"] = 2.5; result["recovery"] = 2.0; result["large"] = true
	return result

static func _update_telegraph(target: Node, runtime: Dictionary, active: Dictionary, delta: float, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var prepared_this_tick := false
	if String(active.get("id", "")) == "offline_laser":
		# Keep the live tracking behavior, but do not refresh on the tick that
		# crosses into ACTIVE.  The snapshot used by the last rendered warning
		# is therefore the exact active collision geometry.
		_refresh_offline_laser_snapshot_if_warning_renders(target, active, arena, delta)
	if String(active.get("id", "")) == "noise_summon" and (runtime.get("noise_summon_pending_wave", {}) as Dictionary).is_empty():
		var payload: Dictionary = active.get("payload", {}) as Dictionary
		var remaining := float(active.get("timer", 0.0))
		if remaining <= float(payload.get("spawnWarningSeconds", 0.6)):
			prepared_this_tick = _prepare_noise_summon_wave(target, runtime, payload, arena, rng, "main_attack", -1)
			if prepared_this_tick:
				var pending: Dictionary = runtime.get("noise_summon_pending_wave", {}) as Dictionary
				pending["warningTimer"] = remaining
				runtime["noise_summon_pending_wave"] = pending
	if String(active.get("id", "")) == "division_noise":
		_update_division_noise_warning_snapshot(target, active, delta)
	if prepared_this_tick:
		_update_pending_noise_wave(target, runtime, delta, arena, rng)
	active["timer"] = float(active.get("timer", 0.0)) - delta
	active["elapsed"] = float(active.get("elapsed", 0.0)) + delta
	if float(active["timer"]) > 0.0:
		return
	active["state"] = STATE_ACTIVE
	active["timer"] = float((active.get("payload", {}) as Dictionary).get("activeDuration", 1.0))
	active["elapsed"] = 0.0
	_activate_dedicated(target, runtime, active, arena, rng)

static func _update_active(target: Node, runtime: Dictionary, active: Dictionary, delta: float, arena: Rect2, rng: RandomNumberGenerator, feedback: Dictionary) -> void:
	active["timer"] = float(active.get("timer", 0.0)) - delta
	active["elapsed"] = float(active.get("elapsed", 0.0)) + delta
	var id := String(active.get("id", ""))
	if id == "game_over_barrage":
		_handle_game_over_barrage(target, runtime, active, arena, rng)
	elif id == "collab_break":
		_handle_collab_break(target, runtime, active)
	elif id == "all_genre_rush":
		_handle_all_genre_rush(target, runtime, active, delta, arena, rng)
	_update_pending_noise_wave(target, runtime, 0.0, arena, rng)
	_process_hazards(target, runtime, active, delta, arena, feedback)
	if float(active.get("timer", 0.0)) > 0.0:
		return
	if id == "all_genre_rush":
		# End-of-ACTIVE cleanup is cast-owned. Dirty paint intentionally survives
		# into RECOVERY so its slow and expiry timer can finish naturally.
		_clear_all_genre_rush_owned_runtime(target, runtime, int(active.get("allGenreRushCastSerial", active.get("serial", -1))), false)
	active["state"] = STATE_RECOVERY
	active["timer"] = float((active.get("payload", {}) as Dictionary).get("recovery", 0.6))
	active["elapsed"] = 0.0
	runtime["last_attack_was_large"] = bool(active.get("large", false))

static func _update_recovery(target: Node, runtime: Dictionary, active: Dictionary, delta: float) -> void:
	active["timer"] = float(active.get("timer", 0.0)) - delta
	if String(active.get("id", "")) == "all_genre_rush":
		_update_dirty_paint_recovery_runtime(runtime, delta, int(active.get("allGenreRushCastSerial", active.get("serial", -1))))
	if float(active.get("timer", 0.0)) <= 0.0:
		if _protected_attack_ids_for_target(target).has(String(active.get("id", ""))):
			runtime["noise_summon_after_protected_attack_lock"] = float(_noise_payload_for_target(target).get("postProtectedAttackSummonSeconds", 1.0))
		if String(active.get("id", "")) == "all_genre_rush":
			_clear_all_genre_rush_owned_runtime(target, runtime, int(active.get("allGenreRushCastSerial", active.get("serial", -1))), true)
			runtime["gameplay_variant"] = ""
			runtime["allGenreRushCastSerial"] = 0
			runtime["allGenreRushStepIndex"] = -1
			runtime["allGenreRushCompletedMask"] = 0
			runtime["allGenreRushElapsed"] = 0.0
		runtime["active_attack"] = _empty_attack()
		if String(active.get("id", "")) != "all_genre_rush":
			runtime["hazards"] = []
		if String(active.get("id", "")) == "collab_break":
			if target.has_method("_clear_collab_partner_mute_source"):
				target.call("_clear_collab_partner_mute_source", "collab_break")
			elif not target.has_method("_clear_all_collab_partner_mute_sources"):
				target.set("collab_boss_partner_muted", false)
		RelayBossMovementSystem.on_attack_finished(target)

static func _activate_dedicated(target: Node, runtime: Dictionary, active: Dictionary, arena: Rect2, rng: RandomNumberGenerator) -> void:
	match String(active.get("id", "")):
		"comment_shotgun": _handle_comment_shotgun(target, active, arena)
		"offline_laser": _handle_offline_laser(target, runtime, active, arena)
		"noise_summon": _handle_noise_summon(target, active, arena, rng)
		"kuso_maro_drop": _handle_kuso_maro_drop(target, runtime, active, arena, rng)
		"long_comment_line": _handle_long_comment_line(runtime, active, arena)
		"race_lane_charge": _handle_race_lane_charge(runtime, active, arena)
		"game_over_barrage":
			active["nextShot"] = 0.0
			active["gameOverBarrageWaveSerial"] = 0
		"fake_gift_trap": _handle_fake_gift_trap(target, runtime, active, arena, rng)
		"howling_ring": _handle_howling_ring(target, runtime, active, arena)
		"pitch_wave": _handle_pitch_wave(target, runtime, active, arena)
		"rhythm_explosion": _handle_rhythm_explosion(target, runtime, active, arena)
		"dirty_paint": _handle_dirty_paint(target, runtime, active, arena)
		"eraser_sweep": _handle_eraser_sweep(runtime, active, arena)
		"paint_warning": _handle_paint_warning(target, runtime, active, arena)
		"division_noise": _handle_division_noise(target, runtime, active, arena, rng)
		"collab_break": _handle_collab_break_start(target, runtime, active, arena, rng)
		"all_genre_rush": _handle_all_genre_rush_start(target, runtime, active, arena, rng)

static func _append_hazard(runtime: Dictionary, hazard: Dictionary) -> void:
	var hazards: Array = runtime.get("hazards", []) as Array
	hazards.append(hazard)
	runtime["hazards"] = hazards

static func _new_hazard(kind: String, pos: Vector2, duration: float, damage: int) -> Dictionary:
	return {"id": "%s_%d" % [kind, Time.get_ticks_usec()], "kind": kind, "pos": pos, "time": duration, "maxTime": duration, "damage": damage, "hitTimer": 0.0, "active": true}

static func _all_genre_rush_child_metadata(active: Dictionary, step_index: int = -1) -> Dictionary:
	if String(active.get("id", "")) != ALL_GENRE_RUSH_OWNER_ID:
		return {}
	var cast_serial := int(active.get("allGenreRushCastSerial", active.get("serial", 0)))
	var resolved_step := step_index if step_index >= 0 else int(active.get("allGenreRushStepIndex", -1))
	var child_kind := String(ALL_GENRE_RUSH_STEP_IDS[resolved_step]) if resolved_step >= 0 and resolved_step < ALL_GENRE_RUSH_STEP_COUNT else ""
	var identity := "%s:%d:%d:%s" % [ALL_GENRE_RUSH_OWNER_ID, cast_serial, resolved_step, child_kind]
	return {
		"ownerAttackId": ALL_GENRE_RUSH_OWNER_ID,
		"allGenreRushCastSerial": cast_serial,
		"allGenreRushStepIndex": resolved_step,
		"allGenreRushChildKind": child_kind,
		"allGenreRushChildIdentity": identity
	}

static func _apply_all_genre_rush_child_metadata(hazard: Dictionary, active: Dictionary, step_index: int = -1) -> void:
	var metadata := _all_genre_rush_child_metadata(active, step_index)
	for key in metadata.keys():
		hazard[key] = metadata[key]

static func _copy_all_genre_rush_child_metadata(item: Dictionary, source: Dictionary) -> void:
	for key in ["ownerAttackId", "allGenreRushCastSerial", "allGenreRushStepIndex", "allGenreRushChildKind", "allGenreRushChildIdentity"]:
		if source.has(key):
			item[key] = source[key]

static func _all_genre_rush_cast_matches(item: Dictionary, cast_serial: int) -> bool:
	if cast_serial < 0:
		return true
	if not item.has("allGenreRushCastSerial"):
		return false
	return int(item.get("allGenreRushCastSerial", -1)) == cast_serial

static func _is_all_genre_rush_owned_item(item: Dictionary, cast_serial: int, include_dirty: bool = true) -> bool:
	var owner := String(item.get("ownerAttackId", ""))
	if owner == "" and String(item.get("dirtyPaintOwnerAttackId", "")) == ALL_GENRE_RUSH_OWNER_ID:
		owner = ALL_GENRE_RUSH_OWNER_ID
	if owner == "" and String(item.get("howlingRingOwnerAttackId", "")) == ALL_GENRE_RUSH_OWNER_ID:
		owner = ALL_GENRE_RUSH_OWNER_ID
	if owner != ALL_GENRE_RUSH_OWNER_ID or not _all_genre_rush_cast_matches(item, cast_serial):
		return false
	if not include_dirty:
		var child_kind := String(item.get("allGenreRushChildKind", item.get("kind", item.get("attackId", ""))))
		if child_kind == "dirty_paint" or String(item.get("dirtyPaintOwnerAttackId", "")) == ALL_GENRE_RUSH_OWNER_ID:
			return false
	return true

static func _clear_all_genre_rush_owned_runtime(target: Node, runtime: Dictionary, cast_serial: int, include_dirty: bool = true) -> void:
	var kept_hazards: Array = []
	for item in runtime.get("hazards", []) as Array:
		var hazard: Dictionary = item as Dictionary
		if not _is_all_genre_rush_owned_item(hazard, cast_serial, include_dirty):
			kept_hazards.append(hazard)
	runtime["hazards"] = kept_hazards
	for field in ["kuso_maro_drop_visual_effects", "long_comment_line_visual_effects", "howling_ring_visual_effects", "dirty_paint_visual_effects"]:
		var kept_effects: Array = []
		for item in runtime.get(field, []) as Array:
			var effect: Dictionary = item as Dictionary
			if not _is_all_genre_rush_owned_item(effect, cast_serial, include_dirty):
				kept_effects.append(effect)
		runtime[field] = kept_effects
	for field in ["collab_effects", "hit_fx"]:
		var value: Variant = target.get(field)
		if not value is Array:
			continue
		var kept_target_effects: Array = []
		for item in value as Array:
			var effect: Dictionary = item as Dictionary
			if not _is_all_genre_rush_owned_item(effect, cast_serial, include_dirty):
				kept_target_effects.append(effect)
		target.set(field, kept_target_effects)
	var contact_state: Dictionary = runtime.get("dirty_paint_contact_state", {}) as Dictionary
	if include_dirty and _is_all_genre_rush_owned_item(contact_state, cast_serial, true):
		runtime["dirty_paint_contact_state"] = {"inside": false, "stayTimer": 0.0, "center": Vector2.ZERO, "radius": DIRTY_PAINT_RADIUS, "visualSeed": 0.0}

static func _process_hazards(target: Node, runtime: Dictionary, active: Dictionary, delta: float, arena: Rect2, feedback: Dictionary) -> void:
	var player_pos := Vector2(target.get("player_pos"))
	var kept: Array = []
	for item in runtime.get("hazards", []) as Array:
		var hazard: Dictionary = item as Dictionary
		var is_eraser_sweep := String(hazard.get("kind", "")) == "eraser_sweep"
		var is_paint_warning := _is_paint_warning_hazard(hazard)
		var is_division_noise_anchor := _is_division_noise_anchor_hazard(hazard)
		var previous_pos := Vector2(hazard.get("pos", Vector2.ZERO))
		hazard["time"] = float(hazard.get("time", 0.0)) - delta
		hazard["hitTimer"] = maxf(0.0, float(hazard.get("hitTimer", 0.0)) - delta)
		var previous_delay := float(hazard.get("delay", 0.0))
		if hazard.has("delay"):
			hazard["delay"] = maxf(0.0, float(hazard.get("delay", 0.0)) - delta)
			if previous_delay > 0.0 and float(hazard.get("delay", 0.0)) <= 0.0 and _is_howling_ring_hazard(hazard) and not bool(hazard.get("howlingRingActivationFxEmitted", false)):
				hazard["howlingRingActivationFxEmitted"] = true
				_append_howling_ring_visual_effect(runtime, "howling_ring_activation", hazard, Vector2(hazard.get("pos", Vector2.ZERO)), 0.18, 0.0)
			if previous_delay > 0.0 and float(hazard.get("delay", 0.0)) <= 0.0 and bool(hazard.get("rhythmExplosionVisual", false)) and not bool(hazard.get("rhythmExplosionActivationFxEmitted", false)):
				hazard["rhythmExplosionActivationFxEmitted"] = true
				var rhythm_activation_effects: Array = runtime.get("rhythm_explosion_visual_effects", []) as Array
				rhythm_activation_effects.append({
					"kind": "relay_rhythm_explosion_activation",
					"bossAttackId": "rhythm_explosion",
					"attackId": "rhythm_explosion",
					"markerIndex": int(hazard.get("rhythmExplosionMarkerIndex", 0)),
					"pos": Vector2(hazard.get("pos", Vector2.ZERO)),
					"visualSeed": float(hazard.get("rhythmExplosionVisualSeed", 0.0)),
					"life": RHYTHM_EXPLOSION_ACTIVATION_FX_DURATION,
					"maxLife": RHYTHM_EXPLOSION_ACTIVATION_FX_DURATION
				})
				runtime["rhythm_explosion_visual_effects"] = rhythm_activation_effects
		if hazard.has("vel") and float(hazard.get("delay", 0.0)) <= 0.0:
			hazard["pos"] = Vector2(hazard.get("pos", Vector2.ZERO)) + Vector2(hazard.get("vel", Vector2.ZERO)) * delta
		var hit_candidate := _hazard_hits_player(hazard, player_pos)
		if is_eraser_sweep:
			# Preserve the existing move-before-hit order, but make this one
			# moving rect continuous across a hitch.  The end is clamped to the
			# authoritative travel path so a post-expiry overshoot cannot become
			# a false-positive area beyond the sweep's endpoint.
			hazard["eraserSweepPreviousPos"] = previous_pos
			hazard["eraserSweepPreviousRect"] = Rect2(previous_pos, Vector2(hazard.get("size", Vector2(ERASER_SWEEP_WIDTH, 0.0))))
			hit_candidate = _eraser_sweep_hits_player(hazard, previous_pos, arena, player_pos)
		if float(hazard.get("delay", 0.0)) <= 0.0 and int(hazard.get("damage", 0)) > 0 and float(hazard.get("hitTimer", 0.0)) <= 0.0 and hit_candidate:
			if is_paint_warning:
				# Candidate cadence is intentionally separate from confirmed damage:
				# it follows the authoritative hazard hitTimer reset, while the
				# player-facing hit accent is appended only after DamageSystem accepts
				# the event in confirm_paint_warning_hits_for_target().
				_append_paint_warning_visual_effect(runtime, "paint_warning_cadence", hazard, player_pos, PAINT_WARNING_CADENCE_FX_DURATION, 0.37)
			var hazard_damage := int(hazard.get("damage", 0))
			if HardModeSystemScript.is_high_difficulty_target(target):
				hazard_damage = roundi(float(hazard_damage) * float(HardModeSystemScript.final_boss_rates(HardModeSystemScript.runtime_for_target(target)).get("attackRate", 1.10)))
			feedback["damageEvents"].append({"source": String(hazard.get("source", "relay_boss_attack")), "damage": hazard_damage, "attackId": String(active.get("id", "")), "attackType": String(hazard.get("kind", "hazard"))})
			hazard["hitTimer"] = maxf(0.1, float(hazard.get("damageInterval", 999.0)))
			if String(hazard.get("kind", "")) == "offline_laser" and not bool(hazard.get("offlineLaserHitFxEmitted", false)):
				hazard["offlineLaserHitFxEmitted"] = true
				var offline_hit_fx: Array = target.get("hit_fx") as Array
				var hit_from := Vector2(hazard.get("from", Vector2.ZERO))
				var hit_to := Vector2(hazard.get("to", hit_from))
				var hit_dir := (hit_to - hit_from).normalized()
				if hit_dir.length_squared() <= 0.01:
					hit_dir = Vector2.RIGHT
				offline_hit_fx.append({
					"kind": "offline_laser_hit",
					"bossAttackId": "offline_laser",
					"pos": player_pos,
					"dir": hit_dir,
					"visualSeed": float(hazard.get("offlineLaserVisualSeed", 0.0)),
					"offlineLaserSerial": int(hazard.get("offlineLaserSerial", 0)),
					"life": 0.20,
					"maxLife": 0.20
				})
				target.set("hit_fx", offline_hit_fx)
			if bool(hazard.get("kusoMaroDropVisual", false)) and not bool(hazard.get("kusoMaroDropHitFxEmitted", false)):
				hazard["kusoMaroDropHitFxEmitted"] = true
				var drop_effects: Array = runtime.get("kuso_maro_drop_visual_effects", []) as Array
				var drop_effect := {
					"kind": "kuso_maro_drop_hit",
					"bossAttackId": "kuso_maro_drop",
					"pos": player_pos,
					"visualSeed": float(hazard.get("kusoMaroDropVisualSeed", 0.0)) + 1.37,
					"life": 0.20,
					"maxLife": 0.20
				}
				_copy_all_genre_rush_child_metadata(drop_effect, hazard)
				drop_effects.append(drop_effect)
				runtime["kuso_maro_drop_visual_effects"] = drop_effects
			if bool(hazard.get("longCommentLineVisual", false)) and not bool(hazard.get("longCommentLineHitFxEmitted", false)):
				hazard["longCommentLineHitFxEmitted"] = true
				var line_effects: Array = runtime.get("long_comment_line_visual_effects", []) as Array
				var line_effect := {
					"kind": "long_comment_line_hit",
					"bossAttackId": "long_comment_line",
					"activeAttackId": String(active.get("id", "")),
					"pos": player_pos,
					"scrollDir": Vector2.LEFT,
					"lineIndex": int(hazard.get("longCommentLineIndex", 0)),
					"visualSeed": float(hazard.get("longCommentLineVisualSeed", 0.0)),
					"life": 0.20,
					"maxLife": 0.20
				}
				_copy_all_genre_rush_child_metadata(line_effect, hazard)
				line_effects.append(line_effect)
				runtime["long_comment_line_visual_effects"] = line_effects
			if bool(hazard.get("raceLaneChargeVisual", false)) and not bool(hazard.get("raceLaneChargeHitFxEmitted", false)):
				hazard["raceLaneChargeHitFxEmitted"] = true
				var race_effects: Array = runtime.get("race_lane_charge_visual_effects", []) as Array
				race_effects.append({
					"kind": "race_lane_charge_hit",
					"bossAttackId": "race_lane_charge",
					"pos": player_pos,
					"laneIndex": int(hazard.get("raceLaneChargeLaneIndex", 0)),
					"visualSeed": float(hazard.get("raceLaneChargeVisualSeed", 0.0)) + 0.37,
					"life": 0.17,
					"maxLife": 0.17
				})
				runtime["race_lane_charge_visual_effects"] = race_effects
			if _is_howling_ring_hazard(hazard) and not bool(hazard.get("howlingRingHitFxEmitted", false)):
				hazard["howlingRingHitFxEmitted"] = true
				_append_howling_ring_visual_effect(runtime, "howling_ring_hit", hazard, player_pos, 0.20, 1.41)
			if bool(hazard.get("pitchWaveVisual", false)) and not bool(hazard.get("pitchWaveHitFxEmitted", false)):
				hazard["pitchWaveHitFxEmitted"] = true
				var pitch_effects: Array = runtime.get("pitch_wave_visual_effects", []) as Array
				pitch_effects.append({
					"kind": "relay_pitch_wave_hit",
					"bossAttackId": "pitch_wave",
					"pos": player_pos,
					"laneIndex": int(hazard.get("pitchWaveLaneIndex", 0)),
					"visualSeed": float(hazard.get("pitchWaveVisualSeed", 0.0)) + 1.37,
					"life": PITCH_WAVE_HIT_FX_DURATION,
					"maxLife": PITCH_WAVE_HIT_FX_DURATION
				})
				runtime["pitch_wave_visual_effects"] = pitch_effects
			if bool(hazard.get("rhythmExplosionVisual", false)) and not bool(hazard.get("rhythmExplosionHitFxEmitted", false)):
				hazard["rhythmExplosionHitFxEmitted"] = true
				var rhythm_hit_effects: Array = runtime.get("rhythm_explosion_visual_effects", []) as Array
				rhythm_hit_effects.append({
					"kind": "relay_rhythm_explosion_hit",
					"bossAttackId": "rhythm_explosion",
					"attackId": "rhythm_explosion",
					"markerIndex": int(hazard.get("rhythmExplosionMarkerIndex", 0)),
					"pos": player_pos,
					"visualSeed": float(hazard.get("rhythmExplosionVisualSeed", 0.0)) + 1.37,
					"life": RHYTHM_EXPLOSION_HIT_FX_DURATION,
					"maxLife": RHYTHM_EXPLOSION_HIT_FX_DURATION
				})
				runtime["rhythm_explosion_visual_effects"] = rhythm_hit_effects
			if is_eraser_sweep and not bool(hazard.get("eraserSweepHitFxEmitted", false)):
				hazard["eraserSweepHitFxEmitted"] = true
				_append_eraser_sweep_visual_effect(runtime, "eraser_sweep_hit", hazard, player_pos, ERASER_SWEEP_HIT_FX_DURATION, 1.37)
			if is_division_noise_anchor and not bool(hazard.get("divisionNoiseAnchorHitFxEmitted", false)):
				hazard["divisionNoiseAnchorHitFxEmitted"] = true
				var division_hit_effects: Array = runtime.get("division_noise_visual_effects", []) as Array
				division_hit_effects.append({
					"kind": "relay_division_noise_anchor_hit",
					"bossAttackId": "division_noise",
					"attackId": "division_noise",
					"anchorIndex": int(hazard.get("divisionNoiseAnchorIndex", 0)),
					"castSerial": int(hazard.get("divisionNoiseCastSerial", 0)),
					"pos": player_pos,
					"visualSeed": float(hazard.get("divisionNoiseVisualSeed", 0.0)) + 1.37,
					"life": DIVISION_NOISE_ANCHOR_FX_DURATION,
					"maxLife": DIVISION_NOISE_ANCHOR_FX_DURATION
				})
				runtime["division_noise_visual_effects"] = division_hit_effects
		if float(hazard.get("time", 0.0)) > 0.0:
			kept.append(hazard)
		elif is_eraser_sweep and not bool(hazard.get("eraserSweepWakeFxEmitted", false)):
			hazard["eraserSweepWakeFxEmitted"] = true
			var wake_pos := Vector2(hazard.get("pos", Vector2.ZERO)) + Vector2(0.0, float(hazard.get("size", Vector2(ERASER_SWEEP_WIDTH, 0.0)).y) * 0.5)
			_append_eraser_sweep_visual_effect(runtime, "eraser_sweep_wake", hazard, wake_pos, ERASER_SWEEP_WAKE_FX_DURATION, 0.73)
		elif _is_dirty_paint_hazard(hazard) and not bool(hazard.get("dirtyPaintExpiryFxEmitted", false)):
			hazard["dirtyPaintExpiryFxEmitted"] = true
			_append_dirty_paint_visual_effect(runtime, "dirty_paint_expiry", hazard, Vector2(hazard.get("pos", Vector2.ZERO)), DIRTY_PAINT_EXPIRY_FX_DURATION, 0.91)
	runtime["hazards"] = kept

static func _hazard_hits_player(hazard: Dictionary, player_pos: Vector2) -> bool:
	match String(hazard.get("shape", "circle")):
		"circle":
			return player_pos.distance_squared_to(Vector2(hazard.get("pos", Vector2.ZERO))) <= pow(float(hazard.get("radius", 30.0)), 2.0)
		"rect":
			return Rect2(Vector2(hazard.get("pos", Vector2.ZERO)), Vector2(hazard.get("size", Vector2(80.0, 80.0)))).has_point(player_pos)
		"ring":
			return absf(player_pos.distance_to(Vector2(hazard.get("pos", Vector2.ZERO))) - float(hazard.get("radius", 100.0))) <= float(hazard.get("width", 20.0))
		"line":
			return _distance_to_segment(player_pos, Vector2(hazard.get("from", Vector2.ZERO)), Vector2(hazard.get("to", Vector2.ZERO))) <= float(hazard.get("width", 24.0))
	return false

static func _distance_to_segment(point: Vector2, from_pos: Vector2, to_pos: Vector2) -> float:
	var segment := to_pos - from_pos
	var length_sq := segment.length_squared()
	if length_sq <= 0.001:
		return point.distance_to(from_pos)
	var ratio := clampf((point - from_pos).dot(segment) / length_sq, 0.0, 1.0)
	return point.distance_to(from_pos + segment * ratio)

static func _boss_origin(target: Node, arena: Rect2) -> Vector2:
	for item in target.get("enemies") as Array:
		var enemy: Dictionary = item as Dictionary
		if bool(enemy.get("relayBoss", false)) or String(enemy.get("bossId", "")) == "last_offline" or String(enemy.get("kind", "")) == "last_offline":
			return Vector2(enemy.get("pos", arena.get_center()))
	return arena.get_center()

static func _attack_marker_name(attack_id: String) -> String:
	match attack_id:
		"comment_shotgun", "noise_summon":
			return "ChatModule"
		"offline_laser":
			return "CoreCenter"
		"game_over_barrage":
			return "GameModule"
		"howling_ring", "pitch_wave", "rhythm_explosion":
			return "SongModule"
		"dirty_paint", "eraser_sweep", "paint_warning":
			return "DrawModule"
		"collab_break":
			return "CollabModule"
	return "MuzzleCenter"

static func _attack_marker_origin(target: Node, attack_id: String, arena: Rect2) -> Vector2:
	return RelayBossMovementSystem.marker_world_position(target, _attack_marker_name(attack_id), arena)

static func _append_bullet(target: Node, pos: Vector2, vel: Vector2, life: float, damage: int, source: String, attack_id: String, visual_metadata: Dictionary = {}) -> void:
	if HardModeSystemScript.is_high_difficulty_target(target):
		var rates := HardModeSystemScript.final_boss_rates(HardModeSystemScript.runtime_for_target(target))
		vel *= float(rates.get("projectileSpeedRate", rates.get("attackRate", 1.10)))
		damage = roundi(float(damage) * float(rates.get("attackRate", 1.10)))
	var bullets: Array = target.get("enemy_bullets")
	var bullet := {"pos": pos, "vel": vel, "life": life, "damage": damage, "source": source, "sourceKind": attack_id, "attackType": "projectile", "relayBossProjectile": true, "shieldBlockable": true}
	for key in visual_metadata.keys():
		bullet[key] = visual_metadata[key]
	bullets.append(bullet)
	target.set("enemy_bullets", bullets)

static func _comment_shotgun_visual_seed(serial: int, index: int, pos: Vector2, vel: Vector2) -> float:
	var raw := sin(
		float(serial) * 17.173
		+ float(index) * 43.917
		+ pos.x * 0.0137
		+ pos.y * 0.0179
		+ vel.x * 0.0071
		+ vel.y * 0.0093
	) * 43758.5453
	return fposmod(raw, 1.0)

static func _travel_comment_salvo_visual_seed(serial: int, index: int, pos: Vector2, vel: Vector2) -> float:
	var raw := sin(
		float(serial) * 19.731
		+ float(index) * 37.917
		+ pos.x * 0.0113
		+ pos.y * 0.0171
		+ vel.x * 0.0067
		+ vel.y * 0.0089
	) * 43758.5453
	return fposmod(raw, 1.0)

static func _travel_noise_shot_visual_seed(serial: int, index: int, pos: Vector2, vel: Vector2) -> float:
	# This is a visual-only hash.  It must never consume the encounter RNG or
	# depend on the order in which unrelated effects are rendered.
	var raw := sin(
		float(serial) * 23.417
		+ float(index) * 41.873
		+ pos.x * 0.0121
		+ pos.y * 0.0187
		+ vel.x * 0.0063
		+ vel.y * 0.0101
	) * 43758.5453
	return fposmod(raw, 1.0)

static func _race_lane_charge_visual_seed(serial: int, lane_index: int, pos: Vector2) -> float:
	var raw := sin(
		float(serial) * 23.171
		+ float(lane_index) * 47.913
		+ pos.x * 0.0117
		+ pos.y * 0.0193
	) * 43758.5453
	return fposmod(raw, 1.0)

static func _game_over_barrage_visual_seed(attack_serial: int, wave_serial: int, pellet_index: int, pos: Vector2) -> float:
	var raw := sin(
		float(attack_serial) * 17.173
		+ float(wave_serial) * 31.719
		+ float(pellet_index) * 47.913
		+ pos.x * 0.0137
		+ pos.y * 0.0193
	) * 43758.5453
	return fposmod(raw, 1.0)

static func _noise_summon_warning_visual_seed(serial: int) -> float:
	return fposmod(sin(float(serial) * 17.731 + 4.913) * 43758.5453, TAU)

static func _noise_summon_visual_seed(wave_id: int, index: int, enemy_uid: int, pos: Vector2) -> float:
	var raw := sin(
		float(wave_id) * 13.917
		+ float(index) * 31.173
		+ float(enemy_uid) * 47.219
		+ pos.x * 0.0173
		+ pos.y * 0.0231
	) * 43758.5453
	return fposmod(raw, TAU)

static func _travel_noise_summon_visual_seed(travel_attack_serial: int, summon_serial: int, pos: Vector2) -> float:
	# Visual-only hash: travel serials, reserved position, and fixed salt are
	# sufficient to keep all marker/cue/child variants deterministic without
	# touching the shared gameplay RNG.
	var raw := sin(
		float(travel_attack_serial) * 19.417
		+ float(summon_serial) * 37.173
		+ pos.x * 0.0157
		+ pos.y * 0.0229
		+ 61.913
	) * 43758.5453
	return fposmod(raw, 1.0)

static func _append_noise_summon_visual_effect(runtime: Dictionary, effect: Dictionary) -> void:
	var effects: Array = runtime.get("noise_summon_visual_effects", []) as Array
	effects.append(effect)
	runtime["noise_summon_visual_effects"] = effects

static func append_division_noise_child_visual_effect_for_target(target: Node, enemy: Dictionary, effect_kind: String, duration: float) -> void:
	if target == null or String(enemy.get("kind", "")) != "noise_ghost_comment" or not bool(enemy.get("divisionNoiseChild", false)):
		return
	var runtime := ensure_for_target(target)
	var effects: Array = runtime.get("division_noise_visual_effects", []) as Array
	var pos := Vector2(enemy.get("pos", Vector2.ZERO))
	var seed := float(enemy.get("divisionNoiseVisualSeed", 0.0))
	effects.append({
		"kind": effect_kind,
		"bossAttackId": "division_noise",
		"attackId": "division_noise",
		"source": "relay_boss_division_noise",
		"childUid": int(enemy.get("uid", -1)),
		"childIndex": int(enemy.get("divisionNoiseChildIndex", 0)),
		"castSerial": int(enemy.get("divisionNoiseCastSerial", 0)),
		"pos": pos,
		"visualSeed": seed,
		"life": maxf(0.01, duration),
		"maxLife": maxf(0.01, duration)
	})
	runtime["division_noise_visual_effects"] = effects
	target.set("relay_boss_runtime", runtime)

static func emit_travel_attack_for_target(target: Node, attack_id: String, arena: Rect2, travel_context: Dictionary = {}) -> void:
	if not bool(target.get("relay_boss_active")):
		return
	var origin := RelayBossMovementSystem.marker_world_position(target, "ChatModule", arena)
	var player_pos := Vector2(target.get("player_pos"))
	var direction := (player_pos - origin).normalized()
	if direction.length_squared() <= 0.01:
		direction = Vector2.DOWN
	var travel_direction := Vector2(travel_context.get("travelDirection", Vector2.ZERO))
	if travel_direction.length_squared() <= 0.01:
		travel_direction = direction
	var rng: RandomNumberGenerator = target.get("rng") as RandomNumberGenerator
	match attack_id:
		"travel_comment_salvo":
			var runtime := ensure_for_target(target)
			var salvo_serial := int(runtime.get("travelCommentSalvoSerial", 0)) + 1
			runtime["travelCommentSalvoSerial"] = salvo_serial
			target.set("relay_boss_runtime", runtime)
			var launch_direction := -travel_direction.normalized()
			if launch_direction.length_squared() <= 0.01:
				launch_direction = direction
			for i in range(TRAVEL_COMMENT_SALVO_COUNT):
				var spread := (float(i) - 1.0) * 0.18
				var projectile_velocity := (-travel_direction).rotated(spread) * TRAVEL_COMMENT_SALVO_SPEED
				_append_bullet(target, origin, projectile_velocity, TRAVEL_COMMENT_SALVO_LIFE, TRAVEL_COMMENT_SALVO_DAMAGE, TRAVEL_COMMENT_SALVO_SOURCE, TRAVEL_COMMENT_SALVO_KIND, {
					"visualKind": TRAVEL_COMMENT_SALVO_KIND,
					"hitRadius": TRAVEL_COMMENT_SALVO_HIT_RADIUS,
					"travelCommentSalvoSerial": salvo_serial,
					"travelCommentSalvoIndex": i,
					"travelCommentSalvoCount": TRAVEL_COMMENT_SALVO_COUNT,
					"travelCommentSalvoVisualAge": 0.0,
					"travelCommentSalvoLaunchVisualTimer": TRAVEL_COMMENT_SALVO_LAUNCH_FX_DURATION,
					"travelCommentSalvoLaunchVisualDuration": TRAVEL_COMMENT_SALVO_LAUNCH_FX_DURATION,
					"travelCommentSalvoDrawSize": 40.0,
					"travelCommentSalvoTrailLength": 18.0,
					"travelCommentSalvoForegroundDuration": TRAVEL_COMMENT_SALVO_FOREGROUND_DURATION
				})
				var bullets: Array = target.get("enemy_bullets") as Array
				if not bullets.is_empty():
					var bullet: Dictionary = bullets[bullets.size() - 1] as Dictionary
					var actual_velocity := Vector2(bullet.get("vel", projectile_velocity))
					var visual_seed := _travel_comment_salvo_visual_seed(salvo_serial, i, origin, actual_velocity)
					bullet["travelCommentSalvoVisualSeed"] = visual_seed
					bullets[bullets.size() - 1] = bullet
					target.set("enemy_bullets", bullets)
			var hit_fx: Array = target.get("hit_fx") as Array
			hit_fx.append({
				"kind": "travel_comment_launch",
				"bossAttackId": TRAVEL_COMMENT_SALVO_KIND,
				"source": TRAVEL_COMMENT_SALVO_SOURCE,
				"sourceKind": TRAVEL_COMMENT_SALVO_KIND,
				"pos": origin,
				"dir": launch_direction,
				"pelletCount": TRAVEL_COMMENT_SALVO_COUNT,
				"travelCommentSalvoSerial": salvo_serial,
				"visualSeed": _travel_comment_salvo_visual_seed(salvo_serial, TRAVEL_COMMENT_SALVO_COUNT, origin, launch_direction),
				"life": TRAVEL_COMMENT_SALVO_LAUNCH_FX_DURATION,
				"maxLife": TRAVEL_COMMENT_SALVO_LAUNCH_FX_DURATION
			})
			target.set("hit_fx", hit_fx)
		"travel_noise_shot":
			var noise_runtime := ensure_for_target(target)
			var noise_serial := int(noise_runtime.get("travelNoiseShotSerial", 0)) + 1
			noise_runtime["travelNoiseShotSerial"] = noise_serial
			target.set("relay_boss_runtime", noise_runtime)
			var launched_directions: Array = []
			for i in range(TRAVEL_NOISE_SHOT_COUNT):
				var jitter := rng.randf_range(-0.35, 0.35) if rng != null else 0.0
				var projectile_velocity := direction.rotated(jitter) * TRAVEL_NOISE_SHOT_SPEED
				_append_bullet(target, origin, projectile_velocity, TRAVEL_NOISE_SHOT_LIFE, TRAVEL_NOISE_SHOT_DAMAGE, TRAVEL_NOISE_SHOT_SOURCE, TRAVEL_NOISE_SHOT_KIND, {
					"visualKind": TRAVEL_NOISE_SHOT_KIND,
					"attackId": TRAVEL_NOISE_SHOT_KIND,
					"hitRadius": TRAVEL_NOISE_SHOT_HIT_RADIUS,
					"travelNoiseShotSerial": noise_serial,
					"travelNoiseShotIndex": i,
					"travelNoiseShotCount": TRAVEL_NOISE_SHOT_COUNT,
					"travelNoiseShotVisualAge": 0.0,
					"travelNoiseShotLaunchVisualTimer": TRAVEL_NOISE_SHOT_LAUNCH_FX_DURATION,
					"travelNoiseShotLaunchVisualDuration": TRAVEL_NOISE_SHOT_LAUNCH_FX_DURATION,
					"travelNoiseShotDrawSize": 40.0,
					"travelNoiseShotTrailLength": 16.0,
					"travelNoiseShotForegroundDuration": TRAVEL_NOISE_SHOT_FOREGROUND_DURATION
				})
				var bullets: Array = target.get("enemy_bullets") as Array
				if not bullets.is_empty():
					var bullet: Dictionary = bullets[bullets.size() - 1] as Dictionary
					var actual_velocity := Vector2(bullet.get("vel", projectile_velocity))
					bullet["travelNoiseShotVisualSeed"] = _travel_noise_shot_visual_seed(noise_serial, i, origin, actual_velocity)
					bullets[bullets.size() - 1] = bullet
					target.set("enemy_bullets", bullets)
					if actual_velocity.length_squared() > 0.01:
						launched_directions.append(actual_velocity.normalized())
					else:
						launched_directions.append(direction)
			var hit_fx: Array = target.get("hit_fx") as Array
			hit_fx.append({
				"kind": "travel_noise_launch",
				"bossAttackId": TRAVEL_NOISE_SHOT_KIND,
				"attackId": TRAVEL_NOISE_SHOT_KIND,
				"source": TRAVEL_NOISE_SHOT_SOURCE,
				"sourceKind": TRAVEL_NOISE_SHOT_KIND,
				"visualKind": TRAVEL_NOISE_SHOT_KIND,
				"pos": origin,
				"directions": launched_directions.duplicate(),
				"projectileCount": TRAVEL_NOISE_SHOT_COUNT,
				"travelNoiseShotSerial": noise_serial,
				"visualSeed": _travel_noise_shot_visual_seed(noise_serial, TRAVEL_NOISE_SHOT_COUNT, origin, direction),
				"life": TRAVEL_NOISE_SHOT_LAUNCH_FX_DURATION,
				"maxLife": TRAVEL_NOISE_SHOT_LAUNCH_FX_DURATION
			})
			target.set("hit_fx", hit_fx)
		"travel_noise_summon":
			var payload := _noise_payload_for_target(target)
			var runtime := ensure_for_target(target)
			var remaining_reposition := RelayBossMovementSystem.remaining_reposition_time_for_target(target, arena)
			if remaining_reposition < TRAVEL_NOISE_SUMMON_WARNING_SECONDS:
				# The feasibility check is deliberately before any candidate angle or
				# distance draw. The travel scheduler still consumes its normal next
				# interval after this callback, while summon position/cooldown RNG is
				# untouched and the existing shot fallback owns its two jitter draws.
				runtime["travelNoiseSummonLastResolution"] = "fallback_noise_shot"
				runtime["travelNoiseSummonLastResolutionReason"] = "remaining_reposition_lt_warning"
				emit_travel_attack_for_target(target, "travel_noise_shot", arena, travel_context)
				return
			var travel_context_with_kind := travel_context.duplicate(true)
			travel_context_with_kind["travelAttackId"] = TRAVEL_NOISE_SUMMON_KIND
			if not _prepare_noise_summon_wave(target, runtime, payload, arena, rng, TRAVEL_NOISE_SUMMON_SOURCE, 1, TRAVEL_NOISE_SUMMON_KIND, -1, travel_context_with_kind):
				runtime["travelNoiseSummonLastResolution"] = "fallback_noise_shot"
				runtime["travelNoiseSummonLastResolutionReason"] = "reservation_failed"
				emit_travel_attack_for_target(target, "travel_noise_shot", arena, travel_context)
				return
			runtime["travelNoiseSummonLastResolution"] = "pending_warning"
			runtime["travelNoiseSummonLastResolutionReason"] = "reservation_committed"
			var pending: Dictionary = runtime.get("noise_summon_pending_wave", {}) as Dictionary
			# This cue is intentionally emitted on the selection frame, at the
			# authoritative ChatModule marker. It is visual-only and hash-seeded.
			_append_noise_summon_visual_effect(runtime, {
				"kind": "relay_noise_summon_travel_cue",
				"bossAttackId": TRAVEL_NOISE_SUMMON_KIND,
				"attackId": TRAVEL_NOISE_SUMMON_KIND,
				"ownerAttackId": TRAVEL_NOISE_SUMMON_KIND,
				"source": TRAVEL_NOISE_SUMMON_SOURCE,
				"sourceKind": TRAVEL_NOISE_SUMMON_KIND,
				"travelAttackSerial": int(pending.get("travelAttackSerial", travel_context.get("travelAttackSerial", 0))),
				"travelNoiseSummonSerial": int(pending.get("travelNoiseSummonSerial", 0)),
				"pos": RelayBossMovementSystem.marker_world_position(target, "ChatModule", arena),
				"visualSeed": float(pending.get("travelNoiseVisualSeed", 0.0)),
				"strength": 1.0,
				"life": TRAVEL_NOISE_SUMMON_CUE_DURATION,
				"maxLife": TRAVEL_NOISE_SUMMON_CUE_DURATION
			})
			target.set("relay_boss_runtime", runtime)

static func _handle_comment_shotgun(target: Node, active: Dictionary, arena: Rect2) -> void:
	var payload: Dictionary = active.get("payload", {}) as Dictionary
	var origin := RelayBossMovementSystem.marker_world_position(target, "ChatModule", arena)
	var direction := (Vector2(target.get("player_pos")) - origin).normalized()
	var count := mini(12, maxi(1, int(payload.get("count", 5))))
	var cast_serial := int(active.get("serial", 0))
	for i in range(count):
		var pellet_velocity := direction.rotated((float(i) - float(count - 1) * 0.5) * 0.12) * 240.0
		_append_bullet(target, origin, pellet_velocity, 4.0, int(payload.get("damage", 7)), "relay_boss_comment_shotgun", String(active.get("id", "")))
		var bullets: Array = target.get("enemy_bullets") as Array
		if bullets.is_empty():
			continue
		var bullet_index := bullets.size() - 1
		var bullet: Dictionary = bullets[bullet_index] as Dictionary
		var actual_velocity := Vector2(bullet.get("vel", pellet_velocity))
		var visual_seed := _comment_shotgun_visual_seed(cast_serial, i, origin, actual_velocity)
		bullet["visualKind"] = "comment_shotgun"
		bullet["commentShotgunCastSerial"] = cast_serial
		bullet["commentShotgunIndex"] = i
		bullet["commentShotgunCount"] = count
		bullet["commentShotgunVisualSeed"] = visual_seed
		bullet["commentShotgunLaunchVisualTimer"] = 0.12
		bullet["commentShotgunLaunchVisualDuration"] = 0.12
		bullet["commentShotgunDrawSize"] = 40.0
		bullet["commentShotgunTrailLength"] = 21.0
		bullets[bullet_index] = bullet
		target.set("enemy_bullets", bullets)
	var hit_fx: Array = target.get("hit_fx") as Array
	hit_fx.append({
		"kind": "comment_shotgun_launch",
		"bossAttackId": "comment_shotgun",
		"pos": origin,
		"dir": direction,
		"pelletCount": count,
		"visualSeed": _comment_shotgun_visual_seed(cast_serial, count, origin, direction),
		"life": 0.16,
		"maxLife": 0.16
	})
	target.set("hit_fx", hit_fx)

static func _handle_offline_laser(target: Node, runtime: Dictionary, active: Dictionary, arena: Rect2) -> void:
	var payload: Dictionary = active.get("payload", {}) as Dictionary
	var snapshot_valid := bool(active.get("offlineLaserSnapshotValid", false))
	if not snapshot_valid:
		# Defensive recovery for old/injected runtime data only.  The normal
		# path captures the snapshot at attack start and never re-aims here.
		_capture_offline_laser_snapshot(target, active, arena)
		snapshot_valid = bool(active.get("offlineLaserSnapshotValid", false))
	var origin := Vector2(active.get("offlineLaserOrigin", Vector2.ZERO))
	var direction := Vector2(active.get("offlineLaserDir", Vector2.DOWN))
	var endpoint := Vector2(active.get("offlineLaserEndpoint", Vector2.ZERO))
	if not snapshot_valid:
		origin = RelayBossMovementSystem.marker_world_position(target, "CoreCenter", arena)
		direction = (Vector2(target.get("player_pos")) - origin).normalized()
		if direction.length_squared() < 0.01:
			direction = Vector2.DOWN
		endpoint = origin + direction * OFFLINE_LASER_LENGTH
	if direction.length_squared() <= 0.01:
		direction = Vector2.DOWN
	else:
		direction = direction.normalized()
	if endpoint.distance_squared_to(origin) <= 0.01:
		endpoint = origin + direction * OFFLINE_LASER_LENGTH
	var hazard := _new_hazard("offline_laser", origin, float(payload.get("activeDuration", 0.8)), int(payload.get("damage", 16)))
	hazard["shape"] = "line"; hazard["from"] = origin; hazard["to"] = endpoint; hazard["width"] = OFFLINE_LASER_HIT_WIDTH; hazard["source"] = "relay_boss_offline_laser"
	hazard["attackId"] = "offline_laser"
	hazard["offlineLaserSerial"] = int(active.get("serial", 0))
	hazard["offlineLaserVisualSeed"] = float(active.get("offlineLaserVisualSeed", 0.0))
	_append_hazard(runtime, hazard)
	var hit_fx: Array = target.get("hit_fx") as Array
	hit_fx.append({
		"kind": "offline_laser_launch",
		"bossAttackId": "offline_laser",
		"pos": origin,
		"dir": direction,
		"endpoint": endpoint,
		"visualSeed": float(active.get("offlineLaserVisualSeed", 0.0)),
		"offlineLaserSerial": int(active.get("serial", 0)),
		"life": 0.18,
		"maxLife": 0.18
	})
	target.set("hit_fx", hit_fx)

static func _capture_offline_laser_snapshot(target: Node, active: Dictionary, arena: Rect2) -> void:
	var origin := RelayBossMovementSystem.marker_world_position(target, "CoreCenter", arena)
	var aim_point := Vector2(target.get("player_pos"))
	var direction := aim_point - origin
	if direction.length_squared() <= 0.01:
		direction = Vector2.DOWN
	else:
		direction = direction.normalized()
	var endpoint := origin + direction * OFFLINE_LASER_LENGTH
	active["offlineLaserSnapshotValid"] = true
	active["offlineLaserOrigin"] = origin
	active["offlineLaserDir"] = direction
	active["offlineLaserEndpoint"] = endpoint
	active["offlineLaserAimPoint"] = aim_point
	active["offlineLaserVisualSeed"] = _offline_laser_visual_seed(int(active.get("serial", 0)), origin, direction)

static func _refresh_offline_laser_snapshot_if_warning_renders(target: Node, active: Dictionary, arena: Rect2, delta: float) -> void:
	var remaining := float(active.get("timer", 0.0))
	# Treat the timer-crossing tick as a commit even when float rounding leaves
	# a few ulps above zero.  No new aim sample is allowed on that tick.
	if remaining <= 0.0 or remaining - maxf(0.0, delta) <= 0.00001:
		return
	_capture_offline_laser_snapshot(target, active, arena)

static func _offline_laser_visual_seed(serial: int, origin: Vector2, direction: Vector2) -> float:
	var raw := sin(
		float(serial) * 19.371
		+ origin.x * 0.0173
		+ origin.y * 0.0119
		+ direction.x * 31.17
		+ direction.y * 47.83
	) * 43758.5453
	return fposmod(raw, 1.0)

static func paint_warning_radius_for_arena(arena: Rect2) -> float:
	return minf(arena.size.x, arena.size.y) * PAINT_WARNING_RADIUS_RATE

static func paint_warning_center_for_target(target: Node, arena: Rect2) -> Vector2:
	return RelayBossMovementSystem.marker_world_position(target, "DrawModule", arena)

static func _paint_warning_visual_seed(serial: int, center: Vector2, salt: float = 0.0) -> float:
	var raw := sin(
		float(serial) * 23.173
		+ center.x * 0.0137
		+ center.y * 0.0193
		+ salt * 41.719
	) * 43758.5453
	return fposmod(raw, 1.0)

static func _capture_paint_warning_snapshot(target: Node, active: Dictionary, arena: Rect2) -> void:
	var center := paint_warning_center_for_target(target, arena)
	var radius := paint_warning_radius_for_arena(arena)
	var serial := int(active.get("serial", 0))
	active["paintWarningSnapshotValid"] = true
	active["paintWarningCenterSnapshot"] = center
	active["paintWarningRadius"] = radius
	active["paintWarningSerial"] = serial
	active["paintWarningVisualSeed"] = _paint_warning_visual_seed(serial, center)
	active["paintWarningWarningDuration"] = float((active.get("payload", {}) as Dictionary).get("telegraph", PAINT_WARNING_DEFAULT_WARNING_DURATION))

static func _division_noise_live_anchor_positions(target: Node) -> Array:
	var player_anchor := Vector2(target.get("player_pos"))
	var partner_anchor := player_anchor
	var partner_value: Variant = target.get("collab_partner_pos")
	if partner_value is Vector2 and (partner_value as Vector2) != Vector2.ZERO:
		partner_anchor = partner_value as Vector2
	return [player_anchor, partner_anchor]

static func _division_noise_warning_anchor_positions(active: Dictionary, target: Node) -> Array:
	if active.has("divisionNoiseWarningPlayerAnchor") and active.has("divisionNoiseWarningPartnerAnchor"):
		return [Vector2(active.get("divisionNoiseWarningPlayerAnchor")), Vector2(active.get("divisionNoiseWarningPartnerAnchor"))]
	return _division_noise_live_anchor_positions(target)

static func _update_division_noise_warning_snapshot(target: Node, active: Dictionary, delta: float) -> void:
	if bool(active.get("divisionNoiseAnchorLocked", false)):
		return
	var live_anchors := _division_noise_live_anchor_positions(target)
	active["divisionNoiseWarningPlayerAnchor"] = live_anchors[0]
	active["divisionNoiseWarningPartnerAnchor"] = live_anchors[1]
	var remaining := float(active.get("timer", 0.0))
	var next_remaining := remaining - maxf(0.0, delta)
	# The current update owns the .45 s boundary.  Locking here also handles a
	# hitch that crosses both .45 and zero, so ACTIVE still receives this tick's
	# authoritative positions without an extra aim sample.
	if remaining <= DIVISION_NOISE_WARNING_LOCK_REMAINING or next_remaining <= DIVISION_NOISE_WARNING_LOCK_REMAINING:
		active["divisionNoiseAnchorLocked"] = true
		active["divisionNoiseAnchorLockRemaining"] = DIVISION_NOISE_WARNING_LOCK_REMAINING
		active["divisionNoiseAnchorPlayer"] = live_anchors[0]
		active["divisionNoiseAnchorPartner"] = live_anchors[1]

static func _division_noise_visual_seed(serial: int, player_anchor: Vector2, partner_anchor: Vector2, salt: float = 0.0) -> float:
	var raw := sin(
		float(serial) * 17.173
		+ player_anchor.x * 0.0137
		+ player_anchor.y * 0.0193
		+ partner_anchor.x * 0.0231
		+ partner_anchor.y * 0.0317
		+ salt * 41.719
	) * 43758.5453
	return fposmod(raw, 1.0)

static func can_start_noise_summon_for_target(target: Node, runtime: Dictionary, payload: Dictionary, movement_state: String = "") -> bool:
	return _can_prepare_noise_wave(target, runtime, payload, movement_state, false)

static func _noise_payload_for_target(target: Node) -> Dictionary:
	var config: Dictionary = target.get("relay_mode_config") as Dictionary
	var boss_config: Dictionary = config.get("boss", {}) as Dictionary
	var attacks: Dictionary = boss_config.get("attacks", {}) as Dictionary
	return _normalized_payload("noise_summon", attacks.get("noise_summon", {}) as Dictionary)

static func _protected_attack_ids_for_target(target: Node) -> Array:
	return _noise_payload_for_target(target).get("protectedAttackIds", []) as Array

static func _noise_phase_settings(payload: Dictionary, phase: int) -> Dictionary:
	var settings: Array = payload.get("phaseSettings", []) as Array
	for item in settings:
		var entry: Dictionary = item as Dictionary
		if int(entry.get("phaseIndex", -1)) == phase:
			return entry
	return {"phaseIndex": phase, "spawnCount": int(payload.get("count", 2)), "activeCap": int(payload.get("maxActive", 4))}

static func _active_noise_summon_count(target: Node) -> int:
	var count := 0
	for item in target.get("enemies") as Array:
		var enemy: Dictionary = item as Dictionary
		if not bool(enemy.get("relayBossNoiseSummon", false)):
			continue
		if bool(enemy.get("defeatPending", false)) or bool(enemy.get("defeatResolved", false)):
			continue
		if float(enemy.get("relayBossSummonLifetime", enemy.get("lifeTimer", 1.0))) <= 0.0:
			continue
		count += 1
	return count

static func _can_prepare_noise_wave(target: Node, runtime: Dictionary, payload: Dictionary, movement_state: String, allow_collab_break: bool) -> bool:
	if float(runtime.get("noise_summon_cooldown", 0.0)) > 0.0:
		return false
	if not (runtime.get("noise_summon_pending_wave", {}) as Dictionary).is_empty():
		return false
	if bool(target.get("relay_boss_defeat_pending")) or bool(target.get("relay_boss_score_awarded")):
		return false
	if movement_state == RelayBossMovementSystem.STATE_REPOSITION_WARNING or movement_state == RelayBossMovementSystem.STATE_REPOSITION or movement_state == RelayBossMovementSystem.STATE_PHASE_TRANSITION or movement_state == RelayBossMovementSystem.STATE_STUNNED:
		return false
	if String(runtime.get("gameplay_variant", "")) == "all_genre_rush":
		return false
	if target.has_method("_collab_combo_sequence_active") and bool(target.call("_collab_combo_sequence_active")):
		return false
	var active_attack: Dictionary = runtime.get("active_attack", {}) as Dictionary
	if not allow_collab_break and String(active_attack.get("id", "")) == "collab_break":
		return false
	var phase := clampi(int(target.get("relay_boss_phase")), 0, 4)
	var phase_settings := _noise_phase_settings(payload, phase)
	return _active_noise_summon_count(target) < int(phase_settings.get("activeCap", payload.get("maxActive", 4)))

static func _prepare_noise_summon_wave(target: Node, runtime: Dictionary, payload: Dictionary, arena: Rect2, rng: RandomNumberGenerator, source: String, requested_override: int, owner_attack_id: String = "", owner_cast_serial: int = -1, travel_context: Dictionary = {}) -> bool:
	if not (runtime.get("noise_summon_pending_wave", {}) as Dictionary).is_empty():
		return false
	if source == "travel_support" and float(runtime.get("noise_summon_cooldown", 0.0)) > 0.0:
		return false
	if not _can_prepare_noise_wave(target, runtime, payload, RelayBossMovementSystem.state_for_target(target), source == "collab_break_sidecar") and source != "travel_support":
		return false
	var phase := clampi(int(target.get("relay_boss_phase")), 0, 4)
	var phase_settings := _noise_phase_settings(payload, phase)
	var requested := int(phase_settings.get("spawnCount", payload.get("count", 2)))
	if HardModeSystemScript.is_high_difficulty_target(target):
		var summon_rate := float(HardModeSystemScript.final_boss_rates(HardModeSystemScript.runtime_for_target(target)).get("summonCountRate", 1.40))
		if requested_override < 0 or source == "collab_break_sidecar":
			var count_base := requested_override if requested_override >= 0 else requested
			requested = HardModeSystemScript.apply_spawn_count_rate(count_base, summon_rate, rng)
	if requested_override >= 0:
		if source != "collab_break_sidecar":
			requested = requested_override
	requested = maxi(0, requested)
	var active_cap := int(phase_settings.get("activeCap", payload.get("maxActive", 4)))
	var available := maxi(0, active_cap - _active_noise_summon_count(target))
	var placement_requested := mini(requested, available)
	var commit_requested := placement_requested
	if source == "collab_break_sidecar" and not HardModeSystemScript.is_high_difficulty_target(target):
		# The legacy normal sidecar placement consumes the full phase placement
		# loop (including all angle/distance rejects) before the formal four-child
		# sidecar commit is truncated.  This preserves the shared RNG call列.
		placement_requested = mini(int(phase_settings.get("spawnCount", requested)), available)
		commit_requested = mini(maxi(0, requested_override if requested_override >= 0 else floori(float(placement_requested) * 0.75)), available)
	if placement_requested <= 0 or commit_requested <= 0:
		return false
	var positions: Array = []
	var existing_positions: Array[Vector2] = []
	for item in target.get("enemies") as Array:
		var enemy: Dictionary = item as Dictionary
		if bool(enemy.get("relayBossNoiseSummon", false)) and not bool(enemy.get("defeatPending", false)) and not bool(enemy.get("defeatResolved", false)):
			existing_positions.append(Vector2(enemy.get("pos", Vector2.ZERO)))
	var boss_pos := _boss_origin(target, arena)
	var player_pos := Vector2(target.get("player_pos"))
	var walls: Array = EnemySystemScript.spawn_walls_for_target(target)
	var attempts := maxi(1, int(payload.get("candidateAttemptsPerEnemy", 48)))
	for _i in range(placement_requested):
		var found := false
		var chosen := Vector2.ZERO
		for _attempt in range(attempts):
			var angle := rng.randf_range(0.0, TAU) if rng != null else 0.0
			var distance := rng.randf_range(float(payload.get("bossDistanceMin", 180.0)), float(payload.get("bossDistanceMax", 300.0))) if rng != null else float(payload.get("bossDistanceMin", 180.0))
			var candidate := boss_pos + Vector2.from_angle(angle) * distance
			var margin := float(payload.get("arenaMargin", 70.0))
			var safe_arena := arena.grow(-margin)
			var enemy_radius := 22.0
			if safe_arena.size.x <= enemy_radius * 2.0 or safe_arena.size.y <= enemy_radius * 2.0:
				break
			if not safe_arena.grow(-enemy_radius).has_point(candidate):
				continue
			if candidate.distance_to(player_pos) < float(payload.get("playerDistanceMin", 180.0)):
				continue
			if candidate.distance_to(boss_pos) < float(payload.get("bossBodyPadding", 28.0)) + 110.0:
				continue
			if EnemySystemScript.spawn_position_blocked_by_walls(candidate, enemy_radius, walls):
				continue
			var spaced := true
			for existing in existing_positions:
				if candidate.distance_to(existing) < float(payload.get("enemySpacingMin", 50.0)):
					spaced = false
					break
			if not spaced:
				continue
			for existing in positions:
				if candidate.distance_to(Vector2(existing)) < float(payload.get("enemySpacingMin", 50.0)):
					spaced = false
					break
			if not spaced:
				continue
			chosen = candidate
			found = true
			break
		if not found:
			break
		positions.append(chosen)
	if source == "collab_break_sidecar" and positions.size() > commit_requested:
		positions = positions.slice(0, commit_requested)
	if positions.is_empty():
		return false
	var wave_serial := int(runtime.get("noise_summon_wave_serial", 0)) + 1
	runtime["noise_summon_wave_serial"] = wave_serial
	var pending := {
		"waveId": wave_serial,
		"source": source,
		"phaseIndex": phase,
		"positions": positions,
		"warningTimer": float(payload.get("spawnWarningSeconds", 0.6)),
		"warningDuration": float(payload.get("spawnWarningSeconds", 0.6)),
		"ownerAttackId": owner_attack_id,
		"ownerCastSerial": owner_cast_serial,
		"spawned": false
	}
	if source == TRAVEL_NOISE_SUMMON_SOURCE:
		var travel_attack_serial := int(travel_context.get("travelAttackSerial", 0))
		var travel_summon_serial := int(runtime.get("travelNoiseSummonSerial", 0)) + 1
		runtime["travelNoiseSummonSerial"] = travel_summon_serial
		var reserved_position := Vector2(positions[0])
		var visual_seed := _travel_noise_summon_visual_seed(travel_attack_serial, travel_summon_serial, reserved_position)
		var min_cooldown := float(payload.get("cooldownMinSeconds", 11.0))
		var max_cooldown := maxf(min_cooldown, float(payload.get("cooldownMaxSeconds", 14.0)))
		# The successful travel contract draws this cooldown immediately after
		# position reservation, before the scheduler's next interval draw.
		var prepared_cooldown := rng.randf_range(min_cooldown, max_cooldown) if rng != null else min_cooldown
		pending["sourceKind"] = TRAVEL_NOISE_SUMMON_KIND
		pending["attackId"] = TRAVEL_NOISE_SUMMON_KIND
		pending["ownerAttackId"] = TRAVEL_NOISE_SUMMON_KIND
		pending["travelAttackSerial"] = travel_attack_serial
		pending["travelNoiseSummonSerial"] = travel_summon_serial
		pending["travelNoiseVisualSeed"] = visual_seed
		pending["reservedPosition"] = reserved_position
		pending["preparedCooldown"] = prepared_cooldown
		pending["preparedCooldownReady"] = true
		pending["travelContext"] = travel_context.duplicate(true)
		pending["warningJustStarted"] = true
	runtime["noise_summon_pending_wave"] = pending
	return true

static func _noise_summon_position_is_safe_at_commit(target: Node, payload: Dictionary, arena: Rect2, candidate: Vector2) -> bool:
	# Reuse only the placement constraints already used by the reservation loop.
	# This is a deterministic re-check for the reserved point; it never draws a
	# replacement candidate and never adds partner/opaque/path rejection rules.
	var margin := float(payload.get("arenaMargin", 70.0))
	var enemy_radius := 22.0
	var safe_arena := arena.grow(-margin)
	if safe_arena.size.x <= enemy_radius * 2.0 or safe_arena.size.y <= enemy_radius * 2.0:
		return false
	if not safe_arena.grow(-enemy_radius).has_point(candidate):
		return false
	var player_pos := Vector2(target.get("player_pos"))
	if candidate.distance_to(player_pos) < float(payload.get("playerDistanceMin", 180.0)):
		return false
	var boss_pos := _boss_origin(target, arena)
	if candidate.distance_to(boss_pos) < float(payload.get("bossBodyPadding", 28.0)) + 110.0:
		return false
	var walls: Array = EnemySystemScript.spawn_walls_for_target(target)
	if EnemySystemScript.spawn_position_blocked_by_walls(candidate, enemy_radius, walls):
		return false
	var spacing := float(payload.get("enemySpacingMin", 50.0))
	for item in target.get("enemies") as Array:
		var enemy: Dictionary = item as Dictionary
		if not bool(enemy.get("relayBossNoiseSummon", false)):
			continue
		if bool(enemy.get("defeatPending", false)) or bool(enemy.get("defeatResolved", false)):
			continue
		if candidate.distance_to(Vector2(enemy.get("pos", Vector2.ZERO))) < spacing:
			return false
	return true

static func _update_pending_noise_wave(target: Node, runtime: Dictionary, delta: float, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var pending: Dictionary = runtime.get("noise_summon_pending_wave", {}) as Dictionary
	if pending.is_empty() or bool(pending.get("spawned", false)):
		return
	if String(pending.get("source", "")) == TRAVEL_NOISE_SUMMON_SOURCE and bool(pending.get("warningJustStarted", false)):
		# Movement emits the travel event before the same frame's attack update.
		# Keep the full world-fixed 0.60 s warning instead of charging one frame
		# immediately on the selection frame.
		pending["warningJustStarted"] = false
		runtime["noise_summon_pending_wave"] = pending
		return
	pending["warningTimer"] = maxf(0.0, float(pending.get("warningTimer", 0.0)) - delta)
	runtime["noise_summon_pending_wave"] = pending
	if float(pending.get("warningTimer", 0.0)) > 0.0:
		return
	pending["spawned"] = true
	runtime["noise_summon_pending_wave"] = pending
	var spawned := _spawn_noise_wave(target, runtime, pending, arena, rng)
	if not spawned and String(pending.get("source", "")) == TRAVEL_NOISE_SUMMON_SOURCE:
		# Commit-time cap/safety failure is a travel support failure, not a
		# position reroll. The fallback consumes only the existing noise-shot
		# jitter draws from this point onward.
		runtime["travelNoiseSummonLastResolution"] = "fallback_noise_shot"
		runtime["travelNoiseSummonLastResolutionReason"] = "commit_zero"
		emit_travel_attack_for_target(target, "travel_noise_shot", arena, pending.get("travelContext", {}) as Dictionary)

static func _spawn_noise_wave(target: Node, runtime: Dictionary, pending: Dictionary, arena: Rect2, rng: RandomNumberGenerator) -> bool:
	var payload := _noise_payload_for_target(target)
	var phase := clampi(int(pending.get("phaseIndex", target.get("relay_boss_phase"))), 0, 4)
	var phase_settings := _noise_phase_settings(payload, phase)
	var available := maxi(0, int(phase_settings.get("activeCap", payload.get("maxActive", 4))) - _active_noise_summon_count(target))
	var positions: Array = pending.get("positions", []) as Array
	var source := String(pending.get("source", "main_attack"))
	var travel_source := source == TRAVEL_NOISE_SUMMON_SOURCE
	var commit_safe := true
	if travel_source and not positions.is_empty():
		commit_safe = _noise_summon_position_is_safe_at_commit(target, payload, arena, Vector2(pending.get("reservedPosition", positions[0])))
	var actual_count := 0 if not commit_safe else mini(available, positions.size())
	if actual_count <= 0:
		runtime["noise_summon_pending_wave"] = {}
		return false
	var is_collab_break_sidecar := source == "collab_break_sidecar"
	var sync_config: Dictionary = payload.get("syncStar", {}) as Dictionary
	var can_carrier := source != "travel_support" and bool(sync_config.get("enabled", true)) and _active_noise_carrier_count(target) < int(sync_config.get("maxCarrierCount", 1)) and int(_reserved_sync_star_count(target)) < _required_sync_star_count(target) and float(runtime.get("sync_star_drop_cooldown", 0.0)) <= 0.0
	var carrier_index := actual_count - 1 if can_carrier else -1
	var enemies: Array = target.get("enemies") as Array
	var spawned_count := 0
	for i in range(actual_count):
		var uid := int(target.get("next_enemy_uid"))
		var summon := EnemySystemScript.build_enemy(String(payload.get("enemyKind", "noise_ghost_comment")), Vector2(positions[i]), uid, 999.0)
		_configure_noise_summon(summon, payload, source, int(pending.get("waveId", 0)), float(payload.get("enemyLifetimeSeconds", payload.get("lifetime", 14.0))))
		summon["relayNoiseOwnerAttackId"] = String(pending.get("ownerAttackId", ""))
		summon["relayNoiseOwnerCastSerial"] = int(pending.get("ownerCastSerial", -1))
		summon["collabBreakSidecar"] = is_collab_break_sidecar
		summon["collabBreakCastSerial"] = int(pending.get("ownerCastSerial", -1))
		var actual_kind := String(summon.get("kind", ""))
		if actual_kind == "noise_ghost_comment":
			# Only the committed child gets visual provenance.  The position is
			# read from the built enemy itself; no predicted/hash position is used.
			var actual_pos := Vector2(summon.get("pos", Vector2.ZERO))
			var visual_seed := _noise_summon_visual_seed(int(pending.get("waveId", 0)), i, uid, actual_pos)
			if travel_source:
				visual_seed = float(pending.get("travelNoiseVisualSeed", visual_seed))
			summon["relayNoiseSummonVisual"] = true
			summon["relayNoiseVisualSeed"] = visual_seed
			summon["relayNoiseWaveId"] = int(pending.get("waveId", 0))
			summon["relayNoiseSource"] = source
			summon["relayNoiseSpawnOrigin"] = actual_pos
			summon["relayNoisePopInTimer"] = 0.20
			summon["relayNoisePopInDuration"] = 0.20
			summon["relayNoiseContactFxTimer"] = 0.0
			if travel_source:
				summon["sourceKind"] = TRAVEL_NOISE_SUMMON_KIND
				summon["attackId"] = TRAVEL_NOISE_SUMMON_KIND
				summon["ownerAttackId"] = TRAVEL_NOISE_SUMMON_KIND
				summon["travelAttackSerial"] = int(pending.get("travelAttackSerial", 0))
				summon["travelNoiseSummonSerial"] = int(pending.get("travelNoiseSummonSerial", 0))
				summon["travelNoiseVisualSeed"] = float(pending.get("travelNoiseVisualSeed", visual_seed))
				summon["reservedPosition"] = Vector2(pending.get("reservedPosition", actual_pos))
				summon["travelNoiseSummonChild"] = true
				summon["travelNoiseSummonExpiryFxEmitted"] = false
		if HardModeSystemScript.is_high_difficulty_target(target):
			var rewardable_hard_summon := String(runtime.get("playMode", "")) == HardModeSystemScript.RELAY_FINAL_BOSS and not travel_source
			if rewardable_hard_summon:
				# Final-boss summons are defeatable reward carriers in HARD. The
				# travel/演出 summons below remain the existing no-reward hazards.
				summon["noRewards"] = false
				summon["hardFinalBossSummonRewardable"] = true
				summon["scoreDisabled"] = true
				var reward_config := HardModeSystemScript.normalized_summon_rewards(runtime)
				summon["rewardConfig"] = reward_config
				summon["scoreEnabled"] = bool(reward_config.get("scoreEnabled", false))
				summon["expEnabled"] = bool(reward_config.get("expEnabled", false))
				summon["starDropEnabled"] = bool(reward_config.get("starDropEnabled", true))
				summon["healDropEnabled"] = bool(reward_config.get("healDropEnabled", true))
				summon["healDropRate"] = float(reward_config.get("healDropRate", 0.10))
				summon["occupancyManaged"] = true
				summon["spawnSource"] = "boss_summon"
				summon["spawnPriority"] = HardModeSystemScript.spawn_priority_for_source("boss_summon")
			HardModeSystemScript.apply_enemy_runtime_stats(summon, HardModeSystemScript.runtime_for_target(target), "finalBossSummon")
		if i == carrier_index:
			summon["syncStarCarrier"] = true
			summon["syncStarCarrierWaveId"] = int(pending.get("waveId", 0))
			summon["syncStarCarrierRevealTimer"] = 0.45
			runtime["sync_star_carrier_uid"] = uid
		enemies.append(summon)
		target.set("next_enemy_uid", uid + 1)
		spawned_count += 1
		if actual_kind == "noise_ghost_comment":
			var spawned_pos := Vector2(summon.get("pos", Vector2.ZERO))
			var visual_seed := float(summon.get("relayNoiseVisualSeed", 0.0))
			if is_collab_break_sidecar:
				_append_collab_break_visual_effect(runtime, {
					"kind": "collab_break_sidecar_spawn",
					"bossAttackId": "collab_break",
					"source": source,
					"ownerAttackId": String(pending.get("ownerAttackId", "")),
					"castSerial": int(pending.get("ownerCastSerial", -1)),
					"waveId": int(pending.get("waveId", 0)),
					"spawnIndex": i,
					"pos": spawned_pos,
					"visualSeed": visual_seed,
					"strength": 1.0,
					"life": 0.22,
					"maxLife": 0.22
				})
			else:
				var strength := TRAVEL_NOISE_SUMMON_SPAWN_FX_STRENGTH if travel_source else 1.0
				var spawn_effect := {
					"kind": "relay_noise_summon_spawn",
					"bossAttackId": "noise_summon",
					"spawnSource": source,
					"waveId": int(pending.get("waveId", 0)),
					"spawnIndex": i,
					"pos": spawned_pos,
					"visualSeed": visual_seed,
					"strength": strength,
					"life": TRAVEL_NOISE_SUMMON_SPAWN_FX_DURATION if travel_source else 0.22,
					"maxLife": TRAVEL_NOISE_SUMMON_SPAWN_FX_DURATION if travel_source else 0.22
				}
				if travel_source:
					spawn_effect["sourceKind"] = TRAVEL_NOISE_SUMMON_KIND
					spawn_effect["attackId"] = TRAVEL_NOISE_SUMMON_KIND
					spawn_effect["ownerAttackId"] = TRAVEL_NOISE_SUMMON_KIND
					spawn_effect["travelAttackSerial"] = int(pending.get("travelAttackSerial", 0))
					spawn_effect["travelNoiseSummonSerial"] = int(pending.get("travelNoiseSummonSerial", 0))
					spawn_effect["travelNoiseVisualSeed"] = float(pending.get("travelNoiseVisualSeed", visual_seed))
				_append_noise_summon_visual_effect(runtime, spawn_effect)
	target.set("enemies", enemies)
	if spawned_count > 0:
		if source == "main_attack":
			var boss_marker := RelayBossMovementSystem.marker_world_position(target, "ChatModule", arena)
			_append_noise_summon_visual_effect(runtime, {
				"kind": "relay_noise_summon_boss_cue",
				"bossAttackId": "noise_summon",
				"spawnSource": source,
				"waveId": int(pending.get("waveId", 0)),
				"pos": boss_marker,
				"visualSeed": _noise_summon_warning_visual_seed(int(pending.get("waveId", 0))),
				"strength": 1.0,
				"life": 0.24,
				"maxLife": 0.24
			})
		var min_cooldown := float(payload.get("cooldownMinSeconds", 11.0))
		var max_cooldown := maxf(min_cooldown, float(payload.get("cooldownMaxSeconds", 14.0)))
		if travel_source:
			# The cooldown draw already happened after reservation. Spawn commit
			# only applies the saved value; it never consumes gameplay RNG.
			runtime["noise_summon_cooldown"] = clampf(float(pending.get("preparedCooldown", min_cooldown)), min_cooldown, max_cooldown)
		else:
			runtime["noise_summon_cooldown"] = rng.randf_range(min_cooldown, max_cooldown) if rng != null else min_cooldown
		runtime["noise_summon_after_wave_lock"] = float(payload.get("postSummonProtectedAttackSeconds", 2.0))
	runtime["noise_summon_pending_wave"] = {}
	return spawned_count > 0

static func _configure_noise_summon(summon: Dictionary, payload: Dictionary, source: String, wave_id: int, lifetime: float) -> void:
	summon["relayBossSummon"] = true
	summon["relayBossNoiseSummon"] = true
	summon["relayBossSummonWaveId"] = wave_id
	summon["relayBossSummonSource"] = source
	summon["relayBossSummonLifetime"] = lifetime
	summon["spawnGraceTimer"] = float(payload.get("spawnGraceSeconds", 0.4))
	summon["contactDamage"] = int(payload.get("contactDamage", 7))
	summon["noRewards"] = true
	summon["score"] = 0
	summon["exp"] = 0
	summon["expDrop"] = 0
	summon["giftHypeReward"] = 0
	summon["itemDrop"] = false
	summon["healDrop"] = false
	summon["lifeTimer"] = lifetime
	summon["lastHitOwner"] = ""
	summon["defeatOwner"] = ""
	summon["removeReason"] = ""
	summon["syncStarDropped"] = false

static func _active_noise_carrier_count(target: Node) -> int:
	var count := 0
	for item in target.get("enemies") as Array:
		var enemy: Dictionary = item as Dictionary
		if bool(enemy.get("relayBossNoiseSummon", false)) and bool(enemy.get("syncStarCarrier", false)) and not bool(enemy.get("defeatPending", false)) and not bool(enemy.get("defeatResolved", false)):
			count += 1
	return count

static func _required_sync_star_count(target: Node) -> int:
	return int(target.call("_collab_required_sync_stars")) if target.has_method("_collab_required_sync_stars") else 3

static func _reserved_sync_star_count(target: Node) -> int:
	return int(target.call("_relay_boss_reserved_sync_stars")) if target.has_method("_relay_boss_reserved_sync_stars") else int(target.get("collab_sync_stars"))

static func _handle_noise_summon(target: Node, active: Dictionary, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var runtime := ensure_for_target(target)
	var pending: Dictionary = runtime.get("noise_summon_pending_wave", {}) as Dictionary
	if pending.is_empty():
		_prepare_noise_summon_wave(target, runtime, active.get("payload", {}) as Dictionary, arena, rng, "main_attack", -1)
		pending = runtime.get("noise_summon_pending_wave", {}) as Dictionary
	if not pending.is_empty() and float(pending.get("warningTimer", 0.0)) <= 0.0:
		_update_pending_noise_wave(target, runtime, 0.0, arena, rng)

static func _add_circle(runtime: Dictionary, kind: String, pos: Vector2, duration: float, damage: int, radius: float, source: String) -> void:
	var hazard := _new_hazard(kind, pos, duration, damage)
	hazard["shape"] = "circle"; hazard["radius"] = radius; hazard["source"] = source
	_append_hazard(runtime, hazard)

static func _clamp_point_to_arena(pos: Vector2, arena: Rect2, margin: float) -> Vector2:
	return Vector2(
		clampf(pos.x, arena.position.x + margin, arena.end.x - margin),
		clampf(pos.y, arena.position.y + margin, arena.end.y - margin)
	)

static func _handle_kuso_maro_drop(target: Node, runtime: Dictionary, active: Dictionary, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var center := Vector2(target.get("player_pos"))
	var batch_serial := int(runtime.get("kuso_maro_drop_visual_batch_serial", 0)) + 1
	runtime["kuso_maro_drop_visual_batch_serial"] = batch_serial
	for i in range(4):
		var pos := center + Vector2.from_angle(float(i) * TAU / 4.0 + rng.randf_range(-0.2, 0.2)) * 170.0
		var actual_pos := _clamp_point_to_arena(pos, arena, 50.0)
		_add_circle(runtime, "kuso_maro_drop", actual_pos, float((active.get("payload", {}) as Dictionary).get("activeDuration", 0.65)), 11, 52, "relay_boss_kuso_maro_drop")
		var hazards: Array = runtime.get("hazards", []) as Array
		if hazards.is_empty():
			continue
		var hazard_index := hazards.size() - 1
		var hazard: Dictionary = hazards[hazard_index] as Dictionary
		var visual_seed := _kuso_maro_drop_visual_seed(batch_serial, i, actual_pos)
		hazard["attackId"] = "kuso_maro_drop"
		hazard["bossAttackId"] = "kuso_maro_drop"
		hazard["kusoMaroDropVisual"] = true
		hazard["kusoMaroDropBatchSerial"] = batch_serial
		hazard["kusoMaroDropSlotIndex"] = i
		hazard["kusoMaroDropVisualSeed"] = visual_seed
		hazard["kusoMaroDropImpactDuration"] = 0.16
		_apply_all_genre_rush_child_metadata(hazard, active, 0)
		hazards[hazard_index] = hazard
		runtime["hazards"] = hazards
		var visual_effects: Array = runtime.get("kuso_maro_drop_visual_effects", []) as Array
		var effect := {
			"kind": "kuso_maro_drop_impact",
			"bossAttackId": "kuso_maro_drop",
			"pos": actual_pos,
			"visualSeed": visual_seed,
			"batchSerial": batch_serial,
			"slotIndex": i,
			"life": 0.18,
			"maxLife": 0.18
		}
		_copy_all_genre_rush_child_metadata(effect, hazard)
		visual_effects.append(effect)
		runtime["kuso_maro_drop_visual_effects"] = visual_effects

static func _kuso_maro_drop_warning_visual_seed(serial: int) -> float:
	return fposmod(sin(float(serial) * 12.9898 + 17.0) * 43758.5453, 1.0)

static func _kuso_maro_drop_visual_seed(batch_serial: int, slot_index: int, pos: Vector2) -> float:
	var value := float(batch_serial) * 97.13 + float(slot_index) * 31.71 + pos.x * 0.071 + pos.y * 0.113
	return fposmod(sin(value) * 43758.5453, 1.0)

static func _long_comment_line_visual_seed(serial: int, slot_index: int, from_pos: Vector2, to_pos: Vector2) -> float:
	var value := float(serial) * 97.13 + float(slot_index) * 31.71 + from_pos.x * 0.071 + from_pos.y * 0.113 + to_pos.x * 0.017
	return fposmod(sin(value) * 43758.5453, 1.0)

static func _handle_long_comment_line(runtime: Dictionary, active: Dictionary, arena: Rect2) -> void:
	var serial := int(active.get("serial", 0))
	for i in range(3):
		var y := arena.position.y + arena.size.y * (0.24 + float(i) * 0.26)
		var hazard := _new_hazard("long_comment_line", arena.get_center(), float((active.get("payload", {}) as Dictionary).get("activeDuration", 0.6)), 11)
		var from_pos := Vector2(arena.position.x, y)
		var to_pos := Vector2(arena.end.x, y)
		hazard["shape"] = "line"; hazard["from"] = from_pos; hazard["to"] = to_pos; hazard["width"] = 18.0; hazard["source"] = "relay_boss_long_comment_line"
		hazard["attackId"] = "long_comment_line"
		hazard["bossAttackId"] = "long_comment_line"
		hazard["longCommentLineVisual"] = true
		hazard["longCommentLineIndex"] = i
		hazard["longCommentLineSerial"] = serial
		hazard["longCommentLineVisualSeed"] = _long_comment_line_visual_seed(serial, i, from_pos, to_pos)
		_apply_all_genre_rush_child_metadata(hazard, active, 1)
		_append_hazard(runtime, hazard)

static func _handle_race_lane_charge(runtime: Dictionary, active: Dictionary, arena: Rect2) -> void:
	for i in range(2):
		var y := arena.position.y + arena.size.y * (0.34 + float(i) * 0.32)
		var hazard := _new_hazard("race_lane_charge", Vector2(arena.position.x, y - 43.0), float((active.get("payload", {}) as Dictionary).get("activeDuration", 1.8)), 16)
		hazard["shape"] = "rect"; hazard["size"] = Vector2(arena.size.x, 86.0); hazard["source"] = "relay_boss_race_lane_charge"
		hazard["attackId"] = "race_lane_charge"
		hazard["bossAttackId"] = "race_lane_charge"
		hazard["raceLaneChargeVisual"] = true
		hazard["raceLaneChargeLaneIndex"] = i
		hazard["raceLaneChargeSerial"] = int(active.get("serial", 0))
		hazard["raceLaneChargeVisualSeed"] = _race_lane_charge_visual_seed(int(active.get("serial", 0)), i, Vector2(hazard.get("pos", Vector2.ZERO)))
		_append_hazard(runtime, hazard)

static func _handle_game_over_barrage(target: Node, runtime: Dictionary, active: Dictionary, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var payload: Dictionary = active.get("payload", {}) as Dictionary
	var next_shot := float(active.get("nextShot", 0.0))
	var interval := maxf(0.08, float(payload.get("fireInterval", 0.35)))
	if float(active.get("elapsed", 0.0)) < next_shot:
		return
	var origin := Vector2(runtime.get("locked_origin", RelayBossMovementSystem.marker_world_position(target, "GameModule", arena)))
	var direction := (Vector2(target.get("player_pos")) - origin).normalized()
	var wave_serial := int(active.get("gameOverBarrageWaveSerial", 0))
	var attack_serial := int(active.get("serial", 0))
	var shot_directions: Array = []
	for i in range(mini(12, int(payload.get("count", 6)))):
		# Keep this random call in the original pellet loop and in the original
		# pellet order. Everything after the call is visual metadata only.
		var shot_angle := (float(i) - 2.5) * 0.18 + rng.randf_range(-0.03, 0.03)
		var shot_direction := direction.rotated(shot_angle)
		shot_directions.append(shot_direction)
		var visual_metadata := {
			"visualKind": "game_over_barrage",
			"gameOverBarrageAttackSerial": attack_serial,
			"gameOverBarrageWaveSerial": wave_serial,
			"gameOverBarragePelletIndex": i,
			"gameOverBarrageVisualSeed": _game_over_barrage_visual_seed(attack_serial, wave_serial, i, origin),
			"gameOverBarrageInitialLife": 3.5,
			"gameOverBarrageAge": 0.0
		}
		_append_bullet(target, origin, shot_direction * 190.0, 3.5, int(payload.get("damage", 7)), "relay_boss_game_over_barrage", String(active.get("id", "")), visual_metadata)
	var hit_fx: Array = target.get("hit_fx") as Array
	hit_fx.append({
		"kind": "game_over_barrage_launch",
		"bossAttackId": "game_over_barrage",
		"source": "relay_boss_game_over_barrage",
		"pos": origin,
		"directions": shot_directions,
		"waveSerial": wave_serial,
		"attackSerial": attack_serial,
		"visualSeed": _game_over_barrage_visual_seed(attack_serial, wave_serial, -1, origin),
		"life": 0.15,
		"maxLife": 0.15
	})
	target.set("hit_fx", hit_fx)
	active["gameOverBarrageWaveSerial"] = wave_serial + 1
	active["nextShot"] = next_shot + interval

static func _handle_fake_gift_trap(target: Node, runtime: Dictionary, active: Dictionary, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var center := Vector2(target.get("player_pos"))
	var payload: Dictionary = active.get("payload", {}) as Dictionary
	var count := maxi(0, int(payload.get("count", 5)))
	var lifetime := maxf(0.01, float(payload.get("lifetime", FAKE_GIFT_TRAP_DEFAULT_LIFETIME)))
	var warning_duration := maxf(0.01, float(payload.get("attackWarning", FAKE_GIFT_TRAP_DEFAULT_WARNING)))
	var damage := int(payload.get("damage", 11))
	var attack_serial := int(active.get("serial", 0))
	var placed_positions: Array = []
	var traps: Array = runtime.get("fake_gift_traps", []) as Array
	for i in range(count):
		# This is the original gameplay draw: one jitter per slot, in slot order.
		# Everything after the call is deterministic placement/visual metadata.
		var slot_angle := float(i) * TAU / float(count) if count > 0 else 0.0
		var jitter := rng.randf_range(-0.18, 0.18)
		var raw_pos := center + Vector2.from_angle(slot_angle + jitter) * 170.0
		var actual_pos := _fake_gift_trap_position_for_slot(target, runtime, raw_pos, slot_angle + jitter, arena, placed_positions)
		if is_inf(actual_pos.x) or is_inf(actual_pos.y):
			# Preserve the remaining jitter calls even if an abnormal arena cannot
			# provide a safe slot. No unsafe replacement or re-roll is attempted.
			continue
		var uid := int(runtime.get("fake_gift_trap_uid_counter", 0)) + 1
		runtime["fake_gift_trap_uid_counter"] = uid
		var visual_seed := _fake_gift_trap_visual_seed(attack_serial, i, actual_pos)
		traps.append({
			"uid": uid,
			"id": "fake_gift_trap_%d" % uid,
			"kind": "fake_gift_trap",
			"attackId": "fake_gift_trap",
			"bossAttackId": "fake_gift_trap",
			"source": FAKE_GIFT_TRAP_SOURCE,
			"spawnSource": FAKE_GIFT_TRAP_SOURCE,
			"pos": actual_pos,
			"slotIndex": i,
			"attackSerial": attack_serial,
			"state": "WAITING",
			"life": lifetime,
			"maxLife": lifetime,
			"triggerRadius": FAKE_GIFT_TRAP_TRIGGER_RADIUS,
			"warningTimer": 0.0,
			"warningMaxTime": warning_duration,
			"damage": damage,
			"visualSeed": visual_seed,
			"consumed": false,
			"spawnedAt": 0.0,
			"materializeTimer": FAKE_GIFT_TRAP_MATERIALIZE_DURATION,
			"materializeDuration": FAKE_GIFT_TRAP_MATERIALIZE_DURATION
		})
		placed_positions.append(actual_pos)
	runtime["fake_gift_traps"] = traps

static func _howling_payload_for_target(target: Node) -> Dictionary:
	var config: Dictionary = target.get("relay_mode_config") as Dictionary
	var boss_config: Dictionary = config.get("boss", {}) as Dictionary
	var attacks: Dictionary = boss_config.get("attacks", {}) as Dictionary
	return _normalized_payload("howling_ring", attacks.get("howling_ring", {}) as Dictionary)

static func _howling_ring_visual_seed(serial: int, ring_index: int, radius: float, center: Vector2) -> float:
	var raw := sin(
		float(serial) * 19.371
		+ float(ring_index) * 47.913
		+ radius * 0.071
		+ center.x * 0.0137
		+ center.y * 0.0193
	) * 43758.5453
	return fposmod(raw, 1.0)

static func _pitch_wave_visual_seed(serial: int, lane_index: int, pos: Vector2) -> float:
	var raw := sin(
		float(serial) * 67.173
		+ float(lane_index) * 31.719
		+ pos.x * 0.0137
		+ pos.y * 0.0193
	) * 43758.5453
	return fposmod(raw, 1.0)

static func _rhythm_explosion_visual_seed(serial: int, marker_index: int, pos: Vector2) -> float:
	var raw := sin(
		float(serial) * 83.173
		+ float(marker_index) * 37.719
		+ pos.x * 0.0137
		+ pos.y * 0.0193
	) * 43758.5453
	return fposmod(raw, 1.0)

static func rhythm_explosion_marker_position_for_target(target: Node, arena: Rect2, marker_index: int, marker_count: int = RHYTHM_EXPLOSION_DEFAULT_COUNT) -> Vector2:
	var center := RelayBossMovementSystem.marker_world_position(target, "SongModule", arena)
	var safe_count := maxi(1, marker_count)
	var angle := float(marker_index) * TAU / float(safe_count)
	var raw_pos := center + Vector2.from_angle(angle) * RHYTHM_EXPLOSION_PLACEMENT_DISTANCE
	return _clamp_point_to_arena(raw_pos, arena, RHYTHM_EXPLOSION_PLACEMENT_MARGIN)

static func _append_howling_ring_visual_effect(runtime: Dictionary, kind: String, hazard: Dictionary, pos: Vector2, life: float, seed_offset: float) -> void:
	var effects: Array = runtime.get("howling_ring_visual_effects", []) as Array
	var seed := float(hazard.get("howlingRingVisualSeed", 0.0)) + seed_offset
	var effect := {
		"kind": kind,
		"bossAttackId": "howling_ring",
		"ownerAttackId": String(hazard.get("howlingRingOwnerAttackId", "howling_ring")),
		"ringIndex": int(hazard.get("howlingRingIndex", 0)),
		"radius": float(hazard.get("radius", 120.0)),
		"pos": pos,
		"visualSeed": seed,
		"life": life,
		"maxLife": life
	}
	_copy_all_genre_rush_child_metadata(effect, hazard)
	effects.append(effect)
	runtime["howling_ring_visual_effects"] = effects

static func _handle_howling_ring(target: Node, runtime: Dictionary, active: Dictionary, arena: Rect2) -> void:
	var center := RelayBossMovementSystem.marker_world_position(target, "SongModule", arena)
	var howling_payload := _howling_payload_for_target(target)
	var active_payload: Dictionary = active.get("payload", {}) as Dictionary
	var ring_count := maxi(1, int(howling_payload.get("count", HOWLING_RING_DEFAULT_COUNT)))
	var ring_interval := maxf(0.0, float(howling_payload.get("interval", HOWLING_RING_DEFAULT_INTERVAL)))
	var ring_damage := int(howling_payload.get("damage", HOWLING_RING_DEFAULT_DAMAGE))
	var duration := maxf(0.01, float(active_payload.get("activeDuration", HOWLING_RING_DEFAULT_ACTIVE_DURATION)))
	var serial := int(active.get("serial", 0))
	for i in range(ring_count):
		var radius := 120.0 + float(i) * 88.0
		var delay := float(i) * ring_interval
		var hazard := _new_hazard("howling_ring", center, duration, ring_damage)
		hazard["shape"] = "ring"; hazard["radius"] = radius; hazard["width"] = HOWLING_RING_BAND_HALF_WIDTH; hazard["delay"] = delay; hazard["source"] = "relay_boss_howling_ring"
		hazard["attackId"] = "howling_ring"
		hazard["bossAttackId"] = "howling_ring"
		hazard["howlingRingVisual"] = true
		hazard["howlingRingIndex"] = i
		hazard["howlingRingCount"] = ring_count
		hazard["howlingRingSerial"] = serial
		hazard["howlingRingOwnerAttackId"] = String(active.get("id", "howling_ring"))
		hazard["howlingRingInitialDelay"] = delay
		hazard["howlingRingVisualSeed"] = _howling_ring_visual_seed(serial, i, radius, center)
		hazard["howlingRingActivationFxEmitted"] = delay <= 0.0
		hazard["howlingRingHitFxEmitted"] = false
		_apply_all_genre_rush_child_metadata(hazard, active, 2)
		_append_hazard(runtime, hazard)
		if delay <= 0.0:
			_append_howling_ring_visual_effect(runtime, "howling_ring_activation", hazard, center, 0.18, 0.0)

static func _handle_pitch_wave(target: Node, runtime: Dictionary, active: Dictionary, arena: Rect2) -> void:
	var payload: Dictionary = active.get("payload", {}) as Dictionary
	var count := maxi(1, int(payload.get("count", PITCH_WAVE_DEFAULT_COUNT)))
	var damage := int(payload.get("damage", PITCH_WAVE_DEFAULT_DAMAGE))
	var active_duration := float(payload.get("activeDuration", 3.0))
	var serial := int(active.get("serial", 0))
	var entry_positions: Array = []
	for i in range(count):
		# This is the original fixed relay geometry: two horizontal packets at
		# 35%/65% arena height, born 80px left of the arena.
		var y := arena.position.y + arena.size.y * (0.35 + float(i) * 0.30)
		var spawn_pos := Vector2(arena.position.x - 80.0, y)
		var hazard := _new_hazard("pitch_wave", spawn_pos, active_duration, damage)
		hazard["shape"] = "circle"; hazard["radius"] = PITCH_WAVE_RADIUS; hazard["vel"] = Vector2(PITCH_WAVE_SPEED, 0.0); hazard["source"] = "relay_boss_pitch_wave"
		hazard["attackId"] = "pitch_wave"
		hazard["bossAttackId"] = "pitch_wave"
		hazard["pitchWaveVisual"] = true
		hazard["pitchWaveLaneIndex"] = i
		hazard["pitchWaveSerial"] = serial
		hazard["pitchWaveVisualSeed"] = _pitch_wave_visual_seed(serial, i, spawn_pos)
		hazard["pitchWaveHitFxEmitted"] = false
		_append_hazard(runtime, hazard)
		entry_positions.append(Vector2(arena.position.x, y))
	var visual_effects: Array = runtime.get("pitch_wave_visual_effects", []) as Array
	visual_effects.append({
		"kind": "relay_pitch_wave_cast",
		"bossAttackId": "pitch_wave",
		"pos": RelayBossMovementSystem.marker_world_position(target, "SongModule", arena),
		"entryPositions": entry_positions,
		"serial": serial,
		"visualSeed": _pitch_wave_visual_seed(serial, -1, Vector2(arena.position.x, arena.position.y)),
		"life": PITCH_WAVE_VISUAL_FX_DURATION,
		"maxLife": PITCH_WAVE_VISUAL_FX_DURATION
	})
	runtime["pitch_wave_visual_effects"] = visual_effects

static func _handle_rhythm_explosion(target: Node, runtime: Dictionary, active: Dictionary, arena: Rect2) -> void:
	var payload: Dictionary = active.get("payload", {}) as Dictionary
	var marker_count := maxi(1, int(payload.get("markerCount", RHYTHM_EXPLOSION_DEFAULT_COUNT)))
	var first_explosion := maxf(0.0, float(payload.get("firstExplosion", RHYTHM_EXPLOSION_DEFAULT_FIRST_EXPLOSION)))
	var interval := maxf(0.0, float(payload.get("interval", RHYTHM_EXPLOSION_DEFAULT_INTERVAL)))
	var damage := int(payload.get("damage", RHYTHM_EXPLOSION_DEFAULT_DAMAGE))
	var active_duration := maxf(0.01, float(payload.get("activeDuration", 2.65)))
	var serial := int(active.get("serial", 0))
	for i in range(marker_count):
		var pos := rhythm_explosion_marker_position_for_target(target, arena, i, marker_count)
		var delay := first_explosion + float(i) * interval
		var hazard := _new_hazard("rhythm_explosion", pos, active_duration, damage)
		hazard["shape"] = "circle"; hazard["radius"] = RHYTHM_EXPLOSION_RADIUS; hazard["delay"] = delay; hazard["source"] = "relay_boss_rhythm_explosion"
		hazard["attackId"] = "rhythm_explosion"
		hazard["bossAttackId"] = "rhythm_explosion"
		hazard["rhythmExplosionVisual"] = true
		hazard["rhythmExplosionMarkerIndex"] = i
		hazard["rhythmExplosionMarkerCount"] = marker_count
		hazard["rhythmExplosionSerial"] = serial
		hazard["rhythmExplosionInitialDelay"] = delay
		hazard["rhythmExplosionVisualSeed"] = _rhythm_explosion_visual_seed(serial, i, pos)
		hazard["rhythmExplosionActivationFxEmitted"] = false
		hazard["rhythmExplosionHitFxEmitted"] = false
		_append_hazard(runtime, hazard)

static func _dirty_paint_payload_for_target(target: Node) -> Dictionary:
	var config: Dictionary = target.get("relay_mode_config") as Dictionary
	var boss_config: Dictionary = config.get("boss", {}) as Dictionary
	var attacks: Dictionary = boss_config.get("attacks", {}) as Dictionary
	return _normalized_payload("dirty_paint", attacks.get("dirty_paint", {}) as Dictionary)

static func dirty_paint_position_for_arena(arena: Rect2, index: int, count: int = 3) -> Vector2:
	# Keep the original fixed three-slot pattern as the single source of truth.
	# `count` is accepted so warning/data consumers use the same helper without
	# changing the established slot formula.
	var safe_count := maxi(1, count)
	var safe_index := clampi(index, 0, safe_count - 1)
	return Vector2(
		arena.position.x + arena.size.x * (0.28 + float(safe_index) * 0.24),
		arena.position.y + arena.size.y * (0.38 + float(safe_index % 2) * 0.24)
	)

static func _dirty_paint_visual_seed(serial: int, slot_index: int, pos: Vector2) -> float:
	var raw := sin(
		float(serial) * 23.173
		+ float(slot_index) * 41.719
		+ pos.x * 0.0137
		+ pos.y * 0.0193
	) * 43758.5453
	return fposmod(raw, 1.0)

static func _is_dirty_paint_hazard(hazard: Dictionary) -> bool:
	return bool(hazard.get("dirtyPaintVisual", false)) \
		or String(hazard.get("kind", "")) == "dirty_paint" \
		or String(hazard.get("source", "")) == "relay_boss_dirty_paint" \
		or String(hazard.get("attackId", hazard.get("bossAttackId", ""))) == "dirty_paint"

static func _is_dirty_paint_visual_effect(effect: Dictionary) -> bool:
	var kind := String(effect.get("kind", ""))
	return kind.begins_with("dirty_paint_") \
		or String(effect.get("bossAttackId", effect.get("attackId", ""))) == "dirty_paint"

static func _append_dirty_paint_visual_effect(runtime: Dictionary, kind: String, hazard: Dictionary, pos: Vector2, life: float, seed_offset: float) -> void:
	var effects: Array = runtime.get("dirty_paint_visual_effects", []) as Array
	var effect := {
		"kind": kind,
		"attackId": "dirty_paint",
		"bossAttackId": "dirty_paint",
		"ownerAttackId": String(hazard.get("dirtyPaintOwnerAttackId", "dirty_paint")),
		"slotIndex": int(hazard.get("dirtyPaintSlotIndex", -1)),
		"serial": int(hazard.get("dirtyPaintSerial", 0)),
		"pos": pos,
		"visualSeed": float(hazard.get("dirtyPaintVisualSeed", 0.0)) + seed_offset,
		"life": life,
		"maxLife": life
	}
	_copy_all_genre_rush_child_metadata(effect, hazard)
	effects.append(effect)
	runtime["dirty_paint_visual_effects"] = effects

static func _handle_dirty_paint(target: Node, runtime: Dictionary, active: Dictionary, arena: Rect2) -> void:
	var mechanics_payload := _dirty_paint_payload_for_target(target)
	var count := maxi(1, int(mechanics_payload.get("count", 3)))
	var speed_multiplier := clampf(float(mechanics_payload.get("speedMultiplier", 0.65)), 0.0, 1.0)
	var slow_rate := 1.0 - speed_multiplier
	var damage := int(mechanics_payload.get("damage", 0))
	var active_payload: Dictionary = active.get("payload", {}) as Dictionary
	var lifetime := maxf(0.01, float(active_payload.get("activeDuration", 7.0)))
	var owner_attack_id := String(active.get("id", "dirty_paint"))
	var serial := int(active.get("serial", 0))
	for i in range(count):
		var pos := dirty_paint_position_for_arena(arena, i, count)
		var hazard := _new_hazard("dirty_paint", pos, lifetime, damage)
		hazard["shape"] = "circle"
		hazard["radius"] = DIRTY_PAINT_RADIUS
		hazard["slowRate"] = slow_rate
		hazard["source"] = "relay_boss_dirty_paint"
		hazard["attackId"] = "dirty_paint"
		hazard["bossAttackId"] = "dirty_paint"
		hazard["dirtyPaintVisual"] = true
		hazard["dirtyPaintSlotIndex"] = i
		hazard["dirtyPaintSerial"] = serial
		hazard["dirtyPaintVisualSeed"] = _dirty_paint_visual_seed(serial, i, pos)
		hazard["dirtyPaintOwnerAttackId"] = owner_attack_id
		hazard["dirtyPaintExpiryFxEmitted"] = false
		_apply_all_genre_rush_child_metadata(hazard, active, 3)
		_append_hazard(runtime, hazard)
		_append_dirty_paint_visual_effect(runtime, "dirty_paint_spawn", hazard, pos, DIRTY_PAINT_SPAWN_FX_DURATION, 0.0)

static func _update_dirty_paint_recovery_runtime(runtime: Dictionary, delta: float, cast_serial: int = -1) -> void:
	var kept: Array = []
	for item in runtime.get("hazards", []) as Array:
		var hazard: Dictionary = item as Dictionary
		if not _is_dirty_paint_hazard(hazard) or String(hazard.get("dirtyPaintOwnerAttackId", "")) != ALL_GENRE_RUSH_OWNER_ID or not _all_genre_rush_cast_matches(hazard, cast_serial):
			kept.append(hazard)
			continue
		hazard["time"] = float(hazard.get("time", 0.0)) - delta
		if float(hazard.get("time", 0.0)) > 0.0:
			kept.append(hazard)
		elif not bool(hazard.get("dirtyPaintExpiryFxEmitted", false)):
			hazard["dirtyPaintExpiryFxEmitted"] = true
			_append_dirty_paint_visual_effect(runtime, "dirty_paint_expiry", hazard, Vector2(hazard.get("pos", Vector2.ZERO)), DIRTY_PAINT_EXPIRY_FX_DURATION, 0.91)
	runtime["hazards"] = kept

static func _update_dirty_paint_contact_visual_state(target: Node, runtime: Dictionary, delta: float) -> void:
	var state: Dictionary = runtime.get("dirty_paint_contact_state", {"inside": false, "stayTimer": 0.0, "center": Vector2.ZERO, "radius": DIRTY_PAINT_RADIUS, "visualSeed": 0.0}) as Dictionary
	var player_pos := Vector2(target.get("player_pos"))
	var inside := false
	var best_distance_sq := 1.0e30
	var best_hazard: Dictionary = {}
	for item in runtime.get("hazards", []) as Array:
		var hazard: Dictionary = item as Dictionary
		if not _is_dirty_paint_hazard(hazard) or float(hazard.get("time", 0.0)) <= 0.0:
			continue
		var center := Vector2(hazard.get("pos", Vector2.ZERO))
		var radius := maxf(0.0, float(hazard.get("radius", DIRTY_PAINT_RADIUS)))
		var distance_sq := player_pos.distance_squared_to(center)
		if distance_sq <= radius * radius and distance_sq < best_distance_sq:
			inside = true
			best_distance_sq = distance_sq
			best_hazard = hazard
	var was_inside := bool(state.get("inside", false))
	if inside:
		state["center"] = Vector2(best_hazard.get("pos", player_pos))
		state["radius"] = float(best_hazard.get("radius", DIRTY_PAINT_RADIUS))
		state["visualSeed"] = float(best_hazard.get("dirtyPaintVisualSeed", 0.0))
		_copy_all_genre_rush_child_metadata(state, best_hazard)
		state["stayTimer"] = float(state.get("stayTimer", 0.0)) + delta
		if not was_inside:
			_append_dirty_paint_visual_effect(runtime, "dirty_paint_contact_enter", best_hazard, player_pos, DIRTY_PAINT_CONTACT_ENTER_FX_DURATION, 0.37)
	else:
		if was_inside:
			var exit_hazard := {"dirtyPaintVisualSeed": float(state.get("visualSeed", 0.0)), "dirtyPaintOwnerAttackId": String(state.get("dirtyPaintOwnerAttackId", "dirty_paint"))}
			_copy_all_genre_rush_child_metadata(exit_hazard, state)
			_append_dirty_paint_visual_effect(runtime, "dirty_paint_contact_exit", exit_hazard, player_pos, DIRTY_PAINT_CONTACT_EXIT_FX_DURATION, 0.73)
		for key in ["ownerAttackId", "allGenreRushCastSerial", "allGenreRushStepIndex", "allGenreRushChildKind", "allGenreRushChildIdentity"]:
			state.erase(key)
		state["stayTimer"] = 0.0
	state["inside"] = inside
	runtime["dirty_paint_contact_state"] = state

static func eraser_sweep_geometry_for_arena(arena: Rect2, travel_time: float = ERASER_SWEEP_TRAVEL_TIME) -> Dictionary:
	var duration := maxf(0.1, travel_time)
	var corridor_height := maxf(0.0, arena.size.y - ERASER_SAFE_MARGIN_Y * 2.0)
	var corridor_size := Vector2(ERASER_SWEEP_WIDTH, corridor_height)
	var start_pos := Vector2(arena.position.x + ERASER_SWEEP_START_OFFSET_X, arena.position.y + ERASER_SAFE_MARGIN_Y)
	var velocity := Vector2(arena.size.x / duration, 0.0)
	var end_pos := start_pos + velocity * duration
	var start_rect := Rect2(start_pos, corridor_size)
	var end_rect := Rect2(end_pos, corridor_size)
	return {
		"start": start_pos,
		"end": end_pos,
		"startRect": start_rect,
		"endRect": end_rect,
		"pathRect": start_rect.merge(end_rect),
		"velocity": velocity,
		"safeTop": start_pos.y,
		"safeBottom": start_pos.y + corridor_height,
		"safeMarginY": ERASER_SAFE_MARGIN_Y,
		"width": ERASER_SWEEP_WIDTH,
		"height": corridor_height,
		"duration": duration,
		"travelTime": duration,
		"startX": start_pos.x,
		"endX": end_pos.x
	}

static func _eraser_sweep_visual_seed(serial: int, pos: Vector2, salt: float = 0.0) -> float:
	return fposmod(sin(float(serial) * 19.173 + pos.x * 0.0137 + pos.y * 0.0193 + salt * 43.917) * 43758.5453, 1.0)

static func _append_eraser_sweep_visual_effect(runtime: Dictionary, kind: String, hazard: Dictionary, pos: Vector2, life: float, seed_offset: float) -> void:
	var effects: Array = runtime.get("eraser_sweep_visual_effects", []) as Array
	effects.append({
		"kind": kind,
		"attackId": "eraser_sweep",
		"bossAttackId": "eraser_sweep",
		"source": "relay_boss_eraser_sweep",
		"serial": int(hazard.get("eraserSweepSerial", 0)),
		"pos": pos,
		"origin": Vector2(hazard.get("pos", pos)),
		"visualSeed": float(hazard.get("eraserSweepVisualSeed", 0.0)) + seed_offset,
		"life": life,
		"maxLife": life
	})
	runtime["eraser_sweep_visual_effects"] = effects

static func _eraser_sweep_hits_player(hazard: Dictionary, previous_pos: Vector2, arena: Rect2, player_pos: Vector2) -> bool:
	var size := Vector2(hazard.get("size", Vector2(ERASER_SWEEP_WIDTH, 0.0)))
	var current_pos := Vector2(hazard.get("pos", previous_pos))
	var fallback_end_x := arena.position.x + ERASER_SWEEP_START_OFFSET_X + arena.size.x
	var end_x := float(hazard.get("eraserSweepEndX", fallback_end_x))
	# A large frame can overshoot the right endpoint.  The sweep's last valid
	# rect is still part of the continuous path, but no area beyond it is.
	var bounded_current := current_pos
	if bounded_current.x > end_x:
		bounded_current.x = end_x
	var previous_rect := Rect2(previous_pos, size)
	var current_rect := Rect2(bounded_current, size)
	hazard["eraserSweepPreviousPos"] = previous_pos
	hazard["eraserSweepPreviousRect"] = previous_rect
	return previous_rect.merge(current_rect).has_point(player_pos)

static func _handle_eraser_sweep(runtime: Dictionary, active: Dictionary, arena: Rect2) -> void:
	var payload: Dictionary = active.get("payload", {}) as Dictionary
	var duration := maxf(0.1, float(payload.get("activeDuration", 1.0)))
	var travel_time := maxf(0.1, float(payload.get("travelTime", ERASER_SWEEP_TRAVEL_TIME)))
	var geometry := eraser_sweep_geometry_for_arena(arena, travel_time)
	var start_pos: Vector2 = geometry.get("start", Vector2(arena.position.x - 80.0, arena.position.y + 128.0))
	var start_rect: Rect2 = geometry.get("startRect", Rect2(start_pos, Vector2(ERASER_SWEEP_WIDTH, arena.size.y - ERASER_SAFE_MARGIN_Y * 2.0)))
	var end_pos: Vector2 = geometry.get("end", start_pos + Vector2(arena.size.x, 0.0))
	var serial := int(active.get("serial", 0))
	var hazard := _new_hazard("eraser_sweep", start_pos, duration, int(payload.get("damage", 20)))
	hazard["shape"] = "rect"
	hazard["size"] = start_rect.size
	# Keep the existing left-to-right travel calculation; this metadata is
	# authoritative for drawing and for the eraser-only swept candidate.
	hazard["vel"] = Vector2(geometry.get("velocity", Vector2(arena.size.x / duration, 0.0)))
	hazard["source"] = "relay_boss_eraser_sweep"
	hazard["attackId"] = "eraser_sweep"
	hazard["bossAttackId"] = "eraser_sweep"
	hazard["eraserSweepVisual"] = true
	hazard["eraserSweepSerial"] = serial
	hazard["eraserSweepVisualSeed"] = _eraser_sweep_visual_seed(serial, start_pos)
	hazard["eraserSweepTravelTime"] = travel_time
	hazard["eraserSweepEndX"] = end_pos.x
	hazard["eraserSweepSafeTop"] = float(geometry.get("safeTop", start_pos.y))
	hazard["eraserSweepSafeBottom"] = float(geometry.get("safeBottom", start_pos.y + start_rect.size.y))
	hazard["eraserSweepEntryFxEmitted"] = false
	hazard["eraserSweepHitFxEmitted"] = false
	hazard["eraserSweepWakeFxEmitted"] = false
	_append_hazard(runtime, hazard)
	_append_eraser_sweep_visual_effect(runtime, "eraser_sweep_entry", hazard, start_pos + Vector2(ERASER_SWEEP_WIDTH, start_rect.size.y * 0.5), ERASER_SWEEP_ENTRY_FX_DURATION, 0.0)

static func _append_paint_warning_visual_effect(runtime: Dictionary, kind: String, hazard: Dictionary, pos: Vector2, life: float, seed_offset: float) -> void:
	var effects: Array = runtime.get("paint_warning_visual_effects", []) as Array
	effects.append({
		"kind": kind,
		"attackId": "paint_warning",
		"bossAttackId": "paint_warning",
		"source": "relay_boss_paint_warning",
		"serial": int(hazard.get("paintWarningSerial", 0)),
		"pos": pos,
		"center": Vector2(hazard.get("paintWarningCenterSnapshot", hazard.get("pos", pos))),
		"radius": float(hazard.get("paintWarningRadius", hazard.get("radius", 0.0))),
		"visualSeed": float(hazard.get("paintWarningVisualSeed", 0.0)) + seed_offset,
		"life": life,
		"maxLife": life
	})
	runtime["paint_warning_visual_effects"] = effects

static func confirm_paint_warning_hits_for_target(target: Node, damage_events: Array, damage_feedback: Dictionary) -> void:
	# DamageSystem is authoritative for the confirmed-hit distinction.  The
	# relay attack itself still emits candidate cadence at hitTimer reset, but
	# this hook adds the stronger player-facing accent only for accepted damage.
	if not bool(damage_feedback.get("damaged", false)):
		return
	var runtime := ensure_for_target(target)
	var is_paint_event := false
	for item in damage_events:
		var event: Dictionary = item as Dictionary
		if String(event.get("attackId", "")) == "paint_warning" or String(event.get("source", "")) == "relay_boss_paint_warning":
			is_paint_event = true
			break
	if not is_paint_event:
		return
	var active: Dictionary = runtime.get("active_attack", {}) as Dictionary
	var center := Vector2(active.get("paintWarningCenterSnapshot", target.get("player_pos")))
	var radius := float(active.get("paintWarningRadius", 0.0))
	var serial := int(active.get("paintWarningSerial", active.get("serial", 0)))
	var seed := _paint_warning_visual_seed(serial, center, 1.37)
	var hit_hazard := {
		"paintWarningSerial": serial,
		"paintWarningCenterSnapshot": center,
		"paintWarningRadius": radius,
		"paintWarningVisualSeed": seed
	}
	_append_paint_warning_visual_effect(runtime, "paint_warning_hit", hit_hazard, Vector2(target.get("player_pos")), PAINT_WARNING_HIT_FX_DURATION, 2.11)

static func _handle_paint_warning(target: Node, runtime: Dictionary, active: Dictionary, arena: Rect2) -> void:
	var payload: Dictionary = active.get("payload", {}) as Dictionary
	if not bool(active.get("paintWarningSnapshotValid", false)):
		# Defensive recovery is only for injected/legacy runtime data.  The
		# ordinary attack-start path captures this snapshot before telegraph draw.
		_capture_paint_warning_snapshot(target, active, arena)
	var center := Vector2(active.get("paintWarningCenterSnapshot", paint_warning_center_for_target(target, arena)))
	var radius := float(active.get("paintWarningRadius", paint_warning_radius_for_arena(arena)))
	var active_duration := float(payload.get("activeDuration", 2.5))
	var count := maxi(1, int(payload.get("count", PAINT_WARNING_DEFAULT_COUNT)))
	var damage := int(payload.get("damage", 7))
	var serial := int(active.get("paintWarningSerial", active.get("serial", 0)))
	for i in range(count):
		var hazard := _new_hazard("paint_warning", center, active_duration, damage)
		hazard["shape"] = "circle"
		hazard["radius"] = radius
		hazard["damageInterval"] = float(payload.get("damageInterval", 0.6))
		hazard["source"] = "relay_boss_paint_warning"
		hazard["attackId"] = "paint_warning"
		hazard["bossAttackId"] = "paint_warning"
		hazard["paintWarningVisual"] = true
		hazard["paintWarningSerial"] = serial
		hazard["paintWarningSlotIndex"] = i
		hazard["paintWarningCenterSnapshot"] = center
		hazard["paintWarningRadius"] = radius
		hazard["paintWarningVisualSeed"] = _paint_warning_visual_seed(serial, center, float(i))
		_append_hazard(runtime, hazard)
		_append_paint_warning_visual_effect(runtime, "paint_warning_activation", hazard, center, PAINT_WARNING_ACTIVATION_FX_DURATION, float(i) * 0.31)

static func _handle_division_noise(target: Node, runtime: Dictionary, active: Dictionary, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var anchors: Array = []
	if active.has("divisionNoiseAnchorPlayer") and active.has("divisionNoiseAnchorPartner"):
		anchors = [Vector2(active.get("divisionNoiseAnchorPlayer")), Vector2(active.get("divisionNoiseAnchorPartner"))]
	else:
		# Direct/forced activation fallback is deliberately a single non-RNG
		# snapshot. Normal telegraph flow always reaches the locked fields above.
		anchors = _division_noise_live_anchor_positions(target)
		active["divisionNoiseAnchorLocked"] = true
		active["divisionNoiseAnchorPlayer"] = anchors[0]
		active["divisionNoiseAnchorPartner"] = anchors[1]
	var payload: Dictionary = active.get("payload", {}) as Dictionary
	var duration := float(payload.get("activeDuration", 4.0))
	var anchor_damage := int(payload.get("damage", 7))
	var cast_serial := int(active.get("serial", 0))
	for index in range(anchors.size()):
		var anchor: Vector2 = anchors[index]
		_add_circle(runtime, "division_noise", anchor, duration, anchor_damage, DIVISION_NOISE_ANCHOR_RADIUS, "relay_boss_division_noise")
		var hazards: Array = runtime.get("hazards", []) as Array
		if hazards.is_empty():
			continue
		var hazard_index := hazards.size() - 1
		var hazard: Dictionary = hazards[hazard_index] as Dictionary
		var visual_seed := _division_noise_visual_seed(cast_serial, anchor, anchors[(index + 1) % anchors.size()], float(index))
		hazard["attackId"] = "division_noise"
		hazard["bossAttackId"] = "division_noise"
		hazard["divisionNoiseAnchor"] = true
		hazard["divisionNoiseAnchorIndex"] = index
		hazard["divisionNoiseCastSerial"] = cast_serial
		hazard["divisionNoiseVisualSeed"] = visual_seed
		hazard["divisionNoiseAnchorSnapshot"] = anchor
		hazards[hazard_index] = hazard
		runtime["hazards"] = hazards
		var effects: Array = runtime.get("division_noise_visual_effects", []) as Array
		effects.append({
			"kind": "relay_division_noise_anchor_activation",
			"bossAttackId": "division_noise",
			"attackId": "division_noise",
			"anchorIndex": index,
			"castSerial": cast_serial,
			"pos": anchor,
			"visualSeed": visual_seed,
			"life": DIVISION_NOISE_ANCHOR_FX_DURATION,
			"maxLife": DIVISION_NOISE_ANCHOR_FX_DURATION
		})
		runtime["division_noise_visual_effects"] = effects
	if target.has_method("_relay_boss_spawn_division_noise"):
		target.call("_relay_boss_spawn_division_noise", 2, arena, rng, cast_serial)

static func _handle_collab_break_start(target: Node, runtime: Dictionary, active: Dictionary, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var payload: Dictionary = active.get("payload", {}) as Dictionary
	var boss_hp := 1.0
	for item in target.get("enemies") as Array:
		var enemy: Dictionary = item as Dictionary
		if bool(enemy.get("relayBoss", false)):
			boss_hp = float(enemy.get("max_hp", enemy.get("hp", 1.0)))
			break
	var core := Vector2(active.get("collabBreakCorePosition", _attack_marker_origin(target, "collab_break", arena)))
	var core_hp := maxi(1, int(round(boss_hp * float(payload.get("breakDamageRate", COLLAB_BREAK_CORE_HP_RATE)))))
	var cast_serial := int(active.get("collabBreakCoreCastSerial", active.get("serial", 0)))
	var core_uid := -1
	if target.has_method("_relay_boss_spawn_collab_break_core"):
		# The dedicated core is built through the deterministic enemy path.  The
		# rng argument is retained for the narrow callback signature but is not
		# read by the core builder.
		core_uid = int(target.call("_relay_boss_spawn_collab_break_core", core, arena, rng, core_hp, cast_serial))
	active["collabBreakCoreUid"] = core_uid
	runtime["collab_break_uid"] = core_uid
	if core_uid < 0:
		_finish_collab_break_for_target(target, "spawn_failed")
		return
	if target.has_method("_set_collab_partner_mute_source"):
		target.call("_set_collab_partner_mute_source", "collab_break", true)
	else:
		target.set("collab_boss_partner_muted", true)
	if target.has_method("_set_collab_pass_source"):
		target.call("_set_collab_pass_source", "collab_break", true)
	# An already active PASS belongs to the collaboration flow, so the core
	# takes ownership of that opportunity immediately.  This uses the existing
	# non-RNG failure/clear path and does not touch other instruction sources.
	if int(target.get("collab_pass_target_uid")) >= 0 and target.has_method("_clear_collab_pass"):
		target.call("_clear_collab_pass", false)
	_append_collab_break_visual_effect(runtime, {
		"kind": "collab_break_core_spawn_fx",
		"bossAttackId": "collab_break",
		"coreUid": core_uid,
		"castSerial": cast_serial,
		"pos": core,
		"visualSeed": float(active.get("collabBreakCoreVisualSeed", _collab_break_visual_seed(cast_serial, core))),
		"life": COLLAB_BREAK_CORE_SPAWN_FX_DURATION,
		"maxLife": COLLAB_BREAK_CORE_SPAWN_FX_DURATION
	})
	var noise_payload := _noise_payload_for_target(target)
	var phase_settings := _noise_phase_settings(noise_payload, clampi(int(target.get("relay_boss_phase")), 0, 4))
	var sidecar_count := maxi(1, floori(float(phase_settings.get("spawnCount", noise_payload.get("count", 2))) * float(noise_payload.get("collabBreakSpawnMultiplier", 0.75))))
	if _can_prepare_noise_wave(target, runtime, noise_payload, RelayBossMovementSystem.state_for_target(target), true):
		_prepare_noise_summon_wave(target, runtime, noise_payload, arena, rng, "collab_break_sidecar", sidecar_count, "collab_break", cast_serial)

static func _handle_all_genre_rush_start(_target: Node, runtime: Dictionary, active: Dictionary, _arena: Rect2, _rng: RandomNumberGenerator) -> void:
	active["substep"] = 0
	active["genreStepTimer"] = 0.0
	active["allGenreRushStepIndex"] = -1
	active["allGenreRushCompletedMask"] = 0
	active["allGenreRushElapsed"] = 0.0
	runtime["gameplay_variant"] = ALL_GENRE_RUSH_OWNER_ID
	runtime["allGenreRushCastSerial"] = int(active.get("allGenreRushCastSerial", active.get("serial", 0)))
	runtime["allGenreRushStepIndex"] = -1
	runtime["allGenreRushCompletedMask"] = 0
	runtime["allGenreRushElapsed"] = 0.0

static func _handle_collab_break(target: Node, _runtime: Dictionary, active: Dictionary) -> void:
	if float(active.get("timer", 0.0)) <= 0.0:
		_finish_collab_break_for_target(target, "timeout")
		return
	var core_uid := int(active.get("collabBreakCoreUid", -1))
	if core_uid < 0:
		_finish_collab_break_for_target(target, "destroy")
		return
	var core := _enemy_by_uid(target, core_uid)
	if core.is_empty() or bool(core.get("defeatPending", false)) or bool(core.get("defeatResolved", false)):
		_finish_collab_break_for_target(target, "destroy")

static func _handle_all_genre_rush(target: Node, runtime: Dictionary, active: Dictionary, _delta: float, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var elapsed := float(active.get("elapsed", 0.0))
	active["allGenreRushElapsed"] = elapsed
	runtime["allGenreRushElapsed"] = elapsed
	var next_step := int(active.get("allGenreRushStepIndex", -1)) + 1
	while next_step < ALL_GENRE_RUSH_STEP_COUNT and elapsed >= float(ALL_GENRE_RUSH_STEP_OFFSETS[next_step]):
		active["allGenreRushStepIndex"] = next_step
		runtime["allGenreRushStepIndex"] = next_step
		match next_step:
			0:
				_handle_kuso_maro_drop(target, runtime, active, arena, rng)
			1:
				_handle_long_comment_line(runtime, active, arena)
			2:
				_handle_howling_ring(target, runtime, active, arena)
			3:
				_handle_dirty_paint(target, runtime, active, arena)
		active["allGenreRushCompletedMask"] = int(active.get("allGenreRushCompletedMask", 0)) | (1 << next_step)
		runtime["allGenreRushCompletedMask"] = int(active.get("allGenreRushCompletedMask", 0))
		active["substep"] = next_step + 1
		next_step += 1
