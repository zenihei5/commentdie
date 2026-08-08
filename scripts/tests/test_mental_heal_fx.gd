extends Node

const DrawDataSystemScript := preload("res://scripts/systems/draw_data_system.gd")

var failures: Array[String] = []

func _ready() -> void:
	var config: Dictionary = DrawDataSystemScript.mental_heal_fx_config()
	_check("configured lifetime", is_equal_approx(float(config.get("life", 0.0)), 0.68))
	_check("configured particle count", int(config.get("particleCount", 0)) == 8)

	var data: Dictionary = DrawDataSystemScript.mental_heal_fx_data(Vector2(120.0, 80.0), 0.68, 0.68, 7)
	_check("data kind", String(data.get("kind", "")) == "mental_heal")
	_check("data amount", int(data.get("amount", 0)) == 7)
	_check("data ring width comes from config", is_equal_approx(float(data.get("ringWidth", 0.0)), float(config.get("ringWidth", 0.0))))
	_check("data particle width comes from config", is_equal_approx(float(data.get("particleWidth", 0.0)), float(config.get("particleWidth", 0.0))))

	var parts: Array = DrawDataSystemScript.hit_fx_parts(data)
	_check("primitive parts exist", parts.size() >= 5)
	_check("particles are present", parts.filter(func(part: Dictionary) -> bool: return String(part.get("kind", "")) == "line").size() == int(config.get("particleCount", 8)) * 2)
	var draw_data: Array = DrawDataSystemScript.hit_fx_draw_data([{
		"kind": "mental_heal",
		"pos": Vector2(120.0, 80.0),
		"life": 0.68,
		"maxLife": 0.68,
		"amount": 7
	}])
	_check("draw data is emitted", not draw_data.is_empty() and String((draw_data[0] as Dictionary).get("kind", "")) == "mental_heal")

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
