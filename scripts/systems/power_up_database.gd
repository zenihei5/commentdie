class_name PowerUpDatabase
extends RefCounted

const DatabaseScript := preload("res://scripts/systems/power_up_database.gd")

const DATA_PATH := "res://data/power_up_shop.json"
const VALID_CATEGORIES := ["combat", "support"]
const UPGRADE_IDS := ["max_hp", "attack_power", "move_speed", "damage_reduction", "exp_gain", "pickup_range", "healing_power", "gift_luck"]

var schema_version := 0
var currency: Dictionary = {}
var reward_rules: Dictionary = {}
var mascot_messages: Dictionary = {}
var categories: Array = []
var upgrades: Array = []
var errors: Array[String] = []
var is_valid := false

static func load_default():
	var database = DatabaseScript.new()
	if not FileAccess.file_exists(DATA_PATH):
		database.errors.append("missing master data: %s" % DATA_PATH)
		return database
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
	if not (parsed is Dictionary):
		database.errors.append("master data root is not an object")
		return database
	database.load_from_dictionary(parsed as Dictionary)
	return database

func load_from_dictionary(data: Dictionary) -> void:
	errors.clear()
	upgrades.clear()
	categories.clear()
	schema_version = int(data.get("schemaVersion", 0))
	currency = data.get("currency", {}) as Dictionary
	reward_rules = data.get("rewardRules", {}) as Dictionary
	mascot_messages = (data.get("mascotMessages", {}) as Dictionary).duplicate(true)
	categories = (data.get("categories", []) as Array).duplicate(true)
	var seen: Dictionary = {}
	for item in data.get("upgrades", []) as Array:
		if not (item is Dictionary):
			errors.append("upgrade is not an object")
			continue
		var upgrade: Dictionary = item as Dictionary
		var id := String(upgrade.get("id", ""))
		if id == "" or seen.has(id):
			errors.append("duplicate or empty upgrade id: %s" % id)
			continue
		seen[id] = true
		if not _validate_upgrade(upgrade):
			continue
		upgrades.append(upgrade.duplicate(true))
	for required_id in UPGRADE_IDS:
		if not seen.has(required_id):
			errors.append("missing required upgrade: %s" % required_id)
	is_valid = schema_version == 1 and errors.is_empty() and upgrades.size() == UPGRADE_IDS.size()

func get_upgrade(id: String) -> Dictionary:
	for item in upgrades:
		var upgrade: Dictionary = item as Dictionary
		if String(upgrade.get("id", "")) == id:
			return upgrade.duplicate(true)
	return {}

func upgrades_for_category(category: String) -> Array:
	var result: Array = []
	for item in upgrades:
		var upgrade: Dictionary = item as Dictionary
		if String(upgrade.get("category", "")) == category:
			result.append(upgrade.duplicate(true))
	return result

func category_name(category: String) -> String:
	for item in categories:
		var data: Dictionary = item as Dictionary
		if String(data.get("id", "")) == category:
			return String(data.get("displayName", category))
	return category

func reward_rule(group: String, key: String, fallback: Variant = 0) -> Variant:
	var group_data: Dictionary = reward_rules.get(group, {}) as Dictionary
	return group_data.get(key, fallback)

func difficulty_multiplier(difficulty_id: String) -> float:
	var difficulty: Dictionary = reward_rules.get("difficulty", {}) as Dictionary
	return maxf(0.0, float(difficulty.get(difficulty_id, 1.0)))

func max_level_for(id: String) -> int:
	var upgrade := get_upgrade(id)
	return int(upgrade.get("maxLevel", 0))

func _validate_upgrade(upgrade: Dictionary) -> bool:
	var id := String(upgrade.get("id", ""))
	var category := String(upgrade.get("category", ""))
	var max_level := int(upgrade.get("maxLevel", -1))
	var values: Array = upgrade.get("values", []) as Array
	var prices: Array = upgrade.get("prices", []) as Array
	var valid := true
	if not VALID_CATEGORIES.has(category):
		errors.append("unknown category for %s" % id)
		valid = false
	if max_level != 5 or values.size() != max_level + 1 or prices.size() != max_level:
		errors.append("invalid level/value/price lengths for %s" % id)
		valid = false
	for value in values:
		if float(value) < 0.0:
			errors.append("negative upgrade value for %s" % id)
			valid = false
	for price in prices:
		if int(price) < 0:
			errors.append("negative upgrade price for %s" % id)
			valid = false
	if id == "gift_luck":
		var luck: Dictionary = upgrade.get("giftLuck", {}) as Dictionary
		if (luck.get("hitWeightMultipliers", []) as Array).size() != max_level + 1 or (luck.get("jackpotWeightMultipliers", []) as Array).size() != max_level + 1:
			errors.append("invalid gift luck arrays")
			valid = false
	return valid
