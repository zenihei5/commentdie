# パワーアップショップ第5版 不具合監査・修正指示

## 1. 監査結果

第5版の大崩れは、主に見た目用Tweenを`Container`管理下のルートControlへ直接適用していることが原因。

### A. 選択・ホバーしたカードが左上へ飛ぶ

`scripts/ui/power_up_shop_card.gd::_apply_selection_transform()`は、カードの現在位置ではなく絶対座標を移動先にしている。

```gdscript
var target_position := Vector2(8, 0) if selected else Vector2.ZERO
```

カードは`GridContainer`の子なので、2列目や下段のカードも選択時に`(8, 0)`へ移動する。未選択化・ホバー解除では`(0, 0)`へ移動するため、複数カードが左上へ重なる。`scale`も左上原点のルートへ適用され、隣接カードへ不自然に張り出す。

**修正方針**

- `GridContainer`直下のカードルートは、位置・サイズ・scaleを常にコンテナへ任せる。
- カード内に`VisualRoot`（または固定サイズSlot配下のCardSurface）を追加し、選択`+8px / 1.04`とホバー`1.01`はその内部表示ノードだけへ適用する。
- `VisualRoot.pivot_offset = VisualRoot.size * 0.5`をレイアウト後に設定する。
- 選択解除時は`VisualRoot.position = base_visual_position`、`VisualRoot.scale = Vector2.ONE`へ戻す。ルートカードを`Vector2.ZERO`へ移動しない。
- カテゴリ切替、購入後更新、画面再表示、Tween中断後も、カードルートの`position`がGridの割当位置から変わらないこと。

### B. マスコット吹き出しが情報面の外へ飛び出す

`SpeechBubble`は右上アンカーのまま、`offset_top = -132`、`offset_bottom = -72`になっている。親の上端より上へ配置され、Hero面へ重なるか画面外へ出る。

**修正方針**

- `SpeechBubble`を右下基準へ変更し、`anchor_top = 1.0`、`anchor_bottom = 1.0`を設定する。
- マスコット左上に収め、1280x720と1600x900の両方で比較欄・価格・購入ボタンへ重ならないoffsetを設定する。
- 吹き出し幅はcompact 160～180px、通常170～220px、高さ45～76pxを守る。

### C. 1280x720でBody最小幅が17px以上はみ出す

compact時は`CardSection 580 + DetailPanel 605 + separation 28 = 1213px`だが、カード1枚の最小幅が300pxなのでGridの実最小幅は`300 * 2 + 16 = 616px`。実際のBody最小幅は`616 + 605 + 28 = 1249px`となり、content幅1232pxを超える。選択拡大も加わり、端切れや重なりが起きる。

**修正方針**

- compactカード幅を272～282pxへ下げるか、compact時にカードの最小幅を動的設定する。
- 1280x720で`Body.size.x <= ShopContent.size.x`、GridとDetailPanelの矩形が交差しないことを幾何テストで確認する。
- 文字、価格、5ランプが収まるよう、カード内余白とフォントをcompact時だけ調整する。

### D. HeroPatternが空ノードで何も描画しない

`HeroPattern`はscriptもtextureもなく、`modulate`だけ更新しているため常に空表示。第5版で要求したcombat/support固有のHero模様が出ない。

**修正方針**

- Hero専用の軽量描画スクリプトを割り当てるか、既存のRoomDecoration描画をmode付きで再利用する。
- combatは衝撃線・火花・上向き矢印、supportはコメント・星・リング・電波を8～16% alphaで表示する。
- 本文とアイコンより背面に置く。

### E. テストが壊れた座標変更を正解として固定している

現テストは`selected card position.x >= 7`を確認するだけで、Grid内の本来位置を保持しているかを見ていない。このため2列目・下段が左上へ飛ぶ実装を検出できない。

**修正方針**

- 旧assertを削除し、ルートカードのGrid位置不変を検証する。
- 4枚それぞれを順に選択・ホバーし、全ルート矩形が互いに不正重複しないことを確認する。
- 表示用内部ノードだけが`+8px / 1.04`になることを確認する。
- 吹き出し、マスコット、比較欄、購入ボタンの矩形交差テストを1280x720と1600x900で追加する。

## 2. 回帰条件

- 価格、強化効果、PP、保存、リセット、8カード常駐、入力遷移は変更しない。
- カード決定は購入、マウスクリックは選択、購入ボタンは購入という既存契約を維持する。
- 選択カードの強調はタブ・フッターへフォーカスを移しても残す。
- カテゴリ切替後も各カテゴリの最後の選択位置を復元する。
- 購入演出中に閉じた場合、Tweenと一時表示を残さない。

## 3. 検証手順

1. JSON整合、GDScript/TSCNパース、`git diff --check`。
2. `scripts/tests/test_power_up_shop_screen_v2.tscn`を実行。
3. 1280x720、1600x900、1920x1080、2560x1440でcombat/supportを撮影。
4. 各解像度で4カードを順番に選択・ホバーし、左上への飛び・カード重なり・端切れがないことを確認。
5. PP不足、購入成功、MAX、リセット確認、閉じて再表示を確認。

Godot GUIが既に動作中なら、別のGodotプロセスを起動しない。現在のプロセスが終了してから、テストと撮影を1プロセスへまとめて実行する。

