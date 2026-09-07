class_name StreamMissionRunTracker
extends RefCounted

const TrackerScript := preload("res://scripts/systems/stream_mission_run_tracker.gd")
const VALID_STAGE_IDS := ["zatsudan", "gameplay", "singing", "drawing", "collab"]
const VALID_DIFFICULTIES := ["normal", "hard", "expert"]
const NORMAL_INK_BITS := {"pink": 1, "cyan": 2, "green": 4, "yellow": 8}
const RELAY_MINI_BITS := {"zatsudan": 1, "gameplay": 2, "singing": 4, "drawing": 8, "collab": 16}

var run_id := ""
var stage_id := ""
var difficulty_id := "normal"
var relay_mode := false
var formal_menu_origin := false
var quick_test_mode := false
var official_run_eligible := false
var debug_contaminated := false

var non_heart_comment_count := 0
var risk_comment_count := 0
var song_heat_level_reached := 0
var song_lv5_playing_seconds := 0.0
var song_lv5_boss_defeated := false
var song_lv5_boss_heat_level := 0
var drawing_color_bits := 0
var defeated_bosses: Array[Dictionary] = []
var player_side_boss_defeats: Array[String] = []
var relay_final_preparation_ready := false
var relay_final_preparation_snapshot: Dictionary = {}
var relay_mini_condition_bits := 0
var relay_segment_dangerous_comment_count := 0
var relay_segment_genre_event_clear_count := 0
var relay_segment_drawing_color_bits := 0
var relay_segment_collab_challenge_success_count := 0

static func start(formal_origin: bool, stage: String, difficulty: String, is_relay: bool, is_quick_test: bool = false):
	var tracker := TrackerScript.new()
	tracker.begin(formal_origin, stage, difficulty, is_relay, is_quick_test)
	return tracker

func begin(formal_origin: bool, stage: String, difficulty: String, is_relay: bool, is_quick_test: bool = false) -> void:
	stage_id = stage.strip_edges().to_lower()
	difficulty_id = difficulty.strip_edges().to_lower()
	relay_mode = is_relay
	formal_menu_origin = formal_origin
	quick_test_mode = is_quick_test
	debug_contaminated = false
	official_run_eligible = formal_origin and not is_quick_test and _valid_origin()
	non_heart_comment_count = 0
	risk_comment_count = 0
	song_heat_level_reached = 0
	song_lv5_playing_seconds = 0.0
	song_lv5_boss_defeated = false
	song_lv5_boss_heat_level = 0
	drawing_color_bits = 0
	defeated_bosses.clear()
	player_side_boss_defeats.clear()
	relay_final_preparation_ready = false
	relay_final_preparation_snapshot.clear()
	relay_mini_condition_bits = 0
	_reset_relay_segment_counters()

func begin_relay_segment(segment_id: String) -> void:
	stage_id = segment_id.strip_edges().to_lower()
	_reset_relay_segment_counters()

func mark_debug_contaminated() -> void:
	debug_contaminated = true
	official_run_eligible = false

func record_comment(applied_risk_level: int, has_heart: bool) -> void:
	if stage_id != "zatsudan":
		return
	if not has_heart:
		non_heart_comment_count += 1
	if applied_risk_level >= 3:
		risk_comment_count += 1
		if relay_mode:
			relay_segment_dangerous_comment_count += 1

func record_song_heat_level(level: int) -> void:
	if stage_id != "singing":
		return
	song_heat_level_reached = maxi(song_heat_level_reached, level)

func add_song_lv5_playing_seconds(seconds: float, heat_level: int) -> void:
	if stage_id != "singing" or heat_level < 5 or seconds <= 0.0:
		return
	song_lv5_playing_seconds += seconds
	song_heat_level_reached = maxi(song_heat_level_reached, heat_level)

func record_drawing_color(color_id: String) -> void:
	var bit := int(NORMAL_INK_BITS.get(color_id.strip_edges().to_lower(), 0))
	if bit == 0:
		return
	drawing_color_bits |= bit
	if relay_mode and stage_id == "drawing":
		relay_segment_drawing_color_bits |= bit

func record_collab_challenge_success() -> void:
	if relay_mode and stage_id == "collab":
		relay_segment_collab_challenge_success_count += 1

func record_relay_genre_event_clear() -> void:
	if relay_mode and stage_id == "gameplay":
		relay_segment_genre_event_clear_count += 1

func register_boss_defeat(data: Dictionary) -> bool:
	var defeat := data.duplicate(true)
	var boss_id := String(defeat.get("bossId", defeat.get("ppRewardId", ""))).strip_edges()
	var formal_boss_id := String(defeat.get("ppRewardId", boss_id)).strip_edges()
	var reason := String(defeat.get("defeatReason", "")).strip_edges()
	if boss_id == "":
		return false
	defeat["bossId"] = boss_id
	defeated_bosses.append(defeat)
	# Pair skills are an active player-side attack, while partner support is
	# deliberately kept out of the formal boss-defeat record.
	var player_side_defeat := reason == "player_side_damage" or reason == "collab_skill"
	if player_side_defeat and not player_side_boss_defeats.has(formal_boss_id):
		player_side_boss_defeats.append(formal_boss_id)
	if formal_boss_id == "pitch_police_chief" and player_side_defeat:
		var heat := int(defeat.get("heatLevel", 0))
		if heat >= 5:
			song_lv5_boss_defeated = true
			song_lv5_boss_heat_level = maxi(song_lv5_boss_heat_level, heat)
	return true

func capture_relay_final_preparation(snapshot: Dictionary) -> bool:
	if relay_final_preparation_ready or snapshot.is_empty():
		return false
	relay_final_preparation_snapshot = snapshot.duplicate(true)
	relay_final_preparation_ready = true
	return true

func record_relay_segment(segment: String, stats: Dictionary = {}) -> int:
	if not relay_mode:
		return relay_mini_condition_bits
	var id := segment.strip_edges().to_lower()
	var bit := int(RELAY_MINI_BITS.get(id, 0))
	if bit == 0:
		return relay_mini_condition_bits
	var achieved := false
	match id:
		"zatsudan":
			achieved = maxi(relay_segment_dangerous_comment_count, int(stats.get("dangerousCommentCount", 0))) >= 3
		"gameplay":
			achieved = maxi(relay_segment_genre_event_clear_count, int(stats.get("genreEventClearCount", 0))) >= 1
		"singing":
			achieved = maxi(song_heat_level_reached, int(stats.get("maxLiveHeatLevel", 0))) >= 4
		"drawing":
			achieved = _bit_count(relay_segment_drawing_color_bits | int(stats.get("drawingColorBits", 0))) >= 2
		"collab":
			achieved = maxi(relay_segment_collab_challenge_success_count, int(stats.get("challengeSuccessCount", 0))) >= 1
	if achieved:
		relay_mini_condition_bits |= bit
	_reset_relay_segment_counters()
	return relay_mini_condition_bits

func relay_final_preparation_has_ready_weapon(required_level: int = 5) -> bool:
	if not relay_final_preparation_ready:
		return false
	var entries: Variant = relay_final_preparation_snapshot.get("weapons", [])
	if not entries is Array:
		return false
	for item in entries as Array:
		if not item is Dictionary:
			continue
		var entry := item as Dictionary
		var level_text := str(entry.get("level", ""))
		if bool(entry.get("isEvolved", false)) or level_text in ["evolved", "進化"]:
			return true
		if int(entry.get("level", 0)) >= required_level:
			return true
	return false

func to_dictionary() -> Dictionary:
	return {
		"runId": run_id,
		"stageId": stage_id,
		"difficultyId": difficulty_id,
		"relayMode": relay_mode,
		"formalMenuOrigin": formal_menu_origin,
		"quickTestMode": quick_test_mode,
		"officialRunEligible": official_run_eligible,
		"debugContaminated": debug_contaminated,
		"nonHeartCommentCount": non_heart_comment_count,
		"riskCommentCount": risk_comment_count,
		"songHeatLevelReached": song_heat_level_reached,
		"songLv5PlayingSeconds": song_lv5_playing_seconds,
		"songLv5BossDefeated": song_lv5_boss_defeated,
		"songLv5BossHeatLevel": song_lv5_boss_heat_level,
		"drawingColorBits": drawing_color_bits,
		"defeatedBosses": defeated_bosses.duplicate(true),
		"playerSideBossDefeats": player_side_boss_defeats.duplicate(),
		"relayFinalPreparationReady": relay_final_preparation_ready,
		"relayFinalPreparationSnapshot": relay_final_preparation_snapshot.duplicate(true),
		"relayMiniConditionBits": relay_mini_condition_bits
	}

func _valid_origin() -> bool:
	if difficulty_id not in VALID_DIFFICULTIES:
		return false
	if relay_mode:
		return stage_id == "relay"
	return stage_id in VALID_STAGE_IDS

func _reset_relay_segment_counters() -> void:
	relay_segment_dangerous_comment_count = 0
	relay_segment_genre_event_clear_count = 0
	relay_segment_drawing_color_bits = 0
	relay_segment_collab_challenge_success_count = 0

func _bit_count(value: int) -> int:
	var count := 0
	var bits := value
	while bits != 0:
		count += bits & 1
		bits = bits >> 1
	return count
