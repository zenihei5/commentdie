# 『ぜんぶコメントのせいだ』
# パワーアップショップ第3版 UIブラッシュアップ実装設計

## 1. 目的

パワーアップショップ第2版のシーン、入力、購入、保存、リセット処理を維持し、カード単体の判別性、購入状態、詳細パネルの情報密度を改善する。

参照仕様:

```text
C:/Users/zenih/.codex/attachments/70868472-c083-49ea-aebe-b213a3d11dc7/pasted-text.txt
```

変更しないもの:

- PP獲得量、価格、強化効果、最大レベル
- セーブ形式と既存セーブ互換
- `PowerUpShopManager`の購入、保存、ロールバック、リセット処理
- ショップ解禁、強化ON/OFF、ラン開始時スナップショット
- カテゴリ構成と入力割り当て
- 第2版後に修正した2x2カード、リセット、確認ダイアログのカーソル遷移

## 2. 現行実装の確認結果

対象:

```text
scripts/ui/power_up_shop_screen.gd
scripts/ui/power_up_shop_screen.tscn
scripts/ui/power_up_shop_card.gd
scripts/ui/power_up_shop_card.tscn
scripts/ui/power_up_shop_visual_style.gd
data/power_up_shop.json
scripts/tests/test_power_up_shop_screen_v2.gd
```

既に利用できる実装:

- カード名は`displayName`から`Title`へ設定済み
- 2列x2行のカードグリッド
- カテゴリ別の前回カード位置復元
- CARDS / RESET / RESET_DIALOGの論理フォーカス
- 確認ダイアログの初期キャンセル
- D-pad、左スティック、キーボード、マウス入力
- 購入成功、PP不足、MAXのManagerシグナル
- 4解像度を想定した全面表示と最大幅1360px

第3版で不足している点:

- カード名は16px、`clip_text = true`で、長い名称の読みやすさが不足
- アイコンに共通プレートがない
- レベル表示が1個の文字列で、追加された1ランプだけを点灯できない
- 価格が単純な`120 PP`で、次価格・不足量・MAXの意味が弱い
- カードと詳細が購入状態を別々に算出している
- PP不足でも購入ボタンが通常色のまま
- 詳細パネル幅の最小値が420pxで、内部が単純な縦並び
- 詳細の説明Labelが縦EXPANDし、大きな空白を作る
- カテゴリタグ、効果対象タグ、効果比較ボックスがない
- PPヘッダーが`PP`表記のみ
- フッターのリセットが通常時から警告色
- 背景装飾用ノードが空
- 購入成功時はカード全体を1.08倍にするだけで、追加ランプを特定していない

## 3. 実装方針

全面的な作り直しは行わない。既存の`PowerUpShopScreen`、`PowerUpShopCard`、`PowerUpShopVisualStyle`を拡張し、表示用購入状態だけを小さな共有モデルへ分離する。

変更ファイル:

```text
scripts/ui/power_up_shop_screen.gd
scripts/ui/power_up_shop_screen.tscn
scripts/ui/power_up_shop_card.gd
scripts/ui/power_up_shop_card.tscn
scripts/ui/power_up_shop_visual_style.gd
data/power_up_shop.json
scripts/tests/test_power_up_shop_screen_v2.gd
```

追加ファイル:

```text
scripts/ui/power_up_shop_ui_state.gd
```

`PowerUpShopManager`、`PowerUpSaveStore`、報酬計算、強化効果適用コードは変更しない。

## 4. 表示用購入状態

`scripts/ui/power_up_shop_ui_state.gd`へ表示専用の状態判定を置く。

```gdscript
class_name PowerUpShopUiState
extends RefCounted

enum PurchaseState {
	PURCHASABLE,
	NOT_ENOUGH_PP,
	MAX_LEVEL,
}

static func build(upgrade: Dictionary, level: int, points: int) -> Dictionary:
	var max_level := int(upgrade.get("maxLevel", 5))
	var maxed := level >= max_level
	var prices: Array = upgrade.get("prices", []) as Array
	var price := int(prices[level]) if not maxed and level < prices.size() else 0
	var shortage := maxi(0, price - points)
	var state := PurchaseState.MAX_LEVEL if maxed else (
		PurchaseState.NOT_ENOUGH_PP if shortage > 0 else PurchaseState.PURCHASABLE
	)
	return {
		"state": state,
		"price": price,
		"shortage": shortage,
		"level": level,
		"maxLevel": max_level,
		"points": points,
	}
```

画面更新時に全カード分の状態を一度構築し、カード、選択中詳細、購入ボタンへ同じDictionaryを渡す。カード側で価格や購入可否を再計算しない。

```gdscript
var _purchase_views_by_id: Dictionary = {}
var _selected_purchase_view: Dictionary = {}
```

優先順位は常に`MAX_LEVEL > NOT_ENOUGH_PP > PURCHASABLE`とする。

## 5. シーン構造

### 5.1 画面

```text
PowerUpShopScreen
├── FullScreenBackground
├── BackgroundDecoration
│   ├── HeartEdge
│   ├── SparkleEdge
│   ├── GiftEdge
│   └── CommentEdge
├── SafeAreaMargin
│   └── MainCenter
│       └── ShopContent
│           ├── Header
│           │   ├── TitleBlock
│           │   └── PpCapsule
│           ├── HeaderToTabsGap
│           ├── CategoryTabs
│           ├── TabsToBodyGap
│           ├── Body
│           │   ├── CardSection
│           │   │   └── CardGrid
│           │   └── DetailPanel
│           ├── BodyToFooterGap
│           └── Footer
├── ToastLayer
├── DialogLayer
└── UiSeGroup
```

`ShopContent`の一律separationは0とし、用途別Gap Controlで間隔を管理する。`CardSection`は縦中央寄せをやめて上寄せにし、カード上端と詳細パネル上端を揃える。

### 5.2 カード

```text
PowerUpShopCard
├── CategoryAccent
├── CardContent
│   └── VBox
│       ├── HeaderRow
│       │   ├── IconSlot
│       │   │   └── IconPlate
│       │   │       └── Icon
│       │   └── TextColumn
│       │       ├── UpgradeName
│       │       └── LevelLabel
│       ├── LevelIndicators
│       │   ├── Lamp0
│       │   ├── Lamp1
│       │   ├── Lamp2
│       │   ├── Lamp3
│       │   └── Lamp4
│       └── PriceCapsule
│           └── PriceLabel
└── MaxBadge
```

選択発光はButtonのStyleBoxとCategoryAccentで表現し、装飾用カードを重ねない。

### 5.3 詳細パネル

```text
DetailPanel
└── DetailMargin
    └── DetailContent
        ├── CategoryTag
        │   └── Label
        ├── IconSlotLarge
        │   └── IconPlateLarge
        │       └── LargeIcon
        ├── Name
        ├── Level
        ├── Description
        ├── TargetTags
        ├── EffectComparison
        │   ├── CurrentEffectBox
        │   │   └── CurrentContent
        │   │       ├── Caption
        │   │       └── Value
        │   ├── Arrow
        │   └── NextEffectBox
        │       └── NextContent
        │           ├── Caption
        │           └── Value
        ├── RequiredPointRow
        │   ├── PpIcon
        │   ├── RequiredCaption
        │   ├── RequiredValue
        │   ├── Spacer
        │   └── OwnedOrShortage
        └── PurchaseButton
```

`Description`から`size_flags_vertical = EXPAND_FILL`を外し、3～4行分の固定上限で上詰めにする。

## 6. 基準レイアウト

### 6.1 1600x900

```text
ShopContent幅: 1360px
ShopContent高: 720～750px
Header高: 64～68px
Header→Tabs: 20px
CategoryTabs高: 42px
Tabs→Body: 54～56px
Body高: 520～540px
CardSection幅: 640～660px
DetailPanel幅: 580～600px
Body左右間隔: 48～52px
Footer高: 64～68px
```

カード:

```text
幅: 300～306px
高: 156～162px
横間隔: 16～18px
縦間隔: 16～18px
```

### 6.2 1280x720

```text
ShopContent幅: viewport - 48px = 1232px
ShopContent高: viewport - 40px = 680px
CardSection幅: 620px
DetailPanel幅: 550～560px
Body左右間隔: 28～32px
Tabs→Body: 24～30px
Body高: 490～500px
Footer高: 60～64px
```

縮小順は仕様どおり、間隔、カード縦間隔、詳細余白、フッター高とし、文字サイズは最後にする。

### 6.3 1920x1080以上

```text
ShopContent最大幅: 1360px
ShopContent最大高: 760px
DetailPanel最大幅: 610px
CardGrid最大幅: 620～630px
```

余った空間は画面外周へ返し、カード間隔や詳細パネルを拡張しない。

### 6.4 実装

`_layout_responsive()`で次を更新する。

- `shop_content.custom_minimum_size`
- Header/Tabs/Body/Footer間のGap高さ
- `card_section.custom_minimum_size.x`
- `detail_panel.custom_minimum_size`
- `Body`のseparation
- CardGridの縦横separation
- DetailMarginの上下左右margin

`ShopContent`と`Body`を縦EXPANDさせず、内容量に応じた高さで中央寄せする。これにより詳細パネル下部の空白を解消する。

## 7. カード表示

### 7.1 強化名

- `displayName`のみを使用し、画面側に名称をハードコードしない。
- 既存`Title`を`UpgradeName`へ改名して再利用する。
- 18px Boldを基本とする。
- `clip_text`を無効化する。
- 最大2行、カード高は固定する。
- 省略記号は使用しない。
- 1行に収まる名前は1行のまま表示する。

### 7.2 アイコンプレート

```text
IconSlot: 68x68px
IconPlate: 66x66px、白～淡紫、カテゴリ色2px枠
Icon: 52x52px、KEEP_ASPECT_CENTERED
詳細IconPlate: 104x104px
詳細Icon: 96x96px以内
```

IconSlotの子であるIconPlateだけを動かし、選択時にY=-3pxとしてContainerのレイアウトを乱さない。

### 7.3 レベルランプ

`LevelIndicators`へ16～18pxのPanelContainerを5個置き、角丸を半径いっぱいにして丸型ランプとして描画する。

```text
未購入: fill #F8F5FD / border #D0C4DF 2px
購入済: category color
Lv5の5個目: #FFD767
間隔: 8px
```

文字列`●○`は廃止する。購入成功時は`new_level - 1`番だけを0.7→1.2→1.0で点灯させる。

### 7.4 価格カプセル

状態別表示:

```text
PURCHASABLE:   次の強化  120 PP
NOT_ENOUGH_PP: あと68 PP
MAX_LEVEL:     強化完了  MAX
```

状態別色:

```text
PURCHASABLE:   fill #FFF3C4 / text #302846 / value #E0963D
NOT_ENOUGH_PP: fill #FFE4EB / text #E45F83
MAX_LEVEL:     fill #FFF1B8 / text #C58D20
```

カード全体はPP不足でも暗くしない。

### 7.5 選択

論理フォーカスがカードにある場合のみ次を適用する。

```text
border 3～4px
scale 1.0→1.025 / 0.15s
IconPlate Y 0→-3px / 0.15s
StyleBox shadow 4→8px
z_indexを一時的に上げる
```

既存の`last_input_device`とホバー競合防止を維持する。

## 8. 詳細パネル

### 8.1 カテゴリタグ

カテゴリの表示メタデータを`data/power_up_shop.json`へ追加する。

```json
{"id":"combat","displayName":"戦闘","detailTag":"戦闘強化"}
{"id":"support","displayName":"配信サポート","detailTag":"配信サポート"}
```

タグは14px、カテゴリ薄色背景、カテゴリ濃色文字で表示する。

### 8.2 効果対象タグ

各upgradeへ表示専用の`effectTags`を追加する。セーブ形式とは無関係で、schemaVersionは変更しない。

```text
max_hp:            全キャラクター / 常時有効
attack_power:      武器攻撃 / 相方攻撃 / 召喚攻撃
move_speed:        通常移動 / ダッシュ速度
damage_reduction:  被ダメージ / 常時有効
exp_gain:          敵EXP / 経験値アイテム
pickup_range:      経験値 / 回復アイテム / 通常回収物
healing_power:     戦闘中の回復 / リレー休憩は対象外
gift_luck:         当たり / 大当たり
```

`HFlowContainer`へ最大3個を生成し、更新前に既存子を削除する。タグは13px、`#EEE8F7`背景、`#665D7B`文字とする。

### 8.3 効果比較

現在と次レベルをそれぞれPanelContainer化する。

```text
CurrentEffectBox: fill #EEE8F7 / border #D5CAE5
NextEffectBox:    fill #FFF3C4 / border #FFD767
Current value:    20～24px
Next value:       24～28px / #D79529
```

1280pxでも横並びを維持できる560px幅を確保する。将来560px未満になる場合だけVBoxへ切り替える。

`gift_luck`のHit/Jackpot特殊表示は既存フォーマットを維持する。Lv5では次値を計算せず`MAX`とする。

### 8.4 必要PP

```text
PURCHASABLE:   必要PP 120                 所持PP 520
NOT_ENOUGH_PP: 必要PP 120                 あと68 PP
MAX_LEVEL:     必要PP -                   所持PP 520
```

必要PP側に既存コインアイコンを1つ置く。不足量だけ`#E45F83`を使う。

## 9. 購入ボタン

### 9.1 PURCHASABLE

```text
パワーアップする  120 PP
```

- 背景は選択カテゴリ色
- 白文字、56～60px高
- マウスカーソルは指
- 決定またはクリックでのみ`manager.purchase_upgrade()`を呼ぶ

### 9.2 NOT_ENOUGH_PP

```text
PPが足りません  あと68 PP
```

- fill `#D8D2E2`
- text `#81788F`
- border `#BDB4CA`
- hover、pressedでもカテゴリ色へ変えない
- `disabled = false`としてクリックを受けるが、見た目とカーソルは無効状態
- 決定・クリック時はManagerの購入APIを呼ばず、既存の不足演出だけを起動する
- PP、セーブ、購入成功SEを変更しない

Manager側の残高再検証は、PURCHASABLEから実購入する際の最終防御として維持する。

### 9.3 MAX_LEVEL

```text
強化完了！  MAX
```

- gold style
- `disabled = true`
- 決定・クリックとも無処理
- エラーSEなし

### 9.4 カテゴリ切り替え

購入可能ボタン、詳細枠、カテゴリタグ、アイコンプレートは、戦闘ならピンク、サポートなら水色へ同時に更新する。現行の購入ボタンは戦闘色固定なので必ず修正する。

## 10. ヘッダーとフッター

### 10.1 PPカプセル

```text
[coin] 所持PP     520
```

- Captionを`所持PP`へ変更
- Caption 17px
- 数値 28px Bold
- 不足演出ではカプセルのStyleBox枠を通常→警告→通常と2回切り替える
- `modulate`へ1.0を超える色を入れない

### 10.2 フッター

- 高さ64～68px
- 背景`#211B43`
- 枠`#64597E`、透明度50％程度
- Backは現行位置を維持する
- Resetの通常状態は`#2A2442`、`#8D82A8`、`#D5CDE5`
- Resetへ論理フォーカスが移った場合だけピンク枠と文字にする
- 入力説明へ`Q / E: カテゴリ`を追加する

入力フォーカスのCARDS / RESET / RESET_DIALOG構造は変更しない。Backと購入ボタンへキーボードの別フォーカスを追加しない。

## 11. 背景装飾

既存素材を再利用し、`BackgroundDecoration`の画面端へTextureRectを4～6個置く。

候補:

```text
assets/generated/relay_break_v1/decorations/heart_pink.png
assets/generated/relay_break_v1/decorations/sparkle_blue.png
assets/generated/relay_break_v1/decorations/sparkle_gold.png
assets/generated/relay_break_v1/icon_gift.png
assets/generated/equipment_icons_v1/icons/comment_radar.png
```

- alpha 0.03～0.06
- mouse_filter IGNORE
- KEEP_ASPECT_CENTERED
- 画面四隅・左右端だけに置く
- ShopContent中央の背面へ置かない
- アニメーションは不要

素材不足を理由に第1・第2段階を止めない。

## 12. アニメーション

### 12.1 選択

- 初めて論理フォーカスになったカードだけ0.15s Tween
- 同じカードへの再描画ではTweenを作り直さない
- フォーカスを失ったらscaleとIconPlate位置を0.12sで戻す

### 12.2 購入成功

`_on_upgrade_purchased(id, level, price)`で最終更新後に、対象カードへ`play_purchase_success(level)`を呼ぶ。

```text
新ランプ: 0.7→1.2→1.0
IconPlate: Y 0→-4→0
StarBurst: alpha 0→1→0
合計: 0.3～0.45s
```

既購入ランプは再アニメーションしない。

### 12.3 MAX到達

`level == maxLevel`の場合だけ追加する。

```text
5個目ランプをgold点灯
外周を1回発光
MaxBadge「MAX!」を0.8s表示
小さな星を表示
```

画面全体フラッシュや大きな揺れは使用しない。

### 12.4 PP不足

```text
PurchaseButton X: 0→-8→8→-5→5→0 / 0.34s
PpCapsule border: normal→warning→normal を2回
Error SE: 1回
```

既存`_purchase_cooldown`を維持し、連打でTweenやSEを重ねない。

## 13. データ変更

`data/power_up_shop.json`へ次だけを追加する。

- categories[].detailTag
- upgrades[].effectTags

既存のid、category、displayName、description、iconPath、maxLevel、values、prices、giftLuckは変更しない。

`PowerUpDatabase`は未知の表示キーを既に保持するため、ロード構造の変更は不要。テストで`effectTags`が1～3個の非空文字列であることを検証する。

## 14. 入力との統合

直前に実装した入力改善を維持する。

- 2x2の端でカードが対角へ飛ばない
- 下段の下入力はRESETへ移るだけ
- リセット確認の初期選択はキャンセル
- ダイアログのキャンセルはRESETへ戻る
- 左スティックのデバウンス
- マウスホバーと論理フォーカスの競合防止

第3版のスタイル更新は`_refresh_focus_visuals()`を通し、購入状態スタイルがフォーカス更新で上書きされないよう責務を分ける。

```text
_refresh_purchase_visuals(): カード、詳細、ボタンの購入状態
_refresh_focus_visuals():    カーソル、選択、ダイアログ
```

## 15. 実装順

1. `PowerUpShopUiState`と単体テスト
2. JSONへカテゴリタグ・効果対象タグ追加
3. Cardシーンの名前、IconPlate、5ランプ、PriceCapsule
4. Cardへ共通購入状態を渡す
5. Detailシーンを上詰め構造へ変更
6. CategoryTag、TargetTags、EffectBox、RequiredPointRow
7. 購入ボタン3状態とカテゴリ色
8. Header PP表記とFooter軽量化
9. レスポンシブ寸法とGap調整
10. 選択、購入成功、PP不足、MAX演出
11. 背景端の低透明度装飾
12. 自動テストと4解像度の視覚確認

## 16. 自動テスト

既存`test_power_up_shop_screen_v2.gd`を拡張し、入力回帰テストを削除しない。

### 16.1 状態モデル

- points == priceはPURCHASABLE
- points == price - 1はNOT_ENOUGH_PP、shortage == 1
- level == maxLevelはpointsに関係なくMAX_LEVEL
- 8強化すべてで価格インデックスが正しい

### 16.2 カード

- 8カードに`displayName`が表示される
- 長い名称が2行以内で、省略記号とクリップを使わない
- Lampが常に5個
- Lv0～Lv5で点灯数が一致
- 通常、PP不足、MAXの価格文字列と色が一致
- Cardが受け取ったstateと選択詳細のstateが一致

### 16.3 詳細

- category tagが正しい
- effectTagsが最大3個表示される
- Lv0の現在値は`なし`
- Lv5の次値は`MAX`
- gift_luckの特殊表示を維持
- 必要PP、所持PP、不足量が正しい

### 16.4 購入

- PP不足時にManager購入APIまたはSaveStoreが呼ばれない
- PP不足時にPPが減らない
- PP不足時に不足TweenとエラーSEが1回だけ
- MAX決定はManager、SaveStore、エラーSEを呼ばない
- 購入可能時だけ既存購入が成功する
- 購入成功時に`level - 1`のランプだけが対象になる

### 16.5 レスポンシブ

- 1280x720、1600x900、1920x1080、2560x1440
- CardGrid、DetailPanel、PurchaseButton、Footerが画面内
- ShopContent最大幅1360px
- 詳細パネルが画面高いっぱいに引き伸ばされない
- 1280x720でカード名、タグ、価格、購入ボタンが重ならない

## 17. 視覚確認

修正後に1プロセス内で4解像度を順にキャプチャする。

確認項目:

- カードだけで名前、レベル、次価格が読める
- PP不足ボタンがピンク・水色に見えない
- タブとカードが同じグループに見える
- 詳細の上から下に不自然な空白がない
- 現在値より次値が少し強く見える
- リセットが購入ボタンより目立たない
- 長い名前と`リレー休憩は対象外`が切れない
- マウスホバーとキー選択が二重に見えない

Godot GUIが起動中の場合は別headlessプロセスを同時起動しない。静的確認、JSON、`git diff --check`を先に行い、Godot検証は競合しない状態の1プロセスへ集約する。signal 11が出た場合は同じコマンドを再実行しない。

## 18. 受け入れ条件

- 8カードすべてに判読可能な強化名がある
- カードだけで現在Lv、5ランプ、次価格または不足量、MAXが分かる
- アイコンの見た目サイズが共通プレートで揃う
- カード、詳細、購入ボタンが同じ購入状態を使用する
- PP不足ボタンは灰紫で不足量を表示し、購入・保存・PP減少を行わない
- MAXはgold表示で、決定・クリック・エラーSEが無処理
- 詳細にカテゴリタグと最大3個の効果対象タグがある
- 詳細の名前、説明、効果、必要PP、購入ボタンが上詰めで連続する
- 現在効果と次レベル効果がボックスで比較できる
- 所持PP表記と不足演出が明確
- タブとカード一覧の距離が縮まる
- リセットは通常時に警告色を使わない
- 第2版の入力改善、購入、保存、リセット、既存セーブへ回帰がない
- 1280x720～2560x1440で切れ、重なり、過剰な間延びがない
