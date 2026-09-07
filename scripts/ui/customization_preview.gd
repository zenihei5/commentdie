class_name CustomizationPreview
extends Control

const CommonLightUiStyleScript := preload("res://scripts/ui/common_light_ui_style.gd")
const CustomizationProviderScript := preload("res://scripts/systems/customization_provider.gd")
const GameFontSystemScript := preload("res://scripts/systems/game_font_system.gd")

var _item: Dictionary = {}
var _status: Dictionary = {}
var _theme: Dictionary = {}

func configure(item: Dictionary, status: Dictionary, theme: Dictionary) -> void:
	_item = item.duplicate(true)
	_status = status.duplicate(true)
	_theme = theme.duplicate(true)
	queue_redraw()

func _draw() -> void:
	var rect := Rect2(Vector2(8.0, 8.0), size - Vector2(16.0, 16.0))
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return
	var fill: Color = _theme.get("decorativeFill", CommonLightUiStyleScript.MAIN_PANEL) as Color
	var border: Color = _theme.get("decorativeBorder", CommonLightUiStyleScript.LILAC_BORDER) as Color
	var accent: Color = _theme.get("decorativeAccent", CommonLightUiStyleScript.COMBAT_MAIN) as Color
	var secondary: Color = _theme.get("decorativeSecondary", CommonLightUiStyleScript.SUPPORT_MAIN) as Color
	var tertiary: Color = _theme.get("decorativeTertiary", Color("#a875e8")) as Color
	draw_style_box(_style(Color(fill, 0.94), border, 2, 20), rect)
	if bool(_theme.get("enabled", false)):
		draw_line(rect.position + Vector2(16.0, 16.0), rect.position + Vector2(rect.size.x - 16.0, 16.0), Color(accent, 0.80), 3.0, true)
		draw_line(rect.position + Vector2(16.0, rect.size.y - 16.0), rect.position + Vector2(rect.size.x - 16.0, rect.size.y - 16.0), Color(secondary, 0.72), 2.0, true)
		draw_circle(rect.position + Vector2(rect.size.x - 28.0, 28.0), 9.0, Color(tertiary, 0.30))
	var category := String(_item.get("category", ""))
	if category == "title":
		_draw_title_preview(rect, accent, secondary)
	elif category == "theme":
		_draw_theme_preview(rect, accent, secondary, tertiary)
	elif category == "result_stamp":
		_draw_stamp_preview(rect, String(_item.get("presentationId", _item.get("id", ""))), accent, secondary)

func _draw_title_preview(rect: Rect2, accent: Color, secondary: Color) -> void:
	var ribbon := Rect2(rect.position + Vector2(22.0, rect.size.y * 0.35), Vector2(rect.size.x - 44.0, 56.0))
	draw_style_box(_style(Color(accent, 0.16), accent, 2, 14), ribbon)
	draw_circle(ribbon.position + Vector2(22.0, 28.0), 8.0, Color(secondary, 0.75))
	var text := String(_item.get("displayName", "肩書き"))
	_draw_fitted(text, ribbon.position + Vector2(42.0, 36.0), ribbon.size.x - 58.0, 23, CommonLightUiStyleScript.TEXT_PRIMARY)
	draw_string(GameFontSystemScript.black_font(), rect.position + Vector2(22.0, 34.0), "装備プレビュー", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14, CommonLightUiStyleScript.TEXT_SECONDARY)

func _draw_theme_preview(rect: Rect2, accent: Color, secondary: Color, tertiary: Color) -> void:
	var compact := rect.size.y < 125.0
	var theme_inset := 16.0 if compact else 24.0
	var inner := rect.grow(-theme_inset)
	for index in range(3):
		var inset := float(index) * 7.0
		var color := accent if index == 0 else (secondary if index == 1 else tertiary)
		draw_style_box(_style(Color(color, 0.10 if index > 0 else 0.16), Color(color, 0.82), 2, 15), inner.grow(-inset))
	var title_size := 19 if compact else 25
	var title_baseline := inner.position.y + (27.0 if compact else inner.size.y * 0.54)
	var subtitle_baseline := title_baseline + float(title_size) + (7.0 if compact else 8.0)
	_draw_fitted(String(_item.get("displayName", "テーマ")), Vector2(inner.position.x + 18.0, title_baseline), inner.size.x - 36.0, title_size, Color(_theme.get("decorativeText", CommonLightUiStyleScript.TEXT_PRIMARY) as Color, 1.0))
	draw_string(GameFontSystemScript.regular_font(), Vector2(inner.position.x + 18.0, subtitle_baseline), "ショップ／リザルト装飾のみ", HORIZONTAL_ALIGNMENT_LEFT, inner.size.x - 36.0, 13, CommonLightUiStyleScript.TEXT_SECONDARY)

func _draw_stamp_preview(rect: Rect2, presentation_id: String, accent: Color, secondary: Color) -> void:
	var preset := CustomizationProviderScript.stamp_preset(presentation_id)
	var preset_accent: Color = preset.get("accent", accent) as Color
	var preset_secondary: Color = preset.get("secondary", secondary) as Color
	var motif := String(preset.get("motif", "bubble_star"))
	var compact := rect.size.y < 125.0
	var motif_rect := Rect2(rect.position + Vector2(16.0, 8.0), Vector2(maxf(48.0, rect.size.x - 32.0), maxf(30.0, rect.size.y - 40.0)))
	var center := motif_rect.get_center()
	match motif:
		"end_placard":
			var placard_width := minf(220.0, motif_rect.size.x)
			var placard := Rect2(Vector2(center.x - placard_width * 0.5, motif_rect.position.y + 2.0), Vector2(placard_width, maxf(24.0, motif_rect.size.y - 4.0)))
			draw_style_box(_style(Color(preset_secondary, 0.22), preset_accent, 3, 12), placard)
		"save_card":
			var card := motif_rect.grow(-2.0)
			draw_style_box(_style(Color(preset_secondary, 0.18), preset_accent, 3, 13), card)
			draw_rect(Rect2(card.position + Vector2(16.0, 8.0), Vector2(minf(54.0, card.size.x * 0.30), maxf(20.0, card.size.y - 16.0))), Color(preset_accent, 0.20), true)
			var play_center := card.position + Vector2(16.0 + minf(54.0, card.size.x * 0.30) * 0.5, card.size.y * 0.5)
			var play_icon := PackedVector2Array([
				play_center + Vector2(-10.0, -14.0),
				play_center + Vector2(14.0, 0.0),
				play_center + Vector2(-10.0, 14.0)
			])
			draw_colored_polygon(play_icon, Color(preset_accent, 0.86))
		"upward_star":
			var arrow_start := Vector2(motif_rect.position.x + 18.0, motif_rect.end.y - 4.0)
			var arrow_tip := Vector2(motif_rect.position.x + motif_rect.size.x * 0.54, motif_rect.position.y + 5.0)
			draw_line(arrow_start, arrow_tip, preset_accent, 6.0, true)
			draw_line(arrow_tip, arrow_tip + Vector2(-6.0, 17.0), preset_accent, 6.0, true)
			draw_line(arrow_tip, arrow_tip + Vector2(-18.0, 5.0), preset_accent, 6.0, true)
			_draw_star(Vector2(motif_rect.end.x - 34.0, motif_rect.position.y + 18.0), 17.0 if not compact else 12.0, preset_secondary)
		"comment_bubbles":
			var bubble_width := minf(118.0, motif_rect.size.x * 0.42)
			_draw_bubble(Vector2(motif_rect.position.x + motif_rect.size.x * 0.30, motif_rect.position.y + motif_rect.size.y * 0.62), Vector2(bubble_width, minf(46.0, motif_rect.size.y * 0.56)), preset_accent, "コメント")
			_draw_bubble(Vector2(motif_rect.position.x + motif_rect.size.x * 0.68, motif_rect.position.y + motif_rect.size.y * 0.32), Vector2(bubble_width, minf(46.0, motif_rect.size.y * 0.56)), preset_secondary, "ぜんぶ")
		_:
			_draw_bubble(Vector2(motif_rect.position.x + motif_rect.size.x * 0.42, center.y), Vector2(minf(172.0, motif_rect.size.x * 0.72), minf(58.0, motif_rect.size.y * 0.76)), preset_accent, "おつ配信！")
			_draw_star(Vector2(motif_rect.end.x - 26.0, motif_rect.position.y + 14.0), 17.0 if not compact else 11.0, preset_secondary)
	var label_rect := Rect2(rect.position + Vector2(16.0, rect.size.y - 29.0), Vector2(maxf(36.0, rect.size.x - 32.0), 23.0))
	var label_size := 20 if String(preset.get("motif", "")) == "save_card" else 18
	_draw_fitted(String(preset.get("label", "")), label_rect.position + Vector2(0.0, 18.0), label_rect.size.x, label_size, preset_accent.darkened(0.24))

func _draw_bubble(center: Vector2, bubble_size: Vector2, color: Color, text: String) -> void:
	var rect := Rect2(center - bubble_size * 0.5, bubble_size)
	draw_style_box(_style(Color(color, 0.16), color, 2, 12), rect)
	draw_colored_polygon(PackedVector2Array([rect.position + Vector2(20.0, rect.size.y), rect.position + Vector2(34.0, rect.size.y), rect.position + Vector2(26.0, rect.size.y + 12.0)]), Color(color, 0.78))
	_draw_fitted(text, rect.position + Vector2(8.0, rect.size.y * 0.62), rect.size.x - 16.0, 15, color.darkened(0.20))

func _draw_star(center: Vector2, radius: float, color: Color) -> void:
	var points := PackedVector2Array()
	for index in range(10):
		var angle := -PI * 0.5 + float(index) * PI / 5.0
		var value := radius if index % 2 == 0 else radius * 0.44
		points.append(center + Vector2(cos(angle), sin(angle)) * value)
	draw_colored_polygon(points, Color(color, 0.86))

func _draw_fitted(text: String, position: Vector2, width: float, desired_size: int, color: Color) -> void:
	var font := GameFontSystemScript.black_font()
	var size := desired_size
	while size > 11 and font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size).x > width:
		size -= 1
	draw_string(font, position, text, HORIZONTAL_ALIGNMENT_LEFT, width, size, color)

func _style(fill: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	return CommonLightUiStyleScript.create_panel_style(fill, border, width, radius, 10.0, 8.0)
