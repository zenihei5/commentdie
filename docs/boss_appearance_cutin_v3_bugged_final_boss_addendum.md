# ボス登場カットイン第3版 追加設計

## バグったラスボス

## 1. 対象と互換性

- 既存bossId: `bugged_final_boss`
- 配信枠: `gameplay`
- 既存背景: `bgStyle = gameplay`
- customIntroId: `bugged_game_final_boss`
- customFinaleId: `bugged_name_correction`
- customCommentPoolId: `cutin_bugged_final_boss`
- customIntroDurationSeconds: `0.65`
- カットイン総時間: `2.20`

第3版対象を5体へ増やすだけで、BossSystemの出現条件、HP、攻撃、報酬、通常/FINAL BGM分離は変更しない。固有handlerが失敗または未登録なら、同じボスの第2版カットインへfallbackする。

## 2. V3 timeline

既存V3 timing式へ0.65秒custom introを適用する。

| 時刻 | 処理 |
| --- | --- |
| 0.00 | PREPARING、通常V3 BGM duck |
| 0.08 | gameplay theme背景 |
| 0.10 | CUSTOM_INTRO開始 |
| 0.10～0.30 | 正常そうな巨大silhouette + loading bar |
| 0.30～0.43 | barが82%付近で停止し、74%付近へ短く逆行 |
| 0.36～0.55 | scanline、横分割、RGBずれ、残像 |
| 0.52～0.70 | 同一画像を描画上だけ3枚へ分裂 |
| 0.65 | 共通SILHOUETTEへ接続開始 |
| 0.75 | CUSTOM_INTRO終了 |
| 0.82 | 共通REVEAL |
| 0.92 | BOSS label |
| 0.96 | subtitle |
| 0.89～1.05 | CUSTOM_FINALE: 固定記号列→横noise→正常名 |
| 1.05 | 共通NAME_IMPACTを1回だけ実行 |
| 1.22 | 固有コメント3～5件 |
| 1.55 | field接続開始、描画上だけ3残像 |
| 1.865 | 登場ロック付き実体を1体だけspawn |
| 1.90 | field実体へcross-fade |
| 1.90～2.08 | `bugged_glitch_settle` field pose |
| 2.08 | HPバー表示開始 |
| 2.20 | ロック解除、戦闘開始 |

最終ボス名は1.05～1.55秒の約0.50秒、安定して読める状態を維持する。

## 3. データ

`data/bosses.json` の `bugged_final_boss.cutin` へ追加する。

```json
{
  "version": 3,
  "customIntroId": "bugged_game_final_boss",
  "customFinaleId": "bugged_name_correction",
  "customCommentPoolId": "cutin_bugged_final_boss",
  "customIntroDurationSeconds": 0.65,
  "replaceCommonThemeIntro": false,
  "introPoseId": "bugged_glitch_settle",
  "durationSeconds": 2.20,
  "customSeType": "bugged_game_boss"
}
```

既存V2フィールドのsilhouette、comment burst、field connection、BGM duckはtrueのまま維持する。

`data/boss_cutin_v2.json` へ追加する。

```json
"cutin_bugged_final_boss": [
  "ラスボスきた！",
  "なんかバグってない？",
  "表示おかしいぞ",
  "これ仕様？",
  "ボス増えてる！",
  "ゲーム壊れた？",
  "そのラスボス大丈夫？"
]
```

同一cutinでは重複なしで3～5件を選ぶ。ChatSystem、履歴、score、buffへは渡さない。

## 4. intro registry

`BossCutinCustomIntroSystem` のregistryへ追加する。

```text
intro: bugged_game_final_boss -> handlerType bugged_game_intro
finale: bugged_name_correction -> handlerType bugged_name_finale
```

描画viewへ追加する値:

```text
loadingProgress
loadingBrokenProgress
normalSilhouetteAlpha
scanlineAlpha
rgbSplitAmount
sliceOffsets
ghostOffsets
pixelDropouts
invertPulse
garbledNameAlpha
stableNameAlpha
edgeNoiseAlpha
handoffGhostProgress
```

すべてelapsedとframeから決定論的に生成し、ゲーム用RNGを消費しない。

## 5. loading演出

- 横長barを名前領域より下、または画面中央下へ配置
- 数値、OS名、実在error codeは表示しない
- 0.10～0.27秒で0→0.82まで進行
- 0.27～0.33秒保持
- 0.33～0.39秒で0.82→0.74へ短く逆行
- 以降はbar右端をpixel欠けさせ、glitchへ変換
- bar fillは8～12個のpixel blockで描き、壊れたblockを2個以内にする

本物のloadingや停止に見えすぎないよう、cutin共通背景・BOSS演出色は残す。

## 6. 偽物silhouetteと画像glitch

正常版素材は増やさず、既存cutin textureを暗いsilhouetteとして使う。

1. 0.10～0.34秒: 1枚の正常silhouette
2. 0.34～0.46秒: 頭・胴・下部に相当する3～5本のhorizontal sliceを左右へ2～10pxずらす
3. 0.42～0.58秒: 同一textureを赤・青紫・水色で最大3回描き、±6px以内のRGB offset
4. 0.50～0.70秒: alpha 0.16～0.32の残像を左右へ最大26px
5. 0.64～0.75秒: 大きなhorizontal glitchを1回通し、共通silhouetteへ戻す

横分割は `draw_texture_rect_region()` などで元textureの帯を切り出して描く。画像を加工した新規ファイルや、敵Dictionaryの複製は作らない。

pixel欠けは背景色の小rectを最大8個重ねる。ボス輪郭の50%以上は常に判別できる状態を維持する。

色反転は通常時でも1～2描画frameだけ。reduced flash時は無効にし、紫系scanlineへ置き換える。

## 7. name finale

`bugged_name_correction` は共通name impactを呼ばない。固有finaleは表示文字の準備だけを行い、その後、共通 `name_impact` eventを1回だけ通す。

```text
0.89～0.97: 固定記号列
0.97～1.05: horizontal noise + 記号列fade
1.05: displayNameへ確定、共通impact
1.05以降: 名前文字は揺らさず固定
```

文字化け表現はランダムUnicodeや実際の文字コード破損を使わず、フォントで確実に表示できる短い固定文字列を使う。

```text
##? // B0SS _
```

確定後は名前そのものへglitchをかけず、画面端とunderlineだけを弱くnoise化する。

## 8. field handoff

V2の予約spawnと90% handoffをそのまま使う。

- 接続終盤にcutin画像を中央、左-22px、右+24pxの3枚で描く
- 左右ghostはalpha 0.22以下
- handoff直前に3枚を中央へ収束
- `spawn_boss_locked` eventは1回だけ
- 敵配列に追加するboss実体は1体だけ
- ghostへuid、HP、collision、AI、damage判定を作らない

## 9. field pose

`bugged_glitch_settle` は既存登場ロック中の描画値だけを変更する。

```text
1.90～1.98: 本体を横へ10pxずらす
1.94～2.03: 2～3個の低alpha残像
2.00～2.08: 本体を正常位置へ戻し、最大8個のpixel片
2.08: HP bar reveal
```

AI、攻撃、接触、被弾、プレイヤー操作、ゲームtimerはV3共通ロックで停止する。poseからenemy bullet、hit area、damage eventを作らない。

## 10. SE

既存SEを `customSeType = bugged_game_boss` のeventへ割り当てる。OS警告音や実在システムerror音は使用しない。

- loading start: 短いdigital起動音
- loading break: 小さい停止音
- custom impact: glitch noise
- common reveal: boss登場衝撃
- name impact: 通常ボス決定音

大SEを同一frameへ重ねず、固有SEがない場合は共通SEのみで続行する。

## 11. アクセシビリティ

- reducedFlash: 色反転なし、白全画面flashなし
- reducedNoise: RGB幅50%、slice数最大3、ghost最大2、1-frame点滅なし
- screen shake off: name impactの画面shakeなし。画像自身の8px以下の短いoffsetだけ許可
- 現在存在しない設定UIをこの追加だけで新設しない

## 12. cleanupとfallback

固有描画は毎frame viewから再構築し、Node、Tween、Shader materialを残さない。

- unknown intro/finale: 第2版へfallback
- textureなし: loading + pixel blocks +共通nameだけで進行
- slice描画失敗: RGB ghostを省略して共通silhouetteへ移行
- cancel/watchdog: custom viewを空にし、V3共通cleanupへ合流
- field handoff失敗: 第2版fade + finish時spawn

終了後はscreen inversion、scanline、edge noise、ghost、loading barをすべて0へ戻す。

## 13. 必須テスト

1. `bugged_final_boss` がV3 custom introを選ぶ
2. 総時間2.20秒、custom区間0.65秒
3. loading barが0.82付近で止まり0.74付近へ逆行する
4. normal silhouette、slice、RGB split、ghostのうち3種類以上が有効になる
5. ボス輪郭が完全消失しない
6. finale中の記号列が0.20秒以内で消える
7. 最終名が0.40秒以上安定表示される
8. 共通name impact eventが1回だけ
9. custom commentが3～5件、重複なし
10. handoff ghostは3描画、敵実体は1体
11. field pose中にAI、攻撃、接触、被弾、timerが停止
12. ghostとpixel片にdamage判定がない
13. reduced flash/noise/shake分岐が強度を下げる
14. unknown handlerとtexture欠損でV2 fallbackして戦闘開始
15. finish/cancel/watchdog後にglitch表示状態が残らない
16. 1600x900と1280x720のCUSTOM_INTRO、name確定、field handoffをcapture確認
17. JSON、GDScript check-only、V1/V2/V3 regression、headless、`git diff --check`

## 14. 完成条件

バグったラスボスを第3版の5体目へ追加し、loading破損、正常silhouette崩壊、画像glitch、名前確定、3残像handoff、field poseが2.20秒内で一続きに見えること。第2版fallbackと1体spawn保証を維持する。
