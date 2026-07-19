class_name EnemyDrawSystem
extends RefCounted

const DrawDataSystemScript := preload("res://scripts/systems/draw_data_system.gd")
const DrawPrimitiveSystemScript := preload("res://scripts/systems/draw_primitive_system.gd")
const GameFontSystemScript := preload("res://scripts/systems/game_font_system.gd")
const TextureCacheSystemScript := preload("res://scripts/systems/texture_cache_system.gd")

static var enemy_texture_cache: Dictionary = {}

static func draw_enemies(target: CanvasItem, enemy_list: Array, visible_rect: Rect2 = Rect2()) -> void:
	var use_culling := visible_rect.size != Vector2.ZERO
	for enemy in enemy_list:
		var enemy_data: Dictionary = enemy as Dictionary
		if float(enemy_data.get("cutinVisualAlpha", 1.0)) <= 0.001:
			continue
		if use_culling and not visible_rect.has_point(Vector2(enemy_data.get("pos", Vector2.ZERO))):
			continue
		var enemy_draw: Dictionary = DrawDataSystemScript.enemy_draw_data(enemy_data)
		draw_red_pen_boss_attack_fx(target, enemy_data)
		draw_enemy_shot_warning(target, enemy_data)
		draw_collab_enemy_fx(target, enemy_data)
		for part in DrawDataSystemScript.enemy_draw_parts(enemy_draw):
			draw_enemy_part(target, part as Dictionary)
		if bool(enemy_data.get("syncStarCarrier", false)) and not bool(enemy_data.get("defeatResolved", false)):
			draw_sync_star_carrier(target, enemy_data)

static func draw_sync_star_carrier(target: CanvasItem, enemy: Dictionary) -> void:
	var pos := Vector2(enemy.get("pos", Vector2.ZERO))
	var radius := float(enemy.get("radius", 22.0))
	var clock := float(Time.get_ticks_msec()) / 1000.0
	var phase := float(enemy.get("syncStarCarrierWaveId", 0)) * 0.61
	var pulse := 0.5 + 0.5 * sin(clock * 4.5 + phase)
	var reveal := clampf(float(enemy.get("syncStarCarrierRevealTimer", 0.0)) / 0.45, 0.0, 1.0)
	var alpha := 1.0 - reveal * 0.18
	target.draw_circle(pos + Vector2(0.0, -radius - 25.0), 24.0 + pulse * 6.0, Color(1.0, 0.82, 0.28, 0.10 * alpha), true)
	target.draw_arc(pos + Vector2(0.0, -radius - 25.0), 25.0 + pulse * 4.0, clock * 1.8, clock * 1.8 + TAU * 0.82, 24, Color(1.0, 0.62, 0.84, 0.72 * alpha), 2.2, true)
	var icon_path := "res://assets/generated/field_pickup_icons_v1/icons/sync_star.png"
	var config_value: Variant = target.get("relay_mode_config") if target.has_method("get") else null
	if config_value is Dictionary:
		var boss_config: Dictionary = (config_value as Dictionary).get("boss", {}) as Dictionary
		var attacks: Dictionary = boss_config.get("attacks", {}) as Dictionary
		var sync_config: Dictionary = ((attacks.get("noise_summon", {}) as Dictionary).get("syncStar", {}) as Dictionary)
		icon_path = String(sync_config.get("iconPath", icon_path))
	var texture := TextureCacheSystemScript.load_png_texture(enemy_texture_cache, icon_path)
	if texture != null:
		var size := Vector2(36.0, 36.0) * (1.0 + reveal * 0.30)
		var icon_pos := pos + Vector2(-size.x * 0.5, -radius - 48.0 - size.y * 0.5)
		target.draw_texture_rect(texture, Rect2(icon_pos, size), false, Color(1.0, 1.0, 1.0, alpha))
	for i in range(4):
		var angle := clock * 1.5 + float(i) * TAU / 4.0
		var sparkle_pos := pos + Vector2(cos(angle) * (28.0 + pulse * 4.0), -radius - 25.0 + sin(angle) * (20.0 + pulse * 3.0))
		target.draw_circle(sparkle_pos, 2.0 + reveal * 3.0, Color(1.0, 0.92, 0.52, (0.52 + reveal * 0.40) * alpha))

static func draw_collab_enemy_fx(target: CanvasItem, enemy: Dictionary) -> void:
	var kind := String(enemy.get("kind", ""))
	if not kind.begins_with("collab_"):
		return
	var pos := Vector2(enemy.get("pos", Vector2.ZERO))
	var radius := float(enemy.get("radius", 22.0))
	var clock := float(Time.get_ticks_msec()) / 1000.0
	if kind == "collab_comparison_troll":
		var pulse := 0.5 + 0.5 * sin(clock * 6.0)
		target.draw_circle(pos, radius + 11.0 + pulse * 3.0, Color(0.98, 0.50, 0.66, 0.12), false, 2.0, true)
		target.draw_line(pos + Vector2(-7.0, -radius - 11.0), pos + Vector2(0.0, -radius - 4.0), Color("#d7567c"), 2.4, true)
		target.draw_line(pos + Vector2(0.0, -radius - 4.0), pos + Vector2(7.0, -radius - 11.0), Color("#d7567c"), 2.4, true)
	elif kind == "collab_messenger_pigeon":
		var warning := float(enemy.get("messengerWarningTimer", 0.0))
		if warning <= 0.0:
			return
		var target_pos := Vector2(enemy.get("messengerDashTarget", pos))
		var target_delta := target_pos - pos
		var dash_dir := target_delta.normalized()
		if dash_dir.length_squared() < 0.01:
			dash_dir = Vector2.RIGHT
		var side := Vector2(-dash_dir.y, dash_dir.x)
		var charge := 1.0 - clampf(warning / 0.55, 0.0, 1.0)
		var pulse := 0.72 + 0.28 * sin(clock * 16.0)
		var start := pos + dash_dir * (radius + 5.0)
		var line_length := clampf(target_delta.length() - radius * 0.35, 112.0, 210.0)
		var end := pos + dash_dir * line_length
		var tail_width := 5.0 + charge * 1.8
		var ribbon := PackedVector2Array([
			start + side * tail_width,
			start - side * tail_width,
			end - side * 0.7,
			end + side * 0.7
		])
		target.draw_colored_polygon(ribbon, Color(0.45, 0.28, 0.72, (0.10 + charge * 0.08) * pulse))
		for marker_index in range(5):
			var marker_t := fposmod(clock * (0.70 + charge * 0.45) + float(marker_index) * 0.19, 1.0)
			marker_t = 0.08 + marker_t * 0.78
			var marker_center := start.lerp(end, marker_t)
			var marker_half_length := 4.0 + charge * 1.8
			var marker_alpha := sin(marker_t * PI) * pulse
			var marker_from := marker_center - dash_dir * marker_half_length
			var marker_to := marker_center + dash_dir * marker_half_length
			target.draw_line(marker_from, marker_to, Color(0.16, 0.07, 0.25, marker_alpha * 0.58), 4.2, true)
			target.draw_line(marker_from, marker_to, Color(0.78, 0.68, 1.0, marker_alpha), 1.8, true)
		var arrow_base := end - dash_dir * (13.0 + charge * 3.0)
		var arrow_width := 6.0 + charge * 1.5
		target.draw_line(arrow_base + side * arrow_width, end, Color(0.18, 0.08, 0.28, pulse * 0.72), 4.8, true)
		target.draw_line(arrow_base - side * arrow_width, end, Color(0.18, 0.08, 0.28, pulse * 0.72), 4.8, true)
		target.draw_line(arrow_base + side * arrow_width, end, Color(0.88, 0.80, 1.0, pulse), 2.0, true)
		target.draw_line(arrow_base - side * arrow_width, end, Color(0.88, 0.80, 1.0, pulse), 2.0, true)
		var arc_rotation := clock * (3.4 + charge * 2.2)
		target.draw_arc(pos, radius + 8.0, arc_rotation, arc_rotation + PI * 0.68, 18, Color(0.82, 0.72, 1.0, pulse), 2.4, true)
		target.draw_arc(pos, radius + 8.0, arc_rotation + PI, arc_rotation + PI * 1.68, 18, Color(0.82, 0.72, 1.0, pulse), 2.4, true)
	elif kind == "collab_discord_troll":
		var pulse_warning := float(enemy.get("collabPulseWarningTimer", 0.0))
		if pulse_warning > 0.0:
			var pulse_alpha := 0.36 + 0.36 * sin(clock * 15.0)
			target.draw_circle(pos, 190.0, Color(0.84, 0.30, 0.72, pulse_alpha * 0.08), true)
			target.draw_circle(pos, 190.0, Color(0.82, 0.28, 0.69, pulse_alpha), false, 3.5, true)
	elif kind == "collab_volume_police":
		var field_warning := float(enemy.get("collabFieldWarningTimer", 0.0))
		if field_warning > 0.0:
			var field_alpha := 0.35 + 0.32 * sin(clock * 13.0)
			target.draw_circle(pos, 135.0, Color(0.46, 0.66, 1.0, field_alpha * 0.10), true)
			target.draw_circle(pos, 135.0, Color(0.56, 0.74, 1.0, field_alpha), false, 3.0, true)
	elif kind == "collab_exclusive_listener" and bool(enemy.get("collabPartnerAttached", false)):
		target.draw_circle(pos, radius + 7.0, Color(0.72, 0.39, 0.57, 0.24), false, 3.0, true)

static func draw_red_pen_boss_attack_fx(target: CanvasItem, enemy: Dictionary) -> void:
	if String(enemy.get("kind", "")) != "red_pen_review_chief":
		return
	var bullet_time := float(enemy.get("redPenBulletCastFx", 0.0))
	var line_time := float(enemy.get("redPenLineCastFx", 0.0))
	var summon_time := float(enemy.get("redPenSummonCastFx", 0.0))
	if bullet_time <= 0.0 and line_time <= 0.0 and summon_time <= 0.0:
		return
	var pos := Vector2(enemy.get("pos", Vector2.ZERO))
	var radius := float(enemy.get("radius", 100.0))
	var dir := Vector2(enemy.get("redPenCastDir", Vector2.RIGHT))
	if dir.length_squared() <= 0.01:
		dir = Vector2.RIGHT
	dir = dir.normalized()
	var side := Vector2(-dir.y, dir.x)
	var clock := float(Time.get_ticks_msec()) / 1000.0
	if bullet_time > 0.0:
		var max_time := maxf(0.01, float(enemy.get("redPenBulletCastFxMax", 0.36)))
		var ratio := clampf(bullet_time / max_time, 0.0, 1.0)
		var burst := sin((1.0 - ratio) * PI)
		target.draw_circle(pos, radius * (1.04 + burst * 0.18), Color(1.0, 0.08, 0.18, 0.18 * ratio), false, 7.0, true)
		for i in range(5):
			var spread := (float(i) - 2.0) * 0.16
			var shot_dir := dir.rotated(spread)
			var start := pos + shot_dir * radius * 0.42
			var end := pos + shot_dir * radius * (1.10 + burst * 0.42)
			target.draw_line(start, end, Color(0.24, 0.01, 0.04, 0.48 * ratio), 7.0, true)
			target.draw_line(start, end, Color(1.0, 0.12, 0.22, 0.70 * ratio), 3.2, true)
			if i % 2 == 0:
				target.draw_circle(end, 3.0 + burst * 2.0, Color(1.0, 0.72, 0.76, 0.72 * ratio))
	if line_time > 0.0:
		var max_time := maxf(0.01, float(enemy.get("redPenLineCastFxMax", 0.76)))
		var ratio := clampf(line_time / max_time, 0.0, 1.0)
		var progress := 1.0 - ratio
		var pulse := 0.5 + 0.5 * sin(clock * 18.0)
		target.draw_circle(pos, radius * (1.08 + progress * 0.30), Color(0.30, 0.01, 0.05, 0.32 * ratio), false, 10.0, true)
		target.draw_circle(pos, radius * (0.88 + pulse * 0.08), Color(1.0, 0.10, 0.18, 0.46 * ratio), false, 4.0, true)
		for i in range(4):
			var angle := clock * 1.6 + float(i) * TAU / 4.0
			var mark_pos := pos + Vector2(cos(angle), sin(angle)) * radius * (0.72 + progress * 0.22)
			var mark_side := Vector2(-sin(angle), cos(angle))
			target.draw_line(mark_pos - mark_side * 10.0, mark_pos + mark_side * 10.0, Color(1.0, 0.78, 0.80, 0.68 * ratio), 3.0, true)
			target.draw_line(mark_pos - Vector2(5.0, 5.0), mark_pos + Vector2(5.0, 5.0), Color(1.0, 0.12, 0.22, 0.72 * ratio), 2.2, true)
	if summon_time > 0.0:
		var max_time := maxf(0.01, float(enemy.get("redPenSummonCastFxMax", 0.85)))
		var ratio := clampf(summon_time / max_time, 0.0, 1.0)
		var progress := 1.0 - ratio
		var burst := sin(progress * PI)
		target.draw_circle(pos, radius * (0.92 + burst * 0.26), Color(1.0, 0.34, 0.48, 0.18 * ratio))
		target.draw_circle(pos, radius * (1.02 + progress * 0.34), Color(1.0, 0.78, 0.82, 0.46 * ratio), false, 4.0, true)
		for i in range(6):
			var angle := -clock * 1.25 + float(i) * TAU / 6.0
			var note_pos := pos + Vector2(cos(angle), sin(angle)) * radius * (0.68 + burst * 0.30)
			var note_size := 5.0 + float(i % 2) * 2.0
			target.draw_circle(note_pos, note_size + 2.0, Color(0.24, 0.01, 0.05, 0.34 * ratio))
			target.draw_circle(note_pos, note_size, Color(1.0, 0.18, 0.30, 0.72 * ratio))
			target.draw_line(note_pos - side * note_size * 0.55, note_pos + side * note_size * 0.55, Color(1.0, 0.92, 0.92, 0.72 * ratio), 1.6, true)

static func draw_enemy_shot_warning(target: CanvasItem, enemy: Dictionary) -> void:
	var timer := float(enemy.get("shotWarningTimer", 0.0))
	if timer <= 0.0:
		return
	var duration := maxf(0.01, float(enemy.get("shotWarningDuration", timer)))
	var ratio := clampf(1.0 - timer / duration, 0.0, 1.0)
	var pos := Vector2(enemy.get("pos", Vector2.ZERO))
	var radius := float(enemy.get("radius", 24.0)) + lerpf(18.0, 7.0, ratio)
	var alpha := 0.35 + 0.35 * sin(ratio * PI)
	target.draw_circle(pos, radius + 2.0, Color(0.04, 0.02, 0.03, 0.24 * alpha), false, 5.0, true)
	target.draw_circle(pos, radius, Color(1.0, 0.16, 0.24, 0.72 * alpha), false, 3.0, true)
	target.draw_circle(pos, radius - 4.0, Color(1.0, 1.0, 1.0, 0.36 * alpha), false, 1.5, true)
	var dir := Vector2(enemy.get("shotWarningDir", Vector2.ZERO))
	if dir.length() <= 0.1:
		return
	dir = dir.normalized()
	var start := pos + dir * (radius + 5.0)
	var end := pos + dir * (radius + 48.0)
	target.draw_line(start, end, Color(0.05, 0.02, 0.03, 0.32 * alpha), 5.0, true)
	target.draw_line(start, end, Color(1.0, 0.20, 0.28, 0.66 * alpha), 2.5, true)

static func draw_enemy_part(target: CanvasItem, part: Dictionary) -> void:
	var kind: String = String(part["kind"])
	if kind == "shadow":
		var shadow: Dictionary = part["data"] as Dictionary
		DrawPrimitiveSystemScript.draw_shadow(target, shadow["pos"] as Vector2, shadow["size"] as Vector2, float(shadow["alpha"]))
	elif kind == "body":
		draw_enemy_body(target, part["data"] as Dictionary)
	elif kind == "face":
		draw_enemy_face(target, part["data"] as Dictionary)
	elif kind == "bar":
		draw_enemy_hp_bar(target, part["data"] as Dictionary)
	elif kind == "speech":
		DrawPrimitiveSystemScript.draw_speech_bubble(target, part["data"] as Dictionary)
	elif kind == "linked_troll_speech":
		draw_linked_troll_speech(target, part["data"] as Dictionary)

static func draw_linked_troll_speech(target: CanvasItem, bubble: Dictionary) -> void:
	if bubble.is_empty():
		return
	var rect: Rect2 = bubble["rect"] as Rect2
	var tail: PackedVector2Array = bubble["tail"] as PackedVector2Array
	var fill: Color = bubble["fill"] as Color
	var border: Color = bubble["border"] as Color
	target.draw_colored_polygon(tail, fill)
	target.draw_rect(rect, fill, true)
	target.draw_rect(rect, border, false, int(bubble["borderWidth"]))
	if tail.size() >= 3:
		target.draw_line(tail[0], tail[2], border, float(bubble["borderWidth"]), true)
		target.draw_line(tail[1], tail[2], border, float(bubble["borderWidth"]), true)
	var warning_pos: Vector2 = bubble["warningPos"] as Vector2
	target.draw_circle(warning_pos, float(bubble["warningRadius"]) + 1.2, Color(0.35, 0.05, 0.14, (bubble["warningFill"] as Color).a * 0.52))
	target.draw_circle(warning_pos, float(bubble["warningRadius"]), bubble["warningFill"] as Color)
	target.draw_string(GameFontSystemScript.font_for_item(bubble), bubble["warningTextPos"] as Vector2, "!", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, bubble["warningTextColor"] as Color)
	var text_item := {
		"text": String(bubble["text"]),
		"pos": bubble["textPos"] as Vector2,
		"width": int(bubble["textWidth"]),
		"size": int(bubble["textSize"]),
		"color": bubble["textColor"] as Color
	}
	for offset in [Vector2(-0.8, 0.0), Vector2(0.8, 0.0), Vector2(0.0, -0.8), Vector2(0.0, 0.8)]:
		var outline_item: Dictionary = text_item.duplicate()
		outline_item["pos"] = (text_item["pos"] as Vector2) + offset
		outline_item["color"] = bubble["outlineColor"] as Color
		DrawPrimitiveSystemScript.draw_multiline_text_item(target, outline_item)
	DrawPrimitiveSystemScript.draw_multiline_text_item(target, text_item)

static func draw_enemy_body(target: CanvasItem, body: Dictionary) -> void:
	for part in DrawDataSystemScript.enemy_body_parts(body):
		var draw_part: Dictionary = part as Dictionary
		if String(draw_part["kind"]) == "sprite":
			draw_enemy_sprite(target, body)
		else:
			DrawPrimitiveSystemScript.draw_simple_draw_part(target, body, draw_part)

static func draw_enemy_sprite(target: CanvasItem, body: Dictionary) -> void:
	var path: String = String(body.get("texturePath", ""))
	if path == "":
		return
	var texture: Texture2D = TextureCacheSystemScript.load_png_texture(enemy_texture_cache, path)
	if texture == null:
		return
	if bool(body.get("relayBossTransformed", false)) and target.has_method("_draw_relay_boss_sprite"):
		target.call("_draw_relay_boss_sprite", texture, body)
		return
	# Enemy sprites are already positioned in world coordinates by DrawDataSystem.
	# Keep the draw call in that coordinate space; a temporary CanvasItem transform
	# makes the boss image drift toward the viewport corner in this draw path.
	target.draw_texture_rect(texture, body["rect"] as Rect2, false, body.get("modulate", Color.WHITE) as Color)

static func draw_enemy_face(target: CanvasItem, face: Dictionary) -> void:
	for part in DrawDataSystemScript.enemy_face_parts():
		DrawPrimitiveSystemScript.draw_simple_draw_part(target, face, part as Dictionary)

static func draw_enemy_hp_bar(target: CanvasItem, bar: Dictionary) -> void:
	for part in DrawDataSystemScript.enemy_hp_bar_parts():
		DrawPrimitiveSystemScript.draw_simple_draw_part(target, bar, part as Dictionary)
