class_name DrawDataSystem
extends RefCounted

const MapBackgroundSystemScript := preload("res://scripts/systems/map_background_system.gd")

static func title_center() -> Vector2:
	return Vector2(600, 390)

static func screen_backdrop_data() -> Dictionary:
	return {
		"rect": Rect2(Vector2.ZERO, Vector2(1600, 900)),
		"color": Color("#f8f7fb")
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
	return Rect2(Vector2(230, 150), Vector2(740, 560))

static func character_select_panel_rect() -> Rect2:
	return Rect2(Vector2(92, 96), Vector2(1040, 660))

static func stream_frame_select_panel_rect() -> Rect2:
	return Rect2(Vector2(70, 88), Vector2(1130, 705))

static func character_card_rect(panel: Rect2, index: int) -> Rect2:
	var card_w := 300.0
	var gap := 28.0
	return Rect2(panel.position + Vector2(34 + index * (card_w + gap), 92), Vector2(card_w, 520))

static func stream_frame_card_rect(panel: Rect2, index: int) -> Rect2:
	var card_w := 340.0
	var card_h := 250.0
	var gap := 24.0
	var col: int = index % 3
	var row: int = int(index / 3)
	return Rect2(panel.position + Vector2(36 + col * (card_w + gap), 98 + row * (card_h + gap)), Vector2(card_w, card_h))

static func selection_panel_fill() -> Color:
	return Color(0.985, 0.99, 1.0, 0.94)

static func selection_panel_border() -> Color:
	return Color("#ff79ad")

static func selection_card_fill() -> Color:
	return Color(1.0, 1.0, 1.0, 0.94)

static func selection_card_border(selected: bool) -> Color:
	return Color("#ff4f92") if selected else Color("#b8d9ff")

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
		"fill": Color(0.985, 0.99, 1.0, 0.92),
		"border": selection_panel_border(),
		"borderWidth": 5
	}

static func title_overlay_data(comment_barrage: String, screen_shake_enabled: bool, selected_index: int) -> Dictionary:
	return {
		"center": title_center(),
		"panel": title_panel_data(),
		"lines": DisplayTextSystem.title_lines(comment_barrage, screen_shake_enabled, selected_index)
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
		"titleColor": Color("#101420"),
		"titleSize": 36,
		"helpPos": panel.position + help_offset,
		"helpColor": Color("#e73763"),
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
		"weaponColor": Color("#1f2a3a"),
		"passivePos": Vector2(text_x, card.position.y + 392),
		"passiveSize": 18,
		"passiveColor": Color("#1f2a3a"),
		"descriptionPos": Vector2(text_x, card.position.y + 428),
		"descriptionSize": 16,
		"textWidth": text_w,
		"roleColor": Color("#1576bc"),
		"descriptionColor": Color("#36445c")
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
		"titlePos": card.position + Vector2(24, 42),
		"titleWidth": text_w,
		"titleSize": 25,
		"descriptionPos": card.position + Vector2(24, 88),
		"descriptionSize": 16,
		"difficultyPos": card.position + Vector2(24, 154),
		"difficultySize": 19,
		"featuresPos": card.position + Vector2(24, 194),
		"featuresSize": 15,
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

static func banana_floor_data(arena: Rect2, rollback_progress: float = 0.0, appear_progress: float = 1.0) -> Dictionary:
	var rollback := clampf(rollback_progress, 0.0, 1.0)
	var appear := clampf(appear_progress, 0.0, 1.0)
	if rollback >= 0.995:
		return {}
	var visible_start_x := arena.position.x
	var visible_end_x := arena.end.x
	var transition_mode := ""
	var transition_progress := 1.0
	var edge_x := arena.position.x
	if rollback > 0.0:
		visible_start_x = arena.position.x + arena.size.x * rollback
		transition_mode = "rollback"
		transition_progress = rollback
		edge_x = visible_start_x
	elif appear < 0.995:
		visible_end_x = arena.position.x + arena.size.x * appear
		transition_mode = "appear"
		transition_progress = appear
		edge_x = visible_end_x
	var visible_width := maxf(0.0, visible_end_x - visible_start_x)
	if visible_width <= 1.0:
		return {}
	var bananas: Array = []
	var banana_count: int = clampi(int(arena.size.x * arena.size.y / 26000.0), 48, 120)
	var edge_fade_width := 150.0
	for i in range(banana_count):
		var fx: float = fmod(float(i * 173 + 41), 997.0) / 997.0
		var fy: float = fmod(float(i * 251 + 83), 991.0) / 991.0
		var pos := Vector2(
			arena.position.x + 70.0 + fx * maxf(1.0, arena.size.x - 140.0),
			arena.position.y + 70.0 + fy * maxf(1.0, arena.size.y - 140.0)
		)
		if pos.x < visible_start_x or pos.x > visible_end_x:
			continue
		var alpha := 1.0
		if transition_mode == "rollback":
			alpha = clampf((pos.x - visible_start_x) / edge_fade_width, 0.24, 1.0)
		elif transition_mode == "appear":
			alpha = clampf((visible_end_x - pos.x) / edge_fade_width, 0.24, 1.0)
		bananas.append({
			"pos": pos,
			"size": 30.0 + fmod(float(i * 37), 18.0),
			"rotation": fmod(float(i * 29), 628.0) / 100.0,
			"alpha": alpha
		})
	return {
		"arenaRect": arena,
		"overlayRect": Rect2(Vector2(visible_start_x, arena.position.y), Vector2(visible_width, arena.size.y)),
		"overlayColor": Color(1.0, 0.78, 0.04, 0.26),
		"rollbackProgress": rollback,
		"appearProgress": appear,
		"transitionMode": transition_mode,
		"transitionProgress": transition_progress,
		"edgeX": edge_x,
		"rollX": edge_x,
		"bananas": bananas,
		"bananaTexturePath": "res://assets/generated/banana_floor_sprite_v1/banana.png",
		"bananaColor": Color("#ffe03a"),
		"bananaOutlineColor": Color(1.0, 0.53, 0.03, 0.62)
	}

static func arena_effect_data(arena: Rect2, has_banana_floor: bool, effect_pits: Array, banana_rollback_progress: float = 1.0, banana_appear_progress: float = 1.0) -> Dictionary:
	var pits: Array = []
	for pit in effect_pits:
		var pit_item: Dictionary = pit as Dictionary
		pits.append(pit_draw_data(Vector2(pit_item["pos"]), float(pit_item["radius"])))
	var banana_data: Dictionary = {}
	if has_banana_floor:
		banana_data = banana_floor_data(arena, 0.0, banana_appear_progress)
	elif banana_rollback_progress < 1.0:
		banana_data = banana_floor_data(arena, banana_rollback_progress, 1.0)
	return {
		"bananaFloor": banana_data,
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
				"texturePath": String(banana_data["bananaTexturePath"]),
				"color": banana_data["bananaColor"] as Color,
				"outlineColor": banana_data["bananaOutlineColor"] as Color
			})
		if String(banana_data.get("transitionMode", "")) != "":
			parts.append({"kind": "banana_roll_edge", "data": banana_data})
	for pit in (arena_effects["pits"] as Array):
		parts.append({"kind": "pit_image", "data": pit as Dictionary})
	return parts

static func static_wall_rects(frame_id: String = "zatsudan") -> Array:
	var map_data: Dictionary = MapBackgroundSystemScript.background_data_for_stream_frame(frame_id)
	return MapBackgroundSystemScript.static_wall_rects_for_data(map_data)

static func arena_wall_draw_list(effect_walls: Array, include_static_walls: bool = true) -> Array:
	var walls: Array = []
	if include_static_walls:
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
		"fillColor": Color("#7b6f7f") if temporary else Color("#d5c2b0"),
		"topRect": Rect2(rect.position, Vector2(rect.size.x, top_height)),
		"topColor": Color("#c0a5d8") if temporary else Color("#f0deca"),
		"borderColor": Color("#241b2f") if temporary else Color("#282437"),
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
		"texturePath": "res://assets/generated/damage_floor_sprite_v1/damage_floor.png",
		"textureSize": Vector2(radius * 3.25, radius * 2.65),
		"textureAlpha": 0.98,
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
	var amount: int = 24
	var alpha: float = 0.72
	var size: int = 31
	if setting == 0:
		amount = 13
		alpha = 0.62
		size = 28
	elif setting == 2:
		amount = 38
		alpha = 0.82
		size = 34
	if kuso_active:
		amount = int(float(amount) * 1.5)
		alpha = minf(0.92, alpha + 0.10)
		size += 3
	return {"amount": amount, "alpha": alpha, "size": size}

static func comment_storm_position(arena: Rect2, elapsed: float, index: int) -> Vector2:
	var travel_width: float = arena.size.x + 520.0
	var speed: float = 118.0 + float(index % 5) * 22.0
	var x: float = arena.end.x + 220.0 - fposmod(elapsed * speed + float(index * 181), travel_width)
	var y: float = arena.position.y + 48.0 + fposmod(float(index * 61), arena.size.y - 96.0)
	return Vector2(x, y)

static func comment_storm_color(index: int, alpha: float, kuso_active: bool) -> Color:
	var palette: Array[Color] = [
		Color("#ff2f8d"),
		Color("#7b2cff"),
		Color("#00a3d9"),
		Color("#ff8a00"),
		Color("#ffffff")
	]
	if kuso_active:
		palette = [
			Color("#ff235f"),
			Color("#a000ff"),
			Color("#ff4a00"),
			Color("#00d1ff"),
			Color("#ffffff")
		]
	var color: Color = palette[index % palette.size()]
	color.a = alpha
	return color

static func comment_storm_draw_data(arena: Rect2, elapsed: float, setting: int, kuso_active: bool, samples: Array[String]) -> Array:
	var style: Dictionary = comment_storm_style(setting, kuso_active)
	var amount: int = int(style["amount"])
	var alpha: float = float(style["alpha"])
	var size: int = int(style["size"])
	var items: Array = []
	for i in range(amount):
		items.append({
			"pos": comment_storm_position(arena, elapsed, i),
			"text": samples[i % samples.size()],
			"size": size,
			"color": comment_storm_color(i, alpha, kuso_active)
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
	var label_pos: Vector2 = rect.position + Vector2(14, 18)
	var value_pos: Vector2 = rect.position + Vector2(14, 42)
	var value_width: int = int(rect.size.x - 22)
	var label_size: int = 15
	var value_size: int = 26
	if rect.position.y >= 790.0:
		label_pos = rect.position + Vector2(48, 17)
		value_pos = rect.position + Vector2(48, 37)
		value_width = int(rect.size.x - 58)
		label_size = 14
		value_size = 24
		if rect.position.x >= 900.0:
			label_pos = rect.position + Vector2(14, 17)
			value_pos = rect.position + Vector2(14, 37)
			value_width = int(rect.size.x - 22)
		elif rect.position.x >= 780.0:
			value_pos = rect.position + Vector2(48, 33)
	elif rect.position.y < 120.0 and rect.position.x < 620.0:
		label_pos = rect.position + Vector2(48, 17)
		value_pos = rect.position + Vector2(48, 38)
		value_width = int(rect.size.x - 58)
		if rect.position.y >= 70.0:
			label_pos = rect.position + Vector2(58, 17)
			value_pos = rect.position + Vector2(58, 36)
			value_width = int(rect.size.x - 68)
	return {
		"rect": rect,
		"fill": Color(0.98, 0.985, 1.0, 0.94),
		"border": Color("#b8d9ff"),
		"borderWidth": 3,
		"accentRect": Rect2(rect.position + Vector2(0, rect.size.y - 5), Vector2(rect.size.x, 5)),
		"accent": accent,
		"labelPos": label_pos,
		"labelColor": Color("#1e2a3a"),
		"labelSize": label_size,
		"valuePos": value_pos,
		"valueWidth": value_width,
		"valueSize": value_size,
		"valueColor": Color("#101420")
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
		"sideFill": Color(0.985, 0.99, 1.0, 0.94),
		"sideBorder": Color("#ff6fa8"),
		"sideBorderWidth": 4,
		"sideDividerStart": Vector2(side.position.x + 20, side.position.y + 48),
		"sideDividerEnd": Vector2(side.end.x - 20, side.position.y + 48),
		"sideDividerColor": Color("#d5e6ff"),
		"sideDividerWidth": 2,
		"viewerPos": Vector2(1382, 143),
		"viewerText": "",
		"viewerSize": 24,
		"viewerColor": Color("#ff4f92"),
		"hudRect": hud,
		"hudFill": Color(0.985, 0.99, 1.0, 0.94),
		"hudBorder": Color("#b8d9ff"),
		"hudBorderWidth": 4
	}

static func hud_metric_specs(comment_alert: bool, _burn_combo: int, _heart_pending: bool) -> Array:
	var items: Array = [
		{"key": "time", "rect": Rect2(34, 22, 170, 46), "label": "残り", "accent": Color("#fff45c")},
		{"key": "streamFrame", "rect": Rect2(214, 22, 185, 46), "label": "配信枠", "accent": Color("#8df7ff")},
		{"key": "multiplier", "rect": Rect2(410, 22, 210, 46), "label": "ボルテージ", "accent": Color("#ff8a31")}
	]
	items.append({"key": "burn", "rect": Rect2(630, 22, 168, 46), "label": "バズ度", "accent": Color("#ff4b68")})
	var next_rect := Rect2(808, 22, 322, 46)
	items.append({
		"key": "nextInstruction",
		"rect": next_rect,
		"label": "WARNING" if comment_alert else "次の指示コメ",
		"accent": Color("#ff4b68") if comment_alert else Color("#8df7ff")
	})
	items.append({"key": "currentComment", "rect": Rect2(34, 74, 764, 42), "label": "現在の指示コメ", "accent": Color("#f3f0ff")})
	items.append_array([
		{"key": "hp", "rect": Rect2(34, 804, 166, 46), "label": "メンタル", "accent": Color("#4ade80")},
		{"key": "viewer", "rect": Rect2(212, 804, 276, 46), "label": "同時視聴者数", "accent": Color("#8df7ff")},
		{"key": "hype", "rect": Rect2(500, 804, 168, 46), "label": "ギフト期待度", "accent": Color("#ff5a78")}
	])
	items.append({"key": "heart", "rect": Rect2(680, 804, 230, 46), "label": "", "accent": Color("#ff91c8")})
	return items

static func hud_metric_draw_data(metric_values: Dictionary, comment_alert: bool, burn_combo: int, heart_pending: bool) -> Array:
	var items: Array = []
	for spec in hud_metric_specs(comment_alert, burn_combo, heart_pending):
		var item: Dictionary = spec as Dictionary
		var key: String = String(item["key"])
		var metric: Dictionary = metric_panel_draw_data(item["rect"] as Rect2, String(item["label"]), String(metric_values[key]), item["accent"] as Color)
		if (metric["rect"] as Rect2).position.y >= 790.0:
			metric["valueColor"] = Color("#101420")
			if key == "hp":
				metric["labelPos"] = (metric["rect"] as Rect2).position + Vector2(16, 17)
				metric["valuePos"] = (metric["rect"] as Rect2).position + Vector2(16, 37)
				metric["valueWidth"] = int((metric["rect"] as Rect2).size.x - 28)
		items.append(metric)
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
	var hp_text: String = "??%" if bool(context["hideHp"]) else "%d%%" % int(round(hp_ratio(int(context["playerHp"]), int(context["playerMaxHp"])) * 100.0))
	var current_comment_text: String = String(context["currentComment"])
	if current_comment_text.strip_edges() == "" or current_comment_text == "なし":
		current_comment_text = "なし"
	else:
		current_comment_text += "　%02d秒" % maxi(0, int(ceil(float(context.get("effectTimer", 0.0)))))
	return {
		"metrics": {
			"hp": hp_text,
			"time": "%02d:%02d" % [remaining / 60, remaining % 60],
			"streamFrame": String(context.get("streamFrameName", "雑談枠")),
			"multiplier": "x%.1f" % float(context["multiplier"]),
			"burn": "%d / 10" % int(context["burnCombo"]),
			"hype": "%d%%" % int(context["giftHype"]),
			"heart": "待機中" if bool(context["heartPending"]) else "なし",
			"viewer": "%s人が視聴中" % format_viewer_count(int(context.get("score", 0))),
			"currentComment": current_comment_text,
			"nextInstruction": "あと %.1fs" % maxf(0.0, float(context.get("commentTimer", 0.0)))
		},
		"expRatio": float(context["expValue"]) / float(exp_need),
		"hypeRatio": float(context["giftHype"]) / 100.0,
		"hpRatio": visual_hp_ratio(int(context["playerHp"]), int(context["playerMaxHp"]), bool(context["hideHp"]), float(context["elapsed"])),
		"hideHp": bool(context["hideHp"])
	}

static func hud_gauge_data(exp_ratio: float, hype_ratio: float, _hp_value_ratio: float) -> Array:
	var gauges: Array = []
	gauges.append_array([
		{
			"label": "EXP",
			"backRect": Rect2(Vector2(34, 862), Vector2(360, 8)),
			"fillRect": Rect2(Vector2(34, 862), Vector2(360 * exp_ratio, 8)),
			"backColor": Color("#d8ecff"),
			"fillColor": Color("#24a8ff"),
			"labelPos": Vector2(34, 884),
			"labelColor": Color("#1576bc"),
			"labelWidth": -1,
			"labelSize": 14
		},
		{
			"label": "ギフト期待度",
			"backRect": Rect2(Vector2(430, 862), Vector2(280, 8)),
			"fillRect": Rect2(Vector2(430, 862), Vector2(280 * hype_ratio, 8)),
			"backColor": Color("#ffe1eb"),
			"fillColor": gift_hype_color(hype_ratio),
			"labelPos": Vector2(430, 884),
			"labelColor": Color("#e33e78"),
			"labelWidth": -1,
			"labelSize": 14
		}
	])
	return gauges

static func gift_hype_color(hype_ratio: float) -> Color:
	if hype_ratio >= 0.9:
		return Color("#fff45c")
	if hype_ratio >= 0.7:
		return Color("#ffcf5a")
	if hype_ratio >= 0.4:
		return Color("#ff91aa")
	return Color("#ff5a78")

static func equipment_icon(id: String, is_weapon: bool) -> String:
	var icons: Dictionary = {
		"ban_hammer": "鎚",
		"ban_judgement": "裁",
		"superchat_shot": "弾",
		"starlight_superchat": "星",
		"comment_boomerang": "ブ",
		"maro_comment_ring": "輪",
		"mic_barrier": "マ",
		"spotlight": "光",
		"kusa_wave": "草",
		"comment_pin": "ピ",
		"emote_mine": "雷",
		"ng_word_laser": "NG",
		"listener_summon": "聴",
		"stream_power": "力",
		"bullet_support": "援",
		"high_speed_connection": "速",
		"wide_angle": "広",
		"light_sneakers": "靴",
		"sweet_tooth": "甘",
		"mental_care": "心",
		"notification_bell": "鈴",
		"comment_radar": "探",
		"mini_humidifier": "潤"
	}
	return String(icons.get(id, "武" if is_weapon else "ア"))

static func equipment_slot_text(items: Array, max_slots: int, is_weapon: bool) -> String:
	var chunks: Array[String] = []
	for i in range(max_slots):
		if i >= items.size():
			chunks.append("[空]")
			continue
		var entry: Dictionary = items[i] as Dictionary
		var id: String = String(entry.get("id", ""))
		var level_text: String = "進" if EquipmentSystem.is_evolved_entry(entry) else str(EquipmentSystem.entry_level(entry))
		chunks.append("[%s%s]" % [equipment_icon(id, is_weapon), level_text])
	return "".join(chunks)

static func hud_equipment_draw_data(context: Dictionary) -> Array:
	var weapon_panel: Dictionary = metric_panel_draw_data(Rect2(920, 804, 266, 46), "武器", "", Color("#fff45c"))
	var accessory_panel: Dictionary = metric_panel_draw_data(Rect2(1198, 804, 332, 46), "アクセ", "", Color("#8df7ff"))
	weapon_panel["valueSize"] = 19
	accessory_panel["valueSize"] = 19
	return [weapon_panel, accessory_panel]

static func hud_gauge_draw_data(hud_values: Dictionary) -> Array:
	return hud_gauge_data(float(hud_values["expRatio"]), float(hud_values["hypeRatio"]), float(hud_values["hpRatio"]))

static func hud_metric_parts() -> Array:
	return [
		{"kind": "panel"},
		{"kind": "rect_keys", "rectKey": "accentRect", "colorKey": "accent"},
		{"kind": "text", "prefix": "label"},
		{"kind": "text", "prefix": "value", "colorKey": "accent"}
	]

static func hud_metric_text_parts() -> Array:
	return [
		{"kind": "text", "prefix": "label"},
		{"kind": "text", "prefix": "value"}
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
		"metrics": hud_metric_draw_data(metric_values, float(context["commentTimer"]) <= 5.0, int(context["burnCombo"]), bool(context["heartPending"])),
		"gauges": hud_gauge_draw_data(values),
		"equipment": hud_equipment_draw_data(context)
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

static func choice_backplate_data(state: String = "") -> Dictionary:
	if state == "gift_choice":
		var gift_rect: Rect2 = Rect2(Vector2(270, 160), Vector2(890, 500))
		return {
			"rect": gift_rect,
			"imagePath": "res://assets/generated/ui_parts_v1/gift_choice_panel.png",
			"textBaked": true,
			"fill": Color(1.0, 0.985, 0.995, 0.94),
			"border": Color("#ff5a9a"),
			"borderWidth": 5,
			"title": "ギフトが届いた！",
			"subtitle": "どれを受け取る？",
			"titlePos": gift_rect.position + Vector2(200, 58),
			"titleWidth": 500,
			"titleSize": 40,
			"titleColor": Color("#e73763"),
			"subtitlePos": gift_rect.position + Vector2(332, 108),
			"subtitleWidth": 260,
			"subtitleSize": 24,
			"subtitleColor": Color("#101420"),
			"help": "1 / 2 / 3 で選択",
			"helpPos": gift_rect.position + Vector2(352, 490),
			"helpWidth": 260,
			"helpSize": 16,
			"helpColor": Color("#36445c")
		}
	if state == "comment_choice":
		return {
			"rect": Rect2(Vector2(270, 145), Vector2(930, 560)),
			"imagePath": "res://assets/generated/ui_parts_v1/comment_choice_panel.png",
			"textBaked": true,
			"fill": Color(0.02, 0.0, 0.0, 0.76),
			"border": Color("#ff2a2a"),
			"borderWidth": 4
		}
	var rect: Rect2 = Rect2(Vector2(430, 126), Vector2(790, 365))
	return {
		"rect": rect,
		"fill": Color(0.02, 0.02, 0.04, 0.48),
		"border": Color("#5b2b88"),
		"borderWidth": 4
	}

static func choice_backplate_text_parts(data: Dictionary) -> Array:
	var parts: Array = []
	if bool(data.get("textBaked", false)):
		return parts
	for prefix in ["title", "subtitle", "help"]:
		if data.has(prefix):
			parts.append({"kind": "text", "prefix": prefix, "alignment": HORIZONTAL_ALIGNMENT_CENTER})
	return parts

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
	var toast_width: float = clampf(360.0 + float(text.length()) * 14.0, 500.0, 660.0)
	var rect := Rect2(Vector2(1180.0 - toast_width, 732.0), Vector2(toast_width, 50.0))
	var border := Color("#8df7ff")
	if text.contains("クソマロ") or text.contains("ブロック"):
		border = Color("#ff4b68")
	return {
		"rect": rect,
		"fill": Color(0.04, 0.035, 0.06, 0.88),
		"border": border,
		"borderWidth": 3,
		"textPos": rect.position + Vector2(18, 34),
		"textWidth": int(rect.size.x - 36),
		"fontSize": 21 if text.length() >= 24 else 23,
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
	if uses_run_sheet:
		if player_vel.x < -18.0:
			draw_data["flipX"] = true
		elif player_vel.x > 18.0:
			draw_data["flipX"] = false
		else:
			draw_data["flipX"] = player_facing_x < -0.1
	else:
		draw_data["flipX"] = player_facing_x < -0.1
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
	if kind == "boss_super_long_comment":
		return Color("#332255")
	if kind == "boss_kuso_maro_king":
		return Color("#5b294f")
	return Color("#7650bd")

static func enemy_shadow_data(pos: Vector2, radius: float) -> Dictionary:
	return {
		"pos": pos + Vector2(0, radius * 0.72),
		"size": Vector2(radius * 2.15, radius * 0.7),
		"alpha": 0.25
	}

static func enemy_sprite_path(kind: String) -> String:
	if kind == "troll":
		return "res://assets/generated/enemy_sprites_v1/troll.png"
	if kind == "fast":
		return "res://assets/generated/enemy_sprites_v1/rapid_poster.png"
	if kind == "shooter":
		return "res://assets/generated/enemy_sprites_v1/backseat_commenter.png"
	if kind == "long_comment_guy":
		return "res://assets/generated/enemy_sprites_v1/long_comment_guy.png"
	if kind == "clipper":
		return "res://assets/generated/enemy_sprites_v1/clipper.png"
	if kind == "unread_maro":
		return "res://assets/generated/enemy_sprites_v1/unread_maro.png"
	if kind == "ghost_comment":
		return "res://assets/generated/enemy_sprites_v1/ghost_comment.png"
	if kind == "boss_super_long_comment":
		return "res://assets/generated/enemy_sprites_v1/super_long_comment_boss.png"
	if kind == "boss_kuso_maro_king":
		return "res://assets/generated/enemy_sprites_v1/kuso_maro_king.png"
	return ""

static func enemy_body_data(kind: String, pos: Vector2, radius: float, color: Color, flash_color: Color = Color.TRANSPARENT, flash_strength: float = 0.0) -> Dictionary:
	var body_color: Color = color.lerp(flash_color, clampf(flash_strength, 0.0, 1.0))
	var sprite_path: String = enemy_sprite_path(kind)
	if sprite_path != "":
		var size: Vector2 = Vector2(radius * 4.35, radius * 4.35)
		return {
			"kind": "sprite",
			"texturePath": sprite_path,
			"rect": Rect2(pos - size * 0.5 + Vector2(0, -radius * 0.08), size),
			"modulate": Color.WHITE.lerp(flash_color, clampf(flash_strength * 0.72, 0.0, 0.72))
		}
	if kind == "long_comment_guy":
		var body: Rect2 = Rect2(pos - Vector2(radius * 1.35, radius * 0.65), Vector2(radius * 2.7, radius * 1.3))
		return {
			"kind": "long",
			"rect": body,
			"shadowRect": body.grow(4),
			"shadowColor": Color("#241d18"),
			"color": body_color,
			"topRect": Rect2(body.position, Vector2(body.size.x, 8)),
			"topColor": Color("#a29273").lerp(flash_color, clampf(flash_strength * 0.5, 0.0, 0.5))
		}
	if kind == "boss_super_long_comment":
		var boss_body: Rect2 = Rect2(pos - Vector2(radius * 1.55, radius * 0.90), Vector2(radius * 3.10, radius * 1.80))
		return {
			"kind": "boss_long",
			"rect": boss_body,
			"shadowRect": boss_body.grow(8),
			"shadowColor": Color("#100916"),
			"color": body_color,
			"topRect": Rect2(boss_body.position, Vector2(boss_body.size.x, 13)),
			"topColor": Color("#5f3da0").lerp(flash_color, clampf(flash_strength * 0.45, 0.0, 0.45)),
			"motif1Rect": Rect2(boss_body.position + Vector2(radius * 0.24, radius * 0.42), Vector2(radius * 0.88, 7)),
			"motif1Color": Color("#8b6be0"),
			"motif2Rect": Rect2(boss_body.position + Vector2(radius * 1.30, radius * 0.68), Vector2(radius * 1.10, 7)),
			"motif2Color": Color("#b08cff"),
			"motif3Rect": Rect2(boss_body.position + Vector2(radius * 0.50, radius * 1.04), Vector2(radius * 0.72, 7)),
			"motif3Color": Color("#7250c0"),
			"motif4Rect": Rect2(boss_body.position + Vector2(radius * 1.58, radius * 1.20), Vector2(radius * 0.82, 7)),
			"motif4Color": Color("#c1adff")
		}
	if kind == "clipper":
		var cam: Rect2 = Rect2(pos - Vector2(radius * 1.0, radius * 0.72), Vector2(radius * 2.0, radius * 1.44))
		return {
			"kind": "clipper",
			"rect": cam,
			"shadowRect": cam.grow(4),
			"shadowColor": Color("#2a1518"),
			"color": body_color,
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
		"color": body_color,
		"highlightPos": pos + Vector2(-radius * 0.22, -radius * 0.25),
		"highlightRadius": radius * 0.32,
		"highlightColor": body_color.lightened(0.28)
	}

static func enemy_hit_flash_color(kind: String) -> Color:
	if kind.begins_with("boss_"):
		return Color("#a3262d")
	if kind == "long_comment_guy":
		return Color("#ff6348")
	return Color("#ff3f2d")

static func enemy_hit_flash_strength(enemy: Dictionary) -> float:
	var duration: float = maxf(0.01, float(enemy.get("hitFlashDuration", 0.10)))
	var timer: float = clampf(float(enemy.get("hitFlashTimer", 0.0)), 0.0, duration)
	var strength: float = timer / duration
	if bool(enemy.get("isBoss", false)) or String(enemy.get("kind", "")).begins_with("boss_"):
		strength *= 0.55
	return clampf(strength, 0.0, 1.0)

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

static func speech_bubble_data(pos: Vector2, text: String, y_offset: float, width: float = 118.0) -> Dictionary:
	var clean_text: String = text.strip_edges()
	if clean_text == "":
		return {}
	if clean_text.length() > 12:
		clean_text = clean_text.substr(0, 12)
	var height: float = 30.0
	var rect := Rect2(pos + Vector2(-width * 0.5, y_offset), Vector2(width, height))
	var tail_tip: Vector2 = pos + Vector2(0.0, y_offset + height + 9.0)
	var tail := PackedVector2Array([
		rect.position + Vector2(width * 0.43, height - 1.0),
		rect.position + Vector2(width * 0.57, height - 1.0),
		tail_tip
	])
	return {
		"rect": rect,
		"tail": tail,
		"fill": Color(1.0, 1.0, 0.96, 0.92),
		"border": Color("#4b5563"),
		"borderWidth": 2,
		"text": clean_text,
		"pos": rect.position + Vector2(9.0, 21.0),
		"width": int(width - 18.0),
		"size": 14,
		"color": Color("#1f2937")
	}

static func enemy_draw_data(enemy: Dictionary) -> Dictionary:
	var kind: String = String(enemy["kind"])
	var pos: Vector2 = Vector2(enemy["pos"])
	var radius: float = float(enemy["radius"])
	var is_boss: bool = bool(enemy.get("isBoss", false)) or kind.begins_with("boss_")
	if bool(enemy.get("defeatPending", false)) and is_boss:
		var max_delay: float = maxf(0.01, float(enemy.get("defeatDelayMax", 0.55)))
		var left: float = clampf(float(enemy.get("defeatDelay", 0.0)), 0.0, max_delay)
		var progress: float = clampf(1.0 - left / max_delay, 0.0, 1.0)
		var clock: float = float(Time.get_ticks_msec()) / 1000.0
		var shake: float = lerpf(5.0, 1.2, progress)
		pos += Vector2(sin(clock * 56.0), cos(clock * 47.0)) * shake
		radius *= 1.0 + sin(progress * PI) * 0.055
	var color: Color = enemy_color(kind)
	var speech_text: String = String(enemy.get("speechText", ""))
	var flash_strength: float = enemy_hit_flash_strength(enemy)
	var flash_color: Color = enemy.get("hitFlashColor", enemy_hit_flash_color(kind)) as Color
	return {
		"kind": kind,
		"pos": pos,
		"radius": radius,
		"shadow": enemy_shadow_data(pos, radius),
		"body": enemy_body_data(kind, pos, radius, color, flash_color, flash_strength),
		"face": {} if kind == "long_comment_guy" or kind == "boss_super_long_comment" or enemy_sprite_path(kind) != "" else enemy_face_data(pos),
		"bar": enemy_hp_bar_data(pos, radius, float(enemy["hp"]), float(enemy["max_hp"])),
		"speech": speech_bubble_data(pos, speech_text, -radius - 54.0)
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
	if body_kind == "sprite":
		return [
			{"kind": "sprite"}
		]
	if body_kind == "long":
		return [
			{"kind": "rect", "prefix": "shadow"},
			{"kind": "rect", "prefix": ""},
			{"kind": "rect", "prefix": "top"}
		]
	if body_kind == "boss_long":
		return [
			{"kind": "rect", "prefix": "shadow"},
			{"kind": "rect", "prefix": ""},
			{"kind": "rect", "prefix": "top"},
			{"kind": "rect", "prefix": "motif1"},
			{"kind": "rect", "prefix": "motif2"},
			{"kind": "rect", "prefix": "motif3"},
			{"kind": "rect", "prefix": "motif4"}
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
	if not (enemy_draw["speech"] as Dictionary).is_empty():
		parts.append({"kind": "speech", "data": enemy_draw["speech"] as Dictionary})
	return parts

static func exp_orb_data(base_pos: Vector2, elapsed_time: float, value: int = 1, visual_type: String = "small_blue") -> Dictionary:
	var pos: Vector2 = base_pos
	pos.y += sin(elapsed_time * 8.0 + pos.x * 0.05) * 2.0
	var radius_x := 11.0
	var radius_y := 13.0
	var shadow_size := Vector2(22, 7)
	var colors := PackedColorArray([Color("#5ad7ff"), Color("#24a8ff"), Color("#116bce"), Color("#82f0ff")])
	if value >= 10 or visual_type == "gold_rainbow":
		radius_x = 18.0
		radius_y = 21.0
		shadow_size = Vector2(34, 10)
		colors = PackedColorArray([Color("#fff36b"), Color("#ffbc2e"), Color("#ff6fd8"), Color("#8ef7ff")])
	elif value >= 4 or visual_type == "large_blue" or visual_type == "large_red":
		radius_x = 16.0
		radius_y = 18.0
		shadow_size = Vector2(30, 9)
		colors = PackedColorArray([Color("#ff9a86"), Color("#ff3f4f"), Color("#b8142a"), Color("#ffd0bf")])
	elif value >= 2 or visual_type == "medium_blue" or visual_type == "medium_green":
		radius_x = 13.5
		radius_y = 16.0
		shadow_size = Vector2(26, 8)
		colors = PackedColorArray([Color("#b7ff8a"), Color("#4fe35f"), Color("#159b39"), Color("#e2ffd0")])
	var diamond := PackedVector2Array([
		pos + Vector2(0, -radius_y),
		pos + Vector2(radius_x, 0),
		pos + Vector2(0, radius_y),
		pos + Vector2(-radius_x, 0)
	])
	return {
		"pos": pos,
		"shadowPos": pos + Vector2(0, 12),
		"shadowSize": shadow_size,
		"shadowAlpha": 0.16,
		"diamond": diamond,
		"colors": colors,
		"outline": PackedVector2Array([diamond[0], diamond[1], diamond[2], diamond[3], diamond[0]]),
		"outlineColor": Color.WHITE,
		"outlineWidth": 2.0
	}

static func exp_orbs_draw_data(exp_orbs: Array, elapsed_time: float) -> Array:
	var items: Array = []
	for orb in exp_orbs:
		var orb_item: Dictionary = orb as Dictionary
		items.append(exp_orb_data(
			Vector2(orb_item["pos"]),
			elapsed_time,
			int(orb_item.get("value", 1)),
			String(orb_item.get("visualType", "small_blue"))
		))
	return items

static func exp_orb_parts() -> Array:
	return [
		{"kind": "shadow"},
		{"kind": "polygon", "pointsKey": "diamond", "colorsKey": "colors"},
		{"kind": "polyline", "pointsKey": "outline", "colorKey": "outlineColor", "widthKey": "outlineWidth"}
	]

static func marshmallow_visual(visual_type: String) -> Dictionary:
	var radius: float = 20.0
	var color: Color = Color("#fff7ef")
	var image_path: String = "res://assets/generated/field_pickup_icons_v1/icons/marshmallow_normal_white.png"
	if visual_type == "pink_heart":
		color = Color("#ffd4e6")
		image_path = "res://assets/generated/field_pickup_icons_v1/icons/marshmallow_pink_heart.png"
	elif visual_type == "cream_star":
		color = Color("#fff0b8")
		image_path = "res://assets/generated/field_pickup_icons_v1/icons/marshmallow_cream_star.png"
	elif visual_type == "gold_rainbow":
		color = Color("#ffe66d")
		radius = 24.0
		image_path = "res://assets/generated/field_pickup_icons_v1/icons/marshmallow_gold_rainbow.png"
	elif visual_type == "gray_bad":
		color = Color("#8a8488")
		radius = 19.0
		image_path = "res://assets/generated/field_pickup_icons_v1/icons/marshmallow_gray_bad.png"
	elif visual_type == "purple_smoke":
		color = Color("#7750a0")
		radius = 19.0
		image_path = "res://assets/generated/field_pickup_icons_v1/icons/marshmallow_purple_smoke.png"
	elif visual_type == "green_bad":
		color = Color("#7ba66a")
		radius = 19.0
		image_path = "res://assets/generated/field_pickup_icons_v1/icons/marshmallow_green_bad.png"
	elif visual_type == "burnt_bad":
		color = Color("#332025")
		radius = 20.0
		image_path = "res://assets/generated/field_pickup_icons_v1/icons/marshmallow_burnt_bad.png"
	return {"color": color, "radius": radius, "imagePath": image_path}

static func marshmallow_draw_data(base_pos: Vector2, item_data: Dictionary, time_left: float, elapsed_time: float, appraisal: bool, speech_text: String = "") -> Dictionary:
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
		"imagePath": String(visual.get("imagePath", "")),
		"imageSize": Vector2((radius + 12.0) * 2.0, (radius + 12.0) * 2.0),
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
		"timeWidth": -1,
		"speech": speech_bubble_data(pos, speech_text, -72.0, 112.0)
	}

static func marshmallow_draw_list(marshmallows: Array, elapsed_time: float, appraisal: bool) -> Array:
	var items: Array = []
	for item in marshmallows:
		var mallow: Dictionary = item as Dictionary
		var data: Dictionary = mallow["data"] as Dictionary
		items.append(marshmallow_draw_data(Vector2(mallow["pos"]), data, float(mallow["time"]), elapsed_time, appraisal, String(mallow.get("speechText", ""))))
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
	if not (visual["speech"] as Dictionary).is_empty():
		parts.append({"kind": "speech", "data": visual["speech"] as Dictionary})
	return parts

static func bullet_visual(player_owned: bool, bullet_item: Dictionary = {}) -> Dictionary:
	if player_owned:
		var visual_kind: String = String(bullet_item.get("visualKind", ""))
		if visual_kind == "high_superchat":
			return {
				"trailLength": 44.0,
				"trailColor": Color(1.0, 0.64, 0.20, 0.50),
				"trailWidth": 13.0,
				"outerRadius": 15.0,
				"outerColor": Color("#ffb52e"),
				"innerRadius": 8.0,
				"innerColor": Color("#fff8d8"),
				"glowRadius": 22.0,
				"glowColor": Color(1.0, 0.86, 0.24, 0.26),
				"starColor": Color(1.0, 0.98, 0.42, 0.82),
				"label": "￥"
			}
		if visual_kind == "starlight_superchat":
			return {
				"trailLength": 32.0,
				"trailColor": Color(0.58, 0.96, 1.0, 0.34),
				"trailWidth": 8.0,
				"outerRadius": 10.0,
				"outerColor": Color("#fff45c"),
				"innerRadius": 4.5,
				"innerColor": Color.WHITE,
				"glowRadius": 15.0,
				"glowColor": Color(0.45, 0.88, 1.0, 0.18),
				"starColor": Color(1.0, 0.96, 0.36, 0.76),
				"label": ""
			}
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
	var items: Array = []
	for bullet in bullets:
		var bullet_item: Dictionary = bullet as Dictionary
		var visual: Dictionary = bullet_visual(player_owned, bullet_item)
		if not player_owned and String(bullet_item.get("visualKind", "")) == "kuso_maro":
			visual = {
				"trailLength": 16.0,
				"trailColor": Color(0.34, 0.04, 0.48, 0.34),
				"trailWidth": 9.0,
				"outerRadius": 13.0,
				"outerColor": Color("#4c2c4f"),
				"innerRadius": 8.0,
				"innerColor": Color("#f094bd")
			}
		var pos: Vector2 = Vector2(bullet_item["pos"])
		var vel: Vector2 = Vector2(bullet_item["vel"]).normalized()
		if vel.length() < 0.1:
			vel = Vector2.RIGHT
		var side: Vector2 = Vector2(-vel.y, vel.x)
		var visual_kind: String = String(bullet_item.get("visualKind", ""))
		var item := {
			"visualKind": visual_kind,
			"trailStart": pos - vel * float(visual["trailLength"]),
			"trailEnd": pos,
			"trailColor": visual["trailColor"] as Color,
			"trailWidth": visual["trailWidth"],
			"pos": pos,
			"outerRadius": visual["outerRadius"],
			"outerColor": visual["outerColor"] as Color,
			"innerRadius": visual["innerRadius"],
			"innerColor": visual["innerColor"] as Color
		}
		if visual_kind == "starlight_superchat" or visual_kind == "high_superchat":
			var star_color: Color = visual["starColor"] as Color
			item["glowPos"] = pos
			item["glowRadius"] = float(visual["glowRadius"])
			item["glowColor"] = visual["glowColor"] as Color
			item["star1Text"] = "★"
			item["star1Pos"] = pos - vel * 18.0 + side * 7.0 + Vector2(-8.0, 6.0)
			item["star1Width"] = 20
			item["star1Size"] = 15
			item["star1Color"] = star_color
			item["star2Text"] = "★"
			item["star2Pos"] = pos - vel * 34.0 - side * 6.0 + Vector2(-7.0, 5.0)
			item["star2Width"] = 18
			item["star2Size"] = 11
			item["star2Color"] = Color(star_color.r, star_color.g, star_color.b, star_color.a * 0.72)
			if visual_kind == "high_superchat":
				item["star3Text"] = "★"
				item["star3Pos"] = pos - vel * 48.0 + side * 12.0 + Vector2(-7.0, 5.0)
				item["star3Width"] = 18
				item["star3Size"] = 12
				item["star3Color"] = Color(1.0, 0.86, 0.22, 0.72)
				item["labelText"] = String(visual["label"])
				item["labelPos"] = pos + Vector2(-8.0, 6.0)
				item["labelWidth"] = 18
				item["labelSize"] = 15
				item["labelColor"] = Color("#7a2d00")
		items.append(item)
	return items

static func bullet_parts(data: Dictionary = {}) -> Array:
	var visual_kind: String = String(data.get("visualKind", ""))
	if visual_kind == "high_superchat":
		return [
			{"kind": "circle", "prefix": "glow"},
			{"kind": "text", "prefix": "star3", "alignment": HORIZONTAL_ALIGNMENT_CENTER},
			{"kind": "text", "prefix": "star2", "alignment": HORIZONTAL_ALIGNMENT_CENTER},
			{"kind": "text", "prefix": "star1", "alignment": HORIZONTAL_ALIGNMENT_CENTER},
			{"kind": "line", "prefix": "trail"},
			{"kind": "circle", "prefix": "outer"},
			{"kind": "circle", "prefix": "inner"},
			{"kind": "text", "prefix": "label", "alignment": HORIZONTAL_ALIGNMENT_CENTER}
		]
	if visual_kind == "starlight_superchat":
		return [
			{"kind": "circle", "prefix": "glow"},
			{"kind": "text", "prefix": "star2", "alignment": HORIZONTAL_ALIGNMENT_CENTER},
			{"kind": "text", "prefix": "star1", "alignment": HORIZONTAL_ALIGNMENT_CENTER},
			{"kind": "line", "prefix": "trail"},
			{"kind": "circle", "prefix": "outer"},
			{"kind": "circle", "prefix": "inner"}
		]
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
		"innerWidth": 3.0,
		"textureSize": Vector2(42.0, 64.0)
	}

static func maro_comment_ring_label(index: int) -> String:
	var labels: Array[String] = ["まろ", "888", "♡", "草", "GG", "すき"]
	return labels[index % labels.size()]

static func maro_comment_ring_bubble(center: Vector2, angle: float, index: int, flash_strength: float) -> Dictionary:
	var size := Vector2(50.0, 30.0)
	var rect := Rect2(center - size * 0.5, size)
	var tail_tip: Vector2 = center + Vector2.DOWN.rotated(angle) * 18.0
	var tail := PackedVector2Array([
		center + Vector2(-8.0, size.y * 0.42),
		center + Vector2(8.0, size.y * 0.42),
		tail_tip
	])
	var fill := Color(1.0, 0.96, 0.99, 0.94)
	var border := Color("#ff91c8").lerp(Color("#fff45c"), flash_strength * 0.45)
	return {
		"rect": rect,
		"tail": tail,
		"fill": fill,
		"border": border,
		"borderWidth": 3,
		"text": maro_comment_ring_label(index),
		"pos": rect.position + Vector2(0.0, 21.0),
		"width": int(size.x),
		"size": 16,
		"color": Color("#7a3a67")
	}

static func maro_comment_ring_draw_data(player_pos: Vector2, count: int, radius: float, orbit_speed: float, elapsed_time: float, pulse_strength: float, flash_strength: float) -> Array:
	var items: Array = []
	var phase: float = elapsed_time * orbit_speed
	var halo_alpha: float = 0.16 + pulse_strength * 0.18 + flash_strength * 0.26
	items.append({
		"visualKind": "maro_comment_ring_halo",
		"pos": player_pos,
		"softPos": player_pos,
		"softRadius": radius + 18.0 + pulse_strength * 12.0,
		"softColor": Color(1.0, 0.74, 0.90, halo_alpha * 0.46),
		"ringPos": player_pos,
		"ringRadius": radius,
		"ringColor": Color(1.0, 0.92, 0.98, halo_alpha),
		"wavePoints": wavy_ring_points(player_pos, radius, 2.0 + 5.0 * maxf(pulse_strength, flash_strength), phase, 6.0),
		"waveColor": Color(0.90, 0.98, 1.0, 0.28 + flash_strength * 0.28 + pulse_strength * 0.24),
		"waveWidth": 3.0 + pulse_strength * 4.0 + flash_strength * 2.0
	})
	if count <= 0:
		return items
	for i in range(count):
		var angle: float = phase + TAU * float(i) / float(count)
		var pos: Vector2 = player_pos + Vector2(cos(angle), sin(angle)) * radius
		var bubble: Dictionary = maro_comment_ring_bubble(pos, angle, i, flash_strength)
		items.append({
			"visualKind": "maro_comment_ring_bubble",
			"pos": pos,
			"shadowPos": pos + Vector2(0.0, 14.0),
			"shadowSize": Vector2(42.0, 10.0),
			"shadowAlpha": 0.20,
			"glowPos": pos,
			"glowRadius": 22.0 + 7.0 * maxf(pulse_strength, flash_strength),
			"glowColor": Color(1.0, 0.78, 0.92, 0.10 + flash_strength * 0.18 + pulse_strength * 0.10),
			"bubble": bubble,
			"sparkText": "☆",
			"sparkPos": pos + Vector2.RIGHT.rotated(-angle * 0.7 + float(i)) * 22.0 + Vector2(-7.0, 5.0),
			"sparkWidth": 16,
			"sparkSize": 12 + int(4.0 * maxf(pulse_strength, flash_strength)),
			"sparkColor": Color(1.0, 0.92, 0.98, 0.52 + flash_strength * 0.36)
		})
	return items

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
			"innerWidth": visual["innerWidth"],
			"textureSize": visual["textureSize"] as Vector2,
			"textureAngle": angle + PI * 0.15
		})
	return items

static func boomerang_draw_data_for_weapon(player_pos: Vector2, weapon: Dictionary, boomerang_level: int, weapon_range: float, elapsed_time: float, weapon_state: Dictionary = {}, bullet_support_level: int = 0) -> Array:
	var is_main_orbit: bool = WeaponSystem.attack_type(weapon) == "orbit"
	var count: int = WeaponSystem.orbit_count(weapon, boomerang_level)
	if count > 0:
		count += bullet_support_level
	var radius: float = weapon_range if is_main_orbit else 78.0
	var orbit_speed: float = WeaponSystem.orbit_speed(weapon)
	if String(weapon.get("id", "")) == "maro_comment_ring":
		var pulse_until: float = float(weapon_state.get("__maro_comment_pulse_until", 0.0))
		var flash_until: float = float(weapon_state.get("__maro_comment_flash_until", 0.0))
		var pulse_duration: float = maxf(0.05, float(weapon.get("pulseDuration", 0.25)))
		var pulse_strength: float = 0.0
		if elapsed_time < pulse_until:
			var pulse_progress: float = clampf(1.0 - (pulse_until - elapsed_time) / pulse_duration, 0.0, 1.0)
			pulse_strength = sin(pulse_progress * PI)
			radius = lerpf(radius, maxf(radius, WeaponSystem.scaled_range(float(weapon.get("pulseOrbitRadius", 3.1)), 43.0)), pulse_strength)
		var flash_strength: float = 0.0
		if elapsed_time < flash_until:
			flash_strength = clampf((flash_until - elapsed_time) / 0.18, 0.0, 1.0)
		return maro_comment_ring_draw_data(player_pos, count, radius, orbit_speed, elapsed_time, pulse_strength, flash_strength)
	return boomerang_draw_data(player_pos, count, radius, orbit_speed, elapsed_time)

static func boomerang_parts(data: Dictionary = {}) -> Array:
	var visual_kind: String = String(data.get("visualKind", ""))
	if visual_kind == "maro_comment_ring_halo":
		return [
			{"kind": "circle", "prefix": "soft"},
			{"kind": "circle", "prefix": "ring", "filled": false, "width": 4.0},
			{"kind": "polyline", "pointsKey": "wavePoints", "colorKey": "waveColor", "widthKey": "waveWidth"}
		]
	if visual_kind == "maro_comment_ring_bubble":
		return [
			{"kind": "shadow"},
			{"kind": "circle", "prefix": "glow"},
			{"kind": "speech", "data": data["bubble"] as Dictionary},
			{"kind": "text", "prefix": "spark", "alignment": HORIZONTAL_ALIGNMENT_CENTER}
		]
	return [
		{"kind": "arc", "prefix": "outer"},
		{"kind": "arc", "prefix": "inner"}
	]

static func hit_fx_data(pos: Vector2, dir: Vector2, hit_pos: Vector2, range: float, life: float, arc_angle: float) -> Dictionary:
	var width: float = 7.0 + life * 24.0
	var angle: float = dir.angle()
	var half_arc: float = deg_to_rad(arc_angle * 0.5)
	var inner_radius: float = maxf(34.0, range * 0.42)
	var fx_duration := 0.24
	var swing_progress: float = clampf(1.0 - life / fx_duration, 0.0, 1.0)
	var swing_angle: float = angle + lerpf(-half_arc, half_arc, swing_progress)
	var hammer_pos: Vector2 = pos + Vector2.RIGHT.rotated(swing_angle) * range * 0.66
	var trail_alpha: float = clampf(life / 0.20, 0.0, 1.0)
	var trail_span: float = minf(half_arc * 0.76, deg_to_rad(92.0))
	var trail_start: float = maxf(angle - half_arc, swing_angle - trail_span)
	var trail_end: float = minf(angle + half_arc, swing_angle + deg_to_rad(9.0))
	var trail_hot_start: float = minf(trail_end - deg_to_rad(1.0), trail_start + deg_to_rad(4.0))
	var trail_core_start: float = minf(trail_end - deg_to_rad(1.0), trail_start + deg_to_rad(8.0))
	var trail_edge_start: float = maxf(trail_start, trail_end - deg_to_rad(12.0))
	var trail_radius: float = maxf(44.0, range * 0.72)
	var hammer_after_images: Array = []
	for i in range(2):
		var ghost_progress: float = maxf(0.0, swing_progress - 0.10 * float(i + 1))
		var ghost_angle: float = angle + lerpf(-half_arc, half_arc, ghost_progress)
		hammer_after_images.append({
			"pos": pos + Vector2.RIGHT.rotated(ghost_angle) * range * 0.66,
			"size": Vector2(70, 70) * (0.88 - 0.05 * float(i)),
			"angle": ghost_angle + deg_to_rad(38.0),
			"alpha": trail_alpha * (0.24 - 0.08 * float(i))
		})
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
		"trailGlowRadius": trail_radius + 3.0,
		"trailGlowStart": trail_start,
		"trailGlowEnd": trail_end,
		"trailGlowPoints": 18,
		"trailGlowColor": Color(1.0, 0.15, 0.55, 0.24 * trail_alpha),
		"trailGlowWidth": clampf(range * 0.18, 22.0, 34.0),
		"trailHotRadius": trail_radius,
		"trailHotStart": trail_hot_start,
		"trailHotEnd": trail_end,
		"trailHotPoints": 18,
		"trailHotColor": Color(1.0, 0.62, 0.16, 0.48 * trail_alpha),
		"trailHotWidth": clampf(range * 0.12, 15.0, 24.0),
		"trailCoreRadius": trail_radius - 2.0,
		"trailCoreStart": trail_core_start,
		"trailCoreEnd": trail_end,
		"trailCorePoints": 16,
		"trailCoreColor": Color(1.0, 1.0, 1.0, 0.74 * trail_alpha),
		"trailCoreWidth": clampf(range * 0.045, 6.0, 10.0),
		"trailEdgeRadius": trail_radius + 16.0,
		"trailEdgeStart": trail_edge_start,
		"trailEdgeEnd": trail_end + deg_to_rad(4.0),
		"trailEdgePoints": 8,
		"trailEdgeColor": Color(1.0, 0.96, 0.36, 0.82 * trail_alpha),
		"trailEdgeWidth": 5.0,
		"burstPos": hit_pos,
		"burstRadius": 24.0 + life * 30.0,
		"burstColor": Color(1.0, 0.95, 0.22, 0.35),
		"hammerPos": hammer_pos,
		"hammerSize": Vector2(70, 70) * (0.94 + 0.06 * sin(swing_progress * PI)),
		"hammerAngle": swing_angle + deg_to_rad(38.0),
		"hammerAlpha": clampf(life / 0.16, 0.0, 1.0),
		"hammerAfterImages": hammer_after_images,
		"sparkPos": pos + Vector2.RIGHT.rotated(trail_end) * (trail_radius + 18.0),
		"sparkDir": Vector2.RIGHT.rotated(trail_end),
		"sparkSize": 10.0 + 5.0 * sin(swing_progress * PI),
		"sparkAlpha": trail_alpha,
		"label": "BAN!",
		"labelPos": hit_pos + Vector2(-22, -28),
		"labelColor": Color("#fff45c"),
		"labelSize": 20
	}

static func ban_judgement_shockwave_fx_data(pos: Vector2, dir: Vector2, life: float, max_life: float, range: float, width: float) -> Dictionary:
	var alpha: float = clampf(life / maxf(0.01, max_life), 0.0, 1.0)
	var progress: float = clampf(1.0 - life / maxf(0.01, max_life), 0.0, 1.0)
	var burst: float = sin(progress * PI)
	var norm_dir: Vector2 = dir.normalized()
	if norm_dir.length() < 0.1:
		norm_dir = Vector2.RIGHT
	var side: Vector2 = Vector2(-norm_dir.y, norm_dir.x)
	var angle: float = norm_dir.angle()
	var half_angle: float = deg_to_rad(48.0 + 10.0 * burst)
	var tail: Vector2 = pos + norm_dir * (10.0 + range * 0.04 * progress)
	var mid: Vector2 = pos + norm_dir * range * (0.48 + 0.08 * progress)
	var front: Vector2 = pos + norm_dir * range * (0.78 + 0.10 * progress)
	var tail_half: float = width * (0.24 + 0.12 * burst)
	var mid_half: float = width * (0.52 + 0.18 * burst)
	var front_half: float = width * (0.32 + 0.12 * burst)
	var tip: Vector2 = front + norm_dir * (24.0 + 24.0 * burst)
	var core_mid_half: float = width * (0.20 + 0.10 * burst)
	var core_front_half: float = width * (0.13 + 0.06 * burst)
	var points := PackedVector2Array([
		tail - side * tail_half,
		mid - side * mid_half,
		front - side * front_half,
		tip,
		front + side * front_half,
		mid + side * mid_half,
		tail + side * tail_half
	])
	var after_points := PackedVector2Array([
		tail - side * tail_half * 1.22 - norm_dir * 8.0,
		mid - side * mid_half * 1.18,
		front - side * front_half * 1.16,
		tip + norm_dir * (12.0 + 12.0 * burst),
		front + side * front_half * 1.16,
		mid + side * mid_half * 1.18,
		tail + side * tail_half * 1.22 - norm_dir * 8.0
	])
	var core_points := PackedVector2Array([
		tail - side * tail_half * 0.24,
		mid - side * core_mid_half,
		front - side * core_front_half,
		tip - norm_dir * 4.0,
		front + side * core_front_half,
		mid + side * core_mid_half,
		tail + side * tail_half * 0.24
	])
	var fill_color := Color(1.0, 0.12, 0.22, 0.46 * alpha)
	var impact_pos: Vector2 = pos + norm_dir * range * (0.72 + 0.08 * burst)
	var stamp_radius: float = width * (0.18 + 0.10 * burst)
	var slam_pos: Vector2 = pos + norm_dir * range * (0.34 + 0.10 * burst)
	var slam_radius: float = width * (0.30 + 0.15 * burst)
	var burst_points := PackedVector2Array()
	var burst_colors := PackedColorArray()
	for i in range(18):
		var point_angle: float = TAU * float(i) / 18.0 + progress * 0.35
		var radius_rate: float = 1.0 if i % 2 == 0 else 0.48
		var point_radius: float = slam_radius * radius_rate * (1.04 + 0.18 * sin(float(i) * 1.7 + progress * TAU))
		var point: Vector2 = slam_pos + norm_dir * cos(point_angle) * point_radius * 1.52 + side * sin(point_angle) * point_radius * 1.02
		burst_points.append(point)
		var point_alpha: float = (0.82 if i % 2 == 0 else 0.52) * alpha
		burst_colors.append(Color(1.0, 0.84, 0.20, point_alpha) if i % 3 == 0 else Color(1.0, 0.16, 0.22, point_alpha))
	var shard_base: Vector2 = slam_pos + norm_dir * slam_radius * 0.28
	var shard_length: float = range * (0.40 + 0.16 * burst)
	var shard_width: float = width * (0.13 + 0.05 * burst)
	var shard1_base: Vector2 = shard_base - side * width * 0.18
	var shard2_base: Vector2 = shard_base + side * width * 0.10 + norm_dir * slam_radius * 0.20
	var shard3_base: Vector2 = shard_base + side * width * 0.34 + norm_dir * slam_radius * 0.06
	var shard1_points := PackedVector2Array([
		shard1_base - side * shard_width,
		shard1_base + norm_dir * shard_length - side * shard_width * 0.20,
		shard1_base + norm_dir * (shard_length + 36.0 * burst),
		shard1_base + norm_dir * shard_length + side * shard_width * 0.20,
		shard1_base + side * shard_width
	])
	var shard2_points := PackedVector2Array([
		shard2_base - side * shard_width * 0.76,
		shard2_base + norm_dir * shard_length * 0.88 - side * shard_width * 0.18,
		shard2_base + norm_dir * (shard_length * 1.05 + 28.0 * burst),
		shard2_base + norm_dir * shard_length * 0.88 + side * shard_width * 0.18,
		shard2_base + side * shard_width * 0.76
	])
	var shard3_points := PackedVector2Array([
		shard3_base - side * shard_width * 0.58,
		shard3_base + norm_dir * shard_length * 0.72 - side * shard_width * 0.12,
		shard3_base + norm_dir * (shard_length * 0.92 + 20.0 * burst),
		shard3_base + norm_dir * shard_length * 0.72 + side * shard_width * 0.12,
		shard3_base + side * shard_width * 0.58
	])
	var shard1_colors := PackedColorArray([
		Color(1.0, 0.10, 0.20, 0.10 * alpha),
		Color(1.0, 0.30, 0.16, 0.42 * alpha),
		Color(1.0, 0.98, 0.58, 0.82 * alpha),
		Color(1.0, 0.30, 0.16, 0.42 * alpha),
		Color(1.0, 0.10, 0.20, 0.10 * alpha)
	])
	var shard2_colors := PackedColorArray([
		Color(1.0, 0.22, 0.26, 0.08 * alpha),
		Color(1.0, 0.58, 0.20, 0.32 * alpha),
		Color(1.0, 0.92, 0.34, 0.66 * alpha),
		Color(1.0, 0.58, 0.20, 0.32 * alpha),
		Color(1.0, 0.22, 0.26, 0.08 * alpha)
	])
	var shard3_colors := PackedColorArray([
		Color(1.0, 0.08, 0.16, 0.06 * alpha),
		Color(1.0, 0.28, 0.34, 0.24 * alpha),
		Color(1.0, 0.80, 0.24, 0.50 * alpha),
		Color(1.0, 0.28, 0.34, 0.24 * alpha),
		Color(1.0, 0.08, 0.16, 0.06 * alpha)
	])
	return {
		"kind": "ban_judgement_shockwave",
		"pos": pos,
		"slamPos": slam_pos,
		"impactGlowPos": slam_pos,
		"impactGlowRadius": slam_radius * 2.15,
		"impactGlowColor": Color(1.0, 0.10, 0.18, 0.22 * alpha),
		"impactCorePos": slam_pos,
		"impactCoreRadius": slam_radius * (0.50 + 0.14 * burst),
		"impactCoreColor": Color(1.0, 0.96, 0.50, 0.60 * alpha),
		"impactRingOuterPos": slam_pos,
		"impactRingOuterRadius": slam_radius * (1.42 + 0.34 * progress),
		"impactRingOuterColor": Color(1.0, 0.82, 0.18, 0.70 * alpha),
		"impactRingInnerPos": slam_pos,
		"impactRingInnerRadius": slam_radius * (0.86 + 0.22 * progress),
		"impactRingInnerColor": Color(1.0, 0.18, 0.26, 0.66 * alpha),
		"burstPoints": burst_points,
		"burstColors": burst_colors,
		"shard1Points": shard1_points,
		"shard1Colors": shard1_colors,
		"shard2Points": shard2_points,
		"shard2Colors": shard2_colors,
		"shard3Points": shard3_points,
		"shard3Colors": shard3_colors,
		"crack1Start": slam_pos - norm_dir * slam_radius * 0.24 - side * slam_radius * 0.50,
		"crack1End": slam_pos + norm_dir * range * 0.58 - side * width * 0.22,
		"crack1Color": Color(1.0, 0.94, 0.58, 0.78 * alpha),
		"crack1Width": 5.4 + 2.2 * burst,
		"crack2Start": slam_pos - norm_dir * slam_radius * 0.16 + side * slam_radius * 0.44,
		"crack2End": slam_pos + norm_dir * range * 0.52 + side * width * 0.36,
		"crack2Color": Color(1.0, 0.18, 0.28, 0.72 * alpha),
		"crack2Width": 4.8 + 2.0 * burst,
		"crack3Start": slam_pos - norm_dir * slam_radius * 0.05,
		"crack3End": slam_pos + norm_dir * range * 0.70,
		"crack3Color": Color(1.0, 0.98, 0.78, 0.68 * alpha),
		"crack3Width": 3.8 + 1.6 * burst,
		"backGlowPos": pos + norm_dir * range * 0.34,
		"backGlowRadius": range * (0.68 + 0.16 * burst),
		"backGlowColor": Color(1.0, 0.08, 0.16, 0.14 * alpha),
		"aftershockPoints": after_points,
		"aftershockColors": PackedColorArray([
			Color(1.0, 0.08, 0.16, 0.03 * alpha),
			Color(1.0, 0.16, 0.22, 0.10 * alpha),
			Color(1.0, 0.50, 0.08, 0.17 * alpha),
			Color(1.0, 0.94, 0.42, 0.24 * alpha),
			Color(1.0, 0.50, 0.08, 0.17 * alpha),
			Color(1.0, 0.16, 0.22, 0.10 * alpha),
			Color(1.0, 0.08, 0.16, 0.03 * alpha)
		]),
		"shockwavePoints": points,
		"shockwaveColors": PackedColorArray([fill_color, fill_color, Color(1.0, 0.42, 0.18, 0.58 * alpha), Color(1.0, 0.94, 0.34, 0.78 * alpha), Color(1.0, 0.42, 0.18, 0.58 * alpha), fill_color, fill_color]),
		"corePoints": core_points,
		"coreColors": PackedColorArray([
			Color(1.0, 0.92, 0.56, 0.10 * alpha),
			Color(1.0, 0.56, 0.18, 0.42 * alpha),
			Color(1.0, 0.90, 0.32, 0.70 * alpha),
			Color(1.0, 1.0, 0.86, 0.92 * alpha),
			Color(1.0, 0.90, 0.32, 0.70 * alpha),
			Color(1.0, 0.56, 0.18, 0.42 * alpha),
			Color(1.0, 0.92, 0.56, 0.10 * alpha)
		]),
		"outerRadius": range * (0.74 + 0.08 * burst),
		"outerStart": angle - half_angle,
		"outerEnd": angle + half_angle,
		"outerPoints": 34,
		"outerColor": Color(1.0, 0.84, 0.16, 0.88 * alpha),
		"outerWidth": 14.0 + 10.0 * burst,
		"hotRadius": range * (0.56 + 0.10 * burst),
		"hotStart": angle - half_angle * 0.78,
		"hotEnd": angle + half_angle * 0.78,
		"hotPoints": 28,
		"hotColor": Color(1.0, 0.18, 0.28, 0.82 * alpha),
		"hotWidth": 20.0 + 12.0 * burst,
		"innerRadius": range * (0.36 + 0.08 * burst),
		"innerStart": angle - half_angle * 0.54,
		"innerEnd": angle + half_angle * 0.54,
		"innerPoints": 22,
		"innerColor": Color(1.0, 0.98, 0.74, 0.86 * alpha),
		"innerWidth": 8.0 + 4.0 * burst,
		"impactPos": impact_pos,
		"impactRadius": width * (0.10 + 0.08 * burst),
		"impactColor": Color(1.0, 0.32, 0.16, 0.18 * alpha),
		"ringPos": impact_pos,
		"ringRadius": width * (0.16 + 0.10 * burst),
		"ringColor": Color(1.0, 0.94, 0.34, 0.66 * alpha),
		"slash1Start": impact_pos - norm_dir * width * 0.10 - side * width * 0.22,
		"slash1End": impact_pos + norm_dir * width * 0.34 + side * width * 0.22,
		"slash1Color": Color(1.0, 0.98, 0.70, 0.90 * alpha),
		"slash1Width": 7.0 + 4.0 * burst,
		"slash2Start": impact_pos - norm_dir * width * 0.06 + side * width * 0.20,
		"slash2End": impact_pos + norm_dir * width * 0.28 - side * width * 0.20,
		"slash2Color": Color(1.0, 0.18, 0.28, 0.78 * alpha),
		"slash2Width": 6.0 + 3.2 * burst,
		"slash3Start": pos + norm_dir * range * 0.20 - side * width * 0.34,
		"slash3End": pos + norm_dir * range * 0.66 - side * width * 0.74,
		"slash3Color": Color(1.0, 0.74, 0.18, 0.46 * alpha),
		"slash3Width": 2.6 + 2.2 * burst,
		"slash4Start": pos + norm_dir * range * 0.24 + side * width * 0.38,
		"slash4End": pos + norm_dir * range * 0.70 + side * width * 0.82,
		"slash4Color": Color(1.0, 0.20, 0.28, 0.42 * alpha),
		"slash4Width": 2.8 + 2.0 * burst,
		"ray1Start": tail - side * tail_half * 0.90,
		"ray1End": front - side * front_half * 1.45 + norm_dir * width * 0.14,
		"ray1Color": Color(1.0, 0.92, 0.42, 0.52 * alpha),
		"ray1Width": 3.0 + 2.4 * burst,
		"ray2Start": tail + side * tail_half * 0.90,
		"ray2End": front + side * front_half * 1.45 + norm_dir * width * 0.14,
		"ray2Color": Color(1.0, 0.34, 0.40, 0.48 * alpha),
		"ray2Width": 3.0 + 2.4 * burst,
		"ray3Start": tail + norm_dir * width * 0.06,
		"ray3End": tip + norm_dir * width * 0.22,
		"ray3Color": Color(1.0, 1.0, 0.82, 0.44 * alpha),
		"ray3Width": 2.2 + 2.0 * burst,
		"sealBackPos": impact_pos - norm_dir * width * 0.05,
		"sealBackRadius": stamp_radius * 1.32,
		"sealBackColor": Color(1.0, 0.05, 0.14, 0.36 * alpha),
		"sealRingPos": impact_pos - norm_dir * width * 0.05,
		"sealRingRadius": stamp_radius,
		"sealRingColor": Color(1.0, 0.84, 0.18, 0.70 * alpha),
		"sealSlashStart": impact_pos - norm_dir * width * 0.05 - Vector2(stamp_radius * 0.72, -stamp_radius * 0.48),
		"sealSlashEnd": impact_pos - norm_dir * width * 0.05 + Vector2(stamp_radius * 0.72, -stamp_radius * 0.48),
		"sealSlashColor": Color(1.0, 0.97, 0.70, 0.84 * alpha),
		"sealSlashWidth": 3.0 + 2.0 * burst,
		"sealLabelText": "BAN",
		"sealLabelPos": impact_pos - norm_dir * width * 0.05 + Vector2(-stamp_radius * 0.82, stamp_radius * 0.22),
		"sealLabelWidth": int(stamp_radius * 1.64),
		"sealLabelSize": int(stamp_radius * 0.58),
		"sealLabelColor": Color(1.0, 0.96, 0.54, 0.88 * alpha),
		"dotRadius": 3.0 + 4.0 * burst,
		"dotColor": Color(1.0, 0.78, 0.20, 0.78 * alpha),
		"dot1Pos": slam_pos + norm_dir * slam_radius * 0.80 - side * slam_radius * 0.62,
		"dot2Pos": slam_pos + norm_dir * slam_radius * 1.42 + side * slam_radius * 0.46,
		"dot3Pos": slam_pos - norm_dir * slam_radius * 0.30 + side * slam_radius * 0.74,
		"dot4Pos": slam_pos + norm_dir * range * 0.22 - side * width * 0.26,
		"dot5Pos": slam_pos + norm_dir * range * 0.28 + side * width * 0.32
	}

static func ban_judgement_hit_fx_data(pos: Vector2, dir: Vector2, life: float, max_life: float, boss_hit: bool = false) -> Dictionary:
	var alpha: float = clampf(life / maxf(0.01, max_life), 0.0, 1.0)
	var progress: float = clampf(1.0 - life / maxf(0.01, max_life), 0.0, 1.0)
	var burst: float = sin(progress * PI)
	var norm_dir: Vector2 = dir.normalized()
	if norm_dir.length() < 0.1:
		norm_dir = Vector2.RIGHT
	var side: Vector2 = Vector2(-norm_dir.y, norm_dir.x)
	var stamp_radius: float = (22.0 + 12.0 * burst) * (0.78 if boss_hit else 1.0)
	var stamp_pos: Vector2 = pos - norm_dir * 8.0 + side * sin(progress * TAU) * 3.0
	return {
		"kind": "ban_judgement_hit",
		"push1Start": stamp_pos - norm_dir * stamp_radius * 1.40 - side * stamp_radius * 0.26,
		"push1End": stamp_pos + norm_dir * stamp_radius * 1.25 - side * stamp_radius * 0.18,
		"push1Color": Color(1.0, 0.86, 0.18, 0.36 * alpha),
		"push1Width": 5.0 + 2.0 * burst,
		"push2Start": stamp_pos - norm_dir * stamp_radius * 1.20 + side * stamp_radius * 0.34,
		"push2End": stamp_pos + norm_dir * stamp_radius * 1.08 + side * stamp_radius * 0.24,
		"push2Color": Color(1.0, 0.22, 0.28, 0.34 * alpha),
		"push2Width": 4.2 + 1.8 * burst,
		"glowPos": stamp_pos,
		"glowRadius": stamp_radius * 1.75,
		"glowColor": Color(1.0, 0.22, 0.18, 0.24 * alpha),
		"burstPos": stamp_pos,
		"burstRadius": stamp_radius * (1.10 + 0.28 * burst),
		"burstColor": Color(1.0, 0.76, 0.18, 0.20 * alpha),
		"stampPos": stamp_pos,
		"stampRadius": stamp_radius,
		"stampColor": Color(1.0, 0.06, 0.16, 0.90 * alpha),
		"ringPos": stamp_pos,
		"ringRadius": stamp_radius * 1.05,
		"ringColor": Color(1.0, 0.84, 0.18, 0.88 * alpha),
		"slashStart": stamp_pos - Vector2(stamp_radius * 0.62, -stamp_radius * 0.54),
		"slashEnd": stamp_pos + Vector2(stamp_radius * 0.62, -stamp_radius * 0.54),
		"slashColor": Color(1.0, 0.96, 0.76, 0.94 * alpha),
		"slashWidth": 4.0,
		"labelText": "BAN",
		"labelPos": stamp_pos + Vector2(-stamp_radius * 0.82, stamp_radius * 0.24),
		"labelWidth": int(stamp_radius * 1.64),
		"labelSize": int(stamp_radius * 0.66),
		"labelColor": Color(1.0, 0.96, 0.55, 0.96 * alpha),
		"spark1Start": stamp_pos - norm_dir * stamp_radius * 0.40,
		"spark1End": stamp_pos - norm_dir * stamp_radius * (1.15 + 0.20 * burst),
		"spark1Color": Color(1.0, 0.86, 0.18, 0.74 * alpha),
		"spark1Width": 3.0,
		"spark2Start": stamp_pos + side * stamp_radius * 0.16,
		"spark2End": stamp_pos + side * stamp_radius * (1.05 + 0.22 * burst),
		"spark2Color": Color(1.0, 0.34, 0.42, 0.60 * alpha),
		"spark2Width": 2.6,
		"spark3Start": stamp_pos - side * stamp_radius * 0.20,
		"spark3End": stamp_pos - side * stamp_radius * (1.02 + 0.18 * burst),
		"spark3Color": Color(1.0, 0.98, 0.64, 0.58 * alpha),
		"spark3Width": 2.4,
		"dotRadius": 2.6 + 2.8 * burst,
		"dotColor": Color(1.0, 0.82, 0.20, 0.78 * alpha),
		"dot1Pos": stamp_pos + norm_dir.rotated(0.8) * stamp_radius * 1.12,
		"dot2Pos": stamp_pos + norm_dir.rotated(-0.9) * stamp_radius * 1.02,
		"dot3Pos": stamp_pos - norm_dir * stamp_radius * 1.22
	}

static func wavy_ring_points(pos: Vector2, radius: float, amplitude: float, phase: float, wave_count: float, samples: int = 56) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in range(samples + 1):
		var ratio: float = float(i) / float(samples)
		var angle: float = TAU * ratio
		var wave_radius: float = radius
		wave_radius += sin(angle * wave_count + phase) * amplitude
		wave_radius += sin(angle * 3.0 - phase * 0.65) * amplitude * 0.32
		points.append(pos + Vector2(cos(angle), sin(angle)) * wave_radius)
	return points

static func mic_wave_fx_data(pos: Vector2, life: float, max_life: float, range: float, hit_count: int) -> Dictionary:
	var progress: float = clampf(1.0 - life / maxf(0.01, max_life), 0.0, 1.0)
	var fade_in: float = clampf(progress / 0.22, 0.0, 1.0)
	fade_in = fade_in * fade_in * (3.0 - 2.0 * fade_in)
	var fade_out: float = clampf(life / maxf(0.01, max_life), 0.0, 1.0)
	var alpha: float = minf(fade_in, fade_out)
	var pulse: float = 0.45 + 0.35 * sin(progress * PI)
	var hit_boost: float = 1.04 if hit_count > 0 else 0.86
	var base_radius: float = maxf(32.0, range)
	var phase: float = progress * TAU * 0.62
	var ring1_radius: float = base_radius * lerpf(0.28, 1.05, progress)
	var ring2_radius: float = base_radius * lerpf(0.18, 0.84, progress)
	var ring3_radius: float = base_radius * lerpf(0.10, 0.62, progress)
	var tick_radius: float = base_radius * (0.74 + 0.20 * pulse)
	var tick_len: float = 12.0 + 10.0 * pulse
	var tick_angle1: float = phase + 0.25
	var tick_angle2: float = phase + 1.85
	var tick_angle3: float = phase + 3.40
	var tick_angle4: float = phase + 5.05
	var tick_dir1: Vector2 = Vector2.RIGHT.rotated(tick_angle1)
	var tick_dir2: Vector2 = Vector2.RIGHT.rotated(tick_angle2)
	var tick_dir3: Vector2 = Vector2.RIGHT.rotated(tick_angle3)
	var tick_dir4: Vector2 = Vector2.RIGHT.rotated(tick_angle4)
	return {
		"kind": "mic_wave",
		"pos": pos,
		"rangeFillPos": pos,
		"rangeFillRadius": base_radius,
		"rangeFillColor": Color(0.22, 0.86, 1.0, 0.045 * alpha),
		"rangeGlowPos": pos,
		"rangeGlowRadius": base_radius,
		"rangeGlowColor": Color(0.42, 0.94, 1.0, 0.18 * alpha),
		"rangeRingPos": pos,
		"rangeRingRadius": base_radius,
		"rangeRingColor": Color(0.72, 1.0, 1.0, 0.48 * alpha),
		"glowPos": pos,
		"glowRadius": base_radius * (0.34 + 0.10 * pulse),
		"glowColor": Color(0.38, 0.95, 1.0, 0.11 * alpha),
		"corePos": pos,
		"coreRadius": base_radius * (0.12 + 0.05 * pulse),
		"coreColor": Color(1.0, 1.0, 1.0, 0.22 * alpha),
		"wave1Points": wavy_ring_points(pos, ring1_radius, 3.0 + 3.0 * pulse, phase, 5.0),
		"wave1Color": Color(0.38, 0.92, 1.0, 0.62 * alpha * hit_boost),
		"wave1Width": 6.0 + 2.0 * pulse,
		"wave2Points": wavy_ring_points(pos, ring2_radius, 2.5 + 2.5 * pulse, phase + 1.15, 4.5),
		"wave2Color": Color(1.0, 0.42, 0.82, 0.46 * alpha * hit_boost),
		"wave2Width": 5.0 + 1.5 * pulse,
		"wave3Points": wavy_ring_points(pos, ring3_radius, 2.0 + 2.0 * pulse, phase + 2.30, 4.0),
		"wave3Color": Color(1.0, 1.0, 1.0, 0.42 * alpha),
		"wave3Width": 4.0 + 1.0 * pulse,
		"tick1Start": pos + tick_dir1 * (tick_radius - tick_len * 0.35),
		"tick1End": pos + tick_dir1 * (tick_radius + tick_len),
		"tick1Color": Color(1.0, 1.0, 1.0, 0.44 * alpha * hit_boost),
		"tick1Width": 3.0,
		"tick2Start": pos + tick_dir2 * (tick_radius - tick_len * 0.35),
		"tick2End": pos + tick_dir2 * (tick_radius + tick_len),
		"tick2Color": Color(0.50, 0.96, 1.0, 0.38 * alpha * hit_boost),
		"tick2Width": 3.0,
		"tick3Start": pos + tick_dir3 * (tick_radius - tick_len * 0.35),
		"tick3End": pos + tick_dir3 * (tick_radius + tick_len),
		"tick3Color": Color(1.0, 0.50, 0.86, 0.34 * alpha * hit_boost),
		"tick3Width": 3.0,
		"tick4Start": pos + tick_dir4 * (tick_radius - tick_len * 0.35),
		"tick4End": pos + tick_dir4 * (tick_radius + tick_len),
		"tick4Color": Color(0.86, 0.72, 1.0, 0.32 * alpha * hit_boost),
		"tick4Width": 3.0,
		"dotRadius": 3.0 + 3.0 * pulse,
		"dotColor": Color(0.72, 0.98, 1.0, 0.42 * alpha * hit_boost),
		"dot1Pos": pos + Vector2.RIGHT.rotated(phase + 0.70) * base_radius * 0.52,
		"dot2Pos": pos + Vector2.RIGHT.rotated(-phase * 0.82 + 2.10) * base_radius * 0.72,
		"dot3Pos": pos + Vector2.RIGHT.rotated(phase * 0.65 + 3.70) * base_radius * 0.92,
		"dot4Pos": pos + Vector2.RIGHT.rotated(-phase + 5.00) * base_radius * 0.64
	}

static func kusa_wave_fx_data(pos: Vector2, dir: Vector2, life: float, max_life: float = 1.0, size_scale: float = 1.0, distance_ratio: float = 0.0, bounces_left: int = 0) -> Dictionary:
	var alpha: float = clampf(life / maxf(0.01, max_life), 0.0, 1.0)
	var progress: float = clampf(distance_ratio, 0.0, 1.0)
	var normalized_dir: Vector2 = dir.normalized()
	if normalized_dir.length() < 0.1:
		normalized_dir = Vector2.RIGHT
	var side: Vector2 = Vector2(-normalized_dir.y, normalized_dir.x)
	var wave_points := PackedVector2Array()
	var wave_length: float = 86.0 * size_scale
	var wave_amp: float = 7.0 * size_scale
	for i in range(9):
		var t: float = float(i) / 8.0
		var base: Vector2 = pos - normalized_dir * wave_length * (1.0 - t)
		var wobble: Vector2 = side * sin(t * TAU * 2.0 + progress * TAU * 2.4) * wave_amp
		wave_points.append(base + wobble)
	var wave_text: String = "ｗｗｗｗ"
	var label_size: int = int(round(25.0 * size_scale))
	var label_width: int = int(round(122.0 * size_scale))
	var text_pos: Vector2 = pos - Vector2(float(label_width) * 0.5, -float(label_size) * 0.32) + side * sin(life * 20.0) * (4.0 * size_scale)
	var outline_color: Color = Color(0.95, 1.0, 0.95, 0.92 * alpha)
	var label_color: Color = Color(0.32, 1.0, 0.34, alpha)
	var dark_shadow: Color = Color(0.0, 0.26, 0.08, 0.42 * alpha)
	var bounce_tint: float = clampf(float(bounces_left) / 2.0, 0.0, 1.0)
	var data: Dictionary = {
		"kind": "kusa_wave",
		"trailStart": pos - normalized_dir * (72.0 * size_scale),
		"trailEnd": pos,
		"trailColor": Color(0.28, 1.0, 0.48, 0.42 * alpha),
		"trailWidth": 11.0 * size_scale,
		"outlinePoints": wave_points,
		"outlineColor": outline_color,
		"outlineWidth": 11.0 * size_scale,
		"wavePoints": wave_points,
		"coreColor": Color(0.22, 1.0, 0.34, 0.86 * alpha),
		"coreWidth": 5.4 * size_scale,
		"glowPos": pos,
		"glowRadius": 18.0 * size_scale,
		"glowColor": Color(0.38, 1.0, 0.55, 0.16 * alpha + 0.06 * bounce_tint),
		"shadowText": wave_text,
		"shadowPos": text_pos + Vector2(2.0, 2.0),
		"shadowColor": dark_shadow,
		"shadowSize": label_size,
		"shadowWidth": label_width,
		"outline1Text": wave_text,
		"outline1Pos": text_pos + Vector2(-2.0, 0.0),
		"outline1Color": outline_color,
		"outline1Size": label_size,
		"outline1Width": label_width,
		"outline2Text": wave_text,
		"outline2Pos": text_pos + Vector2(2.0, 0.0),
		"outline2Color": outline_color,
		"outline2Size": label_size,
		"outline2Width": label_width,
		"outline3Text": wave_text,
		"outline3Pos": text_pos + Vector2(0.0, -2.0),
		"outline3Color": outline_color,
		"outline3Size": label_size,
		"outline3Width": label_width,
		"outline4Text": wave_text,
		"outline4Pos": text_pos + Vector2(0.0, 2.0),
		"outline4Color": outline_color,
		"outline4Size": label_size,
		"outline4Width": label_width,
		"labelText": wave_text,
		"labelPos": text_pos,
		"labelColor": label_color,
		"labelSize": label_size,
		"labelWidth": label_width,
		"showHammer": false
	}
	var glyph_count: int = 6
	var glyph_text: String = wave_text.substr(0, 1)
	var glyph_spacing: float = 15.5 * size_scale
	var glyph_width: int = int(round(44.0 * size_scale))
	var glyph_size_base: int = int(round(28.0 * size_scale))
	data["glyphCount"] = glyph_count
	for glyph_index in range(glyph_count):
		var t: float = float(glyph_index) / maxf(1.0, float(glyph_count - 1))
		var glyph_center: Vector2 = pos - normalized_dir * glyph_spacing * float(glyph_index)
		glyph_center += side * sin(t * TAU * 1.7 + progress * TAU * 2.0) * (5.5 * size_scale)
		glyph_center += normalized_dir * sin(progress * TAU * 2.0 + float(glyph_index) * 0.7) * (1.8 * size_scale)
		var glyph_alpha: float = alpha * lerpf(1.0, 0.46, t)
		var glyph_size: int = glyph_size_base + (1 if glyph_index % 2 == 0 else -1)
		var glyph_pos: Vector2 = glyph_center - Vector2(float(glyph_width) * 0.5, -float(glyph_size) * 0.32)
		var prefix: String = "glyph%d" % glyph_index
		data[prefix + "ShadowText"] = glyph_text
		data[prefix + "ShadowPos"] = glyph_pos + Vector2(2.0, 2.0)
		data[prefix + "ShadowColor"] = Color(0.0, 0.22, 0.08, 0.34 * glyph_alpha)
		data[prefix + "ShadowSize"] = glyph_size
		data[prefix + "ShadowWidth"] = glyph_width
		for outline_index in range(4):
			var outline_offset: Vector2 = [Vector2(-2.0, 0.0), Vector2(2.0, 0.0), Vector2(0.0, -2.0), Vector2(0.0, 2.0)][outline_index] * maxf(0.75, size_scale)
			var outline_prefix: String = "%sOutline%d" % [prefix, outline_index + 1]
			data[outline_prefix + "Text"] = glyph_text
			data[outline_prefix + "Pos"] = glyph_pos + outline_offset
			data[outline_prefix + "Color"] = Color(0.96, 1.0, 0.92, 0.90 * glyph_alpha)
			data[outline_prefix + "Size"] = glyph_size
			data[outline_prefix + "Width"] = glyph_width
		data[prefix + "LabelText"] = glyph_text
		data[prefix + "LabelPos"] = glyph_pos
		data[prefix + "LabelColor"] = Color(0.30, 1.0, 0.34, glyph_alpha)
		data[prefix + "LabelSize"] = glyph_size
		data[prefix + "LabelWidth"] = glyph_width
	return data

static func kusa_wave_bounce_fx_data(pos: Vector2, dir: Vector2, life: float, max_life: float = 0.22, size_scale: float = 1.0, depleted: bool = false) -> Dictionary:
	var progress: float = clampf(1.0 - life / maxf(0.01, max_life), 0.0, 1.0)
	var alpha: float = clampf(life / maxf(0.01, max_life), 0.0, 1.0)
	var normalized_dir: Vector2 = dir.normalized()
	if normalized_dir.length() < 0.1:
		normalized_dir = Vector2.RIGHT
	var side: Vector2 = Vector2(-normalized_dir.y, normalized_dir.x)
	var radius: float = (15.0 + 15.0 * progress) * size_scale
	var pop_color: Color = Color(0.44, 1.0, 0.42, 0.36 * alpha) if not depleted else Color(0.78, 1.0, 0.70, 0.30 * alpha)
	return {
		"kind": "kusa_wave_bounce",
		"softPos": pos,
		"softRadius": radius,
		"softColor": pop_color,
		"ringPos": pos,
		"ringRadius": radius * 0.82,
		"ringColor": Color(0.88, 1.0, 0.84, 0.58 * alpha),
		"spark1Start": pos - normalized_dir * radius * 0.25,
		"spark1End": pos + normalized_dir * radius * 0.75,
		"spark1Color": Color(0.38, 1.0, 0.32, 0.82 * alpha),
		"spark1Width": 3.0 * size_scale,
		"spark2Start": pos - side * radius * 0.18,
		"spark2End": pos + side * radius * 0.62,
		"spark2Color": Color(0.92, 1.0, 0.72, 0.72 * alpha),
		"spark2Width": 2.4 * size_scale,
		"dotRadius": 2.8 * size_scale,
		"dotColor": Color(0.50, 1.0, 0.42, 0.74 * alpha),
		"dot1Pos": pos + normalized_dir.rotated(0.9) * radius * 0.62,
		"dot2Pos": pos + normalized_dir.rotated(-1.1) * radius * 0.72,
		"dot3Pos": pos - normalized_dir * radius * 0.48
	}

static func spotlight_fx_data(pos: Vector2, life: float, max_life: float, radius: float) -> Dictionary:
	var progress: float = clampf(1.0 - life / maxf(0.01, max_life), 0.0, 1.0)
	var alpha: float = clampf(life / maxf(0.01, max_life), 0.0, 1.0)
	var pulse: float = sin(progress * PI)
	var visual_radius: float = radius * lerpf(1.15, 1.55, progress)
	var top: Vector2 = pos + Vector2(0.0, -visual_radius * 2.15)
	return {
		"kind": "spotlight",
		"pos": pos,
		"beamGlowStart": top + Vector2(-visual_radius * 0.58, 0.0),
		"beamGlowEnd": pos + Vector2(-visual_radius * 0.18, visual_radius * 0.26),
		"beamGlowColor": Color(1.0, 0.95, 0.42, 0.22 * alpha),
		"beamGlowWidth": visual_radius * 0.72,
		"beamCoreStart": top + Vector2(visual_radius * 0.26, -visual_radius * 0.18),
		"beamCoreEnd": pos + Vector2(visual_radius * 0.10, visual_radius * 0.18),
		"beamCoreColor": Color(1.0, 1.0, 1.0, 0.36 * alpha),
		"beamCoreWidth": visual_radius * 0.34,
		"beamSideStart": top + Vector2(visual_radius * 0.92, visual_radius * 0.10),
		"beamSideEnd": pos + Vector2(visual_radius * 0.38, visual_radius * 0.28),
		"beamSideColor": Color(0.46, 0.92, 1.0, 0.20 * alpha),
		"beamSideWidth": visual_radius * 0.24,
		"glowRadius": visual_radius * 0.92,
		"glowColor": Color(1.0, 0.96, 0.45, 0.20 * alpha),
		"haloRadius": visual_radius * (0.88 + pulse * 0.22),
		"haloColor": Color(1.0, 0.84, 0.12, 0.54 * alpha),
		"outerRadius": visual_radius * (1.20 + progress * 0.12),
		"outerColor": Color(0.55, 0.94, 1.0, 0.34 * alpha),
		"coreRadius": radius * (0.34 + pulse * 0.16),
		"coreColor": Color(1.0, 1.0, 0.92, 0.60 * alpha),
		"sparkStart": pos + Vector2.RIGHT.rotated(progress * TAU + 0.30) * visual_radius * 0.42,
		"sparkEnd": pos + Vector2.RIGHT.rotated(progress * TAU + 0.30) * visual_radius * 0.72,
		"sparkColor": Color(1.0, 1.0, 1.0, 0.82 * alpha),
		"sparkWidth": 3.0,
		"crossStart": pos + Vector2.RIGHT.rotated(-progress * TAU * 0.55 + 2.2) * visual_radius * 0.50,
		"crossEnd": pos + Vector2.RIGHT.rotated(-progress * TAU * 0.55 + 2.2) * visual_radius * 0.78,
		"crossColor": Color(1.0, 0.48, 0.86, 0.58 * alpha),
		"crossWidth": 3.0,
		"dot1Pos": pos + Vector2.RIGHT.rotated(progress * TAU + 0.90) * visual_radius * 0.82,
		"dot2Pos": pos + Vector2.RIGHT.rotated(-progress * TAU * 0.85 + 2.75) * visual_radius * 0.70,
		"dot3Pos": pos + Vector2.RIGHT.rotated(progress * TAU * 0.62 + 4.40) * visual_radius * 0.55,
		"dot4Pos": pos + Vector2.RIGHT.rotated(-progress * TAU + 5.25) * visual_radius * 0.96,
		"dotRadius": 3.5 + 4.0 * pulse,
		"dotColor": Color(1.0, 0.92, 0.25, 0.72 * alpha),
		"label": "LIVE!",
		"labelPos": pos + Vector2(-34.0, -visual_radius * 0.30),
		"labelColor": Color(1.0, 0.98, 0.54, 0.78 * alpha),
		"labelSize": 18 + int(4.0 * pulse)
	}

static func damage_number_fx_data(pos: Vector2, life: float, max_life: float, damage: float) -> Dictionary:
	var progress: float = clampf(1.0 - life / maxf(0.01, max_life), 0.0, 1.0)
	var alpha: float = clampf(life / maxf(0.01, max_life), 0.0, 1.0)
	var value_text: String = str(int(round(damage)))
	var text_pos: Vector2 = pos + Vector2(-8.0 * float(value_text.length()), -progress * 18.0)
	var size: int = 20 + int((1.0 - progress) * 4.0)
	return {
		"kind": "damage_number",
		"shadowText": value_text,
		"shadowPos": text_pos + Vector2(2, 2),
		"shadowColor": Color(0.20, 0.05, 0.02, 0.82 * alpha),
		"shadowSize": size + 2,
		"label": value_text,
		"labelPos": text_pos,
		"labelColor": Color(1.0, 0.96, 0.34, alpha),
		"labelSize": size
	}

static func pickup_text_fx_data(pos: Vector2, life: float, max_life: float, text: String, color: Color) -> Dictionary:
	var progress: float = clampf(1.0 - life / maxf(0.01, max_life), 0.0, 1.0)
	var alpha: float = clampf(life / maxf(0.01, max_life), 0.0, 1.0)
	var text_pos: Vector2 = pos + Vector2(0.0, -progress * 16.0)
	return {
		"kind": "pickup_text",
		"shadowText": text,
		"shadowPos": text_pos + Vector2(2.0, 2.0),
		"shadowColor": Color(0.10, 0.03, 0.08, 0.76 * alpha),
		"shadowSize": 20,
		"label": text,
		"labelPos": text_pos,
		"labelColor": Color(color.r, color.g, color.b, alpha),
		"labelSize": 19
	}

static func starlight_hit_fx_data(pos: Vector2, life: float, max_life: float, premium: bool) -> Dictionary:
	var progress: float = clampf(1.0 - life / maxf(0.01, max_life), 0.0, 1.0)
	var alpha: float = clampf(life / maxf(0.01, max_life), 0.0, 1.0)
	var burst: float = sin(progress * PI)
	var radius_scale: float = 1.28 if premium else 1.0
	return {
		"kind": "starlight_hit",
		"glowPos": pos,
		"glowRadius": (18.0 + progress * 18.0) * radius_scale,
		"glowColor": Color(0.46, 0.94, 1.0, 0.18 * alpha),
		"ringPos": pos,
		"ringRadius": (10.0 + progress * 24.0) * radius_scale,
		"ringColor": Color(1.0, 0.94, 0.26, 0.64 * alpha),
		"corePos": pos,
		"coreRadius": (5.0 + burst * 6.0) * radius_scale,
		"coreColor": Color(1.0, 1.0, 1.0, 0.62 * alpha),
		"spark1Start": pos + Vector2.LEFT * (10.0 + progress * 14.0),
		"spark1End": pos + Vector2.RIGHT * (10.0 + progress * 14.0),
		"spark1Color": Color(1.0, 1.0, 1.0, 0.72 * alpha),
		"spark1Width": 2.6,
		"spark2Start": pos + Vector2.UP * (10.0 + progress * 14.0),
		"spark2End": pos + Vector2.DOWN * (10.0 + progress * 14.0),
		"spark2Color": Color(1.0, 0.82, 0.20, 0.62 * alpha),
		"spark2Width": 2.4,
		"starText": "★",
		"starPos": pos + Vector2(-17.0, 11.0 - progress * 8.0),
		"starWidth": 34,
		"starSize": 22 + int(5.0 * burst),
		"starColor": Color(1.0, 0.96, 0.30, 0.88 * alpha)
	}

static func starlight_burst_fx_data(pos: Vector2, life: float, max_life: float, radius: float) -> Dictionary:
	var progress: float = clampf(1.0 - life / maxf(0.01, max_life), 0.0, 1.0)
	var alpha: float = clampf(life / maxf(0.01, max_life), 0.0, 1.0)
	var burst: float = sin(progress * PI)
	var wave_radius: float = lerpf(18.0, radius, progress)
	var data := {
		"kind": "starlight_burst",
		"rangePos": pos,
		"rangeRadius": wave_radius,
		"rangeColor": Color(1.0, 0.82, 0.18, 0.20 * alpha),
		"ringPos": pos,
		"ringRadius": wave_radius * (0.82 + burst * 0.18),
		"ringColor": Color(0.62, 0.96, 1.0, 0.46 * alpha),
		"corePos": pos,
		"coreRadius": 10.0 + burst * 18.0,
		"coreColor": Color(1.0, 1.0, 0.84, 0.56 * alpha),
		"wavePoints": wavy_ring_points(pos, wave_radius, 2.0 + burst * 5.0, progress * TAU, 5.0),
		"waveColor": Color(1.0, 0.95, 0.30, 0.58 * alpha),
		"waveWidth": 4.0 + burst * 4.0,
		"dotRadius": 3.0 + burst * 4.0,
		"dotColor": Color(1.0, 1.0, 1.0, 0.78 * alpha),
		"starText": "★",
		"starPos": pos + Vector2(-22.0, 14.0 - progress * 16.0),
		"starWidth": 44,
		"starSize": 28 + int(7.0 * burst),
		"starColor": Color(1.0, 0.90, 0.18, 0.90 * alpha)
	}
	for i in range(4):
		var idx: int = i + 1
		var angle: float = progress * TAU * 0.38 + float(i) * TAU / 4.0
		var dir: Vector2 = Vector2.RIGHT.rotated(angle)
		data["spark%dStart" % idx] = pos + dir * (wave_radius * 0.32)
		data["spark%dEnd" % idx] = pos + dir * (wave_radius * (0.82 + burst * 0.16))
		var spark_color: Color = [Color("#fff45c"), Color("#65e9ff"), Color("#ffffff"), Color("#ff91c8")][i]
		spark_color.a = 0.72 * alpha
		data["spark%dColor" % idx] = spark_color
		data["spark%dWidth" % idx] = 3.0 + burst * 2.0
		data["dot%dPos" % idx] = pos + Vector2.RIGHT.rotated(angle + 0.38) * wave_radius * (0.58 + 0.20 * burst)
	return data

static func maro_comment_hit_fx_data(pos: Vector2, life: float, max_life: float) -> Dictionary:
	var progress: float = clampf(1.0 - life / maxf(0.01, max_life), 0.0, 1.0)
	var alpha: float = clampf(life / maxf(0.01, max_life), 0.0, 1.0)
	return {
		"kind": "maro_comment_hit",
		"bubblePos": pos,
		"bubbleRadius": 10.0 + progress * 16.0,
		"bubbleColor": Color(1.0, 0.72, 0.88, 0.32 * alpha),
		"corePos": pos,
		"coreRadius": 5.0 + sin(progress * PI) * 5.0,
		"coreColor": Color(1.0, 0.98, 1.0, 0.54 * alpha),
		"labelText": "♡",
		"labelPos": pos + Vector2(-12.0, 8.0 - progress * 10.0),
		"labelWidth": 24,
		"labelSize": 20,
		"labelColor": Color(1.0, 0.36, 0.66, 0.84 * alpha)
	}

static func maro_bullet_clear_fx_data(pos: Vector2, dir: Vector2, life: float, max_life: float) -> Dictionary:
	var progress: float = clampf(1.0 - life / maxf(0.01, max_life), 0.0, 1.0)
	var alpha: float = clampf(life / maxf(0.01, max_life), 0.0, 1.0)
	var normalized_dir: Vector2 = dir.normalized()
	if normalized_dir.length() < 0.1:
		normalized_dir = Vector2.RIGHT
	var side: Vector2 = Vector2(-normalized_dir.y, normalized_dir.x)
	return {
		"kind": "maro_bullet_clear",
		"outerPos": pos,
		"outerRadius": 12.0 + progress * 18.0,
		"outerColor": Color(1.0, 0.72, 0.90, 0.30 * alpha),
		"innerPos": pos,
		"innerRadius": 6.0 + progress * 8.0,
		"innerColor": Color(1.0, 1.0, 1.0, 0.50 * alpha),
		"pop1Start": pos - normalized_dir * 6.0,
		"pop1End": pos + normalized_dir * (18.0 + progress * 12.0),
		"pop1Color": Color(1.0, 0.88, 0.96, 0.68 * alpha),
		"pop1Width": 3.0,
		"pop2Start": pos - side * 5.0,
		"pop2End": pos + side * (16.0 + progress * 10.0),
		"pop2Color": Color(1.0, 0.54, 0.78, 0.58 * alpha),
		"pop2Width": 2.6,
		"labelText": "♡",
		"labelPos": pos + Vector2(-11.0, 8.0 - progress * 8.0),
		"labelWidth": 22,
		"labelSize": 18,
		"labelColor": Color(1.0, 0.44, 0.72, 0.82 * alpha)
	}

static func maro_comment_pulse_fx_data(pos: Vector2, life: float, max_life: float, radius: float, pulled_exp: int) -> Dictionary:
	var progress: float = clampf(1.0 - life / maxf(0.01, max_life), 0.0, 1.0)
	var alpha: float = clampf(life / maxf(0.01, max_life), 0.0, 1.0)
	var burst: float = sin(progress * PI)
	return {
		"kind": "maro_comment_pulse",
		"softPos": pos,
		"softRadius": radius * (0.48 + progress * 0.72),
		"softColor": Color(1.0, 0.72, 0.90, 0.12 * alpha),
		"ringPos": pos,
		"ringRadius": radius * (0.72 + progress * 0.36),
		"ringColor": Color(1.0, 0.92, 0.98, 0.50 * alpha),
		"wavePoints": wavy_ring_points(pos, radius * (0.62 + progress * 0.52), 3.0 + burst * 5.0, progress * TAU, 6.0),
		"waveColor": Color(0.86, 1.0, 1.0, 0.54 * alpha),
		"waveWidth": 5.0 + burst * 4.0,
		"labelText": "COMMENT",
		"labelPos": pos + Vector2(-58.0, -radius * 0.36 - progress * 22.0),
		"labelWidth": 116,
		"labelSize": 18 + int(4.0 * burst),
		"labelColor": Color(1.0, 0.72, 0.90, 0.66 * alpha),
		"dotRadius": 3.0 + burst * 3.0,
		"dotColor": Color(1.0, 1.0, 1.0, 0.66 * alpha),
		"dot1Pos": pos + Vector2.RIGHT.rotated(progress * TAU + 0.2) * radius * 0.72,
		"dot2Pos": pos + Vector2.RIGHT.rotated(-progress * TAU * 0.8 + 2.2) * radius * 0.92,
		"dot3Pos": pos + Vector2.RIGHT.rotated(progress * TAU * 0.6 + 4.1) * radius * 0.82,
		"pullText": "+EXP" if pulled_exp > 0 else "",
		"pullPos": pos + Vector2(-34.0, radius * 0.34 + 18.0),
		"pullWidth": 68,
		"pullSize": 16,
		"pullColor": Color(0.72, 1.0, 0.98, 0.54 * alpha)
	}

static func notification_bell_fx_data(pos: Vector2, life: float, max_life: float, bonus: int) -> Dictionary:
	var progress: float = clampf(1.0 - life / maxf(0.01, max_life), 0.0, 1.0)
	var alpha: float = clampf(life / maxf(0.01, max_life), 0.0, 1.0)
	var pop: float = sin(progress * PI)
	return {
		"kind": "notification_bell",
		"glowPos": pos,
		"glowRadius": 12.0 + progress * 22.0,
		"glowColor": Color(1.0, 0.92, 0.30, 0.22 * alpha),
		"corePos": pos,
		"coreRadius": 7.0 + pop * 4.0,
		"coreColor": Color(1.0, 0.78, 0.18, 0.72 * alpha),
		"spark1Start": pos + Vector2(-18.0, -9.0),
		"spark1End": pos + Vector2(-31.0 - progress * 10.0, -19.0 - progress * 8.0),
		"spark1Color": Color(1.0, 1.0, 0.82, 0.62 * alpha),
		"spark1Width": 2.4,
		"spark2Start": pos + Vector2(15.0, -7.0),
		"spark2End": pos + Vector2(28.0 + progress * 8.0, -17.0 - progress * 6.0),
		"spark2Color": Color(0.72, 1.0, 1.0, 0.50 * alpha),
		"spark2Width": 2.2,
		"labelText": "+%d EXP" % bonus,
		"labelPos": pos + Vector2(-42.0, -38.0 - progress * 16.0),
		"labelWidth": 84,
		"labelSize": 15,
		"labelColor": Color(1.0, 0.94, 0.38, 0.78 * alpha)
	}

static func comment_radar_ping_fx_data(pos: Vector2, life: float, max_life: float, radius: float) -> Dictionary:
	var progress: float = clampf(1.0 - life / maxf(0.01, max_life), 0.0, 1.0)
	var alpha: float = clampf(life / maxf(0.01, max_life), 0.0, 1.0)
	var draw_radius: float = maxf(42.0, radius * (0.28 + progress * 0.36))
	return {
		"kind": "comment_radar_ping",
		"softPos": pos,
		"softRadius": draw_radius * 0.78,
		"softColor": Color(0.56, 0.94, 1.0, 0.08 * alpha),
		"ringPos": pos,
		"ringRadius": draw_radius,
		"ringColor": Color(0.62, 1.0, 0.96, 0.42 * alpha),
		"dotRadius": 3.0,
		"dotColor": Color(1.0, 1.0, 1.0, 0.52 * alpha),
		"dot1Pos": pos + Vector2.RIGHT.rotated(progress * TAU) * draw_radius * 0.72,
		"dot2Pos": pos + Vector2.RIGHT.rotated(progress * TAU + 2.2) * draw_radius * 0.56,
		"dot3Pos": pos + Vector2.RIGHT.rotated(progress * TAU + 4.3) * draw_radius * 0.64
	}

static func mini_humidifier_heal_fx_data(pos: Vector2, life: float, max_life: float, amount: int) -> Dictionary:
	var progress: float = clampf(1.0 - life / maxf(0.01, max_life), 0.0, 1.0)
	var alpha: float = clampf(life / maxf(0.01, max_life), 0.0, 1.0)
	var drift: float = progress * 28.0
	return {
		"kind": "mini_humidifier_heal",
		"mist1Pos": pos + Vector2(-15.0, -drift),
		"mist1Radius": 8.0 + progress * 9.0,
		"mist1Color": Color(0.62, 0.94, 1.0, 0.28 * alpha),
		"mist2Pos": pos + Vector2(8.0, -8.0 - drift * 0.82),
		"mist2Radius": 7.0 + progress * 8.0,
		"mist2Color": Color(0.90, 1.0, 1.0, 0.24 * alpha),
		"heartText": "♥",
		"heartPos": pos + Vector2(-12.0, -18.0 - drift * 0.55),
		"heartWidth": 24,
		"heartSize": 20,
		"heartColor": Color(0.52, 0.92, 1.0, 0.76 * alpha),
		"labelText": "+%d" % amount,
		"labelPos": pos + Vector2(2.0, -22.0 - drift * 0.45),
		"labelWidth": 38,
		"labelSize": 15,
		"labelColor": Color(0.78, 1.0, 1.0, 0.66 * alpha)
	}

static func banana_slip_fx_data(pos: Vector2, dir: Vector2, side: Vector2, life: float, max_life: float, seed: float) -> Dictionary:
	var progress: float = clampf(1.0 - life / maxf(0.01, max_life), 0.0, 1.0)
	var alpha: float = clampf(life / maxf(0.01, max_life), 0.0, 1.0)
	var normalized_dir: Vector2 = dir.normalized()
	if normalized_dir.length() <= 0.01:
		normalized_dir = Vector2.RIGHT
	var normalized_side: Vector2 = side.normalized()
	if normalized_side.length() <= 0.01:
		normalized_side = Vector2.UP
	var wobble: Vector2 = normalized_side * sin(seed + progress * TAU) * 5.5
	var trail_end: Vector2 = pos + wobble + normalized_dir * (8.0 + progress * 8.0)
	var trail_start: Vector2 = trail_end + normalized_dir * (28.0 + progress * 16.0)
	return {
		"kind": "banana_slip",
		"trailStart": trail_start,
		"trailEnd": trail_end,
		"trailColor": Color(1.0, 0.88, 0.10, 0.62 * alpha),
		"trailWidth": 7.0 + 2.0 * alpha,
		"shineStart": trail_start + normalized_side * 5.0,
		"shineEnd": trail_end + normalized_side * 3.0,
		"shineColor": Color(1.0, 1.0, 0.78, 0.48 * alpha),
		"shineWidth": 2.5,
		"splashPos": pos - normalized_dir * (4.0 + progress * 10.0) + wobble,
		"splashRadius": 7.0 + progress * 4.0,
		"splashColor": Color(1.0, 0.72, 0.04, 0.30 * alpha),
		"dot1Pos": pos + normalized_side * 9.0 - normalized_dir * 6.0,
		"dot2Pos": pos - normalized_side * 7.0 - normalized_dir * 12.0,
		"dotRadius": 2.1 + alpha,
		"dotColor": Color(1.0, 0.92, 0.18, 0.58 * alpha)
	}

static func comment_pin_fx_data(pos: Vector2, dir: Vector2, life: float, max_life: float) -> Dictionary:
	var alpha: float = clampf(life / maxf(0.01, max_life), 0.0, 1.0)
	var normalized_dir: Vector2 = dir.normalized()
	if normalized_dir.length() < 0.1:
		normalized_dir = Vector2.RIGHT
	return {
		"kind": "comment_pin",
		"trailStart": pos - normalized_dir * 26.0,
		"trailEnd": pos,
		"trailColor": Color(1.0, 0.38, 0.72, 0.42 * alpha),
		"trailWidth": 4.0,
		"imagePath": "res://assets/generated/weapon_fx_v1/comment_pin.png",
		"imagePos": pos,
		"imageSize": Vector2(46.0, 46.0),
		"imageAlpha": alpha,
		"imageRotation": normalized_dir.angle() - PI * 0.75
	}

static func pin_burst_fx_data(pos: Vector2, life: float, max_life: float) -> Dictionary:
	var alpha: float = clampf(life / maxf(0.01, max_life), 0.0, 1.0)
	var progress: float = clampf(1.0 - life / maxf(0.01, max_life), 0.0, 1.0)
	return {
		"kind": "pin_burst",
		"outerPos": pos,
		"outerRadius": 12.0 + progress * 18.0,
		"outerColor": Color(1.0, 0.28, 0.64, 0.34 * alpha),
		"innerPos": pos,
		"innerRadius": 5.0 + progress * 5.0,
		"innerColor": Color(1.0, 0.88, 0.20, 0.62 * alpha)
	}

static func emote_mine_fx_data(pos: Vector2, life: float, max_life: float, radius: float) -> Dictionary:
	var pulse: float = 0.5 + 0.5 * sin(life * 8.0)
	var alpha: float = clampf(life / maxf(0.01, max_life), 0.0, 1.0)
	var image_size: float = 60.0 + pulse * 4.0
	return {
		"kind": "emote_mine",
		"shadowPos": pos + Vector2(0, 5),
		"shadowSize": Vector2(44, 13),
		"shadowAlpha": 0.22 * alpha,
		"outerPos": pos,
		"outerRadius": 16.0 + pulse * 2.0,
		"outerColor": Color(0.80, 0.44, 1.0, 0.42 * alpha),
		"innerPos": pos,
		"innerRadius": 9.0 + pulse,
		"innerColor": Color(1.0, 0.64, 0.88, 0.82 * alpha),
		"imagePath": "res://assets/generated/weapon_fx_v1/emote_mine.png",
		"imagePos": pos + Vector2(0, -2),
		"imageSize": Vector2(image_size, image_size),
		"imageAlpha": alpha,
		"rangePos": pos,
		"rangeRadius": radius,
		"rangeColor": Color(1.0, 0.48, 0.82, 0.10 * alpha)
	}

static func emote_burst_fx_data(pos: Vector2, life: float, max_life: float, radius: float) -> Dictionary:
	var alpha: float = clampf(life / maxf(0.01, max_life), 0.0, 1.0)
	var progress: float = clampf(1.0 - life / maxf(0.01, max_life), 0.0, 1.0)
	return {
		"kind": "emote_burst",
		"outerPos": pos,
		"outerRadius": lerpf(18.0, radius, progress),
		"outerColor": Color(1.0, 0.30, 0.74, 0.25 * alpha),
		"innerPos": pos,
		"innerRadius": 14.0 + progress * 16.0,
		"innerColor": Color(0.74, 0.95, 0.92, 0.38 * alpha)
	}

static func ng_word_laser_fx_data(pos: Vector2, dir: Vector2, life: float, max_life: float, range_value: float, width: float) -> Dictionary:
	var alpha: float = clampf(life / maxf(0.01, max_life), 0.0, 1.0)
	var normalized_dir: Vector2 = dir.normalized()
	if normalized_dir.length() < 0.1:
		normalized_dir = Vector2.RIGHT
	var end_pos: Vector2 = pos + normalized_dir * range_value
	return {
		"kind": "ng_word_laser",
		"trailStart": pos,
		"trailEnd": end_pos,
		"trailColor": Color(0.92, 0.02, 0.22, 0.62 * alpha),
		"trailWidth": width,
		"coreStart": pos,
		"coreEnd": end_pos,
		"coreColor": Color(1.0, 0.04, 0.50, 0.95 * alpha),
		"coreWidth": maxf(5.0, width * 0.28)
	}

static func listener_summon_fx_data(pos: Vector2, dir: Vector2, life: float, max_life: float) -> Dictionary:
	var alpha: float = clampf(life / maxf(0.01, max_life), 0.0, 1.0)
	var normalized_dir: Vector2 = dir.normalized()
	if normalized_dir.length() < 0.1:
		normalized_dir = Vector2.RIGHT
	var bob: float = sin(life * 10.0) * 2.0
	var pulse: float = 0.5 + 0.5 * sin(life * 8.0)
	var image_size: float = 52.0 + pulse * 3.0
	return {
		"kind": "listener_summon",
		"shadowPos": pos + Vector2(0, 15),
		"shadowSize": Vector2(34, 9),
		"shadowAlpha": 0.22 * alpha,
		"imagePath": "res://assets/generated/weapon_fx_v1/listener_summon.png",
		"imagePos": pos + Vector2(0, bob - 4),
		"imageSize": Vector2(image_size, image_size),
		"imageAlpha": alpha,
		"trailStart": pos + Vector2(0, bob) - normalized_dir * 7.0,
		"trailEnd": pos + Vector2(0, bob) + normalized_dir * 23.0,
		"trailColor": Color(0.55, 0.86, 1.0, 0.46 * alpha),
		"trailWidth": 4.0
	}

static func listener_burst_fx_data(pos: Vector2, life: float, max_life: float) -> Dictionary:
	var alpha: float = clampf(life / maxf(0.01, max_life), 0.0, 1.0)
	var progress: float = clampf(1.0 - life / maxf(0.01, max_life), 0.0, 1.0)
	return {
		"kind": "listener_burst",
		"outerPos": pos,
		"outerRadius": 10.0 + progress * 18.0,
		"outerColor": Color(0.88, 0.70, 1.0, 0.32 * alpha),
		"innerPos": pos,
		"innerRadius": 5.0 + progress * 6.0,
		"innerColor": Color(1.0, 0.94, 0.28, 0.70 * alpha)
	}

static func enemy_defeat_fx_data(pos: Vector2, life: float, max_life: float, radius: float, is_boss: bool) -> Dictionary:
	var alpha: float = clampf(life / maxf(0.01, max_life), 0.0, 1.0)
	var progress: float = clampf(1.0 - life / maxf(0.01, max_life), 0.0, 1.0)
	var burst_radius: float = lerpf(radius * 0.35, radius * (1.65 if is_boss else 1.15), progress)
	var dot_distance: float = radius * (0.45 + progress * (1.3 if is_boss else 0.9))
	return {
		"kind": "enemy_defeat",
		"outerPos": pos,
		"outerRadius": burst_radius,
		"outerColor": Color(1.0, 0.32, 0.74, 0.22 * alpha),
		"innerPos": pos,
		"innerRadius": maxf(4.0, radius * (0.32 + progress * 0.22)),
		"innerColor": Color(0.82, 0.62, 1.0, 0.34 * alpha),
		"dot1Pos": pos + Vector2.RIGHT.rotated(0.2) * dot_distance,
		"dot2Pos": pos + Vector2.RIGHT.rotated(2.35) * dot_distance * 0.82,
		"dot3Pos": pos + Vector2.RIGHT.rotated(4.35) * dot_distance * 0.72,
		"dotRadius": 2.6 + progress * (3.0 if is_boss else 1.6),
		"dotColor": Color(1.0, 0.88, 0.32, 0.55 * alpha)
	}

static func boss_defeat_fx_data(pos: Vector2, life: float, max_life: float, radius: float, banner: String, viewer_text: String, effect_type: String, seed: float) -> Dictionary:
	var alpha: float = clampf(life / maxf(0.01, max_life), 0.0, 1.0)
	var progress: float = clampf(1.0 - life / maxf(0.01, max_life), 0.0, 1.0)
	var burst: float = sin(progress * PI)
	var warm_color := Color(1.0, 0.40, 0.18, 0.50 * alpha)
	var accent_color := Color("#ff65b2") if effect_type == "maro" else Color("#a77cff")
	accent_color.a = 0.72 * alpha
	var data := {
		"kind": "boss_defeat",
		"pos": pos,
		"outerPos": pos,
		"outerRadius": radius * (0.9 + progress * 2.15),
		"outerColor": Color(1.0, 0.86, 0.20, 0.36 * alpha),
		"wavePos": pos,
		"waveRadius": radius * (0.55 + progress * 1.30),
		"waveColor": accent_color,
		"corePos": pos,
		"coreRadius": radius * (0.36 + burst * 0.42),
		"coreColor": Color(1.0, 1.0, 0.92, 0.42 * alpha),
		"dotRadius": 4.0 + 4.5 * burst,
		"dotColor": Color(1.0, 0.92, 0.24, 0.80 * alpha),
		"dot1Pos": pos + Vector2.RIGHT.rotated(seed + progress * TAU) * radius * (1.25 + progress * 0.85),
		"dot2Pos": pos + Vector2.RIGHT.rotated(seed + 1.72 - progress * TAU * 0.62) * radius * (1.05 + progress * 0.70),
		"dot3Pos": pos + Vector2.RIGHT.rotated(seed + 3.35 + progress * TAU * 0.48) * radius * (0.95 + progress * 0.65),
		"dot4Pos": pos + Vector2.RIGHT.rotated(seed + 4.70 - progress * TAU * 0.80) * radius * (1.18 + progress * 0.78),
		"bannerShadowText": banner,
		"bannerShadowPos": pos + Vector2(-162.0, -radius * 1.95 - 48.0 - progress * 24.0) + Vector2(3, 3),
		"bannerShadowWidth": 324,
		"bannerShadowSize": 32,
		"bannerShadowColor": Color(0.20, 0.06, 0.16, 0.46 * alpha),
		"bannerText": banner,
		"bannerPos": pos + Vector2(-162.0, -radius * 1.95 - 48.0 - progress * 24.0),
		"bannerWidth": 324,
		"bannerSize": 32,
		"bannerColor": Color(1.0, 0.98, 0.78, 0.96 * alpha),
		"viewerShadowText": viewer_text,
		"viewerShadowPos": pos + Vector2(-58.0, -radius * 0.92 - progress * 42.0) + Vector2(2, 2),
		"viewerShadowWidth": 128,
		"viewerShadowSize": 24,
		"viewerShadowColor": Color(0.18, 0.05, 0.14, 0.38 * alpha),
		"viewerText": viewer_text,
		"viewerPos": pos + Vector2(-58.0, -radius * 0.92 - progress * 42.0),
		"viewerWidth": 128,
		"viewerSize": 24,
		"viewerColor": Color("#ff4f92").lerp(Color("#fff36b"), burst * 0.35)
	}
	for i in range(6):
		var idx: int = i + 1
		var angle: float = seed * 0.37 + float(i) * TAU / 6.0 + progress * (1.1 if i % 2 == 0 else -0.9)
		var center: Vector2 = pos + Vector2.RIGHT.rotated(angle) * radius * (0.75 + progress * 1.85)
		var side: Vector2 = Vector2.RIGHT.rotated(angle + PI * 0.5)
		data["confetti%dStart" % idx] = center - side * (8.0 + burst * 8.0)
		data["confetti%dEnd" % idx] = center + side * (8.0 + burst * 8.0)
		var confetti_color: Color = [Color("#ff4f92"), Color("#fff36b"), Color("#65e9ff"), Color("#a77cff"), Color("#ff9f43"), Color("#ffffff")][i]
		confetti_color.a = 0.72 * alpha
		data["confetti%dColor" % idx] = confetti_color
		data["confetti%dWidth" % idx] = 4.0
	data["flareStart"] = pos + Vector2(-radius * 1.65, -radius * 0.18)
	data["flareEnd"] = pos + Vector2(radius * 1.65, radius * 0.18)
	data["flareColor"] = warm_color
	data["flareWidth"] = 10.0 + 10.0 * burst
	return data

static func hit_fx_draw_data(hit_fx: Array) -> Array:
	var items: Array = []
	for fx in hit_fx:
		var fx_item: Dictionary = fx as Dictionary
		if float(fx_item.get("delay", 0.0)) > 0.0:
			continue
		if String(fx_item.get("kind", "")) == "comment_pin":
			items.append(comment_pin_fx_data(Vector2(fx_item["pos"]), Vector2(fx_item.get("dir", Vector2.RIGHT)), float(fx_item["life"]), float(fx_item.get("maxLife", 0.45))))
			continue
		if String(fx_item.get("kind", "")) == "pin_burst":
			items.append(pin_burst_fx_data(Vector2(fx_item["pos"]), float(fx_item["life"]), float(fx_item.get("maxLife", 0.22))))
			continue
		if String(fx_item.get("kind", "")) == "emote_mine":
			items.append(emote_mine_fx_data(Vector2(fx_item["pos"]), float(fx_item["life"]), float(fx_item.get("maxLife", 8.0)), float(fx_item.get("radius", 120.0))))
			continue
		if String(fx_item.get("kind", "")) == "emote_burst":
			items.append(emote_burst_fx_data(Vector2(fx_item["pos"]), float(fx_item["life"]), float(fx_item.get("maxLife", 0.28)), float(fx_item.get("radius", 120.0))))
			continue
		if String(fx_item.get("kind", "")) == "ng_word_laser":
			items.append(ng_word_laser_fx_data(Vector2(fx_item["pos"]), Vector2(fx_item.get("dir", Vector2.RIGHT)), float(fx_item["life"]), float(fx_item.get("maxLife", 0.25)), float(fx_item.get("range", 640.0)), float(fx_item.get("width", 44.0))))
			continue
		if String(fx_item.get("kind", "")) == "listener_summon":
			items.append(listener_summon_fx_data(Vector2(fx_item["pos"]), Vector2(fx_item.get("dir", Vector2.RIGHT)), float(fx_item["life"]), float(fx_item.get("maxLife", 6.0))))
			continue
		if String(fx_item.get("kind", "")) == "listener_burst":
			items.append(listener_burst_fx_data(Vector2(fx_item["pos"]), float(fx_item["life"]), float(fx_item.get("maxLife", 0.22))))
			continue
		if String(fx_item.get("kind", "")) == "enemy_defeat":
			items.append(enemy_defeat_fx_data(Vector2(fx_item["pos"]), float(fx_item["life"]), float(fx_item.get("maxLife", 0.28)), float(fx_item.get("radius", 22.0)), bool(fx_item.get("boss", false))))
			continue
		if String(fx_item.get("kind", "")) == "boss_defeat":
			items.append(boss_defeat_fx_data(
				Vector2(fx_item["pos"]),
				float(fx_item["life"]),
				float(fx_item.get("maxLife", 1.65)),
				float(fx_item.get("radius", 78.0)),
				String(fx_item.get("banner", "")),
				String(fx_item.get("viewerText", "")),
				String(fx_item.get("effectType", "")),
				float(fx_item.get("seed", 0.0))
			))
			continue
		if String(fx_item.get("kind", "")) == "pickup_text":
			items.append(pickup_text_fx_data(Vector2(fx_item["pos"]), float(fx_item["life"]), float(fx_item.get("maxLife", 0.72)), String(fx_item.get("text", "")), fx_item.get("color", Color.WHITE) as Color))
			continue
		if String(fx_item.get("kind", "")) == "damage_number":
			items.append(damage_number_fx_data(Vector2(fx_item["pos"]), float(fx_item["life"]), float(fx_item.get("maxLife", 0.62)), float(fx_item["damage"])))
			continue
		if String(fx_item.get("kind", "")) == "starlight_hit":
			items.append(starlight_hit_fx_data(Vector2(fx_item["pos"]), float(fx_item["life"]), float(fx_item.get("maxLife", 0.24)), bool(fx_item.get("premium", false))))
			continue
		if String(fx_item.get("kind", "")) == "starlight_burst":
			items.append(starlight_burst_fx_data(Vector2(fx_item["pos"]), float(fx_item["life"]), float(fx_item.get("maxLife", 0.38)), float(fx_item.get("radius", 70.0))))
			continue
		if String(fx_item.get("kind", "")) == "maro_comment_hit":
			items.append(maro_comment_hit_fx_data(Vector2(fx_item["pos"]), float(fx_item["life"]), float(fx_item.get("maxLife", 0.22))))
			continue
		if String(fx_item.get("kind", "")) == "maro_bullet_clear":
			items.append(maro_bullet_clear_fx_data(Vector2(fx_item["pos"]), Vector2(fx_item.get("dir", Vector2.RIGHT)), float(fx_item["life"]), float(fx_item.get("maxLife", 0.24))))
			continue
		if String(fx_item.get("kind", "")) == "maro_comment_pulse":
			items.append(maro_comment_pulse_fx_data(Vector2(fx_item["pos"]), float(fx_item["life"]), float(fx_item.get("maxLife", 0.36)), float(fx_item.get("radius", 130.0)), int(fx_item.get("pulledExp", 0))))
			continue
		if String(fx_item.get("kind", "")) == "notification_bell":
			items.append(notification_bell_fx_data(Vector2(fx_item["pos"]), float(fx_item["life"]), float(fx_item.get("maxLife", 0.46)), int(fx_item.get("bonus", 0))))
			continue
		if String(fx_item.get("kind", "")) == "comment_radar_ping":
			items.append(comment_radar_ping_fx_data(Vector2(fx_item["pos"]), float(fx_item["life"]), float(fx_item.get("maxLife", 0.38)), float(fx_item.get("radius", 120.0))))
			continue
		if String(fx_item.get("kind", "")) == "mini_humidifier_heal":
			items.append(mini_humidifier_heal_fx_data(Vector2(fx_item["pos"]), float(fx_item["life"]), float(fx_item.get("maxLife", 0.58)), int(fx_item.get("amount", 0))))
			continue
		if String(fx_item.get("kind", "")) == "ban_judgement_shockwave":
			items.append(ban_judgement_shockwave_fx_data(
				Vector2(fx_item["pos"]),
				Vector2(fx_item.get("dir", Vector2.RIGHT)),
				float(fx_item["life"]),
				float(fx_item.get("maxLife", 0.22)),
				float(fx_item.get("range", 450.0)),
				float(fx_item.get("width", 96.0))
			))
			continue
		if String(fx_item.get("kind", "")) == "ban_judgement_hit":
			items.append(ban_judgement_hit_fx_data(
				Vector2(fx_item["pos"]),
				Vector2(fx_item.get("dir", Vector2.RIGHT)),
				float(fx_item["life"]),
				float(fx_item.get("maxLife", 0.26)),
				bool(fx_item.get("bossHit", false))
			))
			continue
		if String(fx_item.get("kind", "")) == "mic_wave":
			items.append(mic_wave_fx_data(
				Vector2(fx_item["pos"]),
				float(fx_item["life"]),
				float(fx_item.get("maxLife", 0.42)),
				float(fx_item.get("range", 110.0)),
				int(fx_item.get("hitCount", fx_item.get("count", 0)))
			))
			continue
		if String(fx_item.get("kind", "")) == "kusa_wave":
			items.append(kusa_wave_fx_data(
				Vector2(fx_item["pos"]),
				Vector2(fx_item.get("dir", Vector2.RIGHT)),
				float(fx_item["life"]),
				float(fx_item.get("maxLife", 1.0)),
				float(fx_item.get("sizeScale", 1.0)),
				float(fx_item.get("distanceTraveled", 0.0)) / maxf(1.0, float(fx_item.get("maxDistance", fx_item.get("range", 450.0)))),
				int(fx_item.get("bouncesLeft", 0))
			))
			continue
		if String(fx_item.get("kind", "")) == "kusa_wave_bounce":
			items.append(kusa_wave_bounce_fx_data(
				Vector2(fx_item["pos"]),
				Vector2(fx_item.get("dir", Vector2.RIGHT)),
				float(fx_item["life"]),
				float(fx_item.get("maxLife", 0.22)),
				float(fx_item.get("sizeScale", 1.0)),
				bool(fx_item.get("depleted", false))
			))
			continue
		if String(fx_item.get("kind", "")) == "spotlight":
			items.append(spotlight_fx_data(Vector2(fx_item["pos"]), float(fx_item["life"]), float(fx_item.get("maxLife", 0.55)), float(fx_item.get("range", 72.0))))
			continue
		if String(fx_item.get("kind", "")) == "banana_slip":
			items.append(banana_slip_fx_data(
				Vector2(fx_item["pos"]),
				Vector2(fx_item["dir"]),
				Vector2(fx_item.get("side", Vector2.UP)),
				float(fx_item["life"]),
				float(fx_item.get("maxLife", 0.34)),
				float(fx_item.get("seed", 0.0))
			))
			continue
		var data: Dictionary = hit_fx_data(Vector2(fx_item["pos"]), Vector2(fx_item["dir"]), Vector2(fx_item["hit"]), float(fx_item["range"]), float(fx_item["life"]), float(fx_item.get("arcAngle", 120.0)))
		var is_judgement_hammer: bool = bool(fx_item.get("judgement", false))
		data["showBurst"] = int(fx_item["count"]) > 0
		data["showHammer"] = bool(fx_item.get("hammer", false))
		data["hammerSprite"] = "ban_judgement" if is_judgement_hammer else "ban_hammer"
		if is_judgement_hammer:
			var judgement_scale: float = 1.82
			var fx_pos: Vector2 = Vector2(fx_item["pos"])
			var fx_dir: Vector2 = Vector2(fx_item["dir"]).normalized()
			if fx_dir.length() < 0.1:
				fx_dir = Vector2.RIGHT
			var fx_range: float = float(fx_item["range"])
			var fx_life: float = float(fx_item["life"])
			var fx_arc_angle: float = float(fx_item.get("arcAngle", 120.0))
			var fx_half_arc: float = deg_to_rad(fx_arc_angle * 0.5)
			var fx_swing_progress: float = clampf(1.0 - fx_life / 0.24, 0.0, 1.0)
			var fx_angle: float = fx_dir.angle()
			var judgement_after_images: Array = []
			for ghost_index in range(5):
				var ghost_progress: float = clampf(fx_swing_progress - 0.075 * float(ghost_index + 1), 0.0, 1.0)
				var ghost_angle: float = fx_angle + lerpf(-fx_half_arc, fx_half_arc, ghost_progress)
				judgement_after_images.append({
					"pos": fx_pos + Vector2.RIGHT.rotated(ghost_angle) * fx_range * 0.66,
					"size": Vector2(70, 70) * judgement_scale * (0.95 - 0.08 * float(ghost_index)),
					"angle": ghost_angle + deg_to_rad(38.0),
					"alpha": clampf(0.48 - 0.07 * float(ghost_index), 0.12, 0.48) * float(data.get("hammerAlpha", 1.0))
				})
			data["hammerAfterImages"] = judgement_after_images
			data["hammerSize"] = (data["hammerSize"] as Vector2) * judgement_scale
			data["hammerAlpha"] = clampf(float(data.get("hammerAlpha", 1.0)) * 1.15, 0.0, 1.0)
			data["sparkSize"] = float(data.get("sparkSize", 10.0)) * 1.55
			data["trailGlowWidth"] = float(data.get("trailGlowWidth", 24.0)) * 1.20
			data["trailHotWidth"] = float(data.get("trailHotWidth", 18.0)) * 1.20
			data["trailCoreWidth"] = float(data.get("trailCoreWidth", 8.0)) * 1.18
		items.append(data)
	return items

static func hit_fx_parts(data: Dictionary) -> Array:
	if String(data.get("kind", "")) == "pickup_text":
		return [
			{"kind": "text", "prefix": "shadow"},
			{"kind": "text", "prefix": "label"}
		]
	if String(data.get("kind", "")) == "damage_number":
		return [
			{"kind": "text", "prefix": "shadow"},
			{"kind": "text", "prefix": "label"}
		]
	if String(data.get("kind", "")) == "starlight_hit":
		return [
			{"kind": "circle", "prefix": "glow"},
			{"kind": "circle", "prefix": "ring", "filled": false, "width": 3.0},
			{"kind": "circle", "prefix": "core"},
			{"kind": "line", "prefix": "spark1"},
			{"kind": "line", "prefix": "spark2"},
			{"kind": "text", "prefix": "star", "alignment": HORIZONTAL_ALIGNMENT_CENTER}
		]
	if String(data.get("kind", "")) == "starlight_burst":
		return [
			{"kind": "circle", "prefix": "range"},
			{"kind": "circle", "prefix": "ring", "filled": false, "width": 5.0},
			{"kind": "circle", "prefix": "core"},
			{"kind": "polyline", "pointsKey": "wavePoints", "colorKey": "waveColor", "widthKey": "waveWidth"},
			{"kind": "line", "prefix": "spark1"},
			{"kind": "line", "prefix": "spark2"},
			{"kind": "line", "prefix": "spark3"},
			{"kind": "line", "prefix": "spark4"},
			{"kind": "dot", "pos": data["dot1Pos"] as Vector2},
			{"kind": "dot", "pos": data["dot2Pos"] as Vector2},
			{"kind": "dot", "pos": data["dot3Pos"] as Vector2},
			{"kind": "dot", "pos": data["dot4Pos"] as Vector2},
			{"kind": "text", "prefix": "star", "alignment": HORIZONTAL_ALIGNMENT_CENTER}
		]
	if String(data.get("kind", "")) == "maro_comment_hit":
		return [
			{"kind": "circle", "prefix": "bubble"},
			{"kind": "circle", "prefix": "core"},
			{"kind": "text", "prefix": "label", "alignment": HORIZONTAL_ALIGNMENT_CENTER}
		]
	if String(data.get("kind", "")) == "maro_bullet_clear":
		return [
			{"kind": "circle", "prefix": "outer", "filled": false, "width": 3.0},
			{"kind": "circle", "prefix": "inner"},
			{"kind": "line", "prefix": "pop1"},
			{"kind": "line", "prefix": "pop2"},
			{"kind": "text", "prefix": "label", "alignment": HORIZONTAL_ALIGNMENT_CENTER}
		]
	if String(data.get("kind", "")) == "maro_comment_pulse":
		var parts: Array = [
			{"kind": "circle", "prefix": "soft"},
			{"kind": "circle", "prefix": "ring", "filled": false, "width": 6.0},
			{"kind": "polyline", "pointsKey": "wavePoints", "colorKey": "waveColor", "widthKey": "waveWidth"},
			{"kind": "dot", "pos": data["dot1Pos"] as Vector2},
			{"kind": "dot", "pos": data["dot2Pos"] as Vector2},
			{"kind": "dot", "pos": data["dot3Pos"] as Vector2},
			{"kind": "text", "prefix": "label", "alignment": HORIZONTAL_ALIGNMENT_CENTER}
		]
		if String(data.get("pullText", "")) != "":
			parts.append({"kind": "text", "prefix": "pull", "alignment": HORIZONTAL_ALIGNMENT_CENTER})
		return parts
	if String(data.get("kind", "")) == "notification_bell":
		return [
			{"kind": "circle", "prefix": "glow"},
			{"kind": "circle", "prefix": "core"},
			{"kind": "line", "prefix": "spark1"},
			{"kind": "line", "prefix": "spark2"},
			{"kind": "text", "prefix": "label", "alignment": HORIZONTAL_ALIGNMENT_CENTER}
		]
	if String(data.get("kind", "")) == "comment_radar_ping":
		return [
			{"kind": "circle", "prefix": "soft"},
			{"kind": "circle", "prefix": "ring", "filled": false, "width": 3.0},
			{"kind": "dot", "pos": data["dot1Pos"] as Vector2},
			{"kind": "dot", "pos": data["dot2Pos"] as Vector2},
			{"kind": "dot", "pos": data["dot3Pos"] as Vector2}
		]
	if String(data.get("kind", "")) == "mini_humidifier_heal":
		return [
			{"kind": "circle", "prefix": "mist1"},
			{"kind": "circle", "prefix": "mist2"},
			{"kind": "text", "prefix": "heart", "alignment": HORIZONTAL_ALIGNMENT_CENTER},
			{"kind": "text", "prefix": "label", "alignment": HORIZONTAL_ALIGNMENT_CENTER}
		]
	if String(data.get("kind", "")) == "ban_judgement_shockwave":
		return [
			{"kind": "circle", "prefix": "backGlow"},
			{"kind": "polygon", "pointsKey": "aftershockPoints", "colorsKey": "aftershockColors"},
			{"kind": "circle", "prefix": "impactGlow"},
			{"kind": "polygon", "pointsKey": "shard1Points", "colorsKey": "shard1Colors"},
			{"kind": "polygon", "pointsKey": "shard2Points", "colorsKey": "shard2Colors"},
			{"kind": "polygon", "pointsKey": "shard3Points", "colorsKey": "shard3Colors"},
			{"kind": "polygon", "pointsKey": "burstPoints", "colorsKey": "burstColors"},
			{"kind": "circle", "prefix": "impactRingOuter", "filled": false, "width": 5.0},
			{"kind": "circle", "prefix": "impactRingInner", "filled": false, "width": 3.0},
			{"kind": "circle", "prefix": "impactCore"},
			{"kind": "line", "prefix": "crack1"},
			{"kind": "line", "prefix": "crack2"},
			{"kind": "line", "prefix": "crack3"},
			{"kind": "dot", "pos": data["dot1Pos"] as Vector2},
			{"kind": "dot", "pos": data["dot2Pos"] as Vector2},
			{"kind": "dot", "pos": data["dot3Pos"] as Vector2},
			{"kind": "dot", "pos": data["dot4Pos"] as Vector2},
			{"kind": "dot", "pos": data["dot5Pos"] as Vector2}
		]
	if String(data.get("kind", "")) == "ban_judgement_hit":
		return [
			{"kind": "line", "prefix": "push1"},
			{"kind": "line", "prefix": "push2"},
			{"kind": "circle", "prefix": "glow"},
			{"kind": "circle", "prefix": "burst"},
			{"kind": "circle", "prefix": "stamp"},
			{"kind": "circle", "prefix": "ring", "filled": false, "width": 3.0},
			{"kind": "line", "prefix": "slash"},
			{"kind": "text", "prefix": "label", "alignment": HORIZONTAL_ALIGNMENT_CENTER},
			{"kind": "line", "prefix": "spark1"},
			{"kind": "line", "prefix": "spark2"},
			{"kind": "line", "prefix": "spark3"},
			{"kind": "dot", "pos": data["dot1Pos"] as Vector2},
			{"kind": "dot", "pos": data["dot2Pos"] as Vector2},
			{"kind": "dot", "pos": data["dot3Pos"] as Vector2}
		]
	if String(data.get("kind", "")) == "mic_wave":
		return [
			{"kind": "circle", "prefix": "rangeFill"},
			{"kind": "circle", "prefix": "rangeGlow", "filled": false, "width": 10.0},
			{"kind": "circle", "prefix": "rangeRing", "filled": false, "width": 4.5},
			{"kind": "circle", "prefix": "glow"},
			{"kind": "circle", "prefix": "core"},
			{"kind": "polyline", "pointsKey": "wave1Points", "colorKey": "wave1Color", "widthKey": "wave1Width"},
			{"kind": "polyline", "pointsKey": "wave2Points", "colorKey": "wave2Color", "widthKey": "wave2Width"},
			{"kind": "polyline", "pointsKey": "wave3Points", "colorKey": "wave3Color", "widthKey": "wave3Width"},
			{"kind": "line", "prefix": "tick1"},
			{"kind": "line", "prefix": "tick2"},
			{"kind": "line", "prefix": "tick3"},
			{"kind": "line", "prefix": "tick4"},
			{"kind": "dot", "pos": data["dot1Pos"] as Vector2},
			{"kind": "dot", "pos": data["dot2Pos"] as Vector2},
			{"kind": "dot", "pos": data["dot3Pos"] as Vector2},
			{"kind": "dot", "pos": data["dot4Pos"] as Vector2}
		]
	if String(data.get("kind", "")) == "kusa_wave":
		var parts: Array = [
			{"kind": "line", "prefix": "trail"},
			{"kind": "circle", "prefix": "glow"},
			{"kind": "polyline", "pointsKey": "outlinePoints", "colorKey": "outlineColor", "widthKey": "outlineWidth"},
			{"kind": "polyline", "pointsKey": "wavePoints", "colorKey": "coreColor", "widthKey": "coreWidth"}
		]
		for glyph_index in range(int(data.get("glyphCount", 0))):
			var prefix: String = "glyph%d" % glyph_index
			parts.append({"kind": "text", "prefix": prefix + "Shadow", "alignment": HORIZONTAL_ALIGNMENT_CENTER})
			parts.append({"kind": "text", "prefix": prefix + "Outline1", "alignment": HORIZONTAL_ALIGNMENT_CENTER})
			parts.append({"kind": "text", "prefix": prefix + "Outline2", "alignment": HORIZONTAL_ALIGNMENT_CENTER})
			parts.append({"kind": "text", "prefix": prefix + "Outline3", "alignment": HORIZONTAL_ALIGNMENT_CENTER})
			parts.append({"kind": "text", "prefix": prefix + "Outline4", "alignment": HORIZONTAL_ALIGNMENT_CENTER})
			parts.append({"kind": "text", "prefix": prefix + "Label", "alignment": HORIZONTAL_ALIGNMENT_CENTER})
		return parts
	if String(data.get("kind", "")) == "kusa_wave_bounce":
		return [
			{"kind": "circle", "prefix": "soft"},
			{"kind": "circle", "prefix": "ring", "filled": false, "width": 3.0},
			{"kind": "line", "prefix": "spark1"},
			{"kind": "line", "prefix": "spark2"},
			{"kind": "dot", "pos": data["dot1Pos"] as Vector2},
			{"kind": "dot", "pos": data["dot2Pos"] as Vector2},
			{"kind": "dot", "pos": data["dot3Pos"] as Vector2}
		]
	if String(data.get("kind", "")) == "banana_slip":
		return [
			{"kind": "circle", "prefix": "splash"},
			{"kind": "line", "prefix": "trail"},
			{"kind": "line", "prefix": "shine"},
			{"kind": "dot", "pos": data["dot1Pos"] as Vector2},
			{"kind": "dot", "pos": data["dot2Pos"] as Vector2}
		]
	if String(data.get("kind", "")) == "spotlight":
		return [
			{"kind": "line", "prefix": "beamGlow"},
			{"kind": "line", "prefix": "beamCore"},
			{"kind": "line", "prefix": "beamSide"},
			{"kind": "circle", "prefix": "glow"},
			{"kind": "circle", "prefix": "halo", "filled": false, "width": 10.0},
			{"kind": "circle", "prefix": "outer", "filled": false, "width": 6.0},
			{"kind": "circle", "prefix": "core"},
			{"kind": "line", "prefix": "spark"},
			{"kind": "line", "prefix": "cross"},
			{"kind": "dot", "pos": data["dot1Pos"] as Vector2},
			{"kind": "dot", "pos": data["dot2Pos"] as Vector2},
			{"kind": "dot", "pos": data["dot3Pos"] as Vector2},
			{"kind": "dot", "pos": data["dot4Pos"] as Vector2},
			{"kind": "text", "prefix": "label", "alignment": HORIZONTAL_ALIGNMENT_CENTER}
		]
	if String(data.get("kind", "")) == "comment_pin":
		return [
			{"kind": "line", "prefix": "trail"}
		]
	if String(data.get("kind", "")) == "pin_burst" or String(data.get("kind", "")) == "emote_burst" or String(data.get("kind", "")) == "listener_burst":
		return [
			{"kind": "circle", "prefix": "outer"},
			{"kind": "circle", "prefix": "inner"}
		]
	if String(data.get("kind", "")) == "enemy_defeat":
		return [
			{"kind": "circle", "prefix": "outer", "filled": false, "width": 3.0},
			{"kind": "circle", "prefix": "inner"},
			{"kind": "dot", "pos": data["dot1Pos"] as Vector2},
			{"kind": "dot", "pos": data["dot2Pos"] as Vector2},
			{"kind": "dot", "pos": data["dot3Pos"] as Vector2}
		]
	if String(data.get("kind", "")) == "boss_defeat":
		return [
			{"kind": "line", "prefix": "flare"},
			{"kind": "circle", "prefix": "outer", "filled": false, "width": 6.0},
			{"kind": "circle", "prefix": "wave", "filled": false, "width": 9.0},
			{"kind": "circle", "prefix": "core"},
			{"kind": "line", "prefix": "confetti1"},
			{"kind": "line", "prefix": "confetti2"},
			{"kind": "line", "prefix": "confetti3"},
			{"kind": "line", "prefix": "confetti4"},
			{"kind": "line", "prefix": "confetti5"},
			{"kind": "line", "prefix": "confetti6"},
			{"kind": "dot", "pos": data["dot1Pos"] as Vector2},
			{"kind": "dot", "pos": data["dot2Pos"] as Vector2},
			{"kind": "dot", "pos": data["dot3Pos"] as Vector2},
			{"kind": "dot", "pos": data["dot4Pos"] as Vector2},
			{"kind": "text", "prefix": "bannerShadow", "alignment": HORIZONTAL_ALIGNMENT_CENTER},
			{"kind": "text", "prefix": "banner", "alignment": HORIZONTAL_ALIGNMENT_CENTER},
			{"kind": "text", "prefix": "viewerShadow", "alignment": HORIZONTAL_ALIGNMENT_CENTER},
			{"kind": "text", "prefix": "viewer", "alignment": HORIZONTAL_ALIGNMENT_CENTER}
		]
	if String(data.get("kind", "")) == "emote_mine":
		return [
			{"kind": "shadow"},
			{"kind": "circle", "prefix": "range", "filled": false, "width": 2.0},
			{"kind": "circle", "prefix": "outer"},
			{"kind": "circle", "prefix": "inner"}
		]
	if String(data.get("kind", "")) == "ng_word_laser":
		return [
			{"kind": "line", "prefix": "trail"},
			{"kind": "line", "prefix": "core"}
		]
	if String(data.get("kind", "")) == "listener_summon":
		return [
			{"kind": "shadow"},
			{"kind": "line", "prefix": "trail"}
		]
	var parts: Array = []
	if bool(data.get("showHammer", false)):
		parts.append({"kind": "arc", "prefix": "trailGlow"})
		parts.append({"kind": "arc", "prefix": "trailHot"})
		parts.append({"kind": "arc", "prefix": "trailCore"})
		parts.append({"kind": "arc", "prefix": "trailEdge"})
	else:
		parts.append({"kind": "arc", "prefix": "main"})
		parts.append({"kind": "arc", "prefix": "core"})
	if bool(data["showBurst"]):
		parts.append({"kind": "circle", "prefix": "burst"})
		parts.append({"kind": "text", "prefix": "label"})
	return parts
