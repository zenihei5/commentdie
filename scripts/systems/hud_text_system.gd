class_name HudTextSystem
extends RefCounted

static func status_text(stats: Dictionary) -> String:
	return "EXP %d/%d   効果 %ss   武器:%s   アクセ:%s" % [
		int(stats.get("expValue", 0)),
		int(stats.get("expNeed", 0)),
		String(stats.get("effectText", "00")),
		String(stats.get("weaponSlots", "空き")),
		String(stats.get("accessorySlots", "空き"))
	]

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
		var mode_text: String = "配信リレー" if bool(context.get("relayMode", false)) else ("60秒テスト" if bool(context.get("quickTestMode", false)) else "180秒通常")
		var relay_text: String = "ON" if bool(context.get("relayModeUnlocked", false)) else "LOCKED"
		return "タイトル  T:%s / R:リレー %s / U:解放 / B:%s / 画面揺れ:%s" % [
			mode_text,
			relay_text,
			String(context.get("commentBarrageLabel", "通常")),
			"ON" if bool(context.get("screenShakeEnabled", true)) else "OFF"
		]
	if state == "ranking":
		return "ランキング  Esc：タイトルへ戻る / R：リセット"
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
		return "ポーズ"
	if String(context.get("activeGenreEvent", "")) != "":
		return "%s  %.1fs" % [
			String(context.get("activeGenreLabel", "")),
			float(context.get("genreEventTimer", 0.0))
		]
	if bool(context.get("strategyWiki", false)) and String(context.get("nextKnownGenreEvent", "")) != "":
		return "次のゲーム変化：%s" % String(context.get("nextKnownGenreLabel", ""))
	return ""
