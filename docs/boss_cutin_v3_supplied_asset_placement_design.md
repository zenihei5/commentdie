# ボス登場カットイン・支給素材配置設計

## 1. 目的と範囲

支給された20点を、実装済みBossCutin V3のフレーム駆動runtimeへ組み込む。
ゲーム停止、ボス予約spawn、field handoff、HPバー、BGM duck、総演出時間は変更しない。

今回の変更は次の2種類に限定する。

- 全ボス共通の背景、名前プレート、名前impactを画像化する。
- V3固有イントロの図形代用部分を、対応する支給画像へ置き換える。

基準座標は既存描画と同じ1600x900。1280x720では既存Canvasのスケールに従う。

## 2. 加工済み素材

ルート:

`res://assets/generated/boss_cutin_v3_assets/`

- 緑背景19点はRGBA化し、緑かぶりも除去済み。
- `boss_cutin_bg_common.png`だけは完成背景なので、不透明のまま保持。
- マシュマロatlasは元画像に加え、`marshmallows/marshmallow_01.png`から`25.png`へ分割済み。
- 寸法、元画像内bounds、alpha統計は`manifest.json`に記録。
- QC画像は`docs/images/boss_cutin_v3_assets_qc.png`。
- 可視alphaを持つ強い緑色ピクセルは19点合計0。

## 3. 共通レイヤー順

描画順は次で固定する。

1. 既存暗転
2. `boss_cutin_bg_common.png`
3. theme/accentの薄い色面と背景preset
4. 固有`intro_back`画像
5. ボスイラスト、silhouette、ghost
6. 固有`intro_front`画像
7. `boss_cutin_impact_lines.png`
8. BOSS/FINAL名前プレート
9. BOSSラベル、サブタイトル、ボス名
10. 固有`finale`画像
11. 演出コメント、ノイズ、軽減設定対応flash
12. field pose、HPバー

右コメント欄は現在どおりカットインより下へ置く。支給素材を通常HUD側へ描かない。

## 4. 共通素材の配置

### 共通背景

`boss_cutin_bg_common.png`

- `Rect2(0, 0, 1600, 900)`へ全面描画。
- 通常ボスalpha 0.82、FINAL alpha 0.92。
- 背景上へ黒を0.12から0.22重ね、白文字のコントラストを確保する。
- 既存theme/accent polygonは現在の約55%のalphaへ下げる。
- 読み込み失敗時だけ既存のprocedural背景へfallbackする。

### 名前impact

`boss_cutin_impact_lines.png`

- text側の中心を基準に`Rect2(text_center.x - 270, 180, 540, 540)`。
- `nameImpactProgress`の立ち上がりから0.14秒だけ表示。
- 通常alpha上限0.42、FINAL 0.58。
- 名前プレートと文字より必ず背面。reducedFlash時は上限を0.24にする。

### 通常名前プレート

`boss_cutin_label_boss.png`

- `Rect2(text_x - 20, 376, 900, 120)`。
- alphaは`nameProgress * exitAlpha`。
- ボス名の有効横幅は790px。名前は1行、自動縮小34pxまで。
- 白いプレート内ではボス名を濃紺`#17112b`、outlineを白またはthemeの薄色にする。
- 既存の長い下線は削除するか、プレート内幅へ短縮する。

### FINAL名前プレート

`boss_cutin_label_final.png`

- `Rect2(text_x - 5, 390, 900, 90)`。
- ボス名は白、outlineは黒紫。FINAL BOSSラベルとサブタイトルはプレート上部の既存位置を維持。
- 通常プレートと同時表示しない。

### 共通glitch破片

`boss_cutin_glitch_fragments.png`

- V3固有イントロのimpactまたはhandoffだけで使う。
- 基本`Rect2(520, -40, 940, 940)`、alpha 0.12から0.24。
- 常時表示しない。名前の可読領域ではalphaを半分にする。

## 5. 固有素材の配置

### クソマロキング `marshmallow_pile`

- procedural circle 8個を分割済みマシュマロ画像へ置換する。
- 使用候補は`01, 03, 07, 09, 12, 14, 18, 22`。同一カットイン内で重複させない。
- 既存のstart/landing座標を維持し、各画像を幅62から86pxで描画する。
- `customIntroProgress`で落下、着地時だけ縦0.82・横1.16のsquash。reveal開始後はalpha 0.28まで下げる。

`cutin_decor_kusomaro_crown.png`

- procedural crownを置換する。
- finale開始時`Rect2(1330, 300, 145, 107)`、impact時`Rect2(1330, 365, 145, 107)`。
- 通常名前プレート右端の空き領域へ、名前より前面のfinaleレイヤーで落とす。独自の早消しは行わず、ボス画像・名前表示と同じfield handoff alphaで同時に消す。
- field poseでは別の王冠実体を作らない。

### バグったラスボス `bugged_game_final_boss`

`cutin_bug_loading_bar.png`

- `Rect2(90, 650, 620, 71)`。
- 既存の0.82停止、0.74逆行ロジックを維持し、画像は外枠として使う。
- 内側fillは`Rect2(184, 675, 432, 18)`へ既存block描画を縮尺調整する。

`cutin_bug_horizontal_noise.png`

- `Rect2(-20, 334, 1640, 250)`。
- 0.34秒から0.75秒のglitch区間だけ表示し、毎フレームxを最大12pxずらす。
- alpha上限0.62。reducedNoise時は0.28、ずれ幅6px、表示回数を半減する。

`cutin_bug_pixel_fragment.png`

- `Rect2(50, 100, 650, 650)`へボス画像周辺の欠けとして表示。
- `sliceStrength`または`ghostAlpha`をalphaへ使い、上限0.34。
- 既存RGB split、horizontal slice、ghost本体描画は残す。

`boss_cutin_glitch_fragments.png`

- revealと3分裂handoffにだけ追加。描画専用で敵実体を増やさない。
- reducedNoise時は非表示でもよい。

### 赤ペンリテイクドラゴン `redpen_rewrite`

`cutin_redpen_line_set.png`

- `intro_back`へ`Rect2(55, 205, 650, 366)`。全atlasを校正メモ面として使う。
- alpha上限0.48。0.08秒ずつ段階的にclip幅を広げ、左から書かれるように見せる。

`cutin_redpen_circle.png`

- `intro_front`へ`Rect2(105, 130, 570, 564)`。
- p=0.16から0.58で0.92倍から1.0倍へ拡大し、alpha上限0.86。

`cutin_redpen_cross.png`

- `intro_front`へ`Rect2(105, 145, 570, 524)`。
- p=0.56以降のimpactで0.88表示し、color revealまでに0.18へ落とす。
- 既存の太いprocedural Xと4本線は同時描画しない。

### コラボクラッシャー `split_stream_crash`

`cutin_collab_vs_mark.png`

- `Rect2(675, 270, 250, 264)`。0.85倍から1.0倍へpop。
- split impact開始時にfadeし、名前領域を塞がない。

`cutin_collab_crack.png`

- `Rect2(685, 5, 230, 827)`。
- p=0.42以降に中央から縦方向へclip reveal。impact時alpha 0.95、名前表示中0.30。

`cutin_collab_broken_heart.png`

- finale開始時は`Rect2(735, 492, 130, 114)`へ全体表示。
- impact後は左右半分をUV cropし、左を24px左、右を24px右へ移動してfadeする。
- 既存procedural VS、白い中央線、heartは同時描画しない。
- field poseのheartは最大110pxに縮小し、攻撃判定や敵実体を持たせない。

### ラストオフライン `stream_shutdown`

4点はボス画像への厳密な部位overlayではなく、実体reveal前に中央へ一瞬形成される異常な顔として使う。ボス実体画像自体には焼き付けない。

`cutin_lastoffline_power_icon.png`

- 0.10秒から0.60秒、`Rect2(710, 315, 180, 179)`。
- 0.82倍から1.0倍へpulseし、その後coreへ吸収する。

`cutin_lastoffline_eye_glow.png`

- 0.26秒から0.92秒、`Rect2(470, 180, 660, 198)`。
- alpha上限0.78。reducedFlash時は0.52。

`cutin_lastoffline_mouth_glow.png`

- 0.45秒から1.05秒、`Rect2(520, 380, 560, 200)`。
- alpha上限0.72。目より遅れて出し、同時に明滅させない。

`cutin_lastoffline_core_glow.png`

- 0.72秒から1.25秒、`Rect2(690, 570, 220, 216)`。
- 1.08秒のsilhouette開始から縮小・fadeし、実体revealへ接続する。
- 既存procedural eye/core/powerは置換し、二重表示しない。

FINAL名前表示では`boss_cutin_label_final.png`を使用し、共通glitch破片を通常より強めのalpha 0.22で一度だけ出す。

## 6. 実装構造

既存`BossCutinSystem`の時刻とeventは変更しない。`BossCutinCustomIntroSystem`が返すpartへ汎用`texture`型を追加する。

必要フィールド:

- `type: "texture"`
- `layer`
- `path`
- `rect`
- `color`または`alpha`
- 任意の`sourceUv`。atlasやheart左右分割で使用する。
- 任意の`scaleCenter`。pop、squash、吸収用。

`game.gd::_draw_boss_cutin_custom_parts()`でTextureCacheを使って描画する。毎フレームImageを再読込しない。texture欠損時は、そのpartだけ既存procedural表現へfallbackする。

共通背景、impact lines、名前プレートはcustom part上限へ数えず、`_draw_boss_cutin_overlay()`の共通レイヤーとして描く。

## 7. 軽減設定と安全性

- reducedFlash: 白flashを増やさず、impact linesと目/coreのalphaを低下。
- reducedNoise: noise帯、pixel fragments、glitch fragmentsのalpha・回数・ずれ幅を半減。
- reducedShake: 支給画像の位置jitterも停止。
- cancel/watchdog後にtexture partを残さない。
- handoff画像、heart片、pixel片は描画専用。敵、弾、当たり判定を生成しない。
- 既存のspawn時刻、field lock、AI lock、damage lockを変更しない。

## 8. 受け入れ条件

- 20点が所定パスから読め、緑背景が見えない。
- 通常/FINAL名前プレート内で全ボス名が1行に収まる。
- クソマロ、バグ、赤ペン、コラボ、ラストオフラインで対応素材が別々に再生される。
- procedural代用品との二重描画がない。
- 通常V1/V2ボスは共通背景・名前プレートだけが追加され、既存進行を維持する。
- 1600x900と1280x720で欠け、比率崩れ、右コメント欄の前面化がない。
- reducedFlash/reducedNoise/reducedShakeが画像素材にも反映される。
- texture欠損時もカットインが完了し、ボスは1体だけspawnする。
- 既存のV3 timeline、F7/F10デバッグ経路、通常/FINAL統合テストが通る。
