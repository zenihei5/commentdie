class_name MapBackgroundSystem
extends RefCounted

const ZATSUDAN_STUDIO_DIR := "res://assets/generated/maps/zatsudan_studio_layered_v1"
const ZATSUDAN_STUDIO_BG := ZATSUDAN_STUDIO_DIR + "/zatsudan_studio_floor_with_desk_props_assembled_2200x1500.png"
const ZATSUDAN_STUDIO_FLOOR := ZATSUDAN_STUDIO_DIR + "/zatsudan_studio_floor_only_chatgpt_2200x1500.png"
const ZATSUDAN_STUDIO_PROPS := ZATSUDAN_STUDIO_DIR + "/zatsudan_studio_desk_props_2200x1500.png"
const ZATSUDAN_STUDIO_COLLISION_PREVIEW := ZATSUDAN_STUDIO_DIR + "/zatsudan_studio_floor_with_desk_props_collision_preview_2200x1500.png"
const USE_TRIAL_FIELD_BACKGROUND := true
const TRIAL_FIELD_DIR := "res://assets/generated/maps/trial_field_v1"
const TRIAL_FIELD_BG := TRIAL_FIELD_DIR + "/field_trial_cover_2200x1500.png"
const TRIAL_FIELD_COLLISION_PREVIEW := TRIAL_FIELD_DIR + "/field_trial_collision_preview_2200x1500.png"
const GAMEPLAY_ARENA_DIR := "res://assets/generated/maps/gameplay_arena_v1"
const GAMEPLAY_ARENA_BG := GAMEPLAY_ARENA_DIR + "/gameplay_arena_user_2200x1500.png"
const GAMEPLAY_ARENA_RACE_BG := GAMEPLAY_ARENA_DIR + "/gameplay_arena_race_2200x1500.png"
const GAMEPLAY_ARENA_BULLET_HELL_BG := GAMEPLAY_ARENA_DIR + "/gameplay_arena_bullet_hell_2200x1500.png"
const GAMEPLAY_ARENA_HORROR_BG := GAMEPLAY_ARENA_DIR + "/gameplay_arena_horror_2200x1500.png"
const GAMEPLAY_ARENA_COLLISION_PREVIEW := GAMEPLAY_ARENA_DIR + "/gameplay_arena_user_collision_preview_2200x1500.png"

const ZATSUDAN_STUDIO_SIZE := Vector2(2200, 1500)
const ZATSUDAN_STUDIO_WORLD_RECT := Rect2(Vector2(20, 120), ZATSUDAN_STUDIO_SIZE)
const GAMEPLAY_ARENA_SIZE := Vector2(2200, 1500)
const GAMEPLAY_ARENA_WORLD_RECT := Rect2(Vector2(20, 120), GAMEPLAY_ARENA_SIZE)
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

# Local coordinates for field_trial_cover_2200x1500.png. Tune these Rect2 values
# while USE_TRIAL_FIELD_BACKGROUND is true; set it false to restore the old map.
const TRIAL_FIELD_COLLISION_RECTS := [
	{"id": "top_wall_decor", "rect": Rect2(5, -39, 2196, 231)},
	{"id": "left_upper_shelf", "rect": Rect2(0, 0, 252, 280)},
	{"id": "right_upper_shelf", "rect": Rect2(1940, 2, 260, 330)},
	{"id": "left_ring_camera", "rect": Rect2(102, 407, 192, 223)},
	{"id": "right_ring_camera", "rect": Rect2(1924, 402, 271, 217)},
	{"id": "left_work_desk", "rect": Rect2(0, 585, 178, 278)},
	{"id": "right_work_desk", "rect": Rect2(2023, 614, 180, 286)},
	{"id": "pink_comment_table", "rect": Rect2(607, 415, 280, 237)},
	{"id": "white_heart_table", "rect": Rect2(1308, 554, 301, 252)},
	{"id": "dark_comment_table", "rect": Rect2(912, 858, 344, 242)},
	{"id": "bottom_streaming_desk", "rect": Rect2(693, 1234, 840, 262)},
	{"id": "bottom_left_decor", "rect": Rect2(1, 1041, 289, 460)},
	{"id": "bottom_right_decor", "rect": Rect2(1872, 1175, 326, 306)},
	{"id": "bottom_left_plant", "rect": Rect2(596, 1276, 92, 161)},
	{"id": "bottom_right_plant", "rect": Rect2(1518, 1320, 96, 120)},
	{"id": "bottom_right_decor_copy", "rect": Rect2(2051, 1079, 151, 118)},
	{"id": "bottom_right_plant_copy", "rect": Rect2(909, 1171, 437, 115)},
	{"id": "left_ring_camera_copy", "rect": Rect2(-11, 285, 66, 234)},
	{"id": "bottom_left_plant_copy", "rect": Rect2(294, 1295, 129, 205)},
	{"id": "top_wall_decor_copy", "rect": Rect2(15, 28, 585, 220)},
	{"id": "top_wall_decor_copy_copy", "rect": Rect2(1602, 37, 585, 220)}
]
const GAMEPLAY_ARENA_COLLISION_RECTS := [
	{"id": "top_decor_band", "rect": Rect2(0, 0, 2200, 168)},
	{"id": "bottom_decor_band", "rect": Rect2(0, 1324, 2200, 176)},
	{"id": "left_decor_band", "rect": Rect2(0, 0, 150, 1500)},
	{"id": "right_decor_band", "rect": Rect2(2050, 0, 150, 1500)},
	{"id": "center_arcade_cabinet", "rect": Rect2(1064, 415, 118, 190)},
	{"id": "lower_left_game_desk", "rect": Rect2(740, 790, 196, 185)},
	{"id": "lower_right_tv_stand", "rect": Rect2(1282, 804, 214, 170)}
]

static func zatsudan_background_data() -> Dictionary:
	if USE_TRIAL_FIELD_BACKGROUND:
		return trial_field_background_data()
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

static func trial_field_background_data() -> Dictionary:
	return {
		"id": "trial_field_v1",
		"size": ZATSUDAN_STUDIO_SIZE,
		"worldRect": ZATSUDAN_STUDIO_WORLD_RECT,
		"assembledPath": TRIAL_FIELD_BG,
		"floorPath": TRIAL_FIELD_BG,
		"propsPath": "",
		"collisionPreviewPath": TRIAL_FIELD_COLLISION_PREVIEW,
		"collisionRects": TRIAL_FIELD_COLLISION_RECTS,
		"propCollisionRects": []
	}

static func gameplay_arena_background_path_for_genre(genre_event: String = "") -> String:
	match genre_event:
		"race":
			return GAMEPLAY_ARENA_RACE_BG
		"bullet_hell":
			return GAMEPLAY_ARENA_BULLET_HELL_BG
		"horror":
			return GAMEPLAY_ARENA_HORROR_BG
	return GAMEPLAY_ARENA_BG

static func gameplay_arena_background_data(genre_event: String = "") -> Dictionary:
	var background_path := gameplay_arena_background_path_for_genre(genre_event)
	return {
		"id": "gameplay_arena_%s" % (genre_event if genre_event != "" else "base"),
		"size": GAMEPLAY_ARENA_SIZE,
		"worldRect": GAMEPLAY_ARENA_WORLD_RECT,
		"assembledPath": background_path,
		"floorPath": background_path,
		"propsPath": "",
		"collisionPreviewPath": GAMEPLAY_ARENA_COLLISION_PREVIEW,
		"collisionRects": GAMEPLAY_ARENA_COLLISION_RECTS,
		"propCollisionRects": []
	}

static func background_data_for_stream_frame(frame_id: String, genre_event: String = "") -> Dictionary:
	match frame_id:
		"zatsudan":
			return zatsudan_background_data()
		"gameplay":
			return gameplay_arena_background_data(genre_event)
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
