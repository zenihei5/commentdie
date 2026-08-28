class_name CharacterSystem
extends RefCounted

const TextureCacheSystemScript := preload("res://scripts/systems/texture_cache_system.gd")

const SELECT_PAGE_SIZE := 6
const SELECT_COLUMNS := 3
const SELECT_CARD_ORIGIN := Vector2(24.0, 90.0)
const SELECT_CARD_SIZE := Vector2(264.0, 224.0)
const SELECT_CARD_GAP := Vector2(16.0, 76.0)
const SELECT_CARD_WEAPON_OFFSET := Vector2(108.0, 61.0)
const SELECT_CARD_WEAPON_SIZE := Vector2(152.0, 118.0)
const SELECT_CARD_COMPACT_WEAPON_ICON_SIZE := Vector2(40.0, 40.0)
const SELECT_CARD_COMPACT_WEAPON_LABEL_FONT_SIZE := 13
const SELECT_CARD_COMPACT_WEAPON_LABEL_BASELINE := 15.0
const SELECT_CARD_COMPACT_WEAPON_LABEL_DARKEN := 0.14
const SELECT_CARD_COMPACT_WEAPON_LABEL_ALPHA := 0.94
const SELECT_LOCKED_ACCENT := Color("#8f70c8")
const SELECT_LOCKED_SOFT_FILL := Color("#f1ebf7")
const SELECT_LOCKED_SILHOUETTE_COLOR := Color("#44384f")
const SELECT_CARD_CORNER_RADIUS := 20.0
const SELECT_CARD_WALK_FPS := 8.0
const SELECT_CARD_WALK_SCALE := 1.42
const SELECT_CARD_AVATAR_VISUAL_HEIGHT := 140.0
const SELECT_CARD_AVATAR_FOOT_INSET := 4.0
const SELECT_LIST_PANEL_RECT := Rect2(76.0, 112.0, 880.0, 692.0)
const SELECT_DETAIL_PANEL_SIZE := Vector2(542.0, 692.0)
const DEFAULT_CHARACTER_ID := "ban_chan"

static func selection_visible_count(character_count: int) -> int:
	return maxi(SELECT_PAGE_SIZE, character_count)

static func find_character(characters: Array, id: String) -> Dictionary:
	for item in characters:
		var character: Dictionary = item as Dictionary
		if String(character.get("id", "")) == id:
			return character
	if not characters.is_empty():
		return characters[0] as Dictionary
	return fallback_character()

static func validated_character_id(characters: Array, id: String) -> String:
	for item in characters:
		var character: Dictionary = item as Dictionary
		if String(character.get("id", "")) == id and is_selectable(character):
			return id
	for item in characters:
		var character: Dictionary = item as Dictionary
		if String(character.get("id", "")) == DEFAULT_CHARACTER_ID:
			return DEFAULT_CHARACTER_ID
	return String((characters[0] as Dictionary).get("id", DEFAULT_CHARACTER_ID)) if not characters.is_empty() else DEFAULT_CHARACTER_ID

static func apply_unlock_profile(characters: Array, unlocked_ids: Array) -> void:
	var unlocked: Dictionary = {}
	for value in unlocked_ids:
		unlocked[String(value)] = true
	for item in characters:
		var character: Dictionary = item as Dictionary
		var id := String(character.get("id", ""))
		var always_unlocked := id in ["ban_chan", "superchat_chan", "maro_chan"]
		var is_unlocked := always_unlocked or bool(unlocked.get(id, false))
		character["isUnlocked"] = is_unlocked
		if is_unlocked:
			if String(character.get("status", "")) == "locked":
				character["status"] = "unlocked"
		else:
			character["status"] = "locked"

static func collab_partner_enabled(character: Dictionary) -> bool:
	return bool(character.get("collabPartnerEnabled", true))

static func selected_index(characters: Array, id: String) -> int:
	for i in range(characters.size()):
		var character: Dictionary = characters[i] as Dictionary
		if String(character.get("id", "")) == id:
			return i
	return 0

static func selected_character_state(characters: Array, weapons: Array, id: String, cache: Dictionary) -> Dictionary:
	var character: Dictionary = find_character(characters, id)
	var weapon_id: String = String(character.get("initialWeapon", ""))
	if weapon_id == "":
		weapon_id = "phase1_null_weapon" if String(character.get("unlockGroup", "")) == "senior_unit" else "ban_hammer"
	var weapon_fallback := fallback_weapon() if String(character.get("unlockGroup", "")) != "senior_unit" else fallback_null_weapon()
	var weapon: Dictionary = WeaponSystem.find_weapon(weapons, weapon_id, weapon_fallback)
	var sprite_path: String = String(character.get("sprite", ""))
	if sprite_path == "":
		sprite_path = gameplay_stationary_sprite_path(character)
	var character_id: String = String(character.get("id", "ban_chan"))
	var idle_sprite_path: String = String(character.get("idleSprite", ""))
	if idle_sprite_path == "" and character_id == "ban_chan":
		idle_sprite_path = "res://assets/generated/ban_chan_idle_3x3/sheet-transparent.png"
	var run_sprite_path: String = String(character.get("runSprite", ""))
	return {
		"character": character,
		"characterId": character_id,
		"weapon": weapon,
		"weaponId": weapon_id,
		"sprite": texture_from_cache(cache, sprite_path),
		"idleSprite": texture_from_cache(cache, idle_sprite_path),
		"runSprite": texture_from_cache(cache, run_sprite_path)
	}

static func apply_selected_character_for_target(target: Node, characters: Array, weapons: Array, id: String, cache: Dictionary) -> void:
	var selected: Dictionary = selected_character_state(characters, weapons, id, cache)
	target.set("current_character", selected["character"] as Dictionary)
	target.set("current_character_id", String(selected["characterId"]))
	target.set("current_weapon_id", String(selected["weaponId"]))
	target.set("current_weapon", selected["weapon"] as Dictionary)
	target.set("player_sprite", selected["sprite"] as Texture2D)
	target.set("player_idle_sprite", selected["idleSprite"] as Texture2D)
	target.set("player_run_sprite", selected["runSprite"] as Texture2D)

static func selected_character_state_by_index(characters: Array, index: int) -> Dictionary:
	if index < 0 or index >= characters.size():
		return {}
	var character: Dictionary = characters[index] as Dictionary
	return {
		"character": character,
		"characterId": String(character.get("id", "ban_chan"))
	}

static func update_selection_action(latch: Dictionary, characters: Array, current_index: int) -> Dictionary:
	var visible_count: int = selection_visible_count(characters.size())
	var action: Dictionary = ChoiceCardSystem.character_grid_selection_action(latch, current_index, visible_count, SELECT_PAGE_SIZE, SELECT_COLUMNS, 6)
	if ChoiceCardSystem.is_escape(action):
		return {"kind": "escape", "index": current_index}
	if ChoiceCardSystem.is_move(action):
		return {"kind": "move", "index": int(action["index"])}
	if ChoiceCardSystem.is_select(action):
		var selected: Dictionary = selected_character_state_by_index(characters, int(action["index"]))
		if selected.is_empty():
			return {"kind": "locked", "index": int(action["index"])}
		if not is_selectable(selected["character"] as Dictionary):
			return {"kind": "locked", "index": int(action["index"])}
		return {
			"kind": "select",
			"index": int(action["index"]),
			"characterId": String(selected["characterId"])
		}
	return {"kind": "", "index": current_index}

static func update_selection_for_target(target: Node, latch: Dictionary, characters: Array) -> Dictionary:
	var action: Dictionary = update_selection_action(latch, characters, int(target.get("selected_character_index")))
	var kind: String = String(action["kind"])
	if kind == "escape":
		target.set("state", "title")
		return {"startStreamFrameSelect": false}
	if kind == "move":
		target.set("selected_character_index", int(action["index"]))
	elif kind == "locked":
		target.set("selected_character_index", int(action["index"]))
	elif kind == "select":
		target.set("current_character_id", String(action["characterId"]))
		return {"startStreamFrameSelect": true}
	return {"startStreamFrameSelect": false}

static func start_selection_for_target(target: Node, choice_box: Control, result_panel: Control, characters: Array) -> Dictionary:
	StateFlowSystem.open_pre_run_select_for_target(target, "character_select", choice_box, result_panel)
	if characters.is_empty():
		target.set("current_character_id", "ban_chan")
		return {"restart": true, "chat": "今日の配信者を選べ"}
	var current_id: String = String(target.get("current_character_id"))
	target.set("selected_character_index", selected_index(characters, current_id))
	return {"restart": false, "chat": "今日の配信者を選べ"}

static func selection_page_count(character_count: int) -> int:
	var count: int = selection_visible_count(character_count)
	return maxi(1, int(ceil(float(maxi(1, count)) / float(SELECT_PAGE_SIZE))))

static func selection_page_for_index(index: int, character_count: int) -> int:
	var page_count: int = selection_page_count(character_count)
	var count: int = selection_visible_count(character_count)
	if count <= 0:
		return 0
	return clampi(int(clampi(index, 0, count - 1) / SELECT_PAGE_SIZE), 0, page_count - 1)

static func selection_index_for_page(characters: Array, page: int, local_index: int = 0) -> int:
	var page_count: int = selection_page_count(characters.size())
	var clamped_page: int = clampi(page, 0, page_count - 1)
	var start: int = clamped_page * SELECT_PAGE_SIZE
	var end: int = mini(start + SELECT_PAGE_SIZE, selection_visible_count(characters.size()))
	return clampi(start + local_index, start, end - 1)

static func selection_card_rect(local_index: int) -> Rect2:
	var safe_index: int = maxi(0, local_index)
	var col: int = safe_index % SELECT_COLUMNS
	var row: int = int(safe_index / SELECT_COLUMNS)
	return Rect2(
		SELECT_CARD_ORIGIN + Vector2(
			float(col) * (SELECT_CARD_SIZE.x + SELECT_CARD_GAP.x),
			float(row) * (SELECT_CARD_SIZE.y + SELECT_CARD_GAP.y)
		),
		SELECT_CARD_SIZE
	)

static func selection_group_heading_rects() -> Array:
	var row_width := SELECT_CARD_SIZE.x * float(SELECT_COLUMNS) + SELECT_CARD_GAP.x * float(SELECT_COLUMNS - 1)
	var first_row_y := SELECT_CARD_ORIGIN.y - 34.0
	var second_row_y := SELECT_CARD_ORIGIN.y + SELECT_CARD_SIZE.y + SELECT_CARD_GAP.y - 34.0
	return [
		Rect2(Vector2(SELECT_CARD_ORIGIN.x, first_row_y), Vector2(row_width, 22.0)),
		Rect2(Vector2(SELECT_CARD_ORIGIN.x, second_row_y), Vector2(row_width, 22.0))
	]

static func selection_group_heading_labels() -> Array[String]:
	return ["初期メンバー", "先輩メンバー"]

static func selection_list_panel_rect() -> Rect2:
	return SELECT_LIST_PANEL_RECT

static func selection_card_content_rects(card_rect: Rect2) -> Dictionary:
	return {
		"portrait": Rect2(card_rect.position + Vector2(8.0, 46.0), Vector2(98.0, 162.0)),
		"weapon": Rect2(card_rect.position + SELECT_CARD_WEAPON_OFFSET, SELECT_CARD_WEAPON_SIZE),
		"info": Rect2(card_rect.position + Vector2(108.0, 10.0), Vector2(148.0, 30.0))
	}

static func selection_card_compact_weapon_text_rects(weapon_rect: Rect2) -> Dictionary:
	var inner_width: float = maxf(1.0, weapon_rect.size.x - 20.0)
	return {
		"icon": Rect2(weapon_rect.position + Vector2(10.0, 10.0), SELECT_CARD_COMPACT_WEAPON_ICON_SIZE),
		"label": Rect2(weapon_rect.position + Vector2(58.0, 8.0), Vector2(maxf(1.0, weapon_rect.size.x - 68.0), 22.0)),
		"name": Rect2(weapon_rect.position + Vector2(10.0, 56.0), Vector2(inner_width, 54.0)),
		"condition": Rect2(weapon_rect.position + Vector2(10.0, 42.0), Vector2(inner_width, 66.0))
	}

static func selection_card_compact_weapon_label_color(accent: Color) -> Color:
	var label_color := accent.darkened(SELECT_CARD_COMPACT_WEAPON_LABEL_DARKEN)
	label_color.a = SELECT_CARD_COMPACT_WEAPON_LABEL_ALPHA
	return label_color

static func selection_locked_silhouette_image(source_image: Image, silhouette_color: Color = SELECT_LOCKED_SILHOUETTE_COLOR) -> Image:
	if source_image == null or source_image.get_width() <= 0 or source_image.get_height() <= 0:
		return null
	var result: Image = Image.create(source_image.get_width(), source_image.get_height(), false, Image.FORMAT_RGBA8)
	if result == null:
		return null
	result.fill(Color(0.0, 0.0, 0.0, 0.0))
	for y in range(source_image.get_height()):
		for x in range(source_image.get_width()):
			var source_pixel: Color = source_image.get_pixel(x, y)
			if source_pixel.a > 0.0:
				result.set_pixel(x, y, Color(silhouette_color.r, silhouette_color.g, silhouette_color.b, source_pixel.a))
	return result

static func selection_detail_locked_content_rects(panel_rect: Rect2) -> Dictionary:
	var normal_content := selection_detail_content_rects(panel_rect)
	return {
		"image": normal_content["image"] as Rect2,
		"condition": Rect2(panel_rect.position + Vector2(28.0, 426.0), Vector2(panel_rect.size.x - 56.0, 92.0))
	}

static func selection_card_walk_metadata(character: Dictionary) -> Dictionary:
	var offset_value: Variant = character.get("cardWalkSpriteOffset", {"x": 0, "y": 0})
	if not offset_value is Dictionary:
		offset_value = {"x": 0, "y": 0}
	var scale_value := maxf(0.1, float(character.get("cardWalkSpriteScale", SELECT_CARD_WALK_SCALE)))
	return {
		"path": String(character.get("runSprite", "")),
		"cols": maxi(1, int(character.get("runSpriteCols", 10))),
		"rows": maxi(1, int(character.get("runSpriteRows", 1))),
		"fps": SELECT_CARD_WALK_FPS,
		"sourceFps": maxf(0.0, float(character.get("runSpriteFps", 12.0))),
		"staticFrame": 0,
		"scale": scale_value,
		"offset": offset_value as Dictionary
	}

static func gameplay_stationary_sprite_path(character: Dictionary) -> String:
	var idle_path := String(character.get("idleSprite", ""))
	if idle_path != "":
		return idle_path
	return String(character.get("sprite", ""))

static func selection_card_stationary_metadata(character: Dictionary) -> Dictionary:
	var uses_idle_sheet := String(character.get("idleSprite", "")) != ""
	return {
		"path": gameplay_stationary_sprite_path(character),
		"cols": maxi(1, int(character.get("idleSpriteCols", 1))) if uses_idle_sheet else 1,
		"rows": maxi(1, int(character.get("idleSpriteRows", 1))) if uses_idle_sheet else 1,
		"staticFrame": 0
	}

static func selection_card_can_use_walk_sprite(texture_available: bool, status: String) -> bool:
	return texture_available and status != "coming_soon"

static func selection_card_walk_should_animate(status: String, selectable: bool, selected: bool) -> bool:
	return selected and selectable and status != "locked" and status != "coming_soon"

static func selection_card_avatar_mode(status: String, selectable: bool, selected: bool) -> String:
	return "walk" if selection_card_walk_should_animate(status, selectable, selected) else "static"

static func selection_card_walk_frame_index(time: float, selected: bool, selectable: bool, columns: int = 10, fps: float = SELECT_CARD_WALK_FPS) -> int:
	if not selected or not selectable:
		return 0
	var frame_count := maxi(1, columns)
	var frame := int(floor(maxf(0.0, time) * maxf(0.0, fps)))
	return posmod(frame, frame_count)

static func selection_card_walk_source_rect(texture_size: Vector2, columns: int, rows: int, frame_index: int) -> Rect2:
	var safe_columns := maxi(1, columns)
	var safe_rows := maxi(1, rows)
	var cell_size := Vector2(texture_size.x / float(safe_columns), texture_size.y / float(safe_rows))
	var frame_count := maxi(1, safe_columns * safe_rows)
	var frame := posmod(frame_index, frame_count)
	var frame_column := frame % safe_columns
	var frame_row := int(frame / safe_columns)
	return Rect2(Vector2(float(frame_column) * cell_size.x, float(frame_row) * cell_size.y), cell_size)

static func selection_card_walk_destination_rect(container: Rect2, texture_size: Vector2, columns: int, rows: int, scale_factor: float = SELECT_CARD_WALK_SCALE, offset: Vector2 = Vector2.ZERO) -> Rect2:
	var source_cell := selection_card_walk_source_rect(texture_size, columns, rows, 0).size
	if source_cell.x <= 0.0 or source_cell.y <= 0.0 or container.size.x <= 0.0 or container.size.y <= 0.0:
		return Rect2(container.position, Vector2.ZERO)
	var fit_scale := minf(container.size.x / source_cell.x, container.size.y / source_cell.y)
	var destination_size := source_cell * fit_scale * maxf(0.1, scale_factor)
	var destination_position := Vector2(container.get_center().x - destination_size.x * 0.5, container.end.y - destination_size.y)
	return Rect2(destination_position + offset, destination_size)

static func selection_card_walk_visible_rect(container: Rect2, destination: Rect2) -> Rect2:
	return destination.intersection(container)

static func selection_card_avatar_opaque_bounds(image: Image, columns: int, rows: int, union_frames: bool) -> Rect2:
	if image == null or image.get_width() <= 0 or image.get_height() <= 0:
		return Rect2()
	var safe_columns := maxi(1, columns)
	var safe_rows := maxi(1, rows)
	var cell_size := Vector2i(maxi(1, int(image.get_width() / safe_columns)), maxi(1, int(image.get_height() / safe_rows)))
	var frame_count := maxi(1, safe_columns * safe_rows) if union_frames else 1
	var result := Rect2()
	var has_bounds := false
	for frame in range(frame_count):
		var frame_column := frame % safe_columns
		var frame_row := int(frame / safe_columns)
		var frame_rect := Rect2i(Vector2i(frame_column * cell_size.x, frame_row * cell_size.y), cell_size)
		var used := image.get_region(frame_rect).get_used_rect()
		if used.size.x <= 0 or used.size.y <= 0:
			continue
		var bounds := Rect2(Vector2(used.position), Vector2(used.size))
		if not has_bounds:
			result = bounds
			has_bounds = true
		else:
			result = result.merge(bounds)
	return result if has_bounds else Rect2()

static func selection_card_avatar_destination_rect(container: Rect2, source_cell_size: Vector2, opaque_bounds: Rect2, visual_height: float = SELECT_CARD_AVATAR_VISUAL_HEIGHT, foot_inset: float = SELECT_CARD_AVATAR_FOOT_INSET, scale_adjust: float = 1.0, offset: Vector2 = Vector2.ZERO) -> Rect2:
	if source_cell_size.x <= 0.0 or source_cell_size.y <= 0.0 or opaque_bounds.size.x <= 0.0 or opaque_bounds.size.y <= 0.0 or container.size.x <= 0.0 or container.size.y <= 0.0:
		return Rect2(container.position, Vector2.ZERO)
	var scale_value := maxf(0.01, visual_height) / opaque_bounds.size.y * maxf(0.01, scale_adjust)
	var destination_size := source_cell_size * scale_value
	var destination_position := Vector2(
		container.get_center().x - opaque_bounds.get_center().x * scale_value,
		container.end.y - foot_inset - opaque_bounds.end.y * scale_value
	)
	return Rect2(destination_position + offset, destination_size)

static func selection_card_avatar_mapped_opaque_rect(destination: Rect2, source_cell_size: Vector2, opaque_bounds: Rect2) -> Rect2:
	if source_cell_size.x <= 0.0 or source_cell_size.y <= 0.0 or destination.size.x <= 0.0 or destination.size.y <= 0.0:
		return Rect2()
	var scale_value := destination.size.x / source_cell_size.x
	return Rect2(destination.position + opaque_bounds.position * scale_value, opaque_bounds.size * scale_value)

static func selection_detail_content_rects(panel_rect: Rect2) -> Dictionary:
	return {
		"image": Rect2(panel_rect.position + Vector2(28.0, 102.0), Vector2(panel_rect.size.x - 56.0, 300.0)),
		"weapon": Rect2(panel_rect.position + Vector2(28.0, 414.0), Vector2(panel_rect.size.x - 56.0, 50.0)),
		"tags": Rect2(panel_rect.position + Vector2(28.0, 476.0), Vector2(panel_rect.size.x - 56.0, 28.0)),
		"trait": Rect2(panel_rect.position + Vector2(28.0, 516.0), Vector2(panel_rect.size.x - 56.0, 64.0)),
		"intro": Rect2(panel_rect.position + Vector2(28.0, 592.0), Vector2(panel_rect.size.x - 56.0, 76.0))
	}

static func selection_index_at_local(pos: Vector2, selected_index: int, character_count: int) -> int:
	if character_count <= 0 or not Rect2(Vector2.ZERO, SELECT_LIST_PANEL_RECT.size).has_point(pos):
		return -1
	var page: int = selection_page_for_index(selected_index, character_count)
	var start: int = page * SELECT_PAGE_SIZE
	var visible_count: int = selection_visible_count(character_count)
	for local_index in range(SELECT_PAGE_SIZE):
		var index: int = start + local_index
		if index >= visible_count:
			break
		if selection_card_rect(local_index).has_point(pos):
			return index
	return -1

static func is_unlocked(character: Dictionary) -> bool:
	return bool(character.get("isUnlocked", true))

static func status_id(character: Dictionary) -> String:
	var explicit_status: String = String(character.get("status", "")).strip_edges()
	if not is_unlocked(character):
		return "locked"
	if explicit_status == "locked":
		return "unlocked"
	if explicit_status != "":
		return explicit_status
	return "playable"

static func is_selectable(character: Dictionary) -> bool:
	var status: String = status_id(character)
	return is_unlocked(character) and (status == "playable" or status == "selected" or status == "unlocked")

static func status_text(character: Dictionary) -> String:
	var status: String = status_id(character)
	match status:
		"coming_soon":
			return "準備中"
		"locked":
			return "未開放"
		"selected":
			return "選択中"
		_:
			return "使用可能"

static func selection_status_badge_text(status: String, selectable: bool, selected: bool) -> String:
	match status:
		"coming_soon":
			return "準備中"
		"locked":
			return "LOCKED"
		_:
			return "★ 選択中" if selectable and selected else ""

static func selection_card_status_text(character: Dictionary, selected: bool = false) -> String:
	return selection_status_badge_text(status_id(character), is_selectable(character), selected)

static func selection_detail_status_text(character: Dictionary) -> String:
	var status: String = status_id(character)
	if status == "locked":
		return "LOCKED"
	if status == "coming_soon":
		return "準備中"
	return ""

static func theme_colors(character: Dictionary) -> Dictionary:
	var raw_theme: Variant = character.get("themeColors", {})
	if raw_theme is Dictionary:
		var theme_data: Dictionary = raw_theme as Dictionary
		var accent_text := String(theme_data.get("accent", ""))
		var accent2_text := String(theme_data.get("accent2", ""))
		var soft_text := String(theme_data.get("soft", ""))
		if accent_text != "" and accent2_text != "" and soft_text != "":
			return {"accent": Color(accent_text), "accent2": Color(accent2_text), "soft": Color(soft_text)}
	var theme: String = String(character.get("themeColor", ""))
	var id: String = String(character.get("id", ""))
	if theme == "yellow_orange" or id == "superchat_chan":
		return {"accent": Color("#ffb238"), "accent2": Color("#ff7f4f"), "soft": Color("#fff4d8")}
	if theme == "pink_mint" or id == "maro_chan":
		return {"accent": Color("#ff7fbd"), "accent2": Color("#5ecfc0"), "soft": Color("#fff0f7")}
	return {"accent": Color("#ff4f92"), "accent2": Color("#7a56c8"), "soft": Color("#fff2fa")}

static func default_recommend_text(character_id: String) -> String:
	if character_id == "superchat_chan":
		return "遠くから敵を処理したい人向け。スパチャ弾で安全に戦える。"
	if character_id == "maro_chan":
		return "回収や安定感を重視したい人向け。コメントブーメランで周囲を守れる。"
	return "初めて遊ぶ人向け。近距離で敵をまとめて処理しやすい。"

static func default_specialty_text(character_id: String) -> String:
	if character_id == "superchat_chan":
		return "遠距離攻撃 / 弾数強化 / 火力型"
	if character_id == "maro_chan":
		return "周囲防御 / 回収補助 / 成長型"
	return "近距離制圧 / 正面突破 / 安定型"

static func default_card_tags(character_id: String) -> Array:
	if character_id == "superchat_chan":
		return ["#遠距離火力", "#安全圏"]
	if character_id == "maro_chan":
		return ["#回収補助", "#安定型"]
	return ["#近距離制圧", "#初心者向け"]

static func default_detail_tags(character_id: String) -> Array:
	if character_id == "superchat_chan":
		return ["#遠距離火力", "#安全圏", "#弾幕", "#火力型"]
	if character_id == "maro_chan":
		return ["#回収補助", "#周囲防御", "#安定型", "#成長型"]
	return ["#近距離制圧", "#初心者向け", "#正面突破"]

static func selection_card_view(character: Dictionary, weapons: Array) -> Dictionary:
	var weapon_id: String = String(character.get("initialWeapon", ""))
	if weapon_id == "":
		weapon_id = "phase1_null_weapon" if String(character.get("unlockGroup", "")) == "senior_unit" else "ban_hammer"
	var weapon_fallback := fallback_weapon() if String(character.get("unlockGroup", "")) != "senior_unit" else fallback_null_weapon()
	var weapon: Dictionary = WeaponSystem.find_weapon(weapons, weapon_id, weapon_fallback)
	var passive_data: Dictionary = passive(character)
	var character_id: String = String(character.get("id", "ban_chan"))
	var colors: Dictionary = theme_colors(character)
	var walk_metadata: Dictionary = selection_card_walk_metadata(character)
	var stationary_metadata: Dictionary = selection_card_stationary_metadata(character)
	var select_sprite_path := String(character.get("selectSprite", ""))
	if select_sprite_path == "":
		select_sprite_path = String(character.get("sprite", ""))
	var evolution: Dictionary = weapon.get("evolution", {}) as Dictionary
	var evolved_weapon_id: String = String(character.get("evolvedWeaponId", evolution.get("evolvedWeaponId", "")))
	var evolved_weapon: Dictionary = WeaponSystem.find_weapon(weapons, evolved_weapon_id, {})
	var evolved_weapon_name: String = String(character.get("evolvedWeaponName", evolved_weapon.get("displayName", "")))
	var evolved_icon_path: String = String(evolved_weapon.get("iconPath", weapon.get("iconPath", "")))
	var status_value := status_id(character)
	var view := {
		"displayName": String(character.get("displayName", "配信者")),
		"nickname": String(character.get("nickname", "")),
		"roleName": String(character.get("roleName", "")),
		"weaponName": String(weapon.get("displayName", "未設定")),
		"weaponIconPath": String(weapon.get("iconPath", "")),
		"evolvedWeaponName": evolved_weapon_name,
		"evolvedWeaponIconPath": evolved_icon_path,
		"passiveName": String(passive_data.get("displayName", "なし")),
		"passiveDescription": String(passive_data.get("description", "")),
		"description": String(character.get("description", "")),
		"recommendText": String(character.get("recommendText", default_recommend_text(character_id))),
		"specialtyText": String(character.get("specialtyText", default_specialty_text(character_id))),
		"cardTags": character.get("cardTags", default_card_tags(character_id)) as Array,
		"detailTags": character.get("detailTags", default_detail_tags(character_id)) as Array,
		"spritePath": select_sprite_path,
		"walkSpritePath": walk_metadata["path"],
		"walkSpriteCols": walk_metadata["cols"],
		"walkSpriteRows": walk_metadata["rows"],
		"walkSpriteFps": walk_metadata["fps"],
		"walkSpriteSourceFps": walk_metadata["sourceFps"],
		"walkSpriteStaticFrame": walk_metadata["staticFrame"],
		"cardWalkSpriteScale": walk_metadata["scale"],
		"cardWalkSpriteOffset": walk_metadata["offset"],
		"staticSpritePath": stationary_metadata["path"],
		"staticSpriteCols": stationary_metadata["cols"],
		"staticSpriteRows": stationary_metadata["rows"],
		"staticSpriteFrame": stationary_metadata["staticFrame"],
		"gameplaySpritePath": String(character.get("sprite", "")),
		"selectSpriteScale": float(character.get("selectSpriteScale", 1.0)),
		"selectSpriteOffset": character.get("selectSpriteOffset", {"x": 0, "y": 0}) as Dictionary,
		"cardSelectSpriteScale": float(character.get("cardSelectSpriteScale", 1.0)),
		"cardSelectSpriteOffset": character.get("cardSelectSpriteOffset", {"x": 0, "y": 0}) as Dictionary,
		"isUnlocked": is_unlocked(character),
		"isSelectable": is_selectable(character),
		"statusId": status_id(character),
		"statusText": status_text(character),
		"accent": colors["accent"] as Color,
		"accent2": colors["accent2"] as Color,
		"softFill": colors["soft"] as Color,
		"unlockConditionText": String(character.get("unlockConditionText", "？？？"))
	}
	if status_value == "locked":
		view["displayName"] = "？？？"
		view["nickname"] = ""
		view["roleName"] = ""
		view["weaponName"] = ""
		view["weaponIconPath"] = ""
		view["evolvedWeaponName"] = ""
		view["evolvedWeaponIconPath"] = ""
		view["passiveName"] = ""
		view["passiveDescription"] = ""
		view["description"] = ""
		view["recommendText"] = ""
		view["specialtyText"] = ""
		view["cardTags"] = []
		view["detailTags"] = []
		view["accent"] = SELECT_LOCKED_ACCENT
		view["accent2"] = SELECT_LOCKED_ACCENT
		view["softFill"] = SELECT_LOCKED_SOFT_FILL
	return view

static func fallback_character() -> Dictionary:
	return {
		"id": "ban_chan",
		"displayName": "赤羽ばんり",
		"roleName": "バランス型",
		"description": "扱いやすい標準配信者。BANハンマーで近づく敵をまとめて処理できる。",
		"sprite": "res://assets/characters/ban_chan.png",
		"spriteScale": 0.095,
		"spriteOffset": {"x": 0, "y": -34},
		"initialWeapon": "ban_hammer",
		"baseStats": {"hp": 100, "moveSpeed": 5.0, "dashCooldown": 1.2, "pickupRange": 1.0, "invincibleTime": 0.7},
		"initialResources": {"ngTickets": 0, "heartStock": 0, "giftHype": 0},
		"passiveSkill": {"id": "beginner_safe", "displayName": "初配信補正", "params": {"invincibleTimeBonus": 0.2}}
	}

static func fallback_weapon() -> Dictionary:
	return {
		"id": "ban_hammer",
		"displayName": "BANハンマー",
		"attackType": "melee_arc",
		"damage": 12.0,
		"range": 186.0,
		"arcAngle": 135.0,
		"attackInterval": 0.85,
		"knockback": 18.0,
		"magnetRange": 95.0
	}

static func fallback_null_weapon() -> Dictionary:
	return {
		"id": "phase1_null_weapon",
		"displayName": "固有武器は次段階で追加予定",
		"attackType": "none",
		"damage": 0.0,
		"range": 0.0,
		"knockback": 0.0,
		"attackInterval": 0.0,
		"magnetRange": 0.0,
		"isPhase1Placeholder": true
	}

static func attack_multiplier(character: Dictionary) -> float:
	return maxf(0.01, float(character.get("attackMultiplier", 1.0)))

static func move_speed_multiplier(character: Dictionary) -> float:
	return maxf(0.01, float(character.get("moveSpeedMultiplier", 1.0)))

static func base_stats(character: Dictionary) -> Dictionary:
	if character.has("baseStats") and character["baseStats"] is Dictionary:
		return character["baseStats"] as Dictionary
	return character

static func initial_resources(character: Dictionary) -> Dictionary:
	if character.has("initialResources") and character["initialResources"] is Dictionary:
		return character["initialResources"] as Dictionary
	return {
		"ngTickets": character.get("initialNgStock", 0),
		"heartStock": character.get("initialHeartStock", 0),
		"giftHype": 0
	}

static func passive(character: Dictionary) -> Dictionary:
	if character.has("passiveSkill") and character["passiveSkill"] is Dictionary:
		return character["passiveSkill"] as Dictionary
	return {}

static func apply_passive_values(character: Dictionary, values: Dictionary) -> Dictionary:
	var result: Dictionary = values.duplicate()
	var passive_data: Dictionary = passive(character)
	if passive_data.is_empty():
		return result
	var passive_id: String = String(passive_data.get("id", ""))
	var params: Dictionary = passive_data.get("params", {}) as Dictionary
	if passive_id == "beginner_safe":
		result["playerBaseInvincibleTime"] = float(result.get("playerBaseInvincibleTime", 0.7)) + float(params.get("invincibleTimeBonus", 0.2))
	elif passive_id == "superchat_bonus":
		result["passiveScoreRate"] = float(result.get("passiveScoreRate", 1.0)) * float(params.get("scoreRate", 1.1))
	elif passive_id == "sweet_tooth_passive":
		result["passiveMaroGoodRate"] = float(result.get("passiveMaroGoodRate", 1.0)) * float(params.get("marshmallowGoodEffectRate", 1.1))
		result["passiveMaroPickupRate"] = float(result.get("passiveMaroPickupRate", 1.0)) * float(params.get("marshmallowPickupRangeRate", 1.2))
	return result

static func apply_passive_for_target(target: Node, character: Dictionary) -> void:
	var values: Dictionary = apply_passive_values(character, {
		"playerBaseInvincibleTime": target.get("player_base_invincible_time"),
		"passiveScoreRate": target.get("passive_score_rate"),
		"passiveMaroGoodRate": target.get("passive_maro_good_rate"),
		"passiveMaroPickupRate": target.get("passive_maro_pickup_rate")
	})
	target.set("player_base_invincible_time", float(values["playerBaseInvincibleTime"]))
	target.set("passive_score_rate", float(values["passiveScoreRate"]))
	target.set("passive_maro_good_rate", float(values["passiveMaroGoodRate"]))
	target.set("passive_maro_pickup_rate", float(values["passiveMaroPickupRate"]))

static func role_name(character: Dictionary) -> String:
	return String(character.get("roleName", character.get("archetype", "配信者")))

static func texture_from_cache(cache: Dictionary, sprite_path: String) -> Texture2D:
	if sprite_path == "":
		return null
	return TextureCacheSystemScript.load_png_texture(cache, sprite_path)
