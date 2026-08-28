extends Node

const UnlockPresentation := preload("res://scripts/systems/unlock_presentation_system.gd")
const DifficultyProgress := preload("res://scripts/systems/difficulty_progress_system.gd")
const CommonLightUiStyleScript := preload("res://scripts/ui/common_light_ui_style.gd")
const ResultSystem := preload("res://scripts/systems/result_system.gd")
const DebugSystem := preload("res://scripts/systems/debug_system.gd")

var failures: Array[String] = []

func _ready() -> void:
	_check(UnlockPresentation.ORDER == ["stage:gameplay", "stage:singing", "stage:drawing", "stage:collab", "mode:relay", "difficulty:hard", "difficulty:expert", "character_group:senior_unit"], "presentation priority is stage/mode then difficulty then character")
	_check(DebugSystem.UNLOCK_PRESENTATION_PREVIEW_KEY == KEY_F8 and DebugSystem.UNLOCK_PRESENTATION_PREVIEW_KEY_LABEL == "Shift+F8" and DebugSystem.UNLOCK_PRESENTATION_PREVIEW_ACTION == "unlock_presentation_preview_all", "unlock preview debug command uses Shift+F8")
	_check(DebugSystem.f8_action_for_modifiers(true, true) == DebugSystem.UNLOCK_PRESENTATION_PREVIEW_ACTION and DebugSystem.f8_action_for_modifiers(false, true) == "hard_balance_toggle" and DebugSystem.f8_action_for_modifiers(true, false) == "", "Shift+F8 preview is separate from plain F8 and disabled outside debug builds")
	_check(is_equal_approx(UnlockPresentation.intro_scale(0.0), 0.90), "unlock intro starts at 0.90 scale")
	_check(is_equal_approx(UnlockPresentation.intro_scale(0.70), 1.03), "unlock intro reaches the 1.03 overshoot")
	_check(is_equal_approx(UnlockPresentation.intro_scale(1.0), 1.00), "unlock intro settles at 1.00 scale")
	_check(UnlockPresentation.intro_scale(0.35) > 0.90 and UnlockPresentation.intro_scale(0.85) > 1.00 and UnlockPresentation.intro_scale(0.85) < 1.03, "unlock intro returns from overshoot before the final frame")
	var failed_commit: Dictionary = {"saved": false, "ids": ["stage:gameplay"], "pendingIds": ["stage:gameplay"], "requiresSaveRetry": true}
	var failed_transition: Dictionary = UnlockPresentation.unlock_queue_transition_decision(failed_commit)
	_check(not bool(failed_transition.get("ready", true)) and bool(failed_transition.get("retry", false)), "failed unlock commit blocks transition and requests a save retry")
	var saved_transition: Dictionary = UnlockPresentation.unlock_queue_transition_decision({"saved": true, "ids": ["stage:gameplay"]})
	_check(bool(saved_transition.get("ready", false)) and not bool(saved_transition.get("retry", false)), "saved unlock commit allows transition")
	var result_system_source := FileAccess.get_file_as_string("res://scripts/systems/result_system.gd")
	_check(result_system_source.contains('"unlockPresentationCommit": result.get("unlockPresentationCommit", {})'), "build_result_data preserves an unsaved unlock commit in result data")
	_check(result_system_source.contains('result["unlockPresentationCommit"] = unlock_commit.duplicate(true)'), "initial unlock commit is written before build_result_data")
	var result_data_with_failed_commit: Dictionary = ResultSystem.build_result_data({
		"endType": "mental_breakdown",
		"cleared": false,
		"streamFrameId": "zatsudan",
		"runDifficultyId": "normal",
		"unlockPresentationBefore": {"stage:gameplay": false},
		"unlockPresentationPending": ["stage:gameplay"],
		"unlockPresentationCommit": failed_commit
	})
	var preserved_commit: Dictionary = result_data_with_failed_commit.get("unlockPresentationCommit", {}) as Dictionary
	_check(not bool(preserved_commit.get("saved", true)) and bool(preserved_commit.get("requiresSaveRetry", false)) and (preserved_commit.get("ids", []) as Array) == ["stage:gameplay"], "build_result_data preserves the failed commit values for transition retry")
	var game_source := FileAccess.get_file_as_string("res://scripts/game.gd")
	_check(game_source.contains("DifficultyProgressSystemScript.commit_unlock_presentation_for_target(self, before_variant as Dictionary)"), "transition guard retries unlock queue persistence")
	_check(game_source.contains("if not bool(retry_commit.get(\"saved\", false))") and game_source.contains("last_result_data[\"unlockPresentationCommit\"] = retry_commit.duplicate(true)"), "failed retry keeps the result transition blocked and successful retry updates the commit")
	_check(game_source.contains("unlock_presentation_ids = UnlockPresentationSystemScript.ORDER.duplicate()"), "debug preview uses the shared unlock order")
	_check(game_source.contains("preview_key_event.keycode == DebugSystemScript.UNLOCK_PRESENTATION_PREVIEW_KEY") and game_source.contains("Input.is_key_pressed(KEY_SHIFT) and OS.is_debug_build()"), "Shift+F8 preview is available through the direct key event path")
	_check(game_source.contains("if unlock_presentation_preview_mode:\n\t\t_advance_unlock_presentation_preview()\n\t\treturn"), "preview confirm advances without the persistent confirm path")
	_check(game_source.contains("if unlock_presentation_preview_mode and button_event.pressed") and game_source.contains("if unlock_presentation_preview_mode:\n\t\t\t\t_end_unlock_presentation_preview()"), "Esc and gamepad B interrupt preview without leaking to the background")
	_check(game_source.contains("unlock_presentation_preview_mode = false") and game_source.contains("pending_result_transition_action = \"\""), "preview completion clears only preview state and transition action")
	_check(game_source.contains('if unlock_presentation_preview_mode:\n\t\t_draw_text_item({"pos": Vector2(250.0, -260.0)') and game_source.contains('"text": UNLOCK_PRESENTATION_PREVIEW_LABEL'), "DEBUG PREVIEW label is drawn only in preview mode")
	_check(UnlockPresentation.normalize_id("hard_relay") == "", "hard relay does not create a duplicate relay presentation")
	_check(UnlockPresentation.normalize_id("expert_relay") == "", "expert relay does not create a duplicate relay presentation")
	var before := {"stage:gameplay": false, "mode:relay": false, "difficulty:hard": false, "difficulty:expert": false, "character_group:senior_unit": false}
	var after := {"stage:gameplay": true, "mode:relay": true, "difficulty:hard": true, "difficulty:expert": true, "character_group:senior_unit": true}
	_check(UnlockPresentation.false_to_true_ids(before, after) == ["stage:gameplay", "mode:relay", "difficulty:hard", "difficulty:expert", "character_group:senior_unit"], "false to true diff is ordered")
	var state := UnlockPresentation.create_state()
	state = UnlockPresentation.enqueue_ids(state, ["difficulty:expert", "stage:gameplay", "stage:gameplay", "difficulty:expert"])
	_check((state["pendingIds"] as Array) == ["stage:gameplay", "difficulty:expert"], "pending ids are deduplicated and sorted")
	var confirmed := UnlockPresentation.confirm_id(state, "stage:gameplay")
	_check(bool(confirmed.get("ok", false)), "confirm succeeds")
	var confirmed_state: Dictionary = confirmed.get("state", {}) as Dictionary
	_check((confirmed_state["seenIds"] as Array).has("stage:gameplay") and not (confirmed_state["pendingIds"] as Array).has("stage:gameplay"), "confirmed id moves from pending to seen")
	var recovery_state := UnlockPresentation.create_state([], ["mode:relay"], true, false)
	var normalized_recovery: Dictionary = UnlockPresentation.normalize_state(recovery_state)
	_check((normalized_recovery.get("pendingIds", []) as Array) == ["mode:relay"] and not bool(normalized_recovery.get("migrationComplete", true)), "initialized pending state survives restart migration")
	var old_save := DifficultyProgress.create_default_save_data([])
	_check(not (old_save.get("unlockPresentation", {}) as Dictionary).get("migrationComplete", true), "new default waits for shop profile migration")
	var migrated_old := DifficultyProgress.migrate_save_data({"saveVersion": 2, "streamFrameProgress": {"gameplay": {"isUnlocked": true, "isCleared": true}}}, [])
	var migrated_state: Dictionary = migrated_old.get("unlockPresentation", {}) as Dictionary
	_check((migrated_state.get("pendingIds", []) as Array).is_empty(), "old save migration never creates a presentation flood")
	var frames: Array = [{"id": "gameplay", "iconPath": "res://assets/generated/stream_frame_icons_v1/gameplay/clean.png"}]
	var gameplay_view := UnlockPresentation.descriptor("stage:gameplay", frames, [])
	_check(String(gameplay_view.get("title", "")) == "ゲーム実況配信 解放！" and String(gameplay_view.get("description", "")).contains("ジャンルイベント") and String(gameplay_view.get("iconPath", "")) == frames[0]["iconPath"], "gameplay descriptor uses the specified Japanese copy and asset")
	var stage_copy: Dictionary = {
		"stage:singing": ["歌枠配信 解放！", "ライブテンションと観客コールで"],
		"stage:drawing": ["お絵描き配信 解放！", "ペイントオーブを使いこなしながら"],
		"stage:collab": ["コラボ配信 解放！", "相方と連携して"]
	}
	for stage_id in stage_copy.keys():
		var stage_view := UnlockPresentation.descriptor(stage_id, [], [])
		var expected_copy: Array = stage_copy[stage_id] as Array
		_check(String(stage_view.get("title", "")) == String(expected_copy[0]) and String(stage_view.get("description", "")).contains(String(expected_copy[1])), "%s descriptor keeps its Japanese copy" % stage_id)
	var relay_view := UnlockPresentation.descriptor("mode:relay", [], [])
	_check(String(relay_view.get("kindLabel", "")) == "特別モード解放！" and String(relay_view.get("title", "")) == "配信リレー 解放！" and String(relay_view.get("description", "")).contains("総仕上げの特別モード"), "relay descriptor uses the special-mode copy")
	_check(bool(relay_view.get("specialMode", false)) and (relay_view.get("theme", Color.BLACK) as Color) == Color("#7A56C8") and (relay_view.get("secondaryTheme", Color.BLACK) as Color) == Color("#D6A94A"), "relay descriptor keeps purple primary and gold secondary styling")
	var hard_view := UnlockPresentation.descriptor("difficulty:hard", [], [])
	var expert_view := UnlockPresentation.descriptor("difficulty:expert", [], [])
	_check(String(hard_view.get("title", "")) == "HARD 解放！" and (hard_view.get("theme", Color.BLACK) as Color) == CommonLightUiStyleScript.DIFFICULTY_HARD_ACCENT, "hard uses the shared red difficulty palette and copy")
	_check(String(expert_view.get("title", "")) == "EXPERT 解放！" and String(expert_view.get("description", "")).contains("最高難度") and (expert_view.get("theme", Color.BLACK) as Color) == CommonLightUiStyleScript.DIFFICULTY_EXPERT_ACCENT, "expert uses the shared purple difficulty palette and copy")
	var characters: Array = [
		{"id": "aosumi_kyasumi", "displayName": "青澄きゃすみ", "selectSprite": "res://assets/characters/kyasumi.png"},
		{"id": "akarine_rizumu", "displayName": "灯音りずむ", "selectSprite": "res://assets/characters/rizumu.png"},
		{"id": "shizuki_miimu", "displayName": "紫月みぃむ", "selectSprite": "res://assets/characters/miimu.png"}
	]
	var senior_view := UnlockPresentation.descriptor("character_group:senior_unit", [], characters)
	_check((senior_view.get("memberIds", []) as Array) == ["aosumi_kyasumi", "akarine_rizumu", "shizuki_miimu"] and (senior_view.get("imagePaths", []) as Array).size() == 3 and (senior_view.get("memberNames", []) as Array).size() == 3, "senior unlock is one group with three full-color member assets")
	_check(UnlockPresentation.transition_requires_presentations("retry") and UnlockPresentation.transition_requires_presentations("shop") and UnlockPresentation.transition_requires_presentations("codex") and UnlockPresentation.transition_requires_presentations("title") and not UnlockPresentation.transition_requires_presentations("ranking"), "result transition policy excludes ranking")
	if failures.is_empty():
		print("UNLOCK_PRESENTATION_V1_TESTS: PASS")
	else:
		for failure in failures:
			push_error(failure)
		print("UNLOCK_PRESENTATION_V1_TESTS: FAIL")
	get_tree().quit(0 if failures.is_empty() else 1)

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
