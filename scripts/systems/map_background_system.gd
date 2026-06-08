class_name MapBackgroundSystem
extends RefCounted

const ZATSUDAN_STUDIO_DIR := "res://assets/generated/maps/zatsudan_studio_layered_v1"
const ZATSUDAN_STUDIO_BG := ZATSUDAN_STUDIO_DIR + "/zatsudan_studio_floor_with_desk_props_assembled_2200x1500.png"
const ZATSUDAN_STUDIO_FLOOR := ZATSUDAN_STUDIO_DIR + "/zatsudan_studio_floor_only_chatgpt_2200x1500.png"
const ZATSUDAN_STUDIO_PROPS := ZATSUDAN_STUDIO_DIR + "/zatsudan_studio_desk_props_2200x1500.png"
const ZATSUDAN_STUDIO_COLLISION_PREVIEW := ZATSUDAN_STUDIO_DIR + "/zatsudan_studio_floor_with_desk_props_collision_preview_2200x1500.png"

const ZATSUDAN_STUDIO_SIZE := Vector2(2200, 1500)
const ZATSUDAN_STUDIO_WORLD_RECT := Rect2(Vector2(20, 120), ZATSUDAN_STUDIO_SIZE)
const ZATSUDAN_STUDIO_COLLISION_RECTS := [
	{"id": "bench_left_top", "rect": Rect2(619, 413, 351, 55)},
	{"id": "bench_right_mid", "rect": Rect2(1388, 717, 312, 44)},
	{"id": "bench_bottom_left", "rect": Rect2(742, 1075, 349, 50)},
	{"id": "streaming_desk_bottom", "rect": Rect2(860, 1402, 500, 72)},
	{"id": "camera_left_edge", "rect": Rect2(122, 296, 92, 54)},
	{"id": "camera_right_edge", "rect": Rect2(103, 690, 98, 56)},
	{"id": "hanging_plant_left", "rect": Rect2(384, 194, 99, 50)},
	{"id": "hanging_plant_right", "rect": Rect2(1784, 192, 103, 57)},
	{"id": "speaker_top", "rect": Rect2(953, 109, 75, 78)},
	{"id": "ring_light_left", "rect": Rect2(72, 1022, 114, 56)},
	{"id": "boom_mic_left_bottom", "rect": Rect2(218, 1230, 76, 46)},
	{"id": "gift_box_right", "rect": Rect2(1871, 1062, 82, 70)},
	{"id": "potted_plant_left_bottom", "rect": Rect2(110, 1350, 84, 42)},
	{"id": "led_bar_bottom", "rect": Rect2(1532, 1434, 317, 41)},
	{"id": "speaker_top_copy", "rect": Rect2(1533, 119, 75, 78)},
	{"id": "led_bar_bottom_copy", "rect": Rect2(437, 1416, 317, 41)}
]
const ZATSUDAN_STUDIO_PROP_COLLISION_RECTS := [
]

static func zatsudan_background_data() -> Dictionary:
	return {
		"id": "zatsudan_studio_layered_v1",
		"size": ZATSUDAN_STUDIO_SIZE,
		"worldRect": ZATSUDAN_STUDIO_WORLD_RECT,
		"assembledPath": ZATSUDAN_STUDIO_BG,
		"floorPath": ZATSUDAN_STUDIO_FLOOR,
		"propsPath": ZATSUDAN_STUDIO_PROPS,
		"collisionPreviewPath": ZATSUDAN_STUDIO_COLLISION_PREVIEW,
		"collisionRects": ZATSUDAN_STUDIO_COLLISION_RECTS,
		"propCollisionRects": ZATSUDAN_STUDIO_PROP_COLLISION_RECTS
	}

static func background_data_for_stream_frame(frame_id: String) -> Dictionary:
	match frame_id:
		"zatsudan":
			return zatsudan_background_data()
		"gameplay":
			return zatsudan_background_data()
		_:
			return zatsudan_background_data()

static func background_path(data: Dictionary) -> String:
	if data.has("assembledPath"):
		return String(data["assembledPath"])
	return ""

static func floor_path(data: Dictionary) -> String:
	if data.has("floorPath"):
		return String(data["floorPath"])
	return ""

static func props_path(data: Dictionary) -> String:
	if data.has("propsPath"):
		return String(data["propsPath"])
	return ""

static func world_rect(data: Dictionary) -> Rect2:
	if data.has("worldRect"):
		return data["worldRect"] as Rect2
	return ZATSUDAN_STUDIO_WORLD_RECT

static func zatsudan_background_path() -> String:
	return String(zatsudan_background_data()["assembledPath"])

static func zatsudan_floor_path() -> String:
	return String(zatsudan_background_data()["floorPath"])

static func zatsudan_props_path() -> String:
	return String(zatsudan_background_data()["propsPath"])

static func zatsudan_background_size() -> Vector2:
	return zatsudan_background_data()["size"] as Vector2

static func zatsudan_world_rect() -> Rect2:
	return zatsudan_background_data()["worldRect"] as Rect2

static func zatsudan_collision_rects() -> Array:
	return (zatsudan_background_data()["collisionRects"] as Array).duplicate(true)

static func zatsudan_prop_collision_rects() -> Array:
	return (zatsudan_background_data()["propCollisionRects"] as Array).duplicate(true)

static func zatsudan_static_wall_rects() -> Array:
	return static_wall_rects_for_data(zatsudan_background_data())

static func static_wall_rects_for_data(data: Dictionary) -> Array:
	var rects: Array = []
	var offset: Vector2 = world_rect(data).position
	var collision_rects: Array = []
	if data.has("collisionRects"):
		collision_rects = data["collisionRects"] as Array
	for item in collision_rects:
		var rect: Rect2 = (item as Dictionary)["rect"] as Rect2
		rects.append(Rect2(rect.position + offset, rect.size))
	var prop_collision_rects: Array = []
	if data.has("propCollisionRects"):
		prop_collision_rects = data["propCollisionRects"] as Array
	for item in prop_collision_rects:
		var rect: Rect2 = (item as Dictionary)["rect"] as Rect2
		rects.append(Rect2(rect.position + offset, rect.size))
	return rects
