class_name DisplayTextSystem
extends RefCounted

static func tutorial_title() -> String:
	return "チュートリアル"

static func tutorial_lines() -> Array[String]:
	return [
		"移動：WASD / 方向キー",
		"攻撃は自動",
		"15秒ごとに指示コメが来ます",
		"10秒以内にひとつ選びます",
		"危険な指示コメほどボルテージとギフト期待度が上がります",
		"EXPを集めるとギフトが届きます",
		"マシュマロは拾うと効果が出ます",
		"死んだらコメントのせいです"
	]

static func tutorial_start_text() -> String:
	return "Enter / Spaceで開始"

static func tutorial_text_lines() -> Array[Dictionary]:
	var result: Array[Dictionary] = [
		{"offset": Vector2(220, 70), "text": tutorial_title(), "size": 38, "color": Color("#fff45c")},
		{"offset": Vector2(245, 540), "text": tutorial_start_text(), "size": 28, "color": Color("#8df7ff")}
	]
	var lines: Array[String] = tutorial_lines()
	for i in range(lines.size()):
		result.append({"offset": Vector2(90, 135 + i * 44), "text": lines[i], "size": 24, "color": Color.WHITE})
	return result

static func comment_storm_samples() -> Array[String]:
	return ["www", "右", "神回", "逃げろ", "全部やれ", "x10", "草"]

static func horror_event_title() -> String:
	return "ホラーゲーム風"

static func comment_countdown_title(alert: bool) -> String:
	return "指示コメ襲来" if alert else "次の指示コメ"

static func comment_countdown_warning() -> String:
	return "WARNING"

static func title_tagline() -> String:
	return "指示コメが配信を壊しにくる"

static func title_menu_items() -> Array[String]:
	return ["ニューゲーム", "ランキング", "オプション"]

static func title_controls_text() -> String:
	return "↑↓ / W/S：選択    Enter / Space：決定    1/2/3：直接選択"

static func title_settings_text(comment_barrage: String, screen_shake_enabled: bool) -> String:
	return "B: 弾幕量 %s    N: 画面揺れ %s" % [comment_barrage, "ON" if screen_shake_enabled else "OFF"]

static func title_tutorial_text() -> String:
	return "U: 全配信枠解放"

static func title_lines(comment_barrage: String, screen_shake_enabled: bool, selected_index: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = [
		{"offset": Vector2(-255, -118), "text": title_tagline(), "size": 32, "color": Color("#101420")},
	]
	var items: Array[String] = title_menu_items()
	for i in range(items.size()):
		var selected: bool = i == selected_index
		result.append({
			"offset": Vector2(-160, -16 + i * 54),
			"text": ("▶ " if selected else "   ") + items[i],
			"size": 34,
			"color": Color("#e73763") if selected else Color("#101420")
		})
	result.append({"offset": Vector2(-255, 180), "text": title_controls_text(), "size": 20, "color": Color("#36445c")})
	result.append({"offset": Vector2(-255, 222), "text": title_settings_text(comment_barrage, screen_shake_enabled), "size": 18, "color": Color("#1576bc")})
	result.append({"offset": Vector2(-255, 254), "text": title_tutorial_text(), "size": 17, "color": Color("#36445c")})
	result.append({"offset": Vector2(250, 254), "text": "v0.2", "size": 17, "color": Color("#6b7280")})
	return result

static func options_screen_text(selected_index: int, window_size: String, comment_barrage: String, screen_shake_enabled: bool, tutorial_seen: bool, window_size_status: String = "") -> String:
	var labels: Array[String] = [
		"画面サイズ　%s" % window_size,
		"コメント弾幕量　%s" % comment_barrage,
		"画面揺れ　　　%s" % ("ON" if screen_shake_enabled else "OFF"),
		"チュートリアル再表示",
		"戻る"
	]
	var lines: Array[String] = ["オプション", ""]
	for i in range(labels.size()):
		lines.append(("%s [%d] %s" % ["▶" if i == selected_index else " ", i + 1, labels[i]]))
	lines.append("")
	if window_size_status != "":
		lines.append(window_size_status)
	lines.append("Esc / Backspace：タイトルへ戻る")
	lines.append("チュートリアル：%s" % ("表示済み" if tutorial_seen else "次回表示"))
	return "\n".join(lines)

static func character_select_title() -> String:
	return "配信者を選択"

static func select_help_text() -> String:
	return "Enter：決定 / Esc：戻る"

static func character_role_text(role_name: String) -> String:
	return "タイプ：%s" % role_name

static func character_weapon_text(weapon_name: String) -> String:
	return "武器：%s" % weapon_name

static func character_passive_text(passive_name: String) -> String:
	return "特性：%s" % passive_name

static func stream_frame_select_title() -> String:
	return "今日の配信枠を選択"

static func stream_frame_difficulty_text(difficulty: String) -> String:
	return "難易度：%s" % difficulty

static func stream_frame_feature_text(features: Array[String]) -> String:
	var feature_text: String = " / ".join(features) if not features.is_empty() else "標準"
	return "特徴：" + feature_text

static func comment_barrage_label(setting: int) -> String:
	if setting == 0:
		return "少なめ"
	if setting == 2:
		return "多め"
	return "通常"

static func enemy_display_name(kind: String) -> String:
	if kind == "fast":
		return "連投マン"
	if kind == "shooter":
		return "指示厨"
	if kind == "long_comment_guy":
		return "長文ニキ"
	if kind == "clipper":
		return "悪質切り抜き師"
	if kind == "unread_maro":
		return "未読マロ"
	if kind == "ghost_comment":
		return "幽霊コメント"
	if kind == "boss_super_long_comment":
		return "超長文ニキ"
	if kind == "boss_kuso_maro_king":
		return "クソマロキング"
	if kind == "troll":
		return "荒らし"
	return kind

static func damage_source_display(source: String) -> String:
	if source.ends_with(" contact"):
		return enemy_display_name(source.replace(" contact", "")) + "に接触"
	if source == "clipper charge":
		return "悪質切り抜き師の突進"
	if source == "enemy":
		return "敵"
	if source == "enemy bullet":
		return "敵弾"
	return source

static func rarity_label(rarity: String) -> String:
	if rarity == "evolution":
		return "進化"
	if rarity == "god":
		return "神"
	if rarity == "flame":
		return "炎上"
	if rarity == "rare":
		return "レア"
	return "通常"

static func rarity_color(rarity: String) -> Color:
	if rarity == "evolution":
		return Color("#ff68b3")
	if rarity == "god":
		return Color("#ffdf5a")
	if rarity == "flame":
		return Color("#ff4b31")
	if rarity == "rare":
		return Color("#6ed3ff")
	return Color("#7bff9e")

static func result_one_liner(rank: String, last_death_source: String, marshmallow_kuso: int, marshmallow_god: int) -> String:
	if last_death_source.contains("未読マロ"):
		return "マシュマロは読もう。"
	if marshmallow_kuso >= 3:
		return "マシュマロ欄、終わってました。"
	if marshmallow_god > 0:
		return "神マロに救われた。"
	if rank == "S":
		return "切り抜き確定。コメント欄も満足しています。"
	if rank == "A":
		return "これは神回。生き残ったのはあなたです。"
	if rank == "B":
		return "ほどよく事故って、ほどよく配信映え。"
	if rank == "C":
		return "生き残った。でも神回にはまだ足りない。"
	return "これはコメントが悪い。たぶん。"

static func taken_gift_summary(taken_gift_names: Array[String]) -> String:
	if taken_gift_names.is_empty():
		return "なし"
	var recent: Array[String] = []
	var start: int = maxi(0, taken_gift_names.size() - 4)
	for i in range(start, taken_gift_names.size()):
		recent.append(taken_gift_names[i])
	return " / ".join(recent)

static func stream_frame_result_text(stream_frame_id: String, genre_stats: Dictionary, marshmallow_stats: Dictionary) -> String:
	if stream_frame_id == "gameplay":
		return "\nゲーム実況結果：変化 %d / レース %d / 弾幕 %d / ホラー %d / 完走 %d" % [
			int(genre_stats.get("genreEventCount", 0)),
			int(genre_stats.get("raceEventCount", 0)),
			int(genre_stats.get("bulletHellEventCount", 0)),
			int(genre_stats.get("horrorEventCount", 0)),
			int(genre_stats.get("genreEventClearCount", 0))
		]
	return "\nマシュマロ結果：読了 %d / 良マロ %d / 神マロ %d / クソマロ %d / 未読化 %d" % [
		int(marshmallow_stats.get("answered", 0)),
		int(marshmallow_stats.get("good", 0)),
		int(marshmallow_stats.get("god", 0)),
		int(marshmallow_stats.get("kuso", 0)),
		int(marshmallow_stats.get("unread", 0))
	]

static func shorten_result_line(text: String, max_chars: int) -> String:
	if text.length() <= max_chars:
		return text
	return text.substr(0, max_chars - 1) + "…"
