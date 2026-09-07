extends Node

const DrawData = preload("res://scripts/systems/draw_data_system.gd")
var failures: Array[String] = []

func _ready() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var weapons: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/weapons.json"))
	var climax := WeaponSystem.find_weapon(weapons, "fansa_climax", {})
	var visuals: Dictionary = climax.visuals
	for direction in [Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN, Vector2(1,-1).normalized()]:
		var main_fx := _fx("fansa_climax_hit", visuals, direction, 0.26, 0.26)
		var x_fx := _fx("fansa_climax_x", visuals, direction, 0.30, 0.30)
		var snapshot := var_to_bytes([main_fx, x_fx])
		var main := _draw(main_fx)
		var x := _draw(x_fx)
		_check(var_to_bytes([main_fx, x_fx]) == snapshot, "draw mutated runtime FX / visuals")
		_check(_draw(main_fx) == main, "repeated draws compounded support attenuation")
		_check(_layer(main,"finisher").size == Vector2(226,210), "fan size changed")
		_check(is_equal_approx(float(_layer(main,"finisher").alpha),0.22), "fan is not a secondary accent")
		_check(_layer(x,"xSlash").size == Vector2(214,206), "X size changed")
		_check(is_equal_approx(float(_layer(x,"xSlash").alpha),1.0), "X immediate peak / alpha changed")
		_check((_layer(x,"xSlash").pos as Vector2).is_equal_approx(Vector2(400,400)+direction*85.0), "X anchor changed")
		_check((_layer(main,"finisher").pos as Vector2).is_equal_approx(Vector2(400,400)+direction*94.0), "fan anchor changed")
		_check(main.fanArcPoints == x.fanArcPoints, "main / X attack geometry changed")
		_check(is_equal_approx(float(x.fanRadius),180.0) and is_equal_approx(float(x.fanArcDegrees),180.0), "attack boundary no longer represents the full range")
		_check(_arc_count(main) == 0 and _arc_count(x) == 2, "finisher has duplicated visible boundaries (one line + glow expected)")
		_check(is_equal_approx(float(x.fanArcWidth),2.0) and is_equal_approx(float(x.fanArcGlowWidth),6.0), "boundary line is not subordinate")
		for role in ["batonBodyLeft","batonBodyRight","batonGlowLeft","batonGlowRight"]:
			_check(not _layer(main,role).is_empty(), "baton layer removed: "+role)
		_check(float(_layer(main,"finisherBg").alpha) < 0.15, "background competes with X")
		_check(float(_layer(main,"confetti").alpha) > 0.0 and float(_layer(main,"confetti").alpha) < 0.3, "confetti is not retained as a light accent")

	var late := _draw(_fx("fansa_climax_hit", visuals, Vector2.RIGHT,0.13,0.26))
	_check(is_zero_approx(float(_layer(late,"finisher").alpha)), "fan accent did not finish within 0.12s")
	_check(float(_layer(late,"confetti").alpha)>0.0, "support retirement removed all afterglow")
	var late_x := _draw(_fx("fansa_climax_x",visuals,Vector2.RIGHT,0.17,0.30))
	_check(is_equal_approx(float(_layer(late_x,"xSlash").alpha),0.17/0.30), "X natural lifetime changed")

	var wave_fx := {"kind":"fansa_climax_fan_wave","pos":Vector2(400,400),"radius":105.0,"life":0.28,"maxLife":0.28,"visuals":visuals}
	var wave := _draw(wave_fx)
	_check(bool(wave.get("fieldLayer",false)), "wave does not use the existing field pass")
	_check(_layer(wave,"wave").pos == Vector2(400,400) and _layer(wave,"wave").size == Vector2(220,220), "wave geometry changed")
	_check(is_equal_approx(float(_layer(wave,"wave").alpha),0.92*0.23), "wave not subordinated")
	_check(DrawData.hit_fx_procedural_parts(wave,{"wave":true},{}).is_empty(), "field wave introduces a procedural duplicate")
	wave_fx.visuals = {}
	_check(not DrawData.hit_fx_procedural_parts(_draw(wave_fx),{},{}).is_empty(), "wave missing-image fallback removed")

	# Steps 1/2 and base baton continue through the unmodified shared composer.
	for step in [0,1]:
		var fx := _fx("fansa_climax_hit",visuals,Vector2.RIGHT,0.18,0.18)
		fx.comboStep = step
		var actual := _draw(fx)
		var expected := DrawData.fansa_baton_fx_data(fx.pos,fx.dir,step,fx.life,fx.maxLife,180.0,180.0,visuals,"",1,fx.attackOrigin,180.0,180.0,true)
		expected.kind = "fansa_climax_hit"
		_check(actual == expected, "climax step %d changed" % (step+1))
	var baton := WeaponSystem.find_weapon(weapons,"fansa_baton",{})
	for step in [0,1,2]:
		var fx := _fx("fansa_baton_hit",baton.visuals,Vector2.RIGHT,0.24,0.24)
		fx.comboStep = step
		var data := _draw(fx)
		_check(_arc_count(data)==2 and not data.has("showFanArc"),"base baton boundary changed")
		var role: String = "swingRight" if step==0 else ("swingLeft" if step==1 else "finisher")
		_check(float(_layer(data,role).get("alpha",0.0))>0.22,"base baton accent was reduced")
	if failures.is_empty():
		print("FANSA_CLIMAX_FINISHER_ROLES: PASS")
		get_tree().quit(0)
	else:
		for failure in failures: push_error(failure)
		get_tree().quit(1)

func _fx(kind: String, visuals: Dictionary, direction: Vector2, life: float, max_life: float) -> Dictionary:
	return {"kind":kind,"pos":Vector2(400,400),"dir":direction,"attackOrigin":Vector2(400,400)+direction*25.0,"origin":Vector2(400,400)+direction*25.0,"comboStep":2,"range":180.0,"arcAngle":180.0,"life":life,"maxLife":max_life,"visuals":visuals}

func _draw(fx: Dictionary) -> Dictionary:
	return DrawData.hit_fx_draw_data([fx])[0]

func _layer(data: Dictionary, role: String) -> Dictionary:
	for layer in data.get("imageLayers",[]):
		if String(layer.get("role","")) == role: return layer
	return {}

func _arc_count(data: Dictionary) -> int:
	var count := 0
	for part in DrawData.hit_fx_parts(data):
		if String(part.get("pointsKey","")) == "fanArcPoints": count += 1
	return count

func _check(condition: bool, message: String) -> void:
	if not condition: failures.append(message)
