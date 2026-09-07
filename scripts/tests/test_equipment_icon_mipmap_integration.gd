extends Node

const TextureCache := preload("res://scripts/systems/texture_cache_system.gd")
const GameScript := preload("res://scripts/game.gd")
const CodexScreenScene := preload("res://scenes/ui/codex_screen.tscn")
const ShopScreenScene := preload("res://scripts/ui/power_up_shop_screen.tscn")
const ShopCardScene := preload("res://scripts/ui/power_up_shop_card.tscn")
const Presentation := preload("res://scripts/systems/codex_presentation_system.gd")
const DrawData := preload("res://scripts/systems/draw_data_system.gd")

const CODEX_SAMPLE_PATH := "res://assets/generated/equipment_icons_v1/icons/ban_hammer.png"
const OLD_96_PATH := "res://assets/generated/equipment_icons_v1/icons/kusa_wave.png"
const KUSA_CODEX_PATH := "res://assets/generated/codex_icons_v1/kusa_wave_hd_final_1254.png"
const BAN_JUDGEMENT_OLD_96_PATH := "res://assets/generated/equipment_icons_v1/icons/ban_judgement.png"
const BAN_JUDGEMENT_CODEX_PATH := "res://assets/generated/codex_icons_v1/ban_judgement_hd_final_1254.png"
const STARLIGHT_SUPERCHAT_OLD_96_PATH := "res://assets/generated/equipment_icons_v1/icons/starlight_superchat.png"
const STARLIGHT_SUPERCHAT_CODEX_PATH := "res://assets/generated/codex_icons_v1/starlight_superchat_hd_final_1254.png"
const MARO_COMMENT_RING_OLD_96_PATH := "res://assets/generated/equipment_icons_v1/icons/maro_comment_ring.png"
const MARO_COMMENT_RING_CODEX_PATH := "res://assets/generated/codex_icons_v1/maro_comment_ring_hd_final_1024.png"
const LISTENER_SUMMON_OLD_PATH := "res://assets/generated/weapon_fx_v1/listener_summon.png"
const LISTENER_SUMMON_HD_PATH := "res://assets/generated/weapon_fx_v1/listener_summon_hd_final_1254.png"
const EMOTE_MINE_OLD_FIELD_PATH := "res://assets/generated/weapon_fx_v1/emote_mine.png"
const EMOTE_MINE_HD_PATH := "res://assets/generated/equipment_icons_v1/icons/emote_mine.png"
const STREAM_POWER_OLD_96_PATH := "res://assets/generated/equipment_icons_v1/icons/stream_power.png"
const STREAM_POWER_HD_PATH := "res://assets/generated/equipment_icons_v1/icons/stream_power_hd_final_1254.png"
const MENTAL_CARE_OLD_96_PATH := "res://assets/generated/equipment_icons_v1/icons/mental_care.png"
const MENTAL_CARE_HD_PATH := "res://assets/generated/equipment_icons_v1/icons/mental_care_hd_final_1254.png"
const MINI_HUMIDIFIER_OLD_96_PATH := "res://assets/generated/equipment_icons_v1/icons/mini_humidifier.png"
const MINI_HUMIDIFIER_HD_PATH := "res://assets/generated/equipment_icons_v1/icons/mini_humidifier_hd_final_1254.png"
const NOTIFICATION_BELL_OLD_96_PATH := "res://assets/generated/equipment_icons_v1/icons/notification_bell.png"
const NOTIFICATION_BELL_HD_PATH := "res://assets/generated/equipment_icons_v1/icons/notification_bell_hd_final_1254.png"
const HD_MIN_EDGE := 512

var failures: Array[String] = []

func _ready() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	CodexManager.initialize_empty()
	_check_active_equipment_inventory()
	_check_codex_override_routing()
	_check_listener_summon_cross_surface_routing()
	_check_emote_mine_cross_surface_routing()
	_check_stream_power_shared_hd_routing()
	_check_mental_care_shared_hd_routing()
	_check_mini_humidifier_shared_hd_routing()
	_check_notification_bell_shared_hd_routing()
	await _check_codex_sampling()
	await _check_codex_equipment_insets()

	if failures.is_empty():
		print("EQUIPMENT_ICON_MIPMAP_INTEGRATION_TESTS: PASS")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("EQUIPMENT_ICON_MIPMAP_INTEGRATION_TESTS: FAIL (%d)" % failures.size())
	get_tree().quit(1)

func _check_active_equipment_inventory() -> void:
	var icon_count := 0
	var hd_count := 0
	var legacy_96_count := 0
	for category in [CodexManager.CATEGORY_WEAPON, CodexManager.CATEGORY_ACCESSORY]:
		for item_value in CodexManager.get_master_entries(category):
			if not item_value is Dictionary:
				continue
			var item := item_value as Dictionary
			var path := Presentation.image_path_for(category, item, true)
			if path == "":
				continue
			var texture := load(path) as Texture2D
			_check(texture != null, "%s active icon loads as Texture2D" % path)
			if texture == null:
				continue
			icon_count += 1
			var min_edge := mini(texture.get_width(), texture.get_height())
			var expects_mipmaps := min_edge >= HD_MIN_EDGE
			if expects_mipmaps:
				hd_count += 1
			elif min_edge == 96:
				legacy_96_count += 1
			_check_source_mipmaps(path, expects_mipmaps)
			_check_small_ui_wrapper(path)
	_check(icon_count == 36, "active equipment icon inventory remains 36")
	_check(hd_count == 32, "all 32 active 512px-or-larger HD icon sources are audited")
	_check(legacy_96_count == 4, "all 4 compact-authored 96px sources remain LOD0 assets")

func _check_source_mipmaps(path: String, expected: bool) -> void:
	var texture := load(path) as Texture2D
	_check(texture != null, "%s loads as Texture2D" % path)
	if texture == null:
		return
	var image := texture.get_image()
	_check(image != null, "%s exposes its imported image" % path)
	if image != null:
		_check(image.has_mipmaps() == expected, "%s mipmap state is %s" % [path, expected])

func _check_small_ui_wrapper(path: String) -> void:
	var cache: Dictionary = {}
	var texture := TextureCache.load_small_ui_texture(cache, path)
	_check(texture is CanvasTexture, "%s uses an equipment-only CanvasTexture" % path)
	if not texture is CanvasTexture:
		return
	var canvas_texture := texture as CanvasTexture
	_check(canvas_texture.diffuse_texture != null, "%s wrapper retains its source" % path)
	_check(canvas_texture.diffuse_texture != null and String(canvas_texture.diffuse_texture.resource_path) == path, "%s wrapper points at the requested source" % path)
	_check(canvas_texture.texture_filter == CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS, "%s small UI sampling is Linear with mipmaps" % path)
	_check(canvas_texture.texture_repeat == CanvasItem.TEXTURE_REPEAT_DISABLED, "%s does not repeat at icon edges" % path)
	_check(TextureCache.load_small_ui_texture(cache, path) == texture, "%s remains stable in the equipment cache" % path)

func _check_codex_override_routing() -> void:
	var weapons: Array = CodexManager.get_master_entries(CodexManager.CATEGORY_WEAPON)
	var expected_overrides := {
		"kusa_wave": {
			"small": OLD_96_PATH,
			"codex": KUSA_CODEX_PATH
		},
		"ban_judgement": {
			"small": BAN_JUDGEMENT_OLD_96_PATH,
			"codex": BAN_JUDGEMENT_CODEX_PATH
		},
		"starlight_superchat": {
			"small": STARLIGHT_SUPERCHAT_OLD_96_PATH,
			"codex": STARLIGHT_SUPERCHAT_CODEX_PATH
		},
		"maro_comment_ring": {
			"small": MARO_COMMENT_RING_OLD_96_PATH,
			"codex": MARO_COMMENT_RING_CODEX_PATH
		}
	}
	for id_value in expected_overrides:
		var id := String(id_value)
		var item := _find(weapons, id)
		var paths := expected_overrides[id] as Dictionary
		_check(Presentation.image_path_for(CodexManager.CATEGORY_WEAPON, item, true) == String(paths["small"]), "%s compact routing keeps the old 96px icon" % id)
		_check(Presentation.codex_image_path_for(CodexManager.CATEGORY_WEAPON, item, true) == String(paths["codex"]), "%s Codex routing uses the data-defined HD override" % id)
		var codex_texture := load(String(paths["codex"])) as Texture2D
		_check(codex_texture != null, "%s Codex-only HD texture loads" % id)
		if codex_texture != null:
			_check(mini(codex_texture.get_width(), codex_texture.get_height()) >= HD_MIN_EDGE, "%s Codex override remains HD" % id)
			_check(not codex_texture.get_image().has_mipmaps(), "%s Codex-only HD texture remains ordinary LINEAR source data" % id)
	for item_value in weapons:
		if not item_value is Dictionary:
			continue
		var item := item_value as Dictionary
		if expected_overrides.has(String(item.get("id", ""))):
			continue
		_check(Presentation.codex_image_path_for(CodexManager.CATEGORY_WEAPON, item, true) == Presentation.image_path_for(CodexManager.CATEGORY_WEAPON, item, true), "non-overridden weapon %s keeps normal fallback" % String(item.get("id", "")))

func _check_listener_summon_cross_surface_routing() -> void:
	var weapon := _find(CodexManager.get_master_entries(CodexManager.CATEGORY_WEAPON), "listener_summon")
	_check(Presentation.image_path_for(CodexManager.CATEGORY_WEAPON, weapon, true) == LISTENER_SUMMON_HD_PATH, "listener summon compact equipment UI uses the dedicated HD source")
	_check(Presentation.codex_image_path_for(CodexManager.CATEGORY_WEAPON, weapon, true) == LISTENER_SUMMON_HD_PATH, "listener summon Codex uses the shared HD master")
	var field_data := DrawData.listener_summon_fx_data(Vector2.ZERO, Vector2.RIGHT, 1.0, 1.0)
	_check(String(field_data.get("imagePath", "")) == LISTENER_SUMMON_HD_PATH, "listener summon field visual uses the dedicated HD source")
	_check(bool(field_data.get("imageUseMipmaps", false)), "listener summon field visual requests mipmapped sampling")
	var game := GameScript.new()
	var field_texture := game.call("_load_hit_fx_texture_for_data", field_data) as Texture2D
	_check(field_texture is CanvasTexture, "listener summon field renderer uses a mipmapped CanvasTexture")
	if field_texture is CanvasTexture:
		var field_canvas_texture := field_texture as CanvasTexture
		_check(field_canvas_texture.texture_filter == CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS, "listener summon field renderer applies mipmapped linear sampling")
		_check(field_canvas_texture.texture_repeat == CanvasItem.TEXTURE_REPEAT_DISABLED, "listener summon field renderer disables texture repeat")
	game.free()
	var evolved_data := DrawData.listener_assembly_visual_fx_data(Vector2.ZERO, Vector2.RIGHT, 1.0, 1.0, 1.0, {})
	_check(String(evolved_data.get("imagePath", "")) == "", "listener assembly keeps its independent formal visual path")
	_check(FileAccess.file_exists(LISTENER_SUMMON_OLD_PATH), "legacy listener summon pixel source remains available for rollback")
	var shop := ShopScreenScene.instantiate()
	add_child(shop)
	_check(shop.mascot.texture != null and String(shop.mascot.texture.resource_path) == LISTENER_SUMMON_HD_PATH, "power-up shop mascot uses the dedicated listener summon HD source")
	_check(shop.mascot.texture_filter == CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS, "power-up shop mascot uses mipmapped linear sampling")
	_check(shop.mascot.texture_repeat == CanvasItem.TEXTURE_REPEAT_DISABLED, "power-up shop mascot texture repeat is disabled")
	shop.queue_free()

func _check_emote_mine_cross_surface_routing() -> void:
	var weapons: Array = CodexManager.get_master_entries(CodexManager.CATEGORY_WEAPON)
	var weapon := _find(weapons, "emote_mine")
	_check(Presentation.image_path_for(CodexManager.CATEGORY_WEAPON, weapon, true) == EMOTE_MINE_HD_PATH, "emote mine compact UI keeps its existing HD icon")
	_check(Presentation.codex_image_path_for(CodexManager.CATEGORY_WEAPON, weapon, true) == EMOTE_MINE_HD_PATH, "emote mine Codex keeps the same shared source")
	var hd_texture := load(EMOTE_MINE_HD_PATH) as Texture2D
	_check(hd_texture != null and hd_texture.get_size() == Vector2(512, 512), "emote mine retains the unmodified 512px HD source")
	_check_source_mipmaps(EMOTE_MINE_HD_PATH, true)
	_check(FileAccess.file_exists(EMOTE_MINE_OLD_FIELD_PATH), "legacy emote mine field PNG remains available for rollback")
	_check_source_mipmaps(EMOTE_MINE_OLD_FIELD_PATH, false)
	var pos := Vector2(200, 250)
	var field_data := DrawData.emote_mine_fx_data(pos, 4.0, 8.0, 70.0)
	_check(String(field_data.get("imagePath", "")) == EMOTE_MINE_HD_PATH, "emote mine field uses the shared HD icon")
	_check(bool(field_data.get("imageUseMipmaps", false)), "emote mine field requests mipmapped sampling")
	_check(Vector2(field_data.get("imagePos", Vector2.ZERO)) == pos + Vector2(0, -2), "emote mine keeps its existing field image anchor")
	_check(Vector2(field_data.get("shadowPos", Vector2.ZERO)) == pos + Vector2(0, 5) and Vector2(field_data.get("shadowSize", Vector2.ZERO)) == Vector2(44, 13), "emote mine keeps its existing shadow")
	_check(is_equal_approx(float(field_data.get("imageAlpha", 0.0)), 0.5), "emote mine lifetime fade is unchanged")
	_check(Vector2(field_data.get("rangePos", Vector2.ZERO)) == pos and is_equal_approx(float(field_data.get("rangeRadius", 0.0)), 70.0), "emote mine range indicator is independent of image scale")
	var low_pulse := DrawData.emote_mine_fx_data(pos, 3.0 * PI / 16.0, 8.0, 70.0)
	var high_pulse := DrawData.emote_mine_fx_data(pos, PI / 16.0, 8.0, 70.0)
	_check(Vector2(low_pulse.get("imageSize", Vector2.ZERO)).is_equal_approx(Vector2(76.8, 76.8)), "emote mine pulse minimum compensates transparent margins")
	_check(Vector2(high_pulse.get("imageSize", Vector2.ZERO)).is_equal_approx(Vector2(81.92, 81.92)), "emote mine pulse maximum preserves the original relative pulse")
	var expired := DrawData.emote_mine_fx_data(pos, 0.0, 8.0, 70.0)
	_check(is_zero_approx(float(expired.get("imageAlpha", 1.0))), "expired emote mine remains invisible")
	var game := GameScript.new()
	var field_texture := game.call("_load_hit_fx_texture_for_data", field_data) as Texture2D
	_check(field_texture is CanvasTexture, "emote mine field uses a scoped CanvasTexture")
	if field_texture is CanvasTexture:
		var canvas := field_texture as CanvasTexture
		_check(canvas.texture_filter == CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS, "emote mine field uses Linear with mipmaps")
		_check(canvas.texture_repeat == CanvasItem.TEXTURE_REPEAT_DISABLED, "emote mine field disables texture repeat")
		_check(canvas.diffuse_texture == hd_texture, "emote mine field reuses the imported HD texture")
	_check(game.call("_load_equipment_icon", EMOTE_MINE_HD_PATH) == field_texture, "field and equipment share the cached emote mine wrapper")
	var evolved := _find(weapons, "emote_festival")
	var visuals: Dictionary = evolved.get("visuals", {}) as Dictionary
	var evolved_data := DrawData.emote_festival_mine_visual_fx_data(pos, 12.0, 12.0, 160.0, visuals)
	_check(String(evolved_data.get("imagePath", "")) == "" and game.call("_load_hit_fx_texture_for_data", evolved_data) == null, "emote festival does not draw the normal mine HD source")
	var layers: Array = evolved_data.get("imageLayers", []) as Array
	_check(layers.size() == 1, "emote festival keeps its independent formal mine layer")
	if layers.size() == 1:
		_check(String((layers[0] as Dictionary).get("path", "")) == String((visuals.get("mine", {}) as Dictionary).get("path", "")), "emote festival retains its data-defined field asset")
	game.free()

func _check_stream_power_shared_hd_routing() -> void:
	var accessory := _find(CodexManager.get_master_entries(CodexManager.CATEGORY_ACCESSORY), "stream_power")
	_check(Presentation.image_path_for(CodexManager.CATEGORY_ACCESSORY, accessory, true) == STREAM_POWER_HD_PATH, "stream power compact equipment UI uses the dedicated HD source")
	_check(Presentation.codex_image_path_for(CodexManager.CATEGORY_ACCESSORY, accessory, true) == STREAM_POWER_HD_PATH, "stream power Codex uses the shared HD master")
	var hd_texture := load(STREAM_POWER_HD_PATH) as Texture2D
	_check(hd_texture != null and hd_texture.get_size() == Vector2(1254, 1254), "stream power shared source remains the audited 1254px master")
	if hd_texture != null:
		_check(hd_texture.get_image().has_mipmaps(), "stream power shared HD source contains mip levels")
	_check(FileAccess.file_exists(STREAM_POWER_OLD_96_PATH), "legacy stream power 96px source remains available for rollback")
	var shop_data := JSON.parse_string(FileAccess.get_file_as_string("res://data/power_up_shop.json")) as Dictionary
	var upgrades: Array = shop_data.get("upgrades", []) as Array
	var attack_power := _find(upgrades, "attack_power")
	_check(String(attack_power.get("iconPath", "")) == STREAM_POWER_HD_PATH, "power-up shop attack upgrade uses the shared stream power HD master")
	var shop := ShopScreenScene.instantiate()
	add_child(shop)
	_check(shop.detail_icon.texture_filter == CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS, "power-up shop detail equipment icon uses mipmapped linear sampling")
	_check(shop.detail_icon.texture_repeat == CanvasItem.TEXTURE_REPEAT_DISABLED, "power-up shop detail equipment icon disables repeat")
	shop.queue_free()
	var card := ShopCardScene.instantiate()
	add_child(card)
	_check(card.card_icon.texture_filter == CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS, "power-up shop compact equipment card uses mipmapped linear sampling")
	_check(card.card_icon.texture_repeat == CanvasItem.TEXTURE_REPEAT_DISABLED, "power-up shop compact equipment card disables repeat")
	card.queue_free()

func _check_mental_care_shared_hd_routing() -> void:
	var accessory := _find(CodexManager.get_master_entries(CodexManager.CATEGORY_ACCESSORY), "mental_care")
	_check(Presentation.image_path_for(CodexManager.CATEGORY_ACCESSORY, accessory, true) == MENTAL_CARE_HD_PATH, "mental care compact equipment UI uses the dedicated HD source")
	_check(Presentation.codex_image_path_for(CodexManager.CATEGORY_ACCESSORY, accessory, true) == MENTAL_CARE_HD_PATH, "mental care Codex uses the shared HD master")
	_check(FileAccess.file_exists(MENTAL_CARE_OLD_96_PATH), "legacy mental care 96px source remains available for rollback")
	var shop_data := JSON.parse_string(FileAccess.get_file_as_string("res://data/power_up_shop.json")) as Dictionary
	var max_hp := _find(shop_data.get("upgrades", []) as Array, "max_hp")
	_check(String(max_hp.get("iconPath", "")) == MENTAL_CARE_HD_PATH, "shop max HP upgrade uses the same mental care HD master")

func _check_mini_humidifier_shared_hd_routing() -> void:
	var accessory := _find(CodexManager.get_master_entries(CodexManager.CATEGORY_ACCESSORY), "mini_humidifier")
	_check(Presentation.image_path_for(CodexManager.CATEGORY_ACCESSORY, accessory, true) == MINI_HUMIDIFIER_HD_PATH, "mini humidifier compact equipment UI uses the dedicated HD source")
	_check(Presentation.codex_image_path_for(CodexManager.CATEGORY_ACCESSORY, accessory, true) == MINI_HUMIDIFIER_HD_PATH, "mini humidifier Codex uses the same HD master")
	var hd_texture := load(MINI_HUMIDIFIER_HD_PATH) as Texture2D
	_check(hd_texture != null and hd_texture.get_size() == Vector2(1254, 1254), "mini humidifier HD source remains the audited 1254px master")
	if hd_texture != null:
		_check(hd_texture.get_image().has_mipmaps(), "mini humidifier HD source contains mip levels")
	var old_texture := load(MINI_HUMIDIFIER_OLD_96_PATH) as Texture2D
	_check(old_texture != null and old_texture.get_size() == Vector2(96, 96), "legacy mini humidifier 96px source remains available for rollback")
	_check_source_mipmaps(MINI_HUMIDIFIER_OLD_96_PATH, false)
	_check(int(accessory.get("maxLevel", 0)) == 3, "mini humidifier maximum level is unchanged")

func _check_notification_bell_shared_hd_routing() -> void:
	var accessory := _find(CodexManager.get_master_entries(CodexManager.CATEGORY_ACCESSORY), "notification_bell")
	_check(Presentation.image_path_for(CodexManager.CATEGORY_ACCESSORY, accessory, true) == NOTIFICATION_BELL_HD_PATH, "notification bell compact equipment UI uses the corrected HD source")
	_check(Presentation.codex_image_path_for(CodexManager.CATEGORY_ACCESSORY, accessory, true) == NOTIFICATION_BELL_HD_PATH, "notification bell Codex uses the same HD master")
	var hd_texture := load(NOTIFICATION_BELL_HD_PATH) as Texture2D
	_check(hd_texture != null and hd_texture.get_size() == Vector2(1254, 1254), "notification bell source remains the audited 1254px master")
	if hd_texture != null:
		_check(hd_texture.get_image().has_mipmaps(), "notification bell HD source contains mip levels")
		_check(hd_texture.get_image().get_pixel(618, 210).a == 0.0, "notification bell top-loop transparency correction is retained")
	var old_texture := load(NOTIFICATION_BELL_OLD_96_PATH) as Texture2D
	_check(old_texture != null and old_texture.get_size() == Vector2(96, 96), "legacy notification bell 96px source remains available for rollback")
	_check_source_mipmaps(NOTIFICATION_BELL_OLD_96_PATH, false)
	var shop_data := JSON.parse_string(FileAccess.get_file_as_string("res://data/power_up_shop.json")) as Dictionary
	var exp_gain := _find(shop_data.get("upgrades", []) as Array, "exp_gain")
	_check(String(exp_gain.get("iconPath", "")) == NOTIFICATION_BELL_HD_PATH, "shop exp gain upgrade uses the same corrected notification bell HD master")

func _check_codex_sampling() -> void:
	var screen: Node = CodexScreenScene.instantiate()
	var holder := Control.new()
	holder.size = Vector2(282, 282)
	add_child(holder)
	screen.call("_set_image_in_holder", holder, CODEX_SAMPLE_PATH, CodexManager.CATEGORY_WEAPON)
	await get_tree().process_frame
	var child: Node = holder.get_child(0) if holder.get_child_count() > 0 else null
	_check(child is TextureRect, "Codex equipment renderer creates a TextureRect")
	if child is TextureRect:
		var rect := child as TextureRect
		_check(rect.texture_filter == CanvasItem.TEXTURE_FILTER_LINEAR, "Codex equipment renderer explicitly uses ordinary Linear sampling")
		_check(not rect.texture is CanvasTexture, "Codex detail receives the direct source rather than the small-UI wrapper")
		_check(rect.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "Codex keeps centered aspect-fit")
		_check(rect.clip_contents, "Codex keeps clipping")
	holder.queue_free()
	screen.free()
	await get_tree().process_frame
	await get_tree().process_frame

func _check_codex_equipment_insets() -> void:
	var screen: Node = CodexScreenScene.instantiate()
	for category in [CodexManager.CATEGORY_WEAPON, CodexManager.CATEGORY_ACCESSORY]:
		var inset := 12.0 if category == CodexManager.CATEGORY_WEAPON else 6.0
		for height in [235.0, 256.0, 282.0, 308.0]:
			var holder := Control.new()
			holder.size = Vector2(432.0, height)
			add_child(holder)
			screen.call("_set_image_in_holder", holder, CODEX_SAMPLE_PATH, category, inset)
			await get_tree().process_frame
			var rect := holder.get_child(0) as TextureRect
			_check(rect != null, "equipment inset probe creates a TextureRect")
			if rect != null:
				_check(rect.position.is_equal_approx(Vector2(inset, inset)), "%s %.0fpx image starts at its inset" % [category, height])
				_check(rect.size.is_equal_approx(holder.size - Vector2.ONE * inset * 2.0), "%s %.0fpx image keeps both insets inside its holder" % [category, height])
				_check(holder.get_global_rect().encloses(rect.get_global_rect()), "%s %.0fpx image does not overflow its holder" % [category, height])
			holder.free()
		var pending_holder := Control.new()
		add_child(pending_holder)
		screen.call("_set_image_in_holder", pending_holder, CODEX_SAMPLE_PATH, category, inset)
		pending_holder.size = Vector2(432.0, 256.0)
		await get_tree().process_frame
		var pending_rect := pending_holder.get_child(0) as TextureRect
		_check(pending_rect.position.is_equal_approx(Vector2(inset, inset)), "%s initially zero-size holder keeps inset position" % category)
		_check(pending_rect.size.is_equal_approx(Vector2(432.0, 256.0) - Vector2.ONE * inset * 2.0), "%s initially zero-size holder keeps both insets after layout" % category)
		pending_holder.free()
	var non_equipment_holder := Control.new()
	non_equipment_holder.size = Vector2(282.0, 282.0)
	add_child(non_equipment_holder)
	screen.call("_set_image_in_holder", non_equipment_holder, CODEX_SAMPLE_PATH, CodexManager.CATEGORY_ENEMY)
	var non_equipment_rect := non_equipment_holder.get_child(0) as TextureRect
	_check(non_equipment_rect.clip_contents, "non-equipment keeps its existing clipping behavior")
	_check(non_equipment_rect.texture_filter == CanvasItem.TEXTURE_FILTER_PARENT_NODE, "equipment sampler changes do not leak to non-equipment")
	non_equipment_holder.free()
	screen.free()
	await get_tree().process_frame

func _find(items: Array, id: String) -> Dictionary:
	for item_value in items:
		if item_value is Dictionary and String((item_value as Dictionary).get("id", "")) == id:
			return item_value as Dictionary
	return {}

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
