extends Node2D

const CommentSystemScript := preload("res://scripts/systems/comment_system.gd")
const GiftSystemScript := preload("res://scripts/systems/gift_system.gd")
const WeaponSystemScript := preload("res://scripts/systems/weapon_system.gd")
const EnemySystemScript := preload("res://scripts/systems/enemy_system.gd")
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
const PlayerSystemScript := preload("res://scripts/systems/player_system.gd")
const SpawnerSystemScript := preload("res://scripts/systems/spawner_system.gd")
const DamageSystemScript := preload("res://scripts/systems/damage_system.gd")
const ModifierSystemScript := preload("res://scripts/systems/modifier_system.gd")
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
var player_idle_sprite: Texture2D
var player_run_sprite: Texture2D
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
var equipment_weapon_timers: Dictionary = {}
var hit_fx: Array = []
var player_weapons: Array = []
var player_accessories: Array = []
var chat_lines: Array[String] = []
var active_effects: Array[String] = []
var active_effect_rates: Dictionary = {}

var state := "title"
var previous_state := "playing"
var quick_test_mode := false
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
var player_facing_x := 1.0
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
var result_showing_ranking := false
var debug_key_latch: Dictionary = {}
var pause_escape_down := false
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
var ban_hammer_weapon_sprite: Texture2D

func _ready() -> void:
	rng.randomize()
	ban_hammer_weapon_sprite = _load_texture_from_png("res://assets/generated/ban_hammer_weapon_sprite_v1/clean.png")
	data_repo = RunStateSystemScript.load_boot_data_for_target(self, character_sprite_cache)
	_build_ui()
	ChatSystemScript.seed_box_for_target(self, chat_box, "normal")
	_update_ui()

func _process(delta: float) -> void:
	ChatSystemScript.update_timer_for_target(self, delta, rng, chat_box)
	StateFlowSystemScript.update_pause_input_for_target(self)
	if _update_front_state(delta):
		return
	_handle_debug_keys()
	_update_active_state(delta)
	_update_ui()
	queue_redraw()

func _update_active_state(delta: float) -> void:
	StateFlowSystemScript.apply_active_update(state, {
		"comment_choice": Callable(self, "_update_comment_choice").bind(delta),
		"gift_choice": Callable(self, "_update_gift_choice"),
		"world": Callable(self, "_update_world").bind(delta)
	})

func _update_front_state(delta: float) -> bool:
	var title_action: String = DebugSystemScript.title_action(debug_key_latch) if state == "title" else ""
	var result_action: String = DebugSystemScript.result_action(debug_key_latch) if state == "result" else ""
	var result: Dictionary = StateFlowSystemScript.front_state_action_for_target(self, delta, title_action, result_action)
	if not bool(result["handled"]):
		return false
	var action: String = String(result["action"])
	StateFlowSystemScript.apply_front_action(action, {
		"start_character_select": Callable(self, "_start_character_select"),
		"update_character_select": Callable(self, "_update_character_select"),
		"update_stream_frame_select": Callable(self, "_update_stream_frame_select"),
		"copy_result": Callable(self, "_copy_result"),
		"toggle_ranking": Callable(self, "_toggle_result_ranking"),
		"restart": Callable(self, "_restart")
	})
	_update_ui()
	queue_redraw()
	return true

func _draw_screen_backdrop() -> void:
	var data: Dictionary = DrawDataSystemScript.screen_backdrop_data()
	_draw_mask_rect(data["rect"] as Rect2, data["color"] as Color)

func _draw_modal_dim() -> void:
	var data: Dictionary = DrawDataSystemScript.modal_dim_data(ARENA)
	_draw_mask_rect(data["rect"] as Rect2, data["color"] as Color)

func _draw() -> void:
	_draw_world_layer()
	_draw_overlay_layer()
	_draw_toast()

func _draw_world_layer() -> void:
	_draw_screen_backdrop()
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

func _draw_overlay_layer() -> void:
	if StateFlowSystemScript.has_modal_overlay(state):
		_draw_modal_dim()
	var overlay_view: String = StateFlowSystemScript.overlay_view(state)
	if overlay_view == "title":
		_draw_title_overlay()
	elif overlay_view == "character_select":
		_draw_character_select_overlay()
	elif overlay_view == "stream_frame_select":
		_draw_stream_frame_select_overlay()
	elif overlay_view == "tutorial":
		_draw_tutorial_overlay_v2()
	elif overlay_view == "choice":
		_draw_choice_backplate()
	for special_overlay in DrawDataSystemScript.special_overlay_views(self):
		if String(special_overlay) == "comment_storm":
			_draw_comment_storm()
		elif String(special_overlay) == "zoom_in":
			_draw_zoom_mask()
		elif String(special_overlay) == "horror":
			_draw_horror_mask()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if StateFlowSystemScript.shows_comment_countdown(state):
		_draw_comment_countdown()

func _build_ui() -> void:
	var nodes: Dictionary = UiBuilderSystemScript.build_ui(self, Callable(self, "_choose_index"), UiStyleSystemScript.initial_result_panel_style())
	banner_label = nodes["bannerLabel"] as Label
	choice_box = nodes["choiceBox"] as HBoxContainer
	choice_buttons.clear()
	for button_item in (nodes["choiceButtons"] as Array):
		choice_buttons.append(button_item as Button)
	chat_box = nodes["chatBox"] as VBoxContainer
	status_label = nodes["statusLabel"] as Label
	result_panel = nodes["resultPanel"] as PanelContainer
	result_label = nodes["resultLabel"] as Label

func _update_world(delta: float) -> void:
	elapsed += delta
	if elapsed >= RunStateSystemScript.run_length(quick_test_mode, QUICK_RUN_LENGTH, NORMAL_RUN_LENGTH):
		_finish_run("配信成功！3分間生き残った。")
		return

	var effect_result: Dictionary = ModifierSystemScript.update_effect_timer_for_target(self, delta)
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
		var choice_result: Dictionary = CommentSystemScript.start_choice_ui_for_target(self, comments, rng, CHOICE_TIME, choice_box)
		chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": [String(choice_result["chat"])]}, chat_box)
		_refresh_choice_cards()
		return true
	return false

func _update_stream_frame_events(delta: float) -> void:
	var marshmallow_feedback: Dictionary = MarshmallowSystemScript.update_auto_spawn_if_enabled_for_target(self, current_stream_frame, marshmallow_data, rng, ARENA, effect_walls)
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, marshmallow_feedback, chat_box)
	_update_genre_event(delta)

func _update_world_systems(delta: float) -> void:
	_update_player(delta)
	_apply_damage_feedback(ModifierSystemScript.update_stage_hazard_damage_for_target(self, ARENA))
	_update_spawning(delta)
	_update_enemies(delta)
	_update_weapons(delta)
	var exp_result: Dictionary = ExpSystemScript.update_world_for_target(self, delta)
	if bool(exp_result["levelUp"]):
		_start_gift_choice()
	_update_marshmallow(delta)
	WeaponSystemScript.update_hit_fx_for_target(self, delta)

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
		_start_stream_frame_select()

func _start_stream_frame_select() -> void:
	var result: Dictionary = StreamFrameSystemScript.start_selection_for_target(self, choice_box, result_panel, stream_frames)
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, {"chats": [String(result["chat"])]}, chat_box)
	if bool(result["restart"]):
		_restart()

func _update_stream_frame_select() -> void:
	var result: Dictionary = StreamFrameSystemScript.update_selection_for_target(self, debug_key_latch, stream_frames)
	if bool(result["backToCharacterSelect"]):
		_start_character_select()
		return
	if bool(result["restart"]):
		_restart()

func _update_player(delta: float) -> void:
	var result: Dictionary = PlayerSystemScript.update_for_target(self, delta, ARENA)
	if bool(result["stoppedDamage"]):
		_damage_player("stopped moving")

func _update_spawning(delta: float) -> void:
	SpawnerSystemScript.update_for_target(self, delta, ARENA, rng)

func _update_enemies(delta: float) -> void:
	var result: Dictionary = EnemySystemScript.update_world_for_target(self, delta, rng, ARENA)
	_apply_damage_feedback(DamageSystemScript.apply_damage_events_for_target(self, result.get("damageEvents", []) as Array))

func _update_weapons(delta: float) -> void:
	var result: Dictionary = WeaponSystemScript.update_for_target(self, delta, ARENA, rng)
	var feedback: Dictionary = WeaponSystemScript.apply_update_result_for_target(self, result, ARENA, rng)
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, feedback, chat_box)

func _damage_player(source: String) -> void:
	_apply_damage_feedback(DamageSystemScript.apply_damage_sources_for_target(self, [source]))

func _apply_damage_feedback(feedback: Dictionary) -> void:
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, feedback, chat_box)
	if bool(feedback["dead"]):
		_finish_run(String(feedback["deathReason"]))

func _update_comment_choice(delta: float) -> void:
	var result: Dictionary = CommentSystemScript.update_choice_input_for_target(self, delta, debug_key_latch, rng)
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, result, chat_box)
	if bool(result["refresh"]):
		_refresh_choice_cards()
		return
	if int(result["chooseIndex"]) >= 0:
		_choose_comment(int(result["chooseIndex"]))

func _choose_comment(index: int) -> void:
	var result: Dictionary = CommentSystemScript.choose_comment_with_feedback_for_target(self, index, rng, ARENA, COMMENT_INTERVAL, choice_box, genre_events)
	if not bool(result["selected"]):
		return
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, result, chat_box)

func _start_gift_choice() -> void:
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
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, result, chat_box)

func _update_marshmallow(delta: float) -> void:
	var feedback: Dictionary = MarshmallowSystemScript.update_world_for_target(self, delta, ARENA, rng)
	chat_lines = ChatSystemScript.apply_feedback_for_target(self, feedback, chat_box)
	if bool(feedback["levelUp"]):
		_start_gift_choice()
	MarshmallowSystemScript.update_effect_timers_for_target(self, delta)

func _choose_index(index: int) -> void:
	if state == "comment_choice":
		_choose_comment(index)
	elif state == "gift_choice":
		_choose_gift(index)

func _refresh_choice_cards() -> void:
	ChoiceCardSystemScript.refresh_for_target(self, choice_buttons, state)

func _update_ui() -> void:
	HudTextSystemScript.update_labels_for_target(
		self,
		status_label,
		banner_label,
		DisplayTextSystemScript.comment_barrage_label(comment_barrage_setting),
		GiftSystemScript.arrival_text(gift_hype),
		GenreEventSystemScript.label(active_genre_event),
		GenreEventSystemScript.label(next_known_genre_event)
	)
func _finish_run(reason: String) -> void:
	if state == "result":
		return
	result_showing_ranking = false
	ResultSystemScript.open_result_ui_for_target(reason, self, quick_test_mode, choice_box, result_panel, result_label, heart_cards, chat_box)

func _copy_result() -> void:
	var result: Dictionary = ResultSystemScript.copy_share_text_for_target(self)
	if bool(result["copied"]):
		var text: String = String(result_label.text)
		if not text.contains("結果をコピーしました！"):
			result_label.text = text + "\n結果をコピーしました！"

func _toggle_result_ranking() -> void:
	result_showing_ranking = not result_showing_ranking
	if result_showing_ranking:
		result_label.text = RankingSystemScript.format_ranking_screen() + "\n\nR：リザルトへ戻る    Enter / Space：もう一回"
	else:
		result_label.text = last_result_text

func _restart() -> void:
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
	var points: PackedVector2Array = PackedVector2Array()
	for i in range(18):
		var a: float = TAU * float(i) / 18.0
		points.append(pos + Vector2(cos(a) * size.x * 0.5, sin(a) * size.y * 0.5))
	_draw_colored_poly(points, Color(0.0, 0.0, 0.0, alpha))

func _draw_spark(pos: Vector2, size: float, color: Color) -> void:
	_draw_line_item({"from": pos + Vector2(-size, 0), "to": pos + Vector2(size, 0), "color": color, "width": 2.0})
	_draw_line_item({"from": pos + Vector2(0, -size), "to": pos + Vector2(0, size), "color": color, "width": 2.0})

func _draw_banana_item(item: Dictionary, color: Color) -> void:
	_draw_fixed_arc(item["pos"] as Vector2, 13.0, 0.2, 2.7, 10, color, 5.0)

func _draw_arena() -> void:
	var background: Dictionary = DrawDataSystemScript.arena_background_data(ARENA)
	for part in DrawDataSystemScript.arena_background_parts(background):
		_draw_arena_part(part as Dictionary)
	var arena_effects: Dictionary = DrawDataSystemScript.arena_effect_data(ARENA, ModifierSystemScript.has_effect_for_target(self,"banana_floor"), effect_pits)
	for part in DrawDataSystemScript.arena_effect_parts(arena_effects):
		_draw_arena_part(part as Dictionary)
	for wall in DrawDataSystemScript.arena_wall_draw_list(effect_walls):
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
	elif kind == "spark":
		var spark_item: Dictionary = part["data"] as Dictionary
		_draw_spark(spark_item["pos"] as Vector2, float(spark_item["size"]), spark_item["color"] as Color)
	elif kind == "banana":
		_draw_banana_item(part["data"] as Dictionary, part["color"] as Color)
	elif kind == "shadow":
		_draw_shadow(part["pos"] as Vector2, part["size"] as Vector2, float(part["alpha"]))
	elif kind == "outline":
		_draw_rect_outline(part["rect"] as Rect2, part["color"] as Color, int(part["width"]))
	elif kind == "line":
		_draw_line_item(part["data"] as Dictionary)

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
	draw_set_transform(sprite_draw["center"] as Vector2, float(sprite_draw["tilt"]), transform_scale)
	draw_texture_rect_region(sprite_draw["texture"] as Texture2D, Rect2(-size * 0.5, size), sprite_draw["sourceRect"] as Rect2, Color(1, 1, 1, float(sprite_draw["alpha"])))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

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
	for enemy in enemies:
		var enemy_draw: Dictionary = DrawDataSystemScript.enemy_draw_data(enemy as Dictionary)
		for part in DrawDataSystemScript.enemy_draw_parts(enemy_draw):
			_draw_enemy_part(part as Dictionary)

func _draw_enemy_body(body: Dictionary) -> void:
	for part in DrawDataSystemScript.enemy_body_parts(body):
		_draw_simple_draw_part(body, part as Dictionary)

func _draw_enemy_part(part: Dictionary) -> void:
	var kind: String = String(part["kind"])
	if kind == "shadow":
		var shadow: Dictionary = part["data"] as Dictionary
		_draw_shadow(shadow["pos"] as Vector2, shadow["size"] as Vector2, float(shadow["alpha"]))
	elif kind == "body":
		_draw_enemy_body(part["data"] as Dictionary)
	elif kind == "face":
		_draw_enemy_face(part["data"] as Dictionary)
	elif kind == "bar":
		_draw_enemy_hp_bar(part["data"] as Dictionary)

func _draw_enemy_face(face: Dictionary) -> void:
	for part in DrawDataSystemScript.enemy_face_parts():
		_draw_simple_draw_part(face, part as Dictionary)

func _draw_enemy_hp_bar(bar: Dictionary) -> void:
	for part in DrawDataSystemScript.enemy_hp_bar_parts():
		_draw_simple_draw_part(bar, part as Dictionary)

func _draw_exp() -> void:
	for orb in DrawDataSystemScript.exp_orbs_draw_data(exp_orbs, elapsed):
		_draw_exp_orb(orb as Dictionary)

func _draw_exp_orb(data: Dictionary) -> void:
	for part in DrawDataSystemScript.exp_orb_parts():
		_draw_simple_draw_part(data, part as Dictionary)

func _draw_mallow() -> void:
	for item in DrawDataSystemScript.marshmallow_draw_list(marshmallows, elapsed, maro_appraisal):
		_draw_mallow_item(item as Dictionary)

func _draw_mallow_item(visual: Dictionary) -> void:
	for part in DrawDataSystemScript.marshmallow_parts(visual):
		_draw_simple_draw_part(visual, part as Dictionary)

func _draw_enemy_bullets() -> void:
	for bullet in DrawDataSystemScript.bullet_draw_data(enemy_bullets, false):
		_draw_bullet_item(bullet as Dictionary)

func _draw_player_bullets() -> void:
	for bullet in DrawDataSystemScript.bullet_draw_data(player_bullets, true):
		_draw_bullet_item(bullet as Dictionary)

func _draw_bullet_item(item: Dictionary) -> void:
	for part in DrawDataSystemScript.bullet_parts():
		_draw_simple_draw_part(item, part as Dictionary)

func _draw_boomerang() -> void:
	for item in DrawDataSystemScript.boomerang_draw_data_for_weapon(player_pos, current_weapon, boomerang_level, hammer_range, elapsed):
		_draw_boomerang_item(item as Dictionary)

func _draw_boomerang_item(visual: Dictionary) -> void:
	for part in DrawDataSystemScript.boomerang_parts():
		_draw_simple_draw_part(visual, part as Dictionary)

func _draw_hit_fx() -> void:
	for fx in DrawDataSystemScript.hit_fx_draw_data(hit_fx):
		_draw_hit_fx_item(fx as Dictionary)

func _draw_hit_fx_item(data: Dictionary) -> void:
	for part in DrawDataSystemScript.hit_fx_parts(data):
		_draw_simple_draw_part(data, part as Dictionary)
	if bool(data.get("showHammer", false)):
		_draw_rotated_texture(ban_hammer_weapon_sprite, data["hammerPos"] as Vector2, data["hammerSize"] as Vector2, float(data["hammerAngle"]), float(data["hammerAlpha"]))

func _draw_simple_draw_part(data: Dictionary, part: Dictionary) -> void:
	var kind: String = String(part["kind"])
	var prefix: String = String(part.get("prefix", ""))
	if kind == "line":
		var width: float = float(part["width"]) if part.has("width") else float(data[String(part.get("widthKey", prefix + "Width" if prefix != "" else "width"))])
		var color_override: Variant = null
		if part.has("colorKey"):
			color_override = data[String(part["colorKey"])] as Color
		_draw_line_item(data, prefix, width, color_override)
	elif kind == "panel":
		_draw_panel_rect(data)
	elif kind == "circle":
		_draw_circle_item(
			data,
			prefix,
			String(part.get("radiusPrefix", "")),
			bool(part.get("filled", true)),
			float(part.get("width", -1.0)),
			String(part.get("colorKey", ""))
		)
	elif kind == "rect":
		_draw_rect_item(data, prefix)
	elif kind == "rect_keys":
		_draw_rect_item({"rect": data[String(part["rectKey"])] as Rect2, "color": data[String(part["colorKey"])] as Color})
	elif kind == "bar":
		_draw_bar_item(data)
	elif kind == "arc":
		if part.has("pos"):
			_draw_fixed_arc(part["pos"] as Vector2, float(part["radius"]), float(part["start"]), float(part["end"]), int(part["points"]), part["color"] as Color, float(part["width"]))
		else:
			_draw_arc_item(data, prefix)
	elif kind == "text":
		var alignment: int = int(part.get("alignment", HORIZONTAL_ALIGNMENT_LEFT))
		var text_color_override: Variant = null
		if part.has("colorKey"):
			text_color_override = data[String(part["colorKey"])] as Color
		_draw_text_item(data, prefix, alignment, text_color_override, String(part.get("text", "")))
	elif kind == "dot":
		_draw_circle_item({"pos": part["pos"] as Vector2, "radius": data["dotRadius"], "color": data["dotColor"] as Color})
	elif kind == "time":
		_draw_text_item(data, "time", HORIZONTAL_ALIGNMENT_LEFT, null, "%02d" % int(ceil(float(data["timeLeft"]))))
	elif kind == "shadow":
		_draw_shadow(data["shadowPos"] as Vector2, data["shadowSize"] as Vector2, float(data["shadowAlpha"]))
	elif kind == "polygon":
		_draw_polygon_item(data[String(part["pointsKey"])] as PackedVector2Array, data[String(part["colorsKey"])] as PackedColorArray)
	elif kind == "polyline":
		_draw_polyline_item(data[String(part["pointsKey"])] as PackedVector2Array, data[String(part["colorKey"])] as Color, float(data[String(part["widthKey"])]))

func _draw_frames() -> void:
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
		"ngStock": ng_stock,
		"heartPending": heart_pending,
		"commentTimer": comment_timer,
		"currentComment": current_comment,
		"expValue": exp_value
	})
	var frame: Dictionary = data["frame"] as Dictionary
	_draw_prefixed_panel_rect(frame, "side")
	_draw_line_item(frame, "sideDivider")
	_draw_text_item(frame, "viewer")
	_draw_prefixed_panel_rect(frame, "hud")
	for metric in (data["metrics"] as Array):
		for part in DrawDataSystemScript.hud_metric_parts():
			_draw_simple_draw_part(metric as Dictionary, part as Dictionary)
	for gauge in (data["gauges"] as Array):
		for part in DrawDataSystemScript.hud_gauge_parts():
			_draw_simple_draw_part(gauge as Dictionary, part as Dictionary)

func _draw_comment_countdown() -> void:
	if state == "comment_choice":
		return
	var left: float = maxf(0.0, comment_timer)
	var data: Dictionary = DrawDataSystemScript.comment_countdown_data(left, COMMENT_INTERVAL, elapsed)
	for part in DrawDataSystemScript.comment_countdown_parts(data):
		_draw_simple_draw_part(data, part as Dictionary)

func _draw_title_overlay() -> void:
	var barrage_label: String = DisplayTextSystemScript.comment_barrage_label(comment_barrage_setting)
	var data: Dictionary = DrawDataSystemScript.title_overlay_data(barrage_label, screen_shake_enabled)
	for part in DrawDataSystemScript.title_overlay_parts(data):
		_draw_overlay_part(part as Dictionary)

func _draw_character_select_overlay() -> void:
	var data: Dictionary = DrawDataSystemScript.character_select_overlay_data(characters, weapons)
	_draw_selection_overlay(data, selected_character_index, "character")

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
	var data: Dictionary = DrawDataSystemScript.stream_frame_select_overlay_data(stream_frames)
	_draw_selection_overlay(data, selected_stream_frame_index, "stream")

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
	var data: Dictionary = DrawDataSystemScript.choice_backplate_data()
	_draw_panel_rect(data)

func _draw_comment_storm() -> void:
	var samples: Array[String] = DisplayTextSystemScript.comment_storm_samples()
	for item in DrawDataSystemScript.comment_storm_draw_data(ARENA, elapsed, comment_barrage_setting, kuso_chat_timer > 0.0, samples):
		var data: Dictionary = item as Dictionary
		_draw_text_item(data)

func _draw_tutorial_overlay_v2() -> void:
	var data: Dictionary = DrawDataSystemScript.tutorial_overlay_data()
	for part in DrawDataSystemScript.tutorial_overlay_parts(data):
		_draw_overlay_part(part as Dictionary)

func _draw_zoom_mask() -> void:
	var data: Dictionary = DrawDataSystemScript.zoom_mask_data(ARENA)
	for part in DrawDataSystemScript.zoom_mask_parts(data):
		_draw_overlay_part(part as Dictionary)

func _draw_horror_mask() -> void:
	var data: Dictionary = DrawDataSystemScript.horror_mask_data(elapsed)
	for part in DrawDataSystemScript.horror_mask_parts(data, ARENA):
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

func _draw_colored_poly(points: PackedVector2Array, color: Color) -> void:
	draw_colored_polygon(points, color)

func _draw_polygon_item(points: PackedVector2Array, colors: PackedColorArray) -> void:
	draw_polygon(points, colors)

func _draw_polyline_item(points: PackedVector2Array, color: Color, width: float) -> void:
	draw_polyline(points, color, width)

func _draw_panel_rect(data: Dictionary) -> void:
	var rect: Rect2 = data["rect"] as Rect2
	draw_rect(rect, data["fill"] as Color)
	draw_rect(rect, data["border"] as Color, false, int(data["borderWidth"]))

func _draw_prefixed_panel_rect(data: Dictionary, prefix: String) -> void:
	var rect: Rect2 = data[prefix + "Rect"] as Rect2
	draw_rect(rect, data[prefix + "Fill"] as Color)
	_draw_rect_outline(rect, data[prefix + "Border"] as Color, int(data[prefix + "BorderWidth"]))

func _draw_rect_outline(rect: Rect2, color: Color, width: int) -> void:
	draw_rect(rect, color, false, width)

func _draw_bar_item(item: Dictionary) -> void:
	_draw_rect_item(item, "back")
	_draw_rect_item(item, "fill")

func _draw_rect_item(item: Dictionary, prefix: String = "") -> void:
	var key_prefix: String = prefix
	var rect_key: String = key_prefix + "Rect" if key_prefix != "" else "rect"
	var color_key: String = key_prefix + "Color" if key_prefix != "" else "color"
	draw_rect(item[rect_key] as Rect2, item[color_key] as Color)

func _draw_circle_item(item: Dictionary, prefix: String = "", radius_prefix: String = "", filled: bool = true, width: float = -1.0, color_key_override: String = "") -> void:
	var key_prefix: String = prefix
	var radius_key_prefix: String = radius_prefix if radius_prefix != "" else key_prefix
	var pos_key: String = key_prefix + "Pos" if key_prefix != "" else "pos"
	var radius_key: String = radius_key_prefix + "Radius" if radius_key_prefix != "" else "radius"
	var color_key: String = key_prefix + "Color" if key_prefix != "" else "color"
	if color_key_override != "":
		color_key = color_key_override
	if key_prefix != "" and not item.has(pos_key) and item.has(key_prefix):
		pos_key = key_prefix
	if key_prefix != "" and not item.has(pos_key):
		pos_key = "pos"
	if key_prefix != "" and not item.has(color_key):
		color_key = "color"
	if not item.has(radius_key):
		radius_key = "radius"
	var width_value: float = width if width >= 0.0 else -1.0
	draw_circle(item[pos_key] as Vector2, float(item[radius_key]), item[color_key] as Color, filled, width_value)

func _draw_line_item(item: Dictionary, prefix: String = "", width: float = -1.0, color_override: Variant = null) -> void:
	var key_prefix: String = prefix
	var start_key: String = key_prefix + "Start" if key_prefix != "" else "start"
	var end_key: String = key_prefix + "End" if key_prefix != "" else "end"
	var color_key: String = key_prefix + "Color" if key_prefix != "" else "color"
	var width_key: String = key_prefix + "Width" if key_prefix != "" else "width"
	if not item.has(start_key):
		start_key = "from" if item.has("from") else "start"
	if not item.has(end_key):
		end_key = "to" if item.has("to") else "end"
	if key_prefix != "" and not item.has(color_key):
		color_key = "color"
	var color_value: Color = color_override as Color if color_override != null else item[color_key] as Color
	var width_value: float = width if width >= 0.0 else float(item[width_key])
	draw_line(item[start_key] as Vector2, item[end_key] as Vector2, color_value, width_value)

func _draw_arc_item(item: Dictionary, prefix: String) -> void:
	_draw_fixed_arc(item["pos"] as Vector2, float(item[prefix + "Radius"]), float(item[prefix + "Start"]), float(item[prefix + "End"]), int(item[prefix + "Points"]), item[prefix + "Color"] as Color, float(item[prefix + "Width"]))

func _draw_fixed_arc(pos: Vector2, radius: float, start_angle: float, end_angle: float, points: int, color: Color, width: float) -> void:
	draw_arc(pos, radius, start_angle, end_angle, points, color, width)

func _load_texture_from_png(path: String) -> Texture2D:
	var image := Image.new()
	if image.load(path) != OK:
		return null
	return ImageTexture.create_from_image(image)

func _draw_rotated_texture(texture: Texture2D, center: Vector2, size: Vector2, angle: float, alpha: float = 1.0) -> void:
	if texture == null:
		return
	draw_set_transform(center, angle, Vector2.ONE)
	draw_texture_rect(texture, Rect2(-size * 0.5, size), false, Color(1, 1, 1, alpha))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_text_item(item: Dictionary, prefix: String = "", alignment = HORIZONTAL_ALIGNMENT_LEFT, override_color: Variant = null, override_text: String = "") -> void:
	var key_prefix: String = prefix
	var pos_key: String = key_prefix + "Pos" if key_prefix != "" else "pos"
	var text_key: String = key_prefix if key_prefix != "" else "text"
	if key_prefix != "" and item.has(key_prefix + "Text"):
		text_key = key_prefix + "Text"
	elif key_prefix != "" and not item.has(text_key):
		text_key = key_prefix + "Text"
	var width_key: String = key_prefix + "Width" if key_prefix != "" else "width"
	var size_key: String = key_prefix + "Size" if key_prefix != "" else "size"
	var color_key: String = key_prefix + "Color" if key_prefix != "" else "color"
	var text_value: String = override_text if override_text != "" else String(item[text_key])
	var color_value: Color = override_color as Color if override_color != null else item[color_key] as Color
	draw_string(
		ThemeDB.fallback_font,
		item[pos_key] as Vector2,
		text_value,
		alignment,
		int(item.get(width_key, -1)),
		int(item[size_key]),
		color_value
	)

func _draw_multiline_text_item(item: Dictionary, alignment = HORIZONTAL_ALIGNMENT_LEFT) -> void:
	draw_multiline_string(
		ThemeDB.fallback_font,
		item["pos"] as Vector2,
		String(item["text"]),
		alignment,
		int(item.get("width", -1)),
		int(item["size"]),
		-1,
		item["color"] as Color
	)
