class_name RelayBossDrawSystem
extends RefCounted

const AttackSystemScript := preload("res://scripts/systems/relay_boss_attack_system.gd")
const MovementSystemScript := preload("res://scripts/systems/relay_boss_movement_system.gd")
const DefenseSystemScript := preload("res://scripts/systems/relay_boss_defense_system.gd")

const OFFLINE_LASER_LENGTH := 900.0
const OFFLINE_LASER_HIT_WIDTH := 26.0
const KUSO_MARO_PROJECTILE_TEXTURE: Texture2D = preload("res://assets/generated/boss_attack_fx_v1/kuso_maro_projectile.png")
const LONG_COMMENT_LINE_COLLISION_HALF_WIDTH := 18.0
const LONG_COMMENT_LINE_RAIL_WIDTH := 1.8
const LONG_COMMENT_LINE_HIT_FX_DURATION := 0.20
const RACE_LANE_CHARGE_CORRIDOR_HEIGHT := 86.0
const RACE_LANE_CHARGE_BOUNDARY_OFFSET := 42.0
const RACE_LANE_CHARGE_CUE_DURATION := 0.16
const RACE_LANE_CHARGE_HIT_FX_DURATION := 0.17
const FAKE_GIFT_BOX_ICON_PATH := "res://assets/generated/field_pickup_icons_v1/icons/care_package_box.png"
const FAKE_GIFT_TRAP_DISPLAY_SIZE := 68.0
const FAKE_GIFT_TRAP_TRIGGER_RADIUS := 40.0
const FAKE_GIFT_TRAP_DETONATION_DURATION := 0.20
const HOWLING_RING_RADII := [120.0, 208.0, 296.0]
const HOWLING_RING_HALF_WIDTH := 18.0
const HOWLING_RING_RAIL_WIDTH := 1.8
const HOWLING_RING_ACTIVATION_FX_DURATION := 0.18
const HOWLING_RING_HIT_FX_DURATION := 0.20
const PITCH_WAVE_RADIUS := 42.0
const PITCH_WAVE_SPEED := 300.0
const PITCH_WAVE_LAUNCH_FX_DURATION := 0.18
const PITCH_WAVE_HIT_FX_DURATION := 0.20
const RHYTHM_EXPLOSION_RADIUS := 58.0
const RHYTHM_EXPLOSION_WARNING_DURATION := 1.40
const RHYTHM_EXPLOSION_BEAT_INTERVAL := 0.25
const RHYTHM_EXPLOSION_ACTIVATION_FX_DURATION := 0.20
const RHYTHM_EXPLOSION_HIT_FX_DURATION := 0.20
const DIRTY_PAINT_RADIUS := 145.0
const DIRTY_PAINT_RAIL_WIDTH := 2.0
const DIRTY_PAINT_INNER_RAIL_WIDTH := 1.0
const DIRTY_PAINT_WARNING_DURATION := 0.90
const DIRTY_PAINT_BOSS_CUE_DURATION := 0.20
const ERASER_SWEEP_WIDTH := 128.0
const ERASER_SAFE_MARGIN_Y := 128.0
const ERASER_SWEEP_EDGE_WIDTH := 2.0
const ERASER_SWEEP_ENTRY_FX_DURATION := 0.18
const ERASER_SWEEP_WAKE_FX_DURATION := 0.16
const ERASER_SWEEP_HIT_FX_DURATION := 0.20
const PAINT_WARNING_RADIUS_RATE := 0.24
const PAINT_WARNING_FORMAL_RAIL_WIDTH := 2.0
const PAINT_WARNING_INNER_RAIL_WIDTH := 1.0
const PAINT_WARNING_HIT_FX_DURATION := 0.20
const DIVISION_NOISE_ANCHOR_RADIUS := 46.0
const DIVISION_NOISE_RAIL_WIDTH := 1.8
const DIVISION_NOISE_INNER_RAIL_WIDTH := 1.0
const DIVISION_NOISE_CHILD_RADIUS := 22.0
const DIVISION_NOISE_WARNING_LOCK_REMAINING := 0.45
const DIVISION_NOISE_HIT_FX_DURATION := 0.18
const COLLAB_BREAK_CORE_RADIUS := 27.0
const COLLAB_BREAK_CORE_FX_DURATION := 0.20
const ALL_GENRE_RUSH_STEP_IDS := ["talk", "game", "song", "drawing"]
const ALL_GENRE_RUSH_STEP_OFFSETS := [0.0, 0.6, 1.2, 1.8]
const ALL_GENRE_RUSH_STEP_COUNT := 4
const ALL_GENRE_RUSH_SYNC_CUE_DURATION := 0.20
const ALL_GENRE_RUSH_STEP_CUE_DURATION := 0.12

static func _fake_gift_visual_hash(seed: float, salt: float) -> float:
	return fposmod(sin(seed * 71.173 + salt * 29.719) * 43758.5453, 1.0)

static func _draw_fake_gift_box(target: Node, pos: Vector2, size: float, alpha: float) -> void:
	var drawn := false
	if target.has_method("_draw_field_icon"):
		drawn = bool(target.call("_draw_field_icon", FAKE_GIFT_BOX_ICON_PATH, pos, Vector2(size, size), alpha))
	if drawn:
		return
	var body := Rect2(pos - Vector2(size * 0.32, size * 0.27), Vector2(size * 0.64, size * 0.54))
	target.call("draw_rect", body, Color(1.0, 0.84, 0.46, alpha), true)
	target.call("draw_rect", body, Color(0.35, 0.10, 0.26, alpha), false, 2.0, true)
	target.call("draw_line", pos + Vector2(0.0, -size * 0.27), pos + Vector2(0.0, size * 0.27), Color(1.0, 0.28, 0.52, alpha), 4.0, true)
	target.call("draw_line", pos + Vector2(-size * 0.32, 0.0), pos + Vector2(size * 0.32, 0.0), Color(1.0, 0.28, 0.52, alpha), 4.0, true)

static func _draw_fake_gift_trap_warning(target: Node, active: Dictionary, arena: Rect2, timer: float, foreground: bool) -> void:
	var payload: Dictionary = active.get("payload", {}) as Dictionary
	var duration := maxf(0.01, float(payload.get("telegraph", 0.80)))
	var remaining := clampf(timer, 0.0, duration)
	var progress := clampf(1.0 - remaining / duration, 0.0, 1.0)
	var late := smoothstep(0.58, 1.0, progress)
	var serial := int(active.get("serial", 0))
	var seed := _fake_gift_visual_hash(float(serial), 4.7)
	var center := MovementSystemScript.marker_world_position(target, "GameModule", arena)
	var pulse := 0.5 + 0.5 * sin(float(serial) * 0.71 + progress * TAU * 1.4)
	var alpha := (0.26 + late * 0.22 + pulse * 0.04) if not foreground else (0.42 + late * 0.18)
	# The boss-side cue intentionally communicates five suspicious gifts without
	# exposing the future absolute trap positions.
	# GameModule sits below the relay boss HUD in the world pass.  Keep the
	# five-pip cue on the visible boss body instead of putting it behind the
	# HUD's opaque health panel.
	var offsets := [Vector2(-68.0, 154.0), Vector2(-34.0, 136.0), Vector2(0.0, 126.0), Vector2(34.0, 136.0), Vector2(68.0, 154.0)]
	for i in range(offsets.size()):
		var pip_pos: Vector2 = center + offsets[i]
		var pip_alpha := alpha * (0.84 + 0.14 * _fake_gift_visual_hash(seed, float(i)))
		var pip_size := 17.0 if not foreground else 15.0
		if foreground:
			# The visible pass uses the same existing care-package silhouette as
			# the committed trap, kept deliberately tiny so the warning reads as
			# five suspicious gifts rather than five future hit locations.
			_draw_fake_gift_box(target, pip_pos, 24.0, pip_alpha)
		var body := Rect2(pip_pos - Vector2(pip_size * 0.5, pip_size * 0.38), Vector2(pip_size, pip_size * 0.76))
		target.call("draw_rect", body, Color(0.98, 0.83, 0.56, pip_alpha * 0.82), true)
		target.call("draw_rect", body, Color(0.40, 0.08, 0.24, pip_alpha), false, 1.4, true)
		target.call("draw_line", pip_pos + Vector2(0.0, -pip_size * 0.38), pip_pos + Vector2(0.0, pip_size * 0.38), Color(1.0, 0.25, 0.50, pip_alpha), 1.8, true)
		target.call("draw_line", pip_pos + Vector2(-pip_size * 0.5, 0.0), pip_pos + Vector2(pip_size * 0.5, 0.0), Color(1.0, 0.38, 0.66, pip_alpha * 0.86), 1.4, true)
		if i == 2 and late > 0.0:
			target.call("draw_circle", pip_pos, 2.0 + late * 1.2, Color(1.0, 0.98, 0.86, pip_alpha * (0.44 + late * 0.30)), true)
	var bracket_radius := 42.0 + pulse * 2.0
	target.call("draw_arc", center, bracket_radius, seed * TAU, seed * TAU + 0.82, 7, Color(0.24, 0.04, 0.25, alpha * 0.70), 1.8, true)
	target.call("draw_arc", center, bracket_radius, seed * TAU + PI, seed * TAU + PI + 0.60, 6, Color(1.0, 0.26, 0.52, alpha * 0.66), 1.4, true)
	for i in range(3):
		var sparkle_angle := seed * TAU + float(i) * 2.1
		var sparkle_pos := center + Vector2.from_angle(sparkle_angle) * (50.0 + float(i) * 4.0)
		target.call("draw_rect", Rect2(sparkle_pos - Vector2(2.0, 2.0), Vector2(4.0, 4.0)), Color(0.64, 0.94, 1.0, alpha * (0.34 + late * 0.24)), true)
	if late > 0.84:
		target.call("draw_circle", center, 6.0 + pulse * 2.0, Color(1.0, 0.96, 0.90, alpha * 0.18), true)

static func _fake_gift_pop_scale(timer: float, duration: float) -> float:
	var progress := clampf(1.0 - timer / maxf(0.01, duration), 0.0, 1.0)
	if progress < 0.52:
		return lerpf(0.82, 1.06, smoothstep(0.0, 0.52, progress))
	return lerpf(1.06, 1.0, smoothstep(0.52, 1.0, progress))

static func _draw_fake_gift_traps(target: Node, runtime: Dictionary, arena: Rect2) -> void:
	var visible_rect := arena.grow(90.0)
	for item in runtime.get("fake_gift_traps", []) as Array:
		var trap: Dictionary = item as Dictionary
		var pos := Vector2(trap.get("pos", Vector2.ZERO))
		if not visible_rect.has_point(pos):
			continue
		_draw_fake_gift_trap(target, trap)

static func _draw_fake_gift_trap(target: Node, trap: Dictionary) -> void:
	var pos := Vector2(trap.get("pos", Vector2.ZERO))
	var seed := float(trap.get("visualSeed", 0.0))
	var state := String(trap.get("state", "WAITING"))
	var materialize_timer := maxf(0.0, float(trap.get("materializeTimer", 0.0)))
	var materialize_duration := maxf(0.01, float(trap.get("materializeDuration", 0.18)))
	var scale := _fake_gift_pop_scale(materialize_timer, materialize_duration) if materialize_timer > 0.0 else 1.0
	var alpha := 0.94
	if materialize_timer > 0.0:
		var pop_progress := clampf(1.0 - materialize_timer / materialize_duration, 0.0, 1.0)
		alpha = lerpf(0.92, 1.0, smoothstep(0.0, 0.72, pop_progress))
	_draw_fake_gift_box(target, pos, FAKE_GIFT_TRAP_DISPLAY_SIZE * scale, alpha)
	if state == "WAITING":
		var age := float(trap.get("maxLife", 10.0)) - float(trap.get("life", 10.0))
		var cycle := 1.30 + _fake_gift_visual_hash(seed, 2.0) * 0.70
		var tell_phase := fposmod(age + seed * cycle, cycle)
		if tell_phase >= cycle - 0.12:
			var tell := 1.0 - (tell_phase - (cycle - 0.12)) / 0.12
			target.call("draw_arc", pos, 35.0, seed * TAU, seed * TAU + 1.25, 8, Color(0.50, 0.22, 0.62, tell * 0.34), 1.4, true)
			target.call("draw_rect", Rect2(pos + Vector2(-22.0, -2.0), Vector2(7.0, 3.0)), Color(0.35, 0.07, 0.42, tell * 0.40), true)
			target.call("draw_rect", Rect2(pos + Vector2(14.0, -12.0), Vector2(5.0, 3.0)), Color(0.45, 0.86, 1.0, tell * 0.34), true)
		return
	if state == "ARMED":
		var warning_max := maxf(0.01, float(trap.get("warningMaxTime", 0.45)))
		var warning_progress := clampf(1.0 - float(trap.get("warningTimer", warning_max)) / warning_max, 0.0, 1.0)
		var warn_alpha := 0.58 + warning_progress * 0.28
		var arc_start := seed * TAU
		# Radius 39 with 2px stroke gives an outer edge at the exact 40px
		# trigger boundary. The ring remains broken, never a solid hitbox disk.
		target.call("draw_arc", pos, 39.0, arc_start, arc_start + 1.48, 10, Color(0.30, 0.02, 0.28, warn_alpha), 2.0, true)
		target.call("draw_arc", pos, 39.0, arc_start + 2.18, arc_start + 3.36, 9, Color(0.92, 0.12, 0.38, warn_alpha * 0.92), 2.0, true)
		target.call("draw_arc", pos, 39.0, arc_start + 4.05, arc_start + 4.86, 7, Color(1.0, 0.72, 0.82, warn_alpha * 0.72), 1.0, true)
		target.call("draw_line", pos + Vector2(-9.0, -9.0), pos + Vector2(9.0, 9.0), Color(0.22, 0.02, 0.28, warn_alpha * 0.82), 2.0, true)
		target.call("draw_line", pos + Vector2(-9.0, 9.0), pos + Vector2(9.0, -9.0), Color(0.95, 0.15, 0.44, warn_alpha * 0.78), 1.6, true)
		if warning_progress > 0.45:
			target.call("draw_line", pos + Vector2(-25.0, -13.0), pos + Vector2(-9.0, -18.0), Color(0.52, 0.82, 1.0, warn_alpha * 0.52), 1.2, true)
			target.call("draw_line", pos + Vector2(10.0, 17.0), pos + Vector2(26.0, 11.0), Color(1.0, 0.42, 0.70, warn_alpha * 0.50), 1.2, true)

static func _draw_fake_gift_trap_visual_effects(target: Node, runtime: Dictionary) -> void:
	for item in runtime.get("fake_gift_trap_visual_effects", []) as Array:
		var effect: Dictionary = item as Dictionary
		var life := maxf(0.0, float(effect.get("life", 0.0)))
		var max_life := maxf(0.01, float(effect.get("maxLife", FAKE_GIFT_TRAP_DETONATION_DURATION)))
		var progress := clampf(1.0 - life / max_life, 0.0, 1.0)
		var fade := clampf(life / max_life, 0.0, 1.0)
		var pos := Vector2(effect.get("pos", Vector2.ZERO))
		var seed := float(effect.get("visualSeed", 0.0))
		var radius := lerpf(39.0, 31.0, progress)
		target.call("draw_arc", pos, radius, seed * TAU, seed * TAU + 1.12, 8, Color(0.34, 0.04, 0.40, 0.62 * fade), 2.0, true)
		target.call("draw_arc", pos, radius, seed * TAU + 2.02, seed * TAU + 3.24, 8, Color(1.0, 0.36, 0.66, 0.60 * fade), 1.4, true)
		target.call("draw_line", pos + Vector2(-17.0, -11.0) * (1.0 + progress * 0.2), pos + Vector2(18.0, 12.0) * (1.0 + progress * 0.2), Color(1.0, 0.94, 0.88, 0.62 * fade), 2.0, true)
		for i in range(4):
			var angle := seed * TAU + float(i) * 1.57 + progress * 0.48
			var distance := 18.0 + float(i % 2) * 11.0 + progress * 12.0
			var fragment_pos := pos + Vector2.from_angle(angle) * distance
			var fragment_size := 3.0 + float(i % 2) * 2.0
			target.call("draw_rect", Rect2(fragment_pos - Vector2(fragment_size, fragment_size * 0.5), Vector2(fragment_size * 2.0, fragment_size)), Color(0.38 + 0.12 * float(i % 2), 0.06, 0.42, 0.60 * fade), true)
		if bool(effect.get("hit", false)):
			target.call("draw_line", pos + Vector2(-11.0, -11.0), pos + Vector2(11.0, 11.0), Color(0.96, 0.10, 0.34, 0.86 * fade), 2.2, true)
			target.call("draw_line", pos + Vector2(-11.0, 11.0), pos + Vector2(11.0, -11.0), Color(1.0, 0.94, 0.96, 0.76 * fade), 1.5, true)
		target.call("draw_circle", pos, 5.0 + progress * 3.0, Color(1.0, 0.94, 0.88, 0.26 * fade), true)

static func _draw_fake_gift_trap_foreground(target: Node, runtime: Dictionary) -> void:
	var player_pos := Vector2(target.get("player_pos"))
	for item in runtime.get("fake_gift_traps", []) as Array:
		var trap: Dictionary = item as Dictionary
		if String(trap.get("state", "WAITING")) != "ARMED":
			continue
		var pos := Vector2(trap.get("pos", Vector2.ZERO))
		if player_pos.distance_squared_to(pos) > 108.0 * 108.0:
			continue
		var seed := float(trap.get("visualSeed", 0.0))
		var alpha := 0.38 + clampf(1.0 - float(trap.get("warningTimer", 0.45)) / maxf(0.01, float(trap.get("warningMaxTime", 0.45))), 0.0, 1.0) * 0.22
		target.call("draw_arc", pos, 39.0, seed * TAU + 0.28, seed * TAU + 0.86, 6, Color(0.32, 0.02, 0.30, alpha), 1.6, true)
		target.call("draw_arc", pos, 39.0, seed * TAU + PI + 0.12, seed * TAU + PI + 0.62, 6, Color(1.0, 0.28, 0.52, alpha * 0.90), 1.2, true)

static func draw_for_target(target: Node, arena: Rect2) -> void:
	draw_back_for_target(target, arena)
	draw_front_for_target(target, arena)

static func draw_back_for_target(target: Node, arena: Rect2) -> void:
	if not bool(target.get("relay_boss_active")):
		return
	DefenseSystemScript.draw_back_for_target(target, arena)
	if target.has_method("_draw_relay_boss_motion_effects"):
		target.call("_draw_relay_boss_motion_effects", arena)
	var runtime: Dictionary = AttackSystemScript.ensure_for_target(target)
	var active: Dictionary = runtime.get("active_attack", {}) as Dictionary
	var state := String(active.get("state", AttackSystemScript.STATE_IDLE))
	var attack_id := String(active.get("id", ""))
	var payload: Dictionary = active.get("payload", {}) as Dictionary
	if float(target.get("relay_boss_arena_timer")) > 15.0:
		var warning_alpha := 0.24 + sin(float(target.get("elapsed")) * 14.0) * 0.10
		target.call("draw_rect", arena, Color(1.0, 0.35, 0.60, warning_alpha), false, 8.0)
	if state == AttackSystemScript.STATE_TELEGRAPH:
		if attack_id == "noise_summon":
			_draw_noise_summon_warning(target, active, arena, float(active.get("timer", 0.0)), false)
		elif attack_id == "kuso_maro_drop":
			_draw_kuso_maro_drop_warning(target, active, arena, float(active.get("timer", 0.0)), false)
		elif attack_id == "long_comment_line":
			_draw_long_comment_line_warning(target, active, arena, float(active.get("timer", 0.0)), false)
		elif attack_id == "game_over_barrage":
			_draw_game_over_barrage_warning(target, active, arena, float(active.get("timer", 0.0)), false)
		elif attack_id == "fake_gift_trap":
			_draw_fake_gift_trap_warning(target, active, arena, float(active.get("timer", 0.0)), false)
		elif attack_id == "pitch_wave":
			_draw_pitch_wave_warning(target, active, arena, float(active.get("timer", 0.0)), false)
		elif attack_id == "rhythm_explosion":
			_draw_rhythm_explosion_warning(target, active, arena, float(active.get("timer", 0.0)), false)
		elif attack_id == "dirty_paint":
			_draw_dirty_paint_warning(target, active, arena, float(active.get("timer", 0.0)), false)
		elif attack_id == "eraser_sweep":
			_draw_eraser_sweep_warning(target, active, arena, float(active.get("timer", 0.0)), false)
		elif attack_id == "paint_warning":
			_draw_paint_warning_warning(target, active, arena, float(active.get("timer", 0.0)), false)
		elif attack_id == "division_noise":
			_draw_division_noise_warning(target, active, arena, float(active.get("timer", 0.0)), false)
		elif attack_id == "collab_break":
			_draw_collab_break_warning(target, active, arena, float(active.get("timer", 0.0)), false)
		elif attack_id == "all_genre_rush":
			_draw_all_genre_rush_warning(target, active, arena, float(active.get("timer", 0.0)), false)
		else:
			_draw_telegraph(target, attack_id, payload, arena, float(active.get("timer", 0.0)), active)
	_draw_travel_noise_summon_pending_warning(target, runtime, arena, false)
	_draw_noise_summon_visual_effects(target, runtime)
	_draw_hazards(target, runtime.get("hazards", []) as Array, arena)
	if attack_id == "all_genre_rush" and state != AttackSystemScript.STATE_TELEGRAPH:
		_draw_all_genre_rush_step_cue(target, active, arena, false)
	_draw_kuso_maro_drop_visual_effects(target, runtime)
	_draw_fake_gift_traps(target, runtime, arena)
	_draw_fake_gift_trap_visual_effects(target, runtime)
	_draw_howling_ring_visual_effects(target, runtime)
	_draw_pitch_wave_visual_effects(target, runtime, false)
	_draw_rhythm_explosion_visual_effects(target, runtime, false)
	_draw_dirty_paint_visual_effects(target, runtime)
	_draw_eraser_sweep_visual_effects(target, runtime, false)
	_draw_paint_warning_visual_effects(target, runtime, false)
	_draw_division_noise_effects(target, runtime, false)
	_draw_division_noise_active_link(target, active, runtime)
	_draw_collab_break_visual_effects(target, runtime)
	if bool(runtime.get("debug_overlay", false)):
		_draw_debug(target, runtime, arena)

static func draw_front_for_target(target: Node, arena: Rect2) -> void:
	if not bool(target.get("relay_boss_active")):
		return
	DefenseSystemScript.draw_front_for_target(target, arena)
	var runtime: Dictionary = AttackSystemScript.ensure_for_target(target)
	var active: Dictionary = runtime.get("active_attack", {}) as Dictionary
	_draw_travel_noise_summon_pending_warning(target, runtime, arena, true)
	_draw_travel_noise_summon_front_effects(target, runtime, arena)
	if String(active.get("state", AttackSystemScript.STATE_IDLE)) == AttackSystemScript.STATE_TELEGRAPH and String(active.get("id", "")) == "noise_summon":
		_draw_noise_summon_warning(target, active, arena, float(active.get("timer", 0.0)), true)
	elif String(active.get("state", AttackSystemScript.STATE_IDLE)) == AttackSystemScript.STATE_TELEGRAPH and String(active.get("id", "")) == "kuso_maro_drop":
		_draw_kuso_maro_drop_warning(target, active, arena, float(active.get("timer", 0.0)), true)
	elif String(active.get("state", AttackSystemScript.STATE_IDLE)) == AttackSystemScript.STATE_TELEGRAPH and String(active.get("id", "")) == "long_comment_line":
		_draw_long_comment_line_boss_cue(target, active, arena, true)
	elif String(active.get("state", AttackSystemScript.STATE_IDLE)) == AttackSystemScript.STATE_TELEGRAPH and String(active.get("id", "")) == "race_lane_charge":
		_draw_race_lane_charge_boss_cue(target, active, arena, true)
	elif String(active.get("state", AttackSystemScript.STATE_IDLE)) == AttackSystemScript.STATE_TELEGRAPH and String(active.get("id", "")) == "game_over_barrage":
		_draw_game_over_barrage_warning(target, active, arena, float(active.get("timer", 0.0)), true)
	elif String(active.get("state", AttackSystemScript.STATE_IDLE)) == AttackSystemScript.STATE_TELEGRAPH and String(active.get("id", "")) == "fake_gift_trap":
		_draw_fake_gift_trap_warning(target, active, arena, float(active.get("timer", 0.0)), true)
	elif String(active.get("state", AttackSystemScript.STATE_IDLE)) == AttackSystemScript.STATE_TELEGRAPH and String(active.get("id", "")) == "howling_ring":
		_draw_howling_ring_warning(target, active, arena, float(active.get("timer", 0.0)), true)
	elif String(active.get("state", AttackSystemScript.STATE_IDLE)) == AttackSystemScript.STATE_TELEGRAPH and String(active.get("id", "")) == "pitch_wave":
		_draw_pitch_wave_warning(target, active, arena, float(active.get("timer", 0.0)), true)
	elif String(active.get("state", AttackSystemScript.STATE_IDLE)) == AttackSystemScript.STATE_TELEGRAPH and String(active.get("id", "")) == "rhythm_explosion":
		_draw_rhythm_explosion_warning(target, active, arena, float(active.get("timer", 0.0)), true)
	elif String(active.get("state", AttackSystemScript.STATE_IDLE)) == AttackSystemScript.STATE_TELEGRAPH and String(active.get("id", "")) == "dirty_paint":
		_draw_dirty_paint_warning(target, active, arena, float(active.get("timer", 0.0)), true)
	elif String(active.get("state", AttackSystemScript.STATE_IDLE)) == AttackSystemScript.STATE_TELEGRAPH and String(active.get("id", "")) == "eraser_sweep":
		_draw_eraser_sweep_warning(target, active, arena, float(active.get("timer", 0.0)), true)
	elif String(active.get("state", AttackSystemScript.STATE_IDLE)) == AttackSystemScript.STATE_TELEGRAPH and String(active.get("id", "")) == "paint_warning":
		_draw_paint_warning_warning(target, active, arena, float(active.get("timer", 0.0)), true)
	elif String(active.get("state", AttackSystemScript.STATE_IDLE)) == AttackSystemScript.STATE_TELEGRAPH and String(active.get("id", "")) == "division_noise":
		_draw_division_noise_warning(target, active, arena, float(active.get("timer", 0.0)), true)
	elif String(active.get("state", AttackSystemScript.STATE_IDLE)) == AttackSystemScript.STATE_TELEGRAPH and String(active.get("id", "")) == "all_genre_rush":
		_draw_all_genre_rush_warning(target, active, arena, float(active.get("timer", 0.0)), true)
	for item in runtime.get("hazards", []) as Array:
		var hazard: Dictionary = item as Dictionary
		if String(hazard.get("kind", "")) == "offline_laser":
			_draw_offline_laser_foreground(target, hazard, arena)
		elif bool(hazard.get("kusoMaroDropVisual", false)):
			_draw_kuso_maro_drop_foreground(target, hazard, arena)
		elif bool(hazard.get("howlingRingVisual", false)):
			_draw_howling_ring_foreground(target, hazard, arena)
		elif bool(hazard.get("rhythmExplosionVisual", false)):
			_draw_rhythm_explosion_boss_foreground(target, hazard)
		elif bool(hazard.get("dirtyPaintVisual", false)):
			_draw_dirty_paint_boss_foreground(target, hazard)
		elif bool(hazard.get("eraserSweepVisual", false)):
			_draw_eraser_sweep_boss_foreground(target, hazard, arena)
		elif bool(hazard.get("paintWarningVisual", false)):
			_draw_paint_warning_boss_foreground(target, hazard, arena)
		elif bool(hazard.get("divisionNoiseAnchor", false)):
			_draw_division_noise_foreground(target, hazard)
	if String(active.get("id", "")) == "all_genre_rush" and String(active.get("state", AttackSystemScript.STATE_IDLE)) != AttackSystemScript.STATE_TELEGRAPH:
		_draw_all_genre_rush_step_cue(target, active, arena, true)
	_draw_fake_gift_trap_foreground(target, runtime)

static func draw_collab_break_warning_foreground_for_target(target: Node, arena: Rect2) -> void:
	var runtime: Dictionary = AttackSystemScript.ensure_for_target(target)
	var active: Dictionary = runtime.get("active_attack", {}) as Dictionary
	if String(active.get("state", AttackSystemScript.STATE_IDLE)) == AttackSystemScript.STATE_TELEGRAPH and String(active.get("id", "")) == "collab_break":
		_draw_collab_break_warning(target, active, arena, float(active.get("timer", 0.0)), true)

static func _game_over_barrage_visual_hash(seed: float, salt: float) -> float:
	return fposmod(sin(seed * 71.173 + salt * 29.719) * 43758.5453, 1.0)

static func _draw_game_over_barrage_warning(target: Node, active: Dictionary, arena: Rect2, timer: float, foreground: bool) -> void:
	var payload: Dictionary = active.get("payload", {}) as Dictionary
	var duration := maxf(0.01, float(payload.get("telegraph", 1.0)))
	var remaining := clampf(timer, 0.0, duration)
	var progress := clampf(1.0 - remaining / duration, 0.0, 1.0)
	var late := smoothstep(0.70, 1.0, progress)
	var serial := int(active.get("serial", 0))
	var seed := _game_over_barrage_visual_hash(float(serial), 0.17)
	var center := MovementSystemScript.marker_world_position(target, "GameModule", arena)
	var pulse := 0.5 + 0.5 * sin(float(serial) * 0.41 + progress * TAU * 1.5)
	var marker_alpha := 0.54 + late * 0.20 + pulse * 0.06
	if foreground:
		# Only a compact outline is lifted above the boss.  The warning has no
		# future projectile positions and does not cover the sprite.
		target.call("draw_arc", center, 34.0, seed * TAU, seed * TAU + 1.15, 8, Color(0.12, 0.01, 0.14, 0.70 * marker_alpha), 2.0, true)
		target.call("draw_arc", center, 34.0, seed * TAU + PI, seed * TAU + PI + 0.86, 7, Color(0.96, 0.08, 0.28, 0.82 * marker_alpha), 1.5, true)
		target.call("draw_line", center + Vector2(-9.0, -9.0), center + Vector2(9.0, 9.0), Color(0.98, 0.22, 0.40, 0.88 * marker_alpha), 2.2, true)
		target.call("draw_line", center + Vector2(-9.0, 9.0), center + Vector2(9.0, -9.0), Color(0.12, 0.01, 0.14, 0.90 * marker_alpha), 2.0, true)
		return
	# Back pass: small broken UI brackets and two compact chips.
	target.call("draw_arc", center, 38.0, seed * TAU, seed * TAU + 1.05, 8, Color(0.10, 0.01, 0.13, 0.58 * marker_alpha), 2.4, true)
	target.call("draw_arc", center, 38.0, seed * TAU + 2.25, seed * TAU + 3.42, 8, Color(0.80, 0.05, 0.24, 0.62 * marker_alpha), 2.0, true)
	target.call("draw_arc", center, 38.0, seed * TAU + 4.40, seed * TAU + 5.18, 7, Color(1.0, 0.82, 0.88, 0.48 * marker_alpha), 1.2, true)
	var chip_a := Rect2(center + Vector2(-31.0, -31.0), Vector2(28.0, 13.0))
	var chip_b := Rect2(center + Vector2(4.0, 18.0), Vector2(30.0, 13.0))
	target.call("draw_rect", chip_a, Color(0.08, 0.01, 0.12, 0.76 * marker_alpha), true)
	target.call("draw_rect", chip_a, Color(0.92, 0.08, 0.28, 0.82 * marker_alpha), false, 1.3, true)
	target.call("draw_rect", chip_b, Color(0.08, 0.01, 0.12, 0.76 * marker_alpha), true)
	target.call("draw_rect", chip_b, Color(1.0, 0.84, 0.90, 0.66 * marker_alpha), false, 1.1, true)
	if progress > 0.10:
		if target.has_method("_draw_outlined_text"):
			target.call("_draw_outlined_text", chip_a.position + Vector2(3.0, 10.0), "GAME", 22, 8, Color(1.0, 0.88, 0.93, 0.84 * marker_alpha), Color(0.07, 0.01, 0.11, 0.92 * marker_alpha), HORIZONTAL_ALIGNMENT_CENTER)
			target.call("_draw_outlined_text", chip_b.position + Vector2(4.0, 10.0), "OVER", 22, 8, Color(1.0, 0.88, 0.93, 0.84 * marker_alpha), Color(0.07, 0.01, 0.11, 0.92 * marker_alpha), HORIZONTAL_ALIGNMENT_CENTER)
	# Six short decorative spokes communicate a fan without claiming exact
	# future directions. The current player direction is only a visual bias.
	var player_direction := Vector2(target.get("player_pos")) - center
	if player_direction.length_squared() <= 0.01:
		player_direction = Vector2.RIGHT
	player_direction = player_direction.normalized()
	var spoke_offsets := [-0.45, -0.27, -0.09, 0.09, 0.27, 0.45]
	for i in range(spoke_offsets.size()):
		var spoke_direction := player_direction.rotated(float(spoke_offsets[i]))
		var spoke_start := center + spoke_direction * 24.0
		var spoke_end := center + spoke_direction * (43.0 + late * 6.0)
		var spoke_alpha := (0.22 + progress * 0.16 + late * 0.12) * (0.80 + _game_over_barrage_visual_hash(seed, float(i)) * 0.20)
		var spoke_color := Color(1.0, 0.80, 0.88, spoke_alpha) if i % 2 == 0 else Color(0.88, 0.08, 0.28, spoke_alpha * 0.90)
		target.call("draw_line", spoke_start, spoke_end, spoke_color, 1.6, true)
		if progress > 0.42:
			target.call("draw_rect", Rect2(spoke_end - Vector2(1.8, 1.2), Vector2(3.6, 2.4)), Color(0.13, 0.01, 0.15, spoke_alpha * 1.15), true)
	if late > 0.0:
		target.call("draw_circle", center, 5.0 + pulse * 2.0, Color(1.0, 0.96, 0.98, late * 0.20), true)

static func draw_long_comment_line_hit_fx_for_target(target: Node) -> void:
	var runtime: Dictionary = AttackSystemScript.ensure_for_target(target)
	_draw_long_comment_line_visual_effects(target, runtime)

static func draw_race_lane_charge_hit_fx_for_target(target: Node) -> void:
	var runtime: Dictionary = AttackSystemScript.ensure_for_target(target)
	_draw_race_lane_charge_visual_effects(target, runtime)

static func draw_pitch_wave_hit_fx_for_target(target: Node) -> void:
	var runtime: Dictionary = AttackSystemScript.ensure_for_target(target)
	_draw_pitch_wave_visual_effects(target, runtime, true)

static func draw_rhythm_explosion_hit_fx_for_target(target: Node) -> void:
	var runtime: Dictionary = AttackSystemScript.ensure_for_target(target)
	_draw_rhythm_explosion_visual_effects(target, runtime, true)

static func draw_eraser_sweep_hit_fx_for_target(target: Node) -> void:
	var runtime: Dictionary = AttackSystemScript.ensure_for_target(target)
	_draw_eraser_sweep_visual_effects(target, runtime, true)

static func draw_howling_ring_player_foreground_for_target(target: Node, arena: Rect2) -> void:
	if not bool(target.get("relay_boss_active")):
		return
	var runtime: Dictionary = AttackSystemScript.ensure_for_target(target)
	var player_pos := Vector2(target.get("player_pos"))
	for item in runtime.get("hazards", []) as Array:
		var hazard: Dictionary = item as Dictionary
		if not bool(hazard.get("howlingRingVisual", false)):
			continue
		var center := Vector2(hazard.get("pos", Vector2.ZERO))
		var radius := float(hazard.get("radius", 120.0))
		var band_distance := absf(player_pos.distance_to(center) - radius)
		if band_distance > 70.0:
			continue
		_draw_howling_ring_local_assist(target, center, radius, player_pos, 0.34, float(hazard.get("howlingRingVisualSeed", 0.0)) + 0.31)

static func draw_pitch_wave_player_foreground_for_target(target: Node, _arena: Rect2) -> void:
	if not bool(target.get("relay_boss_active")):
		return
	var runtime: Dictionary = AttackSystemScript.ensure_for_target(target)
	for item in runtime.get("hazards", []) as Array:
		var hazard: Dictionary = item as Dictionary
		if bool(hazard.get("pitchWaveVisual", false)):
			_draw_pitch_wave_foreground(target, hazard)

static func draw_rhythm_explosion_player_foreground_for_target(target: Node, arena: Rect2) -> void:
	if not bool(target.get("relay_boss_active")):
		return
	var runtime: Dictionary = AttackSystemScript.ensure_for_target(target)
	var active: Dictionary = runtime.get("active_attack", {}) as Dictionary
	if String(active.get("state", AttackSystemScript.STATE_IDLE)) == AttackSystemScript.STATE_TELEGRAPH and String(active.get("id", "")) == "rhythm_explosion":
		_draw_rhythm_explosion_player_warning_foreground(target, active, arena)
	var player_pos := Vector2(target.get("player_pos"))
	for item in runtime.get("hazards", []) as Array:
		var hazard: Dictionary = item as Dictionary
		if not bool(hazard.get("rhythmExplosionVisual", false)):
			continue
		var center := Vector2(hazard.get("pos", Vector2.ZERO))
		if player_pos.distance_to(center) - RHYTHM_EXPLOSION_RADIUS <= 72.0:
			_draw_rhythm_explosion_local_assist(target, hazard, player_pos)

static func draw_long_comment_line_player_foreground_for_target(target: Node, arena: Rect2) -> void:
	if not bool(target.get("relay_boss_active")):
		return
	var runtime: Dictionary = AttackSystemScript.ensure_for_target(target)
	var active: Dictionary = runtime.get("active_attack", {}) as Dictionary
	if String(active.get("state", AttackSystemScript.STATE_IDLE)) == AttackSystemScript.STATE_TELEGRAPH and String(active.get("id", "")) == "long_comment_line":
		_draw_long_comment_line_warning(target, active, arena, float(active.get("timer", 0.0)), true)
	for item in runtime.get("hazards", []) as Array:
		var hazard: Dictionary = item as Dictionary
		if bool(hazard.get("longCommentLineVisual", false)):
			_draw_long_comment_line_foreground(target, hazard)

static func draw_race_lane_charge_player_foreground_for_target(target: Node, arena: Rect2) -> void:
	if not bool(target.get("relay_boss_active")):
		return
	var runtime: Dictionary = AttackSystemScript.ensure_for_target(target)
	var active: Dictionary = runtime.get("active_attack", {}) as Dictionary
	if String(active.get("state", AttackSystemScript.STATE_IDLE)) == AttackSystemScript.STATE_TELEGRAPH and String(active.get("id", "")) == "race_lane_charge":
		_draw_race_lane_charge_warning_foreground(target, active, arena, float(active.get("timer", 0.0)))
	for item in runtime.get("hazards", []) as Array:
		var hazard: Dictionary = item as Dictionary
		if bool(hazard.get("raceLaneChargeVisual", false)):
			_draw_race_lane_charge_foreground(target, hazard)

static func draw_dirty_paint_player_foreground_for_target(target: Node, arena: Rect2) -> void:
	if not bool(target.get("relay_boss_active")):
		return
	var runtime: Dictionary = AttackSystemScript.ensure_for_target(target)
	var active: Dictionary = runtime.get("active_attack", {}) as Dictionary
	var player_pos := Vector2(target.get("player_pos"))
	if String(active.get("state", AttackSystemScript.STATE_IDLE)) == AttackSystemScript.STATE_TELEGRAPH and String(active.get("id", "")) == "dirty_paint":
		_draw_dirty_paint_warning_player_assist(target, active, arena, player_pos)
	for item in runtime.get("hazards", []) as Array:
		var hazard: Dictionary = item as Dictionary
		if not bool(hazard.get("dirtyPaintVisual", false)):
			continue
		var center := Vector2(hazard.get("pos", Vector2.ZERO))
		var radius := float(hazard.get("radius", DIRTY_PAINT_RADIUS))
		if absf(player_pos.distance_to(center) - radius) <= 76.0 or player_pos.distance_to(center) <= radius:
			_draw_dirty_paint_player_assist(target, hazard, player_pos)
	var contact_state: Dictionary = runtime.get("dirty_paint_contact_state", {}) as Dictionary
	if bool(contact_state.get("inside", false)):
		_draw_dirty_paint_foot_smear(target, player_pos, float(contact_state.get("visualSeed", 0.0)), 0.20)

static func draw_eraser_sweep_player_foreground_for_target(target: Node, arena: Rect2) -> void:
	if not bool(target.get("relay_boss_active")):
		return
	var runtime: Dictionary = AttackSystemScript.ensure_for_target(target)
	var active: Dictionary = runtime.get("active_attack", {}) as Dictionary
	if String(active.get("state", AttackSystemScript.STATE_IDLE)) == AttackSystemScript.STATE_TELEGRAPH and String(active.get("id", "")) == "eraser_sweep":
		_draw_eraser_sweep_warning(target, active, arena, float(active.get("timer", 0.0)), true)
	var player_pos := Vector2(target.get("player_pos"))
	for item in runtime.get("hazards", []) as Array:
		var hazard: Dictionary = item as Dictionary
		if bool(hazard.get("eraserSweepVisual", false)):
			_draw_eraser_sweep_player_foreground(target, hazard, player_pos)

static func draw_paint_warning_player_foreground_for_target(target: Node, arena: Rect2) -> void:
	if not bool(target.get("relay_boss_active")):
		return
	var runtime: Dictionary = AttackSystemScript.ensure_for_target(target)
	var active: Dictionary = runtime.get("active_attack", {}) as Dictionary
	if String(active.get("state", AttackSystemScript.STATE_IDLE)) == AttackSystemScript.STATE_TELEGRAPH and String(active.get("id", "")) == "paint_warning":
		_draw_paint_warning_warning(target, active, arena, float(active.get("timer", 0.0)), true)
	var player_pos := Vector2(target.get("player_pos"))
	for item in runtime.get("hazards", []) as Array:
		var hazard: Dictionary = item as Dictionary
		if bool(hazard.get("paintWarningVisual", false)):
			var center := Vector2(hazard.get("pos", Vector2.ZERO))
			if center.distance_to(player_pos) <= float(hazard.get("radius", 360.0)) + 86.0:
				_draw_paint_warning_local_assist(target, hazard, player_pos)

static func draw_paint_warning_hit_fx_for_target(target: Node) -> void:
	var runtime: Dictionary = AttackSystemScript.ensure_for_target(target)
	_draw_paint_warning_visual_effects(target, runtime, true)

static func draw_division_noise_player_foreground_for_target(target: Node, arena: Rect2) -> void:
	if not bool(target.get("relay_boss_active")):
		return
	var runtime: Dictionary = AttackSystemScript.ensure_for_target(target)
	var active: Dictionary = runtime.get("active_attack", {}) as Dictionary
	if String(active.get("state", AttackSystemScript.STATE_IDLE)) == AttackSystemScript.STATE_TELEGRAPH and String(active.get("id", "")) == "division_noise":
		# Warning anchors remain in the same saved/live positions used by the
		# back pass; this foreground call only supplies a small local rim.
		_draw_division_noise_warning_local_foreground(target, active)
	var player_pos := Vector2(target.get("player_pos"))
	var partner_pos := Vector2(target.get("collab_partner_pos"))
	for item in runtime.get("hazards", []) as Array:
		var hazard: Dictionary = item as Dictionary
		if bool(hazard.get("divisionNoiseAnchor", false)):
			var center := Vector2(hazard.get("pos", Vector2.ZERO))
			if player_pos.distance_to(center) <= 76.0 or partner_pos.distance_to(center) <= 76.0:
				_draw_division_noise_foreground(target, hazard)

static func draw_division_noise_hit_fx_for_target(target: Node) -> void:
	var runtime: Dictionary = AttackSystemScript.ensure_for_target(target)
	_draw_division_noise_effects(target, runtime, true)

static func _draw_telegraph(target: Node, attack_id: String, payload: Dictionary, arena: Rect2, timer: float, active: Dictionary) -> void:
	var alpha := clampf(0.30 + sin(timer * 12.0) * 0.12, 0.12, 0.55)
	var color := Color(1.0, 0.34, 0.62, alpha)
	var player_pos := Vector2(target.get("player_pos"))
	match attack_id:
		"comment_shotgun":
			target.call("draw_circle", MovementSystemScript.marker_world_position(target, "ChatModule", arena), 48.0, color, false, 4.0)
		"offline_laser":
			_draw_offline_laser_warning(target, active, arena, timer)
		"race_lane_charge":
			_draw_race_lane_charge_warning(target, active, arena, timer)
		"long_comment_line":
			_draw_long_comment_line_warning(target, active, arena, timer, false)
		"eraser_sweep":
			_draw_eraser_sweep_warning(target, active, arena, timer, false)
		"game_over_barrage":
			_draw_game_over_barrage_warning(target, active, arena, float(active.get("timer", 0.0)), false)
		"howling_ring":
			_draw_howling_ring_warning(target, active, arena, timer, false)
		"pitch_wave":
			_draw_pitch_wave_warning(target, active, arena, timer, false)
		"rhythm_explosion":
			_draw_rhythm_explosion_warning(target, active, arena, timer, false)
		"paint_warning":
			_draw_paint_warning_warning(target, active, arena, timer, false)
		"dirty_paint":
			_draw_dirty_paint_warning(target, active, arena, timer, false)
		"collab_break":
			_draw_collab_break_warning(target, active, arena, timer, false)
		"all_genre_rush":
			_draw_all_genre_rush_warning(target, active, arena, timer, false)
		_:
			target.call("draw_circle", player_pos, 64.0, color)

static func _all_genre_rush_boss_radius(target: Node) -> float:
	for item in target.get("enemies") as Array:
		var enemy: Dictionary = item as Dictionary
		if bool(enemy.get("relayBoss", false)) or String(enemy.get("bossId", "")) == "last_offline" or String(enemy.get("kind", "")) == "last_offline":
			return maxf(80.0, float(enemy.get("radius", 105.0)))
	return 105.0

static func _all_genre_rush_pip_centers(target: Node, arena: Rect2) -> Array:
	var boss_center := _boss_origin(target, arena)
	var radius := _all_genre_rush_boss_radius(target)
	# The relay partner's large heart/core sits below the boss and the boss HP
	# strip occupies the upper field in the final scene.  Keep a shallow fixed
	# arc in the open left margin so the four pips remain readable in both draw
	# passes without covering the player or existing child geometry.
	var arc_distance := radius + 205.0
	return [
		boss_center + Vector2(-arc_distance + 18.0, -72.0),
		boss_center + Vector2(-arc_distance, -24.0),
		boss_center + Vector2(-arc_distance, 24.0),
		boss_center + Vector2(-arc_distance + 18.0, 72.0)
	]

static func _draw_all_genre_rush_icon(target: Node, center: Vector2, step_index: int, alpha: float, scale: float, pulse: float, completed: bool) -> void:
	var outline := Color(0.08, 0.03, 0.16, alpha * 0.92)
	var cyan := Color(0.36, 0.94, 1.0, alpha * 0.88)
	var pink := Color(1.0, 0.24, 0.70, alpha * 0.82)
	var white := Color(1.0, 0.97, 1.0, alpha * (0.70 + pulse * 0.20))
	var size := 11.0 * scale
	target.call("draw_circle", center, size + 3.0 * scale, Color(0.05, 0.02, 0.12, alpha * 0.24), true)
	target.call("draw_arc", center, size + 3.0 * scale, -0.75, 1.9, 12, Color(0.42, 0.90, 1.0, alpha * 0.72), 1.2, true)
	target.call("draw_arc", center, size + 3.0 * scale, 2.25, 4.55, 12, Color(1.0, 0.24, 0.68, alpha * 0.66), 1.2, true)
	match step_index:
		0:
			var bubble := Rect2(center + Vector2(-size * 0.78, -size * 0.48), Vector2(size * 1.56, size * 0.98))
			target.call("draw_rect", bubble, Color(0.15, 0.08, 0.22, alpha * 0.78), true)
			target.call("draw_rect", bubble, white, false, 1.2, true)
			target.call("draw_colored_polygon", PackedVector2Array([center + Vector2(-size * 0.25, size * 0.45), center + Vector2(-size * 0.60, size * 0.92), center + Vector2(0.10 * size, size * 0.45)]), white)
			for i in range(3):
				target.call("draw_circle", center + Vector2(-size * 0.45 + float(i) * size * 0.45, 0.0), 1.0 * scale, cyan if i != 1 else pink, true)
		1:
			var pad := Rect2(center + Vector2(-size * 0.82, -size * 0.62), Vector2(size * 1.64, size * 1.24))
			target.call("draw_rect", pad, Color(0.13, 0.08, 0.22, alpha * 0.78), true)
			target.call("draw_rect", pad, white, false, 1.2, true)
			target.call("draw_line", center + Vector2(-size * 0.45, 0.0), center + Vector2(size * 0.45, 0.0), cyan, 1.5 * scale, true)
			target.call("draw_line", center + Vector2(0.0, -size * 0.45), center + Vector2(0.0, size * 0.45), cyan, 1.5 * scale, true)
			target.call("draw_circle", center + Vector2(size * 0.43, -size * 0.28), 1.8 * scale, pink, true)
			target.call("draw_circle", center + Vector2(size * 0.43, size * 0.30), 1.8 * scale, white, true)
		2:
			target.call("draw_line", center + Vector2(size * 0.15, -size * 0.75), center + Vector2(size * 0.15, size * 0.35), white, 1.5 * scale, true)
			target.call("draw_line", center + Vector2(size * 0.15, -size * 0.75), center + Vector2(size * 0.64, -size * 0.62), pink, 1.5 * scale, true)
			target.call("draw_circle", center + Vector2(-size * 0.14, size * 0.48), size * 0.30, cyan, true)
			target.call("draw_circle", center + Vector2(size * 0.16, size * 0.48), size * 0.30, pink, true)
			target.call("draw_arc", center + Vector2(-size * 0.10, -size * 0.05), size * 0.72, -1.30, -0.55, 6, white, 1.0 * scale, true)
		3:
			target.call("draw_line", center + Vector2(-size * 0.64, size * 0.54), center + Vector2(size * 0.52, -size * 0.58), cyan, 2.0 * scale, true)
			target.call("draw_line", center + Vector2(-size * 0.50, size * 0.72), center + Vector2(size * 0.67, -size * 0.42), pink, 1.0 * scale, true)
			target.call("draw_line", center + Vector2(-size * 0.74, size * 0.70), center + Vector2(-size * 0.34, size * 0.95), white, 1.2 * scale, true)
			target.call("draw_rect", Rect2(center + Vector2(size * 0.38, -size * 0.78), Vector2(size * 0.34, size * 0.22)), outline, true)
	if completed:
		var check := center + Vector2(size * 0.68, size * 0.72)
		target.call("draw_line", check + Vector2(-3.0, 0.0) * scale, check + Vector2(-0.5, 2.5) * scale, Color(0.72, 1.0, 0.88, alpha * 0.90), 1.5 * scale, true)
		target.call("draw_line", check + Vector2(-0.5, 2.5) * scale, check + Vector2(4.0, -3.0) * scale, Color(0.72, 1.0, 0.88, alpha * 0.90), 1.5 * scale, true)

static func _draw_all_genre_rush_warning(target: Node, active: Dictionary, arena: Rect2, timer: float, foreground: bool) -> void:
	var payload: Dictionary = active.get("payload", {}) as Dictionary
	var duration := maxf(0.01, float(payload.get("telegraph", 1.2)))
	var remaining := clampf(timer, 0.0, duration)
	var progress := clampf(1.0 - remaining / duration, 0.0, 1.0)
	var sync_remaining := clampf(ALL_GENRE_RUSH_SYNC_CUE_DURATION - (duration - remaining), 0.0, ALL_GENRE_RUSH_SYNC_CUE_DURATION)
	var sync_fade := sync_remaining / ALL_GENRE_RUSH_SYNC_CUE_DURATION
	var boss_center := _boss_origin(target, arena)
	var boss_radius := _all_genre_rush_boss_radius(target)
	var pip_centers := _all_genre_rush_pip_centers(target, arena)
	var serial := int(active.get("serial", 0))
	var foreground_rate := 0.82 if foreground else 1.0
	for i in range(ALL_GENRE_RUSH_STEP_COUNT):
		var first_strength := 0.86 if i == 0 else 0.22
		var pip_alpha := foreground_rate * first_strength * (0.74 + progress * 0.26)
		var pulse := 0.5 + 0.5 * sin(float(serial) * 0.37 + float(i) * 1.7 + progress * TAU * 1.6)
		var pip_scale := 1.0 + (0.10 + pulse * 0.05) * (1.0 if i == 0 else 0.35)
		_draw_all_genre_rush_icon(target, pip_centers[i], i, pip_alpha, pip_scale, pulse, false)
		if not foreground:
			target.call("draw_line", pip_centers[i] + Vector2(-13.0, 16.0), pip_centers[i] + Vector2(13.0, 16.0), Color(0.34, 0.86, 0.96, pip_alpha * 0.22), 1.0, true)
	if sync_fade > 0.0:
		var cue_alpha := sync_fade * (0.42 + 0.12 * sin(float(serial) * 0.61)) * foreground_rate
		var cue_radius := boss_radius + 19.0 + (1.0 - sync_fade) * 8.0
		target.call("draw_arc", boss_center, cue_radius, -1.18, 0.56, 14, Color(1.0, 0.98, 1.0, cue_alpha), 2.2 if foreground else 2.8, true)
		target.call("draw_arc", boss_center, cue_radius + 4.0, 1.72, 3.82, 13, Color(0.24, 0.92, 1.0, cue_alpha * 0.82), 1.5, true)
		target.call("draw_arc", boss_center, cue_radius + 7.0, 4.10, 5.52, 13, Color(1.0, 0.22, 0.70, cue_alpha * 0.74), 1.3, true)
		var glitch_offset := Vector2(sin(float(serial) * 2.7) * 7.0, cos(float(serial) * 1.9) * 5.0)
		target.call("draw_rect", Rect2(boss_center + glitch_offset + Vector2(-18.0, -boss_radius - 7.0), Vector2(11.0, 2.0)), Color(0.82, 0.98, 1.0, cue_alpha * 0.76), true)
		target.call("draw_rect", Rect2(boss_center - glitch_offset + Vector2(8.0, boss_radius + 5.0), Vector2(14.0, 2.0)), Color(1.0, 0.26, 0.70, cue_alpha * 0.70), true)

static func _draw_all_genre_rush_step_cue(target: Node, active: Dictionary, arena: Rect2, foreground: bool) -> void:
	if String(active.get("id", "")) != "all_genre_rush":
		return
	var state := String(active.get("state", AttackSystemScript.STATE_IDLE))
	var current_step := int(active.get("allGenreRushStepIndex", -1))
	var completed_mask := int(active.get("allGenreRushCompletedMask", 0))
	if current_step < 0:
		return
	var pip_centers := _all_genre_rush_pip_centers(target, arena)
	var elapsed := float(active.get("elapsed", 0.0))
	var cue_fade := 0.0
	if state == AttackSystemScript.STATE_ACTIVE and current_step < ALL_GENRE_RUSH_STEP_COUNT:
		var step_elapsed := maxf(0.0, elapsed - float(ALL_GENRE_RUSH_STEP_OFFSETS[current_step]))
		cue_fade = 1.0 - clampf(step_elapsed / ALL_GENRE_RUSH_STEP_CUE_DURATION, 0.0, 1.0)
	var foreground_rate := 0.78 if foreground else 1.0
	for i in range(ALL_GENRE_RUSH_STEP_COUNT):
		var is_current := state == AttackSystemScript.STATE_ACTIVE and i == current_step
		var is_completed := (i < current_step) or (state == AttackSystemScript.STATE_RECOVERY and (completed_mask & (1 << i)) != 0)
		var alpha := 0.14 if i > current_step else 0.25
		if is_current:
			alpha = 0.82 + cue_fade * 0.12
		alpha *= foreground_rate
		var pulse := 0.5 + 0.5 * sin(elapsed * 7.0 + float(i) * 1.4)
		var scale := 1.0 + (0.14 + pulse * 0.08) * (1.0 if is_current else 0.20)
		_draw_all_genre_rush_icon(target, pip_centers[i], i, alpha, scale, pulse, is_completed)
		if is_current and cue_fade > 0.0:
			var cue_radius := 15.0 + (1.0 - cue_fade) * 7.0
			target.call("draw_arc", pip_centers[i], cue_radius, -1.2, 1.15, 9, Color(1.0, 0.98, 1.0, cue_fade * 0.62 * foreground_rate), 1.4, true)

static func _collab_break_visual_hash(seed: float, salt: float) -> float:
	return fposmod(sin(seed * 31.173 + salt * 17.719) * 43758.5453, 1.0)

static func _draw_collab_break_warning(target: Node, active: Dictionary, arena: Rect2, timer: float, foreground: bool) -> void:
	var duration := maxf(0.01, float(active.get("collabBreakCoreWarningDuration", (active.get("payload", {}) as Dictionary).get("telegraph", 1.0))))
	var remaining := clampf(timer, 0.0, duration)
	var progress := clampf(1.0 - remaining / duration, 0.0, 1.0)
	var late := smoothstep(0.72, 1.0, progress)
	var core_pos := Vector2(active.get("collabBreakCorePosition", MovementSystemScript.marker_world_position(target, "CollabModule", arena)))
	var boss_pos := MovementSystemScript.marker_world_position(target, "CollabModule", arena)
	var seed := float(active.get("collabBreakCoreVisualSeed", 0.0))
	var alpha := (0.34 + progress * 0.24 + late * 0.16) if not foreground else (0.48 + progress * 0.18)
	if not foreground:
		# The only pre-spawn location shown is the authoritative fixed core
		# marker.  Sidecar positions remain deliberately undisclosed.
		for ring_index in range(3):
			var ring_radius := 29.0 + float(ring_index) * 5.0
			var start := seed * TAU + float(ring_index) * 1.87 + progress * 0.34
			var gap := 0.70 + float(ring_index % 2) * 0.20
			target.call("draw_arc", core_pos, ring_radius, start, start + 1.65, 16, Color(0.55, 0.23, 0.68, alpha * (0.78 - float(ring_index) * 0.14)), 1.8, true)
			target.call("draw_arc", core_pos, ring_radius, start + 2.05 + gap, start + 3.12, 11, Color(0.94, 0.42, 0.84, alpha * (0.72 - float(ring_index) * 0.12)), 1.5, true)
		for i in range(4):
			var pip_angle := seed * TAU + float(i) * TAU / 4.0
			var pip_pos := boss_pos + Vector2.from_angle(pip_angle) * 108.0
			var pip_size := 7.0 + late * 2.0
			target.call("draw_rect", Rect2(pip_pos - Vector2(pip_size, 2.0), Vector2(pip_size * 2.0, 4.0)), Color(0.49, 0.20, 0.64, alpha * 0.68), true)
			target.call("draw_line", pip_pos - Vector2(0.0, 3.0), pip_pos + Vector2(0.0, 3.0), Color(0.96, 0.78, 1.0, alpha * 0.66), 1.0, true)
		if progress < 0.32:
			var signal_dir := core_pos - boss_pos
			if signal_dir.length_squared() > 0.01:
				signal_dir = signal_dir.normalized()
				var signal_side := Vector2(-signal_dir.y, signal_dir.x)
				for i in range(3):
					var signal_pos := boss_pos.lerp(core_pos, 0.18 + float(i) * 0.18)
					target.call("draw_line", signal_pos - signal_side * 4.0, signal_pos + signal_side * 4.0, Color(0.78, 0.50, 0.90, alpha * (0.54 - progress)), 1.2, true)
	else:
		var core_alpha := clampf(alpha * 1.50, 0.0, 0.86)
		target.call("draw_arc", core_pos, 31.0, seed * TAU, seed * TAU + 1.10, 12, Color(0.90, 0.62, 0.96, core_alpha), 1.6, true)
		target.call("draw_arc", core_pos, 36.0, seed * TAU + 2.20, seed * TAU + 3.18, 10, Color(0.48, 0.18, 0.62, core_alpha), 1.6, true)
		target.call("draw_arc", core_pos, 43.0, seed * TAU + 0.38, seed * TAU + 1.22, 12, Color(0.78, 0.92, 1.0, core_alpha * 0.78), 1.5, true)
		target.call("draw_arc", core_pos, 43.0, seed * TAU + PI + 0.42, seed * TAU + PI + 1.22, 12, Color(1.0, 0.64, 0.88, core_alpha * 0.76), 1.5, true)
		target.call("draw_circle", core_pos, 2.6, Color(1.0, 0.92, 1.0, core_alpha * 0.62), true)
		# The back-pass cue is intentionally allowed to sit under the boss.  A
		# compact copy of the four abstract pips is kept here so the warning
		# remains legible after the boss body/overlay is drawn; it does not expose
		# any sidecar location or gameplay count.
		for i in range(4):
			var pip_angle := seed * TAU + float(i) * TAU / 4.0
			var pip_pos := boss_pos + Vector2.from_angle(pip_angle) * 108.0
			var pip_size := 10.0 + late * 2.0
			target.call("draw_rect", Rect2(pip_pos - Vector2(pip_size, 3.0), Vector2(pip_size * 2.0, 6.0)), Color(0.29, 0.08, 0.40, core_alpha * 0.82), true)
			target.call("draw_rect", Rect2(pip_pos - Vector2(pip_size, 3.0), Vector2(pip_size * 2.0, 6.0)), Color(0.94, 0.66, 1.0, core_alpha * 0.72), false, 1.1, true)
			target.call("draw_line", pip_pos - Vector2(0.0, 4.5), pip_pos + Vector2(0.0, 4.5), Color(1.0, 0.90, 1.0, core_alpha * 0.92), 1.0, true)
		if late > 0.0:
			target.call("draw_circle", core_pos, 3.0 + late * 1.5, Color(1.0, 0.92, 1.0, alpha * (0.42 + late * 0.28)), true)

static func _draw_collab_break_visual_effects(target: Node, runtime: Dictionary) -> void:
	var effects: Array = runtime.get("collab_break_visual_effects", []) as Array
	for item in effects:
		var effect: Dictionary = item as Dictionary
		var life := maxf(0.0, float(effect.get("life", 0.0)))
		var max_life := maxf(0.01, float(effect.get("maxLife", COLLAB_BREAK_CORE_FX_DURATION)))
		if life <= 0.0:
			continue
		var fade := clampf(life / max_life, 0.0, 1.0)
		var progress := 1.0 - fade
		var pos := Vector2(effect.get("pos", Vector2.ZERO))
		var seed := float(effect.get("visualSeed", 0.0))
		var kind := String(effect.get("kind", ""))
		if kind == "collab_break_sidecar_spawn":
			target.call("draw_arc", pos, 22.0 + progress * 4.0, seed * TAU, seed * TAU + 1.44, 14, Color(0.75, 0.30, 0.88, 0.64 * fade), 1.6, true)
			target.call("draw_arc", pos, 26.0 + progress * 4.0, seed * TAU + 2.20, seed * TAU + 3.24, 10, Color(0.96, 0.42, 0.82, 0.52 * fade), 1.3, true)
			for i in range(3):
				var block_pos := pos + Vector2(-9.0 + float(i) * 9.0, -6.0 + float(i % 2) * 10.0)
				target.call("draw_rect", Rect2(block_pos, Vector2(5.0 + float(i), 2.0)), Color(0.20, 0.06, 0.28, 0.68 * fade), true)
		else:
			var radius := 28.0 + progress * 17.0
			target.call("draw_arc", pos, radius, seed * TAU, seed * TAU + 1.52, 16, Color(0.58, 0.22, 0.72, 0.70 * fade), 2.0, true)
			target.call("draw_arc", pos, radius + 5.0, seed * TAU + PI, seed * TAU + PI + 1.20, 12, Color(0.92, 0.76, 1.0, 0.48 * fade), 1.3, true)
			for i in range(4):
				var angle := seed * TAU + float(i) * TAU / 4.0 + progress * 0.35
				var fragment_pos := pos + Vector2.from_angle(angle) * (12.0 + progress * 24.0)
				target.call("draw_rect", Rect2(fragment_pos - Vector2(3.0, 1.2), Vector2(6.0, 2.4)), Color(0.86, 0.48, 0.92, 0.62 * fade), true)
			if kind == "collab_break_destroy_fx":
				target.call("draw_line", pos + Vector2(-16.0, -16.0), pos + Vector2(16.0, 16.0), Color(1.0, 0.84, 1.0, 0.74 * fade), 1.8, true)
				target.call("draw_line", pos + Vector2(-16.0, 16.0), pos + Vector2(16.0, -16.0), Color(0.72, 0.36, 0.88, 0.70 * fade), 1.6, true)
			elif kind == "collab_break_timeout_fx":
				target.call("draw_line", pos + Vector2(-11.0, 0.0), pos + Vector2(11.0, 0.0), Color(0.74, 0.62, 0.84, 0.44 * fade), 1.2, true)
			else:
				# Restore is deliberately a small endpoint-local reconnect pulse,
				# not a long tether or a second hazard indication.
				target.call("draw_arc", pos, 18.0 + progress * 7.0, seed * TAU, seed * TAU + 1.18, 12, Color(0.54, 0.90, 1.0, 0.58 * fade), 1.4, true)
				target.call("draw_line", pos + Vector2(-10.0, 2.0), pos + Vector2(-2.0, -4.0), Color(0.92, 0.98, 1.0, 0.62 * fade), 1.4, true)
				target.call("draw_line", pos + Vector2(3.0, -4.0), pos + Vector2(11.0, 2.0), Color(0.72, 0.94, 1.0, 0.54 * fade), 1.2, true)

static func _long_comment_line_visual_hash(seed: float, salt: float) -> float:
	return fposmod(sin(seed * 91.173 + salt * 37.319) * 43758.5453, 1.0)

static func _long_comment_line_lane_y(arena: Rect2, line_index: int) -> float:
	return arena.position.y + arena.size.y * (0.24 + float(line_index) * 0.26)

static func _draw_long_comment_line_warning(target: Node, active: Dictionary, arena: Rect2, timer: float, foreground: bool) -> void:
	var payload: Dictionary = active.get("payload", {}) as Dictionary
	var duration := maxf(0.01, float(payload.get("telegraph", 1.0)))
	var remaining := clampf(timer, 0.0, duration)
	var progress := clampf(1.0 - remaining / duration, 0.0, 1.0)
	var late := smoothstep(0.82, 1.0, progress)
	var serial := float(active.get("serial", 0))
	if foreground:
		# Only a short local rim is brought in front of sprites.  The full
		# corridor remains in the back pass so the player can still be read.
		var player_pos := Vector2(target.get("player_pos"))
		for i in range(3):
			var y := _long_comment_line_lane_y(arena, i)
			if absf(player_pos.y - y) <= 62.0:
				var from_pos := Vector2(maxf(arena.position.x, player_pos.x - 94.0), y)
				var to_pos := Vector2(minf(arena.end.x, player_pos.x + 94.0), y)
				if to_pos.x > from_pos.x:
					_draw_long_comment_line_local_foreground(target, from_pos, to_pos, i, _long_comment_line_visual_hash(serial, float(i) + 0.41), progress, false)
		return
	for i in range(3):
		var y := _long_comment_line_lane_y(arena, i)
		var from_pos := Vector2(arena.position.x, y)
		var to_pos := Vector2(arena.end.x, y)
		_draw_long_comment_line_lane(target, from_pos, to_pos, i, _long_comment_line_visual_hash(serial, float(i) + 0.41), progress, duration - remaining, false)
	_draw_long_comment_line_boss_cue(target, active, arena, false)

static func _draw_long_comment_line_boss_cue(target: Node, active: Dictionary, arena: Rect2, foreground: bool) -> void:
	var payload: Dictionary = active.get("payload", {}) as Dictionary
	var duration := maxf(0.01, float(payload.get("telegraph", 1.0)))
	var elapsed := clampf(duration - float(active.get("timer", 0.0)), 0.0, duration)
	if elapsed > 0.20:
		return
	var fade := 1.0 - clampf(elapsed / 0.20, 0.0, 1.0)
	var serial := float(active.get("serial", 0))
	var seed := _long_comment_line_visual_hash(serial, 7.0)
	var boss_pos := _boss_origin(target, arena)
	var alpha := fade * (0.48 if foreground else 0.66)
	# Small comment blocks sit beside the boss silhouette; this is not a
	# center banner or a long causal line.
	var offsets := [Vector2(-28.0, -30.0), Vector2(3.0, -42.0), Vector2(28.0, -25.0)]
	for i in range(offsets.size()):
		var center: Vector2 = boss_pos + offsets[i]
		var width := 13.0 + _long_comment_line_visual_hash(seed, float(i) + 1.0) * 12.0
		var color := Color(0.82, 0.68, 0.95, alpha * (0.70 if i != 1 else 0.92)) if i != 1 else Color(1.0, 0.52, 0.78, alpha * 0.78)
		target.call("draw_line", center - Vector2(width * 0.5, 0.0), center + Vector2(width * 0.5, 0.0), color, 1.8 if not foreground else 1.2, true)
	if not foreground:
		target.call("draw_circle", boss_pos + Vector2(0.0, -48.0), 1.7 + fade * 1.2, Color(1.0, 0.96, 1.0, alpha * 0.72), true)
		for i in range(3):
			var dot := boss_pos + Vector2(-5.0 + float(i) * 5.0, -52.0)
			target.call("draw_circle", dot, 1.2, Color(1.0, 0.82, 0.92, alpha * 0.52), true)
	else:
		target.call("draw_line", boss_pos + Vector2(-8.0, -48.0), boss_pos + Vector2(8.0, -48.0), Color(1.0, 0.96, 1.0, alpha * 0.48), 1.0, true)

static func _draw_long_comment_line_lane(target: Node, from_pos: Vector2, to_pos: Vector2, line_index: int, seed: float, progress: float, visual_time: float, active_mode: bool) -> void:
	var segment := to_pos - from_pos
	var lane_length := segment.length()
	if lane_length <= 0.1:
		return
	var direction := segment / lane_length
	var normal := Vector2(-direction.y, direction.x)
	var strength := 1.0 if active_mode else (0.58 + progress * 0.20)
	var late := smoothstep(0.82, 1.0, progress)
	# Warning rails remain deliberately lighter than active, but must still be
	# readable from the first frame against the pale relay paper background.
	var rail_alpha := (0.84 if active_mode else 0.72) * strength
	var rail_width := LONG_COMMENT_LINE_RAIL_WIDTH
	# Rail center = 18px - half the stroke, so the visible outer edge is the
	# same +/-18px as the collision threshold.
	target.call("draw_line", from_pos, to_pos, Color(0.16, 0.03, 0.20, (0.075 if active_mode else 0.035) * strength), 36.0, true)
	target.call("draw_line", from_pos, to_pos, Color(0.84, 0.73, 0.94, (0.34 if active_mode else 0.095) * strength), 18.0, true)
	target.call("draw_line", from_pos + normal * 7.2, to_pos + normal * 7.2, Color(1.0, 0.54, 0.78, (0.28 if active_mode else 0.075) * strength), 1.0, true)
	target.call("draw_line", from_pos - normal * 7.2, to_pos - normal * 7.2, Color(1.0, 0.54, 0.78, (0.28 if active_mode else 0.075) * strength), 1.0, true)
	var rail_center_offset := LONG_COMMENT_LINE_COLLISION_HALF_WIDTH - rail_width * 0.5
	var inner_offset := rail_center_offset - 1.18
	for side_index in range(2):
		var side: float = -1.0 if side_index == 0 else 1.0
		var rail_from: Vector2 = from_pos + normal * rail_center_offset * side
		var rail_to: Vector2 = to_pos + normal * rail_center_offset * side
		target.call("draw_line", rail_from, rail_to, Color(0.34, 0.03, 0.25, rail_alpha), rail_width, true)
		var highlight_from: Vector2 = from_pos + normal * inner_offset * side
		var highlight_to: Vector2 = to_pos + normal * inner_offset * side
		target.call("draw_line", highlight_from, highlight_to, Color(1.0, 0.78, 0.90, rail_alpha * 0.74), 1.0, true)
	if late > 0.0:
		var pulse_alpha := sin(late * PI) * (0.18 if active_mode else 0.12)
		for side_index in range(2):
			var side: float = -1.0 if side_index == 0 else 1.0
			var pulse_from: Vector2 = from_pos + normal * (rail_center_offset * side)
			var pulse_to: Vector2 = to_pos + normal * (rail_center_offset * side)
			target.call("draw_line", pulse_from, pulse_to, Color(1.0, 0.88, 0.96, pulse_alpha), 1.0, true)
	# Only comment internals scroll; the rail/corridor geometry never moves.
	var speed := (190.0 + float(line_index) * 9.0) if active_mode else (30.0 + float(line_index) * 2.5)
	var pitch := 96.0 + _long_comment_line_visual_hash(seed, 11.0) * 22.0
	var shift := fposmod(seed * pitch - visual_time * speed, pitch)
	var x := from_pos.x - pitch + shift
	var block_index := 0
	while x <= to_pos.x:
		var block_length := 20.0 + _long_comment_line_visual_hash(seed, 20.0 + float(block_index)) * 28.0
		var clipped_length := minf(block_length, to_pos.x - x)
		if clipped_length > 2.0:
			var block_y := from_pos.y + (_long_comment_line_visual_hash(seed, 50.0 + float(block_index)) - 0.5) * 5.5
			var block_alpha := (0.62 if active_mode else 0.34) * strength
			target.call("draw_rect", Rect2(x, block_y - 1.1, clipped_length, 2.2), Color(1.0, 0.88, 0.95, block_alpha), true)
			if block_index % 3 == (line_index + 1) % 3 and (active_mode or progress > 0.30):
				for dot_index in range(3):
					var dot_x := x + 5.0 + float(dot_index) * 5.0
					if dot_x < to_pos.x - 1.0:
						target.call("draw_circle", Vector2(dot_x, from_pos.y + 3.6), 1.25, Color(1.0, 0.95, 1.0, block_alpha * 0.84), true)
			if block_index % 4 == (line_index + 2) % 4 and clipped_length > 14.0:
				var tail_x := x + clipped_length - 5.0
				target.call("draw_line", Vector2(tail_x, from_pos.y - 3.4), Vector2(tail_x + 5.0, from_pos.y - 5.3), Color(1.0, 0.58, 0.80, block_alpha * 0.72), 1.0, true)
		x += pitch
		block_index += 1
		if block_index > 64:
			break
	# Tiny cyan corruption blocks stay inside the central strip.
	for i in range(2):
		var glitch_x := from_pos.x + fposmod(seed * (83.0 + float(i) * 31.0) + visual_time * speed * 0.35, lane_length)
		var glitch_y := from_pos.y + (-3.4 if i == 0 else 3.6)
		var glitch_alpha := (0.36 if active_mode else 0.12) * strength
		target.call("draw_rect", Rect2(glitch_x, glitch_y, 4.0 + float(i) * 2.0, 1.0), Color(0.38, 0.92, 1.0, glitch_alpha), true)

static func _draw_long_comment_line_active(target: Node, hazard: Dictionary) -> void:
	var from_pos := Vector2(hazard.get("from", Vector2.ZERO))
	var to_pos := Vector2(hazard.get("to", from_pos))
	var max_time := maxf(0.01, float(hazard.get("maxTime", 0.6)))
	var remaining := clampf(float(hazard.get("time", 0.0)), 0.0, max_time)
	var elapsed := max_time - remaining
	var line_index := int(hazard.get("longCommentLineIndex", 0))
	var seed := float(hazard.get("longCommentLineVisualSeed", 0.0))
	_draw_long_comment_line_lane(target, from_pos, to_pos, line_index, seed, elapsed / max_time, elapsed, true)

static func _draw_long_comment_line_local_foreground(target: Node, from_pos: Vector2, to_pos: Vector2, line_index: int, seed: float, progress: float, active_mode: bool) -> void:
	var segment := to_pos - from_pos
	if segment.length_squared() <= 0.01:
		return
	var direction := segment.normalized()
	var normal := Vector2(-direction.y, direction.x)
	var rail_offset := LONG_COMMENT_LINE_COLLISION_HALF_WIDTH - 0.8
	var alpha := 0.54 if active_mode else 0.38 + progress * 0.08
	for side_index in range(2):
		var side: float = -1.0 if side_index == 0 else 1.0
		var rail_from: Vector2 = from_pos + normal * rail_offset * side
		var rail_to: Vector2 = to_pos + normal * rail_offset * side
		target.call("draw_line", rail_from, rail_to, Color(0.40, 0.03, 0.28, alpha), 1.6, true)
		target.call("draw_line", rail_from - normal * 0.9 * side, rail_to - normal * 0.9 * side, Color(1.0, 0.82, 0.92, alpha * 0.62), 0.75, true)
	var center := (from_pos + to_pos) * 0.5
	var block_shift := fposmod(seed * 17.0 - progress * 38.0, 42.0) - 21.0
	var block_center := center + direction * block_shift + normal * ((_long_comment_line_visual_hash(seed, 91.0 + float(line_index)) - 0.5) * 5.0)
	target.call("draw_line", block_center - direction * 11.0, block_center + direction * 11.0, Color(1.0, 0.90, 0.96, alpha * 0.62), 1.5, true)

static func _draw_long_comment_line_foreground(target: Node, hazard: Dictionary) -> void:
	var from_pos := Vector2(hazard.get("from", Vector2.ZERO))
	var to_pos := Vector2(hazard.get("to", from_pos))
	var segment := to_pos - from_pos
	if segment.length_squared() <= 0.01:
		return
	var player_pos := Vector2(target.get("player_pos"))
	var ratio := clampf((player_pos - from_pos).dot(segment) / segment.length_squared(), 0.0, 1.0)
	var closest := from_pos + segment * ratio
	if closest.distance_to(player_pos) > 64.0:
		return
	var local_from := from_pos + segment * clampf(ratio - 0.10, 0.0, 1.0)
	var local_to := from_pos + segment * clampf(ratio + 0.10, 0.0, 1.0)
	_draw_long_comment_line_local_foreground(target, local_from, local_to, int(hazard.get("longCommentLineIndex", 0)), float(hazard.get("longCommentLineVisualSeed", 0.0)) + 0.19, 0.74, true)

static func _draw_long_comment_line_visual_effects(target: Node, runtime: Dictionary) -> void:
	for item in runtime.get("long_comment_line_visual_effects", []) as Array:
		var effect: Dictionary = item as Dictionary
		if String(effect.get("kind", "")) != "long_comment_line_hit":
			continue
		var max_life := maxf(0.01, float(effect.get("maxLife", LONG_COMMENT_LINE_HIT_FX_DURATION)))
		var life := clampf(float(effect.get("life", 0.0)), 0.0, max_life)
		if life <= 0.0:
			continue
		var fade := life / max_life
		var progress := 1.0 - fade
		var pos := Vector2(effect.get("pos", Vector2.ZERO))
		var seed := float(effect.get("visualSeed", 0.0))
		var base := pos + Vector2(-progress * 34.0, 0.0)
		var alpha := fade * 0.82
		# The darker first pass keeps the local hit mark legible on the pale
		# relay paper; the short white core still reads as a comment-strip tear.
		target.call("draw_line", base - Vector2(24.0, 0.0), base + Vector2(20.0, 0.0), Color(0.64, 0.04, 0.30, alpha * 0.82), 2.8, true)
		target.call("draw_line", base - Vector2(21.0, -0.2), base + Vector2(17.0, -0.2), Color(1.0, 0.90, 0.96, alpha * 0.78), 1.0, true)
		target.call("draw_line", base - Vector2(15.0, 4.0), base + Vector2(6.0, 4.0), Color(0.98, 0.28, 0.64, alpha * 0.72), 1.6, true)
		for i in range(3):
			var dot_pos := base + Vector2(-4.0 + float(i) * 5.0, 5.0)
			target.call("draw_circle", dot_pos, 1.25, Color(1.0, 0.96, 1.0, alpha * 0.84), true)
		for i in range(2):
			var glitch_pos := base + Vector2(10.0 + float(i) * 7.0, -5.0 + float(i) * 4.0)
			target.call("draw_rect", Rect2(glitch_pos, Vector2(5.0 + float(i) * 2.0, 1.4)), Color(0.35, 0.90, 1.0, alpha * 0.54), true)
		var fragment_dir := Vector2.from_angle(seed * TAU + 0.5)
		target.call("draw_line", pos - fragment_dir * 13.0, pos - fragment_dir * 5.0, Color(0.98, 0.34, 0.70, alpha * 0.60), 1.1, true)
		target.call("draw_circle", pos, 3.0 + sin(progress * PI) * 3.0, Color(1.0, 0.96, 1.0, alpha * 0.28), false, 1.0)

static func _kuso_maro_drop_boss_center(target: Node, arena: Rect2) -> Vector2:
	for item in target.get("enemies") as Array:
		var enemy: Dictionary = item as Dictionary
		if bool(enemy.get("relayBoss", false)) or String(enemy.get("bossId", "")) == "last_offline" or String(enemy.get("kind", "")) == "last_offline":
			return Vector2(enemy.get("pos", arena.get_center()))
	return MovementSystemScript.marker_world_position(target, "CoreCenter", arena)

static func _kuso_maro_drop_boss_radius(target: Node) -> float:
	for item in target.get("enemies") as Array:
		var enemy: Dictionary = item as Dictionary
		if bool(enemy.get("relayBoss", false)) or String(enemy.get("bossId", "")) == "last_offline" or String(enemy.get("kind", "")) == "last_offline":
			return maxf(80.0, float(enemy.get("radius", 105.0)))
	return 105.0

static func _kuso_maro_drop_pip_centers(boss_center: Vector2, boss_radius: float) -> Array:
	# Keep the four readable cues just below/around the boss silhouette.  The
	# relay final-boss HUD occupies the upper part of the arena, so a top-only
	# layout would be covered before the warning can be read.
	var layout_radius := clampf(boss_radius * 1.55, 170.0, 210.0)
	var side_offset := clampf(boss_radius * 0.60, 58.0, 78.0)
	var lower_offset := clampf(boss_radius * 1.34, 142.0, 178.0)
	return [
		boss_center + Vector2(-layout_radius, side_offset),
		boss_center + Vector2(-layout_radius * 0.34, lower_offset),
		boss_center + Vector2(layout_radius * 0.34, lower_offset),
		boss_center + Vector2(layout_radius, side_offset)
	]

static func _draw_kuso_maro_drop_warning(target: Node, active: Dictionary, arena: Rect2, timer: float, foreground: bool) -> void:
	var duration := maxf(0.01, float(active.get("kusoMaroDropWarningVisualDuration", (active.get("payload", {}) as Dictionary).get("telegraph", 1.2))))
	var remaining := clampf(timer, 0.0, duration)
	var progress := clampf(1.0 - remaining / duration, 0.0, 1.0)
	var mid := clampf((0.65 - remaining) / 0.45, 0.0, 1.0)
	var late := clampf((0.20 - remaining) / 0.20, 0.0, 1.0)
	var pulse := sin(late * PI)
	var seed := float(active.get("kusoMaroDropWarningVisualSeed", 0.0))
	var boss_center := _kuso_maro_drop_boss_center(target, arena)
	var boss_radius := _kuso_maro_drop_boss_radius(target)
	var pip_centers := _kuso_maro_drop_pip_centers(boss_center, boss_radius)
	var pip_alpha := 0.38 + mid * 0.20 + late * 0.20 + pulse * 0.10
	if not foreground:
		var halo_alpha := 0.035 + mid * 0.025 + late * 0.02
		target.call("draw_circle", boss_center + Vector2(0.0, -boss_radius * 0.42), boss_radius * 0.78, Color(1.0, 0.76, 0.88, halo_alpha), true)
		for i in range(pip_centers.size()):
			var pip: Vector2 = pip_centers[i]
			var puff_offset := Vector2(sin(seed * 5.0 + float(i) * 1.7) * 2.5, cos(seed * 3.0 + float(i) * 1.3) * 2.0)
			target.call("draw_circle", pip + puff_offset, 10.0 + mid * 2.0, Color(1.0, 0.91, 0.96, pip_alpha * 0.24), true)
			target.call("draw_arc", pip + puff_offset, 10.0 + mid * 2.0, seed + float(i) * 0.8, seed + float(i) * 0.8 + 1.9, 8, Color(0.66, 0.28, 0.54, pip_alpha * 0.34), 1.0, true)
			if mid > 0.0:
				var streak_alpha := pip_alpha * (0.30 + mid * 0.28)
				target.call("draw_line", pip + Vector2(0.0, 6.0), pip + Vector2(0.0, -12.0 - mid * 8.0), Color(1.0, 0.78, 0.90, streak_alpha), 1.1, true)
				target.call("draw_line", pip + Vector2(-5.0, -7.0), pip + Vector2(4.0, -15.0), Color(0.48, 0.16, 0.42, streak_alpha * 0.72), 1.0, true)
			if late > 0.0:
				var fragment_dir := Vector2.from_angle(seed * TAU + float(i) * 1.85)
				target.call("draw_line", pip + fragment_dir * 11.0, pip + fragment_dir * (16.0 + late * 6.0), Color(0.72, 0.25, 0.56, pip_alpha * late * 0.70), 1.0, true)
		return
	for i in range(pip_centers.size()):
		var pip: Vector2 = pip_centers[i]
		var pip_scale := 1.0 + pulse * 0.16
		var pip_radius := 7.0 * pip_scale
		target.call("draw_circle", pip, pip_radius, Color(1.0, 0.88, 0.94, pip_alpha), true)
		target.call("draw_arc", pip, pip_radius + 1.8, seed + float(i) * 0.9, seed + float(i) * 0.9 + 4.3, 12, Color(0.48, 0.13, 0.39, pip_alpha * 0.78), 1.3, true)
		target.call("draw_arc", pip, pip_radius - 2.0, seed + float(i) * 0.9 + 0.5, seed + float(i) * 0.9 + 2.2, 8, Color(1.0, 0.99, 1.0, pip_alpha * 0.72), 1.0, true)
		target.call("draw_line", pip + Vector2(-3.0, 2.0), pip + Vector2(4.0, -2.0), Color(0.72, 0.26, 0.58, pip_alpha * 0.70), 1.0, true)
		if late > 0.0:
			var flash_alpha := pulse * (0.40 + late * 0.34)
			target.call("draw_line", pip + Vector2(0.0, -pip_radius - 4.0), pip + Vector2(0.0, -pip_radius - 14.0), Color(1.0, 0.96, 1.0, flash_alpha), 1.4, true)
			target.call("draw_circle", pip, pip_radius + 4.0 + pulse * 2.0, Color(1.0, 0.80, 0.92, flash_alpha * 0.14), false, 1.0)
	if late > 0.0:
		var boss_flash := boss_center + Vector2(0.0, -boss_radius - 13.0)
		target.call("draw_line", boss_flash - Vector2(13.0, 0.0), boss_flash + Vector2(13.0, 0.0), Color(1.0, 0.96, 1.0, pulse * 0.54), 1.6, true)
		target.call("draw_line", boss_flash + Vector2(0.0, -10.0), boss_flash + Vector2(0.0, 8.0), Color(1.0, 0.76, 0.90, pulse * 0.42), 1.2, true)

static func _kuso_maro_drop_nearby_count(hazards: Array, pos: Vector2) -> int:
	var count := 0
	for item in hazards:
		var hazard: Dictionary = item as Dictionary
		if not bool(hazard.get("kusoMaroDropVisual", false)):
			continue
		if Vector2(hazard.get("pos", Vector2.ZERO)).distance_to(pos) <= 104.0:
			count += 1
	return maxi(1, count)

static func _draw_kuso_maro_shadow(target: Node, pos: Vector2, radius: float, scale_x: float, alpha: float) -> void:
	# Build the flattened shadow in world coordinates so the relay world
	# transform remains untouched for the following hazards and draw passes.
	var points := PackedVector2Array()
	for i in range(24):
		var angle := TAU * float(i) / 24.0
		points.append(pos + Vector2(cos(angle) * radius * scale_x, sin(angle) * radius * 0.46))
	target.call("draw_colored_polygon", points, Color(0.24, 0.08, 0.20, alpha))

static func _draw_kuso_maro_drop_hazard(target: Node, hazard: Dictionary, hazards: Array) -> void:
	var pos := Vector2(hazard.get("pos", Vector2.ZERO))
	var radius := maxf(1.0, float(hazard.get("radius", 52.0)))
	var max_time := maxf(0.01, float(hazard.get("maxTime", 0.65)))
	var remaining := clampf(float(hazard.get("time", 0.0)), 0.0, max_time)
	var elapsed := clampf(max_time - remaining, 0.0, max_time)
	var impact_duration := clampf(float(hazard.get("kusoMaroDropImpactDuration", 0.16)), 0.10, 0.18)
	var impact_progress := clampf(elapsed / impact_duration, 0.0, 1.0)
	var impact_eased := smoothstep(0.0, 1.0, impact_progress)
	var seed := float(hazard.get("kusoMaroDropVisualSeed", 0.0))
	var nearby_count := _kuso_maro_drop_nearby_count(hazards, pos)
	var interior_factor := 1.0 / (1.0 + float(maxi(0, nearby_count - 1)) * 0.28)
	var lifetime_factor := 0.78 + clampf(remaining / max_time, 0.0, 1.0) * 0.22
	# The fill and stain are intentionally quiet; the 52px boundary is the
	# authoritative gameplay geometry and remains undimmed in overlaps.
	target.call("draw_circle", pos, radius - 2.0, Color(1.0, 0.94, 0.82, 0.055 * interior_factor), true)
	target.call("draw_circle", pos + Vector2(0.0, 2.0), radius * 0.68, Color(1.0, 0.72, 0.82, 0.035 * interior_factor), true)
	target.call("draw_arc", pos, radius - 1.0, 0.0, TAU, 64, Color(0.28, 0.04, 0.25, 0.88 * lifetime_factor), 2.0, true)
	target.call("draw_arc", pos, radius - 2.3, 0.03, TAU - 0.03, 64, Color(1.0, 0.68, 0.82, 0.74 * lifetime_factor), 1.0, true)
	var notch := fposmod(seed * TAU * 1.7, TAU)
	for i in range(3):
		var stain_start := notch + float(i) * 2.02 + 0.14
		var stain_end := stain_start + 0.52 + float(i % 2) * 0.18
		target.call("draw_arc", pos, radius - 7.0 - float(i) * 4.0, stain_start, stain_end, 10, Color(0.65, 0.28, 0.54, 0.17 * interior_factor), 2.0, true)
	_draw_kuso_maro_shadow(target, pos + Vector2(0.0, 8.0), 14.0 - impact_eased * 2.5, 1.20 + (1.0 - impact_eased) * 0.10, 0.20 * interior_factor)
	var maro_offset := Vector2(0.0, -10.0 * (1.0 - impact_eased))
	var maro_scale := Vector2(1.12 - impact_eased * 0.12, 0.82 + impact_eased * 0.18)
	var maro_pos := pos + maro_offset
	var maro_size := Vector2(40.0, 40.0) * maro_scale
	target.call("draw_texture_rect", KUSO_MARO_PROJECTILE_TEXTURE, Rect2(maro_pos - maro_size * 0.5, maro_size), false, Color(1.0, 1.0, 1.0, 0.96))
	if impact_progress < 1.0:
		var streak_alpha := (1.0 - impact_progress) * 0.68
		target.call("draw_line", pos + Vector2(-2.0, -radius * 0.72 - (1.0 - impact_progress) * 18.0), pos + Vector2(-2.0, -radius * 0.42), Color(1.0, 0.94, 0.98, streak_alpha), 1.6, true)
		target.call("draw_line", pos + Vector2(4.0, -radius * 0.66 - (1.0 - impact_progress) * 12.0), pos + Vector2(4.0, -radius * 0.48), Color(1.0, 0.62, 0.82, streak_alpha * 0.72), 1.0, true)
	var gloss_angle := seed * TAU + 0.7
	var gloss_dir := Vector2.from_angle(gloss_angle)
	target.call("draw_line", maro_pos - gloss_dir * 5.0, maro_pos + gloss_dir * 2.0, Color(1.0, 1.0, 1.0, 0.35 * lifetime_factor), 1.0, true)

static func _draw_kuso_maro_drop_foreground(target: Node, hazard: Dictionary, arena: Rect2) -> void:
	var pos := Vector2(hazard.get("pos", Vector2.ZERO))
	var player_pos := Vector2(target.get("player_pos"))
	var distance := player_pos.distance_to(pos)
	if distance > 116.0:
		return
	var direction := (player_pos - pos).normalized()
	if direction.length_squared() <= 0.01:
		direction = Vector2.UP
	var angle := direction.angle()
	var seed := float(hazard.get("kusoMaroDropVisualSeed", 0.0))
	var phase := fposmod(seed * 4.0, 1.0)
	var start := angle - 0.92 + phase * 0.18
	var end := angle + 0.92 + phase * 0.18
	target.call("draw_arc", pos, 51.0, start, end, 20, Color(0.30, 0.04, 0.27, 0.46), 2.0, true)
	target.call("draw_arc", pos, 49.7, start + 0.06, end - 0.06, 18, Color(1.0, 0.78, 0.88, 0.36), 1.0, true)
	target.call("draw_circle", pos, 2.0, Color(1.0, 0.92, 0.96, 0.32), true)

static func _draw_kuso_maro_drop_visual_effects(target: Node, runtime: Dictionary) -> void:
	for item in runtime.get("kuso_maro_drop_visual_effects", []) as Array:
		var effect: Dictionary = item as Dictionary
		var kind := String(effect.get("kind", ""))
		if not kind.begins_with("kuso_maro_drop_"):
			continue
		var max_life := maxf(0.01, float(effect.get("maxLife", 0.20)))
		var life := clampf(float(effect.get("life", 0.0)), 0.0, max_life)
		if life <= 0.0:
			continue
		var fade := life / max_life
		var progress := 1.0 - fade
		var burst := sin(clampf(progress * PI, 0.0, PI))
		var pos := Vector2(effect.get("pos", Vector2.ZERO))
		var seed := float(effect.get("visualSeed", 0.0))
		if kind == "kuso_maro_drop_impact":
			var radius := 10.0 + burst * 8.0
			target.call("draw_arc", pos, radius, seed + 0.15, seed + 2.05, 16, Color(1.0, 0.94, 0.88, 0.52 * fade), 1.5, true)
			target.call("draw_arc", pos, radius + 3.0, seed + 2.45, seed + 4.05, 13, Color(0.72, 0.48, 0.72, 0.34 * fade), 1.2, true)
			target.call("draw_circle", pos + Vector2(0.0, 1.0), 3.0 + burst * 2.0, Color(1.0, 0.88, 0.82, 0.20 * fade), true)
			for i in range(3):
				var angle := seed + float(i) * 2.1
				var direction := Vector2.from_angle(angle)
				var center := pos + direction * (11.0 + burst * 8.0)
				target.call("draw_line", center - direction * 3.0, center + direction * (4.0 + burst * 2.0), Color(0.72, 0.30, 0.60, 0.52 * fade), 1.1, true)
		elif kind == "kuso_maro_drop_hit":
			var radius := 9.0 + burst * 10.0
			target.call("draw_arc", pos, radius, seed, seed + 2.7, 18, Color(1.0, 0.96, 0.92, 0.64 * fade), 1.7, true)
			target.call("draw_arc", pos, radius + 4.0, seed + 3.0, seed + 4.9, 14, Color(0.70, 0.36, 0.66, 0.48 * fade), 1.4, true)
			for i in range(3):
				var angle := seed + 0.6 + float(i) * 2.0
				var direction := Vector2.from_angle(angle)
				var center := pos + direction * (10.0 + burst * 10.0)
				target.call("draw_line", center - direction * 4.0, center + direction * 4.0, Color(0.82, 0.50, 0.76, 0.56 * fade), 1.3, true)
			target.call("draw_circle", pos, 3.0 + burst * 3.0, Color(1.0, 0.96, 0.98, 0.18 * fade), true)

static func _draw_offline_laser_warning(target: Node, active: Dictionary, arena: Rect2, timer: float) -> void:
	if not bool(active.get("offlineLaserSnapshotValid", false)):
		return
	var origin := Vector2(active.get("offlineLaserOrigin", Vector2.ZERO))
	var direction := Vector2(active.get("offlineLaserDir", Vector2.DOWN))
	if direction.length_squared() <= 0.01:
		direction = Vector2.DOWN
	else:
		direction = direction.normalized()
	var endpoint := Vector2(active.get("offlineLaserEndpoint", origin + direction * OFFLINE_LASER_LENGTH))
	if endpoint.distance_squared_to(origin) <= 0.01:
		endpoint = origin + direction * OFFLINE_LASER_LENGTH
	var side := Vector2(-direction.y, direction.x)
	var progress := 1.0 - clampf(timer / 1.10, 0.0, 1.0)
	var late := clampf((0.18 - timer) / 0.18, 0.0, 1.0)
	var seed := float(active.get("offlineLaserVisualSeed", 0.0))
	var strength := 0.50 + late * 0.18
	# The broad corridor is deliberately only a low-alpha underlay. The two
	# rails below are the readable 52px gameplay boundary.
	target.call("draw_line", origin, endpoint, Color(0.20, 0.02, 0.18, 0.035 + late * 0.02), 52.0, true)
	target.call("draw_line", origin, endpoint, Color(0.92, 0.06, 0.36, 0.08 + late * 0.03), 34.0, true)
	_draw_offline_laser_rail(target, origin + side * OFFLINE_LASER_HIT_WIDTH, endpoint + side * OFFLINE_LASER_HIT_WIDTH, -side, strength, false)
	_draw_offline_laser_rail(target, origin - side * OFFLINE_LASER_HIT_WIDTH, endpoint - side * OFFLINE_LASER_HIT_WIDTH, side, strength, false)
	_draw_offline_laser_signal(target, origin, endpoint, side, seed, progress, false)
	_draw_offline_laser_endcaps(target, origin, endpoint, direction, strength, false)
	if arena.has_point(endpoint):
		_draw_offline_laser_endpoint(target, endpoint, direction, seed, false, late)
	_draw_offline_laser_tracking_marker(target, Vector2(active.get("offlineLaserAimPoint", endpoint)), direction, side, late, seed, arena)

static func _draw_offline_laser_rail(target: Node, from_pos: Vector2, to_pos: Vector2, inward: Vector2, strength: float, active: bool) -> void:
	var edge_alpha := (0.62 if active else 0.48) * strength
	var edge_width := 2.45 if active else 2.15
	target.call("draw_line", from_pos, to_pos, Color(0.30, 0.01, 0.22, edge_alpha), edge_width, true)
	target.call("draw_line", from_pos, to_pos, Color(0.92, 0.04, 0.35, edge_alpha * 0.70), 1.15, true)
	var inner_offset := inward.normalized() * 1.15
	target.call("draw_line", from_pos + inner_offset, to_pos + inner_offset, Color(1.0, 0.72, 0.88, edge_alpha * 0.72), 0.95, true)

static func _draw_offline_laser_signal(target: Node, from_pos: Vector2, to_pos: Vector2, side: Vector2, seed: float, progress: float, active: bool) -> void:
	var segment := to_pos - from_pos
	var length := segment.length()
	if length <= 0.1:
		return
	var direction := segment / length
	var gap_start := 0.36 + fposmod(seed * 0.19, 0.12)
	var gap_size := 0.055 if active else 0.038
	var gap_end := minf(0.92, gap_start + gap_size)
	var first_end := from_pos + segment * gap_start
	var second_start := from_pos + segment * gap_end
	var core_alpha := (0.76 if active else 0.52) + progress * (0.12 if active else 0.08)
	target.call("draw_line", from_pos, first_end, Color(0.42, 0.98, 1.0, core_alpha), 2.8 if active else 2.25, true)
	target.call("draw_line", second_start, to_pos, Color(0.94, 0.98, 1.0, core_alpha * 0.88), 2.4 if active else 1.95, true)
	var crack_center := from_pos + segment * ((gap_start + gap_end) * 0.5)
	target.call("draw_line", crack_center - side * (3.0 if active else 2.0), crack_center + side * (3.0 if active else 2.0), Color(1.0, 0.35, 0.70, core_alpha * 0.78), 1.25, true)
	var fragment_count := 3 if active else 2
	for i in range(fragment_count):
		var t := fposmod(seed * 0.73 + float(i) * 0.29 + progress * (0.22 if active else 0.08), 0.86) + 0.07
		var center := from_pos + segment * t
		var half_length := 5.0 + float(i % 2) * 2.0
		var offset := side * ((-1.0 if i % 2 == 0 else 1.0) * (2.0 + float(i)))
		target.call("draw_line", center - direction * half_length + offset, center + direction * half_length + offset, Color(0.32, 0.91, 1.0, core_alpha * 0.58), 1.15, true)

static func _draw_offline_laser_tracking_marker(target: Node, aim_point: Vector2, direction: Vector2, side: Vector2, late: float, seed: float, arena: Rect2) -> void:
	if not arena.grow(48.0).has_point(aim_point):
		return
	var pulse := 0.65 + 0.35 * sin(seed * TAU + late * TAU * 2.0)
	var along := direction * 8.0
	var rail_span := side * 9.0
	var color := Color(0.35, 0.96, 1.0, 0.48 + late * 0.18)
	target.call("draw_line", aim_point - along - rail_span, aim_point - along + rail_span, color, 1.4, true)
	target.call("draw_line", aim_point + along - rail_span, aim_point + along + rail_span, color, 1.4, true)
	target.call("draw_line", aim_point - rail_span * 0.72, aim_point + rail_span * 0.72, Color(1.0, 0.38, 0.70, 0.32 + late * 0.16), 1.1, true)
	target.call("draw_circle", aim_point - direction * 12.0, 2.2 + late * 1.0, Color(1.0, 0.74, 0.90, 0.55 * pulse), true)
	target.call("draw_circle", aim_point + direction * 12.0, 1.8 + late * 0.8, Color(1.0, 0.26, 0.62, 0.46 * pulse), true)

static func _draw_offline_laser_endcaps(target: Node, origin: Vector2, endpoint: Vector2, direction: Vector2, strength: float, active: bool) -> void:
	var color := Color(0.52, 0.04, 0.35, (0.72 if active else 0.44) * strength)
	var highlight := Color(1.0, 0.55, 0.82, (0.42 if active else 0.28) * strength)
	for i in range(2):
		var center := origin if i == 0 else endpoint
		var facing := direction.angle() + (PI if i == 0 else 0.0)
		target.call("draw_arc", center, OFFLINE_LASER_HIT_WIDTH, facing - 0.92, facing - 0.18, 10, color, 2.1 if active else 1.8, true)
		target.call("draw_arc", center, OFFLINE_LASER_HIT_WIDTH, facing + 0.18, facing + 0.92, 10, highlight, 0.9, true)

static func _draw_offline_laser_endpoint(target: Node, endpoint: Vector2, direction: Vector2, seed: float, active: bool, late: float) -> void:
	var side := Vector2(-direction.y, direction.x)
	var alpha := (0.68 if active else 0.46) + late * 0.14
	var offset := side * (3.0 + fposmod(seed * 7.0, 3.0))
	target.call("draw_line", endpoint - direction * 12.0 - offset, endpoint - direction * 3.0 - offset, Color(0.28, 0.94, 1.0, alpha), 1.8, true)
	target.call("draw_line", endpoint + direction * 3.0 + offset, endpoint + direction * 12.0 + offset, Color(0.28, 0.94, 1.0, alpha * 0.82), 1.5, true)
	target.call("draw_line", endpoint - side * 8.0, endpoint + side * 8.0, Color(1.0, 0.27, 0.64, alpha * 0.72), 1.4, true)
	target.call("draw_circle", endpoint, 2.0 if active else 1.5, Color(1.0, 0.93, 0.98, alpha), true)

static func _draw_offline_laser_active(target: Node, hazard: Dictionary, arena: Rect2) -> void:
	var from_pos := Vector2(hazard.get("from", Vector2.ZERO))
	var to_pos := Vector2(hazard.get("to", from_pos))
	var segment := to_pos - from_pos
	if segment.length_squared() <= 0.01:
		return
	var direction := segment.normalized()
	var side := Vector2(-direction.y, direction.x)
	var max_time := maxf(0.1, float(hazard.get("maxTime", 0.8)))
	var remaining := clampf(float(hazard.get("time", 0.0)) / max_time, 0.0, 1.0)
	var intensity := 0.60 + remaining * 0.40
	var seed := float(hazard.get("offlineLaserVisualSeed", 0.0))
	target.call("draw_line", from_pos, to_pos, Color(0.12, 0.01, 0.16, 0.15 * intensity), 52.0, true)
	target.call("draw_line", from_pos, to_pos, Color(0.28, 0.01, 0.24, 0.78 * intensity), 30.0, true)
	target.call("draw_line", from_pos, to_pos, Color(0.95, 0.04, 0.42, 0.78 * intensity), 24.0, true)
	target.call("draw_line", from_pos, to_pos, Color(1.0, 0.27, 0.64, 0.68 * intensity), 14.0, true)
	target.call("draw_line", from_pos, to_pos, Color(1.0, 0.96, 1.0, 0.76 * intensity), 5.8 - remaining * 0.8, true)
	_draw_offline_laser_rail(target, from_pos + side * OFFLINE_LASER_HIT_WIDTH, to_pos + side * OFFLINE_LASER_HIT_WIDTH, -side, intensity, true)
	_draw_offline_laser_rail(target, from_pos - side * OFFLINE_LASER_HIT_WIDTH, to_pos - side * OFFLINE_LASER_HIT_WIDTH, side, intensity, true)
	_draw_offline_laser_signal(target, from_pos, to_pos, side, seed, 1.0 - remaining, true)
	_draw_offline_laser_endcaps(target, from_pos, to_pos, direction, intensity, true)
	if arena.has_point(to_pos):
		_draw_offline_laser_endpoint(target, to_pos, direction, seed, true, 0.0)

static func _draw_offline_laser_foreground(target: Node, hazard: Dictionary, arena: Rect2) -> void:
	var from_pos := Vector2(hazard.get("from", Vector2.ZERO))
	var to_pos := Vector2(hazard.get("to", from_pos))
	var segment := to_pos - from_pos
	var length_sq := segment.length_squared()
	if length_sq <= 0.01:
		return
	var player_pos := Vector2(target.get("player_pos"))
	var ratio := clampf((player_pos - from_pos).dot(segment) / length_sq, 0.0, 1.0)
	var closest := from_pos + segment * ratio
	if closest.distance_to(player_pos) > 132.0:
		return
	var direction := segment.normalized()
	var side := Vector2(-direction.y, direction.x)
	var local_from := from_pos + segment * clampf(ratio - 0.105, 0.0, 1.0)
	var local_to := from_pos + segment * clampf(ratio + 0.105, 0.0, 1.0)
	var seed := float(hazard.get("offlineLaserVisualSeed", 0.0))
	_draw_offline_laser_rail(target, local_from + side * OFFLINE_LASER_HIT_WIDTH, local_to + side * OFFLINE_LASER_HIT_WIDTH, -side, 0.55, true)
	_draw_offline_laser_rail(target, local_from - side * OFFLINE_LASER_HIT_WIDTH, local_to - side * OFFLINE_LASER_HIT_WIDTH, side, 0.55, true)
	target.call("draw_line", local_from, local_to, Color(1.0, 0.96, 1.0, 0.34), 2.5, true)
	_draw_offline_laser_signal(target, local_from, local_to, side, seed + 0.17, 0.7, true)

static func _race_lane_charge_visual_hash(seed: float, salt: float) -> float:
	return fposmod(sin(seed * 97.173 + salt * 31.719) * 43758.5453, 1.0)

static func _race_lane_charge_lane_y(arena: Rect2, lane_index: int) -> float:
	return arena.position.y + arena.size.y * (0.34 + float(lane_index) * 0.32)

static func _draw_race_lane_charge_warning(target: Node, active: Dictionary, arena: Rect2, timer: float) -> void:
	var payload: Dictionary = active.get("payload", {}) as Dictionary
	var duration := maxf(0.01, float(payload.get("telegraph", 1.2)))
	var remaining := clampf(timer, 0.0, duration)
	var progress := clampf(1.0 - remaining / duration, 0.0, 1.0)
	var charge_warning := clampf(float(payload.get("chargeWarning", 0.60)), 0.0, duration)
	var charge_progress := clampf((charge_warning - remaining) / maxf(0.01, charge_warning), 0.0, 1.0)
	var serial := int(active.get("serial", 0))
	for lane_index in range(2):
		var center_y := _race_lane_charge_lane_y(arena, lane_index)
		var lane_rect := Rect2(arena.position.x, center_y - RACE_LANE_CHARGE_CORRIDOR_HEIGHT * 0.5, arena.size.x, RACE_LANE_CHARGE_CORRIDOR_HEIGHT)
		_draw_race_lane_charge_corridor(target, lane_rect, lane_index, serial, progress, duration - remaining, charge_progress, false)
	_draw_race_lane_charge_boss_cue(target, active, arena, false)

static func _draw_race_lane_charge_corridor(target: Node, lane_rect: Rect2, lane_index: int, serial: int, progress: float, visual_time: float, charge_progress: float, active_mode: bool, interior_factor: float = 1.0) -> void:
	var center := lane_rect.get_center()
	var seed := _race_lane_charge_visual_hash(float(serial) + float(lane_index) * 0.73, 0.19)
	var strength := clampf(interior_factor, 0.35, 1.0)
	var underlay_alpha := (0.105 if active_mode else 0.060 + charge_progress * 0.018) * strength
	var inner_alpha := (0.070 if active_mode else 0.030 + charge_progress * 0.020) * strength
	target.call("draw_rect", lane_rect, Color(0.18, 0.035, 0.20, underlay_alpha), true)
	var inner_rect := Rect2(lane_rect.position + Vector2(0.0, 10.0), Vector2(lane_rect.size.x, lane_rect.size.y - 20.0))
	target.call("draw_rect", inner_rect, Color(0.52, 0.10, 0.30, inner_alpha), true)
	var rail_alpha := (0.86 if active_mode else 0.62 + charge_progress * 0.12) * strength
	var rail_color := Color(0.30, 0.025, 0.25, rail_alpha)
	var highlight_color := Color(1.0, 0.78, 0.89, rail_alpha * 0.70)
	for side_index in range(2):
		var side: float = -1.0 if side_index == 0 else 1.0
		var rail_y := center.y + side * RACE_LANE_CHARGE_BOUNDARY_OFFSET
		var highlight_y := center.y + side * (RACE_LANE_CHARGE_BOUNDARY_OFFSET - 1.45)
		target.call("draw_line", Vector2(lane_rect.position.x, rail_y), Vector2(lane_rect.end.x, rail_y), rail_color, 2.0, true)
		target.call("draw_line", Vector2(lane_rect.position.x, highlight_y), Vector2(lane_rect.end.x, highlight_y), highlight_color, 1.0, true)
	var dash_speed := (178.0 + float(lane_index) * 11.0) if active_mode else (32.0 + charge_progress * 92.0 + float(lane_index) * 4.0)
	var dash_pitch := 92.0 + _race_lane_charge_visual_hash(seed, 2.0) * 24.0
	var dash_shift := fposmod(seed * dash_pitch - visual_time * dash_speed, dash_pitch)
	var x := lane_rect.position.x - dash_pitch + dash_shift
	var dash_index := 0
	while x < lane_rect.end.x:
		var dash_length := 19.0 + _race_lane_charge_visual_hash(seed, 10.0 + float(dash_index)) * 31.0
		var end_x := minf(lane_rect.end.x, x + dash_length)
		if end_x > lane_rect.position.x:
			var dash_y_offset := -20.0 + _race_lane_charge_visual_hash(seed, 40.0 + float(dash_index)) * 40.0
			var dash_y := center.y + dash_y_offset
			var dash_alpha := (0.48 if active_mode else 0.22 + charge_progress * 0.22) * strength
			var dash_color := Color(1.0, 0.84, 0.92, dash_alpha) if dash_index % 3 != lane_index else Color(1.0, 0.98, 0.94, dash_alpha * 0.86)
			target.call("draw_line", Vector2(maxf(x, lane_rect.position.x), dash_y), Vector2(end_x, dash_y), dash_color, 2.1 if active_mode else 1.4, true)
		dash_index += 1
		x += dash_pitch
		if dash_index > 48:
			break
	if active_mode or charge_progress > 0.12:
		for i in range(2):
			var glitch_x := lane_rect.position.x + fposmod(seed * (73.0 + float(i) * 29.0) - visual_time * dash_speed * 0.42, maxf(1.0, lane_rect.size.x))
			var glitch_y := center.y + (-26.0 if i == 0 else 24.0)
			target.call("draw_rect", Rect2(glitch_x, glitch_y, 6.0 + float(i) * 2.0, 1.1), Color(0.38, 0.90, 1.0, (0.20 if active_mode else 0.10) * strength), true)
	var late := smoothstep(0.84, 1.0, progress)
	if late > 0.0:
		var pulse_alpha := sin(late * PI) * (0.22 if active_mode else 0.12)
		for side_index in range(2):
			var side: float = -1.0 if side_index == 0 else 1.0
			var pulse_y := center.y + side * RACE_LANE_CHARGE_BOUNDARY_OFFSET
			target.call("draw_line", Vector2(lane_rect.position.x, pulse_y), Vector2(lane_rect.end.x, pulse_y), Color(1.0, 0.90, 0.96, pulse_alpha * strength), 1.0, true)

static func _draw_race_lane_charge_active(target: Node, hazard: Dictionary, hazards: Array) -> void:
	var lane_rect := Rect2(Vector2(hazard.get("pos", Vector2.ZERO)), Vector2(hazard.get("size", Vector2(2200.0, RACE_LANE_CHARGE_CORRIDOR_HEIGHT))))
	var max_time := maxf(0.01, float(hazard.get("maxTime", 1.8)))
	var elapsed := clampf(max_time - float(hazard.get("time", 0.0)), 0.0, max_time)
	var progress := elapsed / max_time
	var lane_index := int(hazard.get("raceLaneChargeLaneIndex", 0))
	var serial := int(hazard.get("raceLaneChargeSerial", 0))
	var seed := float(hazard.get("raceLaneChargeVisualSeed", 0.0))
	var center := lane_rect.get_center()
	var nearby := 1
	for other_item in hazards:
		var other: Dictionary = other_item as Dictionary
		if not bool(other.get("raceLaneChargeVisual", false)):
			continue
		if String(other.get("id", "")) == String(hazard.get("id", "")):
			continue
		var other_center := Rect2(Vector2(other.get("pos", Vector2.ZERO)), Vector2(other.get("size", Vector2.ZERO))).get_center()
		if center.distance_to(other_center) < 110.0:
			nearby += 1
	var interior_factor := 1.0 if nearby <= 1 else maxf(0.54, 1.0 - float(nearby - 1) * 0.18)
	_draw_race_lane_charge_corridor(target, lane_rect, lane_index, serial, progress, elapsed, 1.0, true, interior_factor)
	var cue_fade := 1.0 - clampf(elapsed / RACE_LANE_CHARGE_CUE_DURATION, 0.0, 1.0)
	if cue_fade <= 0.0:
		return
	for i in range(5):
		var speed_phase := elapsed * 560.0 + (seed + float(i) * 0.23) * (lane_rect.size.x + 96.0)
		var streak_x := lane_rect.end.x - fposmod(speed_phase, lane_rect.size.x + 96.0)
		var streak_length := 24.0 + _race_lane_charge_visual_hash(seed, 10.0 + float(i)) * 34.0
		var streak_y := center.y + (-24.0 + float((i + lane_index) % 4) * 16.0)
		var start_x := maxf(lane_rect.position.x, streak_x - streak_length)
		var end_x := minf(lane_rect.end.x, streak_x)
		if end_x > start_x:
			var streak_color := Color(1.0, 0.91, 0.95, cue_fade * (0.56 if i % 2 == 0 else 0.40) * interior_factor)
			target.call("draw_line", Vector2(start_x, streak_y), Vector2(end_x, streak_y), streak_color, 2.2 if i % 2 == 0 else 1.6, true)
	for i in range(2):
		var dust_x := center.x + (0.22 if i == 0 else 0.72) * lane_rect.size.x - fposmod(elapsed * 520.0 + seed * 180.0 + float(i) * 90.0, 120.0)
		var dust_pos := Vector2(clampf(dust_x, lane_rect.position.x, lane_rect.end.x), center.y + (-15.0 if i == 0 else 14.0))
		target.call("draw_circle", dust_pos, 1.5 + cue_fade * 1.8, Color(0.70, 0.30, 0.60, cue_fade * 0.34 * interior_factor), true)

static func _draw_race_lane_charge_boss_cue(target: Node, active: Dictionary, arena: Rect2, foreground: bool) -> void:
	var payload: Dictionary = active.get("payload", {}) as Dictionary
	var duration := maxf(0.01, float(payload.get("telegraph", 1.2)))
	var elapsed := clampf(duration - float(active.get("timer", 0.0)), 0.0, duration)
	if elapsed > 0.20:
		return
	var fade := 1.0 - clampf(elapsed / 0.20, 0.0, 1.0)
	var boss_pos := _boss_origin(target, arena)
	var seed := _race_lane_charge_visual_hash(float(active.get("serial", 0)), 7.0)
	var alpha := fade * (0.40 if foreground else 0.58)
	var offsets := [Vector2(-22.0, -28.0), Vector2(2.0, -38.0), Vector2(25.0, -24.0)]
	for i in range(offsets.size()):
		var block_center: Vector2 = boss_pos + offsets[i]
		var block_length := 12.0 + _race_lane_charge_visual_hash(seed, float(i) + 1.0) * 15.0
		target.call("draw_line", block_center - Vector2(block_length * 0.5, 0.0), block_center + Vector2(block_length * 0.5, 0.0), Color(1.0, 0.72, 0.86, alpha * (0.72 if i != 1 else 0.95)), 1.8 if not foreground else 1.1, true)
	target.call("draw_circle", boss_pos + Vector2(0.0, -48.0), 2.0 + fade * 1.2, Color(1.0, 0.96, 0.96, alpha * 0.72), true)
	if foreground:
		target.call("draw_line", boss_pos + Vector2(-8.0, -48.0), boss_pos + Vector2(8.0, -48.0), Color(1.0, 0.94, 0.98, alpha * 0.60), 1.0, true)
	else:
		for i in range(2):
			var streak_y := boss_pos.y - 12.0 + float(i) * 9.0
			target.call("draw_line", boss_pos + Vector2(-34.0 + float(i) * 12.0, streak_y - boss_pos.y), boss_pos + Vector2(-14.0 + float(i) * 12.0, streak_y - boss_pos.y), Color(0.96, 0.86, 0.94, alpha * 0.38), 1.0, true)

static func _draw_race_lane_charge_warning_foreground(target: Node, active: Dictionary, arena: Rect2, timer: float) -> void:
	var payload: Dictionary = active.get("payload", {}) as Dictionary
	var duration := maxf(0.01, float(payload.get("telegraph", 1.2)))
	var progress := clampf(1.0 - clampf(timer, 0.0, duration) / duration, 0.0, 1.0)
	var player_pos := Vector2(target.get("player_pos"))
	for lane_index in range(2):
		var center_y := _race_lane_charge_lane_y(arena, lane_index)
		if absf(player_pos.y - center_y) > 62.0:
			continue
		var from_x := maxf(arena.position.x, player_pos.x - 96.0)
		var to_x := minf(arena.end.x, player_pos.x + 96.0)
		if to_x <= from_x:
			continue
		var alpha := 0.30 + smoothstep(0.65, 1.0, progress) * 0.10
		for side_index in range(2):
			var side: float = -1.0 if side_index == 0 else 1.0
			var rail_y := center_y + side * RACE_LANE_CHARGE_BOUNDARY_OFFSET
			target.call("draw_line", Vector2(from_x, rail_y), Vector2(to_x, rail_y), Color(0.40, 0.04, 0.30, alpha), 1.3, true)
		var tick_x := player_pos.x + (-18.0 if lane_index == 0 else 18.0)
		target.call("draw_line", Vector2(tick_x, center_y - 29.0), Vector2(tick_x, center_y + 29.0), Color(1.0, 0.82, 0.92, alpha * 0.62), 1.0, true)

static func _draw_race_lane_charge_foreground(target: Node, hazard: Dictionary) -> void:
	var lane_rect := Rect2(Vector2(hazard.get("pos", Vector2.ZERO)), Vector2(hazard.get("size", Vector2(2200.0, RACE_LANE_CHARGE_CORRIDOR_HEIGHT))))
	var player_pos := Vector2(target.get("player_pos"))
	var center := lane_rect.get_center()
	if absf(player_pos.y - center.y) > 62.0:
		return
	var from_x := maxf(lane_rect.position.x, player_pos.x - 96.0)
	var to_x := minf(lane_rect.end.x, player_pos.x + 96.0)
	if to_x <= from_x:
		return
	var seed := float(hazard.get("raceLaneChargeVisualSeed", 0.0))
	for side_index in range(2):
		var side: float = -1.0 if side_index == 0 else 1.0
		var rail_y := center.y + side * RACE_LANE_CHARGE_BOUNDARY_OFFSET
		target.call("draw_line", Vector2(from_x, rail_y), Vector2(to_x, rail_y), Color(0.48, 0.04, 0.34, 0.42), 1.25, true)
	var dash_x := player_pos.x + fposmod(seed * 57.0, 42.0) - 21.0
	target.call("draw_line", Vector2(dash_x - 14.0, center.y), Vector2(dash_x + 14.0, center.y), Color(1.0, 0.90, 0.95, 0.34), 1.2, true)

static func _draw_race_lane_charge_visual_effects(target: Node, runtime: Dictionary) -> void:
	for item in runtime.get("race_lane_charge_visual_effects", []) as Array:
		var effect: Dictionary = item as Dictionary
		if String(effect.get("kind", "")) != "race_lane_charge_hit":
			continue
		var max_life := maxf(0.01, float(effect.get("maxLife", RACE_LANE_CHARGE_HIT_FX_DURATION)))
		var life := clampf(float(effect.get("life", 0.0)), 0.0, max_life)
		if life <= 0.0:
			continue
		var fade := life / max_life
		var progress := 1.0 - fade
		var pos := Vector2(effect.get("pos", Vector2.ZERO))
		var seed := float(effect.get("visualSeed", 0.0))
		var drift := Vector2(-progress * 24.0, sin(seed * 8.0 + progress * PI) * 3.0)
		var base := pos + drift
		var alpha := fade * 0.78
		target.call("draw_line", base - Vector2(28.0, 0.0), base + Vector2(24.0, 0.0), Color(0.74, 0.08, 0.36, alpha), 2.4, true)
		target.call("draw_line", base - Vector2(23.0, -0.4), base + Vector2(19.0, -0.4), Color(1.0, 0.94, 0.96, alpha * 0.72), 1.1, true)
		target.call("draw_line", base - Vector2(16.0, 5.0), base - Vector2(4.0, 5.0), Color(1.0, 0.40, 0.70, alpha * 0.66), 1.5, true)
		for i in range(3):
			var fragment_x := base.x + 8.0 + float(i) * 7.0
			var fragment_y := base.y - 7.0 + float(i) * 5.5
			target.call("draw_rect", Rect2(fragment_x, fragment_y, 5.0 + float(i % 2) * 2.0, 1.4), Color(0.50, 0.83, 0.94, alpha * 0.54), true)
		var flash := sin(progress * PI)
		target.call("draw_circle", pos, 4.0 + flash * 6.0, Color(1.0, 0.96, 0.98, alpha * 0.30), false, 1.2)

static func _howling_visual_hash(seed: float, salt: float) -> float:
	return fposmod(sin(seed * 71.173 + salt * 29.719) * 43758.5453, 1.0)

static func _draw_howling_ring_warning(target: Node, active: Dictionary, arena: Rect2, timer: float, foreground: bool) -> void:
	var payload: Dictionary = active.get("payload", {}) as Dictionary
	var duration := maxf(0.01, float(payload.get("telegraph", 0.90)))
	var remaining := clampf(timer, 0.0, duration)
	var progress := clampf(1.0 - remaining / duration, 0.0, 1.0)
	var serial := int(active.get("serial", 0))
	var center := MovementSystemScript.marker_world_position(target, "SongModule", arena)
	var ring_count := mini(HOWLING_RING_RADII.size(), maxi(1, int(payload.get("count", HOWLING_RING_RADII.size()))))
	var late := smoothstep(0.70, 1.0, progress)
	var pulse := sin(clampf((progress - 0.78) / 0.22, 0.0, 1.0) * PI)

	if foreground:
		# The front pass is only the short SongModule cue; the three formal
		# corridors remain in the back pass so the boss sprite is not covered.
		if progress > 0.24:
			return
		var cue := 1.0 - smoothstep(0.18, 0.24, progress)
		var cue_seed := _howling_visual_hash(float(serial), 0.7)
		for i in range(3):
			var cue_angle := cue_seed * TAU + float(i) * 2.1
			target.call("draw_arc", center, 42.0 + float(i) * 5.0, cue_angle, cue_angle + 0.42, 6, Color(0.38, 0.84, 1.0, cue * (0.28 - float(i) * 0.04)), 1.2, true)
			target.call("draw_arc", center, 42.0 + float(i) * 5.0, cue_angle + PI, cue_angle + PI + 0.30, 5, Color(1.0, 0.28, 0.68, cue * (0.24 - float(i) * 0.03)), 1.0, true)
		target.call("draw_line", center + Vector2(-10.0, 0.0), center + Vector2(10.0, 0.0), Color(1.0, 0.95, 0.99, cue * 0.44), 1.2, true)
		return

	for i in range(ring_count):
		var radius: float = HOWLING_RING_RADII[i]
		var seed := _howling_visual_hash(float(serial) + radius * 0.01, float(i) + center.x * 0.001)
		# Ring 1 leads, while the later rings remain visible but quieter.  The
		# stroke's nominal outer edge is radius +/- 18: the two 1.8px rails are
		# centered at +/-17 and the thin underlay is centered on the annulus.
		var ring_alpha := (0.44 - float(i) * 0.065 + late * 0.10 + pulse * 0.08)
		var segment_count := 10 - i
		var unit := TAU / float(segment_count)
		for segment_index in range(segment_count):
			var start := seed * TAU + float(segment_index) * unit + progress * (0.08 + float(i) * 0.025)
			var length := unit * (0.52 + late * 0.08)
			target.call("draw_arc", center, radius, start, start + length, maxi(4, int(length * radius / 18.0)), Color(0.18, 0.025, 0.24, ring_alpha * 0.10), HOWLING_RING_HALF_WIDTH * 2.0, true)
			target.call("draw_arc", center, radius + 17.0, start, start + length, maxi(4, int(length * radius / 18.0)), Color(0.43, 0.04, 0.34, ring_alpha), HOWLING_RING_RAIL_WIDTH, true)
			target.call("draw_arc", center, radius - 17.0, start, start + length, maxi(4, int(length * radius / 18.0)), Color(0.38, 0.03, 0.32, ring_alpha * 0.94), HOWLING_RING_RAIL_WIDTH, true)
			target.call("draw_arc", center, radius + 15.5, start, start + length, maxi(4, int(length * radius / 18.0)), Color(1.0, 0.78, 0.91, ring_alpha * 0.46), 0.85, true)
			target.call("draw_arc", center, radius - 15.5, start, start + length, maxi(4, int(length * radius / 18.0)), Color(0.90, 0.68, 0.86, ring_alpha * 0.40), 0.85, true)
		# A few short central signal arcs prevent the warning from reading as a
		# generic solid circle while retaining the exact fixed radius.
		var signal_start := seed * TAU + progress * 0.18 + float(i) * 0.61
		target.call("draw_arc", center, radius, signal_start, signal_start + 0.34, 6, Color(0.68, 0.94, 1.0, ring_alpha * 0.62), 1.6, true)
		target.call("draw_arc", center, radius, signal_start + PI, signal_start + PI + 0.27, 5, Color(1.0, 0.30, 0.70, ring_alpha * 0.58), 1.5, true)

	if progress <= 0.22:
		# SongModule's .20s origin cue is deliberately compact and never a
		# future-position marker.
		var cue_strength := 1.0 - smoothstep(0.18, 0.24, progress)
		target.call("draw_arc", center, 46.0, float(serial) * 0.17, float(serial) * 0.17 + 0.58, 7, Color(0.78, 0.96, 1.0, cue_strength * 0.38), 1.2, true)
		target.call("draw_arc", center, 46.0, float(serial) * 0.17 + PI, float(serial) * 0.17 + PI + 0.46, 6, Color(1.0, 0.34, 0.70, cue_strength * 0.32), 1.1, true)
	if late > 0.0:
		target.call("draw_circle", center, 4.0 + pulse * 2.0, Color(1.0, 0.96, 1.0, late * 0.18), true)

static func _howling_ring_nearby_count(hazard: Dictionary, hazards: Array) -> int:
	var count := 1
	var center := Vector2(hazard.get("pos", Vector2.ZERO))
	var radius := float(hazard.get("radius", 120.0))
	for item in hazards:
		var other: Dictionary = item as Dictionary
		if other == hazard or not bool(other.get("howlingRingVisual", false)):
			continue
		if center.distance_to(Vector2(other.get("pos", Vector2.ZERO))) < 64.0 and absf(radius - float(other.get("radius", radius))) < 42.0:
			count += 1
	return count

static func _draw_howling_ring_active(target: Node, hazard: Dictionary, hazards: Array) -> void:
	var center := Vector2(hazard.get("pos", Vector2.ZERO))
	var radius := float(hazard.get("radius", 120.0))
	var seed := float(hazard.get("howlingRingVisualSeed", 0.0))
	var delay := maxf(0.0, float(hazard.get("delay", 0.0)))
	var initial_delay := maxf(0.0, float(hazard.get("howlingRingInitialDelay", delay)))
	var elapsed := maxf(0.0, initial_delay - delay)
	var crowd := _howling_ring_nearby_count(hazard, hazards)
	var attenuation := 1.0 / (1.0 + float(maxi(0, crowd - 1)) * 0.18)
	if delay > 0.0001:
		# Queued rings have no filled danger band. Their fixed edges become more
		# legible as the stored delay approaches activation.
		var queue_progress := clampf(elapsed / maxf(0.01, initial_delay), 0.0, 1.0)
		var alpha := (0.22 + queue_progress * 0.20) * attenuation
		var dash_count := 7 + int(queue_progress * 3.0)
		var unit := TAU / float(dash_count)
		for i in range(dash_count):
			var start := seed * TAU + float(i) * unit + elapsed * 0.12
			var length := unit * 0.48
			target.call("draw_arc", center, radius + 17.0, start, start + length, maxi(4, int(length * radius / 18.0)), Color(0.39, 0.04, 0.34, alpha), HOWLING_RING_RAIL_WIDTH, true)
			target.call("draw_arc", center, radius - 17.0, start, start + length, maxi(4, int(length * radius / 18.0)), Color(0.34, 0.03, 0.30, alpha * 0.92), HOWLING_RING_RAIL_WIDTH, true)
			target.call("draw_arc", center, radius + 15.5, start, start + length, maxi(4, int(length * radius / 18.0)), Color(1.0, 0.74, 0.90, alpha * 0.34), 0.8, true)
		var split_start := seed * TAU + queue_progress * 0.42
		target.call("draw_arc", center, radius, split_start, split_start + 0.32, 6, Color(0.62, 0.92, 1.0, alpha * 0.52), 1.4, true)
		target.call("draw_arc", center, radius, split_start + PI, split_start + PI + 0.25, 5, Color(1.0, 0.28, 0.68, alpha * 0.48), 1.3, true)
		return

	var life_ratio := clampf(float(hazard.get("time", 0.0)) / maxf(0.01, float(hazard.get("maxTime", 2.25))), 0.0, 1.0)
	var alpha := (0.42 + life_ratio * 0.16) * attenuation
	# The underlay is centered on the collision annulus and is exactly 36px
	# wide by construction. Its opacity stays readable through the final frame.
	target.call("draw_arc", center, radius, 0.0, TAU, 96, Color(0.18, 0.025, 0.23, alpha * 0.13), HOWLING_RING_HALF_WIDTH * 2.0, true)
	target.call("draw_arc", center, radius + 17.0, 0.0, TAU, 96, Color(0.43, 0.04, 0.35, alpha), HOWLING_RING_RAIL_WIDTH, true)
	target.call("draw_arc", center, radius - 17.0, 0.0, TAU, 96, Color(0.37, 0.03, 0.31, alpha * 0.96), HOWLING_RING_RAIL_WIDTH, true)
	target.call("draw_arc", center, radius + 15.5, 0.0, TAU, 96, Color(1.0, 0.80, 0.92, alpha * 0.48), 0.85, true)
	target.call("draw_arc", center, radius - 15.5, 0.0, TAU, 96, Color(0.90, 0.68, 0.86, alpha * 0.42), 0.85, true)
	var visual_elapsed := maxf(0.0, float(hazard.get("maxTime", 2.25)) - float(hazard.get("time", 0.0)))
	var signal_start := seed * TAU + visual_elapsed * 0.16
	for i in range(4):
		var start := signal_start + float(i) * (TAU / 4.0)
		var span := 0.28 + _howling_visual_hash(seed, float(i)) * 0.16
		var signal_color := Color(0.64, 0.93, 1.0, alpha * 0.65) if i % 2 == 0 else Color(1.0, 0.25, 0.68, alpha * 0.58)
		target.call("draw_arc", center, radius, start, start + span, 6, signal_color, 1.8, true)
	# The fixed position pulse and a tiny waveform are audio feedback, not a
	# second hazard or a radial expansion.
	target.call("draw_arc", center, radius, signal_start + 0.10, signal_start + 0.32, 5, Color(1.0, 0.95, 0.99, alpha * 0.34), 1.2, true)
	for i in range(3):
		var notch_start := seed * TAU + float(i) * 2.0 + visual_elapsed * 0.11
		target.call("draw_arc", center, radius, notch_start, notch_start + 0.16, 4, Color(0.55, 0.88, 0.98, alpha * 0.32), 1.0, true)

static func _draw_howling_ring_local_assist(target: Node, center: Vector2, radius: float, anchor: Vector2, alpha: float, seed: float) -> void:
	var direction := anchor - center
	if direction.length_squared() <= 0.01:
		return
	var angle := direction.angle()
	var span := 0.24 + _howling_visual_hash(seed, 2.3) * 0.08
	target.call("draw_arc", center, radius + 17.0, angle - span, angle + span, 8, Color(0.54, 0.07, 0.42, alpha), HOWLING_RING_RAIL_WIDTH, true)
	target.call("draw_arc", center, radius - 17.0, angle - span, angle + span, 8, Color(0.46, 0.05, 0.36, alpha * 0.92), HOWLING_RING_RAIL_WIDTH, true)
	target.call("draw_arc", center, radius, angle - span * 0.72, angle + span * 0.72, 6, Color(0.80, 0.96, 1.0, alpha * 0.62), 1.5, true)

static func _draw_howling_ring_foreground(target: Node, hazard: Dictionary, _arena: Rect2) -> void:
	var boss_pos := Vector2.ZERO
	var found_boss := false
	for item in target.get("enemies") as Array:
		var enemy: Dictionary = item as Dictionary
		if bool(enemy.get("relayBoss", false)) or String(enemy.get("bossId", "")) == "last_offline" or String(enemy.get("kind", "")) == "last_offline":
			boss_pos = Vector2(enemy.get("pos", Vector2.ZERO))
			found_boss = true
			break
	if not found_boss:
		return
	var center := Vector2(hazard.get("pos", Vector2.ZERO))
	var radius := float(hazard.get("radius", 120.0))
	if absf(boss_pos.distance_to(center) - radius) > 54.0:
		return
	var alpha := 0.28 if float(hazard.get("delay", 0.0)) > 0.0 else 0.42
	_draw_howling_ring_local_assist(target, center, radius, boss_pos, alpha, float(hazard.get("howlingRingVisualSeed", 0.0)) + 0.13)

static func _draw_howling_ring_visual_effects(target: Node, runtime: Dictionary) -> void:
	for item in runtime.get("howling_ring_visual_effects", []) as Array:
		var effect: Dictionary = item as Dictionary
		var max_life := maxf(0.01, float(effect.get("maxLife", HOWLING_RING_HIT_FX_DURATION)))
		var life := clampf(float(effect.get("life", 0.0)), 0.0, max_life)
		if life <= 0.0:
			continue
		var fade := life / max_life
		var progress := 1.0 - fade
		var pos := Vector2(effect.get("pos", Vector2.ZERO))
		var seed := float(effect.get("visualSeed", 0.0))
		var ring_index := int(effect.get("ringIndex", 0))
		if String(effect.get("kind", "")) == "howling_ring_activation":
			# Keep every activation pulse on its already-committed radius; only
			# the short audio feedback arcs animate in opacity/phase.
			var radius := float(effect.get("radius", 120.0))
			var alpha := fade * (0.68 + sin(progress * PI) * 0.25)
			for i in range(3):
				var start := seed * TAU + float(i) * 2.1 + progress * 0.18
				target.call("draw_arc", pos, radius + 17.0, start, start + 0.28, 6, Color(0.72, 0.96, 1.0, alpha * 0.70), 1.5, true)
				target.call("draw_arc", pos, radius - 17.0, start + 0.36, start + 0.58, 5, Color(1.0, 0.30, 0.70, alpha * 0.60), 1.3, true)
			var notch_dir := Vector2.from_angle(seed * TAU + float(ring_index) * 0.8)
			target.call("draw_line", pos - notch_dir * 10.0, pos - notch_dir * 3.0, Color(1.0, 0.96, 1.0, alpha * 0.55), 1.2, true)
		else:
			# Hit feedback is local to the player and deliberately smaller than a
			# ring. It signals a broken audio pulse without implying a new hazard.
			var alpha := fade * 0.78
			var burst := sin(clampf(progress * PI, 0.0, PI))
			target.call("draw_arc", pos, 16.0 + burst * 4.0, seed * TAU, seed * TAU + 1.05, 8, Color(1.0, 0.96, 1.0, alpha * 0.62), 1.3, true)
			target.call("draw_arc", pos, 22.0 + burst * 3.0, seed * TAU + PI, seed * TAU + PI + 0.82, 7, Color(1.0, 0.30, 0.70, alpha * 0.55), 1.4, true)
			target.call("draw_line", pos + Vector2(-13.0, -3.0), pos + Vector2(-4.0, 2.0), Color(0.68, 0.94, 1.0, alpha * 0.72), 1.5, true)
			target.call("draw_line", pos + Vector2(3.0, 3.0), pos + Vector2(14.0, -3.0), Color(0.68, 0.94, 1.0, alpha * 0.72), 1.5, true)
			for i in range(3):
				var angle := seed * TAU + float(i) * 2.05 + progress * 0.28
				var fragment_pos := pos + Vector2.from_angle(angle) * (18.0 + burst * 7.0)
				target.call("draw_rect", Rect2(fragment_pos - Vector2(2.5, 1.2), Vector2(5.0, 2.4)), Color(0.24, 0.06, 0.30, alpha * 0.56), true)

static func _pitch_wave_visual_hash(seed: float, salt: float) -> float:
	return fposmod(sin(seed * 73.173 + salt * 29.719) * 43758.5453, 1.0)

static func _pitch_wave_lane_y(arena: Rect2, lane_index: int) -> float:
	return arena.position.y + arena.size.y * (0.35 + float(lane_index) * 0.30)

static func _draw_pitch_wave_warning(target: Node, active: Dictionary, arena: Rect2, timer: float, foreground: bool) -> void:
	var payload: Dictionary = active.get("payload", {}) as Dictionary
	var duration := maxf(0.01, float(payload.get("telegraph", 1.10)))
	var remaining := clampf(timer, 0.0, duration)
	var progress := clampf(1.0 - remaining / duration, 0.0, 1.0)
	var late := smoothstep(0.72, 1.0, progress)
	var serial := float(active.get("serial", 0))
	var count := maxi(1, int(payload.get("count", 2)))
	var start_x := arena.position.x - 80.0
	# The preview intentionally stops at the deterministic final packet center.
	# travelTime is not consulted and no gameplay state is written here.
	var end_x := start_x + PITCH_WAVE_SPEED * float(payload.get("activeDuration", 3.0))
	var seed := _pitch_wave_visual_hash(serial, 0.17)
	if foreground:
		var song_center := MovementSystemScript.marker_world_position(target, "SongModule", arena)
		if progress <= 0.20:
			var cue_fade := 1.0 - clampf(progress / 0.20, 0.0, 1.0)
			target.call("draw_arc", song_center, 36.0, seed * TAU, seed * TAU + 0.56, 7, Color(0.62, 0.94, 1.0, cue_fade * 0.38), 1.2, true)
			target.call("draw_arc", song_center, 36.0, seed * TAU + PI, seed * TAU + PI + 0.46, 6, Color(1.0, 0.28, 0.70, cue_fade * 0.34), 1.1, true)
		# A compact left-entry bracket makes the offscreen origin legible without
		# moving or clamping the actual packet spawn point.
		for i in range(count):
			var y := _pitch_wave_lane_y(arena, i)
			var bracket_alpha := 0.26 + late * 0.12
			target.call("draw_line", Vector2(arena.position.x + 3.0, y - 12.0), Vector2(arena.position.x + 3.0, y + 12.0), Color(0.32, 0.10, 0.38, bracket_alpha), 1.4, true)
			target.call("draw_line", Vector2(arena.position.x + 3.0, y - 12.0), Vector2(arena.position.x + 14.0, y - 12.0), Color(0.76, 0.88, 1.0, bracket_alpha * 0.82), 1.0, true)
			target.call("draw_line", Vector2(arena.position.x + 3.0, y + 12.0), Vector2(arena.position.x + 14.0, y + 12.0), Color(1.0, 0.42, 0.72, bracket_alpha * 0.76), 1.0, true)
		if late > 0.0:
			target.call("draw_circle", song_center, 3.0 + late * 1.5, Color(1.0, 0.96, 1.0, late * 0.16), true)
		return
	for i in range(count):
		var y := _pitch_wave_lane_y(arena, i)
		var lane_alpha := 0.28 + late * 0.10
		# The underlay is deliberately faint; the two rails carry the exact
		# 84px visual corridor instead of a solid danger band.
		target.call("draw_line", Vector2(start_x, y), Vector2(end_x, y), Color(0.18, 0.05, 0.24, 0.035 + late * 0.012), 84.0, true)
		target.call("draw_line", Vector2(start_x, y - 41.0), Vector2(end_x, y - 41.0), Color(0.30, 0.04, 0.30, lane_alpha), 2.0, true)
		target.call("draw_line", Vector2(start_x, y + 41.0), Vector2(end_x, y + 41.0), Color(0.40, 0.05, 0.35, lane_alpha), 2.0, true)
		target.call("draw_line", Vector2(start_x, y - 39.4), Vector2(end_x, y - 39.4), Color(1.0, 0.76, 0.90, lane_alpha * 0.56), 1.0, true)
		target.call("draw_line", Vector2(start_x, y + 39.4), Vector2(end_x, y + 39.4), Color(0.76, 0.90, 1.0, lane_alpha * 0.48), 1.0, true)
		var dash_pitch := 116.0 + _pitch_wave_visual_hash(seed, float(i) + 1.0) * 18.0
		var dash_shift := fposmod(seed * dash_pitch - progress * 42.0, dash_pitch)
		var dash_x := start_x - dash_pitch + dash_shift
		var dash_index := 0
		while dash_x < end_x:
			var dash_length := 18.0 + _pitch_wave_visual_hash(seed, float(i * 7 + dash_index)) * 16.0
			var clipped_start := maxf(start_x, dash_x)
			var clipped_end := minf(end_x, dash_x + dash_length)
			if clipped_end > clipped_start:
				target.call("draw_line", Vector2(clipped_start, y), Vector2(clipped_end, y), Color(0.90, 0.94, 1.0, 0.20 + late * 0.12), 1.4, true)
			dash_x += dash_pitch
			dash_index += 1
			if dash_index > 32:
				break
		# A small two-color split is a waveform cue, not an aiming laser.
		var signal_x := start_x + fposmod(seed * 173.0 + progress * 120.0 + float(i) * 47.0, maxf(1.0, end_x - start_x))
		target.call("draw_line", Vector2(signal_x, y - 4.0), Vector2(minf(end_x, signal_x + 13.0), y - 4.0), Color(0.40, 0.92, 1.0, 0.20 + late * 0.08), 1.0, true)
		target.call("draw_line", Vector2(signal_x + 4.0, y + 4.0), Vector2(minf(end_x, signal_x + 17.0), y + 4.0), Color(1.0, 0.30, 0.70, 0.18 + late * 0.08), 1.0, true)
	if late > 0.0:
		var endpoint_x := end_x
		for endpoint_index in range(count):
			var endpoint_y := _pitch_wave_lane_y(arena, endpoint_index)
			target.call("draw_arc", Vector2(endpoint_x, endpoint_y), 41.0, -0.64, 0.64, 8, Color(0.65, 0.92, 1.0, late * 0.24), 1.2, true)

static func _pitch_wave_points(center: Vector2, seed: float, phase: float, row: int, length: float = 52.0) -> PackedVector2Array:
	var points := PackedVector2Array()
	var base_y := -6.0 if row == 0 else 6.0
	for i in range(9):
		var ratio := float(i) / 8.0
		var x := (ratio - 0.5) * length
		var y := base_y + sin(ratio * TAU * 1.35 + phase + float(row) * 0.72) * 3.2
		points.append(center + Vector2(x, y))
	return points

static func _pitch_wave_nearby_count(hazard: Dictionary, hazards: Array) -> int:
	var count := 1
	var center := Vector2(hazard.get("pos", Vector2.ZERO))
	for item in hazards:
		var other: Dictionary = item as Dictionary
		if other == hazard or not bool(other.get("pitchWaveVisual", false)):
			continue
		if center.distance_to(Vector2(other.get("pos", Vector2.ZERO))) < 96.0:
			count += 1
	return count

static func _draw_pitch_wave_active(target: Node, hazard: Dictionary, hazards: Array) -> void:
	var center := Vector2(hazard.get("pos", Vector2.ZERO))
	var radius := float(hazard.get("radius", PITCH_WAVE_RADIUS))
	var seed := float(hazard.get("pitchWaveVisualSeed", 0.0))
	var max_time := maxf(0.01, float(hazard.get("maxTime", 3.0)))
	var elapsed := clampf(max_time - float(hazard.get("time", 0.0)), 0.0, max_time)
	var life_ratio := clampf(float(hazard.get("time", 0.0)) / max_time, 0.0, 1.0)
	var crowd := _pitch_wave_nearby_count(hazard, hazards)
	var attenuation := 1.0 if crowd <= 1 else maxf(0.58, 1.0 - float(crowd - 1) * 0.18)
	var alpha := (0.42 + life_ratio * 0.16) * attenuation
	# The nominal outer edge is exactly radius 42: radius 41 + a 2px stroke.
	target.call("draw_circle", center, radius - 3.0, Color(1.0, 0.91, 0.95, 0.045 * attenuation), true)
	target.call("draw_arc", center, radius - 1.0, 0.0, TAU, 40, Color(0.34, 0.03, 0.31, alpha), 2.0, true)
	target.call("draw_arc", center, radius - 2.8, 0.18, TAU - 0.18, 36, Color(1.0, 0.78, 0.91, alpha * 0.56), 1.0, true)
	var phase := elapsed * 4.8 + seed * TAU
	for row in range(2):
		var points := _pitch_wave_points(center, seed, phase, row)
		target.call("draw_polyline", points, Color(1.0, 0.94, 0.98, alpha * 0.76), 1.8, true)
	var cyan_points := _pitch_wave_points(center + Vector2(-2.5, -1.5), seed, phase + 0.46, 0, 40.0)
	target.call("draw_polyline", cyan_points, Color(0.38, 0.92, 1.0, alpha * 0.52), 1.1, true)
	var pink_points := _pitch_wave_points(center + Vector2(2.5, 1.4), seed, phase + 1.13, 1, 38.0)
	target.call("draw_polyline", pink_points, Color(1.0, 0.26, 0.70, alpha * 0.46), 1.1, true)
	# Small pitch fragments sit inside the packet; no text or large symbols.
	for i in range(3):
		var fragment_x := center.x - 20.0 + fposmod(seed * 43.0 + float(i) * 17.0 + elapsed * 18.0, 40.0)
		var fragment_y := center.y + (-20.0 if i % 2 == 0 else 18.0)
		target.call("draw_line", Vector2(fragment_x, fragment_y - 3.0), Vector2(fragment_x, fragment_y + 3.0), Color(0.82, 0.64, 0.90, alpha * 0.52), 1.0, true)
		target.call("draw_line", Vector2(fragment_x - 2.5, fragment_y), Vector2(fragment_x + 2.5, fragment_y), Color(0.82, 0.64, 0.90, alpha * 0.44), 1.0, true)
	# Short waveform afterimage, kept below 30px and behind the packet.
	var trail_points := PackedVector2Array([
		center + Vector2(-28.0, 4.0),
		center + Vector2(-22.0, 1.0),
		center + Vector2(-16.0, 5.0),
		center + Vector2(-10.0, 2.0)
	])
	target.call("draw_polyline", trail_points, Color(1.0, 0.54, 0.78, alpha * 0.28), 1.3, true)

static func _draw_pitch_wave_foreground(target: Node, hazard: Dictionary) -> void:
	var center := Vector2(hazard.get("pos", Vector2.ZERO))
	var player_pos := Vector2(target.get("player_pos"))
	if player_pos.distance_to(center) > 80.0:
		return
	var direction := player_pos - center
	if direction.length_squared() <= 0.01:
		direction = Vector2.RIGHT
	var angle := direction.angle()
	var seed := float(hazard.get("pitchWaveVisualSeed", 0.0))
	target.call("draw_arc", center, 41.0, angle - 0.54, angle + 0.54, 7, Color(0.42, 0.05, 0.36, 0.50), 1.5, true)
	target.call("draw_arc", center, 41.0, angle + PI - 0.32, angle + PI + 0.32, 6, Color(1.0, 0.78, 0.91, 0.38), 0.9, true)
	var assist := _pitch_wave_points(center, seed, seed * TAU + 0.5, 0, 28.0)
	target.call("draw_polyline", assist, Color(0.72, 0.95, 1.0, 0.34), 1.0, true)

static func _draw_pitch_wave_visual_effects(target: Node, runtime: Dictionary, hit_only: bool) -> void:
	for item in runtime.get("pitch_wave_visual_effects", []) as Array:
		var effect: Dictionary = item as Dictionary
		var kind := String(effect.get("kind", ""))
		if hit_only and kind != "relay_pitch_wave_hit":
			continue
		if not hit_only and kind != "relay_pitch_wave_cast":
			continue
		var max_life := maxf(0.01, float(effect.get("maxLife", PITCH_WAVE_LAUNCH_FX_DURATION)))
		var life := clampf(float(effect.get("life", 0.0)), 0.0, max_life)
		if life <= 0.0:
			continue
		var fade := life / max_life
		var progress := 1.0 - fade
		var seed := float(effect.get("visualSeed", 0.0))
		if kind == "relay_pitch_wave_cast":
			var entries: Array = effect.get("entryPositions", []) as Array
			for entry_item in entries:
				var entry := Vector2(entry_item)
				var cue_alpha := fade * (0.72 - progress * 0.18)
				target.call("draw_arc", entry, 13.0 + progress * 8.0, seed * TAU, seed * TAU + 1.0, 8, Color(1.0, 0.96, 1.0, cue_alpha * 0.62), 1.4, true)
				target.call("draw_line", entry + Vector2(-9.0, -4.0), entry + Vector2(9.0, -4.0), Color(0.40, 0.92, 1.0, cue_alpha * 0.72), 1.1, true)
				target.call("draw_line", entry + Vector2(-7.0, 4.0), entry + Vector2(10.0, 4.0), Color(1.0, 0.30, 0.70, cue_alpha * 0.68), 1.1, true)
				for i in range(2):
					var fragment_pos := entry + Vector2(-4.0 + float(i) * 13.0, -10.0 + float(i) * 20.0) * (1.0 + progress * 0.2)
					target.call("draw_rect", Rect2(fragment_pos - Vector2(2.0, 1.0), Vector2(4.0, 2.0)), Color(0.18, 0.05, 0.24, cue_alpha * 0.72), true)
		else:
			var pos := Vector2(effect.get("pos", Vector2.ZERO))
			var burst := sin(progress * PI)
			var alpha := fade * 0.84
			target.call("draw_arc", pos, 13.0 + burst * 6.0, seed * TAU, seed * TAU + 1.10, 8, Color(1.0, 0.96, 1.0, alpha * 0.68), 1.4, true)
			target.call("draw_arc", pos, 20.0 + burst * 4.0, seed * TAU + PI, seed * TAU + PI + 0.72, 7, Color(0.38, 0.92, 1.0, alpha * 0.58), 1.3, true)
			var fracture := PackedVector2Array([
				pos + Vector2(-22.0, 3.0),
				pos + Vector2(-11.0, -2.0),
				pos + Vector2(0.0, 3.0),
				pos + Vector2(12.0, -3.0),
				pos + Vector2(22.0, 2.0)
			])
			target.call("draw_polyline", fracture, Color(1.0, 0.32, 0.70, alpha * 0.72), 1.6, true)
			for i in range(3):
				var fragment_pos := pos + Vector2(-12.0 + float(i) * 12.0, -8.0 + float(i % 2) * 15.0) * (1.0 + progress * 0.34)
				target.call("draw_rect", Rect2(fragment_pos - Vector2(2.5, 1.2), Vector2(5.0, 2.4)), Color(0.22, 0.06, 0.30, alpha * 0.62), true)

static func _rhythm_explosion_visual_hash(seed: float, salt: float) -> float:
	return fposmod(sin(seed * 61.173 + salt * 29.719) * 43758.5453, 1.0)

static func _draw_rhythm_explosion_warning(target: Node, active: Dictionary, arena: Rect2, timer: float, foreground: bool) -> void:
	var payload: Dictionary = active.get("payload", {}) as Dictionary
	var count := maxi(1, int(payload.get("markerCount", 6)))
	var duration := maxf(0.01, float(payload.get("telegraph", 1.40)))
	var first_beat := maxf(0.0, float(payload.get("firstExplosion", 1.40)))
	var beat_interval := maxf(0.01, float(payload.get("interval", 0.25)))
	var remaining := clampf(timer, 0.0, duration)
	var progress := clampf(1.0 - remaining / duration, 0.0, 1.0)
	var serial := float(active.get("serial", 0))
	var seed := _rhythm_explosion_visual_hash(serial, 0.17)
	var preview_elapsed := progress * first_beat
	var late := smoothstep(0.72, 1.0, progress)
	var song_center := MovementSystemScript.marker_world_position(target, "SongModule", arena)
	if not foreground and progress <= 0.20:
		var cue_fade := 1.0 - progress / 0.20
		target.call("draw_arc", song_center, 30.0, seed * TAU, seed * TAU + 0.72, 8, Color(0.64, 0.94, 1.0, cue_fade * 0.30), 1.2, true)
		target.call("draw_arc", song_center, 30.0, seed * TAU + PI, seed * TAU + PI + 0.52, 7, Color(1.0, 0.28, 0.70, cue_fade * 0.26), 1.2, true)
		target.call("draw_circle", song_center, 3.5, Color(1.0, 0.96, 1.0, cue_fade * 0.28), true)
	for i in range(count):
		var marker := AttackSystemScript.rhythm_explosion_marker_position_for_target(target, arena, i, count)
		var marker_seed := _rhythm_explosion_visual_hash(seed, float(i) + 0.71)
		var beat_remaining := first_beat + float(i) * beat_interval - preview_elapsed
		var is_ready := beat_remaining > 0.0 and beat_remaining <= 0.20
		var preview_active := beat_remaining <= 0.0
		var state_alpha := 0.24
		if is_ready:
			state_alpha = 0.42
		elif preview_active:
			state_alpha = 0.54
		state_alpha += late * 0.10
		if foreground:
			var player_pos := Vector2(target.get("player_pos"))
			if marker.distance_to(song_center) > 126.0 and marker.distance_to(player_pos) > 72.0:
				continue
		_draw_rhythm_explosion_warning_marker(target, marker, marker_seed, state_alpha, progress, beat_remaining, foreground)

static func _draw_rhythm_explosion_warning_marker(target: Node, center: Vector2, seed: float, alpha: float, progress: float, beat_remaining: float, foreground: bool) -> void:
	var arc_start := seed * TAU
	var arc_width := 1.8 if not foreground else 1.25
	var arc_alpha := alpha * (0.70 if not foreground else 0.76)
	var segments := 3 if beat_remaining > 0.20 else 4
	for arc_index in range(segments):
		var start := arc_start + float(arc_index) * TAU / float(segments) + progress * 0.10
		var span := (0.42 if arc_index % 2 == 0 else 0.30) + _rhythm_explosion_visual_hash(seed, float(arc_index) + 2.0) * 0.08
		var color := Color(0.30, 0.04, 0.34, arc_alpha) if arc_index % 2 == 0 else Color(0.88, 0.20, 0.62, arc_alpha * 0.86)
		target.call("draw_arc", center, RHYTHM_EXPLOSION_RADIUS - 1.0, start, start + span, 8, color, arc_width, true)
	if not foreground:
		target.call("draw_arc", center, RHYTHM_EXPLOSION_RADIUS - 3.3, arc_start + 0.11, arc_start + 0.38, 6, Color(1.0, 0.80, 0.94, alpha * 0.42), 0.9, true)
		target.call("draw_circle", center, RHYTHM_EXPLOSION_RADIUS - 5.0, Color(0.26, 0.05, 0.30, 0.018 + (0.012 if beat_remaining <= 0.20 else 0.0)), true)
	var tick_count := 2 if beat_remaining > 0.20 else 4
	for tick_index in range(tick_count):
		var tick_angle := arc_start + float(tick_index) * TAU / float(tick_count) + progress * 0.16
		var tick_dir := Vector2.from_angle(tick_angle)
		target.call("draw_line", center + tick_dir * 46.0, center + tick_dir * 51.0, Color(0.76, 0.94, 1.0, alpha * (0.34 if beat_remaining > 0.20 else 0.52)), 1.0, true)
	if not foreground:
		target.call("draw_circle", center, 2.0 + (1.2 if beat_remaining <= 0.20 else 0.0), Color(1.0, 0.96, 1.0, alpha * 0.42), true)

static func _draw_rhythm_explosion_active(target: Node, hazard: Dictionary, hazards: Array) -> void:
	var center := Vector2(hazard.get("pos", Vector2.ZERO))
	var radius := float(hazard.get("radius", RHYTHM_EXPLOSION_RADIUS))
	var seed := float(hazard.get("rhythmExplosionVisualSeed", 0.0))
	var delay := float(hazard.get("delay", 0.0))
	var initial_delay := maxf(0.01, float(hazard.get("rhythmExplosionInitialDelay", delay)))
	var elapsed := clampf(initial_delay - delay, 0.0, initial_delay)
	if delay > 0.0:
		var queue_alpha := 0.22 + smoothstep(0.50, 1.0, elapsed / initial_delay) * 0.14
		_draw_rhythm_explosion_warning_marker(target, center, seed, queue_alpha, elapsed / initial_delay, delay, false)
		return
	var life_ratio := clampf(float(hazard.get("time", 0.0)) / maxf(0.01, float(hazard.get("maxTime", 2.65))), 0.0, 1.0)
	var crowd := 1
	for item in hazards:
		var other: Dictionary = item as Dictionary
		if other == hazard or not bool(other.get("rhythmExplosionVisual", false)):
			continue
		if center.distance_to(Vector2(other.get("pos", Vector2.ZERO))) < radius * 2.2:
			crowd += 1
	var attenuation := 1.0 if crowd <= 1 else maxf(0.62, 1.0 - float(crowd - 1) * 0.12)
	var alpha := (0.48 + life_ratio * 0.12) * attenuation
	# The underlay is deliberately faint; the formal outer edge is always
	# radius 58 (57px centerline plus a 2px stroke).
	target.call("draw_circle", center, radius - 4.0, Color(0.34, 0.08, 0.36, 0.035 * attenuation), true)
	target.call("draw_arc", center, radius - 1.0, 0.0, TAU, 72, Color(0.34, 0.035, 0.36, alpha), 2.0, true)
	target.call("draw_arc", center, radius - 3.0, 0.16, TAU - 0.16, 64, Color(1.0, 0.76, 0.92, alpha * 0.48), 1.0, true)
	var beat_phase := fposmod(elapsed, RHYTHM_EXPLOSION_BEAT_INTERVAL) / RHYTHM_EXPLOSION_BEAT_INTERVAL
	var beat_pulse := sin(beat_phase * PI)
	for tick_index in range(6):
		var tick_angle := seed * TAU + float(tick_index) * TAU / 6.0 + elapsed * 0.16
		var tick_dir := Vector2.from_angle(tick_angle)
		var tick_length := 5.0 + beat_pulse * 3.0
		target.call("draw_line", center + tick_dir * 47.0, center + tick_dir * (47.0 + tick_length), Color(0.78, 0.94, 1.0, alpha * (0.44 + beat_pulse * 0.18)), 1.2, true)
	target.call("draw_arc", center, 19.0, seed * TAU, seed * TAU + 0.86, 8, Color(0.66, 0.92, 1.0, alpha * 0.44), 1.2, true)
	target.call("draw_arc", center, 19.0, seed * TAU + PI, seed * TAU + PI + 0.68, 7, Color(1.0, 0.28, 0.70, alpha * 0.42), 1.1, true)
	target.call("draw_line", center + Vector2(-7.0, 2.0), center + Vector2(0.0, -3.0), Color(1.0, 0.96, 1.0, alpha * 0.52), 1.2, true)
	target.call("draw_line", center + Vector2(0.0, -3.0), center + Vector2(7.0, 2.0), Color(1.0, 0.96, 1.0, alpha * 0.52), 1.2, true)

static func _draw_rhythm_explosion_boss_foreground(target: Node, hazard: Dictionary) -> void:
	var boss_pos := Vector2.ZERO
	var boss_radius := 0.0
	for item in target.get("enemies") as Array:
		var enemy: Dictionary = item as Dictionary
		if bool(enemy.get("relayBoss", false)) or String(enemy.get("bossId", "")) == "last_offline" or String(enemy.get("kind", "")) == "last_offline":
			boss_pos = Vector2(enemy.get("pos", Vector2.ZERO))
			boss_radius = maxf(80.0, float(enemy.get("radius", 100.0)))
			break
	if boss_radius <= 0.0:
		return
	var center := Vector2(hazard.get("pos", Vector2.ZERO))
	if center.distance_to(boss_pos) > boss_radius + RHYTHM_EXPLOSION_RADIUS + 24.0:
		return
	var direction := boss_pos - center
	if direction.length_squared() <= 0.01:
		direction = Vector2.RIGHT
	var angle := direction.angle()
	var seed := float(hazard.get("rhythmExplosionVisualSeed", 0.0))
	target.call("draw_arc", center, RHYTHM_EXPLOSION_RADIUS - 1.0, angle - 0.46, angle + 0.46, 10, Color(1.0, 0.82, 0.94, 0.40), 1.15, true)
	target.call("draw_arc", center, RHYTHM_EXPLOSION_RADIUS - 1.0, angle + PI - 0.28, angle + PI + 0.28, 7, Color(0.40, 0.08, 0.44, 0.46), 1.2, true)
	target.call("draw_line", center + Vector2.from_angle(seed * TAU) * 12.0, center + Vector2.from_angle(seed * TAU) * 20.0, Color(0.70, 0.94, 1.0, 0.38), 1.0, true)

static func _draw_rhythm_explosion_local_assist(target: Node, hazard: Dictionary, player_pos: Vector2) -> void:
	var center := Vector2(hazard.get("pos", Vector2.ZERO))
	var direction := player_pos - center
	if direction.length_squared() <= 0.01:
		direction = Vector2.RIGHT
	var angle := direction.angle()
	var seed := float(hazard.get("rhythmExplosionVisualSeed", 0.0))
	target.call("draw_arc", center, RHYTHM_EXPLOSION_RADIUS - 1.0, angle - 0.50, angle + 0.50, 10, Color(1.0, 0.84, 0.95, 0.44), 1.2, true)
	target.call("draw_arc", center, RHYTHM_EXPLOSION_RADIUS - 1.0, angle + PI - 0.30, angle + PI + 0.30, 8, Color(0.42, 0.06, 0.46, 0.48), 1.15, true)
	target.call("draw_line", center + Vector2.from_angle(seed * TAU) * 10.0, center + Vector2.from_angle(seed * TAU) * 18.0, Color(0.72, 0.94, 1.0, 0.36), 1.0, true)

static func _draw_rhythm_explosion_player_warning_foreground(target: Node, active: Dictionary, arena: Rect2) -> void:
	var payload: Dictionary = active.get("payload", {}) as Dictionary
	var count := maxi(1, int(payload.get("markerCount", 6)))
	var duration := maxf(0.01, float(payload.get("telegraph", RHYTHM_EXPLOSION_WARNING_DURATION)))
	var progress := clampf(1.0 - float(active.get("timer", duration)) / duration, 0.0, 1.0)
	var player_pos := Vector2(target.get("player_pos"))
	var seed := _rhythm_explosion_visual_hash(float(active.get("serial", 0)), 0.17)
	for i in range(count):
		var center := AttackSystemScript.rhythm_explosion_marker_position_for_target(target, arena, i, count)
		if center.distance_to(player_pos) > RHYTHM_EXPLOSION_RADIUS + 72.0:
			continue
		var direction := player_pos - center
		if direction.length_squared() <= 0.01:
			direction = Vector2.RIGHT
		var angle := direction.angle()
		var local_seed := _rhythm_explosion_visual_hash(seed, float(i) + 3.1)
		target.call("draw_arc", center, RHYTHM_EXPLOSION_RADIUS - 1.0, angle - 0.42, angle + 0.42, 9, Color(1.0, 0.84, 0.95, 0.38 + progress * 0.10), 1.1, true)
		target.call("draw_arc", center, RHYTHM_EXPLOSION_RADIUS - 1.0, angle + PI - 0.26, angle + PI + 0.26, 7, Color(0.44, 0.06, 0.48, 0.44), 1.1, true)
		target.call("draw_line", center + Vector2.from_angle(local_seed * TAU) * 12.0, center + Vector2.from_angle(local_seed * TAU) * 19.0, Color(0.78, 0.96, 1.0, 0.34), 1.0, true)

static func _draw_rhythm_explosion_visual_effects(target: Node, runtime: Dictionary, hit_only: bool) -> void:
	for item in runtime.get("rhythm_explosion_visual_effects", []) as Array:
		var effect: Dictionary = item as Dictionary
		var kind := String(effect.get("kind", ""))
		if hit_only and kind != "relay_rhythm_explosion_hit":
			continue
		if not hit_only and kind != "relay_rhythm_explosion_activation":
			continue
		var max_life := maxf(0.01, float(effect.get("maxLife", RHYTHM_EXPLOSION_ACTIVATION_FX_DURATION)))
		var life := clampf(float(effect.get("life", 0.0)), 0.0, max_life)
		if life <= 0.0:
			continue
		var fade := life / max_life
		var progress := 1.0 - fade
		var pos := Vector2(effect.get("pos", Vector2.ZERO))
		var seed := float(effect.get("visualSeed", 0.0))
		var arc_start := seed * TAU
		if kind == "relay_rhythm_explosion_activation":
			var alpha := fade * (0.68 + sin(progress * PI) * 0.24)
			target.call("draw_arc", pos, RHYTHM_EXPLOSION_RADIUS - 1.0, arc_start, arc_start + 0.72, 10, Color(1.0, 0.94, 1.0, alpha * 0.74), 1.4, true)
			target.call("draw_arc", pos, RHYTHM_EXPLOSION_RADIUS - 1.0, arc_start + PI, arc_start + PI + 0.58, 8, Color(1.0, 0.28, 0.70, alpha * 0.62), 1.3, true)
			for i in range(4):
				var tick_dir := Vector2.from_angle(arc_start + float(i) * PI * 0.5)
				target.call("draw_line", pos + tick_dir * 42.0, pos + tick_dir * 51.0, Color(0.66, 0.94, 1.0, alpha * 0.62), 1.1, true)
				if i % 2 == 0:
					target.call("draw_rect", Rect2(pos + tick_dir * 32.0 - Vector2(2.0, 1.0), Vector2(4.0, 2.0)), Color(0.28, 0.06, 0.34, alpha * 0.68), true)
			target.call("draw_circle", pos, 3.0 + sin(progress * PI) * 1.5, Color(1.0, 0.97, 1.0, alpha * 0.64), true)
		else:
			var alpha := fade * 0.82
			var burst := sin(clampf(progress * PI, 0.0, PI))
			target.call("draw_arc", pos, 24.0 + burst * 2.0, arc_start, arc_start + 0.88, 9, Color(1.0, 0.94, 1.0, alpha * 0.72), 1.3, true)
			target.call("draw_arc", pos, 30.0, arc_start + PI, arc_start + PI + 0.64, 8, Color(1.0, 0.28, 0.70, alpha * 0.62), 1.4, true)
			var fracture := PackedVector2Array([
				pos + Vector2(-18.0, 3.0),
				pos + Vector2(-8.0, -2.0),
				pos + Vector2(0.0, 3.0),
				pos + Vector2(9.0, -3.0),
				pos + Vector2(18.0, 2.0)
			])
			target.call("draw_polyline", fracture, Color(0.64, 0.94, 1.0, alpha * 0.70), 1.4, true)
			for i in range(3):
				var fragment_pos := pos + Vector2(-13.0 + float(i) * 13.0, -8.0 + float(i % 2) * 14.0) * (1.0 + burst * 0.12)
				target.call("draw_rect", Rect2(fragment_pos - Vector2(2.5, 1.2), Vector2(5.0, 2.4)), Color(0.28, 0.06, 0.36, alpha * 0.64), true)
			target.call("draw_circle", pos, 3.0 + burst * 2.0, Color(1.0, 0.96, 1.0, alpha * 0.40), true)

static func _dirty_paint_visual_hash(seed: float, salt: float) -> float:
	return fposmod(sin(seed * 71.173 + salt * 29.719) * 43758.5453, 1.0)

static func _draw_dirty_paint_warning(target: Node, active: Dictionary, arena: Rect2, timer: float, foreground: bool) -> void:
	var payload: Dictionary = active.get("payload", {}) as Dictionary
	var count := maxi(1, int(payload.get("count", 3)))
	var duration := maxf(0.01, float(payload.get("telegraph", DIRTY_PAINT_WARNING_DURATION)))
	var remaining := clampf(timer, 0.0, duration)
	var progress := clampf(1.0 - remaining / duration, 0.0, 1.0)
	var late := smoothstep(0.68, 1.0, progress)
	var serial := float(active.get("serial", 0))
	var seed := _dirty_paint_visual_hash(serial, 0.17)
	var base_alpha := 0.18 + late * 0.18
	var cue_window := minf(1.0, DIRTY_PAINT_BOSS_CUE_DURATION / duration)
	if foreground:
		# Only the boss-side cue is lifted above the boss. The three precise
		# marker boundaries remain in the back pass so they never cover sprites.
		var cue := MovementSystemScript.marker_world_position(target, "DrawModule", arena)
		if progress <= cue_window:
			var cue_fade := 1.0 - progress / maxf(0.01, cue_window)
			target.call("draw_arc", cue, 22.0, seed * TAU, seed * TAU + 0.92, 8, Color(0.28, 0.04, 0.28, cue_fade * 0.50), 1.5, true)
			target.call("draw_line", cue + Vector2(-15.0, 3.0), cue + Vector2(-3.0, -3.0), Color(0.78, 0.18, 0.48, cue_fade * 0.72), 1.5, true)
			target.call("draw_line", cue + Vector2(0.0, -3.0), cue + Vector2(15.0, 3.0), Color(0.70, 0.90, 0.92, cue_fade * 0.58), 1.2, true)
			for i in range(2):
				var block_pos := cue + Vector2(-11.0 + float(i) * 19.0, -13.0 + float(i) * 26.0)
				target.call("draw_rect", Rect2(block_pos - Vector2(2.5, 1.2), Vector2(5.0, 2.4)), Color(0.20, 0.04, 0.24, cue_fade * 0.72), true)
		return
	for i in range(count):
		var center := AttackSystemScript.dirty_paint_position_for_arena(arena, i, count)
		var marker_seed := _dirty_paint_visual_hash(seed, float(i) + 0.71)
		var marker_alpha := base_alpha * (0.86 + _dirty_paint_visual_hash(marker_seed, 1.0) * 0.14)
		# A very faint underlay gives the marker a painted footprint without
		# turning the warning into a solid danger circle.
		target.call("draw_circle", center, 132.0, Color(0.24, 0.04, 0.25, marker_alpha * 0.045), true)
		var arc_start := marker_seed * TAU
		for arc_index in range(5):
			var start := arc_start + float(arc_index) * TAU / 5.0 + progress * 0.04
			var span := 0.42 + _dirty_paint_visual_hash(marker_seed, float(arc_index) + 2.0) * 0.22
			var edge_color := Color(0.25, 0.03, 0.29, marker_alpha * 1.65) if arc_index % 2 == 0 else Color(0.66, 0.10, 0.40, marker_alpha * 1.42)
			# Centerline 144px + 2px stroke keeps the formal outer edge at 145px.
			target.call("draw_arc", center, DIRTY_PAINT_RADIUS - 1.0, start, start + span, 9, edge_color, 2.0, true)
			target.call("draw_arc", center, DIRTY_PAINT_RADIUS - 3.1, start + 0.04, start + span - 0.04, 8, Color(1.0, 0.62, 0.78, marker_alpha * 0.52), 1.0, true)
		var brush_angle := arc_start + 1.18
		var brush_dir := Vector2.from_angle(brush_angle)
		target.call("draw_line", center + brush_dir * 108.0, center + brush_dir * (128.0 + late * 5.0), Color(0.70, 0.18, 0.46, marker_alpha * 0.72), 2.0, true)
		target.call("draw_line", center + brush_dir.rotated(0.10) * 111.0, center + brush_dir.rotated(0.10) * 123.0, Color(0.50, 0.83, 0.86, marker_alpha * 0.40), 1.0, true)
		for blot_index in range(3):
			var blot_angle := arc_start + float(blot_index) * 2.05 + progress * 0.08
			var blot_pos := center + Vector2.from_angle(blot_angle) * (86.0 + _dirty_paint_visual_hash(marker_seed, float(blot_index) + 5.0) * 35.0)
			var blot_radius := 6.0 + _dirty_paint_visual_hash(marker_seed, float(blot_index) + 8.0) * 5.0
			target.call("draw_circle", blot_pos, blot_radius, Color(0.54, 0.10, 0.37, marker_alpha * 0.22), true)
		if progress > 0.42:
			for drop_index in range(2):
				var drop_angle := arc_start + 0.72 + float(drop_index) * 2.6
				var drop_pos := center + Vector2.from_angle(drop_angle) * (126.0 + float(drop_index) * 6.0)
				target.call("draw_circle", drop_pos, 2.0, Color(0.70, 0.18, 0.45, marker_alpha * 0.35), true)
		if late > 0.78:
			target.call("draw_circle", center, 4.0 + late * 2.0, Color(1.0, 0.86, 0.92, marker_alpha * 0.20), true)
	# Short DrawingModule brush cue: it gives causality without a line to a
	# future floor position. It is intentionally present only at warning start.
	var cue := MovementSystemScript.marker_world_position(target, "DrawModule", arena)
	if not foreground and progress <= cue_window:
		var cue_fade := 1.0 - progress / maxf(0.01, cue_window)
		target.call("draw_arc", cue, 20.0, seed * TAU + 0.12, seed * TAU + 1.10, 8, Color(0.34, 0.06, 0.34, cue_fade * 0.28), 1.5, true)
		target.call("draw_line", cue + Vector2(-16.0, -2.0), cue + Vector2(7.0, 5.0), Color(0.76, 0.28, 0.56, cue_fade * 0.38), 1.4, true)
		target.call("draw_rect", Rect2(cue + Vector2(10.0, -11.0), Vector2(5.0, 2.0)), Color(0.48, 0.82, 0.86, cue_fade * 0.34), true)

static func _draw_dirty_paint_warning_player_assist(target: Node, active: Dictionary, arena: Rect2, player_pos: Vector2) -> void:
	var payload: Dictionary = active.get("payload", {}) as Dictionary
	var count := maxi(1, int(payload.get("count", 3)))
	var progress := clampf(1.0 - float(active.get("timer", DIRTY_PAINT_WARNING_DURATION)) / maxf(0.01, float(payload.get("telegraph", DIRTY_PAINT_WARNING_DURATION))), 0.0, 1.0)
	for i in range(count):
		var center := AttackSystemScript.dirty_paint_position_for_arena(arena, i, count)
		if center.distance_to(player_pos) > DIRTY_PAINT_RADIUS + 82.0:
			continue
		var direction := player_pos - center
		if direction.length_squared() <= 0.01:
			direction = Vector2.RIGHT
		var angle := direction.angle()
		var alpha := 0.32 + smoothstep(0.70, 1.0, progress) * 0.14
		target.call("draw_arc", center, DIRTY_PAINT_RADIUS - 1.0, angle - 0.44, angle + 0.44, 10, Color(0.70, 0.12, 0.45, alpha), 1.5, true)
		target.call("draw_arc", center, DIRTY_PAINT_RADIUS - 3.1, angle + PI - 0.30, angle + PI + 0.30, 8, Color(1.0, 0.70, 0.82, alpha * 0.66), 0.9, true)

static func _dirty_paint_density(hazard: Dictionary, hazards: Array) -> float:
	var center := Vector2(hazard.get("pos", Vector2.ZERO))
	var nearby := 0
	for item in hazards:
		var other: Dictionary = item as Dictionary
		if other == hazard or not bool(other.get("dirtyPaintVisual", false)):
			continue
		if center.distance_to(Vector2(other.get("pos", Vector2.ZERO))) < DIRTY_PAINT_RADIUS * 1.95:
			nearby += 1
	return 1.0 if nearby <= 0 else maxf(0.46, 1.0 - float(nearby) * 0.18)

static func _draw_dirty_paint_active(target: Node, hazard: Dictionary, hazards: Array) -> void:
	var center := Vector2(hazard.get("pos", Vector2.ZERO))
	var seed := float(hazard.get("dirtyPaintVisualSeed", 0.0))
	var time_left := maxf(0.0, float(hazard.get("time", 0.0)))
	var max_time := maxf(0.01, float(hazard.get("maxTime", 7.0)))
	var dry := 0.0
	if time_left < 0.45:
		dry = 1.0 - clampf(time_left / 0.45, 0.0, 1.0)
	var density := _dirty_paint_density(hazard, hazards)
	var edge_alpha := 0.72 - dry * 0.08
	# The interior is deliberately broken into low-alpha lobes and streaks;
	# the 145px formal boundary stays the strongest visual element.
	target.call("draw_circle", center, 122.0, Color(0.25, 0.04, 0.28, 0.032 * density), true)
	for lobe_index in range(7):
		var lobe_angle := seed * TAU + float(lobe_index) * TAU / 7.0
		var lobe_distance := 88.0 + _dirty_paint_visual_hash(seed, float(lobe_index) + 1.0) * 42.0
		var lobe_pos := center + Vector2.from_angle(lobe_angle) * lobe_distance
		var lobe_radius := 9.0 + _dirty_paint_visual_hash(seed, float(lobe_index) + 2.0) * 8.0
		var lobe_color := Color(0.42, 0.07, 0.32, (0.11 - dry * 0.05) * density) if lobe_index % 2 == 0 else Color(0.58, 0.14, 0.40, (0.075 - dry * 0.035) * density)
		target.call("draw_circle", lobe_pos, lobe_radius, lobe_color, true)
	for streak_index in range(5):
		var streak_angle := seed * TAU + float(streak_index) * 1.19
		var streak_dir := Vector2.from_angle(streak_angle)
		var streak_start := center + streak_dir * (38.0 + float(streak_index) * 8.0)
		var streak_end := streak_start + streak_dir.rotated(0.22) * (18.0 + float(streak_index % 2) * 9.0)
		target.call("draw_line", streak_start, streak_end, Color(0.67, 0.17, 0.46, (0.20 - dry * 0.10) * density), 1.4 + float(streak_index % 2) * 0.5, true)
	# Formal outer edge: centerline 144px + 2px gives an outside edge of 145px.
	for arc_index in range(6):
		var start := seed * TAU + float(arc_index) * TAU / 6.0
		var span := 0.72 if arc_index % 2 == 0 else 0.48
		target.call("draw_arc", center, DIRTY_PAINT_RADIUS - 1.0, start, start + span, 12, Color(0.26, 0.025, 0.30, edge_alpha), DIRTY_PAINT_RAIL_WIDTH, true)
		target.call("draw_arc", center, DIRTY_PAINT_RADIUS - 3.1, start + 0.04, start + span - 0.04, 10, Color(0.86, 0.24, 0.52, edge_alpha * 0.68), DIRTY_PAINT_INNER_RAIL_WIDTH, true)
	for blot_index in range(4):
		var blot_angle := seed * TAU + float(blot_index) * 1.52 + 0.3
		var blot_pos := center + Vector2.from_angle(blot_angle) * (70.0 + float(blot_index) * 13.0)
		target.call("draw_circle", blot_pos, 5.0 + float(blot_index % 2) * 3.0, Color(0.35, 0.06, 0.31, (0.16 - dry * 0.10) * density), true)
	if dry > 0.0:
		for crack_index in range(4):
			var crack_angle := seed * TAU + float(crack_index) * 1.61
			var crack_dir := Vector2.from_angle(crack_angle)
			var crack_origin := center + crack_dir * (36.0 + float(crack_index) * 14.0)
			var crack_points := PackedVector2Array([
				crack_origin,
				crack_origin + crack_dir.rotated(0.54) * 9.0,
				crack_origin + crack_dir.rotated(-0.30) * 16.0
			])
			target.call("draw_polyline", crack_points, Color(0.58, 0.46, 0.56, dry * 0.34), 1.2, true)
	# Tiny droplets remain inside the formal boundary and fade with density.
	for drop_index in range(3):
		var drop_angle := seed * TAU + float(drop_index) * 2.10
		var drop_pos := center + Vector2.from_angle(drop_angle) * (128.0 + float(drop_index) * 3.0)
		target.call("draw_circle", drop_pos, 1.8, Color(0.55, 0.16, 0.43, (0.16 - dry * 0.10) * density), true)

static func _draw_dirty_paint_boss_foreground(target: Node, hazard: Dictionary) -> void:
	var boss_pos := Vector2.ZERO
	var boss_radius := 0.0
	for item in target.get("enemies") as Array:
		var enemy: Dictionary = item as Dictionary
		if bool(enemy.get("relayBoss", false)) or String(enemy.get("bossId", "")) == "last_offline" or String(enemy.get("kind", "")) == "last_offline":
			boss_pos = Vector2(enemy.get("pos", Vector2.ZERO))
			boss_radius = maxf(80.0, float(enemy.get("radius", 100.0)))
			break
	if boss_radius <= 0.0:
		return
	var center := Vector2(hazard.get("pos", Vector2.ZERO))
	if center.distance_to(boss_pos) > boss_radius + DIRTY_PAINT_RADIUS + 24.0:
		return
	var direction := boss_pos - center
	if direction.length_squared() <= 0.01:
		direction = Vector2.RIGHT
	var angle := direction.angle()
	var seed := float(hazard.get("dirtyPaintVisualSeed", 0.0))
	target.call("draw_arc", center, DIRTY_PAINT_RADIUS - 1.0, angle - 0.34, angle + 0.34, 9, Color(0.90, 0.28, 0.58, 0.40), 1.15, true)
	target.call("draw_arc", center, DIRTY_PAINT_RADIUS - 1.0, angle + PI - 0.24, angle + PI + 0.24, 8, Color(0.30, 0.04, 0.34, 0.44), 1.2, true)
	target.call("draw_line", center + Vector2.from_angle(seed * TAU) * 118.0, center + Vector2.from_angle(seed * TAU) * 130.0, Color(0.56, 0.86, 0.84, 0.28), 1.0, true)

static func _draw_dirty_paint_player_assist(target: Node, hazard: Dictionary, player_pos: Vector2) -> void:
	var center := Vector2(hazard.get("pos", Vector2.ZERO))
	var direction := player_pos - center
	if direction.length_squared() <= 0.01:
		direction = Vector2.RIGHT
	var angle := direction.angle()
	var seed := float(hazard.get("dirtyPaintVisualSeed", 0.0))
	target.call("draw_arc", center, DIRTY_PAINT_RADIUS - 1.0, angle - 0.40, angle + 0.40, 10, Color(0.86, 0.22, 0.52, 0.34), 1.15, true)
	target.call("draw_arc", center, DIRTY_PAINT_RADIUS - 1.0, angle + PI - 0.28, angle + PI + 0.28, 8, Color(0.28, 0.03, 0.32, 0.38), 1.15, true)
	target.call("draw_line", center + Vector2.from_angle(seed * TAU) * 120.0, center + Vector2.from_angle(seed * TAU) * 130.0, Color(0.70, 0.88, 0.86, 0.25), 1.0, true)

static func _draw_dirty_paint_foot_smear(target: Node, player_pos: Vector2, seed: float, alpha: float) -> void:
	var tilt := (0.5 + _dirty_paint_visual_hash(seed, 3.0)) * 0.22 - 0.11
	var smear_dir := Vector2.RIGHT.rotated(tilt)
	target.call("draw_line", player_pos - smear_dir * 18.0 + Vector2(0.0, 9.0), player_pos + smear_dir * 18.0 + Vector2(0.0, 9.0), Color(0.42, 0.08, 0.34, alpha * 0.52), 2.4, true)
	target.call("draw_line", player_pos - smear_dir * 11.0 + Vector2(0.0, 12.0), player_pos + smear_dir * 8.0 + Vector2(0.0, 12.0), Color(0.76, 0.20, 0.48, alpha * 0.34), 1.2, true)
	target.call("draw_circle", player_pos + Vector2(0.0, 7.0), 3.0, Color(0.60, 0.14, 0.42, alpha * 0.28), true)

static func _draw_dirty_paint_visual_effects(target: Node, runtime: Dictionary) -> void:
	for item in runtime.get("dirty_paint_visual_effects", []) as Array:
		var effect: Dictionary = item as Dictionary
		var kind := String(effect.get("kind", ""))
		var max_life := maxf(0.01, float(effect.get("maxLife", 0.18)))
		var life := clampf(float(effect.get("life", 0.0)), 0.0, max_life)
		if life <= 0.0:
			continue
		var fade := life / max_life
		var progress := 1.0 - fade
		var pos := Vector2(effect.get("pos", Vector2.ZERO))
		var seed := float(effect.get("visualSeed", 0.0))
		if kind == "dirty_paint_contact_enter":
			_draw_dirty_paint_foot_smear(target, pos, seed, fade * 0.90)
			target.call("draw_arc", pos + Vector2(0.0, 6.0), 11.0 + progress * 8.0, seed * TAU, seed * TAU + 0.95, 8, Color(1.0, 0.64, 0.78, fade * 0.36), 1.4, true)
		elif kind == "dirty_paint_contact_exit":
			target.call("draw_line", pos + Vector2(-18.0, 8.0), pos + Vector2(12.0, 12.0), Color(0.54, 0.10, 0.38, fade * 0.50), 2.0, true)
			target.call("draw_line", pos + Vector2(6.0, 5.0), pos + Vector2(19.0, 1.0), Color(0.78, 0.23, 0.52, fade * 0.34), 1.2, true)
		elif kind == "dirty_paint_expiry":
			for flake_index in range(5):
				var flake_angle := seed * TAU + float(flake_index) * 1.21
				var flake_pos := pos + Vector2.from_angle(flake_angle) * (42.0 + progress * 76.0)
				target.call("draw_rect", Rect2(flake_pos - Vector2(2.5, 1.0), Vector2(5.0, 2.0)), Color(0.52, 0.42, 0.54, fade * 0.48), true)
			var crack := PackedVector2Array([pos + Vector2(-18.0, 2.0), pos + Vector2(-4.0, -4.0), pos + Vector2(9.0, 3.0), pos + Vector2(21.0, -1.0)])
			target.call("draw_polyline", crack, Color(0.72, 0.60, 0.70, fade * 0.42), 1.2, true)
		else:
			var burst := sin(clampf(progress * PI, 0.0, PI))
			target.call("draw_arc", pos, 24.0 + burst * 7.0, seed * TAU, seed * TAU + 1.10, 10, Color(0.28, 0.03, 0.32, fade * 0.56), 1.8, true)
			target.call("draw_line", pos + Vector2(-18.0, 2.0), pos + Vector2(12.0, -6.0), Color(0.72, 0.22, 0.50, fade * 0.66), 2.0, true)
			for drop_index in range(4):
				var drop_angle := seed * TAU + float(drop_index) * 1.57 + progress * 0.4
				var drop_pos := pos + Vector2.from_angle(drop_angle) * (18.0 + float(drop_index % 2) * 13.0 + progress * 12.0)
				target.call("draw_circle", drop_pos, 2.0 + float(drop_index % 2), Color(0.68, 0.16, 0.46, fade * 0.52), true)
			target.call("draw_circle", pos, 3.0 + burst * 3.0, Color(1.0, 0.84, 0.90, fade * 0.30), true)

static func _eraser_sweep_visual_hash(seed: float, salt: float) -> float:
	return fposmod(sin(seed * 47.173 + salt * 23.719) * 43758.5453, 1.0)

static func _eraser_sweep_nearby_count(hazard: Dictionary, hazards: Array) -> int:
	var center := Vector2(hazard.get("pos", Vector2.ZERO))
	var count := 0
	for item in hazards:
		var other: Dictionary = item as Dictionary
		if other == hazard or not bool(other.get("eraserSweepVisual", false)):
			continue
		if center.distance_squared_to(Vector2(other.get("pos", Vector2.ZERO))) <= 176.0 * 176.0:
			count += 1
	return count

static func _draw_eraser_sweep_warning(target: Node, active: Dictionary, arena: Rect2, timer: float, foreground: bool) -> void:
	var payload: Dictionary = active.get("payload", {}) as Dictionary
	var duration := maxf(0.01, float(payload.get("telegraph", 1.20)))
	var remaining := clampf(timer, 0.0, duration)
	var progress := clampf(1.0 - remaining / duration, 0.0, 1.0)
	var late := smoothstep(0.72, 1.0, progress)
	var seed := _eraser_sweep_visual_hash(float(active.get("serial", 0)), 0.17)
	var travel_time := maxf(0.1, float(payload.get("travelTime", 1.0)))
	var geometry := AttackSystemScript.eraser_sweep_geometry_for_arena(arena, travel_time)
	var start_rect: Rect2 = geometry.get("startRect", Rect2(Vector2(arena.position.x - 80.0, arena.position.y + 128.0), Vector2(128.0, maxf(0.0, arena.size.y - 256.0))))
	var path_rect: Rect2 = geometry.get("pathRect", start_rect)
	var safe_top := float(geometry.get("safeTop", start_rect.position.y))
	var safe_bottom := float(geometry.get("safeBottom", start_rect.end.y))
	var center_y := (safe_top + safe_bottom) * 0.5
	var alpha_scale := 0.78 if foreground else 1.0
	var rail_alpha := (0.50 + late * 0.18) * alpha_scale
	var inner_alpha := (0.34 + late * 0.15) * alpha_scale
	if foreground:
		# Only a short slice is lifted over sprites.  The full corridor stays in
		# the back pass so the 128px safety envelope remains readable without
		# hiding the player or the boss.
		var player_pos := Vector2(target.get("player_pos"))
		if player_pos.x >= path_rect.position.x - 96.0 and player_pos.x <= path_rect.end.x + 96.0:
			var local_from_x := maxf(path_rect.position.x, player_pos.x - 92.0)
			var local_to_x := minf(path_rect.end.x, player_pos.x + 92.0)
			if local_to_x > local_from_x:
				target.call("draw_line", Vector2(local_from_x, safe_top + 1.0), Vector2(local_to_x, safe_top + 1.0), Color(0.28, 0.04, 0.25, rail_alpha * 0.72), 1.8, true)
				target.call("draw_line", Vector2(local_from_x, safe_bottom - 1.0), Vector2(local_to_x, safe_bottom - 1.0), Color(0.28, 0.04, 0.25, rail_alpha * 0.72), 1.8, true)
				target.call("draw_line", Vector2(local_from_x, safe_top + 2.7), Vector2(local_to_x, safe_top + 2.7), Color(1.0, 0.84, 0.92, inner_alpha * 0.70), 1.0, true)
				target.call("draw_line", Vector2(local_from_x, safe_bottom - 2.7), Vector2(local_to_x, safe_bottom - 2.7), Color(1.0, 0.84, 0.92, inner_alpha * 0.70), 1.0, true)
		# A compact DrawModule cue reinforces the actual entry side.
		var marker := MovementSystemScript.marker_world_position(target, "DrawModule", arena)
		if progress < 0.18:
			target.call("draw_line", marker + Vector2(-12.0, 0.0), marker + Vector2(12.0, 0.0), Color(1.0, 0.96, 0.92, (1.0 - progress / 0.18) * 0.35), 1.2, true)
		return
	# Very low-alpha corridor underlay: it is an outline and a soft wipe cue,
	# never a solid wall.  The formal rails below are the readable boundary.
	target.call("draw_line", Vector2(path_rect.position.x, center_y), Vector2(path_rect.end.x, center_y), Color(0.24, 0.08, 0.26, 0.020 + late * 0.010), 128.0, true)
	target.call("draw_rect", path_rect, Color(0.20, 0.04, 0.22, 0.20 + late * 0.08), false, 1.0, true)
	var path_length := maxf(1.0, path_rect.size.x)
	for side in [-1.0, 1.0]:
		var y := safe_top + 1.0 if side < 0.0 else safe_bottom - 1.0
		var inner_y := safe_top + 2.7 if side < 0.0 else safe_bottom - 2.7
		for segment_index in range(9):
			var start_t := float(segment_index) / 9.0
			var gap_t := 0.035 + _eraser_sweep_visual_hash(seed, float(segment_index) + (11.0 if side > 0.0 else 0.0)) * 0.028
			var end_t := minf(1.0, start_t + 0.075 - gap_t * 0.25)
			var from_x := path_rect.position.x + path_length * start_t
			var to_x := path_rect.position.x + path_length * end_t
			target.call("draw_line", Vector2(from_x, y), Vector2(to_x, y), Color(0.30, 0.035, 0.26, rail_alpha), 1.8, true)
			target.call("draw_line", Vector2(from_x, inner_y), Vector2(to_x, inner_y), Color(1.0, 0.86, 0.92, inner_alpha), 1.0, true)
	# The actual entry rectangle is shown as a ghost, not as a future target.
	target.call("draw_rect", start_rect, Color(0.26, 0.04, 0.25, 0.22 + late * 0.12), false, 1.4, true)
	target.call("draw_line", Vector2(start_rect.position.x + 1.0, safe_top + 10.0), Vector2(start_rect.position.x + 1.0, safe_bottom - 10.0), Color(0.96, 0.93, 0.88, 0.24 + late * 0.15), 1.0, true)
	# Five small motion ticks/chevrons make the left-to-right action legible.
	for i in range(5):
		var t := 0.12 + float(i) * 0.18
		var x := lerpf(path_rect.position.x, path_rect.end.x, t)
		var y := center_y + (float(i % 2) - 0.5) * 22.0
		var size := 7.0 + late * 3.0
		var tick_alpha := (0.22 + progress * 0.12 + late * 0.12) * (0.78 + _eraser_sweep_visual_hash(seed, float(i) + 31.0) * 0.22)
		target.call("draw_line", Vector2(x - size, y - size * 0.55), Vector2(x, y), Color(0.92, 0.88, 0.84, tick_alpha), 1.4, true)
		target.call("draw_line", Vector2(x, y), Vector2(x - size, y + size * 0.55), Color(0.92, 0.88, 0.84, tick_alpha), 1.4, true)
	# A short, non-causal erase streak stays near the entry side.
	var streak_progress := fposmod(progress * 0.85 + seed, 1.0)
	var streak_x := lerpf(path_rect.position.x, path_rect.end.x, streak_progress)
	target.call("draw_line", Vector2(streak_x - 18.0, center_y - 7.0), Vector2(streak_x + 18.0, center_y - 7.0), Color(1.0, 0.98, 0.93, (0.10 + late * 0.12)), 1.2, true)
	target.call("draw_line", Vector2(streak_x - 12.0, center_y + 8.0), Vector2(streak_x + 9.0, center_y + 8.0), Color(0.76, 0.35, 0.62, 0.08 + late * 0.08), 1.0, true)
	if progress < 0.18:
		var marker := MovementSystemScript.marker_world_position(target, "DrawModule", arena)
		target.call("draw_line", marker + Vector2(-18.0, -5.0), marker + Vector2(18.0, -5.0), Color(1.0, 0.96, 0.92, (1.0 - progress / 0.18) * 0.22), 1.4, true)
		target.call("draw_rect", Rect2(marker + Vector2(-3.0, 7.0), Vector2(6.0, 2.0)), Color(0.76, 0.35, 0.62, (1.0 - progress / 0.18) * 0.18), true)

static func _draw_eraser_sweep_active(target: Node, hazard: Dictionary, hazards: Array) -> void:
	var rect := Rect2(Vector2(hazard.get("pos", Vector2.ZERO)), Vector2(hazard.get("size", Vector2(ERASER_SWEEP_WIDTH, 128.0))))
	var pos := rect.position
	var size := rect.size
	var seed := float(hazard.get("eraserSweepVisualSeed", 0.0))
	var nearby := _eraser_sweep_nearby_count(hazard, hazards)
	var fill_alpha := 0.15 * (1.0 / (1.0 + float(nearby) * 0.22))
	var edge_alpha := 0.78
	var inner_alpha := 0.56
	# The interior is deliberately matte and narrow; the hit envelope is read
	# from the four formal edges, not from a glowing solid rectangle.
	var body := Rect2(pos + Vector2(5.0, 5.0), Vector2(maxf(0.0, size.x - 10.0), maxf(0.0, size.y - 10.0)))
	target.call("draw_rect", body, Color(0.86, 0.83, 0.79, fill_alpha), true)
	# Center each 2px rail one pixel inside the Rect2 edge so its outer edge is
	# exactly the gameplay boundary (top/bottom inclusive/exclusive semantics
	# remain in the attack system).
	target.call("draw_line", Vector2(pos.x + 1.0, pos.y + 1.0), Vector2(pos.x + size.x - 1.0, pos.y + 1.0), Color(0.20, 0.035, 0.23, edge_alpha), 2.0, true)
	target.call("draw_line", Vector2(pos.x + 1.0, pos.y + size.y - 1.0), Vector2(pos.x + size.x - 1.0, pos.y + size.y - 1.0), Color(0.20, 0.035, 0.23, edge_alpha), 2.0, true)
	target.call("draw_line", Vector2(pos.x + 1.0, pos.y + 1.0), Vector2(pos.x + 1.0, pos.y + size.y - 1.0), Color(0.20, 0.035, 0.23, edge_alpha), 2.0, true)
	target.call("draw_line", Vector2(pos.x + size.x - 1.0, pos.y + 1.0), Vector2(pos.x + size.x - 1.0, pos.y + size.y - 1.0), Color(0.20, 0.035, 0.23, edge_alpha), 2.0, true)
	var inner_color := Color(1.0, 0.88, 0.91, inner_alpha)
	target.call("draw_line", Vector2(pos.x + 2.7, pos.y + 2.7), Vector2(pos.x + size.x - 2.7, pos.y + 2.7), inner_color, 1.0, true)
	target.call("draw_line", Vector2(pos.x + 2.7, pos.y + size.y - 2.7), Vector2(pos.x + size.x - 2.7, pos.y + size.y - 2.7), inner_color, 1.0, true)
	target.call("draw_line", Vector2(pos.x + 2.7, pos.y + 2.7), Vector2(pos.x + 2.7, pos.y + size.y - 2.7), inner_color, 1.0, true)
	target.call("draw_line", Vector2(pos.x + size.x - 2.7, pos.y + 2.7), Vector2(pos.x + size.x - 2.7, pos.y + size.y - 2.7), inner_color, 1.0, true)
	# Leading (right) wipe and trailing (left) abrasion.
	for mark_index in range(4):
		var mark_y := pos.y + 30.0 + float(mark_index) * maxf(1.0, (size.y - 60.0) / 3.0)
		var mark_len := 15.0 + _eraser_sweep_visual_hash(seed, float(mark_index) + 3.0) * 15.0
		target.call("draw_line", Vector2(pos.x + size.x - mark_len - 4.0, mark_y), Vector2(pos.x + size.x - 4.0, mark_y), Color(1.0, 0.97, 0.91, 0.50), 2.0, true)
		target.call("draw_line", Vector2(pos.x + 5.0, mark_y + 8.0), Vector2(pos.x + 5.0 + 8.0 + mark_len * 0.22, mark_y + 8.0), Color(0.62, 0.59, 0.60, 0.34), 2.0, true)
	# Fixed scratches/rubbed blocks stay inside the formal envelope.
	for scratch_index in range(7):
		var scratch_y := pos.y + 44.0 + _eraser_sweep_visual_hash(seed, float(scratch_index) + 17.0) * maxf(1.0, size.y - 88.0)
		var scratch_x := pos.x + 14.0 + _eraser_sweep_visual_hash(seed, float(scratch_index) + 27.0) * maxf(1.0, size.x - 44.0)
		var scratch_len := 8.0 + _eraser_sweep_visual_hash(seed, float(scratch_index) + 37.0) * 23.0
		var scratch_color := Color(0.54, 0.48, 0.55, 0.16) if scratch_index % 2 == 0 else Color(0.78, 0.20, 0.50, 0.13)
		target.call("draw_line", Vector2(scratch_x, scratch_y), Vector2(minf(pos.x + size.x - 9.0, scratch_x + scratch_len), scratch_y + (1.0 if scratch_index % 3 == 0 else -1.0)), scratch_color, 1.0, true)
	for crumb_index in range(4):
		var crumb_y := pos.y + 36.0 + _eraser_sweep_visual_hash(seed, float(crumb_index) + 51.0) * maxf(1.0, size.y - 72.0)
		var crumb_x := pos.x + 7.0 + _eraser_sweep_visual_hash(seed, float(crumb_index) + 61.0) * 8.0
		target.call("draw_rect", Rect2(crumb_x, crumb_y, 2.5, 1.4), Color(0.58, 0.45, 0.57, 0.30), true)
	# Tiny defects keep this an eraser/editorial tool, not a laser.
	var defect_y := pos.y + 78.0 + _eraser_sweep_visual_hash(seed, 73.0) * maxf(1.0, size.y - 156.0)
	target.call("draw_rect", Rect2(pos.x + 40.0, defect_y, 7.0, 2.0), Color(0.16, 0.76, 0.78, 0.24), true)
	target.call("draw_rect", Rect2(pos.x + size.x - 34.0, defect_y + 11.0, 6.0, 2.0), Color(0.82, 0.16, 0.48, 0.22), true)

static func _draw_eraser_sweep_boss_foreground(target: Node, hazard: Dictionary, arena: Rect2) -> void:
	var boss_pos := MovementSystemScript.marker_world_position(target, "DrawModule", arena)
	var rect := Rect2(Vector2(hazard.get("pos", Vector2.ZERO)), Vector2(hazard.get("size", Vector2(ERASER_SWEEP_WIDTH, 128.0))))
	if not rect.grow(90.0).has_point(boss_pos):
		return
	var alpha := 0.34
	var y_from := maxf(rect.position.y, boss_pos.y - 74.0)
	var y_to := minf(rect.end.y, boss_pos.y + 74.0)
	if y_to > y_from:
		target.call("draw_line", Vector2(rect.position.x + 1.0, y_from), Vector2(rect.position.x + 1.0, y_to), Color(0.36, 0.05, 0.32, alpha), 1.4, true)
		target.call("draw_line", Vector2(rect.end.x - 1.0, y_from), Vector2(rect.end.x - 1.0, y_to), Color(0.98, 0.85, 0.90, alpha * 0.78), 1.0, true)

static func _draw_eraser_sweep_player_foreground(target: Node, hazard: Dictionary, player_pos: Vector2) -> void:
	var rect := Rect2(Vector2(hazard.get("pos", Vector2.ZERO)), Vector2(hazard.get("size", Vector2(ERASER_SWEEP_WIDTH, 128.0))))
	if not rect.grow(92.0).has_point(player_pos):
		return
	var alpha := 0.38
	var y_from := maxf(rect.position.y, player_pos.y - 78.0)
	var y_to := minf(rect.end.y, player_pos.y + 78.0)
	if y_to > y_from:
		target.call("draw_line", Vector2(rect.position.x + 1.0, y_from), Vector2(rect.position.x + 1.0, y_to), Color(0.28, 0.035, 0.27, alpha), 1.6, true)
		target.call("draw_line", Vector2(rect.end.x - 1.0, y_from), Vector2(rect.end.x - 1.0, y_to), Color(1.0, 0.88, 0.92, alpha * 0.82), 1.0, true)
	var abrasion_x := clampf(player_pos.x, rect.position.x + 8.0, rect.end.x - 8.0)
	target.call("draw_line", Vector2(abrasion_x - 18.0, player_pos.y - 7.0), Vector2(abrasion_x + 17.0, player_pos.y - 7.0), Color(0.86, 0.82, 0.78, alpha * 0.70), 1.2, true)
	target.call("draw_rect", Rect2(abrasion_x + 10.0, player_pos.y + 12.0, 3.0, 2.0), Color(0.78, 0.18, 0.48, alpha * 0.70), true)

static func _draw_eraser_sweep_entry_fx(target: Node, effect: Dictionary, fade: float) -> void:
	var pos := Vector2(effect.get("pos", Vector2.ZERO))
	var seed := float(effect.get("visualSeed", 0.0))
	var progress := 1.0 - fade
	var wipe_x := pos.x + progress * 14.0
	target.call("draw_line", Vector2(wipe_x, pos.y - 54.0), Vector2(wipe_x, pos.y + 54.0), Color(1.0, 0.98, 0.92, fade * 0.70), 2.0, true)
	target.call("draw_line", Vector2(wipe_x - 8.0, pos.y - 43.0), Vector2(wipe_x + 7.0, pos.y - 43.0), Color(0.76, 0.72, 0.71, fade * 0.55), 1.2, true)
	for i in range(4):
		var crumb_pos := pos + Vector2(-10.0 + float(i) * 7.0, -20.0 + _eraser_sweep_visual_hash(seed, float(i) + 2.0) * 40.0)
		target.call("draw_rect", Rect2(crumb_pos, Vector2(3.0, 1.7)), Color(0.60, 0.48, 0.60, fade * 0.48), true)
	target.call("draw_rect", Rect2(pos + Vector2(-22.0, 26.0), Vector2(13.0, 1.5)), Color(0.76, 0.20, 0.50, fade * 0.40), true)

static func _draw_eraser_sweep_wake_fx(target: Node, effect: Dictionary, fade: float) -> void:
	var pos := Vector2(effect.get("pos", Vector2.ZERO))
	var seed := float(effect.get("visualSeed", 0.0))
	var spread := 14.0 + (1.0 - fade) * 18.0
	target.call("draw_line", pos + Vector2(-spread, -8.0), pos + Vector2(-3.0, -8.0), Color(0.62, 0.58, 0.60, fade * 0.42), 1.4, true)
	target.call("draw_line", pos + Vector2(-spread * 0.75, 5.0), pos + Vector2(-5.0, 5.0), Color(0.80, 0.30, 0.55, fade * 0.28), 1.0, true)
	for i in range(3):
		var crumb_pos := pos + Vector2(-16.0 - float(i) * 9.0, (float(i) - 1.0) * 8.0)
		crumb_pos.y += _eraser_sweep_visual_hash(seed, float(i) + 9.0) * 7.0
		target.call("draw_rect", Rect2(crumb_pos, Vector2(3.0, 1.5)), Color(0.55, 0.47, 0.56, fade * 0.40), true)

static func _draw_eraser_sweep_hit_fx(target: Node, effect: Dictionary, fade: float) -> void:
	var pos := Vector2(effect.get("pos", Vector2.ZERO))
	var seed := float(effect.get("visualSeed", 0.0))
	var progress := 1.0 - fade
	var flash := sin(clampf(progress * PI, 0.0, PI))
	target.call("draw_circle", pos, 15.0 + progress * 9.0, Color(1.0, 0.98, 0.92, flash * 0.16), true)
	target.call("draw_line", pos + Vector2(-22.0, -8.0), pos + Vector2(24.0, -8.0), Color(1.0, 0.98, 0.92, fade * 0.64), 2.0, true)
	target.call("draw_line", pos + Vector2(-15.0, 9.0), pos + Vector2(18.0, 9.0), Color(0.58, 0.52, 0.56, fade * 0.46), 1.5, true)
	for i in range(5):
		var angle := seed * TAU + float(i) * 1.13
		var distance := 15.0 + progress * (15.0 + float(i % 2) * 8.0)
		var crumb_pos := pos + Vector2.from_angle(angle) * distance
		target.call("draw_rect", Rect2(crumb_pos - Vector2(2.0, 1.0), Vector2(4.0, 2.0)), Color(0.68, 0.55, 0.65, fade * 0.48), true)
	if flash > 0.0:
		target.call("draw_rect", Rect2(pos + Vector2(8.0, -2.0), Vector2(8.0, 2.0)), Color(0.76, 0.22, 0.50, flash * 0.44), true)

static func _draw_eraser_sweep_visual_effects(target: Node, runtime: Dictionary, hit_only: bool) -> void:
	for item in runtime.get("eraser_sweep_visual_effects", []) as Array:
		var effect: Dictionary = item as Dictionary
		var kind := String(effect.get("kind", ""))
		if hit_only and kind != "eraser_sweep_hit":
			continue
		if not hit_only and kind == "eraser_sweep_hit":
			continue
		var max_life := maxf(0.01, float(effect.get("maxLife", 0.18)))
		var life := clampf(float(effect.get("life", 0.0)), 0.0, max_life)
		if life <= 0.0:
			continue
		var fade := life / max_life
		if kind == "eraser_sweep_entry":
			_draw_eraser_sweep_entry_fx(target, effect, fade)
		elif kind == "eraser_sweep_wake":
			_draw_eraser_sweep_wake_fx(target, effect, fade)
		elif kind == "eraser_sweep_hit":
			_draw_eraser_sweep_hit_fx(target, effect, fade)

static func _paint_warning_visual_hash(seed: float, salt: float) -> float:
	return fposmod(sin(seed * 73.173 + salt * 29.719) * 43758.5453, 1.0)

static func _paint_warning_snapshot(active: Dictionary, target: Node, arena: Rect2) -> Dictionary:
	var center := Vector2(active.get("paintWarningCenterSnapshot", AttackSystemScript.paint_warning_center_for_target(target, arena)))
	var radius := float(active.get("paintWarningRadius", AttackSystemScript.paint_warning_radius_for_arena(arena)))
	return {"center": center, "radius": radius}

static func _draw_paint_warning_warning(target: Node, active: Dictionary, arena: Rect2, timer: float, foreground: bool) -> void:
	var snapshot := _paint_warning_snapshot(active, target, arena)
	var center: Vector2 = snapshot["center"]
	var radius: float = snapshot["radius"]
	var payload: Dictionary = active.get("payload", {}) as Dictionary
	var duration := maxf(0.01, float(active.get("paintWarningWarningDuration", payload.get("telegraph", 1.40))))
	var remaining := clampf(timer, 0.0, duration)
	var progress := clampf(1.0 - remaining / duration, 0.0, 1.0)
	var late := smoothstep(0.68, 1.0, progress)
	var serial := float(active.get("paintWarningSerial", active.get("serial", 0)))
	var seed := float(active.get("paintWarningVisualSeed", _paint_warning_visual_hash(serial, 0.17)))
	if foreground:
		var player_pos := Vector2(target.get("player_pos"))
		if player_pos.distance_to(center) <= radius + 86.0:
			var direction := player_pos - center
			if direction.length_squared() <= 0.01:
				direction = Vector2.RIGHT
			var angle := direction.angle()
			target.call("draw_arc", center, radius - 1.0, angle - 0.25, angle + 0.25, 8, Color(0.38, 0.04, 0.34, 0.34 + late * 0.12), PAINT_WARNING_FORMAL_RAIL_WIDTH, true)
			target.call("draw_arc", center, radius - 3.0, angle + PI - 0.18, angle + PI + 0.18, 7, Color(1.0, 0.73, 0.84, 0.28 + late * 0.12), PAINT_WARNING_INNER_RAIL_WIDTH, true)
		# Keep the boss-side cue local in the front pass; the full formal edge
		# remains in the back pass.
		var cue_fade := 1.0 - smoothstep(0.0, 0.20, duration - remaining)
		if cue_fade > 0.0:
			target.call("draw_line", center + Vector2(-14.0, 4.0), center + Vector2(2.0, -3.0), Color(0.72, 0.20, 0.48, cue_fade * 0.42), 1.4, true)
		return
	# The preview is the same formal geometry as the active hazard. Its fill is
	# intentionally faint, while the broken edge is the readable boundary.
	target.call("draw_circle", center, maxf(0.0, radius - 7.0), Color(0.26, 0.03, 0.28, 0.028 + late * 0.012), true)
	var arc_start := seed * TAU
	for arc_index in range(12):
		var start := arc_start + float(arc_index) * TAU / 12.0
		var span := 0.27 + _paint_warning_visual_hash(seed, float(arc_index) + 1.0) * 0.10
		var edge_alpha := 0.42 + late * 0.18
		var edge_color := Color(0.28, 0.03, 0.31, edge_alpha) if arc_index % 2 == 0 else Color(0.70, 0.10, 0.43, edge_alpha * 0.86)
		target.call("draw_arc", center, radius - 1.0, start, start + span, 8, edge_color, PAINT_WARNING_FORMAL_RAIL_WIDTH, true)
		target.call("draw_arc", center, radius - 3.0, start + 0.035, start + span - 0.035, 7, Color(1.0, 0.69, 0.80, edge_alpha * 0.54), PAINT_WARNING_INNER_RAIL_WIDTH, true)
	for stroke_index in range(5):
		var stroke_angle := arc_start + float(stroke_index) * 1.21
		var stroke_dir := Vector2.from_angle(stroke_angle)
		var stroke_from := center + stroke_dir * (42.0 + float(stroke_index) * 9.0)
		var stroke_to := stroke_from + stroke_dir.rotated(0.18) * (18.0 + late * 5.0)
		target.call("draw_line", stroke_from, stroke_to, Color(0.70, 0.20, 0.50, 0.13 + late * 0.08), 1.5, true)
	for blot_index in range(5):
		var blot_angle := arc_start + float(blot_index) * 1.53
		var blot_pos := center + Vector2.from_angle(blot_angle) * (86.0 + _paint_warning_visual_hash(seed, float(blot_index) + 8.0) * 55.0)
		target.call("draw_circle", blot_pos, 3.0 + _paint_warning_visual_hash(seed, float(blot_index) + 11.0) * 3.0, Color(0.62, 0.13, 0.42, 0.13 + late * 0.08), true)
	if late > 0.0:
		var pulse := sin(late * PI)
		target.call("draw_circle", center, 4.0 + pulse * 4.0, Color(1.0, 0.88, 0.93, pulse * 0.18), true)
	# A short DrawingModule brush cue appears only at the start of the warning.
	var cue_elapsed := duration - remaining
	if cue_elapsed <= 0.20:
		var cue_fade := 1.0 - cue_elapsed / 0.20
		target.call("draw_arc", center, 24.0, arc_start + 0.18, arc_start + 1.08, 8, Color(0.36, 0.05, 0.35, cue_fade * 0.30), 1.5, true)
		target.call("draw_line", center + Vector2(-17.0, -3.0), center + Vector2(11.0, 4.0), Color(1.0, 0.80, 0.88, cue_fade * 0.34), 1.4, true)

static func _draw_paint_warning_active(target: Node, hazard: Dictionary) -> void:
	var center := Vector2(hazard.get("pos", Vector2.ZERO))
	var radius := float(hazard.get("radius", AttackSystemScript.PAINT_WARNING_RADIUS_RATE * 1500.0))
	var seed := float(hazard.get("paintWarningVisualSeed", 0.0))
	var time_left := maxf(0.0, float(hazard.get("time", 0.0)))
	var max_time := maxf(0.01, float(hazard.get("maxTime", 2.5)))
	var fade := clampf(time_left / max_time, 0.0, 1.0)
	var density := 0.70 + fade * 0.20
	target.call("draw_circle", center, maxf(0.0, radius - 8.0), Color(0.29, 0.035, 0.30, 0.034 * density), true)
	# Broken, low-alpha brush lobes keep the wash readable as paint rather than
	# a solid danger disk. Every point stays well inside the authoritative edge.
	for lobe_index in range(9):
		var lobe_angle := seed * TAU + float(lobe_index) * TAU / 9.0
		var lobe_distance := 78.0 + _paint_warning_visual_hash(seed, float(lobe_index) + 1.0) * 150.0
		var lobe_pos := center + Vector2.from_angle(lobe_angle) * lobe_distance
		var lobe_radius := 12.0 + _paint_warning_visual_hash(seed, float(lobe_index) + 2.0) * 13.0
		var lobe_color := Color(0.48, 0.07, 0.34, 0.055 * density) if lobe_index % 2 == 0 else Color(0.68, 0.15, 0.43, 0.040 * density)
		target.call("draw_circle", lobe_pos, lobe_radius, lobe_color, true)
	for stroke_index in range(7):
		var stroke_angle := seed * TAU + float(stroke_index) * 0.89
		var stroke_dir := Vector2.from_angle(stroke_angle)
		var stroke_from := center + stroke_dir * (24.0 + float(stroke_index) * 9.0)
		var stroke_to := stroke_from + stroke_dir.rotated(0.21) * (34.0 + float(stroke_index % 3) * 13.0)
		target.call("draw_line", stroke_from, stroke_to, Color(0.70, 0.16, 0.47, 0.11 * density), 2.0 + float(stroke_index % 2), true)
	# The formal outer edge is strongest and never fades with the remaining
	# active time. Centerline radius-1 plus 2px width places its outer edge at
	# the exact collision radius.
	for arc_index in range(10):
		var start := seed * TAU + float(arc_index) * TAU / 10.0
		var span := 0.36 + _paint_warning_visual_hash(seed, float(arc_index) + 14.0) * 0.18
		target.call("draw_arc", center, radius - 1.0, start, start + span, 10, Color(0.28, 0.025, 0.31, 0.78), PAINT_WARNING_FORMAL_RAIL_WIDTH, true)
		target.call("draw_arc", center, radius - 3.0, start + 0.035, start + span - 0.035, 8, Color(0.94, 0.33, 0.58, 0.56), PAINT_WARNING_INNER_RAIL_WIDTH, true)
	for blot_index in range(5):
		var blot_angle := seed * TAU + float(blot_index) * 1.41 + 0.22
		var blot_pos := center + Vector2.from_angle(blot_angle) * (56.0 + float(blot_index) * 31.0)
		target.call("draw_circle", blot_pos, 4.0 + float(blot_index % 2) * 3.0, Color(0.34, 0.05, 0.29, 0.11 * density), true)
	# Small cyan corruption marks are kept inside the wash and never become a
	# line/laser vocabulary.
	for glitch_index in range(3):
		var glitch_pos := center + Vector2(-42.0 + float(glitch_index) * 33.0, -12.0 + float(glitch_index % 2) * 25.0)
		target.call("draw_rect", Rect2(glitch_pos, Vector2(7.0 + float(glitch_index), 2.0)), Color(0.50, 0.82, 0.83, 0.15 * density), true)

static func _draw_paint_warning_local_assist(target: Node, hazard: Dictionary, player_pos: Vector2) -> void:
	var center := Vector2(hazard.get("pos", Vector2.ZERO))
	var radius := float(hazard.get("radius", 360.0))
	var direction := player_pos - center
	if direction.length_squared() <= 0.01:
		direction = Vector2.RIGHT
	var angle := direction.angle()
	target.call("draw_arc", center, radius - 1.0, angle - 0.26, angle + 0.26, 8, Color(0.45, 0.05, 0.38, 0.40), PAINT_WARNING_FORMAL_RAIL_WIDTH, true)
	target.call("draw_arc", center, radius - 3.0, angle + PI - 0.18, angle + PI + 0.18, 7, Color(1.0, 0.74, 0.84, 0.32), PAINT_WARNING_INNER_RAIL_WIDTH, true)
	target.call("draw_line", center + direction.normalized() * (radius - 40.0), center + direction.normalized() * (radius - 22.0), Color(0.70, 0.18, 0.47, 0.22), 1.2, true)

static func _draw_paint_warning_boss_foreground(target: Node, hazard: Dictionary, _arena: Rect2) -> void:
	var boss_pos := Vector2.ZERO
	var boss_radius := 0.0
	for item in target.get("enemies") as Array:
		var enemy: Dictionary = item as Dictionary
		if bool(enemy.get("relayBoss", false)) or String(enemy.get("bossId", "")) == "last_offline" or String(enemy.get("kind", "")) == "last_offline":
			boss_pos = Vector2(enemy.get("pos", Vector2.ZERO))
			boss_radius = maxf(80.0, float(enemy.get("radius", 100.0)))
			break
	if boss_radius <= 0.0:
		return
	var center := Vector2(hazard.get("pos", Vector2.ZERO))
	if center.distance_to(boss_pos) > boss_radius + 80.0:
		return
	var direction := boss_pos - center
	if direction.length_squared() <= 0.01:
		direction = Vector2.RIGHT
	var angle := direction.angle()
	target.call("draw_arc", center, float(hazard.get("radius", 360.0)) - 1.0, angle - 0.22, angle + 0.22, 8, Color(0.40, 0.04, 0.36, 0.34), PAINT_WARNING_FORMAL_RAIL_WIDTH, true)
	target.call("draw_line", center + direction.normalized() * 328.0, center + direction.normalized() * 344.0, Color(1.0, 0.73, 0.84, 0.24), 1.0, true)

static func _draw_paint_warning_hit_fx(target: Node, effect: Dictionary, fade: float) -> void:
	var pos := Vector2(effect.get("pos", Vector2.ZERO))
	var seed := float(effect.get("visualSeed", 0.0))
	var progress := 1.0 - fade
	var flash := sin(clampf(progress * PI, 0.0, PI))
	target.call("draw_circle", pos, 6.0 + flash * 6.0, Color(1.0, 0.88, 0.93, flash * 0.20), true)
	target.call("draw_line", pos + Vector2(-28.0, -7.0), pos + Vector2(22.0, -7.0), Color(0.72, 0.18, 0.50, fade * 0.58), 2.0, true)
	target.call("draw_line", pos + Vector2(-18.0, 8.0), pos + Vector2(28.0, 5.0), Color(0.35, 0.05, 0.34, fade * 0.48), 1.4, true)
	for fragment_index in range(5):
		var fragment_angle := seed * TAU + float(fragment_index) * 1.19
		var fragment_pos := pos + Vector2.from_angle(fragment_angle) * (12.0 + progress * 18.0)
		target.call("draw_rect", Rect2(fragment_pos - Vector2(2.5, 1.0), Vector2(5.0, 2.0)), Color(0.66, 0.14, 0.45, fade * 0.48), true)
	target.call("draw_arc", pos, 15.0 + progress * 8.0, seed * TAU + 0.2, seed * TAU + 1.22, 9, Color(1.0, 0.78, 0.86, fade * 0.42), 1.2, true)

static func _draw_paint_warning_activation_fx(target: Node, effect: Dictionary, fade: float) -> void:
	var center := Vector2(effect.get("center", effect.get("pos", Vector2.ZERO)))
	var radius := float(effect.get("radius", 360.0))
	var seed := float(effect.get("visualSeed", 0.0))
	var progress := 1.0 - fade
	var pulse := sin(clampf(progress * PI, 0.0, PI))
	target.call("draw_arc", center, radius - 1.0, seed * TAU, seed * TAU + 0.72, 9, Color(1.0, 0.74, 0.84, fade * 0.72), PAINT_WARNING_FORMAL_RAIL_WIDTH, true)
	for streak_index in range(7):
		var angle := seed * TAU + float(streak_index) * 0.83
		var direction := Vector2.from_angle(angle)
		target.call("draw_line", center + direction * (radius - 54.0), center + direction * (radius - 30.0), Color(1.0, 0.82, 0.88, fade * 0.34), 1.4, true)
	if pulse > 0.0:
		target.call("draw_circle", center, 5.0 + pulse * 5.0, Color(1.0, 0.92, 0.95, pulse * 0.18), true)

static func _draw_paint_warning_cadence_fx(target: Node, effect: Dictionary, fade: float) -> void:
	var center := Vector2(effect.get("center", effect.get("pos", Vector2.ZERO)))
	var radius := float(effect.get("radius", 360.0))
	var seed := float(effect.get("visualSeed", 0.0))
	target.call("draw_arc", center, radius - 1.0, seed * TAU + 0.14, seed * TAU + 0.62, 8, Color(1.0, 0.70, 0.82, fade * 0.50), PAINT_WARNING_FORMAL_RAIL_WIDTH, true)
	target.call("draw_line", center + Vector2(-20.0, -8.0), center + Vector2(19.0, -8.0), Color(0.74, 0.20, 0.50, fade * 0.34), 1.5, true)
	target.call("draw_line", center + Vector2(-13.0, 8.0), center + Vector2(24.0, 5.0), Color(0.46, 0.10, 0.38, fade * 0.28), 1.1, true)

static func _draw_paint_warning_visual_effects(target: Node, runtime: Dictionary, hit_only: bool) -> void:
	for item in runtime.get("paint_warning_visual_effects", []) as Array:
		var effect: Dictionary = item as Dictionary
		var kind := String(effect.get("kind", ""))
		if hit_only and kind != "paint_warning_hit":
			continue
		if not hit_only and kind == "paint_warning_hit":
			continue
		var max_life := maxf(0.01, float(effect.get("maxLife", 0.20)))
		var life := clampf(float(effect.get("life", 0.0)), 0.0, max_life)
		if life <= 0.0:
			continue
		var fade := life / max_life
		if kind == "paint_warning_hit":
			_draw_paint_warning_hit_fx(target, effect, fade)
		elif kind == "paint_warning_activation":
			_draw_paint_warning_activation_fx(target, effect, fade)
		elif kind == "paint_warning_cadence":
			_draw_paint_warning_cadence_fx(target, effect, fade)

static func _division_noise_visual_hash(seed: float, salt: float) -> float:
	return fposmod(sin(seed * 12.9898 + salt * 78.233) * 43758.5453, 1.0)

static func _division_noise_live_positions(target: Node) -> Array:
	var player_pos := Vector2(target.get("player_pos"))
	var partner_pos := player_pos
	var partner_value: Variant = target.get("collab_partner_pos")
	if partner_value is Vector2 and (partner_value as Vector2) != Vector2.ZERO:
		partner_pos = partner_value as Vector2
	return [player_pos, partner_pos]

static func _division_noise_warning_positions(target: Node, active: Dictionary) -> Array:
	if active.has("divisionNoiseWarningPlayerAnchor") and active.has("divisionNoiseWarningPartnerAnchor"):
		return [Vector2(active.get("divisionNoiseWarningPlayerAnchor")), Vector2(active.get("divisionNoiseWarningPartnerAnchor"))]
	return _division_noise_live_positions(target)

static func _division_noise_boss_position(target: Node, arena: Rect2) -> Vector2:
	for item in target.get("enemies") as Array:
		var enemy: Dictionary = item as Dictionary
		if bool(enemy.get("relayBoss", false)) or String(enemy.get("bossId", "")) == "last_offline" or String(enemy.get("kind", "")) == "last_offline":
			return Vector2(enemy.get("pos", arena.get_center()))
	return arena.get_center()

static func _draw_division_noise_warning(target: Node, active: Dictionary, arena: Rect2, timer: float, foreground: bool) -> void:
	var payload: Dictionary = active.get("payload", {}) as Dictionary
	var duration := maxf(0.01, float(active.get("divisionNoiseWarningDuration", payload.get("telegraph", 0.8))))
	var remaining := clampf(timer, 0.0, duration)
	var progress := clampf(1.0 - remaining / duration, 0.0, 1.0)
	var lock_progress := smoothstep(0.44, 0.62, progress)
	var final_progress := smoothstep(0.78, 1.0, progress)
	var seed := float(active.get("divisionNoiseVisualSeed", 0.0))
	if foreground:
		# The relay front pass owns only the compact boss cue.  Full anchor
		# geometry stays behind sprites; the player/partner local rims are drawn
		# by draw_division_noise_player_foreground_for_target().
		var boss_pos := _division_noise_boss_position(target, arena)
		var boss_seed := seed + 4.3
		var cue_alpha := 0.22 + progress * 0.16 + final_progress * 0.12
		for i in range(2):
			var chip_pos := boss_pos + Vector2(-18.0 + float(i) * 22.0, -92.0 - float(i) * 5.0)
			target.call("draw_rect", Rect2(chip_pos - Vector2(8.0, 2.0), Vector2(16.0, 4.0)), Color(0.08, 0.02, 0.16, cue_alpha), true)
			target.call("draw_line", chip_pos - Vector2(6.0, 0.0), chip_pos + Vector2(4.0, 0.0), Color(0.84, 0.95, 1.0, cue_alpha * 0.78), 1.1, true)
		target.call("draw_arc", boss_pos + Vector2(0.0, -76.0), 13.0 + final_progress * 3.0, boss_seed, boss_seed + 1.0, 7, Color(1.0, 0.92, 1.0, cue_alpha * 0.56), 1.2, true)
		return
	var alpha_scale := 0.62 if foreground else 1.0
	var positions := _division_noise_warning_positions(target, active)
	var locked := bool(active.get("divisionNoiseAnchorLocked", false)) or remaining <= DIVISION_NOISE_WARNING_LOCK_REMAINING
	for index in range(mini(2, positions.size())):
		var center: Vector2 = positions[index]
		var index_seed := seed + float(index) * 0.73
		var pulse := 0.5 + 0.5 * sin(index_seed * 4.0 + progress * TAU * 1.25)
		var radius := 45.0 if locked else lerpf(42.0, 45.0, lock_progress)
		# The warning is intentionally quieter than ACTIVE, but the formal edge
		# must survive the pale relay background and the character sprites.
		var base_alpha := (0.46 + progress * 0.16 + final_progress * 0.14) * alpha_scale
		if not foreground:
			target.call("draw_circle", center, radius - 3.5, Color(0.18, 0.02, 0.20, base_alpha * 0.035), true)
		for arc_index in range(4):
			var start := index_seed + float(arc_index) * TAU / 4.0 + progress * (0.11 if arc_index % 2 == 0 else -0.07)
			var length := 0.66 + lock_progress * 0.18
			var arc_color := Color(0.14, 0.72, 0.94, base_alpha * 0.82) if arc_index % 2 == 0 else Color(0.98, 0.12, 0.62, base_alpha * 0.92)
			target.call("draw_arc", center, radius, start, start + length, 10, arc_color, DIVISION_NOISE_RAIL_WIDTH if locked else 1.5, true)
			if locked:
				target.call("draw_arc", center, radius - 1.5, start + 0.05, start + length - 0.08, 8, Color(0.98, 0.88, 1.0, base_alpha * 0.62), DIVISION_NOISE_INNER_RAIL_WIDTH, true)
		var bracket_dir := Vector2.from_angle(index_seed + 0.3)
		var bracket_side := Vector2(-bracket_dir.y, bracket_dir.x)
		var bracket_center := center + bracket_dir * (radius + 5.0)
		target.call("draw_line", bracket_center - bracket_side * 7.0, bracket_center + bracket_side * 7.0, Color(0.70, 0.91, 1.0, base_alpha * 0.64), 1.2, true)
		if final_progress > 0.0:
			target.call("draw_circle", center, radius + 4.0 + pulse * 2.0, Color(1.0, 0.92, 1.0, final_progress * 0.12 * alpha_scale), false, 1.0, true)
	var first: Vector2 = positions[0] if positions.size() > 0 else Vector2.ZERO
	var second: Vector2 = positions[1] if positions.size() > 1 else first
	var link := second - first
	if link.length_squared() > 0.01:
		var direction := link.normalized()
		var gap := 0.10 + final_progress * 0.08
		var link_alpha := (0.18 + progress * 0.12) * alpha_scale
		target.call("draw_line", first.lerp(second, 0.10), first.lerp(second, 0.43 - gap), Color(0.84, 0.95, 1.0, link_alpha), 1.2, true)
		target.call("draw_line", first.lerp(second, 0.57 + gap), first.lerp(second, 0.90), Color(1.0, 0.22, 0.68, link_alpha * 0.84), 1.2, true)
		var crack_center := first.lerp(second, 0.5)
		target.call("draw_line", crack_center - direction.rotated(0.58) * 8.0, crack_center - direction.rotated(0.58) * 2.0, Color(0.11, 0.02, 0.16, link_alpha * 1.5), 2.0, true)
		target.call("draw_line", crack_center + direction.rotated(-0.55) * 2.0, crack_center + direction.rotated(-0.55) * 8.0, Color(0.11, 0.02, 0.16, link_alpha * 1.5), 2.0, true)
	# Two asymmetric noise blocks are a generic child hint, never a promise of
	# the later RNG-derived child positions.
	var midpoint := first.lerp(second, 0.5)
	var perpendicular := link.normalized().orthogonal() if link.length_squared() > 0.01 else Vector2.UP
	for i in range(2):
		var block_pos := midpoint + perpendicular * (float(i) * 22.0 - 11.0) + Vector2(0.0, -8.0 + float(i) * 3.0)
		var block_alpha := (0.16 + progress * 0.15 + final_progress * 0.10) * alpha_scale
		target.call("draw_rect", Rect2(block_pos - Vector2(4.0, 2.0), Vector2(8.0, 4.0)), Color(0.09, 0.02, 0.16, block_alpha), true)
		target.call("draw_line", block_pos - Vector2(5.0, 0.0), block_pos + Vector2(4.0, 0.0), Color(0.96, 0.22, 0.68, block_alpha * 0.90), 1.0, true)

static func _draw_division_noise_anchor(target: Node, hazard: Dictionary) -> void:
	var center := Vector2(hazard.get("pos", Vector2.ZERO))
	var radius := float(hazard.get("radius", DIVISION_NOISE_ANCHOR_RADIUS))
	var max_time := maxf(0.01, float(hazard.get("maxTime", 4.0)))
	var remaining := clampf(float(hazard.get("time", 0.0)), 0.0, max_time)
	var life_alpha := 0.58 + clampf(remaining / max_time, 0.0, 1.0) * 0.30
	var seed := float(hazard.get("divisionNoiseVisualSeed", 0.0))
	var spent := float(hazard.get("hitTimer", 0.0)) > 0.0
	if spent:
		life_alpha *= 0.76
	target.call("draw_circle", center, radius - 3.0, Color(0.13, 0.02, 0.18, 0.035 * life_alpha), true)
	for i in range(4):
		var start := seed + float(i) * TAU / 4.0 + 0.08
		var end := start + (0.72 if i != 2 else 0.42)
		var color := Color(0.14, 0.72, 0.94, life_alpha * 0.82) if i % 2 == 0 else Color(0.98, 0.18, 0.68, life_alpha * 0.84)
		target.call("draw_arc", center, radius - 1.0, start, end, 12, color, DIVISION_NOISE_RAIL_WIDTH, true)
		target.call("draw_arc", center, radius - 2.7, start + 0.05, end - 0.08, 8, Color(0.98, 0.89, 1.0, life_alpha * 0.38), DIVISION_NOISE_INNER_RAIL_WIDTH, true)
	var notch_angle := seed + 2.3
	var notch_dir := Vector2.from_angle(notch_angle)
	target.call("draw_line", center + notch_dir * (radius - 7.0), center + notch_dir * (radius + 3.0), Color(1.0, 0.94, 1.0, life_alpha * 0.66), 1.3, true)
	target.call("draw_line", center - notch_dir * (radius - 8.0), center - notch_dir * (radius - 1.0), Color(0.28, 0.90, 1.0, life_alpha * 0.42), 1.0, true)

static func _draw_division_noise_active_link(target: Node, active: Dictionary, runtime: Dictionary) -> void:
	if String(active.get("state", AttackSystemScript.STATE_IDLE)) != AttackSystemScript.STATE_ACTIVE:
		return
	var anchors: Array = []
	for item in runtime.get("hazards", []) as Array:
		var hazard: Dictionary = item as Dictionary
		if not bool(hazard.get("divisionNoiseAnchor", false)):
			continue
		anchors.append(Vector2(hazard.get("pos", Vector2.ZERO)))
	if anchors.size() < 2:
		return
	var first: Vector2 = anchors[0]
	var second: Vector2 = anchors[1]
	var segment := second - first
	if segment.length_squared() <= 0.01:
		return
	var direction := segment.normalized()
	var link_alpha := 0.22 + clampf(float(active.get("timer", 0.0)) / maxf(0.01, float((active.get("payload", {}) as Dictionary).get("activeDuration", 4.0))), 0.0, 1.0) * 0.18
	target.call("draw_line", first.lerp(second, 0.10), first.lerp(second, 0.42), Color(0.16, 0.78, 1.0, link_alpha), 1.5, true)
	target.call("draw_line", first.lerp(second, 0.58), first.lerp(second, 0.90), Color(1.0, 0.18, 0.66, link_alpha * 0.92), 1.5, true)
	var crack := first.lerp(second, 0.5)
	target.call("draw_line", crack - direction.rotated(0.58) * 9.0, crack - direction.rotated(0.58) * 2.0, Color(0.08, 0.01, 0.13, link_alpha * 1.8), 2.0, true)
	target.call("draw_line", crack + direction.rotated(-0.55) * 2.0, crack + direction.rotated(-0.55) * 9.0, Color(0.08, 0.01, 0.13, link_alpha * 1.8), 2.0, true)

static func _draw_division_noise_foreground(target: Node, hazard: Dictionary) -> void:
	var center := Vector2(hazard.get("pos", Vector2.ZERO))
	var player_pos := Vector2(target.get("player_pos"))
	var partner_pos := Vector2(target.get("collab_partner_pos"))
	var near := player_pos.distance_to(center) <= 76.0 or partner_pos.distance_to(center) <= 76.0
	if not near:
		return
	var seed := float(hazard.get("divisionNoiseVisualSeed", 0.0))
	var radius := float(hazard.get("radius", DIVISION_NOISE_ANCHOR_RADIUS))
	var view_pos := player_pos if player_pos.distance_to(center) <= partner_pos.distance_to(center) else partner_pos
	var direction := (view_pos - center).normalized()
	if direction.length_squared() <= 0.01:
		direction = Vector2.RIGHT
	var side := Vector2(-direction.y, direction.x)
	target.call("draw_arc", center, radius - 1.0, direction.angle() - 0.70, direction.angle() + 0.70, 10, Color(0.22, 0.88, 1.0, 0.44), 1.4, true)
	target.call("draw_arc", center, radius - 1.0, direction.angle() + PI - 0.62, direction.angle() + PI + 0.62, 10, Color(1.0, 0.20, 0.68, 0.40), 1.3, true)
	target.call("draw_line", center + side * 5.0, center + side * 17.0, Color(1.0, 0.92, 1.0, 0.42), 1.1, true)
	target.call("draw_line", center - side * 5.0, center - side * 13.0, Color(0.10, 0.02, 0.16, 0.48), 1.1, true)
	var block_pos := center + direction * (radius - 3.0) + side * ((_division_noise_visual_hash(seed, 8.0) - 0.5) * 5.0)
	target.call("draw_rect", Rect2(block_pos - Vector2(4.0, 1.2), Vector2(8.0, 2.4)), Color(0.96, 0.24, 0.70, 0.34), true)

static func _draw_division_noise_warning_local_foreground(target: Node, active: Dictionary) -> void:
	var player_pos := Vector2(target.get("player_pos"))
	var partner_pos := Vector2(target.get("collab_partner_pos"))
	var positions := _division_noise_warning_positions(target, active)
	var seed := float(active.get("divisionNoiseVisualSeed", 0.0))
	for index in range(mini(2, positions.size())):
		var center: Vector2 = positions[index]
		var view_pos := player_pos if index == 0 else partner_pos
		if view_pos.distance_to(center) > 76.0:
			continue
		var direction := view_pos - center
		if direction.length_squared() <= 0.01:
			direction = Vector2.RIGHT
		var angle := direction.angle()
		var radius := 45.0
		var color := Color(0.30, 0.90, 1.0, 0.40) if index == 0 else Color(1.0, 0.20, 0.68, 0.36)
		target.call("draw_arc", center, radius, angle - 0.70, angle + 0.70, 10, color, 1.4, true)
		target.call("draw_line", center + direction.normalized() * (radius - 4.0), center + direction.normalized() * (radius + 3.0), Color(1.0, 0.94, 1.0, 0.38), 1.0, true)
		var side := Vector2(-direction.y, direction.x).normalized()
		var notch_seed := seed + float(index) * 0.73
		target.call("draw_line", center + side * 5.0, center + side * (14.0 + _division_noise_visual_hash(notch_seed, 3.0) * 4.0), Color(0.08, 0.02, 0.16, 0.42), 1.0, true)

static func _draw_division_noise_effects(target: Node, runtime: Dictionary, hit_only: bool) -> void:
	for item in runtime.get("division_noise_visual_effects", []) as Array:
		var effect: Dictionary = item as Dictionary
		var kind := String(effect.get("kind", ""))
		if not kind.begins_with("relay_division_noise_"):
			continue
		var is_hit := kind == "relay_division_noise_anchor_hit" or kind.ends_with("_child_contact") or kind.ends_with("_child_defeat")
		if hit_only != is_hit:
			continue
		var max_life := maxf(0.01, float(effect.get("maxLife", 0.18)))
		var life := clampf(float(effect.get("life", 0.0)), 0.0, max_life)
		if life <= 0.0:
			continue
		var fade := life / max_life
		var progress := 1.0 - fade
		var pos := Vector2(effect.get("pos", Vector2.ZERO))
		var seed := float(effect.get("visualSeed", 0.0))
		if kind == "relay_division_noise_anchor_activation":
			var radius := 17.0 + sin(progress * PI) * 5.0
			target.call("draw_arc", pos, radius, seed, seed + 1.9, 12, Color(0.28, 0.90, 1.0, fade * 0.56), 1.4, true)
			target.call("draw_arc", pos, radius + 3.0, seed + 2.2, seed + 3.5, 10, Color(1.0, 0.24, 0.70, fade * 0.48), 1.3, true)
		elif kind == "relay_division_noise_child_spawn":
			var burst := sin(progress * PI)
			target.call("draw_line", pos + Vector2(-12.0, 0.0), pos + Vector2(12.0, 0.0), Color(1.0, 0.96, 1.0, fade * (0.38 + burst * 0.28)), 1.2, true)
			for i in range(4):
				var fragment_dir := Vector2.from_angle(seed + float(i) * 1.57)
				var fragment_pos := pos + fragment_dir * (10.0 + burst * 10.0)
				target.call("draw_rect", Rect2(fragment_pos - Vector2(2.5, 1.2), Vector2(5.0, 2.4)), Color(0.08, 0.02, 0.16, fade * 0.55), true)
				target.call("draw_line", fragment_pos, fragment_pos + fragment_dir * 5.0, Color(0.96, 0.24, 0.70, fade * 0.48), 1.0, true)
		elif kind == "relay_division_noise_child_expiry":
			var collapse := progress
			target.call("draw_arc", pos, lerpf(18.0, 8.0, collapse), seed, seed + 1.8, 10, Color(0.26, 0.88, 1.0, fade * 0.34), 1.1, true)
			target.call("draw_line", pos - Vector2(9.0, 0.0), pos + Vector2(9.0, 0.0), Color(0.10, 0.02, 0.16, fade * 0.44), 1.2, true)
		else:
			var burst := sin(progress * PI)
			target.call("draw_circle", pos, 4.0 + burst * 4.0, Color(1.0, 0.96, 1.0, fade * 0.22), true)
			for i in range(4):
				var fragment_dir := Vector2.from_angle(seed + float(i) * 1.57 + 0.3)
				var fragment_pos := pos + fragment_dir * (7.0 + burst * 14.0)
				target.call("draw_line", fragment_pos - fragment_dir * 4.0, fragment_pos + fragment_dir * 3.0, Color(0.22, 0.88, 1.0, fade * 0.62 if i % 2 == 0 else fade * 0.50), 1.3, true)
				target.call("draw_rect", Rect2(fragment_pos - Vector2(2.0, 1.0), Vector2(4.0, 2.0)), Color(1.0, 0.20, 0.68, fade * 0.44), true)

static func _draw_hazards(target: Node, hazards: Array, arena: Rect2) -> void:
	for item in hazards:
		var hazard: Dictionary = item as Dictionary
		if String(hazard.get("kind", "")) == "offline_laser":
			_draw_offline_laser_active(target, hazard, arena)
			continue
		if bool(hazard.get("kusoMaroDropVisual", false)):
			_draw_kuso_maro_drop_hazard(target, hazard, hazards)
			continue
		if bool(hazard.get("longCommentLineVisual", false)):
			_draw_long_comment_line_active(target, hazard)
			continue
		if bool(hazard.get("raceLaneChargeVisual", false)):
			_draw_race_lane_charge_active(target, hazard, hazards)
			continue
		if bool(hazard.get("howlingRingVisual", false)) or String(hazard.get("kind", "")) == "howling_ring":
			_draw_howling_ring_active(target, hazard, hazards)
			continue
		if bool(hazard.get("pitchWaveVisual", false)):
			_draw_pitch_wave_active(target, hazard, hazards)
			continue
		if bool(hazard.get("rhythmExplosionVisual", false)):
			_draw_rhythm_explosion_active(target, hazard, hazards)
			continue
		if bool(hazard.get("dirtyPaintVisual", false)) or String(hazard.get("kind", "")) == "dirty_paint":
			_draw_dirty_paint_active(target, hazard, hazards)
			continue
		if bool(hazard.get("eraserSweepVisual", false)) or String(hazard.get("kind", "")) == "eraser_sweep":
			_draw_eraser_sweep_active(target, hazard, hazards)
			continue
		if bool(hazard.get("paintWarningVisual", false)) or String(hazard.get("kind", "")) == "paint_warning":
			_draw_paint_warning_active(target, hazard)
			continue
		if bool(hazard.get("divisionNoiseAnchor", false)) or String(hazard.get("kind", "")) == "division_noise":
			_draw_division_noise_anchor(target, hazard)
			continue
		var alpha := clampf(float(hazard.get("time", 0.0)) / maxf(0.1, float(hazard.get("maxTime", 1.0))), 0.25, 0.85)
		var color := Color(1.0, 0.24, 0.52, alpha)
		match String(hazard.get("shape", "circle")):
			"circle":
				target.call("draw_circle", Vector2(hazard.get("pos", Vector2.ZERO)), float(hazard.get("radius", 30.0)), color)
			"ring":
				target.call("draw_arc", Vector2(hazard.get("pos", Vector2.ZERO)), float(hazard.get("radius", 100.0)), 0.0, TAU, 48, color, float(hazard.get("width", 18.0)))
			"line":
				target.call("draw_line", Vector2(hazard.get("from", Vector2.ZERO)), Vector2(hazard.get("to", Vector2.ZERO)), color, float(hazard.get("width", 20.0)))
			"rect":
				target.call("draw_rect", Rect2(Vector2(hazard.get("pos", Vector2.ZERO)), Vector2(hazard.get("size", Vector2(80.0, 80.0)))), color, true)

static func _travel_noise_summon_boss_bounds(target: Node) -> Rect2:
	for item in target.get("enemies") as Array:
		var enemy: Dictionary = item as Dictionary
		if not bool(enemy.get("relayBoss", false)) and String(enemy.get("bossId", "")) != "last_offline" and String(enemy.get("kind", "")) != "last_offline":
			continue
		var size := Vector2(enemy.get("visualOpaqueSize", Vector2(500.0, 450.0)))
		var scale_vector := Vector2(enemy.get("visualScaleVector", Vector2.ONE))
		var center := Vector2(enemy.get("pos", Vector2.ZERO)) + Vector2(enemy.get("visualOffset", Vector2.ZERO))
		return Rect2(center - size * scale_vector * 0.5, size * scale_vector)
	return Rect2()

static func _draw_travel_noise_summon_pending_warning(target: Node, runtime: Dictionary, arena: Rect2, foreground: bool) -> void:
	var pending: Dictionary = runtime.get("noise_summon_pending_wave", {}) as Dictionary
	if pending.is_empty() or String(pending.get("source", "")) != "travel_support":
		return
	var marker := Vector2(pending.get("reservedPosition", Vector2.ZERO))
	if not arena.grow(120.0).has_point(marker):
		return
	var boss_bounds := _travel_noise_summon_boss_bounds(target)
	if foreground and not boss_bounds.grow(10.0).has_point(marker):
		return
	var duration := maxf(0.01, float(pending.get("warningDuration", 0.60)))
	var remaining := clampf(float(pending.get("warningTimer", duration)), 0.0, duration)
	var progress := clampf(1.0 - remaining / duration, 0.0, 1.0)
	var seed := fposmod(float(pending.get("travelNoiseVisualSeed", 0.0)), 1.0)
	var phase := seed * TAU
	var late := smoothstep(0.68, 1.0, progress)
	var tick := 0.5 + 0.5 * sin(phase + progress * TAU * 5.0)
	var alpha := (0.42 + late * 0.24 + tick * 0.05) * (0.74 if foreground else 1.0)
	var ring_radius := lerpf(27.0, 21.0, progress)
	if foreground:
		# Only a local assist is placed above the boss image. The complete
		# warning remains in the back pass and this pass never draws a full body.
		target.call("draw_arc", marker, ring_radius, phase + 0.10, phase + 1.02, 8, Color(0.18, 0.92, 1.0, alpha * 0.78), 1.8, true)
		target.call("draw_arc", marker, ring_radius + 2.0, phase + 2.18, phase + 3.05, 8, Color(1.0, 0.20, 0.68, alpha * 0.76), 1.7, true)
		for i in range(2):
			var block_angle := phase + 1.5 + float(i) * 2.2
			var block_pos := marker + Vector2.from_angle(block_angle) * (ring_radius + 3.0)
			target.call("draw_rect", Rect2(block_pos - Vector2(4.0, 1.5), Vector2(8.0, 3.0)), Color(0.10, 0.03, 0.18, alpha * 0.72), true)
		return
	# World-fixed marker: broken ring, static brackets, small signal blocks,
	# ghost silhouette, and inward timing ticks. It is not a danger disk.
	target.call("draw_arc", marker, ring_radius, phase + 0.08, phase + 1.20, 10, Color(0.18, 0.92, 1.0, alpha * 0.88), 1.8, true)
	target.call("draw_arc", marker, ring_radius, phase + 1.66, phase + 2.52, 9, Color(1.0, 0.20, 0.68, alpha * 0.82), 1.8, true)
	target.call("draw_arc", marker, ring_radius, phase + 3.08, phase + 4.08, 9, Color(0.18, 0.92, 1.0, alpha * 0.66), 1.4, true)
	target.call("draw_arc", marker, ring_radius, phase + 4.54, phase + 5.28, 8, Color(1.0, 0.20, 0.68, alpha * 0.62), 1.4, true)
	for i in range(4):
		var bracket_angle := phase + float(i) * TAU / 4.0 + 0.18
		var bracket_dir := Vector2.from_angle(bracket_angle)
		var bracket_side := Vector2(-bracket_dir.y, bracket_dir.x)
		var bracket_center := marker + bracket_dir * (ring_radius + 6.0)
		target.call("draw_line", bracket_center - bracket_dir * 5.0 - bracket_side * 5.0, bracket_center - bracket_dir * 1.0 - bracket_side * 5.0, Color(0.74, 0.94, 1.0, alpha * 0.72), 1.2, true)
		target.call("draw_line", bracket_center - bracket_dir * 5.0 - bracket_side * 5.0, bracket_center - bracket_dir * 5.0 - bracket_side * 1.0, Color(1.0, 0.34, 0.72, alpha * 0.68), 1.2, true)
		var tick_start := marker + bracket_dir * (ring_radius + 8.0)
		var tick_end := marker + bracket_dir * (ring_radius - 2.0)
		target.call("draw_line", tick_start, tick_end, Color(1.0, 0.96, 1.0, alpha * (0.44 + late * 0.34)), 1.0, true)
	for i in range(4):
		var block_angle := phase + float(i) * 1.43
		var block_distance := ring_radius + 8.0 + _noise_visual_hash(seed, 20 + i) * 5.0
		var block_pos := marker + Vector2.from_angle(block_angle) * block_distance
		var block_size := Vector2(5.0 + float(i % 2) * 2.0, 2.0 + float((i + 1) % 2))
		var block_color := Color(0.08, 0.03, 0.18, alpha * 0.82) if i % 2 == 0 else Color(1.0, 0.22, 0.68, alpha * 0.70)
		target.call("draw_rect", Rect2(block_pos - block_size * 0.5, block_size), block_color, true)
	var ghost_pos := marker + Vector2(0.0, 1.0)
	target.call("draw_circle", ghost_pos + Vector2(0.0, 2.0), 6.5, Color(0.08, 0.03, 0.18, alpha * 0.62), true)
	target.call("draw_arc", ghost_pos, 8.0, PI + 0.18, TAU - 0.18, 8, Color(0.76, 0.94, 1.0, alpha * 0.78), 1.2, true)
	target.call("draw_line", ghost_pos + Vector2(-3.0, -1.0), ghost_pos + Vector2(-1.0, -1.0), Color(1.0, 0.94, 1.0, alpha * 0.82), 1.0, true)
	target.call("draw_line", ghost_pos + Vector2(1.0, -1.0), ghost_pos + Vector2(3.0, -1.0), Color(1.0, 0.94, 1.0, alpha * 0.82), 1.0, true)

static func _draw_travel_noise_summon_front_effects(target: Node, runtime: Dictionary, _arena: Rect2) -> void:
	var boss_bounds := _travel_noise_summon_boss_bounds(target)
	if boss_bounds.size == Vector2.ZERO:
		return
	for item in runtime.get("noise_summon_visual_effects", []) as Array:
		var effect: Dictionary = item as Dictionary
		if String(effect.get("sourceKind", "")) != "travel_noise_summon":
			continue
		var pos := Vector2(effect.get("pos", Vector2.ZERO))
		if not boss_bounds.grow(10.0).has_point(pos):
			continue
		var life := maxf(0.0, float(effect.get("life", 0.0)))
		var max_life := maxf(0.01, float(effect.get("maxLife", 0.18)))
		if life <= 0.0:
			continue
		var alpha := clampf(life / max_life, 0.0, 1.0) * clampf(float(effect.get("strength", 1.0)), 0.0, 1.0) * 0.78
		var seed := fposmod(float(effect.get("travelNoiseVisualSeed", effect.get("visualSeed", 0.0))), 1.0) * TAU
		var radius := 17.0 + (1.0 - life / max_life) * 5.0
		target.call("draw_arc", pos, radius, seed + 0.16, seed + 1.02, 7, Color(0.24, 0.90, 1.0, alpha), 1.6, true)
		target.call("draw_arc", pos, radius + 2.0, seed + 2.14, seed + 2.92, 7, Color(1.0, 0.22, 0.68, alpha * 0.88), 1.4, true)
		for i in range(2):
			var block_pos := pos + Vector2.from_angle(seed + 1.3 + float(i) * 2.2) * (radius + 3.0)
			target.call("draw_rect", Rect2(block_pos - Vector2(4.0, 1.5), Vector2(8.0, 3.0)), Color(0.08, 0.02, 0.16, alpha * 0.74), true)

static func _noise_visual_hash(seed: float, salt: int) -> float:
	return fposmod(sin(seed * 12.9898 + float(salt) * 78.233) * 43758.5453, 1.0)

static func _draw_noise_summon_warning(target: Node, active: Dictionary, arena: Rect2, timer: float, foreground: bool) -> void:
	var marker := MovementSystemScript.marker_world_position(target, "ChatModule", arena)
	var duration := maxf(0.01, float(active.get("noiseSummonWarningVisualDuration", (active.get("payload", {}) as Dictionary).get("telegraph", 1.0))))
	var remaining := clampf(timer, 0.0, duration)
	var progress := clampf(1.0 - remaining / duration, 0.0, 1.0)
	var seed := float(active.get("noiseSummonWarningVisualSeed", 0.0))
	var mid := smoothstep(0.45, 0.82, progress)
	var final_pulse := smoothstep(0.85, 1.0, progress)
	var pulse := sin(final_pulse * PI)
	var ring_radius := 58.0 + mid * 4.0 + pulse * 3.0
	var alpha := (0.26 + mid * 0.20 + final_pulse * 0.15) * (0.72 if foreground else 1.0)
	if not foreground:
		target.call("draw_circle", marker, ring_radius - 3.0, Color(0.05, 0.02, 0.13, 0.025 + mid * 0.018), true)
	for i in range(5):
		var segment_start := seed + float(i) * TAU / 5.0 + progress * (0.22 if i % 2 == 0 else -0.15)
		var gap := 0.18 + mid * 0.17 + (0.08 if i == 2 else 0.0)
		var segment_end := segment_start + TAU / 5.0 * (0.62 - gap * 0.20)
		var color := Color(0.24, 0.90, 1.0, alpha * (0.86 if i % 2 == 0 else 0.54)) if i % 2 == 0 else Color(0.98, 0.20, 0.64, alpha * 0.76)
		target.call("draw_arc", marker, ring_radius, segment_start, segment_end, 10, color, 1.8 if not foreground else 1.35, true)
		if mid > 0.0:
			var offset_dir := Vector2.from_angle(segment_start)
			target.call("draw_line", marker + offset_dir * (ring_radius - 8.0), marker + offset_dir * (ring_radius + 5.0), Color(0.72, 0.88, 1.0, alpha * 0.55), 1.0, true)
	if foreground:
		# A small front rim keeps the boss-side cue legible without moving the
		# pending positions or painting a full overlay over the boss sprite.
		for i in range(3):
			var bar_angle := seed + float(i) * 2.1 + 0.4
			var bar_dir := Vector2.from_angle(bar_angle)
			target.call("draw_line", marker + bar_dir * (ring_radius - 5.0), marker + bar_dir * (ring_radius + 7.0), Color(0.78, 0.96, 1.0, alpha * 0.66), 1.0, true)
		if final_pulse > 0.0:
			target.call("draw_line", marker - Vector2(13.0, 0.0), marker + Vector2(13.0, 0.0), Color(1.0, 0.94, 1.0, pulse * 0.50), 1.2, true)
		# ChatModule is the authoritative attack-side marker.  It sits under the
		# final-boss HUD in the default camera, so add only a tiny, boss-attached
		# signal badge in the foreground; this never exposes pending positions or
		# changes the gameplay origin.
		var boss_pos := marker
		var boss_radius := 105.0
		for item in target.get("enemies") as Array:
			var enemy: Dictionary = item as Dictionary
			if bool(enemy.get("relayBoss", false)):
				boss_pos = Vector2(enemy.get("pos", marker))
				boss_radius = maxf(80.0, float(enemy.get("radius", boss_radius)))
				break
		var badge := boss_pos + Vector2(0.0, boss_radius + 30.0)
		var badge_alpha := alpha * 0.78
		target.call("draw_arc", badge, 17.0 + pulse * 2.0, seed + 0.35, seed + 1.30, 7, Color(0.24, 0.90, 1.0, badge_alpha * 0.72), 1.2, true)
		target.call("draw_arc", badge, 17.0 + pulse * 2.0, seed + 2.10, seed + 3.00, 6, Color(0.98, 0.20, 0.64, badge_alpha * 0.68), 1.3, true)
		target.call("draw_line", badge + Vector2(-7.0, 0.0), badge + Vector2(-2.0, 0.0), Color(0.92, 0.98, 1.0, badge_alpha * 0.74), 1.0, true)
		target.call("draw_line", badge + Vector2(3.0, 0.0), badge + Vector2(8.0, 0.0), Color(0.92, 0.98, 1.0, badge_alpha * 0.74), 1.0, true)
		return
	var block_offsets := [
		Vector2(-34.0, -21.0), Vector2(27.0, -29.0), Vector2(42.0, 12.0), Vector2(-19.0, 34.0)
	]
	for i in range(block_offsets.size()):
		var block_offset: Vector2 = block_offsets[i].rotated(seed * 0.08)
		var jitter := (_noise_visual_hash(seed, 20 + i) - 0.5) * 5.0
		var block_pos := marker + block_offset + Vector2(jitter, -jitter * 0.35)
		var block_size := Vector2(5.0 + float(i % 2) * 3.0, 2.0 + float((i + 1) % 2) * 2.0)
		var block_alpha := alpha * (0.35 + mid * 0.55 + final_pulse * 0.24) * (0.86 if i != 2 else 0.58)
		var block_color := Color(0.08, 0.03, 0.18, block_alpha) if i % 2 == 0 else Color(0.96, 0.22, 0.66, block_alpha * 0.72)
		target.call("draw_rect", Rect2(block_pos - block_size * 0.5, block_size), block_color, true)
	var scan_positions := [Vector2(-20.0, -8.0), Vector2(8.0, 4.0), Vector2(-7.0, 17.0)]
	for i in range(scan_positions.size()):
		var scan_pos: Vector2 = marker + scan_positions[i]
		var scan_half := 10.0 + float(i % 2) * 5.0
		target.call("draw_line", scan_pos - Vector2(scan_half, 0.0), scan_pos + Vector2(scan_half, 0.0), Color(0.82, 0.95, 1.0, alpha * (0.24 + mid * 0.28)), 0.9, true)
	if mid > 0.0:
		var fracture_side := Vector2(0.58, -0.82).rotated(seed * 0.13)
		target.call("draw_line", marker - fracture_side * 12.0, marker - fracture_side * 3.0, Color(0.04, 0.02, 0.10, alpha * 0.72), 2.0, true)
		target.call("draw_line", marker + fracture_side * 2.0, marker + fracture_side * 10.0, Color(0.04, 0.02, 0.10, alpha * 0.72), 2.0, true)
	if final_pulse > 0.0:
		var collapse_dir := Vector2.from_angle(seed + 0.7)
		target.call("draw_line", marker - collapse_dir * 20.0, marker - collapse_dir * 5.0, Color(0.32, 0.94, 1.0, final_pulse * 0.68), 1.5, true)
		target.call("draw_line", marker + collapse_dir * 5.0, marker + collapse_dir * 20.0, Color(1.0, 0.24, 0.70, final_pulse * 0.62), 1.5, true)

static func _draw_noise_summon_visual_effects(target: Node, runtime: Dictionary) -> void:
	for item in runtime.get("noise_summon_visual_effects", []) as Array:
		var effect: Dictionary = item as Dictionary
		var kind := String(effect.get("kind", ""))
		if not kind.begins_with("relay_noise_summon_"):
			continue
		var max_life := maxf(0.01, float(effect.get("maxLife", 0.2)))
		var life := clampf(float(effect.get("life", 0.0)), 0.0, max_life)
		if life <= 0.0:
			continue
		var fade := life / max_life
		var seed := float(effect.get("visualSeed", 0.0))
		var pos := Vector2(effect.get("pos", Vector2.ZERO))
		var strength := clampf(float(effect.get("strength", 1.0)), 0.0, 1.0)
		var alpha := fade * strength
		if kind == "relay_noise_summon_spawn":
			var progress := 1.0 - fade
			var burst := sin(clampf(progress * PI, 0.0, PI))
			var radius := 17.0 + burst * 5.0
			target.call("draw_arc", pos, radius, seed + 0.2, seed + 1.75, 12, Color(0.24, 0.88, 1.0, 0.72 * alpha), 1.8, true)
			target.call("draw_arc", pos, radius + 3.0, seed + 2.05, seed + 3.25, 10, Color(1.0, 0.20, 0.68, 0.62 * alpha), 1.5, true)
			target.call("draw_line", pos + Vector2(-radius * 0.72, -2.0), pos + Vector2(radius * 0.64, -2.0), Color(1.0, 0.96, 1.0, (0.42 + burst * 0.32) * alpha), 1.1, true)
			for i in range(4):
				var angle := seed + float(i) * 1.57 + 0.24
				var block_pos := pos + Vector2.from_angle(angle) * (13.0 + burst * 8.0)
				var block_size := Vector2(4.0 + float(i % 2) * 2.0, 2.0 + float((i + 1) % 2))
				target.call("draw_rect", Rect2(block_pos - block_size * 0.5, block_size), Color(0.08, 0.02, 0.16, 0.50 * alpha), true)
			for i in range(3):
				var fragment_dir := Vector2.from_angle(seed + 0.8 + float(i) * 2.0)
				var fragment_pos := pos + fragment_dir * (15.0 + burst * 12.0)
				target.call("draw_line", fragment_pos - fragment_dir * 4.0, fragment_pos + fragment_dir * 2.0, Color(0.96, 0.26, 0.72, 0.58 * alpha), 1.1, true)
		elif kind == "relay_noise_summon_boss_cue":
			var burst := sin(clampf((1.0 - fade) * PI, 0.0, PI))
			target.call("draw_arc", pos, 42.0 + burst * 5.0, seed + 0.1, seed + 1.5, 14, Color(0.25, 0.88, 1.0, 0.60 * alpha), 1.5, true)
			target.call("draw_arc", pos, 48.0 + burst * 4.0, seed + 2.0, seed + 3.25, 12, Color(0.96, 0.22, 0.68, 0.55 * alpha), 1.8, true)
			target.call("draw_line", pos - Vector2(8.0, 0.0), pos + Vector2(8.0, 0.0), Color(1.0, 0.96, 1.0, 0.42 * alpha), 1.2, true)
		elif kind == "relay_noise_summon_travel_cue":
			var cue_progress := 1.0 - fade
			var cue_pulse := sin(clampf(cue_progress * PI, 0.0, PI))
			target.call("draw_arc", pos, 13.0 + cue_pulse * 4.0, seed + 0.20, seed + 1.18, 8, Color(0.24, 0.92, 1.0, 0.76 * alpha), 1.5, true)
			target.call("draw_arc", pos, 16.0 + cue_pulse * 3.0, seed + 2.02, seed + 2.86, 8, Color(1.0, 0.22, 0.68, 0.70 * alpha), 1.4, true)
			target.call("draw_line", pos + Vector2(-6.0, -1.0), pos + Vector2(6.0, -1.0), Color(1.0, 0.96, 1.0, 0.60 * alpha), 1.1, true)
			target.call("draw_circle", pos + Vector2(0.0, 2.0), 3.2, Color(0.08, 0.02, 0.16, 0.42 * alpha), true)
			target.call("draw_arc", pos, 4.8, PI + 0.18, TAU - 0.18, 7, Color(0.76, 0.94, 1.0, 0.54 * alpha), 1.0, true)
			for i in range(2):
				var cue_block := pos + Vector2.from_angle(seed + 1.2 + float(i) * PI) * (13.0 + cue_pulse * 4.0)
				target.call("draw_rect", Rect2(cue_block - Vector2(3.0, 1.0), Vector2(6.0, 2.0)), Color(0.08, 0.02, 0.16, 0.70 * alpha), true)
		elif kind == "relay_noise_summon_contact":
			var burst := sin(clampf((1.0 - fade) * PI, 0.0, PI))
			target.call("draw_circle", pos, 9.0 + burst * 5.0, Color(1.0, 0.96, 1.0, 0.28 * alpha), true)
			target.call("draw_line", pos + Vector2(-15.0, -4.0), pos + Vector2(-4.0, 0.0), Color(0.24, 0.90, 1.0, 0.72 * alpha), 1.5, true)
			target.call("draw_line", pos + Vector2(4.0, 1.0), pos + Vector2(16.0, 5.0), Color(1.0, 0.22, 0.68, 0.70 * alpha), 1.5, true)
			target.call("draw_line", pos + Vector2(-7.0, 8.0), pos + Vector2(8.0, 8.0), Color(0.08, 0.02, 0.16, 0.60 * alpha), 1.2, true)
		elif kind == "relay_noise_summon_defeat":
			var collapse := 1.0 - fade
			var radius := lerpf(23.0, 9.0, collapse)
			target.call("draw_arc", pos, radius, seed + 0.15, seed + 1.7, 12, Color(0.24, 0.90, 1.0, 0.56 * alpha), 1.6, true)
			target.call("draw_arc", pos, radius + 3.0, seed + 2.0, seed + 3.3, 10, Color(1.0, 0.20, 0.68, 0.50 * alpha), 1.4, true)
			for i in range(4):
				var fragment_dir := Vector2.from_angle(seed + float(i) * 1.57)
				var fragment_pos := pos + fragment_dir * (8.0 + collapse * 16.0)
				target.call("draw_rect", Rect2(fragment_pos - Vector2(3.0, 1.4), Vector2(6.0, 2.8)), Color(0.08, 0.02, 0.16, 0.64 * alpha), true)
			target.call("draw_line", pos - Vector2(10.0, 0.0), pos + Vector2(10.0, 0.0), Color(1.0, 0.96, 1.0, 0.52 * alpha), 1.0, true)
		elif kind == "relay_noise_summon_expiry":
			var collapse := 1.0 - fade
			var radius := lerpf(20.0, 8.0, collapse)
			target.call("draw_arc", pos, radius, seed + 0.14, seed + 1.24, 10, Color(0.24, 0.92, 1.0, 0.66 * alpha), 1.5, true)
			target.call("draw_arc", pos, radius + 2.0, seed + 2.08, seed + 3.12, 10, Color(1.0, 0.22, 0.68, 0.60 * alpha), 1.4, true)
			target.call("draw_line", pos - Vector2(8.0, 0.0), pos + Vector2(8.0, 0.0), Color(1.0, 0.98, 1.0, 0.68 * alpha), 1.0, true)
			for i in range(4):
				var fragment_dir := Vector2.from_angle(seed + float(i) * 1.57)
				var fragment_pos := pos + fragment_dir * (7.0 + collapse * 13.0)
				var fragment_size := Vector2(4.0 + float(i % 2) * 2.0, 2.0 + float((i + 1) % 2))
				var fragment_color := Color(0.08, 0.02, 0.16, 0.72 * alpha) if i == 3 else (Color(0.24, 0.92, 1.0, 0.56 * alpha) if i % 2 == 0 else Color(1.0, 0.22, 0.68, 0.56 * alpha))
				target.call("draw_rect", Rect2(fragment_pos - fragment_size * 0.5, fragment_size), fragment_color, true)

static func _draw_debug(target: Node, runtime: Dictionary, arena: Rect2) -> void:
	var active: Dictionary = runtime.get("active_attack", {}) as Dictionary
	var movement: Dictionary = MovementSystemScript.ensure_for_target(target)
	var balance: Dictionary = target.get("balance_debug_last") as Dictionary
	var stats: Dictionary = balance.get("balanceStats", {}) as Dictionary
	var text := "BOSS FSM %s  %s  %.1fs  hazards:%d  reuse:%d" % [
		String(active.get("state", AttackSystemScript.STATE_IDLE)).to_upper(),
		String(active.get("id", "IDLE")),
		float(active.get("timer", 0.0)),
		(runtime.get("hazards", []) as Array).size(),
		(runtime.get("reuse_cooldowns", {}) as Dictionary).size()
	]
	if target.has_method("_draw_outlined_text"):
		target.call("_draw_outlined_text", arena.position + Vector2(18.0, 32.0), text, 700, 14, Color.WHITE, Color("#37102d"), HORIZONTAL_ALIGNMENT_LEFT)
		var movement_text := "MOVE %s  anchor:%s -> %s  attacks:%d  %.1fs  target:(%.0f,%.0f) locked:(%.0f,%.0f)" % [
			String(movement.get("state", MovementSystemScript.STATE_HOVER)),
			String(movement.get("anchor_id", "center")),
			String(movement.get("pending_anchor_request", "")),
			int(movement.get("attacks_since_reposition", 0)),
			float(movement.get("time_since_reposition", 0.0)),
			Vector2(movement.get("target", arena.get_center())).x,
			Vector2(movement.get("target", arena.get_center())).y,
			Vector2(movement.get("locked_origin", Vector2.ZERO)).x,
			Vector2(movement.get("locked_origin", Vector2.ZERO)).y
		]
		target.call("_draw_outlined_text", arena.position + Vector2(18.0, 50.0), movement_text, 900, 12, Color("#fff1c6"), Color("#37102d"), HORIZONTAL_ALIGNMENT_LEFT)
		var balance_text := "BAL req:%d actual:%d cap:%d enemies:%d/%d bullets:%d defeats:%d exp:%d/%d lv:%d" % [
			int(balance.get("requestedSpawnCount", 0)),
			int(balance.get("actualSpawnCount", 0)),
			int(balance.get("cappedSpawnCount", 0)),
			int(balance.get("activeNormalWaveCount", 0)),
			int(balance.get("activeNormalWaveCap", 0)),
			int(balance.get("activeEnemyBulletCount", 0)),
			int(stats.get("defeats", 0)),
			int(stats.get("expDropped", 0)),
			int(stats.get("expCollected", 0)),
			int(stats.get("levelUps", 0))
		]
		target.call("_draw_outlined_text", arena.position + Vector2(18.0, 66.0), balance_text, 900, 12, Color("#c9f7ff"), Color("#37102d"), HORIZONTAL_ALIGNMENT_LEFT)
		var pending: Dictionary = runtime.get("noise_summon_pending_wave", {}) as Dictionary
		var noise_text := "NOISE phase:%d count:%d cap:%d/%d cd:%.1f" % [
			int(target.get("relay_boss_phase")),
			int((pending.get("positions", []) as Array).size()),
			int(_active_noise_count(target)),
			int(_noise_active_cap(target)),
			float(runtime.get("noise_summon_cooldown", 0.0))
		]
		target.call("_draw_outlined_text", arena.position + Vector2(18.0, 82.0), noise_text, 900, 12, Color("#ffe6f2"), Color("#37102d"), HORIZONTAL_ALIGNMENT_LEFT)
		var star_text := "STAR carrier:%d dropCd:%.1f reserved:%d/%d" % [int(runtime.get("sync_star_carrier_uid", -1)), float(runtime.get("sync_star_drop_cooldown", 0.0)), int(_reserved_stars(target)), int(_required_stars(target))]
		target.call("_draw_outlined_text", arena.position + Vector2(18.0, 98.0), star_text, 900, 12, Color("#fff2a7"), Color("#37102d"), HORIZONTAL_ALIGNMENT_LEFT)
		target.call("_draw_outlined_text", arena.position + Vector2(18.0, 114.0), DefenseSystemScript.debug_text_for_target(target), 900, 12, Color("#f0ddff"), Color("#37102d"), HORIZONTAL_ALIGNMENT_LEFT)

static func _active_noise_count(target: Node) -> int:
	var count := 0
	for item in target.get("enemies") as Array:
		var enemy: Dictionary = item as Dictionary
		if bool(enemy.get("relayBossNoiseSummon", false)) and not bool(enemy.get("defeatPending", false)) and not bool(enemy.get("defeatResolved", false)) and float(enemy.get("relayBossSummonLifetime", 1.0)) > 0.0:
			count += 1
	return count

static func _noise_active_cap(target: Node) -> int:
	var config: Dictionary = target.get("relay_mode_config") as Dictionary
	var boss_config: Dictionary = config.get("boss", {}) as Dictionary
	var attacks: Dictionary = boss_config.get("attacks", {}) as Dictionary
	var payload: Dictionary = attacks.get("noise_summon", {}) as Dictionary
	var phase := clampi(int(target.get("relay_boss_phase")), 0, 4)
	for item in payload.get("phaseSettings", []) as Array:
		var entry: Dictionary = item as Dictionary
		if int(entry.get("phaseIndex", -1)) == phase:
			return int(entry.get("activeCap", payload.get("maxActive", 4)))
	return int(payload.get("maxActive", 4))

static func _required_stars(target: Node) -> int:
	return int(target.call("_collab_required_sync_stars")) if target.has_method("_collab_required_sync_stars") else 3

static func _reserved_stars(target: Node) -> int:
	return int(target.call("_relay_boss_reserved_sync_stars")) if target.has_method("_relay_boss_reserved_sync_stars") else int(target.get("collab_sync_stars"))

static func _boss_origin(target: Node, arena: Rect2) -> Vector2:
	for item in target.get("enemies") as Array:
		var enemy: Dictionary = item as Dictionary
		if bool(enemy.get("relayBoss", false)) or String(enemy.get("bossId", "")) == "last_offline" or String(enemy.get("kind", "")) == "last_offline":
			return Vector2(enemy.get("pos", arena.get_center()))
	return arena.get_center()
