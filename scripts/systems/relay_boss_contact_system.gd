class_name RelayBossContactSystem
extends RefCounted

const MovementSystemScript := preload("res://scripts/systems/relay_boss_movement_system.gd")
const PlayerSystemScript := preload("res://scripts/systems/player_system.gd")
const HardModeSystemScript := preload("res://scripts/systems/hard_mode_system.gd")

const DEFAULT_CONTACT := {
    "damage": 12,
    "rehitSeconds": 1.0,
    "knockbackDistance": 140.0,
    "knockbackDuration": 0.22,
    "shape": "circle",
    "radius": 105.0,
    "centerMarker": "CoreCenter",
    "playerRadius": 22.0,
    "reenableAfterRepositionSeconds": 0.15,
    "arrivalPushDuration": 0.12,
    "arrivalPushPadding": 10.0,
    "minimumDestinationPlayerDistance": 220.0,
    "enabledStates": ["IDLE_HOVER", "CRUISING", "ATTACKING", "PHASE_TRANSITION"],
    "disabledStates": ["REPOSITION_WARNING", "REPOSITIONING", "STUNNED", "DEAD"],
    "effectKind": "relay_boss_contact_noise"
}

static func empty_runtime() -> Dictionary:
    return {
        "damage_cooldown": 0.0,
        "reenable_timer": 0.0,
        "arrival_overlap_pending": false,
        "last_movement_state": "IDLE_HOVER",
        "knockback_active": false,
        "knockback_elapsed": 0.0,
        "knockback_duration": 0.0,
        "knockback_start": Vector2.ZERO,
        "knockback_target": Vector2.ZERO,
        "knockback_is_safety_push": false
    }

static func reset_for_target(target: Node) -> void:
    target.set("relay_boss_contact_runtime", empty_runtime())

static func _runtime_for_target(target: Node) -> Dictionary:
    var runtime_variant: Variant = target.get("relay_boss_contact_runtime")
    if runtime_variant is Dictionary and not (runtime_variant as Dictionary).is_empty():
        return runtime_variant as Dictionary
    var runtime := empty_runtime()
    target.set("relay_boss_contact_runtime", runtime)
    return runtime

static func _contact_config(target: Node) -> Dictionary:
    var config_variant: Variant = target.get("relay_mode_config")
    var config: Dictionary = config_variant as Dictionary if config_variant is Dictionary else {}
    var boss: Dictionary = config.get("boss", {}) as Dictionary
    var configured: Dictionary = boss.get("contact", {}) as Dictionary
    var result := DEFAULT_CONTACT.duplicate(true)
    for key in configured.keys():
        result[key] = configured[key]
    return result

static func _active_boss(target: Node) -> Dictionary:
    var enemies_variant: Variant = target.get("enemies")
    if not enemies_variant is Array:
        return {}
    for item in enemies_variant as Array:
        var enemy: Dictionary = item as Dictionary
        if bool(enemy.get("relayBoss", false)) and not bool(enemy.get("relayBossSummon", false)):
            return enemy
        if String(enemy.get("bossId", "")) == "last_offline" and not bool(enemy.get("relayBossSummon", false)):
            return enemy
    return {}

static func _movement_state(target: Node) -> String:
    return MovementSystemScript.state_for_target(target)

static func _state_in(states: Array, value: String) -> bool:
    for item in states:
        if String(item) == value:
            return true
    return false

static func _contact_enabled(target: Node, state: String, config: Dictionary) -> bool:
    var disabled: Array = config.get("disabledStates", []) as Array
    if _state_in(disabled, state):
        return false
    var enabled: Array = config.get("enabledStates", []) as Array
    if not _state_in(enabled, state):
        return false
    var movement_variant: Variant = target.get("relay_boss_movement")
    if state == MovementSystemScript.STATE_PHASE_TRANSITION and movement_variant is Dictionary:
        if bool((movement_variant as Dictionary).get("phase_center_pending", false)):
            return false
    return true

static func on_reposition_started_for_target(target: Node) -> void:
    var runtime := _runtime_for_target(target)
    runtime["reenable_timer"] = 0.0
    runtime["arrival_overlap_pending"] = false
    runtime["knockback_active"] = false
    runtime["knockback_is_safety_push"] = false
    runtime["last_movement_state"] = MovementSystemScript.STATE_REPOSITION_WARNING
    target.set("relay_boss_contact_runtime", runtime)

static func on_reposition_finished_for_target(target: Node) -> void:
    var runtime := _runtime_for_target(target)
    var config := _contact_config(target)
    runtime["reenable_timer"] = maxf(0.0, float(config.get("reenableAfterRepositionSeconds", 0.15)))
    runtime["arrival_overlap_pending"] = true
    runtime["knockback_active"] = false
    runtime["knockback_is_safety_push"] = false
    runtime["last_movement_state"] = _movement_state(target)
    target.set("relay_boss_contact_runtime", runtime)

static func update_for_target(target: Node, delta: float, arena: Rect2, freeze_gameplay: bool = false) -> Dictionary:
    var feedback := {"damageEvents": [], "contactSucceeded": false}
    if not bool(target.get("relay_boss_active")) or freeze_gameplay:
        return feedback
    if bool(target.get("relay_boss_defeat_pending")) or bool(target.get("relay_boss_player_death_pending")):
        return feedback
    var boss := _active_boss(target)
    if boss.is_empty() or float(boss.get("hp", 0.0)) <= 0.0:
        return feedback
    if bool(boss.get("cutinIntroLocked", false)):
        return feedback
    var config := _contact_config(target)
    var runtime := _runtime_for_target(target)
    var safe_delta := maxf(0.0, delta)
    runtime["damage_cooldown"] = maxf(0.0, float(runtime.get("damage_cooldown", 0.0)) - safe_delta)
    runtime["reenable_timer"] = maxf(0.0, float(runtime.get("reenable_timer", 0.0)) - safe_delta)
    var state := _movement_state(target)
    if state == MovementSystemScript.STATE_REPOSITION_WARNING or state == MovementSystemScript.STATE_REPOSITION:
        runtime["arrival_overlap_pending"] = false
        runtime["knockback_active"] = false
        runtime["last_movement_state"] = state
        target.set("relay_boss_contact_runtime", runtime)
        return feedback
    var transition_timer_variant: Variant = target.get("relay_boss_phase_transition_timer")
    if transition_timer_variant != null and float(transition_timer_variant) > 0.0:
        runtime["last_movement_state"] = state
        target.set("relay_boss_contact_runtime", runtime)
        return feedback
    var boss_center := MovementSystemScript.marker_world_position(target, String(config.get("centerMarker", "CoreCenter")), arena)
    if runtime["arrival_overlap_pending"]:
        var safety_active := _update_arrival_safety_push(target, arena, boss_center, runtime, config, safe_delta)
        if not safety_active and runtime["reenable_timer"] <= 0.0:
            runtime["arrival_overlap_pending"] = false
        else:
            runtime["last_movement_state"] = state
            target.set("relay_boss_contact_runtime", runtime)
            return feedback
    if runtime["reenable_timer"] > 0.0 or not _contact_enabled(target, state, config):
        runtime["last_movement_state"] = state
        target.set("relay_boss_contact_runtime", runtime)
        return feedback
    if bool(target.get("invincible")) or bool(target.get("debug_invincible")):
        runtime["last_movement_state"] = state
        target.set("relay_boss_contact_runtime", runtime)
        return feedback
    var player_pos := Vector2(target.get("player_pos"))
    var combined_radius := float(config.get("radius", 105.0)) + float(config.get("playerRadius", 22.0))
    if boss_center.distance_squared_to(player_pos) > combined_radius * combined_radius:
        runtime["last_movement_state"] = state
        target.set("relay_boss_contact_runtime", runtime)
        return feedback
    if float(runtime.get("damage_cooldown", 0.0)) > 0.0 or bool(runtime.get("knockback_active", false)):
        runtime["last_movement_state"] = state
        target.set("relay_boss_contact_runtime", runtime)
        return feedback
    var damage := maxi(0, int(config.get("damage", 12)))
    if HardModeSystemScript.is_high_difficulty_target(target):
        var rates := HardModeSystemScript.final_boss_rates(HardModeSystemScript.runtime_for_target(target))
        damage = HardModeSystemScript.scaled_damage(float(damage), float(rates.get("attackRate", 1.10)))
    var damage_events: Array = feedback["damageEvents"] as Array
    damage_events.append({
        "source": "last_offline contact",
        "damage": damage,
        "enemyId": "last_offline",
        "runtimeVariant": "",
        "attackType": "contact"
    })
    runtime["damage_cooldown"] = maxf(0.0, float(config.get("rehitSeconds", 1.0)))
    _begin_knockback(target, arena, boss_center, player_pos, runtime, config, false)
    _append_contact_noise_fx(target, boss_center, player_pos, config)
    feedback["contactSucceeded"] = true
    runtime["last_movement_state"] = state
    target.set("relay_boss_contact_runtime", runtime)
    return feedback

static func _begin_knockback(target: Node, arena: Rect2, boss_center: Vector2, player_pos: Vector2, runtime: Dictionary, config: Dictionary, safety_push: bool) -> void:
    var direction := player_pos - boss_center
    if direction.length_squared() <= 0.01:
        direction = Vector2.DOWN
    else:
        direction = direction.normalized()
    var distance := float(config.get("knockbackDistance", 140.0))
    if safety_push:
        var combined := float(config.get("radius", 105.0)) + float(config.get("playerRadius", 22.0))
        distance = maxf(0.0, combined - boss_center.distance_to(player_pos)) + float(config.get("arrivalPushPadding", 10.0))
    var desired := player_pos + direction * distance
    var safe_target := _safe_player_destination(target, player_pos, desired, arena)
    var duration := float(config.get("knockbackDuration", 0.22))
    if safety_push:
        duration = float(config.get("arrivalPushDuration", 0.12))
    runtime["knockback_active"] = true
    runtime["knockback_elapsed"] = 0.0
    runtime["knockback_duration"] = maxf(0.01, duration)
    runtime["knockback_start"] = player_pos
    runtime["knockback_target"] = safe_target
    runtime["knockback_is_safety_push"] = safety_push
    if not safety_push:
        target.set("click_move_active", false)
        var velocity := Vector2(target.get("player_vel"))
        var boss_component := velocity.dot(direction)
        if boss_component > 0.0:
            velocity -= direction * boss_component
        target.set("player_vel", velocity)
    target.set("relay_boss_contact_runtime", runtime)

static func _update_arrival_safety_push(target: Node, arena: Rect2, boss_center: Vector2, runtime: Dictionary, config: Dictionary, delta: float) -> bool:
    var player_pos := Vector2(target.get("player_pos"))
    var combined := float(config.get("radius", 105.0)) + float(config.get("playerRadius", 22.0))
    if not bool(runtime.get("knockback_active", false)):
        if boss_center.distance_to(player_pos) > combined:
            return false
        _begin_knockback(target, arena, boss_center, player_pos, runtime, config, true)
    _advance_knockback(target, arena, runtime, delta)
    return bool(runtime.get("knockback_active", false))

static func update_knockback_for_target(target: Node, delta: float, arena: Rect2) -> void:
    var runtime := _runtime_for_target(target)
    if not bool(runtime.get("knockback_active", false)):
        return
    _advance_knockback(target, arena, runtime, maxf(0.0, delta))
    target.set("relay_boss_contact_runtime", runtime)

static func _advance_knockback(target: Node, arena: Rect2, runtime: Dictionary, delta: float) -> void:
    if not bool(runtime.get("knockback_active", false)):
        return
    var duration := maxf(0.01, float(runtime.get("knockback_duration", 0.22)))
    var elapsed := minf(duration, float(runtime.get("knockback_elapsed", 0.0)) + maxf(0.0, delta))
    var progress := clampf(elapsed / duration, 0.0, 1.0)
    var eased := 1.0 - pow(1.0 - progress, 3.0)
    var start := Vector2(runtime.get("knockback_start", target.get("player_pos")))
    var destination := Vector2(runtime.get("knockback_target", start))
    var current := Vector2(target.get("player_pos"))
    var desired := start.lerp(destination, eased)
    target.set("player_pos", _safe_player_destination(target, current, desired, arena))
    runtime["knockback_elapsed"] = elapsed
    if progress >= 1.0:
        runtime["knockback_active"] = false
        runtime["knockback_is_safety_push"] = false

static func _safe_player_destination(target: Node, from_pos: Vector2, desired: Vector2, arena: Rect2) -> Vector2:
    var radius := 28.0
    var current := _clamp_player(desired, arena, radius)
    var origin := _clamp_player(from_pos, arena, radius)
    var distance := origin.distance_to(current)
    var steps := maxi(1, int(ceil(distance / 10.0)))
    var last := origin
    var walls_variant: Variant = target.get("effect_walls")
    var walls: Array = walls_variant as Array if walls_variant is Array else []
    var frame_id := DrawDataSystem.collision_frame_id_for_target(target)
    for step in range(1, steps + 1):
        var candidate := origin.lerp(current, float(step) / float(steps))
        candidate = _clamp_player(candidate, arena, radius)
        var resolved := PlayerSystemScript.resolve_wall_collision(candidate, last, radius, walls, frame_id)
        if resolved.distance_to(candidate) > 1.5:
            break
        last = resolved
    return _clamp_player(last, arena, radius)

static func _clamp_player(pos: Vector2, arena: Rect2, radius: float) -> Vector2:
    return Vector2(
        clampf(pos.x, arena.position.x + radius, arena.end.x - radius),
        clampf(pos.y, arena.position.y + radius, arena.end.y - radius)
    )

static func _append_contact_noise_fx(target: Node, boss_center: Vector2, player_pos: Vector2, config: Dictionary) -> void:
    var hit_fx_variant: Variant = target.get("hit_fx")
    if not hit_fx_variant is Array:
        return
    var direction := player_pos - boss_center
    if direction.length_squared() <= 0.01:
        direction = Vector2.DOWN
    else:
        direction = direction.normalized()
    var radius := float(config.get("radius", 105.0))
    (hit_fx_variant as Array).append({
        "kind": String(config.get("effectKind", "relay_boss_contact_noise")),
        "pos": boss_center + direction * radius,
        "dir": direction,
        "life": 0.30,
        "maxLife": 0.30
    })
