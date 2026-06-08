class_name DebugSystem
extends RefCounted

const DestructibleSystemScript := preload("res://scripts/systems/destructible_system.gd")

static func pressed_actions(latch: Dictionary) -> Array[String]:
	var actions: Array[String] = []
	_add_if_pressed(actions, latch, KEY_C, "comment_now")
	_add_if_pressed(actions, latch, KEY_G, "gift_now")
	_add_if_pressed(actions, latch, KEY_F, "gift_god")
	_add_if_pressed(actions, latch, KEY_R, "gift_flame")
	_add_if_pressed(actions, latch, KEY_F1, "hype_0")
	_add_if_pressed(actions, latch, KEY_F2, "hype_40")
	_add_if_pressed(actions, latch, KEY_F3, "hype_70")
	_add_if_pressed(actions, latch, KEY_F4, "hype_90")
	_add_if_pressed(actions, latch, KEY_F5, "hype_100")
	_add_if_pressed(actions, latch, KEY_Y, "hype_0")
	_add_if_pressed(actions, latch, KEY_O, "hype_90")
	_add_if_pressed(actions, latch, KEY_P, "hype_100")
	_add_if_pressed(actions, latch, KEY_F6, "heart_pending_on")
	_add_if_pressed(actions, latch, KEY_U, "unlock_stream_frames")
	_add_if_pressed(actions, latch, KEY_K, "clear_enemies")
	_add_if_pressed(actions, latch, KEY_I, "toggle_invincible")
	_add_if_pressed(actions, latch, KEY_1, "comment_no_stop")
	_add_if_pressed(actions, latch, KEY_2, "comment_enemy_speed")
	_add_if_pressed(actions, latch, KEY_3, "comment_barrage")
	_add_if_pressed(actions, latch, KEY_4, "jump_30")
	_add_if_pressed(actions, latch, KEY_5, "jump_60")
	_add_if_pressed(actions, latch, KEY_6, "comment_do_everything")
	_add_if_pressed(actions, latch, KEY_Q, "comment_boss")
	_add_if_pressed(actions, latch, KEY_0, "heart_comment_giant")
	_add_if_pressed(actions, latch, KEY_7, "jump_90")
	_add_if_pressed(actions, latch, KEY_8, "jump_120")
	_add_if_pressed(actions, latch, KEY_9, "jump_150")
	_add_if_pressed(actions, latch, KEY_M, "maro_random")
	_add_if_pressed(actions, latch, KEY_X, "maro_bad")
	_add_if_pressed(actions, latch, KEY_Z, "maro_god")
	_add_if_pressed(actions, latch, KEY_V, "maro_expire")
	_add_if_pressed(actions, latch, KEY_B, "spawn_care_package")
	_add_if_pressed(actions, latch, KEY_L, "spawn_long")
	_add_if_pressed(actions, latch, KEY_J, "spawn_clipper")
	_add_if_pressed(actions, latch, KEY_E, "clear_effects")
	_add_if_pressed(actions, latch, KEY_BACKSPACE, "reset_ranking")
	return actions

static func title_action(latch: Dictionary) -> String:
	if _pressed(latch, KEY_UP) or _pressed(latch, KEY_W):
		return "title_up"
	if _pressed(latch, KEY_DOWN) or _pressed(latch, KEY_S):
		return "title_down"
	if _pressed(latch, KEY_1):
		return "title_new_game"
	if _pressed(latch, KEY_2):
		return "title_ranking"
	if _pressed(latch, KEY_3):
		return "title_options"
	if _pressed(latch, KEY_R):
		return "toggle_relay"
	if _pressed(latch, KEY_T):
		return "toggle_mode"
	if _pressed(latch, KEY_B):
		return "comment_barrage"
	if _pressed(latch, KEY_N):
		return "screen_shake"
	if _pressed(latch, KEY_U):
		return "unlock_stream_frames"
	if _pressed(latch, KEY_ENTER) or _pressed(latch, KEY_SPACE):
		return "title_select"
	return ""

static func ranking_action(latch: Dictionary) -> String:
	if _pressed(latch, KEY_ESCAPE) or _pressed(latch, KEY_BACKSPACE):
		return "back_to_title"
	if _pressed(latch, KEY_R):
		return "reset_ranking"
	if _pressed(latch, KEY_LEFT) or _pressed(latch, KEY_A):
		return "ranking_tab_left"
	if _pressed(latch, KEY_RIGHT) or _pressed(latch, KEY_D):
		return "ranking_tab_right"
	if _pressed(latch, KEY_UP) or _pressed(latch, KEY_W):
		return "ranking_up"
	if _pressed(latch, KEY_DOWN) or _pressed(latch, KEY_S):
		return "ranking_down"
	if _pressed(latch, KEY_ENTER) or _pressed(latch, KEY_SPACE):
		return "ranking_select"
	return ""

static func options_action(latch: Dictionary) -> String:
	if _pressed(latch, KEY_ESCAPE) or _pressed(latch, KEY_BACKSPACE):
		return "back_to_title"
	if _pressed(latch, KEY_UP) or _pressed(latch, KEY_W):
		return "option_up"
	if _pressed(latch, KEY_DOWN) or _pressed(latch, KEY_S):
		return "option_down"
	if _pressed(latch, KEY_LEFT) or _pressed(latch, KEY_A):
		return "option_left"
	if _pressed(latch, KEY_RIGHT) or _pressed(latch, KEY_D):
		return "option_right"
	if _pressed(latch, KEY_ENTER) or _pressed(latch, KEY_SPACE):
		return "option_select"
	if _pressed(latch, KEY_1):
		return "option_bgm_volume"
	if _pressed(latch, KEY_2):
		return "option_se_volume"
	if _pressed(latch, KEY_3):
		return "option_fullscreen"
	if _pressed(latch, KEY_4):
		return "option_window_size"
	if _pressed(latch, KEY_5):
		return "option_comment_barrage"
	if _pressed(latch, KEY_6):
		return "option_screen_shake"
	if _pressed(latch, KEY_7):
		return "option_tutorial"
	if _pressed(latch, KEY_8):
		return "option_reset"
	if _pressed(latch, KEY_9):
		return "back_to_title"
	return ""

static func result_action(latch: Dictionary) -> String:
	if _pressed(latch, KEY_R):
		return "toggle_ranking"
	if _pressed(latch, KEY_ESCAPE):
		return "back_to_title"
	if _pressed(latch, KEY_UP) or _pressed(latch, KEY_LEFT) or _pressed(latch, KEY_W) or _pressed(latch, KEY_A):
		return "result_prev_button"
	if _pressed(latch, KEY_DOWN) or _pressed(latch, KEY_RIGHT) or _pressed(latch, KEY_S) or _pressed(latch, KEY_D):
		return "result_next_button"
	if _pressed(latch, KEY_ENTER) or _pressed(latch, KEY_SPACE):
		return "result_select_button"
	return ""

static func pause_action(latch: Dictionary) -> String:
	if _pressed(latch, KEY_UP) or _pressed(latch, KEY_W):
		return "pause_up"
	if _pressed(latch, KEY_DOWN) or _pressed(latch, KEY_S):
		return "pause_down"
	if _pressed(latch, KEY_1):
		return "pause_continue"
	if _pressed(latch, KEY_2):
		return "pause_retry"
	if _pressed(latch, KEY_3):
		return "pause_title"
	if _pressed(latch, KEY_ENTER) or _pressed(latch, KEY_SPACE):
		return "pause_select"
	if _pressed(latch, KEY_Y):
		return "pause_confirm"
	if _pressed(latch, KEY_N) or _pressed(latch, KEY_BACKSPACE):
		return "pause_cancel"
	return ""

static func jump_time(action: String, quick_test_mode: bool) -> float:
	if action == "jump_30":
		return 10.0 if quick_test_mode else 30.0
	if action == "jump_60":
		return 20.0 if quick_test_mode else 60.0
	if action == "jump_90":
		return 30.0 if quick_test_mode else 90.0
	if action == "jump_120":
		return 40.0 if quick_test_mode else 120.0
	if action == "jump_150":
		return 50.0 if quick_test_mode else 150.0
	return -1.0

static func hype_value(action: String) -> int:
	if action == "hype_0":
		return 0
	if action == "hype_40":
		return 40
	if action == "hype_70":
		return 70
	if action == "hype_90":
		return 90
	if action == "hype_100":
		return 100
	return -1

static func forced_gift_rarity(action: String) -> String:
	if action == "gift_god":
		return "god"
	if action == "gift_flame":
		return "flame"
	return ""

static func should_start_gift(action: String) -> bool:
	return action == "gift_now"

static func should_start_comment(action: String) -> bool:
	return action == "comment_now"

static func forced_comment_id(action: String) -> String:
	if action == "comment_no_stop":
		return "no_stop"
	if action == "comment_enemy_speed":
		return "enemy_speed_up"
	if action == "comment_barrage":
		return "comment_barrage"
	if action == "comment_do_everything":
		return "do_everything"
	if action == "comment_boss":
		return "summon_boss"
	return ""

static func forced_heart_comment_id(action: String) -> String:
	if action == "heart_comment_giant":
		return "giant_enemies"
	return ""

static func marshmallow_kind(action: String) -> String:
	if action == "maro_random":
		return "random"
	if action == "maro_bad":
		return "bad"
	if action == "maro_god":
		return "god"
	return ""

static func spawn_enemy_kind(action: String) -> String:
	if action == "spawn_long":
		return "long_comment_guy"
	if action == "spawn_clipper":
		return "clipper"
	return ""

static func should_clear_enemies(action: String) -> bool:
	return action == "clear_enemies"

static func should_toggle_invincible(action: String) -> bool:
	return action == "toggle_invincible"

static func should_expire_marshmallows(action: String) -> bool:
	return action == "maro_expire"

static func should_clear_effects(action: String) -> bool:
	return action == "clear_effects"

static func should_reset_ranking(action: String) -> bool:
	return action == "reset_ranking"

static func apply_resource_action_for_target(target: Node, action: String) -> Dictionary:
	var chats: Array[String] = []
	if action == "heart_pending_on":
		target.set("heart_pending", true)
		chats.append("♡待機ON")
	var hype: int = hype_value(action)
	if hype >= 0:
		target.set("gift_hype", hype)
		target.set("max_gift_hype", maxi(int(target.get("max_gift_hype")), hype))
	return {"chats": chats}

static func apply_world_action_for_target(target: Node, action: String) -> Dictionary:
	if should_clear_enemies(action):
		(target.get("enemies") as Array).clear()
	if should_toggle_invincible(action):
		target.set("debug_invincible", not bool(target.get("debug_invincible")))
	return {}

static func apply_cleanup_action_for_target(target: Node, action: String) -> Dictionary:
	var chats: Array[String] = []
	if should_clear_effects(action):
		(target.get("active_effects") as Array).clear()
		(target.get("active_effect_rates") as Dictionary).clear()
		(target.get("effect_walls") as Array).clear()
		(target.get("effect_pits") as Array).clear()
	if should_reset_ranking(action):
		RankingSystem.reset_rankings()
		chats.append("ランキングをリセットしました")
	if action == "unlock_stream_frames":
		StreamFrameSystem.unlock_all_for_target(target)
		chats.append("全配信枠と配信リレーを解放しました")
	return {"chats": chats}

static func apply_general_action_for_target(target: Node, action: String, quick_test_mode: bool, arena: Rect2, rng: RandomNumberGenerator) -> Dictionary:
	var chats: Array = []
	var resource_result: Dictionary = apply_resource_action_for_target(target, action)
	for line in (resource_result["chats"] as Array):
		chats.append(String(line))
	apply_world_action_for_target(target, action)
	if String(target.get("state")) == "playing":
		apply_playing_action_for_target(target, action, quick_test_mode, arena, rng)
	var cleanup_result: Dictionary = apply_cleanup_action_for_target(target, action)
	for line in (cleanup_result["chats"] as Array):
		chats.append(String(line))
	return {"chats": chats}

static func apply_playing_action_for_target(target: Node, action: String, quick_test_mode: bool, arena: Rect2, rng: RandomNumberGenerator) -> Dictionary:
	var jump: float = jump_time(action, quick_test_mode)
	if jump >= 0.0:
		target.set("elapsed", jump)
	if should_expire_marshmallows(action):
		for item in (target.get("marshmallows") as Array):
			var marshmallow: Dictionary = item as Dictionary
			marshmallow["time"] = 0.0
	if action == "spawn_care_package":
		DestructibleSystemScript.spawn_box_for_target(target, arena, rng, target.get("effect_walls") as Array)
	var enemy_kind: String = spawn_enemy_kind(action)
	if enemy_kind != "":
		EnemySystem.spawn_enemy_for_target(target, enemy_kind, arena, rng)
	return {}

static func force_gift_choice_for_target(target: Node, gifts: Array, rarity: String, rng: RandomNumberGenerator) -> Dictionary:
	target.set("state", "gift_choice")
	target.set("selected_card", 0)
	var elapsed: float = float(target.get("elapsed"))
	var quick_test: bool = bool(target.get("quick_test_mode"))
	var gift_time: float = elapsed * (3.0 if quick_test else 1.0)
	var context: Dictionary = GiftSystem.build_offer_context_for_target(target, gifts, gift_time, rng)
	target.set("offered_gifts", GiftSystem.build_forced_offer(context, rarity))
	return {"chat": DisplayTextSystem.rarity_label(rarity) + "ギフトを強制抽選"}

static func force_gift_choice_ui_for_target(target: Node, gifts: Array, rarity: String, rng: RandomNumberGenerator, choice_box: Control) -> Dictionary:
	var result: Dictionary = force_gift_choice_for_target(target, gifts, rarity, rng)
	choice_box.visible = true
	return result

static func force_comment_offer_for_target(target: Node, comments: Array, id: String, has_heart: bool) -> Dictionary:
	var offer: Dictionary = CommentSystem.build_forced_offer(comments, id, has_heart)
	if not CommentSystem.apply_forced_offer_to_target(target, offer):
		return {"applied": false, "chooseIndex": -1}
	return {"applied": true, "chooseIndex": 0}

static func force_marshmallow_for_target(target: Node, data_list: Array, kind: String, rng: RandomNumberGenerator, arena: Rect2, effect_walls: Array) -> Dictionary:
	if kind == "":
		return {"spawned": false, "chat": ""}
	var spawned: bool = MarshmallowSystem.spawn_debug_for_target(target, data_list, kind, rng, arena, effect_walls)
	return {
		"spawned": spawned,
		"chat": "マシュマロが届いた！" if spawned else ""
	}

static func _add_if_pressed(actions: Array[String], latch: Dictionary, keycode: Key, action: String) -> void:
	if _pressed(latch, keycode):
		actions.append(action)

static func _pressed(latch: Dictionary, keycode: Key) -> bool:
	var down: bool = Input.is_key_pressed(keycode)
	var was_down: bool = bool(latch.get(keycode, false))
	latch[keycode] = down
	return down and not was_down
