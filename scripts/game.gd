extends Node2D

const DataRepositoryScript := preload("res://scripts/systems/data_repository.gd")
const CommentSystemScript := preload("res://scripts/systems/comment_system.gd")
const GiftSystemScript := preload("res://scripts/systems/gift_system.gd")
const WeaponSystemScript := preload("res://scripts/systems/weapon_system.gd")
const EnemySystemScript := preload("res://scripts/systems/enemy_system.gd")
const MarshmallowSystemScript := preload("res://scripts/systems/marshmallow_system.gd")
const GenreEventSystemScript := preload("res://scripts/systems/genre_event_system.gd")
const StreamFrameSystemScript := preload("res://scripts/systems/stream_frame_system.gd")
const DisplayTextSystemScript := preload("res://scripts/systems/display_text_system.gd")
const SettingsSystemScript := preload("res://scripts/systems/settings_system.gd")
const RankingSystemScript := preload("res://scripts/systems/ranking_system.gd")
const CharacterSystemScript := preload("res://scripts/systems/character_system.gd")
const ResultSystemScript := preload("res://scripts/systems/result_system.gd")
const UiStyleSystemScript := preload("res://scripts/systems/ui_style_system.gd")
const HudTextSystemScript := preload("res://scripts/systems/hud_text_system.gd")
const DebugSystemScript := preload("res://scripts/systems/debug_system.gd")
const RunStateSystemScript := preload("res://scripts/systems/run_state_system.gd")
const DrawDataSystemScript := preload("res://scripts/systems/draw_data_system.gd")
const ChatSystemScript := preload("res://scripts/systems/chat_system.gd")
const ChoiceCardSystemScript := preload("res://scripts/systems/choice_card_system.gd")
const ExpSystemScript := preload("res://scripts/systems/exp_system.gd")
const PlayerSystemScript := preload("res://scripts/systems/player_system.gd")
const SpawnerSystemScript := preload("res://scripts/systems/spawner_system.gd")
const DamageSystemScript := preload("res://scripts/systems/damage_system.gd")
const ModifierSystemScript := preload("res://scripts/systems/modifier_system.gd")
const ScoreSystemScript := preload("res://scripts/systems/score_system.gd")
const ARENA := Rect2(Vector2(20, 20), Vector2(1160, 760))
const SIDE := Rect2(Vector2(1210, 110), Vector2(370, 650))
const HUD := Rect2(Vector2(20, 790), Vector2(1560, 90))
const NORMAL_RUN_LENGTH := 180.0
const QUICK_RUN_LENGTH := 60.0
const COMMENT_INTERVAL := 15.0
const CHOICE_TIME := 10.0

var rng := RandomNumberGenerator.new()
var data_repo: DataRepository
var comments: Array = []
var gifts: Array = []
var marshmallow_data: Array = []
var stream_frames: Array = []
var genre_events: Array = []
var characters: Array = []
var weapons: Array = []
var current_stream_frame: Dictionary = {}
var current_character: Dictionary = {}
var current_weapon: Dictionary = {}
var current_stream_frame_id := "zatsudan"
var current_character_id := "ban_chan"
var current_weapon_id := "ban_hammer"
var player_sprite: Texture2D
var selected_character_index := 0
var selected_stream_frame_index := 0
var character_sprite_cache: Dictionary = {}
var offered_comments: Array = []
var offered_gifts: Array = []
var taken_gift_names: Array[String] = []
var ng_cards: Array[bool] = []
var heart_cards: Array[bool] = []
var enemies: Array = []
var next_enemy_uid := 1
var enemy_bullets: Array = []
var exp_orbs: Array = []
var player_bullets: Array = []
var boomerang_hits: Dictionary = {}
var hit_fx: Array = []
var chat_lines: Array[String] = []
var active_effects: Array[String] = []
var active_effect_rates: Dictionary = {}

var state := "title"
var previous_state := "playing"
var quick_test_mode := false
var t_was_down := false
var tutorial_seen := false
var tutorial_input_grace := 0.0
var comment_barrage_setting := 1
var screen_shake_enabled := true
var selected_card := 0
var choice_timer := 0.0
var elapsed := 0.0
var comment_timer := 15.0
var comment_warning_step := 0
var effect_timer := 0.0
var spawn_timer := 0.0
var attack_timer := 0.25
var superchat_timer := 0.4
var chat_timer := 0.0
var marshmallows: Array = []
var next_mallow_time := 30.0

var player_pos := Vector2(580, 570)
var player_vel := Vector2.ZERO
var player_hp := 5
var player_max_hp := 5
var player_speed := 255.0
var player_base_invincible_time := 0.7
var passive_score_rate := 1.0
var passive_maro_good_rate := 1.0
var passive_maro_pickup_rate := 1.0
var dash_cd := 0.0
var invincible := 0.0
var debug_invincible := false

var hammer_damage := 12.0
var hammer_range := 165.0
var hammer_interval := 0.85
var magnet_range := 95.0
var dash_cooldown := 1.2
var knockback_power := 18.0
var like_score_level := 0
var moderator_level := 0
var reentry_barrier_level := 0
var revive_available := false
var flame_marketing := false
var yes_listener := false
var clip_confirmed := false
var exp_vacuum_extreme := false
var exp_vacuum_timer := 0.0
var zero_taunt_resist := false
var comment_boost := false
var choice_time_bonus := 0.0
var choice_time_penalty := 0.0
var sweet_tooth_level := 0
var maro_magnet_range := 0.0
var read_manager_level := 0
var maro_appraisal := false
var block_function_stock := 0
var steel_mental_level := 0
var superchat_level := 0
var boomerang_level := 0
var burn_resist_charges := 0
var clip_bonus_level := 0
var ng_stock := 0
var heart_stock := 0
var heart_used_count := 0

var score := 0
var kills := 0
var exp_level := 1
var exp_value := 0
var gift_hype := 0
var gifts_taken := 0
var multiplier := 1.0
var max_multiplier := 1.0
var burn_combo := 0
var burn_combo_max := 0
var current_comment := "なし"
var current_death_text := "発動中の指示コメなし"
var last_comment_id := ""
var recent_comment_categories: Array[String] = []
var active_comment_hurt := false
var pending_clear_hype := 0
var marshmallow_answered := 0
var marshmallow_unread := 0
var marshmallow_good := 0
var marshmallow_god := 0
var marshmallow_kuso := 0
var last_maro_type := "なし"
var last_maro_was_kuso := false
var last_death_source := "接触"
var last_hammer_dir := Vector2.RIGHT
var stop_timer := 0.0
var mute_timer := 0.0
var effect_walls: Array = []
var effect_pits: Array = []
var danger_comments_chosen := 0
var max_gift_hype := 0
var run_rank := "D"
var debug_key_latch: Dictionary = {}
var toast_text := ""
var toast_timer := 0.0
var kuso_chat_timer := 0.0
var attack_jitter_timer := 0.0
var move_slow_timer := 0.0
var spawn_rate_timer := 0.0
var support_attack_timer := 0.0
var next_genre_event_time := 35.0
var genre_event_timer := 0.0
var active_genre_event := ""
var next_known_genre_event := ""
var genre_event_hurt := false
var genre_race_move_timer := 0.0
var genre_bullet_timer := 0.0
var genre_event_count := 0
var race_event_count := 0
var bullet_hell_event_count := 0
var horror_event_count := 0
var genre_event_clear_count := 0
var strategy_wiki := false
var first_play_adapt := false
var streaming_skill_level := 0
var kusoge_resist_level := 0

var banner_label: Label
var status_label: Label
var choice_box: HBoxContainer
var choice_buttons: Array[Button] = []
var chat_box: VBoxContainer
var result_panel: PanelContainer
var result_label: Label

func _ready() -> void:
	rng.randomize()
	data_repo = DataRepositoryScript.new()
	data_repo.load_all()
	comments = data_repo.comments
	gifts = data_repo.gifts
	marshmallow_data = data_repo.marshmallows
	stream_frames = data_repo.stream_frames
	genre_events = data_repo.genre_events
	characters = data_repo.characters
	weapons = data_repo.weapons
	var selected_frame: Dictionary = StreamFrameSystemScript.selected_frame_state(stream_frames, current_stream_frame_id)
	current_stream_frame = selected_frame["frame"] as Dictionary
	current_stream_frame_id = String(selected_frame["frameId"])
	_select_character(current_character_id)
	_load_settings()
	_build_ui()
	_seed_chat("normal")
	_update_ui()

func _process(delta: float) -> void:
	_update_chat(delta)
	if Input.is_key_pressed(KEY_ESCAPE):
		_toggle_pause()

	if state == "title":
		_update_title_state()
		return

	if state == "character_select":
		_update_character_select()
		_update_ui()
		queue_redraw()
		return

	if state == "stream_frame_select":
		_update_stream_frame_select()
		_update_ui()
		queue_redraw()
		return

	if state == "tutorial":
		_update_tutorial_state(delta)
		return

	if state == "result":
		_update_result_state()
		return

	if state == "pause":
		_update_ui()
		queue_redraw()
		return

	_handle_debug_keys()

	if state == "comment_choice":
		_update_comment_choice(delta)
	elif state == "gift_choice":
		_update_gift_choice()
	else:
		_update_world(delta)

	_update_ui()
	queue_redraw()

func _update_title_state() -> void:
	var t_down: bool = Input.is_key_pressed(KEY_T)
	if t_down and not t_was_down:
		quick_test_mode = not quick_test_mode
	t_was_down = t_down
	if _debug_pressed(KEY_B):
		comment_barrage_setting = SettingsSystemScript.next_comment_barrage(comment_barrage_setting)
		_save_settings()
	if _debug_pressed(KEY_N):
		screen_shake_enabled = SettingsSystemScript.toggled_screen_shake(screen_shake_enabled)
		_save_settings()
	if _debug_pressed(KEY_U):
		tutorial_seen = SettingsSystemScript.reset_tutorial_seen()
		_save_settings()
	if _debug_pressed(KEY_ENTER) or _debug_pressed(KEY_SPACE):
		_start_character_select()
	_update_ui()
	queue_redraw()

func _update_tutorial_state(delta: float) -> void:
	tutorial_input_grace = maxf(0.0, tutorial_input_grace - delta)
	if tutorial_input_grace <= 0.0 and (Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_ESCAPE)):
		state = "playing"
	_update_ui()
	queue_redraw()

func _update_result_state() -> void:
	if Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_SPACE):
		_restart()
	queue_redraw()

func _screen_shake_offset() -> Vector2:
	# Keep the playfield stable; warning effects should live in UI, not camera shake.
	if not screen_shake_enabled:
		return Vector2.ZERO
	return Vector2.ZERO

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(1600, 900)), Color("#11101a"))
	draw_set_transform(_screen_shake_offset(), 0.0, Vector2.ONE)
	_draw_arena()
	_draw_exp()
	_draw_mallow()
	_draw_enemy_bullets()
	_draw_player_bullets()
	_draw_enemies()
	_draw_boomerang()
	_draw_player()
	_draw_hit_fx()
	_draw_frames()
	if state in ["comment_choice", "gift_choice", "pause", "title", "character_select", "stream_frame_select", "tutorial", "result"]:
		draw_rect(ARENA, Color(0, 0, 0, 0.24))
	if state == "title":
		_draw_title_overlay()
	elif state == "character_select":
		_draw_character_select_overlay()
	elif state == "stream_frame_select":
		_draw_stream_frame_select_overlay()
	elif state == "tutorial":
		_draw_tutorial_overlay_v2()
	elif state in ["comment_choice", "gift_choice"]:
		_draw_choice_backplate()
	if _has_effect("comment_storm"):
		_draw_comment_storm()
	if _has_effect("zoom_in"):
		_draw_zoom_mask()
	if active_genre_event == "horror":
		_draw_horror_mask()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if state not in ["title", "character_select", "stream_frame_select", "tutorial", "result"]:
		_draw_comment_countdown()
	_draw_toast()

func _build_ui() -> void:
	var ui := CanvasLayer.new()
	add_child(ui)
	_build_title_ui(ui)
	_build_choice_ui(ui)
	_build_chat_ui(ui)
	_build_status_ui(ui)
	_build_result_ui(ui)

func _build_title_ui(ui: CanvasLayer) -> void:
	var title := Label.new()
	title.position = Vector2(32, 28)
	title.text = "ぜんぶコメントのせいだ"
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", Color.WHITE)
	title.add_theme_color_override("font_shadow_color", Color.BLACK)
	title.add_theme_constant_override("shadow_offset_x", 4)
	title.add_theme_constant_override("shadow_offset_y", 4)
	ui.add_child(title)

	var banner := PanelContainer.new()
	banner.position = Vector2(430, 22)
	banner.size = Vector2(700, 90)
	ui.add_child(banner)
	banner_label = Label.new()
	banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	banner_label.add_theme_font_size_override("font_size", 30)
	banner.add_child(banner_label)

func _build_choice_ui(ui: CanvasLayer) -> void:
	choice_box = HBoxContainer.new()
	choice_box.position = Vector2(455, 150)
	choice_box.add_theme_constant_override("separation", 22)
	choice_box.visible = false
	ui.add_child(choice_box)
	for i in range(3):
		var button := Button.new()
		button.custom_minimum_size = Vector2(240, 315)
		button.focus_mode = Control.FOCUS_NONE
		button.clip_text = true
		button.pressed.connect(_choose_index.bind(i))
		choice_box.add_child(button)
		choice_buttons.append(button)

func _build_chat_ui(ui: CanvasLayer) -> void:
	var comment_title := Label.new()
	comment_title.position = Vector2(1238, 122)
	comment_title.text = "コメント欄"
	comment_title.add_theme_font_size_override("font_size", 28)
	comment_title.add_theme_color_override("font_color", Color("#ba65ff"))
	ui.add_child(comment_title)

	chat_box = VBoxContainer.new()
	chat_box.position = Vector2(1238, 160)
	chat_box.size = Vector2(315, 560)
	chat_box.add_theme_constant_override("separation", 7)
	ui.add_child(chat_box)

func _build_status_ui(ui: CanvasLayer) -> void:
	status_label = Label.new()
	status_label.position = Vector2(705, 866)
	status_label.size = Vector2(820, 24)
	status_label.add_theme_font_size_override("font_size", 14)
	status_label.add_theme_color_override("font_color", Color("#cfc7ff"))
	ui.add_child(status_label)

func _build_result_ui(ui: CanvasLayer) -> void:
	result_panel = PanelContainer.new()
	result_panel.position = Vector2(240, 78)
	result_panel.size = Vector2(1120, 735)
	result_panel.visible = false
	result_panel.add_theme_stylebox_override("panel", UiStyleSystemScript.initial_result_panel_style())
	ui.add_child(result_panel)
	result_label = Label.new()
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	result_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	result_label.add_theme_font_size_override("font_size", 16)
	result_panel.add_child(result_label)

func _update_world(delta: float) -> void:
	elapsed += delta
	if elapsed >= _run_length():
		_finish_run("配信成功！3分間生き残った。")
		return

	if _update_comment_timer(delta):
		return

	if effect_timer > 0.0:
		effect_timer -= delta
		if effect_timer <= 0.0:
			_clear_comment_effects()

	_update_stream_frame_events(delta)
	_update_world_systems(delta)
	_update_ui()

func _update_comment_timer(delta: float) -> bool:
	var result: Dictionary = CommentSystemScript.update_spawn_timer_for_target(self, delta)
	var chats: Array = result["chats"] as Array
	for line in chats:
		_push_chat(String(line))
	if bool(result["shouldStart"]):
		_start_comment_choice()
		return true
	return false

func _update_stream_frame_events(delta: float) -> void:
	if _stream_frame_has_event("marshmallow") and elapsed >= next_mallow_time and marshmallows.size() < 2:
		_spawn_marshmallow()
	if _stream_frame_has_event("game_genre_event"):
		_update_genre_event(delta)

func _update_world_systems(delta: float) -> void:
	_update_player(delta)
	_update_stage_hazards()
	_update_spawning(delta)
	_update_enemies(delta)
	_update_bullets(delta)
	_update_weapons(delta)
	_update_exp(delta)
	_update_exp_vacuum(delta)
	_update_marshmallow(delta)
	_update_marshmallow_effects(delta)
	_update_hit_fx(delta)

func _run_length() -> float:
	return QUICK_RUN_LENGTH if quick_test_mode else NORMAL_RUN_LENGTH

func _update_genre_event(delta: float) -> void:
	if active_genre_event == "":
		if strategy_wiki and next_known_genre_event == "":
			next_known_genre_event = _roll_genre_event()
		if elapsed >= next_genre_event_time:
			var event_id: String = next_known_genre_event if next_known_genre_event != "" else _roll_genre_event()
			next_known_genre_event = ""
			_start_genre_event(event_id)
		return
	genre_event_timer -= delta
	if active_genre_event == "race":
		if player_vel.length() > 80.0:
			genre_race_move_timer += delta
			if genre_race_move_timer >= 2.0:
				genre_race_move_timer = 0.0
				score += ScoreSystemScript.race_bonus(100, streaming_skill_level)
				_push_chat("レースボーナス +100")
		else:
			genre_race_move_timer = 0.0
	elif active_genre_event == "bullet_hell":
		genre_bullet_timer -= delta
		if genre_bullet_timer <= 0.0:
			var interval: float = 0.42 + 0.08 * float(kusoge_resist_level)
			genre_bullet_timer = interval
			_spawn_genre_bullet()
	if genre_event_timer <= 0.0:
		_finish_genre_event()

func _roll_genre_event() -> String:
	return GenreEventSystemScript.roll_event(genre_events, rng)

func _start_genre_event(event_id: String) -> void:
	if not _stream_frame_has_event("game_genre_event"):
		return
	active_genre_event = event_id
	genre_event_timer = 12.0
	genre_event_hurt = false
	genre_race_move_timer = 0.0
	genre_bullet_timer = 0.25
	genre_event_count += 1
	if first_play_adapt:
		invincible = maxf(invincible, 1.5)
	if event_id == "race":
		race_event_count += 1
	elif event_id == "bullet_hell":
		bullet_hell_event_count += 1
	elif event_id == "horror":
		horror_event_count += 1
		_spawn_horror_ghosts()
	var text_data: Dictionary = GenreEventSystemScript.start_text(event_id)
	_show_toast(String(text_data["toast"]))
	_push_chat(String(text_data["chat"]))

func _finish_genre_event() -> void:
	if active_genre_event == "bullet_hell" and not genre_event_hurt:
		gift_hype = clampi(gift_hype + 10, 0, 100)
		max_gift_hype = maxi(max_gift_hype, gift_hype)
	if not genre_event_hurt:
		genre_event_clear_count += 1
	active_genre_event = ""
	next_genre_event_time = GenreEventSystemScript.next_event_time(elapsed, rng)
	if strategy_wiki:
		next_known_genre_event = _roll_genre_event()

func _maybe_trigger_genre_comment(comment_id: String) -> void:
	if not _stream_frame_has_event("game_genre_event"):
		return
	var event_id: String = GenreEventSystemScript.event_from_comment(comment_id, genre_events, rng)
	if event_id != "":
		_start_genre_event(event_id)

func _spawn_genre_bullet() -> void:
	enemy_bullets.append(GenreEventSystemScript.make_bullet(ARENA, player_pos, rng))

func _spawn_horror_ghosts() -> void:
	var count: int = 1 if kusoge_resist_level > 0 else 2
	var positions: Array = GenreEventSystemScript.horror_positions(ARENA, player_pos, count, rng)
	for item in positions:
		var pos: Vector2 = item
		_spawn_enemy_at("ghost_comment", pos)

func _genre_event_label(event_id: String) -> String:
	return GenreEventSystemScript.label(event_id)

func _load_settings() -> void:
	var data: Dictionary = SettingsSystemScript.load_settings()
	if data.is_empty():
		return
	var settings: Dictionary = SettingsSystemScript.normalized_settings(data)
	tutorial_seen = bool(settings["tutorialSeen"])
	comment_barrage_setting = int(settings["commentBarrage"])
	screen_shake_enabled = bool(settings["screenShake"])
func _save_settings() -> void:
	SettingsSystemScript.save_settings(SettingsSystemScript.build_save_data(tutorial_seen, comment_barrage_setting, screen_shake_enabled))
func _comment_barrage_label() -> String:
	return DisplayTextSystemScript.comment_barrage_label(comment_barrage_setting)
func _start_character_select() -> void:
	state = "character_select"
	choice_box.visible = false
	result_panel.visible = false
	if characters.is_empty():
		current_character_id = "ban_chan"
		_restart()
		return
	selected_character_index = CharacterSystemScript.selected_index(characters, current_character_id)
	_push_chat("今日の配信者を選べ")

func _update_character_select() -> void:
	var action: Dictionary = DebugSystemScript.selection_action(debug_key_latch, selected_character_index, characters.size(), 3)
	var kind: String = String(action["kind"])
	if kind == "escape":
		state = "title"
		return
	if kind == "move":
		selected_character_index = int(action["index"])
	elif kind == "select":
		_select_character_index_and_start(int(action["index"]))

func _select_character_index_and_start(index: int) -> void:
	if index < 0 or index >= characters.size():
		return
	var character: Dictionary = characters[index] as Dictionary
	current_character_id = String(character.get("id", "ban_chan"))
	_start_stream_frame_select()

func _start_stream_frame_select() -> void:
	state = "stream_frame_select"
	choice_box.visible = false
	result_panel.visible = false
	if stream_frames.is_empty():
		var fallback: Dictionary = StreamFrameSystemScript.selected_frame_state(stream_frames, current_stream_frame_id)
		current_stream_frame = fallback["frame"] as Dictionary
		current_stream_frame_id = String(fallback["frameId"])
		_restart()
		return
	selected_stream_frame_index = StreamFrameSystemScript.selected_index(stream_frames, current_stream_frame_id)
	_push_chat("今日の配信枠を選べ")

func _update_stream_frame_select() -> void:
	var action: Dictionary = DebugSystemScript.selection_action(debug_key_latch, selected_stream_frame_index, stream_frames.size(), 2)
	var kind: String = String(action["kind"])
	if kind == "escape":
		_start_character_select()
		return
	if kind == "move":
		selected_stream_frame_index = int(action["index"])
	elif kind == "select":
		_select_stream_frame_index_and_start(int(action["index"]))

func _select_stream_frame_index_and_start(index: int) -> void:
	var selected: Dictionary = StreamFrameSystemScript.selected_frame_state_by_index(stream_frames, index)
	if selected.is_empty():
		return
	current_stream_frame = selected["frame"] as Dictionary
	current_stream_frame_id = String(selected["frameId"])
	_restart()

func _stream_frame_has_event(event_id: String) -> bool:
	return StreamFrameSystemScript.has_event(current_stream_frame, event_id)

func _data_allowed_for_stream_frame(data: Dictionary, tag_key: String) -> bool:
	return StreamFrameSystemScript.data_allowed(current_stream_frame, data, tag_key)

func _select_character(id: String) -> void:
	var selected: Dictionary = CharacterSystemScript.selected_character_state(characters, weapons, id, character_sprite_cache)
	current_character = selected["character"] as Dictionary
	current_character_id = String(selected["characterId"])
	current_weapon_id = String(selected["weaponId"])
	current_weapon = selected["weapon"] as Dictionary
	player_sprite = selected["sprite"] as Texture2D

func _character_texture(sprite_path: String) -> Texture2D:
	return CharacterSystemScript.texture_from_cache(character_sprite_cache, sprite_path)

func _weapon_data(id: String) -> Dictionary:
	return WeaponSystemScript.find_weapon(weapons, id, CharacterSystemScript.fallback_weapon())

func _character_base_stats() -> Dictionary:
	return CharacterSystemScript.base_stats(current_character)

func _character_initial_resources() -> Dictionary:
	return CharacterSystemScript.initial_resources(current_character)

func _character_passive() -> Dictionary:
	return CharacterSystemScript.passive(current_character)

func _weapon_attack_type() -> String:
	return WeaponSystemScript.attack_type(current_weapon)

func _weapon_attack_interval(default_value: float = 0.85) -> float:
	return WeaponSystemScript.attack_interval(current_weapon, default_value)

func _scaled_move_speed(value: float) -> float:
	return WeaponSystemScript.scaled_move_speed(value)

func _scaled_range(value: float, scale: float = 82.5) -> float:
	return WeaponSystemScript.scaled_range(value, scale)

func _scaled_projectile_speed(value: float) -> float:
	return WeaponSystemScript.scaled_projectile_speed(value)

func _scaled_knockback(value: float) -> float:
	return WeaponSystemScript.scaled_knockback(value)

func _weapon_range_base() -> float:
	return WeaponSystemScript.range_base(current_weapon)

func _update_player(delta: float) -> void:
	var input := PlayerSystemScript.input_vector()
	if input.length() < 0.1:
		stop_timer += delta
	else:
		stop_timer = 0.0
	if _has_effect("keep_moving") and stop_timer >= 1.0:
		stop_timer = 0.0
		_damage_player("stopped moving")
	var reverse_power: float = maxf(_effect_rate("reverse_control"), _effect_rate("takeback"))
	input = PlayerSystemScript.adjusted_input(input, reverse_power, elapsed)

	var slide_power: float = maxf(_effect_rate("banana_floor"), maxf(_effect_rate("no_brake"), _effect_rate("takeback")))
	var friction: float = PlayerSystemScript.friction(slide_power, active_genre_event, kusoge_resist_level)
	var speed_rate: float = PlayerSystemScript.speed_rate(move_slow_timer, active_genre_event)
	player_vel = player_vel.lerp(input * player_speed * speed_rate, minf(1.0, delta * friction))

	dash_cd = maxf(0.0, dash_cd - delta)
	invincible = maxf(0.0, invincible - delta)
	var no_dash_power: float = _effect_rate("no_dash")
	if Input.is_key_pressed(KEY_SPACE) and PlayerSystemScript.can_dash(no_dash_power, dash_cd):
		var dash_dir := input
		if dash_dir == Vector2.ZERO:
			dash_dir = Vector2.RIGHT
		player_vel += dash_dir * 620.0
		dash_cd = dash_cooldown * PlayerSystemScript.dash_cooldown_rate(no_dash_power)

	player_pos += player_vel * delta
	player_pos.x = clampf(player_pos.x, ARENA.position.x + 28.0, ARENA.end.x - 28.0)
	player_pos.y = clampf(player_pos.y, ARENA.position.y + 28.0, ARENA.end.y - 28.0)

func _update_spawning(delta: float) -> void:
	var result: Dictionary = SpawnerSystemScript.spawn_step({
		"spawnTimer": spawn_timer,
		"delta": delta,
		"baseInterval": _spawn_interval(),
		"marshmallowCount": marshmallows.size(),
		"moreSpawns": _has_effect("more_spawns"),
		"moreSpawnsPower": _effect_rate("more_spawns"),
		"godReservation": _has_effect("god_reservation"),
		"godReservationPower": _effect_rate("god_reservation"),
		"flameMarketing": flame_marketing,
		"spawnRateTimer": spawn_rate_timer
	})
	spawn_timer = float(result["spawnTimer"])
	var count: int = int(result["spawnCount"])
	if count <= 0:
		return
	for i in range(count):
		_spawn_enemy(_pick_wave_enemy())

func _spawn_interval() -> float:
	return EnemySystemScript.spawn_interval({"elapsed": elapsed, "quickTestMode": quick_test_mode})

func _pick_wave_enemy() -> String:
	return EnemySystemScript.pick_wave_enemy(elapsed, quick_test_mode, rng)

func _spawn_enemy(kind: String) -> void:
	var giant_power: float = _effect_rate("giant_enemies") if _has_effect("giant_enemies") else 0.0
	enemies.append(EnemySystemScript.build_enemy(kind, EnemySystemScript.spawn_position(ARENA, rng), next_enemy_uid, rng.randf_range(0.6, 1.4), giant_power))
	next_enemy_uid += 1

func _enemy_data(kind: String) -> Dictionary:
	return EnemySystemScript.enemy_data(kind)

func _enemy_display_name(kind: String) -> String:
	return DisplayTextSystemScript.enemy_display_name(kind)

func _update_enemies(delta: float) -> void:
	var result: Dictionary = EnemySystemScript.update_enemies({
		"delta": delta,
		"rng": rng,
		"enemies": enemies,
		"bullets": enemy_bullets,
		"playerPos": player_pos,
		"arena": ARENA,
		"enemySpeedRate": _effect_rate("enemy_speed"),
		"godReservation": _has_effect("god_reservation"),
		"godReservationRate": _effect_rate("god_reservation")
	})
	enemy_bullets = result["bullets"] as Array
	_apply_enemy_damage_events(result)

func _update_enemy_bullets(delta: float) -> void:
	var result: Dictionary = EnemySystemScript.update_enemy_bullets({
		"delta": delta,
		"bullets": enemy_bullets,
		"playerPos": player_pos,
		"arena": ARENA,
		"bulletHell": active_genre_event == "bullet_hell"
	})
	enemy_bullets = result["bullets"] as Array
	_apply_enemy_damage_events(result)

func _update_bullets(delta: float) -> void:
	_update_enemy_bullets(delta)
	_update_player_bullets(delta)

func _update_weapons(delta: float) -> void:
	_update_hammer(delta)
	_update_boomerang()

func _apply_enemy_damage_events(result: Dictionary) -> void:
	var damage_events: Array = result.get("damageEvents", []) as Array
	for item in damage_events:
		var event: Dictionary = item
		_damage_player(String(event.get("source", "enemy")))

func _damage_source_display(source: String) -> String:
	return DisplayTextSystemScript.damage_source_display(source)

func _update_hammer(delta: float) -> void:
	var result: Dictionary = WeaponSystemScript.update_hammer({
		"delta": delta,
		"rng": rng,
		"weaponType": _weapon_attack_type(),
		"attackTimer": attack_timer,
		"muteTimer": mute_timer,
		"lastDir": last_hammer_dir,
		"supportAttack": support_attack_timer > 0.0,
		"weaponMute": _has_effect("weapon_mute"),
		"weaponMuteRate": _effect_rate("weapon_mute"),
		"takeback": _has_effect("takeback"),
		"attackRightOnly": _has_effect("attack_right_only"),
		"attackRightOnlyRate": _effect_rate("attack_right_only"),
		"attackJitter": attack_jitter_timer > 0.0,
		"shortRange": _has_effect("short_range"),
		"playerPos": player_pos,
		"enemies": enemies,
		"damage": hammer_damage,
		"range": hammer_range,
		"interval": hammer_interval,
		"knockback": knockback_power
	})
	attack_timer = float(result["attackTimer"])
	mute_timer = float(result["muteTimer"])
	last_hammer_dir = Vector2(result["lastDir"])
	_apply_weapon_result(result)
	enemies = enemies.filter(func(e): return float(e["hp"]) > 0.0)

func _update_player_bullets(delta: float) -> void:
	var result: Dictionary = WeaponSystemScript.update_projectiles({
		"delta": delta,
		"weapon": current_weapon,
		"weaponType": _weapon_attack_type(),
		"superchatLevel": superchat_level,
		"superchatTimer": superchat_timer,
		"interval": hammer_interval,
		"range": hammer_range,
		"damage": hammer_damage,
		"playerPos": player_pos,
		"enemies": enemies,
		"bullets": player_bullets,
		"arena": ARENA
	})
	superchat_timer = float(result["superchatTimer"])
	player_bullets = result["bullets"] as Array
	_apply_weapon_result(result)
	enemies = enemies.filter(func(e): return float(e["hp"]) > 0.0)

func _update_boomerang() -> void:
	var result: Dictionary = WeaponSystemScript.update_boomerang({
		"weapon": current_weapon,
		"weaponType": _weapon_attack_type(),
		"boomerangLevel": boomerang_level,
		"elapsed": elapsed,
		"playerPos": player_pos,
		"enemies": enemies,
		"boomerangHits": boomerang_hits,
		"range": hammer_range,
		"damage": hammer_damage,
		"knockback": knockback_power
	})
	boomerang_hits = result["boomerangHits"] as Dictionary
	_apply_weapon_result(result)
	enemies = enemies.filter(func(e): return float(e["hp"]) > 0.0)

func _apply_weapon_result(result: Dictionary) -> void:
	var killed: Array = result.get("killed", []) as Array
	for item in killed:
		var enemy: Dictionary = item
		_kill_enemy(enemy)
	var effects: Array = result.get("hitFx", []) as Array
	for item in effects:
		hit_fx.append(item)
	var chats: Array = result.get("chat", []) as Array
	for item in chats:
		_push_chat(String(item))

func _kill_enemy(enemy: Dictionary) -> void:
	kills += 1
	score += ScoreSystemScript.enemy_score_for_target(self, enemy)
	ExpSystemScript.drop_from_enemy_for_target(self, enemy)
	var events: Dictionary = EnemySystemScript.kill_events(enemy, _has_effect("split_enemy"), rng)
	var splits: Array = events["splits"] as Array
	for pos in splits:
		_spawn_enemy_at("troll", pos)
	var chat: String = String(events["chat"])
	if chat != "":
		_push_chat(chat)
func _update_exp(delta: float) -> void:
	var result: Dictionary = ExpSystemScript.update_orbs_for_target(self, delta)
	if bool(result["levelUp"]):
		_start_gift_choice()

func _update_exp_vacuum(delta: float) -> void:
	ExpSystemScript.update_vacuum_for_target(self, delta)

func _add_exp(amount: int) -> void:
	if ExpSystemScript.add_exp_to_target(self, amount):
		_start_gift_choice()

func _current_exp_need() -> int:
	return ExpSystemScript.current_need(exp_level)

func _damage_player(source: String) -> void:
	if invincible > 0.0 or debug_invincible:
		return
	var source_text: String = _damage_source_display(source)
	last_death_source = source_text
	var result: Dictionary = DamageSystemScript.apply_hit_to_target(self)
	if bool(result["revived"]):
		_push_chat("低評価回避！HP1で復帰")
		return
	if player_hp <= 0:
		_finish_run(DamageSystemScript.death_reason(current_comment, current_death_text, source_text))
func _start_comment_choice() -> void:
	CommentSystemScript.start_choice_for_target(self, comments, rng, CHOICE_TIME)
	choice_box.visible = true
	banner_label.text = "指示コメが来た！10秒以内にひとつ選べ！"
	_push_chat("指示コメが来た！")
	_refresh_choice_cards()
func _update_comment_choice(delta: float) -> void:
	var timer_result: Dictionary = CommentSystemScript.update_choice_timer_for_target(self, delta)
	var timer_chats: Array = timer_result["chats"] as Array
	for line in timer_chats:
		_push_chat(String(line))
	if Input.is_key_pressed(KEY_LEFT):
		selected_card = maxi(0, selected_card - 1)
		_refresh_choice_cards()
	elif Input.is_key_pressed(KEY_RIGHT):
		selected_card = mini(2, selected_card + 1)
		_refresh_choice_cards()
	elif Input.is_key_pressed(KEY_Q):
		_use_ng()
	elif Input.is_key_pressed(KEY_H):
		_use_heart()
	elif Input.is_key_pressed(KEY_1):
		_choose_comment(0)
	elif Input.is_key_pressed(KEY_2):
		_choose_comment(1)
	elif Input.is_key_pressed(KEY_3):
		_choose_comment(2)
	elif Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_SPACE):
		_choose_comment(selected_card)
	elif bool(timer_result["timedOut"]):
		_push_chat("指示コメに押し切られた！")
		_choose_comment(_highest_multiplier_card())
func _use_ng() -> void:
	var result: Dictionary = CommentSystemScript.use_ng_for_target(self)
	if bool(result["changed"]):
		_push_chat(String(result["chat"]))
		_refresh_choice_cards()
func _use_heart() -> void:
	var result: Dictionary = CommentSystemScript.use_heart_for_target(self, rng)
	if bool(result["changed"]):
		_push_chat(String(result["chat"]))
		_refresh_choice_cards()
func _choose_comment(index: int) -> void:
	if index < 0 or index >= offered_comments.size():
		return
	if index < ng_cards.size() and ng_cards[index]:
		return
	var c: Dictionary = offered_comments[index]
	var has_heart: bool = index < heart_cards.size() and heart_cards[index]
	var view: Dictionary = _comment_view(c, has_heart)
	var result: Dictionary = ModifierSystemScript.start_comment_for_target(self, c, view, has_heart, rng)
	_maybe_trigger_genre_comment(String(result["commentId"]))
	_setup_stage_effects()
	_finish_comment_choice()

func _finish_comment_choice() -> void:
	comment_timer = COMMENT_INTERVAL
	comment_warning_step = 0
	state = "playing"
	choice_box.visible = false
	heart_cards.clear()
	_push_chat(current_comment + " を選択")

func _clear_comment_effects() -> void:
	var clear_state: Dictionary = ModifierSystemScript.clear_state_for_target(self)
	if bool(clear_state["clearBonus"]):
		_push_chat("指示コメ完走ボーナス！")

func _has_effect(id: String) -> bool:
	return ModifierSystemScript.has_effect(active_effects, id)

func _effect_rate(id: String) -> float:
	return ModifierSystemScript.effect_rate(active_effects, active_effect_rates, id)

func _comment_offer() -> Array:
	return CommentSystemScript.build_offer_for_target(self, comments, rng)

func _comment_view(comment: Dictionary, has_heart: bool) -> Dictionary:
	return CommentSystemScript.comment_view(comment, has_heart)

func _highest_multiplier_card() -> int:
	return CommentSystemScript.highest_multiplier_card(offered_comments, ng_cards, heart_cards)

func _setup_stage_effects() -> void:
	effect_walls.clear()
	effect_pits.clear()
	if _has_effect("random_walls"):
		for i in range(4):
			var p := Vector2(rng.randf_range(ARENA.position.x + 120, ARENA.end.x - 180), rng.randf_range(ARENA.position.y + 110, ARENA.end.y - 120))
			effect_walls.append(Rect2(p, Vector2(rng.randf_range(70, 140), 28)))
	if _has_effect("damage_pits"):
		for i in range(7):
			var p := Vector2(rng.randf_range(ARENA.position.x + 80, ARENA.end.x - 80), rng.randf_range(ARENA.position.y + 80, ARENA.end.y - 80))
			effect_pits.append({"pos": p, "radius": rng.randf_range(24, 42)})

func _update_stage_hazards() -> void:
	for wall in effect_walls:
		var rect: Rect2 = wall
		if rect.has_point(player_pos):
			player_pos = player_pos.move_toward(ARENA.get_center(), -8.0)
	for pit in effect_pits:
		if player_pos.distance_to(Vector2(pit["pos"])) < float(pit["radius"]) + 16.0:
			_damage_player("ダメージ床")

func _start_gift_choice() -> void:
	state = "gift_choice"
	selected_card = 0
	offered_gifts = _build_gift_offer()
	choice_box.visible = true
	_push_chat(_gift_arrival_text())
	_refresh_choice_cards()

func _gift_arrival_text() -> String:
	return GiftSystemScript.arrival_text(gift_hype)

func _build_gift_offer() -> Array:
	var gift_time: float = elapsed * (3.0 if quick_test_mode else 1.0)
	var context: Dictionary = GiftSystemScript.build_offer_context_for_target(self, gifts, gift_time, rng)
	return GiftSystemScript.build_offer(context)

func _gift_level(id: String) -> int:
	return GiftSystemScript.gift_level_for_target(self, id)

func _update_gift_choice() -> void:
	if Input.is_key_pressed(KEY_LEFT):
		selected_card = maxi(0, selected_card - 1)
		_refresh_choice_cards()
	elif Input.is_key_pressed(KEY_RIGHT):
		selected_card = mini(2, selected_card + 1)
		_refresh_choice_cards()
	elif Input.is_key_pressed(KEY_1):
		_choose_gift(0)
	elif Input.is_key_pressed(KEY_2):
		_choose_gift(1)
	elif Input.is_key_pressed(KEY_3):
		_choose_gift(2)
	elif Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_SPACE):
		_choose_gift(selected_card)

func _choose_gift(index: int) -> void:
	if index < 0 or index >= offered_gifts.size():
		return
	var gift: Dictionary = offered_gifts[index]
	var result: Dictionary = GiftSystemScript.choose_gift_for_target(self, gift)
	if bool(result.get("rollGenreEvent", false)):
		next_known_genre_event = _roll_genre_event()
	state = "playing"
	choice_box.visible = false
	_push_chat(String(gift["displayName"]) + " を取得")

func _spawn_marshmallow() -> void:
	var data: Dictionary = MarshmallowSystemScript.pick_data_for_target(self, marshmallow_data, rng)
	_spawn_marshmallow_with_data(data)

func _spawn_marshmallow_with_data(data: Dictionary) -> void:
	if MarshmallowSystemScript.spawn_pickup_for_target(self, data, rng, ARENA, effect_walls):
		_push_chat("マシュマロが届いた！")

func _spawn_marshmallow_for_debug(kind: String) -> void:
	var data: Dictionary = MarshmallowSystemScript.pick_debug_data(marshmallow_data, kind, rng)
	if data.is_empty():
		return
	_spawn_marshmallow_with_data(data)

func _update_marshmallow(delta: float) -> void:
	var result: Dictionary = MarshmallowSystemScript.update_pickups_for_target(self, delta)
	var picked: Array = result["picked"] as Array
	for item in picked:
		_apply_marshmallow(item as Dictionary)
	var expired: Array = result["expired"] as Array
	for item in expired:
		var m: Dictionary = item as Dictionary
		_spawn_enemy_at("unread_maro", Vector2(m["pos"]))
		_push_chat("未読マロが荒らし化！")
		_push_maro_chat("unread")

func _update_marshmallow_effects(delta: float) -> void:
	MarshmallowSystemScript.update_effect_timers_for_target(self, delta)

func _apply_marshmallow(item: Dictionary) -> void:
	var data: Dictionary = item["data"]
	if data.is_empty():
		return
	var result: Dictionary = MarshmallowSystemScript.apply_pickup_to_target(self, data)
	var feedback: Dictionary = MarshmallowSystemScript.pickup_feedback(data, result)
	if String(feedback["maroChatKind"]) != "":
		_push_maro_chat(String(feedback["maroChatKind"]))
	for i in range(int(feedback["spawnTrolls"])):
		_spawn_enemy("troll")
	if int(feedback["expAdd"]) > 0:
		_add_exp(int(feedback["expAdd"]))
	_show_toast(String(feedback["toast"]))
	_push_chat(String(feedback["chat"]))

func _show_toast(text: String) -> void:
	toast_text = text
	toast_timer = 1.4

func _push_maro_chat(kind: String) -> void:
	_push_chat(ChatSystemScript.random_marshmallow_line(kind, rng))
func _spawn_enemy_at(kind: String, pos: Vector2) -> void:
	enemies.append(EnemySystemScript.build_enemy(kind, pos, next_enemy_uid, 1.0))
	next_enemy_uid += 1

func _choose_index(index: int) -> void:
	if state == "comment_choice":
		_choose_comment(index)
	elif state == "gift_choice":
		_choose_gift(index)

func _refresh_choice_cards() -> void:
	for i in range(choice_buttons.size()):
		var button: Button = choice_buttons[i]
		button.add_theme_font_size_override("font_size", 21)
		var card: Dictionary = ChoiceCardSystemScript.hidden_card()
		if state == "comment_choice":
			if i >= offered_comments.size():
				button.text = String(card["text"])
				continue
			if i < ng_cards.size() and ng_cards[i]:
				card = ChoiceCardSystemScript.ng_card(i)
				_style_choice_button(button, card["fill"] as Color, card["border"] as Color, i == selected_card)
				button.text = String(card["text"])
				continue
			var c: Dictionary = offered_comments[i]
			var has_heart: bool = i < heart_cards.size() and heart_cards[i]
			var view: Dictionary = _comment_view(c, has_heart)
			card = ChoiceCardSystemScript.comment_card(i, view, has_heart, choice_timer, elapsed)
			_style_choice_button(button, card["fill"] as Color, card["border"] as Color, i == selected_card)
			button.text = String(card["text"])
		elif state == "gift_choice":
			if i >= offered_gifts.size():
				button.text = String(card["text"])
				continue
			var g: Dictionary = offered_gifts[i]
			card = ChoiceCardSystemScript.gift_card(i, g, _gift_level(String(g["id"])))
			_style_choice_button(button, card["fill"] as Color, card["border"] as Color, i == selected_card)
			button.text = String(card["text"])
func _style_choice_button(button: Button, fill: Color, border: Color, selected: bool) -> void:
	UiStyleSystemScript.apply_choice_button(button, fill, border, selected)

func _rarity_label(rarity: String) -> String:
	return DisplayTextSystemScript.rarity_label(rarity)
func _rarity_color(rarity: String) -> Color:
	return DisplayTextSystemScript.rarity_color(rarity)

func _update_ui() -> void:
	var effect_text: String = "%02d" % int(ceil(maxf(0.0, effect_timer)))
	var need: int = _current_exp_need()
	status_label.text = HudTextSystemScript.status_text({
		"score": score,
		"expValue": exp_value,
		"expNeed": need,
		"effectText": effect_text,
		"characterName": String(current_character.get("displayName", "バンちゃん")),
		"streamFrameName": String(current_stream_frame.get("displayName", "雑談枠")),
		"weaponName": String(current_weapon.get("displayName", "BANハンマー"))
	})
	banner_label.text = HudTextSystemScript.banner_text({
		"state": state,
		"quickTestMode": quick_test_mode,
		"commentBarrageLabel": _comment_barrage_label(),
		"screenShakeEnabled": screen_shake_enabled,
		"choiceTimer": choice_timer,
		"ngStock": ng_stock,
		"heartStock": heart_stock,
		"giftArrivalText": _gift_arrival_text(),
		"activeGenreEvent": active_genre_event,
		"activeGenreLabel": _genre_event_label(active_genre_event),
		"genreEventTimer": genre_event_timer,
		"strategyWiki": strategy_wiki,
		"nextKnownGenreEvent": next_known_genre_event,
		"nextKnownGenreLabel": _genre_event_label(next_known_genre_event),
		"commentTimer": comment_timer
	})
func _finish_run(reason: String) -> void:
	if state == "result":
		return
	state = "result"
	choice_box.visible = false
	heart_cards.clear()
	result_panel.visible = true
	var result_stats: Dictionary = ResultSystemScript.complete_run_stats(ResultSystemScript.build_run_stats_from_target(reason, self))
	run_rank = String(result_stats["rank"])
	_style_result_panel(run_rank)
	result_stats["rankingText"] = RankingSystemScript.save_and_format_ranking(ResultSystemScript.build_ranking_entry(result_stats), quick_test_mode)
	result_label.text = ResultSystemScript.build_result_text(result_stats)
	_seed_chat("death")

func _style_result_panel(rank: String) -> void:
	result_panel.add_theme_stylebox_override("panel", UiStyleSystemScript.result_panel_style(rank))

func _restart() -> void:
	_select_character(current_character_id)
	var stats: Dictionary = _character_base_stats()
	var resources: Dictionary = _character_initial_resources()
	var initial: Dictionary = RunStateSystemScript.initial_values(current_character, current_weapon, stats, resources)
	RunStateSystemScript.apply_initial_values(self, initial)
	var gift_defaults: Dictionary = RunStateSystemScript.gift_flags()
	RunStateSystemScript.apply_gift_flags(self, gift_defaults)
	_clear_run_collections()
	var timer_defaults: Dictionary = RunStateSystemScript.timers()
	RunStateSystemScript.apply_timers(self, timer_defaults)
	marshmallows.clear()
	var score_defaults: Dictionary = RunStateSystemScript.score_state(int(initial["giftHype"]))
	RunStateSystemScript.apply_score_state(self, score_defaults)
	var maro_defaults: Dictionary = RunStateSystemScript.marshmallow_state()
	RunStateSystemScript.apply_marshmallow_state(self, maro_defaults)
	last_death_source = "接触"
	last_hammer_dir = Vector2.RIGHT
	_clear_stage_effect_collections()
	var genre_defaults: Dictionary = RunStateSystemScript.genre_state()
	RunStateSystemScript.apply_genre_state(self, genre_defaults)
	_apply_character_passive()
	if not tutorial_seen:
		tutorial_seen = true
		tutorial_input_grace = 0.25
		_save_settings()
		state = "tutorial"
	else:
		tutorial_input_grace = 0.0
		state = "playing"
	_reset_run_ui()

func _clear_run_collections() -> void:
	RunStateSystemScript.clear_run_collections(self)

func _clear_stage_effect_collections() -> void:
	RunStateSystemScript.clear_stage_effect_collections(self)

func _reset_run_ui() -> void:
	RunStateSystemScript.reset_run_ui(result_panel, choice_box, heart_cards, chat_lines)
	_seed_chat("normal")

func _toggle_pause() -> void:
	if state == "pause":
		state = previous_state
	elif state == "playing":
		previous_state = state
		state = "pause"

func _apply_character_passive() -> void:
	var values: Dictionary = CharacterSystemScript.apply_passive_values(current_character, {
		"playerBaseInvincibleTime": player_base_invincible_time,
		"passiveScoreRate": passive_score_rate,
		"passiveMaroGoodRate": passive_maro_good_rate,
		"passiveMaroPickupRate": passive_maro_pickup_rate
	})
	player_base_invincible_time = float(values["playerBaseInvincibleTime"])
	passive_score_rate = float(values["passiveScoreRate"])
	passive_maro_good_rate = float(values["passiveMaroGoodRate"])
	passive_maro_pickup_rate = float(values["passiveMaroPickupRate"])

func _handle_debug_keys() -> void:
	for action in DebugSystemScript.pressed_actions(debug_key_latch):
		_apply_debug_action(action)

func _apply_debug_action(action: String) -> void:
	if DebugSystemScript.should_start_comment(action) and state == "playing":
		comment_timer = 0.0
	if DebugSystemScript.should_start_gift(action) and state == "playing":
		_start_gift_choice()
	var forced_gift_rarity: String = DebugSystemScript.forced_gift_rarity(action)
	if forced_gift_rarity != "" and state == "playing":
		_force_gift_choice_by_rarity(forced_gift_rarity)
	_apply_debug_resource_action(action)
	_apply_debug_world_action(action)
	var forced_comment_id: String = DebugSystemScript.forced_comment_id(action)
	if forced_comment_id != "" and state == "playing":
		_force_comment_by_id(forced_comment_id)
	var forced_heart_id: String = DebugSystemScript.forced_heart_comment_id(action)
	if forced_heart_id != "" and state == "playing":
		_force_heart_comment_by_id(forced_heart_id)
	var jump: float = DebugSystemScript.jump_time(action, quick_test_mode)
	if jump >= 0.0:
		elapsed = jump
	var marshmallow_kind: String = DebugSystemScript.marshmallow_kind(action)
	if marshmallow_kind != "" and state == "playing":
		_spawn_marshmallow_for_debug(marshmallow_kind)
	if DebugSystemScript.should_expire_marshmallows(action) and state == "playing":
		for item in marshmallows:
			item["time"] = 0.0
	var spawn_enemy_kind: String = DebugSystemScript.spawn_enemy_kind(action)
	if spawn_enemy_kind != "" and state == "playing":
		_spawn_enemy(spawn_enemy_kind)
	_apply_debug_cleanup_action(action)

func _apply_debug_resource_action(action: String) -> void:
	if action == "heart":
		if state == "comment_choice":
			_use_heart()
		else:
			heart_stock = DebugSystemScript.heart_stock_value(action, heart_stock)
			_push_chat("♡ +1")
	var hype_value: int = DebugSystemScript.hype_value(action)
	if hype_value >= 0:
		gift_hype = hype_value
		max_gift_hype = maxi(max_gift_hype, gift_hype)
	var debug_heart_value: int = DebugSystemScript.heart_stock_value(action, heart_stock)
	if action == "heart_max":
		heart_stock = debug_heart_value
		_push_chat("♡ MAX")

func _apply_debug_world_action(action: String) -> void:
	if DebugSystemScript.should_clear_enemies(action):
		enemies.clear()
	if DebugSystemScript.should_toggle_invincible(action):
		debug_invincible = not debug_invincible

func _apply_debug_cleanup_action(action: String) -> void:
	if DebugSystemScript.should_clear_effects(action):
		active_effects.clear()
		active_effect_rates.clear()
		effect_walls.clear()
		effect_pits.clear()
	if DebugSystemScript.should_reset_ranking(action):
		RankingSystemScript.save_rankings([])
		_push_chat("ランキングをリセットしました")

func _force_comment_by_id(id: String) -> void:
	_apply_forced_comment_offer(CommentSystemScript.build_forced_offer(comments, id, false))

func _force_heart_comment_by_id(id: String) -> void:
	_apply_forced_comment_offer(CommentSystemScript.build_forced_offer(comments, id, true))

func _apply_forced_comment_offer(offer: Dictionary) -> void:
	if offer.is_empty():
		return
	offered_comments = offer["comments"] as Array
	ng_cards = [bool(offer["ngCard"])]
	heart_cards = [bool(offer["heartCard"])]
	_choose_comment(0)

func _force_gift_choice_by_rarity(rarity: String) -> void:
	state = "gift_choice"
	selected_card = 0
	var gift_time: float = elapsed * (3.0 if quick_test_mode else 1.0)
	var context: Dictionary = GiftSystemScript.build_offer_context_for_target(self, gifts, gift_time, rng)
	offered_gifts = GiftSystemScript.build_forced_offer(context, rarity)
	choice_box.visible = true
	_refresh_choice_cards()
	_push_chat(_rarity_label(rarity) + "ギフトを強制抽選")

func _debug_pressed(keycode: Key) -> bool:
	var down: bool = Input.is_key_pressed(keycode)
	var was_down: bool = bool(debug_key_latch.get(keycode, false))
	debug_key_latch[keycode] = down
	return down and not was_down

func _update_chat(delta: float) -> void:
	chat_timer -= delta
	if chat_timer > 0.0:
		return
	chat_timer = ChatSystemScript.next_interval(state, kuso_chat_timer, rng)
	var pool: Array[String] = ChatSystemScript.pool_for_state(state)
	_push_chat(pool[rng.randi_range(0, pool.size() - 1)])

func _seed_chat(mode: String) -> void:
	chat_lines.clear()
	for line in ChatSystemScript.seed_lines(mode):
		_push_chat(line)

func _push_chat(text: String) -> void:
	chat_lines = ChatSystemScript.append_line(chat_lines, text)
	if chat_box == null:
		return
	for child in chat_box.get_children():
		child.queue_free()
	for item in ChatSystemScript.display_items(chat_lines):
		var view: Dictionary = item as Dictionary
		var label := Label.new()
		label.text = String(view["text"])
		label.add_theme_font_size_override("font_size", int(view["fontSize"]))
		label.add_theme_color_override("font_color", view["color"] as Color)
		chat_box.add_child(label)

func _update_hit_fx(delta: float) -> void:
	hit_fx = WeaponSystemScript.update_hit_fx(hit_fx, delta)

func _draw_shadow(pos: Vector2, size: Vector2, alpha: float = 0.28) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	for i in range(18):
		var a: float = TAU * float(i) / 18.0
		points.append(pos + Vector2(cos(a) * size.x * 0.5, sin(a) * size.y * 0.5))
	draw_colored_polygon(points, Color(0.0, 0.0, 0.0, alpha))

func _draw_spark(pos: Vector2, size: float, color: Color) -> void:
	draw_line(pos + Vector2(-size, 0), pos + Vector2(size, 0), color, 2.0)
	draw_line(pos + Vector2(0, -size), pos + Vector2(0, size), color, 2.0)

func _draw_arena() -> void:
	draw_rect(ARENA, DrawDataSystemScript.arena_base_color())
	for tile in DrawDataSystemScript.arena_tiles(ARENA):
		var tile_item: Dictionary = tile as Dictionary
		draw_rect(tile_item["rect"] as Rect2, tile_item["color"] as Color)
	for rock in DrawDataSystemScript.arena_rocks(ARENA):
		var rock_item: Dictionary = rock as Dictionary
		draw_circle(rock_item["pos"] as Vector2, float(rock_item["radius"]), rock_item["color"] as Color)
	for spark in DrawDataSystemScript.arena_sparks(ARENA):
		var spark_item: Dictionary = spark as Dictionary
		_draw_spark(spark_item["pos"] as Vector2, float(spark_item["size"]), spark_item["color"] as Color)
	if _has_effect("banana_floor"):
		var banana_data: Dictionary = DrawDataSystemScript.banana_floor_data(ARENA)
		draw_rect(banana_data["overlayRect"] as Rect2, banana_data["overlayColor"] as Color)
		for banana in banana_data["bananas"]:
			var banana_item: Dictionary = banana as Dictionary
			draw_arc(banana_item["pos"] as Vector2, 13, 0.2, 2.7, 10, banana_data["bananaColor"] as Color, 5)
	for wall in DrawDataSystemScript.static_wall_rects():
		_draw_arena_wall(wall as Rect2, false)
	for wall in effect_walls:
		_draw_arena_wall(wall as Rect2, true)
	for pit in effect_pits:
		var pit_data: Dictionary = DrawDataSystemScript.pit_draw_data(Vector2(pit["pos"]), float(pit["radius"]))
		draw_circle(pit_data["pos"] as Vector2, float(pit_data["radius"]), pit_data["outerColor"] as Color)
		draw_circle(pit_data["pos"] as Vector2, float(pit_data["innerRadius"]), pit_data["innerColor"] as Color)
	for shade in DrawDataSystemScript.arena_edge_shades(ARENA):
		var shade_item: Dictionary = shade as Dictionary
		draw_rect(shade_item["rect"] as Rect2, shade_item["color"] as Color)
	draw_rect(ARENA, DrawDataSystemScript.arena_border_color(), false, 5)

func _draw_arena_wall(rect: Rect2, temporary: bool) -> void:
	var wall: Dictionary = DrawDataSystemScript.arena_wall_data(rect, temporary)
	_draw_shadow(wall["shadowPos"] as Vector2, wall["shadowSize"] as Vector2, float(wall["shadowAlpha"]))
	draw_rect(rect, wall["fillColor"] as Color)
	draw_rect(wall["topRect"] as Rect2, wall["topColor"] as Color)
	draw_rect(rect, wall["borderColor"] as Color, false, int(wall["borderWidth"]))
	if not temporary:
		for x in range(1, int(rect.size.x / 36.0)):
			draw_line(rect.position + Vector2(float(x) * 36.0, 2), rect.position + Vector2(float(x) * 36.0, rect.size.y - 2), wall["seamColor"] as Color, 2)

func _draw_player() -> void:
	if player_sprite != null:
		var move_amount: float = clampf(player_vel.length() / 260.0, 0.0, 1.0)
		var idle_bob: float = sin(elapsed * 4.0) * 2.0
		var walk_bob: float = abs(sin(elapsed * 11.0)) * 5.0 * move_amount
		var dash_squash: float = clampf((player_vel.length() - 330.0) / 430.0, 0.0, 1.0)
		var attack_pop: float = clampf(1.0 - attack_timer / maxf(0.01, hammer_interval), 0.0, 1.0)
		attack_pop = sin(attack_pop * PI) * 0.08
		var tilt: float = clampf(player_vel.x / 520.0, -1.0, 1.0) * 0.12
		if last_hammer_dir.x < -0.2:
			tilt -= attack_pop * 0.6
		else:
			tilt += attack_pop * 0.6
		var alpha: float = 1.0
		if invincible > 0.0 and fmod(elapsed * 16.0, 2.0) < 1.0:
			alpha = 0.42
		_draw_shadow(player_pos + Vector2(0, 31 + walk_bob * 0.25), Vector2(62 + dash_squash * 12.0, 20 - dash_squash * 4.0), 0.30)
		var sprite_scale: float = float(current_character.get("spriteScale", 0.095))
		var offset_data: Dictionary = current_character.get("spriteOffset", {"x": 0, "y": -34})
		var offset: Vector2 = Vector2(float(offset_data.get("x", 0)), float(offset_data.get("y", -34)) - idle_bob - walk_bob)
		var size: Vector2 = Vector2(player_sprite.get_size()) * sprite_scale
		size.x *= 1.0 + dash_squash * 0.08 + attack_pop
		size.y *= 1.0 - dash_squash * 0.05 + attack_pop * 0.35
		var center: Vector2 = player_pos + offset
		draw_set_transform(center, tilt, Vector2.ONE)
		draw_texture_rect(player_sprite, Rect2(-size * 0.5, size), false, Color(1, 1, 1, alpha))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		if debug_invincible:
			var label: Dictionary = DrawDataSystemScript.invincible_label_data(player_pos)
			draw_string(ThemeDB.fallback_font, label["pos"] as Vector2, "無敵", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, label["color"] as Color)
		return
	var fallback: Dictionary = DrawDataSystemScript.fallback_player_draw_data(player_pos, current_character_id, invincible > 0.0)
	_draw_shadow(fallback["shadowPos"] as Vector2, fallback["shadowSize"] as Vector2, float(fallback["shadowAlpha"]))
	draw_circle(fallback["backPos"] as Vector2, float(fallback["backRadius"]), fallback["backColor"] as Color)
	draw_circle(fallback["bodyPos"] as Vector2, float(fallback["bodyRadius"]), fallback["bodyColor"] as Color)
	draw_circle(fallback["facePos"] as Vector2, float(fallback["faceRadius"]), fallback["faceColor"] as Color)
	draw_rect(fallback["liveBackRect"] as Rect2, fallback["liveBackColor"] as Color)
	draw_rect(fallback["liveRect"] as Rect2, fallback["liveColor"] as Color)
	draw_string(ThemeDB.fallback_font, fallback["liveTextPos"] as Vector2, "LIVE", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, fallback["liveTextColor"] as Color)
	draw_circle(fallback["rightEye"] as Vector2, float(fallback["eyeRadius"]), fallback["eyeColor"] as Color)
	draw_circle(fallback["leftEye"] as Vector2, float(fallback["eyeRadius"]), fallback["eyeColor"] as Color)
	draw_circle(fallback["rightEye"] as Vector2, float(fallback["eyeDotRadius"]), fallback["eyeDotColor"] as Color)
	draw_circle(fallback["leftEye"] as Vector2, float(fallback["eyeDotRadius"]), fallback["eyeDotColor"] as Color)
	draw_arc(fallback["mouthCenter"] as Vector2, 9, 0.1, PI - 0.1, 12, fallback["mouthColor"] as Color, 2)
	draw_line(fallback["micLineStart"] as Vector2, fallback["micLineEnd"] as Vector2, fallback["micLineColor"] as Color, 5)
	draw_circle(fallback["micPos"] as Vector2, float(fallback["micRadius"]), fallback["micColor"] as Color)
	draw_line(fallback["hammerLineStart"] as Vector2, fallback["hammerLineEnd"] as Vector2, fallback["hammerLineColor"] as Color, 15)
	draw_line(fallback["hammerCoreStart"] as Vector2, fallback["hammerCoreEnd"] as Vector2, fallback["hammerCoreColor"] as Color, 9)
	draw_circle(fallback["hammerBackPos"] as Vector2, float(fallback["hammerBackRadius"]), fallback["hammerBackColor"] as Color)
	draw_circle(fallback["hammerPos"] as Vector2, float(fallback["hammerRadius"]), fallback["hammerColor"] as Color)
	draw_string(ThemeDB.fallback_font, fallback["banTextPos"] as Vector2, "BAN", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, fallback["banTextColor"] as Color)
	if debug_invincible:
		var label: Dictionary = DrawDataSystemScript.invincible_label_data(player_pos)
		draw_string(ThemeDB.fallback_font, label["pos"] as Vector2, "無敵", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, label["color"] as Color)

func _draw_enemies() -> void:
	for enemy in enemies:
		var kind: String = String(enemy["kind"])
		var color: Color = DrawDataSystemScript.enemy_color(kind)
		var pos: Vector2 = Vector2(enemy["pos"])
		var radius: float = float(enemy["radius"])
		var shadow: Dictionary = DrawDataSystemScript.enemy_shadow_data(pos, radius)
		_draw_shadow(shadow["pos"] as Vector2, shadow["size"] as Vector2, float(shadow["alpha"]))
		var body: Dictionary = DrawDataSystemScript.enemy_body_data(kind, pos, radius, color)
		if String(body["kind"]) == "long":
			draw_rect(body["shadowRect"] as Rect2, body["shadowColor"] as Color)
			draw_rect(body["rect"] as Rect2, body["color"] as Color)
			draw_rect(body["topRect"] as Rect2, body["topColor"] as Color)
		elif String(body["kind"]) == "clipper":
			draw_rect(body["shadowRect"] as Rect2, body["shadowColor"] as Color)
			draw_rect(body["rect"] as Rect2, body["color"] as Color)
			draw_rect(body["lensRect"] as Rect2, body["lensColor"] as Color)
		else:
			draw_circle(body["shadowPos"] as Vector2, float(body["shadowRadius"]), body["shadowColor"] as Color)
			draw_circle(body["pos"] as Vector2, float(body["radius"]), body["color"] as Color)
			draw_circle(body["highlightPos"] as Vector2, float(body["highlightRadius"]), body["highlightColor"] as Color)
		if kind != "long_comment_guy":
			var face: Dictionary = DrawDataSystemScript.enemy_face_data(pos)
			draw_circle(face["leftEye"] as Vector2, float(face["eyeRadius"]), face["color"] as Color)
			draw_circle(face["rightEye"] as Vector2, float(face["eyeRadius"]), face["color"] as Color)
			draw_line(face["mouthStart"] as Vector2, face["mouthEnd"] as Vector2, face["color"] as Color, 3)
		var bar: Dictionary = DrawDataSystemScript.enemy_hp_bar_data(pos, radius, float(enemy["hp"]), float(enemy["max_hp"]))
		draw_rect(bar["backRect"] as Rect2, bar["backColor"] as Color)
		draw_rect(bar["fillRect"] as Rect2, bar["fillColor"] as Color)
		draw_string(ThemeDB.fallback_font, bar["labelPos"] as Vector2, _enemy_display_name(kind), HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color.WHITE)
func _draw_exp() -> void:
	for orb in exp_orbs:
		var data: Dictionary = DrawDataSystemScript.exp_orb_data(Vector2(orb["pos"]), elapsed)
		_draw_shadow(data["shadowPos"] as Vector2, data["shadowSize"] as Vector2, float(data["shadowAlpha"]))
		draw_polygon(data["diamond"] as PackedVector2Array, data["colors"] as PackedColorArray)
		draw_polyline(data["outline"] as PackedVector2Array, Color.WHITE, 2.0)
		draw_string(ThemeDB.fallback_font, data["labelPos"] as Vector2, "EXP", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color.WHITE)

func _draw_mallow() -> void:
	for item in marshmallows:
		var data: Dictionary = item["data"]
		var t: float = float(item["time"])
		var visual: Dictionary = DrawDataSystemScript.marshmallow_draw_data(Vector2(item["pos"]), data, t, elapsed, maro_appraisal)
		if bool(visual["isBad"]):
			draw_circle(visual["badAuraPos"] as Vector2, float(visual["badAuraRadius"]), visual["badAuraColor"] as Color)
			if bool(visual["appraisal"]):
				draw_circle(visual["pos"] as Vector2, float(visual["appraisalRadius"]), visual["appraisalColor"] as Color, false, 4.0)
		elif bool(visual["isGod"]):
			draw_circle(visual["pos"] as Vector2, float(visual["godAuraRadius"]), visual["godAuraColor"] as Color)
		_draw_shadow(visual["shadowPos"] as Vector2, visual["shadowSize"] as Vector2, float(visual["shadowAlpha"]))
		draw_circle(visual["basePos"] as Vector2, float(visual["baseRadius"]), visual["baseColor"] as Color)
		draw_circle(visual["pos"] as Vector2, float(visual["radius"]), visual["color"] as Color)
		draw_circle(visual["highlightPos"] as Vector2, float(visual["highlightRadius"]), visual["highlightColor"] as Color)
		for dot_pos in visual["dotPositions"]:
			draw_circle(dot_pos as Vector2, float(visual["dotRadius"]), visual["dotColor"] as Color)
		if bool(visual["warning"]):
			draw_string(ThemeDB.fallback_font, visual["warningPos"] as Vector2, "!", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, visual["warningColor"] as Color)
		draw_string(ThemeDB.fallback_font, visual["labelPos"] as Vector2, String(visual["label"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color.WHITE)
		draw_string(ThemeDB.fallback_font, visual["timePos"] as Vector2, "%02d" % int(ceil(t)), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, visual["timeColor"] as Color)

func _draw_enemy_bullets() -> void:
	var visual: Dictionary = DrawDataSystemScript.bullet_visual(false)
	for bullet in enemy_bullets:
		var pos: Vector2 = Vector2(bullet["pos"])
		var vel: Vector2 = Vector2(bullet["vel"]).normalized()
		draw_line(pos - vel * float(visual["trailLength"]), pos, visual["trailColor"] as Color, float(visual["trailWidth"]))
		draw_circle(pos, float(visual["outerRadius"]), visual["outerColor"] as Color)
		draw_circle(pos, float(visual["innerRadius"]), visual["innerColor"] as Color)

func _draw_player_bullets() -> void:
	var visual: Dictionary = DrawDataSystemScript.bullet_visual(true)
	for bullet in player_bullets:
		var pos: Vector2 = Vector2(bullet["pos"])
		var vel: Vector2 = Vector2(bullet["vel"]).normalized()
		draw_line(pos - vel * float(visual["trailLength"]), pos, visual["trailColor"] as Color, float(visual["trailWidth"]))
		draw_circle(pos, float(visual["outerRadius"]), visual["outerColor"] as Color)
		draw_circle(pos, float(visual["innerRadius"]), visual["innerColor"] as Color)

func _draw_boomerang() -> void:
	var is_main_orbit: bool = _weapon_attack_type() == "orbit"
	var count: int = WeaponSystemScript.orbit_count(current_weapon, boomerang_level)
	if count <= 0:
		return
	var radius: float = hammer_range if is_main_orbit else 78.0
	var orbit_speed: float = WeaponSystemScript.orbit_speed(current_weapon)
	var visual: Dictionary = DrawDataSystemScript.boomerang_visual()
	for i in range(count):
		var angle: float = elapsed * orbit_speed + TAU * float(i) / float(count)
		var pos: Vector2 = player_pos + Vector2(cos(angle), sin(angle)) * radius
		draw_arc(pos, float(visual["outerRadius"]), angle, angle + PI * 1.25, int(visual["outerPoints"]), visual["outerColor"] as Color, float(visual["outerWidth"]))
		draw_arc(pos, float(visual["innerRadius"]), angle + PI, angle + TAU * 1.2, int(visual["innerPoints"]), visual["innerColor"] as Color, float(visual["innerWidth"]))

func _draw_hit_fx() -> void:
	for fx in hit_fx:
		var dir: Vector2 = fx["dir"]
		var life: float = float(fx["life"])
		var data: Dictionary = DrawDataSystemScript.hit_fx_data(Vector2(fx["pos"]), dir, Vector2(fx["hit"]), float(fx["range"]), life)
		draw_line(data["start"] as Vector2, data["end"] as Vector2, data["mainColor"] as Color, float(data["width"]))
		draw_line(data["start"] as Vector2, data["end"] as Vector2, data["coreColor"] as Color, float(data["coreWidth"]))
		if int(fx["count"]) > 0:
			draw_circle(data["burstPos"] as Vector2, float(data["burstRadius"]), data["burstColor"] as Color)
			draw_string(ThemeDB.fallback_font, data["labelPos"] as Vector2, "BAN!", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, data["labelColor"] as Color)

func _draw_frames() -> void:
	var frame: Dictionary = DrawDataSystemScript.hud_frame_data(SIDE, HUD)
	draw_rect(frame["sideRect"] as Rect2, frame["sideFill"] as Color)
	draw_rect(frame["sideRect"] as Rect2, frame["sideBorder"] as Color, false, 4)
	draw_line(frame["sideDividerStart"] as Vector2, frame["sideDividerEnd"] as Vector2, frame["sideDividerColor"] as Color, 2)
	draw_string(ThemeDB.fallback_font, frame["viewerPos"] as Vector2, "8,888", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color.WHITE)
	draw_rect(frame["hudRect"] as Rect2, frame["hudFill"] as Color)
	draw_rect(frame["hudRect"] as Rect2, frame["hudBorder"] as Color, false, 4)
	var remaining: int = maxi(0, int(ceil(_run_length() - elapsed)))
	var time_text: String = "%02d:%02d" % [remaining / 60, remaining % 60]
	var exp_ratio: float = float(exp_value) / float(_current_exp_need())
	var hype_ratio: float = float(gift_hype) / 100.0
	var hp_text: String = "??/??" if _has_effect("hide_hp") else "%d/%d" % [player_hp, player_max_hp]
	var metric_values: Dictionary = {
		"hp": hp_text,
		"time": time_text,
		"multiplier": "x%.1f" % multiplier,
		"burn": str(burn_combo),
		"hype": "%d%%" % gift_hype,
		"ng": "x%d" % ng_stock,
		"heart": "x%d" % heart_stock,
		"nextComment": "%.1fs" % maxf(0.0, comment_timer),
		"currentComment": current_comment
	}
	for spec in DrawDataSystemScript.hud_metric_specs(comment_timer <= 5.0):
		var item: Dictionary = spec as Dictionary
		var key: String = String(item["key"])
		_draw_metric_panel(item["rect"] as Rect2, String(item["label"]), String(metric_values[key]), item["accent"] as Color)
	for gauge in DrawDataSystemScript.hud_gauge_data(exp_ratio, hype_ratio):
		var gauge_item: Dictionary = gauge as Dictionary
		draw_rect(gauge_item["backRect"] as Rect2, gauge_item["backColor"] as Color)
		draw_rect(gauge_item["fillRect"] as Rect2, gauge_item["fillColor"] as Color)
		draw_string(ThemeDB.fallback_font, gauge_item["labelPos"] as Vector2, String(gauge_item["label"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, gauge_item["labelColor"] as Color)
func _draw_metric_panel(rect: Rect2, label: String, value: String, accent: Color) -> void:
	var style: Dictionary = DrawDataSystemScript.metric_panel_style(rect, accent)
	draw_rect(style["rect"] as Rect2, style["fill"] as Color)
	draw_rect(style["rect"] as Rect2, style["border"] as Color, false, 3)
	draw_rect(style["accentRect"] as Rect2, style["accent"] as Color)
	draw_string(ThemeDB.fallback_font, style["labelPos"] as Vector2, label, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#cfc7ff"))
	draw_string(ThemeDB.fallback_font, style["valuePos"] as Vector2, value, HORIZONTAL_ALIGNMENT_LEFT, int(style["valueWidth"]), 26, accent)

func _draw_comment_countdown() -> void:
	if state == "comment_choice":
		return
	var left: float = maxf(0.0, comment_timer)
	var data: Dictionary = DrawDataSystemScript.comment_countdown_data(left, COMMENT_INTERVAL, elapsed)
	var alert: bool = bool(data["alert"])
	var rect: Rect2 = data["rect"] as Rect2
	draw_rect(rect, data["fill"] as Color)
	draw_rect(rect, data["border"] as Color, false, 4)
	draw_rect(data["progressRect"] as Rect2, data["progressColor"] as Color)
	var title: String = DisplayTextSystemScript.comment_countdown_title(alert)
	var value: String = "%.1fs" % left
	draw_string(ThemeDB.fallback_font, data["titlePos"] as Vector2, title, HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color.WHITE)
	draw_string(ThemeDB.fallback_font, data["valuePos"] as Vector2, value, HORIZONTAL_ALIGNMENT_RIGHT, 130, 25, data["valueColor"] as Color)
	if alert:
		draw_string(ThemeDB.fallback_font, data["warningPos"] as Vector2, DisplayTextSystemScript.comment_countdown_warning(), HORIZONTAL_ALIGNMENT_LEFT, -1, 18, data["warningColor"] as Color)
func _draw_title_overlay() -> void:
	var center: Vector2 = DrawDataSystemScript.title_center()
	var panel_data: Dictionary = DrawDataSystemScript.title_panel_data()
	var panel: Rect2 = panel_data["rect"] as Rect2
	draw_rect(panel, panel_data["fill"] as Color)
	draw_rect(panel, panel_data["border"] as Color, false, 5)
	for line in DisplayTextSystemScript.title_lines(_comment_barrage_label(), screen_shake_enabled):
		var item: Dictionary = line as Dictionary
		_draw_text_line(center, item)
func _draw_character_select_overlay() -> void:
	var panel: Rect2 = DrawDataSystemScript.character_select_panel_rect()
	_draw_selection_panel(panel)
	_draw_selection_header(panel, DisplayTextSystemScript.character_select_title(), Vector2(620, 58))
	for i in range(characters.size()):
		var character: Dictionary = characters[i] as Dictionary
		var view: Dictionary = CharacterSystemScript.selection_card_view(character, weapons)
		var card: Rect2 = DrawDataSystemScript.character_card_rect(panel, i)
		_draw_character_card(card, view, i, i == selected_character_index)

func _draw_character_card(card: Rect2, view: Dictionary, index: int, selected: bool) -> void:
	var border: Color = _draw_selection_card_frame(card, selected)
	var tex: Texture2D = _character_texture(String(view["spritePath"]))
	var tex_size: Vector2 = tex.get_size() if tex != null else Vector2.ZERO
	var layout: Dictionary = DrawDataSystemScript.character_card_layout(card, tex_size)
	draw_string(ThemeDB.fallback_font, layout["titlePos"] as Vector2, "[%d] %s" % [index + 1, String(view["displayName"])], HORIZONTAL_ALIGNMENT_LEFT, int(layout["titleWidth"]), 29, border)
	if tex != null:
		draw_texture_rect(tex, layout["textureRect"] as Rect2, false)
	var text_w: int = int(layout["textWidth"])
	draw_string(ThemeDB.fallback_font, layout["rolePos"] as Vector2, DisplayTextSystemScript.character_role_text(String(view["roleName"])), HORIZONTAL_ALIGNMENT_LEFT, text_w, 18, layout["roleColor"] as Color)
	draw_string(ThemeDB.fallback_font, layout["weaponPos"] as Vector2, DisplayTextSystemScript.character_weapon_text(String(view["weaponName"])), HORIZONTAL_ALIGNMENT_LEFT, text_w, 18, Color.WHITE)
	draw_string(ThemeDB.fallback_font, layout["passivePos"] as Vector2, DisplayTextSystemScript.character_passive_text(String(view["passiveName"])), HORIZONTAL_ALIGNMENT_LEFT, text_w, 18, Color.WHITE)
	draw_multiline_string(ThemeDB.fallback_font, layout["descriptionPos"] as Vector2, String(view["description"]), HORIZONTAL_ALIGNMENT_LEFT, text_w, 16, -1, layout["descriptionColor"] as Color)
func _draw_stream_frame_select_overlay() -> void:
	var panel: Rect2 = DrawDataSystemScript.stream_frame_select_panel_rect()
	_draw_selection_panel(panel)
	_draw_selection_header(panel, DisplayTextSystemScript.stream_frame_select_title(), Vector2(610, 58))
	for i in range(stream_frames.size()):
		var frame: Dictionary = stream_frames[i] as Dictionary
		var view: Dictionary = StreamFrameSystemScript.selection_card_view(frame)
		var card: Rect2 = DrawDataSystemScript.stream_frame_card_rect(panel, i)
		_draw_stream_frame_card(card, view, i, i == selected_stream_frame_index)

func _draw_selection_panel(panel: Rect2) -> void:
	draw_rect(panel, DrawDataSystemScript.selection_panel_fill())
	draw_rect(panel, DrawDataSystemScript.selection_panel_border(), false, 5)

func _draw_selection_header(panel: Rect2, title_text: String, help_offset: Vector2) -> void:
	var data: Dictionary = DrawDataSystemScript.selection_header_data(panel, help_offset)
	draw_string(ThemeDB.fallback_font, data["titlePos"] as Vector2, title_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 36, data["titleColor"] as Color)
	draw_string(ThemeDB.fallback_font, data["helpPos"] as Vector2, DisplayTextSystemScript.select_help_text(), HORIZONTAL_ALIGNMENT_LEFT, -1, 20, data["helpColor"] as Color)

func _draw_text_line(origin: Vector2, item: Dictionary) -> void:
	draw_string(
		ThemeDB.fallback_font,
		origin + (item["offset"] as Vector2),
		String(item["text"]),
		HORIZONTAL_ALIGNMENT_LEFT,
		int(item.get("width", -1)),
		int(item["size"]),
		item["color"] as Color
	)

func _draw_selection_card_frame(card: Rect2, selected: bool) -> Color:
	var border: Color = DrawDataSystemScript.selection_card_border(selected)
	draw_rect(card, DrawDataSystemScript.selection_card_fill())
	draw_rect(card, border, false, 4 if selected else 2)
	return border

func _draw_stream_frame_card(card: Rect2, view: Dictionary, index: int, selected: bool) -> void:
	var border: Color = _draw_selection_card_frame(card, selected)
	var layout: Dictionary = DrawDataSystemScript.stream_frame_card_layout(card)
	var text_w: int = int(layout["textWidth"])
	draw_string(ThemeDB.fallback_font, layout["titlePos"] as Vector2, "[%d] %s" % [index + 1, String(view["displayName"])], HORIZONTAL_ALIGNMENT_LEFT, text_w, 30, border)
	draw_multiline_string(ThemeDB.fallback_font, layout["descriptionPos"] as Vector2, String(view["description"]), HORIZONTAL_ALIGNMENT_LEFT, text_w, 19, -1, layout["descriptionColor"] as Color)
	draw_string(ThemeDB.fallback_font, layout["difficultyPos"] as Vector2, DisplayTextSystemScript.stream_frame_difficulty_text(String(view["difficultyText"])), HORIZONTAL_ALIGNMENT_LEFT, text_w, 22, layout["difficultyColor"] as Color)
	var features: Array[String] = view["features"]
	draw_multiline_string(ThemeDB.fallback_font, layout["featuresPos"] as Vector2, DisplayTextSystemScript.stream_frame_feature_text(features), HORIZONTAL_ALIGNMENT_LEFT, text_w, 18, -1, layout["featuresColor"] as Color)
func _draw_choice_backplate() -> void:
	var data: Dictionary = DrawDataSystemScript.choice_backplate_data()
	var rect: Rect2 = data["rect"] as Rect2
	draw_rect(rect, data["fill"] as Color)
	draw_rect(rect, data["border"] as Color, false, 4)

func _draw_comment_storm() -> void:
	var samples: Array[String] = DisplayTextSystemScript.comment_storm_samples()
	var style: Dictionary = DrawDataSystemScript.comment_storm_style(comment_barrage_setting, kuso_chat_timer > 0.0)
	var amount: int = int(style["amount"])
	var alpha: float = float(style["alpha"])
	for i in range(amount):
		var pos: Vector2 = DrawDataSystemScript.comment_storm_position(ARENA, elapsed, i)
		var text: String = samples[i % samples.size()]
		draw_string(ThemeDB.fallback_font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(1.0, 1.0, 1.0, alpha))
func _draw_tutorial_overlay_v2() -> void:
	var data: Dictionary = DrawDataSystemScript.tutorial_overlay_data()
	var rect: Rect2 = data["rect"] as Rect2
	draw_rect(rect, data["fill"] as Color)
	draw_rect(rect, data["border"] as Color, false, 4)
	for line in DisplayTextSystemScript.tutorial_text_lines():
		_draw_text_line(rect.position, line as Dictionary)

func _draw_zoom_mask() -> void:
	var data: Dictionary = DrawDataSystemScript.zoom_mask_data(ARENA)
	var shade: Color = Color(0.0, 0.0, 0.0, 0.24)
	for rect in data["shades"]:
		draw_rect(rect as Rect2, shade)
	var inner: Rect2 = data["inner"] as Rect2
	draw_rect(inner, Color(1.0, 1.0, 1.0, 0.08), false, 3)

func _draw_horror_mask() -> void:
	var data: Dictionary = DrawDataSystemScript.horror_mask_data(elapsed)
	draw_rect(ARENA, data["shade"] as Color)
	draw_rect(ARENA, data["pulse"] as Color, false, 6)
	draw_string(ThemeDB.fallback_font, ARENA.position + Vector2(36, 70), DisplayTextSystemScript.horror_event_title(), HORIZONTAL_ALIGNMENT_LEFT, -1, 30, data["titleColor"] as Color)
func _draw_toast() -> void:
	if toast_timer <= 0.0:
		return
	var data: Dictionary = DrawDataSystemScript.toast_data(toast_text)
	var rect: Rect2 = data["rect"] as Rect2
	draw_rect(rect, data["fill"] as Color)
	draw_rect(rect, data["border"] as Color, false, 4)
	draw_string(ThemeDB.fallback_font, data["textPos"] as Vector2, toast_text, HORIZONTAL_ALIGNMENT_LEFT, int(data["textWidth"]), int(data["fontSize"]), Color.WHITE)
