class_name RelayRunData
extends RefCounted

static func capture(target: Node) -> Dictionary:
	return {
		"characterId": String(target.get("current_character_id")),
		"currentHp": int(target.get("player_hp")),
		"maxHp": int(target.get("player_max_hp")),
		"level": int(target.get("exp_level")),
		"exp": int(target.get("exp_value")),
		"weapons": normalize_weapon_entries(_copy(target.get("player_weapons")) as Array),
		"accessories": _copy(target.get("player_accessories")),
		"score": int(target.get("score")),
		"relayBaseMultiplier": float(target.get("relay_base_multiplier")),
		"giftHype": int(target.get("gift_hype")),
		"maxGiftHype": int(target.get("max_gift_hype")),
		"heartStock": int(target.get("heart_stock")),
		"ngStock": int(target.get("ng_stock")),
		"burnResistCharges": int(target.get("burn_resist_charges")),
		"giftRerollRemaining": int(target.get("gift_reroll_remaining")),
		"persistentRunBuff": _copy(target.get("relay_persistent_run_buff")),
		"partnerId": String(target.get("collab_partner_id")),
		"syncStars": int(target.get("collab_sync_stars"))
	}

static func apply(target: Node, snapshot: Dictionary) -> void:
	if snapshot.is_empty():
		return
	target.set("current_character_id", String(snapshot.get("characterId", target.get("current_character_id"))))
	target.set("player_max_hp", maxi(1, int(snapshot.get("maxHp", target.get("player_max_hp")))))
	target.set("player_hp", clampi(int(snapshot.get("currentHp", target.get("player_hp"))), 0, int(target.get("player_max_hp"))))
	target.set("exp_level", maxi(1, int(snapshot.get("level", target.get("exp_level")))))
	target.set("exp_value", maxi(0, int(snapshot.get("exp", target.get("exp_value")))))
	var restored_weapons: Array = _copy(snapshot.get("weapons", [])) as Array
	_migrate_phase1_character_weapon(target, String(snapshot.get("characterId", target.get("current_character_id"))), restored_weapons)
	restored_weapons = normalize_weapon_entries(restored_weapons)
	target.set("player_weapons", restored_weapons)
	_normalize_current_weapon(target, restored_weapons)
	target.set("player_accessories", _copy(snapshot.get("accessories", [])))
	target.set("score", int(snapshot.get("score", target.get("score"))))
	target.set("relay_base_multiplier", maxf(1.0, float(snapshot.get("relayBaseMultiplier", 1.0))))
	target.set("multiplier", float(target.get("relay_base_multiplier")))
	target.set("gift_hype", clampi(int(snapshot.get("giftHype", target.get("gift_hype"))), 0, 100))
	target.set("max_gift_hype", maxi(int(snapshot.get("maxGiftHype", target.get("max_gift_hype"))), int(target.get("gift_hype"))))
	target.set("heart_stock", maxi(0, int(snapshot.get("heartStock", target.get("heart_stock")))))
	target.set("ng_stock", maxi(0, int(snapshot.get("ngStock", target.get("ng_stock")))))
	target.set("burn_resist_charges", maxi(0, int(snapshot.get("burnResistCharges", target.get("burn_resist_charges")))))
	target.set("gift_reroll_remaining", maxi(0, int(snapshot.get("giftRerollRemaining", target.get("gift_reroll_remaining")))))
	target.set("relay_persistent_run_buff", _copy(snapshot.get("persistentRunBuff", {})))
	target.set("collab_partner_id", String(snapshot.get("partnerId", target.get("collab_partner_id"))))
	target.set("collab_sync_stars", maxi(0, int(snapshot.get("syncStars", target.get("collab_sync_stars")))))

static func normalize_weapon_entries(weapons: Array) -> Array:
	var evolved_by_base: Dictionary = {}
	for item in weapons:
		var entry: Dictionary = item as Dictionary
		var base_id := String(entry.get("baseWeaponId", ""))
		if _is_evolved_entry(entry) and base_id != "":
			evolved_by_base[base_id] = entry
	var normalized: Array = []
	var seen_ids: Dictionary = {}
	for item in weapons:
		var entry: Dictionary = item as Dictionary
		var entry_id := String(entry.get("id", ""))
		if entry_id == "" or bool(seen_ids.get(entry_id, false)):
			continue
		if not _is_evolved_entry(entry) and evolved_by_base.has(entry_id):
			continue
		seen_ids[entry_id] = true
		normalized.append(entry)
	for base_id in evolved_by_base.keys():
		var evolved_entry: Dictionary = evolved_by_base[base_id] as Dictionary
		var evolved_id := String(evolved_entry.get("id", ""))
		if evolved_id != "" and not bool(seen_ids.get(evolved_id, false)):
			seen_ids[evolved_id] = true
			normalized.append(evolved_entry)
	return normalized

static func _is_evolved_entry(entry: Dictionary) -> bool:
	var level_text := String(entry.get("level", ""))
	return bool(entry.get("isEvolved", false)) or level_text == "evolved" or String(entry.get("baseWeaponId", "")) != ""

static func _normalize_current_weapon(target: Node, entries: Array) -> void:
	var current_id := String(target.get("current_weapon_id"))
	if current_id == "":
		return
	for item in entries:
		var entry: Dictionary = item as Dictionary
		if not _is_evolved_entry(entry) or String(entry.get("baseWeaponId", "")) != current_id:
			continue
		var evolved_id := String(entry.get("id", ""))
		target.set("current_weapon_id", evolved_id)
		var registry_value: Variant = target.get("weapons")
		if registry_value is Array:
			for weapon_item in registry_value as Array:
				var weapon: Dictionary = weapon_item as Dictionary
				if String(weapon.get("id", "")) == evolved_id:
					target.set("current_weapon", weapon)
					return
		return

static func transient_boundary() -> Array[String]:
	return [
		"currentGenre", "genreObjects", "liveHeat", "heldNotes", "songEvents",
		"paintAmount", "paintZones", "drawingProgress", "drawingObjects",
		"activeCollabPass", "activeCollabChallenge", "temporaryEffects", "enemies",
		"enemyBullets", "expOrbs", "dropItems"
	]

static func _migrate_phase1_character_weapon(target: Node, character_id: String, weapons: Array) -> void:
	var character: Dictionary = target.get("current_character") as Dictionary
	var initial_weapon_id := String(character.get("initialWeapon", ""))
	if initial_weapon_id == "" or initial_weapon_id == "phase1_null_weapon":
		var registry_value: Variant = target.get("characters")
		if registry_value is Array:
			var registry: Array = registry_value as Array
			for character_item in registry:
				var registry_character: Dictionary = character_item as Dictionary
				if String(registry_character.get("id", "")) == character_id:
					initial_weapon_id = String(registry_character.get("initialWeapon", ""))
					break
	if initial_weapon_id == "" or initial_weapon_id == "phase1_null_weapon":
		return
	var has_formal_weapon := false
	var replaced_null := false
	for index in range(weapons.size()):
		var entry: Dictionary = weapons[index] as Dictionary
		var entry_id := String(entry.get("id", ""))
		if entry_id == initial_weapon_id:
			has_formal_weapon = true
		if entry_id == "phase1_null_weapon":
			weapons[index] = {"id": initial_weapon_id, "level": 1}
			replaced_null = true
	if not has_formal_weapon and (replaced_null or weapons.is_empty()):
		weapons.append({"id": initial_weapon_id, "level": 1})

static func _copy(value: Variant) -> Variant:
	if value is Array or value is Dictionary:
		return value.duplicate(true)
	return value
