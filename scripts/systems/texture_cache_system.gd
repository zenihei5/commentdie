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
	var resource_texture: Texture2D = ResourceLoader.load(path) as Texture2D
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
