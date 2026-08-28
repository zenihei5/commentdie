extends Node

const CodexScreenScript := preload("res://scripts/ui/codex_screen.gd")

var failures: Array[String] = []
var screen: Control

func _ready() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	CodexManager.initialize_empty()
	screen = CodexScreenScript.new()
	screen.name = "CodexScreenTestInstance"
	screen.size = Vector2(1600, 900)
	add_child(screen)
	await get_tree().process_frame
	CodexManager.discover(CodexManager.CATEGORY_WEAPON, "ban_hammer")
	CodexManager.discover(CodexManager.CATEGORY_ACCESSORY, "stream_power")
	screen.open_screen("title", {})
	await get_tree().process_frame
	screen._category_index = 1
	screen._selected_ids[CodexManager.CATEGORY_WEAPON] = "ban_hammer"
	screen._refresh(false, false)
	await get_tree().process_frame
	_check(screen._item_profile_content.visible, "discovered weapon uses structured item content")
	_check(not screen._detail_body.visible and not screen._detail_image_frame.visible, "weapon generic body and fixed visual are hidden")
	_check(screen._character_unit_badge.visible and String(screen._character_unit_badge_label.text) == "初期武器", "weapon classification badge is shown")
	_check(screen._item_archive_card.visible and String(screen._item_archive_card.get_meta("character_card_heading", null).text) == "WEAPON ARCHIVE", "weapon archive card is visible")
	_check(String(screen._item_game_data_card.get_meta("character_card_body", null).text).contains("LEVEL"), "weapon game data remains after lore")
	_check(screen._item_visual_holder.get_child_count() == 1, "weapon uses the dedicated visual holder")

	screen._category_index = 2
	screen._selected_ids[CodexManager.CATEGORY_ACCESSORY] = "stream_power"
	screen._refresh(false, false)
	await get_tree().process_frame
	_check(screen._item_profile_content.visible, "discovered accessory uses the same structured item content")
	_check(String(screen._character_unit_badge_label.text) == "アクセサリ", "accessory classification badge is derived")
	_check(String(screen._item_archive_card.get_meta("character_card_heading", null).text) == "ITEM NOTE", "accessory archive title is ITEM NOTE")
	_check(not screen._character_profile_content.visible, "character cards are hidden for accessory")

	screen._category_index = 0
	screen._selected_ids[CodexManager.CATEGORY_CHARACTER] = "ban_chan"
	screen._refresh(false, false)
	await get_tree().process_frame
	_check(screen._character_profile_content.visible and not screen._item_profile_content.visible, "character switches back without item cards")
	_check(String(screen._character_unit_badge_label.text) == "初期メンバー", "character unit badge is restored")

	CodexManager.initialize_empty()
	screen._category_index = 1
	screen._selected_ids[CodexManager.CATEGORY_WEAPON] = "starlight_superchat"
	screen._refresh(false, false)
	await get_tree().process_frame
	_check(not screen._item_profile_content.visible and screen._detail_body.visible, "undiscovered weapon uses masked generic detail")
	_check(screen._item_visual_holder.get_child_count() == 0 and screen._character_unit_badge.visible == false, "undiscovered item clears stale lore image and badge")

	if failures.is_empty():
		print("CODEX_ITEM_LORE_UI_V1_TESTS: PASS")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("CODEX_ITEM_LORE_UI_V1_TESTS: FAIL (%d)" % failures.size())
	get_tree().quit(1)

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
