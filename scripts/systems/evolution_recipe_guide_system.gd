class_name EvolutionRecipeGuideSystem
extends RefCounted

const EquipmentSystemScript := preload("res://scripts/systems/equipment_system.gd")

static func context_for_target(target: Node, manager = null) -> Dictionary:
	var resolved_manager = manager
	if resolved_manager == null:
		for property_value in target.get_property_list():
			if String((property_value as Dictionary).get("name", "")) == "power_up_shop_manager":
				var manager_value: Variant = target.get("power_up_shop_manager")
				if manager_value != null:
					resolved_manager = manager_value
				break
	var discovered: Array = []
	if resolved_manager != null and resolved_manager.has_method("discovered_evolution_recipe_ids"):
		discovered = resolved_manager.discovered_evolution_recipe_ids()
	var current_character_id := String(target.get("current_character_id"))
	if current_character_id == "":
		var current_character: Variant = target.get("current_character")
		if current_character is Dictionary:
			current_character_id = String((current_character as Dictionary).get("id", ""))
	return {
		"weaponRegistry": _array_value(target.get("weapons")),
		"giftRegistry": _array_value(target.get("gifts")),
		"currentCharacterId": current_character_id,
		"discoveredIds": discovered
	}

static func build_catalog(context: Dictionary) -> Array:
	var catalog: Array = []
	var seen_evolved_ids: Array[String] = []
	var weapon_registry := _context_array(context, "weaponRegistry", "weapon_registry", "weapons")
	var discovered := _string_array(context.get("discoveredIds", context.get("discoveredEvolutionRecipes", context.get("discovered_evolution_recipes", []))))
	for item in weapon_registry:
		if not (item is Dictionary):
			continue
		var base_weapon: Dictionary = item as Dictionary
		if not EquipmentSystemScript.is_weapon(base_weapon):
			continue
		var evolution_value: Variant = base_weapon.get("evolution", {})
		if not (evolution_value is Dictionary) or not _is_true(base_weapon.get("evolutionEnabled", false)):
			continue
		var evolution: Dictionary = evolution_value as Dictionary
		var evolved_id := String(evolution.get("evolvedWeaponId", "")).strip_edges()
		if evolved_id == "" or seen_evolved_ids.has(evolved_id):
			continue
		var evolved_weapon := _find_definition(weapon_registry, evolved_id)
		if evolved_weapon.is_empty():
			continue
		seen_evolved_ids.append(evolved_id)
		catalog.append(_recipe_model(base_weapon, evolution, evolved_weapon, context, discovered))
	return catalog

static func catalog_for_target(target: Node, manager = null) -> Array:
	return build_catalog(context_for_target(target, manager))

static func build_codex_catalog(weapon_registry: Array, gift_registry: Array = []) -> Array:
	# Neutral catalog for read-only consumers.  Shop/profile discovery is not
	# consulted here; the codex supplies its own discovered weapon IDs.
	return build_catalog({
		"weaponRegistry": weapon_registry,
		"giftRegistry": gift_registry,
		"currentCharacterId": "",
		"discoveredIds": []
	})

static func recipe_for_base_id(base_weapon_id: String, context: Dictionary) -> Dictionary:
	var normalized_id := base_weapon_id.strip_edges()
	for recipe_item in build_catalog(context):
		var recipe: Dictionary = recipe_item as Dictionary
		if String(recipe.get("baseWeaponId", "")) == normalized_id:
			return recipe.duplicate(true)
	return {}

static func recipe_for_evolved_id(evolved_weapon_id: String, context: Dictionary) -> Dictionary:
	var normalized_id := evolved_weapon_id.strip_edges()
	for recipe_item in build_catalog(context):
		var recipe: Dictionary = recipe_item as Dictionary
		if String(recipe.get("evolvedWeaponId", "")) == normalized_id:
			return recipe.duplicate(true)
	return {}

static func card_line_for_gift(gift: Dictionary, context: Dictionary) -> String:
	if gift.is_empty() or EquipmentSystemScript.is_evolution_gift(gift):
		return ""
	var item_id := String(gift.get("id", "")).strip_edges()
	if item_id == "":
		return ""
	var recipe := recipe_for_base_id(item_id, context)
	if not recipe.is_empty():
		if not _is_true(recipe.get("discovered", false)):
			return "進化：？？？"
		var additional_labels := _additional_requirement_labels(recipe)
		if not additional_labels.is_empty():
			return "進化：%s" % String(additional_labels[0])
		return "進化：Lv%d → %s" % [int(recipe.get("requiredWeaponLevel", 1)), String(recipe.get("evolvedDisplayName", ""))]
	var reverse_guides := reverse_material_guides(item_id, "", context)
	if not reverse_guides.is_empty():
		return "進化素材 ×%d" % reverse_guides.size()
	return ""

static func detail_for_item(item_id: String, item_type: String, context: Dictionary) -> String:
	var normalized_id := item_id.strip_edges()
	if normalized_id == "":
		return ""
	var lines: Array[String] = []
	var forward_recipe := recipe_for_base_id(normalized_id, context)
	if not forward_recipe.is_empty():
		if not _is_true(forward_recipe.get("discovered", false)):
			return "進化：？？？"
		lines.append("進化条件")
		lines.append(_condition_line(forward_recipe))
		lines.append("→ %s" % String(forward_recipe.get("evolvedDisplayName", "")))
		lines.append("※進化済みの武器も、元武器の進化条件を満たします")
	var reverse_guides := reverse_material_guides(normalized_id, item_type, context)
	if not reverse_guides.is_empty():
		lines.append("進化素材")
		for guide_item in reverse_guides:
			var guide: Dictionary = guide_item as Dictionary
			lines.append("%s → %s" % [String(guide.get("baseDisplayName", "")), String(guide.get("evolvedDisplayName", ""))])
		if forward_recipe.is_empty():
			lines.append("※進化済みの武器も、元武器の進化条件を満たします")
	return "\n".join(lines)

static func reverse_material_guides(item_id: String, item_type: String, context: Dictionary) -> Array:
	var normalized_id := item_id.strip_edges()
	var normalized_type := item_type.strip_edges()
	var result: Array = []
	var seen_evolved_ids: Array[String] = []
	for recipe_item in build_catalog(context):
		var recipe: Dictionary = recipe_item as Dictionary
		if not _is_true(recipe.get("discovered", false)):
			continue
		var additional: Array = _array_value(recipe.get("additionalRequirements"))
		for requirement_value in additional:
			if not (requirement_value is Dictionary):
				continue
			var requirement: Dictionary = requirement_value as Dictionary
			var requirement_id := String(requirement.get("id", "")).strip_edges()
			var requirement_type := String(requirement.get("type", "")).strip_edges()
			if requirement_id != normalized_id:
				continue
			if normalized_type != "" and requirement_type != normalized_type:
				continue
			var evolved_id := String(recipe.get("evolvedWeaponId", ""))
			if seen_evolved_ids.has(evolved_id):
				continue
			seen_evolved_ids.append(evolved_id)
			result.append({
				"baseWeaponId": recipe.get("baseWeaponId", ""),
				"baseDisplayName": recipe.get("baseDisplayName", ""),
				"evolvedWeaponId": evolved_id,
				"evolvedDisplayName": recipe.get("evolvedDisplayName", ""),
				"requirementType": requirement_type,
				"requirementId": requirement_id
			})
	return result

static func _recipe_model(base_weapon: Dictionary, evolution: Dictionary, evolved_weapon: Dictionary, context: Dictionary, discovered: Array[String]) -> Dictionary:
	var base_id := String(base_weapon.get("id", ""))
	var evolved_id := String(evolution.get("evolvedWeaponId", ""))
	var required_level := int(evolution.get("requiredWeaponLevel", 1))
	var model := {
		"baseWeaponId": base_id,
		"baseDisplayName": String(base_weapon.get("displayName", base_id)),
		"evolvedWeaponId": evolved_id,
		"evolvedDisplayName": String(evolved_weapon.get("displayName", evolved_id)),
		"requiredWeaponLevel": required_level,
		"requiredCharacterId": String(evolution.get("requiredCharacterId", "")),
		"matchingCharacterBypassesAdditionalRequirements": _is_true(evolution.get("matchingCharacterBypassesAdditionalRequirements", false)),
		"additionalRequirements": _array_value(evolution.get("additionalRequirements")).duplicate(true),
		"discovered": discovered.has(evolved_id),
		"applicableRequirements": []
	}
	var applicable: Array = []
	applicable.append({
		"type": "weapon",
		"id": base_id,
		"displayName": model["baseDisplayName"],
		"requiredLevel": required_level,
		"requiredLevelLabel": "Lv%d" % required_level,
		"label": "%s Lv%d" % [String(model["baseDisplayName"]), required_level]
	})
	if _show_additional_requirements(evolution, context):
		for requirement_value in model["additionalRequirements"] as Array:
			if requirement_value is Dictionary:
				applicable.append(_requirement_model(requirement_value as Dictionary, context))
	model["applicableRequirements"] = applicable
	return model

static func _show_additional_requirements(evolution: Dictionary, context: Dictionary) -> bool:
	var required_character_id := String(evolution.get("requiredCharacterId", "")).strip_edges()
	var current_character_id := _context_character_id(context)
	var bypass := _is_true(evolution.get("matchingCharacterBypassesAdditionalRequirements", false))
	return not (bypass and required_character_id != "" and required_character_id == current_character_id)

static func _requirement_model(requirement: Dictionary, context: Dictionary) -> Dictionary:
	var requirement_type := String(requirement.get("type", "")).strip_edges()
	var requirement_id := String(requirement.get("id", "")).strip_edges()
	var registry := _context_array(context, "weaponRegistry", "weapon_registry", "weapons") if requirement_type == "weapon" else _context_array(context, "giftRegistry", "gift_registry", "gifts")
	var definition := _find_definition(registry, requirement_id)
	var display_name := String(definition.get("displayName", requirement_id))
	var level_value: Variant = requirement.get("requiredLevel", 1)
	var level_label := _level_label(level_value)
	return {
		"type": requirement_type,
		"id": requirement_id,
		"displayName": display_name,
		"requiredLevel": level_value,
		"requiredLevelLabel": level_label,
		"label": "%s %s" % [display_name, level_label]
	}

static func _additional_requirement_labels(recipe: Dictionary) -> Array[String]:
	var labels: Array[String] = []
	for requirement_value in recipe.get("applicableRequirements", []) as Array:
		if not (requirement_value is Dictionary):
			continue
		var requirement: Dictionary = requirement_value as Dictionary
		if String(requirement.get("id", "")) == String(recipe.get("baseWeaponId", "")):
			continue
		labels.append(String(requirement.get("label", "")))
	return labels

static func _condition_line(recipe: Dictionary) -> String:
	var labels: Array[String] = []
	for requirement_value in recipe.get("applicableRequirements", []) as Array:
		if requirement_value is Dictionary:
			labels.append(String((requirement_value as Dictionary).get("label", "")))
	return " ＋ ".join(labels)

static func _level_label(value: Variant) -> String:
	if value is String and String(value).strip_edges().to_lower() == "max":
		return "LvMAX"
	return "Lv%d" % int(value)

static func _find_definition(registry: Array, item_id: String) -> Dictionary:
	for item in registry:
		if item is Dictionary and String((item as Dictionary).get("id", "")) == item_id:
			return item as Dictionary
	return {}

static func _array_value(value: Variant) -> Array:
	return value as Array if value is Array else []

static func _context_array(context: Dictionary, primary_key: String, alternate_key: String, legacy_key: String) -> Array:
	var value: Variant = context.get(primary_key, context.get(alternate_key, context.get(legacy_key, [])))
	return _array_value(value)

static func _context_character_id(context: Dictionary) -> String:
	var current_id := String(context.get("currentCharacterId", context.get("current_character_id", ""))).strip_edges()
	if current_id != "":
		return current_id
	var character_value: Variant = context.get("currentCharacter", context.get("current_character", {}))
	if character_value is Dictionary:
		return String((character_value as Dictionary).get("id", "")).strip_edges()
	return ""

static func _string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for item in value as Array:
			var text: String = item.strip_edges() if item is String else str(item).strip_edges()
			if text != "" and not result.has(text):
				result.append(text)
	return result

static func _is_true(value: Variant) -> bool:
	return value == true
