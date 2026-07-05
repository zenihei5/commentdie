class_name RankingSystem
extends RefCounted

const RANKINGS_PATH: String = "user://rankings.json"
const MAX_SAVED_ENTRIES: int = 100
const MAX_TAB_ENTRIES: int = 10
const RANK_ORDER: Dictionary = {"S": 5, "A": 4, "B": 3, "C": 2, "D": 1}


static func load_rankings() -> Array:
	return _safe_array(_load_ranking_data().get("rankingEntries", []))


static func load_relay_rankings() -> Array:
	return _safe_array(_load_ranking_data().get("relayRankingEntries", []))


static func _load_ranking_data() -> Dictionary:
	if not FileAccess.file_exists(RANKINGS_PATH):
		return {"rankingEntries": [], "relayRankingEntries": []}
	var file: FileAccess = FileAccess.open(RANKINGS_PATH, FileAccess.READ)
	if file == null:
		return {"rankingEntries": [], "relayRankingEntries": []}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Array:
		var legacy_entries: Array = parsed as Array
		return {"rankingEntries": legacy_entries, "relayRankingEntries": []}
	if parsed is Dictionary:
		var data: Dictionary = parsed as Dictionary
		return {
			"rankingEntries": _safe_array(data.get("rankingEntries", [])),
			"relayRankingEntries": _safe_array(data.get("relayRankingEntries", []))
		}
	return {"rankingEntries": [], "relayRankingEntries": []}


static func save_rankings(entries: Array) -> void:
	save_all_rankings(entries, load_relay_rankings())


static func save_relay_rankings(entries: Array) -> void:
	save_all_rankings(load_rankings(), entries)


static func reset_rankings() -> void:
	save_all_rankings([], [])


static func reset_tab(tab_index: int = 0, relay_mode_unlocked: bool = false) -> void:
	var clamped_tab: int = clamp_tab_index(tab_index, relay_mode_unlocked)
	var tab: Dictionary = _tabs(relay_mode_unlocked)[clamped_tab] as Dictionary
	var tab_id: String = String(tab.get("id", "all"))
	if tab_id == "relay":
		save_relay_rankings([])
		return
	if tab_id == "all":
		save_rankings([])
		return
	var kept_entries: Array = []
	for entry_item in load_rankings():
		if not (entry_item is Dictionary):
			continue
		var entry: Dictionary = entry_item as Dictionary
		if String(entry.get("streamFrameId", "")) != tab_id:
			kept_entries.append(entry)
	save_rankings(kept_entries)


static func tab_reset_label(tab_index: int = 0, relay_mode_unlocked: bool = false) -> String:
	var tab: Dictionary = _tabs(relay_mode_unlocked)[clamp_tab_index(tab_index, relay_mode_unlocked)] as Dictionary
	return String(tab.get("label", "ランキング")).replace(" 未開放", "")


static func save_all_rankings(entries: Array, relay_entries: Array) -> void:
	var sorted_entries: Array = _sort_entries(entries)
	if sorted_entries.size() > MAX_SAVED_ENTRIES:
		sorted_entries = sorted_entries.slice(0, MAX_SAVED_ENTRIES)
	var sorted_relay_entries: Array = _sort_relay_entries(relay_entries)
	if sorted_relay_entries.size() > MAX_SAVED_ENTRIES:
		sorted_relay_entries = sorted_relay_entries.slice(0, MAX_SAVED_ENTRIES)
	var file: FileAccess = FileAccess.open(RANKINGS_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify({
		"rankingEntries": sorted_entries,
		"relayRankingEntries": sorted_relay_entries
	}, "\t"))


static func save_and_format_ranking(entry: Dictionary, is_ranking_eligible: bool) -> String:
	if not is_ranking_eligible or String(entry.get("modeId", "")) != "normal_180":
		return "ランキング対象外：テスト配信の記録は保存されません。"
	var entries: Array = load_rankings()
	entries.append(entry)
	var sorted_entries: Array = _sort_entries(entries)
	if sorted_entries.size() > MAX_SAVED_ENTRIES:
		sorted_entries = sorted_entries.slice(0, MAX_SAVED_ENTRIES)
	save_rankings(sorted_entries)
	var scoped_entries: Array = _ranking_scope_entries(sorted_entries, String(entry.get("streamFrameId", "")))
	var rank_index: int = _rank_position(scoped_entries, entry)
	var viewer_count: int = int(entry.get("viewerCount", entry.get("score", 0)))
	return "%s登録：%d位 / 最大同時視聴者数 %s人" % [
		_ranking_scope_label(entry),
		rank_index,
		_format_number(viewer_count)
	]


static func save_and_format_relay_ranking(entry: Dictionary, is_ranking_eligible: bool) -> String:
	if not is_ranking_eligible or String(entry.get("modeId", "")) != "relay":
		return "ランキング対象外：配信リレー以外の記録は保存されません。"
	var entries: Array = load_relay_rankings()
	entries.append(entry)
	var sorted_entries: Array = _sort_relay_entries(entries)
	if sorted_entries.size() > MAX_SAVED_ENTRIES:
		sorted_entries = sorted_entries.slice(0, MAX_SAVED_ENTRIES)
	save_relay_rankings(sorted_entries)
	var rank_index: int = _relay_rank_position(sorted_entries, entry)
	return "配信リレーランキング登録：%d位 / %s / 最大%s人" % [
		rank_index,
		_relay_progress_text(entry),
		_format_number(int(entry.get("maxViewerCount", 0)))
	]


static func tab_count(relay_mode_unlocked: bool = false) -> int:
	return _tabs(relay_mode_unlocked).size()


static func clamp_tab_index(tab_index: int, relay_mode_unlocked: bool = false) -> int:
	return clampi(tab_index, 0, maxi(0, tab_count(relay_mode_unlocked) - 1))


static func entry_count_for_tab(tab_index: int, relay_mode_unlocked: bool = false) -> int:
	return _sorted_entries_for_tab(tab_index, relay_mode_unlocked).size()


static func format_ranking_screen(tab_index: int = 0, selected_index: int = 0, relay_mode_unlocked: bool = false) -> String:
	var tab: Dictionary = _tabs(relay_mode_unlocked)[clamp_tab_index(tab_index, relay_mode_unlocked)] as Dictionary
	var tab_id: String = String(tab.get("id", "all"))
	var lines: Array[String] = []
	lines.append("配信リレーランキング" if tab_id == "relay" else "神回ランキング")
	lines.append(_format_tabs(tab_index, relay_mode_unlocked))
	lines.append("")
	if bool(tab.get("locked", false)):
		if tab_id == "relay":
			lines.append("配信リレーはまだ開放されていません。")
			lines.append("すべての配信枠を開放すると選択できます。")
		else:
			lines.append("この配信枠はまだ開放されていません。")
			lines.append(String(tab.get("unlockText", "ゲーム実況枠をクリアすると開放されます。")))
		return "\n".join(lines)

	var entries: Array = _sorted_entries_for_tab(tab_index, relay_mode_unlocked)
	if entries.is_empty():
		if tab_id == "relay":
			lines.append("まだ配信リレーの記録がありません。")
			lines.append("全配信枠を突破して、神回リレーを目指そう！")
		else:
			lines.append("まだ記録がありません。")
			if tab_id == "all":
				lines.append("ニューゲームから配信を始めよう！")
			else:
				lines.append("この配信枠で神回を目指そう！")
		return "\n".join(lines)

	var clamped_selected: int = clampi(selected_index, 0, entries.size() - 1)
	for index in range(entries.size()):
		var entry: Dictionary = entries[index] as Dictionary
		if tab_id == "relay":
			lines.append(_format_relay_entry_row(entry, index, index == clamped_selected))
		else:
			lines.append(_format_entry_row(entry, index, index == clamped_selected, tab_id == "all"))
	lines.append("")
	if tab_id == "relay":
		lines.append(_format_relay_detail(entries[clamped_selected] as Dictionary, clamped_selected + 1))
	else:
		lines.append(_format_detail(entries[clamped_selected] as Dictionary, clamped_selected + 1))
	return "\n".join(lines)


static func ranking_view(tab_index: int = 0, selected_index: int = 0, relay_mode_unlocked: bool = false) -> Dictionary:
	var clamped_tab: int = clamp_tab_index(tab_index, relay_mode_unlocked)
	var tabs: Array = _tabs(relay_mode_unlocked)
	var tab: Dictionary = tabs[clamped_tab] as Dictionary
	var tab_id: String = String(tab.get("id", "all"))
	var tab_views: Array = []
	for index in range(tabs.size()):
		var source_tab: Dictionary = tabs[index] as Dictionary
		tab_views.append({
			"id": String(source_tab.get("id", "")),
			"label": String(source_tab.get("label", "")),
			"locked": bool(source_tab.get("locked", false)),
			"selected": index == clamped_tab
		})
	var view: Dictionary = {
		"title": "ランキング",
		"subtitle": "最大同時視聴者数ランキング",
		"tabId": tab_id,
		"tabIndex": clamped_tab,
		"tabs": tab_views,
		"locked": bool(tab.get("locked", false)),
		"empty": false,
		"messageLines": [],
		"rows": [],
		"selectedIndex": 0,
		"detailCards": [],
		"detail": {}
	}
	if bool(view["locked"]):
		if tab_id == "relay":
			view["messageLines"] = ["配信リレーランキングはまだ開放されていません。", "すべての配信枠を開放するとランキングが表示されます。"]
		else:
			view["messageLines"] = ["この配信枠はまだ開放されていません。", "解放条件：%s" % String(tab.get("unlockText", "ゲーム実況枠をクリアすると開放されます。"))]
		return view
	var entries: Array = _sorted_entries_for_tab(clamped_tab, relay_mode_unlocked)
	if entries.is_empty():
		view["empty"] = true
		if tab_id == "relay":
			view["messageLines"] = ["まだ配信リレーの記録がありません。", "配信リレーを遊ぶと、最大同時視聴者数ランキングに登録されます。"]
		elif tab_id == "all":
			view["messageLines"] = ["まだ記録がありません。", "配信を遊ぶと、最大同時視聴者数ランキングに登録されます。"]
		else:
			view["messageLines"] = ["まだ記録がありません。", "この配信枠を遊ぶと、最大同時視聴者数ランキングに登録されます。"]
		return view
	var clamped_selected: int = clampi(selected_index, 0, entries.size() - 1)
	view["selectedIndex"] = clamped_selected
	var rows: Array = []
	for index in range(entries.size()):
		var entry: Dictionary = entries[index] as Dictionary
		rows.append(_relay_row_view(entry, index, index == clamped_selected) if tab_id == "relay" else _normal_row_view(entry, index, index == clamped_selected, tab_id == "all"))
	view["rows"] = rows
	var selected_entry: Dictionary = entries[clamped_selected] as Dictionary
	view["detailCards"] = _relay_detail_cards(selected_entry) if tab_id == "relay" else _normal_detail_cards(selected_entry)
	view["detail"] = _relay_detail_view(selected_entry, clamped_selected + 1) if tab_id == "relay" else _normal_detail_view(selected_entry, clamped_selected + 1)
	return view


static func _tabs(relay_mode_unlocked: bool = false) -> Array:
	return [
		{"id": "all", "label": "総合"},
		{"id": "zatsudan", "label": "雑談枠"},
		{"id": "gameplay", "label": "ゲーム実況枠"},
		{"id": "singing", "label": "歌枠"},
		{"id": "drawing", "label": "お絵かき枠 未開放", "locked": true, "unlockText": "歌枠をクリアすると開放されます。"},
		{"id": "collab", "label": "コラボ枠 未開放", "locked": true, "unlockText": "お絵かき枠をクリアすると開放されます。"},
		{"id": "relay", "label": "配信リレー" if relay_mode_unlocked else "配信リレー 未開放", "locked": not relay_mode_unlocked}
	]


static func _format_tabs(tab_index: int, relay_mode_unlocked: bool = false) -> String:
	var labels: Array[String] = []
	var tabs: Array = _tabs(relay_mode_unlocked)
	for index in range(tabs.size()):
		var tab: Dictionary = tabs[index] as Dictionary
		var label: String = String(tab.get("label", ""))
		if index == clamp_tab_index(tab_index, relay_mode_unlocked):
			labels.append("[%s]" % label)
		else:
			labels.append(label)
	return " / ".join(labels)


static func _sorted_entries_for_tab(tab_index: int, relay_mode_unlocked: bool = false) -> Array:
	var tab: Dictionary = _tabs(relay_mode_unlocked)[clamp_tab_index(tab_index, relay_mode_unlocked)] as Dictionary
	if bool(tab.get("locked", false)):
		return []
	var tab_id: String = String(tab.get("id", "all"))
	if tab_id == "relay":
		var relay_entries: Array = _sort_relay_entries(load_relay_rankings())
		if relay_entries.size() > MAX_TAB_ENTRIES:
			return relay_entries.slice(0, MAX_TAB_ENTRIES)
		return relay_entries
	var entries: Array = []
	for entry_item in load_rankings():
		if not (entry_item is Dictionary):
			continue
		var entry: Dictionary = entry_item as Dictionary
		if String(entry.get("modeId", "")) != "normal_180":
			continue
		if tab_id != "all" and String(entry.get("streamFrameId", "")) != tab_id:
			continue
		entries.append(entry)
	var sorted_entries: Array = _sort_entries(entries)
	if sorted_entries.size() > MAX_TAB_ENTRIES:
		return sorted_entries.slice(0, MAX_TAB_ENTRIES)
	return sorted_entries


static func _sort_entries(entries: Array) -> Array:
	var sorted_entries: Array = entries.duplicate()
	sorted_entries.sort_custom(func(a: Variant, b: Variant) -> bool:
		if not (a is Dictionary) or not (b is Dictionary):
			return false
		return _entry_is_higher(a as Dictionary, b as Dictionary)
	)
	return sorted_entries


static func _sort_relay_entries(entries: Array) -> Array:
	var sorted_entries: Array = entries.duplicate()
	sorted_entries.sort_custom(func(a: Variant, b: Variant) -> bool:
		if not (a is Dictionary) or not (b is Dictionary):
			return false
		return _relay_entry_is_higher(a as Dictionary, b as Dictionary)
	)
	return sorted_entries


static func _format_entry_row(entry: Dictionary, index: int, selected: bool, show_frame: bool) -> String:
	var marker: String = ">" if selected else " "
	var viewer_count: int = int(entry.get("viewerCount", entry.get("score", 0)))
	var parts: Array[String] = [
		"%s%2d." % [marker, index + 1],
		_character_nickname(entry),
		"%s人" % _format_number(viewer_count),
		"神回度%s" % String(entry.get("kamiRank", entry.get("rank", "D")))
	]
	if show_frame:
		parts.append(String(entry.get("streamFrameName", "配信枠")))
	parts.append("x%.1f" % float(entry.get("maxVoltage", entry.get("maxMultiplier", 1.0))))
	parts.append(_format_time(float(entry.get("survivalTime", entry.get("time", 0)))))
	parts.append(_format_build_short(entry))
	return "  ".join(parts)


static func _format_relay_entry_row(entry: Dictionary, index: int, selected: bool) -> String:
	var marker: String = ">" if selected else " "
	var lines: Array[String] = [
		"%s%2d. [%s] %s" % [marker, index + 1, _character_nickname(entry), _relay_progress_text(entry)]
	]
	if not bool(entry.get("isRelayCompleted", false)):
		lines.append("     到達：%s" % String(entry.get("currentFrameName", "配信枠")))
	lines.append("     最大%s人 / 合計%s人 / 最大ボルテージ x%.1f" % [
		_format_number(int(entry.get("maxViewerCount", 0))),
		_format_number(int(entry.get("totalViewerCount", 0))),
		float(entry.get("maxVoltage", 1.0))
	])
	lines.append("     武器：%s" % _equipment_summary(_safe_array(entry.get("weapons", [])), "なし"))
	lines.append("     アクセ：%s" % _equipment_summary(_safe_array(entry.get("accessories", [])), "なし"))
	return "\n".join(lines)


static func _normal_row_view(entry: Dictionary, index: int, selected: bool, _show_frame: bool) -> Dictionary:
	var viewer_count: int = _viewer_count(entry)
	var meta_parts: Array[String] = [
		"神回度 %s" % String(entry.get("kamiRank", entry.get("rank", "D"))),
		"x%.1f" % float(entry.get("maxVoltage", entry.get("maxMultiplier", 1.0))),
		_format_time(float(entry.get("survivalTime", entry.get("time", 0))))
	]
	meta_parts.insert(1, String(entry.get("streamFrameName", "配信枠")))
	return {
		"rank": index + 1,
		"selected": selected,
		"characterId": _character_id(entry),
		"character": _character_nickname(entry),
		"title": _character_nickname(entry),
		"scoreText": "%s人" % _format_number(viewer_count),
		"summary": " / ".join(meta_parts),
		"build": _format_build_short(entry),
		"weapons": _slice_items(_safe_array(entry.get("weapons", [])), 5),
		"accessories": _slice_items(_safe_array(entry.get("accessories", [])), 5),
		"endType": _entry_end_type(entry),
		"endTypeLabel": _end_type_label(entry),
		"accent": _rank_accent(index)
	}


static func _relay_row_view(entry: Dictionary, index: int, selected: bool) -> Dictionary:
	var summary: String = _relay_progress_text(entry)
	if not bool(entry.get("isRelayCompleted", false)):
		summary += " / 到達 %s" % String(entry.get("currentFrameName", "配信枠"))
	return {
		"rank": index + 1,
		"selected": selected,
		"characterId": _character_id(entry),
		"character": _character_nickname(entry),
		"title": _character_nickname(entry),
		"scoreText": "最大%s人" % _format_number(int(entry.get("maxViewerCount", 0))),
		"summary": "%s / 合計%s人 / x%.1f" % [
			summary,
			_format_number(int(entry.get("totalViewerCount", 0))),
			float(entry.get("maxVoltage", 1.0))
		],
		"build": "武器 %s / アクセ %s" % [
			_equipment_summary(_safe_array(entry.get("weapons", [])), "なし"),
			_equipment_summary(_safe_array(entry.get("accessories", [])), "なし")
		],
		"weapons": _slice_items(_safe_array(entry.get("weapons", [])), 5),
		"accessories": _slice_items(_safe_array(entry.get("accessories", [])), 5),
		"endType": _entry_end_type(entry),
		"endTypeLabel": _end_type_label(entry),
		"accent": _rank_accent(index)
	}


static func _normal_detail_view(entry: Dictionary, rank_index: int) -> Dictionary:
	var end_type: String = _entry_end_type(entry)
	return {
		"title": "記録詳細",
		"rankLabel": "%d位記録" % rank_index,
		"summaryLines": [
			"%s / %s" % [_character_nickname(entry), String(entry.get("streamFrameName", "配信枠"))],
			"最大同時視聴者数：%s人" % _format_number(_viewer_count(entry)),
			"神回度：%s / 終了：%s" % [String(entry.get("kamiRank", entry.get("rank", "D"))), _end_type_label(entry)]
		],
		"stats": [
			{"label": "最大同時視聴者数", "value": "%s人" % _format_number(_viewer_count(entry))},
			{"label": "神回度", "value": "%s  %dpt" % [String(entry.get("kamiRank", entry.get("rank", "D"))), _god_point(entry)]},
			{"label": "生存時間", "value": _format_time(float(entry.get("survivalTime", entry.get("time", 0))))},
			{"label": "最大ボルテージ", "value": "x%.1f" % float(entry.get("maxVoltage", entry.get("maxMultiplier", 1.0)))},
			{"label": "最大バズ度", "value": "%d" % int(entry.get("maxBurnCombo", 0))},
			{"label": "ギフト数", "value": "%d" % int(entry.get("giftCount", 0))}
		],
		"weapons": _safe_array(entry.get("weapons", [])),
		"accessories": _safe_array(entry.get("accessories", [])),
		"instructionTitle": _instruction_title(end_type),
		"instructionLines": _instruction_lines(entry, end_type),
		"bossText": _boss_detail_text(entry) if _boss_detail_text(entry) != "" else "なし",
		"playedAtText": _format_played_at(String(entry.get("playedAt", ""))),
		"endTypeLabel": _end_type_label(entry)
	}


static func _relay_detail_view(entry: Dictionary, rank_index: int) -> Dictionary:
	var end_type: String = _entry_end_type(entry)
	var completed_names: Array[String] = _string_array(entry.get("completedFrameNames", []))
	var completed_text: String = "なし" if completed_names.is_empty() else " / ".join(completed_names)
	return {
		"title": "配信リレー詳細",
		"rankLabel": "%d位記録" % rank_index,
		"summaryLines": [
			"%s / 配信リレー" % _character_nickname(entry),
			"最大同時視聴者数：%s人" % _format_number(int(entry.get("maxViewerCount", 0))),
			"突破：%s / 終了：%s" % [_relay_progress_text(entry), _end_type_label(entry)]
		],
		"stats": [
			{"label": "最大同時視聴者数", "value": "%s人" % _format_number(int(entry.get("maxViewerCount", 0)))},
			{"label": "合計視聴者数", "value": "%s人" % _format_number(int(entry.get("totalViewerCount", 0)))},
			{"label": "到達枠", "value": String(entry.get("currentFrameName", "配信枠"))},
			{"label": "突破枠", "value": completed_text},
			{"label": "最大ボルテージ", "value": "x%.1f" % float(entry.get("maxVoltage", 1.0))},
			{"label": "最大バズ度", "value": "%d" % int(entry.get("maxBurnCombo", 0))}
		],
		"weapons": _safe_array(entry.get("weapons", [])),
		"accessories": _safe_array(entry.get("accessories", [])),
		"instructionTitle": _instruction_title(end_type),
		"instructionLines": _instruction_lines(entry, end_type),
		"bossText": _boss_detail_text(entry) if _boss_detail_text(entry) != "" else "なし",
		"playedAtText": _format_played_at(String(entry.get("playedAt", ""))),
		"endTypeLabel": _end_type_label(entry)
	}


static func _format_detail(entry: Dictionary, rank_index: int) -> String:
	var lines: Array[String] = [
		"詳細：%d位" % rank_index,
		"配信者：%s" % _character_nickname(entry),
		"配信枠：%s" % String(entry.get("streamFrameName", "配信枠")),
		"最大同時視聴者数：%s人" % _format_number(int(entry.get("viewerCount", entry.get("score", 0)))),
		"神回度：%s" % String(entry.get("kamiRank", entry.get("rank", "D"))),
		"生存時間：%s" % _format_time(float(entry.get("survivalTime", entry.get("time", 0)))),
		"最大ボルテージ：x%.1f" % float(entry.get("maxVoltage", entry.get("maxMultiplier", 1.0))),
		"最大バズ度：%d" % int(entry.get("maxBurnCombo", 0)),
		"武器：%s" % _equipment_summary(_safe_array(entry.get("weapons", [])), String(entry.get("weaponEquipmentText", "なし"))),
		"アクセサリ：%s" % _equipment_summary(_safe_array(entry.get("accessories", [])), String(entry.get("accessoryEquipmentText", "なし"))),
		"戦犯指示コメ：%s" % String(entry.get("culpritInstructionComment", "なし")),
		"死因：%s" % String(entry.get("deathText", "")),
		"日時：%s" % String(entry.get("playedAt", ""))
	]
	var boss_text: String = _boss_detail_text(entry)
	if boss_text != "":
		lines.insert(lines.size() - 1, "ボス：%s" % boss_text)
	return "\n".join(lines)


static func _normal_detail_cards(entry: Dictionary) -> Array:
	var cards: Array = [
		{
			"title": "配信者",
			"lines": [
				_character_nickname(entry),
				String(entry.get("streamFrameName", "配信枠"))
			]
		},
		{
			"title": "統計情報",
			"lines": [
				"最大同時視聴者数 %s人" % _format_number(int(entry.get("viewerCount", entry.get("score", 0)))),
				"神回度 %s" % String(entry.get("kamiRank", entry.get("rank", "D"))),
				"生存時間 %s" % _format_time(float(entry.get("survivalTime", entry.get("time", 0)))),
				"最大ボルテージ x%.1f" % float(entry.get("maxVoltage", entry.get("maxMultiplier", 1.0))),
				"最大バズ度 %d" % int(entry.get("maxBurnCombo", 0))
			]
		},
		{
			"title": "ビルド構成",
			"lines": [
				"武器：%s" % _equipment_summary(_safe_array(entry.get("weapons", [])), String(entry.get("weaponEquipmentText", "なし"))),
				"アクセ：%s" % _equipment_summary(_safe_array(entry.get("accessories", [])), String(entry.get("accessoryEquipmentText", "なし")))
			]
		},
		{
			"title": "戦犯指示コメ",
			"lines": [
				String(entry.get("culpritInstructionComment", "なし")),
				"死因：%s" % String(entry.get("deathText", ""))
			]
		},
		{
			"title": "記録日時",
			"lines": [String(entry.get("playedAt", ""))]
		}
	]
	var boss_text: String = _boss_detail_text(entry)
	if boss_text != "":
		cards.insert(3, {
			"title": "ボス結果",
			"lines": [boss_text]
		})
	return cards


static func _format_relay_detail(entry: Dictionary, rank_index: int) -> String:
	var completed_names: Array[String] = _string_array(entry.get("completedFrameNames", []))
	var completed_text: String = "なし" if completed_names.is_empty() else "\n".join(completed_names)
	var ended_reason: String = _relay_ended_reason_text(String(entry.get("endedReason", "")))
	var culprit: String = String(entry.get("culpritInstructionComment", "なし"))
	if culprit == "" or culprit == "<null>":
		culprit = "なし"
	var lines: Array[String] = [
		"配信リレー詳細：%d位" % rank_index,
		"配信者：%s" % _character_nickname(entry),
		"モード：配信リレー",
		"突破数：%s" % _relay_progress_text(entry),
		"到達配信枠：%s" % String(entry.get("currentFrameName", "配信枠")),
		"突破した配信枠：\n%s" % completed_text,
		"最大同時視聴者数：%s人" % _format_number(int(entry.get("maxViewerCount", 0))),
		"合計同時視聴者数：%s人" % _format_number(int(entry.get("totalViewerCount", 0))),
		"最大ボルテージ：x%.1f" % float(entry.get("maxVoltage", 1.0)),
		"最大バズ度：%d" % int(entry.get("maxBurnCombo", 0)),
		"最終武器ビルド：\n%s" % _equipment_detail(_safe_array(entry.get("weapons", []))),
		"最終アクセサリビルド：\n%s" % _equipment_detail(_safe_array(entry.get("accessories", []))),
		"終了理由：%s" % ended_reason,
		"戦犯指示コメ：%s" % culprit,
		"死因：%s" % String(entry.get("deathText", "")),
		"日時：%s" % String(entry.get("playedAt", ""))
	]
	var boss_text: String = _boss_detail_text(entry)
	if boss_text != "":
		lines.insert(lines.size() - 1, "ボス：%s" % boss_text)
	return "\n".join(lines)


static func _relay_detail_cards(entry: Dictionary) -> Array:
	var completed_names: Array[String] = _string_array(entry.get("completedFrameNames", []))
	var completed_text: String = "なし" if completed_names.is_empty() else " / ".join(completed_names)
	var culprit: String = String(entry.get("culpritInstructionComment", "なし"))
	if culprit == "" or culprit == "<null>":
		culprit = "なし"
	var cards: Array = [
		{
			"title": "配信者",
			"lines": [
				_character_nickname(entry),
				"配信リレー"
			]
		},
		{
			"title": "突破状況",
			"lines": [
				_relay_progress_text(entry),
				"到達：%s" % String(entry.get("currentFrameName", "配信枠")),
				"突破：%s" % completed_text,
				"終了理由：%s" % _relay_ended_reason_text(String(entry.get("endedReason", "")))
			]
		},
		{
			"title": "統計情報",
			"lines": [
				"最大同時視聴者数 %s人" % _format_number(int(entry.get("maxViewerCount", 0))),
				"合計同時視聴者数 %s人" % _format_number(int(entry.get("totalViewerCount", 0))),
				"最大ボルテージ x%.1f" % float(entry.get("maxVoltage", 1.0)),
				"最大バズ度 %d" % int(entry.get("maxBurnCombo", 0))
			]
		},
		{
			"title": "最終ビルド",
			"lines": [
				"武器：%s" % _equipment_summary(_safe_array(entry.get("weapons", [])), "なし"),
				"アクセ：%s" % _equipment_summary(_safe_array(entry.get("accessories", [])), "なし")
			]
		},
		{
			"title": "戦犯指示コメ",
			"lines": [
				culprit,
				"死因：%s" % String(entry.get("deathText", ""))
			]
		},
		{
			"title": "記録日時",
			"lines": [String(entry.get("playedAt", ""))]
		}
	]
	var boss_text: String = _boss_detail_text(entry)
	if boss_text != "":
		cards.insert(4, {
			"title": "ボス結果",
			"lines": [boss_text]
		})
	return cards


static func _format_build_short(entry: Dictionary) -> String:
	var weapon_text: String = _equipment_summary(_safe_array(entry.get("weapons", [])), String(entry.get("weaponEquipmentText", "なし")))
	var accessory_text: String = _equipment_summary(_safe_array(entry.get("accessories", [])), String(entry.get("accessoryEquipmentText", "なし")))
	if accessory_text == "なし":
		return "武器 %s" % weapon_text
	return "武器 %s / アクセ %s" % [weapon_text, accessory_text]


static func _boss_detail_text(entry: Dictionary) -> String:
	if not bool(entry.get("bossSummoned", false)):
		return ""
	var boss_name: String = String(entry.get("bossName", "ボス"))
	var status: String = "撃破" if bool(entry.get("bossDefeated", false)) else ("撤退" if String(entry.get("bossResult", "")) == "retreated" else "出現")
	var reward: int = int(entry.get("bossRewardViewer", 0))
	if reward > 0:
		return "%s：%s / +%s人" % [boss_name, status, _format_number(reward)]
	return "%s：%s" % [boss_name, status]


static func _equipment_summary(items: Array, fallback: String) -> String:
	var names: Array[String] = []
	for item in items:
		if not (item is Dictionary):
			continue
		var data: Dictionary = item as Dictionary
		var name: String = String(data.get("displayName", data.get("id", "")))
		if name != "":
			names.append("%s %s" % [name, _equipment_level_label(data)])
	if not names.is_empty():
		return "、".join(names)
	if fallback.strip_edges() != "":
		return fallback
	return "なし"


static func _equipment_detail(items: Array) -> String:
	var lines: Array[String] = []
	for item in items:
		if not (item is Dictionary):
			continue
		var data: Dictionary = item as Dictionary
		var name: String = String(data.get("displayName", data.get("id", "")))
		if name != "":
			lines.append("%s %s" % [name, _equipment_level_label(data)])
	if lines.is_empty():
		return "なし"
	return "\n".join(lines)


static func _equipment_level_label(data: Dictionary) -> String:
	var label: String = String(data.get("levelLabel", ""))
	if label != "":
		return label
	if bool(data.get("isEvolved", false)):
		return "進化"
	return "Lv%d" % int(data.get("level", 1))


static func _character_nickname(entry: Dictionary) -> String:
	var id: String = _character_id(entry)
	if id == "ban_chan" or id == "banri":
		return "ばんちゃん"
	if id == "superchat_chan" or id == "supana":
		return "すぱなちゃん"
	if id == "maro_chan" or id == "maron":
		return "まろんちゃん"
	var name: String = String(entry.get("characterName", ""))
	if name == "赤羽ばんり":
		return "ばんちゃん"
	if name == "星投すぱな":
		return "すぱなちゃん"
	if name == "白綿まろん":
		return "まろんちゃん"
	if name != "":
		return name
	return "配信者"


static func _character_id(entry: Dictionary) -> String:
	var id: String = String(entry.get("characterId", "")).strip_edges()
	if id == "banri":
		return "ban_chan"
	if id == "supana":
		return "superchat_chan"
	if id == "maron":
		return "maro_chan"
	if id != "":
		return id
	var name: String = String(entry.get("characterName", "")).strip_edges()
	if name == "赤羽ばんり" or name == "ばんちゃん":
		return "ban_chan"
	if name == "星投すぱな" or name == "すぱなちゃん":
		return "superchat_chan"
	if name == "白綿まろん" or name == "まろんちゃん":
		return "maro_chan"
	return ""


static func _rank_position(entries: Array, entry: Dictionary) -> int:
	var run_id: String = String(entry.get("runId", ""))
	for index in range(entries.size()):
		var current_item: Variant = entries[index]
		if not (current_item is Dictionary):
			continue
		var current: Dictionary = current_item as Dictionary
		if run_id != "" and String(current.get("runId", "")) == run_id:
			return index + 1
		if _entry_is_same(current, entry):
			return index + 1
	return entries.size()


static func _ranking_scope_entries(entries: Array, stream_frame_id: String) -> Array:
	var frame_id := stream_frame_id.strip_edges()
	if frame_id == "":
		return entries
	var scoped_entries: Array = []
	for entry_item in entries:
		if not (entry_item is Dictionary):
			continue
		var entry: Dictionary = entry_item as Dictionary
		if String(entry.get("modeId", "")) != "normal_180":
			continue
		if String(entry.get("streamFrameId", "")) != frame_id:
			continue
		scoped_entries.append(entry)
	if scoped_entries.is_empty():
		return entries
	return _sort_entries(scoped_entries)


static func _ranking_scope_label(entry: Dictionary) -> String:
	var frame_name := String(entry.get("streamFrameName", "")).strip_edges()
	if frame_name == "":
		return "ランキング"
	return "%sランキング" % frame_name


static func _relay_rank_position(entries: Array, entry: Dictionary) -> int:
	var run_id: String = String(entry.get("runId", ""))
	for index in range(entries.size()):
		var current_item: Variant = entries[index]
		if not (current_item is Dictionary):
			continue
		var current: Dictionary = current_item as Dictionary
		if run_id != "" and String(current.get("runId", "")) == run_id:
			return index + 1
		if _relay_entry_is_same(current, entry):
			return index + 1
	return entries.size()


static func _entry_is_same(a: Dictionary, b: Dictionary) -> bool:
	return (
		_viewer_count(a) == _viewer_count(b)
		and String(a.get("playedAt", "")) == String(b.get("playedAt", ""))
		and String(a.get("characterId", "")) == String(b.get("characterId", ""))
	)


static func _relay_entry_is_same(a: Dictionary, b: Dictionary) -> bool:
	return (
		int(a.get("clearedFrameCount", 0)) == int(b.get("clearedFrameCount", 0))
		and int(a.get("maxViewerCount", 0)) == int(b.get("maxViewerCount", 0))
		and int(a.get("totalViewerCount", 0)) == int(b.get("totalViewerCount", 0))
		and String(a.get("playedAt", "")) == String(b.get("playedAt", ""))
		and String(a.get("characterId", "")) == String(b.get("characterId", ""))
	)


static func _entry_is_higher(a: Dictionary, b: Dictionary) -> bool:
	var score_a: int = _viewer_count(a)
	var score_b: int = _viewer_count(b)
	if score_a != score_b:
		return score_a > score_b
	var point_a: int = _god_point(a)
	var point_b: int = _god_point(b)
	if point_a != point_b:
		return point_a > point_b
	var a_rank: int = _rank_value(String(a.get("kamiRank", a.get("rank", "D"))))
	var b_rank: int = _rank_value(String(b.get("kamiRank", b.get("rank", "D"))))
	if a_rank != b_rank:
		return a_rank > b_rank
	var a_time: float = float(a.get("survivalTime", a.get("time", 0)))
	var b_time: float = float(b.get("survivalTime", b.get("time", 0)))
	if not is_equal_approx(a_time, b_time):
		return a_time > b_time
	var voltage_a: float = float(a.get("maxVoltage", a.get("maxMultiplier", 1.0)))
	var voltage_b: float = float(b.get("maxVoltage", b.get("maxMultiplier", 1.0)))
	if not is_equal_approx(voltage_a, voltage_b):
		return voltage_a > voltage_b
	return String(a.get("playedAt", "")) > String(b.get("playedAt", ""))


static func _relay_entry_is_higher(a: Dictionary, b: Dictionary) -> bool:
	var max_viewers_a: int = int(a.get("maxViewerCount", 0))
	var max_viewers_b: int = int(b.get("maxViewerCount", 0))
	if max_viewers_a != max_viewers_b:
		return max_viewers_a > max_viewers_b
	var cleared_a: int = int(a.get("clearedFrameCount", 0))
	var cleared_b: int = int(b.get("clearedFrameCount", 0))
	if cleared_a != cleared_b:
		return cleared_a > cleared_b
	var total_viewers_a: int = int(a.get("totalViewerCount", 0))
	var total_viewers_b: int = int(b.get("totalViewerCount", 0))
	if total_viewers_a != total_viewers_b:
		return total_viewers_a > total_viewers_b
	var voltage_a: float = float(a.get("maxVoltage", 1.0))
	var voltage_b: float = float(b.get("maxVoltage", 1.0))
	if not is_equal_approx(voltage_a, voltage_b):
		return voltage_a > voltage_b
	return String(a.get("playedAt", "")) > String(b.get("playedAt", ""))


static func _relay_progress_text(entry: Dictionary) -> String:
	var cleared_count: int = int(entry.get("clearedFrameCount", 0))
	if bool(entry.get("isRelayCompleted", false)):
		return "%d枠突破 / 完走" % cleared_count
	return "%d枠突破" % cleared_count


static func _relay_ended_reason_text(reason: String) -> String:
	if reason == "completed":
		return "完走"
	if reason == "interrupted":
		return "中断"
	if reason == "death":
		return "死亡"
	if reason != "":
		return reason
	return "死亡"


static func _rank_accent(index: int) -> Color:
	if index == 0:
		return Color("#f4b83f")
	if index == 1:
		return Color("#8fa2d4")
	if index == 2:
		return Color("#df8b3f")
	return Color("#8d6be8")


static func _rank_value(rank: String) -> int:
	return int(RANK_ORDER.get(rank, 0))


static func _viewer_count(entry: Dictionary) -> int:
	return int(entry.get("maxViewerCount", entry.get("viewerCount", entry.get("score", 0))))


static func _god_point(entry: Dictionary) -> int:
	return int(entry.get("godPoint", entry.get("kamiPoint", 0)))


static func _slice_items(items: Array, max_count: int) -> Array:
	if items.size() <= max_count:
		return items
	return items.slice(0, max_count)


static func _entry_end_type(entry: Dictionary) -> String:
	var end_type: String = String(entry.get("endType", "")).strip_edges()
	if end_type != "":
		return end_type
	if bool(entry.get("isRelayCompleted", false)) or String(entry.get("endedReason", "")) == "completed":
		return "completed"
	if String(entry.get("endedReason", "")) == "interrupted":
		return "relay_failed"
	if String(entry.get("modeId", "")) == "relay":
		return "relay_failed"
	if String(entry.get("deathText", "")).strip_edges() != "":
		return "mental_breakdown"
	return "completed"


static func _end_type_label(entry: Dictionary) -> String:
	var end_type: String = _entry_end_type(entry)
	if end_type == "completed":
		return "完走"
	if end_type == "mental_breakdown":
		return "崩壊"
	if end_type == "relay_failed" or end_type == "quit" or end_type == "debug":
		return "中断"
	return "記録"


static func _instruction_title(end_type: String) -> String:
	if end_type == "completed":
		return "配信ハイライト"
	if end_type == "relay_failed":
		return "中断時の指示コメ"
	return "戦犯指示コメ"


static func _instruction_lines(entry: Dictionary, end_type: String) -> Array[String]:
	var comment: String = String(entry.get("culpritInstructionComment", entry.get("lastInstructionComment", "なし"))).strip_edges()
	if comment == "" or comment == "<null>":
		comment = "なし"
	var death: String = String(entry.get("deathText", entry.get("deathReason", ""))).strip_edges()
	if end_type == "completed":
		if comment == "なし":
			comment = String(entry.get("lastInstructionComment", "最後まで走り切った！")).strip_edges()
		return [comment, "最後まで配信を走り切った記録です。"]
	if end_type == "relay_failed":
		if death == "":
			death = _relay_ended_reason_text(String(entry.get("endedReason", "")))
		return [comment, "中断理由：%s" % death]
	if death == "":
		death = "通常被弾でメンタル崩壊"
	return [comment, "死因：%s" % death]


static func _format_played_at(text: String) -> String:
	var value: String = text.strip_edges()
	if value == "":
		return "不明"
	value = value.replace("T", " ").replace("-", "/")
	if value.length() >= 16:
		return value.substr(0, 16)
	return value


static func _format_time(seconds: float) -> String:
	var total_seconds: int = int(seconds)
	var minutes: int = int(total_seconds / 60)
	var secs: int = total_seconds % 60
	return "%02d:%02d" % [minutes, secs]


static func _format_number(value: int) -> String:
	var text: String = str(value)
	var result: String = ""
	var count: int = 0
	for i in range(text.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = text.substr(i, 1) + result
		count += 1
	return result


static func _safe_array(value: Variant) -> Array:
	if value is Array:
		return value as Array
	return []


static func _string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if not (value is Array):
		return result
	for item in (value as Array):
		result.append(String(item))
	return result
