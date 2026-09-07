class_name CodexRewardSystem
extends RefCounted

## Data-defined, side-effect-free rules for persistent Codex milestone rewards.
## Discovery counts and claimed IDs are supplied by callers; this system never
## reads or mutates CodexManager/PowerUpShopManager state.

const MASTER_PATH := "res://data/codex_rewards.json"
const KNOWN_CATEGORIES: Array[String] = [
	"characters",
	"weapons",
	"accessories",
	"enemies",
	"comments"
]

var _master: Dictionary = {}
var _milestones: Array[Dictionary] = []
var _categories: Array[String] = []
var _valid := false
var _error := ""

func _init(master_override: Variant = null) -> void:
	var source: Variant = master_override
	if master_override == null:
		if FileAccess.file_exists(MASTER_PATH):
			source = JSON.parse_string(FileAccess.get_file_as_string(MASTER_PATH))
	_load_master(source)

func is_valid() -> bool:
	return _valid

func error_message() -> String:
	return _error

func master_version() -> int:
	return int(_master.get("version", 0))

func category_ids() -> Array[String]:
	return _categories.duplicate()

func milestone_definitions() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for item in _milestones:
		result.append(item.duplicate(true))
	return result

func category_status(category_id: String, found: int, total: int, claimed_ids: Array, shop_unlocked: bool) -> Dictionary:
	var category := category_id.strip_edges().to_lower()
	if not _valid:
		return _invalid_status(category, "master_invalid")
	if not _categories.has(category):
		return _invalid_status(category, "invalid_category")
	var safe_total := maxi(0, total)
	var safe_found := clampi(found, 0, safe_total)
	var display_percent := floori(float(safe_found) * 100.0 / float(safe_total)) if safe_total > 0 else 0
	var claimed: Array[String] = _normalize_claimed_ids(claimed_ids)
	var milestones: Array[Dictionary] = []
	var eligible_ids: Array[String] = []
	var claimable_ids: Array[String] = []
	var eligible_pp := 0
	var claimable_pp := 0
	for definition in _milestones:
		var percent := int(definition["percent"])
		var pp := int(definition["pp"])
		var required_count := ceili(float(safe_total) * float(percent) / 100.0) if safe_total > 0 else 0
		var reached := safe_total > 0 and safe_found >= required_count
		var milestone_id := milestone_id_for(category, percent)
		var is_claimed := claimed.has(milestone_id)
		var state := "claimed" if is_claimed else ("claimable" if reached else "unachieved")
		var remaining := maxi(0, required_count - safe_found)
		var milestone := {
			"id": milestone_id,
			"percent": percent,
			"pp": pp,
			"requiredCount": required_count,
			"remainingCount": remaining,
			"reached": reached,
			"state": state,
			"claimed": is_claimed
		}
		milestones.append(milestone)
		if reached and not is_claimed:
			eligible_ids.append(milestone_id)
			eligible_pp += pp
			if shop_unlocked:
				claimable_ids.append(milestone_id)
				claimable_pp += pp
	var next_milestone: Dictionary = {}
	for milestone in milestones:
		if not bool(milestone.get("claimed", false)) and not bool(milestone.get("reached", false)):
			next_milestone = milestone.duplicate(true)
			break
	var all_claimed := true
	for milestone in milestones:
		if not bool(milestone.get("claimed", false)):
			all_claimed = false
			break
	var blocked_reason := ""
	if not shop_unlocked and not eligible_ids.is_empty():
		blocked_reason = "shop_locked"
	elif not claimable_ids.is_empty():
		blocked_reason = ""
	elif not eligible_ids.is_empty():
		blocked_reason = "shop_locked"
	return {
		"ok": true,
		"categoryId": category,
		"found": safe_found,
		"total": safe_total,
		"displayPercent": display_percent,
		"milestones": milestones,
		"eligibleIds": eligible_ids,
		"eligiblePp": eligible_pp,
		"claimableIds": claimable_ids,
		"claimablePp": claimable_pp,
		"nextMilestone": next_milestone,
		"allClaimed": all_claimed,
		"currentComplete": safe_total > 0 and safe_found == safe_total,
		"shopUnlocked": shop_unlocked,
		"claimEnabled": not claimable_ids.is_empty(),
		"blockedReason": blocked_reason
	}

func crossed_milestones(category_id: String, previous_found: int, current_found: int, total: int) -> Array[Dictionary]:
	var category := category_id.strip_edges().to_lower()
	var result: Array[Dictionary] = []
	if not _valid or not _categories.has(category):
		return result
	var safe_total := maxi(0, total)
	if safe_total <= 0:
		return result
	var previous := clampi(previous_found, 0, safe_total)
	var current := clampi(current_found, 0, safe_total)
	if current <= previous:
		return result
	for definition in _milestones:
		var percent := int(definition["percent"])
		var required_count := ceili(float(safe_total) * float(percent) / 100.0)
		if previous < required_count and required_count <= current:
			result.append({
				"id": milestone_id_for(category, percent),
				"percent": percent,
				"pp": int(definition["pp"]),
				"requiredCount": required_count
			})
	return result

func milestone_id_for(category_id: String, percent: int) -> String:
	return category_id.strip_edges().to_lower() + ":" + str(percent)

func _invalid_status(category: String, reason: String) -> Dictionary:
	return {
		"ok": false,
		"categoryId": category,
		"found": 0,
		"total": 0,
		"displayPercent": 0,
		"milestones": [],
		"eligibleIds": [],
		"eligiblePp": 0,
		"claimableIds": [],
		"claimablePp": 0,
		"nextMilestone": {},
		"allClaimed": false,
		"currentComplete": false,
		"shopUnlocked": false,
		"claimEnabled": false,
		"blockedReason": reason
	}

func _normalize_claimed_ids(value: Array) -> Array[String]:
	var result: Array[String] = []
	for item in value:
		var id := String(item).strip_edges()
		if id != "" and not result.has(id):
			result.append(id)
	return result

func _load_master(source: Variant) -> void:
	_valid = false
	_error = ""
	_master = {}
	_milestones.clear()
	_categories.clear()
	if not source is Dictionary:
		_error = "master root is not an object"
		return
	var raw := source as Dictionary
	var raw_categories: Variant = raw.get("categories", [])
	if not raw_categories is Array or (raw_categories as Array).is_empty():
		_error = "categories are missing"
		return
	for item in raw_categories as Array:
		var category := String(item).strip_edges().to_lower()
		if not KNOWN_CATEGORIES.has(category) or _categories.has(category):
			_error = "invalid or duplicate category: %s" % category
			_categories.clear()
			return
		_categories.append(category)
	var raw_version: Variant = raw.get("version", null)
	if not _is_positive_integer(raw_version) or int(raw_version) != 1:
		_error = "unsupported master version"
		_categories.clear()
		return
	var raw_milestones: Variant = raw.get("milestones", [])
	if not raw_milestones is Array or (raw_milestones as Array).is_empty():
		_error = "milestones are missing"
		_categories.clear()
		return
	var previous_percent := 0
	for item in raw_milestones as Array:
		if not item is Dictionary:
			_error = "milestone is not an object"
			_milestones.clear()
			_categories.clear()
			return
		var definition := item as Dictionary
		var raw_percent: Variant = definition.get("percent", null)
		var raw_pp: Variant = definition.get("pp", null)
		if not _is_positive_integer(raw_percent) or not _is_positive_integer(raw_pp):
			_error = "milestone percent/pp must be positive integers"
			_milestones.clear()
			_categories.clear()
			return
		var percent := int(raw_percent)
		if percent < 1 or percent > 100 or percent <= previous_percent:
			_error = "milestone percents must be strictly ascending from 1 to 100"
			_milestones.clear()
			_categories.clear()
			return
		previous_percent = percent
		_milestones.append({"percent": percent, "pp": int(raw_pp)})
	_master = raw.duplicate(true)
	_valid = true

func _is_positive_integer(value: Variant) -> bool:
	if not (value is int or value is float):
		return false
	var number := float(value)
	return is_finite(number) and number > 0.0 and number == floorf(number)
