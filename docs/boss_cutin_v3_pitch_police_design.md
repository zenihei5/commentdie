# BossCutin V3 音程警察長・固有イントロ接続設計

## 1. 接続方針

歌枠ボス`pitch_police_chief`を、既存のフレーム駆動BossCutin V3へ追加する。
独立Overlay、専用awaitシーケンス、常駐サイレンloopは作らない。

既存のpause、BGM duck、予約spawn、field handoff、登場ロック、HPバー、F8/F10経路をそのまま使う。固有イントロは`BossCutinCustomIntroSystem.build_view()`が時刻から毎フレーム再構築する描画データにする。

原仕様の`silhouette_prepared`フラグは、現在の実装では不要。実体画像の移動は既存`imageEntryOffset`が1回だけ行うため、固有イントロ側は音程ラインを押しのけるところまで担当し、共通silhouette entryへ接続する。

## 2. ID・表記・データ更新

実データを優先し、次を使用する。

- `bossId`: `pitch_police_chief`
- `displayName`: `音程警察長`
- `customIntroId`: `pitch_violation_crackdown`
- `customCommentPoolId`: `cutin_pitch_police_chief`
- `introPoseId`: `pitch_police_crackdown`

現在、ボス本体の`displayName`は「音程警察長」だが、cutin内だけ「音程警察署長」になっている。cutin側を本体表記へ合わせる。サブタイトルは仕様どおり空文字にする。

`data/bosses.json`のcutin設定は以下へ更新する。

```json
{
  "version": 3,
  "displayName": "音程警察長",
  "subTitle": "",
  "labelType": "boss",
  "imagePath": "res://assets/generated/enemy_sprites_v1/song_pitch_police_chief.png",
  "themeColor": "#ff5d91",
  "accentColor": "#73d9ff",
  "noiseColor": "#fff7d8",
  "bgStyle": "singing",
  "durationSeconds": 2.25,
  "imageSide": "left",
  "entryDirection": "right",
  "customIntroId": "pitch_violation_crackdown",
  "customFinaleId": "",
  "customCommentPoolId": "cutin_pitch_police_chief",
  "customIntroDurationSeconds": 0.78,
  "replaceCommonThemeIntro": false,
  "useSilhouetteReveal": true,
  "useCommentBurst": true,
  "connectImageToBossSpawn": true,
  "useBossIntroPose": true,
  "introPoseId": "pitch_police_crackdown",
  "bgmDuckVolumeMultiplier": 0.52,
  "customSeType": "pitch_police_boss",
  "seType": "boss_normal",
  "isFinalBoss": false
}
```

専用カットイン画像が別途ないため、第一版では既存の戦闘用透過画像を使う。画像追加時に`imagePath`だけ差し替えられる構造を維持する。

## 3. 加工済み素材

ルート:

`res://assets/generated/boss_cutin_v3_assets/`

- `cutin_pitch_line.png`: 2099x453
- `cutin_pitch_violation_marker.png`: 1135x1060
- `cutin_pitch_police_siren.png`: 928x660

3点ともRGBA化、緑かぶり除去済み。可視alphaを持つ強い緑色ピクセルは0。
寸法・alpha統計は同ディレクトリの`manifest.json`、透過確認は`docs/images/boss_cutin_v3_assets_qc.png`を参照する。

## 4. V3タイムラインへの割り当て

既存`_v3_timings()`へ2.25秒と固有イントロ0.78秒を渡すと、次の時刻になる。この計算結果を変更せず使う。

| 時刻 | 処理 |
| ---: | --- |
| 0.06 | 音程ラインを左からclip reveal |
| 0.14 | 歌声ラインの進行開始 |
| 0.35 | 大きな音程ずれ、軽い振動 |
| 0.43 | 違反マーカーlock-on |
| 0.50 | サイレン交互点灯開始 |
| 0.74 | `custom_intro_impact`で警告SE |
| 0.70-0.88 | ラインとマーカーを左右へ退場 |
| 0.78 | 既存共通silhouette entry開始 |
| 0.95 | color reveal |
| 1.05 | BOSSラベル |
| 1.18 | ボス名impact |
| 1.35 | 演出コメント |
| 1.60 | field接続開始 |
| 1.915 | ロック付き実体を1体spawn |
| 1.95 | field pose開始 |
| 2.13 | HPバー表示 |
| 2.25 | 停止解除・戦闘開始 |

サイレン、ライン、マーカーは名前表示前までにalpha 0へする。`customIntroProgress`は終了後1.0を保持するため、各素材はprogressだけでなく`elapsed`による退場envelopeを必ず持つ。

## 5. 1600x900配置

### 音程ガイド

`cutin_pitch_line.png`を2回描画する。

ガイドライン:

- `intro_back`
- `Rect2(130, 392, 1340, 120)`
- Colorは水色白、alpha上限0.58
- 元画像を縦方向へ圧縮し、正解帯として見せる

歌声ライン:

- `intro_front`
- `Rect2(130, 300, 1340, 280)`
- ピンク寄り、alpha上限0.96
- 0.06秒から0.25秒でsource UVの横幅を0から1へ伸ばす
- 画像内の大きな山が0.35秒付近に現れるため、追加の大変形は不要
- ずれimpact時だけ全体を上下8px、左右4px以内で振動させる
- reducedShake時は振動0
- reducedNoise時は振動量を50%にする

0.70秒以降、左半分を左へ140px、右半分を右へ140px移動し、0.88秒までにfadeする。左右分割は`sourceUv`を使い、実体や別ノードを生成しない。

### 違反マーカー

`cutin_pitch_violation_marker.png`

- `intro_front`
- 基準`Rect2(525, 185, 250, 234)`
- 歌声ラインの大きな上方向peakを囲う
- 0.43秒でscale 1.40、0.51秒で0.92、0.56秒で1.00
- 通常時は0.09秒周期で最大2回だけ明度を変える
- reducedFlash時は点滅せず、1回の拡縮だけ
- 0.70秒から縮小、0.88秒までに非表示

### 警告灯

`cutin_pitch_police_siren.png`

- `intro_front`
- `Rect2(650, 72, 300, 213)`
- 全体をalpha 0.32で常時下地表示し、左右halfを`sourceUv`で重ねる
- 左halfは赤・ピンク、右halfは青・水色のまま使用
- 0.50秒から0.11秒周期で左右を交互にalpha 1.0 / 0.22へ切り替える
- 2から4往復で終了し、1.05秒までに非表示
- reducedNoise時は周期0.18秒、alpha上限0.62
- reducedFlash時はalpha上限0.58

左右点灯に合わせ、画面上部左/右へtheme/accent色の半透明polygonをalpha 0.10から0.18で描く。全画面を赤や青へ染めない。

### 共通素材との重なり

- `boss_cutin_bg_common.png`と通常BOSS名前プレートは既存の支給素材統合をそのまま利用する。
- `boss_cutin_impact_lines.png`は名前impact時のみ。音程マーカーとは同時に最大alphaへしない。
- ボス名表示時はライン、マーカー、サイレンを描かない。

## 6. フレーム駆動metrics

`BossCutinCustomIntroSystem.INTRO_IDS`へ`pitch_violation_crackdown`を追加し、`_pitch_police_parts(view, data)`を呼ぶ。

必要な決定論metrics:

- `pitchLineReveal`
- `pitchDeviationProgress`
- `pitchPushProgress`
- `violationMarkerAlpha`
- `violationMarkerScale`
- `sirenAlpha`
- `sirenSide`
- `sirenCycleSeconds`
- `reducedFlashApplied`
- `reducedNoiseApplied`
- `reducedShakeApplied`

`sirenSide`はloop coroutineではなく次で決める。

```gdscript
var cycle := 0.18 if reduced_noise else 0.11
var siren_side := int(floor(maxf(0.0, elapsed - 0.50) / cycle)) % 2
```

これによりcancel/watchdog時にloopやTweenが残らない。custom viewが空になれば全素材も消える。

前回追加した汎用`texture` partと`sourceUv`を使う。素材欠損時は次へfallbackする。

- line欠損: procedural horizontal guideと折れ線
- marker欠損: 赤黄の角枠
- siren欠損: 上部左右の赤/水色polygon

固有素材1点の欠損を理由にV2共通全体へ戻す必要はない。ボス画像またはcustom handler自体が不正な場合のみ既存共通fallbackを使う。

## 7. 音・コメント・field pose

コメントプールへ次の8件を追加し、既存ロジックで重複なし3から5件を選ぶ。

```json
{
  "cutin_pitch_police_chief": [
    "音程警察きた！",
    "取り締まり始まった",
    "音外したら捕まる？",
    "警察長でかい！",
    "採点厳しそう",
    "歌い直しですか？",
    "サイレン鳴ってる！",
    "音程見られてる！"
  ]
}
```

SEは新規素材がないため、第一版では`customSeType == "pitch_police_boss"`の`custom_intro_impact`で既存`boss_warning.mp3`を1回使う。名前impactは既存confirm SEを使う。`stream_end_whistle.mp3`は用途が異なるため、音を確認せず流用しない。

field poseへ`pitch_police_crackdown`を追加する。

- spawn中心から白、ピンク、水色のringを2から3本、半径28から105pxへ拡大
- 表示時間0.22秒
- damage、knockback、弾消し、collision、ライブテンション変化なし
- 既存intro lock中の描画だけにし、AI・攻撃・接触・被弾・player操作・timer停止を維持

## 8. 検証条件

- `pitch_police_chief`だけがV3 2.25秒、custom intro 0.78秒になる。
- 表示名が「音程警察長」に統一される。
- 音程ラインが左から現れ、大きなpeakをmarkerが捕捉する。
- サイレンが左右交互に2から4往復し、名前表示前に消える。
- silhouetteは既存共通描画で1回だけ登場する。
- コメントは3から5件、重複なし、通常コメント履歴へ入らない。
- field上のボス実体は1体だけ。
- 音波ringは描画専用でゲーム効果がない。
- reducedFlash/reducedNoise/reducedShakeが画像素材へ反映される。
- cancel/watchdog/texture欠損後にライン、marker、sirenが残らない。
- 1600x900と1280x720でライン、ボス名、コメントが重ならない。
- 既存5体のV3、V1/V2、F8/F10、予約spawn、PauseReasonの回帰テストが通る。
