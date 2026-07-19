# 『ぜんぶコメントのせいだ』
# パワーアップショップ第2版 見た目ブラッシュアップ実装設計

## 1. 目的と非対象

本設計は、パワーアップショップ第1版の購入・報酬・強化・保存処理を維持したまま、`PowerUpShopScreen`の表示層と操作フィードバックを第2版仕様へ更新するための実装設計である。

変更対象:

- フルスクリーン表示と解像度追従
- ヘッダー、カテゴリタブ、カード、詳細、フッターの再構成
- マウス購入導線
- 選択、購入成功、PP不足、MAX、リセットの短い演出
- 既存素材を使った仮アイコン

変更しないもの:

- PP報酬計算
- 8種の強化ID、価格、効果値、最大レベル
- `PowerUpSaveStore`の保存形式
- `PowerUpShopManager`の購入・リセット・原子的保存処理
- ショップ解禁条件
- ラン開始時スナップショットと強化ON/OFF
- キーボード、ゲームパッドの入力割り当て

参照仕様:

```text
C:/Users/zenih/.codex/attachments/3d18836e-4158-4377-ba8d-0092ea8904f2/pasted-text.txt
```

## 2. 現行実装の確認結果

### 2.1 画面構造

現行`PowerUpShopScreen`は、空に近い1枚の`Control`へ`_draw()`で全要素を描いている。

- カード、タブ、購入情報、リセット確認は固定座標
- マウス判定も固定`Rect2`
- 詳細欄に購入ボタンがない
- カードクリックが選択と購入を同時に実行する
- 画面幅だけ`max(1280, size.x)`で補正し、高さと中央寄せは固定
- `ThemeDB.fallback_font`を使い、既存ゲームフォントを使っていない

`power_up_shop_screen.tscn`はルート`Control`のみで、レスポンシブなコンテナ階層を持たない。

### 2.2 白い余白の構造要因

ゲーム本体は`Node2D`で、通常UIは`UiBuilderSystem`が生成する`CanvasLayer`へ載っている。一方、ショップだけは`game.gd`から`Node2D`直下へ追加されている。

```gdscript
power_up_shop_screen = PowerUpShopScreenScene.instantiate()
add_child(power_up_shop_screen)
```

この配置と固定座標描画を併用しているため、ビューポート変更時に通常UIと同じ全面追従を保証できない。第2版ではショップを既存UI用`CanvasLayer`へ移し、背景と入力面をFull Rectにする。

### 2.3 利用可能な既存API

`PowerUpShopManager`には表示更新に必要なAPIとシグナルが既にある。

```text
current_points()
get_upgrade_level(id)
calculate_refund_points()
purchase_upgrade(id)
reset_all_upgrades()

points_changed(previous, current)
upgrade_purchased(id, new_level, price)
upgrades_reset(refund)
purchase_failed(reason)
```

第2版でManagerを作り直す必要はない。表示値はDBと上記APIから構成する。

### 2.4 既存の表示素材

専用ショップ素材は未提供だが、仮アイコンとして使える透過PNGがある。

```text
assets/generated/equipment_icons_v1/icons/
assets/generated/relay_break_v1/icon_heal.png
assets/generated/relay_break_v1/icon_gift.png
assets/generated/gameplay_event_objects_v1/coin.png
```

フォントは`GameFontSystem`のM PLUS Rounded 1cを使用する。

## 3. 実装方針

### 3.1 ロジックと表示を分離する

`PowerUpShopScreen`は画面状態とManager接続を担当し、カードの見た目は`PowerUpShopCard`へ分ける。

```text
PowerUpShopManager
  -> 購入、保存、残高、Lv、結果シグナル

PowerUpShopScreen
  -> 選択、カテゴリ、入力源、詳細更新、演出制御

PowerUpShopCard
  -> 1カード分の表示、ホバー、選択、レベルランプ、価格

PowerUpShopVisualStyle
  -> 色、StyleBoxFlat、レスポンシブ寸法
```

購入可否をUI側で再実装しない。UIは表示のために残高・価格・Lvから状態を導出し、実際の購入確定は必ず`manager.purchase_upgrade()`へ委譲する。

### 3.2 固定座標描画を廃止する

背景装飾の軽い描画を除き、情報と操作部品は実Controlノードへ置き換える。

理由:

- アンカーとContainerで白い余白を防げる
- マウス判定がノードの実Rectと一致する
- 文字折返し、最小サイズ、フォーカス、ツールチップをGodotへ任せられる
- 選択状態とアニメーションをカード単位で管理できる

## 4. 変更ファイル

### 更新

```text
scripts/ui/power_up_shop_screen.tscn
scripts/ui/power_up_shop_screen.gd
scripts/systems/ui_builder_system.gd
scripts/game.gd
data/power_up_shop.json
scripts/tests/test_power_up_shop.gd
```

### 追加

```text
scripts/ui/power_up_shop_card.tscn
scripts/ui/power_up_shop_card.gd
scripts/ui/power_up_shop_visual_style.gd
scripts/tests/test_power_up_shop_screen_v2.gd
scripts/tests/test_power_up_shop_screen_v2.tscn
```

`PowerUpShopManager`、`PowerUpSaveStore`、報酬計算系は原則変更しない。

## 5. CanvasLayerへの接続

`UiBuilderSystem.build_ui()`の戻り値へ、生成済み`CanvasLayer`を追加する。

```gdscript
return {
    "uiRoot": ui,
    # 既存項目
}
```

`game.gd::_build_ui()`ではショップを`Node2D`直下ではなく`uiRoot`へ追加する。

```gdscript
var ui_root := nodes["uiRoot"] as CanvasLayer
power_up_shop_screen = PowerUpShopScreenScene.instantiate()
ui_root.add_child(power_up_shop_screen)
```

ショップはUI内で最後に追加し、既存タイトル、チャット、HUDより前面に表示する。既存Godotエディタやゲーム全体のCanvasLayer構造を作り直さない。

## 6. シーン構造

```text
PowerUpShopScreen : Control
├── FullScreenBackground : TextureRect
├── BackgroundDecoration : Control
├── SafeAreaMargin : MarginContainer
│   └── MainCenter : CenterContainer
│       └── ShopContent : VBoxContainer
│           ├── Header : HBoxContainer
│           │   ├── BackButton : Button
│           │   ├── TitleBlock : VBoxContainer
│           │   │   ├── EnglishTitle : Label
│           │   │   └── Title : Label
│           │   ├── HeaderSpacer : Control
│           │   └── PpCapsule : PanelContainer
│           │       └── PpRow : HBoxContainer
│           │           ├── PpIcon : TextureRect
│           │           ├── PpCaption : Label
│           │           └── PpValue : Label
│           ├── CategoryTabs : HBoxContainer
│           │   ├── CombatTab : Button
│           │   └── SupportTab : Button
│           ├── Body : HBoxContainer
│           │   ├── CardSection : CenterContainer
│           │   │   └── CardGrid : GridContainer
│           │   └── DetailPanel : PanelContainer
│           │       └── DetailMargin : MarginContainer
│           │           └── DetailContent : VBoxContainer
│           │               ├── LargeIcon : TextureRect
│           │               ├── UpgradeName : Label
│           │               ├── DetailLevel : Label
│           │               ├── Description : Label
│           │               ├── ComparisonArea : VBoxContainer
│           │               │   ├── CurrentBox : PanelContainer
│           │               │   ├── CompareArrow : Label
│           │               │   └── NextBox : PanelContainer
│           │               ├── RequiredPointArea : HBoxContainer
│           │               └── PurchaseButton : Button
│           └── Footer : PanelContainer
│               └── FooterRow : HBoxContainer
│                   ├── ResetButton : Button
│                   ├── FooterSpacer : Control
│                   └── InputHints : HBoxContainer
├── ToastLayer : Control
│   └── ToastPanel : PanelContainer
├── DialogLayer : Control
│   └── ResetDialog : PanelContainer
└── UiSeGroup : Node
    ├── CursorSe : AudioStreamPlayer
    ├── PurchaseSe : AudioStreamPlayer
    ├── ErrorSe : AudioStreamPlayer
    └── MaxSe : AudioStreamPlayer
```

ルート、背景、ToastLayer、DialogLayerはFull Rect。背景装飾は`MOUSE_FILTER_IGNORE`、通常画面は`MOUSE_FILTER_STOP`とする。

## 7. レスポンシブレイアウト

プロジェクトの基準ビューポートは1600x900、stretchは`canvas_items`である。ショップは論理サイズへ追従し、1920x1080以上でもコンテンツを1360pxより広げない。

### 通常レイアウト

対象: 高さ800px以上

```text
左右SafeArea: 48px
上下SafeArea: 28px
ShopContent最大幅: 1360px
ShopContent最大高: 844px
Header: 96px
CategoryTabs: 64px
Body: 580px
Footer: 72px
縦間隔: 10px
```

### コンパクトレイアウト

対象: 高さ800px未満、代表1280x720

```text
左右SafeArea: 32px
上下SafeArea: 18px
ShopContent幅: available width
Header: 72px
CategoryTabs: 48px
Body: 480px
Footer: 58px
縦間隔: 8px
```

合計高を720px内へ収める。スクロールは追加しない。

### 本文比率

```text
CardSection stretch_ratio: 1.62
DetailPanel stretch_ratio: 1.0
本文間隔: 通常32px / コンパクト22px
DetailPanel最小幅: 420px
```

カードは2列x2行を維持する。

```text
通常カード: 300x180px前後
コンパクトカード: 270x164px前後
カード間隔: 通常20px / コンパクト16px
```

`NOTIFICATION_RESIZED`でレイアウト区分を再評価し、Tween中にサイズが変わった場合はTweenを止めて最終位置へ揃える。

## 8. テーマ管理

`PowerUpShopVisualStyle`へ色とStyleBox生成を集約する。シーンの各ノードへ色を散在させない。

主要色:

```text
background_top      #292252
background_bottom   #141226
panel_dark          #211B43
card                #F7F3FF
card_subtle         #EDE6FA
detail              #FCF9FF
text_primary        #302846
text_secondary      #746B8D
text_on_dark        #FFF9FF
combat              #FF8FBD
combat_dark         #D9699D
support             #79D9EF
support_dark        #51B8D2
pp                  #FFD767
pp_dark             #E6B93B
warning             #F16F87
disabled            #AAA2BB
```

StyleBox生成ヘルパー:

```text
make_panel_style(fill, border, radius, border_width, shadow)
make_card_style(category, selected, hovered)
make_price_style(state)
make_purchase_button_style(category, state)
make_tab_style(category, selected)
```

背景は`GradientTexture2D`で上部`#292252`、下部`#141226`。装飾は星、吹き出し、ハート、電波、ドットを5～8%の不透明度で画面端にだけ描く。中央のカード背面へ密集させない。

## 9. PowerUpShopCard

### ノード構造

```text
PowerUpShopCard : Button
└── CardMargin : MarginContainer
    └── CardContent : VBoxContainer
        ├── TopRow : HBoxContainer
        │   ├── IconFrame : PanelContainer
        │   │   └── Icon : TextureRect
        │   └── NameLabel : Label
        ├── LevelLabel : Label
        ├── LevelIndicators : HBoxContainer
        ├── CardSpacer : Control
        └── PriceCapsule : PanelContainer
```

Buttonの子は`MOUSE_FILTER_IGNORE`にし、カード全体でクリックとホバーを受ける。`focus_mode = FOCUS_NONE`とし、キーボード／ゲームパッド選択は従来どおりScreenが管理する。

### 状態モデル

選択・購入可否・MAXを単一enumへ押し込まず、独立フラグで扱う。

```text
selected: bool
hovered: bool
level: int
max_level: int
affordable: bool
```

表示優先順位:

1. MAXは価格を`MAX`、5個のランプを点灯
2. PP不足は価格カプセルだけ警告色
3. selectedはカテゴリ色の3～4px枠、弱い発光、1.025倍
4. hoveredはselectedより弱い枠と影

PP不足でもカード本体、名前、アイコンは暗くしない。

### カードクリック

第2版ではカードクリックは選択だけにする。現行の「クリックと同時に購入」は廃止する。

```gdscript
card.pressed -> select_card(index)
purchase_button.pressed -> request_purchase_for_selected()
```

キーボード／ゲームパッドの決定入力は、選択カードを従来どおり購入する。

## 10. アイコン割り当て

第2版初回は既存の透過アイコンを仮利用し、`data/power_up_shop.json`の既存`iconPath`だけを埋める。価格・効果・保存スキーマは変えない。

| Upgrade ID | 仮アイコン |
| --- | --- |
| `max_hp` | `res://assets/generated/equipment_icons_v1/icons/mental_care.png` |
| `attack_power` | `res://assets/generated/equipment_icons_v1/icons/stream_power.png` |
| `move_speed` | `res://assets/generated/equipment_icons_v1/icons/light_sneakers.png` |
| `damage_reduction` | `res://assets/generated/equipment_icons_v1/icons/mic_barrier.png` |
| `exp_gain` | `res://assets/generated/equipment_icons_v1/icons/high_speed_connection.png` |
| `pickup_range` | `res://assets/generated/equipment_icons_v1/icons/comment_radar.png` |
| `healing_power` | `res://assets/generated/relay_break_v1/icon_heal.png` |
| `gift_luck` | `res://assets/generated/relay_break_v1/icon_gift.png` |

PPアイコンは`res://assets/generated/gameplay_event_objects_v1/coin.png`を仮利用する。専用素材が追加された場合はJSONパスの差し替えだけで更新可能にする。

## 11. 詳細表示

### 通常強化

Lv0の現在値は`効果なし`とする。Lv1以降は強化IDごとの文言で表示する。

| ID | 表示例 |
| --- | --- |
| `max_hp` | `最大メンタル +4%` |
| `attack_power` | `与ダメージ +3%` |
| `move_speed` | `移動速度 +2%` |
| `damage_reduction` | `被ダメージ -2%` |
| `exp_gain` | `獲得経験値 +4%` |
| `pickup_range` | `回収範囲 +6%` |
| `healing_power` | `対象回復量 +5%` |

現在値と購入後値は別のPanelContainerへ入れ、購入後値だけ金色の枠と数値を使う。Lv5ではNextBoxを`強化完了 / MAX`にする。

### ギフト祈願

`gift_luck`を通常の百分率で表示しない。DBの`giftLuck`配列から表示する。

```text
現在: 当たり x1.08 / 大当たり x1.12
購入後: 当たり x1.16 / 大当たり x1.24
```

Lv0は`補正なし`、Lv5は購入後欄を`MAX`とする。

## 12. 購入ボタン

購入ボタンは詳細パネル最下部へ常設する。状態は次の3種。

```text
AVAILABLE
  パワーアップする
  120 PP

NOT_ENOUGH_PP
  PPが足りません
  あと 40 PP

MAX
  強化完了！
  MAX
```

NOT_ENOUGH_PPとMAXもボタンを非表示にしない。MAXはクリック・決定を無視し、エラーSEを鳴らさない。PP不足はManagerを呼んでもよいが、画面側で不足演出の0.5秒クールダウンを守る。

購入ボタンへキーボードフォーカスを移す手順は追加しない。

## 13. 入力源とフォーカス

`last_input_source`を`navigation`または`pointer`で保持する。

- キー／ゲームパッド入力時: navigation
- 3px以上のマウス移動またはクリック時: pointer
- マウスホバーで選択インデックスを勝手に変更しない
- マウスクリックで選択を確定する
- navigation中はselected枠を優先
- pointer中はhover枠を追加するが、selected状態は維持

ネイティブButtonの`pressed`、`mouse_entered`、`mouse_exited`を使い、固定Rectによる手動マウス判定を廃止する。

## 14. アニメーションとSE

Tweenは画面・カード単位で保持し、新しい演出開始前と画面クローズ時に既存Tweenをkillする。画面再表示時に途中状態を残さない。

### 画面表示

```text
0.00～0.18秒: 背景フェード
0.08～0.30秒: ヘッダーとタブ
0.14～0.46秒: カードを行単位で表示
0.22～0.52秒: 詳細とフッター
```

### カテゴリ切替

0.2秒のUIロックを設け、旧カードを12px移動＋フェード、新カードを逆側から表示する。Manager操作は行わない。

### 購入成功

`upgrade_purchased`で次を実行する。

- 対象カードだけランプを1つ点灯
- アイコンを最大1.08倍まで跳ねさせる
- 6～10個の小さな星粒
- PP数字を0.25秒で旧値から新値へ更新
- 詳細を新Lvへ更新
- `confirm_select.mp3`

画面側に0.35秒の演出入力ロックを設ける。Managerの`busy`を変更しない。

### PP不足

`purchase_failed(NOT_ENOUGH_POINTS)`で次を実行する。

- 購入ボタンを左右8px、2往復以内で揺らす
- PPカプセル枠を警告色で最大2回点滅
- `PPが足りません`トーストを1秒
- 0.5秒通知クールダウン
- 仮エラーSEとして`back_transition.mp3`を小さめに再生

### MAX到達

Lv4からLv5だけ、黄色ランプ、星粒、`MAX!`を0.8秒、大型アイコン1.08倍、`level_up.mp3`を使う。全画面フラッシュは使わない。

### リセット

`upgrades_reset(refund)`でカードランプを左から短く消灯し、PPを旧値から新値へ0.6秒で更新する。Managerは既存処理のまま。

## 15. Managerシグナルとの接続

表示更新は次の一方向フローにする。

```text
ユーザー入力
  -> manager.purchase_upgrade / reset_all_upgrades
  -> Managerが保存成功
  -> signal
  -> Screenが表示更新と演出
```

保存前にLvやPPを先行表示しない。`SAVE_FAILED`ではカード値を変えず、保存失敗トーストだけ表示する。

リセット時はManagerが`points_changed`を発火しなくても、`upgrades_reset(refund)`と現在残高からPPカウント演出を構成できるため、Manager変更は不要。

## 16. リセット確認

DialogLayerはFull Rectの半透明入力遮断面と中央ダイアログで構成する。実Buttonを使い、絶対座標のクリック判定を廃止する。

- 初期選択はキャンセル
- 戻る入力は閉じる
- リセット対象が0の場合はダイアログを開かず`リセット対象がありません`
- リセットボタンは透明～濃紫の枠線型
- 通常時は購入ボタンより彩度、面積、発光を弱くする

## 17. 実装順

1. 第1版実装の安定化と通常メインシーン復元を完了する
2. `UiBuilderSystem`から`uiRoot`を返し、ショップをCanvasLayerへ移す
3. 新しいTSCN階層とVisualStyleを作る
4. Cardコンポーネントを作り、4枚をDBから構築する
5. 詳細パネルと常設購入ボタンを接続する
6. ネイティブButtonへマウス操作を移す
7. 通常／コンパクトのレスポンシブ寸法を実装する
8. iconPathを仮素材へ接続する
9. 選択、購入、PP不足、MAX、リセット演出を追加する
10. 既存ロジックテストと第2版UIテストを1回の検証バッチで実行する

## 18. テスト設計

### ロジック回帰

既存`test_power_up_shop`で次が変わっていないことを確認する。

- 価格、効果値、報酬額
- 購入と残高
- 保存失敗ロールバック
- リセット全額返還
- 重複報酬防止
- ON/OFFとスナップショット

### UI自動テスト

Fake／一時Storeを使い、ユーザーセーブへ書き込まない。

- 1280x720、1600x900、1920x1080、2560x1440で背景RectがRoot Rectと一致
- ShopContentがSafeArea内かつ幅1360以下
- Footer、PurchaseButton、DetailPanelが画面内
- 4カードが2列x2行
- カードクリックは選択だけでPPを減らさない
- PurchaseButtonクリックは1回だけ購入
- PP不足、MAX、選択、未選択の文言と状態
- `gift_luck`が百分率表示にならない
- カテゴリ切替後に選択カードと詳細が一致
- close/open後にTween、Toast、Dialogが残らない

### 視覚確認

可能なら専用のcapture scene 1プロセス内で4解像度を順番に描画し、PNGを確認する。確認項目:

- 白い右・下余白がない
- 長い強化名、説明、PP桁数が重ならない
- 選択カードが濃色塗りつぶしになっていない
- 購入ボタンが常に見える
- リセットが購入ボタンより目立たない
- 背景装飾がカード背面をうるさくしない

現在Godot 4.6.3のheadless反復でネイティブクラッシュが確認されているため、編集途中にGodotを連打しない。静的確認、JSON、`git diff --check`を先に完了し、Godot検証はファイルが安定した後の1回のバッチへ集約する。signal 11が出た場合は同じテストを再実行せず、コマンドとログを報告する。

## 19. 受け入れ条件

- ショップが既存CanvasLayer上で全面表示される
- 1280x720～2560x1440で白い未使用領域がない
- コンテンツが中央寄せされ、1920px以上でも幅1360pxを超えない
- 8カードすべてにアイコンが表示される
- 戦闘はピンク、サポートは水色を色・文字・アイコンで区別できる
- 明色カード上で文字が読める
- 選択は枠、発光、拡大で示し、濃色塗りつぶしを使わない
- PP不足は価格と文言で分かり、カード内容は暗くならない
- 詳細に現在値、購入後値、必要PP、常設購入ボタンがある
- カードクリックは選択、購入ボタンは購入として分離される
- キーボード／ゲームパッドの従来購入操作は維持される
- MAXで購入処理とエラー音を発生させない
- リセットは購入より弱い見た目で、確認ダイアログを経由する
- 既存の購入、保存、リセット、報酬、強化効果へ回帰がない
- 画面再表示後に演出の中間状態が残らない

