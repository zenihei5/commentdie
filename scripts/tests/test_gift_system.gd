extends Node

const GiftSystemScript := preload("res://scripts/systems/gift_system.gd")
const ChoiceCardSystemScript := preload("res://scripts/systems/choice_card_system.gd")
const TrackerScript := preload("res://scripts/systems/power_up_run_tracker.gd")
const RewardCalculatorScript := preload("res://scripts/systems/stream_point_reward_calculator.gd")

var failures: Array[String] = []

func _ready() -> void:
	_test_quality_and_amounts()
	_test_candidate_counts()
	_test_initial_weapon_fixed_offer_rate()
	_test_variable_choice_cards()
	_test_direct_pp_dedup_and_result()
	if failures.is_empty():
		print("GIFT_SYSTEM_TESTS: PASS")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("GIFT_SYSTEM_TESTS: FAIL (%d)" % failures.size())
	get_tree().quit(1)

func _test_quality_and_amounts() -> void:
	_check_equal("big_hit aliases jackpot", GiftSystemScript.normalize_gift_quality("big_hit"), "jackpot")
	_check_equal("unknown quality falls back", GiftSystemScript.normalize_gift_quality("mystery"), "normal")
	var context := _context(3, {"giftQuality": "jackpot"})
	_check_equal("jackpot PP amount", GiftSystemScript.pp_amount_for_context(context), 15)
	context["giftRequest"] = {"giftQuality": "hit"}
	_check_equal("hit PP amount", GiftSystemScript.pp_amount_for_context(context), 10)
	context["giftRequest"] = {"giftQuality": "normal"}
	_check_equal("normal PP amount", GiftSystemScript.pp_amount_for_context(context), 5)

func _test_candidate_counts() -> void:
	var normal := GiftSystemScript.build_offer(_context(3, {"fieldRandomEligible": false}))
	_check_equal("three candidates keep three equipment cards", normal.size(), 3)
	_check(not _contains_pp(normal), "three candidates do not add PP without field roll")
	var field_context := _context(3, {"fieldRandomEligible": true})
	(field_context["directPpConfig"] as Dictionary)["fieldOptionChance"] = {"normal": 1.0, "hard": 1.0, "expert": 1.0}
	var field_offer := GiftSystemScript.build_offer(field_context)
	_check_equal("field random keeps three total options", field_offer.size(), 3)
	_check(_contains_pp(field_offer), "field random creates PP option")
	_check_equal("field random has one PP", _pp_count(field_offer), 1)
	var two := GiftSystemScript.build_offer(_context(2, {"fieldRandomEligible": false}))
	_check_equal("two candidates add fallback PP", two.size(), 3)
	_check_equal("two candidate PP count", _pp_count(two), 1)
	var one := GiftSystemScript.build_offer(_context(1, {"fieldRandomEligible": false}))
	_check_equal("one candidate fills all three options", one.size(), 3)
	_check_equal("one candidate PP count", _pp_count(one), 1)
	_check_equal("one candidate instant fallback count", _instant_fallback_count(one), 1)
	_check(_unique_ids(one), "one candidate fallback does not duplicate IDs")
	var evolution_context := _context(0, {"fieldRandomEligible": false})
	evolution_context["evolutionGift"] = {"id": "test_evolution", "displayName": "test evolution", "isEvolution": true, "evolution": true}
	var evolution_only := GiftSystemScript.build_offer(evolution_context)
	_check_equal("evolution-only offer fills all three options", evolution_only.size(), 3)
	_check_equal("evolution-only offer has one PP", _pp_count(evolution_only), 1)
	_check_equal("evolution-only offer has one instant fallback", _instant_fallback_count(evolution_only), 1)
	var zero := GiftSystemScript.build_offer(_context(0, {"fieldRandomEligible": false}))
	_check_equal("zero candidates keep exhausted three-choice UI", zero.size(), 3)
	_check(_all_exhausted_ids(zero), "zero candidates use only instant pool and PP")
	_check(_unique_ids(zero), "zero candidates do not duplicate IDs")
	var no_pp := GiftSystemScript.build_offer(_context(0, {"fieldRandomEligible": false, "ppEligible": false}))
	_check_equal("pp-ineligible exhausted offer keeps three instant cards", no_pp.size(), 3)
	_check(not _contains_pp(no_pp), "pp-ineligible exhausted offer has no PP card")

func _test_initial_weapon_fixed_offer_rate() -> void:
	var context := _context(20, {"fieldRandomEligible": false})
	var initial_id := "test_weapon_0"
	context["initialWeaponId"] = initial_id
	context["currentCharacter"] = {
		"id": "test_character",
		"initialWeapon": initial_id,
		"initialWeaponGiftChance": 1.0
	}
	var guaranteed_offer := GiftSystemScript.build_offer(context)
	_check(_contains_id(guaranteed_offer, initial_id), "100% initial weapon chance guarantees an offer")
	(context["currentCharacter"] as Dictionary)["initialWeaponGiftChance"] = 0.0
	var excluded_offer := GiftSystemScript.build_offer(context)
	_check(not _contains_id(excluded_offer, initial_id), "failed initial weapon roll cannot leak through the normal pool")
	(context["currentCharacter"] as Dictionary)["initialWeaponGiftChance"] = 0.20
	var rate_rng := RandomNumberGenerator.new()
	rate_rng.seed = 20260805
	context["rng"] = rate_rng
	var trials := 5000
	var hits := 0
	for _trial in range(trials):
		if _contains_id(GiftSystemScript.build_offer(context), initial_id):
			hits += 1
	var observed_rate := float(hits) / float(trials)
	_check(absf(observed_rate - 0.20) <= 0.02, "initial weapon offer rate stays near 20 percent (observed %.3f)" % observed_rate)

func _test_variable_choice_cards() -> void:
	var one_candidate_offer := GiftSystemScript.build_offer(_context(1, {"fieldRandomEligible": false}))
	var cards := ChoiceCardSystemScript.gift_cards(one_candidate_offer, {})
	_check_equal("one candidate produces three rendered cards", cards.size(), 3)
	var pp_card: Dictionary = {}
	for card_value in cards:
		var card: Dictionary = card_value as Dictionary
		if String(card.get("styleKey", "")) == "gift_pp":
			pp_card = card
			break
	_check_equal("PP card uses transparent gift button style", String(pp_card.get("styleKey", "")), "gift_pp")
	_check(String(pp_card.get("text", "")).contains("パワーアップポイント"), "PP card has a visible title")
	_check(String(pp_card.get("text", "")).contains("PP"), "PP card has visible reward text")
	var buttons: Array = [Button.new(), Button.new(), Button.new()]
	for button in buttons:
		(button as Button).visible = true
	ChoiceCardSystemScript.refresh_buttons(buttons, cards, 0)
	_check((buttons[0] as Button).visible, "first live gift button stays visible")
	_check((buttons[1] as Button).visible, "second live gift button stays visible")
	_check((buttons[2] as Button).visible, "fallback gift button fills the third slot")
	_check(not (buttons[2] as Button).disabled, "fallback gift button can be selected")

func _test_direct_pp_dedup_and_result() -> void:
	var tracker = TrackerScript.start(true, 0, true)
	var first: Dictionary = tracker.grant_direct_pp(5, "field_random", "reward:1")
	var duplicate: Dictionary = tracker.grant_direct_pp(5, "field_random", "reward:1")
	tracker.grant_direct_pp(10, "candidate_fallback", "reward:2")
	tracker.grant_direct_pp(15, "full_build_conversion", "reward:3")
	_check(bool(first.get("granted", false)), "first direct PP is granted")
	_check(not bool(duplicate.get("granted", false)), "same reward ID is deduplicated")
	_check_equal("direct PP subtotal", tracker.direct_pp_subtotal(), 30)
	var reward = RewardCalculatorScript.calculate({
		"rewardEligible": true,
		"outcome": "defeated",
		"isRelay": false,
		"activePlaySeconds": 0.0,
		"fieldGiftPp": 5,
		"fallbackGiftPp": 10,
		"fullBuildConversionPp": 15,
		"difficultyMultiplier": 0.60
	})
	_check_equal("direct PP is outside difficulty multiplier", reward.direct_pp_subtotal, 30)
	_check_equal("direct PP enters total", reward.total_pp, reward.repeatable_subtotal + reward.one_time_subtotal + 30)

func _context(count: int, request_overrides: Dictionary) -> Dictionary:
	var gifts: Array = []
	var ids: Array = []
	for i in range(count):
		var id := "test_weapon_%d" % i
		ids.append(id)
		gifts.append({
			"id": id,
			"displayName": id,
			"equipmentType": "weapon",
			"maxLevel": 5,
			"levelStats": [],
			"weight": 1,
			"tags": ["default"]
		})
	var instant_gifts: Array = [
		{"id": "rest", "displayName": "休憩", "description": "メンタルを回復", "equipmentType": "instant", "maxLevel": 0, "effectType": "heal", "weight": 1},
		{"id": "heart_mark", "displayName": "♡", "description": "次の指示コメを甘くする", "equipmentType": "instant", "maxLevel": 0, "effectType": "add_heart_stock", "weight": 1},
		{"id": "viewer_burst", "displayName": "視聴者急増", "description": "同時視聴者数 +800", "equipmentType": "instant", "maxLevel": 0, "effectType": "viewer_burst", "weight": 1}
	]
	for gift in instant_gifts:
		gifts.append(gift)
		ids.append(String(gift["id"]))
	var request := {"source": "level_up", "giftQuality": "normal", "ppEligible": true, "fieldRandomEligible": false, "fallbackEligible": true, "rewardId": "test:reward"}
	for key in request_overrides.keys():
		request[key] = request_overrides[key]
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	return {
		"rng": rng,
		"gifts": gifts,
		"availableIds": ids,
		"streamFrame": {"giftPoolTags": ["default"]},
		"giftHype": 0,
		"giftTime": 0.0,
		"playerWeapons": [],
		"playerAccessories": [],
		"weaponRegistry": [],
		"currentCharacter": {},
		"evolutionGift": {},
		"giftRequest": request,
		"difficultyId": "normal",
		"directPpConfig": {
			"enabled": true,
			"amountByQuality": {"normal": 5, "hit": 10, "jackpot": 15},
			"difficultyRate": {"normal": 1.0, "hard": 1.0, "expert": 1.0},
			"fieldOptionChance": {"normal": 0.10, "hard": 0.10, "expert": 0.10},
			"maxPpOptions": 1
		},
		"maxPpOptions": 1
	}

func _contains_pp(offer: Array) -> bool:
	return _pp_count(offer) > 0

func _contains_id(offer: Array, wanted_id: String) -> bool:
	for value in offer:
		if String((value as Dictionary).get("id", "")) == wanted_id:
			return true
	return false

func _pp_count(offer: Array) -> int:
	var count := 0
	for value in offer:
		var gift: Dictionary = value as Dictionary
		if String(gift.get("type", gift.get("category", ""))) == "pp":
			count += 1
	return count

func _instant_fallback_count(offer: Array) -> int:
	var count := 0
	for value in offer:
		var id := String((value as Dictionary).get("id", ""))
		if id in ["rest", "heart_mark", "viewer_burst"]:
			count += 1
	return count

func _unique_ids(offer: Array) -> bool:
	var ids: Array[String] = []
	for value in offer:
		var id := String((value as Dictionary).get("id", ""))
		if id == "" or ids.has(id):
			return false
		ids.append(id)
	return true

func _all_exhausted_ids(offer: Array) -> bool:
	for value in offer:
		var id := String((value as Dictionary).get("id", ""))
		if id not in ["rest", "heart_mark", "viewer_burst", "direct_pp"]:
			return false
	return true

func _check(condition: bool, label: String) -> void:
	if not condition:
		failures.append(label)

func _check_equal(label: String, actual: Variant, expected: Variant) -> void:
	if actual != expected:
		failures.append("%s: got %s expected %s" % [label, str(actual), str(expected)])
