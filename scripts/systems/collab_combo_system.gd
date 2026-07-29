extends RefCounted

const REGISTRY_PATH := "res://data/collab_combos.json"
static var _registry_cache: Dictionary = {}

static func pair_key(first_id: String, second_id: String) -> String:
	var ids := [first_id, second_id]
	ids.sort()
	return "%s+%s" % [String(ids[0]), String(ids[1])]

static func registry(path: String = REGISTRY_PATH) -> Dictionary:
	if not _registry_cache.is_empty() and path == REGISTRY_PATH:
		return _registry_cache
	if not FileAccess.file_exists(path):
		return {"modules": {}, "dedicatedPairs": []}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"modules": {}, "dedicatedPairs": []}
	var parsed = JSON.parse_string(file.get_as_text())
	var result: Dictionary = {"modules": {}, "dedicatedPairs": []}
	if parsed is Dictionary:
		result = parsed
	if path == REGISTRY_PATH:
		_registry_cache = result
	return result

static func dedicated_pair_map(data: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for item in data.get("dedicatedPairs", []) as Array:
		var entry: Dictionary = item as Dictionary
		var key := String(entry.get("pairKey", ""))
		if key == "":
			key = pair_key(String(entry.get("firstId", "")), String(entry.get("secondId", "")))
		if key != "+":
			result[key] = entry.duplicate(true)
	return result

static func _character_for_id(characters: Array, id: String) -> Dictionary:
	for item in characters:
		var character: Dictionary = item as Dictionary
		if String(character.get("id", "")) == id:
			return character
	return {}

static func resolve_pair(first_id: String, second_id: String, characters: Array, data: Dictionary = {}) -> Dictionary:
	var key := pair_key(first_id, second_id)
	var source: Dictionary = data
	if source.is_empty():
		source = registry()
	var dedicated_map := dedicated_pair_map(source)
	if dedicated_map.has(key):
		var dedicated: Dictionary = dedicated_map[key] as Dictionary
		var resolved := dedicated.duplicate(true)
		resolved["pairKey"] = key
		resolved["firstId"] = first_id
		resolved["secondId"] = second_id
		return resolved
	var first := _character_for_id(characters, first_id)
	var second := _character_for_id(characters, second_id)
	if first.is_empty() or second.is_empty():
		return {}
	var ordered: Array = [first, second]
	if int((ordered[0] as Dictionary).get("comboExecutionPriority", 999)) > int((ordered[1] as Dictionary).get("comboExecutionPriority", 999)):
		var swap: Dictionary = ordered[0] as Dictionary
		ordered[0] = ordered[1]
		ordered[1] = swap
	var modules: Array = []
	var module_data: Dictionary = source.get("modules", {}) as Dictionary
	for item in ordered:
		var character: Dictionary = item as Dictionary
		var module_id := String(character.get("comboModuleId", "generic_support"))
		var module: Dictionary = module_data.get(module_id, {}) as Dictionary
		var module_copy := module.duplicate(true)
		module_copy["id"] = module_id
		module_copy["characterId"] = String(character.get("id", ""))
		module_copy["priority"] = int(character.get("comboExecutionPriority", module_copy.get("priority", 999)))
		modules.append(module_copy)
	var finisher: Dictionary = source.get("commonFinisher", {}) as Dictionary
	var finisher_copy := finisher.duplicate(true)
	finisher_copy["id"] = String(finisher_copy.get("id", "syncro_burst"))
	finisher_copy["kind"] = "common_finisher"
	modules.append(finisher_copy)
	var different_units := String(first.get("unitId", "")) != String(second.get("unitId", ""))
	var cross_name := String(source.get("crossUnitDisplayName", "共通合成技・シンクロバースト"))
	return {
		"pairKey": key,
		"comboId": "cross_unit_%s" % key.replace("+", "_"),
		"kind": "cross_unit" if different_units else "composite",
		"displayName": cross_name,
		"handler": "composite_modules",
		"orderedModules": modules
	}

static func validate_registry(characters: Array, data: Dictionary = {}) -> Dictionary:
	var source: Dictionary = data
	if source.is_empty():
		source = registry()
	var ids: Array = []
	for item in characters:
		ids.append(String((item as Dictionary).get("id", "")))
	var errors: Array = []
	var count := 0
	for first_index in range(ids.size()):
		for second_index in range(first_index + 1, ids.size()):
			count += 1
			var key := pair_key(String(ids[first_index]), String(ids[second_index]))
			var forward := resolve_pair(String(ids[first_index]), String(ids[second_index]), characters, source)
			var reverse := resolve_pair(String(ids[second_index]), String(ids[first_index]), characters, source)
			if forward.is_empty() or reverse.is_empty() or String(forward.get("pairKey", "")) != key or String(reverse.get("pairKey", "")) != key:
				errors.append(key)
	return {"valid": errors.is_empty(), "pairCount": count, "errors": errors}

static func partner_candidates(characters: Array, current_id: String, unlocked_ids: Array = []) -> Array:
	var unlocked: Dictionary = {}
	for value in unlocked_ids:
		unlocked[String(value)] = true
	var result: Array = []
	for item in characters:
		var character: Dictionary = item as Dictionary
		var id := String(character.get("id", ""))
		if id == "" or id == current_id or not bool(character.get("collabPartnerEnabled", true)):
			continue
		var always_unlocked := id in ["ban_chan", "superchat_chan", "maro_chan"]
		if not always_unlocked and not bool(character.get("isUnlocked", false)) and not unlocked.has(id):
			continue
		result.append(character)
		if result.size() >= 5:
			break
	return result

static func grid_move(index: int, direction: Vector2i, count: int, columns: int = 3) -> int:
	if count <= 0:
		return -1
	var current := clampi(index, 0, count - 1)
	if direction.x != 0:
		return clampi(current + direction.x, 0, count - 1)
	var row := current / columns
	var col := current % columns
	var next := (row + direction.y) * columns + col
	return clampi(next, 0, count - 1)
