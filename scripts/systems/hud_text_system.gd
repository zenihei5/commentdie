class_name HudTextSystem
extends RefCounted

const DifficultyProgressSystemScript := preload("res://scripts/systems/difficulty_progress_system.gd")
const GameFontSystemScript := preload("res://scripts/systems/game_font_system.gd")

const INSTRUCTION_MULTIPLIER_BADGE_SIZE := Vector2(176.0, 28.0)
const INSTRUCTION_MULTIPLIER_BADGE_GAP := 14.0
const INSTRUCTION_MULTIPLIER_TITLE_SAFE_GAP := 16.0
const HARD_CLIMAX_HUD_BADGE_SIZE := Vector2(210.0, 42.0)
const HARD_CLIMAX_HUD_BADGE_GAP := 14.0
const HARD_CLIMAX_TITLE_SAFE_GAP := 16.0

static func status_text(stats: Dictionary) -> String:
	return "EXP %d/%d   効果 %ss   武器:%s   アクセ:%s" % [
		int(stats.get("expValue", 0)),
		int(stats.get("expNeed", 0)),
		String(stats.get("effectText", "00")),
		String(stats.get("weaponSlots", "空き")),
		String(stats.get("accessorySlots", "空き"))
	]

static func stream_frame_card_view(context: Dictionary) -> Dictionary:
	var difficulty_id := DifficultyProgressSystemScript.normalize_difficulty_id(context.get("difficultyId", "normal"))
	var frame_name := "配信リレー" if bool(context.get("relayMode", false)) else _stream_frame_card_name(context)
	return {
		"frameName": frame_name,
		"difficultyId": difficulty_id,
		"difficultyLabel": DifficultyProgressSystemScript.difficulty_display_name(difficulty_id)
	}

static func stream_frame_card_badge_rect(card_rect: Rect2) -> Rect2:
	return Rect2(Vector2(card_rect.end.x - 76.0, card_rect.position.y + 10.0), Vector2(58.0, 20.0))

static func hard_climax_view(context: Dictionary) -> Dictionary:
	var difficulty_id := DifficultyProgressSystemScript.normalize_difficulty_id(context.get("difficultyId", "normal"))
	var state := String(context.get("state", ""))
	var relay_boss_active := bool(context.get("relayBossActive", false))
	var runtime_value: Variant = context.get("difficultyRuntime", {})
	var runtime: Dictionary = runtime_value as Dictionary if runtime_value is Dictionary else {}
	var climax_value: Variant = runtime.get("climax", {})
	var climax: Dictionary = climax_value as Dictionary if climax_value is Dictionary else {}
	var play_mode := String(runtime.get("playMode", ""))
	var visible := (
		state == "playing"
		and difficulty_id in ["hard", "expert"]
		and bool(climax.get("active", false))
		and not relay_boss_active
		and play_mode != "relayFinalBoss"
	)
	return {
		"visible": visible,
		"title": "終盤ボーナス中",
		"description": "通常敵の撃破スコア＋20％"
	}

static func instruction_multiplier_view(context: Dictionary) -> Dictionary:
	var active := bool(context.get("active", false))
	var effect_timer := float(context.get("effectTimer", 0.0))
	if not active or effect_timer <= 0.0:
		return {"visible": false, "value": 0.0, "text": ""}
	var relay_boss_active := bool(context.get("relayBossActive", false))
	var multiplier := 0.0
	var source_id := ""
	if relay_boss_active:
		var boss_instruction_value: Variant = context.get("relayBossInstruction", {})
		var boss_instruction: Dictionary = boss_instruction_value as Dictionary if boss_instruction_value is Dictionary else {}
		if String(boss_instruction.get("category", "")) == "boss_support":
			return {"visible": false, "value": 0.0, "text": ""}
		multiplier = float(boss_instruction.get("multiplier", 1.0))
		source_id = String(boss_instruction.get("id", ""))
	else:
		var view_value: Variant = context.get("resolvedCommentView", {})
		var view: Dictionary = view_value as Dictionary if view_value is Dictionary else {}
		if view.is_empty() or not view.has("multiplier"):
			return {"visible": false, "value": 0.0, "text": ""}
		multiplier = float(view.get("multiplier", 1.0))
		if bool(context.get("commentBoost", false)):
			multiplier *= 1.2
		source_id = String(view.get("id", ""))
	if is_nan(multiplier) or is_inf(multiplier) or multiplier < 0.0:
		return {"visible": false, "value": 0.0, "text": ""}
	return {
		"visible": true,
		"value": multiplier,
		"text": "スコア倍率 ×%.1f" % multiplier,
		"sourceId": source_id
	}

static func instruction_countdown_layout(rect: Rect2, multiplier_visible: bool, climax_visible: bool = false) -> Dictionary:
	var remaining_rect := Rect2(rect.position + Vector2(rect.size.x - 152.0, 11.0), Vector2(124.0, 28.0))
	var title_pos := rect.position + Vector2(156.0, 33.0)
	var title_width := 800.0
	var multiplier_rect := Rect2(Vector2.ZERO, Vector2.ZERO)
	var climax_rect := Rect2(Vector2.ZERO, Vector2.ZERO)
	var reserved_left := remaining_rect.position.x
	if multiplier_visible:
		multiplier_rect = Rect2(
			remaining_rect.position - Vector2(INSTRUCTION_MULTIPLIER_BADGE_GAP + INSTRUCTION_MULTIPLIER_BADGE_SIZE.x, 0.0),
			INSTRUCTION_MULTIPLIER_BADGE_SIZE
		)
		reserved_left = multiplier_rect.position.x
	if climax_visible:
		climax_rect = Rect2(
			Vector2(reserved_left - HARD_CLIMAX_HUD_BADGE_GAP - HARD_CLIMAX_HUD_BADGE_SIZE.x, rect.position.y + 5.0),
			HARD_CLIMAX_HUD_BADGE_SIZE
		)
		reserved_left = climax_rect.position.x
	if multiplier_visible or climax_visible:
		title_width = maxf(1.0, reserved_left - title_pos.x - (HARD_CLIMAX_TITLE_SAFE_GAP if climax_visible else INSTRUCTION_MULTIPLIER_TITLE_SAFE_GAP))
	return {
		"titlePos": title_pos,
		"titleWidth": title_width,
		"multiplierRect": multiplier_rect,
		"climaxRect": climax_rect,
		"remainingRect": remaining_rect
	}

static func instruction_title_layout(text: String, available_width: float, desired_size: int = 28, minimum_size: int = 16) -> Dictionary:
	var safe_width := maxf(1.0, available_width)
	var top_size := maxi(minimum_size, desired_size)
	var font := GameFontSystemScript.black_font()
	for text_size in range(top_size, minimum_size - 1, -1):
		if font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, text_size).x <= safe_width:
			return {"text": text, "size": text_size}
	var ellipsis := "…"
	for length in range(text.length(), 0, -1):
		var shortened := text.substr(0, length) + ellipsis
		if font.get_string_size(shortened, HORIZONTAL_ALIGNMENT_LEFT, -1.0, minimum_size).x <= safe_width:
			return {"text": shortened, "size": minimum_size}
	return {"text": ellipsis, "size": minimum_size}

static func _stream_frame_card_name(context: Dictionary) -> String:
	var frame_value: Variant = context.get("streamFrame", {})
	var frame: Dictionary = frame_value as Dictionary if frame_value is Dictionary else {}
	var display_name := String(frame.get("displayName", "")).strip_edges()
	if display_name != "":
		return display_name
	var frame_id := String(context.get("streamFrameId", frame.get("id", ""))).strip_edges().to_lower()
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
	return "雑談枠"

static func texts_for_target(target: Node, comment_barrage_label: String, gift_arrival_text: String, active_genre_label: String, next_known_genre_label: String) -> Dictionary:
	var effect_text: String = "%02d" % int(ceil(maxf(0.0, float(target.get("effect_timer")))))
	var current_character: Dictionary = target.get("current_character") as Dictionary
	var current_stream_frame: Dictionary = target.get("current_stream_frame") as Dictionary
	var current_weapon: Dictionary = target.get("current_weapon") as Dictionary
	var weapons: Array[String] = EquipmentSystem.weapon_names(target.get("player_weapons") as Array, target.get("weapons") as Array)
	var accessories: Array[String] = EquipmentSystem.accessory_names(target.get("player_accessories") as Array, target.get("gifts") as Array)
	return {
		"status": status_text({
			"score": int(target.get("score")),
			"expValue": int(target.get("exp_value")),
			"expNeed": ExpSystem.current_need(int(target.get("exp_level"))),
			"effectText": effect_text,
			"characterName": String(current_character.get("displayName", "赤羽ばんり")),
			"streamFrameName": String(current_stream_frame.get("displayName", "雑談枠")),
			"weaponName": String(current_weapon.get("displayName", "BANハンマー")),
			"weaponSlots": EquipmentSystem.slot_summary(weapons, EquipmentSystem.MAX_WEAPONS),
			"accessorySlots": EquipmentSystem.slot_summary(accessories, EquipmentSystem.MAX_ACCESSORIES)
		}),
		"banner": banner_text({
			"state": String(target.get("state")),
			"quickTestMode": bool(target.get("quick_test_mode")),
			"relayMode": bool(target.get("relay_mode")),
			"relayModeUnlocked": bool(target.get("relay_mode_unlocked")),
			"commentBarrageLabel": comment_barrage_label,
			"screenShakeEnabled": bool(target.get("screen_shake_enabled")),
			"choiceTimer": float(target.get("choice_timer")),
			"heartPending": bool(target.get("heart_pending")),
			"giftArrivalText": gift_arrival_text,
			"activeGenreEvent": String(target.get("active_genre_event")),
			"activeGenreLabel": active_genre_label,
			"genreEventTimer": float(target.get("genre_event_timer")),
			"strategyWiki": bool(target.get("strategy_wiki")),
			"nextKnownGenreEvent": String(target.get("next_known_genre_event")),
			"nextKnownGenreLabel": next_known_genre_label,
			"commentTimer": float(target.get("comment_timer"))
		})
	}

static func update_labels_for_target(
	target: Node,
	status_label: Label,
	banner_label: Label,
	comment_barrage_label: String,
	gift_arrival_text: String,
	active_genre_label: String,
	next_known_genre_label: String
) -> void:
	var texts: Dictionary = texts_for_target(
		target,
		comment_barrage_label,
		gift_arrival_text,
		active_genre_label,
		next_known_genre_label
	)
	status_label.text = String(texts["status"])
	banner_label.text = String(texts["banner"])
	var banner_parent: Control = banner_label.get_parent() as Control
	if banner_parent != null:
		banner_parent.visible = banner_label.text.strip_edges() != ""

static func banner_text(context: Dictionary) -> String:
	var state: String = String(context.get("state", "title"))
	if state == "title":
		return ""
	if state == "ranking":
		return ""
	if state == "options":
		return ""
	if state == "character_select":
		return ""
	if state == "stream_frame_select":
		return ""
	if state == "tutorial":
		return "チュートリアル  Enter / Spaceで開始"
	if state == "comment_choice":
		return ""
	if state == "gift_choice":
		return ""
	if state == "pause":
		return ""
	if String(context.get("activeGenreEvent", "")) != "":
		return ""
	if bool(context.get("strategyWiki", false)) and String(context.get("nextKnownGenreEvent", "")) != "":
		return "次のゲーム変化：%s" % String(context.get("nextKnownGenreLabel", ""))
	return ""
