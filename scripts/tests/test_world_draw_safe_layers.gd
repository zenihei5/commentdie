extends Node


func _ready() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	var failures: Array[String] = []
	var source := FileAccess.get_file_as_string("res://scripts/game.gd")
	var start := source.find("func _draw_world_layer() -> void:")
	var finish := source.find("\nfunc _draw_overlay_layer() -> void:", start)
	_check(start >= 0 and finish > start, "_draw_world_layer source block missing", failures)
	if start >= 0 and finish > start:
		var block := source.substr(start, finish - start)
		var weapon_cosmetic := block.find("_draw_hit_fx(false, hit_fx_draw_items, \"front\")")
		var hostile_body := block.find("_draw_enemy_bullets(visible_world_rect)")
		var player := block.find("_draw_player()")
		var red_pen_telegraph := block.find("_draw_red_pen_bullet_telegraph()")
		var pitch_telegraph := block.find("_draw_pitch_chief_bullet_telegraph()")
		var boss_warning_foreground := block.find("_draw_boss_guide_lines_foreground()")
		var red_pen_rim := block.find("WeaponDrawSystemScript.draw_red_pen_player_near_rims")

		_check(block.count("_draw_hit_fx(false, hit_fx_draw_items, \"front\")") == 1, "weapon cosmetic front pass must draw exactly once", failures)
		_check(block.count("_draw_enemy_bullets(visible_world_rect)") == 1, "hostile projectile body pass must draw exactly once", failures)
		_check(block.count("_draw_player()") == 1, "player safe-layer pass must draw exactly once", failures)
		_check(weapon_cosmetic >= 0 and hostile_body > weapon_cosmetic, "hostile projectile bodies must draw above weapon cosmetic front FX", failures)
		_check(player > hostile_body, "player must draw above dense weapon FX and hostile projectile bodies", failures)
		_check(red_pen_telegraph > player, "red-pen telegraph must draw above the player safe layer", failures)
		_check(pitch_telegraph > player, "pitch-chief telegraph must draw above the player safe layer", failures)
		_check(boss_warning_foreground > player, "boss warning foreground must draw above the player safe layer", failures)
		_check(red_pen_rim > player, "near-player projectile rims must draw above the player safe layer", failures)

	if failures.is_empty():
		print("World draw safe-layer tests passed")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	get_tree().quit(1)


func _check(condition: bool, message: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(message)
