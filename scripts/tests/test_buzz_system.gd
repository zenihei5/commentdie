extends Node

const BuzzSystemScript := preload("res://scripts/systems/buzz_system.gd")
const ModifierSystemScript := preload("res://scripts/systems/modifier_system.gd")
const DamageSystemScript := preload("res://scripts/systems/damage_system.gd")
const ScoreSystemScript := preload("res://scripts/systems/score_system.gd")
const ResultSystemScript := preload("res://scripts/systems/result_system.gd")
const ChoiceCardSystemScript := preload("res://scripts/systems/choice_card_system.gd")

var failures: Array[String] = []

func _ready() -> void:
	_run_tests()
	if failures.is_empty():
		print("BUZZ_SYSTEM_TESTS: PASS")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("BUZZ_SYSTEM_TESTS: FAIL (%d)" % failures.size())
	get_tree().quit(1)

func _run_tests() -> void:
	_check_equal("risk 0 gain", BuzzSystemScript.gain_for_risk(0), 5)
	_check_equal("risk 1 gain", BuzzSystemScript.gain_for_risk(1), 5)
	_check_equal("risk 2 gain", BuzzSystemScript.gain_for_risk(2), 10)
	_check_equal("risk 3 gain", BuzzSystemScript.gain_for_risk(3), 10)
	_check_equal("risk 4 gain", BuzzSystemScript.gain_for_risk(4), 20)
	_check_equal("risk 5 gain", BuzzSystemScript.gain_for_risk(5), 20)
	var relay_instruction: Dictionary = BuzzSystemScript.instruction_transition(0, 0, 1)
	_check_equal("relay default risk adds once", relay_instruction["buzzDelta"], 5)
	_check_equal("relay default risk after", relay_instruction["buzzAfter"], 5)
	_check(ChoiceCardSystemScript.buzz_gain_text(0).contains("+5%"), "risk 0 card displays +5%")
	_check(ChoiceCardSystemScript.buzz_gain_text(3).contains("+10%"), "risk 3 card displays +10%")
	_check(ChoiceCardSystemScript.buzz_gain_text(4).contains("+20%"), "risk 4 card displays +20%")
	_check_equal("clamp 95 plus 20", BuzzSystemScript.clamp_percent(95 + 20), 100)
	_check_equal("clamp 100 plus 20", BuzzSystemScript.clamp_percent(100 + 20), 100)
	_check_equal("damage 100", BuzzSystemScript.damage_transition(100, 0)["buzzAfter"], 95)
	_check_equal("damage 20", BuzzSystemScript.damage_transition(20, 0)["buzzAfter"], 15)
	_check_equal("damage 5", BuzzSystemScript.damage_transition(5, 0)["buzzAfter"], 0)
	_check_equal("damage 0", BuzzSystemScript.damage_transition(0, 2)["buzzAfter"], 0)
	_check_equal("buzz zero keeps charge", BuzzSystemScript.damage_transition(0, 2)["burnResistChargesAfter"], 2)
	var protected: Dictionary = BuzzSystemScript.damage_transition(20, 2)
	_check_equal("protected keeps buzz", protected["buzzAfter"], 20)
	_check_equal("protected consumes one charge", protected["burnResistChargesAfter"], 1)
	_check(bool(protected["buzzProtected"]), "protected feedback")
	var invalid: Dictionary = BuzzSystemScript.damage_transition(20, 2, false)
	_check_equal("invalid hit keeps buzz", invalid["buzzAfter"], 20)
	_check_equal("invalid hit keeps charge", invalid["burnResistChargesAfter"], 2)
	var formal_hit: Dictionary = DamageSystemScript.apply_hit({"playerHp": 100, "damage": 1, "burnCombo": 20, "burnResistCharges": 1, "giftHype": 0, "reviveAvailable": false})
	_check_equal("formal hit preserves buzz with charge", formal_hit["burnCombo"], 20)
	_check_equal("formal hit consumes charge", formal_hit["burnResistCharges"], 0)
	var zero_hit: Dictionary = DamageSystemScript.apply_hit({"playerHp": 100, "damage": 0, "burnCombo": 20, "burnResistCharges": 1, "giftHype": 0, "reviveAvailable": false})
	_check_equal("zero damage keeps buzz", zero_hit["burnCombo"], 20)
	_check_equal("zero damage keeps charge", zero_hit["burnResistCharges"], 1)
	_check_approx("score multiplier 0", BuzzSystemScript.score_multiplier(0), 1.0)
	_check_approx("score multiplier 5", BuzzSystemScript.score_multiplier(5), 1.05)
	_check_approx("score multiplier 50", BuzzSystemScript.score_multiplier(50), 1.5)
	_check_approx("score multiplier 80", BuzzSystemScript.score_multiplier(80), 1.8)
	_check_approx("score multiplier 100", BuzzSystemScript.score_multiplier(100), 2.0)
	_check(not BuzzSystemScript.is_high(75), "75 is not high buzz")
	_check(BuzzSystemScript.is_high(80), "80 is high buzz")
	_check_equal("result points 0", BuzzSystemScript.result_points(0), 0)
	_check_equal("result points 10", BuzzSystemScript.result_points(10), 5)
	_check_equal("result points 20", BuzzSystemScript.result_points(20), 10)
	_check_equal("result points 55", BuzzSystemScript.result_points(55), 28)
	_check_equal("result points 80", BuzzSystemScript.result_points(80), 40)
	_check_equal("result points 100", BuzzSystemScript.result_points(100), 50)
	var view := {"multiplier": 1.0, "riskLevel": 4, "giftHypeOnSelect": 0, "giftHypeOnClear": 0}
	var numbers: Dictionary = ModifierSystemScript.apply_choice_numbers({"view": view, "burnCombo": 95, "burnComboMax": 95, "dangerCommentsChosen": 0, "yesListener": false, "giftHype": 0, "maxGiftHype": 0})
	_check_equal("normal instruction clamps once", numbers["burnCombo"], 100)
	_check_equal("normal instruction actual gain", numbers["buzzDelta"], 5)
	_check(bool(numbers["buzzReachedMax"]), "normal instruction max transition")
	var already_max: Dictionary = ModifierSystemScript.apply_choice_numbers({"view": view, "burnCombo": 100, "burnComboMax": 100, "dangerCommentsChosen": 0, "yesListener": false, "giftHype": 0, "maxGiftHype": 0})
	_check_equal("max remains clamped", already_max["burnCombo"], 100)
	_check(not bool(already_max["buzzReachedMax"]), "max transition does not repeat")
	_check_equal("normal result uses buzz points", ResultSystemScript.calculate_kami_point({"maxBurnCombo": 55}), 36)
	_check_equal("score system uses percent multiplier", ScoreSystemScript.enemy_score({"score": 100, "scoreMultiplier": 1.0}, {"burnCombo": 50}), 150)

func _check(condition: bool, label: String) -> void:
	if not condition:
		failures.append(label)

func _check_equal(label: String, actual: Variant, expected: Variant) -> void:
	_check(actual == expected, "%s: got %s expected %s" % [label, str(actual), str(expected)])

func _check_approx(label: String, actual: float, expected: float) -> void:
	_check(is_equal_approx(actual, expected), "%s: got %.4f expected %.4f" % [label, actual, expected])
