class_name CharacterSystem
extends RefCounted

const TextureCacheSystemScript := preload("res://scripts/systems/texture_cache_system.gd")

const SELECT_PAGE_SIZE := 6
const SELECT_COLUMNS := 3

static func selection_visible_count(character_count: int) -> int:
	return maxi(SELECT_PAGE_SIZE, character_count)

static func find_character(characters: Array, id: String) -> Dictionary:
	for item in characters:
		var character: Dictionary = item as Dictionary
		if String(character.get("id", "")) == id:
			return character
	if not characters.is_empty():
		return characters[0] as Dictionary
	return fallback_character()

static func selected_index(characters: Array, id: String) -> int:
	for i in range(characters.size()):
		var character: Dictionary = characters[i] as Dictionary
		if String(character.get("id", "")) == id:
			return i
	return 0

static func selected_character_state(characters: Array, weapons: Array, id: String, cache: Dictionary) -> Dictionary:
	var character: Dictionary = find_character(characters, id)
	var weapon_id: String = String(character.get("initialWeapon", "ban_hammer"))
	var weapon: Dictionary = WeaponSystem.find_weapon(weapons, weapon_id, fallback_weapon())
	var sprite_path: String = String(character.get("sprite", ""))
	var character_id: String = String(character.get("id", "ban_chan"))
	var idle_sprite_path: String = String(character.get("idleSprite", ""))
	if idle_sprite_path == "" and character_id == "ban_chan":
		idle_sprite_path = "res://assets/generated/ban_chan_idle_3x3/sheet-transparent.png"
	var run_sprite_path: String = String(character.get("runSprite", ""))
	return {
		"character": character,
		"characterId": character_id,
		"weapon": weapon,
		"weaponId": weapon_id,
		"sprite": texture_from_cache(cache, sprite_path),
		"idleSprite": texture_from_cache(cache, idle_sprite_path),
		"runSprite": texture_from_cache(cache, run_sprite_path)
	}

static func apply_selected_character_for_target(target: Node, characters: Array, weapons: Array, id: String, cache: Dictionary) -> void:
	var selected: Dictionary = selected_character_state(characters, weapons, id, cache)
	target.set("current_character", selected["character"] as Dictionary)
	target.set("current_character_id", String(selected["characterId"]))
	target.set("current_weapon_id", String(selected["weaponId"]))
	target.set("current_weapon", selected["weapon"] as Dictionary)
	target.set("player_sprite", selected["sprite"] as Texture2D)
	target.set("player_idle_sprite", selected["idleSprite"] as Texture2D)
	target.set("player_run_sprite", selected["runSprite"] as Texture2D)

static func selected_character_state_by_index(characters: Array, index: int) -> Dictionary:
	if index < 0 or index >= characters.size():
		return {}
	var character: Dictionary = characters[index] as Dictionary
	return {
		"character": character,
		"characterId": String(character.get("id", "ban_chan"))
	}

static func update_selection_action(latch: Dictionary, characters: Array, current_index: int) -> Dictionary:
	var visible_count: int = selection_visible_count(characters.size())
	var action: Dictionary = ChoiceCardSystem.character_grid_selection_action(latch, current_index, visible_count, SELECT_PAGE_SIZE, SELECT_COLUMNS, 6)
	if ChoiceCardSystem.is_escape(action):
		return {"kind": "escape", "index": current_index}
	if ChoiceCardSystem.is_move(action):
		return {"kind": "move", "index": int(action["index"])}
	if ChoiceCardSystem.is_select(action):
		var selected: Dictionary = selected_character_state_by_index(characters, int(action["index"]))
		if selected.is_empty():
			return {"kind": "locked", "index": int(action["index"])}
		if not is_selectable(selected["character"] as Dictionary):
			return {"kind": "locked", "index": int(action["index"])}
		return {
			"kind": "select",
			"index": int(action["index"]),
			"characterId": String(selected["characterId"])
		}
	return {"kind": "", "index": current_index}

static func update_selection_for_target(target: Node, latch: Dictionary, characters: Array) -> Dictionary:
	var action: Dictionary = update_selection_action(latch, characters, int(target.get("selected_character_index")))
	var kind: String = String(action["kind"])
	if kind == "escape":
		target.set("state", "title")
		return {"startStreamFrameSelect": false}
	if kind == "move":
		target.set("selected_character_index", int(action["index"]))
	elif kind == "locked":
		target.set("selected_character_index", int(action["index"]))
	elif kind == "select":
		target.set("current_character_id", String(action["characterId"]))
		return {"startStreamFrameSelect": true}
	return {"startStreamFrameSelect": false}

static func start_selection_for_target(target: Node, choice_box: Control, result_panel: Control, characters: Array) -> Dictionary:
	StateFlowSystem.open_pre_run_select_for_target(target, "character_select", choice_box, result_panel)
	if characters.is_empty():
		target.set("current_character_id", "ban_chan")
		return {"restart": true, "chat": "今日の配信者を選べ"}
	var current_id: String = String(target.get("current_character_id"))
	target.set("selected_character_index", selected_index(characters, current_id))
	return {"restart": false, "chat": "今日の配信者を選べ"}

static func selection_page_count(character_count: int) -> int:
	var count: int = selection_visible_count(character_count)
	return maxi(1, int(ceil(float(maxi(1, count)) / float(SELECT_PAGE_SIZE))))

static func selection_page_for_index(index: int, character_count: int) -> int:
	var page_count: int = selection_page_count(character_count)
	var count: int = selection_visible_count(character_count)
	if count <= 0:
		return 0
	return clampi(int(clampi(index, 0, count - 1) / SELECT_PAGE_SIZE), 0, page_count - 1)

static func selection_index_for_page(characters: Array, page: int, local_index: int = 0) -> int:
	var page_count: int = selection_page_count(characters.size())
	var clamped_page: int = clampi(page, 0, page_count - 1)
	var start: int = clamped_page * SELECT_PAGE_SIZE
	var end: int = mini(start + SELECT_PAGE_SIZE, selection_visible_count(characters.size()))
	return clampi(start + local_index, start, end - 1)

static func is_unlocked(character: Dictionary) -> bool:
	return bool(character.get("isUnlocked", true))

static func status_id(character: Dictionary) -> String:
	var explicit_status: String = String(character.get("status", "")).strip_edges()
	if explicit_status != "":
		return explicit_status
	if not is_unlocked(character):
		return "locked"
	return "playable"

static func is_selectable(character: Dictionary) -> bool:
	var status: String = status_id(character)
	return is_unlocked(character) and (status == "playable" or status == "selected" or status == "unlocked")

static func status_text(character: Dictionary) -> String:
	var status: String = status_id(character)
	match status:
		"coming_soon":
			return "準備中"
		"locked":
			return "未開放"
		"selected":
			return "選択中"
		_:
			return "使用可能"

static func theme_colors(character: Dictionary) -> Dictionary:
	var theme: String = String(character.get("themeColor", ""))
	var id: String = String(character.get("id", ""))
	if theme == "yellow_orange" or id == "superchat_chan":
		return {"accent": Color("#ffb238"), "accent2": Color("#ff7f4f"), "soft": Color("#fff4d8")}
	if theme == "pink_mint" or id == "maro_chan":
		return {"accent": Color("#ff7fbd"), "accent2": Color("#5ecfc0"), "soft": Color("#fff0f7")}
	return {"accent": Color("#ff4f92"), "accent2": Color("#7a56c8"), "soft": Color("#fff2fa")}

static func default_recommend_text(character_id: String) -> String:
	if character_id == "superchat_chan":
		return "遠くから敵を処理したい人向け。スパチャ弾で安全に戦える。"
	if character_id == "maro_chan":
		return "回収や安定感を重視したい人向け。コメントブーメランで周囲を守れる。"
	return "初めて遊ぶ人向け。近距離で敵をまとめて処理しやすい。"

static func default_specialty_text(character_id: String) -> String:
	if character_id == "superchat_chan":
		return "遠距離攻撃 / 弾数強化 / 火力型"
	if character_id == "maro_chan":
		return "周囲防御 / 回収補助 / 成長型"
	return "近距離制圧 / 正面突破 / 安定型"

static func default_card_tags(character_id: String) -> Array:
	if character_id == "superchat_chan":
		return ["#遠距離火力", "#安全圏"]
	if character_id == "maro_chan":
		return ["#回収補助", "#安定型"]
	return ["#近距離制圧", "#初心者向け"]

static func default_detail_tags(character_id: String) -> Array:
	if character_id == "superchat_chan":
		return ["#遠距離火力", "#安全圏", "#弾幕", "#火力型"]
	if character_id == "maro_chan":
		return ["#回収補助", "#周囲防御", "#安定型", "#成長型"]
	return ["#近距離制圧", "#初心者向け", "#正面突破"]

static func selection_card_view(character: Dictionary, weapons: Array) -> Dictionary:
	var weapon_id: String = String(character.get("initialWeapon", "ban_hammer"))
	var weapon: Dictionary = WeaponSystem.find_weapon(weapons, weapon_id, fallback_weapon())
	var passive_data: Dictionary = passive(character)
	var character_id: String = String(character.get("id", "ban_chan"))
	var colors: Dictionary = theme_colors(character)
	var evolution: Dictionary = weapon.get("evolution", {}) as Dictionary
	var evolved_weapon_id: String = String(character.get("evolvedWeaponId", evolution.get("evolvedWeaponId", "")))
	var evolved_weapon: Dictionary = WeaponSystem.find_weapon(weapons, evolved_weapon_id, {})
	var evolved_weapon_name: String = String(character.get("evolvedWeaponName", evolved_weapon.get("displayName", "")))
	var evolved_icon_path: String = String(evolved_weapon.get("iconPath", weapon.get("iconPath", "")))
	return {
		"displayName": String(character.get("displayName", "配信者")),
		"nickname": String(character.get("nickname", "")),
		"roleName": String(character.get("roleName", "")),
		"weaponName": String(weapon.get("displayName", "未設定")),
		"weaponIconPath": String(weapon.get("iconPath", "")),
		"evolvedWeaponName": evolved_weapon_name,
		"evolvedWeaponIconPath": evolved_icon_path,
		"passiveName": String(passive_data.get("displayName", "なし")),
		"passiveDescription": String(passive_data.get("description", "")),
		"description": String(character.get("description", "")),
		"recommendText": String(character.get("recommendText", default_recommend_text(character_id))),
		"specialtyText": String(character.get("specialtyText", default_specialty_text(character_id))),
		"cardTags": character.get("cardTags", default_card_tags(character_id)) as Array,
		"detailTags": character.get("detailTags", default_detail_tags(character_id)) as Array,
		"spritePath": String(character.get("sprite", "")),
		"isUnlocked": is_unlocked(character),
		"isSelectable": is_selectable(character),
		"statusId": status_id(character),
		"statusText": status_text(character),
		"accent": colors["accent"] as Color,
		"accent2": colors["accent2"] as Color,
		"softFill": colors["soft"] as Color,
		"unlockConditionText": String(character.get("unlockConditionText", "？？？"))
	}

static func fallback_character() -> Dictionary:
	return {
		"id": "ban_chan",
		"displayName": "赤羽ばんり",
		"roleName": "バランス型",
		"description": "扱いやすい標準配信者。BANハンマーで近づく敵をまとめて処理できる。",
		"sprite": "res://assets/characters/ban_chan.png",
		"spriteScale": 0.095,
		"spriteOffset": {"x": 0, "y": -34},
		"initialWeapon": "ban_hammer",
		"baseStats": {"hp": 5, "moveSpeed": 5.0, "dashCooldown": 1.2, "pickupRange": 1.0, "invincibleTime": 0.7},
		"initialResources": {"ngTickets": 0, "heartStock": 0, "giftHype": 0},
		"passiveSkill": {"id": "beginner_safe", "displayName": "初配信補正", "params": {"invincibleTimeBonus": 0.2}}
	}

static func fallback_weapon() -> Dictionary:
	return {
		"id": "ban_hammer",
		"displayName": "BANハンマー",
		"attackType": "melee_arc",
		"damage": 12.0,
		"range": 186.0,
		"arcAngle": 135.0,
		"attackInterval": 0.85,
		"knockback": 18.0,
		"magnetRange": 95.0
	}

static func base_stats(character: Dictionary) -> Dictionary:
	if character.has("baseStats") and character["baseStats"] is Dictionary:
		return character["baseStats"] as Dictionary
	return character

static func initial_resources(character: Dictionary) -> Dictionary:
	if character.has("initialResources") and character["initialResources"] is Dictionary:
		return character["initialResources"] as Dictionary
	return {
		"ngTickets": character.get("initialNgStock", 0),
		"heartStock": character.get("initialHeartStock", 0),
		"giftHype": 0
	}

static func passive(character: Dictionary) -> Dictionary:
	if character.has("passiveSkill") and character["passiveSkill"] is Dictionary:
		return character["passiveSkill"] as Dictionary
	return {}

static func apply_passive_values(character: Dictionary, values: Dictionary) -> Dictionary:
	var result: Dictionary = values.duplicate()
	var passive_data: Dictionary = passive(character)
	if passive_data.is_empty():
		return result
	var passive_id: String = String(passive_data.get("id", ""))
	var params: Dictionary = passive_data.get("params", {}) as Dictionary
	if passive_id == "beginner_safe":
		result["playerBaseInvincibleTime"] = float(result.get("playerBaseInvincibleTime", 0.7)) + float(params.get("invincibleTimeBonus", 0.2))
	elif passive_id == "superchat_bonus":
		result["passiveScoreRate"] = float(result.get("passiveScoreRate", 1.0)) * float(params.get("scoreRate", 1.1))
	elif passive_id == "sweet_tooth_passive":
		result["passiveMaroGoodRate"] = float(result.get("passiveMaroGoodRate", 1.0)) * float(params.get("marshmallowGoodEffectRate", 1.1))
		result["passiveMaroPickupRate"] = float(result.get("passiveMaroPickupRate", 1.0)) * float(params.get("marshmallowPickupRangeRate", 1.2))
	return result

static func apply_passive_for_target(target: Node, character: Dictionary) -> void:
	var values: Dictionary = apply_passive_values(character, {
		"playerBaseInvincibleTime": target.get("player_base_invincible_time"),
		"passiveScoreRate": target.get("passive_score_rate"),
		"passiveMaroGoodRate": target.get("passive_maro_good_rate"),
		"passiveMaroPickupRate": target.get("passive_maro_pickup_rate")
	})
	target.set("player_base_invincible_time", float(values["playerBaseInvincibleTime"]))
	target.set("passive_score_rate", float(values["passiveScoreRate"]))
	target.set("passive_maro_good_rate", float(values["passiveMaroGoodRate"]))
	target.set("passive_maro_pickup_rate", float(values["passiveMaroPickupRate"]))

static func role_name(character: Dictionary) -> String:
	return String(character.get("roleName", character.get("archetype", "配信者")))

static func texture_from_cache(cache: Dictionary, sprite_path: String) -> Texture2D:
	if sprite_path == "":
		return null
	return TextureCacheSystemScript.load_png_texture(cache, sprite_path)
