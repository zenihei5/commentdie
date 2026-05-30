extends RefCounted
class_name ScoreSystem

static func genre_score_rate(streaming_skill_level: int) -> float:
	return 1.0 + 0.1 * float(streaming_skill_level)

static func race_bonus(base_score: int, streaming_skill_level: int) -> int:
	return int(float(base_score) * genre_score_rate(streaming_skill_level))

static func exp_collect_bonus(like_score_level: int, collected_count: int) -> int:
	return like_score_level * 6 * collected_count

static func enemy_score(enemy: Dictionary, context: Dictionary) -> int:
	var multiplier: float = float(context.get("multiplier", 1.0))
	var burn_combo: int = int(context.get("burnCombo", 0))
	var gift_bonus: float = 1.0
	if multiplier >= 3.0 and int(context.get("clipBonusLevel", 0)) > 0:
		gift_bonus += 0.15 * float(context.get("clipBonusLevel", 0))
	if bool(context.get("flameMarketing", false)):
		gift_bonus += 0.30
	if bool(context.get("clipConfirmed", false)) and multiplier >= 3.0:
		gift_bonus += 0.40
	if bool(context.get("zeroTauntResist", false)) and multiplier >= 3.0:
		gift_bonus += 0.60
	if bool(context.get("genreActive", false)):
		gift_bonus *= genre_score_rate(int(context.get("streamingSkillLevel", 0)))
	var combo_bonus: float = 1.0 + float(burn_combo) * 0.1
	var passive_rate: float = float(context.get("passiveScoreRate", 1.0))
	return int(float(enemy["score"]) * multiplier * combo_bonus * gift_bonus * passive_rate)

static func enemy_score_for_target(target: Node, enemy: Dictionary) -> int:
	return enemy_score(enemy, {
		"multiplier": target.get("multiplier"),
		"burnCombo": target.get("burn_combo"),
		"clipBonusLevel": target.get("clip_bonus_level"),
		"flameMarketing": target.get("flame_marketing"),
		"clipConfirmed": target.get("clip_confirmed"),
		"zeroTauntResist": target.get("zero_taunt_resist"),
		"genreActive": String(target.get("active_genre_event")) != "",
		"streamingSkillLevel": target.get("streaming_skill_level"),
		"passiveScoreRate": target.get("passive_score_rate")
	})
