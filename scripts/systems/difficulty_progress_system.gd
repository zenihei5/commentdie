class_name DifficultyProgressSystem
extends RefCounted

## Difficulty progression and stage-select persistence.
## streamFrameProgress is kept as a NORMAL compatibility projection.

const PROGRESS_PATH: String = "user://stream_frame_progress.json"
const RANKINGS_PATH: String = "user://rankings.json"
const SAVE_VERSION: int = 6
const UnlockPresentationSystemScript := preload("res://scripts/systems/unlock_presentation_system.gd")

const DIFFICULTY_NORMAL: String = "normal"
const DIFFICULTY_HARD: String = "hard"
const DIFFICULTY_EXPERT: String = "expert"
const DIFFICULTY_IDS: Array[String] = [DIFFICULTY_NORMAL, DIFFICULTY_HARD, DIFFICULTY_EXPERT]

const STAGE_ZATSUDAN: String = "zatsudan"
const STAGE_GAMEPLAY: String = "gameplay"
const STAGE_SINGING: String = "singing"
const STAGE_DRAWING: String = "drawing"
const STAGE_COLLAB: String = "collab"
const STAGE_RELAY: String = "relay"
const STANDARD_STAGE_IDS: Array[String] = [STAGE_ZATSUDAN, STAGE_GAMEPLAY, STAGE_SINGING, STAGE_DRAWING, STAGE_COLLAB]
const ALL_STAGE_IDS: Array[String] = [STAGE_ZATSUDAN, STAGE_GAMEPLAY, STAGE_SINGING, STAGE_DRAWING, STAGE_COLLAB, STAGE_RELAY]
const DEFAULT_STAGE_ID: String = STAGE_ZATSUDAN

const STAGE_ALIASES: Dictionary = {
	"talk": STAGE_ZATSUDAN,
	"chat": STAGE_ZATSUDAN,
	"zatsudan": STAGE_ZATSUDAN,
	"game": STAGE_GAMEPLAY,
	"gameplay": STAGE_GAMEPLAY,
	"song": STAGE_SINGING,
	"singing": STAGE_SINGING,
	"drawing": STAGE_DRAWING,
	"collab": STAGE_COLLAB,
	"relay": STAGE_RELAY
}
const DIFFICULTY_NAMES: Dictionary = {
	DIFFICULTY_NORMAL: "NORMAL",
	DIFFICULTY_HARD: "HARD",
	DIFFICULTY_EXPERT: "EXPERT"
}
const STAGE_COMPLEXITIES: Dictionary = {
	STAGE_ZATSUDAN: 1,
	STAGE_GAMEPLAY: 2,
	STAGE_SINGING: 3,
	STAGE_DRAWING: 4,
	STAGE_COLLAB: 3,
	STAGE_RELAY: 5
}

static func _default_unlock_presentation_state() -> Dictionary:
	return UnlockPresentationSystemScript.create_state([], [], true, false)

static func source_has_unlock_presentation(value: Variant) -> bool:
	if not value is Dictionary:
		return false
	var source: Dictionary = value as Dictionary
	var state: Variant = source.get("unlockPresentation", null)
	return state is Dictionary and bool((state as Dictionary).get("initialized", false))

static func _unlock_presentation_state(progress: Dictionary) -> Dictionary:
	return UnlockPresentationSystemScript.normalize_state(progress.get("unlockPresentation", {}))

static func _unlocked_presentation_ids(snapshot: Dictionary) -> Array:
	var result: Array = []
	for id in UnlockPresentationSystemScript.ORDER:
		if bool(snapshot.get(id, false)):
			result.append(id)
	return result

static func unlock_presentation_snapshot(progress: Dictionary, senior_unit_unlocked: bool = false) -> Dictionary:
	var snapshot: Dictionary = {}
	var normal := _difficulty_data(progress, DIFFICULTY_NORMAL)
	var hard := _difficulty_data(progress, DIFFICULTY_HARD)
	var expert := _difficulty_data(progress, DIFFICULTY_EXPERT)
	var legacy := _dict(progress.get("streamFrameProgress", {}))
	for stage_id in [STAGE_GAMEPLAY, STAGE_SINGING, STAGE_DRAWING, STAGE_COLLAB]:
		var unlocked := _stage_is_unlocked(progress, DIFFICULTY_NORMAL, stage_id)
		unlocked = unlocked or _safe_bool(_dict(legacy.get(stage_id, {})).get("isUnlocked", false))
		snapshot["stage:" + stage_id] = unlocked
	snapshot["mode:relay"] = bool(_dict(normal.get("relay", {})).get("unlocked", false)) or _safe_bool(progress.get("relayModeUnlocked", false))
	snapshot["difficulty:hard"] = bool(hard.get("unlocked", false))
	snapshot["difficulty:expert"] = bool(expert.get("unlocked", false))
	snapshot["character_group:senior_unit"] = senior_unit_unlocked
	return snapshot

static func unlock_presentation_snapshot_for_target(target: Node) -> Dictionary:
	var progress: Dictionary = _dict(target.get("difficulty_progress"))
	if progress.is_empty():
		progress = load_progress(_array(target.get("stream_frames")))
	var senior_unlocked := false
	var manager: Variant = target.get("power_up_shop_manager")
	if manager != null:
		if manager.has_method("unlocked_character_ids"):
			var unlocked_ids: Array = manager.unlocked_character_ids() as Array
			senior_unlocked = unlocked_ids.has("aosumi_kyasumi") and unlocked_ids.has("akarine_rizumu") and unlocked_ids.has("shizuki_miimu")
		elif manager.get("profile") is Dictionary:
			senior_unlocked = bool((manager.get("profile") as Dictionary).get("normalRelayCleared", false))
	return unlock_presentation_snapshot(progress, senior_unlocked)

static func pending_unlock_presentations_for_target(target: Node) -> Array:
	var progress: Dictionary = _dict(target.get("difficulty_progress"))
	if progress.is_empty():
		return []
	var state := _unlock_presentation_state(progress)
	return (state.get("pendingIds", []) as Array).duplicate()

static func commit_unlock_presentation_for_target(target: Node, before_snapshot: Dictionary) -> Dictionary:
	var progress: Dictionary = _dict(target.get("difficulty_progress"))
	if progress.is_empty():
		return {"saved": false, "ids": [], "pendingIds": []}
	var after_snapshot := unlock_presentation_snapshot_for_target(target)
	var ids := UnlockPresentationSystemScript.false_to_true_ids(before_snapshot, after_snapshot)
	var candidate: Dictionary = progress.duplicate(true)
	var state := UnlockPresentationSystemScript.enqueue_ids(_unlock_presentation_state(candidate), ids)
	candidate["unlockPresentation"] = state
	if not save_progress(candidate):
		return {"saved": false, "ids": ids, "pendingIds": state.get("pendingIds", [])}
	_sync_target(target, candidate, _array(target.get("stream_frames")))
	return {"saved": true, "ids": ids, "pendingIds": state.get("pendingIds", [])}

static func confirm_unlock_presentation_for_target(target: Node, unlock_id: Variant) -> Dictionary:
	var progress: Dictionary = _dict(target.get("difficulty_progress"))
	if progress.is_empty():
		return {"saved": false, "confirmed": false}
	var candidate: Dictionary = progress.duplicate(true)
	var result := UnlockPresentationSystemScript.confirm_id(_unlock_presentation_state(candidate), unlock_id)
	if not bool(result.get("ok", false)):
		return {"saved": true, "confirmed": false}
	candidate["unlockPresentation"] = result.get("state", {})
	if not save_progress(candidate):
		return {"saved": false, "confirmed": false, "id": String(result.get("id", ""))}
	_sync_target(target, candidate, _array(target.get("stream_frames")))
	return {"saved": true, "confirmed": true, "id": String(result.get("id", "")), "pendingIds": (candidate["unlockPresentation"] as Dictionary).get("pendingIds", [])}

static func sync_unlock_presentation_for_target(target: Node) -> Dictionary:
	var progress: Dictionary = _dict(target.get("difficulty_progress"))
	if progress.is_empty():
		return {"saved": false, "migrated": false}
	var state := _unlock_presentation_state(progress)
	if bool(state.get("migrationComplete", false)):
		return {"saved": true, "migrated": false}
	# A real initialized queue may already contain an unlock that was saved
	# before the app closed.  Preserve that pending work; only the empty state
	# is treated as a legacy migration that needs current-unlock seeding.
	var existing_pending: Array = state.get("pendingIds", []) as Array
	if bool(state.get("initialized", false)) and not existing_pending.is_empty():
		state["migrationComplete"] = true
		var pending_candidate: Dictionary = progress.duplicate(true)
		pending_candidate["unlockPresentation"] = state
		if not save_progress(pending_candidate):
			return {"saved": false, "migrated": false}
		_sync_target(target, pending_candidate, _array(target.get("stream_frames")))
		return {"saved": true, "migrated": false}
	var snapshot := unlock_presentation_snapshot_for_target(target)
	state["seenIds"] = UnlockPresentationSystemScript.sort_ids(_unlocked_presentation_ids(snapshot))
	state["pendingIds"] = []
	state["migrationComplete"] = true
	state["initialized"] = true
	var candidate: Dictionary = progress.duplicate(true)
	candidate["unlockPresentation"] = state
	if not save_progress(candidate):
		return {"saved": false, "migrated": true}
	_sync_target(target, candidate, _array(target.get("stream_frames")))
	return {"saved": true, "migrated": true}

static func normalize_difficulty_id(value: Variant) -> String:
	var id := String(value).strip_edges().to_lower()
	if id == DIFFICULTY_HARD:
		return DIFFICULTY_HARD
	if id == DIFFICULTY_EXPERT:
		return DIFFICULTY_EXPERT
	return DIFFICULTY_NORMAL

static func normalize_stage_id(value: Variant) -> String:
	var id := String(value).strip_edges().to_lower()
	if id == "":
		return DEFAULT_STAGE_ID
	if STAGE_ALIASES.has(id):
		return String(STAGE_ALIASES[id])
	return id

static func difficulty_display_name(value: Variant) -> String:
	return String(DIFFICULTY_NAMES.get(normalize_difficulty_id(value), "NORMAL"))

static func stage_display_name(value: Variant) -> String:
	var id := normalize_stage_id(value)
	var names: Dictionary = {
		STAGE_ZATSUDAN: "Talk",
		STAGE_GAMEPLAY: "Gameplay",
		STAGE_SINGING: "Singing",
		STAGE_DRAWING: "Drawing",
		STAGE_COLLAB: "Collab",
		STAGE_RELAY: "配信リレー"
	}
	return String(names.get(id, id))

static func create_default_stage_progress() -> Dictionary:
	return {"played": false, "cleared": false, "firstBossDefeated": false, "reignitionBossDefeated": false, "bestScore": 0, "bestBossCount": 0, "clearCharacterIds": [], "bossDefeatCharacterIds": [], "reignitionDefeatCharacterIds": []}

static func create_default_relay_progress() -> Dictionary:
	return {"unlocked": false, "played": false, "cleared": false, "finalBossDefeated": false, "bestScore": 0, "bestReachedSection": 0, "bestReachedStageId": null, "bestFinalBossPhase": 0, "clearCharacterIds": []}

static func create_default_difficulty_progress() -> Dictionary:
	var stages: Dictionary = {}
	for stage_id in STANDARD_STAGE_IDS:
		stages[stage_id] = create_default_stage_progress()
	return {"unlocked": false, "isNew": false, "stages": stages, "relay": create_default_relay_progress()}

static func _legacy_entry(unlocked: bool = false) -> Dictionary:
	return {"isUnlocked": unlocked, "isCleared": false, "bestViewerCount": 0, "bestKamiRank": null}

static func create_default_save_data(frames: Array = []) -> Dictionary:
	var legacy: Dictionary = {}
	for stage_id in STANDARD_STAGE_IDS:
		legacy[stage_id] = _legacy_entry(stage_id == DEFAULT_STAGE_ID)
	for item in frames:
		if not item is Dictionary:
			continue
		var frame: Dictionary = item as Dictionary
		var stage_id := normalize_stage_id(frame.get("id", ""))
		if STANDARD_STAGE_IDS.has(stage_id):
			legacy[stage_id] = _legacy_entry(_safe_bool(frame.get("initialUnlocked", stage_id == DEFAULT_STAGE_ID)))
	var normal := create_default_difficulty_progress()
	normal["unlocked"] = true
	return {"saveVersion": SAVE_VERSION, "difficulties": {DIFFICULTY_NORMAL: normal, DIFFICULTY_HARD: create_default_difficulty_progress(), DIFFICULTY_EXPERT: create_default_difficulty_progress()}, "stageSelectUi": {"selectedDifficulty": DIFFICULTY_NORMAL, "lastSelectedStageByDifficulty": {DIFFICULTY_NORMAL: DEFAULT_STAGE_ID, DIFFICULTY_HARD: DEFAULT_STAGE_ID, DIFFICULTY_EXPERT: DEFAULT_STAGE_ID}}, "streamFrameProgress": legacy, "relayModeUnlocked": false, "unlockPresentation": _default_unlock_presentation_state(), "codex": CodexManager.get_save_data()}

static func default_progress(frames: Array = []) -> Dictionary:
	return create_default_save_data(frames)

static func load_progress(frames: Array) -> Dictionary:
	var progress := create_default_save_data(frames)
	var parsed: Variant = null
	var legacy_codex_import := false
	if FileAccess.file_exists(PROGRESS_PATH):
		var file := FileAccess.open(PROGRESS_PATH, FileAccess.READ)
		if file != null:
			parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		var source: Dictionary = parsed as Dictionary
		if source.has("codex") and source.get("codex") is Dictionary:
			CodexManager.load_save_data(source.get("codex"))
		else:
			# Keep the rest of an old/corrupt save intact and only reset codex
			# state.  The game performs the one-time shop unlock sync afterwards.
			CodexManager.initialize_empty()
			legacy_codex_import = true
		if source.has("difficulties"):
			progress = _normalize_save(progress, source)
		else:
			progress = migrate_save_data(source, frames)
	else:
		CodexManager.initialize_empty()
	# Legacy v0.1/v0.2 difficulty history is authoritative for only the
	# per-stage clear flags.  The codex layer performs this idempotently and
	# deliberately does not invent old play/clear counters or scores.
	CodexManager.sync_legacy_character_records(progress)
	progress["codex"] = CodexManager.get_save_data()
	CodexManager.set_legacy_import_pending(legacy_codex_import)
	var has_unlock_presentation := source_has_unlock_presentation(parsed)
	var unlocks := evaluate_all_unlocks(progress)
	if not has_unlock_presentation:
		# Migration is deliberately marked incomplete until the shop profile is
		# available.  Existing unlocks are seen, never presented as new.
		var migrated_state := _unlock_presentation_state(progress)
		migrated_state["seenIds"] = UnlockPresentationSystemScript.sort_ids(_unlocked_presentation_ids(unlock_presentation_snapshot(progress)))
		migrated_state["pendingIds"] = []
		migrated_state["migrationComplete"] = false
		progress["unlockPresentation"] = migrated_state
	else:
		progress["unlockPresentation"] = UnlockPresentationSystemScript.normalize_state(progress.get("unlockPresentation", {}))
	save_progress(progress)
	return progress

static func load_progress_for_target(target: Node) -> void:
	var frames := _array(target.get("stream_frames"))
	var progress := load_progress(frames)
	_sync_target(target, progress, frames)
	var ui := _dict(progress.get("stageSelectUi", {}))
	target.set("run_difficulty_id", normalize_difficulty_id(ui.get("selectedDifficulty", DIFFICULTY_NORMAL)))
	target.set("difficulty_progress_recorded_run_id", "")

static func save_progress(progress: Dictionary) -> bool:
	var payload := progress.duplicate(true)
	payload["saveVersion"] = SAVE_VERSION
	payload["unlockPresentation"] = UnlockPresentationSystemScript.normalize_state(payload.get("unlockPresentation", {}))
	payload["codex"] = CodexManager.get_save_data()
	var temp_path := PROGRESS_PATH + ".tmp"
	var file := FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(payload, "\t"))
	file.flush()
	file.close()
	if DirAccess.rename_absolute(temp_path, PROGRESS_PATH) == OK:
		return true
	var fallback := FileAccess.open(PROGRESS_PATH, FileAccess.WRITE)
	if fallback == null:
		return false
	fallback.store_string(JSON.stringify(payload, "\t"))
	fallback.flush()
	fallback.close()
	return true

static func migrate_save_data(old_save: Dictionary, frames: Array = []) -> Dictionary:
	var result := create_default_save_data(frames)
	var difficulties := _dict(result.get("difficulties", {}))
	var normal := _dict(difficulties.get(DIFFICULTY_NORMAL, {}))
	var stages := _dict(normal.get("stages", {}))
	var legacy_result := _dict(result.get("streamFrameProgress", {}))
	var source := _dict(old_save.get("streamFrameProgress", old_save.get("stream_frame_progress", {})))
	for key in source.keys():
		var stage_id := normalize_stage_id(key)
		if not STANDARD_STAGE_IDS.has(stage_id):
			continue
		var old_entry := _dict(source[key])
		var stage := _dict(stages.get(stage_id, create_default_stage_progress()))
		var cleared := _safe_bool(old_entry.get("isCleared", old_entry.get("cleared", false)))
		var score := maxi(0, int(old_entry.get("bestViewerCount", old_entry.get("bestScore", 0))))
		stage["played"] = _safe_bool(old_entry.get("played", false)) or cleared or score > 0
		stage["cleared"] = cleared
		stage["bestScore"] = score
		stages[stage_id] = stage
		var projected := _legacy_entry(_safe_bool(old_entry.get("isUnlocked", false)))
		projected["isCleared"] = cleared
		projected["bestViewerCount"] = score
		projected["bestKamiRank"] = old_entry.get("bestKamiRank", null)
		legacy_result[stage_id] = projected
	normal["stages"] = stages
	var old_relay := _dict(old_save.get("relayProgress", old_save.get("relay", {})))
	var relay := _dict(normal.get("relay", {}))
	if not old_relay.is_empty():
		relay["unlocked"] = _safe_bool(old_relay.get("unlocked", false))
		relay["played"] = _safe_bool(old_relay.get("played", false))
		relay["bestScore"] = maxi(0, int(old_relay.get("bestScore", 0)))
		relay["bestReachedSection"] = clampi(int(old_relay.get("bestReachedSection", 0)), 0, 5)
		relay["bestReachedStageId"] = _safe_stage_or_null(old_relay.get("bestReachedStageId", null))
		relay["bestFinalBossPhase"] = maxi(0, int(old_relay.get("bestFinalBossPhase", 0)))
	var relay_cleared := _safe_bool(old_save.get("normalRelayCleared", old_save.get("normal_relay_cleared", false)))
	relay_cleared = relay_cleared or _safe_bool(old_relay.get("finalBossDefeated", old_relay.get("cleared", false)))
	relay_cleared = relay_cleared or _legacy_rankings_have_normal_relay_clear()
	relay["finalBossDefeated"] = relay_cleared
	relay["cleared"] = relay_cleared
	if _safe_bool(old_save.get("relayModeUnlocked", old_save.get("relay_mode_unlocked", false))):
		relay["unlocked"] = true
	normal["relay"] = relay
	difficulties[DIFFICULTY_NORMAL] = normal
	result["difficulties"] = difficulties
	result["streamFrameProgress"] = legacy_result
	result["unlockPresentation"] = _default_unlock_presentation_state()
	return result

static func _legacy_rankings_have_normal_relay_clear() -> bool:
	if not FileAccess.file_exists(RANKINGS_PATH):
		return false
	var file := FileAccess.open(RANKINGS_PATH, FileAccess.READ)
	if file == null:
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return false
	var data: Dictionary = parsed as Dictionary
	var lists: Array = []
	for key in ["relayRankingEntries", "rankingEntries"]:
		var entries := _array(data.get(key, []))
		if not entries.is_empty():
			lists.append(entries)
	for list_value in lists:
		for item in _array(list_value):
			if not item is Dictionary:
				continue
			var entry: Dictionary = item as Dictionary
			if _safe_bool(entry.get("isDebug", false)) or String(entry.get("endType", "")) == "debug":
				continue
			if normalize_difficulty_id(entry.get("difficultyId", DIFFICULTY_NORMAL)) != DIFFICULTY_NORMAL:
				continue
			var relay := String(entry.get("modeId", "")) == STAGE_RELAY or String(entry.get("stageId", "")) == STAGE_RELAY
			if relay and (_safe_bool(entry.get("isRelayCompleted", false)) or String(entry.get("endedReason", "")) == "completed" or _safe_bool(entry.get("bossDefeated", false))):
				return true
	return false

static func _normalize_save(defaults: Dictionary, source: Dictionary) -> Dictionary:
	var result := defaults.duplicate(true)
	var difficulties := _dict(result.get("difficulties", {}))
	var source_difficulties := _dict(source.get("difficulties", {}))
	for difficulty_id in DIFFICULTY_IDS:
		var data := _dict(difficulties.get(difficulty_id, create_default_difficulty_progress()))
		var source_data := _dict(source_difficulties.get(difficulty_id, {}))
		data["unlocked"] = _safe_bool(source_data.get("unlocked", data.get("unlocked", false)))
		data["isNew"] = _safe_bool(source_data.get("isNew", false))
		var stages := _dict(data.get("stages", {}))
		var source_stages := _dict(source_data.get("stages", {}))
		for key in source_stages.keys():
			var stage_id := normalize_stage_id(key)
			if not STANDARD_STAGE_IDS.has(stage_id):
				continue
			var stage := _dict(stages.get(stage_id, create_default_stage_progress()))
			var source_stage := _dict(source_stages[key])
			stage["played"] = _safe_bool(source_stage.get("played", false)) or _safe_bool(source_stage.get("cleared", false))
			stage["cleared"] = _safe_bool(source_stage.get("cleared", false))
			stage["firstBossDefeated"] = _safe_bool(source_stage.get("firstBossDefeated", false))
			stage["reignitionBossDefeated"] = _safe_bool(source_stage.get("reignitionBossDefeated", false))
			stage["bestScore"] = maxi(0, int(source_stage.get("bestScore", 0)))
			stage["bestBossCount"] = maxi(0, int(source_stage.get("bestBossCount", 0)))
			stage["clearCharacterIds"] = _unique_string_array(source_stage.get("clearCharacterIds", []))
			stage["bossDefeatCharacterIds"] = _unique_string_array(source_stage.get("bossDefeatCharacterIds", []))
			stage["reignitionDefeatCharacterIds"] = _unique_string_array(source_stage.get("reignitionDefeatCharacterIds", []))
			stages[stage_id] = stage
		data["stages"] = stages
		var relay := _dict(data.get("relay", {}))
		var source_relay := _dict(source_data.get("relay", {}))
		relay["unlocked"] = _safe_bool(source_relay.get("unlocked", false))
		relay["played"] = _safe_bool(source_relay.get("played", false))
		relay["finalBossDefeated"] = _safe_bool(source_relay.get("finalBossDefeated", false))
		relay["cleared"] = _safe_bool(source_relay.get("cleared", false)) or bool(relay["finalBossDefeated"])
		relay["played"] = bool(relay["played"]) or bool(relay["cleared"])
		relay["bestScore"] = maxi(0, int(source_relay.get("bestScore", 0)))
		relay["bestReachedSection"] = clampi(int(source_relay.get("bestReachedSection", 0)), 0, 5)
		relay["bestReachedStageId"] = _safe_stage_or_null(source_relay.get("bestReachedStageId", null))
		relay["bestFinalBossPhase"] = maxi(0, int(source_relay.get("bestFinalBossPhase", 0)))
		relay["clearCharacterIds"] = _unique_string_array(source_relay.get("clearCharacterIds", []))
		data["relay"] = relay
		difficulties[difficulty_id] = data
	result["difficulties"] = difficulties
	var source_ui := _dict(source.get("stageSelectUi", {}))
	var ui := _dict(result.get("stageSelectUi", {}))
	ui["selectedDifficulty"] = normalize_difficulty_id(source_ui.get("selectedDifficulty", DIFFICULTY_NORMAL))
	var last := _dict(ui.get("lastSelectedStageByDifficulty", {}))
	var source_last := _dict(source_ui.get("lastSelectedStageByDifficulty", {}))
	for difficulty_id in DIFFICULTY_IDS:
		var stage_id := normalize_stage_id(source_last.get(difficulty_id, DEFAULT_STAGE_ID))
		if not ALL_STAGE_IDS.has(stage_id):
			stage_id = DEFAULT_STAGE_ID
		last[difficulty_id] = stage_id
	ui["lastSelectedStageByDifficulty"] = last
	result["stageSelectUi"] = ui
	result["streamFrameProgress"] = _normalize_legacy_projection(source.get("streamFrameProgress", {}), result)
	var normal := _dict(difficulties.get(DIFFICULTY_NORMAL, {}))
	result["relayModeUnlocked"] = bool(_dict(normal.get("relay", {})).get("unlocked", false))
	var presentation: Variant = source.get("unlockPresentation", null)
	result["unlockPresentation"] = UnlockPresentationSystemScript.normalize_state(presentation) if presentation is Dictionary else _default_unlock_presentation_state()
	result["codex"] = CodexManager.get_save_data()
	return result

static func evaluate_all_unlocks(progress: Dictionary) -> Array:
	var new_unlocks: Array = []
	var difficulties := _dict(progress.get("difficulties", {}))
	var normal := _dict(difficulties.get(DIFFICULTY_NORMAL, create_default_difficulty_progress()))
	var hard := _dict(difficulties.get(DIFFICULTY_HARD, create_default_difficulty_progress()))
	var expert := _dict(difficulties.get(DIFFICULTY_EXPERT, create_default_difficulty_progress()))
	normal["unlocked"] = true
	_update_relay_unlock(normal, DIFFICULTY_NORMAL, new_unlocks)
	if bool(_dict(normal.get("relay", {})).get("cleared", false)) and not bool(hard.get("unlocked", false)):
		hard["unlocked"] = true
		hard["isNew"] = true
		new_unlocks.append(DIFFICULTY_HARD)
	if bool(hard.get("unlocked", false)):
		_update_relay_unlock(hard, DIFFICULTY_HARD, new_unlocks)
	if bool(_dict(hard.get("relay", {})).get("cleared", false)) and not bool(expert.get("unlocked", false)):
		expert["unlocked"] = true
		expert["isNew"] = true
		new_unlocks.append(DIFFICULTY_EXPERT)
	if bool(expert.get("unlocked", false)):
		_update_relay_unlock(expert, DIFFICULTY_EXPERT, new_unlocks)
	difficulties[DIFFICULTY_NORMAL] = normal
	difficulties[DIFFICULTY_HARD] = hard
	difficulties[DIFFICULTY_EXPERT] = expert
	progress["difficulties"] = difficulties
	progress["relayModeUnlocked"] = bool(_dict(normal.get("relay", {})).get("unlocked", false))
	return new_unlocks

static func _update_relay_unlock(data: Dictionary, difficulty_id: String, new_unlocks: Array) -> void:
	var relay := _dict(data.get("relay", {}))
	if not bool(relay.get("unlocked", false)) and can_unlock_relay_data(data):
		relay["unlocked"] = true
		new_unlocks.append("%s_relay" % difficulty_id)
	data["relay"] = relay

static func can_unlock_relay(progress: Dictionary, difficulty_id: Variant) -> bool:
	return can_unlock_relay_data(_difficulty_data(progress, normalize_difficulty_id(difficulty_id)))

static func can_unlock_relay_data(data: Dictionary) -> bool:
	var stages := _dict(data.get("stages", {}))
	for stage_id in STANDARD_STAGE_IDS:
		if not bool(_dict(stages.get(stage_id, {})).get("cleared", false)):
			return false
	return true

static func can_unlock_hard(progress: Dictionary) -> bool:
	return bool(_dict(_difficulty_data(progress, DIFFICULTY_NORMAL).get("relay", {})).get("cleared", false))

static func can_unlock_expert(progress: Dictionary) -> bool:
	return bool(_dict(_difficulty_data(progress, DIFFICULTY_HARD).get("relay", {})).get("cleared", false))

static func count_cleared_standard_stages(progress: Dictionary, difficulty_id: Variant) -> int:
	var count := 0
	var stages := _dict(_difficulty_data(progress, normalize_difficulty_id(difficulty_id)).get("stages", {}))
	for stage_id in STANDARD_STAGE_IDS:
		if bool(_dict(stages.get(stage_id, {})).get("cleared", false)):
			count += 1
	return count

static func get_stage_card_state(progress: Dictionary, difficulty_value: Variant, stage_value: Variant) -> Dictionary:
	var difficulty_id := normalize_difficulty_id(difficulty_value)
	var stage_id := normalize_stage_id(stage_value)
	var data := _difficulty_data(progress, difficulty_id)
	if not bool(data.get("unlocked", false)):
		return {"selectable": false, "status": "difficulty_locked", "difficulty": difficulty_id, "stageId": stage_id, "cleared": false}
	if stage_id == STAGE_RELAY:
		var relay := _dict(data.get("relay", {}))
		if not bool(relay.get("unlocked", false)):
			return {"selectable": false, "status": "relay_locked", "difficulty": difficulty_id, "stageId": stage_id, "cleared": false, "progress": count_cleared_standard_stages(progress, difficulty_id)}
		var relay_status := "selectable"
		if bool(relay.get("cleared", false)):
			relay_status = "relay_cleared"
		return {"selectable": true, "status": relay_status, "difficulty": difficulty_id, "stageId": stage_id, "cleared": bool(relay.get("cleared", false))}
	var stages := _dict(data.get("stages", {}))
	var stage := _dict(stages.get(stage_id, create_default_stage_progress()))
	if not _stage_is_unlocked(progress, difficulty_id, stage_id):
		return {"selectable": false, "status": "stage_locked", "difficulty": difficulty_id, "stageId": stage_id, "cleared": bool(stage.get("cleared", false)), "condition": _lock_condition(progress, difficulty_id, stage_id, "stage_locked")}
	if not bool(stage.get("played", false)):
		return {"selectable": true, "status": "not_played", "difficulty": difficulty_id, "stageId": stage_id, "cleared": false}
	if not bool(stage.get("cleared", false)):
		return {"selectable": true, "status": "in_progress", "difficulty": difficulty_id, "stageId": stage_id, "cleared": false}
	var status := "cleared"
	if difficulty_id == DIFFICULTY_HARD and bool(stage.get("reignitionBossDefeated", false)):
		status = "fully_extinguished"
	elif difficulty_id == DIFFICULTY_HARD and bool(stage.get("firstBossDefeated", false)):
		status = "boss_defeated"
	return {"selectable": true, "status": status, "difficulty": difficulty_id, "stageId": stage_id, "cleared": true}

static func record_single_stage_result(progress: Dictionary, result: Dictionary) -> Dictionary:
	var difficulty_id := normalize_difficulty_id(result.get("difficulty", result.get("difficultyId", DIFFICULTY_NORMAL)))
	var stage_id := normalize_stage_id(result.get("stageId", ""))
	if not STANDARD_STAGE_IDS.has(stage_id):
		return {"changed": false, "difficulty": difficulty_id, "stageId": stage_id}
	var data := _difficulty_data(progress, difficulty_id)
	var stages := _dict(data.get("stages", {}))
	var stage := _dict(stages.get(stage_id, create_default_stage_progress()))
	var changed := false
	if not bool(stage.get("played", false)):
		stage["played"] = true
		changed = true
	var cleared := _safe_bool(result.get("survivedToEnd", result.get("cleared", false)))
	if cleared and not bool(stage.get("cleared", false)):
		stage["cleared"] = true
		changed = true
	var first_boss := _safe_bool(result.get("firstBossDefeated", false))
	var reignition := _safe_bool(result.get("reignitionBossDefeated", false))
	if first_boss and not bool(stage.get("firstBossDefeated", false)):
		stage["firstBossDefeated"] = true
		changed = true
	if reignition and not bool(stage.get("reignitionBossDefeated", false)):
		stage["reignitionBossDefeated"] = true
		changed = true
	var boss_defeated := _safe_bool(result.get("bossDefeated", false))
	var boss_count := maxi(0, int(result.get("bossCount", 1 if boss_defeated else 0)))
	if boss_count > int(stage.get("bestBossCount", 0)):
		stage["bestBossCount"] = boss_count
		changed = true
	var score := maxi(0, int(result.get("score", 0)))
	if score > int(stage.get("bestScore", 0)):
		stage["bestScore"] = score
		changed = true
	var character_id := String(result.get("characterId", "")).strip_edges()
	if cleared and character_id != "":
		changed = _append_unique(_array(stage.get("clearCharacterIds", [])), character_id) or changed
	if boss_defeated and character_id != "":
		changed = _append_unique(_array(stage.get("bossDefeatCharacterIds", [])), character_id) or changed
	if reignition and character_id != "":
		changed = _append_unique(_array(stage.get("reignitionDefeatCharacterIds", [])), character_id) or changed
	stages[stage_id] = stage
	data["stages"] = stages
	var difficulties := _dict(progress.get("difficulties", {}))
	difficulties[difficulty_id] = data
	progress["difficulties"] = difficulties
	return {"changed": changed, "difficulty": difficulty_id, "stageId": stage_id, "state": get_stage_card_state(progress, difficulty_id, stage_id)}

static func record_relay_result(progress: Dictionary, result: Dictionary) -> Dictionary:
	var difficulty_id := normalize_difficulty_id(result.get("difficulty", result.get("difficultyId", DIFFICULTY_NORMAL)))
	var data := _difficulty_data(progress, difficulty_id)
	var relay := _dict(data.get("relay", {}))
	var changed := false
	if not bool(relay.get("played", false)):
		relay["played"] = true
		changed = true
	var final_boss := _safe_bool(result.get("finalBossDefeated", result.get("relayFinalDefeated", false)))
	if final_boss and not bool(relay.get("finalBossDefeated", false)):
		relay["finalBossDefeated"] = true
		relay["cleared"] = true
		changed = true
	var score := maxi(0, int(result.get("score", 0)))
	if score > int(relay.get("bestScore", 0)):
		relay["bestScore"] = score
		changed = true
	var section := clampi(int(result.get("reachedSection", result.get("relayClearedFrameCount", 0))), 0, 5)
	if section > int(relay.get("bestReachedSection", 0)):
		relay["bestReachedSection"] = section
		changed = true
	var reached_stage := normalize_stage_id(result.get("reachedStageId", result.get("stageId", "")))
	if reached_stage != "" and reached_stage != DEFAULT_STAGE_ID and section >= int(relay.get("bestReachedSection", 0)):
		if relay.get("bestReachedStageId", null) != reached_stage:
			relay["bestReachedStageId"] = reached_stage
			changed = true
	var phase := maxi(0, int(result.get("finalBossPhase", 0)))
	if phase > int(relay.get("bestFinalBossPhase", 0)):
		relay["bestFinalBossPhase"] = phase
		changed = true
	var character_id := String(result.get("characterId", "")).strip_edges()
	if final_boss and character_id != "":
		changed = _append_unique(_array(relay.get("clearCharacterIds", [])), character_id) or changed
	data["relay"] = relay
	var difficulties := _dict(progress.get("difficulties", {}))
	difficulties[difficulty_id] = data
	progress["difficulties"] = difficulties
	return {"changed": changed, "difficulty": difficulty_id, "relay": relay.duplicate(true)}

static func record_result_for_target(target: Node, result: Dictionary, quick_test_mode: bool = false) -> Dictionary:
	if quick_test_mode:
		return {"changed": false, "ignored": true}
	var run_id := String(result.get("runId", target.get("run_id"))).strip_edges()
	if run_id != "" and run_id == String(target.get("difficulty_progress_recorded_run_id")):
		return {"changed": false, "duplicate": true}
	var progress: Dictionary = _dict(target.get("difficulty_progress"))
	if progress.is_empty():
		progress = load_progress(_array(target.get("stream_frames")))
	var difficulty_id := normalize_difficulty_id(result.get("difficultyId", target.get("run_difficulty_id")))
	var input := result.duplicate(true)
	input["difficulty"] = difficulty_id
	input["difficultyId"] = difficulty_id
	var record: Dictionary
	if _safe_bool(result.get("relayMode", false)):
		var final_boss := _safe_bool(target.get("relay_boss_score_awarded"))
		final_boss = final_boss or (_safe_bool(result.get("bossDefeated", false)) and String(result.get("endType", "")) == "completed")
		input["finalBossDefeated"] = final_boss
		input["reachedSection"] = int(target.get("relay_cleared_frame_count"))
		input["reachedStageId"] = String(target.get("current_stream_frame_id"))
		input["finalBossPhase"] = int(target.get("relay_boss_phase"))
		record = record_relay_result(progress, input)
	else:
		input["stageId"] = normalize_stage_id(result.get("stageId", result.get("streamFrameId", target.get("current_stream_frame_id"))))
		input["characterId"] = String(result.get("characterId", target.get("current_character_id")))
		record = record_single_stage_result(progress, input)
	var unlocks := evaluate_all_unlocks(progress)
	var saved := save_progress(progress)
	_sync_target(target, progress, _array(target.get("stream_frames")))
	if run_id != "":
		target.set("difficulty_progress_recorded_run_id", run_id)
	return {"changed": bool(record.get("changed", false)), "saved": saved, "record": record, "newlyUnlocked": unlocks}

static func unlock_all_for_target(target: Node) -> void:
	var progress: Dictionary = _dict(target.get("difficulty_progress"))
	if progress.is_empty():
		progress = load_progress(_array(target.get("stream_frames")))
	var legacy := legacy_normal_progress(progress)
	for stage_id in STANDARD_STAGE_IDS:
		var entry := _dict(legacy.get(stage_id, _legacy_entry()))
		entry["isUnlocked"] = true
		legacy[stage_id] = entry
	progress["streamFrameProgress"] = legacy
	var difficulties := _dict(progress.get("difficulties", {}))
	var normal := _dict(difficulties.get(DIFFICULTY_NORMAL, {}))
	var relay := _dict(normal.get("relay", {}))
	relay["unlocked"] = true
	normal["relay"] = relay
	difficulties[DIFFICULTY_NORMAL] = normal
	progress["difficulties"] = difficulties
	progress["relayModeUnlocked"] = true
	save_progress(progress)
	_sync_target(target, progress, _array(target.get("stream_frames")))
	target.set("relay_mode_unlocked", true)

static func force_expert_unlock_for_target(target: Node) -> void:
	var progress: Dictionary = _dict(target.get("difficulty_progress"))
	if progress.is_empty():
		progress = load_progress(_array(target.get("stream_frames")))
	var difficulties := _dict(progress.get("difficulties", {}))
	var expert := _dict(difficulties.get(DIFFICULTY_EXPERT, create_default_difficulty_progress()))
	expert["unlocked"] = true
	expert["isNew"] = false
	difficulties[DIFFICULTY_EXPERT] = expert
	progress["difficulties"] = difficulties
	evaluate_all_unlocks(progress)
	save_progress(progress)
	_sync_target(target, progress, _array(target.get("stream_frames")))

static func force_expert_clear_all_stages_for_target(target: Node) -> void:
	force_expert_unlock_for_target(target)
	var progress: Dictionary = _dict(target.get("difficulty_progress"))
	var difficulties := _dict(progress.get("difficulties", {}))
	var expert := _dict(difficulties.get(DIFFICULTY_EXPERT, create_default_difficulty_progress()))
	var stages := _dict(expert.get("stages", {}))
	for stage_id in STANDARD_STAGE_IDS:
		var stage := _dict(stages.get(stage_id, create_default_stage_progress()))
		stage["played"] = true
		stage["cleared"] = true
		stages[stage_id] = stage
	expert["stages"] = stages
	difficulties[DIFFICULTY_EXPERT] = expert
	progress["difficulties"] = difficulties
	evaluate_all_unlocks(progress)
	save_progress(progress)
	_sync_target(target, progress, _array(target.get("stream_frames")))

static func force_expert_relay_unlock_for_target(target: Node) -> void:
	force_expert_clear_all_stages_for_target(target)
	var progress: Dictionary = _dict(target.get("difficulty_progress"))
	var difficulties := _dict(progress.get("difficulties", {}))
	var expert := _dict(difficulties.get(DIFFICULTY_EXPERT, create_default_difficulty_progress()))
	var relay := _dict(expert.get("relay", create_default_relay_progress()))
	relay["unlocked"] = true
	expert["relay"] = relay
	difficulties[DIFFICULTY_EXPERT] = expert
	progress["difficulties"] = difficulties
	evaluate_all_unlocks(progress)
	save_progress(progress)
	_sync_target(target, progress, _array(target.get("stream_frames")))

static func selected_difficulty(progress: Dictionary) -> String:
	return normalize_difficulty_id(_dict(progress.get("stageSelectUi", {})).get("selectedDifficulty", DIFFICULTY_NORMAL))

static func consume_difficulty_new(progress: Dictionary, difficulty_id: Variant) -> bool:
	var id := normalize_difficulty_id(difficulty_id)
	var difficulties := _dict(progress.get("difficulties", {}))
	var data := _dict(difficulties.get(id, {}))
	if not bool(data.get("isNew", false)):
		return false
	data["isNew"] = false
	difficulties[id] = data
	progress["difficulties"] = difficulties
	return true

static func consume_difficulty_new_for_target(target: Node, difficulty_id: Variant) -> bool:
	var progress: Dictionary = _dict(target.get("difficulty_progress"))
	if progress.is_empty():
		return false
	var consumed := consume_difficulty_new(progress, difficulty_id)
	if consumed:
		save_progress(progress)
		target.set("difficulty_progress", progress)
	return consumed

static func last_selected_stage(progress: Dictionary, difficulty_id: Variant) -> String:
	var last := _dict(_dict(progress.get("stageSelectUi", {})).get("lastSelectedStageByDifficulty", {}))
	var stage_id := normalize_stage_id(last.get(normalize_difficulty_id(difficulty_id), DEFAULT_STAGE_ID))
	if ALL_STAGE_IDS.has(stage_id):
		return stage_id
	return DEFAULT_STAGE_ID

static func set_selected_difficulty_for_target(target: Node, difficulty_id: Variant) -> String:
	var progress: Dictionary = _dict(target.get("difficulty_progress"))
	if progress.is_empty():
		progress = load_progress(_array(target.get("stream_frames")))
	var normalized := normalize_difficulty_id(difficulty_id)
	var ui := _dict(progress.get("stageSelectUi", {}))
	ui["selectedDifficulty"] = normalized
	progress["stageSelectUi"] = ui
	target.set("difficulty_progress", progress)
	target.set("run_difficulty_id", normalized)
	save_progress(progress)
	return normalized

static func remember_selected_stage_for_target(target: Node, stage_id_value: Variant) -> void:
	var progress: Dictionary = _dict(target.get("difficulty_progress"))
	if progress.is_empty():
		return
	var ui := _dict(progress.get("stageSelectUi", {}))
	var last := _dict(ui.get("lastSelectedStageByDifficulty", {}))
	var stage_id := normalize_stage_id(stage_id_value)
	if not ALL_STAGE_IDS.has(stage_id):
		stage_id = DEFAULT_STAGE_ID
	last[normalize_difficulty_id(target.get("run_difficulty_id"))] = stage_id
	ui["lastSelectedStageByDifficulty"] = last
	progress["stageSelectUi"] = ui
	save_progress(progress)

static func selection_frames_for_target(target: Node, frames: Array, relay_config: Dictionary = {}) -> Array:
	var progress: Dictionary = _dict(target.get("difficulty_progress"))
	if progress.is_empty():
		progress = load_progress(frames)
	return selection_frames_for_progress(frames, progress, target.get("run_difficulty_id"), relay_config)

static func selection_frames_for_progress(frames: Array, progress: Dictionary, difficulty_value: Variant, relay_config: Dictionary = {}) -> Array:
	var difficulty_id := normalize_difficulty_id(difficulty_value)
	var result: Array = []
	for stage_id in STANDARD_STAGE_IDS:
		var source := _find_frame(frames, stage_id)
		if source.is_empty():
			source = {"id": stage_id, "displayName": stage_display_name(stage_id), "isPlayable": true}
		var frame := source.duplicate(true)
		var state := get_stage_card_state(progress, difficulty_id, stage_id)
		var status := String(state.get("status", "not_played"))
		frame["id"] = stage_id
		frame["difficultyMode"] = difficulty_id
		frame["difficultyId"] = difficulty_id
		frame["stageComplexity"] = int(STAGE_COMPLEXITIES.get(stage_id, int(source.get("difficulty", 1))))
		frame["isUnlocked"] = bool(state.get("selectable", false))
		frame["isPlayable"] = bool(state.get("selectable", false))
		frame["isCleared"] = bool(state.get("cleared", false))
		frame["statusId"] = status
		frame["statusText"] = _status_text(status)
		frame["status"] = "cleared" if bool(state.get("cleared", false)) else ("unlocked" if bool(state.get("selectable", false)) else "locked")
		frame["difficultyText"] = "\u67a0\u96e3\u5ea6\uff1a" + _stars(int(frame["stageComplexity"]))
		frame["difficultyLocked"] = status == "difficulty_locked"
		frame["relayLocked"] = false
		frame["detailTitle"] = difficulty_display_name(difficulty_id) if status == "difficulty_locked" else String(frame.get("displayName", stage_display_name(stage_id)))
		frame["unlockConditionText"] = _lock_condition(progress, difficulty_id, stage_id, status)
		frame["disabledReason"] = String(frame["unlockConditionText"])
		result.append(frame)
	var relay := _dict(_difficulty_data(progress, difficulty_id).get("relay", {}))
	var relay_frame := _relay_frame(progress, difficulty_id, relay, relay_config)
	result.append(relay_frame)
	return result

static func _relay_frame(progress: Dictionary, difficulty_id: String, relay: Dictionary, relay_config: Dictionary) -> Dictionary:
	var data := _difficulty_data(progress, difficulty_id)
	var difficulty_unlocked := bool(data.get("unlocked", false))
	var unlocked := difficulty_unlocked and bool(relay.get("unlocked", false))
	var cleared := bool(relay.get("cleared", false))
	var status := "selectable"
	if not difficulty_unlocked:
		status = "difficulty_locked"
	elif not unlocked:
		status = "relay_locked"
	elif cleared:
		status = "relay_cleared"
	var segment := float(relay_config.get("segmentDuration", 120.0))
	var segment_seconds := maxi(0, int(round(segment)))
	var total_seconds := segment_seconds * 5
	var unlock_condition := "通常5枠をすべてクリアすると解禁されます。"
	var reason := ""
	if status == "difficulty_locked":
		reason = _difficulty_condition(difficulty_id)
	elif status == "relay_locked":
		reason = unlock_condition
	var features: Array[String] = ["5区間", "各%d秒" % segment_seconds]
	var description := "5つの配信枠を各%d秒ずつ連続で進み、最後に時間制限なしの最終ボスへ挑みます。区間の合間には休憩が入り、回復やギフトを選択できます。" % segment_seconds
	var recommend := "5つの配信枠を連続で走り切る、総仕上げの特別モードです。" if status == "selectable" or status == "relay_cleared" else ""
	return {
		"id": STAGE_RELAY,
		"displayName": "配信リレー",
		"plainName": "配信リレー",
		"iconId": "stream_icon_relay",
		"iconPath": "res://assets/generated/stream_frame_icons_v1/relay/clean.png",
		"themeColor": "relay",
		"difficulty": 5,
		"difficultyMode": difficulty_id,
		"difficultyId": difficulty_id,
		"stageComplexity": 5,
		"difficultyText": "枠難度：★★★★★",
		"description": description,
		"features": features,
		"shortFeatures": features.duplicate(),
		"mainGimmicks": ["5枠連続", "休憩", "最終ボス"],
		"recommendText": recommend,
		"unlockConditionText": reason,
		"disabledReason": reason,
		"isUnlocked": unlocked,
		"isCleared": cleared,
		"isPlayable": unlocked,
		"isRelayMode": true,
		"status": status,
		"statusId": status,
		"statusText": _relay_status_text(status),
		"relayProgress": count_cleared_standard_stages(progress, difficulty_id),
		"relayDurationText": "各%d秒・合計%d秒" % [segment_seconds, total_seconds],
		"difficultyLocked": status == "difficulty_locked",
		"relayLocked": status == "relay_locked",
		"detailTitle": "配信リレー"
	}

static func _relay_status_text(status: String) -> String:
	match status:
		"difficulty_locked", "relay_locked":
			return "未解禁"
		"relay_cleared":
			return "クリア"
		"selectable":
			return "挑戦可能"
	return "未解禁"

static func _status_text(status: String) -> String:
	match status:
		"difficulty_locked": return "LOCKED"
		"stage_locked": return "PREVIOUS CLEAR REQUIRED"
		"relay_locked": return "未解禁"
		"not_played": return "NEW"
		"in_progress": return "IN PROGRESS"
		"cleared": return "CLEAR"
		"boss_defeated": return "BOSS CLEAR"
		"fully_extinguished": return "FULL CLEAR"
		"relay_cleared": return "クリア"
	return "SELECTABLE"

static func gameplay_implemented(config: Dictionary, difficulty_id: Variant) -> bool:
	var id := normalize_difficulty_id(difficulty_id)
	var mode := _dict(_dict(config.get("modes", {})).get(id, {}))
	if mode.is_empty():
		return id != DIFFICULTY_EXPERT
	return _safe_bool(mode.get("implemented", id != DIFFICULTY_EXPERT))

static func duration_for(difficulty_id: Variant, relay_mode: bool, final_boss: bool, relay_config: Dictionary, difficulty_config: Dictionary) -> float:
	if relay_mode and final_boss:
		return INF
	if relay_mode:
		return float(relay_config.get("segmentDuration", 120.0))
	var mode := _dict(_dict(difficulty_config.get("modes", {})).get(normalize_difficulty_id(difficulty_id), {}))
	return float(mode.get("singleDurationSeconds", 180.0))

static func _lock_condition(progress: Dictionary, difficulty_id: String, stage_id: String, status: String) -> String:
	if status == "difficulty_locked":
		return _difficulty_condition(difficulty_id)
	if status == "stage_locked":
		var index := STANDARD_STAGE_IDS.find(stage_id)
		if index > 0:
			return "Clear %s (%s) to unlock" % [stage_display_name(STANDARD_STAGE_IDS[index - 1]), difficulty_display_name(difficulty_id)]
	return ""

static func _difficulty_condition(difficulty_id: String) -> String:
	if difficulty_id == DIFFICULTY_HARD:
		return "NORMALの配信リレーをクリアするとHARDが解禁されます。"
	if difficulty_id == DIFFICULTY_EXPERT:
		return "HARDの配信リレーをクリアするとEXPERTが解禁されます。"
	return "NORMALは最初から解禁されています。"

static func _stage_is_unlocked(progress: Dictionary, difficulty_id: String, stage_id: String) -> bool:
	if stage_id == DEFAULT_STAGE_ID:
		return true
	var index := STANDARD_STAGE_IDS.find(stage_id)
	if index <= 0:
		return true
	if difficulty_id == DIFFICULTY_NORMAL:
		if _safe_bool(_dict(_dict(progress.get("streamFrameProgress", {})).get(stage_id, {})).get("isUnlocked", false)):
			return true
	if difficulty_id == DIFFICULTY_EXPERT:
		# EXPERT's five standard frames are selectable immediately after the
		# difficulty unlock. NORMAL/HARD retain their existing sequential gates.
		return bool(_difficulty_data(progress, difficulty_id).get("unlocked", false))
	var stages := _dict(_difficulty_data(progress, difficulty_id).get("stages", {}))
	return bool(_dict(stages.get(STANDARD_STAGE_IDS[index - 1], {})).get("cleared", false))

static func _difficulty_data(progress: Dictionary, difficulty_id: String) -> Dictionary:
	var value: Variant = _dict(progress.get("difficulties", {})).get(difficulty_id, {})
	if value is Dictionary:
		return value as Dictionary
	return create_default_difficulty_progress()

static func _stage_progress(progress: Dictionary, difficulty_id: String, stage_id: String) -> Dictionary:
	var value: Variant = _dict(_difficulty_data(progress, difficulty_id).get("stages", {})).get(stage_id, {})
	if value is Dictionary:
		return value as Dictionary
	return create_default_stage_progress()

static func legacy_normal_progress(progress: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	var source := _dict(progress.get("streamFrameProgress", {}))
	for stage_id in STANDARD_STAGE_IDS:
		var stage := _stage_progress(progress, DIFFICULTY_NORMAL, stage_id)
		var old := _dict(source.get(stage_id, {}))
		result[stage_id] = {"isUnlocked": _stage_is_unlocked(progress, DIFFICULTY_NORMAL, stage_id) or _safe_bool(old.get("isUnlocked", false)), "isCleared": bool(stage.get("cleared", false)) or _safe_bool(old.get("isCleared", false)), "bestViewerCount": maxi(int(stage.get("bestScore", 0)), int(old.get("bestViewerCount", 0))), "bestKamiRank": old.get("bestKamiRank", null)}
	return result

static func frames_with_legacy_progress(frames: Array, progress: Dictionary) -> Array:
	var result: Array = []
	var legacy := legacy_normal_progress(progress)
	for item in frames:
		if not item is Dictionary:
			continue
		var frame: Dictionary = (item as Dictionary).duplicate(true)
		var entry := _dict(legacy.get(normalize_stage_id(frame.get("id", "")), {}))
		if not entry.is_empty():
			frame["isUnlocked"] = _safe_bool(entry.get("isUnlocked", frame.get("initialUnlocked", false)))
			frame["isCleared"] = _safe_bool(entry.get("isCleared", false))
			frame["bestViewerCount"] = int(entry.get("bestViewerCount", 0))
			frame["bestKamiRank"] = entry.get("bestKamiRank", null)
		result.append(frame)
	return result

static func _normalize_legacy_projection(value: Variant, progress: Dictionary) -> Dictionary:
	var result := legacy_normal_progress(progress)
	if not value is Dictionary:
		return result
	var source: Dictionary = value as Dictionary
	for key in source.keys():
		var stage_id := normalize_stage_id(key)
		if not STANDARD_STAGE_IDS.has(stage_id):
			continue
		var current := _dict(result.get(stage_id, _legacy_entry()))
		var entry := _dict(source[key])
		current["isUnlocked"] = _safe_bool(entry.get("isUnlocked", false)) or bool(current.get("isUnlocked", false))
		current["isCleared"] = _safe_bool(entry.get("isCleared", false)) or bool(current.get("isCleared", false))
		current["bestViewerCount"] = maxi(int(current.get("bestViewerCount", 0)), int(entry.get("bestViewerCount", 0)))
		result[stage_id] = current
	return result

static func _find_frame(frames: Array, stage_id: String) -> Dictionary:
	for item in frames:
		if item is Dictionary and normalize_stage_id((item as Dictionary).get("id", "")) == stage_id:
			return (item as Dictionary).duplicate(true)
	return {}

static func _sync_target(target: Node, progress: Dictionary, frames: Array) -> void:
	target.set("difficulty_progress", progress)
	# Existing StreamFrameSystem.clear_frame_for_target expects the full save
	# object here, while its streamFrameProgress child is the legacy projection.
	target.set("stream_frame_progress", progress)
	var normal := _dict(_dict(progress.get("difficulties", {})).get(DIFFICULTY_NORMAL, {}))
	target.set("relay_mode_unlocked", bool(_dict(normal.get("relay", {})).get("unlocked", false)))
	target.set("stream_frames", frames_with_legacy_progress(frames, progress))

static func _dict(value: Variant) -> Dictionary:
	if value is Dictionary:
		return value as Dictionary
	return {}

static func _array(value: Variant) -> Array:
	if value is Array:
		return value as Array
	return []

static func _safe_bool(value: Variant) -> bool:
	if value is bool:
		return value as bool
	if value is int or value is float:
		return float(value) != 0.0
	return String(value).strip_edges().to_lower() in ["1", "true", "yes", "on"]

static func _safe_stage_or_null(value: Variant):
	if value == null:
		return null
	var id := normalize_stage_id(value)
	if ALL_STAGE_IDS.has(id):
		return id
	return null

static func _unique_string_array(value: Variant) -> Array:
	var result: Array = []
	for item in _array(value):
		if not item is String and not item is StringName:
			continue
		var id := String(item).strip_edges()
		if id != "" and not result.has(id):
			result.append(id)
	return result

static func _append_unique(array: Array, value: String) -> bool:
	if value == "" or array.has(value):
		return false
	array.append(value)
	return true

static func _stars(level: int) -> String:
	var result := ""
	for _i in range(clampi(level, 1, 5)):
		result += "*"
	return result
