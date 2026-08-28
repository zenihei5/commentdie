extends Node

const Presentation := preload("res://scripts/systems/codex_presentation_system.gd")
const WeaponSystemScript := preload("res://scripts/systems/weapon_system.gd")
const GiftSystemScript := preload("res://scripts/systems/gift_system.gd")
const DifficultyProgressSystemScript := preload("res://scripts/systems/difficulty_progress_system.gd")

const INITIAL_WEAPON_IDS: Array[String] = ["ban_hammer", "superchat_shot", "comment_boomerang", "moderator_shield", "fansa_baton", "tsuri_thumbnail_rod"]
const KNOWN_COMMENT_TAGS: Array[String] = ["敵強化", "ボス", "プレイヤー制限", "配信イベント", "ゲームジャンル", "歌", "お絵かき", "コラボ", "HARD", "特殊", "SPECIAL"]

var failures: Array[String] = []

func _ready() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	CodexManager.initialize_empty()
	_check(DifficultyProgressSystemScript.SAVE_VERSION == 6, "outer save schema includes unlock presentation state")
	var weapons: Array = CodexManager.get_master_entries(CodexManager.CATEGORY_WEAPON)
	var accessories: Array = CodexManager.get_master_entries(CodexManager.CATEGORY_ACCESSORY)
	var characters: Array = CodexManager.get_master_entries(CodexManager.CATEGORY_CHARACTER)
	var comments: Array = CodexManager.get_master_entries(CodexManager.CATEGORY_COMMENT)
	_check(weapons.size() == 26, "effective weapon master has 26 entries")
	_check(accessories.size() == 10, "effective accessory master has 10 entries")
	_check(characters.size() == 6, "character master has 6 entries")
	_check(comments.size() == 44, "comment master has 44 entries")

	_test_weapon_models(weapons)
	_test_accessory_models(accessories)
	_test_comment_models(comments)
	_test_character_profiles(characters)
	_test_collection()

	if failures.is_empty():
		print("CODEX_V04_CONTENT_TESTS: PASS")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("CODEX_V04_CONTENT_TESTS: FAIL (%d)" % failures.size())
	get_tree().quit(1)

func _test_weapon_models(weapons: Array) -> void:
	for weapon_value in weapons:
		if not weapon_value is Dictionary:
			continue
		var weapon: Dictionary = weapon_value as Dictionary
		var stats_value: Variant = weapon.get("codexStats", [])
		_check(stats_value is Array and not (stats_value as Array).is_empty(), "weapon has codexStats: %s" % String(weapon.get("id", "")))
		var seen: Dictionary = {}
		if stats_value is Array:
			for stat_value in stats_value as Array:
				var stat_key := String(stat_value)
				_check(not seen.has(stat_key), "weapon codexStats has no duplicate: %s/%s" % [String(weapon.get("id", "")), stat_key])
				seen[stat_key] = true
				_check(Presentation.STAT_META.has(stat_key), "weapon codexStats uses known key: %s/%s" % [String(weapon.get("id", "")), stat_key])
		var model := Presentation.weapon_performance_model(weapon, INITIAL_WEAPON_IDS.has(String(weapon.get("id", ""))))
		if bool(weapon.get("isEvolved", false)):
			_check((model.get("levelRows", []) as Array).is_empty(), "evolved weapon has no LEVEL rows: %s" % String(weapon.get("id", "")))
		else:
			_check((model.get("levelRows", []) as Array).size() == maxi(1, int(weapon.get("maxLevel", 1))), "normal weapon has maxLevel rows: %s" % String(weapon.get("id", "")))
		_check(not bool(model.get("missing", false)), "weapon has at least one resolved performance value: %s" % String(weapon.get("id", "")))
		_check(not model.has("riskLevel"), "weapon performance model has no unrelated risk data")

	var ban := _find(weapons, "ban_hammer")
	var ban_level_one := WeaponSystemScript.codex_standard_stats_for_level(ban, 1, true)
	var ban_level_five := WeaponSystemScript.codex_standard_stats_for_level(ban, 5, true)
	_check(is_equal_approx(float(ban_level_one.get("damage", 0.0)), 12.0), "BAN hammer standard Lv1 damage is runtime-derived")
	_check(is_equal_approx(float(ban_level_one.get("range", 0.0)), 185.625), "BAN hammer standard Lv1 range is runtime-derived")
	_check(is_equal_approx(float(ban_level_one.get("attackInterval", 0.0)), 0.85), "BAN hammer standard Lv1 interval is runtime-derived")
	_check(is_equal_approx(float(ban_level_five.get("damage", 0.0)), 16.8), "BAN hammer standard Lv5 damage is runtime-derived")
	_check(is_equal_approx(float(ban_level_five.get("range", 0.0)), 245.025), "BAN hammer standard Lv5 range is runtime-derived")
	_check(absf(float(ban_level_five.get("attackInterval", 0.0)) - 0.6636) < 0.001, "BAN hammer standard Lv5 interval is runtime-derived")
	var kusa_expectations: Array = [
		{"damage": 5.0, "interval": 1.40, "distance": 900.0, "size": 1.00, "bounces": 1},
		{"damage": 7.0, "interval": 1.35, "distance": 1200.0, "size": 1.10, "bounces": 2},
		{"damage": 8.0, "interval": 1.30, "distance": 1550.0, "size": 1.25, "bounces": 3},
		{"damage": 10.0, "interval": 1.25, "distance": 1950.0, "size": 1.40, "bounces": 4},
		{"damage": 12.0, "interval": 1.20, "distance": 2400.0, "size": 1.55, "bounces": 5}
	]
	for index in range(kusa_expectations.size()):
		var expected: Dictionary = kusa_expectations[index] as Dictionary
		var kusa := WeaponSystemScript.codex_standard_stats_for_level(_find(weapons, "kusa_wave"), index + 1, false)
		_check(is_equal_approx(float(kusa.get("damage", 0.0)), float(expected["damage"])), "kusa Lv%d damage uses runtime table" % (index + 1))
		_check(is_equal_approx(float(kusa.get("attackInterval", 0.0)), float(expected["interval"])), "kusa Lv%d interval uses runtime table" % (index + 1))
		_check(is_equal_approx(float(kusa.get("range", 0.0)), float(expected["distance"])), "kusa Lv%d distance uses runtime table" % (index + 1))
		_check(is_equal_approx(float(kusa.get("sizeMultiplier", 0.0)), float(expected["size"])), "kusa Lv%d size uses runtime table" % (index + 1))
		_check(int(kusa.get("bounceCount", 0)) == int(expected["bounces"]), "kusa Lv%d bounces use runtime table" % (index + 1))
	var incomplete := Presentation.weapon_performance_model({"id": "unknown", "maxLevel": 3, "codexStats": ["unknownStat", "damage"], "damage": 4.0, "attackInterval": 1.0, "range": 2.0}, false)
	_check(not incomplete.is_empty(), "unknown weapon stat does not crash resolver")

func _test_accessory_models(accessories: Array) -> void:
	for accessory_value in accessories:
		if not accessory_value is Dictionary:
			continue
		var accessory: Dictionary = accessory_value as Dictionary
		var stats_value: Variant = accessory.get("codexStats", [])
		_check(stats_value is Array and not (stats_value as Array).is_empty(), "accessory has codexStats: %s" % String(accessory.get("id", "")))
		var model := Presentation.accessory_performance_model(accessory)
		_check((model.get("levelRows", []) as Array).size() == maxi(1, int(accessory.get("maxLevel", 1))), "accessory uses its real maxLevel: %s" % String(accessory.get("id", "")))
		_check(not bool(model.get("missing", false)), "accessory has at least one resolved performance value: %s" % String(accessory.get("id", "")))
	var high_speed := GiftSystemScript.codex_accessory_stats_for_level(_find(accessories, "high_speed_connection"), 5)
	_check(is_equal_approx(float(high_speed.get("attackIntervalMultiplier", 0.0)), pow(0.92, 5.0)), "high speed connection is cumulative")
	var sweet := GiftSystemScript.codex_accessory_stats_for_level(_find(accessories, "sweet_tooth"), 3)
	_check(is_equal_approx(float(sweet.get("goodEffectMultiplier", 0.0)), 1.45), "sweet tooth merit rate uses MarshmallowSystem")
	_check(is_equal_approx(float(sweet.get("kusoDurationMultiplier", 0.0)), 0.35), "sweet tooth duration floor uses MarshmallowSystem")
	_check(int(_find(accessories, "mini_humidifier").get("maxLevel", 0)) == 3, "humidifier maxLevel is three")
	var humidifier := GiftSystemScript.codex_accessory_stats_for_level(_find(accessories, "mini_humidifier"), 3)
	_check(is_equal_approx(float(humidifier.get("healInterval", 0.0)), 6.0) and int(humidifier.get("healAmount", 0)) == 6, "humidifier Lv3 uses runtime values")

func _test_comment_models(comments: Array) -> void:
	for comment_value in comments:
		if not comment_value is Dictionary:
			continue
		var comment: Dictionary = comment_value as Dictionary
		var model := Presentation.comment_effect_model(comment)
		var normal: Dictionary = model.get("normal", {}) as Dictionary
		_check(not normal.is_empty(), "comment has a normal effect model: %s" % String(comment.get("id", "")))
		_check(String(normal.get("description", "")).strip_edges() != "", "comment effect has description fallback: %s" % String(comment.get("id", "")))
		var tags: Array = model.get("tags", []) as Array
		for tag_value in tags:
			_check(KNOWN_COMMENT_TAGS.has(String(tag_value)), "comment tag is from known vocabulary: %s/%s" % [String(comment.get("id", "")), String(tag_value)])
		_check(not JSON.stringify(model).contains("riskLevel"), "comment model does not expose risk level: %s" % String(comment.get("id", "")))
	var short_range := Presentation.comment_effect_model(_find(comments, "short_range"))
	_check(not (short_range.get("heart", {}) as Dictionary).is_empty(), "explicit heartVariant produces heart model")
	var hard := Presentation.comment_effect_model(_find(comments, "hard_overclock"))
	_check(hard.get("hard", {}) is Dictionary and not (hard.get("hard", {}) as Dictionary).is_empty(), "HARD override gets separate model")
	var special := Presentation.comment_effect_model(_find(comments, "do_everything"))
	_check((special.get("normal", {}) as Dictionary).get("lines", []) is Array, "do_everything uses generic objective note")

func _test_character_profiles(characters: Array) -> void:
	var weapons := CodexManager.get_master_entries(CodexManager.CATEGORY_WEAPON)
	var sources := Presentation.load_sources()
	var unit_master := _read_array("res://data/character_units.json")
	_check(unit_master.size() == 2, "character unit master contains rookie and senior units")
	var rookie_unit := _find(unit_master, "rookie_unit")
	_check(String(rookie_unit.get("id", "")) == "rookie_unit", "character unit master contains rookie_unit")
	_check(String(rookie_unit.get("displayName", "")) == "初期メンバー" and String(rookie_unit.get("codexDescription", "")).contains("配信の進め方もコメントへの対応も手探り"), "rookie unit master keeps the canonical shared introduction")
	var senior_unit := _find(unit_master, "senior_unit")
	_check(String(senior_unit.get("id", "")) == "senior_unit", "character unit master contains senior_unit")
	_check(String(senior_unit.get("displayName", "")) == "先輩メンバー", "senior unit master uses the canonical display name")
	_check(not senior_unit.has("codexDescription") or String(senior_unit.get("codexDescription", "")) == "", "senior unit has no invented shared description")
	var expected_profiles := {
		"ban_chan": {
			"description": "思ったことが顔や声にすぐ出る、明るく行動力のある新人配信者。\n\n少し慌てやすく、音声設定を間違えたり、画面を切り替え忘れたりと、配信に慣れていないことが原因の失敗もまだ多い。なかでも配信を終了したつもりで消し忘れ、そのまま一人反省会を始めてしまったことは何度かある。\n\n本人は事故のたびに落ち込むものの、引きずるよりも次の配信で取り返そうとするタイプ。困っている仲間を放っておけない面倒見のよさもあり、勢い任せに見えて意外と周囲のことをよく見ている。\n\n荒れたコメント欄を放っておけない性格もあって、BANハンマーはいつしか彼女を象徴する道具になった。",
			"streamStyle": "勢いとリアクションを大切にする、にぎやかな配信が中心。細かく計画を立てるより、その場の流れに乗って進めることが多い。",
			"likes": ["にぎやかなコメント欄", "分かりやすい勝負", "頼られること"],
			"dislikes": ["細かい設定確認", "回りくどいやり取り", "気まずい空気"]
		},
		"superchat_chan": {
			"description": "好奇心が強く、面白そうなものにはすぐ飛びつく新人配信者。\n\nお金が好きなことを隠す気がなく、スパチャが届けば素直に喜び、収益や数字の話も遠慮なく口にする。その正直さは彼女らしい魅力でもあるが、ときどき発言が少し過激になり、運営から注意されることもある。\n\n本人に悪気はなく、応援が目に見える形で届くことが純粋にうれしいらしい。企画を思いつく速度は速い一方、細かな準備は配信を始めてから考えることも多く、予定どおりに進まない状況すら楽しんでいる節がある。\n\nスパチャ弾は、そんな彼女がリスナーから受け取った応援をそのまま力に変えたものだと言われている。",
			"streamStyle": "新しい企画や派手な演出を好み、見てすぐ分かる盛り上がりを大切にする。数字の変化にもよく気がつく。",
			"likes": ["お金", "スパチャ", "新しい機材", "景気のいい数字"],
			"dislikes": ["地味な展開", "成果の分かりにくい作業", "運営からの注意連絡"]
		},
		"maro_chan": {
			"description": "大人しく柔らかな印象を持たれやすいが、自分の考えをしっかり持っている新人配信者。\n\n普段は穏やかな受け答えが多く、以前の配信で話した小さな内容まで覚えていることもある。争いごとを好むわけではないが、納得できない言葉まで笑って受け流すタイプではない。\n\n特に悪意のあるクソマロには、柔らかな口調のまま辛辣な返しをすることがある。その普段との落差がリスナーに受け、クソマロを読む場面だけを楽しみにしている視聴者も少なくない。\n\n本人は面白いことを言おうとしているのではなく、筋の通らない言葉へ率直に答えているだけらしい。コメントブーメランも、投げかけた言葉が相手へ返っていく彼女の配信スタイルを象徴している。",
			"streamStyle": "穏やかな空気でリスナーと話す、ゆったりした配信が中心。コメントを丁寧に拾いながら、自分のペースで進めていく。",
			"likes": ["甘いもの", "かわいい小物", "落ち着いた雑談", "礼儀のあるコメント"],
			"dislikes": ["急かされること", "悪意を善意のように装った言葉", "誰かを傷つけて楽しむこと"]
		}
	}
	for character_value in characters:
		var character: Dictionary = character_value as Dictionary
		var profile_value: Variant = character.get("codexProfile", {})
		_check(profile_value is Dictionary and String((profile_value as Dictionary).get("description", "")).strip_edges() != "", "character has codexProfile description: %s" % String(character.get("id", "")))
		var model := Presentation.character_profile_model(character, weapons, [], true, sources)
		_check(String(model.get("description", "")).strip_edges() != "", "character presentation uses profile description: %s" % String(character.get("id", "")))
		var character_id := String(character.get("id", ""))
		if expected_profiles.has(character_id):
			var expected: Dictionary = expected_profiles[character_id] as Dictionary
			_check(String(model.get("description", "")) == String(expected.get("description", "")), "character profile description is canonical: %s" % character_id)
			_check(String(model.get("streamStyle", "")) == String(expected.get("streamStyle", "")), "character stream style is canonical: %s" % character_id)
			_check((model.get("likes", []) as Array) == (expected.get("likes", []) as Array), "character likes preserve order: %s" % character_id)
			_check((model.get("dislikes", []) as Array) == (expected.get("dislikes", []) as Array), "character dislikes preserve order: %s" % character_id)
			_check(not String(model.get("likesText", "")).contains("。。") and String(model.get("likesText", "")).ends_with("。"), "character likes text has one natural final punctuation: %s" % character_id)
			_check(not String(model.get("dislikesText", "")).contains("。。") and String(model.get("dislikesText", "")).ends_with("。"), "character dislikes text has one natural final punctuation: %s" % character_id)
			_check(String(model.get("unitDisplayName", "")) == "初期メンバー", "character uses the shared rookie unit name: %s" % character_id)
			_check(String(model.get("unitDescription", "")).contains("ほぼ同じ時期にデビューした"), "character uses the shared rookie unit description: %s" % character_id)
			var copied_likes: Array = model.get("likes", []) as Array
			if not copied_likes.is_empty():
				copied_likes[0] = "変更テスト"
			var fresh_model := Presentation.character_profile_model(character, weapons, [], true, sources)
			_check(String((fresh_model.get("likes", []) as Array).front()) == String((expected.get("likes", []) as Array).front()), "character profile arrays are copied defensively: %s" % character_id)
	var expected_senior_profiles := {
		"aosumi_kyasumi": {
			"description": "冷静で落ち着いており、何か起きてもまず状況を整理しようとするタイプの配信者。\n\nコメント欄の変化にもかなり敏感で、荒れそうな流れや危ない空気を早い段階で察知することが多い。そのため、リスナーからは「本人が一番早く異変に気づく」と言われることもある。\n\n真面目で少し堅く見られがちだが、配信そのものを大切にしている気持ちは人一倍強い。誰かが安心して見られる空間を保ちたいという意識が強く、それがそのまま彼女の立ち回りにも表れている。\n\nモデレーターシールドは、自分のためというより配信全体を守るための道具として扱っているらしい。",
			"streamStyle": "落ち着いた進行と丁寧なコメント対応を得意とする、安定感のある配信が中心。大きく盛り上げるというより、配信全体をきれいに整えるのがうまい。",
			"likes": ["整理された環境", "静かな時間", "ルールが守られているコメント欄"],
			"dislikes": ["突発的なトラブル", "場の空気を乱す言動", "説明を読まない人"]
		},
		"akarine_rizumu": {
			"description": "見ている側まで元気になりそうな勢いを持つ、明るくエネルギッシュな配信者。\n\n考えるより先に体が動くタイプで、テンションが上がるとそのまま勢いで押し切ってしまうことも多い。ただ、その勢いが配信の空気を前向きに引っ張っていく場面も多く、本人の明るさそのものが武器になっている。\n\n視聴者へ反応を返すのが好きで、コメントに答えるだけでなく、その場で急にファンサを始めることも珍しくない。配信を「一緒に盛り上がる場」として考えている節が強く、見ている相手を置いていかないのが彼女らしさでもある。\n\nファンサバトンは、もともとはステージを盛り上げるための小道具だったらしいが、今では本人の手にすっかりなじんでいる。",
			"streamStyle": "テンション高めで、リアクションやファンサを交えながら進めるライブ感の強い配信が中心。止まっている時間を作らず、常に何かしら動いていることが多い。",
			"likes": ["ライブ感", "ファンサ", "拍手や反応", "身体を動かすこと"],
			"dislikes": ["静かすぎる空気", "長い待ち時間", "反応の薄い場面"]
		},
		"shizuki_miimu": {
			"description": "どこまで本気で、どこまで冗談なのか少し分かりにくい、つかみどころのない配信者。\n\n人の反応を見るのが好きで、タイトルやサムネイルにもつい工夫を入れたがる。少し煽るような見せ方をすることもあるが、本気で相手を困らせたいわけではなく、最終的には「見に来てよかった」と思ってもらうところまで含めて配信だと考えているらしい。\n\nいたずらっぽい印象を持たれやすい一方で、配信の見せ方についてはかなり計算しているところがあり、何が気になってもらえるか、どこで引きつけるかをよく考えている。軽く見えて、実はかなり手強いタイプ。\n\n釣りサムネロッドについて尋ねられると毎回答えが少し違うが、少なくとも人を惹きつけるための道具であることだけは確からしい。",
			"streamStyle": "企画や見せ方にひとひねり加えるのが得意で、リスナーの反応を見ながら空気を転がしていくタイプ。少し怪しげな導入や、気になる見せ方を好む。",
			"likes": ["面白い反応", "予想外の展開", "変わった企画", "目を引くサムネイル"],
			"dislikes": ["予定調和", "印象の薄い配信", "反応のない空気"]
		}
	}
	for senior_id_value in expected_senior_profiles.keys():
		var senior_id := String(senior_id_value)
		var senior_character := _find(characters, senior_id)
		var expected_senior: Dictionary = expected_senior_profiles[senior_id] as Dictionary
		var senior_model := Presentation.character_profile_model(senior_character, weapons, [], true, sources)
		_check(String(senior_model.get("description", "")) == String(expected_senior.get("description", "")), "senior profile description is canonical: %s" % senior_id)
		_check(String(senior_model.get("streamStyle", "")) == String(expected_senior.get("streamStyle", "")), "senior stream style is canonical: %s" % senior_id)
		_check((senior_model.get("likes", []) as Array) == (expected_senior.get("likes", []) as Array), "senior likes preserve order: %s" % senior_id)
		_check((senior_model.get("dislikes", []) as Array) == (expected_senior.get("dislikes", []) as Array), "senior dislikes preserve order: %s" % senior_id)
		_check(String(senior_model.get("unitDisplayName", "")) == "先輩メンバー", "senior profile uses the shared unit name: %s" % senior_id)
		_check(String(senior_model.get("unitDescription", "")) == "", "senior profile has no invented shared description: %s" % senior_id)
		_check(not String(senior_model.get("description", "")).contains("**"), "senior profile does not expose markdown markers: %s" % senior_id)
		_check(not String(senior_model.get("likesText", "")).contains("。。") and String(senior_model.get("likesText", "")).ends_with("。"), "senior likes text has one natural final punctuation: %s" % senior_id)
		_check(not String(senior_model.get("dislikesText", "")).contains("。。") and String(senior_model.get("dislikesText", "")).ends_with("。"), "senior dislikes text has one natural final punctuation: %s" % senior_id)
	var missing_model := Presentation.character_profile_model({"id": "missing", "unitId": "unknown_unit", "initialWeapon": "ban_hammer"}, weapons, [], true, sources)
	_check(String(missing_model.get("unitDisplayName", "")) == "" and String(missing_model.get("streamStyle", "")) == "" and (missing_model.get("likes", []) as Array).is_empty(), "missing character profile sections fall back safely")
	var hidden_model := Presentation.character_profile_model(_find(characters, "ban_chan"), weapons, [], false, sources)
	_check(String(hidden_model.get("unitDisplayName", "")) == "" and String(hidden_model.get("description", "")) == "" and (hidden_model.get("likes", []) as Array).is_empty(), "undiscovered character profile stays masked")

func _test_collection() -> void:
	CodexManager.initialize_empty()
	var initial := CodexManager.get_collection_summary()
	_check(int(initial.get("total", 0)) == 84, "collection total is four current categories")
	var initial_comment_log: Dictionary = initial.get("commentLog", {}) as Dictionary
	_check(int(initial_comment_log.get("total", 0)) == 44, "comment log remains separate")
	_check(not bool(initial.get("completed", false)), "initial collection is incomplete")
	var before_comment_discovery_found := int(initial.get("found", 0))
	CodexManager.discover_comment("banana_floor")
	var after_comment_discovery := CodexManager.get_collection_summary()
	_check(int(after_comment_discovery.get("found", 0)) == before_comment_discovery_found, "comment discoveries do not enter collection total")
	for category in [CodexManager.CATEGORY_CHARACTER, CodexManager.CATEGORY_WEAPON, CodexManager.CATEGORY_ACCESSORY, CodexManager.CATEGORY_ENEMY]:
		for entry in CodexManager.get_master_entries(category):
			var id := String((entry as Dictionary).get("id", ""))
			CodexManager.discover(category, id)
	var complete := CodexManager.get_collection_summary()
	_check(int(complete.get("found", 0)) == 84 and int(complete.get("total", 0)) == 84, "collection counts all four categories")
	_check(bool(complete.get("completed", false)) and bool(complete.get("completedOnce", false)), "collection complete and completedOnce are distinct values")
	var saved := CodexManager.get_save_data()
	_check(int(saved.get("schemaVersion", 0)) == 4 and bool(saved.get("collection_completed_once", false)), "collection flag is saved in schema four")
	var saved_copy := saved.duplicate(true)
	var saved_characters: Dictionary = saved_copy.get(CodexManager.CATEGORY_CHARACTER, {}) as Dictionary
	var saved_ban: Dictionary = saved_characters.get("ban_chan", {}) as Dictionary
	_saved_ban_new(saved_ban)
	_check(not CodexManager.is_new(CodexManager.CATEGORY_CHARACTER, "ban_chan"), "collection reads do not mutate NEW state")
	CodexManager.load_save_data({"schemaVersion": 1, "characters": {"ban_chan": {"discovered": true, "new": false}}})
	_check(int(CodexManager.get_entry(CodexManager.CATEGORY_CHARACTER, "ban_chan").get("play_count", -1)) == 0, "schema one character entry gets record defaults")
	CodexManager.load_save_data({"schemaVersion": 2, "characters": {"ban_chan": {"discovered": true, "new": false}}, "comments": {"banana_floor": {"discovered": true, "new": true}}})
	_check(CodexManager.is_discovered(CodexManager.CATEGORY_COMMENT, "banana_floor"), "schema two comment entry remains readable")
	CodexManager.load_save_data(saved)
	_check(bool(CodexManager.collection_completed_once()), "completedOnce survives round trip")
	var partial := saved.duplicate(true)
	(partial.get(CodexManager.CATEGORY_ENEMY, {}) as Dictionary).clear()
	CodexManager.load_save_data(partial)
	_check(bool(CodexManager.collection_completed_once()), "completedOnce never resets after content becomes incomplete")

func _find(items: Array, id: String) -> Dictionary:
	for item_value in items:
		if item_value is Dictionary and String((item_value as Dictionary).get("id", "")) == id:
			return item_value as Dictionary
	return {}

func _saved_ban_new(entry: Dictionary) -> void:
	entry["new"] = true

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
