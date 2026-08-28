class_name CodexPresentationSystem
extends RefCounted

## Read-only models for the codex screen.  Discovery state is supplied by the
## caller; this class never stores it and never reads shop recipe state.

const EnemySystemScript := preload("res://scripts/systems/enemy_system.gd")
const EnemyCodexProfileSystemScript := preload("res://scripts/systems/enemy_codex_profile_system.gd")
const DrawDataSystemScript := preload("res://scripts/systems/draw_data_system.gd")
const EvolutionRecipeGuideSystemScript := preload("res://scripts/systems/evolution_recipe_guide_system.gd")
const WeaponSystemScript := preload("res://scripts/systems/weapon_system.gd")
const GiftSystemScript := preload("res://scripts/systems/gift_system.gd")
const CommentSystemScript := preload("res://scripts/systems/comment_system.gd")
const HardModeSystemScript := preload("res://scripts/systems/hard_mode_system.gd")

const CHARACTER_UNITS_MASTER_PATH := "res://data/character_units.json"
const STAGES: Array[String] = ["zatsudan", "gameplay", "singing", "drawing", "collab", "relay"]
const STAGE_LABELS: Dictionary = {
	"zatsudan": "雑談",
	"gameplay": "ゲーム",
	"singing": "歌",
	"drawing": "お絵かき",
	"collab": "コラボ",
	"relay": "配信リレー"
}
const RECORD_STAGE_IDS: Array[String] = ["zatsudan", "gameplay", "singing", "drawing", "collab"]
const RECORD_STAGE_LABELS: Dictionary = {
	"zatsudan": "雑談",
	"gameplay": "ゲーム実況",
	"singing": "歌",
	"drawing": "お絵かき",
	"collab": "コラボ"
}
const RECORD_DIFFICULTIES: Array[String] = ["normal", "hard", "expert"]
const RECORD_DIFFICULTY_LABELS: Dictionary = {"normal": "NORMAL", "hard": "HARD", "expert": "EXPERT"}
const CODEX_CATEGORY_LABELS: Dictionary = {
	"characters": "キャラクター",
	"weapons": "武器",
	"accessories": "アクセサリ",
	"enemies": "敵",
	"comments": "指示コメ"
}
const FILTERS: Array[String] = ["ALL", "zatsudan", "gameplay", "singing", "drawing", "collab", "SPECIAL"]
const FILTER_LABELS: Array[String] = ["ALL", "雑談", "ゲーム", "歌", "お絵かき", "コラボ", "SPECIAL"]
const SPAWN_TYPES: Array[String] = [
	"normal_wave",
	"genre_race",
	"genre_bullet",
	"genre_bullet_late",
	"genre_horror",
	"fake_gift_destroy",
	"marshmallow_timeout",
	"boss_summon",
	"boss_only",
	"relay_final_boss"
]
const SPECIAL_IDS: Array[String] = [
	"enemy_wrong_way_kart",
	"enemy_jammer_cone",
	"enemy_dot_invader",
	"enemy_bullet_drone",
	"ghost_comment",
	"enemy_noise_ghost_comment",
	"enemy_fake_gift_box",
	"collab_division_noise",
	"collab_mute_core",
	"unread_maro",
	"noise_ghost_comment",
	"last_offline"
]
const BEHAVIOR_TAG_ORDER: Array[String] = EnemyCodexProfileSystemScript.TAG_ORDER
const BEHAVIOR_TAG_LABELS: Dictionary = {
	"contact": "接触",
	"ranged": "遠距離",
	"fast": "高速",
	"tank": "高耐久",
	"bullet": "弾幕",
	"summon": "召喚",
	"special": "特殊"
}
const STAT_META: Dictionary = {
	"damage": {"label": "威力", "kind": "number"},
	"normalDamage": {"label": "通常威力", "kind": "number"},
	"finisherDamage": {"label": "フィニッシャー威力", "kind": "number"},
	"shockwaveDamage": {"label": "衝撃波威力", "kind": "number"},
	"pulseDamage": {"label": "パルス威力", "kind": "number"},
	"initialDamage": {"label": "初撃威力", "kind": "number"},
	"reelDamage": {"label": "巻き取り威力", "kind": "number"},
	"caughtDamage": {"label": "捕獲威力", "kind": "number"},
	"echoDamage": {"label": "追撃威力", "kind": "number"},
	"followupDamage": {"label": "追撃威力", "kind": "number"},
	"finishDamage": {"label": "終了威力", "kind": "number"},
	"tickDamage": {"label": "継続威力", "kind": "number"},
	"attackInterval": {"label": "攻撃間隔", "kind": "seconds"},
	"hitInterval": {"label": "命中間隔", "kind": "seconds"},
	"summonInterval": {"label": "召喚間隔", "kind": "seconds"},
	"range": {"label": "射程", "kind": "distance"},
	"shockwaveRange": {"label": "衝撃波射程", "kind": "distance"},
	"shockwaveWidth": {"label": "衝撃波幅", "kind": "distance"},
	"orbitRadius": {"label": "回転半径", "kind": "distance"},
	"orbitSpeed": {"label": "回転速度", "kind": "number"},
	"pulseOrbitRadius": {"label": "パルス回転半径", "kind": "distance"},
	"pulseExpPullRadius": {"label": "経験値吸引範囲", "kind": "distance"},
	"radius": {"label": "範囲", "kind": "distance"},
	"pulseRadius": {"label": "パルス範囲", "kind": "distance"},
	"fanRadius": {"label": "扇形範囲", "kind": "distance"},
	"fanWaveRadius": {"label": "扇形波範囲", "kind": "distance"},
	"finisherRange": {"label": "フィニッシャー射程", "kind": "distance"},
	"gatherRadius": {"label": "吸引範囲", "kind": "distance"},
	"searchRange": {"label": "索敵範囲", "kind": "distance"},
	"explosionRadius": {"label": "爆発範囲", "kind": "distance"},
	"chainRadius": {"label": "連鎖範囲", "kind": "distance"},
	"width": {"label": "幅", "kind": "distance"},
	"projectileSpeed": {"label": "弾速", "kind": "number"},
	"moveSpeed": {"label": "移動速度", "kind": "number"},
	"sizeMultiplier": {"label": "サイズ", "kind": "multiplier"},
	"chainDamageCoefficient": {"label": "連鎖倍率", "kind": "multiplier"},
	"echoDamageCoefficient": {"label": "追撃倍率", "kind": "multiplier"},
	"explosionDamageCoefficient": {"label": "爆発倍率", "kind": "multiplier"},
	"bossReelCoefficient": {"label": "ボス巻き取り倍率", "kind": "multiplier"},
	"normalDamageCoefficient": {"label": "通常倍率", "kind": "multiplier"},
	"finisherDamageCoefficient": {"label": "フィニッシャー倍率", "kind": "multiplier"},
	"premiumDamage": {"label": "プレミア弾威力", "kind": "number"},
	"premiumExplosionDamage": {"label": "プレミア爆発威力", "kind": "number"},
	"premiumExplosionRadius": {"label": "プレミア爆発範囲", "kind": "distance"},
	"duration": {"label": "持続時間", "kind": "seconds"},
	"pulseDuration": {"label": "パルス持続", "kind": "seconds"},
	"pulseInterval": {"label": "パルス間隔", "kind": "seconds"},
	"slowDuration": {"label": "減速時間", "kind": "seconds"},
	"slowRate": {"label": "減速倍率", "kind": "multiplier"},
	"activeDuration": {"label": "展開時間", "kind": "seconds"},
	"stunDuration": {"label": "スタン時間", "kind": "seconds"},
	"largeStunDuration": {"label": "大型スタン時間", "kind": "seconds"},
	"followupDelay": {"label": "追撃遅延", "kind": "seconds"},
	"gatherDuration": {"label": "吸引持続", "kind": "seconds"},
	"hitRadius": {"label": "命中半径", "kind": "distance"},
	"projectileCount": {"label": "弾数", "kind": "count", "unit": "発"},
	"boomerangCount": {"label": "回転数", "kind": "count", "unit": "個"},
	"mineCount": {"label": "設置数", "kind": "count", "unit": "個"},
	"maxActiveCount": {"label": "同時上限", "kind": "count", "unit": "個"},
	"laserCount": {"label": "レーザー数", "kind": "count", "unit": "本"},
	"summonCount": {"label": "召喚数", "kind": "count", "unit": "体"},
	"gatherMaxTargets": {"label": "吸引対象数", "kind": "count", "unit": "体"},
	"maxActiveCasts": {"label": "同時発動上限", "kind": "count", "unit": "回"},
	"maxTicks": {"label": "最大継続回数", "kind": "count", "unit": "回"},
	"bounceCount": {"label": "反射回数", "kind": "count", "unit": "回"},
	"premiumEvery": {"label": "プレミア周期", "kind": "count", "unit": "発"},
	"pierce": {"label": "貫通数", "kind": "count", "unit": "体"},
	"arcAngle": {"label": "攻撃角度", "kind": "degrees"},
	"arcDegrees": {"label": "展開角度", "kind": "degrees"},
	"shieldDurability": {"label": "耐久", "kind": "number"},
	"blockEnemyProjectiles": {"label": "敵弾ブロック", "kind": "bool"},
	"damageMultiplier": {"label": "攻撃倍率", "kind": "multiplier"},
	"projectileCountBonus": {"label": "弾数・生成数", "kind": "count", "unit": "発"},
	"attackIntervalMultiplier": {"label": "攻撃間隔倍率", "kind": "multiplier"},
	"rangeAreaMultiplier": {"label": "範囲・射程倍率", "kind": "multiplier"},
	"moveSpeedMultiplier": {"label": "移動速度倍率", "kind": "multiplier"},
	"dashCooldownMultiplier": {"label": "ダッシュCT倍率", "kind": "multiplier"},
	"goodEffectMultiplier": {"label": "メリット効果倍率", "kind": "multiplier"},
	"kusoDurationMultiplier": {"label": "クソマロ持続倍率", "kind": "multiplier"},
	"maxHpBonus": {"label": "最大HP", "kind": "number", "suffix": "増加"},
	"expMultiplier": {"label": "獲得EXP倍率", "kind": "multiplier"},
	"pickupRangeBonus": {"label": "回収範囲", "kind": "distance", "suffix": "増加"},
	"pickupSpeedMultiplier": {"label": "回収速度倍率", "kind": "multiplier"},
	"healInterval": {"label": "回復間隔", "kind": "seconds"},
	"healAmount": {"label": "回復量", "kind": "number"}
}
const COMMENT_PARAM_META: Dictionary = {
	"rangeRate": "射程倍率",
	"areaRate": "範囲倍率",
	"searchRate": "索敵倍率",
	"explosionAreaRate": "爆発範囲倍率",
	"playerMoveSpeedMultiplier": "プレイヤー移動速度倍率",
	"enemyMoveSpeedMultiplier": "敵移動速度倍率",
	"enemySpawnMultiplier": "敵出現倍率",
	"noteLifetimeMultiplier": "ノート持続倍率",
	"forcedChorusDuration": "強制サビ時間",
	"forcedChorusEnemySpawnMultiplier": "サビ敵出現倍率",
	"forcedChorusNoteCountMultiplier": "サビノート数倍率",
	"emitterCount": "発生源数",
	"waveInterval": "波の間隔",
	"telegraphDuration": "予告時間",
	"waveExpandDuration": "波の拡大時間",
	"waveStartRadius": "開始範囲",
	"waveEndRadius": "終了範囲",
	"damage": "威力",
	"knockback": "ノックバック",
	"badLightCount": "悪い照明数",
	"badLightRadius": "悪い照明範囲",
	"badLightLifetime": "悪い照明持続",
	"badLightRespawnDelay": "再出現遅延",
	"trailLifetime": "線の持続時間",
	"trailWidthMultiplier": "線幅倍率",
	"paintCostMultiplier": "絵の具消費倍率",
	"grayPaintRate": "灰色絵の具率",
	"correctionBurst": "修正数",
	"correctionRewardMultiplier": "修正報酬倍率",
	"spillCount": "汚れ数",
	"playerWeaponDamageMultiplier": "プレイヤー攻撃倍率",
	"partnerDamageMultiplier": "相方攻撃倍率",
	"partnerAttackIntervalMultiplier": "相方攻撃間隔倍率",
	"starLossCooldown": "星減少CT",
	"moveSpeedMultiplier": "移動速度倍率",
	"slowDuration": "減速時間",
	"warningDuration": "警告時間",
	"projectileGraceDuration": "弾の猶予時間",
	"passDuration": "パス時間",
	"bossHpRate": "ボスHP倍率",
	"bossAttackIntervalRate": "ボス攻撃間隔倍率",
	"bossRewardRate": "ボス報酬倍率",
	"attackIntervalRate": "攻撃間隔倍率",
	"projectileSpeedRate": "弾速倍率",
	"countRate": "出現数倍率",
	"maxDelay": "最大遅延",
	"commentCount": "コメント数",
	"eventDuration": "イベント時間",
	"travelDuration": "移動時間",
	"spawnInterval": "出現間隔",
	"laneCount": "レーン数",
	"pushRate": "押し出し倍率",
	"knockbackSpeed": "ノックバック速度",
	"knockbackDuration": "ノックバック時間",
	"moveRate": "移動倍率",
	"rehitInterval": "再命中間隔",
	"transitionSeconds": "切替時間",
	"eventDurationRate": "イベント時間倍率",
	"eventSpawnRate": "イベント出現倍率"
}

static func filter_ids() -> Array[String]:
	return FILTERS.duplicate()

static func filter_labels() -> Array[String]:
	return FILTER_LABELS.duplicate()

static func normalize_stage_id(value: Variant) -> String:
	var raw := String(value).strip_edges().to_lower()
	if raw == "":
		return ""
	if raw in ["chat", "talk", "zatsudan"]:
		return "zatsudan"
	if raw in ["game", "gameplay"] or raw.begins_with("gameplay_"):
		return "gameplay"
	if raw in ["song", "singing"]:
		return "singing"
	if raw == "drawing" or raw.begins_with("drawing_"):
		return "drawing"
	if raw == "collab" or raw.begins_with("collab_"):
		return "collab"
	if raw == "relay" or raw.begins_with("relay_"):
		return "relay"
	return ""

static func stage_label(value: Variant) -> String:
	var normalized := normalize_stage_id(value)
	return String(STAGE_LABELS.get(normalized, "---"))

static func stage_ids(master: Dictionary) -> Array[String]:
	var result: Array[String] = []
	var raw_stages: Variant = master.get("codexStages", [])
	if raw_stages is Array:
		for raw_stage in raw_stages as Array:
			var stage := normalize_stage_id(raw_stage)
			if stage != "" and not result.has(stage):
				result.append(stage)
	if not result.is_empty():
		return result
	# v0.1 masters used spawnFrames.  Keep that format safe as a read-only
	# compatibility fallback while the new filters use normalized IDs.
	var raw_frames: Variant = master.get("spawnFrames", [])
	if raw_frames is Array:
		for raw_frame in raw_frames as Array:
			var frame_stage := normalize_stage_id(raw_frame)
			if frame_stage != "" and not result.has(frame_stage):
				result.append(frame_stage)
	return result

static func stage_labels(master: Dictionary, sources: Dictionary = {}) -> Array[String]:
	var result: Array[String] = []
	for stage in stage_ids_for_display(master, sources):
		result.append(stage_label(stage))
	return result

static func stage_ids_for_display(master: Dictionary, sources: Dictionary = {}) -> Array[String]:
	if not bool(master.get("isBoss", false)):
		return stage_ids(master)
	var result: Array[String] = []
	var id := String(master.get("id", ""))
	var bosses: Variant = sources.get("bosses", [])
	if bosses is Array:
		for boss_value in bosses as Array:
			if boss_value is Dictionary and String((boss_value as Dictionary).get("id", "")) == id:
				var boss_stage := normalize_stage_id((boss_value as Dictionary).get("stageId", ""))
				if boss_stage != "":
					result.append(boss_stage)
	var difficulty_data: Variant = sources.get("difficultyModes", {})
	var hard_config := _hard_config(difficulty_data)
	var boss_ids: Variant = hard_config.get("boss", {}).get("bossIds", {}) if hard_config.get("boss", {}) is Dictionary else {}
	if boss_ids is Dictionary:
		for stage_key in (boss_ids as Dictionary).keys():
			if String((boss_ids as Dictionary)[stage_key]) == id:
				var hard_stage := normalize_stage_id(stage_key)
				if hard_stage != "" and not result.has(hard_stage):
					result.append(hard_stage)
	var relay_mode: Variant = sources.get("relayMode", {})
	if relay_mode is Dictionary and String((relay_mode as Dictionary).get("boss", {}).get("id", "")) == id:
		result.append("relay")
	if result.is_empty():
		return stage_ids(master)
	return _unique_strings(result)

static func spawn_types(master: Dictionary) -> Array[String]:
	var result: Array[String] = []
	var raw_types: Variant = master.get("codexSpawnTypes", [])
	if raw_types is Array:
		for raw_type in raw_types as Array:
			var spawn_type := String(raw_type).strip_edges()
			if SPAWN_TYPES.has(spawn_type) and not result.has(spawn_type):
				result.append(spawn_type)
	return result

static func enemy_filter_matches(master: Dictionary, filter_id: String) -> bool:
	var normalized_filter := filter_id.strip_edges()
	if normalized_filter == "" or normalized_filter == "ALL":
		return true
	if normalized_filter == "SPECIAL":
		return bool(master.get("codexSpecial", false))
	var stage := normalize_stage_id(normalized_filter)
	return stage != "" and stage_ids(master).has(stage)

static func filtered_entries(entries: Array, filter_id: String) -> Array:
	var result: Array = []
	for item in entries:
		if not item is Dictionary:
			continue
		if enemy_filter_matches(item as Dictionary, filter_id):
			result.append((item as Dictionary).duplicate(true))
	return result

static func load_sources() -> Dictionary:
	var sources := {
		"difficultyModes": _read_json("res://data/difficulty_modes.json"),
		"bosses": _read_json("res://data/bosses.json"),
		"relayMode": _read_json("res://data/relay_mode.json"),
		"characterUnits": _read_json(CHARACTER_UNITS_MASTER_PATH)
	}
	var enemy_master: Variant = _read_json("res://data/codex_enemies.json")
	if enemy_master is Array:
		sources["enemyProfileCatalog"] = EnemyCodexProfileSystemScript.build_catalog(enemy_master as Array, sources)
	return sources

static func canonical_enemy_display_name(master: Dictionary, sources: Dictionary = {}) -> String:
	return EnemyCodexProfileSystemScript.canonical_display_name(master, sources)

static func build_enemy_model(master: Dictionary, discovered: bool, entry: Dictionary = {}, sources: Dictionary = {}) -> Dictionary:
	var id := String(master.get("id", "")).strip_edges()
	var types := spawn_types(master) if discovered else []
	var stages := stage_ids_for_display(master, sources) if discovered else []
	var hint_lines: Array = enemy_hint_lines(master)
	var conditions: Array = enemy_condition_lines(master, sources) if discovered else []
	var kind := enemy_kind(master) if discovered else ""
	var codex_text := enemy_codex_text(master) if discovered else {"description": "", "strategy": "", "flavor": ""}
	var lore_model := enemy_lore_model(master, discovered)
	var profile: Dictionary = {}
	var profile_catalog: Dictionary = sources.get("enemyProfileCatalog", {}) as Dictionary
	var profile_by_id: Dictionary = profile_catalog.get("byId", {}) as Dictionary
	if discovered and profile_by_id.has(id) and profile_by_id.get(id) is Dictionary:
		profile = (profile_by_id.get(id) as Dictionary).duplicate(true)
	var canonical_name := String(profile.get("canonicalDisplayName", "")).strip_edges()
	if canonical_name == "":
		canonical_name = canonical_enemy_display_name(master, sources)
	var related_ids: Array = []
	if discovered:
		related_ids = _string_array(master.get("relatedEnemyIds", []))
	var model := {
		"id": id,
		"displayName": canonical_name if discovered else "？？？",
		"description": String(master.get("description", "")) if discovered else "",
		"imagePath": image_path_for_enemy(id) if discovered else "",
		"stageIds": stages,
		"stageLabels": stage_labels(master, sources) if discovered else [],
		"spawnTypes": types,
		"badges": (lore_model.get("classificationBadges", []) as Array).duplicate(true) if discovered else [],
		"conditions": conditions,
		"killCount": maxi(0, int(entry.get("kill_count", 0))) if discovered else 0,
		"defeated": (entry.get("defeated", {}) as Dictionary).duplicate(true) if discovered and entry.get("defeated", {}) is Dictionary else {},
		"relatedEnemyIds": related_ids,
		"discovered": discovered
	}
	model["kind"] = kind
	model["titleTag"] = "SPECIAL BOSS" if kind == "specialBoss" else ("BOSS" if kind == "boss" else "")
	model["description"] = codex_text.get("description", "") if discovered else ""
	model["strategy"] = codex_text.get("strategy", "") if discovered else ""
	model["flavor"] = codex_text.get("flavor", "") if discovered else ""
	model["enemyProfile"] = profile.duplicate(true)
	model["primaryTag"] = String(profile.get("primaryTag", "")) if discovered else ""
	model["detailTags"] = (profile.get("detailTags", []) as Array).duplicate(true) if discovered else []
	model["attackTypeLabels"] = _attack_type_labels(profile.get("attackTypes", []) as Array) if discovered else []
	model["mainAttacks"] = (profile.get("mainAttacks", []) as Array).duplicate(true) if discovered else []
	model["attackLines"] = _profile_attack_lines(profile) if discovered else []
	model["summonIds"] = _string_array(profile.get("summonIds", [])) if discovered else []
	model["specialEffects"] = _string_array(profile.get("specialEffects", [])) if discovered else []
	model["durabilityRating"] = (profile.get("durabilityRating", {}) as Dictionary).duplicate(true) if discovered else {}
	model["speedRating"] = (profile.get("speedRating", {}) as Dictionary).duplicate(true) if discovered else {}
	model["behaviorTagRows"] = enemy_behavior_tag_rows(master, profile) if discovered else []
	model["conditionLines"] = conditions
	model["hintLines"] = hint_lines
	model["loreTemplate"] = String(lore_model.get("template", "")) if discovered else ""
	model["cards"] = (lore_model.get("cards", []) as Array).duplicate(true) if discovered else []
	model["loreCards"] = (lore_model.get("cards", []) as Array).duplicate(true) if discovered else []
	model["archiveTitle"] = String(lore_model.get("archiveTitle", "")) if discovered else ""
	model["archiveParagraphs"] = (lore_model.get("archiveParagraphs", []) as Array).duplicate(true) if discovered else []
	model["hasLore"] = bool(lore_model.get("hasLore", false)) if discovered else false
	model["classificationBadges"] = (lore_model.get("classificationBadges", []) as Array).duplicate(true) if discovered else []
	model["classificationLabel"] = String(lore_model.get("classificationLabel", "")) if discovered else ""
	model["codexVisual"] = (lore_model.get("codexVisual", {}) as Dictionary).duplicate(true) if discovered else {}
	return model

static func enemy_lore_model(master: Dictionary, discovered: bool = true) -> Dictionary:
	var result := {
		"id": String(master.get("id", "")).strip_edges(),
		"template": "",
		"cards": [],
		"loreCards": [],
		"archiveTitle": "",
		"archiveParagraphs": [],
		"classificationBadges": [],
		"classificationLabel": "",
		"codexVisual": {},
		"imagePath": "",
		"hasLore": false
	}
	if not discovered or String(result.get("id", "")) == "":
		return result
	var lore_value: Variant = master.get("codexLore", master.get("codex_lore", {}))
	if not lore_value is Dictionary:
		return result
	var lore := lore_value as Dictionary
	var template := String(lore.get("template", "")).strip_edges()
	if not ["normal_enemy", "special", "boss"].has(template):
		template = "boss" if bool(master.get("isBoss", false)) or bool(master.get("relayBoss", false)) else ("special" if bool(master.get("codexSpecial", false)) else "normal_enemy")
	var normalized_cards: Array = []
	var raw_cards: Variant = lore.get("cards", [])
	if raw_cards is Array:
		for raw_value in raw_cards as Array:
			if not raw_value is Dictionary:
				continue
			var raw_card := raw_value as Dictionary
			var card_id := String(raw_card.get("id", "")).strip_edges()
			var title := String(raw_card.get("title", "")).strip_edges()
			var text := String(raw_card.get("text", "")).strip_edges()
			if card_id == "" or title == "" or text == "":
				continue
			var raw_span: Variant = raw_card.get("span", 1)
			var span := 2 if (raw_span is int or raw_span is float) and int(raw_span) == 2 else 1
			normalized_cards.append({"id": card_id, "title": title, "text": text, "span": span})
	var paragraphs: Array[String] = []
	var raw_paragraphs: Variant = lore.get("archiveParagraphs", lore.get("archive_paragraphs", []))
	if raw_paragraphs is Array:
		for raw_paragraph in raw_paragraphs as Array:
			if raw_paragraph is String and String(raw_paragraph).strip_edges() != "":
				paragraphs.append(String(raw_paragraph).strip_edges())
	var badges := enemy_classification_badges(master)
	var badge_label_parts: Array[String] = []
	for badge in badges:
		badge_label_parts.append(String(badge))
	result["template"] = template
	result["cards"] = normalized_cards
	result["loreCards"] = normalized_cards.duplicate(true)
	result["archiveTitle"] = String(lore.get("archiveTitle", lore.get("archive_title", ""))).strip_edges()
	result["archiveParagraphs"] = paragraphs
	result["classificationBadges"] = badges
	result["classificationLabel"] = " / ".join(badge_label_parts)
	var visual_value: Variant = lore.get("codexVisual", lore.get("codex_visual", {}))
	result["codexVisual"] = {"scale": 1.0, "offsetX": 0.0, "offsetY": 0.0}
	if visual_value is Dictionary:
		var visual := visual_value as Dictionary
		var raw_scale: Variant = visual.get("scale", 1.0)
		var raw_offset_x: Variant = visual.get("offsetX", visual.get("offset_x", 0.0))
		var raw_offset_y: Variant = visual.get("offsetY", visual.get("offset_y", 0.0))
		var visual_scale := float(raw_scale) if raw_scale is int or raw_scale is float else 1.0
		var visual_offset_x := float(raw_offset_x) if raw_offset_x is int or raw_offset_x is float else 0.0
		var visual_offset_y := float(raw_offset_y) if raw_offset_y is int or raw_offset_y is float else 0.0
		if is_finite(visual_scale):
			visual_scale = clampf(visual_scale, 0.5, 2.5)
		else:
			visual_scale = 1.0
		if not is_finite(visual_offset_x):
			visual_offset_x = 0.0
		if not is_finite(visual_offset_y):
			visual_offset_y = 0.0
		result["codexVisual"] = {"scale": visual_scale, "offsetX": clampf(visual_offset_x, -1.0, 1.0), "offsetY": clampf(visual_offset_y, -1.0, 1.0)}
	result["imagePath"] = image_path_for_enemy(String(result.get("id", "")))
	result["hasLore"] = not normalized_cards.is_empty() or not paragraphs.is_empty()
	return result

static func enemy_classification_badges(master: Dictionary) -> Array[String]:
	var badges: Array[String] = []
	var id := String(master.get("id", "")).strip_edges()
	if bool(master.get("relayBoss", false)) or id == "last_offline":
		badges.append("SPECIAL BOSS")
	elif bool(master.get("isBoss", false)):
		badges.append("BOSS")
	elif bool(master.get("codexSpecial", false)):
		badges.append("SPECIAL")
	else:
		badges.append("EVENT" if _has_event_spawn_type(master) else "NORMAL")
	if badges.size() < 3 and not badges.has("SPECIAL BOSS") and not badges.has("BOSS") and _has_event_spawn_type(master) and not badges.has("EVENT"):
		badges.append("EVENT")
	return badges

static func _attack_type_labels(values: Array) -> Array[String]:
	var labels := {
		"contact": "接触",
		"ranged": "遠距離",
		"projectile": "飛び道具",
		"charge": "突進",
		"summon": "召喚",
		"area": "範囲攻撃",
		"special": "特殊"
	}
	var result: Array[String] = []
	for value in values:
		var label := String(labels.get(String(value), ""))
		if label != "" and not result.has(label):
			result.append(label)
	return result

static func enemy_tag_label(tag: String) -> String:
	return EnemyCodexProfileSystemScript.tag_label(tag)

static func _profile_attack_lines(profile: Dictionary) -> Array[String]:
	var result: Array[String] = []
	var main_attacks: Array = profile.get("mainAttacks", []) as Array
	if not main_attacks.is_empty():
		for value in main_attacks:
			if value is Dictionary:
				var attack := value as Dictionary
				var label := String(attack.get("label", attack.get("displayName", attack.get("id", ""))))
				if label != "":
					result.append(label)
			elif String(value) != "":
				result.append(String(value))
	if result.is_empty():
		for value in profile.get("attacks", []) as Array:
			if value is Dictionary:
				var attack := value as Dictionary
				var label := String(attack.get("displayName", attack.get("id", "")))
				if label != "" and not result.has(label):
					result.append(label)
	return result

static func enemy_kind(master: Dictionary) -> String:
	if bool(master.get("relayBoss", false)):
		return "specialBoss"
	if bool(master.get("isBoss", false)):
		return "boss"
	return "normal"

static func enemy_codex_text(master: Dictionary) -> Dictionary:
	var result := {"description": "", "strategy": "", "flavor": ""}
	var codex_value: Variant = master.get("codex", {})
	if codex_value is Dictionary:
		for key in result.keys():
			var value: Variant = (codex_value as Dictionary).get(key, "")
			if value is String:
				result[key] = String(value).strip_edges()
	# v0.1-v0.4 compatibility for masters that still have the old field.
	if String(result.get("description", "")) == "":
		var legacy_description: Variant = master.get("description", "")
		if legacy_description is String:
			result["description"] = String(legacy_description).strip_edges()
	return result

static func enemy_behavior_tag_rows(master: Dictionary, profile: Dictionary = {}) -> Array[Dictionary]:
	var present: Dictionary = {}
	var value: Variant = profile.get("resolvedTags", null)
	if not value is Array:
		var codex_value: Variant = master.get("codex", {})
		if codex_value is Dictionary:
			value = (codex_value as Dictionary).get("behaviorTags", null)
			if not value is Array or (value as Array).is_empty():
				value = master.get("behaviorTags", [])
		else:
			value = master.get("behaviorTags", [])
	if value is Array:
		for raw_tag in value as Array:
			var tag := String(raw_tag)
			present["projectile" if tag == "bullet" else tag] = true
	var rows: Array[Dictionary] = []
	for tag in EnemyCodexProfileSystemScript.TAG_ORDER:
		if present.has(tag):
			rows.append({"key": tag, "label": EnemyCodexProfileSystemScript.tag_label(tag)})
	return rows

static func undiscovered_hint(category: String, master: Dictionary = {}) -> Array[String]:
	var result: Array[String] = []
	for value in _undiscovered_hint_raw(category, master):
		if value is String:
			result.append(String(value))
	return result

static func _undiscovered_hint_raw(category: String, master: Dictionary = {}) -> Array:
	match category:
		"characters": return ["未発見のキャラクター"]
		"weapons":
			return ["進化によって入手"] if bool(master.get("isEvolved", false)) else ["未発見の武器"]
		"accessories": return ["未発見のアクセサリ"]
		"enemies": return enemy_hint_lines(master)
		"comments": return ["未発見の指示コメ"]
	return ["まだ発見していません"]

static func enemy_badges(master: Dictionary) -> Array[String]:
	return enemy_classification_badges(master)

static func enemy_condition_lines(master: Dictionary, sources: Dictionary = {}) -> Array[String]:
	var result: Array[String] = []
	var id := String(master.get("id", ""))
	var normal: Dictionary = EnemySystemScript.codex_normal_spawn_conditions(id)
	var starts: Dictionary = normal.get("startSeconds", {}) as Dictionary
	for stage_value in normal.get("stages", []) as Array:
		var stage := normalize_stage_id(stage_value)
		if stage == "":
			continue
		var start := float(starts.get(stage, 0.0))
		result.append("%s：配信開始%.0f秒から" % [stage_label(stage), start])
	for spawn_type in spawn_types(master):
		var line := _spawn_type_condition(spawn_type, master, sources)
		if line != "" and not result.has(line):
			result.append(line)
	for hard_line in hard_wave_condition_lines(id, sources.get("difficultyModes", {})):
		if not result.has(hard_line):
			result.append(hard_line)
	if result.is_empty():
		result.append("出現条件：---")
	return result

static func enemy_hint_lines(master: Dictionary) -> Array[String]:
	var result: Array[String] = []
	var id := String(master.get("id", "")).strip_edges()
	if bool(master.get("relayBoss", false)) or id == "last_offline":
		result.append("配信リレー")
	elif bool(master.get("isBoss", false)):
		result.append("ボス戦")
	elif bool(master.get("codexSpecial", false)):
		var types := spawn_types(master)
		if types.has("genre_race") or types.has("genre_bullet") or types.has("genre_horror") or types.has("genre_drawing") or types.has("genre_collab"):
			result.append("特定のイベント")
		else:
			result.append("特別な配信")
	else:
		result.append("通常の配信中")
	if result.is_empty():
		result.append("まだ発見されていません")
	return result

static func hard_wave_condition_lines(enemy_id: String, difficulty_data: Variant) -> Array[String]:
	var result: Array[String] = []
	var hard_config := _hard_config(difficulty_data)
	var waves: Variant = hard_config.get("hardWaves", [])
	if waves is Array:
		for wave_value in waves as Array:
			if not wave_value is Dictionary:
				continue
			var wave: Dictionary = wave_value as Dictionary
			for group_value in wave.get("groups", []) as Array:
				if not group_value is Dictionary or String((group_value as Dictionary).get("enemyId", "")) != enemy_id:
					continue
				var stage := normalize_stage_id(wave.get("stageId", ""))
				if stage != "":
					result.append("HARD追加ウェーブ：%s、%.0f秒以降" % [stage_label(stage), float(wave.get("minElapsedSeconds", 0.0))])
	var profiles: Variant = hard_config.get("pressureWaveProfiles", {})
	if profiles is Dictionary:
		for stage_key in (profiles as Dictionary).keys():
			var profile: Variant = (profiles as Dictionary)[stage_key]
			if not profile is Dictionary:
				continue
			for group_value in (profile as Dictionary).get("groups", []) as Array:
				if group_value is Dictionary and String((group_value as Dictionary).get("enemyId", "")) == enemy_id:
					var stage := normalize_stage_id(stage_key)
					if stage != "":
						result.append("HARD圧力ウェーブ：%s" % stage_label(stage))
	return _unique_strings(result)
	return result

static func evolution_catalog(weapons: Array, gifts: Array = [], discovered_ids: Array = []) -> Array:
	var definitions: Dictionary = {}
	for item in weapons:
		if not item is Dictionary:
			continue
		var weapon: Dictionary = item as Dictionary
		var id := String(weapon.get("id", "")).strip_edges()
		if id != "" and bool(weapon.get("codexEnabled", true)):
			definitions[id] = weapon
	var discovered := _string_array(discovered_ids)
	var result: Array = []
	var seen: Dictionary = {}
	for neutral_value in EvolutionRecipeGuideSystemScript.build_codex_catalog(weapons, gifts):
		if not neutral_value is Dictionary:
			continue
		var neutral: Dictionary = neutral_value as Dictionary
		var base_id := String(neutral.get("baseWeaponId", "")).strip_edges()
		var evolved_id := String(neutral.get("evolvedWeaponId", "")).strip_edges()
		var base := _find_by_id(weapons, base_id)
		if evolved_id == "" or seen.has(evolved_id) or not definitions.has(evolved_id):
			continue
		var evolved: Dictionary = definitions[evolved_id] as Dictionary
		seen[evolved_id] = true
		var model := {
			"baseWeaponId": base_id,
			"baseDisplayName": _display_name(base),
			"evolvedWeaponId": evolved_id,
			"evolvedDisplayName": _display_name(evolved) if discovered.has(evolved_id) else "？？？？？",
			"evolvedDisplayNameRaw": _display_name(evolved),
			"requiredWeaponLevel": int(neutral.get("requiredWeaponLevel", 1)),
			"requiredCharacterId": String(neutral.get("requiredCharacterId", "")),
			"matchingCharacterBypassesAdditionalRequirements": bool(neutral.get("matchingCharacterBypassesAdditionalRequirements", false)),
			"additionalRequirements": (neutral.get("additionalRequirements", []) as Array).duplicate(true) if neutral.get("additionalRequirements", []) is Array else [],
			"evolvedDiscovered": discovered.has(evolved_id)
		}
		model["selfRequirements"] = _requirement_labels(model, weapons, gifts, true)
		model["otherRequirements"] = _requirement_labels(model, weapons, gifts, false)
		result.append(model)
	return result

static func accessory_reverse_guides(weapons: Array, gifts: Array = [], discovered_ids: Array = []) -> Array:
	var guides: Array = []
	var discovered := _string_array(discovered_ids)
	for recipe_value in evolution_catalog(weapons, gifts, discovered_ids):
		var recipe: Dictionary = recipe_value as Dictionary
		for requirement_value in recipe.get("additionalRequirements", []) as Array:
			if not requirement_value is Dictionary:
				continue
			var requirement: Dictionary = requirement_value as Dictionary
			if String(requirement.get("type", "")) != "accessory":
				continue
			var accessory_id := String(requirement.get("id", ""))
			var accessory_name := _definition_name(gifts, accessory_id)
			guides.append({
				"accessoryId": accessory_id,
				"accessoryDisplayName": accessory_name,
				"baseWeaponId": recipe.get("baseWeaponId", ""),
				"baseDisplayName": recipe.get("baseDisplayName", "") if discovered.has(String(recipe.get("baseWeaponId", ""))) else "？？？",
				"baseDiscovered": discovered.has(String(recipe.get("baseWeaponId", ""))),
				"evolvedWeaponId": recipe.get("evolvedWeaponId", ""),
				"evolvedDisplayName": recipe.get("evolvedDisplayName", "") if bool(recipe.get("evolvedDiscovered", false)) else "？？？？？",
				"evolvedDiscovered": bool(recipe.get("evolvedDiscovered", false)),
				"requiredLevel": requirement.get("requiredLevel", 1),
				"matchingCharacterBypassesAdditionalRequirements": bool(recipe.get("matchingCharacterBypassesAdditionalRequirements", false)),
				"requiredCharacterId": recipe.get("requiredCharacterId", "")
			})
	return guides

static func character_model(character: Dictionary, weapons: Array, discovered_ids: Array = [], discovered: bool = true) -> Dictionary:
	var initial_id := String(character.get("initialWeapon", ""))
	var initial := _find_by_id(weapons, initial_id)
	var recipes := evolution_catalog(weapons, [], discovered_ids)
	var evolved_name := "進化なし"
	for recipe_value in recipes:
		var recipe: Dictionary = recipe_value as Dictionary
		if String(recipe.get("baseWeaponId", "")) != initial_id:
			continue
		evolved_name = String(recipe.get("evolvedDisplayName", "")) if bool(recipe.get("evolvedDiscovered", false)) else "？？？？？"
		break
	return {
		"id": String(character.get("id", "")),
		"displayName": _display_name(character) if discovered else "？？？",
		"description": character_profile_description(character) if discovered else "",
		"type": String(character.get("codexType", "")).strip_edges(),
		"initialWeaponId": initial_id,
		"initialWeaponName": _display_name(initial) if not initial.is_empty() else "",
		"initialEvolutionName": evolved_name,
		"imagePath": image_path_for_character(character) if discovered else "",
		"discovered": discovered
	}

static func character_profile_description(character: Dictionary) -> String:
	var profile_value: Variant = character.get("codexProfile", {})
	if profile_value is Dictionary:
		var profile_description := String((profile_value as Dictionary).get("description", "")).strip_edges()
		if profile_description != "":
			return profile_description
	return String(character.get("description", "")).strip_edges()

static func character_profile_model(character: Dictionary, weapons: Array, discovered_ids: Array = [], discovered: bool = true, sources: Dictionary = {}) -> Dictionary:
	var model := character_model(character, weapons, discovered_ids, discovered)
	model["description"] = character_profile_description(character) if discovered else ""
	model["unitId"] = ""
	model["unit"] = {}
	model["unitDisplayName"] = ""
	model["unitDescription"] = ""
	model["streamStyle"] = ""
	model["likes"] = []
	model["dislikes"] = []
	model["likesText"] = ""
	model["dislikesText"] = ""
	if not discovered:
		return model
	var resolved_sources := sources if not sources.is_empty() else load_sources()
	var unit_id := String(character.get("unitId", "")).strip_edges()
	var unit := _character_unit_model(unit_id, resolved_sources)
	model["unitId"] = unit_id
	model["unit"] = unit.duplicate(true)
	model["unitDisplayName"] = String(unit.get("displayName", "")).strip_edges()
	model["unitDescription"] = String(unit.get("description", "")).strip_edges()
	var profile_value: Variant = character.get("codexProfile", {})
	if profile_value is Dictionary:
		var profile: Dictionary = profile_value as Dictionary
		model["streamStyle"] = _profile_string(profile.get("streamStyle", ""))
		model["likes"] = _profile_string_array(profile.get("likes", []))
		model["dislikes"] = _profile_string_array(profile.get("dislikes", []))
		model["likesText"] = _profile_list_text(model["likes"] as Array)
		model["dislikesText"] = _profile_list_text(model["dislikes"] as Array)
	return model

## World-building model for weapon and accessory detail pages.  Lore is read
## from the master only; classification and evolution names are derived from
## the existing weapon/character relationships so they cannot drift from game
## data.
static func item_lore_model(master: Dictionary, category: String, discovered: bool = true, weapons: Array = [], characters: Array = []) -> Dictionary:
	var item_id := String(master.get("id", "")).strip_edges()
	var result := {
		"id": item_id,
		"category": category,
		"classificationLabel": "",
		"classificationKey": "",
		"archiveTitle": "",
		"archiveParagraphs": [],
		"cards": [],
		"imagePath": "",
		"hasLore": false
	}
	if not discovered or item_id == "":
		return result
	var classification := _item_classification(master, category, weapons, characters)
	result["classificationLabel"] = String(classification.get("label", ""))
	result["classificationKey"] = String(classification.get("key", ""))
	result["imagePath"] = image_path_for(category, master, true)
	var lore_value: Variant = master.get("codexLore", master.get("codex_lore", {}))
	if not lore_value is Dictionary:
		return result
	var lore := lore_value as Dictionary
	var cards: Array = []
	var raw_cards: Variant = lore.get("cards", [])
	if raw_cards is Array:
		for card_value in raw_cards as Array:
			if not card_value is Dictionary:
				continue
			var raw_card := card_value as Dictionary
			var card_id := String(raw_card.get("id", "")).strip_edges()
			var title := String(raw_card.get("title", "")).strip_edges()
			var text := String(raw_card.get("text", "")).strip_edges()
			if card_id == "" or title == "":
				continue
			var span := 2 if int(raw_card.get("span", 1)) == 2 else 1
			if card_id == "evolution_from" and text == "":
				text = String(classification.get("baseDisplayName", "")).strip_edges()
			if text == "":
				continue
			cards.append({"id": card_id, "title": title, "text": text, "span": span})
	result["cards"] = cards
	var paragraphs: Array[String] = []
	var raw_paragraphs: Variant = lore.get("archiveParagraphs", lore.get("archive_paragraphs", []))
	if raw_paragraphs is Array:
		for paragraph_value in raw_paragraphs as Array:
			if not paragraph_value is String:
				continue
			var paragraph := String(paragraph_value).strip_edges()
			if paragraph != "":
				paragraphs.append(paragraph)
	result["archiveTitle"] = String(lore.get("archiveTitle", lore.get("archive_title", ""))).strip_edges()
	result["archiveParagraphs"] = paragraphs
	result["hasLore"] = not cards.is_empty() or not paragraphs.is_empty()
	return result

static func _item_classification(master: Dictionary, category: String, weapons: Array, characters: Array) -> Dictionary:
	if category == "accessories":
		return {"key": "accessory", "label": "アクセサリ"}
	if bool(master.get("isEvolved", false)):
		var base_id := String(master.get("baseWeaponId", "")).strip_edges()
		var base_name := _definition_name(weapons, base_id) if base_id != "" else ""
		return {"key": "evolved", "label": "進化武器", "baseWeaponId": base_id, "baseDisplayName": base_name}
	var initial_ids: Array[String] = []
	for character_value in characters:
		if not character_value is Dictionary:
			continue
		var initial_id := String((character_value as Dictionary).get("initialWeapon", "")).strip_edges()
		if initial_id != "" and not initial_ids.has(initial_id):
			initial_ids.append(initial_id)
	var weapon_id := String(master.get("id", "")).strip_edges()
	if initial_ids.has(weapon_id):
		return {"key": "initial", "label": "初期武器"}
	return {"key": "normal", "label": "通常武器"}

static func _character_unit_model(unit_id: String, sources: Dictionary) -> Dictionary:
	if unit_id == "":
		return {}
	var units_value: Variant = sources.get("characterUnits", [])
	var units: Array = []
	if units_value is Array:
		units = units_value as Array
	elif units_value is Dictionary:
		var nested: Variant = (units_value as Dictionary).get("units", [])
		if nested is Array:
			units = nested as Array
		elif (units_value as Dictionary).has(unit_id):
			var mapped: Variant = (units_value as Dictionary).get(unit_id)
			if mapped is Dictionary:
				units = [{"id": unit_id, "displayName": (mapped as Dictionary).get("displayName", ""), "codexDescription": (mapped as Dictionary).get("codexDescription", (mapped as Dictionary).get("description", ""))}]
	for unit_value in units:
		if not unit_value is Dictionary:
			continue
		var unit := unit_value as Dictionary
		if String(unit.get("id", "")).strip_edges() != unit_id:
			continue
		return {
			"id": unit_id,
			"displayName": String(unit.get("displayName", "")).strip_edges(),
			"description": String(unit.get("codexDescription", unit.get("description", ""))).strip_edges()
		}
	return {}

static func _profile_string(value: Variant) -> String:
	return String(value).strip_edges() if value is String else ""

static func _profile_string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if not value is Array:
		return result
	for item_value in value as Array:
		if not item_value is String:
			continue
		var item := String(item_value).strip_edges()
		if item != "":
			result.append(item)
	return result

static func _profile_list_text(values: Array) -> String:
	var parts: Array[String] = []
	for value in values:
		var item := String(value).strip_edges()
		if item == "":
			continue
		parts.append(item)
	var joined := "、".join(parts)
	if joined != "" and not _ends_with_sentence_punctuation(joined):
		joined += "。"
	return joined

static func _ends_with_sentence_punctuation(value: String) -> bool:
	for suffix in ["。", "！", "？", "!", "?", "."]:
		if value.ends_with(suffix):
			return true
	return false

static func weapon_performance_model(weapon: Dictionary, initial_owner: bool = false) -> Dictionary:
	var stat_keys := _declared_stats(weapon)
	var max_level := maxi(1, int(weapon.get("maxLevel", 1)))
	var evolved := bool(weapon.get("isEvolved", false))
	var model := {
		"basicStats": [],
		"levelRows": [],
		"performanceStats": [],
		"specials": _weapon_specials(weapon),
		"maxLevel": max_level,
		"isEvolved": evolved,
		"showLevels": not evolved,
		"standardLabel": "INITIAL WEAPON STANDARD" if initial_owner else ("EVOLVED STANDARD" if evolved else "STANDARD PERFORMANCE"),
		"missing": false
	}
	if stat_keys.is_empty():
		model["missing"] = true
		return model
	if evolved:
		var evolved_values: Dictionary = WeaponSystemScript.codex_standard_stats_for_level(weapon, 1, false)
		var performance: Array = []
		for stat_key in stat_keys:
			if evolved_values.has(stat_key):
				var row := _stat_row(stat_key, evolved_values.get(stat_key))
				if not row.is_empty():
					performance.append(row)
		model["performanceStats"] = performance
		model["missing"] = performance.is_empty() and (model["specials"] as Array).is_empty()
		return model

	var values_by_level: Array[Dictionary] = []
	for level in range(1, max_level + 1):
		values_by_level.append(WeaponSystemScript.codex_standard_stats_for_level(weapon, level, initial_owner))
	var basic: Array = []
	var varying_keys: Array[String] = []
	for stat_key in stat_keys:
		var present := true
		var first_value: Variant = null
		var has_first := false
		var stable := true
		for value_dict in values_by_level:
			if not value_dict.has(stat_key):
				present = false
				break
			var current: Variant = value_dict.get(stat_key)
			if not has_first:
				first_value = current
				has_first = true
			elif not _same_stat_value(first_value, current):
				stable = false
		if not present or not has_first:
			continue
		if stable:
			var basic_row := _stat_row(stat_key, first_value)
			if not basic_row.is_empty():
				basic.append(basic_row)
		else:
			varying_keys.append(stat_key)
	model["basicStats"] = basic
	var level_rows: Array = []
	for level_index in range(values_by_level.size()):
		var level_stats: Array = []
		var level_values: Dictionary = values_by_level[level_index]
		for stat_key in varying_keys:
			if level_values.has(stat_key):
				var level_row := _stat_row(stat_key, level_values.get(stat_key))
				if not level_row.is_empty():
					level_stats.append(level_row)
		level_rows.append({"level": level_index + 1, "stats": level_stats})
	model["levelRows"] = level_rows
	model["missing"] = basic.is_empty() and _all_level_rows_empty(level_rows) and (model["specials"] as Array).is_empty()
	return model

static func accessory_performance_model(gift: Dictionary) -> Dictionary:
	var stat_keys := _declared_stats(gift)
	var max_level := maxi(1, int(gift.get("maxLevel", 1)))
	var rows: Array = []
	for level in range(1, max_level + 1):
		var stats: Array = []
		var values: Dictionary = GiftSystemScript.codex_accessory_stats_for_level(gift, level)
		for stat_key in stat_keys:
			if values.has(stat_key):
				var row := _stat_row(stat_key, values.get(stat_key))
				if not row.is_empty():
					stats.append(row)
		rows.append({"level": level, "stats": stats})
	return {
		"basicStats": [],
		"levelRows": rows,
		"performanceStats": [],
		"specials": [],
		"maxLevel": max_level,
		"showLevels": true,
		"missing": _all_level_rows_empty(rows)
	}

static func comment_effect_model(master: Dictionary) -> Dictionary:
	var normal_view := CommentSystemScript.codex_comment_view(master, false)
	var model := {
		"tags": _comment_tags(master),
		"normal": _comment_effect_block(normal_view, false),
		"heart": {},
		"hard": {},
		"missing": false
	}
	if master.get("heartVariant", null) is Dictionary:
		model["heart"] = _comment_effect_block(CommentSystemScript.codex_comment_view(master, true), true)
	var source: Variant = _read_json("res://data/difficulty_modes.json")
	var hard_config := HardModeSystemScript.config_for("hard", source if source is Dictionary else {})
	var hard_view := HardModeSystemScript.resolve_comment(master, {"difficulty": "hard", "difficultyConfig": hard_config})
	if bool(master.get("hardOnly", false)) or _comment_blocks_differ(normal_view, hard_view):
		model["hard"] = _comment_effect_block(hard_view, false)
	model["missing"] = String((model["normal"] as Dictionary).get("description", "")).strip_edges() == "" and ((model["normal"] as Dictionary).get("params", []) as Array).is_empty()
	return model

static func _comment_effect_block(view: Dictionary, heart: bool) -> Dictionary:
	var description := String(view.get("description", "")).strip_edges()
	var lines: Array[String] = []
	if String(view.get("id", "")) == "do_everything":
		lines.append("複合的な特殊効果が発動")
	var multiplier_value: Variant = view.get("multiplier", view.get("scoreRate", null))
	if multiplier_value is float or multiplier_value is int:
		lines.append("盛り上がり ×%s" % _format_number(float(multiplier_value)))
	return {
		"description": description,
		"params": _comment_param_rows(view.get("params", {})),
		"lines": lines,
		"heart": heart
	}

static func _comment_param_rows(value: Variant) -> Array:
	var rows: Array = []
	if not value is Dictionary:
		return rows
	for key_value in (value as Dictionary).keys():
		var key := String(key_value)
		if not COMMENT_PARAM_META.has(key):
			continue
		var raw: Variant = (value as Dictionary).get(key)
		if not (raw is bool or raw is int or raw is float):
			continue
		rows.append({"key": key, "label": String(COMMENT_PARAM_META.get(key, key)), "rawValue": raw, "text": _format_comment_param(key, raw)})
	return rows

static func _format_comment_param(key: String, raw: Variant) -> String:
	if raw is bool:
		return "あり" if bool(raw) else "なし"
	var value := float(raw)
	var number := _format_number(value)
	if key.ends_with("Multiplier") or key.ends_with("Rate") or key.ends_with("Coefficient") or key in ["rangeRate", "areaRate", "searchRate"]:
		return "×%s" % number
	if key.to_lower().contains("duration") or key.to_lower().contains("interval") or key.to_lower().contains("lifetime") or key.to_lower().contains("delay") or key.to_lower().contains("seconds"):
		return "%s秒" % number
	if key.to_lower().contains("count") or key.to_lower().contains("burst") or key.to_lower().contains("emitter") or key.to_lower().contains("lane"):
		return "%s" % number
	return number

static func _comment_blocks_differ(first: Dictionary, second: Dictionary) -> bool:
	if String(first.get("description", "")) != String(second.get("description", "")):
		return true
	return first.get("params", {}) != second.get("params", {})

static func _comment_tags(master: Dictionary) -> Array[String]:
	var result: Array[String] = []
	var values: Array = []
	for key in ["category", "effectType"]:
		values.append(master.get(key, ""))
	for key in ["tags", "categories", "stageIds", "codexTags"]:
		var value: Variant = master.get(key, [])
		if value is Array:
			values.append_array(value as Array)
		else:
			values.append(value)
	for value in values:
		var tag := _known_comment_tag(String(value))
		if tag != "" and not result.has(tag):
			result.append(tag)
	if bool(master.get("hardOnly", false)) and not result.has("HARD"):
		result.append("HARD")
	if bool(master.get("isSpecialChoice", false)):
		if not result.has("特殊"):
			result.append("特殊")
		if not result.has("SPECIAL"):
			result.append("SPECIAL")
	return result

static func _known_comment_tag(value: String) -> String:
	var raw := value.strip_edges().to_lower()
	if raw == "" or raw in ["default", "normal", "instruction", "comment"]:
		return ""
	if raw in ["enemy", "enemy_attack", "enemy_pressure", "enemy_spawn"] or raw.contains("enemy"):
		return "敵強化"
	if raw in ["boss", "summon_boss"] or raw.contains("boss"):
		return "ボス"
	if raw in ["weapon", "control", "ui", "terrain", "god"] or raw.contains("weapon") or raw.contains("control"):
		return "プレイヤー制限"
	if raw in ["event", "stage_major_event", "hard_wave"] or raw.contains("event"):
		return "配信イベント"
	if raw in ["game", "gameplay", "genre", "forced_movement"] or raw.contains("game") or raw.contains("genre"):
		return "ゲームジャンル"
	if raw in ["song", "singing"] or raw.contains("song"):
		return "歌"
	if raw in ["drawing"] or raw.contains("drawing"):
		return "お絵かき"
	if raw in ["collab"] or raw.contains("collab"):
		return "コラボ"
	if raw == "hard" or raw.contains("hard"):
		return "HARD"
	if raw in ["special"]:
		return "特殊"
	return ""

static func _declared_stats(master: Dictionary) -> Array[String]:
	var result: Array[String] = []
	var value: Variant = master.get("codexStats", [])
	if not value is Array:
		return result
	for raw in value as Array:
		var key := String(raw).strip_edges()
		if key != "" and STAT_META.has(key) and not result.has(key):
			result.append(key)
	return result

static func is_known_stat_key(key: String) -> bool:
	return STAT_META.has(key.strip_edges())

static func _stat_row(key: String, raw: Variant) -> Dictionary:
	if not STAT_META.has(key):
		return {}
	var meta: Dictionary = STAT_META.get(key, {}) as Dictionary
	return {"key": key, "label": String(meta.get("label", key)), "rawValue": raw, "text": _format_stat_value(raw, meta)}

static func _format_stat_value(raw: Variant, meta: Dictionary) -> String:
	if raw is bool:
		return "あり" if bool(raw) else "なし"
	var kind := String(meta.get("kind", "number"))
	var number := _format_number(float(raw))
	match kind:
		"seconds": return "%s秒" % number
		"multiplier": return "×%s" % number
		"distance": return number
		"degrees": return "%s°" % number
		"count": return "%s%s" % [number, String(meta.get("unit", ""))]
	return "%s%s" % [number, String(meta.get("suffix", ""))]

static func _format_number(value: float) -> String:
	var text := "%.3f" % value
	while text.ends_with("0"):
		text = text.trim_suffix("0")
	if text.ends_with("."):
		text = text.trim_suffix(".")
	return text

static func _same_stat_value(first: Variant, second: Variant) -> bool:
	if first is bool or second is bool:
		return bool(first) == bool(second)
	if (first is int or first is float) and (second is int or second is float):
		return is_equal_approx(float(first), float(second))
	return first == second

static func _all_level_rows_empty(rows: Array) -> bool:
	for value in rows:
		if value is Dictionary and not ((value as Dictionary).get("stats", []) as Array).is_empty():
			return false
	return true

static func _weapon_specials(weapon: Dictionary) -> Array[String]:
	var result: Array[String] = []
	var declared: Variant = weapon.get("codexSpecials", [])
	if declared is Array:
		for value in declared as Array:
			var text := String(value).strip_edges()
			if text != "" and not result.has(text):
				result.append(text)
	if bool(weapon.get("blockEnemyProjectiles", false)):
		result.append("敵弾をブロック")
	if String(weapon.get("attackType", "")) == "orbit":
		result.append("周囲を回転攻撃")
	return result

static func character_record_model(character: Dictionary, entry: Dictionary, difficulty_progress: Dictionary = {}) -> Dictionary:
	var record := {
		"playCount": maxi(0, int(entry.get("play_count", 0))),
		"clearCount": maxi(0, int(entry.get("clear_count", 0))),
		"bestScore": maxi(0, int(entry.get("best_score", 0))),
		"stageClears": _record_stage_clear_model(entry.get("stage_clears", {}), difficulty_progress),
		"relayRecords": _record_relay_model(entry.get("relay_records", {}), difficulty_progress)
	}
	return record

static func boss_record_model(master: Dictionary, entry: Dictionary, difficulty_progress: Dictionary = {}, sources: Dictionary = {}) -> Dictionary:
	var defeated_value: Variant = entry.get("defeated", {})
	var defeated: Dictionary = defeated_value as Dictionary if defeated_value is Dictionary else {}
	var applicable: Array[String] = _boss_applicable_difficulties(master, sources)
	var states: Array = []
	for difficulty_id in RECORD_DIFFICULTIES:
		if not applicable.has(difficulty_id) and difficulty_id == "expert":
			continue
		var unlock_state := difficulty_state(difficulty_progress, difficulty_id)
		if bool(master.get("relayBoss", false)):
			unlock_state = relay_difficulty_state(difficulty_progress, difficulty_id)
		var status := "LOCK"
		if unlock_state == "OPEN":
			status = "CLEAR" if bool(defeated.get(difficulty_id, false)) else "---"
		states.append({
			"difficulty": difficulty_id,
			"label": String(RECORD_DIFFICULTY_LABELS.get(difficulty_id, difficulty_id.to_upper())),
			"status": status,
			"applicable": applicable.has(difficulty_id),
			"unlockState": unlock_state
		})
	return {
		"id": String(master.get("id", "")),
		"killCount": maxi(0, int(entry.get("kill_count", 0))),
		"states": states,
		"relatedEnemyIds": _string_array(master.get("relatedEnemyIds", []))
	}

static func comment_record_model(master: Dictionary, entry: Dictionary) -> Dictionary:
	var tags := _comment_tags(master)
	if String(master.get("category", "")) == "special" and not tags.has("特殊"):
		tags.append("特殊")
	var heart_description := ""
	var heart_variant: Variant = master.get("heartVariant", null)
	if heart_variant is Dictionary:
		heart_description = String((heart_variant as Dictionary).get("description", master.get("description", ""))).strip_edges()
		if heart_description == "":
			heart_description = String(master.get("description", "")).strip_edges()
	var body := String(master.get("text", master.get("body", master.get("displayName", "")))).strip_edges()
	if body == "":
		body = _display_name(master)
	var description := String(master.get("description", "")).strip_edges()
	var category := String(master.get("category", "")).strip_edges()
	return {
		"displayName": _display_name(master),
		"body": body,
		"description": description,
		"category": category,
		"tags": tags,
		"stageIds": _comment_stage_ids(master),
		"effectModel": comment_effect_model(master),
		"heartDescription": heart_description if heart_variant is Dictionary else "",
		"appearedCount": maxi(0, int(entry.get("appeared_count", 0))),
		"selectedCount": maxi(0, int(entry.get("selected_count", 0))),
		"heartCount": maxi(0, int(entry.get("heart_count", 0)))
	}

## Unified presentation model for instruction-comment archive pages.  The
## comment master remains the source of truth for the live card/effect view;
## codexLore is optional editorial data layered on top of it.
static func comment_lore_model(master: Dictionary, entry: Dictionary, discovered: bool = true) -> Dictionary:
	var record := comment_record_model(master, entry)
	var result: Dictionary = record.duplicate(true)
	result["id"] = String(master.get("id", "")).strip_edges()
	result["template"] = "directive_comment"
	result["classificationLabels"] = []
	result["classificationLabel"] = ""
	result["stageLabels"] = []
	result["cards"] = []
	result["archiveTitle"] = ""
	result["archiveParagraphs"] = []
	result["hasLore"] = false
	result["hasHeart"] = master.get("heartVariant", null) is Dictionary
	result["effectSummary"] = ""
	result["imagePath"] = ""
	result["codexVisual"] = {}
	result["illustrationModel"] = {}
	if not discovered:
		result["body"] = ""
		result["description"] = ""
		result["tags"] = []
		result["stageIds"] = []
		result["effectModel"] = {}
		result["heartDescription"] = ""
		result["appearedCount"] = 0
		result["selectedCount"] = 0
		result["heartCount"] = 0
		result["hasHeart"] = false
		return result

	var stage_ids: Array[String] = record.get("stageIds", []) as Array[String]
	var stage_labels := _comment_stage_labels(stage_ids)
	var classification_labels: Array[String] = []
	classification_labels.append_array(stage_labels)
	if bool(result["hasHeart"]):
		classification_labels.append("♡あり")
	if classification_labels.size() > 3:
		classification_labels = ["複数枠", "♡あり"] if bool(result["hasHeart"]) else ["複数枠"]
	result["stageLabels"] = stage_labels
	result["classificationLabels"] = classification_labels
	result["classificationLabel"] = " / ".join(classification_labels)
	result["imagePath"] = image_path_for("comments", master, true)
	result["effectSummary"] = String(record.get("description", "")).strip_edges()
	var lore_value: Variant = master.get("codexLore", master.get("codex_lore", {}))
	var lore: Dictionary = lore_value as Dictionary if lore_value is Dictionary else {}
	result["codexVisual"] = _comment_codex_visual(lore)
	result["illustrationModel"] = {
		"imagePath": result["imagePath"],
		"codexVisual": (result["codexVisual"] as Dictionary).duplicate(true)
	}

	var appeared_count := int(result.get("appearedCount", 0))
	if appeared_count > 0:
		result["selectionRate"] = float(result.get("selectedCount", 0)) / float(appeared_count) * 100.0

	if lore.is_empty():
		return result
	var cards: Array = []
	var raw_cards: Variant = lore.get("cards", [])
	if raw_cards is Array:
		for card_value in raw_cards as Array:
			if not card_value is Dictionary:
				continue
			var raw_card := card_value as Dictionary
			var card_id := String(raw_card.get("id", "")).strip_edges()
			var title := String(raw_card.get("title", "")).strip_edges()
			var text := String(raw_card.get("text", "")).strip_edges()
			if card_id == "" or title == "" or text == "":
				continue
			var span := 2 if int(raw_card.get("span", 1)) == 2 else 1
			cards.append({"id": card_id, "title": title, "text": text, "span": span})
	var paragraphs: Array[String] = []
	var raw_paragraphs: Variant = lore.get("archiveParagraphs", lore.get("archive_paragraphs", []))
	if raw_paragraphs is Array:
		for paragraph_value in raw_paragraphs as Array:
			if not paragraph_value is String:
				continue
			var paragraph := String(paragraph_value).strip_edges()
			if paragraph != "":
				paragraphs.append(paragraph)
	result["cards"] = cards
	result["archiveTitle"] = String(lore.get("archiveTitle", lore.get("archive_title", ""))).strip_edges()
	result["archiveParagraphs"] = paragraphs
	result["hasLore"] = not cards.is_empty() or not paragraphs.is_empty()
	return result

static func _comment_codex_visual(lore: Dictionary) -> Dictionary:
	var normalized := {"scale": 1.0, "offsetX": 0.0, "offsetY": 0.0}
	var visual_value: Variant = lore.get("codexVisual", lore.get("codex_visual", {}))
	if not visual_value is Dictionary:
		return normalized
	var visual := visual_value as Dictionary
	var raw_scale: Variant = visual.get("scale", 1.0)
	var raw_offset_x: Variant = visual.get("offsetX", visual.get("offset_x", 0.0))
	var raw_offset_y: Variant = visual.get("offsetY", visual.get("offset_y", 0.0))
	var scale := float(raw_scale) if raw_scale is int or raw_scale is float else 1.0
	var offset_x := float(raw_offset_x) if raw_offset_x is int or raw_offset_x is float else 0.0
	var offset_y := float(raw_offset_y) if raw_offset_y is int or raw_offset_y is float else 0.0
	if not is_finite(scale):
		scale = 1.0
	if not is_finite(offset_x):
		offset_x = 0.0
	if not is_finite(offset_y):
		offset_y = 0.0
	return {
		"scale": clampf(scale, 0.5, 2.5),
		"offsetX": clampf(offset_x, -1.0, 1.0),
		"offsetY": clampf(offset_y, -1.0, 1.0)
	}

static func _comment_stage_labels(stage_ids: Array[String]) -> Array[String]:
	var normalized: Array[String] = []
	for stage_id in stage_ids:
		var stage := normalize_stage_id(stage_id)
		if stage != "" and stage != "relay" and not normalized.has(stage):
			normalized.append(stage)
	# No explicit stage restriction means the runtime default pool, i.e. 共通.
	if normalized.is_empty() or normalized.size() >= RECORD_STAGE_IDS.size():
		return ["共通"]
	var labels: Array[String] = []
	var label_map := {"gameplay": "ゲーム実況", "singing": "歌枠", "drawing": "お絵かき", "collab": "コラボ", "zatsudan": "雑談"}
	for stage in normalized:
		var label := String(label_map.get(stage, stage))
		if label != "" and not labels.has(label):
			labels.append(label)
	return labels if not labels.is_empty() else ["共通"]

static func _comment_stage_ids(master: Dictionary) -> Array[String]:
	var result: Array[String] = []
	var raw_stage_ids: Variant = master.get("stageIds", [])
	if raw_stage_ids is Array:
		for raw_stage in raw_stage_ids as Array:
			var stage := normalize_stage_id(raw_stage)
			if stage != "" and stage != "relay" and not result.has(stage):
				result.append(stage)
	if not result.is_empty():
		return result
	var raw_tags: Variant = master.get("tags", master.get("commentPoolTags", []))
	if raw_tags is Array:
		for raw_tag in raw_tags as Array:
			var tagged_stage := normalize_stage_id(raw_tag)
			if tagged_stage != "" and tagged_stage != "relay" and not result.has(tagged_stage):
				result.append(tagged_stage)
	if not result.is_empty():
		return result
	var category := String(master.get("category", "")).strip_edges().to_lower()
	var category_stage := normalize_stage_id(category)
	if category_stage != "" and category_stage != "relay":
		return [category_stage]
	# A comment without stage tags uses the runtime's default pool and can appear
	# in every standard frame.  Keep this derived rather than duplicating a
	# per-comment stage list in comments.json.
	return RECORD_STAGE_IDS.duplicate()

static func session_discovery_groups(snapshot: Dictionary, masters: Dictionary = {}) -> Array:
	var groups: Array = []
	for category in ["characters", "weapons", "accessories", "enemies", "comments"]:
		var ids_value: Variant = snapshot.get(category, [])
		if not ids_value is Array or (ids_value as Array).is_empty():
			continue
		var category_masters: Dictionary = masters.get(category, {}) as Dictionary
		var names: Array[String] = []
		var ids: Array[String] = []
		for raw_id in ids_value as Array:
			var id := String(raw_id)
			if id == "" or ids.has(id):
				continue
			ids.append(id)
			var master: Dictionary = category_masters.get(id, {}) as Dictionary
			names.append(_display_name(master) if not master.is_empty() else id)
		if not names.is_empty():
			groups.append({"category": category, "label": String(CODEX_CATEGORY_LABELS.get(category, category)), "ids": ids, "names": names})
	return groups

static func has_session_entries(snapshot: Dictionary) -> bool:
	for category in ["characters", "weapons", "accessories", "enemies", "comments"]:
		var value: Variant = snapshot.get(category, [])
		if value is Array and not (value as Array).is_empty():
			return true
	return false

static func difficulty_state(difficulty_progress: Dictionary, difficulty_id: String) -> String:
	var modes_value: Variant = _read_json("res://data/difficulty_modes.json")
	var modes: Dictionary = modes_value.get("modes", {}) as Dictionary if modes_value is Dictionary else {}
	var mode: Dictionary = modes.get(difficulty_id, {}) as Dictionary
	if mode.is_empty() or not bool(mode.get("implemented", false)):
		return "LOCK"
	var difficulties_value: Variant = difficulty_progress.get("difficulties", {})
	var difficulties: Dictionary = difficulties_value as Dictionary if difficulties_value is Dictionary else {}
	var progress: Dictionary = difficulties.get(difficulty_id, {}) as Dictionary
	return "OPEN" if bool(progress.get("unlocked", false)) else "LOCK"

static func relay_difficulty_state(difficulty_progress: Dictionary, difficulty_id: String) -> String:
	if difficulty_state(difficulty_progress, difficulty_id) != "OPEN":
		return "LOCK"
	var difficulties_value: Variant = difficulty_progress.get("difficulties", {})
	var difficulties: Dictionary = difficulties_value as Dictionary if difficulties_value is Dictionary else {}
	var progress: Dictionary = difficulties.get(difficulty_id, {}) as Dictionary
	var relay_value: Variant = progress.get("relay", {})
	var relay: Dictionary = relay_value as Dictionary if relay_value is Dictionary else {}
	return "OPEN" if bool(relay.get("unlocked", false)) else "LOCK"

static func _record_stage_clear_model(value: Variant, difficulty_progress: Dictionary) -> Array:
	var source: Dictionary = value as Dictionary if value is Dictionary else {}
	var result: Array = []
	for stage_id in RECORD_STAGE_IDS:
		var raw_flags: Variant = source.get(stage_id, {})
		var flags: Dictionary = raw_flags as Dictionary if raw_flags is Dictionary else {}
		var states: Array = []
		for difficulty_id in RECORD_DIFFICULTIES:
			var unlock_state := difficulty_state(difficulty_progress, difficulty_id)
			states.append({
				"difficulty": difficulty_id,
				"label": String(RECORD_DIFFICULTY_LABELS.get(difficulty_id, difficulty_id.to_upper())),
				"status": "CLEAR" if unlock_state == "OPEN" and bool(flags.get(difficulty_id, false)) else ("---" if unlock_state == "OPEN" else "LOCK")
			})
		result.append({"stageId": stage_id, "label": String(RECORD_STAGE_LABELS.get(stage_id, stage_id)), "states": states})
	return result

static func _record_relay_model(value: Variant, difficulty_progress: Dictionary) -> Array:
	var source: Dictionary = value as Dictionary if value is Dictionary else {}
	var result: Array = []
	for difficulty_id in RECORD_DIFFICULTIES:
		var raw_record: Variant = source.get(difficulty_id, {})
		var record: Dictionary = raw_record as Dictionary if raw_record is Dictionary else {}
		var unlock_state := relay_difficulty_state(difficulty_progress, difficulty_id)
		var section := clampi(int(record.get("best_section", 0)), 0, 5)
		result.append({
			"difficulty": difficulty_id,
			"label": String(RECORD_DIFFICULTY_LABELS.get(difficulty_id, difficulty_id.to_upper())),
			"status": "CLEAR" if unlock_state == "OPEN" and bool(record.get("cleared", false)) else ("---" if unlock_state == "OPEN" else "LOCK"),
			"bestSection": section,
			"bestSectionLabel": String(RECORD_STAGE_LABELS.get(RECORD_STAGE_IDS[mini(section - 1, RECORD_STAGE_IDS.size() - 1)], "---")) if section > 0 else "---"
		})
	return result

static func _boss_applicable_difficulties(master: Dictionary, sources: Dictionary) -> Array[String]:
	var result: Array[String] = ["normal", "hard"]
	var modes_value: Variant = sources.get("difficultyModes", {})
	var modes: Dictionary = modes_value.get("modes", {}) as Dictionary if modes_value is Dictionary else {}
	if bool(master.get("relayBoss", false)):
		result.clear()
		for difficulty_id in ["normal", "hard"]:
			var mode: Variant = modes.get(difficulty_id, {})
			if mode is Dictionary and bool((mode as Dictionary).get("implemented", false)):
				result.append(difficulty_id)
		return result if not result.is_empty() else ["normal"]
	if not modes.has("hard"):
		result.erase("hard")
	return result

static func image_path_for(category: String, master: Dictionary, discovered: bool = true) -> String:
	if not discovered:
		return ""
	match category:
		"enemies":
			return image_path_for_enemy(String(master.get("id", "")))
		"characters":
			return image_path_for_character(master)
		"weapons", "accessories":
			return safe_resource_path(String(master.get("iconPath", "")))
		"comments":
			var choice_icon_path := CommentSystemScript.instruction_comment_icon_path(String(master.get("id", "")))
			var safe_choice_icon_path := safe_resource_path(choice_icon_path)
			if safe_choice_icon_path != "":
				return safe_choice_icon_path
			return safe_resource_path(String(master.get("imagePath", "")))
	return ""

static func image_path_for_enemy(enemy_id: String) -> String:
	return safe_resource_path(DrawDataSystemScript.enemy_sprite_path(enemy_id))

static func image_path_for_character(character: Dictionary) -> String:
	for key in ["selectSprite", "sprite", "hudIcon"]:
		var path := safe_resource_path(String(character.get(key, "")))
		if path != "":
			return path
	return ""

static func safe_resource_path(path: String) -> String:
	var normalized := path.strip_edges()
	if normalized == "" or not ResourceLoader.exists(normalized):
		return ""
	return normalized

static func _requirement_labels(recipe: Dictionary, weapons: Array, gifts: Array, self_character: bool) -> Array[String]:
	var labels: Array[String] = ["%s Lv%d" % [String(recipe.get("baseDisplayName", "---")), int(recipe.get("requiredWeaponLevel", 1))]]
	var required_character := String(recipe.get("requiredCharacterId", ""))
	var bypass := bool(recipe.get("matchingCharacterBypassesAdditionalRequirements", false))
	if self_character and required_character != "" and bypass:
		return labels
	for requirement_value in recipe.get("additionalRequirements", []) as Array:
		if not requirement_value is Dictionary:
			continue
		var requirement: Dictionary = requirement_value as Dictionary
		var registry := weapons if String(requirement.get("type", "")) == "weapon" else gifts
		var name := _definition_name(registry, String(requirement.get("id", "")))
		labels.append("%s %s" % [name, _level_label(requirement.get("requiredLevel", 1))])
	return labels

static func _spawn_type_condition(spawn_type: String, master: Dictionary, sources: Dictionary = {}) -> String:
	var enemy_id := String(master.get("id", ""))
	if spawn_type == "boss_summon":
		match enemy_id:
			"unread_maro": return "クソマロキングの召喚経路で出現"
			"collab_division_noise", "collab_mute_core": return "コラボクラッシャー関連イベントで出現"
			"noise_ghost_comment": return "ラストオフラインの召喚で出現"
	match spawn_type:
		"genre_race": return "ゲーム実況のレースイベント中に出現"
		"genre_bullet": return "ゲーム実況の弾幕イベント中に出現"
		"genre_bullet_late": return "ゲーム実況の弾幕イベント中、配信開始%.0f秒以降に出現" % EnemySystemScript.BULLET_DRONE_STAGE_START_SECONDS
		"genre_horror": return "ゲーム実況のホラーイベント開始時に出現"
		"fake_gift_destroy": return "ホラーイベント中に偽ギフトを破壊すると出現"
		"marshmallow_timeout": return "マシュマロ時間切れ後、クソマロキングの召喚経路で出現"
		"boss_summon": return "ボス戦で召喚される"
		"boss_only":
			var stages := stage_ids_for_display(master, sources)
			return "%sのボス戦で出現" % stage_label(stages[0] if not stages.is_empty() else "")
		"relay_final_boss": return _relay_final_boss_condition(enemy_id, sources)
	return ""

static func _relay_final_boss_condition(enemy_id: String, sources: Dictionary) -> String:
	var relay_value: Variant = sources.get("relayMode", {})
	var relay_boss: Dictionary = relay_value.get("boss", {}) as Dictionary if relay_value is Dictionary else {}
	if String(relay_boss.get("id", "")) != enemy_id:
		return "配信リレーの最終戦で出現"
	var modes_value: Variant = sources.get("difficultyModes", {})
	var modes: Dictionary = modes_value.get("modes", {}) as Dictionary if modes_value is Dictionary else {}
	var available: Array[String] = []
	for difficulty_id in ["normal", "hard", "expert"]:
		var mode: Variant = modes.get(difficulty_id, {})
		if mode is Dictionary and bool((mode as Dictionary).get("implemented", false)):
			available.append(difficulty_id.to_upper())
	var suffix := "" if available.is_empty() else "（%s）" % " / ".join(available)
	return "配信リレーの最終戦で出現%s" % suffix

static func _spawn_type_hint(spawn_type: String, master: Dictionary) -> String:
	match spawn_type:
		"normal_wave": return "通常波で出現"
		"genre_race", "genre_bullet", "genre_bullet_late": return "特定のゲームジャンルで出現"
		"genre_horror", "fake_gift_destroy": return "特定のイベント中に出現"
		"marshmallow_timeout": return "マシュマロの時間切れに関係して出現"
		"boss_summon": return "ボス戦で出現"
		"boss_only": return "この配信枠のボス戦で出現"
		"relay_final_boss": return "配信リレーで出現"
	return ""

static func _has_event_spawn_type(master: Dictionary) -> bool:
	for spawn_type in spawn_types(master):
		if spawn_type != "normal_wave":
			return true
	return false

static func _hard_config(value: Variant) -> Dictionary:
	if not value is Dictionary:
		return {}
	var source: Dictionary = value as Dictionary
	var modes: Variant = source.get("modes", source)
	if modes is Dictionary and (modes as Dictionary).get("hard", null) is Dictionary:
		return (modes as Dictionary).get("hard", {}) as Dictionary
	return source

static func _read_json(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed if parsed != null else {}

static func _find_by_id(items: Array, id: String) -> Dictionary:
	for item in items:
		if item is Dictionary and String((item as Dictionary).get("id", "")) == id:
			return item as Dictionary
	return {}

static func _definition_name(items: Array, id: String) -> String:
	var definition := _find_by_id(items, id)
	return _display_name(definition) if not definition.is_empty() else id

static func _display_name(item: Dictionary) -> String:
	var name := String(item.get("displayName", "")).strip_edges()
	return name if name != "" else String(item.get("id", "---"))

static func _level_label(value: Variant) -> String:
	if str(value).strip_edges().to_lower() == "max":
		return "LvMAX"
	return "Lv%d" % int(value)

static func _string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for item in value as Array:
			var value_string := String(item).strip_edges()
			if value_string != "" and not result.has(value_string):
				result.append(value_string)
	return result

static func _unique_strings(values: Array[String]) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		if value != "" and not result.has(value):
			result.append(value)
	return result
