class_name ResultSystem
extends RefCounted

static func calculate_kami_point(stats: Dictionary) -> int:
	var cleared_bonus: int = 40 if bool(stats.get("cleared", false)) else 0
	return int(
		float(stats.get("elapsed", 0.0))
		+ int(stats.get("score", 0)) / 1000.0
		+ float(stats.get("maxMultiplier", 1.0)) * 8.0
		+ int(stats.get("burnComboMax", 0)) * 5.0
		+ int(stats.get("dangerCommentsChosen", 0)) * 3.0
		+ int(stats.get("giftsTaken", 0)) * 3.0
		+ cleared_bonus
	)

static func calculate_rank(stats: Dictionary) -> String:
	var points: int = int(stats.get("kamiPoint", calculate_kami_point(stats)))
	if points >= 220:
		return "S"
	if points >= 170:
		return "A"
	if points >= 120:
		return "B"
	if points >= 70:
		return "C"
	return "D"

static func format_time(seconds: float) -> String:
	return "%02d:%02d" % [int(seconds) / 60, int(seconds) % 60]

static func build_ranking_entry(stats: Dictionary) -> Dictionary:
	return {
		"runId": String(stats.get("runId", "")),
		"score": int(stats.get("score", 0)),
		"rank": String(stats.get("rank", "D")),
		"kamiRank": String(stats.get("rank", "D")),
		"kamiPoint": int(stats.get("kamiPoint", 0)),
		"time": int(stats.get("elapsed", 0.0)),
		"survivalTime": float(stats.get("elapsed", 0.0)),
		"cleared": bool(stats.get("cleared", false)),
		"maxMultiplier": float(stats.get("maxMultiplier", 1.0)),
		"modeId": String(stats.get("modeId", "")),
		"modeName": String(stats.get("modeName", "")),
		"characterId": String(stats.get("characterId", "")),
		"characterName": String(stats.get("characterName", "配信者")),
		"streamFrameId": String(stats.get("streamFrameId", "")),
		"streamFrameName": String(stats.get("streamFrameName", "配信枠")),
		"culpritInstructionComment": String(stats.get("currentComment", "なし")),
		"date": Time.get_date_string_from_system(),
		"playedAt": String(stats.get("playedAt", Time.get_datetime_string_from_system()))
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
		"ngUsedCount": int(core.get("ngUsedCount", 0)),
		"currentComment": String(core.get("currentComment", "なし")),
		"currentDeathText": String(core.get("currentDeathText", "発動中の指示コメなし")),
		"lastDeathSource": String(core.get("lastDeathSource", "接触")),
		"characterId": String(core.get("characterId", "")),
		"characterName": String(character.get("displayName", "バンちゃん")),
		"streamFrameId": String(core.get("streamFrameId", "")),
		"streamFrameName": String(stream_frame.get("displayName", "雑談枠")),
		"weaponName": String(weapon.get("displayName", "BANハンマー")),
		"weaponEquipmentText": String(core.get("weaponEquipmentText", "")),
		"accessoryEquipmentText": String(core.get("accessoryEquipmentText", "")),
		"giftList": gift_names.duplicate(),
		"giftSummary": DisplayTextSystem.taken_gift_summary(gift_names),
		"streamFrameResultText": DisplayTextSystem.stream_frame_result_text(String(core.get("streamFrameId", "")), genre_stats, marshmallow_stats),
		"genreEventCount": int(genre_stats.get("genreEventCount", 0)),
		"raceEventCount": int(genre_stats.get("raceEventCount", 0)),
		"bulletHellEventCount": int(genre_stats.get("bulletHellEventCount", 0)),
		"horrorEventCount": int(genre_stats.get("horrorEventCount", 0)),
		"genreEventClearCount": int(genre_stats.get("genreEventClearCount", 0)),
		"marshmallowReadCount": int(marshmallow_stats.get("answered", 0)),
		"goodMaroCount": int(marshmallow_stats.get("good", 0)),
		"godMaroCount": int(marshmallow_stats.get("god", 0)),
		"kusoMaroCount": int(marshmallow_stats.get("kuso", 0)),
		"unreadMaroCount": int(marshmallow_stats.get("unread", 0))
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
		"ngUsedCount": int(target.get("ng_used_count")),
		"currentComment": String(target.get("current_comment")),
		"currentDeathText": String(target.get("current_death_text")),
		"lastDeathSource": String(target.get("last_death_source")),
		"characterId": String(target.get("current_character_id")),
		"streamFrameId": String(target.get("current_stream_frame_id")),
		"weaponEquipmentText": EquipmentSystem.slot_summary(EquipmentSystem.weapon_names(target.get("player_weapons") as Array, target.get("weapons") as Array), EquipmentSystem.MAX_WEAPONS),
		"accessoryEquipmentText": EquipmentSystem.slot_summary(EquipmentSystem.accessory_names(target.get("player_accessories") as Array, target.get("gifts") as Array), EquipmentSystem.MAX_ACCESSORIES)
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
	result["kamiPoint"] = calculate_kami_point(result)
	var rank: String = calculate_rank(result)
	result["rank"] = rank
	result["timeText"] = format_time(float(result.get("elapsed", 0.0)))
	return result

static func complete_run_for_target(reason: String, target: Node, quick_test_mode: bool) -> Dictionary:
	var result: Dictionary = build_run_stats_from_target(reason, target)
	result["modeId"] = "test_60" if quick_test_mode else "normal_180"
	result["modeName"] = "テスト配信" if quick_test_mode else "通常配信"
	result["isRankingEligible"] = not quick_test_mode
	result["cleared"] = _is_cleared(result, quick_test_mode)
	result["playedAt"] = Time.get_datetime_string_from_system()
	result["runId"] = "%s_%d" % [String(result["playedAt"]).replace(":", "").replace("-", "").replace("T", "_"), int(result.get("score", 0))]
	result = complete_run_stats(result)
	var result_data: Dictionary = build_result_data(result)
	result_data["shareText"] = build_share_text(result_data)
	result["resultData"] = result_data
	target.set("last_result_data", result_data)
	result["rankingText"] = RankingSystem.save_and_format_ranking(build_ranking_entry(result), bool(result["isRankingEligible"]))
	result["resultText"] = build_result_text(result)
	return result

static func build_result_data(result: Dictionary) -> Dictionary:
	return {
		"runId": String(result.get("runId", "")),
		"modeId": String(result.get("modeId", "")),
		"modeName": String(result.get("modeName", "")),
		"isRankingEligible": bool(result.get("isRankingEligible", false)),
		"characterId": String(result.get("characterId", "")),
		"characterName": String(result.get("characterName", "配信者")),
		"streamFrameId": String(result.get("streamFrameId", "")),
		"streamFrameName": String(result.get("streamFrameName", "配信枠")),
		"score": int(result.get("score", 0)),
		"viewerCount": int(result.get("score", 0)),
		"kamiRank": String(result.get("rank", "D")),
		"kamiPoint": int(result.get("kamiPoint", 0)),
		"survivalTime": float(result.get("elapsed", 0.0)),
		"cleared": bool(result.get("cleared", false)),
		"maxMultiplier": float(result.get("maxMultiplier", 1.0)),
		"maxVoltage": float(result.get("maxMultiplier", 1.0)),
		"maxBurnCombo": int(result.get("burnComboMax", 0)),
		"dangerCommentSelectedCount": int(result.get("dangerCommentsChosen", 0)),
		"heartActivatedCount": int(result.get("heartUsedCount", 0)),
		"ngUsedCount": int(result.get("ngUsedCount", 0)),
		"giftCount": int(result.get("giftsTaken", 0)),
		"highestGiftHype": int(result.get("maxGiftHype", 0)),
		"giftList": result.get("giftList", []),
		"weaponEquipmentText": String(result.get("weaponEquipmentText", "")),
		"accessoryEquipmentText": String(result.get("accessoryEquipmentText", "")),
		"lastInstructionComment": String(result.get("currentComment", "なし")),
		"culpritInstructionComment": String(result.get("currentComment", "なし")),
		"deathText": String(result.get("reason", "")),
		"marshmallowReadCount": int(result.get("marshmallowReadCount", 0)),
		"goodMaroCount": int(result.get("goodMaroCount", 0)),
		"godMaroCount": int(result.get("godMaroCount", 0)),
		"kusoMaroCount": int(result.get("kusoMaroCount", 0)),
		"unreadMaroCount": int(result.get("unreadMaroCount", 0)),
		"genreEventCount": int(result.get("genreEventCount", 0)),
		"raceEventCount": int(result.get("raceEventCount", 0)),
		"bulletHellEventCount": int(result.get("bulletHellEventCount", 0)),
		"horrorEventCount": int(result.get("horrorEventCount", 0)),
		"genreEventClearCount": int(result.get("genreEventClearCount", 0)),
		"playedAt": String(result.get("playedAt", ""))
	}

static func build_share_text(data: Dictionary) -> String:
	var lines: Array[String] = [
		"『ぜんぶコメントのせいだ』配信結果",
		"%s / %s / %s" % [
			String(data.get("modeName", "通常配信")),
			String(data.get("characterName", "配信者")),
			String(data.get("streamFrameName", "配信枠"))
		],
		"神回度：%s（%dpt）  最大同時視聴者数：%d人" % [
			String(data.get("kamiRank", "D")),
			int(data.get("kamiPoint", 0)),
			int(data.get("score", 0))
		],
		"生存：%s  最大ボルテージ：x%.1f" % [
			format_time(float(data.get("survivalTime", 0.0))),
			float(data.get("maxMultiplier", 1.0))
		],
		"戦犯指示コメ：%s" % String(data.get("culpritInstructionComment", "なし")),
		"死因：%s" % _short_line(String(data.get("deathText", "")), 52)
	]
	return "\n".join(lines)

static func copy_share_text_for_target(target: Node) -> Dictionary:
	var data: Dictionary = target.get("last_result_data") as Dictionary
	if data.is_empty():
		return {"copied": false, "shareText": ""}
	var share_text: String = String(data.get("shareText", build_share_text(data)))
	DisplayServer.clipboard_set(share_text)
	return {"copied": true, "shareText": share_text}

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
	target.set("last_result_text", result_label.text)
	var lines: Array[String] = ChatSystem.seed_box(chat_box, "death")
	target.set("chat_lines", lines)
	return stats

static func build_result_text(stats: Dictionary) -> String:
	var header: String = "配信成功！" if bool(stats.get("cleared", false)) else "配信終了！"
	var stream_result: String = String(stats.get("streamFrameResultText", "")).strip_edges()
	var ranking_text: String = String(stats.get("rankingText", "")).strip_edges()
	var gift_summary: String = _short_line(String(stats.get("giftSummary", "なし")), 44)
	var weapon_equipment: String = _short_line(String(stats.get("weaponEquipmentText", "")), 66)
	var accessory_equipment: String = _short_line(String(stats.get("accessoryEquipmentText", "")), 66)
	var death_reason: String = _short_line(String(stats.get("reason", "")), 44)
	var death_source: String = _short_line(String(stats.get("lastDeathSource", "接触")), 34)
	var lines: Array[String] = [
		"%s  神回度：%s  %dpt" % [
			header,
			String(stats.get("rank", "D")),
			int(stats.get("kamiPoint", 0))
		],
		"%s / %s / %s / %s" % [
			String(stats.get("modeName", "通常配信")),
			String(stats.get("characterName", "バンちゃん")),
			String(stats.get("streamFrameName", "雑談枠")),
			String(stats.get("weaponName", "BANハンマー"))
		],
		"最大同時視聴者数：%d人  生存：%s  最大ボルテージ：x%.1f  炎上：%d" % [
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
		"NG使用：%d  ランキング：%s" % [
			int(stats.get("ngUsedCount", 0)),
			"対象" if bool(stats.get("isRankingEligible", false)) else "対象外"
		],
		"",
		"戦犯指示コメ：%s" % String(stats.get("currentComment", "なし")),
		"死因：%s" % death_reason,
		"最後の一撃：%s" % death_source,
		"最終装備 武器：%s" % weapon_equipment,
		"最終装備 アクセサリ：%s" % accessory_equipment,
		"取得ギフト：%s" % gift_summary
	]
	if stream_result != "":
		lines.append(stream_result)
	if ranking_text != "":
		lines.append("")
		lines.append(ranking_text)
	lines.append("")
	lines.append("Enter / Space：もう一回    R：ランキング    C：結果コピー")
	return "\n".join(lines)

static func _is_cleared(stats: Dictionary, quick_test_mode: bool) -> bool:
	var required_time: float = 60.0 if quick_test_mode else 180.0
	return float(stats.get("elapsed", 0.0)) >= required_time - 0.05 or String(stats.get("reason", "")).contains("成功")

static func _short_line(text: String, max_length: int) -> String:
	var one_line: String = text.replace("\r", " ").replace("\n", " ").strip_edges()
	if one_line.length() <= max_length:
		return one_line
	return one_line.substr(0, max_length - 1) + "…"
