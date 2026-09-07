class_name TextureCacheSystem
extends RefCounted

static func load_resource_texture(cache: Dictionary, path: String) -> Texture2D:
	if path == "":
		return null
	if cache.has(path):
		return cache[path] as Texture2D
	var texture: Texture2D = ResourceLoader.load(path) as Texture2D
	cache[path] = texture
	return texture

static func load_png_texture(cache: Dictionary, path: String) -> Texture2D:
	if path == "":
		return null
	if cache.has(path):
		return cache[path] as Texture2D
	var resource_texture: Texture2D = ResourceLoader.load(path) as Texture2D if ResourceLoader.exists(path) else null
	if resource_texture != null:
		cache[path] = resource_texture
		return resource_texture
	var image := Image.new()
	if image.load(path) != OK:
		cache[path] = null
		return null
	var texture: Texture2D = ImageTexture.create_from_image(image)
	cache[path] = texture
	return texture

static func load_small_ui_texture(cache: Dictionary, path: String) -> Texture2D:
	if path == "":
		return null
	if cache.has(path):
		return cache[path] as Texture2D
	var source_texture: Texture2D = ResourceLoader.load(path) as Texture2D if ResourceLoader.exists(path) else null
	if source_texture == null:
		var image := Image.new()
		if image.load(path) != OK:
			cache[path] = null
			return null
		source_texture = ImageTexture.create_from_image(image)
	var canvas_texture := CanvasTexture.new()
	canvas_texture.diffuse_texture = source_texture
	canvas_texture.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	canvas_texture.texture_repeat = CanvasItem.TEXTURE_REPEAT_DISABLED
	cache[path] = canvas_texture
	return canvas_texture
