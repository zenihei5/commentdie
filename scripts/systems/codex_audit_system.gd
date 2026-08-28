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
	var enemies := _audit_enemies(raw_masters.get("enemies", []), enabled_masters.get("enemies", []), warnings, sources)
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
		_audit_item_lore(row, "weapons", ["origin", "usage", "rumor"] if not bool(row.get("isEvolved", false)) else ["evolution_trigger", "evolution_from", "reputation"], warnings)
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
	for row in enabled:
		_audit_item_lore(row, "accessories", ["usage", "popularity", "streamer_memo"], warnings)
	return {"raw": raw.size(), "enabled": enabled.size(), "disabled": maxi(0, raw.size() - enabled.size())}

static func _audit_item_lore(row: Dictionary, category: String, expected_ids: Array, warnings: Array[String]) -> void:
	var id := String(row.get("id", ""))
	var expected_titles: Dictionary = {}
	if category == "accessories":
		expected_titles = {
			"usage": "使い道",
			"popularity": "人気の理由",
			"streamer_memo": "配信者メモ",
		}
	elif bool(row.get("isEvolved", false)):
		expected_titles = {
			"evolution_trigger": "変化のきっかけ",
			"evolution_from": "進化前",
			"reputation": "配信界隈の評判",
		}
	else:
		expected_titles = {
			"origin": "由来",
			"usage": "扱われ方",
			"rumor": "うわさ",
		}
	var lore_value: Variant = row.get("codexLore", null)
	if not lore_value is Dictionary:
		warnings.append("%s missing codexLore: %s" % [category, id])
		return
	var lore := lore_value as Dictionary
	var cards_value: Variant = lore.get("cards", [])
	if not cards_value is Array or (cards_value as Array).size() != 3:
		warnings.append("%s codexLore cards must have 3 entries: %s" % [category, id])
		return
	var seen_ids: Dictionary = {}
	var spans: Array[int] = []
	for card_index in range((cards_value as Array).size()):
		var card_value: Variant = (cards_value as Array)[card_index]
		if not card_value is Dictionary:
			warnings.append("%s codexLore card is not Dictionary: %s/%d" % [category, id, card_index])
			continue
		var card := card_value as Dictionary
		var card_id := String(card.get("id", ""))
		var title := String(card.get("title", "")).strip_edges()
		var text := String(card.get("text", "")).strip_edges()
		var raw_span: Variant = card.get("span", 1)
		var span := int(raw_span) if raw_span is int or raw_span is float else 0
		if not expected_ids.has(card_id):
			warnings.append("%s unknown codexLore card id: %s/%s" % [category, id, card_id])
		if seen_ids.has(card_id):
			warnings.append("%s duplicate codexLore card id: %s/%s" % [category, id, card_id])
		seen_ids[card_id] = true
		if title == "":
			warnings.append("%s codexLore card missing title: %s/%s" % [category, id, card_id])
		elif expected_titles.has(card_id) and title != String(expected_titles.get(card_id, "")):
			warnings.append("%s codexLore card title mismatch: %s/%s" % [category, id, card_id])
		if text == "" and card_id != "evolution_from":
			warnings.append("%s codexLore card missing text: %s/%s" % [category, id, card_id])
		if span != 1 and span != 2:
			warnings.append("%s codexLore invalid span: %s/%s" % [category, id, card_id])
		spans.append(span)
	if seen_ids.size() != expected_ids.size():
		warnings.append("%s codexLore card ids incomplete: %s" % [category, id])
	elif spans.size() == 3 and (spans[0] != 2 or spans[1] != 1 or spans[2] != 1):
		warnings.append("%s codexLore span order is not 2/1/1: %s" % [category, id])
	var archive_title := String(lore.get("archiveTitle", "")).strip_edges()
	if archive_title == "":
		warnings.append("%s codexLore missing archiveTitle: %s" % [category, id])
	else:
		var expected_archive_title := "ITEM NOTE" if category == "accessories" else "WEAPON ARCHIVE"
		if archive_title != expected_archive_title:
			warnings.append("%s codexLore archiveTitle mismatch: %s" % [category, id])
	var paragraphs_value: Variant = lore.get("archiveParagraphs", [])
	if not paragraphs_value is Array or (paragraphs_value as Array).is_empty():
		warnings.append("%s codexLore missing archiveParagraphs: %s" % [category, id])
	else:
		for paragraph_value in paragraphs_value as Array:
			if not paragraph_value is String or String(paragraph_value).strip_edges() == "":
				warnings.append("%s codexLore has empty archive paragraph: %s" % [category, id])
	var image_path := CodexPresentationSystemScript.image_path_for(category, row, true)
	if image_path == "":
		warnings.append("%s codexLore item has no valid image: %s" % [category, id])

static func _audit_enemies(raw_value: Variant, enabled_value: Variant, warnings: Array[String], sources: Dictionary = {}) -> Dictionary:
	var raw := _dict_array(raw_value)
	var enabled := _dict_array(enabled_value)
	var safe_sources := sources.duplicate(true)
	if safe_sources.is_empty():
		safe_sources = EnemyCodexProfileSystemScript.load_sources()
	var ids: Dictionary = {}
	var orders: Dictionary = {}
	var relay_ids: Array[String] = []
	var lore_template_counts := {"normal_enemy": 0, "special": 0, "boss": 0}
	for row in raw:
		var id := String(row.get("id", "")).strip_edges()
		_check_duplicate_id(row, ids, "enemies", warnings)
		var order_key := str(row.get("order", ""))
		if orders.has(order_key):
			warnings.append("enemies duplicate order: %s" % order_key)
		orders[order_key] = true
		var codex_display_name := String(row.get("displayName", "")).strip_edges()
		var runtime_display_name := EnemyCodexProfileSystemScript.runtime_display_name(row, safe_sources)
		if runtime_display_name != "" and codex_display_name != runtime_display_name:
			warnings.append("enemies displayName mismatch: id=%s codex=%s runtime=%s" % [id, codex_display_name, runtime_display_name])
		if not bool(row.get("codexEnabled", true)):
			if row.has("codexLore") or row.has("codex_lore"):
				warnings.append("disabled enemy must not have codexLore: %s" % id)
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
		_audit_enemy_lore(row, warnings)
		var lore_value: Variant = row.get("codexLore", {})
		if lore_value is Dictionary:
			var template := String((lore_value as Dictionary).get("template", ""))
			if lore_template_counts.has(template):
				lore_template_counts[template] += 1
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
	return {"raw": raw.size(), "enabled": enabled.size(), "disabled": maxi(0, raw.size() - enabled.size()), "relayBossIds": relay_ids, "loreTemplateCounts": lore_template_counts}

static func _audit_enemy_lore(row: Dictionary, warnings: Array[String]) -> void:
	var id := String(row.get("id", "")).strip_edges()
	var lore_value: Variant = row.get("codexLore", null)
	if not lore_value is Dictionary:
		warnings.append("enemies missing codexLore: %s" % id)
		return
	var lore := lore_value as Dictionary
	var template := String(lore.get("template", "")).strip_edges()
	var expected_template := "boss" if bool(row.get("isBoss", false)) or bool(row.get("relayBoss", false)) else ("special" if bool(row.get("codexSpecial", false)) else "normal_enemy")
	if template not in ["normal_enemy", "special", "boss"]:
		warnings.append("enemies invalid codexLore template: %s/%s" % [id, template])
	elif template != expected_template:
		warnings.append("enemies codexLore template mismatch: %s/%s" % [id, template])
	var cards_value: Variant = lore.get("cards", [])
	if not cards_value is Array or (cards_value as Array).size() != 3:
		warnings.append("enemies codexLore cards must have 3 entries: %s" % id)
		return
	var expected_ids: Array[String] = []
	var expected_titles: Dictionary = {}
	if template == "normal_enemy":
		expected_ids = ["ecology", "appearance_reason", "observation_note"]
		expected_titles = {"ecology": "生態", "appearance_reason": "出没理由", "observation_note": "観測メモ"}
	elif template == "boss":
		expected_ids = ["origin", "habit", "rumor"]
		expected_titles = {"origin": "発生源", "habit": "習性", "rumor": "配信界隈のうわさ"}
	var seen_ids: Dictionary = {}
	var spans: Array[int] = []
	for card_value in cards_value as Array:
		if not card_value is Dictionary:
			warnings.append("enemies codexLore card is not Dictionary: %s" % id)
			continue
		var card := card_value as Dictionary
		var card_id := String(card.get("id", "")).strip_edges()
		var title := String(card.get("title", "")).strip_edges()
		var text := String(card.get("text", "")).strip_edges()
		var span := int(card.get("span", 1))
		if card_id == "" or seen_ids.has(card_id):
			warnings.append("enemies duplicate/empty codexLore card id: %s/%s" % [id, card_id])
		seen_ids[card_id] = true
		if template != "special" and not expected_ids.has(card_id):
			warnings.append("enemies unknown codexLore card id: %s/%s" % [id, card_id])
		if title == "":
			warnings.append("enemies codexLore card missing title: %s/%s" % [id, card_id])
		elif expected_titles.has(card_id) and title != String(expected_titles.get(card_id, "")):
			warnings.append("enemies codexLore card title mismatch: %s/%s" % [id, card_id])
		if text == "":
			warnings.append("enemies codexLore card missing text: %s/%s" % [id, card_id])
		if span != 1 and span != 2:
			warnings.append("enemies codexLore invalid span: %s/%s" % [id, card_id])
		spans.append(span)
	if template != "special" and seen_ids.size() != expected_ids.size():
		warnings.append("enemies codexLore card ids incomplete: %s" % id)
	if spans.size() == 3 and (spans[0] != 2 or spans[1] != 1 or spans[2] != 1):
		warnings.append("enemies codexLore span order is not 2/1/1: %s" % id)
	var archive_title := String(lore.get("archiveTitle", "")).strip_edges()
	if archive_title != "ENEMY ARCHIVE":
		warnings.append("enemies codexLore archiveTitle mismatch: %s" % id)
	var paragraphs_value: Variant = lore.get("archiveParagraphs", [])
	if not paragraphs_value is Array or (paragraphs_value as Array).is_empty():
		warnings.append("enemies codexLore missing archiveParagraphs: %s" % id)
	else:
		for paragraph_value in paragraphs_value as Array:
			if not paragraph_value is String or String(paragraph_value).strip_edges() == "":
				warnings.append("enemies codexLore empty archive paragraph: %s" % id)
	if lore.has("codexVisual"):
		var visual_value: Variant = lore.get("codexVisual")
		if not visual_value is Dictionary:
			warnings.append("enemies codexVisual is not Dictionary: %s" % id)
		else:
			var visual := visual_value as Dictionary
			var scale_value: Variant = visual.get("scale", 1.0)
			if not (scale_value is int or scale_value is float) or float(scale_value) < 0.5 or float(scale_value) > 2.5:
				warnings.append("enemies codexVisual scale out of range: %s" % id)

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
		elif id != "":
			_audit_comment_lore(row, warnings)
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
	return CommentSystemScript.codex_reachable_standard_comment_ids(comments)

static func _audit_comment_lore(row: Dictionary, warnings: Array[String]) -> void:
	var id := String(row.get("id", ""))
	var lore_value: Variant = row.get("codexLore", row.get("codex_lore", null))
	if not lore_value is Dictionary:
		warnings.append("comments missing codexLore: %s" % id)
		return
	var lore := lore_value as Dictionary
	if String(lore.get("template", "")).strip_edges() != "directive_comment":
		warnings.append("comments codexLore template mismatch: %s" % id)
	var cards_value: Variant = lore.get("cards", [])
	var cards: Array = cards_value as Array if cards_value is Array else []
	var expected := ["writer", "posting_moment", "observation_note"]
	if cards.size() != 3:
		warnings.append("comments codexLore cards count mismatch: %s" % id)
	for index in range(mini(cards.size(), expected.size())):
		var card_value: Variant = cards[index]
		if not card_value is Dictionary:
			warnings.append("comments codexLore card is not Dictionary: %s" % id)
			continue
		var card := card_value as Dictionary
		if String(card.get("id", "")) != expected[index]:
			warnings.append("comments codexLore card id mismatch: %s" % id)
		if String(card.get("title", "")).strip_edges() == "" or String(card.get("text", "")).strip_edges() == "":
			warnings.append("comments codexLore empty card: %s" % id)
		var expected_span := 2 if index == 0 else 1
		if int(card.get("span", 1)) != expected_span:
			warnings.append("comments codexLore card span mismatch: %s" % id)
	var archive_title := String(lore.get("archiveTitle", lore.get("archive_title", ""))).strip_edges()
	if archive_title != "COMMENT ARCHIVE":
		warnings.append("comments codexLore archiveTitle mismatch: %s" % id)
	var paragraphs_value: Variant = lore.get("archiveParagraphs", lore.get("archive_paragraphs", []))
	if not paragraphs_value is Array or (paragraphs_value as Array).is_empty():
		warnings.append("comments codexLore missing archiveParagraphs: %s" % id)
	else:
		for paragraph_value in paragraphs_value as Array:
			if not paragraph_value is String or String(paragraph_value).strip_edges() == "":
				warnings.append("comments codexLore empty archive paragraph: %s" % id)
	if String(row.get("description", "")).strip_edges() == "":
		warnings.append("comments missing normal effect for codex detail: %s" % id)
	if lore.has("codexVisual") or lore.has("codex_visual"):
		var visual_value: Variant = lore.get("codexVisual", lore.get("codex_visual", {}))
		if not visual_value is Dictionary:
			warnings.append("comments codexVisual is not Dictionary: %s" % id)
		else:
			var visual := visual_value as Dictionary
			var scale_value: Variant = visual.get("scale", 1.0)
			var offset_x_value: Variant = visual.get("offsetX", visual.get("offset_x", 0.0))
			var offset_y_value: Variant = visual.get("offsetY", visual.get("offset_y", 0.0))
			if not (scale_value is int or scale_value is float) or not is_finite(float(scale_value)) or float(scale_value) < 0.5 or float(scale_value) > 2.5:
				warnings.append("comments codexVisual scale out of range: %s" % id)
			if not (offset_x_value is int or offset_x_value is float) or not is_finite(float(offset_x_value)) or float(offset_x_value) < -1.0 or float(offset_x_value) > 1.0:
				warnings.append("comments codexVisual offsetX out of range: %s" % id)
			if not (offset_y_value is int or offset_y_value is float) or not is_finite(float(offset_y_value)) or float(offset_y_value) < -1.0 or float(offset_y_value) > 1.0:
				warnings.append("comments codexVisual offsetY out of range: %s" % id)

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
