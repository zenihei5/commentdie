extends Node

const Presentation := preload("res://scripts/systems/codex_presentation_system.gd")
const KUSA_SMALL_ICON_PATH := "res://assets/generated/equipment_icons_v1/icons/kusa_wave.png"
const KUSA_CODEX_ICON_PATH := "res://assets/generated/codex_icons_v1/kusa_wave_hd_final_1254.png"
const BAN_JUDGEMENT_SMALL_ICON_PATH := "res://assets/generated/equipment_icons_v1/icons/ban_judgement.png"
const BAN_JUDGEMENT_CODEX_ICON_PATH := "res://assets/generated/codex_icons_v1/ban_judgement_hd_final_1254.png"
const STARLIGHT_SUPERCHAT_SMALL_ICON_PATH := "res://assets/generated/equipment_icons_v1/icons/starlight_superchat.png"
const STARLIGHT_SUPERCHAT_CODEX_ICON_PATH := "res://assets/generated/codex_icons_v1/starlight_superchat_hd_final_1254.png"
const MARO_COMMENT_RING_SMALL_ICON_PATH := "res://assets/generated/equipment_icons_v1/icons/maro_comment_ring.png"
const MARO_COMMENT_RING_CODEX_ICON_PATH := "res://assets/generated/codex_icons_v1/maro_comment_ring_hd_final_1024.png"

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
	var unchanged_codex_fallback_count := 0
	for weapon_value in weapons:
		if not weapon_value is Dictionary:
			continue
		var weapon := weapon_value as Dictionary
		var model := Presentation.item_lore_model(weapon, CodexManager.CATEGORY_WEAPON, true, weapons, characters)
		var weapon_id := String(weapon.get("id", ""))
		var small_icon_path := Presentation.image_path_for(CodexManager.CATEGORY_WEAPON, weapon, true)
		var codex_icon_path := Presentation.codex_image_path_for(CodexManager.CATEGORY_WEAPON, weapon, true)
		_check(small_icon_path == String(weapon.get("iconPath", "")), "weapon small icon keeps production iconPath: %s" % weapon_id)
		_check(String(model.get("imagePath", "")) == codex_icon_path, "weapon lore model uses the Codex resolver: %s" % weapon_id)
		if weapon_id == "kusa_wave":
			_check(small_icon_path == KUSA_SMALL_ICON_PATH, "kusa_wave compact UI keeps the old 96px icon")
			_check(codex_icon_path == KUSA_CODEX_ICON_PATH, "kusa_wave Codex detail uses the HD override")
			_check(String((model.get("codexVisual", {}) as Dictionary).get("iconPath", "")) == KUSA_CODEX_ICON_PATH, "kusa_wave exposes the normalized Codex visual override")
		elif weapon_id == "ban_judgement":
			_check(small_icon_path == BAN_JUDGEMENT_SMALL_ICON_PATH, "ban_judgement compact UI keeps the old 96px icon")
			_check(codex_icon_path == BAN_JUDGEMENT_CODEX_ICON_PATH, "ban_judgement Codex detail uses the HD override")
			_check(String((model.get("codexVisual", {}) as Dictionary).get("iconPath", "")) == BAN_JUDGEMENT_CODEX_ICON_PATH, "ban_judgement exposes the normalized Codex visual override")
		elif weapon_id == "starlight_superchat":
			_check(small_icon_path == STARLIGHT_SUPERCHAT_SMALL_ICON_PATH, "starlight_superchat compact UI keeps the old 96px icon")
			_check(codex_icon_path == STARLIGHT_SUPERCHAT_CODEX_ICON_PATH, "starlight_superchat Codex detail uses the HD override")
			_check(String((model.get("codexVisual", {}) as Dictionary).get("iconPath", "")) == STARLIGHT_SUPERCHAT_CODEX_ICON_PATH, "starlight_superchat exposes the normalized Codex visual override")
		elif weapon_id == "maro_comment_ring":
			_check(small_icon_path == MARO_COMMENT_RING_SMALL_ICON_PATH, "maro_comment_ring compact UI keeps the old 96px icon")
			_check(codex_icon_path == MARO_COMMENT_RING_CODEX_ICON_PATH, "maro_comment_ring Codex detail uses the HD override")
			_check(String((model.get("codexVisual", {}) as Dictionary).get("iconPath", "")) == MARO_COMMENT_RING_CODEX_ICON_PATH, "maro_comment_ring exposes the normalized Codex visual override")
		else:
			unchanged_codex_fallback_count += 1
			_check(codex_icon_path == small_icon_path, "non-overridden weapon keeps its existing icon: %s" % weapon_id)
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
		var accessory_id := String(accessory.get("id", ""))
		var small_icon_path := Presentation.image_path_for(CodexManager.CATEGORY_ACCESSORY, accessory, true)
		var codex_icon_path := Presentation.codex_image_path_for(CodexManager.CATEGORY_ACCESSORY, accessory, true)
		unchanged_codex_fallback_count += 1
		_check(small_icon_path == String(accessory.get("iconPath", "")), "accessory small icon keeps production iconPath: %s" % accessory_id)
		_check(codex_icon_path == small_icon_path and String(model.get("imagePath", "")) == small_icon_path, "non-overridden accessory keeps its existing icon: %s" % accessory_id)
		_check(String(model.get("classificationLabel", "")) == "アクセサリ", "accessory classification is derived")
		_check(bool(model.get("hasLore", false)), "accessory has lore: %s" % String(accessory.get("id", "")))
		_check(_check_lore_shape(model, String(accessory.get("id", ""))), "accessory lore shape: %s" % String(accessory.get("id", "")))
		var expected_archive_count := 6 if String(accessory.get("id", "")) == "mental_care" else 4
		_check((model.get("archiveParagraphs", []) as Array).size() == expected_archive_count, "accessory archive paragraph count: %s" % String(accessory.get("id", "")))
	_check(unchanged_codex_fallback_count == 32, "the other 32 weapon/accessory icons keep the standard resolver path")
	var small_texture := load(KUSA_SMALL_ICON_PATH) as Texture2D
	var codex_texture := load(KUSA_CODEX_ICON_PATH) as Texture2D
	_check(small_texture != null and small_texture.get_size() == Vector2(96, 96), "kusa_wave compact source remains 96x96")
	_check(codex_texture != null and codex_texture.get_size() == Vector2(1254, 1254), "kusa_wave Codex source is 1254x1254")
	var ban_judgement_small_texture := load(BAN_JUDGEMENT_SMALL_ICON_PATH) as Texture2D
	var ban_judgement_codex_texture := load(BAN_JUDGEMENT_CODEX_ICON_PATH) as Texture2D
	_check(ban_judgement_small_texture != null and ban_judgement_small_texture.get_size() == Vector2(96, 96), "ban_judgement compact source remains 96x96")
	_check(ban_judgement_codex_texture != null and ban_judgement_codex_texture.get_size() == Vector2(1254, 1254), "ban_judgement Codex source is 1254x1254")
	var starlight_superchat_small_texture := load(STARLIGHT_SUPERCHAT_SMALL_ICON_PATH) as Texture2D
	var starlight_superchat_codex_texture := load(STARLIGHT_SUPERCHAT_CODEX_ICON_PATH) as Texture2D
	_check(starlight_superchat_small_texture != null and starlight_superchat_small_texture.get_size() == Vector2(96, 96), "starlight_superchat compact source remains 96x96")
	_check(starlight_superchat_codex_texture != null and starlight_superchat_codex_texture.get_size() == Vector2(1254, 1254), "starlight_superchat Codex source is 1254x1254")
	var maro_comment_ring_small_texture := load(MARO_COMMENT_RING_SMALL_ICON_PATH) as Texture2D
	var maro_comment_ring_codex_texture := load(MARO_COMMENT_RING_CODEX_ICON_PATH) as Texture2D
	_check(maro_comment_ring_small_texture != null and maro_comment_ring_small_texture.get_size() == Vector2(96, 96), "maro_comment_ring compact source remains 96x96")
	_check(maro_comment_ring_codex_texture != null and maro_comment_ring_codex_texture.get_size() == Vector2(1024, 1024), "maro_comment_ring Codex source is 1024x1024")
	var kusa_gift := _find(_json_array("res://data/gifts.json"), "kusa_wave")
	_check(String(kusa_gift.get("iconPath", "")) == KUSA_SMALL_ICON_PATH, "kusa_wave gift/evolution choice keeps the old compact icon")
	var generic_override := {"id": "generic_override_fixture", "iconPath": KUSA_SMALL_ICON_PATH, "codexLore": {"codexVisual": {"iconPath": KUSA_CODEX_ICON_PATH}}}
	_check(Presentation.codex_image_path_for(CodexManager.CATEGORY_WEAPON, generic_override, true) == KUSA_CODEX_ICON_PATH, "Codex override is data-driven rather than tied to the kusa_wave ID")
	var invalid_override := {"id": "invalid_override_fixture", "iconPath": KUSA_SMALL_ICON_PATH, "codexLore": {"codexVisual": {"iconPath": "res://assets/generated/codex_icons_v1/missing.png"}}}
	_check(Presentation.codex_image_path_for(CodexManager.CATEGORY_WEAPON, invalid_override, true) == KUSA_SMALL_ICON_PATH, "missing Codex override safely falls back to the standard icon")
	var hidden := Presentation.item_lore_model(_find(weapons, "ban_judgement"), CodexManager.CATEGORY_WEAPON, false, weapons, characters)
	_check(not bool(hidden.get("hasLore", false)) and (hidden.get("cards", []) as Array).is_empty() and String(hidden.get("imagePath", "")) == "" and (hidden.get("codexVisual", {}) as Dictionary).is_empty(), "undiscovered item does not expose lore, image, or Codex visual data")
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

func _json_array(path: String) -> Array:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Array if parsed is Array else []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
