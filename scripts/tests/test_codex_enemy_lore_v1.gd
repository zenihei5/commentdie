extends Node

const Presentation := preload("res://scripts/systems/codex_presentation_system.gd")

var failures: Array[String] = []

func _ready() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	var file := FileAccess.open("res://data/codex_enemies.json", FileAccess.READ)
	_check(file != null, "enemy master opens")
	if file == null:
		_finish()
		return
	var raw_value: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	_check(raw_value is Array, "enemy master parses as Array")
	if not raw_value is Array:
		_finish()
		return
	var raw := raw_value as Array
	var enabled: Array = []
	var disabled: Array = []
	for value in raw:
		if not value is Dictionary:
			continue
		if bool((value as Dictionary).get("codexEnabled", false)):
			enabled.append(value)
		else:
			disabled.append(value)
	_check(raw.size() == 44, "raw enemy count is 44")
	_check(enabled.size() == 42, "enabled enemy count is 42")
	_check(disabled.size() == 2, "disabled enemy count is 2")
	var disabled_ids: Array[String] = []
	for value in disabled:
		disabled_ids.append(String((value as Dictionary).get("id", "")))
	_check(disabled_ids.has("undo_ghost") and disabled_ids.has("boss_super_long_comment"), "disabled ids are exact")
	for value in disabled:
		_check(not (value as Dictionary).has("codexLore"), "disabled enemy has no Lore: %s" % String((value as Dictionary).get("id", "")))

	var groups := {
		"common": ["troll", "fast", "shooter", "long_comment_guy", "clipper"],
		"gameplay": ["unread_maro", "enemy_spoiler_comment", "enemy_backseat_controller", "enemy_armchair_strategist", "enemy_lag_comment", "enemy_strategy_wiki_ojisan", "enemy_fake_first_timer", "enemy_wrong_way_kart", "enemy_jammer_cone", "enemy_dot_invader", "enemy_bullet_drone", "enemy_fake_gift_box", "enemy_noise_ghost_comment"],
		"singing": ["pitch_police", "request_spammer", "fast_call_fan", "song_noise_comment", "song_lyric_spoiler_comment"],
		"drawing": ["drawing_fix_note", "red_pen_teacher", "layer_lost", "bucket_fill_slime"],
		"collab": ["collab_comparison_troll", "collab_messenger_pigeon", "collab_discord_troll", "collab_volume_police", "collab_exclusive_listener", "collab_division_noise", "collab_mute_core"],
		"other_special": ["ghost_comment", "noise_ghost_comment"],
		"boss": ["boss_kuso_maro_king", "bugged_final_boss", "pitch_police_chief", "red_pen_review_chief", "collab_crusher", "last_offline"]
	}
	var enabled_by_id: Dictionary = {}
	for value in enabled:
		enabled_by_id[String((value as Dictionary).get("id", ""))] = true
	var grouped_ids: Dictionary = {}
	for group_name in groups.keys():
		var group_ids: Array = groups[group_name] as Array
		for id_value in group_ids:
			var id := String(id_value)
			_check(enabled_by_id.has(id), "content group id is enabled: %s" % id)
			_check(not grouped_ids.has(id), "enemy is not in multiple content groups: %s" % id)
			grouped_ids[id] = true
		_check(group_ids.size() == ({"common": 5, "gameplay": 13, "singing": 5, "drawing": 4, "collab": 7, "other_special": 2, "boss": 6}.get(group_name, 0)), "content group count: %s" % group_name)
	_check(grouped_ids.size() == 42, "content groups cover all enabled enemies")

	var sources := Presentation.load_sources()
	var profile_catalog: Dictionary = sources.get("enemyProfileCatalog", {}) as Dictionary
	var profiles_by_id: Dictionary = profile_catalog.get("byId", {}) as Dictionary
	var canonical_mismatch_count := 0
	for value in raw:
		if not value is Dictionary:
			continue
		var name_master := value as Dictionary
		var name_id := String(name_master.get("id", ""))
		var expected_name := Presentation.canonical_enemy_display_name(name_master, sources)
		var actual_name := String(name_master.get("displayName", ""))
		if actual_name != expected_name:
			canonical_mismatch_count += 1
		_check(actual_name == expected_name, "canonical enemy displayName: %s" % name_id)
		if profiles_by_id.has(name_id) and profiles_by_id.get(name_id) is Dictionary:
			var profile := profiles_by_id.get(name_id) as Dictionary
			_check(String(profile.get("runtimeDisplayName", expected_name)) == expected_name, "profile runtimeDisplayName: %s" % name_id)
			_check(String(profile.get("canonicalDisplayName", "")) == expected_name, "profile canonicalDisplayName: %s" % name_id)
	_check(canonical_mismatch_count == 0, "all 44 enemy names match authoritative sources")
	_check(String((_find(raw, "red_pen_review_chief")).get("displayName", "")) == "赤ペンリテイクドラゴン", "red pen boss name uses bosses.json")
	var expected_names := {
		"troll": "荒らし",
		"fast": "連投マン",
		"long_comment_guy": "長文ニキ",
		"clipper": "悪質切り抜き師",
		"ghost_comment": "幽霊コメント",
		"enemy_fake_first_timer": "初見詐欺",
		"enemy_jammer_cone": "じゃまコーン",
		"enemy_noise_ghost_comment": "ノイズ幽霊コメント",
		"collab_comparison_troll": "比較厨",
		"collab_discord_troll": "不仲煽り",
		"undo_ghost": "Undo幽霊",
		"boss_super_long_comment": "超長文ニキ"
	}
	for expected_id in expected_names.keys():
		_check(String((_find(raw, String(expected_id))).get("displayName", "")) == String(expected_names[expected_id]), "canonical name exact: %s" % String(expected_id))
	var template_counts := {"normal_enemy": 0, "special": 0, "boss": 0}
	for value in enabled:
		var master := value as Dictionary
		var id := String(master.get("id", ""))
		var lore_value: Variant = master.get("codexLore", null)
		_check(lore_value is Dictionary, "Lore dictionary exists: %s" % id)
		if not lore_value is Dictionary:
			continue
		var lore := lore_value as Dictionary
		for forbidden_key in ["hp", "speed", "moveSpeed", "damage", "contactDamage", "attackInterval", "attackRange", "projectileSpeed", "projectileCount"]:
			_check(not lore.has(forbidden_key), "enemy Lore does not duplicate combat data: %s/%s" % [id, forbidden_key])
		var template := String(lore.get("template", ""))
		_check(template_counts.has(template), "known Lore template: %s" % id)
		if template_counts.has(template):
			template_counts[template] += 1
		var cards: Array = lore.get("cards", []) as Array
		_check(cards.size() == 3, "three Lore cards: %s" % id)
		var spans: Array[int] = []
		var card_ids: Dictionary = {}
		for card_value in cards:
			_check(card_value is Dictionary, "Lore card dictionary: %s" % id)
			if not card_value is Dictionary:
				continue
			var card := card_value as Dictionary
			var card_id := String(card.get("id", ""))
			_check(card_id != "" and not card_ids.has(card_id), "unique Lore card id: %s" % id)
			card_ids[card_id] = true
			_check(String(card.get("title", "")).strip_edges() != "", "Lore card title: %s" % id)
			_check(String(card.get("text", "")).strip_edges() != "", "Lore card text: %s" % id)
			spans.append(int(card.get("span", 0)))
		_check(spans == [2, 1, 1], "Lore spans are 2/1/1: %s" % id)
		_check(String(lore.get("archiveTitle", "")) == "ENEMY ARCHIVE", "enemy archive title: %s" % id)
		_check(not (lore.get("archiveParagraphs", []) as Array).is_empty(), "enemy archive paragraphs: %s" % id)
		var model := Presentation.build_enemy_model(master, true, {}, sources)
		_check(bool(model.get("hasLore", false)), "discovered model has Lore: %s" % id)
		_check((model.get("cards", []) as Array).size() == 3, "model exposes cards: %s" % id)
		_check(String(model.get("imagePath", "")) != "", "discovered model has image path: %s" % id)
	_check(int(template_counts["normal_enemy"]) == 25, "normal_enemy template count is 25")
	_check(int(template_counts["special"]) == 11, "special template count is 11")
	_check(int(template_counts["boss"]) == 6, "boss template count is 6")

	var phase2_archive_counts: Dictionary = {
		"enemy_spoiler_comment": 3,
		"enemy_backseat_controller": 3,
		"enemy_armchair_strategist": 4,
		"enemy_lag_comment": 4,
		"enemy_strategy_wiki_ojisan": 4,
		"enemy_fake_first_timer": 4,
		"enemy_wrong_way_kart": 3,
		"enemy_jammer_cone": 4,
		"enemy_dot_invader": 4,
		"enemy_bullet_drone": 4,
		"enemy_fake_gift_box": 4,
		"enemy_noise_ghost_comment": 4,
		"pitch_police": 4,
		"request_spammer": 4,
		"fast_call_fan": 4,
		"song_noise_comment": 4,
		"song_lyric_spoiler_comment": 4,
		"drawing_fix_note": 4,
		"red_pen_teacher": 4,
		"layer_lost": 4,
		"bucket_fill_slime": 4,
		"collab_comparison_troll": 3,
		"collab_messenger_pigeon": 4,
		"collab_discord_troll": 4,
		"collab_volume_police": 4,
		"collab_exclusive_listener": 4,
		"collab_division_noise": 4,
		"collab_mute_core": 4,
		"noise_ghost_comment": 4,
		"boss_kuso_maro_king": 4,
		"bugged_final_boss": 4,
		"pitch_police_chief": 4,
		"red_pen_review_chief": 4,
		"collab_crusher": 4,
		"last_offline": 6,
	}
	var phase2_card_titles: Dictionary = {
		"enemy_spoiler_comment": ["生態", "出没理由", "観測メモ"],
		"enemy_backseat_controller": ["生態", "出没理由", "観測メモ"],
		"enemy_armchair_strategist": ["生態", "出没理由", "観測メモ"],
		"enemy_lag_comment": ["生態", "出没理由", "観測メモ"],
		"enemy_strategy_wiki_ojisan": ["生態", "出没理由", "観測メモ"],
		"enemy_fake_first_timer": ["生態", "出没理由", "観測メモ"],
		"enemy_wrong_way_kart": ["正体", "走行理由", "観測メモ"],
		"enemy_jammer_cone": ["役割", "設置場所", "観測メモ"],
		"enemy_dot_invader": ["正体", "侵入目的", "観測メモ"],
		"enemy_bullet_drone": ["役割", "稼働条件", "観測メモ"],
		"enemy_fake_gift_box": ["正体", "誘い方", "観測メモ"],
		"enemy_noise_ghost_comment": ["正体", "現れ方", "観測メモ"],
		"pitch_police": ["生態", "出没理由", "観測メモ"],
		"request_spammer": ["生態", "出没理由", "観測メモ"],
		"fast_call_fan": ["生態", "出没理由", "観測メモ"],
		"song_noise_comment": ["生態", "出没理由", "観測メモ"],
		"song_lyric_spoiler_comment": ["生態", "出没理由", "観測メモ"],
		"drawing_fix_note": ["生態", "出没理由", "観測メモ"],
		"red_pen_teacher": ["生態", "出没理由", "観測メモ"],
		"layer_lost": ["生態", "出没理由", "観測メモ"],
		"bucket_fill_slime": ["生態", "出没理由", "観測メモ"],
		"collab_comparison_troll": ["生態", "出没理由", "観測メモ"],
		"collab_messenger_pigeon": ["生態", "出没理由", "観測メモ"],
		"collab_discord_troll": ["生態", "出没理由", "観測メモ"],
		"collab_volume_police": ["生態", "出没理由", "観測メモ"],
		"collab_exclusive_listener": ["生態", "出没理由", "観測メモ"],
		"collab_division_noise": ["発生源", "作用", "観測メモ"],
		"collab_mute_core": ["役割", "稼働条件", "観測メモ"],
		"noise_ghost_comment": ["発生源", "現れ方", "観測メモ"],
		"boss_kuso_maro_king": ["発生源", "習性", "配信界隈のうわさ"],
		"bugged_final_boss": ["発生源", "習性", "配信界隈のうわさ"],
		"pitch_police_chief": ["発生源", "習性", "配信界隈のうわさ"],
		"red_pen_review_chief": ["発生源", "習性", "配信界隈のうわさ"],
		"collab_crusher": ["発生源", "習性", "配信界隈のうわさ"],
		"last_offline": ["発生源", "習性", "配信界隈のうわさ"],
	}
	for phase2_id_value in phase2_archive_counts.keys():
		var phase2_id := String(phase2_id_value)
		var phase2_master := _find(enabled, phase2_id)
		var phase2_lore := phase2_master.get("codexLore", {}) as Dictionary
		_check((phase2_lore.get("archiveParagraphs", []) as Array).size() == int(phase2_archive_counts[phase2_id]), "phase2 archive paragraph count: %s" % phase2_id)
		var phase2_cards: Array = phase2_lore.get("cards", []) as Array
		var expected_titles: Array = phase2_card_titles[phase2_id] as Array
		for title_index in range(mini(expected_titles.size(), phase2_cards.size())):
			var phase2_card := phase2_cards[title_index] as Dictionary
			_check(String(phase2_card.get("title", "")) == String(expected_titles[title_index]), "phase2 card title: %s/%d" % [phase2_id, title_index])

	var fake_gift := _find(enabled, "enemy_fake_gift_box")
	var fake_model := Presentation.build_enemy_model(fake_gift, true, {}, sources)
	_check(_card_title(fake_model, "identity") == "正体", "fake gift identity title")
	_check(_card_title(fake_model, "behavior") == "誘い方", "fake gift lure title")
	var king := Presentation.build_enemy_model(_find(enabled, "boss_kuso_maro_king"), true, {}, sources)
	_check((king.get("classificationBadges", []) as Array).has("BOSS"), "kuso maro king BOSS badge")
	_check(_card_title(king, "origin") == "発生源", "boss origin title")
	var relay := Presentation.build_enemy_model(_find(enabled, "last_offline"), true, {}, sources)
	_check((relay.get("classificationBadges", []) as Array).has("SPECIAL BOSS"), "last offline SPECIAL BOSS badge")
	_check(String(relay.get("loreTemplate", "")) == "boss", "last offline boss template")

	var hidden := Presentation.build_enemy_model(fake_gift, false, {}, sources)
	_check(String(hidden.get("displayName", "")) == "？？？", "undiscovered enemy name masked")
	for key in ["imagePath", "stageIds", "stageLabels", "spawnTypes", "conditionLines", "relatedEnemyIds", "badges", "classificationBadges", "cards", "loreCards", "archiveParagraphs", "codexVisual"]:
		var value: Variant = hidden.get(key, null)
		var masked_value := (value is String and String(value) == "") \
			or (value is Array and (value as Array).is_empty()) \
			or (value is Dictionary and (value as Dictionary).is_empty())
		_check(masked_value, "undiscovered enemy field masked: %s" % key)
	var hint_lines: Array = hidden.get("hintLines", []) as Array
	_check(not hint_lines.is_empty(), "undiscovered enemy has broad hint")
	_check(not JSON.stringify(hint_lines).contains("秒"), "undiscovered hint has no exact seconds")
	_check(not JSON.stringify(hint_lines).contains("偽ギフト"), "undiscovered hint has no identity leak")

	var weapon_file := FileAccess.open("res://data/weapons.json", FileAccess.READ)
	var gift_file := FileAccess.open("res://data/gifts.json", FileAccess.READ)
	_check(weapon_file != null and gift_file != null, "weapon/accessory masters remain readable")
	if weapon_file != null:
		var weapons: Variant = JSON.parse_string(weapon_file.get_as_text())
		weapon_file.close()
		_check(weapons is Array, "weapon JSON parses")
	if gift_file != null:
		var gifts: Variant = JSON.parse_string(gift_file.get_as_text())
		gift_file.close()
		_check(gifts is Array, "accessory JSON parses")

	CodexManager.initialize_empty()
	var save_text := JSON.stringify(CodexManager.get_save_data())
	_check(not save_text.contains("codexLore") and not save_text.contains("codexVisual"), "enemy Lore is not saved")
	var report := CodexManager.validate_masters()
	var report_counts: Dictionary = report.get("counts", {}) as Dictionary
	var enemy_counts: Dictionary = report_counts.get("enemies", {}) as Dictionary
	_check(int(enemy_counts.get("raw", 0)) == 44 and int(enemy_counts.get("enabled", 0)) == 42, "audit enemy count is 44/42")
	var audited_templates: Dictionary = enemy_counts.get("loreTemplateCounts", {}) as Dictionary
	_check(int(audited_templates.get("normal_enemy", 0)) == 25 and int(audited_templates.get("special", 0)) == 11 and int(audited_templates.get("boss", 0)) == 6, "audit template counts are 25/11/6")
	for warning_value in report.get("warnings", []) as Array:
		var warning := String(warning_value)
		_check(not warning.contains("enemies missing codexLore"), "audit has no missing enemy Lore warning: %s" % warning)
		_check(not warning.contains("enemies codexLore cards must have 3"), "audit has no enemy card warning: %s" % warning)
		_check(not warning.contains("enemies displayName mismatch"), "audit has no displayName mismatch warning: %s" % warning)

	_finish()

func _card_title(model: Dictionary, card_id: String) -> String:
	for value in model.get("cards", []) as Array:
		if value is Dictionary and String((value as Dictionary).get("id", "")) == card_id:
			return String((value as Dictionary).get("title", ""))
	return ""

func _find(items: Array, id: String) -> Dictionary:
	for value in items:
		if value is Dictionary and String((value as Dictionary).get("id", "")) == id:
			return value as Dictionary
	return {}

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _finish() -> void:
	if failures.is_empty():
		print("CODEX_ENEMY_LORE_V1_TESTS: PASS")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("CODEX_ENEMY_LORE_V1_TESTS: FAIL (%d)" % failures.size())
	get_tree().quit(1)
