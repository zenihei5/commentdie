class_name CodexAuditSystem
extends RefCounted

## Read-only master audit used by the Codex debug tools.  It reports defects
## without making the game or the save loader fail.

const CodexPresentationSystemScript := preload("res://scripts/systems/codex_presentation_system.gd")
const EnemyCodexProfileSystemScript := preload("res://scripts/systems/enemy_codex_profile_system.gd")
const DrawDataSystemScript := preload("res://scripts/systems/draw_data_system.gd")
const CommentSystemScript := preload("res://scripts/systems/comment_system.gd")

const KNOWN_BEHAVIOR_TAGS: Array[String] = EnemyCodexProfileSystemScript.KNOWN_TAGS
const KNOWN_ATTACK_TYPES: Array[String] = ["contact", "ranged", "projectile", "charge", "summon", "area", "special"]

static func audit(raw_masters: Dictionary, enabled_masters: Dictionary, disabled_ids: Dictionary, sources: Dictionary = {}) -> Dictionary:
	var warnings: Array[String] = []
	var counts: Dictionary = {}
	var characters := _audit_characters(raw_masters.get("characters", []), enabled_masters.get("characters", []), warnings)
	var weapons := _audit_weapons(raw_masters.get("weapons", []), enabled_masters.get("weapons", []), raw_masters.get("accessories", []), enabled_masters.get("accessories", []), warnings)
	var accessories := _audit_accessories(raw_masters.get("accessories", []), enabled_masters.get("accessories", []), warnings)
	var enemies := _audit_enemies(raw_masters.get("enemies", []), enabled_masters.get("enemies", []), warnings)
	var enemy_catalog := EnemyCodexProfileSystemScript.build_catalog(raw_masters.get("enemies", []) as Array, sources)
	var enemy_cohorts: Dictionary = enemy_catalog.get("cohorts", {}) as Dictionary
	var normal_cohort: Dictionary = enemy_cohorts.get("normal", {}) as Dictionary
	var boss_cohort: Dictionary = enemy_cohorts.get("boss", {}) as Dictionary
	enemies["bossRaw"] = int(enemy_catalog.get("rawBossCount", 0))
	enemies["bossEnabled"] = int(enemy_catalog.get("enabledBossCount", 0))
	enemies["normalEnabled"] = int(enemy_catalog.get("normalEnabledCount", 0))
	enemies["normalMobile"] = int(enemy_catalog.get("normalMobileCount", 0))
	enemies["normalFixed"] = int(enemy_catalog.get("normalFixedCount", 0))
	enemies["normalHpMedian"] = normal_cohort.get("hpMedian", 0.0)
	enemies["normalSpeedMedian"] = normal_cohort.get("speedMedian", 0.0)
	enemies["bossHpMedian"] = boss_cohort.get("hpMedian", 0.0)
	enemies["bossSpeedMedian"] = boss_cohort.get("speedMedian", 0.0)
	var comments := _audit_comments(raw_masters.get("comments", []), enabled_masters.get("comments", []), warnings)
	var comment_boundary := _audit_relay_comment_boundary(raw_masters.get("comments", []), warnings)
	counts["characters"] = characters
	counts["weapons"] = weapons
	counts["accessories"] = accessories
	counts["enemies"] = enemies
	counts["comments"] = comments
	var collection_total := int(characters.get("enabled", 0)) + int(weapons.get("enabled", 0)) + int(accessories.get("enabled", 0)) + int(enemies.get("enabled", 0))
	return {
		"warnings": warnings.duplicate(true),
		"counts": counts.duplicate(true),
		"collectionTotal": collection_total,
		"valid": warnings.is_empty(),
		"enemyProfileCatalog": enemy_catalog.duplicate(true),
		"commentBoundary": comment_boundary.duplicate(true)
	}

static func _audit_characters(raw_value: Variant, enabled_value: Variant, warnings: Array[String]) -> Dictionary:
	var raw := _dict_array(raw_value)
	var enabled := _dict_array(enabled_value)
	var ids: Dictionary = {}
	for row in raw:
		_check_duplicate_id(row, ids, "characters", warnings)
		if String(row.get("displayName", "")).strip_edges() == "":
			warnings.append("characters missing displayName: %s" % String(row.get("id", "")))
		var profile: Variant = row.get("codexProfile", {})
		if profile != null and not profile is Dictionary:
			warnings.append("characters codexProfile is not a Dictionary: %s" % String(row.get("id", "")))
	return {"raw": raw.size(), "enabled": enabled.size(), "disabled": maxi(0, raw.size() - enabled.size())}

static func _audit_weapons(raw_value: Variant, enabled_value: Variant, accessories_raw_value: Variant, accessories_enabled_value: Variant, warnings: Array[String]) -> Dictionary:
	var raw := _dict_array(raw_value)
	var enabled := _dict_array(enabled_value)
	var ids: Dictionary = {}
	var enabled_ids: Dictionary = {}
	var referenced_evolved_ids: Dictionary = {}
	var disabled_ids: Array[String] = []
	for row in raw:
		_check_duplicate_id(row, ids, "weapons", warnings)
		if bool(row.get("codexEnabled", true)):
			enabled_ids[String(row.get("id", ""))] = true
			_audit_declared_stats(row, "weapons", warnings)
		else:
			disabled_ids.append(String(row.get("id", "")))
	if disabled_ids.size() != 1 or not disabled_ids.has("phase1_null_weapon"):
		warnings.append("weapons disabled set is not phase1_null_weapon")
	var accessory_ids: Dictionary = {}
	for row in _dict_array(accessories_enabled_value):
		accessory_ids[String(row.get("id", ""))] = true
	for row in enabled:
		if bool(row.get("evolutionEnabled", false)):
			var evolution: Variant = row.get("evolution", {})
			if not evolution is Dictionary:
				warnings.append("weapons missing evolution dictionary: %s" % String(row.get("id", "")))
				continue
			var evolved_id := String((evolution as Dictionary).get("evolvedWeaponId", ""))
			if evolved_id != "":
				referenced_evolved_ids[evolved_id] = true
			if evolved_id == "" or not enabled_ids.has(evolved_id):
				warnings.append("weapons invalid evolution target: %s -> %s" % [String(row.get("id", "")), evolved_id])
			for requirement_value in (evolution as Dictionary).get("additionalRequirements", []) as Array:
				if requirement_value is Dictionary and String((requirement_value as Dictionary).get("type", "")) == "accessory":
					var accessory_id := String((requirement_value as Dictionary).get("id", ""))
					if not accessory_ids.has(accessory_id):
						warnings.append("weapons invalid accessory requirement: %s -> %s" % [String(row.get("id", "")), accessory_id])
	for row in enabled:
		if bool(row.get("isEvolved", false)) and not referenced_evolved_ids.has(String(row.get("id", ""))):
			warnings.append("weapons evolved item is not referenced by an enabled recipe: %s" % String(row.get("id", "")))
	return {"raw": raw.size(), "enabled": enabled.size(), "disabled": maxi(0, raw.size() - enabled.size())}

static func _audit_accessories(raw_value: Variant, enabled_value: Variant, warnings: Array[String]) -> Dictionary:
	var raw := _dict_array(raw_value)
	var enabled := _dict_array(enabled_value)
	var ids: Dictionary = {}
	for row in raw:
		_check_duplicate_id(row, ids, "accessories", warnings)
		if bool(row.get("codexEnabled", true)):
			if int(row.get("maxLevel", row.get("maxLv", 0))) < 1:
				warnings.append("accessories invalid maxLevel: %s" % String(row.get("id", "")))
			_audit_declared_stats(row, "accessories", warnings)
	return {"raw": raw.size(), "enabled": enabled.size(), "disabled": maxi(0, raw.size() - enabled.size())}

static func _audit_enemies(raw_value: Variant, enabled_value: Variant, warnings: Array[String]) -> Dictionary:
	var raw := _dict_array(raw_value)
	var enabled := _dict_array(enabled_value)
	var ids: Dictionary = {}
	var orders: Dictionary = {}
	var relay_ids: Array[String] = []
	for row in raw:
		var id := String(row.get("id", "")).strip_edges()
		_check_duplicate_id(row, ids, "enemies", warnings)
		var order_key := str(row.get("order", ""))
		if orders.has(order_key):
			warnings.append("enemies duplicate order: %s" % order_key)
		orders[order_key] = true
		if not bool(row.get("codexEnabled", true)):
			continue
		var order_value: Variant = row.get("order", null)
		if not (order_value is int or order_value is float) or float(order_value) < 0.0:
			warnings.append("enemies invalid order: %s" % id)
		if String(row.get("displayName", "")).strip_edges() == "":
			warnings.append("enemies missing displayName: %s" % id)
		var codex: Variant = row.get("codex", {})
		if not codex is Dictionary:
			warnings.append("enemies codex is not a Dictionary: %s" % id)
		else:
			for key in ["description", "strategy", "flavor"]:
				if not ((codex as Dictionary).get(key, "") is String):
					warnings.append("enemies codex.%s is not String: %s" % [key, id])
			for combat_key in ["hp", "speed", "moveSpeed", "damage", "contactDamage", "attackInterval", "attackRange"]:
				if (codex as Dictionary).has(combat_key):
					warnings.append("enemies codex contains combat value: %s/%s" % [id, combat_key])
			for array_key in ["autoTagExcludes", "attackTypeOverride", "mainAttacks", "summonIds", "specialEffects"]:
				var array_value: Variant = (codex as Dictionary).get(array_key, [])
				if not array_value is Array:
					warnings.append("enemies codex.%s is not Array: %s" % [array_key, id])
			if (codex as Dictionary).get("attackTypeOverride", []) is Array:
				for attack_type_value in (codex as Dictionary).get("attackTypeOverride", []) as Array:
					if not KNOWN_ATTACK_TYPES.has(String(attack_type_value)):
						warnings.append("enemies unknown attackTypeOverride: %s/%s" % [id, String(attack_type_value)])
		var behavior: Variant = row.get("behaviorTags", [])
		if codex is Dictionary:
			var codex_behavior: Variant = (codex as Dictionary).get("behaviorTags", null)
			behavior = codex_behavior if codex_behavior is Array and not (codex_behavior as Array).is_empty() else behavior
		if not behavior is Array:
			warnings.append("enemies behaviorTags is not Array: %s" % id)
		else:
			var seen_tags: Dictionary = {}
			for tag_value in behavior as Array:
				var tag := String(tag_value)
				if not KNOWN_BEHAVIOR_TAGS.has(tag):
					warnings.append("enemies unknown behaviorTag: %s/%s" % [id, tag])
				if seen_tags.has(tag):
					warnings.append("enemies duplicate behaviorTag: %s/%s" % [id, tag])
				seen_tags[tag] = true
		var image_path := DrawDataSystemScript.enemy_sprite_path(id)
		if image_path != "" and not ResourceLoader.exists(image_path):
			warnings.append("enemies missing image resource: %s" % id)
		if bool(row.get("relayBoss", false)):
			relay_ids.append(id)
	if raw.size() != 44:
		warnings.append("enemies raw count is %d (expected current 44)" % raw.size())
	if enabled.size() != 42:
		warnings.append("enemies enabled count is %d (expected current 42)" % enabled.size())
	if relay_ids.size() == 1 and String(enabled.back().get("id", "")) != relay_ids[0]:
		warnings.append("enemies relay boss is not last in master order")
	var disabled_enemy_ids: Array[String] = []
	for row in raw:
		if not bool(row.get("codexEnabled", true)):
			disabled_enemy_ids.append(String(row.get("id", "")))
	if disabled_enemy_ids.size() != 2 or not disabled_enemy_ids.has("undo_ghost") or not disabled_enemy_ids.has("boss_super_long_comment"):
		warnings.append("enemies disabled set is not undo_ghost/boss_super_long_comment")
	return {"raw": raw.size(), "enabled": enabled.size(), "disabled": maxi(0, raw.size() - enabled.size()), "relayBossIds": relay_ids}

static func _audit_comments(raw_value: Variant, enabled_value: Variant, warnings: Array[String]) -> Dictionary:
	var raw := _dict_array(raw_value)
	var enabled := _dict_array(enabled_value)
	var ids: Dictionary = {}
	for row in raw:
		_check_duplicate_id(row, ids, "comments", warnings)
		if bool(row.get("codexEnabled", true)):
			if String(row.get("displayName", "")).strip_edges() == "":
				warnings.append("comments missing displayName: %s" % String(row.get("id", "")))
			if String(row.get("description", "")).strip_edges() == "":
				warnings.append("comments missing description: %s" % String(row.get("id", "")))
	var reachability := _comment_reachability(enabled)
	var relay_reachability := _relay_comment_reachability(enabled)
	for row in enabled:
		var id := String(row.get("id", ""))
		if id != "" and not bool(reachability.get(id, false)):
			warnings.append("comments has no normal/hard frame reachability: %s" % id)
	var unreachable_ids: Array[String] = []
	for id in reachability.keys():
		if not bool(reachability[id]):
			unreachable_ids.append(String(id))
	var reachable_count := reachability.size() - unreachable_ids.size()
	return {
		"raw": raw.size(),
		"enabled": enabled.size(),
		"disabled": maxi(0, raw.size() - enabled.size()),
		"reachable": reachable_count,
		"unreachableIds": unreachable_ids,
		"relayReachable": relay_reachability.size() - _unreachable_ids(relay_reachability).size(),
		"relayUnreachableIds": _unreachable_ids(relay_reachability)
	}

static func _comment_reachability(comments: Array[Dictionary]) -> Dictionary:
	var reachability: Dictionary = {}
	var frames_value: Variant = _read_json("res://data/stream_frames.json")
	if not frames_value is Array:
		return reachability
	for row in comments:
		var id := String(row.get("id", ""))
		if id != "":
			reachability[id] = false
	for frame_value in frames_value as Array:
		if not frame_value is Dictionary:
			continue
		var frame := frame_value as Dictionary
		for difficulty_id in ["normal", "hard"]:
			for candidate_value in CommentSystemScript.comments_allowed_for_frame(frame, comments, difficulty_id):
				if candidate_value is Dictionary:
					var candidate_id := String((candidate_value as Dictionary).get("id", ""))
					if reachability.has(candidate_id):
						reachability[candidate_id] = true
	return reachability

static func _relay_comment_reachability(comments: Array[Dictionary]) -> Dictionary:
	var reachability: Dictionary = {}
	var relay_value: Variant = _read_json("res://data/relay_mode.json")
	if not relay_value is Dictionary:
		return reachability
	var segments: Variant = (relay_value as Dictionary).get("segments", {})
	if not segments is Dictionary:
		return reachability
	for row in comments:
		var id := String(row.get("id", ""))
		if id != "":
			reachability[id] = false
	for segment_id_value in (segments as Dictionary).keys():
		var segment_id := String(segment_id_value)
		var segment: Dictionary = (segments as Dictionary).get(segment_id, {}) as Dictionary
		var pool := String(segment.get("instructionPool", "")).strip_edges()
		if pool == "":
			continue
		var frame := {"id": segment_id, "commentPoolTags": ["default", pool]}
		for difficulty_id in ["normal", "hard"]:
			for candidate_value in CommentSystemScript.comments_allowed_for_frame(frame, comments, difficulty_id):
				if candidate_value is Dictionary:
					var candidate_id := String((candidate_value as Dictionary).get("id", ""))
					if reachability.has(candidate_id):
						reachability[candidate_id] = true
	return reachability

static func _unreachable_ids(reachability: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for id_value in reachability.keys():
		if not bool(reachability[id_value]):
			result.append(String(id_value))
	result.sort()
	return result

static func _audit_relay_comment_boundary(standard_value: Variant, warnings: Array[String]) -> Dictionary:
	var standard_ids: Dictionary = {}
	for row in _dict_array(standard_value):
		var id := String(row.get("id", ""))
		if id != "":
			standard_ids[id] = true
	var relay_value: Variant = _read_json("res://data/relay_mode.json")
	var private_ids: Array[String] = []
	if relay_value is Dictionary:
		var boss: Dictionary = (relay_value as Dictionary).get("boss", {}) as Dictionary
		for comment_value in boss.get("comments", []) as Array:
			if not comment_value is Dictionary:
				continue
			var id := String((comment_value as Dictionary).get("id", ""))
			if id == "":
				continue
			if standard_ids.has(id):
				warnings.append("relay private comment overlaps standard comment: %s" % id)
			elif not private_ids.has(id):
				private_ids.append(id)
	return {
		"mechanic": "relay_boss_private_choice",
		"standardCommentCount": standard_ids.size(),
		"relayPrivateCount": private_ids.size(),
		"relayPrivateIds": private_ids
	}

static func _audit_declared_stats(row: Dictionary, category: String, warnings: Array[String]) -> void:
	var stats: Variant = row.get("codexStats", [])
	if not stats is Array or (stats as Array).is_empty():
		warnings.append("%s missing codexStats: %s" % [category, String(row.get("id", ""))])
		return
	var seen: Dictionary = {}
	for stat_value in stats as Array:
		var stat := String(stat_value)
		if seen.has(stat):
			warnings.append("%s duplicate codexStats: %s/%s" % [category, String(row.get("id", "")), stat])
		seen[stat] = true
		if not CodexPresentationSystemScript.is_known_stat_key(stat):
			warnings.append("%s unknown codexStats: %s/%s" % [category, String(row.get("id", "")), stat])

static func _check_duplicate_id(row: Dictionary, ids: Dictionary, category: String, warnings: Array[String]) -> void:
	var id := String(row.get("id", "")).strip_edges()
	if id == "":
		warnings.append("%s missing id" % category)
	elif ids.has(id):
		warnings.append("%s duplicate id: %s" % [category, id])
	ids[id] = true

static func _read_json(path: String) -> Variant:
	if not ResourceLoader.exists(path):
		return null
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	return parsed

static func _dict_array(value: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if value is Array:
		for item in value as Array:
			if item is Dictionary:
				result.append(item as Dictionary)
	return result
