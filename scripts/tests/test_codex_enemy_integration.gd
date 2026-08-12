extends Node

const EnemySystemScript := preload("res://scripts/systems/enemy_system.gd")

class FakeTarget:
	extends Node
	var enemies: Array = []
	var kills := 0
	var run_difficulty_id := "normal"

var failures: Array[String] = []

func _ready() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	CodexManager.initialize_empty()
	var target := FakeTarget.new()
	add_child(target)
	target.enemies = [
		{"kind": "enemy_wrong_way_kart"},
		{"kind": "enemy_fake_gift_box"},
		{"kind": "unread_maro"},
		{"kind": "collab_division_noise"},
		{"kind": "noise_ghost_comment"},
		{"kind": "undo_ghost"},
		{"kind": "red_pen_retake_dragon", "isBoss": true, "bossId": "red_pen_retake_dragon"}
	]
	EnemySystemScript.discover_spawned_enemies_for_target(target)
	for enemy_id in ["enemy_wrong_way_kart", "enemy_fake_gift_box", "unread_maro", "collab_division_noise", "noise_ghost_comment", "red_pen_review_chief"]:
		_check(CodexManager.is_discovered(CodexManager.CATEGORY_ENEMY, enemy_id), "special route discovered: %s" % enemy_id)
	_check(not CodexManager.is_discovered(CodexManager.CATEGORY_ENEMY, "undo_ghost"), "disabled enemy is not discovered")
	_check(bool((target.enemies[5] as Dictionary).get("_codex_spawn_processed", false)), "disabled instance is marked processed")

	var normal_enemy := {"kind": "troll", "noRewards": true}
	EnemySystemScript.apply_kill_for_target(target, normal_enemy, Rect2(0, 0, 100, 100), RandomNumberGenerator.new())
	EnemySystemScript.apply_kill_for_target(target, normal_enemy, Rect2(0, 0, 100, 100), RandomNumberGenerator.new())
	_check(int(CodexManager.get_entry(CodexManager.CATEGORY_ENEMY, "troll").get("kill_count", 0)) == 1, "normal defeat is recorded once per instance")

	var boss_enemy := {"kind": "boss_kuso_maro_king", "bossId": "boss_kuso_maro_king", "isBoss": true, "noRewards": true}
	EnemySystemScript.apply_kill_for_target(target, boss_enemy, Rect2(0, 0, 100, 100), RandomNumberGenerator.new())
	var boss_entry := CodexManager.get_entry(CodexManager.CATEGORY_ENEMY, "boss_kuso_maro_king")
	_check(int(boss_entry.get("kill_count", 0)) == 1, "boss defeat uses boss recorder")
	_check(bool((boss_entry.get("defeated", {}) as Dictionary).get("normal", false)), "boss normal flag is recorded")

	if failures.is_empty():
		print("CODEX_ENEMY_INTEGRATION_TESTS: PASS")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("CODEX_ENEMY_INTEGRATION_TESTS: FAIL (%d)" % failures.size())
	get_tree().quit(1)

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
