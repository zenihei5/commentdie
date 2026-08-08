class_name DangerEventSystem
extends RefCounted

const CATEGORIES: Array[String] = [
	"surround",
	"high_speed",
	"high_density",
	"ranged_pressure",
	"forced_movement",
	"screen_restriction",
	"stage_major_event",
	"boss_major_attack",
	"collab_challenge"
]

const ALIASES := {"high_density_wave": "high_density"}

const CONFLICTS := {
	"surround": ["forced_movement", "screen_restriction"],
	"forced_movement": ["surround"],
	"screen_restriction": ["surround", "ranged_pressure"],
	"high_density": ["boss_major_attack", "collab_challenge"],
	"boss_major_attack": ["high_density", "stage_major_event"],
	"collab_challenge": ["high_density"],
	"ranged_pressure": ["screen_restriction"],
	"stage_major_event": ["boss_major_attack"]
}

static func begin(runtime: Dictionary, category: String, owner: String = "", priority: int = 0) -> bool:
	category = normalize_category(category)
	if category == "" or not CATEGORIES.has(category):
		return false
	var active: Dictionary = runtime.get("dangerCategories", {}) as Dictionary
	for key in active.keys():
		var event: Dictionary = active[key] as Dictionary
		var active_category := normalize_category(String(key))
		if active_category == category:
			continue
		if conflicts(category, active_category):
			return false
		if priority < int(event.get("priority", 0)):
			continue
		if priority == int(event.get("priority", 0)) and String(key) != category:
			return false
	active[category] = {"owner": owner, "priority": priority}
	runtime["dangerCategories"] = active
	return true

static func end(runtime: Dictionary, category: String, owner: String = "") -> void:
	category = normalize_category(category)
	var active: Dictionary = runtime.get("dangerCategories", {}) as Dictionary
	if not active.has(category):
		return
	if owner == "" or String((active[category] as Dictionary).get("owner", "")) == owner:
		active.erase(category)
	runtime["dangerCategories"] = active

static func clear(runtime: Dictionary) -> void:
	runtime["dangerCategories"] = {}

static func is_active(runtime: Dictionary, category: String) -> bool:
	return (runtime.get("dangerCategories", {}) as Dictionary).has(normalize_category(category))

static func can_start(runtime: Dictionary, category: String, priority: int = 0) -> bool:
	category = normalize_category(category)
	if category == "" or not CATEGORIES.has(category):
		return false
	var active: Dictionary = runtime.get("dangerCategories", {}) as Dictionary
	if active.has(category):
		return true
	for key in active.keys():
		var active_category := normalize_category(String(key))
		if conflicts(category, active_category):
			return false
		var event: Dictionary = active[key] as Dictionary
		if priority < int((event as Dictionary).get("priority", 0)):
			return false
	return true

static func normalize_category(category: String) -> String:
	var value := category.strip_edges().to_lower()
	return String(ALIASES.get(value, value))

static func conflicts(left: String, right: String) -> bool:
	var normalized_left := normalize_category(left)
	var normalized_right := normalize_category(right)
	if normalized_left == normalized_right:
		return true
	return normalized_right in (CONFLICTS.get(normalized_left, []) as Array) or normalized_left in (CONFLICTS.get(normalized_right, []) as Array)

static func can_start_categories(active: Dictionary, requested: Array, blocked: Array = []) -> bool:
	var normalized_active: Array = []
	for key in active.keys():
		normalized_active.append(normalize_category(String(key)))
	var normalized_blocked: Array = []
	for item in blocked:
		normalized_blocked.append(normalize_category(String(item)))
	var normalized_requested: Array = []
	for item in requested:
		var category := normalize_category(String(item))
		if category == "" or not CATEGORIES.has(category) or normalized_blocked.has(category):
			return false
		for other_category in normalized_requested:
			if conflicts(category, String(other_category)):
				return false
		normalized_requested.append(category)
		for active_category in normalized_active:
			if conflicts(category, String(active_category)):
				return false
	for blocked_category in normalized_blocked:
		for active_category in normalized_active:
			if conflicts(String(blocked_category), String(active_category)):
				return false
	return true
