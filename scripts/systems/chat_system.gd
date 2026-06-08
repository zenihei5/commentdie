class_name ChatSystem
extends RefCounted

const GameFontSystemScript := preload("res://scripts/systems/game_font_system.gd")

static func next_interval(state: String, kuso_chat_timer: float, rng: RandomNumberGenerator) -> float:
	var fast: bool = state == "comment_choice" or kuso_chat_timer > 0.0
	return rng.randf_range(0.15, 0.35) if fast else rng.randf_range(0.5, 1.0)

static func pool_for_state(state: String) -> Array[String]:
	if state == "comment_choice":
		return ["x10いけ", "全部やれ", "日和るな", "コメント欄を信じろ", "早く選べ"]
	if state == "gift_choice":
		return ["♡取っとけ", "火力足りない", "回復しろｗ", "いいギフト"]
	if state == "result":
		return ["草", "これはコメントのせい", "切り抜き確定", "もう一回"]
	return ["草", "逃げろ", "今のうまい", "右いけ右", "ギフト欲しい"]

static func seed_lines(mode: String) -> Array[String]:
	if mode == "death":
		return ["草", "これはコメントのせい", "切り抜き確定", "もう一回"]
	return ["草", "逃げろ", "今のうまい", "右いけ右", "ギフト欲しい"]

static func marshmallow_pool(kind: String) -> Array[String]:
	if kind == "god":
		return ["神マロきた！", "これはでかい", "切り抜き確定", "運いいな"]
	if kind == "bad":
		return ["クソマロｗ", "ブロックしろ", "コメント欄終わった", "読まなきゃよかった"]
	if kind == "unread":
		return ["未読マロ来た", "マロ溜めるな", "逃げろ", "未読化したぞ"]
	return ["いいマロ", "拾ったのうまい", "助かる", "今のタイミングいい"]

static func random_marshmallow_line(kind: String, rng: RandomNumberGenerator) -> String:
	var pool: Array[String] = marshmallow_pool(kind)
	return pool[rng.randi_range(0, pool.size() - 1)]

static func update_timer(state: String, kuso_chat_timer: float, chat_timer: float, delta: float, rng: RandomNumberGenerator) -> Dictionary:
	var next_timer: float = chat_timer - delta
	if next_timer > 0.0:
		return {"timer": next_timer, "line": ""}
	next_timer = next_interval(state, kuso_chat_timer, rng)
	var pool: Array[String] = pool_for_state(state)
	return {
		"timer": next_timer,
		"line": pool[rng.randi_range(0, pool.size() - 1)]
	}

static func prefix(line: String) -> String:
	if line.contains("x10") or line.contains("全部"):
		return "!"
	if line.contains("ギフト") or line.contains("回復"):
		return "+"
	if line.contains("草"):
		return "ｗ"
	return ">"

static func color(line: String) -> Color:
	if line.contains("x10") or line.contains("全部"):
		return Color("#d81b3c")
	if line.contains("ギフト") or line.contains("回復"):
		return Color("#0097b8")
	if line.contains("草"):
		return Color("#42a800")
	return Color("#526174")

static func append_line(lines: Array[String], text: String, limit: int = 14) -> Array[String]:
	var result: Array[String] = lines.duplicate()
	result.append(text)
	while result.size() > limit:
		result.pop_front()
	return result

static func display_items(lines: Array[String]) -> Array:
	var items: Array = []
	var visible_lines: Array[String] = lines
	if visible_lines.size() > 11:
		visible_lines = visible_lines.slice(visible_lines.size() - 11, visible_lines.size())
	for line in visible_lines:
		items.append({
			"text": prefix(line) + " " + line,
			"color": color(line),
			"fontSize": 23
		})
	return items

static func refresh_box(chat_box: Control, lines: Array[String]) -> void:
	if chat_box == null:
		return
	for child in chat_box.get_children():
		child.queue_free()
	for item in display_items(lines):
		var view: Dictionary = item as Dictionary
		var label := Label.new()
		label.text = String(view["text"])
		GameFontSystemScript.apply_regular_font(label)
		label.add_theme_font_size_override("font_size", int(view["fontSize"]))
		label.add_theme_color_override("font_color", view["color"] as Color)
		label.custom_minimum_size = Vector2(280, 27)
		label.size = Vector2(280, 27)
		label.clip_text = true
		chat_box.add_child(label)

static func seed_box(chat_box: Control, mode: String) -> Array[String]:
	var lines: Array[String] = seed_lines(mode)
	refresh_box(chat_box, lines)
	return lines

static func seed_box_for_target(target: Node, chat_box: Control, mode: String) -> Array[String]:
	var lines: Array[String] = seed_box(chat_box, mode)
	target.set("chat_lines", lines)
	return lines

static func update_timer_for_target(target: Node, delta: float, rng: RandomNumberGenerator, chat_box: Control) -> Array[String]:
	var result: Dictionary = update_timer(
		String(target.get("state")),
		float(target.get("kuso_chat_timer")),
		float(target.get("chat_timer")),
		delta,
		rng
	)
	target.set("chat_timer", float(result["timer"]))
	var line: String = String(result["line"])
	var lines: Array[String] = []
	for item in target.get("chat_lines") as Array:
		lines.append(String(item))
	if line != "":
		lines = append_line(lines, line)
		refresh_box(chat_box, lines)
	target.set("chat_lines", lines)
	return lines

static func current_lines_for_target(target: Node) -> Array[String]:
	var lines: Array[String] = []
	for item in target.get("chat_lines") as Array:
		lines.append(String(item))
	return lines

static func push_line_for_target(target: Node, chat_box: Control, text: String) -> Array[String]:
	var lines: Array[String] = append_line(current_lines_for_target(target), text)
	target.set("chat_lines", lines)
	refresh_box(chat_box, lines)
	return lines

static func apply_feedback_for_target(target: Node, feedback: Dictionary, chat_box: Control, toast_seconds: float = 1.4) -> Array[String]:
	for toast in (feedback.get("toasts", []) as Array):
		target.set("toast_text", String(toast))
		target.set("toast_timer", toast_seconds)
	var chats: Array = feedback.get("chats", feedback.get("messages", [])) as Array
	var lines: Array[String] = current_lines_for_target(target)
	for maro_chat in (feedback.get("maroChatLines", []) as Array):
		lines = append_line(lines, String(maro_chat))
	for chat in chats:
		lines = append_line(lines, String(chat))
	target.set("chat_lines", lines)
	if not chats.is_empty() or not (feedback.get("maroChatLines", []) as Array).is_empty():
		refresh_box(chat_box, lines)
	return lines
