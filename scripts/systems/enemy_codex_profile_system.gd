class_name EnemyCodexProfileSystem
extends RefCounted

## Read-only bridge between the enemy runtime sources and the Codex UI/audit.
## Combat values are always read from EnemySystem/BossSystem/JSON sources; this
## file intentionally contains no enemy balance constants.

const EnemySystemScript := preload("res://scripts/systems/enemy_system.gd")
const BossSystemScript := preload("res://scripts/systems/boss_system.gd")

const TAG_ORDER: Array[String] = [
	"contact", "ranged", "projectile", "fast", "tank", "charge",
	"summon", "area", "bullet_hell", "support", "special", "boss_only"
]
const TAG_LABELS: Dictionary = {
	"contact": "接触",
	"ranged": "遠距離",
	"projectile": "飛び道具",
	"fast": "高速",
	"tank": "高耐久",
	"charge": "突進",
	"summon": "召喚",
	"area": "範囲攻撃",
	"bullet_hell": "弾幕",
	"support": "支援",
	"special": "特殊",
	"boss_only": "ボス戦限定"
}
const STAGE_LABELS: Dictionary = {
	"zatsudan": "雑談枠",
	"gameplay": "ゲーム実況枠",
	"singing": "歌枠",
	"drawing": "お絵かき枠",
	"collab": "コラボ枠",
	"relay": "配信リレー"
}
const KNOWN_TAGS: Array[String] = TAG_ORDER
const PROJECTILE_BEHAVIORS: Array[String] = [
	"shooter", "keep_distance_shooter", "slow_spread_shooter",
	"drone_keep_distance", "drawing_red_pen_teacher", "stg_side_move"
]
const CHARGE_BEHAVIORS: Array[String] = ["charger", "ambush_chase", "linear_pass"]
const SUPPORT_BEHAVIORS: Array[String] = [
	"collab_messenger_pigeon", "collab_discord_troll", "collab_volume_police",
	"collab_exclusive_listener", "collab_division_noise"
]
const FIXED_BEHAVIORS: Array[String] = ["stationary_obstacle", "collab_mute_core"]
const AREA_BEHAVIORS: Array[String] = ["drawing_bucket_slime", "collab_volume_police"]
const BULLET_HELL_BEHAVIORS: Array[String] = [
	"slow_spread_shooter", "stg_side_move", "drone_keep_distance"
]

static func load_sources() -> Dictionary:
	return {
		"bosses": _read_json("res://data/bosses.json"),
		"relayMode": _read_json("res://data/relay_mode.json"),
		"difficultyModes": _read_json("res://data/difficulty_modes.json")
	}

static func runtime_display_name(master: Dictionary, sources: Dictionary = {}) -> String:
	var id := String(master.get("id", "")).strip_edges()
	if id == "":
		return ""
	var safe_sources := sources.duplicate(true)
	if safe_sources.is_empty():
		safe_sources = load_sources()
	if bool(master.get("relayBoss", false)) or id == "last_offline":
		var relay_mode := _dictionary(safe_sources.get("relayMode", {}))
		var relay_boss := _dictionary(relay_mode.get("boss", {}))
		var relay_name := String(relay_boss.get("displayName", "")).strip_edges()
		if relay_name != "":
			return relay_name
	elif bool(master.get("isBoss", false)):
		var boss_data := _find_boss_data(id, safe_sources.get("bosses", []))
		var boss_name := String(boss_data.get("displayName", "")).strip_edges()
		if boss_name != "":
			return boss_name
	else:
		var runtime_data := EnemySystemScript.enemy_data(id)
		var runtime_name := String(runtime_data.get("displayName", "")).strip_edges()
		if runtime_name != "":
			return runtime_name
	return ""

static func canonical_display_name(master: Dictionary, sources: Dictionary = {}) -> String:
	var id := String(master.get("id", "")).strip_edges()
	var runtime_name := runtime_display_name(master, sources)
	if runtime_name != "":
		return runtime_name
	var master_name := String(master.get("displayName", "")).strip_edges()
	return master_name if master_name != "" else id

static func build_catalog(raw_enemy_masters: Array, sources: Dictionary = {}) -> Dictionary:
	var safe_sources := sources.duplicate(true)
	if safe_sources.is_empty():
		safe_sources = load_sources()
	var profiles: Array[Dictionary] = []
	for raw_value in raw_enemy_masters:
		if raw_value is Dictionary:
			profiles.append(build_profile(raw_value as Dictionary, safe_sources))
	profiles.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("order", 0)) < int(b.get("order", 0))
	)

	var normal_hp: Array[float] = []
	var normal_speeds: Array[float] = []
	var boss_hp: Array[float] = []
	var boss_speeds: Array[float] = []
	var normal_mobile_ids: Array[String] = []
	var normal_fixed_ids: Array[String] = []
	var enabled_boss_ids: Array[String] = []
	for profile in profiles:
		if not bool(profile.get("codexEnabled", true)):
			continue
		var id := String(profile.get("id", ""))
		var hp: Variant = _positive_number(profile.get("hp", null))
		var speed: Variant = _positive_number(profile.get("moveSpeed", null))
		if bool(profile.get("isBoss", false)):
			enabled_boss_ids.append(id)
			if hp != null:
				boss_hp.append(float(hp))
			if speed != null:
				boss_speeds.append(float(speed))
		else:
			if hp != null:
				normal_hp.append(float(hp))
			if bool(profile.get("stationary", false)):
				normal_fixed_ids.append(id)
			elif speed != null:
				normal_mobile_ids.append(id)
				normal_speeds.append(float(speed))

	var normal_hp_median := _median(normal_hp)
	var normal_speed_median := _median(normal_speeds)
	var boss_hp_median := _median(boss_hp)
	var boss_speed_median := _median(boss_speeds)
	for index in range(profiles.size()):
		var profile: Dictionary = profiles[index].duplicate(true)
		var is_boss := bool(profile.get("isBoss", false))
		var hp_median := boss_hp_median if is_boss else normal_hp_median
		var speed_median := boss_speed_median if is_boss else normal_speed_median
		profile["durabilityRating"] = _rating_for_value(profile.get("hp", null), hp_median, "durability", is_boss)
		if bool(profile.get("stationary", false)):
			profile["speedRating"] = _stationary_rating(is_boss)
		else:
			profile["speedRating"] = _rating_for_value(profile.get("moveSpeed", null), speed_median, "speed", is_boss)
		var auto_tags := _auto_tags(profile)
		var manual_tags := _manual_tags(profile.get("manualTags", []))
		var excludes := _manual_tags(profile.get("autoTagExcludes", []))
		profile["autoTags"] = _stable_tags(auto_tags)
		profile["manualTags"] = _stable_tags(manual_tags)
		profile["resolvedTags"] = _resolve_tags(auto_tags, manual_tags, excludes)
		profile["primaryTag"] = primary_tag(profile["resolvedTags"] as Array, is_boss)
		profile["detailTags"] = detail_tags(profile["resolvedTags"] as Array, is_boss)
		profiles[index] = profile

	var by_id: Dictionary = {}
	for profile in profiles:
		by_id[String(profile.get("id", ""))] = profile.duplicate(true)
	var raw_boss_count := 0
	for raw_value in raw_enemy_masters:
		if raw_value is Dictionary and (bool((raw_value as Dictionary).get("isBoss", false)) or bool((raw_value as Dictionary).get("relayBoss", false))):
			raw_boss_count += 1
	var warnings: Array[String] = []
	for profile in profiles:
		for warning_value in profile.get("warnings", []) as Array:
			warnings.append(String(warning_value))
	return {
		"profiles": profiles.duplicate(true),
		"byId": by_id.duplicate(true),
		"rawCount": raw_enemy_masters.size(),
		"enabledCount": profiles.filter(func(item: Dictionary) -> bool: return bool(item.get("codexEnabled", true))).size(),
		"rawBossCount": raw_boss_count,
		"enabledBossCount": enabled_boss_ids.size(),
		"normalEnabledCount": profiles.filter(func(item: Dictionary) -> bool: return bool(item.get("codexEnabled", true)) and not bool(item.get("isBoss", false))).size(),
		"normalMobileCount": normal_mobile_ids.size(),
		"normalFixedCount": normal_fixed_ids.size(),
		"cohorts": {
			"normal": {"hpMedian": normal_hp_median, "speedMedian": normal_speed_median, "mobileIds": normal_mobile_ids, "fixedIds": normal_fixed_ids},
			"boss": {"hpMedian": boss_hp_median, "speedMedian": boss_speed_median, "ids": enabled_boss_ids}
		},
		"warnings": warnings.duplicate(true)
	}

static func build_profile(master: Dictionary, sources: Dictionary = {}) -> Dictionary:
	var safe_sources := sources.duplicate(true)
	if safe_sources.is_empty():
		safe_sources = load_sources()
	var id := String(master.get("id", "")).strip_edges()
	var master_display_name := String(master.get("displayName", "")).strip_edges()
	var runtime_display_name_value := runtime_display_name(master, safe_sources)
	var canonical_display_name_value := runtime_display_name_value if runtime_display_name_value != "" else (master_display_name if master_display_name != "" else id)
	var is_boss := bool(master.get("isBoss", false)) or bool(master.get("relayBoss", false))
	var source := "enemy_system"
	var runtime_data: Dictionary = {}
	var attacks: Array[Dictionary] = []
	var move_speed: Variant = null
	var move_range: Array[float] = []
	var hp: Variant = null
	var contact_damage: Variant = null
	var provenance: Dictionary = {}
	var warnings: Array[String] = []

	if bool(master.get("relayBoss", false)) or id == "last_offline":
		source = "relay_mode"
		var relay_mode := _dictionary(safe_sources.get("relayMode", {}))
		var relay_boss := _dictionary(relay_mode.get("boss", {}))
		runtime_data = relay_boss.duplicate(true)
		hp = _number_or_null(relay_boss.get("maxHp", relay_boss.get("hp", null)))
		var movement := _dictionary(relay_boss.get("movement", {}))
		if movement.is_empty():
			movement = _dictionary(relay_mode.get("movement", {}))
		move_range = _float_array(movement.get("cruiseSpeeds", []))
		if not move_range.is_empty():
			move_speed = move_range[0]
		contact_damage = _number_or_null(relay_boss.get("contactDamage", null))
		attacks = _relay_attacks(relay_boss, relay_mode)
		provenance = {"hp": "relay_mode.boss.maxHp", "moveSpeed": "relay_mode.boss.movement.cruiseSpeeds[0]", "moveSpeedRange": "relay_mode.boss.movement.cruiseSpeeds", "contactDamage": "relay_mode.boss.contactDamage", "attacks": "relay_mode.boss.attacks"}
		if relay_boss.is_empty():
			warnings.append("relay boss source missing: %s" % id)
	else:
		if is_boss:
			source = "bosses"
			runtime_data = _find_boss_data(id, safe_sources.get("bosses", []))
			hp = _number_or_null(runtime_data.get("hp", null))
			if runtime_data.has("speed"):
				move_speed = BossSystemScript.boss_speed(runtime_data)
				move_range = [float(move_speed)]
			contact_damage = _number_or_null(runtime_data.get("contactDamage", EnemySystemScript.contact_damage_for_kind(id, true)))
			attacks = _boss_attacks(runtime_data)
			provenance = {"hp": "bosses.hp", "moveSpeed": "BossSystem.boss_speed(bosses.speed)", "contactDamage": "bosses.contactDamage/BossSystem", "attacks": "bosses.attacks/attackData"}
			if runtime_data.is_empty():
				warnings.append("boss source missing: %s" % id)
		else:
			runtime_data = EnemySystemScript.enemy_data(id)
			hp = _number_or_null(runtime_data.get("hp", null))
			move_speed = _number_or_null(runtime_data.get("speed", null))
			if move_speed != null:
				move_range = [float(move_speed)]
			contact_damage = _number_or_null(runtime_data.get("contactDamage", EnemySystemScript.contact_damage_for_kind(id, false)))
			attacks = _runtime_attacks(id, runtime_data, master)
			provenance = {"hp": "EnemySystem.enemy_data.hp", "moveSpeed": "EnemySystem.enemy_data.speed", "contactDamage": "EnemySystem.enemy_data.contactDamage/EnemySystem.contact_damage_for_kind", "attacks": "EnemySystem runtimeBehavior"}
			if runtime_data.is_empty():
				warnings.append("enemy source missing: %s" % id)

	var behavior := String(runtime_data.get("behavior", ""))
	var stationary := behavior in FIXED_BEHAVIORS or bool(runtime_data.get("fixedHazard", false))
	var codex := _codex_dictionary(master)
	var manual_tag_value: Variant = codex.get("behaviorTags", null)
	if not manual_tag_value is Array or (manual_tag_value as Array).is_empty():
		manual_tag_value = master.get("behaviorTags", [])
	var manual_tags := _string_array(manual_tag_value)
	var auto_excludes := _string_array(codex.get("autoTagExcludes", []))
	var attack_override := _string_array(codex.get("attackTypeOverride", []))
	var main_attacks := _normalize_main_attacks(codex.get("mainAttacks", []))
	var manual_summons := _string_array(codex.get("summonIds", []))
	var special_effects := _string_array(codex.get("specialEffects", []))
	var all_summons := manual_summons.duplicate()
	for attack in attacks:
		var summon_id := String(attack.get("summonId", attack.get("enemyId", "")))
		if summon_id != "" and not all_summons.has(summon_id):
			all_summons.append(summon_id)
	var attack_types := attack_override if not attack_override.is_empty() else _attack_types(attacks, behavior, stationary)
	var has_projectile := _has_attack_type(attacks, "projectile") or attack_types.has("projectile")
	var has_summon := not all_summons.is_empty() or attack_types.has("summon")
	var has_slow := _attacks_have_field(attacks, ["slow", "slow_field", "area_slow"]) or special_effects.has("slow") or behavior == "drawing_bucket_slime"
	var has_knockback := _attacks_have_property(attacks, "knockback")
	var has_special := not special_effects.is_empty() or behavior in FIXED_BEHAVIORS or behavior in SUPPORT_BEHAVIORS or attack_types.has("special")
	var has_charge := attack_types.has("charge")
	var attack_summary := _single_numeric_summary(attacks)
	var missing: Array[String] = []
	if hp == null:
		missing.append("hp")
	if move_speed == null:
		missing.append("moveSpeed")
	if contact_damage == null:
		missing.append("contactDamage")
	var lore_value: Variant = master.get("codexLore", master.get("codex_lore", {}))
	var lore_template := ""
	var lore_card_count := 0
	var lore_archive_count := 0
	if lore_value is Dictionary:
		var lore := lore_value as Dictionary
		lore_template = String(lore.get("template", ""))
		var lore_cards: Variant = lore.get("cards", [])
		var lore_paragraphs: Variant = lore.get("archiveParagraphs", lore.get("archive_paragraphs", []))
		lore_card_count = (lore_cards as Array).size() if lore_cards is Array else 0
		lore_archive_count = (lore_paragraphs as Array).size() if lore_paragraphs is Array else 0
	return {
		"id": id,
		"displayName": canonical_display_name_value,
		"runtimeDisplayName": runtime_display_name_value,
		"canonicalDisplayName": canonical_display_name_value,
		"stageIds": _string_array(master.get("codexStages", master.get("spawnFrames", []))),
		"stageLabels": _stage_labels(master.get("codexStages", master.get("spawnFrames", []))),
		"spawnTypes": _string_array(master.get("codexSpawnTypes", [])),
		"source": source,
		"codexEnabled": bool(master.get("codexEnabled", true)),
		"isBoss": is_boss,
		"loreTemplate": lore_template,
		"loreCardCount": lore_card_count,
		"loreArchiveParagraphCount": lore_archive_count,
		"order": int(master.get("order", 0)),
		"hp": hp,
		"moveSpeed": move_speed,
		"moveSpeedRange": move_range,
		"contactDamage": contact_damage,
		"runtimeBehavior": behavior,
		"stationary": stationary,
		"attackTypes": attack_types,
		"attacks": attacks,
		"attackDamage": attack_summary.get("damage", null),
		"attackInterval": attack_summary.get("interval", null),
		"attackRange": attack_summary.get("range", null),
		"projectileSpeed": attack_summary.get("projectileSpeed", null),
		"projectileCount": attack_summary.get("projectileCount", null),
		"projectilePattern": attack_summary.get("projectilePattern", null),
		"hasContactDamage": contact_damage != null and float(contact_damage) > 0.0,
		"hasProjectile": has_projectile,
		"hasCharge": has_charge,
		"hasSummon": has_summon,
		"hasSlow": has_slow,
		"hasKnockback": has_knockback,
		"hasSpecialEffect": has_special,
		"summonIds": all_summons,
		"manualTags": manual_tags,
		"autoTagExcludes": auto_excludes,
		"attackTypeOverride": attack_override,
		"mainAttacks": main_attacks,
		"specialEffects": special_effects,
		"autoTags": [],
		"resolvedTags": [],
		"warnings": warnings,
		"missing": missing,
		"provenance": provenance
	}

static func relative_band(value: Variant, median: float, thresholds: Dictionary = {}) -> Dictionary:
	if not _is_number(value) or median <= 0.0 or float(value) <= 0.0:
		return {"key": "", "label": "---", "ratio": null, "value": value, "median": median}
	var ratio := float(value) / median
	var low := float(thresholds.get("low", 0.7))
	var normal := float(thresholds.get("normal", 1.3))
	var high := float(thresholds.get("high", 2.0))
	var key := "low" if ratio < low else ("normal" if ratio <= normal else ("high" if ratio < high else "very_high"))
	return {"key": key, "label": key, "ratio": ratio, "value": float(value), "median": median}

static func tag_label(tag: String) -> String:
	return String(TAG_LABELS.get(tag, ""))

static func primary_tag(tags: Array, is_boss: bool = false) -> String:
	for tag in TAG_ORDER:
		if not tags.has(tag):
			continue
		if is_boss and tag == "boss_only" and tags.size() > 1:
			continue
		return tag
	return ""

static func detail_tags(tags: Array, is_boss: bool = false) -> Array[String]:
	var result: Array[String] = []
	for tag in TAG_ORDER:
		if not tags.has(tag):
			continue
		if is_boss and tag == "boss_only" and tags.size() > 1:
			continue
		result.append(tag)
		if result.size() >= 3:
			break
	return result

static func build_report_text(catalog: Dictionary) -> String:
	var lines: Array[String] = ["[Enemy Codex Audit]", ""]
	lines.append("Raw enemies: %d / Enabled: %d" % [int(catalog.get("rawCount", 0)), int(catalog.get("enabledCount", 0))])
	lines.append("Raw boss: %d / Enabled boss: %d" % [int(catalog.get("rawBossCount", 0)), int(catalog.get("enabledBossCount", 0))])
	lines.append("Normal non-boss: %d / Mobile: %d / Fixed: %d" % [int(catalog.get("normalEnabledCount", 0)), int(catalog.get("normalMobileCount", 0)), int(catalog.get("normalFixedCount", 0))])
	var cohorts := catalog.get("cohorts", {}) as Dictionary
	var normal := cohorts.get("normal", {}) as Dictionary
	var boss := cohorts.get("boss", {}) as Dictionary
	lines.append("Normal cohort median HP: %s / speed: %s" % [_format_number(normal.get("hpMedian", null)), _format_number(normal.get("speedMedian", null))])
	lines.append("Boss cohort median HP: %s / speed: %s" % [_format_number(boss.get("hpMedian", null)), _format_number(boss.get("speedMedian", null))])
	lines.append("")
	for profile_value in catalog.get("profiles", []) as Array:
		if not profile_value is Dictionary:
			continue
		var profile: Dictionary = profile_value as Dictionary
		lines.append("=== %s ===" % String(profile.get("id", "---")))
		lines.append("Name: %s" % String(profile.get("displayName", "---")))
		lines.append("Codex Enabled: %s" % ("true" if bool(profile.get("codexEnabled", false)) else "false"))
		lines.append("Boss: %s" % ("true" if bool(profile.get("isBoss", false)) else "false"))
		lines.append("Source: %s" % String(profile.get("source", "---")))
		lines.append("Lore: %s / cards: %s / archive paragraphs: %s" % [String(profile.get("loreTemplate", "---")) if String(profile.get("loreTemplate", "")) != "" else "---", int(profile.get("loreCardCount", 0)), int(profile.get("loreArchiveParagraphCount", 0))])
		lines.append("Stages: %s" % _array_text(profile.get("stageLabels", [])))
		lines.append("Spawn: %s" % _array_text(profile.get("spawnTypes", [])))
		lines.append("Stats:")
		lines.append("HP: %s" % _format_number(profile.get("hp", null)))
		lines.append("Move speed: %s" % _format_number(profile.get("moveSpeed", null)))
		lines.append("Move speed range: %s" % _array_text(profile.get("moveSpeedRange", [])))
		lines.append("Contact damage: %s" % _format_number(profile.get("contactDamage", null)))
		lines.append("Attack types: %s" % _array_text(profile.get("attackTypes", [])))
		lines.append("Attacks: %s" % _attack_report_text(profile.get("attacks", [])))
		lines.append("Projectile: %s / Summon: %s / Slow: %s / Knockback: %s / Special: %s" % [
			_yes_no(profile.get("hasProjectile", false)), _yes_no(profile.get("hasSummon", false)),
			_yes_no(profile.get("hasSlow", false)), _yes_no(profile.get("hasKnockback", false)), _yes_no(profile.get("hasSpecialEffect", false))
		])
		lines.append("Summon IDs: %s" % _array_text(profile.get("summonIds", [])))
		lines.append("Auto tags: %s" % _array_text(profile.get("autoTags", [])))
		lines.append("Manual tags: %s" % _array_text(profile.get("manualTags", [])))
		lines.append("Resolved tags: %s" % _array_text(profile.get("resolvedTags", [])))
		lines.append("Durability: %s / Speed rating: %s" % [_rating_text(profile.get("durabilityRating", {})), _rating_text(profile.get("speedRating", {}))])
		lines.append("Missing: %s" % _array_text(profile.get("missing", [])))
		lines.append("Warnings: %s" % _array_text(profile.get("warnings", [])))
		lines.append("")
	return "\n".join(lines)

static func _auto_tags(profile: Dictionary) -> Array[String]:
	var tags: Array[String] = []
	var behavior := String(profile.get("runtimeBehavior", ""))
	var attack_types: Array = profile.get("attackTypes", []) as Array
	if attack_types.has("contact"):
		tags.append("contact")
	if attack_types.has("ranged"):
		tags.append("ranged")
	if attack_types.has("projectile"):
		tags.append("projectile")
	if attack_types.has("charge"):
		tags.append("charge")
	if attack_types.has("summon"):
		tags.append("summon")
	if attack_types.has("area"):
		tags.append("area")
	if attack_types.has("special"):
		tags.append("special")
	if behavior in SUPPORT_BEHAVIORS:
		tags.append("support")
	if behavior in BULLET_HELL_BEHAVIORS:
		tags.append("bullet_hell")
	var durability := profile.get("durabilityRating", {}) as Dictionary
	if String(durability.get("key", "")) in ["high", "very_high"]:
		tags.append("tank")
	var speed := profile.get("speedRating", {}) as Dictionary
	if String(speed.get("key", "")) in ["high", "very_high"]:
		tags.append("fast")
	if bool(profile.get("isBoss", false)) or _has_boss_only_spawn(profile):
		tags.append("boss_only")
	return tags

static func _resolve_tags(auto_tags: Array, manual_tags: Array, excludes: Array) -> Array[String]:
	var present: Dictionary = {}
	for tag_value in auto_tags + manual_tags:
		var tag := _canonical_tag(String(tag_value))
		if tag in KNOWN_TAGS and not excludes.has(tag):
			present[tag] = true
	var result: Array[String] = []
	for tag in TAG_ORDER:
		if present.has(tag):
			result.append(tag)
	return result

static func _canonical_tag(tag: String) -> String:
	return "projectile" if tag == "bullet" else tag

static func _manual_tags(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for item in value as Array:
			var tag := _canonical_tag(String(item).strip_edges())
			if tag != "" and KNOWN_TAGS.has(tag) and not result.has(tag):
				result.append(tag)
	return result

static func _attack_types(attacks: Array[Dictionary], behavior: String, stationary: bool) -> Array[String]:
	var result: Array[String] = []
	for attack in attacks:
		var type := String(attack.get("type", ""))
		if type in ["contact", "ranged", "projectile", "charge", "summon", "area", "special"] and not result.has(type):
			result.append(type)
	if result.is_empty():
		if behavior in PROJECTILE_BEHAVIORS:
			result = ["ranged", "projectile"]
		elif behavior in CHARGE_BEHAVIORS:
			result = ["charge"]
		elif behavior in FIXED_BEHAVIORS or stationary:
			result = ["special"]
		elif behavior in SUPPORT_BEHAVIORS:
			result = ["special"]
		else:
			result = ["contact"]
	if behavior in PROJECTILE_BEHAVIORS and not result.has("ranged"):
		result.push_front("ranged")
	if behavior in PROJECTILE_BEHAVIORS and not result.has("projectile"):
		result.append("projectile")
	return result

static func _runtime_attacks(id: String, data: Dictionary, master: Dictionary) -> Array[Dictionary]:
	var behavior := String(data.get("behavior", ""))
	var attacks: Array[Dictionary] = []
	if behavior in PROJECTILE_BEHAVIORS:
		var count: Variant = null
		var pattern: Variant = null
		if behavior == "drone_keep_distance":
			count = 3
			pattern = "3-way"
		elif behavior == "slow_spread_shooter":
			count = 3
			pattern = "spread"
		else:
			count = 1
			pattern = "single"
		attacks.append({"id": "%s_projectile" % id, "type": "projectile", "damage": null, "interval": null, "range": null, "projectileSpeed": null, "projectileCount": count, "projectilePattern": pattern})
	elif behavior in CHARGE_BEHAVIORS:
		attacks.append({"id": "%s_charge" % id, "type": "charge", "damage": null, "interval": null, "range": null, "projectileSpeed": null, "projectileCount": null, "projectilePattern": null})
	elif behavior in AREA_BEHAVIORS:
		attacks.append({"id": "%s_area" % id, "type": "area", "damage": null, "interval": null, "range": null, "projectileSpeed": null, "projectileCount": null, "projectilePattern": null})
	elif behavior in SUPPORT_BEHAVIORS or behavior in FIXED_BEHAVIORS:
		attacks.append({"id": "%s_special" % id, "type": "special", "damage": null, "interval": null, "range": null, "projectileSpeed": null, "projectileCount": null, "projectilePattern": null})
	else:
		attacks.append({"id": "%s_contact" % id, "type": "contact", "damage": null, "interval": null, "range": null, "projectileSpeed": null, "projectileCount": null, "projectilePattern": null})
	return attacks

static func _boss_attacks(data: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var attack_data: Variant = data.get("attackData", {})
	if attack_data is Dictionary and not (attack_data as Dictionary).is_empty():
		for key in (attack_data as Dictionary).keys():
			var raw := _dictionary((attack_data as Dictionary)[key])
			if raw.is_empty():
				raw = {"id": String(key)}
			else:
				raw["id"] = String(raw.get("id", key))
			result.append(_normalize_attack(raw))
	else:
		var attacks: Variant = data.get("attacks", [])
		if attacks is Array:
			for attack_value in attacks as Array:
				var id := String(attack_value)
				result.append(_normalize_attack({"id": id, "type": _infer_attack_type(id)}))
	return result

static func _relay_attacks(boss_data: Dictionary, relay_mode: Dictionary) -> Array[Dictionary]:
	var attacks: Variant = boss_data.get("attacks", relay_mode.get("attacks", {}))
	if attacks is Dictionary:
		var result: Array[Dictionary] = []
		for key in (attacks as Dictionary).keys():
			var raw := _dictionary((attacks as Dictionary)[key])
			raw["id"] = String(raw.get("id", key))
			result.append(_normalize_attack(raw))
		return result
	return _boss_attacks(boss_data)

static func _normalize_attack(raw: Dictionary) -> Dictionary:
	var id := String(raw.get("id", "attack"))
	var attack_type := String(raw.get("attackType", raw.get("type", _infer_attack_type(id))))
	var normalized := {
		"id": id,
		"displayName": String(raw.get("displayName", raw.get("label", id))),
		"type": _infer_attack_type(attack_type),
		"damage": _number_or_null(raw.get("damage", raw.get("contactDamage", null))),
		"interval": _number_or_null(raw.get("interval", raw.get("cooldown", raw.get("reuseCooldown", null)))),
		"range": _number_or_null(raw.get("range", raw.get("radius", null))),
		"projectileSpeed": _number_or_null(raw.get("projectileSpeed", raw.get("bulletSpeed", null))),
		"projectileCount": _number_or_null(raw.get("projectileCount", raw.get("bulletCount", raw.get("count", null)))),
		"projectilePattern": String(raw.get("projectilePattern", attack_type)) if raw.has("projectilePattern") or "projectile" in attack_type.to_lower() else null,
		"summonId": String(raw.get("enemyId", raw.get("enemyKind", raw.get("summonId", "")))),
		"slow": raw.get("slow", raw.get("slowRate", null)),
		"knockback": raw.get("knockback", null)
	}
	return normalized

static func _infer_attack_type(value: String) -> String:
	var raw := value.to_lower()
	if raw.contains("summon") or raw.contains("spawn"):
		return "summon"
	if raw.contains("slow") or raw.contains("field") or raw.contains("puddle") or raw.contains("ring") or raw.contains("wave") or raw.contains("area"):
		return "area"
	if raw.contains("charge") or raw.contains("dash") or raw.contains("rush") or raw.contains("sweep"):
		return "charge"
	if raw.contains("laser") or raw.contains("bullet") or raw.contains("shot") or raw.contains("projectile") or raw.contains("barrage"):
		return "projectile"
	if raw.contains("mute") or raw.contains("noise") or raw.contains("partner") or raw.contains("divide") or raw.contains("support"):
		return "special"
	return "contact"

static func _single_numeric_summary(attacks: Array[Dictionary]) -> Dictionary:
	var result: Dictionary = {"damage": null, "interval": null, "range": null, "projectileSpeed": null, "projectileCount": null, "projectilePattern": null}
	for key in ["damage", "interval", "range", "projectileSpeed", "projectileCount"]:
		var values: Array[float] = []
		for attack in attacks:
			var value: Variant = attack.get(key, null)
			if _is_number(value):
				values.append(float(value))
		if not values.is_empty() and _all_equal(values):
			result[key] = values[0]
	var patterns: Array[String] = []
	for attack in attacks:
		var pattern := str(attack.get("projectilePattern", ""))
		if pattern != "" and not patterns.has(pattern):
			patterns.append(pattern)
	if patterns.size() == 1:
		result["projectilePattern"] = patterns[0]
	return result

static func _rating_for_value(value: Variant, median: float, kind: String, is_boss: bool) -> Dictionary:
	var raw := relative_band(value, median)
	var key := String(raw.get("key", ""))
	var labels := {"durability": {"low": "低い", "normal": "普通", "high": "高い", "very_high": "非常に高い"}, "speed": {"low": "遅い", "normal": "普通", "high": "速い", "very_high": "非常に速い"}}
	var label := String((labels.get(kind, {}) as Dictionary).get(key, "---"))
	raw["label"] = label
	raw["cohort"] = "boss" if is_boss else "normal"
	raw["cohortLabel"] = "ボス内比較" if is_boss else "通常敵比較"
	return raw

static func _stationary_rating(is_boss: bool) -> Dictionary:
	return {"key": "stationary", "label": "移動しない", "ratio": null, "value": 0.0, "median": null, "cohort": "boss" if is_boss else "normal", "cohortLabel": "ボス内比較" if is_boss else "通常敵比較"}

static func _has_boss_only_spawn(profile: Dictionary) -> bool:
	var spawn_types: Array = profile.get("spawnTypes", []) as Array
	return spawn_types.has("boss_only") or spawn_types.has("boss_summon") or spawn_types.has("relay_final_boss")

static func _has_attack_type(attacks: Array[Dictionary], type: String) -> bool:
	for attack in attacks:
		if String(attack.get("type", "")) == type:
			return true
	return false

static func _attacks_have_field(attacks: Array[Dictionary], types: Array) -> bool:
	for attack in attacks:
		if types.has(String(attack.get("type", ""))):
			return true
		if attack.get("slow", null) != null:
			return true
	return false

static func _attacks_have_property(attacks: Array[Dictionary], key: String) -> bool:
	for attack in attacks:
		var value: Variant = attack.get(key, null)
		if value != null and String(value) != "":
			return true
	return false

static func _find_boss_data(id: String, raw_value: Variant) -> Dictionary:
	if raw_value is Array:
		for item in raw_value as Array:
			if item is Dictionary and String((item as Dictionary).get("id", "")) == id:
				return (item as Dictionary).duplicate(true)
	return {}

static func _codex_dictionary(master: Dictionary) -> Dictionary:
	var value: Variant = master.get("codex", {})
	return (value as Dictionary).duplicate(true) if value is Dictionary else {}

static func _normalize_main_attacks(value: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if value is Array:
		for item in value as Array:
			if item is Dictionary:
				result.append((item as Dictionary).duplicate(true))
			elif String(item).strip_edges() != "":
				result.append({"id": String(item), "label": String(item)})
	return result

static func _dictionary(value: Variant) -> Dictionary:
	return value as Dictionary if value is Dictionary else {}

static func _string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for item in value as Array:
			var text := String(item).strip_edges()
			if text != "" and not result.has(text):
				result.append(text)
	return result

static func _stage_labels(value: Variant) -> Array[String]:
	var result: Array[String] = []
	for stage in _string_array(value):
		var normalized := stage.to_lower()
		if normalized == "chat" or normalized == "talk":
			normalized = "zatsudan"
		elif normalized == "game":
			normalized = "gameplay"
		elif normalized == "song":
			normalized = "singing"
		var label := String(STAGE_LABELS.get(normalized, stage))
		if not result.has(label):
			result.append(label)
	return result

static func _float_array(value: Variant) -> Array[float]:
	var result: Array[float] = []
	if value is Array:
		for item in value as Array:
			if _is_number(item):
				result.append(float(item))
	return result

static func _positive_number(value: Variant) -> Variant:
	return float(value) if _is_number(value) and float(value) > 0.0 else null

static func _number_or_null(value: Variant) -> Variant:
	return float(value) if _is_number(value) else null

static func _is_number(value: Variant) -> bool:
	return value is int or value is float

static func _median(values: Array[float]) -> float:
	if values.is_empty():
		return 0.0
	var sorted := values.duplicate()
	sorted.sort()
	var center := sorted.size() / 2
	if sorted.size() % 2 == 1:
		return float(sorted[center])
	return (float(sorted[center - 1]) + float(sorted[center])) * 0.5

static func _all_equal(values: Array[float]) -> bool:
	if values.size() < 2:
		return true
	for index in range(1, values.size()):
		if not is_equal_approx(values[0], values[index]):
			return false
	return true

static func _stable_tags(values: Array) -> Array[String]:
	var present: Dictionary = {}
	for value in values:
		var tag := _canonical_tag(String(value))
		if KNOWN_TAGS.has(tag):
			present[tag] = true
	var result: Array[String] = []
	for tag in TAG_ORDER:
		if present.has(tag):
			result.append(tag)
	return result

static func _format_number(value: Variant) -> String:
	if not _is_number(value):
		return "---"
	var number := float(value)
	return "%.2f" % number if not is_equal_approx(number, round(number)) else str(int(round(number)))

static func _array_text(value: Variant) -> String:
	if not value is Array or (value as Array).is_empty():
		return "---"
	var result: Array[String] = []
	for item in value as Array:
		result.append(str(item))
	return ", ".join(result)

static func _attack_report_text(value: Variant) -> String:
	if not value is Array or (value as Array).is_empty():
		return "---"
	var result: Array[String] = []
	for item in value as Array:
		if item is Dictionary:
			var attack: Dictionary = item as Dictionary
			result.append("%s[%s]" % [String(attack.get("id", "---")), String(attack.get("type", "---"))])
	return ", ".join(result) if not result.is_empty() else "---"

static func _rating_text(value: Variant) -> String:
	if not value is Dictionary:
		return "---"
	var rating := value as Dictionary
	return String(rating.get("label", "---"))

static func _yes_no(value: Variant) -> String:
	return "true" if bool(value) else "false"

static func _read_json(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed if parsed != null else {}
