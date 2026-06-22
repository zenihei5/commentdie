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
const TITLE_QUIT_BUTTON_IMAGE := "res://assets/title/title_quit_button_alpha.png"
const TITLE_MENU_COUNT := 4
const TITLE_QUIT_INDEX := 3
const CHARACTER_SELECT_HEADER_ICON := "res://assets/generated/character_select_icons_v1/character_select.png"
const STREAM_FRAME_SELECT_HEADER_ICON := "res://assets/generated/stream_frame_select_icons_v1/stream_frame_select.png"
const OPTIONS_HEADER_ICON := "res://assets/generated/options_icons_v1/options_header.png"
const OPTIONS_BGM_ICON := "res://assets/generated/options_icons_v1/option_bgm.png"
const OPTIONS_SE_ICON := "res://assets/generated/options_icons_v1/option_se.png"
const OPTIONS_FULLSCREEN_ICON := "res://assets/generated/options_icons_v1/option_fullscreen.png"
const OPTIONS_WINDOW_SIZE_ICON := "res://assets/generated/options_icons_v1/option_window_size.png"
const OPTIONS_SCREEN_SHAKE_ICON := "res://assets/generated/options_icons_v1/option_screen_shake.png"
const OPTIONS_TUTORIAL_ICON := "res://assets/generated/options_icons_v1/option_tutorial.png"
const RANKING_PODIUM_ICON := "res://assets/generated/ranking_icons_v1/ranking_podium.png"
const RANKING_LOCK_ICON := "res://assets/generated/ranking_icons_v1/lock.png"
const RANKING_RANK_ICON_1 := "res://assets/generated/ranking_icons_v1/rank_1.png"
const RANKING_RANK_ICON_2 := "res://assets/generated/ranking_icons_v1/rank_2.png"
const RANKING_RANK_ICON_3 := "res://assets/generated/ranking_icons_v1/rank_3.png"
const RANKING_RANK_ICON_4_PLUS := "res://assets/generated/ranking_icons_v1/rank_4_plus.png"
const RANKING_END_MENTAL_ICON := "res://assets/generated/ranking_icons_v1/end_mental_breakdown.png"
const RANKING_END_COMPLETE_ICON := "res://assets/generated/ranking_icons_v1/end_stream_complete.png"
const RANKING_FOCUS_TABS := "tabs"
const RANKING_FOCUS_ENTRIES := "entries"
const RANKING_FOCUS_BACK := "back"
const PRE_RUN_SELECT_FOCUS_ITEMS := "items"
const PRE_RUN_SELECT_FOCUS_BACK := "back"
const BAN_JUDGEMENT_WEAPON_SPRITE_PATH := "res://assets/generated/ban_judgement_weapon_sprite_v1/clean.png"
const NO_BRAKE_SWEAT_IMAGE := "res://assets/generated/no_brake_sweat_icon_v1/sweat.png"
const TITLE_BGM_PATH := "res://assets/audio/title_bgm.mp3"
const BOSS_BATTLE_BGM_PATH := "res://assets/audio/boss_battle_bgm.mp3"
const GAME_OVER_RESULT_BGM_PATH := "res://assets/audio/game_over_result_bgm.mp3"
const STREAM_COMPLETE_RESULT_BGM_PATH := "res://assets/audio/stream_complete_result_bgm.mp3"
const BOSS_BGM_FADE_DURATION := 0.75
const CURSOR_MOVE_SE_PATH := "res://assets/audio/cursor_move.mp3"
const CONFIRM_SELECT_SE_PATH := "res://assets/audio/confirm_select.mp3"
const PAUSE_OPEN_SE_PATH := "res://assets/audio/pause_open.mp3"
const BACK_TRANSITION_SE_PATH := "res://assets/audio/back_transition.mp3"
const DASH_SE_PATH := "res://assets/audio/dash_move.mp3"
const INSTRUCTION_COMMENT_ARRIVAL_SE_PATH := "res://assets/audio/instruction_comment_arrival.mp3"
const LASER_SHOT_SE_PATH := "res://assets/audio/laser_shot.mp3"
const BAN_HAMMER_SWING_SE_PATH := "res://assets/audio/ban_hammer_swing.mp3"
const BAN_JUDGEMENT_ATTACK_SE_PATH := "res://assets/audio/ban_judgement_attack.mp3"
const SUPERCHAT_SHOT_SE_PATH := "res://assets/audio/superchat_shot.mp3"
const SPOTLIGHT_ATTACK_SE_PATH := "res://assets/audio/spotlight_attack.mp3"
const KUSA_WAVE_SHOT_SE_PATH := "res://assets/audio/kusa_wave_shot.mp3"
const COMMENT_PIN_THROW_SE_PATH := "res://assets/audio/comment_pin_throw.mp3"
const LISTENER_ATTACK_SE_PATH := "res://assets/audio/listener_attack.mp3"
const MARSHMALLOW_PICKUP_SE_PATH := "res://assets/audio/marshmallow_pickup.mp3"
const KUSO_MARSHMALLOW_PICKUP_SE_PATH := "res://assets/audio/kuso_marshmallow_pickup.mp3"
const GOD_MARSHMALLOW_PICKUP_SE_PATH := "res://assets/audio/god_marshmallow_pickup.mp3"
const EXP_PICKUP_SE_PATH := "res://assets/audio/exp_pickup.mp3"
const GIFT_BOX_ITEM_PICKUP_SE_PATH := "res://assets/audio/gift_box_item_pickup.mp3"
const LEVEL_UP_SE_PATH := "res://assets/audio/level_up.mp3"
const PLAYER_DAMAGE_SE_PATH := "res://assets/audio/player_damage.mp3"
const MENTAL_BREAKDOWN_SE_PATH := "res://assets/audio/mental_breakdown.mp3"
const STREAM_COMPLETE_CLEAR_SE_PATH := "res://assets/audio/stream_complete_clear.mp3"
const LIVE_START_SE_PATH := "res://assets/audio/live_start_air_horn.mp3"
const BOSS_WARNING_SE_PATH := "res://assets/audio/boss_warning.mp3"
const ENEMY_DAMAGE_SE_PATH := "res://assets/audio/enemy_damage.mp3"
const ENEMY_DEFEAT_SE_PATH := "res://assets/audio/enemy_defeat.mp3"
const EMOTE_MINE_EXPLOSION_SE_PATH := "res://assets/audio/emote_mine_explosion.mp3"
const MENTAL_BREAKDOWN_BANRI_IMAGE := "res://assets/generated/game_over_cutin_v1/banri_mental_breakdown.png"
const MENTAL_BREAKDOWN_SUPANA_IMAGE := "res://assets/generated/game_over_cutin_v1/supana_mental_breakdown.png"
const MENTAL_BREAKDOWN_MARON_IMAGE := "res://assets/generated/game_over_cutin_v1/maron_mental_breakdown.png"
const MENTAL_BREAKDOWN_INTRO_BANRI_IMAGE := "res://assets/generated/game_over_intro_cutin_v1/banri_mental_intro.png"
const MENTAL_BREAKDOWN_INTRO_SUPANA_IMAGE := "res://assets/generated/game_over_intro_cutin_v1/supana_mental_intro.png"
const MENTAL_BREAKDOWN_INTRO_MARON_IMAGE := "res://assets/generated/game_over_intro_cutin_v1/maron_mental_intro.png"
const STREAM_COMPLETE_BANRI_IMAGE := "res://assets/generated/game_clear_cutin_v1/banri_stream_complete.png"
const STREAM_COMPLETE_SUPANA_IMAGE := "res://assets/generated/game_clear_cutin_v1/supana_stream_complete.png"
const STREAM_COMPLETE_MARON_IMAGE := "res://assets/generated/game_clear_cutin_v1/maron_stream_complete.png"
const COMMENT_BOOMERANG_IMAGE := "res://assets/generated/comment_boomerang_sprite_v1/comment_boomerang.png"
const STREAM_START_INTRO_DURATION := 1.90
const STREAM_START_INTRO_SKIP_DELAY := 0.30
const STREAM_START_LIVE_START_TIME := 0.90
const GAME_OVER_INTRO_MENTAL_DURATION := 2.5
const GAME_OVER_INTRO_COMPLETE_DURATION := 2.8
const GAME_OVER_INTRO_SKIP_DELAY := 0.5
const MENTAL_BREAKDOWN_SHAKE_POWER := 0.35
const MENTAL_BREAKDOWN_SHAKE_DURATION := 0.22
const MENTAL_BREAKDOWN_FLASH_DURATION := 0.18
const MENTAL_BREAKDOWN_REACTION_DURATION := 1.10
const MENTAL_BREAKDOWN_BGM_FADE_DURATION := 2.20
const RESULT_DROP_DURATION := 0.48
const RESULT_DROP_START_Y := -860.0
const COMMENT_PANEL_BG_V25 := "res://assets/generated/ui_parts_v2/comment_panel_bg_v1_370x606.png"
const HUD_ICON_BANRI_IMAGE := "res://assets/generated/hud_character_icons_v1/banri_hud_icon.png"
const HUD_ICON_SUPANA_IMAGE := "res://assets/generated/hud_character_icons_v1/supana_hud_icon.png"
const HUD_ICON_MARON_IMAGE := "res://assets/generated/hud_character_icons_v1/maron_hud_icon.png"
const HUD_UI_TOP_CARD_STREAM_IMAGE := "res://assets/generated/hud_ui_parts_gen_v1/top_card_stream_198x80.png"
const HUD_UI_TOP_CARD_TIME_IMAGE := "res://assets/generated/hud_ui_parts_gen_v1/top_card_time_198x80.png"
const HUD_UI_TOP_CARD_BUZZ_IMAGE := "res://assets/generated/hud_ui_parts_gen_v1/top_card_buzz_220x80.png"
const HUD_UI_TOP_CARD_VIEWER_IMAGE := "res://assets/generated/hud_ui_parts_gen_v1/top_card_viewer_278x80.png"
const HUD_UI_TOP_CARD_CHARACTER_IMAGE := "res://assets/generated/hud_ui_parts_gen_v1/top_card_character_258x80.png"
const HUD_UI_METRIC_MENTAL_IMAGE := "res://assets/generated/hud_ui_parts_v2/metric_mental_226x62.png"
const HUD_UI_METRIC_EXP_IMAGE := "res://assets/generated/hud_ui_parts_v2/metric_exp_260x62.png"
const HUD_UI_METRIC_GIFT_IMAGE := "res://assets/generated/hud_ui_parts_v2/metric_gift_170x54.png"
const HUD_UI_METRIC_HEART_IMAGE := "res://assets/generated/hud_ui_parts_v2/metric_heart_160x54.png"
const HUD_UI_INSTRUCTION_NORMAL_IMAGE := "res://assets/generated/hud_ui_parts_v2/instruction_panel_normal_1200x76.png"
const HUD_UI_INSTRUCTION_DANGER_IMAGE := "res://assets/generated/hud_ui_parts_v2/instruction_panel_danger_1200x76.png"
const HUD_UI_COMMENT_PANEL_IMAGE := "res://assets/generated/hud_ui_parts_v5/comment_panel_320x752.png"
const HUD_UI_BOTTOM_BASE_IMAGE := "res://assets/generated/hud_ui_parts_v2/bottom_hud_base_1560x90.png"
const HUD_UI_EQUIPMENT_WEAPON_PANEL_IMAGE := "res://assets/generated/hud_ui_parts_v2/equipment_weapon_panel_304x70.png"
const HUD_UI_EQUIPMENT_ACCESSORY_PANEL_IMAGE := "res://assets/generated/hud_ui_parts_v2/equipment_accessory_panel_322x70.png"
const HUD_UI_SLOT_WEAPON_EMPTY_IMAGE := "res://assets/generated/hud_ui_parts_v2/slot_weapon_empty_34x34.png"
const HUD_UI_SLOT_WEAPON_FILLED_IMAGE := "res://assets/generated/hud_ui_parts_v2/slot_weapon_filled_34x34.png"
const HUD_UI_SLOT_ACCESSORY_EMPTY_IMAGE := "res://assets/generated/hud_ui_parts_v2/slot_accessory_empty_34x34.png"
const HUD_UI_SLOT_ACCESSORY_FILLED_IMAGE := "res://assets/generated/hud_ui_parts_v2/slot_accessory_filled_34x34.png"
const HUD_METRIC_ICON_MENTAL_IMAGE := "res://assets/generated/hud_metric_icons_v1/mental.png"
const HUD_METRIC_ICON_EXP_IMAGE := "res://assets/generated/hud_metric_icons_v1/exp.png"
const HUD_METRIC_ICON_GIFT_IMAGE := "res://assets/generated/hud_metric_icons_v1/gift_hype.png"
const HUD_METRIC_ICON_HEART_IMAGE := "res://assets/generated/field_pickup_icons_v1/icons/heart_drop.png"
const HUD_DASH_ICON_IMAGE := "res://assets/generated/hud_dash_icons_v1/dash_tight.png"
const GIFT_STAMP_HIT_IMAGE := "res://assets/generated/gift_quality_stamps_v1/hit_stamp.png"
const GIFT_STAMP_BIG_HIT_IMAGE := "res://assets/generated/gift_quality_stamps_v1/big_hit_stamp.png"
const GIFT_STAMP_EVOLUTION_IMAGE := "res://assets/generated/gift_quality_stamps_v1/evolution_stamp.png"
const TITLE_SCREEN_RECT := Rect2(Vector2.ZERO, Vector2(1600, 900))
const TITLE_SUPANA_RECT := Rect2(Vector2(-210, 160), Vector2(580, 845))
const TITLE_MARON_RECT := Rect2(Vector2(1155, 185), Vector2(460, 822))
const TITLE_BANCHAN_RECT := Rect2(Vector2(125, 285), Vector2(510, 711))
const TITLE_LOGO_RECT := Rect2(Vector2(390, 4), Vector2(820, 442))
const TITLE_BUTTON_RECT := Rect2(Vector2(610, 432), Vector2(380, 340))
const TITLE_BUTTON_SOURCE_SIZE := Vector2(1074, 960)
const TITLE_QUIT_BUTTON_RECT := Rect2(Vector2(635, 775), Vector2(330, 116))
const TITLE_LOGO_DROP_DURATION := 0.72
const TITLE_LOGO_DROP_START_Y_OFFSET := -540.0
const TITLE_CHARACTER_APPEAR_TOTAL_DURATION := 1.28
const TITLE_CHARACTER_APPEAR_DURATION := 0.72
const TITLE_SUPANA_START_OFFSET := Vector2(-430.0, 10.0)
const TITLE_MARON_START_OFFSET := Vector2(490.0, 12.0)
const TITLE_BANCHAN_START_OFFSET := Vector2(0.0, 635.0)
const FIELD_VIEW := Rect2(Vector2(20, 190), Vector2(1200, 590))
const ARENA := Rect2(Vector2(20, 120), Vector2(2200, 1500))
const SIDE := Rect2(Vector2(1210, 174), Vector2(370, 606))
const COMMENT_PANEL_RECT_V25 := Rect2(Vector2(1240, 18), Vector2(320, 752))
const HUD := Rect2(Vector2(18, 788), Vector2(1564, 98))
const CLICK_MOVE_ARRIVE_DISTANCE := 22.0
const CLICK_MOVE_PLAYER_RADIUS := 24.0
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
var stream_start_intro_config: Dictionary = {}
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
var character_select_focus_area := PRE_RUN_SELECT_FOCUS_ITEMS
var stream_frame_select_focus_area := PRE_RUN_SELECT_FOCUS_ITEMS
var title_menu_index := 0
var option_menu_index := 0
var options_return_state := "title"
var character_sprite_cache: Dictionary = {}
var ranking_avatar_source_cache: Dictionary = {}
var equipment_icon_cache: Dictionary = {}
var ui_part_cache: Dictionary = {}
var field_pickup_icon_cache: Dictionary = {}
var raw_png_texture_cache: Dictionary = {}
var offered_comments: Array = []
var offered_gifts: Array = []
var pending_gift_choices := 0
var gift_choice_delay_timer := 0.0
var do_everything_offer_count := 0
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
var active_sub_comment_ids: Array[String] = []

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
var screen_shake_timer := 0.0
var screen_shake_duration := 0.0
var screen_shake_strength := 0.0
var screen_shake_offset := Vector2.ZERO
var hit_stop_timer := 0.0
var screen_flash_timer := 0.0
var screen_flash_duration := 0.0
var screen_flash_color := Color.TRANSPARENT
var selected_card := 0
var special_choice_return_card := 0
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
var player_no_brake_sliding := false
var player_facing_x := 1.0
var click_move_active := false
var click_move_target := Vector2.ZERO
var world_camera_offset := Vector2.ZERO
var world_draw_active := false
var world_zoom: float = 1.0
var world_zoom_target: float = 1.0
var player_hp := 100
var player_max_hp := 100
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
var mental_care_level := 0
var notification_bell_level := 0
var exp_bonus_remainder := 0.0
var comment_radar_level := 0
var comment_radar_range_bonus := 0.0
var item_magnet_speed_rate := 1.0
var comment_radar_fx_timer := 0.0
var mini_humidifier_level := 0
var mini_humidifier_timer := 0.0
var mini_humidifier_hurt_cooldown := 0.0
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
var ranking_focus_area := RANKING_FOCUS_TABS
var ranking_reset_confirm_visible := false
var ranking_reset_confirm_index := 1
var debug_key_latch: Dictionary = {}
var pause_escape_down := false
var pause_menu_index := 0
var pause_confirm_action := ""
var pause_confirm_index := 1
var pause_focus_area := "actions"
var pause_equipment_row := 0
var pause_weapon_slot_index := 0
var pause_accessory_slot_index := 0
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
var debug_rare_comment_boost := false
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
var ban_judgement_weapon_sprite: Texture2D
var comment_boomerang_sprite: Texture2D
var title_bgm_player: AudioStreamPlayer
var gameplay_bgm_player: AudioStreamPlayer
var gameplay_bgm_path := ""
var boss_bgm_player: AudioStreamPlayer
var result_bgm_player: AudioStreamPlayer
var result_bgm_active_path := ""
var boss_bgm_mix := 0.0
var ui_se_player: AudioStreamPlayer
var confirm_se_player: AudioStreamPlayer
var pause_open_se_player: AudioStreamPlayer
var back_transition_se_player: AudioStreamPlayer
var dash_se_player: AudioStreamPlayer
var instruction_comment_arrival_se_player: AudioStreamPlayer
var laser_se_player: AudioStreamPlayer
var ban_hammer_se_player: AudioStreamPlayer
var ban_judgement_se_player: AudioStreamPlayer
var superchat_shot_se_player: AudioStreamPlayer
var spotlight_attack_se_player: AudioStreamPlayer
var kusa_wave_se_player: AudioStreamPlayer
var comment_pin_se_player: AudioStreamPlayer
var listener_attack_se_player: AudioStreamPlayer
var marshmallow_pickup_se_player: AudioStreamPlayer
var kuso_marshmallow_pickup_se_player: AudioStreamPlayer
var god_marshmallow_pickup_se_player: AudioStreamPlayer
var exp_pickup_se_player: AudioStreamPlayer
var gift_box_item_pickup_se_player: AudioStreamPlayer
var level_up_se_player: AudioStreamPlayer
var player_damage_se_player: AudioStreamPlayer
var mental_breakdown_se_player: AudioStreamPlayer
var stream_complete_clear_se_player: AudioStreamPlayer
var live_start_se_player: AudioStreamPlayer
var boss_warning_se_player: AudioStreamPlayer
var enemy_damage_se_player: AudioStreamPlayer
var enemy_defeat_se_player: AudioStreamPlayer
var emote_mine_explosion_se_player: AudioStreamPlayer
var enemy_damage_se_played_frame := -1
var listener_attack_se_played_frame := -1
var stream_start_intro_timer := 0.0
var stream_start_intro_duration := STREAM_START_INTRO_DURATION
var stream_start_intro_skip_down := false
var stream_start_intro_live_start_se_played := false
var game_over_intro_timer := 0.0
var game_over_intro_duration := 0.0
var result_drop_timer := 0.0
var title_logo_drop_timer := TITLE_LOGO_DROP_DURATION
var title_character_appear_timer := TITLE_CHARACTER_APPEAR_TOTAL_DURATION
var pending_game_over_reason := ""
var pending_game_over_end_type := ""

func _ready() -> void:
	rng.randomize()
	ban_hammer_weapon_sprite = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, "res://assets/generated/ban_hammer_weapon_sprite_v1/clean.png")
	ban_judgement_weapon_sprite = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, BAN_JUDGEMENT_WEAPON_SPRITE_PATH)
	comment_boomerang_sprite = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, COMMENT_BOOMERANG_IMAGE)
	_setup_title_bgm()
	_setup_gameplay_bgm()
	_setup_boss_bgm()
	_setup_result_bgm()
	_setup_ui_se()
	_setup_confirm_se()
	_setup_pause_open_se()
	_setup_back_transition_se()
	_setup_dash_se()
	_setup_instruction_comment_arrival_se()
	_setup_laser_se()
	_setup_ban_hammer_se()
	_setup_ban_judgement_se()
	_setup_superchat_shot_se()
	_setup_spotlight_attack_se()
	_setup_kusa_wave_se()
	_setup_comment_pin_se()
	_setup_listener_attack_se()
	_setup_marshmallow_pickup_se()
	_setup_kuso_marshmallow_pickup_se()
	_setup_god_marshmallow_pickup_se()
	_setup_exp_pickup_se()
	_setup_gift_box_item_pickup_se()
	_setup_level_up_se()
	_setup_player_damage_se()
	_setup_mental_breakdown_se()
	_setup_stream_complete_clear_se()
	_setup_live_start_se()
	_setup_boss_warning_se()
	_setup_enemy_damage_se()
	_setup_enemy_defeat_se()
	_setup_emote_mine_explosion_se()
	data_repo = RunStateSystemScript.load_boot_data_for_target(self, character_sprite_cache)
	_build_ui()
	ChatSystemScript.seed_box_for_target(self, chat_box, "normal")
	_update_ui()
	_sync_title_bgm()
	_sync_gameplay_bgm()
	_sync_boss_bgm(0.0)
	_sync_result_bgm()

func _process(delta: float) -> void:
	_update_window_resize_lock()
	_update_world_zoom(delta)
	_update_screen_shake(delta)
	_update_screen_flash(delta)
	_update_title_logo_drop(delta)
	_update_title_character_appear(delta)
	if state != "pause" and state != "result" and state != "stream_start_intro" and state != "game_over_intro":
		ChatSystemScript.update_timer_for_target(self, delta, rng, chat_box)
	if state == "comment_choice":
		comment_choice_enter_time += delta
		_update_comment_choice_box_drop()
	if state == "gift_choice":
		gift_choice_enter_time += delta
		_update_gift_choice_box_drop()
	if state != "stream_start_intro" and state != "game_over_intro":
		_update_pause_input_with_se()
	if _update_front_state(delta):
		_sync_title_bgm()
		_sync_gameplay_bgm()
		_sync_boss_bgm(delta)
		_sync_result_bgm()
		return
	_handle_debug_keys()
	_update_active_state(delta)
	_update_ui()
	_sync_title_bgm()
	_sync_gameplay_bgm()
	_sync_boss_bgm(delta)
	_sync_result_bgm()
	queue_redraw()

func _update_pause_input_with_se() -> void:
	var before_state := state
	StateFlowSystemScript.update_pause_input_for_target(self)
	if before_state != "pause" and state == "pause":
		_play_pause_open_se()
	elif before_state == "pause" and state != "pause":
		_play_back_transition_se()

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

func _setup_result_bgm() -> void:
	result_bgm_player = AudioStreamPlayer.new()
	result_bgm_player.name = "ResultBgmPlayer"
	result_bgm_player.volume_db = SettingsSystemScript.volume_db_from_percent(bgm_volume)
	result_bgm_active_path = GAME_OVER_RESULT_BGM_PATH
	result_bgm_player.stream = _load_looping_audio_stream(result_bgm_active_path)
	add_child(result_bgm_player)

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

func _setup_pause_open_se() -> void:
	pause_open_se_player = AudioStreamPlayer.new()
	pause_open_se_player.name = "PauseOpenSePlayer"
	pause_open_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	pause_open_se_player.stream = _load_audio_stream(PAUSE_OPEN_SE_PATH, false)
	add_child(pause_open_se_player)

func _setup_back_transition_se() -> void:
	back_transition_se_player = AudioStreamPlayer.new()
	back_transition_se_player.name = "BackTransitionSePlayer"
	back_transition_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	back_transition_se_player.stream = _load_audio_stream(BACK_TRANSITION_SE_PATH, false)
	add_child(back_transition_se_player)

func _setup_dash_se() -> void:
	dash_se_player = AudioStreamPlayer.new()
	dash_se_player.name = "DashSePlayer"
	dash_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	dash_se_player.stream = _load_audio_stream(DASH_SE_PATH, false)
	add_child(dash_se_player)

func _setup_instruction_comment_arrival_se() -> void:
	instruction_comment_arrival_se_player = AudioStreamPlayer.new()
	instruction_comment_arrival_se_player.name = "InstructionCommentArrivalSePlayer"
	instruction_comment_arrival_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	instruction_comment_arrival_se_player.stream = _load_audio_stream(INSTRUCTION_COMMENT_ARRIVAL_SE_PATH, false)
	add_child(instruction_comment_arrival_se_player)

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

func _setup_ban_judgement_se() -> void:
	ban_judgement_se_player = AudioStreamPlayer.new()
	ban_judgement_se_player.name = "BanJudgementSePlayer"
	ban_judgement_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	ban_judgement_se_player.stream = _load_audio_stream(BAN_JUDGEMENT_ATTACK_SE_PATH, false)
	add_child(ban_judgement_se_player)

func _setup_superchat_shot_se() -> void:
	superchat_shot_se_player = AudioStreamPlayer.new()
	superchat_shot_se_player.name = "SuperchatShotSePlayer"
	superchat_shot_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	superchat_shot_se_player.stream = _load_audio_stream(SUPERCHAT_SHOT_SE_PATH, false)
	add_child(superchat_shot_se_player)

func _setup_spotlight_attack_se() -> void:
	spotlight_attack_se_player = AudioStreamPlayer.new()
	spotlight_attack_se_player.name = "SpotlightAttackSePlayer"
	spotlight_attack_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	spotlight_attack_se_player.stream = _load_audio_stream(SPOTLIGHT_ATTACK_SE_PATH, false)
	add_child(spotlight_attack_se_player)

func _setup_kusa_wave_se() -> void:
	kusa_wave_se_player = AudioStreamPlayer.new()
	kusa_wave_se_player.name = "KusaWaveSePlayer"
	kusa_wave_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	kusa_wave_se_player.stream = _load_audio_stream(KUSA_WAVE_SHOT_SE_PATH, false)
	add_child(kusa_wave_se_player)

func _setup_comment_pin_se() -> void:
	comment_pin_se_player = AudioStreamPlayer.new()
	comment_pin_se_player.name = "CommentPinSePlayer"
	comment_pin_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	comment_pin_se_player.stream = _load_audio_stream(COMMENT_PIN_THROW_SE_PATH, false)
	add_child(comment_pin_se_player)

func _setup_listener_attack_se() -> void:
	listener_attack_se_player = AudioStreamPlayer.new()
	listener_attack_se_player.name = "ListenerAttackSePlayer"
	listener_attack_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	listener_attack_se_player.stream = _load_audio_stream(LISTENER_ATTACK_SE_PATH, false)
	add_child(listener_attack_se_player)

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

func _setup_god_marshmallow_pickup_se() -> void:
	god_marshmallow_pickup_se_player = AudioStreamPlayer.new()
	god_marshmallow_pickup_se_player.name = "GodMarshmallowPickupSePlayer"
	god_marshmallow_pickup_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	god_marshmallow_pickup_se_player.stream = _load_audio_stream(GOD_MARSHMALLOW_PICKUP_SE_PATH, false)
	add_child(god_marshmallow_pickup_se_player)

func _setup_exp_pickup_se() -> void:
	exp_pickup_se_player = AudioStreamPlayer.new()
	exp_pickup_se_player.name = "ExpPickupSePlayer"
	exp_pickup_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	exp_pickup_se_player.stream = _load_audio_stream(EXP_PICKUP_SE_PATH, false)
	add_child(exp_pickup_se_player)

func _setup_gift_box_item_pickup_se() -> void:
	gift_box_item_pickup_se_player = AudioStreamPlayer.new()
	gift_box_item_pickup_se_player.name = "GiftBoxItemPickupSePlayer"
	gift_box_item_pickup_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	gift_box_item_pickup_se_player.stream = _load_audio_stream(GIFT_BOX_ITEM_PICKUP_SE_PATH, false)
	add_child(gift_box_item_pickup_se_player)

func _setup_level_up_se() -> void:
	level_up_se_player = AudioStreamPlayer.new()
	level_up_se_player.name = "LevelUpSePlayer"
	level_up_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	level_up_se_player.stream = _load_audio_stream(LEVEL_UP_SE_PATH, false)
	add_child(level_up_se_player)

func _setup_player_damage_se() -> void:
	player_damage_se_player = AudioStreamPlayer.new()
	player_damage_se_player.name = "PlayerDamageSePlayer"
	player_damage_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	player_damage_se_player.stream = _load_audio_stream(PLAYER_DAMAGE_SE_PATH, false)
	add_child(player_damage_se_player)

func _setup_mental_breakdown_se() -> void:
	mental_breakdown_se_player = AudioStreamPlayer.new()
	mental_breakdown_se_player.name = "MentalBreakdownSePlayer"
	mental_breakdown_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	mental_breakdown_se_player.stream = _load_audio_stream(MENTAL_BREAKDOWN_SE_PATH, false)
	add_child(mental_breakdown_se_player)

func _setup_stream_complete_clear_se() -> void:
	stream_complete_clear_se_player = AudioStreamPlayer.new()
	stream_complete_clear_se_player.name = "StreamCompleteClearSePlayer"
	stream_complete_clear_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	stream_complete_clear_se_player.stream = _load_audio_stream(STREAM_COMPLETE_CLEAR_SE_PATH, false)
	add_child(stream_complete_clear_se_player)

func _setup_live_start_se() -> void:
	live_start_se_player = AudioStreamPlayer.new()
	live_start_se_player.name = "LiveStartSePlayer"
	live_start_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	live_start_se_player.stream = _load_audio_stream(LIVE_START_SE_PATH, false)
	add_child(live_start_se_player)

func _setup_boss_warning_se() -> void:
	boss_warning_se_player = AudioStreamPlayer.new()
	boss_warning_se_player.name = "BossWarningSePlayer"
	boss_warning_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	boss_warning_se_player.stream = _load_audio_stream(BOSS_WARNING_SE_PATH, false)
	add_child(boss_warning_se_player)

func _setup_enemy_damage_se() -> void:
	enemy_damage_se_player = AudioStreamPlayer.new()
	enemy_damage_se_player.name = "EnemyDamageSePlayer"
	enemy_damage_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	enemy_damage_se_player.stream = _load_audio_stream(ENEMY_DAMAGE_SE_PATH, false)
	add_child(enemy_damage_se_player)

func _setup_enemy_defeat_se() -> void:
	enemy_defeat_se_player = AudioStreamPlayer.new()
	enemy_defeat_se_player.name = "EnemyDefeatSePlayer"
	enemy_defeat_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	enemy_defeat_se_player.stream = _load_audio_stream(ENEMY_DEFEAT_SE_PATH, false)
	add_child(enemy_defeat_se_player)

func _setup_emote_mine_explosion_se() -> void:
	emote_mine_explosion_se_player = AudioStreamPlayer.new()
	emote_mine_explosion_se_player.name = "EmoteMineExplosionSePlayer"
	emote_mine_explosion_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	emote_mine_explosion_se_player.stream = _load_audio_stream(EMOTE_MINE_EXPLOSION_SE_PATH, false)
	add_child(emote_mine_explosion_se_player)

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

func _is_pause_options_state() -> bool:
	return state == "options" and options_return_state == "pause"

func _title_bgm_should_play() -> bool:
	return state in ["title", "ranking", "options", "character_select", "stream_frame_select", "stream_start_intro", "tutorial"] and not _is_pause_options_state()

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
	return (state in ["playing", "comment_choice", "gift_choice", "pause", "game_over_intro"] or _is_pause_options_state()) and _stream_frame_bgm_path() != ""

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

func _result_bgm_should_play() -> bool:
	return state == "result"

func _result_bgm_path_for_current_end() -> String:
	if pending_game_over_end_type == "completed":
		return STREAM_COMPLETE_RESULT_BGM_PATH
	return GAME_OVER_RESULT_BGM_PATH

func _set_result_bgm_stream(path: String) -> void:
	if result_bgm_player == null:
		return
	if result_bgm_active_path == path and result_bgm_player.stream != null:
		return
	if result_bgm_player.playing:
		result_bgm_player.stop()
	result_bgm_active_path = path
	result_bgm_player.stream = _load_looping_audio_stream(path)

func _sync_result_bgm() -> void:
	if result_bgm_player == null:
		return
	result_bgm_player.volume_db = SettingsSystemScript.volume_db_from_percent(bgm_volume)
	if _result_bgm_should_play():
		_set_result_bgm_stream(_result_bgm_path_for_current_end())
		if result_bgm_player.stream == null:
			return
		if not result_bgm_player.playing:
			result_bgm_player.play()
	elif result_bgm_player.playing:
		result_bgm_player.stop()

func _boss_bgm_can_fade() -> bool:
	return state in ["playing", "comment_choice", "gift_choice", "pause", "game_over_intro"] or _is_pause_options_state()

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
	var ending_scale := _mental_breakdown_bgm_fade_scale()
	if gameplay_bgm_player != null:
		gameplay_bgm_player.volume_db = _bgm_volume_db_for_scale((1.0 - boss_bgm_mix) * ending_scale)
	if boss_bgm_player != null:
		boss_bgm_player.volume_db = _bgm_volume_db_for_scale(boss_bgm_mix * ending_scale)

func _mental_breakdown_bgm_fade_scale() -> float:
	if not _is_mental_breakdown_intro():
		return 1.0
	return clampf(1.0 - _game_over_intro_elapsed() / MENTAL_BREAKDOWN_BGM_FADE_DURATION, 0.0, 1.0)

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

func _play_pause_open_se() -> void:
	if pause_open_se_player == null or pause_open_se_player.stream == null:
		return
	pause_open_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if pause_open_se_player.playing:
		pause_open_se_player.stop()
	pause_open_se_player.play()

func _play_back_transition_se() -> void:
	if back_transition_se_player == null or back_transition_se_player.stream == null:
		return
	back_transition_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if back_transition_se_player.playing:
		back_transition_se_player.stop()
	back_transition_se_player.play()

func _play_dash_se() -> void:
	if dash_se_player == null or dash_se_player.stream == null:
		return
	dash_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if dash_se_player.playing:
		dash_se_player.stop()
	dash_se_player.play()

func _play_instruction_comment_arrival_se() -> void:
	if instruction_comment_arrival_se_player == null or instruction_comment_arrival_se_player.stream == null:
		return
	instruction_comment_arrival_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if instruction_comment_arrival_se_player.playing:
		instruction_comment_arrival_se_player.stop()
	instruction_comment_arrival_se_player.play()

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

func _play_ban_judgement_se() -> void:
	if ban_judgement_se_player == null or ban_judgement_se_player.stream == null:
		return
	ban_judgement_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if ban_judgement_se_player.playing:
		ban_judgement_se_player.stop()
	ban_judgement_se_player.play()

func _play_superchat_shot_se() -> void:
	if superchat_shot_se_player == null or superchat_shot_se_player.stream == null:
		return
	superchat_shot_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if superchat_shot_se_player.playing:
		superchat_shot_se_player.stop()
	superchat_shot_se_player.play()

func _play_spotlight_attack_se() -> void:
	if spotlight_attack_se_player == null or spotlight_attack_se_player.stream == null:
		return
	spotlight_attack_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if spotlight_attack_se_player.playing:
		spotlight_attack_se_player.stop()
	spotlight_attack_se_player.play()

func _play_kusa_wave_se() -> void:
	if kusa_wave_se_player == null or kusa_wave_se_player.stream == null:
		return
	kusa_wave_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if kusa_wave_se_player.playing:
		kusa_wave_se_player.stop()
	kusa_wave_se_player.play()

func _play_comment_pin_se() -> void:
	if comment_pin_se_player == null or comment_pin_se_player.stream == null:
		return
	comment_pin_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if comment_pin_se_player.playing:
		comment_pin_se_player.stop()
	comment_pin_se_player.play()

func _play_listener_attack_se_once_per_frame() -> void:
	if listener_attack_se_player == null or listener_attack_se_player.stream == null:
		return
	var current_frame: int = Engine.get_process_frames()
	if listener_attack_se_played_frame == current_frame:
		return
	listener_attack_se_played_frame = current_frame
	listener_attack_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if listener_attack_se_player.playing:
		listener_attack_se_player.stop()
	listener_attack_se_player.play()

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

func _play_god_marshmallow_pickup_se() -> void:
	if god_marshmallow_pickup_se_player == null or god_marshmallow_pickup_se_player.stream == null:
		return
	god_marshmallow_pickup_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if god_marshmallow_pickup_se_player.playing:
		god_marshmallow_pickup_se_player.stop()
	god_marshmallow_pickup_se_player.play()

func _play_exp_pickup_se() -> void:
	if exp_pickup_se_player == null or exp_pickup_se_player.stream == null:
		return
	exp_pickup_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if exp_pickup_se_player.playing:
		exp_pickup_se_player.stop()
	exp_pickup_se_player.play()

func _play_gift_box_item_pickup_se() -> void:
	if gift_box_item_pickup_se_player == null or gift_box_item_pickup_se_player.stream == null:
		return
	gift_box_item_pickup_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if gift_box_item_pickup_se_player.playing:
		gift_box_item_pickup_se_player.stop()
	gift_box_item_pickup_se_player.play()

func _play_level_up_se() -> void:
	if level_up_se_player == null or level_up_se_player.stream == null:
		return
	level_up_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if level_up_se_player.playing:
		level_up_se_player.stop()
	level_up_se_player.play()

func _play_player_damage_se() -> void:
	if player_damage_se_player == null or player_damage_se_player.stream == null:
		return
	player_damage_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if player_damage_se_player.playing:
		player_damage_se_player.stop()
	player_damage_se_player.play()

func _play_mental_breakdown_se() -> void:
	if mental_breakdown_se_player == null or mental_breakdown_se_player.stream == null:
		return
	mental_breakdown_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if mental_breakdown_se_player.playing:
		mental_breakdown_se_player.stop()
	mental_breakdown_se_player.play()

func _play_stream_complete_clear_se() -> void:
	if stream_complete_clear_se_player == null or stream_complete_clear_se_player.stream == null:
		return
	stream_complete_clear_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if stream_complete_clear_se_player.playing:
		stream_complete_clear_se_player.stop()
	stream_complete_clear_se_player.play()

func _play_live_start_se() -> void:
	if live_start_se_player == null or live_start_se_player.stream == null:
		return
	live_start_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if live_start_se_player.playing:
		live_start_se_player.stop()
	live_start_se_player.play()

func _play_boss_warning_se() -> void:
	if boss_warning_se_player == null or boss_warning_se_player.stream == null:
		return
	boss_warning_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if boss_warning_se_player.playing:
		boss_warning_se_player.stop()
	boss_warning_se_player.play()

func _play_enemy_damage_se_once_per_frame() -> void:
	if enemy_damage_se_player == null or enemy_damage_se_player.stream == null:
		return
	var current_frame: int = Engine.get_process_frames()
	if enemy_damage_se_played_frame == current_frame:
		return
	enemy_damage_se_played_frame = current_frame
	enemy_damage_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if enemy_damage_se_player.playing:
		enemy_damage_se_player.stop()
	enemy_damage_se_player.play()

func _play_enemy_defeat_se() -> void:
	if enemy_defeat_se_player == null or enemy_defeat_se_player.stream == null:
		return
	enemy_defeat_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if enemy_defeat_se_player.playing:
		enemy_defeat_se_player.stop()
	enemy_defeat_se_player.play()

func _play_emote_mine_explosion_se() -> void:
	if emote_mine_explosion_se_player == null or emote_mine_explosion_se_player.stream == null:
		return
	emote_mine_explosion_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if emote_mine_explosion_se_player.playing:
		emote_mine_explosion_se_player.stop()
	emote_mine_explosion_se_player.play()

func _cursor_sound_snapshot() -> Dictionary:
	return {
		"state": state,
		"titleMenu": title_menu_index,
		"optionMenu": option_menu_index,
		"character": selected_character_index,
		"characterFocus": character_select_focus_area,
		"streamFrame": selected_stream_frame_index,
		"streamFrameFocus": stream_frame_select_focus_area,
		"rankingTab": ranking_tab_index,
		"rankingSelected": ranking_selected_index,
		"rankingFocus": ranking_focus_area,
		"rankingResetConfirmIndex": ranking_reset_confirm_index,
		"pauseMenu": pause_menu_index,
		"pauseFocus": pause_focus_area,
		"pauseEquipRow": pause_equipment_row,
		"pauseWeaponSlot": pause_weapon_slot_index,
		"pauseAccessorySlot": pause_accessory_slot_index,
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
		"characterFocus",
		"streamFrame",
		"streamFrameFocus",
		"rankingTab",
		"rankingSelected",
		"rankingFocus",
		"rankingResetConfirmIndex",
		"pauseMenu",
		"pauseFocus",
		"pauseEquipRow",
		"pauseWeaponSlot",
		"pauseAccessorySlot",
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
	elif state == "ranking" or (state == "result" and result_showing_ranking):
		if event is InputEventMouseButton:
			var ranking_mouse_button := event as InputEventMouseButton
			if ranking_mouse_button.button_index == MOUSE_BUTTON_LEFT and ranking_mouse_button.pressed:
				if _activate_ranking_mouse(ranking_mouse_button.position):
					get_viewport().set_input_as_handled()
	elif state == "result" and not result_showing_ranking:
		if event is InputEventMouseMotion:
			_update_result_mouse_selection((event as InputEventMouseMotion).position)
		elif event is InputEventMouseButton:
			var result_mouse_button := event as InputEventMouseButton
			if result_mouse_button.button_index == MOUSE_BUTTON_LEFT and result_mouse_button.pressed:
				if _activate_result_mouse(result_mouse_button.position):
					get_viewport().set_input_as_handled()
	elif state == "playing":
		if event is InputEventMouseButton:
			var play_mouse_button := event as InputEventMouseButton
			if play_mouse_button.button_index == MOUSE_BUTTON_LEFT and play_mouse_button.pressed:
				if _set_click_move_target_from_screen(play_mouse_button.position):
					get_viewport().set_input_as_handled()

func _set_click_move_target_from_screen(pos: Vector2) -> bool:
	if not FIELD_VIEW.has_point(pos):
		return false
	var target: Vector2 = _world_pos_from_screen(pos)
	target.x = clampf(target.x, ARENA.position.x + CLICK_MOVE_PLAYER_RADIUS, ARENA.end.x - CLICK_MOVE_PLAYER_RADIUS)
	target.y = clampf(target.y, ARENA.position.y + CLICK_MOVE_PLAYER_RADIUS, ARENA.end.y - CLICK_MOVE_PLAYER_RADIUS)
	target = PlayerSystemScript.resolve_wall_collision(target, player_pos, CLICK_MOVE_PLAYER_RADIUS, effect_walls, current_stream_frame_id)
	click_move_target = target
	click_move_active = true
	queue_redraw()
	return true

func _update_title_mouse_selection(pos: Vector2) -> void:
	var index: int = _title_button_index_at(pos)
	if index < 0 or index == title_menu_index:
		return
	title_menu_index = index
	_play_cursor_move_se()
	queue_redraw()

func _title_button_index_at(pos: Vector2) -> int:
	for i in range(TITLE_MENU_COUNT):
		if _title_button_hit_rect(i).has_point(pos):
			return i
	return -1

func _title_button_hit_rect(index: int) -> Rect2:
	if index == TITLE_QUIT_INDEX:
		return TITLE_QUIT_BUTTON_RECT
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
	elif index == TITLE_QUIT_INDEX:
		_quit_game()

func _update_character_select_mouse_selection(pos: Vector2) -> void:
	var index: int = _character_select_index_at(pos)
	if index < 0:
		return
	if index == selected_character_index and character_select_focus_area == PRE_RUN_SELECT_FOCUS_ITEMS:
		return
	character_select_focus_area = PRE_RUN_SELECT_FOCUS_ITEMS
	selected_character_index = index
	_play_cursor_move_se()
	queue_redraw()

func _activate_character_select_mouse(pos: Vector2) -> bool:
	var layout: Dictionary = _character_select_layout()
	if (layout["backButton"] as Rect2).has_point(pos):
		_play_back_transition_se()
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
		if index == selected_character_index:
			_confirm_character_select()
			return true
		character_select_focus_area = PRE_RUN_SELECT_FOCUS_ITEMS
		selected_character_index = index
		queue_redraw()
		return true
	return false

func _character_select_index_at(pos: Vector2) -> int:
	if characters.is_empty():
		return -1
	var page: int = CharacterSystemScript.selection_page_for_index(selected_character_index, characters.size())
	var start: int = page * CharacterSystemScript.SELECT_PAGE_SIZE
	var visible_count: int = CharacterSystemScript.selection_visible_count(characters.size())
	for local_index in range(CharacterSystemScript.SELECT_PAGE_SIZE):
		var index: int = start + local_index
		if index >= visible_count:
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
	character_select_focus_area = PRE_RUN_SELECT_FOCUS_ITEMS
	selected_character_index = CharacterSystemScript.selection_index_for_page(characters, next_page, 0)
	queue_redraw()

func _confirm_character_select() -> void:
	var selected: Dictionary = CharacterSystemScript.selected_character_state_by_index(characters, selected_character_index)
	if selected.is_empty():
		return
	var character: Dictionary = selected["character"] as Dictionary
	if not CharacterSystemScript.is_selectable(character):
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
	if index < 0:
		return
	if index == selected_stream_frame_index and stream_frame_select_focus_area == PRE_RUN_SELECT_FOCUS_ITEMS:
		return
	stream_frame_select_focus_area = PRE_RUN_SELECT_FOCUS_ITEMS
	selected_stream_frame_index = index
	_play_cursor_move_se()
	queue_redraw()

func _activate_stream_frame_select_mouse(pos: Vector2) -> bool:
	var layout: Dictionary = _stream_frame_select_layout()
	if (layout["backButton"] as Rect2).has_point(pos):
		_play_back_transition_se()
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
		if index == selected_stream_frame_index:
			_confirm_stream_frame_select()
			return true
		stream_frame_select_focus_area = PRE_RUN_SELECT_FOCUS_ITEMS
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
	stream_frame_select_focus_area = PRE_RUN_SELECT_FOCUS_ITEMS
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
	stream_start_intro_duration = float(stream_start_intro_config.get("duration", STREAM_START_INTRO_DURATION))
	stream_start_intro_timer = stream_start_intro_duration
	stream_start_intro_skip_down = _stream_start_intro_confirm_down()
	stream_start_intro_live_start_se_played = false
	choice_box.visible = false
	result_panel.visible = false
	queue_redraw()

func _start_pause_retry_intro() -> void:
	_reset_retry_bgm_from_start()
	_start_stream_start_intro()

func _reset_retry_bgm_from_start() -> void:
	boss_bgm_mix = 0.0
	if boss_bgm_player != null:
		boss_bgm_player.stream_paused = false
		if boss_bgm_player.playing:
			boss_bgm_player.stop()
	if gameplay_bgm_player != null:
		gameplay_bgm_player.stream_paused = false
		if gameplay_bgm_player.playing:
			gameplay_bgm_player.stop()
		gameplay_bgm_player.stream = null
	gameplay_bgm_path = ""
	_apply_bgm_volumes()

func _update_stream_start_intro(delta: float) -> void:
	var skip_pressed := _stream_start_intro_skip_pressed()
	stream_start_intro_timer = maxf(0.0, stream_start_intro_timer - delta)
	_maybe_play_stream_start_live_start_se()
	if stream_start_intro_timer <= 0.0 or skip_pressed:
		_restart()

func _maybe_play_stream_start_live_start_se() -> void:
	if stream_start_intro_live_start_se_played:
		return
	if _stream_start_intro_elapsed() < STREAM_START_LIVE_START_TIME:
		return
	stream_start_intro_live_start_se_played = true
	_play_live_start_se()

func _start_game_over_intro(reason: String) -> void:
	_start_ending_cutin(reason, "mental_breakdown")

func _start_stream_complete_intro(reason: String) -> void:
	_start_ending_cutin(reason, "completed")

func _start_ending_cutin(reason: String, end_type: String) -> void:
	if state == "result" or state == "game_over_intro":
		return
	_clear_toast()
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
	if end_type == "mental_breakdown":
		_start_mental_breakdown_impact()
	elif end_type == "completed":
		_play_stream_complete_clear_se()
	var reaction_lines: Array[String] = _ending_cutin_reaction_lines(end_type)
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": reaction_lines}, chat_box)
	queue_redraw()

func _start_mental_breakdown_impact() -> void:
	player_hp = 0
	_request_screen_shake(MENTAL_BREAKDOWN_SHAKE_POWER, MENTAL_BREAKDOWN_SHAKE_DURATION)

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
	var barrage_counts: Array[int] = [4, 6, 8]
	var target_count: int = barrage_counts[clampi(comment_barrage_setting, 0, 2)]
	var pool: Array[String] = [
		"あっ",
		"終わった",
		"メンタルが……",
		"これは事故",
		"コメントのせいだ",
		"戦犯どれ？",
		"配信止まった？",
		"無理だったか……"
	]
	for cause_line in _mental_breakdown_cause_reaction_lines():
		if not pool.has(cause_line):
			pool.append(cause_line)
	var lines: Array[String] = []
	for line in pool:
		lines.append(line)
		if lines.size() >= target_count:
			break
	return lines

func _mental_breakdown_cause_reaction_lines() -> Array[String]:
	var cause_text := "%s %s %s" % [current_comment, pending_game_over_reason, current_death_text]
	if cause_text.contains("ダッシュは甘え"):
		return ["ダッシュ封印きつい", "逃げ切れなかったか", "甘えじゃなかった"]
	if cause_text.contains("ノーブレーキ"):
		return ["止まれなかったか……", "ブレーキ大事", "ノーブレーキは危険"]
	if cause_text.contains("床、全部バナナ"):
		return ["滑ったｗ", "バナナは危険", "床が終わってた"]
	if cause_text.contains("ボスと戦え"):
		return ["挑まなければ……", "ボスは無理だったか", "戦えって言ったの誰"]
	if cause_text.contains("武器ミュート"):
		return ["武器消えたのきつい", "ミュート中だったか……", "攻撃できないの無理"]
	if cause_text.contains("カメラ近すぎ"):
		return ["画角が終わってる", "近すぎた", "見えないのきつい"]
	return ["配信止まるか？"]

func _game_over_intro_elapsed() -> float:
	return maxf(0.0, game_over_intro_duration - game_over_intro_timer)

func _game_over_intro_can_skip() -> bool:
	return state == "game_over_intro" and _game_over_intro_elapsed() >= GAME_OVER_INTRO_SKIP_DELAY

func _is_mental_breakdown_intro() -> bool:
	return state == "game_over_intro" and pending_game_over_end_type == "mental_breakdown"

func _mental_breakdown_impact_ratio(duration: float) -> float:
	if not _is_mental_breakdown_intro():
		return 0.0
	return clampf(1.0 - _game_over_intro_elapsed() / maxf(0.01, duration), 0.0, 1.0)

func _game_over_intro_skip_pressed() -> bool:
	if not _game_over_intro_can_skip():
		return false
	return Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_SPACE)

func _stream_start_intro_display_name() -> String:
	if relay_mode:
		return "配信リレー"
	var display_name := String(current_stream_frame.get("displayName", ""))
	return display_name if display_name != "" else "配信枠"

func _stream_start_intro_elapsed() -> float:
	return clampf(stream_start_intro_duration - stream_start_intro_timer, 0.0, maxf(0.01, stream_start_intro_duration))

func _stream_start_intro_progress() -> float:
	return clampf(_stream_start_intro_elapsed() / maxf(0.01, stream_start_intro_duration), 0.0, 1.0)

func _stream_start_intro_skip_delay() -> float:
	return float(stream_start_intro_config.get("skipDelay", STREAM_START_INTRO_SKIP_DELAY))

func _stream_start_intro_confirm_down() -> bool:
	if Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_SPACE):
		return true
	return InputMap.has_action("ui_accept") and Input.is_action_pressed("ui_accept")

func _stream_start_intro_skip_pressed() -> bool:
	var down := _stream_start_intro_confirm_down()
	var pressed := down and not stream_start_intro_skip_down and _stream_start_intro_elapsed() >= _stream_start_intro_skip_delay()
	stream_start_intro_skip_down = down
	return pressed

func _result_layout() -> Dictionary:
	var offset := _result_drop_offset()
	if String(last_result_data.get("endType", "")) == "completed":
		return {
			"panel": Rect2(Vector2(150, 74) + offset, Vector2(1300, 746)),
			"summaryPanel": Rect2(Vector2(190, 246) + offset, Vector2(350, 464)),
			"detailPanel": Rect2(Vector2(560, 246) + offset, Vector2(520, 464)),
			"characterPanel": Rect2(Vector2(1100, 208) + offset, Vector2(320, 520)),
			"retryButton": Rect2(Vector2(300, 742) + offset, Vector2(330, 56)),
			"rankingButton": Rect2(Vector2(660, 742) + offset, Vector2(260, 56)),
			"titleButton": Rect2(Vector2(950, 742) + offset, Vector2(310, 56))
		}
	if String(last_result_data.get("endType", "")) == "mental_breakdown":
		return {
			"panel": Rect2(Vector2(150, 74) + offset, Vector2(1300, 746)),
			"summaryPanel": Rect2(Vector2(190, 246) + offset, Vector2(350, 464)),
			"detailPanel": Rect2(Vector2(560, 246) + offset, Vector2(520, 464)),
			"characterPanel": Rect2(Vector2(1100, 208) + offset, Vector2(320, 520)),
			"retryButton": Rect2(Vector2(300, 742) + offset, Vector2(330, 56)),
			"rankingButton": Rect2(Vector2(660, 742) + offset, Vector2(260, 56)),
			"titleButton": Rect2(Vector2(950, 742) + offset, Vector2(310, 56))
		}
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
		_play_back_transition_se()
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
	if ranking_reset_confirm_visible and ranking_action != "":
		if _handle_ranking_reset_confirm_action(ranking_action):
			if _cursor_sound_snapshot_changed(cursor_before):
				_play_cursor_move_se()
			_update_ui()
			queue_redraw()
			return true
	var title_action: String = DebugSystemScript.title_action(debug_key_latch) if state == "title" else ""
	var result_action: String = DebugSystemScript.result_action(debug_key_latch) if state == "result" and not result_showing_ranking else ""
	var options_action: String = DebugSystemScript.options_action(debug_key_latch) if state == "options" else ""
	var result: Dictionary = StateFlowSystemScript.front_state_action_for_target(self, delta, title_action, result_action, ranking_action, options_action)
	if not bool(result["handled"]):
		return false
	var action: String = String(result["action"])
	var is_back_transition := action == "back_to_title" or (action == "toggle_ranking" and state == "result" and result_showing_ranking)
	if action in ["start_character_select", "open_title_ranking", "open_title_options", "quit_game"]:
		_play_confirm_se()
	if state == "options" and options_action == "option_select" and not is_back_transition:
		_play_confirm_se()
	if is_back_transition:
		_play_back_transition_se()
	StateFlowSystemScript.apply_front_action(action, {
		"start_character_select": Callable(self, "_start_character_select"),
		"open_title_ranking": Callable(self, "_open_title_ranking"),
		"open_title_options": Callable(self, "_open_title_options"),
		"quit_game": Callable(self, "_quit_game"),
		"reset_title_ranking": Callable(self, "_reset_title_ranking"),
		"ranking_tab_left": Callable(self, "_ranking_tab_left"),
		"ranking_tab_right": Callable(self, "_ranking_tab_right"),
		"ranking_up": Callable(self, "_ranking_up"),
		"ranking_down": Callable(self, "_ranking_down"),
		"ranking_select": Callable(self, "_ranking_select"),
		"back_to_title": Callable(self, "_back_from_front_screen"),
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

func _update_screen_shake(delta: float) -> void:
	if screen_shake_timer <= 0.0:
		screen_shake_strength = 0.0
		screen_shake_duration = 0.0
		screen_shake_offset = Vector2.ZERO
		return
	screen_shake_timer = maxf(0.0, screen_shake_timer - delta)
	if screen_shake_timer <= 0.0:
		screen_shake_strength = 0.0
		screen_shake_duration = 0.0
		screen_shake_offset = Vector2.ZERO
		return
	var t: float = clampf(screen_shake_timer / maxf(0.01, screen_shake_duration), 0.0, 1.0)
	var amp: float = screen_shake_strength * t * t
	screen_shake_offset = Vector2(randf_range(-amp, amp), randf_range(-amp, amp)).round()

func _request_screen_shake(power: float, duration: float = 0.10) -> void:
	if not screen_shake_enabled:
		return
	if power <= 0.0:
		return
	var safe_duration: float = maxf(0.01, duration)
	screen_shake_strength = maxf(screen_shake_strength, power * 28.0)
	screen_shake_duration = maxf(screen_shake_duration, safe_duration)
	screen_shake_timer = maxf(screen_shake_timer, safe_duration)

func _screen_shake_offset() -> Vector2:
	return screen_shake_offset

func _update_screen_flash(delta: float) -> void:
	if screen_flash_timer <= 0.0:
		screen_flash_duration = 0.0
		screen_flash_color = Color.TRANSPARENT
		return
	screen_flash_timer = maxf(0.0, screen_flash_timer - delta)
	if screen_flash_timer <= 0.0:
		screen_flash_duration = 0.0
		screen_flash_color = Color.TRANSPARENT

func _request_screen_flash(color: Color, duration: float) -> void:
	if duration <= 0.0 or color.a <= 0.0:
		return
	screen_flash_color = color
	screen_flash_duration = maxf(screen_flash_duration, duration)
	screen_flash_timer = maxf(screen_flash_timer, duration)

func _draw_screen_flash() -> void:
	if screen_flash_timer <= 0.0 or screen_flash_duration <= 0.0:
		return
	var ratio: float = clampf(screen_flash_timer / screen_flash_duration, 0.0, 1.0)
	var color := screen_flash_color
	color.a *= ratio
	draw_rect(Rect2(Vector2.ZERO, Vector2(1600, 900)), color, true)

func _request_hit_stop(seconds: float) -> void:
	if seconds <= 0.0:
		return
	hit_stop_timer = maxf(hit_stop_timer, minf(seconds, 0.10))

func _consume_hit_stop(delta: float) -> bool:
	if hit_stop_timer <= 0.0:
		return false
	hit_stop_timer = maxf(0.0, hit_stop_timer - delta)
	return true

func _apply_hit_reaction_feedback(feedback: Dictionary) -> void:
	_request_screen_shake(float(feedback.get("screenShakePower", 0.0)), float(feedback.get("screenShakeDuration", 0.10)))
	_request_hit_stop(float(feedback.get("hitStop", 0.0)))
	if float(feedback.get("screenFlashDuration", 0.0)) > 0.0:
		_request_screen_flash(feedback.get("screenFlashColor", Color(1.0, 1.0, 1.0, 0.24)) as Color, float(feedback.get("screenFlashDuration", 0.0)))
	if bool(feedback.get("enemyDamaged", false)):
		_play_enemy_damage_se_once_per_frame()
	if bool(feedback.get("listenerSummonAttacked", false)):
		_play_listener_attack_se_once_per_frame()
	if bool(feedback.get("enemyDefeated", false)):
		_play_enemy_defeat_se()
	if bool(feedback.get("emoteMineExploded", false)):
		_play_emote_mine_explosion_se()
	if bool(feedback.get("bossWarningStarted", false)):
		_play_boss_warning_se()

func _world_transform_position() -> Vector2:
	var center: Vector2 = FIELD_VIEW.get_center()
	return center - (world_camera_offset + center) * world_zoom + _screen_shake_offset()

func _apply_world_transform() -> void:
	draw_set_transform(_world_transform_position(), 0.0, Vector2(world_zoom, world_zoom))

func _reset_world_transform() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _screen_pos(world_pos: Vector2) -> Vector2:
	if not world_draw_active:
		return world_pos
	return world_pos * world_zoom + _world_transform_position()

func _world_pos_from_screen(screen_pos: Vector2) -> Vector2:
	var center: Vector2 = FIELD_VIEW.get_center()
	var camera_offset: Vector2 = _world_camera_offset()
	var transform_pos: Vector2 = center - (camera_offset + center) * world_zoom + _screen_shake_offset()
	return (screen_pos - transform_pos) / world_zoom

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
	_draw_screen_flash()
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
	_draw_click_move_marker()
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
	var title_only: bool = _draws_title_only()
	var modal_overlay_active: bool = StateFlowSystemScript.has_modal_overlay(state) and not title_only
	var special_overlays: Array[String] = []
	if not title_only:
		special_overlays = DrawDataSystemScript.special_overlay_views(self)
	if modal_overlay_active and special_overlays.has("comment_storm"):
		_draw_comment_storm()
	if modal_overlay_active:
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
	if not title_only:
		for special_overlay in special_overlays:
			if String(special_overlay) == "comment_storm":
				if not modal_overlay_active:
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

	if _consume_hit_stop(delta):
		_update_ui()
		return

	_update_stream_frame_events(delta)
	_update_world_systems(delta)
	_update_ui()

func _update_comment_timer(delta: float) -> bool:
	var result: Dictionary = CommentSystemScript.update_spawn_timer_for_target(self, delta)
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, result, chat_box)
	if bool(result["shouldStart"]):
		comment_choice_enter_time = 0.0
		_play_instruction_comment_arrival_se()
		var choice_result: Dictionary = CommentSystemScript.start_choice_ui_for_target(self, comments, rng, CHOICE_TIME, choice_box)
		_prime_choice_selection_latch()
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

func _clear_toast() -> void:
	toast_text = ""
	toast_timer = 0.0

func _reset_time_announcements() -> void:
	time_announcement_flags.clear()
	last_countdown_announcement_second = -1

func _update_stream_frame_events(delta: float) -> void:
	var marshmallow_feedback: Dictionary = MarshmallowSystemScript.update_auto_spawn_if_enabled_for_target(self, current_stream_frame, marshmallow_data, rng, ARENA, effect_walls)
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, marshmallow_feedback, chat_box)
	_update_genre_event(delta)

func _update_world_systems(delta: float) -> void:
	_update_gift_choice_delay(delta)
	_update_player(delta)
	if state != "playing":
		return
	_update_accessory_effects(delta)
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
	if int(exp_result.get("collectedExp", 0)) > 0:
		_play_exp_pickup_se()
	if bool(exp_result["levelUp"]):
		pending_gift_choices += int(exp_result.get("levelUps", 1))
		if gift_choice_delay_timer <= 0.0:
			_start_gift_choice()
	_update_marshmallow(delta)
	var hit_fx_feedback: Dictionary = WeaponSystemScript.update_hit_fx_for_target(self, delta, ARENA, rng)
	_apply_hit_reaction_feedback(hit_fx_feedback)
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, hit_fx_feedback, chat_box)
	if state == "playing" and pending_gift_choices > 0 and gift_choice_delay_timer <= 0.0:
		_start_gift_choice()

func _update_gift_choice_delay(delta: float) -> void:
	if gift_choice_delay_timer <= 0.0:
		return
	gift_choice_delay_timer = maxf(0.0, gift_choice_delay_timer - delta)

func _update_boss(delta: float) -> void:
	var feedback: Dictionary = BossSystemScript.update_for_target(self, delta, ARENA, rng)
	_apply_hit_reaction_feedback(feedback)
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, feedback, chat_box)

func _update_accessory_effects(delta: float) -> void:
	comment_radar_fx_timer = maxf(0.0, comment_radar_fx_timer - delta)
	if mini_humidifier_level <= 0:
		return
	var interval: float = GiftSystemScript.mini_humidifier_interval(mini_humidifier_level)
	if interval <= 0.0:
		return
	if mini_humidifier_hurt_cooldown > 0.0:
		mini_humidifier_hurt_cooldown = maxf(0.0, mini_humidifier_hurt_cooldown - delta)
		return
	if mini_humidifier_timer <= 0.0:
		mini_humidifier_timer = interval
	mini_humidifier_timer -= delta
	if mini_humidifier_timer > 0.0:
		return
	mini_humidifier_timer = interval
	if player_hp >= player_max_hp:
		return
	var heal_amount: int = GiftSystemScript.mini_humidifier_heal_amount(mini_humidifier_level)
	var actual_heal: int = mini(heal_amount, player_max_hp - player_hp)
	if actual_heal <= 0:
		return
	player_hp = mini(player_max_hp, player_hp + actual_heal)
	_append_mini_humidifier_heal_fx(actual_heal)

func _notify_accessory_player_damaged() -> void:
	if mini_humidifier_level <= 0:
		return
	mini_humidifier_hurt_cooldown = GiftSystemScript.MINI_HUMIDIFIER_HURT_PAUSE_SECONDS
	mini_humidifier_timer = GiftSystemScript.mini_humidifier_interval(mini_humidifier_level)

func _append_mini_humidifier_heal_fx(amount: int) -> void:
	var pos: Vector2 = player_pos + Vector2(0.0, -34.0)
	hit_fx.append({
		"kind": "mini_humidifier_heal",
		"pos": pos,
		"life": 0.58,
		"maxLife": 0.58,
		"amount": amount
	})
	hit_fx.append({
		"kind": "pickup_text",
		"pos": pos + Vector2(-34.0, -20.0),
		"vel": Vector2(0.0, -42.0),
		"life": 0.72,
		"maxLife": 0.72,
		"text": "HP +%d" % amount,
		"color": Color("#65e9ff")
	})

func _update_genre_event(delta: float) -> void:
	var feedback: Dictionary = GenreEventSystemScript.update_world_if_enabled_for_target(self, current_stream_frame, delta, genre_events, ARENA, rng)
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, feedback, chat_box)

func _start_character_select() -> void:
	var result: Dictionary = CharacterSystemScript.start_selection_for_target(self, choice_box, result_panel, characters)
	character_select_focus_area = PRE_RUN_SELECT_FOCUS_ITEMS
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": [String(result["chat"])]}, chat_box)
	if bool(result["restart"]):
		_restart()

func _selection_latch_pressed(keycode: Key) -> bool:
	var down: bool = Input.is_key_pressed(keycode)
	var was_down: bool = bool(debug_key_latch.get(keycode, false))
	debug_key_latch[keycode] = down
	return down and not was_down

func _selection_latch_would_press(keycode: Key) -> bool:
	return Input.is_key_pressed(keycode) and not bool(debug_key_latch.get(keycode, false))

func _prime_choice_selection_latch() -> void:
	for keycode in [KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN, KEY_ENTER, KEY_SPACE, KEY_1, KEY_2, KEY_3, KEY_4]:
		debug_key_latch[keycode] = Input.is_key_pressed(keycode)

func _character_select_can_move_down_to_footer() -> bool:
	var visible_count: int = CharacterSystemScript.selection_visible_count(characters.size())
	if visible_count <= 0:
		return false
	var safe_index := clampi(selected_character_index, 0, visible_count - 1)
	var page := int(safe_index / CharacterSystemScript.SELECT_PAGE_SIZE)
	var page_count := CharacterSystemScript.selection_page_count(characters.size())
	var local := safe_index - page * CharacterSystemScript.SELECT_PAGE_SIZE
	return page + 1 >= page_count and (local + CharacterSystemScript.SELECT_COLUMNS >= CharacterSystemScript.SELECT_PAGE_SIZE or safe_index + CharacterSystemScript.SELECT_COLUMNS >= visible_count)

func _update_character_select_back_focus() -> bool:
	if character_select_focus_area != PRE_RUN_SELECT_FOCUS_BACK:
		return false
	var escape_pressed := _selection_latch_pressed(KEY_ESCAPE)
	var backspace_pressed := _selection_latch_pressed(KEY_BACKSPACE)
	var enter_pressed := _selection_latch_pressed(KEY_ENTER)
	var space_pressed := _selection_latch_pressed(KEY_SPACE)
	var up_pressed := _selection_latch_pressed(KEY_UP)
	_selection_latch_pressed(KEY_DOWN)
	_selection_latch_pressed(KEY_LEFT)
	_selection_latch_pressed(KEY_RIGHT)
	_selection_latch_pressed(KEY_A)
	_selection_latch_pressed(KEY_D)
	_selection_latch_pressed(KEY_Q)
	_selection_latch_pressed(KEY_E)
	if escape_pressed or backspace_pressed or enter_pressed or space_pressed:
		_play_back_transition_se()
		_back_to_title()
		return true
	if up_pressed:
		character_select_focus_area = PRE_RUN_SELECT_FOCUS_ITEMS
		return true
	return true

func _update_character_select() -> void:
	if _update_character_select_back_focus():
		return
	var footer_down_requested := _selection_latch_would_press(KEY_DOWN) and _character_select_can_move_down_to_footer()
	var before_state := state
	var result: Dictionary = CharacterSystemScript.update_selection_for_target(self, debug_key_latch, characters)
	if before_state == "character_select" and state == "title":
		_play_back_transition_se()
		return
	if bool(result["startStreamFrameSelect"]):
		_play_confirm_se()
		_start_stream_frame_select()
		return
	if footer_down_requested:
		character_select_focus_area = PRE_RUN_SELECT_FOCUS_BACK

func _start_stream_frame_select() -> void:
	var result: Dictionary = StreamFrameSystemScript.start_selection_for_target(self, choice_box, result_panel, stream_frames)
	stream_frame_select_focus_area = PRE_RUN_SELECT_FOCUS_ITEMS
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": [String(result["chat"])]}, chat_box)
	if bool(result["restart"]):
		_restart()

func _stream_frame_select_can_move_down_to_footer() -> bool:
	var frames: Array = _stream_frame_selection_items()
	if frames.is_empty():
		return false
	var safe_index := clampi(selected_stream_frame_index, 0, frames.size() - 1)
	var page := int(safe_index / StreamFrameSystemScript.SELECT_PAGE_SIZE)
	var page_count := StreamFrameSystemScript.selection_page_count(frames.size())
	var local := safe_index - page * StreamFrameSystemScript.SELECT_PAGE_SIZE
	return page + 1 >= page_count and (local + StreamFrameSystemScript.SELECT_COLUMNS >= StreamFrameSystemScript.SELECT_PAGE_SIZE or safe_index + StreamFrameSystemScript.SELECT_COLUMNS >= frames.size())

func _update_stream_frame_select_back_focus() -> bool:
	if stream_frame_select_focus_area != PRE_RUN_SELECT_FOCUS_BACK:
		return false
	var escape_pressed := _selection_latch_pressed(KEY_ESCAPE)
	var backspace_pressed := _selection_latch_pressed(KEY_BACKSPACE)
	var enter_pressed := _selection_latch_pressed(KEY_ENTER)
	var space_pressed := _selection_latch_pressed(KEY_SPACE)
	var up_pressed := _selection_latch_pressed(KEY_UP)
	_selection_latch_pressed(KEY_DOWN)
	_selection_latch_pressed(KEY_LEFT)
	_selection_latch_pressed(KEY_RIGHT)
	_selection_latch_pressed(KEY_A)
	_selection_latch_pressed(KEY_D)
	_selection_latch_pressed(KEY_Q)
	_selection_latch_pressed(KEY_E)
	if escape_pressed or backspace_pressed or enter_pressed or space_pressed:
		_play_back_transition_se()
		_start_character_select()
		return true
	if up_pressed:
		stream_frame_select_focus_area = PRE_RUN_SELECT_FOCUS_ITEMS
		return true
	return true

func _update_stream_frame_select() -> void:
	if _update_stream_frame_select_back_focus():
		return
	var footer_down_requested := _selection_latch_would_press(KEY_DOWN) and _stream_frame_select_can_move_down_to_footer()
	var result: Dictionary = StreamFrameSystemScript.update_selection_for_target(self, debug_key_latch, stream_frames)
	var chat: String = String(result.get("chat", ""))
	if chat != "":
		chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": [chat]}, chat_box)
	if bool(result["backToCharacterSelect"]):
		_play_back_transition_se()
		_start_character_select()
		return
	if bool(result["restart"]):
		_play_confirm_se()
		_start_stream_start_intro()
		return
	if footer_down_requested:
		stream_frame_select_focus_area = PRE_RUN_SELECT_FOCUS_BACK

func _open_title_ranking() -> void:
	state = "ranking"
	ranking_tab_index = 0
	ranking_selected_index = 0
	ranking_focus_area = RANKING_FOCUS_TABS
	ranking_reset_confirm_visible = false
	ranking_reset_confirm_index = 1
	choice_box.visible = false
	result_panel.visible = false
	_refresh_ranking_screen()

func _reset_title_ranking() -> void:
	ranking_reset_confirm_visible = true
	ranking_reset_confirm_index = 1
	if state == "ranking" or (state == "result" and result_showing_ranking):
		_refresh_ranking_screen()

func _execute_ranking_reset() -> void:
	RankingSystemScript.reset_tab(ranking_tab_index, relay_mode_unlocked)
	ranking_selected_index = 0
	if ranking_focus_area == RANKING_FOCUS_ENTRIES:
		ranking_focus_area = RANKING_FOCUS_TABS
	ranking_reset_confirm_visible = false
	ranking_reset_confirm_index = 1
	if state == "ranking" or (state == "result" and result_showing_ranking):
		_refresh_ranking_screen()

func _cancel_ranking_reset() -> void:
	ranking_reset_confirm_visible = false
	ranking_reset_confirm_index = 1
	if state == "ranking" or (state == "result" and result_showing_ranking):
		_refresh_ranking_screen()

func _handle_ranking_reset_confirm_action(action: String) -> bool:
	if action == "reset_ranking":
		return true
	if action == "ranking_tab_left" or action == "ranking_tab_right" or action == "ranking_up" or action == "ranking_down":
		ranking_reset_confirm_index = 1 - ranking_reset_confirm_index
		return true
	if action == "ranking_select":
		if ranking_reset_confirm_index == 0:
			_play_confirm_se()
			_execute_ranking_reset()
		else:
			_play_back_transition_se()
			_cancel_ranking_reset()
		return true
	if action == "back_to_title":
		_play_back_transition_se()
		_cancel_ranking_reset()
		return true
	return false

func _activate_ranking_mouse(pos: Vector2) -> bool:
	if ranking_reset_confirm_visible:
		return false
	if _ranking_back_button_rect().has_point(pos):
		_activate_ranking_back_button()
		return true
	return false

func _activate_ranking_back_button() -> void:
	_play_back_transition_se()
	if state == "result" and result_showing_ranking:
		_toggle_result_ranking()
	else:
		_back_from_front_screen()

func _ranking_current_entry_count() -> int:
	return RankingSystemScript.entry_count_for_tab(ranking_tab_index, relay_mode_unlocked)

func _ranking_focus_entries_at(index: int) -> void:
	var count := _ranking_current_entry_count()
	ranking_focus_area = RANKING_FOCUS_ENTRIES
	ranking_selected_index = 0 if count <= 0 else clampi(index, 0, count - 1)

func _refresh_ranking_screen() -> void:
	var footer: String = "←→：タブ  ↑↓：記録  Enter：詳細  Esc：戻る  R：リセット"
	if state == "result" and result_showing_ranking:
		footer = "←→：タブ  ↑↓：記録  Enter：詳細  Esc：戻る  R：リセット"
	result_label.text = RankingSystemScript.format_ranking_screen(ranking_tab_index, ranking_selected_index, relay_mode_unlocked) + "\n\n" + footer
	if state == "ranking" or (state == "result" and result_showing_ranking):
		result_panel.visible = false

func _ranking_tab_left() -> void:
	if ranking_reset_confirm_visible:
		_handle_ranking_reset_confirm_action("ranking_tab_left")
		return
	if ranking_focus_area == RANKING_FOCUS_BACK:
		return
	ranking_tab_index = RankingSystemScript.clamp_tab_index(ranking_tab_index - 1, relay_mode_unlocked)
	ranking_selected_index = 0
	if ranking_focus_area == RANKING_FOCUS_ENTRIES and _ranking_current_entry_count() <= 0:
		ranking_focus_area = RANKING_FOCUS_TABS
	_refresh_ranking_screen()

func _ranking_tab_right() -> void:
	if ranking_reset_confirm_visible:
		_handle_ranking_reset_confirm_action("ranking_tab_right")
		return
	if ranking_focus_area == RANKING_FOCUS_BACK:
		return
	ranking_tab_index = RankingSystemScript.clamp_tab_index(ranking_tab_index + 1, relay_mode_unlocked)
	ranking_selected_index = 0
	if ranking_focus_area == RANKING_FOCUS_ENTRIES and _ranking_current_entry_count() <= 0:
		ranking_focus_area = RANKING_FOCUS_TABS
	_refresh_ranking_screen()

func _ranking_up() -> void:
	if ranking_reset_confirm_visible:
		_handle_ranking_reset_confirm_action("ranking_up")
		return
	if ranking_focus_area == RANKING_FOCUS_BACK:
		var last_count := _ranking_current_entry_count()
		if last_count > 0:
			_ranking_focus_entries_at(last_count - 1)
			_refresh_ranking_screen()
		return
	if ranking_focus_area == RANKING_FOCUS_TABS:
		ranking_focus_area = RANKING_FOCUS_BACK
		_refresh_ranking_screen()
		return
	var count := _ranking_current_entry_count()
	if count <= 0:
		ranking_focus_area = RANKING_FOCUS_TABS
		ranking_selected_index = 0
	elif ranking_selected_index <= 0:
		ranking_selected_index = 0
		ranking_focus_area = RANKING_FOCUS_TABS
	else:
		ranking_selected_index -= 1
	_refresh_ranking_screen()

func _ranking_down() -> void:
	if ranking_reset_confirm_visible:
		_handle_ranking_reset_confirm_action("ranking_down")
		return
	if ranking_focus_area == RANKING_FOCUS_BACK:
		ranking_focus_area = RANKING_FOCUS_TABS
		_refresh_ranking_screen()
		return
	if ranking_focus_area == RANKING_FOCUS_TABS:
		var tab_count := _ranking_current_entry_count()
		if tab_count <= 0:
			ranking_selected_index = 0
			ranking_focus_area = RANKING_FOCUS_BACK
		else:
			_ranking_focus_entries_at(0)
		_refresh_ranking_screen()
		return
	var count := _ranking_current_entry_count()
	if count <= 0:
		ranking_selected_index = 0
		ranking_focus_area = RANKING_FOCUS_BACK
	elif ranking_selected_index >= count - 1:
		ranking_selected_index = count - 1
		ranking_focus_area = RANKING_FOCUS_BACK
	else:
		ranking_selected_index += 1
	_refresh_ranking_screen()

func _ranking_select() -> void:
	if ranking_reset_confirm_visible:
		_handle_ranking_reset_confirm_action("ranking_select")
		return
	if ranking_focus_area == RANKING_FOCUS_BACK:
		_activate_ranking_back_button()
		return
	if ranking_focus_area == RANKING_FOCUS_TABS:
		var count := _ranking_current_entry_count()
		if count <= 0:
			ranking_focus_area = RANKING_FOCUS_BACK
		else:
			_ranking_focus_entries_at(0)
	_refresh_ranking_screen()

func _open_title_options() -> void:
	options_return_state = "title"
	state = "options"
	choice_box.visible = false
	result_panel.visible = false
	_refresh_options_screen()

func _quit_game() -> void:
	get_tree().quit()

func _refresh_options_screen() -> void:
	result_label.text = ""
	result_panel.visible = false

func _back_from_front_screen() -> void:
	if state == "options" and options_return_state == "pause":
		state = "pause"
		result_label.text = ""
		result_panel.visible = false
		return
	_back_to_title()

func _back_to_title() -> void:
	options_return_state = "title"
	state = "title"
	game_over_intro_timer = 0.0
	game_over_intro_duration = 0.0
	result_drop_timer = 0.0
	title_logo_drop_timer = TITLE_LOGO_DROP_DURATION
	title_character_appear_timer = TITLE_CHARACTER_APPEAR_TOTAL_DURATION
	pending_game_over_reason = ""
	pending_game_over_end_type = ""
	player_no_brake_sliding = false
	click_move_active = false
	click_move_target = Vector2.ZERO
	banana_floor_appear_timer = 0.0
	banana_floor_rollback_timer = 0.0
	banana_floor_was_active = false
	choice_box.visible = false
	result_panel.visible = false
	_update_title_screen_visibility()

func _update_player(delta: float) -> void:
	var result: Dictionary = PlayerSystemScript.update_for_target(self, delta, ARENA)
	if bool(result.get("dashStarted", false)):
		_play_dash_se()
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
	_apply_hit_reaction_feedback(result)
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, result, chat_box)
	_apply_damage_feedback(DamageSystemScript.apply_damage_events_for_target(self, result.get("damageEvents", []) as Array))

func _update_weapons(delta: float) -> void:
	var result: Dictionary = WeaponSystemScript.update_for_target(self, delta, ARENA, rng)
	if _weapon_update_has_fx(result, "ng_word_laser"):
		_play_laser_se()
	if _weapon_update_has_ban_judgement_swing(result):
		_play_ban_judgement_se()
	elif _weapon_update_has_hammer_swing(result):
		_play_ban_hammer_se()
	if bool(result.get("superchatShotFired", false)):
		_play_superchat_shot_se()
	if _weapon_update_has_fx(result, "spotlight"):
		_play_spotlight_attack_se()
	if _weapon_update_has_fx(result, "kusa_wave"):
		_play_kusa_wave_se()
	if _weapon_update_has_fx(result, "comment_pin"):
		_play_comment_pin_se()
	var feedback: Dictionary = WeaponSystemScript.apply_update_result_for_target(self, result, ARENA, rng)
	_apply_hit_reaction_feedback(feedback)
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

func _weapon_update_has_ban_judgement_swing(result: Dictionary) -> bool:
	for item in (result.get("hitFx", []) as Array):
		var fx: Dictionary = item as Dictionary
		if bool(fx.get("hammer", false)) and bool(fx.get("judgement", false)):
			return true
	return false

func _damage_player(source: String) -> void:
	_apply_damage_feedback(DamageSystemScript.apply_damage_sources_for_target(self, [source]))

func _apply_damage_feedback(feedback: Dictionary) -> void:
	if state == "game_over_intro" or state == "result":
		return
	if bool(feedback.get("damaged", false)):
		_notify_accessory_player_damaged()
		_request_screen_shake(0.16, 0.10)
		if not bool(feedback.get("dead", false)):
			_play_player_damage_se()
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, feedback, chat_box)
	if bool(feedback["dead"]):
		_play_mental_breakdown_se()
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
	if bool(result.get("bossWarningStarted", false)):
		_play_boss_warning_se()
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, result, chat_box)
	if not had_banana_floor and ModifierSystemScript.has_effect_for_target(self, "banana_floor"):
		_start_banana_floor_appear()

func _start_gift_choice() -> void:
	if pending_gift_choices <= 0:
		pending_gift_choices = 1
	pending_gift_choices -= 1
	gift_choice_enter_time = 0.0
	_play_level_up_se()
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
	if bool(feedback.get("godPickupSe", false)):
		_play_god_marshmallow_pickup_se()
	elif bool(feedback.get("kusoPickupSe", false)):
		_play_kuso_marshmallow_pickup_se()
	elif bool(feedback.get("goodPickupSe", false)):
		_play_marshmallow_pickup_se()
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, feedback, chat_box)
	if bool(feedback["levelUp"]):
		pending_gift_choices += int(feedback.get("levelUps", 1))
		if gift_choice_delay_timer <= 0.0:
			_start_gift_choice()
	MarshmallowSystemScript.update_effect_timers_for_target(self, delta)

func _update_destructibles(delta: float) -> void:
	var feedback: Dictionary = DestructibleSystemScript.update_world_for_target(self, delta, ARENA, rng, effect_walls)
	if bool(feedback.get("dropPickupSe", false)):
		_play_gift_box_item_pickup_se()
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
	_clear_toast()
	if pending_game_over_end_type == "":
		pending_game_over_end_type = _end_type_for_finish_reason(reason)
	result_showing_ranking = false
	result_hover_button = "retry"
	result_drop_timer = RESULT_DROP_DURATION
	if pending_game_over_end_type == "mental_breakdown":
		chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": _ending_cutin_reaction_lines("mental_breakdown")}, chat_box)
	ResultSystemScript.open_result_ui_for_target(reason, self, quick_test_mode, choice_box, result_panel, result_label, heart_cards, chat_box)

func _end_type_for_finish_reason(reason: String) -> String:
	if reason.contains("成功") or reason.contains("完走") or player_hp > 0:
		return "completed"
	return "mental_breakdown"

func _toggle_result_ranking() -> void:
	result_showing_ranking = not result_showing_ranking
	result_hover_button = ""
	ranking_reset_confirm_visible = false
	ranking_reset_confirm_index = 1
	if result_showing_ranking:
		ranking_tab_index = 0
		ranking_selected_index = 0
		ranking_focus_area = RANKING_FOCUS_TABS
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
	if action in ["pause_up", "pause_down", "pause_left", "pause_right"]:
		return
	if pause_confirm_action != "":
		if action == "pause_cancel":
			_play_back_transition_se()
			_close_pause_confirm()
			return
		if action == "pause_confirm" or action == "pause_select":
			if pause_confirm_index == 0:
				_accept_pause_confirm()
			else:
				_play_back_transition_se()
				_close_pause_confirm()
			return
	if action == "pause_continue":
		pause_focus_area = "actions"
		pause_menu_index = 0
		_resume_from_pause()
	elif action == "pause_retry":
		pause_focus_area = "actions"
		pause_menu_index = 1
		_open_pause_confirm("retry")
	elif action == "pause_options":
		pause_focus_area = "actions"
		pause_menu_index = 2
		_open_pause_options()
	elif action == "pause_title":
		pause_focus_area = "actions"
		pause_menu_index = 3
		_open_pause_confirm("title")
	elif action == "pause_select":
		if pause_focus_area != "actions":
			return
		if pause_menu_index == 0:
			_resume_from_pause()
		elif pause_menu_index == 1:
			_open_pause_confirm("retry")
		elif pause_menu_index == 2:
			_open_pause_options()
		else:
			_open_pause_confirm("title")

func _update_pause_menu_navigation(delta: float) -> void:
	var nav: int = 0
	if Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W):
		nav = -2
	elif Input.is_key_pressed(KEY_DOWN) or Input.is_key_pressed(KEY_S):
		nav = 2
	elif Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A):
		nav = -1
	elif Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
		nav = 1
	if nav == 0:
		pause_nav_repeat_timer = 0.0
		pause_nav_last_dir = 0
		return
	if pause_confirm_action != "":
		if abs(nav) != 1:
			pause_nav_repeat_timer = 0.0
			pause_nav_last_dir = 0
			return
		if nav != pause_nav_last_dir:
			_apply_pause_confirm_navigation(nav)
			pause_nav_last_dir = nav
			pause_nav_repeat_timer = 0.24
			return
		pause_nav_repeat_timer -= delta
		if pause_nav_repeat_timer <= 0.0:
			_apply_pause_confirm_navigation(nav)
			pause_nav_repeat_timer = 0.10
		return
	if nav != pause_nav_last_dir:
		_apply_pause_navigation(nav)
		pause_nav_last_dir = nav
		pause_nav_repeat_timer = 0.24
		return
	pause_nav_repeat_timer -= delta
	if pause_nav_repeat_timer <= 0.0:
		_apply_pause_navigation(nav)
		pause_nav_repeat_timer = 0.10

func _apply_pause_navigation(nav: int) -> void:
	if nav == -2:
		if pause_focus_area == "actions":
			pause_focus_area = "equipment"
		return
	if nav == 2:
		if pause_focus_area == "equipment":
			pause_focus_area = "actions"
		return
	var dir: int = -1 if nav < 0 else 1
	if pause_focus_area == "actions":
		pause_menu_index = posmod(pause_menu_index + dir, 4)
		return
	_move_pause_equipment_cursor(dir)

func _apply_pause_confirm_navigation(nav: int) -> void:
	var dir: int = -1 if nav < 0 else 1
	pause_confirm_index = posmod(pause_confirm_index + dir, 2)
	_play_cursor_move_se()

func _open_pause_confirm(action: String) -> void:
	pause_confirm_action = action
	pause_confirm_index = 1
	pause_nav_repeat_timer = 0.0
	pause_nav_last_dir = 0

func _close_pause_confirm() -> void:
	pause_confirm_action = ""
	pause_confirm_index = 1
	pause_nav_repeat_timer = 0.0
	pause_nav_last_dir = 0

func _accept_pause_confirm() -> void:
	var confirmed_action: String = pause_confirm_action
	_close_pause_confirm()
	if confirmed_action == "retry":
		_start_pause_retry_intro()
	elif confirmed_action == "title":
		_play_back_transition_se()
		_back_to_title()

func _move_pause_equipment_cursor(dir: int) -> void:
	if pause_equipment_row == 0:
		var next_weapon_index: int = pause_weapon_slot_index + dir
		if next_weapon_index < 0:
			pause_equipment_row = 1
			pause_accessory_slot_index = 4
		elif next_weapon_index > 4:
			pause_equipment_row = 1
			pause_accessory_slot_index = 0
		else:
			pause_weapon_slot_index = next_weapon_index
	else:
		var next_accessory_index: int = pause_accessory_slot_index + dir
		if next_accessory_index < 0:
			pause_equipment_row = 0
			pause_weapon_slot_index = 4
		elif next_accessory_index > 4:
			pause_equipment_row = 0
			pause_weapon_slot_index = 0
		else:
			pause_accessory_slot_index = next_accessory_index

func _resume_from_pause() -> void:
	_play_back_transition_se()
	_close_pause_confirm()
	pause_nav_repeat_timer = 0.0
	pause_nav_last_dir = 0
	state = previous_state if previous_state != "" and previous_state != "pause" else "playing"

func _open_pause_options() -> void:
	_close_pause_confirm()
	options_return_state = "pause"
	state = "options"
	choice_box.visible = false
	result_panel.visible = false
	_refresh_options_screen()

func _draw_pause_overlay() -> void:
	draw_rect(TITLE_SCREEN_RECT, Color(0.04, 0.01, 0.05, 0.62), true)
	var panel: Rect2 = Rect2(Vector2(188, 68), Vector2(1224, 744))
	_draw_ranking_panel(panel, Color(1.0, 0.972, 0.99, 0.98), Color("#ff72ad"), 28, 4, true)
	_draw_text_item({"pos": panel.position + Vector2(40, 54), "text": "ポーズ中", "width": 260, "size": 38, "color": Color("#e73763")})
	_draw_text_item({"pos": panel.position + Vector2(42, 84), "text": "配信を一時停止しています", "width": 360, "size": 17, "color": Color("#7a526b")})
	_draw_pause_status_panel(Rect2(panel.position + Vector2(36, 104), Vector2(1152, 86)))
	_draw_pause_equipment_slot_panel(Rect2(panel.position + Vector2(36, 210), Vector2(560, 244)), true)
	_draw_pause_equipment_slot_panel(Rect2(panel.position + Vector2(628, 210), Vector2(560, 244)), false)
	_draw_pause_current_instruction_panel(Rect2(panel.position + Vector2(36, 474), Vector2(356, 126)))
	_draw_pause_compact_stream_rule_panel(Rect2(panel.position + Vector2(416, 474), Vector2(356, 126)))
	_draw_pause_short_controls_panel(Rect2(panel.position + Vector2(796, 474), Vector2(392, 126)))
	_draw_pause_action_panel(Rect2(panel.position + Vector2(36, 626), Vector2(1152, 84)))

func _draw_pause_status_panel(rect: Rect2) -> void:
	_draw_pause_section_box(rect, Color("#eef9ff"), Color("#bfe8ff"))
	var remaining: float = maxf(0.0, RunStateSystemScript.run_length(quick_test_mode, QUICK_RUN_LENGTH, NORMAL_RUN_LENGTH) - elapsed)
	var status_lines: Array[String] = [
		"配信者：%s　配信枠：%s" % [
			String(current_character.get("displayName", "赤羽ばんり")),
			String(current_stream_frame.get("displayName", "雑談枠"))
		],
		"残り時間：%s　視聴者数：%d人　ボルテージ：x%.1f" % [
			_format_pause_time(remaining),
			score,
			multiplier
		],
		"バズ度：%d　撃破スコア +%d%%　ギフト期待度：%d%%　♡待機：%s" % [
			burn_combo,
			burn_combo * 10,
			gift_hype,
			"あり" if heart_pending else "なし"
		]
	]
	var line_colors: Array[Color] = [Color("#26435c"), Color("#142033"), Color("#6d4b75")]
	for i in range(status_lines.size()):
		_draw_text_item({
			"pos": rect.position + Vector2(20, 27 + i * 24),
			"text": status_lines[i],
			"width": int(rect.size.x - 40),
			"size": 17 if i < 2 else 16,
			"color": line_colors[i]
		})

func _pause_empty_slot_description(is_weapon: bool) -> Dictionary:
	if is_weapon:
		return {"title": "空き武器スロット", "body": "ギフトで武器を入手すると、ここに表示されます"}
	return {"title": "空きアクセサリスロット", "body": "ギフトでアクセサリを入手すると、ここに表示されます"}

func _pause_default_equipment_description() -> Dictionary:
	return {
		"title": "装備説明",
		"body": "武器・アクセサリにカーソルを合わせると説明が表示されます"
	}

func _pause_equipment_description(selected_info: Dictionary, is_weapon: bool, active_row: bool) -> Dictionary:
	if active_row:
		if selected_info.is_empty() or not bool(selected_info.get("filled", false)):
			return _pause_empty_slot_description(is_weapon)
		var level_text: String = "進化" if bool(selected_info.get("evolved", false)) else "Lv%d" % int(selected_info.get("level", 1))
		return {
			"title": "%s %s" % [String(selected_info.get("name", "")), level_text],
			"body": String(selected_info.get("description", ""))
		}
	return _pause_default_equipment_description()

func _draw_pause_description_box(rect: Rect2, accent: Color, description: Dictionary) -> void:
	_draw_ranking_panel(rect, Color(1, 1, 1, 0.86), Color(accent.r, accent.g, accent.b, 0.50), 14, 2, false)
	_draw_ranking_text(String(description.get("title", "")), rect.position + Vector2(16, 34), 19, accent, rect.size.x - 32)
	_draw_ranking_text(_short_pause_text(String(description.get("body", "")), 42), rect.position + Vector2(16, 62), 15, Color("#2d2530"), rect.size.x - 32)

func _draw_pause_equipment_slot_panel(rect: Rect2, is_weapon: bool) -> void:
	var accent: Color = Color("#ffb433") if is_weapon else Color("#45c8df")
	var fill: Color = Color("#fffdf6") if is_weapon else Color("#f4fdff")
	_draw_pause_section_box(rect, fill, accent)
	var title: String = "武器" if is_weapon else "アクセサリ"
	_draw_text_item({"pos": rect.position + Vector2(20, 32), "text": title, "width": 190, "size": 24, "color": accent})
	var selected_index: int = pause_weapon_slot_index if is_weapon else pause_accessory_slot_index
	var row: int = 0 if is_weapon else 1
	var active_row: bool = pause_focus_area == "equipment" and pause_equipment_row == row
	var slot_size := Vector2(58, 58)
	var slot_step := 66.0
	var slot_start := rect.position + Vector2(22, 56)
	var selected_info: Dictionary = {}
	for i in range(5):
		var info: Dictionary = _pause_equipment_slot_info(i, is_weapon)
		if i == selected_index:
			selected_info = info
		var slot_rect := Rect2(slot_start + Vector2(float(i) * slot_step, 0), slot_size)
		_draw_pause_equipment_slot(slot_rect, info, i == selected_index, active_row, accent)
	var desc_rect := Rect2(rect.position + Vector2(18, 132), Vector2(rect.size.x - 36, 90))
	_draw_pause_description_box(desc_rect, accent, _pause_equipment_description(selected_info, is_weapon, active_row))

func _pause_equipment_slot_info(index: int, is_weapon: bool) -> Dictionary:
	var entries: Array = player_weapons if is_weapon else player_accessories
	if index >= entries.size() or not (entries[index] is Dictionary):
		return {"filled": false}
	var entry: Dictionary = entries[index] as Dictionary
	var item_id: String = String(entry.get("id", ""))
	if item_id == "":
		return {"filled": false}
	var data: Dictionary = WeaponSystemScript.find_weapon(weapons, item_id, {}) if is_weapon else _find_gift_data(item_id)
	var name: String = String(data.get("displayName", item_id))
	return {
		"filled": true,
		"id": item_id,
		"name": name,
		"description": String(data.get("description", "")),
		"iconPath": String(data.get("iconPath", entry.get("iconPath", ""))),
		"level": EquipmentSystem.entry_level(entry),
		"evolved": EquipmentSystem.is_evolved_entry(entry) or bool(data.get("isEvolved", false))
	}

func _draw_pause_equipment_slot(rect: Rect2, info: Dictionary, selected: bool, active_focus: bool, accent: Color) -> void:
	var filled: bool = bool(info.get("filled", false))
	var evolved: bool = bool(info.get("evolved", false))
	var active_selected: bool = selected and active_focus
	var border: Color = Color("#ffd15a") if evolved else Color("#d9c8ee")
	if active_selected:
		border = Color("#ff4f9b")
	var fill: Color = Color("#fff4d6") if evolved else (Color(1, 1, 1, 0.95) if filled else Color(1, 1, 1, 0.40))
	_draw_ranking_panel(rect, fill, border, 11, 4 if active_selected else (2 if filled else 1), false)
	if active_selected:
		draw_rect(rect.grow(4), Color("#ff5b9c"), false, 2.0)
	if not filled:
		draw_rect(Rect2(rect.position + Vector2(13, 13), rect.size - Vector2(26, 26)), Color(1, 1, 1, 0.22), true)
		return
	var icon: Texture2D = _load_equipment_icon(String(info.get("iconPath", "")))
	if icon != null:
		draw_texture_rect(icon, _fit_texture_rect(rect.grow(-7), icon.get_size()), false)
	else:
		_draw_ranking_text(_short_pause_text(String(info.get("name", "")), 2), rect.position + Vector2(0, 37), 17, Color("#7a56c8"), rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	var badge_text: String = "進化" if evolved else "Lv%d" % int(info.get("level", 1))
	var badge_width: float = 34.0 if evolved else 32.0
	var badge_rect := Rect2(rect.end - Vector2(badge_width + 3.0, 17.0), Vector2(badge_width, 15.0))
	_draw_ranking_panel(badge_rect, Color("#ffd15a") if evolved else Color("#ff72ad"), Color(1, 1, 1, 0.0), 5, 0, false)
	_draw_ranking_text(badge_text, badge_rect.position + Vector2(0, 12), 9, Color("#6a3a00") if evolved else Color.WHITE, badge_rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_pause_current_instruction_panel(rect: Rect2) -> void:
	_draw_pause_section_box(rect, Color("#fff8fc"), Color("#ff8fc4"))
	_draw_text_item({"pos": rect.position + Vector2(18, 30), "text": "現在の指示コメ", "width": 230, "size": 21, "color": Color("#e73763")})
	var text_pos := rect.position + Vector2(20, 58)
	var text_width := int(rect.size.x - 40)
	if current_comment != "なし" and effect_timer > 0.0:
		var icon: Texture2D = _load_instruction_comment_icon(last_comment_id)
		if icon != null:
			var icon_rect := Rect2(rect.position + Vector2(20, 50), Vector2(48, 48))
			draw_texture_rect(icon, icon_rect, false)
			text_pos.x += 58.0
			text_width -= 58
	_draw_multiline_text_item({"pos": text_pos, "text": _pause_instruction_text(), "width": text_width, "size": 15, "color": Color("#142033")})

func _draw_pause_compact_stream_rule_panel(rect: Rect2) -> void:
	_draw_pause_section_box(rect, Color("#fffdf4"), Color("#ffbf5c"))
	_draw_text_item({"pos": rect.position + Vector2(18, 30), "text": "配信枠ルール", "width": 220, "size": 21, "color": Color("#d97706")})
	var frame_name: String = String(current_stream_frame.get("displayName", "雑談枠"))
	_draw_ranking_text(frame_name, rect.position + Vector2(20, 58), 17, Color("#8f4b00"), rect.size.x - 40)
	_draw_multiline_text_item({"pos": rect.position + Vector2(20, 82), "text": _short_pause_text(_pause_stream_rule_text(), 45), "width": int(rect.size.x - 40), "size": 14, "color": Color("#33281e")})

func _draw_pause_short_controls_panel(rect: Rect2) -> void:
	_draw_pause_section_box(rect, Color("#f8fbff"), Color("#c9d7ef"))
	_draw_text_item({"pos": rect.position + Vector2(18, 30), "text": "操作", "width": 160, "size": 21, "color": Color("#6b7280")})
	var text: String = "移動：WASD / 方向キー\nダッシュ：同方向2回\n指示コメ：1 / 2 / 3\nEsc：ポーズ解除"
	_draw_multiline_text_item({"pos": rect.position + Vector2(20, 58), "text": text, "width": int(rect.size.x - 40), "size": 15, "color": Color("#34445c")})

func _draw_pause_action_panel(rect: Rect2) -> void:
	_draw_pause_section_box(rect, Color("#fff8fc"), Color("#ffd2e5"))
	if pause_confirm_action != "":
		var action_text: String = "リトライしますか？" if pause_confirm_action == "retry" else "タイトルへ戻りますか？"
		_draw_ranking_text(action_text, rect.position + Vector2(32, 50), 22, Color("#e73763"), rect.size.x * 0.42, HORIZONTAL_ALIGNMENT_CENTER)
		var confirm_labels: Array[String] = ["はい", "いいえ"]
		var button_width := 190.0
		var confirm_gap := 22.0
		var start_x := rect.position.x + rect.size.x * 0.55
		for i in range(confirm_labels.size()):
			var selected: bool = i == pause_confirm_index
			var item_rect := Rect2(Vector2(start_x + float(i) * (button_width + confirm_gap), rect.position.y + 17.0), Vector2(button_width, 50.0))
			var fill := Color("#ff5b9c") if selected else Color(1, 1, 1, 0.88)
			var border := Color("#ff5b9c") if selected else Color("#e6cfe1")
			_draw_ranking_panel(item_rect, fill, border, 16, 3 if selected else 2, false)
			_draw_ranking_text(confirm_labels[i], item_rect.position + Vector2(0, 32), 20, Color.WHITE if selected else Color("#573349"), item_rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)
		return
	var labels: Array[String] = ["配信に戻る", "リトライ", "オプション", "タイトルへ"]
	var gap := 20.0
	var button_width := (rect.size.x - 48.0 - gap * 3.0) / 4.0
	for i in range(labels.size()):
		var selected: bool = pause_focus_area == "actions" and i == pause_menu_index
		var item_rect := Rect2(rect.position + Vector2(24.0 + float(i) * (button_width + gap), 17.0), Vector2(button_width, 50.0))
		var fill := Color("#ff5b9c") if selected else Color(1, 1, 1, 0.88)
		var border := Color("#ff5b9c") if selected else Color("#e6cfe1")
		_draw_ranking_panel(item_rect, fill, border, 16, 3 if selected else 2, false)
		_draw_ranking_text("[%d] %s" % [i + 1, labels[i]], item_rect.position + Vector2(0, 32), 19, Color.WHITE if selected else Color("#573349"), item_rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_pause_section_box(rect: Rect2, fill: Color, border: Color) -> void:
	_draw_ranking_panel(rect, fill, border, 18, 2, false)

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
	var text: String = "移動：WASD / 方向キー　ダッシュ：同じ方向を2回押し\n指示コメ選択：1 / 2 / 3　Esc：ポーズ解除"
	_draw_multiline_text_item({"pos": rect.position + Vector2(18, 29), "text": text, "width": int(rect.size.x - 36), "size": 16, "color": Color("#34445c")})

func _draw_pause_menu_panel(rect: Rect2) -> void:
	_draw_pause_box(rect, Color("#fff7fb"))
	if pause_confirm_action != "":
		var action_text: String = "リトライしますか？" if pause_confirm_action == "retry" else "タイトルへ戻りますか？"
		_draw_ranking_text(action_text, rect.position + Vector2(18, 30), 17, Color("#e73763"), rect.size.x - 36, HORIZONTAL_ALIGNMENT_CENTER)
		var confirm_labels: Array[String] = ["はい", "いいえ"]
		for i in range(confirm_labels.size()):
			var selected: bool = i == pause_confirm_index
			var x: float = rect.position.x + 82.0 + float(i) * 170.0
			var item_rect: Rect2 = Rect2(Vector2(x, rect.position.y + 50.0), Vector2(136.0, 34.0))
			draw_rect(item_rect, Color("#ff5b9c") if selected else Color("#ffffff"))
			_draw_rect_outline(item_rect, Color("#ff5b9c"), 2)
			_draw_text_item({
				"pos": item_rect.position + Vector2(0, 24),
				"text": confirm_labels[i],
				"width": int(item_rect.size.x),
				"size": 16,
				"color": Color.WHITE if selected else Color("#142033")
			}, "", HORIZONTAL_ALIGNMENT_CENTER)
		return
	var labels: Array[String] = ["配信に戻る", "リトライ", "タイトルへ"]
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
		var level_text: String = "進化" if EquipmentSystem.is_evolved_entry(entry) else "Lv%d" % EquipmentSystem.entry_level(entry)
		result.append("%d. %s %s" % [i + 1, name, level_text])
		result.append("   %s" % desc)
	return result

func _pause_instruction_text() -> String:
	if current_comment == "なし" or effect_timer <= 0.0:
		return "現在の指示コメ：なし"
	var lines: Array[String] = [
		"%s　残り%02d秒" % [current_comment, int(ceil(effect_timer))]
	]
	if not active_sub_comment_ids.is_empty():
		lines.append("内訳：")
		for label in _active_sub_instruction_labels():
			lines.append("・%s" % label)
	elif active_effects.size() > 1:
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
	if not active_sub_comment_ids.is_empty():
		return _active_sub_instruction_text()
	if active_effects.is_empty():
		return "なし"
	var labels: Array[String] = []
	for item in active_effects:
		labels.append(_pause_effect_label(String(item)))
	return " / ".join(labels)

func _active_sub_instruction_text() -> String:
	return " / ".join(_active_sub_instruction_labels())

func _active_sub_instruction_labels() -> Array[String]:
	var labels: Array[String] = []
	for item in active_sub_comment_ids:
		var id: String = String(item)
		var comment: Dictionary = _find_comment_data(id)
		labels.append(String(comment.get("displayName", _pause_effect_label(id))) if not comment.is_empty() else _pause_effect_label(id))
	return labels

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
	player_no_brake_sliding = false
	click_move_active = false
	click_move_target = Vector2.ZERO
	banana_floor_appear_timer = 0.0
	banana_floor_rollback_timer = 0.0
	banana_floor_was_active = false
	screen_shake_timer = 0.0
	screen_shake_duration = 0.0
	screen_shake_strength = 0.0
	screen_shake_offset = Vector2.ZERO
	hit_stop_timer = 0.0
	screen_flash_timer = 0.0
	screen_flash_duration = 0.0
	screen_flash_color = Color.TRANSPARENT
	gift_choice_delay_timer = 0.0
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
	_suppress_dash_button_after_ui_confirm()

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
	player_no_brake_sliding = false
	click_move_active = false
	click_move_target = Vector2.ZERO
	banana_floor_appear_timer = 0.0
	banana_floor_rollback_timer = 0.0
	banana_floor_was_active = false
	screen_shake_timer = 0.0
	screen_shake_duration = 0.0
	screen_shake_strength = 0.0
	screen_shake_offset = Vector2.ZERO
	hit_stop_timer = 0.0
	screen_flash_timer = 0.0
	screen_flash_duration = 0.0
	screen_flash_color = Color.TRANSPARENT
	gift_choice_delay_timer = 0.0
	next_mallow_time = 30.0
	stop_timer = 0.0
	mute_timer = 0.0
	_clear_toast()
	_reset_time_announcements()
	kuso_chat_timer = 0.0
	attack_jitter_timer = 0.0
	move_slow_timer = 0.0
	spawn_rate_timer = 0.0
	support_attack_timer = 0.0
	player_hp = mini(player_max_hp, player_hp + DamageSystemScript.LEGACY_HP_UNIT * 2)
	gift_hype = int(floor(float(gift_hype) * 0.5))
	max_gift_hype = maxi(max_gift_hype, gift_hype)
	multiplier = 1.0
	burn_combo = 0
	current_comment = "なし"
	current_death_text = "発動中の指示コメなし"
	active_comment_hurt = false
	pending_clear_hype = 0
	do_everything_offer_count = 0
	active_effects.clear()
	active_effect_rates.clear()
	active_sub_comment_ids.clear()
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
	if state == "comment_choice" or state == "gift_choice":
		return
	for action in DebugSystemScript.pressed_actions(debug_key_latch):
		_apply_debug_action(action)

func _apply_debug_action(action: String) -> void:
	if DebugSystemScript.should_start_comment(action) and state == "playing":
		comment_timer = 0.0
	if DebugSystemScript.should_start_gift(action) and state == "playing":
		_start_gift_choice()
	if DebugSystemScript.should_force_do_everything_offer(action) and state == "playing":
		_apply_forced_do_everything_debug()
		return
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
		_play_instruction_comment_arrival_se()
		_choose_comment(int(result["chooseIndex"]))

func _apply_forced_do_everything_debug() -> void:
	var result: Dictionary = DebugSystemScript.force_do_everything_choice_ui_for_target(self, comments, rng, CHOICE_TIME, choice_box)
	if bool(result["applied"]):
		comment_choice_enter_time = 0.0
		_play_instruction_comment_arrival_se()
		_prime_choice_selection_latch()
		_refresh_choice_cards()
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": [String(result.get("chat", ""))]}, chat_box)

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

func _draw_click_move_marker() -> void:
	if state != "playing" or not click_move_active:
		return
	var pulse: float = 0.5 + sin(elapsed * 8.0) * 0.5
	var spin: float = elapsed * 2.2
	var radius: float = 18.0 + pulse * 4.0
	var center := click_move_target
	draw_circle(center, radius + 8.0, Color(1.0, 0.42, 0.72, 0.10 + pulse * 0.05))
	draw_arc(center, radius, 0.0, TAU, 56, Color(1.0, 0.36, 0.70, 0.86), 3.0, true)
	draw_arc(center, radius + 7.0, spin, spin + TAU * 0.72, 48, Color(0.50, 0.94, 1.0, 0.62), 2.0, true)
	draw_line(center + Vector2(-10.0, 0.0), center + Vector2(10.0, 0.0), Color(1.0, 1.0, 1.0, 0.82), 2.0, true)
	draw_line(center + Vector2(0.0, -10.0), center + Vector2(0.0, 10.0), Color(1.0, 1.0, 1.0, 0.82), 2.0, true)
	draw_circle(center, 3.8 + pulse * 1.2, Color(1.0, 0.94, 0.35, 0.92))

func _draw_player() -> void:
	if player_sprite != null:
		_draw_player_sprite()
		_draw_player_no_brake_sweat()
		_draw_invincible_label()
		_draw_player_hp_bar()
		_draw_player_dash_status_icon()
		return
	_draw_player_fallback()
	_draw_player_no_brake_sweat()
	_draw_invincible_label()
	_draw_player_hp_bar()
	_draw_player_dash_status_icon()

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

func _draw_player_no_brake_sweat() -> void:
	if state != "playing":
		return
	if not player_no_brake_sliding:
		return
	var texture: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, NO_BRAKE_SWEAT_IMAGE)
	if texture == null:
		return
	var back_side := 1.0
	if player_vel.x > 24.0:
		back_side = -1.0
	elif player_vel.x < -24.0:
		back_side = 1.0
	elif player_facing_x > 0.0:
		back_side = -1.0
	var bob := sin(elapsed * TAU / 0.42)
	var pulse := 0.94 + 0.06 * sin(elapsed * TAU / 0.36)
	var alpha := 0.88 + 0.08 * sin(elapsed * TAU / 0.48)
	var center := player_pos + Vector2(24.0 * back_side, -30.0 + bob * 1.6)
	var size := Vector2(32.0, 32.0) * pulse
	var transform_scale: Vector2 = Vector2(-1.0, 1.0) if back_side < 0.0 else Vector2.ONE
	if world_draw_active:
		transform_scale *= world_zoom
	draw_set_transform(_screen_pos(center), 0.0, transform_scale)
	draw_texture_rect(texture, Rect2(-size * 0.5, size), false, Color(1.0, 1.0, 1.0, alpha))
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

func _draw_player_dash_status_icon() -> void:
	if state != "playing":
		return
	var no_dash_power: float = ModifierSystemScript.effect_rate_for_target(self, "no_dash")
	var max_cd: float = maxf(0.01, dash_cooldown * PlayerSystemScript.dash_cooldown_rate(no_dash_power))
	var cooldown_ratio: float = clampf(1.0 - dash_cd / max_cd, 0.0, 1.0)
	var banned: bool = no_dash_power >= 0.95
	var ready: bool = PlayerSystemScript.can_dash(no_dash_power, dash_cd)
	var center := player_pos + Vector2(31.0, 31.0)
	var back_color := Color(1.0, 1.0, 1.0, 0.78)
	var ring_color := Color("#62e7d8")
	var icon_color := Color("#1cae9f")
	if banned:
		back_color = Color(1.0, 0.92, 0.96, 0.82)
		ring_color = Color("#ff4f78")
		icon_color = Color("#d9315f")
	elif not ready:
		back_color = Color(0.96, 0.94, 0.90, 0.72)
		ring_color = Color("#ffd166")
		icon_color = Color("#8f8793")
	draw_circle(center + Vector2(0, 2), 15.0, Color(0.24, 0.15, 0.28, 0.14))
	draw_circle(center, 13.0, back_color)
	_draw_fixed_arc(center, 15.0, -PI * 0.5, PI * 1.5, 36, Color(0.80, 0.78, 0.84, 0.40), 1.8)
	var ring_end := -PI * 0.5 + TAU * (1.0 if ready or banned else cooldown_ratio)
	_draw_fixed_arc(center, 15.0, -PI * 0.5, ring_end, 36, ring_color, 2.6)
	var dash_icon: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, HUD_DASH_ICON_IMAGE)
	if dash_icon != null:
		var icon_tint := Color(1.0, 1.0, 1.0, 0.96)
		if banned:
			icon_tint = Color(1.0, 0.72, 0.82, 0.92)
		elif not ready:
			icon_tint = Color(0.78, 0.78, 0.82, 0.68)
		draw_texture_rect(dash_icon, Rect2(center - Vector2(14.0, 10.0), Vector2(28.0, 20.0)), false, icon_tint)
	else:
		_draw_text_item({"pos": center + Vector2(-9, 7), "text": "足", "width": 18, "size": 14, "color": icon_color, "fontWeight": "black"}, "", HORIZONTAL_ALIGNMENT_CENTER)
	if banned:
		draw_line(center + Vector2(-8, -8), center + Vector2(8, 8), ring_color, 2.6, true)

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
		Callable(self, "_draw_rotated_texture"),
		equipment_weapon_timers,
		equipment_bullet_support_level
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
	var defeat_pending := bool(boss.get("defeatPending", false))
	var defeat_progress := 0.0
	var overlay_alpha := 1.0
	if defeat_pending:
		var delay_max := maxf(0.01, float(boss.get("defeatDelayMax", 0.55)))
		defeat_progress = clampf(1.0 - float(boss.get("defeatDelay", 0.0)) / delay_max, 0.0, 1.0)
		overlay_alpha = clampf(1.0 - maxf(0.0, defeat_progress - 0.35) / 0.65, 0.0, 1.0)
	var rect := Rect2(Vector2(388, 112), Vector2(640, 50))
	draw_rect(rect, Color(1.0, 1.0, 1.0, 0.94 * overlay_alpha), true)
	var border_color := Color("#c8b8ff")
	border_color.a *= overlay_alpha
	_draw_rect_outline(rect, border_color, 3)
	var bar_rect := Rect2(rect.position + Vector2(142, 25), Vector2(482, 14))
	draw_rect(bar_rect, Color(0.14, 0.09, 0.19, overlay_alpha), true)
	draw_rect(Rect2(bar_rect.position, Vector2(bar_rect.size.x * ratio, bar_rect.size.y)), Color(1.0, 0.31, 0.57, overlay_alpha), true)
	var bar_border := Color("#6f55c8")
	bar_border.a *= overlay_alpha
	_draw_rect_outline(bar_rect, bar_border, 2)
	if defeat_pending:
		var flash := sin(defeat_progress * PI)
		draw_rect(rect, Color(1.0, 0.94, 0.48, 0.22 * flash * overlay_alpha), true)
		draw_line(bar_rect.position + Vector2(8, -3), bar_rect.end + Vector2(-78, 8), Color(1.0, 1.0, 1.0, 0.78 * overlay_alpha), 3.0)
		var crack_color := Color("#ff4f92")
		crack_color.a *= overlay_alpha
		draw_line(bar_rect.position + Vector2(128, 12), bar_rect.position + Vector2(180, -8), crack_color, 2.0)
		draw_line(bar_rect.position + Vector2(276, -8), bar_rect.position + Vector2(322, 17), crack_color, 2.0)
	var name_color := Color("#332255")
	name_color.a *= overlay_alpha
	_draw_text_item({"pos": rect.position + Vector2(18, 34), "text": String(boss.get("displayName", "超長文ニキ")), "width": 132, "size": 20, "color": name_color})
	_draw_text_item({"pos": rect.position + Vector2(516, 20), "text": "%d/%d" % [maxi(0, int(ceil(float(boss.get("hp", 0.0))))), int(ceil(max_hp))], "width": 108, "size": 14, "color": name_color})

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
	var hammer_texture: Texture2D = _hammer_weapon_sprite_for_data(data)
	if bool(data.get("showHammer", false)):
		_draw_ban_hammer_afterimages(data, hammer_texture)
	_draw_hit_fx_texture(data)
	if bool(data.get("showHammer", false)):
		_draw_rotated_texture(hammer_texture, data["hammerPos"] as Vector2, data["hammerSize"] as Vector2, float(data["hammerAngle"]), float(data["hammerAlpha"]))
		_draw_ban_hammer_sparks(data)

func _hammer_weapon_sprite_for_data(data: Dictionary) -> Texture2D:
	if String(data.get("hammerSprite", "ban_hammer")) == "ban_judgement" and ban_judgement_weapon_sprite != null:
		return ban_judgement_weapon_sprite
	return ban_hammer_weapon_sprite

func _draw_ban_hammer_afterimages(data: Dictionary, texture: Texture2D) -> void:
	if texture == null:
		return
	var after_images: Array = data.get("hammerAfterImages", []) as Array
	for image_item in after_images:
		var image_data: Dictionary = image_item as Dictionary
		_draw_rotated_texture(
			texture,
			image_data["pos"] as Vector2,
			image_data["size"] as Vector2,
			float(image_data["angle"]),
			float(image_data["alpha"])
		)

func _draw_ban_hammer_sparks(data: Dictionary) -> void:
	var alpha: float = float(data.get("sparkAlpha", 0.0))
	if alpha <= 0.0:
		return
	var pos: Vector2 = data["sparkPos"] as Vector2
	var dir: Vector2 = data.get("sparkDir", Vector2.RIGHT) as Vector2
	dir = dir.normalized()
	var side := Vector2(-dir.y, dir.x)
	var size: float = float(data.get("sparkSize", 10.0))
	var warm := Color(1.0, 0.86, 0.18, 0.86 * alpha)
	var hot := Color(1.0, 1.0, 1.0, 0.92 * alpha)
	var pink := Color(1.0, 0.18, 0.58, 0.62 * alpha)
	draw_line(pos - dir * size * 0.55, pos + dir * size * 1.10, hot, 3.0)
	draw_line(pos - side * size * 0.82, pos + side * size * 0.82, warm, 2.4)
	draw_line(pos - (dir + side).normalized() * size * 0.58, pos + (dir + side).normalized() * size * 0.72, pink, 2.0)
	draw_circle(pos, size * 0.22, hot, true)

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
	if data.has("imageRotation"):
		_draw_rotated_texture(texture, pos, size, float(data["imageRotation"]), alpha)
	else:
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
	_draw_field_view_frame_v25()
	_draw_comment_panel_v25()
	_draw_comment_row_lines_v25()
	_draw_top_status_v25()
	_draw_instruction_countdown_v25()
	_draw_bottom_hud_v25()
	_draw_equipment_icons()

func _draw_field_view_frame_v25() -> void:
	_draw_ranking_panel(FIELD_VIEW.grow(5.0), Color(1.0, 1.0, 1.0, 0.0), Color(0.67, 0.59, 0.75, 0.18), 8, 2, false)
	_draw_rect_outline(FIELD_VIEW.grow(1.0), Color(1.0, 1.0, 1.0, 0.34), 2)

func _draw_comment_panel_v25() -> void:
	var rect := COMMENT_PANEL_RECT_V25
	var image_drawn := _draw_hud_ui_texture_v25(HUD_UI_COMMENT_PANEL_IMAGE, rect)
	if not image_drawn:
		_draw_ranking_panel(rect, Color(1.0, 1.0, 1.0, 0.62), Color(1.0, 0.64, 0.82, 0.34), 24, 1, true)
		var header := Rect2(rect.position + Vector2(14, 14), Vector2(rect.size.x - 28, 44))
		_draw_ranking_panel(header, Color(1.0, 0.96, 0.995, 0.54), Color(0.76, 0.42, 1.0, 0.16), 20, 1, false)
		draw_circle(rect.position + Vector2(38, 36), 15, Color(1.0, 0.33, 0.64, 0.76))
	_draw_text_item({"pos": rect.position + Vector2(30, 48), "text": "…", "width": 18, "size": 17, "color": Color.WHITE})
	_draw_text_item({"pos": rect.position + Vector2(64, 46), "text": "COMMENT", "width": 150, "size": 22, "color": Color("#9a55d9")})
	_draw_comment_input_panel_v25()

func _draw_comment_input_panel_v25() -> void:
	var panel := COMMENT_PANEL_RECT_V25
	var input_rect := Rect2(panel.position + Vector2(16, panel.size.y - 56), Vector2(panel.size.x - 92, 38))
	var send_rect := Rect2(Vector2(input_rect.end.x + 8, panel.position.y + panel.size.y - 60), Vector2(46, 46))
	if not _has_hud_ui_texture_v25(HUD_UI_COMMENT_PANEL_IMAGE):
		_draw_ranking_panel(input_rect, Color(1.0, 1.0, 1.0, 0.72), Color(0.72, 0.85, 1.0, 0.58), 11, 1, false)
	_draw_text_item({"pos": input_rect.position + Vector2(16, 24), "text": "コメントを入力...", "width": int(input_rect.size.x - 30), "size": 15, "color": Color("#7b8798")})
	if not _has_hud_ui_texture_v25(HUD_UI_COMMENT_PANEL_IMAGE):
		_draw_ranking_panel(send_rect, Color(1.0, 0.94, 0.985, 0.76), Color("#ff9bc8"), 12, 1, false)
	_draw_text_item({"pos": send_rect.position + Vector2(0, 31), "text": "▶", "width": int(send_rect.size.x), "size": 22, "color": Color("#ff4f92")}, "", HORIZONTAL_ALIGNMENT_CENTER)

func _draw_comment_row_lines_v25() -> void:
	if _has_hud_ui_texture_v25(HUD_UI_COMMENT_PANEL_IMAGE):
		return
	var panel := COMMENT_PANEL_RECT_V25
	var x1: float = panel.position.x + 16.0
	var x2: float = panel.end.x - 16.0
	var y: float = panel.position.y + 72.0
	var bottom: float = panel.position.y + panel.size.y - 116.0
	while y <= bottom:
		draw_line(Vector2(x1, y), Vector2(x2, y), Color(0.74, 0.82, 0.92, 0.38), 1.0)
		y += 30.0

func _draw_soft_card_shadow_v25(rect: Rect2, radius: int) -> void:
	_draw_ranking_panel(Rect2(rect.position + Vector2(0, 4), rect.size), Color(0.67, 0.59, 0.75, 0.12), Color(1, 1, 1, 0), radius, 0, false)

func _draw_hud_ui_texture_v25(path: String, rect: Rect2, color: Color = Color.WHITE) -> bool:
	if path == "":
		return false
	var texture: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, path)
	if texture == null:
		return false
	draw_texture_rect(texture, rect, false, color)
	return true

func _draw_hud_metric_icon_v25(path: String, rect: Rect2) -> bool:
	if path == "":
		return false
	var texture: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, path)
	if texture == null:
		return false
	var icon_rect := _fit_texture_rect(rect, texture.get_size())
	draw_texture_rect(texture, icon_rect, false)
	return true

func _has_hud_ui_texture_v25(path: String) -> bool:
	if path == "":
		return false
	return TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, path) != null

func _color_near_v25(a: Color, b: Color, tolerance: float = 0.025) -> bool:
	return absf(a.r - b.r) <= tolerance and absf(a.g - b.g) <= tolerance and absf(a.b - b.b) <= tolerance

func _ui_card_image_path_v25(rect: Rect2, accent: Color) -> String:
	var width := int(round(rect.size.x))
	var height := int(round(rect.size.y))
	if width == 198 and height == 80:
		if _color_near_v25(accent, Color("#fff45c")):
			return HUD_UI_TOP_CARD_TIME_IMAGE
		return HUD_UI_TOP_CARD_STREAM_IMAGE
	if width == 278 and height == 80:
		return HUD_UI_TOP_CARD_VIEWER_IMAGE
	if width == 260 and height == 62:
		return HUD_UI_METRIC_EXP_IMAGE
	if width == 170 and height == 54:
		return HUD_UI_METRIC_GIFT_IMAGE
	if width == 160 and height == 54:
		return HUD_UI_METRIC_HEART_IMAGE
	return ""

func _draw_ui_card_background_v25(rect: Rect2, accent: Color, border_color: Color, border_width: int) -> bool:
	_draw_soft_card_shadow_v25(rect, 6)
	var image_path := _ui_card_image_path_v25(rect, accent)
	if _draw_hud_ui_texture_v25(image_path, rect):
		return true
	_draw_ranking_panel(rect, Color("#fcfbfe"), border_color, 6, border_width, false)
	draw_rect(Rect2(rect.position + Vector2(0, rect.size.y - 5), Vector2(rect.size.x, 5)), accent, true)
	return false

func _draw_ui_card_v25(rect: Rect2, label: String, value: String, accent: Color, icon_text: String = "", border_color: Color = Color("#ffc1da"), border_width: int = 2, icon_path: String = "") -> void:
	var image_drawn := _draw_ui_card_background_v25(rect, accent, border_color, border_width)
	if rect.size.y <= 64.0:
		_draw_compact_ui_card_text_v25(rect, label, value, accent, icon_text, icon_path)
		return
	if icon_path != "":
		_draw_hud_metric_icon_v25(icon_path, Rect2(rect.position + Vector2(14, 15), Vector2(38, 38)))
	elif icon_text != "" and not image_drawn:
		_draw_text_item({"pos": rect.position + Vector2(18, 47), "text": icon_text, "width": 42, "size": 31, "color": accent})
	var has_icon := icon_text != "" or icon_path != ""
	var text_x: float = rect.position.x + (58.0 if has_icon else 16.0)
	if image_drawn and int(round(rect.size.x)) == 278:
		text_x = rect.position.x + 86.0
	elif image_drawn and int(round(rect.size.x)) == 198:
		text_x = rect.position.x + 66.0
	_draw_text_item({"pos": Vector2(text_x, rect.position.y + 30), "text": label, "width": int(rect.size.x - 30), "size": 15, "color": Color("#101420")})
	_draw_text_item({"pos": Vector2(text_x, rect.position.y + 65), "text": value, "width": int(rect.size.x - 28), "size": 27, "color": Color("#101420")})

func _draw_buzz_status_card_v25(rect: Rect2) -> void:
	var accent := Color("#b46cff")
	_draw_soft_card_shadow_v25(rect, 6)
	var image_drawn := _draw_hud_ui_texture_v25(HUD_UI_TOP_CARD_BUZZ_IMAGE, rect)
	if not image_drawn:
		_draw_ranking_panel(rect, Color("#fcfbfe"), Color("#e2d3fb"), 6, 1, false)
		draw_rect(Rect2(rect.position + Vector2(0, rect.size.y - 5), Vector2(rect.size.x, 5)), accent, true)
	if not image_drawn:
		_draw_text_item({"pos": rect.position + Vector2(16, 47), "text": "↗", "width": 42, "size": 31, "color": accent})
		_draw_text_item({"pos": rect.position + Vector2(36, 24), "text": "✦", "width": 24, "size": 14, "color": Color("#ff8fd0")})
	var text_x := rect.position.x + (72.0 if image_drawn else 58.0)
	var text_width := int(rect.end.x - text_x - 14.0)
	_draw_text_item({"pos": Vector2(text_x, rect.position.y + 28), "text": "バズ度", "width": text_width, "size": 15, "color": Color("#51316c")})
	_draw_text_item({"pos": Vector2(text_x, rect.position.y + 53), "text": "%d / 10" % burn_combo, "width": text_width, "size": 25, "color": Color("#2b1738")})
	_draw_text_item({"pos": Vector2(text_x, rect.position.y + 74), "text": "撃破スコア +%d%%" % (burn_combo * 10), "width": text_width, "size": 13, "color": Color("#9a55d9")})

func _draw_mental_breakdown_viewer_card(rect: Rect2) -> void:
	var clock := float(Time.get_ticks_msec()) / 1000.0
	var reaction := _mental_breakdown_impact_ratio(MENTAL_BREAKDOWN_REACTION_DURATION)
	var jitter := Vector2(sin(clock * 54.0), cos(clock * 47.0)) * 4.0 * reaction
	var card := Rect2(rect.position + jitter, rect.size)
	var viewer_drop := int(round(float(maxi(score, 1)) * 0.045 * reaction))
	var preview_score := maxi(0, score - viewer_drop)
	draw_rect(card, Color(0.94, 0.93, 0.95, 0.94), true)
	_draw_rect_outline(card, Color("#d0c8d6"), 2)
	draw_rect(Rect2(card.position + Vector2(0, card.size.y - 5), Vector2(card.size.x, 5)), Color("#9ca3af"), true)
	_draw_text_item({"pos": card.position + Vector2(18, 47), "text": "●●", "width": 42, "size": 31, "color": Color("#a1a1aa")})
	_draw_text_item({"pos": card.position + Vector2(58, 30), "text": "同時視聴者数", "width": int(card.size.x - 76), "size": 15, "color": Color("#625866")})
	_draw_text_item({"pos": card.position + Vector2(58, 65), "text": "%s人が視聴中" % DrawDataSystemScript.format_viewer_count(preview_score), "width": int(card.size.x - 76), "size": 27, "color": Color("#55515d")})
	if reaction > 0.02:
		_draw_text_item({"pos": card.position + Vector2(168, 29), "text": "離脱中…", "width": 86, "size": 14, "color": Color("#ff5a96")})

func _draw_mental_breakdown_hud_card(rect: Rect2) -> void:
	var clock := float(Time.get_ticks_msec()) / 1000.0
	var reaction := _mental_breakdown_impact_ratio(MENTAL_BREAKDOWN_REACTION_DURATION)
	var jitter := Vector2(sin(clock * 62.0), cos(clock * 55.0)) * 3.0 * reaction
	var card := Rect2(rect.position + jitter, rect.size)
	draw_rect(card, Color(1.0, 0.90, 0.95, 0.96), true)
	_draw_rect_outline(card, Color("#ff5a96"), 3)
	draw_rect(Rect2(card.position + Vector2(0, card.size.y - 5), Vector2(card.size.x, 5)), Color("#ff477f"), true)
	if not _draw_hud_metric_icon_v25(HUD_METRIC_ICON_MENTAL_IMAGE, Rect2(card.position + Vector2(11, 10), Vector2(38, 38))):
		_draw_text_item({"pos": card.position + Vector2(18, 51), "text": "♡", "width": 28, "size": 26, "color": Color("#ff2f78")})
	_draw_text_item({"pos": card.position + Vector2(58, 32), "text": "メンタル", "width": 92, "size": 14, "color": Color("#101420")})
	_draw_text_item({"pos": card.position + Vector2(card.size.x - 64, 32), "text": "0%", "width": 48, "size": 15, "color": Color("#ff2f78")}, "", HORIZONTAL_ALIGNMENT_RIGHT)
	var crack := card.position + Vector2(34, 29)
	draw_line(crack + Vector2(-3, 0), crack + Vector2(2, 7), Color.WHITE, 2.0)
	draw_line(crack + Vector2(2, 7), crack + Vector2(-1, 14), Color.WHITE, 2.0)
	draw_line(crack + Vector2(-1, 14), crack + Vector2(4, 22), Color.WHITE, 2.0)
	if reaction > 0.02:
		for i in range(5):
			var angle := clock * 2.4 + float(i) * 1.32
			var pos := card.position + Vector2(38, 36) + Vector2(cos(angle), sin(angle)) * (18.0 + float(i % 2) * 7.0) * (1.0 - reaction)
			draw_circle(pos, 2.5, Color(1.0, 0.36, 0.68, 0.72 * reaction))

func _draw_compact_ui_card_text_v25(rect: Rect2, label: String, value: String, accent: Color, icon_text: String = "", icon_path: String = "") -> void:
	var tight := rect.size.y <= 56.0
	if icon_path != "":
		var icon_size := 34.0 if tight else 38.0
		var icon_offset := Vector2(14, 11 if tight else 10)
		if icon_path == HUD_METRIC_ICON_EXP_IMAGE:
			icon_offset.x = 9.0
		elif icon_path == HUD_METRIC_ICON_GIFT_IMAGE:
			icon_size = 38.0
			icon_offset = Vector2(12, 8)
		elif icon_path == HUD_METRIC_ICON_HEART_IMAGE:
			icon_offset.x = 10.0
		_draw_hud_metric_icon_v25(icon_path, Rect2(rect.position + icon_offset, Vector2(icon_size, icon_size)))
	elif icon_text != "":
		_draw_text_item({"pos": rect.position + Vector2(18, 38 if tight else 42), "text": icon_text, "width": 38, "size": 24 if tight else 28, "color": accent})
	var has_icon := icon_text != "" or icon_path != ""
	var text_x: float = rect.position.x + (58.0 if has_icon else 14.0)
	if label.strip_edges() == "":
		if value != "":
			_draw_text_item({"pos": Vector2(text_x, rect.position.y + (38 if tight else 42)), "text": value, "width": int(rect.size.x - 30), "size": 23 if tight else 27, "color": Color("#101420")})
		return
	_draw_text_item({"pos": Vector2(text_x, rect.position.y + (20 if tight else 24)), "text": label, "width": int(rect.size.x - 28), "size": 13 if tight else 14, "color": Color("#101420")})
	if value != "":
		_draw_text_item({"pos": Vector2(text_x, rect.position.y + (44 if tight else 52)), "text": value, "width": int(rect.size.x - 30), "size": 21 if tight else 25, "color": Color("#101420")})

func _draw_equipment_panel_v25(rect: Rect2, label: String, accent: Color) -> void:
	_draw_soft_card_shadow_v25(rect, 6)
	_draw_ranking_panel(rect, Color(1.0, 1.0, 1.0, 0.88), Color(accent.r, accent.g, accent.b, 0.36), 6, 2, false)
	draw_rect(Rect2(rect.position + Vector2(0, rect.size.y - 5), Vector2(rect.size.x, 5)), accent, true)
	var tab := Rect2(rect.position + Vector2(10, -1), Vector2(72, 23))
	draw_rect(tab, accent, true)
	_draw_text_item({"pos": tab.position + Vector2(0, 17), "text": label, "width": int(tab.size.x), "size": 14, "color": Color("#101420")}, "", HORIZONTAL_ALIGNMENT_CENTER)

func _viewer_hud_text() -> String:
	return "%s人視聴中" % DrawDataSystemScript.format_viewer_count(score)

func _time_hud_text() -> String:
	var remaining: int = maxi(0, int(ceil(RunStateSystemScript.run_length(quick_test_mode, QUICK_RUN_LENGTH, NORMAL_RUN_LENGTH) - elapsed)))
	return "%02d:%02d" % [remaining / 60, remaining % 60]

func _current_instruction_hud_text() -> String:
	var text: String = current_comment.strip_edges()
	if not active_sub_comment_ids.is_empty():
		return "%s　%02d秒\n%s" % [text, maxi(0, int(ceil(effect_timer))), _active_sub_instruction_text()]
	if text == "" or text == "なし":
		return "なし"
	if ModifierSystemScript.has_effect_for_target(self, "short_range"):
		return "%s　%02d秒\n射程短縮中" % [text, maxi(0, int(ceil(effect_timer)))]
	return "%s　%02d秒" % [text, maxi(0, int(ceil(effect_timer)))]

func _current_instruction_panel_text_v25() -> String:
	var text: String = current_comment.strip_edges()
	if text == "" or text == "なし" or effect_timer <= 0.0:
		return "なし"
	if active_sub_comment_ids.is_empty():
		if ModifierSystemScript.has_effect_for_target(self, "short_range"):
			return "%s / 射程短縮中" % text
		return text
	var labels: Array[String] = []
	for label in _active_sub_instruction_labels():
		labels.append(_short_pause_text(String(label), 8))
	var joined := " / ".join(labels)
	if text == "" or text == "なし":
		return joined
	return "%s：%s" % [_short_pause_text(text, 8), joined]

func _current_instruction_risk_v25() -> int:
	if not active_sub_comment_ids.is_empty():
		return 5
	var comment: Dictionary = _find_comment_data(last_comment_id)
	if comment.is_empty():
		return 0
	var has_heart: bool = current_comment.ends_with("♡")
	var view: Dictionary = CommentSystemScript.comment_view(comment, has_heart)
	return int(view.get("riskLevel", 0))

func _draw_top_status_v25() -> void:
	_draw_ui_card_v25(Rect2(20, 18, 198, 80), "配信枠", String(current_stream_frame.get("displayName", "雑談枠")), Color("#6ee7f0"), "▣", Color("#d8eaf4"), 1)
	_draw_ui_card_v25(Rect2(230, 18, 198, 80), "残り時間", _time_hud_text(), Color("#fff45c"), "◷", Color("#eadf9a"), 1)
	_draw_buzz_status_card_v25(Rect2(440, 18, 220, 80))
	var viewer_rect := Rect2(672, 18, 278, 80)
	if _is_mental_breakdown_intro():
		_draw_mental_breakdown_viewer_card(viewer_rect)
	else:
		_draw_ui_card_v25(viewer_rect, "同時視聴者数", _viewer_hud_text(), Color("#8df7ff"), "●●", Color("#d8eaf4"), 1)
	_draw_character_status_card_v25(Rect2(962, 18, 258, 80))

func _draw_character_status_card_v25(rect: Rect2) -> void:
	var accent := Color("#ff8fc7")
	_draw_soft_card_shadow_v25(rect, 6)
	if not _draw_hud_ui_texture_v25(HUD_UI_TOP_CARD_CHARACTER_IMAGE, rect):
		_draw_ranking_panel(rect, Color("#fcfbfe"), Color("#ead7e9"), 6, 1, false)
		draw_rect(Rect2(rect.position + Vector2(0, rect.size.y - 5), Vector2(rect.size.x, 5)), accent, true)
	var avatar_rect := Rect2(rect.position + Vector2(12, 9), Vector2(62, 62))
	_draw_ranking_panel(avatar_rect, Color(1.0, 0.94, 0.98, 0.90), Color(1.0, 0.56, 0.76, 0.34), 8, 1, false)
	var hud_icon: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, _current_character_hud_icon_path_v25())
	if hud_icon != null:
		draw_texture_rect(hud_icon, _fit_texture_rect(avatar_rect.grow(-3), hud_icon.get_size()), false)
	else:
		var sprite_path: String = String(current_character.get("sprite", ""))
		var tex: Texture2D = CharacterSystemScript.texture_from_cache(character_sprite_cache, sprite_path)
		if tex != null:
			_draw_character_hud_icon_texture_v25(tex, avatar_rect.grow(-3))
	var text_x := rect.position.x + 86.0
	_draw_text_item({"pos": Vector2(text_x, rect.position.y + 24), "text": "使用キャラ", "width": int(rect.size.x - 98), "size": 13, "color": Color("#8a6b82")})
	_draw_text_item({"pos": Vector2(text_x, rect.position.y + 56), "text": String(current_character.get("displayName", "")), "width": int(rect.size.x - 98), "size": 22, "color": Color("#101420")})

func _current_character_hud_icon_path_v25() -> String:
	if current_character_id == "superchat_chan" or current_character_id == "supana":
		return HUD_ICON_SUPANA_IMAGE
	if current_character_id == "maro_chan" or current_character_id == "maron":
		return HUD_ICON_MARON_IMAGE
	return HUD_ICON_BANRI_IMAGE

func _draw_character_hud_icon_texture_v25(texture: Texture2D, rect: Rect2) -> void:
	var focus := Vector2(0.50, 0.30)
	var zoom := 2.35
	if current_character_id == "maro_chan" or current_character_id == "maron":
		focus = Vector2(0.50, 0.28)
		zoom = 2.25
	elif current_character_id == "superchat_chan" or current_character_id == "supana":
		focus = Vector2(0.50, 0.30)
		zoom = 2.45
	_draw_texture_cover_rect(texture, rect, focus, zoom)

func _draw_instruction_countdown_v25() -> void:
	if state == "comment_choice" or state == "gift_choice" or state == "pause" or state == "result":
		return
	var left: float = maxf(0.0, comment_timer)
	var ratio: float = clampf(left / COMMENT_INTERVAL, 0.0, 1.0)
	var alert: bool = left <= 5.0
	var urgent: bool = left <= 3.0
	var risk: int = _current_instruction_risk_v25()
	var rect := Rect2(Vector2(20, 108), Vector2(1200, 76))
	var accent: Color = Color("#ff4f92") if risk >= 4 else Color("#ff73ad")
	if alert:
		accent = Color("#ff3f78")
	var fill: Color = Color(1.0, 0.965, 0.985, 0.94) if not urgent else Color(1.0, 0.90, 0.94, 0.96)
	var border := Color("#ff80b7") if risk >= 4 else Color("#ffc1da")
	if urgent:
		var flash := 0.5 + sin(elapsed * 12.0) * 0.5
		border = Color("#ff3f78").lerp(Color("#ffc1da"), flash * 0.34)
	var panel_image := HUD_UI_INSTRUCTION_DANGER_IMAGE if risk >= 4 or urgent else HUD_UI_INSTRUCTION_NORMAL_IMAGE
	if not _draw_hud_ui_texture_v25(panel_image, rect):
		_draw_ranking_panel(rect, fill, border, 18, 3 if risk >= 4 or urgent else 2, true)
		draw_line(rect.position + Vector2(18, 40), rect.position + Vector2(rect.size.x - 18, 40), Color(1.0, 0.72, 0.86, 0.40), 1.0)
	elif risk >= 4 or urgent:
		_draw_ranking_panel(rect, Color(1.0, 1.0, 1.0, 0.0), border, 18, 2, false)
	var current_text := _short_pause_text(_current_instruction_panel_text_v25(), 33)
	var current_color := Color("#101420") if current_text != "なし" else Color("#817184")
	_draw_text_item({"pos": rect.position + Vector2(24, 25), "text": "現在の指示コメ", "width": 126, "size": 14, "color": Color("#e73783")})
	_draw_text_item({"pos": rect.position + Vector2(156, 33), "text": current_text, "width": 800, "size": 28, "color": current_color, "fontWeight": "black"})
	if current_text != "なし":
		var remain_fill := Color("#fff3fa") if not urgent else Color("#ffe6f0")
		var remain_rect := Rect2(rect.position + Vector2(rect.size.x - 152, 11), Vector2(124, 28))
		_draw_ranking_panel(remain_rect, remain_fill, Color(1.0, 0.45, 0.70, 0.35), 14, 1, false)
		_draw_text_item({"pos": remain_rect.position + Vector2(0, 21), "text": "残り %02d秒" % maxi(0, int(ceil(effect_timer))), "width": int(remain_rect.size.x), "size": 16, "color": Color("#e73763")}, "", HORIZONTAL_ALIGNMENT_CENTER)
	var text_color: Color = Color("#e06a86") if alert else Color("#8b74bd")
	_draw_text_item({"pos": rect.position + Vector2(24, 64), "text": "⚠ 次の指示まで", "width": 160, "size": 15, "color": text_color})
	var bar_back := Rect2(rect.position + Vector2(188, 54), Vector2(rect.size.x - 216, 9))
	_draw_ranking_panel(bar_back, Color("#f2e6ef"), Color(1, 1, 1, 0), 6, 0, false)
	_draw_ranking_panel(Rect2(bar_back.position, Vector2(bar_back.size.x * ratio, bar_back.size.y)), Color(accent.r, accent.g, accent.b, 0.72), Color(1, 1, 1, 0), 6, 0, false)

func _fit_texture_rect(container: Rect2, tex_size: Vector2) -> Rect2:
	if tex_size.x <= 0.0 or tex_size.y <= 0.0:
		return Rect2(container.position, Vector2.ZERO)
	var scale: float = minf(container.size.x / tex_size.x, container.size.y / tex_size.y)
	var size: Vector2 = tex_size * scale
	return Rect2(container.position + (container.size - size) * 0.5, size)

func _draw_texture_cover_rect(texture: Texture2D, container: Rect2, focus: Vector2 = Vector2(0.5, 0.46), zoom: float = 1.0) -> void:
	var tex_size := texture.get_size()
	if tex_size.x <= 0.0 or tex_size.y <= 0.0 or container.size.x <= 0.0 or container.size.y <= 0.0:
		return
	zoom = maxf(1.0, zoom)
	var container_aspect: float = container.size.x / container.size.y
	var texture_aspect: float = tex_size.x / tex_size.y
	var source_rect := Rect2(Vector2.ZERO, tex_size)
	if texture_aspect > container_aspect:
		source_rect.size.x = tex_size.y * container_aspect
		source_rect.position.x = clampf((tex_size.x - source_rect.size.x) * focus.x, 0.0, tex_size.x - source_rect.size.x)
	else:
		source_rect.size.y = tex_size.x / container_aspect
		source_rect.position.y = clampf((tex_size.y - source_rect.size.y) * focus.y, 0.0, tex_size.y - source_rect.size.y)
	if zoom > 1.0:
		var zoomed_size := source_rect.size / zoom
		var zoom_margin := source_rect.size - zoomed_size
		source_rect.position += Vector2(zoom_margin.x * focus.x, zoom_margin.y * focus.y)
		source_rect.size = zoomed_size
	draw_texture_rect_region(texture, container, source_rect)

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
	if not active_sub_comment_ids.is_empty():
		_draw_active_sub_instruction_panel_rows_v25(rect)
		return
	_draw_text_item({"pos": rect.position + Vector2(22, 91), "text": _current_instruction_hud_text(), "width": 280, "size": 26, "color": Color("#101420")})

func _draw_active_sub_instruction_panel_rows_v25(rect: Rect2) -> void:
	var labels: Array[String] = _active_sub_instruction_labels()
	var seconds_text: String = "%02d" % maxi(0, int(ceil(effect_timer)))
	var row_start_y: float = rect.position.y + 66.0
	var row_gap: float = 28.0
	var visible_count: int = mini(labels.size(), 3)
	var timer_row: int = int(visible_count / 2)
	for i in range(visible_count):
		var y: float = row_start_y + float(i) * row_gap
		_draw_text_item({
			"pos": Vector2(rect.position.x + 22.0, y),
			"text": _short_pause_text(String(labels[i]), 9),
			"width": 210,
			"size": 21,
			"color": Color("#101420")
		})
		if i != timer_row:
			continue
		_draw_text_item({
			"pos": Vector2(rect.position.x + 244.0, y),
			"text": seconds_text,
			"width": 52,
			"size": 20,
			"color": Color("#e73763")
		}, "", HORIZONTAL_ALIGNMENT_RIGHT)

func _draw_bottom_hud_v25() -> void:
	if not _draw_hud_ui_texture_v25(HUD_UI_BOTTOM_BASE_IMAGE, HUD):
		_draw_ranking_panel(HUD, Color(0.985, 0.99, 1.0, 0.91), Color("#b8d9ff"), 10, 3, false)
	var mental_rect := Rect2(34, 806, 226, 62)
	if _is_mental_breakdown_intro():
		_draw_mental_breakdown_hud_card(mental_rect)
	else:
		_draw_mental_hud_card_v25(mental_rect)
	var exp_need: int = maxi(1, ExpSystemScript.current_need(exp_level))
	_draw_ui_card_v25(Rect2(274, 806, 260, 62), "EXP", "Lv.%d  %d/%d" % [exp_level, exp_value, exp_need], Color("#27c4d9"), "★", Color("#b8d9ff"), 2, HUD_METRIC_ICON_EXP_IMAGE)
	_draw_ui_card_v25(Rect2(548, 810, 170, 54), "ギフト期待度", "%d%%" % gift_hype, Color("#ff7ea8"), "▣", Color("#f2d7e6"), 1, HUD_METRIC_ICON_GIFT_IMAGE)
	_draw_ui_card_v25(Rect2(730, 810, 160, 54), "", "待機" if heart_pending else "なし", Color("#ffabd5"), "♥", Color("#f2d7e6"), 1, HUD_METRIC_ICON_HEART_IMAGE)
	_draw_equipment_panel_v25(Rect2(910, 802, 304, 70), "武器", Color("#fff45c"))
	_draw_equipment_panel_v25(Rect2(1230, 802, 304, 70), "アクセ", Color("#8df7ff"))
	var exp_ratio: float = clampf(float(exp_value) / float(exp_need), 0.0, 1.0)
	var hype_ratio: float = clampf(float(gift_hype) / 100.0, 0.0, 1.0)
	var exp_gauge := Rect2(Vector2(332, 860), Vector2(184, 6))
	_draw_ranking_panel(exp_gauge, Color("#d8ecff"), Color(1, 1, 1, 0), 4, 0, false)
	_draw_ranking_panel(Rect2(exp_gauge.position, Vector2(exp_gauge.size.x * exp_ratio, exp_gauge.size.y)), Color("#24c7d9"), Color(1, 1, 1, 0), 4, 0, false)
	var hype_gauge := Rect2(Vector2(606, 858), Vector2(96, 5))
	_draw_ranking_panel(hype_gauge, Color("#ffe1eb"), Color(1, 1, 1, 0), 4, 0, false)
	_draw_ranking_panel(Rect2(hype_gauge.position, Vector2(hype_gauge.size.x * hype_ratio, hype_gauge.size.y)), DrawDataSystemScript.gift_hype_color(hype_ratio), Color(1, 1, 1, 0), 4, 0, false)

func _mental_hud_text() -> String:
	if ModifierSystemScript.has_effect_for_target(self, "hide_hp"):
		return "??%"
	return "%d%%" % int(round(_mental_hud_ratio() * 100.0))

func _mental_hud_ratio() -> float:
	if ModifierSystemScript.has_effect_for_target(self, "hide_hp"):
		return DrawDataSystemScript.fake_hp_ratio(elapsed)
	if player_max_hp <= 0:
		return 0.0
	return clampf(float(player_hp) / float(player_max_hp), 0.0, 1.0)

func _mental_hud_fill_color(ratio: float) -> Color:
	if ModifierSystemScript.has_effect_for_target(self, "hide_hp"):
		return Color("#9ca3af")
	if ratio <= 0.25:
		return Color("#ff4f8f")
	if ratio <= 0.55:
		return Color("#ffd166")
	return Color("#4ade80")

func _draw_mental_hud_card_v25(rect: Rect2) -> void:
	var ratio := _mental_hud_ratio()
	var accent := _mental_hud_fill_color(ratio)
	var image_drawn := _draw_hud_ui_texture_v25(HUD_UI_METRIC_MENTAL_IMAGE, rect)
	if not image_drawn:
		_draw_ranking_panel(rect, Color(1.0, 1.0, 1.0, 0.94), Color("#ffc1da"), 6, 2, false)
		draw_rect(Rect2(rect.position + Vector2(0, rect.size.y - 5), Vector2(rect.size.x, 5)), accent, true)
	if not _draw_hud_metric_icon_v25(HUD_METRIC_ICON_MENTAL_IMAGE, Rect2(rect.position + Vector2(11, 10), Vector2(38, 38))):
		_draw_text_item({"pos": rect.position + Vector2(18, 51), "text": "♡", "width": 28, "size": 26, "color": accent})
	_draw_text_item({"pos": rect.position + Vector2(58, 32), "text": "メンタル", "width": 92, "size": 14, "color": Color("#101420")})
	_draw_text_item({"pos": rect.position + Vector2(rect.size.x - 64, 32), "text": _mental_hud_text(), "width": 48, "size": 15, "color": Color("#101420")}, "", HORIZONTAL_ALIGNMENT_RIGHT)
	var gauge := Rect2(rect.position + Vector2(58, 37), Vector2(rect.size.x - 74, 12))
	_draw_ranking_panel(gauge, Color("#e7f7ee"), Color(1, 1, 1, 0), 5, 0, false)
	_draw_ranking_panel(Rect2(gauge.position, Vector2(gauge.size.x * ratio, gauge.size.y)), accent, Color(1, 1, 1, 0), 5, 0, false)
	_draw_rect_outline(gauge, Color("#b9e8cb"), 1)

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
	_draw_equipment_icon_row(player_weapons, weapons, Vector2(992, 821), true)
	_draw_equipment_icon_row(player_accessories, gifts, Vector2(1312, 821), false)

func _draw_equipment_icon_row(items: Array, source_data: Array, start: Vector2, is_weapon: bool) -> void:
	var slot_size := Vector2(38, 38)
	var step := 41.0
	var accent := Color("#ffd15a") if is_weapon else Color("#55d8ec")
	var empty_border := Color(0.72, 0.67, 0.82, 0.42)
	var fill := Color("#fffdf3") if is_weapon else Color("#f2fdff")
	var empty_mark := "◇" if is_weapon else "♡"
	for i in range(5):
		var slot_rect := Rect2(start + Vector2(i * step, 0), slot_size)
		var filled := i < items.size()
		var slot_image := ""
		if is_weapon:
			slot_image = HUD_UI_SLOT_WEAPON_FILLED_IMAGE if filled else HUD_UI_SLOT_WEAPON_EMPTY_IMAGE
		else:
			slot_image = HUD_UI_SLOT_ACCESSORY_FILLED_IMAGE if filled else HUD_UI_SLOT_ACCESSORY_EMPTY_IMAGE
		if not _draw_hud_ui_texture_v25(slot_image, slot_rect):
			draw_rect(slot_rect, Color(fill.r, fill.g, fill.b, 0.96 if filled else 0.50), true)
			_draw_rect_outline(slot_rect, accent if filled else empty_border, 2 if filled else 1)
		if i >= items.size():
			_draw_text_item({
				"pos": slot_rect.position + Vector2(0, 28),
				"text": empty_mark,
				"width": int(slot_rect.size.x),
				"size": 17,
				"color": Color(accent.r, accent.g, accent.b, 0.25)
			}, "", HORIZONTAL_ALIGNMENT_CENTER)
			continue
		var entry: Dictionary = items[i] as Dictionary
		var id: String = String(entry.get("id", ""))
		var data: Dictionary = _find_equipment_icon_data(source_data, id)
		var texture: Texture2D = _load_equipment_icon(String(data.get("iconPath", "")))
		if texture != null:
			var icon_rect := _fit_texture_rect(slot_rect.grow(0.5), texture.get_size())
			_draw_ranking_panel(icon_rect.grow(1.0), Color(1.0, 1.0, 1.0, 0.70), Color(1.0, 1.0, 1.0, 0.50), 7, 1, false)
			draw_texture_rect(texture, icon_rect, false)
		else:
			var fallback_text: String = DrawDataSystemScript.equipment_icon(id, is_weapon)
			_draw_text_item({"pos": slot_rect.position + Vector2(8, 27), "text": fallback_text, "width": 26, "size": 16, "color": Color("#1f2a3a")})
		var evolved_level := EquipmentSystem.is_evolved_entry(entry)
		var level_text: String = "進" if evolved_level else str(EquipmentSystem.entry_level(entry))
		var badge_width := 23.0 if level_text.length() >= 2 else 18.0
		var badge_rect := Rect2(slot_rect.end - Vector2(badge_width, 15.0), Vector2(badge_width, 15.0))
		var badge_fill := Color("#ffd15a") if evolved_level else Color("#ff4f92")
		var badge_text_color := Color("#6a3a00") if evolved_level else Color.WHITE
		_draw_ranking_panel(badge_rect, Color(badge_fill.r, badge_fill.g, badge_fill.b, 0.92), Color(1, 1, 1, 0.86), 5, 1, false)
		_draw_text_item({
			"pos": badge_rect.position + Vector2(1, 13),
			"text": level_text,
			"width": int(badge_rect.size.x),
			"size": 12,
			"color": Color(0, 0, 0, 0.24),
			"fontWeight": "black"
		}, "", HORIZONTAL_ALIGNMENT_CENTER)
		_draw_text_item({
			"pos": badge_rect.position + Vector2(0, 12),
			"text": level_text,
			"width": int(badge_rect.size.x),
			"size": 12,
			"color": badge_text_color,
			"fontWeight": "black"
		}, "", HORIZONTAL_ALIGNMENT_CENTER)

func _find_equipment_icon_data(source_data: Array, id: String) -> Dictionary:
	for item in source_data:
		var data: Dictionary = item as Dictionary
		if String(data.get("id", "")) == id:
			return data
	return {}

func _equipment_icon_path_for_item(item: Dictionary, source_data: Array = []) -> String:
	var icon_path: String = String(item.get("iconPath", ""))
	if icon_path != "":
		return icon_path
	var id: String = String(item.get("id", ""))
	if id == "":
		return ""
	var data: Dictionary = _find_equipment_icon_data(source_data, id)
	icon_path = String(data.get("iconPath", ""))
	if icon_path != "":
		return icon_path
	var generated_path := "res://assets/generated/equipment_icons_v1/icons/%s.png" % id
	if FileAccess.file_exists(generated_path):
		return generated_path
	return ""

func _load_equipment_icon(path: String) -> Texture2D:
	return TextureCacheSystemScript.load_png_texture(equipment_icon_cache, path)

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
	_draw_title_character_image(TITLE_SUPANA_IMAGE, TITLE_SUPANA_RECT, TITLE_SUPANA_START_OFFSET, 0.04, 0.0)
	_draw_title_character_image(TITLE_MARON_IMAGE, TITLE_MARON_RECT, TITLE_MARON_START_OFFSET, 0.18, 0.7)
	_draw_title_character_image(TITLE_BANCHAN_IMAGE, TITLE_BANCHAN_RECT, TITLE_BANCHAN_START_OFFSET, 0.30, 1.4)
	_draw_title_image(TITLE_LOGO_IMAGE, _title_logo_draw_rect())
	_draw_title_image(TITLE_BUTTON_IMAGE, TITLE_BUTTON_RECT)
	_draw_title_quit_button(title_menu_index == TITLE_QUIT_INDEX)
	_draw_title_button_selection()
	return true

func _update_title_logo_drop(delta: float) -> void:
	if state != "title":
		return
	title_logo_drop_timer = maxf(0.0, title_logo_drop_timer - delta)

func _update_title_character_appear(delta: float) -> void:
	if state != "title":
		return
	title_character_appear_timer = maxf(0.0, title_character_appear_timer - delta)

func _title_logo_draw_rect() -> Rect2:
	if title_logo_drop_timer <= 0.0:
		return TITLE_LOGO_RECT
	var progress := clampf((TITLE_LOGO_DROP_DURATION - title_logo_drop_timer) / TITLE_LOGO_DROP_DURATION, 0.0, 1.0)
	var shifted := progress - 1.0
	var eased := 1.0 + 2.70158 * shifted * shifted * shifted + 1.70158 * shifted * shifted
	var y := lerpf(TITLE_LOGO_RECT.position.y + TITLE_LOGO_DROP_START_Y_OFFSET, TITLE_LOGO_RECT.position.y, eased)
	return Rect2(Vector2(TITLE_LOGO_RECT.position.x, y), TITLE_LOGO_RECT.size)

func _title_character_appear_progress(delay: float) -> float:
	var elapsed := TITLE_CHARACTER_APPEAR_TOTAL_DURATION - title_character_appear_timer
	return clampf((elapsed - delay) / TITLE_CHARACTER_APPEAR_DURATION, 0.0, 1.0)

func _title_character_ease(progress: float) -> float:
	return 1.0 - pow(1.0 - progress, 3.0)

func _title_character_draw_rect(final_rect: Rect2, start_offset: Vector2, delay: float, phase: float) -> Rect2:
	var progress := _title_character_appear_progress(delay)
	var eased := _title_character_ease(progress)
	var start_pos := final_rect.position + start_offset
	var pos := start_pos.lerp(final_rect.position, eased)
	var idle_strength := smoothstep(0.72, 1.0, progress)
	var clock := float(Time.get_ticks_msec()) / 1000.0
	pos.y += sin(clock * 2.0 + phase) * 2.0 * idle_strength
	return Rect2(pos, final_rect.size)

func _draw_title_image(path: String, rect: Rect2, modulate: Color = Color.WHITE) -> void:
	var texture: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, path)
	if texture == null:
		return
	draw_texture_rect(texture, rect, false, modulate)

func _draw_title_character_image(path: String, final_rect: Rect2, start_offset: Vector2, delay: float, phase: float) -> void:
	var progress := _title_character_appear_progress(delay)
	var alpha := smoothstep(0.0, 0.45, progress)
	_draw_title_image(path, _title_character_draw_rect(final_rect, start_offset, delay, phase), Color(1, 1, 1, alpha))

func _draw_title_button_selection() -> void:
	var rect: Rect2 = _title_button_hit_rect(title_menu_index).grow(6.0)
	var pulse: float = 0.5 + sin(float(Time.get_ticks_msec()) / 1000.0 * 6.5) * 0.5
	var is_quit_selected := title_menu_index == TITLE_QUIT_INDEX
	var corner_radius := 54 if is_quit_selected else 48
	var outer_corner_radius := 62 if is_quit_selected else 56
	var outer_grow := 3.0 if is_quit_selected else 8.0
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1.0, 0.97, 0.45, 0.08 + pulse * 0.08)
	style.border_color = Color(1.0, 0.96, 0.25, 0.72 + pulse * 0.22)
	style.set_border_width_all(4 if is_quit_selected else 5)
	style.set_corner_radius_all(corner_radius)
	draw_style_box(style, rect)
	var outer_style := StyleBoxFlat.new()
	outer_style.bg_color = Color(1.0, 1.0, 1.0, 0.0)
	outer_style.border_color = Color(1.0, 1.0, 1.0, 0.20 + pulse * 0.16)
	outer_style.set_border_width_all(3)
	outer_style.set_corner_radius_all(outer_corner_radius)
	draw_style_box(outer_style, rect.grow(outer_grow))

func _draw_title_quit_button(selected: bool) -> void:
	var rect := TITLE_QUIT_BUTTON_RECT
	var texture: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, TITLE_QUIT_BUTTON_IMAGE)
	if texture != null:
		var image_rect := _fit_texture_rect(rect, texture.get_size())
		var alpha := 1.0 if selected else 0.96
		draw_texture_rect(texture, image_rect, false, Color(1, 1, 1, alpha))
		return
	var fill := Color("#fff4fb") if selected else Color(1.0, 0.98, 1.0, 0.82)
	var border := Color("#ff62b5") if selected else Color("#e7cfe1")
	var text_color := Color("#e73778") if selected else Color("#6b4a63")
	_draw_ranking_panel(rect, fill, border, 42, 3 if selected else 2, true)
	_draw_ranking_text("終了する", rect.position + Vector2(0, 72), 24, text_color, rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)

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
	_draw_ranking_reset_confirm()

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
	_draw_ranking_text(String(view.get("title", "ランキング")), rect.position + Vector2(96, 44), 34, Color("#4f3149"), 720)
	draw_circle(rect.position + Vector2(48, 34), 22, Color("#fff4fb"))
	var icon: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, RANKING_PODIUM_ICON)
	if icon != null:
		var icon_rect := Rect2(rect.position + Vector2(18, 8), Vector2(60, 52))
		draw_texture_rect(icon, _fit_texture_rect(icon_rect, icon.get_size()), false, Color(1, 1, 1, 0.98))
	else:
		_draw_ranking_text("視", rect.position + Vector2(36, 44), 23, Color("#f05aa5"), 32, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_ranking_lock_icon(rect: Rect2, selected: bool) -> void:
	var icon: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, RANKING_LOCK_ICON)
	if icon == null:
		return
	var alpha := 0.98 if selected else 0.86
	draw_texture_rect(icon, _fit_texture_rect(rect, icon.get_size()), false, Color(1, 1, 1, alpha))

func _ranking_rank_icon_path(rank: int) -> String:
	if rank <= 1:
		return RANKING_RANK_ICON_1
	if rank == 2:
		return RANKING_RANK_ICON_2
	if rank == 3:
		return RANKING_RANK_ICON_3
	return RANKING_RANK_ICON_4_PLUS

func _ranking_rank_text_color(rank: int) -> Color:
	if rank <= 1:
		return Color("#8a5200")
	if rank == 2:
		return Color("#52606c")
	if rank == 3:
		return Color("#8c4a18")
	return Color("#7c7386")

func _draw_ranking_rank_icon(rect: Rect2, rank: int) -> void:
	var safe_rank: int = maxi(1, rank)
	var icon_path := _ranking_rank_icon_path(safe_rank)
	var icon: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, icon_path)
	if icon == null:
		_draw_ranking_text(str(safe_rank), rect.position + Vector2(0, rect.size.y * 0.68), 46, _ranking_rank_text_color(safe_rank), rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)
		return
	draw_texture_rect(icon, _fit_texture_rect(rect, icon.get_size()), false, Color(1, 1, 1, 0.98))
	var rank_label := str(safe_rank)
	var font_size := 32
	if rank_label.length() >= 2:
		font_size = 25
	if rank_label.length() >= 3:
		font_size = 20
	var text_y := rect.position.y + rect.size.y * 0.61
	var text_x := rect.position.x - 1.0
	if safe_rank <= 3:
		text_y = rect.position.y + rect.size.y * 0.67
		text_x = rect.position.x + 1.0
	_draw_ranking_text(rank_label, Vector2(text_x + 1.0, text_y + 1.0), font_size, Color(1, 1, 1, 0.82), rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_ranking_text(rank_label, Vector2(text_x, text_y), font_size, _ranking_rank_text_color(safe_rank), rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)

func _ranking_end_icon_path(end_type: String) -> String:
	if end_type == "mental_breakdown":
		return RANKING_END_MENTAL_ICON
	if end_type == "completed":
		return RANKING_END_COMPLETE_ICON
	return ""

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
		var focused: bool = selected and ranking_focus_area == RANKING_FOCUS_TABS
		var locked: bool = bool(tab.get("locked", false))
		var fill := Color(1, 1, 1, 0.93)
		var border := Color("#e7d7e5")
		var text_color := Color("#5d3b56")
		if focused:
			fill = Color("#ff93cd")
			border = Color("#ff62b5")
			text_color = Color.WHITE
		elif selected:
			fill = Color("#fff3fb")
			border = Color("#ff9acb")
			text_color = Color("#d64e98")
		elif locked:
			fill = Color("#f2eef2")
			text_color = Color("#9a8f98")
		_draw_ranking_panel(rect, fill, border, 18, 3 if focused else 2, false)
		var label: String = String(tab.get("label", ""))
		var display_label: String = label.replace(" 未開放", "")
		var text_size := 19
		if display_label.length() >= 8:
			text_size = 16
		var text_width := rect.size.x - (36.0 if locked else 0.0)
		_draw_ranking_text(display_label, rect.position + Vector2(0, 38), text_size, text_color, text_width, HORIZONTAL_ALIGNMENT_CENTER)
		if locked:
			var icon_rect := Rect2(rect.position + Vector2(rect.size.x - 44.0, 15.0), Vector2(30.0, 30.0))
			_draw_ranking_lock_icon(icon_rect, selected)
		if selected:
			var p1 := rect.position + Vector2(rect.size.x * 0.5 - 12.0, rect.size.y + 2.0)
			var p2 := rect.position + Vector2(rect.size.x * 0.5 + 12.0, rect.size.y + 2.0)
			var p3 := rect.position + Vector2(rect.size.x * 0.5, rect.size.y + 22.0)
			draw_colored_polygon(PackedVector2Array([p1, p2, p3]), Color("#ff62b5") if focused else Color("#ffb9dc"))

func _draw_ranking_list_panel(panel: Rect2, view: Dictionary) -> void:
	var empty_or_locked := bool(view.get("locked", false)) or bool(view.get("empty", false))
	var panel_focused := ranking_focus_area == RANKING_FOCUS_ENTRIES and empty_or_locked
	_draw_ranking_panel(panel, Color(1, 1, 1, 0.93), Color("#ff67b8") if panel_focused else Color("#ead7e9"), 24, 4 if panel_focused else 2, true)
	var title: String = String(view.get("subtitle", "最大同時視聴者数ランキング"))
	_draw_ranking_text(title, panel.position + Vector2(30, 42), 28, Color("#7a3fb0"), panel.size.x - 60)
	var rows: Array = view.get("rows", []) as Array
	if empty_or_locked:
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
		_draw_ranking_row(rect, row, ranking_focus_area == RANKING_FOCUS_ENTRIES)
	if rows.size() > visible_count:
		var bar_rect := Rect2(panel.end.x - 22, panel.position.y + 72, 8, panel.size.y - 104)
		draw_rect(bar_rect, Color("#f3deef"), true)
		var ratio: float = float(visible_count) / float(rows.size())
		var thumb_h: float = maxf(44.0, bar_rect.size.y * ratio)
		var denom: int = maxi(1, rows.size() - visible_count)
		var thumb_y: float = bar_rect.position.y + (bar_rect.size.y - thumb_h) * float(start) / float(denom)
		draw_rect(Rect2(bar_rect.position.x, thumb_y, bar_rect.size.x, thumb_h), Color("#ff7dbc"), true)

func _draw_ranking_row(rect: Rect2, row: Dictionary, selection_active: bool = true) -> void:
	var selected: bool = selection_active and bool(row.get("selected", false))
	var accent: Color = row.get("accent", Color("#8d6be8")) as Color
	_draw_ranking_panel(
		rect,
		Color(1, 1, 1, 0.98),
		Color("#ff67b8") if selected else Color("#ead7e9"),
		18,
		4 if selected else 2,
		false
	)
	_draw_ranking_rank_icon(Rect2(rect.position + Vector2(16, 14), Vector2(78, 78)), int(row.get("rank", 0)))
	var avatar_pos := rect.position + Vector2(132, 54)
	_draw_ranking_character_avatar(avatar_pos, 36.0, row, accent)
	_draw_ranking_text(_short_pause_text(_ranking_formal_character_name(row), 13), rect.position + Vector2(188, 36), 25, accent, 190)
	_draw_ranking_text(_short_pause_text(String(row.get("scoreText", "")), 18), rect.position + Vector2(188, 68), 26, Color("#ff4d9f"), 190)
	_draw_ranking_row_build_icons(Rect2(rect.position + Vector2(370, 28), Vector2(238, 72)), row.get("weapons", []) as Array, row.get("accessories", []) as Array)
	_draw_ranking_end_type_badge(Rect2(rect.end - Vector2(126, 82), Vector2(108, 64)), String(row.get("endTypeLabel", "")), String(row.get("endType", "")))

func _ranking_formal_character_name(row: Dictionary) -> String:
	var character_id := String(row.get("characterId", "")).strip_edges()
	var name := String(row.get("title", row.get("character", ""))).strip_edges()
	if character_id == "ban_chan" or character_id == "banri" or name == "ばんちゃん" or name == "ばん" or name == "赤羽ばんり":
		return "赤羽ばんり"
	if character_id == "superchat_chan" or character_id == "supana" or name == "すぱなちゃん" or name == "すぱ" or name == "星投すぱな":
		return "星投すぱな"
	if character_id == "maro_chan" or character_id == "maron" or name == "まろんちゃん" or name == "まろ" or name == "白綿まろん":
		return "白綿まろん"
	return name

func _draw_ranking_row_build_icons(area: Rect2, weapons: Array, accessories: Array) -> void:
	var slot := 34.0
	var gap := 4.0
	var label_w := 42.0
	var weapon_y := area.position.y
	var accessory_y := area.position.y + 36.0
	_draw_ranking_text("武器", area.position + Vector2(0, 20), 13, Color("#b7771f"), label_w)
	_draw_ranking_text("アクセ", area.position + Vector2(0, 56), 13, Color("#208a9b"), label_w)
	for index in range(5):
		var x: float = area.position.x + label_w + float(index) * (slot + gap)
		_draw_ranking_equipment_icon_slot(Rect2(x, weapon_y, slot, slot), _ranking_item_at(weapons, index), Color("#ffb547"), true)
		_draw_ranking_equipment_icon_slot(Rect2(x, accessory_y, slot, slot), _ranking_item_at(accessories, index), Color("#55cfe0"), true)

func _ranking_item_at(items: Array, index: int) -> Dictionary:
	if index < 0 or index >= items.size():
		return {}
	if not (items[index] is Dictionary):
		return {}
	return items[index] as Dictionary

func _draw_ranking_equipment_icon_slot(rect: Rect2, item: Dictionary, accent: Color, compact: bool = false) -> void:
	var filled: bool = not item.is_empty()
	var evolved: bool = filled and (bool(item.get("isEvolved", false)) or String(item.get("levelLabel", "")) == "進化")
	var border: Color = Color("#ffd45a") if evolved else accent
	var fill := Color(1, 1, 1, 0.96) if filled else Color(1, 1, 1, 0.46)
	if filled and evolved:
		_draw_ranking_panel(rect.grow(2.0), Color(1.0, 0.78, 0.22, 0.10), Color("#ffd45a"), 8, 1, false)
	_draw_ranking_panel(rect, fill, border if filled else Color("#decfeb"), 7, 2, false)
	if filled:
		var icon_path: String = _equipment_icon_path_for_item(item, gifts)
		var icon: Texture2D = _load_equipment_icon(icon_path) if icon_path != "" else null
		var icon_padding := 2.0 if compact else 4.0
		var icon_rect := rect.grow(-icon_padding)
		if icon != null:
			draw_texture_rect(icon, _fit_texture_rect(icon_rect, icon.get_size()), false, Color(1, 1, 1, 0.98))
		else:
			var fallback: String = String(item.get("displayName", item.get("id", "?")))
			_draw_ranking_text(_short_pause_text(fallback, 2), rect.position + Vector2(0, rect.size.y * 0.65), 13, Color("#76536f"), rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)
		if evolved and compact:
			draw_circle(rect.position + Vector2(rect.size.x - 4.0, 4.0), 3.0, Color("#ffd45a"))
	if filled and not compact:
		var level_label: String = String(item.get("levelLabel", ""))
		if level_label == "":
			level_label = "Lv%d" % int(item.get("level", 1))
		var badge_rect := Rect2(rect.position + Vector2(rect.size.x - 28, rect.size.y - 15), Vector2(30, 14))
		draw_rect(badge_rect, Color("#ff70b6") if not evolved else Color("#ffc94c"), true)
		_draw_ranking_text(_short_pause_text(level_label, 4), badge_rect.position + Vector2(0, 11), 9, Color.WHITE, badge_rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_ranking_end_type_badge(rect: Rect2, label: String, end_type: String) -> void:
	if end_type == "":
		if label == "崩壊":
			end_type = "mental_breakdown"
		elif label == "完走":
			end_type = "completed"
		elif label == "中断":
			end_type = "relay_failed"
	var fill := Color("#fff1a9")
	var border := Color("#f6bf3f")
	var text_color := Color("#9b6b18")
	if end_type == "mental_breakdown":
		fill = Color("#ffe2f0")
		border = Color("#ff76b8")
		text_color = Color("#c23d7f")
	elif end_type == "completed":
		fill = Color("#fff8e4")
		border = Color("#ffcf72")
		text_color = Color("#d58119")
	elif end_type == "relay_failed" or end_type == "quit" or end_type == "debug":
		fill = Color("#edf1f6")
		border = Color("#b8c2d1")
		text_color = Color("#697487")
	_draw_ranking_panel(rect, fill, border, 14, 2, false)
	var icon_path := _ranking_end_icon_path(end_type)
	if rect.size.y >= 48.0:
		if icon_path != "":
			var vertical_icon: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, icon_path)
			if vertical_icon != null:
				var vertical_icon_size: float = minf(rect.size.x - 44.0, rect.size.y - 25.0)
				var vertical_icon_rect := Rect2(
					rect.position + Vector2((rect.size.x - vertical_icon_size) * 0.5, 6.0),
					Vector2(vertical_icon_size, vertical_icon_size)
				)
				draw_texture_rect(vertical_icon, _fit_texture_rect(vertical_icon_rect, vertical_icon.get_size()), false, Color(1, 1, 1, 0.98))
		_draw_ranking_text(label, rect.position + Vector2(0, rect.size.y - 8.0), 14, text_color, rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)
		return
	var text_size := 16 if rect.size.y >= 36.0 else 14
	var text_pos := rect.position + Vector2(0, rect.size.y * 0.67)
	var text_width := rect.size.x
	if icon_path != "":
		var icon: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, icon_path)
		if icon != null:
			var icon_size: float = minf(rect.size.y - 8.0, 30.0)
			var icon_rect := Rect2(rect.position + Vector2(7.0, (rect.size.y - icon_size) * 0.5), Vector2(icon_size, icon_size))
			draw_texture_rect(icon, _fit_texture_rect(icon_rect, icon.get_size()), false, Color(1, 1, 1, 0.98))
			text_pos.x += icon_size + 12.0
			text_width -= icon_size + 14.0
	_draw_ranking_text(label, text_pos, text_size, text_color, text_width, HORIZONTAL_ALIGNMENT_CENTER)

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
	var detail: Dictionary = view.get("detail", {}) as Dictionary
	var title: String = String(detail.get("title", "記録詳細"))
	_draw_ranking_text(title, panel.position + Vector2(30, 42), 28, Color("#ff5aa5"), panel.size.x - 60)
	if bool(view.get("locked", false)) or bool(view.get("empty", false)):
		_draw_ranking_message(panel, view.get("messageLines", []) as Array)
		return
	if detail.is_empty():
		_draw_ranking_message(panel, ["記録詳細を表示できません。"])
		return
	_draw_ranking_detail_summary(Rect2(panel.position + Vector2(20, 70), Vector2(panel.size.x - 40, 112)), detail)
	_draw_ranking_detail_stats(Rect2(panel.position + Vector2(20, 196), Vector2(292, 176)), detail.get("stats", []) as Array)
	_draw_ranking_detail_build_slots(Rect2(panel.position + Vector2(330, 196), Vector2(panel.size.x - 350, 176)), detail.get("weapons", []) as Array, detail.get("accessories", []) as Array)
	_draw_ranking_detail_instruction(Rect2(panel.position + Vector2(20, 386), Vector2(panel.size.x - 40, 160)), detail)
	_draw_ranking_detail_played_at_line(Rect2(panel.position + Vector2(20, 562), Vector2(panel.size.x - 40, 34)), detail)

func _draw_ranking_detail_summary(rect: Rect2, detail: Dictionary) -> void:
	_draw_ranking_panel(rect, Color(1, 1, 1, 0.96), Color("#ffd1e5"), 16, 2, false)
	_draw_ranking_text(String(detail.get("rankLabel", "記録")), rect.position + Vector2(18, 28), 20, Color("#b1509c"), 180)
	var end_badge_rect := Rect2(Vector2(rect.end.x - 132.0, rect.position.y + (rect.size.y - 68.0) * 0.5), Vector2(112, 68))
	_draw_ranking_end_type_badge(end_badge_rect, String(detail.get("endTypeLabel", "")), String(detail.get("endType", "")))
	var lines: Array = detail.get("summaryLines", []) as Array
	for index in range(mini(lines.size(), 3)):
		var size := 21 if index == 1 else 17
		var color := Color("#ff4d9f") if index == 1 else Color("#5d4658")
		_draw_ranking_text(_short_pause_text(String(lines[index]), 34), rect.position + Vector2(18, 58 + float(index) * 24.0), size, color, rect.size.x - 152)

func _draw_ranking_detail_stats(rect: Rect2, stats: Array) -> void:
	_draw_ranking_panel(rect, Color(1, 1, 1, 0.96), Color("#efd5e7"), 14, 2, false)
	_draw_ranking_text("統計情報", rect.position + Vector2(18, 31), 19, Color("#b1509c"), rect.size.x - 36)
	for index in range(mini(stats.size(), 6)):
		if not (stats[index] is Dictionary):
			continue
		var item: Dictionary = stats[index] as Dictionary
		var y: float = rect.position.y + 60.0 + float(index) * 18.5
		_draw_ranking_text(_short_pause_text(String(item.get("label", "")), 10), Vector2(rect.position.x + 18, y), 14, Color("#7a6d79"), 118)
		_draw_ranking_text(_short_pause_text(String(item.get("value", "")), 14), Vector2(rect.position.x + 132, y), 15, Color("#ff4d9f"), rect.size.x - 150, HORIZONTAL_ALIGNMENT_RIGHT)

func _draw_ranking_detail_build_slots(rect: Rect2, weapons: Array, accessories: Array) -> void:
	_draw_ranking_panel(rect, Color(1, 1, 1, 0.96), Color("#d7c8ff"), 14, 2, false)
	_draw_ranking_text("ビルド構成", rect.position + Vector2(18, 31), 19, Color("#7a52cd"), rect.size.x - 36)
	var slot := 38.0
	var gap := 6.0
	var weapon_y := rect.position.y + 62.0
	var accessory_y := rect.position.y + 118.0
	_draw_ranking_text("武器", rect.position + Vector2(18, 87), 15, Color("#5d4658"), 42)
	_draw_ranking_text("アクセ", rect.position + Vector2(18, 143), 15, Color("#5d4658"), 48)
	for index in range(5):
		var x: float = rect.position.x + 72.0 + float(index) * (slot + gap)
		_draw_ranking_equipment_icon_slot(Rect2(x, weapon_y, slot, slot), _ranking_item_at(weapons, index), Color("#ffb547"), false)
		_draw_ranking_equipment_icon_slot(Rect2(x, accessory_y, slot, slot), _ranking_item_at(accessories, index), Color("#55cfe0"), false)

func _draw_ranking_detail_instruction(rect: Rect2, detail: Dictionary) -> void:
	_draw_ranking_panel(rect, Color(1, 1, 1, 0.96), Color("#ffbfdc"), 14, 2, false)
	_draw_ranking_text(String(detail.get("instructionTitle", "指示コメ")), rect.position + Vector2(18, 31), 19, Color("#ff5aa5"), rect.size.x - 36)
	var lines: Array = detail.get("instructionLines", []) as Array
	for index in range(mini(lines.size(), 3)):
		var color := Color("#5d4658") if index > 0 else Color("#b1509c")
		_draw_ranking_text(_short_pause_text(String(lines[index]), 44), rect.position + Vector2(18, 61 + float(index) * 23.0), 16, color, rect.size.x - 36)
	var boss_text: String = String(detail.get("bossText", "なし"))
	_draw_ranking_text("ボス：%s" % _short_pause_text(boss_text, 28), rect.position + Vector2(18, rect.size.y - 18), 14, Color("#7a6d79"), rect.size.x - 36)

func _draw_ranking_detail_meta(rect: Rect2, detail: Dictionary) -> void:
	_draw_ranking_panel(rect, Color("#fffaf0"), Color("#f2c96e"), 14, 2, false)
	_draw_ranking_text("記録日時", rect.position + Vector2(18, 31), 18, Color("#b7771f"), rect.size.x - 36)
	_draw_ranking_text(String(detail.get("playedAtText", "不明")), rect.position + Vector2(18, 62), 19, Color("#5d4658"), rect.size.x - 36)

func _draw_ranking_detail_played_at_line(rect: Rect2, detail: Dictionary) -> void:
	var played_at := String(detail.get("playedAtText", "不明"))
	_draw_ranking_text("記録日時：%s" % played_at, rect.position + Vector2(0, 23), 14, Color("#8a6b82"), rect.size.x, HORIZONTAL_ALIGNMENT_RIGHT)

func _draw_ranking_detail_card(rect: Rect2, card: Dictionary) -> void:
	_draw_ranking_panel(rect, Color(1, 1, 1, 0.97), Color("#efd5e7"), 14, 2, false)
	_draw_ranking_text(_short_pause_text(String(card.get("title", "")), 16), rect.position + Vector2(18, 31), 19, Color("#b1509c"), rect.size.x - 36)
	var lines: Array = card.get("lines", []) as Array
	for index in range(mini(lines.size(), 4)):
		var text: String = _short_pause_text(String(lines[index]), 28)
		_draw_ranking_text(text, rect.position + Vector2(18, 60 + float(index) * 24.0), 16, Color("#5d4658"), rect.size.x - 36)

func _ranking_footer_rect() -> Rect2:
	return Rect2(76, 848, 1448, 44)

func _ranking_back_button_rect() -> Rect2:
	var footer := _ranking_footer_rect()
	return Rect2(footer.end.x - 154.0, footer.position.y + 6.0, 132.0, 32.0)

func _draw_ranking_footer() -> void:
	var rect := _ranking_footer_rect()
	var back_rect := _ranking_back_button_rect()
	var back_selected := ranking_focus_area == RANKING_FOCUS_BACK
	_draw_ranking_panel(rect, Color(1, 1, 1, 0.94), Color("#ead7e9"), 18, 2, true)
	_draw_ranking_text("←→：タブ　↑↓：記録　Enter：詳細　Esc：戻る　R：リセット", rect.position + Vector2(0, 29), 18, Color("#6b4a63"), back_rect.position.x - rect.position.x - 18.0, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_ranking_panel(back_rect, Color("#ff93cd") if back_selected else Color("#eef9ff"), Color("#ff62b5") if back_selected else Color("#9ed9f4"), 14, 3 if back_selected else 2, false)
	_draw_ranking_text("戻る", back_rect.position + Vector2(0, 23), 16, Color.WHITE if back_selected else Color("#2587b8"), back_rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_ranking_reset_confirm() -> void:
	if not ranking_reset_confirm_visible:
		return
	draw_rect(TITLE_SCREEN_RECT, Color(0.16, 0.06, 0.13, 0.42), true)
	var rect := Rect2(500, 282, 600, 284)
	_draw_ranking_panel(rect, Color(1, 1, 1, 0.98), Color("#ff7dbc"), 22, 3, true)
	var target_label: String = RankingSystemScript.tab_reset_label(ranking_tab_index, relay_mode_unlocked)
	_draw_ranking_text("%sランキングをリセットしますか？" % target_label, rect.position + Vector2(0, 76), 28, Color("#4f3149"), rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_ranking_text("この操作は元に戻せません。", rect.position + Vector2(0, 118), 19, Color("#8a6b82"), rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	var labels: Array[String] = ["はい", "いいえ"]
	var button_y := rect.position.y + 184.0
	for index in range(labels.size()):
		var button_rect := Rect2(rect.position.x + 92.0 + float(index) * 222.0, button_y, 194, 54)
		var selected: bool = index == ranking_reset_confirm_index
		var fill := Color("#ff5aa5") if selected else Color(1, 1, 1, 0.96)
		var border := Color("#ff4d9f") if selected else Color("#ead7e9")
		var text_color := Color.WHITE if selected else Color("#6b4a63")
		_draw_ranking_panel(button_rect, fill, border, 16, 2, false)
		_draw_ranking_text(labels[index], button_rect.position + Vector2(0, 36), 21, text_color, button_rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)

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
	var options_icon: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, OPTIONS_HEADER_ICON)
	if options_icon != null:
		var icon_rect := Rect2(panel.position + Vector2(54, 30), Vector2(54, 54))
		draw_texture_rect(options_icon, _fit_texture_rect(icon_rect, options_icon.get_size()), false, Color(1, 1, 1, 0.98))
		_draw_ranking_text("オプション", panel.position + Vector2(122, 64), 42, Color("#e73778"), 390)
	else:
		_draw_ranking_text("オプション", panel.position + Vector2(54, 64), 42, Color("#e73778"), 390)
	_draw_ranking_text("ゲームの表示や演出を設定できます", panel.position + Vector2(58, 102), 20, Color("#6b4a63"), 560)
	_draw_ranking_panel(Rect2(panel.position + Vector2(846, 36), Vector2(244, 70)), Color("#fff8fc"), Color("#f2d7e8"), 22, 2, false)
	_draw_ranking_text("↑↓ 選択", panel.position + Vector2(876, 66), 18, Color("#6b4a63"), 94, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_ranking_text("←→ 変更", panel.position + Vector2(976, 66), 18, Color("#6b4a63"), 94, HORIZONTAL_ALIGNMENT_CENTER)
	var items: Array = _option_items()
	var reset_index := items.size()
	var back_index := items.size() + 1
	var list_x := panel.position.x + 52.0
	var y := panel.position.y + 136.0
	var card_width := panel.size.x - 104.0
	for index in range(items.size()):
		var card_rect := Rect2(Vector2(list_x, y + float(index) * 74.0), Vector2(card_width, 64))
		_draw_option_card(card_rect, items[index] as Dictionary, option_menu_index == index)
	var guide_rect := Rect2(panel.position + Vector2(52, 670), Vector2(panel.size.x - 104, 42))
	_draw_ranking_panel(guide_rect, Color("#fff8fc"), Color("#f2d7e8"), 18, 2, false)
	var back_label: String = "ポーズへ戻る" if options_return_state == "pause" else "戻る"
	_draw_ranking_text("↑↓：選択　←→：変更 / 下段移動　Enter：決定　Esc：%s" % back_label, guide_rect.position + Vector2(0, 28), 18, Color("#6b4a63"), guide_rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	var reset_rect := Rect2(panel.position + Vector2(panel.size.x - 52 - 430, 724), Vector2(250, 54))
	var back_rect := Rect2(panel.position + Vector2(panel.size.x - 52 - 160, 724), Vector2(160, 54))
	_draw_options_button(reset_rect, "設定を初期化", option_menu_index == reset_index, Color("#fff0f7"), Color("#d93682"))
	_draw_options_button(back_rect, "戻る", option_menu_index == back_index, Color("#eef9ff"), Color("#2587b8"))

func _option_items() -> Array:
	return [
		{
			"icon": "♪",
			"iconPath": OPTIONS_BGM_ICON,
			"name": "BGM音量",
			"description": "タイトルBGMなどの音量を調整します",
			"type": "slider",
			"value": bgm_volume,
			"accent": Color("#f25a9b")
		},
		{
			"icon": "SE",
			"iconPath": OPTIONS_SE_ICON,
			"name": "SE音量",
			"description": "効果音の音量を保存します",
			"type": "slider",
			"value": se_volume,
			"accent": Color("#4fb8df")
		},
		{
			"icon": "全",
			"iconPath": OPTIONS_FULLSCREEN_ICON,
			"name": "フルスクリーン切替",
			"description": "全画面表示のON/OFFを切り替えます",
			"type": "toggle",
			"on": fullscreen_enabled,
			"accent": Color("#a768dc")
		},
		{
			"icon": "窓",
			"iconPath": OPTIONS_WINDOW_SIZE_ICON,
			"name": "ウィンドウサイズ",
			"description": "ウィンドウ表示時のサイズを選びます",
			"type": "select",
			"value": SettingsSystemScript.window_size_label(window_size_index).replace(" x ", "×"),
			"accent": Color("#6d8dde")
		},
		{
			"icon": "揺",
			"iconPath": OPTIONS_SCREEN_SHAKE_ICON,
			"name": "画面揺れ",
			"description": "ダメージや演出時の画面揺れを切り替えます",
			"type": "toggle",
			"on": screen_shake_enabled,
			"accent": Color("#2fbfb6")
		},
		{
			"icon": "教",
			"iconPath": OPTIONS_TUTORIAL_ICON,
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
	var icon_rect := Rect2(rect.position + Vector2(15, 9), Vector2(46, 46))
	_draw_ranking_panel(icon_rect, Color(accent.r, accent.g, accent.b, 0.13), Color(accent.r, accent.g, accent.b, 0.55), 16, 2, false)
	var icon_path := String(item.get("iconPath", ""))
	var icon_texture: Texture2D = null
	if icon_path != "":
		icon_texture = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, icon_path)
	if icon_texture != null:
		draw_texture_rect(icon_texture, _fit_texture_rect(icon_rect.grow(-3.0), icon_texture.get_size()), false, Color(1, 1, 1, 0.98))
	else:
		_draw_ranking_text(String(item.get("icon", "")), icon_rect.position + Vector2(0, 29), 18, accent, icon_rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_ranking_text(String(item.get("name", "")), rect.position + Vector2(82, 29), 22, Color("#3d3041"), 310)
	_draw_ranking_text(String(item.get("description", "")), rect.position + Vector2(82, 52), 15, Color("#7b6475"), 430)
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
	var mental_breakdown := String(data.get("endType", "")) == "mental_breakdown"
	if mental_breakdown:
		draw_rect(TITLE_SCREEN_RECT, Color(0.08, 0.0, 0.055, 0.78), true)
		_draw_ranking_panel(panel.grow(12.0), Color(0.62, 0.03, 0.31, 0.16), Color(1, 1, 1, 0), 42, 0, false)
		_draw_ranking_panel(panel.grow(5.0), Color(1.0, 0.09, 0.42, 0.06), Color("#9f175f"), 38, 2, false)
	elif completed:
		draw_rect(TITLE_SCREEN_RECT, Color(1.0, 0.98, 0.90, 0.50), true)
		draw_rect(TITLE_SCREEN_RECT, Color(1.0, 1.0, 1.0, 0.12), true)
		_draw_ranking_panel(panel.grow(12.0), Color(1.0, 0.75, 0.18, 0.12), Color(1, 1, 1, 0), 42, 0, false)
		_draw_ranking_panel(panel.grow(5.0), Color(1.0, 0.42, 0.68, 0.08), Color("#ffd46a"), 38, 2, false)
	var panel_border := Color("#ffd46a") if completed else (Color("#d83b8f") if mental_breakdown else Color("#ffbad8"))
	var panel_fill := Color(1.0, 0.995, 0.965, 0.97) if completed else (Color(1.0, 0.94, 0.978, 0.985) if mental_breakdown else Color(1.0, 0.985, 0.995, 0.97))
	_draw_ranking_panel(panel, panel_fill, panel_border, 36, 4, true)
	if mental_breakdown:
		_draw_result_accident_noise(panel)
	elif completed:
		_draw_result_complete_celebration(panel)
	_draw_result_header(panel, data)
	_draw_result_summary_panel(layout["summaryPanel"] as Rect2, data)
	_draw_result_detail_panel(layout["detailPanel"] as Rect2, data)
	if mental_breakdown:
		_draw_result_mental_breakdown_character(layout["characterPanel"] as Rect2, data)
	elif completed:
		_draw_result_stream_complete_character(layout["characterPanel"] as Rect2, data)
	_draw_result_buttons(layout)

func _draw_result_accident_noise(panel: Rect2) -> void:
	var clock := float(Time.get_ticks_msec()) / 1000.0
	for i in range(16):
		var y := panel.position.y + 82.0 + fmod(clock * 34.0 + float(i) * 47.0, panel.size.y - 150.0)
		var x := panel.position.x + 34.0 + fmod(float(i) * 123.0 + sin(clock * 1.3 + float(i)) * 30.0, panel.size.x - 140.0)
		var length := 70.0 + float((i * 31) % 140)
		var color := Color(1.0, 0.17, 0.55, 0.12) if i % 2 == 0 else Color(0.42, 0.95, 1.0, 0.10)
		draw_line(Vector2(x, y), Vector2(minf(panel.end.x - 32.0, x + length), y), color, 1.2, true)
	_draw_result_broken_heart(panel.position + Vector2(panel.size.x - 268.0, 148.0), 18.0, 0.52)

func _draw_result_complete_celebration(panel: Rect2) -> void:
	var clock := float(Time.get_ticks_msec()) / 1000.0
	var colors := [Color("#ff6faf"), Color("#ffd35c"), Color("#8de7ff"), Color("#a875ff")]
	for i in range(22):
		var x := panel.position.x + 44.0 + fmod(float(i) * 137.0 + sin(clock * 0.9 + float(i)) * 24.0, panel.size.x - 88.0)
		var y := panel.position.y + 38.0 + fmod(float(i) * 61.0 - clock * 18.0, panel.size.y - 88.0)
		var color: Color = colors[i % colors.size()] as Color
		var alpha_color := Color(color.r, color.g, color.b, 0.24)
		if i % 3 == 0:
			draw_rect(Rect2(Vector2(x, y), Vector2(14, 6)), alpha_color, true)
		else:
			_draw_stream_start_sparkle(Vector2(x, y), 5.0 + float(i % 3) * 2.0, alpha_color)
	for i in range(5):
		var symbol := "★" if i % 2 == 0 else "♥"
		var pos := panel.position + Vector2(105.0 + float(i) * 238.0, 54.0 + sin(clock * 1.6 + float(i)) * 5.0)
		var text_color := Color(1.0, 0.64, 0.10, 0.28) if symbol == "★" else Color(1.0, 0.34, 0.62, 0.24)
		_draw_ranking_text(symbol, pos, 25, text_color, 38, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_result_header(panel: Rect2, data: Dictionary) -> void:
	var completed := String(data.get("endType", "")) == "completed"
	var mental_breakdown := String(data.get("endType", "")) == "mental_breakdown"
	var accent := Color("#ff9f1c") if completed else (Color("#ee3e8f") if mental_breakdown else Color("#f05aa5"))
	var header_text := String(data.get("resultTitle", "配信終了！"))
	if completed:
		header_text = "配信完走！"
		var success_tag := Rect2(panel.position + Vector2(88, 34), Vector2(126, 30))
		_draw_ranking_panel(success_tag, Color("#ffb433"), Color(1, 1, 1, 0.62), 14, 2, false)
		_draw_ranking_text("配信成功", success_tag.position + Vector2(0, 22), 16, Color.WHITE, success_tag.size.x, HORIZONTAL_ALIGNMENT_CENTER)
		_draw_ranking_text(header_text, panel.position + Vector2(94, 116), 50, accent, 390)
		_draw_ranking_text("最後まで配信を走り切った！", panel.position + Vector2(98, 150), 19, Color("#8a5b1d"), 410)
	elif mental_breakdown:
		var accident_tag := Rect2(panel.position + Vector2(88, 34), Vector2(126, 30))
		_draw_ranking_panel(accident_tag, Color("#ee3e8f"), Color(1, 1, 1, 0.52), 14, 2, false)
		_draw_ranking_text("配信事故", accident_tag.position + Vector2(0, 22), 16, Color.WHITE, accident_tag.size.x, HORIZONTAL_ALIGNMENT_CENTER)
		_draw_ranking_text(header_text, panel.position + Vector2(94, 102), 50, accent, 390)
		_draw_ranking_text("配信は続けられなかった……", panel.position + Vector2(98, 132), 19, Color("#7a415f"), 390)
		_draw_ranking_text(_short_pause_text(String(data.get("summaryLine", "繧ｳ繝｡繝ｳ繝医↓謖ｯ繧雁屓縺輔ｌ縺滄・菫｡縺縺｣縺溪ｦ窶ｦ")), 30), panel.position + Vector2(98, 144), 15, Color("#8a5a72"), 410)
	else:
		_draw_ranking_text(header_text, panel.position + Vector2(112, 78), 46, accent, 360)
	if mental_breakdown:
		draw_rect(Rect2(panel.position + Vector2(86, 116), Vector2(438, 52)), Color(1.0, 0.94, 0.978, 0.985), true)
		var mental_summary := String(data.get("summaryLine", "コメントに振り回された配信だった……"))
		if mental_summary == "":
			mental_summary = "コメントに振り回された配信だった……"
		_draw_ranking_text(_short_pause_text(mental_summary, 32), panel.position + Vector2(98, 142), 17, Color("#7a415f"), 410)
	var rank_rect := Rect2(panel.position + Vector2(482, 26), Vector2(392, 86))
	if mental_breakdown or completed:
		rank_rect = Rect2(panel.position + Vector2(430, 28), Vector2(392, 86))
	_draw_ranking_panel(rank_rect, Color(1, 1, 1, 0.88), Color("#ffd46a") if completed else (Color("#ffc0dc") if mental_breakdown else Color("#d7c5ff")), 20, 2, false)
	if mental_breakdown:
		_draw_ranking_text("今回の配信評価", rank_rect.position + Vector2(24, 54), 20, Color("#c74187"), 150)
	elif completed:
		_draw_ranking_text("配信完走評価", rank_rect.position + Vector2(24, 54), 20, Color("#c97813"), 150)
	else:
		_draw_ranking_text("神回度", rank_rect.position + Vector2(30, 54), 24, Color("#7a56c8"), 116)
	_draw_ranking_text(String(data.get("kamiRank", "D")), rank_rect.position + Vector2(154, 63), 54, _result_rank_color(String(data.get("kamiRank", "D"))), 70, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_ranking_text("%d pt" % int(data.get("kamiPoint", 0)), rank_rect.position + Vector2(244, 58), 34, Color("#7a56c8"), 130)
	var summary_line: String = String(data.get("summaryLine", "これはコメントが悪い。たぶん。"))
	if not mental_breakdown and not completed:
		var summary_rect := Rect2(panel.position + Vector2(196, 128), Vector2(700, 46))
		_draw_ranking_panel(summary_rect, Color(1, 1, 1, 0.78), Color("#f3d3e6"), 20, 2, false)
		_draw_ranking_text(_short_pause_text(summary_line, 44), summary_rect.position + Vector2(14, 29), 20, Color("#4f3149"), summary_rect.size.x - 28, HORIZONTAL_ALIGNMENT_CENTER)
	if not mental_breakdown and not completed:
		var character_rect := Rect2(panel.position + Vector2(938, 18), Vector2(138, 138))
		_draw_ranking_panel(character_rect, Color("#fff5fb"), Color("#f3d3e6"), 22, 2, false)
		_draw_result_character_bust(character_rect.grow(-8), String(data.get("characterId", "")), String(data.get("characterName", "配信者")), false)
		_draw_result_small_badge(panel.position + Vector2(58, 46), "完走" if completed else "BAN", Color("#ffb433") if completed else Color("#ff4b62"))

func _result_mental_kami_label(rank: String) -> Array[String]:
	if rank == "S" or rank == "A":
		return ["事故ったけど", "神回度"]
	if rank == "B" or rank == "C":
		return ["コメント的には", "神回度"]
	return ["今回の配信", "評価"]

func _draw_result_summary_panel(rect: Rect2, data: Dictionary) -> void:
	_draw_ranking_panel(rect, Color(1, 1, 1, 0.88), Color("#ffd2e5"), 20, 2, false)
	_draw_result_ribbon(rect.position + Vector2(70, -18), "配信サマリー", Color("#ff6fa8"))
	var rows: Array = [
		{"icon": "配", "label": "配信者", "value": String(data.get("characterName", "配信者"))},
		{"icon": "枠", "label": "配信枠", "value": String(data.get("streamFrameName", "配信枠"))},
		{"icon": "人", "label": "最大同時視聴者数", "value": "%s 人" % _result_number(int(data.get("viewerCount", data.get("score", 0))))},
		{"icon": "時", "label": "生存時間", "value": ResultSystemScript.format_time(float(data.get("survivalTime", 0.0)))},
		{"icon": "V", "label": "最大ボルテージ", "value": "x%.1f" % float(data.get("maxVoltage", data.get("maxMultiplier", 1.0)))},
		{"icon": "話", "label": "最大バズ度", "value": str(int(data.get("maxBurnCombo", 0)))},
		{"icon": "贈", "label": "ギフト", "value": str(int(data.get("giftCount", 0)))}
	]
	for index in range(rows.size()):
		var row_rect := Rect2(rect.position + Vector2(22, 48 + float(index) * 58.0), Vector2(rect.size.x - 44, 46))
		_draw_result_summary_row(row_rect, rows[index] as Dictionary)

func _draw_result_summary_row(rect: Rect2, row: Dictionary) -> void:
	var label_text: String = String(row.get("label", ""))
	var emphasized := label_text in ["最大同時視聴者数", "生存時間", "最大ボルテージ"]
	var fill := Color(1, 0.985, 0.995, 0.94) if emphasized else Color(1, 1, 1, 0.88)
	var border := Color("#ffacd0") if emphasized else Color("#f4d5e6")
	_draw_ranking_panel(rect, fill, border, 12, 2 if emphasized else 1, false)
	draw_circle(rect.position + Vector2(24, 23), 16, Color("#fff0f8"))
	_draw_ranking_text(String(row.get("icon", "")), rect.position + Vector2(14, 29), 16, Color("#f05aa5"), 20, HORIZONTAL_ALIGNMENT_CENTER)
	var label_width := 178.0
	var value_x := 214.0
	if label_text.length() <= 4:
		label_width = 92.0
		value_x = 154.0
	_draw_ranking_text(label_text, rect.position + Vector2(50, 30), 17, Color("#4f3149"), label_width)
	_draw_ranking_text(_short_pause_text(String(row.get("value", "")), 16), rect.position + Vector2(value_x, 31), 23 if emphasized else 21, Color("#ee3e8f") if emphasized else Color("#f05aa5"), rect.size.x - value_x - 14.0, HORIZONTAL_ALIGNMENT_RIGHT)

func _draw_result_detail_panel(rect: Rect2, data: Dictionary) -> void:
	var completed := String(data.get("endType", "")) == "completed"
	var mental_breakdown := String(data.get("endType", "")) == "mental_breakdown"
	var detail_fill := Color(1, 1, 1, 0.94) if (mental_breakdown or completed) else Color(1, 1, 1, 0.88)
	var detail_border := Color("#ffd98a") if completed else (Color("#ffbddc") if mental_breakdown else Color("#d8cdf7"))
	_draw_ranking_panel(rect, detail_fill, detail_border, 20, 2, false)
	_draw_result_ribbon(rect.position + Vector2(68, -18), "配信詳細", Color("#ffb433") if completed else (Color("#ee5aa1") if mental_breakdown else Color("#a875e8")))
	var trouble_rect := Rect2(rect.position + Vector2(24, 42), Vector2(rect.size.x - 48, 120))
	var build_rect := Rect2(rect.position + Vector2(24, 182), Vector2(330, 140))
	var gift_rect := Rect2(rect.position + Vector2(374, 182), Vector2(330, 140))
	var ranking_rect := Rect2(rect.position + Vector2(24, 340), Vector2(330, 92))
	if completed:
		trouble_rect = Rect2(rect.position + Vector2(24, 42), Vector2(rect.size.x - 48, 156))
		build_rect = Rect2(rect.position + Vector2(24, 216), Vector2(rect.size.x - 48, 154))
		ranking_rect = Rect2(rect.position + Vector2(24, 388), Vector2(rect.size.x - 48, 72))
		_draw_result_trouble_card(trouble_rect, data)
		_draw_result_build_card(build_rect, data)
		_draw_result_ranking_card(ranking_rect, data)
		return
	if mental_breakdown:
		trouble_rect = Rect2(rect.position + Vector2(24, 42), Vector2(rect.size.x - 48, 156))
		build_rect = Rect2(rect.position + Vector2(24, 216), Vector2(rect.size.x - 48, 154))
		ranking_rect = Rect2(rect.position + Vector2(24, 388), Vector2(rect.size.x - 48, 72))
		_draw_result_trouble_card(trouble_rect, data)
		_draw_result_build_card(build_rect, data)
		_draw_result_ranking_card(ranking_rect, data)
		return
	ranking_rect = Rect2(rect.position + Vector2(24, 340), Vector2(rect.size.x - 48, 92))
	_draw_result_trouble_card(trouble_rect, data)
	_draw_result_build_card(build_rect, data)
	_draw_result_gift_card(gift_rect, data)
	_draw_result_ranking_card(ranking_rect, data)

func _draw_result_trouble_card(rect: Rect2, data: Dictionary) -> void:
	var completed := String(data.get("endType", "")) == "completed"
	var mental_breakdown := String(data.get("endType", "")) == "mental_breakdown"
	if mental_breakdown:
		_draw_ranking_panel(rect, Color("#fff8fc"), Color("#ff8fc2"), 16, 3, false)
		_draw_ranking_text("配信トラブル", rect.position + Vector2(18, 30), 18, Color("#e53e8c"), rect.size.x - 36)
		var culprit := String(data.get("culpritInstructionComment", "なし"))
		var has_culprit := culprit != "" and culprit != "なし" and culprit != "縺ｪ縺・"
		var reason := String(data.get("deathReasonText", "メンタル崩壊"))
		_draw_ranking_text("終了理由", rect.position + Vector2(20, 58), 13, Color("#b24488"), 82)
		_draw_ranking_text(_short_pause_text(reason, 52), rect.position + Vector2(94, 59), 16, Color("#d92f7e"), rect.size.x - 114)
		var culprit_rect := Rect2(rect.position + Vector2(20, 76), Vector2(rect.size.x - 40, 30))
		_draw_ranking_panel(culprit_rect, Color("#fff0f8") if has_culprit else Color(1, 1, 1, 0.65), Color("#ffbddc"), 12, 1, false)
		_draw_ranking_text("戦犯指示コメ", culprit_rect.position + Vector2(12, 21), 13, Color("#b24488"), 104)
		_draw_ranking_text(_short_pause_text(culprit, 24), culprit_rect.position + Vector2(126, 22), 15, Color("#d92f7e") if has_culprit else Color("#7b6475"), culprit_rect.size.x - 138)
		_draw_ranking_text("最後の一撃: %s" % String(data.get("finalBlowText", data.get("lastDeathSource", "接触"))), rect.position + Vector2(20, 124), 14, Color("#4f3149"), rect.size.x - 40)
		if bool(data.get("bossSummoned", false)):
			var boss_result: String = "撃破" if bool(data.get("bossDefeated", false)) else ("撤退" if String(data.get("bossResult", "")) == "retreated" else "出現中")
			_draw_ranking_text("出現ボス: %s / %s" % [String(data.get("bossName", "ボス")), boss_result], rect.position + Vector2(20, 144), 13, Color("#8d46b5"), rect.size.x - 40)
		return
	var panel_fill := Color("#fffdf4") if completed else (Color("#fff8fc") if mental_breakdown else Color(1, 1, 1, 0.92))
	var panel_border := Color("#ffd98a") if completed else (Color("#ff9aca") if mental_breakdown else Color("#ead7ff"))
	var title_color := Color("#c97813") if completed else (Color("#e53e8c") if mental_breakdown else Color("#7a56c8"))
	_draw_ranking_panel(rect, panel_fill, panel_border, 14, 2, false)
	_draw_ranking_text("配信ハイライト" if completed else "配信トラブル", rect.position + Vector2(18, 28), 17, title_color, rect.size.x - 36)
	var rows: Array = []
	if completed:
		rows = [
			{"text": "完走結果：最後まで配信を走り切った！", "color": Color("#7a4b10")},
			{"text": "ラスト指示コメ：%s" % String(data.get("lastInstructionComment", "なし")), "color": Color("#4f3149")},
			{"text": "コメント欄：完走おめ！で大盛り上がり", "color": Color("#4f3149")},
			{"text": "完走ポイント：最後までメンタルを残して完走", "color": Color("#d77b10")}
		]
	elif mental_breakdown:
		var culprit := String(data.get("culpritInstructionComment", "なし"))
		rows = [
			{"text": "終了理由：%s" % String(data.get("deathReasonText", "メンタル崩壊")), "color": Color("#d92f7e")},
			{"text": "戦犯指示コメ：%s" % culprit, "color": Color("#b24488") if culprit != "なし" else Color("#4f3149")}
		]
		var note := String(data.get("troubleNote", ""))
		if note != "":
			rows.append({"text": "補足：%s" % note, "color": Color("#7b6475")})
		rows.append({"text": "最後の一撃：%s" % String(data.get("finalBlowText", data.get("lastDeathSource", "接触"))), "color": Color("#4f3149")})
	else:
		rows = [
			{"text": "戦犯指示コメ：%s" % String(data.get("culpritInstructionComment", "なし")), "color": Color("#4f3149")},
			{"text": "死因：%s" % String(data.get("deathText", "")), "color": Color("#4f3149")},
			{"text": "最後の一撃：%s" % String(data.get("lastDeathSource", "接触")), "color": Color("#4f3149")}
		]
	if bool(data.get("bossSummoned", false)):
		var boss_result: String = "撃破" if bool(data.get("bossDefeated", false)) else ("撤退" if String(data.get("bossResult", "")) == "retreated" else "出現")
		var reward_text: String = " / +%s人" % _result_number(int(data.get("bossRewardViewer", 0))) if int(data.get("bossRewardViewer", 0)) > 0 else ""
		var boss_label := "挑戦ボス" if completed else ("出現ボス" if mental_breakdown else "ボス%s" % boss_result)
		rows.append({"text": "%s：%s%s" % [boss_label, String(data.get("bossName", "ボス")), reward_text], "color": Color("#8d46b5")})
	for index in range(rows.size()):
		var row: Dictionary = rows[index] as Dictionary
		var y: float = 52.0 + float(index) * (18.0 if rows.size() >= 5 else (20.0 if rows.size() >= 4 else 24.0))
		_draw_ranking_text(_short_pause_text(String(row.get("text", "")), 66), rect.position + Vector2(18, y), 14 if rows.size() >= 5 else 15, row.get("color", Color("#4f3149")) as Color, rect.size.x - 36)

func _draw_result_build_card(rect: Rect2, data: Dictionary) -> void:
	var completed := String(data.get("endType", "")) == "completed"
	_draw_ranking_panel(rect, Color("#fffdf4") if completed else Color(1, 1, 1, 0.92), Color("#ffd98a") if completed else Color("#d8cdf7"), 14, 2, false)
	_draw_ranking_text("最終ビルド", rect.position + Vector2(18, 28), 17, Color("#c97813") if completed else Color("#7a56c8"), rect.size.x - 36)
	var compact := rect.size.x < 300.0
	var label_width := 42.0 if compact else 54.0
	var slot_start_x := 60.0 if compact else 76.0
	var slot_size := 30.0 if compact else 42.0
	var slot_step := 35.0 if compact else 52.0
	_draw_ranking_text("武器", rect.position + Vector2(18, 64), 16, Color("#4f3149"), label_width)
	_draw_result_equipment_slots(data.get("weapons", []), weapons, rect.position + Vector2(slot_start_x, 42), 5, slot_size, slot_step)
	_draw_ranking_text("アクセ", rect.position + Vector2(18, 112), 16, Color("#4f3149"), label_width)
	_draw_result_equipment_slots(data.get("accessories", []), gifts, rect.position + Vector2(slot_start_x, 98), 5, slot_size, slot_step)

func _draw_result_gift_card(rect: Rect2, data: Dictionary) -> void:
	_draw_ranking_panel(rect, Color(1, 1, 1, 0.92), Color("#ffd2e5"), 14, 2, false)
	_draw_ranking_text("取得ギフト", rect.position + Vector2(18, 28), 17, Color("#f05aa5"), rect.size.x - 36)
	var names: Array = data.get("giftList", []) as Array
	if names.is_empty():
		_draw_ranking_text("なし", rect.position + Vector2(18, rect.size.y * 0.58), 18, Color("#7f7480"), rect.size.x - 36, HORIZONTAL_ALIGNMENT_CENTER)
		return
	var compact := rect.size.x < 260.0
	if compact:
		var compact_slot_size := 36.0
		var compact_step_x := 44.0
		var compact_step_y := 42.0
		var compact_columns := 4
		var max_compact_icons := mini(names.size(), 8)
		for index in range(max_compact_icons):
			var slot := Rect2(rect.position + Vector2(18 + float(index % compact_columns) * compact_step_x, 44 + float(index / compact_columns) * compact_step_y), Vector2(compact_slot_size, compact_slot_size))
			_draw_ranking_panel(slot, Color("#fff8fc"), Color("#ffd2e5"), 9, 2, false)
			var gift_name := String(names[index])
			var icon := _result_gift_icon_for_name(gift_name)
			if icon != null:
				draw_texture_rect(icon, slot.grow(-4), false)
			else:
				_draw_result_present_icon(slot.grow(-7))
		return
	var slot_size := 42.0 if compact else 58.0
	var slot_step := 52.0 if compact else 76.0
	var max_icons := mini(names.size(), 4 if not compact else 3)
	for index in range(max_icons):
		var slot := Rect2(rect.position + Vector2(18 + float(index) * slot_step, 50), Vector2(slot_size, slot_size))
		_draw_ranking_panel(slot, Color("#fff8fc"), Color("#ffd2e5"), 10, 2, false)
		var gift_name := String(names[index])
		var icon := _result_gift_icon_for_name(gift_name)
		if icon != null:
			draw_texture_rect(icon, slot.grow(-5), false)
		else:
			_draw_result_present_icon(slot.grow(-8))
		if rect.size.y >= 120.0:
			_draw_ranking_text("x1", slot.position + Vector2(0, slot.size.y + 20.0), 13, Color("#4f3149"), slot.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	if rect.size.y >= 128.0:
		_draw_ranking_text(_short_pause_text(String(data.get("giftSummary", "")), 24), rect.position + Vector2(18, 132), 14, Color("#6b4a63"), rect.size.x - 36)

func _result_gift_icon_for_name(name: String) -> Texture2D:
	var path := _result_gift_icon_path_for_name(name)
	if path == "":
		return null
	return _load_equipment_icon(path)

func _result_gift_icon_path_for_name(name: String) -> String:
	var normalized := name.strip_edges()
	var level_index := normalized.find(" Lv")
	if level_index >= 0:
		normalized = normalized.substr(0, level_index).strip_edges()
	if normalized.ends_with(" 進化"):
		normalized = normalized.substr(0, normalized.length() - " 進化".length()).strip_edges()
	for source in [gifts, weapons]:
		for item_value in source:
			var item: Dictionary = item_value as Dictionary
			if String(item.get("displayName", "")) == normalized or String(item.get("id", "")) == normalized:
				return String(item.get("iconPath", ""))
	return ""

func _draw_result_present_icon(rect: Rect2) -> void:
	var box := Rect2(rect.position + Vector2(rect.size.x * 0.18, rect.size.y * 0.34), Vector2(rect.size.x * 0.64, rect.size.y * 0.48))
	var lid := Rect2(rect.position + Vector2(rect.size.x * 0.12, rect.size.y * 0.24), Vector2(rect.size.x * 0.76, rect.size.y * 0.20))
	_draw_ranking_panel(lid, Color("#ff75b1"), Color("#d93e86"), 4, 1, false)
	_draw_ranking_panel(box, Color("#ffd7e8"), Color("#d93e86"), 5, 1, false)
	draw_rect(Rect2(box.position + Vector2(box.size.x * 0.43, 0), Vector2(box.size.x * 0.14, box.size.y)), Color("#ff5aa5"), true)
	draw_rect(Rect2(lid.position + Vector2(0, lid.size.y * 0.38), Vector2(lid.size.x, lid.size.y * 0.24)), Color(1, 1, 1, 0.42), true)

func _draw_result_ranking_card(rect: Rect2, data: Dictionary) -> void:
	_draw_ranking_panel(rect, Color("#fffaf0"), Color("#ffd98a"), 14, 2, false)
	var text: String = String(data.get("rankingText", ""))
	if text == "":
		text = "ランキング対象外"
	var title := "ランキング登録！" if text.contains("ランキング登録") else ("ランキング対象外" if text.contains("対象外") else "ランキング結果")
	var body := text
	body = body.replace("ランキング登録：", "")
	body = body.replace("配信リレーランキング登録：", "")
	body = body.replace("ランキング対象外：", "")
	var compact := rect.size.y < 90.0
	_draw_ranking_text(title, rect.position + Vector2(18, 29 if compact else 31), 16 if compact else 17, Color("#d77b10"), rect.size.x - 36)
	var first_line := body.strip_edges()
	var second_line := ""
	var separator_index := first_line.find(" / ")
	if separator_index >= 0:
		second_line = first_line.substr(separator_index + 3).strip_edges()
		first_line = first_line.substr(0, separator_index).strip_edges()
	_draw_ranking_text(_short_pause_text(first_line, 24), rect.position + Vector2(18, 56 if compact else 63), 17 if compact else 19, Color("#d77b10"), rect.size.x - 36)
	if second_line != "" and (not compact or rect.size.y >= 86.0):
		_draw_ranking_text(_short_pause_text(second_line, 28), rect.position + Vector2(18, 76 if compact else 84), 11 if compact else 13, Color("#6b4a2f"), rect.size.x - 36)

func _draw_result_equipment_slots(items_value: Variant, source_data: Array, start: Vector2, slot_count: int, slot_size: float = 38.0, slot_step: float = 46.0) -> void:
	var items: Array = []
	if items_value is Array:
		items = items_value as Array
	for index in range(slot_count):
		var slot := Rect2(start + Vector2(float(index) * slot_step, 0), Vector2(slot_size, slot_size))
		var evolved := false
		if index < items.size() and items[index] is Dictionary:
			evolved = EquipmentSystem.is_evolved_entry(items[index] as Dictionary)
		_draw_ranking_panel(slot, Color("#fff9ec") if evolved else Color("#fbfbff"), Color("#ffd15a") if evolved else Color("#d8cdf7"), 6, 2 if evolved else 1, false)
		if index >= items.size() or not (items[index] is Dictionary):
			continue
		var item: Dictionary = items[index] as Dictionary
		var data: Dictionary = _find_equipment_icon_data(source_data, String(item.get("id", "")))
		evolved = evolved or bool(data.get("isEvolved", false))
		if evolved:
			_draw_ranking_panel(slot.grow(2.0), Color(1.0, 0.78, 0.16, 0.10), Color("#ffd15a"), 7, 2, false)
		var icon: Texture2D = _load_equipment_icon(_equipment_icon_path_for_item(item, source_data))
		if icon != null:
			draw_texture_rect(icon, slot.grow(-3), false)
		else:
			_draw_ranking_text(_short_pause_text(String(item.get("displayName", item.get("id", ""))), 2), slot.position + Vector2(0, slot.size.y * 0.66), 12, Color("#7a56c8"), slot.size.x, HORIZONTAL_ALIGNMENT_CENTER)
		if evolved:
			var label_rect := Rect2(slot.position + Vector2(1, -10), Vector2(slot.size.x - 2, 14))
			_draw_ranking_panel(label_rect, Color("#ffd15a"), Color(1, 1, 1, 0), 4, 0, false)
			_draw_ranking_text("進化", slot.position + Vector2(0, 1), 9, Color("#7a3f00"), slot.size.x, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_result_buttons(layout: Dictionary) -> void:
	var mental_breakdown := String(last_result_data.get("endType", "")) == "mental_breakdown"
	if mental_breakdown:
		_draw_ranking_panel((layout["retryButton"] as Rect2).grow(8), Color(1.0, 0.18, 0.56, 0.14), Color(1, 1, 1, 0), 22, 0, false)
	_draw_result_button(layout["retryButton"] as Rect2, "▶ もう一回", Color("#ff3f9b") if mental_breakdown else Color("#ff5aa5"), Color.WHITE, "retry")
	_draw_result_button(layout["rankingButton"] as Rect2, "ランキング", Color("#f8f2ff"), Color("#7a56c8"), "ranking")
	_draw_result_button(layout["titleButton"] as Rect2, "タイトルへ", Color("#e8f7ff"), Color("#2587b8"), "title")

func _draw_result_button(rect: Rect2, label: String, fill: Color, text_color: Color, button_id: String) -> void:
	if result_hover_button == button_id:
		_draw_ranking_panel(rect.grow(5), Color(1, 1, 1, 0.72), Color("#ff9cc9"), 18, 3, false)
	_draw_ranking_panel(rect, fill, Color("#ead7e9"), 14, 2, false)
	var font_size := 17
	var text_baseline_y := rect.position.y + rect.size.y * 0.5 + float(font_size) * 0.38
	_draw_ranking_text(label, Vector2(rect.position.x, text_baseline_y), font_size, text_color, rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_result_ribbon(pos: Vector2, text: String, color: Color) -> void:
	var rect := Rect2(pos, Vector2(200, 32))
	_draw_ranking_panel(rect, color, Color(1, 1, 1, 0), 4, 0, false)
	_draw_ranking_text(text, rect.position + Vector2(0, 23), 16, Color.WHITE, rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_result_small_badge(pos: Vector2, text: String, color: Color) -> void:
	var rect := Rect2(pos, Vector2(70, 70))
	_draw_ranking_panel(rect, Color(color.r, color.g, color.b, 0.16), color, 16, 3, false)
	_draw_ranking_text(text, rect.position + Vector2(0, 42), 22, color, rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_result_mental_breakdown_character(rect: Rect2, data: Dictionary) -> void:
	var breakdown_path := _mental_breakdown_result_image_path(String(data.get("characterId", "")))
	if breakdown_path == "":
		return
	var texture: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, breakdown_path)
	if texture == null:
		return
	var clock := float(Time.get_ticks_msec()) / 1000.0
	var sway := Vector2(sin(clock * 1.7) * 2.0, sin(clock * 2.1) * 2.5)
	var area_rect := rect.grow(-6.0)
	_draw_ranking_panel(area_rect, Color(1.0, 0.76, 0.90, 0.18), Color(1, 1, 1, 0), 36, 0, false)
	_draw_ranking_panel(area_rect.grow(-18.0), Color(0.68, 0.02, 0.28, 0.08), Color(1, 1, 1, 0), 28, 0, false)
	for i in range(5):
		var line_y := rect.position.y + 70.0 + float(i) * 74.0 + sin(clock * 1.5 + float(i)) * 6.0
		draw_line(Vector2(rect.position.x + 28.0, line_y), Vector2(rect.end.x - 24.0, line_y), Color(1.0, 0.18, 0.55, 0.10), 1.2, true)
	var glow_rect := Rect2(rect.position + Vector2(24, 72), Vector2(rect.size.x - 48.0, rect.size.y * 0.64))
	_draw_ranking_panel(glow_rect.grow(18.0), Color(0.94, 0.05, 0.40, 0.11), Color(1, 1, 1, 0), 44, 0, false)
	_draw_ranking_panel(glow_rect.grow(6.0), Color(0.52, 0.03, 0.32, 0.10), Color(1, 1, 1, 0), 38, 0, false)
	_draw_result_broken_heart(rect.position + Vector2(38, 98), 20.0, 0.78)
	_draw_result_broken_heart(rect.position + Vector2(rect.size.x - 40.0, rect.size.y - 132.0), 15.0, 0.48)
	var container := Rect2(rect.position + Vector2(0, 24) + sway, rect.size - Vector2(0, 44))
	draw_texture_rect(texture, _fit_texture_rect(container, texture.get_size()), false)

func _draw_result_stream_complete_character(rect: Rect2, data: Dictionary) -> void:
	var character_id := String(data.get("characterId", ""))
	var image_path := _stream_complete_result_image_path(character_id)
	if image_path == "":
		return
	var texture: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, image_path)
	if texture == null:
		return
	var clock := float(Time.get_ticks_msec()) / 1000.0
	var sway := Vector2(0.0, sin(clock * 2.0) * 3.0)
	var area_rect := rect.grow(-6.0)
	_draw_ranking_panel(area_rect, Color(1.0, 0.78, 0.18, 0.14), Color(1, 1, 1, 0), 36, 0, false)
	_draw_ranking_panel(area_rect.grow(-18.0), Color(1.0, 0.98, 0.88, 0.28), Color("#ffe08a"), 30, 2, false)
	var glow_rect := Rect2(rect.position + Vector2(18, 74), Vector2(rect.size.x - 36.0, rect.size.y * 0.66))
	_draw_ranking_panel(glow_rect.grow(24.0), Color(1.0, 0.70, 0.16, 0.13), Color(1, 1, 1, 0), 48, 0, false)
	_draw_ranking_panel(glow_rect.grow(8.0), Color(1.0, 0.40, 0.66, 0.07), Color(1, 1, 1, 0), 38, 0, false)
	for i in range(10):
		var color := Color(1.0, 0.74, 0.18, 0.42) if i % 2 == 0 else Color(1.0, 0.38, 0.70, 0.34)
		var pos := rect.position + Vector2(28.0 + fmod(float(i) * 73.0, rect.size.x - 56.0), 44.0 + fmod(float(i) * 51.0 - clock * 12.0, rect.size.y - 90.0))
		if i % 3 == 0:
			draw_rect(Rect2(pos, Vector2(14, 6)), color, true)
		else:
			_draw_stream_start_sparkle(pos, 6.0 + float(i % 2) * 3.0, color)
	for i in range(4):
		var symbol := "★" if i % 2 == 0 else "♥"
		var symbol_color := Color(1.0, 0.68, 0.08, 0.46) if symbol == "★" else Color(1.0, 0.34, 0.60, 0.38)
		var pos := rect.position + Vector2(20.0 + float(i) * 84.0, 78.0 + sin(clock * 1.6 + float(i)) * 5.0)
		_draw_ranking_text(symbol, pos, 22, symbol_color, 34, HORIZONTAL_ALIGNMENT_CENTER)
	var offset := Vector2(-44.0, 38.0)
	var expand := Vector2(88.0, -48.0)
	if character_id == "superchat_chan" or character_id == "supana":
		offset = Vector2(-36.0, 38.0)
		expand = Vector2(72.0, -46.0)
	elif character_id == "maro_chan" or character_id == "maron":
		offset = Vector2(-68.0, 38.0)
		expand = Vector2(136.0, -48.0)
	var container := Rect2(rect.position + offset + sway, rect.size + expand)
	draw_texture_rect(texture, _fit_texture_rect(container, texture.get_size()), false)

func _draw_result_character_bust(rect: Rect2, character_id: String, character_name: String, mental_breakdown: bool = false) -> void:
	if mental_breakdown:
		var breakdown_path := _mental_breakdown_result_image_path(character_id)
		if breakdown_path != "":
			var breakdown_tex: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, breakdown_path)
			if breakdown_tex != null:
				draw_texture_rect(breakdown_tex, _fit_texture_rect(rect, breakdown_tex.get_size()), false)
				return
	var character: Dictionary = CharacterSystemScript.find_character(characters, character_id)
	var tex: Texture2D = CharacterSystemScript.texture_from_cache(character_sprite_cache, String(character.get("sprite", "")))
	if tex != null:
		draw_texture_rect(tex, _fit_texture_rect(rect, tex.get_size()), false)
	else:
		draw_circle(rect.get_center(), 44, Color("#fff0f8"))
		_draw_ranking_text(_ranking_avatar_text(character_name), rect.position + Vector2(0, rect.size.y * 0.55), 20, Color("#f05aa5"), rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)

func _mental_breakdown_result_image_path(character_id: String) -> String:
	if character_id == "ban_chan" or character_id == "banri":
		return MENTAL_BREAKDOWN_BANRI_IMAGE
	if character_id == "superchat_chan" or character_id == "supana":
		return MENTAL_BREAKDOWN_SUPANA_IMAGE
	if character_id == "maro_chan" or character_id == "maron":
		return MENTAL_BREAKDOWN_MARON_IMAGE
	return ""

func _stream_complete_result_image_path(character_id: String) -> String:
	if character_id == "ban_chan" or character_id == "banri":
		return STREAM_COMPLETE_BANRI_IMAGE
	if character_id == "superchat_chan" or character_id == "supana":
		return STREAM_COMPLETE_SUPANA_IMAGE
	if character_id == "maro_chan" or character_id == "maron":
		return STREAM_COMPLETE_MARON_IMAGE
	return ""

func _draw_result_broken_heart(center: Vector2, size: float, alpha: float = 1.0) -> void:
	var color := Color(0.94, 0.16, 0.40, alpha)
	var shine := Color(1.0, 0.72, 0.84, alpha * 0.7)
	draw_circle(center + Vector2(-size * 0.28, -size * 0.12), size * 0.28, color)
	draw_circle(center + Vector2(size * 0.28, -size * 0.12), size * 0.28, color)
	var points := PackedVector2Array([
		center + Vector2(-size * 0.58, -size * 0.06),
		center + Vector2(size * 0.58, -size * 0.06),
		center + Vector2(0.0, size * 0.62)
	])
	draw_colored_polygon(points, color)
	draw_line(center + Vector2(-size * 0.04, -size * 0.34), center + Vector2(size * 0.10, -size * 0.08), Color.WHITE, 2.2, true)
	draw_line(center + Vector2(size * 0.10, -size * 0.08), center + Vector2(-size * 0.02, size * 0.18), Color.WHITE, 2.2, true)
	draw_line(center + Vector2(-size * 0.02, size * 0.18), center + Vector2(size * 0.12, size * 0.48), Color.WHITE, 2.2, true)
	draw_circle(center + Vector2(-size * 0.28, -size * 0.20), size * 0.08, shine)

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
	_draw_character_select_header(layout["header"] as Rect2, page_count)
	_draw_character_select_list_panel(layout["listPanel"] as Rect2, page)
	_draw_character_select_detail_panel(layout["detailPanel"] as Rect2)
	_draw_character_select_footer(layout, page, page_count)

func _character_select_layout() -> Dictionary:
	return {
		"header": Rect2(76, 16, 1448, 72),
		"listPanel": Rect2(76, 112, 880, 692),
		"detailPanel": Rect2(982, 112, 542, 692),
		"footer": Rect2(76, 828, 1448, 52),
		"backButton": Rect2(108, 838, 176, 34),
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

func _draw_character_select_header(rect: Rect2, page_count: int) -> void:
	_draw_ranking_panel(rect, Color(1, 1, 1, 0.95), Color("#ead7e9"), 22, 2, true)
	var header_icon: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, CHARACTER_SELECT_HEADER_ICON)
	if header_icon != null:
		var icon_rect := Rect2(rect.position + Vector2(18, 11), Vector2(58, 50))
		draw_texture_rect(header_icon, _fit_texture_rect(icon_rect, header_icon.get_size()), false, Color(1, 1, 1, 0.98))
	else:
		draw_circle(rect.position + Vector2(46, 36), 22, Color("#fff3fb"))
		_draw_ranking_text("配", rect.position + Vector2(35, 47), 25, Color("#f05aa5"), 28, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_ranking_text("配信者を選択", rect.position + Vector2(88, 47), 34, Color("#4f3149"), 360)
	var guide := "←→：選択　Enter：決定　Esc：戻る"
	if page_count > 1:
		guide = "←→：選択　A/D：ページ　Enter：決定　Esc：戻る"
	_draw_ranking_text(guide, rect.position + Vector2(682, 45), 20, Color("#6b4a63"), 710, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_character_select_list_panel(panel: Rect2, page: int) -> void:
	_draw_ranking_panel(panel, Color(1, 1, 1, 0.93), Color("#ead7e9"), 24, 2, true)
	_draw_ranking_text("配信者一覧", panel.position + Vector2(30, 46), 28, Color("#7a3fb0"), 360)
	var start: int = page * CharacterSystemScript.SELECT_PAGE_SIZE
	var visible_count: int = CharacterSystemScript.selection_visible_count(characters.size())
	for local_index in range(CharacterSystemScript.SELECT_PAGE_SIZE):
		var rect: Rect2 = _character_select_card_rect(local_index)
		var index: int = start + local_index
		if index < characters.size():
			_draw_character_select_card(rect, index)
		elif index < visible_count:
			if _character_select_placeholder_status(index) == "locked":
				_draw_character_select_locked_card(rect, index, character_select_focus_area == PRE_RUN_SELECT_FOCUS_ITEMS and index == selected_character_index)
			else:
				_draw_character_select_coming_card(rect, index, character_select_focus_area == PRE_RUN_SELECT_FOCUS_ITEMS and index == selected_character_index)

func _draw_character_select_card(rect: Rect2, index: int) -> void:
	var character: Dictionary = characters[index] as Dictionary
	var view: Dictionary = CharacterSystemScript.selection_card_view(character, weapons)
	var selected: bool = character_select_focus_area == PRE_RUN_SELECT_FOCUS_ITEMS and index == selected_character_index
	var selectable: bool = bool(view.get("isSelectable", true))
	var accent: Color = view.get("accent", Color("#ff4f92")) as Color
	var accent2: Color = view.get("accent2", Color("#7a56c8")) as Color
	var soft_fill: Color = view.get("softFill", Color("#fff2fa")) as Color
	var border: Color = accent if selected else Color(accent.r, accent.g, accent.b, 0.34)
	var fill: Color = Color(1, 1, 1, 0.98)
	var text_color := Color("#4f3149")
	if not selectable:
		border = Color("#cfc8d6") if not selected else Color("#a887d8")
		fill = Color("#f4f0f5")
		text_color = Color("#7f7480")
	if selected:
		fill = Color(soft_fill.r, soft_fill.g, soft_fill.b, 0.96) if selectable else Color("#f4eff7")
		_draw_ranking_panel(rect.grow(8), Color(accent.r, accent.g, accent.b, 0.20), Color(1, 1, 1, 0), 24, 0, false)
		_draw_ranking_panel(rect.grow(3), Color(1, 1, 1, 0), Color(accent.r, accent.g, accent.b, 0.42), 22, 2, false)
	_draw_ranking_panel(rect, fill, border, 20, 5 if selected else 2, false)
	_draw_ranking_text("[%d]" % (index + 1), rect.position + Vector2(16, 31), 18, accent if selectable else Color("#8f8793"), 42)
	_draw_ranking_text(_short_pause_text(String(view.get("displayName", "配信者")), 9), rect.position + Vector2(58, 35), 23, text_color, rect.size.x - 76)
	var status_rect := Rect2(rect.position + Vector2(rect.size.x - 92, 12), Vector2(74, 26))
	if selected:
		_draw_ranking_panel(status_rect, Color(accent.r, accent.g, accent.b, 0.88), accent, 13, 1, false)
		_draw_ranking_text("★ 選択中", status_rect.position + Vector2(4, 19), 13, Color.WHITE, status_rect.size.x - 8, HORIZONTAL_ALIGNMENT_CENTER)
	else:
		_draw_character_select_tag(status_rect, String(view.get("statusText", "使用可能")), Color(soft_fill.r, soft_fill.g, soft_fill.b, 0.90), accent)
	var image_rect := Rect2(rect.position + Vector2(18, 62), Vector2(rect.size.x - 36, 136))
	if selectable:
		var tex: Texture2D = CharacterSystemScript.texture_from_cache(character_sprite_cache, String(view.get("spritePath", "")))
		if tex != null:
			_draw_texture_cover_rect(tex, image_rect, Vector2(0.5, 0.10), 1.24)
	else:
		draw_circle(image_rect.get_center() + Vector2(0, -6), 44, Color("#dfd8e3"))
		_draw_ranking_text("LOCK", image_rect.position + Vector2(0, 84), 24, Color("#8f8793"), image_rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_character_select_tag_row(Rect2(rect.position + Vector2(18, 198), Vector2(rect.size.x - 36, 30)), view.get("cardTags", []) as Array, accent, 2, 13)
	_draw_character_select_weapon_line(Rect2(rect.position + Vector2(18, 238), Vector2(rect.size.x - 36, 30)), view, "weaponName", "weaponIconPath", accent)

func _character_select_placeholder_status(index: int) -> String:
	var local_index := index % CharacterSystemScript.SELECT_PAGE_SIZE
	if local_index < CharacterSystemScript.SELECT_PAGE_SIZE - 1:
		return "locked"
	return "coming_soon"

func _character_select_placeholder_unlock_text(index: int) -> String:
	if index == 3:
		return "雑談枠をクリア"
	if index == 4:
		return "ゲーム実況枠をクリア"
	return "今後のアップデートで追加予定"

func _draw_character_select_locked_card(rect: Rect2, index: int, selected: bool) -> void:
	var border := Color("#a887d8") if selected else Color("#d8d0dc")
	var fill := Color("#f5f0f6") if selected else Color("#faf7fb")
	if selected:
		_draw_ranking_panel(rect.grow(7), Color(0.50, 0.38, 0.76, 0.16), Color(1, 1, 1, 0), 24, 0, false)
		_draw_ranking_panel(rect.grow(3), Color(1, 1, 1, 0), Color(0.50, 0.38, 0.76, 0.34), 22, 2, false)
	_draw_ranking_panel(rect, fill, border, 20, 4 if selected else 2, false)
	_draw_ranking_text("[%d]" % (index + 1), rect.position + Vector2(16, 31), 18, Color("#8f8793"), 42)
	if selected:
		var selected_rect := Rect2(rect.position + Vector2(rect.size.x - 92, 12), Vector2(74, 26))
		_draw_ranking_panel(selected_rect, Color("#a887d8"), Color("#8f70c8"), 13, 1, false)
		_draw_ranking_text("★ 選択中", selected_rect.position + Vector2(4, 19), 13, Color.WHITE, selected_rect.size.x - 8, HORIZONTAL_ALIGNMENT_CENTER)
	var image_rect := Rect2(rect.position + Vector2(34, 52), Vector2(rect.size.x - 68, 140))
	var mystery_center := image_rect.get_center() + Vector2(0, -8)
	draw_circle(mystery_center, 54, Color("#eee7f1"))
	draw_circle(mystery_center, 54, Color("#d8d0dc"), false, 3.0)
	_draw_ranking_text("？？？", Vector2(image_rect.position.x, mystery_center.y + 10.0), 28, Color("#8f8793"), image_rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_character_select_tag(Rect2(rect.position + Vector2(52, 198), Vector2(rect.size.x - 104, 30)), "未開放", Color("#f0eaf3"), Color("#8f70c8"))
	_draw_ranking_text("解放条件：%s" % _character_select_placeholder_unlock_text(index), rect.position + Vector2(18, 254), 14, Color("#8f8793"), rect.size.x - 36, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_character_select_coming_card(rect: Rect2, index: int, selected: bool) -> void:
	var border := Color("#cba3d9") if selected else Color("#e0d7e2")
	var fill := Color("#f7f0f9") if selected else Color("#fbf8fc")
	if selected:
		_draw_ranking_panel(rect.grow(7), Color(0.68, 0.48, 0.78, 0.16), Color(1, 1, 1, 0), 24, 0, false)
		_draw_ranking_panel(rect.grow(3), Color(1, 1, 1, 0), Color(0.68, 0.48, 0.78, 0.34), 22, 2, false)
	_draw_ranking_panel(rect, fill, border, 20, 4 if selected else 2, false)
	_draw_ranking_text("[%d]" % (index + 1), rect.position + Vector2(16, 31), 18, Color("#a294a3"), 42)
	if selected:
		var selected_rect := Rect2(rect.position + Vector2(rect.size.x - 92, 12), Vector2(74, 26))
		_draw_ranking_panel(selected_rect, Color("#c08adb"), Color("#a46fc3"), 13, 1, false)
		_draw_ranking_text("★ 選択中", selected_rect.position + Vector2(4, 19), 13, Color.WHITE, selected_rect.size.x - 8, HORIZONTAL_ALIGNMENT_CENTER)
	var preparing_center := rect.position + rect.size * 0.5 + Vector2(0, -36)
	draw_circle(preparing_center, 48, Color("#f1eaf2"))
	draw_circle(preparing_center, 48, Color("#ddd2e0"), false, 2.0)
	_draw_ranking_text("準備中", Vector2(rect.position.x, preparing_center.y + 9.0), 24, Color("#8d7b93"), rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_ranking_text("今後のアップデートで追加予定", rect.position + Vector2(20, 204), 15, Color("#8f8793"), rect.size.x - 40, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_character_select_detail_panel(panel: Rect2) -> void:
	_draw_ranking_panel(panel, Color(1, 1, 1, 0.93), Color("#ead7e9"), 24, 2, true)
	_draw_ranking_text("選択中キャラ詳細", panel.position + Vector2(30, 46), 28, Color("#ff5aa5"), panel.size.x - 60)
	if characters.is_empty():
		_draw_ranking_text("配信者データがありません。", panel.position + Vector2(30, 300), 22, Color("#6b4a63"), panel.size.x - 60, HORIZONTAL_ALIGNMENT_CENTER)
		return
	if selected_character_index < 0 or selected_character_index >= characters.size():
		if _character_select_placeholder_status(selected_character_index) == "locked":
			_draw_character_select_locked_detail(panel, selected_character_index)
		else:
			_draw_character_select_preparing_detail(panel)
		return
	var index: int = selected_character_index
	var character: Dictionary = characters[index] as Dictionary
	var view: Dictionary = CharacterSystemScript.selection_card_view(character, weapons)
	var selectable: bool = bool(view.get("isSelectable", true))
	var accent: Color = view.get("accent", Color("#ff4f92")) as Color
	var accent2: Color = view.get("accent2", Color("#7a56c8")) as Color
	var soft_fill: Color = view.get("softFill", Color("#fff2fa")) as Color
	var status_rect := Rect2(panel.position + Vector2(panel.size.x - 132, 20), Vector2(102, 30))
	_draw_character_select_tag(status_rect, String(view.get("statusText", "使用可能")), Color(soft_fill.r, soft_fill.g, soft_fill.b, 0.92), accent)
	_draw_ranking_text(String(view.get("displayName", "配信者")), panel.position + Vector2(30, 88), 32, accent if selectable else Color("#7f7480"), panel.size.x - 60, HORIZONTAL_ALIGNMENT_CENTER)
	var image_panel := Rect2(panel.position + Vector2(28, 104), Vector2(panel.size.x - 56, 426))
	_draw_ranking_panel(image_panel, Color(soft_fill.r, soft_fill.g, soft_fill.b, 0.66), Color(accent.r, accent.g, accent.b, 0.32), 24, 2, false)
	var image_rect := Rect2(image_panel.position + Vector2(10, 8), image_panel.size - Vector2(20, 18))
	if selectable:
		var tex: Texture2D = CharacterSystemScript.texture_from_cache(character_sprite_cache, String(view.get("spritePath", "")))
		if tex != null:
			draw_texture_rect(tex, _fit_texture_rect(image_rect, tex.get_size()), false)
	else:
		draw_circle(image_rect.get_center() + Vector2(0, -10), 68, Color("#dfd8e3"))
		_draw_ranking_text("LOCK", image_rect.position + Vector2(0, 148), 30, Color("#8f8793"), image_rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	if not selectable:
		var lock_rect := Rect2(panel.position + Vector2(28, 390), Vector2(panel.size.x - 56, 170))
		_draw_ranking_panel(lock_rect, Color("#fbf8fc"), Color("#e0d7e2"), 16, 2, false)
		_draw_multiline_text_item({"pos": lock_rect.position + Vector2(22, 48), "text": "この配信者はまだ開放されていません。\n\n解放条件：\n%s" % String(view.get("unlockConditionText", "？？？")), "width": int(lock_rect.size.x - 44), "size": 20, "color": Color("#6b4a63")})
		return
	_draw_character_select_weapon_highlight(Rect2(image_panel.position + Vector2(18, image_panel.size.y - 94), Vector2(image_panel.size.x - 36, 44)), view, accent, soft_fill, true)
	_draw_character_select_tag_row(Rect2(image_panel.position + Vector2(18, image_panel.size.y - 42), Vector2(image_panel.size.x - 36, 30)), view.get("detailTags", []) as Array, accent, 4, 13, true)
	_draw_character_select_detail_section(Rect2(panel.position + Vector2(30, 548), Vector2(panel.size.x - 60, 56)), "特性", "%s：%s" % [String(view.get("passiveName", "なし")), String(view.get("passiveDescription", ""))], accent2, Color("#fff8fc"), 14)
	_draw_character_select_detail_section(Rect2(panel.position + Vector2(30, 618), Vector2(panel.size.x - 60, 72)), "紹介", String(view.get("description", "")), accent, Color(1, 1, 1, 0.98), 15, -4.0)

func _draw_character_select_preparing_detail(panel: Rect2) -> void:
	var box := Rect2(panel.position + Vector2(34, 96), Vector2(panel.size.x - 68, 300))
	_draw_ranking_panel(box, Color("#fbf8fc"), Color("#e0d7e2"), 22, 2, false)
	draw_circle(box.get_center() + Vector2(0, -58), 58, Color("#f1eaf2"))
	draw_circle(box.get_center() + Vector2(0, -58), 58, Color("#ddd2e0"), false, 3.0)
	_draw_ranking_text("準備中の配信者", box.position + Vector2(0, 190), 29, Color("#8d7b93"), box.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_multiline_text_item({"pos": box.position + Vector2(36, 228), "text": "この配信者は現在準備中です。\n今後のアップデートで追加予定です。", "width": int(box.size.x - 72), "size": 19, "color": Color("#6b4a63")}, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_character_select_detail_section(Rect2(panel.position + Vector2(34, 438), Vector2(panel.size.x - 68, 120)), "状態", "準備中\n選択はできますが、決定はできません。", Color("#a46fc3"), Color("#fff8fc"), 18)

func _draw_character_select_locked_detail(panel: Rect2, index: int) -> void:
	var box := Rect2(panel.position + Vector2(34, 96), Vector2(panel.size.x - 68, 300))
	_draw_ranking_panel(box, Color("#fbf8fc"), Color("#ded4e4"), 22, 2, false)
	draw_circle(box.get_center() + Vector2(0, -58), 58, Color("#eee7f1"))
	draw_circle(box.get_center() + Vector2(0, -58), 58, Color("#d8d0dc"), false, 3.0)
	_draw_ranking_text("？？？", box.position + Vector2(0, 152), 42, Color("#8f8793"), box.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_ranking_text("未開放の配信者", box.position + Vector2(0, 210), 26, Color("#8d7b93"), box.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	var condition := _character_select_placeholder_unlock_text(index)
	_draw_character_select_detail_section(Rect2(panel.position + Vector2(34, 438), Vector2(panel.size.x - 68, 132)), "解放条件", "この配信者はまだ開放されていません。\n解放条件：%s" % condition, Color("#8f70c8"), Color("#fff8fc"), 18)

func _draw_character_select_footer(layout: Dictionary, page: int, page_count: int) -> void:
	var rect: Rect2 = layout["footer"] as Rect2
	_draw_ranking_panel(rect, Color(1, 1, 1, 0.94), Color("#ead7e9"), 18, 2, true)
	_draw_character_select_button(layout["backButton"] as Rect2, "戻る", Color("#ff93cd") if character_select_focus_area == PRE_RUN_SELECT_FOCUS_BACK else Color("#f8f2ff"), Color.WHITE if character_select_focus_area == PRE_RUN_SELECT_FOCUS_BACK else Color("#6b4a63"), true, character_select_focus_area == PRE_RUN_SELECT_FOCUS_BACK)
	_draw_ranking_text("%d / %d" % [page + 1, page_count], rect.position + Vector2(0, 34), 19, Color("#6b4a63"), rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_character_select_button(layout["prevButton"] as Rect2, "← 前", Color("#ffffff"), Color("#6b4a63"), page > 0)
	_draw_character_select_button(layout["nextButton"] as Rect2, "次 →", Color("#ffffff"), Color("#6b4a63"), page + 1 < page_count)

func _draw_character_select_button(rect: Rect2, label: String, fill: Color, text_color: Color, enabled: bool, selected: bool = false) -> void:
	var actual_fill: Color = fill if enabled else Color("#eee9ef")
	var actual_text: Color = text_color if enabled else Color("#a89fac")
	_draw_ranking_panel(rect, actual_fill, Color("#ff62b5") if selected else Color("#ead7e9"), 14, 3 if selected else 2, false)
	_draw_ranking_text(label, rect.position + Vector2(0, 24), 17, actual_text, rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_character_select_info_card(rect: Rect2, label: String, value: String, fill: Color, accent: Color) -> void:
	_draw_ranking_panel(rect, fill, Color("#efd5e7"), 14, 2, false)
	_draw_ranking_text(label, rect.position + Vector2(16, 22), 14, accent, rect.size.x - 32)
	_draw_ranking_text(_short_pause_text(value, 25), rect.position + Vector2(16, 46), 18, Color("#4f3149"), rect.size.x - 32)

func _draw_character_select_tag(rect: Rect2, text: String, fill: Color, accent: Color) -> void:
	_draw_ranking_panel(rect, fill, Color("#dbeaf4"), 12, 1, false)
	_draw_ranking_text(_short_pause_text(text, 13), rect.position + Vector2(0, rect.size.y * 0.68), 16, accent, rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_character_select_tag_row(rect: Rect2, tags: Array, accent: Color, max_count: int, text_size: int = 14, opaque: bool = false) -> void:
	var x := rect.position.x
	var y := rect.position.y
	var shown := 0
	for item in tags:
		if shown >= max_count:
			break
		var tag := String(item)
		if tag.strip_edges() == "":
			continue
		var width := clampf(float(tag.length()) * float(text_size) + 28.0, 78.0, rect.end.x - x)
		if x + width > rect.end.x:
			break
		var tag_rect := Rect2(Vector2(x, y), Vector2(width, rect.size.y))
		var tag_fill := Color(1.0, 1.0, 1.0, 1.0) if opaque else Color(accent.r, accent.g, accent.b, 0.10)
		var tag_border := Color(accent.r, accent.g, accent.b, 0.56 if opaque else 0.34)
		_draw_ranking_panel(tag_rect, tag_fill, tag_border, int(rect.size.y * 0.5), 1, false)
		_draw_ranking_text(tag, tag_rect.position + Vector2(0, rect.size.y * 0.68), text_size, Color(accent.r * 0.75, accent.g * 0.75, accent.b * 0.75, 1.0), tag_rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)
		x += width + 8.0
		shown += 1

func _draw_character_select_weapon_highlight(rect: Rect2, view: Dictionary, accent: Color, soft_fill: Color, overlay: bool = false) -> void:
	var fill := Color(soft_fill.r, soft_fill.g, soft_fill.b, 0.92) if overlay else Color(soft_fill.r, soft_fill.g, soft_fill.b, 0.98)
	var border := Color(accent.r, accent.g, accent.b, 0.48 if overlay else 0.42)
	_draw_ranking_panel(rect, fill, border, 17, 2, false)
	_draw_character_select_weapon_line(Rect2(rect.position + Vector2(18, 8), Vector2(rect.size.x - 36, 30)), view, "weaponName", "weaponIconPath", accent, "初期武器：")

func _draw_character_select_detail_section(rect: Rect2, title: String, text: String, accent: Color, fill: Color, text_size: int = 15, body_offset_y: float = 0.0) -> void:
	_draw_ranking_panel(rect, fill, Color(accent.r, accent.g, accent.b, 0.28), 16, 2, false)
	_draw_ranking_text(title, rect.position + Vector2(18, 26), 15, accent, rect.size.x - 36)
	_draw_multiline_text_item({"pos": rect.position + Vector2(18, 48 + body_offset_y), "text": text, "width": int(rect.size.x - 36), "size": text_size, "color": Color("#5d4658")})

func _draw_character_select_weapon_line(rect: Rect2, view: Dictionary, name_key: String = "weaponName", icon_key: String = "weaponIconPath", accent: Color = Color("#e24e9a"), prefix: String = "") -> void:
	var icon: Texture2D = _load_equipment_icon(String(view.get(icon_key, "")))
	var text_x := rect.position.x
	if icon != null:
		var icon_size: float = minf(rect.size.y, 30.0)
		var icon_rect := Rect2(rect.position, Vector2(icon_size, icon_size))
		draw_texture_rect(icon, icon_rect, false)
		text_x += icon_size + 8.0
	_draw_ranking_text(_short_pause_text("%s%s" % [prefix, String(view.get(name_key, "未設定"))], 22), Vector2(text_x, rect.position.y + 23), 16, accent, rect.end.x - text_x)

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
		"backButton": Rect2(108, 838, 176, 34),
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

func _stream_start_intro_color(data: Dictionary, key: String, fallback: Color) -> Color:
	var raw := String(data.get(key, ""))
	return Color(raw) if raw != "" else fallback

func _stream_start_intro_alpha(color: Color, alpha: float) -> Color:
	color.a *= alpha
	return color

func _stream_start_intro_character_config() -> Dictionary:
	var character_configs_raw: Variant = stream_start_intro_config.get("characters", {})
	if not (character_configs_raw is Dictionary):
		return {}
	var character_configs: Dictionary = character_configs_raw as Dictionary
	var character_id := current_character_id
	if character_id == "":
		character_id = String(current_character.get("id", ""))
	var default_config: Dictionary = character_configs.get("default", {}) as Dictionary
	var config: Dictionary = character_configs.get(character_id, default_config) as Dictionary
	var alias := String(config.get("aliasOf", ""))
	if alias != "" and character_configs.has(alias):
		config = character_configs[alias] as Dictionary
	return config

func _stream_start_intro_character_display_name(character_config: Dictionary) -> String:
	var display_name := String(character_config.get("displayName", ""))
	if display_name != "":
		return display_name
	display_name = String(current_character.get("displayName", ""))
	return display_name if display_name != "" else "配信者"

func _stream_start_intro_frame_config() -> Dictionary:
	var frame_configs_raw: Variant = stream_start_intro_config.get("frames", {})
	if not (frame_configs_raw is Dictionary):
		return {}
	var frame_configs: Dictionary = frame_configs_raw as Dictionary
	var frame_id := "relay" if relay_mode else current_stream_frame_id
	return frame_configs.get(frame_id, frame_configs.get("default", {})) as Dictionary

func _stream_start_intro_frame_title(frame_config: Dictionary) -> String:
	var title := String(frame_config.get("title", ""))
	if title != "":
		return title
	if relay_mode:
		return "配信リレー"
	return String(current_stream_frame.get("displayName", "配信枠"))

func _stream_start_intro_status_label(frame_config: Dictionary, progress: float) -> String:
	var labels: Array = []
	var raw_labels: Variant = frame_config.get("statusLabels", [])
	if raw_labels is Array:
		labels = raw_labels as Array
	if labels.is_empty():
		var default_labels: Variant = stream_start_intro_config.get("progressLabels", [])
		if default_labels is Array:
			labels = default_labels as Array
	if labels.is_empty():
		return "配信準備中…"
	var index := clampi(int(floor(progress * float(labels.size()))), 0, labels.size() - 1)
	return String(labels[index])

func _stream_start_intro_character_texture(character_config: Dictionary) -> Texture2D:
	var paths: Array[String] = []
	var ready_path := String(character_config.get("imagePath", ""))
	if ready_path != "":
		paths.append(ready_path)
	var sprite_path := String(current_character.get("sprite", ""))
	if sprite_path != "":
		paths.append(sprite_path)
	var icon_path := String(current_character.get("iconPath", ""))
	if icon_path != "":
		paths.append(icon_path)
	for path in paths:
		if not ResourceLoader.exists(path) and not FileAccess.file_exists(path):
			continue
		var texture: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, path)
		if texture != null:
			return texture
	return null

func _draw_stream_start_intro_overlay_v2() -> void:
	var elapsed_intro := _stream_start_intro_elapsed()
	var progress := _stream_start_intro_progress()
	var clock := float(Time.get_ticks_msec()) / 1000.0
	var fade_in := smoothstep(0.0, 0.30, elapsed_intro)
	var fade_out := 1.0 - smoothstep(maxf(0.35, stream_start_intro_duration - 0.35), stream_start_intro_duration, elapsed_intro)
	var alpha := clampf(minf(fade_in, fade_out), 0.0, 1.0)
	var character_config := _stream_start_intro_character_config()
	var frame_config := _stream_start_intro_frame_config()
	var character_accent := _stream_start_intro_color(character_config, "accentColor", Color("#f36fa8"))
	var accent := _stream_start_intro_color(frame_config, "accentColor", character_accent)
	var sub_color := _stream_start_intro_color(frame_config, "subColor", _stream_start_intro_color(character_config, "subColor", Color("#8bdff2")))
	var soft_color := _stream_start_intro_color(character_config, "softColor", Color("#fff4fb"))
	var background_path := String(stream_start_intro_config.get("backgroundPath", TITLE_BACK_IMAGE))
	var background: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, background_path)
	if background != null:
		draw_texture_rect(background, TITLE_SCREEN_RECT, false, Color(1, 1, 1, alpha))
	else:
		_draw_screen_backdrop()
	draw_rect(TITLE_SCREEN_RECT, Color(1.0, 0.96, 0.995, 0.64 * alpha), true)
	draw_rect(TITLE_SCREEN_RECT, Color(0.76, 0.92, 1.0, 0.10 * alpha), true)
	_draw_stream_start_ready_character(Rect2(-64, 156, 720, 710), character_config, soft_color, alpha)
	var panel := Rect2(670, 118, 822, 650)
	_draw_ranking_panel(panel, Color(1.0, 0.99, 1.0, 0.95 * alpha), Color(accent.r, accent.g, accent.b, 0.82 * alpha), 36, 4, true)
	_draw_ranking_panel(panel.grow(-16.0), Color(soft_color.r, soft_color.g, soft_color.b, 0.35 * alpha), Color(sub_color.r, sub_color.g, sub_color.b, 0.26 * alpha), 26, 2, false)
	var icon_path := String(frame_config.get("iconPath", ""))
	var icon_texture: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, icon_path)
	if icon_texture != null:
		var icon_rect := Rect2(panel.position + Vector2(54, 48), Vector2(78, 78))
		_draw_ranking_panel(icon_rect.grow(8.0), Color(1, 1, 1, 0.82 * alpha), Color(sub_color.r, sub_color.g, sub_color.b, 0.50 * alpha), 28, 2, false)
		draw_texture_rect(icon_texture, _fit_texture_rect(icon_rect, icon_texture.get_size()), false, Color(1, 1, 1, alpha))
	_draw_ranking_text("今日の配信枠", panel.position + Vector2(152, 74), 24, _stream_start_intro_alpha(Color("#9b5a95"), 0.92 * alpha), 260)
	_draw_ranking_text(_stream_start_intro_frame_title(frame_config), panel.position + Vector2(152, 122), 42, _stream_start_intro_alpha(Color("#4f3149"), alpha), 560)
	var start_callout_rect := Rect2(panel.position + Vector2(72, 220), Vector2(678, 138))
	var ready_alpha := smoothstep(0.30, 0.46, elapsed_intro) * (1.0 - smoothstep(0.88, 1.02, elapsed_intro)) * alpha
	if ready_alpha > 0.01:
		var ready_glow := 0.45 + sin(clock * 8.0) * 0.16
		_draw_ranking_panel(start_callout_rect, Color(1, 1, 1, 0.72 * ready_alpha), Color(sub_color.r, sub_color.g, sub_color.b, (0.40 + ready_glow * 0.30) * ready_alpha), 36, 3, false)
		_draw_ranking_text("READY", start_callout_rect.position + Vector2(0, 94), 72, _stream_start_intro_alpha(Color("#7a56c8"), ready_alpha), start_callout_rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	var live_alpha := smoothstep(0.90, 1.08, elapsed_intro) * alpha
	var live_scale := 0.84 + 0.16 * smoothstep(0.90, 1.14, elapsed_intro) + sin(clock * 6.8) * 0.012
	var live_rect := start_callout_rect.grow((live_scale - 1.0) * 84.0)
	if live_alpha > 0.01:
		_draw_stream_start_live_fx(panel, clock, live_alpha, accent, sub_color)
		_draw_ranking_panel(live_rect, Color(1.0, 0.965, 0.995, 0.94 * live_alpha), Color(accent.r, accent.g, accent.b, 0.76 * live_alpha), 36, 3, false)
		_draw_ranking_text("LIVE START!!", live_rect.position + Vector2(0, 94), 72, _stream_start_intro_alpha(Color("#ff3f94"), live_alpha), live_rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	var main_message := String(frame_config.get("mainMessage", "コメント受付開始！"))
	_draw_ranking_text(main_message, panel.position + Vector2(72, 430), 30, _stream_start_intro_alpha(Color("#6b4a63"), alpha), panel.size.x - 144, HORIZONTAL_ALIGNMENT_CENTER)
	var notice := String(frame_config.get("notice", "コメント欄の反応に注意！"))
	_draw_ranking_panel(Rect2(panel.position + Vector2(72, 468), Vector2(panel.size.x - 144, 70)), _stream_start_intro_alpha(Color("#fff7fc"), 0.86 * alpha), Color(accent.r, accent.g, accent.b, 0.28 * alpha), 22, 2, false)
	_draw_ranking_text(notice, panel.position + Vector2(92, 511), 22, _stream_start_intro_alpha(Color("#8a587d"), alpha), panel.size.x - 184, HORIZONTAL_ALIGNMENT_CENTER)
	var status_label := _stream_start_intro_status_label(frame_config, progress)
	_draw_ranking_text(status_label, panel.position + Vector2(72, 584), 20, _stream_start_intro_alpha(Color("#7a56c8"), alpha), 360)
	var bar_back := Rect2(panel.position + Vector2(72, 602), Vector2(panel.size.x - 144, 20))
	_draw_ranking_panel(bar_back.grow(7.0), _stream_start_intro_alpha(Color("#fff8fc"), 0.92 * alpha), _stream_start_intro_alpha(Color("#f3cfe4"), 0.88 * alpha), 14, 2, false)
	draw_rect(Rect2(bar_back.position, Vector2(bar_back.size.x * progress, bar_back.size.y)), Color(accent.r, accent.g, accent.b, 0.86 * alpha), true)
	draw_rect(Rect2(bar_back.position, Vector2(bar_back.size.x * progress, 5.0)), Color(1.0, 1.0, 1.0, 0.34 * alpha), true)
	_draw_ranking_text("%d%%" % int(round(progress * 100.0)), bar_back.position + Vector2(0, 37), 18, _stream_start_intro_alpha(Color("#6b4a63"), alpha), bar_back.size.x, HORIZONTAL_ALIGNMENT_RIGHT)

func _draw_stream_start_ready_character(rect: Rect2, character_config: Dictionary, soft_color: Color, alpha: float) -> void:
	var texture := _stream_start_intro_character_texture(character_config)
	if texture == null:
		var silhouette := Rect2(rect.position + Vector2(120, 82), Vector2(360, 520))
		_draw_ranking_panel(silhouette, Color(soft_color.r, soft_color.g, soft_color.b, 0.66 * alpha), _stream_start_intro_alpha(Color("#ffaad1"), 0.54 * alpha), 44, 3, true)
		draw_circle(silhouette.position + Vector2(silhouette.size.x * 0.5, 170), 86, Color(1, 1, 1, 0.68 * alpha))
		draw_circle(silhouette.position + Vector2(silhouette.size.x * 0.5, 354), 132, Color(1, 1, 1, 0.54 * alpha))
	else:
		var image_rect := _fit_texture_rect(rect, texture.get_size())
		image_rect.position.y = rect.end.y - image_rect.size.y
		image_rect.position.x = rect.position.x + (rect.size.x - image_rect.size.x) * 0.18
		draw_texture_rect(texture, image_rect, false, Color(1, 1, 1, alpha))
	var badge := Rect2(68, 784, 360, 54)
	_draw_ranking_panel(badge, Color(1, 1, 1, 0.72 * alpha), Color(1.0, 0.70, 0.84, 0.58 * alpha), 24, 2, true)
	_draw_ranking_text(_stream_start_intro_character_display_name(character_config) + "　配信準備中", badge.position + Vector2(0, 36), 20, _stream_start_intro_alpha(Color("#774865"), alpha), badge.size.x, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_stream_start_live_fx(panel: Rect2, clock: float, alpha: float, accent: Color, sub_color: Color) -> void:
	var colors := [Color(accent.r, accent.g, accent.b, 0.84 * alpha), Color(sub_color.r, sub_color.g, sub_color.b, 0.78 * alpha), Color(1.0, 0.88, 0.34, 0.78 * alpha)]
	for i in range(18):
		var angle := clock * 1.8 + float(i) * 0.74
		var distance := 300.0 + sin(clock * 2.0 + float(i)) * 26.0
		var pos := panel.get_center() + Vector2(cos(angle) * distance, sin(angle * 0.82) * 210.0)
		_draw_stream_start_sparkle(pos, 6.0 + float(i % 3) * 2.0, colors[i % colors.size()] as Color)
	for i in range(5):
		var pos := panel.position + Vector2(110.0 + float(i) * 142.0, 178.0 + sin(clock * 2.6 + float(i)) * 12.0)
		_draw_ranking_text("♡", pos, 24 + i % 2 * 4, Color(accent.r, accent.g, accent.b, 0.56 * alpha), 36, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_stream_start_intro_overlay() -> void:
	_draw_stream_start_intro_overlay_v2()

func _draw_stream_start_sparkle(pos: Vector2, size: float, color: Color) -> void:
	draw_line(pos + Vector2(-size, 0), pos + Vector2(size, 0), color, 2.5, true)
	draw_line(pos + Vector2(0, -size), pos + Vector2(0, size), color, 2.5, true)
	draw_circle(pos, 2.0, Color(1.0, 1.0, 1.0, 0.82))

func _draw_game_over_intro_overlay() -> void:
	var duration := maxf(0.01, game_over_intro_duration)
	var progress := clampf((duration - game_over_intro_timer) / duration, 0.0, 1.0)
	var is_completed := pending_game_over_end_type == "completed"
	var clock := float(Time.get_ticks_msec()) / 1000.0
	var completed_has_cutin := is_completed and _stream_complete_cutin_image_path() != ""
	if is_completed:
		draw_rect(TITLE_SCREEN_RECT, Color(1.0, 0.96, 0.99, lerpf(0.24, 0.46, progress)), true)
		draw_rect(TITLE_SCREEN_RECT, Color(0.58, 0.92, 1.0, 0.12 + sin(clock * 5.0) * 0.03), true)
		_draw_stream_complete_cutin_fx(clock, progress)
	else:
		var dim_alpha := lerpf(0.32, 0.58, progress)
		draw_rect(TITLE_SCREEN_RECT, Color(0.06, 0.02, 0.07, dim_alpha), true)
		for i in range(12):
			var y := fmod(clock * 130.0 + float(i) * 77.0, TITLE_SCREEN_RECT.size.y)
			draw_line(Vector2(0, y), Vector2(TITLE_SCREEN_RECT.size.x, y), Color(0.9, 0.05, 0.35, 0.08), 2.0)
		var flash := _mental_breakdown_impact_ratio(MENTAL_BREAKDOWN_FLASH_DURATION)
		if flash > 0.0:
			draw_rect(TITLE_SCREEN_RECT, Color(1.0, 0.08, 0.32, 0.25 * flash), true)
	var pulse := 1.0 + sin(clock * 7.5) * 0.018
	var completed_panel_base := Rect2(276, 238, 706, 360) if completed_has_cutin else Rect2(447, 238, 706, 360)
	var panel_base := completed_panel_base if is_completed else Rect2(342, 232, 640, 360)
	var panel := panel_base.grow((pulse - 1.0) * 64.0)
	var panel_border := Color("#ffd46a") if is_completed else Color("#ff7db7")
	var panel_fill := Color(1.0, 0.995, 0.985, 0.97) if is_completed else Color(1.0, 0.972, 0.994, 0.96)
	if not is_completed:
		_draw_mental_breakdown_accident_label(panel)
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
	var main_y := 118.0 if is_completed else 148.0
	var sub_y := 176.0 if is_completed else 210.0
	var reason_y := 218.0 if is_completed else 256.0
	var bar_y := 306.0 if is_completed else 314.0
	var skip_y := 340.0 if is_completed else 348.0
	_draw_ranking_text(icon_text, panel.position + Vector2(63, 101), 28, main_color, 40, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_ranking_text(main_text, panel.position + Vector2(0, main_y), 58, main_color, panel.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_ranking_text(sub_text, panel.position + Vector2(0, sub_y), 25, Color("#6b4a63"), panel.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	if not is_completed:
		_draw_mental_breakdown_cutin_status(panel, clock)
	var reason_text := pending_game_over_reason.strip_edges()
	if reason_text != "":
		var reason_width := panel.size.x - 144.0 if is_completed else 380.0
		_draw_ranking_text(reason_text, panel.position + Vector2(72, reason_y), 18, Color("#554155"), reason_width, HORIZONTAL_ALIGNMENT_CENTER)
	if is_completed:
		_draw_stream_complete_cutin_stats(panel, clock)
		_draw_stream_complete_comment_bubbles(panel, clock, progress)
	if not is_completed:
		_draw_mental_breakdown_cutin_character(progress, clock)
	else:
		_draw_stream_complete_cutin_character(progress, clock)
	var bar_pos := panel.position + (Vector2(170, bar_y) if is_completed else Vector2(118, bar_y))
	var bar_size := Vector2(400, 14) if is_completed else Vector2(330, 14)
	var bar_back := Rect2(bar_pos, bar_size)
	_draw_ranking_panel(bar_back.grow(5.0), Color("#fff9fd"), Color("#f2c8de"), 10, 2, false)
	draw_rect(Rect2(bar_back.position, Vector2(bar_back.size.x * progress, bar_back.size.y)), Color("#ffd15c") if is_completed else Color("#ff5aa5"), true)
	if _game_over_intro_can_skip():
		var skip_pos := panel.position + (Vector2(0, skip_y) if is_completed else Vector2(28, skip_y))
		var skip_width := panel.size.x if is_completed else 500.0
		_draw_ranking_text("Enter / Space / Clickでスキップ", skip_pos, 15, Color("#7b6475"), skip_width, HORIZONTAL_ALIGNMENT_CENTER)
	if not is_completed:
		_draw_mental_breakdown_noise_lines(clock, progress)

func _draw_stream_complete_cutin_fx(clock: float, progress: float) -> void:
	var alpha := clampf(progress * 1.8, 0.0, 1.0)
	var colors := [
		Color(1.0, 0.45, 0.72, 0.36 * alpha),
		Color(1.0, 0.86, 0.25, 0.32 * alpha),
		Color(0.52, 0.90, 1.0, 0.28 * alpha),
		Color(1.0, 1.0, 1.0, 0.34 * alpha)
	]
	for i in range(30):
		var angle := clock * 0.72 + float(i) * 0.81
		var x := 70.0 + fmod(float(i) * 137.0 + sin(clock * 1.1 + float(i)) * 52.0, 1460.0)
		var y := 124.0 + fmod(float(i) * 59.0 - clock * 28.0, 610.0)
		var color: Color = colors[i % colors.size()] as Color
		if i % 4 == 0:
			_draw_stream_start_sparkle(Vector2(x, y), 5.0 + float(i % 3) * 2.0, color)
		else:
			var size := 8.0 + float(i % 5) * 2.0
			draw_line(Vector2(x, y), Vector2(x + cos(angle) * size, y + sin(angle) * size * 0.55), color, 3.0, true)
	for i in range(8):
		var symbol := "★" if i % 2 == 0 else "♥"
		var pos := Vector2(120.0 + float(i) * 178.0, 168.0 + sin(clock * 2.2 + float(i)) * 20.0)
		var text_color := Color(1.0, 0.35, 0.68, 0.30 * alpha) if symbol == "♥" else Color(1.0, 0.78, 0.14, 0.36 * alpha)
		_draw_ranking_text(symbol, pos, 28, text_color, 42, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_stream_complete_cutin_stats(panel: Rect2, clock: float) -> void:
	var max_viewers := score
	if relay_mode:
		max_viewers = maxi(max_viewers, relay_max_score)
	var stat_rect := Rect2(panel.position + Vector2(76, 246), Vector2(438, 48))
	var glow := 0.07 + sin(clock * 5.0) * 0.025
	_draw_ranking_panel(stat_rect, Color(1.0, 0.98, 0.92, 0.90), Color("#ffd86c"), 18, 2, false)
	draw_rect(stat_rect.grow(-4.0), Color(1.0, 0.56, 0.74, glow), false, 2.0)
	_draw_ranking_text("最大同時視聴者数", stat_rect.position + Vector2(22, 30), 16, Color("#9a5b3b"), 162)
	_draw_ranking_text("%s人" % _result_number(max_viewers), stat_rect.position + Vector2(184, 34), 25, Color("#ff5a9d"), 170, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_ranking_text("神回！", stat_rect.position + Vector2(354, 31), 18, Color("#8c5be8"), 70, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_stream_complete_comment_bubbles(panel: Rect2, clock: float, progress: float) -> void:
	var alpha := clampf(progress * 2.2, 0.0, 1.0)
	var comments: Array[String] = ["完走おめ！", "神回だった", "888888"]
	for i in range(comments.size()):
		var rect := Rect2(panel.position + Vector2(26.0 + float(i) * 220.0, -56.0 + sin(clock * 2.0 + float(i)) * 4.0), Vector2(184, 38))
		var fill := Color(1.0, 0.985, 1.0, 0.82 * alpha)
		var border := Color(1.0, 0.48, 0.74, 0.68 * alpha)
		if i == 2:
			border = Color(1.0, 0.78, 0.22, 0.70 * alpha)
		_draw_ranking_panel(rect, fill, border, 18, 2, true)
		_draw_ranking_text(comments[i], rect.position + Vector2(0, 27), 18, Color(0.55, 0.25, 0.50, 0.92 * alpha), rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_stream_complete_cutin_character(progress: float, clock: float) -> void:
	var image_path := _stream_complete_cutin_image_path()
	if image_path == "":
		return
	var texture: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, image_path)
	if texture == null:
		return
	var appear := clampf(_game_over_intro_elapsed() / 0.28, 0.0, 1.0)
	var eased := appear * appear * (3.0 - 2.0 * appear)
	var scale := lerpf(0.94, 1.0, eased) + sin(clock * 3.8) * 0.006
	var base_rect := _stream_complete_cutin_rect()
	var size := base_rect.size * scale
	var bob := Vector2(0, sin(clock * 4.2) * 5.0)
	var pos := base_rect.position + (base_rect.size - size) * 0.5 + Vector2(0, (1.0 - eased) * 30.0) + bob
	draw_texture_rect(texture, Rect2(pos, size), false, Color(1, 1, 1, clampf(progress * 5.0, 0.0, 1.0)))

func _stream_complete_cutin_image_path() -> String:
	return _stream_complete_result_image_path(_stream_complete_cutin_character_id())

func _stream_complete_cutin_rect() -> Rect2:
	var character_id := _stream_complete_cutin_character_id()
	if character_id == "superchat_chan" or character_id == "supana":
		return Rect2(Vector2(806, 112), Vector2(546, 632))
	if character_id == "maro_chan" or character_id == "maron":
		return Rect2(Vector2(800, 96), Vector2(670, 632))
	return Rect2(Vector2(848, 112), Vector2(520, 632))

func _stream_complete_cutin_character_id() -> String:
	var character_id := current_character_id
	if character_id == "":
		character_id = String(current_character.get("id", ""))
	return character_id

func _draw_mental_breakdown_accident_label(panel: Rect2) -> void:
	var label_rect := Rect2(panel.position + Vector2(100, -48), Vector2(362, 42))
	_draw_ranking_panel(label_rect, Color("#f2308b"), Color("#fff5fb"), 18, 2, false)
	_draw_ranking_text("配信事故発生", label_rect.position + Vector2(0, 30), 27, Color.WHITE, label_rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_mental_breakdown_cutin_character(progress: float, clock: float) -> void:
	var image_path := _mental_breakdown_cutin_image_path()
	if image_path == "":
		return
	var texture: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, image_path)
	if texture == null:
		return
	var appear := clampf(_game_over_intro_elapsed() / 0.24, 0.0, 1.0)
	var eased := appear * appear * (3.0 - 2.0 * appear)
	var scale := lerpf(0.95, 1.0, eased)
	var base_rect := _mental_breakdown_cutin_rect()
	var shake_strength := 2.0 * _mental_breakdown_impact_ratio(MENTAL_BREAKDOWN_REACTION_DURATION)
	var jitter := Vector2(sin(clock * 46.0), cos(clock * 51.0)) * shake_strength
	var size := base_rect.size * scale
	var pos := base_rect.position + (base_rect.size - size) * 0.5 + Vector2(0, (1.0 - eased) * 34.0) + jitter
	var image_rect := _fit_texture_rect(Rect2(pos, size), texture.get_size())
	draw_texture_rect(texture, image_rect, false, Color(1, 1, 1, clampf(progress * 5.0, 0.0, 1.0)))

func _mental_breakdown_cutin_image_path() -> String:
	var character_id := current_character_id
	if character_id == "":
		character_id = String(current_character.get("id", ""))
	if character_id == "ban_chan" or character_id == "banri":
		return MENTAL_BREAKDOWN_INTRO_BANRI_IMAGE
	if character_id == "superchat_chan" or character_id == "supana":
		return MENTAL_BREAKDOWN_INTRO_SUPANA_IMAGE
	if character_id == "maro_chan" or character_id == "maron":
		return MENTAL_BREAKDOWN_INTRO_MARON_IMAGE
	return ""

func _mental_breakdown_cutin_rect() -> Rect2:
	var character_id := current_character_id
	if character_id == "":
		character_id = String(current_character.get("id", ""))
	if character_id == "superchat_chan" or character_id == "supana":
		return Rect2(Vector2(820, 232), Vector2(486, 562))
	if character_id == "maro_chan" or character_id == "maron":
		return Rect2(Vector2(820, 226), Vector2(558, 562))
	return Rect2(Vector2(872, 232), Vector2(450, 562))

func _draw_mental_breakdown_noise_lines(clock: float, progress: float) -> void:
	var alpha_base := 0.10 + 0.16 * clampf(progress * 2.0, 0.0, 1.0)
	var colors := [
		Color(1.0, 1.0, 1.0, alpha_base),
		Color(1.0, 0.18, 0.55, alpha_base * 0.85),
		Color(0.45, 0.95, 1.0, alpha_base * 0.75)
	]
	for i in range(18):
		var y := 166.0 + fmod(clock * 92.0 + float(i) * 43.0, 610.0)
		var x := fmod(float(i) * 173.0 + sin(clock * 1.7 + float(i)) * 84.0, 1420.0)
		var length := 110.0 + float((i * 37) % 260)
		var thickness := 1.0 + float(i % 3) * 0.55
		var color: Color = colors[i % colors.size()] as Color
		draw_line(Vector2(x, y), Vector2(minf(TITLE_SCREEN_RECT.size.x, x + length), y), color, thickness, true)
		if i % 5 == 0:
			draw_line(Vector2(maxf(0.0, x - 70.0), y + 8.0), Vector2(x + length * 0.42, y + 8.0), Color(1.0, 1.0, 1.0, alpha_base * 0.55), 1.0, true)

func _draw_mental_breakdown_cutin_status(panel: Rect2, clock: float) -> void:
	var gauge := Rect2(panel.position + Vector2(112, 52), Vector2(150, 44))
	_draw_ranking_panel(gauge, Color("#fff2f8"), Color("#ff74aa"), 16, 2, false)
	_draw_ranking_text("メンタル 0%", gauge.position + Vector2(0, 29), 18, Color("#f04893"), gauge.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	var icon_center := panel.position + Vector2(82, 86)
	var crack_alpha := 0.72 + sin(clock * 12.0) * 0.18
	draw_line(icon_center + Vector2(-12, -16), icon_center + Vector2(-2, -4), Color(1, 1, 1, crack_alpha), 3.0)
	draw_line(icon_center + Vector2(-2, -4), icon_center + Vector2(-8, 7), Color(1, 1, 1, crack_alpha), 3.0)
	draw_line(icon_center + Vector2(-8, 7), icon_center + Vector2(8, 19), Color(1, 1, 1, crack_alpha), 3.0)
	if pending_game_over_reason.strip_edges() == "":
		var note := Rect2(panel.position + Vector2(238, 210), Vector2(264, 34))
		_draw_ranking_panel(note, Color(1.0, 0.92, 0.97, 0.92), Color("#ffc1da"), 14, 1, false)
		_draw_ranking_text("コメント欄がざわついている…", note.position + Vector2(0, 24), 16, Color("#9b4774"), note.size.x, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_stream_frame_select_header(rect: Rect2) -> void:
	_draw_ranking_panel(rect, Color(1, 1, 1, 0.95), Color("#ead7e9"), 22, 2, true)
	var header_icon: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, STREAM_FRAME_SELECT_HEADER_ICON)
	if header_icon != null:
		var icon_rect := Rect2(rect.position + Vector2(14, 16), Vector2(66, 40))
		draw_texture_rect(header_icon, _fit_texture_rect(icon_rect, header_icon.get_size()), false, Color(1, 1, 1, 0.98))
	else:
		draw_circle(rect.position + Vector2(46, 36), 22, Color("#fff3fb"))
		_draw_ranking_text("枠", rect.position + Vector2(35, 47), 25, Color("#f05aa5"), 28, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_ranking_text("今日の配信枠を選択", rect.position + Vector2(88, 47), 34, Color("#4f3149"), 520)
	_draw_ranking_text("←→：選択　A/D：ページ　Enter：決定　Esc：戻る", rect.position + Vector2(682, 45), 20, Color("#6b4a63"), 710, HORIZONTAL_ALIGNMENT_CENTER)

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
	var selected: bool = stream_frame_select_focus_area == PRE_RUN_SELECT_FOCUS_ITEMS and index == selected_stream_frame_index
	var selectable: bool = bool(view.get("isSelectable", true))
	var accent: Color = view.get("accent", Color("#f05aa5")) as Color
	var status_fill: Color = view.get("statusFill", Color("#fff2fa")) as Color
	var status_text_color: Color = view.get("statusTextColor", accent) as Color
	var status_border: Color = view.get("statusBorder", accent) as Color
	var border: Color = Color("#ff4aa2") if selected else Color(accent.r, accent.g, accent.b, 0.34)
	var fill: Color = Color(1, 1, 1, 0.98)
	var text_color := Color("#4f3149")
	if not selectable:
		border = Color("#cfc8d6") if not selected else Color("#a887d8")
		fill = Color("#f4f0f5")
		text_color = Color("#7f7480")
	if selected:
		fill = Color("#fff2fa") if selectable else Color("#f4eff7")
		_draw_ranking_panel(rect.grow(8), Color(accent.r, accent.g, accent.b, 0.22), Color(1, 1, 1, 0), 24, 0, false)
		_draw_ranking_panel(rect.grow(3), Color(1, 1, 1, 0), Color(accent.r, accent.g, accent.b, 0.42), 22, 2, false)
	_draw_ranking_panel(rect, fill, border, 20, 5 if selected else 2, false)
	_draw_stream_frame_select_icon(Rect2(rect.position + Vector2(66, 34), Vector2(132, 92)), view, accent, not selectable)
	_draw_ranking_text("%d. %s" % [index + 1, _short_pause_text(String(view.get("plainName", "配信枠")), 9)], rect.position + Vector2(20, 150), 24, text_color if selectable else Color("#8f8793"), rect.size.x - 40, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_ranking_text(String(view.get("difficultyText", "難易度：★")), rect.position + Vector2(20, 180), 17, accent if selectable else Color("#8f8793"), rect.size.x - 40, HORIZONTAL_ALIGNMENT_CENTER)
	var badge_rect := Rect2(rect.position + Vector2(52, 207), Vector2(rect.size.x - 104, 32))
	_draw_character_select_tag(badge_rect, String(view.get("statusText", "解放済み")), status_fill, status_text_color)
	_draw_rect_outline(badge_rect, status_border, 1)
	_draw_ranking_text(_short_pause_text(String(view.get("featureText", "")), 20), rect.position + Vector2(18, 260), 14, Color("#5d4658") if selectable else Color("#8f8793"), rect.size.x - 36, HORIZONTAL_ALIGNMENT_CENTER)
	if selected:
		var selected_rect := Rect2(rect.position + Vector2(rect.size.x - 92, 14), Vector2(74, 26))
		_draw_ranking_panel(selected_rect, Color("#ff6fb7"), Color("#ff3d98"), 13, 1, false)
		_draw_ranking_text("★ 選択中", selected_rect.position + Vector2(4, 19), 13, Color.WHITE, selected_rect.size.x - 8, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_stream_frame_select_coming_card(rect: Rect2) -> void:
	_draw_ranking_panel(rect, Color("#fbf8fc"), Color("#e0d7e2"), 20, 2, false)
	draw_circle(rect.position + rect.size * 0.5 + Vector2(0, -24), 48, Color("#f1eaf2"))
	_draw_ranking_text("COMING", rect.position + Vector2(0, 136), 24, Color("#a294a3"), rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_ranking_text("SOON", rect.position + Vector2(0, 168), 24, Color("#a294a3"), rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_ranking_text("新しい配信枠をお楽しみに！", rect.position + Vector2(20, 224), 15, Color("#8f8793"), rect.size.x - 40, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_stream_frame_select_detail_panel(panel: Rect2, frames: Array) -> void:
	_draw_ranking_panel(panel, Color(1, 1, 1, 0.93), Color("#ead7e9"), 24, 2, true)
	_draw_ranking_text("選択中の配信枠", panel.position + Vector2(30, 44), 26, Color("#ff5aa5"), panel.size.x - 60)
	if frames.is_empty():
		_draw_ranking_text("配信枠データがありません。", panel.position + Vector2(30, 300), 22, Color("#6b4a63"), panel.size.x - 60, HORIZONTAL_ALIGNMENT_CENTER)
		return
	var index: int = clampi(selected_stream_frame_index, 0, frames.size() - 1)
	var frame: Dictionary = frames[index] as Dictionary
	var view: Dictionary = StreamFrameSystemScript.selection_card_view(frame)
	var accent: Color = view.get("accent", Color("#f05aa5")) as Color
	var accent2: Color = view.get("accent2", accent) as Color
	var selectable: bool = bool(view.get("isSelectable", true))
	_draw_stream_frame_select_icon(Rect2(panel.position + Vector2(176, 62), Vector2(190, 126)), view, accent, not selectable, true)
	_draw_ranking_text(String(view.get("plainName", "配信枠")), panel.position + Vector2(30, 230), 31, accent if selectable else Color("#7f7480"), panel.size.x - 60, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_character_select_info_card(Rect2(panel.position + Vector2(28, 272), Vector2(232, 52)), "難易度", String(view.get("difficultyStars", "★")), Color("#fff2fa"), accent)
	_draw_character_select_info_card(Rect2(panel.position + Vector2(282, 272), Vector2(232, 52)), "状態", String(view.get("statusText", "解放済み")), Color("#f3ecff"), accent2)
	_draw_character_select_info_card(Rect2(panel.position + Vector2(28, 336), Vector2(panel.size.x - 56, 52)), "特徴", String(view.get("featureText", "")), Color("#e8f7ff"), Color("#4d8ab5"))
	_draw_stream_frame_detail_section(Rect2(panel.position + Vector2(28, 402), Vector2(panel.size.x - 56, 68)), "主なギミック", String(view.get("mainGimmickText", "")), accent, Color("#fff8fc"), 15)
	_draw_stream_frame_detail_section(Rect2(panel.position + Vector2(28, 482), Vector2(panel.size.x - 56, 116)), "説明", String(view.get("description", "")), accent, Color(1, 1, 1, 0.98), 16)
	var note_title := "おすすめ" if selectable else "理由"
	var note_text := String(view.get("recommendText", "")) if selectable else String(view.get("disabledReason", "この配信枠はまだ選択できません。"))
	if not selectable and String(view.get("statusId", "")) == "locked":
		note_title = "解放条件"
		note_text = String(view.get("unlockConditionText", note_text))
	_draw_stream_frame_detail_section(Rect2(panel.position + Vector2(28, 612), Vector2(panel.size.x - 56, 66)), note_title, note_text, accent2, Color("#fff8fc"), 15)


func _draw_stream_frame_detail_section(rect: Rect2, title: String, text: String, accent: Color, fill: Color, text_size: int = 16) -> void:
	_draw_ranking_panel(rect, fill, Color(accent.r, accent.g, accent.b, 0.28), 16, 2, false)
	_draw_ranking_text(title, rect.position + Vector2(18, 28), 16, accent, rect.size.x - 36)
	_draw_multiline_text_item({"pos": rect.position + Vector2(18, 52), "text": text, "width": int(rect.size.x - 36), "size": text_size, "color": Color("#5d4658")})

func _draw_stream_frame_select_footer(layout: Dictionary, frames: Array, page: int, page_count: int) -> void:
	var rect: Rect2 = layout["footer"] as Rect2
	_draw_ranking_panel(rect, Color(1, 1, 1, 0.94), Color("#ead7e9"), 18, 2, true)
	_draw_character_select_button(layout["backButton"] as Rect2, "戻る", Color("#ff93cd") if stream_frame_select_focus_area == PRE_RUN_SELECT_FOCUS_BACK else Color("#f8f2ff"), Color.WHITE if stream_frame_select_focus_area == PRE_RUN_SELECT_FOCUS_BACK else Color("#6b4a63"), true, stream_frame_select_focus_area == PRE_RUN_SELECT_FOCUS_BACK)
	_draw_ranking_text("%d / %d" % [page + 1, page_count], rect.position + Vector2(0, 34), 19, Color("#6b4a63"), rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_character_select_button(layout["prevButton"] as Rect2, "← 前", Color("#ffffff"), Color("#6b4a63"), page > 0)
	_draw_character_select_button(layout["nextButton"] as Rect2, "次 →", Color("#ffffff"), Color("#6b4a63"), page + 1 < page_count)

func _draw_stream_frame_select_icon(rect: Rect2, view: Dictionary, accent: Color, muted: bool, large: bool = false) -> void:
	var center: Vector2 = rect.get_center()
	var radius: float = 64.0 if large else 42.0
	var icon_color: Color = Color("#8f8793") if muted else accent
	draw_circle(center, radius, Color(icon_color.r, icon_color.g, icon_color.b, 0.14))
	draw_circle(center, radius, Color(icon_color.r, icon_color.g, icon_color.b, 0.38), false, 3.0)
	var icon_path := String(view.get("iconPath", ""))
	if not icon_path.is_empty():
		var texture: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, icon_path)
		if texture != null:
			var texture_rect := _fit_texture_rect(rect.grow(-8), texture.get_size())
			var modulate := Color(1, 1, 1, 0.5) if muted else Color.WHITE
			draw_texture_rect(texture, texture_rect, false, modulate)
			return
	_draw_stream_frame_symbol_icon(center, radius, String(view.get("iconId", "")), icon_color, muted)


func _draw_stream_frame_symbol_icon(center: Vector2, radius: float, icon_id: String, color: Color, muted: bool) -> void:
	var alpha := 0.58 if muted else 1.0
	var main := Color(color.r, color.g, color.b, alpha)
	var soft := Color(color.r, color.g, color.b, 0.18 if muted else 0.26)
	var white := Color(1, 1, 1, 0.78 if muted else 0.92)
	var line_width := maxf(2.0, radius * 0.08)
	if icon_id.contains("zatsudan"):
		draw_circle(center + Vector2(0, -6), radius * 0.44, soft)
		draw_circle(center + Vector2(0, -6), radius * 0.44, main, false, line_width)
		draw_colored_polygon(PackedVector2Array([center + Vector2(-12, radius * 0.28), center + Vector2(0, radius * 0.56), center + Vector2(12, radius * 0.28)]), main)
		for offset in [-16.0, 0.0, 16.0]:
			draw_circle(center + Vector2(offset, -6), radius * 0.08, white)
	elif icon_id.contains("gameplay"):
		var body := Rect2(center + Vector2(-radius * 0.5, -radius * 0.22), Vector2(radius, radius * 0.48))
		_draw_ranking_panel(body, soft, main, int(radius * 0.18), int(line_width), false)
		draw_circle(center + Vector2(-radius * 0.24, 2), radius * 0.09, white)
		draw_line(center + Vector2(-radius * 0.35, 2), center + Vector2(-radius * 0.13, 2), main, line_width * 0.7)
		draw_line(center + Vector2(-radius * 0.24, -radius * 0.1), center + Vector2(-radius * 0.24, radius * 0.12), main, line_width * 0.7)
		draw_circle(center + Vector2(radius * 0.22, -radius * 0.06), radius * 0.08, white)
		draw_circle(center + Vector2(radius * 0.34, radius * 0.08), radius * 0.08, white)
	elif icon_id.contains("singing"):
		draw_circle(center + Vector2(0, -radius * 0.2), radius * 0.24, soft)
		draw_circle(center + Vector2(0, -radius * 0.2), radius * 0.24, main, false, line_width)
		draw_line(center + Vector2(radius * 0.14, -radius * 0.02), center + Vector2(radius * 0.32, radius * 0.42), main, line_width)
		draw_line(center + Vector2(radius * 0.2, radius * 0.42), center + Vector2(radius * 0.44, radius * 0.42), main, line_width)
		draw_arc(center + Vector2(-radius * 0.16, -radius * 0.05), radius * 0.56, -1.35, -0.75, 12, white, line_width * 0.65)
	elif icon_id.contains("drawing"):
		draw_line(center + Vector2(-radius * 0.34, radius * 0.28), center + Vector2(radius * 0.32, -radius * 0.34), main, line_width * 1.4)
		draw_line(center + Vector2(-radius * 0.22, radius * 0.4), center + Vector2(radius * 0.44, -radius * 0.22), white, line_width * 0.65)
		draw_colored_polygon(PackedVector2Array([center + Vector2(radius * 0.32, -radius * 0.34), center + Vector2(radius * 0.52, -radius * 0.52), center + Vector2(radius * 0.48, -radius * 0.18)]), main)
		draw_arc(center + Vector2(-radius * 0.16, radius * 0.36), radius * 0.28, 2.9, 6.0, 18, main, line_width * 0.65)
	elif icon_id.contains("collab"):
		draw_circle(center + Vector2(-radius * 0.18, -radius * 0.16), radius * 0.17, soft)
		draw_circle(center + Vector2(radius * 0.18, -radius * 0.16), radius * 0.17, soft)
		draw_circle(center + Vector2(-radius * 0.18, -radius * 0.16), radius * 0.17, main, false, line_width * 0.65)
		draw_circle(center + Vector2(radius * 0.18, -radius * 0.16), radius * 0.17, main, false, line_width * 0.65)
		draw_line(center + Vector2(-radius * 0.3, radius * 0.22), center + Vector2(-radius * 0.05, radius * 0.04), main, line_width)
		draw_line(center + Vector2(radius * 0.3, radius * 0.22), center + Vector2(radius * 0.05, radius * 0.04), main, line_width)
		_draw_stream_frame_icon_heart(center + Vector2(0, radius * 0.16), radius * 0.18, Color("#ff7aa9") if not muted else main)
	elif icon_id.contains("relay"):
		draw_arc(center, radius * 0.48, 0.25, 2.85, 28, main, line_width)
		draw_arc(center, radius * 0.48, 3.38, 6.0, 28, main, line_width)
		draw_colored_polygon(PackedVector2Array([center + Vector2(-radius * 0.48, -radius * 0.06), center + Vector2(-radius * 0.2, -radius * 0.22), center + Vector2(-radius * 0.25, radius * 0.08)]), main)
		draw_colored_polygon(PackedVector2Array([center + Vector2(radius * 0.48, radius * 0.06), center + Vector2(radius * 0.2, radius * 0.22), center + Vector2(radius * 0.25, -radius * 0.08)]), main)
		_draw_stream_frame_icon_star(center, radius * 0.18, Color("#ffd15c") if not muted else main)
	else:
		_draw_stream_frame_icon_star(center, radius * 0.36, main)


func _draw_stream_frame_icon_heart(center: Vector2, size: float, color: Color) -> void:
	draw_circle(center + Vector2(-size * 0.35, -size * 0.2), size * 0.42, color)
	draw_circle(center + Vector2(size * 0.35, -size * 0.2), size * 0.42, color)
	draw_colored_polygon(PackedVector2Array([center + Vector2(-size * 0.8, -size * 0.05), center + Vector2(size * 0.8, -size * 0.05), center + Vector2(0, size * 0.86)]), color)


func _draw_stream_frame_icon_star(center: Vector2, radius: float, color: Color) -> void:
	var points := PackedVector2Array()
	for i in range(10):
		var angle := -PI * 0.5 + float(i) * PI / 5.0
		var length := radius if i % 2 == 0 else radius * 0.48
		points.append(center + Vector2(cos(angle), sin(angle)) * length)
	draw_colored_polygon(points, color)

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

func _comment_choice_has_special_card() -> bool:
	if offered_comments.size() <= 3:
		return false
	var comment: Dictionary = offered_comments[3] as Dictionary
	return String(comment.get("id", "")) == "do_everything"

func _comment_choice_special_card_rect() -> Rect2:
	return Rect2(Vector2(326.0, 657.0) + _comment_choice_drop_offset(), Vector2(821.0, 70.0))

func _draw_gift_choice_card_contents() -> void:
	for i in range(mini(offered_gifts.size(), 3)):
		var gift: Dictionary = offered_gifts[i] as Dictionary
		var rect: Rect2 = _gift_choice_card_rect(i)
		if i == selected_card:
			_draw_gift_choice_cursor(rect)
		var center_x: float = rect.position.x + rect.size.x * 0.5
		var gift_level: int = GiftSystemScript.gift_level_for_target(self, String(gift["id"]))
		var category: String = GiftSystemScript.gift_category_tag(gift)
		var display_name: String = EquipmentSystem.display_name_for_card(gift, gift_level)
		var quality_label: String = GiftSystemScript.gift_quality_label(gift)
		var quality: String = GiftSystemScript.gift_quality(gift)
		var quality_color: Color = GiftSystemScript.gift_quality_color(gift)
		var text_color: Color = Color("#101420")
		var sub_color: Color = Color("#273247")
		if quality_label != "":
			_draw_gift_quality_stamp(rect, quality_label, quality)
		_draw_gift_category_tag(_gift_choice_category_tag_rect(rect), category)
		_draw_three_choice_number_badge(_three_choice_number_badge_rect(rect), i + 1)
		var texture: Texture2D = _load_equipment_icon(String(gift.get("iconPath", "")))
		if texture != null:
			draw_texture_rect(texture, Rect2(Vector2(center_x - 34.0, rect.position.y + 76.0), Vector2(68.0, 68.0)), false)
		elif not EquipmentSystem.is_instant(gift):
			var fallback_icon: String = DrawDataSystemScript.equipment_icon(String(gift.get("id", "")), EquipmentSystem.is_weapon(gift))
			_draw_centered_card_text(fallback_icon, center_x, rect.position.y + 110.0, rect.size.x - 28.0, 34, Color("#e73763"))
		_draw_gift_card_name(display_name, center_x, rect.position.y + 160.0, rect.size.x - 24.0, text_color)
		var level_y: float = rect.position.y + 196.0
		var level_text: String = GiftSystemScript.gift_level_change_text(gift, gift_level)
		var level_color: Color = quality_color if quality != "normal" else Color("#273247")
		_draw_centered_card_text_with_outline(level_text, center_x, level_y, rect.size.x - 26.0, 20, level_color, Color(1.0, 1.0, 1.0, 0.94))
		var summary_lines: Array[String] = _split_card_text(GiftSystemScript.gift_card_summary(gift), 10)
		var summary_y: float = rect.position.y + 226.0
		for line in summary_lines.slice(0, 2):
			_draw_centered_card_text(String(line), center_x, summary_y, rect.size.x - 28.0, 16, sub_color)
			summary_y += 20.0
		_draw_centered_card_text(GiftSystemScript.gift_level_status_text(gift, gift_level), center_x, rect.position.y + 259.0, rect.size.x - 28.0, 15, Color("#6b7280"))

func _gift_choice_category_tag_rect(rect: Rect2) -> Rect2:
	return Rect2(rect.position + Vector2(16.0, 54.0), Vector2(54.0, 24.0))

func _three_choice_number_badge_rect(rect: Rect2) -> Rect2:
	return Rect2(rect.position + Vector2(rect.size.x * 0.5 - 16.0, 18.0), Vector2(32.0, 24.0))

func _draw_three_choice_number_badge(badge_rect: Rect2, number: int, accent: Color = Color("#ff9bcf")) -> void:
	_draw_ranking_panel(badge_rect, Color(1.0, 0.96, 0.99, 0.94), accent, 9, 1, false)
	_draw_text_item({
		"pos": badge_rect.position + Vector2(0.0, 17.0),
		"text": str(number),
		"width": int(badge_rect.size.x),
		"size": 15,
		"color": Color("#7b405e"),
		"fontWeight": "black"
	}, "", HORIZONTAL_ALIGNMENT_CENTER)

func _draw_gift_quality_stamp(rect: Rect2, label: String, quality: String) -> void:
	var stamp_texture: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, _gift_quality_stamp_image_path(quality))
	if stamp_texture != null:
		var image_rect: Rect2 = _gift_quality_stamp_image_rect(rect, quality)
		var fitted_rect: Rect2 = _fit_texture_rect(image_rect, stamp_texture.get_size())
		_draw_rotated_texture(stamp_texture, fitted_rect.position + fitted_rect.size * 0.5, fitted_rect.size, _gift_quality_stamp_angle(quality), 0.98)
		return
	var stamp_size: Vector2 = Vector2(82.0, 34.0)
	if quality == "big_hit":
		stamp_size = Vector2(92.0, 38.0)
	elif quality == "evolution":
		stamp_size = Vector2(78.0, 34.0)
	var stamp_rect: Rect2 = Rect2(rect.position + Vector2(-10.0, -5.0), stamp_size)
	var fill: Color = Color(1.0, 0.94, 0.78, 0.94)
	var border: Color = Color("#ffb84d")
	var text_color: Color = Color("#a85400")
	if quality == "big_hit":
		fill = Color(1.0, 0.84, 0.93, 0.96)
		border = Color("#ff5fb8")
		text_color = Color("#b01868")
	elif quality == "evolution":
		fill = Color(0.98, 0.88, 1.0, 0.96)
		border = Color("#ff68b3")
		text_color = Color("#9333a4")
	draw_rect(stamp_rect, fill)
	draw_rect(stamp_rect, border, false, 2.0)
	var lines: PackedStringArray = label.split("\n", false)
	var text_y: float = stamp_rect.position.y + (6.0 if lines.size() >= 2 else 8.0)
	for line in lines:
		_draw_centered_card_text(String(line), stamp_rect.position.x + stamp_rect.size.x * 0.5, text_y, stamp_rect.size.x - 8.0, 14 if lines.size() >= 2 else 16, text_color)
		text_y += 17.0
	if quality == "big_hit":
		_draw_centered_card_text("★", stamp_rect.position.x + 8.0, stamp_rect.position.y - 3.0, 18.0, 15, Color("#ffd84d"))
		_draw_centered_card_text("★", stamp_rect.position.x + stamp_rect.size.x - 8.0, stamp_rect.position.y + stamp_rect.size.y - 15.0, 18.0, 15, Color("#ffd84d"))

func _gift_quality_stamp_image_path(quality: String) -> String:
	if quality == "big_hit":
		return GIFT_STAMP_BIG_HIT_IMAGE
	if quality == "hit":
		return GIFT_STAMP_HIT_IMAGE
	if quality == "evolution":
		return GIFT_STAMP_EVOLUTION_IMAGE
	return ""

func _gift_quality_stamp_image_rect(rect: Rect2, quality: String) -> Rect2:
	if quality == "big_hit":
		return Rect2(rect.position + Vector2(-2.0, -34.0), Vector2(92.0, 92.0))
	if quality == "evolution":
		return Rect2(rect.position + Vector2(-6.0, -40.0), Vector2(100.0, 100.0))
	return Rect2(rect.position + Vector2(0.0, -31.0), Vector2(84.0, 84.0))

func _gift_quality_stamp_angle(quality: String) -> float:
	if quality == "big_hit":
		return -0.08
	if quality == "evolution":
		return -0.07
	return -0.09

func _draw_gift_category_tag(tag_rect: Rect2, category: String) -> void:
	var border: Color = Color("#ff9bcf")
	var fill: Color = Color(1.0, 0.93, 0.97, 0.90)
	if category == "武器":
		border = Color("#ffd84d")
		fill = Color(1.0, 0.97, 0.78, 0.90)
	elif category == "アクセ":
		border = Color("#70e4f2")
		fill = Color(0.88, 1.0, 1.0, 0.90)
	elif category == "進化":
		border = Color("#ff68b3")
		fill = Color(1.0, 0.89, 0.97, 0.92)
	elif category == "回復":
		border = Color("#64d987")
		fill = Color(0.90, 1.0, 0.92, 0.90)
	draw_rect(tag_rect, fill)
	draw_rect(tag_rect, border, false, 1.6)
	_draw_centered_card_text(category, tag_rect.position.x + tag_rect.size.x * 0.5, tag_rect.position.y + 17.0, tag_rect.size.x - 8.0, 13, Color("#4b3142"))

func _draw_gift_choice_cursor(rect: Rect2) -> void:
	var cursor_rect: Rect2 = rect.grow(1.0)
	draw_rect(cursor_rect.grow(6.0), Color(1.0, 0.45, 0.72, 0.18))
	draw_rect(cursor_rect, Color("#ff7ab8"), false, 4.0)

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
		_draw_three_choice_number_badge(_three_choice_number_badge_rect(rect), i + 1, _comment_choice_badge_accent(risk))
		var comment_id: String = String(comment.get("id", ""))
		var icon: Texture2D = _load_instruction_comment_icon(comment_id)
		var icon_rect: Rect2 = Rect2()
		if icon != null:
			icon_rect = _instruction_comment_icon_rect(rect, center_x, comment_id)
			_draw_instruction_comment_icon_backdrop(rect, icon_rect, risk)
		var title_lines: Array[String] = _split_card_text(String(view["displayName"]) if view.has("displayName") else "", 8)
		var title_y: float = rect.position.y + 66.0
		for line in title_lines.slice(0, 2):
			_draw_centered_card_text(String(line), center_x, title_y, rect.size.x - 34.0, 27, title_color)
			title_y += 32.0
		var desc_lines: Array[String] = _split_card_text(String(view["description"]) if view.has("description") else "", 9)
		if icon != null:
			_draw_instruction_comment_icon(icon, icon_rect, comment_id)
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
		_draw_centered_card_text("倍率 x%.1f" % [multiplier], center_x, rect.position.y + 270.0, rect.size.x - 42.0, 22, metric_color)
		_draw_centered_card_text("ギフト期待 +%d" % [gift_hype_on_select], center_x, rect.position.y + 299.0, rect.size.x - 42.0, 18, Color("#ffd46a"))
	if _comment_choice_has_special_card():
		var special_comment: Dictionary = offered_comments[3] as Dictionary
		var special_heart: bool = 3 < heart_cards.size() and bool(heart_cards[3])
		var special_view: Dictionary = CommentSystemScript.comment_view(special_comment, special_heart)
		var special_rect: Rect2 = _comment_choice_special_card_rect()
		if selected_card == 3:
			_draw_comment_choice_cursor(special_rect, int(special_view.get("riskLevel", 5)))
		_draw_do_everything_special_card(special_rect, special_view)
	_draw_comment_choice_footer()

func _draw_do_everything_special_card(rect: Rect2, view: Dictionary) -> void:
	draw_rect(rect, Color(1.0, 0.92, 0.98, 0.97), true)
	_draw_rect_outline(rect, Color("#ffe45c"), 4)
	draw_rect(Rect2(rect.position, Vector2(166.0, rect.size.y)), Color("#ff4c9a"), true)
	_draw_text_item({"pos": rect.position + Vector2(20.0, 42.0), "text": "[4] SPECIAL", "width": 140, "size": 23, "color": Color.WHITE})
	var name: String = String(view.get("displayName", "SPECIAL"))
	_draw_text_item({"pos": rect.position + Vector2(188.0, 44.0), "text": name, "width": 230, "size": 31, "color": Color("#e73763")})
	_draw_text_item({"pos": rect.position + Vector2(422.0, 40.0), "text": "上の3つを全部発動", "width": 210, "size": 22, "color": Color("#5b2a4c")})
	_draw_text_item({"pos": rect.position + Vector2(638.0, 40.0), "text": "x%.1f / +%d" % [float(view.get("multiplier", 5.0)), int(view.get("giftHypeOnSelect", 70))], "width": 150, "size": 24, "color": Color("#ff8a36")})

func _draw_comment_choice_cursor(rect: Rect2, risk: int) -> void:
	var color: Color = _comment_choice_badge_accent(risk)
	draw_rect(rect.grow(5.0), Color(color.r, color.g, color.b, 0.15))
	draw_rect(rect.grow(1.0), color, false, 4.0)

func _comment_choice_badge_accent(risk: int) -> Color:
	if risk >= 4:
		return Color("#ffe45c")
	if risk >= 3:
		return Color("#ff783a")
	return Color("#8df7ff")

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
	elif comment_id == "takeback":
		path = "res://assets/generated/instruction_comment_icons_v1/takeback_icon.png"
	elif comment_id == "attack_right_only":
		path = "res://assets/generated/instruction_comment_icons_v1/attack_right_only_icon.png"
	elif comment_id == "weapon_mute":
		path = "res://assets/generated/instruction_comment_icons_v1/weapon_mute_icon.png"
	elif comment_id == "temp_walls":
		path = "res://assets/generated/instruction_comment_icons_v1/temp_walls_icon.png"
	elif comment_id == "damage_pits":
		path = "res://assets/generated/instruction_comment_icons_v1/damage_pits_icon.png"
	elif comment_id == "hide_hp":
		path = "res://assets/generated/instruction_comment_icons_v1/hide_hp_icon.png"
	elif comment_id == "comment_barrage":
		path = "res://assets/generated/instruction_comment_icons_v1/comment_barrage_icon.png"
	elif comment_id == "kamiyoyaku":
		path = "res://assets/generated/instruction_comment_icons_v1/kamiyoyaku_icon.png"
	elif comment_id == "camera_zoom":
		path = "res://assets/generated/instruction_comment_icons_v1/camera_zoom_icon.png"
	elif comment_id == "summon_boss":
		path = "res://assets/generated/instruction_comment_icons_v1/summon_boss_icon.png"
	if path == "":
		return null
	return TextureCacheSystemScript.load_png_texture(equipment_icon_cache, path)

func _instruction_comment_icon_rect(card_rect: Rect2, center_x: float, comment_id: String) -> Rect2:
	var icon_size: Vector2 = Vector2(118.0, 118.0)
	var y_offset: float = 96.0
	if comment_id == "split_enemy":
		icon_size = Vector2(162.0, 126.0)
		y_offset = 88.0
	elif comment_id == "reverse_control":
		icon_size = Vector2(144.0, 136.0)
		y_offset = 86.0
	elif comment_id == "short_range":
		icon_size = Vector2(148.0, 148.0)
		y_offset = 82.0
	elif comment_id == "takeback" or comment_id == "kamiyoyaku":
		icon_size = Vector2(136.0, 136.0)
		y_offset = 88.0
	return Rect2(Vector2(center_x - icon_size.x * 0.5, card_rect.position.y + y_offset), icon_size)

func _draw_instruction_comment_icon_backdrop(card_rect: Rect2, icon_rect: Rect2, risk: int) -> void:
	var backdrop_rect: Rect2 = icon_rect.grow_individual(16.0, 12.0, 16.0, 8.0)
	var min_y: float = card_rect.position.y + 76.0
	var max_bottom: float = card_rect.position.y + 230.0
	backdrop_rect.position.y = maxf(backdrop_rect.position.y, min_y)
	backdrop_rect.size.y = maxf(78.0, minf(backdrop_rect.end.y, max_bottom) - backdrop_rect.position.y)
	var accent: Color = _comment_choice_badge_accent(risk)
	var fill_color: Color = Color(1.0, 0.92, 0.965, 0.18)
	var border_color: Color = Color(accent.r, accent.g, accent.b, 0.18)
	_draw_ranking_panel(backdrop_rect, fill_color, border_color, 20, 1, false)

func _draw_instruction_comment_icon(icon: Texture2D, icon_rect: Rect2, comment_id: String) -> void:
	if comment_id == "split_enemy":
		var tex_size: Vector2 = icon.get_size()
		var source_rect: Rect2 = Rect2(Vector2(tex_size.x * 0.03, tex_size.y * 0.30), Vector2(tex_size.x * 0.94, tex_size.y * 0.45))
		var fitted_rect: Rect2 = _fit_texture_rect(icon_rect, source_rect.size)
		draw_texture_rect_region(icon, fitted_rect, source_rect)
		return
	var fitted_icon_rect: Rect2 = _fit_texture_rect(icon_rect, icon.get_size())
	if comment_id == "no_dash" or comment_id == "no_brake":
		draw_texture_rect(icon, fitted_icon_rect, false, Color(0.95, 0.90, 0.90, 0.98))
		draw_texture_rect(icon, fitted_icon_rect, false, Color(0.15, 0.03, 0.04, 0.08))
		return
	draw_texture_rect(icon, fitted_icon_rect, false)

func _draw_comment_choice_alert_overlay() -> void:
	var ui_time: float = float(Time.get_ticks_msec()) / 1000.0
	var pulse: float = 0.5 + sin(ui_time * 9.0) * 0.5
	var panel_rect: Rect2 = Rect2(Vector2(270.0, 145.0) + _comment_choice_drop_offset(), Vector2(930.0, 560.0))
	draw_rect(panel_rect, Color(1.0, 0.0, 0.0, 0.03 + pulse * 0.16))
	draw_rect(panel_rect.grow(-5.0), Color(1.0, 0.06, 0.02, 0.12 + pulse * 0.50), false, 7.0)
	draw_rect(panel_rect.grow(-13.0), Color(1.0, 0.12, 0.04, 0.05 + pulse * 0.20), false, 3.0)

func _draw_comment_choice_footer() -> void:
	if _comment_choice_has_special_card():
		return
	var footer_rect: Rect2 = Rect2(Vector2(530.0, 654.0) + _comment_choice_drop_offset(), Vector2(410.0, 32.0))
	var remain: float = maxf(0.0, choice_timer)
	var border_color: Color = Color("#ff9bcf")
	var fill_color: Color = Color(1.0, 0.94, 0.985, 0.94)
	var text_color: Color = Color("#7b405e")
	if choice_timer <= 5.0:
		border_color = Color("#ff4f78")
		fill_color = Color(1.0, 0.90, 0.96, 0.96)
		text_color = Color("#d9315f")
	_draw_ranking_panel(footer_rect, fill_color, border_color, 12, 2, false)
	_draw_centered_card_text("自動選択まで %.1fs　　1 / 2 / 3 で選択" % [remain], footer_rect.position.x + footer_rect.size.x * 0.5, footer_rect.position.y + 21.0, footer_rect.size.x - 18.0, 19, text_color)

func _draw_gift_card_name(display_name: String, center_x: float, y: float, width: float, color: Color) -> void:
	var text_length: int = display_name.length()
	if text_length <= 12:
		var font_size: int = 20
		if text_length >= 9:
			font_size = 18
		if text_length >= 11:
			font_size = 17
		_draw_centered_card_text(display_name, center_x, y, width, font_size, color)
		return
	var name_lines: Array[String] = _split_card_text(display_name, 9)
	var line_y: float = y - 9.0
	for line in name_lines.slice(0, 2):
		_draw_centered_card_text(String(line), center_x, line_y, width, 18, color)
		line_y += 20.0

func _draw_centered_card_text(text: String, center_x: float, y: float, width: float, size: int, color: Color) -> void:
	_draw_text_item({
		"pos": Vector2(center_x - width * 0.5, y),
		"text": text,
		"width": width,
		"size": size,
		"color": color
	}, "", HORIZONTAL_ALIGNMENT_CENTER)

func _draw_centered_card_text_with_outline(text: String, center_x: float, y: float, width: float, size: int, color: Color, outline_color: Color) -> void:
	var pos := Vector2(center_x - width * 0.5, y)
	var offsets: Array[Vector2] = [
		Vector2(-1.2, 0.0),
		Vector2(1.2, 0.0),
		Vector2(0.0, -1.2),
		Vector2(0.0, 1.2),
		Vector2(-0.9, -0.9),
		Vector2(0.9, -0.9),
		Vector2(-0.9, 0.9),
		Vector2(0.9, 0.9)
	]
	for offset in offsets:
		_draw_text_item({
			"pos": pos + offset,
			"text": text,
			"width": width,
			"size": size,
			"color": outline_color,
			"fontWeight": "black"
		}, "", HORIZONTAL_ALIGNMENT_CENTER)
	_draw_text_item({
		"pos": pos,
		"text": text,
		"width": width,
		"size": size,
		"color": color,
		"fontWeight": "black"
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
	_reset_world_transform()
	var samples: Array[String] = DisplayTextSystemScript.comment_storm_samples()
	for item in DrawDataSystemScript.comment_storm_draw_data(FIELD_VIEW, elapsed, comment_barrage_setting, kuso_chat_timer > 0.0, samples):
		var data: Dictionary = item as Dictionary
		var shadow: Dictionary = data.duplicate()
		var color: Color = data["color"] as Color
		shadow["pos"] = (data["pos"] as Vector2) + Vector2(2.0, 2.0)
		shadow["color"] = Color(0.04, 0.02, 0.08, minf(0.70, color.a * 0.78))
		_draw_text_item(shadow)
		_draw_text_item(data)
	_reset_world_transform()

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
