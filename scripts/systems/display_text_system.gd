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
		"危険度の高い指示コメでバズ度が上がり、被弾すると5％下がります",
		"バズ度が高いほど、敵撃破時の視聴者数スコア倍率が上がります",
		"バズ度は0～100％で、時間経過や効果終了では変化しません",
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
	return ["ニューゲーム", "パワーアップショップ", "ランキング", "オプション", "終了する"]

static func title_controls_text() -> String:
	return "↑↓ / W/S：選択    Enter / Space：決定"

static func title_settings_text(_comment_barrage: String, screen_shake_enabled: bool) -> String:
	return "N: 画面揺れ %s" % ("ON" if screen_shake_enabled else "OFF")

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

static func options_screen_text(selected_index: int, window_size: String, _comment_barrage: String, screen_shake_enabled: bool, tutorial_seen: bool, window_size_status: String = "") -> String:
	var labels: Array[String] = [
		"画面サイズ　%s" % window_size,
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
	if kind == "pitch_police_chief":
		return "音程警察長"
	if kind == "pitch_police":
		return "音程警察"
	if kind == "request_spammer":
		return "リクエスト連投"
	if kind == "fast_call_fan":
		return "早口コール勢"
	if kind == "song_noise_comment":
		return "ノイズコメント"
	if kind == "song_lyric_spoiler_comment":
		return "歌詞ネタバレコメント"
	if kind == "drawing_fix_note":
		return "修正指示コメント"
	if kind == "red_pen_teacher":
		return "赤ペン先生"
	if kind == "layer_lost":
		return "レイヤー迷子"
	if kind == "bucket_fill_slime":
		return "バケツ塗りスライム"
	if kind == "undo_ghost":
		return "Undo幽霊"
	if kind == "red_pen_review_chief":
		return "赤ペン添削長"
	if kind == "enemy_spoiler_comment":
		return "ネタバレコメント"
	if kind == "enemy_backseat_controller":
		return "指示厨コントローラー"
	if kind == "enemy_armchair_strategist":
		return "エアプ軍師"
	if kind == "enemy_dot_invader":
		return "ドットインベーダー"
	if kind == "enemy_fake_gift_box":
		return "偽ギフトボックス"
	if kind == "enemy_lag_comment":
		return "ラグコメント"
	if kind == "enemy_strategy_wiki_ojisan":
		return "攻略Wikiおじさん"
	if kind == "enemy_fake_first_timer":
		return "初見詐欺"
	if kind == "enemy_wrong_way_kart":
		return "逆走カート"
	if kind == "enemy_jammer_cone":
		return "じゃまコーン"
	if kind == "enemy_bullet_drone":
		return "弾幕ドローン"
	if kind == "enemy_noise_ghost_comment":
		return "ノイズ幽霊コメント"
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
	if kind == "bugged_final_boss":
		return "バグったラスボス"
	if kind == "bugged_final_boss_stun":
		return "バグったラスボス"
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
	if source == "boss_bullet" or source == "boss_attack":
		return "ボス攻撃"
	if source == "damage_pit":
		return "ダメージ床"
	if source == "song_howling_wave":
		return "ハウリング音波"
	if source == "stopped moving":
		return "足止め"
	return source

static func rarity_label(rarity: String) -> String:
	if rarity == "evolution":
		return "進化"
	if rarity == "god":
		return "神"
	if rarity == "flame":
		return "大バズ"
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

static func stream_frame_result_text(stream_frame_id: String, genre_stats: Dictionary, marshmallow_stats: Dictionary, song_stats: Dictionary = {}, drawing_stats: Dictionary = {}, collab_stats: Dictionary = {}) -> String:
	if stream_frame_id == "gameplay":
		return "\nゲーム実況結果：変化 %d / レース %d / 弾幕 %d / ホラー %d / 完走 %d" % [
			int(genre_stats.get("genreEventCount", 0)),
			int(genre_stats.get("raceEventCount", 0)),
			int(genre_stats.get("bulletHellEventCount", 0)),
			int(genre_stats.get("horrorEventCount", 0)),
			int(genre_stats.get("genreEventClearCount", 0))
		]
	if stream_frame_id == "singing" or stream_frame_id == "song":
		return "\n歌枠結果：最大HEAT Lv.%d %.0f / サビ %d / 音符 %d / オクターブ %d / 照明 %.1fs / アンコール %s" % [
			int(song_stats.get("maxLiveHeatLevel", 0)),
			float(song_stats.get("maxLiveHeat", 0.0)),
			int(song_stats.get("chorusCount", 0)),
			int(song_stats.get("notesCollected", 0)),
			int(song_stats.get("octaveBonusCount", 0)),
			float(song_stats.get("spotlightStayTime", 0.0)),
			"成功" if bool(song_stats.get("encoreCompleted", false)) else ("発生" if bool(song_stats.get("encoreTriggered", false)) else "なし")
		]
	if stream_frame_id == "drawing":
		return "\nお絵かき結果：制作進捗 %d%% / 囲い塗り %d / 修正 %d / 消しゴム %d" % [
			roundi(float(drawing_stats.get("progress", 0.0))),
			int(drawing_stats.get("fillCount", 0)),
			int(drawing_stats.get("correctionCount", 0)),
			int(drawing_stats.get("eraserCount", 0))
		]
	if stream_frame_id == "collab":
		var partner_name := String(collab_stats.get("partnerName", "相方"))
		if partner_name == "" or partner_name == "未選択":
			partner_name = "相方"
		return "\nコラボ結果：相方 %s / パス成功 %d / 星 %d / ペア技 %d / チャレンジ成功 %d" % [
			partner_name,
			int(collab_stats.get("passSuccessCount", 0)),
			int(collab_stats.get("syncStarsCollected", 0)),
			int(collab_stats.get("pairSkillCount", 0)),
			int(collab_stats.get("challengeSuccessCount", 0))
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
