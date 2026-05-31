class_name CharacterSystem
extends RefCounted

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
	return {
		"character": character,
		"characterId": character_id,
		"weapon": weapon,
		"weaponId": weapon_id,
		"sprite": texture_from_cache(cache, sprite_path),
		"idleSprite": texture_from_cache(cache, idle_sprite_path)
	}

static func apply_selected_character_for_target(target: Node, characters: Array, weapons: Array, id: String, cache: Dictionary) -> void:
	var selected: Dictionary = selected_character_state(characters, weapons, id, cache)
	target.set("current_character", selected["character"] as Dictionary)
	target.set("current_character_id", String(selected["characterId"]))
	target.set("current_weapon_id", String(selected["weaponId"]))
	target.set("current_weapon", selected["weapon"] as Dictionary)
	target.set("player_sprite", selected["sprite"] as Texture2D)
	target.set("player_idle_sprite", selected["idleSprite"] as Texture2D)

static func selected_character_state_by_index(characters: Array, index: int) -> Dictionary:
	if index < 0 or index >= characters.size():
		return {}
	var character: Dictionary = characters[index] as Dictionary
	return {
		"character": character,
		"characterId": String(character.get("id", "ban_chan"))
	}

static func update_selection_action(latch: Dictionary, characters: Array, current_index: int) -> Dictionary:
	var action: Dictionary = ChoiceCardSystem.menu_selection_action(latch, current_index, characters.size(), 3)
	if ChoiceCardSystem.is_escape(action):
		return {"kind": "escape", "index": current_index}
	if ChoiceCardSystem.is_move(action):
		return {"kind": "move", "index": int(action["index"])}
	if ChoiceCardSystem.is_select(action):
		var selected: Dictionary = selected_character_state_by_index(characters, int(action["index"]))
		if selected.is_empty():
			return {"kind": "", "index": current_index}
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

static func selection_card_view(character: Dictionary, weapons: Array) -> Dictionary:
	var weapon_id: String = String(character.get("initialWeapon", "ban_hammer"))
	var weapon: Dictionary = WeaponSystem.find_weapon(weapons, weapon_id, fallback_weapon())
	var passive_data: Dictionary = passive(character)
	return {
		"displayName": String(character.get("displayName", "配信者")),
		"roleName": String(character.get("roleName", "")),
		"weaponName": String(weapon.get("displayName", "未設定")),
		"passiveName": String(passive_data.get("displayName", "なし")),
		"description": String(character.get("description", "")),
		"spritePath": String(character.get("sprite", ""))
	}

static func fallback_character() -> Dictionary:
	return {
		"id": "ban_chan",
		"displayName": "バンちゃん",
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
		"range": 165.0,
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
	if not cache.has(sprite_path):
		cache[sprite_path] = load(sprite_path) as Texture2D
	return cache[sprite_path] as Texture2D
