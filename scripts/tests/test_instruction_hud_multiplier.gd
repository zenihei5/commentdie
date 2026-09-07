extends Node

const HudTextSystemScript := preload("res://scripts/systems/hud_text_system.gd")
const GameFontSystemScript := preload("res://scripts/systems/game_font_system.gd")

var failures: Array[String] = []

func _ready() -> void:
	_check_multiplier_views()
	_check_countdown_layout()
	_check_production_connection()
	if failures.is_empty():
		print("INSTRUCTION_HUD_MULTIPLIER_TESTS: PASS")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("INSTRUCTION_HUD_MULTIPLIER_TESTS: FAIL (%d)" % failures.size())
	get_tree().quit(1)

func _check_multiplier_views() -> void:
	var resolved_view := {"id": "no_brake", "multiplier": 2.5}
	for difficulty_label in ["NORMAL", "HARD", "EXPERT"]:
		var view: Dictionary = HudTextSystemScript.instruction_multiplier_view({
			"active": true,
			"effectTimer": 15.0,
			"resolvedCommentView": resolved_view,
			"commentBoost": false,
			"difficultyLabel": difficulty_label
		})
		_check(bool(view.get("visible", false)), "%s resolved instruction is visible" % difficulty_label)
		_check_approx(float(view.get("value", 0.0)), 2.5, "%s uses resolved multiplier" % difficulty_label)
		_check(String(view.get("text", "")) == "スコア倍率 ×2.5", "%s multiplier text" % difficulty_label)
		var heart_view: Dictionary = HudTextSystemScript.instruction_multiplier_view({
			"active": true,
			"effectTimer": 15.0,
			"resolvedCommentView": resolved_view,
			"commentBoost": true,
			"difficultyLabel": "%s+♡" % difficulty_label
		})
		_check_approx(float(heart_view.get("value", 0.0)), 3.0, "%s comment_boost applies 1.2" % difficulty_label)
		_check(String(heart_view.get("text", "")) == "スコア倍率 ×3.0", "%s boosted multiplier text" % difficulty_label)

	var special_view: Dictionary = HudTextSystemScript.instruction_multiplier_view({
		"active": true,
		"effectTimer": 15.0,
		"resolvedCommentView": {"id": "do_everything", "multiplier": 5.0},
		"commentBoost": false
	})
	_check_approx(float(special_view.get("value", 0.0)), 5.0, "do_everything uses resolved x5.0")
	_check(String(special_view.get("text", "")) == "スコア倍率 ×5.0", "do_everything multiplier text")

	var relay_boss_view: Dictionary = HudTextSystemScript.instruction_multiplier_view({
		"active": true,
		"effectTimer": 15.0,
		"relayBossActive": true,
		"relayBossInstruction": {"id": "relay_boss_no_dash", "category": "player", "multiplier": 1.0}
	})
	_check(bool(relay_boss_view.get("visible", false)), "relay boss instruction multiplier is visible")
	_check_approx(float(relay_boss_view.get("value", 0.0)), 1.0, "relay boss instruction uses x1.0")
	_check(String(relay_boss_view.get("text", "")) == "スコア倍率 ×1.0", "relay boss multiplier text")

	var support_view: Dictionary = HudTextSystemScript.instruction_multiplier_view({
		"active": true,
		"effectTimer": 15.0,
		"relayBossActive": true,
		"relayBossInstruction": {"id": "boss_support_dont_lose", "category": "boss_support", "multiplier": 1.0}
	})
	_check(not bool(support_view.get("visible", false)), "boss_support does not show a score multiplier")
	_check(not bool(HudTextSystemScript.instruction_multiplier_view({
		"active": false,
		"effectTimer": 15.0,
		"resolvedCommentView": resolved_view
	}).get("visible", false)), "no active instruction hides multiplier")
	_check(not bool(HudTextSystemScript.instruction_multiplier_view({
		"active": true,
		"effectTimer": 0.0,
		"resolvedCommentView": resolved_view
	}).get("visible", false)), "expired instruction hides multiplier")
	_check(not bool(HudTextSystemScript.instruction_multiplier_view({
		"active": true,
		"effectTimer": 15.0,
		"resolvedCommentView": {}
	}).get("visible", false)), "empty resolved view hides multiplier")

	var hard_climax_runtime := {"playMode": "single", "climax": {"active": true}}
	var hard_climax_view: Dictionary = HudTextSystemScript.hard_climax_view({
		"state": "playing",
		"difficultyId": "hard",
		"difficultyRuntime": hard_climax_runtime,
		"relayBossActive": false
	})
	_check(bool(hard_climax_view.get("visible", false)), "HARD active climax is visible")
	_check(String(hard_climax_view.get("title", "")) == "終盤ボーナス中", "active climax title")
	_check(String(hard_climax_view.get("description", "")) == "通常敵の撃破スコア＋20％", "active climax description")
	var expert_climax_view: Dictionary = HudTextSystemScript.hard_climax_view({
		"state": "playing",
		"difficultyId": "expert",
		"difficultyRuntime": hard_climax_runtime,
		"relayBossActive": false
	})
	_check(bool(expert_climax_view.get("visible", false)), "EXPERT active climax is visible")
	_check(not bool(HudTextSystemScript.hard_climax_view({
		"state": "playing",
		"difficultyId": "normal",
		"difficultyRuntime": hard_climax_runtime,
		"relayBossActive": false
	}).get("visible", false)), "NORMAL hides climax")
	_check(not bool(HudTextSystemScript.hard_climax_view({
		"state": "pause",
		"difficultyId": "hard",
		"difficultyRuntime": hard_climax_runtime,
		"relayBossActive": false
	}).get("visible", false)), "pause hides climax HUD")
	_check(not bool(HudTextSystemScript.hard_climax_view({
		"state": "playing",
		"difficultyId": "hard",
		"difficultyRuntime": {"playMode": "relayFinalBoss", "climax": {"active": true}},
		"relayBossActive": true
	}).get("visible", false)), "relay final boss hides climax HUD")
	_check(bool(HudTextSystemScript.hard_climax_view({
		"state": "playing",
		"difficultyId": "hard",
		"difficultyRuntime": {"playMode": "relaySection", "climax": {"active": true}},
		"relayBossActive": false
	}).get("visible", false)), "relay section keeps climax HUD")

func _check_countdown_layout() -> void:
	var countdown_rect := Rect2(20.0, 108.0, 1200.0, 76.0)
	var layout: Dictionary = HudTextSystemScript.instruction_countdown_layout(countdown_rect, true, true)
	var expected_remaining := Rect2(1068.0, 119.0, 124.0, 28.0)
	var badge: Rect2 = layout["multiplierRect"] as Rect2
	var remaining: Rect2 = layout["remainingRect"] as Rect2
	_check(remaining == expected_remaining, "remaining chip keeps its existing geometry")
	_check(badge.size == Vector2(176.0, 28.0), "multiplier chip is 176x28")
	_check(badge == Rect2(878.0, 119.0, 176.0, 28.0), "multiplier chip sits before remaining chip")
	_check_approx(remaining.position.x - badge.end.x, 14.0, "multiplier and remaining chips keep a 14px gap")
	var climax_badge: Rect2 = layout["climaxRect"] as Rect2
	_check(climax_badge == Rect2(654.0, 113.0, 210.0, 42.0), "climax chip sits before instruction multiplier chip")
	_check_approx(badge.position.x - climax_badge.end.x, 14.0, "climax and multiplier chips keep a 14px gap")
	var title_pos: Vector2 = layout["titlePos"] as Vector2
	var title_width := float(layout["titleWidth"])
	_check_approx(title_pos.x, 176.0, "instruction title keeps its x anchor")
	_check_approx(climax_badge.position.x - (title_pos.x + title_width), 16.0, "title keeps a 16px safety gap before climax chip")
	_check(not Rect2(title_pos, Vector2(title_width, 36.0)).intersects(badge), "title rect does not overlap multiplier chip")
	_check(not Rect2(title_pos, Vector2(title_width, 36.0)).intersects(climax_badge), "title rect does not overlap climax chip")
	_check(not badge.intersects(remaining), "multiplier chip does not overlap remaining chip")
	_check(not climax_badge.intersects(badge), "climax chip does not overlap multiplier chip")
	_check(climax_badge.end.y < countdown_rect.position.y + 54.0, "climax chip stays above the countdown bar")

	var inactive_layout: Dictionary = HudTextSystemScript.instruction_countdown_layout(countdown_rect, false)
	_check_approx(float(inactive_layout["titleWidth"]), 800.0, "hidden multiplier keeps the legacy title width")
	_check((inactive_layout["multiplierRect"] as Rect2).size == Vector2.ZERO, "hidden multiplier has no visible rect")
	_check((inactive_layout["climaxRect"] as Rect2).size == Vector2.ZERO, "hidden climax has no visible rect")
	_check((inactive_layout["remainingRect"] as Rect2) == expected_remaining, "hidden multiplier keeps remaining geometry")

	var short_layout: Dictionary = HudTextSystemScript.instruction_title_layout("ノーブレーキ", title_width, 28, 16)
	_check(String(short_layout.get("text", "")) == "ノーブレーキ", "short title remains complete")
	_check(int(short_layout.get("size", 0)) == 28, "short title keeps 28px")
	var long_text := "とても長い複合指示コメタイトルをここに表示する"
	var long_layout: Dictionary = HudTextSystemScript.instruction_title_layout(long_text, title_width, 28, 16)
	var long_display := String(long_layout.get("text", ""))
	var long_size := int(long_layout.get("size", 0))
	var long_width := GameFontSystemScript.black_font().get_string_size(long_display, HORIZONTAL_ALIGNMENT_LEFT, -1.0, long_size).x
	_check(long_display != "", "long title remains nonempty")
	_check(long_size >= 16 and long_size <= 28, "long title stays within the allowed font range")
	_check(long_width <= title_width + 0.01, "long title fits before multiplier chip")
	var badge_text_width := GameFontSystemScript.black_font().get_string_size("スコア倍率 ×2.5", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 15).x
	_check(badge_text_width <= 176.0, "multiplier text fits its chip")

func _check_production_connection() -> void:
	var source := FileAccess.get_file_as_string("res://scripts/game.gd")
	_check(source.contains("HudTextSystemScript.instruction_multiplier_view"), "HUD draw path calls the multiplier view helper")
	_check(source.contains("\"commentBoost\": comment_boost"), "HUD draw path passes comment_boost")
	_check(source.contains("HudTextSystemScript.hard_climax_view"), "HUD draw path calls the active climax helper")
	_check(source.contains("\"difficultyRuntime\": difficulty_runtime"), "HUD draw path passes the real difficulty runtime")
	_check(source.contains("HudTextSystemScript.instruction_countdown_layout"), "HUD draw path uses shared countdown layout")
	_check(source.contains("const HARD_CLIMAX_BANNER_TITLE := \"終盤ボーナス！\""), "climax notification title is localized")
	_check(source.contains("const HARD_CLIMAX_BANNER_DESCRIPTION := \"通常敵の撃破スコアがさらに20％UP\""), "climax notification description is explicit")
	var banner_start := source.find("func _draw_hard_climax_banner()")
	var banner_end := source.find("func _draw_hard_balance_debug_overlay", banner_start)
	var banner_source := source.substr(banner_start, banner_end - banner_start) if banner_start >= 0 and banner_end > banner_start else ""
	_check(banner_source.contains("state != \"playing\""), "climax notification is hidden outside gameplay")
	_check(not banner_source.contains("load_png_texture"), "climax notification no longer draws the banner image")

func _check(condition: bool, label: String) -> void:
	if not condition:
		failures.append(label)

func _check_approx(actual: float, expected: float, label: String) -> void:
	if absf(actual - expected) > 0.01:
		failures.append("%s: got %.3f expected %.3f" % [label, actual, expected])
