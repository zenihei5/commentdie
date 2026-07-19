class_name PauseReasonSystem
extends RefCounted

static func add(target: Node, reason: String) -> void:
	var reasons: Array = target.get("pause_reasons") as Array
	if not reasons.has(reason):
		reasons.append(reason)

static func remove(target: Node, reason: String) -> void:
	var reasons: Array = target.get("pause_reasons") as Array
	reasons.erase(reason)

static func clear(target: Node) -> void:
	(target.get("pause_reasons") as Array).clear()

static func is_paused(target: Node) -> bool:
	return not (target.get("pause_reasons") as Array).is_empty()

static func reasons(target: Node) -> Array:
	return (target.get("pause_reasons") as Array).duplicate()
