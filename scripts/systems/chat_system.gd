class_name ChatSystem
extends RefCounted

const GameFontSystemScript := preload("res://scripts/systems/game_font_system.gd")
const COMMENT_POOLS_PATH := "res://data/comment_pools.json"
const FALLBACK_VISIBLE_LINE_LIMIT := 18
const FALLBACK_HISTORY_LIMIT := 20
const FALLBACK_RECENT_DUPLICATE_BLOCK := 12
const FALLBACK_CATEGORY_STREAK_LIMIT := 3
const ENTRY_INDEX_CACHE_KEY := "__chat_entry_index_cache"

static var _comment_pool_loaded := false
static var _comment_pool_cache: Dictionary = {}

static func comment_pool_data() -> Dictionary:
	if _comment_pool_loaded:
		return _comment_pool_cache
	_comment_pool_loaded = true
	if FileAccess.file_exists(COMMENT_POOLS_PATH):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(COMMENT_POOLS_PATH))
		if parsed is Dictionary:
			_comment_pool_cache = parsed as Dictionary
	if _comment_pool_cache.is_empty():
		_comment_pool_cache = {"settings": {}, "prefix_rules": {}, "pools": {}, "events": {}}
	return _comment_pool_cache

static func _comment_pool_data_for_target(target: Node) -> Dictionary:
	var value: Variant = target.get("comment_pools")
	if value is Dictionary and not (value as Dictionary).is_empty():
		return value as Dictionary
	return comment_pool_data()

static func _settings(data: Dictionary) -> Dictionary:
	var raw: Variant = data.get("settings", {})
	return raw as Dictionary if raw is Dictionary else {}

static func _setting_int(data: Dictionary, key: String, fallback: int) -> int:
	return int(_settings(data).get(key, fallback))

static func _setting_float(data: Dictionary, key: String, fallback: float) -> float:
	return float(_settings(data).get(key, fallback))

static func next_interval(state: String, kuso_chat_timer: float, rng: RandomNumberGenerator) -> float:
	var data := comment_pool_data()
	var fast: bool = state == "comment_choice" or kuso_chat_timer > 0.0
	if fast:
		return rng.randf_range(
			_setting_float(data, "fast_interval_min", 0.15),
			_setting_float(data, "fast_interval_max", 0.35)
		)
	return rng.randf_range(
		_setting_float(data, "normal_interval_min", 0.5),
		_setting_float(data, "normal_interval_max", 1.0)
	)

static func _normalize_type(type_value: String) -> String:
	match type_value:
		"system", "notice", "system_notice":
			return "system_notice"
		"warning", "danger", "instruction", "viewer_warning":
			return "warning"
		"positive", "hype", "gift", "viewer_hype":
			return "positive"
		"joke", "viewer_joke":
			return "joke"
	return "normal"

static func _entry_text(entry: Dictionary) -> String:
	return sanitize_line(String(entry.get("text", "")))

static func _entry_type(entry: Dictionary) -> String:
	return _normalize_type(String(entry.get("type", "normal")))

static func _entry_weight(entry: Dictionary) -> float:
	return maxf(0.01, float(entry.get("weight", 1.0)))

static func _entry_tags(entry: Dictionary) -> Array[String]:
	var tags: Array[String] = []
	var raw: Variant = entry.get("tags", [])
	if raw is Array:
		for item in raw as Array:
			tags.append(String(item))
	return tags

static func _entry_cooldown(entry: Dictionary, data: Dictionary) -> int:
	return maxi(1, int(entry.get("cooldown", _setting_int(data, "recent_duplicate_block", FALLBACK_RECENT_DUPLICATE_BLOCK))))

static func _section_dictionary(data: Dictionary, key: String) -> Dictionary:
	var raw: Variant = data.get(key, {})
	return raw as Dictionary if raw is Dictionary else {}

static func _entries_from_array(raw: Variant) -> Array:
	var result: Array = []
	if not (raw is Array):
		return result
	for item in raw as Array:
		if item is Dictionary and _entry_text(item as Dictionary) != "":
			result.append(item)
	return result

static func _pool_entries(data: Dictionary, pool_keys: Array[String]) -> Array:
	var pools := _section_dictionary(data, "pools")
	var result: Array = []
	for key in pool_keys:
		for entry in _entries_from_array(pools.get(key, [])):
			result.append(entry)
	return result

static func _character_reaction_key_for_id(character_id: String) -> String:
	match character_id:
		"ban_chan", "banri":
			return "banri"
		"superchat_chan", "supana":
			return "supana"
		"maro_chan", "maron":
			return "maron"
	return character_id

static func _character_reaction_key_for_target(target: Node) -> String:
	var character_id := String(target.get("current_character_id")).strip_edges()
	if character_id == "":
		var current_character: Dictionary = target.get("current_character") as Dictionary
		character_id = String(current_character.get("id", "")).strip_edges()
	return _character_reaction_key_for_id(character_id)

static func _character_reaction_pool_key(pool_key: String) -> String:
	match pool_key:
		"normal":
			return "normal"
		"danger":
			return "danger"
		"low_mental":
			return "low_mental"
		"high_buzz":
			return "hype"
		"result_clear":
			return "clear"
		"result_collapse":
			return "collapse"
	return ""

static func _character_pool_entries(data: Dictionary, character_key: String, pool_keys: Array[String]) -> Array:
	var characters := _section_dictionary(data, "character_reactions")
	var raw: Variant = characters.get(character_key, {})
	if not (raw is Dictionary):
		return []
	var character: Dictionary = raw as Dictionary
	var result: Array = []
	var used_keys: Array[String] = []
	for pool_key in pool_keys:
		var character_pool_key := _character_reaction_pool_key(pool_key)
		if character_pool_key == "" or character_pool_key in used_keys:
			continue
		used_keys.append(character_pool_key)
		for entry in _entries_from_array(character.get(character_pool_key, [])):
			result.append(entry)
	return result

static func _stream_slot_reaction_key_for_id(stream_frame_id: String) -> String:
	match stream_frame_id:
		"gameplay", "game":
			return "gameplay"
		"singing", "song":
			return "song"
		"zatsudan", "drawing", "collab", "relay":
			return stream_frame_id
	return stream_frame_id

static func _stream_slot_reaction_key_for_target(target: Node) -> String:
	var stream_frame_id := String(target.get("current_stream_frame_id")).strip_edges()
	if bool(target.get("relay_mode")):
		stream_frame_id = "relay"
	if stream_frame_id == "":
		var current_frame: Dictionary = target.get("current_stream_frame") as Dictionary
		stream_frame_id = String(current_frame.get("id", "")).strip_edges()
	return _stream_slot_reaction_key_for_id(stream_frame_id)

static func _stream_slot_key_candidates(stream_slot_key: String) -> Array[String]:
	var keys: Array[String] = []
	if stream_slot_key != "":
		keys.append(stream_slot_key)
	if stream_slot_key == "gameplay":
		keys.append("game")
	elif stream_slot_key == "game":
		keys.append("gameplay")
	return keys

static func _stream_slot_pool_key_candidates(pool_key: String) -> Array[String]:
	match pool_key:
		"normal":
			return ["normal"]
		"danger":
			return ["danger"]
		"low_mental":
			return ["low_mental", "danger"]
		"high_buzz":
			return ["high_buzz", "hype"]
		"result_clear":
			return ["clear"]
		"result_collapse":
			return ["collapse"]
		"song_low_heat":
			return ["low_heat", "normal"]
		"song_mid_heat":
			return ["mid_heat", "hype"]
		"song_high_heat":
			return ["high_heat", "hype"]
		"song_chorus":
			return ["chorus", "hype"]
		"song_encore":
			return ["encore", "hype"]
		"song_spotlight":
			return ["spotlight", "hype"]
	return []

static func _stream_slot_pool_entries(data: Dictionary, stream_slot_key: String, pool_keys: Array[String]) -> Array:
	var slots := _section_dictionary(data, "stream_slot_reactions")
	var result: Array = []
	for actual_slot_key in _stream_slot_key_candidates(stream_slot_key):
		var raw: Variant = slots.get(actual_slot_key, {})
		if not (raw is Dictionary):
			continue
		var slot: Dictionary = raw as Dictionary
		var used_keys: Array[String] = []
		for pool_key in pool_keys:
			for slot_pool_key in _stream_slot_pool_key_candidates(pool_key):
				if slot_pool_key == "" or slot_pool_key in used_keys:
					continue
				used_keys.append(slot_pool_key)
				for entry in _entries_from_array(slot.get(slot_pool_key, [])):
					result.append(entry)
	return result

static func _target_pool_entries(data: Dictionary, pool_keys: Array[String], target: Node) -> Array:
	var result := _pool_entries(data, pool_keys)
	var character_key := _character_reaction_key_for_target(target)
	if character_key != "":
		for entry in _character_pool_entries(data, character_key, pool_keys):
			result.append(entry)
	var stream_slot_key := _stream_slot_reaction_key_for_target(target)
	if stream_slot_key != "":
		for entry in _stream_slot_pool_entries(data, stream_slot_key, pool_keys):
			result.append(entry)
	return result

static func _section_entries(data: Dictionary, section_key: String, keys: Array[String]) -> Array:
	var section := _section_dictionary(data, section_key)
	var result: Array = []
	for key in keys:
		for entry in _entries_from_array(section.get(key, [])):
			result.append(entry)
	return result

static func _event_data(data: Dictionary, event_id: String) -> Dictionary:
	var events := _section_dictionary(data, "events")
	var raw: Variant = events.get(event_id, {})
	return raw as Dictionary if raw is Dictionary else {}

static func _event_entries(data: Dictionary, event_id: String, key: String) -> Array:
	var event := _event_data(data, event_id)
	return _entries_from_array(event.get(key, []))

static func _all_entries(data: Dictionary) -> Array:
	var result: Array = []
	var pools := _section_dictionary(data, "pools")
	for key in pools.keys():
		for entry in _entries_from_array(pools[key]):
			result.append(entry)
	var events := _section_dictionary(data, "events")
	for key in events.keys():
		var event := events[key] as Dictionary
		for entry in _entries_from_array(event.get("notice", [])):
			result.append(entry)
		for entry in _entries_from_array(event.get("reactions", [])):
			result.append(entry)
	for section_key in ["weapon_reactions", "modifier_reactions", "marshmallow_reactions"]:
		var section := _section_dictionary(data, section_key)
		for key in section.keys():
			for entry in _entries_from_array(section[key]):
				result.append(entry)
	var characters := _section_dictionary(data, "character_reactions")
	for character_key in characters.keys():
		var raw_character: Variant = characters[character_key]
		if not (raw_character is Dictionary):
			continue
		var character: Dictionary = raw_character as Dictionary
		for key in character.keys():
			for entry in _entries_from_array(character[key]):
				result.append(entry)
	var slots := _section_dictionary(data, "stream_slot_reactions")
	for slot_key in slots.keys():
		var raw_slot: Variant = slots[slot_key]
		if not (raw_slot is Dictionary):
			continue
		var slot: Dictionary = raw_slot as Dictionary
		for key in slot.keys():
			for entry in _entries_from_array(slot[key]):
				result.append(entry)
	return result

static func _entry_index(data: Dictionary) -> Dictionary:
	var raw: Variant = data.get(ENTRY_INDEX_CACHE_KEY, {})
	if raw is Dictionary:
		var cached: Dictionary = raw as Dictionary
		if not cached.is_empty():
			return cached
	var index: Dictionary = {}
	for item in _all_entries(data):
		var entry: Dictionary = item as Dictionary
		var text := _entry_text(entry)
		if text != "" and not index.has(text):
			index[text] = entry
	data[ENTRY_INDEX_CACHE_KEY] = index
	return index

static func _entry_for_text(text: String, data: Dictionary = {}) -> Dictionary:
	var source := data if not data.is_empty() else comment_pool_data()
	var clean := sanitize_line(text)
	var index := _entry_index(source)
	if index.has(clean):
		return index[clean] as Dictionary
	return {}

static func _synthetic_entry(text: String, data: Dictionary) -> Dictionary:
	return {
		"text": sanitize_line(text),
		"type": _fallback_type_for_text(text),
		"weight": 1.0,
		"tags": [],
		"cooldown": _setting_int(data, "recent_duplicate_block", FALLBACK_RECENT_DUPLICATE_BLOCK)
	}

static func _entry_for_append(text: String, data: Dictionary) -> Dictionary:
	var entry := _entry_for_text(text, data)
	return _synthetic_entry(text, data) if entry.is_empty() else entry

static func sanitize_line(line: String) -> String:
	var text := line.strip_edges()
	text = text.replace("コメント欄：", "")
	text = text.replace("コメント欄:", "")
	text = text.replace("【アナウンス】", "")
	text = text.replace("【通知】", "")
	return text.strip_edges()

static func _fallback_type_for_text(text: String) -> String:
	var clean := sanitize_line(text)
	if clean.contains("配信終了まで") or clean.contains("終了まで") or clean.contains("LIVE") or clean.contains("WARNING") or clean.contains("次の配信枠へ") or clean.contains("配信開始") or clean.contains(" を選択") or clean.contains("を取得"):
		return "system_notice"
	if clean.contains("事故") or clean.contains("やられ") or clean.contains("メンタル") or clean.contains("逃げ") or clean.contains("危") or clean.contains("残り") or clean.contains("ボス") or clean.contains("クソマロ") or clean.contains("未読") or clean.contains("荒れ") or clean.contains("近い") or clean.contains("後ろ") or clean.contains("囲ま") or clean.contains("避けろ") or clean.contains("ざわ") or clean.contains("押し切"):
		return "warning"
	if clean.contains("草") or clean.contains("ｗ") or clean.contains("w") or clean.contains("笑"):
		return "joke"
	if clean.contains("神") or clean.contains("切り抜き") or clean.contains("完走") or clean.contains("おめ") or clean.contains("888") or clean.contains("バズ") or clean.contains("ギフト") or clean.contains("回復") or clean.contains("ハート") or clean.contains("♡") or clean.contains("拾った") or clean.contains("進化") or clean.contains("成功") or clean.contains("撃破") or clean.contains("スパチャ") or clean.contains("ボーナス") or clean.contains("流入") or clean.contains("+"):
		return "positive"
	return "normal"

static func line_category(line: String) -> String:
	var data := comment_pool_data()
	var entry := _entry_for_text(line, data)
	return _entry_type(entry) if not entry.is_empty() else _fallback_type_for_text(line)

static func _prefix_rules(data: Dictionary) -> Dictionary:
	var raw: Variant = data.get("prefix_rules", {})
	if raw is Dictionary:
		return raw as Dictionary
	return {}

static func prefix(line: String) -> String:
	var data := comment_pool_data()
	var type := line_category(line)
	var rules := _prefix_rules(data)
	if rules.has(type):
		return String(rules[type])
	return ">"

static func color(line: String) -> Color:
	match line_category(line):
		"warning":
			return Color("#d63a73")
		"positive":
			return Color("#009dc4")
		"joke":
			return Color("#8a65c7")
		"system_notice":
			return Color("#c97913")
	return Color("#6b7280")

static func font_size_for_line(line: String) -> int:
	var type := line_category(line)
	return 21 if type == "warning" or type == "system_notice" else 20

static func _display_type_for_text(text: String, data: Dictionary) -> String:
	var entry := _entry_for_text(text, data)
	return _entry_type(entry) if not entry.is_empty() else _fallback_type_for_text(text)

static func _recent_has_line(lines: Array[String], text: String, lookback: int) -> bool:
	var start_index := maxi(0, lines.size() - lookback)
	for i in range(start_index, lines.size()):
		if sanitize_line(lines[i]) == text:
			return true
	return false

static func _category_streak(lines: Array[String], type: String, data: Dictionary) -> int:
	var streak := 0
	for i in range(lines.size() - 1, -1, -1):
		if _display_type_for_text(lines[i], data) != type:
			break
		streak += 1
	return streak

static func _can_append_entry(lines: Array[String], entry: Dictionary, data: Dictionary) -> bool:
	var text := _entry_text(entry)
	if text == "":
		return false
	if _recent_has_line(lines, text, _entry_cooldown(entry, data)):
		return false
	var type := _entry_type(entry)
	if type != "system_notice" and _category_streak(lines, type, data) >= _setting_int(data, "max_same_category_streak", FALLBACK_CATEGORY_STREAK_LIMIT):
		return false
	return true

static func append_line(lines: Array[String], text: String, limit: int = -1, data: Dictionary = {}) -> Array[String]:
	var source := data if not data.is_empty() else comment_pool_data()
	var max_lines := limit if limit > 0 else _setting_int(source, "max_lines", FALLBACK_HISTORY_LIMIT)
	var result: Array[String] = []
	for line in lines:
		var clean_existing := sanitize_line(line)
		if clean_existing != "":
			result.append(clean_existing)
	var entry := _entry_for_append(text, source)
	if _can_append_entry(result, entry, source):
		result.append(_entry_text(entry))
	while result.size() > max_lines:
		result.pop_front()
	return result

static func _same_lines(a: Array[String], b: Array[String]) -> bool:
	if a.size() != b.size():
		return false
	for i in range(a.size()):
		if a[i] != b[i]:
			return false
	return true

static func _choose_weighted_entry(entries: Array, lines: Array[String], rng: RandomNumberGenerator, data: Dictionary) -> Dictionary:
	var total_weight := 0.0
	for item in entries:
		if not (item is Dictionary):
			continue
		var entry: Dictionary = item as Dictionary
		if not _can_append_entry(lines, entry, data):
			continue
		if rng == null:
			return entry
		total_weight += _entry_weight(entry)
	if total_weight <= 0.0:
		return {}
	var roll := rng.randf() * total_weight
	var accumulated := 0.0
	var fallback: Dictionary = {}
	for item in entries:
		if not (item is Dictionary):
			continue
		var entry: Dictionary = item as Dictionary
		if not _can_append_entry(lines, entry, data):
			continue
		fallback = entry
		accumulated += _entry_weight(entry)
		if roll <= accumulated:
			return entry
	return fallback

static func _apply_params_to_entry(entry: Dictionary, params: Dictionary) -> Dictionary:
	var result := entry.duplicate()
	var text := _entry_text(result)
	for key in params.keys():
		text = text.replace("{%s}" % String(key), String(params[key]))
	result["text"] = text
	return result

static func _append_entry(lines: Array[String], entry: Dictionary, data: Dictionary, params: Dictionary = {}) -> Array[String]:
	var actual := _apply_params_to_entry(entry, params) if not params.is_empty() else entry
	return append_line(lines, _entry_text(actual), _setting_int(data, "max_lines", FALLBACK_HISTORY_LIMIT), data)

static func _target_rng(target: Node) -> RandomNumberGenerator:
	var value: Variant = target.get("rng")
	if value is RandomNumberGenerator:
		return value as RandomNumberGenerator
	return null

static func _pool_keys_for_state(state: String) -> Array[String]:
	match state:
		"comment_choice", "instruction_selecting":
			return ["instruction_selecting"]
		"gift_choice", "gift_selecting":
			return ["gift_selecting"]
		"result", "result_clear":
			return ["result_clear"]
		"death", "result_collapse":
			return ["result_collapse"]
		"hp_low", "low_mental":
			return ["normal", "danger", "low_mental"]
		"enemy_near", "danger":
			return ["normal", "danger"]
		"boss_active":
			return ["normal", "danger", "boss"]
		"kuso_maro", "boss_kusomaro":
			return ["danger", "boss_kusomaro"]
		"buzz_high", "high_buzz":
			return ["normal", "high_buzz"]
		"endgame":
			return ["normal", "endgame"]
	return ["normal"]

static func pool_for_state(state: String) -> Array[String]:
	var texts: Array[String] = []
	for item in _pool_entries(comment_pool_data(), _pool_keys_for_state(state)):
		texts.append(_entry_text(item as Dictionary))
	return texts

static func random_pool_for_context(context: String) -> Array[String]:
	return pool_for_state(context)

static func seed_lines(mode: String) -> Array[String]:
	var data := comment_pool_data()
	var key := "result_collapse" if mode == "death" else ("result_clear" if mode == "result" else "normal")
	var texts: Array[String] = []
	for item in _pool_entries(data, [key]):
		texts.append(_entry_text(item as Dictionary))
	return texts.slice(0, 5)

static func seed_lines_for_target(target: Node, mode: String) -> Array[String]:
	var data := _comment_pool_data_for_target(target)
	var key := "result_collapse" if mode == "death" else ("result_clear" if mode == "result" else "normal")
	var base_entries := _pool_entries(data, [key])
	var character_entries := _character_pool_entries(data, _character_reaction_key_for_target(target), [key])
	var stream_slot_entries := _stream_slot_pool_entries(data, _stream_slot_reaction_key_for_target(target), [key])
	var texts: Array[String] = []
	for i in range(mini(3, base_entries.size())):
		texts.append(_entry_text(base_entries[i] as Dictionary))
	if not character_entries.is_empty():
		texts.append(_entry_text(character_entries[0] as Dictionary))
	if not stream_slot_entries.is_empty():
		texts.append(_entry_text(stream_slot_entries[0] as Dictionary))
	var base_index := 3
	while texts.size() < 5 and base_index < base_entries.size():
		texts.append(_entry_text(base_entries[base_index] as Dictionary))
		base_index += 1
	return texts

static func marshmallow_pool(kind: String) -> Array[String]:
	var data := comment_pool_data()
	var key := kind if kind in ["god", "bad", "unread"] else "good"
	var texts: Array[String] = []
	for item in _section_entries(data, "marshmallow_reactions", [key]):
		texts.append(_entry_text(item as Dictionary))
	return texts

static func random_marshmallow_line(kind: String, rng: RandomNumberGenerator) -> String:
	var data := comment_pool_data()
	var key := kind if kind in ["god", "bad", "unread"] else "good"
	var entry := _choose_weighted_entry(_section_entries(data, "marshmallow_reactions", [key]), [], rng, data)
	return _entry_text(entry) if not entry.is_empty() else ""

static func update_timer(state: String, kuso_chat_timer: float, chat_timer: float, delta: float, rng: RandomNumberGenerator) -> Dictionary:
	var next_timer: float = chat_timer - delta
	if next_timer > 0.0:
		return {"timer": next_timer, "line": ""}
	next_timer = next_interval(state, kuso_chat_timer, rng)
	var data := comment_pool_data()
	var key_state := "boss_kusomaro" if kuso_chat_timer > 0.0 else state
	var entry := _choose_weighted_entry(_pool_entries(data, _pool_keys_for_state(key_state)), [], rng, data)
	return {"timer": next_timer, "line": _entry_text(entry) if not entry.is_empty() else ""}

static func _near_enemy_count(target: Node) -> int:
	var count := 0
	var player_pos: Vector2 = Vector2(target.get("player_pos"))
	var enemies: Array = target.get("enemies") as Array
	for enemy_item in enemies:
		var enemy: Dictionary = enemy_item as Dictionary
		if float(enemy.get("hp", 0.0)) <= 0.0:
			continue
		var enemy_pos: Vector2 = Vector2(enemy.get("pos", Vector2.ZERO))
		var danger_range := float(enemy.get("radius", 20.0)) + 128.0
		if enemy_pos.distance_squared_to(player_pos) <= danger_range * danger_range:
			count += 1
	return count

static func _is_endgame_target(target: Node) -> bool:
	var elapsed := float(target.get("elapsed"))
	if elapsed <= 0.0:
		return false
	var run_length := 60.0 if bool(target.get("quick_test_mode")) else 180.0
	var remaining := run_length - elapsed
	return remaining > 0.0 and remaining <= 30.0

static func _song_pool_keys_for_target(target: Node) -> Array[String]:
	var stream_frame_id := String(target.get("current_stream_frame_id"))
	if stream_frame_id != "singing" and stream_frame_id != "song":
		return []
	var keys: Array[String] = []
	var heat_level := int(target.get("song_live_heat_level"))
	if heat_level <= 1:
		keys.append("song_low_heat")
	elif heat_level <= 3:
		keys.append("song_mid_heat")
	else:
		keys.append("song_high_heat")
	if float(target.get("song_chorus_timer")) > 0.0:
		keys.append("song_chorus")
	if float(target.get("song_encore_timer")) > 0.0:
		keys.append("song_encore")
	var spotlights: Array = target.get("song_spotlights") as Array
	if spotlights.size() > 0:
		keys.append("song_spotlight")
	return keys

static func _target_pool_keys(target: Node) -> Array[String]:
	var state := String(target.get("state"))
	if state == "comment_choice":
		return ["instruction_selecting"]
	if state == "gift_choice":
		return ["gift_selecting"]
	if state == "result":
		var result_data: Dictionary = target.get("last_result_data") as Dictionary
		return ["result_clear"] if String(result_data.get("endType", "")) == "completed" else ["result_collapse"]
	if float(target.get("kuso_chat_timer")) > 0.0:
		return ["danger", "boss_kusomaro"]
	var keys: Array[String] = ["normal"]
	if bool(target.get("boss_active")) or bool(target.get("boss_requested")) or float(target.get("boss_warning_timer")) > 0.0:
		keys.append("danger")
		keys.append("boss")
		if String(target.get("boss_pending_id")).contains("kuso") or String(target.get("boss_last_name")).contains("クソマロ"):
			keys.append("boss_kusomaro")
	var max_hp := maxf(1.0, float(target.get("player_max_hp")))
	var mental_rate := float(target.get("player_hp")) / max_hp
	if mental_rate <= 0.3:
		keys.append("low_mental")
	if _near_enemy_count(target) >= 1:
		keys.append("danger")
	if int(target.get("burn_combo")) >= 8 or float(target.get("multiplier")) >= 3.0 or int(target.get("gift_hype")) >= 85:
		keys.append("high_buzz")
	if _is_endgame_target(target):
		keys.append("endgame")
	for song_key in _song_pool_keys_for_target(target):
		if not keys.has(song_key):
			keys.append(song_key)
	return keys

static func _event_params_for_line(text: String, target: Node) -> Dictionary:
	var line := sanitize_line(text)
	var params: Dictionary = {}
	if line.contains(" を選択"):
		params["modifier_name"] = line.split(" を選択")[0]
	if line.contains(" を取得"):
		params["gift_name"] = line.split(" を取得")[0]
	if line.contains("武器進化！") and line.contains("→"):
		var body := line.replace("武器進化！", "").strip_edges()
		var parts := body.split("→")
		if parts.size() >= 2:
			params["base_weapon"] = String(parts[0]).strip_edges()
			params["evolved_weapon"] = String(parts[1]).strip_edges()
	var boss_name := String(target.get("boss_last_name"))
	if boss_name == "" and line.contains("が出現"):
		boss_name = line.split("が出現")[0]
	if boss_name == "" and line.contains("撃破"):
		boss_name = line.split("撃破")[0].replace("大荒れ突破！", "").strip_edges()
	if boss_name != "":
		params["boss_name"] = boss_name
	return params

static func _event_ids_for_line(text: String, target: Node) -> Array[String]:
	var line := sanitize_line(text)
	var result: Array[String] = []
	if line.contains("あと5秒で指示コメ"):
		result.append("instruction_warning")
	if line.contains("指示コメが来た"):
		result.append("instruction_arrived")
	if line.contains(" を選択") or line.contains("押し切られた"):
		result.append("instruction_selected")
	if line.contains("指示コメ完走ボーナス"):
		result.append("instruction_clear")
	if line.contains("ギフト") and (line.contains("届いた") or line.contains("予感")):
		if line.contains("大当たり"):
			result.append("gift_big_lucky")
		elif line.contains("当たり") or line.contains("豪華"):
			result.append("gift_lucky")
		else:
			result.append("gift_arrived")
	if line.contains(" を取得"):
		result.append("gift_taken")
	if line.contains("♡を受け取った") or line.contains("♡はすでに") or line.contains("♡発動"):
		result.append("heart_taken")
	if line.contains("武器進化"):
		result.append("evolution")
	if line.contains("が出現") or line.contains("ボスきた") or line.contains("接近"):
		if line.contains("クソマロ") or String(target.get("boss_pending_id")).contains("kuso") or String(target.get("boss_last_name")).contains("クソマロ"):
			result.append("boss_spawn_kusomaro")
		elif line.contains("ボス") or line.contains("出現") or line.contains("接近"):
			result.append("boss_spawn_normal")
	if line.contains("撃破") and (line.contains("ボス") or line.contains("大荒れ") or String(target.get("boss_last_name")) != ""):
		result.append("boss_defeated")
	return result

static func _event_reaction_count(event: Dictionary, rng: RandomNumberGenerator) -> int:
	var min_count := int(event.get("reaction_count_min", 0))
	var max_count := int(event.get("reaction_count_max", min_count))
	max_count = maxi(min_count, max_count)
	if max_count <= min_count or rng == null:
		return min_count
	return rng.randi_range(min_count, max_count)

static func _append_event_comments(lines: Array[String], data: Dictionary, event_id: String, params: Dictionary, include_notice: bool, rng: RandomNumberGenerator) -> Array[String]:
	var result := lines
	var event := _event_data(data, event_id)
	if event.is_empty():
		return result
	if include_notice:
		var notice := _choose_weighted_entry(_event_entries(data, event_id, "notice"), result, rng, data)
		if not notice.is_empty():
			result = _append_entry(result, notice, data, params)
	var count := _event_reaction_count(event, rng)
	var reactions := _event_entries(data, event_id, "reactions")
	for i in range(count):
		var reaction := _choose_weighted_entry(reactions, result, rng, data)
		if reaction.is_empty():
			break
		result = _append_entry(result, reaction, data, params)
	return result

static func _weapon_reaction_keys(kind: String) -> Array[String]:
	match kind:
		"ban":
			return ["ban_hammer"]
		"superchat":
			return ["starlight_superchat", "superchat_shot"]
		"maro_ring":
			return ["maro_comment_ring"]
		"kusa_wave":
			return ["kusa_wave", "grass_wave"]
	return [kind]

static func _modifier_reaction_keys(target: Node) -> Array[String]:
	var keys: Array[String] = []
	var comment_id := String(target.get("last_comment_id"))
	match comment_id:
		"no_dash":
			keys.append("dash_disabled")
		"kamiyoyaku":
			keys.append("kami_kai_yoyaku")
		"takeback":
			keys.append("ima_no_nashi")
		"short_range":
			keys.append("range_down")
		_:
			if comment_id != "":
				keys.append(comment_id)
	return keys

static func _append_section_reaction(lines: Array[String], data: Dictionary, section_key: String, keys: Array[String], rng: RandomNumberGenerator, max_count: int = 1) -> Array[String]:
	var result := lines
	var entries := _section_entries(data, section_key, keys)
	for i in range(max_count):
		var entry := _choose_weighted_entry(entries, result, rng, data)
		if entry.is_empty():
			break
		result = _append_entry(result, entry, data)
	return result

static func display_items(lines: Array[String]) -> Array:
	var data := comment_pool_data()
	var items: Array = []
	var visible_lines: Array[String] = lines
	var visible_limit := _setting_int(data, "visible_lines", FALLBACK_VISIBLE_LINE_LIMIT)
	if visible_lines.size() > visible_limit:
		visible_lines = visible_lines.slice(visible_lines.size() - visible_limit, visible_lines.size())
	for line in visible_lines:
		var clean := sanitize_line(line)
		if clean == "":
			continue
		var type := line_category(clean)
		var rules := _prefix_rules(data)
		var line_prefix := String(rules.get(type, ">"))
		var line_color := Color("#6b7280")
		match type:
			"warning":
				line_color = Color("#d63a73")
			"positive":
				line_color = Color("#009dc4")
			"joke":
				line_color = Color("#8a65c7")
			"system_notice":
				line_color = Color("#c97913")
		items.append({
			"text": line_prefix + " " + clean,
			"color": line_color,
			"fontSize": 21 if type == "warning" or type == "system_notice" else 20
		})
	return items

static func refresh_box(chat_box: Control, lines: Array[String]) -> void:
	if chat_box == null:
		return
	for child in chat_box.get_children():
		child.queue_free()
	for item in display_items(lines):
		var view: Dictionary = item as Dictionary
		var label := Label.new()
		label.text = String(view["text"])
		GameFontSystemScript.apply_regular_font(label)
		label.add_theme_font_size_override("font_size", int(view["fontSize"]))
		label.add_theme_color_override("font_color", view["color"] as Color)
		var row_width := maxf(240.0, chat_box.size.x)
		label.custom_minimum_size = Vector2(row_width, 24)
		label.size = Vector2(row_width, 24)
		label.clip_text = true
		chat_box.add_child(label)

static func seed_box(chat_box: Control, mode: String) -> Array[String]:
	var lines: Array[String] = []
	for line in seed_lines(mode):
		lines = append_line(lines, line)
	refresh_box(chat_box, lines)
	return lines

static func seed_box_for_target(target: Node, chat_box: Control, mode: String) -> Array[String]:
	var lines: Array[String] = []
	for line in seed_lines_for_target(target, mode):
		lines = append_line(lines, line)
	refresh_box(chat_box, lines)
	target.set("chat_lines", lines)
	return lines

static func update_timer_for_target(target: Node, delta: float, rng: RandomNumberGenerator, chat_box: Control) -> Array[String]:
	var data := _comment_pool_data_for_target(target)
	var state := String(target.get("state"))
	var next_timer := float(target.get("chat_timer")) - delta
	if next_timer > 0.0:
		target.set("chat_timer", next_timer)
		return target.get("chat_lines") as Array[String]
	var lines := current_lines_for_target(target)
	var fast := state == "comment_choice" or float(target.get("kuso_chat_timer")) > 0.0
	next_timer = rng.randf_range(
		_setting_float(data, "fast_interval_min" if fast else "normal_interval_min", 0.15 if fast else 0.5),
		_setting_float(data, "fast_interval_max" if fast else "normal_interval_max", 0.35 if fast else 1.0)
	)
	if not fast and target.has_method("_song_comment_speed_multiplier"):
		next_timer /= maxf(0.25, float(target.call("_song_comment_speed_multiplier")))
	target.set("chat_timer", next_timer)
	var entry := _choose_weighted_entry(_target_pool_entries(data, _target_pool_keys(target), target), lines, rng, data)
	if not entry.is_empty():
		lines = _append_entry(lines, entry, data)
		refresh_box(chat_box, lines)
	target.set("chat_lines", lines)
	return lines

static func current_lines_for_target(target: Node) -> Array[String]:
	var lines: Array[String] = []
	for item in target.get("chat_lines") as Array:
		var clean := sanitize_line(String(item))
		if clean != "":
			lines.append(clean)
	return lines

static func push_line_for_target(target: Node, chat_box: Control, text: String) -> Array[String]:
	var lines: Array[String] = append_line(current_lines_for_target(target), text)
	target.set("chat_lines", lines)
	refresh_box(chat_box, lines)
	return lines

static func apply_feedback_for_target(target: Node, feedback: Dictionary, chat_box: Control, toast_seconds: float = 1.4) -> Array[String]:
	var data := _comment_pool_data_for_target(target)
	var rng := _target_rng(target)
	for toast in (feedback.get("toasts", []) as Array):
		target.set("toast_text", sanitize_line(String(toast)))
		target.set("toast_timer", toast_seconds)
	var lines: Array[String] = current_lines_for_target(target)
	var changed := false

	var explicit_event_ids: Array[String] = []
	var explicit_event_id := String(feedback.get("commentEventId", feedback.get("chatEventId", "")))
	if explicit_event_id != "":
		explicit_event_ids.append(explicit_event_id)
	var explicit_event_ids_raw: Variant = feedback.get("commentEventIds", feedback.get("chatEventIds", []))
	if explicit_event_ids_raw is Array:
		for item in explicit_event_ids_raw as Array:
			var event_id := String(item)
			if event_id != "" and not explicit_event_ids.has(event_id):
				explicit_event_ids.append(event_id)
	for event_id in explicit_event_ids:
		var before_explicit := lines.duplicate()
		var params: Dictionary = feedback.get("eventParams", {}) as Dictionary
		lines = _append_event_comments(lines, data, event_id, params, true, rng)
		changed = changed or not _same_lines(before_explicit, lines)

	for maro_chat in (feedback.get("maroChatLines", []) as Array):
		var before_maro := lines.duplicate()
		lines = append_line(lines, String(maro_chat))
		changed = changed or not _same_lines(before_maro, lines)

	var chats: Array = feedback.get("chats", feedback.get("messages", [])) as Array
	for chat in chats:
		var before_lines := lines.duplicate()
		var clean_chat := sanitize_line(String(chat))
		lines = append_line(lines, clean_chat)
		var chat_appended := not _same_lines(before_lines, lines)
		changed = changed or chat_appended
		if chat_appended:
			var params := _event_params_for_line(clean_chat, target)
			for event_id in _event_ids_for_line(clean_chat, target):
				var before_event := lines.duplicate()
				lines = _append_event_comments(lines, data, event_id, params, false, rng)
				changed = changed or not _same_lines(before_event, lines)
				if event_id == "instruction_selected" or event_id == "instruction_clear":
					var before_modifier := lines.duplicate()
					lines = _append_section_reaction(lines, data, "modifier_reactions", _modifier_reaction_keys(target), rng, 1)
					changed = changed or not _same_lines(before_modifier, lines)

	var weapon_kind := String(feedback.get("weaponCommentKind", ""))
	if weapon_kind == "" and bool(feedback.get("listenerSummonAttacked", false)):
		weapon_kind = "listener_summon"
	if weapon_kind == "" and bool(feedback.get("emoteMineExploded", false)):
		weapon_kind = "emote_mine"
	if weapon_kind != "":
		var before_weapon := lines.duplicate()
		lines = _append_section_reaction(lines, data, "weapon_reactions", _weapon_reaction_keys(weapon_kind), rng, 1)
		changed = changed or not _same_lines(before_weapon, lines)

	target.set("chat_lines", lines)
	if changed:
		refresh_box(chat_box, lines)
	return lines
