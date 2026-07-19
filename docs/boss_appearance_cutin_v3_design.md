# ボス登場カットイン第3版 実装設計

## 1. 実装方針

完成済みの第2版 `BossCutinSystem`、予約spawn、登場ロック、field handoff、HPバー、BGM duck、F10経路を維持する。Controlシーンや `await` ベースへ作り直さず、現在の決定論的なフレーム駆動runtimeへ固有イントロphaseを追加する。

追加構成:

- `BossCutinSystem`: V3用timing、CUSTOM_INTRO / CUSTOM_FINALE phase、one-shotイベント
- 新規 `BossCutinCustomIntroSystem`: intro registry、固有progress、決定論的な演出パーツ生成
- `game.gd`: 固有描画、SE、コメント表示snapshot、異常終了復帰
- 既存Boss/RelayBoss描画: field intro poseの固有差分だけを受ける

固有イントロ未設定、不明ID、素材欠損では第2版の同じボスへfallbackする。

## 2. 既存IDとの対応

仕様書の表示名と実装IDを次へ固定する。

| 表示名 | 実装bossId | customIntroId |
| --- | --- | --- |
| クソマロキング | `boss_kuso_maro_king` | `marshmallow_pile` |
| 赤ペンリテイクドラゴン | `red_pen_review_chief` | `redpen_rewrite` |
| コラボクラッシャー | `collab_crusher` | `split_stream_crash` |
| ラストオフライン | `last_offline` | `stream_shutdown` |

仕様書表では赤ペンリテイクドラゴンが歌枠と書かれているが、既存実装ではお絵かき枠ボスである。第3版演出だけを追加し、配信枠、`bgStyle = drawing`、出現条件は変更しない。

## 3. データ互換

`BossCutinSystem.normalize_data()` へ追加する。

```text
customIntroId = ""
customFinaleId = ""
customCommentPoolId = ""
customIntroDurationSeconds = 0.0
replaceCommonThemeIntro = false
useFakeNameCorrection = false
customSeType = ""
```

`customIntroId != ""` のときversionを3へ上げる。version 1/2のデータとtimingは変更しない。

対象データ:

```json
{
  "version": 3,
  "customIntroId": "marshmallow_pile",
  "customFinaleId": "marshmallow_crown_drop",
  "customCommentPoolId": "cutin_kusomaro_king",
  "customIntroDurationSeconds": 0.55,
  "replaceCommonThemeIntro": false,
  "useFakeNameCorrection": false,
  "durationSeconds": 2.10
}
```

推奨総時間:

- クソマロキング: 2.10秒
- 赤ペンリテイクドラゴン: 2.15秒
- コラボクラッシャー: 2.20秒
- ラストオフライン: 3.40秒

ゲーム実況、歌、超長文ニキなど未設定ボスは第2版1.80秒のまま。

## 4. タイムライン再配置

固有イントロ時間を第2版へ単純加算しない。V3では共通theme後にcustom segmentを置き、最後の0.10秒をsilhouette開始と重ねる。field handoffからfinishまでの長さは第2版と同等に保つ。

### 通常V3

```text
themeStart = 0.08
customStart = 0.10
customEnd = customStart + customIntroDurationSeconds
silhouette = customEnd - 0.10
reveal = silhouette + 0.17
label = reveal + 0.10
subtitle = reveal + 0.14
name = reveal + 0.23
comments = name + 0.17
connect = duration - 0.65
spawn = duration - 0.335
field = duration - 0.30
hp = duration - 0.12
finish = duration
```

### FINAL V3 3.40秒

```text
themeStart = 0.08
customStart = 0.10
customEnd = 1.20
silhouette = 1.08
reveal = 1.25
label = 1.42
subtitle = 1.58
name = 1.75
comments = 1.98
connect = 2.75
spawn = 3.047
field = 3.08
hp = 3.28
finish = 3.40
```

`stream_shutdown` は第2版の5枠sequenceを内包するため `replaceCommonThemeIntro = true` とし、V2 motifとV3 motifを二重描画しない。

## 5. phaseとイベント

第2版phaseへ追加する。

```text
CUSTOM_INTRO
CUSTOM_FINALE
```

`CUSTOM_INTRO` はtheme後からsilhouette接続まで、`CUSTOM_FINALE` は名前impact直前の短い装飾区間。固有処理から次phase、spawn、finishを直接呼ばない。

one-shotイベント:

- `custom_intro_start`
- `custom_intro_impact`
- `custom_intro_finish`
- `custom_finale_start`
- `custom_finale_impact`
- 既存 `reveal_flash` / `name_impact` / `spawn_boss_locked` / `finish`

deltaがイベント時刻を飛び越えても1回だけ発火する。watchdogは `duration + 0.5秒` を維持する。

## 6. 固有イントロシステム

新規 `scripts/systems/boss_cutin_custom_intro_system.gd` を追加する。

```gdscript
class_name BossCutinCustomIntroSystem
extends RefCounted

static func supports_intro(intro_id: String) -> bool
static func supports_finale(finale_id: String) -> bool
static func build_view(data: Dictionary, runtime: Dictionary, common_view: Dictionary) -> Dictionary
static func effect_parts(custom_view: Dictionary) -> Array[Dictionary]
```

Node参照やゲーム状態は保持しない。context相当はDictionaryで渡す。

```text
bossId
cutinData
imageRect
spawnWorldPosition
spawnScreenPosition
isFinalBoss
reducedFlash
reducedScreenShake
frame
```

`effect_parts` は描画命令データだけを返す。通常最大24、FINAL最大40。位置と種類はbossId + index + frameから決定論的に作り、ゲーム用RNGを消費しない。

将来の追加は `data/boss_cutin_v2.json` 内のrecipeへ既存handler typeと値を足すだけで可能にする。新しい表現方式そのものを追加する場合だけregistry handlerを増やす。

## 7. 描画

既存 `_draw_boss_cutin_overlay()` の共通背景後、silhouette前にcustom introを描く。`game.gd`を肥大化させないため、新規 `scripts/systems/boss_cutin_custom_draw_system.gd` へ固有描画を分離してよい。既存RelayBossDrawSystemと同様、CanvasItem targetへdraw命令を出す。

描画順:

1. 暗転 / 共通背景
2. common theme、またはreplace時はcustom背景
3. CUSTOM_INTRO
4. 共通silhouette / reveal
5. label / subtitle
6. CUSTOM_FINALE
7. name impact
8. custom comment burst
9. field handoff / field pose / HP bar

素材がなければCanvas描画で成立させる。固有演出のために新規画像生成を必須にしない。

## 8. クソマロキング

### marshmallow_pile

- 8個を基本、データで6～12へclamp
- 画面上からboss image予定rect下部へ落下
- 白、薄ピンク、薄紫の丸みある2～3円の塊で描画
- 着地点を少しずらして積層
- 後半でpile scale 1.00→1.12→1.00
- pile内に簡易目2つと口を短時間表示
- 最終0.10秒で白ピンク片を外側へ飛ばし、共通silhouetteへcross-fade

### marshmallow_crown_drop

- name impactの0.16秒前から王冠を上から落下
- 画像の頭位置が未設定なら、名前帯の左上装飾へ着地
- 1回だけ小さくbounce
- 王冠衝撃とname impactの大SEを同一フレームに重ねない

### field pose

既存 `bounce` をV3用に強化し、膨張→1回jump→6個以下のマシュマロ片。描画専用で当たり判定なし。

## 9. 赤ペンリテイクドラゴン

### redpen_rewrite

- 薄白ピンクの仮silhouetteを先行表示
- 3～5本の修正記号を決定論的に選ぶ
- underline、circle、wave、check、crossをCanvas線で描画
- 後半で大きな赤いXを1回横切らせる
- X直後に線を左右へ裂き、共通silhouetteを見せる
- 線はcutin layer内だけに存在し、敵弾・hit area・damage eventを生成しない

`useFakeNameCorrection` は既定false。trueでも表示専用文字で、正式displayNameは変更しない。

### field pose

既存 `redline_pose` を使い、左右へ赤線を1本ずつ描く。ゲーム上の攻撃配列へ追加しない。

## 10. コラボクラッシャー

### split_stream_crash

- 左半面をピンク～赤、右半面を水色～青紫で描画
- 中央境界は初期2px白線
- custom progress中盤で境界を2～4px揺らす
- 中央にVS motif、周辺に配信枠風の小装飾
- 後半で紫黒のひび、割れハート、最大12個のnoise片
- 破裂時に中央が開き、共通silhouetteへ接続
- name impact時の左右寄せは0.10秒、名前guard rectを侵食しない

### field pose

既存 `collab_split` を使い、VS点灯→左右展開→割れハート。相方、パス、コラボチャレンジ状態を変更しない。

## 11. ラストオフライン

### コメント停止

現在 `_process()` の通常コメント更新条件に `state != "boss_cutin"` がないため、第3版着手時に追加する。完全停止仕様として通常・FINAL両方のカットイン中にChatSystem timerを進めない。

`stream_shutdown` 開始時、表示中の `chat_lines` から最大7件を `commentFeedSnapshot` としてruntimeへ複製する。通常chat Controlは従来どおり非表示にし、snapshotをcutin layerへ描画する。

- 0.00～0.25秒で上から順に横ずれ、欠け、alpha低下
- snapshotは表示専用で `chat_lines`、pool、recent duplicate履歴を変更しない
- 消失後はsnapshotを空として描画
- name後は `customCommentPoolId` の4～7件をcutin comment burstとして一気に表示
- finish/cancel/watchdogで通常chat Controlとtimerを必ず復帰

古いコメントをUIへ再表示しても進行上問題はない。仕様の「復元不要」を満たすため表示を置き換える場合も、永続poolや抽選履歴は変更しない専用UI overrideを使う。

### stream_shutdown

1. コメントsnapshotを停止・ノイズ消失
2. BGMを0.15秒で20%、続いて8%へ
3. 5枠アイコンを0.08秒間隔で表示
4. アイコンへ短い横ずれとscan line
5. 中央へ吸収
6. 画面中央へ電源終了symbolを0.15秒点灯・pulse
7. symbolをboss core位置へ縮小吸収
8. 目・口・core先行発光
9. 共通silhouette / revealへ接続

電源symbolは円弧 + 縦線でCanvas描画し、英字は出さない。eye/mouth/core素材があれば任意パスから読み、なければV2の正規化座標発光へfallbackする。

### field pose

既存 `last_offline_boot` を強化し、core点灯→5周辺パーツを順番に展開→浮上→glitch ring。既存RelayBossの攻撃・接触・フェーズ処理は `cutinIntroLocked` 中に動かさない。

## 12. BGM

V2の合成倍率 `boss_cutin_bgm_duck_scale` を維持する。AudioStreamPlayerの元volume_dbを上書き保存しない。

通常V3はV2と同じ0.55。FINAL V3だけcustom viewからpiecewise scaleを返す。

```text
0.00: 1.00
0.15: 0.20
0.35: 0.08
core点灯～name: 0.08～0.12
field handoff: 0.08
finish後: boss BGM mixのfade-inと同時に1.00へ滑らかに復帰
```

finish瞬間に旧BGMが一度だけ大音量へ戻らないよう、duck releaseはcutin runtime外の短いrelease stateで0.25～0.40秒継続できるようにする。cancel/resetは必ず1.0へ復元する。

## 13. SE

固有イベントを `customSeType` とevent idで既存SEへ解決する。素材未支給では既存SEを暫定利用し、無音でも進行を止めない。

- marshmallow: 軽い落下 / pile impact / crown
- redpen: stroke / paper break / name impact
- collab: split crack / burst / name impact
- shutdown: noise / absorb / core boot / final impact

大SEは1フレームに1つまで。固有impactと共通reveal/nameの時刻が近い場合、固有側を弱くするか0.04秒以上ずらす。

## 14. アクセシビリティ

- `screen_shake_enabled == false`: shakeを呼ばない
- flash軽減設定が存在する場合: 全画面白flashを使わず、alpha 0.50以下のtheme色反転へ置換
- noise軽減設定が存在する場合: glitch更新を15fps以下、横ずれ量50%以下
- 現在存在しない設定項目を、この改修だけのためにタイトル設定へ追加しない

## 15. cleanup

固有演出は毎フレームの描画データから生成し、Node、Tween、Particleを永続生成しない。これにより終了時cleanupはruntime破棄で完了する。

finish、cancel、watchdog、restart、title遷移で必ず行う。

- custom runtimeとeffect partsを空にする
- `commentFeedSuspended = false`
- comment snapshot / UI overrideを破棄
- BGM duckまたはreleaseを正常化
- spawn前なら予約破棄
- spawn後cancelなら報酬なし除去
- `BossCutin` PauseReasonを解除
- field boss lockを解除するのは正常finish時だけ

未知のintro/finale IDはwarningを1回だけ出し、第2版phaseへ継続する。

## 16. コメントデータ

既存 `data/boss_cutin_v2.json` の `commentPools` へ追加する。

```json
"cutin_kusomaro_king": [
  "マロでかすぎ！", "マロの王きた", "絶対ろくなこと書いてない", "王冠ついてる！", "全部クソマロじゃん"
],
"cutin_redpen_retake_dragon": [
  "またリテイク！？", "赤ペン持ってる！", "歌い直しさせる気だ", "先生きた", "全部直されそう"
],
"cutin_collab_crusher": [
  "不仲？", "空気悪くない？", "VSになってる！", "コラボ壊しにきた", "間に入ってきた！"
],
"cutin_last_offline": [
  "最後だ！", "負けないで！", "配信を終わらせるな！", "いけー！！", "勝ってくれ！", "ここまで来たんだ！"
]
```

優先順位は `customCommentPoolId` → V2 `commentPoolId` → `default_boss`。同一cutin内の重複を禁止する。

## 17. デバッグ

```text
debug_play_custom_boss_intro(intro_id)
debug_play_boss_cutin_v3(boss_id)
```

個別再生はvisual-onlyでspawn、chat履歴、BGM本再生を変更しない。全体再生のdebug returnも実体を残さない。F10は実戦経路としてV3 FINALを最後まで通す。

debug表示:

- bossId / customIntroId / customFinaleId
- phase / customProgress / effectPartCount
- commentFeedSuspended / snapshotCount
- prepared / spawned / spawnUid / battleActive
- PauseReasons / duckScale / duckRelease
- fallbackReason

## 18. 変更対象

- `scripts/systems/boss_cutin_system.gd`
- 新規 `scripts/systems/boss_cutin_custom_intro_system.gd`
- 必要なら新規 `scripts/systems/boss_cutin_custom_draw_system.gd`
- `scripts/game.gd`
- 通常/RelayBossの描画system
- `data/bosses.json`
- `data/relay_mode.json`
- `data/boss_cutin_v2.json`
- cutin test / integration test / capture test

## 19. 必須テスト

1. V1、V2データのtimingと挙動が変わらない
2. customIntroId空欄と未知IDがV2へfallbackする
3. 4ボスが指定duration内に終了する
4. custom introから共通silhouette、name、handoffへ1回だけ遷移する
5. 通常4ボスのhandoffで二重spawnしない
6. 固有演出がHP、score、buff、enemy bullets、challenge stateを変更しない
7. redpen/collabの演出線がdamage判定を持たない
8. part countが通常24、FINAL40以下
9. cutin中にChatSystem timerと通常コメント更新が進まない
10. FINAL snapshotが上から消え、履歴/poolを変更しない
11. FINAL name後に4～7件が重複なし表示される
12. finish/cancel/watchdogでchat表示と更新が復帰する
13. FINAL旧BGMの音量spikeがなく、ボスBGMへfadeする
14. field intro中はAI、攻撃、接触、被弾が無効
15. F10が3.40秒V3 FINALを通る
16. 素材欠損、未知intro、未知finale、座標不正の各fallbackで戦闘開始する
17. JSON、GDScript check-only、統合test、headless、`git diff --check`
18. 4固有introの1600x900 capture、FINALの1280x720 captureを確認
19. ボス画像、名前、コメント、VS、王冠、HPバーが重ならない
20. 右通常コメントControlがcutinより前面へ出ない

## 20. 完成条件

A→B→Cを順に実装・検証し、4ボスの固有intro、固有comment、field pose、FINAL shutdown、cleanup、fallback、アクセシビリティまで揃ってから第3版完了とする。固有演出未設定のボスは第2版の見た目・時間・spawn保証を維持する。
