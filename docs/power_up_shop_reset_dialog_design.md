# パワーアップショップ 全強化リセット確認ダイアログ 現行コード向け設計

## 1. 方針

- 対象は `scripts/ui/power_up_shop_screen.tscn` と `scripts/ui/power_up_shop_screen.gd` を中心とする。
- PP返還額は既存の `PowerUpShopManager.calculate_refund_points()` を唯一の計算元とする。
- PP返還、全Lv0化、`totalSpentPoints` の初期化、保存は、既存の `PowerUpShopManager.reset_all_upgrades()` に集約された原子的処理を維持する。
- UIからPP加算とレベル変更を個別に呼ばない。新しい価格表や返還額のハードコードも作らない。
- 強化項目、価格、効果、セーブ形式、ショップ遷移は変更しない。

## 2. 現状との差分

現行モーダルは `ResetDialog/Content` に見出し、1行説明、2ボタンだけがあり、幅560px・高さ292pxである。これを620x390px基準の情報ダイアログへ変更する。

追加する表示:

- `全強化をリセットしますか？`
- `購入したすべての強化がLv0に戻ります。`
- `強化に使用したPPは、すべて返還されます。`
- PPアイコン付きの返還予定額
- 所持PPの変更前、矢印、変更後
- `全強化をリセット` と `キャンセル` の同寸ボタン

## 3. ノード構造

既存の `DialogLayer` を維持し、`ResetDialog` 以下を次の構造へ整理する。

```text
DialogLayer
├── Dim
└── ResetDialog (PanelContainer, 620x390)
    └── ContentMargin (MarginContainer)
        └── Content (VBoxContainer)
            ├── Title
            ├── Description (RichTextLabel推奨)
            ├── RefundPanel (PanelContainer)
            │   └── RefundMargin
            │       └── RefundRows
            │           ├── RefundRow
            │           │   ├── PpIcon (30x30)
            │           │   ├── RefundCaption
            │           │   └── RefundAmount
            │           └── BalanceRow
            │               ├── BalanceCaption
            │               ├── BalanceBefore
            │               ├── BalanceArrow
            │               └── BalanceAfter
            └── Buttons
                ├── Confirm
                └── Cancel
```

既存のボタンノード名 `Confirm` / `Cancel` は維持する。PPアイコンは既存の `res://assets/generated/gameplay_event_objects_v1/coin.png` を再利用する。

## 4. レイアウトとスタイル

- 1600x900基準で620x390px、画面中央。1280x720でも画面内へ収める。
- 内側余白は左右38px、上34px、下32pxを初期値とする。
- 見出しは26～28px、太字、`#3F2C4E`、中央揃え。
- 説明は17px、`#765F78`、中央揃え、2行。RichTextLabel使用時は「すべて返還されます」だけ `#E55D95` の太字にする。
- 返還パネルは背景 `#FFF8D9`、枠 `#EFCB47` 2px、角丸16px。
- 返還額は24～26px・`#C78A18`、所持PP変更後は20～22px・太字・`#C78A18`。
- 実行ボタンは既存のリセットテーマ、キャンセルは既存の戻るボタンテーマを再利用する。
- 両ボタンは同じ幅（240～260px）・高さ56px、間隔16px。
- `Dim` は `#241B35`、最終アルファ0.62を基準とする。

## 5. 表示データ

専用クラスは増やさず、画面内のDictionaryで十分である。

```gdscript
func _create_reset_confirmation_view_data() -> Dictionary:
    var current := manager.current_points()
    var refund := manager.calculate_refund_points()
    return {
        "currentPoints": current,
        "refundPoints": refund,
        "pointsAfterReset": current + refund,
        "purchasedLevelCount": manager.total_upgrade_level(),
    }
```

- 表示時にこのスナップショットを生成する。
- `totalSpentPoints` は表示・返還の計算元にしない。現在レベルと購入時と同じ `prices` が正とする。
- `_format_point_amount(value)` を画面内の共通関数として追加し、返還額、前後残高、右上所持PPのすべてで3桁区切りを使用する。
- 不正な負値は表示前に0へ丸める。int64加算の上限を超える可能性がある場合は実行を中止し、不整合扱いにする。ゲーム上の任意のPP上限は新設しない。

## 6. ダイアログを開く処理

`_show_reset_dialog()` の先頭で次を判定する。

1. 購入・遷移・リセット実行ロック中なら無視する。
2. `manager.total_upgrade_level() <= 0` ならダイアログを開かず、軽い無効SEと `リセットできる強化がありません` のトーストを1.5秒表示する。保存は行わない。
3. レベル合計が1以上なのに `calculate_refund_points() <= 0` なら不整合として開かず、`PP返還額を取得できませんでした` を表示し、開発ログへ各ID・Lv・pricesを出す。
4. 正常ならラベルへ値を反映し、`dialog_choice = CANCEL`、`focus_area = RESET_DIALOG` とする。

背景操作は既存どおり `DialogLayer` で遮断する。モーダル外クリックでは閉じない。

## 7. 入力

- 初期フォーカスはキャンセル。
- 左/Aで実行、右/Dでキャンセル。
- Enter/Z/ゲームパッド決定で選択中のボタンを実行。
- Esc/X/ゲームパッドキャンセルで閉じる。
- マウスクリックは既存の `pressed` 経路へ合流させる。
- モーダル表示中はカテゴリ、カード、購入、戻る、リセット再押下へ入力を通さない。
- `reset_execution_locked` と `reset_dialog_animation_locked` を設け、連打、キーボードとマウスの同時入力、開閉アニメーション中の再入力を遮断する。

## 8. 開閉アニメーション

- 表示: 暗幕0→0.62を0.18秒、ダイアログをalpha 0→1、scale 0.94→1.02→1.0で合計0.24秒。
- 非表示: alpha 1→0、scale 1.0→0.97で0.18秒。その後に `hide()`。
- `pivot_offset = size * 0.5` をレイアウト確定後に設定し、拡縮で中央位置をずらさない。
- 開閉Tweenは専用参照を持ち、再利用前にkillする。

## 9. リセット実行

`_on_reset_confirmed()` はダイアログを先に閉じない。

```text
入力ロック
→ total levelと返還額を再計算
→ 0件/不整合を再判定
→ manager.reset_all_upgrades() を1回だけ呼ぶ
→ SUCCESS時だけ閉じる・全UI更新・成功演出
→ SAVE_FAILED/BUSY時はレベルとPPを変えず、ダイアログを残して通知
```

- 実行直前の返還額と、成功シグナル `upgrades_reset(refunded_points)` の実額を比較できるようにする。
- 成功後のトーストは `全強化をリセットし、1,200 PPを返還しました` とし、シグナルの `refunded_points` を表示する。
- `reset_all_upgrades()` は既にcandidate作成→保存成功時だけprofile反映の順なので、UI側で処理を分割しない。
- `SAVE_FAILED` 時はモーダルを閉じず、再試行またはキャンセル可能に戻す。

## 10. 成功時更新と演出

成功シグナルを受けた `_on_reset(refund)` で次を行う。

- モーダルを閉じ、フォーカスをフッターの全強化リセットへ戻す。
- `_refresh_view()` を1回呼び、所持PP、0/40、カードLv、ランプ、価格、VisualTier、詳細、購入ボタン、マスコットを更新する。
- リセット前のレベルスナップショットを保持し、各カードへ短い消灯・縮小復帰演出を順番に出す。合計0.45～0.8秒に収め、操作停止は必要最小限にする。
- 右上PPカプセルを1.08倍→1.0倍、コインを1～2個だけ光らせる。
- マスコット吹き出しは `PPが戻ってきたよ！`。購入成功より控えめに小さく跳ねる。

カードの厳密な逐次消灯が既存構造で難しい場合も、全カードのLv0表示・ランプ消灯・VisualTier更新は同一フレームで必ず完了させ、その上へカード単位の短い順次パルスを重ねる。表示を古いレベルへ戻す演出は行わない。

## 11. テスト

`scripts/tests/test_power_up_shop.gd`:

- 1項目Lv1、Lv5、複数項目混在、全項目Lv5で `calculate_refund_points()` がprices累積と一致。
- `reset_all_upgrades()` 成功で全Lv0、PP全額返還、`totalSpentPoints = 0`。
- 保存失敗でprofile全体が不変。
- 二重呼び出しの2回目は `NOTHING_TO_RESET` で追加返還なし。
- レベル1以上・価格不整合時はPPなしでレベルだけ0にしない。

`scripts/tests/test_power_up_shop_screen_v2.gd`:

- ダイアログ文言、返還額、前後残高、桁区切り。
- 初期選択がキャンセル、左右移動、決定・キャンセル。
- 全Lv0ではダイアログを開かずトーストだけ。
- モーダル中の背面入力無効。
- 実行連打・マウス同時入力でmanager呼び出しが1回。
- 成功後に全カード、詳細、総Lv、PP、マスコットが更新。
- SAVE_FAILEDで表示値とmanager profileが変わらない。
- 1280x720、1600x900、1920x1080、2560x1440でダイアログが画面内に収まり、ラベルとボタンが重ならない。

## 12. 変更対象

必須:

- `scripts/ui/power_up_shop_screen.tscn`
- `scripts/ui/power_up_shop_screen.gd`
- `scripts/tests/test_power_up_shop.gd`
- `scripts/tests/test_power_up_shop_screen_v2.gd`

必要な場合のみ:

- `scripts/ui/power_up_shop_card.gd`（カードのリセット成功演出）
- `scripts/systems/power_up_shop_manager.gd`（不整合・int64上限の防御をmanagerでも保証する場合）

既存のdirty差分を戻さず、Godot PID 4088が起動中なら別のGodotプロセスは起動しない。
