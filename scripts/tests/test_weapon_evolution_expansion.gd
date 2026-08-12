extends Node

const TestTargetScript := preload("res://scripts/tests/stage4_test_target.gd")
const WeaponEvolutionSystemScript := preload("res://scripts/systems/weapon_evolution_system.gd")
const GiftSystemScript := preload("res://scripts/systems/gift_system.gd")
const DebugSystemScript := preload("res://scripts/systems/debug_system.gd")

var weapons: Array = []
var gifts: Array = []
var failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	weapons = JSON.parse_string(FileAccess.get_file_as_string("res://data/weapons.json")) as Array
	gifts = JSON.parse_string(FileAccess.get_file_as_string("res://data/gifts.json")) as Array
	_check(not weapons.is_empty(), "weapon data parsed", failures)
	_check(not gifts.is_empty(), "gift data parsed", failures)
	_test_initial_six()
	_test_regular_evolutions_are_active()
	_test_accessory_requirement()
	_test_weapon_requirement_and_lineage()
	_test_evolution_keeps_materials_and_enables_next_candidate()
	_test_multiple_evolution_gifts()
	_test_reroll_keeps_all_evolution_cards()
	_test_apply_result_is_level_one_and_not_a_normal_candidate()
	_test_evolution_gift_marker_types()
	_test_debug_evolution_gift_command()
	if failures.is_empty():
		print("WEAPON_EVOLUTION_EXPANSION_TESTS: PASS")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("WEAPON_EVOLUTION_EXPANSION_TESTS: FAIL (%d)" % failures.size())
	get_tree().quit(1)


func _test_initial_six() -> void:
	var cases: Array = [
		{"base": "ban_hammer", "evolved": "ban_judgement", "character": "ban_chan", "accessory": "stream_power"},
		{"base": "superchat_shot", "evolved": "starlight_superchat", "character": "superchat_chan", "accessory": "bullet_support"},
		{"base": "comment_boomerang", "evolved": "maro_comment_ring", "character": "maro_chan", "accessory": "sweet_tooth"},
		{"base": "moderator_shield", "evolved": "moderator_fortress", "character": "aosumi_kyasumi", "accessory": "mental_care"},
		{"base": "fansa_baton", "evolved": "fansa_climax", "character": "akarine_rizumu", "accessory": "light_sneakers"},
		{"base": "tsuri_thumbnail_rod", "evolved": "buzz_thumbnail_rod", "character": "shizuki_miimu", "accessory": "comment_radar"}
	]
	for case_value in cases:
		var spec: Dictionary = case_value as Dictionary
		var base_id := String(spec["base"])
		var evolved_id := String(spec["evolved"])
		var character_id := String(spec["character"])
		var accessory_id := String(spec["accessory"])
		var base_weapon := _find_data(weapons, base_id)
		var evolution: Dictionary = base_weapon.get("evolution", {}) as Dictionary
		_check(bool(base_weapon.get("evolutionEnabled", false)), "%s evolution is enabled" % base_id, failures)
		_check(String(evolution.get("evolvedWeaponId", "")) == evolved_id, "%s target is data-driven" % base_id, failures)
		_check(int(evolution.get("requiredWeaponLevel", 0)) == 5, "%s requires weapon Lv5" % base_id, failures)
		_check(int(evolution.get("requiredExpLevel", -1)) == 0, "%s has no EXP gate" % base_id, failures)
		_check(bool(evolution.get("matchingCharacterBypassesAdditionalRequirements", false)), "%s has character bypass flag" % base_id, failures)

		var own_target := _make_target([{"id": base_id, "level": 5}], character_id, [])
		_check(_can_evolve(own_target), "%s本人 Lv5 evolves without accessory" % base_id, failures)
		own_target.player_weapons = [{"id": base_id, "level": 4}]
		_check(not _can_evolve(own_target), "%s本人 Lv4 does not evolve" % base_id, failures)

		var other_target := _make_target([{"id": base_id, "level": 5}], "other_character", [])
		_check(not _can_evolve(other_target), "%s other character without accessory fails" % base_id, failures)
		var gift_data := _find_data(gifts, accessory_id)
		var max_level := int(gift_data.get("maxLevel", 0))
		_check(max_level > 0, "%s accessory has data max" % accessory_id, failures)
		other_target.player_accessories = [{"id": accessory_id, "level": maxi(0, max_level - 1)}]
		_check(not _can_evolve(other_target), "%s below max accessory fails" % base_id, failures)
		other_target.player_accessories = [{"id": accessory_id, "level": max_level}]
		_check(_can_evolve(other_target), "%s other character at data max evolves" % base_id, failures)
		other_target.gifts = []
		_check(not _can_evolve(other_target), "%s missing accessory data fails closed" % base_id, failures)

		var regression_target := _make_target([{"id": base_id, "level": 5}], character_id, [])
		var gift := WeaponEvolutionSystemScript.evolution_gift_for_target(regression_target, weapons)
		_check(String(gift.get("evolvedWeaponId", "")) == evolved_id, "%s regression gift exists" % base_id, failures)


func _test_regular_evolutions_are_active() -> void:
	var cases: Array = [
		{"base": "mic_barrier", "evolved": "full_voice_dome", "material": {"type": "accessory", "id": "mini_humidifier", "requiredLevel": 5}},
		{"base": "spotlight", "evolved": "center_stage", "material": {"type": "weapon", "id": "mic_barrier", "requiredLevel": 5}},
		{"base": "kusa_wave", "evolved": "great_grassland", "material": {"type": "accessory", "id": "bullet_support", "requiredLevel": 5}},
		{"base": "comment_pin", "evolved": "comment_lockdown", "material": {"type": "weapon", "id": "ng_word_laser", "requiredLevel": 5}},
		{"base": "emote_mine", "evolved": "emote_festival", "material": {"type": "accessory", "id": "wide_angle", "requiredLevel": 5}},
		{"base": "ng_word_laser", "evolved": "all_block_laser", "material": {"type": "accessory", "id": "high_speed_connection", "requiredLevel": 5}},
		{"base": "listener_summon", "evolved": "listener_assembly", "material": {"type": "accessory", "id": "notification_bell", "requiredLevel": 5}}
	]
	for case_value in cases:
		var item: Dictionary = case_value as Dictionary
		var base_id := String(item["base"])
		var evolved_id := String(item["evolved"])
		var material: Dictionary = item["material"] as Dictionary
		var base_weapon := _find_data(weapons, base_id)
		var evolution: Dictionary = base_weapon.get("evolution", {}) as Dictionary
		_check(bool(base_weapon.get("evolutionEnabled", false)), "%s regular evolution is active" % base_id, failures)
		_check(String(evolution.get("evolvedWeaponId", "")) == evolved_id, "%s regular target is stable" % base_id, failures)
		_check(int(evolution.get("requiredWeaponLevel", 0)) == 5, "%s regular base requires Lv5" % base_id, failures)
		_check(int(evolution.get("requiredExpLevel", -1)) == 0, "%s regular evolution has no EXP gate" % base_id, failures)
		var requirement_list: Array = evolution.get("additionalRequirements", []) as Array
		_check(requirement_list.size() == 1 and String((requirement_list[0] as Dictionary).get("id", "")) == String(material.get("id", "")) and int((requirement_list[0] as Dictionary).get("requiredLevel", 0)) == 5, "%s regular material is numeric Lv5" % base_id, failures)
		var level_four := _make_target([{"id": base_id, "level": 4}], "other_character", [], weapons)
		_check(not _can_evolve(level_four), "%s base Lv4 fails" % base_id, failures)
		var no_material := _make_target([{"id": base_id, "level": 5}], "other_character", [], weapons)
		_check(not _can_evolve(no_material), "%s Lv5 without material fails" % base_id, failures)
		var material_entry: Array = [{"id": material.get("id", ""), "level": 4}] if String(material.get("type", "")) == "weapon" else []
		var accessories: Array = [{"id": material.get("id", ""), "level": 4}] if String(material.get("type", "")) == "accessory" else []
		var below_required := _make_target([{"id": base_id, "level": 5}] + material_entry, "other_character", accessories, weapons)
		_check(not _can_evolve(below_required), "%s material below Lv5 fails" % base_id, failures)
		if String(material.get("type", "")) == "accessory":
			below_required.player_accessories = [{"id": material.get("id", ""), "level": 5}]
		else:
			below_required.player_weapons[1] = {"id": material.get("id", ""), "level": 5}
		_check(_can_evolve(below_required), "%s Lv5 plus material succeeds" % base_id, failures)
		var evolved_weapon := _find_data(weapons, evolved_id)
		_check(int(evolved_weapon.get("maxLevel", 0)) == 1 and bool(evolved_weapon.get("isEvolved", false)) and not bool(evolved_weapon.get("offerEnabled", true)) and not bool(evolved_weapon.get("giftEnabled", true)) and not bool(evolved_weapon.get("canAppearAsUpgrade", true)), "%s evolved definition is restricted" % evolved_id, failures)

	var spotlight_lineage := _make_target([
		{"id": "spotlight", "level": 5},
		{"id": "full_voice_dome", "level": 1, "isEvolved": true, "baseWeaponId": "mic_barrier"}
	], "other_character", [], weapons)
	_check(_can_evolve(spotlight_lineage), "spotlight accepts full_voice_dome lineage", failures)
	var lockdown_lineage := _make_target([
		{"id": "comment_pin", "level": 5},
		{"id": "all_block_laser", "level": 1, "isEvolved": true, "baseWeaponId": "ng_word_laser"}
	], "other_character", [], weapons)
	_check(_can_evolve(lockdown_lineage), "comment_pin accepts all_block_laser lineage", failures)


func _test_accessory_requirement() -> void:
	var registry := _fixture_registry("mic_barrier", "fixture_mic_evolved", [
		{"type": "accessory", "id": "mini_humidifier", "requiredLevel": 5}
	])
	var no_accessory_target := _make_target([{"id": "mic_barrier", "level": 5}], "any_character", [], registry)
	_check(not _can_evolve(no_accessory_target, registry), "numeric accessory with no ownership fails", failures)
	var target := _make_target([{"id": "mic_barrier", "level": 5}], "any_character", [{"id": "mini_humidifier", "level": 4}], registry)
	_check(not _can_evolve(target, registry), "numeric accessory Lv4 fails", failures)
	target.player_accessories = [{"id": "mini_humidifier", "level": 5}]
	_check(_can_evolve(target, registry), "numeric accessory Lv5 succeeds despite data max3", failures)


func _test_weapon_requirement_and_lineage() -> void:
	var spotlight_registry := _fixture_registry("spotlight", "fixture_spotlight_evolved", [
		{"type": "weapon", "id": "mic_barrier", "requiredLevel": 5}
	], [
		{"id": "full_voice_dome", "equipmentType": "weapon", "maxLevel": 1, "isEvolved": true, "baseWeaponId": "mic_barrier"},
		{"id": "all_block_laser", "equipmentType": "weapon", "maxLevel": 1, "isEvolved": true, "baseWeaponId": "ng_word_laser"}
	])
	var low_spotlight_target := _make_target([
		{"id": "spotlight", "level": 4},
		{"id": "mic_barrier", "level": 5}
	], "any_character", [], spotlight_registry)
	_check(not _can_evolve(low_spotlight_target, spotlight_registry), "spotlight Lv4 fails", failures)
	var direct_target := _make_target([
		{"id": "spotlight", "level": 5},
		{"id": "mic_barrier", "level": 4}
	], "any_character", [], spotlight_registry)
	_check(not _can_evolve(direct_target, spotlight_registry), "direct material Lv4 fails", failures)
	direct_target.player_weapons[1] = {"id": "mic_barrier", "level": 5}
	_check(_can_evolve(direct_target, spotlight_registry), "direct material Lv5 succeeds", failures)

	var evolved_mic_target := _make_target([
		{"id": "spotlight", "level": 5},
		{"id": "full_voice_dome", "level": 1, "isEvolved": true, "baseWeaponId": "mic_barrier"}
	], "any_character", [], spotlight_registry)
	_check(_can_evolve(evolved_mic_target, spotlight_registry), "evolved mic lineage satisfies material", failures)

	var pin_registry := _fixture_registry("comment_pin", "fixture_pin_evolved", [
		{"type": "weapon", "id": "ng_word_laser", "requiredLevel": 5}
	], [
		{"id": "all_block_laser", "equipmentType": "weapon", "maxLevel": 1, "isEvolved": true, "baseWeaponId": "ng_word_laser"}
	])
	var direct_laser_target := _make_target([
		{"id": "comment_pin", "level": 5},
		{"id": "ng_word_laser", "level": 4}
	], "any_character", [], pin_registry)
	_check(not _can_evolve(direct_laser_target, pin_registry), "direct NG laser Lv4 fails", failures)
	direct_laser_target.player_weapons[1] = {"id": "ng_word_laser", "level": 5}
	_check(_can_evolve(direct_laser_target, pin_registry), "direct NG laser Lv5 succeeds", failures)
	var evolved_laser_target := _make_target([
		{"id": "comment_pin", "level": 5},
		{"id": "all_block_laser", "level": 1, "isEvolved": true, "baseWeaponId": "ng_word_laser"}
	], "any_character", [], pin_registry)
	_check(_can_evolve(evolved_laser_target, pin_registry), "evolved NG laser lineage satisfies material", failures)


func _test_evolution_keeps_materials_and_enables_next_candidate() -> void:
	var registry := weapons.duplicate(true)
	_configure_evolution(registry, "spotlight", "fixture_spotlight_evolved", [
		{"type": "weapon", "id": "mic_barrier", "requiredLevel": 5}
	])
	_configure_evolution(registry, "mic_barrier", "fixture_mic_evolved", [
		{"type": "accessory", "id": "mini_humidifier", "requiredLevel": 5}
	])
	registry.append({"id": "fixture_spotlight_evolved", "equipmentType": "weapon", "maxLevel": 1, "isEvolved": true, "baseWeaponId": "spotlight"})
	registry.append({"id": "fixture_mic_evolved", "equipmentType": "weapon", "maxLevel": 1, "isEvolved": true, "baseWeaponId": "mic_barrier"})
	var target := _make_target([
		{"id": "spotlight", "level": 5},
		{"id": "mic_barrier", "level": 5}
	], "any_character", [{"id": "mini_humidifier", "level": 5}], registry)
	var spotlight_gift := WeaponEvolutionSystemScript.evolution_gift_for_target(target, registry)
	var applied := WeaponEvolutionSystemScript.apply_evolution_gift_for_target(target, spotlight_gift)
	_check(not (applied.get("weaponEvolution", {}) as Dictionary).is_empty(), "spotlight evolution applied", failures)
	_check(not EquipmentSystem.find_entry(target.player_weapons, "mic_barrier").is_empty(), "material mic remains after spotlight evolution", failures)
	_check(not EquipmentSystem.find_entry(target.player_weapons, "fixture_spotlight_evolved").is_empty(), "spotlight slot became evolved weapon", failures)
	_check(_has_state_for_base(target, registry, "mic_barrier"), "mic side remains independently evolvable", failures)


func _test_multiple_evolution_gifts() -> void:
	var evolution_gifts: Array = []
	for index in range(4):
		evolution_gifts.append({
			"id": "evolution_fixture_%d" % index,
			"displayName": "fixture",
			"equipmentType": "evolution",
			"effectType": "weapon_evolution",
			"isEvolutionGift": true,
			"baseWeaponId": "fixture_base_%d" % index,
			"evolvedWeaponId": "fixture_evolved_%d" % index
		})
	var context := _gift_context(evolution_gifts, 0)
	var first_offer := GiftSystemScript.build_offer(context)
	_check(first_offer.size() == 3, "evolution cards fill the three priority slots", failures)
	_check(String((first_offer[0] as Dictionary).get("id", "")) == "evolution_fixture_0" and String((first_offer[2] as Dictionary).get("id", "")) == "evolution_fixture_2", "first evolution window follows stable order", failures)
	context["giftsTaken"] = 1
	var rotated_offer := GiftSystemScript.build_offer(context)
	_check(String((rotated_offer[0] as Dictionary).get("id", "")) == "evolution_fixture_1" and String((rotated_offer[2] as Dictionary).get("id", "")) == "evolution_fixture_3", "fourth evolution enters after rotation", failures)


func _test_reroll_keeps_all_evolution_cards() -> void:
	var target := _make_target([], "any_character", [])
	target.gifts = [
		{"id": "normal_a", "displayName": "A", "equipmentType": "weapon", "maxLevel": 5, "weight": 1},
		{"id": "normal_b", "displayName": "B", "equipmentType": "weapon", "maxLevel": 5, "weight": 1}
	]
	target.gift_reroll_remaining = 1
	target.active_gift_request = {"source": "level_up", "giftQuality": "normal", "ppEligible": true, "fieldRandomEligible": false, "fallbackEligible": true}
	var fixed_a := _fake_evolution_gift("fixed_a")
	var fixed_b := _fake_evolution_gift("fixed_b")
	var normal_a := {"id": "normal_a", "displayName": "A", "equipmentType": "weapon", "maxLevel": 5, "weight": 1}
	target.offered_gifts = [fixed_a, fixed_b, normal_a]
	target.gift_reroll_original_offer = target.offered_gifts.duplicate(true)
	target.gift_debug_last = {"validGiftCandidateCount": 2}
	var rng := RandomNumberGenerator.new()
	rng.seed = 90210
	var result := GiftSystemScript.reroll_offer_for_target(target, target.gifts, rng)
	var offer: Array = result.get("offer", []) as Array
	_check(bool(result.get("success", false)), "reroll succeeds with normal replacements available", failures)
	_check(offer.size() == 3 and String((offer[0] as Dictionary).get("id", "")) == "fixed_a" and String((offer[1] as Dictionary).get("id", "")) == "fixed_b", "reroll fixes every displayed evolution card", failures)
	_check(String((offer[2] as Dictionary).get("id", "")) != "normal_a", "reroll changes only the normal slot", failures)


func _test_apply_result_is_level_one_and_not_a_normal_candidate() -> void:
	var target := _make_target([{"id": "ban_hammer", "level": 5}], "ban_chan", [])
	var gift := WeaponEvolutionSystemScript.evolution_gift_for_target(target, weapons)
	var result := WeaponEvolutionSystemScript.apply_evolution_gift_for_target(target, gift)
	var evolved_entry := EquipmentSystem.find_entry(target.player_weapons, "ban_judgement")
	_check(not evolved_entry.is_empty(), "applied evolution entry exists", failures)
	_check(EquipmentSystem.entry_level(evolved_entry, 0) == 1, "applied evolution starts at Lv1", failures)
	_check(int(_find_data(weapons, "ban_judgement").get("maxLevel", 0)) == 1, "evolved data max is Lv1", failures)
	_check(WeaponEvolutionSystemScript.evolution_states_for_target(target, weapons).is_empty(), "evolved entry cannot evolve again", failures)
	_check(not EquipmentSystem.can_offer(target, _find_data(weapons, "ban_judgement"), 0.0), "evolved entry is not a normal candidate", failures)
	_check(not (result.get("weaponEvolution", {}) as Dictionary).is_empty(), "apply result reports selected pair", failures)


func _test_evolution_gift_marker_types() -> void:
	_check(WeaponEvolutionSystemScript.is_evolution_gift({"evolution": {"evolvedWeaponId": "fixture_evolved"}}), "dictionary evolution marker is classified safely", failures)
	_check(not WeaponEvolutionSystemScript.is_evolution_gift({"evolution": {}}), "empty evolution dictionary is not classified as a gift", failures)
	_check(WeaponEvolutionSystemScript.is_evolution_gift({"isEvolutionGift": true}), "boolean evolution marker remains supported", failures)
	var fansa_baton := _find_data(weapons, "fansa_baton")
	_check(not WeaponEvolutionSystemScript.is_evolution_gift(fansa_baton), "base weapon evolution configuration is not a gift", failures)
	_check(GiftSystemScript.gift_level_gain(fansa_baton) == 1, "base weapon keeps its normal gift level gain", failures)
	var fansa_target := _make_target([{"id": "fansa_baton", "level": 5}], "akarine_rizumu", [])
	var fansa_gift := WeaponEvolutionSystemScript.evolution_gift_for_target(fansa_target, weapons)
	_check(String(fansa_gift.get("evolvedWeaponId", "")) == "fansa_climax", "fansa baton evolution gift targets fansa climax", failures)
	_check(String(fansa_gift.get("displayName", "")) == String(_find_data(weapons, "fansa_climax").get("displayName", "")), "fansa evolution card uses evolved display name", failures)


func _test_debug_evolution_gift_command() -> void:
	_check(DebugSystemScript.EVOLUTION_GIFT_KEY == KEY_G and DebugSystemScript.EVOLUTION_GIFT_MODIFIER_KEY == KEY_SHIFT, "debug evolution command is bound to Shift+G", failures)
	_check(DebugSystemScript.should_start_evolution_gift("gift_evolution"), "debug evolution action is recognized", failures)
	var expected_ids: Array[String] = [
		"ban_judgement",
		"starlight_superchat",
		"maro_comment_ring",
		"full_voice_dome",
		"center_stage",
		"great_grassland",
		"comment_lockdown",
		"emote_festival",
		"all_block_laser",
		"listener_assembly",
		"moderator_fortress",
		"fansa_climax",
		"buzz_thumbnail_rod"
	]
	var target := _make_target([{"id": "ban_hammer", "level": 1}], "other_character", [])
	_check(WeaponEvolutionSystemScript.evolution_gift_for_target(target, weapons).is_empty(), "normal evolution still rejects a low-level base weapon", failures)
	var catalog: Array = WeaponEvolutionSystemScript.debug_evolution_gifts_for_target(target, weapons)
	var actual_ids: Array[String] = []
	for gift_value in catalog:
		var gift: Dictionary = gift_value as Dictionary
		actual_ids.append(String(gift.get("evolvedWeaponId", "")))
		_check(bool(gift.get("debugForceEvolution", false)), "every debug evolution candidate carries the debug marker", failures)
	_check(actual_ids == expected_ids, "debug evolution catalog contains all 13 weapons in data order", failures)

	var first_page: Dictionary = DebugSystemScript.force_evolution_choice_for_target(target, weapons, 0)
	var first_offer: Array = first_page.get("offer", []) as Array
	_check(bool(first_page.get("applied", false)) and first_offer.size() == 3, "debug evolution opens a three-card gift page", failures)
	_check(String((first_offer[0] as Dictionary).get("evolvedWeaponId", "")) == expected_ids[0] and String((first_offer[2] as Dictionary).get("evolvedWeaponId", "")) == expected_ids[2], "first debug evolution page follows catalog order", failures)
	_check(target.state == "gift_choice" and target.pause_reasons.has("GiftSelection"), "debug evolution page uses the paused gift-choice state", failures)
	var second_page: Dictionary = DebugSystemScript.force_evolution_choice_for_target(target, weapons, int(first_page.get("nextPageStart", 0)))
	var second_offer: Array = second_page.get("offer", []) as Array
	_check(second_offer.size() == 3 and String((second_offer[0] as Dictionary).get("evolvedWeaponId", "")) == expected_ids[3], "debug evolution page control advances to the next three weapons", failures)
	var final_page: Dictionary = DebugSystemScript.force_evolution_choice_for_target(target, weapons, 12)
	var final_offer: Array = final_page.get("offer", []) as Array
	_check(final_offer.size() == 1 and String((final_offer[0] as Dictionary).get("evolvedWeaponId", "")) == expected_ids[12], "final debug evolution page exposes the thirteenth weapon", failures)
	_check(int(final_page.get("nextPageStart", -1)) == 0, "debug evolution page control wraps to the first page", failures)

	var replace_target := _make_target([{"id": "ban_hammer", "level": 1}], "other_character", [])
	var ban_gift := _find_debug_evolution_gift(WeaponEvolutionSystemScript.debug_evolution_gifts_for_target(replace_target, weapons), "ban_judgement")
	var replace_result: Dictionary = WeaponEvolutionSystemScript.apply_evolution_gift_for_target(replace_target, ban_gift)
	var ban_entry := EquipmentSystem.find_entry(replace_target.player_weapons, "ban_judgement")
	_check(replace_target.player_weapons.size() == 1 and not ban_entry.is_empty(), "debug evolution replaces an owned base weapon in the same slot", failures)
	_check(EquipmentSystem.entry_level(ban_entry, 0) == 1 and EquipmentSystem.is_evolved_entry(ban_entry), "debug evolution grants an evolved Lv1 entry", failures)
	_check(replace_target.current_weapon_id == "ban_judgement" and bool((replace_result.get("weaponEvolution", {}) as Dictionary).get("debugForced", false)), "debug replacement updates the active main weapon and reports its source", failures)

	var append_target := _make_target([{"id": "ban_hammer", "level": 1}], "other_character", [])
	var center_gift := _find_debug_evolution_gift(WeaponEvolutionSystemScript.debug_evolution_gifts_for_target(append_target, weapons), "center_stage")
	WeaponEvolutionSystemScript.apply_evolution_gift_for_target(append_target, center_gift)
	var center_entry := EquipmentSystem.find_entry(append_target.player_weapons, "center_stage")
	_check(append_target.player_weapons.size() == 2 and not center_entry.is_empty(), "debug evolution adds an evolved weapon to an empty slot when its base is absent", failures)
	_check(String(center_entry.get("baseWeaponId", "")) == "spotlight" and EquipmentSystem.entry_level(center_entry, 0) == 1, "debug-added evolution retains its base lineage and Lv1", failures)

	var full_target := _make_target([
		{"id": "ban_hammer", "level": 1},
		{"id": "superchat_shot", "level": 1},
		{"id": "comment_boomerang", "level": 1},
		{"id": "kusa_wave", "level": 1},
		{"id": "comment_pin", "level": 1}
	], "other_character", [])
	var full_catalog: Array = WeaponEvolutionSystemScript.debug_evolution_gifts_for_target(full_target, weapons)
	_check(_find_debug_evolution_gift(full_catalog, "center_stage").is_empty(), "a full weapon inventory does not offer an evolution whose base slot is absent", failures)
	_check(not _find_debug_evolution_gift(full_catalog, "ban_judgement").is_empty(), "a full weapon inventory still offers safe same-slot evolution replacements", failures)


func _make_target(entries: Array, character_id: String, accessories: Array, registry: Array = []) -> Node:
	var target := TestTargetScript.new()
	target.weapons = weapons if registry.is_empty() else registry
	target.gifts = gifts.duplicate(true)
	target.player_weapons = entries.duplicate(true)
	target.player_accessories = accessories.duplicate(true)
	target.current_character_id = character_id
	var first_id := String((entries[0] as Dictionary).get("id", "")) if not entries.is_empty() else ""
	target.current_character = {"id": character_id, "initialWeapon": first_id}
	target.current_weapon_id = first_id
	target.current_weapon = WeaponSystem.find_weapon(target.weapons, first_id, {})
	target.current_stream_frame = {"giftPoolTags": ["default"]}
	target.exp_level = 1
	target.gift_hype = 0
	target.max_gift_hype = 0
	target.run_difficulty_id = "normal"
	target.gifts_taken = 0
	target.enemies = []
	target.hit_fx = []
	target.equipment_weapon_timers = {}
	target.boomerang_hits = {}
	return target


func _fixture_registry(base_id: String, evolved_id: String, requirements: Array, extra_defs: Array = []) -> Array:
	var registry := weapons.duplicate(true)
	_configure_evolution(registry, base_id, evolved_id, requirements)
	registry.append({"id": evolved_id, "equipmentType": "weapon", "maxLevel": 1, "isEvolved": true, "baseWeaponId": base_id})
	for item in extra_defs:
		registry.append((item as Dictionary).duplicate(true))
	return registry


func _configure_evolution(registry: Array, base_id: String, evolved_id: String, requirements: Array) -> void:
	for index in range(registry.size()):
		var item: Dictionary = registry[index] as Dictionary
		if String(item.get("id", "")) != base_id:
			continue
		item["evolutionEnabled"] = true
		item["evolution"] = {
			"evolvedWeaponId": evolved_id,
			"requiredWeaponLevel": 5,
			"requiredExpLevel": 0,
			"additionalRequirements": requirements.duplicate(true)
		}
		registry[index] = item
		return


func _gift_context(evolution_gifts: Array, normal_count: int) -> Dictionary:
	var normal_gifts: Array = []
	var available_ids: Array = []
	for index in range(normal_count):
		var id := "normal_fixture_%d" % index
		var gift := {"id": id, "displayName": id, "equipmentType": "weapon", "maxLevel": 5, "weight": 1}
		normal_gifts.append(gift)
		available_ids.append(id)
	var rng := RandomNumberGenerator.new()
	rng.seed = 1234
	return {
		"rng": rng,
		"gifts": normal_gifts,
		"availableIds": available_ids,
		"streamFrame": {"giftPoolTags": ["default"]},
		"giftHype": 0,
		"giftTime": 0.0,
		"playerWeapons": [],
		"playerAccessories": [],
		"weaponRegistry": [],
		"currentCharacter": {},
		"evolutionGifts": evolution_gifts,
		"evolutionGift": {},
		"giftsTaken": 0,
		"giftRequest": {"source": "level_up", "giftQuality": "normal", "ppEligible": true, "fieldRandomEligible": false, "fallbackEligible": true},
		"directPpConfig": {"enabled": true, "amountByQuality": {"normal": 5, "hit": 10, "jackpot": 15}, "maxPpOptions": 1},
		"maxPpOptions": 1
	}


func _fake_evolution_gift(id: String) -> Dictionary:
	return {
		"id": id,
		"displayName": id,
		"equipmentType": "evolution",
		"effectType": "weapon_evolution",
		"isEvolutionGift": true,
		"baseWeaponId": id + "_base",
		"evolvedWeaponId": id + "_evolved"
	}


func _find_data(data: Array, id: String) -> Dictionary:
	for item in data:
		var entry: Dictionary = item as Dictionary
		if String(entry.get("id", "")) == id:
			return entry
	return {}


func _find_debug_evolution_gift(data: Array, evolved_id: String) -> Dictionary:
	for item in data:
		var gift: Dictionary = item as Dictionary
		if String(gift.get("evolvedWeaponId", "")) == evolved_id:
			return gift
	return {}


func _can_evolve(target: Node, registry: Array = []) -> bool:
	var data := weapons if registry.is_empty() else registry
	return bool(WeaponEvolutionSystemScript.evolution_state_for_target(target, data).get("canEvolve", false))


func _has_state_for_base(target: Node, registry: Array, base_id: String) -> bool:
	for state_value in WeaponEvolutionSystemScript.evolution_states_for_target(target, registry):
		if String((state_value as Dictionary).get("baseWeaponId", "")) == base_id:
			return true
	return false


func _check(condition: bool, label: String, output: Array[String]) -> void:
	if not condition:
		output.append(label)
