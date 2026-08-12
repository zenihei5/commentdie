extends Node

const Presentation := preload("res://scripts/systems/codex_presentation_system.gd")
const WeaponSystemScript := preload("res://scripts/systems/weapon_system.gd")
const GiftSystemScript := preload("res://scripts/systems/gift_system.gd")
const DifficultyProgressSystemScript := preload("res://scripts/systems/difficulty_progress_system.gd")

const INITIAL_WEAPON_IDS: Array[String] = ["ban_hammer", "superchat_shot", "comment_boomerang", "moderator_shield", "fansa_baton", "tsuri_thumbnail_rod"]
const KNOWN_COMMENT_TAGS: Array[String] = ["敵強化", "ボス", "プレイヤー制限", "配信イベント", "ゲームジャンル", "歌", "お絵かき", "コラボ", "HARD", "特殊", "SPECIAL"]

var failures: Array[String] = []

func _ready() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	CodexManager.initialize_empty()
	_check(DifficultyProgressSystemScript.SAVE_VERSION == 5, "outer save schema is five")
	var weapons: Array = CodexManager.get_master_entries(CodexManager.CATEGORY_WEAPON)
	var accessories: Array = CodexManager.get_master_entries(CodexManager.CATEGORY_ACCESSORY)
	var characters: Array = CodexManager.get_master_entries(CodexManager.CATEGORY_CHARACTER)
	var comments: Array = CodexManager.get_master_entries(CodexManager.CATEGORY_COMMENT)
	_check(weapons.size() == 26, "effective weapon master has 26 entries")
	_check(accessories.size() == 10, "effective accessory master has 10 entries")
	_check(characters.size() == 6, "character master has 6 entries")
	_check(comments.size() == 44, "comment master has 44 entries")

	_test_weapon_models(weapons)
	_test_accessory_models(accessories)
	_test_comment_models(comments)
	_test_character_profiles(characters)
	_test_collection()

	if failures.is_empty():
		print("CODEX_V04_CONTENT_TESTS: PASS")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("CODEX_V04_CONTENT_TESTS: FAIL (%d)" % failures.size())
	get_tree().quit(1)

func _test_weapon_models(weapons: Array) -> void:
	for weapon_value in weapons:
		if not weapon_value is Dictionary:
			continue
		var weapon: Dictionary = weapon_value as Dictionary
		var stats_value: Variant = weapon.get("codexStats", [])
		_check(stats_value is Array and not (stats_value as Array).is_empty(), "weapon has codexStats: %s" % String(weapon.get("id", "")))
		var seen: Dictionary = {}
		if stats_value is Array:
			for stat_value in stats_value as Array:
				var stat_key := String(stat_value)
				_check(not seen.has(stat_key), "weapon codexStats has no duplicate: %s/%s" % [String(weapon.get("id", "")), stat_key])
				seen[stat_key] = true
				_check(Presentation.STAT_META.has(stat_key), "weapon codexStats uses known key: %s/%s" % [String(weapon.get("id", "")), stat_key])
		var model := Presentation.weapon_performance_model(weapon, INITIAL_WEAPON_IDS.has(String(weapon.get("id", ""))))
		if bool(weapon.get("isEvolved", false)):
			_check((model.get("levelRows", []) as Array).is_empty(), "evolved weapon has no LEVEL rows: %s" % String(weapon.get("id", "")))
		else:
			_check((model.get("levelRows", []) as Array).size() == maxi(1, int(weapon.get("maxLevel", 1))), "normal weapon has maxLevel rows: %s" % String(weapon.get("id", "")))
		_check(not bool(model.get("missing", false)), "weapon has at least one resolved performance value: %s" % String(weapon.get("id", "")))
		_check(not model.has("riskLevel"), "weapon performance model has no unrelated risk data")

	var ban := _find(weapons, "ban_hammer")
	var ban_level_one := WeaponSystemScript.codex_standard_stats_for_level(ban, 1, true)
	var ban_level_five := WeaponSystemScript.codex_standard_stats_for_level(ban, 5, true)
	_check(is_equal_approx(float(ban_level_one.get("damage", 0.0)), 12.0), "BAN hammer standard Lv1 damage is runtime-derived")
	_check(is_equal_approx(float(ban_level_one.get("range", 0.0)), 185.625), "BAN hammer standard Lv1 range is runtime-derived")
	_check(is_equal_approx(float(ban_level_one.get("attackInterval", 0.0)), 0.85), "BAN hammer standard Lv1 interval is runtime-derived")
	_check(is_equal_approx(float(ban_level_five.get("damage", 0.0)), 16.8), "BAN hammer standard Lv5 damage is runtime-derived")
	_check(is_equal_approx(float(ban_level_five.get("range", 0.0)), 245.025), "BAN hammer standard Lv5 range is runtime-derived")
	_check(absf(float(ban_level_five.get("attackInterval", 0.0)) - 0.6636) < 0.001, "BAN hammer standard Lv5 interval is runtime-derived")
	var kusa := WeaponSystemScript.codex_standard_stats_for_level(_find(weapons, "kusa_wave"), 5, false)
	_check(is_equal_approx(float(kusa.get("damage", 0.0)), 12.0), "kusa Lv5 damage uses runtime table")
	_check(is_equal_approx(float(kusa.get("attackInterval", 0.0)), 1.20), "kusa Lv5 interval uses runtime table")
	_check(is_equal_approx(float(kusa.get("range", 0.0)), 750.0), "kusa Lv5 distance uses runtime table")
	_check(is_equal_approx(float(kusa.get("sizeMultiplier", 0.0)), 1.45), "kusa Lv5 size uses runtime table")
	_check(int(kusa.get("bounceCount", 0)) == 2, "kusa Lv5 bounces use runtime table")
	var incomplete := Presentation.weapon_performance_model({"id": "unknown", "maxLevel": 3, "codexStats": ["unknownStat", "damage"], "damage": 4.0, "attackInterval": 1.0, "range": 2.0}, false)
	_check(not incomplete.is_empty(), "unknown weapon stat does not crash resolver")

func _test_accessory_models(accessories: Array) -> void:
	for accessory_value in accessories:
		if not accessory_value is Dictionary:
			continue
		var accessory: Dictionary = accessory_value as Dictionary
		var stats_value: Variant = accessory.get("codexStats", [])
		_check(stats_value is Array and not (stats_value as Array).is_empty(), "accessory has codexStats: %s" % String(accessory.get("id", "")))
		var model := Presentation.accessory_performance_model(accessory)
		_check((model.get("levelRows", []) as Array).size() == maxi(1, int(accessory.get("maxLevel", 1))), "accessory uses its real maxLevel: %s" % String(accessory.get("id", "")))
		_check(not bool(model.get("missing", false)), "accessory has at least one resolved performance value: %s" % String(accessory.get("id", "")))
	var high_speed := GiftSystemScript.codex_accessory_stats_for_level(_find(accessories, "high_speed_connection"), 5)
	_check(is_equal_approx(float(high_speed.get("attackIntervalMultiplier", 0.0)), pow(0.92, 5.0)), "high speed connection is cumulative")
	var sweet := GiftSystemScript.codex_accessory_stats_for_level(_find(accessories, "sweet_tooth"), 3)
	_check(is_equal_approx(float(sweet.get("goodEffectMultiplier", 0.0)), 1.45), "sweet tooth merit rate uses MarshmallowSystem")
	_check(is_equal_approx(float(sweet.get("kusoDurationMultiplier", 0.0)), 0.35), "sweet tooth duration floor uses MarshmallowSystem")
	_check(int(_find(accessories, "mini_humidifier").get("maxLevel", 0)) == 3, "humidifier maxLevel is three")
	var humidifier := GiftSystemScript.codex_accessory_stats_for_level(_find(accessories, "mini_humidifier"), 3)
	_check(is_equal_approx(float(humidifier.get("healInterval", 0.0)), 6.0) and int(humidifier.get("healAmount", 0)) == 6, "humidifier Lv3 uses runtime values")

func _test_comment_models(comments: Array) -> void:
	for comment_value in comments:
		if not comment_value is Dictionary:
			continue
		var comment: Dictionary = comment_value as Dictionary
		var model := Presentation.comment_effect_model(comment)
		var normal: Dictionary = model.get("normal", {}) as Dictionary
		_check(not normal.is_empty(), "comment has a normal effect model: %s" % String(comment.get("id", "")))
		_check(String(normal.get("description", "")).strip_edges() != "", "comment effect has description fallback: %s" % String(comment.get("id", "")))
		var tags: Array = model.get("tags", []) as Array
		for tag_value in tags:
			_check(KNOWN_COMMENT_TAGS.has(String(tag_value)), "comment tag is from known vocabulary: %s/%s" % [String(comment.get("id", "")), String(tag_value)])
		_check(not JSON.stringify(model).contains("riskLevel"), "comment model does not expose risk level: %s" % String(comment.get("id", "")))
	var short_range := Presentation.comment_effect_model(_find(comments, "short_range"))
	_check(not (short_range.get("heart", {}) as Dictionary).is_empty(), "explicit heartVariant produces heart model")
	var hard := Presentation.comment_effect_model(_find(comments, "hard_overclock"))
	_check(hard.get("hard", {}) is Dictionary and not (hard.get("hard", {}) as Dictionary).is_empty(), "HARD override gets separate model")
	var special := Presentation.comment_effect_model(_find(comments, "do_everything"))
	_check((special.get("normal", {}) as Dictionary).get("lines", []) is Array, "do_everything uses generic objective note")

func _test_character_profiles(characters: Array) -> void:
	var weapons := CodexManager.get_master_entries(CodexManager.CATEGORY_WEAPON)
	for character_value in characters:
		var character: Dictionary = character_value as Dictionary
		var profile_value: Variant = character.get("codexProfile", {})
		_check(profile_value is Dictionary and String((profile_value as Dictionary).get("description", "")).strip_edges() != "", "character has codexProfile description: %s" % String(character.get("id", "")))
		var model := Presentation.character_profile_model(character, weapons, [])
		_check(String(model.get("description", "")).strip_edges() != "", "character presentation uses profile description: %s" % String(character.get("id", "")))

func _test_collection() -> void:
	CodexManager.initialize_empty()
	var initial := CodexManager.get_collection_summary()
	_check(int(initial.get("total", 0)) == 84, "collection total is four current categories")
	var initial_comment_log: Dictionary = initial.get("commentLog", {}) as Dictionary
	_check(int(initial_comment_log.get("total", 0)) == 44, "comment log remains separate")
	_check(not bool(initial.get("completed", false)), "initial collection is incomplete")
	var before_comment_discovery_found := int(initial.get("found", 0))
	CodexManager.discover_comment("banana_floor")
	var after_comment_discovery := CodexManager.get_collection_summary()
	_check(int(after_comment_discovery.get("found", 0)) == before_comment_discovery_found, "comment discoveries do not enter collection total")
	for category in [CodexManager.CATEGORY_CHARACTER, CodexManager.CATEGORY_WEAPON, CodexManager.CATEGORY_ACCESSORY, CodexManager.CATEGORY_ENEMY]:
		for entry in CodexManager.get_master_entries(category):
			var id := String((entry as Dictionary).get("id", ""))
			CodexManager.discover(category, id)
	var complete := CodexManager.get_collection_summary()
	_check(int(complete.get("found", 0)) == 84 and int(complete.get("total", 0)) == 84, "collection counts all four categories")
	_check(bool(complete.get("completed", false)) and bool(complete.get("completedOnce", false)), "collection complete and completedOnce are distinct values")
	var saved := CodexManager.get_save_data()
	_check(int(saved.get("schemaVersion", 0)) == 4 and bool(saved.get("collection_completed_once", false)), "collection flag is saved in schema four")
	var saved_copy := saved.duplicate(true)
	var saved_characters: Dictionary = saved_copy.get(CodexManager.CATEGORY_CHARACTER, {}) as Dictionary
	var saved_ban: Dictionary = saved_characters.get("ban_chan", {}) as Dictionary
	_saved_ban_new(saved_ban)
	_check(not CodexManager.is_new(CodexManager.CATEGORY_CHARACTER, "ban_chan"), "collection reads do not mutate NEW state")
	CodexManager.load_save_data({"schemaVersion": 1, "characters": {"ban_chan": {"discovered": true, "new": false}}})
	_check(int(CodexManager.get_entry(CodexManager.CATEGORY_CHARACTER, "ban_chan").get("play_count", -1)) == 0, "schema one character entry gets record defaults")
	CodexManager.load_save_data({"schemaVersion": 2, "characters": {"ban_chan": {"discovered": true, "new": false}}, "comments": {"banana_floor": {"discovered": true, "new": true}}})
	_check(CodexManager.is_discovered(CodexManager.CATEGORY_COMMENT, "banana_floor"), "schema two comment entry remains readable")
	CodexManager.load_save_data(saved)
	_check(bool(CodexManager.collection_completed_once()), "completedOnce survives round trip")
	var partial := saved.duplicate(true)
	(partial.get(CodexManager.CATEGORY_ENEMY, {}) as Dictionary).clear()
	CodexManager.load_save_data(partial)
	_check(bool(CodexManager.collection_completed_once()), "completedOnce never resets after content becomes incomplete")

func _find(items: Array, id: String) -> Dictionary:
	for item_value in items:
		if item_value is Dictionary and String((item_value as Dictionary).get("id", "")) == id:
			return item_value as Dictionary
	return {}

func _saved_ban_new(entry: Dictionary) -> void:
	entry["new"] = true

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
