extends RefCounted
class_name CollabChallengeSystem

const PROFILE_STANDARD := "standard"
const PROFILE_HIGH := "high"
const PROFILE_HEART_HIGH := "heart_high"

static func normalize_profile(value: Variant) -> String:
	match String(value).strip_edges().to_lower():
		PROFILE_HIGH:
			return PROFILE_HIGH
		PROFILE_HEART_HIGH:
			return PROFILE_HEART_HIGH
	return PROFILE_STANDARD

static func profile_for_comment(comment_id: String, params: Dictionary = {}) -> String:
	if comment_id != "dont_fail_collab":
		return PROFILE_STANDARD
	var configured := normalize_profile(params.get("challengeProfile", PROFILE_HIGH))
	return PROFILE_HIGH if configured == PROFILE_STANDARD else configured

static func challenge_parameters(challenge_type: String, profile: Variant = PROFILE_STANDARD) -> Dictionary:
	var normalized := normalize_profile(profile)
	var high := normalized != PROFILE_STANDARD
	var heart_high := normalized == PROFILE_HEART_HIGH
	match challenge_type:
		"collab_chain":
			return {"required": 4, "duration": 14.0 if heart_high else 12.0}
		"comment_catch":
			return {
				"required": 5,
				"spawn": 7,
				"duration": 9.0 if heart_high else (8.0 if high else 10.0),
				"pickupRadius": 48.0 if heart_high else 42.0
			}
		"dash_sync":
			return {
				"required": 3 if high else 2,
				"duration": 9.0 if heart_high else 8.0,
				"inputWindow": 0.48 if heart_high else (0.40 if high else 0.60)
			}
		"thumbnail_time":
			return {
				"required": 3 if high else 2,
				"duration": 9.0 if heart_high else 8.0,
				"maxSpeed": 32.0 if heart_high else 28.0,
				"maxDistance": 10.0 if heart_high else 8.0
			}
		"troll_focus":
			return {
				"duration": 9.0 if heart_high else (8.0 if high else 10.0),
				"hp": 36.0 if heart_high else (40.0 if high else 32.0),
				"speed": 48.0,
				"contactDamage": 5
			}
		"line_defense":
			return {
				"duration": 9.0 if heart_high else 10.0,
				"successTerminalHp": 60.0 if heart_high else (70.0 if high else 50.0),
				"terminalHp": 100.0,
				"initialEnemies": 3,
				"maxEnemies": 6,
				"replenishInterval": 1.65 if high else 2.2,
				"enemyHp": 18.0,
				"enemySpeed": 62.0,
				"terminalDamageInterval": 1.0,
				"terminalDamage": 10.0
			}
	return {"duration": 8.0, "required": 1}

static func line_defense_replenish_count(active_count: int, max_enemies: int) -> int:
	return mini(maxi(0, active_count) + 1, maxi(0, max_enemies))
