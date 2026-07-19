# ボス登場カットイン実装設計

## 1. 実装方針

通常ボスと配信リレー最終ボスで別機能を作らず、共通の `BossCutinSystem` と `game.gd` の共通描画を使用する。

このプロジェクトは主要UIを `game.gd` から描画し、状態計算を `scripts/systems/*_system.gd` へ分離する構造なので、第一版では新しい `.tscn` を増やさない。

- `BossCutinSystem`: データ正規化、タイムライン、表示進捗、完了判定を担当
- `game.gd`: 状態遷移、ゲーム停止、テクスチャ・SE、実描画、完了後処理を担当
- `BossSystem`: 通常ボスの警告終了と実体spawnの間にカットイン要求を挟む
- `RelayBossSystem`: 既存の最終ボス開始処理を、カットイン完了後だけ呼ぶ

通常・FINALの差はデータとタイムラインだけにし、共通APIを通す。

## 2. 既存経路と差し込み位置

### 通常ボス

現状は `BossSystem.request_summon_for_target()` の3秒警告後、`BossSystem.update_for_target()` から `spawn_for_target()` が直接呼ばれる。

変更後:

1. 出現条件達成、既存の3秒警告を開始
2. 警告終了時に実体をspawnせず、1回だけ `bossCutinRequest` を返す
3. `game.gd` が敵・弾を整理して `boss_cutin` 状態へ入る
4. 1.5秒の共通カットインを再生
5. 完了アクション `spawn_normal_boss` が `BossSystem.spawn_for_target()` を1回だけ呼ぶ
6. ボスBGM・AI・指示コメ周期を再開

`boss_requested` はカットイン完了まで維持する。警告終了後の再要求を防ぐため、BossSystem側に `boss_cutin_pending` と `boss_cutin_started` を持たせる。spawn成功時またはキャンセル時に両方を必ず解除する。

### 配信リレー最終ボス

現状は最終休憩後の枠開始イントロ完了時、`_start_relay_boss()` が直接呼ばれ、`RelayBossSystem.start_for_target()` がラストオフラインを生成する。

変更後:

1. 最終休憩終了
2. 既存の枠開始イントロを再生
3. イントロ完了時に `_start_relay_boss()` を呼ばず、`last_offline` のカットインを開始
4. 2.4秒のFINAL BOSSカットインを再生
5. 完了アクション `start_relay_final_boss` が既存 `_start_relay_boss()` を1回だけ呼ぶ
6. ラストオフライン生成後0.30秒は攻撃・接触ダメージを無効にし、その後戦闘開始

休憩、枠開始イントロ、カットイン、spawnの順序は変えない。最終ボス本体をカットイン前に生成しない。

## 3. 新規システム

新規ファイル: `scripts/systems/boss_cutin_system.gd`

```gdscript
class_name BossCutinSystem

static func empty_runtime() -> Dictionary
static func normalize_data(raw: Dictionary, fallback: Dictionary) -> Dictionary
static func start(data: Dictionary, completion_action: String, previous_state: String) -> Dictionary
static func update(runtime: Dictionary, delta: float) -> Dictionary
static func build_view(runtime: Dictionary) -> Dictionary
static func cancel(runtime: Dictionary) -> Dictionary
```

ランタイムに `Callable` は保存せず、以下の完了アクション文字列を使う。

- `spawn_normal_boss`
- `start_relay_final_boss`
- `debug_return`

最低限のランタイム:

```gdscript
{
  "active": true,
  "elapsed": 0.0,
  "duration": 1.5,
  "data": {},
  "completionAction": "spawn_normal_boss",
  "previousState": "playing",
  "revealSePlayed": false,
  "completionDispatched": false
}
```

`update()` は更新後runtimeに加え、`playRevealSe` と `finished` を返す。`finished` が複数フレームでtrueになっても、`completionDispatched` により完了処理は必ず1回にする。

## 4. 状態と完全停止

`state = "boss_cutin"` を新しい前面状態として追加する。

- `StateFlowSystem.front_state_action_for_target()` の処理済み状態へ追加
- `StateFlowSystem.has_modal_overlay()` へ追加
- `_update_front_state()` から `_update_boss_cutin(delta)` を呼ぶ
- `boss_cutin` 中は `_update_world()` を一切呼ばない
- `_draws_title_only()` には追加せず、停止した戦闘画面を背景として残す
- ポーズ入力、指示コメ選択、ギフト選択など別モーダルへの遷移を受け付けない

所有権を明確にするため `PauseReasonSystem.add_reason(target, "BossCutin")` も追加し、終了・キャンセル・リセット時は `BossCutin` だけを解除する。`PauseReasonSystem.clear()` は使わない。

これにより次が同時に停止する。

- プレイヤー操作・相方AI
- 敵AI・敵弾・味方弾
- ステージタイマー・スポーンタイマー
- 指示コメ周期・指示コメ効果時間
- 回復、バフ、デバフなどの時間経過
- コラボパスとステージ固有ギミック

`SceneTree.paused` や `Engine.time_scale = 0` は使わない。カットイン自身のアニメーションとSEを通常deltaで進める。

## 5. 開始・終了API

`game.gd` に以下を追加する。

```gdscript
func _start_boss_cutin(boss_id: String, completion_action: String) -> void
func _update_boss_cutin(delta: float) -> void
func _finish_boss_cutin() -> void
func _cancel_boss_cutin(restore_previous_state := true) -> void
func _dispatch_boss_cutin_completion(action: String) -> void
func debug_play_boss_cutin(boss_id: String) -> void
```

終了順序:

1. `completionDispatched = true`
2. カットイン用SE・一時表示を停止
3. `BossCutin` pause reasonを解除
4. runtimeを非active化
5. 完了アクションをdispatch
6. 通常ボスまたはラスボスの既存開始処理へ戻す

`duration + 0.5秒` を超えた場合はwatchdogで強制完了する。画像ロード失敗、SEなし、途中の状態リセットでもゲーム停止が残らないこと。

## 6. 事前整理

通常ボスのカットイン開始直前に、報酬を発生させない共通整理処理を1回だけ実行する。

```gdscript
func _prepare_normal_boss_cutin() -> void
```

処理内容:

- `boss_cutin` 状態への遷移で新規スポーンを停止
- 敵弾を全消去
- プレイヤー弾と遅延ヒットを消去し、カットイン後の即時命中を防止
- 非ボス雑魚を退場扱いで消去。経験値、ドロップ、撃破数、スコアを与えない
- 攻撃予告線、攻撃ライン、低速領域、コラボボス攻撃など短命の敵性オブジェクトを消去
- 遅延生成待ちの敵・コメント攻撃をキャンセル

維持するもの:

- プレイヤー、相方、HP、経験値、レベル
- 装備、バフ・デバフの残り時間
- 取得済みアイテム、配信リレー引き継ぎデータ
- 有益な永続ギミック

ラストオフライン側は、既存 `RelayBossSystem.start_for_target()` の敵・敵弾整理を維持する。カットイン前にはまだ同処理を呼ばない。

## 7. データ定義

通常ボスは `data/bosses.json` の各ボスへ `cutin` を追加する。最終ボスは `data/relay_mode.json` のボス設定へ同じ構造で追加する。別形式を作らず、`BossCutinSystem.normalize_data()` が共通既定値を補う。

```json
"cutin": {
  "displayName": "クソマロキング",
  "subTitle": "",
  "labelType": "boss",
  "imagePath": "res://assets/generated/enemy_sprites_v1/kuso_maro_king.png",
  "themeColor": "#ff66b8",
  "accentColor": "#8defff",
  "noiseColor": "#f7f7ff",
  "bgStyle": "zatsudan",
  "durationSeconds": 1.5,
  "imageSide": "left",
  "flipH": false,
  "imageScale": 1.0,
  "imageOffset": {"x": 0, "y": 0},
  "seType": "boss_normal",
  "isFinalBoss": false
}
```

ラストオフライン:

```json
"cutin": {
  "displayName": "ラストオフライン",
  "subTitle": "配信終焉体",
  "labelType": "final_boss",
  "imagePath": "res://assets/generated/relay_boss_v1/last_offline.png",
  "themeColor": "#8a5cff",
  "accentColor": "#ff6ecf",
  "noiseColor": "#f5f7ff",
  "bgStyle": "final",
  "durationSeconds": 2.4,
  "imageSide": "left",
  "flipH": false,
  "imageScale": 1.0,
  "imageOffset": {"x": 0, "y": 0},
  "seType": "boss_final",
  "isFinalBoss": true
}
```

`labelType` は第一版では `boss` と `final_boss` のみ許可し、それぞれ `BOSS`、`FINAL BOSS` に変換する。

`displayName`、`imagePath`、色、durationが欠けた場合はボス本体データと共通既定値へフォールバックする。存在しない画像パスでもクラッシュせず、戦闘用スプライトまたは名前だけで継続する。

## 8. 第一版の画像割り当て

専用カットインイラストが未支給のため、第一版は既存透過スプライトを使用する。後から `imagePath` の差し替えだけで専用絵へ移行できる。

| bossId | imagePath |
| --- | --- |
| `boss_kuso_maro_king` | `res://assets/generated/enemy_sprites_v1/kuso_maro_king.png` |
| `bugged_final_boss` | `res://assets/generated/enemy_sprites_v1/gameplay_bugged_final_boss.png` |
| `pitch_police_chief` | `res://assets/generated/enemy_sprites_v1/song_pitch_police_chief.png` |
| `red_pen_review_chief` | `res://assets/generated/enemy_sprites_v1/red_pen_retake_dragon.png` |
| `collab_crusher` | `res://assets/generated/enemy_sprites_v1/collab_crusher.png` |
| `boss_super_long_comment` | `res://assets/generated/enemy_sprites_v1/super_long_comment_boss.png` |
| `last_offline` | `res://assets/generated/relay_boss_v1/last_offline.png` |

テーマ初期値:

- 雑談: ピンク + 水色
- ゲーム実況: 水色 + 青紫
- 歌: ピンク + 黄
- お絵かき: ミント + ピンク + 黄アクセント
- コラボ: オレンジ + ピンク
- FINAL: 黒ベース + 赤紫 + 青紫 + 白ノイズ

## 9. 描画構造

`game.gd` の最前面オーバーレイとして `_draw_boss_cutin_overlay()` を追加し、通常HUD・指示コメカードより後に描く。

描画順:

1. 画面暗転
2. 共通の斜め帯背景
3. スピードライン・決定論的グリッチ
4. ボスイラスト
5. BOSS / FINAL BOSSラベル
6. サブタイトル
7. ボス名
8. 白フラッシュ・ノイズ破片
9. デバッグ情報（デバッグ時のみ）

共通背景は第一版ではCanvas描画で生成し、共通画像が後日支給された場合は背景レイヤーだけ差し替えられる構造にする。ノイズの乱数はゲーム本体のRNGを消費せず、`bossId + 表示フレーム番号` から決定論的に生成する。

1600x900を基準とし、既存の画面スケーリングへ追従する。

- イラスト領域: 左右どちらか、画面高の約45～55%
- テキスト領域: イラストと反対側
- `imageScale`、`imageOffset`、`flipH` を反映
- 画像はcontainで収め、縦横比を維持
- 左右反転は描画transformで行い、元画像を加工しない
- ボス名は原則1行、最大幅内に収まるまで最大64～72pxから最小34pxまで自動縮小
- サブタイトル空欄時は非表示にしてボス名位置を補正

## 10. タイムライン

### 通常 1.50秒

| 時刻 | 内容 |
| --- | --- |
| 0.00 | 状態切替、暗転開始、開始SE |
| 0.10 | 斜め帯とノイズ表示 |
| 0.18～0.45 | イラストを横からスライド、軽いオーバーシュート |
| 0.35 | BOSSラベルをフェード + スライド |
| 0.45～0.72 | 名前を0.90→1.05→1.00倍で表示 |
| 0.65～0.73 | 短い決めフラッシュ、決めSE |
| 0.73～1.18 | 保持、イラストをごく小さく揺らす |
| 1.18～1.50 | 全体フェードアウト |

### FINAL 2.40秒

| 時刻 | 内容 |
| --- | --- |
| 0.00 | 状態切替、強めの暗転、開始SE |
| 0.12 | 強いノイズ帯・スラッシュ |
| 0.22～0.58 | イラストをスライドイン |
| 0.45 | FINAL BOSS表示 |
| 0.65 | サブタイトル表示 |
| 0.82～1.16 | ボス名表示 |
| 1.10～1.20 | 強い決めフラッシュ、FINAL決めSE |
| 1.20～2.00 | ノイズを残して保持 |
| 2.00～2.40 | 終了演出とフェードアウト |

タイムラインは絶対秒を直接描画側へ散らさず、`BossCutinSystem.build_view()` が `imageProgress`、`labelAlpha`、`nameProgress`、`flashAlpha`、`noiseIntensity`、`exitAlpha` を返す。

## 11. SE

第一版はデータ上の `seType` を共通SE定義へ解決する。

- `boss_normal`: 短い侵入音 + 名前決め音
- `boss_final`: 通常より重い侵入音 + FINAL決め音

専用素材が未支給なら既存SEを暫定利用する。

- 侵入音候補: `res://assets/audio/collab_cut_in_sharp.mp3`
- 通常決め音候補: `res://assets/audio/confirm_select.mp3`
- FINAL決め音候補: `res://assets/audio/boss_warning.mp3`

SEパスは1か所の定義に置き、ボススクリプトへ直書きしない。再生失敗は演出完了を妨げない。第一版ではBGM音量を変更せず、ボスBGMは実体spawn後に既存条件で開始する。

## 12. デバッグ

```gdscript
debug_play_boss_cutin("boss_kuso_maro_king")
debug_play_boss_cutin("last_offline")
```

デバッグ再生は `completionAction = "debug_return"` とし、ボスをspawnしない。終了後は開始前stateへ戻し、PauseReasonを残さない。既にボス戦、別モーダル、ゲームオーバー処理中なら開始を拒否する。

既存デバッグ表示が有効な場合のみ、次を小さく表示する。

- bossId
- displayName / subTitle
- labelType
- durationSeconds
- imagePath
- isFinalBoss

未確認のキーへ新しいショートカットを割り当てない。既存DebugSystemの未使用アクションが確認できた場合のみ接続する。

## 13. 変更対象

- 新規 `scripts/systems/boss_cutin_system.gd`
- `scripts/game.gd`
- `scripts/systems/boss_system.gd`
- `scripts/systems/state_flow_system.gd`
- `data/bosses.json`
- `data/relay_mode.json`
- 必要に応じて既存DebugSystemとSE定義箇所

通常ボスの個別スクリプトやラスボスAIへ、演出タイムライン・色・固定秒数を重複実装しない。

## 14. テスト項目

### 自動・ヘッドレス確認

1. JSON構文チェック
2. Godot `--check-only` とheadless起動
3. 通常1.50秒、FINAL 2.40秒で完了する純粋タイムラインテスト
4. 完了フラグが複数フレーム続いてもcallbackが1回だけであること
5. watchdog完了、キャンセル、リセットで `BossCutin` pause reasonが残らないこと

### 通常ボス

1. 3秒警告終了後、カットイン中はボス実体が存在しない
2. カットイン完了後に対象ボスが1体だけspawnする
3. カットイン開始時に雑魚・敵弾・攻撃予告が報酬なしで消える
4. カットイン中にstage elapsed、指示コメ残り時間、バフ残り時間、プレイヤー位置が変化しない
5. 5枠すべてで正しい名前、色、画像になる

### ラスボス

1. 最終休憩→既存枠イントロ→FINALカットイン→ラストオフラインの順になる
2. カットイン中にラストオフラインが生成されない
3. 完了後に1体だけ生成され、0.30秒の安全時間後に戦闘が始まる
4. `FINAL BOSS` と `配信終焉体` が表示される

### 表示

1. 1600x900と1280x720でイラスト、ラベル、名前が重ならない
2. 長いボス名が1行で自動縮小される
3. 画像欠損時も名前だけで演出完了する
4. `flipH`、`imageScale`、`imageOffset` が反映される
5. 通常とFINALの強さ・長さが明確に異なる

## 15. 完成条件

- 通常5枠、フォールバック通常ボス、ラストオフラインが同じ共通システムを使用する
- 通常ボスは約1.5秒、FINALは約2.4秒
- カットイン中はゲーム内の全時間進行が止まる
- カットイン前に通常ボス用の戦場整理が行われる
- カットイン完了後だけボスをspawnする
- spawn、停止解除、完了callbackが重複しない
- 専用イラスト・色・SEを後からデータ差し替えできる
- デバッグ単体再生では実際のボス戦を開始しない

