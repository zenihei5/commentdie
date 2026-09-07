class_name CodexMilestoneNotice
extends PanelContainer

const CommonLightUiStyleScript := preload("res://scripts/ui/common_light_ui_style.gd")

var _title_label: Label
var _body_label: Label
var _queue: Array[Dictionary] = []
var _timer := 0.0

func _ready() -> void:
	set_anchors_preset(Control.PRESET_CENTER_TOP)
	offset_left = -290.0
	offset_top = 118.0
	offset_right = 290.0
	offset_bottom = 198.0
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 80
	add_theme_stylebox_override("panel", CommonLightUiStyleScript.create_panel_style(Color(CommonLightUiStyleScript.PP_PALE, 0.97), CommonLightUiStyleScript.PP_GOLD, 2, 14, 12.0, 8.0))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 7)
	margin.add_theme_constant_override("margin_bottom", 7)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(margin)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 2)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(content)
	_title_label = Label.new()
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	CommonLightUiStyleScript.apply_font(_title_label, 18, true, CommonLightUiStyleScript.PP_TEXT)
	content.add_child(_title_label)
	_body_label = Label.new()
	_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_body_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	CommonLightUiStyleScript.apply_font(_body_label, 14, false, CommonLightUiStyleScript.TEXT_PRIMARY)
	content.add_child(_body_label)
	hide()

func _process(delta: float) -> void:
	if _timer <= 0.0:
		return
	_timer = maxf(0.0, _timer - delta)
	if _timer <= 0.0:
		hide()
		_show_next()

func show_milestones(category_label: String, milestones: Array, shop_unlocked: bool) -> void:
	if milestones.is_empty():
		return
	var percents: Array[String] = []
	var total_pp := 0
	for value in milestones:
		if not value is Dictionary:
			continue
		var milestone := value as Dictionary
		percents.append("%d%%" % int(milestone.get("percent", 0)))
		total_pp += int(milestone.get("pp", 0))
	if percents.is_empty() or total_pp <= 0:
		return
	_queue.append({"kind": "pp", "category": category_label, "percents": percents, "totalPp": total_pp, "shopUnlocked": shop_unlocked})
	if _timer <= 0.0:
		_show_next()

func show_customization_unlocks(item_count: int) -> void:
	var count := maxi(0, item_count)
	if count <= 0:
		return
	_queue.append({"kind": "customization", "itemCount": count})
	if _timer <= 0.0:
		_show_next()

func _show_next() -> void:
	if _queue.is_empty() or _title_label == null or _body_label == null:
		return
	var notice := _queue.pop_front() as Dictionary
	if String(notice.get("kind", "pp")) == "customization":
		var item_count := maxi(1, int(notice.get("itemCount", 0)))
		_title_label.text = "配信カスタム解禁！"
		_body_label.text = "新しい商品 %d件\n配信カスタムショップで確認できます" % item_count
		_timer = 2.8
		show()
		return
	var category := String(notice.get("category", "図鑑"))
	var percents: Array = notice.get("percents", []) as Array
	var percent_text := "・".join(percents)
	var total_pp := int(notice.get("totalPp", 0))
	_title_label.text = "図鑑マイルストーン達成！"
	if bool(notice.get("shopUnlocked", false)):
		_body_label.text = "%s %s達成\n配信図鑑から合計%d PP受取可能" % [category, percent_text, total_pp]
	else:
		_body_label.text = "%s %s達成\n配信ポイント解禁後、図鑑から合計%d PP受取可能" % [category, percent_text, total_pp]
	_timer = 2.8
	show()
