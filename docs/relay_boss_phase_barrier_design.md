# ラストオフライン・フェーズバリア実装設計

## 1. 目的

ラストオフラインのフェーズ移行中に、実際の無敵状態と一致する「フェーズバリア」を表示する。

プレイヤーが画面だけで次を判断できる状態を完成条件とする。

- 現在は攻撃が通らない
- 次フェーズへ移行中である
- バリアが消えた直後から攻撃を再開できる

既存のフェーズ境界判定、攻撃終了待ち、召喚物整理、中央移動、次フェーズ開始処理は維持する。

## 2. 現行実装の監査結果

### 2.1 すでに実装されているもの

- HP比率から次フェーズを決める処理
- 現在攻撃の終了を待ってからフェーズ移行へ入る処理
- `PHASE_TRANSITION` で中央アンカーへ移動する処理
- 敵弾、ボス攻撃オブジェクト、召喚物の整理
- フェーズ移行中の攻撃FSM停止
- フェーズ移行終了後の攻撃再開
- フリーズ防止用のフェーズ移行ウォッチドッグ
- コラボ技終了後に保留中のフェーズ移行を始める処理

### 2.2 不足しているもの

- フェーズ移行専用の防御状態
- ボス本体へ実際の無敵フラグを同期する処理
- 通常武器を止める共通ダメージゲート
- 相方支援、歌枠系攻撃、コラボ技を含む全ダメージ経路の統一
- フェーズバリア、命中波紋、`無効`表示
- HPバーの移行表示
- バリア解除アニメーション
- 多段攻撃用の表示、SEクールダウン
- フェーズ移行中に満タンになったシンクロスターの保留処理

### 2.3 現行コード上の注意点

`WeaponSystem._apply_enemy_hit()` と `game.gd::_song_apply_enemy_damage()` は、現在の
`invincible` / `invulnerable` フラグを共通判定として使用していない。

そのため、ボスDictionaryへフラグを追加するだけでは通常武器と相方支援を確実に止められない。

コラボ技側にはボスの `invincible` / `invulnerable` 判定があるが、シンクロスターが満タンになると
自動でカットインを開始するため、入力だけでなく自動開始経路もロックする必要がある。

## 3. 所有モジュール

新規に次を追加する。

`scripts/systems/relay_boss_defense_system.gd`

このシステムを、フェーズ移行中の防御状態とバリア表示状態の唯一の所有者とする。

既存の責務は次のまま維持する。

- `relay_boss_system.gd`
  - フェーズ境界と移行シーケンスの進行
- `relay_boss_movement_system.gd`
  - 中央移動と移動FSM
- `relay_boss_attack_system.gd`
  - 攻撃FSM
- `relay_boss_draw_system.gd`
  - ワールド上のバリア描画
- `game.gd`
  - HPバー、SEプレイヤー、コラボ技開始制御

## 4. 防御状態

```gdscript
const STATE_NORMAL := "NORMAL"
const STATE_PHASE_INVINCIBLE := "PHASE_INVINCIBLE"
const STATE_DEAD := "DEAD"
```

ランタイム例:

```gdscript
{
    "state": "NORMAL",
    "nextPhase": 0,
    "barrierVisible": false,
    "releaseActive": false,
    "releaseTimer": 0.0,
    "releaseDuration": 0.30,
    "invalidTextCooldown": 0.0,
    "hitSeCooldown": 0.0,
    "invalidTextTimer": 0.0,
    "ripples": [],
    "blockedHitCount": 0,
    "elapsed": 0.0
}
```

`barrierVisible` と実際の無敵判定を別々の呼び出し元から変更しない。

外部コードは必ず次のAPIを使用する。

```gdscript
RelayBossDefenseSystem.begin_phase_transition(target, next_phase)
RelayBossDefenseSystem.begin_release(target)
RelayBossDefenseSystem.finish_phase_transition(target)
RelayBossDefenseSystem.force_clear(target, final_state)
RelayBossDefenseSystem.is_phase_invincible(target)
RelayBossDefenseSystem.register_blocked_hit(target, hit_position, source)
```

## 5. 設定データ

`data/relay_mode.json` の `boss` 直下へ追加する。

```json
"phaseBarrier": {
  "enabled": true,
  "releaseDuration": 0.30,
  "invalidTextCooldown": 0.35,
  "hitSeCooldown": 0.20,
  "maxRipples": 3,
  "invalidTextDuration": 0.48,
  "rippleDuration": 0.34,
  "barrierRadiusRate": 0.60,
  "barrierAspect": 0.90,
  "moduleGatherRate": 0.16,
  "finalPhaseNoiseMultiplier": 1.35,
  "hitSePath": "res://assets/audio/collab_maro_ban_circle_barrier.mp3",
  "releaseSePath": "res://assets/audio/confirm_select.mp3",
  "phaseColors": {
    "gameplay": ["#85e6ff", "#947cff", "#fff7ff"],
    "singing": ["#ff83c6", "#ffe16a", "#fff7ff"],
    "drawing": ["#82ddff", "#ff8dca", "#ffe16a"],
    "collab_final": ["#d85cff", "#ff5f9e", "#ffd76a"]
  }
}
```

専用SE素材が追加された場合は、パスだけを差し替えられる構造にする。

初回実装では次を既存素材から流用してよい。

- バリア命中: `collab_maro_ban_circle_barrier.mp3`
- バリア解除: `confirm_select.mp3`

## 6. フェーズ移行シーケンス

### 6.1 開始

`RelayBossSystem.begin_pending_phase_transition_for_target()` は、次の順序にする。

1. 保留フェーズと現在フェーズを検証
2. 攻撃中、コラボ技中なら開始しない
3. 攻撃オブジェクトと召喚物を整理
4. `RelayBossMovementSystem.begin_phase_transition()` を実行
5. 中央移動を受理できた場合のみ `RelayBossDefenseSystem.begin_phase_transition()` を実行
6. 同じフレームでボスの無敵フラグとバリア表示を有効化
7. HUD上のフェーズ番号を次フェーズへ更新
8. `BossPhaseTransition` のPauseReasonを追加

移動開始に失敗した場合は、無敵とバリアを開始しない。

### 6.2 中央到着後

現行の `phaseTransitionTime = 1.5` は維持する。

中央到着後の1.5秒を次のように使用する。

```text
約1.20秒: バリア保持、次フェーズ演出
約0.30秒: バリア解除演出
```

追加の0.3秒を後ろへ足さず、既存移行時間の末尾を解除演出へ割り当てる。

### 6.3 解除

`relay_boss_phase_transition_timer <= releaseDuration` へ入った最初のフレームで、
`RelayBossDefenseSystem.begin_release()` を一度だけ呼ぶ。

解除中も次を維持する。

- `STATE_PHASE_INVINCIBLE`
- ボスの `invincible = true`
- ボスの `invulnerable = true`
- バリア表示
- 攻撃FSM停止
- コラボ技開始ロック

タイマーが0になったフレームで、次を同時に行う。

1. 防御状態を `NORMAL` に変更
2. ボスの無敵フラグを解除
3. バリア表示を解除
4. `BossPhaseTransition` を解除
5. 保留中のコラボ技開始を再判定
6. 次フェーズの攻撃FSMを再開

攻撃FSMを無敵解除より先に再開しない。

## 7. ボスDictionaryへのミラー

汎用攻撃システムとの互換用に、アクティブなラストオフラインへ次を同期する。

```gdscript
boss["phaseBarrierActive"] = true
boss["phaseBarrierNextPhase"] = next_phase
boss["invincible"] = true
boss["invulnerable"] = true
```

解除時:

```gdscript
boss["phaseBarrierActive"] = false
boss["phaseBarrierNextPhase"] = -1
boss["invincible"] = false
boss["invulnerable"] = false
boss["hitFlashTimer"] = 0.0
```

防御状態の正本はDefenseSystemとし、Dictionaryの値だけからフェーズ進行を判断しない。

## 8. 通常武器のダメージゲート

### 8.1 命中結果を三値化する

`WeaponSystem._apply_enemy_hit()` の戻り値を単純なboolから次の結果へ変更する。

```gdscript
const HIT_NONE := 0
const HIT_DAMAGED := 1
const HIT_BLOCKED := 2
```

`phaseBarrierActive == true` の敵へ当たった場合:

- HPを変更しない
- `lastHitSource` / `lastHitOwner` を更新しない
- `defeatSource` / `defeatOwner` を更新しない
- ダメージ数値を作らない
- ヒットフラッシュを開始しない
- ノックバックを与えない
- スタンを与えない
- 撃破キューへ入れない
- `HIT_BLOCKED` を返す

### 8.2 衝突とダメージ成功を分ける

各武器は `HIT_BLOCKED` を「弾や攻撃がバリアへ接触した」として扱う。

そのため、必要な場合は次を行う。

- プレイヤー弾をバリアで消費
- ブーメランの同一対象再ヒット間隔を記録
- レーザーの接触判定を継続

ただし、通常命中としては数えない。

- `enemyDamaged` を立てない
- 通常敵ダメージSEを鳴らさない
- 通常ヒットストップを要求しない
- 武器命中コメントを発生させない
- 命中時追加効果を発生させない
- HP吸収や撃破報酬を発生させない

### 8.3 バリア命中要求

WeaponSystemの結果へ次を追加する。

```gdscript
"barrierHitRequests": [
    {
        "enemyUid": uid,
        "pos": hit_position,
        "source": weapon_id
    }
]
```

`apply_update_result_for_target()` で対象がラストオフラインかつ現在も無敵なら、
`target._relay_boss_register_barrier_hit()` を呼ぶ。

実際の接触位置が取得できない攻撃では、次の位置を使用する。

```text
ボス中心から攻撃元方向へ、バリア半径だけ進めた点
```

## 9. 相方支援と特殊攻撃

`game.gd::_song_apply_enemy_damage()` の先頭へ同じ防御判定を追加する。

ブロック時はDefenseSystemへ命中を登録し、次を行わずに終了する。

- HP減少
- 相方命中記録
- ヒットフラッシュ
- ダメージ数値
- 撃破処理
- ノックバック
- スロー、スタンなどの追加状態

ほかに `enemy["hp"]` を直接変更する攻撃経路がある場合も、ラストオフラインへ到達する前に
同じ防御APIを通す。

実装時に少なくとも次を監査する。

- 通常武器
- 装備武器
- NGワードレーザー
- リング、ブーメラン
- BANジャッジメント
- 相方の通常支援
- コラボ技
- デバッグ攻撃

## 10. コラボ技のロック

### 10.1 フェーズ移行開始前

コラボ技がすでに `ready` / `cutin` / `post` のいずれかなら、
既存どおりコラボ技完了後までフェーズ移行を保留する。

### 10.2 フェーズ移行中

シンクロスターが満タンになっても、カットインを開始しない。

```gdscript
relay_boss_combo_ready_pending = true
```

スターは消費しない。

`_start_collab_combo_ready()` にも防御状態のガードを入れ、別経路から呼ばれても開始しない。

### 10.3 バリア解除後

解除フレームで次を満たす場合のみ、保留したコラボ技を開始する。

- シンクロスター数が必要数以上
- コラボ技シーケンスが未開始
- ボスが生存中
- ゲーム状態が `playing`
- フェーズ移行が完全に終了

これにより、スターだけ消費してバリアに無効化される状態を防ぐ。

## 11. フェーズバリア描画

新規画像を必須にせず、初回実装はGodotの描画APIで構成する。

### 11.1 二層描画

現在の `RelayBossDrawSystem.draw_for_target()` はボス本体より先に描画される。

次の二層へ分ける。

```gdscript
draw_back_for_target(target, arena)
draw_front_for_target(target, arena)
```

描画順:

```text
バリア背面グロー
既存攻撃予告と危険領域
ボス本体
バリア前面リング、走査線、命中波紋、無効表示
```

`game.gd::_draw_world_layer()` では、ボス本体を描く前後に各パスを呼ぶ。

### 11.2 基本形状

ボスの `visualDrawSize` を基準にする。

```text
基準半径 = max(visualDrawSize.x, visualDrawSize.y) * barrierRadiusRate
横半径 = 基準半径
縦半径 = 基準半径 * barrierAspect
```

描画要素:

- 半透明の背面グロー
- 白紫の主リング
- アクセント色の回転アーク2～3本
- 細い走査線
- 短いピクセル欠け線
- コア周囲の白紫発光
- 低いアルファの内側リング

矩形一枚を回転させるのではなく、楕円上の点を計算して線分を描く。

### 11.3 テーマパーツの集合表現

現在のラストオフラインは一枚絵なので、5パーツそのものを分離移動できない。

初回実装では、既存の5つの論理Markerを使用して「内側へ集まる発光プロキシ」を描く。

対象Marker:

- `ChatModule`
- `GameModule`
- `SongModule`
- `DrawModule`
- `CollabModule`

各Marker位置をコアへ `moduleGatherRate` だけ補間し、次を描く。

- Marker色の小さな発光
- Markerからコアへの短い光線
- 内側へ流れる粒子

元画像を透明化せず、パーツが本体を守る動きを光で補強する。

将来パーツ別素材が追加された場合も、同じMarkerと補間率を流用できる。

### 11.4 ボス本体

無敵中もアルファを下げない。

`DrawDataSystem.enemy_draw_data()` でラストオフラインの `modulate` を次のように補正する。

- 彩度を少し下げる
- 明度を維持する
- コアは前面パスで白紫に固定
- 通常被弾フラッシュは無効

`hitFlashTimer` はバリア命中では変更しない。

## 12. フェーズ色

内部の次フェーズ番号を次のキーへ変換する。

| `nextPhase` | キー |
| --- | --- |
| 1 | `gameplay` |
| 2 | `singing` |
| 3 | `drawing` |
| 4 | `collab_final` |

最終フェーズでは次を強める。

- ピクセル欠け数
- 外周発光
- 回転アークの本数
- コア発光

点滅速度は大きく上げず、危険なフリッカーを避ける。

## 13. 命中反応

`register_blocked_hit()` はダメージ判定のたびに呼ばれてよい。

表示とSEだけをクールダウンで制限する。

### 13.1 波紋

- 実際の命中位置へ追加
- 最大3個
- 白紫の円形または六角形
- 約0.34秒で拡大して消える
- 上限時は最古を消さず、新規追加を見送る

### 13.2 `無効`

- ボスのコア付近へ小さく表示
- 白文字、濃い紫の太い縁取り
- 0.35秒クールダウン
- 通常ダメージ数値とは別管理

### 13.3 SE

- 0.20秒クールダウン
- 通常敵命中SEを鳴らさない
- 重い爆発音を重ねない

## 14. HPバー

`_draw_relay_boss_hud()` はDefenseSystemの状態を参照する。

無敵中:

- HPバー背景と塗りを約25%暗くする
- フェーズ番号の左側に手続き描画の小さな鍵を表示
- `フェーズ移行中` と表示
- HP数値は現在値を表示
- バー比率は防御開始時の値を保持する

新規の鍵画像は不要。

鍵は次で描画する。

- 角丸に依存しない小さな矩形
- 上部の半円アーク
- 白紫の塗りと濃紫の縁

通常へ戻ったフレームから、現在HP比率へ同期する。

## 15. 解除演出

解除時間は設定値の約0.30秒。

進行:

```text
0.00～0.18秒:
回転アーク加速、外周が少し縮む

0.18～0.26秒:
バリアがコアへ収縮

0.26～0.30秒:
テーマ色のリングを外側へ一度だけ放つ
コアを強く発光
解除SE
```

解除SEは一回だけ鳴らす。

最終フレームで、防御状態・ボス無敵フラグ・バリア表示をまとめて解除する。

## 16. 強制終了とウォッチドッグ

次の経路は必ずDefenseSystemをクリアする。

- ボス撃破
- プレイヤー死亡
- 最終ボス戦終了
- デバッグ再開始
- フェーズ移行ウォッチドッグ
- ボス本体復元

`_relay_boss_phase_lock_active()` は、既存タイマーと移動状態だけでなく
`RelayBossDefenseSystem.is_phase_invincible()` も含める。

ウォッチドッグ上限は次を含める。

```text
中央移動時間
+ phaseTransitionTime
+ 0.5秒の安全余白
```

解除時間は `phaseTransitionTime` 内に含めるため、別加算しない。

ウォッチドッグ発動時は次を同じフレームで行う。

- 移動FSMをHOVERへ戻す
- 防御状態をNORMALへ戻す
- ボス無敵フラグを解除
- バリアを消す
- コラボ技保留を再判定
- 攻撃FSMを再開

## 17. SE実装

`game.gd` へ次のAudioStreamPlayerを追加する。

```text
relay_boss_barrier_hit_se_player
relay_boss_barrier_release_se_player
```

DefenseSystemから音声ノードを直接操作せず、targetのコールバックを呼ぶ。

```gdscript
target._play_relay_boss_barrier_hit_se()
target._play_relay_boss_barrier_release_se()
```

設定パスが空、またはロード失敗の場合もゲーム進行を止めない。

## 18. デバッグ表示

F9のボスデバッグ表示へ次を追加する。

```text
DEFENSE PHASE_INVINCIBLE
barrier:on
nextPhase:3
release:0.22
ripples:2/3
blocked:18
```

F12で次フェーズへ進めた際に、バリア開始から解除まで確認できるようにする。

## 19. 検証

### 19.1 自動検証

- `data/relay_mode.json` のJSON検証
- 変更したGDScriptの `--check-only`
- Godot headless起動
- `git diff --check`

可能なら `scripts/tests/relay_boss_phase_barrier_test.gd` を追加し、次を検証する。

- 開始時に防御状態とボス無敵フラグが同時に有効
- 解除中も無敵
- 終了時に防御状態とバリアが同時に無効
- 波紋が3個を超えない
- 表示、SEクールダウン
- 強制クリアで無敵が残らない

### 19.2 実機確認

1. F10でラストオフライン戦へ入る
2. F9でデバッグ表示を出す
3. F12で各フェーズ移行を確認する
4. 通常武器でバリアを攻撃する
5. NGワードレーザーやリングで多段命中させる
6. シンクロスターを満タンにしてからF12を押す
7. バリア解除後にコラボ技が開始されることを確認する
8. 最終フェーズの色、発光、ノイズ強化を確認する

## 20. 受け入れ条件

- フェーズ移行開始と同じフレームで無敵とバリアが有効になる
- 中央移動中からバリアが表示される
- ボス本体が透明にならない
- HPバーへ鍵と `フェーズ移行中` が表示される
- 通常武器、相方支援、コラボ技でHPが減らない
- バリア命中時に通常ダメージ数値と通常命中SEが出ない
- `無効`、波紋、専用SEがクールダウンに従う
- 多段攻撃でも表示が画面を埋めない
- バリア解除中は無敵が維持される
- バリア消失と無敵解除が同じフレームになる
- 解除後に通常攻撃と保留コラボ技が再開する
- フェーズ移行後に無敵フラグが残留しない
- 最終フェーズだけ発光とノイズが少し強い
- 既存のフェーズ進行、攻撃FSM、接触処理、召喚物整理を回帰させない
