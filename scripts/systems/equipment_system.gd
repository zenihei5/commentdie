class_name EquipmentSystem
extends RefCounted

const MAX_WEAPONS := 5
const MAX_ACCESSORIES := 5

static func initial_weapons(initial_weapon_id: String) -> Array:
	return [{"id": initial_weapon_id, "level": 1}]

static func empty_accessories() -> Array:
	return []

static func equipment_type(item: Dictionary) -> String:
	return String(item.get("equipmentType", "instant"))

static func is_weapon(item: Dictionary) -> bool:
	return equipment_type(item) == "weapon"

static func is_accessory(item: Dictionary) -> bool:
	return equipment_type(item) == "accessory"

static func is_instant(item: Dictionary) -> bool:
	return equipment_type(item) == "instant"

static func find_entry(items: Array, id: String) -> Dictionary:
	for entry_item in items:
		var entry: Dictionary = entry_item as Dictionary
		if String(entry.get("id", "")) == id:
			return entry
	return {}

static func level(items: Array, id: String) -> int:
	var entry: Dictionary = find_entry(items, id)
	if entry.is_empty():
		return 0
	return int(entry.get("level", 0))

static func level_for_target(target: Node, id: String) -> int:
	var weapons: Array = target.get("player_weapons") as Array
	var accessories: Array = target.get("player_accessories") as Array
	return maxi(level(weapons, id), level(accessories, id))

static func can_offer(target: Node, item: Dictionary, gift_time: float) -> bool:
	if gift_time < float(item.get("minTime", 0.0)):
		return false
	var item_type: String = equipment_type(item)
	if item_type == "instant":
		return true
	var id: String = String(item.get("id", ""))
	var max_level: int = int(item.get("maxLevel", 1))
	var items: Array = target.get("player_accessories") as Array
	if item_type == "weapon":
		items = target.get("player_weapons") as Array
	var current_level: int = level(items, id)
	if current_level > 0:
		return current_level < max_level
	var max_slots: int = MAX_WEAPONS if item_type == "weapon" else MAX_ACCESSORIES
	return items.size() < max_slots

static func category_label_for_card(item: Dictionary, current_level: int) -> String:
	var item_type: String = equipment_type(item)
	if item_type == "weapon":
		return "武器強化" if current_level > 0 else "武器"
	if item_type == "accessory":
		return "アクセサリ強化" if current_level > 0 else "アクセサリ"
	return "即時"

static func display_name_for_card(item: Dictionary, current_level: int) -> String:
	if current_level <= 0 or is_instant(item):
		return String(item.get("displayName", "ギフト"))
	return "%s Lv%d → Lv%d" % [
		String(item.get("displayName", "装備")),
		current_level,
		current_level + 1
	]

static func add_or_level(items: Array, id: String, max_level: int) -> Dictionary:
	for i in range(items.size()):
		var entry: Dictionary = items[i] as Dictionary
		if String(entry.get("id", "")) == id:
			entry["level"] = mini(max_level, int(entry.get("level", 1)) + 1)
			items[i] = entry
			return entry
	var new_entry: Dictionary = {"id": id, "level": 1}
	items.append(new_entry)
	return new_entry

static func weapon_names(weapons: Array, weapon_data: Array) -> Array[String]:
	var names: Array[String] = []
	for entry_item in weapons:
		var entry: Dictionary = entry_item as Dictionary
		var weapon: Dictionary = WeaponSystem.find_weapon(weapon_data, String(entry.get("id", "")), {})
		names.append("%s Lv%d" % [String(weapon.get("displayName", entry.get("id", ""))), int(entry.get("level", 1))])
	return names

static func accessory_names(accessories: Array, gift_data: Array) -> Array[String]:
	var names: Array[String] = []
	for entry_item in accessories:
		var entry: Dictionary = entry_item as Dictionary
		var data: Dictionary = _find_data(gift_data, String(entry.get("id", "")))
		names.append("%s Lv%d" % [String(data.get("displayName", entry.get("id", ""))), int(entry.get("level", 1))])
	return names

static func _find_data(data: Array, id: String) -> Dictionary:
	for item in data:
		var entry: Dictionary = item as Dictionary
		if String(entry.get("id", "")) == id:
			return entry
	return {}

static func slot_summary(names: Array[String], max_slots: int) -> String:
	var items: Array[String] = []
	for name in names:
		items.append(name)
	while items.size() < max_slots:
		items.append("空き")
	return " / ".join(items)
