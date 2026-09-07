extends Node

const CodexScreenScene := preload("res://scenes/ui/codex_screen.tscn")
const Presentation := preload("res://scripts/systems/codex_presentation_system.gd")
const KUSA_SMALL_ICON_PATH := "res://assets/generated/equipment_icons_v1/icons/kusa_wave.png"
const KUSA_CODEX_ICON_PATH := "res://assets/generated/codex_icons_v1/kusa_wave_hd_final_1254.png"

var failures: Array[String] = []

func _ready() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	CodexManager.initialize_empty()
	var weapons: Array = CodexManager.get_master_entries(CodexManager.CATEGORY_WEAPON)
	var characters: Array = CodexManager.get_master_entries(CodexManager.CATEGORY_CHARACTER)
	var kusa := _find(weapons, "kusa_wave")
	var model := Presentation.item_lore_model(kusa, CodexManager.CATEGORY_WEAPON, true, weapons, characters)
	_check(Presentation.image_path_for(CodexManager.CATEGORY_WEAPON, kusa, true) == KUSA_SMALL_ICON_PATH, "compact resolver keeps the old kusa_wave icon")
	_check(String(model.get("imagePath", "")) == KUSA_CODEX_ICON_PATH, "Codex model resolves the kusa_wave HD override")
	var hd_texture := load(KUSA_CODEX_ICON_PATH) as Texture2D
	var hd_image: Image = hd_texture.get_image() if hd_texture != null else null
	_check(hd_image != null and hd_image.get_size() == Vector2i(1254, 1254) and hd_image.get_format() == Image.FORMAT_RGBA8, "Codex asset is a 1254x1254 RGBA PNG")
	if hd_image != null:
		var alpha_bbox := _alpha_bbox(hd_image, 8)
		var alpha_margins := Vector4i(alpha_bbox.position.x, alpha_bbox.position.y, hd_image.get_width() - alpha_bbox.end.x, hd_image.get_height() - alpha_bbox.end.y)
		_check(alpha_bbox.has_area() and alpha_margins.x >= 63 and alpha_margins.y >= 63 and alpha_margins.z >= 63 and alpha_margins.w >= 63, "Codex asset keeps true transparency and alpha>=8 margins of at least 63px")

	CodexManager.discover_weapon("kusa_wave")
	var screen: Node = CodexScreenScene.instantiate()
	add_child(screen)
	screen.call("open_screen", "title", {}, {"category": CodexManager.CATEGORY_WEAPON})
	screen.call("_select_entry_by_id", "kusa_wave")
	await get_tree().process_frame
	await get_tree().process_frame
	var holder := screen.get("_item_visual_holder") as Control
	_check(holder != null and holder.clip_contents, "Codex detail keeps its clipped visual holder")
	var visual_child: Node = holder.get_child(0) if holder != null and holder.get_child_count() > 0 else null
	_check(visual_child is TextureRect, "Codex detail creates the production TextureRect")
	if visual_child is TextureRect:
		_check_hd_rect(visual_child as TextureRect, "Codex detail")

	var probe_holder := Control.new()
	probe_holder.size = Vector2(256, 256)
	probe_holder.clip_contents = true
	add_child(probe_holder)
	screen.call("_set_image_in_holder", probe_holder, String(model.get("imagePath", "")), CodexManager.CATEGORY_WEAPON, 0.0, model.get("codexVisual", {}) as Dictionary)
	await get_tree().process_frame
	var probe_child: Node = probe_holder.get_child(0) if probe_holder.get_child_count() > 0 else null
	_check(probe_holder.size == Vector2(256, 256) and probe_child is TextureRect, "256px Codex renderer probe creates an image")
	if probe_child is TextureRect:
		var probe_rect := probe_child as TextureRect
		_check(probe_rect.size == Vector2(256, 256), "256px Codex renderer keeps the requested actual rect")
		_check_hd_rect(probe_rect, "256px Codex renderer")

	probe_holder.queue_free()
	screen.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	if failures.is_empty():
		print("KUSA_WAVE_CODEX_HIRES_OVERRIDE_TESTS: PASS")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("KUSA_WAVE_CODEX_HIRES_OVERRIDE_TESTS: FAIL (%d)" % failures.size())
	get_tree().quit(1)

func _check_hd_rect(rect: TextureRect, context: String) -> void:
	_check(rect.texture != null, "%s loads a texture" % context)
	if rect.texture == null:
		return
	_check(String(rect.texture.resource_path) == KUSA_CODEX_ICON_PATH, "%s uses the Codex-only path" % context)
	_check(rect.texture.get_size() == Vector2(1254, 1254), "%s receives the 1254px source" % context)
	_check(rect.expand_mode == TextureRect.EXPAND_IGNORE_SIZE and rect.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "%s keeps centered aspect-fit rendering" % context)
	_check(rect.clip_contents, "%s keeps image clipping" % context)
	_check(rect.texture_filter == CanvasItem.TEXTURE_FILTER_LINEAR, "%s explicitly uses ordinary Linear sampling" % context)

func _find(items: Array, id: String) -> Dictionary:
	for item_value in items:
		if item_value is Dictionary and String((item_value as Dictionary).get("id", "")) == id:
			return item_value as Dictionary
	return {}

func _alpha_bbox(image: Image, threshold_byte: int) -> Rect2i:
	var min_x := image.get_width()
	var min_y := image.get_height()
	var max_x := -1
	var max_y := -1
	var threshold := float(threshold_byte) / 255.0
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).a < threshold:
				continue
			min_x = mini(min_x, x)
			min_y = mini(min_y, y)
			max_x = maxi(max_x, x)
			max_y = maxi(max_y, y)
	if max_x < min_x or max_y < min_y:
		return Rect2i()
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
