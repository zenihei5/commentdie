class_name ResultSystem
extends RefCounted

const StreamPointRewardCalculatorScript := preload("res://scripts/systems/stream_point_reward_calculator.gd")
const PowerUpRunTrackerScript := preload("res://scripts/systems/power_up_run_tracker.gd")
const StreamPointRewardResultScript := preload("res://scripts/systems/stream_point_reward_result.gd")
const BuzzSystemScript := preload("res://scripts/systems/buzz_system.gd")
const DifficultyProgressSystemScript := preload("res://scripts/systems/difficulty_progress_system.gd")
const CodexPresentationSystemScript := preload("res://scripts/systems/codex_presentation_system.gd")

static func max_buzz_value(stats: Dictionary) -> int:
	var maximum: int = maxi(int(stats.get("burnComboMax", 0)), int(stats.get("maxBurnCombo", 0)))
	maximum = maxi(maximum, int(stats.get("relayMaxBurnCombo", 0)))
	return BuzzSystemScript.clamp_percent(maximum)

static func calculate_kami_point(stats: Dictionary) -> int:
	var cleared_bonus: int = 40 if bool(stats.get("cleared", false)) else 0
	var max_buzz: int = max_buzz_value(stats)
	return int(
		float(stats.get("elapsed", 0.0))
		+ int(stats.get("score", 0)) / 1000.0
		+ float(stats.get("maxMultiplier", 1.0)) * 8.0
		+ BuzzSystemScript.result_points(max_buzz)
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
		return "メンタル崩壊"
	return "配信成功！" if cleared else "配信終了！"

static func result_summary_for_end_type(end_type: String, fallback: String = "") -> String:
	if end_type == "completed":
		return "最後まで配信を走り切った！"
	if end_type == "mental_breakdown":
		return "コメントに振り回された配信だった……"
	return fallback

static func _clean_result_text(value: Variant, fallback: String = "なし") -> String:
	var text := String(value).strip_edges()
	return fallback if text == "" else text

static func _culprit_comment_for_result(result: Dictionary, end_type: String) -> String:
	if end_type == "completed":
		return "なし"
	var comment := _clean_result_text(result.get("currentComment", "なし"))
	if comment == "なし" or comment == "発動中の指示コメなし":
		return "なし"
	return comment

static func _last_blow_for_result(result: Dictionary, end_type: String) -> String:
	if end_type == "completed":
		return "なし"
	var source := _clean_result_text(result.get("lastDeathSource", "接触"), "接触")
	if source == "接触" or source == "敵":
		return "敵に接触"
	return source

static func _source_action_for_result(source: String) -> String:
	var text := source.strip_edges()
	if text == "" or text == "接触" or text == "敵":
		return "敵に接触"
	if text == "敵弾":
		return "敵弾を受けた"
	if text == "ダメージ床":
		return "ダメージ床を踏んだ"
	if text == "バナナ床":
		return "バナナ床で足を滑らせた"
	if text.ends_with("に接触"):
		return text.replace("に接触", "へ接触")
	if text.contains("突進"):
		return "%sを受けた" % text
	return "%sを受けた" % text

static func _source_breakdown_reason(source: String) -> String:
	var text := source.strip_edges()
	if text == "" or text == "接触" or text == "敵":
		return "敵に接触してメンタル崩壊"
	if text == "敵弾":
		return "敵弾を受けてメンタル崩壊"
	if text == "ダメージ床":
		return "ダメージ床を踏んでメンタル崩壊"
	if text == "バナナ床":
		return "バナナ床で足を滑らせてメンタル崩壊"
	if text.ends_with("に接触"):
		return "%sしてメンタル崩壊" % text
	return "%sでメンタル崩壊" % text

static func _death_reason_for_result(result: Dictionary, end_type: String, culprit_comment: String) -> String:
	if end_type == "completed":
		return "最後まで配信を走り切った！"
	var death_text := _clean_result_text(result.get("deathText", result.get("currentDeathText", result.get("reason", ""))), "")
	var last_source := _clean_result_text(result.get("lastDeathSource", "接触"), "接触")
	if culprit_comment != "なし":
		if culprit_comment.contains("床、全部バナナ"):
			return "「%s」中に足を滑らせてメンタル崩壊" % culprit_comment
		if culprit_comment.contains("ノーブレーキ"):
			return "「%s」中に止まれず%s" % [culprit_comment, _source_action_for_result(last_source)]
		if culprit_comment.contains("ダッシュは甘え"):
			return "「%s」中に%s" % [culprit_comment, _source_action_for_result(last_source)]
		if culprit_comment.contains("武器ミュート"):
			return "「%s」中に攻撃できず%s" % [culprit_comment, _source_action_for_result(last_source)]
		if culprit_comment.contains("ボスと戦え"):
			return "「%s」でボスに押し切られてメンタル崩壊" % culprit_comment
		if death_text != "" and death_text != "発動中の指示コメなし" and not death_text.contains(culprit_comment):
			return "「%s」中に%s" % [culprit_comment, death_text]
		return "「%s」中に%s" % [culprit_comment, _source_action_for_result(last_source)]
	return _source_breakdown_reason(last_source)

static func _trouble_note_for_result(end_type: String, culprit_comment: String) -> String:
	if end_type == "mental_breakdown" and culprit_comment == "なし":
		return "通常被弾でメンタル崩壊"
	return ""

static func result_end_type_for_stats(stats: Dictionary, quick_test_mode: bool) -> String:
	var end_type := String(stats.get("endType", ""))
	if end_type in ["mental_breakdown", "completed", "quit", "debug"]:
		return end_type
	if _is_cleared(stats, quick_test_mode):
		return "completed"
	return "mental_breakdown"

static func build_ranking_entry(stats: Dictionary) -> Dictionary:
	return {
		"dataVersion": 2,
		"runId": String(stats.get("runId", "")),
		"playerId": String(stats.get("playerId", "")),
		"playerName": String(stats.get("playerName", "")),
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
		"maxBurnCombo": max_buzz_value(stats),
		"modeId": String(stats.get("modeId", "")),
		"playMode": "single",
		"difficulty": String(stats.get("difficultyId", "normal")),
		"difficultyId": String(stats.get("difficultyId", "normal")),
		"stageId": String(stats.get("stageId", stats.get("streamFrameId", ""))),
		"modeName": String(stats.get("modeName", "")),
		"characterId": String(stats.get("characterId", "")),
		"partnerId": String(stats.get("partnerId", "")),
		"partnerName": String(stats.get("partnerName", stats.get("collabPartnerName", ""))),
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
		"boss": {
			"firstBossSpawned": bool(stats.get("firstBossSpawned", false)),
			"firstBossDefeated": bool(stats.get("firstBossDefeated", false)),
			"reignitionBossSpawned": bool(stats.get("reignitionBossSpawned", false)),
			"reignitionBossDefeated": bool(stats.get("reignitionBossDefeated", false)),
			"defeatedCount": clampi(int(stats.get("bossCount", 0)), 0, 2)
		},
		"selectedHighDifficultyCommentCount": int(stats.get("dangerCommentsChosen", 0)),
		"gameOver": String(stats.get("endType", "")) == "mental_breakdown",
		"createdAt": String(stats.get("playedAt", Time.get_datetime_string_from_system())),
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
	var max_burn_combo: int = max_buzz_value(stats)
	var relay_completed: bool = _is_relay_completed(stats)
	var ended_reason: String = "death"
	var culprit_comment: String = String(stats.get("currentComment", "なし"))
	var death_text: String = String(stats.get("currentDeathText", stats.get("reason", "")))
	if relay_completed:
		ended_reason = "completed"
		culprit_comment = "なし"
		death_text = ""
	return {
		"dataVersion": 2,
		"id": String(stats.get("runId", stats.get("playedAt", ""))),
		"runId": String(stats.get("runId", "")),
		"playerId": String(stats.get("playerId", "")),
		"playerName": String(stats.get("playerName", "")),
		"endType": String(stats.get("endType", "")),
		"modeId": "relay",
		"playMode": "relay",
		"difficulty": String(stats.get("difficultyId", "normal")),
		"difficultyId": String(stats.get("difficultyId", "normal")),
		"stageId": "relay",
		"isRankingEligible": bool(stats.get("isRankingEligible", true)),
		"characterId": String(stats.get("characterId", "")),
		"characterName": String(stats.get("characterName", "配信者")),
		"characterDisplayName": _character_nickname_for_stats(stats),
		"characterIconId": String(stats.get("characterId", "")) + "_icon",
		"partnerId": String(stats.get("partnerId", "")),
		"partnerName": String(stats.get("partnerName", stats.get("collabPartnerName", ""))),
		"score": int(stats.get("score", stats.get("relayTotalScore", 0))),
		"cleared": relay_completed,
		"gameOver": String(stats.get("endType", "")) == "mental_breakdown",
		"clearedFrameCount": cleared_count,
		"completedFrameIds": completed_frame_ids,
		"completedFrameNames": completed_frame_names,
		"currentFrameId": String(stats.get("streamFrameId", "")),
		"currentFrameName": String(stats.get("streamFrameName", "配信枠")),
		"isRelayCompleted": relay_completed,
		"relay": {
			"reachedSectionIndex": clampi(cleared_count, 0, 5),
			"reachedStageId": String(stats.get("streamFrameId", "")),
			"reachedFinalBoss": bool(stats.get("relayFinalBossReached", false)),
			"finalBossPhase": clampi(int(stats.get("relayBossPhase", 0)), 0, 3),
			"finalBossDefeated": bool(stats.get("relayBossScoreAwarded", false))
		},
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
	marshmallow_stats: Dictionary,
	song_stats: Dictionary = {},
	drawing_stats: Dictionary = {},
	collab_stats: Dictionary = {}
) -> Dictionary:
	return {
		"reason": reason,
		"endType": String(core.get("endType", "")),
		"elapsed": float(core.get("elapsed", 0.0)),
		"score": int(core.get("score", 0)),
		"viewerCount": int(core.get("viewerCount", core.get("score", 0))),
		"maxMultiplier": float(core.get("maxMultiplier", 1.0)),
		"maxVoltage": float(core.get("maxVoltage", core.get("maxMultiplier", 1.0))),
		"burnComboMax": BuzzSystemScript.clamp_percent(int(core.get("burnComboMax", 0))),
		"maxBurnCombo": BuzzSystemScript.clamp_percent(int(core.get("maxBurnCombo", core.get("burnComboMax", 0)))),
		"giftsTaken": int(core.get("giftsTaken", 0)),
		"maxGiftHype": int(core.get("maxGiftHype", 0)),
		"dangerCommentsChosen": int(core.get("dangerCommentsChosen", 0)),
		"difficultyId": String(core.get("difficultyId", "normal")),
		"heartUsedCount": int(core.get("heartUsedCount", 0)),
		"relayMode": bool(core.get("relayMode", false)),
		"relayClearedFrameCount": int(core.get("relayClearedFrameCount", 0)),
		"relayCompletedFrameIds": core.get("relayCompletedFrameIds", []),
		"relayCompletedFrameNames": core.get("relayCompletedFrameNames", []),
		"relayTotalScore": int(core.get("relayTotalScore", 0)),
		"relayMaxScore": int(core.get("relayMaxScore", 0)),
		"relayMaxMultiplier": float(core.get("relayMaxMultiplier", core.get("maxMultiplier", 1.0))),
		"relayMaxBurnCombo": BuzzSystemScript.clamp_percent(int(core.get("relayMaxBurnCombo", core.get("maxBurnCombo", core.get("burnComboMax", 0))))),
		"relayBossScoreAwarded": bool(core.get("relayBossScoreAwarded", false)),
		"relayFinalBossReached": bool(core.get("relayFinalBossReached", false)),
		"relayBossPhase": clampi(int(core.get("relayBossPhase", 0)), 0, 3),
		"partnerId": String(core.get("partnerId", "")),
		"currentComment": String(core.get("currentComment", "なし")),
		"currentDeathText": String(core.get("currentDeathText", "発動中の指示コメなし")),
		"lastDeathSource": String(core.get("lastDeathSource", "接触")),
		"bossSummoned": bool(core.get("bossSummoned", false)),
		"bossDefeated": bool(core.get("bossDefeated", false)),
		"firstBossSpawned": bool(core.get("firstBossSpawned", false)),
		"firstBossDefeated": bool(core.get("firstBossDefeated", false)),
		"reignitionBossSpawned": bool(core.get("reignitionBossSpawned", false)),
		"reignitionBossDefeated": bool(core.get("reignitionBossDefeated", false)),
		"bossCount": clampi(int(core.get("bossCount", 0)), 0, 2),
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
		"streamFrameResultText": DisplayTextSystem.stream_frame_result_text(String(core.get("streamFrameId", "")), genre_stats, marshmallow_stats, song_stats, drawing_stats, collab_stats),
		"genreEventCount": int(genre_stats.get("genreEventCount", 0)),
		"raceEventCount": int(genre_stats.get("raceEventCount", 0)),
		"bulletHellEventCount": int(genre_stats.get("bulletHellEventCount", 0)),
		"horrorEventCount": int(genre_stats.get("horrorEventCount", 0)),
		"genreEventClearCount": int(genre_stats.get("genreEventClearCount", 0)),
		"songMaxLiveHeat": float(song_stats.get("maxLiveHeat", 0.0)),
		"songMaxLiveHeatLevel": int(song_stats.get("maxLiveHeatLevel", 0)),
		"songChorusCount": int(song_stats.get("chorusCount", 0)),
		"songNotesCollected": int(song_stats.get("notesCollected", 0)),
		"songOctaveBonusCount": int(song_stats.get("octaveBonusCount", 0)),
		"songSpotlightStayTime": float(song_stats.get("spotlightStayTime", 0.0)),
		"songEncoreTriggered": bool(song_stats.get("encoreTriggered", false)),
		"songEncoreCompleted": bool(song_stats.get("encoreCompleted", false)),
		"drawingProgress": float(drawing_stats.get("progress", 0.0)),
		"drawingFillCount": int(drawing_stats.get("fillCount", 0)),
		"drawingCorrectionCount": int(drawing_stats.get("correctionCount", 0)),
		"drawingEraserCount": int(drawing_stats.get("eraserCount", 0)),
		"collabPartnerName": String(collab_stats.get("partnerName", "")),
		"collabPassSuccessCount": int(collab_stats.get("passSuccessCount", 0)),
		"collabSyncStarsCollected": int(collab_stats.get("syncStarsCollected", 0)),
		"collabPairSkillCount": int(collab_stats.get("pairSkillCount", 0)),
		"collabChallengeSuccessCount": int(collab_stats.get("challengeSuccessCount", 0)),
		"marshmallowReadCount": int(marshmallow_stats.get("answered", 0)),
		"goodMaroCount": int(marshmallow_stats.get("good", 0)),
		"godMaroCount": int(marshmallow_stats.get("god", 0)),
		"kusoMaroCount": int(marshmallow_stats.get("kuso", 0)),
		"unreadMaroCount": int(marshmallow_stats.get("unread", 0))
	}

static func build_run_stats_from_target(reason: String, target: Node) -> Dictionary:
	var hard_runtime_variant: Variant = target.get("difficulty_runtime")
	var hard_state: Dictionary = {}
	var is_high_difficulty_run := false
	if hard_runtime_variant is Dictionary:
		var runtime_data := hard_runtime_variant as Dictionary
		hard_state = runtime_data.get("bossState", {}) as Dictionary
		is_high_difficulty_run = String(runtime_data.get("difficulty", "normal")) in ["hard", "expert"]
	var first_boss_defeated := bool(hard_state.get("firstBossDefeated", false))
	var reignition_boss_defeated := bool(hard_state.get("secondBossDefeated", false))
	var first_boss_spawned := bool(hard_state.get("firstBossSpawned", first_boss_defeated))
	var reignition_boss_spawned := bool(hard_state.get("secondBossSpawned", reignition_boss_defeated))
	var hard_boss_count := (1 if first_boss_defeated else 0) + (1 if reignition_boss_defeated else 0)
	var relay_boss_phase := clampi(int(target.get("relay_boss_phase")), 0, 3)
	var relay_boss_reached := bool(target.get("relay_boss_active")) or relay_boss_phase > 0 or bool(target.get("relay_boss_score_awarded")) or String(target.get("relay_flow_state")) == "PlayingBoss"
	return build_run_stats(reason, {
		"endType": String(target.get("pending_game_over_end_type")),
		"elapsed": float(target.get("elapsed")),
		"score": int(target.get("score")),
		"viewerCount": int(target.get("score")),
		"maxMultiplier": float(target.get("max_multiplier")),
		"maxVoltage": float(target.get("max_multiplier")),
		"burnComboMax": BuzzSystemScript.clamp_percent(int(target.get("burn_combo_max"))),
		"maxBurnCombo": BuzzSystemScript.clamp_percent(int(target.get("burn_combo_max"))),
		"giftsTaken": int(target.get("gifts_taken")),
		"maxGiftHype": int(target.get("max_gift_hype")),
		"dangerCommentsChosen": int(target.get("danger_comments_chosen")),
		"heartUsedCount": int(target.get("heart_used_count")),
		"relayMode": bool(target.get("relay_mode")),
		"relayBossScoreAwarded": bool(target.get("relay_boss_score_awarded")),
		"relayFinalBossReached": relay_boss_reached,
		"relayBossPhase": relay_boss_phase if relay_boss_reached else 0,
		"relayClearedFrameCount": int(target.get("relay_cleared_frame_count")),
		"relayCompletedFrameIds": (target.get("relay_completed_frame_ids") as Array).duplicate(),
		"relayCompletedFrameNames": _frame_names_for_ids(target.get("relay_completed_frame_ids") as Array, target.get("stream_frames") as Array),
		"relayTotalScore": int(target.get("score")),
		"relayMaxScore": maxi(int(target.get("relay_max_score")), int(target.get("score"))),
		"relayMaxMultiplier": maxf(float(target.get("relay_max_multiplier")), float(target.get("max_multiplier"))),
		"relayMaxBurnCombo": BuzzSystemScript.clamp_percent(maxi(int(target.get("relay_max_burn_combo")), int(target.get("burn_combo_max")))),
		"currentComment": String(target.get("current_comment")),
		"currentDeathText": String(target.get("current_death_text")),
		"lastDeathSource": String(target.get("last_death_source")),
		"bossSummoned": bool(target.get("boss_summoned")),
		"bossDefeated": bool(target.get("boss_defeated")),
		"firstBossDefeated": first_boss_defeated,
		"reignitionBossDefeated": reignition_boss_defeated,
		"firstBossSpawned": first_boss_spawned,
		"reignitionBossSpawned": reignition_boss_spawned,
		"bossCount": hard_boss_count if is_high_difficulty_run else (1 if bool(target.get("boss_defeated")) else 0),
		"difficultyId": String(target.get("run_difficulty_id")) if target.get("run_difficulty_id") != null else "normal",
		"partnerId": String(target.get("collab_partner_id")),
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
	}, {
		"maxLiveHeat": float(target.get("song_max_live_heat")),
		"maxLiveHeatLevel": int(target.get("song_max_live_heat_level")),
		"chorusCount": int(target.get("song_chorus_count")),
		"notesCollected": int(target.get("song_total_notes_collected")),
		"octaveBonusCount": int(target.get("song_octave_bonus_count")),
		"spotlightStayTime": float(target.get("song_total_spotlight_time")),
		"encoreTriggered": bool(target.get("song_encore_triggered")),
		"encoreCompleted": bool(target.get("song_encore_completed"))
	}, {
		"progress": float(target.get("drawing_progress")),
		"fillCount": int(target.get("drawing_fill_count")),
		"correctionCount": int(target.get("drawing_correction_complete_count")),
		"eraserCount": int(target.get("drawing_eraser_used_count"))
	}, {
		"partnerName": String(target.call("_collab_partner_display_name")) if target.has_method("_collab_partner_display_name") else "",
		"passSuccessCount": int(target.get("collab_pass_success_count")),
		"syncStarsCollected": int(target.get("collab_sync_star_collected_count")),
		"pairSkillCount": int(target.get("collab_pair_skill_count")),
		"challengeSuccessCount": int(target.get("collab_challenge_success_count"))
	})

static func complete_run_stats(stats: Dictionary) -> Dictionary:
	var result: Dictionary = stats.duplicate()
	result["kamiPoint"] = calculate_kami_point(result)
	var rank: String = calculate_rank(result)
	result["rank"] = rank
	result["timeText"] = format_time(float(result.get("elapsed", 0.0)))
	return result

static func complete_run_for_target(reason: String, target: Node, quick_test_mode: bool) -> Dictionary:
	var existing_result: Variant = target.get("last_result_stats")
	var existing_tracker: Variant = target.get("power_up_run_tracker")
	if existing_tracker != null and bool(existing_tracker.result_committed) and existing_result is Dictionary:
		return (existing_result as Dictionary).duplicate(true)
	var result: Dictionary = build_run_stats_from_target(reason, target)
	var relay_mode: bool = bool(target.get("relay_mode"))
	result["modeId"] = "relay" if relay_mode else ("test_60" if quick_test_mode else "normal_180")
	result["modeName"] = "配信リレー" if relay_mode else ("テスト配信" if quick_test_mode else "通常配信")
	result["difficultyId"] = String(target.get("run_difficulty_id")) if target.get("run_difficulty_id") != null else "normal"
	result["stageId"] = "relay" if relay_mode else String(result.get("streamFrameId", ""))
	var high_difficulty_relay := relay_mode and String(result.get("difficultyId", "normal")) in ["hard", "expert"]
	var relay_eligible := relay_mode and (high_difficulty_relay or bool(target.get("relay_boss_score_awarded")))
	result["isRankingEligible"] = (not quick_test_mode) and (not relay_mode or relay_eligible)
	result["isRelayRankingEligible"] = bool(result["isRankingEligible"]) and relay_mode
	result["gameOver"] = String(result.get("endType", "")) == "mental_breakdown"
	result["cleared"] = _is_cleared(result, quick_test_mode)
	result["endType"] = result_end_type_for_stats(result, quick_test_mode)
	result["playedAt"] = Time.get_datetime_string_from_system()
	result["runId"] = String(target.get("run_id"))
	if String(result["runId"]).strip_edges() == "":
		result["runId"] = "%s_%d" % [String(result["playedAt"]).replace(":", "").replace("-", "").replace("T", "_"), int(result.get("score", 0))]
	result = complete_run_stats(result)
	if not quick_test_mode:
		CodexManager.record_character_result(result)
	# This is the single result-commit point for difficulty progression.  The
	# system is run before the legacy normal-frame projection and carries a
	# per-run guard so reward retries or result redraws cannot double-record it.
	var difficulty_progress_result: Dictionary = DifficultyProgressSystemScript.record_result_for_target(target, result, quick_test_mode)
	result["difficultyProgress"] = difficulty_progress_result
	var difficulty_unlocks: Array = difficulty_progress_result.get("newlyUnlocked", []) as Array
	if not difficulty_unlocks.is_empty():
		result["difficultyUnlockMessage"] = "New difficulty unlocked: %s" % ", ".join(difficulty_unlocks)
	var reward_commit := _commit_power_up_reward(result, target)
	var committed_reward = reward_commit.get("reward", null)
	var reward_data: Dictionary = committed_reward.to_dictionary() if committed_reward != null and committed_reward.has_method("to_dictionary") else {}
	var grant_state := String(reward_commit.get("state", "unavailable"))
	var points_before := int(reward_commit.get("beforeBalance", 0))
	var points_after := int(reward_commit.get("balance", points_before))
	var points_earned := int(reward_commit.get("earnedPoints", 0))
	result["streamPointReward"] = reward_data
	result["ppGrantState"] = grant_state
	result["seniorUnitUnlocked"] = bool(reward_commit.get("seniorUnitUnlocked", false))
	result["streamPointBalance"] = points_after
	result["pointRewardView"] = build_point_reward_view(
		reward_data,
		grant_state,
		points_before,
		points_earned,
		points_after,
		relay_mode
	)
	var unlock_result: Dictionary = {"message": ""}
	if not relay_mode:
		unlock_result = StreamFrameSystem.clear_frame_for_target(target, result)
	var legacy_unlock_message := String(unlock_result.get("message", ""))
	result["unlockMessage"] = legacy_unlock_message if legacy_unlock_message != "" else String(result.get("difficultyUnlockMessage", ""))
	if bool(reward_commit.get("seniorUnitUnlocked", false)):
		for character_id in ["aosumi_kyasumi", "akarine_rizumu", "shizuki_miimu"]:
			CodexManager.discover_character(character_id)
	var session_discoveries: Dictionary = CodexManager.finish_run(String(result.get("runId", "")))
	result["sessionDiscoveries"] = session_discoveries.duplicate(true)
	if not quick_test_mode:
		var final_progress: Variant = target.get("difficulty_progress")
		if final_progress is Dictionary:
			# record_result_for_target saves before PP rewards are committed.  This
			# final write captures both the reward unlock and any codex discoveries.
			DifficultyProgressSystemScript.save_progress(final_progress as Dictionary)
	var result_data: Dictionary = build_result_data(result)
	var ranking_entry := build_relay_ranking_entry(result) if relay_mode else build_ranking_entry(result)
	result["rankingText"] = RankingSystem.save_entry_and_format(ranking_entry, bool(result["isRankingEligible"]))
	result_data["rankingText"] = String(result.get("rankingText", ""))
	result_data["rankingRegistered"] = bool(result["isRankingEligible"]) and not String(result.get("rankingText", "")).contains("保存できません")
	result["resultData"] = result_data
	target.set("last_result_data", result_data)
	result["resultText"] = build_result_text(result)
	target.set("last_result_stats", result.duplicate(true))
	return result

static func _commit_power_up_reward(result: Dictionary, target: Node) -> Dictionary:
	var tracker_variant: Variant = target.get("power_up_run_tracker")
	var manager_variant: Variant = target.get("power_up_shop_manager")
	if tracker_variant == null or manager_variant == null:
		return {"state": "unavailable", "balance": 0, "reward": StreamPointRewardResultScript.new()}
	var tracker = tracker_variant
	var manager = manager_variant
	if manager == null:
		return {"state": "unavailable", "balance": 0, "reward": StreamPointRewardResultScript.new()}
	var outcome := "completed" if String(result.get("endType", "")) == "completed" else ("defeated" if String(result.get("endType", "")) == "mental_breakdown" else "retired")
	var input: Dictionary = tracker.reward_input(
		bool(result.get("relayMode", false)),
		outcome,
		float(result.get("elapsed", 0.0)),
		String(result.get("stageId", result.get("streamFrameId", ""))),
		bool(result.get("cleared", false)),
		(result.get("relayCompletedFrameIds", []) as Array)
	)
	input["difficultyId"] = String(target.get("run_difficulty_id")) if target.get("run_difficulty_id") != null else String(input.get("difficultyId", "normal"))
	if input["difficultyId"] == "hard":
		input["difficultyMultiplier"] = 1.20 if bool(result.get("cleared", false)) else 0.60
	var profile: Dictionary = manager.profile as Dictionary
	var reward = StreamPointRewardCalculatorScript.calculate(
		input,
		profile.get("firstStageClears", {}) as Dictionary,
		profile.get("firstBossDefeats", {}) as Dictionary,
		bool(profile.get("firstRelayClear", false)),
		manager.database.reward_rules
	)
	var before_balance: int = int(manager.current_points())
	var senior_unlock_eligible: bool = tracker.should_unlock_senior_unit(input)
	var grant: Dictionary = manager.grant_reward(tracker.run_id, reward, senior_unlock_eligible)
	if bool(grant.get("ok", false)):
		tracker.result_committed = true
		target.set("pending_power_up_reward", null)
		var after_balance: int = int(grant.get("balance", manager.current_points()))
		var grant_state := String(grant.get("state", "granted"))
		var earned_points := maxi(0, after_balance - before_balance) if grant_state == "granted" else 0
		return {"state": grant_state, "beforeBalance": before_balance, "earnedPoints": earned_points, "balance": after_balance, "reward": reward, "seniorUnitUnlocked": bool(grant.get("seniorUnitUnlocked", false))}
	target.set("pending_power_up_reward", reward)
	var failure_state := String(grant.get("state", "save_failed"))
	if failure_state != "save_failed":
		failure_state = "save_failed"
	return {"state": failure_state, "beforeBalance": before_balance, "earnedPoints": 0, "balance": int(manager.current_points()), "reward": reward, "seniorUnitUnlocked": false}

static func retry_power_up_reward_for_target(target: Node) -> Dictionary:
	var tracker_variant: Variant = target.get("power_up_run_tracker")
	var manager = target.get("power_up_shop_manager")
	var pending_variant: Variant = target.get("pending_power_up_reward")
	if tracker_variant == null or manager == null or pending_variant == null or not pending_variant.has_method("to_dictionary"):
		return {"ok": false, "state": "nothing_to_retry"}
	var tracker = tracker_variant
	var reward = pending_variant
	var before_balance: int = int(manager.current_points())
	var grant: Dictionary = manager.grant_reward(tracker.run_id, reward)
	if bool(grant.get("ok", false)):
		tracker.result_committed = true
		target.set("pending_power_up_reward", null)
		var result_data: Dictionary = target.get("last_result_data") as Dictionary
		result_data["ppGrantState"] = String(grant.get("state", "granted"))
		result_data["streamPointBalance"] = int(grant.get("balance", manager.current_points()))
		result_data["streamPointReward"] = reward.to_dictionary()
		var after_balance: int = int(grant.get("balance", manager.current_points()))
		var previous_view: Dictionary = result_data.get("pointRewardView", {}) as Dictionary
		result_data["pointRewardView"] = build_point_reward_view(
			reward.to_dictionary(),
			String(grant.get("state", "granted")),
			int(previous_view.get("pointsBefore", before_balance)),
			maxi(0, after_balance - int(previous_view.get("pointsBefore", before_balance))),
			after_balance,
			bool(result_data.get("relayMode", false))
		)
		target.set("last_result_data", result_data)
		return {"ok": true, "state": "granted", "balance": manager.current_points()}
	return {"ok": false, "state": String(grant.get("state", "save_failed"))}

static func point_reward_display_rows(stream_reward: Dictionary, relay_mode: bool) -> Array:
	var entries: Array = []
	if relay_mode:
		entries = [
			{"key": "participationPp", "id": "relay_participation", "displayName": "リレー参加", "isOneTimeBonus": false},
			{"key": "relayStagePp", "id": "relay_stage", "displayName": "配信枠突破", "isOneTimeBonus": false},
			{"key": "relayFinalReachedPp", "id": "relay_final_reached", "displayName": "ラスボス戦到達", "isOneTimeBonus": false},
			{"key": "relayFinalClearPp", "id": "relay_final_clear", "displayName": "ラストオフライン撃破", "isOneTimeBonus": false},
			{"key": "bossDefeatPp", "id": "relay_boss_defeat", "displayName": "指示コメボス討伐", "isOneTimeBonus": false},
			{"key": "firstRelayClearPp", "id": "first_relay_clear", "displayName": "リレー初回完走", "isOneTimeBonus": true}
		]
	else:
		entries = [
			{"key": "participationPp", "id": "participation", "displayName": "参加報酬", "isOneTimeBonus": false},
			{"key": "progressPp", "id": "progress", "displayName": "配信継続", "isOneTimeBonus": false},
			{"key": "clearPp", "id": "clear", "displayName": "配信クリア", "isOneTimeBonus": false},
			{"key": "bossDefeatPp", "id": "boss_defeat", "displayName": "ボス討伐", "isOneTimeBonus": false},
			{"key": "firstStageClearPp", "id": "first_stage_clear", "displayName": "配信枠初回クリア", "isOneTimeBonus": true},
			{"key": "firstBossDefeatPp", "id": "first_boss_defeat", "displayName": "ボス初回討伐", "isOneTimeBonus": true}
		]
	var rows: Array = []
	var subtotal := 0
	for entry_value in entries:
		var entry: Dictionary = entry_value as Dictionary
		var amount := int(stream_reward.get(String(entry["key"]), 0))
		if amount <= 0:
			continue
		subtotal += amount
		rows.append({
			"id": String(entry["id"]),
			"displayName": String(entry["displayName"]),
			"amount": amount,
			"isOneTimeBonus": bool(entry["isOneTimeBonus"])
		})
	var field_gift_pp := int(stream_reward.get("fieldGiftPp", 0))
	if field_gift_pp > 0:
		subtotal += field_gift_pp
		rows.append({"id": "field_gift_pp", "displayName": "フィールドギフト", "amount": field_gift_pp, "isOneTimeBonus": false})
	var gift_conversion_pp := int(stream_reward.get("fallbackGiftPp", 0)) + int(stream_reward.get("fullBuildConversionPp", 0))
	if gift_conversion_pp > 0:
		subtotal += gift_conversion_pp
		rows.append({"id": "gift_conversion_pp", "displayName": "ギフト変換", "amount": gift_conversion_pp, "isOneTimeBonus": false})
	var total := int(stream_reward.get("totalPp", subtotal))
	var adjustment := total - subtotal
	if adjustment != 0:
		rows.append({
			"id": "difficulty_adjustment",
			"displayName": "難易度調整",
			"amount": adjustment,
			"isOneTimeBonus": false
		})
	return rows

static func build_point_reward_view(stream_reward: Dictionary, grant_state: String, points_before: int, points_earned: int, points_after: int, relay_mode: bool) -> Dictionary:
	var rows: Array = []
	if grant_state != "already_granted" and grant_state != "unavailable":
		rows = point_reward_display_rows(stream_reward, relay_mode)
	return {
		"grantState": grant_state,
		"pointsBefore": points_before,
		"pointsEarned": points_earned,
		"pointsAfter": points_after,
		"rewardRows": rows
	}

static func result_stream_frame_display_name(result: Dictionary) -> String:
	if bool(result.get("relayMode", false)):
		return "配信リレー"
	var frame_id := String(result.get("streamFrameId", "")).strip_edges().to_lower()
	if frame_id == "":
		frame_id = String(result.get("stageId", "")).strip_edges().to_lower()
	if frame_id != "":
		frame_id = DifficultyProgressSystemScript.normalize_stage_id(frame_id)
	match frame_id:
		"zatsudan":
			return "雑談枠"
		"gameplay":
			return "ゲーム実況枠"
		"singing":
			return "歌枠"
		"drawing":
			return "お絵かき枠"
		"collab":
			return "コラボ枠"
		"relay":
			return "配信リレー"
	var fallback := String(result.get("streamFrameName", "")).strip_edges()
	return fallback if fallback != "" else "配信枠"

static func build_result_data(result: Dictionary) -> Dictionary:
	var end_type := String(result.get("endType", ""))
	var run_difficulty_id := DifficultyProgressSystemScript.normalize_difficulty_id(result.get("runDifficultyId", result.get("difficultyId", "normal")))
	var culprit_comment := _culprit_comment_for_result(result, end_type)
	var death_reason_text := _death_reason_for_result(result, end_type, culprit_comment)
	var trouble_note := _trouble_note_for_result(end_type, culprit_comment)
	var death_text := "" if end_type == "completed" else String(result.get("deathText", result.get("currentDeathText", result.get("reason", ""))))
	var last_death_source := "なし" if end_type == "completed" else String(result.get("lastDeathSource", "接触"))
	var final_blow_text := _last_blow_for_result(result, end_type)
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
		"difficultyId": String(result.get("difficultyId", "normal")),
		"runDifficultyId": run_difficulty_id,
		"difficulty": String(result.get("difficultyId", "normal")),
		"relayMode": bool(result.get("relayMode", false)),
		"stageId": String(result.get("stageId", result.get("streamFrameId", ""))),
		"isRankingEligible": bool(result.get("isRankingEligible", false)),
		"rankingRegistered": bool(result.get("isRankingEligible", false)),
		"characterId": String(result.get("characterId", "")),
		"partnerId": String(result.get("partnerId", "")),
		"seniorUnitUnlocked": bool(result.get("seniorUnitUnlocked", false)),
		"characterName": String(result.get("characterName", "配信者")),
		"streamFrameId": String(result.get("streamFrameId", "")),
		"streamFrameName": result_stream_frame_display_name(result),
		"relayClearedFrameCount": int(result.get("relayClearedFrameCount", 0)),
		"relayCompletedFrameIds": result.get("relayCompletedFrameIds", []),
		"relayCompletedFrameNames": result.get("relayCompletedFrameNames", []),
		"relayMaxViewerCount": maxi(int(result.get("relayMaxScore", 0)), int(result.get("viewerCount", result.get("score", 0)))),
		"relayTotalViewerCount": int(result.get("score", result.get("relayTotalScore", 0))),
		"relayMaxVoltage": maxf(float(result.get("relayMaxMultiplier", 1.0)), float(result.get("maxVoltage", result.get("maxMultiplier", 1.0)))),
		"relayMaxBurnCombo": BuzzSystemScript.clamp_percent(maxi(int(result.get("relayMaxBurnCombo", 0)), int(result.get("maxBurnCombo", result.get("burnComboMax", 0))))),
		"isRelayCompleted": _is_relay_completed(result),
		"score": int(result.get("score", 0)),
		"viewerCount": int(result.get("viewerCount", result.get("score", 0))),
		"kamiRank": String(result.get("rank", "D")),
		"kamiPoint": int(result.get("kamiPoint", 0)),
		"survivalTime": float(result.get("elapsed", 0.0)),
		"cleared": bool(result.get("cleared", false)),
		"maxMultiplier": float(result.get("maxMultiplier", 1.0)),
		"maxVoltage": float(result.get("maxVoltage", result.get("maxMultiplier", 1.0))),
		"maxBurnCombo": BuzzSystemScript.clamp_percent(int(result.get("maxBurnCombo", result.get("burnComboMax", 0)))),
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
		"culpritInstructionComment": culprit_comment,
		"deathText": death_text,
		"deathReasonText": death_reason_text,
		"troubleNote": trouble_note,
		"lastDeathSource": last_death_source,
		"finalBlowText": final_blow_text,
		"summaryLine": result_summary_for_end_type(end_type, fallback_summary),
		"streamFrameResultText": String(result.get("streamFrameResultText", "")),
		"unlockMessage": String(result.get("unlockMessage", "")),
		"streamPointReward": result.get("streamPointReward", {}),
		"ppGrantState": String(result.get("ppGrantState", "unavailable")),
		"streamPointBalance": int(result.get("streamPointBalance", 0)),
		"pointRewardView": result.get("pointRewardView", {}),
		"rankingText": String(result.get("rankingText", "")),
		"bossSummoned": bool(result.get("bossSummoned", false)),
		"bossDefeated": bool(result.get("bossDefeated", false)),
		"bossName": String(result.get("bossName", "")),
		"bossResult": String(result.get("bossResult", "")),
		"bossRewardViewer": int(result.get("bossRewardViewer", 0)),
		"boss": {"firstBossSpawned": bool(result.get("firstBossSpawned", false)), "firstBossDefeated": bool(result.get("firstBossDefeated", false)), "reignitionBossSpawned": bool(result.get("reignitionBossSpawned", false)), "reignitionBossDefeated": bool(result.get("reignitionBossDefeated", false)), "defeatedCount": clampi(int(result.get("bossCount", 0)), 0, 2)},
		"selectedHighDifficultyCommentCount": int(result.get("dangerCommentsChosen", 0)),
		"relay": {"reachedSectionIndex": clampi(int(result.get("relayClearedFrameCount", 0)), 0, 5), "reachedStageId": String(result.get("streamFrameId", "")), "reachedFinalBoss": bool(result.get("relayFinalBossReached", false)), "finalBossPhase": clampi(int(result.get("relayBossPhase", 0)), 0, 3), "finalBossDefeated": bool(result.get("relayBossScoreAwarded", false))},
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
		"sessionDiscoveries": result.get("sessionDiscoveries", {}).duplicate(true),
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
		"最大同時視聴者数：%d人  生存：%s  最大ボルテージ：x%.1f  最大バズ度：%d%%" % [
			int(stats.get("score", 0)),
			String(stats.get("timeText", "00:00")),
			float(stats.get("maxMultiplier", 1.0)),
			max_buzz_value(stats)
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
		var completed_point_view: Dictionary = stats.get("pointRewardView", {}) as Dictionary
		lines[0] = "%s  %s  +%d PP" % [header, String(stats.get("rank", "D")), int(completed_point_view.get("pointsEarned", 0))]
		if relay_mode and _is_relay_completed(stats):
			lines.append("RELAY COMPLETE")
		lines.append("配信結果：最後まで配信を走り切った！")
		lines.append("最終指示コメ：%s" % String(stats.get("currentComment", "なし")))
	else:
		lines.append("挑戦指示コメ：%s" % String(stats.get("currentComment", "なし")))
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
	var reward_data: Dictionary = stats.get("streamPointReward", {}) as Dictionary
	var pp_state := String(stats.get("ppGrantState", "unavailable"))
	if pp_state == "save_failed":
		lines.append("PP保存に失敗しました。ショップから再試行できます")
	elif int(reward_data.get("totalPp", 0)) > 0:
		lines.append("パワーアップPP  +%d  / 所持 %d PP" % [int(reward_data.get("totalPp", 0)), int(stats.get("streamPointBalance", 0))])
	if ranking_text != "":
		lines.append("")
		lines.append(ranking_text)
	var discovery_lines := _session_discovery_lines(stats.get("sessionDiscoveries", {}))
	if not discovery_lines.is_empty():
		lines.append("")
		lines.append_array(discovery_lines)
	lines.append("")
	lines.append("Enter / Space：もう一回    R：ランキング    Esc：タイトルへ")
	return "\n".join(lines)

static func _legacy_session_discovery_lines(snapshot_value: Variant) -> Array[String]:
	var snapshot: Dictionary = snapshot_value as Dictionary if snapshot_value is Dictionary else {}
	var masters: Dictionary = {}
	for category in [CodexManager.CATEGORY_CHARACTER, CodexManager.CATEGORY_WEAPON, CodexManager.CATEGORY_ACCESSORY, CodexManager.CATEGORY_ENEMY, CodexManager.CATEGORY_COMMENT]:
		var by_id: Dictionary = {}
		for master_value in CodexManager.get_master_entries(category):
			if master_value is Dictionary:
				by_id[String((master_value as Dictionary).get("id", ""))] = master_value
		masters[category] = by_id
	var groups := CodexPresentationSystemScript.session_discovery_groups(snapshot, masters)
	var lines: Array[String] = ["NEW DISCOVERIES"]
	var total := 0
	for group_value in groups:
		if not group_value is Dictionary:
			continue
		var group := group_value as Dictionary
		var names: Array = group.get("names", []) as Array
		if names.is_empty():
			continue
		var shown: Array[String] = []
		for name_value in names:
			if total >= 12 or shown.size() >= 4:
				break
			shown.append(String(name_value))
			total += 1
		if shown.is_empty():
			break
		var omitted := names.size() - shown.size()
		var suffix := " ほか%d件" % omitted if omitted > 0 else ""
		lines.append("%s: %s%s" % [String(group.get("label", "")), ", ".join(shown), suffix])
		if total >= 12:
			break
	return [] if lines.size() == 1 else lines

static func _session_discovery_lines(snapshot_value: Variant) -> Array[String]:
	var snapshot: Dictionary = snapshot_value as Dictionary if snapshot_value is Dictionary else {}
	var summary := CodexManager.summarize_session_discoveries(snapshot)
	var total := int(summary.get("total", 0))
	if total <= 0:
		return []
	var lines: Array[String] = ["図鑑更新 %d件" % total, "NEW DISCOVERIES"]
	var shown_total := 0
	for category in CodexManager.CATEGORIES:
		var group: Dictionary = (summary.get("categories", {}) as Dictionary).get(category, {}) as Dictionary
		var count := int(group.get("count", 0))
		if count <= 0:
			continue
		var names: Array = group.get("names", []) as Array
		var shown: Array[String] = []
		for name_value in names:
			if shown_total >= 12 or shown.size() >= 4:
				break
			shown.append(String(name_value))
			shown_total += 1
		var omitted := count - shown.size()
		var suffix := " ほか%d件" % omitted if omitted > 0 else ""
		var label := String(CodexPresentationSystemScript.CODEX_CATEGORY_LABELS.get(category, category))
		lines.append("%s: %s%s" % [label, ", ".join(shown), suffix])
		if shown_total >= 12:
			break
	return lines

static func _is_cleared(stats: Dictionary, quick_test_mode: bool) -> bool:
	if bool(stats.get("relayMode", false)) and _is_relay_completed(stats):
		return true
	var required_time: float = 60.0 if quick_test_mode else 180.0
	var reason: String = String(stats.get("reason", ""))
	return float(stats.get("elapsed", 0.0)) >= required_time - 0.05 or reason.contains("成功") or reason.contains("完走")


static func _is_relay_completed(stats: Dictionary) -> bool:
	return bool(stats.get("relayBossScoreAwarded", false))
	# Reaching the final-boss arena is not a relay clear. The target flag is
	# set only after the final boss defeat awards the relay score.
	if bool(stats.get("relayBossScoreAwarded", false)):
		return true
	if String(stats.get("reason", "")).contains("完走"):
		return true
	if bool(stats.get("isRelayCompleted", false)):
		return true
	return false


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
