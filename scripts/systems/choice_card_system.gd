class_name ChoiceCardSystem
extends RefCounted

static func hidden_card() -> Dictionary:
	return {"text": "", "fill": Color("#11131c"), "border": Color("#49305f")}

static func ng_card(index: int) -> Dictionary:
	return {
		"text": "[%d]\nNG済み\n\n選択不可" % [index + 1],
		"fill": Color("#2b2b34"),
		"border": Color("#777777")
	}

static func comment_card(index: int, view: Dictionary, has_heart: bool, choice_timer: float, elapsed: float) -> Dictionary:
	var risk: int = int(view["riskLevel"])
	var border: Color = Color("#60a5ff")
	if risk == 3:
		border = Color("#b768ff")
	elif risk >= 4:
		border = Color("#ff3333")
	if choice_timer <= 5.0:
		border = Color("#ff3333").lightened(0.18 + sin(elapsed * 12.0) * 0.08)
	if has_heart:
		border = border.lightened(0.35)
	return {
		"text": "[%d]\n%s\n\n%s\n\nx%.1f\n期待度 +%d\n危険度 %d" % [
			index + 1,
			String(view["displayName"]),
			String(view["description"]),
			float(view["multiplier"]),
			int(view["giftHypeOnSelect"]),
			int(view["riskLevel"])
		],
		"fill": Color("#11131c"),
		"border": border
	}

static func gift_card(index: int, gift: Dictionary, gift_level: int) -> Dictionary:
	var rarity: String = String(gift["rarity"])
	return {
		"text": "[%d]\n%s\n%s\n\n%s\nLv %d/%d" % [
			index + 1,
			DisplayTextSystem.rarity_label(rarity),
			String(gift["displayName"]),
			String(gift["description"]),
			gift_level,
			int(gift["maxLevel"])
		],
		"fill": Color("#101720"),
		"border": DisplayTextSystem.rarity_color(rarity)
	}
