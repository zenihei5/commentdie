class_name DrawDataSystem
extends RefCounted

static func title_center() -> Vector2:
	return Vector2(600, 390)

static func screen_backdrop_data() -> Dictionary:
	return {
		"rect": Rect2(Vector2.ZERO, Vector2(1600, 900)),
		"color": Color("#11101a")
	}

static func modal_dim_data(arena: Rect2) -> Dictionary:
	return {
		"rect": arena,
		"color": Color(0, 0, 0, 0.24)
	}

static func special_overlay_views(target: Node) -> Array[String]:
	var views: Array[String] = []
	if ModifierSystem.has_effect_for_target(target, "comment_storm"):
		views.append("comment_storm")
	if ModifierSystem.has_effect_for_target(target, "zoom_in"):
		views.append("zoom_in")
	if String(target.get("active_genre_event")) == "horror":
		views.append("horror")
	return views

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

static func text_item(pos: Vector2, text: String, width: int, size: int, color: Color) -> Dictionary:
	return {
		"pos": pos,
		"text": text,
		"width": width,
		"size": size,
		"color": color
	}

static func layout_text_item(layout: Dictionary, prefix: String, text: String, color: Color, width: int = -1) -> Dictionary:
	return {
		"pos": layout[prefix + "Pos"] as Vector2,
		"text": text,
		"width": width if width >= 0 else int(layout.get(prefix + "Width", -1)),
		"size": int(layout[prefix + "Size"]),
		"color": color
	}

static func selection_panel_style(panel: Rect2) -> Dictionary:
	return {
		"rect": panel,
		"fill": selection_panel_fill(),
		"border": selection_panel_border(),
		"borderWidth": 5
	}

static func selection_card_frame_data(card: Rect2, selected: bool) -> Dictionary:
	var border: Color = selection_card_border(selected)
	return {
		"rect": card,
		"fill": selection_card_fill(),
		"border": border,
		"borderWidth": 4 if selected else 2
	}

static func title_panel_data() -> Dictionary:
	return {
		"rect": title_panel_rect(),
		"fill": Color(0.03, 0.03, 0.06, 0.84),
		"border": selection_panel_border(),
		"borderWidth": 5
	}

static func title_overlay_data(comment_barrage: String, screen_shake_enabled: bool) -> Dictionary:
	return {
		"center": title_center(),
		"panel": title_panel_data(),
		"lines": DisplayTextSystem.title_lines(comment_barrage, screen_shake_enabled)
	}

static func title_overlay_parts(data: Dictionary) -> Array:
	var parts: Array = [{"kind": "panel", "data": data["panel"] as Dictionary}]
	var center: Vector2 = data["center"] as Vector2
	for line in (data["lines"] as Array):
		var line_item: Dictionary = line as Dictionary
		parts.append({
			"kind": "text",
			"data": text_item(
				center + (line_item["offset"] as Vector2),
				String(line_item["text"]),
				int(line_item.get("width", -1)),
				int(line_item["size"]),
				line_item["color"] as Color
			)
		})
	return parts

static func selection_header_data(panel: Rect2, help_offset: Vector2) -> Dictionary:
	return {
		"titlePos": panel.position + Vector2(38, 58),
		"titleColor": Color("#fff45c"),
		"titleSize": 36,
		"helpPos": panel.position + help_offset,
		"helpColor": Color("#cfc7ff"),
		"helpSize": 20
	}

static func character_select_overlay_data(characters: Array, weapons: Array) -> Dictionary:
	var panel: Rect2 = character_select_panel_rect()
	var cards: Array = []
	for i in range(characters.size()):
		var character: Dictionary = characters[i] as Dictionary
		cards.append({
			"rect": character_card_rect(panel, i),
			"view": CharacterSystem.selection_card_view(character, weapons),
			"index": i
		})
	return {
		"panel": panel,
		"title": DisplayTextSystem.character_select_title(),
		"helpOffset": Vector2(620, 58),
		"cards": cards
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
		"titleSize": 29,
		"textureRect": tex_rect,
		"rolePos": Vector2(text_x, card.position.y + 332),
		"roleSize": 18,
		"weaponPos": Vector2(text_x, card.position.y + 362),
		"weaponSize": 18,
		"weaponColor": Color.WHITE,
		"passivePos": Vector2(text_x, card.position.y + 392),
		"passiveSize": 18,
		"passiveColor": Color.WHITE,
		"descriptionPos": Vector2(text_x, card.position.y + 428),
		"descriptionSize": 16,
		"textWidth": text_w,
		"roleColor": Color("#8df7ff"),
		"descriptionColor": Color("#dcd7ff")
	}

static func character_card_text_items(view: Dictionary, layout: Dictionary) -> Array:
	var text_w: int = int(layout["textWidth"])
	return [
		{"item": layout_text_item(layout, "role", DisplayTextSystem.character_role_text(String(view["roleName"])), layout["roleColor"] as Color, text_w), "multiline": false},
		{"item": layout_text_item(layout, "weapon", DisplayTextSystem.character_weapon_text(String(view["weaponName"])), layout["weaponColor"] as Color, text_w), "multiline": false},
		{"item": layout_text_item(layout, "passive", DisplayTextSystem.character_passive_text(String(view["passiveName"])), layout["passiveColor"] as Color, text_w), "multiline": false},
		{"item": layout_text_item(layout, "description", String(view["description"]), layout["descriptionColor"] as Color, text_w), "multiline": true}
	]

static func stream_frame_select_overlay_data(stream_frames: Array) -> Dictionary:
	var panel: Rect2 = stream_frame_select_panel_rect()
	var cards: Array = []
	for i in range(stream_frames.size()):
		var frame: Dictionary = stream_frames[i] as Dictionary
		cards.append({
			"rect": stream_frame_card_rect(panel, i),
			"view": StreamFrameSystem.selection_card_view(frame),
			"index": i
		})
	return {
		"panel": panel,
		"title": DisplayTextSystem.stream_frame_select_title(),
		"helpOffset": Vector2(610, 58),
		"cards": cards
	}

static func stream_frame_card_layout(card: Rect2) -> Dictionary:
	var text_w: int = int(card.size.x - 48)
	return {
		"titlePos": card.position + Vector2(24, 50),
		"titleWidth": text_w,
		"titleSize": 30,
		"descriptionPos": card.position + Vector2(24, 105),
		"descriptionSize": 19,
		"difficultyPos": card.position + Vector2(24, 178),
		"difficultySize": 22,
		"featuresPos": card.position + Vector2(24, 222),
		"featuresSize": 18,
		"textWidth": text_w,
		"descriptionColor": Color("#f3f0ff"),
		"difficultyColor": Color("#fff45c"),
		"featuresColor": Color("#8df7ff")
	}

static func stream_frame_card_text_items(view: Dictionary, layout: Dictionary) -> Array:
	var text_w: int = int(layout["textWidth"])
	var features: Array[String] = view["features"]
	return [
		{"item": layout_text_item(layout, "description", String(view["description"]), layout["descriptionColor"] as Color, text_w), "multiline": true},
		{"item": layout_text_item(layout, "difficulty", DisplayTextSystem.stream_frame_difficulty_text(String(view["difficultyText"])), layout["difficultyColor"] as Color, text_w), "multiline": false},
		{"item": layout_text_item(layout, "features", DisplayTextSystem.stream_frame_feature_text(features), layout["featuresColor"] as Color, text_w), "multiline": true}
	]

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

static func arena_background_data(arena: Rect2) -> Dictionary:
	return {
		"baseRect": arena,
		"baseColor": arena_base_color(),
		"tiles": arena_tiles(arena),
		"rocks": arena_rocks(arena),
		"sparks": arena_sparks(arena),
		"edgeShades": arena_edge_shades(arena),
		"borderRect": arena,
		"borderColor": arena_border_color(),
		"borderWidth": 5
	}

static func arena_background_parts(background: Dictionary) -> Array:
	var parts: Array = [
		{"kind": "rect_prefix", "data": background, "prefix": "base"}
	]
	for tile in (background["tiles"] as Array):
		parts.append({"kind": "rect", "data": tile as Dictionary})
	for rock in (background["rocks"] as Array):
		parts.append({"kind": "circle", "data": rock as Dictionary})
	for spark in (background["sparks"] as Array):
		parts.append({"kind": "spark", "data": spark as Dictionary})
	for shade in (background["edgeShades"] as Array):
		parts.append({"kind": "rect", "data": shade as Dictionary})
	parts.append({
		"kind": "outline",
		"rect": background["borderRect"] as Rect2,
		"color": background["borderColor"] as Color,
		"width": int(background["borderWidth"])
	})
	return parts

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

static func arena_effect_data(arena: Rect2, has_banana_floor: bool, effect_pits: Array) -> Dictionary:
	var pits: Array = []
	for pit in effect_pits:
		var pit_item: Dictionary = pit as Dictionary
		pits.append(pit_draw_data(Vector2(pit_item["pos"]), float(pit_item["radius"])))
	return {
		"bananaFloor": banana_floor_data(arena) if has_banana_floor else {},
		"pits": pits
	}

static func arena_effect_parts(arena_effects: Dictionary) -> Array:
	var parts: Array = []
	var banana_data: Dictionary = arena_effects["bananaFloor"] as Dictionary
	if not banana_data.is_empty():
		parts.append({"kind": "rect_prefix", "data": banana_data, "prefix": "overlay"})
		for banana in (banana_data["bananas"] as Array):
			parts.append({
				"kind": "banana",
				"data": banana as Dictionary,
				"color": banana_data["bananaColor"] as Color
			})
	for pit in (arena_effects["pits"] as Array):
		parts.append({"kind": "circle_prefix", "data": pit as Dictionary, "prefix": "outer"})
		parts.append({"kind": "circle_prefix", "data": pit as Dictionary, "prefix": "inner"})
	return parts

static func static_wall_rects() -> Array:
	return [Rect2(310, 310, 210, 32), Rect2(320, 700, 260, 28), Rect2(840, 480, 210, 32)]

static func arena_wall_draw_list(effect_walls: Array) -> Array:
	var walls: Array = []
	for wall in static_wall_rects():
		walls.append({"rect": wall, "temporary": false})
	for wall in effect_walls:
		walls.append({"rect": wall as Rect2, "temporary": true})
	return walls

static func arena_wall_data(rect: Rect2, temporary: bool) -> Dictionary:
	var top_height: float = 6.0 if temporary else 7.0
	var seams: Array = []
	if not temporary:
		for x in range(1, int(rect.size.x / 36.0)):
			seams.append({
				"from": rect.position + Vector2(float(x) * 36.0, 2),
				"to": rect.position + Vector2(float(x) * 36.0, rect.size.y - 2),
				"color": Color("#4a434e"),
				"width": 2
			})
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
		"seams": seams
	}

static func arena_wall_parts(wall: Dictionary) -> Array:
	var rect: Rect2 = wall["rect"] as Rect2
	var parts: Array = [
		{
			"kind": "shadow",
			"pos": wall["shadowPos"] as Vector2,
			"size": wall["shadowSize"] as Vector2,
			"alpha": float(wall["shadowAlpha"])
		},
		{
			"kind": "rect",
			"data": {
				"rect": rect,
				"color": wall["fillColor"] as Color
			}
		},
		{"kind": "rect_prefix", "data": wall, "prefix": "top"},
		{
			"kind": "outline",
			"rect": rect,
			"color": wall["borderColor"] as Color,
			"width": int(wall["borderWidth"])
		}
	]
	for seam in (wall["seams"] as Array):
		parts.append({"kind": "line", "data": seam as Dictionary})
	return parts

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

static func comment_storm_draw_data(arena: Rect2, elapsed: float, setting: int, kuso_active: bool, samples: Array[String]) -> Array:
	var style: Dictionary = comment_storm_style(setting, kuso_active)
	var amount: int = int(style["amount"])
	var alpha: float = float(style["alpha"])
	var items: Array = []
	for i in range(amount):
		items.append({
			"pos": comment_storm_position(arena, elapsed, i),
			"text": samples[i % samples.size()],
			"size": 22,
			"color": Color(1.0, 1.0, 1.0, alpha)
		})
	return items

static func zoom_mask_data(outer: Rect2) -> Dictionary:
	var center: Vector2 = outer.get_center()
	var inner_size: Vector2 = outer.size * 0.72
	var inner: Rect2 = Rect2(center - inner_size * 0.5, inner_size)
	return {
		"inner": inner,
		"shadeColor": Color(0.0, 0.0, 0.0, 0.24),
		"innerBorderColor": Color(1.0, 1.0, 1.0, 0.08),
		"innerBorderWidth": 3,
		"shades": [
			Rect2(outer.position, Vector2(outer.size.x, inner.position.y - outer.position.y)),
			Rect2(Vector2(outer.position.x, inner.end.y), Vector2(outer.size.x, outer.end.y - inner.end.y)),
			Rect2(Vector2(outer.position.x, inner.position.y), Vector2(inner.position.x - outer.position.x, inner.size.y)),
			Rect2(Vector2(inner.end.x, inner.position.y), Vector2(outer.end.x - inner.end.x, inner.size.y))
		]
	}

static func zoom_mask_parts(data: Dictionary) -> Array:
	var parts: Array = []
	for shade in (data["shades"] as Array):
		parts.append({
			"kind": "mask",
			"rect": shade as Rect2,
			"color": data["shadeColor"] as Color
		})
	parts.append({
		"kind": "outline",
		"rect": data["inner"] as Rect2,
		"color": data["innerBorderColor"] as Color,
		"width": int(data["innerBorderWidth"])
	})
	return parts

static func horror_mask_data(elapsed: float) -> Dictionary:
	var pulse: float = 0.5 + sin(elapsed * 5.0) * 0.5
	return {
		"shade": Color(0.0, 0.0, 0.0, 0.32),
		"pulse": Color(0.25, 0.0, 0.12, 0.08 + pulse * 0.05),
		"pulseWidth": 6,
		"title": DisplayTextSystem.horror_event_title(),
		"titleOffset": Vector2(36, 70),
		"titleSize": 30,
		"titleColor": Color(1.0, 0.78, 0.88, 0.85)
	}

static func horror_mask_parts(data: Dictionary, arena: Rect2) -> Array:
	return [
		{
			"kind": "mask",
			"rect": arena,
			"color": data["shade"] as Color
		},
		{
			"kind": "outline",
			"rect": arena,
			"color": data["pulse"] as Color,
			"width": int(data["pulseWidth"])
		},
		{
			"kind": "text",
			"data": text_item(
				arena.position + (data["titleOffset"] as Vector2),
				String(data["title"]),
				-1,
				int(data["titleSize"]),
				data["titleColor"] as Color
			)
		}
	]

static func metric_panel_style(rect: Rect2, accent: Color) -> Dictionary:
	return {
		"rect": rect,
		"fill": Color("#11131c"),
		"border": Color("#49305f"),
		"borderWidth": 3,
		"accentRect": Rect2(rect.position, Vector2(5, rect.size.y)),
		"accent": accent,
		"labelPos": rect.position + Vector2(14, 20),
		"labelColor": Color("#cfc7ff"),
		"labelSize": 15,
		"valuePos": rect.position + Vector2(14, 48),
		"valueWidth": int(rect.size.x - 22),
		"valueSize": 26
	}

static func metric_panel_draw_data(rect: Rect2, label: String, value: String, accent: Color) -> Dictionary:
	var style: Dictionary = metric_panel_style(rect, accent)
	style["label"] = label
	style["value"] = value
	return style

static func format_viewer_count(value: int) -> String:
	var text: String = str(maxi(0, value))
	var result: String = ""
	while text.length() > 3:
		result = "," + text.substr(text.length() - 3, 3) + result
		text = text.substr(0, text.length() - 3)
	return text + result

static func hud_frame_data(side: Rect2, hud: Rect2, viewer_count: int) -> Dictionary:
	return {
		"sideRect": side,
		"sideFill": Color("#080910"),
		"sideBorder": Color("#8e36e8"),
		"sideBorderWidth": 4,
		"sideDividerStart": Vector2(side.position.x + 20, side.position.y + 48),
		"sideDividerEnd": Vector2(side.end.x - 20, side.position.y + 48),
		"sideDividerColor": Color("#6f627e"),
		"sideDividerWidth": 2,
		"viewerPos": Vector2(1382, 143),
		"viewerText": format_viewer_count(viewer_count) + "人",
		"viewerSize": 24,
		"viewerColor": Color.WHITE,
		"hudRect": hud,
		"hudFill": Color("#080910"),
		"hudBorder": Color("#49305f"),
		"hudBorderWidth": 4
	}

static func hud_metric_specs(comment_alert: bool) -> Array:
	var comment_color: Color = Color("#ff4b68") if comment_alert else Color("#8df7ff")
	return [
		{"key": "hp", "rect": Rect2(34, 806, 154, 58), "label": "HP", "accent": Color("#ff4b68")},
		{"key": "time", "rect": Rect2(200, 806, 160, 58), "label": "残り", "accent": Color("#fff45c")},
		{"key": "multiplier", "rect": Rect2(372, 806, 156, 58), "label": "ボルテージ", "accent": Color("#b768ff")},
		{"key": "burn", "rect": Rect2(540, 806, 156, 58), "label": "炎上", "accent": Color("#ff8a31")},
		{"key": "hype", "rect": Rect2(708, 806, 210, 58), "label": "期待度", "accent": Color("#ff5a78")},
		{"key": "ng", "rect": Rect2(930, 806, 70, 58), "label": "NG", "accent": Color("#8df7ff")},
		{"key": "heart", "rect": Rect2(1008, 806, 66, 58), "label": "♡", "accent": Color("#ff91c8")},
		{"key": "nextComment", "rect": Rect2(1086, 806, 150, 58), "label": "次コメ", "accent": comment_color},
		{"key": "currentComment", "rect": Rect2(1248, 806, 308, 58), "label": "現在", "accent": Color("#f3f0ff")}
	]

static func hud_metric_draw_data(metric_values: Dictionary, comment_alert: bool) -> Array:
	var items: Array = []
	for spec in hud_metric_specs(comment_alert):
		var item: Dictionary = spec as Dictionary
		var key: String = String(item["key"])
		items.append(metric_panel_draw_data(item["rect"] as Rect2, String(item["label"]), String(metric_values[key]), item["accent"] as Color))
	return items

static func hp_ratio(hp: int, max_hp: int) -> float:
	if max_hp <= 0:
		return 0.0
	return clampf(float(hp) / float(max_hp), 0.0, 1.0)

static func fake_hp_ratio(elapsed: float) -> float:
	var step: float = floor(elapsed * 5.0)
	var noise: float = fposmod(sin(step * 12.9898 + 78.233) * 43758.5453, 1.0)
	return clampf(lerpf(0.12, 1.0, noise), 0.05, 1.0)

static func visual_hp_ratio(hp: int, max_hp: int, hide_hp: bool, elapsed: float) -> float:
	if hide_hp:
		return fake_hp_ratio(elapsed)
	return hp_ratio(hp, max_hp)

static func hud_value_data(context: Dictionary) -> Dictionary:
	var remaining: int = maxi(0, int(ceil(float(context["runLength"]) - float(context["elapsed"]))))
	var exp_need: int = maxi(1, int(context["expNeed"]))
	var hp_text: String = "??" if bool(context["hideHp"]) else ""
	return {
		"metrics": {
			"hp": hp_text,
			"time": "%02d:%02d" % [remaining / 60, remaining % 60],
			"multiplier": "x%.1f" % float(context["multiplier"]),
			"burn": str(int(context["burnCombo"])),
			"hype": "%d%%" % int(context["giftHype"]),
			"ng": "x%d" % int(context["ngStock"]),
			"heart": "待機" if bool(context["heartPending"]) else "-",
			"nextComment": "%.1fs" % maxf(0.0, float(context["commentTimer"])),
			"currentComment": String(context["currentComment"])
		},
		"expRatio": float(context["expValue"]) / float(exp_need),
		"hypeRatio": float(context["giftHype"]) / 100.0,
		"hpRatio": visual_hp_ratio(int(context["playerHp"]), int(context["playerMaxHp"]), bool(context["hideHp"]), float(context["elapsed"])),
		"hideHp": bool(context["hideHp"])
	}

static func hud_gauge_data(exp_ratio: float, hype_ratio: float, hp_value_ratio: float) -> Array:
	var gauges: Array = []
	gauges.append({
		"label": "",
		"backRect": Rect2(Vector2(54, 842), Vector2(112, 11)),
		"fillRect": Rect2(Vector2(54, 842), Vector2(112 * hp_value_ratio, 11)),
		"backColor": Color("#10261a"),
		"fillColor": Color("#4ade80"),
		"labelPos": Vector2(54, 858),
		"labelColor": Color("#a7f3c4"),
		"labelWidth": -1,
		"labelSize": 12
	})
	gauges.append_array([
		{
			"label": "EXP",
			"backRect": Rect2(Vector2(34, 872), Vector2(360, 6)),
			"fillRect": Rect2(Vector2(34, 872), Vector2(360 * exp_ratio, 6)),
			"backColor": Color("#203047"),
			"fillColor": Color("#24a8ff"),
			"labelPos": Vector2(34, 888),
			"labelColor": Color("#7cdcff"),
			"labelWidth": -1,
			"labelSize": 14
		},
		{
			"label": "ギフト期待度",
			"backRect": Rect2(Vector2(430, 872), Vector2(260, 6)),
			"fillRect": Rect2(Vector2(430, 872), Vector2(260 * hype_ratio, 6)),
			"backColor": Color("#40202a"),
			"fillColor": Color("#ff5a78"),
			"labelPos": Vector2(430, 888),
			"labelColor": Color("#ff91aa"),
			"labelWidth": -1,
			"labelSize": 14
		}
	])
	return gauges

static func hud_gauge_draw_data(hud_values: Dictionary) -> Array:
	return hud_gauge_data(float(hud_values["expRatio"]), float(hud_values["hypeRatio"]), float(hud_values["hpRatio"]))

static func hud_metric_parts() -> Array:
	return [
		{"kind": "panel"},
		{"kind": "rect_keys", "rectKey": "accentRect", "colorKey": "accent"},
		{"kind": "text", "prefix": "label"},
		{"kind": "text", "prefix": "value", "colorKey": "accent"}
	]

static func hud_gauge_parts() -> Array:
	return [
		{"kind": "bar"},
		{"kind": "text", "prefix": "label"}
	]

static func hud_draw_data(side: Rect2, hud: Rect2, context: Dictionary) -> Dictionary:
	var values: Dictionary = hud_value_data(context)
	var metric_values: Dictionary = values["metrics"] as Dictionary
	return {
		"frame": hud_frame_data(side, hud, int(context.get("score", 0))),
		"metrics": hud_metric_draw_data(metric_values, float(context["commentTimer"]) <= 5.0),
		"gauges": hud_gauge_draw_data(values)
	}

static func comment_countdown_data(left: float, interval: float, elapsed_time: float) -> Dictionary:
	var ratio: float = clampf(left / interval, 0.0, 1.0)
	var alert: bool = left <= 5.0
	var rect: Rect2 = Rect2(Vector2(450, 118), Vector2(520, 54))
	if alert:
		var shake: Vector2 = Vector2(
			sin(elapsed_time * 58.0) * 2.2,
			cos(elapsed_time * 47.0) * 1.4
		)
		rect.position += shake
	var pulse: float = 0.5 + sin(elapsed_time * 12.0) * 0.5
	var border: Color = Color("#ff4b68") if alert else Color("#8df7ff")
	var progress_color: Color = Color("#ff4b68") if alert else Color("#8df7ff")
	return {
		"rect": rect,
		"ratio": ratio,
		"alert": alert,
		"fill": Color(0.16, 0.02, 0.04, 0.92) if alert else Color(0.02, 0.04, 0.07, 0.84),
		"border": border.lightened(0.25 * pulse) if alert else border,
		"borderWidth": 4,
		"progressRect": Rect2(rect.position + Vector2(18, 38), Vector2((rect.size.x - 36.0) * ratio, 7)),
		"progressColor": progress_color,
		"title": DisplayTextSystem.comment_countdown_title(alert),
		"value": "%.1fs" % left,
		"warningText": DisplayTextSystem.comment_countdown_warning(),
		"titlePos": rect.position + Vector2(22, 26),
		"titleSize": 19,
		"titleColor": Color.WHITE,
		"valuePos": rect.position + Vector2(350, 31),
		"valueWidth": 130,
		"valueSize": 25,
		"warningPos": rect.position + Vector2(172, 29),
		"warningWidth": -1,
		"warningSize": 18,
		"valueColor": Color("#fff45c") if alert else Color("#8df7ff"),
		"warningColor": Color("#ff4b68")
	}

static func comment_countdown_parts(data: Dictionary) -> Array:
	var parts: Array = [
		{"kind": "panel"},
		{"kind": "rect_keys", "rectKey": "progressRect", "colorKey": "progressColor"},
		{"kind": "text", "prefix": "title", "alignment": HORIZONTAL_ALIGNMENT_LEFT},
		{"kind": "text", "prefix": "value", "alignment": HORIZONTAL_ALIGNMENT_RIGHT}
	]
	if bool(data["alert"]):
		parts.append({"kind": "text", "prefix": "warning", "alignment": HORIZONTAL_ALIGNMENT_LEFT})
	return parts

static func choice_backplate_data() -> Dictionary:
	var rect: Rect2 = Rect2(Vector2(430, 126), Vector2(790, 365))
	return {
		"rect": rect,
		"fill": Color(0.02, 0.02, 0.04, 0.48),
		"border": Color("#5b2b88"),
		"borderWidth": 4
	}

static func tutorial_overlay_data() -> Dictionary:
	return {
		"rect": Rect2(Vector2(230, 150), Vector2(760, 560)),
		"fill": Color(0.02, 0.02, 0.04, 0.95),
		"border": Color("#8df7ff"),
		"borderWidth": 4
	}

static func tutorial_overlay_parts(data: Dictionary) -> Array:
	var parts: Array = [{"kind": "panel", "data": data}]
	var rect: Rect2 = data["rect"] as Rect2
	for line in DisplayTextSystem.tutorial_text_lines():
		var item: Dictionary = line as Dictionary
		parts.append({
			"kind": "text",
			"data": text_item(
				rect.position + (item["offset"] as Vector2),
				String(item["text"]),
				int(item.get("width", -1)),
				int(item["size"]),
				item["color"] as Color
			)
		})
	return parts

static func toast_data(text: String) -> Dictionary:
	var rect := Rect2(Vector2(440, 655), Vector2(700, 72))
	var border := Color("#8df7ff")
	if text.contains("クソマロ") or text.contains("ブロック"):
		border = Color("#ff4b68")
	return {
		"rect": rect,
		"fill": Color(0.04, 0.035, 0.06, 0.88),
		"border": border,
		"borderWidth": 4,
		"textPos": rect.position + Vector2(22, 45),
		"textWidth": int(rect.size.x - 44),
		"fontSize": 28,
		"textColor": Color.WHITE
	}

static func toast_parts(data: Dictionary, text: String) -> Array:
	return [
		{"kind": "panel", "data": data},
		{"kind": "text", "data": text_item(data["textPos"] as Vector2, text, int(data["textWidth"]), int(data["fontSize"]), data["textColor"] as Color)}
	]

static func animated_sprite_frame_data(sprite: Texture2D, character: Dictionary, prefix: String, elapsed_time: float) -> Dictionary:
	var cols: int = int(character.get(prefix + "SpriteCols", 3))
	var rows: int = int(character.get(prefix + "SpriteRows", 3))
	var frames: int = max(1, cols * rows)
	var frame: int = int(floor(elapsed_time * float(character.get(prefix + "SpriteFps", 8.0)))) % frames
	var cell: Vector2 = Vector2(sprite.get_width() / cols, sprite.get_height() / rows)
	var frame_row: int = int(frame / cols)
	return {
		"sourceRect": Rect2(Vector2(float(frame % cols) * cell.x, float(frame_row) * cell.y), cell),
		"scale": float(character.get(prefix + "SpriteScale", 0.82)),
		"offset": character.get(prefix + "SpriteOffset", {"x": 0, "y": -12})
	}

static func idle_sprite_frame_data(sprite: Texture2D, character: Dictionary, elapsed_time: float) -> Dictionary:
	return animated_sprite_frame_data(sprite, character, "idle", elapsed_time)

static func run_sprite_frame_data(sprite: Texture2D, character: Dictionary, elapsed_time: float) -> Dictionary:
	return animated_sprite_frame_data(sprite, character, "run", elapsed_time)

static func player_sprite_draw_data(
	player_pos: Vector2,
	source_rect: Rect2,
	sprite_scale: float,
	offset_data: Dictionary,
	uses_idle_sheet: bool,
	idle_bob: float,
	walk_bob: float,
	dash_squash: float,
	attack_pop: float,
	alpha: float
) -> Dictionary:
	var visual_bob: float = 0.0 if uses_idle_sheet else idle_bob + walk_bob
	var shadow_bob: float = 0.0 if uses_idle_sheet else walk_bob * 0.25
	var shadow_pos: Vector2 = player_pos + (Vector2(0, 36) if uses_idle_sheet else Vector2(0, 31 + shadow_bob))
	var shadow_size: Vector2 = (Vector2(52, 15) if uses_idle_sheet else Vector2(62, 20)) + Vector2(dash_squash * 12.0, -dash_squash * 4.0)
	var offset: Vector2 = Vector2(float(offset_data.get("x", 0)), float(offset_data.get("y", -34)) - visual_bob)
	var size: Vector2 = source_rect.size * sprite_scale
	size.x *= 1.0 + dash_squash * 0.08 + attack_pop
	size.y *= 1.0 - dash_squash * 0.05 + attack_pop * 0.35
	return {
		"shadowPos": shadow_pos,
		"shadowSize": shadow_size,
		"shadowAlpha": 0.30,
		"center": player_pos + offset,
		"size": size,
		"alpha": alpha
	}

static func player_sprite_state(
	player_pos: Vector2,
	player_vel: Vector2,
	player_facing_x: float,
	player_sprite: Texture2D,
	player_idle_sprite: Texture2D,
	player_run_sprite: Texture2D,
	character: Dictionary,
	elapsed_time: float,
	attack_timer: float,
	attack_interval: float,
	last_dir: Vector2,
	invincible_time: float
) -> Dictionary:
	var move_amount: float = clampf(player_vel.length() / 260.0, 0.0, 1.0)
	var idle_bob: float = sin(elapsed_time * 4.0) * 2.0
	var walk_bob: float = abs(sin(elapsed_time * 11.0)) * 5.0 * move_amount
	var dash_squash: float = clampf((player_vel.length() - 330.0) / 430.0, 0.0, 1.0)
	var attack_pop: float = clampf(1.0 - attack_timer / maxf(0.01, attack_interval), 0.0, 1.0)
	attack_pop = sin(attack_pop * PI) * 0.08
	var tilt: float = clampf(player_vel.x / 520.0, -1.0, 1.0) * 0.12
	if last_dir.x < -0.2:
		tilt -= attack_pop * 0.6
	else:
		tilt += attack_pop * 0.6
	var alpha: float = 1.0
	if invincible_time > 0.0 and fmod(elapsed_time * 16.0, 2.0) < 1.0:
		alpha = 0.42
	var draw_sprite: Texture2D = player_sprite
	var source_rect: Rect2 = Rect2(Vector2.ZERO, Vector2(player_sprite.get_size()))
	var sprite_scale: float = float(character.get("spriteScale", 0.095))
	var uses_idle_sheet: bool = player_idle_sprite != null
	var is_moving: bool = player_vel.length() > 18.0
	var uses_run_sheet: bool = is_moving and player_run_sprite != null
	var idle_frame_data: Dictionary = {}
	if uses_run_sheet:
		draw_sprite = player_run_sprite
		idle_frame_data = run_sprite_frame_data(player_run_sprite, character, elapsed_time)
		source_rect = idle_frame_data["sourceRect"] as Rect2
		sprite_scale = float(idle_frame_data["scale"])
		uses_idle_sheet = true
	elif player_idle_sprite != null:
		draw_sprite = player_idle_sprite
		idle_frame_data = idle_sprite_frame_data(player_idle_sprite, character, elapsed_time)
		source_rect = idle_frame_data["sourceRect"] as Rect2
		sprite_scale = float(idle_frame_data["scale"])
	var offset_data: Dictionary = character.get("spriteOffset", {"x": 0, "y": -34})
	if uses_idle_sheet:
		offset_data = idle_frame_data["offset"] as Dictionary
	var draw_data: Dictionary = player_sprite_draw_data(player_pos, source_rect, sprite_scale, offset_data, uses_idle_sheet, idle_bob, walk_bob, dash_squash, attack_pop, alpha)
	draw_data["texture"] = draw_sprite
	draw_data["sourceRect"] = source_rect
	draw_data["tilt"] = tilt
	draw_data["flipX"] = (player_vel.x < -18.0) if uses_run_sheet else player_facing_x < -0.1
	return draw_data

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
		"liveText": "LIVE",
		"liveTextPos": pos + Vector2(-18, -27),
		"liveTextWidth": -1,
		"liveTextSize": 13,
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
		"banText": "BAN",
		"banTextPos": pos + Vector2(61, -13),
		"banTextWidth": -1,
		"banTextSize": 15,
		"banTextColor": Color("#2b1016")
	}

static func fallback_player_parts(draw_data: Dictionary) -> Array:
	return [
		{"kind": "shadow"},
		{"kind": "circle", "prefix": "back"},
		{"kind": "circle", "prefix": "body"},
		{"kind": "circle", "prefix": "face"},
		{"kind": "rect", "prefix": "liveBack"},
		{"kind": "rect", "prefix": "live"},
		{"kind": "text", "prefix": "liveText"},
		{"kind": "circle", "prefix": "rightEye", "radiusPrefix": "eye"},
		{"kind": "circle", "prefix": "leftEye", "radiusPrefix": "eye"},
		{"kind": "circle", "prefix": "rightEye", "radiusPrefix": "eyeDot", "colorKey": "eyeDotColor"},
		{"kind": "circle", "prefix": "leftEye", "radiusPrefix": "eyeDot", "colorKey": "eyeDotColor"},
		{"kind": "arc", "pos": draw_data["mouthCenter"] as Vector2, "radius": 9.0, "start": 0.1, "end": PI - 0.1, "points": 12, "color": draw_data["mouthColor"] as Color, "width": 2.0},
		{"kind": "line", "prefix": "micLine", "width": 5.0},
		{"kind": "circle", "prefix": "mic"},
		{"kind": "line", "prefix": "hammerLine", "width": 15.0},
		{"kind": "line", "prefix": "hammerCore", "width": 9.0},
		{"kind": "circle", "prefix": "hammerBack"},
		{"kind": "circle", "prefix": "hammer"},
		{"kind": "text", "prefix": "banText"}
	]

static func invincible_label_data(pos: Vector2) -> Dictionary:
	return {
		"text": "無敵",
		"pos": pos + Vector2(-35, 45),
		"width": -1,
		"size": 15,
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
		"labelPos": pos + Vector2(-34, -radius - 12),
		"labelWidth": -1,
		"labelSize": 15,
		"labelColor": Color.WHITE
	}

static func enemy_draw_data(enemy: Dictionary) -> Dictionary:
	var kind: String = String(enemy["kind"])
	var pos: Vector2 = Vector2(enemy["pos"])
	var radius: float = float(enemy["radius"])
	var color: Color = enemy_color(kind)
	return {
		"kind": kind,
		"pos": pos,
		"radius": radius,
		"shadow": enemy_shadow_data(pos, radius),
		"body": enemy_body_data(kind, pos, radius, color),
		"face": {} if kind == "long_comment_guy" else enemy_face_data(pos),
		"bar": enemy_hp_bar_data(pos, radius, float(enemy["hp"]), float(enemy["max_hp"]))
	}

static func enemy_face_parts() -> Array:
	return [
		{"kind": "circle", "prefix": "leftEye", "radiusPrefix": "eye"},
		{"kind": "circle", "prefix": "rightEye", "radiusPrefix": "eye"},
		{"kind": "line", "prefix": "mouth", "width": 3.0}
	]

static func enemy_hp_bar_parts() -> Array:
	return [
		{"kind": "bar"},
		{"kind": "text", "prefix": "label"}
	]

static func player_hp_bar_data(pos: Vector2, hp: int, max_hp: int, hide_hp: bool, elapsed: float) -> Dictionary:
	var width: float = 96.0
	var origin: Vector2 = pos + Vector2(-width * 0.5, 48.0)
	var ratio: float = visual_hp_ratio(hp, max_hp, hide_hp, elapsed)
	return {
		"backRect": Rect2(origin, Vector2(width, 8.0)),
		"fillRect": Rect2(origin, Vector2(width * ratio, 8.0)),
		"backColor": Color("#10261a"),
		"fillColor": Color("#4ade80"),
		"label": "",
		"labelPos": origin + Vector2(0, -2),
		"labelWidth": -1,
		"labelSize": 10,
		"labelColor": Color("#a7f3c4")
	}

static func player_hp_bar_parts() -> Array:
	return [
		{"kind": "bar"}
	]

static func enemy_body_parts(body: Dictionary) -> Array:
	var body_kind: String = String(body["kind"])
	if body_kind == "long":
		return [
			{"kind": "rect", "prefix": "shadow"},
			{"kind": "rect", "prefix": ""},
			{"kind": "rect", "prefix": "top"}
		]
	if body_kind == "clipper":
		return [
			{"kind": "rect", "prefix": "shadow"},
			{"kind": "rect", "prefix": ""},
			{"kind": "rect", "prefix": "lens"}
		]
	return [
		{"kind": "circle", "prefix": "shadow"},
		{"kind": "circle", "prefix": ""},
		{"kind": "circle", "prefix": "highlight"}
	]

static func enemy_draw_parts(enemy_draw: Dictionary) -> Array:
	var parts: Array = []
	parts.append({"kind": "shadow", "data": enemy_draw["shadow"] as Dictionary})
	parts.append({"kind": "body", "data": enemy_draw["body"] as Dictionary})
	if not (enemy_draw["face"] as Dictionary).is_empty():
		parts.append({"kind": "face", "data": enemy_draw["face"] as Dictionary})
	var bar: Dictionary = enemy_draw["bar"] as Dictionary
	bar["label"] = DisplayTextSystem.enemy_display_name(String(enemy_draw["kind"]))
	parts.append({"kind": "bar", "data": bar})
	return parts

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
		"outlineColor": Color.WHITE,
		"outlineWidth": 2.0,
		"label": "EXP",
		"labelPos": pos + Vector2(-13, 4),
		"labelWidth": -1,
		"labelSize": 8,
		"labelColor": Color.WHITE
	}

static func exp_orbs_draw_data(exp_orbs: Array, elapsed_time: float) -> Array:
	var items: Array = []
	for orb in exp_orbs:
		var orb_item: Dictionary = orb as Dictionary
		items.append(exp_orb_data(Vector2(orb_item["pos"]), elapsed_time))
	return items

static func exp_orb_parts() -> Array:
	return [
		{"kind": "shadow"},
		{"kind": "polygon", "pointsKey": "diamond", "colorsKey": "colors"},
		{"kind": "polyline", "pointsKey": "outline", "colorKey": "outlineColor", "widthKey": "outlineWidth"},
		{"kind": "text", "prefix": "label"}
	]

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
		"warningText": "!",
		"warningPos": pos + Vector2(-16, -28),
		"warningColor": Color("#ff4b68"),
		"warningSize": 28,
		"warningWidth": -1,
		"label": "変なマシュマロ" if is_bad else String(item_data["displayName"]),
		"labelPos": pos + Vector2(-58, -34),
		"labelColor": Color.WHITE,
		"labelSize": 15,
		"labelWidth": -1,
		"timeLeft": time_left,
		"timePos": pos + Vector2(-18, 38),
		"timeColor": Color("#cfc7ff"),
		"timeSize": 14,
		"timeWidth": -1
	}

static func marshmallow_draw_list(marshmallows: Array, elapsed_time: float, appraisal: bool) -> Array:
	var items: Array = []
	for item in marshmallows:
		var mallow: Dictionary = item as Dictionary
		var data: Dictionary = mallow["data"] as Dictionary
		items.append(marshmallow_draw_data(Vector2(mallow["pos"]), data, float(mallow["time"]), elapsed_time, appraisal))
	return items

static func marshmallow_parts(visual: Dictionary) -> Array:
	var parts: Array = []
	if bool(visual["isBad"]):
		parts.append({"kind": "circle", "prefix": "badAura", "filled": true})
		if bool(visual["appraisal"]):
			parts.append({"kind": "circle", "prefix": "appraisal", "filled": false, "width": 4.0})
	elif bool(visual["isGod"]):
		parts.append({"kind": "circle", "prefix": "godAura", "filled": true})
	parts.append({"kind": "shadow"})
	parts.append({"kind": "circle", "prefix": "base", "filled": true})
	parts.append({"kind": "circle", "prefix": "", "filled": true})
	parts.append({"kind": "circle", "prefix": "highlight", "filled": true})
	for dot_pos in (visual["dotPositions"] as Array):
		parts.append({"kind": "dot", "pos": dot_pos as Vector2})
	if bool(visual["warning"]):
		parts.append({"kind": "text", "prefix": "warning"})
	parts.append({"kind": "text", "prefix": "label"})
	parts.append({"kind": "time"})
	return parts

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

static func bullet_draw_data(bullets: Array, player_owned: bool) -> Array:
	var visual: Dictionary = bullet_visual(player_owned)
	var items: Array = []
	for bullet in bullets:
		var bullet_item: Dictionary = bullet as Dictionary
		var pos: Vector2 = Vector2(bullet_item["pos"])
		var vel: Vector2 = Vector2(bullet_item["vel"]).normalized()
		items.append({
			"trailStart": pos - vel * float(visual["trailLength"]),
			"trailEnd": pos,
			"trailColor": visual["trailColor"] as Color,
			"trailWidth": visual["trailWidth"],
			"pos": pos,
			"outerRadius": visual["outerRadius"],
			"outerColor": visual["outerColor"] as Color,
			"innerRadius": visual["innerRadius"],
			"innerColor": visual["innerColor"] as Color
		})
	return items

static func bullet_parts() -> Array:
	return [
		{"kind": "line", "prefix": "trail"},
		{"kind": "circle", "prefix": "outer"},
		{"kind": "circle", "prefix": "inner"}
	]

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

static func boomerang_draw_data(player_pos: Vector2, count: int, radius: float, orbit_speed: float, elapsed_time: float) -> Array:
	var visual: Dictionary = boomerang_visual()
	var items: Array = []
	if count <= 0:
		return items
	for i in range(count):
		var angle: float = elapsed_time * orbit_speed + TAU * float(i) / float(count)
		items.append({
			"pos": player_pos + Vector2(cos(angle), sin(angle)) * radius,
			"outerRadius": visual["outerRadius"],
			"outerStart": angle,
			"outerEnd": angle + PI * 1.25,
			"outerPoints": visual["outerPoints"],
			"outerColor": visual["outerColor"] as Color,
			"outerWidth": visual["outerWidth"],
			"innerRadius": visual["innerRadius"],
			"innerStart": angle + PI,
			"innerEnd": angle + TAU * 1.2,
			"innerPoints": visual["innerPoints"],
			"innerColor": visual["innerColor"] as Color,
			"innerWidth": visual["innerWidth"]
		})
	return items

static func boomerang_draw_data_for_weapon(player_pos: Vector2, weapon: Dictionary, boomerang_level: int, weapon_range: float, elapsed_time: float) -> Array:
	var is_main_orbit: bool = WeaponSystem.attack_type(weapon) == "orbit"
	var count: int = WeaponSystem.orbit_count(weapon, boomerang_level)
	var radius: float = weapon_range if is_main_orbit else 78.0
	var orbit_speed: float = WeaponSystem.orbit_speed(weapon)
	return boomerang_draw_data(player_pos, count, radius, orbit_speed, elapsed_time)

static func boomerang_parts() -> Array:
	return [
		{"kind": "arc", "prefix": "outer"},
		{"kind": "arc", "prefix": "inner"}
	]

static func hit_fx_data(pos: Vector2, dir: Vector2, hit_pos: Vector2, range: float, life: float, arc_angle: float) -> Dictionary:
	var width: float = 9.0 + life * 36.0
	var angle: float = dir.angle()
	var half_arc: float = deg_to_rad(arc_angle * 0.5)
	var inner_radius: float = maxf(34.0, range * 0.42)
	var swing_progress: float = clampf(1.0 - life / 0.22, 0.0, 1.0)
	var swing_angle: float = angle + lerpf(-half_arc, half_arc, swing_progress)
	var hammer_pos: Vector2 = pos + Vector2.RIGHT.rotated(swing_angle) * range * 0.62
	return {
		"pos": pos,
		"start": pos + dir * 20.0,
		"end": pos + dir * range,
		"width": width,
		"mainRadius": range,
		"mainStart": angle - half_arc,
		"mainEnd": angle + half_arc,
		"mainPoints": 28,
		"mainColor": Color(1.0, 0.82, 0.20, 0.78),
		"mainWidth": width,
		"coreRadius": inner_radius,
		"coreStart": angle - half_arc * 0.86,
		"coreEnd": angle + half_arc * 0.86,
		"corePoints": 24,
		"coreColor": Color(1.0, 1.0, 1.0, 0.70),
		"coreWidth": maxf(3.0, width * 0.34),
		"burstPos": hit_pos,
		"burstRadius": 24.0 + life * 30.0,
		"burstColor": Color(1.0, 0.95, 0.22, 0.35),
		"hammerPos": hammer_pos,
		"hammerSize": Vector2(82, 82) * (0.92 + 0.08 * sin(swing_progress * PI)),
		"hammerAngle": swing_angle + deg_to_rad(38.0),
		"hammerAlpha": clampf(life / 0.16, 0.0, 1.0),
		"label": "BAN!",
		"labelPos": hit_pos + Vector2(-22, -28),
		"labelColor": Color("#fff45c"),
		"labelSize": 20
	}

static func kusa_wave_fx_data(pos: Vector2, dir: Vector2, life: float) -> Dictionary:
	var alpha: float = clampf(life / 0.48, 0.0, 1.0)
	var progress: float = clampf(1.0 - life / 0.48, 0.0, 1.0)
	var normalized_dir: Vector2 = dir.normalized()
	var side: Vector2 = Vector2(-normalized_dir.y, normalized_dir.x)
	var chars: int = clampi(1 + int(progress * 6.0), 1, 7)
	var wave_text: String = ""
	for i in range(chars):
		wave_text += "W"
	var wobble: Vector2 = side * sin(life * 28.0) * 7.0
	var text_pos: Vector2 = pos + wobble - normalized_dir * (8.0 * float(chars)) + Vector2(-10, 14)
	return {
		"kind": "kusa_wave",
		"trailStart": pos - normalized_dir * (48.0 + 11.0 * float(chars)),
		"trailEnd": pos,
		"trailColor": Color(0.0, 0.95, 0.12, 0.62 * alpha),
		"trailWidth": 13.0,
		"label": wave_text,
		"labelPos": text_pos,
		"labelColor": Color(0.0, 1.0, 0.10, alpha),
		"labelSize": 34 + int(progress * 8.0),
		"shadowText": wave_text,
		"shadowPos": text_pos + Vector2(3, 3),
		"shadowColor": Color(0.0, 0.12, 0.02, 0.90 * alpha),
		"shadowSize": 36 + int(progress * 8.0),
		"burstPos": pos + wobble,
		"burstRadius": 24.0 + alpha * 18.0,
		"burstColor": Color(0.0, 0.95, 0.10, 0.34 * alpha),
		"showBurst": true,
		"showHammer": false
	}

static func hit_fx_draw_data(hit_fx: Array) -> Array:
	var items: Array = []
	for fx in hit_fx:
		var fx_item: Dictionary = fx as Dictionary
		if String(fx_item.get("kind", "")) == "kusa_wave":
			items.append(kusa_wave_fx_data(Vector2(fx_item["pos"]), Vector2(fx_item["dir"]), float(fx_item["life"])))
			continue
		var data: Dictionary = hit_fx_data(Vector2(fx_item["pos"]), Vector2(fx_item["dir"]), Vector2(fx_item["hit"]), float(fx_item["range"]), float(fx_item["life"]), float(fx_item.get("arcAngle", 120.0)))
		data["showBurst"] = int(fx_item["count"]) > 0
		data["showHammer"] = bool(fx_item.get("hammer", false))
		items.append(data)
	return items

static func hit_fx_parts(data: Dictionary) -> Array:
	if String(data.get("kind", "")) == "kusa_wave":
		return [
			{"kind": "line", "prefix": "trail"},
			{"kind": "circle", "prefix": "burst"},
			{"kind": "text", "prefix": "shadow"},
			{"kind": "text", "prefix": "label"}
		]
	var parts: Array = [
		{"kind": "arc", "prefix": "main"},
		{"kind": "arc", "prefix": "core"}
	]
	if bool(data["showBurst"]):
		parts.append({"kind": "circle", "prefix": "burst"})
		parts.append({"kind": "text", "prefix": "label"})
	return parts
