extends Node

const ComboSystem := preload("res://scripts/systems/collab_combo_system.gd")

func _ready() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var failures: Array[String] = []
	var characters: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/characters.json")) as Array
	var registry: Dictionary = ComboSystem.registry()
	_check(characters.size() == 6, "expected six characters", failures)
	var ids: Array[String] = []
	for item in characters:
		ids.append(String((item as Dictionary).get("id", "")))
	var dedicated_count := 0
	var composite_count := 0
	for first_index in range(ids.size()):
		for second_index in range(first_index + 1, ids.size()):
			var first_id := ids[first_index]
			var second_id := ids[second_index]
			var forward := ComboSystem.resolve_pair(first_id, second_id, characters, registry)
			var reverse := ComboSystem.resolve_pair(second_id, first_id, characters, registry)
			_check(String(forward.get("pairKey", "")) == String(reverse.get("pairKey", "")), "pair order key mismatch", failures)
			_check(String(forward.get("comboId", "")) == String(reverse.get("comboId", "")), "pair order combo mismatch", failures)
			if String(forward.get("kind", "")) == "dedicated":
				dedicated_count += 1
			else:
				composite_count += 1
				var modules: Array = forward.get("orderedModules", []) as Array
				_check(modules.size() == 3, "composite module count", failures)
				if modules.size() >= 2:
					_check(int((modules[0] as Dictionary).get("priority", 999)) <= int((modules[1] as Dictionary).get("priority", 999)), "module priority order", failures)
	_check(dedicated_count == 6, "dedicated pair count", failures)
	_check(composite_count == 9, "composite pair count", failures)
	var guard_live := ComboSystem.resolve_pair("aosumi_kyasumi", "akarine_rizumu", characters, registry)
	_check(String(guard_live.get("handler", "")) == "kyasumi_rizumu", "kyasumi and rizumu dedicated pair handler", failures)
	_check(String(guard_live.get("displayName", "")) == "ガードライブ・フィナーレ", "kyasumi and rizumu dedicated pair name", failures)
	var candidates := ComboSystem.partner_candidates(characters, "ban_chan", ["aosumi_kyasumi", "akarine_rizumu", "shizuki_miimu"])
	_check(candidates.size() <= 5, "partner candidate cap", failures)
	for item in candidates:
		_check(String((item as Dictionary).get("id", "")) != "ban_chan", "self appeared in partner candidates", failures)
	_check(ComboSystem.grid_move(0, Vector2i(0, 1), 5, 3) == 3, "2D grid down navigation", failures)
	_check(ComboSystem.grid_move(3, Vector2i(0, 1), 5, 3) == 4, "incomplete final row navigation", failures)

	if failures.is_empty():
		print("Stage4 collab logic tests passed")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	get_tree().quit(1)

func _check(condition: bool, message: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(message)
