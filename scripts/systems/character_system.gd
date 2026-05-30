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
	return {
		"character": character,
		"characterId": String(character.get("id", "ban_chan")),
		"weapon": weapon,
		"weaponId": weapon_id,
		"sprite": texture_from_cache(cache, sprite_path)
	}

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

static func role_name(character: Dictionary) -> String:
	return String(character.get("roleName", character.get("archetype", "配信者")))

static func texture_from_cache(cache: Dictionary, sprite_path: String) -> Texture2D:
	if sprite_path == "":
		return null
	if not cache.has(sprite_path):
		cache[sprite_path] = load(sprite_path) as Texture2D
	return cache[sprite_path] as Texture2D
