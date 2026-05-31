class_name ResultSystem
extends RefCounted

static func calculate_rank(stats: Dictionary) -> String:
	var points: int = int(
		float(stats.get("elapsed", 0.0))
		+ int(stats.get("score", 0)) / 100.0
		+ float(stats.get("maxMultiplier", 1.0)) * 10.0
		+ int(stats.get("burnComboMax", 0)) * 5.0
		+ int(stats.get("giftsTaken", 0)) * 5.0
	)
	if points >= 160:
		return "S"
	if points >= 120:
		return "A"
	if points >= 80:
		return "B"
	if points >= 40:
		return "C"
	return "D"

static func format_time(seconds: float) -> String:
	return "%02d:%02d" % [int(seconds) / 60, int(seconds) % 60]

static func build_ranking_entry(stats: Dictionary) -> Dictionary:
	return {
		"score": int(stats.get("score", 0)),
		"rank": String(stats.get("rank", "D")),
		"time": int(stats.get("elapsed", 0.0)),
		"maxMultiplier": float(stats.get("maxMultiplier", 1.0)),
		"characterId": String(stats.get("characterId", "")),
		"characterName": String(stats.get("characterName", "配信者")),
		"streamFrameId": String(stats.get("streamFrameId", "")),
		"streamFrameName": String(stats.get("streamFrameName", "配信枠")),
		"date": Time.get_date_string_from_system()
	}

static func build_run_stats(
	reason: String,
	core: Dictionary,
	character: Dictionary,
	stream_frame: Dictionary,
	weapon: Dictionary,
	gift_names: Array,
	genre_stats: Dictionary,
	marshmallow_stats: Dictionary
) -> Dictionary:
	return {
		"reason": reason,
		"elapsed": float(core.get("elapsed", 0.0)),
		"score": int(core.get("score", 0)),
		"maxMultiplier": float(core.get("maxMultiplier", 1.0)),
		"burnComboMax": int(core.get("burnComboMax", 0)),
		"giftsTaken": int(core.get("giftsTaken", 0)),
		"maxGiftHype": int(core.get("maxGiftHype", 0)),
		"dangerCommentsChosen": int(core.get("dangerCommentsChosen", 0)),
		"heartUsedCount": int(core.get("heartUsedCount", 0)),
		"currentComment": String(core.get("currentComment", "なし")),
		"lastDeathSource": String(core.get("lastDeathSource", "接触")),
		"characterId": String(core.get("characterId", "")),
		"characterName": String(character.get("displayName", "バンちゃん")),
		"streamFrameId": String(core.get("streamFrameId", "")),
		"streamFrameName": String(stream_frame.get("displayName", "雑談枠")),
		"weaponName": String(weapon.get("displayName", "BANハンマー")),
		"giftSummary": DisplayTextSystem.taken_gift_summary(gift_names),
		"streamFrameResultText": DisplayTextSystem.stream_frame_result_text(String(core.get("streamFrameId", "")), genre_stats, marshmallow_stats)
	}

static func build_run_stats_from_target(reason: String, target: Node) -> Dictionary:
	return build_run_stats(reason, {
		"elapsed": float(target.get("elapsed")),
		"score": int(target.get("score")),
		"maxMultiplier": float(target.get("max_multiplier")),
		"burnComboMax": int(target.get("burn_combo_max")),
		"giftsTaken": int(target.get("gifts_taken")),
		"maxGiftHype": int(target.get("max_gift_hype")),
		"dangerCommentsChosen": int(target.get("danger_comments_chosen")),
		"heartUsedCount": int(target.get("heart_used_count")),
		"currentComment": String(target.get("current_comment")),
		"lastDeathSource": String(target.get("last_death_source")),
		"characterId": String(target.get("current_character_id")),
		"streamFrameId": String(target.get("current_stream_frame_id"))
	}, target.get("current_character") as Dictionary, target.get("current_stream_frame") as Dictionary, target.get("current_weapon") as Dictionary, target.get("taken_gift_names") as Array, {
		"genreEventCount": int(target.get("genre_event_count")),
		"raceEventCount": int(target.get("race_event_count")),
		"bulletHellEventCount": int(target.get("bullet_hell_event_count")),
		"horrorEventCount": int(target.get("horror_event_count")),
		"genreEventClearCount": int(target.get("genre_event_clear_count"))
	}, {
		"answered": int(target.get("marshmallow_answered")),
		"good": int(target.get("marshmallow_good")),
		"god": int(target.get("marshmallow_god")),
		"kuso": int(target.get("marshmallow_kuso")),
		"unread": int(target.get("marshmallow_unread"))
	})

static func complete_run_stats(stats: Dictionary) -> Dictionary:
	var result: Dictionary = stats.duplicate()
	var rank: String = calculate_rank(result)
	result["rank"] = rank
	result["timeText"] = format_time(float(result.get("elapsed", 0.0)))
	return result

static func complete_run_for_target(reason: String, target: Node, quick_test_mode: bool) -> Dictionary:
	var result: Dictionary = complete_run_stats(build_run_stats_from_target(reason, target))
	result["rankingText"] = RankingSystem.save_and_format_ranking(build_ranking_entry(result), quick_test_mode)
	result["resultText"] = build_result_text(result)
	return result

static func open_result_for_target(reason: String, target: Node, quick_test_mode: bool, choice_box: Control, result_panel: Control, heart_cards: Array) -> Dictionary:
	target.set("state", "result")
	choice_box.visible = false
	heart_cards.clear()
	result_panel.visible = true
	return complete_run_for_target(reason, target, quick_test_mode)

static func open_result_ui_for_target(
	reason: String,
	target: Node,
	quick_test_mode: bool,
	choice_box: Control,
	result_panel: PanelContainer,
	result_label: Label,
	heart_cards: Array,
	chat_box: Control
) -> Dictionary:
	var stats: Dictionary = open_result_for_target(reason, target, quick_test_mode, choice_box, result_panel, heart_cards)
	var rank: String = String(stats["rank"])
	target.set("run_rank", rank)
	result_panel.add_theme_stylebox_override("panel", UiStyleSystem.result_panel_style(rank))
	result_label.text = String(stats["resultText"])
	var lines: Array[String] = ChatSystem.seed_box(chat_box, "death")
	target.set("chat_lines", lines)
	return stats

static func build_result_text(stats: Dictionary) -> String:
	var stream_result: String = String(stats.get("streamFrameResultText", "")).strip_edges()
	var ranking_text: String = String(stats.get("rankingText", "")).strip_edges()
	var gift_summary: String = _short_line(String(stats.get("giftSummary", "なし")), 44)
	var death_reason: String = _short_line(String(stats.get("reason", "")), 44)
	var death_source: String = _short_line(String(stats.get("lastDeathSource", "接触")), 34)
	var lines: Array[String] = [
		"配信終了！  神回度：%s" % String(stats.get("rank", "D")),
		"%s / %s / %s" % [
			String(stats.get("characterName", "バンちゃん")),
			String(stats.get("streamFrameName", "雑談枠")),
			String(stats.get("weaponName", "BANハンマー"))
		],
		"スコア：%d  生存：%s  最大倍率：x%.1f  炎上：%d" % [
			int(stats.get("score", 0)),
			String(stats.get("timeText", "00:00")),
			float(stats.get("maxMultiplier", 1.0)),
			int(stats.get("burnComboMax", 0))
		],
		"ギフト：%d  最高期待度：%d%%  危険指示コメ：%d  ♡：%d" % [
			int(stats.get("giftsTaken", 0)),
			int(stats.get("maxGiftHype", 0)),
			int(stats.get("dangerCommentsChosen", 0)),
			int(stats.get("heartUsedCount", 0))
		],
		"",
		"戦犯指示コメ：%s" % String(stats.get("currentComment", "なし")),
		"死因：%s" % death_reason,
		"最後の一撃：%s" % death_source,
		"取得ギフト：%s" % gift_summary
	]
	if stream_result != "":
		lines.append(stream_result)
	if ranking_text != "":
		lines.append("")
		lines.append(ranking_text)
	lines.append("")
	lines.append("Enter / Space：もう一回")
	return "\n".join(lines)

static func _short_line(text: String, max_length: int) -> String:
	var one_line: String = text.replace("\r", " ").replace("\n", " ").strip_edges()
	if one_line.length() <= max_length:
		return one_line
	return one_line.substr(0, max_length - 1) + "…"
