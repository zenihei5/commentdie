extends Node2D

const CommentSystemScript := preload("res://scripts/systems/comment_system.gd")
const GiftSystemScript := preload("res://scripts/systems/gift_system.gd")
const WeaponSystemScript := preload("res://scripts/systems/weapon_system.gd")
const EnemySystemScript := preload("res://scripts/systems/enemy_system.gd")
const BossSystemScript := preload("res://scripts/systems/boss_system.gd")
const MarshmallowSystemScript := preload("res://scripts/systems/marshmallow_system.gd")
const GenreEventSystemScript := preload("res://scripts/systems/genre_event_system.gd")
const StreamFrameSystemScript := preload("res://scripts/systems/stream_frame_system.gd")
const DisplayTextSystemScript := preload("res://scripts/systems/display_text_system.gd")
const SettingsSystemScript := preload("res://scripts/systems/settings_system.gd")
const CharacterSystemScript := preload("res://scripts/systems/character_system.gd")
const ResultSystemScript := preload("res://scripts/systems/result_system.gd")
const RankingSystemScript := preload("res://scripts/systems/ranking_system.gd")
const UiStyleSystemScript := preload("res://scripts/systems/ui_style_system.gd")
const HudTextSystemScript := preload("res://scripts/systems/hud_text_system.gd")
const DebugSystemScript := preload("res://scripts/systems/debug_system.gd")
const RunStateSystemScript := preload("res://scripts/systems/run_state_system.gd")
const DrawDataSystemScript := preload("res://scripts/systems/draw_data_system.gd")
const ChatSystemScript := preload("res://scripts/systems/chat_system.gd")
const ChoiceCardSystemScript := preload("res://scripts/systems/choice_card_system.gd")
const UiBuilderSystemScript := preload("res://scripts/systems/ui_builder_system.gd")
const StateFlowSystemScript := preload("res://scripts/systems/state_flow_system.gd")
const ExpSystemScript := preload("res://scripts/systems/exp_system.gd")
const DestructibleSystemScript := preload("res://scripts/systems/destructible_system.gd")
const PlayerSystemScript := preload("res://scripts/systems/player_system.gd")
const SpawnerSystemScript := preload("res://scripts/systems/spawner_system.gd")
const DamageSystemScript := preload("res://scripts/systems/damage_system.gd")
const ModifierSystemScript := preload("res://scripts/systems/modifier_system.gd")
const MapBackgroundSystemScript := preload("res://scripts/systems/map_background_system.gd")
const TextureCacheSystemScript := preload("res://scripts/systems/texture_cache_system.gd")
const DrawPrimitiveSystemScript := preload("res://scripts/systems/draw_primitive_system.gd")
const FieldPickupVisualSystemScript := preload("res://scripts/systems/field_pickup_visual_system.gd")
const EnemyDrawSystemScript := preload("res://scripts/systems/enemy_draw_system.gd")
const ExpDrawSystemScript := preload("res://scripts/systems/exp_draw_system.gd")
const WeaponDrawSystemScript := preload("res://scripts/systems/weapon_draw_system.gd")
const TITLE_BACK_IMAGE := "res://assets/title/title_back.png"
const TITLE_LOGO_IMAGE := "res://assets/title/title_logo_alpha.png"
const TITLE_BANCHAN_IMAGE := "res://assets/title/title_banchan_alpha.png"
const TITLE_SUPANA_IMAGE := "res://assets/title/title_supana_alpha.png"
const TITLE_MARON_IMAGE := "res://assets/title/title_maron_alpha.png"
const TITLE_BUTTON_IMAGE := "res://assets/title/title_button_alpha.png"
const TITLE_BGM_PATH := "res://assets/audio/title_bgm.mp3"
const BOSS_BATTLE_BGM_PATH := "res://assets/audio/boss_battle_bgm.mp3"
const BOSS_BGM_FADE_DURATION := 0.75
const CURSOR_MOVE_SE_PATH := "res://assets/audio/cursor_move.mp3"
const CONFIRM_SELECT_SE_PATH := "res://assets/audio/confirm_select.mp3"
const LASER_SHOT_SE_PATH := "res://assets/audio/laser_shot.mp3"
const BAN_HAMMER_SWING_SE_PATH := "res://assets/audio/ban_hammer_swing.mp3"
const SUPERCHAT_SHOT_SE_PATH := "res://assets/audio/superchat_shot.mp3"
const MARSHMALLOW_PICKUP_SE_PATH := "res://assets/audio/marshmallow_pickup.mp3"
const KUSO_MARSHMALLOW_PICKUP_SE_PATH := "res://assets/audio/kuso_marshmallow_pickup.mp3"
const COMMENT_BOOMERANG_IMAGE := "res://assets/generated/comment_boomerang_sprite_v1/comment_boomerang.png"
const STREAM_START_INTRO_DURATION := 1.20
const GAME_OVER_INTRO_MENTAL_DURATION := 2.0
const GAME_OVER_INTRO_COMPLETE_DURATION := 2.2
const GAME_OVER_INTRO_SKIP_DELAY := 0.5
const RESULT_DROP_DURATION := 0.48
const RESULT_DROP_START_Y := -860.0
const COMMENT_PANEL_BG_V25 := "res://assets/generated/ui_parts_v2/comment_panel_bg_v1_370x606.png"
const TITLE_SCREEN_RECT := Rect2(Vector2.ZERO, Vector2(1600, 900))
const TITLE_SUPANA_RECT := Rect2(Vector2(-210, 160), Vector2(580, 845))
const TITLE_MARON_RECT := Rect2(Vector2(1155, 185), Vector2(460, 822))
const TITLE_BANCHAN_RECT := Rect2(Vector2(125, 285), Vector2(510, 711))
const TITLE_LOGO_RECT := Rect2(Vector2(390, 4), Vector2(820, 442))
const TITLE_BUTTON_RECT := Rect2(Vector2(560, 450), Vector2(480, 430))
const TITLE_BUTTON_SOURCE_SIZE := Vector2(1074, 960)
const FIELD_VIEW := Rect2(Vector2(20, 190), Vector2(1160, 590))
const ARENA := Rect2(Vector2(20, 120), Vector2(2200, 1500))
const SIDE := Rect2(Vector2(1210, 174), Vector2(370, 606))
const HUD := Rect2(Vector2(20, 790), Vector2(1560, 90))
const NORMAL_RUN_LENGTH := 180.0
const QUICK_RUN_LENGTH := 60.0
const COMMENT_INTERVAL := 15.0
const CHOICE_TIME := 10.0
const BANANA_FLOOR_APPEAR_DURATION := 0.85
const BANANA_FLOOR_ROLLBACK_DURATION := 1.15

var rng := RandomNumberGenerator.new()
var data_repo: DataRepository
var comments: Array = []
var gifts: Array = []
var marshmallow_data: Array = []
var stream_frames: Array = []
var genre_events: Array = []
var characters: Array = []
var weapons: Array = []
var bosses: Array = []
var stream_frame_progress: Dictionary = {}
var relay_mode_unlocked := false
var current_stream_frame: Dictionary = {}
var current_character: Dictionary = {}
var current_weapon: Dictionary = {}
var current_stream_frame_id := "zatsudan"
var current_character_id := "ban_chan"
var current_weapon_id := "ban_hammer"
var player_sprite: Texture2D
var player_idle_sprite: Texture2D
var player_run_sprite: Texture2D
var selected_character_index := 0
var selected_stream_frame_index := 0
var title_menu_index := 0
var option_menu_index := 0
var character_sprite_cache: Dictionary = {}
var ranking_avatar_source_cache: Dictionary = {}
var equipment_icon_cache: Dictionary = {}
var ui_part_cache: Dictionary = {}
var field_pickup_icon_cache: Dictionary = {}
var raw_png_texture_cache: Dictionary = {}
var offered_comments: Array = []
var offered_gifts: Array = []
var pending_gift_choices := 0
var taken_gift_names: Array[String] = []
var ng_cards: Array[bool] = []
var heart_cards: Array[bool] = []
var enemies: Array = []
var next_enemy_uid := 1
var enemy_bullets: Array = []
var boss_requested := false
var boss_warning_timer := 0.0
var boss_warning_duration := 3.0
var boss_pending_id := ""
var boss_warning_text := "大荒れイベント発生！"
var boss_active := false
var active_boss_uid := -1
var boss_summon_count := 0
var boss_heart_variant := false
var boss_hp_rate := 1.0
var boss_attack_interval_rate := 1.0
var boss_reward_rate := 1.0
var boss_summoned := false
var boss_defeated := false
var boss_last_name := ""
var boss_last_result := ""
var boss_reward_viewers := 0
var boss_slow_fields: Array = []
var exp_orbs: Array = []
var player_bullets: Array = []
var boomerang_hits: Dictionary = {}
var equipment_weapon_timers: Dictionary = {}
var hit_fx: Array = []
var banana_slip_fx_timer := 0.0
var banana_floor_appear_timer := 0.0
var banana_floor_rollback_timer := 0.0
var banana_floor_was_active := false
var destructibles: Array = []
var drop_items: Array = []
var next_destructible_uid := 1
var player_weapons: Array = []
var player_accessories: Array = []
var chat_lines: Array[String] = []
var active_effects: Array[String] = []
var active_effect_rates: Dictionary = {}

var state := "title"
var previous_state := "playing"
var quick_test_mode := false
var relay_mode := false
var relay_completed_frame_ids: Array[String] = []
var relay_cleared_frame_count := 0
var relay_total_score := 0
var relay_max_score := 0
var relay_max_multiplier := 1.0
var relay_max_burn_combo := 0
var tutorial_seen := false
var tutorial_input_grace := 0.0
var bgm_volume := 70
var se_volume := 80
var fullscreen_enabled := true
var window_size_index := 1
var pending_window_resize_lock_frames := 0
var comment_barrage_setting := 1
var screen_shake_enabled := true
var selected_card := 0
var choice_timer := 0.0
var comment_choice_enter_time := 0.0
var gift_choice_enter_time := 0.0
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
var next_care_package_time := 15.0

var player_pos := ARENA.get_center()
var player_vel := Vector2.ZERO
var player_facing_x := 1.0
var world_camera_offset := Vector2.ZERO
var world_draw_active := false
var world_zoom: float = 1.0
var world_zoom_target: float = 1.0
var player_hp := 5
var player_max_hp := 5
var player_speed := 255.0
var player_base_invincible_time := 0.7
var passive_score_rate := 1.0
var passive_maro_good_rate := 1.0
var passive_maro_pickup_rate := 1.0
var dash_cd := 0.0
var dash_tap_timer := 0.0
var dash_tap_last_dir := Vector2.ZERO
var dash_left_down := false
var dash_right_down := false
var dash_up_down := false
var dash_down_down := false
var dash_enter_down := false
var invincible := 0.0
var debug_invincible := false

var hammer_damage := 12.0
var hammer_range := 165.0
var hammer_interval := 0.85
var magnet_range := 95.0
var dash_cooldown := 1.2
var knockback_power := 18.0
var equipment_damage_rate := 1.0
var equipment_range_rate := 1.0
var equipment_interval_rate := 1.0
var equipment_bullet_support_level := 0
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
var ng_used_count := 0
var heart_stock := 0
var heart_pending := false
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
var last_result_data: Dictionary = {}
var last_result_text := ""
var result_showing_ranking: bool = false
var result_hover_button := ""
var ranking_tab_index: int = 0
var ranking_selected_index: int = 0
var debug_key_latch: Dictionary = {}
var pause_escape_down := false
var pause_menu_index := 0
var pause_confirm_action := ""
var pause_nav_repeat_timer := 0.0
var pause_nav_last_dir := 0
var toast_text := ""
var toast_timer := 0.0
var time_announcement_flags: Dictionary = {}
var last_countdown_announcement_second := -1
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
var title_label: Label
var chat_title_label: Label
var ban_hammer_weapon_sprite: Texture2D
var comment_boomerang_sprite: Texture2D
var title_bgm_player: AudioStreamPlayer
var gameplay_bgm_player: AudioStreamPlayer
var gameplay_bgm_path := ""
var boss_bgm_player: AudioStreamPlayer
var boss_bgm_mix := 0.0
var ui_se_player: AudioStreamPlayer
var confirm_se_player: AudioStreamPlayer
var laser_se_player: AudioStreamPlayer
var ban_hammer_se_player: AudioStreamPlayer
var superchat_shot_se_player: AudioStreamPlayer
var marshmallow_pickup_se_player: AudioStreamPlayer
var kuso_marshmallow_pickup_se_player: AudioStreamPlayer
var stream_start_intro_timer := 0.0
var game_over_intro_timer := 0.0
var game_over_intro_duration := 0.0
var result_drop_timer := 0.0
var pending_game_over_reason := ""
var pending_game_over_end_type := ""

func _ready() -> void:
	rng.randomize()
	ban_hammer_weapon_sprite = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, "res://assets/generated/ban_hammer_weapon_sprite_v1/clean.png")
	comment_boomerang_sprite = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, COMMENT_BOOMERANG_IMAGE)
	_setup_title_bgm()
	_setup_gameplay_bgm()
	_setup_boss_bgm()
	_setup_ui_se()
	_setup_confirm_se()
	_setup_laser_se()
	_setup_ban_hammer_se()
	_setup_superchat_shot_se()
	_setup_marshmallow_pickup_se()
	_setup_kuso_marshmallow_pickup_se()
	data_repo = RunStateSystemScript.load_boot_data_for_target(self, character_sprite_cache)
	_build_ui()
	ChatSystemScript.seed_box_for_target(self, chat_box, "normal")
	_update_ui()
	_sync_title_bgm()
	_sync_gameplay_bgm()
	_sync_boss_bgm(0.0)

func _process(delta: float) -> void:
	_update_window_resize_lock()
	_update_world_zoom(delta)
	if state != "pause" and state != "result" and state != "stream_start_intro" and state != "game_over_intro":
		ChatSystemScript.update_timer_for_target(self, delta, rng, chat_box)
	if state == "comment_choice":
		comment_choice_enter_time += delta
		_update_comment_choice_box_drop()
	if state == "gift_choice":
		gift_choice_enter_time += delta
		_update_gift_choice_box_drop()
	if state != "stream_start_intro" and state != "game_over_intro":
		StateFlowSystemScript.update_pause_input_for_target(self)
	if _update_front_state(delta):
		_sync_title_bgm()
		_sync_gameplay_bgm()
		_sync_boss_bgm(delta)
		return
	_handle_debug_keys()
	_update_active_state(delta)
	_update_ui()
	_sync_title_bgm()
	_sync_gameplay_bgm()
	_sync_boss_bgm(delta)
	queue_redraw()

func _setup_title_bgm() -> void:
	title_bgm_player = AudioStreamPlayer.new()
	title_bgm_player.name = "TitleBgmPlayer"
	title_bgm_player.volume_db = SettingsSystemScript.volume_db_from_percent(bgm_volume)
	title_bgm_player.stream = _load_looping_audio_stream(TITLE_BGM_PATH)
	add_child(title_bgm_player)

func _setup_gameplay_bgm() -> void:
	gameplay_bgm_player = AudioStreamPlayer.new()
	gameplay_bgm_player.name = "GameplayBgmPlayer"
	gameplay_bgm_player.volume_db = SettingsSystemScript.volume_db_from_percent(bgm_volume)
	add_child(gameplay_bgm_player)

func _setup_boss_bgm() -> void:
	boss_bgm_player = AudioStreamPlayer.new()
	boss_bgm_player.name = "BossBgmPlayer"
	boss_bgm_player.volume_db = -80.0
	boss_bgm_player.stream = _load_looping_audio_stream(BOSS_BATTLE_BGM_PATH)
	add_child(boss_bgm_player)

func _setup_ui_se() -> void:
	ui_se_player = AudioStreamPlayer.new()
	ui_se_player.name = "UiSePlayer"
	ui_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	ui_se_player.stream = _load_audio_stream(CURSOR_MOVE_SE_PATH, false)
	add_child(ui_se_player)

func _setup_confirm_se() -> void:
	confirm_se_player = AudioStreamPlayer.new()
	confirm_se_player.name = "ConfirmSePlayer"
	confirm_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	confirm_se_player.stream = _load_audio_stream(CONFIRM_SELECT_SE_PATH, false)
	add_child(confirm_se_player)

func _setup_laser_se() -> void:
	laser_se_player = AudioStreamPlayer.new()
	laser_se_player.name = "LaserSePlayer"
	laser_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	laser_se_player.stream = _load_audio_stream(LASER_SHOT_SE_PATH, false)
	add_child(laser_se_player)

func _setup_ban_hammer_se() -> void:
	ban_hammer_se_player = AudioStreamPlayer.new()
	ban_hammer_se_player.name = "BanHammerSePlayer"
	ban_hammer_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	ban_hammer_se_player.stream = _load_audio_stream(BAN_HAMMER_SWING_SE_PATH, false)
	add_child(ban_hammer_se_player)

func _setup_superchat_shot_se() -> void:
	superchat_shot_se_player = AudioStreamPlayer.new()
	superchat_shot_se_player.name = "SuperchatShotSePlayer"
	superchat_shot_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	superchat_shot_se_player.stream = _load_audio_stream(SUPERCHAT_SHOT_SE_PATH, false)
	add_child(superchat_shot_se_player)

func _setup_marshmallow_pickup_se() -> void:
	marshmallow_pickup_se_player = AudioStreamPlayer.new()
	marshmallow_pickup_se_player.name = "MarshmallowPickupSePlayer"
	marshmallow_pickup_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	marshmallow_pickup_se_player.stream = _load_audio_stream(MARSHMALLOW_PICKUP_SE_PATH, false)
	add_child(marshmallow_pickup_se_player)

func _setup_kuso_marshmallow_pickup_se() -> void:
	kuso_marshmallow_pickup_se_player = AudioStreamPlayer.new()
	kuso_marshmallow_pickup_se_player.name = "KusoMarshmallowPickupSePlayer"
	kuso_marshmallow_pickup_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	kuso_marshmallow_pickup_se_player.stream = _load_audio_stream(KUSO_MARSHMALLOW_PICKUP_SE_PATH, false)
	add_child(kuso_marshmallow_pickup_se_player)

func _load_audio_stream(path: String, loop: bool = false) -> AudioStream:
	var loaded: AudioStream = ResourceLoader.load(path) as AudioStream
	if loaded == null:
		if path.get_extension().to_lower() == "mp3" and FileAccess.file_exists(path):
			var fallback_stream := AudioStreamMP3.new()
			fallback_stream.data = FileAccess.get_file_as_bytes(path)
			fallback_stream.loop = loop
			return fallback_stream
		return null
	var stream: AudioStream = loaded.duplicate() as AudioStream
	if stream == null:
		stream = loaded
	if stream is AudioStreamMP3:
		var mp3_stream: AudioStreamMP3 = stream as AudioStreamMP3
		mp3_stream.loop = loop
	return stream

func _load_looping_audio_stream(path: String) -> AudioStream:
	return _load_audio_stream(path, true)

func _title_bgm_should_play() -> bool:
	return state in ["title", "ranking", "options", "character_select", "stream_frame_select", "stream_start_intro", "tutorial"]

func _sync_title_bgm() -> void:
	if title_bgm_player == null or title_bgm_player.stream == null:
		return
	title_bgm_player.volume_db = SettingsSystemScript.volume_db_from_percent(bgm_volume)
	if _title_bgm_should_play():
		if not title_bgm_player.playing:
			title_bgm_player.play()
	elif title_bgm_player.playing:
		title_bgm_player.stop()

func _stream_frame_bgm_path() -> String:
	return String(current_stream_frame.get("bgmPath", ""))

func _gameplay_bgm_should_play() -> bool:
	return state in ["playing", "comment_choice", "gift_choice", "pause", "game_over_intro"] and _stream_frame_bgm_path() != ""

func _sync_gameplay_bgm() -> void:
	if gameplay_bgm_player == null:
		return
	if not _gameplay_bgm_should_play():
		gameplay_bgm_player.stream_paused = false
		if gameplay_bgm_player.playing:
			gameplay_bgm_player.stop()
		_apply_bgm_volumes()
		return
	var next_path := _stream_frame_bgm_path()
	if next_path != gameplay_bgm_path:
		gameplay_bgm_path = next_path
		gameplay_bgm_player.stream = _load_looping_audio_stream(gameplay_bgm_path)
		if gameplay_bgm_player.playing:
			gameplay_bgm_player.stop()
	if gameplay_bgm_player.stream != null and not gameplay_bgm_player.playing:
		gameplay_bgm_player.play()
	if boss_bgm_mix <= 0.001:
		gameplay_bgm_player.stream_paused = false
	_apply_bgm_volumes()

func _boss_bgm_can_fade() -> bool:
	return state in ["playing", "comment_choice", "gift_choice", "pause", "game_over_intro"]

func _boss_bgm_should_play() -> bool:
	return boss_active and _boss_bgm_can_fade()

func _sync_boss_bgm(delta: float) -> void:
	if boss_bgm_player == null:
		return
	var should_play: bool = _boss_bgm_should_play() and boss_bgm_player.stream != null
	if not should_play and not _boss_bgm_can_fade():
		boss_bgm_mix = 0.0
		if boss_bgm_player.playing:
			boss_bgm_player.stop()
		if gameplay_bgm_player != null:
			gameplay_bgm_player.stream_paused = false
		_apply_bgm_volumes()
		return
	if should_play:
		if not boss_bgm_player.playing:
			boss_bgm_player.play()
		if boss_bgm_mix < 0.999 and gameplay_bgm_player != null:
			gameplay_bgm_player.stream_paused = false
	elif boss_bgm_mix > 0.001:
		_resume_gameplay_bgm_after_boss()
	var target_mix: float = 1.0 if should_play else 0.0
	var step: float = 1.0 if delta <= 0.0 else delta / BOSS_BGM_FADE_DURATION
	boss_bgm_mix = move_toward(boss_bgm_mix, target_mix, step)
	if should_play and boss_bgm_mix >= 0.999:
		boss_bgm_mix = 1.0
		_pause_gameplay_bgm_for_boss()
	elif not should_play and boss_bgm_mix <= 0.001:
		boss_bgm_mix = 0.0
		if boss_bgm_player.playing:
			boss_bgm_player.stop()
		if gameplay_bgm_player != null:
			gameplay_bgm_player.stream_paused = false
	_apply_bgm_volumes()

func _pause_gameplay_bgm_for_boss() -> void:
	if gameplay_bgm_player == null:
		return
	if gameplay_bgm_player.playing:
		gameplay_bgm_player.stream_paused = true

func _resume_gameplay_bgm_after_boss() -> void:
	if gameplay_bgm_player == null or not _gameplay_bgm_should_play():
		return
	if gameplay_bgm_player.stream == null:
		return
	if not gameplay_bgm_player.playing:
		gameplay_bgm_player.play()
	gameplay_bgm_player.stream_paused = false

func _apply_bgm_volumes() -> void:
	if gameplay_bgm_player != null:
		gameplay_bgm_player.volume_db = _bgm_volume_db_for_scale(1.0 - boss_bgm_mix)
	if boss_bgm_player != null:
		boss_bgm_player.volume_db = _bgm_volume_db_for_scale(boss_bgm_mix)

func _bgm_volume_db_for_scale(scale: float) -> float:
	var normalized: float = float(SettingsSystemScript.normalized_volume(bgm_volume)) / 100.0
	var value: float = normalized * clampf(scale, 0.0, 1.0)
	if value <= 0.001:
		return -80.0
	return linear_to_db(value)

func _play_cursor_move_se() -> void:
	if ui_se_player == null or ui_se_player.stream == null:
		return
	ui_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if ui_se_player.playing:
		ui_se_player.stop()
	ui_se_player.play()

func _play_confirm_se() -> void:
	if confirm_se_player == null or confirm_se_player.stream == null:
		return
	confirm_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if confirm_se_player.playing:
		confirm_se_player.stop()
	confirm_se_player.play()

func _play_laser_se() -> void:
	if laser_se_player == null or laser_se_player.stream == null:
		return
	laser_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if laser_se_player.playing:
		laser_se_player.stop()
	laser_se_player.play()

func _play_ban_hammer_se() -> void:
	if ban_hammer_se_player == null or ban_hammer_se_player.stream == null:
		return
	ban_hammer_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if ban_hammer_se_player.playing:
		ban_hammer_se_player.stop()
	ban_hammer_se_player.play()

func _play_superchat_shot_se() -> void:
	if superchat_shot_se_player == null or superchat_shot_se_player.stream == null:
		return
	superchat_shot_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if superchat_shot_se_player.playing:
		superchat_shot_se_player.stop()
	superchat_shot_se_player.play()

func _play_marshmallow_pickup_se() -> void:
	if marshmallow_pickup_se_player == null or marshmallow_pickup_se_player.stream == null:
		return
	marshmallow_pickup_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if marshmallow_pickup_se_player.playing:
		marshmallow_pickup_se_player.stop()
	marshmallow_pickup_se_player.play()

func _play_kuso_marshmallow_pickup_se() -> void:
	if kuso_marshmallow_pickup_se_player == null or kuso_marshmallow_pickup_se_player.stream == null:
		return
	kuso_marshmallow_pickup_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if kuso_marshmallow_pickup_se_player.playing:
		kuso_marshmallow_pickup_se_player.stop()
	kuso_marshmallow_pickup_se_player.play()

func _cursor_sound_snapshot() -> Dictionary:
	return {
		"state": state,
		"titleMenu": title_menu_index,
		"optionMenu": option_menu_index,
		"character": selected_character_index,
		"streamFrame": selected_stream_frame_index,
		"rankingTab": ranking_tab_index,
		"rankingSelected": ranking_selected_index,
		"pauseMenu": pause_menu_index,
		"choiceCard": selected_card,
		"resultHover": result_hover_button
	}

func _cursor_sound_snapshot_changed(before: Dictionary) -> bool:
	if String(before.get("state", "")) != state:
		return false
	for key in [
		"titleMenu",
		"optionMenu",
		"character",
		"streamFrame",
		"rankingTab",
		"rankingSelected",
		"pauseMenu",
		"choiceCard",
		"resultHover"
	]:
		if before.get(key) != _cursor_sound_snapshot().get(key):
			return true
	return false

func _unhandled_input(event: InputEvent) -> void:
	if state == "game_over_intro":
		if event is InputEventMouseButton:
			var skip_mouse_button := event as InputEventMouseButton
			if skip_mouse_button.button_index == MOUSE_BUTTON_LEFT and skip_mouse_button.pressed and _game_over_intro_can_skip():
				_finish_run(pending_game_over_reason)
				get_viewport().set_input_as_handled()
				return
	if state == "result" and _result_drop_is_playing():
		return
	if state == "title":
		if event is InputEventMouseMotion:
			_update_title_mouse_selection((event as InputEventMouseMotion).position)
		elif event is InputEventMouseButton:
			var mouse_button := event as InputEventMouseButton
			if mouse_button.button_index == MOUSE_BUTTON_LEFT and mouse_button.pressed:
				var index: int = _title_button_index_at(mouse_button.position)
				if index >= 0:
					title_menu_index = index
					_activate_title_menu_index(index)
					get_viewport().set_input_as_handled()
	elif state == "character_select":
		if event is InputEventMouseMotion:
			_update_character_select_mouse_selection((event as InputEventMouseMotion).position)
		elif event is InputEventMouseButton:
			var select_mouse_button := event as InputEventMouseButton
			if select_mouse_button.button_index == MOUSE_BUTTON_LEFT and select_mouse_button.pressed:
				if _activate_character_select_mouse(select_mouse_button.position):
					get_viewport().set_input_as_handled()
	elif state == "stream_frame_select":
		if event is InputEventMouseMotion:
			_update_stream_frame_select_mouse_selection((event as InputEventMouseMotion).position)
		elif event is InputEventMouseButton:
			var frame_mouse_button := event as InputEventMouseButton
			if frame_mouse_button.button_index == MOUSE_BUTTON_LEFT and frame_mouse_button.pressed:
				if _activate_stream_frame_select_mouse(frame_mouse_button.position):
					get_viewport().set_input_as_handled()
	elif state == "result" and not result_showing_ranking:
		if event is InputEventMouseMotion:
			_update_result_mouse_selection((event as InputEventMouseMotion).position)
		elif event is InputEventMouseButton:
			var result_mouse_button := event as InputEventMouseButton
			if result_mouse_button.button_index == MOUSE_BUTTON_LEFT and result_mouse_button.pressed:
				if _activate_result_mouse(result_mouse_button.position):
					get_viewport().set_input_as_handled()

func _update_title_mouse_selection(pos: Vector2) -> void:
	var index: int = _title_button_index_at(pos)
	if index < 0 or index == title_menu_index:
		return
	title_menu_index = index
	_play_cursor_move_se()
	queue_redraw()

func _title_button_index_at(pos: Vector2) -> int:
	for i in range(3):
		if _title_button_hit_rect(i).has_point(pos):
			return i
	return -1

func _title_button_hit_rect(index: int) -> Rect2:
	var source_rect: Rect2 = _title_button_source_rect(index)
	var scale := Vector2(TITLE_BUTTON_RECT.size.x / TITLE_BUTTON_SOURCE_SIZE.x, TITLE_BUTTON_RECT.size.y / TITLE_BUTTON_SOURCE_SIZE.y)
	return Rect2(TITLE_BUTTON_RECT.position + source_rect.position * scale, source_rect.size * scale)

func _title_button_source_rect(index: int) -> Rect2:
	if index == 0:
		return Rect2(Vector2(8, 8), Vector2(1058, 285))
	if index == 1:
		return Rect2(Vector2(8, 337), Vector2(1058, 286))
	return Rect2(Vector2(8, 666), Vector2(1057, 286))

func _activate_title_menu_index(index: int) -> void:
	_play_confirm_se()
	if index == 0:
		_start_character_select()
	elif index == 1:
		_open_title_ranking()
	elif index == 2:
		_open_title_options()

func _update_character_select_mouse_selection(pos: Vector2) -> void:
	var index: int = _character_select_index_at(pos)
	if index < 0 or index == selected_character_index:
		return
	selected_character_index = index
	_play_cursor_move_se()
	queue_redraw()

func _activate_character_select_mouse(pos: Vector2) -> bool:
	var layout: Dictionary = _character_select_layout()
	if (layout["confirmButton"] as Rect2).has_point(pos):
		_confirm_character_select()
		return true
	if (layout["backButton"] as Rect2).has_point(pos):
		_play_confirm_se()
		_back_to_title()
		return true
	if (layout["prevButton"] as Rect2).has_point(pos):
		_move_character_select_page(-1)
		return true
	if (layout["nextButton"] as Rect2).has_point(pos):
		_move_character_select_page(1)
		return true
	var index: int = _character_select_index_at(pos)
	if index >= 0:
		selected_character_index = index
		queue_redraw()
		return true
	return false

func _character_select_index_at(pos: Vector2) -> int:
	if characters.is_empty():
		return -1
	var page: int = CharacterSystemScript.selection_page_for_index(selected_character_index, characters.size())
	var start: int = page * CharacterSystemScript.SELECT_PAGE_SIZE
	for local_index in range(CharacterSystemScript.SELECT_PAGE_SIZE):
		var index: int = start + local_index
		if index >= characters.size():
			break
		if _character_select_card_rect(local_index).has_point(pos):
			return index
	return -1

func _move_character_select_page(direction: int) -> void:
	if characters.is_empty():
		return
	var page: int = CharacterSystemScript.selection_page_for_index(selected_character_index, characters.size())
	var page_count: int = CharacterSystemScript.selection_page_count(characters.size())
	var next_page: int = clampi(page + direction, 0, page_count - 1)
	if next_page == page:
		return
	selected_character_index = CharacterSystemScript.selection_index_for_page(characters, next_page, 0)
	queue_redraw()

func _confirm_character_select() -> void:
	var selected: Dictionary = CharacterSystemScript.selected_character_state_by_index(characters, selected_character_index)
	if selected.is_empty():
		return
	var character: Dictionary = selected["character"] as Dictionary
	if not CharacterSystemScript.is_unlocked(character):
		return
	_play_confirm_se()
	current_character_id = String(selected["characterId"])
	if relay_mode:
		_start_stream_start_intro()
		return
	_start_stream_frame_select()

func _stream_frame_selection_items() -> Array:
	return StreamFrameSystemScript.selection_frames(stream_frames, relay_mode_unlocked)

func _update_stream_frame_select_mouse_selection(pos: Vector2) -> void:
	var index: int = _stream_frame_select_index_at(pos)
	if index < 0 or index == selected_stream_frame_index:
		return
	selected_stream_frame_index = index
	_play_cursor_move_se()
	queue_redraw()

func _activate_stream_frame_select_mouse(pos: Vector2) -> bool:
	var layout: Dictionary = _stream_frame_select_layout()
	if (layout["confirmButton"] as Rect2).has_point(pos):
		_confirm_stream_frame_select()
		return true
	if (layout["backButton"] as Rect2).has_point(pos):
		_play_confirm_se()
		_start_character_select()
		return true
	if (layout["prevButton"] as Rect2).has_point(pos):
		_move_stream_frame_select_page(-1)
		return true
	if (layout["nextButton"] as Rect2).has_point(pos):
		_move_stream_frame_select_page(1)
		return true
	var index: int = _stream_frame_select_index_at(pos)
	if index >= 0:
		selected_stream_frame_index = index
		queue_redraw()
		return true
	return false

func _stream_frame_select_index_at(pos: Vector2) -> int:
	var frames: Array = _stream_frame_selection_items()
	if frames.is_empty():
		return -1
	var page: int = StreamFrameSystemScript.selection_page_for_index(selected_stream_frame_index, frames.size())
	var start: int = page * StreamFrameSystemScript.SELECT_PAGE_SIZE
	for local_index in range(StreamFrameSystemScript.SELECT_PAGE_SIZE):
		var index: int = start + local_index
		if index >= frames.size():
			break
		if _stream_frame_select_card_rect(local_index).has_point(pos):
			return index
	return -1

func _move_stream_frame_select_page(direction: int) -> void:
	var frames: Array = _stream_frame_selection_items()
	if frames.is_empty():
		return
	var page: int = StreamFrameSystemScript.selection_page_for_index(selected_stream_frame_index, frames.size())
	var page_count: int = StreamFrameSystemScript.selection_page_count(frames.size())
	var next_page: int = clampi(page + direction, 0, page_count - 1)
	if next_page == page:
		return
	selected_stream_frame_index = StreamFrameSystemScript.selection_index_for_page(frames, next_page, 0)
	queue_redraw()

func _confirm_stream_frame_select() -> void:
	var frames: Array = _stream_frame_selection_items()
	var selected: Dictionary = StreamFrameSystemScript.selected_frame_state_by_index(frames, selected_stream_frame_index)
	if selected.is_empty():
		return
	var frame: Dictionary = selected["frame"] as Dictionary
	if not StreamFrameSystemScript.is_selectable(frame):
		return
	_play_confirm_se()
	if bool(frame.get("isRelayMode", false)):
		relay_mode = true
		quick_test_mode = false
	else:
		relay_mode = false
		current_stream_frame = frame
		current_stream_frame_id = String(selected["frameId"])
	_start_stream_start_intro()

func _start_stream_start_intro() -> void:
	state = "stream_start_intro"
	stream_start_intro_timer = STREAM_START_INTRO_DURATION
	choice_box.visible = false
	result_panel.visible = false
	queue_redraw()

func _update_stream_start_intro(delta: float) -> void:
	stream_start_intro_timer = maxf(0.0, stream_start_intro_timer - delta)
	if stream_start_intro_timer <= 0.0:
		_restart()

func _start_game_over_intro(reason: String) -> void:
	_start_ending_cutin(reason, "mental_breakdown")

func _start_stream_complete_intro(reason: String) -> void:
	_start_ending_cutin(reason, "completed")

func _start_ending_cutin(reason: String, end_type: String) -> void:
	if state == "result" or state == "game_over_intro":
		return
	pending_game_over_reason = reason
	if pending_game_over_reason == "":
		pending_game_over_reason = current_death_text
	pending_game_over_end_type = end_type
	game_over_intro_duration = GAME_OVER_INTRO_COMPLETE_DURATION if end_type == "completed" else GAME_OVER_INTRO_MENTAL_DURATION
	game_over_intro_timer = game_over_intro_duration
	state = "game_over_intro"
	previous_state = "playing"
	choice_box.visible = false
	result_panel.visible = false
	var reaction_lines: Array[String] = _ending_cutin_reaction_lines(end_type)
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": reaction_lines}, chat_box)
	queue_redraw()

func _update_game_over_intro(delta: float) -> void:
	game_over_intro_timer = maxf(0.0, game_over_intro_timer - delta)
	if game_over_intro_timer <= 0.0 or _game_over_intro_skip_pressed():
		_finish_run(pending_game_over_reason)

func _ending_cutin_reaction_lines(end_type: String) -> Array[String]:
	if end_type == "completed":
		return [
			"888888",
			"完走おめ！",
			"神回だった",
			"ナイス配信！"
		]
	return [
		"あっ",
		"終わった",
		"メンタルが……",
		"これは事故"
	]

func _game_over_intro_elapsed() -> float:
	return maxf(0.0, game_over_intro_duration - game_over_intro_timer)

func _game_over_intro_can_skip() -> bool:
	return state == "game_over_intro" and _game_over_intro_elapsed() >= GAME_OVER_INTRO_SKIP_DELAY

func _game_over_intro_skip_pressed() -> bool:
	if not _game_over_intro_can_skip():
		return false
	return Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_SPACE)

func _stream_start_intro_display_name() -> String:
	if relay_mode:
		return "配信リレー"
	var display_name := String(current_stream_frame.get("displayName", ""))
	return display_name if display_name != "" else "配信枠"

func _result_layout() -> Dictionary:
	var offset := _result_drop_offset()
	return {
		"panel": Rect2(Vector2(210, 74) + offset, Vector2(1180, 746)),
		"summaryPanel": Rect2(Vector2(246, 260) + offset, Vector2(360, 450)),
		"detailPanel": Rect2(Vector2(626, 260) + offset, Vector2(728, 450)),
		"retryButton": Rect2(Vector2(300, 742) + offset, Vector2(330, 56)),
		"rankingButton": Rect2(Vector2(660, 742) + offset, Vector2(260, 56)),
		"titleButton": Rect2(Vector2(950, 742) + offset, Vector2(310, 56))
	}

func _result_drop_is_playing() -> bool:
	return result_drop_timer > 0.0

func _update_result_drop(delta: float) -> void:
	result_drop_timer = maxf(0.0, result_drop_timer - delta)

func _result_drop_offset() -> Vector2:
	if result_drop_timer <= 0.0 or result_showing_ranking:
		return Vector2.ZERO
	var progress := clampf((RESULT_DROP_DURATION - result_drop_timer) / RESULT_DROP_DURATION, 0.0, 1.0)
	var eased := 1.0 - pow(1.0 - progress, 3.0)
	var y := lerpf(RESULT_DROP_START_Y, 0.0, eased)
	if progress > 0.82:
		var settle := (progress - 0.82) / 0.18
		y += sin(settle * PI) * 16.0
	return Vector2(0.0, y)

func _activate_result_mouse(pos: Vector2) -> bool:
	var button_id: String = _result_button_at(pos)
	return _activate_result_button(button_id)

func _activate_result_button(button_id: String) -> bool:
	if button_id == "retry":
		_play_confirm_se()
		_restart()
		return true
	if button_id == "ranking":
		_play_confirm_se()
		_toggle_result_ranking()
		return true
	if button_id == "title":
		_play_confirm_se()
		_back_to_title()
		return true
	return false

func _update_result_mouse_selection(pos: Vector2) -> void:
	var button_id: String = _result_button_at(pos)
	if button_id == "":
		return
	if button_id == result_hover_button:
		return
	result_hover_button = button_id
	_play_cursor_move_se()
	queue_redraw()

func _result_button_at(pos: Vector2) -> String:
	var layout: Dictionary = _result_layout()
	if (layout["retryButton"] as Rect2).has_point(pos):
		return "retry"
	if (layout["rankingButton"] as Rect2).has_point(pos):
		return "ranking"
	if (layout["titleButton"] as Rect2).has_point(pos):
		return "title"
	return ""

func _result_button_ids() -> Array[String]:
	return ["retry", "ranking", "title"]

func _result_button_index(button_id: String) -> int:
	var ids := _result_button_ids()
	var index := ids.find(button_id)
	return 0 if index < 0 else index

func _normalize_result_button_selection() -> void:
	if not _result_button_ids().has(result_hover_button):
		result_hover_button = "retry"

func _move_result_button(direction: int) -> void:
	if result_showing_ranking:
		return
	var ids := _result_button_ids()
	var index := _result_button_index(result_hover_button)
	result_hover_button = String(ids[posmod(index + direction, ids.size())])
	queue_redraw()

func _select_result_button() -> void:
	if result_showing_ranking:
		return
	_normalize_result_button_selection()
	_activate_result_button(result_hover_button)

func _result_prev_button() -> void:
	_move_result_button(-1)

func _result_next_button() -> void:
	_move_result_button(1)

func _update_active_state(delta: float) -> void:
	var cursor_before: Dictionary = _cursor_sound_snapshot()
	StateFlowSystemScript.apply_active_update(state, {
		"comment_choice": Callable(self, "_update_comment_choice").bind(delta),
		"gift_choice": Callable(self, "_update_gift_choice"),
		"world": Callable(self, "_update_world").bind(delta)
	})
	if _cursor_sound_snapshot_changed(cursor_before):
		_play_cursor_move_se()

func _update_front_state(delta: float) -> bool:
	var cursor_before: Dictionary = _cursor_sound_snapshot()
	if state == "pause":
		_update_pause_menu(delta)
		if _cursor_sound_snapshot_changed(cursor_before):
			_play_cursor_move_se()
		_update_ui()
		queue_redraw()
		return true
	if state == "stream_start_intro":
		_update_stream_start_intro(delta)
		_update_ui()
		queue_redraw()
		return true
	if state == "game_over_intro":
		_update_game_over_intro(delta)
		_update_ui()
		queue_redraw()
		return true
	if state == "result" and _result_drop_is_playing():
		_update_result_drop(delta)
		_update_ui()
		queue_redraw()
		return true
	var ranking_action: String = DebugSystemScript.ranking_action(debug_key_latch) if (state == "ranking" or (state == "result" and result_showing_ranking)) else ""
	var title_action: String = DebugSystemScript.title_action(debug_key_latch) if state == "title" else ""
	var result_action: String = DebugSystemScript.result_action(debug_key_latch) if state == "result" and not result_showing_ranking else ""
	var options_action: String = DebugSystemScript.options_action(debug_key_latch) if state == "options" else ""
	var result: Dictionary = StateFlowSystemScript.front_state_action_for_target(self, delta, title_action, result_action, ranking_action, options_action)
	if not bool(result["handled"]):
		return false
	var action: String = String(result["action"])
	if action in ["start_character_select", "open_title_ranking", "open_title_options"]:
		_play_confirm_se()
	if state == "options" and options_action == "option_select":
		_play_confirm_se()
	StateFlowSystemScript.apply_front_action(action, {
		"start_character_select": Callable(self, "_start_character_select"),
		"open_title_ranking": Callable(self, "_open_title_ranking"),
		"open_title_options": Callable(self, "_open_title_options"),
		"reset_title_ranking": Callable(self, "_reset_title_ranking"),
		"ranking_tab_left": Callable(self, "_ranking_tab_left"),
		"ranking_tab_right": Callable(self, "_ranking_tab_right"),
		"ranking_up": Callable(self, "_ranking_up"),
		"ranking_down": Callable(self, "_ranking_down"),
		"ranking_select": Callable(self, "_ranking_select"),
		"back_to_title": Callable(self, "_back_to_title"),
		"update_character_select": Callable(self, "_update_character_select"),
		"update_stream_frame_select": Callable(self, "_update_stream_frame_select"),
		"result_prev_button": Callable(self, "_result_prev_button"),
		"result_next_button": Callable(self, "_result_next_button"),
		"result_select_button": Callable(self, "_select_result_button"),
		"toggle_ranking": Callable(self, "_toggle_result_ranking"),
		"restart": Callable(self, "_restart")
	})
	if state == "options":
		_refresh_options_screen()
	if _cursor_sound_snapshot_changed(cursor_before):
		_play_cursor_move_se()
	_update_ui()
	queue_redraw()
	return true

func _update_window_resize_lock() -> void:
	if pending_window_resize_lock_frames <= 0:
		return
	pending_window_resize_lock_frames -= 1
	if pending_window_resize_lock_frames > 0:
		return
	SettingsSystemScript.lock_window_resize()
	if state == "options":
		_refresh_options_screen()

func _draw_screen_backdrop() -> void:
	var data: Dictionary = DrawDataSystemScript.screen_backdrop_data()
	_draw_mask_rect(data["rect"] as Rect2, data["color"] as Color)

func _draw_modal_dim() -> void:
	var data: Dictionary = DrawDataSystemScript.modal_dim_data(FIELD_VIEW)
	_draw_mask_rect(data["rect"] as Rect2, data["color"] as Color)

func _world_camera_offset() -> Vector2:
	var desired: Vector2 = player_pos - FIELD_VIEW.get_center()
	var min_offset: Vector2 = ARENA.position - FIELD_VIEW.position
	var max_offset: Vector2 = ARENA.end - FIELD_VIEW.end
	return Vector2(
		roundf(clampf(desired.x, min_offset.x, max_offset.x)),
		roundf(clampf(desired.y, min_offset.y, max_offset.y))
	)

func _world_zoom_scale() -> float:
	var zoom_power: float = ModifierSystemScript.effect_rate_for_target(self, "zoom_in")
	if zoom_power <= 0.0:
		return 1.0
	return lerpf(1.0, 1.34, clampf(zoom_power, 0.0, 1.0))

func _update_world_zoom(delta: float) -> void:
	world_zoom_target = _world_zoom_scale()
	var zoom_speed: float = 5.8 if world_zoom_target > world_zoom else 4.2
	world_zoom = lerpf(world_zoom, world_zoom_target, 1.0 - exp(-zoom_speed * delta))
	if absf(world_zoom - world_zoom_target) < 0.001:
		world_zoom = world_zoom_target

func _world_transform_position() -> Vector2:
	var center: Vector2 = FIELD_VIEW.get_center()
	return center - (world_camera_offset + center) * world_zoom

func _apply_world_transform() -> void:
	draw_set_transform(_world_transform_position(), 0.0, Vector2(world_zoom, world_zoom))

func _reset_world_transform() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _screen_pos(world_pos: Vector2) -> Vector2:
	if not world_draw_active:
		return world_pos
	return world_pos * world_zoom + _world_transform_position()

func _draw_field_clip_masks() -> void:
	var fill: Color = (DrawDataSystemScript.screen_backdrop_data()["color"] as Color)
	draw_rect(Rect2(Vector2.ZERO, Vector2(1600.0, FIELD_VIEW.position.y)), fill, true)
	draw_rect(Rect2(Vector2.ZERO, Vector2(FIELD_VIEW.position.x, 900.0)), fill, true)
	draw_rect(Rect2(Vector2(FIELD_VIEW.end.x, 0.0), Vector2(1600.0 - FIELD_VIEW.end.x, 900.0)), fill, true)
	draw_rect(Rect2(Vector2(0.0, FIELD_VIEW.end.y), Vector2(1600.0, 900.0 - FIELD_VIEW.end.y)), fill, true)

func _draw() -> void:
	if _draws_title_only():
		_draw_screen_backdrop()
	else:
		_draw_world_layer()
	_draw_overlay_layer()
	_draw_toast()

func _draws_title_only() -> bool:
	return state in ["title", "ranking", "options", "character_select", "stream_frame_select", "stream_start_intro"]

func _draw_world_layer() -> void:
	_draw_screen_backdrop()
	world_camera_offset = _world_camera_offset()
	world_draw_active = true
	_apply_world_transform()
	_draw_arena()
	_draw_boss_slow_fields()
	_draw_hit_fx(true)
	_draw_exp()
	_draw_mallow()
	_draw_drop_items()
	_draw_destructibles()
	_draw_enemy_bullets()
	_draw_player_bullets()
	_draw_enemies()
	_draw_boomerang()
	_draw_player()
	_draw_hit_fx(false)
	_draw_map_foreground()
	world_draw_active = false
	_reset_world_transform()
	_draw_field_clip_masks()
	_draw_frames()

func _draw_overlay_layer() -> void:
	if StateFlowSystemScript.has_modal_overlay(state) and not _draws_title_only():
		_draw_modal_dim()
	var overlay_view: String = StateFlowSystemScript.overlay_view(state)
	if overlay_view == "title":
		_draw_title_overlay()
	elif overlay_view == "ranking":
		_draw_ranking_overlay()
	elif overlay_view == "options":
		_draw_options_overlay()
	elif overlay_view == "character_select":
		_draw_character_select_overlay()
	elif overlay_view == "stream_frame_select":
		_draw_stream_frame_select_overlay()
	elif overlay_view == "stream_start_intro":
		_draw_stream_start_intro_overlay()
	elif overlay_view == "game_over_intro":
		_draw_game_over_intro_overlay()
	elif overlay_view == "tutorial":
		_draw_tutorial_overlay_v2()
	elif overlay_view == "pause":
		_draw_pause_overlay()
	elif overlay_view == "choice":
		_draw_choice_backplate()
		if state == "gift_choice":
			_draw_gift_choice_card_contents()
		elif state == "comment_choice":
			_draw_comment_choice_card_contents()
	if not _draws_title_only():
		for special_overlay in DrawDataSystemScript.special_overlay_views(self):
			if String(special_overlay) == "comment_storm":
				_draw_comment_storm()
			elif String(special_overlay) == "horror":
				_draw_horror_mask()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if state == "playing":
		_draw_boss_overlay()
	if StateFlowSystemScript.shows_comment_countdown(state):
		_draw_comment_countdown()
	if state == "result" and result_showing_ranking:
		_draw_ranking_overlay()
	elif state == "result":
		_draw_result_overlay()

func _build_ui() -> void:
	var nodes: Dictionary = UiBuilderSystemScript.build_ui(self, Callable(self, "_choose_index"), UiStyleSystemScript.initial_result_panel_style())
	title_label = nodes["titleLabel"] as Label
	banner_label = nodes["bannerLabel"] as Label
	choice_box = nodes["choiceBox"] as HBoxContainer
	choice_buttons.clear()
	for button_item in (nodes["choiceButtons"] as Array):
		choice_buttons.append(button_item as Button)
	chat_title_label = nodes["chatTitleLabel"] as Label
	chat_box = nodes["chatBox"] as VBoxContainer
	status_label = nodes["statusLabel"] as Label
	result_panel = nodes["resultPanel"] as PanelContainer
	result_label = nodes["resultLabel"] as Label

func _update_world(delta: float) -> void:
	var run_length := RunStateSystemScript.run_length(quick_test_mode, QUICK_RUN_LENGTH, NORMAL_RUN_LENGTH)
	var previous_remaining := maxf(0.0, run_length - elapsed)
	elapsed += delta
	if elapsed >= run_length:
		if relay_mode:
			_advance_relay_frame()
			return
		_start_stream_complete_intro("配信成功！3分間生き残った。")
		return
	_update_time_announcements(previous_remaining, run_length)

	var had_banana_floor := ModifierSystemScript.has_effect_for_target(self, "banana_floor")
	var effect_result: Dictionary = ModifierSystemScript.update_effect_timer_for_target(self, delta)
	var has_banana_floor := ModifierSystemScript.has_effect_for_target(self, "banana_floor")
	_update_banana_floor_transition(delta, had_banana_floor, has_banana_floor, bool(effect_result["cleared"]))
	if bool(effect_result["clearBonus"]):
		var bonus_text: String = "指示コメ完走ボーナス！"
		chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": [bonus_text], "toasts": [bonus_text]}, chat_box)

	if _update_comment_timer(delta):
		return

	_update_stream_frame_events(delta)
	_update_world_systems(delta)
	_update_ui()

func _update_comment_timer(delta: float) -> bool:
	var result: Dictionary = CommentSystemScript.update_spawn_timer_for_target(self, delta)
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, result, chat_box)
	if bool(result["shouldStart"]):
		comment_choice_enter_time = 0.0
		var choice_result: Dictionary = CommentSystemScript.start_choice_ui_for_target(self, comments, rng, CHOICE_TIME, choice_box)
		chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": [String(choice_result["chat"])]}, chat_box)
		_refresh_choice_cards()
		return true
	return false

func _update_time_announcements(previous_remaining: float, run_length: float) -> void:
	var remaining := maxf(0.0, run_length - elapsed)
	_maybe_time_mark_announcement("2min", previous_remaining, remaining, run_length, 120.0, "【アナウンス】配信終了まで残り2分！")
	_maybe_time_mark_announcement("1min", previous_remaining, remaining, run_length, 60.0, "【アナウンス】配信終了まで残り1分！")
	if remaining > 10.0:
		return
	var second := int(ceil(remaining))
	if second < 1 or second > 10 or second == last_countdown_announcement_second:
		return
	last_countdown_announcement_second = second
	_push_time_announcement("【カウントダウン】終了まで %d！" % second, 0.92)

func _maybe_time_mark_announcement(key: String, previous_remaining: float, remaining: float, run_length: float, mark: float, text: String) -> void:
	if run_length <= mark or bool(time_announcement_flags.get(key, false)):
		return
	if previous_remaining >= mark and remaining < mark:
		time_announcement_flags[key] = true
		_push_time_announcement(text, 1.5)

func _push_time_announcement(text: String, toast_seconds: float) -> void:
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": [text], "toasts": [text]}, chat_box, toast_seconds)

func _reset_time_announcements() -> void:
	time_announcement_flags.clear()
	last_countdown_announcement_second = -1

func _update_stream_frame_events(delta: float) -> void:
	var marshmallow_feedback: Dictionary = MarshmallowSystemScript.update_auto_spawn_if_enabled_for_target(self, current_stream_frame, marshmallow_data, rng, ARENA, effect_walls)
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, marshmallow_feedback, chat_box)
	_update_genre_event(delta)

func _update_world_systems(delta: float) -> void:
	_update_player(delta)
	if state != "playing":
		return
	_apply_damage_feedback(ModifierSystemScript.update_stage_hazard_damage_for_target(self, ARENA))
	if state != "playing":
		return
	_update_spawning(delta)
	_update_boss(delta)
	_update_enemies(delta)
	if state != "playing":
		return
	_update_destructibles(delta)
	_update_weapons(delta)
	var exp_result: Dictionary = ExpSystemScript.update_world_for_target(self, delta)
	if bool(exp_result["levelUp"]):
		pending_gift_choices += int(exp_result.get("levelUps", 1))
		_start_gift_choice()
	_update_marshmallow(delta)
	var hit_fx_feedback: Dictionary = WeaponSystemScript.update_hit_fx_for_target(self, delta, ARENA, rng)
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, hit_fx_feedback, chat_box)
	if state == "playing" and pending_gift_choices > 0:
		_start_gift_choice()

func _update_boss(delta: float) -> void:
	var feedback: Dictionary = BossSystemScript.update_for_target(self, delta, ARENA, rng)
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, feedback, chat_box)

func _update_genre_event(delta: float) -> void:
	var feedback: Dictionary = GenreEventSystemScript.update_world_if_enabled_for_target(self, current_stream_frame, delta, genre_events, ARENA, rng)
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, feedback, chat_box)

func _start_character_select() -> void:
	var result: Dictionary = CharacterSystemScript.start_selection_for_target(self, choice_box, result_panel, characters)
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": [String(result["chat"])]}, chat_box)
	if bool(result["restart"]):
		_restart()

func _update_character_select() -> void:
	var result: Dictionary = CharacterSystemScript.update_selection_for_target(self, debug_key_latch, characters)
	if bool(result["startStreamFrameSelect"]):
		_play_confirm_se()
		_start_stream_frame_select()

func _start_stream_frame_select() -> void:
	var result: Dictionary = StreamFrameSystemScript.start_selection_for_target(self, choice_box, result_panel, stream_frames)
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": [String(result["chat"])]}, chat_box)
	if bool(result["restart"]):
		_restart()

func _update_stream_frame_select() -> void:
	var result: Dictionary = StreamFrameSystemScript.update_selection_for_target(self, debug_key_latch, stream_frames)
	var chat: String = String(result.get("chat", ""))
	if chat != "":
		chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": [chat]}, chat_box)
	if bool(result["backToCharacterSelect"]):
		_start_character_select()
		return
	if bool(result["restart"]):
		_play_confirm_se()
		_start_stream_start_intro()

func _open_title_ranking() -> void:
	state = "ranking"
	ranking_tab_index = 0
	ranking_selected_index = 0
	choice_box.visible = false
	result_panel.visible = false
	_refresh_ranking_screen()

func _reset_title_ranking() -> void:
	RankingSystemScript.reset_rankings()
	ranking_selected_index = 0
	if state == "ranking" or (state == "result" and result_showing_ranking):
		_refresh_ranking_screen()

func _refresh_ranking_screen() -> void:
	var footer: String = "←→：タブ  ↑↓：記録  Esc / Backspace：タイトルへ戻る  R：ランキングリセット"
	if state == "result" and result_showing_ranking:
		footer = "←→：タブ  ↑↓：記録  R：リザルトへ戻る  Enter / Space：もう一回"
	result_label.text = RankingSystemScript.format_ranking_screen(ranking_tab_index, ranking_selected_index, relay_mode_unlocked) + "\n\n" + footer
	if state == "ranking" or (state == "result" and result_showing_ranking):
		result_panel.visible = false

func _ranking_tab_left() -> void:
	ranking_tab_index = RankingSystemScript.clamp_tab_index(ranking_tab_index - 1, relay_mode_unlocked)
	ranking_selected_index = 0
	_refresh_ranking_screen()

func _ranking_tab_right() -> void:
	ranking_tab_index = RankingSystemScript.clamp_tab_index(ranking_tab_index + 1, relay_mode_unlocked)
	ranking_selected_index = 0
	_refresh_ranking_screen()

func _ranking_up() -> void:
	var count: int = RankingSystemScript.entry_count_for_tab(ranking_tab_index, relay_mode_unlocked)
	if count <= 0:
		ranking_selected_index = 0
	else:
		ranking_selected_index = posmod(ranking_selected_index - 1, count)
	_refresh_ranking_screen()

func _ranking_down() -> void:
	var count: int = RankingSystemScript.entry_count_for_tab(ranking_tab_index, relay_mode_unlocked)
	if count <= 0:
		ranking_selected_index = 0
	else:
		ranking_selected_index = posmod(ranking_selected_index + 1, count)
	_refresh_ranking_screen()

func _ranking_select() -> void:
	_refresh_ranking_screen()

func _open_title_options() -> void:
	state = "options"
	choice_box.visible = false
	result_panel.visible = false
	_refresh_options_screen()

func _refresh_options_screen() -> void:
	result_label.text = ""
	result_panel.visible = false

func _back_to_title() -> void:
	state = "title"
	game_over_intro_timer = 0.0
	game_over_intro_duration = 0.0
	result_drop_timer = 0.0
	pending_game_over_reason = ""
	pending_game_over_end_type = ""
	banana_floor_appear_timer = 0.0
	banana_floor_rollback_timer = 0.0
	banana_floor_was_active = false
	choice_box.visible = false
	result_panel.visible = false
	_update_title_screen_visibility()

func _update_player(delta: float) -> void:
	var result: Dictionary = PlayerSystemScript.update_for_target(self, delta, ARENA)
	if bool(result["stoppedDamage"]):
		_damage_player("stopped moving")
	_update_banana_slip_fx(delta)

func _update_banana_slip_fx(delta: float) -> void:
	if not ModifierSystemScript.has_effect_for_target(self, "banana_floor"):
		banana_slip_fx_timer = 0.0
		return
	if player_vel.length() < 80.0:
		banana_slip_fx_timer = maxf(0.0, banana_slip_fx_timer - delta)
		return
	banana_slip_fx_timer -= delta
	if banana_slip_fx_timer > 0.0:
		return
	banana_slip_fx_timer = 0.07
	var dir: Vector2 = player_vel.normalized()
	var side: Vector2 = Vector2(-dir.y, dir.x)
	var foot_pos: Vector2 = player_pos + Vector2(0, 22) - dir * 9.0 + side * rng.randf_range(-9.0, 9.0)
	hit_fx.append({
		"kind": "banana_slip",
		"pos": foot_pos,
		"dir": -dir,
		"life": 0.34,
		"maxLife": 0.34,
		"side": side,
		"seed": rng.randf_range(0.0, TAU)
	})

func _start_banana_floor_appear() -> void:
	banana_floor_appear_timer = BANANA_FLOOR_APPEAR_DURATION
	banana_floor_rollback_timer = 0.0
	banana_floor_was_active = true

func _update_banana_floor_transition(delta: float, had_banana_floor: bool, has_banana_floor: bool, effect_cleared: bool) -> void:
	if has_banana_floor and not banana_floor_was_active:
		_start_banana_floor_appear()
	if had_banana_floor and effect_cleared:
		banana_floor_appear_timer = 0.0
		banana_floor_rollback_timer = BANANA_FLOOR_ROLLBACK_DURATION
		banana_floor_was_active = false
		return
	if has_banana_floor:
		banana_floor_rollback_timer = 0.0
		if banana_floor_appear_timer > 0.0:
			banana_floor_appear_timer = maxf(0.0, banana_floor_appear_timer - delta)
		banana_floor_was_active = true
		return
	banana_floor_appear_timer = 0.0
	if banana_floor_rollback_timer > 0.0:
		banana_floor_rollback_timer = maxf(0.0, banana_floor_rollback_timer - delta)
	banana_floor_was_active = false

func _banana_floor_appear_progress() -> float:
	if banana_floor_appear_timer <= 0.0:
		return 1.0
	return clampf(1.0 - banana_floor_appear_timer / BANANA_FLOOR_APPEAR_DURATION, 0.0, 1.0)

func _banana_floor_rollback_progress() -> float:
	if banana_floor_rollback_timer <= 0.0:
		return 1.0
	return clampf(1.0 - banana_floor_rollback_timer / BANANA_FLOOR_ROLLBACK_DURATION, 0.0, 1.0)

func _update_spawning(delta: float) -> void:
	SpawnerSystemScript.update_for_target(self, delta, ARENA, rng)

func _update_enemies(delta: float) -> void:
	var result: Dictionary = EnemySystemScript.update_world_for_target(self, delta, rng, ARENA)
	_apply_damage_feedback(DamageSystemScript.apply_damage_events_for_target(self, result.get("damageEvents", []) as Array))

func _update_weapons(delta: float) -> void:
	var result: Dictionary = WeaponSystemScript.update_for_target(self, delta, ARENA, rng)
	if _weapon_update_has_fx(result, "ng_word_laser"):
		_play_laser_se()
	if _weapon_update_has_hammer_swing(result):
		_play_ban_hammer_se()
	if bool(result.get("superchatShotFired", false)):
		_play_superchat_shot_se()
	var feedback: Dictionary = WeaponSystemScript.apply_update_result_for_target(self, result, ARENA, rng)
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, feedback, chat_box)

func _weapon_update_has_fx(result: Dictionary, kind: String) -> bool:
	for item in (result.get("hitFx", []) as Array):
		var fx: Dictionary = item as Dictionary
		if String(fx.get("kind", "")) == kind:
			return true
	return false

func _weapon_update_has_hammer_swing(result: Dictionary) -> bool:
	for item in (result.get("hitFx", []) as Array):
		var fx: Dictionary = item as Dictionary
		if bool(fx.get("hammer", false)):
			return true
	return false

func _damage_player(source: String) -> void:
	_apply_damage_feedback(DamageSystemScript.apply_damage_sources_for_target(self, [source]))

func _apply_damage_feedback(feedback: Dictionary) -> void:
	if state == "game_over_intro" or state == "result":
		return
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, feedback, chat_box)
	if bool(feedback["dead"]):
		_start_game_over_intro(String(feedback["deathReason"]))

func _update_comment_choice(delta: float) -> void:
	var result: Dictionary = CommentSystemScript.update_choice_input_for_target(self, delta, debug_key_latch, rng)
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, result, chat_box)
	if bool(result["refresh"]):
		_refresh_choice_cards()
		return
	if int(result["chooseIndex"]) >= 0:
		_choose_comment(int(result["chooseIndex"]))

func _choose_comment(index: int) -> void:
	var had_banana_floor := ModifierSystemScript.has_effect_for_target(self, "banana_floor")
	var result: Dictionary = CommentSystemScript.choose_comment_with_feedback_for_target(self, index, rng, ARENA, COMMENT_INTERVAL, choice_box, genre_events)
	if not bool(result["selected"]):
		return
	_play_confirm_se()
	_suppress_dash_button_after_ui_confirm()
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, result, chat_box)
	if not had_banana_floor and ModifierSystemScript.has_effect_for_target(self, "banana_floor"):
		_start_banana_floor_appear()

func _start_gift_choice() -> void:
	if pending_gift_choices <= 0:
		pending_gift_choices = 1
	pending_gift_choices -= 1
	gift_choice_enter_time = 0.0
	var result: Dictionary = GiftSystemScript.start_offer_ui_for_target(self, gifts, rng, choice_box)
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": [String(result["arrivalText"])]}, chat_box)
	_refresh_choice_cards()

func _update_gift_choice() -> void:
	var result: Dictionary = GiftSystemScript.update_choice_input_for_target(self, debug_key_latch)
	if bool(result["refresh"]):
		_refresh_choice_cards()
		return
	if int(result["chooseIndex"]) >= 0:
		_choose_gift(int(result["chooseIndex"]))

func _choose_gift(index: int) -> void:
	var result: Dictionary = GiftSystemScript.choose_offer_index_with_feedback_for_target(self, index, choice_box, genre_events, rng)
	if not bool(result["selected"]):
		return
	_play_confirm_se()
	_suppress_dash_button_after_ui_confirm()
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, result, chat_box)
	if pending_gift_choices > 0:
		_start_gift_choice()

func _suppress_dash_button_after_ui_confirm() -> void:
	dash_enter_down = Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_SPACE)

func _update_marshmallow(delta: float) -> void:
	var feedback: Dictionary = MarshmallowSystemScript.update_world_for_target(self, delta, ARENA, rng)
	if bool(feedback.get("kusoPickupSe", false)):
		_play_kuso_marshmallow_pickup_se()
	elif bool(feedback.get("goodPickupSe", false)):
		_play_marshmallow_pickup_se()
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, feedback, chat_box)
	if bool(feedback["levelUp"]):
		pending_gift_choices += int(feedback.get("levelUps", 1))
		_start_gift_choice()
	MarshmallowSystemScript.update_effect_timers_for_target(self, delta)

func _update_destructibles(delta: float) -> void:
	var feedback: Dictionary = DestructibleSystemScript.update_world_for_target(self, delta, ARENA, rng, effect_walls)
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, feedback, chat_box)

func _choose_index(index: int) -> void:
	if state == "comment_choice":
		_choose_comment(index)
	elif state == "gift_choice":
		_choose_gift(index)

func _refresh_choice_cards() -> void:
	_layout_choice_ui()
	ChoiceCardSystemScript.refresh_for_target(self, choice_buttons, state)
	_refresh_choice_button_icons()

func _layout_choice_ui() -> void:
	if choice_box == null:
		return
	if state == "gift_choice":
		choice_box.position = Vector2(386, 320) + _gift_choice_drop_offset()
		choice_box.add_theme_constant_override("separation", 24)
		for button_item in choice_buttons:
			var button: Button = button_item as Button
			button.custom_minimum_size = Vector2(206, 280)
	elif state == "comment_choice":
		choice_box.position = Vector2(326, 322) + _comment_choice_drop_offset()
		choice_box.add_theme_constant_override("separation", 13)
		for button_item in choice_buttons:
			var button: Button = button_item as Button
			button.custom_minimum_size = Vector2(265, 326)
	else:
		choice_box.position = Vector2(455, 150)
		choice_box.add_theme_constant_override("separation", 22)
		for button_item in choice_buttons:
			var button: Button = button_item as Button
			button.custom_minimum_size = Vector2(240, 315)

func _update_gift_choice_box_drop() -> void:
	if choice_box == null or state != "gift_choice":
		return
	choice_box.position = Vector2(386, 320) + _gift_choice_drop_offset()

func _update_comment_choice_box_drop() -> void:
	if choice_box == null or state != "comment_choice":
		return
	choice_box.position = Vector2(326, 322) + _comment_choice_drop_offset()

func _refresh_choice_button_icons() -> void:
	for i in range(choice_buttons.size()):
		var button: Button = choice_buttons[i]
		button.icon = null
		if state == "gift_choice" or state == "comment_choice":
			button.text = ""

func _update_ui() -> void:
	_update_title_screen_visibility()
	if state == "options":
		_refresh_options_screen()
	HudTextSystemScript.update_labels_for_target(
		self,
		status_label,
		banner_label,
		DisplayTextSystemScript.comment_barrage_label(comment_barrage_setting),
		GiftSystemScript.arrival_text(gift_hype),
		GenreEventSystemScript.label(active_genre_event),
		GenreEventSystemScript.label(next_known_genre_event)
	)

func _update_title_screen_visibility() -> void:
	var title_only := _draws_title_only()
	var hide_chat := title_only or state == "pause" or state == "result"
	title_label.visible = false
	chat_title_label.visible = false
	chat_box.visible = not hide_chat
	status_label.visible = false
	if state == "title" or state == "ranking" or state == "options" or state == "character_select" or state == "stream_frame_select" or state == "result":
		result_panel.visible = false
func _finish_run(reason: String) -> void:
	if state == "result":
		return
	if pending_game_over_end_type == "":
		pending_game_over_end_type = _end_type_for_finish_reason(reason)
	result_showing_ranking = false
	result_hover_button = "retry"
	result_drop_timer = RESULT_DROP_DURATION
	ResultSystemScript.open_result_ui_for_target(reason, self, quick_test_mode, choice_box, result_panel, result_label, heart_cards, chat_box)

func _end_type_for_finish_reason(reason: String) -> String:
	if reason.contains("成功") or reason.contains("完走") or player_hp > 0:
		return "completed"
	return "mental_breakdown"

func _toggle_result_ranking() -> void:
	result_showing_ranking = not result_showing_ranking
	result_hover_button = ""
	if result_showing_ranking:
		ranking_tab_index = 0
		ranking_selected_index = 0
		result_panel.visible = false
		_refresh_ranking_screen()
	else:
		result_hover_button = "retry"
		result_panel.visible = false
		result_label.text = last_result_text

func _update_pause_menu(delta: float) -> void:
	_update_pause_menu_navigation(delta)
	var action: String = DebugSystemScript.pause_action(debug_key_latch)
	if action == "":
		return
	if pause_confirm_action != "":
		if action == "pause_cancel":
			pause_confirm_action = ""
			return
		if action == "pause_confirm" or action == "pause_select":
			var confirmed_action: String = pause_confirm_action
			pause_confirm_action = ""
			if confirmed_action == "retry":
				_restart()
			elif confirmed_action == "title":
				_back_to_title()
			return
	if action == "pause_continue":
		pause_menu_index = 0
		_resume_from_pause()
	elif action == "pause_retry":
		pause_menu_index = 1
		pause_confirm_action = "retry"
	elif action == "pause_title":
		pause_menu_index = 2
		pause_confirm_action = "title"
	elif action == "pause_select":
		if pause_menu_index == 0:
			_resume_from_pause()
		elif pause_menu_index == 1:
			pause_confirm_action = "retry"
		else:
			pause_confirm_action = "title"

func _update_pause_menu_navigation(delta: float) -> void:
	if pause_confirm_action != "":
		pause_nav_repeat_timer = 0.0
		pause_nav_last_dir = 0
		return
	var dir: int = 0
	if Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_W):
		dir -= 1
	if Input.is_key_pressed(KEY_DOWN) or Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_S):
		dir += 1
	if dir == 0:
		pause_nav_repeat_timer = 0.0
		pause_nav_last_dir = 0
		return
	if dir != pause_nav_last_dir:
		pause_menu_index = posmod(pause_menu_index + dir, 3)
		pause_nav_last_dir = dir
		pause_nav_repeat_timer = 0.24
		return
	pause_nav_repeat_timer -= delta
	if pause_nav_repeat_timer <= 0.0:
		pause_menu_index = posmod(pause_menu_index + dir, 3)
		pause_nav_repeat_timer = 0.10

func _resume_from_pause() -> void:
	pause_confirm_action = ""
	pause_nav_repeat_timer = 0.0
	pause_nav_last_dir = 0
	state = previous_state if previous_state != "" and previous_state != "pause" else "playing"

func _draw_pause_overlay() -> void:
	var panel: Rect2 = Rect2(Vector2(245, 86), Vector2(1110, 680))
	draw_rect(panel, Color(0.97, 0.985, 1.0, 0.96))
	_draw_rect_outline(panel, Color("#ff5b9c"), 4)
	_draw_text_item({"pos": panel.position + Vector2(36, 52), "text": "ポーズ中", "width": 320, "size": 36, "color": Color("#e73763")})
	_draw_pause_status_panel(Rect2(panel.position + Vector2(32, 78), Vector2(1046, 88)))
	_draw_pause_equipment_panel(Rect2(panel.position + Vector2(32, 184), Vector2(506, 248)), true)
	_draw_pause_equipment_panel(Rect2(panel.position + Vector2(572, 184), Vector2(506, 248)), false)
	_draw_pause_instruction_panel(Rect2(panel.position + Vector2(32, 448), Vector2(506, 110)))
	_draw_pause_stream_rule_panel(Rect2(panel.position + Vector2(572, 448), Vector2(506, 110)))
	_draw_pause_controls_panel(Rect2(panel.position + Vector2(32, 574), Vector2(506, 74)))
	_draw_pause_menu_panel(Rect2(panel.position + Vector2(572, 574), Vector2(506, 74)))

func _draw_pause_status_panel(rect: Rect2) -> void:
	_draw_pause_box(rect, Color("#e9f7ff"))
	var remaining: float = maxf(0.0, RunStateSystemScript.run_length(quick_test_mode, QUICK_RUN_LENGTH, NORMAL_RUN_LENGTH) - elapsed)
	var status_text: String = "配信者：%s　配信枠：%s\n残り時間：%s　同時視聴者数：%d人　ボルテージ：x%.1f\n炎上コンボ：%d　ギフト期待度：%d%%　♡待機中：%s" % [
		String(current_character.get("displayName", "赤羽ばんり")),
		String(current_stream_frame.get("displayName", "雑談枠")),
		_format_pause_time(remaining),
		score,
		multiplier,
		burn_combo,
		gift_hype,
		"あり" if heart_pending else "なし"
	]
	_draw_multiline_text_item({"pos": rect.position + Vector2(18, 25), "text": status_text, "width": int(rect.size.x - 36), "size": 18, "color": Color("#142033")})

func _draw_pause_equipment_panel(rect: Rect2, is_weapon: bool) -> void:
	_draw_pause_box(rect, Color("#ffffff"))
	var title: String = "武器" if is_weapon else "アクセサリ"
	_draw_text_item({"pos": rect.position + Vector2(18, 32), "text": title, "width": 200, "size": 24, "color": Color("#1576bc")})
	var lines: Array[String] = _pause_equipment_lines(is_weapon)
	_draw_multiline_text_item({"pos": rect.position + Vector2(22, 64), "text": "\n".join(lines), "width": int(rect.size.x - 44), "size": 16, "color": Color("#162033")})

func _draw_pause_instruction_panel(rect: Rect2) -> void:
	_draw_pause_box(rect, Color("#fff9fb"))
	_draw_text_item({"pos": rect.position + Vector2(18, 30), "text": "現在の指示コメ", "width": 220, "size": 22, "color": Color("#e73763")})
	_draw_multiline_text_item({"pos": rect.position + Vector2(20, 58), "text": _pause_instruction_text(), "width": int(rect.size.x - 40), "size": 16, "color": Color("#142033")})

func _draw_pause_stream_rule_panel(rect: Rect2) -> void:
	_draw_pause_box(rect, Color("#fffdf5"))
	_draw_text_item({"pos": rect.position + Vector2(18, 30), "text": "配信枠ルール", "width": 220, "size": 22, "color": Color("#d97706")})
	_draw_multiline_text_item({"pos": rect.position + Vector2(20, 58), "text": _pause_stream_rule_text(), "width": int(rect.size.x - 40), "size": 16, "color": Color("#142033")})

func _draw_pause_controls_panel(rect: Rect2) -> void:
	_draw_pause_box(rect, Color("#f7fbff"))
	var text: String = "移動：WASD / 方向キー　ダッシュ：同じ方向を2回押し\n指示コメ選択：1 / 2 / 3　ポーズ：Esc"
	_draw_multiline_text_item({"pos": rect.position + Vector2(18, 29), "text": text, "width": int(rect.size.x - 36), "size": 16, "color": Color("#34445c")})

func _draw_pause_menu_panel(rect: Rect2) -> void:
	_draw_pause_box(rect, Color("#fff7fb"))
	if pause_confirm_action != "":
		var confirm_text: String = "現在の配信を終了します。よろしいですか？\nEnter / Space / Y：はい　N / Backspace：いいえ"
		_draw_multiline_text_item({"pos": rect.position + Vector2(18, 30), "text": confirm_text, "width": int(rect.size.x - 36), "size": 16, "color": Color("#e73763")})
		return
	var labels: Array[String] = ["続ける", "リトライ", "タイトルへ"]
	for i in range(labels.size()):
		var selected: bool = i == pause_menu_index
		var x: float = rect.position.x + 22.0 + float(i) * 155.0
		var item_rect: Rect2 = Rect2(Vector2(x, rect.position.y + 20.0), Vector2(136.0, 38.0))
		draw_rect(item_rect, Color("#ff5b9c") if selected else Color("#ffffff"))
		_draw_rect_outline(item_rect, Color("#ff5b9c"), 2)
		_draw_text_item({
			"pos": item_rect.position + Vector2(0, 26),
			"text": "[%d] %s" % [i + 1, labels[i]],
			"width": int(item_rect.size.x),
			"size": 17,
			"color": Color.WHITE if selected else Color("#142033")
		}, "", HORIZONTAL_ALIGNMENT_CENTER)

func _draw_pause_box(rect: Rect2, fill: Color) -> void:
	draw_rect(rect, fill)
	_draw_rect_outline(rect, Color("#aad4ff"), 2)

func _pause_equipment_lines(is_weapon: bool) -> Array[String]:
	var result: Array[String] = []
	var entries: Array = player_weapons if is_weapon else player_accessories
	for i in range(5):
		if i >= entries.size():
			result.append("%d. 空き" % [i + 1])
			result.append("")
			continue
		var entry: Dictionary = entries[i] as Dictionary
		var item_id: String = String(entry.get("id", ""))
		var data: Dictionary = WeaponSystemScript.find_weapon(weapons, item_id, {}) if is_weapon else _find_gift_data(item_id)
		var name: String = String(data.get("displayName", item_id))
		var desc: String = _short_pause_text(String(data.get("description", "")), 26)
		result.append("%d. %s Lv%d" % [i + 1, name, int(entry.get("level", 1))])
		result.append("   %s" % desc)
	return result

func _pause_instruction_text() -> String:
	if current_comment == "なし" or effect_timer <= 0.0:
		return "現在の指示コメ：なし"
	var lines: Array[String] = [
		"%s　残り%02d秒" % [current_comment, int(ceil(effect_timer))]
	]
	if active_effects.size() > 1:
		lines.append("発動中効果：%s" % _pause_active_effect_text())
	else:
		lines.append("効果：%s" % _pause_comment_description())
	return "\n".join(lines)

func _pause_stream_rule_text() -> String:
	var frame_id: String = String(current_stream_frame.get("id", current_stream_frame_id))
	if frame_id == "gameplay":
		return "ゲーム実況枠：一定時間ごとにジャンルイベントが発生します。\nレース風、弾幕風、ホラー風などが一時的に混ざります。"
	return "雑談枠：マシュマロが届く基本配信枠です。\n拾うとメリット効果、たまにクソマロが混ざります。"

func _pause_comment_description() -> String:
	var comment: Dictionary = _find_comment_data(last_comment_id)
	if comment.is_empty():
		return _pause_active_effect_text()
	var has_heart: bool = current_comment.ends_with("♡")
	var view: Dictionary = CommentSystemScript.comment_view(comment, has_heart)
	return _short_pause_text(String(view.get("description", _pause_active_effect_text())), 34)

func _pause_active_effect_text() -> String:
	if active_effects.is_empty():
		return "なし"
	var labels: Array[String] = []
	for item in active_effects:
		labels.append(_pause_effect_label(String(item)))
	return " / ".join(labels)

func _pause_effect_label(id: String) -> String:
	var labels: Dictionary = {
		"slippery_floor": "床すべり",
		"reverse_control": "操作混乱",
		"giant_enemies": "敵巨大化",
		"no_dash": "ダッシュ制限",
		"attack_right_only": "右寄り攻撃",
		"no_stop": "停止ダメージ",
		"no_brake": "慣性上昇",
		"enemy_speed_up": "敵高速化",
		"enemy_spawn_up": "敵出現増加",
		"weapon_mute": "武器ミュート",
		"hide_hp": "メンタル表示妨害",
		"comment_barrage": "コメント弾幕",
		"camera_zoom": "カメラズーム",
		"temp_walls": "一時壁",
		"damage_pits": "ダメージ床",
		"god_reservation": "神回予約"
	}
	return String(labels.get(id, id))

func _find_gift_data(id: String) -> Dictionary:
	for item in gifts:
		var gift: Dictionary = item as Dictionary
		if String(gift.get("id", "")) == id:
			return gift
	return {}

func _find_comment_data(id: String) -> Dictionary:
	for item in comments:
		var comment: Dictionary = item as Dictionary
		if String(comment.get("id", "")) == id:
			return comment
	return {}

func _format_pause_time(seconds: float) -> String:
	return "%02d:%02d" % [int(seconds) / 60, int(seconds) % 60]

func _short_pause_text(text: String, max_chars: int) -> String:
	var one_line: String = text.replace("\r", " ").replace("\n", " ").strip_edges()
	if one_line.length() <= max_chars:
		return one_line
	return one_line.substr(0, max_chars - 1) + "…"

func _restart() -> void:
	if relay_mode:
		_prepare_relay_start()
	game_over_intro_timer = 0.0
	game_over_intro_duration = 0.0
	result_drop_timer = 0.0
	pending_game_over_reason = ""
	pending_game_over_end_type = ""
	banana_floor_appear_timer = 0.0
	banana_floor_rollback_timer = 0.0
	banana_floor_was_active = false
	var restart_state: Dictionary = RunStateSystemScript.restart_run_for_target(
		self,
		characters,
		weapons,
		character_sprite_cache,
		tutorial_seen
	)
	if bool(restart_state["saveSettings"]):
		SettingsSystemScript.save_for_target(self)
	chat_lines = RunStateSystemScript.reset_run_ui_and_seed_chat(result_panel, choice_box, heart_cards, chat_lines, chat_box)
	BossSystemScript.reset_for_target(self)
	_reset_time_announcements()

func _prepare_relay_start() -> void:
	quick_test_mode = false
	relay_completed_frame_ids.clear()
	relay_cleared_frame_count = 0
	relay_total_score = 0
	relay_max_score = 0
	relay_max_multiplier = 1.0
	relay_max_burn_combo = 0
	current_stream_frame_id = "zatsudan"
	StreamFrameSystemScript.apply_selected_frame_for_target(self, stream_frames, current_stream_frame_id)

func _advance_relay_frame() -> void:
	relay_completed_frame_ids.append(current_stream_frame_id)
	relay_cleared_frame_count += 1
	relay_total_score = score
	relay_max_score = maxi(relay_max_score, score)
	relay_max_multiplier = maxf(relay_max_multiplier, max_multiplier)
	relay_max_burn_combo = maxi(relay_max_burn_combo, burn_combo_max)
	var next_id: String = String(current_stream_frame.get("nextUnlockFrameId", ""))
	if next_id == "":
		_start_stream_complete_intro("配信リレー完走！ 全枠突破！")
		return
	current_stream_frame_id = next_id
	StreamFrameSystemScript.apply_selected_frame_for_target(self, stream_frames, current_stream_frame_id)
	_start_next_relay_segment()

func _start_next_relay_segment() -> void:
	elapsed = 0.0
	comment_timer = COMMENT_INTERVAL
	comment_warning_step = 0
	effect_timer = 0.0
	spawn_timer = 0.2
	attack_timer = 0.25
	superchat_timer = 0.4
	banana_slip_fx_timer = 0.0
	banana_floor_appear_timer = 0.0
	banana_floor_rollback_timer = 0.0
	banana_floor_was_active = false
	next_mallow_time = 30.0
	stop_timer = 0.0
	mute_timer = 0.0
	toast_text = ""
	toast_timer = 0.0
	_reset_time_announcements()
	kuso_chat_timer = 0.0
	attack_jitter_timer = 0.0
	move_slow_timer = 0.0
	spawn_rate_timer = 0.0
	support_attack_timer = 0.0
	player_hp = mini(player_max_hp, player_hp + 2)
	gift_hype = int(floor(float(gift_hype) * 0.5))
	max_gift_hype = maxi(max_gift_hype, gift_hype)
	multiplier = 1.0
	burn_combo = 0
	current_comment = "なし"
	current_death_text = "発動中の指示コメなし"
	active_comment_hurt = false
	pending_clear_hype = 0
	active_effects.clear()
	active_effect_rates.clear()
	effect_walls.clear()
	effect_pits.clear()
	enemies.clear()
	enemy_bullets.clear()
	exp_orbs.clear()
	player_bullets.clear()
	boomerang_hits.clear()
	equipment_weapon_timers.clear()
	hit_fx.clear()
	BossSystemScript.reset_for_target(self)
	marshmallows.clear()
	destructibles.clear()
	drop_items.clear()
	next_destructible_uid = 1
	next_care_package_time = 15.0
	active_genre_event = ""
	genre_event_timer = 0.0
	genre_bullet_timer = 0.0
	genre_event_hurt = false
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": ["次の配信枠へ！ " + String(current_stream_frame.get("displayName", "配信枠"))]}, chat_box)

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
		var gift_result: Dictionary = DebugSystemScript.force_gift_choice_ui_for_target(self, gifts, forced_gift_rarity, rng, choice_box)
		_refresh_choice_cards()
		chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": [String(gift_result["chat"])]}, chat_box)
	var forced_comment_id: String = DebugSystemScript.forced_comment_id(action)
	if forced_comment_id != "" and state == "playing":
		_apply_forced_comment_debug(forced_comment_id, false)
	var forced_heart_id: String = DebugSystemScript.forced_heart_comment_id(action)
	if forced_heart_id != "" and state == "playing":
		_apply_forced_comment_debug(forced_heart_id, true)
	var marshmallow_kind: String = DebugSystemScript.marshmallow_kind(action)
	if marshmallow_kind != "" and state == "playing":
		var marshmallow_result: Dictionary = DebugSystemScript.force_marshmallow_for_target(self, marshmallow_data, marshmallow_kind, rng, ARENA, effect_walls)
		if bool(marshmallow_result["spawned"]):
			chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": [String(marshmallow_result["chat"])]}, chat_box)
	var result: Dictionary = DebugSystemScript.apply_general_action_for_target(self, action, quick_test_mode, ARENA, rng)
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, result, chat_box)

func _apply_forced_comment_debug(comment_id: String, has_heart: bool) -> void:
	var result: Dictionary = DebugSystemScript.force_comment_offer_for_target(self, comments, comment_id, has_heart)
	if bool(result["applied"]):
		_choose_comment(int(result["chooseIndex"]))

func _draw_shadow(pos: Vector2, size: Vector2, alpha: float = 0.28) -> void:
	DrawPrimitiveSystemScript.draw_shadow(self, pos, size, alpha)

func _draw_spark(pos: Vector2, size: float, color: Color) -> void:
	DrawPrimitiveSystemScript.draw_spark(self, pos, size, color)

func _draw_banana_item(item: Dictionary, color: Color) -> void:
	var pos: Vector2 = item["pos"] as Vector2
	var size: float = float(item.get("size", 16.0))
	var rotation: float = float(item.get("rotation", 0.0))
	var alpha: float = clampf(float(item.get("alpha", 1.0)), 0.0, 1.0)
	if alpha <= 0.01:
		return
	var texture_path: String = String(item.get("texturePath", ""))
	if texture_path != "":
		var texture: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, texture_path)
		if texture != null:
			var texture_size: Vector2 = texture.get_size()
			var draw_size: Vector2 = Vector2(size, size)
			if texture_size.x > 0.0 and texture_size.y > 0.0:
				draw_size.y = size * texture_size.y / texture_size.x
			_draw_shadow(pos + Vector2(0.0, draw_size.y * 0.22), Vector2(draw_size.x * 0.72, draw_size.y * 0.18), 0.13 * alpha)
			_draw_rotated_texture(texture, pos, draw_size, rotation, 0.96 * alpha)
			return
	var outline_color: Color = Color(1.0, 0.52, 0.02, 0.58)
	if item.has("outlineColor"):
		outline_color = item["outlineColor"] as Color
	outline_color.a *= alpha
	var banana_color := color
	banana_color.a *= alpha
	var shine_color := Color("#fff0a8")
	shine_color.a *= alpha
	var end_color := Color("#d48713")
	end_color.a *= alpha
	_draw_fixed_arc(pos, size + 2.5, rotation + 0.18, rotation + 2.75, 10, outline_color, 7.0)
	_draw_fixed_arc(pos, size, rotation + 0.2, rotation + 2.7, 10, banana_color, 5.0)
	draw_circle(pos + Vector2(cos(rotation + 0.24), sin(rotation + 0.24)) * size * 0.52, 2.2, shine_color)
	draw_circle(pos + Vector2(cos(rotation + 2.64), sin(rotation + 2.64)) * size * 0.52, 2.0, end_color)

func _draw_banana_roll_edge(data: Dictionary) -> void:
	var mode := String(data.get("transitionMode", ""))
	if mode == "":
		return
	var progress: float = float(data.get("transitionProgress", 0.0))
	var arena: Rect2 = data.get("arenaRect", ARENA) as Rect2
	var x: float = float(data.get("edgeX", data.get("rollX", arena.position.x)))
	var wobble: float = sin(elapsed * 10.0 + progress * TAU) * 2.5
	var edge_x := x + wobble
	var band_alpha := 0.22
	var warm_alpha := 0.30
	var shine_alpha := 0.66
	var side_alpha := 0.38
	if mode == "appear":
		band_alpha = 0.14
		warm_alpha = 0.16
		shine_alpha = 0.50
		side_alpha = 0.24
	var band := Rect2(Vector2(edge_x - 12.0, arena.position.y), Vector2(24.0, arena.size.y))
	draw_rect(band, Color(1.0, 0.82, 0.10, band_alpha), true)
	draw_line(Vector2(edge_x - 7.0, arena.position.y), Vector2(edge_x - 7.0, arena.end.y), Color(0.92, 0.48, 0.02, warm_alpha), 8.0)
	draw_line(Vector2(edge_x, arena.position.y), Vector2(edge_x, arena.end.y), Color(1.0, 0.95, 0.30, shine_alpha), 5.0)
	draw_line(Vector2(edge_x + 5.0, arena.position.y), Vector2(edge_x + 5.0, arena.end.y), Color(1.0, 0.54, 0.16, side_alpha), 3.0)
	for i in range(8):
		var y := arena.position.y + fmod(float(i) * 193.0 + elapsed * 62.0, arena.size.y)
		draw_line(Vector2(edge_x - 16.0, y), Vector2(edge_x + 16.0, y + 8.0), Color(1.0, 0.93, 0.45, 0.25 if mode == "rollback" else 0.16), 2.0)

func _draw_arena() -> void:
	var map_data: Dictionary = MapBackgroundSystemScript.background_data_for_stream_frame(current_stream_frame_id)
	var map_rect: Rect2 = MapBackgroundSystemScript.world_rect(map_data)
	var has_image_background := false
	if not _draw_map_background_image(MapBackgroundSystemScript.floor_path(map_data), map_rect):
		if _draw_map_background_image(MapBackgroundSystemScript.background_path(map_data), map_rect):
			has_image_background = true
		else:
			var background: Dictionary = DrawDataSystemScript.arena_background_data(ARENA)
			for part in DrawDataSystemScript.arena_background_parts(background):
				_draw_arena_part(part as Dictionary)
	else:
		has_image_background = true
	var has_banana_floor := ModifierSystemScript.has_effect_for_target(self, "banana_floor")
	var arena_effects: Dictionary = DrawDataSystemScript.arena_effect_data(ARENA, has_banana_floor, effect_pits, _banana_floor_rollback_progress(), _banana_floor_appear_progress())
	for part in DrawDataSystemScript.arena_effect_parts(arena_effects):
		_draw_arena_part(part as Dictionary)
	for wall in DrawDataSystemScript.arena_wall_draw_list(effect_walls, not has_image_background):
		var wall_item: Dictionary = wall as Dictionary
		_draw_arena_wall(wall_item["rect"] as Rect2, bool(wall_item["temporary"]))

func _draw_arena_wall(rect: Rect2, temporary: bool) -> void:
	var wall: Dictionary = DrawDataSystemScript.arena_wall_data(rect, temporary)
	wall["rect"] = rect
	for part in DrawDataSystemScript.arena_wall_parts(wall):
		_draw_arena_part(part as Dictionary)

func _draw_arena_part(part: Dictionary) -> void:
	var kind: String = String(part["kind"])
	if kind == "rect":
		_draw_rect_item(part["data"] as Dictionary)
	elif kind == "rect_prefix":
		_draw_rect_item(part["data"] as Dictionary, String(part["prefix"]))
	elif kind == "circle":
		_draw_circle_item(part["data"] as Dictionary)
	elif kind == "circle_prefix":
		_draw_circle_item(part["data"] as Dictionary, String(part["prefix"]))
	elif kind == "pit_image":
		_draw_pit_image(part["data"] as Dictionary)
	elif kind == "spark":
		var spark_item: Dictionary = part["data"] as Dictionary
		_draw_spark(spark_item["pos"] as Vector2, float(spark_item["size"]), spark_item["color"] as Color)
	elif kind == "banana":
		var banana_item: Dictionary = part["data"] as Dictionary
		if part.has("outlineColor"):
			banana_item["outlineColor"] = part["outlineColor"] as Color
		if part.has("texturePath"):
			banana_item["texturePath"] = String(part["texturePath"])
		_draw_banana_item(banana_item, part["color"] as Color)
	elif kind == "banana_roll_edge":
		_draw_banana_roll_edge(part["data"] as Dictionary)
	elif kind == "shadow":
		_draw_shadow(part["pos"] as Vector2, part["size"] as Vector2, float(part["alpha"]))
	elif kind == "outline":
		_draw_rect_outline(part["rect"] as Rect2, part["color"] as Color, int(part["width"]))
	elif kind == "line":
		_draw_line_item(part["data"] as Dictionary)

func _draw_pit_image(data: Dictionary) -> void:
	var texture: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, String(data.get("texturePath", "")))
	if texture == null:
		_draw_circle_item(data, "outer")
		_draw_circle_item(data, "inner")
		return
	var pos: Vector2 = data["pos"] as Vector2
	var size: Vector2 = data.get("textureSize", Vector2(float(data.get("radius", 36.0)) * 3.0, float(data.get("radius", 36.0)) * 2.45)) as Vector2
	var alpha: float = float(data.get("textureAlpha", 1.0))
	draw_texture_rect(texture, Rect2(pos - size * 0.5, size), false, Color(1.0, 1.0, 1.0, alpha))

func _draw_map_foreground() -> void:
	var map_data: Dictionary = MapBackgroundSystemScript.background_data_for_stream_frame(current_stream_frame_id)
	_draw_map_background_image(MapBackgroundSystemScript.props_path(map_data), MapBackgroundSystemScript.world_rect(map_data))

func _draw_player() -> void:
	if player_sprite != null:
		_draw_player_sprite()
		_draw_invincible_label()
		_draw_player_hp_bar()
		return
	_draw_player_fallback()
	_draw_invincible_label()
	_draw_player_hp_bar()

func _draw_player_fallback() -> void:
	var fallback: Dictionary = DrawDataSystemScript.fallback_player_draw_data(player_pos, current_character_id, invincible > 0.0)
	for part in DrawDataSystemScript.fallback_player_parts(fallback):
		_draw_simple_draw_part(fallback, part as Dictionary)

func _draw_player_sprite() -> void:
	var sprite_draw: Dictionary = DrawDataSystemScript.player_sprite_state(player_pos, player_vel, player_facing_x, player_sprite, player_idle_sprite, player_run_sprite, current_character, elapsed, attack_timer, hammer_interval, last_hammer_dir, invincible)
	_draw_shadow(sprite_draw["shadowPos"] as Vector2, sprite_draw["shadowSize"] as Vector2, float(sprite_draw["shadowAlpha"]))
	var size: Vector2 = sprite_draw["size"] as Vector2
	var transform_scale: Vector2 = Vector2(-1, 1) if bool(sprite_draw.get("flipX", false)) else Vector2.ONE
	if world_draw_active:
		transform_scale *= world_zoom
	draw_set_transform(_screen_pos(sprite_draw["center"] as Vector2), float(sprite_draw["tilt"]), transform_scale)
	draw_texture_rect_region(sprite_draw["texture"] as Texture2D, Rect2(-size * 0.5, size), sprite_draw["sourceRect"] as Rect2, Color(1, 1, 1, float(sprite_draw["alpha"])))
	if world_draw_active:
		_apply_world_transform()
	else:
		_reset_world_transform()

func _draw_invincible_label() -> void:
	if debug_invincible:
		var label: Dictionary = DrawDataSystemScript.invincible_label_data(player_pos)
		_draw_text_item(label)

func _draw_player_hp_bar() -> void:
	var hide_hp: bool = ModifierSystemScript.has_effect_for_target(self, "hide_hp")
	var bar: Dictionary = DrawDataSystemScript.player_hp_bar_data(player_pos, player_hp, player_max_hp, hide_hp, elapsed)
	for part in DrawDataSystemScript.player_hp_bar_parts():
		_draw_simple_draw_part(bar, part as Dictionary)

func _draw_enemies() -> void:
	EnemyDrawSystemScript.draw_enemies(self, enemies)

func _draw_exp() -> void:
	ExpDrawSystemScript.draw_exp_orbs(self, exp_orbs, elapsed)

func _draw_mallow() -> void:
	for item in DrawDataSystemScript.marshmallow_draw_list(marshmallows, elapsed, maro_appraisal):
		_draw_mallow_item(item as Dictionary)

func _draw_mallow_item(visual: Dictionary) -> void:
	var icon_path: String = String(visual.get("imagePath", ""))
	if icon_path != "":
		_draw_shadow(visual["shadowPos"] as Vector2, visual["shadowSize"] as Vector2, float(visual["shadowAlpha"]))
		_draw_field_icon(icon_path, visual["pos"] as Vector2, visual["imageSize"] as Vector2)
		if bool(visual["warning"]):
			_draw_text_item(visual, "warning")
		_draw_text_item(visual, "time", HORIZONTAL_ALIGNMENT_LEFT, null, "%02d" % int(ceil(float(visual["timeLeft"]))))
		if visual.has("speech") and not (visual["speech"] as Dictionary).is_empty():
			_draw_speech_bubble(visual["speech"] as Dictionary)
		return
	for part in DrawDataSystemScript.marshmallow_parts(visual):
		_draw_simple_draw_part(visual, part as Dictionary)

func _draw_destructibles() -> void:
	for item in destructibles:
		var box: Dictionary = item as Dictionary
		if float(box.get("hp", 0.0)) <= 0.0:
			continue
		_draw_care_package_box(box)

func _draw_care_package_box(box: Dictionary) -> void:
	var pos: Vector2 = Vector2(box["pos"])
	if _draw_field_icon(FieldPickupVisualSystemScript.care_package_box_icon_path(), pos, Vector2(68, 68)):
		return
	_draw_shadow(pos + Vector2(0, 19), Vector2(54, 16), 0.22)
	var body := Rect2(pos + Vector2(-22, -20), Vector2(44, 38))
	draw_rect(body, Color("#ffd772"), true)
	_draw_rect_outline(body, Color("#8b4b1d"), 3)
	draw_rect(Rect2(pos + Vector2(-4, -20), Vector2(8, 38)), Color("#ff5f8f"), true)
	draw_rect(Rect2(pos + Vector2(-22, -4), Vector2(44, 8)), Color("#ff5f8f"), true)
	_draw_line_item({"from": pos + Vector2(-18, -20), "to": pos + Vector2(0, -34), "color": Color("#ff79a8"), "width": 4.0})
	_draw_line_item({"from": pos + Vector2(18, -20), "to": pos + Vector2(0, -34), "color": Color("#ff79a8"), "width": 4.0})
	_draw_text_item({
		"label": "差",
		"labelPos": pos + Vector2(-10, 9),
		"labelColor": Color("#5a2f18"),
		"labelSize": 18,
		"labelWidth": -1
	}, "label")

func _draw_drop_items() -> void:
	for item in drop_items:
		var drop: Dictionary = item as Dictionary
		_draw_drop_item(drop)

func _draw_drop_item(drop: Dictionary) -> void:
	var pos: Vector2 = Vector2(drop["pos"])
	var id: String = String(drop["id"])
	var bob := sin(elapsed * 9.0 + pos.x * 0.02) * 3.0
	pos.y += bob
	var icon_path: String = FieldPickupVisualSystemScript.drop_item_icon_path(id)
	if icon_path != "":
		if _draw_field_icon(icon_path, pos, Vector2(48, 48)):
			return
	_draw_shadow(pos + Vector2(0, 15), Vector2(34, 9), 0.16)
	if id == "heal_drink":
		var rect := Rect2(pos + Vector2(-10, -17), Vector2(20, 32))
		draw_rect(rect, Color("#37e06d"), true)
		_draw_rect_outline(rect, Color.WHITE, 2)
		draw_rect(Rect2(pos + Vector2(-6, -21), Vector2(12, 5)), Color("#d7fff0"), true)
		_draw_text_item({"label": "メ", "labelPos": pos + Vector2(-8, 8), "labelColor": Color.WHITE, "labelSize": 12, "labelWidth": -1}, "label")
	elif id == "heart_drop":
		_draw_text_item({"label": "♡", "labelPos": pos + Vector2(-15, 15), "labelColor": Color("#ff4f9b"), "labelSize": 42, "labelWidth": -1}, "label")
	else:
		draw_circle(pos, 18.0, Color("#35d9ff"))
		draw_circle(pos, 11.0, Color("#e8fbff"))
		_draw_text_item({"label": "+人", "labelPos": pos + Vector2(-16, 6), "labelColor": Color("#006e96"), "labelSize": 14, "labelWidth": -1}, "label")

func _load_field_icon(path: String) -> Texture2D:
	return TextureCacheSystemScript.load_png_texture(field_pickup_icon_cache, path)

func _draw_field_icon(path: String, center: Vector2, size: Vector2, alpha: float = 1.0) -> bool:
	var texture: Texture2D = _load_field_icon(path)
	if texture == null:
		return false
	_draw_shadow(center + Vector2(0, size.y * 0.30), Vector2(size.x * 0.76, size.y * 0.18), 0.18 * alpha)
	draw_texture_rect(texture, Rect2(center - size * 0.5, size), false, Color(1.0, 1.0, 1.0, alpha))
	return true

func _draw_enemy_bullets() -> void:
	WeaponDrawSystemScript.draw_bullets(self, enemy_bullets, false)

func _draw_boss_slow_fields() -> void:
	for item in boss_slow_fields:
		var field: Dictionary = item as Dictionary
		var pos: Vector2 = Vector2(field.get("pos", Vector2.ZERO))
		var radius: float = float(field.get("radius", 90.0))
		var life: float = float(field.get("life", 0.0))
		var max_life: float = maxf(0.01, float(field.get("maxLife", 6.0)))
		var alpha: float = clampf(life / max_life, 0.0, 1.0)
		var pulse: float = 0.5 + sin(elapsed * 7.0 + pos.x * 0.01) * 0.5
		draw_circle(pos, radius, Color(1.0, 0.72, 0.88, 0.18 * alpha), true)
		draw_circle(pos, radius * 0.72, Color(0.50, 0.08, 0.46, 0.13 * alpha), true)
		draw_circle(pos, radius * (0.50 + pulse * 0.08), Color(1.0, 0.92, 0.96, 0.20 * alpha), false, 4.0)
		draw_circle(pos + Vector2(-radius * 0.28, -radius * 0.16), radius * 0.13, Color(0.22, 0.04, 0.26, 0.22 * alpha), true)
		draw_circle(pos + Vector2(radius * 0.30, radius * 0.12), radius * 0.10, Color(0.95, 0.20, 0.62, 0.24 * alpha), true)

func _draw_player_bullets() -> void:
	WeaponDrawSystemScript.draw_bullets(self, player_bullets, true)

func _draw_boomerang() -> void:
	WeaponDrawSystemScript.draw_boomerangs(
		self,
		player_pos,
		current_weapon,
		boomerang_level,
		hammer_range,
		elapsed,
		comment_boomerang_sprite,
		Callable(self, "_draw_rotated_texture")
	)

func _draw_boss_overlay() -> void:
	if boss_requested:
		_draw_boss_warning_overlay()
	if boss_active:
		_draw_boss_hp_overlay()

func _draw_boss_warning_overlay() -> void:
	var pulse: float = 0.5 + sin(float(Time.get_ticks_msec()) / 1000.0 * 11.0) * 0.5
	draw_rect(Rect2(Vector2.ZERO, Vector2(1600, 900)), Color(1.0, 0.0, 0.08, 0.06 + pulse * 0.05), true)
	var rect := Rect2(Vector2(338, 112), Vector2(704, 74))
	draw_rect(rect, Color(0.18, 0.0, 0.04, 0.86), true)
	_draw_rect_outline(rect, Color(1.0, 0.12, 0.24, 0.95), 4)
	_draw_text_item({"pos": rect.position + Vector2(26, 48), "text": "WARNING!", "width": 230, "size": 34, "color": Color("#ff436a")})
	_draw_text_item({"pos": rect.position + Vector2(260, 44), "text": boss_warning_text, "width": 360, "size": 25, "color": Color.WHITE})
	_draw_text_item({"pos": rect.position + Vector2(610, 45), "text": "%d" % maxi(1, int(ceil(boss_warning_timer))), "width": 60, "size": 29, "color": Color("#fff45c")})

func _draw_boss_hp_overlay() -> void:
	var boss: Dictionary = BossSystemScript.active_boss_for_target(self)
	if boss.is_empty():
		return
	var ratio: float = 0.0
	var max_hp: float = float(boss.get("max_hp", 1.0))
	if max_hp > 0.0:
		ratio = clampf(float(boss.get("hp", 0.0)) / max_hp, 0.0, 1.0)
	var rect := Rect2(Vector2(388, 112), Vector2(640, 50))
	draw_rect(rect, Color(1.0, 1.0, 1.0, 0.94), true)
	_draw_rect_outline(rect, Color("#c8b8ff"), 3)
	var bar_rect := Rect2(rect.position + Vector2(142, 25), Vector2(482, 14))
	draw_rect(bar_rect, Color("#241631"), true)
	draw_rect(Rect2(bar_rect.position, Vector2(bar_rect.size.x * ratio, bar_rect.size.y)), Color("#ff4f92"), true)
	_draw_rect_outline(bar_rect, Color("#6f55c8"), 2)
	_draw_text_item({"pos": rect.position + Vector2(18, 34), "text": String(boss.get("displayName", "超長文ニキ")), "width": 132, "size": 20, "color": Color("#332255")})
	_draw_text_item({"pos": rect.position + Vector2(516, 20), "text": "%d/%d" % [maxi(0, int(ceil(float(boss.get("hp", 0.0))))), int(ceil(max_hp))], "width": 108, "size": 14, "color": Color("#332255")})

func _draw_hit_fx(field_layer: bool = false) -> void:
	for fx in DrawDataSystemScript.hit_fx_draw_data(hit_fx):
		var data := fx as Dictionary
		var is_field_fx := String(data.get("kind", "")) == "emote_mine"
		if is_field_fx != field_layer:
			continue
		_draw_hit_fx_item(data)

func _draw_hit_fx_item(data: Dictionary) -> void:
	for part in DrawDataSystemScript.hit_fx_parts(data):
		_draw_simple_draw_part(data, part as Dictionary)
	_draw_hit_fx_texture(data)
	if bool(data.get("showHammer", false)):
		_draw_rotated_texture(ban_hammer_weapon_sprite, data["hammerPos"] as Vector2, data["hammerSize"] as Vector2, float(data["hammerAngle"]), float(data["hammerAlpha"]))

func _draw_hit_fx_texture(data: Dictionary) -> bool:
	var path: String = String(data.get("imagePath", ""))
	if path == "":
		return false
	var texture: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, path)
	if texture == null:
		return false
	var pos: Vector2 = Vector2(data.get("imagePos", data.get("pos", Vector2.ZERO)))
	var size: Vector2 = Vector2(data.get("imageSize", texture.get_size()))
	var alpha: float = float(data.get("imageAlpha", 1.0))
	draw_texture_rect(texture, Rect2(pos - size * 0.5, size), false, Color(1.0, 1.0, 1.0, alpha))
	return true

func _draw_simple_draw_part(data: Dictionary, part: Dictionary) -> void:
	DrawPrimitiveSystemScript.draw_simple_draw_part(self, data, part)

func _draw_frames() -> void:
	_draw_frames_v25()
	return
	var data: Dictionary = DrawDataSystemScript.hud_draw_data(SIDE, HUD, {
		"runLength": RunStateSystemScript.run_length(quick_test_mode, QUICK_RUN_LENGTH, NORMAL_RUN_LENGTH),
		"elapsed": elapsed,
		"expNeed": ExpSystemScript.current_need(exp_level),
		"hideHp": ModifierSystemScript.has_effect_for_target(self,"hide_hp"),
		"playerHp": player_hp,
		"playerMaxHp": player_max_hp,
		"score": score,
		"multiplier": multiplier,
		"burnCombo": burn_combo,
		"giftHype": gift_hype,
		"heartPending": heart_pending,
		"commentTimer": comment_timer,
		"effectTimer": effect_timer,
		"currentComment": current_comment,
		"streamFrameName": String(current_stream_frame.get("displayName", "雑談枠")),
		"playerWeapons": player_weapons,
		"playerAccessories": player_accessories,
		"expValue": exp_value
	})
	var frame: Dictionary = data["frame"] as Dictionary
	if not _draw_ui_part("res://assets/generated/ui_parts_v1/comment_panel_frame.png", SIDE.position - Vector2(10, 10)):
		_draw_prefixed_panel_rect(frame, "side")
		_draw_line_item(frame, "sideDivider")
	_draw_text_item(frame, "viewer")
	if not _draw_ui_part("res://assets/generated/ui_parts_v1/bottom_hud_frame.png", HUD.position - Vector2(10, 10)):
		_draw_prefixed_panel_rect(frame, "hud")
	var top_hud_image: bool = _draw_ui_part("res://assets/generated/ui_parts_v1/top_hud_frame.png", Vector2(20, 10))
	var bottom_hud_image: bool = _load_ui_part("res://assets/generated/ui_parts_v1/bottom_hud_frame.png") != null
	for metric in (data["metrics"] as Array):
		var metric_data: Dictionary = metric as Dictionary
		var metric_rect: Rect2 = metric_data["rect"] as Rect2
		var use_text_only: bool = (bottom_hud_image and metric_rect.position.y >= 790.0) or (top_hud_image and metric_rect.position.y < 120.0 and metric_rect.position.x < 630.0)
		var metric_parts: Array = DrawDataSystemScript.hud_metric_text_parts() if use_text_only else DrawDataSystemScript.hud_metric_parts()
		for part in metric_parts:
			_draw_simple_draw_part(metric as Dictionary, part as Dictionary)
	for gauge in (data["gauges"] as Array):
		var gauge_data: Dictionary = gauge as Dictionary
		if bottom_hud_image:
			var bottom_gauge: Dictionary = gauge_data.duplicate()
			bottom_gauge["backColor"] = Color(0, 0, 0, 0)
			bottom_gauge["label"] = ""
			_draw_bar_item(bottom_gauge)
		else:
			for part in DrawDataSystemScript.hud_gauge_parts():
				_draw_simple_draw_part(gauge_data, part as Dictionary)
	var equipment_parts: Array = DrawDataSystemScript.hud_metric_text_parts() if bottom_hud_image else DrawDataSystemScript.hud_metric_parts()
	for item in (data["equipment"] as Array):
		for part in equipment_parts:
			_draw_simple_draw_part(item as Dictionary, part as Dictionary)
	_draw_equipment_icons()

func _draw_frames_v25() -> void:
	var frame: Dictionary = DrawDataSystemScript.hud_frame_data(SIDE, HUD, score)
	var side_image_drawn := _draw_ui_part(COMMENT_PANEL_BG_V25, SIDE.position)
	if not side_image_drawn:
		_draw_prefixed_panel_rect(frame, "side")
		_draw_line_item(frame, "sideDivider")
		_draw_text_item({"pos": SIDE.position + Vector2(64, 44), "text": "COMMENT", "width": 210, "size": 30, "color": Color("#b46cff")})
		_draw_comment_input_panel_v25()
	_draw_comment_row_lines_v25()
	_draw_top_status_v25()
	_draw_instruction_countdown_v25()
	_draw_character_bust_panel_v25()
	_draw_current_instruction_panel_v25()
	_draw_bottom_hud_v25()
	_draw_equipment_icons()

func _draw_comment_input_panel_v25() -> void:
	var input_rect := Rect2(SIDE.position + Vector2(20, SIDE.size.y - 58), Vector2(SIDE.size.x - 72, 40))
	var send_rect := Rect2(Vector2(input_rect.end.x + 10, input_rect.position.y), Vector2(42, 40))
	draw_rect(input_rect, Color(1.0, 1.0, 1.0, 0.96), true)
	_draw_rect_outline(input_rect, Color("#b8d9ff"), 2)
	_draw_text_item({"pos": input_rect.position + Vector2(18, 27), "text": "コメントを入力...", "width": int(input_rect.size.x - 30), "size": 16, "color": Color("#7b8798")})
	draw_rect(send_rect, Color(1.0, 0.96, 0.99, 0.96), true)
	_draw_rect_outline(send_rect, Color("#ff5a9a"), 2)
	_draw_text_item({"pos": send_rect.position + Vector2(13, 28), "text": "▶", "width": 20, "size": 22, "color": Color("#ff4f92")})

func _draw_comment_row_lines_v25() -> void:
	var x1: float = SIDE.position.x + 20.0
	var x2: float = SIDE.end.x - 22.0
	var y: float = SIDE.position.y + 88.0
	var bottom: float = SIDE.position.y + SIDE.size.y - 120.0
	while y <= bottom:
		draw_line(Vector2(x1, y), Vector2(x2, y), Color("#cfdcf0"), 1.0)
		y += 38.0

func _draw_ui_card_v25(rect: Rect2, label: String, value: String, accent: Color, icon_text: String = "") -> void:
	draw_rect(rect, Color(1.0, 1.0, 1.0, 0.94), true)
	_draw_rect_outline(rect, Color("#ffc1da"), 2)
	draw_rect(Rect2(rect.position + Vector2(0, rect.size.y - 5), Vector2(rect.size.x, 5)), accent, true)
	if rect.size.y <= 64.0:
		_draw_compact_ui_card_text_v25(rect, label, value, accent, icon_text)
		return
	if icon_text != "":
		_draw_text_item({"pos": rect.position + Vector2(18, 47), "text": icon_text, "width": 42, "size": 31, "color": accent})
	var text_x: float = rect.position.x + (58.0 if icon_text != "" else 16.0)
	_draw_text_item({"pos": Vector2(text_x, rect.position.y + 30), "text": label, "width": int(rect.size.x - 30), "size": 15, "color": Color("#101420")})
	_draw_text_item({"pos": Vector2(text_x, rect.position.y + 65), "text": value, "width": int(rect.size.x - 28), "size": 27, "color": Color("#101420")})

func _draw_compact_ui_card_text_v25(rect: Rect2, label: String, value: String, accent: Color, icon_text: String = "") -> void:
	if icon_text != "":
		_draw_text_item({"pos": rect.position + Vector2(18, 42), "text": icon_text, "width": 38, "size": 28, "color": accent})
	var text_x: float = rect.position.x + (58.0 if icon_text != "" else 14.0)
	_draw_text_item({"pos": Vector2(text_x, rect.position.y + 24), "text": label, "width": int(rect.size.x - 28), "size": 14, "color": Color("#101420")})
	if value != "":
		_draw_text_item({"pos": Vector2(text_x, rect.position.y + 52), "text": value, "width": int(rect.size.x - 30), "size": 25, "color": Color("#101420")})

func _draw_equipment_panel_v25(rect: Rect2, label: String, accent: Color) -> void:
	draw_rect(rect, Color(1.0, 1.0, 1.0, 0.94), true)
	_draw_rect_outline(rect, Color("#ffc1da"), 2)
	draw_rect(Rect2(rect.position + Vector2(0, rect.size.y - 5), Vector2(rect.size.x, 5)), accent, true)
	var tab := Rect2(rect.position + Vector2(10, -1), Vector2(72, 23))
	draw_rect(tab, accent, true)
	_draw_text_item({"pos": tab.position + Vector2(12, 17), "text": label, "width": 54, "size": 14, "color": Color("#101420")})

func _viewer_hud_text() -> String:
	return "%s人が視聴中" % DrawDataSystemScript.format_viewer_count(score)

func _time_hud_text() -> String:
	var remaining: int = maxi(0, int(ceil(RunStateSystemScript.run_length(quick_test_mode, QUICK_RUN_LENGTH, NORMAL_RUN_LENGTH) - elapsed)))
	return "%02d:%02d" % [remaining / 60, remaining % 60]

func _current_instruction_hud_text() -> String:
	var text: String = current_comment.strip_edges()
	if text == "" or text == "なし":
		return "なし"
	return "%s　%02d秒" % [text, maxi(0, int(ceil(effect_timer)))]

func _draw_top_status_v25() -> void:
	_draw_ui_card_v25(Rect2(28, 18, 210, 80), "配信枠", String(current_stream_frame.get("displayName", "雑談枠")), Color("#6ee7f0"), "▣")
	_draw_ui_card_v25(Rect2(256, 18, 212, 80), "残り時間", _time_hud_text(), Color("#fff45c"), "◷")
	_draw_ui_card_v25(Rect2(486, 18, 210, 80), "ボルテージ", "x%.1f  炎上 %d" % [multiplier, burn_combo], Color("#ff6f91"), "ϟ")
	_draw_ui_card_v25(Rect2(714, 18, 260, 80), "同時視聴者数", _viewer_hud_text(), Color("#8df7ff"), "●●")

func _draw_instruction_countdown_v25() -> void:
	if state == "comment_choice" or state == "gift_choice" or state == "pause" or state == "result":
		return
	var left: float = maxf(0.0, comment_timer)
	var ratio: float = clampf(left / COMMENT_INTERVAL, 0.0, 1.0)
	var alert: bool = left <= 5.0
	var urgent: bool = left <= 3.0
	var rect := Rect2(Vector2(28, 126), Vector2(946, 54))
	var accent: Color = Color("#ff3f78") if alert else Color("#ff6fa8")
	var fill: Color = Color(1.0, 0.94, 0.97, 0.94) if not urgent else Color(1.0, 0.87, 0.90, 0.96)
	draw_rect(rect, fill, true)
	_draw_rect_outline(rect, Color("#ffc1da"), 2)
	var text_color: Color = Color("#ff245f") if alert else Color("#e73763")
	_draw_text_item({"pos": rect.position + Vector2(26, 35), "text": "⚠ 次の指示コメまで　あと %.1fs" % left, "width": 360, "size": 24, "color": text_color})
	var bar_back := Rect2(rect.position + Vector2(365, 21), Vector2(560, 14))
	draw_rect(bar_back, Color("#f2e6ef"), true)
	draw_rect(Rect2(bar_back.position, Vector2(bar_back.size.x * ratio, bar_back.size.y)), accent, true)

func _fit_texture_rect(container: Rect2, tex_size: Vector2) -> Rect2:
	if tex_size.x <= 0.0 or tex_size.y <= 0.0:
		return Rect2(container.position, Vector2.ZERO)
	var scale: float = minf(container.size.x / tex_size.x, container.size.y / tex_size.y)
	var size: Vector2 = tex_size * scale
	return Rect2(container.position + (container.size - size) * 0.5, size)

func _draw_character_bust_panel_v25() -> void:
	var rect := Rect2(Vector2(1006, 18), Vector2(230, 136))
	draw_rect(rect, Color(1.0, 0.95, 0.98, 0.94), true)
	_draw_rect_outline(rect, Color("#ffc1da"), 2)
	var sprite_path: String = String(current_character.get("sprite", ""))
	var tex: Texture2D = CharacterSystemScript.texture_from_cache(character_sprite_cache, sprite_path)
	if tex != null:
		draw_texture_rect(tex, _fit_texture_rect(rect.grow(-6), tex.get_size()), false)
	_draw_text_item({"pos": rect.position + Vector2(12, 124), "text": String(current_character.get("displayName", "")), "width": int(rect.size.x - 24), "size": 14, "color": Color("#e73763")})

func _draw_current_instruction_panel_v25() -> void:
	var rect := Rect2(Vector2(1268, 18), Vector2(320, 134))
	draw_rect(rect, Color(1.0, 1.0, 1.0, 0.94), true)
	_draw_rect_outline(rect, Color("#ffc1da"), 2)
	_draw_text_item({"pos": rect.position + Vector2(22, 39), "text": "現在の指示コメ", "width": 230, "size": 18, "color": Color("#101420")})
	_draw_text_item({"pos": rect.position + Vector2(22, 91), "text": _current_instruction_hud_text(), "width": 280, "size": 26, "color": Color("#101420")})

func _draw_bottom_hud_v25() -> void:
	_draw_prefixed_panel_rect({"hudRect": HUD, "hudFill": Color(0.985, 0.99, 1.0, 0.94), "hudBorder": Color("#b8d9ff"), "hudBorderWidth": 4}, "hud")
	_draw_ui_card_v25(Rect2(34, 806, 205, 62), "メンタル", _mental_hud_text(), Color("#4ade80"), "")
	var exp_need: int = maxi(1, ExpSystemScript.current_need(exp_level))
	_draw_ui_card_v25(Rect2(254, 806, 256, 62), "EXP", "Lv.%d  %d/%d" % [exp_level, exp_value, exp_need], Color("#27c4d9"), "★")
	_draw_ui_card_v25(Rect2(526, 806, 200, 62), "ギフト期待度", "%d%%" % gift_hype, Color("#ff5a78"), "▣")
	_draw_ui_card_v25(Rect2(742, 806, 190, 62), "♡ 状態", "待機" if heart_pending else "なし", Color("#ff91c8"), "♥")
	_draw_equipment_panel_v25(Rect2(952, 806, 270, 62), "武器", Color("#fff45c"))
	_draw_equipment_panel_v25(Rect2(1234, 806, 296, 62), "アクセサリ", Color("#8df7ff"))
	var exp_ratio: float = clampf(float(exp_value) / float(exp_need), 0.0, 1.0)
	var hype_ratio: float = clampf(float(gift_hype) / 100.0, 0.0, 1.0)
	draw_rect(Rect2(Vector2(270, 862), Vector2(220, 6)), Color("#d8ecff"), true)
	draw_rect(Rect2(Vector2(270, 862), Vector2(220 * exp_ratio, 6)), Color("#24c7d9"), true)
	draw_rect(Rect2(Vector2(542, 862), Vector2(168, 6)), Color("#ffe1eb"), true)
	draw_rect(Rect2(Vector2(542, 862), Vector2(168 * hype_ratio, 6)), DrawDataSystemScript.gift_hype_color(hype_ratio), true)

func _mental_hud_text() -> String:
	if ModifierSystemScript.has_effect_for_target(self, "hide_hp"):
		return "？？/？？"
	return "%d/%d" % [player_hp, player_max_hp]

func _draw_ui_part(path: String, pos: Vector2) -> bool:
	var texture: Texture2D = _load_ui_part(path)
	if texture == null:
		return false
	draw_texture(texture, pos)
	return true

func _draw_map_background_image(path: String, rect: Rect2) -> bool:
	var texture: Texture2D = _load_ui_part(path)
	if texture == null:
		return false
	draw_texture_rect(texture, rect, false)
	return true

func _load_ui_part(path: String) -> Texture2D:
	return TextureCacheSystemScript.load_resource_texture(ui_part_cache, path)

func _draw_equipment_icons() -> void:
	_draw_equipment_icon_row(player_weapons, weapons, Vector2(1008, 827), true)
	_draw_equipment_icon_row(player_accessories, gifts, Vector2(1304, 827), false)

func _draw_equipment_icon_row(items: Array, source_data: Array, start: Vector2, is_weapon: bool) -> void:
	var slot_size := Vector2(30, 30)
	var step := 40.0
	for i in range(5):
		var slot_rect := Rect2(start + Vector2(i * step, 0), slot_size)
		draw_rect(slot_rect, Color(1.0, 1.0, 1.0, 0.92), true)
		_draw_rect_outline(slot_rect, Color("#c6dfff"), 2)
		if i >= items.size():
			continue
		var entry: Dictionary = items[i] as Dictionary
		var id: String = String(entry.get("id", ""))
		var data: Dictionary = _find_equipment_icon_data(source_data, id)
		var texture: Texture2D = _load_equipment_icon(String(data.get("iconPath", "")))
		if texture != null:
			draw_texture_rect(texture, slot_rect.grow(-2), false)
		else:
			var fallback_text: String = DrawDataSystemScript.equipment_icon(id, is_weapon)
			_draw_text_item({"pos": slot_rect.position + Vector2(8, 22), "text": fallback_text, "width": 22, "size": 14, "color": Color("#1f2a3a")})
		_draw_text_item({
			"pos": slot_rect.position + Vector2(19, 28),
			"text": str(int(entry.get("level", 1))),
			"width": 20,
			"size": 11,
			"color": Color("#e73763")
		})

func _find_equipment_icon_data(source_data: Array, id: String) -> Dictionary:
	for item in source_data:
		var data: Dictionary = item as Dictionary
		if String(data.get("id", "")) == id:
			return data
	return {}

func _load_equipment_icon(path: String) -> Texture2D:
	return TextureCacheSystemScript.load_resource_texture(equipment_icon_cache, path)

func _draw_comment_countdown() -> void:
	return
	if state == "comment_choice" or state == "gift_choice":
		return
	var left: float = maxf(0.0, comment_timer)
	var data: Dictionary = DrawDataSystemScript.comment_countdown_data(left, COMMENT_INTERVAL, elapsed)
	for part in DrawDataSystemScript.comment_countdown_parts(data):
		_draw_simple_draw_part(data, part as Dictionary)

func _draw_title_image_overlay() -> bool:
	var background: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, TITLE_BACK_IMAGE)
	if background == null:
		return false
	draw_texture_rect(background, TITLE_SCREEN_RECT, false)
	_draw_title_image(TITLE_SUPANA_IMAGE, TITLE_SUPANA_RECT)
	_draw_title_image(TITLE_MARON_IMAGE, TITLE_MARON_RECT)
	_draw_title_image(TITLE_BANCHAN_IMAGE, TITLE_BANCHAN_RECT)
	_draw_title_image(TITLE_LOGO_IMAGE, TITLE_LOGO_RECT)
	_draw_title_image(TITLE_BUTTON_IMAGE, TITLE_BUTTON_RECT)
	_draw_title_button_selection()
	return true

func _draw_title_image(path: String, rect: Rect2) -> void:
	var texture: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, path)
	if texture == null:
		return
	draw_texture_rect(texture, rect, false)

func _draw_title_button_selection() -> void:
	var rect: Rect2 = _title_button_hit_rect(title_menu_index).grow(6.0)
	var pulse: float = 0.5 + sin(float(Time.get_ticks_msec()) / 1000.0 * 6.5) * 0.5
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1.0, 0.97, 0.45, 0.08 + pulse * 0.08)
	style.border_color = Color(1.0, 0.96, 0.25, 0.72 + pulse * 0.22)
	style.set_border_width_all(5)
	style.set_corner_radius_all(48)
	draw_style_box(style, rect)
	var outer_style := StyleBoxFlat.new()
	outer_style.bg_color = Color(1.0, 1.0, 1.0, 0.0)
	outer_style.border_color = Color(1.0, 1.0, 1.0, 0.20 + pulse * 0.16)
	outer_style.set_border_width_all(3)
	outer_style.set_corner_radius_all(56)
	draw_style_box(outer_style, rect.grow(8.0))

func _draw_title_overlay() -> void:
	if _draw_title_image_overlay():
		return
	var barrage_label: String = DisplayTextSystemScript.comment_barrage_label(comment_barrage_setting)
	var data: Dictionary = DrawDataSystemScript.title_overlay_data(barrage_label, screen_shake_enabled, title_menu_index)
	for part in DrawDataSystemScript.title_overlay_parts(data):
		_draw_overlay_part(part as Dictionary)

func _draw_ranking_overlay() -> void:
	var view: Dictionary = RankingSystemScript.ranking_view(ranking_tab_index, ranking_selected_index, relay_mode_unlocked)
	_draw_ranking_background()
	_draw_ranking_header(view)
	_draw_ranking_tabs(view["tabs"] as Array)
	var list_rect := Rect2(76, 174, 780, 660)
	var detail_rect := Rect2(876, 174, 648, 660)
	_draw_ranking_list_panel(list_rect, view)
	_draw_ranking_detail_panel(detail_rect, view)
	_draw_ranking_footer()

func _draw_ranking_background() -> void:
	var background: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, TITLE_BACK_IMAGE)
	if background != null:
		draw_texture_rect(background, TITLE_SCREEN_RECT, false, Color(1, 1, 1, 0.62))
	else:
		_draw_screen_backdrop()
	draw_rect(TITLE_SCREEN_RECT, Color(1.0, 0.92, 0.98, 0.56), true)
	draw_rect(TITLE_SCREEN_RECT, Color(1.0, 1.0, 1.0, 0.34), true)

func _draw_ranking_header(view: Dictionary) -> void:
	var rect := Rect2(76, 16, 1448, 68)
	_draw_ranking_panel(rect, Color(1, 1, 1, 0.94), Color("#ead7e9"), 22, 2, true)
	_draw_ranking_text(String(view.get("title", "ランキング")), rect.position + Vector2(96, 44), 34, Color("#4f3149"), 620)
	_draw_ranking_text("Esc：タイトルへ戻る", rect.position + Vector2(1000, 42), 20, Color("#6b4a63"), 210, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_ranking_text("R：リセット", rect.position + Vector2(1224, 42), 20, Color("#6b4a63"), 170, HORIZONTAL_ALIGNMENT_CENTER)
	draw_circle(rect.position + Vector2(48, 34), 22, Color("#fff4fb"))
	_draw_ranking_text("1", rect.position + Vector2(41, 44), 24, Color("#f05aa5"), 24, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_ranking_tabs(tabs: Array) -> void:
	var count: int = maxi(1, tabs.size())
	var gap := 12.0
	var total_width := 1448.0
	var tab_width := (total_width - gap * float(count - 1)) / float(count)
	var y := 100.0
	for index in range(tabs.size()):
		var tab: Dictionary = tabs[index] as Dictionary
		var rect := Rect2(76 + float(index) * (tab_width + gap), y, tab_width, 60)
		var selected: bool = bool(tab.get("selected", false))
		var locked: bool = bool(tab.get("locked", false))
		var fill := Color(1, 1, 1, 0.93)
		var border := Color("#e7d7e5")
		var text_color := Color("#5d3b56")
		if selected:
			fill = Color("#ff93cd")
			border = Color("#ff62b5")
			text_color = Color.WHITE
		elif locked:
			fill = Color("#f2eef2")
			text_color = Color("#9a8f98")
		_draw_ranking_panel(rect, fill, border, 18, 2, false)
		var label: String = _short_pause_text(String(tab.get("label", "")), 9)
		_draw_ranking_text(label, rect.position + Vector2(0, 38), 20, text_color, rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)
		if selected:
			var p1 := rect.position + Vector2(rect.size.x * 0.5 - 12.0, rect.size.y + 2.0)
			var p2 := rect.position + Vector2(rect.size.x * 0.5 + 12.0, rect.size.y + 2.0)
			var p3 := rect.position + Vector2(rect.size.x * 0.5, rect.size.y + 22.0)
			draw_colored_polygon(PackedVector2Array([p1, p2, p3]), Color("#ff62b5"))

func _draw_ranking_list_panel(panel: Rect2, view: Dictionary) -> void:
	_draw_ranking_panel(panel, Color(1, 1, 1, 0.93), Color("#ead7e9"), 24, 2, true)
	var title: String = "配信リレーランキング" if String(view.get("tabId", "")) == "relay" else "神回ランキング"
	_draw_ranking_text(title, panel.position + Vector2(30, 42), 28, Color("#7a3fb0"), panel.size.x - 60)
	var rows: Array = view.get("rows", []) as Array
	if bool(view.get("locked", false)) or bool(view.get("empty", false)):
		_draw_ranking_message(panel, view.get("messageLines", []) as Array)
		return
	var visible_count := 5
	var selected_index: int = int(view.get("selectedIndex", 0))
	var start: int = clampi(selected_index - 2, 0, maxi(0, rows.size() - visible_count))
	var row_y := panel.position.y + 74.0
	var row_height := 106.0
	for i in range(visible_count):
		var row_index: int = start + i
		if row_index >= rows.size():
			break
		var row: Dictionary = rows[row_index] as Dictionary
		var rect := Rect2(panel.position.x + 20, row_y + float(i) * (row_height + 10.0), panel.size.x - 46, row_height)
		_draw_ranking_row(rect, row)
	if rows.size() > visible_count:
		var bar_rect := Rect2(panel.end.x - 22, panel.position.y + 72, 8, panel.size.y - 104)
		draw_rect(bar_rect, Color("#f3deef"), true)
		var ratio: float = float(visible_count) / float(rows.size())
		var thumb_h: float = maxf(44.0, bar_rect.size.y * ratio)
		var denom: int = maxi(1, rows.size() - visible_count)
		var thumb_y: float = bar_rect.position.y + (bar_rect.size.y - thumb_h) * float(start) / float(denom)
		draw_rect(Rect2(bar_rect.position.x, thumb_y, bar_rect.size.x, thumb_h), Color("#ff7dbc"), true)

func _draw_ranking_row(rect: Rect2, row: Dictionary) -> void:
	var selected: bool = bool(row.get("selected", false))
	var accent: Color = row.get("accent", Color("#8d6be8")) as Color
	_draw_ranking_panel(
		rect,
		Color(1, 1, 1, 0.98),
		Color("#ff67b8") if selected else Color("#ead7e9"),
		18,
		4 if selected else 2,
		false
	)
	_draw_ranking_text(str(int(row.get("rank", 0))), rect.position + Vector2(24, 72), 48, accent, 64, HORIZONTAL_ALIGNMENT_CENTER)
	draw_arc(rect.position + Vector2(57, 54), 35, -PI * 0.82, PI * 0.82, 28, Color(accent.r, accent.g, accent.b, 0.34), 4)
	var avatar_pos := rect.position + Vector2(132, 54)
	_draw_ranking_character_avatar(avatar_pos, 36.0, row, accent)
	_draw_ranking_text(_short_pause_text(String(row.get("title", "")), 13), rect.position + Vector2(188, 36), 25, accent, 250)
	_draw_ranking_text(_short_pause_text(String(row.get("scoreText", "")), 18), rect.position + Vector2(188, 68), 26, Color("#ff4d9f"), 260)
	_draw_ranking_text(_short_pause_text(String(row.get("summary", "")), 48), rect.position + Vector2(390, 42), 16, Color("#6b4a63"), rect.size.x - 410)
	_draw_ranking_text(_short_pause_text(String(row.get("build", "")), 42), rect.position + Vector2(390, 74), 15, Color("#7a6d79"), rect.size.x - 410)

func _draw_ranking_character_avatar(center: Vector2, radius: float, row: Dictionary, accent: Color) -> void:
	draw_circle(center, radius, Color("#fff4fb"))
	var character_name: String = String(row.get("character", ""))
	var character: Dictionary = _ranking_character_for_row(String(row.get("characterId", "")), character_name)
	var texture: Texture2D = null
	if not character.is_empty():
		var idle_path: String = _ranking_idle_sprite_path(character)
		texture = CharacterSystemScript.texture_from_cache(character_sprite_cache, idle_path)
		if texture != null:
			var source_rect: Rect2 = _ranking_avatar_source_rect(character, idle_path, texture)
			var image_rect := Rect2(center - Vector2(radius - 3.0, radius - 3.0), Vector2((radius - 3.0) * 2.0, (radius - 3.0) * 2.0))
			draw_texture_rect_region(texture, image_rect, source_rect, Color(1, 1, 1, 0.98))
	if texture == null:
		_draw_ranking_text(_ranking_avatar_text(character_name), center + Vector2(-24, 9), 20, Color("#6b4a63"), 48, HORIZONTAL_ALIGNMENT_CENTER)
	draw_circle(center, radius, Color(1, 1, 1, 0.22), false, 1.5)
	draw_circle(center, radius, Color(accent.r, accent.g, accent.b, 0.34), false, 3.0)

func _ranking_character_for_row(character_id: String, character_name: String) -> Dictionary:
	var normalized_id: String = _ranking_character_id_for_row(character_id, character_name)
	for item in characters:
		var character: Dictionary = item as Dictionary
		if String(character.get("id", "")) == normalized_id:
			return character
	return {}

func _ranking_character_id_for_row(character_id: String, character_name: String) -> String:
	var id: String = character_id.strip_edges()
	if id == "banri":
		return "ban_chan"
	if id == "supana":
		return "superchat_chan"
	if id == "maron":
		return "maro_chan"
	if id != "":
		return id
	var name: String = character_name.strip_edges()
	if name == "赤羽ばんり" or name == "ばんちゃん" or name == "ばん":
		return "ban_chan"
	if name == "星投すぱな" or name == "すぱなちゃん" or name == "すぱ":
		return "superchat_chan"
	if name == "白綿まろん" or name == "まろんちゃん" or name == "まろ":
		return "maro_chan"
	return ""

func _ranking_idle_sprite_path(character: Dictionary) -> String:
	var idle_path: String = String(character.get("idleSprite", ""))
	if idle_path == "" and String(character.get("id", "")) == "ban_chan":
		return "res://assets/generated/ban_chan_idle_3x3/sheet-transparent.png"
	return idle_path

func _ranking_avatar_source_rect(character: Dictionary, sprite_path: String, texture: Texture2D) -> Rect2:
	var cols: int = maxi(1, int(character.get("idleSpriteCols", 1)))
	var rows: int = maxi(1, int(character.get("idleSpriteRows", 1)))
	var texture_size: Vector2 = texture.get_size()
	var frame_rect := Rect2(Vector2.ZERO, Vector2(texture_size.x / float(cols), texture_size.y / float(rows)))
	var cache_key := "%s:%d:%d:%d:%d" % [sprite_path, cols, rows, int(texture_size.x), int(texture_size.y)]
	if ranking_avatar_source_cache.has(cache_key):
		return ranking_avatar_source_cache[cache_key] as Rect2
	var opaque_bounds: Rect2 = _ranking_first_frame_opaque_bounds(sprite_path, frame_rect, texture)
	if opaque_bounds.size.x <= 0.0 or opaque_bounds.size.y <= 0.0:
		opaque_bounds = frame_rect
	var side: float = maxf(opaque_bounds.size.x * 0.70, opaque_bounds.size.y * 0.56)
	side = minf(side, minf(frame_rect.size.x, frame_rect.size.y))
	var center := Vector2(opaque_bounds.position.x + opaque_bounds.size.x * 0.5, opaque_bounds.position.y + opaque_bounds.size.y * 0.30)
	var source_rect := _clamp_rect_to_rect(Rect2(center - Vector2(side * 0.5, side * 0.5), Vector2(side, side)), frame_rect)
	ranking_avatar_source_cache[cache_key] = source_rect
	return source_rect

func _ranking_first_frame_opaque_bounds(sprite_path: String, frame_rect: Rect2, texture: Texture2D) -> Rect2:
	var image: Image = texture.get_image()
	if image == null or image.is_empty():
		image = Image.new()
		if image.load(sprite_path) != OK:
			return Rect2()
	var start_x: int = clampi(int(floor(frame_rect.position.x)), 0, image.get_width())
	var start_y: int = clampi(int(floor(frame_rect.position.y)), 0, image.get_height())
	var end_x: int = clampi(int(ceil(frame_rect.end.x)), start_x, image.get_width())
	var end_y: int = clampi(int(ceil(frame_rect.end.y)), start_y, image.get_height())
	var min_x := end_x
	var min_y := end_y
	var max_x := start_x
	var max_y := start_y
	for y in range(start_y, end_y):
		for x in range(start_x, end_x):
			if image.get_pixel(x, y).a <= 0.08:
				continue
			min_x = mini(min_x, x)
			min_y = mini(min_y, y)
			max_x = maxi(max_x, x)
			max_y = maxi(max_y, y)
	if max_x < min_x or max_y < min_y:
		return Rect2()
	return Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x + 1, max_y - min_y + 1))

func _clamp_rect_to_rect(rect: Rect2, bounds: Rect2) -> Rect2:
	var size := Vector2(minf(rect.size.x, bounds.size.x), minf(rect.size.y, bounds.size.y))
	var max_pos := bounds.end - size
	return Rect2(Vector2(clampf(rect.position.x, bounds.position.x, max_pos.x), clampf(rect.position.y, bounds.position.y, max_pos.y)), size)

func _draw_ranking_detail_panel(panel: Rect2, view: Dictionary) -> void:
	_draw_ranking_panel(panel, Color(1, 1, 1, 0.93), Color("#ead7e9"), 24, 2, true)
	var title: String = "配信リレー詳細" if String(view.get("tabId", "")) == "relay" else "記録詳細"
	_draw_ranking_text(title, panel.position + Vector2(30, 42), 28, Color("#ff5aa5"), panel.size.x - 60)
	if bool(view.get("locked", false)) or bool(view.get("empty", false)):
		_draw_ranking_message(panel, view.get("messageLines", []) as Array)
		return
	var cards: Array = view.get("detailCards", []) as Array
	var gap := 14.0
	var card_w := (panel.size.x - 54.0) * 0.5
	var card_h := 132.0
	var start := panel.position + Vector2(20, 70)
	for index in range(cards.size()):
		var col: int = index % 2
		var row: int = int(index / 2)
		var rect := Rect2(start + Vector2(float(col) * (card_w + gap), float(row) * (card_h + gap)), Vector2(card_w, card_h))
		_draw_ranking_detail_card(rect, cards[index] as Dictionary)

func _draw_ranking_detail_card(rect: Rect2, card: Dictionary) -> void:
	_draw_ranking_panel(rect, Color(1, 1, 1, 0.97), Color("#efd5e7"), 14, 2, false)
	_draw_ranking_text(_short_pause_text(String(card.get("title", "")), 16), rect.position + Vector2(18, 31), 19, Color("#b1509c"), rect.size.x - 36)
	var lines: Array = card.get("lines", []) as Array
	for index in range(mini(lines.size(), 4)):
		var text: String = _short_pause_text(String(lines[index]), 28)
		_draw_ranking_text(text, rect.position + Vector2(18, 60 + float(index) * 24.0), 16, Color("#5d4658"), rect.size.x - 36)

func _draw_ranking_footer() -> void:
	var rect := Rect2(76, 848, 1448, 44)
	_draw_ranking_panel(rect, Color(1, 1, 1, 0.94), Color("#ead7e9"), 18, 2, true)
	_draw_ranking_text("← →：タブ        ↑ ↓：記録        Esc：戻る        R：リセット", rect.position + Vector2(0, 29), 18, Color("#6b4a63"), rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_ranking_message(panel: Rect2, lines: Array) -> void:
	var y: float = panel.position.y + panel.size.y * 0.48
	for index in range(lines.size()):
		_draw_ranking_text(String(lines[index]), Vector2(panel.position.x + 30, y + float(index) * 34.0), 22, Color("#6b4a63"), panel.size.x - 60, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_ranking_panel(rect: Rect2, fill: Color, border: Color, radius: int, border_width: int = 2, shadow: bool = false) -> void:
	if shadow:
		var shadow_style := StyleBoxFlat.new()
		shadow_style.bg_color = Color(0.35, 0.15, 0.28, 0.12)
		shadow_style.border_color = Color(0, 0, 0, 0)
		shadow_style.set_corner_radius_all(radius)
		draw_style_box(shadow_style, Rect2(rect.position + Vector2(0, 5), rect.size))
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	draw_style_box(style, rect)

func _draw_ranking_text(text: String, pos: Vector2, size: int, color: Color, width: float = -1.0, alignment = HORIZONTAL_ALIGNMENT_LEFT) -> void:
	_draw_text_item({
		"pos": pos,
		"text": text,
		"width": int(width),
		"size": size,
		"color": color
	}, "", alignment)

func _draw_options_overlay() -> void:
	var background: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, TITLE_BACK_IMAGE)
	if background != null:
		draw_texture_rect(background, TITLE_SCREEN_RECT, false)
	else:
		draw_rect(TITLE_SCREEN_RECT, Color("#fff3fa"), true)
		draw_rect(Rect2(Vector2.ZERO, Vector2(1600, 220)), Color("#f4e7ff"), true)
	draw_rect(TITLE_SCREEN_RECT, Color(1.0, 0.94, 0.98, 0.42), true)
	var panel := Rect2(Vector2(230, 46), Vector2(1140, 812))
	_draw_ranking_panel(panel, Color(1.0, 0.992, 1.0, 0.97), Color("#ffbad8"), 32, 4, true)
	_draw_ranking_text("オプション", panel.position + Vector2(54, 64), 42, Color("#e73778"), 390)
	_draw_ranking_text("ゲームの表示や演出を設定できます", panel.position + Vector2(58, 102), 20, Color("#6b4a63"), 560)
	_draw_ranking_panel(Rect2(panel.position + Vector2(846, 36), Vector2(244, 70)), Color("#fff8fc"), Color("#f2d7e8"), 22, 2, false)
	_draw_ranking_text("↑↓ 選択", panel.position + Vector2(876, 66), 18, Color("#6b4a63"), 94, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_ranking_text("←→ 変更", panel.position + Vector2(976, 66), 18, Color("#6b4a63"), 94, HORIZONTAL_ALIGNMENT_CENTER)
	var items: Array = _option_items()
	var list_x := panel.position.x + 52.0
	var y := panel.position.y + 136.0
	var card_width := panel.size.x - 104.0
	for index in range(items.size()):
		var card_rect := Rect2(Vector2(list_x, y + float(index) * 74.0), Vector2(card_width, 64))
		_draw_option_card(card_rect, items[index] as Dictionary, option_menu_index == index)
	var guide_rect := Rect2(panel.position + Vector2(52, 670), Vector2(panel.size.x - 104, 42))
	_draw_ranking_panel(guide_rect, Color("#fff8fc"), Color("#f2d7e8"), 18, 2, false)
	_draw_ranking_text("↑↓：選択　←→：変更　Enter：決定　Esc：戻る", guide_rect.position + Vector2(0, 28), 18, Color("#6b4a63"), guide_rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	var reset_rect := Rect2(panel.position + Vector2(panel.size.x - 52 - 430, 724), Vector2(250, 54))
	var back_rect := Rect2(panel.position + Vector2(panel.size.x - 52 - 160, 724), Vector2(160, 54))
	_draw_options_button(reset_rect, "設定を初期化", option_menu_index == 7, Color("#fff0f7"), Color("#d93682"))
	_draw_options_button(back_rect, "戻る", option_menu_index == 8, Color("#eef9ff"), Color("#2587b8"))

func _option_items() -> Array:
	return [
		{
			"icon": "♪",
			"name": "BGM音量",
			"description": "タイトルBGMなどの音量を調整します",
			"type": "slider",
			"value": bgm_volume,
			"accent": Color("#f25a9b")
		},
		{
			"icon": "SE",
			"name": "SE音量",
			"description": "効果音の音量を保存します",
			"type": "slider",
			"value": se_volume,
			"accent": Color("#4fb8df")
		},
		{
			"icon": "全",
			"name": "フルスクリーン切替",
			"description": "全画面表示のON/OFFを切り替えます",
			"type": "toggle",
			"on": fullscreen_enabled,
			"accent": Color("#a768dc")
		},
		{
			"icon": "窓",
			"name": "ウィンドウサイズ",
			"description": "ウィンドウ表示時のサイズを選びます",
			"type": "select",
			"value": SettingsSystemScript.window_size_label(window_size_index).replace(" x ", "×"),
			"accent": Color("#6d8dde")
		},
		{
			"icon": "弾",
			"name": "コメント弾幕量",
			"description": "ゲーム中に流れるコメント量を調整します",
			"type": "select",
			"value": DisplayTextSystemScript.comment_barrage_label(comment_barrage_setting),
			"accent": Color("#f08a44")
		},
		{
			"icon": "揺",
			"name": "画面揺れ",
			"description": "ダメージや演出時の画面揺れを切り替えます",
			"type": "toggle",
			"on": screen_shake_enabled,
			"accent": Color("#2fbfb6")
		},
		{
			"icon": "教",
			"name": "チュートリアル再表示",
			"description": "次回開始時にチュートリアルを表示するか選びます",
			"type": "select",
			"value": "表示しない" if tutorial_seen else "表示する",
			"accent": Color("#d673c4")
		}
	]

func _draw_option_card(rect: Rect2, item: Dictionary, selected: bool) -> void:
	var accent: Color = item.get("accent", Color("#f25a9b")) as Color
	if selected:
		_draw_ranking_panel(rect.grow(5.0), Color(accent.r, accent.g, accent.b, 0.14), Color(1, 1, 1, 0), 22, 0, false)
	var fill := Color("#fff5fb") if selected else Color(1, 1, 1, 0.88)
	var border := accent if selected else Color("#f2d7e8")
	_draw_ranking_panel(rect, fill, border, 20, 4 if selected else 2, false)
	var icon_rect := Rect2(rect.position + Vector2(18, 12), Vector2(40, 40))
	_draw_ranking_panel(icon_rect, Color(accent.r, accent.g, accent.b, 0.13), Color(accent.r, accent.g, accent.b, 0.65), 16, 2, false)
	_draw_ranking_text(String(item.get("icon", "")), icon_rect.position + Vector2(0, 28), 18, accent, icon_rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_ranking_text(String(item.get("name", "")), rect.position + Vector2(76, 29), 22, Color("#3d3041"), 310)
	_draw_ranking_text(String(item.get("description", "")), rect.position + Vector2(76, 52), 15, Color("#7b6475"), 430)
	var control_rect := Rect2(rect.position + Vector2(rect.size.x - 330, 12), Vector2(298, 40))
	_draw_option_control(control_rect, item, accent)

func _draw_option_control(rect: Rect2, item: Dictionary, accent: Color) -> void:
	var control_type := String(item.get("type", "select"))
	if control_type == "slider":
		_draw_option_slider(Rect2(rect.position + Vector2(0, 11), Vector2(202, 18)), int(item.get("value", 0)), accent)
		_draw_ranking_text("%d%%" % int(item.get("value", 0)), rect.position + Vector2(214, 28), 20, accent, 76, HORIZONTAL_ALIGNMENT_RIGHT)
	elif control_type == "toggle":
		_draw_option_toggle(Rect2(rect.position + Vector2(106, 2), Vector2(136, 36)), bool(item.get("on", false)), accent)
	else:
		_draw_option_selector(Rect2(rect.position + Vector2(0, 2), Vector2(242, 36)), String(item.get("value", "")), accent)

func _draw_option_slider(rect: Rect2, value: int, accent: Color) -> void:
	_draw_ranking_panel(rect, Color("#f6eaf2"), Color("#ead4e4"), 9, 1, false)
	var ratio := clampf(float(value) / 100.0, 0.0, 1.0)
	if ratio > 0.0:
		_draw_ranking_panel(Rect2(rect.position, Vector2(rect.size.x * ratio, rect.size.y)), Color(accent.r, accent.g, accent.b, 0.72), Color(accent.r, accent.g, accent.b, 0.0), 9, 0, false)
	var knob_x := rect.position.x + rect.size.x * ratio
	draw_circle(Vector2(knob_x, rect.position.y + rect.size.y * 0.5), 12, Color(1, 1, 1, 0.98))
	draw_circle(Vector2(knob_x, rect.position.y + rect.size.y * 0.5), 7, accent)

func _draw_option_toggle(rect: Rect2, enabled: bool, accent: Color) -> void:
	var fill := Color(accent.r, accent.g, accent.b, 0.74) if enabled else Color("#d9d1dc")
	var border := accent if enabled else Color("#b8acbd")
	_draw_ranking_panel(rect, fill, border, 18, 2, false)
	_draw_ranking_text("ON" if enabled else "OFF", rect.position + Vector2(0, 25), 18, Color(1, 1, 1, 0.96), rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	var knob_x := rect.position.x + rect.size.x - 20.0 if enabled else rect.position.x + 20.0
	draw_circle(Vector2(knob_x, rect.position.y + rect.size.y * 0.5), 13, Color(1, 1, 1, 0.96))

func _draw_option_selector(rect: Rect2, value: String, accent: Color) -> void:
	_draw_ranking_panel(rect, Color("#fffefe"), Color(accent.r, accent.g, accent.b, 0.58), 18, 2, false)
	_draw_ranking_text("< %s >" % value, rect.position + Vector2(0, 25), 20, accent, rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_options_button(rect: Rect2, label: String, selected: bool, fill: Color, accent: Color) -> void:
	if selected:
		_draw_ranking_panel(rect.grow(5.0), Color(accent.r, accent.g, accent.b, 0.14), Color(1, 1, 1, 0), 22, 0, false)
	_draw_ranking_panel(rect, fill if not selected else Color(1, 1, 1, 0.96), accent, 20, 4 if selected else 2, false)
	_draw_ranking_text(label, rect.position + Vector2(0, 35), 22, accent, rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)

func _ranking_avatar_text(name: String) -> String:
	if name.contains("ばん"):
		return "ばん"
	if name.contains("すぱ"):
		return "すぱ"
	if name.contains("まろん"):
		return "まろ"
	if name.length() >= 2:
		return name.substr(0, 2)
	return name

func _draw_result_overlay() -> void:
	var data: Dictionary = last_result_data
	if data.is_empty():
		return
	var layout: Dictionary = _result_layout()
	var panel: Rect2 = layout["panel"] as Rect2
	var completed := String(data.get("endType", "")) == "completed"
	var panel_border := Color("#ffd46a") if completed else Color("#ffbad8")
	var panel_fill := Color(1.0, 0.995, 0.965, 0.97) if completed else Color(1.0, 0.985, 0.995, 0.97)
	_draw_ranking_panel(panel, panel_fill, panel_border, 36, 4, true)
	_draw_result_header(panel, data)
	_draw_result_summary_panel(layout["summaryPanel"] as Rect2, data)
	_draw_result_detail_panel(layout["detailPanel"] as Rect2, data)
	_draw_result_buttons(layout)

func _draw_result_header(panel: Rect2, data: Dictionary) -> void:
	var completed := String(data.get("endType", "")) == "completed"
	var accent := Color("#ff9f1c") if completed else Color("#f05aa5")
	var header_text := String(data.get("resultTitle", "配信終了！"))
	_draw_ranking_text(header_text, panel.position + Vector2(112, 78), 46, accent, 360)
	var rank_rect := Rect2(panel.position + Vector2(482, 26), Vector2(392, 86))
	_draw_ranking_panel(rank_rect, Color(1, 1, 1, 0.88), Color("#d7c5ff"), 20, 2, false)
	_draw_ranking_text("神回度", rank_rect.position + Vector2(30, 54), 24, Color("#7a56c8"), 116)
	_draw_ranking_text(String(data.get("kamiRank", "D")), rank_rect.position + Vector2(154, 63), 54, _result_rank_color(String(data.get("kamiRank", "D"))), 70, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_ranking_text("%d pt" % int(data.get("kamiPoint", 0)), rank_rect.position + Vector2(244, 58), 34, Color("#7a56c8"), 130)
	var summary_line: String = String(data.get("summaryLine", "これはコメントが悪い。たぶん。"))
	_draw_ranking_panel(Rect2(panel.position + Vector2(196, 128), Vector2(700, 46)), Color(1, 1, 1, 0.78), Color("#f3d3e6"), 20, 2, false)
	_draw_ranking_text(_short_pause_text(summary_line, 44), panel.position + Vector2(210, 158), 20, Color("#4f3149"), 672, HORIZONTAL_ALIGNMENT_CENTER)
	var character_rect := Rect2(panel.position + Vector2(938, 18), Vector2(138, 138))
	_draw_ranking_panel(character_rect, Color("#fff5fb"), Color("#f3d3e6"), 22, 2, false)
	_draw_result_character_bust(character_rect.grow(-8), String(data.get("characterId", "")), String(data.get("characterName", "配信者")))
	_draw_result_small_badge(panel.position + Vector2(58, 46), "完走" if completed else "BAN", Color("#ffb433") if completed else Color("#ff4b62"))

func _draw_result_summary_panel(rect: Rect2, data: Dictionary) -> void:
	_draw_ranking_panel(rect, Color(1, 1, 1, 0.88), Color("#ffd2e5"), 20, 2, false)
	_draw_result_ribbon(rect.position + Vector2(70, -18), "配信サマリー", Color("#ff6fa8"))
	var rows: Array = [
		{"icon": "配", "label": "配信者", "value": String(data.get("characterName", "配信者"))},
		{"icon": "枠", "label": "配信枠", "value": String(data.get("streamFrameName", "配信枠"))},
		{"icon": "人", "label": "最大同時視聴者数", "value": "%s 人" % _result_number(int(data.get("viewerCount", data.get("score", 0))))},
		{"icon": "時", "label": "生存時間", "value": ResultSystemScript.format_time(float(data.get("survivalTime", 0.0)))},
		{"icon": "V", "label": "最大ボルテージ", "value": "x%.1f" % float(data.get("maxVoltage", data.get("maxMultiplier", 1.0)))},
		{"icon": "炎", "label": "炎上", "value": str(int(data.get("maxBurnCombo", 0)))},
		{"icon": "贈", "label": "ギフト", "value": str(int(data.get("giftCount", 0)))}
	]
	for index in range(rows.size()):
		var row_rect := Rect2(rect.position + Vector2(22, 48 + float(index) * 58.0), Vector2(rect.size.x - 44, 46))
		_draw_result_summary_row(row_rect, rows[index] as Dictionary)

func _draw_result_summary_row(rect: Rect2, row: Dictionary) -> void:
	_draw_ranking_panel(rect, Color(1, 1, 1, 0.88), Color("#f4d5e6"), 12, 1, false)
	draw_circle(rect.position + Vector2(24, 23), 16, Color("#fff0f8"))
	_draw_ranking_text(String(row.get("icon", "")), rect.position + Vector2(14, 29), 16, Color("#f05aa5"), 20, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_ranking_text(String(row.get("label", "")), rect.position + Vector2(50, 30), 17, Color("#4f3149"), 178)
	_draw_ranking_text(_short_pause_text(String(row.get("value", "")), 16), rect.position + Vector2(214, 31), 21, Color("#f05aa5"), rect.size.x - 228, HORIZONTAL_ALIGNMENT_RIGHT)

func _draw_result_detail_panel(rect: Rect2, data: Dictionary) -> void:
	_draw_ranking_panel(rect, Color(1, 1, 1, 0.88), Color("#d8cdf7"), 20, 2, false)
	_draw_result_ribbon(rect.position + Vector2(68, -18), "配信詳細", Color("#a875e8"))
	var trouble_rect := Rect2(rect.position + Vector2(24, 42), Vector2(rect.size.x - 48, 120))
	var build_rect := Rect2(rect.position + Vector2(24, 182), Vector2(330, 140))
	var gift_rect := Rect2(rect.position + Vector2(374, 182), Vector2(330, 140))
	var ranking_rect := Rect2(rect.position + Vector2(24, 340), Vector2(330, 92))
	var maro_rect := Rect2(rect.position + Vector2(374, 340), Vector2(330, 92))
	_draw_result_trouble_card(trouble_rect, data)
	_draw_result_build_card(build_rect, data)
	_draw_result_gift_card(gift_rect, data)
	_draw_result_marshmallow_card(maro_rect, data)
	_draw_result_ranking_card(ranking_rect, data)

func _draw_result_trouble_card(rect: Rect2, data: Dictionary) -> void:
	_draw_ranking_panel(rect, Color(1, 1, 1, 0.92), Color("#ead7ff"), 14, 2, false)
	var completed := String(data.get("endType", "")) == "completed"
	_draw_ranking_text("配信ハイライト" if completed else "配信トラブル", rect.position + Vector2(18, 28), 17, Color("#7a56c8"), rect.size.x - 36)
	var rows: Array = []
	if completed:
		rows = [
			"結果：最後まで配信を走り切った！",
			"最終指示コメ：%s" % String(data.get("lastInstructionComment", "なし")),
			"コメント欄：大盛り上がり"
		]
	else:
		rows = [
			"戦犯指示コメ：%s" % String(data.get("culpritInstructionComment", "なし")),
			"死因：%s" % String(data.get("deathText", "")),
			"最後の一撃：%s" % String(data.get("lastDeathSource", "接触"))
		]
	if bool(data.get("bossSummoned", false)):
		var boss_result: String = "撃破" if bool(data.get("bossDefeated", false)) else ("撤退" if String(data.get("bossResult", "")) == "retreated" else "出現")
		var reward_text: String = " / +%s人" % _result_number(int(data.get("bossRewardViewer", 0))) if int(data.get("bossRewardViewer", 0)) > 0 else ""
		rows.append("ボス%s：%s%s" % [boss_result, String(data.get("bossName", "ボス")), reward_text])
	for index in range(rows.size()):
		var y: float = 52.0 + float(index) * (20.0 if rows.size() >= 4 else 24.0)
		_draw_ranking_text(_short_pause_text(String(rows[index]), 66), rect.position + Vector2(18, y), 15, Color("#4f3149"), rect.size.x - 36)

func _draw_result_build_card(rect: Rect2, data: Dictionary) -> void:
	_draw_ranking_panel(rect, Color(1, 1, 1, 0.92), Color("#d8cdf7"), 14, 2, false)
	_draw_ranking_text("最終ビルド", rect.position + Vector2(18, 28), 17, Color("#7a56c8"), rect.size.x - 36)
	_draw_ranking_text("武器", rect.position + Vector2(18, 64), 16, Color("#4f3149"), 54)
	_draw_result_equipment_slots(data.get("weapons", []), weapons, rect.position + Vector2(72, 42), 5)
	_draw_ranking_text("アクセ", rect.position + Vector2(18, 112), 16, Color("#4f3149"), 54)
	_draw_result_equipment_slots(data.get("accessories", []), gifts, rect.position + Vector2(72, 90), 5)

func _draw_result_gift_card(rect: Rect2, data: Dictionary) -> void:
	_draw_ranking_panel(rect, Color(1, 1, 1, 0.92), Color("#ffd2e5"), 14, 2, false)
	_draw_ranking_text("取得ギフト", rect.position + Vector2(18, 28), 17, Color("#f05aa5"), rect.size.x - 36)
	var names: Array = data.get("giftList", []) as Array
	if names.is_empty():
		_draw_ranking_text("なし", rect.position + Vector2(18, 82), 18, Color("#7f7480"), rect.size.x - 36, HORIZONTAL_ALIGNMENT_CENTER)
		return
	for index in range(mini(names.size(), 4)):
		var slot := Rect2(rect.position + Vector2(18 + float(index) * 76.0, 50), Vector2(58, 58))
		_draw_ranking_panel(slot, Color("#fff8fc"), Color("#ffd2e5"), 10, 2, false)
		_draw_ranking_text("G", slot.position + Vector2(0, 38), 24, Color("#f05aa5"), slot.size.x, HORIZONTAL_ALIGNMENT_CENTER)
		_draw_ranking_text("x1", slot.position + Vector2(0, 78), 13, Color("#4f3149"), slot.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_ranking_text(_short_pause_text(String(data.get("giftSummary", "")), 24), rect.position + Vector2(18, 132), 14, Color("#6b4a63"), rect.size.x - 36)

func _draw_result_marshmallow_card(rect: Rect2, data: Dictionary) -> void:
	_draw_ranking_panel(rect, Color(1, 1, 1, 0.92), Color("#d4eafe"), 14, 2, false)
	_draw_ranking_text("マシュマロ結果", rect.position + Vector2(18, 28), 17, Color("#438ee8"), rect.size.x - 36)
	var chips: Array = [
		"読了 %d" % int(data.get("marshmallowReadCount", 0)),
		"良マロ %d" % int(data.get("goodMaroCount", 0)),
		"神マロ %d" % int(data.get("godMaroCount", 0)),
		"クソマロ %d" % int(data.get("kusoMaroCount", 0)),
		"未読 %d" % int(data.get("unreadMaroCount", 0))
	]
	for index in range(chips.size()):
		var chip := Rect2(rect.position + Vector2(18 + float(index % 3) * 98.0, 40 + float(index / 3) * 30.0), Vector2(86, 24))
		_draw_ranking_panel(chip, Color("#f7fbff"), Color("#d4eafe"), 10, 1, false)
		_draw_ranking_text(String(chips[index]), chip.position + Vector2(0, 18), 13, Color("#4f3149"), chip.size.x, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_result_ranking_card(rect: Rect2, data: Dictionary) -> void:
	_draw_ranking_panel(rect, Color("#fffaf0"), Color("#ffd98a"), 14, 2, false)
	var text: String = String(data.get("rankingText", ""))
	if text == "":
		text = "ランキング対象外"
	_draw_ranking_text(_short_pause_text(text, 31), rect.position + Vector2(18, 39), 16, Color("#b06b18"), rect.size.x - 36)

func _draw_result_equipment_slots(items_value: Variant, source_data: Array, start: Vector2, slot_count: int) -> void:
	var items: Array = []
	if items_value is Array:
		items = items_value as Array
	for index in range(slot_count):
		var slot := Rect2(start + Vector2(float(index) * 46.0, 0), Vector2(38, 38))
		_draw_ranking_panel(slot, Color("#fbfbff"), Color("#d8cdf7"), 6, 1, false)
		if index >= items.size() or not (items[index] is Dictionary):
			continue
		var item: Dictionary = items[index] as Dictionary
		var data: Dictionary = _find_equipment_icon_data(source_data, String(item.get("id", "")))
		var icon: Texture2D = _load_equipment_icon(String(data.get("iconPath", "")))
		if icon != null:
			draw_texture_rect(icon, slot.grow(-3), false)
		else:
			_draw_ranking_text(_short_pause_text(String(item.get("displayName", item.get("id", ""))), 2), slot.position + Vector2(0, 25), 13, Color("#7a56c8"), slot.size.x, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_result_buttons(layout: Dictionary) -> void:
	_draw_result_button(layout["retryButton"] as Rect2, "▶ もう一回", Color("#ff5aa5"), Color.WHITE, "retry")
	_draw_result_button(layout["rankingButton"] as Rect2, "ランキング", Color("#f8f2ff"), Color("#7a56c8"), "ranking")
	_draw_result_button(layout["titleButton"] as Rect2, "タイトルへ", Color("#e8f7ff"), Color("#2587b8"), "title")

func _draw_result_button(rect: Rect2, label: String, fill: Color, text_color: Color, button_id: String) -> void:
	if result_hover_button == button_id:
		_draw_ranking_panel(rect.grow(5), Color(1, 1, 1, 0.72), Color("#ff9cc9"), 18, 3, false)
	_draw_character_select_button(rect, label, fill, text_color, true)

func _draw_result_ribbon(pos: Vector2, text: String, color: Color) -> void:
	var rect := Rect2(pos, Vector2(200, 32))
	_draw_ranking_panel(rect, color, Color(1, 1, 1, 0), 4, 0, false)
	_draw_ranking_text(text, rect.position + Vector2(0, 23), 16, Color.WHITE, rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_result_small_badge(pos: Vector2, text: String, color: Color) -> void:
	var rect := Rect2(pos, Vector2(70, 70))
	_draw_ranking_panel(rect, Color(color.r, color.g, color.b, 0.16), color, 16, 3, false)
	_draw_ranking_text(text, rect.position + Vector2(0, 42), 22, color, rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_result_character_bust(rect: Rect2, character_id: String, character_name: String) -> void:
	var character: Dictionary = CharacterSystemScript.find_character(characters, character_id)
	var tex: Texture2D = CharacterSystemScript.texture_from_cache(character_sprite_cache, String(character.get("sprite", "")))
	if tex != null:
		draw_texture_rect(tex, _fit_texture_rect(rect, tex.get_size()), false)
	else:
		draw_circle(rect.get_center(), 44, Color("#fff0f8"))
		_draw_ranking_text(_ranking_avatar_text(character_name), rect.position + Vector2(0, rect.size.y * 0.55), 20, Color("#f05aa5"), rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)

func _result_rank_color(rank: String) -> Color:
	if rank == "S":
		return Color("#ff68b3")
	if rank == "A":
		return Color("#f3a43b")
	if rank == "B":
		return Color("#a875e8")
	if rank == "C":
		return Color("#438ee8")
	return Color("#7f7480")

func _result_number(value: int) -> String:
	var text: String = str(value)
	var result := ""
	var count := 0
	for i in range(text.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = text.substr(i, 1) + result
		count += 1
	return result

func _draw_character_select_overlay() -> void:
	_draw_character_select_background()
	var layout: Dictionary = _character_select_layout()
	var page: int = CharacterSystemScript.selection_page_for_index(selected_character_index, characters.size())
	var page_count: int = CharacterSystemScript.selection_page_count(characters.size())
	_draw_character_select_header(layout["header"] as Rect2)
	_draw_character_select_list_panel(layout["listPanel"] as Rect2, page)
	_draw_character_select_detail_panel(layout["detailPanel"] as Rect2)
	_draw_character_select_footer(layout, page, page_count)

func _character_select_layout() -> Dictionary:
	return {
		"header": Rect2(76, 16, 1448, 72),
		"listPanel": Rect2(76, 112, 880, 692),
		"detailPanel": Rect2(982, 112, 542, 692),
		"footer": Rect2(76, 828, 1448, 52),
		"confirmButton": Rect2(108, 838, 176, 34),
		"backButton": Rect2(306, 838, 150, 34),
		"prevButton": Rect2(1230, 838, 96, 34),
		"nextButton": Rect2(1352, 838, 96, 34)
	}

func _character_select_card_rect(local_index: int) -> Rect2:
	var panel: Rect2 = (_character_select_layout()["listPanel"] as Rect2)
	var col: int = local_index % CharacterSystemScript.SELECT_COLUMNS
	var row: int = int(local_index / CharacterSystemScript.SELECT_COLUMNS)
	var card_w := 264.0
	var card_h := 276.0
	var gap_x := 16.0
	var gap_y := 18.0
	return Rect2(panel.position + Vector2(24.0 + float(col) * (card_w + gap_x), 82.0 + float(row) * (card_h + gap_y)), Vector2(card_w, card_h))

func _draw_character_select_background() -> void:
	var background: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, TITLE_BACK_IMAGE)
	if background != null:
		draw_texture_rect(background, TITLE_SCREEN_RECT, false, Color(1, 1, 1, 0.58))
	else:
		_draw_screen_backdrop()
	draw_rect(TITLE_SCREEN_RECT, Color(1.0, 0.93, 0.985, 0.62), true)
	draw_rect(TITLE_SCREEN_RECT, Color(1.0, 1.0, 1.0, 0.30), true)

func _draw_character_select_header(rect: Rect2) -> void:
	_draw_ranking_panel(rect, Color(1, 1, 1, 0.95), Color("#ead7e9"), 22, 2, true)
	draw_circle(rect.position + Vector2(46, 36), 22, Color("#fff3fb"))
	_draw_ranking_text("配", rect.position + Vector2(35, 47), 25, Color("#f05aa5"), 28, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_ranking_text("配信者を選択", rect.position + Vector2(88, 47), 34, Color("#4f3149"), 360)
	_draw_ranking_text("← →：選択 / A D：ページ / Enter Space：決定 / Esc：戻る", rect.position + Vector2(682, 45), 20, Color("#6b4a63"), 710, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_character_select_list_panel(panel: Rect2, page: int) -> void:
	_draw_ranking_panel(panel, Color(1, 1, 1, 0.93), Color("#ead7e9"), 24, 2, true)
	_draw_ranking_text("配信者一覧", panel.position + Vector2(30, 46), 28, Color("#7a3fb0"), 360)
	var start: int = page * CharacterSystemScript.SELECT_PAGE_SIZE
	for local_index in range(CharacterSystemScript.SELECT_PAGE_SIZE):
		var rect: Rect2 = _character_select_card_rect(local_index)
		var index: int = start + local_index
		if index < characters.size():
			_draw_character_select_card(rect, index)
		else:
			_draw_character_select_coming_card(rect)

func _draw_character_select_card(rect: Rect2, index: int) -> void:
	var character: Dictionary = characters[index] as Dictionary
	var view: Dictionary = CharacterSystemScript.selection_card_view(character, weapons)
	var selected: bool = index == selected_character_index
	var unlocked: bool = bool(view.get("isUnlocked", true))
	var border: Color = Color("#ff62b5") if selected else Color("#cfe9ff")
	var fill: Color = Color(1, 1, 1, 0.98)
	var text_color := Color("#4f3149")
	if not unlocked:
		border = Color("#cfc8d6") if not selected else Color("#a887d8")
		fill = Color("#f4f0f5")
		text_color = Color("#7f7480")
	if selected:
		_draw_ranking_panel(rect.grow(6), Color(1.0, 0.73, 0.90, 0.18), Color(1, 1, 1, 0), 22, 0, false)
	_draw_ranking_panel(rect, fill, border, 20, 4 if selected else 2, false)
	_draw_ranking_text("[%d]" % (index + 1), rect.position + Vector2(16, 31), 18, Color("#ff5aa5") if unlocked else Color("#8f8793"), 42)
	_draw_ranking_text(_short_pause_text(String(view.get("displayName", "配信者")), 9), rect.position + Vector2(58, 35), 23, text_color, rect.size.x - 76)
	var image_rect := Rect2(rect.position + Vector2(42, 50), Vector2(rect.size.x - 84, 130))
	if unlocked:
		var tex: Texture2D = CharacterSystemScript.texture_from_cache(character_sprite_cache, String(view.get("spritePath", "")))
		if tex != null:
			draw_texture_rect(tex, _fit_texture_rect(image_rect, tex.get_size()), false)
	else:
		draw_circle(image_rect.get_center() + Vector2(0, -6), 44, Color("#dfd8e3"))
		_draw_ranking_text("LOCK", image_rect.position + Vector2(0, 84), 24, Color("#8f8793"), image_rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_character_select_tag(Rect2(rect.position + Vector2(18, 190), Vector2(rect.size.x - 36, 34)), String(view.get("roleName", "配信者")), Color("#e8f7ff"), Color("#4d8ab5"))
	_draw_character_select_weapon_line(Rect2(rect.position + Vector2(18, 232), Vector2(rect.size.x - 36, 30)), view)
	if selected:
		_draw_ranking_text("★", rect.position + Vector2(rect.size.x - 36, 33), 22, Color("#ffd15c"), 28, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_character_select_coming_card(rect: Rect2) -> void:
	_draw_ranking_panel(rect, Color("#fbf8fc"), Color("#e0d7e2"), 20, 2, false)
	draw_circle(rect.position + rect.size * 0.5 + Vector2(0, -24), 48, Color("#f1eaf2"))
	_draw_ranking_text("COMING", rect.position + Vector2(0, 136), 24, Color("#a294a3"), rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_ranking_text("SOON", rect.position + Vector2(0, 168), 24, Color("#a294a3"), rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_ranking_text("新しい配信者をお楽しみに！", rect.position + Vector2(20, 224), 15, Color("#8f8793"), rect.size.x - 40, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_character_select_detail_panel(panel: Rect2) -> void:
	_draw_ranking_panel(panel, Color(1, 1, 1, 0.93), Color("#ead7e9"), 24, 2, true)
	_draw_ranking_text("選択中キャラ詳細", panel.position + Vector2(30, 46), 28, Color("#ff5aa5"), panel.size.x - 60)
	if characters.is_empty():
		_draw_ranking_text("配信者データがありません。", panel.position + Vector2(30, 300), 22, Color("#6b4a63"), panel.size.x - 60, HORIZONTAL_ALIGNMENT_CENTER)
		return
	var index: int = clampi(selected_character_index, 0, characters.size() - 1)
	var character: Dictionary = characters[index] as Dictionary
	var view: Dictionary = CharacterSystemScript.selection_card_view(character, weapons)
	var unlocked: bool = bool(view.get("isUnlocked", true))
	_draw_ranking_text(String(view.get("displayName", "配信者")), panel.position + Vector2(30, 88), 32, Color("#4f3149"), panel.size.x - 60)
	var image_rect := Rect2(panel.position + Vector2(70, 104), Vector2(panel.size.x - 140, 250))
	if unlocked:
		var tex: Texture2D = CharacterSystemScript.texture_from_cache(character_sprite_cache, String(view.get("spritePath", "")))
		if tex != null:
			draw_texture_rect(tex, _fit_texture_rect(image_rect, tex.get_size()), false)
	else:
		draw_circle(image_rect.get_center() + Vector2(0, -10), 68, Color("#dfd8e3"))
		_draw_ranking_text("LOCK", image_rect.position + Vector2(0, 148), 30, Color("#8f8793"), image_rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	if not unlocked:
		var lock_rect := Rect2(panel.position + Vector2(28, 390), Vector2(panel.size.x - 56, 170))
		_draw_ranking_panel(lock_rect, Color("#fbf8fc"), Color("#e0d7e2"), 16, 2, false)
		_draw_multiline_text_item({"pos": lock_rect.position + Vector2(22, 48), "text": "この配信者はまだ開放されていません。\n\n解放条件：\n%s" % String(view.get("unlockConditionText", "？？？")), "width": int(lock_rect.size.x - 44), "size": 20, "color": Color("#6b4a63")})
		return
	_draw_character_select_info_card(Rect2(panel.position + Vector2(28, 380), Vector2(232, 56)), "タイプ", String(view.get("roleName", "配信者")), Color("#e8f7ff"), Color("#4d8ab5"))
	_draw_character_select_info_card(Rect2(panel.position + Vector2(282, 380), Vector2(232, 56)), "初期武器", String(view.get("weaponName", "未設定")), Color("#fff2fa"), Color("#e24e9a"))
	_draw_character_select_info_card(Rect2(panel.position + Vector2(28, 448), Vector2(panel.size.x - 56, 62)), "特性", "%s：%s" % [String(view.get("passiveName", "なし")), String(view.get("passiveDescription", ""))], Color("#f3ecff"), Color("#7a56c8"))
	var desc_rect := Rect2(panel.position + Vector2(28, 522), Vector2(panel.size.x - 56, 112))
	_draw_ranking_panel(desc_rect, Color(1, 1, 1, 0.98), Color("#efd5e7"), 16, 2, false)
	_draw_ranking_text("紹介", desc_rect.position + Vector2(18, 30), 17, Color("#b1509c"), desc_rect.size.x - 36)
	_draw_multiline_text_item({"pos": desc_rect.position + Vector2(18, 62), "text": String(view.get("description", "")), "width": int(desc_rect.size.x - 36), "size": 17, "color": Color("#5d4658")})
	var weapon_rect := Rect2(panel.position + Vector2(28, 648), Vector2(panel.size.x - 56, 54))
	_draw_ranking_panel(weapon_rect, Color("#fff8fc"), Color("#efd5e7"), 16, 2, false)
	_draw_character_select_weapon_line(Rect2(weapon_rect.position + Vector2(18, 12), Vector2(weapon_rect.size.x - 36, 30)), view)

func _draw_character_select_footer(layout: Dictionary, page: int, page_count: int) -> void:
	var rect: Rect2 = layout["footer"] as Rect2
	_draw_ranking_panel(rect, Color(1, 1, 1, 0.94), Color("#ead7e9"), 18, 2, true)
	var unlocked := false
	if not characters.is_empty() and selected_character_index >= 0 and selected_character_index < characters.size():
		unlocked = CharacterSystemScript.is_unlocked(characters[selected_character_index] as Dictionary)
	_draw_character_select_button(layout["confirmButton"] as Rect2, "決定", Color("#ff93cd"), Color.WHITE, unlocked)
	_draw_character_select_button(layout["backButton"] as Rect2, "戻る", Color("#f8f2ff"), Color("#6b4a63"), true)
	_draw_ranking_text("%d / %d" % [page + 1, page_count], rect.position + Vector2(0, 34), 19, Color("#6b4a63"), rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_character_select_button(layout["prevButton"] as Rect2, "← 前", Color("#ffffff"), Color("#6b4a63"), page > 0)
	_draw_character_select_button(layout["nextButton"] as Rect2, "次 →", Color("#ffffff"), Color("#6b4a63"), page + 1 < page_count)

func _draw_character_select_button(rect: Rect2, label: String, fill: Color, text_color: Color, enabled: bool) -> void:
	var actual_fill: Color = fill if enabled else Color("#eee9ef")
	var actual_text: Color = text_color if enabled else Color("#a89fac")
	_draw_ranking_panel(rect, actual_fill, Color("#ead7e9"), 14, 2, false)
	_draw_ranking_text(label, rect.position + Vector2(0, 24), 17, actual_text, rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_character_select_info_card(rect: Rect2, label: String, value: String, fill: Color, accent: Color) -> void:
	_draw_ranking_panel(rect, fill, Color("#efd5e7"), 14, 2, false)
	_draw_ranking_text(label, rect.position + Vector2(16, 22), 14, accent, rect.size.x - 32)
	_draw_ranking_text(_short_pause_text(value, 25), rect.position + Vector2(16, 46), 18, Color("#4f3149"), rect.size.x - 32)

func _draw_character_select_tag(rect: Rect2, text: String, fill: Color, accent: Color) -> void:
	_draw_ranking_panel(rect, fill, Color("#dbeaf4"), 12, 1, false)
	_draw_ranking_text(_short_pause_text(text, 13), rect.position + Vector2(0, 24), 16, accent, rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_character_select_weapon_line(rect: Rect2, view: Dictionary) -> void:
	var icon: Texture2D = _load_equipment_icon(String(view.get("weaponIconPath", "")))
	var text_x := rect.position.x
	if icon != null:
		var icon_rect := Rect2(rect.position, Vector2(30, 30))
		draw_texture_rect(icon, icon_rect, false)
		text_x += 38.0
	_draw_ranking_text(_short_pause_text(String(view.get("weaponName", "未設定")), 16), Vector2(text_x, rect.position.y + 23), 16, Color("#e24e9a"), rect.end.x - text_x)

func _draw_selection_overlay(data: Dictionary, selected_index: int, card_kind: String) -> void:
	var panel: Rect2 = data["panel"] as Rect2
	_draw_panel_rect(DrawDataSystemScript.selection_panel_style(panel))
	var header: Dictionary = DrawDataSystemScript.selection_header_data(panel, data["helpOffset"] as Vector2)
	_draw_text_item(header, "title", HORIZONTAL_ALIGNMENT_LEFT, header["titleColor"] as Color, String(data["title"]))
	_draw_text_item(header, "help", HORIZONTAL_ALIGNMENT_LEFT, header["helpColor"] as Color, DisplayTextSystemScript.select_help_text())
	for item in (data["cards"] as Array):
		var card_data: Dictionary = item as Dictionary
		var index: int = int(card_data["index"])
		if card_kind == "character":
			_draw_character_card(card_data["rect"] as Rect2, card_data["view"] as Dictionary, index, index == selected_index)
		elif card_kind == "stream":
			_draw_stream_frame_card(card_data["rect"] as Rect2, card_data["view"] as Dictionary, index, index == selected_index)

func _draw_character_card(card: Rect2, view: Dictionary, index: int, selected: bool) -> void:
	var border: Color = _draw_selection_card_frame(card, selected)
	var tex: Texture2D = CharacterSystemScript.texture_from_cache(character_sprite_cache, String(view["spritePath"]))
	var tex_size: Vector2 = tex.get_size() if tex != null else Vector2.ZERO
	var layout: Dictionary = DrawDataSystemScript.character_card_layout(card, tex_size)
	var title_item: Dictionary = DrawDataSystemScript.layout_text_item(layout, "title", "[%d] %s" % [index + 1, String(view["displayName"])], border)
	_draw_text_item(title_item)
	if tex != null:
		draw_texture_rect(tex, layout["textureRect"] as Rect2, false)
	_draw_card_text_items(DrawDataSystemScript.character_card_text_items(view, layout))

func _draw_stream_frame_select_overlay() -> void:
	_draw_stream_frame_select_background()
	var layout: Dictionary = _stream_frame_select_layout()
	var frames: Array = _stream_frame_selection_items()
	var page: int = StreamFrameSystemScript.selection_page_for_index(selected_stream_frame_index, frames.size())
	var page_count: int = StreamFrameSystemScript.selection_page_count(frames.size())
	_draw_stream_frame_select_header(layout["header"] as Rect2)
	_draw_stream_frame_select_list_panel(layout["listPanel"] as Rect2, frames, page)
	_draw_stream_frame_select_detail_panel(layout["detailPanel"] as Rect2, frames)
	_draw_stream_frame_select_footer(layout, frames, page, page_count)

func _stream_frame_select_layout() -> Dictionary:
	return {
		"header": Rect2(76, 16, 1448, 72),
		"listPanel": Rect2(76, 112, 880, 692),
		"detailPanel": Rect2(982, 112, 542, 692),
		"footer": Rect2(76, 828, 1448, 52),
		"confirmButton": Rect2(108, 838, 176, 34),
		"backButton": Rect2(306, 838, 150, 34),
		"prevButton": Rect2(1230, 838, 96, 34),
		"nextButton": Rect2(1352, 838, 96, 34)
	}

func _stream_frame_select_card_rect(local_index: int) -> Rect2:
	var panel: Rect2 = (_stream_frame_select_layout()["listPanel"] as Rect2)
	var col: int = local_index % StreamFrameSystemScript.SELECT_COLUMNS
	var row: int = int(local_index / StreamFrameSystemScript.SELECT_COLUMNS)
	var card_w := 264.0
	var card_h := 276.0
	var gap_x := 16.0
	var gap_y := 18.0
	return Rect2(panel.position + Vector2(24.0 + float(col) * (card_w + gap_x), 82.0 + float(row) * (card_h + gap_y)), Vector2(card_w, card_h))

func _draw_stream_frame_select_background() -> void:
	var background: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, TITLE_BACK_IMAGE)
	if background != null:
		draw_texture_rect(background, TITLE_SCREEN_RECT, false, Color(1, 1, 1, 0.58))
	else:
		_draw_screen_backdrop()
	draw_rect(TITLE_SCREEN_RECT, Color(1.0, 0.93, 0.985, 0.62), true)
	draw_rect(TITLE_SCREEN_RECT, Color(1.0, 1.0, 1.0, 0.30), true)

func _draw_stream_start_intro_overlay() -> void:
	_draw_stream_frame_select_background()
	var progress := clampf((STREAM_START_INTRO_DURATION - stream_start_intro_timer) / STREAM_START_INTRO_DURATION, 0.0, 1.0)
	var live_phase := progress >= 0.48
	var clock := float(Time.get_ticks_msec()) / 1000.0
	var flash_alpha := (0.05 + sin(clock * 5.4) * 0.025) if live_phase else 0.0
	draw_rect(TITLE_SCREEN_RECT, Color(1.0, 1.0, 1.0, flash_alpha), true)
	var panel := Rect2(318, 190, 964, 500)
	_draw_ranking_panel(panel, Color(1.0, 0.99, 1.0, 0.96), Color("#ffaad1"), 36, 4, true)
	draw_rect(panel.grow(-12.0), Color(1.0, 0.50, 0.78, 0.16), false, 3.0)
	var sparkle_colors := [Color("#ff70b6"), Color("#8de7ff"), Color("#ffe27a"), Color("#a875ff")]
	for i in range(14):
		var angle := clock * 1.7 + float(i) * 0.72
		var distance := 260.0 + sin(clock * 2.0 + float(i)) * 34.0
		var pos := panel.get_center() + Vector2(cos(angle) * distance, sin(angle * 0.88) * 174.0)
		var sparkle_color: Color = sparkle_colors[i % sparkle_colors.size()] as Color
		_draw_stream_start_sparkle(pos, 8.0 + float(i % 3) * 2.0, sparkle_color)
	var display_name := _stream_start_intro_display_name()
	_draw_ranking_text("今日の配信枠", panel.position + Vector2(0, 82), 24, Color("#a954a0"), panel.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_ranking_text(display_name, panel.position + Vector2(0, 126), 38, Color("#4f3149"), panel.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	var big_text := "LIVE START!!" if live_phase else "READY..."
	var big_color := Color("#ff3f94") if live_phase else Color("#7d55d8")
	var pulse_speed := 7.0 if live_phase else 4.5
	var pulse_amount := 0.025 if live_phase else 0.012
	var big_pulse := 1.0 + sin(clock * pulse_speed) * pulse_amount
	var big_rect := Rect2(panel.position + Vector2(122, 190), Vector2(720, 124)).grow((big_pulse - 1.0) * 80.0)
	_draw_ranking_panel(big_rect, Color(1.0, 0.965, 0.995, 0.94), Color("#ffd0e6"), 34, 3, false)
	_draw_ranking_text(big_text, big_rect.position + Vector2(0, 84), 72, big_color, big_rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	var sub_text := "コメント受付開始！" if live_phase else "配信準備中"
	_draw_ranking_text(sub_text, panel.position + Vector2(0, 374), 25, Color("#6b4a63"), panel.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	var bar_back := Rect2(panel.position + Vector2(278, 414), Vector2(408, 16))
	_draw_ranking_panel(bar_back.grow(6.0), Color("#fff8fc"), Color("#f3cfe4"), 12, 2, false)
	draw_rect(Rect2(bar_back.position, Vector2(bar_back.size.x * progress, bar_back.size.y)), Color("#ff67ad"), true)

func _draw_stream_start_sparkle(pos: Vector2, size: float, color: Color) -> void:
	draw_line(pos + Vector2(-size, 0), pos + Vector2(size, 0), color, 2.5, true)
	draw_line(pos + Vector2(0, -size), pos + Vector2(0, size), color, 2.5, true)
	draw_circle(pos, 2.0, Color(1.0, 1.0, 1.0, 0.82))

func _draw_game_over_intro_overlay() -> void:
	var duration := maxf(0.01, game_over_intro_duration)
	var progress := clampf((duration - game_over_intro_timer) / duration, 0.0, 1.0)
	var is_completed := pending_game_over_end_type == "completed"
	var clock := float(Time.get_ticks_msec()) / 1000.0
	if is_completed:
		draw_rect(TITLE_SCREEN_RECT, Color(1.0, 0.96, 0.99, lerpf(0.24, 0.46, progress)), true)
		draw_rect(TITLE_SCREEN_RECT, Color(0.58, 0.92, 1.0, 0.12 + sin(clock * 5.0) * 0.03), true)
	else:
		var dim_alpha := lerpf(0.32, 0.58, progress)
		draw_rect(TITLE_SCREEN_RECT, Color(0.06, 0.02, 0.07, dim_alpha), true)
		for i in range(12):
			var y := fmod(clock * 130.0 + float(i) * 77.0, TITLE_SCREEN_RECT.size.y)
			draw_line(Vector2(0, y), Vector2(TITLE_SCREEN_RECT.size.x, y), Color(0.9, 0.05, 0.35, 0.08), 2.0)
	var pulse := 1.0 + sin(clock * 7.5) * 0.018
	var panel := Rect2(430, 244, 740, 318).grow((pulse - 1.0) * 64.0)
	var panel_border := Color("#ffd46a") if is_completed else Color("#ff7db7")
	var panel_fill := Color(1.0, 0.995, 0.985, 0.97) if is_completed else Color(1.0, 0.972, 0.994, 0.96)
	_draw_ranking_panel(panel, panel_fill, panel_border, 34, 4, true)
	var inner_color := Color(1.0, 0.90, 0.35, 0.14) if is_completed else Color(1.0, 0.46, 0.72, 0.10)
	draw_rect(panel.grow(-14.0), inner_color, false, 3.0)
	var sparkle_colors := [Color("#ff5da8"), Color("#8de7ff"), Color("#ffe27a"), Color("#a875ff")]
	var sparkle_count := 18 if is_completed else 10
	for i in range(sparkle_count):
		var angle := clock * 1.25 + float(i) * 0.84
		var distance := 340.0 + sin(clock * 2.0 + float(i)) * 24.0
		var pos := panel.get_center() + Vector2(cos(angle) * distance, sin(angle * 0.92) * 132.0)
		var sparkle_color: Color = sparkle_colors[i % sparkle_colors.size()] as Color
		if is_completed and i % 3 == 0:
			draw_rect(Rect2(pos, Vector2(14, 6)), sparkle_color, true)
		else:
			_draw_stream_start_sparkle(pos, 6.0 + float(i % 2) * 2.0, sparkle_color)
	draw_circle(panel.position + Vector2(82, 86), 34, Color("#fff0f8"))
	var icon_text := "祝" if is_completed else "心"
	var main_text := "配信完走！" if is_completed else "メンタル崩壊"
	var sub_text := "最後まで乗り切った！" if is_completed else "配信は続けられなかった……"
	var main_color := Color("#ff9f1c") if is_completed else Color("#f04893")
	_draw_ranking_text(icon_text, panel.position + Vector2(63, 101), 28, main_color, 40, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_ranking_text(main_text, panel.position + Vector2(0, 126), 58, main_color, panel.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_ranking_text(sub_text, panel.position + Vector2(0, 186), 25, Color("#6b4a63"), panel.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	var reason_text := pending_game_over_reason.strip_edges()
	if reason_text != "":
		_draw_ranking_text(reason_text, panel.position + Vector2(72, 228), 18, Color("#554155"), panel.size.x - 144.0, HORIZONTAL_ALIGNMENT_CENTER)
	var bar_back := Rect2(panel.position + Vector2(170, 270), Vector2(400, 14))
	_draw_ranking_panel(bar_back.grow(5.0), Color("#fff9fd"), Color("#f2c8de"), 10, 2, false)
	draw_rect(Rect2(bar_back.position, Vector2(bar_back.size.x * progress, bar_back.size.y)), Color("#ffd15c") if is_completed else Color("#ff5aa5"), true)
	if _game_over_intro_can_skip():
		_draw_ranking_text("Enter / Space / Clickでスキップ", panel.position + Vector2(0, 302), 15, Color("#7b6475"), panel.size.x, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_stream_frame_select_header(rect: Rect2) -> void:
	_draw_ranking_panel(rect, Color(1, 1, 1, 0.95), Color("#ead7e9"), 22, 2, true)
	draw_circle(rect.position + Vector2(46, 36), 22, Color("#fff3fb"))
	_draw_ranking_text("枠", rect.position + Vector2(35, 47), 25, Color("#f05aa5"), 28, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_ranking_text("今日の配信枠を選択", rect.position + Vector2(88, 47), 34, Color("#4f3149"), 520)
	_draw_ranking_text("← →：選択 / A D：ページ / Enter Space：決定 / Esc：戻る", rect.position + Vector2(682, 45), 20, Color("#6b4a63"), 710, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_stream_frame_select_list_panel(panel: Rect2, frames: Array, page: int) -> void:
	_draw_ranking_panel(panel, Color(1, 1, 1, 0.93), Color("#ead7e9"), 24, 2, true)
	_draw_ranking_text("配信枠一覧", panel.position + Vector2(30, 46), 28, Color("#7a3fb0"), 360)
	var start: int = page * StreamFrameSystemScript.SELECT_PAGE_SIZE
	for local_index in range(StreamFrameSystemScript.SELECT_PAGE_SIZE):
		var rect: Rect2 = _stream_frame_select_card_rect(local_index)
		var index: int = start + local_index
		if index < frames.size():
			_draw_stream_frame_select_card(rect, frames[index] as Dictionary, index)
		else:
			_draw_stream_frame_select_coming_card(rect)

func _draw_stream_frame_select_card(rect: Rect2, frame: Dictionary, index: int) -> void:
	var view: Dictionary = StreamFrameSystemScript.selection_card_view(frame)
	var selected: bool = index == selected_stream_frame_index
	var selectable: bool = bool(view.get("isSelectable", true))
	var accent: Color = view.get("accent", Color("#f05aa5")) as Color
	var border: Color = Color("#ff62b5") if selected else Color(accent.r, accent.g, accent.b, 0.34)
	var fill: Color = Color(1, 1, 1, 0.98)
	var text_color := Color("#4f3149")
	if not selectable:
		border = Color("#cfc8d6") if not selected else Color("#a887d8")
		fill = Color("#f4f0f5")
		text_color = Color("#7f7480")
	if selected:
		_draw_ranking_panel(rect.grow(6), Color(accent.r, accent.g, accent.b, 0.18), Color(1, 1, 1, 0), 22, 0, false)
	_draw_ranking_panel(rect, fill, border, 20, 4 if selected else 2, false)
	_draw_stream_frame_select_icon(Rect2(rect.position + Vector2(66, 38), Vector2(132, 84)), view, accent, not selectable)
	_draw_ranking_text("%d. %s" % [index + 1, _short_pause_text(String(view.get("plainName", "配信枠")), 9)], rect.position + Vector2(20, 154), 24, text_color if selectable else Color("#8f8793"), rect.size.x - 40, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_ranking_text(String(view.get("difficultyText", "難易度：★")), rect.position + Vector2(20, 184), 17, accent if selectable else Color("#8f8793"), rect.size.x - 40, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_character_select_tag(Rect2(rect.position + Vector2(18, 210), Vector2(rect.size.x - 36, 32)), String(view.get("statusText", "解放済み")), Color("#fff2fa") if selectable else Color("#eee9ef"), accent if selectable else Color("#8f8793"))
	_draw_ranking_text(_short_pause_text(String(view.get("featureText", "")), 20), rect.position + Vector2(18, 264), 14, Color("#5d4658") if selectable else Color("#8f8793"), rect.size.x - 36, HORIZONTAL_ALIGNMENT_CENTER)
	if selected:
		_draw_ranking_text("★", rect.position + Vector2(rect.size.x - 36, 33), 22, Color("#ffd15c"), 28, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_stream_frame_select_coming_card(rect: Rect2) -> void:
	_draw_ranking_panel(rect, Color("#fbf8fc"), Color("#e0d7e2"), 20, 2, false)
	draw_circle(rect.position + rect.size * 0.5 + Vector2(0, -24), 48, Color("#f1eaf2"))
	_draw_ranking_text("COMING", rect.position + Vector2(0, 136), 24, Color("#a294a3"), rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_ranking_text("SOON", rect.position + Vector2(0, 168), 24, Color("#a294a3"), rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_ranking_text("新しい配信枠をお楽しみに！", rect.position + Vector2(20, 224), 15, Color("#8f8793"), rect.size.x - 40, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_stream_frame_select_detail_panel(panel: Rect2, frames: Array) -> void:
	_draw_ranking_panel(panel, Color(1, 1, 1, 0.93), Color("#ead7e9"), 24, 2, true)
	_draw_ranking_text("選択中の配信枠", panel.position + Vector2(30, 46), 28, Color("#ff5aa5"), panel.size.x - 60)
	if frames.is_empty():
		_draw_ranking_text("配信枠データがありません。", panel.position + Vector2(30, 300), 22, Color("#6b4a63"), panel.size.x - 60, HORIZONTAL_ALIGNMENT_CENTER)
		return
	var index: int = clampi(selected_stream_frame_index, 0, frames.size() - 1)
	var frame: Dictionary = frames[index] as Dictionary
	var view: Dictionary = StreamFrameSystemScript.selection_card_view(frame)
	var accent: Color = view.get("accent", Color("#f05aa5")) as Color
	var selectable: bool = bool(view.get("isSelectable", true))
	_draw_stream_frame_select_icon(Rect2(panel.position + Vector2(152, 78), Vector2(238, 156)), view, accent, not selectable, true)
	_draw_ranking_text(String(view.get("plainName", "配信枠")), panel.position + Vector2(30, 274), 34, accent if selectable else Color("#7f7480"), panel.size.x - 60, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_character_select_info_card(Rect2(panel.position + Vector2(28, 326), Vector2(232, 58)), "難易度", String(view.get("difficultyStars", "★")), Color("#fff2fa"), accent)
	_draw_character_select_info_card(Rect2(panel.position + Vector2(282, 326), Vector2(232, 58)), "状態", String(view.get("statusText", "解放済み")), Color("#f3ecff"), accent)
	_draw_character_select_info_card(Rect2(panel.position + Vector2(28, 398), Vector2(panel.size.x - 56, 58)), "特徴", String(view.get("featureText", "")), Color("#e8f7ff"), Color("#4d8ab5"))
	var desc_rect := Rect2(panel.position + Vector2(28, 470), Vector2(panel.size.x - 56, 124))
	_draw_ranking_panel(desc_rect, Color(1, 1, 1, 0.98), Color("#efd5e7"), 16, 2, false)
	_draw_ranking_text("説明", desc_rect.position + Vector2(18, 30), 17, Color("#b1509c"), desc_rect.size.x - 36)
	_draw_multiline_text_item({"pos": desc_rect.position + Vector2(18, 62), "text": String(view.get("description", "")), "width": int(desc_rect.size.x - 36), "size": 17, "color": Color("#5d4658")})
	var note_rect := Rect2(panel.position + Vector2(28, 610), Vector2(panel.size.x - 56, 90))
	_draw_ranking_panel(note_rect, Color("#fff8fc"), Color("#efd5e7"), 16, 2, false)
	var note_title := "おすすめ" if selectable else "解放条件"
	var note_text := String(view.get("recommendText", "")) if selectable else String(view.get("unlockConditionText", ""))
	_draw_ranking_text(note_title, note_rect.position + Vector2(18, 30), 17, Color("#b1509c"), note_rect.size.x - 36)
	_draw_multiline_text_item({"pos": note_rect.position + Vector2(18, 58), "text": note_text, "width": int(note_rect.size.x - 36), "size": 16, "color": Color("#5d4658")})

func _draw_stream_frame_select_footer(layout: Dictionary, frames: Array, page: int, page_count: int) -> void:
	var rect: Rect2 = layout["footer"] as Rect2
	_draw_ranking_panel(rect, Color(1, 1, 1, 0.94), Color("#ead7e9"), 18, 2, true)
	var selectable := false
	if not frames.is_empty() and selected_stream_frame_index >= 0 and selected_stream_frame_index < frames.size():
		selectable = StreamFrameSystemScript.is_selectable(frames[selected_stream_frame_index] as Dictionary)
	_draw_character_select_button(layout["confirmButton"] as Rect2, "決定", Color("#ff93cd"), Color.WHITE, selectable)
	_draw_character_select_button(layout["backButton"] as Rect2, "戻る", Color("#f8f2ff"), Color("#6b4a63"), true)
	_draw_ranking_text("%d / %d" % [page + 1, page_count], rect.position + Vector2(0, 34), 19, Color("#6b4a63"), rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_character_select_button(layout["prevButton"] as Rect2, "← 前", Color("#ffffff"), Color("#6b4a63"), page > 0)
	_draw_character_select_button(layout["nextButton"] as Rect2, "次 →", Color("#ffffff"), Color("#6b4a63"), page + 1 < page_count)

func _draw_stream_frame_select_icon(rect: Rect2, view: Dictionary, accent: Color, muted: bool, large: bool = false) -> void:
	var center: Vector2 = rect.get_center()
	var radius: float = 64.0 if large else 42.0
	var icon_color: Color = Color("#8f8793") if muted else accent
	draw_circle(center, radius, Color(icon_color.r, icon_color.g, icon_color.b, 0.14))
	draw_circle(center, radius, Color(icon_color.r, icon_color.g, icon_color.b, 0.38), false, 3.0)
	var text_size := 24 if large else 18
	var width := radius * 2.0
	_draw_ranking_text(String(view.get("iconText", "LIVE")), center + Vector2(-radius, 8.0), text_size, icon_color, width, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_selection_card_frame(card: Rect2, selected: bool) -> Color:
	var data: Dictionary = DrawDataSystemScript.selection_card_frame_data(card, selected)
	var border: Color = data["border"] as Color
	_draw_panel_rect(data)
	return border

func _draw_stream_frame_card(card: Rect2, view: Dictionary, index: int, selected: bool) -> void:
	var border: Color = _draw_selection_card_frame(card, selected)
	var layout: Dictionary = DrawDataSystemScript.stream_frame_card_layout(card)
	var text_w: int = int(layout["textWidth"])
	_draw_text_item(DrawDataSystemScript.layout_text_item(layout, "title", "[%d] %s" % [index + 1, String(view["displayName"])], border, text_w))
	_draw_card_text_items(DrawDataSystemScript.stream_frame_card_text_items(view, layout))

func _draw_card_text_items(items: Array) -> void:
	for item in items:
		_draw_card_text_item(item as Dictionary)

func _draw_card_text_item(item: Dictionary) -> void:
	var text_item_data: Dictionary = item["item"] as Dictionary
	if bool(item["multiline"]):
		_draw_multiline_text_item(text_item_data)
	else:
		_draw_text_item(text_item_data)

func _draw_choice_backplate() -> void:
	var data: Dictionary = DrawDataSystemScript.choice_backplate_data(state)
	var draw_offset: Vector2 = _choice_drop_offset()
	if data.has("imagePath"):
		var image_rect: Rect2 = data["rect"] as Rect2
		if not _draw_ui_part(String(data["imagePath"]), image_rect.position + draw_offset):
			data["rect"] = image_rect
			if state == "gift_choice" or state == "comment_choice":
				data["rect"] = Rect2(image_rect.position + draw_offset, image_rect.size)
			_draw_panel_rect(data)
	else:
		if (state == "gift_choice" or state == "comment_choice") and data.has("rect"):
			var rect: Rect2 = data["rect"] as Rect2
			data["rect"] = Rect2(rect.position + draw_offset, rect.size)
		_draw_panel_rect(data)
	for part in DrawDataSystemScript.choice_backplate_text_parts(data):
		_draw_simple_draw_part(data, part as Dictionary)

func _gift_choice_drop_offset() -> Vector2:
	if state != "gift_choice":
		return Vector2.ZERO
	var duration: float = 0.36
	var t: float = clampf(gift_choice_enter_time / duration, 0.0, 1.0)
	var eased: float = 1.0 - pow(1.0 - t, 3.0)
	var overshoot: float = sin(t * PI) * 10.0 if t < 1.0 else 0.0
	return Vector2(0.0, lerpf(-170.0, 0.0, eased) + overshoot)

func _comment_choice_drop_offset() -> Vector2:
	if state != "comment_choice":
		return Vector2.ZERO
	var duration: float = 0.36
	var t: float = clampf(comment_choice_enter_time / duration, 0.0, 1.0)
	var eased: float = 1.0 - pow(1.0 - t, 3.0)
	var overshoot: float = sin(t * PI) * 10.0 if t < 1.0 else 0.0
	return Vector2(0.0, lerpf(-170.0, 0.0, eased) + overshoot)

func _choice_drop_offset() -> Vector2:
	if state == "gift_choice":
		return _gift_choice_drop_offset()
	if state == "comment_choice":
		return _comment_choice_drop_offset()
	return Vector2.ZERO

func _gift_choice_card_rect(index: int) -> Rect2:
	return Rect2(Vector2(386.0 + float(index) * 230.0, 320.0) + _gift_choice_drop_offset(), Vector2(206.0, 280.0))

func _comment_choice_card_rect(index: int) -> Rect2:
	return Rect2(Vector2(326.0 + float(index) * 278.0, 322.0) + _comment_choice_drop_offset(), Vector2(265.0, 326.0))

func _draw_gift_choice_card_contents() -> void:
	for i in range(mini(offered_gifts.size(), 3)):
		var gift: Dictionary = offered_gifts[i] as Dictionary
		var rect: Rect2 = _gift_choice_card_rect(i)
		if i == selected_card:
			_draw_gift_choice_cursor(rect)
		var center_x: float = rect.position.x + rect.size.x * 0.5
		var gift_level: int = GiftSystemScript.gift_level_for_target(self, String(gift["id"]))
		var category: String = EquipmentSystem.category_label_for_card(gift, gift_level)
		var display_name: String = EquipmentSystem.display_name_for_card(gift, gift_level)
		var description: String = String(gift["description"])
		var text_color: Color = Color("#101420")
		var sub_color: Color = Color("#273247")
		var texture: Texture2D = _load_equipment_icon(String(gift.get("iconPath", "")))
		if texture != null:
			draw_texture_rect(texture, Rect2(Vector2(center_x - 30.0, rect.position.y + 72.0), Vector2(60.0, 60.0)), false)
		elif not EquipmentSystem.is_instant(gift):
			var fallback_icon: String = DrawDataSystemScript.equipment_icon(String(gift.get("id", "")), EquipmentSystem.is_weapon(gift))
			_draw_centered_card_text(fallback_icon, center_x, rect.position.y + 116.0, rect.size.x - 28.0, 30, Color("#e73763"))
		_draw_centered_card_text("[%d]" % [i + 1], center_x, rect.position.y + 64.0, rect.size.x - 28.0, 18, text_color)
		_draw_centered_card_text("[%s]" % category, center_x, rect.position.y + 142.0, rect.size.x - 28.0, 18, text_color)
		var name_lines: Array[String] = _split_card_text(display_name, 8)
		var name_y: float = rect.position.y + 170.0
		for line in name_lines.slice(0, 2):
			_draw_centered_card_text(String(line), center_x, name_y, rect.size.x - 28.0, 18, text_color)
			name_y += 24.0
		var desc_lines: Array[String] = _split_card_text(description, 9)
		var desc_y: float = name_y + 2.0
		for line in desc_lines.slice(0, 2):
			_draw_centered_card_text(String(line), center_x, desc_y, rect.size.x - 28.0, 16, sub_color)
			desc_y += 21.0
		if not EquipmentSystem.is_instant(gift):
			_draw_centered_card_text("Lv %d/%d" % [gift_level, int(gift["maxLevel"])], center_x, rect.position.y + 246.0, rect.size.x - 28.0, 18, text_color)

func _draw_gift_choice_cursor(rect: Rect2) -> void:
	var cursor_rect: Rect2 = rect.grow(1.0)
	draw_rect(cursor_rect.grow(4.0), Color(0.36, 1.0, 0.58, 0.14))
	draw_rect(cursor_rect, Color("#5cf48a"), false, 4.0)

func _draw_comment_choice_card_contents() -> void:
	if choice_timer <= 5.0:
		_draw_comment_choice_alert_overlay()
	for i in range(mini(offered_comments.size(), 3)):
		var comment: Dictionary = offered_comments[i] as Dictionary
		var rect: Rect2 = _comment_choice_card_rect(i)
		var has_heart: bool = i < heart_cards.size() and bool(heart_cards[i])
		var view: Dictionary = CommentSystemScript.comment_view(comment, has_heart)
		var risk: int = int(view["riskLevel"]) if view.has("riskLevel") else 1
		if i == selected_card:
			_draw_comment_choice_cursor(rect, risk)
		var center_x: float = rect.position.x + rect.size.x * 0.5
		var title_color: Color = Color("#ffffff")
		if risk >= 4:
			title_color = Color("#ffe75c")
		elif risk >= 3:
			title_color = Color("#ff7a36")
		var sub_color: Color = Color("#f5f5f5")
		var metric_color: Color = Color("#ff8a36")
		if risk >= 4:
			metric_color = Color("#ff5a5a")
		_draw_centered_card_text("[%d]" % [i + 1], center_x, rect.position.y + 32.0, rect.size.x - 28.0, 28, Color.WHITE)
		var title_lines: Array[String] = _split_card_text(String(view["displayName"]) if view.has("displayName") else "", 8)
		var title_y: float = rect.position.y + 66.0
		for line in title_lines.slice(0, 2):
			_draw_centered_card_text(String(line), center_x, title_y, rect.size.x - 34.0, 27, title_color)
			title_y += 32.0
		var desc_lines: Array[String] = _split_card_text(String(view["description"]) if view.has("description") else "", 9)
		var icon: Texture2D = _load_instruction_comment_icon(String(comment.get("id", "")))
		if icon != null:
			var icon_size: Vector2 = Vector2(118.0, 118.0)
			var icon_rect: Rect2 = Rect2(Vector2(center_x - icon_size.x * 0.5, rect.position.y + 112.0), icon_size)
			draw_texture_rect(icon, icon_rect, false)
			for line in desc_lines.slice(0, 1):
				_draw_centered_card_text(String(line), center_x, rect.position.y + 232.0, rect.size.x - 42.0, 20, sub_color)
		else:
			var desc_y: float = rect.position.y + 158.0
			for line in desc_lines.slice(0, 3):
				_draw_centered_card_text(String(line), center_x, desc_y, rect.size.x - 42.0, 20, sub_color)
				desc_y += 25.0
		draw_line(rect.position + Vector2(42.0, 248.0), rect.position + Vector2(rect.size.x - 42.0, 248.0), Color(1, 1, 1, 0.25), 2.0)
		var multiplier: float = float(view["multiplier"]) if view.has("multiplier") else 1.0
		var gift_hype_on_select: int = int(view["giftHypeOnSelect"]) if view.has("giftHypeOnSelect") else 0
		_draw_centered_card_text("倍率 x%.1f" % [multiplier], center_x, rect.position.y + 257.0, rect.size.x - 38.0, 26, metric_color)
		_draw_centered_card_text("ギフト期待 +%d" % [gift_hype_on_select], center_x, rect.position.y + 289.0, rect.size.x - 38.0, 21, Color("#ffd46a"))
	_draw_comment_choice_footer()

func _draw_comment_choice_cursor(rect: Rect2, risk: int) -> void:
	var color: Color = Color("#8df7ff")
	if risk >= 4:
		color = Color("#ffe45c")
	elif risk >= 3:
		color = Color("#ff783a")
	draw_rect(rect.grow(5.0), Color(color.r, color.g, color.b, 0.15))
	draw_rect(rect.grow(1.0), color, false, 4.0)

func _load_instruction_comment_icon(comment_id: String) -> Texture2D:
	var path: String = ""
	if comment_id == "banana_floor":
		path = "res://assets/generated/instruction_comment_icons_v1/banana_floor_icon.png"
	elif comment_id == "reverse_control":
		path = "res://assets/generated/instruction_comment_icons_v1/reverse_control_icon.png"
	elif comment_id == "no_dash":
		path = "res://assets/generated/instruction_comment_icons_v1/no_dash_icon.png"
	elif comment_id == "no_brake":
		path = "res://assets/generated/instruction_comment_icons_v1/no_brake_icon.png"
	elif comment_id == "no_stop":
		path = "res://assets/generated/instruction_comment_icons_v1/no_stop_icon.png"
	elif comment_id == "giant_enemies":
		path = "res://assets/generated/instruction_comment_icons_v1/giant_enemies_icon.png"
	elif comment_id == "enemy_speed_up":
		path = "res://assets/generated/instruction_comment_icons_v1/enemy_speed_up_icon.png"
	elif comment_id == "enemy_spawn_up":
		path = "res://assets/generated/instruction_comment_icons_v1/enemy_spawn_up_icon.png"
	elif comment_id == "split_enemy":
		path = "res://assets/generated/instruction_comment_icons_v1/split_enemy_icon.png"
	elif comment_id == "short_range":
		path = "res://assets/generated/instruction_comment_icons_v1/short_range_icon.png"
	elif comment_id == "attack_right_only":
		path = "res://assets/generated/instruction_comment_icons_v1/attack_right_only_icon.png"
	elif comment_id == "temp_walls":
		path = "res://assets/generated/instruction_comment_icons_v1/temp_walls_icon.png"
	elif comment_id == "damage_pits":
		path = "res://assets/generated/instruction_comment_icons_v1/damage_pits_icon.png"
	elif comment_id == "hide_hp":
		path = "res://assets/generated/instruction_comment_icons_v1/hide_hp_icon.png"
	elif comment_id == "comment_barrage":
		path = "res://assets/generated/instruction_comment_icons_v1/comment_barrage_icon.png"
	elif comment_id == "camera_zoom":
		path = "res://assets/generated/instruction_comment_icons_v1/camera_zoom_icon.png"
	elif comment_id == "summon_boss":
		path = "res://assets/generated/instruction_comment_icons_v1/summon_boss_icon.png"
	if path == "":
		return null
	return TextureCacheSystemScript.load_png_texture(equipment_icon_cache, path)

func _draw_comment_choice_alert_overlay() -> void:
	var ui_time: float = float(Time.get_ticks_msec()) / 1000.0
	var pulse: float = 0.5 + sin(ui_time * 9.0) * 0.5
	var panel_rect: Rect2 = Rect2(Vector2(270.0, 145.0) + _comment_choice_drop_offset(), Vector2(930.0, 560.0))
	draw_rect(panel_rect, Color(1.0, 0.0, 0.0, 0.03 + pulse * 0.16))
	draw_rect(panel_rect.grow(-5.0), Color(1.0, 0.06, 0.02, 0.12 + pulse * 0.50), false, 7.0)
	draw_rect(panel_rect.grow(-13.0), Color(1.0, 0.12, 0.04, 0.05 + pulse * 0.20), false, 3.0)

func _draw_comment_choice_footer() -> void:
	var footer_rect: Rect2 = Rect2(Vector2(530.0, 668.0) + _comment_choice_drop_offset(), Vector2(410.0, 32.0))
	draw_rect(footer_rect.grow(-3.0), Color(0.0, 0.0, 0.0, 0.82))
	var remain: float = maxf(0.0, choice_timer)
	var text_color: Color = Color.WHITE
	if choice_timer <= 5.0:
		text_color = Color("#ff3232")
		draw_rect(footer_rect.grow(-2.0), Color(0.35, 0.0, 0.0, 0.82))
	_draw_centered_card_text("自動選択まで %.1fs　　1 / 2 / 3 で選択" % [remain], footer_rect.position.x + footer_rect.size.x * 0.5, footer_rect.position.y + 7.0, footer_rect.size.x - 18.0, 20, text_color)

func _draw_centered_card_text(text: String, center_x: float, y: float, width: float, size: int, color: Color) -> void:
	_draw_text_item({
		"pos": Vector2(center_x - width * 0.5, y),
		"text": text,
		"width": width,
		"size": size,
		"color": color
	}, "", HORIZONTAL_ALIGNMENT_CENTER)

func _split_card_text(text: String, max_chars: int) -> Array[String]:
	var lines: Array[String] = []
	var current: String = ""
	for i in range(text.length()):
		current += text.substr(i, 1)
		if current.length() >= max_chars:
			lines.append(current)
			current = ""
	if current != "":
		lines.append(current)
	return lines

func _draw_comment_storm() -> void:
	var samples: Array[String] = DisplayTextSystemScript.comment_storm_samples()
	for item in DrawDataSystemScript.comment_storm_draw_data(FIELD_VIEW, elapsed, comment_barrage_setting, kuso_chat_timer > 0.0, samples):
		var data: Dictionary = item as Dictionary
		_draw_text_item(data)

func _draw_tutorial_overlay_v2() -> void:
	var data: Dictionary = DrawDataSystemScript.tutorial_overlay_data()
	for part in DrawDataSystemScript.tutorial_overlay_parts(data):
		_draw_overlay_part(part as Dictionary)

func _draw_zoom_mask() -> void:
	var data: Dictionary = DrawDataSystemScript.zoom_mask_data(FIELD_VIEW)
	for part in DrawDataSystemScript.zoom_mask_parts(data):
		_draw_overlay_part(part as Dictionary)

func _draw_horror_mask() -> void:
	var data: Dictionary = DrawDataSystemScript.horror_mask_data(elapsed)
	for part in DrawDataSystemScript.horror_mask_parts(data, FIELD_VIEW):
		_draw_overlay_part(part as Dictionary)

func _draw_toast() -> void:
	if toast_timer <= 0.0:
		return
	var data: Dictionary = DrawDataSystemScript.toast_data(toast_text)
	for part in DrawDataSystemScript.toast_parts(data, toast_text):
		_draw_overlay_part(part as Dictionary)

func _draw_overlay_part(part: Dictionary) -> void:
	var kind: String = String(part["kind"])
	if kind == "panel":
		_draw_panel_rect(part["data"] as Dictionary)
	elif kind == "text":
		_draw_text_item(part["data"] as Dictionary)
	elif kind == "mask":
		_draw_mask_rect(part["rect"] as Rect2, part["color"] as Color)
	elif kind == "outline":
		_draw_rect_outline(part["rect"] as Rect2, part["color"] as Color, int(part["width"]))

func _draw_mask_rect(rect: Rect2, color: Color) -> void:
	draw_rect(rect, color)

func _draw_speech_bubble(bubble: Dictionary) -> void:
	DrawPrimitiveSystemScript.draw_speech_bubble(self, bubble)

func _draw_colored_poly(points: PackedVector2Array, color: Color) -> void:
	draw_colored_polygon(points, color)

func _draw_polygon_item(points: PackedVector2Array, colors: PackedColorArray) -> void:
	draw_polygon(points, colors)

func _draw_polyline_item(points: PackedVector2Array, color: Color, width: float) -> void:
	draw_polyline(points, color, width)

func _draw_panel_rect(data: Dictionary) -> void:
	DrawPrimitiveSystemScript.draw_panel_rect(self, data)

func _draw_prefixed_panel_rect(data: Dictionary, prefix: String) -> void:
	DrawPrimitiveSystemScript.draw_prefixed_panel_rect(self, data, prefix)

func _draw_rect_outline(rect: Rect2, color: Color, width: int) -> void:
	DrawPrimitiveSystemScript.draw_rect_outline(self, rect, color, width)

func _draw_bar_item(item: Dictionary) -> void:
	DrawPrimitiveSystemScript.draw_bar_item(self, item)

func _draw_rect_item(item: Dictionary, prefix: String = "") -> void:
	DrawPrimitiveSystemScript.draw_rect_item(self, item, prefix)

func _draw_circle_item(item: Dictionary, prefix: String = "", radius_prefix: String = "", filled: bool = true, width: float = -1.0, color_key_override: String = "") -> void:
	DrawPrimitiveSystemScript.draw_circle_item(self, item, prefix, radius_prefix, filled, width, color_key_override)

func _draw_line_item(item: Dictionary, prefix: String = "", width: float = -1.0, color_override: Variant = null) -> void:
	DrawPrimitiveSystemScript.draw_line_item(self, item, prefix, width, color_override)

func _draw_arc_item(item: Dictionary, prefix: String) -> void:
	DrawPrimitiveSystemScript.draw_arc_item(self, item, prefix)

func _draw_fixed_arc(pos: Vector2, radius: float, start_angle: float, end_angle: float, points: int, color: Color, width: float) -> void:
	DrawPrimitiveSystemScript.draw_fixed_arc(self, pos, radius, start_angle, end_angle, points, color, width)

func _draw_rotated_texture(texture: Texture2D, center: Vector2, size: Vector2, angle: float, alpha: float = 1.0) -> void:
	if texture == null:
		return
	var transform_scale: Vector2 = Vector2(world_zoom, world_zoom) if world_draw_active else Vector2.ONE
	draw_set_transform(_screen_pos(center), angle, transform_scale)
	draw_texture_rect(texture, Rect2(-size * 0.5, size), false, Color(1, 1, 1, alpha))
	if world_draw_active:
		_apply_world_transform()
	else:
		_reset_world_transform()

func _draw_text_item(item: Dictionary, prefix: String = "", alignment = HORIZONTAL_ALIGNMENT_LEFT, override_color: Variant = null, override_text: String = "") -> void:
	DrawPrimitiveSystemScript.draw_text_item(self, item, prefix, alignment, override_color, override_text)

func _draw_multiline_text_item(item: Dictionary, alignment = HORIZONTAL_ALIGNMENT_LEFT) -> void:
	DrawPrimitiveSystemScript.draw_multiline_text_item(self, item, alignment)
