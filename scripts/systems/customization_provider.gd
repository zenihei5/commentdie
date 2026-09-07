class_name CustomizationProvider
extends RefCounted

## V1 deliberately exposes decoration-only values.  Callers outside the
## customization shop and result band should not consume this provider.

static func theme_preset(theme_id: String) -> Dictionary:
	var id := theme_id.strip_edges()
	match id:
		"theme_neon_pink":
			return _theme(id, Color("#fff1fa"), Color("#f05aa5"), Color("#ff9fca"), Color("#ffd3e9"), Color("#8b3d70"), Color("#8de7ff"), Color("#c7a6ff"))
		"theme_cyan_light":
			return _theme(id, Color("#effcff"), Color("#42bfd2"), Color("#76e7ef"), Color("#c7f6f8"), Color("#276071"), Color("#ff8fc2"), Color("#bfe7ff"))
		"theme_lavender_night":
			return _theme(id, Color("#f5f0ff"), Color("#9b76d6"), Color("#c5a8ff"), Color("#e1d5ff"), Color("#573c7b"), Color("#66deef"), Color("#f1b6e1"))
		"theme_live_gold":
			return _theme(id, Color("#fff9e6"), Color("#d89b28"), Color("#ffc857"), Color("#ffe8a8"), Color("#765319"), Color("#ef83b6"), Color("#fff0b0"))
		"theme_complete_neon":
			return _theme(id, Color("#effcff"), Color("#ef5fb1"), Color("#66def4"), Color("#d0f8ff"), Color("#5d3d86"), Color("#ef5fb1"), Color("#a875ff"))
		_:
			return {
				"id": "",
				"enabled": false,
				"decorativeBorder": Color("#ead7e9"),
				"decorativeAccent": Color("#f05aa5"),
				"decorativeGlow": Color("#ffd2e5"),
				"decorativeSecondary": Color("#8de7ff"),
				"decorativeTertiary": Color("#a875e8"),
				"decorativeFill": Color("#ffffff"),
				"decorativeText": Color("#4f3149")
			}

static func _theme(id: String, fill: Color, border: Color, accent: Color, glow: Color, text: Color, secondary: Color, tertiary: Color) -> Dictionary:
	return {
		"id": id,
		"enabled": true,
		"decorativeBorder": border,
		"decorativeAccent": accent,
		"decorativeGlow": glow,
		"decorativeSecondary": secondary,
		"decorativeTertiary": tertiary,
		"decorativeFill": fill,
		"decorativeText": text
	}

static func stamp_preset(presentation_id: String) -> Dictionary:
	match presentation_id.strip_edges():
		"stamp_otsu_stream":
			return {"motif": "bubble_star", "accent": Color("#ef6aaf"), "secondary": Color("#ffcf68"), "label": "おつ配信！"}
		"stamp_stream_end":
			return {"motif": "end_placard", "accent": Color("#43bfd2"), "secondary": Color("#b9f1f3"), "label": "配信終了！"}
		"stamp_archive":
			return {"motif": "save_card", "accent": Color("#9b76d6"), "secondary": Color("#dfd0ff"), "label": "アーカイブ残します"}
		"stamp_viral":
			return {"motif": "upward_star", "accent": Color("#ef8e3a"), "secondary": Color("#ffd86b"), "label": "バズった！"}
		"stamp_commentdie":
			return {"motif": "comment_bubbles", "accent": Color("#ef5fb1"), "secondary": Color("#66def4"), "label": "ぜんぶコメントのせいだ"}
		_:
			return {"motif": "bubble_star", "accent": Color("#f05aa5"), "secondary": Color("#ffd46a"), "label": ""}

static func category_slot(category: String) -> String:
	return "resultStamp" if category.strip_edges().to_lower() == "result_stamp" else category.strip_edges().to_lower()

static func category_label(category: String) -> String:
	match category.strip_edges().to_lower():
		"title": return "肩書き"
		"theme": return "テーマ"
		"result_stamp": return "スタンプ"
		_: return category

static func category_label_from_codex(category: String) -> String:
	match category.strip_edges().to_lower():
		"characters": return "キャラクター図鑑"
		"weapons": return "武器図鑑"
		"accessories": return "アクセサリー図鑑"
		"enemies": return "敵図鑑"
		"comments": return "指示コメ図鑑"
		_: return category
