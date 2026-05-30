extends RefCounted
class_name DataRepository

var comments: Array = []
var gifts: Array = []
var marshmallows: Array = []
var stream_frames: Array = []
var genre_events: Array = []
var characters: Array = []
var weapons: Array = []

func load_all() -> void:
	comments = _load_array("res://data/comments.json")
	gifts = _load_array("res://data/gifts.json")
	marshmallows = _load_array("res://data/marshmallows.json")
	stream_frames = _load_array("res://data/stream_frames.json")
	genre_events = _load_array("res://data/genre_events.json", true)
	characters = _load_array("res://data/characters.json")
	weapons = _load_array("res://data/weapons.json")

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
