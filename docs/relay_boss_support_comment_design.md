# ラストオフライン・ガチ応援コメ実装設計

## 1. 目的

ラスボス専用の通常指示コメ3択を生成した後、低確率で1枠だけを`boss_support`カテゴリへ差し替える。

応援コメはプレイヤーを助ける例外枠だが、既存の指示コメ周期、フェーズ移行、スコア、相方、コンビ技を変更しない。効果値はプレイヤーの基礎値へ書き込まず、source単位で合成・解除できる倍率レイヤーへ登録する。

## 2. 現状監査と不足点

### 既存処理

- `data/relay_mode.json`の`boss.comments`から`RelayBossSystem.start_comment_choice_for_target()`が通常3択を作る。
- `RelayBossSystem.choose_instruction_for_target()`が選択結果を`relay_boss_instruction`へ保存し、共通の`relay_boss_instruction_timer`で15秒を管理する。
- 通常ボス指示コメは、攻撃間隔、弾数、弾速、ダッシュ禁止、相方停止、アリーナ縮小、回復禁止を専用変数へ直接反映している。
- プレイヤー移動速度は`PlayerSystem`から`_relay_boss_player_move_speed_multiplier()`を呼ぶ既存合成口がある。
- プレイヤー武器ダメージは`WeaponSystem`内で既存のコラボ倍率を掛けている。
- プレイヤー被ダメージは`DamageSystem.apply_damage_source_for_target()`へ集約されている。
- ラスボス選択では通常の`ModifierSystem.apply_choice_numbers_to_target()`を通らないため、現状でも選択による難度倍率やギフト期待度は加算されない。

### 不足点

- 提示履歴、45秒クールダウン、90秒保証、連続周期禁止を管理する状態がない。
- 新しい指示を選ぶ前に、現在のラスボス指示効果を明示的に解除する共通関数がない。
- 攻撃力、移動速度、被ダメージ倍率を他の効果とsource単位で合成する仕組みがない。
- 応援カード、専用SE、プレイヤーへ飛ぶ光、HUDバフアイコンがない。
- 現在のカード描画は危険度、倍率、ギフト期待度を前提としており、応援カード専用表示が必要。

## 3. 設定データ

`data/relay_mode.json`の`boss.comments`へ次の2件を追加する。通常候補生成時は`category == "boss_support"`を除外し、応援抽選時だけ使用する。

```json
{
  "id": "boss_support_dont_lose",
  "displayName": "負けないで！",
  "description": "メンタル15%回復 / 15秒間 被ダメージ20%軽減",
  "category": "boss_support",
  "effectType": "relay_boss_support",
  "duration": 15.0,
  "riskLevel": 0,
  "multiplier": 1.0,
  "difficultyBonus": 0,
  "giftHypeOnSelect": 0,
  "giftHypeOnClear": 0,
  "params": {
    "healMaxHpRate": 0.15,
    "damageTakenMultiplier": 0.80
  }
}
```

```json
{
  "id": "boss_support_do_your_best",
  "displayName": "頑張れ！！",
  "description": "15秒間 攻撃力25%アップ / 移動速度10%アップ",
  "category": "boss_support",
  "effectType": "relay_boss_support",
  "duration": 15.0,
  "riskLevel": 0,
  "multiplier": 1.0,
  "difficultyBonus": 0,
  "giftHypeOnSelect": 0,
  "giftHypeOnClear": 0,
  "params": {
    "playerAttackMultiplier": 1.25,
    "playerMoveSpeedMultiplier": 1.10
  }
}
```

`boss.bossInstructionSettings`へ次を追加する。

```json
"support": {
  "enabled": true,
  "baseChance": 0.15,
  "lowHpThreshold": 0.35,
  "lowHpChance": 0.30,
  "appearanceCooldown": 45.0,
  "pityElapsed": 90.0,
  "maxPerOffer": 1,
  "appearanceSePath": "res://assets/audio/collab_star_comment_shower_complete.mp3"
}
```

SEパスは設定値から読む。ロードに失敗した場合だけ通常の指示コメ到着SEへフォールバックし、無音にはしない。

## 4. ランタイム状態

`scripts/game.gd`へ次を追加し、ラスボス開始時、ラン初期化時、勝利・敗北クリーンアップ時に必ず初期化する。

```gdscript
var relay_boss_encounter_elapsed := 0.0
var relay_boss_instruction_cycle := 0
var relay_boss_support_ever_offered := false
var relay_boss_support_appearance_cooldown := 0.0
var relay_boss_support_last_offer_cycle := -999
var relay_boss_support_last_id := ""
var relay_boss_support_fx: Array = []
var modifier_sources: Dictionary = {}
```

`relay_boss_encounter_elapsed`と`relay_boss_support_appearance_cooldown`は、ラスボス戦の`playing`時間で進める。指示コメ3択、ポーズ、リザルト中は進めない。フェーズ移行はボス戦時間に含める。

`relay_boss_instruction_cycle`は3択を実際に開く直前に1増やす。提示キャンセルやフェーズ待ちだけでは増やさない。

## 5. 応援コメの抽選

### 5.1 処理順

`RelayBossSystem.start_comment_choice_for_target()`を次の順へ変更する。

1. `boss.comments`を通常プールと`boss_support`プールへ分離する。
2. 通常プールだけから、既存ルールどおり3択を完成させる。
3. `relay_boss_instruction_cycle`を1増やす。
4. 応援コメを差し込むか判定する。
5. 差し込み時は通常3枠のランダムな1枠だけを応援コメへ置換する。
6. `offered_comments`へ確定結果を保存する。

候補数が3未満の場合もクラッシュさせない。差し替え先は`0 .. offer.size() - 1`から選ぶ。

### 5.2 出現条件

次をすべて満たす場合だけ通常抽選を行う。

- `support.enabled == true`
- 応援プールが空ではない
- `relay_boss_support_appearance_cooldown <= 0`
- `currentCycle - relay_boss_support_last_offer_cycle > 1`

確率は3択生成時点のプレイヤーHPで決める。

```gdscript
var hp_ratio := float(player_hp) / maxf(1.0, float(player_max_hp))
var chance := lowHpChance if hp_ratio <= lowHpThreshold else baseChance
```

境界の35%は低HP側、つまり30%とする。

### 5.3 90秒保証

次を満たす場合、確率ロールを行わず必ず1枚差し込む。

```gdscript
relay_boss_encounter_elapsed >= pityElapsed
and not relay_boss_support_ever_offered
```

「出現」は選択ではなく、3択へ提示された時点と定義する。提示されたが選ばれなかった場合も、初回保証は消費し、45秒クールダウンを開始する。

### 5.4 提示確定時の更新

差し込みに成功した時だけ次を更新する。

```gdscript
relay_boss_support_ever_offered = true
relay_boss_support_appearance_cooldown = appearanceCooldown
relay_boss_support_last_offer_cycle = relay_boss_instruction_cycle
relay_boss_support_last_id = support_id
```

同一3択へ差し込む応援コメは常に最大1枚とする。設定値が壊れていても実装側で1へ上限固定する。

### 5.5 2種類の均等抽選

応援プールから`relay_boss_support_last_id`と同じIDを除外する。除外後に候補が残る場合はそこから均等抽選し、残らない場合だけ元のプールへ戻す。

現在は2種類なので、一度出た後は必ずもう一方が選ばれる。抽選と差し替え位置には、引数の`RandomNumberGenerator`を使用し、グローバル`Array.shuffle()`へ依存しない。

## 6. 効果の切り替えと解除

### 6.1 共通解除

`RelayBossSystem`へ次の責務を持つ関数を追加する。

```gdscript
static func clear_active_instruction_for_target(target: Node) -> void
```

この関数は、現在の`relay_boss_instruction.id`に対応する効果だけを解除する。

- 攻撃間隔を1.0へ戻す
- 弾数、弾速を1.0へ戻す
- ラスボス由来の`no_dash`だけを解除する
- 相方ミュートを解除する
- アリーナ縮小タイマーを終了する
- 回復禁止タイマーを終了する
- `boss_support`のmodifier sourceを削除する
- `relay_boss_instruction`とタイマーを空へ戻す

通常の指示コメ、装備、ギフト、休憩バフ、歌・お絵かき・コラボ枠由来の効果は消さない。`active_effects.erase("no_dash")`は、同じIDを別sourceが所有する可能性を考慮し、ラスボス指示コメの所有状態を別フラグで記録してから解除する。

### 6.2 選択時の順序

`choose_instruction_for_target()`は必ず次の順で処理する。

1. 選択候補を取得する。
2. `clear_active_instruction_for_target(target)`を呼ぶ。
3. 新しい`relay_boss_instruction`と15秒タイマーを設定する。
4. 通常ボス指示コメ、または応援コメの効果を適用する。
5. 選択UIを閉じる。

応援コメの回復は手順2の後に行う。このため、現在効果が`relay_boss_no_heal`でも、先に回復禁止を解除してから15%回復できる。

### 6.3 効果時間終了

`_update_instruction_timer()`で0になった時も`clear_active_instruction_for_target()`だけを呼ぶ。一括で基礎値や他sourceの倍率を初期化しない。

## 7. source単位の倍率管理

既存の`ModifierSystem`を、単一の`active_effects`とは別にsource単位の乗算倍率を保持できるよう拡張する。

```gdscript
static func set_multiplier_source_for_target(
    target: Node,
    source_id: String,
    multipliers: Dictionary
) -> void

static func remove_multiplier_source_for_target(
    target: Node,
    source_id: String
) -> void

static func combined_multiplier_for_target(
    target: Node,
    key: String,
    fallback: float = 1.0
) -> float
```

保存先は`target.modifier_sources[source_id]`とし、同じsourceを再設定した場合は置換する。複数sourceの同一キーは乗算する。

応援コメのsource IDは次とする。

```text
relay_boss_support_dont_lose
relay_boss_support_do_your_best
```

使用キーは次に固定する。

```text
playerAttackDamage
playerMoveSpeed
playerDamageTaken
```

ラスボス戦終了時は`relay_boss_support_`接頭辞のsourceだけを削除する。`modifier_sources.clear()`はラン全体の初期化時だけ許可する。

### 7.1 負けないで！

選択直後に次を行う。

```gdscript
var requested_heal := ceili(float(player_max_hp) * 0.15)
var actual_heal := mini(requested_heal, player_max_hp - player_hp)
player_hp = mini(player_max_hp, player_hp + maxi(0, actual_heal))
```

その後、次のsourceを15秒間登録する。

```gdscript
{"playerDamageTaken": 0.80}
```

HP満タンで`actual_heal == 0`でもsource登録は省略しない。

### 7.2 頑張れ！！

次のsourceを15秒間登録する。

```gdscript
{
  "playerAttackDamage": 1.25,
  "playerMoveSpeed": 1.10
}
```

### 7.3 攻撃力の適用場所

`WeaponSystem.update_for_target()`で既存のコラボダメージ倍率と応援倍率を乗算し、メイン武器と装備武器の生成ダメージへ同じ値を渡す。

```gdscript
var support_attack_rate := ModifierSystem.combined_multiplier_for_target(
    target,
    "playerAttackDamage"
)
var player_damage_rate := collab_damage_rate * support_attack_rate
```

固定割合ダメージであるラスボス用コンビ技、相方攻撃、環境攻撃、敵同士のダメージには掛けない。バフ開始前に生成済みの弾は、生成時のダメージ値を保持してよい。

### 7.4 移動速度の適用場所

`_relay_boss_player_move_speed_multiplier()`の既存ハザード計算結果へ、`playerMoveSpeed`の合成倍率を乗算する。

```gdscript
return hazard_multiplier * support_move_multiplier
```

これにより、ハザードの減速と応援の1.10倍が同時に有効になる。`player_speed`基礎値は変更しない。

### 7.5 被ダメージの適用場所

`DamageSystem.apply_damage_source_for_target()`で、ステージ倍率と歌枠倍率を計算した後、最終適用直前に`playerDamageTaken`を乗算する。

```gdscript
amount = maxi(1, int(ceil(float(amount) * damage_taken_multiplier)))
```

敵弾、接触、ラスボス攻撃、召喚、ダメージ床を含む全被ダメージへ適用する。無敵判定は既存どおり先にダメージを無視する。0ダメージイベントを1へ変換しない。

## 8. SEと決定演出

### 8.1 専用出現SE

`start_comment_choice_for_target()`は次を返す。

```gdscript
{
  "supportOffered": true,
  "supportId": "boss_support_dont_lose"
}
```

現在は通常到着SEを候補生成前に鳴らしているため、次の順へ変更する。

1. 3択を生成する。
2. `supportOffered`なら専用SEを1回鳴らす。
3. それ以外は通常の指示コメ到着SEを鳴らす。

両方を同時再生しない。

### 8.2 プレイヤーへ飛ぶ光

応援コメ選択結果に次を含める。

```gdscript
{
  "supportSelected": true,
  "supportId": "...",
  "healAmount": 15
}
```

`game.gd::_choose_comment()`は選択カード中央からプレイヤー位置へ0.50〜0.60秒で移動する光を`relay_boss_support_fx`へ追加する。

- 白いコア
- 淡い金の尾
- ミントの小粒
- 到着時にハート1個と十字キラキラ4個
- `boss_support_dont_lose`は到着時に`HP +N`
- `boss_support_do_your_best`は到着時に`POWER UP`

ゲーム効果は選択直後に適用し、光の到着待ちにはしない。演出中にフェーズ移行が始まっても、UI演出deltaで最後まで描画する。

## 9. カード表示

通常指示コメと同じ3択サイズ、入力、番号バッジ、選択カーソルを維持する。

`category == "boss_support"`のカードだけ、`ChoiceCardSystem.comment_card()`と`game.gd::_draw_comment_choice_card_contents()`で専用分岐する。

- 背景: 白を主体に、上側を淡い金、下側を淡いミント
- 枠: 金の外線、ミントの内線
- 上部タグ: `応援`
- 装飾: 左上に小さなハート、右上と下部に十字キラキラ
- タイトル色: 濃いピンクまたは濃いミント。白文字を白背景へ置かない
- 危険度表示、倍率、ギフト期待度は表示しない
- 下部表示:
  - 負けないで！: `HP 15%回復` / `被ダメ -20%`
  - 頑張れ！！: `攻撃 +25%` / `移動 +10%`

応援カードの`riskLevel`は0とし、危険カード用の赤点滅や警告オーバーレイを発生させない。3択全体の残り5秒警告は維持する。

専用画像素材は必須にせず、既存の`_draw_stream_frame_icon_heart()`、`_draw_stream_start_sparkle()`等の描画プリミティブを再利用する。

## 10. HUDバフ表示

### 候補提示中

応援カード内に対応アイコンを表示するため、提示中の効果内容はカードだけで判別できる。通常HUDの「現在の指示コメ」はまだ変更しない。

### 効果中

`relay_boss_instruction.category == "boss_support"`かつタイマーが正の場合、上部の現在指示コメパネルを白・淡い金・ミントへ切り替え、`応援`タグと残り秒数を表示する。

- `boss_support_dont_lose`: ハート＋小盾アイコン、`被ダメ -20%`
- `boss_support_do_your_best`: 星＋上向き矢印アイコン、`攻撃 +25% / 移動 +10%`

アイコンは固定24〜28pxとし、タイマーや長い表示名でレイアウトが動かないよう専用領域を確保する。ポーズ画面の現在指示コメにも同じ表示名と残り時間を出す。

## 11. スコアと既存ルール

- `difficultyBonus = 0`をデータと正規化後の両方で保証する。
- 応援コメ選択時に`multiplier`、`max_multiplier`、`burn_combo`、`gift_hype`、`pending_clear_hype`を変更しない。
- 応援効果終了時に完走ボーナスを発生させない。
- ボス討伐固定スコア、`relay_boss_score_snapshot`、盛り上がり倍率、コンビ技必要スター数を変更しない。
- 通常3択の生成ルール、15秒周期、10秒選択時間、15秒効果時間は変更しない。

## 12. フェーズ移行・終了処理

- 指示コメ選択中にフェーズ閾値へ到達した場合は、既存どおり選択完了後にフェーズ移行する。
- 応援バフの15秒タイマーは既存の指示コメ効果時計と同様にフェーズ移行中は停止する。
- 応援出現クールダウンと90秒保証用のボス戦経過時間はフェーズ移行中も進める。
- ボス撃破、敗北、デバッグ再開、通常枠へ戻る処理では、応援source、応援FX、現在応援コメ、専用SE再生を確実に停止する。

## 13. 実装対象

### `data/relay_mode.json`

- 応援コメ2件
- `bossInstructionSettings.support`

### `scripts/systems/relay_boss_system.gd`

- 通常・応援プール分離
- 応援出現判定、履歴、クールダウン、90秒保証
- 現在指示効果の共通解除
- 応援効果適用
- 選択結果メタデータ
- ラスボス開始・終了時の初期化

### `scripts/systems/modifier_system.gd`

- source単位の倍率登録、削除、乗算取得

### `scripts/systems/weapon_system.gd`

- プレイヤー武器ダメージへ`playerAttackDamage`を合成

### `scripts/systems/damage_system.gd`

- 最終被ダメージへ`playerDamageTaken`を合成

### `scripts/game.gd`

- ランタイム変数
- ボス戦経過時間とクールダウン更新
- 専用SEセットアップ・再生
- 光の飛翔FX更新・描画
- 応援カード専用描画
- HUDバフアイコンと応援パレット
- ラスボス移動倍率へ`playerMoveSpeed`を合成
- 全終了経路のクリーンアップ

## 14. 検証

### 自動テスト

可能なら`tests`または`scripts/tests`へ、乱数を固定した応援抽選テストを追加する。

1. HP36%以上では出現率設定が15%を使う。
2. HP35%ちょうど以下では30%を使う。
3. 1回の3択に応援は最大1枚。
4. 提示後45秒未満は再出現しない。
5. 連続周期には出現しない。
6. 90秒以上で一度も提示されていなければ次回確定。
7. 直前の応援IDを除外し、2種類が交互になる。
8. 提示されたが未選択でも保証とクールダウンを消費する。
9. 通常候補生成へ`boss_support`が混入しない。
10. スコア関連値が選択前後で変わらない。

### 効果テスト

1. 回復禁止中に`負けないで！`を選ぶと、回復禁止解除後に最大HPの15%を回復する。
2. HP満タンでも15秒間0.80倍軽減が残る。
3. 100最大HP、20ダメージは16ダメージになる。
4. `頑張れ！！`中はメイン武器と装備武器が1.25倍、移動速度が1.10倍。
5. 相方攻撃と固定割合コンビ技は1.25倍にならない。
6. 15秒終了後は応援sourceだけが消え、他の減速・装備・ギフト効果が残る。
7. 応援から通常指示、通常指示から応援へ切り替えても前効果が残らない。
8. フェーズ移行中に効果時間が早く切れない。

### 表示・音

1. 応援カードだけ白・金・ミント枠と`応援`タグになる。
2. 赤い危険警告、難度倍率、ギフト期待度を表示しない。
3. 応援を含む3択では専用SEだけが1回鳴る。
4. 決定直後にカードからプレイヤーへ光が飛び、効果は待たずに適用される。
5. 効果中はHUDに対応アイコン、表示名、残り時間が出る。
6. 1280x720相当とゲーム標準解像度で文字・アイコンが重ならない。

### 回帰確認

- JSON構文検証
- Godot headless起動
- `relay_boss_system.gd`、`modifier_system.gd`、`weapon_system.gd`、`damage_system.gd`、`game.gd`のパース
- 通常ラスボス指示コメ6種
- フェーズバリア、接触ダメージ、ノイズ召喚、コンビ技、勝利・敗北
- `git diff --check`

## 15. 完了条件

- 指定確率、低HP補正、45秒クールダウン、90秒保証、連続周期禁止が同時に成立する。
- 3択へ入る応援コメは最大1枚で、2種類は直前IDを避ける。
- 選択前に現在のラスボス指示効果が解除される。
- 回復、攻撃、移動、軽減が15秒間正しく適用され、終了後に他効果を壊さず戻る。
- カード、SE、飛翔光、HUDアイコンで通常指示コメと明確に区別できる。
- 難度ボーナス、討伐スコア、盛り上がり倍率が変化しない。
