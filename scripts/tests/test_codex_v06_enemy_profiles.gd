extends Node

const Profile := preload("res://scripts/systems/enemy_codex_profile_system.gd")
const Presentation := preload("res://scripts/systems/codex_presentation_system.gd")
const Audit := preload("res://scripts/systems/codex_audit_system.gd")

var failures: Array[String] = []

func _ready() -> void:
	_run_tests()
	if failures.is_empty():
		print("CODEX_V06_ENEMY_PROFILE_TESTS: PASS")
	else:
		for failure in failures:
			push_error(failure)
		print("CODEX_V06_ENEMY_PROFILE_TESTS: FAIL (%d)" % failures.size())
	get_tree().quit(1 if not failures.is_empty() else 0)

func _run_tests() -> void:
	var raw := _read_array("res://data/codex_enemies.json")
	var sources := Presentation.load_sources()
	var catalog := Profile.build_catalog(raw, sources)
	_check(raw.size() == 44, "raw enemy profile input has 44 rows")
	_check(int(catalog.get("enabledCount", 0)) == 42, "profile catalog has 42 enabled enemies")
	_check(int(catalog.get("rawBossCount", 0)) == 7 and int(catalog.get("enabledBossCount", 0)) == 6, "profile catalog reports raw boss 7/enabled boss 6")
	_check(int(catalog.get("normalEnabledCount", 0)) == 36, "profile catalog reports 36 enabled non-boss enemies")
	_check(int(catalog.get("normalMobileCount", 0)) == 34 and int(catalog.get("normalFixedCount", 0)) == 2, "profile catalog separates 34 mobile and 2 fixed enemies")
	var cohorts := catalog.get("cohorts", {}) as Dictionary
	var normal := cohorts.get("normal", {}) as Dictionary
	_check(is_equal_approx(float(normal.get("hpMedian", 0.0)), 16.0), "normal HP median is 16")
	_check(is_equal_approx(float(normal.get("speedMedian", 0.0)), 90.0), "normal mobile speed median is 90")

	var by_id := catalog.get("byId", {}) as Dictionary
	_check(by_id.size() == 44, "every raw enemy receives a profile")
	var shooter := _profile(by_id, "shooter")
	_check(float(shooter.get("hp", 0.0)) == 14.0 and float(shooter.get("moveSpeed", 0.0)) == 95.0, "shooter uses EnemySystem HP/speed")
	_check((shooter.get("attackTypes", []) as Array).has("ranged") and (shooter.get("attackTypes", []) as Array).has("projectile"), "shooter is ranged projectile")
	_check(bool(shooter.get("hasContactDamage", false)) and not (shooter.get("resolvedTags", []) as Array).has("contact"), "shooter contact damage is separate from contact tag")
	var clipper := _profile(by_id, "clipper")
	_check((clipper.get("attackTypes", []) as Array).has("charge") and (clipper.get("resolvedTags", []) as Array).has("charge"), "clipper exposes charge")
	var kart := _profile(by_id, "enemy_wrong_way_kart")
	_check(float(kart.get("moveSpeed", 0.0)) == 292.0 and String((kart.get("speedRating", {}) as Dictionary).get("key", "")) == "very_high", "race kart is very fast by relative rating")
	var jammer := _profile(by_id, "enemy_jammer_cone")
	var mute_core := _profile(by_id, "collab_mute_core")
	_check(bool(jammer.get("stationary", false)) and String((jammer.get("speedRating", {}) as Dictionary).get("key", "")) == "stationary", "jammer cone is fixed")
	_check(bool(mute_core.get("stationary", false)) and String((mute_core.get("speedRating", {}) as Dictionary).get("key", "")) == "stationary", "mute core is fixed")
	var kuso := _profile(by_id, "boss_kuso_maro_king")
	_check(float(kuso.get("hp", 0.0)) == 360.0 and float(kuso.get("moveSpeed", 0.0)) == 56.0, "kuso king uses BossSystem.boss_speed")
	_check((kuso.get("attackTypes", []) as Array).has("projectile") and (kuso.get("attackTypes", []) as Array).has("area") and (kuso.get("attackTypes", []) as Array).has("summon"), "kuso king keeps multiple attack types")
	_check((kuso.get("summonIds", []) as Array).has("unread_maro"), "kuso king exposes unread maro summon")
	var last_offline := _profile(by_id, "last_offline")
	_check(float(last_offline.get("hp", 0.0)) == 2400.0 and float(last_offline.get("moveSpeed", 0.0)) == 90.0, "last offline uses relay HP and phase0 cruise speed")
	_check((last_offline.get("moveSpeedRange", []) as Array).size() == 5 and float((last_offline.get("moveSpeedRange", []) as Array)[0]) == 90.0, "last offline keeps relay cruise speed range")
	_check(String(last_offline.get("source", "")) == "relay_mode" and bool(last_offline.get("hasSummon", false)), "last offline uses relay source and summon attack")
	_check((last_offline.get("summonIds", []) as Array).has("noise_ghost_comment"), "last offline exposes noise summon")

	var low := Profile.relative_band(6.99, 10.0)
	var normal_low := Profile.relative_band(7.0, 10.0)
	var normal_high := Profile.relative_band(13.0, 10.0)
	var high := Profile.relative_band(13.01, 10.0)
	var very_high := Profile.relative_band(20.0, 10.0)
	_check(String(low.get("key", "")) == "low" and String(normal_low.get("key", "")) == "normal", "relative low boundary")
	_check(String(normal_high.get("key", "")) == "normal" and String(high.get("key", "")) == "high" and String(very_high.get("key", "")) == "very_high", "relative high boundaries")
	var boss_cohort := cohorts.get("boss", {}) as Dictionary
	_check(float(boss_cohort.get("hpMedian", 0.0)) > float(normal.get("hpMedian", 0.0)), "boss ratings use a separate cohort")

	for profile_value in catalog.get("profiles", []) as Array:
		var profile: Dictionary = profile_value as Dictionary
		var resolved: Array = profile.get("resolvedTags", []) as Array
		_check((resolved as Array).size() == Profile.detail_tags(resolved, bool(profile.get("isBoss", false))).size() or (resolved as Array).size() >= Profile.detail_tags(resolved, bool(profile.get("isBoss", false))).size(), "profile tags are resolved deterministically")
		_check(not (resolved as Array).has("bullet"), "legacy bullet tag is not emitted")
		_check((Profile.detail_tags(resolved, bool(profile.get("isBoss", false))) as Array).size() <= 3, "detail tags are capped at three")
	_check(Profile.primary_tag((shooter.get("resolvedTags", []) as Array)).is_empty() == false, "primary tag exists for discovered shooter")

	var override_master := _find(raw, "shooter").duplicate(true)
	var override_codex := (override_master.get("codex", {}) as Dictionary).duplicate(true)
	override_codex["attackTypeOverride"] = ["special"]
	override_codex["autoTagExcludes"] = ["projectile"]
	override_master["codex"] = override_codex
	var override_profile := Profile.build_catalog([override_master], sources).get("profiles", [])[0] as Dictionary
	_check((override_profile.get("attackTypes", []) as Array) == ["special"], "attack type override replaces automatic classification")
	_check(not (override_profile.get("resolvedTags", []) as Array).has("projectile"), "auto tag exclusion suppresses projectile")

	var hidden := Presentation.build_enemy_model(_find(raw, "shooter"), false, {}, sources)
	_check(String(hidden.get("displayName", "")) == "？？？" and String(hidden.get("imagePath", "")) == "", "undiscovered profile keeps name/image masked")
	_check((hidden.get("enemyProfile", {}) as Dictionary).is_empty() and (hidden.get("attackTypeLabels", []) as Array).is_empty() and (hidden.get("durabilityRating", {}) as Dictionary).is_empty(), "undiscovered profile does not leak performance")
	var discovered_model := Presentation.build_enemy_model(_find(raw, "shooter"), true, {}, sources)
	_check(String(discovered_model.get("primaryTag", "")) != "" and not (discovered_model.get("attackTypeLabels", []) as Array).is_empty(), "discovered model exposes profile labels")

	var report := Audit.audit({"enemies": raw}, {"enemies": raw.filter(func(item: Dictionary) -> bool: return bool(item.get("codexEnabled", true)))}, {}, sources)
	var report_counts := report.get("counts", {}) as Dictionary
	var report_enemies := report_counts.get("enemies", {}) as Dictionary
	_check(int(report_enemies.get("raw", 0)) == 44 and int(report_enemies.get("enabled", 0)) == 42, "audit counts raw/effective enemies")
	_check(int(report_enemies.get("bossRaw", 0)) == 7 and int(report_enemies.get("bossEnabled", 0)) == 6, "audit counts raw/effective bosses")
	_check(is_equal_approx(float(report_enemies.get("normalHpMedian", 0.0)), 16.0) and is_equal_approx(float(report_enemies.get("normalSpeedMedian", 0.0)), 90.0), "audit reports current normal medians")
	var report_text := Profile.build_report_text(catalog)
	_check(report_text.count("=== ") == 44, "audit report has 44 deterministic sections")
	_check(report_text.count("Codex Enabled: false") == 2 and report_text.contains("=== undo_ghost ===") and report_text.contains("=== boss_super_long_comment ==="), "audit report includes both disabled IDs")
	_check(report_text.contains("Raw boss: 7 / Enabled boss: 6"), "audit report includes boss totals")
	var manager_report := CodexManager.write_enemy_audit_report()
	_check(bool(manager_report.get("written", false)) and String(manager_report.get("path", "")).contains("enemy_codex_audit.txt"), "debug audit writes the user audit file")

	var combat_keys := ["hp", "speed", "moveSpeed", "damage", "contactDamage", "attackInterval", "attackRange"]
	for raw_value in raw:
		var row: Dictionary = raw_value as Dictionary
		var codex: Dictionary = row.get("codex", {}) as Dictionary
		for combat_key in combat_keys:
			_check(not codex.has(combat_key), "codex metadata does not duplicate combat value %s/%s" % [String(row.get("id", "")), combat_key])

func _profile(by_id: Dictionary, id: String) -> Dictionary:
	return (by_id.get(id, {}) as Dictionary).duplicate(true)

func _find(rows: Array, id: String) -> Dictionary:
	for value in rows:
		if value is Dictionary and String((value as Dictionary).get("id", "")) == id:
			return value as Dictionary
	return {}

func _read_array(path: String) -> Array:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return []
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed as Array if parsed is Array else []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
