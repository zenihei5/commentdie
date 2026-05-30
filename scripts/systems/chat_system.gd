class_name ChatSystem
extends RefCounted

static func next_interval(state: String, kuso_chat_timer: float, rng: RandomNumberGenerator) -> float:
	var fast: bool = state == "comment_choice" or kuso_chat_timer > 0.0
	return rng.randf_range(0.15, 0.35) if fast else rng.randf_range(0.5, 1.0)

static func pool_for_state(state: String) -> Array[String]:
	if state == "comment_choice":
		return ["x10いけ", "全部やれ", "日和るな", "コメント欄を信じろ", "早く選べ"]
	if state == "gift_choice":
		return ["NG権取っとけ", "火力足りない", "回復しろｗ", "いいギフト"]
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
		return Color("#ff6a6a")
	if line.contains("ギフト") or line.contains("回復"):
		return Color("#8df7ff")
	if line.contains("草"):
		return Color("#b6ff62")
	return Color("#f3f0ff")

static func append_line(lines: Array[String], text: String, limit: int = 15) -> Array[String]:
	var result: Array[String] = lines.duplicate()
	result.append(text)
	while result.size() > limit:
		result.pop_front()
	return result

static func display_items(lines: Array[String]) -> Array:
	var items: Array = []
	for line in lines:
		items.append({
			"text": prefix(line) + " " + line,
			"color": color(line),
			"fontSize": 23
		})
	return items
