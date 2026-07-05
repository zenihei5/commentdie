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
const GAMEPLAY_FRAME_BGM_VOLUME_SCALE := 0.82
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
const STARLIGHT_SUPERCHAT_DEFEAT_SE_PATH := "res://assets/audio/starlight_superchat_defeat.mp3"
const SPOTLIGHT_ATTACK_SE_PATH := "res://assets/audio/spotlight_attack.mp3"
const SONG_PENLIGHT_BIT_ATTACK_SE_PATH := "res://assets/audio/song_penlight_bit_attack.mp3"
const SONG_AUDIENCE_CALL_WAVE_SE_PATH := "res://assets/audio/song_audience_call_wave.mp3"
const SONG_SPOTLIGHT_BENEFIT_SE_PATH := "res://assets/audio/song_spotlight_benefit.mp3"
const SONG_LYRICS_CARD_PICKUP_SE_PATH := "res://assets/audio/song_lyrics_card_pickup.mp3"
const KUSA_WAVE_SHOT_SE_PATH := "res://assets/audio/kusa_wave_shot.mp3"
const COMMENT_PIN_THROW_SE_PATH := "res://assets/audio/comment_pin_throw.mp3"
const COMMENT_BOOMERANG_SWING_SE_PATH := "res://assets/audio/comment_boomerang_swing.mp3"
const LISTENER_ATTACK_SE_PATH := "res://assets/audio/listener_attack.mp3"
const MARSHMALLOW_PICKUP_SE_PATH := "res://assets/audio/marshmallow_pickup.mp3"
const KUSO_MARSHMALLOW_PICKUP_SE_PATH := "res://assets/audio/kuso_marshmallow_pickup.mp3"
const GOD_MARSHMALLOW_PICKUP_SE_PATH := "res://assets/audio/god_marshmallow_pickup.mp3"
const EXP_PICKUP_SE_PATH := "res://assets/audio/exp_pickup.mp3"
const GIFT_BOX_ITEM_PICKUP_SE_PATH := "res://assets/audio/gift_box_item_pickup.mp3"
const GENRE_RACE_COIN_PICKUP_SE_PATH := "res://assets/audio/genre_race_coin_pickup.mp3"
const GENRE_RACE_DASH_PAD_SE_PATH := "res://assets/audio/genre_race_dash_pad.mp3"
const LEVEL_UP_SE_PATH := "res://assets/audio/level_up.mp3"
const PLAYER_DAMAGE_SE_PATH := "res://assets/audio/player_damage.mp3"
const MENTAL_BREAKDOWN_SE_PATH := "res://assets/audio/mental_breakdown.mp3"
const STREAM_COMPLETE_CLEAR_SE_PATH := "res://assets/audio/stream_complete_clear.mp3"
const STREAM_END_WHISTLE_SE_PATH := "res://assets/audio/stream_end_whistle.mp3"
const STREAM_START_READY_SE_PATH := "res://assets/audio/stream_start_ready.mp3"
const LIVE_START_SE_PATH := "res://assets/audio/live_start_air_horn.mp3"
const BOSS_WARNING_SE_PATH := "res://assets/audio/boss_warning.mp3"
const ENEMY_DAMAGE_SE_PATH := "res://assets/audio/enemy_damage.mp3"
const ENEMY_DEFEAT_SE_PATH := "res://assets/audio/enemy_defeat.mp3"
const EMOTE_MINE_PLACE_SE_PATH := "res://assets/audio/emote_mine_place.mp3"
const EMOTE_MINE_EXPLOSION_SE_PATH := "res://assets/audio/emote_mine_explosion.mp3"
const SONG_SCALE_NOTE_SE_PATHS := [
	"res://assets/audio/song_scale_do1.mp3",
	"res://assets/audio/song_scale_re.mp3",
	"res://assets/audio/song_scale_mi.mp3",
	"res://assets/audio/song_scale_fa.mp3",
	"res://assets/audio/song_scale_so.mp3",
	"res://assets/audio/song_scale_la.mp3",
	"res://assets/audio/song_scale_si.mp3",
	"res://assets/audio/song_scale_do2.mp3"
]
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
const GENRE_CHANGE_BANNER_RACE_IMAGE := "res://assets/generated/genre_change_banners_v1/genre_change_banner_race.png"
const GENRE_CHANGE_BANNER_BULLET_HELL_IMAGE := "res://assets/generated/genre_change_banners_v1/genre_change_banner_bullet_hell.png"
const GENRE_CHANGE_BANNER_HORROR_IMAGE := "res://assets/generated/genre_change_banners_v1/genre_change_banner_horror.png"
const GENRE_EVENT_DASH_PAD_IMAGE := "res://assets/generated/gameplay_event_objects_v1/dash_pad.png"
const GENRE_EVENT_COIN_IMAGE := "res://assets/generated/gameplay_event_objects_v1/coin.png"
const GENRE_EVENT_STG_PLAYER_OVERLAY_IMAGE := "res://assets/generated/gameplay_event_objects_v1/stg_player_overlay.png"
const GENRE_EVENT_FAKE_GIFT_IMAGE := "res://assets/generated/gameplay_event_objects_v1/fake_gift_box.png"
const SONG_NOTE_ORB_IMAGES := [
	"res://assets/generated/song_note_orbs_v1/song_note_orb_1.png",
	"res://assets/generated/song_note_orbs_v1/song_note_orb_2.png",
	"res://assets/generated/song_note_orbs_v1/song_note_orb_3.png",
]
const SONG_PENLIGHT_BIT_IMAGES := [
	"res://assets/generated/song_penlight_bits_v1/penlight_bit_blue.png",
	"res://assets/generated/song_penlight_bits_v1/penlight_bit_pink.png",
]
const SONG_LIVE_GIFT_IMAGE := "res://assets/generated/song_live_gifts_v1/live_gift.png"
const SONG_SPECIAL_LIVE_GIFT_IMAGE := "res://assets/generated/song_live_gifts_v1/special_live_gift.png"
const SONG_LYRICS_CARD_IMAGE := "res://assets/generated/song_lyrics_card_v1/lyrics_card.png"
const SONG_LIVE_HEAT_HUD_IMAGE := "res://assets/generated/song_live_heat_hud_v1/live_heat_panel.png"
const SONG_SPOTLIGHT_FLOOR_ACTIVE_IMAGE := "res://assets/generated/song_spotlight_floor_v1/spotlight_floor_active.png"
const SONG_SPOTLIGHT_FLOOR_OCCUPIED_IMAGE := "res://assets/generated/song_spotlight_floor_v1/spotlight_floor_occupied.png"
const SONG_SPOTLIGHT_FLOOR_EXPIRING_IMAGE := "res://assets/generated/song_spotlight_floor_v1/spotlight_floor_expiring.png"
const SONG_SPOTLIGHT_SPARKLE_PARTICLES_IMAGE := "res://assets/generated/song_spotlight_floor_v1/spotlight_sparkle_particles.png"
const GENRE_RESULT_CARD_DURATION := 1.55
const SONG_CHORUS_FIRST_DELAY := 30.0
const SONG_CHORUS_INTERVAL_MIN := 38.0
const SONG_CHORUS_INTERVAL_MAX := 48.0
const SONG_CHORUS_TELEGRAPH_DURATION := 1.5
const SONG_CHORUS_DURATION := 12.0
const SONG_CHORUS_BANNER_DURATION := 1.5
const SONG_CHORUS_RESULT_CARD_DURATION := 1.55
const SONG_NOTE_COUNT_MIN := 9
const SONG_NOTE_COUNT_MAX := 15
const SONG_SCALE_NOTE_COUNT := 8
const SONG_SCALE_NOTE_QUEUE_INTERVAL := 0.075
const SONG_AMBIENT_NOTE_INTERVAL_MIN := 9.0
const SONG_AMBIENT_NOTE_INTERVAL_MAX := 14.0
const SONG_AMBIENT_NOTE_LIFETIME := 16.0
const SONG_LIVE_GIFT_LIFETIME := 18.0
const SONG_NOTE_OBSTACLE_CLEARANCE := 80.0
const SONG_SPOTLIGHT_OBSTACLE_CLEARANCE := 160.0
const SONG_LYRICS_CARD_OBSTACLE_CLEARANCE := 80.0
const SONG_LIVE_HEAT_LEVEL_NOTICE_DURATION := 2.0
const SONG_NOTICE_STACK_BASE_TOP := 82.0
const SONG_NOTICE_STACK_RESULT_TOP := 134.0
const SONG_NOTICE_STACK_CHORUS_TOP := 154.0
const SONG_NOTICE_STACK_LANE_GAP := 132.0
const SONG_LIVE_HEAT_LV1_MOVE_RATE := 1.05
const SONG_LIVE_HEAT_LV1_PICKUP_RATE := 1.10
const SONG_LIVE_HEAT_LV5_MOVE_RATE := 1.08
const SONG_LIVE_HEAT_LV5_PICKUP_RATE := 1.25
const SONG_LIVE_HEAT_LV4_DAMAGE_RATE := 0.90
const SONG_LIVE_HEAT_LV4_COOLDOWN_RATE := 0.95
const SONG_LIVE_HEAT_LV5_COOLDOWN_RATE := 0.92
const SONG_PENLIGHT_BIT_COUNT := 2
const SONG_PENLIGHT_BIT_SHOT_INTERVAL := 2.5
const SONG_PENLIGHT_BIT_SHOT_DAMAGE := 3.0
const SONG_PENLIGHT_BIT_SHOT_RANGE := 460.0
const SONG_PENLIGHT_BIT_SHOT_KNOCKBACK := 36.0
const SONG_NOTE_EXTRA_SHOT_DAMAGE := 2.5
const SONG_NOTE_EXTRA_SHOT_RANGE := 360.0
const SONG_HARMONY_WAVE_INTERVAL := 6.0
const SONG_HARMONY_WAVE_RADIUS := 180.0
const SONG_HARMONY_WAVE_DAMAGE := 5.0
const SONG_HARMONY_WAVE_KNOCKBACK := 48.0
const SONG_AUDIENCE_CALL_WAVE_INTERVAL := 8.0
const SONG_AUDIENCE_CALL_WAVE_WIDTH := 220.0
const SONG_AUDIENCE_CALL_WAVE_DURATION := 1.05
const SONG_AUDIENCE_CALL_WAVE_DAMAGE := 5.0
const SONG_AUDIENCE_CALL_WAVE_KNOCKBACK := 90.0
const SONG_MAX_OCTAVE_AUDIENCE_CALL_WAVE_COOLDOWN := 2.0
const SONG_NOTE_VOLTAGE_GAIN := 0.08
const SONG_NOTE_VIEWER_GAIN := 120
const SONG_OCTAVE_BONUS_LIVE_HEAT_GAIN := 5.0
const SONG_OCTAVE_BONUS_VIEWER_GAIN := 500
const SONG_OCTAVE_BONUS_GIFT_HYPE_GAIN := 1
const SONG_OCTAVE_BONUS_RADIUS := 150.0
const SONG_OCTAVE_BONUS_DAMAGE := 0.8
const SONG_OCTAVE_BONUS_KNOCKBACK := 0.3
const SONG_OCTAVE_BONUS_NOTICE_DURATION := 1.75
const SONG_SPOTLIGHT_COUNT_MIN := 2
const SONG_SPOTLIGHT_COUNT_MAX := 3
const SONG_SPOTLIGHT_DURATION := 6.0
const SONG_SPOTLIGHT_RADIUS := 140.0
const SONG_SPOTLIGHT_VOLTAGE_RATE := 0.026
const SONG_SPOTLIGHT_VIEWER_GAIN_PER_SECOND := 24.0
const SONG_SPOTLIGHT_BENEFIT_SE_INTERVAL := 1.15
const SONG_CHORUS_EXTRA_ENEMY_INTERVAL_MIN := 3.2
const SONG_CHORUS_EXTRA_ENEMY_INTERVAL_MAX := 4.2
const SONG_LIVE_HEAT_MAX := 100.0
const SONG_LIVE_HEAT_NOTE_GAIN := 2.2
const SONG_LIVE_HEAT_CHORUS_NOTE_GAIN := 2.8
const SONG_LIVE_HEAT_SPOTLIGHT_GAIN_PER_SECOND := 0.8
const SONG_LIVE_HEAT_ENEMY_SMALL_GAIN := 0.15
const SONG_LIVE_HEAT_ENEMY_MEDIUM_GAIN := 0.5
const SONG_LIVE_HEAT_ENEMY_LARGE_GAIN := 1.2
const SONG_LIVE_HEAT_CHORUS_FINISH_GAIN := 3.0
const SONG_LIVE_HEAT_CHORUS_GOOD_GAIN := 5.0
const SONG_LIVE_HEAT_NO_DAMAGE_STREAK_GAIN := 1.0
const SONG_NO_DAMAGE_STREAK_INTERVAL := 12.0
const SONG_CHORUS_LIVE_HEAT_MULTIPLIER := 1.4
const SONG_CHORUS_VOLTAGE_GAIN_MULTIPLIER := 1.25
const SONG_CHORUS_VIEWER_GAIN_MULTIPLIER := 1.2
const SONG_PITCH_WAVE_TELEGRAPH_DURATION := 0.7
const SONG_PITCH_WAVE_ACTIVE_DURATION := 0.4
const SONG_PITCH_WAVE_DAMAGE := 12
const SONG_PITCH_WAVE_WIDTH := 165.0
const SONG_HOWLING_EMITTER_COUNT := 2
const SONG_HOWLING_WAVE_INTERVAL := 2.8
const SONG_HOWLING_TELEGRAPH_DURATION := 0.45
const SONG_HOWLING_WAVE_EXPAND_DURATION := 0.75
const SONG_HOWLING_WAVE_START_RADIUS := 30.0
const SONG_HOWLING_WAVE_END_RADIUS := 260.0
const SONG_HOWLING_WAVE_THICKNESS := 34.0
const SONG_HOWLING_DAMAGE := 12
const SONG_HOWLING_PLAYER_KNOCKBACK := 170.0
const SONG_HOWLING_SPEAKER_IMAGE := "res://assets/generated/song_howling_props_v1/howling_speaker.png"
const SONG_BAD_LIGHT_COUNT := 2
const SONG_BAD_LIGHT_RADIUS := 135.0
const SONG_BAD_LIGHT_LIFETIME := 3.0
const SONG_BAD_LIGHT_RESPAWN_DELAY := 0.4
const SONG_BAD_LIGHT_DISABLE_NORMAL_WEAPONS := true
const SONG_BAD_LIGHT_DISABLE_LIVE_HEAT_SUPPORT := false
const SONG_LYRICS_CARD_LIFETIME := 15.0
const SONG_LYRICS_CARD_PICKUP_RADIUS := 48.0
const SONG_LYRICS_CARD_MIN_DISTANCE := 420.0
const SONG_LYRICS_CARD_MAX_DISTANCE := 760.0
const SONG_ENCORE_TRIGGER_REMAINING := 30.0
const SONG_ENCORE_DURATION := 15.0
const SONG_ENCORE_LIVE_HEAT_MULTIPLIER := 1.4
const SONG_ENCORE_VIEWER_GAIN_MULTIPLIER := 1.35
const SONG_ENCORE_VOLTAGE_GAIN_MULTIPLIER := 1.35
const SONG_ENCORE_CLEAR_BONUS_MULTIPLIER := 1.1
const DRAWING_PAINT_COLOR_IDS := ["pink", "cyan"]
const DRAWING_PAINT_DURATION := 8.0
const DRAWING_PAINT_ORB_INTERVAL_MIN := 7.0
const DRAWING_PAINT_ORB_INTERVAL_MAX := 11.0
const DRAWING_PAINT_ORB_LIFETIME := 18.0
const DRAWING_PAINT_ORB_MAX := 5
const DRAWING_PAINT_ORB_RADIUS := 28.0
const DRAWING_TRAIL_LIFETIME := 12.0
const DRAWING_TRAIL_WIDTH := 56.0
const DRAWING_TRAIL_STAMP_INTERVAL := 0.08
const DRAWING_TRAIL_MIN_DISTANCE := 14.0
const DRAWING_TRAIL_MAX_SAMPLES := 230
const DRAWING_CELL_SIZE := 32.0
const DRAWING_MIN_FILL_CELLS := 12
const DRAWING_MAX_FILL_CELLS := 180
const DRAWING_MAX_ACTIVE_REGIONS := 3
const DRAWING_REGION_LIFETIME := 10.0
const DRAWING_REGION_TICK_INTERVAL := 0.5
const DRAWING_PINK_DAMAGE_PER_TICK := 0.8
const DRAWING_CYAN_SLOW_RATE := 0.30
const DRAWING_CYAN_SLOW_TIMER := 0.85
const DRAWING_REGION_KNOCKBACK := 18.0
const DRAWING_CORRECTION_INTERVAL_MIN := 22.0
const DRAWING_CORRECTION_INTERVAL_MAX := 34.0
const DRAWING_CORRECTION_MAX := 2
const DRAWING_CORRECTION_RADIUS := 34.0
const DRAWING_CORRECTION_LIFETIME := 20.0
const DRAWING_CORRECTION_DIRECT_PAINT_TIME := 1.5
const DRAWING_CORRECTION_VIEWER_GAIN := 600
const DRAWING_CORRECTION_GIFT_HYPE_GAIN := 5
const DRAWING_CORRECTION_SPAWN_PAINT_ORB_CHANCE := 0.35
const DRAWING_CORRECTION_HEAL_MENTAL_CHANCE := 0.15
const DRAWING_CORRECTION_HEAL_AMOUNT := 5
const DRAWING_ERASER_INTERVAL_MIN := 35.0
const DRAWING_ERASER_INTERVAL_MAX := 50.0
const DRAWING_ERASER_LIFETIME := 16.0
const DRAWING_ERASER_RADIUS := 190.0
const DRAWING_ERASER_DAMAGE := 1.0
const DRAWING_ERASER_KNOCKBACK := 90.0
const DRAWING_PROGRESS_FILL_GAIN := 1.5
const DRAWING_PROGRESS_LARGE_FILL_BONUS := 2.0
const DRAWING_PROGRESS_LARGE_FILL_MIN_CELLS := 64
const DRAWING_PROGRESS_CORRECTION_GAIN := 5.0
const DRAWING_PROGRESS_ERASER_GAIN := 1.0
const DRAWING_PROGRESS_ENEMY_SMALL_GAIN := 0.25
const DRAWING_PROGRESS_ENEMY_MEDIUM_GAIN := 0.55
const DRAWING_PROGRESS_ENEMY_LARGE_GAIN := 1.0
const DRAWING_COMPLETE_VIEWER_REWARD := 1800
const DRAWING_COMPLETE_GIFT_HYPE_REWARD := 15
const DRAWING_FOCUS_SPOT_INTERVAL_MIN := 24.0
const DRAWING_FOCUS_SPOT_INTERVAL_MAX := 34.0
const DRAWING_FOCUS_SPOT_LIFETIME := 13.0
const DRAWING_FOCUS_SPOT_RADIUS := 118.0
const DRAWING_FOCUS_TRAIL_WIDTH_RATE := 1.16
const DRAWING_FOCUS_CORRECTION_SPEED_RATE := 1.25
const DRAWING_TOAST_DURATION := 1.45
const STREAM_START_INTRO_DURATION := 1.90
const STREAM_START_INTRO_SKIP_DELAY := 0.30
const STREAM_START_READY_TIME := 0.30
const STREAM_START_LIVE_START_TIME := 1.05
const GAME_OVER_INTRO_MENTAL_DURATION := 2.5
const GAME_OVER_INTRO_COMPLETE_DURATION := 2.8
const GAME_OVER_INTRO_SKIP_DELAY := 0.5
const STREAM_COMPLETE_CELEBRATION_DURATION := 1.85
const STREAM_COMPLETE_CRACKER_DURATION := 1.45
const MENTAL_BREAKDOWN_SHAKE_POWER := 0.35
const MENTAL_BREAKDOWN_SHAKE_DURATION := 0.22
const MENTAL_BREAKDOWN_FLASH_DURATION := 0.18
const MENTAL_BREAKDOWN_REACTION_DURATION := 1.10
const MENTAL_BREAKDOWN_BGM_FADE_DURATION := 2.20
const END_COUNTDOWN_START_SECONDS := 5
const END_COUNTDOWN_TOAST_SECONDS := 10.0
const STREAM_END_BANNER_DURATION := 0.72
const GENRE_CHANGE_BANNER_DURATION := 1.38
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
var comment_pools: Dictionary = {}
var stream_frame_progress: Dictionary = {}
var relay_mode_unlocked := false
var current_stream_frame: Dictionary = {}
var current_character: Dictionary = {}
var current_weapon: Dictionary = {}
var current_stream_frame_id := "zatsudan"
var cached_map_frame_id := ""
var cached_map_genre_event := ""
var cached_map_data: Dictionary = {}
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
var song_note_gray_texture_cache: Dictionary = {}
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
var boss_guide_lines: Array = []
var exp_orbs: Array = []
var player_bullets: Array = []
var boomerang_hits: Dictionary = {}
var equipment_weapon_timers: Dictionary = {}
var hit_fx: Array = []
var genre_change_banner_event := ""
var genre_change_banner_timer := 0.0
var song_chorus_next_time := SONG_CHORUS_FIRST_DELAY
var song_chorus_telegraph_timer := 0.0
var song_chorus_timer := 0.0
var song_chorus_banner_timer := 0.0
var song_chorus_result_timer := 0.0
var song_chorus_result_duration := SONG_CHORUS_RESULT_CARD_DURATION
var song_chorus_result_data: Dictionary = {}
var song_chorus_notes_collected := 0
var song_chorus_spotlight_time := 0.0
var song_chorus_enemy_spawn_timer := 0.0
var song_chorus_viewer_accum := 0.0
var song_chorus_current_duration := SONG_CHORUS_DURATION
var song_forced_chorus_active := false
var song_chorus_reward_multiplier := 1.0
var song_howling_emitters: Array = []
var song_howling_waves: Array = []
var song_bad_lights: Array = []
var song_bad_light_respawn_timer := 0.0
var song_bad_light_inside := false
var song_lyrics_cards: Array = []
var song_lyrics_card_locked_pos := Vector2.ZERO
var song_lyrics_card_has_locked_pos := false
var song_lyrics_lost_card_collected := false
var song_spotlight_inside_last_frame := false
var song_spotlight_benefit_se_cooldown := 0.0
var song_spotlight_benefit_flash_timer := 0.0
var song_notes: Array = []
var song_ambient_note_timer := SONG_AMBIENT_NOTE_INTERVAL_MIN
var song_spotlights: Array = []
var song_chorus_count := 0
var song_total_notes_collected := 0
var song_note_scale_index := 0
var song_note_total_collected := 0
var song_octave_bonus_count := 0
var song_scale_note_queue: Array = []
var song_scale_note_queue_timer := 0.0
var song_octave_bonus_notice_timer := 0.0
var song_octave_bonus_notice_duration := 0.0
var song_octave_bonus_notice_hits := 0
var song_octave_bonus_notice_call_wave := false
var song_total_spotlight_time := 0.0
var song_live_heat := 0.0
var song_live_heat_level := 0
var song_max_live_heat := 0.0
var song_max_live_heat_level := 0
var song_live_heat_level_flash_timer := 0.0
var song_live_heat_reward_claimed: Dictionary = {}
var song_live_heat_level_notice_queue: Array = []
var song_live_heat_level_notice_timer := 0.0
var song_live_heat_level_notice_duration := 0.0
var song_live_heat_level_notice_data: Dictionary = {}
var song_penlight_bit_shot_timer := 0.0
var song_harmony_wave_timer := 0.0
var song_audience_call_wave_timer := 0.0
var song_max_octave_audience_call_wave_cooldown := 0.0
var song_note_trail_timer := 0.0
var song_live_heat_fx: Array = []
var song_no_damage_streak_timer := 0.0
var song_pitch_wave_cooldown := 0.0
var song_pitch_waves: Array = []
var song_boss_chorus_judge_busy := false
var song_boss_chorus_judge_active := false
var song_boss_chorus_judge_required := 0
var song_boss_chorus_judge_collected := 0
var song_boss_chorus_judge_timer := 0.0
var song_boss_chorus_judge_duration := 0.0
var song_boss_chorus_judge_notice_timer := 0.0
var song_boss_chorus_judge_notice_duration := 0.0
var song_boss_chorus_judge_notice_title := ""
var song_boss_chorus_judge_notice_subtitle := ""
var song_boss_chorus_judge_notice_success := false
var song_boss_megaphone_waves: Array = []
var song_encore_timer := 0.0
var song_encore_triggered := false
var song_encore_completed := false
var song_encore_unlocked := false
var drawing_paint_orbs: Array = []
var drawing_paint_trails: Array = []
var drawing_paint_regions: Array = []
var drawing_correction_points: Array = []
var drawing_erasers: Array = []
var drawing_focus_spots: Array = []
var drawing_active_paint_color := ""
var drawing_active_paint_timer := 0.0
var drawing_orb_spawn_timer := 1.8
var drawing_correction_spawn_timer := 8.0
var drawing_eraser_spawn_timer := 15.0
var drawing_focus_spawn_timer := 6.0
var drawing_trail_stamp_timer := 0.0
var drawing_last_trail_stamp_pos := Vector2.ZERO
var drawing_has_last_trail_stamp := false
var drawing_focus_inside_last_frame := false
var drawing_next_region_id := 1
var drawing_progress := 0.0
var drawing_complete_reward_claimed := false
var drawing_fill_count := 0
var drawing_correction_complete_count := 0
var drawing_eraser_used_count := 0
var drawing_filled_cell_keys: Dictionary = {}
var drawing_toast_timer := 0.0
var drawing_toast_title := ""
var drawing_toast_subtitle := ""
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
var comment_storm_slot_texts: Array[String] = []
var comment_storm_slot_cycles: Array[int] = []
var comment_storm_sample_cursor := 0
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

const VIEWER_COUNTUP_CATCHUP_TIME := 0.65
const VIEWER_COUNTUP_MIN_RATE := 90.0
const VIEWER_COUNTUP_MAX_RATE := 5200.0
const MENTAL_GAUGE_DISPLAY_MIN_RATE := 0.65
const MENTAL_GAUGE_DISPLAY_CATCHUP_RATE := 7.0
const LIVE_HEAT_GAUGE_DISPLAY_MIN_RATE := 18.0
const LIVE_HEAT_GAUGE_DISPLAY_CATCHUP_RATE := 7.0

var score := 0
var displayed_viewer_score := 0
var displayed_viewer_score_remainder := 0.0
var viewer_score_countup_initialized := false
var displayed_mental_ratio := 1.0
var mental_gauge_display_initialized := false
var displayed_song_live_heat := 0.0
var song_live_heat_gauge_display_initialized := false
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
var pause_escape_release_blocked := false
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
var stream_end_banner_timer := 0.0
var stream_end_banner_duration := STREAM_END_BANNER_DURATION
var kuso_chat_timer := 0.0
var attack_jitter_timer := 0.0
var move_slow_timer := 0.0
var spawn_rate_timer := 0.0
var support_attack_timer := 0.0
var next_genre_event_time := GenreEventSystemScript.FIRST_GENRE_EVENT_TIME
var debug_rare_comment_boost := false
var genre_event_timer := 0.0
var genre_event_duration := GenreEventSystemScript.GENRE_EVENT_DURATION
var genre_event_source := ""
var active_genre_event := ""
var next_known_genre_event := ""
var genre_event_hurt := false
var genre_race_move_timer := 0.0
var genre_bullet_timer := 0.0
var genre_race_dash_pads: Array = []
var genre_race_coins: Array = []
var genre_horror_fake_gifts: Array = []
var genre_race_dash_boost_timer := 0.0
var genre_race_enemy_spawn_timer := 0.0
var genre_stg_shot_timer := 0.0
var genre_stg_spawn_timer := 0.0
var genre_stg_last_dir := Vector2.RIGHT
var genre_result_coin_count := 0
var genre_result_dash_pad_count := 0
var genre_event_start_kills := 0
var genre_result_stg_shot_kill_count := 0
var genre_result_fake_gift_defeat_count := 0
var genre_result_card_timer := 0.0
var genre_result_card_duration := GENRE_RESULT_CARD_DURATION
var genre_result_card_data: Dictionary = {}
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
var starlight_superchat_defeat_se_player: AudioStreamPlayer
var spotlight_attack_se_player: AudioStreamPlayer
var song_penlight_bit_attack_se_player: AudioStreamPlayer
var song_audience_call_wave_se_player: AudioStreamPlayer
var song_spotlight_benefit_se_player: AudioStreamPlayer
var song_lyrics_card_pickup_se_player: AudioStreamPlayer
var kusa_wave_se_player: AudioStreamPlayer
var comment_pin_se_player: AudioStreamPlayer
var comment_boomerang_se_player: AudioStreamPlayer
var listener_attack_se_player: AudioStreamPlayer
var marshmallow_pickup_se_player: AudioStreamPlayer
var kuso_marshmallow_pickup_se_player: AudioStreamPlayer
var god_marshmallow_pickup_se_player: AudioStreamPlayer
var exp_pickup_se_player: AudioStreamPlayer
var gift_box_item_pickup_se_player: AudioStreamPlayer
var genre_race_coin_pickup_se_player: AudioStreamPlayer
var genre_race_dash_pad_se_player: AudioStreamPlayer
var level_up_se_player: AudioStreamPlayer
var player_damage_se_player: AudioStreamPlayer
var mental_breakdown_se_player: AudioStreamPlayer
var stream_complete_clear_se_player: AudioStreamPlayer
var stream_end_whistle_se_player: AudioStreamPlayer
var stream_start_ready_se_player: AudioStreamPlayer
var live_start_se_player: AudioStreamPlayer
var boss_warning_se_player: AudioStreamPlayer
var enemy_damage_se_player: AudioStreamPlayer
var enemy_defeat_se_player: AudioStreamPlayer
var emote_mine_place_se_player: AudioStreamPlayer
var emote_mine_explosion_se_player: AudioStreamPlayer
var song_scale_note_se_player: AudioStreamPlayer
var song_scale_note_streams: Array = []
var enemy_damage_se_played_frame := -1
var listener_attack_se_played_frame := -1
var starlight_superchat_defeat_se_played_frame := -1
var stream_start_intro_timer := 0.0
var stream_start_intro_duration := STREAM_START_INTRO_DURATION
var stream_start_intro_skip_down := false
var stream_start_intro_ready_se_played := false
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
	_setup_starlight_superchat_defeat_se()
	_setup_spotlight_attack_se()
	_setup_song_penlight_bit_attack_se()
	_setup_song_audience_call_wave_se()
	_setup_song_spotlight_benefit_se()
	_setup_song_lyrics_card_pickup_se()
	_setup_kusa_wave_se()
	_setup_comment_pin_se()
	_setup_comment_boomerang_se()
	_setup_listener_attack_se()
	_setup_marshmallow_pickup_se()
	_setup_kuso_marshmallow_pickup_se()
	_setup_god_marshmallow_pickup_se()
	_setup_exp_pickup_se()
	_setup_gift_box_item_pickup_se()
	_setup_genre_race_coin_pickup_se()
	_setup_genre_race_dash_pad_se()
	_setup_level_up_se()
	_setup_player_damage_se()
	_setup_mental_breakdown_se()
	_setup_stream_complete_clear_se()
	_setup_stream_end_whistle_se()
	_setup_stream_start_ready_se()
	_setup_live_start_se()
	_setup_boss_warning_se()
	_setup_enemy_damage_se()
	_setup_enemy_defeat_se()
	_setup_emote_mine_place_se()
	_setup_emote_mine_explosion_se()
	_setup_song_scale_note_se()
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
	_update_viewer_score_countup(delta)
	_update_display_gauge_values(delta)
	_update_genre_change_banner(delta)
	_update_genre_result_card(delta)
	_update_song_chorus_overlay_timers(delta)
	_update_song_scale_note_se_queue(delta)
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

func _update_viewer_score_countup(delta: float) -> void:
	var target_score: int = maxi(0, score)
	if not viewer_score_countup_initialized:
		_sync_viewer_score_countup()
		return
	if target_score <= displayed_viewer_score:
		displayed_viewer_score = target_score
		displayed_viewer_score_remainder = 0.0
		return
	var diff: int = target_score - displayed_viewer_score
	var rate: float = clampf(float(diff) / VIEWER_COUNTUP_CATCHUP_TIME, VIEWER_COUNTUP_MIN_RATE, VIEWER_COUNTUP_MAX_RATE)
	displayed_viewer_score_remainder += rate * delta
	var step := int(floor(displayed_viewer_score_remainder))
	if step <= 0:
		return
	step = mini(step, diff)
	displayed_viewer_score += step
	displayed_viewer_score_remainder -= float(step)

func _sync_viewer_score_countup() -> void:
	displayed_viewer_score = maxi(0, score)
	displayed_viewer_score_remainder = 0.0
	viewer_score_countup_initialized = true

func _update_display_gauge_values(delta: float) -> void:
	_update_mental_gauge_display(delta)
	_update_song_live_heat_gauge_display(delta)

func _update_mental_gauge_display(delta: float) -> void:
	var target_ratio := _mental_hud_ratio()
	if not mental_gauge_display_initialized:
		displayed_mental_ratio = target_ratio
		mental_gauge_display_initialized = true
		return
	displayed_mental_ratio = _approach_display_float(displayed_mental_ratio, target_ratio, delta, MENTAL_GAUGE_DISPLAY_MIN_RATE, MENTAL_GAUGE_DISPLAY_CATCHUP_RATE)

func _update_song_live_heat_gauge_display(delta: float) -> void:
	var target_heat := clampf(song_live_heat, 0.0, SONG_LIVE_HEAT_MAX)
	if not song_live_heat_gauge_display_initialized:
		displayed_song_live_heat = target_heat
		song_live_heat_gauge_display_initialized = true
		return
	displayed_song_live_heat = _approach_display_float(displayed_song_live_heat, target_heat, delta, LIVE_HEAT_GAUGE_DISPLAY_MIN_RATE, LIVE_HEAT_GAUGE_DISPLAY_CATCHUP_RATE)

func _approach_display_float(current_value: float, target_value: float, delta: float, min_rate: float, catchup_rate: float) -> float:
	if delta <= 0.0:
		return current_value
	var diff := target_value - current_value
	if absf(diff) <= 0.001:
		return target_value
	var step := maxf(min_rate, absf(diff) * catchup_rate) * delta
	if absf(diff) <= step:
		return target_value
	return current_value + (1.0 if diff > 0.0 else -1.0) * step

func _sync_display_gauge_values() -> void:
	displayed_mental_ratio = _mental_hud_ratio()
	mental_gauge_display_initialized = true
	displayed_song_live_heat = clampf(song_live_heat, 0.0, SONG_LIVE_HEAT_MAX)
	song_live_heat_gauge_display_initialized = true

func _update_pause_input_with_se() -> void:
	var escape_down := Input.is_key_pressed(KEY_ESCAPE)
	if pause_escape_release_blocked:
		pause_escape_down = escape_down
		if not escape_down:
			pause_escape_release_blocked = false
		return
	if state == "pause" and pause_confirm_action != "":
		var was_escape_down := pause_escape_down
		pause_escape_down = escape_down
		if was_escape_down and not escape_down:
			_play_back_transition_se()
			_close_pause_confirm()
		return
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

func _setup_starlight_superchat_defeat_se() -> void:
	starlight_superchat_defeat_se_player = AudioStreamPlayer.new()
	starlight_superchat_defeat_se_player.name = "StarlightSuperchatDefeatSePlayer"
	starlight_superchat_defeat_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	starlight_superchat_defeat_se_player.stream = _load_audio_stream(STARLIGHT_SUPERCHAT_DEFEAT_SE_PATH, false)
	add_child(starlight_superchat_defeat_se_player)

func _setup_spotlight_attack_se() -> void:
	spotlight_attack_se_player = AudioStreamPlayer.new()
	spotlight_attack_se_player.name = "SpotlightAttackSePlayer"
	spotlight_attack_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	spotlight_attack_se_player.stream = _load_audio_stream(SPOTLIGHT_ATTACK_SE_PATH, false)
	add_child(spotlight_attack_se_player)

func _setup_song_penlight_bit_attack_se() -> void:
	song_penlight_bit_attack_se_player = AudioStreamPlayer.new()
	song_penlight_bit_attack_se_player.name = "SongPenlightBitAttackSePlayer"
	song_penlight_bit_attack_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	song_penlight_bit_attack_se_player.stream = _load_audio_stream(SONG_PENLIGHT_BIT_ATTACK_SE_PATH, false)
	add_child(song_penlight_bit_attack_se_player)

func _setup_song_audience_call_wave_se() -> void:
	song_audience_call_wave_se_player = AudioStreamPlayer.new()
	song_audience_call_wave_se_player.name = "SongAudienceCallWaveSePlayer"
	song_audience_call_wave_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume) - 3.0
	song_audience_call_wave_se_player.stream = _load_audio_stream(SONG_AUDIENCE_CALL_WAVE_SE_PATH, false)
	add_child(song_audience_call_wave_se_player)

func _setup_song_spotlight_benefit_se() -> void:
	song_spotlight_benefit_se_player = AudioStreamPlayer.new()
	song_spotlight_benefit_se_player.name = "SongSpotlightBenefitSePlayer"
	song_spotlight_benefit_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume) - 5.0
	song_spotlight_benefit_se_player.stream = _load_audio_stream(SONG_SPOTLIGHT_BENEFIT_SE_PATH, false)
	add_child(song_spotlight_benefit_se_player)

func _setup_song_lyrics_card_pickup_se() -> void:
	song_lyrics_card_pickup_se_player = AudioStreamPlayer.new()
	song_lyrics_card_pickup_se_player.name = "SongLyricsCardPickupSePlayer"
	song_lyrics_card_pickup_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	song_lyrics_card_pickup_se_player.stream = _load_audio_stream(SONG_LYRICS_CARD_PICKUP_SE_PATH, false)
	add_child(song_lyrics_card_pickup_se_player)

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

func _setup_comment_boomerang_se() -> void:
	comment_boomerang_se_player = AudioStreamPlayer.new()
	comment_boomerang_se_player.name = "CommentBoomerangSePlayer"
	comment_boomerang_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	comment_boomerang_se_player.stream = _load_audio_stream(COMMENT_BOOMERANG_SWING_SE_PATH, false)
	add_child(comment_boomerang_se_player)

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

func _setup_genre_race_coin_pickup_se() -> void:
	genre_race_coin_pickup_se_player = AudioStreamPlayer.new()
	genre_race_coin_pickup_se_player.name = "GenreRaceCoinPickupSePlayer"
	genre_race_coin_pickup_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	genre_race_coin_pickup_se_player.stream = _load_audio_stream(GENRE_RACE_COIN_PICKUP_SE_PATH, false)
	add_child(genre_race_coin_pickup_se_player)

func _setup_genre_race_dash_pad_se() -> void:
	genre_race_dash_pad_se_player = AudioStreamPlayer.new()
	genre_race_dash_pad_se_player.name = "GenreRaceDashPadSePlayer"
	genre_race_dash_pad_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	genre_race_dash_pad_se_player.stream = _load_audio_stream(GENRE_RACE_DASH_PAD_SE_PATH, false)
	add_child(genre_race_dash_pad_se_player)

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

func _setup_stream_end_whistle_se() -> void:
	stream_end_whistle_se_player = AudioStreamPlayer.new()
	stream_end_whistle_se_player.name = "StreamEndWhistleSePlayer"
	stream_end_whistle_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	stream_end_whistle_se_player.stream = _load_audio_stream(STREAM_END_WHISTLE_SE_PATH, false)
	add_child(stream_end_whistle_se_player)

func _setup_stream_start_ready_se() -> void:
	stream_start_ready_se_player = AudioStreamPlayer.new()
	stream_start_ready_se_player.name = "StreamStartReadySePlayer"
	stream_start_ready_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	stream_start_ready_se_player.stream = _load_audio_stream(STREAM_START_READY_SE_PATH, false)
	add_child(stream_start_ready_se_player)

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

func _setup_emote_mine_place_se() -> void:
	emote_mine_place_se_player = AudioStreamPlayer.new()
	emote_mine_place_se_player.name = "EmoteMinePlaceSePlayer"
	emote_mine_place_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	emote_mine_place_se_player.stream = _load_audio_stream(EMOTE_MINE_PLACE_SE_PATH, false)
	add_child(emote_mine_place_se_player)

func _setup_emote_mine_explosion_se() -> void:
	emote_mine_explosion_se_player = AudioStreamPlayer.new()
	emote_mine_explosion_se_player.name = "EmoteMineExplosionSePlayer"
	emote_mine_explosion_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	emote_mine_explosion_se_player.stream = _load_audio_stream(EMOTE_MINE_EXPLOSION_SE_PATH, false)
	add_child(emote_mine_explosion_se_player)

func _setup_song_scale_note_se() -> void:
	song_scale_note_se_player = AudioStreamPlayer.new()
	song_scale_note_se_player.name = "SongScaleNoteSePlayer"
	song_scale_note_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	add_child(song_scale_note_se_player)
	song_scale_note_streams.clear()
	for path in SONG_SCALE_NOTE_SE_PATHS:
		song_scale_note_streams.append(_load_audio_stream(String(path), false))

func _load_audio_stream(path: String, loop: bool = false) -> AudioStream:
	if path.get_extension().to_lower() == "mp3" and FileAccess.file_exists(path):
		var fallback_stream := AudioStreamMP3.new()
		fallback_stream.data = FileAccess.get_file_as_bytes(path)
		fallback_stream.loop = loop
		return fallback_stream
	var loaded: AudioStream = ResourceLoader.load(path) as AudioStream
	if loaded == null:
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
		gameplay_bgm_player.volume_db = _bgm_volume_db_for_scale((1.0 - boss_bgm_mix) * ending_scale * _stream_frame_bgm_volume_scale())
	if boss_bgm_player != null:
		boss_bgm_player.volume_db = _bgm_volume_db_for_scale(boss_bgm_mix * ending_scale)

func _stream_frame_bgm_volume_scale() -> float:
	if current_stream_frame_id == "gameplay":
		return GAMEPLAY_FRAME_BGM_VOLUME_SCALE
	return 1.0

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

func _play_starlight_superchat_defeat_se_once_per_frame() -> void:
	if starlight_superchat_defeat_se_player == null or starlight_superchat_defeat_se_player.stream == null:
		return
	var current_frame: int = Engine.get_process_frames()
	if starlight_superchat_defeat_se_played_frame == current_frame:
		return
	starlight_superchat_defeat_se_played_frame = current_frame
	starlight_superchat_defeat_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if starlight_superchat_defeat_se_player.playing:
		starlight_superchat_defeat_se_player.stop()
	starlight_superchat_defeat_se_player.play()

func _play_spotlight_attack_se() -> void:
	if spotlight_attack_se_player == null or spotlight_attack_se_player.stream == null:
		return
	spotlight_attack_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if spotlight_attack_se_player.playing:
		spotlight_attack_se_player.stop()
	spotlight_attack_se_player.play()

func _play_song_penlight_bit_attack_se() -> void:
	if song_penlight_bit_attack_se_player == null or song_penlight_bit_attack_se_player.stream == null:
		return
	song_penlight_bit_attack_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if song_penlight_bit_attack_se_player.playing:
		song_penlight_bit_attack_se_player.stop()
	song_penlight_bit_attack_se_player.play()

func _play_song_audience_call_wave_se() -> void:
	if song_audience_call_wave_se_player == null or song_audience_call_wave_se_player.stream == null:
		return
	song_audience_call_wave_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume) - 3.0
	if song_audience_call_wave_se_player.playing:
		song_audience_call_wave_se_player.stop()
	song_audience_call_wave_se_player.play()

func _play_song_spotlight_benefit_se() -> void:
	if song_spotlight_benefit_se_player == null or song_spotlight_benefit_se_player.stream == null:
		return
	song_spotlight_benefit_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume) - 5.0
	if song_spotlight_benefit_se_player.playing:
		song_spotlight_benefit_se_player.stop()
	song_spotlight_benefit_se_player.play()

func _play_song_lyrics_card_pickup_se() -> void:
	if song_lyrics_card_pickup_se_player == null or song_lyrics_card_pickup_se_player.stream == null:
		return
	song_lyrics_card_pickup_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if song_lyrics_card_pickup_se_player.playing:
		song_lyrics_card_pickup_se_player.stop()
	song_lyrics_card_pickup_se_player.play()

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

func _play_comment_boomerang_se() -> void:
	if comment_boomerang_se_player == null or comment_boomerang_se_player.stream == null:
		return
	comment_boomerang_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if comment_boomerang_se_player.playing:
		comment_boomerang_se_player.stop()
	comment_boomerang_se_player.play()

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

func _play_genre_race_coin_pickup_se() -> void:
	if genre_race_coin_pickup_se_player == null or genre_race_coin_pickup_se_player.stream == null:
		return
	genre_race_coin_pickup_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if genre_race_coin_pickup_se_player.playing:
		genre_race_coin_pickup_se_player.stop()
	genre_race_coin_pickup_se_player.play()

func _play_genre_race_dash_pad_se() -> void:
	if genre_race_dash_pad_se_player == null or genre_race_dash_pad_se_player.stream == null:
		return
	genre_race_dash_pad_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if genre_race_dash_pad_se_player.playing:
		genre_race_dash_pad_se_player.stop()
	genre_race_dash_pad_se_player.play()

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

func _play_stream_end_whistle_se() -> void:
	if stream_end_whistle_se_player == null or stream_end_whistle_se_player.stream == null:
		return
	stream_end_whistle_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if stream_end_whistle_se_player.playing:
		stream_end_whistle_se_player.stop()
	stream_end_whistle_se_player.play()

func _play_stream_start_ready_se() -> void:
	if stream_start_ready_se_player == null or stream_start_ready_se_player.stream == null:
		return
	stream_start_ready_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if stream_start_ready_se_player.playing:
		stream_start_ready_se_player.stop()
	stream_start_ready_se_player.play()

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

func _play_emote_mine_place_se() -> void:
	if emote_mine_place_se_player == null or emote_mine_place_se_player.stream == null:
		return
	emote_mine_place_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if emote_mine_place_se_player.playing:
		emote_mine_place_se_player.stop()
	emote_mine_place_se_player.play()

func _play_emote_mine_explosion_se() -> void:
	if emote_mine_explosion_se_player == null or emote_mine_explosion_se_player.stream == null:
		return
	emote_mine_explosion_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	if emote_mine_explosion_se_player.playing:
		emote_mine_explosion_se_player.stop()
	emote_mine_explosion_se_player.play()

func _enqueue_song_scale_note_se(index: int) -> void:
	if song_scale_note_streams.is_empty():
		return
	song_scale_note_queue.append(clampi(index, 0, SONG_SCALE_NOTE_COUNT - 1))
	if song_scale_note_queue.size() > 12:
		song_scale_note_queue.pop_front()

func _update_song_scale_note_se_queue(delta: float) -> void:
	if song_scale_note_queue_timer > 0.0:
		song_scale_note_queue_timer = maxf(0.0, song_scale_note_queue_timer - delta)
	if song_scale_note_queue_timer > 0.0 or song_scale_note_queue.is_empty():
		return
	var note_index := int(song_scale_note_queue.pop_front())
	_play_song_scale_note_se(note_index)
	song_scale_note_queue_timer = SONG_SCALE_NOTE_QUEUE_INTERVAL

func _play_song_scale_note_se(index: int) -> void:
	if song_scale_note_se_player == null:
		return
	if index < 0 or index >= song_scale_note_streams.size():
		return
	var stream: AudioStream = song_scale_note_streams[index] as AudioStream
	if stream == null:
		return
	song_scale_note_se_player.volume_db = SettingsSystemScript.volume_db_from_percent(se_volume)
	song_scale_note_se_player.stream = stream
	if song_scale_note_se_player.playing:
		song_scale_note_se_player.stop()
	song_scale_note_se_player.play()

func _cursor_sound_snapshot() -> Array:
	return [
		state,
		title_menu_index,
		option_menu_index,
		selected_character_index,
		character_select_focus_area,
		selected_stream_frame_index,
		stream_frame_select_focus_area,
		ranking_tab_index,
		ranking_selected_index,
		ranking_focus_area,
		ranking_reset_confirm_index,
		pause_menu_index,
		pause_focus_area,
		pause_equipment_row,
		pause_weapon_slot_index,
		pause_accessory_slot_index,
		selected_card,
		result_hover_button
	]

func _cursor_sound_snapshot_changed(before: Array) -> bool:
	if before.size() < 18 or String(before[0]) != state:
		return false
	return (
		int(before[1]) != title_menu_index
		or int(before[2]) != option_menu_index
		or int(before[3]) != selected_character_index
		or String(before[4]) != character_select_focus_area
		or int(before[5]) != selected_stream_frame_index
		or String(before[6]) != stream_frame_select_focus_area
		or int(before[7]) != ranking_tab_index
		or int(before[8]) != ranking_selected_index
		or String(before[9]) != ranking_focus_area
		or int(before[10]) != ranking_reset_confirm_index
		or int(before[11]) != pause_menu_index
		or String(before[12]) != pause_focus_area
		or int(before[13]) != pause_equipment_row
		or int(before[14]) != pause_weapon_slot_index
		or int(before[15]) != pause_accessory_slot_index
		or int(before[16]) != selected_card
		or String(before[17]) != result_hover_button
	)

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
	var arena := _current_arena()
	target.x = clampf(target.x, arena.position.x + CLICK_MOVE_PLAYER_RADIUS, arena.end.x - CLICK_MOVE_PLAYER_RADIUS)
	target.y = clampf(target.y, arena.position.y + CLICK_MOVE_PLAYER_RADIUS, arena.end.y - CLICK_MOVE_PLAYER_RADIUS)
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
	stream_start_intro_ready_se_played = false
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
	_maybe_play_stream_start_ready_se()
	_maybe_play_stream_start_live_start_se()
	if stream_start_intro_timer <= 0.0 or skip_pressed:
		_restart()

func _maybe_play_stream_start_ready_se() -> void:
	if stream_start_intro_ready_se_played:
		return
	if _stream_start_intro_elapsed() < STREAM_START_READY_TIME:
		return
	stream_start_intro_ready_se_played = true
	_play_stream_start_ready_se()

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
	if _is_song_frame() and song_encore_completed:
		score = int(round(float(score) * SONG_ENCORE_CLEAR_BONUS_MULTIPLIER))
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
		_request_screen_flash(Color(1.0, 0.92, 0.62, 0.16), 0.18)
		_request_screen_shake(0.055, 0.12)
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
	var cursor_before: Array = _cursor_sound_snapshot()
	if state == "comment_choice":
		_update_comment_choice(delta)
	elif state == "gift_choice":
		_update_gift_choice()
	else:
		_update_world(delta)
	if _cursor_sound_snapshot_changed(cursor_before):
		_play_cursor_move_se()

func _update_front_state(delta: float) -> bool:
	var cursor_before: Array = _cursor_sound_snapshot()
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
	var arena := _current_arena()
	var min_offset: Vector2 = arena.position - FIELD_VIEW.position
	var max_offset: Vector2 = arena.end - FIELD_VIEW.end
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

func _visible_world_rect_for_spawning() -> Rect2:
	var top_left := _world_pos_from_screen(FIELD_VIEW.position)
	var bottom_right := _world_pos_from_screen(FIELD_VIEW.end)
	var min_pos := Vector2(minf(top_left.x, bottom_right.x), minf(top_left.y, bottom_right.y))
	var max_pos := Vector2(maxf(top_left.x, bottom_right.x), maxf(top_left.y, bottom_right.y))
	return Rect2(min_pos, max_pos - min_pos)

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
	if state == "comment_choice" or state == "gift_choice" or state == "pause":
		_draw_status_overlay_layer()
		_draw_overlay_layer()
	else:
		_draw_overlay_layer()
		_draw_status_overlay_layer()

func _draw_status_overlay_layer() -> void:
	_draw_screen_flash()
	_draw_genre_change_banner()
	_draw_genre_event_timer()
	_draw_genre_result_card()
	_draw_song_chorus_banner()
	_draw_song_live_heat_level_notice()
	_draw_song_octave_bonus_notice()
	_draw_song_boss_chorus_judge_notice()
	_draw_song_live_heat_hud()
	_draw_song_chorus_timer()
	_draw_song_chorus_result_card()
	_draw_drawing_stage_hud()
	_draw_drawing_stage_toast()
	_draw_toast()

func _draws_title_only() -> bool:
	return state in ["title", "ranking", "options", "character_select", "stream_frame_select", "stream_start_intro"]

func _draw_world_layer() -> void:
	_draw_screen_backdrop()
	world_camera_offset = _world_camera_offset()
	var visible_world_rect := _visible_world_rect_for_spawning().grow(260.0)
	world_draw_active = true
	_apply_world_transform()
	_draw_arena()
	_draw_boss_slow_fields()
	_draw_boss_guide_lines()
	var hit_fx_draw_items: Array = DrawDataSystemScript.hit_fx_draw_data(hit_fx, visible_world_rect)
	_draw_hit_fx(true, hit_fx_draw_items)
	_draw_click_move_marker()
	_draw_genre_event_objects(visible_world_rect)
	_draw_song_chorus_objects(visible_world_rect)
	_draw_drawing_stage_objects(visible_world_rect)
	_draw_exp(visible_world_rect)
	_draw_mallow(visible_world_rect)
	_draw_drop_items(visible_world_rect)
	_draw_destructibles(visible_world_rect)
	_draw_enemy_bullets(visible_world_rect)
	_draw_player_bullets(visible_world_rect)
	_draw_enemies(visible_world_rect)
	_draw_boomerang()
	_draw_player()
	_draw_song_spotlight_labels(visible_world_rect)
	_draw_hit_fx(false, hit_fx_draw_items)
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
	if not special_overlays.has("comment_storm"):
		_reset_comment_storm_slots()
	var comment_storm_under_overlay: bool = (modal_overlay_active or state == "game_over_intro") and not title_only
	if comment_storm_under_overlay and special_overlays.has("comment_storm"):
		_draw_comment_storm()
	if modal_overlay_active and special_overlays.has("horror"):
		_draw_horror_mask()
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
				if not comment_storm_under_overlay:
					_draw_comment_storm()
			elif String(special_overlay) == "horror":
				if not modal_overlay_active:
					_draw_horror_mask()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if state == "playing":
		_draw_boss_overlay()
	if StateFlowSystemScript.shows_comment_countdown(state):
		_draw_comment_countdown()
	if state == "playing":
		_draw_stream_end_countdown_overlay()
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
	if stream_end_banner_timer > 0.0:
		stream_end_banner_timer = maxf(0.0, stream_end_banner_timer - delta)
		if stream_end_banner_timer <= 0.0:
			_finish_stream_end_banner()
		_update_ui()
		return
	var previous_remaining := maxf(0.0, run_length - elapsed)
	elapsed += delta
	var remaining := maxf(0.0, run_length - elapsed)
	_update_time_announcements(previous_remaining, run_length)
	_update_stream_end_countdown_feedback(remaining)
	if elapsed >= run_length:
		elapsed = run_length
		_start_stream_end_banner()
		return

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
	_maybe_time_toast_announcement("10sec", previous_remaining, remaining, run_length, END_COUNTDOWN_TOAST_SECONDS, "終了まで10秒", 1.6)

func _update_stream_end_countdown_feedback(remaining: float) -> void:
	if remaining <= 0.0 or remaining > float(END_COUNTDOWN_START_SECONDS):
		return
	var second := int(ceil(remaining))
	if second < 1 or second > END_COUNTDOWN_START_SECONDS or second == last_countdown_announcement_second:
		return
	last_countdown_announcement_second = second
	if second == 1:
		_play_confirm_se()
		_request_screen_shake(0.055, 0.10)
		_request_screen_flash(Color(1.0, 0.70, 0.94, 0.08), 0.08)
	else:
		_play_cursor_move_se()
		_request_screen_shake(0.025, 0.07)

func _start_stream_end_banner() -> void:
	if stream_end_banner_timer > 0.0:
		return
	stream_end_banner_duration = STREAM_END_BANNER_DURATION
	stream_end_banner_timer = stream_end_banner_duration
	_play_stream_end_whistle_se()
	_request_screen_shake(0.08, 0.13)
	_request_screen_flash(Color(0.76, 0.92, 1.0, 0.10), 0.12)
	queue_redraw()

func _finish_stream_end_banner() -> void:
	stream_end_banner_timer = 0.0
	if relay_mode:
		_advance_relay_frame()
		return
	_start_stream_complete_intro("配信成功！3分間生き残った。")

func _maybe_time_mark_announcement(key: String, previous_remaining: float, remaining: float, run_length: float, mark: float, text: String) -> void:
	if run_length <= mark or bool(time_announcement_flags.get(key, false)):
		return
	if previous_remaining >= mark and remaining < mark:
		time_announcement_flags[key] = true
		_push_time_announcement(text, 1.5)

func _maybe_time_toast_announcement(key: String, previous_remaining: float, remaining: float, run_length: float, mark: float, text: String, toast_seconds: float) -> void:
	if run_length <= mark or bool(time_announcement_flags.get(key, false)):
		return
	if previous_remaining >= mark and remaining < mark:
		time_announcement_flags[key] = true
		_push_time_toast(text, toast_seconds)

func _push_time_announcement(text: String, toast_seconds: float) -> void:
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": [text], "toasts": [text]}, chat_box, toast_seconds)

func _push_time_toast(text: String, toast_seconds: float) -> void:
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"toasts": [text]}, chat_box, toast_seconds)

func _clear_toast() -> void:
	toast_text = ""
	toast_timer = 0.0

func _reset_time_announcements() -> void:
	time_announcement_flags.clear()
	last_countdown_announcement_second = -1
	stream_end_banner_timer = 0.0
	stream_end_banner_duration = STREAM_END_BANNER_DURATION

func _update_stream_frame_events(delta: float) -> void:
	var arena := _current_arena()
	var marshmallow_feedback: Dictionary = MarshmallowSystemScript.update_auto_spawn_if_enabled_for_target(self, current_stream_frame, marshmallow_data, rng, arena, effect_walls)
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, marshmallow_feedback, chat_box)
	_update_genre_event(delta)
	_update_song_chorus(delta, arena)

func _update_world_systems(delta: float) -> void:
	var arena := _current_arena()
	_update_gift_choice_delay(delta)
	_update_player(delta, arena)
	if state != "playing":
		return
	_update_drawing_stage(delta, arena)
	_update_accessory_effects(delta)
	_apply_damage_feedback(ModifierSystemScript.update_stage_hazard_damage_for_target(self, arena))
	if state != "playing":
		return
	_update_spawning(delta, arena)
	_update_boss(delta, arena)
	_update_enemies(delta, arena)
	if state != "playing":
		return
	_update_destructibles(delta, arena)
	_update_weapons(delta, arena)
	var exp_result: Dictionary = ExpSystemScript.update_world_for_target(self, delta)
	if int(exp_result.get("collectedExp", 0)) > 0:
		_play_exp_pickup_se()
	if bool(exp_result["levelUp"]):
		pending_gift_choices += int(exp_result.get("levelUps", 1))
		if gift_choice_delay_timer <= 0.0:
			_start_gift_choice()
	_update_marshmallow(delta, arena)
	var hit_fx_feedback: Dictionary = WeaponSystemScript.update_hit_fx_for_target(self, delta, arena, rng)
	_apply_hit_reaction_feedback(hit_fx_feedback)
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, hit_fx_feedback, chat_box)
	if state == "playing" and pending_gift_choices > 0 and gift_choice_delay_timer <= 0.0:
		_start_gift_choice()

func _update_gift_choice_delay(delta: float) -> void:
	if gift_choice_delay_timer <= 0.0:
		return
	gift_choice_delay_timer = maxf(0.0, gift_choice_delay_timer - delta)

func _update_boss(delta: float, arena: Rect2) -> void:
	var before_event := String(active_genre_event)
	var feedback: Dictionary = BossSystemScript.update_for_target(self, delta, arena, rng)
	_apply_hit_reaction_feedback(feedback)
	_maybe_start_genre_change_banner(before_event)
	_apply_damage_feedback(DamageSystemScript.apply_damage_events_for_target(self, feedback.get("damageEvents", []) as Array))
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
	var before_event := String(active_genre_event)
	var feedback: Dictionary = GenreEventSystemScript.update_world_if_enabled_for_target(self, current_stream_frame, delta, genre_events, _current_arena(), rng)
	if _feedback_has_comment_event(feedback, "gameplay_race_coin_collected"):
		_play_genre_race_coin_pickup_se()
	if _feedback_has_comment_event(feedback, "gameplay_race_dash_pad_used"):
		_play_genre_race_dash_pad_se()
	_maybe_start_genre_change_banner(before_event)
	_maybe_start_genre_result_card(feedback)
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, feedback, chat_box)

func _feedback_has_comment_event(feedback: Dictionary, event_id: String) -> bool:
	for item in (feedback.get("commentEventIds", []) as Array):
		if String(item) == event_id:
			return true
	var single_event_id := String(feedback.get("commentEventId", ""))
	return single_event_id == event_id

func _maybe_start_genre_change_banner(before_event: String) -> void:
	var after_event := String(active_genre_event)
	if current_stream_frame_id != "gameplay" or after_event == "" or after_event == before_event:
		return
	if _genre_change_banner_path(after_event) == "":
		return
	genre_change_banner_event = after_event
	genre_change_banner_timer = GENRE_CHANGE_BANNER_DURATION

func _update_genre_change_banner(delta: float) -> void:
	if genre_change_banner_timer <= 0.0:
		return
	genre_change_banner_timer = maxf(0.0, genre_change_banner_timer - delta)
	if genre_change_banner_timer <= 0.0:
		genre_change_banner_event = ""

func _maybe_start_genre_result_card(feedback: Dictionary) -> void:
	var result_value: Variant = feedback.get("genreResult", {})
	if not (result_value is Dictionary):
		return
	var data: Dictionary = result_value as Dictionary
	if data.is_empty():
		return
	genre_result_card_data = data.duplicate(true)
	genre_result_card_duration = clampf(float(data.get("duration", GENRE_RESULT_CARD_DURATION)), 1.2, 1.8)
	genre_result_card_timer = genre_result_card_duration

func _update_genre_result_card(delta: float) -> void:
	if genre_result_card_timer <= 0.0:
		return
	genre_result_card_timer = maxf(0.0, genre_result_card_timer - delta)
	if genre_result_card_timer <= 0.0:
		genre_result_card_data.clear()

func _genre_change_banner_path(event_id: String) -> String:
	match event_id:
		"race":
			return GENRE_CHANGE_BANNER_RACE_IMAGE
		"bullet_hell":
			return GENRE_CHANGE_BANNER_BULLET_HELL_IMAGE
		"horror":
			return GENRE_CHANGE_BANNER_HORROR_IMAGE
	return ""

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
		pause_escape_release_blocked = true
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
	_reset_time_announcements()
	choice_box.visible = false
	result_panel.visible = false
	_update_title_screen_visibility()

func _update_player(delta: float, arena: Rect2) -> void:
	var result: Dictionary = PlayerSystemScript.update_for_target(self, delta, arena)
	if bool(result.get("dashStarted", false)):
		_play_dash_se()
	if bool(result["stoppedDamage"]):
		_damage_player("stopped moving")
	_update_banana_slip_fx(delta)

func _update_banana_slip_fx(delta: float) -> void:
	if not ModifierSystemScript.has_effect_for_target(self, "banana_floor"):
		banana_slip_fx_timer = 0.0
		return
	var speed_sq := player_vel.length_squared()
	if speed_sq < 6400.0:
		banana_slip_fx_timer = maxf(0.0, banana_slip_fx_timer - delta)
		return
	banana_slip_fx_timer -= delta
	if banana_slip_fx_timer > 0.0:
		return
	banana_slip_fx_timer = 0.07
	var dir: Vector2 = player_vel / sqrt(speed_sq)
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

func _update_spawning(delta: float, arena: Rect2) -> void:
	SpawnerSystemScript.update_for_target(self, delta, arena, rng)

func _update_enemies(delta: float, arena: Rect2) -> void:
	var result: Dictionary = EnemySystemScript.update_world_for_target(self, delta, rng, arena)
	var marshmallow_drop_requests: Array = result.get("marshmallowDropRequests", []) as Array
	if not marshmallow_drop_requests.is_empty():
		MarshmallowSystemScript.spawn_supply_drop_requests_for_target(self, marshmallow_data, marshmallow_drop_requests, rng, arena, effect_walls)
	_apply_hit_reaction_feedback(result)
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, result, chat_box)
	_apply_damage_feedback(DamageSystemScript.apply_damage_events_for_target(self, result.get("damageEvents", []) as Array))

func _update_weapons(delta: float, arena: Rect2) -> void:
	var result: Dictionary = WeaponSystemScript.update_for_target(self, delta, arena, rng)
	if _weapon_update_has_fx(result, "ng_word_laser"):
		_play_laser_se()
	if _weapon_update_has_ban_judgement_swing(result):
		_play_ban_judgement_se()
	elif _weapon_update_has_hammer_swing(result):
		_play_ban_hammer_se()
	if bool(result.get("superchatShotFired", false)):
		_play_superchat_shot_se()
	if _weapon_update_has_fx(result, "starlight_defeat"):
		_play_starlight_superchat_defeat_se_once_per_frame()
	if _weapon_update_has_fx(result, "spotlight"):
		_play_spotlight_attack_se()
	if _weapon_update_has_fx(result, "kusa_wave"):
		_play_kusa_wave_se()
	if _weapon_update_has_fx(result, "comment_pin"):
		_play_comment_pin_se()
	if bool(result.get("boomerangOrbitSe", false)):
		_play_comment_boomerang_se()
	if _weapon_update_has_fx(result, "emote_mine"):
		_play_emote_mine_place_se()
	var feedback: Dictionary = WeaponSystemScript.apply_update_result_for_target(self, result, arena, rng)
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
		if _is_song_frame():
			song_no_damage_streak_timer = 0.0
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
	var before_genre_event := String(active_genre_event)
	var result: Dictionary = CommentSystemScript.choose_comment_with_feedback_for_target(self, index, rng, _current_arena(), COMMENT_INTERVAL, choice_box, genre_events)
	if not bool(result["selected"]):
		return
	_maybe_start_genre_change_banner(before_genre_event)
	_play_confirm_se()
	_suppress_dash_button_after_ui_confirm()
	if bool(result.get("bossWarningStarted", false)):
		_play_boss_warning_se()
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, result, chat_box)
	_apply_song_instruction_comment(String(result.get("commentId", "")))
	_apply_drawing_instruction_comment(String(result.get("commentId", "")))
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

func _update_marshmallow(delta: float, arena: Rect2) -> void:
	var feedback: Dictionary = MarshmallowSystemScript.update_world_for_target(self, delta, arena, rng)
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

func _update_destructibles(delta: float, arena: Rect2) -> void:
	var feedback: Dictionary = DestructibleSystemScript.update_world_for_target(self, delta, arena, rng, effect_walls)
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
	_play_confirm_se()
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
	_play_confirm_se()
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
	_sync_viewer_score_countup()
	_sync_display_gauge_values()
	chat_lines = RunStateSystemScript.reset_run_ui_and_seed_chat(result_panel, choice_box, heart_cards, chat_lines, chat_box)
	BossSystemScript.reset_for_target(self)
	_reset_time_announcements()
	_reset_song_chorus_state()
	_reset_drawing_stage_state()
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
	genre_event_duration = GenreEventSystemScript.GENRE_EVENT_DURATION
	genre_event_source = ""
	genre_bullet_timer = 0.0
	genre_event_hurt = false
	genre_race_dash_pads.clear()
	genre_race_coins.clear()
	genre_horror_fake_gifts.clear()
	genre_race_dash_boost_timer = 0.0
	genre_race_enemy_spawn_timer = 0.0
	genre_stg_shot_timer = 0.0
	genre_stg_spawn_timer = 0.0
	genre_stg_last_dir = Vector2.RIGHT
	genre_result_coin_count = 0
	genre_result_dash_pad_count = 0
	genre_event_start_kills = 0
	genre_result_stg_shot_kill_count = 0
	genre_result_fake_gift_defeat_count = 0
	genre_result_card_timer = 0.0
	genre_result_card_duration = GENRE_RESULT_CARD_DURATION
	genre_result_card_data.clear()
	genre_change_banner_event = ""
	genre_change_banner_timer = 0.0
	_reset_song_chorus_state()
	_reset_drawing_stage_state()
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
		var marshmallow_result: Dictionary = DebugSystemScript.force_marshmallow_for_target(self, marshmallow_data, marshmallow_kind, rng, _current_arena(), effect_walls)
		if bool(marshmallow_result["spawned"]):
			chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": [String(marshmallow_result["chat"])]}, chat_box)
	var result: Dictionary = DebugSystemScript.apply_general_action_for_target(self, action, quick_test_mode, _current_arena(), rng)
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

func _current_map_data() -> Dictionary:
	var map_variant := ""
	if current_stream_frame_id == "gameplay":
		map_variant = String(active_genre_event)
	elif _is_song_frame() and (song_chorus_timer > 0.0 or song_encore_timer > 0.0):
		map_variant = "chorus"
	if cached_map_frame_id != current_stream_frame_id or cached_map_genre_event != map_variant or cached_map_data.is_empty():
		cached_map_frame_id = current_stream_frame_id
		cached_map_genre_event = map_variant
		cached_map_data = MapBackgroundSystemScript.background_data_for_stream_frame(current_stream_frame_id, map_variant)
	return cached_map_data

func _current_arena() -> Rect2:
	return MapBackgroundSystemScript.world_rect(_current_map_data())

func _draw_arena() -> void:
	var map_data: Dictionary = _current_map_data()
	var map_rect: Rect2 = MapBackgroundSystemScript.world_rect(map_data)
	var arena := _current_arena()
	var has_image_background := false
	if not _draw_map_background_image(MapBackgroundSystemScript.floor_path(map_data), map_rect):
		if _draw_map_background_image(MapBackgroundSystemScript.background_path(map_data), map_rect):
			has_image_background = true
		else:
			if _is_song_frame():
				_draw_song_stage_background(arena)
			elif _is_drawing_frame():
				_draw_drawing_stage_background(arena)
			else:
				var background: Dictionary = DrawDataSystemScript.arena_background_data(arena)
				for part in DrawDataSystemScript.arena_background_parts(background):
					_draw_arena_part(part as Dictionary)
	else:
		has_image_background = true
	if has_image_background and _is_drawing_frame():
		_draw_drawing_canvas_progress_layer(map_data)
	var has_banana_floor := ModifierSystemScript.has_effect_for_target(self, "banana_floor")
	var arena_effects: Dictionary = DrawDataSystemScript.arena_effect_data(arena, has_banana_floor, effect_pits, _banana_floor_rollback_progress(), _banana_floor_appear_progress())
	for part in DrawDataSystemScript.arena_effect_parts(arena_effects):
		_draw_arena_part(part as Dictionary)
	if _is_song_frame():
		_draw_song_live_heat_background_overlay(arena)
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
	var map_data: Dictionary = _current_map_data()
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

func _rotated_rect_points(center: Vector2, size: Vector2, angle: float) -> PackedVector2Array:
	var dir := Vector2(cos(angle), sin(angle))
	var side := Vector2(-dir.y, dir.x)
	var half_w := size.x * 0.5
	var half_h := size.y * 0.5
	return PackedVector2Array([
		center - dir * half_w - side * half_h,
		center + dir * half_w - side * half_h,
		center + dir * half_w + side * half_h,
		center - dir * half_w + side * half_h
	])

func _draw_polyline(points: PackedVector2Array, color: Color, width: float) -> void:
	if points.size() < 2:
		return
	for i in range(points.size()):
		draw_line(points[i], points[(i + 1) % points.size()], color, width, true)

func _draw_genre_event_objects(visible_rect: Rect2) -> void:
	if current_stream_frame_id != "gameplay":
		return
	for pad_item in genre_race_dash_pads:
		var pad: Dictionary = pad_item as Dictionary
		if not visible_rect.has_point(Vector2(pad.get("pos", Vector2.ZERO))):
			continue
		_draw_genre_race_dash_pad(pad)
	for coin_item in genre_race_coins:
		var coin: Dictionary = coin_item as Dictionary
		if not visible_rect.has_point(Vector2(coin.get("pos", Vector2.ZERO))):
			continue
		_draw_genre_race_coin(coin)

func _draw_genre_race_dash_pad(pad: Dictionary) -> void:
	var pos := Vector2(pad.get("pos", Vector2.ZERO))
	var angle := float(pad.get("angle", 0.0))
	var pulse := 0.5 + 0.5 * sin(elapsed * 8.0 + float(pad.get("seed", 0.0)))
	var texture: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, GENRE_EVENT_DASH_PAD_IMAGE)
	if texture != null:
		var image_size := Vector2(122.0, 110.0) * (1.0 + pulse * 0.025)
		_draw_shadow(pos + Vector2(0.0, 18.0), Vector2(92.0, 26.0), 0.18)
		draw_colored_polygon(_rotated_rect_points(pos, image_size * Vector2(0.90, 0.46), angle), Color(1.0, 0.72, 0.16, 0.08 + pulse * 0.07))
		_draw_rotated_texture(texture, pos, image_size, angle, 0.98)
		if genre_race_dash_boost_timer > 0.0:
			var boost_alpha := clampf(genre_race_dash_boost_timer / GenreEventSystemScript.RACE_DASH_BUFF_DURATION, 0.0, 1.0)
			draw_arc(pos, 56.0 + pulse * 5.0, elapsed * 5.0, elapsed * 5.0 + TAU * 0.72, 32, Color(1.0, 0.84, 0.20, 0.26 * boost_alpha), 4.0, true)
		return
	var size := Vector2(94.0, 42.0)
	var dir := Vector2(cos(angle), sin(angle))
	var side := Vector2(-dir.y, dir.x)
	var points := _rotated_rect_points(pos, size, angle)
	_draw_shadow(pos + Vector2(0.0, 12.0), Vector2(82.0, 22.0), 0.18)
	draw_colored_polygon(_rotated_rect_points(pos, size + Vector2(18.0, 15.0), angle), Color(1.0, 0.68, 0.10, 0.10 + pulse * 0.08))
	draw_colored_polygon(points, Color("#fff0a0"))
	_draw_polyline(points, Color("#ff9b21"), 4.0)
	_draw_polyline(_rotated_rect_points(pos, size - Vector2(12.0, 12.0), angle), Color(1.0, 1.0, 1.0, 0.60), 2.0)
	for i in range(3):
		var arrow_center := pos + dir * (-26.0 + float(i) * 24.0)
		var tip := arrow_center + dir * (12.0 + pulse * 2.0)
		var back := arrow_center - dir * 10.0
		draw_line(back, tip, Color("#ff7a00"), 5.0, true)
		draw_line(tip, tip - dir * 10.0 + side * 8.0, Color("#ff7a00"), 5.0, true)
		draw_line(tip, tip - dir * 10.0 - side * 8.0, Color("#ff7a00"), 5.0, true)
	if genre_race_dash_boost_timer > 0.0:
		var alpha := clampf(genre_race_dash_boost_timer / GenreEventSystemScript.RACE_DASH_BUFF_DURATION, 0.0, 1.0)
		draw_arc(pos, 56.0 + pulse * 5.0, elapsed * 5.0, elapsed * 5.0 + TAU * 0.72, 32, Color(1.0, 0.84, 0.20, 0.26 * alpha), 4.0, true)

func _draw_genre_race_coin(coin: Dictionary) -> void:
	var pos := Vector2(coin.get("pos", Vector2.ZERO))
	var pulse := 0.5 + 0.5 * sin(elapsed * 7.5 + float(coin.get("seed", 0.0)))
	var texture: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, GENRE_EVENT_COIN_IMAGE)
	if texture != null:
		var image_size := Vector2.ONE * (43.0 + pulse * 4.0)
		_draw_shadow(pos + Vector2(0.0, 13.0), Vector2(31.0, 9.0), 0.16)
		draw_circle(pos, 25.0 + pulse * 5.0, Color(1.0, 0.78, 0.14, 0.10 + pulse * 0.07))
		_draw_rotated_texture(texture, pos, image_size, sin(elapsed * 4.0 + float(coin.get("seed", 0.0))) * 0.08, 0.98)
		return
	var radius := 15.0 + pulse * 2.5
	_draw_shadow(pos + Vector2(0.0, 12.0), Vector2(30.0, 9.0), 0.16)
	draw_circle(pos, radius + 10.0, Color(1.0, 0.78, 0.14, 0.12 + pulse * 0.08))
	draw_circle(pos, radius, Color("#ffcc35"))
	draw_circle(pos - Vector2(3.0, 4.0), radius * 0.62, Color("#fff18c"))
	draw_arc(pos, radius + 2.0, 0.0, TAU, 28, Color("#c87805"), 3.0, true)
	_draw_text_item({"label": "C", "labelPos": pos + Vector2(-8.0, 7.0), "labelColor": Color("#a86400"), "labelSize": 18, "labelWidth": -1}, "label")

func _draw_genre_horror_fake_gift(gift: Dictionary) -> void:
	var pos := Vector2(gift.get("pos", Vector2.ZERO))
	var seed := float(gift.get("seed", 0.0))
	var wobble := sin(elapsed * 8.0 + seed) * 2.0
	var texture: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, GENRE_EVENT_FAKE_GIFT_IMAGE)
	if texture != null:
		var draw_pos := pos + Vector2(0.0, wobble - 4.0)
		var image_size := Vector2(58.0, 58.0) * (1.0 + sin(elapsed * 5.5 + seed) * 0.015)
		_draw_shadow(pos + Vector2(0.0, 18.0), Vector2(45.0, 13.0), 0.23)
		draw_circle(pos + Vector2(0.0, wobble), 36.0, Color(0.38, 0.20, 0.60, 0.10))
		_draw_rotated_texture(texture, draw_pos, image_size, sin(elapsed * 3.0 + seed) * 0.035, 0.98)
		if int(elapsed * 5.0 + seed) % 3 == 0:
			draw_circle(pos + Vector2(9.0, -5.0 + wobble), 2.4, Color(0.10, 0.02, 0.05, 0.68))
			draw_circle(pos + Vector2(-9.0, -5.0 + wobble), 2.4, Color(0.10, 0.02, 0.05, 0.68))
		return
	var body := Rect2(pos + Vector2(-21.0, -18.0 + wobble), Vector2(42.0, 36.0))
	var lid := Rect2(pos + Vector2(-25.0, -28.0 + wobble), Vector2(50.0, 12.0))
	_draw_shadow(pos + Vector2(0.0, 17.0), Vector2(46.0, 13.0), 0.26)
	draw_circle(pos + Vector2(0.0, wobble), 40.0, Color(0.38, 0.20, 0.60, 0.12))
	draw_rect(body, Color("#c59ce9"), true)
	draw_rect(lid, Color("#f0d9ff"), true)
	_draw_rect_outline(body, Color("#62406f"), 3)
	_draw_rect_outline(lid, Color("#62406f"), 3)
	draw_rect(Rect2(pos + Vector2(-5.0, -28.0 + wobble), Vector2(10.0, 46.0)), Color("#7660c9"), true)
	draw_rect(Rect2(pos + Vector2(-21.0, -4.0 + wobble), Vector2(42.0, 8.0)), Color("#7660c9"), true)
	draw_line(pos + Vector2(-15.0, -28.0 + wobble), pos + Vector2(0.0, -40.0 + wobble), Color("#e0c7ff"), 4.0, true)
	draw_line(pos + Vector2(15.0, -28.0 + wobble), pos + Vector2(0.0, -40.0 + wobble), Color("#e0c7ff"), 4.0, true)
	if int(elapsed * 5.0 + seed) % 3 == 0:
		draw_circle(pos + Vector2(9.0, -5.0 + wobble), 2.5, Color("#3b254f"))
		draw_circle(pos + Vector2(-9.0, -5.0 + wobble), 2.5, Color("#3b254f"))

func _draw_genre_stg_player_overlay() -> void:
	if active_genre_event != "bullet_hell":
		return
	var dir := Vector2(genre_stg_last_dir)
	if dir.length() < 0.1:
		dir = Vector2.RIGHT if player_facing_x >= 0.0 else Vector2.LEFT
	dir = dir.normalized()
	var texture: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, GENRE_EVENT_STG_PLAYER_OVERLAY_IMAGE)
	if texture != null:
		var center := player_pos + dir * 5.0 + Vector2(0.0, -3.0)
		var pulse := 0.5 + 0.5 * sin(elapsed * 10.0)
		var image_size := Vector2(92.0, 89.0) * (1.0 + pulse * 0.025)
		var glow_alpha := 0.13 + pulse * 0.04
		draw_circle(center, 43.0 + pulse * 4.0, Color(0.28, 0.90, 1.0, glow_alpha))
		_draw_rotated_texture(texture, center, image_size, dir.angle() + PI * 0.5, 0.94)
		draw_line(center - dir * 34.0, center - dir * 52.0 + Vector2(-dir.y, dir.x) * 9.0, Color(0.40, 0.78, 1.0, 0.25), 5.0, true)
		draw_line(center - dir * 34.0, center - dir * 52.0 - Vector2(-dir.y, dir.x) * 9.0, Color(0.40, 0.78, 1.0, 0.25), 5.0, true)
		return
	var side := Vector2(-dir.y, dir.x)
	var center := player_pos + dir * 4.0
	var nose := center + dir * 34.0
	var tail := center - dir * 25.0
	var wing_left := center - dir * 4.0 + side * 28.0
	var wing_right := center - dir * 4.0 - side * 28.0
	var glow_alpha := 0.14 + sin(elapsed * 11.0) * 0.03
	draw_circle(center, 38.0, Color(0.28, 0.90, 1.0, glow_alpha))
	draw_colored_polygon(PackedVector2Array([nose, wing_left, tail, wing_right]), Color(0.62, 0.96, 1.0, 0.32))
	draw_line(tail, nose, Color(1.0, 1.0, 1.0, 0.72), 4.0, true)
	draw_line(wing_left, nose, Color("#7deeff"), 3.0, true)
	draw_line(wing_right, nose, Color("#7deeff"), 3.0, true)
	draw_line(tail, tail - dir * 18.0 + side * 8.0, Color(0.40, 0.78, 1.0, 0.28), 5.0, true)
	draw_line(tail, tail - dir * 18.0 - side * 8.0, Color(0.40, 0.78, 1.0, 0.28), 5.0, true)

func _draw_player() -> void:
	_draw_song_spotlight_player_underlay()
	if player_sprite != null:
		_draw_player_sprite()
		_draw_genre_stg_player_overlay()
		_draw_song_spotlight_player_overlay()
		_draw_player_no_brake_sweat()
		_draw_invincible_label()
		_draw_player_hp_bar()
		_draw_player_dash_status_icon()
		return
	_draw_player_fallback()
	_draw_genre_stg_player_overlay()
	_draw_song_spotlight_player_overlay()
	_draw_player_no_brake_sweat()
	_draw_invincible_label()
	_draw_player_hp_bar()
	_draw_player_dash_status_icon()

func _song_spotlight_benefit_active() -> bool:
	return _is_song_frame() and (song_spotlight_inside_last_frame or song_spotlight_benefit_flash_timer > 0.0)

func _draw_song_spotlight_player_underlay() -> void:
	if not _song_spotlight_benefit_active():
		return
	var flash := clampf(song_spotlight_benefit_flash_timer / 0.45, 0.0, 1.0)
	var pulse := 0.5 + 0.5 * sin(elapsed * 8.0)
	var alpha := 0.34 + flash * 0.22
	var base_radius := 46.0 + pulse * 5.0 + flash * 10.0
	draw_circle(player_pos + Vector2(0.0, -5.0), base_radius + 18.0, Color(1.0, 0.82, 0.20, 0.13 * alpha))
	draw_circle(player_pos + Vector2(0.0, -8.0), base_radius + 7.0, Color(1.0, 1.0, 1.0, 0.16 * alpha))
	draw_circle(player_pos + Vector2(0.0, -4.0), base_radius, Color(1.0, 0.72, 0.18, 0.30 * alpha), false, 4.0 + flash * 2.0)
	draw_circle(player_pos + Vector2(0.0, -4.0), base_radius * 0.68, Color(0.75, 0.92, 1.0, 0.18 * alpha), false, 2.4)
	for i in range(6):
		var angle := elapsed * 1.5 + float(i) * TAU / 6.0
		var from_pos := player_pos + Vector2(cos(angle), sin(angle)) * (base_radius * 0.72)
		var to_pos := player_pos + Vector2(0.0, -36.0) + Vector2(cos(angle) * 9.0, sin(angle) * 5.0)
		draw_line(from_pos, to_pos, Color(1.0, 0.88, 0.36, (0.12 + flash * 0.08) * alpha), 2.4, true)

func _draw_song_spotlight_player_overlay() -> void:
	if not _song_spotlight_benefit_active():
		return
	var flash := clampf(song_spotlight_benefit_flash_timer / 0.45, 0.0, 1.0)
	var pulse := 0.5 + 0.5 * sin(elapsed * 7.0)
	var aura_alpha := 0.70 + flash * 0.25
	draw_circle(player_pos + Vector2(0.0, -34.0), 18.0 + pulse * 5.0 + flash * 6.0, Color(1.0, 1.0, 1.0, 0.12 * aura_alpha))
	draw_circle(player_pos + Vector2(0.0, -34.0), 13.0 + flash * 4.0, Color(1.0, 0.80, 0.24, 0.18 * aura_alpha), false, 2.2)
	for i in range(7):
		var phase := elapsed * 2.2 + float(i) * TAU / 7.0
		var orbit := 30.0 + 12.0 * absf(sin(elapsed * 1.4 + float(i)))
		var sparkle := player_pos + Vector2(cos(phase) * orbit, -30.0 + sin(phase) * 22.0)
		var sparkle_color := Color("#ffe177") if i % 2 == 0 else Color("#8eeaff")
		DrawPrimitiveSystemScript.draw_spark(self, sparkle, 4.2 + pulse * 2.4 + flash * 2.0, Color(sparkle_color.r, sparkle_color.g, sparkle_color.b, (0.56 + flash * 0.28) * aura_alpha))
	if flash > 0.02:
		var label_pos := player_pos + Vector2(-48.0, -72.0 - flash * 10.0)
		_draw_outlined_text(label_pos, "視聴者+", 96, 18, Color(1.0, 0.72, 0.16, 0.92 * flash), Color(1.0, 1.0, 1.0, 0.70 * flash), HORIZONTAL_ALIGNMENT_CENTER)

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
	var bar: Dictionary = DrawDataSystemScript.player_hp_bar_data(player_pos, player_hp, player_max_hp, hide_hp, elapsed, _displayed_mental_hud_ratio())
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

func _draw_enemies(visible_rect: Rect2) -> void:
	EnemyDrawSystemScript.draw_enemies(self, enemies, visible_rect)

func _draw_exp(visible_rect: Rect2) -> void:
	ExpDrawSystemScript.draw_exp_orbs(self, exp_orbs, elapsed, visible_rect)

func _draw_mallow(visible_rect: Rect2) -> void:
	for item in marshmallows:
		var mallow: Dictionary = item as Dictionary
		var pos := Vector2(mallow.get("pos", Vector2.ZERO))
		if not visible_rect.has_point(pos):
			continue
		var data: Dictionary = mallow["data"] as Dictionary
		_draw_mallow_item(DrawDataSystemScript.marshmallow_draw_data(pos, data, float(mallow["time"]), elapsed, maro_appraisal, String(mallow.get("speechText", ""))))

func _draw_mallow_item(visual: Dictionary) -> void:
	var icon_path: String = String(visual.get("imagePath", ""))
	if icon_path != "":
		_draw_shadow(visual["shadowPos"] as Vector2, visual["shadowSize"] as Vector2, float(visual["shadowAlpha"]))
		_draw_field_icon(icon_path, visual["pos"] as Vector2, visual["imageSize"] as Vector2)
		if bool(visual["warning"]):
			_draw_text_item(visual, "warning")
		DrawPrimitiveSystemScript.draw_time_text_item(self, visual)
		if visual.has("speech") and not (visual["speech"] as Dictionary).is_empty():
			_draw_speech_bubble(visual["speech"] as Dictionary)
		return
	for part in DrawDataSystemScript.marshmallow_parts(visual):
		_draw_simple_draw_part(visual, part as Dictionary)

func _draw_destructibles(visible_rect: Rect2) -> void:
	for item in destructibles:
		var box: Dictionary = item as Dictionary
		if float(box.get("hp", 0.0)) <= 0.0:
			continue
		if not visible_rect.has_point(Vector2(box.get("pos", Vector2.ZERO))):
			continue
		if String(box.get("id", "")) == "horror_fake_gift":
			_draw_genre_horror_fake_gift(box)
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

func _draw_drop_items(visible_rect: Rect2) -> void:
	for item in drop_items:
		var drop: Dictionary = item as Dictionary
		if not visible_rect.has_point(Vector2(drop.get("pos", Vector2.ZERO))):
			continue
		_draw_drop_item(drop)

func _draw_drop_item(drop: Dictionary) -> void:
	var pos: Vector2 = Vector2(drop["pos"])
	var id: String = String(drop["id"])
	var bob := sin(elapsed * 9.0 + pos.x * 0.02) * 3.0
	pos.y += bob
	if id == "song_live_gift" or id == "song_special_live_gift":
		_draw_song_live_gift_drop(pos, id == "song_special_live_gift")
		return
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

func _draw_song_live_gift_drop(pos: Vector2, special: bool) -> void:
	var pulse := 0.5 + 0.5 * sin(elapsed * (7.5 if special else 6.0) + pos.x * 0.01)
	var texture_path := SONG_SPECIAL_LIVE_GIFT_IMAGE if special else SONG_LIVE_GIFT_IMAGE
	var texture: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, texture_path)
	if texture != null:
		var base_height := 96.0 if special else 84.0
		var aspect := float(texture.get_width()) / maxf(1.0, float(texture.get_height()))
		var image_size := Vector2(base_height * aspect, base_height) * (1.0 + pulse * (0.045 if special else 0.035))
		_draw_shadow(pos + Vector2(0.0, image_size.y * 0.32), Vector2(image_size.x * 0.55, image_size.y * 0.15), 0.20 if special else 0.16)
		draw_circle(pos, image_size.y * (0.48 + pulse * 0.04), Color(1.0, 0.78, 0.24, 0.12 if special else 0.08), true)
		draw_texture_rect(texture, Rect2(pos - image_size * 0.5, image_size), false, Color.WHITE)
		return
	var size := Vector2(66.0, 62.0) if special else Vector2(56.0, 54.0)
	var body := Rect2(pos - size * 0.5, size)
	var accent := Color("#ff6fbd") if special else Color("#58d9f7")
	var ribbon := Color("#ff73bd") if special else Color("#8eeaff")
	var label := "SP" if special else "LIVE"
	var label_color := Color("#ff4fa8") if special else Color("#00a8c8")
	_draw_shadow(pos + Vector2(0.0, size.y * 0.34), Vector2(size.x * 0.74, 14.0), 0.20 if special else 0.16)
	draw_circle(pos, 42.0 + pulse * 5.0, Color(1.0, 0.46, 0.86, 0.16 if special else 0.08), true)
	draw_circle(pos, 30.0 + pulse * 4.0, Color(0.55, 0.92, 1.0, 0.11), true)
	draw_rect(body, Color("#fff7ff") if special else Color("#f8ffff"), true)
	_draw_rect_outline(body, accent, 3)
	draw_rect(Rect2(body.position + Vector2(body.size.x * 0.42, 0.0), Vector2(body.size.x * 0.16, body.size.y)), ribbon, true)
	draw_rect(Rect2(body.position + Vector2(0.0, body.size.y * 0.40), Vector2(body.size.x, body.size.y * 0.16)), ribbon, true)
	draw_line(pos + Vector2(-17.0, -size.y * 0.50), pos + Vector2(0.0, -size.y * 0.72), Color("#ff8fd0"), 4.0, true)
	draw_line(pos + Vector2(17.0, -size.y * 0.50), pos + Vector2(0.0, -size.y * 0.72), Color("#8eeaff"), 4.0, true)
	_draw_outlined_text(pos + Vector2(-24.0, 8.0), label, 48, 16, label_color, Color(1.0, 1.0, 1.0, 0.78), HORIZONTAL_ALIGNMENT_CENTER)
	var sparkle_count := 6 if special else 4
	for i in range(sparkle_count):
		var angle := elapsed * (1.8 if special else 1.2) + float(i) * TAU / float(sparkle_count)
		var spark := pos + Vector2(cos(angle), sin(angle)) * (36.0 + pulse * 5.0)
		draw_circle(spark, 3.0 if special else 2.4, Color(1.0, 1.0, 1.0, 0.72), true)

func _load_field_icon(path: String) -> Texture2D:
	return TextureCacheSystemScript.load_png_texture(field_pickup_icon_cache, path)

func _draw_field_icon(path: String, center: Vector2, size: Vector2, alpha: float = 1.0) -> bool:
	var texture: Texture2D = _load_field_icon(path)
	if texture == null:
		return false
	_draw_shadow(center + Vector2(0, size.y * 0.30), Vector2(size.x * 0.76, size.y * 0.18), 0.18 * alpha)
	draw_texture_rect(texture, Rect2(center - size * 0.5, size), false, Color(1.0, 1.0, 1.0, alpha))
	return true

func _draw_enemy_bullets(visible_rect: Rect2) -> void:
	WeaponDrawSystemScript.draw_bullets(self, enemy_bullets, false, Callable(), Callable(), visible_rect)

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

func _draw_boss_guide_lines() -> void:
	for item in boss_guide_lines:
		var line: Dictionary = item as Dictionary
		var from_pos := Vector2(line.get("from", Vector2.ZERO))
		var to_pos := Vector2(line.get("to", Vector2.ZERO))
		var width := float(line.get("width", 58.0))
		var dir := to_pos - from_pos
		var length := dir.length()
		if length <= 0.1:
			continue
		dir /= length
		var side := Vector2(-dir.y, dir.x)
		if bool(line.get("hit", false)):
			var flash_life := clampf(float(line.get("flashLife", 0.0)) / 0.16, 0.0, 1.0)
			_draw_boss_guide_line_hit(from_pos, to_pos, dir, side, width, flash_life)
			continue
		var timer := float(line.get("timer", 0.0))
		var max_timer := maxf(0.01, float(line.get("maxTimer", 0.72)))
		var progress := clampf(1.0 - timer / max_timer, 0.0, 1.0)
		_draw_boss_guide_line_warning(from_pos, to_pos, dir, side, width, progress)

func _draw_boss_guide_beam_body(from_pos: Vector2, to_pos: Vector2, side: Vector2, half_width: float, alpha: float, hot: bool = false) -> void:
	var points := PackedVector2Array([
		from_pos - side * half_width,
		to_pos - side * half_width * 0.92,
		to_pos + side * half_width * 0.92,
		from_pos + side * half_width
	])
	var colors := PackedColorArray([
		Color(0.16, 0.00, 0.08, 0.08 * alpha),
		Color(1.0, 0.04, 0.24, (0.38 if hot else 0.24) * alpha),
		Color(1.0, 0.28, 0.68, (0.34 if hot else 0.22) * alpha),
		Color(0.10, 0.00, 0.12, 0.08 * alpha)
	])
	draw_polygon(points, colors)

func _draw_boss_guide_line_warning(from_pos: Vector2, to_pos: Vector2, dir: Vector2, side: Vector2, width: float, progress: float) -> void:
	var pulse := 0.5 + 0.5 * sin(elapsed * 18.0)
	var alpha := 0.48 + progress * 0.34
	var half_width := width * (0.39 + progress * 0.10)
	draw_line(from_pos, to_pos, Color(0.02, 0.00, 0.05, 0.34 + progress * 0.22), width * (1.66 + progress * 0.20), true)
	draw_line(from_pos, to_pos, Color(1.0, 0.04, 0.24, 0.18 + progress * 0.22), width * (1.24 + progress * 0.22), true)
	_draw_boss_guide_beam_body(from_pos, to_pos, side, half_width, alpha, false)
	draw_line(from_pos - side * half_width * 0.78, to_pos - side * half_width * 0.72, Color(1.0, 0.13, 0.24, 0.56 * alpha), 3.4 + pulse * 1.4, true)
	draw_line(from_pos + side * half_width * 0.78, to_pos + side * half_width * 0.72, Color(0.72, 0.92, 1.0, 0.34 * alpha), 2.6 + pulse * 1.1, true)
	draw_line(from_pos, to_pos, Color(0.80, 0.98, 1.0, (0.36 + pulse * 0.18) * alpha), maxf(4.5, width * (0.09 + progress * 0.035)), true)
	_draw_boss_guide_scans(from_pos, to_pos, dir, side, width, alpha, progress, false)

func _draw_boss_guide_line_hit(from_pos: Vector2, to_pos: Vector2, dir: Vector2, side: Vector2, width: float, flash_life: float) -> void:
	var burst := sin(flash_life * PI)
	var half_width := width * (0.58 + burst * 0.10)
	draw_line(from_pos, to_pos, Color(0.01, 0.00, 0.03, 0.56 * flash_life), width * (2.18 + burst * 0.26), true)
	draw_line(from_pos, to_pos, Color(1.0, 0.02, 0.18, 0.48 * flash_life), width * (1.50 + burst * 0.18), true)
	_draw_boss_guide_beam_body(from_pos, to_pos, side, half_width, flash_life, true)
	draw_line(from_pos - side * half_width * 0.76, to_pos - side * half_width * 0.72, Color(1.0, 0.07, 0.12, 0.86 * flash_life), 5.2 + burst * 2.0, true)
	draw_line(from_pos + side * half_width * 0.76, to_pos + side * half_width * 0.72, Color(1.0, 0.42, 0.74, 0.64 * flash_life), 4.2 + burst * 1.6, true)
	draw_line(from_pos, to_pos, Color(1.0, 0.08, 0.40, 0.95 * flash_life), maxf(7.0, width * (0.24 + burst * 0.05)), true)
	draw_line(from_pos, to_pos, Color(1.0, 0.96, 0.98, 0.82 * flash_life), maxf(2.8, width * 0.075), true)
	_draw_boss_guide_scans(from_pos, to_pos, dir, side, width, flash_life, 1.0 - flash_life, true)
	_draw_boss_guide_sparks((from_pos + to_pos) * 0.5, dir, side, width, flash_life, burst)

func _draw_boss_guide_scans(from_pos: Vector2, to_pos: Vector2, dir: Vector2, side: Vector2, width: float, alpha: float, progress: float, hit: bool) -> void:
	var center := (from_pos + to_pos) * 0.5
	var span := 1280.0
	var count := 9 if hit else 7
	for i in range(count):
		var offset := (float(i) - float(count - 1) * 0.5) * (span / float(maxi(1, count - 1)))
		offset += sin(elapsed * 5.5 + float(i) * 1.3) * 24.0 + progress * 72.0
		var p := center + dir * offset
		var length := width * (0.52 if hit else 0.42)
		var scan_alpha := (0.22 if hit else 0.13) * alpha
		var color := Color(1.0, 0.88, 0.92, scan_alpha) if i % 2 == 0 else Color(0.58, 0.96, 1.0, scan_alpha * 0.85)
		draw_line(p - side * length - dir * width * 0.15, p + side * length + dir * width * 0.15, color, 2.4 if hit else 1.8, true)

func _draw_boss_guide_sparks(center: Vector2, dir: Vector2, side: Vector2, width: float, alpha: float, burst: float) -> void:
	for i in range(6):
		var p := center + dir * ((float(i) - 2.5) * width * 1.6) + side * sin(elapsed * 7.0 + float(i)) * width * 0.36
		var spark_dir := (dir * (0.52 + burst * 0.20) + side * (0.58 if i % 2 == 0 else -0.58)).normalized()
		var size := width * (0.18 + 0.08 * burst)
		var color := Color(1.0, 0.92, 0.58, 0.44 * alpha)
		draw_line(p - spark_dir * size, p + spark_dir * size * 1.6, color, 2.0 + burst * 1.2, true)
		draw_line(p - side * size * 0.62, p + side * size * 0.62, Color(0.78, 0.96, 1.0, 0.30 * alpha), 1.5 + burst * 0.8, true)

func _draw_player_bullets(visible_rect: Rect2) -> void:
	WeaponDrawSystemScript.draw_bullets(
		self,
		player_bullets,
		true,
		Callable(self, "_draw_rotated_texture"),
		Callable(self, "_load_raw_png_texture"),
		visible_rect
	)

func _draw_boomerang() -> void:
	if _normal_weapons_disabled_by_song_bad_light():
		return
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
		equipment_bullet_support_level,
		Callable(self, "_load_raw_png_texture")
	)

func _load_raw_png_texture(path: String) -> Texture2D:
	return TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, path)

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

func _draw_hit_fx(field_layer: bool = false, draw_items: Variant = null) -> void:
	var fx_draw_items: Array = []
	if draw_items is Array:
		fx_draw_items = draw_items as Array
	else:
		fx_draw_items = DrawDataSystemScript.hit_fx_draw_data(hit_fx)
	for fx in fx_draw_items:
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

func _draw_ui_card_v25(rect: Rect2, label: String, value: String, accent: Color, icon_text: String = "", border_color: Color = Color("#ffc1da"), border_width: int = 2, icon_path: String = "", value_alignment: int = HORIZONTAL_ALIGNMENT_LEFT, value_size_override: int = -1) -> void:
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
		value_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	elif image_drawn and int(round(rect.size.x)) == 198:
		text_x = rect.position.x + 66.0
	var text_width: int = maxi(24, int(rect.end.x - text_x - 18.0))
	var value_size := value_size_override if value_size_override > 0 else 27
	_draw_text_item({"pos": Vector2(text_x, rect.position.y + 30), "text": label, "width": text_width, "size": 15, "color": Color("#101420")})
	_draw_text_item({"pos": Vector2(text_x, rect.position.y + 65), "text": value, "width": text_width, "size": value_size, "color": Color("#101420")}, "", value_alignment)

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
	var bonus_text := "撃破スコア +%d%%" % (burn_combo * 10)
	var bonus_rect := Rect2(Vector2(text_x - 18.0, rect.position.y + 58.0), Vector2(float(text_width) + 23.0, 18.0))
	_draw_ranking_panel(bonus_rect, Color(1.0, 1.0, 1.0, 0.70), Color(1.0, 0.58, 0.86, 0.46), 8, 1, false)
	draw_line(bonus_rect.position + Vector2(7.0, 3.0), bonus_rect.position + Vector2(bonus_rect.size.x - 7.0, 3.0), Color(0.72, 0.94, 1.0, 0.34), 1.0)
	_draw_text_item({"pos": Vector2(text_x + 1.0, rect.position.y + 74.0), "text": bonus_text, "width": text_width, "size": 13, "color": Color(0.34, 0.12, 0.48, 0.26)})
	_draw_text_item({"pos": Vector2(text_x, rect.position.y + 73.0), "text": bonus_text, "width": text_width, "size": 13, "color": Color("#8a37cf")})

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
	return "%s人" % DrawDataSystemScript.format_viewer_count(displayed_viewer_score)

func _time_hud_text() -> String:
	var remaining: int = maxi(0, int(ceil(RunStateSystemScript.run_length(quick_test_mode, QUICK_RUN_LENGTH, NORMAL_RUN_LENGTH) - elapsed)))
	return "%02d:%02d" % [remaining / 60, remaining % 60]

func _current_instruction_hud_text() -> String:
	var text: String = current_comment.strip_edges()
	if not active_sub_comment_ids.is_empty():
		return "%s　%02d秒\n%s" % [text, maxi(0, int(ceil(effect_timer))), _active_sub_instruction_text()]
	if text == "" or text == "なし":
		return "なし"
	if _song_lighting_mistake_active():
		return "%s　%02d秒\n暴走ライトを避けろ！ 入ると攻撃停止" % [text, maxi(0, int(ceil(effect_timer)))]
	if ModifierSystemScript.has_effect_for_target(self, "short_range"):
		return "%s　%02d秒\n射程短縮中" % [text, maxi(0, int(ceil(effect_timer)))]
	return "%s　%02d秒" % [text, maxi(0, int(ceil(effect_timer)))]

func _current_instruction_panel_text_v25() -> String:
	var text: String = current_comment.strip_edges()
	if text == "" or text == "なし" or effect_timer <= 0.0:
		return "なし"
	if active_sub_comment_ids.is_empty():
		if _song_lighting_mistake_active():
			return "%s / 入ると攻撃停止" % text
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
	_draw_ui_card_v25(Rect2(20, 18, 198, 80), "配信枠", String(current_stream_frame.get("displayName", "雑談枠")), Color("#6ee7f0"), "▣", Color("#d8eaf4"), 1, "", HORIZONTAL_ALIGNMENT_LEFT, 19)
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
	return "%d%%" % int(round(_displayed_mental_hud_ratio() * 100.0))

func _mental_hud_ratio() -> float:
	if ModifierSystemScript.has_effect_for_target(self, "hide_hp"):
		return DrawDataSystemScript.fake_hp_ratio(elapsed)
	if player_max_hp <= 0:
		return 0.0
	return clampf(float(player_hp) / float(player_max_hp), 0.0, 1.0)

func _displayed_mental_hud_ratio() -> float:
	if not mental_gauge_display_initialized:
		return _mental_hud_ratio()
	return clampf(displayed_mental_ratio, 0.0, 1.0)

func _mental_hud_fill_color(ratio: float) -> Color:
	if ModifierSystemScript.has_effect_for_target(self, "hide_hp"):
		return Color("#9ca3af")
	if ratio <= 0.25:
		return Color("#ff4f8f")
	if ratio <= 0.55:
		return Color("#ffd166")
	return Color("#4ade80")

func _draw_mental_hud_card_v25(rect: Rect2) -> void:
	var ratio := _displayed_mental_hud_ratio()
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
		texture = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, path)
	if texture == null:
		return false
	draw_texture_rect(texture, rect, false)
	return true

func _draw_drawing_canvas_progress_layer(map_data: Dictionary) -> void:
	if not _is_drawing_frame():
		return
	var rect_value: Variant = map_data.get("canvasProgressRect", Rect2())
	if not (rect_value is Rect2):
		return
	var paths_value: Variant = map_data.get("canvasProgressPaths", {})
	if not (paths_value is Dictionary):
		return
	var progress_data := _drawing_canvas_progress_layer_data()
	var progress_key := String(progress_data.get("key", "rough"))
	var path := String((paths_value as Dictionary).get(progress_key, ""))
	if path == "":
		return
	var texture: Texture2D = _load_ui_part(path)
	if texture == null:
		texture = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, path)
	if texture == null:
		return
	var local_rect: Rect2 = rect_value as Rect2
	var map_rect: Rect2 = MapBackgroundSystemScript.world_rect(map_data)
	var canvas_rect := Rect2(map_rect.position + local_rect.position, local_rect.size)
	var draw_rect := _fit_texture_rect(canvas_rect.grow(-18.0), texture.get_size())
	var alpha := float(progress_data.get("alpha", 0.22))
	draw_texture_rect(texture, draw_rect, false, Color(1.0, 1.0, 1.0, alpha))

func _drawing_canvas_progress_layer_data() -> Dictionary:
	var progress := clampf(drawing_progress, 0.0, 100.0)
	if progress >= 100.0:
		return {"key": "complete", "alpha": 0.42}
	if progress >= 75.0:
		return {"key": "finish", "alpha": 0.30 + (progress - 75.0) / 25.0 * 0.08}
	if progress >= 50.0:
		return {"key": "finish", "alpha": 0.21 + (progress - 50.0) / 25.0 * 0.07}
	if progress >= 25.0:
		return {"key": "lineart", "alpha": 0.20 + (progress - 25.0) / 25.0 * 0.05}
	return {"key": "rough", "alpha": 0.14 + progress / 25.0 * 0.07}

func _load_ui_part(path: String) -> Texture2D:
	return TextureCacheSystemScript.load_resource_texture(ui_part_cache, path)

func _draw_equipment_icons() -> void:
	_draw_equipment_icon_row(player_weapons, weapons, Vector2(992, 821), true)
	_draw_equipment_icon_row(player_accessories, gifts, Vector2(1312, 821), false)
	if _normal_weapons_disabled_by_song_bad_light():
		_draw_bad_light_weapon_stop_badge()

func _draw_bad_light_weapon_stop_badge() -> void:
	var rect := Rect2(Vector2(1003, 805), Vector2(184, 24))
	var blink := 0.74 + 0.26 * sin(elapsed * 20.0)
	_draw_ranking_panel(rect, Color(1.0, 0.94, 0.99, 0.92), Color(0.95, 0.05, 0.50, 0.92 * blink), 7, 2, false)
	_draw_text_item({
		"pos": rect.position + Vector2(0, 18),
		"text": "通常武器 攻撃停止",
		"width": int(rect.size.x),
		"size": 16,
		"color": Color("#e40068"),
		"fontWeight": "bold"
	}, "", HORIZONTAL_ALIGNMENT_CENTER)

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

func _draw_stream_end_countdown_overlay() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if stream_end_banner_timer > 0.0:
		var banner_progress := clampf(1.0 - stream_end_banner_timer / maxf(0.01, stream_end_banner_duration), 0.0, 1.0)
		_draw_stream_end_banner_overlay(banner_progress)
		return
	var run_length := RunStateSystemScript.run_length(quick_test_mode, QUICK_RUN_LENGTH, NORMAL_RUN_LENGTH)
	var remaining := maxf(0.0, run_length - elapsed)
	if remaining <= 0.0 or remaining > float(END_COUNTDOWN_START_SECONDS):
		return
	var second := int(ceil(remaining))
	if second < 1 or second > END_COUNTDOWN_START_SECONDS:
		return
	var progress := clampf(float(second) - remaining, 0.0, 1.0)
	_draw_stream_end_number_overlay(str(second), progress, second == 1)

func _draw_stream_end_number_overlay(text: String, progress: float, emphasized: bool) -> void:
	var center := Vector2(TITLE_SCREEN_RECT.size.x * 0.5, FIELD_VIEW.position.y + FIELD_VIEW.size.y * 0.46)
	var pop_t := clampf(progress / 0.22, 0.0, 1.0)
	var pop_eased := 1.0 - pow(1.0 - pop_t, 3.0)
	var scale := lerpf(1.38 if emphasized else 1.30, 1.0, pop_eased) + sin(progress * PI) * (0.055 if emphasized else 0.035)
	var fade_t := clampf((progress - 0.70) / 0.30, 0.0, 1.0)
	var alpha := clampf(1.0 - fade_t, 0.0, 1.0)
	var base_size := 178 if emphasized else 158
	var size := maxi(40, int(round(float(base_size) * scale)))
	var glow_radius := (128.0 if emphasized else 112.0) * scale
	_draw_stream_end_glow(center, glow_radius, alpha, progress, emphasized)
	_draw_stream_end_countdown_text(text, center, 520.0, size, alpha, emphasized)

func _draw_stream_end_banner_overlay(progress: float) -> void:
	var center := Vector2(TITLE_SCREEN_RECT.size.x * 0.5, FIELD_VIEW.position.y + FIELD_VIEW.size.y * 0.46)
	var enter := clampf(progress / 0.22, 0.0, 1.0)
	var exit := clampf((progress - 0.74) / 0.26, 0.0, 1.0)
	var alpha := clampf(minf(enter / 0.85, 1.0 - exit), 0.0, 1.0)
	var scale := lerpf(1.18, 1.0, 1.0 - pow(1.0 - enter, 3.0))
	_draw_stream_end_glow(center, 156.0 * scale, alpha, progress, true)
	_draw_stream_end_countdown_text("LIVE END", center, 760.0, int(round(88.0 * scale)), alpha, true)

func _draw_stream_end_glow(center: Vector2, radius: float, alpha: float, progress: float, emphasized: bool) -> void:
	if alpha <= 0.0:
		return
	draw_circle(center, radius * 1.10, Color(1.0, 0.46, 0.74, 0.13 * alpha))
	draw_circle(center, radius * 0.78, Color(0.57, 0.92, 1.0, 0.12 * alpha))
	draw_circle(center, radius * 0.48, Color(0.78, 0.64, 1.0, 0.10 * alpha))
	var ring_alpha := (0.34 if emphasized else 0.25) * alpha
	draw_arc(center, radius * 0.92, -PI * 0.15 + progress * TAU * 0.35, PI * 1.55 + progress * TAU * 0.35, 72, Color(1.0, 0.58, 0.82, ring_alpha), 5.0)
	draw_arc(center, radius * 0.70, PI * 0.15 - progress * TAU * 0.28, PI * 1.75 - progress * TAU * 0.28, 72, Color(0.53, 0.88, 1.0, ring_alpha * 0.78), 3.5)
	for i in range(8):
		var angle := progress * TAU * 0.18 + float(i) * TAU / 8.0
		var sparkle_center := center + Vector2(cos(angle), sin(angle)) * radius * (0.80 + 0.05 * sin(progress * TAU + float(i)))
		var sparkle_size := (8.0 if emphasized else 6.0) * alpha
		var sparkle_color := Color(1.0, 0.98, 1.0, 0.30 * alpha)
		draw_line(sparkle_center + Vector2(-sparkle_size, 0.0), sparkle_center + Vector2(sparkle_size, 0.0), sparkle_color, 2.0, true)
		draw_line(sparkle_center + Vector2(0.0, -sparkle_size), sparkle_center + Vector2(0.0, sparkle_size), sparkle_color, 2.0, true)

func _draw_stream_end_countdown_text(text: String, center: Vector2, width: float, size: int, alpha: float, emphasized: bool) -> void:
	var pos := Vector2(center.x - width * 0.5, center.y + float(size) * 0.35)
	var outer_color := Color(0.95, 0.26, 0.58, 0.88 * alpha)
	var mid_color := Color(0.42, 0.86, 1.0, 0.82 * alpha)
	var inner_color := Color(0.73, 0.54, 1.0, 0.72 * alpha)
	if emphasized:
		outer_color = Color(1.0, 0.22, 0.55, 0.96 * alpha)
		mid_color = Color(0.38, 0.90, 1.0, 0.90 * alpha)
		inner_color = Color(0.90, 0.68, 1.0, 0.82 * alpha)
	var offsets: Array[Vector2] = [
		Vector2(-1.0, 0.0),
		Vector2(1.0, 0.0),
		Vector2(0.0, -1.0),
		Vector2(0.0, 1.0),
		Vector2(-0.72, -0.72),
		Vector2(0.72, -0.72),
		Vector2(-0.72, 0.72),
		Vector2(0.72, 0.72)
	]
	_draw_stream_end_text_layer(text, pos, width, size, offsets, 10.0 if emphasized else 8.0, outer_color)
	_draw_stream_end_text_layer(text, pos, width, size, offsets, 6.0 if emphasized else 5.0, mid_color)
	_draw_stream_end_text_layer(text, pos, width, size, offsets, 3.0, inner_color)
	_draw_text_item({
		"pos": pos + Vector2(0.0, 4.0),
		"text": text,
		"width": int(width),
		"size": size,
		"color": Color(0.12, 0.05, 0.15, 0.20 * alpha),
		"fontWeight": "black"
	}, "", HORIZONTAL_ALIGNMENT_CENTER)
	_draw_text_item({
		"pos": pos,
		"text": text,
		"width": int(width),
		"size": size,
		"color": Color(1.0, 1.0, 1.0, 0.98 * alpha),
		"fontWeight": "black"
	}, "", HORIZONTAL_ALIGNMENT_CENTER)

func _draw_stream_end_text_layer(text: String, pos: Vector2, width: float, size: int, offsets: Array[Vector2], radius: float, color: Color) -> void:
	if color.a <= 0.0:
		return
	for offset in offsets:
		_draw_text_item({
			"pos": pos + offset * radius,
			"text": text,
			"width": int(width),
			"size": size,
			"color": color,
			"fontWeight": "black"
		}, "", HORIZONTAL_ALIGNMENT_CENTER)

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
	if completed:
		_draw_result_clear_rank_panel(rank_rect, data)
	elif mental_breakdown:
		_draw_ranking_panel(rank_rect, Color(1, 1, 1, 0.88), Color("#ffc0dc"), 20, 2, false)
		_draw_ranking_text("今回の配信評価", rank_rect.position + Vector2(24, 54), 20, Color("#c74187"), 150)
		_draw_ranking_text(String(data.get("kamiRank", "D")), rank_rect.position + Vector2(154, 63), 54, _result_rank_color(String(data.get("kamiRank", "D"))), 70, HORIZONTAL_ALIGNMENT_CENTER)
		_draw_ranking_text("%d pt" % int(data.get("kamiPoint", 0)), rank_rect.position + Vector2(244, 58), 34, Color("#7a56c8"), 130)
	else:
		_draw_ranking_panel(rank_rect, Color(1, 1, 1, 0.88), Color("#d7c5ff"), 20, 2, false)
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
		{"icon": "person", "label": "配信者", "value": String(data.get("characterName", "配信者")), "tone": Color("#ff8fc2")},
		{"icon": "chat", "label": "配信枠", "value": String(data.get("streamFrameName", "配信枠")), "tone": Color("#82dff2")},
		{"icon": "viewers", "label": "最大同時視聴者数", "value": "%s 人" % _result_number(int(data.get("viewerCount", data.get("score", 0)))), "tone": Color("#ff5aa5"), "primary": true},
		{"icon": "time", "label": "生存時間", "value": ResultSystemScript.format_time(float(data.get("survivalTime", 0.0))), "tone": Color("#a875e8"), "emphasis": true},
		{"icon": "voltage", "label": "最大ボルテージ", "value": "x%.1f" % float(data.get("maxVoltage", data.get("maxMultiplier", 1.0))), "tone": Color("#ffb433"), "emphasis": true},
		{"icon": "buzz", "label": "最大バズ度", "value": str(int(data.get("maxBurnCombo", 0))), "tone": Color("#6ccbe8")},
		{"icon": "gift", "label": "ギフト", "value": str(int(data.get("giftCount", 0))), "tone": Color("#ff9fbc")}
	]
	for index in range(rows.size()):
		var row_rect := Rect2(rect.position + Vector2(22, 48 + float(index) * 58.0), Vector2(rect.size.x - 44, 46))
		_draw_result_summary_row(row_rect, rows[index] as Dictionary)

func _draw_result_summary_row(rect: Rect2, row: Dictionary) -> void:
	var label_text: String = String(row.get("label", ""))
	var primary := bool(row.get("primary", false))
	var emphasized := primary or bool(row.get("emphasis", false))
	var tone: Color = row.get("tone", Color("#f05aa5")) as Color
	var fill := Color(1, 0.98, 0.995, 0.96) if primary else (Color(1, 0.992, 0.972, 0.94) if emphasized else Color(1, 1, 1, 0.88))
	var border := Color("#ff78b6") if primary else (Color("#ffc36b") if emphasized else Color("#f4d5e6"))
	_draw_ranking_panel(rect, fill, border, 12, 3 if primary else (2 if emphasized else 1), false)
	var icon_rect := Rect2(rect.position + Vector2(9, 8), Vector2(32, 32))
	_draw_result_summary_icon(icon_rect, String(row.get("icon", "")), tone)
	var label_width := 178.0
	var value_x := 214.0
	if label_text.length() <= 4:
		label_width = 92.0
		value_x = 154.0
	var value_color := Color("#e72f88") if primary else (Color("#c97813") if emphasized else Color("#f05aa5"))
	_draw_ranking_text(label_text, rect.position + Vector2(50, 30), 17, Color("#4f3149"), label_width)
	_draw_ranking_text(_short_pause_text(String(row.get("value", "")), 16), rect.position + Vector2(value_x, 31), 25 if primary else (23 if emphasized else 21), value_color, rect.size.x - value_x - 14.0, HORIZONTAL_ALIGNMENT_RIGHT)

func _draw_result_clear_rank_panel(rect: Rect2, data: Dictionary) -> void:
	_draw_ranking_panel(rect, Color("#fffdf4"), Color("#ffd46a"), 20, 3, false)
	var clock := float(Time.get_ticks_msec()) / 1000.0
	for i in range(6):
		var pos := rect.position + Vector2(166.0 + float(i) * 32.0, 22.0 + sin(clock * 1.8 + float(i)) * 5.0)
		_draw_stream_start_sparkle(pos, 4.5 + float(i % 2) * 1.8, Color(1.0, 0.62, 0.16, 0.30))
	_draw_ranking_panel(Rect2(rect.position + Vector2(140, 12), Vector2(96, 62)), Color(1.0, 0.78, 0.16, 0.12), Color(1, 1, 1, 0), 22, 0, false)
	_draw_ranking_text("配信完走評価", rect.position + Vector2(24, 30), 18, Color("#c97813"), 138)
	_draw_ranking_text(String(data.get("kamiRank", "D")), rect.position + Vector2(146, 70), 64, _result_rank_color(String(data.get("kamiRank", "D"))), 92, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_ranking_text("%d pt" % int(data.get("kamiPoint", 0)), rect.position + Vector2(252, 61), 29, Color("#7a56c8"), 118, HORIZONTAL_ALIGNMENT_CENTER)

func _draw_result_summary_icon(rect: Rect2, kind: String, tone: Color) -> void:
	var center := rect.get_center()
	var bg := Color(tone.r, tone.g, tone.b, 0.16)
	draw_circle(center, rect.size.x * 0.5, bg)
	draw_arc(center, rect.size.x * 0.43, 0.0, TAU, 28, Color(tone.r, tone.g, tone.b, 0.42), 1.6, true)
	match kind:
		"person":
			draw_circle(center + Vector2(0, -6), 5.0, tone)
			draw_circle(center + Vector2(0, 7), 8.0, Color(tone.r, tone.g, tone.b, 0.78))
		"chat":
			var bubble := Rect2(rect.position + Vector2(7, 8), Vector2(18, 13))
			_draw_ranking_panel(bubble, Color(tone.r, tone.g, tone.b, 0.72), Color(1, 1, 1, 0), 5, 0, false)
			draw_colored_polygon(PackedVector2Array([bubble.position + Vector2(5, 12), bubble.position + Vector2(9, 18), bubble.position + Vector2(12, 12)]), Color(tone.r, tone.g, tone.b, 0.72))
		"viewers":
			for offset in [Vector2(-7, -4), Vector2(0, -7), Vector2(7, -4)]:
				draw_circle(center + offset, 3.5, tone)
			draw_rect(Rect2(center + Vector2(-12, 4), Vector2(24, 7)), Color(tone.r, tone.g, tone.b, 0.72), true)
		"time":
			draw_arc(center, 9.0, 0.0, TAU, 24, tone, 2.2, true)
			draw_line(center, center + Vector2(0, -6), tone, 2.0, true)
			draw_line(center, center + Vector2(5, 3), tone, 2.0, true)
		"voltage":
			draw_colored_polygon(PackedVector2Array([
				center + Vector2(1, -13),
				center + Vector2(-8, 2),
				center + Vector2(-1, 1),
				center + Vector2(-4, 13),
				center + Vector2(9, -3),
				center + Vector2(2, -2)
			]), tone)
		"buzz":
			draw_line(center + Vector2(-8, 8), center + Vector2(7, -7), tone, 3.0, true)
			draw_line(center + Vector2(7, -7), center + Vector2(7, 2), tone, 3.0, true)
			draw_line(center + Vector2(7, -7), center + Vector2(-2, -7), tone, 3.0, true)
			_draw_stream_start_sparkle(center + Vector2(-8, -6), 3.5, Color(tone.r, tone.g, tone.b, 0.72))
		"gift":
			var box := Rect2(center + Vector2(-8, -2), Vector2(16, 12))
			var lid := Rect2(center + Vector2(-10, -8), Vector2(20, 7))
			_draw_ranking_panel(lid, tone, Color(1, 1, 1, 0), 3, 0, false)
			_draw_ranking_panel(box, Color(tone.r, tone.g, tone.b, 0.62), Color(1, 1, 1, 0), 3, 0, false)
			draw_rect(Rect2(box.position + Vector2(7, 0), Vector2(2, 12)), Color(1, 1, 1, 0.60), true)
		_:
			_draw_stream_start_sparkle(center, 8.0, tone)

func _draw_result_highlight_row(rect: Rect2, row: Dictionary) -> void:
	var accent := bool(row.get("accent", false))
	_draw_ranking_panel(rect, Color("#fff8ea") if accent else Color(1, 1, 1, 0.72), Color("#ffd98a") if accent else Color("#f0dfca"), 9, 1, false)
	var tone := Color("#ff9f1c") if accent else Color("#a875e8")
	_draw_result_highlight_icon(Rect2(rect.position + Vector2(5, 4), Vector2(16, 16)), String(row.get("icon", "")), tone)
	_draw_ranking_text(String(row.get("label", "")), rect.position + Vector2(26, 17), 12, Color("#9a6a2a"), 100)
	_draw_ranking_text(_short_pause_text(String(row.get("value", "")), 28), rect.position + Vector2(124, 18), 14, Color("#4f3149") if not accent else Color("#d77b10"), rect.size.x - 132)

func _draw_result_highlight_icon(rect: Rect2, kind: String, tone: Color) -> void:
	var center := rect.get_center()
	draw_circle(center, rect.size.x * 0.5, Color(tone.r, tone.g, tone.b, 0.18))
	match kind:
		"check":
			draw_line(center + Vector2(-5, 0), center + Vector2(-1, 5), tone, 2.2, true)
			draw_line(center + Vector2(-1, 5), center + Vector2(6, -5), tone, 2.2, true)
		"comment":
			_draw_ranking_panel(Rect2(rect.position + Vector2(3, 4), Vector2(10, 8)), Color(tone.r, tone.g, tone.b, 0.72), Color(1, 1, 1, 0), 3, 0, false)
		"boss":
			draw_colored_polygon(PackedVector2Array([center + Vector2(0, -7), center + Vector2(-7, 6), center + Vector2(7, 6)]), Color(tone.r, tone.g, tone.b, 0.70))
		_:
			_draw_stream_start_sparkle(center, 5.5, tone)

func _result_ranking_rank_number(text: String) -> int:
	var rank_end := text.find("位")
	if rank_end < 0:
		return 0
	var digits := ""
	for i in range(rank_end - 1, -1, -1):
		var ch := text.substr(i, 1)
		if "0123456789".contains(ch):
			digits = ch + digits
		elif digits != "":
			break
	if digits == "":
		return 0
	return int(digits)

func _result_ranking_card_view(text: String) -> Dictionary:
	var registered := text.contains("ランキング登録")
	if registered:
		var rank := ""
		var rank_start := text.find("：")
		var rank_end := text.find("位", rank_start + 1)
		if rank_start >= 0 and rank_end > rank_start:
			rank = text.substr(rank_start + 1, rank_end - rank_start)
		if rank == "":
			rank = "記録"
		var rank_number := _result_ranking_rank_number(text)
		var subtitle := "記録を保存！"
		if rank_number > 0:
			subtitle = "TOP10入り！" if rank_number <= 10 else "%d位に登録！" % rank_number
		return {"title": "ランキング登録！", "rank": rank, "subtitle": subtitle}
	var body := text
	var separator := body.find("：")
	if separator >= 0:
		body = body.substr(separator + 1).strip_edges()
	if body == "":
		body = "次はTOP10入りを目指そう！"
	return {"title": "ランキング圏外", "subtitle": body}

func _draw_result_crown_icon(rect: Rect2, color: Color) -> void:
	_draw_ranking_panel(rect, Color(color.r, color.g, color.b, 0.15), Color(color.r, color.g, color.b, 0.34), 14, 2, false)
	var p := rect.position
	var crown := PackedVector2Array([
		p + Vector2(9, 31),
		p + Vector2(13, 17),
		p + Vector2(22, 25),
		p + Vector2(30, 12),
		p + Vector2(38, 25),
		p + Vector2(44, 17),
		p + Vector2(40, 31)
	])
	draw_colored_polygon(crown, color)
	draw_rect(Rect2(p + Vector2(11, 31), Vector2(30, 6)), Color("#ffe28a"), true)
	for dot in [p + Vector2(13, 17), p + Vector2(30, 12), p + Vector2(44, 17)]:
		draw_circle(dot, 3.0, Color("#fff7c7"))

func _draw_result_podium_icon(rect: Rect2, color: Color, crown: bool = true) -> void:
	_draw_ranking_panel(rect, Color(color.r, color.g, color.b, 0.12), Color(color.r, color.g, color.b, 0.26), 14, 2, false)
	var base := rect.position + Vector2(10, 32)
	draw_rect(Rect2(base + Vector2(0, 2), Vector2(8, 10)), Color(color.r, color.g, color.b, 0.48), true)
	draw_rect(Rect2(base + Vector2(10, -7), Vector2(10, 19)), color, true)
	draw_rect(Rect2(base + Vector2(22, -1), Vector2(8, 13)), Color(color.r, color.g, color.b, 0.58), true)
	if crown:
		_draw_stream_start_sparkle(rect.position + Vector2(34, 15), 5.5, Color("#ffd15a"))

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
			{"icon": "check", "label": "完走結果", "value": "最後まで配信を走り切った！", "accent": true},
			{"icon": "comment", "label": "ラスト指示コメ", "value": String(data.get("lastInstructionComment", "なし")), "accent": true},
			{"icon": "hype", "label": "盛り上がり", "value": "完走おめ！の声で大盛り上がり"},
			{"icon": "spark", "label": "完走ポイント", "value": "メンタルを残して完走", "accent": true}
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
		if completed:
			rows.append({"icon": "boss", "label": boss_label, "value": "%s%s" % [String(data.get("bossName", "ボス")), reward_text], "accent": true})
		else:
			rows.append({"text": "%s：%s%s" % [boss_label, String(data.get("bossName", "ボス")), reward_text], "color": Color("#8d46b5")})
	for index in range(rows.size()):
		var row: Dictionary = rows[index] as Dictionary
		var y: float = 52.0 + float(index) * (24.0 if completed else (18.0 if rows.size() >= 5 else (20.0 if rows.size() >= 4 else 24.0)))
		if completed and row.has("label"):
			_draw_result_highlight_row(Rect2(rect.position + Vector2(18, y - 17.0), Vector2(rect.size.x - 36, 24)), row)
		else:
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
	var text: String = String(data.get("rankingText", ""))
	if text == "":
		text = "ランキング対象外"
	var registered := text.contains("ランキング登録")
	var view := _result_ranking_card_view(text)
	var compact := rect.size.y < 90.0
	var fill := Color("#fff8ea") if registered else Color(1, 1, 1, 0.90)
	var border := Color("#ffd15a") if registered else Color("#d8cdf7")
	_draw_ranking_panel(rect, fill, border, 14, 3 if registered else 2, false)
	var icon_rect := Rect2(rect.position + Vector2(16, 12 if compact else 16), Vector2(48, 48))
	if registered:
		_draw_result_crown_icon(icon_rect, Color("#ffb433"))
	else:
		_draw_result_podium_icon(icon_rect, Color("#a875e8"), false)
	var text_x := 78.0
	if registered:
		_draw_ranking_text(String(view.get("rank", "記録")), rect.position + Vector2(text_x, 51 if compact else 63), 34 if compact else 42, Color("#d77b10"), 96, HORIZONTAL_ALIGNMENT_CENTER)
		_draw_ranking_text(String(view.get("title", "ランキング登録！")), rect.position + Vector2(text_x + 112.0, 28 if compact else 34), 16, Color("#c97813"), rect.size.x - text_x - 126.0)
		_draw_ranking_text(String(view.get("subtitle", "記録を保存！")), rect.position + Vector2(text_x + 112.0, 52 if compact else 61), 16 if compact else 18, Color("#e84f93"), rect.size.x - text_x - 126.0)
		if not compact:
			_draw_ranking_text("ランキングを見る ＞", rect.position + Vector2(rect.size.x - 156.0, 86), 12, Color("#8d46b5"), 132, HORIZONTAL_ALIGNMENT_RIGHT)
	else:
		_draw_ranking_text(String(view.get("title", "ランキング圏外")), rect.position + Vector2(text_x, 34 if compact else 39), 20, Color("#7a56c8"), rect.size.x - text_x - 22.0)
		_draw_ranking_text(String(view.get("subtitle", "次はTOP10入りを目指そう！")), rect.position + Vector2(text_x, 57 if compact else 66), 14, Color("#6b4a63"), rect.size.x - text_x - 22.0)

func _draw_result_equipment_slots(items_value: Variant, source_data: Array, start: Vector2, slot_count: int, slot_size: float = 38.0, slot_step: float = 46.0) -> void:
	var items: Array = []
	if items_value is Array:
		items = items_value as Array
	for index in range(slot_count):
		var slot := Rect2(start + Vector2(float(index) * slot_step, 0), Vector2(slot_size, slot_size))
		if index >= items.size() or not (items[index] is Dictionary):
			_draw_ranking_panel(slot, Color(1, 1, 1, 0.34), Color(0.80, 0.76, 0.88, 0.34), 6, 1, false)
			draw_circle(slot.get_center(), slot.size.x * 0.08, Color(0.62, 0.58, 0.70, 0.22))
			continue
		var item: Dictionary = items[index] as Dictionary
		var data: Dictionary = _find_equipment_icon_data(source_data, String(item.get("id", "")))
		var evolved := EquipmentSystem.is_evolved_entry(item) or bool(data.get("isEvolved", false))
		var item_level := EquipmentSystem.entry_level(item)
		var max_level := int(data.get("maxLevel", 0))
		var high_level := not evolved and max_level > 0 and item_level >= max_level
		if evolved:
			_draw_ranking_panel(slot.grow(4.0), Color(1.0, 0.78, 0.16, 0.16), Color(1, 1, 1, 0), 9, 0, false)
		elif high_level:
			_draw_ranking_panel(slot.grow(2.0), Color(0.66, 0.84, 1.0, 0.14), Color(1, 1, 1, 0), 8, 0, false)
		_draw_ranking_panel(slot, Color("#fff9ec") if evolved else (Color("#f0fbff") if high_level else Color("#fbfbff")), Color("#ffd15a") if evolved else (Color("#82dff2") if high_level else Color("#d8cdf7")), 6, 3 if evolved else (2 if high_level else 1), false)
		var icon: Texture2D = _load_equipment_icon(_equipment_icon_path_for_item(item, source_data))
		if icon != null:
			draw_texture_rect(icon, slot.grow(-3), false)
		else:
			_draw_ranking_text(_short_pause_text(String(item.get("displayName", item.get("id", ""))), 2), slot.position + Vector2(0, slot.size.y * 0.66), 12, Color("#7a56c8"), slot.size.x, HORIZONTAL_ALIGNMENT_CENTER)
		var level_label := _result_equipment_level_label(item, data, evolved, high_level)
		var label_width := minf(slot.size.x, 34.0 if level_label.length() >= 4 else 28.0)
		var label_rect := Rect2(slot.end - Vector2(label_width + 1.0, 13.0), Vector2(label_width, 13.0))
		var label_fill := Color("#ffd15a") if evolved else (Color("#49c7e8") if high_level else Color("#ff6fa8"))
		var label_text_color := Color("#6a3a00") if evolved else Color.WHITE
		_draw_ranking_panel(label_rect, label_fill, Color(1, 1, 1, 0.74), 4, 1, false)
		_draw_ranking_text(level_label, label_rect.position + Vector2(0, 10), 8, label_text_color, label_rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)

func _result_equipment_level_label(item: Dictionary, data: Dictionary, evolved: bool, high_level: bool) -> String:
	if evolved:
		return "進化"
	if high_level:
		return "LvMAX"
	var label := String(item.get("levelLabel", ""))
	if label != "":
		return label
	return "Lv%d" % EquipmentSystem.entry_level(item)

func _result_clear_character_line(character_id: String) -> String:
	if character_id == "ban_chan" or character_id == "banri":
		return "やった！最後まで配信できた！"
	if character_id == "superchat_chan" or character_id == "supana":
		return "星みたいに輝けたかな！"
	if character_id == "maro_chan" or character_id == "maron":
		return "みんなのおかげで完走できたよ〜！"
	return "最後まで配信できた！"

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
	var stamp_rect := Rect2(rect.position + Vector2(rect.size.x - 128.0, 62.0), Vector2(104.0, 44.0))
	_draw_ranking_panel(stamp_rect, Color(1.0, 1.0, 1.0, 0.50), Color("#ff9fbc"), 12, 2, false)
	_draw_ranking_text("CLEAR!", stamp_rect.position + Vector2(0, 30), 23, Color("#ff5aa5"), stamp_rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)
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
	var comment := _result_clear_character_line(character_id)
	var bubble := Rect2(rect.position + Vector2(20.0, rect.size.y - 78.0), Vector2(rect.size.x - 40.0, 48.0))
	_draw_ranking_panel(bubble, Color(1.0, 1.0, 1.0, 0.82), Color("#ffd2e5"), 16, 2, false)
	_draw_ranking_text(_short_pause_text(comment, 18), bubble.position + Vector2(14.0, 30.0), 15, Color("#d94f8d"), bubble.size.x - 28.0, HORIZONTAL_ALIGNMENT_CENTER)

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
		_draw_stream_complete_celebration_back(clock, progress)
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
		_draw_stream_complete_celebration_front(clock, progress)
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

func _draw_stream_complete_celebration_back(clock: float, progress: float) -> void:
	var elapsed_intro := _game_over_intro_elapsed()
	if elapsed_intro > STREAM_COMPLETE_CELEBRATION_DURATION:
		return
	var fade_in := smoothstep(0.0, 0.16, elapsed_intro)
	var fade_out := 1.0 - smoothstep(STREAM_COMPLETE_CELEBRATION_DURATION * 0.78, STREAM_COMPLETE_CELEBRATION_DURATION, elapsed_intro)
	var alpha := clampf(progress * 2.8, 0.0, 1.0) * fade_in * fade_out
	if alpha <= 0.0:
		return
	_draw_stream_complete_celebration_burst(clock, elapsed_intro, alpha)
	_draw_stream_complete_confetti_layer(clock, elapsed_intro, alpha, false)
	_draw_stream_complete_crackers(clock, elapsed_intro, alpha)

func _draw_stream_complete_celebration_front(clock: float, progress: float) -> void:
	var elapsed_intro := _game_over_intro_elapsed()
	if elapsed_intro > STREAM_COMPLETE_CELEBRATION_DURATION:
		return
	var fade_in := smoothstep(0.08, 0.24, elapsed_intro)
	var fade_out := 1.0 - smoothstep(STREAM_COMPLETE_CELEBRATION_DURATION * 0.72, STREAM_COMPLETE_CELEBRATION_DURATION, elapsed_intro)
	var alpha := clampf(progress * 2.2, 0.0, 1.0) * fade_in * fade_out * 0.90
	if alpha <= 0.0:
		return
	_draw_stream_complete_confetti_layer(clock, elapsed_intro, alpha, true)
	_draw_stream_complete_edge_sparkles(clock, elapsed_intro, alpha)

func _draw_stream_complete_celebration_burst(clock: float, elapsed_intro: float, alpha: float) -> void:
	var t := clampf(elapsed_intro / 0.95, 0.0, 1.0)
	var pop := 1.0 - pow(1.0 - t, 3.0)
	var fade := 1.0 - smoothstep(0.55, 1.0, t)
	var burst_alpha := alpha * fade
	if burst_alpha <= 0.0:
		return
	var center := Vector2(TITLE_SCREEN_RECT.size.x * 0.50, 402.0)
	draw_circle(center, 322.0 * pop, Color(1.0, 0.52, 0.78, 0.08 * burst_alpha))
	draw_circle(center, 238.0 * pop, Color(0.52, 0.90, 1.0, 0.09 * burst_alpha))
	draw_circle(center, 160.0 * pop, Color(1.0, 0.92, 0.36, 0.09 * burst_alpha))
	draw_arc(center, 212.0 * pop, -PI * 0.10 + clock * 0.9, PI * 1.45 + clock * 0.9, 72, Color(1.0, 0.48, 0.75, 0.42 * burst_alpha), 8.0, true)
	draw_arc(center, 274.0 * pop, PI * 0.12 - clock * 0.7, PI * 1.70 - clock * 0.7, 72, Color(0.54, 0.90, 1.0, 0.34 * burst_alpha), 6.0, true)
	for i in range(18):
		var angle := -PI * 0.92 + float(i) * PI * 1.84 / 17.0
		var ray_start := center + Vector2(cos(angle), sin(angle)) * (64.0 + pop * 20.0)
		var ray_end := center + Vector2(cos(angle), sin(angle)) * (210.0 + pop * 190.0 + float(i % 3) * 18.0)
		var ray_color := Color(1.0, 0.70, 0.90, 0.18 * burst_alpha) if i % 2 == 0 else Color(0.64, 0.92, 1.0, 0.16 * burst_alpha)
		draw_line(ray_start, ray_end, ray_color, 6.0 if i % 3 == 0 else 4.0, true)
	for i in range(8):
		var angle := clock * 0.25 + float(i) * TAU / 8.0
		var pos := center + Vector2(cos(angle), sin(angle)) * (148.0 + pop * 182.0 + sin(clock + float(i)) * 12.0)
		var color := Color(1.0, 0.86, 0.28, 0.46 * burst_alpha) if i % 2 == 0 else Color(1.0, 0.55, 0.80, 0.42 * burst_alpha)
		_draw_stream_frame_icon_star(pos, 15.0 + float(i % 3) * 4.0, color)

func _draw_stream_complete_confetti_layer(clock: float, elapsed_intro: float, alpha: float, foreground: bool) -> void:
	var count := 38 if foreground else 128
	var colors := [
		Color(1.0, 1.0, 1.0, 1.0),
		Color("#ff8fbd"),
		Color("#8de7ff"),
		Color("#c7a6ff"),
		Color("#ffe27a"),
		Color("#ff6fae"),
		Color("#a6f3ff")
	]
	var screen_size := TITLE_SCREEN_RECT.size
	var fall_span := screen_size.y + 220.0
	for i in range(count):
		var seed := float(i)
		var lane_width := screen_size.x + 160.0
		var x_seed := fmod(seed * (113.0 if foreground else 97.0), lane_width) - 80.0
		var speed := (318.0 if foreground else 258.0) + float(i % 7) * (24.0 if foreground else 20.0)
		var y := -132.0 + fmod(seed * (43.0 if foreground else 61.0) + elapsed_intro * speed, fall_span)
		var sway := sin(elapsed_intro * (2.0 + float(i % 5) * 0.22) + seed * 0.73) * (28.0 if foreground else 42.0)
		var pos := Vector2(x_seed + sway, y)
		var visibility := _stream_complete_confetti_front_visibility(pos) if foreground else 1.0
		if visibility <= 0.0:
			continue
		var base_color: Color = colors[i % colors.size()] as Color
		var piece_alpha := alpha * (0.70 if foreground else 0.96) * (0.76 + float(i % 4) * 0.09) * visibility
		if piece_alpha <= 0.025:
			continue
		var color := Color(base_color.r, base_color.g, base_color.b, piece_alpha)
		var size := Vector2(12.0 + float(i % 4) * 2.6, 6.0 + float((i + 2) % 3) * 2.2)
		if i % 5 == 0:
			size = Vector2(22.0 + float(i % 3) * 4.0, 5.0)
		var angle := clock * (1.8 + float(i % 5) * 0.14) + seed * 0.57
		var shape := 0
		if i % 13 == 0:
			shape = 3
		elif i % 11 == 0:
			shape = 2
		elif i % 5 == 0:
			shape = 4
		elif i % 3 == 0:
			shape = 1
		_draw_stream_complete_confetti_piece(pos, size, angle, color, shape)

func _stream_complete_confetti_front_visibility(pos: Vector2) -> float:
	var cutin_rect := _stream_complete_cutin_rect()
	var face_rect := Rect2(cutin_rect.position + Vector2(cutin_rect.size.x * 0.18, cutin_rect.size.y * 0.08), Vector2(cutin_rect.size.x * 0.64, cutin_rect.size.y * 0.38)).grow(48.0)
	if face_rect.has_point(pos):
		return 0.0
	var panel_block := Rect2(Vector2(236.0, 178.0), Vector2(780.0, 468.0))
	if panel_block.has_point(pos):
		return 0.28
	var center_block := Rect2(Vector2(470.0, 150.0), Vector2(720.0, 530.0))
	if center_block.has_point(pos):
		return 0.48
	return 1.0

func _draw_stream_complete_confetti_piece(pos: Vector2, size: Vector2, angle: float, color: Color, shape: int) -> void:
	if color.a <= 0.0:
		return
	if shape == 2:
		_draw_stream_frame_icon_star(pos, maxf(size.x, size.y) * 0.62, color)
		return
	if shape == 3:
		_draw_stream_frame_icon_heart(pos, maxf(size.x, size.y) * 0.52, color)
		return
	if shape == 4:
		var dir := Vector2(cos(angle), sin(angle))
		var side := Vector2(-dir.y, dir.x)
		var ribbon := PackedVector2Array([
			pos - dir * size.x * 0.55,
			pos - dir * size.x * 0.16 + side * size.y * 0.90,
			pos + dir * size.x * 0.22 - side * size.y * 0.58,
			pos + dir * size.x * 0.56
		])
		draw_polyline(ribbon, color, maxf(2.0, size.y * 0.62), true)
		return
	_draw_stream_complete_rotated_rect(pos, size, angle, color)

func _draw_stream_complete_rotated_rect(center: Vector2, size: Vector2, angle: float, color: Color) -> void:
	var axis := Vector2(cos(angle), sin(angle))
	var normal := Vector2(-axis.y, axis.x)
	var half_x := size.x * 0.5
	var half_y := size.y * 0.5
	var points := PackedVector2Array([
		center - axis * half_x - normal * half_y,
		center + axis * half_x - normal * half_y,
		center + axis * half_x + normal * half_y,
		center - axis * half_x + normal * half_y
	])
	draw_colored_polygon(points, color)
	draw_line(center - axis * half_x + normal * half_y * 0.15, center + axis * half_x + normal * half_y * 0.15, Color(1.0, 1.0, 1.0, color.a * 0.35), 1.2, true)

func _draw_stream_complete_crackers(clock: float, elapsed_intro: float, base_alpha: float) -> void:
	if elapsed_intro > STREAM_COMPLETE_CRACKER_DURATION:
		return
	var t := clampf(elapsed_intro / maxf(0.01, STREAM_COMPLETE_CRACKER_DURATION), 0.0, 1.0)
	var pop := 1.0 - pow(1.0 - t, 3.0)
	var fade := 1.0 - smoothstep(0.78, 1.0, t)
	var alpha := base_alpha * fade
	if alpha <= 0.0:
		return
	_draw_stream_complete_cracker_side(Vector2(118.0, 716.0), 1.0, clock, t, pop, alpha * 1.18)
	_draw_stream_complete_cracker_side(Vector2(TITLE_SCREEN_RECT.size.x - 118.0, 716.0), -1.0, clock, t, pop, alpha * 1.18)

func _draw_stream_complete_cracker_side(origin: Vector2, side_sign: float, clock: float, t: float, pop: float, alpha: float) -> void:
	var dir := Vector2(0.74 * side_sign, -0.67).normalized()
	var perp := Vector2(-dir.y, dir.x)
	var body_alpha := clampf(alpha * (1.0 - smoothstep(0.70, 1.0, t)), 0.0, 1.0)
	var body_color := Color(1.0, 0.78, 0.93, 0.88 * body_alpha)
	var body_shadow := Color(0.38, 0.12, 0.30, 0.16 * body_alpha)
	var mouth := origin + dir * 32.0
	var back := origin - dir * 28.0
	draw_colored_polygon(PackedVector2Array([
		back - perp * 12.0 + Vector2(3.0 * side_sign, 5.0),
		back + perp * 12.0 + Vector2(3.0 * side_sign, 5.0),
		mouth + perp * 22.0 + Vector2(3.0 * side_sign, 5.0),
		mouth - perp * 22.0 + Vector2(3.0 * side_sign, 5.0)
	]), body_shadow)
	draw_colored_polygon(PackedVector2Array([
		back - perp * 12.0,
		back + perp * 12.0,
		mouth + perp * 22.0,
		mouth - perp * 22.0
	]), body_color)
	draw_line(back - perp * 6.0, mouth + perp * 11.0, Color(0.54, 0.86, 1.0, 0.90 * body_alpha), 5.0, true)
	draw_line(back + perp * 6.0, mouth - perp * 11.0, Color(1.0, 0.92, 0.36, 0.86 * body_alpha), 5.0, true)
	draw_circle(mouth, 42.0 * (1.0 - smoothstep(0.16, 0.58, t)), Color(1.0, 0.96, 0.62, 0.24 * alpha))
	draw_circle(mouth, 24.0 * (1.0 - smoothstep(0.20, 0.64, t)), Color(0.64, 0.92, 1.0, 0.18 * alpha))
	var colors := [
		Color("#ffffff"),
		Color("#ff8fbd"),
		Color("#8de7ff"),
		Color("#c7a6ff"),
		Color("#ffe27a")
	]
	for i in range(48):
		var seed := float(i)
		var spread := (fmod(seed * 0.618, 1.0) - 0.5) * 1.28
		var particle_dir := dir.rotated(spread)
		var distance := lerpf(48.0, 430.0 + float(i % 6) * 24.0, pop) * (0.76 + float(i % 5) * 0.075)
		var gravity := Vector2(0.0, 62.0 * t * t)
		var drift := perp * sin(clock * 3.0 + seed * 1.7) * (10.0 + float(i % 3) * 4.0)
		var pos := origin + particle_dir * distance + gravity + drift
		var base_color: Color = colors[i % colors.size()] as Color
		var piece_alpha := alpha * (1.0 - smoothstep(0.76, 1.0, t)) * (0.76 + float(i % 5) * 0.08)
		if piece_alpha <= 0.025:
			continue
		var color := Color(base_color.r, base_color.g, base_color.b, piece_alpha)
		if i % 5 == 0:
			var tail := pos - particle_dir * (54.0 + float(i % 3) * 14.0)
			var mid := (tail + pos) * 0.5 + perp * sin(clock * 4.0 + seed) * 18.0
			draw_polyline(PackedVector2Array([tail, mid, pos]), color, 5.0, true)
		else:
			var size := Vector2(14.0 + float(i % 3) * 4.0, 6.0 + float(i % 2) * 2.4)
			var shape := 2 if i % 11 == 0 else (3 if i % 13 == 0 else (4 if i % 5 == 0 else 0))
			_draw_stream_complete_confetti_piece(pos, size, clock * 2.4 + seed * 0.42, color, shape)

func _draw_stream_complete_edge_sparkles(clock: float, elapsed_intro: float, alpha: float) -> void:
	var fade := 1.0 - smoothstep(1.0, STREAM_COMPLETE_CELEBRATION_DURATION, elapsed_intro)
	var colors := [
		Color(1.0, 0.56, 0.78, 0.52 * alpha * fade),
		Color(0.58, 0.90, 1.0, 0.44 * alpha * fade),
		Color(1.0, 0.86, 0.26, 0.42 * alpha * fade),
		Color(0.78, 0.60, 1.0, 0.44 * alpha * fade)
	]
	for i in range(18):
		var side := -1.0 if i % 2 == 0 else 1.0
		var x := (76.0 + float(i / 2) * 44.0) if side < 0.0 else (TITLE_SCREEN_RECT.size.x - 76.0 - float(i / 2) * 44.0)
		var y := 136.0 + float(i % 6) * 78.0 + sin(clock * 2.4 + float(i)) * 11.0
		var color: Color = colors[i % colors.size()] as Color
		_draw_stream_start_sparkle(Vector2(x, y), 7.0 + float(i % 3) * 3.0, color)

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
			var icon_desc_y: float = rect.position.y + 220.0
			for line in desc_lines.slice(0, 2):
				_draw_centered_card_text(String(line), center_x, icon_desc_y, rect.size.x - 42.0, 18, sub_color)
				icon_desc_y += 21.0
		else:
			var desc_y: float = rect.position.y + 158.0
			for line in desc_lines.slice(0, 3):
				_draw_centered_card_text(String(line), center_x, desc_y, rect.size.x - 42.0, 20, sub_color)
				desc_y += 25.0
		var metric_line_y: float = rect.position.y + 257.0
		draw_line(Vector2(rect.position.x + 42.0, metric_line_y), Vector2(rect.position.x + rect.size.x - 42.0, metric_line_y), Color(1, 1, 1, 0.25), 2.0)
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
	elif comment_id == "genre_change":
		path = "res://assets/generated/instruction_comment_icons_v1/genre_change_icon.png"
	elif comment_id == "force_bullet_hell":
		path = "res://assets/generated/instruction_comment_icons_v1/force_bullet_hell_icon.png"
	elif comment_id == "force_race":
		path = "res://assets/generated/instruction_comment_icons_v1/force_race_icon.png"
	elif comment_id == "force_horror":
		path = "res://assets/generated/instruction_comment_icons_v1/force_horror_icon.png"
	elif comment_id == "kamiyoyaku":
		path = "res://assets/generated/instruction_comment_icons_v1/kamiyoyaku_icon.png"
	elif comment_id == "camera_zoom":
		path = "res://assets/generated/instruction_comment_icons_v1/camera_zoom_icon.png"
	elif comment_id == "summon_boss":
		path = "res://assets/generated/instruction_comment_icons_v1/summon_boss_icon.png"
	elif comment_id == "song_tempo_up":
		path = "res://assets/generated/instruction_comment_icons_v1/song_tempo_up_icon.png"
	elif comment_id == "song_force_chorus":
		path = "res://assets/generated/instruction_comment_icons_v1/song_force_chorus_icon.png"
	elif comment_id == "song_mic_howling":
		path = "res://assets/generated/instruction_comment_icons_v1/song_mic_howling_icon.png"
	elif comment_id == "song_lighting_mistake":
		path = "res://assets/generated/instruction_comment_icons_v1/song_lighting_mistake_icon.png"
	elif comment_id == "song_lyrics_lost":
		path = "res://assets/generated/instruction_comment_icons_v1/song_lyrics_lost_icon.png"
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
	elif comment_id == "song_tempo_up":
		icon_size = Vector2(150.0, 150.0)
		y_offset = 82.0
	elif comment_id in ["song_force_chorus", "song_mic_howling", "song_lighting_mistake", "song_lyrics_lost"]:
		icon_size = Vector2(156.0, 156.0)
		y_offset = 78.0
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
	for raw_part in text.split("\n", false):
		var part: String = String(raw_part)
		var current: String = ""
		for i in range(part.length()):
			current += part.substr(i, 1)
			if current.length() >= max_chars:
				lines.append(current)
				current = ""
		if current != "":
			lines.append(current)
	return lines

func _draw_comment_storm() -> void:
	_reset_world_transform()
	var samples: Array[String] = _comment_storm_samples_from_chat_lines()
	var slot_samples: Array[String] = _comment_storm_slot_samples(samples)
	for item in DrawDataSystemScript.comment_storm_draw_data(FIELD_VIEW, elapsed, comment_barrage_setting, kuso_chat_timer > 0.0, slot_samples):
		var data: Dictionary = item as Dictionary
		var shadow: Dictionary = data.duplicate()
		var color: Color = data["color"] as Color
		shadow["pos"] = (data["pos"] as Vector2) + Vector2(2.0, 2.0)
		shadow["color"] = Color(0.04, 0.02, 0.08, minf(0.70, color.a * 0.78))
		_draw_text_item(shadow)
		_draw_text_item(data)
	_reset_world_transform()

func _comment_storm_samples_from_chat_lines() -> Array[String]:
	var max_comment_storm_sample_length := 22
	var samples: Array[String] = []
	var source_lines: Array[String] = chat_lines
	var start_index: int = maxi(0, source_lines.size() - 18)
	for i in range(start_index, source_lines.size()):
		var line := ChatSystemScript.sanitize_line(source_lines[i])
		if line == "" or samples.has(line):
			continue
		if line.length() > max_comment_storm_sample_length:
			line = line.substr(0, max_comment_storm_sample_length) + "..."
		samples.append(line)
	var fallback: Array[String] = DisplayTextSystemScript.comment_storm_samples()
	for line in fallback:
		if samples.size() >= 8:
			break
		if not samples.has(line):
			samples.append(line)
	return samples

func _comment_storm_slot_samples(candidates: Array[String]) -> Array[String]:
	var style: Dictionary = DrawDataSystemScript.comment_storm_style(comment_barrage_setting, kuso_chat_timer > 0.0)
	var amount := int(style["amount"])
	if comment_storm_slot_texts.size() > amount:
		comment_storm_slot_texts.resize(amount)
		comment_storm_slot_cycles.resize(amount)
	while comment_storm_slot_texts.size() < amount:
		var index := comment_storm_slot_texts.size()
		comment_storm_slot_texts.append(_next_comment_storm_sample(candidates))
		comment_storm_slot_cycles.append(_comment_storm_cycle_for_slot(index))
	for i in range(amount):
		var cycle := _comment_storm_cycle_for_slot(i)
		if cycle != comment_storm_slot_cycles[i]:
			comment_storm_slot_cycles[i] = cycle
			comment_storm_slot_texts[i] = _next_comment_storm_sample(candidates)
	return comment_storm_slot_texts

func _comment_storm_cycle_for_slot(index: int) -> int:
	var travel_width := FIELD_VIEW.size.x + 520.0
	var speed := 118.0 + float(index % 5) * 22.0
	return int(floor((elapsed * speed + float(index * 181)) / travel_width))

func _next_comment_storm_sample(candidates: Array[String]) -> String:
	if candidates.is_empty():
		return "www"
	var text := candidates[comment_storm_sample_cursor % candidates.size()]
	comment_storm_sample_cursor += 1
	return text

func _reset_comment_storm_slots() -> void:
	if comment_storm_slot_texts.is_empty() and comment_storm_slot_cycles.is_empty() and comment_storm_sample_cursor == 0:
		return
	comment_storm_slot_texts.clear()
	comment_storm_slot_cycles.clear()
	comment_storm_sample_cursor = 0

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

func _draw_genre_change_banner() -> void:
	if genre_change_banner_timer <= 0.0 or genre_change_banner_event == "":
		return
	var path := _genre_change_banner_path(genre_change_banner_event)
	if path == "":
		return
	var texture: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, path)
	if texture == null:
		return
	var age := GENRE_CHANGE_BANNER_DURATION - genre_change_banner_timer
	var appear := smoothstep(0.0, 0.18, age)
	var fade := 1.0 - smoothstep(GENRE_CHANGE_BANNER_DURATION - 0.28, GENRE_CHANGE_BANNER_DURATION, age)
	var alpha := clampf(appear * fade, 0.0, 1.0)
	if alpha <= 0.0:
		return
	var settle := smoothstep(0.08, 0.34, age)
	var pop_scale := lerpf(0.90, 1.03, appear)
	var scale := lerpf(pop_scale, 1.0, settle)
	var banner_area := Rect2(Vector2(FIELD_VIEW.get_center().x - 340.0, FIELD_VIEW.position.y + 38.0), Vector2(680.0, 150.0))
	var base_rect := _fit_texture_rect(banner_area, texture.get_size())
	var rect := Rect2(base_rect.get_center() - base_rect.size * scale * 0.5, base_rect.size * scale)
	var shadow_rect := Rect2(rect.position + Vector2(0.0, 10.0), rect.size).grow(5.0)
	draw_texture_rect(texture, shadow_rect, false, Color(0.12, 0.02, 0.10, 0.20 * alpha))
	draw_texture_rect(texture, rect, false, Color(1.0, 1.0, 1.0, alpha))
	_draw_genre_change_rule_panel(genre_change_banner_event, rect, alpha, appear)

func _draw_genre_change_rule_panel(event_id: String, banner_rect: Rect2, alpha: float, appear: float) -> void:
	var rule_text := _genre_change_rule_text(event_id)
	if rule_text == "":
		return
	var accent := _genre_event_timer_accent_color(event_id)
	var panel_scale := lerpf(0.96, 1.0, appear)
	var base_rect := Rect2(
		Vector2(FIELD_VIEW.get_center().x - 250.0, banner_rect.end.y - 2.0),
		Vector2(500.0, 48.0)
	)
	var rect := Rect2(base_rect.get_center() - base_rect.size * panel_scale * 0.5, base_rect.size * panel_scale)
	var rule_color := Color("#5b3a5d")
	rule_color.a = 0.96 * alpha
	DrawPrimitiveSystemScript.draw_shadow(self, rect.get_center() + Vector2(0.0, 7.0), rect.size + Vector2(20.0, 10.0), 0.14 * alpha)
	draw_rect(rect.grow(3.0), Color(1.0, 0.72, 0.90, 0.18 * alpha), true)
	draw_rect(rect, Color(1.0, 1.0, 1.0, 0.88 * alpha), true)
	draw_rect(rect, Color(accent.r, accent.g, accent.b, 0.76 * alpha), false, 3)
	draw_rect(rect.grow(-6.0), Color(1.0, 0.78, 0.94, 0.20 * alpha), false, 1)
	_draw_text_item(
		{
			"pos": rect.position + Vector2(0.0, 31.0),
			"text": rule_text,
			"width": int(rect.size.x),
			"size": 18,
			"fontWeight": "black",
			"color": rule_color
		},
		"",
		HORIZONTAL_ALIGNMENT_CENTER
	)

func _genre_change_rule_text(event_id: String) -> String:
	if event_id == "race":
		return "走り続けて、コインを集めろ！"
	if event_id == "bullet_hell":
		return "ショットで敵を倒せ！"
	if event_id == "horror":
		return "ギフト大量発生！偽物に気を付けろ！"
	return ""

func _draw_genre_event_timer() -> void:
	if active_genre_event == "" or genre_event_timer <= 0.0:
		return
	if state != "playing" and state != "comment_choice" and state != "gift_choice":
		return
	var remaining := ceili(maxf(0.0, genre_event_timer))
	var duration := maxf(0.01, genre_event_duration)
	var progress := clampf(genre_event_timer / duration, 0.0, 1.0)
	var rect := Rect2(Vector2(FIELD_VIEW.position.x + 10.0, FIELD_VIEW.position.y + 14.0), Vector2(246.0, 56.0))
	var accent := _genre_event_timer_accent_color(active_genre_event)
	var urgent := genre_event_timer <= 3.0
	var pulse := (0.5 + 0.5 * sin(elapsed * 9.0)) if urgent else 0.0
	var alpha := 0.92 + pulse * 0.08
	DrawPrimitiveSystemScript.draw_shadow(self, rect.get_center() + Vector2(0.0, 7.0), rect.size + Vector2(20.0, 10.0), 0.16 * alpha)
	draw_rect(rect.grow(3.0), Color(1.0, 0.78, 0.90, 0.16 * alpha), true)
	draw_rect(rect, Color(1.0, 1.0, 1.0, 0.88 * alpha), true)
	draw_rect(rect, Color(accent.r, accent.g, accent.b, (0.76 + pulse * 0.18) * alpha), false, 3)
	draw_rect(rect.grow(-5.0), Color(1.0, 0.75, 0.92, 0.18 * alpha), false, 1)
	_draw_text_item(
		{
			"pos": rect.position + Vector2(14.0, 24.0),
			"text": "ジャンル終了まで",
			"width": 142,
			"size": 15,
			"fontWeight": "bold",
			"color": Color("#8b6a87")
		}
	)
	_draw_text_item(
		{
			"pos": rect.position + Vector2(156.0, 38.0),
			"text": "%02ds" % remaining,
			"width": 72,
			"size": 30,
			"fontWeight": "black",
			"color": Color("#ffffff")
		},
		"",
		HORIZONTAL_ALIGNMENT_CENTER,
		Color(0.30, 0.16, 0.36, 0.34 * alpha)
	)
	_draw_text_item(
		{
			"pos": rect.position + Vector2(154.0, 36.0),
			"text": "%02ds" % remaining,
			"width": 76,
			"size": 30,
			"fontWeight": "black",
			"color": Color(accent.r, accent.g, accent.b, 1.0)
		},
		"",
		HORIZONTAL_ALIGNMENT_CENTER
	)
	var bar_back := Rect2(rect.position + Vector2(14.0, 43.0), Vector2(rect.size.x - 28.0, 7.0))
	var bar_fill := Rect2(bar_back.position, Vector2(bar_back.size.x * progress, bar_back.size.y))
	draw_rect(bar_back, Color(0.92, 0.88, 0.97, 0.80 * alpha), true)
	draw_rect(bar_fill, Color(accent.r, accent.g, accent.b, 0.82 * alpha), true)
	draw_rect(bar_back, Color(1.0, 1.0, 1.0, 0.64 * alpha), false, 1)

func _draw_genre_result_card() -> void:
	if genre_result_card_timer <= 0.0 or genre_result_card_data.is_empty():
		return
	if state != "playing":
		return
	var event_id := String(genre_result_card_data.get("eventId", ""))
	var title := String(genre_result_card_data.get("title", "ジャンルイベント 終了！"))
	var lines_value: Variant = genre_result_card_data.get("lines", [])
	var lines: Array = []
	if lines_value is Array:
		lines = lines_value as Array
	var duration := maxf(0.1, genre_result_card_duration)
	var age := duration - genre_result_card_timer
	var appear := smoothstep(0.0, 0.16, age)
	var fade := 1.0 - smoothstep(duration - 0.30, duration, age)
	var alpha := clampf(appear * fade, 0.0, 1.0)
	if alpha <= 0.0:
		return
	var accent := _genre_event_timer_accent_color(event_id)
	var line_count := mini(lines.size(), 3)
	var card_size := Vector2(330.0, 58.0 + float(line_count) * 20.0)
	var card_x := clampf(FIELD_VIEW.position.x + FIELD_VIEW.size.x * 0.64, FIELD_VIEW.position.x + 340.0, FIELD_VIEW.end.x - card_size.x - 28.0)
	var card_y := FIELD_VIEW.position.y + 18.0 + lerpf(-8.0, 0.0, appear)
	var rect := Rect2(Vector2(card_x, card_y), card_size)
	var fill := Color(1.0, 1.0, 1.0, 0.90 * alpha)
	var accent_soft := Color(accent.r, accent.g, accent.b, 0.18 * alpha)
	var accent_main := Color(accent.r, accent.g, accent.b, 0.82 * alpha)
	var text_color := Color("#6f5374")
	text_color.a = alpha
	var sub_text_color := Color("#8d748d")
	sub_text_color.a = 0.92 * alpha
	DrawPrimitiveSystemScript.draw_shadow(self, rect.get_center() + Vector2(0.0, 7.0), rect.size + Vector2(20.0, 12.0), 0.13 * alpha)
	draw_rect(rect.grow(3.0), accent_soft, true)
	draw_rect(rect, fill, true)
	draw_rect(Rect2(rect.position, Vector2(8.0, rect.size.y)), accent_main, true)
	draw_rect(Rect2(rect.position, Vector2(rect.size.x, 5.0)), Color(accent.r, accent.g, accent.b, 0.42 * alpha), true)
	draw_rect(rect, Color(accent.r, accent.g, accent.b, 0.64 * alpha), false, 2)
	draw_rect(rect.grow(-5.0), Color(1.0, 0.78, 0.92, 0.18 * alpha), false, 1)
	_draw_text_item(
		{
			"pos": rect.position + Vector2(20.0, 28.0),
			"text": title,
			"width": int(rect.size.x - 40.0),
			"size": 17,
			"fontWeight": "black",
			"color": text_color
		}
	)
	for i in range(line_count):
		var line_text := String(lines[i])
		var line_pos := rect.position + Vector2(30.0, 52.0 + float(i) * 20.0)
		draw_circle(line_pos + Vector2(-12.0, -5.0), 3.6, Color(accent.r, accent.g, accent.b, 0.72 * alpha))
		_draw_text_item(
			{
				"pos": line_pos,
				"text": line_text,
				"width": int(rect.size.x - 54.0),
				"size": 15,
				"fontWeight": "bold",
				"color": sub_text_color
			}
		)

func _genre_event_timer_accent_color(event_id: String) -> Color:
	if event_id == "race":
		return Color("#ffb84d")
	if event_id == "bullet_hell":
		return Color("#63dfff")
	if event_id == "horror":
		return Color("#ba93ff")
	return Color("#ff79ad")

func _is_song_frame() -> bool:
	return current_stream_frame_id == "singing" or current_stream_frame_id == "song"

func _is_drawing_frame() -> bool:
	return current_stream_frame_id == "drawing"

func _song_live_heat_level_for(value: float) -> int:
	if value >= 90.0:
		return 5
	if value >= 75.0:
		return 4
	if value >= 60.0:
		return 3
	if value >= 40.0:
		return 2
	if value >= 20.0:
		return 1
	return 0

func _song_live_heat_label(level: int) -> String:
	match clampi(level, 0, 5):
		0:
			return "開演直後"
		1:
			return "テンポアップ"
		2:
			return "ペンライト支援"
		3:
			return "ハーモニーウェーブ"
		4:
			return "主役スポットライト"
		5:
			return "アンコールフィーバー"
	return "LIVE"

func _song_live_heat_move_speed_multiplier() -> float:
	if not _is_song_frame():
		return 1.0
	var value := 1.0
	if song_live_heat_level >= 1:
		value *= SONG_LIVE_HEAT_LV1_MOVE_RATE
	if song_live_heat_level >= 5:
		value *= SONG_LIVE_HEAT_LV5_MOVE_RATE
	value *= _song_instruction_multiplier("song_tempo_up", 1.08)
	return value

func _song_dash_cooldown_recovery_multiplier() -> float:
	return 1.0

func _song_enemy_move_speed_multiplier() -> float:
	if not _is_song_frame():
		return 1.0
	return _song_instruction_multiplier("song_tempo_up", 1.22)

func _song_live_heat_pickup_range_multiplier() -> float:
	if not _is_song_frame():
		return 1.0
	var value := 1.0
	if song_live_heat_level >= 1:
		value *= SONG_LIVE_HEAT_LV1_PICKUP_RATE
	if song_live_heat_level >= 5:
		value *= SONG_LIVE_HEAT_LV5_PICKUP_RATE
	return value

func _song_live_heat_attack_cooldown_multiplier() -> float:
	if not _is_song_frame():
		return 1.0
	var value := 1.0
	if song_live_heat_level >= 4:
		value *= SONG_LIVE_HEAT_LV4_COOLDOWN_RATE
	if song_live_heat_level >= 5:
		value *= SONG_LIVE_HEAT_LV5_COOLDOWN_RATE
	return value

func _normal_weapons_disabled_by_song_bad_light() -> bool:
	return _is_song_frame() and SONG_BAD_LIGHT_DISABLE_NORMAL_WEAPONS and song_bad_light_inside

func _live_heat_support_disabled_by_song_bad_light() -> bool:
	return _is_song_frame() and SONG_BAD_LIGHT_DISABLE_LIVE_HEAT_SUPPORT and song_bad_light_inside

func _song_live_heat_damage_taken_multiplier() -> float:
	if not _is_song_frame():
		return 1.0
	return SONG_LIVE_HEAT_LV4_DAMAGE_RATE if song_live_heat_level >= 4 else 1.0

func _song_comment_speed_multiplier() -> float:
	if not _is_song_frame():
		return 1.0
	match clampi(song_live_heat_level, 0, 5):
		0:
			return 1.0
		1:
			return 1.05
		2:
			return 1.15
		3:
			return 1.30
		4:
			return 1.45
		5:
			return 1.60
	return 1.0

func _song_note_spawn_multiplier() -> float:
	match clampi(song_live_heat_level, 0, 5):
		0:
			return 1.0
		1:
			return 1.05
		2:
			return 1.15
		3:
			return 1.25
		4:
			return 1.40
		5:
			return 1.60
	return 1.0

func _song_enemy_spawn_multiplier() -> float:
	var multiplier_value := 1.0
	match clampi(song_live_heat_level, 0, 5):
		2:
			multiplier_value = 1.05
		3:
			multiplier_value = 1.10
		4:
			multiplier_value = 1.15
		5:
			multiplier_value = 1.22
	if song_encore_timer > 0.0:
		multiplier_value *= 1.25
	multiplier_value *= _song_instruction_enemy_spawn_multiplier()
	return multiplier_value

func _song_instruction_enemy_spawn_multiplier() -> float:
	if not _is_song_frame():
		return 1.0
	var value := 1.0
	value *= _song_instruction_multiplier("song_tempo_up", 1.15)
	value *= _song_instruction_multiplier("song_force_chorus", 1.35)
	return value

func _song_comment_enemy_spawn_bias() -> float:
	return 0.0

func _song_note_lifetime_multiplier() -> float:
	if not _is_song_frame():
		return 1.0
	return _song_instruction_multiplier("song_tempo_up", 0.80)

func _song_note_live_heat_gain_multiplier() -> float:
	return 1.0

func _song_instruction_power(comment_id: String) -> float:
	if not _is_song_frame():
		return 0.0
	return clampf(ModifierSystemScript.effect_rate_for_target(self, comment_id), 0.0, 1.0)

func _song_instruction_multiplier(comment_id: String, active_value: float) -> float:
	var power := _song_instruction_power(comment_id)
	if power <= 0.0:
		return 1.0
	return lerpf(1.0, active_value, power)

func _song_max_spotlights() -> int:
	var level := clampi(song_live_heat_level, 0, 5)
	if level <= 0:
		return 1
	if level <= 2:
		return 2
	if level <= 4:
		return 3
	return 4

func _song_live_heat_gain_multiplier() -> float:
	var value := 1.0
	if song_chorus_timer > 0.0:
		value *= SONG_CHORUS_LIVE_HEAT_MULTIPLIER
	if song_encore_timer > 0.0:
		value *= SONG_ENCORE_LIVE_HEAT_MULTIPLIER
	return value

func _song_viewer_gain_multiplier() -> float:
	var value := 1.0
	if song_chorus_timer > 0.0:
		value *= SONG_CHORUS_VIEWER_GAIN_MULTIPLIER
	if song_encore_timer > 0.0:
		value *= SONG_ENCORE_VIEWER_GAIN_MULTIPLIER
	return value

func _song_voltage_gain_multiplier() -> float:
	var value := 1.0
	if song_chorus_timer > 0.0:
		value *= SONG_CHORUS_VOLTAGE_GAIN_MULTIPLIER
	if song_encore_timer > 0.0:
		value *= SONG_ENCORE_VOLTAGE_GAIN_MULTIPLIER
	return value

func _add_song_live_heat(amount: float, _source: String = "") -> void:
	if not _is_song_frame() or amount <= 0.0:
		return
	var previous_level := song_live_heat_level
	song_live_heat = clampf(song_live_heat + amount, 0.0, SONG_LIVE_HEAT_MAX)
	song_live_heat_level = _song_live_heat_level_for(song_live_heat)
	song_max_live_heat = maxf(song_max_live_heat, song_live_heat)
	song_max_live_heat_level = maxi(song_max_live_heat_level, song_live_heat_level)
	if song_live_heat_level > previous_level:
		song_live_heat_level_flash_timer = 1.0
		screen_flash_timer = 0.10
		screen_flash_duration = 0.10
		screen_flash_color = Color(1.0, 0.72, 0.96, 0.14)
		chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": ["+ LIVE HEAT Lv.%d！" % song_live_heat_level, "+ %s" % _song_live_heat_label(song_live_heat_level)]}, chat_box)
		_apply_song_live_heat_level_rewards(previous_level, song_live_heat_level)

func _apply_song_live_heat_level_rewards(previous_level: int, new_level: int) -> void:
	if not _is_song_frame():
		return
	var arena := _current_arena()
	for level in range(previous_level + 1, new_level + 1):
		if level <= 0 or bool(song_live_heat_reward_claimed.get(level, false)):
			continue
		song_live_heat_reward_claimed[level] = true
		_grant_song_live_heat_level_reward(level, arena)

func _grant_song_live_heat_level_reward(level: int, arena: Rect2) -> void:
	var chats: Array[String] = ["+ LIVE HEAT Lv.%d到達報酬！" % level]
	var level_label := _song_live_heat_label(level)
	var toast := "LIVE HEAT Lv.%d %s！" % [level, level_label]
	match level:
		1:
			_spawn_song_notes(3, arena, false, SONG_AMBIENT_NOTE_LIFETIME)
			score += 300
			chats.append("+ テンポ上がってきた！")
			chats.append("> 動きよくなった")
			chats.append("+ 音符3個出現")
			chats.append("+ 視聴者 +300")
			toast += " 移動/回収UP"
		2:
			_add_song_gift_hype_reward(5)
			song_penlight_bit_shot_timer = 0.45
			chats.append("+ ペンライト支援きた！")
			chats.append("> ペンライト飛んでる")
			chats.append("ｗ 客席が攻撃してる")
			chats.append("+ ギフト期待度 +5")
			toast += " ペンライトビット"
		3:
			_spawn_song_live_gift_drop(arena, false)
			_add_song_gift_hype_reward(10)
			song_harmony_wave_timer = 0.55
			chats.append("+ ハーモニーウェーブ解放！")
			chats.append("> 音波出てる！")
			chats.append("ｗ ライブ会場が武器になった")
			chats.append("+ ライブギフト箱が出現")
			chats.append("+ ギフト期待度 +10")
			toast += " 音波リング解放"
		4:
			_spawn_song_notes(8, arena, false, SONG_AMBIENT_NOTE_LIFETIME)
			_spawn_song_spotlights(1, arena)
			_add_song_gift_hype_reward(15)
			chats.append("+ 主役スポットライト！")
			chats.append("> 今めっちゃ映えてる")
			chats.append("+ 音符回収で少し回復")
			chats.append("+ 音符8個出現")
			chats.append("+ スポットライト出現")
			chats.append("+ ギフト期待度 +15")
			toast += " 防御/攻撃補助UP"
		5:
			_spawn_song_live_gift_drop(arena, true)
			_add_song_gift_hype_reward(20)
			song_encore_unlocked = true
			song_audience_call_wave_timer = 0.65
			chats.append("+ アンコールフィーバー！")
			chats.append("> 会場あったまりすぎ")
			chats.append("ｗ 終われない空気")
			chats.append("+ スペシャルライブギフト箱が出現")
			chats.append("+ ギフト期待度 +20")
			chats.append("+ アンコールチャンス解放！")
			toast = "LIVE HEAT MAX! アンコールフィーバー！"
		_:
			return
	_queue_song_live_heat_level_notice(level)
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": chats, "toasts": [toast]}, chat_box, 1.5)

func _add_song_gift_hype_reward(amount: int) -> void:
	gift_hype = clampi(gift_hype + amount, 0, 100)
	max_gift_hype = maxi(max_gift_hype, gift_hype)

func _song_live_heat_is_max() -> bool:
	return song_live_heat >= SONG_LIVE_HEAT_MAX - 0.001 or (song_live_heat_level >= 5 and song_live_heat >= SONG_LIVE_HEAT_MAX - 0.001)

func _try_trigger_song_max_octave_audience_call_wave() -> bool:
	if not _song_live_heat_is_max():
		return false
	if song_max_octave_audience_call_wave_cooldown > 0.0:
		return false
	var arena := _current_arena()
	_spawn_song_audience_call_wave(arena)
	song_max_octave_audience_call_wave_cooldown = SONG_MAX_OCTAVE_AUDIENCE_CALL_WAVE_COOLDOWN
	song_audience_call_wave_timer = maxf(song_audience_call_wave_timer, SONG_MAX_OCTAVE_AUDIENCE_CALL_WAVE_COOLDOWN)
	return true

func _spawn_song_live_gift_drop(arena: Rect2, special: bool) -> void:
	var drop_id := "song_special_live_gift" if special else "song_live_gift"
	drop_items.append({
		"id": drop_id,
		"displayName": "スペシャルライブギフト箱" if special else "ライブギフト箱",
		"pos": _song_live_gift_position(arena),
		"life": SONG_LIVE_GIFT_LIFETIME,
		"age": 0.0,
		"special": special
	})

func _song_live_gift_position(arena: Rect2) -> Vector2:
	var walls := EnemySystemScript.movement_wall_rects(effect_walls, current_stream_frame_id)
	var rect := arena.grow(-76.0)
	for i in range(56):
		var angle := rng.randf_range(0.0, TAU)
		var distance := rng.randf_range(160.0, 320.0)
		var pos := player_pos + Vector2(cos(angle), sin(angle)) * distance
		if not rect.has_point(pos):
			continue
		if _song_live_gift_position_blocked(pos, 42.0, walls):
			continue
		return pos
	return _song_event_position(arena, 52.0)

func _song_live_gift_position_blocked(pos: Vector2, radius: float, walls: Array) -> bool:
	for wall_value in walls:
		var wall: Rect2 = wall_value as Rect2
		if wall.grow(radius).has_point(pos):
			return true
	for drop_item in drop_items:
		var drop: Dictionary = drop_item as Dictionary
		if pos.distance_squared_to(Vector2(drop.get("pos", Vector2.ZERO))) < 7396.0:
			return true
	for box_item in destructibles:
		var box: Dictionary = box_item as Dictionary
		if float(box.get("hp", 0.0)) > 0.0 and pos.distance_squared_to(Vector2(box.get("pos", Vector2.ZERO))) < 8464.0:
			return true
	return false

func _song_add_viewers(amount: float) -> void:
	var add_viewers := int(round(amount * _song_viewer_gain_multiplier()))
	if add_viewers > 0:
		score += add_viewers

func _song_add_voltage(amount: float) -> void:
	multiplier = minf(5.0, multiplier + amount * _song_voltage_gain_multiplier())
	max_multiplier = maxf(max_multiplier, multiplier)

func _reset_song_chorus_state() -> void:
	song_chorus_next_time = SONG_CHORUS_FIRST_DELAY
	song_chorus_telegraph_timer = 0.0
	song_chorus_timer = 0.0
	song_chorus_banner_timer = 0.0
	song_chorus_result_timer = 0.0
	song_chorus_result_duration = SONG_CHORUS_RESULT_CARD_DURATION
	song_chorus_result_data.clear()
	song_chorus_notes_collected = 0
	song_chorus_spotlight_time = 0.0
	song_chorus_enemy_spawn_timer = 0.0
	song_chorus_viewer_accum = 0.0
	song_chorus_current_duration = SONG_CHORUS_DURATION
	song_forced_chorus_active = false
	song_chorus_reward_multiplier = 1.0
	song_howling_emitters.clear()
	song_howling_waves.clear()
	song_bad_lights.clear()
	song_bad_light_respawn_timer = 0.0
	song_bad_light_inside = false
	song_lyrics_cards.clear()
	song_lyrics_card_locked_pos = Vector2.ZERO
	song_lyrics_card_has_locked_pos = false
	song_lyrics_lost_card_collected = false
	song_spotlight_inside_last_frame = false
	song_spotlight_benefit_se_cooldown = 0.0
	song_spotlight_benefit_flash_timer = 0.0
	song_notes.clear()
	song_ambient_note_timer = SONG_AMBIENT_NOTE_INTERVAL_MIN
	song_spotlights.clear()
	song_chorus_count = 0
	song_total_notes_collected = 0
	song_note_scale_index = 0
	song_note_total_collected = 0
	song_octave_bonus_count = 0
	song_scale_note_queue.clear()
	song_scale_note_queue_timer = 0.0
	song_octave_bonus_notice_timer = 0.0
	song_octave_bonus_notice_duration = 0.0
	song_octave_bonus_notice_hits = 0
	song_octave_bonus_notice_call_wave = false
	song_total_spotlight_time = 0.0
	song_live_heat = 0.0
	displayed_song_live_heat = song_live_heat
	song_live_heat_gauge_display_initialized = true
	song_live_heat_level = 0
	song_max_live_heat = 0.0
	song_max_live_heat_level = 0
	song_live_heat_level_flash_timer = 0.0
	song_live_heat_reward_claimed.clear()
	song_live_heat_level_notice_queue.clear()
	song_live_heat_level_notice_timer = 0.0
	song_live_heat_level_notice_duration = 0.0
	song_live_heat_level_notice_data.clear()
	song_no_damage_streak_timer = 0.0
	song_pitch_wave_cooldown = 0.0
	song_pitch_waves.clear()
	song_boss_chorus_judge_busy = false
	song_boss_chorus_judge_active = false
	song_boss_chorus_judge_required = 0
	song_boss_chorus_judge_collected = 0
	song_boss_chorus_judge_timer = 0.0
	song_boss_chorus_judge_duration = 0.0
	song_boss_chorus_judge_notice_timer = 0.0
	song_boss_chorus_judge_notice_duration = 0.0
	song_boss_chorus_judge_notice_title = ""
	song_boss_chorus_judge_notice_subtitle = ""
	song_boss_chorus_judge_notice_success = false
	song_boss_megaphone_waves.clear()
	song_encore_timer = 0.0
	song_encore_triggered = false
	song_encore_completed = false
	song_encore_unlocked = false
	song_penlight_bit_shot_timer = 0.0
	song_harmony_wave_timer = 0.0
	song_audience_call_wave_timer = 0.0
	song_max_octave_audience_call_wave_cooldown = 0.0
	song_note_trail_timer = 0.0
	song_live_heat_fx.clear()

func _update_song_chorus_overlay_timers(delta: float) -> void:
	if song_chorus_banner_timer > 0.0:
		song_chorus_banner_timer = maxf(0.0, song_chorus_banner_timer - delta)
	if song_chorus_result_timer > 0.0:
		song_chorus_result_timer = maxf(0.0, song_chorus_result_timer - delta)
		if song_chorus_result_timer <= 0.0:
			song_chorus_result_data.clear()
	if song_live_heat_level_flash_timer > 0.0:
		song_live_heat_level_flash_timer = maxf(0.0, song_live_heat_level_flash_timer - delta)
	if song_octave_bonus_notice_timer > 0.0:
		song_octave_bonus_notice_timer = maxf(0.0, song_octave_bonus_notice_timer - delta)
	if song_boss_chorus_judge_notice_timer > 0.0:
		song_boss_chorus_judge_notice_timer = maxf(0.0, song_boss_chorus_judge_notice_timer - delta)
	if song_max_octave_audience_call_wave_cooldown > 0.0:
		song_max_octave_audience_call_wave_cooldown = maxf(0.0, song_max_octave_audience_call_wave_cooldown - delta)
	_update_song_live_heat_level_notice(delta)

func _queue_song_live_heat_level_notice(level: int) -> void:
	var data := _song_live_heat_level_notice_content(level)
	if data.is_empty():
		return
	song_live_heat_level_notice_queue.append(data)

func _song_live_heat_level_notice_content(level: int) -> Dictionary:
	match clampi(level, 1, 5):
		1:
			return {
				"level": 1,
				"title": "ライブテンション Lv.1",
				"name": "テンポアップ！",
				"description": "移動速度・回収範囲UP",
				"icon": "♪",
				"accent": Color("#8eeaff")
			}
		2:
			return {
				"level": 2,
				"title": "ライブテンション Lv.2",
				"name": "ペンライト支援！",
				"description": "ペンライトビットが敵を攻撃",
				"icon": "✦",
				"accent": Color("#ff8fc8")
			}
		3:
			return {
				"level": 3,
				"title": "ライブテンション Lv.3",
				"name": "ハーモニーウェーブ解放！",
				"description": "音波リングで周囲を攻撃",
				"icon": "◎",
				"accent": Color("#c6a5ff")
			}
		4:
			return {
				"level": 4,
				"title": "ライブテンション Lv.4",
				"name": "主役スポットライト！",
				"description": "防御UP・攻撃間隔短縮",
				"icon": "★",
				"accent": Color("#ffe177")
			}
		5:
			return {
				"level": 5,
				"title": "LIVE HEAT MAX!",
				"name": "アンコールフィーバー！",
				"description": "観客コール波・特別ギフト解放",
				"icon": "♛",
				"accent": Color("#ffcf4d"),
				"subAccent": Color("#ff67b3")
			}
	return {}

func _song_live_heat_level_notice_blocked() -> bool:
	if not _is_song_frame():
		return true
	if state != "playing":
		return true
	if song_chorus_banner_timer > 0.0:
		return true
	return false

func _song_live_heat_level_notice_visible() -> bool:
	return song_live_heat_level_notice_timer > 0.0 and not song_live_heat_level_notice_data.is_empty() and not _song_live_heat_level_notice_blocked()

func _song_notice_stack_top_y() -> float:
	var top := FIELD_VIEW.position.y + SONG_NOTICE_STACK_BASE_TOP
	if song_chorus_result_timer > 0.0:
		top = maxf(top, FIELD_VIEW.position.y + SONG_NOTICE_STACK_RESULT_TOP)
	if song_chorus_banner_timer > 0.0:
		top = maxf(top, FIELD_VIEW.position.y + SONG_NOTICE_STACK_CHORUS_TOP)
	return top

func _song_notice_stack_center_y(height: float, lane: int) -> float:
	return _song_notice_stack_top_y() + float(maxi(0, lane)) * SONG_NOTICE_STACK_LANE_GAP + height * 0.5

func _update_song_live_heat_level_notice(delta: float) -> void:
	if not _is_song_frame():
		song_live_heat_level_notice_queue.clear()
		song_live_heat_level_notice_timer = 0.0
		song_live_heat_level_notice_duration = 0.0
		song_live_heat_level_notice_data.clear()
		song_octave_bonus_notice_timer = 0.0
		song_octave_bonus_notice_duration = 0.0
		song_octave_bonus_notice_hits = 0
		song_boss_chorus_judge_notice_timer = 0.0
		song_boss_chorus_judge_notice_duration = 0.0
		return
	if _song_live_heat_level_notice_blocked():
		return
	if song_live_heat_level_notice_timer > 0.0:
		song_live_heat_level_notice_timer = maxf(0.0, song_live_heat_level_notice_timer - delta)
		if song_live_heat_level_notice_timer <= 0.0:
			song_live_heat_level_notice_data.clear()
		return
	if song_live_heat_level_notice_queue.is_empty():
		return
	song_live_heat_level_notice_data = song_live_heat_level_notice_queue.pop_front() as Dictionary
	song_live_heat_level_notice_duration = SONG_LIVE_HEAT_LEVEL_NOTICE_DURATION + (0.25 if int(song_live_heat_level_notice_data.get("level", 0)) >= 5 else 0.0)
	song_live_heat_level_notice_timer = song_live_heat_level_notice_duration

func _song_next_interval() -> float:
	var heat_reduction := float(song_live_heat_level) * 1.4
	return rng.randf_range(
		maxf(24.0, SONG_CHORUS_INTERVAL_MIN - heat_reduction),
		maxf(32.0, SONG_CHORUS_INTERVAL_MAX - heat_reduction)
	)

func _update_song_no_damage_bonus(delta: float) -> void:
	if not _is_song_frame():
		song_no_damage_streak_timer = 0.0
		return
	if state != "playing" and state != "comment_choice" and state != "gift_choice":
		return
	song_no_damage_streak_timer += delta
	while song_no_damage_streak_timer >= SONG_NO_DAMAGE_STREAK_INTERVAL:
		song_no_damage_streak_timer -= SONG_NO_DAMAGE_STREAK_INTERVAL
		_add_song_live_heat(SONG_LIVE_HEAT_NO_DAMAGE_STREAK_GAIN, "no_damage_streak")

func _update_song_chorus(delta: float, arena: Rect2) -> void:
	if not _is_song_frame():
		if song_chorus_timer > 0.0 or song_chorus_telegraph_timer > 0.0 or not song_notes.is_empty() or not song_spotlights.is_empty() or not song_live_heat_fx.is_empty() or song_boss_chorus_judge_busy or not song_boss_megaphone_waves.is_empty():
			_reset_song_chorus_state()
		return
	_update_song_no_damage_bonus(delta)
	_update_song_notes(delta)
	if not song_boss_chorus_judge_active:
		_update_song_ambient_notes(delta, arena)
	_update_song_spotlights(delta)
	_update_song_live_heat_buffs(delta, arena)
	_update_song_instruction_effects(delta, arena)
	_update_song_pitch_waves(delta)
	_update_song_boss_chorus_judge(delta)
	_update_song_boss_megaphone_waves(delta)
	_update_song_encore(delta, arena)
	if song_chorus_telegraph_timer > 0.0:
		song_chorus_telegraph_timer = maxf(0.0, song_chorus_telegraph_timer - delta)
		if song_chorus_telegraph_timer <= 0.0:
			_start_song_chorus(arena)
		return
	if song_chorus_timer > 0.0:
		song_chorus_timer = maxf(0.0, song_chorus_timer - delta)
		_update_song_chorus_enemy_spawns(delta, arena)
		if song_chorus_timer <= 0.0:
			_finish_song_chorus()
		return
	if elapsed >= song_chorus_next_time and not song_boss_chorus_judge_busy:
		_start_song_chorus_telegraph()

func _apply_song_instruction_comment(comment_id: String) -> void:
	if not _is_song_frame():
		return
	var arena := _current_arena()
	match comment_id:
		"song_force_chorus":
			if song_chorus_timer <= 0.0 and song_chorus_telegraph_timer <= 0.0:
				_start_song_chorus(arena, true)
				song_chorus_next_time = maxf(song_chorus_next_time, elapsed + 10.0)
				_push_time_toast("短縮サビ発生！", 1.2)
		"song_tempo_up":
			_push_time_toast("テンポアップ！", 1.1)
		"song_mic_howling":
			_start_song_mic_howling(arena)
			_push_time_toast("ハウリング注意！", 1.2)
		"song_lighting_mistake":
			_start_song_lighting_mistake(arena)
			_push_time_toast("暴走ライト注意！", 1.2)
		"song_lyrics_lost":
			_start_song_lyrics_lost(arena)
			_push_time_toast("歌詞カードを拾って！", 1.25)
		"song_pitch_police", "song_no_breath", "song_comment_too_fast":
			_cancel_deprecated_song_instruction(comment_id)

func _apply_drawing_instruction_comment(comment_id: String) -> void:
	if not _is_drawing_frame():
		return
	var arena := _current_arena()
	match comment_id:
		"drawing_paint_rush":
			for i in range(3):
				if drawing_paint_orbs.size() < DRAWING_PAINT_ORB_MAX:
					_spawn_drawing_paint_orb(arena)
			_show_drawing_toast("一気に塗ろう！", "絵の具追加・線が少し太くなります")
			chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": ["+ 絵の具追加！", "> 一気に塗る流れきた"]}, chat_box)
		"drawing_fix_here":
			for i in range(2):
				if drawing_correction_points.size() < DRAWING_CORRECTION_MAX + 2:
					_spawn_drawing_correction_point(arena)
			_show_drawing_toast("そこ修正して！", "修正ポイント追加・修正速度UP")
			chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": ["+ 修正ポイント追加！", "> 赤字対応タイム"]}, chat_box)
		"drawing_clean_screen":
			_spawn_drawing_eraser(arena)
			_collect_drawing_eraser(player_pos)
			_show_drawing_toast("画面きれいにして！", "消しゴム出現・周囲を掃除")
			chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": ["+ 画面掃除！", "> 見やすくなってきた"]}, chat_box)

func _drawing_instruction_power(comment_id: String) -> float:
	if not _is_drawing_frame():
		return 0.0
	return clampf(ModifierSystemScript.effect_rate_for_target(self, comment_id), 0.0, 1.0)

func _drawing_instruction_multiplier(comment_id: String, active_value: float) -> float:
	var power := _drawing_instruction_power(comment_id)
	if power <= 0.0:
		return 1.0
	return lerpf(1.0, active_value, power)

func _drawing_focus_work_multiplier(active_value: float) -> float:
	if not drawing_focus_inside_last_frame:
		return 1.0
	return active_value

func _drawing_trail_width() -> float:
	var value := DRAWING_TRAIL_WIDTH
	value *= _drawing_instruction_multiplier("drawing_paint_rush", 1.22)
	value *= _drawing_focus_work_multiplier(DRAWING_FOCUS_TRAIL_WIDTH_RATE)
	return value

func _drawing_correction_speed_multiplier() -> float:
	var value := _drawing_instruction_multiplier("drawing_fix_here", 1.35)
	value *= _drawing_focus_work_multiplier(DRAWING_FOCUS_CORRECTION_SPEED_RATE)
	return value

func _drawing_eraser_radius() -> float:
	return DRAWING_ERASER_RADIUS * _drawing_instruction_multiplier("drawing_clean_screen", 1.15)

func _update_song_instruction_effects(delta: float, arena: Rect2) -> void:
	_update_song_howling_instruction(delta, arena)
	_update_song_bad_lights(delta, arena)
	_update_song_lyrics_cards(delta, arena)

func _cancel_deprecated_song_instruction(comment_id: String) -> void:
	if not active_effects.has(comment_id):
		return
	active_effects.clear()
	active_effect_rates.clear()
	active_sub_comment_ids.clear()
	effect_timer = 0.0
	pending_clear_hype = 0
	active_comment_hurt = false
	current_comment = "なし"
	current_death_text = "発動中の指示コメなし"
	last_comment_id = ""

func _song_mic_howling_active() -> bool:
	return _song_instruction_power("song_mic_howling") > 0.0

func _song_lighting_mistake_active() -> bool:
	return _song_instruction_power("song_lighting_mistake") > 0.0

func _song_lyrics_lost_active() -> bool:
	return last_comment_id == "song_lyrics_lost" and effect_timer > 0.0 and not song_lyrics_lost_card_collected

func _song_notes_locked_by_lyrics_lost() -> bool:
	return _song_lyrics_lost_active()

func _should_suppress_instruction_clear_bonus() -> bool:
	return last_comment_id == "song_lyrics_lost" and not song_lyrics_lost_card_collected

func _song_note_orb_texture(orb_index: int, locked: bool) -> Texture2D:
	var image_path := String(SONG_NOTE_ORB_IMAGES[orb_index])
	if not locked:
		return TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, image_path)
	var gray_key := "%s#lyrics_locked_gray" % image_path
	if song_note_gray_texture_cache.has(gray_key):
		return song_note_gray_texture_cache[gray_key] as Texture2D
	var texture: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, image_path)
	if texture == null:
		song_note_gray_texture_cache[gray_key] = null
		return null
	var image: Image = texture.get_image()
	if image == null or image.is_empty():
		return texture
	image.convert(Image.FORMAT_RGBA8)
	image.adjust_bcs(0.88, 0.88, 0.0)
	var gray_texture: Texture2D = ImageTexture.create_from_image(image)
	song_note_gray_texture_cache[gray_key] = gray_texture
	return gray_texture

func _start_song_mic_howling(arena: Rect2) -> void:
	song_howling_emitters.clear()
	song_howling_waves.clear()
	for i in range(SONG_HOWLING_EMITTER_COUNT):
		song_howling_emitters.append({
			"pos": _song_instruction_position(arena, 40.0, 260.0, 520.0),
			"timer": 0.28 + float(i) * 0.72,
			"phase": rng.randf_range(0.0, TAU)
		})

func _update_song_howling_instruction(delta: float, arena: Rect2) -> void:
	if not _song_mic_howling_active():
		song_howling_emitters.clear()
		song_howling_waves.clear()
		return
	if song_howling_emitters.is_empty():
		_start_song_mic_howling(arena)
	for i in range(song_howling_emitters.size()):
		var emitter: Dictionary = song_howling_emitters[i] as Dictionary
		emitter["timer"] = float(emitter.get("timer", 0.0)) - delta
		if float(emitter["timer"]) <= 0.0:
			_spawn_song_howling_wave(Vector2(emitter.get("pos", player_pos)))
			emitter["timer"] = SONG_HOWLING_WAVE_INTERVAL + rng.randf_range(-0.18, 0.22)
		song_howling_emitters[i] = emitter
	for i in range(song_howling_waves.size() - 1, -1, -1):
		var wave: Dictionary = song_howling_waves[i] as Dictionary
		wave["age"] = float(wave.get("age", 0.0)) + delta
		var age := float(wave.get("age", 0.0))
		var life := SONG_HOWLING_TELEGRAPH_DURATION + SONG_HOWLING_WAVE_EXPAND_DURATION
		var active := age >= SONG_HOWLING_TELEGRAPH_DURATION
		if active and not bool(wave.get("hitPlayer", false)):
			var progress := clampf((age - SONG_HOWLING_TELEGRAPH_DURATION) / maxf(0.01, SONG_HOWLING_WAVE_EXPAND_DURATION), 0.0, 1.0)
			var radius := lerpf(SONG_HOWLING_WAVE_START_RADIUS, SONG_HOWLING_WAVE_END_RADIUS, progress)
			var origin := Vector2(wave.get("pos", player_pos))
			var dist := player_pos.distance_to(origin)
			if absf(dist - radius) <= SONG_HOWLING_WAVE_THICKNESS:
				wave["hitPlayer"] = true
				var push_dir := player_pos - origin
				if push_dir.length_squared() > 0.01:
					player_vel += push_dir.normalized() * SONG_HOWLING_PLAYER_KNOCKBACK
				_apply_damage_feedback(DamageSystemScript.apply_damage_events_for_target(self, [{"source": "song_howling_wave", "damage": SONG_HOWLING_DAMAGE}]))
		if age >= life:
			song_howling_waves.remove_at(i)
		else:
			song_howling_waves[i] = wave

func _spawn_song_howling_wave(pos: Vector2) -> void:
	song_howling_waves.append({
		"pos": pos,
		"age": 0.0,
		"hitPlayer": false,
		"phase": rng.randf_range(0.0, TAU)
	})

func _start_song_lighting_mistake(arena: Rect2) -> void:
	song_bad_lights.clear()
	song_bad_light_respawn_timer = 0.0
	song_bad_light_inside = false
	_spawn_song_bad_lights(SONG_BAD_LIGHT_COUNT, arena)

func _update_song_bad_lights(delta: float, arena: Rect2) -> void:
	if not _song_lighting_mistake_active():
		song_bad_lights.clear()
		song_bad_light_respawn_timer = 0.0
		song_bad_light_inside = false
		return
	var was_inside := song_bad_light_inside
	for i in range(song_bad_lights.size() - 1, -1, -1):
		var light: Dictionary = song_bad_lights[i] as Dictionary
		light["time"] = float(light.get("time", 0.0)) - delta
		if float(light.get("time", 0.0)) <= 0.0:
			song_bad_lights.remove_at(i)
		else:
			song_bad_lights[i] = light
	if song_bad_lights.size() < SONG_BAD_LIGHT_COUNT:
		song_bad_light_respawn_timer = maxf(0.0, song_bad_light_respawn_timer - delta)
		if song_bad_light_respawn_timer <= 0.0:
			_spawn_song_bad_lights(1, arena)
			song_bad_light_respawn_timer = SONG_BAD_LIGHT_RESPAWN_DELAY
	song_bad_light_inside = false
	for item in song_bad_lights:
		var light2: Dictionary = item as Dictionary
		var radius := float(light2.get("radius", SONG_BAD_LIGHT_RADIUS))
		if player_pos.distance_squared_to(Vector2(light2.get("pos", Vector2.ZERO))) <= radius * radius:
			song_bad_light_inside = true
			break
	if song_bad_light_inside and not was_inside:
		_show_song_bad_light_attack_stop_notice()

func _show_song_bad_light_attack_stop_notice() -> void:
	hit_fx.append({
		"kind": "pickup_text",
		"pos": player_pos + Vector2(-44.0, -74.0),
		"vel": Vector2(0.0, -44.0),
		"life": 0.8,
		"maxLife": 0.8,
		"text": "攻撃停止！",
		"color": Color("#ff2f8f")
	})

func _spawn_song_bad_lights(count: int, arena: Rect2) -> void:
	for i in range(maxi(0, count)):
		song_bad_lights.append({
			"pos": _song_instruction_position(arena, SONG_BAD_LIGHT_RADIUS, 180.0, 520.0),
			"radius": SONG_BAD_LIGHT_RADIUS,
			"time": SONG_BAD_LIGHT_LIFETIME,
			"maxTime": SONG_BAD_LIGHT_LIFETIME,
			"phase": rng.randf_range(0.0, TAU)
		})

func _start_song_lyrics_lost(arena: Rect2) -> void:
	song_lyrics_cards.clear()
	song_lyrics_lost_card_collected = false
	song_lyrics_card_has_locked_pos = false
	_spawn_song_lyrics_card(arena)

func _spawn_song_lyrics_card(arena: Rect2) -> void:
	var card_lifetime := maxf(SONG_LYRICS_CARD_LIFETIME, float(effect_timer))
	if not song_lyrics_card_has_locked_pos:
		song_lyrics_card_locked_pos = _song_lyrics_card_position(arena)
		song_lyrics_card_has_locked_pos = true
	song_lyrics_cards.append({
		"pos": song_lyrics_card_locked_pos,
		"time": card_lifetime,
		"maxTime": card_lifetime,
		"phase": rng.randf_range(0.0, TAU)
	})

func _update_song_lyrics_cards(_delta: float, arena: Rect2) -> void:
	if not _song_lyrics_lost_active():
		song_lyrics_cards.clear()
		return
	if song_lyrics_cards.is_empty():
		_spawn_song_lyrics_card(arena)
	for i in range(song_lyrics_cards.size() - 1, -1, -1):
		var card: Dictionary = song_lyrics_cards[i] as Dictionary
		var remaining := maxf(0.0, float(effect_timer))
		card["time"] = remaining
		card["maxTime"] = maxf(float(card.get("maxTime", SONG_LYRICS_CARD_LIFETIME)), remaining)
		var pos := Vector2(card.get("pos", Vector2.ZERO))
		if pos.distance_squared_to(player_pos) <= SONG_LYRICS_CARD_PICKUP_RADIUS * SONG_LYRICS_CARD_PICKUP_RADIUS:
			song_lyrics_cards.remove_at(i)
			_collect_song_lyrics_card(pos)
			continue
		song_lyrics_cards[i] = card

func _collect_song_lyrics_card(pos: Vector2) -> void:
	song_lyrics_lost_card_collected = true
	_play_song_lyrics_card_pickup_se()
	ModifierSystemScript.clear_state_for_target(self)
	hit_fx.append({
		"kind": "pickup_text",
		"pos": pos + Vector2(-64.0, -58.0),
		"vel": Vector2(0.0, -46.0),
		"life": 0.78,
		"maxLife": 0.78,
		"text": "歌詞カード回収！",
		"color": Color("#ff5cad")
	})
	_push_time_toast("歌詞カード回収！ 音階コンボ再開", 1.4)
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": ["+ 歌詞カード回収！", "+ 音階コンボ再開", "> 戻ってきた"]}, chat_box)

func _spawn_song_instruction_enemies(kind: String, count: int, arena: Rect2) -> void:
	for i in range(maxi(0, count)):
		EnemySystemScript.spawn_enemy_for_target(self, kind, arena, rng)

func _start_song_chorus_telegraph() -> void:
	song_chorus_telegraph_timer = SONG_CHORUS_TELEGRAPH_DURATION
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": ["* もうすぐサビ！", "> ペンライト準備", "> 盛り上がってきた"]}, chat_box)
	_push_time_toast("もうすぐサビ！", 1.1)

func _start_song_chorus(arena: Rect2, forced: bool = false) -> void:
	song_chorus_count += 1
	song_forced_chorus_active = forced
	song_chorus_current_duration = 8.0 if forced else SONG_CHORUS_DURATION
	song_chorus_reward_multiplier = 0.5 if forced else 1.0
	song_chorus_timer = song_chorus_current_duration
	song_chorus_banner_timer = SONG_CHORUS_BANNER_DURATION
	song_chorus_notes_collected = 0
	song_chorus_spotlight_time = 0.0
	song_chorus_enemy_spawn_timer = rng.randf_range(1.0, 1.8)
	song_chorus_viewer_accum = 0.0
	song_spotlight_inside_last_frame = false
	song_notes.clear()
	song_spotlights.clear()
	var note_count := int(round(float(rng.randi_range(SONG_NOTE_COUNT_MIN, SONG_NOTE_COUNT_MAX)) * _song_note_spawn_multiplier()))
	if song_encore_timer > 0.0:
		note_count = int(round(float(note_count) * 1.8))
	if forced:
		note_count = maxi(4, int(round(float(note_count) * 0.85)))
	_spawn_song_notes(note_count, arena)
	var spotlight_max := mini(_song_max_spotlights(), SONG_SPOTLIGHT_COUNT_MAX + (1 if song_encore_timer > 0.0 else 0))
	if forced:
		spotlight_max = mini(spotlight_max, 1)
	var spotlight_min := mini(SONG_SPOTLIGHT_COUNT_MIN, spotlight_max)
	_spawn_song_spotlights(rng.randi_range(spotlight_min, spotlight_max), arena)
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": ["* サビタイム！", "+ 音符集めろ！", "+ スポットライト入ろう"]}, chat_box)
	_push_time_toast("サビタイム！", 1.2)
	screen_flash_timer = 0.12
	screen_flash_duration = 0.12
	screen_flash_color = Color(1.0, 0.58, 0.86, 0.12)

func _finish_song_chorus() -> void:
	var good_result := song_chorus_notes_collected >= 8 or song_chorus_spotlight_time >= 2.2
	var reward_multiplier := song_chorus_reward_multiplier
	_add_song_live_heat((SONG_LIVE_HEAT_CHORUS_FINISH_GAIN + (SONG_LIVE_HEAT_CHORUS_GOOD_GAIN if good_result else 0.0)) * _song_live_heat_gain_multiplier() * reward_multiplier, "chorus_finish")
	song_chorus_result_data = {
		"title": "サビ成功！" if good_result else "サビタイム RESULT",
		"lines": [
			"音符 %d個GET" % song_chorus_notes_collected,
			"スポットライト %.1f秒" % song_chorus_spotlight_time,
			"LIVE HEAT Lv.%d" % song_live_heat_level
		]
	}
	song_chorus_result_duration = SONG_CHORUS_RESULT_CARD_DURATION
	song_chorus_result_timer = song_chorus_result_duration
	song_chorus_next_time = elapsed + _song_next_interval()
	if song_forced_chorus_active:
		song_chorus_next_time = maxf(song_chorus_next_time, elapsed + 10.0)
	song_notes.clear()
	song_spotlights.clear()
	song_spotlight_inside_last_frame = false
	song_forced_chorus_active = false
	song_chorus_reward_multiplier = 1.0
	song_chorus_current_duration = SONG_CHORUS_DURATION
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": ["* サビタイム終了！", "+ いいサビだった", "> 次のサビもいこう"]}, chat_box)

func _spawn_song_notes(count: int, arena: Rect2, chorus_note: bool = true, lifetime: float = 0.0, note_tag: String = "") -> void:
	for i in range(count):
		var pos := _song_event_position(arena, 34.0, SONG_NOTE_OBSTACLE_CLEARANCE)
		var note_lifetime := lifetime
		if note_lifetime > 0.0:
			note_lifetime *= _song_note_lifetime_multiplier()
		var note := {
			"pos": pos,
			"orbIndex": rng.randi_range(0, SONG_NOTE_ORB_IMAGES.size() - 1),
			"phase": rng.randf_range(0.0, TAU),
			"chorus": chorus_note,
			"time": note_lifetime
		}
		if note_tag != "":
			note["noteTag"] = note_tag
		song_notes.append(note)

func _spawn_song_spotlights(count: int, arena: Rect2) -> void:
	for i in range(count):
		song_spotlights.append({
			"pos": _song_event_position(arena, SONG_SPOTLIGHT_RADIUS + 20.0, SONG_SPOTLIGHT_OBSTACLE_CLEARANCE),
			"radius": SONG_SPOTLIGHT_RADIUS,
			"time": SONG_SPOTLIGHT_DURATION,
			"maxTime": SONG_SPOTLIGHT_DURATION,
			"phase": rng.randf_range(0.0, TAU)
		})

func _song_event_position(arena: Rect2, radius: float, obstacle_clearance: float = -1.0) -> Vector2:
	var walls := EnemySystemScript.movement_wall_rects(effect_walls, current_stream_frame_id)
	var rect := arena.grow(-(radius + 36.0))
	for i in range(42):
		var pos := Vector2(rng.randf_range(rect.position.x, rect.end.x), rng.randf_range(rect.position.y, rect.end.y))
		if pos.distance_squared_to(player_pos) < 12100.0:
			continue
		var blocked := false
		for wall_value in walls:
			var wall: Rect2 = wall_value as Rect2
			if wall.grow(radius + 18.0).has_point(pos):
				blocked = true
				break
		if not blocked and obstacle_clearance > 0.0 and _song_stage_prop_position_blocked(pos, obstacle_clearance):
			blocked = true
		if not blocked:
			return pos
	for i in range(24):
		var fallback := arena.get_center() + Vector2(rng.randf_range(-220.0, 220.0), rng.randf_range(-150.0, 150.0))
		if obstacle_clearance <= 0.0 or not _song_stage_prop_position_blocked(fallback, obstacle_clearance):
			return fallback
	return arena.get_center()

func _song_stage_prop_position_blocked(pos: Vector2, clearance: float) -> bool:
	for rect_value in MapBackgroundSystemScript.prop_collision_rects_for_data(_current_map_data()):
		var rect: Rect2 = rect_value as Rect2
		if rect.grow(clearance).has_point(pos):
			return true
	return false

func _song_instruction_position(arena: Rect2, radius: float, min_distance: float, max_distance: float) -> Vector2:
	var walls := EnemySystemScript.movement_wall_rects(effect_walls, current_stream_frame_id)
	var rect := arena.grow(-(radius + 36.0))
	var min_sq := min_distance * min_distance
	var max_dist := maxf(min_distance + 10.0, max_distance)
	for i in range(56):
		var angle := rng.randf_range(0.0, TAU)
		var distance := rng.randf_range(min_distance, max_dist)
		var pos := player_pos + Vector2(cos(angle), sin(angle)) * distance
		if not rect.has_point(pos):
			continue
		if pos.distance_squared_to(player_pos) < min_sq:
			continue
		var blocked := false
		for wall_value in walls:
			var wall: Rect2 = wall_value as Rect2
			if wall.grow(radius + 18.0).has_point(pos):
				blocked = true
				break
		if not blocked and _song_stage_prop_position_blocked(pos, maxf(radius + 18.0, SONG_NOTE_OBSTACLE_CLEARANCE)):
			blocked = true
		if not blocked:
			return pos
	return _song_event_position(arena, radius)

func _song_position_blocked(pos: Vector2, radius: float) -> bool:
	var walls := EnemySystemScript.movement_wall_rects(effect_walls, current_stream_frame_id)
	for wall_value in walls:
		var wall: Rect2 = wall_value as Rect2
		if wall.grow(radius + 18.0).has_point(pos):
			return true
	if _song_stage_prop_position_blocked(pos, SONG_LYRICS_CARD_OBSTACLE_CLEARANCE):
		return true
	return false

func _song_lyrics_card_visible_rect(arena: Rect2) -> Rect2:
	var visible_rect := _visible_world_rect_for_spawning().intersection(arena).grow(-86.0)
	if visible_rect.has_area():
		return visible_rect
	return arena.grow(-86.0)

func _song_lyrics_card_position(arena: Rect2) -> Vector2:
	var radius := 48.0
	var rect := _song_lyrics_card_visible_rect(arena).grow(-radius)
	if not rect.has_area():
		rect = arena.grow(-(radius + 36.0))
	var min_sq := SONG_LYRICS_CARD_MIN_DISTANCE * SONG_LYRICS_CARD_MIN_DISTANCE
	var max_sq := SONG_LYRICS_CARD_MAX_DISTANCE * SONG_LYRICS_CARD_MAX_DISTANCE
	var best_pos := Vector2.ZERO
	var best_dist_sq := -1.0
	for i in range(120):
		var pos := Vector2(rng.randf_range(rect.position.x, rect.end.x), rng.randf_range(rect.position.y, rect.end.y))
		var dist_sq := pos.distance_squared_to(player_pos)
		if dist_sq < min_sq or dist_sq > max_sq:
			continue
		if _song_position_blocked(pos, radius):
			continue
		if dist_sq > best_dist_sq:
			best_pos = pos
			best_dist_sq = dist_sq
	if best_dist_sq >= 0.0:
		return best_pos
	var fallback_min_sq := min_sq * 0.42
	for i in range(80):
		var pos := Vector2(rng.randf_range(rect.position.x, rect.end.x), rng.randf_range(rect.position.y, rect.end.y))
		var dist_sq := pos.distance_squared_to(player_pos)
		if dist_sq < fallback_min_sq:
			continue
		if _song_position_blocked(pos, radius):
			continue
		if dist_sq > best_dist_sq:
			best_pos = pos
			best_dist_sq = dist_sq
	if best_dist_sq >= 0.0:
		return best_pos
	return rect.get_center()

func _song_far_instruction_position(arena: Rect2, radius: float, min_distance: float, max_distance: float) -> Vector2:
	var walls := EnemySystemScript.movement_wall_rects(effect_walls, current_stream_frame_id)
	var rect := arena.grow(-(radius + 36.0))
	var min_sq := min_distance * min_distance
	var max_dist := maxf(min_distance + 10.0, max_distance)
	var best_pos := Vector2.ZERO
	var best_dist_sq := -1.0
	for i in range(96):
		var angle := rng.randf_range(0.0, TAU)
		var distance := lerpf(min_distance, max_dist, pow(rng.randf(), 0.35))
		var pos := player_pos + Vector2(cos(angle), sin(angle)) * distance
		var dist_sq := pos.distance_squared_to(player_pos)
		if dist_sq < min_sq or not rect.has_point(pos):
			continue
		var blocked := false
		for wall_value in walls:
			var wall: Rect2 = wall_value as Rect2
			if wall.grow(radius + 18.0).has_point(pos):
				blocked = true
				break
		if not blocked and dist_sq > best_dist_sq:
			best_pos = pos
			best_dist_sq = dist_sq
	if best_dist_sq >= 0.0:
		return best_pos
	for i in range(72):
		var pos := Vector2(rng.randf_range(rect.position.x, rect.end.x), rng.randf_range(rect.position.y, rect.end.y))
		var dist_sq := pos.distance_squared_to(player_pos)
		if dist_sq < min_sq:
			continue
		var blocked := false
		for wall_value in walls:
			var wall: Rect2 = wall_value as Rect2
			if wall.grow(radius + 18.0).has_point(pos):
				blocked = true
				break
		if not blocked and dist_sq > best_dist_sq:
			best_pos = pos
			best_dist_sq = dist_sq
	if best_dist_sq >= 0.0:
		return best_pos
	return _song_instruction_position(arena, radius, min_distance, max_distance)

func _reset_song_ambient_note_timer() -> void:
	song_ambient_note_timer = rng.randf_range(SONG_AMBIENT_NOTE_INTERVAL_MIN, SONG_AMBIENT_NOTE_INTERVAL_MAX) / maxf(0.75, _song_note_spawn_multiplier())

func _update_song_ambient_notes(delta: float, arena: Rect2) -> void:
	if song_chorus_timer > 0.0 or song_chorus_telegraph_timer > 0.0:
		return
	song_ambient_note_timer -= delta
	if song_ambient_note_timer > 0.0:
		return
	_reset_song_ambient_note_timer()
	var ambient_count := 0
	for item in song_notes:
		var note: Dictionary = item as Dictionary
		if not bool(note.get("chorus", true)):
			ambient_count += 1
	if ambient_count < 2:
		_spawn_song_notes(1, arena, false, SONG_AMBIENT_NOTE_LIFETIME)

func _update_song_notes(delta: float) -> void:
	var lyrics_locked := _song_notes_locked_by_lyrics_lost()
	for i in range(song_notes.size() - 1, -1, -1):
		var note: Dictionary = song_notes[i] as Dictionary
		if not lyrics_locked and not bool(note.get("chorus", true)) and note.has("time"):
			note["time"] = float(note.get("time", 0.0)) - delta
			if float(note["time"]) <= 0.0:
				song_notes.remove_at(i)
				continue
			song_notes[i] = note
		if lyrics_locked:
			continue
		if Vector2(note.get("pos", Vector2.ZERO)).distance_squared_to(player_pos) <= 2304.0:
			_collect_song_note(i)

func _collect_song_note(index: int) -> void:
	if index < 0 or index >= song_notes.size():
		return
	var note: Dictionary = song_notes[index] as Dictionary
	song_notes.remove_at(index)
	var chorus_note := bool(note.get("chorus", song_chorus_timer > 0.0))
	if chorus_note:
		song_chorus_notes_collected += 1
	if song_boss_chorus_judge_active:
		if song_boss_chorus_judge_required > 0:
			song_boss_chorus_judge_collected = mini(song_boss_chorus_judge_required, song_boss_chorus_judge_collected + 1)
		else:
			song_boss_chorus_judge_collected += 1
	song_total_notes_collected += 1
	_handle_song_note_scale_combo()
	var heat_gain := SONG_LIVE_HEAT_CHORUS_NOTE_GAIN if chorus_note else SONG_LIVE_HEAT_NOTE_GAIN
	_add_song_live_heat(heat_gain * _song_live_heat_gain_multiplier() * _song_note_live_heat_gain_multiplier(), "chorus_note" if chorus_note else "note")
	_song_add_viewers(SONG_NOTE_VIEWER_GAIN)
	_song_add_voltage(SONG_NOTE_VOLTAGE_GAIN)
	var note_pos := Vector2(note.get("pos", player_pos))
	hit_fx.append({
		"kind": "song_note",
		"pos": note_pos,
		"life": 0.38,
		"maxLife": 0.38,
		"radius": 26.0
	})
	if song_live_heat_level >= 2:
		_fire_song_note_pickup_extra_shot(note_pos)
	if song_live_heat_level >= 3:
		song_harmony_wave_timer = maxf(0.0, song_harmony_wave_timer - 0.30)
	if song_live_heat_level >= 4:
		_song_live_heat_note_heal(1)
	if song_live_heat_level >= 5:
		song_audience_call_wave_timer = maxf(0.0, song_audience_call_wave_timer - 0.40)
	if chorus_note and (song_chorus_notes_collected == 1 or song_chorus_notes_collected % 4 == 0):
		chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": ["+ 音符GET！", "+ ライブテンション上がってる"]}, chat_box)
	elif not chorus_note:
		chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": ["+ 音符GET！", "> いいリズム"]}, chat_box)

func _handle_song_note_scale_combo() -> void:
	var play_index := clampi(song_note_scale_index, 0, SONG_SCALE_NOTE_COUNT - 1)
	_enqueue_song_scale_note_se(play_index)
	song_note_total_collected += 1
	song_note_scale_index += 1
	if song_note_scale_index >= SONG_SCALE_NOTE_COUNT:
		song_note_scale_index = 0
		song_octave_bonus_count += 1
		_trigger_song_octave_bonus()

func _handle_song_note_scale_paused() -> void:
	var play_index := clampi(song_note_scale_index, 0, SONG_SCALE_NOTE_COUNT - 1)
	_enqueue_song_scale_note_se(play_index)
	song_note_total_collected += 1

func _trigger_song_octave_bonus() -> void:
	_add_song_live_heat(SONG_OCTAVE_BONUS_LIVE_HEAT_GAIN, "octave_bonus")
	score += SONG_OCTAVE_BONUS_VIEWER_GAIN
	_add_song_gift_hype_reward(SONG_OCTAVE_BONUS_GIFT_HYPE_GAIN)
	var hits := _spawn_song_live_heat_wave("octave_wave", SONG_OCTAVE_BONUS_RADIUS, SONG_OCTAVE_BONUS_DAMAGE, SONG_OCTAVE_BONUS_KNOCKBACK, Color("#ffe177"), "song_octave_bonus")
	var call_wave_triggered := _try_trigger_song_max_octave_audience_call_wave()
	_show_song_octave_bonus_notice(hits, call_wave_triggered)
	hit_fx.append({
		"kind": "pickup_text",
		"pos": player_pos + Vector2(-84.0, -84.0),
		"vel": Vector2(0.0, -48.0),
		"life": 0.86,
		"maxLife": 0.86,
		"text": "1オクターブ完成！",
		"color": Color("#ffb33d")
	})
	_push_time_toast("1オクターブ完成！ テンション+5 / 視聴者+500 / 期待度+1", 1.55)
	if call_wave_triggered:
		_push_time_toast("オクターブMAX！ 観客コール波！", 1.55)
	var octave_chats: Array[String] = ["+ 1オクターブ完成！", "+ ライブテンション +5 / 視聴者 +500", "+ ギフト期待度 +1", "> 音波ボーナス出た"]
	if call_wave_triggered:
		octave_chats.append("+ オクターブMAX！")
		octave_chats.append("+ 観客コール波！")
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": octave_chats}, chat_box)

func _show_song_octave_bonus_notice(hit_count: int, call_wave_triggered: bool = false) -> void:
	song_octave_bonus_notice_hits = hit_count
	song_octave_bonus_notice_call_wave = call_wave_triggered
	song_octave_bonus_notice_duration = SONG_OCTAVE_BONUS_NOTICE_DURATION
	song_octave_bonus_notice_timer = song_octave_bonus_notice_duration

func _update_song_spotlights(delta: float) -> void:
	song_spotlight_benefit_se_cooldown = maxf(0.0, song_spotlight_benefit_se_cooldown - delta)
	song_spotlight_benefit_flash_timer = maxf(0.0, song_spotlight_benefit_flash_timer - delta)
	for i in range(song_spotlights.size() - 1, -1, -1):
		var light: Dictionary = song_spotlights[i] as Dictionary
		light["time"] = maxf(0.0, float(light.get("time", 0.0)) - delta)
		if float(light["time"]) <= 0.0:
			song_spotlights.remove_at(i)
		else:
			song_spotlights[i] = light
	var inside := false
	for item in song_spotlights:
		var light: Dictionary = item as Dictionary
		var radius := float(light.get("radius", SONG_SPOTLIGHT_RADIUS))
		if player_pos.distance_squared_to(Vector2(light.get("pos", Vector2.ZERO))) <= radius * radius:
			inside = true
			break
	if inside:
		if song_chorus_timer > 0.0:
			song_chorus_spotlight_time += delta
		song_total_spotlight_time += delta
		_add_song_live_heat(SONG_LIVE_HEAT_SPOTLIGHT_GAIN_PER_SECOND * delta * _song_live_heat_gain_multiplier(), "spotlight")
		_song_add_voltage(SONG_SPOTLIGHT_VOLTAGE_RATE * delta)
		song_chorus_viewer_accum += SONG_SPOTLIGHT_VIEWER_GAIN_PER_SECOND * delta * _song_viewer_gain_multiplier()
		var add_viewers := int(floor(song_chorus_viewer_accum))
		if add_viewers > 0:
			score += add_viewers
			song_chorus_viewer_accum -= float(add_viewers)
			song_spotlight_benefit_flash_timer = 0.45
			if song_spotlight_benefit_se_cooldown <= 0.0:
				_play_song_spotlight_benefit_se()
				song_spotlight_benefit_se_cooldown = SONG_SPOTLIGHT_BENEFIT_SE_INTERVAL
	if inside and not song_spotlight_inside_last_frame:
		chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": ["+ スポットライト！", "> 今映えてる"]}, chat_box)
	song_spotlight_inside_last_frame = inside

func _update_song_chorus_enemy_spawns(delta: float, arena: Rect2) -> void:
	song_chorus_enemy_spawn_timer -= delta
	if song_chorus_enemy_spawn_timer > 0.0:
		return
	var spawn_multiplier := maxf(0.5, _song_enemy_spawn_multiplier())
	song_chorus_enemy_spawn_timer = rng.randf_range(SONG_CHORUS_EXTRA_ENEMY_INTERVAL_MIN, SONG_CHORUS_EXTRA_ENEMY_INTERVAL_MAX) / spawn_multiplier
	EnemySystemScript.spawn_enemy_for_target(self, "fast_call_fan", arena, rng)
	if rng.randf() < 0.35 + float(song_live_heat_level) * 0.03:
		EnemySystemScript.spawn_enemy_for_target(self, "pitch_police", arena, rng)

func _song_pitch_wave_interval() -> float:
	if song_live_heat_level >= 5:
		return 8.0
	if song_live_heat_level >= 4:
		return 10.0
	return 14.0

# Kept as a reusable attack primitive for future song bosses or enemies.
func _update_song_pitch_waves(delta: float) -> void:
	for i in range(song_pitch_waves.size() - 1, -1, -1):
		var wave: Dictionary = song_pitch_waves[i] as Dictionary
		wave["time"] = float(wave.get("time", 0.0)) - delta
		var age := float(wave.get("maxTime", 1.0)) - float(wave.get("time", 0.0))
		var active := age >= SONG_PITCH_WAVE_TELEGRAPH_DURATION
		var wave_rect: Rect2 = wave.get("rect", Rect2()) as Rect2
		if active and not bool(wave.get("hit", false)) and wave_rect.has_point(player_pos):
			wave["hit"] = true
			_apply_damage_feedback(DamageSystemScript.apply_damage_events_for_target(self, [{"source": "pitch_wave", "damage": SONG_PITCH_WAVE_DAMAGE}]))
		if float(wave.get("time", 0.0)) <= 0.0:
			song_pitch_waves.remove_at(i)
		else:
			song_pitch_waves[i] = wave
	if song_pitch_wave_cooldown > 0.0:
		song_pitch_wave_cooldown = maxf(0.0, song_pitch_wave_cooldown - delta)

func _spawn_song_pitch_wave(arena: Rect2) -> void:
	var horizontal := rng.randf() < 0.55
	var rect: Rect2
	if horizontal:
		var y := clampf(player_pos.y + rng.randf_range(-130.0, 130.0), arena.position.y + SONG_PITCH_WAVE_WIDTH, arena.end.y - SONG_PITCH_WAVE_WIDTH)
		rect = Rect2(Vector2(arena.position.x, y - SONG_PITCH_WAVE_WIDTH * 0.5), Vector2(arena.size.x, SONG_PITCH_WAVE_WIDTH))
	else:
		var x := clampf(player_pos.x + rng.randf_range(-180.0, 180.0), arena.position.x + SONG_PITCH_WAVE_WIDTH, arena.end.x - SONG_PITCH_WAVE_WIDTH)
		rect = Rect2(Vector2(x - SONG_PITCH_WAVE_WIDTH * 0.5, arena.position.y), Vector2(SONG_PITCH_WAVE_WIDTH, arena.size.y))
	song_pitch_waves.append({
		"rect": rect,
		"time": SONG_PITCH_WAVE_TELEGRAPH_DURATION + SONG_PITCH_WAVE_ACTIVE_DURATION,
		"maxTime": SONG_PITCH_WAVE_TELEGRAPH_DURATION + SONG_PITCH_WAVE_ACTIVE_DURATION,
		"horizontal": horizontal,
		"hit": false
	})
	song_pitch_wave_cooldown = _song_pitch_wave_interval()
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": ["! 音程ズレ波注意", "> 赤紫のライン避けて"]}, chat_box)

func _show_song_boss_chorus_judge_notice(title: String, subtitle: String, success: bool = false, duration: float = 1.25) -> void:
	song_boss_chorus_judge_notice_title = title
	song_boss_chorus_judge_notice_subtitle = subtitle
	song_boss_chorus_judge_notice_success = success
	song_boss_chorus_judge_notice_duration = duration
	song_boss_chorus_judge_notice_timer = duration

func _prepare_song_boss_chorus_judge(required: int, duration: float) -> void:
	song_boss_chorus_judge_busy = true
	song_boss_chorus_judge_active = false
	song_boss_chorus_judge_required = required
	song_boss_chorus_judge_collected = 0
	song_boss_chorus_judge_timer = duration
	song_boss_chorus_judge_duration = duration
	_remove_song_boss_chorus_judge_notes()
	song_chorus_telegraph_timer = 0.0
	song_chorus_banner_timer = 0.0
	song_chorus_result_timer = 0.0
	song_chorus_result_data.clear()
	_show_song_boss_chorus_judge_notice("サビジャッジ予告！", "音符を%d個集めろ！" % required, false, 1.35)

func _start_song_boss_chorus_judge(required: int, duration: float) -> void:
	song_boss_chorus_judge_busy = true
	song_boss_chorus_judge_active = true
	song_boss_chorus_judge_required = required
	song_boss_chorus_judge_collected = 0
	song_boss_chorus_judge_timer = duration
	song_boss_chorus_judge_duration = duration
	_remove_song_boss_chorus_judge_notes()
	_show_song_boss_chorus_judge_notice("サビジャッジ中！", "音符を%d個集めろ！" % required, false, 1.0)

func _spawn_song_boss_chorus_judge_notes(count: int, arena: Rect2) -> void:
	_spawn_song_notes(count, arena, true, 0.0, "chorus_judge_note")

func _finish_song_boss_chorus_judge(success: bool) -> void:
	song_boss_chorus_judge_active = false
	song_boss_chorus_judge_busy = false
	var title := "サビジャッジ成功！" if success else "サビジャッジ未達"
	var subtitle := "ボス停止・与ダメージUP" if success else "短時間だけ停止"
	_show_song_boss_chorus_judge_notice(title, subtitle, success, 1.45)
	_remove_song_boss_chorus_judge_notes()

func _clear_song_boss_chorus_judge() -> void:
	song_boss_chorus_judge_busy = false
	song_boss_chorus_judge_active = false
	song_boss_chorus_judge_required = 0
	song_boss_chorus_judge_collected = 0
	song_boss_chorus_judge_timer = 0.0
	song_boss_chorus_judge_duration = 0.0
	song_boss_chorus_judge_notice_timer = 0.0
	song_boss_chorus_judge_notice_duration = 0.0
	song_boss_chorus_judge_notice_title = ""
	song_boss_chorus_judge_notice_subtitle = ""
	song_boss_chorus_judge_notice_success = false
	_remove_song_boss_chorus_judge_notes()
	song_boss_megaphone_waves.clear()

func _remove_song_boss_chorus_judge_notes() -> void:
	for i in range(song_notes.size() - 1, -1, -1):
		var note: Dictionary = song_notes[i] as Dictionary
		if String(note.get("noteTag", "")) == "chorus_judge_note":
			song_notes.remove_at(i)

func _update_song_boss_chorus_judge(delta: float) -> void:
	if not song_boss_chorus_judge_active:
		return
	song_boss_chorus_judge_timer = maxf(0.0, song_boss_chorus_judge_timer - delta)

func _spawn_song_boss_megaphone_wave(origin: Vector2, dir: Vector2, wave_range: float, angle: float, telegraph: float, active_duration: float, damage: int, knockback: float) -> void:
	var wave_dir := dir.normalized()
	if wave_dir.length_squared() <= 0.01:
		wave_dir = Vector2.RIGHT
	song_boss_megaphone_waves.append({
		"origin": origin,
		"dir": wave_dir,
		"range": wave_range,
		"angle": angle,
		"telegraph": telegraph,
		"activeDuration": active_duration,
		"time": telegraph + active_duration,
		"maxTime": telegraph + active_duration,
		"damage": damage,
		"knockback": knockback,
		"hit": false
	})

func _update_song_boss_megaphone_waves(delta: float) -> void:
	for i in range(song_boss_megaphone_waves.size() - 1, -1, -1):
		var wave: Dictionary = song_boss_megaphone_waves[i] as Dictionary
		wave["time"] = float(wave.get("time", 0.0)) - delta
		var age := float(wave.get("maxTime", 1.0)) - float(wave.get("time", 0.0))
		var active := age >= float(wave.get("telegraph", 0.7))
		if active and not bool(wave.get("hit", false)):
			var origin := Vector2(wave.get("origin", Vector2.ZERO))
			var wave_dir := Vector2(wave.get("dir", Vector2.RIGHT)).normalized()
			var to_player := player_pos - origin
			var dist := to_player.length()
			if dist > 0.01 and dist <= float(wave.get("range", 380.0)):
				var angle_diff := absf(wrapf(to_player.angle() - wave_dir.angle(), -PI, PI))
				if angle_diff <= float(wave.get("angle", PI / 3.0)) * 0.5:
					wave["hit"] = true
					player_vel += to_player.normalized() * float(wave.get("knockback", 0.7)) * 260.0
					_apply_damage_feedback(DamageSystemScript.apply_damage_events_for_target(self, [{"source": "boss_attack", "damage": int(wave.get("damage", 28))}]))
		if float(wave.get("time", 0.0)) <= 0.0:
			song_boss_megaphone_waves.remove_at(i)
		else:
			song_boss_megaphone_waves[i] = wave

func _update_song_encore(delta: float, arena: Rect2) -> void:
	if song_encore_timer > 0.0:
		song_encore_timer = maxf(0.0, song_encore_timer - delta)
		if song_encore_timer <= 0.0 and song_encore_triggered:
			song_encore_completed = true
			chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": ["+ アンコール完走！", "888888", "+ 最後まで盛り上がった"]}, chat_box)
		return
	if song_encore_triggered or not song_encore_unlocked:
		return
	var run_length := RunStateSystemScript.run_length(quick_test_mode, QUICK_RUN_LENGTH, NORMAL_RUN_LENGTH)
	var remaining := run_length - elapsed
	if remaining <= SONG_ENCORE_TRIGGER_REMAINING and remaining > 3.0:
		_start_song_encore(arena)

func _start_song_encore(arena: Rect2) -> void:
	song_encore_triggered = true
	song_encore_timer = SONG_ENCORE_DURATION
	_add_song_live_heat(6.0, "encore_start")
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": ["+ アンコール！", "+ 最後まで盛り上げろ！", "w 終われない空気"]}, chat_box)
	_push_time_toast("アンコール！", 1.3)
	if song_chorus_timer <= 0.0 and song_chorus_telegraph_timer <= 0.0:
		_start_song_chorus(arena)

func _update_song_live_heat_buffs(delta: float, arena: Rect2) -> void:
	_update_song_live_heat_fx(delta)
	_update_song_note_trail(delta)
	if song_live_heat_level >= 2:
		_update_song_penlight_bits(delta)
	else:
		song_penlight_bit_shot_timer = 0.0
	if song_live_heat_level >= 3:
		_update_song_harmony_wave(delta)
	else:
		song_harmony_wave_timer = 0.0
	if song_live_heat_level >= 5:
		_update_song_audience_call_wave(delta, arena)
	else:
		song_audience_call_wave_timer = 0.0

func _update_song_live_heat_fx(delta: float) -> void:
	for i in range(song_live_heat_fx.size() - 1, -1, -1):
		var fx: Dictionary = song_live_heat_fx[i] as Dictionary
		fx["life"] = float(fx.get("life", 0.0)) - delta
		if float(fx.get("life", 0.0)) <= 0.0:
			song_live_heat_fx.remove_at(i)
		else:
			song_live_heat_fx[i] = fx

func _update_song_note_trail(delta: float) -> void:
	var speed_sq := player_vel.length_squared()
	if song_live_heat_level < 1 or speed_sq < 4225.0:
		return
	song_note_trail_timer -= delta
	if song_note_trail_timer > 0.0:
		return
	song_note_trail_timer = 0.10 if song_live_heat_level >= 5 else 0.16
	var colors := [Color("#ff8fc8"), Color("#8eeaff"), Color("#d6b4ff"), Color("#ffe177")]
	var symbols := ["♪", "♬", "☆", "♡"]
	song_live_heat_fx.append({
		"kind": "note_trail",
		"pos": player_pos - player_vel.normalized() * 24.0 + Vector2(rng.randf_range(-10.0, 10.0), rng.randf_range(-8.0, 8.0)),
		"life": 0.48,
		"maxLife": 0.48,
		"symbol": String(symbols[rng.randi_range(0, symbols.size() - 1)]),
		"color": colors[rng.randi_range(0, colors.size() - 1)]
	})

func _update_song_penlight_bits(delta: float) -> void:
	if song_penlight_bit_shot_timer <= 0.0:
		song_penlight_bit_shot_timer = SONG_PENLIGHT_BIT_SHOT_INTERVAL
	song_penlight_bit_shot_timer -= delta
	if song_penlight_bit_shot_timer > 0.0:
		return
	song_penlight_bit_shot_timer = SONG_PENLIGHT_BIT_SHOT_INTERVAL
	var fired := false
	for i in range(SONG_PENLIGHT_BIT_COUNT):
		var bit_pos := _song_penlight_bit_position(i)
		var target := _song_nearest_enemy(bit_pos, SONG_PENLIGHT_BIT_SHOT_RANGE)
		if target.is_empty():
			continue
		fired = true
		var target_pos := Vector2(target.get("pos", bit_pos))
		_song_apply_enemy_damage(target, SONG_PENLIGHT_BIT_SHOT_DAMAGE, bit_pos, SONG_PENLIGHT_BIT_SHOT_KNOCKBACK, "song_penlight_bit")
		song_live_heat_fx.append({
			"kind": "penlight_shot",
			"from": bit_pos,
			"to": target_pos,
			"life": 0.24,
			"maxLife": 0.24,
			"color": Color("#8eeaff") if i % 2 == 0 else Color("#ff8fc8")
		})
	if fired:
		_play_song_penlight_bit_attack_se()

func _song_penlight_bit_position(index: int) -> Vector2:
	var angle := elapsed * 1.65 + TAU * float(index) / maxf(1.0, float(SONG_PENLIGHT_BIT_COUNT))
	var radius := 58.0 + sin(elapsed * 3.4 + float(index)) * 5.0
	return player_pos + Vector2(cos(angle), sin(angle)) * radius

func _update_song_harmony_wave(delta: float) -> void:
	if song_harmony_wave_timer <= 0.0:
		song_harmony_wave_timer = SONG_HARMONY_WAVE_INTERVAL
	song_harmony_wave_timer -= delta
	if song_harmony_wave_timer > 0.0:
		return
	_spawn_song_live_heat_wave("harmony_wave", SONG_HARMONY_WAVE_RADIUS, SONG_HARMONY_WAVE_DAMAGE, SONG_HARMONY_WAVE_KNOCKBACK, Color("#ff8fc8"), "song_harmony_wave")
	song_harmony_wave_timer = SONG_HARMONY_WAVE_INTERVAL

func _update_song_audience_call_wave(delta: float, arena: Rect2) -> void:
	if song_audience_call_wave_timer <= 0.0:
		song_audience_call_wave_timer = SONG_AUDIENCE_CALL_WAVE_INTERVAL
	song_audience_call_wave_timer -= delta
	if song_audience_call_wave_timer > 0.0:
		return
	_spawn_song_audience_call_wave(arena)
	song_audience_call_wave_timer = SONG_AUDIENCE_CALL_WAVE_INTERVAL

func _spawn_song_audience_call_wave(arena: Rect2) -> int:
	var width := SONG_AUDIENCE_CALL_WAVE_WIDTH
	var horizontal_lane := rng.randf() < 0.65
	var forward := rng.randf() < 0.5
	var lane_rect := Rect2()
	var origin := Vector2.ZERO
	var dir := Vector2.RIGHT
	if horizontal_lane:
		var y := clampf(player_pos.y + rng.randf_range(-120.0, 120.0), arena.position.y + width * 0.5, arena.end.y - width * 0.5)
		lane_rect = Rect2(Vector2(arena.position.x, y - width * 0.5), Vector2(arena.size.x, width))
		dir = Vector2.RIGHT if forward else Vector2.LEFT
		origin = Vector2(arena.position.x - width if forward else arena.end.x + width, y)
	else:
		var x := clampf(player_pos.x + rng.randf_range(-160.0, 160.0), arena.position.x + width * 0.5, arena.end.x - width * 0.5)
		lane_rect = Rect2(Vector2(x - width * 0.5, arena.position.y), Vector2(width, arena.size.y))
		dir = Vector2.DOWN if forward else Vector2.UP
		origin = Vector2(x, arena.position.y - width if forward else arena.end.y + width)
	var hits := _song_apply_sweep_damage(lane_rect, origin, SONG_AUDIENCE_CALL_WAVE_DAMAGE, SONG_AUDIENCE_CALL_WAVE_KNOCKBACK, "song_audience_call_wave")
	song_live_heat_fx.append({
		"kind": "audience_call_wave",
		"arena": arena,
		"rect": lane_rect,
		"dir": dir,
		"horizontal": horizontal_lane,
		"width": width,
		"hits": hits,
		"life": SONG_AUDIENCE_CALL_WAVE_DURATION,
		"maxLife": SONG_AUDIENCE_CALL_WAVE_DURATION,
		"color": Color("#8eeaff")
	})
	_play_song_audience_call_wave_se()
	return hits

func _spawn_song_live_heat_wave(kind: String, radius: float, damage: float, knockback: float, color: Color, source: String) -> int:
	var hits := _song_apply_area_damage(player_pos, radius, damage, knockback, source)
	song_live_heat_fx.append({
		"kind": kind,
		"pos": player_pos,
		"radius": radius,
		"hits": hits,
		"life": 0.58,
		"maxLife": 0.58,
		"color": color
	})
	return hits

func _fire_song_note_pickup_extra_shot(origin: Vector2) -> void:
	var target := _song_nearest_enemy(origin, SONG_NOTE_EXTRA_SHOT_RANGE)
	if target.is_empty():
		return
	var target_pos := Vector2(target.get("pos", origin))
	_song_apply_enemy_damage(target, SONG_NOTE_EXTRA_SHOT_DAMAGE, origin, 20.0, "song_note_extra_shot")
	song_live_heat_fx.append({
		"kind": "penlight_shot",
		"from": origin,
		"to": target_pos,
		"life": 0.18,
		"maxLife": 0.18,
		"color": Color("#ffe177")
	})

func _song_live_heat_note_heal(amount: int) -> void:
	if amount <= 0 or player_hp >= player_max_hp:
		return
	player_hp = mini(player_max_hp, player_hp + amount)
	hit_fx.append({
		"kind": "pickup_text",
		"pos": player_pos + Vector2(-24.0, -54.0),
		"vel": Vector2(0.0, -48.0),
		"life": 0.64,
		"maxLife": 0.64,
		"text": "+%d" % amount,
		"color": Color("#ff5cad")
	})

func _song_apply_area_damage(center: Vector2, radius: float, damage: float, knockback: float, source: String) -> int:
	var hits := 0
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if _song_enemy_inactive(enemy):
			continue
		var enemy_pos := Vector2(enemy.get("pos", Vector2.ZERO))
		var enemy_radius := maxf(12.0, float(enemy.get("radius", 24.0)))
		var hit_radius := radius + enemy_radius * 0.65
		if enemy_pos.distance_squared_to(center) > hit_radius * hit_radius:
			continue
		if _song_apply_enemy_damage(enemy, damage, center, knockback, source):
			hits += 1
	return hits

func _song_apply_sweep_damage(rect: Rect2, origin: Vector2, damage: float, knockback: float, source: String) -> int:
	var hits := 0
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if _song_enemy_inactive(enemy):
			continue
		var enemy_pos := Vector2(enemy.get("pos", Vector2.ZERO))
		var enemy_radius := maxf(12.0, float(enemy.get("radius", 24.0)))
		if not rect.grow(enemy_radius * 0.65).has_point(enemy_pos):
			continue
		if _song_apply_enemy_damage(enemy, damage, origin, knockback, source):
			hits += 1
	return hits

func _song_nearest_enemy(origin: Vector2, range: float) -> Dictionary:
	var best: Dictionary = {}
	var best_dist_sq := range * range
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if _song_enemy_inactive(enemy):
			continue
		var dist_sq := Vector2(enemy.get("pos", Vector2.ZERO)).distance_squared_to(origin)
		if dist_sq >= best_dist_sq:
			continue
		best = enemy
		best_dist_sq = dist_sq
	return best

func _song_enemy_inactive(enemy: Dictionary) -> bool:
	return float(enemy.get("hp", 0.0)) <= 0.0 or bool(enemy.get("defeatPending", false)) or bool(enemy.get("defeatResolved", false))

func _song_apply_enemy_damage(enemy: Dictionary, damage: float, origin: Vector2, knockback: float, source: String) -> bool:
	if _song_enemy_inactive(enemy):
		return false
	var enemy_pos := Vector2(enemy.get("pos", Vector2.ZERO))
	var applied_damage := damage * maxf(0.05, float(enemy.get("damageTakenRate", 1.0)))
	enemy["hp"] = float(enemy.get("hp", 0.0)) - applied_damage
	enemy["lastHitSource"] = source
	var flash_duration := maxf(0.08, float(enemy.get("hitFlashDuration", 0.10)))
	enemy["hitFlashDuration"] = flash_duration
	enemy["hitFlashTimer"] = flash_duration
	hit_fx.append({
		"kind": "damage_number",
		"pos": enemy_pos + Vector2(rng.randf_range(-8.0, 8.0), -22.0 + rng.randf_range(-5.0, 3.0)),
		"vel": Vector2(rng.randf_range(-14.0, 14.0), -52.0),
		"life": 0.44,
		"maxLife": 0.44,
		"damage": applied_damage
	})
	var defeated := float(enemy.get("hp", 0.0)) <= 0.0
	if defeated:
		enemy["defeatSource"] = source
		EnemySystemScript.queue_defeat_for_enemy(enemy)
	var knockback_offset := enemy_pos - origin
	if knockback_offset.length_squared() > 0.01 and knockback > 0.0:
		var knockback_rate := 1.0
		if bool(enemy.get("isBoss", false)) or String(enemy.get("kind", "")).begins_with("boss_"):
			knockback_rate = 0.12
		EnemySystemScript.add_knockback_for_enemy(enemy, knockback_offset.normalized(), knockback * knockback_rate)
	return true

func _add_drawing_progress(amount: float, _source: String = "", pos: Vector2 = Vector2.INF) -> void:
	if amount <= 0.0 or not _is_drawing_frame():
		return
	var before := drawing_progress
	drawing_progress = clampf(drawing_progress + amount, 0.0, 100.0)
	if pos != Vector2.INF and drawing_progress > before:
		hit_fx.append({
			"kind": "pickup_text",
			"pos": pos,
			"vel": Vector2(0.0, -34.0),
			"life": 0.50,
			"maxLife": 0.50,
			"text": "+%.1f%%" % amount,
			"color": Color("#ff8fc8")
		})
	if before < 100.0 and drawing_progress >= 100.0:
		_complete_drawing_illustration()

func _add_drawing_progress_from_enemy_defeat(enemy: Dictionary) -> void:
	var max_hp := float(enemy.get("max_hp", enemy.get("maxHp", enemy.get("hp", 0.0))))
	var radius := float(enemy.get("radius", 22.0))
	var gain := DRAWING_PROGRESS_ENEMY_SMALL_GAIN
	if max_hp >= 28.0 or radius >= 30.0:
		gain = DRAWING_PROGRESS_ENEMY_LARGE_GAIN
	elif max_hp >= 15.0 or radius >= 24.0:
		gain = DRAWING_PROGRESS_ENEMY_MEDIUM_GAIN
	_add_drawing_progress(gain, "enemy_defeat", Vector2(enemy.get("pos", player_pos)) + Vector2(-18.0, -24.0))

func _complete_drawing_illustration() -> void:
	if drawing_complete_reward_claimed:
		return
	drawing_complete_reward_claimed = true
	score += DRAWING_COMPLETE_VIEWER_REWARD
	gift_hype = clampi(gift_hype + DRAWING_COMPLETE_GIFT_HYPE_REWARD, 0, 100)
	max_gift_hype = maxi(max_gift_hype, gift_hype)
	_show_drawing_toast("イラスト完成！", "視聴者 +%d / ギフト +%d" % [DRAWING_COMPLETE_VIEWER_REWARD, DRAWING_COMPLETE_GIFT_HYPE_REWARD])
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": ["+ イラスト完成！", "888888", "> サムネいける", "+ 視聴者が増えた！"]}, chat_box)
	hit_fx.append({
		"kind": "pickup_text",
		"pos": player_pos + Vector2(-64.0, -96.0),
		"vel": Vector2(0.0, -52.0),
		"life": 0.95,
		"maxLife": 0.95,
		"text": "COMPLETE!",
		"color": Color("#ff5cad")
	})
	_play_exp_pickup_se()

func _reset_drawing_stage_state() -> void:
	drawing_paint_orbs.clear()
	drawing_paint_trails.clear()
	drawing_paint_regions.clear()
	drawing_correction_points.clear()
	drawing_erasers.clear()
	drawing_focus_spots.clear()
	drawing_active_paint_color = ""
	drawing_active_paint_timer = 0.0
	drawing_orb_spawn_timer = 1.8
	drawing_correction_spawn_timer = 8.0
	drawing_eraser_spawn_timer = 15.0
	drawing_focus_spawn_timer = 6.0
	drawing_trail_stamp_timer = 0.0
	drawing_last_trail_stamp_pos = Vector2.ZERO
	drawing_has_last_trail_stamp = false
	drawing_focus_inside_last_frame = false
	drawing_next_region_id = 1
	drawing_progress = 0.0
	drawing_complete_reward_claimed = false
	drawing_fill_count = 0
	drawing_correction_complete_count = 0
	drawing_eraser_used_count = 0
	drawing_filled_cell_keys.clear()
	drawing_toast_timer = 0.0
	drawing_toast_title = ""
	drawing_toast_subtitle = ""

func _update_drawing_stage(delta: float, arena: Rect2) -> void:
	if not _is_drawing_frame():
		if not drawing_paint_orbs.is_empty() or not drawing_paint_trails.is_empty() or not drawing_paint_regions.is_empty() or not drawing_focus_spots.is_empty():
			_reset_drawing_stage_state()
		return
	drawing_toast_timer = maxf(0.0, drawing_toast_timer - delta)
	_update_drawing_focus_spots(delta, arena)
	if drawing_active_paint_timer > 0.0:
		drawing_active_paint_timer = maxf(0.0, drawing_active_paint_timer - delta)
		if drawing_active_paint_timer <= 0.0:
			drawing_active_paint_color = ""
			drawing_has_last_trail_stamp = false
	_update_drawing_regions(delta, arena)
	_update_drawing_paint_orbs(delta, arena)
	_update_drawing_correction_points(delta, arena)
	_update_drawing_erasers(delta, arena)
	if drawing_active_paint_color != "":
		_update_drawing_trail(delta, arena)
	else:
		drawing_has_last_trail_stamp = false

func _update_drawing_focus_spots(delta: float, arena: Rect2) -> void:
	for i in range(drawing_focus_spots.size() - 1, -1, -1):
		var spot: Dictionary = drawing_focus_spots[i] as Dictionary
		spot["time"] = float(spot.get("time", 0.0)) - delta
		if float(spot["time"]) <= 0.0:
			drawing_focus_spots.remove_at(i)
		else:
			drawing_focus_spots[i] = spot
	drawing_focus_spawn_timer -= delta
	if drawing_focus_spawn_timer <= 0.0:
		if drawing_focus_spots.size() < 2:
			_spawn_drawing_focus_spot(arena)
		drawing_focus_spawn_timer = rng.randf_range(DRAWING_FOCUS_SPOT_INTERVAL_MIN, DRAWING_FOCUS_SPOT_INTERVAL_MAX)
	var inside := false
	for spot_value in drawing_focus_spots:
		var spot: Dictionary = spot_value as Dictionary
		var pos := Vector2(spot.get("pos", Vector2.ZERO))
		var radius := float(spot.get("radius", DRAWING_FOCUS_SPOT_RADIUS))
		if pos.distance_squared_to(player_pos) <= radius * radius:
			inside = true
			break
	if inside and not drawing_focus_inside_last_frame:
		_show_drawing_toast("集中作業スポット！", "線幅・修正速度UP")
		chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": ["+ 集中作業スポット！", "> そこ作業しやすそう"]}, chat_box)
	drawing_focus_inside_last_frame = inside

func _spawn_drawing_focus_spot(arena: Rect2) -> void:
	drawing_focus_spots.append({
		"pos": _drawing_event_position(arena, DRAWING_FOCUS_SPOT_RADIUS, DRAWING_FOCUS_SPOT_RADIUS + 42.0),
		"radius": DRAWING_FOCUS_SPOT_RADIUS,
		"time": DRAWING_FOCUS_SPOT_LIFETIME,
		"maxTime": DRAWING_FOCUS_SPOT_LIFETIME,
		"phase": rng.randf_range(0.0, TAU)
	})

func _update_drawing_paint_orbs(delta: float, arena: Rect2) -> void:
	for i in range(drawing_paint_orbs.size() - 1, -1, -1):
		var orb: Dictionary = drawing_paint_orbs[i] as Dictionary
		orb["time"] = float(orb.get("time", 0.0)) - delta
		if float(orb["time"]) <= 0.0:
			drawing_paint_orbs.remove_at(i)
			continue
		var radius := float(orb.get("radius", DRAWING_PAINT_ORB_RADIUS))
		if Vector2(orb.get("pos", Vector2.ZERO)).distance_squared_to(player_pos) <= (radius + 28.0) * (radius + 28.0):
			_collect_drawing_paint_orb(orb)
			drawing_paint_orbs.remove_at(i)
	drawing_orb_spawn_timer -= delta
	if drawing_orb_spawn_timer <= 0.0:
		if drawing_paint_orbs.size() < DRAWING_PAINT_ORB_MAX:
			_spawn_drawing_paint_orb(arena)
		drawing_orb_spawn_timer = rng.randf_range(DRAWING_PAINT_ORB_INTERVAL_MIN, DRAWING_PAINT_ORB_INTERVAL_MAX)

func _spawn_drawing_paint_orb(arena: Rect2) -> void:
	var color_id: String = DRAWING_PAINT_COLOR_IDS[rng.randi_range(0, DRAWING_PAINT_COLOR_IDS.size() - 1)]
	drawing_paint_orbs.append({
		"pos": _drawing_event_position(arena, DRAWING_PAINT_ORB_RADIUS, 82.0),
		"colorId": color_id,
		"radius": DRAWING_PAINT_ORB_RADIUS,
		"time": DRAWING_PAINT_ORB_LIFETIME,
		"maxTime": DRAWING_PAINT_ORB_LIFETIME,
		"phase": rng.randf_range(0.0, TAU)
	})

func _collect_drawing_paint_orb(orb: Dictionary) -> void:
	drawing_active_paint_color = String(orb.get("colorId", "pink"))
	drawing_active_paint_timer = DRAWING_PAINT_DURATION
	drawing_has_last_trail_stamp = false
	drawing_trail_stamp_timer = 0.0
	var color_name := _drawing_paint_name(drawing_active_paint_color)
	_show_drawing_toast("%s絵の具GET！" % color_name, "移動すると線を描けます")
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": ["+ %s絵の具を拾った！" % color_name]}, chat_box)
	_play_exp_pickup_se()

func _update_drawing_trail(delta: float, arena: Rect2) -> void:
	drawing_trail_stamp_timer = maxf(0.0, drawing_trail_stamp_timer - delta)
	if drawing_trail_stamp_timer > 0.0:
		return
	var trail_width := _drawing_trail_width()
	if not arena.grow(-24.0).has_point(player_pos):
		drawing_has_last_trail_stamp = false
		return
	if _drawing_position_blocked(player_pos, trail_width * 0.35):
		drawing_has_last_trail_stamp = false
		return
	if drawing_has_last_trail_stamp and player_pos.distance_squared_to(drawing_last_trail_stamp_pos) < DRAWING_TRAIL_MIN_DISTANCE * DRAWING_TRAIL_MIN_DISTANCE:
		return
	drawing_trail_stamp_timer = DRAWING_TRAIL_STAMP_INTERVAL
	var cell := _drawing_world_to_cell(player_pos, arena)
	var cell_key := _drawing_cell_key(cell)
	drawing_paint_trails.append({
		"pos": player_pos,
		"cell": cell,
		"cellKey": cell_key,
		"colorId": drawing_active_paint_color,
		"width": trail_width,
		"time": DRAWING_TRAIL_LIFETIME,
		"maxTime": DRAWING_TRAIL_LIFETIME
	})
	drawing_last_trail_stamp_pos = player_pos
	drawing_has_last_trail_stamp = true
	while drawing_paint_trails.size() > DRAWING_TRAIL_MAX_SAMPLES:
		drawing_paint_trails.remove_at(0)
	_try_drawing_fill_from_trail(cell, drawing_active_paint_color, arena)

func _update_drawing_regions(delta: float, arena: Rect2) -> void:
	for i in range(drawing_paint_trails.size() - 1, -1, -1):
		var trail: Dictionary = drawing_paint_trails[i] as Dictionary
		trail["time"] = float(trail.get("time", 0.0)) - delta
		if float(trail["time"]) <= 0.0:
			drawing_paint_trails.remove_at(i)
	for i in range(drawing_paint_regions.size() - 1, -1, -1):
		var region: Dictionary = drawing_paint_regions[i] as Dictionary
		region["time"] = float(region.get("time", 0.0)) - delta
		region["tick"] = float(region.get("tick", 0.0)) - delta
		if float(region.get("tick", 0.0)) <= 0.0:
			region["tick"] = DRAWING_REGION_TICK_INTERVAL
			_apply_drawing_region_effect(region, arena)
		if float(region.get("time", 0.0)) <= 0.0:
			drawing_paint_regions.remove_at(i)

func _try_drawing_fill_from_trail(new_cell: Vector2i, color_id: String, arena: Rect2) -> void:
	var boundary: Dictionary = {}
	for trail_item in drawing_paint_trails:
		var trail: Dictionary = trail_item as Dictionary
		if String(trail.get("colorId", "")) != color_id:
			continue
		boundary[String(trail.get("cellKey", ""))] = true
	if boundary.size() < 10:
		return
	var grid := _drawing_grid_size(arena)
	if grid.x < 3 or grid.y < 3:
		return
	var outside: Dictionary = {}
	var queue: Array = []
	for x in range(grid.x):
		_drawing_enqueue_flood_cell(Vector2i(x, 0), boundary, outside, queue, grid)
		_drawing_enqueue_flood_cell(Vector2i(x, grid.y - 1), boundary, outside, queue, grid)
	for y in range(grid.y):
		_drawing_enqueue_flood_cell(Vector2i(0, y), boundary, outside, queue, grid)
		_drawing_enqueue_flood_cell(Vector2i(grid.x - 1, y), boundary, outside, queue, grid)
	var head := 0
	while head < queue.size():
		var cell: Vector2i = queue[head] as Vector2i
		head += 1
		_drawing_enqueue_flood_cell(cell + Vector2i(1, 0), boundary, outside, queue, grid)
		_drawing_enqueue_flood_cell(cell + Vector2i(-1, 0), boundary, outside, queue, grid)
		_drawing_enqueue_flood_cell(cell + Vector2i(0, 1), boundary, outside, queue, grid)
		_drawing_enqueue_flood_cell(cell + Vector2i(0, -1), boundary, outside, queue, grid)
	var candidates: Array = []
	for y in range(1, grid.y - 1):
		for x in range(1, grid.x - 1):
			var cell := Vector2i(x, y)
			var key := _drawing_cell_key(cell)
			if boundary.has(key) or outside.has(key) or drawing_filled_cell_keys.has(key):
				continue
			if _drawing_cell_blocked(cell, arena):
				continue
			candidates.append(cell)
	if candidates.is_empty():
		return
	var candidate_set: Dictionary = {}
	for cell_value in candidates:
		candidate_set[_drawing_cell_key(cell_value as Vector2i)] = true
	var visited: Dictionary = {}
	var best_component: Array = []
	var best_distance_sq := INF
	for cell_value in candidates:
		var start_cell: Vector2i = cell_value as Vector2i
		var start_key := _drawing_cell_key(start_cell)
		if visited.has(start_key):
			continue
		var component := _drawing_collect_component(start_cell, candidate_set, visited, grid)
		var size := component.size()
		if size < DRAWING_MIN_FILL_CELLS or size > DRAWING_MAX_FILL_CELLS:
			continue
		var dist_sq := _drawing_component_distance_sq(component, new_cell)
		if best_component.is_empty() or dist_sq < best_distance_sq:
			best_component = component
			best_distance_sq = dist_sq
	if best_component.is_empty():
		return
	_create_drawing_region(best_component, color_id, arena)

func _drawing_enqueue_flood_cell(cell: Vector2i, boundary: Dictionary, outside: Dictionary, queue: Array, grid: Vector2i) -> void:
	if cell.x < 0 or cell.y < 0 or cell.x >= grid.x or cell.y >= grid.y:
		return
	var key := _drawing_cell_key(cell)
	if boundary.has(key) or outside.has(key):
		return
	outside[key] = true
	queue.append(cell)

func _drawing_collect_component(start_cell: Vector2i, candidate_set: Dictionary, visited: Dictionary, grid: Vector2i) -> Array:
	var component: Array = []
	var queue: Array = [start_cell]
	visited[_drawing_cell_key(start_cell)] = true
	var head := 0
	while head < queue.size():
		var cell: Vector2i = queue[head] as Vector2i
		head += 1
		component.append(cell)
		for offset in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var next_cell: Vector2i = cell + offset
			if next_cell.x < 0 or next_cell.y < 0 or next_cell.x >= grid.x or next_cell.y >= grid.y:
				continue
			var key := _drawing_cell_key(next_cell)
			if visited.has(key) or not candidate_set.has(key):
				continue
			visited[key] = true
			queue.append(next_cell)
	return component

func _drawing_component_distance_sq(component: Array, target_cell: Vector2i) -> float:
	var best := INF
	for cell_value in component:
		var cell: Vector2i = cell_value as Vector2i
		var dist := Vector2(float(cell.x - target_cell.x), float(cell.y - target_cell.y)).length_squared()
		best = minf(best, dist)
	return best

func _create_drawing_region(cells: Array, color_id: String, arena: Rect2) -> void:
	var cell_keys: Dictionary = {}
	var center := Vector2.ZERO
	for cell_value in cells:
		var cell: Vector2i = cell_value as Vector2i
		var key := _drawing_cell_key(cell)
		cell_keys[key] = true
		drawing_filled_cell_keys[key] = true
		center += _drawing_cell_center(cell, arena)
	if cells.size() > 0:
		center /= float(cells.size())
	drawing_paint_regions.append({
		"id": drawing_next_region_id,
		"colorId": color_id,
		"cells": cells.duplicate(),
		"cellKeys": cell_keys,
		"center": center,
		"time": DRAWING_REGION_LIFETIME,
		"maxTime": DRAWING_REGION_LIFETIME,
		"tick": 0.05
	})
	drawing_next_region_id += 1
	while drawing_paint_regions.size() > DRAWING_MAX_ACTIVE_REGIONS:
		drawing_paint_regions.remove_at(0)
	var fill_score := cells.size()
	drawing_fill_count += 1
	var progress_gain := DRAWING_PROGRESS_FILL_GAIN
	if fill_score >= DRAWING_PROGRESS_LARGE_FILL_MIN_CELLS:
		progress_gain += DRAWING_PROGRESS_LARGE_FILL_BONUS
	var hits := _apply_drawing_region_effect(drawing_paint_regions[drawing_paint_regions.size() - 1] as Dictionary, arena)
	_complete_drawing_corrections_in_region(cell_keys)
	_show_drawing_toast("囲い塗り成功！", "%sエリア %dマス / 敵%d体に効果" % [_drawing_paint_name(color_id), fill_score, hits])
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": ["+ 囲い塗り成功！", "> 塗り範囲できてる"]}, chat_box)
	hit_fx.append({
		"kind": "pickup_text",
		"pos": center,
		"vel": Vector2(0.0, -44.0),
		"life": 0.72,
		"maxLife": 0.72,
		"text": "PAINT!",
		"color": _drawing_paint_color(color_id)
	})
	_add_drawing_progress(progress_gain, "paint_fill", center)

func _apply_drawing_region_effect(region: Dictionary, arena: Rect2) -> int:
	var hits := 0
	var color_id := String(region.get("colorId", "pink"))
	var cell_keys: Dictionary = region.get("cellKeys", {}) as Dictionary
	if cell_keys.is_empty():
		return 0
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if _song_enemy_inactive(enemy):
			continue
		var enemy_pos := Vector2(enemy.get("pos", Vector2.ZERO))
		var cell := _drawing_world_to_cell(enemy_pos, arena)
		if not cell_keys.has(_drawing_cell_key(cell)):
			continue
		if color_id == "pink":
			if _song_apply_enemy_damage(enemy, DRAWING_PINK_DAMAGE_PER_TICK, Vector2(region.get("center", enemy_pos)), DRAWING_REGION_KNOCKBACK, "drawing_pink_region"):
				hits += 1
		else:
			enemy["slowTimer"] = maxf(float(enemy.get("slowTimer", 0.0)), DRAWING_CYAN_SLOW_TIMER)
			enemy["slowRate"] = maxf(float(enemy.get("slowRate", 0.0)), DRAWING_CYAN_SLOW_RATE)
			hits += 1
	return hits

func _update_drawing_correction_points(delta: float, arena: Rect2) -> void:
	for i in range(drawing_correction_points.size() - 1, -1, -1):
		var point: Dictionary = drawing_correction_points[i] as Dictionary
		point["time"] = float(point.get("time", 0.0)) - delta
		if float(point["time"]) <= 0.0:
			drawing_correction_points.remove_at(i)
			continue
		if drawing_active_paint_color != "":
			var point_pos := Vector2(point.get("pos", Vector2.ZERO))
			var radius := float(point.get("radius", DRAWING_CORRECTION_RADIUS)) + _drawing_trail_width() * 0.42
			if point_pos.distance_squared_to(player_pos) <= radius * radius:
				point["paintTime"] = float(point.get("paintTime", 0.0)) + delta * _drawing_correction_speed_multiplier()
				if float(point["paintTime"]) >= DRAWING_CORRECTION_DIRECT_PAINT_TIME:
					_complete_drawing_correction_at(i)
					continue
			else:
				point["paintTime"] = maxf(0.0, float(point.get("paintTime", 0.0)) - delta * 0.65)
	drawing_correction_spawn_timer -= delta
	if drawing_correction_spawn_timer <= 0.0:
		if drawing_correction_points.size() < DRAWING_CORRECTION_MAX:
			_spawn_drawing_correction_point(arena)
		drawing_correction_spawn_timer = rng.randf_range(DRAWING_CORRECTION_INTERVAL_MIN, DRAWING_CORRECTION_INTERVAL_MAX)

func _spawn_drawing_correction_point(arena: Rect2) -> void:
	drawing_correction_points.append({
		"pos": _drawing_event_position(arena, DRAWING_CORRECTION_RADIUS, 120.0),
		"radius": DRAWING_CORRECTION_RADIUS,
		"time": DRAWING_CORRECTION_LIFETIME,
		"maxTime": DRAWING_CORRECTION_LIFETIME,
		"paintTime": 0.0,
		"phase": rng.randf_range(0.0, TAU)
	})

func _complete_drawing_corrections_in_region(cell_keys: Dictionary) -> void:
	for i in range(drawing_correction_points.size() - 1, -1, -1):
		var point: Dictionary = drawing_correction_points[i] as Dictionary
		var cell := _drawing_world_to_cell(Vector2(point.get("pos", Vector2.ZERO)), _current_arena())
		if not cell_keys.has(_drawing_cell_key(cell)):
			continue
		_complete_drawing_correction_at(i)

func _complete_drawing_correction_at(index: int) -> void:
	if index < 0 or index >= drawing_correction_points.size():
		return
	var point: Dictionary = drawing_correction_points[index] as Dictionary
	var pos := Vector2(point.get("pos", Vector2.ZERO))
	drawing_correction_points.remove_at(index)
	drawing_correction_complete_count += 1
	score += DRAWING_CORRECTION_VIEWER_GAIN
	gift_hype = clampi(gift_hype + DRAWING_CORRECTION_GIFT_HYPE_GAIN, 0, 100)
	max_gift_hype = maxi(max_gift_hype, gift_hype)
	if rng.randf() < DRAWING_CORRECTION_SPAWN_PAINT_ORB_CHANCE and drawing_paint_orbs.size() < DRAWING_PAINT_ORB_MAX:
		_spawn_drawing_paint_orb(_current_arena())
	if rng.randf() < DRAWING_CORRECTION_HEAL_MENTAL_CHANCE:
		_song_live_heat_note_heal(DRAWING_CORRECTION_HEAL_AMOUNT)
	_show_drawing_toast("修正ポイント完了！", "進捗 +%d%% / 視聴者 +%d / ギフト +%d" % [
		roundi(DRAWING_PROGRESS_CORRECTION_GAIN),
		DRAWING_CORRECTION_VIEWER_GAIN,
		DRAWING_CORRECTION_GIFT_HYPE_GAIN
	])
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": ["+ 修正対応完了！", "> そこ直したの助かる"]}, chat_box)
	hit_fx.append({
		"kind": "pickup_text",
		"pos": pos,
		"vel": Vector2(0.0, -48.0),
		"life": 0.62,
		"maxLife": 0.62,
		"text": "FIX!",
		"color": Color("#ff6aa5")
	})
	_add_drawing_progress(DRAWING_PROGRESS_CORRECTION_GAIN, "correction", pos)

func _update_drawing_erasers(delta: float, arena: Rect2) -> void:
	for i in range(drawing_erasers.size() - 1, -1, -1):
		var eraser: Dictionary = drawing_erasers[i] as Dictionary
		eraser["time"] = float(eraser.get("time", 0.0)) - delta
		if float(eraser["time"]) <= 0.0:
			drawing_erasers.remove_at(i)
			continue
		var pos := Vector2(eraser.get("pos", Vector2.ZERO))
		if pos.distance_squared_to(player_pos) <= 54.0 * 54.0:
			_collect_drawing_eraser(pos)
			drawing_erasers.remove_at(i)
	drawing_eraser_spawn_timer -= delta
	if drawing_eraser_spawn_timer <= 0.0:
		_spawn_drawing_eraser(arena)
		drawing_eraser_spawn_timer = rng.randf_range(DRAWING_ERASER_INTERVAL_MIN, DRAWING_ERASER_INTERVAL_MAX)

func _spawn_drawing_eraser(arena: Rect2) -> void:
	drawing_erasers.append({
		"pos": _drawing_event_position(arena, 32.0, 90.0),
		"time": DRAWING_ERASER_LIFETIME,
		"maxTime": DRAWING_ERASER_LIFETIME,
		"phase": rng.randf_range(0.0, TAU)
	})

func _collect_drawing_eraser(pos: Vector2) -> void:
	drawing_eraser_used_count += 1
	var eraser_radius := _drawing_eraser_radius()
	var removed_bullets := 0
	for i in range(enemy_bullets.size() - 1, -1, -1):
		var bullet: Dictionary = enemy_bullets[i] as Dictionary
		if Vector2(bullet.get("pos", Vector2.ZERO)).distance_squared_to(pos) <= eraser_radius * eraser_radius:
			enemy_bullets.remove_at(i)
			removed_bullets += 1
	var hits := _song_apply_area_damage(pos, eraser_radius, DRAWING_ERASER_DAMAGE, DRAWING_ERASER_KNOCKBACK, "drawing_eraser")
	var progress_gain := DRAWING_PROGRESS_ERASER_GAIN if removed_bullets > 0 or hits > 0 else 0.0
	_show_drawing_toast("消しゴム発動！", "敵弾%d個消去 / 敵%d体に効果" % [removed_bullets, hits])
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": ["+ 消しゴム助かる", "> 画面が少しきれいになった"]}, chat_box)
	hit_fx.append({
		"kind": "pickup_text",
		"pos": pos,
		"vel": Vector2(0.0, -50.0),
		"life": 0.62,
		"maxLife": 0.62,
		"text": "ERASE",
		"color": Color("#7ce8ff")
	})
	_add_drawing_progress(progress_gain, "eraser", pos)
	_play_marshmallow_pickup_se()

func _drawing_event_position(arena: Rect2, radius: float, obstacle_clearance: float = 80.0) -> Vector2:
	var rect := arena.grow(-(radius + 38.0))
	for i in range(58):
		var pos := Vector2(rng.randf_range(rect.position.x, rect.end.x), rng.randf_range(rect.position.y, rect.end.y))
		if pos.distance_squared_to(player_pos) < 150.0 * 150.0:
			continue
		if _drawing_position_blocked(pos, maxf(radius, obstacle_clearance)):
			continue
		return pos
	for i in range(28):
		var fallback := arena.get_center() + Vector2(rng.randf_range(-360.0, 360.0), rng.randf_range(-230.0, 230.0))
		if rect.has_point(fallback) and not _drawing_position_blocked(fallback, radius):
			return fallback
	return arena.get_center()

func _drawing_position_blocked(pos: Vector2, radius: float) -> bool:
	var walls := EnemySystemScript.movement_wall_rects(effect_walls, current_stream_frame_id)
	for wall_value in walls:
		var wall: Rect2 = wall_value as Rect2
		if wall.grow(radius + 12.0).has_point(pos):
			return true
	for rect_value in MapBackgroundSystemScript.prop_collision_rects_for_data(_current_map_data()):
		var rect: Rect2 = rect_value as Rect2
		if rect.grow(radius).has_point(pos):
			return true
	return false

func _drawing_world_to_cell(pos: Vector2, arena: Rect2) -> Vector2i:
	return Vector2i(
		int(floor((pos.x - arena.position.x) / DRAWING_CELL_SIZE)),
		int(floor((pos.y - arena.position.y) / DRAWING_CELL_SIZE))
	)

func _drawing_cell_center(cell: Vector2i, arena: Rect2) -> Vector2:
	return arena.position + Vector2((float(cell.x) + 0.5) * DRAWING_CELL_SIZE, (float(cell.y) + 0.5) * DRAWING_CELL_SIZE)

func _drawing_cell_key(cell: Vector2i) -> String:
	return "%d:%d" % [cell.x, cell.y]

func _drawing_grid_size(arena: Rect2) -> Vector2i:
	return Vector2i(int(ceil(arena.size.x / DRAWING_CELL_SIZE)), int(ceil(arena.size.y / DRAWING_CELL_SIZE)))

func _drawing_cell_blocked(cell: Vector2i, arena: Rect2) -> bool:
	var center := _drawing_cell_center(cell, arena)
	if not arena.has_point(center):
		return true
	return _drawing_position_blocked(center, DRAWING_CELL_SIZE * 0.35)

func _show_drawing_toast(title: String, subtitle: String) -> void:
	drawing_toast_title = title
	drawing_toast_subtitle = subtitle
	drawing_toast_timer = DRAWING_TOAST_DURATION

func _drawing_paint_name(color_id: String) -> String:
	if color_id == "cyan":
		return "水色"
	return "ピンク"

func _drawing_paint_effect_name(color_id: String) -> String:
	if color_id == "cyan":
		return "敵スロー"
	return "敵ダメージ"

func _drawing_paint_color(color_id: String) -> Color:
	if color_id == "cyan":
		return Color("#57dfff")
	return Color("#ff70b9")

func _drawing_paint_soft_color(color_id: String) -> Color:
	if color_id == "cyan":
		return Color(0.35, 0.86, 1.0, 0.25)
	return Color(1.0, 0.45, 0.73, 0.25)

func _draw_drawing_stage_objects(visible_rect: Rect2) -> void:
	if not _is_drawing_frame():
		return
	for spot_value in drawing_focus_spots:
		_draw_drawing_focus_spot(spot_value as Dictionary, visible_rect)
	for region_value in drawing_paint_regions:
		_draw_drawing_paint_region(region_value as Dictionary, visible_rect)
	_draw_drawing_trails(visible_rect)
	for point_value in drawing_correction_points:
		_draw_drawing_correction_point(point_value as Dictionary, visible_rect)
	for eraser_value in drawing_erasers:
		_draw_drawing_eraser(eraser_value as Dictionary, visible_rect)
	for orb_value in drawing_paint_orbs:
		_draw_drawing_paint_orb(orb_value as Dictionary, visible_rect)

func _draw_drawing_focus_spot(spot: Dictionary, visible_rect: Rect2) -> void:
	var pos := Vector2(spot.get("pos", Vector2.ZERO))
	var radius := float(spot.get("radius", DRAWING_FOCUS_SPOT_RADIUS))
	if not visible_rect.grow(radius + 18.0).has_point(pos):
		return
	var life_ratio := clampf(float(spot.get("time", 0.0)) / maxf(0.1, float(spot.get("maxTime", DRAWING_FOCUS_SPOT_LIFETIME))), 0.0, 1.0)
	var phase := float(spot.get("phase", 0.0))
	var occupied := pos.distance_squared_to(player_pos) <= radius * radius
	var pulse := 0.5 + 0.5 * sin(elapsed * 4.2 + phase)
	var base_alpha := (0.20 + pulse * 0.06) * life_ratio
	var ring_color := Color("#67e7ff") if occupied else Color("#ff9ed2")
	draw_circle(pos, radius, Color(ring_color.r, ring_color.g, ring_color.b, base_alpha))
	draw_circle(pos, radius * 0.70, Color(1.0, 1.0, 1.0, 0.05 * life_ratio))
	draw_circle(pos, radius, Color(ring_color.r, ring_color.g, ring_color.b, 0.34 * life_ratio), false, 4.0, true)
	draw_circle(pos, radius * (0.58 + pulse * 0.04), Color(1.0, 1.0, 1.0, 0.14 * life_ratio), false, 2.0, true)
	_draw_outlined_text(pos + Vector2(-54.0, 8.0), "FOCUS", 108, 15, Color("#ffffff"), Color(ring_color.r, ring_color.g, ring_color.b, 0.90), HORIZONTAL_ALIGNMENT_CENTER)

func _draw_drawing_paint_region(region: Dictionary, visible_rect: Rect2) -> void:
	var color_id := String(region.get("colorId", "pink"))
	var time_left := float(region.get("time", 0.0))
	var max_time := maxf(0.1, float(region.get("maxTime", DRAWING_REGION_LIFETIME)))
	var life_ratio := clampf(time_left / max_time, 0.0, 1.0)
	var base_color := _drawing_paint_soft_color(color_id)
	var edge_color := _drawing_paint_color(color_id)
	base_color.a *= 0.42 + life_ratio * 0.55
	edge_color.a = 0.28 + life_ratio * 0.34
	for cell_value in region.get("cells", []):
		var cell: Vector2i = cell_value as Vector2i
		var center := _drawing_cell_center(cell, _current_arena())
		var rect := Rect2(center - Vector2.ONE * DRAWING_CELL_SIZE * 0.5, Vector2.ONE * DRAWING_CELL_SIZE)
		if not rect.intersects(visible_rect):
			continue
		draw_rect(rect.grow(1.0), base_color, true)
		if cell.x % 2 == 0 and cell.y % 2 == 0:
			draw_rect(rect.grow(-5.0), Color(1.0, 1.0, 1.0, 0.06 + 0.06 * life_ratio), true)
	var center_pos := Vector2(region.get("center", Vector2.ZERO))
	if visible_rect.has_point(center_pos):
		draw_circle(center_pos, 22.0 + sin(elapsed * 4.2 + float(region.get("id", 0))) * 2.4, Color(edge_color.r, edge_color.g, edge_color.b, 0.14))
		_draw_outlined_text(center_pos + Vector2(-52.0, 7.0), _drawing_paint_effect_name(color_id), 104, 14, Color("#ffffff"), Color(edge_color.r, edge_color.g, edge_color.b, 0.86), HORIZONTAL_ALIGNMENT_CENTER)

func _draw_drawing_trails(visible_rect: Rect2) -> void:
	var previous_by_color: Dictionary = {}
	for trail_value in drawing_paint_trails:
		var trail: Dictionary = trail_value as Dictionary
		var pos := Vector2(trail.get("pos", Vector2.ZERO))
		var trail_width := float(trail.get("width", _drawing_trail_width()))
		if not visible_rect.grow(trail_width).has_point(pos):
			continue
		var color_id := String(trail.get("colorId", "pink"))
		var time_left := float(trail.get("time", 0.0))
		var max_time := maxf(0.1, float(trail.get("maxTime", DRAWING_TRAIL_LIFETIME)))
		var life_ratio := clampf(time_left / max_time, 0.0, 1.0)
		var color := _drawing_paint_color(color_id)
		if previous_by_color.has(color_id):
			var prev := Vector2(previous_by_color[color_id])
			if prev.distance_squared_to(pos) < 92.0 * 92.0:
				draw_line(prev, pos, Color(color.r, color.g, color.b, 0.28 * life_ratio), trail_width * 0.82, true)
				draw_line(prev, pos, Color(1.0, 1.0, 1.0, 0.10 * life_ratio), trail_width * 0.36, true)
		draw_circle(pos, trail_width * 0.44, Color(color.r, color.g, color.b, 0.28 * life_ratio))
		draw_circle(pos, trail_width * 0.22, Color(1.0, 1.0, 1.0, 0.13 * life_ratio))
		draw_circle(pos, trail_width * 0.45, Color(color.r, color.g, color.b, 0.22 * life_ratio), false, 2.0, true)
		previous_by_color[color_id] = pos

func _draw_drawing_paint_orb(orb: Dictionary, visible_rect: Rect2) -> void:
	var pos := Vector2(orb.get("pos", Vector2.ZERO))
	var radius := float(orb.get("radius", DRAWING_PAINT_ORB_RADIUS))
	if not visible_rect.grow(radius + 32.0).has_point(pos):
		return
	var color_id := String(orb.get("colorId", "pink"))
	var color := _drawing_paint_color(color_id)
	var phase := float(orb.get("phase", 0.0))
	var bob := sin(elapsed * 4.6 + phase) * 3.5
	var center := pos + Vector2(0.0, bob)
	var time_ratio := clampf(float(orb.get("time", 0.0)) / maxf(0.1, float(orb.get("maxTime", DRAWING_PAINT_ORB_LIFETIME))), 0.0, 1.0)
	DrawPrimitiveSystemScript.draw_shadow(self, center + Vector2(0.0, radius * 0.85), Vector2(radius * 1.7, radius * 0.46), 0.16 * time_ratio)
	draw_circle(center, radius + 8.0, Color(color.r, color.g, color.b, 0.18 + 0.10 * sin(elapsed * 5.0 + phase)))
	draw_circle(center, radius, Color(color.r, color.g, color.b, 0.78))
	draw_circle(center - Vector2(radius * 0.22, radius * 0.24), radius * 0.45, Color(1.0, 1.0, 1.0, 0.42))
	draw_circle(center, radius, Color("#ffffff"), false, 3.0, true)
	_draw_outlined_text(center + Vector2(-22.0, 10.0), "絵具", 44, 13, Color("#ffffff"), Color(color.r, color.g, color.b, 0.95), HORIZONTAL_ALIGNMENT_CENTER)

func _draw_drawing_correction_point(point: Dictionary, visible_rect: Rect2) -> void:
	var pos := Vector2(point.get("pos", Vector2.ZERO))
	var radius := float(point.get("radius", DRAWING_CORRECTION_RADIUS))
	if not visible_rect.grow(radius + 28.0).has_point(pos):
		return
	var phase := float(point.get("phase", 0.0))
	var pulse := 0.5 + 0.5 * sin(elapsed * 5.4 + phase)
	var life_ratio := clampf(float(point.get("time", 0.0)) / maxf(0.1, float(point.get("maxTime", DRAWING_CORRECTION_LIFETIME))), 0.0, 1.0)
	draw_circle(pos, radius + pulse * 7.0, Color(1.0, 0.92, 0.45, 0.16 * life_ratio), false, 3.0, true)
	draw_circle(pos, radius * 0.72, Color(1.0, 0.96, 0.56, 0.74 * life_ratio))
	draw_circle(pos, radius * 0.72, Color("#ff80bd"), false, 3.0, true)
	draw_line(pos + Vector2(-radius * 0.42, 0.0), pos + Vector2(radius * 0.42, 0.0), Color("#ffffff"), 4.0, true)
	draw_line(pos + Vector2(0.0, -radius * 0.42), pos + Vector2(0.0, radius * 0.42), Color("#ffffff"), 4.0, true)
	var paint_ratio := clampf(float(point.get("paintTime", 0.0)) / DRAWING_CORRECTION_DIRECT_PAINT_TIME, 0.0, 1.0)
	if paint_ratio > 0.0:
		draw_arc(pos, radius + 10.0, -PI * 0.5, -PI * 0.5 + TAU * paint_ratio, 36, Color("#74e7ff"), 4.0, true)
	_draw_outlined_text(pos + Vector2(-34.0, radius + 17.0), "修正", 68, 13, Color("#ffffff"), Color("#d34f8d"), HORIZONTAL_ALIGNMENT_CENTER)

func _draw_drawing_eraser(eraser: Dictionary, visible_rect: Rect2) -> void:
	var pos := Vector2(eraser.get("pos", Vector2.ZERO))
	if not visible_rect.grow(62.0).has_point(pos):
		return
	var phase := float(eraser.get("phase", 0.0))
	var bob := sin(elapsed * 4.0 + phase) * 3.0
	var center := pos + Vector2(0.0, bob)
	var life_ratio := clampf(float(eraser.get("time", 0.0)) / maxf(0.1, float(eraser.get("maxTime", DRAWING_ERASER_LIFETIME))), 0.0, 1.0)
	var body := Rect2(center - Vector2(33.0, 19.0), Vector2(66.0, 38.0))
	DrawPrimitiveSystemScript.draw_shadow(self, center + Vector2(0.0, 31.0), Vector2(76.0, 18.0), 0.15 * life_ratio)
	draw_rect(body.grow(5.0), Color(0.45, 0.92, 1.0, 0.20 * life_ratio), true)
	draw_rect(body, Color("#f7fbff"), true)
	draw_rect(Rect2(body.position, Vector2(body.size.x * 0.42, body.size.y)), Color("#8eeaff"), true)
	draw_rect(body, Color("#58c8ff"), false, 3.0)
	_draw_outlined_text(center + Vector2(-34.0, 35.0), "消しゴム", 68, 12, Color("#ffffff"), Color("#3279b5"), HORIZONTAL_ALIGNMENT_CENTER)

func _draw_drawing_stage_hud() -> void:
	if not _is_drawing_frame():
		return
	if state != "playing" and state != "comment_choice" and state != "gift_choice":
		return
	var rect := Rect2(FIELD_VIEW.position + Vector2(18.0, 18.0), Vector2(294.0, 92.0))
	DrawPrimitiveSystemScript.draw_shadow(self, rect.get_center() + Vector2(0.0, 7.0), rect.size + Vector2(18.0, 10.0), 0.13)
	draw_rect(rect, Color(1.0, 0.98, 1.0, 0.90), true)
	draw_rect(rect, Color("#ff9dcc"), false, 3.0)
	draw_rect(Rect2(rect.position, Vector2(9.0, rect.size.y)), Color("#8eeaff"), true)
	_draw_text_item({"pos": rect.position + Vector2(18.0, 26.0), "text": "DRAWING", "width": 118, "size": 18, "fontWeight": "black", "color": Color("#e94f9a")})
	var active_text := "絵具なし"
	var active_color := Color("#8b7288")
	if drawing_active_paint_color != "":
		active_text = "%s %.1fs" % [_drawing_paint_name(drawing_active_paint_color), drawing_active_paint_timer]
		active_color = _drawing_paint_color(drawing_active_paint_color)
	_draw_text_item({"pos": rect.position + Vector2(144.0, 28.0), "text": active_text, "width": 132, "size": 16, "fontWeight": "bold", "color": active_color}, "", HORIZONTAL_ALIGNMENT_RIGHT)
	var bar := Rect2(rect.position + Vector2(22.0, 52.0), Vector2(rect.size.x - 44.0, 14.0))
	draw_rect(bar, Color("#fff0f8"), true)
	var progress_ratio := clampf(drawing_progress / 100.0, 0.0, 1.0)
	var fill_rect := Rect2(bar.position, Vector2(bar.size.x * progress_ratio, bar.size.y))
	if fill_rect.size.x > 0.0:
		draw_rect(fill_rect, Color("#ff7ec5"), true)
		draw_rect(Rect2(fill_rect.position, Vector2(fill_rect.size.x, fill_rect.size.y * 0.42)), Color(1.0, 1.0, 1.0, 0.22), true)
	draw_rect(bar, Color("#ffb7dc"), false, 2.0)
	_draw_text_item({"pos": rect.position + Vector2(20.0, 82.0), "text": "制作進捗 %d%%" % roundi(drawing_progress), "width": 132, "size": 12, "fontWeight": "bold", "color": Color("#6d5870")})
	var fill_count := drawing_fill_count
	_draw_text_item({"pos": rect.position + Vector2(152.0, 82.0), "text": "塗りエリア %d" % fill_count, "width": 122, "size": 12, "fontWeight": "bold", "color": Color("#6d5870")}, "", HORIZONTAL_ALIGNMENT_RIGHT)

func _draw_drawing_stage_toast() -> void:
	if drawing_toast_timer <= 0.0 or drawing_toast_title == "":
		return
	var progress := 1.0 - clampf(drawing_toast_timer / DRAWING_TOAST_DURATION, 0.0, 1.0)
	var alpha := smoothstep(0.0, 0.16, progress) * (1.0 - smoothstep(0.78, 1.0, progress))
	var rect := Rect2(Vector2(FIELD_VIEW.position.x + FIELD_VIEW.size.x * 0.5 - 185.0, FIELD_VIEW.position.y + 18.0), Vector2(370.0, 74.0))
	DrawPrimitiveSystemScript.draw_shadow(self, rect.get_center() + Vector2(0.0, 7.0), rect.size + Vector2(20.0, 12.0), 0.13 * alpha)
	draw_rect(rect, Color(1.0, 1.0, 1.0, 0.90 * alpha), true)
	draw_rect(Rect2(rect.position, Vector2(8.0, rect.size.y)), Color(0.55, 0.90, 1.0, 0.78 * alpha), true)
	draw_rect(rect, Color(1.0, 0.50, 0.78, 0.64 * alpha), false, 2.0)
	_draw_text_item({"pos": rect.position + Vector2(24.0, 30.0), "text": drawing_toast_title, "width": int(rect.size.x - 48.0), "size": 18, "fontWeight": "black", "color": Color("#e94393", alpha)}, "", HORIZONTAL_ALIGNMENT_LEFT)
	_draw_text_item({"pos": rect.position + Vector2(24.0, 56.0), "text": drawing_toast_subtitle, "width": int(rect.size.x - 48.0), "size": 13, "fontWeight": "bold", "color": Color("#6f5972", alpha)}, "", HORIZONTAL_ALIGNMENT_LEFT)

func _draw_song_chorus_objects(visible_rect: Rect2) -> void:
	if not _is_song_frame():
		return
	_draw_song_live_heat_player_aura()
	_draw_song_pitch_waves()
	_draw_song_boss_megaphone_waves()
	_draw_song_bad_lights()
	_draw_song_bad_light_player_glare()
	_draw_song_howling_effects()
	_draw_song_live_heat_fx()
	_draw_song_stage_obstacles(visible_rect)
	for item in song_spotlights:
		var spotlight: Dictionary = item as Dictionary
		if not visible_rect.has_point(Vector2(spotlight.get("pos", Vector2.ZERO))):
			continue
		_draw_song_spotlight(spotlight)
	_draw_song_penlight_bits()
	for item in song_notes:
		var note: Dictionary = item as Dictionary
		if not visible_rect.has_point(Vector2(note.get("pos", Vector2.ZERO))):
			continue
		_draw_song_note(note)
	for item in song_lyrics_cards:
		var card: Dictionary = item as Dictionary
		if not visible_rect.has_point(Vector2(card.get("pos", Vector2.ZERO))):
			continue
		_draw_song_lyrics_card(card)

func _draw_song_stage_obstacles(visible_rect: Rect2) -> void:
	var obstacle_items := MapBackgroundSystemScript.obstacle_draw_items_for_data(_current_map_data())
	for item in obstacle_items:
		var obstacle: Dictionary = item as Dictionary
		var center: Vector2 = obstacle.get("center", Vector2.ZERO) as Vector2
		var size: Vector2 = obstacle.get("size", Vector2(128.0, 128.0)) as Vector2
		var draw_rect := Rect2(center - size * 0.5, size)
		if not visible_rect.intersects(draw_rect.grow(48.0)):
			continue
		var shadow_offset: Vector2 = obstacle.get("shadowOffset", Vector2(0.0, size.y * 0.30)) as Vector2
		var shadow_size: Vector2 = obstacle.get("shadowSize", Vector2(size.x * 0.58, size.y * 0.13)) as Vector2
		_draw_shadow(center + shadow_offset, shadow_size, 0.18)
		var texture_path := String(obstacle.get("texturePath", ""))
		var texture: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, texture_path)
		if texture != null:
			draw_texture_rect(texture, draw_rect, false, Color(1.0, 1.0, 1.0, 0.99))
		else:
			draw_rect(draw_rect.grow(-24.0), Color(0.14, 0.12, 0.18, 0.90))
			draw_rect(draw_rect.grow(-24.0), Color(0.95, 0.70, 0.95, 0.72), false, 3.0)

func _draw_song_live_heat_player_aura() -> void:
	if song_live_heat_level < 4:
		return
	var pulse := 0.5 + 0.5 * sin(elapsed * 5.4)
	var radius := 78.0 if song_live_heat_level >= 5 else 62.0
	draw_circle(player_pos, radius + 15.0 + pulse * 8.0, Color(1.0, 0.62, 0.90, 0.18))
	draw_circle(player_pos, radius + 6.0 + pulse * 4.0, Color(0.45, 0.88, 1.0, 0.12))
	draw_circle(player_pos, radius * 0.70, Color(1.0, 1.0, 1.0, 0.10))
	draw_circle(player_pos, radius + 2.0, Color(1.0, 1.0, 1.0, 0.62), false, 5.0)
	draw_circle(player_pos, radius, Color("#ff5cad"), false, 4.0)
	draw_circle(player_pos, radius * 0.56, Color("#20c8ff"), false, 3.0)
	if song_live_heat_level >= 5:
		for i in range(10):
			var angle := -elapsed * 1.7 + float(i) * TAU / 10.0
			var spark := player_pos + Vector2(cos(angle), sin(angle)) * (radius + 10.0 + pulse * 5.0)
			var color := Color("#ff8fc8") if i % 2 == 0 else Color("#8eeaff")
			DrawPrimitiveSystemScript.draw_spark(self, spark, 6.0 + pulse * 3.0, Color(color.r, color.g, color.b, 0.82))

func _draw_song_penlight_bits() -> void:
	if song_live_heat_level < 2:
		return
	for i in range(SONG_PENLIGHT_BIT_COUNT):
		var pos := _song_penlight_bit_position(i)
		var color := Color("#8eeaff") if i % 2 == 0 else Color("#ff8fc8")
		var texture_path := String(SONG_PENLIGHT_BIT_IMAGES[i % SONG_PENLIGHT_BIT_IMAGES.size()])
		var texture: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, texture_path)
		if texture != null:
			var pulse := 0.5 + 0.5 * sin(elapsed * 6.2 + float(i) * 1.7)
			var image_size := Vector2(62.0, 62.0) * (1.0 + pulse * 0.04)
			if song_live_heat_level >= 5:
				image_size *= 1.08
			_draw_shadow(pos + Vector2(0.0, image_size.y * 0.22), Vector2(image_size.x * 0.42, image_size.y * 0.12), 0.14)
			draw_circle(pos, 24.0 + pulse * 3.0, Color(color.r, color.g, color.b, 0.14))
			_draw_rotated_texture(texture, pos, image_size, sin(elapsed * 2.6 + float(i) * 1.3) * 0.08, 0.98)
			continue
		draw_circle(pos, 24.0, Color(color.r, color.g, color.b, 0.28))
		draw_circle(pos, 15.0, Color(1.0, 1.0, 1.0, 0.94))
		draw_circle(pos, 15.0, Color(0.16, 0.08, 0.26, 0.18), false, 5.0)
		draw_circle(pos, 15.0, Color(color.r, color.g, color.b, 0.90), false, 4.0)
		draw_circle(pos, 5.0, Color(color.r, color.g, color.b, 0.95))
		draw_line(pos + Vector2(-5.0, 7.0), pos + Vector2(8.0, -11.0), Color(0.14, 0.06, 0.22, 0.28), 7.0, true)
		draw_line(pos + Vector2(-5.0, 7.0), pos + Vector2(8.0, -11.0), Color(1.0, 1.0, 1.0, 0.82), 5.0, true)
		draw_line(pos + Vector2(-5.0, 7.0), pos + Vector2(8.0, -11.0), Color(color.r, color.g, color.b, 0.95), 2.8, true)

func _draw_song_live_heat_fx() -> void:
	for item in song_live_heat_fx:
		var fx: Dictionary = item as Dictionary
		var life := float(fx.get("life", 0.0))
		var max_life := maxf(0.01, float(fx.get("maxLife", 1.0)))
		var ratio := clampf(life / max_life, 0.0, 1.0)
		var color: Color = fx.get("color", Color("#ff8fc8")) as Color
		var kind := String(fx.get("kind", ""))
		if kind == "note_trail":
			var pos := Vector2(fx.get("pos", Vector2.ZERO))
			draw_circle(pos, 18.0 * ratio, Color(color.r, color.g, color.b, 0.22 * ratio))
			draw_circle(pos, 10.0 * ratio, Color(1.0, 1.0, 1.0, 0.20 * ratio))
			_draw_outlined_text(pos + Vector2(-10.0, 9.0), String(fx.get("symbol", "♪")), 24, 20, Color(color.r, color.g, color.b, 0.94 * ratio), Color(0.16, 0.04, 0.20, 0.62 * ratio), HORIZONTAL_ALIGNMENT_CENTER)
		elif kind == "penlight_shot":
			var from_pos := Vector2(fx.get("from", Vector2.ZERO))
			var to_pos := Vector2(fx.get("to", Vector2.ZERO))
			var beam_len: float = from_pos.distance_to(to_pos)
			var beam_dir := Vector2.RIGHT
			if beam_len > 0.01:
				beam_dir = (to_pos - from_pos) / beam_len
			var beam_side := Vector2(-beam_dir.y, beam_dir.x)
			draw_line(from_pos, to_pos, Color(color.r, color.g, color.b, 0.34 * ratio), 16.0, true)
			draw_line(from_pos, to_pos, Color(1.0, 1.0, 1.0, 0.64 * ratio), 9.5, true)
			draw_line(from_pos, to_pos, Color(color.r, color.g, color.b, 0.98 * ratio), 6.0, true)
			draw_line(from_pos, to_pos, Color(1.0, 1.0, 1.0, 0.94 * ratio), 2.6, true)
			for offset in [-5.5, 5.5]:
				draw_line(from_pos + beam_side * offset, to_pos + beam_side * offset, Color(color.r, color.g, color.b, 0.38 * ratio), 2.0, true)
			var glint_pos := from_pos.lerp(to_pos, 0.58 + sin(elapsed * 18.0 + from_pos.x * 0.03) * 0.10)
			DrawPrimitiveSystemScript.draw_spark(self, glint_pos, 5.0 + 4.0 * ratio, Color(1.0, 1.0, 1.0, 0.58 * ratio))
			draw_circle(from_pos, 10.0 + 4.0 * ratio, Color(color.r, color.g, color.b, 0.20 * ratio))
			draw_circle(to_pos, 12.0 + (1.0 - ratio) * 14.0, Color(color.r, color.g, color.b, 0.26 * ratio))
			draw_circle(to_pos, 5.0 + (1.0 - ratio) * 5.0, Color(1.0, 1.0, 1.0, 0.72 * ratio))
		elif kind == "harmony_wave" or kind == "octave_wave":
			var pos2 := Vector2(fx.get("pos", Vector2.ZERO))
			var radius := float(fx.get("radius", 120.0)) * (1.10 - ratio * 0.10)
			var wave_color := Color("#ffc7df") if kind == "harmony_wave" else color
			var spark_count := 8 if kind == "octave_wave" else (6 if kind == "harmony_wave" else 10)
			var thickness := 7.0 if kind == "octave_wave" else (5.5 if kind == "harmony_wave" else 7.0)
			draw_circle(pos2, radius, Color(wave_color.r, wave_color.g, wave_color.b, 0.18 * ratio))
			draw_circle(pos2, radius * 0.72, Color(1.0, 1.0, 1.0, 0.12 * ratio))
			draw_circle(pos2, radius + 4.0, Color(1.0, 1.0, 1.0, 0.58 * ratio), false, thickness + 2.0)
			draw_circle(pos2, radius, Color(wave_color.r, wave_color.g, wave_color.b, 0.86 * ratio), false, thickness)
			draw_circle(pos2, radius * 0.78, Color(1.0, 1.0, 1.0, 0.48 * ratio), false, 3.0)
			draw_circle(pos2, radius * 0.48, Color(wave_color.r, wave_color.g, wave_color.b, 0.24 * ratio), false, 2.0)
			for arc_index in range(6):
				var start_angle := elapsed * 1.7 + float(arc_index) * TAU / 6.0
				draw_arc(pos2, radius * 0.96, start_angle, start_angle + TAU / 32.0, 6, Color(1.0, 1.0, 1.0, 0.62 * ratio), 3.0)
			for i in range(spark_count):
				var angle := elapsed * 1.8 + float(i) * TAU / float(spark_count)
				var spark := pos2 + Vector2(cos(angle), sin(angle)) * radius * 0.92
				DrawPrimitiveSystemScript.draw_spark(self, spark, 5.0 + 4.0 * ratio, Color(1.0, 1.0, 1.0, 0.76 * ratio))
		elif kind == "audience_call_wave":
			var lane_rect: Rect2 = fx.get("rect", Rect2()) as Rect2
			if lane_rect.size == Vector2.ZERO:
				continue
			var arena: Rect2 = fx.get("arena", lane_rect) as Rect2
			var horizontal_lane := bool(fx.get("horizontal", true))
			var dir := Vector2(fx.get("dir", Vector2.RIGHT))
			var width := float(fx.get("width", SONG_AUDIENCE_CALL_WAVE_WIDTH))
			var progress := 1.0 - ratio
			var call_colors := [Color("#ff5cae"), Color("#5be7ff"), Color("#ffd84f"), Color("#caa7ff")]
			draw_rect(lane_rect, Color(1.0, 0.55, 0.82, 0.13 * ratio), true)
			draw_rect(lane_rect.grow(-width * 0.18), Color(0.40, 0.88, 1.0, 0.12 * ratio), true)
			draw_rect(lane_rect, Color(1.0, 1.0, 1.0, 0.42 * ratio), false, 5.0)
			draw_rect(lane_rect.grow(-9.0), Color(1.0, 0.83, 0.22, 0.34 * ratio), false, 3.0)
			if horizontal_lane:
				var start_x := arena.position.x - width * 0.65
				var end_x := arena.end.x + width * 0.65
				var crest_x := lerpf(start_x, end_x, progress) if dir.x >= 0.0 else lerpf(end_x, start_x, progress)
				var entry_x := arena.position.x if dir.x >= 0.0 else arena.end.x
				var core_rect := Rect2(Vector2(crest_x - width * 0.36, lane_rect.position.y), Vector2(width * 0.72, lane_rect.size.y))
				draw_line(Vector2(entry_x, lane_rect.position.y), Vector2(entry_x, lane_rect.end.y), Color(1.0, 0.88, 0.35, 0.20 * ratio), width * 0.45, true)
				draw_line(Vector2(entry_x, lane_rect.position.y), Vector2(entry_x, lane_rect.end.y), Color(1.0, 1.0, 1.0, 0.30 * ratio), width * 0.14, true)
				draw_rect(core_rect.grow(42.0), Color(1.0, 1.0, 1.0, 0.18 * ratio), true)
				draw_rect(core_rect.grow(22.0), Color(1.0, 0.84, 0.26, 0.18 * ratio), true)
				draw_rect(core_rect, Color(0.40, 0.90, 1.0, 0.20 * ratio), true)
				draw_rect(core_rect, Color(1.0, 1.0, 1.0, 0.70 * ratio), false, 7.0)
				draw_rect(core_rect.grow(-10.0), Color(1.0, 0.34, 0.70, 0.55 * ratio), false, 4.0)
				for band in range(5):
					var lane_rate := 0.16 + float(band) * 0.17
					var y := lane_rect.position.y + lane_rect.size.y * lane_rate + sin(elapsed * 5.2 + float(band) * 1.4) * 8.0
					var wave_y := y + sin(elapsed * 3.2 + float(band)) * 10.0
					var band_color: Color = call_colors[band % call_colors.size()] as Color
					draw_line(Vector2(lane_rect.position.x, y), Vector2(lane_rect.end.x, wave_y), Color(1.0, 1.0, 1.0, 0.46 * ratio), 15.0, true)
					draw_line(Vector2(lane_rect.position.x, y), Vector2(lane_rect.end.x, wave_y), Color(band_color.r, band_color.g, band_color.b, 0.78 * ratio), 8.0, true)
					draw_line(Vector2(lane_rect.position.x, y), Vector2(lane_rect.end.x, wave_y), Color(1.0, 1.0, 1.0, 0.72 * ratio), 2.2, true)
				for i in range(20):
					var t := fmod(progress * 1.45 + float(i) / 20.0, 1.0)
					var x := lane_rect.position.x + t * lane_rect.size.x
					if dir.x < 0.0:
						x = lane_rect.end.x - t * lane_rect.size.x
					var y2 := lane_rect.position.y + 22.0 + fmod(float(i) * 47.0 + elapsed * 64.0, maxf(1.0, lane_rect.size.y - 44.0))
					var light_color: Color = call_colors[i % call_colors.size()] as Color
					var rod_dir := dir * 34.0 + Vector2(0.0, sin(elapsed * 6.0 + float(i)) * 15.0)
					var rod_from := Vector2(x, y2) - rod_dir * 0.48
					var rod_to := Vector2(x, y2) + rod_dir * 0.52
					draw_line(rod_from, rod_to, Color(1.0, 1.0, 1.0, 0.68 * ratio), 9.0, true)
					draw_line(rod_from, rod_to, Color(light_color.r, light_color.g, light_color.b, 0.96 * ratio), 5.2, true)
					draw_circle(rod_to, 6.0, Color(1.0, 1.0, 1.0, 0.84 * ratio))
					if i % 4 == 0:
						DrawPrimitiveSystemScript.draw_spark(self, rod_to + dir * 10.0, 5.0 + 3.0 * ratio, Color(1.0, 1.0, 1.0, 0.70 * ratio))
				for mark in range(5):
					var mt := fmod(progress * 1.1 + float(mark) / 5.0, 1.0)
					var mx := lane_rect.position.x + mt * lane_rect.size.x
					if dir.x < 0.0:
						mx = lane_rect.end.x - mt * lane_rect.size.x
					var my := lane_rect.get_center().y + sin(elapsed * 4.0 + float(mark)) * width * 0.20
					var side := Vector2(0.0, 18.0)
					var back := -dir * 28.0
					var tip := Vector2(mx, my) + dir * 16.0
					draw_line(tip + back + side, tip, Color(1.0, 1.0, 1.0, 0.62 * ratio), 6.0, true)
					draw_line(tip + back - side, tip, Color(1.0, 0.82, 0.28, 0.64 * ratio), 6.0, true)
			else:
				var start_y := arena.position.y - width * 0.65
				var end_y := arena.end.y + width * 0.65
				var crest_y := lerpf(start_y, end_y, progress) if dir.y >= 0.0 else lerpf(end_y, start_y, progress)
				var entry_y := arena.position.y if dir.y >= 0.0 else arena.end.y
				var core_rect := Rect2(Vector2(lane_rect.position.x, crest_y - width * 0.36), Vector2(lane_rect.size.x, width * 0.72))
				draw_line(Vector2(lane_rect.position.x, entry_y), Vector2(lane_rect.end.x, entry_y), Color(1.0, 0.88, 0.35, 0.20 * ratio), width * 0.45, true)
				draw_line(Vector2(lane_rect.position.x, entry_y), Vector2(lane_rect.end.x, entry_y), Color(1.0, 1.0, 1.0, 0.30 * ratio), width * 0.14, true)
				draw_rect(core_rect.grow(42.0), Color(1.0, 1.0, 1.0, 0.18 * ratio), true)
				draw_rect(core_rect.grow(22.0), Color(1.0, 0.84, 0.26, 0.18 * ratio), true)
				draw_rect(core_rect, Color(0.40, 0.90, 1.0, 0.20 * ratio), true)
				draw_rect(core_rect, Color(1.0, 1.0, 1.0, 0.70 * ratio), false, 7.0)
				draw_rect(core_rect.grow(-10.0), Color(1.0, 0.34, 0.70, 0.55 * ratio), false, 4.0)
				for band in range(5):
					var lane_rate2 := 0.16 + float(band) * 0.17
					var x2 := lane_rect.position.x + lane_rect.size.x * lane_rate2 + sin(elapsed * 5.2 + float(band) * 1.4) * 8.0
					var wave_x := x2 + sin(elapsed * 3.2 + float(band)) * 10.0
					var band_color2: Color = call_colors[band % call_colors.size()] as Color
					draw_line(Vector2(x2, lane_rect.position.y), Vector2(wave_x, lane_rect.end.y), Color(1.0, 1.0, 1.0, 0.46 * ratio), 15.0, true)
					draw_line(Vector2(x2, lane_rect.position.y), Vector2(wave_x, lane_rect.end.y), Color(band_color2.r, band_color2.g, band_color2.b, 0.78 * ratio), 8.0, true)
					draw_line(Vector2(x2, lane_rect.position.y), Vector2(wave_x, lane_rect.end.y), Color(1.0, 1.0, 1.0, 0.72 * ratio), 2.2, true)
				for i in range(20):
					var t2 := fmod(progress * 1.45 + float(i) / 20.0, 1.0)
					var y3 := lane_rect.position.y + t2 * lane_rect.size.y
					if dir.y < 0.0:
						y3 = lane_rect.end.y - t2 * lane_rect.size.y
					var x3 := lane_rect.position.x + 22.0 + fmod(float(i) * 47.0 + elapsed * 64.0, maxf(1.0, lane_rect.size.x - 44.0))
					var light_color2: Color = call_colors[i % call_colors.size()] as Color
					var rod_dir2 := dir * 34.0 + Vector2(sin(elapsed * 6.0 + float(i)) * 15.0, 0.0)
					var rod_from2 := Vector2(x3, y3) - rod_dir2 * 0.48
					var rod_to2 := Vector2(x3, y3) + rod_dir2 * 0.52
					draw_line(rod_from2, rod_to2, Color(1.0, 1.0, 1.0, 0.68 * ratio), 9.0, true)
					draw_line(rod_from2, rod_to2, Color(light_color2.r, light_color2.g, light_color2.b, 0.96 * ratio), 5.2, true)
					draw_circle(rod_to2, 6.0, Color(1.0, 1.0, 1.0, 0.84 * ratio))
					if i % 4 == 0:
						DrawPrimitiveSystemScript.draw_spark(self, rod_to2 + dir * 10.0, 5.0 + 3.0 * ratio, Color(1.0, 1.0, 1.0, 0.70 * ratio))
				for mark in range(5):
					var mt2 := fmod(progress * 1.1 + float(mark) / 5.0, 1.0)
					var my2 := lane_rect.position.y + mt2 * lane_rect.size.y
					if dir.y < 0.0:
						my2 = lane_rect.end.y - mt2 * lane_rect.size.y
					var mx2 := lane_rect.get_center().x + sin(elapsed * 4.0 + float(mark)) * width * 0.20
					var side2 := Vector2(18.0, 0.0)
					var back2 := -dir * 28.0
					var tip2 := Vector2(mx2, my2) + dir * 16.0
					draw_line(tip2 + back2 + side2, tip2, Color(1.0, 1.0, 1.0, 0.62 * ratio), 6.0, true)
					draw_line(tip2 + back2 - side2, tip2, Color(1.0, 0.82, 0.28, 0.64 * ratio), 6.0, true)

func _draw_song_howling_effects() -> void:
	var speaker_texture: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, SONG_HOWLING_SPEAKER_IMAGE)
	for item in song_howling_emitters:
		var emitter: Dictionary = item as Dictionary
		var pos := Vector2(emitter.get("pos", Vector2.ZERO))
		var phase := float(emitter.get("phase", 0.0))
		var pulse := 0.5 + 0.5 * sin(elapsed * 8.0 + phase)
		draw_circle(pos + Vector2(0.0, 18.0), 42.0 + pulse * 6.0, Color(0.78, 0.06, 0.58, 0.16))
		if speaker_texture != null:
			var texture_size := speaker_texture.get_size()
			var image_width := 118.0 + pulse * 5.0
			var image_size := Vector2(image_width, image_width * texture_size.y / maxf(1.0, texture_size.x))
			var image_center := pos + Vector2(0.0, 4.0 + sin(elapsed * 5.5 + phase) * 1.8)
			var angle := sin(elapsed * 7.0 + phase) * 0.025
			_draw_rotated_texture(speaker_texture, image_center, image_size, angle, 0.98)
			draw_circle(pos + Vector2(image_width * 0.28, -image_size.y * 0.31), 7.0 + pulse * 2.2, Color(1.0, 0.18, 0.72, 0.48))
		else:
			draw_circle(pos, 19.0, Color(0.18, 0.06, 0.24, 0.66))
			draw_circle(pos, 19.0, Color(1.0, 0.52, 0.88, 0.92), false, 3.0)
			draw_line(pos + Vector2(-10.0, -3.0), pos + Vector2(10.0, -3.0), Color(1.0, 0.92, 1.0, 0.78), 4.0, true)
			draw_line(pos + Vector2(-5.0, 7.0), pos + Vector2(7.0, -11.0), Color(1.0, 0.35, 0.86, 0.82), 3.0, true)
		for i in range(3):
			var arc_radius := 38.0 + float(i) * 9.0 + pulse * 3.0
			_draw_fixed_arc(pos + Vector2(18.0, -8.0), arc_radius, -0.62, 0.56, 12, Color(1.0, 0.32, 0.86, 0.38 - float(i) * 0.07), 2.8)
		_draw_outlined_text(pos + Vector2(0.0, 36.0), "!!", 24, 18, Color("#ff47ca"), Color(0.18, 0.02, 0.20, 0.82), HORIZONTAL_ALIGNMENT_CENTER)
	for item in song_howling_waves:
		var wave: Dictionary = item as Dictionary
		var pos2 := Vector2(wave.get("pos", Vector2.ZERO))
		var age := float(wave.get("age", 0.0))
		var active := age >= SONG_HOWLING_TELEGRAPH_DURATION
		var phase2 := float(wave.get("phase", 0.0))
		if not active:
			var telegraph_ratio := clampf(age / maxf(0.01, SONG_HOWLING_TELEGRAPH_DURATION), 0.0, 1.0)
			var warn_radius := lerpf(SONG_HOWLING_WAVE_START_RADIUS, SONG_HOWLING_WAVE_END_RADIUS, telegraph_ratio)
			draw_circle(pos2, warn_radius, Color(1.0, 0.10, 0.82, 0.08 + telegraph_ratio * 0.12), false, 4.0)
			draw_circle(pos2, warn_radius + 7.0, Color(1.0, 1.0, 1.0, 0.20 + telegraph_ratio * 0.20), false, 2.5)
			for i in range(10):
				var angle := phase2 + float(i) * TAU / 10.0
				var spark := pos2 + Vector2(cos(angle), sin(angle)) * warn_radius
				draw_circle(spark, 3.0 + telegraph_ratio * 2.0, Color(1.0, 0.60, 0.94, 0.54))
			continue
		var progress := clampf((age - SONG_HOWLING_TELEGRAPH_DURATION) / maxf(0.01, SONG_HOWLING_WAVE_EXPAND_DURATION), 0.0, 1.0)
		var radius := lerpf(SONG_HOWLING_WAVE_START_RADIUS, SONG_HOWLING_WAVE_END_RADIUS, progress)
		var alpha := 1.0 - progress
		draw_circle(pos2, radius + 12.0, Color(0.94, 0.04, 0.74, 0.13 * alpha))
		draw_circle(pos2, radius, Color(1.0, 1.0, 1.0, 0.60 * alpha), false, 7.0)
		draw_circle(pos2, radius, Color(0.96, 0.05, 0.72, 0.92 * alpha), false, 4.5)
		draw_circle(pos2, maxf(8.0, radius - 30.0), Color(0.32, 0.08, 0.40, 0.22 * alpha), false, 2.8)
		for i in range(18):
			var angle2 := phase2 + float(i) * TAU / 18.0 + sin(elapsed * 7.0 + float(i)) * 0.06
			var jag := radius + (8.0 if i % 2 == 0 else -7.0)
			var p1 := pos2 + Vector2(cos(angle2), sin(angle2)) * jag
			var p2 := pos2 + Vector2(cos(angle2 + TAU / 44.0), sin(angle2 + TAU / 44.0)) * (radius + 4.0)
			draw_line(p1, p2, Color(1.0, 0.62, 0.94, 0.58 * alpha), 3.0, true)

func _draw_song_bad_lights() -> void:
	for item in song_bad_lights:
		var light: Dictionary = item as Dictionary
		var pos := Vector2(light.get("pos", Vector2.ZERO))
		var radius := float(light.get("radius", SONG_BAD_LIGHT_RADIUS))
		var time_left := float(light.get("time", 0.0))
		var max_time := maxf(0.01, float(light.get("maxTime", SONG_BAD_LIGHT_LIFETIME)))
		var age := max_time - time_left
		var spawn := smoothstep(0.0, 0.18, age)
		var fade := smoothstep(0.0, 0.38, time_left)
		var alpha := clampf(spawn * fade, 0.0, 1.0)
		if alpha <= 0.0:
			continue
		var phase := float(light.get("phase", 0.0))
		var flicker := 0.55 + 0.45 * sin(elapsed * 19.0 + phase)
		var inside := player_pos.distance_squared_to(pos) <= radius * radius
		var ring_alpha := alpha * (flicker if time_left < 0.7 else 1.0)
		var color := Color("#e91c80")
		draw_circle(pos, radius * 1.02, Color(1.0, 1.0, 1.0, 0.12 * alpha))
		draw_circle(pos, radius * 0.92, Color(0.96, 0.05, 0.56, 0.14 * alpha))
		draw_circle(pos, radius * 0.58, Color(1.0, 0.80, 0.98, 0.08 * alpha))
		draw_circle(pos, radius, Color(1.0, 1.0, 1.0, 0.70 * ring_alpha), false, 5.5)
		draw_circle(pos, radius * 0.94, Color(color.r, color.g, color.b, 0.88 * ring_alpha), false, 6.0)
		draw_circle(pos, radius * 0.77, Color(0.42, 0.02, 0.30, 0.28 * alpha), false, 2.6)
		for i in range(18):
			var angle := phase + elapsed * 2.2 + float(i) * TAU / 18.0
			var outer := radius * (1.02 + (0.06 if i % 2 == 0 else -0.04))
			var inner := radius * (0.84 + (0.04 if i % 3 == 0 else -0.02))
			var p1 := pos + Vector2(cos(angle), sin(angle)) * inner
			var p2 := pos + Vector2(cos(angle + 0.08), sin(angle + 0.08)) * outer
			draw_line(p1, p2, Color(1.0, 0.58, 0.90, 0.56 * alpha), 3.4, true)
			if i % 3 == 0:
				draw_line(pos + Vector2(cos(angle), sin(angle)) * radius * 0.38, p2, Color(1.0, 1.0, 1.0, 0.18 * alpha), 2.0, true)
		var icon_alpha := (0.78 if inside else 0.55) * alpha
		draw_circle(pos, 25.0 + (6.0 if inside else 0.0), Color(0.20, 0.04, 0.28, 0.42 * alpha))
		_draw_outlined_text(pos + Vector2(-12.0, 11.0), "!", 26, 24, Color(1.0, 0.34, 0.88, icon_alpha), Color(0.12, 0.00, 0.16, 0.82 * alpha), HORIZONTAL_ALIGNMENT_CENTER)
		_draw_outlined_text(pos + Vector2(-48.0, radius * 0.38), "攻撃停止", 96, 15, Color(1.0, 0.86, 0.98, 0.82 * alpha), Color(0.18, 0.00, 0.10, 0.84 * alpha), HORIZONTAL_ALIGNMENT_CENTER)

func _draw_song_bad_light_player_glare() -> void:
	if not _normal_weapons_disabled_by_song_bad_light():
		return
	var pulse := 0.55 + 0.45 * sin(elapsed * 18.0)
	draw_circle(player_pos, 58.0 + pulse * 9.0, Color(1.0, 0.92, 1.0, 0.16))
	draw_circle(player_pos, 42.0 + pulse * 4.0, Color(1.0, 0.18, 0.62, 0.13))
	draw_circle(player_pos, 32.0, Color(1.0, 1.0, 1.0, 0.10))
	for i in range(8):
		var angle := elapsed * 6.2 + float(i) * TAU / 8.0
		var from_pos := player_pos + Vector2(cos(angle), sin(angle)) * (24.0 + pulse * 5.0)
		var to_pos := player_pos + Vector2(cos(angle + 0.10), sin(angle + 0.10)) * (62.0 + pulse * 8.0)
		draw_line(from_pos, to_pos, Color(1.0, 0.40, 0.86, 0.38), 3.0, true)

func _draw_song_lyrics_card(card: Dictionary) -> void:
	var pos := Vector2(card.get("pos", Vector2.ZERO))
	var phase := float(card.get("phase", 0.0))
	var bob := sin(elapsed * 4.8 + phase) * 5.0
	var draw_pos := pos + Vector2(0.0, bob)
	var time_left := float(card.get("time", 0.0))
	var max_time := maxf(0.01, float(card.get("maxTime", SONG_LYRICS_CARD_LIFETIME)))
	var spawn_alpha := smoothstep(0.0, 0.28, max_time - time_left)
	var alpha := clampf(spawn_alpha if time_left > 0.0 else 0.0, 0.0, 1.0)
	var lyrics_texture: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, SONG_LYRICS_CARD_IMAGE)
	if lyrics_texture != null:
		var pulse := 1.0 + sin(elapsed * 5.0 + phase) * 0.025
		var image_width := 118.0 * pulse
		var image_size := Vector2(image_width, image_width * lyrics_texture.get_size().y / maxf(1.0, lyrics_texture.get_size().x))
		DrawPrimitiveSystemScript.draw_shadow(self, draw_pos + Vector2(0.0, image_size.y * 0.28), Vector2(image_size.x * 0.70, image_size.y * 0.20), 0.14 * alpha)
		draw_circle(draw_pos, image_width * 0.44, Color(1.0, 0.92, 0.42, 0.09 * alpha))
		draw_texture_rect(lyrics_texture, Rect2(draw_pos - image_size * 0.5, image_size), false, Color(1.0, 1.0, 1.0, alpha))
		if time_left <= 2.0:
			var blink := 0.45 + 0.55 * sin(elapsed * 18.0)
			draw_circle(draw_pos, image_width * 0.48, Color(1.0, 0.58, 0.86, 0.22 * blink * alpha), false, 3.0)
		return
	var rect := Rect2(draw_pos - Vector2(46.0, 34.0), Vector2(92.0, 68.0))
	DrawPrimitiveSystemScript.draw_shadow(self, rect.get_center() + Vector2(0.0, 10.0), rect.size + Vector2(12.0, 8.0), 0.15 * alpha)
	_draw_song_notice_soft_rect(rect, Color(1.0, 0.98, 1.0, 0.92 * alpha), Color(1.0, 0.42, 0.76, 0.88 * alpha), 2.5, 10.0)
	draw_rect(Rect2(rect.position + Vector2(10.0, 12.0), Vector2(rect.size.x - 20.0, 4.0)), Color(0.56, 0.84, 1.0, 0.72 * alpha), true)
	draw_rect(Rect2(rect.position + Vector2(12.0, 25.0), Vector2(rect.size.x - 24.0, 3.0)), Color(0.82, 0.62, 1.0, 0.58 * alpha), true)
	draw_rect(Rect2(rect.position + Vector2(12.0, 36.0), Vector2(rect.size.x - 34.0, 3.0)), Color(1.0, 0.70, 0.86, 0.58 * alpha), true)
	var note_color := Color("#ff5cad")
	note_color.a = alpha
	_draw_outlined_text(rect.position + Vector2(24.0, 59.0), "♪?", 44, 24, note_color, Color(0.22, 0.04, 0.24, 0.74 * alpha), HORIZONTAL_ALIGNMENT_CENTER)
	DrawPrimitiveSystemScript.draw_spark(self, rect.position + Vector2(rect.size.x - 10.0, 10.0), 6.0, Color(1.0, 1.0, 1.0, 0.58 * alpha))

func _draw_song_boss_megaphone_waves() -> void:
	for item in song_boss_megaphone_waves:
		var wave: Dictionary = item as Dictionary
		var origin := Vector2(wave.get("origin", Vector2.ZERO))
		var wave_dir := Vector2(wave.get("dir", Vector2.RIGHT)).normalized()
		if wave_dir.length_squared() <= 0.01:
			wave_dir = Vector2.RIGHT
		var wave_range := float(wave.get("range", 380.0))
		var wave_angle := float(wave.get("angle", PI / 3.0))
		var max_time := maxf(0.01, float(wave.get("maxTime", 1.0)))
		var time_left := float(wave.get("time", 0.0))
		var age := max_time - time_left
		var telegraph := float(wave.get("telegraph", 0.7))
		var active := age >= telegraph
		var phase := clampf(age / maxf(0.01, max_time), 0.0, 1.0)
		var alpha := (0.45 if active else 0.28) * (1.0 - smoothstep(max_time - 0.16, max_time, age))
		if alpha <= 0.0:
			continue
		var base_angle := wave_dir.angle()
		var points := PackedVector2Array()
		points.append(origin)
		var steps := 18
		for i in range(steps + 1):
			var a := base_angle - wave_angle * 0.5 + wave_angle * float(i) / float(steps)
			points.append(origin + Vector2(cos(a), sin(a)) * wave_range)
		draw_colored_polygon(points, Color(1.0, 0.12, 0.42, 0.11 + alpha * 0.16))
		_draw_polyline(points, Color(1.0, 1.0, 1.0, 0.50 + alpha * 0.35), 4.0 if active else 2.5)
		_draw_polyline(points, Color(1.0, 0.12, 0.38, 0.62 + alpha * 0.18), 2.2 if active else 1.6)
		var core_len := wave_range * (0.72 + phase * 0.10)
		for j in range(5):
			var offset_rate := -0.42 + float(j) * 0.21
			var a2 := base_angle + wave_angle * offset_rate + sin(elapsed * 10.0 + float(j)) * 0.015
			var to_pos := origin + Vector2(cos(a2), sin(a2)) * core_len
			draw_line(origin + wave_dir * 18.0, to_pos, Color(1.0, 1.0, 1.0, 0.22 + alpha * 0.22), 10.0 if active else 6.0, true)
			draw_line(origin + wave_dir * 18.0, to_pos, Color(1.0, 0.12, 0.38, 0.46 + alpha * 0.22), 5.0 if active else 3.2, true)
		var label_pos := origin + wave_dir * minf(150.0, wave_range * 0.42) + Vector2(-46.0, 14.0)
		_draw_outlined_text(label_pos, "CHECK!", 92, 18, Color(1.0, 0.92, 0.98, 0.82 + alpha * 0.12), Color(0.22, 0.02, 0.10, 0.72), HORIZONTAL_ALIGNMENT_CENTER)
		for spark_index in range(8):
			var spark_t := fmod(phase * 1.4 + float(spark_index) / 8.0, 1.0)
			var spread := -wave_angle * 0.42 + wave_angle * 0.84 * fmod(float(spark_index) * 0.37, 1.0)
			var spark_pos := origin + Vector2(cos(base_angle + spread), sin(base_angle + spread)) * (wave_range * spark_t)
			DrawPrimitiveSystemScript.draw_spark(self, spark_pos, 4.5, Color(1.0, 0.62, 0.86, 0.48 + alpha * 0.18))

func _draw_song_pitch_waves() -> void:
	for item in song_pitch_waves:
		var wave: Dictionary = item as Dictionary
		var rect: Rect2 = wave.get("rect", Rect2()) as Rect2
		var age := float(wave.get("maxTime", 1.0)) - float(wave.get("time", 0.0))
		var active := age >= SONG_PITCH_WAVE_TELEGRAPH_DURATION
		var alpha := 0.50 if active else 0.32
		var core_color := Color(0.95, 0.08, 0.78, alpha)
		var edge_color := Color(1.0, 1.0, 1.0, 0.78 if active else 0.52)
		var warn_color := Color(1.0, 0.62, 0.94, 0.88 if active else 0.58)
		var fill_color := Color(0.82, 0.04, 0.68, 0.16 if active else 0.10)
		draw_rect(rect, fill_color, true)
		draw_rect(rect, Color(1.0, 1.0, 1.0, 0.22 if active else 0.14), false, 3.0)
		if bool(wave.get("horizontal", true)):
			var y := rect.get_center().y
			for offset in [-34.0, 0.0, 34.0]:
				draw_line(Vector2(rect.position.x, y + offset), Vector2(rect.end.x, y + offset + sin(elapsed * 9.0 + offset) * 6.0), Color(1.0, 1.0, 1.0, 0.34 if active else 0.22), 9.0 if active else 6.0, true)
				draw_line(Vector2(rect.position.x, y + offset), Vector2(rect.end.x, y + offset + sin(elapsed * 9.0 + offset) * 6.0), core_color, 5.5 if active else 4.0, true)
			draw_line(Vector2(rect.position.x, y), Vector2(rect.end.x, y), edge_color, 3.2)
			for j in range(7):
				var x := rect.position.x + 90.0 + float(j) * 270.0
				var noise_y := y + sin(elapsed * 10.0 + float(j)) * 38.0
				draw_line(Vector2(x - 22.0, noise_y - 12.0), Vector2(x + 24.0, noise_y + 10.0), Color(1.0, 1.0, 1.0, 0.42 if active else 0.28), 5.0, true)
				draw_line(Vector2(x - 22.0, noise_y - 12.0), Vector2(x + 24.0, noise_y + 10.0), warn_color, 2.6, true)
				if j % 2 == 0:
					_draw_outlined_text(Vector2(x - 18.0, y + 15.0), "♭", 36, 25, Color("#ff47ca"), Color(0.20, 0.02, 0.24, 0.78), HORIZONTAL_ALIGNMENT_CENTER)
		else:
			var x := rect.get_center().x
			for offset in [-34.0, 0.0, 34.0]:
				draw_line(Vector2(x + offset, rect.position.y), Vector2(x + offset + sin(elapsed * 9.0 + offset) * 6.0, rect.end.y), Color(1.0, 1.0, 1.0, 0.34 if active else 0.22), 9.0 if active else 6.0, true)
				draw_line(Vector2(x + offset, rect.position.y), Vector2(x + offset + sin(elapsed * 9.0 + offset) * 6.0, rect.end.y), core_color, 5.5 if active else 4.0, true)
			draw_line(Vector2(x, rect.position.y), Vector2(x, rect.end.y), edge_color, 3.2)
			for j in range(6):
				var y2 := rect.position.y + 100.0 + float(j) * 240.0
				var noise_x := x + sin(elapsed * 10.0 + float(j)) * 38.0
				draw_line(Vector2(noise_x - 12.0, y2 - 22.0), Vector2(noise_x + 10.0, y2 + 24.0), Color(1.0, 1.0, 1.0, 0.42 if active else 0.28), 5.0, true)
				draw_line(Vector2(noise_x - 12.0, y2 - 22.0), Vector2(noise_x + 10.0, y2 + 24.0), warn_color, 2.6, true)
				if j % 2 == 0:
					_draw_outlined_text(Vector2(x - 18.0, y2 + 10.0), "♭", 36, 25, Color("#ff47ca"), Color(0.20, 0.02, 0.24, 0.78), HORIZONTAL_ALIGNMENT_CENTER)

func _draw_song_note(note: Dictionary) -> void:
	var pos := Vector2(note.get("pos", Vector2.ZERO))
	var phase := float(note.get("phase", 0.0))
	var bob := sin(elapsed * 4.4 + phase) * 4.0
	var draw_pos := pos + Vector2(0.0, bob)
	var orb_index := clampi(int(note.get("orbIndex", 0)), 0, SONG_NOTE_ORB_IMAGES.size() - 1)
	var lyrics_locked := _song_notes_locked_by_lyrics_lost()
	var texture: Texture2D = _song_note_orb_texture(orb_index, lyrics_locked)
	if texture != null:
		var pulse := 1.0 + sin(elapsed * 5.2 + phase) * 0.035
		var size := Vector2(66.0, 66.0) * pulse
		DrawPrimitiveSystemScript.draw_shadow(self, draw_pos + Vector2(0.0, 13.0), Vector2(36.0, 10.0), 0.08 if lyrics_locked else 0.12)
		if lyrics_locked:
			draw_circle(draw_pos, 30.0 * pulse, Color(0.18, 0.17, 0.22, 0.20))
			draw_texture_rect(texture, Rect2(draw_pos - size * 0.5, size), false, Color(0.80, 0.82, 0.88, 0.84))
			draw_circle(draw_pos, 31.0 * pulse, Color(0.10, 0.09, 0.13, 0.24))
			draw_circle(draw_pos, 32.0 * pulse, Color(1.0, 1.0, 1.0, 0.36), false, 2.2)
			_draw_outlined_text(draw_pos + Vector2(-13.0, 14.0), "×", 31, 26, Color(0.92, 0.94, 1.0, 0.90), Color(0.10, 0.08, 0.14, 0.88), HORIZONTAL_ALIGNMENT_CENTER)
		else:
			draw_circle(draw_pos, 28.0 * pulse, Color(1.0, 0.78, 0.96, 0.10))
			draw_texture_rect(texture, Rect2(draw_pos - size * 0.5, size), false)
		return
	var color: Color = note.get("color", Color("#ff8fc8")) as Color
	if lyrics_locked:
		color = Color(0.58, 0.60, 0.68, 0.82)
	draw_circle(draw_pos, 28.0, Color(color.r, color.g, color.b, 0.16))
	draw_circle(draw_pos, 19.0, Color(1.0, 1.0, 1.0, 0.86))
	draw_circle(draw_pos, 18.0, Color(color.r, color.g, color.b, 0.78), false, 3)
	_draw_outlined_text(draw_pos + Vector2(-17.0, 15.0), String(note.get("symbol", "♪")), 34, 26, color, Color(0.26, 0.12, 0.34, 0.55), HORIZONTAL_ALIGNMENT_CENTER)

func _draw_song_spotlight(light: Dictionary) -> void:
	var pos := Vector2(light.get("pos", Vector2.ZERO))
	var radius := float(light.get("radius", SONG_SPOTLIGHT_RADIUS))
	var time_left := float(light.get("time", 0.0))
	var max_time := maxf(0.01, float(light.get("maxTime", SONG_SPOTLIGHT_DURATION)))
	var age := max_time - time_left
	var spawn := smoothstep(0.0, 0.24, age)
	var fade := smoothstep(0.0, 0.48, time_left)
	var life_alpha := clampf(spawn * fade, 0.0, 1.0)
	if life_alpha <= 0.0:
		return
	var phase := float(light.get("phase", 0.0))
	var occupied := player_pos.distance_squared_to(pos) <= radius * radius
	var expiring := time_left < 0.85
	var pulse := 0.5 + 0.5 * sin(elapsed * 5.8 + phase)
	var sweep := elapsed * 0.58 + phase
	var blink := 0.45 + 0.55 * sin(elapsed * 18.0 + phase)
	var ring_alpha := life_alpha * (blink if expiring else 1.0)
	var occupied_boost := 1.0 if occupied else 0.0
	var visual_radius := minf(160.0, radius * (0.87 + pulse * 0.025 + occupied_boost * 0.06 + (1.0 - spawn) * 0.12))
	var floor_texture_path := SONG_SPOTLIGHT_FLOOR_ACTIVE_IMAGE
	if expiring:
		floor_texture_path = SONG_SPOTLIGHT_FLOOR_EXPIRING_IMAGE
	elif occupied:
		floor_texture_path = SONG_SPOTLIGHT_FLOOR_OCCUPIED_IMAGE
	var floor_texture: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, floor_texture_path)
	var floor_scale := 2.34 + occupied_boost * 0.12
	var floor_size := Vector2.ONE * visual_radius * floor_scale
	var floor_alpha := life_alpha * (0.56 + occupied_boost * 0.20)
	if expiring:
		floor_alpha = life_alpha * (0.34 + blink * 0.20)
	if floor_texture != null:
		draw_texture_rect(floor_texture, Rect2(pos - floor_size * 0.5, floor_size), false, Color(1.0, 1.0, 1.0, floor_alpha))
		var sparkle_texture: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, SONG_SPOTLIGHT_SPARKLE_PARTICLES_IMAGE)
		if sparkle_texture != null and (occupied or expiring):
			var sparkle_alpha := life_alpha * (0.14 + occupied_boost * 0.22 + (0.10 * blink if expiring else 0.0))
			var sparkle_size := floor_size * (1.02 + pulse * 0.03)
			draw_texture_rect(sparkle_texture, Rect2(pos - sparkle_size * 0.5, sparkle_size), false, Color(1.0, 1.0, 1.0, sparkle_alpha))
	if age < 0.55:
		for i in range(12):
			var angle := phase + float(i) * TAU / 12.0 + elapsed * 1.4
			var gather := lerpf(radius * 0.95, radius * 0.34, spawn)
			var spark_pos := pos + Vector2(cos(angle), sin(angle)) * (gather + sin(elapsed * 8.0 + float(i)) * 6.0)
			draw_circle(spark_pos, 2.2 + pulse * 1.0, Color(1.0, 0.93, 0.58, 0.54 * life_alpha))
	if floor_texture == null:
		draw_circle(pos, visual_radius * 1.06, Color(1.0, 0.92, 0.48, (0.08 + occupied_boost * 0.04) * life_alpha))
		draw_circle(pos, visual_radius * 0.76, Color(1.0, 0.98, 0.78, (0.12 + occupied_boost * 0.06) * life_alpha))
	draw_circle(pos, visual_radius, Color(1.0, 0.82, 0.22, (0.36 + occupied_boost * 0.22) * ring_alpha), false, 1.8 + occupied_boost * 1.5)
	draw_circle(pos, visual_radius * 0.72, Color(1.0, 1.0, 1.0, (0.18 + occupied_boost * 0.12) * ring_alpha), false, 1.0 + occupied_boost * 0.8)
	for i in range(14):
		var start_angle := sweep + float(i) * TAU / 14.0
		var arc_alpha := (0.15 + occupied_boost * 0.16) * ring_alpha
		draw_arc(pos, visual_radius * 0.96, start_angle, start_angle + TAU / 58.0, 5, Color(1.0, 0.94, 0.58, arc_alpha), 1.2 + occupied_boost * 0.8)
	var particle_count: int = 12 if occupied else 7
	for i in range(particle_count):
		var angle := -sweep * (1.35 if occupied else 0.85) + float(i) * TAU / float(particle_count)
		var orbit: float = visual_radius * (0.30 + 0.36 * absf(sin(elapsed * 0.95 + float(i) * 0.73)))
		var particle_pos := pos + Vector2(cos(angle) * orbit, sin(angle) * orbit)
		if occupied:
			var attract: float = 0.18 + 0.10 * sin(elapsed * 3.0 + float(i))
			particle_pos = particle_pos.lerp(player_pos, attract)
		var particle_alpha := (0.48 + occupied_boost * 0.26) * life_alpha
		if i % 3 == 0:
			_draw_outlined_text(particle_pos + Vector2(-7.0, 7.0), "♪", 16, 13, Color(1.0, 0.76, 0.20, particle_alpha), Color(1.0, 1.0, 1.0, 0.34 * particle_alpha), HORIZONTAL_ALIGNMENT_CENTER)
		else:
			DrawPrimitiveSystemScript.draw_spark(self, particle_pos, 4.0 + pulse * 2.0, Color(1.0, 0.94, 0.56, particle_alpha))
	var icon_radius := 20.0 + occupied_boost * 4.0 + pulse * 1.5
	draw_circle(pos, icon_radius + 6.0, Color(1.0, 0.90, 0.42, (0.16 + occupied_boost * 0.08) * life_alpha))
	draw_circle(pos, icon_radius, Color(1.0, 1.0, 1.0, (0.72 + occupied_boost * 0.14) * life_alpha))
	draw_circle(pos, icon_radius, Color(1.0, 0.72, 0.16, 0.74 * life_alpha), false, 2.2)
	_draw_outlined_text(pos + Vector2(-13.0, 10.0), "♪", 26, 22, Color(0.86, 0.50, 0.03, 0.96 * life_alpha), Color(1.0, 1.0, 1.0, 0.70 * life_alpha), HORIZONTAL_ALIGNMENT_CENTER)
	if occupied:
		for i in range(5):
			var angle := sweep + float(i) * TAU / 5.0
			var from_pos := pos + Vector2(cos(angle), sin(angle)) * visual_radius * 0.72
			var to_pos := player_pos + Vector2(cos(angle + PI), sin(angle + PI)) * 10.0
			draw_line(from_pos, to_pos, Color(1.0, 0.92, 0.42, 0.18 * life_alpha), 2.0, true)

func _draw_song_spotlight_labels(visible_rect: Rect2) -> void:
	if not _is_song_frame():
		return
	for item in song_spotlights:
		var light: Dictionary = item as Dictionary
		var pos := Vector2(light.get("pos", Vector2.ZERO))
		if not visible_rect.has_point(pos):
			continue
		var radius := float(light.get("radius", SONG_SPOTLIGHT_RADIUS))
		if player_pos.distance_squared_to(pos) > radius * radius:
			continue
		var time_left := float(light.get("time", 0.0))
		var max_time := maxf(0.01, float(light.get("maxTime", SONG_SPOTLIGHT_DURATION)))
		var age := max_time - time_left
		var spawn := smoothstep(0.0, 0.24, age)
		var fade := smoothstep(0.0, 0.48, time_left)
		var life_alpha := clampf(spawn * fade, 0.0, 1.0)
		if life_alpha <= 0.0:
			continue
		var phase := float(light.get("phase", 0.0))
		var pulse := 0.5 + 0.5 * sin(elapsed * 5.8 + phase)
		var visual_radius := minf(160.0, radius * (0.93 + pulse * 0.025 + (1.0 - spawn) * 0.12))
		var label_alpha := (0.72 + pulse * 0.18) * life_alpha
		_draw_outlined_text(pos + Vector2(-52.0, visual_radius * 0.36), "LIVE HEAT+", 104, 15, Color(0.86, 0.50, 0.03, label_alpha), Color(1.0, 1.0, 1.0, 0.72 * label_alpha), HORIZONTAL_ALIGNMENT_CENTER)

func _draw_song_live_heat_level_notice() -> void:
	if song_live_heat_level_notice_timer <= 0.0 or song_live_heat_level_notice_data.is_empty():
		return
	if _song_live_heat_level_notice_blocked():
		return
	var duration := maxf(0.1, song_live_heat_level_notice_duration)
	var age := duration - song_live_heat_level_notice_timer
	var appear := smoothstep(0.0, 0.15, age)
	var fade := 1.0 - smoothstep(duration - 0.25, duration, age)
	var alpha := clampf(appear * fade, 0.0, 1.0)
	if alpha <= 0.0:
		return
	var level := int(song_live_heat_level_notice_data.get("level", 1))
	var max_level := level >= 5
	var accent: Color = song_live_heat_level_notice_data.get("accent", Color("#ff8fc8")) as Color
	var sub_accent: Color = song_live_heat_level_notice_data.get("subAccent", Color("#8eeaff")) as Color
	var base_size := Vector2(560.0, 136.0) if max_level else Vector2(510.0, 118.0)
	var scale := 1.0 + (1.0 - appear) * 0.065
	if max_level:
		scale += sin(elapsed * 10.0) * 0.006
	var center := Vector2(FIELD_VIEW.get_center().x, _song_notice_stack_center_y(base_size.y * scale, 0))
	center.y += lerpf(-14.0, 0.0, appear) - (1.0 - fade) * 12.0
	var rect := Rect2(center - base_size * scale * 0.5, base_size * scale)
	var glow_alpha := (0.24 if max_level else 0.14) * alpha
	DrawPrimitiveSystemScript.draw_shadow(self, rect.get_center() + Vector2(0.0, 8.0), rect.size + Vector2(26.0, 14.0), 0.17 * alpha)
	draw_rect(rect.grow(7.0), Color(accent.r, accent.g, accent.b, glow_alpha), true)
	if max_level:
		draw_rect(rect.grow(12.0), Color(sub_accent.r, sub_accent.g, sub_accent.b, 0.11 * alpha), true)
	_draw_song_notice_soft_rect(rect, Color(1.0, 0.985, 1.0, 0.94 * alpha), Color(accent.r, accent.g, accent.b, 0.86 * alpha), 3.0, 22.0)
	draw_rect(Rect2(rect.position + Vector2(0.0, 7.0), Vector2(rect.size.x, 7.0)), Color(sub_accent.r, sub_accent.g, sub_accent.b, (0.34 if max_level else 0.22) * alpha), true)
	draw_rect(Rect2(rect.position + Vector2(0.0, rect.size.y - 10.0), Vector2(rect.size.x, 8.0)), Color(accent.r, accent.g, accent.b, 0.22 * alpha), true)
	var icon_pos := rect.position + Vector2(62.0, rect.size.y * 0.5)
	draw_circle(icon_pos, 34.0, Color(accent.r, accent.g, accent.b, 0.22 * alpha))
	draw_circle(icon_pos, 25.0, Color(1.0, 1.0, 1.0, 0.92 * alpha))
	draw_circle(icon_pos, 25.0, Color(accent.r, accent.g, accent.b, 0.82 * alpha), false, 3.0)
	_draw_outlined_text(icon_pos + Vector2(-17.0, 12.0), String(song_live_heat_level_notice_data.get("icon", "♪")), 34, 28, Color(accent.r, accent.g, accent.b, alpha), Color(0.24, 0.08, 0.20, 0.38 * alpha), HORIZONTAL_ALIGNMENT_CENTER)
	var text_x := rect.position.x + 112.0
	var text_width := int(rect.size.x - 136.0)
	var title_color := Color("#7a587d")
	title_color.a = 0.88 * alpha
	var name_color := Color("#ff3f9d") if not max_level else Color("#e58c00")
	name_color.a = alpha
	var desc_color := Color("#5f5068")
	desc_color.a = 0.92 * alpha
	_draw_text_item({"pos": Vector2(text_x, rect.position.y + 30.0), "text": String(song_live_heat_level_notice_data.get("title", "")), "width": text_width, "size": 18, "fontWeight": "black", "color": title_color})
	_draw_text_item({"pos": Vector2(text_x, rect.position.y + 68.0), "text": String(song_live_heat_level_notice_data.get("name", "")), "width": text_width, "size": 31 if max_level else 28, "fontWeight": "black", "color": name_color})
	_draw_text_item({"pos": Vector2(text_x, rect.position.y + 101.0), "text": String(song_live_heat_level_notice_data.get("description", "")), "width": text_width, "size": 17, "fontWeight": "bold", "color": desc_color})
	if max_level:
		for i in range(14):
			var t := elapsed * 2.2 + float(i) * 0.63
			var spark := rect.position + Vector2(fmod(float(i) * 47.0 + elapsed * 54.0, rect.size.x), 12.0 + sin(t) * 10.0)
			var spark_color := accent if i % 2 == 0 else sub_accent
			draw_circle(spark, 2.4 + sin(t * 1.7) * 0.8, Color(spark_color.r, spark_color.g, spark_color.b, 0.58 * alpha))
			if i % 4 == 0:
				DrawPrimitiveSystemScript.draw_spark(self, spark + Vector2(0.0, 20.0), 7.0, Color(1.0, 1.0, 1.0, 0.56 * alpha))

func _draw_song_octave_bonus_notice() -> void:
	if song_octave_bonus_notice_timer <= 0.0:
		return
	if not _is_song_frame():
		return
	if state != "playing":
		return
	var duration := maxf(0.1, song_octave_bonus_notice_duration)
	var age := duration - song_octave_bonus_notice_timer
	var appear := smoothstep(0.0, 0.14, age)
	var fade := 1.0 - smoothstep(duration - 0.25, duration, age)
	var alpha := clampf(appear * fade, 0.0, 1.0)
	if alpha <= 0.0:
		return
	var base_size := Vector2(468.0, 102.0)
	var scale := 1.0 + (1.0 - appear) * 0.055
	var lane := 1 if _song_live_heat_level_notice_visible() else 0
	var center := Vector2(FIELD_VIEW.get_center().x, _song_notice_stack_center_y(base_size.y * scale, lane))
	center.y += lerpf(-10.0, 0.0, appear) - (1.0 - fade) * 10.0
	var rect := Rect2(center - base_size * scale * 0.5, base_size * scale)
	var gold := Color("#ffd45d")
	var pink := Color("#ff7eb6")
	var cyan := Color("#8eeaff")
	DrawPrimitiveSystemScript.draw_shadow(self, rect.get_center() + Vector2(0.0, 7.0), rect.size + Vector2(24.0, 12.0), 0.15 * alpha)
	draw_rect(rect.grow(7.0), Color(gold.r, gold.g, gold.b, 0.14 * alpha), true)
	_draw_song_notice_soft_rect(rect, Color(1.0, 0.99, 0.96, 0.94 * alpha), Color(gold.r, gold.g, gold.b, 0.88 * alpha), 3.0, 20.0)
	draw_rect(Rect2(rect.position + Vector2(0.0, 7.0), Vector2(rect.size.x, 6.0)), Color(pink.r, pink.g, pink.b, 0.26 * alpha), true)
	draw_rect(Rect2(rect.position + Vector2(0.0, rect.size.y - 9.0), Vector2(rect.size.x, 7.0)), Color(cyan.r, cyan.g, cyan.b, 0.24 * alpha), true)
	var icon_pos := rect.position + Vector2(54.0, rect.size.y * 0.5)
	draw_circle(icon_pos, 29.0, Color(gold.r, gold.g, gold.b, 0.24 * alpha))
	draw_circle(icon_pos, 21.0, Color(1.0, 1.0, 1.0, 0.94 * alpha))
	draw_circle(icon_pos, 21.0, Color(pink.r, pink.g, pink.b, 0.74 * alpha), false, 3.0)
	var icon_color := Color("#ff5cad")
	icon_color.a = alpha
	_draw_outlined_text(icon_pos + Vector2(-16.0, 11.0), "♪", 32, 26, icon_color, Color(0.24, 0.08, 0.18, 0.36 * alpha), HORIZONTAL_ALIGNMENT_CENTER)
	var text_x := rect.position.x + 96.0
	var text_width := int(rect.size.x - 118.0)
	_draw_text_item({"pos": Vector2(text_x, rect.position.y + 26.0), "text": "1オクターブ完成！ オクターブボーナス", "width": text_width, "size": 19, "fontWeight": "black", "color": Color(0.52, 0.28, 0.48, 0.94 * alpha)})
	_draw_text_item({"pos": Vector2(text_x, rect.position.y + 57.0), "text": "テンション +5　視聴者 +500", "width": text_width, "size": 16, "fontWeight": "bold", "color": Color(0.90, 0.28, 0.56, 0.95 * alpha)})
	var wave_text := "音波攻撃・ノックバック"
	if song_octave_bonus_notice_hits > 0:
		wave_text = "音波攻撃 %d体" % song_octave_bonus_notice_hits
	if song_octave_bonus_notice_call_wave:
		wave_text = "観客コール波発生！"
	_draw_text_item({"pos": Vector2(text_x, rect.position.y + 80.0), "text": "ギフト期待度 +1　%s" % wave_text, "width": text_width, "size": 15, "fontWeight": "bold", "color": Color(0.28, 0.52, 0.72, 0.92 * alpha)})
	for i in range(6):
		var t := elapsed * 2.8 + float(i) * 0.74
		var spark := rect.position + Vector2(34.0 + float(i) * 70.0 + sin(t) * 5.0, 16.0 + cos(t * 1.2) * 5.0)
		DrawPrimitiveSystemScript.draw_spark(self, spark, 5.0, Color(1.0, 1.0, 1.0, 0.45 * alpha))

func _draw_song_boss_chorus_judge_notice() -> void:
	if not _is_song_frame() or state != "playing":
		return
	if song_boss_chorus_judge_notice_timer <= 0.0 and not song_boss_chorus_judge_active:
		return
	var duration := maxf(0.1, song_boss_chorus_judge_notice_duration if song_boss_chorus_judge_notice_duration > 0.0 else 1.0)
	var age := duration - song_boss_chorus_judge_notice_timer
	var appear := 1.0 if song_boss_chorus_judge_active else smoothstep(0.0, 0.14, age)
	var fade := 1.0 if song_boss_chorus_judge_active else 1.0 - smoothstep(duration - 0.25, duration, age)
	var alpha := clampf(appear * fade, 0.0, 1.0)
	if alpha <= 0.0:
		return
	var base_size := Vector2(430.0, 90.0)
	var lane := 0
	if _song_live_heat_level_notice_visible():
		lane += 1
	if song_octave_bonus_notice_timer > 0.0:
		lane += 1
	var center := Vector2(FIELD_VIEW.get_center().x, _song_notice_stack_center_y(base_size.y, lane))
	center.y += lerpf(-9.0, 0.0, appear) - (1.0 - fade) * 9.0
	var rect := Rect2(center - base_size * 0.5, base_size)
	var accent := Color("#ff3f82")
	var sub_accent := Color("#8eeaff") if song_boss_chorus_judge_notice_success else Color("#caa7ff")
	var title := song_boss_chorus_judge_notice_title
	var subtitle := song_boss_chorus_judge_notice_subtitle
	if song_boss_chorus_judge_active:
		title = "サビジャッジ中！"
		var remain := int(ceil(song_boss_chorus_judge_timer))
		subtitle = "音符 %d / %d　残り%02d秒" % [song_boss_chorus_judge_collected, song_boss_chorus_judge_required, remain]
	DrawPrimitiveSystemScript.draw_shadow(self, rect.get_center() + Vector2(0.0, 7.0), rect.size + Vector2(24.0, 12.0), 0.15 * alpha)
	draw_rect(rect.grow(7.0), Color(accent.r, accent.g, accent.b, 0.13 * alpha), true)
	_draw_song_notice_soft_rect(rect, Color(1.0, 0.985, 1.0, 0.94 * alpha), Color(accent.r, accent.g, accent.b, 0.88 * alpha), 3.0, 20.0)
	draw_rect(Rect2(rect.position + Vector2(0.0, 7.0), Vector2(rect.size.x, 6.0)), Color(sub_accent.r, sub_accent.g, sub_accent.b, 0.26 * alpha), true)
	var icon_pos := rect.position + Vector2(54.0, rect.size.y * 0.5)
	draw_circle(icon_pos, 28.0, Color(accent.r, accent.g, accent.b, 0.24 * alpha))
	draw_circle(icon_pos, 20.0, Color(1.0, 1.0, 1.0, 0.94 * alpha))
	draw_circle(icon_pos, 20.0, Color(accent.r, accent.g, accent.b, 0.78 * alpha), false, 3.0)
	_draw_outlined_text(icon_pos + Vector2(-15.0, 10.0), "♪!", 32, 22, Color(accent.r, accent.g, accent.b, alpha), Color(0.20, 0.04, 0.18, 0.52 * alpha), HORIZONTAL_ALIGNMENT_CENTER)
	var text_x := rect.position.x + 94.0
	var text_width := int(rect.size.x - 116.0)
	_draw_text_item({"pos": Vector2(text_x, rect.position.y + 28.0), "text": title, "width": text_width, "size": 21, "fontWeight": "black", "color": Color(0.54, 0.18, 0.40, 0.95 * alpha)})
	_draw_text_item({"pos": Vector2(text_x, rect.position.y + 59.0), "text": subtitle, "width": text_width, "size": 17, "fontWeight": "bold", "color": Color(0.28, 0.46, 0.68, 0.92 * alpha)})
	if song_boss_chorus_judge_active and song_boss_chorus_judge_required > 0:
		var bar_rect := Rect2(rect.position + Vector2(95.0, rect.size.y - 16.0), Vector2(rect.size.x - 122.0, 6.0))
		var rate := clampf(float(song_boss_chorus_judge_collected) / float(song_boss_chorus_judge_required), 0.0, 1.0)
		draw_rect(bar_rect, Color(0.98, 0.82, 0.92, 0.72 * alpha), true)
		draw_rect(Rect2(bar_rect.position, Vector2(bar_rect.size.x * rate, bar_rect.size.y)), Color(accent.r, accent.g, accent.b, 0.86 * alpha), true)

func _draw_song_notice_soft_rect(rect: Rect2, fill: Color, border: Color, border_width: float, radius: float) -> void:
	var r := minf(radius, minf(rect.size.x, rect.size.y) * 0.5)
	draw_rect(Rect2(rect.position + Vector2(r, 0.0), Vector2(rect.size.x - r * 2.0, rect.size.y)), fill, true)
	draw_rect(Rect2(rect.position + Vector2(0.0, r), Vector2(rect.size.x, rect.size.y - r * 2.0)), fill, true)
	draw_circle(rect.position + Vector2(r, r), r, fill)
	draw_circle(rect.position + Vector2(rect.size.x - r, r), r, fill)
	draw_circle(rect.position + Vector2(r, rect.size.y - r), r, fill)
	draw_circle(rect.position + Vector2(rect.size.x - r, rect.size.y - r), r, fill)
	draw_line(rect.position + Vector2(r, 0.0), rect.position + Vector2(rect.size.x - r, 0.0), border, border_width)
	draw_line(rect.position + Vector2(r, rect.size.y), rect.position + Vector2(rect.size.x - r, rect.size.y), border, border_width)
	draw_line(rect.position + Vector2(0.0, r), rect.position + Vector2(0.0, rect.size.y - r), border, border_width)
	draw_line(rect.position + Vector2(rect.size.x, r), rect.position + Vector2(rect.size.x, rect.size.y - r), border, border_width)
	draw_arc(rect.position + Vector2(r, r), r, PI, PI * 1.5, 12, border, border_width)
	draw_arc(rect.position + Vector2(rect.size.x - r, r), r, PI * 1.5, TAU, 12, border, border_width)
	draw_arc(rect.position + Vector2(rect.size.x - r, rect.size.y - r), r, 0.0, PI * 0.5, 12, border, border_width)
	draw_arc(rect.position + Vector2(r, rect.size.y - r), r, PI * 0.5, PI, 12, border, border_width)

func _draw_song_chorus_banner() -> void:
	if song_chorus_banner_timer <= 0.0:
		return
	var duration := maxf(0.01, SONG_CHORUS_BANNER_DURATION)
	var age := duration - song_chorus_banner_timer
	var appear := smoothstep(0.0, 0.18, age)
	var fade := 1.0 - smoothstep(duration - 0.30, duration, age)
	var alpha := clampf(appear * fade, 0.0, 1.0)
	if alpha <= 0.0:
		return
	var rect := Rect2(Vector2(FIELD_VIEW.get_center().x - 260.0, FIELD_VIEW.position.y + 44.0), Vector2(520.0, 82.0))
	var accent := Color("#ff82c4")
	DrawPrimitiveSystemScript.draw_shadow(self, rect.get_center() + Vector2(0.0, 8.0), rect.size + Vector2(28.0, 14.0), 0.17 * alpha)
	draw_rect(rect.grow(4.0), Color(1.0, 0.75, 0.92, 0.22 * alpha), true)
	draw_rect(rect, Color(1.0, 1.0, 1.0, 0.91 * alpha), true)
	draw_rect(Rect2(rect.position, Vector2(rect.size.x, 7.0)), Color(0.55, 0.90, 1.0, 0.72 * alpha), true)
	draw_rect(rect, Color(accent.r, accent.g, accent.b, 0.84 * alpha), false, 3)
	_draw_text_item({"pos": rect.position + Vector2(0.0, 41.0), "text": "サビタイム！", "width": int(rect.size.x), "size": 34, "fontWeight": "black", "color": Color("#ff3f9d")}, "", HORIZONTAL_ALIGNMENT_CENTER)
	_draw_text_item({"pos": rect.position + Vector2(0.0, 67.0), "text": "音符を集めてテンションUP！", "width": int(rect.size.x), "size": 17, "fontWeight": "bold", "color": Color("#6b4a74")}, "", HORIZONTAL_ALIGNMENT_CENTER)

func _draw_song_chorus_timer() -> void:
	if not _is_song_frame() or song_chorus_timer <= 0.0:
		return
	if state != "playing" and state != "comment_choice" and state != "gift_choice":
		return
	var remaining := ceili(maxf(0.0, song_chorus_timer))
	var progress := clampf(song_chorus_timer / maxf(0.1, song_chorus_current_duration), 0.0, 1.0)
	var rect := Rect2(Vector2(FIELD_VIEW.end.x - 256.0, FIELD_VIEW.position.y + 14.0), Vector2(226.0, 54.0))
	var accent := Color("#ff82c4")
	DrawPrimitiveSystemScript.draw_shadow(self, rect.get_center() + Vector2(0.0, 7.0), rect.size + Vector2(18.0, 10.0), 0.14)
	draw_rect(rect, Color(1.0, 1.0, 1.0, 0.88), true)
	draw_rect(rect, accent, false, 3)
	_draw_text_item({"pos": rect.position + Vector2(13.0, 23.0), "text": "サビ 残り", "width": 118, "size": 15, "fontWeight": "bold", "color": Color("#7a587d")})
	_draw_text_item({"pos": rect.position + Vector2(136.0, 38.0), "text": "%02ds" % remaining, "width": 72, "size": 30, "fontWeight": "black", "color": Color("#ff54a8")}, "", HORIZONTAL_ALIGNMENT_CENTER)
	var bar := Rect2(rect.position + Vector2(13.0, 42.0), Vector2(rect.size.x - 26.0, 7.0))
	draw_rect(bar, Color("#f2e7fb"), true)
	draw_rect(Rect2(bar.position, Vector2(bar.size.x * progress, bar.size.y)), Color("#8eeaff"), true)

func _draw_song_chorus_result_card() -> void:
	if song_chorus_result_timer <= 0.0 or song_chorus_result_data.is_empty():
		return
	if state != "playing":
		return
	var lines_value: Variant = song_chorus_result_data.get("lines", [])
	var lines: Array = []
	if lines_value is Array:
		lines = lines_value as Array
	var duration := maxf(0.1, song_chorus_result_duration)
	var age := duration - song_chorus_result_timer
	var appear := smoothstep(0.0, 0.16, age)
	var fade := 1.0 - smoothstep(duration - 0.30, duration, age)
	var alpha := clampf(appear * fade, 0.0, 1.0)
	var rect := Rect2(Vector2(FIELD_VIEW.end.x - 370.0, FIELD_VIEW.position.y + 20.0), Vector2(330.0, 98.0))
	DrawPrimitiveSystemScript.draw_shadow(self, rect.get_center() + Vector2(0.0, 7.0), rect.size + Vector2(20.0, 12.0), 0.13 * alpha)
	draw_rect(rect, Color(1.0, 1.0, 1.0, 0.90 * alpha), true)
	draw_rect(Rect2(rect.position, Vector2(8.0, rect.size.y)), Color(1.0, 0.48, 0.78, 0.86 * alpha), true)
	draw_rect(rect, Color(1.0, 0.48, 0.78, 0.65 * alpha), false, 2)
	_draw_text_item({"pos": rect.position + Vector2(20.0, 29.0), "text": String(song_chorus_result_data.get("title", "サビタイム RESULT")), "width": int(rect.size.x - 40.0), "size": 17, "fontWeight": "black", "color": Color("#70436d")}, "", HORIZONTAL_ALIGNMENT_LEFT)
	for i in range(mini(lines.size(), 2)):
		_draw_text_item({"pos": rect.position + Vector2(32.0, 56.0 + float(i) * 22.0), "text": String(lines[i]), "width": int(rect.size.x - 48.0), "size": 15, "fontWeight": "bold", "color": Color("#8a6d88")})

func _song_live_heat_bar_color(value: float) -> Color:
	var t := clampf(value, 0.0, 1.0)
	if t < 0.34:
		return Color("#74ecff").lerp(Color("#b4ffe9"), t / 0.34)
	if t < 0.68:
		return Color("#b4ffe9").lerp(Color("#ff8fcb"), (t - 0.34) / 0.34)
	return Color("#ff8fcb").lerp(Color("#ffe873"), (t - 0.68) / 0.32)

func _draw_song_live_heat_hud() -> void:
	if not _is_song_frame():
		return
	if state != "playing" and state != "comment_choice" and state != "gift_choice":
		return
	var ratio := clampf(displayed_song_live_heat / SONG_LIVE_HEAT_MAX, 0.0, 1.0)
	if not song_live_heat_gauge_display_initialized:
		ratio = clampf(song_live_heat / SONG_LIVE_HEAT_MAX, 0.0, 1.0)
	var accent := Color("#8eeaff").lerp(Color("#ff5cad"), ratio)
	var flash := 0.0
	if song_live_heat_level_flash_timer > 0.0:
		flash = clampf(song_live_heat_level_flash_timer, 0.0, 1.0)
	var panel_texture: Texture2D = TextureCacheSystemScript.load_png_texture(raw_png_texture_cache, SONG_LIVE_HEAT_HUD_IMAGE)
	if panel_texture != null:
		var texture_size := panel_texture.get_size()
		var panel_width := 352.0
		var panel_height := panel_width * float(texture_size.y) / maxf(1.0, float(texture_size.x))
		var rect := Rect2(Vector2(FIELD_VIEW.position.x + 4.0, FIELD_VIEW.position.y + 2.0), Vector2(panel_width, panel_height))
		DrawPrimitiveSystemScript.draw_shadow(self, rect.get_center() + Vector2(0.0, 7.0), rect.size + Vector2(18.0, 10.0), 0.10 + flash * 0.06)
		if flash > 0.0:
			draw_rect(rect.grow(3.0), Color(accent.r, accent.g, accent.b, 0.10 * flash), true)
		draw_texture_rect(panel_texture, rect, false, Color(1.0, 1.0, 1.0, 0.99))
		var bar := Rect2(rect.position + Vector2(rect.size.x * 0.096, rect.size.y * 0.655), Vector2(rect.size.x * 0.800, rect.size.y * 0.125))
		var fill_width := maxf(0.0, bar.size.x * ratio)
		if fill_width > 0.0:
			var fill_rect := Rect2(bar.position, Vector2(fill_width, bar.size.y))
			var fill_segments := 14
			for i in range(fill_segments):
				var segment_start := fill_width * float(i) / float(fill_segments)
				var segment_end := fill_width * float(i + 1) / float(fill_segments)
				var segment_rect := Rect2(bar.position + Vector2(segment_start, 0.0), Vector2(maxf(1.0, segment_end - segment_start + 0.75), bar.size.y))
				var segment_color := _song_live_heat_bar_color(ratio * (float(i) + 0.5) / float(fill_segments))
				draw_rect(segment_rect, Color(segment_color.r, segment_color.g, segment_color.b, 0.86), true)
			var fill_color := _song_live_heat_bar_color(ratio)
			draw_rect(Rect2(fill_rect.position, Vector2(fill_rect.size.x, fill_rect.size.y * 0.42)), Color(1.0, 1.0, 1.0, 0.22), true)
			var end_radius := bar.size.y * 0.5
			var start_color := _song_live_heat_bar_color(0.0)
			draw_circle(bar.position + Vector2(end_radius, end_radius), end_radius, Color(start_color.r, start_color.g, start_color.b, 0.86))
			if fill_width > bar.size.y:
				draw_circle(bar.position + Vector2(fill_width - end_radius, end_radius), end_radius, Color(fill_color.r, fill_color.g, fill_color.b, 0.86))
			if flash > 0.0:
				draw_rect(fill_rect.grow(2.0), Color(1.0, 0.74, 0.92, 0.18 * flash), true)
		_draw_text_item({"pos": rect.position + Vector2(rect.size.x * 0.56, rect.size.y * 0.40), "text": "Lv.%d" % song_live_heat_level, "width": int(rect.size.x * 0.18), "size": 21, "fontWeight": "black", "color": Color("#ff4f9d")}, "", HORIZONTAL_ALIGNMENT_CENTER)
		_draw_text_item({"pos": rect.position + Vector2(rect.size.x * 0.70, rect.size.y * 0.39), "text": "%d%%" % roundi(ratio * 100.0), "width": int(rect.size.x * 0.16), "size": 15, "fontWeight": "bold", "color": Color("#806080")}, "", HORIZONTAL_ALIGNMENT_CENTER)
		var scale_text := "♪ 音階 %d/8" % song_note_scale_index
		var scale_color := Color("#70436d")
		if _song_lyrics_lost_active():
			scale_text = "♪ 音階停止"
			scale_color = Color("#d84596")
		_draw_text_item({"pos": rect.position + Vector2(rect.size.x * 0.61, rect.size.y * 0.90), "text": scale_text, "width": int(rect.size.x * 0.28), "size": 12, "fontWeight": "bold", "color": scale_color}, "", HORIZONTAL_ALIGNMENT_RIGHT)
		if song_encore_timer > 0.0:
			_draw_text_item({"pos": rect.position + Vector2(rect.size.x * 0.14, rect.size.y * 0.90), "text": "アンコール %02ds" % ceili(song_encore_timer), "width": int(rect.size.x * 0.42), "size": 12, "fontWeight": "bold", "color": Color("#e43d91")})
		elif song_chorus_timer <= 0.0:
			var next_chorus := maxi(0, int(ceil(song_chorus_next_time - elapsed)))
			_draw_text_item({"pos": rect.position + Vector2(rect.size.x * 0.14, rect.size.y * 0.90), "text": "次のサビまで %02ds" % next_chorus, "width": int(rect.size.x * 0.42), "size": 12, "fontWeight": "bold", "color": Color("#7a587d")})
		return
	var rect := Rect2(Vector2(FIELD_VIEW.position.x + 34.0, FIELD_VIEW.position.y + 14.0), Vector2(232.0, 54.0))
	DrawPrimitiveSystemScript.draw_shadow(self, rect.get_center() + Vector2(0.0, 7.0), rect.size + Vector2(18.0, 10.0), 0.14 + flash * 0.08)
	draw_rect(rect, Color(1.0, 1.0, 1.0, 0.88), true)
	draw_rect(rect.grow(2.0), Color(accent.r, accent.g, accent.b, 0.12 + flash * 0.18), true)
	draw_rect(rect, accent, false, 3)
	_draw_text_item({"pos": rect.position + Vector2(13.0, 22.0), "text": "LIVE HEAT", "width": 104, "size": 15, "fontWeight": "bold", "color": Color("#7a587d")})
	_draw_text_item({"pos": rect.position + Vector2(126.0, 33.0), "text": "Lv.%d" % song_live_heat_level, "width": 88, "size": 28, "fontWeight": "black", "color": Color("#ff54a8")}, "", HORIZONTAL_ALIGNMENT_CENTER)
	var bar := Rect2(rect.position + Vector2(13.0, 42.0), Vector2(rect.size.x - 26.0, 7.0))
	draw_rect(bar, Color("#f2e7fb"), true)
	draw_rect(Rect2(bar.position, Vector2(bar.size.x * ratio, bar.size.y)), accent, true)
	var scale_text := "♪ 音階 %d/8" % song_note_scale_index
	var scale_color := Color("#70436d")
	if _song_lyrics_lost_active():
		scale_text = "♪ 音階停止"
		scale_color = Color("#d84596")
	_draw_text_item({"pos": rect.position + Vector2(146.0, 58.0), "text": scale_text, "width": 80, "size": 13, "fontWeight": "bold", "color": scale_color}, "", HORIZONTAL_ALIGNMENT_RIGHT)
	if song_encore_timer > 0.0:
		_draw_text_item({"pos": rect.position + Vector2(16.0, 58.0), "text": "アンコール %02ds" % ceili(song_encore_timer), "width": 124, "size": 13, "fontWeight": "bold", "color": Color("#e43d91")})
	elif song_chorus_timer <= 0.0:
		var next_chorus := maxi(0, int(ceil(song_chorus_next_time - elapsed)))
		_draw_text_item({"pos": rect.position + Vector2(16.0, 58.0), "text": "次のサビまで %02ds" % next_chorus, "width": 124, "size": 13, "fontWeight": "bold", "color": Color("#7a587d")})

func _draw_song_live_heat_background_overlay(arena: Rect2) -> void:
	var intensity := clampf(float(song_live_heat_level) / 5.0, 0.0, 1.0)
	if song_encore_timer > 0.0:
		intensity = 1.0
	if intensity <= 0.0:
		return
	var pulse := 0.5 + 0.5 * sin(elapsed * 2.8)
	var pink := Color(1.0, 0.50, 0.78, 0.055 + intensity * 0.060)
	var cyan := Color(0.50, 0.92, 1.0, 0.040 + intensity * 0.050)
	draw_rect(arena, pink, true)
	var top_band := Rect2(arena.position, Vector2(arena.size.x, 92.0))
	var bottom_band := Rect2(Vector2(arena.position.x, arena.end.y - 92.0), Vector2(arena.size.x, 92.0))
	draw_rect(top_band, Color(cyan.r, cyan.g, cyan.b, cyan.a * (0.55 + pulse * 0.35)), true)
	draw_rect(bottom_band, Color(pink.r, pink.g, pink.b, pink.a * (0.55 + (1.0 - pulse) * 0.35)), true)
	for i in range(8 + song_live_heat_level * 2):
		var x := arena.position.x + fmod(float(i) * 167.0 + elapsed * (28.0 + intensity * 24.0), arena.size.x)
		var y := arena.end.y - 60.0 - sin(elapsed * 3.0 + float(i)) * 16.0
		var color := Color("#ff8fc8") if i % 2 == 0 else Color("#8eeaff")
		draw_line(Vector2(x, y + 28.0), Vector2(x + 10.0, y - 30.0), Color(color.r, color.g, color.b, 0.28 + intensity * 0.30), 4.0)
	if song_encore_timer > 0.0:
		for i in range(7):
			var angle := elapsed * 0.45 + float(i) * TAU / 7.0
			var pos := arena.get_center() + Vector2(cos(angle), sin(angle)) * Vector2(arena.size.x * 0.40, arena.size.y * 0.34)
			draw_circle(pos, 4.0 + pulse * 3.0, Color(1.0, 1.0, 1.0, 0.34))

func _draw_outlined_text(pos: Vector2, text: String, width: int, size: int, color: Color, outline: Color, alignment = HORIZONTAL_ALIGNMENT_LEFT) -> void:
	for offset in [Vector2(-1.5, 0.0), Vector2(1.5, 0.0), Vector2(0.0, -1.5), Vector2(0.0, 1.5), Vector2(-1.1, -1.1), Vector2(1.1, -1.1), Vector2(-1.1, 1.1), Vector2(1.1, 1.1)]:
		_draw_text_item({"pos": pos + offset, "text": text, "width": width, "size": size, "fontWeight": "black", "color": outline}, "", alignment)
	_draw_text_item({"pos": pos, "text": text, "width": width, "size": size, "fontWeight": "black", "color": color}, "", alignment)

func _draw_song_stage_background(arena: Rect2) -> void:
	draw_rect(arena, Color("#fff8ff"), true)
	draw_rect(arena.grow(-34.0), Color("#fbfdff"), true)
	draw_rect(arena, Color("#ffb6dd"), false, 6)
	draw_rect(arena.grow(-24.0), Color("#91eaff"), false, 3)
	for i in range(6):
		var y := arena.position.y + 260.0 + float(i) * 155.0
		draw_line(Vector2(arena.position.x + 160.0, y), Vector2(arena.end.x - 160.0, y), Color(0.82, 0.72, 0.93, 0.20), 2.0)
	for i in range(10):
		var x := arena.position.x + 240.0 + float(i) * 190.0
		draw_circle(Vector2(x, arena.position.y + 76.0), 14.0, Color("#ffd1ec"))
		draw_circle(Vector2(x + 46.0, arena.end.y - 76.0), 12.0, Color("#9eefff"))
	var stage := Rect2(arena.position + Vector2(170.0, 180.0), arena.size - Vector2(340.0, 330.0))
	draw_rect(stage, Color(1.0, 1.0, 1.0, 0.36), false, 2)
	var monitor := Rect2(Vector2(arena.get_center().x - 180.0, arena.position.y + 84.0), Vector2(360.0, 96.0))
	draw_rect(monitor, Color("#2a1b44"), true)
	draw_rect(monitor, Color("#ffd1ec"), false, 3)
	_draw_text_item({"pos": monitor.position + Vector2(0.0, 61.0), "text": "LIVE STAGE", "width": int(monitor.size.x), "size": 30, "fontWeight": "black", "color": Color("#ffffff")}, "", HORIZONTAL_ALIGNMENT_CENTER)
	for side in [-1.0, 1.0]:
		var speaker := Rect2(Vector2(arena.get_center().x + side * 850.0 - 48.0, arena.position.y + 260.0), Vector2(96.0, 540.0))
		draw_rect(speaker, Color("#37204f"), true)
		draw_rect(speaker, Color("#d7b9ff"), false, 3)
		for j in range(3):
			draw_circle(speaker.position + Vector2(48.0, 96.0 + float(j) * 150.0), 34.0, Color("#8eeaff"))
			draw_circle(speaker.position + Vector2(48.0, 96.0 + float(j) * 150.0), 20.0, Color("#2a1b44"))

func _draw_drawing_stage_background(arena: Rect2) -> void:
	draw_rect(arena.grow(80.0), Color("#f5f7ff"), true)
	draw_rect(arena, Color("#fff8fb"), true)
	draw_rect(arena, Color("#83e8f2"), false, 7.0)
	draw_rect(arena.grow(-26.0), Color("#ffc0db"), false, 4.0)
	var paper := arena.grow(-132.0)
	draw_rect(paper, Color("#fffdf7"), true)
	draw_rect(paper, Color(1.0, 0.64, 0.78, 0.38), false, 3.0)
	for i in range(1, int(paper.size.x / 96.0)):
		var x := paper.position.x + float(i) * 96.0
		draw_line(Vector2(x, paper.position.y), Vector2(x, paper.end.y), Color(0.67, 0.86, 0.96, 0.14), 1.0)
	for i in range(1, int(paper.size.y / 96.0)):
		var y := paper.position.y + float(i) * 96.0
		draw_line(Vector2(paper.position.x, y), Vector2(paper.end.x, y), Color(1.0, 0.64, 0.78, 0.13), 1.0)
	var progress_ratio := clampf(drawing_progress / 100.0, 0.0, 1.0)
	if progress_ratio > 0.0:
		draw_rect(Rect2(paper.position, Vector2(paper.size.x * progress_ratio, paper.size.y)), Color(1.0, 0.70, 0.88, 0.045 + progress_ratio * 0.035), true)
		var sketch_alpha := 0.08 + progress_ratio * 0.12
		var stroke_count := clampi(int(4.0 + progress_ratio * 10.0), 4, 14)
		for i in range(stroke_count):
			var t := float(i) / float(maxi(1, stroke_count - 1))
			var y := paper.position.y + paper.size.y * (0.18 + 0.62 * fposmod(t * 1.37, 1.0))
			var x0 := paper.position.x + paper.size.x * (0.12 + 0.15 * sin(t * TAU))
			var x1 := paper.position.x + paper.size.x * (0.72 + 0.16 * cos(t * TAU * 0.7))
			var color := Color(0.97, 0.45, 0.76, sketch_alpha) if i % 2 == 0 else Color(0.34, 0.78, 1.0, sketch_alpha)
			draw_line(Vector2(x0, y), Vector2(x1, y + 28.0 * sin(t * TAU * 1.8)), color, 2.0, true)
		if drawing_progress >= 75.0:
			for i in range(6):
				var px := paper.position.x + paper.size.x * (0.18 + 0.64 * fposmod(float(i) * 0.37, 1.0))
				var py := paper.position.y + paper.size.y * (0.18 + 0.62 * fposmod(float(i) * 0.23, 1.0))
				var glow := 0.55 + 0.45 * sin(elapsed * 2.2 + float(i) * 1.4)
				draw_circle(Vector2(px, py), 3.0 + glow * 2.0, Color(1.0, 0.95, 0.45, 0.16 + glow * 0.14))
	var top_band := Rect2(arena.position, Vector2(arena.size.x, 132.0))
	var bottom_band := Rect2(Vector2(arena.position.x, arena.end.y - 132.0), Vector2(arena.size.x, 132.0))
	var left_band := Rect2(arena.position, Vector2(116.0, arena.size.y))
	var right_band := Rect2(Vector2(arena.end.x - 116.0, arena.position.y), Vector2(116.0, arena.size.y))
	draw_rect(top_band, Color("#f0e6ff"), true)
	draw_rect(bottom_band, Color("#fff0c9"), true)
	draw_rect(left_band, Color("#e7fbff"), true)
	draw_rect(right_band, Color("#fff1f9"), true)
	for x in range(0, 9):
		var pos := arena.position + Vector2(210.0 + float(x) * 210.0, 64.0)
		var color := Color("#ff87c0") if x % 2 == 0 else Color("#72dcff")
		draw_circle(pos, 18.0, Color(color.r, color.g, color.b, 0.38))
		draw_circle(pos, 8.0, Color("#ffffff"))
	for x in range(0, 10):
		var pos := Vector2(arena.position.x + 180.0 + float(x) * 190.0, arena.end.y - 60.0)
		draw_rect(Rect2(pos - Vector2(38.0, 14.0), Vector2(76.0, 28.0)), Color("#ffffff"), true)
		draw_rect(Rect2(pos - Vector2(38.0, 14.0), Vector2(76.0, 28.0)), Color("#ffb6d9"), false, 2.0)
	var monitor := Rect2(Vector2(arena.get_center().x - 190.0, arena.position.y + 32.0), Vector2(380.0, 76.0))
	draw_rect(monitor, Color("#f9fbff"), true)
	draw_rect(monitor, Color("#93e9ff"), false, 3.0)
	_draw_text_item({"pos": monitor.position + Vector2(0.0, 52.0), "text": "CANVAS LIVE", "width": int(monitor.size.x), "size": 24, "fontWeight": "black", "color": Color("#ee5d9f")}, "", HORIZONTAL_ALIGNMENT_CENTER)
	for prop_value in MapBackgroundSystemScript.prop_collision_rects_for_data(_current_map_data()):
		var prop: Rect2 = prop_value as Rect2
		DrawPrimitiveSystemScript.draw_shadow(self, prop.get_center() + Vector2(0.0, 8.0), prop.size + Vector2(18.0, 10.0), 0.15)
		draw_rect(prop, Color("#ffffff"), true)
		draw_rect(prop, Color("#d0b8ff"), false, 3.0)
		if prop.size.x > prop.size.y:
			draw_line(prop.position + Vector2(16.0, prop.size.y * 0.5), prop.end - Vector2(16.0, prop.size.y * 0.5), Color("#ff8fc8"), 4.0, true)
		else:
			draw_circle(prop.get_center(), minf(prop.size.x, prop.size.y) * 0.22, Color("#8eeaff"))

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
