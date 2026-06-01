class_name RankingSystem
extends RefCounted

const RANKINGS_PATH := "user://rankings.json"

static func load_rankings() -> Array:
	if not FileAccess.file_exists(RANKINGS_PATH):
		return []
	var text: String = FileAccess.get_file_as_string(RANKINGS_PATH)
	var parsed: Variant = JSON.parse_string(text)
	return parsed if parsed is Array else []

static func save_rankings(entries: Array) -> void:
	var file: FileAccess = FileAccess.open(RANKINGS_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(entries))

static func save_and_format_ranking(entry: Dictionary, is_ranking_eligible: bool) -> String:
	if not is_ranking_eligible:
		return "ランキング：60秒テストは対象外"
	var entries: Array = load_rankings()
	entries.append(entry)
	entries.sort_custom(func(a: Variant, b: Variant) -> bool:
		var entry_a: Dictionary = a as Dictionary
		var entry_b: Dictionary = b as Dictionary
		return _entry_is_higher(entry_a, entry_b)
	)
	while entries.size() > 10:
		entries.pop_back()
	save_rankings(entries)
	var lines: Array[String] = ["神回ランキング TOP5"]
	for i in range(mini(5, entries.size())):
		var e: Dictionary = entries[i] as Dictionary
		lines.append("%d. %d人  %s  %s  %s  %s" % [
			i + 1,
			int(e["score"]),
			String(e.get("characterName", "配信者")),
			String(e.get("streamFrameName", "配信枠")),
			String(e.get("kamiRank", e.get("rank", "D"))),
			_format_time(float(e.get("survivalTime", e.get("time", 0))))
		])
	return "\n".join(lines)

static func _format_time(seconds: float) -> String:
	return "%02d:%02d" % [int(seconds) / 60, int(seconds) % 60]

static func format_ranking_screen() -> String:
	var entries: Array = load_rankings()
	if entries.is_empty():
		return "神回ランキング\n\nまだ記録がありません。"
	var lines: Array[String] = ["神回ランキング"]
	for i in range(mini(10, entries.size())):
		var e: Dictionary = entries[i] as Dictionary
		lines.append("%d. %d人  %s  %s  %s  最大ボルテージ x%.1f  %s" % [
			i + 1,
			int(e.get("score", 0)),
			String(e.get("kamiRank", e.get("rank", "D"))),
			String(e.get("characterName", "配信者")),
			String(e.get("streamFrameName", "配信枠")),
			float(e.get("maxMultiplier", 1.0)),
			_format_time(float(e.get("survivalTime", e.get("time", 0))))
		])
	return "\n".join(lines)

static func _entry_is_higher(a: Dictionary, b: Dictionary) -> bool:
	var score_a: int = int(a.get("score", 0))
	var score_b: int = int(b.get("score", 0))
	if score_a != score_b:
		return score_a > score_b
	var time_a: float = float(a.get("survivalTime", a.get("time", 0.0)))
	var time_b: float = float(b.get("survivalTime", b.get("time", 0.0)))
	if not is_equal_approx(time_a, time_b):
		return time_a > time_b
	return String(a.get("playedAt", a.get("date", ""))) > String(b.get("playedAt", b.get("date", "")))
