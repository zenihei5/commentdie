class_name RelayFlowSystem
extends RefCounted

const SEGMENT_IDS: Array[String] = ["zatsudan", "gameplay", "singing", "drawing", "collab"]
const STATES: Array[String] = [
	"CharacterSelect", "SegmentIntro", "PlayingChat", "BreakAfterChat", "PlayingGame",
	"BreakAfterGame", "PlayingSong", "BreakAfterSong", "PlayingDrawing", "BreakAfterDrawing",
	"CollabPartnerSelect", "PlayingCollab", "BreakBeforeBoss", "BossIntro", "PlayingBoss", "Clear", "Failed"
]

static func segment_id(index: int) -> String:
	return SEGMENT_IDS[clampi(index, 0, SEGMENT_IDS.size() - 1)]

static func playing_state_for_segment(id: String) -> String:
	match id:
		"zatsudan": return "PlayingChat"
		"gameplay": return "PlayingGame"
		"singing": return "PlayingSong"
		"drawing": return "PlayingDrawing"
		"collab": return "PlayingCollab"
	return "PlayingChat"

static func break_state_for_segment(id: String) -> String:
	match id:
		"zatsudan": return "BreakAfterChat"
		"gameplay": return "BreakAfterGame"
		"singing": return "BreakAfterSong"
		"drawing": return "BreakAfterDrawing"
		"collab": return "BreakBeforeBoss"
	return "BreakAfterChat"

static func is_boss_state(flow_state: String) -> bool:
	return flow_state == "BossIntro" or flow_state == "PlayingBoss"

static func is_segment_playing(flow_state: String) -> bool:
	return flow_state == "PlayingChat" or flow_state == "PlayingGame" or flow_state == "PlayingSong" or flow_state == "PlayingDrawing" or flow_state == "PlayingCollab"

static func progress_label(index: int, flow_state: String) -> String:
	var parts: Array[String] = ["雑談", "ゲーム", "歌", "お絵かき", "コラボ", "ボス"]
	var current := 5 if is_boss_state(flow_state) else clampi(index, 0, 4)
	var labels: Array[String] = []
	for i in range(parts.size()):
		labels.append((">" if i == current else "") + parts[i])
	return "  ".join(labels)
