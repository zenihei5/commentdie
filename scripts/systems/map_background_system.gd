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
const SINGING_STAGE_DIR := "res://assets/generated/maps/singing_stage_v1"
const SINGING_STAGE_BG := SINGING_STAGE_DIR + "/singing_stage_base_1470x1070.png"
const SINGING_STAGE_CHORUS_BG := SINGING_STAGE_DIR + "/singing_stage_chorus_1470x1070.png"
const SINGING_STAGE_FLOOR_SPEAKER := "res://assets/generated/song_stage_obstacles_v1/floor_speaker.png"
const SINGING_STAGE_FLOOR_SPEAKER_FLIPPED := "res://assets/generated/song_stage_obstacles_v1/floor_speaker_flipped.png"
const SINGING_STAGE_MONITOR_STAND := "res://assets/generated/song_stage_obstacles_v1/monitor_stand.png"
const DRAWING_STAGE_DIR := "res://assets/generated/maps/drawing_stage_v1"
const DRAWING_STAGE_BG := DRAWING_STAGE_DIR + "/drawing_stage_base.png"
const DRAWING_STAGE_PROGRESS_ROUGH := DRAWING_STAGE_DIR + "/canvas_progress_rough.png"
const DRAWING_STAGE_PROGRESS_LINEART := DRAWING_STAGE_DIR + "/canvas_progress_lineart.png"
const DRAWING_STAGE_PROGRESS_FINISH := DRAWING_STAGE_DIR + "/canvas_progress_finish.png"
const DRAWING_STAGE_PROGRESS_COMPLETE := DRAWING_STAGE_DIR + "/canvas_progress_complete.png"
const COLLAB_STAGE_DIR := "res://assets/generated/maps/collab_studio_v2"
const COLLAB_STAGE_BG := COLLAB_STAGE_DIR + "/collab_studio_user_1536x1024.png"
const RELAY_BOSS_STAGE_DIR := "res://assets/generated/maps/relay_boss_stage_v1"
const RELAY_BOSS_STAGE_BG := RELAY_BOSS_STAGE_DIR + "/last_offline_boss_arena.png"

const ZATSUDAN_STUDIO_SIZE := Vector2(2200, 1500)
const ZATSUDAN_STUDIO_WORLD_RECT := Rect2(Vector2(20, 120), ZATSUDAN_STUDIO_SIZE)
const GAMEPLAY_ARENA_SIZE := Vector2(2200, 1500)
const GAMEPLAY_ARENA_WORLD_RECT := Rect2(Vector2(20, 120), GAMEPLAY_ARENA_SIZE)
const COLLAB_STAGE_SIZE := Vector2(2200, 1500)
const COLLAB_STAGE_WORLD_RECT := Rect2(Vector2(20, 120), COLLAB_STAGE_SIZE)
const RELAY_BOSS_STAGE_SIZE := Vector2(2200, 1500)
const RELAY_BOSS_STAGE_WORLD_RECT := Rect2(Vector2(20, 120), RELAY_BOSS_STAGE_SIZE)
const SINGING_STAGE_SIZE := Vector2(2200, 1600)
const SINGING_STAGE_WORLD_RECT := Rect2(Vector2(20, 120), SINGING_STAGE_SIZE)
const DRAWING_STAGE_SIZE := Vector2(2300, 1600)
const DRAWING_STAGE_WORLD_RECT := Rect2(Vector2(20, 120), DRAWING_STAGE_SIZE)
const DRAWING_STAGE_PLAY_RECT := Rect2(Vector2(280, 315), Vector2(1700, 950))
const DRAWING_STAGE_CANVAS_PROGRESS_RECT := Rect2(Vector2(280, 315), Vector2(1700, 950))
const DRAWING_STAGE_CANVAS_PROGRESS_INSET := Vector4(24, 44, 24, 42)
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
const COLLAB_STAGE_COLLISION_RECTS := [
	{"id": "top_monitor_wall", "rect": Rect2(0, 0, 2200, 218)},
	{"id": "bottom_window_ledge", "rect": Rect2(0, 1448, 2200, 52)},
	{"id": "left_wall_equipment", "rect": Rect2(0, 0, 160, 1500)},
	{"id": "right_wall_equipment", "rect": Rect2(2040, 0, 160, 1500)},
	{"id": "left_stream_desk", "rect": Rect2(260, 242, 455, 180)},
	{"id": "right_stream_desk", "rect": Rect2(1470, 242, 460, 180)},
	{"id": "center_audio_mixer", "rect": Rect2(910, 250, 380, 150)},
	{"id": "left_mobile_monitor", "rect": Rect2(562, 848, 148, 216)},
	{"id": "right_mobile_monitor", "rect": Rect2(1478, 848, 148, 216)},
	{"id": "bottom_sofa", "rect": Rect2(700, 1170, 690, 240)},
	{"id": "bottom_right_equipment_case", "rect": Rect2(1388, 1164, 116, 226)}
]
const RELAY_BOSS_STAGE_COLLISION_RECTS := [
	{"id": "top_ruined_studio", "rect": Rect2(0, 0, 2200, 270)},
	{"id": "bottom_ruined_studio", "rect": Rect2(0, 1280, 2200, 220)},
	{"id": "left_ruined_studio", "rect": Rect2(0, 0, 180, 1500)},
	{"id": "right_ruined_studio", "rect": Rect2(2020, 0, 180, 1500)}
]
const SINGING_STAGE_COLLISION_RECTS := [
	{"id": "top_stage_decor_band", "rect": Rect2(0, 0, 2200, 300)},
	{"id": "bottom_audience_edge", "rect": Rect2(0, 1230, 2200, 370)},
	{"id": "left_stage_side_decor", "rect": Rect2(0, 0, 176, 1600)},
	{"id": "right_stage_side_decor", "rect": Rect2(2024, 0, 176, 1600)}
]
const SINGING_STAGE_PROP_COLLISION_RECTS := [
	{"id": "floor_speaker_left", "rect": Rect2(438, 976, 206, 108)},
	{"id": "floor_speaker_right", "rect": Rect2(1556, 976, 206, 108)},
	{"id": "monitor_stand_mid", "rect": Rect2(1038, 438, 164, 196)}
]
const DRAWING_STAGE_COLLISION_RECTS := [
	{"id": "tablet_top_bezel", "rect": Rect2(0, 0, 2300, 315)},
	{"id": "tablet_bottom_bezel", "rect": Rect2(0, 1265, 2300, 335)},
	{"id": "tablet_left_bezel", "rect": Rect2(0, 315, 280, 950)},
	{"id": "tablet_right_bezel", "rect": Rect2(1980, 315, 320, 950)}
]
const DRAWING_STAGE_PROP_COLLISION_RECTS := []
const SINGING_STAGE_OBSTACLE_DRAW_ITEMS := [
	{
		"id": "floor_speaker_left",
		"texturePath": SINGING_STAGE_FLOOR_SPEAKER,
		"center": Vector2(541, 1022),
		"size": Vector2(232, 232),
		"shadowOffset": Vector2(0, 52),
		"shadowSize": Vector2(150, 24)
	},
	{
		"id": "floor_speaker_right",
		"texturePath": SINGING_STAGE_FLOOR_SPEAKER_FLIPPED,
		"center": Vector2(1659, 1022),
		"size": Vector2(232, 232),
		"shadowOffset": Vector2(0, 52),
		"shadowSize": Vector2(150, 24)
	},
	{
		"id": "monitor_stand_mid",
		"texturePath": SINGING_STAGE_MONITOR_STAND,
		"center": Vector2(1120, 535),
		"size": Vector2(214, 214),
		"shadowOffset": Vector2(0, 76),
		"shadowSize": Vector2(96, 22)
	}
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

static func collab_stage_background_data() -> Dictionary:
	return {
		"id": "collab_studio_v2",
		"size": COLLAB_STAGE_SIZE,
		"worldRect": COLLAB_STAGE_WORLD_RECT,
		"assembledPath": COLLAB_STAGE_BG,
		"floorPath": COLLAB_STAGE_BG,
		"propsPath": "",
		"collisionPreviewPath": "",
		"collisionRects": COLLAB_STAGE_COLLISION_RECTS,
		"propCollisionRects": []
	}

static func relay_boss_background_data() -> Dictionary:
	return {
		"id": "relay_boss_last_offline",
		"size": RELAY_BOSS_STAGE_SIZE,
		"worldRect": RELAY_BOSS_STAGE_WORLD_RECT,
		"assembledPath": RELAY_BOSS_STAGE_BG,
		"floorPath": RELAY_BOSS_STAGE_BG,
		"propsPath": "",
		"collisionPreviewPath": "",
		"collisionRects": RELAY_BOSS_STAGE_COLLISION_RECTS,
		"propCollisionRects": []
	}

static func singing_stage_background_path_for_mode(mode: String = "") -> String:
	if mode == "chorus":
		return SINGING_STAGE_CHORUS_BG
	return SINGING_STAGE_BG

static func singing_stage_background_data(mode: String = "") -> Dictionary:
	var background_path := singing_stage_background_path_for_mode(mode)
	return {
		"id": "singing_live_stage_%s" % (mode if mode != "" else "base"),
		"size": SINGING_STAGE_SIZE,
		"worldRect": SINGING_STAGE_WORLD_RECT,
		"assembledPath": background_path,
		"floorPath": background_path,
		"propsPath": "",
		"collisionPreviewPath": "",
		"collisionRects": SINGING_STAGE_COLLISION_RECTS,
		"propCollisionRects": SINGING_STAGE_PROP_COLLISION_RECTS,
		"obstacleDrawItems": SINGING_STAGE_OBSTACLE_DRAW_ITEMS
	}

static func drawing_stage_background_data() -> Dictionary:
	return {
		"id": "drawing_canvas_stage_v1",
		"size": DRAWING_STAGE_SIZE,
		"worldRect": DRAWING_STAGE_WORLD_RECT,
		"assembledPath": DRAWING_STAGE_BG,
		"floorPath": DRAWING_STAGE_BG,
		"propsPath": "",
		"collisionPreviewPath": "",
		"collisionRects": DRAWING_STAGE_COLLISION_RECTS,
		"propCollisionRects": DRAWING_STAGE_PROP_COLLISION_RECTS,
		"canvasProgressRect": DRAWING_STAGE_CANVAS_PROGRESS_RECT,
		"canvasProgressInset": DRAWING_STAGE_CANVAS_PROGRESS_INSET,
		"canvasProgressPaths": {
			"rough": DRAWING_STAGE_PROGRESS_ROUGH,
			"lineart": DRAWING_STAGE_PROGRESS_LINEART,
			"finish": DRAWING_STAGE_PROGRESS_FINISH,
			"complete": DRAWING_STAGE_PROGRESS_COMPLETE
		}
	}

static func background_data_for_stream_frame(frame_id: String, genre_event: String = "") -> Dictionary:
	match frame_id:
		"zatsudan":
			return zatsudan_background_data()
		"gameplay":
			return gameplay_arena_background_data(genre_event)
		"singing", "song":
			return singing_stage_background_data(genre_event)
		"drawing":
			return drawing_stage_background_data()
		"collab":
			return collab_stage_background_data()
		"relay_boss":
			return relay_boss_background_data()
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

static func relay_boss_static_wall_rects() -> Array:
	return static_wall_rects_for_data(relay_boss_background_data())

static func static_wall_rects_for_data(data: Dictionary) -> Array:
	var rects: Array = []
	var offset: Vector2 = world_rect(data).position
	var collision_rects: Array = []
	if data.has("collisionRects"):
		collision_rects = data["collisionRects"] as Array
	for item in collision_rects:
		var rect: Rect2 = (item as Dictionary)["rect"] as Rect2
		rects.append(Rect2(rect.position + offset, rect.size))
	rects.append_array(prop_collision_rects_for_data(data))
	return rects

static func prop_collision_rects_for_data(data: Dictionary) -> Array:
	var rects: Array = []
	if not data.has("propCollisionRects"):
		return rects
	var offset: Vector2 = world_rect(data).position
	for item in (data["propCollisionRects"] as Array):
		var rect: Rect2 = (item as Dictionary)["rect"] as Rect2
		rects.append(Rect2(rect.position + offset, rect.size))
	return rects

static func obstacle_draw_items_for_data(data: Dictionary) -> Array:
	var draw_items: Array = []
	if not data.has("obstacleDrawItems"):
		return draw_items
	var offset: Vector2 = world_rect(data).position
	for item in (data["obstacleDrawItems"] as Array):
		var source: Dictionary = item as Dictionary
		var draw_item := source.duplicate(true)
		draw_item["center"] = (source["center"] as Vector2) + offset
		draw_items.append(draw_item)
	return draw_items
