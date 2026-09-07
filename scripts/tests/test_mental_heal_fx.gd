extends Node

const DrawDataSystemScript := preload("res://scripts/systems/draw_data_system.gd")

var failures: Array[String] = []

func _ready() -> void:
	var config: Dictionary = DrawDataSystemScript.mental_heal_fx_config()
	_check("configured lifetime is visible", is_equal_approx(float(config.get("life", 0.0)), 0.95))
	_check("configured outer radius reaches about 80", is_equal_approx(float(config.get("baseRadius", 0.0)) + float(config.get("expandRadius", 0.0)), 80.0))
	_check("configured particle count", int(config.get("particleCount", 0)) == 10)
	_check("configured ring width is visible", is_equal_approx(float(config.get("ringWidth", 0.0)), 4.5))
	_check("configured inner ring width is visible", is_equal_approx(float(config.get("innerRingWidth", 0.0)), 2.5))

	var data: Dictionary = DrawDataSystemScript.mental_heal_fx_data(Vector2(120.0, 80.0), 0.95, 0.95, 1)
	_check("data kind", String(data.get("kind", "")) == "mental_heal")
	_check("data amount", int(data.get("amount", 0)) == 1)
	var expanded_data: Dictionary = DrawDataSystemScript.mental_heal_fx_data(Vector2(120.0, 80.0), 0.0, 0.95, 1)
	_check("expanded ring reaches about 80", is_equal_approx(float(expanded_data.get("ringRadius", 0.0)), 80.0))
	_check("plus one label is explicit", String(data.get("labelText", "")) == "メンタル +1")
	_check("label is readable", int(data.get("labelSize", 0)) >= 22 and int(data.get("labelWidth", 0)) >= 160)
	_check("label outline is 2 to 3 px", float(data.get("labelOutlineWidth", 0.0)) >= 2.0 and float(data.get("labelOutlineWidth", 0.0)) <= 3.0)
	_check("label outline is dark green", (data.get("labelOutlineColor", Color.BLACK) as Color).g > (data.get("labelOutlineColor", Color.BLACK) as Color).r)
	_check("data ring width comes from config", is_equal_approx(float(data.get("ringWidth", 0.0)), float(config.get("ringWidth", 0.0))))
	_check("data particle width comes from config", is_equal_approx(float(data.get("particleWidth", 0.0)), float(config.get("particleWidth", 0.0))))

	var parts: Array = DrawDataSystemScript.hit_fx_parts(data)
	_check("primitive parts exist", parts.size() >= 5)
	_check("particles are present", parts.filter(func(part: Dictionary) -> bool: return String(part.get("kind", "")) == "line").size() == int(config.get("particleCount", 10)) * 2)
	var draw_data: Array = DrawDataSystemScript.hit_fx_draw_data([{
		"kind": "mental_heal",
		"pos": Vector2(120.0, 80.0),
		"life": 0.95,
		"maxLife": 0.95,
		"amount": 1
	}])
	_check("draw data is emitted", not draw_data.is_empty() and String((draw_data[0] as Dictionary).get("kind", "")) == "mental_heal")
	_check("actual one point heal is detected", DrawDataSystemScript.actual_mental_heal_amount(100, 101) == 1)
	_check("full health produces no heal", DrawDataSystemScript.actual_mental_heal_amount(100, 100) == 0)
	_check("downward assignment produces no heal", DrawDataSystemScript.actual_mental_heal_amount(101, 100) == 0)
	_check("active heal aggregates", DrawDataSystemScript.aggregate_mental_heal_amount(1, 2) == 3)
	_check("non-positive addition cannot create feedback", DrawDataSystemScript.aggregate_mental_heal_amount(1, -2) == 1)
	_check("zero amount has no label", String(DrawDataSystemScript.mental_heal_fx_data(Vector2.ZERO, 0.95, 0.95, 0).get("labelText", "")) == "")
	_check("HUD pulse starts and ends at zero", is_zero_approx(DrawDataSystemScript.mental_heal_hud_pulse_alpha(0.45)) and is_zero_approx(DrawDataSystemScript.mental_heal_hud_pulse_alpha(0.0)))
	_check("HUD pulse peaks during feedback", DrawDataSystemScript.mental_heal_hud_pulse_alpha(0.225) > 0.99)

	if failures.is_empty():
		print("MENTAL_HEAL_FX_TESTS: PASS")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("MENTAL_HEAL_FX_TESTS: FAIL (%d)" % failures.size())
	get_tree().quit(1)

func _check(label: String, condition: bool) -> void:
	if not condition:
		failures.append(label)
