extends Node

const DrawData := preload("res://scripts/systems/draw_data_system.gd")

const CAPTURE_SIZE := Vector2i(1600, 900)
const CAPTURE_CENTER := Vector2(800, 450)
const OUTPUT_DIR := "res://artifacts/moderator_fortress_layout"

var visuals: Dictionary
var source_images: Dictionary = {}

func _ready() -> void:
	call_deferred("_capture_sequence")

func _capture_sequence() -> void:
	var weapons: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/weapons.json")) as Array
	for weapon_value in weapons:
		var weapon: Dictionary = weapon_value as Dictionary
		if String(weapon.get("id", "")) == "moderator_fortress":
			visuals = weapon.get("visuals", {}) as Dictionary
			break
	if visuals.is_empty():
		push_error("moderator_fortress visuals are missing")
		get_tree().quit(1)
		return

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	var directions: Array[Dictionary] = [
		{"name": "right", "direction": Vector2.RIGHT},
		{"name": "left", "direction": Vector2.LEFT},
		{"name": "up", "direction": Vector2.UP},
		{"name": "down", "direction": Vector2.DOWN}
	]
	for entry in directions:
		var direction: Vector2 = entry["direction"] as Vector2
		var image := Image.create(CAPTURE_SIZE.x, CAPTURE_SIZE.y, false, Image.FORMAT_RGBA8)
		image.fill(Color("#101828"))
		var items: Array = [{
			"kind": "moderator_fortress_active",
			"pos": CAPTURE_CENTER,
			"dir": direction,
			"progress": 0.4,
			"life": 0.4,
			"maxLife": 7.0,
			"arcDegrees": 220.0,
			"radius": 100.0,
			"visuals": visuals
		}]
		var draw_items: Array = DrawData.hit_fx_draw_data(items) as Array
		if not draw_items.is_empty():
			var data: Dictionary = draw_items[0] as Dictionary
			for layer_value in data.get("imageLayers", []) as Array:
				_composite_layer(image, layer_value as Dictionary)
		_draw_marker(image, direction)
		var path := "%s/%s.png" % [OUTPUT_DIR, String(entry["name"])]
		var error := image.save_png(path)
		if error != OK:
			push_error("Failed to save moderator fortress layout: %s (%s)" % [path, error_string(error)])
			get_tree().quit(1)
			return
		print("Saved moderator fortress layout: %s" % path)

	get_tree().quit(0)

func _composite_layer(destination: Image, layer: Dictionary) -> void:
	var path := String(layer.get("path", ""))
	var source := _source_image(path)
	if source == null or source.is_empty():
		return
	var size := Vector2(layer.get("size", Vector2.ONE))
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var pivot := Vector2(layer.get("pivotNormalized", Vector2(0.5, 0.5)))
	var anchor := Vector2(layer.get("pos", CAPTURE_CENTER))
	var rotation := float(layer.get("rotation", 0.0))
	var alpha_scale := clampf(float(layer.get("alpha", 1.0)), 0.0, 1.0)
	var flip_x := bool(layer.get("flipX", false))
	var extent_x := absf(cos(rotation)) * size.x + absf(sin(rotation)) * size.y
	var extent_y := absf(sin(rotation)) * size.x + absf(cos(rotation)) * size.y
	var minimum_x := maxi(0, floori(anchor.x - extent_x * 0.5 - 1.0))
	var maximum_x := mini(destination.get_width() - 1, ceili(anchor.x + extent_x * 0.5 + 1.0))
	var minimum_y := maxi(0, floori(anchor.y - extent_y * 0.5 - 1.0))
	var maximum_y := mini(destination.get_height() - 1, ceili(anchor.y + extent_y * 0.5 + 1.0))
	for y in range(minimum_y, maximum_y + 1):
		for x in range(minimum_x, maximum_x + 1):
			var local := Vector2(float(x) + 0.5 - anchor.x, float(y) + 0.5 - anchor.y).rotated(-rotation)
			if flip_x:
				local.x = -local.x
			var uv := Vector2(local.x / size.x + pivot.x, local.y / size.y + pivot.y)
			if uv.x < 0.0 or uv.x >= 1.0 or uv.y < 0.0 or uv.y >= 1.0:
				continue
			var source_x := clampi(floori(uv.x * source.get_width()), 0, source.get_width() - 1)
			var source_y := clampi(floori(uv.y * source.get_height()), 0, source.get_height() - 1)
			var source_color := source.get_pixel(source_x, source_y)
			var blend_alpha := clampf(source_color.a * alpha_scale, 0.0, 1.0)
			if blend_alpha <= 0.001:
				continue
			_blend_pixel(destination, x, y, source_color, blend_alpha)

func _source_image(path: String) -> Image:
	if path == "":
		return null
	if not source_images.has(path):
		var image := Image.load_from_file(ProjectSettings.globalize_path(path))
		source_images[path] = image
	return source_images.get(path) as Image

func _draw_marker(image: Image, direction: Vector2) -> void:
	_draw_circle(image, CAPTURE_CENTER, 13.0, Color("#f5f7ff"))
	_draw_circle(image, CAPTURE_CENTER, 9.0, Color("#263d66"))
	_draw_line(image, CAPTURE_CENTER, CAPTURE_CENTER + direction.normalized() * 34.0, 5.0, Color("#f5f7ff"))
	_draw_circle(image, CAPTURE_CENTER + direction.normalized() * 34.0, 4.0, Color("#f5f7ff"))

func _draw_circle(image: Image, center: Vector2, radius: float, color: Color) -> void:
	var minimum_x := maxi(0, floori(center.x - radius - 1.0))
	var maximum_x := mini(image.get_width() - 1, ceili(center.x + radius + 1.0))
	var minimum_y := maxi(0, floori(center.y - radius - 1.0))
	var maximum_y := mini(image.get_height() - 1, ceili(center.y + radius + 1.0))
	for y in range(minimum_y, maximum_y + 1):
		for x in range(minimum_x, maximum_x + 1):
			if Vector2(float(x) + 0.5, float(y) + 0.5).distance_squared_to(center) <= radius * radius:
				_blend_pixel(image, x, y, color, color.a)

func _draw_line(image: Image, from_pos: Vector2, to_pos: Vector2, width: float, color: Color) -> void:
	var minimum_x := maxi(0, floori(minf(from_pos.x, to_pos.x) - width - 1.0))
	var maximum_x := mini(image.get_width() - 1, ceili(maxf(from_pos.x, to_pos.x) + width + 1.0))
	var minimum_y := maxi(0, floori(minf(from_pos.y, to_pos.y) - width - 1.0))
	var maximum_y := mini(image.get_height() - 1, ceili(maxf(from_pos.y, to_pos.y) + width + 1.0))
	var segment := to_pos - from_pos
	var segment_length_squared := segment.length_squared()
	for y in range(minimum_y, maximum_y + 1):
		for x in range(minimum_x, maximum_x + 1):
			var point := Vector2(float(x) + 0.5, float(y) + 0.5)
			var ratio := clampf((point - from_pos).dot(segment) / maxf(0.001, segment_length_squared), 0.0, 1.0)
			if point.distance_squared_to(from_pos + segment * ratio) <= width * width * 0.25:
				_blend_pixel(image, x, y, color, color.a)

func _blend_pixel(image: Image, x: int, y: int, color: Color, alpha: float) -> void:
	var destination := image.get_pixel(x, y)
	var output_alpha := alpha + destination.a * (1.0 - alpha)
	if output_alpha <= 0.001:
		return
	image.set_pixel(x, y, Color(
		(color.r * alpha + destination.r * destination.a * (1.0 - alpha)) / output_alpha,
		(color.g * alpha + destination.g * destination.a * (1.0 - alpha)) / output_alpha,
		(color.b * alpha + destination.b * destination.a * (1.0 - alpha)) / output_alpha,
		output_alpha
	))
