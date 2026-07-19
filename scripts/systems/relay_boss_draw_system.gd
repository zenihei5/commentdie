class_name RelayBossDrawSystem
extends RefCounted

const AttackSystemScript := preload("res://scripts/systems/relay_boss_attack_system.gd")
const MovementSystemScript := preload("res://scripts/systems/relay_boss_movement_system.gd")
const DefenseSystemScript := preload("res://scripts/systems/relay_boss_defense_system.gd")

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
		_draw_telegraph(target, attack_id, payload, arena, float(active.get("timer", 0.0)))
	var pending_noise: Dictionary = runtime.get("noise_summon_pending_wave", {}) as Dictionary
	if not pending_noise.is_empty():
		_draw_noise_summon_pending(target, pending_noise)
	_draw_hazards(target, runtime.get("hazards", []) as Array)
	if bool(runtime.get("debug_overlay", false)):
		_draw_debug(target, runtime, arena)

static func draw_front_for_target(target: Node, _arena: Rect2) -> void:
	if not bool(target.get("relay_boss_active")):
		return
	DefenseSystemScript.draw_front_for_target(target, _arena)

static func _draw_telegraph(target: Node, attack_id: String, payload: Dictionary, arena: Rect2, timer: float) -> void:
	var alpha := clampf(0.30 + sin(timer * 12.0) * 0.12, 0.12, 0.55)
	var color := Color(1.0, 0.34, 0.62, alpha)
	var player_pos := Vector2(target.get("player_pos"))
	match attack_id:
		"comment_shotgun", "noise_summon":
			target.call("draw_circle", MovementSystemScript.marker_world_position(target, "ChatModule", arena), 48.0, color, false, 4.0)
		"offline_laser":
			var origin := MovementSystemScript.marker_world_position(target, "CoreCenter", arena)
			var movement: Dictionary = MovementSystemScript.ensure_for_target(target)
			var locked_origin := Vector2(movement.get("locked_origin", Vector2.ZERO))
			if locked_origin.length_squared() > 0.01:
				origin = locked_origin
			target.call("draw_line", origin, origin + (player_pos - origin).normalized() * 900.0, color, 34.0)
		"race_lane_charge", "long_comment_line":
			for i in range(3):
				var y := arena.position.y + arena.size.y * (0.24 + float(i) * 0.26)
				target.call("draw_line", Vector2(arena.position.x, y), Vector2(arena.end.x, y), color, 24.0)
		"eraser_sweep":
			target.call("draw_rect", Rect2(arena.position.x, arena.position.y, 128.0, arena.size.y), color, true)
		"game_over_barrage":
			target.call("draw_circle", MovementSystemScript.marker_world_position(target, "GameModule", arena), 56.0, color, false, 4.0)
		"howling_ring", "pitch_wave", "rhythm_explosion":
			target.call("draw_circle", MovementSystemScript.marker_world_position(target, "SongModule", arena), 92.0, color, false, 4.0)
		"paint_warning", "dirty_paint":
			target.call("draw_circle", MovementSystemScript.marker_world_position(target, "DrawModule", arena), 96.0, color, false, 4.0)
		"collab_break":
			target.call("draw_circle", MovementSystemScript.marker_world_position(target, "CollabModule", arena), 190.0, color)
		"all_genre_rush":
			target.call("draw_circle", MovementSystemScript.marker_world_position(target, "CoreCenter", arena), 190.0, color)
		_:
			target.call("draw_circle", player_pos, 64.0, color)

static func _draw_hazards(target: Node, hazards: Array) -> void:
	for item in hazards:
		var hazard: Dictionary = item as Dictionary
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

static func _draw_noise_summon_pending(target: Node, pending: Dictionary) -> void:
	var timer := maxf(0.0, float(pending.get("warningTimer", 0.0)))
	var pulse := 0.5 + 0.5 * sin(float(target.get("elapsed")) * (16.0 if timer < 0.15 else 10.0))
	var alpha := 0.34 + pulse * 0.26
	for raw_pos in pending.get("positions", []) as Array:
		var pos := Vector2(raw_pos)
		target.call("draw_circle", pos, 24.0 + pulse * 5.0, Color(1.0, 0.30, 0.68, alpha * 0.16), true)
		target.call("draw_arc", pos, 24.0 + timer * 18.0, 0.0, TAU, 24, Color(1.0, 0.48, 0.82, alpha), 2.6, true)
		target.call("draw_arc", pos, maxf(4.0, 18.0 - timer * 20.0), 0.0, TAU, 20, Color(0.38, 0.86, 1.0, alpha * 0.9), 2.0, true)
		target.call("draw_circle", pos, 5.0 + pulse * 2.0, Color(0.12, 0.04, 0.18, alpha * 0.9), true)

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
