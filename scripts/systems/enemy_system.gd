extends RefCounted
class_name EnemySystem

const BossSystemScript := preload("res://scripts/systems/boss_system.gd")
const KNOCKBACK_SPEED_SCALE := 13.0
const KNOCKBACK_DECAY_RATE := 13.0
const KNOCKBACK_STOP_SPEED := 8.0
const KNOCKBACK_MAX_SPEED := 1800.0
const SHOOTER_FIRE_INTERVAL_MIN := 2.35
const SHOOTER_FIRE_INTERVAL_MAX := 2.90
const SHOOTER_BULLET_LIFE := 2.7
const ARMCHAIR_FIRE_INTERVAL_MIN := 2.25
const ARMCHAIR_FIRE_INTERVAL_MAX := 2.85
const ARMCHAIR_BULLET_LIFE := 2.7
const DOT_INVADER_FIRE_INTERVAL_MIN := 1.85
const DOT_INVADER_FIRE_INTERVAL_MAX := 2.45
const DOT_INVADER_BULLET_LIFE := 2.8
const WIKI_FIRE_INTERVAL_MIN := 3.65
const WIKI_FIRE_INTERVAL_MAX := 4.45
const WIKI_BULLET_LIFE := 2.9
const DRONE_FIRE_INTERVAL_MIN := 2.55
const DRONE_FIRE_INTERVAL_MAX := 3.25
const DRONE_BULLET_LIFE := 2.9
const LAG_WARP_COOLDOWN_MIN := 4.45
const LAG_WARP_COOLDOWN_MAX := 5.45
const LAG_WARP_WARNING_TIME := 0.35
const LAG_WARP_DISTANCE_MIN := 76.0
const LAG_WARP_DISTANCE_MAX := 126.0
const MAX_ENEMY_BULLETS := 72
const SPAWN_EDGE_PADDING := 72.0
const SPAWN_WALL_CLEARANCE := 24.0
const SPAWN_POSITION_ATTEMPTS := 64
const SPAWN_OUTER_BAND_DEPTH := 280.0
const SPAWN_PLAYER_MIN_DISTANCE := 300.0
const SPAWN_SCREEN_MARGIN := 72.0
const SPAWN_FALLBACK_FIELD_VIEW := Rect2(Vector2(20.0, 190.0), Vector2(1200.0, 590.0))
const ENEMY_WALL_AVOIDANCE_MARGIN := 18.0
const ENEMY_WALL_AVOIDANCE_BLEND := 0.62
const ENEMY_WALL_AVOIDANCE_FALLBACK_DISTANCE := 420.0
const ENEMY_WALL_AVOIDANCE_MIN_FORWARD_DOT := 0.28
const ENEMY_WALL_AVOIDANCE_ROUTE_TURN_THRESHOLD := 160.0
const ENEMY_WALL_NAVIGATION_RADIUS_RATE := 0.72
const ENEMY_WALL_NAVIGATION_RADIUS_MIN := 14.0
const BOSS_WALL_NAVIGATION_RADIUS_RATE := 0.56
const BOSS_WALL_NAVIGATION_RADIUS_MIN := 46.0
const BOSS_WALL_UNSTICK_STEP_RATE := 0.58
const GAMEPLAY_MARSHMALLOW_DROP_CHANCE := 0.012
const GAMEPLAY_RACE_MARSHMALLOW_DROP_CHANCE := 0.006
const GAMEPLAY_BULLET_HELL_MARSHMALLOW_DROP_CHANCE := 0.004
const GAMEPLAY_HORROR_MARSHMALLOW_DROP_CHANCE := 0.010
const GAMEPLAY_FAKE_GIFT_MARSHMALLOW_DROP_CHANCE := 0.25

static var movement_wall_cache: Dictionary = {}

static func spawn_interval(context: Dictionary) -> float:
	var elapsed: float = float(context["elapsed"])
	if bool(context["quickTestMode"]):
		if elapsed >= 45.0:
			return 0.55
		if elapsed >= 30.0:
			return 0.75
		if elapsed >= 15.0:
			return 1.0
		return 1.25
	if elapsed >= 150.0:
		return 0.45
	if elapsed >= 120.0:
		return 0.6
	if elapsed >= 90.0:
		return 0.7
	if elapsed >= 60.0:
		return 0.8
	if elapsed >= 30.0:
		return 1.0
	return 1.3

static func effective_wave_time(elapsed: float, quick_test_mode: bool) -> float:
	return elapsed * 3.0 if quick_test_mode else elapsed

static func pick_wave_enemy(elapsed: float, quick_test_mode: bool, rng: RandomNumberGenerator, stream_frame_id: String = "", active_genre_event: String = "") -> String:
	if stream_frame_id == "gameplay" and active_genre_event == "":
		return pick_gameplay_normal_enemy(elapsed, quick_test_mode, rng)
	if stream_frame_id == "singing" or stream_frame_id == "song":
		return pick_song_enemy(elapsed, quick_test_mode, rng)
	if stream_frame_id == "drawing":
		return pick_drawing_enemy(elapsed, quick_test_mode, rng)
	return pick_default_wave_enemy(elapsed, quick_test_mode, rng)

static func pick_gameplay_normal_enemy(elapsed: float, quick_test_mode: bool, rng: RandomNumberGenerator) -> String:
	var t: float = effective_wave_time(elapsed, quick_test_mode)
	var roll: float = rng.randf()
	if t >= 120.0:
		if roll < 0.18:
			return "enemy_spoiler_comment"
		if roll < 0.35:
			return "enemy_backseat_controller"
		if roll < 0.50:
			return "enemy_armchair_strategist"
		if roll < 0.62:
			return "enemy_lag_comment"
		if roll < 0.74:
			return "enemy_strategy_wiki_ojisan"
		if roll < 0.82:
			return "enemy_fake_first_timer"
		if roll < 0.89:
			return "shooter"
		if roll < 0.96:
			return "fast"
		return "long_comment_guy"
	if t >= 75.0:
		if roll < 0.25:
			return "enemy_spoiler_comment"
		if roll < 0.45:
			return "enemy_backseat_controller"
		if roll < 0.61:
			return "enemy_armchair_strategist"
		if roll < 0.72:
			return "enemy_lag_comment"
		if roll < 0.80:
			return "enemy_fake_first_timer"
		if roll < 0.90:
			return "fast"
		return "troll"
	if t >= 30.0:
		if roll < 0.42:
			return "enemy_spoiler_comment"
		if roll < 0.62:
			return "enemy_backseat_controller"
		if roll < 0.74:
			return "fast"
		return "troll"
	if roll < 0.55:
		return "enemy_spoiler_comment"
	return "troll"

static func pick_bullet_hell_enemy(elapsed: float, quick_test_mode: bool, rng: RandomNumberGenerator) -> String:
	var t: float = effective_wave_time(elapsed, quick_test_mode)
	if t >= 75.0 and rng.randf() < 0.22:
		return "enemy_bullet_drone"
	return "enemy_dot_invader"

static func pick_race_event_enemy(_elapsed: float, _quick_test_mode: bool, rng: RandomNumberGenerator) -> String:
	return "enemy_wrong_way_kart" if rng.randf() < 0.62 else "enemy_jammer_cone"

static func pick_song_enemy(elapsed: float, quick_test_mode: bool, rng: RandomNumberGenerator) -> String:
	var t: float = effective_wave_time(elapsed, quick_test_mode)
	var roll: float = rng.randf()
	if t >= 120.0:
		if roll < 0.24:
			return "pitch_police"
		if roll < 0.45:
			return "request_spammer"
		if roll < 0.63:
			return "fast_call_fan"
		if roll < 0.75:
			return "song_noise_comment"
		if roll < 0.86:
			return "song_lyric_spoiler_comment"
		if roll < 0.93:
			return "shooter"
		return "fast"
	if t >= 70.0:
		if roll < 0.32:
			return "pitch_police"
		if roll < 0.52:
			return "request_spammer"
		if roll < 0.68:
			return "fast_call_fan"
		if roll < 0.80:
			return "song_noise_comment"
		if roll < 0.90:
			return "song_lyric_spoiler_comment"
		return "fast"
	if t >= 30.0:
		if roll < 0.42:
			return "pitch_police"
		if roll < 0.58:
			return "request_spammer"
		if roll < 0.72:
			return "fast_call_fan"
		if roll < 0.82:
			return "song_noise_comment"
		if roll < 0.90:
			return "song_lyric_spoiler_comment"
		return "troll"
	if roll < 0.55:
		return "pitch_police"
	if roll < 0.68:
		return "song_noise_comment"
	if roll < 0.80:
		return "request_spammer"
	return "troll"

static func pick_drawing_enemy(elapsed: float, quick_test_mode: bool, rng: RandomNumberGenerator) -> String:
	var t: float = effective_wave_time(elapsed, quick_test_mode)
	var roll: float = rng.randf()
	if t >= 120.0:
		if roll < 0.24:
			return "drawing_fix_note"
		if roll < 0.44:
			return "red_pen_teacher"
		if roll < 0.62:
			return "layer_lost"
		if roll < 0.78:
			return "bucket_fill_slime"
		if roll < 0.92:
			return "undo_ghost"
		return "shooter"
	if t >= 70.0:
		if roll < 0.30:
			return "drawing_fix_note"
		if roll < 0.50:
			return "red_pen_teacher"
		if roll < 0.66:
			return "layer_lost"
		if roll < 0.82:
			return "bucket_fill_slime"
		return "undo_ghost"
	if t >= 30.0:
		if roll < 0.34:
			return "drawing_fix_note"
		if roll < 0.54:
			return "red_pen_teacher"
		if roll < 0.72:
			return "undo_ghost"
		if roll < 0.86:
			return "bucket_fill_slime"
		return "troll"
	if roll < 0.46:
		return "drawing_fix_note"
	if roll < 0.68:
		return "undo_ghost"
	if roll < 0.84:
		return "bucket_fill_slime"
	return "troll"

static func pick_default_wave_enemy(elapsed: float, quick_test_mode: bool, rng: RandomNumberGenerator) -> String:
	var t: float = effective_wave_time(elapsed, quick_test_mode)
	var roll: float = rng.randf()
	if t >= 150.0:
		if roll < 0.20:
			return "clipper"
		if roll < 0.40:
			return "long_comment_guy"
		if roll < 0.62:
			return "shooter"
		if roll < 0.82:
			return "fast"
		return "troll"
	if t >= 120.0:
		if roll < 0.25:
			return "clipper"
		if roll < 0.45:
			return "long_comment_guy"
		if roll < 0.68:
			return "shooter"
		return "fast" if roll < 0.84 else "troll"
	if t >= 90.0:
		if roll < 0.35:
			return "long_comment_guy"
		if roll < 0.62:
			return "shooter"
		return "fast" if roll < 0.82 else "troll"
	if t >= 60.0:
		if roll < 0.38:
			return "shooter"
		return "fast" if roll < 0.68 else "troll"
	if t >= 30.0:
		return "fast" if roll < 0.45 else "troll"
	return "troll"

static func is_genre_event_enemy(kind: String) -> bool:
	return kind == "enemy_wrong_way_kart" or kind == "enemy_jammer_cone" or kind == "enemy_dot_invader" or kind == "enemy_bullet_drone" or kind == "enemy_fake_gift_box" or kind == "enemy_noise_ghost_comment"
static func hit_flash_duration_for_kind(kind: String, is_boss: bool = false) -> float:
	if is_boss or kind.begins_with("boss_"):
		return 0.06
	if kind == "long_comment_guy":
		return 0.08
	return 0.10

static func knockback_resistance_for_kind(kind: String, is_boss: bool = false) -> float:
	if is_boss or kind.begins_with("boss_"):
		return 1.0
	if kind == "enemy_backseat_controller":
		return 0.35
	if kind == "enemy_strategy_wiki_ojisan":
		return 0.65
	if kind == "enemy_wrong_way_kart" or kind == "enemy_jammer_cone":
		return 0.45
	if kind == "enemy_armchair_strategist" or kind == "enemy_lag_comment" or kind == "enemy_dot_invader" or kind == "enemy_bullet_drone" or kind == "enemy_fake_gift_box" or kind == "enemy_noise_ghost_comment" or kind == "song_noise_comment" or kind == "song_lyric_spoiler_comment":
		return 0.2
	if kind == "request_spammer":
		return 0.25
	if kind == "pitch_police" or kind == "fast_call_fan":
		return 0.12
	if kind == "fast" or kind == "unread_maro":
		return 0.1
	if kind == "shooter" or kind == "ghost_comment":
		return 0.2
	if kind == "clipper":
		return 0.3
	if kind == "long_comment_guy":
		return 0.7
	return 0.0

static func can_knockback_kind(kind: String, is_boss: bool = false) -> bool:
	return knockback_resistance_for_kind(kind, is_boss) < 1.0

static func contact_damage_for_kind(kind: String, is_boss: bool = false) -> int:
	if is_boss or kind.begins_with("boss_"):
		return DamageSystem.BOSS_CONTACT_DAMAGE
	if kind == "long_comment_guy" or kind == "clipper" or kind == "ghost_comment":
		return DamageSystem.STRONG_CONTACT_DAMAGE
	if kind == "fast":
		return DamageSystem.FAST_CONTACT_DAMAGE
	return DamageSystem.DEFAULT_CONTACT_DAMAGE

static func enemy_data(kind: String) -> Dictionary:
	if kind == "pitch_police":
		return {"displayName": "音程警察", "description": "音程チェックで近づいてくる歌枠の基本敵", "hp": 14.0, "speed": 110.0, "radius": 23.0, "score": 58, "exp": 2, "behavior": "chase"}
	if kind == "request_spammer":
		return {"displayName": "リクエスト連投", "description": "曲リクエストを投げ続ける歌枠の遠距離敵", "hp": 18.0, "speed": 72.0, "radius": 25.0, "score": 84, "exp": 3, "behavior": "keep_distance_shooter", "contactDamage": 18}
	if kind == "fast_call_fan":
		return {"displayName": "早口コール勢", "description": "サビに合わせて高速で押し寄せるコール敵", "hp": 9.0, "speed": 166.0, "radius": 20.0, "score": 48, "exp": 2, "behavior": "chase_fast", "contactDamage": 20}
	if kind == "song_noise_comment":
		return {"displayName": "ノイズコメント", "description": "歌声にノイズを混ぜる変則コメント敵", "hp": 12.0, "speed": 96.0, "radius": 22.0, "score": 58, "exp": 2, "behavior": "chase_with_short_warp", "contactDamage": 16}
	if kind == "song_lyric_spoiler_comment":
		return {"displayName": "歌詞ネタバレコメント", "description": "先の歌詞を先回りして流す迷惑コメント敵", "hp": 13.0, "speed": 100.0, "radius": 23.0, "score": 62, "exp": 2, "behavior": "chase", "contactDamage": 18}
	if kind == "drawing_fix_note":
		return {"displayName": "修正指示コメント", "description": "赤字の修正メモを投げてくるお絵かき枠の遠距離敵", "hp": 15.0, "speed": 76.0, "radius": 24.0, "score": 70, "exp": 3, "behavior": "keep_distance_shooter", "contactDamage": 18}
	if kind == "red_pen_teacher":
		return {"displayName": "赤ペン先生", "description": "赤ペンチェックで急接近する添削コメント敵", "hp": 18.0, "speed": 118.0, "radius": 24.0, "score": 86, "exp": 3, "behavior": "charger", "contactDamage": 22}
	if kind == "layer_lost":
		return {"displayName": "レイヤー迷子", "description": "半透明に揺れながら近づくレイヤー混乱敵", "hp": 13.0, "speed": 96.0, "radius": 23.0, "score": 64, "exp": 2, "behavior": "ghost_chase", "contactDamage": 18}
	if kind == "bucket_fill_slime":
		return {"displayName": "バケツ塗りスライム", "description": "広い塗り残しのように押し寄せる硬めの敵", "hp": 30.0, "speed": 58.0, "radius": 31.0, "score": 96, "exp": 4, "behavior": "tank", "contactDamage": 20}
	if kind == "undo_ghost":
		return {"displayName": "Undo幽霊", "description": "戻る矢印をまとって半透明に揺れるお絵かき枠の幽霊敵", "hp": 12.0, "speed": 112.0, "radius": 23.0, "score": 62, "exp": 2, "behavior": "ghost_chase", "contactDamage": 17}
	if kind == "enemy_spoiler_comment":
		return {"displayName": "ネタバレコメント", "description": "ゲーム実況中にネタバレを書き込む迷惑コメント敵", "hp": 11.0, "speed": 108.0, "radius": 23.0, "score": 44, "exp": 2, "behavior": "chase"}
	if kind == "enemy_backseat_controller":
		return {"displayName": "指示厨コントローラー", "description": "操作指示コメントがコントローラー型になった中型敵", "hp": 24.0, "speed": 104.0, "radius": 28.0, "score": 82, "exp": 3, "behavior": "zigzag_chase"}
	if kind == "enemy_armchair_strategist":
		return {"displayName": "エアプ軍師", "description": "離れた位置から攻略コメント弾を撃つ遠距離敵", "hp": 18.0, "speed": 72.0, "radius": 25.0, "score": 86, "exp": 4, "behavior": "keep_distance_shooter"}
	if kind == "enemy_dot_invader":
		return {"displayName": "ドットインベーダー", "description": "弾幕シューティング風イベントに出るレトロSTG敵", "hp": 12.0, "speed": 70.0, "radius": 22.0, "score": 72, "exp": 3, "behavior": "stg_side_move"}
	if kind == "enemy_fake_gift_box":
		return {"displayName": "偽ギフトボックス", "description": "ホラーゲーム風イベントで正体を現す罠ギフト", "hp": 18.0, "speed": 126.0, "radius": 24.0, "score": 90, "exp": 3, "behavior": "chase"}
	if kind == "enemy_lag_comment":
		return {"displayName": "ラグコメント", "description": "短距離ワープで画面にノイズを混ぜる変則コメント敵", "hp": 10.0, "speed": 106.0, "radius": 22.0, "score": 58, "exp": 2, "behavior": "chase_with_short_warp", "contactDamage": 18}
	if kind == "enemy_strategy_wiki_ojisan":
		return {"displayName": "攻略Wikiおじさん", "description": "攻略情報を抱えて低速で迫る硬めのゲーム実況敵", "hp": 52.0, "speed": 54.0, "radius": 34.0, "score": 130, "exp": 7, "behavior": "slow_spread_shooter", "contactDamage": 25}
	if kind == "enemy_fake_first_timer":
		return {"displayName": "初見詐欺", "description": "初見のふりをして近づくと急加速する奇襲コメント敵", "hp": 9.0, "speed": 54.0, "radius": 19.0, "score": 62, "exp": 2, "behavior": "ambush_chase", "contactDamage": 22}
	if kind == "enemy_wrong_way_kart":
		return {"displayName": "逆走カート", "description": "レースゲーム風イベントで直線的に走り抜ける妨害カート", "hp": 18.0, "speed": 292.0, "radius": 25.0, "score": 78, "exp": 2, "behavior": "linear_pass", "contactDamage": 24}
	if kind == "enemy_jammer_cone":
		return {"displayName": "じゃまコーン", "description": "レースゲーム風イベント中に短時間だけ残る壊せる障害物", "hp": 18.0, "speed": 0.0, "radius": 24.0, "score": 34, "exp": 1, "behavior": "stationary_obstacle", "contactDamage": 14, "lifeTime": 8.0}
	if kind == "enemy_bullet_drone":
		return {"displayName": "弾幕ドローン", "description": "弾幕シューティング風イベントで3方向弾を撃つ中型敵", "hp": 24.0, "speed": 86.0, "radius": 26.0, "score": 110, "exp": 4, "behavior": "drone_keep_distance", "contactDamage": 18}
	if kind == "enemy_noise_ghost_comment":
		return {"displayName": "ノイズ幽霊コメント", "description": "ホラーゲーム風イベントに現れる砂嵐混じりのコメント敵", "hp": 16.0, "speed": 88.0, "radius": 22.0, "score": 82, "exp": 3, "behavior": "ghost_chase", "contactDamage": 18}
	if kind == "fast":
		return {"displayName": "連投マン", "description": "高速で距離を詰める連投コメント敵", "hp": 8.0, "speed": 155.0, "radius": 20.0, "score": 40, "exp": 2, "behavior": "chase_fast"}
	if kind == "shooter":
		return {"displayName": "指示厨", "description": "距離を取りながら指示弾を撃つ敵", "hp": 14.0, "speed": 95.0, "radius": 24.0, "score": 60, "exp": 3, "behavior": "shooter"}
	if kind == "long_comment_guy":
		return {"displayName": "長文ニキ", "description": "遅いがしぶとく進路をふさぐ長文コメント敵", "hp": 40.0, "speed": 62.0, "radius": 34.0, "score": 80, "exp": 5, "behavior": "tank"}
	if kind == "clipper":
		return {"displayName": "悪質切り抜き師", "description": "予告後に突進して事故シーンを狙う敵", "hp": 18.0, "speed": 120.0, "radius": 23.0, "score": 100, "exp": 4, "behavior": "charger"}
	if kind == "unread_maro":
		return {"displayName": "未読マロ", "description": "放置されたマシュマロが荒らし化した敵", "hp": 8.0, "speed": 130.0, "radius": 19.0, "score": 20, "exp": 1, "behavior": "chase"}
	if kind == "ghost_comment":
		return {"displayName": "幽霊コメント", "description": "ホラー風イベント中に現れる透明気味のコメント敵", "hp": 20.0, "speed": 122.0, "radius": 23.0, "score": 120, "exp": 3, "behavior": "ghost"}
	if kind == "boss_super_long_comment":
		return {"displayName": "超長文ニキ", "description": "長文ニキの巨大版。大きなコメント塊でプレイヤーを追い詰める。", "hp": 400.0, "speed": 58.0, "radius": 78.0, "score": 3000, "exp": 20, "behavior": "tank"}
	if kind == "bugged_final_boss":
		return {"displayName": "バグったラスボス", "description": "ゲーム実況枠のジャンル変化を暴走させる専用ボス。", "hp": 1000.0, "speed": 52.0, "radius": 96.0, "score": 4200, "exp": 28, "behavior": "tank", "contactDamage": DamageSystem.BOSS_CONTACT_DAMAGE}
	return {"displayName": "荒らし", "description": "まっすぐ近づいてくる基本コメント敵", "hp": 10.0, "speed": 92.0, "radius": 21.0, "score": 20, "exp": 1, "behavior": "chase"}

static func spawn_position(arena: Rect2, rng: RandomNumberGenerator, edge_padding: float = 20.0) -> Vector2:
	var rect := spawn_candidate_rect(arena, edge_padding)
	return spawn_position_on_rect_edge(rect, rng)

static func spawn_candidate_rect(arena: Rect2, edge_padding: float) -> Rect2:
	var rect := arena.grow(-edge_padding)
	if rect.size.x <= 1.0 or rect.size.y <= 1.0:
		return arena
	return rect

static func spawn_position_on_rect_edge(rect: Rect2, rng: RandomNumberGenerator) -> Vector2:
	var edge := rng.randi_range(0, 3)
	if edge == 0:
		return Vector2(rng.randf_range(rect.position.x, rect.end.x), rect.position.y)
	if edge == 1:
		return Vector2(rng.randf_range(rect.position.x, rect.end.x), rect.end.y)
	if edge == 2:
		return Vector2(rect.position.x, rng.randf_range(rect.position.y, rect.end.y))
	return Vector2(rect.end.x, rng.randf_range(rect.position.y, rect.end.y))

static func spawn_position_in_outer_band(rect: Rect2, rng: RandomNumberGenerator) -> Vector2:
	var band: float = minf(SPAWN_OUTER_BAND_DEPTH, minf(rect.size.x, rect.size.y) * 0.5)
	var edge := rng.randi_range(0, 3)
	if edge == 0:
		return Vector2(rng.randf_range(rect.position.x, rect.end.x), rng.randf_range(rect.position.y, rect.position.y + band))
	if edge == 1:
		return Vector2(rng.randf_range(rect.position.x, rect.end.x), rng.randf_range(rect.end.y - band, rect.end.y))
	if edge == 2:
		return Vector2(rng.randf_range(rect.position.x, rect.position.x + band), rng.randf_range(rect.position.y, rect.end.y))
	return Vector2(rng.randf_range(rect.end.x - band, rect.end.x), rng.randf_range(rect.position.y, rect.end.y))

static func spawn_walls_for_target(target: Node) -> Array:
	var stream_frame_id := String(target.get("current_stream_frame_id"))
	if stream_frame_id == "":
		stream_frame_id = "zatsudan"
	var effect_walls_value: Variant = target.get("effect_walls")
	var effect_walls: Array = []
	if effect_walls_value is Array:
		effect_walls = effect_walls_value as Array
	return movement_wall_rects(effect_walls, stream_frame_id)

static func spawn_position_blocked_by_walls(pos: Vector2, radius: float, walls: Array) -> bool:
	var clearance := radius + SPAWN_WALL_CLEARANCE
	for wall_value in walls:
		var wall := wall_value as Rect2
		if wall.grow(clearance).has_point(pos):
			return true
	return false

static func fallback_visible_world_rect_for_target(target: Node, arena: Rect2) -> Rect2:
	var zoom := maxf(0.1, float(target.get("world_zoom")))
	var field_center := SPAWN_FALLBACK_FIELD_VIEW.get_center()
	var player_pos := Vector2(target.get("player_pos"))
	var desired := player_pos - field_center
	var min_offset := arena.position - SPAWN_FALLBACK_FIELD_VIEW.position
	var max_offset := arena.end - SPAWN_FALLBACK_FIELD_VIEW.end
	var camera_offset := Vector2(
		roundf(clampf(desired.x, min_offset.x, max_offset.x)),
		roundf(clampf(desired.y, min_offset.y, max_offset.y))
	)
	var top_left := (SPAWN_FALLBACK_FIELD_VIEW.position - field_center) / zoom + camera_offset + field_center
	var bottom_right := (SPAWN_FALLBACK_FIELD_VIEW.end - field_center) / zoom + camera_offset + field_center
	return Rect2(top_left, bottom_right - top_left)

static func visible_world_rect_for_target(target: Node, arena: Rect2) -> Rect2:
	if target.has_method("_visible_world_rect_for_spawning"):
		var visible_value: Variant = target.call("_visible_world_rect_for_spawning")
		if visible_value is Rect2:
			return visible_value as Rect2
	return fallback_visible_world_rect_for_target(target, arena)

static func append_spawn_band_if_valid(bands: Array, rect: Rect2) -> void:
	if rect.size.x > 1.0 and rect.size.y > 1.0:
		bands.append(rect)

static func offscreen_spawn_bands(rect: Rect2, visible_rect: Rect2) -> Array:
	var blocked := visible_rect.grow(SPAWN_SCREEN_MARGIN)
	var bands: Array = []
	if blocked.end.x <= rect.position.x or blocked.position.x >= rect.end.x or blocked.end.y <= rect.position.y or blocked.position.y >= rect.end.y:
		bands.append(rect)
		return bands
	var top_end_y := minf(blocked.position.y, rect.end.y)
	append_spawn_band_if_valid(bands, Rect2(rect.position, Vector2(rect.size.x, top_end_y - rect.position.y)))
	var bottom_start_y := maxf(blocked.end.y, rect.position.y)
	append_spawn_band_if_valid(bands, Rect2(Vector2(rect.position.x, bottom_start_y), Vector2(rect.size.x, rect.end.y - bottom_start_y)))
	var middle_y := maxf(rect.position.y, blocked.position.y)
	var middle_end_y := minf(rect.end.y, blocked.end.y)
	if middle_end_y > middle_y:
		var left_end_x := minf(blocked.position.x, rect.end.x)
		append_spawn_band_if_valid(bands, Rect2(Vector2(rect.position.x, middle_y), Vector2(left_end_x - rect.position.x, middle_end_y - middle_y)))
		var right_start_x := maxf(blocked.end.x, rect.position.x)
		append_spawn_band_if_valid(bands, Rect2(Vector2(right_start_x, middle_y), Vector2(rect.end.x - right_start_x, middle_end_y - middle_y)))
	return bands

static func random_position_in_rect(rect: Rect2, rng: RandomNumberGenerator) -> Vector2:
	return Vector2(rng.randf_range(rect.position.x, rect.end.x), rng.randf_range(rect.position.y, rect.end.y))

static func random_position_in_weighted_bands(bands: Array, rng: RandomNumberGenerator) -> Vector2:
	var total_area := 0.0
	for band_item in bands:
		var band: Rect2 = band_item as Rect2
		total_area += maxf(0.0, band.size.x * band.size.y)
	if total_area <= 0.0:
		return Vector2.INF
	var roll := rng.randf() * total_area
	for band_item in bands:
		var band: Rect2 = band_item as Rect2
		roll -= maxf(0.0, band.size.x * band.size.y)
		if roll <= 0.0:
			return random_position_in_rect(band, rng)
	return random_position_in_rect(bands.back() as Rect2, rng)

static func spawn_position_too_close_to_player(pos: Vector2, radius: float, player_pos: Vector2) -> bool:
	var min_distance := SPAWN_PLAYER_MIN_DISTANCE + radius
	return pos.distance_squared_to(player_pos) < min_distance * min_distance

static func spawn_position_visible(pos: Vector2, radius: float, visible_rect: Rect2) -> bool:
	return visible_rect.grow(radius + SPAWN_SCREEN_MARGIN).has_point(pos)

static func spawn_position_allowed(pos: Vector2, radius: float, walls: Array, player_pos: Vector2, visible_rect: Rect2) -> bool:
	if spawn_position_blocked_by_walls(pos, radius, walls):
		return false
	if spawn_position_too_close_to_player(pos, radius, player_pos):
		return false
	if spawn_position_visible(pos, radius, visible_rect):
		return false
	return true

static func spawn_position_for_target(target: Node, arena: Rect2, rng: RandomNumberGenerator, radius: float) -> Vector2:
	var walls: Array = spawn_walls_for_target(target)
	var edge_padding := radius + SPAWN_EDGE_PADDING
	var rect := spawn_candidate_rect(arena, edge_padding)
	var player_pos := Vector2(target.get("player_pos"))
	var visible_rect := visible_world_rect_for_target(target, arena)
	var offscreen_bands := offscreen_spawn_bands(rect, visible_rect)
	for i in range(SPAWN_POSITION_ATTEMPTS):
		var pos := random_position_in_weighted_bands(offscreen_bands, rng)
		if pos != Vector2.INF and spawn_position_allowed(pos, radius, walls, player_pos, visible_rect):
			return pos
	for i in range(SPAWN_POSITION_ATTEMPTS):
		var pos := spawn_position_on_rect_edge(rect, rng)
		if spawn_position_allowed(pos, radius, walls, player_pos, visible_rect):
			return pos
	for i in range(SPAWN_POSITION_ATTEMPTS):
		var pos := spawn_position_in_outer_band(rect, rng)
		if spawn_position_allowed(pos, radius, walls, player_pos, visible_rect):
			return pos
	return Vector2.INF

static func speech_lines(kind: String) -> Array[String]:
	if kind == "pitch_police":
		return ["音程！", "そこ違う", "ピッチ見て", "赤チェック"]
	if kind == "request_spammer":
		return ["これ歌って", "次これ", "リク連投", "この曲まだ？"]
	if kind == "fast_call_fan":
		return ["はい！はい！", "コール中", "サビ来た", "早口失礼"]
	if kind == "song_noise_comment":
		return ["ザザッ", "音割れ", "ノイズ入った", "聞こえる？"]
	if kind == "song_lyric_spoiler_comment":
		return ["次の歌詞", "そこ先に言うな", "ネタバレ歌詞", "まだ早い"]
	if kind == "drawing_fix_note":
		return ["そこ修正", "赤入れます", "線見て", "直して"]
	if kind == "red_pen_teacher":
		return ["赤ペンです", "添削します", "そこ違う", "要修正"]
	if kind == "layer_lost":
		return ["今どのレイヤー？", "線画どこ", "下に描いた", "結合しちゃった"]
	if kind == "bucket_fill_slime":
		return ["バケツでいこう", "全部塗る", "はみ出した", "塗り残し発見"]
	if kind == "undo_ghost":
		return ["戻して", "Undoします", "一手前へ", "消しすぎ注意"]
	if kind == "enemy_lag_comment":
		return ["止まった？", "ラグい", "今ワープした？", "回線大丈夫？"]
	if kind == "enemy_strategy_wiki_ojisan":
		return ["完全攻略", "最強ルート", "そこ違う", "Wiki見た？"]
	if kind == "enemy_fake_first_timer":
		return ["初見です", "ここ知ってる", "初見ですけど", "あっそこ罠"]
	if kind == "enemy_wrong_way_kart":
		return ["逆走中", "そっちじゃない", "ぶつかるぞ", "道あけて"]
	if kind == "enemy_jammer_cone":
		return ["通行止め", "工事中", "ここ邪魔", "止まれ"]
	if kind == "enemy_bullet_drone":
		return ["ロックオン", "3way", "弾幕開始", "避けて"]
	if kind == "enemy_noise_ghost_comment":
		return ["ザザッ", "見えてる？", "後ろ", "砂嵐"]
	if kind == "enemy_spoiler_comment":
		return ["そこ罠", "このあと...", "ラスボス...", "ネタバレ注意"]
	if kind == "enemy_backseat_controller":
		return ["右！", "避けろ！", "今だ！", "そこ左"]
	if kind == "enemy_armchair_strategist":
		return ["違う", "こうしろ", "なんで？", "右だろ"]
	if kind == "enemy_dot_invader":
		return ["撃て撃て", "急にSTG", "避けろ", "画面見て"]
	if kind == "enemy_fake_gift_box":
		return ["ギフト？", "開けて", "近づいて", "!? "]
	if kind == "fast":
		return ["連投失礼", "追いついた", "逃がさない", "連投マン参上"]
	if kind == "shooter":
		return ["指示します", "そこ避けて", "こう動いて", "弾幕いくぞ"]
	if kind == "long_comment_guy":
		return ["長文失礼します", "結論から言うと", "読んでください", "要約すると無理"]
	if kind == "clipper":
		return ["悪質切り抜き中", "今の切り取る", "サムネにする", "そこだけ使う"]
	if kind == "unread_maro":
		return ["未読です", "読んで", "マロ溜めるな", "返事まだ？"]
	if kind == "ghost_comment":
		return ["見てるよ", "うしろ", "消えないよ", "既読つけて"]
	return ["草", "それな〜", "逃げろ", "BANできる？", "右いけ右"]

static func random_speech(kind: String, rng: RandomNumberGenerator) -> String:
	var lines: Array[String] = speech_lines(kind)
	if lines.is_empty():
		return ""
	return lines[rng.randi_range(0, lines.size() - 1)]

static func build_enemy(kind: String, pos: Vector2, uid: int, shoot: float, giant_power: float = 0.0, speech_text: String = "") -> Dictionary:
	var data: Dictionary = enemy_data(kind)
	var is_boss_kind: bool = kind.begins_with("boss_")
	if giant_power > 0.0:
		data["hp"] = float(data["hp"]) * lerpf(1.25, 1.5, giant_power)
		data["radius"] = float(data["radius"]) * lerpf(1.5, 2.0, giant_power)
	var enemy: Dictionary = {
		"uid": uid,
		"kind": kind,
		"displayName": String(data.get("displayName", kind)),
		"pos": pos,
		"hp": data["hp"],
		"max_hp": data["hp"],
		"speed": data["speed"],
		"radius": data["radius"],
		"score": data["score"],
		"exp": data["exp"],
		"expValue": data["exp"],
		"behavior": data["behavior"],
		"shoot": shoot,
		"speechText": speech_text,
		"hitFlashDuration": float(data.get("hitFlashDuration", hit_flash_duration_for_kind(kind, is_boss_kind))),
		"hitFlashTimer": 0.0,
		"knockbackResistance": float(data.get("knockbackResistance", knockback_resistance_for_kind(kind, is_boss_kind))),
		"canBeKnockedBack": bool(data.get("canBeKnockedBack", can_knockback_kind(kind, is_boss_kind))),
		"contactDamage": int(data.get("contactDamage", contact_damage_for_kind(kind, is_boss_kind))),
		"knockbackVelocity": Vector2.ZERO,
		"stunTimer": 0.0,
		"defeatPending": false,
		"defeatDelay": 0.0,
		"defeatResolved": false
	}
	if kind == "enemy_backseat_controller" or kind == "enemy_dot_invader" or kind == "enemy_lag_comment" or kind == "enemy_strategy_wiki_ojisan" or kind == "enemy_bullet_drone" or kind == "enemy_noise_ghost_comment":
		enemy["movePhase"] = float(uid % 19) * 0.37
	if kind == "enemy_backseat_controller":
		enemy["dashTimer"] = 0.0
	if kind == "enemy_dot_invader":
		enemy["sideMoveDir"] = -1.0 if uid % 2 == 0 else 1.0
	if kind == "enemy_lag_comment":
		enemy["warpWarningTimer"] = 0.0
	if kind == "enemy_fake_first_timer":
		enemy["ambushActive"] = false
	if kind == "enemy_wrong_way_kart":
		enemy["ignoreMovementWalls"] = true
		enemy["lifeTimer"] = 5.4
	if kind == "enemy_jammer_cone":
		enemy["lifeTimer"] = float(data.get("lifeTime", 8.0))
	if kind == "enemy_noise_ghost_comment" or kind == "layer_lost" or kind == "undo_ghost":
		enemy["phaseTimer"] = float(uid % 13) * 0.21
	if is_genre_event_enemy(kind):
		enemy["genreEventEnemy"] = true
	return enemy
static func spawn_enemy_for_target(target: Node, kind: String, arena: Rect2, rng: RandomNumberGenerator, pos: Vector2 = Vector2.INF) -> void:
	var spawn_pos: Vector2 = pos
	var giant_power: float = 0.0
	if ModifierSystem.has_effect_for_target(target, "giant_enemies"):
		giant_power = ModifierSystem.effect_rate_for_target(target, "giant_enemies")
	var data := enemy_data(kind)
	var spawn_radius := float(data.get("radius", 22.0))
	if giant_power > 0.0:
		spawn_radius *= lerpf(1.5, 2.0, giant_power)
	if spawn_pos == Vector2.INF:
		spawn_pos = spawn_position_for_target(target, arena, rng, spawn_radius)
		if spawn_pos == Vector2.INF:
			return
	var shoot_seed: float = rng.randf_range(0.6, 1.4) if pos == Vector2.INF else 1.0
	if kind == "shooter":
		shoot_seed = rng.randf_range(1.4, SHOOTER_FIRE_INTERVAL_MAX)
	elif kind == "enemy_armchair_strategist":
		shoot_seed = rng.randf_range(1.3, ARMCHAIR_FIRE_INTERVAL_MAX)
	elif kind == "drawing_fix_note":
		shoot_seed = rng.randf_range(1.2, ARMCHAIR_FIRE_INTERVAL_MAX)
	elif kind == "enemy_dot_invader":
		shoot_seed = rng.randf_range(1.0, DOT_INVADER_FIRE_INTERVAL_MAX)
	elif kind == "enemy_strategy_wiki_ojisan":
		shoot_seed = rng.randf_range(1.4, WIKI_FIRE_INTERVAL_MAX)
	elif kind == "enemy_bullet_drone":
		shoot_seed = rng.randf_range(1.2, DRONE_FIRE_INTERVAL_MAX)
	elif kind == "enemy_lag_comment":
		shoot_seed = rng.randf_range(LAG_WARP_COOLDOWN_MIN, LAG_WARP_COOLDOWN_MAX)
	var enemies: Array = target.get("enemies") as Array
	var next_uid: int = int(target.get("next_enemy_uid"))
	var speech_text: String = ""
	if rng.randf() < 0.33:
		speech_text = random_speech(kind, rng)
	var enemy := build_enemy(kind, spawn_pos, next_uid, shoot_seed, giant_power, speech_text)
	if is_genre_event_enemy(kind):
		enemy["genreEventEnemy"] = true
	enemies.append(enemy)
	target.set("enemies", enemies)
	target.set("next_enemy_uid", next_uid + 1)

static func kill_events(enemy: Dictionary, split_enemy: bool, rng: RandomNumberGenerator) -> Dictionary:
	var pos: Vector2 = Vector2(enemy["pos"])
	var splits: Array = []
	if split_enemy and rng.randf() < 0.35 and String(enemy["kind"]) != "troll":
		splits.append(pos + Vector2(18, 0))
		splits.append(pos + Vector2(-18, 0))
	return {
		"splits": splits,
		"chat": "今のBANうまい" if rng.randf() < 0.16 else ""
	}

static func gameplay_marshmallow_drop_request_for_target(target: Node, enemy: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	if String(target.get("current_stream_frame_id")) != "gameplay":
		return {}
	if bool(enemy.get("isBoss", false)):
		return {}
	var active_genre_event := String(target.get("active_genre_event"))
	var chance := GAMEPLAY_MARSHMALLOW_DROP_CHANCE
	var source := "enemy_defeat"
	if active_genre_event == "race":
		chance = GAMEPLAY_RACE_MARSHMALLOW_DROP_CHANCE
	elif active_genre_event == "bullet_hell":
		chance = GAMEPLAY_BULLET_HELL_MARSHMALLOW_DROP_CHANCE
	elif active_genre_event == "horror":
		chance = GAMEPLAY_HORROR_MARSHMALLOW_DROP_CHANCE
		if String(enemy.get("source", "")) == "fake_gift":
			chance = GAMEPLAY_FAKE_GIFT_MARSHMALLOW_DROP_CHANCE
			source = "fake_gift_defeat"
	if rng.randf() >= chance:
		return {}
	return {
		"pos": Vector2(enemy.get("pos", Vector2.ZERO)),
		"source": source
	}

static func apply_kill_for_target(target: Node, enemy: Dictionary, arena: Rect2, rng: RandomNumberGenerator) -> Dictionary:
	target.set("kills", int(target.get("kills")) + 1)
	var active_genre_event := String(target.get("active_genre_event"))
	var comment_event_ids: Array[String] = []
	if active_genre_event == "bullet_hell" and String(enemy.get("defeatSource", enemy.get("lastHitSource", ""))) == "genre_stg_shot":
		target.set("genre_result_stg_shot_kill_count", int(target.get("genre_result_stg_shot_kill_count")) + 1)
	if active_genre_event == "horror" and String(enemy.get("source", "")) == "fake_gift":
		target.set("genre_result_fake_gift_defeat_count", int(target.get("genre_result_fake_gift_defeat_count")) + 1)
		comment_event_ids.append("gameplay_horror_fake_gift_defeated")
	var is_boss: bool = bool(enemy.get("isBoss", false)) or String(enemy.get("kind", "")) == "boss_super_long_comment"
	append_defeat_fx_for_target(target, enemy, is_boss)
	_apply_song_live_heat_for_kill(target, enemy)
	_apply_drawing_progress_for_kill(target, enemy)
	if is_boss:
		return BossSystemScript.apply_defeat_for_target(target, enemy)
	target.set("score", int(target.get("score")) + ScoreSystem.enemy_score_for_target(target, enemy))
	ExpSystem.drop_from_enemy_for_target(target, enemy)
	var marshmallow_drop_requests: Array = []
	var marshmallow_drop_request: Dictionary = gameplay_marshmallow_drop_request_for_target(target, enemy, rng)
	if not marshmallow_drop_request.is_empty():
		marshmallow_drop_requests.append(marshmallow_drop_request)
	var split_enemy: bool = ModifierSystem.has_effect_for_target(target, "split_enemy")
	var events: Dictionary = kill_events(enemy, split_enemy, rng)
	var splits: Array = events["splits"] as Array
	for item in splits:
		spawn_enemy_for_target(target, "troll", arena, rng, Vector2(item))
	return {
		"chat": String(events["chat"]),
		"commentEventIds": comment_event_ids,
		"marshmallowDropRequests": marshmallow_drop_requests,
		"enemyDefeated": true
	}

static func _apply_song_live_heat_for_kill(target: Node, enemy: Dictionary) -> void:
	if not target.has_method("_add_song_live_heat"):
		return
	var stream_frame_id := String(target.get("current_stream_frame_id"))
	if stream_frame_id != "singing" and stream_frame_id != "song":
		return
	var radius := float(enemy.get("radius", 20.0))
	var max_hp := float(enemy.get("max_hp", enemy.get("maxHp", enemy.get("hp", 0.0))))
	var gain := 0.15
	if bool(enemy.get("isBoss", false)) or max_hp >= 90.0 or radius >= 44.0:
		gain = 1.2
	elif max_hp >= 18.0 or radius >= 26.0:
		gain = 0.5
	target.call("_add_song_live_heat", gain, "enemy_defeat")

static func _apply_drawing_progress_for_kill(target: Node, enemy: Dictionary) -> void:
	if not target.has_method("_add_drawing_progress_from_enemy_defeat"):
		return
	if String(target.get("current_stream_frame_id")) != "drawing":
		return
	if bool(enemy.get("isBoss", false)):
		return
	target.call("_add_drawing_progress_from_enemy_defeat", enemy)

static func defeat_delay_for_enemy(enemy: Dictionary) -> float:
	var base_delay: float = 0.55 if bool(enemy.get("isBoss", false)) else 0.12
	return maxf(base_delay, float(enemy.get("hitFlashDuration", 0.10)))

static func queue_defeat_for_enemy(enemy: Dictionary) -> void:
	if bool(enemy.get("defeatPending", false)) or bool(enemy.get("defeatResolved", false)):
		return
	var delay: float = defeat_delay_for_enemy(enemy)
	enemy["defeatPending"] = true
	enemy["defeatDelay"] = delay
	enemy["defeatDelayMax"] = delay
	enemy["killQueued"] = true
	if bool(enemy.get("isBoss", false)):
		enemy["hitFlashColor"] = Color(1.0, 0.96, 0.66, 1.0)
		enemy["hitFlashDuration"] = maxf(float(enemy.get("hitFlashDuration", 0.10)), 0.18)
		enemy["hitFlashTimer"] = maxf(float(enemy.get("hitFlashTimer", 0.0)), float(enemy["hitFlashDuration"]))

static func should_keep_enemy(enemy_value: Variant) -> bool:
	var enemy: Dictionary = enemy_value as Dictionary
	return not bool(enemy.get("defeatResolved", false))

static func add_knockback_for_enemy(enemy: Dictionary, direction: Vector2, distance: float) -> void:
	if distance <= 0.0:
		return
	var dir: Vector2 = direction.normalized()
	if dir.length() < 0.1:
		return
	var velocity: Vector2 = Vector2(enemy.get("knockbackVelocity", Vector2.ZERO))
	velocity += dir * distance * KNOCKBACK_SPEED_SCALE
	if velocity.length() > KNOCKBACK_MAX_SPEED:
		velocity = velocity.normalized() * KNOCKBACK_MAX_SPEED
	enemy["knockbackVelocity"] = velocity

static func clamp_enemy_pos_to_arena(pos: Vector2, arena: Rect2) -> Vector2:
	return Vector2(
		clampf(pos.x, arena.position.x + 15.0, arena.end.x - 15.0),
		clampf(pos.y, arena.position.y + 15.0, arena.end.y - 15.0)
	)

static func clamp_enemy_pos_to_arena_for_enemy(enemy: Dictionary, pos: Vector2, arena: Rect2) -> Vector2:
	var margin := 15.0
	if ignores_movement_walls(enemy) and (bool(enemy.get("isBoss", false)) or String(enemy.get("kind", "")) == BossSystemScript.BOSS_BUGGED_FINAL_BOSS):
		margin = maxf(margin, float(enemy.get("radius", 22.0)) + 2.0)
	return Vector2(
		clampf(pos.x, arena.position.x + margin, arena.end.x - margin),
		clampf(pos.y, arena.position.y + margin, arena.end.y - margin)
	)

static func apply_knockback_motion(enemy: Dictionary, enemy_pos: Vector2, previous_enemy_pos: Vector2, delta: float, arena: Rect2, effect_walls: Array, stream_frame_id: String) -> Vector2:
	var velocity: Vector2 = Vector2(enemy.get("knockbackVelocity", Vector2.ZERO))
	if velocity.length() <= KNOCKBACK_STOP_SPEED:
		enemy["knockbackVelocity"] = Vector2.ZERO
		return clamp_enemy_pos_to_arena_for_enemy(enemy, enemy_pos, arena) if ignores_movement_walls(enemy) else enemy_pos
	enemy_pos += velocity * delta
	enemy_pos = clamp_enemy_pos_to_arena_for_enemy(enemy, enemy_pos, arena) if ignores_movement_walls(enemy) else clamp_enemy_pos_to_arena(enemy_pos, arena)
	if not ignores_movement_walls(enemy):
		enemy_pos = PlayerSystem.resolve_wall_collision(enemy_pos, previous_enemy_pos, wall_navigation_radius(enemy), effect_walls, stream_frame_id)
	enemy_pos = clamp_enemy_pos_to_arena_for_enemy(enemy, enemy_pos, arena) if ignores_movement_walls(enemy) else clamp_enemy_pos_to_arena(enemy_pos, arena)
	velocity *= exp(-KNOCKBACK_DECAY_RATE * delta)
	if velocity.length() <= KNOCKBACK_STOP_SPEED:
		velocity = Vector2.ZERO
	enemy["knockbackVelocity"] = velocity
	return enemy_pos

static func ignores_movement_walls(enemy: Dictionary) -> bool:
	if bool(enemy.get("ignoreMovementWalls", false)):
		return true
	var boss_id: String = String(enemy.get("bossId", enemy.get("kind", "")))
	if bool(enemy.get("isBoss", false)) and (boss_id == BossSystemScript.BOSS_KUSO_MARO_KING or boss_id == BossSystemScript.BOSS_BUGGED_FINAL_BOSS or boss_id == BossSystemScript.BOSS_PITCH_POLICE_CHIEF):
		return true
	var kind := String(enemy.get("kind", ""))
	return kind == BossSystemScript.BOSS_BUGGED_FINAL_BOSS or kind == BossSystemScript.BOSS_PITCH_POLICE_CHIEF

static func wall_navigation_radius(enemy: Dictionary) -> float:
	var radius := float(enemy.get("radius", 22.0))
	if bool(enemy.get("isBoss", false)):
		return minf(radius, maxf(BOSS_WALL_NAVIGATION_RADIUS_MIN, radius * BOSS_WALL_NAVIGATION_RADIUS_RATE))
	return minf(radius, maxf(ENEMY_WALL_NAVIGATION_RADIUS_MIN, radius * ENEMY_WALL_NAVIGATION_RADIUS_RATE))

static func movement_wall_rects(effect_walls: Array, stream_frame_id: String) -> Array:
	var frame_id := stream_frame_id
	if frame_id == "":
		frame_id = "zatsudan"
	if not movement_wall_cache.has(frame_id):
		movement_wall_cache[frame_id] = DrawDataSystem.static_wall_rects(frame_id)
	var walls: Array = (movement_wall_cache[frame_id] as Array).duplicate()
	for effect_wall in effect_walls:
		walls.append(effect_wall as Rect2)
	return walls

static func resolve_enemy_wall_collision(pos: Vector2, previous_pos: Vector2, radius: float, walls: Array) -> Vector2:
	var resolved: Vector2 = pos
	for wall_item in walls:
		var wall: Rect2 = wall_item as Rect2
		var grown: Rect2 = wall.grow(radius)
		if not grown.has_point(resolved):
			continue
		if previous_pos.x <= wall.position.x:
			resolved.x = wall.position.x - radius
		elif previous_pos.x >= wall.end.x:
			resolved.x = wall.end.x + radius
		elif previous_pos.y <= wall.position.y:
			resolved.y = wall.position.y - radius
		elif previous_pos.y >= wall.end.y:
			resolved.y = wall.end.y + radius
		else:
			var left_push: float = absf(resolved.x - grown.position.x)
			var right_push: float = absf(grown.end.x - resolved.x)
			var top_push: float = absf(resolved.y - grown.position.y)
			var bottom_push: float = absf(grown.end.y - resolved.y)
			var min_push: float = minf(minf(left_push, right_push), minf(top_push, bottom_push))
			if min_push == left_push:
				resolved.x = grown.position.x
			elif min_push == right_push:
				resolved.x = grown.end.x
			elif min_push == top_push:
				resolved.y = grown.position.y
			else:
				resolved.y = grown.end.y
	return resolved

static func segment_intersects_rect(from_pos: Vector2, to_pos: Vector2, rect: Rect2) -> bool:
	if rect.has_point(from_pos) or rect.has_point(to_pos):
		return true
	var delta: Vector2 = to_pos - from_pos
	var t_min := 0.0
	var t_max := 1.0
	if absf(delta.x) < 0.001:
		if from_pos.x < rect.position.x or from_pos.x > rect.end.x:
			return false
	else:
		var tx1: float = (rect.position.x - from_pos.x) / delta.x
		var tx2: float = (rect.end.x - from_pos.x) / delta.x
		t_min = maxf(t_min, minf(tx1, tx2))
		t_max = minf(t_max, maxf(tx1, tx2))
	if absf(delta.y) < 0.001:
		if from_pos.y < rect.position.y or from_pos.y > rect.end.y:
			return false
	else:
		var ty1: float = (rect.position.y - from_pos.y) / delta.y
		var ty2: float = (rect.end.y - from_pos.y) / delta.y
		t_min = maxf(t_min, minf(ty1, ty2))
		t_max = minf(t_max, maxf(ty1, ty2))
	return t_max >= t_min and t_max >= 0.0 and t_min <= 1.0

static func point_distance_to_rect(pos: Vector2, rect: Rect2) -> float:
	var dx: float = maxf(maxf(rect.position.x - pos.x, 0.0), pos.x - rect.end.x)
	var dy: float = maxf(maxf(rect.position.y - pos.y, 0.0), pos.y - rect.end.y)
	return Vector2(dx, dy).length()

static func choose_vertical_avoidance(enemy: Dictionary, enemy_pos: Vector2, goal_pos: Vector2, rect: Rect2) -> Vector2:
	if goal_pos.y <= rect.position.y:
		enemy["wallAvoidY"] = -1
		return Vector2.UP
	if goal_pos.y >= rect.end.y:
		enemy["wallAvoidY"] = 1
		return Vector2.DOWN
	var desired_delta := goal_pos.y - enemy_pos.y
	if absf(desired_delta) > ENEMY_WALL_AVOIDANCE_ROUTE_TURN_THRESHOLD:
		var route := 1 if desired_delta > 0.0 else -1
		enemy["wallAvoidY"] = route
		return Vector2.DOWN if route > 0 else Vector2.UP
	var stored_route := int(enemy.get("wallAvoidY", 0))
	if stored_route != 0:
		return Vector2.DOWN if stored_route > 0 else Vector2.UP
	if absf(desired_delta) > 18.0:
		stored_route = 1 if desired_delta > 0.0 else -1
		enemy["wallAvoidY"] = stored_route
		return Vector2.DOWN if stored_route > 0 else Vector2.UP
	var top_cost: float = absf(enemy_pos.y - rect.position.y) + absf(goal_pos.y - rect.position.y) * 0.35
	var bottom_cost: float = absf(enemy_pos.y - rect.end.y) + absf(goal_pos.y - rect.end.y) * 0.35
	if absf(top_cost - bottom_cost) <= 8.0:
		stored_route = -1 if int(enemy.get("uid", 0)) % 2 == 0 else 1
	else:
		stored_route = -1 if top_cost < bottom_cost else 1
	enemy["wallAvoidY"] = stored_route
	return Vector2.DOWN if stored_route > 0 else Vector2.UP

static func choose_horizontal_avoidance(enemy: Dictionary, enemy_pos: Vector2, goal_pos: Vector2, rect: Rect2) -> Vector2:
	if goal_pos.x <= rect.position.x:
		enemy["wallAvoidX"] = -1
		return Vector2.LEFT
	if goal_pos.x >= rect.end.x:
		enemy["wallAvoidX"] = 1
		return Vector2.RIGHT
	var desired_delta := goal_pos.x - enemy_pos.x
	if absf(desired_delta) > ENEMY_WALL_AVOIDANCE_ROUTE_TURN_THRESHOLD:
		var route := 1 if desired_delta > 0.0 else -1
		enemy["wallAvoidX"] = route
		return Vector2.RIGHT if route > 0 else Vector2.LEFT
	var stored_route := int(enemy.get("wallAvoidX", 0))
	if stored_route != 0:
		return Vector2.RIGHT if stored_route > 0 else Vector2.LEFT
	if absf(desired_delta) > 18.0:
		stored_route = 1 if desired_delta > 0.0 else -1
		enemy["wallAvoidX"] = stored_route
		return Vector2.RIGHT if stored_route > 0 else Vector2.LEFT
	var left_cost: float = absf(enemy_pos.x - rect.position.x) + absf(goal_pos.x - rect.position.x) * 0.35
	var right_cost: float = absf(enemy_pos.x - rect.end.x) + absf(goal_pos.x - rect.end.x) * 0.35
	if absf(left_cost - right_cost) <= 8.0:
		stored_route = -1 if int(enemy.get("uid", 0)) % 2 == 0 else 1
	else:
		stored_route = -1 if left_cost < right_cost else 1
	enemy["wallAvoidX"] = stored_route
	return Vector2.RIGHT if stored_route > 0 else Vector2.LEFT

static func wall_avoidance_direction(enemy: Dictionary, enemy_pos: Vector2, goal_pos: Vector2, radius: float, walls: Array) -> Vector2:
	var best_dir := Vector2.ZERO
	var best_score := INF
	var desired: Vector2 = goal_pos - enemy_pos
	if desired.length() < 0.1:
		return best_dir
	for wall_item in walls:
		var wall: Rect2 = wall_item as Rect2
		var grown: Rect2 = wall.grow(radius + ENEMY_WALL_AVOIDANCE_MARGIN)
		if not segment_intersects_rect(enemy_pos, goal_pos, grown):
			continue
		var horizontal_block: bool = (
			(enemy_pos.x <= grown.position.x and goal_pos.x >= grown.position.x)
			or (enemy_pos.x >= grown.end.x and goal_pos.x <= grown.end.x)
		)
		var vertical_block: bool = (
			(enemy_pos.y <= grown.position.y and goal_pos.y >= grown.position.y)
			or (enemy_pos.y >= grown.end.y and goal_pos.y <= grown.end.y)
		)
		var enemy_y_inside: bool = enemy_pos.y >= grown.position.y and enemy_pos.y <= grown.end.y
		var enemy_x_inside: bool = enemy_pos.x >= grown.position.x and enemy_pos.x <= grown.end.x
		var candidate := Vector2.ZERO
		if (horizontal_block and enemy_y_inside) or (enemy_y_inside and absf(desired.x) >= absf(desired.y)):
			candidate = choose_vertical_avoidance(enemy, enemy_pos, goal_pos, grown)
		elif (vertical_block and enemy_x_inside) or (enemy_x_inside and absf(desired.y) > absf(desired.x)):
			candidate = choose_horizontal_avoidance(enemy, enemy_pos, goal_pos, grown)
		else:
			candidate = choose_vertical_avoidance(enemy, enemy_pos, goal_pos, grown) if absf(desired.x) >= absf(desired.y) else choose_horizontal_avoidance(enemy, enemy_pos, goal_pos, grown)
		var score := point_distance_to_rect(enemy_pos, grown)
		if score < best_score:
			best_score = score
			best_dir = candidate
	return best_dir

static func forward_safe_avoidance_dir(base_dir: Vector2, avoid_dir: Vector2) -> Vector2:
	if avoid_dir.length() < 0.1:
		return Vector2.ZERO
	var safe_dir := avoid_dir.normalized()
	var backward: float = safe_dir.dot(base_dir)
	if backward >= -0.05:
		return safe_dir
	safe_dir = safe_dir - base_dir * backward
	if safe_dir.length() < 0.1:
		return Vector2.ZERO
	return safe_dir.normalized()

static func blended_enemy_move_dir(base_dir: Vector2, avoid_dir: Vector2, dir_power: float) -> Vector2:
	var safe_avoid := forward_safe_avoidance_dir(base_dir, avoid_dir)
	if safe_avoid.length() < 0.1:
		return base_dir * dir_power
	var mixed := (base_dir * (1.0 - ENEMY_WALL_AVOIDANCE_BLEND) + safe_avoid * ENEMY_WALL_AVOIDANCE_BLEND)
	if mixed.length() < 0.1:
		return base_dir * dir_power
	mixed = mixed.normalized()
	if mixed.dot(base_dir) < ENEMY_WALL_AVOIDANCE_MIN_FORWARD_DOT:
		var side := safe_avoid - base_dir * safe_avoid.dot(base_dir)
		if side.length() < 0.1:
			return base_dir * dir_power
		var side_rate := sqrt(1.0 - ENEMY_WALL_AVOIDANCE_MIN_FORWARD_DOT * ENEMY_WALL_AVOIDANCE_MIN_FORWARD_DOT)
		mixed = (base_dir * ENEMY_WALL_AVOIDANCE_MIN_FORWARD_DOT + side.normalized() * side_rate).normalized()
	return mixed * dir_power

static func move_enemy_with_wall_avoidance(enemy: Dictionary, enemy_pos: Vector2, dir: Vector2, speed: float, delta: float, arena: Rect2, walls: Array, player_pos: Vector2) -> Vector2:
	var dir_power := dir.length()
	if dir_power < 0.1 or speed <= 0.0:
		return enemy_pos
	if ignores_movement_walls(enemy):
		enemy.erase("wallAvoidX")
		enemy.erase("wallAvoidY")
		return clamp_enemy_pos_to_arena_for_enemy(enemy, enemy_pos + dir * speed * delta, arena)
	var radius := wall_navigation_radius(enemy)
	var base_dir := dir / dir_power
	var to_player := player_pos - enemy_pos
	var goal_pos := enemy_pos + base_dir * ENEMY_WALL_AVOIDANCE_FALLBACK_DISTANCE
	var to_player_dist_sq := to_player.length_squared()
	if to_player_dist_sq > 0.01 and base_dir.dot(to_player / sqrt(to_player_dist_sq)) > 0.35:
		goal_pos = player_pos
	var avoid_dir := wall_avoidance_direction(enemy, enemy_pos, goal_pos, radius, walls)
	var safe_avoid_dir := forward_safe_avoidance_dir(base_dir, avoid_dir)
	var move_dir := blended_enemy_move_dir(base_dir, safe_avoid_dir, dir_power)
	if avoid_dir.length() <= 0.1:
		enemy.erase("wallAvoidX")
		enemy.erase("wallAvoidY")

	var previous_pos := enemy_pos
	var expected_distance := speed * delta * dir_power
	var moved_pos := enemy_pos + move_dir * speed * delta
	moved_pos = clamp_enemy_pos_to_arena(moved_pos, arena)
	moved_pos = resolve_enemy_wall_collision(moved_pos, previous_pos, radius, walls)
	moved_pos = clamp_enemy_pos_to_arena(moved_pos, arena)
	var moved_step := moved_pos - previous_pos
	var moved_forward_enough := moved_step.dot(base_dir) >= expected_distance * 0.18
	var moved_distance_sq := moved_pos.distance_squared_to(previous_pos)
	var moved_min_distance := expected_distance * 0.3
	if avoid_dir.length() <= 0.1 or (moved_distance_sq >= moved_min_distance * moved_min_distance and (not bool(enemy.get("isBoss", false)) or moved_forward_enough)):
		return moved_pos

	if safe_avoid_dir.length() <= 0.1:
		return moved_pos

	var fallback_pos := enemy_pos + safe_avoid_dir * speed * delta * dir_power
	fallback_pos = clamp_enemy_pos_to_arena(fallback_pos, arena)
	fallback_pos = resolve_enemy_wall_collision(fallback_pos, previous_pos, radius, walls)
	fallback_pos = clamp_enemy_pos_to_arena(fallback_pos, arena)
	var fallback_step := fallback_pos - previous_pos
	var best_pos := moved_pos
	if fallback_step.dot(base_dir) >= -0.01 and fallback_pos.distance_squared_to(previous_pos) > moved_distance_sq:
		best_pos = fallback_pos
	if bool(enemy.get("isBoss", false)):
		var unstick_pos := enemy_pos + base_dir * speed * delta * dir_power * BOSS_WALL_UNSTICK_STEP_RATE
		unstick_pos = clamp_enemy_pos_to_arena(unstick_pos, arena)
		var unstick_step := unstick_pos - previous_pos
		var best_step := best_pos - previous_pos
		if unstick_step.dot(base_dir) > best_step.dot(base_dir) + 0.01:
			return unstick_pos
	return best_pos

static func append_defeat_fx_for_target(target: Node, enemy: Dictionary, is_boss: bool = false) -> void:
	if bool(enemy.get("defeatFxSpawned", false)):
		return
	enemy["defeatFxSpawned"] = true
	var hit_fx: Array = target.get("hit_fx") as Array
	var radius: float = float(enemy.get("radius", 22.0))
	hit_fx.append({
		"kind": "enemy_defeat",
		"pos": Vector2(enemy.get("pos", Vector2.ZERO)),
		"radius": radius,
		"life": 0.44 if is_boss else 0.28,
		"maxLife": 0.44 if is_boss else 0.28,
		"boss": is_boss
	})
	target.set("hit_fx", hit_fx)

static func update_enemy_world(context: Dictionary) -> Dictionary:
	var result: Dictionary = {
		"bullets": context["bullets"],
		"damageEvents": []
	}
	var enemy_result: Dictionary = update_enemies(context)
	result["bullets"] = enemy_result["bullets"]
	_merge_damage_events(result, enemy_result)
	var bullet_result: Dictionary = update_enemy_bullets({
		"delta": context["delta"],
		"bullets": result["bullets"],
		"playerPos": context["playerPos"],
		"arena": context["arena"],
		"bulletHell": context["bulletHell"]
	})
	result["bullets"] = bullet_result["bullets"]
	_merge_damage_events(result, bullet_result)
	return result

static func update_world_for_target(target: Node, delta: float, rng: RandomNumberGenerator, arena: Rect2) -> Dictionary:
	var result: Dictionary = update_enemy_world({
		"delta": delta,
		"rng": rng,
		"enemies": target.get("enemies"),
		"bullets": target.get("enemy_bullets"),
		"playerPos": target.get("player_pos"),
		"arena": arena,
		"enemySpeedRate": ModifierSystem.effect_rate_for_target(target, "enemy_speed"),
		"godReservation": ModifierSystem.has_effect_for_target(target, "god_reservation"),
		"godReservationRate": ModifierSystem.effect_rate_for_target(target, "god_reservation"),
		"songEnemyMoveMultiplier": float(target.call("_song_enemy_move_speed_multiplier")) if target.has_method("_song_enemy_move_speed_multiplier") else 1.0,
		"bulletHell": String(target.get("active_genre_event")) == "bullet_hell",
		"effectWalls": target.get("effect_walls"),
		"streamFrameId": target.get("current_stream_frame_id")
	})
	target.set("enemy_bullets", result["bullets"])
	apply_pending_defeats_for_target(target, result, arena, rng)
	return result

static func apply_pending_defeats_for_target(target: Node, result: Dictionary, arena: Rect2, rng: RandomNumberGenerator) -> void:
	var enemies: Array = target.get("enemies") as Array
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item
		if not bool(enemy.get("defeatPending", false)):
			continue
		if bool(enemy.get("defeatResolved", false)):
			continue
		if bool(enemy.get("isBoss", false)) and not bool(enemy.get("defeatReactionApplied", false)):
			enemy["defeatReactionApplied"] = true
			merge_kill_feedback(result, {
				"screenShakePower": 0.55,
				"screenShakeDuration": 0.25,
				"hitStop": 0.10,
				"screenFlashColor": Color(1.0, 0.94, 0.50, 0.34),
				"screenFlashDuration": 0.16
			})
		if float(enemy.get("defeatDelay", 0.0)) > 0.0:
			continue
		enemy["defeatResolved"] = true
		var kill_result: Dictionary = apply_kill_for_target(target, enemy, arena, rng)
		merge_kill_feedback(result, kill_result)
	var current_enemies: Array = target.get("enemies") as Array
	var kept_enemies: Array = []
	for enemy_item in current_enemies:
		if should_keep_enemy(enemy_item):
			kept_enemies.append(enemy_item)
	target.set("enemies", kept_enemies)

static func merge_kill_feedback(target: Dictionary, source: Dictionary) -> void:
	var chats: Array = target.get("chats", []) as Array
	var chat: String = String(source.get("chat", ""))
	if chat != "":
		chats.append(chat)
	for item in (source.get("chats", []) as Array):
		chats.append(String(item))
	target["chats"] = chats
	var comment_event_ids: Array = target.get("commentEventIds", []) as Array
	for item in (source.get("commentEventIds", []) as Array):
		var event_id := String(item)
		if event_id != "" and not comment_event_ids.has(event_id):
			comment_event_ids.append(event_id)
	if not comment_event_ids.is_empty():
		target["commentEventIds"] = comment_event_ids
	var toasts: Array = target.get("toasts", []) as Array
	for item in (source.get("toasts", []) as Array):
		toasts.append(String(item))
	if not toasts.is_empty():
		target["toasts"] = toasts
	if float(source.get("screenShakePower", 0.0)) > float(target.get("screenShakePower", 0.0)):
		target["screenShakePower"] = float(source.get("screenShakePower", 0.0))
	if float(source.get("screenShakeDuration", 0.0)) > float(target.get("screenShakeDuration", 0.0)):
		target["screenShakeDuration"] = float(source.get("screenShakeDuration", 0.0))
	if float(source.get("hitStop", 0.0)) > float(target.get("hitStop", 0.0)):
		target["hitStop"] = float(source.get("hitStop", 0.0))
	if float(source.get("screenFlashDuration", 0.0)) > float(target.get("screenFlashDuration", 0.0)):
		target["screenFlashDuration"] = float(source.get("screenFlashDuration", 0.0))
		target["screenFlashColor"] = source.get("screenFlashColor", Color.WHITE)
	var marshmallow_drop_requests: Array = target.get("marshmallowDropRequests", []) as Array
	for item in (source.get("marshmallowDropRequests", []) as Array):
		marshmallow_drop_requests.append(item)
	if not marshmallow_drop_requests.is_empty():
		target["marshmallowDropRequests"] = marshmallow_drop_requests
	if bool(source.get("enemyDefeated", false)):
		target["enemyDefeated"] = true

static func _merge_damage_events(target: Dictionary, source: Dictionary) -> void:
	var target_items: Array = target.get("damageEvents", []) as Array
	var source_items: Array = source.get("damageEvents", []) as Array
	for item in source_items:
		target_items.append(item)

static func update_enemies(context: Dictionary) -> Dictionary:
	var result: Dictionary = {
		"bullets": context["bullets"],
		"damageEvents": [],
		"chats": []
	}
	var damage_events: Array = result["damageEvents"] as Array
	var bullets: Array = context["bullets"] as Array
	var enemies: Array = context["enemies"] as Array
	var rng: RandomNumberGenerator = context["rng"] as RandomNumberGenerator
	var delta: float = float(context["delta"])
	var player_pos: Vector2 = Vector2(context["playerPos"])
	var arena: Rect2 = context["arena"] as Rect2
	var effect_walls: Array = context["effectWalls"] as Array
	var stream_frame_id: String = String(context["streamFrameId"])
	var walls: Array = movement_wall_rects(effect_walls, stream_frame_id)
	var speed_rate: float = 1.0 + 0.45 * float(context["enemySpeedRate"])
	if bool(context["godReservation"]):
		speed_rate += 0.10 * float(context["godReservationRate"])
	speed_rate *= maxf(0.1, float(context.get("songEnemyMoveMultiplier", 1.0)))
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item
		var enemy_pos: Vector2 = Vector2(enemy["pos"])
		var previous_enemy_pos: Vector2 = enemy_pos
		enemy["hitFlashTimer"] = maxf(0.0, float(enemy.get("hitFlashTimer", 0.0)) - delta)
		if bool(enemy.get("defeatPending", false)):
			enemy_pos = apply_knockback_motion(enemy, enemy_pos, previous_enemy_pos, delta, arena, effect_walls, stream_frame_id)
			enemy["pos"] = enemy_pos
			enemy["defeatDelay"] = maxf(0.0, float(enemy.get("defeatDelay", 0.0)) - delta)
			continue
		var stun_timer: float = float(enemy.get("stunTimer", 0.0))
		if stun_timer > 0.0:
			enemy["stunTimer"] = maxf(0.0, stun_timer - delta)
			enemy_pos = apply_knockback_motion(enemy, enemy_pos, previous_enemy_pos, delta, arena, effect_walls, stream_frame_id)
			enemy["pos"] = enemy_pos
			continue
		var behavior: String = String(enemy["behavior"])
		var to_player: Vector2 = player_pos - enemy_pos
		var dist: float = to_player.length()
		var to_player_dir := to_player / dist if dist > 0.1 else Vector2.ZERO
		var dir: Vector2 = to_player_dir
		var local_speed_rate: float = 1.0 if bool(enemy.get("isBoss", false)) else speed_rate
		var speed: float = float(enemy["speed"]) * local_speed_rate
		var slow_timer: float = float(enemy.get("slowTimer", 0.0))
		if slow_timer > 0.0:
			var slow_rate: float = clampf(float(enemy.get("slowRate", 0.0)), 0.0, 0.85)
			speed *= 1.0 - slow_rate
			enemy["slowTimer"] = maxf(0.0, slow_timer - delta)
		if behavior == "shooter":
			if dist < 250.0:
				dir *= -1.0
			elif dist < 360.0:
				dir = Vector2.ZERO
			enemy["shoot"] = float(enemy["shoot"]) - delta
			if float(enemy["shoot"]) <= 0.0 and dist < 650.0:
				enemy["shoot"] = rng.randf_range(SHOOTER_FIRE_INTERVAL_MIN, SHOOTER_FIRE_INTERVAL_MAX)
				if bullets.size() < MAX_ENEMY_BULLETS:
					bullets.append({"pos": enemy_pos, "vel": to_player_dir * 260.0, "life": SHOOTER_BULLET_LIFE, "damage": DamageSystem.ENEMY_BULLET_DAMAGE})
		elif behavior == "zigzag_chase":
			var base_dir := to_player_dir
			if base_dir.length() < 0.1:
				base_dir = Vector2.RIGHT
			var phase := float(enemy.get("movePhase", 0.0)) + delta * 3.25
			enemy["movePhase"] = phase
			var side := Vector2(-base_dir.y, base_dir.x) * sin(phase) * 0.46
			dir = (base_dir + side).normalized()
			enemy["shoot"] = float(enemy["shoot"]) - delta
			var dash_timer := maxf(0.0, float(enemy.get("dashTimer", 0.0)) - delta)
			if float(enemy["shoot"]) <= 0.0 and dist < 540.0:
				enemy["shoot"] = rng.randf_range(3.7, 4.8)
				dash_timer = 0.34
			if dash_timer > 0.0:
				dir = base_dir * 2.25
			enemy["dashTimer"] = dash_timer
		elif behavior == "keep_distance_shooter":
			var preferred_distance := 260.0
			if dist < preferred_distance - 45.0:
				dir *= -1.0
			elif dist > preferred_distance + 85.0:
				dir *= 0.72
			else:
				dir = Vector2.ZERO
			enemy["shoot"] = float(enemy["shoot"]) - delta
			if float(enemy["shoot"]) <= 0.0 and dist < 720.0:
				enemy["shoot"] = rng.randf_range(ARMCHAIR_FIRE_INTERVAL_MIN, ARMCHAIR_FIRE_INTERVAL_MAX)
				if bullets.size() < MAX_ENEMY_BULLETS:
					var bullet_dir := to_player_dir
					if bullet_dir.length() < 0.1:
						bullet_dir = Vector2.RIGHT
					bullets.append({"pos": enemy_pos + bullet_dir * 18.0, "vel": bullet_dir * 245.0, "life": ARMCHAIR_BULLET_LIFE, "damage": DamageSystem.ENEMY_BULLET_DAMAGE, "hitRadius": 18.0, "source": "enemy bullet", "visualKind": "armchair_comment"})
		elif behavior == "stg_side_move":
			var side_dir := float(enemy.get("sideMoveDir", 1.0))
			if enemy_pos.x < arena.position.x + 90.0:
				side_dir = 1.0
			elif enemy_pos.x > arena.end.x - 90.0:
				side_dir = -1.0
			enemy["sideMoveDir"] = side_dir
			var phase := float(enemy.get("movePhase", 0.0)) + delta * 2.65
			enemy["movePhase"] = phase
			dir = (Vector2(side_dir, sin(phase) * 0.38).normalized() * 0.86) + to_player_dir * 0.18
			if dir.length() > 1.0:
				dir = dir.normalized()
			enemy["shoot"] = float(enemy["shoot"]) - delta
			if float(enemy["shoot"]) <= 0.0 and dist < 720.0:
				enemy["shoot"] = rng.randf_range(DOT_INVADER_FIRE_INTERVAL_MIN, DOT_INVADER_FIRE_INTERVAL_MAX)
				if bullets.size() < MAX_ENEMY_BULLETS:
					var bullet_dir := to_player_dir
					if bullet_dir.length() < 0.1:
						bullet_dir = Vector2.DOWN
					bullets.append({"pos": enemy_pos + bullet_dir * 16.0, "vel": bullet_dir * 230.0, "life": DOT_INVADER_BULLET_LIFE, "damage": DamageSystem.ENEMY_BULLET_DAMAGE, "hitRadius": 15.0, "source": "enemy bullet", "visualKind": "dot_invader_bullet"})
		elif behavior == "chase_with_short_warp":
			var lag_base_dir := to_player_dir
			if lag_base_dir.length() < 0.1:
				lag_base_dir = Vector2.RIGHT
			var lag_phase := float(enemy.get("movePhase", 0.0)) + delta * 3.8
			enemy["movePhase"] = lag_phase
			var lag_side := Vector2(-lag_base_dir.y, lag_base_dir.x) * sin(lag_phase) * 0.22
			dir = (lag_base_dir + lag_side).normalized()
			var warp_warning_timer := float(enemy.get("warpWarningTimer", 0.0))
			if warp_warning_timer > 0.0:
				warp_warning_timer = maxf(0.0, warp_warning_timer - delta)
				enemy["warpWarningTimer"] = warp_warning_timer
				dir *= 0.28
				if warp_warning_timer <= 0.0:
					var orbit_sign := -1.0 if int(enemy.get("uid", 0)) % 2 == 0 else 1.0
					var orbit_dir := Vector2(-lag_base_dir.y, lag_base_dir.x) * orbit_sign
					var warp_dir := (lag_base_dir * 0.58 + orbit_dir * 0.42).normalized()
					var warp_distance := rng.randf_range(LAG_WARP_DISTANCE_MIN, LAG_WARP_DISTANCE_MAX)
					enemy_pos = clamp_enemy_pos_to_arena(enemy_pos + warp_dir * warp_distance, arena)
					enemy["hitFlashTimer"] = maxf(float(enemy.get("hitFlashTimer", 0.0)), 0.08)
					enemy["shoot"] = rng.randf_range(LAG_WARP_COOLDOWN_MIN, LAG_WARP_COOLDOWN_MAX)
			else:
				enemy["shoot"] = float(enemy["shoot"]) - delta
				if float(enemy["shoot"]) <= 0.0 and dist < 620.0:
					enemy["warpWarningTimer"] = LAG_WARP_WARNING_TIME
		elif behavior == "slow_spread_shooter":
			var wiki_preferred_distance := 300.0
			if dist < wiki_preferred_distance - 50.0:
				dir *= -0.55
			elif dist > wiki_preferred_distance + 100.0:
				dir *= 0.48
			else:
				var wiki_phase := float(enemy.get("movePhase", 0.0)) + delta * 1.8
				enemy["movePhase"] = wiki_phase
				var wiki_base := to_player_dir
				if wiki_base.length() < 0.1:
					wiki_base = Vector2.RIGHT
				dir = Vector2(-wiki_base.y, wiki_base.x) * sin(wiki_phase) * 0.34
			enemy["shoot"] = float(enemy["shoot"]) - delta
			if float(enemy["shoot"]) <= 0.0 and dist < 740.0:
				enemy["shoot"] = rng.randf_range(WIKI_FIRE_INTERVAL_MIN, WIKI_FIRE_INTERVAL_MAX)
				var wiki_bullet_dir := to_player_dir
				if wiki_bullet_dir.length() < 0.1:
					wiki_bullet_dir = Vector2.RIGHT
				for angle in [-0.18, 0.0, 0.18]:
					if bullets.size() >= MAX_ENEMY_BULLETS:
						break
					var spread_dir := wiki_bullet_dir.rotated(angle)
					bullets.append({"pos": enemy_pos + spread_dir * 22.0, "vel": spread_dir * 210.0, "life": WIKI_BULLET_LIFE, "damage": DamageSystem.ENEMY_BULLET_DAMAGE, "hitRadius": 15.0, "source": "enemy bullet", "visualKind": "wiki_comment"})
		elif behavior == "ambush_chase":
			var ambush_base_dir := to_player_dir
			if ambush_base_dir.length() < 0.1:
				ambush_base_dir = Vector2.RIGHT
			if dist < 180.0:
				enemy["ambushActive"] = true
			if bool(enemy.get("ambushActive", false)):
				speed *= 2.65
				enemy["hitFlashTimer"] = maxf(float(enemy.get("hitFlashTimer", 0.0)), 0.03)
			dir = ambush_base_dir
		elif behavior == "linear_pass":
			var pass_life := float(enemy.get("lifeTimer", 5.4)) - delta
			enemy["lifeTimer"] = pass_life
			if pass_life <= 0.0:
				enemy["defeatResolved"] = true
				enemy["pos"] = enemy_pos
				continue
			var pass_dir := Vector2(enemy.get("passDir", Vector2.ZERO))
			if pass_dir.length() < 0.1:
				var center := arena.get_center()
				var pass_noise := sin(float(int(enemy.get("uid", 0))) * 12.9898) * 0.16
				if absf(enemy_pos.x - center.x) >= absf(enemy_pos.y - center.y):
					pass_dir = Vector2(-1.0 if enemy_pos.x > center.x else 1.0, pass_noise).normalized()
				else:
					pass_dir = Vector2(pass_noise, -1.0 if enemy_pos.y > center.y else 1.0).normalized()
				enemy["passDir"] = pass_dir
			dir = pass_dir
		elif behavior == "stationary_obstacle":
			var obstacle_life := float(enemy.get("lifeTimer", 8.0)) - delta
			enemy["lifeTimer"] = obstacle_life
			if obstacle_life <= 0.0:
				enemy["defeatResolved"] = true
				enemy["pos"] = enemy_pos
				continue
			dir = Vector2.ZERO
		elif behavior == "drone_keep_distance":
			var drone_base := to_player_dir
			if drone_base.length() < 0.1:
				drone_base = Vector2.DOWN
			var drone_phase := float(enemy.get("movePhase", 0.0)) + delta * 2.25
			enemy["movePhase"] = drone_phase
			var drone_side := Vector2(-drone_base.y, drone_base.x) * sin(drone_phase) * 0.52
			var drone_preferred_distance := 320.0
			if dist < drone_preferred_distance - 60.0:
				dir = (-drone_base + drone_side * 0.55).normalized()
			elif dist > drone_preferred_distance + 110.0:
				dir = (drone_base * 0.65 + drone_side * 0.35).normalized()
			else:
				dir = drone_side.normalized() * 0.58
			enemy["shoot"] = float(enemy["shoot"]) - delta
			if float(enemy["shoot"]) <= 0.0 and dist < 760.0:
				enemy["shoot"] = rng.randf_range(DRONE_FIRE_INTERVAL_MIN, DRONE_FIRE_INTERVAL_MAX)
				for angle in [-0.24, 0.0, 0.24]:
					if bullets.size() >= MAX_ENEMY_BULLETS:
						break
					var drone_bullet_dir := drone_base.rotated(angle)
					bullets.append({"pos": enemy_pos + drone_bullet_dir * 20.0, "vel": drone_bullet_dir * 250.0, "life": DRONE_BULLET_LIFE, "damage": DamageSystem.ENEMY_BULLET_DAMAGE, "hitRadius": 14.0, "source": "enemy bullet", "visualKind": "drone_bullet"})
		elif behavior == "ghost_chase":
			var ghost_base := to_player_dir
			if ghost_base.length() < 0.1:
				ghost_base = Vector2.RIGHT
			var ghost_phase := float(enemy.get("phaseTimer", 0.0)) + delta * 2.2
			enemy["phaseTimer"] = ghost_phase
			var ghost_side := Vector2(-ghost_base.y, ghost_base.x) * sin(ghost_phase) * 0.30
			speed *= 0.86 + 0.12 * sin(ghost_phase * 0.7)
			dir = (ghost_base + ghost_side).normalized()
		elif behavior == "charger":
			enemy["shoot"] = float(enemy["shoot"]) - delta
			if float(enemy["shoot"]) < -0.35:
				enemy["shoot"] = rng.randf_range(1.2, 2.0)
			elif float(enemy["shoot"]) <= 0.0:
				dir = to_player_dir * 3.2
			else:
				dir *= 0.55
		enemy_pos = move_enemy_with_wall_avoidance(enemy, enemy_pos, dir, speed, delta, arena, walls, player_pos)
		enemy_pos = apply_knockback_motion(enemy, enemy_pos, enemy_pos, delta, arena, effect_walls, stream_frame_id)
		enemy["pos"] = enemy_pos
		var contact_radius: float = float(enemy["radius"]) + 22.0
		if enemy_pos.distance_squared_to(player_pos) < contact_radius * contact_radius:
			var contact_source: String = String(enemy["kind"]) + " contact"
			var contact_damage: int = int(enemy.get("contactDamage", contact_damage_for_kind(String(enemy["kind"]), bool(enemy.get("isBoss", false)))))
			damage_events.append({"source": contact_source, "damage": contact_damage})
	result["bullets"] = bullets
	return result

static func update_enemy_bullets(context: Dictionary) -> Dictionary:
	var result: Dictionary = {
		"bullets": context["bullets"],
		"damageEvents": []
	}
	var damage_events: Array = result["damageEvents"] as Array
	var bullets: Array = context["bullets"] as Array
	var delta: float = float(context["delta"])
	var player_pos: Vector2 = Vector2(context["playerPos"])
	var arena: Rect2 = context["arena"] as Rect2
	var bullet_hit_rate: float = 0.8 if bool(context["bulletHell"]) else 1.0
	for bullet_item in bullets:
		var bullet: Dictionary = bullet_item
		bullet["pos"] = Vector2(bullet["pos"]) + Vector2(bullet["vel"]) * delta
		bullet["life"] = float(bullet["life"]) - delta
		var hit_radius: float = float(bullet.get("hitRadius", 22.0)) * bullet_hit_rate
		var bullet_pos: Vector2 = Vector2(bullet["pos"])
		if bullet_pos.distance_squared_to(player_pos) < hit_radius * hit_radius:
			bullet["life"] = -1.0
			damage_events.append({"source": String(bullet.get("source", "enemy bullet")), "damage": int(bullet.get("damage", DamageSystem.ENEMY_BULLET_DAMAGE))})
	var bullet_keep_area: Rect2 = arena.grow(80.0)
	var kept_bullets: Array = []
	for bullet_item in bullets:
		var bullet: Dictionary = bullet_item
		if float(bullet["life"]) > 0.0 and bullet_keep_area.has_point(Vector2(bullet["pos"])):
			kept_bullets.append(bullet)
	result["bullets"] = kept_bullets
	return result
