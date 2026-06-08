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
	var total_seconds: int = int(seconds)
	var minutes: int = int(total_seconds / 60)
	var secs: int = total_seconds % 60
	return "%02d:%02d" % [minutes, secs]

static func result_header_for_end_type(end_type: String, cleared: bool = false) -> String:
	if end_type == "completed":
		return "配信完走！"
	if end_type == "mental_breakdown":
		return "配信終了……"
	return "配信成功！" if cleared else "配信終了！"

static func result_summary_for_end_type(end_type: String, fallback: String = "") -> String:
	if end_type == "completed":
		return "最後まで配信を走り切った！"
	if end_type == "mental_breakdown":
		return "コメントに振り回された配信だった……"
	return fallback

static func result_end_type_for_stats(stats: Dictionary, quick_test_mode: bool) -> String:
	var end_type := String(stats.get("endType", ""))
	if end_type in ["mental_breakdown", "completed", "quit", "debug"]:
		return end_type
	if _is_cleared(stats, quick_test_mode):
		return "completed"
	return "mental_breakdown"

static func build_ranking_entry(stats: Dictionary) -> Dictionary:
	return {
		"runId": String(stats.get("runId", "")),
		"endType": String(stats.get("endType", "")),
		"score": int(stats.get("score", 0)),
		"viewerCount": int(stats.get("viewerCount", stats.get("score", 0))),
		"rank": String(stats.get("rank", "D")),
		"kamiRank": String(stats.get("kamiRank", stats.get("rank", "D"))),
		"kamiPoint": int(stats.get("kamiPoint", 0)),
		"time": int(stats.get("elapsed", 0.0)),
		"survivalTime": float(stats.get("elapsed", 0.0)),
		"cleared": bool(stats.get("cleared", false)),
		"maxMultiplier": float(stats.get("maxMultiplier", 1.0)),
		"maxVoltage": float(stats.get("maxVoltage", stats.get("maxMultiplier", 1.0))),
		"maxBurnCombo": int(stats.get("maxBurnCombo", stats.get("burnComboMax", 0))),
		"modeId": String(stats.get("modeId", "")),
		"modeName": String(stats.get("modeName", "")),
		"characterId": String(stats.get("characterId", "")),
		"characterName": String(stats.get("characterName", "配信者")),
		"streamFrameId": String(stats.get("streamFrameId", "")),
		"streamFrameName": String(stats.get("streamFrameName", "配信枠")),
		"culpritInstructionComment": "なし" if String(stats.get("endType", "")) == "completed" else String(stats.get("currentComment", "なし")),
		"weapons": stats.get("weapons", []),
		"accessories": stats.get("accessories", []),
		"weaponEquipmentText": String(stats.get("weaponEquipmentText", "")),
		"accessoryEquipmentText": String(stats.get("accessoryEquipmentText", "")),
		"bossSummoned": bool(stats.get("bossSummoned", false)),
		"bossDefeated": bool(stats.get("bossDefeated", false)),
		"bossName": String(stats.get("bossName", "")),
		"bossResult": String(stats.get("bossResult", "")),
		"bossRewardViewer": int(stats.get("bossRewardViewer", 0)),
		"deathText": "" if String(stats.get("endType", "")) == "completed" else String(stats.get("deathText", stats.get("currentDeathText", ""))),
		"date": Time.get_date_string_from_system(),
		"playedAt": String(stats.get("playedAt", Time.get_datetime_string_from_system()))
	}


static func build_relay_ranking_entry(stats: Dictionary) -> Dictionary:
	var completed_frame_ids: Array = _safe_array(stats.get("relayCompletedFrameIds", []))
	var completed_frame_names: Array = _safe_array(stats.get("relayCompletedFrameNames", []))
	var cleared_count: int = int(stats.get("relayClearedFrameCount", completed_frame_ids.size()))
	var max_viewer_count: int = maxi(int(stats.get("relayMaxScore", 0)), int(stats.get("viewerCount", stats.get("score", 0))))
	var total_viewer_count: int = int(stats.get("score", stats.get("relayTotalScore", 0)))
	var max_voltage: float = maxf(float(stats.get("relayMaxMultiplier", 1.0)), float(stats.get("maxVoltage", stats.get("maxMultiplier", 1.0))))
	var max_burn_combo: int = maxi(int(stats.get("relayMaxBurnCombo", 0)), int(stats.get("maxBurnCombo", stats.get("burnComboMax", 0))))
	var relay_completed: bool = _is_relay_completed(stats)
	var ended_reason: String = "death"
	var culprit_comment: Variant = String(stats.get("currentComment", "なし"))
	var death_text: String = String(stats.get("currentDeathText", stats.get("reason", "")))
	if relay_completed:
		ended_reason = "completed"
		culprit_comment = null
		death_text = ""
	return {
		"id": String(stats.get("runId", stats.get("playedAt", ""))),
		"runId": String(stats.get("runId", "")),
		"endType": String(stats.get("endType", "")),
		"modeId": "relay",
		"isRankingEligible": true,
		"characterId": String(stats.get("characterId", "")),
		"characterName": String(stats.get("characterName", "配信者")),
		"characterDisplayName": _character_nickname_for_stats(stats),
		"characterIconId": String(stats.get("characterId", "")) + "_icon",
		"clearedFrameCount": cleared_count,
		"completedFrameIds": completed_frame_ids,
		"completedFrameNames": completed_frame_names,
		"currentFrameId": String(stats.get("streamFrameId", "")),
		"currentFrameName": String(stats.get("streamFrameName", "配信枠")),
		"isRelayCompleted": relay_completed,
		"maxViewerCount": max_viewer_count,
		"totalViewerCount": total_viewer_count,
		"maxVoltage": max_voltage,
		"maxBurnCombo": max_burn_combo,
		"totalSurvivalTime": float(cleared_count) * 180.0 + float(stats.get("elapsed", 0.0)),
		"weapons": stats.get("weapons", []),
		"accessories": stats.get("accessories", []),
		"weaponEquipmentText": String(stats.get("weaponEquipmentText", "")),
		"accessoryEquipmentText": String(stats.get("accessoryEquipmentText", "")),
		"bossSummoned": bool(stats.get("bossSummoned", false)),
		"bossDefeated": bool(stats.get("bossDefeated", false)),
		"bossName": String(stats.get("bossName", "")),
		"bossResult": String(stats.get("bossResult", "")),
		"bossRewardViewer": int(stats.get("bossRewardViewer", 0)),
		"endedReason": ended_reason,
		"culpritInstructionComment": culprit_comment,
		"deathText": death_text,
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
		"endType": String(core.get("endType", "")),
		"elapsed": float(core.get("elapsed", 0.0)),
		"score": int(core.get("score", 0)),
		"viewerCount": int(core.get("viewerCount", core.get("score", 0))),
		"maxMultiplier": float(core.get("maxMultiplier", 1.0)),
		"maxVoltage": float(core.get("maxVoltage", core.get("maxMultiplier", 1.0))),
		"burnComboMax": int(core.get("burnComboMax", 0)),
		"maxBurnCombo": int(core.get("maxBurnCombo", core.get("burnComboMax", 0))),
		"giftsTaken": int(core.get("giftsTaken", 0)),
		"maxGiftHype": int(core.get("maxGiftHype", 0)),
		"dangerCommentsChosen": int(core.get("dangerCommentsChosen", 0)),
		"heartUsedCount": int(core.get("heartUsedCount", 0)),
		"relayMode": bool(core.get("relayMode", false)),
		"relayClearedFrameCount": int(core.get("relayClearedFrameCount", 0)),
		"relayCompletedFrameIds": core.get("relayCompletedFrameIds", []),
		"relayCompletedFrameNames": core.get("relayCompletedFrameNames", []),
		"relayTotalScore": int(core.get("relayTotalScore", 0)),
		"relayMaxScore": int(core.get("relayMaxScore", 0)),
		"relayMaxMultiplier": float(core.get("relayMaxMultiplier", core.get("maxMultiplier", 1.0))),
		"relayMaxBurnCombo": int(core.get("relayMaxBurnCombo", core.get("maxBurnCombo", core.get("burnComboMax", 0)))),
		"currentComment": String(core.get("currentComment", "なし")),
		"currentDeathText": String(core.get("currentDeathText", "発動中の指示コメなし")),
		"lastDeathSource": String(core.get("lastDeathSource", "接触")),
		"bossSummoned": bool(core.get("bossSummoned", false)),
		"bossDefeated": bool(core.get("bossDefeated", false)),
		"bossName": String(core.get("bossName", "")),
		"bossResult": String(core.get("bossResult", "")),
		"bossRewardViewer": int(core.get("bossRewardViewer", 0)),
		"characterId": String(core.get("characterId", "")),
		"characterName": String(character.get("displayName", "赤羽ばんり")),
		"streamFrameId": String(core.get("streamFrameId", "")),
		"streamFrameName": String(stream_frame.get("displayName", "雑談枠")),
		"weaponName": String(weapon.get("displayName", "BANハンマー")),
		"weaponEquipmentText": String(core.get("weaponEquipmentText", "")),
		"accessoryEquipmentText": String(core.get("accessoryEquipmentText", "")),
		"weapons": core.get("weapons", []),
		"accessories": core.get("accessories", []),
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
		"endType": String(target.get("pending_game_over_end_type")),
		"elapsed": float(target.get("elapsed")),
		"score": int(target.get("score")),
		"viewerCount": int(target.get("score")),
		"maxMultiplier": float(target.get("max_multiplier")),
		"maxVoltage": float(target.get("max_multiplier")),
		"burnComboMax": int(target.get("burn_combo_max")),
		"maxBurnCombo": int(target.get("burn_combo_max")),
		"giftsTaken": int(target.get("gifts_taken")),
		"maxGiftHype": int(target.get("max_gift_hype")),
		"dangerCommentsChosen": int(target.get("danger_comments_chosen")),
		"heartUsedCount": int(target.get("heart_used_count")),
		"relayMode": bool(target.get("relay_mode")),
		"relayClearedFrameCount": int(target.get("relay_cleared_frame_count")),
		"relayCompletedFrameIds": (target.get("relay_completed_frame_ids") as Array).duplicate(),
		"relayCompletedFrameNames": _frame_names_for_ids(target.get("relay_completed_frame_ids") as Array, target.get("stream_frames") as Array),
		"relayTotalScore": int(target.get("score")),
		"relayMaxScore": maxi(int(target.get("relay_max_score")), int(target.get("score"))),
		"relayMaxMultiplier": maxf(float(target.get("relay_max_multiplier")), float(target.get("max_multiplier"))),
		"relayMaxBurnCombo": maxi(int(target.get("relay_max_burn_combo")), int(target.get("burn_combo_max"))),
		"currentComment": String(target.get("current_comment")),
		"currentDeathText": String(target.get("current_death_text")),
		"lastDeathSource": String(target.get("last_death_source")),
		"bossSummoned": bool(target.get("boss_summoned")),
		"bossDefeated": bool(target.get("boss_defeated")),
		"bossName": String(target.get("boss_last_name")),
		"bossResult": String(target.get("boss_last_result")),
		"bossRewardViewer": int(target.get("boss_reward_viewers")),
		"characterId": String(target.get("current_character_id")),
		"streamFrameId": String(target.get("current_stream_frame_id")),
		"weaponEquipmentText": EquipmentSystem.slot_summary(EquipmentSystem.weapon_names(target.get("player_weapons") as Array, target.get("weapons") as Array), EquipmentSystem.MAX_WEAPONS),
		"accessoryEquipmentText": EquipmentSystem.slot_summary(EquipmentSystem.accessory_names(target.get("player_accessories") as Array, target.get("gifts") as Array), EquipmentSystem.MAX_ACCESSORIES),
		"weapons": EquipmentSystem.weapon_entries_for_ranking(target.get("player_weapons") as Array, target.get("weapons") as Array),
		"accessories": EquipmentSystem.accessory_entries_for_ranking(target.get("player_accessories") as Array, target.get("gifts") as Array)
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
	var relay_mode: bool = bool(target.get("relay_mode"))
	result["modeId"] = "relay" if relay_mode else ("test_60" if quick_test_mode else "normal_180")
	result["modeName"] = "配信リレー" if relay_mode else ("テスト配信" if quick_test_mode else "通常配信")
	result["isRankingEligible"] = (not quick_test_mode) and (not relay_mode)
	result["isRelayRankingEligible"] = relay_mode
	result["cleared"] = _is_cleared(result, quick_test_mode)
	result["endType"] = result_end_type_for_stats(result, quick_test_mode)
	result["playedAt"] = Time.get_datetime_string_from_system()
	result["runId"] = "%s_%d" % [String(result["playedAt"]).replace(":", "").replace("-", "").replace("T", "_"), int(result.get("score", 0))]
	result = complete_run_stats(result)
	var unlock_result: Dictionary = {"message": ""}
	if not relay_mode:
		unlock_result = StreamFrameSystem.clear_frame_for_target(target, result)
	result["unlockMessage"] = String(unlock_result.get("message", ""))
	var result_data: Dictionary = build_result_data(result)
	if relay_mode:
		result["rankingText"] = RankingSystem.save_and_format_relay_ranking(build_relay_ranking_entry(result), bool(result["isRelayRankingEligible"]))
	else:
		result["rankingText"] = RankingSystem.save_and_format_ranking(build_ranking_entry(result), bool(result["isRankingEligible"]))
	result_data["rankingText"] = String(result.get("rankingText", ""))
	result["resultData"] = result_data
	target.set("last_result_data", result_data)
	result["resultText"] = build_result_text(result)
	return result

static func build_result_data(result: Dictionary) -> Dictionary:
	var end_type := String(result.get("endType", ""))
	var fallback_summary := DisplayTextSystem.result_one_liner(
		String(result.get("rank", "D")),
		String(result.get("lastDeathSource", "")),
		int(result.get("kusoMaroCount", 0)),
		int(result.get("godMaroCount", 0))
	)
	return {
		"runId": String(result.get("runId", "")),
		"endType": end_type,
		"resultTitle": result_header_for_end_type(end_type, bool(result.get("cleared", false))),
		"modeId": String(result.get("modeId", "")),
		"modeName": String(result.get("modeName", "")),
		"isRankingEligible": bool(result.get("isRankingEligible", false)),
		"characterId": String(result.get("characterId", "")),
		"characterName": String(result.get("characterName", "配信者")),
		"streamFrameId": String(result.get("streamFrameId", "")),
		"streamFrameName": String(result.get("streamFrameName", "配信枠")),
		"relayClearedFrameCount": int(result.get("relayClearedFrameCount", 0)),
		"relayCompletedFrameIds": result.get("relayCompletedFrameIds", []),
		"relayCompletedFrameNames": result.get("relayCompletedFrameNames", []),
		"relayMaxViewerCount": maxi(int(result.get("relayMaxScore", 0)), int(result.get("viewerCount", result.get("score", 0)))),
		"relayTotalViewerCount": int(result.get("score", result.get("relayTotalScore", 0))),
		"relayMaxVoltage": maxf(float(result.get("relayMaxMultiplier", 1.0)), float(result.get("maxVoltage", result.get("maxMultiplier", 1.0)))),
		"relayMaxBurnCombo": maxi(int(result.get("relayMaxBurnCombo", 0)), int(result.get("maxBurnCombo", result.get("burnComboMax", 0)))),
		"isRelayCompleted": _is_relay_completed(result),
		"score": int(result.get("score", 0)),
		"viewerCount": int(result.get("viewerCount", result.get("score", 0))),
		"kamiRank": String(result.get("rank", "D")),
		"kamiPoint": int(result.get("kamiPoint", 0)),
		"survivalTime": float(result.get("elapsed", 0.0)),
		"cleared": bool(result.get("cleared", false)),
		"maxMultiplier": float(result.get("maxMultiplier", 1.0)),
		"maxVoltage": float(result.get("maxVoltage", result.get("maxMultiplier", 1.0))),
		"maxBurnCombo": int(result.get("maxBurnCombo", result.get("burnComboMax", 0))),
		"dangerCommentSelectedCount": int(result.get("dangerCommentsChosen", 0)),
		"heartActivatedCount": int(result.get("heartUsedCount", 0)),
		"giftCount": int(result.get("giftsTaken", 0)),
		"highestGiftHype": int(result.get("maxGiftHype", 0)),
		"giftList": result.get("giftList", []),
		"giftSummary": String(result.get("giftSummary", "")),
		"weapons": result.get("weapons", []),
		"accessories": result.get("accessories", []),
		"weaponEquipmentText": String(result.get("weaponEquipmentText", "")),
		"accessoryEquipmentText": String(result.get("accessoryEquipmentText", "")),
		"lastInstructionComment": String(result.get("currentComment", "なし")),
		"culpritInstructionComment": String(result.get("currentComment", "なし")),
		"deathText": "" if end_type == "completed" else String(result.get("deathText", result.get("currentDeathText", result.get("reason", "")))),
		"lastDeathSource": "なし" if end_type == "completed" else String(result.get("lastDeathSource", "接触")),
		"summaryLine": result_summary_for_end_type(end_type, fallback_summary),
		"streamFrameResultText": String(result.get("streamFrameResultText", "")),
		"unlockMessage": String(result.get("unlockMessage", "")),
		"rankingText": String(result.get("rankingText", "")),
		"bossSummoned": bool(result.get("bossSummoned", false)),
		"bossDefeated": bool(result.get("bossDefeated", false)),
		"bossName": String(result.get("bossName", "")),
		"bossResult": String(result.get("bossResult", "")),
		"bossRewardViewer": int(result.get("bossRewardViewer", 0)),
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
	_chat_box: Control
) -> Dictionary:
	var stats: Dictionary = open_result_for_target(reason, target, quick_test_mode, choice_box, result_panel, heart_cards)
	var rank: String = String(stats["rank"])
	target.set("run_rank", rank)
	result_panel.add_theme_stylebox_override("panel", UiStyleSystem.result_panel_style(rank))
	result_label.text = String(stats["resultText"])
	target.set("last_result_text", result_label.text)
	return stats

static func build_result_text(stats: Dictionary) -> String:
	var end_type := String(stats.get("endType", ""))
	var header: String = result_header_for_end_type(end_type, bool(stats.get("cleared", false)))
	var stream_result: String = String(stats.get("streamFrameResultText", "")).strip_edges()
	var ranking_text: String = String(stats.get("rankingText", "")).strip_edges()
	var gift_summary: String = _short_line(String(stats.get("giftSummary", "なし")), 44)
	var weapon_equipment: String = _short_line(String(stats.get("weaponEquipmentText", "")), 66)
	var accessory_equipment: String = _short_line(String(stats.get("accessoryEquipmentText", "")), 66)
	var unlock_message: String = String(stats.get("unlockMessage", "")).strip_edges()
	var relay_mode: bool = bool(stats.get("relayMode", false))
	var death_reason: String = _short_line(String(stats.get("reason", "")), 44)
	var death_source: String = _short_line(String(stats.get("lastDeathSource", "接触")), 34)
	var completed := end_type == "completed"
	var ranking_label: String = "対象" if bool(stats.get("isRankingEligible", false)) else "対象外"
	if relay_mode:
		ranking_label = "配信リレー対象"
	var lines: Array[String] = [
		"%s  神回度：%s  %dpt" % [
			header,
			String(stats.get("rank", "D")),
			int(stats.get("kamiPoint", 0))
		],
		"%s / %s / %s / %s" % [
			String(stats.get("modeName", "通常配信")),
			String(stats.get("characterName", "赤羽ばんり")),
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
		"ランキング：%s" % [
			ranking_label
		],
		""
	]
	if completed:
		lines.append("配信結果：最後まで配信を走り切った！")
		lines.append("最終指示コメ：%s" % String(stats.get("currentComment", "なし")))
	else:
		lines.append("戦犯指示コメ：%s" % String(stats.get("currentComment", "なし")))
		lines.append("死因：%s" % death_reason)
		lines.append("最後の一撃：%s" % death_source)
	lines.append("最終装備 武器：%s" % weapon_equipment)
	lines.append("最終装備 アクセサリ：%s" % accessory_equipment)
	lines.append("取得ギフト：%s" % gift_summary)
	if relay_mode:
		var relay_completed_text: String = ""
		if _is_relay_completed(stats):
			relay_completed_text = " / 完走"
		lines.append("配信リレー結果：突破 %d枠%s / 合計 %d人 / 最大 %d人" % [
			int(stats.get("relayClearedFrameCount", 0)),
			relay_completed_text,
			int(stats.get("score", 0)),
			maxi(int(stats.get("relayMaxScore", 0)), int(stats.get("score", 0)))
		])
	if stream_result != "":
		lines.append(stream_result)
	if unlock_message != "":
		lines.append("")
		lines.append(unlock_message)
	if ranking_text != "":
		lines.append("")
		lines.append(ranking_text)
	lines.append("")
	lines.append("Enter / Space：もう一回    R：ランキング    Esc：タイトルへ")
	return "\n".join(lines)

static func _is_cleared(stats: Dictionary, quick_test_mode: bool) -> bool:
	var required_time: float = 60.0 if quick_test_mode else 180.0
	var reason: String = String(stats.get("reason", ""))
	return float(stats.get("elapsed", 0.0)) >= required_time - 0.05 or reason.contains("成功") or reason.contains("完走")


static func _is_relay_completed(stats: Dictionary) -> bool:
	if String(stats.get("reason", "")).contains("完走"):
		return true
	if bool(stats.get("isRelayCompleted", false)):
		return true
	return int(stats.get("relayClearedFrameCount", 0)) >= 5 and String(stats.get("streamFrameId", "")) == "collab"


static func _frame_names_for_ids(ids: Array, frames: Array) -> Array[String]:
	var names: Array[String] = []
	for id_item in ids:
		names.append(_frame_name_for_id(String(id_item), frames))
	return names


static func _frame_name_for_id(id: String, frames: Array) -> String:
	for item in frames:
		if not (item is Dictionary):
			continue
		var frame: Dictionary = item as Dictionary
		if String(frame.get("id", "")) == id:
			return String(frame.get("displayName", id))
	if id == "zatsudan":
		return "雑談枠"
	if id == "gameplay":
		return "ゲーム実況枠"
	if id == "singing":
		return "歌枠"
	if id == "drawing":
		return "お絵かき枠"
	if id == "collab":
		return "コラボ枠"
	return id


static func _character_nickname_for_stats(stats: Dictionary) -> String:
	var id: String = String(stats.get("characterId", ""))
	if id == "ban_chan" or id == "banri":
		return "ばんちゃん"
	if id == "superchat_chan" or id == "supana":
		return "すぱなちゃん"
	if id == "maro_chan" or id == "maron":
		return "まろんちゃん"
	var name: String = String(stats.get("characterName", ""))
	if name == "赤羽ばんり":
		return "ばんちゃん"
	if name == "星投すぱな":
		return "すぱなちゃん"
	if name == "白綿まろん":
		return "まろんちゃん"
	if name != "":
		return name
	return "配信者"


static func _safe_array(value: Variant) -> Array:
	if value is Array:
		return value as Array
	return []


static func _short_line(text: String, max_length: int) -> String:
	var one_line: String = text.replace("\r", " ").replace("\n", " ").strip_edges()
	if one_line.length() <= max_length:
		return one_line
	return one_line.substr(0, max_length - 1) + "…"
