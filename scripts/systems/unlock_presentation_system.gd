class_name UnlockPresentationSystem
extends RefCounted

## Pure data helpers for the one-shot unlock presentation queue.
## Actual unlock rules remain in DifficultyProgressSystem and the shop.

const CommonLightUiStyleScript := preload("res://scripts/ui/common_light_ui_style.gd")

const VERSION: int = 1
const STAGE_IDS: Array[String] = [
	"stage:gameplay",
	"stage:singing",
	"stage:drawing",
	"stage:collab",
	"mode:relay"
]
const DIFFICULTY_IDS: Array[String] = ["difficulty:hard", "difficulty:expert"]
const CHARACTER_IDS: Array[String] = ["character_group:senior_unit"]
const ORDER: Array[String] = ["stage:gameplay", "stage:singing", "stage:drawing", "stage:collab", "mode:relay", "difficulty:hard", "difficulty:expert", "character_group:senior_unit"]

const STAGE_INFO: Dictionary = {
	"gameplay": {
		"kindLabel": "新しい配信枠が解放！",
		"title": "ゲーム実況配信 解放！",
		"description": "ジャンルイベントに対応しながら\n配信を盛り上げよう！"
	},
	"singing": {
		"kindLabel": "新しい配信枠が解放！",
		"title": "歌枠配信 解放！",
		"description": "ライブテンションと観客コールで\n最高のステージを作ろう！"
	},
	"drawing": {
		"kindLabel": "新しい配信枠が解放！",
		"title": "お絵描き配信 解放！",
		"description": "ペイントオーブを使いこなしながら\n配信を進めよう！"
	},
	"collab": {
		"kindLabel": "新しい配信枠が解放！",
		"title": "コラボ配信 解放！",
		"description": "相方と連携して\n配信を乗り切ろう！"
	}
}

static func normalize_id(value: Variant) -> String:
	var raw := String(value).strip_edges().to_lower()
	if raw == "gameplay" or raw == "stage:gameplay":
		return "stage:gameplay"
	if raw == "singing" or raw == "stage:singing":
		return "stage:singing"
	if raw == "drawing" or raw == "stage:drawing":
		return "stage:drawing"
	if raw == "collab" or raw == "stage:collab":
		return "stage:collab"
	if raw == "relay" or raw == "normal_relay" or raw == "mode:relay":
		return "mode:relay"
	if raw == "hard" or raw == "difficulty:hard":
		return "difficulty:hard"
	if raw == "expert" or raw == "difficulty:expert":
		return "difficulty:expert"
	if raw == "senior_unit" or raw == "character_group:senior_unit":
		return "character_group:senior_unit"
	return ""

static func sort_ids(values: Array) -> Array:
	var unique: Dictionary = {}
	for value in values:
		var id := normalize_id(value)
		if id != "":
			unique[id] = true
	var result: Array = []
	for id in ORDER:
		if unique.has(id):
			result.append(id)
	for id in unique.keys():
		if not result.has(id):
			result.append(String(id))
	return result

static func create_state(seen_ids: Array = [], pending_ids: Array = [], initialized: bool = true, migration_complete: bool = true) -> Dictionary:
	return {
		"version": VERSION,
		"initialized": initialized,
		"migrationComplete": migration_complete,
		"seenIds": sort_ids(seen_ids),
		"pendingIds": sort_ids(pending_ids)
	}

static func normalize_state(value: Variant) -> Dictionary:
	if not value is Dictionary:
		return create_state()
	var source: Dictionary = value as Dictionary
	var seen: Array = sort_ids(source.get("seenIds", []))
	var pending: Array = sort_ids(source.get("pendingIds", []))
	var filtered_pending: Array = []
	for id in pending:
		if not seen.has(id):
			filtered_pending.append(id)
	return create_state(
		seen,
		filtered_pending,
		bool(source.get("initialized", false)),
		bool(source.get("migrationComplete", false))
	)

static func enqueue_ids(state_value: Variant, values: Array) -> Dictionary:
	var state := normalize_state(state_value)
	var seen: Array = state.get("seenIds", []) as Array
	var pending: Array = state.get("pendingIds", []) as Array
	var merged: Array = pending.duplicate()
	for value in values:
		var id := normalize_id(value)
		if id != "" and not seen.has(id) and not merged.has(id):
			merged.append(id)
	state["pendingIds"] = sort_ids(merged)
	state["initialized"] = true
	return state

static func confirm_id(state_value: Variant, value: Variant) -> Dictionary:
	var state := normalize_state(state_value)
	var id := normalize_id(value)
	var pending: Array = state.get("pendingIds", []) as Array
	if id == "" or not pending.has(id):
		return {"ok": false, "state": state}
	pending.erase(id)
	var seen: Array = state.get("seenIds", []) as Array
	if not seen.has(id):
		seen.append(id)
	state["pendingIds"] = sort_ids(pending)
	state["seenIds"] = sort_ids(seen)
	return {"ok": true, "state": state, "id": id}

static func false_to_true_ids(before: Dictionary, after: Dictionary) -> Array:
	var result: Array = []
	for id in ORDER:
		if not bool(before.get(id, false)) and bool(after.get(id, false)):
			result.append(id)
	return result

static func transition_requires_presentations(action_id: Variant) -> bool:
	return String(action_id) in ["retry", "shop", "codex", "title"]

static func unlock_queue_transition_decision(commit_value: Variant) -> Dictionary:
	if not commit_value is Dictionary:
		return {"ready": true, "retry": false}
	var commit: Dictionary = commit_value as Dictionary
	if bool(commit.get("saved", true)):
		return {"ready": true, "retry": false}
	var ids_value: Variant = commit.get("ids", [])
	var has_ids: bool = ids_value is Array and not (ids_value as Array).is_empty()
	if not has_ids and not bool(commit.get("requiresSaveRetry", false)):
		return {"ready": true, "retry": false}
	return {"ready": false, "retry": true}

static func intro_scale(progress_value: float) -> float:
	var progress := clampf(progress_value, 0.0, 1.0)
	if progress <= 0.70:
		return lerpf(0.90, 1.03, progress / 0.70)
	return lerpf(1.03, 1.00, (progress - 0.70) / 0.30)

static func descriptor(unlock_id_value: Variant, frames: Array = [], characters: Array = []) -> Dictionary:
	var unlock_id := normalize_id(unlock_id_value)
	var result: Dictionary = {
		"id": unlock_id,
		"kindLabel": "新しい要素が解放！",
		"title": "解放！",
		"description": "新しい要素を使えるようになりました！",
		"theme": Color("#E954A5"),
		"iconPath": "",
		"imagePaths": [],
		"memberNames": [],
		"memberIds": []
	}
	if unlock_id.begins_with("stage:"):
		var stage_id := unlock_id.trim_prefix("stage:")
		if stage_id == "relay":
			return _relay_descriptor()
		var info: Dictionary = STAGE_INFO.get(stage_id, {}) as Dictionary
		result["kindLabel"] = String(info.get("kindLabel", result["kindLabel"]))
		result["title"] = String(info.get("title", result["title"]))
		result["description"] = String(info.get("description", result["description"]))
		result["displayName"] = String(info.get("title", stage_id)).replace(" 解放！", "")
		var frame := _find_stage(frames, stage_id)
		result["theme"] = _stage_theme(String(frame.get("themeColor", stage_id)))
		result["iconPath"] = String(frame.get("iconPath", ""))
		return result
	if unlock_id == "mode:relay":
		return _relay_descriptor()
	if unlock_id.begins_with("difficulty:"):
		var difficulty_id := unlock_id.trim_prefix("difficulty:")
		var palette: Dictionary = CommonLightUiStyleScript.difficulty_palette(difficulty_id)
		result["kindLabel"] = "新しい難易度が解放！"
		result["title"] = "%s 解放！" % String(palette.get("id", difficulty_id)).to_upper()
		result["description"] = "より激しく、より厳しい配信に挑戦！" if difficulty_id == "hard" else "最高難度の配信に挑戦できます！"
		result["theme"] = palette.get("accent", Color("#7A56C8"))
		result["difficultyId"] = difficulty_id
		return result
	if unlock_id == "character_group:senior_unit":
		result["kindLabel"] = "新しいキャラクターが解放！"
		result["title"] = "先輩メンバー解放！"
		result["description"] = "配信者選択から使用できるようになりました！"
		result["theme"] = Color("#7A56C8")
		for item in characters:
			if not item is Dictionary:
				continue
			var character: Dictionary = item as Dictionary
			var id := String(character.get("id", ""))
			if id in ["aosumi_kyasumi", "akarine_rizumu", "shizuki_miimu"]:
				(result["memberIds"] as Array).append(id)
				(result["memberNames"] as Array).append(String(character.get("displayName", id)))
				(result["imagePaths"] as Array).append(String(character.get("selectSprite", character.get("sprite", ""))))
	return result

static func _relay_descriptor() -> Dictionary:
	return {
		"id": "mode:relay",
		"kindLabel": "特別モード解放！",
		"title": "配信リレー 解放！",
		"description": "5つの配信枠を連続で走り切る\n総仕上げの特別モード！",
		"theme": Color("#7A56C8"),
		"secondaryTheme": Color("#D6A94A"),
		"specialMode": true,
		"iconPath": "res://assets/generated/stream_frame_icons_v1/relay/clean.png",
		"imagePaths": [],
		"memberNames": [],
		"memberIds": []
	}

static func _find_stage(frames: Array, stage_id: String) -> Dictionary:
	for item in frames:
		if item is Dictionary and String((item as Dictionary).get("id", "")) == stage_id:
			return item as Dictionary
	return {}

static func _stage_theme(stage_id: String) -> Color:
	match stage_id:
		"gameplay", "blue": return Color("#5BAFE3")
		"singing", "purple": return Color("#A66DDE")
		"drawing", "mint": return Color("#42C6B7")
		"collab", "orange": return Color("#F2A34A")
		"pink": return Color("#E954A5")
	return Color("#E954A5")
