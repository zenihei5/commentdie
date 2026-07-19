class_name RelayRunData
extends RefCounted

static func capture(target: Node) -> Dictionary:
	return {
		"characterId": String(target.get("current_character_id")),
		"currentHp": int(target.get("player_hp")),
		"maxHp": int(target.get("player_max_hp")),
		"level": int(target.get("exp_level")),
		"exp": int(target.get("exp_value")),
		"weapons": _copy(target.get("player_weapons")),
		"accessories": _copy(target.get("player_accessories")),
		"score": int(target.get("score")),
		"relayBaseMultiplier": float(target.get("relay_base_multiplier")),
		"giftHype": int(target.get("gift_hype")),
		"maxGiftHype": int(target.get("max_gift_hype")),
		"heartStock": int(target.get("heart_stock")),
		"ngStock": int(target.get("ng_stock")),
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
	target.set("player_weapons", _copy(snapshot.get("weapons", [])))
	target.set("player_accessories", _copy(snapshot.get("accessories", [])))
	target.set("score", int(snapshot.get("score", target.get("score"))))
	target.set("relay_base_multiplier", maxf(1.0, float(snapshot.get("relayBaseMultiplier", 1.0))))
	target.set("multiplier", float(target.get("relay_base_multiplier")))
	target.set("gift_hype", clampi(int(snapshot.get("giftHype", target.get("gift_hype"))), 0, 100))
	target.set("max_gift_hype", maxi(int(snapshot.get("maxGiftHype", target.get("max_gift_hype"))), int(target.get("gift_hype"))))
	target.set("heart_stock", maxi(0, int(snapshot.get("heartStock", target.get("heart_stock")))))
	target.set("ng_stock", maxi(0, int(snapshot.get("ngStock", target.get("ng_stock")))))
	target.set("relay_persistent_run_buff", _copy(snapshot.get("persistentRunBuff", {})))
	target.set("collab_partner_id", String(snapshot.get("partnerId", target.get("collab_partner_id"))))
	target.set("collab_sync_stars", maxi(0, int(snapshot.get("syncStars", target.get("collab_sync_stars")))))

static func transient_boundary() -> Array[String]:
	return [
		"currentGenre", "genreObjects", "liveHeat", "heldNotes", "songEvents",
		"paintAmount", "paintZones", "drawingProgress", "drawingObjects",
		"activeCollabPass", "activeCollabChallenge", "temporaryEffects", "enemies",
		"enemyBullets", "expOrbs", "dropItems"
	]

static func _copy(value: Variant) -> Variant:
	if value is Array or value is Dictionary:
		return value.duplicate(true)
	return value
