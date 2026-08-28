extends Node

const CodexScreenScene := preload("res://scenes/ui/codex_screen.tscn")
const GameScene := preload("res://scenes/main.tscn")
const CommentSystemScript := preload("res://scripts/systems/comment_system.gd")
const CommonLightUiStyleScript := preload("res://scripts/ui/common_light_ui_style.gd")

var failures: Array[String] = []
var closed_seen := false
var closed_origins: Array[String] = []
var confirm_events := 0
var cancel_events := 0
var focus_cursor_events := 0
var focus_confirm_events := 0
var focus_cancel_events := 0
var focus_closed_events := 0
var focus_read_state_save_events := 0
var focus_read_state_save_requests: Array[Dictionary] = []

func _ready() -> void:
	CodexManager.initialize_empty()
	CodexManager.discover_enemy("enemy_bullet_drone")
	var screen = CodexScreenScene.instantiate()
	add_child(screen)
	screen.size = Vector2(1280, 720)
	screen.closed.connect(func(origin: String) -> void:
		closed_seen = true
		closed_origins.append(origin)
	)
	var cursor_move_events: Array[bool] = []
	screen.cursor_moved.connect(func() -> void: cursor_move_events.append(true))
	screen.open_screen("title")
	_check(bool(screen.visible), "codex screen opens")
	_check(screen.get_child_count() >= 2, "codex screen builds overlay controls")
	_check(String(screen._collection_label.text).contains("COLLECTION"), "codex screen shows collection summary")
	_check(String(screen._comment_log_label.text).contains("COMMENT LOG"), "codex screen shows separate comment log")
	_check(screen._collection_bar != null, "codex screen builds collection progress bar")
	_check(screen._debug_row != null and screen._debug_row.get_child_count() >= 4, "debug codex controls are visible in debug build")
	_check(_codex_buttons_are_manual_focus_only(screen), "codex buttons do not steal arrow/D-pad input from logical focus")
	_test_new_badge_structure(screen)
	var game_source := FileAccess.get_file_as_string("res://scripts/game.gd")
	_check(game_source.contains("codex_screen.confirm_requested.connect(_on_codex_confirm_requested)"), "game connects codex confirm signal")
	_check(game_source.contains("codex_screen.cancel_requested.connect(_on_codex_cancel_requested)"), "game connects codex cancel signal")
	_check(game_source.contains("func _on_codex_confirm_requested()") and game_source.contains("func _on_codex_cancel_requested()"), "game exposes codex SE handlers")
	_check(game_source.contains("func _prepare_codex_from_title()"), "game prepares codex separately for title transition")
	_check(game_source.contains("codex_screen.begin_common_front_transition(\"incoming\")"), "title codex path starts the common incoming transition")
	_check(game_source.contains("_begin_front_screen_transition(\"title\", \"codex\", \"forward\")"), "title codex path uses the shared front-screen clock")
	_check(game_source.contains("codex_screen.apply_common_front_transition"), "game adapter forwards the shared frame to codex")
	_check(game_source.contains("front_screen_transition_to == \"codex\""), "game finishes the title codex transition explicitly")
	_test_common_front_transition(screen)
	_test_focus_and_signal_contract()
	await _test_game_cursor_se_connection()
	screen.hide_screen()
	await _test_list_selection_scroll_contract()
	screen.open_screen("title")
	screen._select_category(0)
	screen._select_entry_by_id("ban_chan")
	var banri_profile_text := _character_profile_text(screen)
	_check(screen._character_profile_content.visible and not screen._detail_body.visible, "discovered character uses the structured profile content")
	_check(screen._character_unit_badge.visible and screen._character_unit_badge_label.text == "初期メンバー", "rookie character shows the unit badge")
	_check(screen._character_stream_card.visible and screen._character_likes_card.visible and screen._character_dislikes_card.visible and screen._character_profile_card.visible, "character detail builds all profile cards")
	_check(screen._character_overview_row.visible and screen._character_overview_image_frame.visible and not screen._detail_image_frame.visible, "formal character detail uses the in-scroll overview row")
	_check(screen._character_overview_image_holder.get_child_count() == 1 and screen._character_overview_image_holder.get_child(0) is TextureRect, "formal character detail uses one dedicated overview image")
	_check(banri_profile_text.contains("活動スタイル") and banri_profile_text.contains("好きなもの") and banri_profile_text.contains("苦手なもの") and banri_profile_text.contains("PROFILE"), "character detail shows the structured profile sections")
	_check(not banri_profile_text.contains("ほぼ同じ時期にデビューした") and banri_profile_text.contains("BANハンマーはいつしか彼女を象徴する道具になった。"), "character detail keeps the shared unit description out of the profile card")
	_check(banri_profile_text.contains("初期武器：BANハンマー") and banri_profile_text.contains("PLAY RECORD"), "character detail keeps game information and play record")
	_check(banri_profile_text.find("活動スタイル") < banri_profile_text.find("好きなもの") and banri_profile_text.find("好きなもの") < banri_profile_text.find("苦手なもの") and banri_profile_text.find("苦手なもの") < banri_profile_text.find("PROFILE"), "character profile cards keep the requested order")
	var banri_profile_body := screen._character_profile_card.get_meta("character_card_body", null) as Label
	_check(banri_profile_body != null and not banri_profile_body.text.contains("ほぼ同じ時期にデビューした"), "unit description is not copied into the PROFILE card")
	var banri_likes_body := screen._character_likes_card.get_meta("character_card_body", null) as Label
	_check(banri_likes_body != null and banri_likes_body.text.begins_with("・") and not banri_likes_body.text.contains("、"), "likes card keeps ordered bullet rows")
	_check(screen._character_profile_content.visible and not screen._detail_body.visible, "selected character keeps the full detail visible without a second detail mode")
	var senior_character_checks := {
		"aosumi_kyasumi": {"style": "落ち着いた進行と丁寧なコメント対応を得意とする", "profile": "冷静で落ち着いており", "weapon": "モデレーターシールド"},
		"akarine_rizumu": {"style": "テンション高めで、リアクションやファンサを交えながら進める", "profile": "見ている側まで元気になりそうな勢い", "weapon": "ファンサバトン"},
		"shizuki_miimu": {"style": "企画や見せ方にひとひねり加えるのが得意", "profile": "どこまで本気で、どこまで冗談なのか", "weapon": "釣りサムネロッド"}
	}
	for senior_id_value in senior_character_checks.keys():
		var senior_id := String(senior_id_value)
		var senior_expectation: Dictionary = senior_character_checks[senior_id] as Dictionary
		CodexManager.discover_character(senior_id)
		screen._select_category(0)
		screen._select_entry_by_id(senior_id)
		var senior_profile_text := _character_profile_text(screen)
		_check(screen._character_profile_content.visible and screen._character_unit_badge.visible and screen._character_unit_badge_label.text == "先輩メンバー", "senior detail shows the shared unit badge: %s" % senior_id)
		_check(not senior_profile_text.contains("ほぼ同じ時期にデビューした") and not senior_profile_text.contains("**"), "senior detail does not show an invented unit body or markdown markers: %s" % senior_id)
		_check(screen._character_stream_card.visible and senior_profile_text.contains(String(senior_expectation.get("style", ""))), "senior detail shows the activity style: %s" % senior_id)
		_check(screen._character_likes_card.visible and screen._character_dislikes_card.visible and screen._character_profile_card.visible, "senior detail shows all profile cards: %s" % senior_id)
		_check(senior_profile_text.contains(String(senior_expectation.get("profile", ""))), "senior detail shows the canonical profile text: %s" % senior_id)
		_check(senior_profile_text.contains("初期武器：" + String(senior_expectation.get("weapon", ""))) and senior_profile_text.contains("PLAY RECORD"), "senior detail keeps game information and play record: %s" % senior_id)
		_check(senior_profile_text.find("活動スタイル") < senior_profile_text.find("好きなもの") and senior_profile_text.find("好きなもの") < senior_profile_text.find("苦手なもの") and senior_profile_text.find("苦手なもの") < senior_profile_text.find("PROFILE"), "senior detail sections keep the requested order: %s" % senior_id)
	var cursor_before_category := cursor_move_events.size()
	screen._select_category(1)
	_check(cursor_move_events.size() == cursor_before_category + 1, "codex emits cursor movement for category navigation")
	CodexManager.discover_weapon("ban_hammer")
	screen._select_category(1)
	screen._select_entry_by_id("ban_hammer")
	_check(String(screen._detail_body.text).contains("LEVEL"), "normal weapon detail shows level section")
	_check(String(screen._detail_body.text).contains("標準性能"), "weapon detail labels standard performance")
	CodexManager.discover_weapon("ban_judgement")
	screen._select_entry_by_id("ban_judgement")
	_check(not String(screen._detail_body.text).contains("LEVEL"), "evolved weapon detail hides level section")
	CodexManager.discover_accessory("mini_humidifier")
	screen._select_category(2)
	screen._select_entry_by_id("mini_humidifier")
	var accessory_game_body := screen._item_game_data_card.get_meta("character_card_body", null) as Label
	_check(accessory_game_body != null and String(accessory_game_body.text).contains("Lv3"), "accessory GAME DATA shows its real max level")
	CodexManager.discover_comment("short_range")
	screen._select_category(4)
	screen._select_entry_by_id("short_range")
	await get_tree().process_frame
	var comment_game_body := screen._item_game_data_card.get_meta("character_card_body", null) as Label
	_check(comment_game_body != null and String(comment_game_body.text).contains("通常効果") and String(comment_game_body.text).contains("♡効果"), "comment GAME DATA shows normal and heart effects")
	var comment_visual_child := screen._item_visual_holder.get_child(0) if screen._item_visual_holder.get_child_count() > 0 else null
	_check(screen._item_profile_content.visible and comment_visual_child != null and (comment_visual_child is TextureRect or comment_visual_child is Label), "comment detail uses an illustration-only visual holder")
	_check(screen._item_visual_holder.clip_contents, "comment illustration holder clips its image")
	if comment_visual_child is TextureRect:
		var comment_rect := comment_visual_child as TextureRect
		_check(comment_rect.clip_contents and comment_rect.texture is AtlasTexture, "comment illustration uses a clipped content-trimmed AtlasTexture")
		if screen._item_visual_holder.size.y > 0.0:
			var visible_height_ratio := comment_rect.size.y / screen._item_visual_holder.size.y
			_check(visible_height_ratio >= 0.70 and visible_height_ratio <= 0.85, "comment illustration keeps the target 70-85%% height ratio: %.3f" % visible_height_ratio)
	_check(screen._item_visual_holder.find_child("TypeLabel", true, false) == null and screen._item_visual_holder.find_child("CommentLabel", true, false) == null and screen._item_visual_holder.find_child("EffectLabel", true, false) == null and screen._item_visual_holder.find_child("DirectiveCardPreview", true, false) == null, "comment illustration does not contain old card text or background nodes")
	var comment_wide_names: Array[String] = []
	for child in screen._item_comment_wide_column.get_children():
		comment_wide_names.append(String(child.name))
	var comment_half_names: Array[String] = []
	for child in screen._item_summary_secondary_row.get_children():
		comment_half_names.append(String(child.name))
	_check(comment_wide_names == ["CommentEffectSummaryCard", "ItemLoreCard_writer"] and comment_half_names == ["ItemLoreCard_posting_moment", "ItemLoreCard_observation_note"], "comment summary cards keep effect, writer, and half-card order")
	_check(not screen._item_summary_primary_row.visible and screen._item_comment_wide_column.get_parent() == screen._item_summary_area and screen._item_comment_effect_card.visible and String(screen._item_comment_effect_card.get_meta("item_lore_id", "")) == "effect_summary", "comment effect summary and writer are vertically stacked in the wide column")
	var comment_effect_body := screen._item_comment_effect_card.get_meta("character_card_body", null) as Label
	_check(comment_effect_body != null and String(comment_effect_body.text) == "射程が短くなる", "comment effect summary uses the existing description")
	var codex_screen_source := FileAccess.get_file_as_string("res://scripts/ui/codex_screen.gd")
	_check(not codex_screen_source.contains("InstructionCommentCardPreview") and not codex_screen_source.contains("_set_comment_preview") and not codex_screen_source.contains("DirectiveCardPreview"), "old comment preview is no longer referenced by CodexScreen")
	for comment_value in CodexManager.get_master_entries(CodexManager.CATEGORY_COMMENT):
		var comment_id := String((comment_value as Dictionary).get("id", ""))
		if comment_id == "do_everything":
			_check(CommentSystemScript.instruction_comment_icon_path(comment_id) == "", "special all-effects card keeps its image-free choice layout")
			continue
		var icon_path := CommentSystemScript.instruction_comment_icon_path(comment_id)
		_check(icon_path != "" and ResourceLoader.exists(icon_path), "choice icon exists for comment %s" % comment_id)
	screen._select_category(0)
	var down := InputEventKey.new()
	down.pressed = true
	down.keycode = KEY_DOWN
	_check(bool(screen.handle_input(down)), "codex screen handles list navigation")
	var enter := InputEventKey.new()
	enter.pressed = true
	enter.keycode = KEY_ENTER
	_check(bool(screen.handle_input(enter)), "codex screen handles explicit detail selection")
	screen._select_category(3)
	_check(screen._enemy_filter_buttons.size() == 7, "codex screen builds seven enemy filters")
	screen._toggle_new_filter()
	_check(screen._new_only and _contains_id(screen._visible_entries(), "enemy_bullet_drone"), "NEW filter keeps undiscovered-filter matches")
	screen._set_enemy_filter("gameplay")
	_check(not CodexManager.is_new(CodexManager.CATEGORY_ENEMY, "enemy_bullet_drone"), "formal filter selection clears the reached NEW item")
	screen._select_entry_by_id("enemy_bullet_drone")
	_check(not CodexManager.is_new(CodexManager.CATEGORY_ENEMY, "enemy_bullet_drone"), "explicit enemy detail selection preserves the read state")
	CodexManager.discover_enemy("last_offline")
	screen._set_enemy_filter("ALL")
	screen._select_entry_by_id("last_offline")
	var enemy_archive_body := screen._item_archive_card.get_meta("character_card_body", null) as Label
	var enemy_archive_heading := screen._item_archive_card.get_meta("character_card_heading", null) as Label
	var enemy_game_body := screen._item_game_data_card.get_meta("character_card_body", null) as Label
	_check(screen._item_profile_content.visible and not screen._detail_body.visible, "discovered enemy uses the structured Lore detail")
	_check(screen._character_unit_badge.visible and screen._character_unit_badge_label.text == "SPECIAL BOSS", "special boss detail has a distinct classification badge")
	_check(enemy_archive_heading != null and enemy_archive_heading.text == "ENEMY ARCHIVE" and enemy_archive_body != null and enemy_archive_body.text.strip_edges() != "", "enemy archive card uses the Lore model")
	_check(enemy_game_body != null and enemy_game_body.text.contains("基本特性") and enemy_game_body.text.contains("攻撃タイプ："), "enemy GAME DATA keeps runtime profile labels")
	_check(not String(screen._detail_body.text).contains("攻略メモ："), "old duplicated enemy strategy section is removed")
	screen._set_enemy_filter("singing")
	_check(CodexManager.get_total_count(CodexManager.CATEGORY_ENEMY) == 42, "filter progress keeps full category total")
	screen._set_enemy_filter("gameplay")
	CodexManager.initialize_empty()
	screen.open_screen("title")
	for comment_value in CodexManager.get_master_entries(CodexManager.CATEGORY_COMMENT):
		CodexManager.discover_comment(String((comment_value as Dictionary).get("id", "")))
	_check(screen._completion_banner.visible, "completion banner is shown after live discovery")
	screen.close_screen()
	_check(not bool(screen.visible) and closed_seen and closed_origins.size() == 1 and closed_origins[0] == "title", "codex screen closes and emits title origin")
	screen.close_screen()
	_check(closed_origins.size() == 1, "repeated codex close does not emit a second closed signal")
	if failures.is_empty():
		print("CODEX_SCREEN_TESTS: PASS")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("CODEX_SCREEN_TESTS: FAIL (%d)" % failures.size())
	get_tree().quit(1)

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _character_profile_text(screen) -> String:
	var parts: Array[String] = []
	if screen._character_unit_badge.visible:
		parts.append(String(screen._character_unit_badge_label.text))
	for card in [screen._character_stream_card, screen._character_likes_card, screen._character_dislikes_card, screen._character_profile_card, screen._character_game_info_card, screen._character_play_record_card]:
		if card == null or not card.visible:
			continue
		var heading := card.get_meta("character_card_heading", null) as Label
		var body := card.get_meta("character_card_body", null) as Label
		if heading != null:
			parts.append(String(heading.text))
		if body != null:
			parts.append(String(body.text))
	return "\n\n".join(parts)

func _test_focus_and_signal_contract() -> void:
	var focus_screen = CodexScreenScene.instantiate()
	add_child(focus_screen)
	focus_screen.size = Vector2(1280, 720)
	focus_cursor_events = 0
	focus_confirm_events = 0
	focus_cancel_events = 0
	focus_closed_events = 0
	focus_screen.cursor_moved.connect(func() -> void: focus_cursor_events += 1)
	focus_screen.confirm_requested.connect(func() -> void: focus_confirm_events += 1)
	focus_screen.cancel_requested.connect(func() -> void: focus_cancel_events += 1)
	focus_screen.closed.connect(func(_origin: String) -> void: focus_closed_events += 1)
	focus_read_state_save_events = 0
	focus_read_state_save_requests.clear()
	focus_screen.read_state_save_requested.connect(func(category: String, item_id: String) -> void:
		focus_read_state_save_events += 1
		focus_read_state_save_requests.append({"category": category, "id": item_id})
	)

	CodexManager.initialize_empty()
	CodexManager.discover_weapon("ban_hammer")
	focus_screen._selected_ids[CodexManager.CATEGORY_WEAPON] = "ban_hammer"
	focus_screen.open_screen("title", {}, {"category": "weapons"})
	_check(focus_read_state_save_events == 1, "initial formal selection emits one NEW save request")
	_check(focus_read_state_save_requests.size() == 1 and String(focus_read_state_save_requests[0].get("category", "")) == CodexManager.CATEGORY_WEAPON and String(focus_read_state_save_requests[0].get("id", "")) == "ban_hammer", "NEW save request carries the selected category and id")
	_check(not CodexManager.is_new(CodexManager.CATEGORY_WEAPON, "ban_hammer"), "formal selection clears NEW before requesting persistence")
	focus_screen._select_entry_by_id("ban_hammer")
	_check(focus_read_state_save_events == 1, "reselecting an already-read item does not request another save")
	CodexManager.discover_weapon("superchat_shot")
	focus_screen._select_entry_by_id("superchat_shot")
	_check(focus_read_state_save_events == 2 and not CodexManager.is_new(CodexManager.CATEGORY_WEAPON, "superchat_shot"), "mouse/list formal selection shares the one-shot NEW save path")
	focus_screen._select_entry_by_id("superchat_shot")
	_check(focus_read_state_save_events == 2, "same-item formal selection does not duplicate persistence")
	CodexManager.initialize_empty()
	focus_screen.open_screen("title", {}, {"category": "weapons"})
	var read_events_before_hidden := focus_read_state_save_events
	focus_screen._select_entry_by_id("ban_hammer")
	_check(focus_read_state_save_events == read_events_before_hidden, "undiscovered selection does not request persistence")
	var codex_screen_source := FileAccess.get_file_as_string("res://scripts/ui/codex_screen.gd")
	_check(codex_screen_source.contains("read_state_save_requested.emit(category, item_id)"), "CodexScreen emits persistence only after a successful read transition")
	var game_source := FileAccess.get_file_as_string("res://scripts/game.gd")
	_check(game_source.contains("codex_screen.read_state_save_requested.connect(_on_codex_read_state_save_requested)"), "Game connects the Codex NEW persistence signal")
	_check(game_source.contains("func _on_codex_read_state_save_requested(category: String, item_id: String)") and game_source.contains("DifficultyProgressSystemScript.save_progress(difficulty_progress)"), "Game handles the NEW persistence request synchronously")

	CodexManager.initialize_empty()
	focus_screen.open_screen("title", {}, {"category": "characters"})
	var character_category := CodexManager.CATEGORY_CHARACTER
	var first_id := String((focus_screen._visible_entries()[0] as Dictionary).get("id", ""))
	var cursor_before := focus_cursor_events
	_check(bool(focus_screen.handle_input(_key_event(KEY_UP))), "first item accepts Up input")
	_check(int(focus_screen._focus_area) == 1 and String(focus_screen._selected_ids.get(character_category, "")) == first_id, "first item Up moves logical focus to BACK")
	_check(not _list_has_cursor(focus_screen) and _list_rows_are_normal(focus_screen), "BACK focus hides the list cursor and selected row style")
	_check(focus_cursor_events == cursor_before + 1, "entering BACK emits one cursor movement")
	cursor_before = focus_cursor_events
	_check(bool(focus_screen.handle_input(_key_event(KEY_DOWN))), "BACK accepts Down input")
	_check(int(focus_screen._focus_area) == 0 and String(focus_screen._selected_ids.get(character_category, "")) == first_id, "BACK Down returns to first list item")
	_check(_list_has_cursor(focus_screen) and not _list_rows_are_normal(focus_screen), "returning from BACK restores the list cursor")
	_check(focus_cursor_events == cursor_before + 1, "leaving BACK emits one cursor movement")
	focus_screen._selected_ids[character_category] = "shizuki_miimu"
	focus_screen._refresh_list_and_detail()
	cursor_before = focus_cursor_events
	_check(bool(focus_screen.handle_input(_key_event(KEY_DOWN))), "last item accepts Down input")
	_check(int(focus_screen._focus_area) == 1 and String(focus_screen._selected_ids.get(character_category, "")) == "shizuki_miimu", "last item Down moves logical focus to BACK")
	_check(not _list_has_cursor(focus_screen) and _list_rows_are_normal(focus_screen), "last-item BACK focus hides the list cursor")
	_check(focus_cursor_events == cursor_before + 1, "last item enters BACK once")
	cursor_before = focus_cursor_events
	_check(bool(focus_screen.handle_input(_key_event(KEY_UP))), "BACK accepts Up input")
	_check(int(focus_screen._focus_area) == 0 and String(focus_screen._selected_ids.get(character_category, "")) == "shizuki_miimu", "BACK Up returns to last list item")
	_check(_list_has_cursor(focus_screen), "BACK Up restores the last row cursor")
	_check(focus_cursor_events == cursor_before + 1, "BACK Up emits one cursor movement")
	var category_before: int = focus_screen._category_index
	cursor_before = focus_cursor_events
	focus_screen._move_selection(1)
	_check(int(focus_screen._focus_area) == 1, "last item can re-enter BACK")
	focus_screen.handle_input(_key_event(KEY_LEFT))
	_check(focus_screen._category_index == category_before and focus_cursor_events == cursor_before + 1, "BACK Left does not change category or emit extra movement")
	_check(bool(focus_screen.handle_input(_key_event(KEY_ENTER))), "BACK accepts Enter")
	_check(focus_closed_events == 1 and focus_cancel_events == 1, "BACK Enter closes once with one cancel signal")

	CodexManager.initialize_empty()
	CodexManager.discover_weapon("ban_hammer")
	focus_screen.open_screen("title", {}, {"category": "weapons"})
	focus_screen._select_entry_by_id("ban_hammer")
	var confirm_before := focus_confirm_events
	_check(String(focus_screen._detail_body.text).contains("標準性能"), "list selection shows the complete weapon detail before DETAIL focus")
	_check(int(focus_screen._input_focus) == 0 and _list_has_cursor(focus_screen), "initial complete detail still starts with LIST focus")
	var detail_is_scrollable := focus_screen._detail_is_scrollable()
	_check(bool(focus_screen.handle_input(_key_event(KEY_ENTER))), "list Enter is consumed")
	if detail_is_scrollable:
		_check(int(focus_screen._input_focus) == 1, "scrollable detail enters DETAIL focus")
		_check(focus_confirm_events == confirm_before + 1, "entering DETAIL emits one confirm signal")
		var ring := focus_screen.get_node_or_null("DetailFocusRing") as PanelContainer
		_check(ring != null and ring.visible, "DETAIL focus shows the detail outline")
		_check(focus_screen._detail_back_button.text == "一覧へ戻る", "DETAIL focus changes the footer back action")
		_check(not _list_has_cursor(focus_screen) and not _list_rows_are_normal(focus_screen), "DETAIL keeps a weak selected row without the strong cursor")
		var detail_scroll_before := focus_screen._detail_scroll.scroll_vertical
		focus_screen.handle_input(_key_event(KEY_PAGEDOWN))
		_check(focus_screen._detail_scroll.scroll_vertical >= detail_scroll_before, "DETAIL PageDown scrolls the right detail only")
		var selected_before_horizontal := String(focus_screen._selected_ids.get(CodexManager.CATEGORY_WEAPON, ""))
		var category_before_horizontal := focus_screen._category_index
		var enemy_filter_before_horizontal := focus_screen._enemy_filter_id
		var new_only_before_horizontal := focus_screen._new_only
		var scroll_before_horizontal := focus_screen._detail_scroll.scroll_vertical
		var cursor_before_horizontal := focus_cursor_events
		var confirm_before_horizontal := focus_confirm_events
		var cancel_before_horizontal := focus_cancel_events
		_check(bool(focus_screen.handle_input(_key_event(KEY_LEFT))), "DETAIL KEY_LEFT is consumed as reserved input")
		_check(bool(focus_screen.handle_input(_key_event(KEY_RIGHT))), "DETAIL KEY_RIGHT is consumed as reserved input")
		_check(bool(focus_screen.handle_input(_pad_event(JOY_BUTTON_DPAD_LEFT))), "DETAIL D-pad left is consumed as reserved input")
		_check(bool(focus_screen.handle_input(_pad_event(JOY_BUTTON_DPAD_RIGHT))), "DETAIL D-pad right is consumed as reserved input")
		_check(bool(focus_screen.handle_input(_pad_event(JOY_BUTTON_LEFT_SHOULDER))), "DETAIL left shoulder is consumed as reserved input")
		_check(bool(focus_screen.handle_input(_pad_event(JOY_BUTTON_RIGHT_SHOULDER))), "DETAIL right shoulder is consumed as reserved input")
		_check(int(focus_screen._input_focus) == 1 and String(focus_screen._selected_ids.get(CodexManager.CATEGORY_WEAPON, "")) == selected_before_horizontal, "DETAIL horizontal input does not change the selected item")
		_check(focus_screen._category_index == category_before_horizontal and focus_screen._enemy_filter_id == enemy_filter_before_horizontal and focus_screen._new_only == new_only_before_horizontal, "DETAIL horizontal input does not change the navigation scope")
		_check(focus_screen._detail_scroll.scroll_vertical == scroll_before_horizontal and focus_cursor_events == cursor_before_horizontal and focus_confirm_events == confirm_before_horizontal and focus_cancel_events == cancel_before_horizontal, "DETAIL horizontal input does not scroll or emit SE signals")
		var horizontal_echo := _key_event(KEY_RIGHT)
		horizontal_echo.echo = true
		_check(not focus_screen.handle_input(horizontal_echo), "DETAIL horizontal key echo is ignored")
		var horizontal_release := _key_event(KEY_RIGHT)
		horizontal_release.pressed = false
		_check(not focus_screen.handle_input(horizontal_release), "DETAIL horizontal key release is ignored")
		var horizontal_axis := _motion_event(JOY_AXIS_LEFT_X, 0.8)
		_check(bool(focus_screen.handle_input(horizontal_axis)), "DETAIL left-stick horizontal input is consumed")
		_check(String(focus_screen._selected_ids.get(CodexManager.CATEGORY_WEAPON, "")) == selected_before_horizontal and focus_screen._category_index == category_before_horizontal, "DETAIL left-stick horizontal input is a no-op")
		_check(bool(focus_screen.handle_input(horizontal_axis)), "DETAIL held left-stick horizontal input remains consumed")
		focus_screen.handle_input(_motion_event(JOY_AXIS_LEFT_X, 0.0))
		_check(bool(focus_screen.handle_input(_motion_event(JOY_AXIS_LEFT_X, -0.8))), "DETAIL re-armed left-stick horizontal input is consumed")
		_check(String(focus_screen._selected_ids.get(CodexManager.CATEGORY_WEAPON, "")) == selected_before_horizontal and focus_screen._category_index == category_before_horizontal, "DETAIL re-armed left-stick horizontal input remains a no-op")
		focus_screen._set_detail_scroll_value(100.0)
		var preserved_detail_scroll := focus_screen._detail_scroll.scroll_vertical
		var cancel_before := focus_cancel_events
		var closed_before := focus_closed_events
		focus_screen.handle_input(_key_event(KEY_ESCAPE))
		_check(int(focus_screen._input_focus) == 0 and focus_cancel_events == cancel_before + 1 and focus_closed_events == closed_before, "DETAIL Escape returns to LIST without closing")
		_check(focus_screen._detail_scroll.scroll_vertical == preserved_detail_scroll, "DETAIL to LIST preserves the scroll position")
		_check(not ring.visible and _list_has_cursor(focus_screen), "returning to LIST restores the cursor and hides the outline")
		var confirm_before_reenter := focus_confirm_events
		_check(bool(focus_screen.handle_input(_key_event(KEY_ENTER))), "re-entering the same detail is consumed")
		_check(int(focus_screen._input_focus) == 1 and focus_screen._detail_scroll.scroll_vertical == preserved_detail_scroll and focus_confirm_events == confirm_before_reenter + 1, "re-entering the same item preserves detail scroll")
		focus_screen.handle_input(_key_event(KEY_ESCAPE))
		_check(int(focus_screen._input_focus) == 0, "re-entering detail can return to LIST")
	else:
		_check(int(focus_screen._input_focus) == 0 and focus_confirm_events == confirm_before, "short detail does not enter DETAIL or emit confirm")
	var list_category_before := focus_screen._category_index
	var list_selected_before := String(focus_screen._selected_ids.get(CodexManager.CATEGORY_WEAPON, ""))
	_check(bool(focus_screen.handle_input(_key_event(KEY_RIGHT))), "LIST KEY_RIGHT is consumed")
	_check(focus_screen._category_index != list_category_before and int(focus_screen._input_focus) == 0, "LIST KEY_RIGHT still changes category")
	_check(String(focus_screen._selected_ids.get(CodexManager.CATEGORY_WEAPON, "")) == list_selected_before, "LIST KEY_RIGHT does not move the previous category item")

	var cancel_before := focus_cancel_events
	focus_screen.handle_input(_key_event(KEY_ESCAPE))
	_check(not focus_screen.visible and focus_cancel_events == cancel_before + 1 and focus_closed_events == 2, "LIST Escape closes with one cancel signal")
	focus_screen.open_screen("title", {}, {"category": "weapons"})
	cancel_before = focus_cancel_events
	focus_screen._handle_back_button()
	_check(not focus_screen.visible and focus_cancel_events == cancel_before + 1 and focus_closed_events == 3, "LIST back button closes directly with one cancel signal")
	_check(focus_confirm_events == confirm_before + (2 if detail_is_scrollable else 0), "confirm is emitted only when DETAIL focus is entered")

	CodexManager.initialize_empty()
	focus_screen.open_screen("title", {}, {"category": "characters"})
	focus_screen._selected_ids[CodexManager.CATEGORY_CHARACTER] = "ban_chan"
	focus_screen._refresh_list_and_detail()
	_check(bool(focus_screen.handle_input(_pad_event(JOY_BUTTON_DPAD_UP))) and int(focus_screen._focus_area) == 1, "D-pad Up uses the BACK boundary")
	_check(bool(focus_screen.handle_input(_pad_event(JOY_BUTTON_DPAD_DOWN))) and int(focus_screen._focus_area) == 0, "D-pad Down returns to the first item")
	var analog_up := _motion_event(JOY_AXIS_LEFT_Y, -0.8)
	var analog_cursor_before := focus_cursor_events
	_check(bool(focus_screen.handle_input(analog_up)) and int(focus_screen._focus_area) == 1, "analog Up uses the BACK boundary")
	focus_screen.handle_input(analog_up)
	_check(focus_cursor_events == analog_cursor_before + 1, "analog latch prevents repeated boundary movement")
	focus_screen.handle_input(_motion_event(JOY_AXIS_LEFT_Y, 0.0))
	_check(bool(focus_screen.handle_input(_motion_event(JOY_AXIS_LEFT_Y, 0.8))) and int(focus_screen._focus_area) == 0, "analog Down returns to the first item")
	focus_screen.close_screen()

	CodexManager.initialize_empty()
	focus_screen.open_screen("title", {}, {"category": "weapons"})
	CodexManager.discover_weapon("ban_hammer")
	focus_screen._toggle_new_filter()
	_check(focus_screen._new_only and focus_screen._visible_entries().size() == 1, "single-item NEW snapshot is available for boundary focus")
	_check(bool(focus_screen.handle_input(_key_event(KEY_UP))) and int(focus_screen._focus_area) == 1, "single item Up moves to BACK")
	_check(bool(focus_screen.handle_input(_key_event(KEY_DOWN))) and int(focus_screen._focus_area) == 0, "single item BACK Down returns to list")
	_check(bool(focus_screen.handle_input(_key_event(KEY_DOWN))) and int(focus_screen._focus_area) == 1, "single item Down moves to BACK")
	focus_screen.close_screen()

	CodexManager.initialize_empty()
	focus_screen.open_screen("title", {}, {"category": "weapons"})
	var invalid_confirm_before := focus_confirm_events
	focus_screen._select_entry(-1)
	_check(focus_confirm_events == invalid_confirm_before, "invalid selection does not emit confirm")
	focus_screen._new_only = true
	focus_screen._new_snapshot_ids[CodexManager.CATEGORY_WEAPON] = []
	focus_screen._refresh_list_and_detail()
	_check(bool(focus_screen.handle_input(_key_event(KEY_UP))) and int(focus_screen._focus_area) == 1, "empty list Up moves to BACK")
	focus_screen.handle_input(_key_event(KEY_DOWN))
	_check(int(focus_screen._focus_area) == 1, "empty list Down remains safely in BACK")
	focus_screen.close_screen()
	focus_screen.queue_free()
	CodexManager.initialize_empty()
	CodexManager.discover_enemy("enemy_bullet_drone")

func _test_list_selection_scroll_contract() -> void:
	CodexManager.initialize_empty()
	for master_value in CodexManager.get_master_entries(CodexManager.CATEGORY_ENEMY):
		if not master_value is Dictionary:
			continue
		var master := master_value as Dictionary
		if not bool(master.get("codexEnabled", true)):
			continue
		CodexManager.discover_enemy(String(master.get("id", "")))

	var scroll_screen = CodexScreenScene.instantiate()
	add_child(scroll_screen)
	scroll_screen.size = Vector2(1280, 720)
	scroll_screen.open_screen("title", {}, {"category": CodexManager.CATEGORY_ENEMY})
	await get_tree().process_frame
	_check(scroll_screen._visible_entries().size() == 42, "enemy list scroll fixture exposes all 42 enabled entries")
	var initial_scroll := float(scroll_screen._list_scroll.scroll_vertical)
	var down_moves := 14
	for _step in range(down_moves):
		var before_index := scroll_screen._selected_index(scroll_screen._visible_entries())
		scroll_screen.handle_input(_key_event(KEY_DOWN))
		await get_tree().process_frame
		var after_index := scroll_screen._selected_index(scroll_screen._visible_entries())
		_check(after_index == before_index + 1, "down input advances exactly one list entry")
		_check(_selected_list_row_visible(scroll_screen), "down input keeps the selected row inside the list viewport")
	var after_down_scroll := float(scroll_screen._list_scroll.scroll_vertical)
	_check(after_down_scroll > initial_scroll, "down input scrolls the left list when the selected row reaches the viewport edge")

	for _step in range(down_moves):
		var before_index := scroll_screen._selected_index(scroll_screen._visible_entries())
		scroll_screen.handle_input(_key_event(KEY_UP))
		await get_tree().process_frame
		var after_index := scroll_screen._selected_index(scroll_screen._visible_entries())
		_check(after_index == before_index - 1, "up input moves exactly one list entry")
		_check(_selected_list_row_visible(scroll_screen), "up input keeps the selected row inside the list viewport")
	var after_up_scroll := float(scroll_screen._list_scroll.scroll_vertical)
	_check(after_up_scroll < after_down_scroll, "up input scrolls the left list back when needed")
	scroll_screen.size = Vector2(1600, 900)
	scroll_screen._apply_layout_metrics()
	scroll_screen._select_entry_by_id("last_offline")
	await get_tree().process_frame
	_check(_selected_list_row_visible(scroll_screen), "standard layout also reveals a selected lower enemy row")
	scroll_screen.size = Vector2(1280, 720)
	scroll_screen._apply_layout_metrics()
	await get_tree().process_frame

	var list_scroll_bar := scroll_screen._list_scroll.get_v_scroll_bar()
	var manual_max := maxf(0.0, float(list_scroll_bar.max_value) - float(list_scroll_bar.page)) if list_scroll_bar != null else 0.0
	var manual_scroll := maxf(0.0, manual_max)
	scroll_screen._list_scroll.scroll_vertical = int(round(manual_scroll))
	var neutral_scroll := float(scroll_screen._list_scroll.scroll_vertical)
	scroll_screen._refresh_list_and_detail(true, true, false)
	await get_tree().process_frame
	_check(is_equal_approx(float(scroll_screen._list_scroll.scroll_vertical), neutral_scroll), "neutral list redraw preserves manual list scrolling")
	scroll_screen._move_selection(1)
	await get_tree().process_frame
	_check(_selected_list_row_visible(scroll_screen), "explicit selection movement takes priority over old list scroll")
	_check(float(scroll_screen._list_scroll.scroll_vertical) < neutral_scroll, "explicit selection movement overrides the old scroll position when the row is hidden")

	scroll_screen._select_entry_by_id("last_offline")
	await get_tree().process_frame
	_check(_selected_list_row_visible(scroll_screen), "selecting the last enemy reveals the last row")
	scroll_screen._move_selection(1)
	scroll_screen._list_scroll.scroll_vertical = 0
	scroll_screen.handle_input(_key_event(KEY_UP))
	await get_tree().process_frame
	_check(int(scroll_screen._focus_area) == 0 and String(scroll_screen._selected_ids.get(CodexManager.CATEGORY_ENEMY, "")) == "last_offline", "BACK Up returns to the last selected list item")
	_check(_selected_list_row_visible(scroll_screen), "BACK to list restoration reveals the returning last row")

	var list_scroll_before_detail := float(scroll_screen._list_scroll.scroll_vertical)
	var detail_entered := bool(scroll_screen.handle_input(_key_event(KEY_ENTER)))
	await get_tree().process_frame
	_check(detail_entered and int(scroll_screen._input_focus) == 1, "scrollable enemy detail enters DETAIL focus")
	if int(scroll_screen._input_focus) == 1:
		scroll_screen.handle_input(_key_event(KEY_DOWN))
		await get_tree().process_frame
		_check(is_equal_approx(float(scroll_screen._list_scroll.scroll_vertical), list_scroll_before_detail), "DETAIL vertical scrolling leaves the left list position unchanged")
	scroll_screen.queue_free()
	await get_tree().process_frame
	CodexManager.initialize_empty()
	CodexManager.discover_enemy("enemy_bullet_drone")

func _test_common_front_transition(screen: Control) -> void:
	var visual_root := screen._transition_visual_root as Control
	var veil := screen._transition_veil as ColorRect
	_check(visual_root != null and veil != null, "codex builds a shared transition visual root and fixed veil")
	if visual_root == null or veil == null:
		return
	var base_position := visual_root.position
	screen.finish_common_front_transition(true)
	screen.begin_common_front_transition("incoming")
	_check(screen._common_front_transition_locked, "codex locks input during incoming transition")
	_check(not screen.visible and not visual_root.visible, "incoming codex visuals stay hidden before midpoint")
	_check(veil.mouse_filter == Control.MOUSE_FILTER_STOP, "transition veil blocks mouse input while locked")
	var selected_before := screen._selected_ids.duplicate(true)
	_check(bool(screen.handle_input(_key_event(KEY_DOWN))) and screen._selected_ids == selected_before, "codex ignores input while transition is locked")
	screen.apply_common_front_transition(52.0, 0.70, true)
	_check(screen.visible and visual_root.visible, "codex visuals appear at the shared transition midpoint")
	_check(is_equal_approx(visual_root.position.x, base_position.x + 52.0), "codex uses the shared incoming offset")
	_check(is_equal_approx(veil.color.a, 0.70) and veil.color.r == 0.965 and veil.color.g == 0.95 and veil.color.b == 1.0, "codex veil uses the shared overlay color and alpha")
	screen.apply_common_front_transition(6.5, 0.12, true)
	_check(is_equal_approx(visual_root.position.x, base_position.x + 6.5), "codex follows the shared eased incoming offset")
	screen.finish_common_front_transition(true)
	_check(screen.visible and visual_root.visible and is_equal_approx(visual_root.position.x, base_position.x), "codex finish restores its base position")
	_check(not screen._common_front_transition_locked and not veil.visible and veil.mouse_filter == Control.MOUSE_FILTER_IGNORE, "codex finish clears veil and input lock")
	screen.finish_common_front_transition(false)
	_check(not screen.visible and not visual_root.visible and is_equal_approx(visual_root.position.x, base_position.x), "codex finish(false) resets the transition state")
	screen.open_screen("title")
	_check(screen.visible and not screen._common_front_transition_locked and is_equal_approx(visual_root.position.x, base_position.x), "direct codex open clears stale transition state")
	var closed_before_hide := closed_origins.size()
	screen.hide_screen()
	_check(not screen.visible and closed_origins.size() == closed_before_hide, "forced codex hide does not emit closed")
	screen.open_screen("title")
	_check(screen.visible and not screen._common_front_transition_locked and not veil.visible and is_equal_approx(visual_root.position.x, base_position.x), "reopen after forced hide restores normal transition state")

func _key_event(keycode: Key) -> InputEventKey:
	var event := InputEventKey.new()
	event.pressed = true
	event.keycode = keycode
	return event

func _test_game_cursor_se_connection() -> void:
	var game = GameScene.instantiate()
	add_child(game)
	await get_tree().process_frame
	await get_tree().process_frame
	var runtime_screen = game.codex_screen
	var connected := false
	for connection in runtime_screen.get_signal_connection_list("cursor_moved"):
		var callable: Callable = connection.get("callable", Callable())
		if callable.is_valid() and callable.get_object() == game and callable.get_method() == "_on_codex_cursor_moved":
			connected = true
	_check(connected, "runtime cursor signal is connected to Game handler")
	var read_state_save_connected := false
	for connection in runtime_screen.get_signal_connection_list("read_state_save_requested"):
		var callable: Callable = connection.get("callable", Callable())
		if callable.is_valid() and callable.get_object() == game and callable.get_method() == "_on_codex_read_state_save_requested":
			read_state_save_connected = true
	_check(read_state_save_connected, "runtime NEW persistence signal is connected to Game handler")
	_check(game.ui_se_player != null and game.ui_se_player.stream != null, "runtime cursor SE player has a stream")
	CodexManager.initialize_empty()
	game.state = "codex"
	runtime_screen.size = Vector2(1280, 720)
	runtime_screen.open_screen("title", {}, {"category": CodexManager.CATEGORY_CHARACTER})
	runtime_screen._selected_ids[CodexManager.CATEGORY_CHARACTER] = "ban_chan"
	runtime_screen._refresh_list_and_detail()
	runtime_screen.handle_input(_key_event(KEY_UP))
	_check(int(runtime_screen._focus_area) == 1, "runtime boundary input enters BACK")
	_check(game.ui_se_player.playing, "runtime boundary input starts cursor SE")
	runtime_screen.hide_screen()
	game.state = "title"
	game.front_screen_transition_active = false
	game._open_codex()
	_check(game.state == "codex" and game.front_screen_transition_active, "runtime title-to-codex starts the common transition")
	_check(game.front_screen_transition_from == "title" and game.front_screen_transition_to == "codex" and game.front_screen_transition_direction == "forward", "runtime title-to-codex uses the expected transition endpoints")
	_check(runtime_screen._common_front_transition_locked and not runtime_screen.visible, "runtime codex hides and locks before the transition midpoint")
	game._finish_front_screen_transition()
	_check(runtime_screen.visible and not runtime_screen._common_front_transition_locked, "runtime codex finishes at the normal interactive position")
	var result_snapshot := game.last_result_data.duplicate(true)
	runtime_screen.close_screen()
	_check(game.state == "title" and not runtime_screen.visible, "runtime title-origin close returns Game to the title state")
	game.state = "codex"
	game.codex_return_state = "result"
	runtime_screen.open_screen("result")
	runtime_screen.close_screen()
	_check(game.state == "result" and game.last_result_data == result_snapshot, "runtime result-origin close returns without changing last result data")
	game.queue_free()
	await get_tree().process_frame
	CodexManager.initialize_empty()
	CodexManager.discover_enemy("enemy_bullet_drone")

func _pad_event(button_index: int) -> InputEventJoypadButton:
	var event := InputEventJoypadButton.new()
	event.pressed = true
	event.button_index = button_index
	return event

func _motion_event(axis: int, value: float) -> InputEventJoypadMotion:
	var event := InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = value
	return event

func _list_has_cursor(screen: Control) -> bool:
	if screen._list_box == null:
		return false
	for child in screen._list_box.get_children():
		if child is Button:
			var marker := (child as Button).find_child("SelectionMarker", true, false) as Label
			if marker != null and String(marker.text).begins_with("▶"):
				return true
	return false

func _selected_list_row_visible(screen: Control) -> bool:
	if screen._list_scroll == null or screen._list_box == null:
		return false
	var entries := screen._visible_entries()
	var selected := screen._selected_index(entries)
	if selected < 0 or selected >= screen._list_box.get_child_count():
		return false
	var row := screen._list_box.get_child(selected) as Control
	if row == null:
		return false
	var viewport_rect := screen._list_scroll.get_global_rect()
	var row_rect := row.get_global_rect()
	return row_rect.position.y >= viewport_rect.position.y - 1.0 and row_rect.end.y <= viewport_rect.end.y + 1.0

func _test_new_badge_structure(screen: Control) -> void:
	var fixtures: Array[Dictionary] = [
		{"category": CodexManager.CATEGORY_CHARACTER, "id": "aosumi_kyasumi"},
		{"category": CodexManager.CATEGORY_WEAPON, "id": "superchat_shot"},
		{"category": CodexManager.CATEGORY_ACCESSORY, "id": "bullet_support"},
		{"category": CodexManager.CATEGORY_ENEMY, "id": "enemy_bullet_drone"},
		{"category": CodexManager.CATEGORY_COMMENT, "id": "short_range"},
	]
	for fixture in fixtures:
		var category := String(fixture.get("category", ""))
		var target_id := String(fixture.get("id", ""))
		CodexManager.initialize_empty()
		CodexManager.discover(category, target_id)
		screen.open_screen("title", {}, {"category": category})
		var target_badge: PanelContainer = null
		for child in screen._list_box.get_children():
			var button := child as Button
			if button == null:
				continue
			var item_id := String(button.get_meta("codex_item_id", ""))
			var badge := button.find_child("NewBadge", true, false) as PanelContainer
			if item_id == target_id:
				target_badge = badge
				_check(badge != null and badge.visible, "NEW badge is visible for %s" % category)
				if badge != null:
					var badge_label := badge.find_child("NewBadgeLabel", true, false) as Label
					var badge_style := badge.get_theme_stylebox("panel") as StyleBoxFlat
					var item_name_label := button.find_child("ItemNameLabel", true, false) as Label
					_check(badge_label != null and badge_label.text == "NEW", "NEW badge text is separated from item name for %s" % category)
					_check(item_name_label != null and not item_name_label.text.contains("NEW"), "item name does not concatenate NEW text for %s" % category)
					_check(badge_label != null and badge_label.get_theme_color("font_color") == CommonLightUiStyleScript.NEW_BADGE_TEXT, "NEW badge text uses the shared white color for %s" % category)
					_check(badge_style != null and badge_style.bg_color == CommonLightUiStyleScript.NEW_BADGE_FILL and badge_style.border_color == CommonLightUiStyleScript.NEW_BADGE_BORDER, "NEW badge uses shared fixed colors for %s" % category)
					_check(badge.custom_minimum_size.y >= 20.0 and badge.custom_minimum_size.y <= 24.0 and badge.custom_minimum_size.x >= 54.0, "NEW badge keeps a fixed readable size for %s" % category)
					_check(badge_style != null and badge_style.shadow_size == 0, "NEW badge has no shadow for %s" % category)
			else:
				_check(badge == null, "non-NEW row has no visible badge for %s" % category)
		_check(target_badge != null, "each category exposes a dedicated NEW badge")
	CodexManager.initialize_empty()
	CodexManager.discover_enemy("enemy_bullet_drone")
	screen.open_screen("title")

func _list_rows_are_normal(screen: Control) -> bool:
	if screen._list_box == null:
		return true
	for child in screen._list_box.get_children():
		if child is Button:
			var style := (child as Button).get_theme_stylebox("normal") as StyleBoxFlat
			if style != null and style.border_width_left > 1:
				return false
	return true

func _codex_buttons_are_manual_focus_only(screen: Control) -> bool:
	var buttons: Array = []
	buttons.append_array(screen._category_buttons)
	buttons.append_array(screen._enemy_filter_buttons)
	buttons.append(screen._all_filter_button)
	buttons.append(screen._new_filter_button)
	buttons.append(screen._detail_back_button)
	buttons.append_array(screen._list_box.get_children())
	for button_value in buttons:
		var button := button_value as Button
		if button == null or button.focus_mode != Control.FOCUS_NONE:
			return false
	return true

func _contains_id(items: Array, id: String) -> bool:
	for item in items:
		if item is Dictionary and String((item as Dictionary).get("id", "")) == id:
			return true
	return false
