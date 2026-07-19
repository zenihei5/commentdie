class_name DamageSystem
extends RefCounted

const RelayStageProfileSystemScript := preload("res://scripts/systems/relay_stage_profile_system.gd")
const ModifierSystemScript := preload("res://scripts/systems/modifier_system.gd")
const PowerUpEffectProviderScript := preload("res://scripts/systems/power_up_effect_provider.gd")

const LEGACY_HP_UNIT := 20
const DEFAULT_CONTACT_DAMAGE := 12
const FAST_CONTACT_DAMAGE := 14
const STRONG_CONTACT_DAMAGE := 18
const GHOST_CONTACT_DAMAGE := 14
const BOSS_CONTACT_DAMAGE := 35
const ENEMY_BULLET_DAMAGE := 8
const SPREAD_ENEMY_BULLET_DAMAGE := 6
const DEFAULT_ZATSUDAN_ENEMY_DAMAGE_MULTIPLIER := 0.80
const BOSS_ATTACK_DAMAGE := 34
const STAGE_HAZARD_DAMAGE := 12
const REVIVE_HP := 20

static func apply_hit(context: Dictionary) -> Dictionary:
	var damage: int = maxi(1, int(context.get("damage", DEFAULT_CONTACT_DAMAGE)))
	if bool(context.get("zeroTauntResist", false)) and float(context.get("multiplier", 1.0)) >= 3.0:
		damage += LEGACY_HP_UNIT

	var hp: int = int(context.get("playerHp", 1)) - damage
	var burn_resist_charges: int = int(context.get("burnResistCharges", 0))
	var burn_combo: int = int(context.get("burnCombo", 0))
	if burn_resist_charges > 0:
		burn_resist_charges -= 1
	else:
		burn_combo = maxi(0, burn_combo - 1)

	var gift_hype: int = maxi(0, int(context.get("giftHype", 0)) - 10)
	var revive_available: bool = bool(context.get("reviveAvailable", false))
	var revived := false
	var invincible: float = float(context.get("baseInvincibleTime", 0.7))
	if hp <= 0 and revive_available:
		revive_available = false
		hp = REVIVE_HP
		invincible = 1.2
		revived = true

	return {
		"damage": damage,
		"playerHp": hp,
		"burnResistCharges": burn_resist_charges,
		"burnCombo": burn_combo,
		"giftHype": gift_hype,
		"reviveAvailable": revive_available,
		"revived": revived,
		"invincible": invincible,
		"activeCommentHurt": true
	}

static func source_damage(source: String, fallback: int = DEFAULT_CONTACT_DAMAGE) -> int:
	if source == "damage_pit" or source == "stopped moving" or source.contains("ダメージ床"):
		return STAGE_HAZARD_DAMAGE
	if source == "boss_bullet" or source == "boss_attack" or source.contains("boss_"):
		return BOSS_CONTACT_DAMAGE if source.ends_with(" contact") else BOSS_ATTACK_DAMAGE
	if source == "enemy bullet":
		return ENEMY_BULLET_DAMAGE
	if source.ends_with(" contact"):
		var kind := source.replace(" contact", "")
		if kind == "ghost_comment":
			return GHOST_CONTACT_DAMAGE
		if kind == "long_comment_guy" or kind == "clipper":
			return STRONG_CONTACT_DAMAGE
		if kind == "fast":
			return FAST_CONTACT_DAMAGE
		return DEFAULT_CONTACT_DAMAGE
	return fallback

static func apply_hit_to_target(target: Node, damage: int = DEFAULT_CONTACT_DAMAGE) -> Dictionary:
	var result: Dictionary = apply_hit({
		"playerHp": target.get("player_hp"),
		"damage": damage,
		"zeroTauntResist": target.get("zero_taunt_resist"),
		"multiplier": target.get("multiplier"),
		"burnResistCharges": target.get("burn_resist_charges"),
		"burnCombo": target.get("burn_combo"),
		"giftHype": target.get("gift_hype"),
		"reviveAvailable": target.get("revive_available"),
		"baseInvincibleTime": target.get("player_base_invincible_time")
	})
	target.set("player_hp", int(result["playerHp"]))
	target.set("burn_resist_charges", int(result["burnResistCharges"]))
	target.set("burn_combo", int(result["burnCombo"]))
	target.set("gift_hype", int(result["giftHype"]))
	target.set("revive_available", bool(result["reviveAvailable"]))
	target.set("active_comment_hurt", bool(result["activeCommentHurt"]))
	target.set("invincible", float(result["invincible"]))
	return result

static func apply_damage_for_target(target: Node, source_text: String, damage: int = DEFAULT_CONTACT_DAMAGE) -> Dictionary:
	if damage <= 0:
		return {"ignored": true, "revived": false, "dead": false, "chat": "", "deathReason": ""}
	if float(target.get("invincible")) > 0.0 or bool(target.get("debug_invincible")):
		return {"ignored": true, "revived": false, "dead": false, "chat": "", "deathReason": ""}
	target.set("last_death_source", source_text)
	var result: Dictionary = apply_hit_to_target(target, damage)
	var dead: bool = int(target.get("player_hp")) <= 0
	var death_text: String = ""
	if dead:
		death_text = death_reason(
			String(target.get("current_comment")),
			String(target.get("current_death_text")),
			source_text
		)
	return {
		"ignored": false,
		"revived": bool(result["revived"]),
		"dead": dead,
		"chat": "メンタル%dで復帰" % REVIVE_HP if bool(result["revived"]) else "",
		"deathReason": death_text
	}

static func apply_damage_source_for_target(target: Node, source: String, damage: int = -1, debug_enemy_id: String = "", debug_runtime_variant: String = "", debug_attack_type: String = "") -> Dictionary:
	var amount: int = source_damage(source) if damage < 0 else damage
	amount = _scale_enemy_damage_for_target(target, source, amount, debug_enemy_id, debug_runtime_variant, debug_attack_type)
	var shop_snapshot = target.get("permanent_upgrade_snapshot")
	if shop_snapshot != null and amount > 0:
		amount = PowerUpEffectProviderScript.constant_damage_taken(amount, shop_snapshot)
	if amount > 0 and target.has_method("_song_live_heat_damage_taken_multiplier"):
		amount = maxi(1, int(ceil(float(amount) * maxf(0.05, float(target.call("_song_live_heat_damage_taken_multiplier"))))))
	var damage_taken_multiplier := ModifierSystemScript.combined_multiplier_for_target(target, "playerDamageTaken")
	if amount > 0:
		amount = maxi(1, int(ceil(float(amount) * maxf(0.05, damage_taken_multiplier))))
	return apply_damage_for_target(target, DisplayTextSystem.damage_source_display(source), amount)

static func _scale_enemy_damage_for_target(target: Node, source: String, amount: int, debug_enemy_id: String = "", debug_runtime_variant: String = "", debug_attack_type: String = "") -> int:
	if amount <= 0:
		return 0
	if _is_non_enemy_damage_source(source):
		return amount
	var stage_id := String(target.get("current_stream_frame_id"))
	var is_boss_attack := source == "boss_bullet" or source == "boss_attack" or source.contains("boss_")
	var multiplier := RelayStageProfileSystemScript.damage_multiplier_for_target(target)
	var final_damage := calculate_enemy_damage(amount, stage_id, is_boss_attack, multiplier)
	var debug_payload := {
		"stageId": stage_id,
		"gameMode": "relay" if bool(target.get("relay_mode")) else "normal",
		"enemyId": debug_enemy_id if debug_enemy_id != "" else source.replace(" contact", ""),
		"runtimeVariant": debug_runtime_variant,
		"attackType": debug_attack_type if debug_attack_type != "" else _damage_attack_type(source),
		"baseDamage": amount,
		"stageDamageMultiplier": multiplier,
		"finalDamage": final_damage
	}
	if target.has_method("set"):
		target.set("balance_debug_damage_last", debug_payload)
		if bool(target.get("balance_debug_damage_logging")):
			print("[DamageBalance] %s" % debug_payload)
	return final_damage

static func calculate_enemy_damage(base_damage: int, stage_id: String, is_boss_attack: bool, stage_multiplier: float = DEFAULT_ZATSUDAN_ENEMY_DAMAGE_MULTIPLIER) -> int:
	if base_damage <= 0:
		return 0
	var multiplier := 1.0
	if stage_id == "zatsudan" and not is_boss_attack:
		multiplier = maxf(0.0, stage_multiplier)
	return maxi(1, roundi(float(base_damage) * multiplier))

static func _damage_attack_type(source: String) -> String:
	if source == "enemy bullet":
		return "projectile"
	if source.contains("dash"):
		return "dashContact"
	if source.contains("charge"):
		return "chargeContact"
	if source.contains("ambush"):
		return "ambushContact"
	if source.contains("warp"):
		return "warpContact"
	if source.ends_with(" contact"):
		return "contact"
	return "directSpecial"

static func _is_non_enemy_damage_source(source: String) -> bool:
	return source == "damage_pit" or source == "stopped moving" or source.contains("ダメージ床") or source == "boss_bullet" or source == "boss_attack" or source.contains("boss_")

static func apply_damage_sources_for_target(target: Node, sources: Array) -> Dictionary:
	var feedback: Dictionary = {"chats": [], "dead": false, "deathReason": "", "damaged": false}
	var chats: Array = feedback["chats"] as Array
	for source_item in sources:
		var source: String = String(source_item)
		var result: Dictionary = apply_damage_source_for_target(target, source, source_damage(source))
		if bool(result["ignored"]):
			continue
		feedback["damaged"] = true
		if bool(result["revived"]):
			chats.append(String(result["chat"]))
			continue
		if bool(result["dead"]):
			feedback["dead"] = true
			feedback["deathReason"] = String(result["deathReason"])
			return feedback
	return feedback

static func apply_damage_events_for_target(target: Node, damage_events: Array) -> Dictionary:
	var feedback: Dictionary = {"chats": [], "dead": false, "deathReason": "", "damaged": false}
	var chats: Array = feedback["chats"] as Array
	for item in damage_events:
		var event: Dictionary = item as Dictionary
		var source: String = String(event.get("source", "enemy"))
		var amount: int = int(event.get("damage", source_damage(source)))
		var result: Dictionary = apply_damage_source_for_target(
			target,
			source,
			amount,
			String(event.get("enemyId", "")),
			String(event.get("runtimeVariant", "")),
			String(event.get("attackType", ""))
		)
		if bool(result["ignored"]):
			continue
		feedback["damaged"] = true
		if bool(result["revived"]):
			chats.append(String(result["chat"]))
			continue
		if bool(result["dead"]):
			feedback["dead"] = true
			feedback["deathReason"] = String(result["deathReason"])
			return feedback
	return feedback

static func death_reason(current_comment: String, current_death_text: String, damage_source_text: String) -> String:
	if current_comment == "" or current_comment == "なし" or current_comment == "縺ｪ縺・":
		return "%sでやられた。指示コメは発動していなかった。" % damage_source_text
	return current_death_text
