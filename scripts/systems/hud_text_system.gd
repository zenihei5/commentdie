class_name HudTextSystem
extends RefCounted

static func status_text(stats: Dictionary) -> String:
	return "スコア %d   EXP %d/%d   効果 %ss   配信者:%s   配信枠:%s   武器:%s" % [
		int(stats.get("score", 0)),
		int(stats.get("expValue", 0)),
		int(stats.get("expNeed", 0)),
		String(stats.get("effectText", "00")),
		String(stats.get("characterName", "バンちゃん")),
		String(stats.get("streamFrameName", "雑談枠")),
		String(stats.get("weaponName", "BANハンマー"))
	]

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
		return "指示コメが来た！ %.1fs  Q:NG x%d  H:♡ x%d" % [
			float(context.get("choiceTimer", 0.0)),
			int(context.get("ngStock", 0)),
			int(context.get("heartStock", 0))
		]
	if state == "gift_choice":
		return String(context.get("giftArrivalText", "ギフトが届いた！")) + " ひとつ選べ！"
	if state == "pause":
		return "ポーズ"
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
