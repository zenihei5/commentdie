extends RefCounted
class_name DataRepository

var comments: Array = []
var gifts: Array = []
var marshmallows: Array = []
var stream_frames: Array = []
var genre_events: Array = []
var characters: Array = []
var weapons: Array = []
var bosses: Array = []
var stream_start_intro_config: Dictionary = {}
var comment_pools: Dictionary = {}
var relay_mode_config: Dictionary = {}
var difficulty_mode_config: Dictionary = {}
var boss_cutin_v2_config: Dictionary = {}
var comment_balance_overrides: Dictionary = {}

static func loaded() -> DataRepository:
	var repository: DataRepository = DataRepository.new()
	repository.load_all()
	return repository

func load_all() -> void:
	comment_balance_overrides = _load_dictionary("res://data/comment_balance_overrides.json", true)
	comments = _apply_comment_balance_overrides(_load_array("res://data/comments.json"), comment_balance_overrides)
	gifts = _load_array("res://data/gifts.json")
	marshmallows = _load_array("res://data/marshmallows.json")
	stream_frames = _load_array("res://data/stream_frames.json")
	genre_events = _load_array("res://data/genre_events.json", true)
	characters = _load_array("res://data/characters.json")
	weapons = _load_array("res://data/weapons.json")
	bosses = _load_array("res://data/bosses.json", true)
	stream_start_intro_config = _load_dictionary("res://data/stream_start_intro.json", true)
	comment_pools = _load_dictionary("res://data/comment_pools.json", true)
	relay_mode_config = _load_dictionary("res://data/relay_mode.json", true)
	difficulty_mode_config = _load_dictionary("res://data/difficulty_modes.json", true)
	boss_cutin_v2_config = _load_dictionary("res://data/boss_cutin_v2.json", true)

func apply_to_target(target: Node) -> void:
	target.set("comments", comments)
	target.set("gifts", gifts)
	target.set("marshmallow_data", marshmallows)
	target.set("stream_frames", stream_frames)
	target.set("genre_events", genre_events)
	target.set("characters", characters)
	target.set("weapons", weapons)
	target.set("bosses", bosses)
	target.set("stream_start_intro_config", stream_start_intro_config)
	target.set("comment_pools", comment_pools)
	target.set("relay_mode_config", relay_mode_config)
	target.set("difficulty_mode_config", difficulty_mode_config)
	target.set("boss_cutin_v2_config", boss_cutin_v2_config)

func find_by_id(list: Array, id: String) -> Dictionary:
	for item in list:
		var data: Dictionary = item
		if String(data.get("id", "")) == id:
			return data
	return {}

func _load_array(path: String, optional: bool = false) -> Array:
	if optional and not FileAccess.file_exists(path):
		return []
	var text: String = FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(text)
	if parsed is Array:
		return parsed as Array
	return []

func _load_dictionary(path: String, optional: bool = false) -> Dictionary:
	if optional and not FileAccess.file_exists(path):
		return {}
	var text: String = FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(text)
	if parsed is Dictionary:
		return parsed as Dictionary
	return {}

func _apply_comment_balance_overrides(source: Array, overrides: Dictionary) -> Array:
	if overrides.is_empty():
		return source
	var result: Array = []
	for item in source:
		if not item is Dictionary:
			result.append(item)
			continue
		var comment: Dictionary = item as Dictionary
		var comment_id := String(comment.get("id", ""))
		result.append(_deep_merge(comment, overrides.get(comment_id, {})))
	return result

func _deep_merge(base: Dictionary, patch: Variant) -> Dictionary:
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
