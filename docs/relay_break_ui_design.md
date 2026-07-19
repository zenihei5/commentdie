# 配信リレー休憩画面 実装設計

## 1. 設計方針

休憩画面は「回復か強化を選ぶ2枚の報酬カード」として見せる。ゲームルールは既存の `RelayBreakSystem` に残し、表示、入力、選択アニメーションだけを専用 `Control` に分離する。

- 通常ステージのギフト画面とリザルト画面は変更しない。
- 回復30%、ギフト3択、5回の休憩というルールは変更しない。
- 休憩中は `PauseReasonSystem` の理由が残っている間、ワールド時間を進めない。
- 既存素材が読めない場合は `StyleBoxFlat` と既存アイコンで表示できるフォールバックを残す。

## 2. 現行実装の整理

現在の休憩画面は `scripts/game.gd` の `_draw_relay_break_overlay()` と固定 `Rect2` で描画されている。入力は `_update_relay_break()`、決定は `_complete_relay_break()` が所有する。

改修時に解消する点:

- 画面が即時描画だけで構成され、カード単位のTweenとアンカー配置を持たない。
- EnterとSpaceは扱うが、`ui_accept` とゲームパッド決定を統一していない。
- 左右選択が物理キーのポーリングで、入力デバイス表示の切り替えを持たない。
- 進行バーは前枠完了と次枠を区別せず、現在インデックスだけを強調する。
- `RelayBreakSystem.heal_preview()` は現在 `round` を使う。正式仕様に合わせて `floor(max_hp * heal_rate)` と上限適用へ変更する。
- 決定直後の専用入力ロックと画面状態がないため、遷移処理を明示的な状態で守る。

## 3. 追加する表示コンポーネント

`RelayBreakScreen` を `Control` として一度だけ生成し、通常は非表示にする。ゲーム本体はコンテキストを渡し、画面からのシグナルを受けて既存の回復、ギフト、次枠遷移を実行する。

```text
RelayBreakScreen (Control, full rect)
├── DimOverlay (ColorRect)
├── ProgressLayer (Control)
│   └── RelayProgressBar
├── MainPanel (TextureRect)
│   ├── HeaderGroup
│   ├── CharacterBreakArt
│   ├── BossAccent
│   ├── HealCard (TextureButton)
│   ├── GiftCard (TextureButton)
│   └── OperationGuide
├── HealEffectLayer
└── TransitionLayer
```

`TextureButton` は透明テクスチャを押下判定に使い、カード背景、アイコン、テキストは子ノードで構成する。カード全体をクリック領域にし、子ノードは `mouse_filter = IGNORE` とする。

## 4. 1600x900基準レイアウト

| 要素 | 基準Rect / サイズ | 備考 |
| --- | --- | --- |
| 暗転 | `0, 0, 1600, 900` | `Color(0.10, 0.08, 0.15, 0.42)` |
| 進行バー | `280, 22, 1040, 52` | 暗転より前面 |
| メインパネル | `260, 142, 1080, 568` | `panel_frame.png` |
| ヘッダー左 | `338, 188, 500, 104` | BREAK TIME、見出し、補足 |
| ヘッダー右 | `888, 190, 370, 92` | 前枠CLEAR、次枠 |
| 回復カード | `386, 326, 390, 260` | 選択時は上へ4px |
| ギフトカード | `824, 326, 390, 260` | カード間48px |
| キャラ絵 | `232, 365, 250, 330` | カード背面、下端合わせ |
| 操作案内 | `430, 632, 740, 34` | 入力デバイスで文言切替 |
| ボス前アクセント | `346, 274, 908, 54` | `is_before_boss` のみ |

`RelayBreakScreen` はfull rectでアンカーし、内部に1600x900基準の `AspectRatioContainer` を置く。異なる比率では全体を等倍縮小して中央配置し、左右または上下の余白へ暗転を延長する。カードと文字だけを個別に横伸ばししない。

キャラクター絵はカードより先に描画し、左側から少し覗く構図にする。素材がない場合は非表示にし、カード配置は動かさない。

## 5. 素材契約

透過済み素材は `assets/generated/relay_break_v1/` を使用する。

| ファイル | 用途 | 推奨表示 |
| --- | --- | --- |
| `panel_frame.png` | メインパネル | 1080x568、keep aspect centered |
| `card_heal.png` | 回復カード背景 | 390x260 |
| `card_gift.png` | ギフトカード背景 | 390x260 |
| `icon_heal.png` | 回復アイコン | 104x104 |
| `icon_gift.png` | ギフトアイコン | 104x104 |
| `character_supana.png` | すぱな休憩絵 | 高さ330基準 |
| `character_maron.png` | まろん休憩絵 | 高さ330基準 |
| `character_banri.png` | ばんり休憩絵 | 高さ330基準 |
| `boss_accent.png` | 最終ボス前装飾 | 幅908、高さは比率維持 |
| `decorations/*.png` | 回復粒子、カード装飾 | 16から48px |

カード背景はNinePatchとして引き伸ばさず、指定Rectへアスペクトを維持して収める。文字とアイコンは別レイヤーに置くため、解像度差で背景内の文字がぼやけない。

## 6. コンテキスト契約

第一版はDictionaryで既存コードへ接続し、必要になった段階で型へ昇格する。

```gdscript
{
	"previousSegmentId": String,
	"nextSegmentId": String,
	"isBeforeBoss": bool,
	"currentHp": int,
	"maxHp": int,
	"healRate": float,
	"playerCharacterId": String,
	"lastInputDevice": String,
}
```

表示用の前枠名、次枠名、キャラ素材パスはIDから画面側の辞書で解決する。`isBeforeBoss` は `nextSegmentId == "boss"` と整合性を確認し、表示文言だけからボス前を判定しない。

## 7. 状態と入力

状態は `ENTERING -> SELECTING -> RESOLVING_HEAL / OPENING_GIFT -> EXITING` とする。

- 初期選択は回復。
- `ui_left`、`ui_right`、A、D、ゲームパッド左右で2択を切り替える。
- `ui_accept`、Enter、Space、ゲームパッド決定で確定する。
- 表示後0.15秒は決定入力を受け付けない。
- 決定したフレームで `input_locked = true` にし、同じ処理を二度呼ばない。
- マウスhoverは選択だけを変え、左クリックで確定する。
- 最後に入力されたデバイスに合わせて操作案内を更新する。

選択Tweenは0.14秒、`TRANS_QUAD / EASE_OUT`。既存Tweenをkillしてから、scale 1.04、上方向4px、選択枠alpha 1.0へ遷移する。非選択カードはalpha 0.92を維持し、グレーにはしない。

## 8. カード情報配置

### 回復カード

- アイコン: 上端から20px、104x104
- タイトル: `ひと休みする`、26px
- 説明: `メンタルを30％回復`、18px
- HPプレビュー: `HP 34 / 100 -> 64 / 100`、20px太字
- HP満タン: `メンタルは満タンです` と `100 / 100`

### ギフトカード

- アイコン: 上端から20px、104x104
- タイトル: `ギフトを開ける`、26px
- 説明1: `武器・アクセを強化`、18px
- 説明2: `3つから1つ選択`、17px

日本語は既存フォントを使用し、白文字へ色付き縁取り、または濃色文字へ白の薄い縁取りを付ける。背景装飾と本文が重なる場合は本文側へ半透明の白いピル背景を敷く。

## 9. 進行バー表示

進行バーは6項目それぞれに `UNREACHED / CLEARED / NEXT / CURRENT / BOSS_NEXT` を渡して描画する。

休憩中は前枠を `CLEARED`、次枠を `NEXT` とし、`CURRENT` は使用しない。最終ボス前だけBOSSを `BOSS_NEXT` にする。完了チェックは文字の左、NEXTの脈動は0.85から1.0のalpha範囲に抑える。

## 10. 回復とギフト遷移

回復確定後は0.8秒の演出を行う。回復カード発光、ミントのorbとハート粒子、HP数値の段階更新、既存メンタルゲージ反映、回復SEの順に同期させる。実HPは一度だけ確定し、数値Tweenは表示専用とする。

ギフト確定時はカードを0.18秒発光させ、`GiftSelection` の停止理由を追加してから既存ギフト画面を開く。次枠開始まで `Break` の停止理由を残すか、同一フレーム内で理由を引き継ぎ、停止理由が空になる瞬間を作らない。

## 11. 最終ボス前差分

同じ画面へ以下だけを差し替える。

- 見出し: `最終決戦に備えよう！`
- 次枠: `次は「ラストオフライン」`
- `boss_accent.png` をヘッダー下へ表示
- BOSSを `BOSS_NEXT` にし、金色と赤紫を混ぜた発光にする
- カード内容、回復量、ギフト品質、入力処理は通常休憩と共通

## 12. 実装境界

`RelayBreakScreen` が行うこと:

- コンテキストの表示
- 選択状態、入力ロック、Tween
- hover、クリック、入力デバイス表示
- 回復プレビューの表示Tween
- `heal_selected` と `gift_selected` の通知

`game.gd` / `RelayBreakSystem` が行うこと:

- 回復量計算と実HP確定
- ギフト候補生成と既存ギフト画面遷移
- PauseReasonの追加、引き継ぎ、解除
- 次枠または最終ボスへの進行
- 二重報酬を防ぐrun側once guard

画面ノードから `player_hp` やリレーフローを直接変更しない。

## 13. 検証項目

- HP 34/100、90/100、100/100、端数最大HPでプレビューと実値が一致する。
- 回復とギフトを連打しても一度しか確定しない。
- ギフト画面が閉じるまで次枠が始まらない。
- 5回すべてで前枠CLEARと次枠NEXTが正しい。
- 最終ボス前だけ専用タイトル、アクセント、BOSS_NEXTになる。
- 1600x900、1280x720、1920x1080、16:10で文字とカードが画面外へ出ない。
- キーボード、ゲームパッド、マウスの最後の入力方式が操作案内へ反映される。
- 休憩からギフトへの遷移中もPauseReasonが空にならない。
- 素材が欠けた状態でもフォールバック表示で選択と進行ができる。
