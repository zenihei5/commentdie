# 『ぜんぶコメントのせいだ』
# ラストオフライン接触ダメージ設計

## 1. 目的

配信リレー最終ボス「ラストオフライン」へ、中央本体だけを対象とした接触ダメージを追加する。

本設計は、以下の既存設計にある `contactDamage: 0` の記述を上書きする。

- `docs/relay_late_stage_and_boss_tuning_design.md`
- `docs/relay_boss_large_roaming_revision_design.md`

高速位置変更中の接触無効という安全方針は維持し、通常巡航・攻撃中にボス中央へ入り込んだ場合だけ被弾させる。

## 2. 現行実装の問題

現在のラスボスは通常敵と同じ `EnemySystem.update_enemies()` の接触判定へ流れ込む。

```gdscript
var contact_radius := float(enemy["radius"]) + 22.0
if enemy_pos.distance_squared_to(player_pos) < contact_radius * contact_radius:
    damage_events.append(...)
```

ただし `data/relay_mode.json` の `boss.contactDamage` が `0` のため、実ダメージは発生しない。

この汎用判定へ `12` を設定するだけでは、次の問題が残る。

- 移動状態に関係なく毎フレーム接触イベントを生成する
- 高速位置変更中にも判定が残る
- 浮遊パーツを含む見た目との区別がない
- 到着直後の重なりを安全に解消できない
- 140px、0.22秒のノックバックを管理できない
- 接触専用クールダウンを保持できない

したがって、ラスボスは汎用接触イベント生成から除外し、専用の接触処理で管理する。

## 3. 設定データ

`data/relay_mode.json` の `boss` へ `contact` を追加する。

```json
"contact": {
  "damage": 12,
  "rehitSeconds": 1.0,
  "knockbackDistance": 140.0,
  "knockbackDuration": 0.22,
  "shape": "circle",
  "radius": 105.0,
  "centerMarker": "CoreCenter",
  "playerRadius": 22.0,
  "reenableAfterRepositionSeconds": 0.15,
  "arrivalPushDuration": 0.12,
  "arrivalPushPadding": 10.0,
  "minimumDestinationPlayerDistance": 220.0,
  "enabledStates": [
    "IDLE_HOVER",
    "CRUISING",
    "ATTACKING",
    "PHASE_TRANSITION"
  ],
  "disabledStates": [
    "REPOSITION_WARNING",
    "REPOSITIONING",
    "STUNNED",
    "DEAD"
  ],
  "effectKind": "relay_boss_contact_noise"
}
```

既存の `boss.contactDamage` は互換用に残してもよいが、ラスボス専用判定では参照しない。削除する場合は `RelayBossSystem` の初期化処理も `contact.damage` 参照へ統一する。

中央判定は半径105px、直径210pxの円形とする。指定された横幅190～230pxの範囲内であり、周囲の5つの浮遊パーツへ判定が届かない。

接触中心はボス辞書の `pos` そのものではなく、既存の `CoreCenter` Markerから算出する。

## 4. 所有システム

新規 `scripts/systems/relay_boss_contact_system.gd` を追加し、以下を所有する。

- 接触設定の取得
- 接触ランタイム
- 状態別の接触有効判定
- 中央円とプレイヤー円の重なり判定
- 接触ダメージイベント生成
- 接触専用クールダウン
- 通常接触ノックバック
- 高速移動到着後の再有効化待機
- 到着時の無傷押し出し
- 接触ノイズエフェクト要求

`RelayBossMovementSystem` は移動状態と到着通知だけを担当し、ダメージ値やノックバック距離を固定値で持たない。

## 5. 接触ランタイム

`game.gd` へ次の永続Dictionaryを宣言する。

```gdscript
var relay_boss_contact_runtime: Dictionary = {}
```

初期値は次の形とする。

```gdscript
{
    "damage_cooldown": 0.0,
    "reenable_timer": 0.0,
    "arrival_overlap_pending": false,
    "last_movement_state": "IDLE_HOVER",
    "knockback_active": false,
    "knockback_elapsed": 0.0,
    "knockback_duration": 0.0,
    "knockback_start": Vector2.ZERO,
    "knockback_target": Vector2.ZERO,
    "knockback_is_safety_push": false
}
```

リレー開始、ボス開始、ボス終了、敗北、通常モード復帰時に必ず初期化する。

## 6. 汎用敵接触との分離

`EnemySystem.update_enemies()` の接触イベント生成前に、ラスボス本体を除外する。

判定条件は次のいずれかを使用する。

```gdscript
bool(enemy.get("relayBoss", false))
```

または

```gdscript
String(enemy.get("bossId", "")) == "last_offline"
```

召喚物は従来どおり各自の `contactDamage` を使う。除外対象はラスボス本体だけとする。

## 7. 接触形状

接触判定は円対円で計算する。

```gdscript
var boss_center := RelayBossMovementSystem.marker_world_position(
    target,
    "CoreCenter",
    arena
)
var combined_radius := contact_radius + player_radius
var overlapping := boss_center.distance_squared_to(player_pos) <= combined_radius * combined_radius
```

デバッグ表示では、プレイヤー半径を加算する前の半径105pxを描画する。これがボス中央本体の論理CollisionShapeである。

ボス画像の描画矩形、`visualOpaqueSize`、周囲の5パーツ、武器からダメージを受ける `damageRadius` は接触判定へ使わない。

## 8. 接触有効判定

基本判定は設定の `enabledStates` と `disabledStates` から取得する。

有効状態:

- `IDLE_HOVER`
- `CRUISING`
- `ATTACKING`

無効状態:

- `REPOSITION_WARNING`
- `REPOSITIONING`
- `STUNNED`
- `DEAD`

追加の共通無効条件:

- `relay_boss_active == false`
- ボスHPが0以下
- `reenable_timer > 0`
- ボス撃破演出中
- プレイヤー死亡確定中
- 接触ノックバック処理中

### PHASE_TRANSITION

フェーズ移行先の中央へボスが強制移動している間は接触を無効にする。

中央到着後、既存のフェーズ演出タイマー中にボスが静止しており、ゲーム更新が継続している場合だけ接触を有効にしてよい。

実装上は次の条件を満たす場合のみ許可する。

```gdscript
movement_state == "PHASE_TRANSITION"
and not bool(movement_runtime.get("phase_center_pending", false))
```

現行実装のように中央到着時点で状態が `IDLE_HOVER` へ戻る場合は、通常の `IDLE_HOVER` 判定へ委ねる。強制移動中に接触ダメージを出してはならない。

## 9. 接触ダメージ処理

更新順は次のとおり。

1. `damage_cooldown` と `reenable_timer` を減算する
2. 接触有効状態か確認する
3. プレイヤーの `invincible` と `debug_invincible` を確認する
4. 中央円とプレイヤー円の重なりを確認する
5. 条件を満たした場合だけ接触イベントを1件生成する
6. `damage_cooldown` を `rehitSeconds` に設定する
7. 通常接触ノックバックを開始する
8. 接触位置へノイズ衝撃エフェクトを追加する

イベント例:

```gdscript
{
    "source": "last_offline contact",
    "damage": 12,
    "enemyId": "last_offline",
    "runtimeVariant": "",
    "attackType": "contact"
}
```

接触イベントは、同フレームのボス攻撃イベントより前へ追加する。これにより接触条件を満たしたフレームでは、接触ダメージが先にプレイヤー無敵時間を取得する。

`DamageSystem.apply_damage_events_for_target()` は既存のプレイヤー無敵時間を適用する。専用クールダウンも併用し、同じ接触による再ダメージは最低1.0秒空ける。

プレイヤーが無敵中の場合は、ダメージ、通常ノックバック、接触エフェクト、接触SEのすべてを発生させない。

## 10. 通常接触ノックバック

接触成功時、方向はボス中央からプレイヤーへ向ける。

```gdscript
var direction := player_pos - boss_center
if direction.length_squared() <= 0.01:
    direction = Vector2.DOWN
else:
    direction = direction.normalized()
```

目標位置:

```gdscript
knockback_target = player_pos + direction * knockbackDistance
```

ノックバックは `player_vel` へ一度だけ大きな速度を加える方式ではなく、0.22秒の専用ランタイムで位置補間する。これにより距離140pxと時間0.22秒を安定して守る。

`game.gd::_update_player()` で通常の `PlayerSystem.update_for_target()` 後に、接触ノックバックを進める。

補間は `ease_out_cubic` を使用し、前フレームの進捗との差分だけ移動させる。開始時には次を行う。

- `click_move_active = false`
- `player_vel` のボス方向成分を除去する
- 入力による移動は残してよいが、ノックバック方向への逆入力で押し出しが消えないよう、補間差分を最後に加算する

## 11. プレイ可能範囲と障害物補正

ノックバック目標は次の順で補正する。

1. アリーナ端からプレイヤー半径28pxを引いた矩形へclampする
2. `PlayerSystem.resolve_wall_collision()` で静的壁と `effect_walls` を解決する
3. 開始位置から目標位置までを8～12px間隔で走査する
4. 最後に到達できた位置を最終目標にする

壁の反対側へ瞬間移動させてはならない。

ノックバック中も毎フレーム最終位置を同じプレイ可能範囲へ補正する。

## 12. 高速位置変更

`REPOSITION_WARNING` へ入った時点で次を行う。

- 接触ダメージを無効化
- 通常接触ノックバックを停止
- `arrival_overlap_pending = false`

`REPOSITIONING` 中は次を一切発生させない。

- 接触ダメージ
- 押し出し
- 接触SE
- 接触ノイズエフェクト
- 接触クールダウンの新規開始

高速移動が完了したフレームで次を設定する。

```gdscript
runtime["reenable_timer"] = reenableAfterRepositionSeconds
runtime["arrival_overlap_pending"] = true
```

`reenable_timer` が0.15秒から0になるまでは、通常接触判定を行わない。

## 13. 到着時の重なり解消

高速移動完了後、`arrival_overlap_pending` がtrueの間は中央円とプレイヤー円の重なりを確認する。

重なっている場合:

- ダメージを与えない
- プレイヤー無敵時間を開始しない
- 被弾フラッシュを出さない
- 被弾SEを鳴らさない
- 接触ノイズエフェクトを出さない
- ボス中心から外側へ押し出す

安全押し出し距離は固定140pxではなく、接触円の外へ出るために必要な最小距離とする。

```gdscript
var overlap_exit_distance := combined_radius - boss_center.distance_to(player_pos)
var push_distance := maxf(0.0, overlap_exit_distance) + arrivalPushPadding
```

0.12秒で安全位置へ補間し、通常ノックバックと同じ壁・範囲補正を使う。

重なっていない場合は `arrival_overlap_pending = false` にする。

安全押し出し終了後も0.15秒の再有効化待機が残っている間は接触ダメージを出さない。

## 14. 移動先の安全確認

既存の `_choose_anchor()` は `minimumPlayerDistance` で220px未満の候補を除外している。この判定を維持し、接触設定の `minimumDestinationPlayerDistance` と同じ値へ統一する。

追加で、以下の移動経路も同じ安全確認を通す。

- 攻撃が要求する `required_anchor_for_attack()`
- デバッグによる強制アンカー移動
- 外部からの `request_anchor()`

通常の位置変更で220px以上離れた候補がない場合は、移動を開始せず0.25秒後に再抽選する。

攻撃が特定アンカーを必須とし、その位置がプレイヤーから220px未満の場合:

- 代替アンカーを許容する攻撃は別の安全アンカーを選ぶ
- `all_genre_rush` など中央必須の攻撃は、中央が安全になるまで開始を延期する

フェーズ移行の中央移動は例外として許可するが、強制移動中の接触を無効にし、到着時は無傷押し出しを適用する。

## 15. 演出

通常接触ダメージが実際に通った場合のみ、以下を発生させる。

- 既存のプレイヤー被弾フラッシュ
- 既存のプレイヤー被弾SE
- 既存の被弾画面揺れ
- 140px、0.22秒のノックバック
- 接触位置の小さなノイズ衝撃エフェクト

接触位置は、ボス中央とプレイヤー中心を結ぶ線上の中央円外周とする。

```gdscript
var impact_pos := boss_center + direction * contact_radius
```

`hit_fx` に次を追加する。

```gdscript
{
    "kind": "relay_boss_contact_noise",
    "pos": impact_pos,
    "dir": direction,
    "life": 0.30,
    "maxLife": 0.30
}
```

`DrawDataSystem.hit_fx_draw_data()` へ専用描画データを追加し、小型の紫・白・黒ノイズ片、短いリング、外向きの線で表現する。

ボス辞書の `hitFlashTimer` は変更しない。接触したボス本体を被弾フラッシュさせてはならない。

## 16. 変更対象

主な変更対象は次のとおり。

- `data/relay_mode.json`
  - `boss.contact` を追加
- `scripts/game.gd`
  - `relay_boss_contact_runtime` 宣言・初期化
  - プレイヤー更新後のノックバック更新
  - 接触成功時の演出要求
- `scripts/systems/relay_boss_contact_system.gd`
  - 新規。接触処理本体
- `scripts/systems/relay_boss_system.gd`
  - 接触更新を呼び、`damageEvents` の先頭へイベントを追加
- `scripts/systems/relay_boss_movement_system.gd`
  - 高速移動開始・終了通知
  - すべてのアンカー要求で220px安全確認
- `scripts/systems/enemy_system.gd`
  - ラスボス本体を汎用接触判定から除外
- `scripts/systems/draw_data_system.gd`
  - `relay_boss_contact_noise` 描画データ

## 17. 検証項目

### 基本

- `IDLE_HOVER` 中に中央へ接触すると12ダメージを受ける
- `CRUISING` 中に中央へ接触すると12ダメージを受ける
- `ATTACKING` 中に中央へ接触すると12ダメージを受ける
- 浮遊パーツだけへ触れてもダメージを受けない
- 接触判定の直径が210pxである

### クールダウン

- 接触を続けても毎フレームダメージを受けない
- 同じ接触の再ダメージが1.0秒未満で発生しない
- プレイヤー無敵中は接触ダメージとノックバックが発生しない

### 高速移動

- `REPOSITION_WARNING` 中は接触ダメージがない
- `REPOSITIONING` 中はダメージ、押し出し、SE、エフェクトがない
- 到着後0.15秒は接触ダメージがない
- 到着時に重なっている場合は無傷で外へ押し出される
- 安全押し出しで壁の反対側やフィールド外へ移動しない

### ノックバック

- 通常接触時の目標距離が約140pxである
- ノックバック時間が約0.22秒である
- フィールド端では最終位置がプレイ可能範囲内へ補正される
- 静的壁と一時壁をすり抜けない

### 移動先

- 通常の高速位置変更先がプレイヤーから220px以上離れる
- 安全候補がない場合に危険な位置へ強行移動しない
- 中央必須攻撃は中央が安全になるまで開始されない

### 演出

- 接触成功時だけプレイヤー被弾フラッシュ、SE、ノックバック、ノイズ衝撃が出る
- ボス本体は接触時に被弾フラッシュしない
- 無傷押し出しでは被弾演出が出ない

### 回帰

- 通常敵とラスボス召喚物の接触ダメージは従来どおり動作する
- ラスボスの武器被弾半径 `damageRadius` は変わらない
- 高速移動、フェーズ移行、17種の攻撃FSMが停止しない
- ボス撃破後に接触判定やノックバックが残らない
