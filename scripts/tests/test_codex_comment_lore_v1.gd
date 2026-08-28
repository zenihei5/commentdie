extends Node

const Presentation := preload("res://scripts/systems/codex_presentation_system.gd")
const CommentSystemScript := preload("res://scripts/systems/comment_system.gd")

var failures: Array[String] = []

func _ready() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	CodexManager.initialize_empty()
	var comments := CodexManager.get_master_entries(CodexManager.CATEGORY_COMMENT)
	var raw_comments := _read_comments()
	var reachability := CommentSystemScript.codex_reachable_standard_comment_ids(raw_comments)
	var expected_count := 0
	for id in reachability.keys():
		if bool(reachability[id]):
			expected_count += 1
	_check(comments.size() == expected_count, "comment catalogue is derived from reachable standard frames")
	_check(expected_count == 44, "current reachable comment total remains 44")

	var expected := {
		"banana_floor": {"labels": ["共通", "♡あり"], "heart": true, "archive": 4},
		"reverse_control": {"labels": ["共通", "♡あり"], "heart": true, "archive": 3},
		"giant_enemies": {"labels": ["共通", "♡あり"], "heart": true, "archive": 4},
		"no_dash": {"labels": ["共通", "♡あり"], "heart": true, "archive": 4},
		"attack_right_only": {"labels": ["共通", "♡あり"], "heart": true, "archive": 3},
		"do_everything": {"labels": ["共通", "♡あり"], "heart": true, "archive": 4},
		"no_stop": {"labels": ["共通"], "heart": false, "archive": 4},
		"no_brake": {"labels": ["共通"], "heart": false, "archive": 4},
		"enemy_speed_up": {"labels": ["共通"], "heart": false, "archive": 4},
		"enemy_spawn_up": {"labels": ["共通"], "heart": false, "archive": 4},
		"split_enemy": {"labels": ["共通"], "heart": false, "archive": 4},
		"short_range": {"labels": ["共通", "♡あり"], "heart": true, "archive": 4},
		"weapon_mute": {"labels": ["共通"], "heart": false, "archive": 4},
		"hide_hp": {"labels": ["共通"], "heart": false, "archive": 4},
		"comment_barrage": {"labels": ["共通"], "heart": false, "archive": 4},
		"camera_zoom": {"labels": ["共通"], "heart": false, "archive": 4},
		"temp_walls": {"labels": ["共通"], "heart": false, "archive": 4},
		"damage_pits": {"labels": ["共通"], "heart": false, "archive": 4},
		"kamiyoyaku": {"labels": ["共通"], "heart": false, "archive": 4},
		"takeback": {"labels": ["共通"], "heart": false, "archive": 4},
		"summon_boss": {"labels": ["共通", "♡あり"], "heart": true, "archive": 4},
		"genre_change": {"labels": ["ゲーム実況"], "heart": false, "archive": 5},
		"force_bullet_hell": {"labels": ["ゲーム実況"], "heart": false, "archive": 5},
		"force_race": {"labels": ["ゲーム実況"], "heart": false, "archive": 4},
		"force_horror": {"labels": ["ゲーム実況"], "heart": false, "archive": 5},
		"song_tempo_up": {"labels": ["歌枠"], "heart": false, "archive": 4},
		"song_force_chorus": {"labels": ["歌枠"], "heart": false, "archive": 4},
		"song_mic_howling": {"labels": ["歌枠"], "heart": false, "archive": 4},
		"song_lighting_mistake": {"labels": ["歌枠"], "heart": false, "archive": 4},
		"song_lyrics_lost": {"labels": ["歌枠"], "heart": false, "archive": 4},
		"drawing_fast_dry": {"labels": ["お絵かき", "♡あり"], "heart": true, "archive": 5},
		"drawing_too_much_paint": {"labels": ["お絵かき", "♡あり"], "heart": true, "archive": 4},
		"drawing_palette_shuffle": {"labels": ["お絵かき", "♡あり"], "heart": true, "archive": 5},
		"drawing_more_corrections": {"labels": ["お絵かき", "♡あり"], "heart": true, "archive": 4},
		"drawing_spilled_bucket": {"labels": ["お絵かき", "♡あり"], "heart": true, "archive": 4},
		"partner_take_over": {"labels": ["コラボ", "♡あり"], "heart": true, "archive": 5},
		"dont_fail_collab": {"labels": ["コラボ", "♡あり"], "heart": true, "archive": 4},
		"keep_sync": {"labels": ["コラボ", "♡あり"], "heart": true, "archive": 5},
		"out_of_sync": {"labels": ["コラボ", "♡あり"], "heart": true, "archive": 4},
		"fast_collab_pass": {"labels": ["コラボ", "♡あり"], "heart": true, "archive": 4},
		"hard_overclock": {"labels": ["共通", "♡あり"], "heart": true, "archive": 4},
		"hard_pressure_wave": {"labels": ["共通", "♡あり"], "heart": true, "archive": 5},
		"talk_comment_avalanche": {"labels": ["雑談", "♡あり"], "heart": true, "archive": 4},
		"game_genre_mix": {"labels": ["ゲーム実況", "♡あり"], "heart": true, "archive": 5}
	}
	_check(expected.size() == 44, "codex lore expectations cover all 44 comments")
	for id_value in expected.keys():
		var id := String(id_value)
		var master := _find(comments, id)
		var model := Presentation.comment_lore_model(master, {}, true)
		var spec: Dictionary = expected[id] as Dictionary
		_check(not master.is_empty(), "representative comment exists: %s" % id)
		_check(String(model.get("template", "")) == "directive_comment", "comment template: %s" % id)
		_check(bool(model.get("hasLore", false)), "representative comment has lore: %s" % id)
		_check((model.get("classificationLabels", []) as Array) == (spec.get("labels", []) as Array), "classification labels: %s" % id)
		_check(bool(model.get("hasHeart", false)) == bool(spec.get("heart", false)), "heart badge state: %s" % id)
		_check((master.get("heartVariant", null) is Dictionary) == bool(spec.get("heart", false)), "master heart variant is preserved: %s" % id)
		_check((model.get("cards", []) as Array).size() == 3, "three lore cards: %s" % id)
		_check((model.get("archiveParagraphs", []) as Array).size() == int(spec.get("archive", 0)), "archive paragraph count: %s" % id)
		_check(_card_spans(model) == [2, 1, 1], "card spans: %s" % id)
		_check(_card_ids(model) == ["writer", "posting_moment", "observation_note"], "card ids: %s" % id)
		_check(String(model.get("archiveTitle", "")) == "COMMENT ARCHIVE", "archive title: %s" % id)
		_check(String(model.get("effectSummary", "")).strip_edges() == String(master.get("description", "")).strip_edges(), "effect summary comes from the existing description: %s" % id)
		_check((model.get("codexVisual", {}) as Dictionary).get("scale", 0.0) == 1.0, "comment visual defaults to scale 1: %s" % id)
	_check(_find_card(Presentation.comment_lore_model(_find(comments, "enemy_spawn_up"), {}, true), "writer").get("text", "") == "落ち着いた展開では刺激が足りないと感じ、敵の数で画面をにぎやかにしてほしい視聴者。一体ごとの強さより、画面を埋める密度を重視する。", "representative writer text is exact")
	_check(_find_card(Presentation.comment_lore_model(_find(comments, "partner_take_over"), {}, true), "observation_note").get("text", "") == "相方が成功すると「さすが」と称賛し、失敗した場合は「今のは事故」と素早く擁護する。", "representative observation text is exact")
	_check(_find_card(Presentation.comment_lore_model(_find(comments, "split_enemy"), {}, true), "observation_note").get("text", "") == "分裂した敵を見た書き手は、「小さくなったから実質弱体化」と説明する。数については触れない。", "phase 2 observation text is exact")
	_check(_find_card(Presentation.comment_lore_model(_find(comments, "summon_boss"), {}, true), "writer").get("text", "") == "通常の敵だけでは配信の山場が足りず、準備状況に関係なく今すぐボス戦を見たい視聴者。配信者なら突然の大勝負にも対応できると信じている。", "phase 2 writer text is exact")
	_check(_find_card(Presentation.comment_lore_model(_find(comments, "force_race"), {}, true), "writer").get("text", "") == "目的地があるなら、普通に向かうのではなく順位と制限時間を付けた方が面白いと考える競争好きの視聴者。対戦相手がいなくても、何かと競わせようとする。", "phase 3 game writer text is exact")
	_check(_find_card(Presentation.comment_lore_model(_find(comments, "song_lyrics_lost"), {}, true), "observation_note").get("text", "") == "歌詞カードが見つかるまで、コメント欄へ各自が覚えている歌詞を書き込む。内容が全員少しずつ違う。", "phase 3 song observation text is exact")
	_check(_find_card(Presentation.comment_lore_model(_find(comments, "drawing_palette_shuffle"), {}, true), "writer").get("text", "") == "整った配色よりも、何が出るか分からない偶然の色選びを楽しみたい視聴者。完成度を下げたいわけではなく、配信者の対応力を見たいと考えている場合も多い。", "phase 4 drawing writer text is exact")
	_check(_find_card(Presentation.comment_lore_model(_find(comments, "partner_take_over"), {}, true), "writer").get("text", "") == "コラボ相手の力を信じ、難しい状況を思い切って任せてみてほしいと考える視聴者。自分の推しに見せ場を作りたいという気持ちが含まれることもある。", "phase 4 collab writer text is exact")
	_check(_find_card(Presentation.comment_lore_model(_find(comments, "hard_overclock"), {}, true), "observation_note").get("text", "") == "敵の攻撃が速くなると、「弾速おかしくない？」という報告が同じコメント欄から届く。正常な速度へ戻すよう求める者はいない。", "phase 5 hard observation text is exact")
	_check(_find_card(Presentation.comment_lore_model(_find(comments, "game_genre_mix"), {}, true), "writer").get("text", "") == "一つのゲームジャンルだけでは展開を予測できてしまうため、異なるジャンルを続けて遊べば新しい面白さが生まれると考える視聴者。相性がよいかどうかは、混ぜてから確かめればよいという姿勢を取る。", "phase 5 hard game writer text is exact")

	var synthetic := {
		"id": "synthetic_comment",
		"displayName": "合成コメント",
		"description": "短い効果概要",
		"codexLore": {"codexVisual": {"scale": 9.0, "offsetX": -9.0, "offsetY": 0.75}}
	}
	var synthetic_model := Presentation.comment_lore_model(synthetic, {}, true)
	var synthetic_visual: Dictionary = synthetic_model.get("codexVisual", {}) as Dictionary
	_check(synthetic_visual.get("scale", 0.0) == 2.5 and synthetic_visual.get("offsetX", 0.0) == -1.0 and synthetic_visual.get("offsetY", 0.0) == 0.75, "comment visual scale and offsets are clamped")
	_check(String(synthetic_model.get("effectSummary", "")) == "短い効果概要" and not synthetic_model.has("previewModel"), "effect summary is UI data and old preview model is gone")

	var counted := Presentation.comment_lore_model(_find(comments, "enemy_spawn_up"), {"appeared_count": 4, "selected_count": 1, "heart_count": 0}, true)
	_check(counted.has("selectionRate") and is_equal_approx(float(counted.get("selectionRate", 0.0)), 25.0), "selection rate is derived when appeared")
	var uncounted := Presentation.comment_lore_model(_find(comments, "enemy_spawn_up"), {"appeared_count": 0, "selected_count": 0}, true)
	_check(not uncounted.has("selectionRate"), "selection rate is hidden when not appeared")

	var missing := Presentation.comment_lore_model({"id": "missing_comment", "displayName": "欠損", "description": "効果"}, {}, true)
	_check(not bool(missing.get("hasLore", false)) and (missing.get("cards", []) as Array).is_empty(), "missing lore remains safe")
	_check(String(missing.get("effectSummary", "")) == "効果" and String(missing.get("imagePath", "")) == "", "missing lore keeps effect fallback source without exposing an image")
	_check(not missing.has("previewModel"), "missing lore has no old preview model")
	var hidden := Presentation.comment_lore_model(_find(comments, "enemy_spawn_up"), {}, false)
	_check(not bool(hidden.get("hasLore", false)) and String(hidden.get("imagePath", "")) == "" and (hidden.get("codexVisual", {}) as Dictionary).is_empty() and String(hidden.get("effectSummary", "")) == "" and (hidden.get("effectModel", {}) as Dictionary).is_empty() and not bool(hidden.get("hasHeart", false)), "undiscovered comment masks illustration, summary, lore, and effects")

	_check(not FileAccess.file_exists("res://scripts/ui/instruction_comment_card_preview.gd"), "old static preview component is removed")
	_check(not FileAccess.file_exists("res://scripts/ui/instruction_comment_card_preview.gd.uid"), "old preview uid is removed")
	var codex_screen_source := FileAccess.get_file_as_string("res://scripts/ui/codex_screen.gd")
	_check(codex_screen_source.contains("codex_visual_offset_x") and codex_screen_source.contains("codex_visual_offset_y"), "comment visual offsets are stored on the TextureRect")
	_check(codex_screen_source.contains("var dx := offset_x * _item_visual_holder.size.x") and codex_screen_source.contains("var dy := offset_y * _item_visual_holder.size.y") and codex_screen_source.contains("rect.offset_left = inset + dx") and codex_screen_source.contains("rect.offset_top = inset + dy"), "comment visual offsets are recalculated from the current holder size")
	_check(codex_screen_source.contains("resolved_category != CodexManager.CATEGORY_COMMENT") and codex_screen_source.contains("_comment_content_texture"), "other category offsets keep their existing path and comments use a separate trim cache")
	var report := CodexManager.validate_masters()
	var warning_count := 0
	for warning_value in report.get("warnings", []) as Array:
		if String(warning_value).begins_with("comments missing codexLore:"):
			warning_count += 1
	_check(warning_count == 0, "all 44 comments have lore")
	if failures.is_empty():
		print("CODEX_COMMENT_LORE_V1_TESTS: PASS")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("CODEX_COMMENT_LORE_V1_TESTS: FAIL (%d)" % failures.size())
	get_tree().quit(1)

func _read_comments() -> Array:
	var file := FileAccess.open("res://data/comments.json", FileAccess.READ)
	if file == null:
		return []
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed as Array if parsed is Array else []

func _find(items: Array, id: String) -> Dictionary:
	for item_value in items:
		if item_value is Dictionary and String((item_value as Dictionary).get("id", "")) == id:
			return item_value as Dictionary
	return {}

func _find_card(model: Dictionary, id: String) -> Dictionary:
	for card_value in model.get("cards", []) as Array:
		if card_value is Dictionary and String((card_value as Dictionary).get("id", "")) == id:
			return card_value as Dictionary
	return {}

func _card_ids(model: Dictionary) -> Array:
	var ids: Array = []
	for card_value in model.get("cards", []) as Array:
		if card_value is Dictionary:
			ids.append(String((card_value as Dictionary).get("id", "")))
	return ids

func _card_spans(model: Dictionary) -> Array:
	var spans: Array = []
	for card_value in model.get("cards", []) as Array:
		if card_value is Dictionary:
			spans.append(int((card_value as Dictionary).get("span", 0)))
	return spans

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
