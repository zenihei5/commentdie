class_name DrawDataSystem
extends RefCounted

static func title_center() -> Vector2:
	return Vector2(600, 390)

static func title_panel_rect() -> Rect2:
	return Rect2(Vector2(245, 225), Vector2(710, 330))

static func character_select_panel_rect() -> Rect2:
	return Rect2(Vector2(92, 96), Vector2(1040, 660))

static func stream_frame_select_panel_rect() -> Rect2:
	return Rect2(Vector2(165, 145), Vector2(890, 530))

static func character_card_rect(panel: Rect2, index: int) -> Rect2:
	var card_w := 300.0
	var gap := 28.0
	return Rect2(panel.position + Vector2(34 + index * (card_w + gap), 92), Vector2(card_w, 520))

static func stream_frame_card_rect(panel: Rect2, index: int) -> Rect2:
	return Rect2(panel.position + Vector2(42 + index * 420, 112), Vector2(380, 340))

static func selection_panel_fill() -> Color:
	return Color(0.025, 0.023, 0.04, 0.92)

static func selection_panel_border() -> Color:
	return Color("#8e36e8")

static func selection_card_fill() -> Color:
	return Color("#11131c")

static func selection_card_border(selected: bool) -> Color:
	return Color("#fff45c") if selected else Color("#49305f")

static func title_panel_data() -> Dictionary:
	return {
		"rect": title_panel_rect(),
		"fill": Color(0.03, 0.03, 0.06, 0.84),
		"border": selection_panel_border()
	}

static func selection_header_data(panel: Rect2, help_offset: Vector2) -> Dictionary:
	return {
		"titlePos": panel.position + Vector2(38, 58),
		"titleColor": Color("#fff45c"),
		"helpPos": panel.position + help_offset,
		"helpColor": Color("#cfc7ff")
	}

static func character_card_layout(card: Rect2, tex_size: Vector2) -> Dictionary:
	var scale: float = 0.0
	var tex_rect: Rect2 = Rect2()
	if tex_size.x > 0.0 and tex_size.y > 0.0:
		scale = minf(170.0 / tex_size.x, 245.0 / tex_size.y)
		tex_rect = Rect2(card.position + Vector2((card.size.x - tex_size.x * scale) * 0.5, 62), tex_size * scale)
	var text_x: float = card.position.x + 22
	var text_w: int = int(card.size.x - 44)
	return {
		"titlePos": card.position + Vector2(22, 42),
		"titleWidth": text_w,
		"textureRect": tex_rect,
		"rolePos": Vector2(text_x, card.position.y + 332),
		"weaponPos": Vector2(text_x, card.position.y + 362),
		"passivePos": Vector2(text_x, card.position.y + 392),
		"descriptionPos": Vector2(text_x, card.position.y + 428),
		"textWidth": text_w,
		"roleColor": Color("#8df7ff"),
		"descriptionColor": Color("#dcd7ff")
	}

static func stream_frame_card_layout(card: Rect2) -> Dictionary:
	var text_w: int = int(card.size.x - 48)
	return {
		"titlePos": card.position + Vector2(24, 50),
		"titleWidth": text_w,
		"descriptionPos": card.position + Vector2(24, 105),
		"difficultyPos": card.position + Vector2(24, 178),
		"featuresPos": card.position + Vector2(24, 222),
		"textWidth": text_w,
		"descriptionColor": Color("#f3f0ff"),
		"difficultyColor": Color("#fff45c"),
		"featuresColor": Color("#8df7ff")
	}

static func arena_base_color() -> Color:
	return Color("#6f5728")

static func arena_tiles(arena: Rect2) -> Array:
	var tiles: Array = []
	for y in range(9):
		for x in range(14):
			var tile: Rect2 = Rect2(arena.position + Vector2(float(x) * 86.0, float(y) * 86.0), Vector2(84, 84))
			var shade: Color = Color(0.50, 0.38, 0.15, 0.18) if (x + y) % 2 == 0 else Color(0.90, 0.68, 0.22, 0.10)
			tiles.append({"rect": tile, "color": shade})
	return tiles

static func arena_rocks(arena: Rect2) -> Array:
	var rocks: Array = []
	for i in range(110):
		var pos: Vector2 = Vector2(arena.position.x + fmod(float(i * 137), arena.size.x), arena.position.y + fmod(float(i * 83), arena.size.y))
		var color: Color = Color(0.20, 0.17, 0.14, 0.20) if i % 3 == 0 else Color(0.95, 0.68, 0.20, 0.18)
		rocks.append({"pos": pos, "radius": 3.0 + float(i % 5), "color": color})
	return rocks

static func arena_sparks(arena: Rect2) -> Array:
	var sparks: Array = []
	for i in range(18):
		var pos: Vector2 = Vector2(arena.position.x + fmod(float(i * 221), arena.size.x), arena.position.y + fmod(float(i * 151), arena.size.y))
		sparks.append({"pos": pos, "size": 5.0 + float(i % 3), "color": Color(1.0, 0.92, 0.25, 0.28)})
	return sparks

static func banana_floor_data(arena: Rect2) -> Dictionary:
	var bananas: Array = []
	for i in range(28):
		bananas.append({"pos": Vector2(80 + fmod(float(i * 97), 1050.0), 80 + fmod(float(i * 59), 640.0))})
	return {
		"overlayRect": arena,
		"overlayColor": Color(1.0, 0.83, 0.08, 0.18),
		"bananas": bananas,
		"bananaColor": Color("#ffe24c")
	}

static func static_wall_rects() -> Array:
	return [Rect2(310, 310, 210, 32), Rect2(320, 700, 260, 28), Rect2(840, 480, 210, 32)]

static func arena_wall_data(rect: Rect2, temporary: bool) -> Dictionary:
	var top_height: float = 6.0 if temporary else 7.0
	return {
		"rect": rect,
		"shadowPos": rect.get_center() + (Vector2(7, 14) if temporary else Vector2(8, 16)),
		"shadowSize": Vector2(rect.size.x, 22 if temporary else 24),
		"shadowAlpha": 0.2 if temporary else 0.18,
		"fillColor": Color("#7b6f7f") if temporary else Color("#746d75"),
		"topRect": Rect2(rect.position, Vector2(rect.size.x, top_height)),
		"topColor": Color("#c0a5d8") if temporary else Color("#aaa1ad"),
		"borderColor": Color("#241b2f") if temporary else Color("#2a2730"),
		"borderWidth": 4 if temporary else 3,
		"seamColor": Color("#4a434e")
	}

static func pit_draw_data(pos: Vector2, radius: float) -> Dictionary:
	return {
		"pos": pos,
		"radius": radius,
		"outerColor": Color("#241019"),
		"innerRadius": radius * 0.65,
		"innerColor": Color(1.0, 0.25, 0.37, 0.34)
	}

static func arena_edge_shades(arena: Rect2) -> Array:
	return [
		{"rect": Rect2(arena.position, Vector2(arena.size.x, 38)), "color": Color(0.03, 0.02, 0.04, 0.18)},
		{"rect": Rect2(Vector2(arena.position.x, arena.end.y - 44), Vector2(arena.size.x, 44)), "color": Color(0.02, 0.015, 0.025, 0.16)},
		{"rect": Rect2(arena.position, Vector2(44, arena.size.y)), "color": Color(0.02, 0.015, 0.025, 0.13)},
		{"rect": Rect2(Vector2(arena.end.x - 44, arena.position.y), Vector2(44, arena.size.y)), "color": Color(0.02, 0.015, 0.025, 0.13)}
	]

static func arena_border_color() -> Color:
	return Color("#34234d")

static func comment_storm_style(setting: int, kuso_active: bool) -> Dictionary:
	var amount: int = 22
	var alpha: float = 0.42
	if setting == 0:
		amount = 11
		alpha = 0.30
	elif setting == 2:
		amount = 34
		alpha = 0.55
	if kuso_active:
		amount = int(float(amount) * 1.5)
		alpha = minf(0.72, alpha + 0.18)
	return {"amount": amount, "alpha": alpha}

static func comment_storm_position(arena: Rect2, elapsed: float, index: int) -> Vector2:
	var x: float = fposmod(elapsed * (55.0 + float(index % 5) * 16.0) + float(index * 127), arena.size.x + 260.0) + arena.position.x - 160.0
	var y: float = arena.position.y + 42.0 + fposmod(float(index * 53), arena.size.y - 84.0)
	return Vector2(x, y)

static func zoom_mask_data(outer: Rect2) -> Dictionary:
	var center: Vector2 = outer.get_center()
	var inner_size: Vector2 = outer.size * 0.72
	var inner: Rect2 = Rect2(center - inner_size * 0.5, inner_size)
	return {
		"inner": inner,
		"shades": [
			Rect2(outer.position, Vector2(outer.size.x, inner.position.y - outer.position.y)),
			Rect2(Vector2(outer.position.x, inner.end.y), Vector2(outer.size.x, outer.end.y - inner.end.y)),
			Rect2(Vector2(outer.position.x, inner.position.y), Vector2(inner.position.x - outer.position.x, inner.size.y)),
			Rect2(Vector2(inner.end.x, inner.position.y), Vector2(outer.end.x - inner.end.x, inner.size.y))
		]
	}

static func horror_mask_data(elapsed: float) -> Dictionary:
	var pulse: float = 0.5 + sin(elapsed * 5.0) * 0.5
	return {
		"shade": Color(0.0, 0.0, 0.0, 0.32),
		"pulse": Color(0.25, 0.0, 0.12, 0.08 + pulse * 0.05),
		"titleColor": Color(1.0, 0.78, 0.88, 0.85)
	}

static func metric_panel_style(rect: Rect2, accent: Color) -> Dictionary:
	return {
		"rect": rect,
		"fill": Color("#11131c"),
		"border": Color("#49305f"),
		"accentRect": Rect2(rect.position, Vector2(5, rect.size.y)),
		"accent": accent,
		"labelPos": rect.position + Vector2(14, 20),
		"valuePos": rect.position + Vector2(14, 48),
		"valueWidth": int(rect.size.x - 22)
	}

static func hud_frame_data(side: Rect2, hud: Rect2) -> Dictionary:
	return {
		"sideRect": side,
		"sideFill": Color("#080910"),
		"sideBorder": Color("#8e36e8"),
		"sideDividerStart": Vector2(side.position.x + 20, side.position.y + 48),
		"sideDividerEnd": Vector2(side.end.x - 20, side.position.y + 48),
		"sideDividerColor": Color("#6f627e"),
		"viewerPos": Vector2(1450, 143),
		"hudRect": hud,
		"hudFill": Color("#080910"),
		"hudBorder": Color("#49305f")
	}

static func hud_metric_specs(comment_alert: bool) -> Array:
	var comment_color: Color = Color("#ff4b68") if comment_alert else Color("#8df7ff")
	return [
		{"key": "hp", "rect": Rect2(34, 806, 154, 58), "label": "HP", "accent": Color("#ff4b68")},
		{"key": "time", "rect": Rect2(200, 806, 160, 58), "label": "残り", "accent": Color("#fff45c")},
		{"key": "multiplier", "rect": Rect2(372, 806, 156, 58), "label": "倍率", "accent": Color("#b768ff")},
		{"key": "burn", "rect": Rect2(540, 806, 156, 58), "label": "炎上", "accent": Color("#ff8a31")},
		{"key": "hype", "rect": Rect2(708, 806, 210, 58), "label": "期待度", "accent": Color("#ff5a78")},
		{"key": "ng", "rect": Rect2(930, 806, 70, 58), "label": "NG", "accent": Color("#8df7ff")},
		{"key": "heart", "rect": Rect2(1008, 806, 66, 58), "label": "♡", "accent": Color("#ff91c8")},
		{"key": "nextComment", "rect": Rect2(1086, 806, 150, 58), "label": "次コメ", "accent": comment_color},
		{"key": "currentComment", "rect": Rect2(1248, 806, 308, 58), "label": "現在", "accent": Color("#f3f0ff")}
	]

static func hud_gauge_data(exp_ratio: float, hype_ratio: float) -> Array:
	return [
		{
			"label": "EXP",
			"backRect": Rect2(Vector2(34, 872), Vector2(360, 6)),
			"fillRect": Rect2(Vector2(34, 872), Vector2(360 * exp_ratio, 6)),
			"backColor": Color("#203047"),
			"fillColor": Color("#24a8ff"),
			"labelPos": Vector2(34, 888),
			"labelColor": Color("#7cdcff")
		},
		{
			"label": "ギフト期待度",
			"backRect": Rect2(Vector2(430, 872), Vector2(260, 6)),
			"fillRect": Rect2(Vector2(430, 872), Vector2(260 * hype_ratio, 6)),
			"backColor": Color("#40202a"),
			"fillColor": Color("#ff5a78"),
			"labelPos": Vector2(430, 888),
			"labelColor": Color("#ff91aa")
		}
	]

static func comment_countdown_data(left: float, interval: float, elapsed_time: float) -> Dictionary:
	var ratio: float = clampf(left / interval, 0.0, 1.0)
	var alert: bool = left <= 5.0
	var rect: Rect2 = Rect2(Vector2(450, 118), Vector2(520, 54))
	var pulse: float = 0.5 + sin(elapsed_time * 12.0) * 0.5
	var border: Color = Color("#ff4b68") if alert else Color("#8df7ff")
	var progress_color: Color = Color("#ff4b68") if alert else Color("#8df7ff")
	return {
		"rect": rect,
		"ratio": ratio,
		"alert": alert,
		"fill": Color(0.16, 0.02, 0.04, 0.92) if alert else Color(0.02, 0.04, 0.07, 0.84),
		"border": border.lightened(0.25 * pulse) if alert else border,
		"progressRect": Rect2(rect.position + Vector2(18, 38), Vector2((rect.size.x - 36.0) * ratio, 7)),
		"progressColor": progress_color,
		"titlePos": rect.position + Vector2(22, 26),
		"valuePos": rect.position + Vector2(350, 31),
		"warningPos": rect.position + Vector2(172, 29),
		"valueColor": Color("#fff45c") if alert else Color("#8df7ff"),
		"warningColor": Color("#ff4b68")
	}

static func choice_backplate_data() -> Dictionary:
	var rect: Rect2 = Rect2(Vector2(430, 126), Vector2(790, 365))
	return {
		"rect": rect,
		"fill": Color(0.02, 0.02, 0.04, 0.48),
		"border": Color("#5b2b88")
	}

static func tutorial_overlay_data() -> Dictionary:
	return {
		"rect": Rect2(Vector2(230, 150), Vector2(760, 560)),
		"fill": Color(0.02, 0.02, 0.04, 0.95),
		"border": Color("#8df7ff")
	}

static func toast_data(text: String) -> Dictionary:
	var rect := Rect2(Vector2(440, 655), Vector2(700, 72))
	var border := Color("#8df7ff")
	if text.contains("クソマロ") or text.contains("ブロック"):
		border = Color("#ff4b68")
	return {
		"rect": rect,
		"fill": Color(0.04, 0.035, 0.06, 0.88),
		"border": border,
		"textPos": rect.position + Vector2(22, 45),
		"textWidth": int(rect.size.x - 44),
		"fontSize": 28
	}

static func fallback_player_color(character_id: String, invincible: bool) -> Color:
	if invincible:
		return Color.WHITE
	if character_id == "superchat_chan":
		return Color("#ffca4f")
	if character_id == "maro_chan":
		return Color("#ffb6d8")
	return Color("#8d54ff")

static func fallback_player_draw_data(pos: Vector2, character_id: String, invincible: bool) -> Dictionary:
	var color: Color = fallback_player_color(character_id, invincible)
	return {
		"shadowPos": pos + Vector2(0, 28),
		"shadowSize": Vector2(58, 18),
		"shadowAlpha": 0.30,
		"backPos": pos + Vector2(0, 7),
		"backRadius": 24.0,
		"backColor": Color("#2b2136"),
		"bodyPos": pos,
		"bodyRadius": 25.0,
		"bodyColor": color,
		"facePos": pos + Vector2(0, -3),
		"faceRadius": 20.0,
		"faceColor": Color("#251a2e"),
		"liveBackRect": Rect2(pos + Vector2(-28, -40), Vector2(56, 18)),
		"liveBackColor": Color("#14121c"),
		"liveRect": Rect2(pos + Vector2(-23, -37), Vector2(46, 12)),
		"liveColor": Color("#7037d5"),
		"liveTextPos": pos + Vector2(-18, -27),
		"liveTextColor": Color("#fff45c"),
		"eyeColor": Color("#f7f0ff"),
		"eyeDotColor": Color.BLACK,
		"rightEye": pos + Vector2(7, -6),
		"leftEye": pos + Vector2(-7, -6),
		"eyeRadius": 4.0,
		"eyeDotRadius": 2.0,
		"mouthCenter": pos + Vector2(0, 5),
		"mouthColor": Color("#f6d5ff"),
		"micLineStart": pos + Vector2(-25, -7),
		"micLineEnd": pos + Vector2(-36, -2),
		"micLineColor": Color("#343044"),
		"micPos": pos + Vector2(-39, -1),
		"micRadius": 8.0,
		"micColor": Color("#6b47cf"),
		"hammerLineStart": pos + Vector2(19, 10),
		"hammerLineEnd": pos + Vector2(70, -15),
		"hammerLineColor": Color("#3a2430"),
		"hammerCoreStart": pos + Vector2(22, 8),
		"hammerCoreEnd": pos + Vector2(70, -17),
		"hammerCoreColor": Color("#ffc431"),
		"hammerBackPos": pos + Vector2(79, -20),
		"hammerBackRadius": 24.0,
		"hammerBackColor": Color("#3a2028"),
		"hammerPos": pos + Vector2(78, -18),
		"hammerRadius": 21.0,
		"hammerColor": Color("#d73327"),
		"banTextPos": pos + Vector2(61, -13),
		"banTextColor": Color("#2b1016")
	}

static func invincible_label_data(pos: Vector2) -> Dictionary:
	return {
		"pos": pos + Vector2(-35, 45),
		"color": Color("#fff45c")
	}

static func enemy_color(kind: String) -> Color:
	if kind == "shooter":
		return Color("#3498ff")
	if kind == "long_comment_guy":
		return Color("#7d6f5a")
	if kind == "clipper":
		return Color("#e0522f")
	if kind == "unread_maro":
		return Color("#f8f1ff")
	if kind == "ghost_comment":
		return Color(0.72, 0.88, 1.0, 0.68)
	return Color("#7650bd")

static func enemy_shadow_data(pos: Vector2, radius: float) -> Dictionary:
	return {
		"pos": pos + Vector2(0, radius * 0.72),
		"size": Vector2(radius * 2.15, radius * 0.7),
		"alpha": 0.25
	}

static func enemy_body_data(kind: String, pos: Vector2, radius: float, color: Color) -> Dictionary:
	if kind == "long_comment_guy":
		var body: Rect2 = Rect2(pos - Vector2(radius * 1.35, radius * 0.65), Vector2(radius * 2.7, radius * 1.3))
		return {
			"kind": "long",
			"rect": body,
			"shadowRect": body.grow(4),
			"shadowColor": Color("#241d18"),
			"color": color,
			"topRect": Rect2(body.position, Vector2(body.size.x, 8)),
			"topColor": Color("#a29273")
		}
	if kind == "clipper":
		var cam: Rect2 = Rect2(pos - Vector2(radius * 1.0, radius * 0.72), Vector2(radius * 2.0, radius * 1.44))
		return {
			"kind": "clipper",
			"rect": cam,
			"shadowRect": cam.grow(4),
			"shadowColor": Color("#2a1518"),
			"color": color,
			"lensRect": Rect2(cam.position + Vector2(radius * 1.55, radius * 0.22), Vector2(radius * 0.65, radius * 0.48)),
			"lensColor": Color("#2a1518")
		}
	return {
		"kind": "round",
		"shadowPos": pos + Vector2(0, 3),
		"shadowRadius": radius + 3.0,
		"shadowColor": Color("#24192d"),
		"pos": pos,
		"radius": radius,
		"color": color,
		"highlightPos": pos + Vector2(-radius * 0.22, -radius * 0.25),
		"highlightRadius": radius * 0.32,
		"highlightColor": color.lightened(0.28)
	}

static func enemy_face_data(pos: Vector2) -> Dictionary:
	return {
		"leftEye": pos + Vector2(-7, -5),
		"rightEye": pos + Vector2(7, -5),
		"eyeRadius": 4.0,
		"mouthStart": pos + Vector2(-8, 8),
		"mouthEnd": pos + Vector2(8, 8),
		"color": Color.BLACK
	}

static func enemy_hp_bar_data(pos: Vector2, radius: float, hp: float, max_hp: float) -> Dictionary:
	var bar_w: float = radius * 1.8
	var ratio: float = 0.0
	if max_hp > 0.0:
		ratio = clampf(hp / max_hp, 0.0, 1.0)
	var origin: Vector2 = pos + Vector2(-bar_w / 2, radius + 8)
	return {
		"backRect": Rect2(origin, Vector2(bar_w, 6)),
		"fillRect": Rect2(origin, Vector2(bar_w * ratio, 6)),
		"backColor": Color("#2a1118"),
		"fillColor": Color("#ff3246"),
		"labelPos": pos + Vector2(-34, -radius - 12)
	}

static func exp_orb_data(base_pos: Vector2, elapsed_time: float) -> Dictionary:
	var pos: Vector2 = base_pos
	pos.y += sin(elapsed_time * 8.0 + pos.x * 0.05) * 2.0
	var diamond := PackedVector2Array([
		pos + Vector2(0, -13),
		pos + Vector2(11, 0),
		pos + Vector2(0, 13),
		pos + Vector2(-11, 0)
	])
	return {
		"pos": pos,
		"shadowPos": pos + Vector2(0, 12),
		"shadowSize": Vector2(22, 7),
		"shadowAlpha": 0.16,
		"diamond": diamond,
		"colors": PackedColorArray([Color("#5ad7ff"), Color("#24a8ff"), Color("#116bce"), Color("#82f0ff")]),
		"outline": PackedVector2Array([diamond[0], diamond[1], diamond[2], diamond[3], diamond[0]]),
		"labelPos": pos + Vector2(-13, 4)
	}

static func marshmallow_visual(visual_type: String) -> Dictionary:
	var radius: float = 20.0
	var color: Color = Color("#fff7ef")
	if visual_type == "pink_heart":
		color = Color("#ffd4e6")
	elif visual_type == "cream_star":
		color = Color("#fff0b8")
	elif visual_type == "gold_rainbow":
		color = Color("#ffe66d")
		radius = 24.0
	elif visual_type == "gray_bad":
		color = Color("#8a8488")
		radius = 19.0
	elif visual_type == "purple_smoke":
		color = Color("#7750a0")
		radius = 19.0
	elif visual_type == "green_bad":
		color = Color("#7ba66a")
		radius = 19.0
	elif visual_type == "burnt_bad":
		color = Color("#332025")
		radius = 20.0
	return {"color": color, "radius": radius}

static func marshmallow_draw_data(base_pos: Vector2, item_data: Dictionary, time_left: float, elapsed_time: float, appraisal: bool) -> Dictionary:
	var visual_type: String = String(item_data.get("visualType", "normal_white"))
	var visual: Dictionary = marshmallow_visual(visual_type)
	var radius: float = float(visual["radius"])
	if visual_type == "purple_smoke":
		radius = 19.0 + sin(elapsed_time * 17.0) * 2.0
	var pos: Vector2 = base_pos + Vector2(0, sin(elapsed_time * 5.0 + base_pos.x * 0.02) * 4.0)
	var is_bad: bool = String(item_data["type"]) == "bad"
	var is_god: bool = String(item_data["rarity"]) == "god"
	return {
		"pos": pos,
		"radius": radius,
		"color": visual["color"] as Color,
		"isBad": is_bad,
		"isGod": is_god,
		"badAuraPos": pos + Vector2(4, -4),
		"badAuraRadius": radius + 7.0,
		"badAuraColor": Color(0.05, 0.0, 0.08, 0.25),
		"appraisal": appraisal and is_bad,
		"appraisalRadius": radius + 5.0,
		"appraisalColor": Color("#ff4b68"),
		"godAuraRadius": radius + 10.0,
		"godAuraColor": Color(1.0, 0.88, 0.2, 0.25),
		"shadowPos": pos + Vector2(0, radius * 0.8),
		"shadowSize": Vector2(radius * 1.8, radius * 0.55),
		"shadowAlpha": 0.16,
		"basePos": pos + Vector2(0, 2),
		"baseRadius": radius + 3.0,
		"baseColor": Color("#5c5265") if is_bad else Color("#efe0ff"),
		"highlightPos": pos + Vector2(-radius * 0.26, -radius * 0.28),
		"highlightRadius": radius * 0.34,
		"highlightColor": Color(1.0, 1.0, 1.0, 0.35),
		"dotPositions": [pos + Vector2(-7, -3), pos + Vector2(0, -3), pos + Vector2(7, -3)],
		"dotRadius": 2.0,
		"dotColor": Color("#5a4b67"),
		"warning": time_left <= 5.0,
		"warningPos": pos + Vector2(-16, -28),
		"warningColor": Color("#ff4b68"),
		"label": "変なマシュマロ" if is_bad else String(item_data["displayName"]),
		"labelPos": pos + Vector2(-58, -34),
		"timePos": pos + Vector2(-18, 38),
		"timeColor": Color("#cfc7ff")
	}

static func bullet_visual(player_owned: bool) -> Dictionary:
	if player_owned:
		return {
			"trailLength": 22.0,
			"trailColor": Color(0.25, 0.73, 1.0, 0.28),
			"trailWidth": 8.0,
			"outerRadius": 9.0,
			"outerColor": Color("#1d8fff"),
			"innerRadius": 4.0,
			"innerColor": Color.WHITE
		}
	return {
		"trailLength": 18.0,
		"trailColor": Color(1.0, 0.17, 0.35, 0.32),
		"trailWidth": 7.0,
		"outerRadius": 8.0,
		"outerColor": Color("#ff3357"),
		"innerRadius": 4.0,
		"innerColor": Color("#ffd0d8")
	}

static func boomerang_visual() -> Dictionary:
	return {
		"outerRadius": 16.0,
		"outerPoints": 18,
		"outerColor": Color("#d57bff"),
		"outerWidth": 6.0,
		"innerRadius": 9.0,
		"innerPoints": 14,
		"innerColor": Color("#fff45c"),
		"innerWidth": 3.0
	}

static func hit_fx_data(pos: Vector2, dir: Vector2, hit_pos: Vector2, range: float, life: float) -> Dictionary:
	var width: float = 12.0 + life * 46.0
	return {
		"start": pos + dir * 20.0,
		"end": pos + dir * range,
		"width": width,
		"mainColor": Color("#ffd34d"),
		"coreColor": Color.WHITE,
		"coreWidth": maxf(4.0, width * 0.28),
		"burstPos": hit_pos,
		"burstRadius": 24.0 + life * 30.0,
		"burstColor": Color(1.0, 0.95, 0.22, 0.35),
		"labelPos": hit_pos + Vector2(-22, -28),
		"labelColor": Color("#fff45c")
	}
