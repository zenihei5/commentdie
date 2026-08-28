extends Node

const Presentation := preload("res://scripts/systems/codex_presentation_system.gd")

var failures: Array[String] = []

func _ready() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	CodexManager.initialize_empty()
	var weapons: Array = CodexManager.get_master_entries(CodexManager.CATEGORY_WEAPON)
	var accessories: Array = CodexManager.get_master_entries(CodexManager.CATEGORY_ACCESSORY)
	var characters: Array = CodexManager.get_master_entries(CodexManager.CATEGORY_CHARACTER)
	_check(weapons.size() == 26, "effective weapon count is 26")
	_check(accessories.size() == 10, "effective accessory count is 10")
	var classification_counts := {"initial": 0, "normal": 0, "evolved": 0}
	for weapon_value in weapons:
		if not weapon_value is Dictionary:
			continue
		var weapon := weapon_value as Dictionary
		var model := Presentation.item_lore_model(weapon, CodexManager.CATEGORY_WEAPON, true, weapons, characters)
		_check(bool(model.get("hasLore", false)), "weapon has lore: %s" % String(weapon.get("id", "")))
		_check(String(model.get("classificationLabel", "")) != "", "weapon has classification: %s" % String(weapon.get("id", "")))
		var key := String(model.get("classificationKey", ""))
		if classification_counts.has(key):
			classification_counts[key] += 1
		_check(_check_lore_shape(model, String(weapon.get("id", ""))), "weapon lore shape: %s" % String(weapon.get("id", "")))
		_check((model.get("archiveParagraphs", []) as Array).size() == 4, "weapon archive uses revised four-paragraph text: %s" % String(weapon.get("id", "")))
		if bool(weapon.get("isEvolved", false)):
			var base_id := String(weapon.get("baseWeaponId", ""))
			var base := _find(weapons, base_id)
			var evolution_from := _find_card(model, "evolution_from")
			_check(String(evolution_from.get("text", "")) == String(base.get("displayName", base_id)), "evolution_from is derived from existing relation: %s" % String(weapon.get("id", "")))
	_check(int(classification_counts["initial"]) == 6, "weapon classification has six initial weapons")
	_check(int(classification_counts["normal"]) == 7, "weapon classification has seven normal weapons")
	_check(int(classification_counts["evolved"]) == 13, "weapon classification has thirteen evolved weapons")
	for accessory_value in accessories:
		if not accessory_value is Dictionary:
			continue
		var accessory := accessory_value as Dictionary
		var model := Presentation.item_lore_model(accessory, CodexManager.CATEGORY_ACCESSORY, true, weapons, characters)
		_check(String(model.get("classificationLabel", "")) == "アクセサリ", "accessory classification is derived")
		_check(bool(model.get("hasLore", false)), "accessory has lore: %s" % String(accessory.get("id", "")))
		_check(_check_lore_shape(model, String(accessory.get("id", ""))), "accessory lore shape: %s" % String(accessory.get("id", "")))
		var expected_archive_count := 6 if String(accessory.get("id", "")) == "mental_care" else 4
		_check((model.get("archiveParagraphs", []) as Array).size() == expected_archive_count, "accessory archive paragraph count: %s" % String(accessory.get("id", "")))
	var hidden := Presentation.item_lore_model(_find(weapons, "ban_judgement"), CodexManager.CATEGORY_WEAPON, false, weapons, characters)
	_check(not bool(hidden.get("hasLore", false)) and (hidden.get("cards", []) as Array).is_empty() and String(hidden.get("imagePath", "")) == "", "undiscovered item does not expose lore or image")
	var missing := Presentation.item_lore_model({"id": "missing_item", "displayName": "欠損"}, CodexManager.CATEGORY_WEAPON, true, weapons, characters)
	_check(not bool(missing.get("hasLore", false)) and String(missing.get("classificationLabel", "")) == "通常武器", "missing lore falls back without breaking classification")
	var legacy := Presentation.item_lore_model({"id": "legacy", "codex_lore": {"cards": [{"id": "usage", "title": "使い道", "text": "旧キー", "span": 2}], "archive_title": "ITEM NOTE", "archive_paragraphs": ["旧段落"]}}, CodexManager.CATEGORY_ACCESSORY, true, weapons, characters)
	_check(bool(legacy.get("hasLore", false)) and String(legacy.get("archiveTitle", "")) == "ITEM NOTE", "snake_case lore remains a read-only fallback")
	var saved := CodexManager.get_save_data()
	_check(not JSON.stringify(saved).contains("codexLore") and not JSON.stringify(saved).contains("codex_lore"), "lore is not written to codex save data")
	var report := CodexManager.validate_masters()
	var counts: Dictionary = report.get("counts", {}) as Dictionary
	_check(int((counts.get("weapons", {}) as Dictionary).get("enabled", 0)) == 26, "audit keeps weapon enabled count")
	_check(int((counts.get("accessories", {}) as Dictionary).get("enabled", 0)) == 10, "audit keeps accessory enabled count")
	for warning_value in report.get("warnings", []) as Array:
		if String(warning_value).begins_with("comments missing codexLore:"):
			continue
		_check(not String(warning_value).contains("missing codexLore"), "audit has no missing item lore warning: %s" % String(warning_value))
	if failures.is_empty():
		print("CODEX_ITEM_LORE_V1_TESTS: PASS")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("CODEX_ITEM_LORE_V1_TESTS: FAIL (%d)" % failures.size())
	get_tree().quit(1)

func _check_lore_shape(model: Dictionary, id: String) -> bool:
	var cards: Array = model.get("cards", []) as Array
	if cards.size() != 3:
		return false
	var spans: Array[int] = []
	for card_value in cards:
		if not card_value is Dictionary:
			return false
		var card := card_value as Dictionary
		if String(card.get("id", "")) == "" or String(card.get("title", "")) == "" or (String(card.get("text", "")) == "" and String(card.get("id", "")) != "evolution_from"):
			return false
		spans.append(int(card.get("span", 0)))
	if spans != [2, 1, 1]:
		return false
	var paragraphs: Array = model.get("archiveParagraphs", []) as Array
	return String(model.get("archiveTitle", "")).strip_edges() != "" and not paragraphs.is_empty() and not id.is_empty()

func _find_card(model: Dictionary, id: String) -> Dictionary:
	for card_value in model.get("cards", []) as Array:
		if card_value is Dictionary and String((card_value as Dictionary).get("id", "")) == id:
			return card_value as Dictionary
	return {}

func _find(items: Array, id: String) -> Dictionary:
	for item_value in items:
		if item_value is Dictionary and String((item_value as Dictionary).get("id", "")) == id:
			return item_value as Dictionary
	return {}

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
