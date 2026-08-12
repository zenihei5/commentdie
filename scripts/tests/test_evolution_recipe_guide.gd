extends Node

const DatabaseScript := preload("res://scripts/systems/power_up_database.gd")
const SaveStoreScript := preload("res://scripts/systems/power_up_save_store.gd")
const ShopManagerScript := preload("res://scripts/systems/power_up_shop_manager.gd")
const GuideSystemScript := preload("res://scripts/systems/evolution_recipe_guide_system.gd")
const ChoiceCardSystemScript := preload("res://scripts/systems/choice_card_system.gd")
const GiftSystemScript := preload("res://scripts/systems/gift_system.gd")
const WeaponSystemScript := preload("res://scripts/systems/weapon_system.gd")
const WeaponEvolutionSystemScript := preload("res://scripts/systems/weapon_evolution_system.gd")
const GameScript := preload("res://scripts/game.gd")
const TestTargetScript := preload("res://scripts/tests/evolution_recipe_guide_test_target.gd")

var weapons: Array = []
var gifts: Array = []
var failures: Array[String] = []
var save_should_fail := false
var saved_candidate: Dictionary = {}
var save_call_count := 0

func _ready() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	weapons = JSON.parse_string(FileAccess.get_file_as_string("res://data/weapons.json")) as Array
	gifts = JSON.parse_string(FileAccess.get_file_as_string("res://data/gifts.json")) as Array
	_check(not weapons.is_empty(), "weapon registry parsed", failures)
	_check(not gifts.is_empty(), "gift registry parsed", failures)
	_test_store_normalization_and_round_trip()
	_test_manager_discovery_and_rollback()
	_test_catalog_and_character_conditions()
	_test_hidden_and_reverse_display()
	_test_actual_apply_result_propagation()
	if failures.is_empty():
		print("EVOLUTION_RECIPE_GUIDE_TESTS: PASS")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("EVOLUTION_RECIPE_GUIDE_TESTS: FAIL (%d)" % failures.size())
	get_tree().quit(1)

func _test_store_normalization_and_round_trip() -> void:
	var database = DatabaseScript.load_default()
	var store = SaveStoreScript.new()
	var defaults := store.default_data(database)
	_check((defaults.get("discoveredEvolutionRecipes", []) as Array).is_empty(), "missing recipe field defaults to empty", failures)
	var normalized := store.normalize({
		"schemaVersion": 3,
		"selectedCharacterId": "ban_chan",
		"discoveredEvolutionRecipes": [" full_voice_dome ", "", "full_voice_dome", "future_recipe", 42]
	}, database)
	var discovered: Array = normalized.get("discoveredEvolutionRecipes", []) as Array
	_check(discovered == ["full_voice_dome", "future_recipe", "42"], "recipe IDs trim, deduplicate, and keep future IDs", failures)
	_check(String(normalized.get("selectedCharacterId", "")) == "ban_chan", "existing profile fields remain normalized", failures)
	var schema_two := store.normalize({"schemaVersion": 2, "firstRelayClear": true}, database)
	_check(schema_two.get("normalRelayCleared", false) != true, "schema v2 does not retrigger legacy relay migration", failures)
	var path_store = SaveStoreScript.new()
	path_store.path = "user://evolution_recipe_guide_profile_test.json"
	path_store.backup_path = "user://evolution_recipe_guide_profile_test.json.bak"
	path_store.temp_path = "user://evolution_recipe_guide_profile_test.json.tmp"
	var saved := path_store.default_data(database)
	saved["discoveredEvolutionRecipes"] = ["full_voice_dome", "future_recipe"]
	_check(path_store.save_data(saved, database), "recipe profile atomic save", failures)
	var reloaded := path_store.load_data(database)
	_check((reloaded.get("discoveredEvolutionRecipes", []) as Array) == ["full_voice_dome", "future_recipe"], "recipe profile reloads from dedicated test path", failures)
	_cleanup_file(path_store.path)
	_cleanup_file(path_store.backup_path)
	_cleanup_file(path_store.temp_path)

func _test_manager_discovery_and_rollback() -> void:
	var database = DatabaseScript.load_default()
	var store = SaveStoreScript.new()
	store.save_override = Callable(self, "_save_override")
	var manager = ShopManagerScript.new(database, store)
	manager.profile = store.default_data(database)
	saved_candidate = {}
	save_call_count = 0
	save_should_fail = false
	var first: Dictionary = manager.discover_evolution_recipe(" full_voice_dome ")
	_check(first.get("ok", false) == true and first.get("newlyDiscovered", false) == true, "first recipe discovery saves", failures)
	_check(manager.is_evolution_recipe_discovered("full_voice_dome"), "manager exposes discovered recipe", failures)
	var saves_after_first := save_call_count
	var second: Dictionary = manager.discover_evolution_recipe("full_voice_dome")
	_check(second.get("ok", false) == true and second.get("newlyDiscovered", false) == false and save_call_count == saves_after_first, "second discovery is a save-free no-op", failures)
	save_should_fail = true
	var before_failure := JSON.stringify(manager.profile)
	var failed: Dictionary = manager.discover_evolution_recipe("center_stage")
	_check(failed.get("ok", false) != true and failed.get("state", "") == "save_failed", "discovery reports save failure", failures)
	_check(JSON.stringify(manager.profile) == before_failure and not manager.is_evolution_recipe_discovered("center_stage"), "failed discovery does not update profile first", failures)
	_check(manager.discover_evolution_recipe("").get("state", "") == "invalid_id", "empty recipe ID is rejected", failures)

func _test_catalog_and_character_conditions() -> void:
	var context := _context([], "ban_chan")
	var catalog := GuideSystemScript.build_catalog(context)
	_check(catalog.size() == 13, "catalog has thirteen valid recipes", failures)
	var evolved_ids: Array[String] = []
	for item_value in catalog:
		var item: Dictionary = item_value as Dictionary
		evolved_ids.append(String(item.get("evolvedWeaponId", "")))
	_check(evolved_ids.size() == 13 and evolved_ids.size() == _unique_count(evolved_ids), "catalog evolved IDs are unique", failures)
	var initial_cases: Array = [
		{"base": "ban_hammer", "character": "ban_chan", "material": "stream_power"},
		{"base": "superchat_shot", "character": "superchat_chan", "material": "bullet_support"},
		{"base": "comment_boomerang", "character": "maro_chan", "material": "sweet_tooth"},
		{"base": "moderator_shield", "character": "aosumi_kyasumi", "material": "mental_care"},
		{"base": "fansa_baton", "character": "akarine_rizumu", "material": "light_sneakers"},
		{"base": "tsuri_thumbnail_rod", "character": "shizuki_miimu", "material": "comment_radar"}
	]
	for case_value in initial_cases:
		var spec: Dictionary = case_value as Dictionary
		var own := GuideSystemScript.recipe_for_base_id(String(spec["base"]), _context([], String(spec["character"])))
		var other := GuideSystemScript.recipe_for_base_id(String(spec["base"]), _context([], "other_character"))
		_check((own.get("applicableRequirements", []) as Array).size() == 1, "%s own context hides bypassed material" % String(spec["base"]), failures)
		var other_requirements: Array = other.get("applicableRequirements", []) as Array
		_check(other_requirements.size() == 2 and String((other_requirements[1] as Dictionary).get("id", "")) == String(spec["material"]), "%s other context shows material" % String(spec["base"]), failures)
	for recipe_value in catalog:
		var recipe: Dictionary = recipe_value as Dictionary
		var additional: Array = recipe.get("additionalRequirements", []) as Array
		if additional.is_empty():
			continue
		var requirement: Dictionary = additional[0] as Dictionary
		if String(requirement.get("type", "")) == "accessory" and requirement.get("requiredLevel", null) is int:
			_check(int(requirement.get("requiredLevel", 0)) == 5, "%s numeric accessory is Lv5" % String(recipe.get("baseWeaponId", "")), failures)

func _test_hidden_and_reverse_display() -> void:
	var hidden_context := _context([], "other_character")
	var mic := _find(weapons, "mic_barrier")
	var hidden_card := ChoiceCardSystemScript.gift_card(0, mic, 5, hidden_context)
	var hidden_text := String(hidden_card.get("text", ""))
	var full_voice_name := String(_find(weapons, "full_voice_dome").get("displayName", ""))
	_check(hidden_text.contains("進化：？？？"), "undiscovered base card shows unknown recipe", failures)
	_check(not hidden_text.contains(full_voice_name) and not hidden_text.contains("mini_humidifier"), "undiscovered card does not leak target or material", failures)
	var hidden_detail := GuideSystemScript.detail_for_item("mic_barrier", "weapon", hidden_context)
	_check(hidden_detail == "進化：？？？", "undiscovered detail stays unknown", failures)
	var discovered_context := _context(["full_voice_dome"], "other_character")
	var full_detail := GuideSystemScript.detail_for_item("mic_barrier", "weapon", discovered_context)
	var humidifier_name := String(_find(gifts, "mini_humidifier").get("displayName", ""))
	_check(full_detail.contains(full_voice_name) and full_detail.contains(humidifier_name) and full_detail.contains("Lv5"), "discovered weapon detail shows full condition", failures)
	var material_detail := GuideSystemScript.detail_for_item("mini_humidifier", "accessory", discovered_context)
	_check(material_detail.contains("進化素材") and material_detail.contains(full_voice_name), "discovered accessory reverse index is visible", failures)
	var material_card := ChoiceCardSystemScript.gift_card(0, _find(gifts, "mini_humidifier"), 3, discovered_context)
	_check(String(material_card.get("text", "")).contains("進化素材"), "discovered material card can show reverse index", failures)
	var evolved_card := ChoiceCardSystemScript.gift_card(0, _find(weapons, "full_voice_dome"), 1, discovered_context)
	_check(not String(evolved_card.get("text", "")).contains("進化："), "evolution gift is not treated as a normal unknown recipe", failures)

func _test_actual_apply_result_propagation() -> void:
	var target := TestTargetScript.new()
	target.weapons = weapons.duplicate(true)
	target.gifts = gifts.duplicate(true)
	target.player_weapons = [{"id": "mic_barrier", "level": 5}]
	target.player_accessories = [{"id": "mini_humidifier", "level": 5}]
	target.current_character_id = "other_character"
	target.current_character = {"id": "other_character", "hp": 100, "moveSpeed": 5.0, "pickupRange": 1.0, "dashCooldown": 1.2}
	target.current_weapon_id = "mic_barrier"
	target.current_weapon = WeaponSystemScript.find_weapon(weapons, "mic_barrier", {})
	var gift := WeaponEvolutionSystemScript.evolution_gift_for_target(target, weapons)
	target.offered_gifts = [gift]
	var choice_box := Control.new()
	var rng := RandomNumberGenerator.new()
	var result := GiftSystemScript.choose_offer_index_with_feedback_for_target(target, 0, choice_box, [], rng)
	_check(result.get("selected", false) == true, "actual gift selection succeeds", failures)
	var propagated_evolution: Dictionary = result.get("weaponEvolution", {}) as Dictionary
	_check(not propagated_evolution.is_empty(), "weaponEvolution survives feedback result", failures)
	var store := SaveStoreScript.new()
	store.save_override = Callable(self, "_save_override")
	var database = DatabaseScript.load_default()
	var manager = ShopManagerScript.new(database, store)
	manager.profile = store.default_data(database)
	save_should_fail = false
	var game_probe := GameScript.new()
	game_probe.power_up_shop_manager = manager
	var discovery := game_probe._record_evolution_recipe_discovery(result)
	_check(discovery.get("ok", false) == true, "final game retrieval point saves applied recipe", failures)
	_check(manager.is_evolution_recipe_discovered("full_voice_dome"), "final game retrieval point records applied recipe", failures)
	choice_box.free()
	target.free()
	game_probe.free()

func _context(discovered: Array, character_id: String) -> Dictionary:
	return {
		"weaponRegistry": weapons,
		"giftRegistry": gifts,
		"currentCharacterId": character_id,
		"discoveredIds": discovered
	}

func _find(registry: Array, id: String) -> Dictionary:
	for item in registry:
		if item is Dictionary and String((item as Dictionary).get("id", "")) == id:
			return item as Dictionary
	return {}

func _unique_count(values: Array[String]) -> int:
	var unique: Array[String] = []
	for value in values:
		if not unique.has(value):
			unique.append(value)
	return unique.size()

func _save_override(candidate: Dictionary) -> bool:
	save_call_count += 1
	saved_candidate = candidate.duplicate(true)
	return not save_should_fail

func _cleanup_file(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _check(condition: bool, label: String, output: Array[String]) -> void:
	if not condition:
		output.append(label)
