# パワーアップショップ画面遷移 共通化設計

## 1. 検証結果

現在のショップ遷移は、既存の前画面共通遷移へ接続されていない。

- `game.gd`の共通遷移は、退場0.10秒、登場0.14秒、合計0.24秒。
- 前進時は旧画面が左へ42px退場し、新画面が右52pxから登場する。
- 戻る時は旧画面が右へ42px退場し、新画面が左52pxから登場する。
- 中間へ向けて白い幕が最大alpha 0.70まで濃くなり、その後消える。
- 登場側はCubic Out、退場側は既存式の線形進行。
- 遷移中はGame側で入力を遮断する。

一方、ショップは`power_up_shop_screen.gd`内で別の0.24秒Tweenを実行している。

- 旧画面の退場がない。
- 白い幕の遷移がない。
- 背景画像と`BackgroundWash`は固定され、SafeAreaと一部装飾だけが動く。
- 入退場とも52px、Quad Outで、共通値と異なる。
- 既存の段階フェードが同時再生され、全要素の表示完了が約0.44秒になる。
- ショップからタイトルへ戻る際、`_prepare_back_to_title(true)`へ進み、タイトル初回登場演出が再生される。
- 戻るSEが共通経路から再生されない。

したがって、ショップ独自Tweenの数値調整ではなく、共通遷移進行への統合が必要。

## 2. 基本方針

`game.gd`の`front_screen_transition_*`を唯一の進行時計とする。

ショップはCanvasLayer上の独立Controlであるため、Gameの`draw_set_transform()`では直接描画できない。そこで、共通タイムラインから算出したフレーム情報をショップへ渡す「外部画面アダプタ」を追加する。

- 時間、方向、距離、イージング、白幕alphaはGame側で一度だけ計算する。
- 通常のタイトル、ランキング、オプション等は従来どおりGame描画を使う。
- `power_up_shop`がfrom/toに含まれる時だけ、ショップControlへ同じフレーム情報を適用する。
- ショップ側でナビゲーション用Tweenを生成しない。

## 3. 共通フレームデータ

既存の`_draw_front_screen_transition_overlay()`内の計算を、副作用のない共通関数へ抽出する。

例：

```gdscript
func _front_screen_transition_frame() -> Dictionary:
    return {
        "outgoingProgress": outgoing_progress,
        "incomingProgress": incoming_progress,
        "incomingEased": incoming_eased,
        "overlayAlpha": overlay_alpha,
        "outgoingOffsetX": outgoing_offset_x,
        "incomingOffsetX": incoming_offset_x,
        "atMidpoint": incoming_progress > 0.0,
    }
```

### 3.1 既存の白幕タイミングを保持する

位置移動は退場0.10秒、登場0.14秒だが、白幕alphaは既存画面で使われている次の式を変更せずフレームデータへ移す。

```gdscript
overlay_alpha = FRONT_SCREEN_TRANSITION_OVERLAY_MAX_ALPHA * minf(
    clampf(front_screen_transition_elapsed / 0.08, 0.0, 1.0),
    clampf((_front_screen_transition_total_duration() - front_screen_transition_elapsed) / 0.12, 0.0, 1.0)
)
```

したがって白幕は0.08秒で最大alpha 0.70へ達し、終端0.12秒でフェードアウトする。以下のタイムラインにある「0.00-0.10で0から0.70」「0.10-0.24で0.70から0」は段階説明の簡略表現であり、実装値は必ず上式を使う。ランキング、オプションなど既存フロント画面の見え方を変更しない。

既存描画とショップアダプタの両方がこの値を使う。ショップ側へ同じ定数を複製しない。

## 4. ショップ側アダプタ

### 4.1 移動対象

共通遷移では画面全体が移動するため、ショップでも以下をすべて同じXオフセットで動かす。

- `FullScreenBackground`
- `BackgroundWash`
- `BackgroundDecoration`
- `SafeAreaMargin`
- 表示中なら`DialogLayer`と`ToastLayer`

これらを`TransitionVisualRoot`へまとめるか、トップレベル表示ノード一覧へ同じoffsetを適用する。背景を固定したままにしない。

白幕は移動対象の外側に、全画面固定の`TransitionVeil`として置く。初期状態は非表示、`mouse_filter = IGNORE`。

### 4.2 API案

名称は既存構造に合わせて変更してよい。

```gdscript
func begin_common_front_transition(role: String) -> void
func apply_common_front_transition(offset_x: float, overlay_alpha: float, should_show: bool) -> void
func finish_common_front_transition(keep_open: bool) -> void
func request_common_close() -> void
```

- `role`は`incoming`または`outgoing`。
- `begin`で基準位置を保存し、入力をロックする。
- `apply`はTweenを作らず、そのフレームの位置・白幕alpha・表示状態を直接反映する。
- `finish`で全位置を基準へ戻し、白幕を消す。
- 退場完了時はシグナルを再送せず、Game側から明示的に画面を閉じる。

## 5. タイトルからショップへの遷移

```text
0.00-0.10秒
タイトルを左へ42px退場
白幕 0 -> 0.70
ショップは非表示

0.10秒
ショップを表示
ショップ全画面を右52pxへ配置
ショップ内TransitionVeilをalpha 0.70で表示

0.10-0.24秒
ショップ全画面を右52px -> 0pxへCubic Out
TransitionVeilを0.70 -> 0へ

0.24秒
基準位置へ確定
白幕非表示
入力ロック解除
```

タイトルの決定SEは既存どおり1回だけ再生する。

ショップの既存`_animate_show()`による段階フェードは、共通画面遷移から開く場合は無効化し、header/tabs/body/footerを開始時から`Color.WHITE`にする。デバッグや単体テスト向けの即時`open_shop()`では既存表示演出を残してもよい。

## 6. ショップからタイトルへの遷移

```text
0.00秒
戻るSEを1回再生
ショップ入力をロック

0.00-0.10秒
ショップ全画面を右へ42px退場
ショップ内TransitionVeilを0 -> 0.70

0.10秒
ショップを非表示
タイトルを遷移用状態で準備

0.10-0.24秒
タイトルを左52px -> 0pxへCubic Out
Game側白幕を0.70 -> 0へ

0.24秒
入力ロック解除
```

タイトル準備には必ず`_prepare_back_to_title(false)`相当を使用する。ロゴ落下、キャラ登場など初回タイトル演出を再生しない。

戻る操作は、ショップが自分で0.24秒Tweenを完了してから`closed`を送る構造にしない。ショップから`close_requested(origin)`を送り、Gameが共通遷移を開始・完了させる。

## 7. Game側の接続

- `power_up_shop`を共通前画面遷移の有効なendpointとして扱う。
- `_draw_front_screen_overlay_for_state("power_up_shop")`は描画しない。独立Control側のアダプタが担当する。
- `_update_front_screen_transition()`中に、from/toが`power_up_shop`なら共通フレームをショップへ適用する。
- 遷移開始直後、最初の描画より前にショップの表示状態を正しく設定する。
- 遷移終了時に、入場なら表示・位置を確定し、退場なら非表示・一時状態を破棄する。
- `_unhandled_input()`の既存`front_screen_transition_active`ロックに加え、ショップの`_input()`でもアダプタ動作中は入力を消費する。
- 途中キャンセル、画面破棄、直接close時に位置・白幕・入力ロックを必ず復元する。

## 8. result起点

現在の`origin == "result"`経路と、終了後に`stream_frame_select`へ進む仕様は変更しない。

第一段階ではタイトルとショップ間を共通化対象とする。result起点へ同じ演出を適用する場合は、`result`を無条件に全前画面遷移へ追加せず、結果画面固有の状態を保持した専用endpointとして接続する。今回の修正で結果画面の進行を巻き込まないこと。

## 9. 削除・禁止事項

- `power_up_shop_screen.gd`の`SCREEN_TRANSITION_DURATION`と`SCREEN_TRANSITION_SLIDE`を共通値として残さない。
- 画面遷移用`_screen_transition_tween`を残さない。
- 共通遷移中にショップの段階フェードを重ねない。
- 背景を固定し、SafeAreaだけを動かさない。
- 退場完了後に`_prepare_back_to_title(true)`を呼ばない。
- 戻るSEをショップとGameの両方で二重再生しない。

## 10. 回帰テスト

最低限、以下を自動テストへ追加する。

1. タイトルからショップを開くと`front_screen_transition_active == true`になる。
2. 0.05秒時点ではショップ非表示、旧タイトルが退場中。
3. 0.10秒直後にショップが右52px、白幕alpha約0.70で表示される。
4. 0.24秒後にショップ位置0、白幕非表示、入力可能になる。
5. ショップから戻る0.05秒時点で、ショップが右へ約21px移動する。
6. 中間点でショップが隠れ、タイトルが左52pxから登場する。
7. 戻り完了後、タイトルロゴ・キャラの初回登場タイマーが0である。
8. 戻るSEは1回だけ再生される。
9. 共通遷移中、ショップのカード購入・戻る・カテゴリ変更が発火しない。
10. 軽減設定では合計0.12秒、移動量0pxになる。
11. 直接`open_shop()` / `close_shop(false)`の単体テスト互換を維持する。
12. result起点の開閉先とPP処理を変更しない。

## 11. 受け入れ条件

- タイトル、ランキング、オプションと同じ二段階タイムラインに見える。
- 前画面退場、白幕、次画面登場の3要素がすべて存在する。
- ショップ背景、白い背景幕、装飾、UI本体が一体で移動する。
- ショップだけ表示完了が0.44秒へ延びない。
- ショップから戻ってもタイトル初回登場演出が再生されない。
- 入力、SE、軽減設定、異常終了時の後始末が共通画面と一致する。
- 遷移値の定数・計算はGame側に一元化されている。
