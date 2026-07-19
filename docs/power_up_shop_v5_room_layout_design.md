# 『ぜんぶコメントのせいだ』パワーアップショップ第5版 実装設計

## 1. 位置づけ

- 原仕様: `C:/Users/zenih/.codex/attachments/30cc0e8b-7976-4ee6-911e-889c8d7743bf/pasted-text.txt`
- 対象: 実装済みの第4版ショップUIを、第5版の「配信強化ルーム」へ刷新する。
- 第5版は表示構造と演出の改修であり、価格、効果、PP、保存、リセット、入力仕様を変更しない。
- 第4版で追加済みの8カード常駐、`PowerUpShopUiState`、`UpgradeVisualTier`、総強化Lv、購入シグナル順、購入後演出の基盤を再利用する。

## 2. 現行実装との照合

現行には次が実装済みである。

- `scripts/ui/power_up_shop_screen.tscn`
  - Header / CategoryTabs / 2列カード / DetailPanel / Footer
  - 総強化Lv、HeroRow、5ランプ、マスコット、カテゴリ背景、接続線
- `scripts/ui/power_up_shop_screen.gd`
  - combat/support合計8カードの常駐・再利用
  - `points_changed -> upgrade_purchased -> 購入演出 -> View更新` の順序制御
  - カテゴリタブ、カード、フッター、リセット確認の論理フォーカス
- `scripts/ui/power_up_shop_card.gd`
  - VisualTier、価格・不足量、選択、ホバー、論理フォーカス、購入ランプ演出
- `data/power_up_shop.json`
  - 8強化、`cardSummary`、カテゴリ、価格、効果値

第5版ではこれらを捨てず、主にシーン構造と表示データを拡張する。

## 3. 変更しない契約

次は回帰させない。

1. `PowerUpShopManager`、SaveStore、PP報酬、価格、強化効果、セーブ形式
2. 8カードを初回だけ生成し、カテゴリ切替では表示だけを切り替える方式
3. 戦闘/配信サポートタブへ上下で移動でき、タブ上の左右でカテゴリを切り替える操作
4. カード最上段から上でタブ、最下段から下でフッターへ移動する操作
5. フッターへ入った時は必ず「戻る」、左右で「戻る/全強化をリセット」を移動する操作
6. カーソル移動SE、購入SE、エラーSE、MAX SE
7. 保存成功後だけ購入成功演出を開始する順序
8. 購入演出中も「戻る」によるショップ終了を許可し、終了時にTweenと一時状態を掃除する処理
9. Fake Storeを使うテスト。ユーザーの実セーブをテストで変更しない。

## 4. 第5版の画面シルエット

1600x900を基準とし、次の見え方を第一版の完成形とする。

```text
┌──────────────────────────────────────────────────────────────┐
│ タイトル + 総強化Lv                           所持PP         │
│ [戦闘] [配信サポート]                                        │
├──────────────────────────────┬───────────────────────────────┤
│ 個別背景カード  個別背景カード │ カテゴリ色のHeroSection       │
│ 個別背景カード  個別背景カード │ アイコン  名前 / Lv / 5ランプ │
│                              ├───────────────────────────────┤
│                              │ 白いInformationSection         │
│                              │ 説明 / タグ / 現在→次           │
│                              │ 必要PP / 購入ボタン    吹き出し │
│                              │                         マスコット│
├──────────────────────────────┴───────────────────────────────┤
│ 戻る  全強化をリセット                         入力ヒント    │
└──────────────────────────────────────────────────────────────┘
```

主要な判断:

- 右詳細は「白い大カードの上に小さなHeroRow」ではなく、カテゴリ色の上部ヒーロー面と白い下部情報面の二層にする。
- 既存の画面横断接続線は削除し、詳細左端の7～10pxアクセント帯と選択カードの持ち上がりで関係を示す。
- マスコットはボタン横の小アイコンではなく、情報面右下の独立したプレゼンテーション領域へ移す。
- 総強化Lvはタイトル直下へ統合し、独立カードとしてヘッダー中央に置かない。
- 背景はカテゴリ画像を置くだけでなく、「配信強化ルーム」の機材、コメント、PPの流れを薄く常駐表示する。

## 5. 目標ノード構造

既存名を必要に応じて移行してよいが、責務は次のように分ける。

```text
PowerUpShopScreen
├── FullScreenBackground
├── RoomDecorationLayer                 # 常駐。画面全体の配信強化ルーム
│   ├── CommonRoomDecoration
│   ├── CombatRoomDecoration
│   └── SupportRoomDecoration
├── SafeAreaMargin
│   └── MainCenter
│       └── ShopContent
│           ├── Header
│           │   ├── TitleArea
│           │   │   ├── EnglishTitle
│           │   │   ├── Title
│           │   │   └── TotalProgressRow
│           │   │       ├── Caption
│           │   │       ├── Value
│           │   │       └── ProgressBar
│           │   └── PpCapsule
│           ├── CategoryTabs
│           ├── Body
│           │   ├── CardSection
│           │   │   └── CardGrid
│           │   └── DetailPanel
│           │       ├── DetailAccentBand
│           │       ├── HeroSection
│           │       │   ├── CombatHeroBackground
│           │       │   ├── SupportHeroBackground
│           │       │   ├── HeroPattern
│           │       │   └── HeroContent
│           │       │       ├── IconStage
│           │       │       │   ├── IconGlowPlate
│           │       │       │   └── LargeIcon
│           │       │       └── HeroCopy
│           │       │           ├── CategoryTag
│           │       │           ├── Name
│           │       │           ├── Level
│           │       │           └── DetailLevelGauge
│           │       └── InformationSection
│           │           ├── InfoContent
│           │           │   ├── Description
│           │           │   ├── TargetTags
│           │           │   ├── EffectComparison
│           │           │   └── PurchaseArea
│           │           │       ├── PriceColumn
│           │           │       │   ├── RequiredPointRow
│           │           │       │   └── PurchaseButton
│           │           │       └── MascotReserve
│           │           └── MascotPresentation
│           │               ├── SpeechBubble
│           │               │   └── Message
│           │               ├── MascotGlow
│           │               ├── Mascot
│           │               └── MascotStateDecoration
│           └── Footer
├── PurchaseLight
├── ToastLayer
├── DialogLayer
└── UiSeGroup
```

`SelectionConnectorLayer`と`power_up_shop_connector.gd`は第5版では参照しない。ファイル自体の削除は、他参照がないことを`rg`で確認してから行う。安全側ではシーンから外し、未使用ファイルの削除を別差分にしない選択でもよい。

## 6. レイアウト寸法

### 6.1 1600x900基準

- `ShopContent`: 幅1360前後、高さ860前後
- Header: 78～84px
- CategoryTabs: 46～52px
- Body: 550～570px
- Footer: 48～56px
- Body separation: 28px
- CardSection: 650～670px
- DetailPanel: 630～650px
- DetailPanel上部HeroSection: 205～220px、全体の約38%
- DetailPanel下部InformationSection: 335～350px、全体の約62%
- Hero icon: 96～116px
- IconGlowPlate: 150～190px
- Mascot: 140～160px
- SpeechBubble: 幅170～220px、高さ48～76px

### 6.2 1280x720

仕様の優先縮小順に従う。

1. 背景装飾の数と移動量を減らす
2. DetailPanel内余白を24pxから16～18pxへ縮める
3. マスコットを120px、吹き出しを150～170pxへ縮める
4. HeroSectionを178～190pxへ縮める
5. CardSectionを570～585px、DetailPanelを600～615pxまで縮める
6. カード1枚の最小幅を272～282pxまで許容する
7. 説明文は2行、タグは最大3件、ボス名のような長文は自動縮小する

購入ボタン、価格、比較値、Lv、PP残高は装飾より先に削らない。縦720で収まらない場合、先に各セクションの余白と装飾を減らす。

### 6.3 1920x1080以上

- ショップ本体は最大幅1380～1420に抑え、カードや文字を無制限に拡大しない。
- 余白側へRoomDecorationを見せ、主UIの密度を維持する。
- 2560x1440でもHeroSectionとInformationSectionの比率を維持する。

## 7. ヘッダー

- `TotalProgressArea`をHeaderの独立パネルから外し、`TitleArea/TotalProgressRow`へ移す。
- 表示は `総強化Lv 12 / 40` と細い進捗バー。40は固定せず既存どおり全`maxLevel`合計から算出する。
- PPカプセルは右端へ固定し、購入光の開始点として既存参照を維持する。
- タブの論理フォーカスとSEは変更しない。

## 8. 左カードの個別表現

### 8.1 データ定義

各強化の静的表示データを`data/power_up_shop.json`の各upgradeへ追加する。

```json
"visualStyle": {
  "baseColor": "#FFF1F7",
  "accentColor": "#FF78A9",
  "patternId": "heart_circle",
  "patternAlpha": 0.06
}
```

カードIDごとの初期値:

| ID | baseColor | patternId | モチーフ |
|---|---|---|---|
| `max_hp` | `#FFF1F7` | `heart_circle` | ハート、円 |
| `attack_power` | `#FFF1E7` | `spark_impact` | 火花、衝撃線 |
| `move_speed` | `#EEF8FF` | `speed_wing` | 速度線、羽根 |
| `damage_reduction` | `#F3EEFF` | `hex_shield` | 六角形、盾 |
| `exp_gain` | `#EFF1FF` | `book_chart` | 本、上昇グラフ |
| `pickup_range` | `#ECFAF5` | `comment_suction` | コメント、吸引リング |
| `healing_power` | `#FFF8E9` | `steam_heart` | 湯気、ハート、マグ |
| `gift_luck` | `#FFF8D9` | `star_ribbon` | 星、リボン |

- `accentColor`は各アイコンとカテゴリ色に合う色を同じ辞書へ指定する。
- 模様はカード上で`patternId`を解釈する1か所の描画処理に集約する。カードIDごとの`if`を画面スクリプトへ散らさない。
- 視覚段階で模様のalphaを加算する。
  - Lv0: 4～7%
  - LOW: 6～9%
  - HIGH: 8～12%
  - MAX: 10～15%
- 色だけに依存せず、8種類すべて形が異なるようにする。

### 8.2 選択・ホバー・論理フォーカス

`selected`、`hovered`、`logical_focused`を混同しない。

- `selected`
  - scale `1.04`
  - x方向 `+8px`
  - カテゴリ枠4px、影、アイコン発光、`z_index`を前へ
  - 0.15～0.20秒
  - タブまたはフッターへ論理フォーカスが移っても、現在の選択カードとして保持する
- `logical_focused`
  - キーボード/ゲームパッドの現在位置を示す細い外側リングを追加
  - 選択カード上では選択表現へ重ねるが、二重にscaleさせない
- `hovered`
  - 枠2px、明度微増のみ
  - scaleは最大1.01。選択と同等にしない
- 未選択
  - `self_modulate.a = 0.90～0.94`または`#EDEAF3`の弱いtint
  - 読めなくなるほど暗くしない

現行`set_logical_focus()`がscaleを担当しているため、第5版ではscaleの主担当を`selected`へ移す。フォーカス遷移の入力ロジック自体は変更しない。

## 9. 詳細パネル

### 9.1 外形

- DetailPanel自体は8px以下の角丸、白基調。
- 左端にカテゴリ色の`DetailAccentBand`を7～10pxで常駐させる。
- カテゴリ切替時、帯を上から下へ0.25～0.35秒で光が走る。
- カードと詳細を結ぶ画面横断線は表示しない。

### 9.2 HeroSection

- combat背景: `#FF8FBD -> #D65A94`
- support背景: `#79D9EF -> #7C8FF0`
- 2枚の背景TextureRectを常駐させ、カテゴリ変更時に0.25～0.35秒クロスフェードする。
- combat模様: スピード線、火花、上向き矢印、衝撃波
- support模様: コメント、星、リング、電波、ハート
- 模様は文字とアイコンの背後へ置き、alpha 8～16%に抑える。
- カテゴリタグは白地にカテゴリ色文字。
- 名前、Lv、ランプは白を基本とし、影または濃色アウトラインで可読性を確保する。
- IconGlowPlateは150～190px、実アイコンは96～116px。アイコン画像を引き伸ばさず`KEEP_ASPECT_CENTERED`を使う。

HeroSectionの境界は第一版では水平でよい。浅い斜めアクセントを装飾として重ねてもよいが、レイアウト境界そのものを複雑なPolygonへしない。

### 9.3 InformationSection

- 背景は白～ごく薄い紫。
- 説明、タグ、現在→次、価格、購入ボタンの既存情報をすべて残す。
- 比較表示は左を中立色、右をカテゴリ色またはPP色にする。
- 右下170～200pxをMascotReserveとして確保し、購入ボタンと価格がマスコットに隠れないようにする。
- 購入ボタンは左側のPriceColumn内に置く。
- 購入可能時は2行を推奨する。

```text
パワーアップする
120 PP
```

不足時とMAX時も同じ高さを維持し、ボタン文言でレイアウトを動かさない。

## 10. マスコットと吹き出し

### 10.1 本体

- 本体は`res://assets/generated/weapon_fx_v1/listener_summon.png`を使い、140～160pxで表示する。
- 情報面の右下に配置し、パネル外へ20～35%だけ重ねてもよい。画面外へは出さない。
- 現行の`_mascot_max_texture = sweat.png`による本体差し替えは廃止する。`sweat.png`は緑背景を含むため、そのままマスコット本体へ表示しない。
- MAXは同じマスコットへ金色のGlow、星、軽い跳ねを加える。
- 不足状態に汗表現が必要なら、透過確認済みの小さな装飾だけを別ノードへ載せる。透過されていなければ使用しない。

### 10.2 状態モデル

```gdscript
enum MascotState {
	IDLE,
	PURCHASABLE,
	SHORTAGE,
	PURCHASE_SUCCESS,
	MAX_LEVEL,
}
```

基本状態は現在の`PurchaseState`から決める。

- MAX_LEVEL -> `MAX_LEVEL`
- NOT_ENOUGH_PP -> `SHORTAGE`
- PURCHASABLE -> `PURCHASABLE`
- それ以外 -> `IDLE`

一時状態の優先順位:

```text
PURCHASE_SUCCESS > MAX_LEVEL > SHORTAGE > PURCHASABLE > IDLE
```

- 購入成功時は1.2～1.6秒`PURCHASE_SUCCESS`。
- 購入でMAXになった場合は成功表示の後、1.8～2.4秒`MAX_LEVEL`。
- 一時状態にはgeneration/tokenを持たせ、古いTimerやTweenが新しい選択の吹き出しを上書きしないようにする。
- `_reset_transient_state()`と`_kill_tweens()`でマスコット用Timer/Tween/tokenを必ず無効化する。

### 10.3 メッセージ

- IDLE: 「どれを強化する？」「応援を力に変えよう！」
- PURCHASABLE: 「強化できるよ！」
- SHORTAGE: `あと%dPPだよ！`
- PURCHASE_SUCCESS: 「パワーアップ完了！」
- MAX_LEVEL: 「最大まで強くなった！」

メッセージ辞書は画面内に条件分岐で散らさず、`data/power_up_shop.json`のトップレベル`mascotMessages`または単一の表示設定辞書へ置く。ランダム候補を使う場合、毎回の`_refresh_view()`で変えず、選択変更時だけ決める。

### 10.4 吹き出し

- 白地、カテゴリ色1～2px、文字`#302846`、角丸12～16px
- 150～220 x 45～76px
- マスコットの左上に置き、三角の尻尾だけマスコットへ向ける
- ボタン、価格、効果比較へ重ならない
- 通常は常時表示。選択変更時は0.12～0.18秒の短いフェードのみ

## 11. 配信強化ルーム背景

### 11.1 常駐構造

カテゴリ切替のたびにノードを作らない。

- `CommonRoomDecoration`: コメント窓、PP導線、モニター、点、ケーブル、円形装置
- `CombatRoomDecoration`: 衝撃線、上昇矢印、火花、強化グラフ
- `SupportRoomDecoration`: コメント、電波、ギフト、ハート、星

`CombatRoomDecoration`と`SupportRoomDecoration`は0.25～0.35秒でクロスフェードする。

### 11.2 表現

- 左側: コメントホログラム、グラフ、カードへ流れる細いライン
- 右側: PPケーブル、円形強化装置、モニター、上向き矢印
- 画面端: 点、電波、ギフト、コメント記号
- alpha 8～15%。カード本文や詳細本文の直下は密度を下げる。
- 3～6秒周期の遅い移動だけを許可する。常時大きく揺らさない。
- 既存の`relay_break_v1/decorations`、`coin.png`、`comment_radar.png`を補助素材として使える。
- 専用画像が足りなくても、StyleBoxFlat、GradientTexture2D、`draw_line`、`draw_circle`、`draw_arc`で構成し、旧レイアウトへ戻さない。

背景描画は`power_up_shop_room_decoration.gd`の1個のカスタムControlへ集約する。カードごとの模様は`PowerUpShopCard`配下の`CardPattern`へ分離し、RoomDecorationへ混ぜない。

## 12. カテゴリ切替

現行`_animate_category_switch()`はBody全体を薄くするため、第5版では次へ変更する。

1. カード4枚を0.12～0.18秒で短くクロスフェード
2. Hero背景2枚を0.25～0.35秒でクロスフェード
3. RoomDecorationのカテゴリレイヤーを0.25～0.35秒でクロスフェード
4. DetailAccentBandへ上から下の光
5. 新カテゴリの選択カードは保存済み`category_last_indices`を使う

Body全体を透明化すると白い情報面までちらつくため行わない。文字更新はクロスフェード中間点で1回だけ行う。

## 13. 購入演出の接続

Managerの取引順は変更しない。表示順だけ第5版へ接続する。

```text
manager.purchase_upgrade(id)
↓
保存成功
↓
points_changed: PP数値だけ更新
↓
upgrade_purchased: 演出開始
↓
PPカプセルから選択カードへ光 0.20～0.28秒
↓
カードからHeroアイコンへ光 0.18～0.24秒
↓
View更新・新ランプ点灯・カードVisualTier更新
↓
Hero面の短い発光 0.10～0.16秒
↓
マスコット購入成功 + 吹き出し
```

全体は0.55～0.85秒。コミット前にレベルやPPを先行表示しない。

- 不足時: 成功光は出さず、購入ボタンの短い横揺れ、PPカプセル警告、`SHORTAGE`吹き出し。
- MAX時: 全画面フラッシュなし。カードとHeroの金色発光、マスコット、吹き出しだけ。
- 購入中の選択・カテゴリ・再購入ロックは既存の0.35秒前後を維持する。
- 閉じる時はカード、Hero、マスコット、背景のTweenをすべて停止する。

## 14. 表示データ契約

`PowerUpShopUiState.build()`の返り値へ、静的表示データを通す。

```gdscript
{
	# 既存キーは維持
	"visualStyle": upgrade.get("visualStyle", {}),
	"mascotBaseState": mascot_state_from_purchase_state(state),
	"mascotMessageArgs": {"shortage": shortage},
}
```

ただし、購入一時状態はViewへ保存せず、画面側のプレゼンテーション状態として持つ。価格や不足量をカード、詳細、吹き出しで個別計算せず、同じView Dictionaryを使う。

JSONの`schemaVersion`は、ローダーが未知キーを許可しており既存セーブ互換へ影響しないため第5版でも`1`を維持してよい。厳密バリデーションがある場合のみ表示設定の許可キーを追加する。

## 15. ファイル別変更

### `data/power_up_shop.json`

- 各upgradeへ`visualStyle`
- トップレベルへ`mascotMessages`
- ゲームバランス値は変更しない

### `scripts/ui/power_up_shop_ui_state.gd`

- `visualStyle`をViewへコピー
- 基本マスコット状態と不足引数をViewへ追加
- 既存のPurchaseState、VisualTier、効果文言を維持

### `scripts/ui/power_up_shop_screen.tscn`

- Header内へ総強化Lvを統合
- DetailPanelをHeroSection / InformationSectionへ再構築
- MascotPresentationとSpeechBubbleを追加
- RoomDecorationLayerを追加
- SelectionConnectorLayerを外す
- 既存Toast/Dialog/UiSeを維持

### `scripts/ui/power_up_shop_screen.gd`

- 新ノードパスへ更新
- Hero/Roomカテゴリ背景の常駐クロスフェード
- マスコット状態機械とメッセージ更新
- DetailAccentBandの走査光
- 購入光をPP -> card -> Heroへ接続
- responsive寸法を第5版へ更新
- 入力処理とManager取引処理は原則触らない

### `scripts/ui/power_up_shop_card.tscn`

- `CardPattern`、選択影、アイコンGlowを追加
- 安定した最小寸法を設定

### `scripts/ui/power_up_shop_card.gd`

- `visualStyle`と`patternId`を反映
- selected主導のscale/x移動へ変更
- hovered/logical_focusedを別レイヤーへ分離
- unselected alphaとz_indexを制御

### 新規候補 `scripts/ui/power_up_shop_room_decoration.gd`

- RoomDecorationの共通・カテゴリ固有モチーフを描画
- 3～6秒の遅い位相移動
- combat/support alphaを外部から設定

必要ならHeroPatternも同スクリプトの別modeで描けるが、カード模様まで1ファイルへ押し込まない。

### `scripts/tests/test_power_up_shop_screen_v2.gd`

- 既存入力回帰を削除せず、第5版の構造・状態・購入順を追加

## 16. 実装順

1. JSONへ8件の`visualStyle`とメッセージ辞書を追加
2. UiStateへ表示データを通す
3. シーンをHeader / HeroSection / InformationSection / MascotPresentationへ再構築
4. onready参照とstatic styleを新構造へ更新
5. カード個別背景・選択/ホバー/フォーカス分離
6. 詳細Hero背景とAccentBand
7. マスコット状態・吹き出し
8. RoomDecoration
9. カテゴリ切替を3レイヤー同期クロスフェードへ更新
10. 購入光を新レイアウトへ接続
11. 1280x720からresponsive調整
12. テスト拡張、静的検証、1プロセスで実行検証と撮影

大規模シーン変更後も、まずカード1枚と詳細1件を表示できる状態でパース確認し、その後アニメーションを足す。入力関数を同時に全面改修しない。

## 17. 自動テスト

既存テストに以下を追加する。

1. 8upgradeすべてに`visualStyle.baseColor/accentColor/patternId/patternAlpha`がある
2. 8件の`patternId`が意図した固有値である
3. `PowerUpShopUiState.build()`がvisualStyleと不足量を同じViewへ保持する
4. 8カードのinstance idがカテゴリ切替、購入、PP更新後も変わらない
5. `SelectionConnectorLayer`が存在しない、または非表示・未参照である
6. `DetailAccentBand`幅が7～10px
7. HeroSection / InformationSectionが存在し、1600x900で約38/62比率
8. combat/support Hero背景とRoom背景のノード数が切替後も増えない
9. 選択カードは未選択よりscale、x、z_index、枠が強い
10. ホバーだけでは選択と同じscaleにならない
11. タブ/フッターへ移動後も現在カードのselected表現が残る
12. SHORTAGE吹き出しが実際の`shortage`値を表示する
13. 購入成功の一時状態が古いTimerで別選択へ残らない
14. close後に購入光、Hero flash、マスコットTween、吹き出し一時状態が残らない
15. Manager呼び出し回数、保存後更新、多重購入防止の既存テストが通る
16. カード最上段/タブ/下段/フッター/リセット確認の既存入力テストが通る

## 18. 視覚検証

Godotが安全に実行できる時だけ、1プロセスへ集約して次を撮影する。

- 1280x720
- 1600x900
- 1920x1080
- 2560x1440

各解像度で確認する状態:

- combat / support
- Lv0 / LOW / HIGH / MAX
- 購入可能 / PP不足
- カード選択、マウスホバー、タブフォーカス、フッターフォーカス
- マスコット通常 / 不足 / 購入成功 / MAX

目視基準:

- 第4版と一目で違う上下二層の詳細パネルになっている
- マスコットが120～160pxで読める
- マスコットと吹き出しが購入ボタン、価格、画面端へ重ならない
- 8カードの背景が色だけでなく模様でも区別できる
- 選択カードがホバーより明確に強い
- 1280x720で文字切れ、カード重なり、詳細の欠落がない
- 背景装飾が本文の可読性を邪魔しない
- カテゴリ切替後に古いHero/背景が残らない

## 19. Godot安全手順

1. 静的参照、JSON、末尾空白、`git diff --check`を先に行う。
2. Godot GUI起動中は別headlessプロセスを同時起動しない。
3. ユーザーのGodotエディタをkillしない。
4. 実行検証と4解像度撮影は競合しない1プロセスへまとめる。
5. native signal 11が出たら同じコマンドを再実行せず、その時点で報告する。

## 20. 完成条件

- 第4版の購入・保存・入力・カード再利用仕様が維持されている
- タイトル直下に総強化Lvが統合されている
- 右詳細がカテゴリ色HeroSection + 白いInformationSectionの二層構造である
- マスコットが右下へ大きく表示され、状態に応じた吹き出しが出る
- 8カードに固有背景色と固有模様がある
- 選択、ホバー、論理フォーカスの強弱が正しい
- 画面横断接続線がなく、左アクセント帯へ置換されている
- 配信強化ルームの背景があり、カテゴリ切替で自然に変化する
- 購入成功は保存成功後だけ再生される
- 1280x720を含む4解像度で情報欠落と重なりがない
- 既存入力回帰と第4版回帰を含む自動テストが通る
- 第4版と比較して、画面構成のシルエットが明確に異なる
