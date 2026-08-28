extends RefCounted
class_name CommentBalanceSystem

const OVERRIDE_PATH := "res://data/comment_balance_overrides.json"
static var _loaded := false
static var _overrides: Dictionary = {}

static func normalize_comment(comment: Dictionary) -> Dictionary:
	_load_overrides()
	return _deep_merge(comment, _overrides.get(String(comment.get("id", "")), {}))

static func _load_overrides() -> void:
	if _loaded:
		return
	_loaded = true
	if not FileAccess.file_exists(OVERRIDE_PATH):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(OVERRIDE_PATH))
	if parsed is Dictionary:
		_overrides = parsed as Dictionary

static func _deep_merge(base: Dictionary, patch: Variant) -> Dictionary:
	var result: Dictionary = base.duplicate(true)
	if not patch is Dictionary:
		return result
	for key in (patch as Dictionary).keys():
		var value: Variant = (patch as Dictionary)[key]
		if value is Dictionary and result.get(key) is Dictionary:
			result[key] = _deep_merge(result[key] as Dictionary, value)
		else:
			result[key] = value
	return result
