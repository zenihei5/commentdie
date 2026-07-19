# 『ぜんぶコメントのせいだ』
# パワーアップショップ第4版 ゲーム固有表現・成長演出 実装設計

## 1. 目的

実装済みの第3版と入力改善を土台に、ショップへ本作固有の案内役、成長段階、購入リアクション、カテゴリ演出を追加する。

参照仕様:

```text
C:/Users/zenih/.codex/attachments/6d9c422b-17da-4a56-99a4-2a1519e3fe95/pasted-text.txt
```

本設計は表示層の拡張であり、次を変更しない。

- PP獲得量、価格、強化効果、最大レベル
- `PowerUpShopManager`の購入、保存、ロールバック、リセット処理
- 既存セーブ形式と既存セーブ互換
- 8強化項目と戦闘／配信サポートの2カテゴリ
- CARDS / CATEGORY_TABS / RESET / RESET_DIALOGの入力遷移
- 2x2カード遷移、タブ・フッター操作、マウス／キー競合防止
- PP不足時のManager・SaveStore未呼び出し、MAX時の完全無処理

## 2. 現行実装との照合結果

第3版として、以下は実装済みである。

- `PowerUpShopUiState.PurchaseState`による3状態の共通判定
- カード名、IconPlate、5個の独立ランプ、PriceCapsule
- カテゴリタグ、対象タグ、現在／次Lv比較、必要PP、購入ボタン
- 戦闘ピンク／配信サポート水色のカテゴリ差
- PP不足・購入成功・MAXの小演出
- 最大幅1360pxのレスポンシブ配置
- 4解像度と入力遷移を含む`test_power_up_shop_screen_v2.gd`

第4版で補うもの:

- Lv0 / Lv1～2 / Lv3～4 / Lv5のカード成長段階
- 一覧内の短い効果ラベルと、PP不足時の価格・不足量併記
- 総強化Lv 0～40
- 詳細アイコン装飾、大型レベルゲージ、左端アクセント
- 選択カードから詳細へ伸びる接続ライン
- リスナーマスコットと状態別リアクション
- カテゴリ別背景、購入可能ボタンの強調、PPから飛ぶ購入光
- 軽量なフッター

現行の`_refresh_view()`は毎回カードを破棄・再生成している。第4版の購入途中の段階変化、カテゴリクロスフェード、Tween管理を安定させるため、カードは初回だけ生成して再利用する。

## 3. 実装ファイル

変更:

```text
data/power_up_shop.json
scripts/ui/power_up_shop_ui_state.gd
scripts/ui/power_up_shop_visual_style.gd
scripts/ui/power_up_shop_card.gd
scripts/ui/power_up_shop_card.tscn
scripts/ui/power_up_shop_screen.gd
scripts/ui/power_up_shop_screen.tscn
scripts/tests/test_power_up_shop_screen_v2.gd
```

追加:

```text
scripts/ui/power_up_shop_connector.gd
```

`PowerUpShopManager`、`PowerUpSaveStore`、強化効果適用コードは変更しない。

## 4. 表示モデル

新しい動的状態クラスを重複追加せず、既存の`PowerUpShopUiState`を表示データ生成役へ拡張する。既存の`build()`と既存キーは維持し、テストと呼び出し互換を保つ。

```gdscript
enum UpgradeVisualTier {
	UNPURCHASED,
	LOW,
	HIGH,
	MAX,
}

static func visual_tier_for_level(level: int, max_level: int = 5) -> int:
	if level <= 0:
		return UpgradeVisualTier.UNPURCHASED
	if level <= 2:
		return UpgradeVisualTier.LOW
	if level < max_level:
		return UpgradeVisualTier.HIGH
	return UpgradeVisualTier.MAX
```

`build()`の返却Dictionaryへ次を追加する。

```text
id
displayName
category
state / price / shortage / points / level / maxLevel
visualTier
cardEffectSummary
cardPriceText
currentEffectText
nextEffectText
iconPath
effectTags
```

画面は1更新につき各強化のViewを1回だけ構築し、カード、詳細、購入ボタン、マスコットへ同じDictionaryを渡す。カード内で価格、効果、VisualTierを再計算しない。

### 4.1 静的表示メタデータ

短いラベルの語句をカードスクリプトへハードコードしない。`data/power_up_shop.json`の各upgradeへ静的な表示メタデータだけを追加する。

```json
"cardSummary": {
  "levelZero": "最大メンタルを強化",
  "valueLabel": "最大メンタル",
  "format": "percent_up"
}
```

使用する`format`:

```text
percent_up        現在の累積値を「+N％」で表示
percent_down      現在の累積値を「-N％」で表示
fixed_by_level    Lv0とLv1以上で固定文言を切替
```

`gift_luck`だけは次の形にする。

```json
"cardSummary": {
  "levelZero": "当たり抽選を強化",
  "levelOnePlus": "当たり・大当たり率UP",
  "format": "fixed_by_level"
}
```

Lv2以降の通常項目は`values[level]`の累積値を表示する。例としてメンタルLv2は`最大メンタル +8％`、炎上耐性Lv3は`被ダメージ -6％`とする。マスターデータへ現在Lv、所持PP、購入状態などの動的値は保存しない。

### 4.2 総強化Lv

```gdscript
total_level = 全upgradeのmanager.get_upgrade_level(id)合計
max_total_level = 全upgradeのmaxLevel合計
```

現在は`0～40`になるが、40をUIへ固定値として埋め込まずデータから合計する。表示時、購入成功演出の反映時、リセット時、再読込時に更新する。

## 5. カードの常駐化

`_rebuild_cards()`を次へ分割する。

```text
_ensure_card_pool()   manager/database変更時だけ8枚を生成
_refresh_cards()      ViewDataと選択状態だけ更新
_show_category_cards() 対象カテゴリ4枚だけvisible=true
```

保持:

```gdscript
var _cards_by_category := {"combat": [], "support": []}
var _cards_by_id: Dictionary = {}
var _cards: Array = [] # 現在カテゴリの4枚。既存入力処理との互換用
```

8枚は同じ`GridContainer`へカテゴリ順に追加し、非対象4枚を非表示にする。GodotのContainerは非表示Controlをレイアウト対象から外すため、2x2配置を維持できる。カードの生成・破棄はmanager/databaseが差し替わった場合だけ行う。

これにより購入対象カードの参照、前Lv、旧VisualTierを演出完了まで保持できる。非表示カードのTweenと低頻度粒子は停止する。

## 6. カード構造と成長段階

`PowerUpShopCard`は高さ184px前後を基準とする。

```text
PowerUpShopCard
├── TierDecoration
├── SelectionLamp
├── CategoryAccent
├── CardContent
│   └── VBox
│       ├── HeaderRow
│       ├── EffectSummary
│       ├── LevelIndicators
│       └── PriceCapsule
├── MaxRibbon
└── TransitionSpark
```

`TierDecoration`は入力を持たないControlとし、静的な斜線・星・コメント粒を`_draw()`で描く。レベル変更時だけ`queue_redraw()`し、常時processしない。

### 6.1 表示段階

`UNPURCHASED`:

- 背景`#F8F5FD`、枠`#D8CEE8`
- 模様なし、IconPlate発光なし
- 既存の未点灯ランプ

`LOW`:

- カテゴリ色の細い内枠
- IconPlateに弱い光
- 背景模様alpha 2～3％

`HIGH`:

- カテゴリ色の軽いグラデーション相当の枠
- 背景模様alpha 4～6％
- IconHaloと上部の小光粒
- 点灯済みランプを弱く発光

`MAX`:

- カテゴリ色＋`#FFD767`の内枠
- 右上に文字入り`MAX`リボン
- IconHalo、全ランプ点灯、模様alpha 6～8％
- 表示中カードだけ、1個の小光粒を低頻度で移動

選択／論理フォーカスはVisualTierと別レイヤーにする。既存`SelectionLamp`と外側の太枠を選択表現に使い、Tierの内枠を上書きしない。

### 6.2 効果ラベルと価格

`EffectSummary`:

- 13～15px、`#746B8D`、1行
- 自動縮小または長文のみ小さいfont sizeへ切替
- レベルランプの直前へ置く

`PriceCapsule`:

```text
PURCHASABLE:    次 120 PP
NOT_ENOUGH_PP: 必要120　あと68
MAX_LEVEL:     強化完了　MAX
```

不足時も価格と不足量の両方を必ず表示する。カード幅が狭い時だけ`次 120 PP　不足68`ではなく短い`必要120　あと68`を使う。

## 7. ヘッダーの総合進行度

`Header`へ`TotalProgressArea`をTitleBlockとPpCapsuleの間に追加する。

```text
POWER-UP PROGRESS
総強化Lv 12 / 40
[ProgressBar]
```

- 幅220px前後、高さ52px
- ラベル14px、数値20px、バー高10px
- 背景は淡紫、塗りはピンクから水色
- MAX時だけバー上辺へ細い金線を追加
- PPカプセルより強い発光や大きな文字を使わない

`TextureProgressBar.max_value`は`max_total_level`、`value`は`total_level`とする。購入反映時は0.18～0.24秒の短い補間を許可する。

## 8. 詳細パネル再配置

第4版の要素を単純に縦追加すると1280x720で溢れるため、上部と購入部を横並びにする。

```text
DetailPanel
├── DetailOverlay
│   └── LeftAccent
└── DetailMargin
    └── DetailContent
        ├── CategoryTag
        ├── HeroRow
        │   ├── LargeIconDecoration
        │   │   ├── BackGlow
        │   │   ├── UpgradeArrow
        │   │   ├── DecorationRing
        │   │   ├── SparkNodes
        │   │   └── LargeIcon
        │   └── TitleGaugeColumn
        │       ├── Name
        │       ├── Level
        │       └── DetailLevelGauge
        ├── Description
        ├── TargetTags
        ├── EffectComparison
        └── PurchaseAndMascotRow
            ├── PurchaseColumn
            │   ├── RequiredPointRow
            │   └── PurchaseButton
            └── MascotArea
```

1280x720基準:

```text
HeroRow                 116～124px
LargeIconDecoration     136～152px
LargeIcon               88～96px
DetailLevelGauge lamp   22px x 5、間隔10px
PurchaseAndMascotRow    100～108px
MascotArea              92～104px
```

詳細パネルの内側余白はcompact時16px、通常時20～24pxとする。説明文36～42px、効果比較68～72pxを基準にし、下端へ不要なEXPANDを付けない。

`DetailOverlay`はPanelContainer内の全面Controlとして常駐させる。左端に5～8pxのカテゴリ色ラインを置き、他の外周は淡紫の2pxとする。選択変更時だけ左端ラインを0.18秒発光させる。

### 8.1 詳細アイコン装飾

戦闘:

- ピンク～赤紫のBackGlow
- 細い斜線、火花、上向き矢印

配信サポート:

- 水色～ミントのBackGlow
- 円形波紋、星、コメント粒

装飾はアイコンより低いalphaで、文字やアイコン輪郭を隠さない。カテゴリ切替時は既存ノードの色・表示を更新し、作り直さない。

### 8.2 詳細レベルゲージ

5個の独立したランプを配置する。カード側とは別ノードだが、同じViewDataのlevelを参照する。購入成功時は`new_level - 1`だけを0.7→1.2→1.0で点灯させる。

## 9. リスナーマスコット

既存素材を使用する。

```text
通常＋黄色サイリウム:
assets/generated/weapon_fx_v1/listener_summon.png

汗:
assets/generated/no_brake_sweat_icon_v1/sweat.png

星・ハート:
assets/generated/relay_break_v1/decorations/sparkle_gold.png
assets/generated/relay_break_v1/decorations/sparkle_blue.png
assets/generated/relay_break_v1/decorations/heart_pink.png
```

`listener_summon.png`自体に黄色サイリウムが含まれるため、第一版では別パーツを生成しない。

```gdscript
enum MascotState {
	PURCHASABLE,
	NOT_ENOUGH_PP,
	SUCCESS,
	MAX,
}
```

表示は1体だけ常駐させ、状態画像を切り替えずTransformと補助エフェクトで差を作る。

- 通常: 1.8秒周期でY 0→-2→0
- 購入可能: 全体を±1.5度だけ揺らし、小さな金星1～2個
- PP不足: Yを2px下げ、-4度傾け、汗を1個表示
- 購入成功: Yを-8px、scale 1.06、星／ハート3～5個、0.6秒で待機へ戻す
- MAX: scale 1.10、金・白・カテゴリ色の星、0.9秒でMAX待機へ戻す

補助エフェクトは固定個数のTextureRectを事前作成し再利用する。状態更新でTweenをkillして基準Transformへ戻してから、新しい状態を開始する。ショップ非表示中は待機Tweenも停止する。

## 10. 選択接続ライン

`SelectionConnectorLayer`を`BackgroundDecoration`の後、`SafeAreaMargin`の前へ置く。これによりカード・詳細パネルより背面へ描画される。

`power_up_shop_connector.gd`はControlの`_draw()`で1本だけ描く。

```gdscript
start = to_local(selected_card.global_position + Vector2(selected_card.size.x, selected_card.size.y * 0.5))
end = to_local(detail_panel.global_position + Vector2(0.0, detail_panel.size.y * 0.5))
```

- 太さ3px、alpha 35％
- カテゴリ色
- 必要なら同じ線上を移動する光粒1個だけ
- `mouse_filter = IGNORE`
- 固定座標禁止

更新契機:

- 選択カード変更
- カテゴリ変更完了後
- `_layout_responsive()`完了後
- `NOTIFICATION_RESIZED`後
- ショップ表示時

Container配置確定後に`call_deferred()`または1フレーム待って座標を再計算する。対象Controlが非表示またはsizeゼロの間はラインを隠す。

## 11. カテゴリ別背景

既存`BackgroundDecoration`を次へ整理し、両レイヤーを常駐させる。

```text
CategoryBackgroundDecoration
├── CombatDecoration
└── SupportDecoration
```

戦闘は斜線・火花・上向き矢印、サポートは既存heart / sparkle / gift / comment素材を使う。alphaは3～7％。中央の情報領域へ強い画像を置かない。

カテゴリ切替時は0.25秒で旧レイヤー1→0、新レイヤー0→1へクロスフェードする。Tween中の再切替は直前Tweenをkillし、現在alphaから新しいTweenを開始する。ノードを生成・破棄しない。

詳細内部の模様も同じカテゴリ状態で更新し、alpha 2～5％に抑える。

## 12. 購入ボタン

購入状態判定と入力フォーカスは第3版を維持する。

`PURCHASABLE`:

```text
↑ パワーアップする　120 PP
```

- 戦闘はピンク～赤紫、サポートは水色～ミント
- 白文字、PP数値は黄色
- 弱い外周光と上辺の光沢
- hover／論理選択時はscale 1.015、矢印Y=-2px、0.18秒
- pressedは1.0→0.97→1.0、0.15秒

`NOT_ENOUGH_PP`:

```text
PPが足りません
あと 68 PP
```

- 灰紫、発光・矢印なし
- hoverでもカテゴリ色へ変えない
- 既存の横揺れ、PPカプセル警告、エラーSEを維持
- Manager購入APIとSaveStoreは呼ばない

`MAX_LEVEL`:

- 金色、`強化完了！ MAX`
- disabled、決定／クリック／エラーSEは無処理

二段文字が必要な不足状態は、Button直下へVBoxを置くか、既存Buttonのdraw機能で描画する。入力対象は購入Button 1個のまま増やさない。

## 13. 購入成功シーケンス

保存成功後にだけ演出を開始する。Managerのトランザクション完了より先に見た目を成功扱いにしない。

現行Managerは成功時に次の順で同期シグナルを送る。

```text
_commit成功
points_changed
upgrade_purchased
```

この順序へ合わせ、購入開始前に次を記録する。

```text
pending_upgrade_id
previous_level
previous_visual_tier
target_card
```

ローカル購入中の`points_changed`ではPP数値だけを更新し、カードと詳細の全refreshを一時保留する。`upgrade_purchased`で保存済み状態を確認後、次を実行する。

```text
0.00s  PPカプセルの数値を更新、小さな黄色光を生成
0.00～0.32s PPカプセル→詳細大型アイコンへ光移動
0.32s  新ViewDataでカード、詳細、総強化Lv、価格を更新
0.32～0.52s 新しいカードランプと詳細ランプだけ点灯
0.34～0.60s IconHaloとVisualTierを新段階へ遷移
0.34～0.70s マスコット成功リアクション
```

光はroot座標で開始・終了位置を算出し、二次BezierまたはTweenで1個だけ移動する。開始は`pp_capsule`中央下、終了は`detail_icon`中央。大粒や全画面フラッシュは使わない。

入力ロック:

- 光移動中の約0.35秒だけ、方向・カテゴリ・購入決定・カードクリックを無効化
- 戻る／キャンセルによるショップ終了は許可
- 光到着後は、残りのマスコット・カードTween中でも操作を再開
- 購入ボタンは全体0.45～0.75秒の多重購入防止時間中だけ再購入不可

閉じた場合は光、Tween、pending状態を破棄する。データは既に保存済みなのでロールバックしない。次回open時の通常refreshで正しい状態を表示する。

購入失敗時はpending状態を即時解除し、成功光・Tier変化・マスコット成功を再生しない。外部の`points_changed`は従来通り全refreshする。

### 13.1 MAX到達

Lv4→Lv5だけ次を追加する。

- 5個目の詳細ランプを強く点灯
- カード内枠をカテゴリ色＋金へ遷移
- `MAX`リボンを表示
- IconHalo周辺に少数の星
- マスコットMAXリアクション
- `MAX!`を0.8～1.0秒表示

全画面フラッシュ、大量紙吹雪、連続点滅は使用しない。

## 14. フッター

戻る、全強化リセット、既存の論理フォーカスは維持する。

- 全周枠を除去するかalpha 25％へ下げる
- 上辺だけ1pxの淡紫線
- 背景は`#1D1838`を少し透過
- 操作説明alpha 70％
- Reset通常時は中立色、RESETフォーカス時だけピンク枠
- 確認ダイアログの実行ボタンだけ警告色

## 15. レスポンシブ配置

対象は1280x720、1600x900、1920x1080、2560x1440。既存最大幅1360pxを維持する。

1280x720での優先順位:

1. カード名、効果ラベル、価格を切らない
2. 詳細の現在／次効果、必要PP、購入ボタンを切らない
3. マスコットは84～92pxまで縮小可能
4. 詳細装飾と背景装飾の量を減らす
5. 総合進行バーは180pxまで縮小可能

装飾を縮小しても情報文字を縮めすぎない。マスコット、ライン、背景装飾はすべて`mouse_filter = IGNORE`とする。

## 16. ライフサイクルと負荷

`open_shop()`:

- 常駐カードを確保
- 全ViewDataと総強化Lvを再構築
- カテゴリ背景、接続ライン、マスコット待機を開始

`close_shop()` / `_reset_transient_state()`:

- 画面、カード、マスコット、カテゴリ、購入光の全Tweenをkill
- 接続光粒、汗、星、ハートを基準状態へ戻す
- pending購入演出と入力ロックを解除
- 非表示カテゴリの低頻度演出を停止

禁止:

- カテゴリ切替ごとのカード／背景／マスコット生成破棄
- カードごとの常時`_process()`
- 非表示カテゴリのParticleSystem稼働
- 接続ラインの複数生成
- Timer/Tweenを閉じたショップに残すこと

## 17. アクセシビリティ

- VisualTierは色や発光だけでなく、模様密度、ランプ、MAX文字で区別
- カテゴリは色だけでなく斜線／火花と星／コメントの形で区別
- PP不足は必ず文言と不足数を表示
- MAXは必ず文字入りリボンを表示
- 高速点滅、全画面フラッシュ、強い連続揺れを使わない
- マスコット演出が停止しても購入状態を判断できる
- 背景と詳細模様のalpha上限を守り、文字の背後を空ける

## 18. テスト

既存`test_power_up_shop_screen_v2.gd`を拡張し、入力回帰テストを削除しない。

純粋状態:

- level 0→UNPURCHASED、1・2→LOW、3・4→HIGH、5→MAX
- 8項目すべてのLv0／Lv1以上の短い効果ラベル
- 累積値表示、炎上耐性のマイナス表記、gift_luck固定文言
- 購入可能、PP不足、MAXのカード価格文言
- PP不足文言に必要価格と不足量の両方を含む

総強化Lv:

- 全Lv0で0/40、1購入で1/40、複数合計、全MAXで40/40
- リセット後0/40、セーブ相当profile再読込後の復元

カード／詳細:

- カードが初回生成後に購入refreshとカテゴリ往復で同一instance
- カテゴリ4枚だけ表示、非表示4枚のTween停止
- TierDecoration、EffectSummary、MaxRibbonの状態
- 詳細5ランプ、カテゴリ装飾、左端アクセント
- 選択カードと詳細が同じViewDataを参照

接続／背景:

- 4解像度でstart/endが現在Control矩形と一致しfinite
- 選択、カテゴリ、resize後に更新
- カテゴリ背景は常駐2レイヤーで、切替後のalphaが正しい
- 切替回数で背景ノード数が増えない

マスコット:

- 購入可能、PP不足、成功、MAXの状態遷移
- 成功後に待機へ戻る
- カテゴリ変更、close/reopenでTransformと補助エフェクトが初期化

購入:

- PP減算と保存成功が先、成功演出が後
- `points_changed`と`upgrade_purchased`の二重refreshを抑制
- 光の終了先が選択中詳細アイコン
- 新しいランプだけを点灯
- 0.35秒中の多重購入、選択変更、カテゴリ変更が起きない
- 戻るで閉じても保存状態は維持しTweenが残らない
- PP不足・MAX・保存失敗で成功演出なし

視覚確認:

- 1プロセス内で1280x720、1600x900、1920x1080、2560x1440を順に撮影
- Lv0 / LOW / HIGH / MAX、戦闘／サポート、PP不足を最低1枚ずつ含める
- 文字切れ、カードと詳細の不一致、マスコットの重なり、接続線位置、背景可読性を確認

テストはFake Storeを使い、ユーザーセーブを書き換えない。

## 19. 実装順

1. `PowerUpShopUiState`へVisualTier、効果ラベル、価格文言、総合進行計算を追加
2. JSONへ静的`cardSummary`を追加し、純粋状態テストを追加
3. カードを常駐化し、EffectSummaryとTierDecoration、MAXリボンを追加
4. ヘッダー総強化Lvを追加
5. 詳細をHeroRow / PurchaseAndMascotRowへ再配置し、大型ゲージを追加
6. 詳細アイコン装飾、左端アクセント、接続ラインを追加
7. マスコットと状態別リアクションを追加
8. カテゴリ背景を常駐2レイヤーへ整理
9. 購入ボタンと購入成功シーケンスを追加
10. MAX演出、フッター、ライフサイクルを仕上げ
11. 回帰テスト、静的確認、1プロセスの4解像度視覚確認

## 20. 完成条件

- 第4版仕様のマスコット、成長段階、総強化Lv、効果ラベル、接続線、購入光が表示される
- 1280x720～2560x1440で文字、カード、詳細、マスコットが重ならない
- 戦闘／配信サポートで背景と詳細装飾が形・色ともに変わる
- 購入・保存完了前に成功演出を出さない
- 購入後に正しい1ランプ、VisualTier、価格、総強化Lvだけが更新される
- PP不足とMAXの既存取引保証を維持する
- 第3版と入力改善の全回帰テストを維持する

## 21. 検証時のGodot安全手順

1. JSON、GDScriptの静的照合、`git diff --check`を先に行う
2. Godot GUI起動中は別headlessプロセスを同時起動しない
3. ユーザーのGodotエディタを終了・killしない
4. 実行テストと4解像度撮影は競合しない時に1プロセスへまとめる
5. native signal 11が出た場合は同じGodotコマンドを再実行せず、その時点の静的確認結果とともに報告する
