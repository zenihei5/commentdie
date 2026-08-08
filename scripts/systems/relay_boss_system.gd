class_name RelayBossSystem
extends RefCounted

const ChoiceCardSystemScript := preload("res://scripts/systems/choice_card_system.gd")
const EnemySystemScript := preload("res://scripts/systems/enemy_system.gd")
const PauseReasonSystemScript := preload("res://scripts/systems/pause_reason_system.gd")
const RelayBossAttackSystemScript := preload("res://scripts/systems/relay_boss_attack_system.gd")
const RelayBossMovementSystemScript := preload("res://scripts/systems/relay_boss_movement_system.gd")
const RelayBossContactSystemScript := preload("res://scripts/systems/relay_boss_contact_system.gd")
const RelayBossDefenseSystemScript := preload("res://scripts/systems/relay_boss_defense_system.gd")
const ModifierSystemScript := preload("res://scripts/systems/modifier_system.gd")
const BuzzSystemScript := preload("res://scripts/systems/buzz_system.gd")
const HardModeSystemScript := preload("res://scripts/systems/hard_mode_system.gd")
const PowerUpEffectProviderScript := preload("res://scripts/systems/power_up_effect_provider.gd")

static func _clear_support_modifiers_for_target(target: Node) -> void:
	var current: Variant = target.get("modifier_sources")
	if not current is Dictionary:
		return
	var sources: Dictionary = current as Dictionary
	for source_id in sources.keys():
		if String(source_id).begins_with("relay_boss_support_"):
			sources.erase(source_id)
	target.set("modifier_sources", sources)

static func prepare_start_for_target(_target: Node, arena: Rect2) -> Dictionary:
	var player_start := arena.get_center() + Vector2(0.0, 260.0)
	player_start.x = clampf(player_start.x, arena.position.x + 64.0, arena.end.x - 64.0)
	player_start.y = clampf(player_start.y, arena.position.y + 64.0, arena.end.y - 64.0)
	return {
		"bossId": "last_offline",
		"arena": arena,
		"worldPosition": arena.get_center(),
		"playerStartPosition": player_start,
		"introLocked": false
	}

static func start_for_target(target: Node, arena: Rect2, rng: RandomNumberGenerator) -> void:
	start_prepared_for_target(target, arena, rng, prepare_start_for_target(target, arena))

static func start_prepared_for_target(target: Node, arena: Rect2, rng: RandomNumberGenerator, prepared: Dictionary) -> int:
	var config: Dictionary = target.get("relay_mode_config") as Dictionary
	var boss_config: Dictionary = config.get("boss", {}) as Dictionary
	var intro_locked := bool(prepared.get("introLocked", false))
	var enemies: Array = target.get("enemies") as Array
	enemies.clear()
	(target.get("enemy_bullets") as Array).clear()
	var uid := int(target.get("next_enemy_uid"))
	var boss_position: Vector2 = prepared.get("worldPosition", arena.get_center()) as Vector2
	var boss: Dictionary = EnemySystemScript.build_enemy("long_comment_guy", boss_position, uid, 999.0)
	boss["spawnSource"] = "boss"
	boss["spawnPriority"] = HardModeSystemScript.spawn_priority_for_source("boss")
	boss["occupancyManaged"] = false
	boss["kind"] = "last_offline"
	boss["bossId"] = "last_offline"
	boss["displayName"] = String(boss_config.get("displayName", "ラストオフライン"))
	boss["formalName"] = String(boss_config.get("formalName", "配信終焉体・ラストオフライン"))
	boss["hp"] = float(boss_config.get("maxHp", 1200.0))
	boss["max_hp"] = float(boss.get("hp"))
	_apply_large_body_profile(boss, boss_config, true)
	_apply_hard_final_profile(target, boss, boss_config)
	boss["speed"] = 0.0
	boss["contactDamage"] = int(boss_config.get("contactDamage", 0))
	_apply_hard_final_profile(target, boss, boss_config)
	boss["score"] = 0
	boss["exp"] = 0
	boss["expValue"] = 0
	boss["giftHypeReward"] = 0
	boss["noRewards"] = true
	boss["relayBoss"] = true
	boss["isBoss"] = true
	boss["canBeKnockedBack"] = false
	boss["knockbackResistance"] = 1.0
	boss["cutinIntroLocked"] = intro_locked
	boss["cutinVisualAlpha"] = 0.0 if intro_locked else 1.0
	boss["cutinVisualScale"] = 0.94 if intro_locked else 1.0
	boss["cutinVisualOffset"] = Vector2.ZERO
	boss["cutinIntroPoseId"] = String(prepared.get("introPoseId", "last_offline_boot"))
	boss["cutinIntroPoseProgress"] = 0.0
	enemies.append(boss)
	target.set("enemies", enemies)
	target.set("next_enemy_uid", uid + 1)
	# Keep the player clearly below the boss when the arena is created.  The
	# relay boss is centered in the arena, so carrying the previous frame's
	# position can otherwise cause an immediate contact hit on frame one.
	var player_start: Vector2 = prepared.get("playerStartPosition", arena.get_center() + Vector2(0.0, 260.0)) as Vector2
	target.set("player_pos", player_start)
	target.set("player_vel", Vector2.ZERO)
	target.set("click_move_active", false)
	target.set("click_move_target", player_start)
	target.set("boss_active", true)
	target.set("boss_requested", false)
	target.set("active_boss_uid", uid)
	target.set("boss_pending_id", "last_offline")
	target.set("boss_last_name", String(boss_config.get("displayName", "ラストオフライン")))
	target.set("boss_summoned", true)
	target.set("boss_defeated", false)
	target.set("boss_last_result", "")
	target.set("relay_boss_active", true)
	target.set("relay_boss_max_hp", float(boss.get("max_hp")))
	target.set("relay_boss_hp", float(boss.get("hp")))
	target.set("relay_boss_phase", 0)
	target.set("relay_boss_attack_timer", 1.0)
	target.set("relay_boss_active_attack", {})
	target.set("relay_boss_last_attack", "")
	target.set("relay_boss_comment_timer", float((boss_config.get("bossInstructionSettings", {}) as Dictionary).get("interval", 15.0)))
	target.set("relay_boss_score_snapshot", float(target.get("relay_base_multiplier")))
	target.set("relay_boss_score_awarded", false)
	target.set("relay_boss_defeat_pending", false)
	target.set("relay_boss_player_death_pending", false)
	target.set("relay_boss_pending_phase", -1)
	target.set("relay_boss_phase_transition_timer", 0.0)
	target.set("relay_boss_phase_center_timer", 0.0)
	target.set("relay_boss_instruction", {})
	target.set("relay_boss_instruction_last_id", "")
	target.set("relay_boss_projectile_count_multiplier", 1.0)
	target.set("relay_boss_projectile_speed_multiplier", 1.0)
	target.set("relay_boss_attack_interval_multiplier", 1.0)
	target.set("relay_boss_arena_timer", 0.0)
	target.set("relay_boss_no_heal_timer", 0.0)
	target.set("relay_boss_encounter_elapsed", 0.0)
	target.set("relay_boss_instruction_cycle", 0)
	target.set("relay_boss_support_ever_offered", false)
	target.set("relay_boss_support_appearance_cooldown", 0.0)
	target.set("relay_boss_support_last_offer_cycle", -999)
	target.set("relay_boss_support_last_id", "")
	target.set("relay_boss_support_fx", [])
	target.set("relay_boss_support_selected", false)
	target.set("relay_boss_support_selected_id", "")
	target.set("relay_boss_support_heal_amount", 0)
	target.set("relay_boss_no_dash_owned", false)
	_clear_support_modifiers_for_target(target)
	target.set("collab_boss_partner_muted", false)
	(target.get("collab_boss_attacks") as Array).clear()
	RelayBossMovementSystemScript.reset_for_target(target, arena)
	RelayBossAttackSystemScript.reset_for_target(target)
	RelayBossContactSystemScript.reset_for_target(target)
	RelayBossDefenseSystemScript.reset_for_target(target)
	if not intro_locked:
		PauseReasonSystemScript.clear(target)
	if target.has_method("_emit_relay_chat"):
		target.call("_emit_relay_chat", "最終ボス『ラストオフライン』出現！")
	return uid

static func unlock_intro_for_target(target: Node, uid: int) -> void:
	for item in (target.get("enemies") as Array):
		var enemy: Dictionary = item as Dictionary
		if int(enemy.get("uid", -1)) != uid:
			continue
		enemy["cutinIntroLocked"] = false
		enemy["cutinVisualAlpha"] = 1.0
		enemy["cutinVisualScale"] = 1.0
		enemy["cutinVisualOffset"] = Vector2.ZERO
		enemy["cutinIntroPoseProgress"] = 1.0
		return

static func remove_intro_spawn_for_target(target: Node, uid: int) -> void:
	var remaining: Array = []
	for item in (target.get("enemies") as Array):
		var enemy: Dictionary = item as Dictionary
		if int(enemy.get("uid", -1)) == uid and bool(enemy.get("cutinIntroLocked", false)):
			continue
		remaining.append(enemy)
	target.set("enemies", remaining)
	target.set("relay_boss_active", false)
	target.set("boss_active", false)
	target.set("active_boss_uid", -1)

static func is_active(target: Node) -> bool:
	return bool(target.get("relay_boss_active"))

static func _is_hard_final_target(target: Node) -> bool:
	if not HardModeSystemScript.is_hard_target(target):
		return false
	return String(HardModeSystemScript.runtime_for_target(target).get("playMode", "")) == HardModeSystemScript.RELAY_FINAL_BOSS

static func phase_count_for_target(target: Node) -> int:
	if _is_hard_final_target(target):
		return HardModeSystemScript.final_boss_phase_count(HardModeSystemScript.runtime_for_target(target))
	var boss_config: Dictionary = (target.get("relay_mode_config") as Dictionary).get("boss", {}) as Dictionary
	var thresholds: Array = boss_config.get("phaseThresholds", [0.80, 0.60, 0.40, 0.20, 0.00]) as Array
	return maxi(1, thresholds.size())

static func max_phase_for_target(target: Node) -> int:
	return phase_count_for_target(target) - 1

static func phase_transition_lock_timeout_for_target(target: Node) -> float:
	var boss_config: Dictionary = (target.get("relay_mode_config") as Dictionary).get("boss", {}) as Dictionary
	var duration := maxf(0.05, float(boss_config.get("phaseTransitionTime", 1.5)))
	if _is_hard_final_target(target):
		# HARD specifies 1.5 seconds for the complete invincible transition,
		# including the move to the center anchor.
		return duration + 0.5
	var movement_config: Dictionary = boss_config.get("movement", {}) as Dictionary
	return float(movement_config.get("phaseTransitionCenterTime", 0.7)) + duration + 0.5

static func phase_for_target(target: Node) -> int:
	var config: Dictionary = target.get("relay_mode_config") as Dictionary
	var boss_config: Dictionary = config.get("boss", {}) as Dictionary
	var max_hp := maxf(1.0, float(target.get("relay_boss_max_hp")))
	var hp := maxf(0.0, float(target.get("relay_boss_hp")))
	var boss := active_boss(target)
	if not boss.is_empty():
		hp = maxf(0.0, float(boss.get("hp", hp)))
	if _is_hard_final_target(target):
		return HardModeSystemScript.final_boss_phase(HardModeSystemScript.runtime_for_target(target), hp / max_hp)
	return _phase_for_ratio(boss_config, hp / max_hp)

static func active_boss(target: Node) -> Dictionary:
	for item in target.get("enemies") as Array:
		var enemy: Dictionary = item as Dictionary
		if bool(enemy.get("relayBoss", false)) or String(enemy.get("bossId", "")) == "last_offline" or String(enemy.get("kind", "")) == "last_offline":
			return enemy
	return {}

static func _restore_body_for_target(target: Node, arena: Rect2) -> Dictionary:
	var config: Dictionary = target.get("relay_mode_config") as Dictionary
	var boss_config: Dictionary = config.get("boss", {}) as Dictionary
	var enemies: Array = target.get("enemies") as Array
	var uid := int(target.get("active_boss_uid"))
	if uid < 0:
		uid = int(target.get("next_enemy_uid"))
		target.set("next_enemy_uid", uid + 1)
	var hp := maxf(1.0, float(target.get("relay_boss_hp")))
	var max_hp := maxf(hp, float(target.get("relay_boss_max_hp")))
	var boss: Dictionary = EnemySystemScript.build_enemy("long_comment_guy", arena.get_center(), uid, 999.0)
	boss["spawnSource"] = "boss"
	boss["spawnPriority"] = HardModeSystemScript.spawn_priority_for_source("boss")
	boss["occupancyManaged"] = false
	boss["kind"] = "last_offline"
	boss["bossId"] = "last_offline"
	boss["hp"] = hp
	boss["max_hp"] = max_hp
	boss["relayBoss"] = true
	boss["relayBossSummon"] = false
	boss["isBoss"] = true
	boss["noRewards"] = true
	_apply_large_body_profile(boss, boss_config, true)
	_apply_hard_final_profile(target, boss, boss_config)
	boss["speed"] = 0.0
	boss["contactDamage"] = int(boss_config.get("contactDamage", 0))
	_apply_hard_final_profile(target, boss, boss_config)
	boss["score"] = 0
	boss["exp"] = 0
	boss["expValue"] = 0
	boss["expDrop"] = 0
	boss["giftHypeReward"] = 0
	boss["canBeKnockedBack"] = false
	boss["knockbackResistance"] = 1.0
	enemies.append(boss)
	target.set("enemies", enemies)
	target.set("active_boss_uid", uid)
	# A missing-body recovery is a hard synchronization point.  Do not let a
	# stale barrier mirror survive onto the reconstructed dictionary.
	RelayBossDefenseSystemScript.force_clear(target, RelayBossDefenseSystemScript.STATE_NORMAL)
	return boss

static func normalize_body_for_target(target: Node) -> void:
	var boss := active_boss(target)
	if boss.is_empty():
		return
	var config: Dictionary = target.get("relay_mode_config") as Dictionary
	var boss_config: Dictionary = config.get("boss", {}) as Dictionary
	boss["relayBoss"] = true
	boss["relayBossSummon"] = false
	boss["isBoss"] = true
	boss["kind"] = "last_offline"
	boss["bossId"] = "last_offline"
	boss["noRewards"] = true
	_apply_large_body_profile(boss, boss_config)
	_apply_hard_final_profile(target, boss, boss_config)
	boss["speed"] = 0.0
	boss["contactDamage"] = int(boss_config.get("contactDamage", 0))
	boss["canBeKnockedBack"] = false
	boss["knockbackResistance"] = 1.0
	_apply_hard_final_profile(target, boss, boss_config)

static func _apply_large_body_profile(boss: Dictionary, boss_config: Dictionary, reset_visual: bool = false) -> void:
	var movement: Dictionary = boss_config.get("movement", {}) as Dictionary
	var draw_size := _vector2_from_config(movement.get("visualDrawSize", {"x": 520.0, "y": 520.0}), Vector2(520.0, 520.0))
	var opaque_size := _vector2_from_config(movement.get("visualOpaqueSize", {"x": 500.0, "y": 450.0}), Vector2(500.0, 450.0))
	var damage_radius := maxf(1.0, float(movement.get("damageRadius", 110.0)))
	boss["radius"] = damage_radius
	boss["damageRadius"] = damage_radius
	boss["visualDrawSize"] = draw_size
	boss["visualOpaqueSize"] = opaque_size
	if reset_visual:
		boss["visualScaleVector"] = Vector2.ONE
		boss["visualRotation"] = 0.0
		boss["visualOffset"] = Vector2.ZERO
		boss["shadowScale"] = 1.0
	boss["showWorldHpBar"] = false

static func _apply_hard_final_profile(target: Node, boss: Dictionary, boss_config: Dictionary) -> void:
	var runtime := HardModeSystemScript.runtime_for_target(target)
	if not HardModeSystemScript.is_hard_runtime(runtime) or String(runtime.get("playMode", "")) != HardModeSystemScript.RELAY_FINAL_BOSS:
		return
	var rates := HardModeSystemScript.final_boss_rates(runtime)
	var base_contact_damage := int(boss_config.get("contactDamage", 12))
	if base_contact_damage <= 0:
		base_contact_damage = 12
	if not bool(boss.get("hardFinalStatsApplied", false)):
		var base_hp := float(boss.get("max_hp", boss.get("hp", 1.0)))
		boss["hardFinalBaseHp"] = base_hp
		boss["hp"] = maxf(1.0, base_hp * float(rates.get("hpRate", 1.35)))
		boss["max_hp"] = boss["hp"]
		boss["hardFinalStatsApplied"] = true
		boss["hardFinalBaseSpeed"] = float(boss.get("speed", 0.0))
		boss["hardFinalBaseContactDamage"] = base_contact_damage
	boss["hardFinalBoss"] = true
	boss["hardMoveSpeedRate"] = float(rates.get("moveSpeedRate", 1.08))
	boss["hardActionIntervalRate"] = float(rates.get("actionIntervalRate", 0.85))
	boss["hardSummonCountRate"] = float(rates.get("summonCountRate", 1.40))
	boss["speed"] = float(boss.get("hardFinalBaseSpeed", 0.0)) * float(rates.get("moveSpeedRate", 1.08))
	boss["contactDamage"] = base_contact_damage if bool(rates.get("contactDamageEnabled", true)) else 0

static func _vector2_from_config(value: Variant, fallback: Vector2) -> Vector2:
	if value is Vector2:
		return value as Vector2
	if value is Dictionary:
		var data: Dictionary = value as Dictionary
		return Vector2(float(data.get("x", fallback.x)), float(data.get("y", fallback.y)))
	return fallback

static func update_for_target(target: Node, delta: float, arena: Rect2, rng: RandomNumberGenerator, freeze_gameplay: bool = false) -> Dictionary:
	if not is_active(target):
		return {"damageEvents": [], "chats": [], "toasts": []}
	var boss := active_boss(target)
	if boss.is_empty():
		boss = _restore_body_for_target(target, arena)
	if boss.is_empty():
		return {"damageEvents": [], "chats": [], "toasts": []}
	if bool(boss.get("cutinIntroLocked", false)):
		return {"damageEvents": [], "chats": [], "toasts": []}
	if bool(target.get("relay_boss_defeat_pending")):
		return {"damageEvents": [], "chats": [], "toasts": []}
	# Encounter time includes the phase barrier/transition, but never advances
	# while the instruction choice modal is open.
	if String(target.get("state")) == "playing":
		target.set("relay_boss_encounter_elapsed", float(target.get("relay_boss_encounter_elapsed")) + delta)
		target.set("relay_boss_support_appearance_cooldown", maxf(0.0, float(target.get("relay_boss_support_appearance_cooldown")) - delta))
	normalize_body_for_target(target)
	var config: Dictionary = target.get("relay_mode_config") as Dictionary
	var boss_config: Dictionary = config.get("boss", {}) as Dictionary
	target.set("relay_boss_hp", maxf(0.0, float(boss.get("hp", target.get("relay_boss_hp")))))
	var ratio := float(target.get("relay_boss_hp")) / maxf(1.0, float(target.get("relay_boss_max_hp")))
	var next_phase := phase_for_target(target) if HardModeSystemScript.is_hard_target(target) else _phase_for_ratio(boss_config, ratio)
	var current_phase := int(target.get("relay_boss_phase"))
	var pending_phase := int(target.get("relay_boss_pending_phase"))
	if next_phase != current_phase:
		pending_phase = next_phase
		target.set("relay_boss_pending_phase", pending_phase)
	var movement_feedback := RelayBossMovementSystemScript.update_for_target(target, delta, arena, freeze_gameplay)
	var movement_state_after := RelayBossMovementSystemScript.state_for_target(target)
	if movement_state_after != RelayBossMovementSystemScript.STATE_PHASE_TRANSITION and float(target.get("relay_boss_phase_center_timer")) > 0.0:
		# The movement FSM has already left the center transition; never keep
		# gameplay frozen because of a stale mirrored timer.
		target.set("relay_boss_phase_center_timer", 0.0)
	if bool(movement_feedback.get("phaseCenterArrived", false)):
		var arrived_phase := int(target.get("relay_boss_pending_phase"))
		if arrived_phase >= 0:
			target.set("relay_boss_phase", clampi(arrived_phase, 0, max_phase_for_target(target)))
			target.set("relay_boss_pending_phase", -1)
			var duration := float(boss_config.get("phaseTransitionTime", 1.5))
			var remaining_transition := float(target.get("relay_boss_phase_transition_timer"))
			# NORMAL keeps its existing center-then-presentation timing. HARD's
			# timer starts when invincibility starts, so arriving at center must
			# not restart the full 1.5 seconds.
			target.set("relay_boss_phase_transition_timer", remaining_transition if remaining_transition > 0.0 else duration)
			PauseReasonSystemScript.add(target, "BossPhaseTransition")
	if not freeze_gameplay and int(target.get("relay_boss_pending_phase")) >= 0 and float(target.get("relay_boss_phase_center_timer")) <= 0.0 and float(target.get("relay_boss_phase_transition_timer")) <= 0.0:
		var pending_attack_state := String((target.get("relay_boss_active_attack") as Dictionary).get("state", RelayBossAttackSystemScript.STATE_IDLE))
		if pending_attack_state != RelayBossAttackSystemScript.STATE_TELEGRAPH and pending_attack_state != RelayBossAttackSystemScript.STATE_ACTIVE:
			begin_pending_phase_transition_for_target(target)
	var previous_transition_timer := float(target.get("relay_boss_phase_transition_timer"))
	var transition_timer := maxf(0.0, previous_transition_timer - delta)
	target.set("relay_boss_phase_transition_timer", transition_timer)
	var center_timer := float(target.get("relay_boss_phase_center_timer"))
	RelayBossDefenseSystemScript.update_for_target(target, delta, transition_timer, center_timer)
	if transition_timer <= 0.0 and center_timer <= 0.0 and RelayBossMovementSystemScript.state_for_target(target) == RelayBossMovementSystemScript.STATE_PHASE_TRANSITION:
		# A stale movement mirror must not keep the caller in its phase-lock
		# branch forever.  Complete the transition and return the boss to HOVER.
		var reached_phase := phase_for_target(target)
		if reached_phase > int(target.get("relay_boss_phase")):
			target.set("relay_boss_phase", reached_phase)
		target.set("relay_boss_pending_phase", -1)
		RelayBossMovementSystemScript.force_resume_for_target(target, arena)
		center_timer = 0.0
	if transition_timer <= 0.0 and center_timer <= 0.0:
		PauseReasonSystemScript.remove(target, "BossPhaseTransition")
	if transition_timer <= 0.0 and center_timer <= 0.0:
		_update_instruction_timer(target, delta)
	target.set("relay_boss_arena_timer", maxf(0.0, float(target.get("relay_boss_arena_timer")) - delta))
	target.set("relay_boss_no_heal_timer", maxf(0.0, float(target.get("relay_boss_no_heal_timer")) - delta))
	var movement_state := RelayBossMovementSystemScript.state_for_target(target)
	# Contact damage is resolved before boss projectiles so DamageSystem can grant
	# invincibility before any same-tick attack event is applied.
	var contact_feedback: Dictionary = RelayBossContactSystemScript.update_for_target(target, delta, arena, freeze_gameplay)
	var feedback := RelayBossAttackSystemScript.update_for_target(target, delta, arena, rng, transition_timer > 0.0 or center_timer > 0.0 or movement_state == RelayBossMovementSystemScript.STATE_PHASE_TRANSITION or freeze_gameplay)
	var ordered_damage_events: Array = contact_feedback.get("damageEvents", []) as Array
	ordered_damage_events.append_array(feedback.get("damageEvents", []) as Array)
	feedback["damageEvents"] = ordered_damage_events
	feedback["contactSucceeded"] = bool(contact_feedback.get("contactSucceeded", false))
	if previous_transition_timer > 0.0 and transition_timer <= 0.0 and not freeze_gameplay:
		RelayBossAttackSystemScript.resume_after_phase_transition_for_target(target, arena, rng)
		if target.has_method("_relay_boss_barrier_finished"):
			target.call("_relay_boss_barrier_finished")
	target.set("relay_boss_last_attack", String((target.get("relay_boss_active_attack") as Dictionary).get("id", target.get("relay_boss_last_attack"))))
	return feedback

static func _clear_phase_hazards(target: Node) -> void:
	(target.get("enemy_bullets") as Array).clear()
	(target.get("collab_boss_attacks") as Array).clear()
	(target.get("collab_effects") as Array).clear()
	(target.get("collab_hazard_fields") as Array).clear()
	(target.get("collab_messenger_trails") as Array).clear()
	if target.has_method("_clear_collab_pass"):
		target.call("_clear_collab_pass", false)
	var kept: Array = []
	for item in target.get("enemies") as Array:
		var enemy: Dictionary = item as Dictionary
		if not bool(enemy.get("relayBossSummon", false)):
			kept.append(enemy)
		else:
			enemy["removeReason"] = "phase_transition_clear"
	target.set("enemies", kept)

static func start_comment_choice_for_target(target: Node, rng: RandomNumberGenerator, choice_box: Control) -> Dictionary:
	var boss_config: Dictionary = (target.get("relay_mode_config") as Dictionary).get("boss", {}) as Dictionary
	var all_comments: Array = (boss_config.get("comments", []) as Array).duplicate(true)
	if HardModeSystemScript.is_hard_target(target):
		var runtime := HardModeSystemScript.runtime_for_target(target)
		for i in range(all_comments.size()):
			if all_comments[i] is Dictionary:
				all_comments[i] = HardModeSystemScript.resolve_comment(all_comments[i] as Dictionary, runtime)
	var normal_pool: Array = []
	var support_pool: Array = []
	for item in all_comments:
		var comment: Dictionary = item as Dictionary
		if String(comment.get("category", "")) == "boss_support":
			support_pool.append(_normalize_comment(comment))
		else:
			normal_pool.append(_normalize_comment(comment))
	var previous := String(target.get("relay_boss_instruction_last_id"))
	var available: Array = []
	for item in normal_pool:
		if String((item as Dictionary).get("id", "")) != previous:
			available.append(item)
	var offer: Array = []
	var category_groups: Array = [["boss"], ["player"], ["partner", "field", "heal"]]
	for category_group in category_groups:
		var candidate_indices: Array[int] = []
		for i in range(available.size()):
			var candidate: Dictionary = available[i] as Dictionary
			if (category_group as Array).has(String(candidate.get("category", ""))):
				candidate_indices.append(i)
		if not candidate_indices.is_empty():
			var chosen_index := int(candidate_indices[rng.randi_range(0, candidate_indices.size() - 1)])
			offer.append(available[chosen_index])
			available.remove_at(chosen_index)
		elif not available.is_empty():
			var fallback_index := rng.randi_range(0, available.size() - 1)
			offer.append(available[fallback_index])
			available.remove_at(fallback_index)
	while offer.size() > 3:
		offer.pop_back()

	# The cycle is incremented only when the modal is actually opened.
	var cycle := int(target.get("relay_boss_instruction_cycle")) + 1
	target.set("relay_boss_instruction_cycle", cycle)
	var support_offered := false
	var support_id := ""
	var support_settings: Dictionary = (boss_config.get("bossInstructionSettings", {}) as Dictionary).get("support", {}) as Dictionary
	if HardModeSystemScript.is_hard_target(target):
		support_settings = support_settings.duplicate(true)
		support_settings["baseChance"] = float(HardModeSystemScript.final_boss_rates(HardModeSystemScript.runtime_for_target(target)).get("supportChance", support_settings.get("baseChance", 0.15)))
	var support_enabled := bool(support_settings.get("enabled", false))
	var max_support_per_offer := mini(1, maxi(0, int(support_settings.get("maxPerOffer", 1))))
	var last_offer_cycle := int(target.get("relay_boss_support_last_offer_cycle"))
	var eligible := support_enabled and max_support_per_offer > 0 and not support_pool.is_empty()
	eligible = eligible and float(target.get("relay_boss_support_appearance_cooldown")) <= 0.0
	eligible = eligible and cycle - last_offer_cycle > 1
	if eligible and not offer.is_empty():
		var hp_ratio := float(target.get("player_hp")) / maxf(1.0, float(target.get("player_max_hp")))
		var low_hp_threshold := float(support_settings.get("lowHpThreshold", 0.35))
		var chance := float(support_settings.get("lowHpChance", 0.30)) if hp_ratio <= low_hp_threshold else float(support_settings.get("baseChance", 0.15))
		var pity := float(target.get("relay_boss_encounter_elapsed")) >= float(support_settings.get("pityElapsed", 90.0)) and not bool(target.get("relay_boss_support_ever_offered"))
		if pity or rng.randf() < clampf(chance, 0.0, 1.0):
			var last_id := String(target.get("relay_boss_support_last_id"))
			var eligible_supports: Array = []
			for support in support_pool:
				if String((support as Dictionary).get("id", "")) != last_id:
					eligible_supports.append(support)
			if eligible_supports.is_empty():
				eligible_supports = support_pool.duplicate(true)
			var support_index := rng.randi_range(0, eligible_supports.size() - 1)
			var support: Dictionary = eligible_supports[support_index] as Dictionary
			support_id = String(support.get("id", ""))
			var replace_index := rng.randi_range(0, offer.size() - 1)
			offer[replace_index] = support
			support_offered = true
			target.set("relay_boss_support_ever_offered", true)
			target.set("relay_boss_support_appearance_cooldown", float(support_settings.get("appearanceCooldown", 45.0)))
			target.set("relay_boss_support_last_offer_cycle", cycle)
			target.set("relay_boss_support_last_id", support_id)

	target.set("offered_comments", offer)
	target.set("selected_card", 0)
	target.set("heart_cards", [false, false, false])
	target.set("ng_cards", [false, false, false])
	target.set("choice_timer", float((boss_config.get("bossInstructionSettings", {}) as Dictionary).get("choiceTime", 10.0)))
	target.set("comment_warning_step", 0)
	target.set("state", "comment_choice")
	choice_box.visible = true
	PauseReasonSystemScript.add(target, "InstructionComment")
	return {"supportOffered": support_offered, "supportId": support_id}

static func _normalize_comment(source: Dictionary) -> Dictionary:
	var comment := source.duplicate(true)
	comment["riskLevel"] = int(comment.get("riskLevel", 1))
	comment["giftHypeOnSelect"] = int(comment.get("giftHypeOnSelect", 0))
	comment["giftHypeOnClear"] = int(comment.get("giftHypeOnClear", 0))
	comment["deathText"] = String(comment.get("deathText", ""))
	comment["duration"] = float(comment.get("duration", 15.0))
	comment["effectType"] = String(comment.get("effectType", ""))
	comment["category"] = String(comment.get("category", "default"))
	comment["difficultyBonus"] = int(comment.get("difficultyBonus", 0))
	if comment["category"] == "boss_support":
		comment["difficultyBonus"] = 0
	if not comment.has("params") or not comment["params"] is Dictionary:
		comment["params"] = {}
	return comment

static func update_comment_choice_for_target(target: Node, delta: float, latch: Dictionary, _rng: RandomNumberGenerator) -> int:
	var timer := float(target.get("choice_timer")) - delta
	target.set("choice_timer", timer)
	var offer: Array = target.get("offered_comments") as Array
	var action := ChoiceCardSystemScript.selection_action(latch, int(target.get("selected_card")), maxi(1, offer.size()))
	if ChoiceCardSystemScript.is_move(action):
		target.set("selected_card", int(action["index"]))
		return -1
	if ChoiceCardSystemScript.is_select(action):
		return int(action["index"])
	if timer <= 0.0:
		return clampi(int(target.get("selected_card")), 0, maxi(0, offer.size() - 1))
	return -1

static func choose_instruction_for_target(target: Node, index: int, choice_box: Control) -> Dictionary:
	var offer: Array = target.get("offered_comments") as Array
	if index < 0 or index >= offer.size():
		return {"selected": false}
	var comment: Dictionary = offer[index] as Dictionary
	var buzz_state: Dictionary = BuzzSystemScript.instruction_transition(int(target.get("burn_combo")), int(target.get("burn_combo_max")), int(comment.get("riskLevel", 1)))
	var buzz_before: int = int(buzz_state["buzzBefore"])
	var buzz_gain: int = int(buzz_state["buzzGainRequested"])
	var buzz_after: int = int(buzz_state["buzzAfter"])
	var buzz_max: int = int(buzz_state["burnComboMax"])
	clear_active_instruction_for_target(target)
	target.set("relay_boss_instruction", comment.duplicate(true))
	target.set("relay_boss_instruction_last_id", String(comment.get("id", "")))
	target.set("relay_boss_instruction_timer", float(comment.get("duration", ((target.get("relay_mode_config") as Dictionary).get("boss", {}) as Dictionary).get("bossInstructionSettings", {}).get("effectTime", 15.0))))
	var heal_amount := _apply_instruction_state(target, String(comment.get("id", "")))
	var support_selected := String(comment.get("category", "")) == "boss_support"
	target.set("relay_boss_support_selected", support_selected)
	target.set("relay_boss_support_selected_id", String(comment.get("id", "")) if support_selected else "")
	target.set("relay_boss_support_heal_amount", heal_amount)
	target.set("burn_combo", buzz_after)
	target.set("burn_combo_max", buzz_max)
	target.set("state", "playing")
	target.set("comment_timer", 15.0)
	target.set("comment_warning_step", 0)
	choice_box.visible = false
	PauseReasonSystemScript.remove(target, "InstructionComment")
	return {"selected": true, "commentId": String(comment.get("id", "")), "chat": String(comment.get("displayName", "")) + " を選択", "supportSelected": support_selected, "supportId": String(comment.get("id", "")) if support_selected else "", "healAmount": heal_amount, "buzzBefore": buzz_before, "buzzAfter": buzz_after, "buzzDelta": int(buzz_state["buzzDelta"]), "buzzGainRequested": buzz_gain, "buzzChanged": bool(buzz_state["buzzChanged"]), "buzzReachedMax": bool(buzz_state["buzzReachedMax"])}
	return {"selected": true, "commentId": String(comment.get("id", "")), "chat": String(comment.get("displayName", "指示コメ")) + " を選択"}

static func clear_active_instruction_for_target(target: Node) -> void:
	var current: Dictionary = target.get("relay_boss_instruction") as Dictionary
	var current_id := String(current.get("id", ""))
	if String(current.get("category", "")) == "boss_support" and current_id != "":
		ModifierSystemScript.remove_multiplier_source_for_target(target, current_id)
	target.set("relay_boss_attack_interval_multiplier", 1.0)
	target.set("relay_boss_projectile_count_multiplier", 1.0)
	target.set("relay_boss_projectile_speed_multiplier", 1.0)
	target.set("collab_boss_partner_muted", false)
	target.set("relay_boss_arena_timer", 0.0)
	target.set("relay_boss_no_heal_timer", 0.0)
	if bool(target.get("relay_boss_no_dash_owned")):
		var active: Array = target.get("active_effects") as Array
		active.erase("no_dash")
	target.set("relay_boss_no_dash_owned", false)
	target.set("relay_boss_instruction", {})
	target.set("relay_boss_instruction_timer", 0.0)

static func _apply_instruction_state(target: Node, id: String) -> int:
	match id:
		"relay_boss_attack_up": target.set("relay_boss_attack_interval_multiplier", 0.75)
		"relay_boss_projectiles_up":
			target.set("relay_boss_projectile_count_multiplier", 1.40)
			target.set("relay_boss_projectile_speed_multiplier", 1.10)
		"relay_boss_movement_up":
			var movement := RelayBossMovementSystemScript.ensure_for_target(target)
			movement["attacks_since_reposition"] = RelayBossMovementSystemScript.attack_limit_for_target(target)
			movement["time_since_reposition"] = 999.0
			target.set("relay_boss_movement", movement)
		"relay_boss_no_dash":
			var active: Array = target.get("active_effects") as Array
			if not active.has("no_dash"):
				active.append("no_dash")
			target.set("relay_boss_no_dash_owned", true)
		"relay_boss_partner_mute": target.set("collab_boss_partner_muted", true)
		"relay_boss_small_arena": target.set("relay_boss_arena_timer", 16.0)
		"relay_boss_no_heal": target.set("relay_boss_no_heal_timer", 15.0)
		"boss_support_dont_lose":
			var params: Dictionary = (target.get("relay_boss_instruction") as Dictionary).get("params", {}) as Dictionary
			var requested_heal := ceili(float(target.get("player_max_hp")) * float(params.get("healMaxHpRate", 0.15)))
			var snapshot = target.get("permanent_upgrade_snapshot")
			if snapshot != null:
				requested_heal = PowerUpEffectProviderScript.scaled_heal_amount(requested_heal, snapshot, "boss_support_dont_lose")
			var actual_heal := mini(requested_heal, maxi(0, int(target.get("player_max_hp")) - int(target.get("player_hp"))))
			target.set("player_hp", mini(int(target.get("player_max_hp")), int(target.get("player_hp")) + maxi(0, actual_heal)))
			ModifierSystemScript.set_multiplier_source_for_target(target, id, {"playerDamageTaken": float(params.get("damageTakenMultiplier", 0.80))})
			return maxi(0, actual_heal)
		"boss_support_do_your_best":
			var best_params: Dictionary = (target.get("relay_boss_instruction") as Dictionary).get("params", {}) as Dictionary
			ModifierSystemScript.set_multiplier_source_for_target(target, id, {"playerAttackDamage": float(best_params.get("playerAttackMultiplier", 1.25)), "playerMoveSpeed": float(best_params.get("playerMoveSpeedMultiplier", 1.10))})
	return 0

static func _update_instruction_timer(target: Node, delta: float) -> void:
	var timer := maxf(0.0, float(target.get("relay_boss_instruction_timer")) - delta)
	target.set("relay_boss_instruction_timer", timer)
	if timer > 0.0:
		return
	clear_active_instruction_for_target(target)

static func mark_defeated(target: Node) -> void:
	if not is_active(target) or bool(target.get("relay_boss_defeat_pending")):
		return
	clear_active_instruction_for_target(target)
	_clear_support_modifiers_for_target(target)
	target.set("relay_boss_support_fx", [])
	if target.has_method("_stop_relay_boss_support_audio"):
		target.call("_stop_relay_boss_support_audio")
	target.set("relay_boss_defeat_pending", true)
	target.set("boss_defeated", true)
	target.set("boss_last_result", "defeated")
	(target.get("enemy_bullets") as Array).clear()
	RelayBossAttackSystemScript.interrupt_for_target(target, "defeat")
	RelayBossMovementSystemScript.interrupt_for_target(target, RelayBossMovementSystemScript.STATE_DEAD)
	_clear_phase_hazards(target)
	RelayBossDefenseSystemScript.force_clear(target, RelayBossDefenseSystemScript.STATE_DEAD)
	PauseReasonSystemScript.clear(target)

static func begin_pending_phase_transition_for_target(target: Node) -> bool:
	if not is_active(target) or float(target.get("relay_boss_phase_transition_timer")) > 0.0:
		return false
	var pending := int(target.get("relay_boss_pending_phase"))
	var current := int(target.get("relay_boss_phase"))
	if pending < 0 or pending == current:
		return false
	var active := RelayBossAttackSystemScript.active_attack_for_target(target)
	var state := String(active.get("state", RelayBossAttackSystemScript.STATE_IDLE))
	if state != RelayBossAttackSystemScript.STATE_IDLE:
		return false
	if target.has_method("_collab_combo_sequence_active") and bool(target.call("_collab_combo_sequence_active")):
		return false
	var boss_config: Dictionary = (target.get("relay_mode_config") as Dictionary).get("boss", {}) as Dictionary
	if not RelayBossMovementSystemScript.begin_phase_transition(target, target.call("_current_arena")):
		return false
	RelayBossAttackSystemScript.clear_runtime_objects_for_target(target)
	_clear_phase_hazards(target)
	if not RelayBossDefenseSystemScript.begin_phase_transition(target, pending):
		RelayBossMovementSystemScript.force_resume_for_target(target, target.call("_current_arena"))
		return false
	# Commit the HUD phase as soon as the transition is accepted.  The boss
	# still remains in the center/transition lock until movement reports arrival
	# and the presentation timer completes.
	target.set("relay_boss_phase", clampi(pending, 0, max_phase_for_target(target)))
	target.set("relay_boss_phase_center_timer", float((boss_config.get("movement", {}) as Dictionary).get("phaseTransitionCenterTime", 0.7)))
	# HARD counts the move-to-center inside the configured 1.5-second
	# invincibility. NORMAL retains the existing additional presentation time.
	target.set("relay_boss_phase_transition_timer", float(boss_config.get("phaseTransitionTime", 1.5)) if _is_hard_final_target(target) else 0.0)
	PauseReasonSystemScript.add(target, "BossPhaseTransition")
	return true

static func force_phase_for_target(target: Node) -> bool:
	if not is_active(target):
		return false
	var next_phase := mini(max_phase_for_target(target), int(target.get("relay_boss_phase")) + 1)
	target.set("relay_boss_pending_phase", next_phase)
	RelayBossAttackSystemScript.interrupt_for_target(target, "debug_phase")
	return begin_pending_phase_transition_for_target(target)

static func _phase_for_ratio(config: Dictionary, ratio: float) -> int:
	var thresholds: Array = config.get("phaseThresholds", [0.80, 0.60, 0.40, 0.20, 0.00]) as Array
	for i in range(thresholds.size() - 1):
		if ratio > float(thresholds[i]):
			return i
	return 4
