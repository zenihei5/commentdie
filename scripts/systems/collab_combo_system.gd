extends RefCounted

const REGISTRY_PATH := "res://data/collab_combos.json"
static var _registry_cache: Dictionary = {}

const REQUIRED_EFFECT_KINDS := [
	"collab_module_defense",
	"collab_module_gather",
	"collab_module_area",
	"collab_module_firepower",
	"collab_module_followup",
	"collab_module_finisher",
	"collab_composite_link",
	"collab_composite_finish",
	"collab_senior_guard_live",
	"collab_senior_moderate_finish",
	"collab_senior_buzz_fishing"
]

const REQUIRED_CROSS_LINK_STYLES := [
	"shield_anvil",
	"rhythm_ban",
	"thumbnail_smash",
	"star_reflector",
	"star_stage",
	"viral_thumbnail",
	"moderated_comments",
	"audience_ring",
	"comment_curation"
]

static func required_effect_kinds() -> Array:
	return REQUIRED_EFFECT_KINDS.duplicate()

static func required_cross_link_styles() -> Array:
	return REQUIRED_CROSS_LINK_STYLES.duplicate()

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

static func cross_pair_styles(data: Dictionary, pair_key_filter: String = "") -> Dictionary:
	var styles: Dictionary = data.get("crossPairStyles", {}) as Dictionary
	if pair_key_filter == "":
		return styles.duplicate(true)
	var style: Dictionary = styles.get(pair_key_filter, {}) as Dictionary
	return style.duplicate(true)

static func link_style_for_pair(data: Dictionary, pair_key_value: String) -> String:
	var style: Dictionary = cross_pair_styles(data, pair_key_value)
	return String(style.get("linkStyle", ""))

static func se_profile_events(data: Dictionary, profile: String) -> Array:
	if profile == "":
		return []
	var profiles: Dictionary = data.get("seProfiles", {}) as Dictionary
	var profile_data: Dictionary = profiles.get(profile, {}) as Dictionary
	return (profile_data.get("events", []) as Array).duplicate(true)

static func se_step_after_elapsed(events: Array, elapsed: float, previous_step: int = 0) -> int:
	var step := clampi(previous_step, 0, events.size())
	var safe_elapsed := maxf(0.0, elapsed)
	while step < events.size():
		var event: Dictionary = events[step] as Dictionary
		if safe_elapsed + 0.0001 < float(event.get("at", 0.0)):
			break
		step += 1
	return step

static func visual_elements_for_effect(effect_kind: String, progress: float, textures_available: bool = true) -> Array:
	# This is a deterministic preview/test description.  Runtime drawing uses
	# the same effect kind and activation snapshot, but never generates random
	# positions while rendering.
	var t := clampf(progress, 0.0, 1.0)
	var fallback := not textures_available
	match effect_kind:
		"collab_module_defense":
			return [{"type": "hex_panel", "index": 0, "progress": t, "fallback": fallback}, {"type": "scanline", "progress": t}]
		"collab_module_gather":
			return [{"type": "thumbnail_corners", "progress": t, "fallback": fallback}, {"type": "fishing_lines", "count": 5, "progress": t}]
		"collab_module_area":
			return [{"type": "comment_badges", "count": 12, "progress": t}, {"type": "ring", "index": 0, "progress": t}]
		"collab_module_firepower":
			return [{"type": "star_rays", "count": 8, "progress": t}, {"type": "impact_pentagon", "progress": t}]
		"collab_module_followup":
			return [{"type": "beat_slash", "beat": mini(2, int(floor(t * 3.0))), "progress": t}, {"type": "confetti", "count": 12, "progress": t}]
		"collab_module_finisher":
			return [{"type": "hammer", "afterimages": 3, "progress": t, "fallback": fallback}, {"type": "cracks", "progress": t}]
		"collab_composite_link":
			return [{"type": "double_helix", "turns": 2, "progress": t}, {"type": "pair_style_motif", "progress": t}]
		"collab_composite_finish":
			return [{"type": "sync_star", "progress": t}, {"type": "alternating_ring", "progress": t}, {"type": "white_lines", "progress": t}]
		"collab_senior_guard_live":
			return [{"type": "open_shield_panels", "progress": t}, {"type": "three_beat_fan", "progress": t}, {"type": "guard_wave", "progress": t}]
		"collab_senior_moderate_finish":
			return [{"type": "thumbnail_frame", "progress": t}, {"type": "shield_scanline", "progress": t}, {"type": "compress_ring", "progress": t}]
		"collab_senior_buzz_fishing":
			return [{"type": "thumbnail_lure", "progress": t, "fallback": fallback}, {"type": "six_fishing_lines", "progress": t}, {"type": "rhythm_firework", "progress": t}]
	return []

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
		resolved["effectKind"] = String(resolved.get("effectKind", ""))
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
		module_copy["effectKind"] = String(module_copy.get("effectKind", "collab_module_%s" % String(module_copy.get("kind", "support"))))
		module_copy["visualDuration"] = float(module_copy.get("visualDuration", module_copy.get("duration", 0.28)))
		modules.append(module_copy)
	var finisher: Dictionary = source.get("commonFinisher", {}) as Dictionary
	var finisher_copy := finisher.duplicate(true)
	finisher_copy["id"] = String(finisher_copy.get("id", "syncro_burst"))
	finisher_copy["kind"] = "common_finisher"
	finisher_copy["effectKind"] = String(finisher_copy.get("effectKind", "collab_composite_finish"))
	finisher_copy["visualDuration"] = float(finisher_copy.get("visualDuration", finisher_copy.get("duration", 0.34)))
	modules.append(finisher_copy)
	var different_units := String(first.get("unitId", "")) != String(second.get("unitId", ""))
	var cross_name := String(source.get("crossUnitDisplayName", "共通合成技・シンクロバースト"))
	var link_style := link_style_for_pair(source, key)
	return {
		"pairKey": key,
		"comboId": "cross_unit_%s" % key.replace("+", "_"),
		"kind": "cross_unit" if different_units else "composite",
		"displayName": cross_name,
		"handler": "composite_modules",
		"linkStyle": link_style,
		"crossPairStyle": cross_pair_styles(source, key),
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
	var dedicated_count := 0
	var composite_count := 0
	var effect_kinds: Dictionary = {}
	var link_styles: Dictionary = {}
	var module_data: Dictionary = source.get("modules", {}) as Dictionary
	var common_finisher: Dictionary = source.get("commonFinisher", {}) as Dictionary
	for module_id in module_data:
		var module: Dictionary = module_data[module_id] as Dictionary
		if String(module.get("effectKind", "")) == "":
			errors.append("modules.%s.effectKind" % String(module_id))
		if float(module.get("visualDuration", module.get("duration", 0.0))) <= 0.0:
			errors.append("modules.%s.duration" % String(module_id))
	if String(common_finisher.get("effectKind", "")) == "":
		errors.append("commonFinisher.effectKind")
	if float(common_finisher.get("visualDuration", common_finisher.get("duration", 0.0))) <= 0.0:
		errors.append("commonFinisher.duration")
	for first_index in range(ids.size()):
		for second_index in range(first_index + 1, ids.size()):
			count += 1
			var key := pair_key(String(ids[first_index]), String(ids[second_index]))
			var forward := resolve_pair(String(ids[first_index]), String(ids[second_index]), characters, source)
			var reverse := resolve_pair(String(ids[second_index]), String(ids[first_index]), characters, source)
			if forward.is_empty() or reverse.is_empty() or String(forward.get("pairKey", "")) != key or String(reverse.get("pairKey", "")) != key:
				errors.append(key)
				continue
			var resolved: Dictionary = forward as Dictionary
			if String(resolved.get("kind", "")) == "dedicated":
				dedicated_count += 1
				var dedicated_effect_kind := String(resolved.get("effectKind", ""))
				if dedicated_effect_kind == "":
					errors.append("%s.effectKind" % key)
				else:
					effect_kinds[dedicated_effect_kind] = true
				if float(resolved.get("duration", 0.0)) <= 0.0 or float(resolved.get("visualDuration", resolved.get("duration", 0.0))) <= 0.0:
					errors.append("%s.duration" % key)
			else:
				composite_count += 1
				var style := String(resolved.get("linkStyle", ""))
				if style == "":
					errors.append("%s.linkStyle" % key)
				else:
					link_styles[style] = true
					effect_kinds["collab_composite_link"] = true
				for module_item in resolved.get("orderedModules", []) as Array:
					var module: Dictionary = module_item as Dictionary
					var effect_kind := String(module.get("effectKind", ""))
					if effect_kind == "":
						errors.append("%s.module.effectKind" % key)
					else:
						effect_kinds[effect_kind] = true
	return {
		"valid": errors.is_empty(),
		"pairCount": count,
		"dedicatedCount": dedicated_count,
		"compositeCount": composite_count,
		"effectKinds": effect_kinds.keys(),
		"linkStyles": link_styles.keys(),
		"errors": errors
	}

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
