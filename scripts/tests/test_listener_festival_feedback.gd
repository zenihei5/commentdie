extends Node

const Weapons := preload("res://scripts/systems/weapon_system.gd")
const Settings := preload("res://scripts/systems/settings_system.gd")

class FeedbackGame:
	extends "res://scripts/game.gd"
	var test_usec := 0
	var listener_starts := 0
	var explosion_starts := 0
	var hit_starts := 0
	func _listener_assembly_se_time_usec() -> int:
		return test_usec
	func _play_listener_attack_se_once_per_frame() -> void:
		var prior := listener_attack_se_played_frame
		super._play_listener_attack_se_once_per_frame()
		if listener_attack_se_played_frame != prior and listener_attack_se_player != null and listener_attack_se_player.playing:
			listener_starts += 1
	func _play_emote_mine_explosion_se() -> void:
		super._play_emote_mine_explosion_se()
		if emote_mine_explosion_se_player != null and emote_mine_explosion_se_player.playing:
			explosion_starts += 1
	func _play_enemy_damage_se_once_per_frame() -> void:
		var prior := enemy_damage_se_played_frame
		super._play_enemy_damage_se_once_per_frame()
		if enemy_damage_se_played_frame != prior:
			hit_starts += 1

var failures: Array[String] = []
var evidence: Dictionary = {}
var game: FeedbackGame

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	game = FeedbackGame.new()
	game.quick_test_mode = true
	add_child(game)
	game.set_process(false)
	await get_tree().process_frame
	for child in game.get_children():
		if child is AudioStreamPlayer: child.stop()
	_test_listener_event_isolation()
	await _test_listener_audio_gate()
	await _test_normal_and_assembly_coalescence()
	_test_festival_main_and_chain()
	_test_normal_mine()
	await _test_feedback_delivery()
	await _test_retry()
	evidence["failures"] = failures
	evidence["engine"] = Engine.get_version_info()
	evidence["driver"] = AudioServer.get_driver_name()
	print("LISTENER_FESTIVAL_FEEDBACK_EVIDENCE=" + JSON.stringify(evidence))
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--evidence="):
			var output := FileAccess.open(argument.trim_prefix("--evidence="), FileAccess.WRITE)
			if output != null: output.store_string(JSON.stringify(evidence,"  "))
	game.queue_free()
	await get_tree().process_frame
	if failures.is_empty():
		print("LISTENER_FESTIVAL_FEEDBACK: PASS")
	else:
		for failure in failures: push_error(failure)
	get_tree().quit(0 if failures.is_empty() else 1)

func _test_listener_event_isolation() -> void:
	for evolved in [false,true]:
		var id := "listener_assembly" if evolved else "listener_summon"
		var enemy := _enemy(1,Vector2(20,0))
		var feedback: Dictionary = {}
		var hits: Array = []
		var units: Array = []
		for serial in range(4):
			var unit := {"kind":id,"owner":id,"weaponId":id,"pos":Vector2.ZERO,"dir":Vector2.RIGHT,"life":8.0,"maxLife":8.0,"moveSpeed":195.0,"searchRange":680.0,"hitRadius":18.0,"hitTimer":0.0,"hitCooldown":0.70,"damage":12.0,"knockback":0.0,"unitSerial":serial+1}
			units.append(unit)
		hits = Weapons.update_hit_fx(units,0.0,[enemy],[],[],[],[],feedback)
		for unit in units:
			_check(is_equal_approx(float(unit.hitTimer),0.70),id+" attack cooldown changed")
		_check(is_equal_approx(float(enemy.hp),952.0),id+" did not retain four independent hits")
		_check(_count_fx(hits,"listener_burst")==4,id+" lost an attack effect")
		_check(bool(feedback.get("listenerAssemblyAttacked",false))==evolved,id+" used the wrong assembly feedback flag")
		_check(bool(feedback.get("listenerSummonAttacked",false))!=evolved,id+" used the wrong base feedback flag")
		evidence[id+"Events"]={"attacks":4,"damage":1000.0-float(enemy.hp),"feedback":feedback}

func _test_listener_audio_gate() -> void:
	game.listener_assembly_se_last_started_usec=-1
	game.listener_attack_se_played_frame=-1
	game.listener_starts=0
	var rows: Array=[]
	var stream_id:=game.listener_attack_se_player.stream.get_instance_id()
	for usec in [0,100000,399999,400000,700000,799999,800000,900000]:
		await get_tree().process_frame
		game.test_usec=usec
		var prior:=game.listener_starts
		var prior_position:=game.listener_attack_se_player.get_playback_position()
		game._apply_hit_reaction_feedback({"listenerAssemblyAttacked":true})
		var started:=game.listener_starts>prior
		_check(started==(usec in [0,400000,800000]),"assembly gate boundary mismatch at "+str(usec))
		_check(game.listener_attack_se_player.playing,"assembly gate stopped a playing SE")
		_check(game.listener_attack_se_player.stream.get_instance_id()==stream_id,"assembly gate replaced the stream")
		if not started:
			_check(game.listener_attack_se_player.get_playback_position()>=prior_position-0.001,"suppressed assembly feedback rewound the stream")
		rows.append({"usec":usec,"started":started,"playing":game.listener_attack_se_player.playing,"streamId":stream_id,"position":game.listener_attack_se_player.get_playback_position()})
	_check(game.listener_starts==3,"assembly gate did not start three sounds")
	_check(game.listener_attack_se_player.bus==&"Master","listener output bus changed")
	_check(is_equal_approx(game.listener_attack_se_player.volume_db,Settings.volume_db_from_percent(game.se_volume)),"listener SE volume setting was lost")
	_check(is_equal_approx(game.listener_attack_se_player.pitch_scale,1.0),"listener pitch changed")
	evidence["gate"]={"minimumSeconds":game.LISTENER_ASSEMBLY_SE_MIN_INTERVAL,"rows":rows,"starts":game.listener_starts,"bus":game.listener_attack_se_player.bus,"volumeDb":game.listener_attack_se_player.volume_db}

func _test_normal_and_assembly_coalescence() -> void:
	var prior:=game.listener_starts
	for index in range(5):
		await get_tree().process_frame
		game.test_usec=900000+index*1000
		game._apply_hit_reaction_feedback({"listenerSummonAttacked":true})
	_check(game.listener_starts-prior==5,"normal listener inherited assembly cooldown")
	await get_tree().process_frame
	game.test_usec=2000000
	prior=game.listener_starts
	var last:=game.listener_assembly_se_last_started_usec
	game._apply_hit_reaction_feedback({"listenerSummonAttacked":true,"listenerAssemblyAttacked":true})
	_check(game.listener_starts==prior+1,"same-frame normal/assembly feedback replayed twice")
	_check(game.listener_assembly_se_last_started_usec==last,"coalesced request incorrectly consumed assembly cooldown")
	await get_tree().process_frame
	game._apply_hit_reaction_feedback({"listenerAssemblyAttacked":true})
	_check(game.listener_starts==prior+2,"coalesced feedback blocked next assembly event")
	var stream:=game.listener_attack_se_player.stream
	game.listener_attack_se_player.stream=null
	game.test_usec=3000000
	last=game.listener_assembly_se_last_started_usec
	game._apply_hit_reaction_feedback({"listenerAssemblyAttacked":true})
	_check(game.listener_assembly_se_last_started_usec==last,"missing stream consumed cooldown")
	game.listener_attack_se_player.stream=stream
	evidence["normalIsolation"]={"normalStartsForFiveEvents":5,"sameFrameCoalesced":true,"missingStreamDoesNotReserve":true}

func _test_festival_main_and_chain() -> void:
	var main:=_mine("main",Vector2.ZERO)
	var chain_a:=_mine("chain_a",Vector2(100,0))
	var chain_b:=_mine("chain_b",Vector2(160,0))
	var all_fx: Array=[main,chain_a,chain_b]
	var enemies: Array=[_enemy(2,Vector2(20,0)),_enemy(3,Vector2(30,0)),_enemy(4,Vector2(40,0))]
	var bullets: Array=[{"pos":Vector2(30,0),"life":1.0,"hitRadius":4.0},{"pos":Vector2(40,0),"life":1.0,"hitRadius":4.0},{"pos":Vector2(45,0),"life":1.0,"hitRadius":4.0,"redPenTelegraphPending":true}]
	var feedback: Dictionary={}
	var effects: Array=[]
	Weapons.update_emote_festival_mine_damage(main,enemies,[],bullets,[],[],effects,all_fx,feedback)
	_check(int(feedback.get("emoteFestivalMainBurstCount",0))==1,"main burst did not emit exactly one explosion request")
	_check(not feedback.get("emoteMineExploded",false),"festival used the normal mine notification")
	_check(enemies.all(func(e:Dictionary)->bool:return is_equal_approx(float(e.hp),982.0)),"festival multi-target damage changed")
	_check(float(bullets[0].life)<=0 and float(bullets[1].life)<=0 and float(bullets[2].life)>0,"festival bullet clear/warning rules changed")
	_check(bool(chain_a.chainQueued) and bool(chain_b.chainQueued),"main did not queue both chains")
	Weapons.update_emote_festival_mine_damage(main,enemies,[],bullets,[],[],effects,all_fx,feedback)
	_check(int(feedback.get("emoteFestivalMainBurstCount",0))==1,"same main burst emitted twice")
	for chain in [chain_a,chain_b]:
		Weapons.update_emote_festival_mine_damage(chain,enemies,[],bullets,[],[],effects,all_fx,feedback)
	_check(int(feedback.get("emoteFestivalMainBurstCount",0))==1,"chain emitted a main explosion SE")
	_check(_count_fx(effects,"emote_festival_burst")==3,"chain explosion count changed")
	_check(bool(feedback.get("enemyDamaged",false)),"common hit feedback was lost")
	var merged: Dictionary={}
	Weapons._merge_reaction_result(merged,feedback)
	Weapons._merge_reaction_result(merged,{"emoteFestivalMainBurstCount":1})
	_check(int(merged.get("emoteFestivalMainBurstCount",0))==2,"independent main bursts collapsed into a bool")
	evidence["festivalChain"]={"mainBursts":1,"chainBursts":2,"enemyHits":3,"clearedBullets":2,"explosionRequests":feedback.get("emoteFestivalMainBurstCount",0),"mergedIndependentRequests":merged.get("emoteFestivalMainBurstCount",0)}

func _test_normal_mine() -> void:
	var mine:=_mine("normal",Vector2.ZERO)
	mine.kind="emote_mine"
	mine.weaponId="emote_mine"
	var feedback: Dictionary={}
	var effects: Array=[]
	Weapons.update_emote_mine_damage(mine,[_enemy(8,Vector2(20,0))],[],[],[],[],effects,feedback)
	_check(bool(feedback.get("emoteMineExploded",false)),"normal mine explosion feedback changed")
	_check(not feedback.has("emoteFestivalMainBurstCount"),"normal mine acquired evolved explosion feedback")
	_check(_count_fx(effects,"emote_burst")==1,"normal mine explosion FX changed")

func _test_feedback_delivery() -> void:
	await get_tree().process_frame
	var prior:=game.explosion_starts
	var hit_prior:=game.hit_starts
	var stream_id:=game.emote_mine_explosion_se_player.stream.get_instance_id()
	game._apply_hit_reaction_feedback({"emoteFestivalMainBurstCount":1,"enemyDamaged":true})
	_check(game.explosion_starts==prior+1 and game.hit_starts==hit_prior+1,"main explosion audio/common hit did not both start")
	game._apply_hit_reaction_feedback({"emoteFestivalMainBurstCount":0})
	_check(game.explosion_starts==prior+1,"zero/chain notification replayed explosion")
	game._apply_hit_reaction_feedback({"emoteFestivalMainBurstCount":2})
	_check(game.explosion_starts==prior+3,"two independent main notifications did not each call the existing SE path")
	game._apply_hit_reaction_feedback({"emoteMineExploded":true})
	_check(game.explosion_starts==prior+4,"normal mine audio delivery changed")
	_check(game.emote_mine_explosion_se_player.playing and game.emote_mine_explosion_se_player.stream.get_instance_id()==stream_id,"festival did not reuse the existing explosion stream")
	_check(is_equal_approx(game.emote_mine_explosion_se_player.volume_db,Settings.volume_db_from_percent(game.se_volume)),"festival explosion volume changed")
	evidence["audioDelivery"]={"explosionStarts":game.explosion_starts-prior,"commonHitStarts":game.hit_starts-hit_prior,"streamId":stream_id,"playing":game.emote_mine_explosion_se_player.playing,"path":game.EMOTE_MINE_EXPLOSION_SE_PATH}

func _test_retry() -> void:
	game.listener_assembly_se_last_started_usec=game.test_usec
	game._restart()
	_check(game.listener_assembly_se_last_started_usec==-1,"retry retained assembly cooldown")
	await get_tree().process_frame
	var prior:=game.listener_starts
	game._apply_hit_reaction_feedback({"listenerAssemblyAttacked":true})
	_check(game.listener_starts==prior+1,"retry's first assembly feedback was suppressed")

func _enemy(uid:int,pos:Vector2) -> Dictionary:
	return {"kind":"test_enemy","uid":uid,"spawnToken":"feedback_test:"+str(uid),"pos":pos,"hp":1000.0,"max_hp":1000.0,"radius":20.0,"canBeKnockedBack":true,"damageTakenRate":1.0}

func _mine(serial:String,pos:Vector2) -> Dictionary:
	return {"kind":"emote_festival_mine","owner":"emote_festival","weaponId":"emote_festival","mineSerial":serial,"pos":pos,"life":12.0,"maxLife":12.0,"damage":18.0,"radius":160.0,"triggerRadius":60.0,"chainRadius":260.0,"chainDamageCoefficient":0.70,"chainDelay":0.01,"chainQueued":false,"chainTriggered":false,"exploded":false,"knockback":0.0}

func _count_fx(items:Array,kind:String) -> int:
	var count:=0
	for item in items:
		if String(item.get("kind",""))==kind: count+=1
	return count

func _check(condition:bool,message:String) -> void:
	if not condition: failures.append(message)
