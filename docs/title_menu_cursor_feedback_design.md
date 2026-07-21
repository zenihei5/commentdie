# タイトル画面 カーソル・押し込みフィードバック実装設計

## 1. 目的

現在の太い黄色い選択枠を、タイトルボタン自身の色・外枠と競合しない選択表現へ変更する。
キーボード、ゲームパッド、マウスの全操作で、同じ選択表示と押し込み演出を再生する。

今回の対象:

- 選択中ボタンの浮き上がり
- 選択中ボタンの薄い発光と影
- 左右の小さな三角マーカー
- 非選択ボタンの軽い減光
- 決定時の押し込み・跳ね返り
- 押し込み終了後の既存画面遷移

対象外:

- ボタン画像、5項目の順番、解禁条件の変更
- タイトルロゴやキャラクターの配置変更
- 新しいSEや画像素材の追加
- 各遷移先画面の演出変更

## 2. 現行実装との接続

現行の主な経路:

- 描画: scripts/game.gd の _draw_title_menu_buttons()
- 選択枠: _draw_title_button_selection()
- マウス選択: _update_title_mouse_selection()
- マウス決定: _activate_title_menu_index()
- キーボード／ゲームパッド: StateFlowSystem.front_state_action_for_target()
- 遷移実行: StateFlowSystem.apply_front_action()

現在はマウスとキーボードの決定が別経路で即時実行される。両方とも
_request_title_menu_activation(index, action) へ集約し、押し込み完了後だけ既存処理を実行する。

## 3. 選択中の見た目

既存の太い黄色い二重枠は削除する。

選択中ボタン:

- 基準位置から上へ2px
- 画像スケール1.025
- ボタン色に合わせた薄い影を下へ5px
- ボタン外周へ低透明度の発光
- 左右へ白い三角マーカー
- 三角マーカーの縁色は選択ボタンのテーマ色
- マーカーは0.8秒周期で左右へ最大2pxだけ動く

非選択ボタン:

- スケール1.0
- 位置変更なし
- Color(0.92, 0.92, 0.95, 0.94)程度へ軽く減光
- 影、発光、マーカーなし

未解禁ショップ:

- 既存の未解禁減光を維持する
- 選択中の浮き上がりとマーカーは表示する
- PP非表示、鍵と「未解禁」を維持する
- 未解禁減光と非選択減光を二重に強く掛けすぎない

## 4. テーマ色

    0 ニューゲーム: #ff6ba7
    1 パワーアップショップ: #eeb52f
    2 ランキング: #9b5de5
    3 オプション: #35b9e8
    4 終了する: #ff6f83

テーマ色は影、薄い発光、マーカー外周へ使用する。全面をテーマ色で覆わない。

## 5. 描画レイヤー

選択中の描画順:

1. テーマ色の薄い影
2. テーマ色の低透明度ハロー
3. 変形後のボタン画像
4. ショップのPP／未解禁オーバーレイ
5. 左右の三角マーカー

PP／未解禁表示はボタン画像と同じ変形を受ける。ボタンだけ動いて状態表示が残らないようにする。

## 6. 矩形の責務

入力判定と描画変形を分離する。

    _title_menu_button_rect(index)
        変形前の共通キャンバス描画矩形

    _title_menu_button_visual_rect(index)
        変形前の実ボタン外枠。マウスヒット判定に使用

    _title_menu_button_draw_rect(index)
        浮き上がり／押し込みを反映したキャンバス描画矩形

    _title_menu_button_draw_visual_rect(index)
        変形後の実ボタン外枠。影、発光、マーカー、PP表示に使用

マウスヒット判定は _title_menu_button_visual_rect() のまま固定する。
アニメーションでクリック領域を動かさない。

## 7. 通常選択アニメーション

選択が変わった直後:

    0.00s scale 1.000 / y 0
    0.08s scale 1.030 / y -2
    0.14s scale 1.025 / y -2

通常保持中はボタン自体を連続拡縮しない。常時動かすのは左右マーカーの2px移動だけにする。
文字の読みやすさと画面の落ち着きを優先する。

選択移動SEは既存処理を1回だけ使用する。

## 8. 決定時の押し込み

タイムライン:

    0.00s 確定SE、押し込み開始
    0.06s scale 0.970 / y +4 / 影と発光を弱める
    0.14s scale 1.010 / y 0
    0.14s 既存の決定処理または画面遷移を1回だけ実行

画面遷移開始後は、既存のfront_screen_transitionへそのまま接続する。
押し込み途中に画面遷移を始めない。

## 9. 状態管理

追加候補:

    const TITLE_MENU_FOCUS_ENTER_DURATION := 0.14
    const TITLE_MENU_PRESS_DURATION := 0.14
    const TITLE_MENU_PRESS_DOWN_DURATION := 0.06
    const TITLE_MENU_MARKER_PERIOD := 0.8

    var title_menu_focus_timer := 0.0
    var title_menu_press_timer := 0.0
    var title_menu_press_active := false
    var title_menu_pressed_index := -1
    var title_menu_pending_action := ""

選択index変更時:

- title_menu_focus_timerを0へ戻す
- queue_redraw()
- 押し込み中はindex変更を受け付けない

押し込み中:

- 上下左右、決定、マウスホバーによるindex変更を無視する
- 追加の決定入力を無視する
- タイマー完了時にpending actionを1回だけcommitする
- commit前にactiveを解除し、再入や二重遷移を防ぐ

タイトル以外へ移動した場合:

- press状態、pending action、focus timerをリセットする

## 10. 決定処理の共通化

マウス:

- _activate_title_menu_index() は即時遷移せず、indexから既存action名を取得してrequestする

キーボード／ゲームパッド:

- StateFlowSystemが返した次のactionは、その場でapplyしない
  - start_character_select
  - open_power_up_shop
  - open_title_ranking
  - open_title_options
  - quit_game
- 現在のtitle_menu_indexとactionをrequestへ渡す

commit時:

- StateFlowSystem.apply_front_action()または既存Callableを再利用する
- 確定SEを二重再生しない
- 未解禁ショップも押し込み後に既存_open_power_up_shop()へ渡し、既存トーストを表示する

## 11. 描画API案

    func _title_menu_theme_color(index: int) -> Color
    func _title_menu_feedback(index: int) -> Dictionary
    func _title_menu_button_draw_rect(index: int) -> Rect2
    func _title_menu_button_draw_visual_rect(index: int) -> Rect2
    func _draw_title_menu_focus_feedback(index: int) -> void
    func _draw_title_menu_side_markers(rect: Rect2, color: Color, offset: float) -> void
    func _request_title_menu_activation(index: int, action: String) -> void
    func _update_title_menu_feedback(delta: float) -> void
    func _commit_title_menu_activation() -> void

_title_menu_feedback() はscale、offsetY、shadowAlpha、glowAlpha、markerOffsetを返す純粋な計算関数にする。
描画とテストで同じ計算結果を利用する。

## 12. 三角マーカー

新規画像は使わずCanvas描画でよい。

- 左マーカーは右向き
- 右マーカーは左向き
- 実ボタン外枠から12～16px外側
- 一辺10～12px程度
- 白塗り、テーマ色2～3px縁取り
- ボタン文字やキャラクターへ重ならない
- mouse_filter相当の入力対象にはしない

## 13. 入力とSE

- カーソル移動SEは選択indexが変わった時だけ
- 確定SEは押し込み開始時に1回
- 押し込み完了時に確定SEを再生しない
- マウスクリック、Enter、ゲームパッド決定で同一タイムライン
- 押し込み中の連打で複数遷移しない

## 14. テスト

追加または更新するテスト:

- 選択中はscale 1.025、y -2へ収束する
- 非選択はscale 1.0、offset 0である
- press 0.06秒時点でscale 0.970、y +4になる
- press完了時にpending actionが1回だけcommitされる
- press中の追加決定とindex変更を無視する
- マウスヒット矩形がアニメーションで変化しない
- PP／未解禁表示が変形後矩形へ追従する
- 5項目すべてで同じ押し込みを使用する
- 未解禁ショップは押し込み後もタイトルに留まり、既存トーストが出る
- 既存の上下循環、ショートカット、画面遷移を維持する
- 旧黄色二重枠を描画しない
- 1600 x 900でマーカーと選択拡大が隣接ボタンへ重ならない
- git diff --checkを通す

Godotエディタが起動中の場合、新しいGodotプロセスは起動しない。実行できないランタイム確認は完了報告へ明記する。

## 15. 受け入れ条件

- 選択中ボタンが自然に浮き上がって見える
- 太い黄色い全周カーソルが表示されない
- 左右マーカーで選択位置が一目で分かる
- 非選択ボタンが過度に暗くならない
- 決定時に押し込まれてから遷移する
- マウス、キーボード、ゲームパッドで演出差がない
- 連打しても二重遷移しない
- PP、未解禁、クリック判定、既存SE、既存遷移に回帰がない
