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
			"characterName": String(current_character.get("displayName", "バンちゃん")),
			"streamFrameName": String(current_stream_frame.get("displayName", "雑談枠")),
			"weaponName": String(current_weapon.get("displayName", "BANハンマー")),
			"weaponSlots": EquipmentSystem.slot_summary(weapons, EquipmentSystem.MAX_WEAPONS),
			"accessorySlots": EquipmentSystem.slot_summary(accessories, EquipmentSystem.MAX_ACCESSORIES)
		}),
		"banner": banner_text({
			"state": String(target.get("state")),
			"quickTestMode": bool(target.get("quick_test_mode")),
			"commentBarrageLabel": comment_barrage_label,
			"screenShakeEnabled": bool(target.get("screen_shake_enabled")),
			"choiceTimer": float(target.get("choice_timer")),
			"ngStock": int(target.get("ng_stock")),
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

static func banner_text(context: Dictionary) -> String:
	var state: String = String(context.get("state", "title"))
	if state == "title":
		var mode_text: String = "60秒テスト" if bool(context.get("quickTestMode", false)) else "180秒通常"
		return "Enter：配信者を選択 / T:%s / B:%s / 画面揺れ:%s" % [
			mode_text,
			String(context.get("commentBarrageLabel", "通常")),
			"ON" if bool(context.get("screenShakeEnabled", true)) else "OFF"
		]
	if state == "character_select":
		return "配信者を選択  1/2/3 または方向キー + Enter"
	if state == "stream_frame_select":
		return "配信枠を選択  1/2 または方向キー + Enter"
	if state == "tutorial":
		return "チュートリアル  Enter / Spaceで開始"
	if state == "comment_choice":
		return "指示コメが来た！ %.1fs  Q:NG x%d" % [
			float(context.get("choiceTimer", 0.0)),
			int(context.get("ngStock", 0))
		]
	if state == "gift_choice":
		return String(context.get("giftArrivalText", "ギフトが届いた！")) + " ひとつ選べ！"
	if state == "pause":
		return "ポーズ"
	if bool(context.get("heartPending", false)):
		return "♡待機中：次の指示コメが全部ちょっと甘くなる"
	if String(context.get("activeGenreEvent", "")) != "":
		return "%s  %.1fs" % [
			String(context.get("activeGenreLabel", "")),
			float(context.get("genreEventTimer", 0.0))
		]
	if bool(context.get("strategyWiki", false)) and String(context.get("nextKnownGenreEvent", "")) != "":
		return "次のゲーム変化：%s" % String(context.get("nextKnownGenreLabel", ""))
	var comment_timer: float = float(context.get("commentTimer", 0.0))
	if comment_timer <= 5.0:
		return "指示コメ襲来まで %.1fs" % maxf(0.0, comment_timer)
	return "15秒ごとに指示コメがルールを変える。"
