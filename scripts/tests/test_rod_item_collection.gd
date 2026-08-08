extends Node

func _ready() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var failures: Array[String] = []
	var weapons: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/weapons.json")) as Array
	var rod := WeaponSystem.find_weapon(weapons, "tsuri_thumbnail_rod", {})
	var buzz := WeaponSystem.find_weapon(weapons, "buzz_thumbnail_rod", {})
	_check(not rod.is_empty() and not buzz.is_empty(), "rod registries are missing", failures)

	var expected_radii := [150.0, 150.0, 190.0, 220.0, 260.0]
	var expected_speeds := [550.0, 550.0, 675.0, 775.0, 900.0]
	for index in range(expected_radii.size()):
		var config := WeaponSystem.rod_collection_config_for_level(rod, index + 1)
		_check(is_equal_approx(float(config.get("attractRadius", 0.0)), expected_radii[index]), "tsuri Lv%d radius" % (index + 1), failures)
		_check(is_equal_approx(float(config.get("attractSpeed", 0.0)), expected_speeds[index]), "tsuri Lv%d speed" % (index + 1), failures)
	_check(is_equal_approx(float(WeaponSystem.rod_collection_config_for_level(buzz, 1).get("attractRadius", 0.0)), 360.0), "buzz collection radius", failures)
	_check(is_equal_approx(float(WeaponSystem.rod_collection_config_for_level(buzz, 1).get("attractSpeed", 0.0)), 1200.0), "buzz collection speed", failures)
	var short_context := {"shortRange": true, "shortRangeRate": 1.0}
	_check(is_equal_approx(WeaponSystem._rod_collection_radius(WeaponSystem.rod_collection_config_for_level(rod, 1), short_context), 112.5), "short range changed the wrong collection value", failures)
	var base_level_five := WeaponSystem._stage2_level_data(rod, 5)
	var weapon_context := {"weaponData": [rod, buzz]}
	_check(is_equal_approx(WeaponSystem.rod_collection_effective_return_speed(base_level_five, weapon_context), 1800.0), "Lv5 collection return speed was double-counted or missing", failures)
	_check(is_equal_approx(WeaponSystem.rod_collection_effective_return_speed(buzz, weapon_context), 2100.0), "evolved collection return speed did not use Lv5 baseline x1.40", failures)
	_check(is_equal_approx(float(WeaponSystem.rod_collection_config_for_level(rod, 1).get("returnCatchupRate", 0.0)), 1.35), "rod catch-up rate is missing", failures)

	# Casting begins at the player's position. The one-shot search must remain
	# pending until the lure reaches its actual landing point.
	var player_side_orb := {"pos": Vector2(10, 0), "value": 1, "life": 20.0}
	var landing_orb := {"pos": Vector2(230, 0), "value": 1, "life": 20.0}
	var landing_test_orbs: Array = [player_side_orb, landing_orb]
	var landing_fx := {
		"pos": Vector2.ZERO, "phase": "casting", "itemCollectionConfig": WeaponSystem.rod_collection_config_for_level(rod, 1),
		"itemAttractRadius": 150.0, "collectionClaimToken": "tsuri:landing:test",
		"itemSearchDone": false, "claimedCollectibles": []
	}
	WeaponSystem._rod_claim_collectibles_at_landing(landing_fx, landing_test_orbs, [])
	_check(not bool(landing_fx.get("itemSearchDone", false)), "casting consumed the landing-point item search", failures)
	_check((landing_fx.get("claimedCollectibles", []) as Array).is_empty(), "casting claimed an item around the player", failures)
	landing_fx["phase"] = "gathering"
	landing_fx["pos"] = Vector2(200, 0)
	WeaponSystem._rod_claim_collectibles_at_landing(landing_fx, landing_test_orbs, [])
	_check(bool(landing_fx.get("itemSearchDone", false)), "landing did not consume the item search", failures)
	_check((landing_fx.get("claimedCollectibles", []) as Array).size() == 1, "landing did not claim only the nearby item", failures)
	_check(String(landing_orb.get("rodCollectionState", "")) == "attracted_to_lure", "landing-point item was not attracted", failures)
	_check(String(player_side_orb.get("rodCollectionState", "free")) == "free", "player-side item was claimed instead of landing-point item", failures)
	WeaponSystem._rod_release_claimed_collectibles(landing_fx)

	var orb := {"pos": Vector2(50, 0), "value": 3, "life": 20.0}
	var score_drop := {"id": "viewer_boost", "pos": Vector2(40, 0), "life": 12.0}
	var heal_drop := {"id": "heal_drink", "pos": Vector2(30, 0), "life": 12.0}
	var heart_drop := {"id": "heart_drop", "pos": Vector2(20, 0), "life": 12.0}
	var excluded_song := {"id": "song_live_gift", "pos": Vector2(10, 0), "life": 12.0}
	var excluded_star := {"id": "collab_sync_star", "pos": Vector2(10, 0), "life": 12.0}
	var unknown := {"id": "future_unknown", "pos": Vector2(10, 0), "life": 12.0}
	var exp_orbs: Array = [orb]
	var drops: Array = [score_drop, heal_drop, heart_drop, excluded_song, excluded_star, unknown]
	var config := WeaponSystem.rod_collection_config_for_level(rod, 1)
	var fx := {
		"pos": Vector2.ZERO, "phase": "gathering", "itemCollectionConfig": config,
		"itemAttractRadius": 100.0, "collectionClaimToken": "tsuri:collect:1",
		"itemSearchDone": false, "claimedCollectibles": []
	}
	WeaponSystem._rod_claim_collectibles_at_landing(fx, exp_orbs, drops)
	_check((fx.get("claimedCollectibles", []) as Array).size() == 4, "only whitelisted collectibles were claimed", failures)
	_check(String(orb.get("rodCollectionState", "")) == "attracted_to_lure", "EXP orb claim state", failures)
	var guarded_result := ExpSystem.update_orbs({"orbs": exp_orbs, "playerPos": Vector2.ZERO, "magnetRange": 100.0, "magnetSpeedRate": 1.0, "delta": 1.0})
	_check((guarded_result.get("orbs", []) as Array).size() == 1 and int(guarded_result.get("collectedCount", 0)) == 0, "normal EXP pickup moved or collected a claimed orb", failures)
	_check(String(excluded_song.get("rodCollectionState", "free")) == "free", "song gift was incorrectly claimed", failures)
	_check(String(excluded_star.get("rodCollectionState", "free")) == "free", "collab star was incorrectly claimed", failures)
	_check(WeaponSystem._rod_collectible_type("drop_items", excluded_star) == "", "collab star mapped to a normal star", failures)

	# A second cast cannot take an item already owned by the first token.
	var second_fx := fx.duplicate(true)
	second_fx["collectionClaimToken"] = "tsuri:collect:2"
	second_fx["itemSearchDone"] = false
	second_fx["claimedCollectibles"] = []
	WeaponSystem._rod_claim_collectibles_at_landing(second_fx, exp_orbs, drops)
	_check((second_fx.get("claimedCollectibles", []) as Array).is_empty(), "a second cast stole a claimed item", failures)

	WeaponSystem._rod_update_claimed_collectibles(fx, 0.10, Vector2.ZERO)
	_check(Vector2(orb.get("pos", Vector2.ZERO)).x < 50.0, "claimed item did not move toward lure", failures)
	fx["phase"] = "reeling"
	fx["pos"] = Vector2.ZERO
	WeaponSystem._rod_update_claimed_collectibles(fx, 0.01, Vector2.ZERO)
	_check(String(orb.get("rodCollectionState", "")) == "homing_to_player", "return did not hand item to normal pickup", failures)
	_check(String(orb.get("rodClaimToken", "")) == "", "claim token remained after return", failures)

	# Every EXP orb inside the landing radius is claimed independently. The
	# visual line cap must not limit collection, and all values must survive the
	# hand-off to the normal pickup route.
	var bulk_orbs: Array = []
	var expected_bulk_exp := 0
	for index in range(12):
		var value := index + 1
		expected_bulk_exp += value
		bulk_orbs.append({"pos": Vector2(-30.0 + float(index) * 5.0, 12.0), "value": value, "life": 20.0})
	var bulk_fx := {
		"pos": Vector2.ZERO, "phase": "gathering", "itemCollectionConfig": config,
		"itemAttractRadius": 150.0, "collectionClaimToken": "tsuri:collect:bulk",
		"itemSearchDone": false, "claimedCollectibles": [], "reelSpeed": 1250.0,
		"collectionLines": [], "collectionParticles": []
	}
	WeaponSystem._rod_claim_collectibles_at_landing(bulk_fx, bulk_orbs, [])
	_check((bulk_fx.get("claimedCollectibles", []) as Array).size() == bulk_orbs.size(), "landing did not claim every EXP orb", failures)
	bulk_fx["phase"] = "reeling"
	WeaponSystem._rod_update_claimed_collectibles(bulk_fx, 0.01, Vector2.ZERO)
	_check((bulk_fx.get("claimedCollectibles", []) as Array).is_empty(), "bulk EXP claims remained after reel hand-off", failures)
	var bulk_pickup := ExpSystem.update_orbs({"orbs": bulk_orbs, "playerPos": Vector2.ZERO, "magnetRange": 100.0, "magnetSpeedRate": 1.0, "delta": 0.01})
	_check(int(bulk_pickup.get("collectedCount", 0)) == bulk_orbs.size(), "not every reeled EXP orb reached normal pickup", failures)
	_check(int(bulk_pickup.get("collectedExp", 0)) == expected_bulk_exp, "reeled EXP value was lost", failures)

	# An already attached item remains locked to the lure instead of falling
	# behind when the lure starts moving.
	var attached_orb := {"pos": Vector2.ZERO, "value": 1, "life": 20.0, "rodCollectionState": "attached_to_lure", "rodClaimToken": "tsuri:attached"}
	var attached_fx := {
		"pos": Vector2(80, 0), "phase": "reeling", "itemCollectionConfig": config,
		"collectionClaimToken": "tsuri:attached", "itemReturnSpeed": 1250.0, "reelSpeed": 1250.0,
		"claimedCollectibles": [{"item": attached_orb, "scatterOffset": Vector2(9, 0)}],
		"collectionLines": [], "collectionParticles": []
	}
	WeaponSystem._rod_update_claimed_collectibles(attached_fx, 0.01, Vector2.ZERO)
	_check(String(attached_orb.get("rodCollectionState", "")) == "attached_to_lure", "attached EXP was detached during reel", failures)
	_check(Vector2(attached_orb.get("pos", Vector2.ZERO)).is_equal_approx(Vector2(89, 0)), "attached EXP did not stay on the moving lure", failures)

	# The reel endpoint follows the player's latest position, not its old snapshot.
	var tracking_fx := {
		"phase": "reeling", "pos": Vector2.ZERO, "previousPos": Vector2.ZERO,
		"reelDestination": Vector2(-100, 0), "reelSpeed": 100.0, "life": 2.0,
		"targetReference": {}, "pathHitEnemyIds": {}, "pathHitBoxIds": {},
		"collisionHitEnemyIds": {}, "collisionEnabled": false
	}
	WeaponSystem.update_tsuri_rod_fx(tracking_fx, 0.10, [], [], [], [], [], {"barrierHitRequests": [], "weaponSeRequests": []}, Vector2(100, 0))
	_check(Vector2(tracking_fx.get("reelDestination", Vector2.ZERO)).is_equal_approx(Vector2(100, 0)), "reel destination did not follow the player", failures)
	_check(Vector2(tracking_fx.get("pos", Vector2.ZERO)).x > 0.0, "lure kept moving toward the stale reel destination", failures)

	# Buzz has extra gathering/throwing phases and finishes by expiring its cast
	# FX. Its own reel endpoint must hand every claimed orb to normal pickup before
	# the generic zero-life cleanup runs.
	var buzz_orbs: Array = []
	var expected_buzz_exp := 0
	for index in range(16):
		var value := index + 1
		expected_buzz_exp += value
		buzz_orbs.append({"pos": Vector2(180.0 + float(index % 4) * 12.0, -18.0 + float(index / 4) * 12.0), "value": value, "life": 20.0})
	var buzz_config := WeaponSystem.rod_collection_config_for_level(buzz, 1)
	var buzz_fx := {
		"kind": "buzz_thumbnail_rod_cast", "weaponId": "buzz_thumbnail_rod",
		"pos": Vector2(200, 0), "phase": "gathering", "itemCollectionConfig": buzz_config,
		"itemAttractRadius": 360.0, "collectionClaimToken": "buzz:collect:bulk",
		"itemSearchDone": false, "claimedCollectibles": [], "collectionLines": [], "collectionParticles": [],
		"itemReturnSpeed": 2100.0, "reelSpeed": 1250.0, "reelDestination": Vector2(-200, 0),
		"targetReference": {}, "targetToken": "", "life": 10.0, "maxLife": 10.0
	}
	WeaponSystem._rod_claim_collectibles_at_landing(buzz_fx, buzz_orbs, [])
	_check((buzz_fx.get("claimedCollectibles", []) as Array).size() == buzz_orbs.size(), "buzz did not claim every landing-point EXP orb", failures)
	buzz_fx["phase"] = "reeling"
	WeaponSystem.update_buzz_thumbnail_rod_fx(buzz_fx, 1.0, [], [], [], {"barrierHitRequests": []}, Vector2.ZERO)
	_check(is_equal_approx(float(buzz_fx.get("life", 1.0)), 0.0), "buzz reel did not complete", failures)
	_check(bool(buzz_fx.get("collectionReturned", false)), "buzz reel endpoint did not complete the item hand-off", failures)
	_check((buzz_fx.get("claimedCollectibles", []) as Array).is_empty(), "buzz claims remained after reel completion", failures)
	var buzz_pickup := ExpSystem.update_orbs({"orbs": buzz_orbs, "playerPos": Vector2.ZERO, "magnetRange": 100.0, "magnetSpeedRate": 1.0, "delta": 0.01})
	_check(int(buzz_pickup.get("collectedCount", 0)) == buzz_orbs.size(), "buzz did not return every EXP orb", failures)
	_check(int(buzz_pickup.get("collectedExp", 0)) == expected_buzz_exp, "buzz lost EXP value during return", failures)

	# Forced cleanup releases an in-flight claim without awarding anything.
	var cleanup_item := {"pos": Vector2(60, 0), "value": 1, "life": 20.0}
	var cleanup_orbs: Array = [cleanup_item]
	var cleanup_fx := {
		"pos": Vector2.ZERO, "phase": "gathering", "itemCollectionConfig": config,
		"itemAttractRadius": 100.0, "collectionClaimToken": "tsuri:collect:3",
		"itemSearchDone": false, "claimedCollectibles": []
	}
	WeaponSystem._rod_claim_collectibles_at_landing(cleanup_fx, cleanup_orbs, [])
	WeaponSystem._rod_release_claimed_collectibles(cleanup_fx)
	_check(String(cleanup_item.get("rodCollectionState", "")) == "free", "forced cleanup did not release claim", failures)
	_check(not cleanup_item.has("rodClaimToken"), "forced cleanup left claim token", failures)

	if failures.is_empty():
		print("Rod item collection tests passed")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	get_tree().quit(1)

func _check(condition: bool, message: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(message)
