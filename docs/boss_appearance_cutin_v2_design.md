# ボス登場カットイン第2版 実装設計

## 1. 方針

第1版の `BossCutinSystem`、`state = "boss_cutin"`、`PauseReason = BossCutin`、通常ボスと最終ボスの既存接続経路を維持する。別Overlay、Coroutine、`await`主体の新システムには置き換えない。

第2版は次の3層へ分ける。

- `BossCutinSystem`: タイムライン、phase、イベント境界、表示進捗を純粋計算
- `game.gd`: 描画、SE、BGMダッキング、コメント選択、出現予約とhandoffを統括
- `BossSystem` / `RelayBossSystem`: 予約済み座標への1回だけのspawnと、登場ロック解除

第2版フィールドがないボスは、現在の第1版タイムラインをそのまま再生する。

## 2. 仕様書からの構造適合

### 2.1 ボス事前生成

現在の敵はNodeではなく `enemies` 内のDictionaryである。カットイン開始時に実体を配列へ追加すると、既存システムのどこかがAI・接触・BGM・HUDを先行開始する危険がある。

そのため「事前生成」は次の予約データとして実装する。

```gdscript
{
  "bossId": "boss_kuso_maro_king",
  "worldPosition": Vector2.ZERO,
  "screenPosition": Vector2.ZERO,
  "prepared": true,
  "spawned": false,
  "active": false,
  "spawnUid": -1
}
```

カットイン開始時はspawn位置と表示情報だけを確定し、敵配列へは追加しない。`CONNECTING_TO_BOSS` の90%地点で既存spawn関数を1回だけ呼び、登場ロック付きで追加する。

- `cutinIntroLocked = true`
- `cutinVisualAlpha = 0.0`
- `cutinVisualScale` と `cutinVisualOffset` を描画だけに使用
- stateが `boss_cutin` のためAI・攻撃・接触・ステージ時間は更新されない
- HPは最大値のまま変更しない
- HUDは `SHOWING_HP_BAR` まで描画しない

この方式を第2版における `bossPrepared` と定義する。

### 2.2 実装方式

仕様書のNode/Tween/AnimationPlayer例は概念例として扱う。現在のコードに合わせ、`BossCutinSystem.update()` と `build_view()` の決定論的なフレーム更新で実装する。キャンセル・watchdog・debug returnを第1版と同じ経路へ通せるため、停止解除漏れを防げる。

## 3. タイムラインとphase

第2版有効時だけ次のphaseを使用する。

```text
PREPARING
THEME_INTRO
SILHOUETTE
REVEAL
NAME_IMPACT
COMMENT_BURST
CONNECTING_TO_BOSS
BOSS_INTRO_POSE
SHOWING_HP_BAR
FINISHING
```

runtimeへ追加する値:

```gdscript
{
  "version": 2,
  "phase": "PREPARING",
  "firedEvents": {},
  "selectedComments": [],
  "bossPrepared": false,
  "bossSpawned": false,
  "spawnUid": -1,
  "spawnWorldPosition": Vector2.ZERO,
  "spawnScreenPosition": Vector2.ZERO,
  "bgmDuckRestored": false
}
```

イベントは `previousElapsed < eventTime and elapsed >= eventTime` で検出し、deltaが大きくても取りこぼさない。`firedEvents` で次を1回だけ返す。

- `theme_sweep`
- `reveal_flash`
- `name_impact`
- `comment_burst`
- `spawn_boss_locked`
- `reveal_field_boss`
- `show_hp_bar`
- `finish`

### 通常ボス 1.80秒

| 時刻 | phase / 処理 |
| --- | --- |
| 0.00 | PREPARING、BGM duck開始 |
| 0.08 | THEME_INTRO |
| 0.15 | SILHOUETTE、画像スライド開始 |
| 0.32 | REVEAL、白フラッシュ、カラー化 |
| 0.42 | BOSSラベル |
| 0.55 | NAME_IMPACT、叩きつけ |
| 0.72 | COMMENT_BURST |
| 1.15 | CONNECTING_TO_BOSS開始 |
| 1.465 | 接続90%、実体を登場ロック付きで1回spawn |
| 1.50 | カットイン画像と実体をcross-fade |
| 1.50～1.72 | BOSS_INTRO_POSE |
| 1.68 | SHOWING_HP_BAR開始 |
| 1.80 | FINISH、ロック解除、戦闘開始 |

### ラストオフライン 2.80秒

| 時刻 | phase / 処理 |
| --- | --- |
| 0.00 | PREPARING、BGM duck開始 |
| 0.10～0.50 | 5枠モチーフを0.08秒間隔で表示 |
| 0.55～0.70 | 5枠モチーフを中央へ吸収 |
| 0.72 | 目・コア点灯 |
| 0.88 | SILHOUETTE |
| 1.05 | REVEAL、グリッチフラッシュ |
| 1.22 | FINAL BOSS |
| 1.38 | 配信終焉体 |
| 1.55 | NAME_IMPACT |
| 1.78 | COMMENT_BURST |
| 2.15 | CONNECTING_TO_BOSS開始 |
| 2.447 | 接続90%、実体を登場ロック付きで1回spawn |
| 2.48 | cross-fade |
| 2.48～2.72 | last_offline_boot |
| 2.68 | SHOWING_HP_BAR開始 |
| 2.80 | FINISH、ロック解除、戦闘開始 |

watchdogは従来どおり `duration + 0.5秒`。watchdog時にまだspawnしていなければ従来の完了actionでspawnし、進行不能を避ける。

## 4. BossCutinSystem拡張

`normalize_data()` に以下を追加する。第2版の既定値は仕様書どおりfalseで、第1版互換を維持する。

```text
version = 1
entryDirection = imageSide
flipImageX = flipH
useSilhouetteReveal = false
useCommentBurst = false
commentPoolId = default_boss
connectImageToBossSpawn = false
useBossIntroPose = false
introPoseId = generic
useRelayThemeSequence = false
bgmDuckVolumeMultiplier = 0.55
```

第2版は `version = 2` または第2版機能フラグが1つ以上trueなら有効にする。

`build_view()` は既存値に加えて次を返す。

```text
phase
themeIntroProgress
silhouetteAlpha
colorRevealProgress
imageEntryScale
imageEntryOffset
nameImpactProgress
nameImpactScale
commentBurstAlpha
connectProgress
cutinImageAlpha
fieldBossAlpha
fieldBossIntroProgress
hpBarProgress
bgmDuckProgress
relayMotifProgresses[5]
relayAbsorbProgress
preRevealCoreAlpha
```

叩きつけscaleは `1.40 -> 0.95 -> 1.00`、登場画像は `1.15 -> 0.98 -> 1.00`。オーバーシュートは20～40pxをデータのentryDirectionへ適用する。

## 5. spawn予約とhandoff

### 通常ボス

`BossSystem` に次を追加する。

```gdscript
static func prepare_spawn_for_target(target, arena, rng) -> Dictionary
static func spawn_prepared_for_target(target, prepared: Dictionary) -> Dictionary
static func unlock_intro_for_target(target, uid: int) -> void
```

`prepare_spawn_for_target()` は現在の `spawn_position_for_target()` を1回だけ呼び、boss id、data、HP倍率、報酬倍率、world positionを予約する。`spawn_prepared_for_target()` は予約位置を使い、位置抽選をやり直さない。

現在の `spawn_for_target()` は内部でprepare + spawn_preparedを呼ぶ互換ラッパーにし、第1版や他の呼び出しを壊さない。

### ラストオフライン

`RelayBossSystem` に次を追加する。

```gdscript
static func prepare_start_for_target(target, arena) -> Dictionary
static func start_prepared_for_target(target, arena, rng, prepared: Dictionary) -> int
static func unlock_intro_for_target(target, uid: int) -> void
```

予約にはarena中央のboss位置と、既存のplayer開始位置を含める。接続先screen positionは、予約player位置を使ったカメラ変換で先に算出する。spawn時に既存 `start_for_target()` と同じ初期化を行うが、二重初期化しない。

### 画面座標

3Dの `camera.unproject_position()` は使わない。現在の2D変換である `_screen_pos(worldPosition)` を使い、カメラoffsetとzoomを反映する。対象座標はFIELD_VIEW内へclampし、取得失敗や非有限値なら第1版フェードへfallbackする。

## 6. field boss登場ロック

spawn済みボスには次の表示専用値を持たせる。

```text
cutinIntroLocked
cutinVisualAlpha
cutinVisualScale
cutinVisualOffset
cutinIntroPoseId
cutinIntroPoseProgress
```

stateが `boss_cutin` のためworld updateは止まっているが、追加防御として通常ボス更新、RelayBoss攻撃、接触処理は `cutinIntroLocked` を検出したらreturnする。被弾判定も無効にする。

描画だけはalpha、scale、offsetを反映する。終了時に全値を標準へ戻し、ロック解除を1回だけ行う。

キャンセル時:

- handoff前なら予約を破棄し、実体なし
- handoff後ならspawn済み実体を報酬なしで除去
- `BossCutin`、BGM duck、HUD revealを必ずリセット

## 7. 背景プリセット

共通背景の上へ `bgStyle` ごとのCanvas描画を追加する。文字は描かず、ボス画像と名前のguard rectを避ける。

- `zatsudan`: 吹き出し輪郭、コメント片、マシュマロ形
- `gameplay`: ピクセルブロック、ゲームパッド記号、警告線
- `singing`: 音符、音波、ステージライト
- `drawing`: 筆跡、絵具飛沫、パレット形
- `collab`: VSを示す交差線、割れハート、分断線
- `final`: 電源断リング、グリッチ、5色の細い断片

モチーフの位置はbossIdとframeから決定論的に作り、ゲーム用RNGを消費しない。未定義styleは第1版共通背景のみ。

## 8. シルエットとラスボス先行発光

専用画像やShaderは必須にしない。同じTextureを暗いmodulateで描き、REVEAL時にカラー描画へcross-fadeする。

```gdscript
silhouetteColor = Color(0.05, 0.02, 0.08, alpha)
```

ラストオフラインはデータ駆動の正規化座標で発光を重ねる。

```json
"preRevealAccents": [
  {"type":"eye_pair", "x":0.50, "y":0.40, "scale":1.0},
  {"type":"core", "x":0.50, "y":0.58, "scale":1.0}
]
```

画像に合わない場合は座標調整だけで済むようにする。データなしなら中央core glowだけを表示する。

## 9. 演出専用コメント

新規 `data/boss_cutin_v2.json` を作り、DataRepositoryへ任意読込として追加する。

```json
{
  "commentPools": {
    "default_boss": ["ボスきた！", "でかい！", "やばそう", "勝てる？", "きたあああ！"],
    "kusomaro_king": ["マロでかすぎ！", "ボスきた！", "それ食べられる？", "やばいマロだ"],
    "last_offline": ["最後だ！", "負けないで！", "配信を終わらせるな！", "いけー！！", "勝ってくれ！"]
  }
}
```

開始時に専用ローカルRNGで通常3～5件、FINAL 4～7件を重複なし抽選し、runtimeへ固定する。ChatSystem、`chat_lines`、コメント履歴、スコア、ガチ応援抽選へは渡さない。

右側の通常コメントControlは第1版修正どおり `boss_cutin` 中は非表示を維持する。演出コメントは `_draw_boss_cutin_overlay()` 内で描くため、カットインより上へ飛び出さない。

配置は候補rectから、ボス画像の顔guard、名前rect、ラベルrectとの交差を除外して決める。配置不能なら件数を減らし、文字を重ねない。

## 10. 5枠モチーフ

ラストオフラインのみ、`data/stream_frames.json` の既存 `iconPath` を次の順で使用する。

1. zatsudan
2. gameplay
3. singing
4. drawing
5. collab

0.08秒間隔で表示し、横並びまたは浅い円弧へ配置する。0.55秒から中央coreへ吸収し、alphaとscaleを下げる。英字は描かない。ロード失敗したアイコンだけテーマ色の菱形へfallbackし、演出全体は続行する。

## 11. intro pose

第一版の敵AIへ個別Coroutineを追加せず、カットインruntimeから描画用progressを渡す。

| boss | introPoseId | 第一版の動き |
| --- | --- | --- |
| 超長文ニキ / クソマロキング | `bounce` | 小さく跳ね、テーマ片を散らす |
| バグったラスボス | `glitch_boot` | 横ずれとピクセル片 |
| 音程警察署長 | `spotlight_pose` | 小さな拡縮と音波 |
| 赤ペンリテイクドラゴン | `redline_pose` | 構え + 赤線1本 |
| コラボクラッシャー | `collab_split` | 左右方向の展開 + 割れハート |
| ラストオフライン | `last_offline_boot` | core点灯 + 周辺パーツ展開 + グリッチ波 |

個別描画が未対応なら `generic` の0.3秒fade + 0.94→1.02→1.00 scaleへfallbackする。

## 12. HPバー登場

カットイン中は通常の `_draw_boss_overlay()` / `_draw_relay_boss_hud()` を表示しない。`SHOWING_HP_BAR` だけ、同じHUD描画関数へ `revealProgress` を渡して描く。

- 背景alpha: 0→1
- 外枠幅: 中央から左右へ0→100%
- ボス名alpha: 0→1
- HP fillは最初から実HP比率。初登場時は100%
- HP値を0から増やさない

通常戦闘へ移った後は `revealProgress = 1.0` で従来表示と同一にする。

## 13. BGMダッキング

AudioStreamPlayerの `volume_db` を保存・上書きしない。現在の音量合成へ一時倍率を追加する。

```gdscript
var boss_cutin_bgm_duck_scale := 1.0
```

`_apply_bgm_volumes()` の最終scaleへ乗算し、設定音量、枠別音量、既存boss mixを保持する。

- 通常: 0.15秒で1.0→0.55、終了前0.30秒で1.0へ復帰
- FINAL: 0.15秒で1.0→0.40、終了前0.35秒で1.0へ復帰
- `_gameplay_bgm_should_play()` は `boss_cutin` を含め、カットイン開始時に曲を停止しない
- 再生中BGMがなければ何もしない
- finish、cancel、reset、watchdogで必ず1.0へ戻す

ボスBGMは従来どおり戦闘有効化後に開始し、通常用とFINAL用の分離を維持する。

## 14. SE・揺れ・フラッシュ

イベント境界で既存SEを割り当てる。大音量SEは同一フレームに1つまで。

- entry: sweep / cut-in sharp
- reveal: 軽い衝撃
- name impact: normal/final決定音
- field handoff: 出現音
- final core: boss warningまたはcore起動候補

`name_impact` で小、`reveal_field_boss` で中の `_request_screen_shake()` を呼ぶ。`screen_shake_enabled == false` なら既存処理で無効化される。フラッシュはカットインCanvas内で描き、通常0.55以下、FINAL0.70以下のalphaへ制限する。

## 15. データ更新

`data/bosses.json` と `data/relay_mode.json` の既存 `cutin` オブジェクトへ第2版フィールドを追加する。

```json
{
  "version": 2,
  "entryDirection": "left",
  "flipImageX": false,
  "useSilhouetteReveal": true,
  "useCommentBurst": true,
  "commentPoolId": "kusomaro_king",
  "connectImageToBossSpawn": true,
  "useBossIntroPose": true,
  "introPoseId": "bounce",
  "useRelayThemeSequence": false,
  "durationSeconds": 1.8,
  "bgmDuckVolumeMultiplier": 0.55
}
```

既存の `imagePath` / `imageSide` / `flipH` は読み続け、別名 `cutinImage` / `entryDirection` / `flipImageX` もnormalizeで受ける。データ移行中の互換性を確保する。

FINALはduration 2.8、duck 0.40、`useRelayThemeSequence = true`、`introPoseId = last_offline_boot`。

## 16. デバッグ

既存 `debug_play_boss_cutin()` とF10のFINAL直通を第2版へ接続する。

- 通常のvisual-only debugは実体をspawnしない。接続phaseはターゲットmarkerへ縮小し、最後はdebug return
- F10は実戦経路なので、予約→handoff spawn→intro→戦闘開始まで行う
- component debugはmode文字列で表示phaseを限定し、同じruntimeを使う

表示項目は仕様書の項目に加え、`spawnUid` と `completionDispatched` を出す。

## 17. 失敗時の復旧

- 画像なし: 戦闘用画像、それもなければ名前だけ
- comment poolなし: default、それもなければ省略
- motifなし: 共通背景
- spawn screen座標不正: 第1版fadeへ切替
- intro pose不明: generic
- handoff spawn失敗: finish時の既存completion actionで1回だけspawn
- BGM playerなし: duckを省略
- cancel後にspawn済み: 報酬なし除去

いずれも `BossCutin` pause reason、duck倍率、runtime activeを解除し、進行不能にしない。

## 18. 変更対象

- `scripts/systems/boss_cutin_system.gd`
- `scripts/systems/boss_system.gd`
- `scripts/systems/relay_boss_system.gd`
- `scripts/game.gd`
- 必要な通常・RelayBoss描画system
- `scripts/systems/data_repository.gd`
- `data/bosses.json`
- `data/relay_mode.json`
- 新規 `data/boss_cutin_v2.json`
- 自動テストscene/script

## 19. 必須テスト

1. 第2版フィールドなしデータが第1版1.5/2.4秒で完了する
2. 通常5枠とfallbackボスが1.8秒で1体だけspawnする
3. FINALが2.8秒で1体だけspawnする
4. handoff前は敵配列にボスがなく、90%地点で登場ロック付き1体だけ追加される
5. intro中にAI、攻撃、接触、被弾、指示コメ、stage elapsedが進まない
6. finish後にロック、PauseReason、duck倍率が残らない
7. cancelをhandoff前後それぞれで行い、残留ボスや二重spawnがない
8. HPバーが最大値のまま伸長表示される
9. comment burstが履歴、スコア、応援抽選へ影響しない
10. 同一コメントが同時重複しない
11. 右通常コメント欄がカットインより上へ出ない
12. 5アイコンが順番表示→中央吸収される
13. 画像・pool・style・座標・pose欠損の各fallbackで戦闘開始できる
14. BGMが設定値へ正確に復帰し、通常/FINALボス曲の分離を維持する
15. F10がFINAL v2 cut-in経由で開始する
16. JSON、Godot editor scan、headless起動、`git diff --check`
17. 1600x900と1280x720で通常代表1体とFINALのスクリーンショット確認

## 20. 完成条件

第1版の共通システムと停止保証を維持したまま、シルエット、名前impact、背景、演出コメント、field handoff、intro pose、HPバー、duck、FINAL 5枠sequenceがデータ駆動で動くこと。実装は優先順位A→B→Cで検証を挟みながら進めるが、第2版完了報告はA～Cすべての受け入れ条件を満たしてから行う。
