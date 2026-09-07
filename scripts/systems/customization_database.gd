class_name CustomizationDatabase
extends RefCounted

const DatabaseScript := preload("res://scripts/systems/customization_database.gd")
const MASTER_PATH := "res://data/customizations.json"
const VALID_CATEGORIES := ["title", "theme", "result_stamp"]

var is_valid := false
var version := 0
var conditions: Dictionary = {}
var items: Array[Dictionary] = []
var _items_by_id: Dictionary = {}
var _items_by_category: Dictionary = {}
var validation_errors: Array[String] = []

static func load_default():
	var database = DatabaseScript.new()
	var file := FileAccess.open(MASTER_PATH, FileAccess.READ)
	if file == null:
		database.validation_errors.append("missing master: %s" % MASTER_PATH)
		return database
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		database.validation_errors.append("master root is not an object")
		return database
	database._load(parsed as Dictionary)
	return database

func _load(root: Dictionary) -> void:
	version = int(root.get("version", 0))
	if version <= 0:
		validation_errors.append("master version is invalid")
	var raw_conditions: Variant = root.get("conditions", {})
	if not raw_conditions is Dictionary:
		validation_errors.append("conditions is not an object")
		raw_conditions = {}
	for raw_id in (raw_conditions as Dictionary).keys():
		var condition_id := String(raw_id).strip_edges()
		var condition_value: Variant = (raw_conditions as Dictionary)[raw_id]
		if condition_id == "" or not condition_value is Dictionary:
			validation_errors.append("invalid condition: %s" % condition_id)
			continue
		conditions[condition_id] = (condition_value as Dictionary).duplicate(true)
	var raw_items: Variant = root.get("items", [])
	if not raw_items is Array:
		validation_errors.append("items is not an array")
		raw_items = []
	for raw_item in raw_items as Array:
		if not raw_item is Dictionary:
			validation_errors.append("item is not an object")
			continue
		var item := (raw_item as Dictionary).duplicate(true)
		var id := String(item.get("id", "")).strip_edges()
		var category := String(item.get("category", "")).strip_edges().to_lower()
		var condition_id := String(item.get("unlockConditionId", "")).strip_edges()
		var raw_price: Variant = item.get("pricePp", null)
		if id == "" or _items_by_id.has(id):
			validation_errors.append("duplicate or empty item id: %s" % id)
			continue
		if not VALID_CATEGORIES.has(category):
			validation_errors.append("invalid item category: %s/%s" % [id, category])
			continue
		if not _is_valid_price(raw_price):
			validation_errors.append("invalid item price: %s" % id)
			continue
		var price := int(raw_price)
		if not conditions.has(condition_id):
			validation_errors.append("unknown item condition: %s/%s" % [id, condition_id])
			continue
		item["id"] = id
		item["category"] = category
		item["pricePp"] = price
		item["unlockConditionId"] = condition_id
		item["presentationId"] = String(item.get("presentationId", id))
		item["sortOrder"] = int(item.get("sortOrder", items.size()))
		items.append(item)
		_items_by_id[id] = item
		var category_items: Array = _items_by_category.get(category, []) as Array
		category_items.append(item)
		_items_by_category[category] = category_items
	for category in VALID_CATEGORIES:
		var category_items: Array = _items_by_category.get(category, []) as Array
		category_items.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			return int(a.get("sortOrder", 0)) < int(b.get("sortOrder", 0))
		)
		_items_by_category[category] = category_items
	# Treat an otherwise well-formed master as valid only when all products and
	# conditions passed validation.  The shop can fail closed on bad content.
	is_valid = validation_errors.is_empty() and not items.is_empty() and not conditions.is_empty()

func _is_valid_price(value: Variant) -> bool:
	if not (value is int or value is float):
		return false
	var numeric := float(value)
	return is_finite(numeric) and numeric >= 0.0 and numeric <= 2147483647.0 and floorf(numeric) == numeric

func get_item(id: String) -> Dictionary:
	var value: Variant = _items_by_id.get(id.strip_edges(), {})
	return value.duplicate(true) as Dictionary if value is Dictionary else {}

func items_for_category(category: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value in _items_by_category.get(category.strip_edges().to_lower(), []) as Array:
		if value is Dictionary:
			result.append((value as Dictionary).duplicate(true))
	return result

func get_condition(id: String) -> Dictionary:
	var value: Variant = conditions.get(id.strip_edges(), {})
	return value.duplicate(true) as Dictionary if value is Dictionary else {}

func item_ids() -> Array[String]:
	var result: Array[String] = []
	for item in items:
		result.append(String(item.get("id", "")))
	return result

func condition_ids() -> Array[String]:
	var result: Array[String] = []
	for id in conditions.keys():
		result.append(String(id))
	return result

func total_price_pp() -> int:
	var total := 0
	for item in items:
		total += int(item.get("pricePp", 0))
	return total
