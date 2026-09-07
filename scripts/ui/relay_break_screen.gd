class_name RelayBreakScreen
extends Control

const GameFontSystemScript := preload("res://scripts/systems/game_font_system.gd")

signal break_screen_opened(context: Dictionary)
signal choice_changed(choice: int)
signal heal_selected(context: Dictionary)
signal gift_selected(context: Dictionary)

enum BreakChoice { HEAL, GIFT }
enum BreakScreenState { ENTERING, SELECTING, RESOLVING_HEAL, OPENING_GIFT, EXITING }

const BASE_SIZE := Vector2(1600.0, 900.0)
const PANEL_RECT := Rect2(260.0, 142.0, 1080.0, 568.0)
const HEAL_CARD_RECT := Rect2(386.0, 326.0, 390.0, 260.0)
const GIFT_CARD_RECT := Rect2(824.0, 326.0, 390.0, 260.0)
const BREAK_ASSET_ROOT := "res://assets/generated/relay_break_v1/"
const PANEL_TEXTURE_PATH := BREAK_ASSET_ROOT + "panel_frame.png"
const HEAL_CARD_TEXTURE_PATH := BREAK_ASSET_ROOT + "card_heal.png"
const GIFT_CARD_TEXTURE_PATH := BREAK_ASSET_ROOT + "card_gift.png"
const HEAL_ICON_TEXTURE_PATH := BREAK_ASSET_ROOT + "icon_heal.png"
const GIFT_ICON_TEXTURE_PATH := BREAK_ASSET_ROOT + "icon_gift.png"
const BOSS_ACCENT_TEXTURE_PATH := BREAK_ASSET_ROOT + "boss_accent.png"
const CHARACTER_TEXTURES := {
	"aosumi_kyasumi": BREAK_ASSET_ROOT + "character_kyasumi.png",
	"kyasumi": BREAK_ASSET_ROOT + "character_kyasumi.png",
	"akarine_rizumu": BREAK_ASSET_ROOT + "character_rizumu.png",
	"rizumu": BREAK_ASSET_ROOT + "character_rizumu.png",
	"shizuki_miimu": BREAK_ASSET_ROOT + "character_miimu.png",
	"miimu": BREAK_ASSET_ROOT + "character_miimu.png",
	"supana": BREAK_ASSET_ROOT + "character_supana.png",
	"superchat_chan": BREAK_ASSET_ROOT + "character_supana.png",
	"maron": BREAK_ASSET_ROOT + "character_maron.png",
	"maro_chan": BREAK_ASSET_ROOT + "character_maron.png",
	"banri": BREAK_ASSET_ROOT + "character_banri.png",
	"ban_chan": BREAK_ASSET_ROOT + "character_banri.png"
}

const SEGMENT_NAMES := {
	"zatsudan": "雑談枠",
	"gameplay": "ゲーム実況枠",
	"singing": "歌枠",
	"drawing": "お絵描き枠",
	"collab": "コラボ枠",
	"boss": "ラストオフライン"
}
const SEGMENT_LABELS := {
	"zatsudan": "CHAT",
	"gameplay": "GAME",
	"singing": "SONG",
	"drawing": "DRAW",
	"collab": "COLLAB",
	"boss": "BOSS"
}

var screen_state := BreakScreenState.EXITING
var current_choice := BreakChoice.HEAL
var input_locked := false
var context: Dictionary = {}
var is_before_boss := false
var content: Control
var dim_overlay: ColorRect
var progress_visual: Control
var panel: TextureRect
var character_art: TextureRect
var character_fallback: Label
var boss_accent: TextureRect
var break_label: Label
var title_label: Label
var subtitle_label: Label
var previous_label: Label
var next_label: Label
var heal_card: TextureButton
var gift_card: TextureButton
var heal_icon: TextureRect
var gift_icon: TextureRect
var heal_title: Label
var heal_description: Label
var heal_preview_label: Label
var heal_full_label: Label
var gift_title: Label
var gift_description: Label
var gift_footer: Label
var operation_guide: Label
var animation_tween: Tween
var content_tween: Tween
var heal_preview_tween: Tween
var left_down := false
var right_down := false
var accept_down := false
var texture_cache: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = 1000
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_screen()
	if get_viewport() != null:
		get_viewport().size_changed.connect(_on_viewport_size_changed)
	_on_viewport_size_changed()
	visible = false

func _on_viewport_size_changed() -> void:
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = BASE_SIZE
	size = viewport_size
	if dim_overlay != null:
		dim_overlay.size = viewport_size
	if content != null:
		var uniform_scale := minf(viewport_size.x / BASE_SIZE.x, viewport_size.y / BASE_SIZE.y)
		content.scale = Vector2.ONE * uniform_scale
		content.position = (viewport_size - BASE_SIZE * uniform_scale) * 0.5

func _build_screen() -> void:
	dim_overlay = ColorRect.new()
	dim_overlay.color = Color(0.10, 0.08, 0.15, 0.42)
	dim_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim_overlay)

	content = Control.new()
	content.set_size(BASE_SIZE)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(content)

	progress_visual = _make_progress_visual()
	progress_visual.position = Vector2(280.0, 22.0)
	progress_visual.size = Vector2(1040.0, 52.0)
	content.add_child(progress_visual)

	panel = _make_texture_rect(_load_texture(PANEL_TEXTURE_PATH), PANEL_RECT)
	content.add_child(panel)

	character_art = _make_texture_rect(null, Rect2(168.0, 365.0, 250.0, 330.0))
	character_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(character_art)
	character_fallback = _make_label("", Rect2(186.0, 510.0, 214.0, 42.0), 16, Color("#9f83a0"), HORIZONTAL_ALIGNMENT_CENTER, false)
	character_fallback.mouse_filter = Control.MOUSE_FILTER_IGNORE
	character_fallback.visible = false
	content.add_child(character_fallback)

	boss_accent = _make_texture_rect(_load_texture(BOSS_ACCENT_TEXTURE_PATH), Rect2(346.0, 274.0, 908.0, 54.0))
	boss_accent.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(boss_accent)

	break_label = _make_label("BREAK TIME", Rect2(338.0, 186.0, 500.0, 28.0), 20, Color("#e84c93"), HORIZONTAL_ALIGNMENT_LEFT, true)
	title_label = _make_label("", Rect2(338.0, 218.0, 560.0, 52.0), 32, Color("#5b285b"), HORIZONTAL_ALIGNMENT_LEFT, true)
	subtitle_label = _make_label("", Rect2(338.0, 270.0, 540.0, 28.0), 16, Color("#745b78"), HORIZONTAL_ALIGNMENT_LEFT, false)
	previous_label = _make_label("", Rect2(888.0, 188.0, 370.0, 30.0), 18, Color("#ae5a91"), HORIZONTAL_ALIGNMENT_RIGHT, true)
	next_label = _make_label("", Rect2(888.0, 220.0, 370.0, 48.0), 22, Color("#54427b"), HORIZONTAL_ALIGNMENT_RIGHT, true)
	for label in [break_label, title_label, subtitle_label, previous_label, next_label]:
		content.add_child(label)

	heal_card = _make_card(_load_texture(HEAL_CARD_TEXTURE_PATH), HEAL_CARD_RECT, BreakChoice.HEAL)
	gift_card = _make_card(_load_texture(GIFT_CARD_TEXTURE_PATH), GIFT_CARD_RECT, BreakChoice.GIFT)
	content.add_child(heal_card)
	content.add_child(gift_card)

	heal_icon = _make_texture_rect(_load_texture(HEAL_ICON_TEXTURE_PATH), Rect2(143.0, 17.0, 104.0, 104.0))
	gift_icon = _make_texture_rect(_load_texture(GIFT_ICON_TEXTURE_PATH), Rect2(143.0, 17.0, 104.0, 104.0))
	heal_card.add_child(heal_icon)
	gift_card.add_child(gift_icon)
	heal_title = _make_label("ひと休みする", Rect2(24.0, 128.0, 342.0, 34.0), 24, Color("#24566b"), HORIZONTAL_ALIGNMENT_CENTER, true)
	heal_description = _make_label("メンタルを30%回復", Rect2(24.0, 164.0, 342.0, 25.0), 15, Color("#527476"), HORIZONTAL_ALIGNMENT_CENTER, false)
	heal_preview_label = _make_label("", Rect2(40.0, 201.0, 310.0, 35.0), 16, Color("#24566b"), HORIZONTAL_ALIGNMENT_CENTER, true)
	heal_full_label = _make_label("", Rect2(40.0, 234.0, 310.0, 22.0), 13, Color("#628488"), HORIZONTAL_ALIGNMENT_CENTER, false)
	heal_card.add_child(heal_title)
	heal_card.add_child(heal_description)
	heal_card.add_child(heal_preview_label)
	heal_card.add_child(heal_full_label)

	gift_title = _make_label("ギフトを開ける", Rect2(24.0, 128.0, 342.0, 34.0), 24, Color("#81335d"), HORIZONTAL_ALIGNMENT_CENTER, true)
	gift_description = _make_label("武器・アクセを強化", Rect2(24.0, 164.0, 342.0, 25.0), 15, Color("#9b5c77"), HORIZONTAL_ALIGNMENT_CENTER, false)
	gift_footer = _make_label("3つから1つ選択", Rect2(40.0, 204.0, 310.0, 35.0), 16, Color("#81335d"), HORIZONTAL_ALIGNMENT_CENTER, true)
	gift_card.add_child(gift_title)
	gift_card.add_child(gift_description)
	gift_card.add_child(gift_footer)

	operation_guide = _make_label("← → / A D：選択    Enter / Space：決定", Rect2(430.0, 632.0, 740.0, 34.0), 16, Color("#715e78"), HORIZONTAL_ALIGNMENT_CENTER, false)
	content.add_child(operation_guide)

func _make_progress_visual() -> Control:
	var visual := RelayBreakProgressVisual.new()
	visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return visual

func _make_texture_rect(texture: Texture2D, rect: Rect2) -> TextureRect:
	var node := TextureRect.new()
	node.position = rect.position
	node.size = rect.size
	node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.texture = texture
	return node

func _load_texture(path: String) -> Texture2D:
	if path == "":
		return null
	if texture_cache.has(path):
		return texture_cache[path] as Texture2D
	var texture: Texture2D = null
	# Prefer the imported resource when the editor has generated its .import
	# sidecar. Fresh checkouts can still display the transparent PNG directly.
	if FileAccess.file_exists(path + ".import"):
		texture = ResourceLoader.load(path) as Texture2D
	if texture == null:
		var image := Image.new()
		if image.load(path) == OK:
			texture = ImageTexture.create_from_image(image)
	texture_cache[path] = texture
	return texture

func _make_card(texture: Texture2D, rect: Rect2, choice: int) -> TextureButton:
	var card := TextureButton.new()
	card.position = rect.position
	card.size = rect.size
	card.ignore_texture_size = true
	card.stretch_mode = TextureButton.STRETCH_SCALE
	card.texture_normal = texture
	card.focus_mode = Control.FOCUS_NONE
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	card.mouse_entered.connect(_on_card_hover.bind(choice))
	card.pressed.connect(_on_card_pressed.bind(choice))
	return card

func _make_label(text_value: String, rect: Rect2, font_size: int, color: Color, alignment: HorizontalAlignment, black: bool) -> Label:
	var label := Label.new()
	label.position = rect.position
	label.size = rect.size
	label.text = text_value
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if black:
		GameFontSystemScript.apply_black_font(label)
	else:
		GameFontSystemScript.apply_regular_font(label)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(1.0, 1.0, 1.0, 0.85))
	label.add_theme_constant_override("outline_size", 2)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func show_context(next_context: Dictionary) -> void:
	context = next_context.duplicate(true)
	is_before_boss = bool(context.get("isBeforeBoss", false))
	current_choice = BreakChoice.HEAL
	input_locked = false
	screen_state = BreakScreenState.ENTERING
	left_down = false
	right_down = false
	accept_down = false
	_refresh_context_visuals()
	visible = true
	content.modulate = Color(1.0, 1.0, 1.0, 0.0)
	if content_tween != null:
		content_tween.kill()
	content_tween = create_tween()
	content_tween.set_parallel(true)
	content_tween.tween_property(content, "modulate", Color.WHITE, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	content_tween.set_parallel(false)
	content_tween.tween_callback(func(): screen_state = BreakScreenState.SELECTING)
	break_screen_opened.emit(context)
	_apply_choice_visuals()

func hide_screen() -> void:
	screen_state = BreakScreenState.EXITING
	input_locked = true
	visible = false
	if animation_tween != null:
		animation_tween.kill()
	if content_tween != null:
		content_tween.kill()

func _refresh_context_visuals() -> void:
	var previous_id := String(context.get("previousSegmentId", "zatsudan"))
	var next_id := String(context.get("nextSegmentId", "gameplay"))
	var previous_name := String(SEGMENT_NAMES.get(previous_id, previous_id))
	var next_name := String(SEGMENT_NAMES.get(next_id, next_id))
	break_label.text = "BREAK TIME"
	if is_before_boss:
		title_label.text = "最終決戦に備えよう！"
		subtitle_label.text = "選択後、ラストオフラインへ"
		previous_label.text = "%s CLEAR!" % previous_name
		next_label.text = "次は「%s」" % next_name
		break_label.add_theme_color_override("font_color", Color("#c45d95"))
	else:
		title_label.text = "ちょっと休憩！"
		subtitle_label.text = "次の配信に備えよう"
		previous_label.text = "%s CLEAR!" % previous_name
		next_label.text = "次は「%s」" % next_name
		break_label.add_theme_color_override("font_color", Color("#e84c93"))
	boss_accent.visible = is_before_boss
	character_art.texture = _character_texture(String(context.get("playerCharacterId", "")))
	character_fallback.visible = character_art.texture == null
	progress_visual.set_context(previous_id, next_id, is_before_boss)
	var current_hp := int(context.get("currentHp", 0))
	var max_hp := int(context.get("maxHp", 0))
	var heal_amount := int(context.get("healAmount", 0))
	var after_hp := int(context.get("healPreviewHp", current_hp))
	heal_preview_label.text = "メンタル %d / %d → %d / %d" % [current_hp, max_hp, after_hp, max_hp]
	heal_full_label.text = "メンタルは満タンです" if current_hp >= max_hp else "メンタル +%d（最大メンタルの30%%）" % heal_amount

func _character_texture(character_id: String) -> Texture2D:
	return _load_texture(String(CHARACTER_TEXTURES.get(character_id, "")))

func update_input() -> void:
	if not visible or screen_state != BreakScreenState.SELECTING or input_locked:
		return
	var left_pressed := Input.is_action_just_pressed("ui_left") or (Input.is_key_pressed(KEY_A) and not left_down)
	var right_pressed := Input.is_action_just_pressed("ui_right") or (Input.is_key_pressed(KEY_D) and not right_down)
	var accept_pressed := Input.is_action_just_pressed("ui_accept") or ((Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_SPACE)) and not accept_down)
	if left_pressed:
		_set_choice(BreakChoice.HEAL)
	if right_pressed:
		_set_choice(BreakChoice.GIFT)
	left_down = Input.is_key_pressed(KEY_A)
	right_down = Input.is_key_pressed(KEY_D)
	accept_down = Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_SPACE)
	if accept_pressed:
		_confirm_choice()

func _on_card_hover(choice: int) -> void:
	if screen_state != BreakScreenState.SELECTING or input_locked:
		return
	_set_choice(choice)

func _on_card_pressed(choice: int) -> void:
	if screen_state != BreakScreenState.SELECTING or input_locked:
		return
	_set_choice(choice)
	_confirm_choice()

func _set_choice(choice: int) -> void:
	if choice == current_choice or screen_state != BreakScreenState.SELECTING or input_locked:
		return
	current_choice = choice
	_apply_choice_visuals()
	choice_changed.emit(current_choice)

func _apply_choice_visuals() -> void:
	if heal_card == null or gift_card == null:
		return
	if animation_tween != null:
		animation_tween.kill()
	animation_tween = create_tween()
	animation_tween.set_parallel(true)
	_apply_card_tween(heal_card, current_choice == BreakChoice.HEAL)
	_apply_card_tween(gift_card, current_choice == BreakChoice.GIFT)
	animation_tween.set_parallel(false)

func _apply_card_tween(card: TextureButton, selected: bool) -> void:
	var target_scale := Vector2(1.04, 1.04) if selected else Vector2.ONE
	var target_position := Vector2(card.position.x, 322.0) if selected else Vector2(card.position.x, 326.0)
	card.modulate = Color(1.0, 1.0, 1.0, 1.0 if selected else 0.92)
	animation_tween.tween_property(card, "scale", target_scale, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	animation_tween.tween_property(card, "position", target_position, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _confirm_choice() -> void:
	if screen_state != BreakScreenState.SELECTING or input_locked:
		return
	input_locked = true
	if current_choice == BreakChoice.HEAL:
		screen_state = BreakScreenState.RESOLVING_HEAL
		heal_selected.emit(context.duplicate(true))
	else:
		screen_state = BreakScreenState.OPENING_GIFT
		gift_selected.emit(context.duplicate(true))

func play_heal_resolution(preview: Dictionary) -> void:
	screen_state = BreakScreenState.RESOLVING_HEAL
	var before_hp := int(preview.get("currentHp", 0))
	var after_hp := int(preview.get("afterHp", before_hp))
	var max_hp := int(preview.get("maxHp", 0))
	heal_preview_label.text = "HP %d / %d → %d / %d" % [before_hp, max_hp, after_hp, max_hp]
	heal_full_label.text = "回復完了"
	if heal_preview_tween != null:
		heal_preview_tween.kill()
	heal_preview_tween = create_tween()
	heal_preview_tween.tween_property(heal_preview_label, "modulate", Color("#ffffff"), 0.12)
	heal_preview_tween.tween_property(heal_preview_label, "modulate", Color("#24566b"), 0.24)
	await get_tree().create_timer(0.72).timeout

func play_gift_transition() -> void:
	screen_state = BreakScreenState.OPENING_GIFT
	await get_tree().create_timer(0.18).timeout


class RelayBreakProgressVisual extends Control:
	var previous_id := "zatsudan"
	var next_id := "gameplay"
	var before_boss := false
	const LABELS := ["CHAT", "GAME", "SONG", "DRAW", "COLLAB", "BOSS"]

	func set_context(previous: String, next: String, boss_next: bool) -> void:
		previous_id = previous
		next_id = next
		before_boss = boss_next
		queue_redraw()

	func _draw() -> void:
		var outer := Rect2(Vector2.ZERO, size)
		draw_rect(outer.grow(3.0), Color(0.05, 0.02, 0.10, 0.26), true)
		draw_style_box(_box(Color("#fffaff"), Color("#ef9cc6"), 2, 14), outer)
		var font := GameFontSystemScript.black_font()
		var segment_width := (size.x - 28.0) / 6.0
		for i in range(LABELS.size()):
			var id: String = String(["zatsudan", "gameplay", "singing", "drawing", "collab", "boss"][i])
			var item := Rect2(10.0 + float(i) * segment_width, 7.0, segment_width - 10.0, size.y - 14.0)
			var is_previous: bool = id == previous_id
			var is_next: bool = id == next_id
			var is_boss_next: bool = before_boss and id == "boss"
			var fill := Color("#f4eaf3")
			var border := Color("#d8c7d6")
			if is_next and not is_boss_next:
				fill = Color("#d9f6fb")
				border = Color("#5ac9eb")
			elif is_boss_next:
				fill = Color("#fff0d9")
				border = Color("#e99a32")
			elif is_previous:
				fill = Color("#f4eaf3")
				border = Color("#d5bfd2")
			draw_style_box(_box(fill, border, 2 if (is_next or is_boss_next) else 1, 8), item)
			var prefix := "✓ " if is_previous else ("> " if is_next else "")
			var text_color := Color("#593451") if (is_previous or is_next or is_boss_next) else Color("#846b83")
			draw_string(font, item.position + Vector2(0.0, 23.0), prefix + LABELS[i], HORIZONTAL_ALIGNMENT_CENTER, item.size.x, 13, text_color)

	func _box(fill: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
		var box := StyleBoxFlat.new()
		box.bg_color = fill
		box.border_color = border
		box.set_border_width_all(width)
		box.set_corner_radius_all(radius)
		return box
