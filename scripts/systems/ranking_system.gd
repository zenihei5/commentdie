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

static func save_and_format_ranking(entry: Dictionary, quick_test_mode: bool) -> String:
	if quick_test_mode:
		return "ランキング：60秒テストは対象外"
	var entries: Array = load_rankings()
	entries.append(entry)
	entries.sort_custom(func(a, b): return int(a["score"]) > int(b["score"]))
	while entries.size() > 10:
		entries.pop_back()
	save_rankings(entries)
	var lines: Array[String] = ["神回ランキング TOP3"]
	for i in range(mini(3, entries.size())):
		var e: Dictionary = entries[i]
		lines.append("%d. %d  %s  %s  %s  x%.1f" % [
			i + 1,
			int(e["score"]),
			String(e.get("characterName", "配信者")),
			String(e.get("streamFrameName", "配信枠")),
			String(e["rank"]),
			float(e["maxMultiplier"])
		])
	return "\n".join(lines)
