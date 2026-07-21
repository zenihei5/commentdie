# クリア画面 第2版 PP報酬統合 実装設計

## 1. 適用範囲

- 対象は `endType == "completed"` の完走画面。
- `mental_breakdown` の敗北画面、ランク計算、ランキング登録、PP基礎報酬、セーブ形式、画面遷移先は変更しない。
- 内部の `kamiPoint` はランク計算用に保持するが、完走画面では表示しない。
- 既存のカスタム描画方式と1600x900の仮想キャンバスを維持する。新しいControlシーンへ全面移行しない。

## 2. 現行実装の確認結果

- 完走結果は `scripts/systems/result_system.gd::complete_run_for_target()` で確定する。
- PPは同関数内の `_commit_power_up_reward()` から、画面表示前に正式付与・保存されている。
- `PowerUpShopManager.grant_reward()` は `rewardedRunIds` と報酬キーで二重付与を防いでいる。
- `last_result_data` には現在、付与後残高 `streamPointBalance` と報酬辞書はあるが、付与前残高がない。
- `scripts/game.gd::_draw_result_clear_rank_panel()` に `%d pt` の表示が残っている。
- 完走時の中央列はハイライト、最終ビルド、ランキングの3ブロックで、PP内訳は未実装。
- ショップは入力矩形を持ち、`_draw_result_overlay()` の末尾で `PP SHOP` として個別描画されている。
- 既存の0.48秒ドロップ演出中は入力が遮断されている。

## 3. データ境界

辞書ベースの既存設計に合わせ、第一版では新しいResourceクラスを増やさず、`resultData` に次の表示専用辞書を追加する。

```gdscript
"pointRewardView": {
    "grantState": "granted",
    "pointsBefore": 52,
    "pointsEarned": 225,
    "pointsAfter": 277,
    "rewardRows": [
        {
            "id": "participation",
            "displayName": "参加報酬",
            "amount": 5,
            "isOneTimeBonus": false
        }
    ]
}
```

### 3.1 残高の確定

`_commit_power_up_reward()` で `grant_reward()` を呼ぶ直前に `before_balance = manager.current_points()` を記録する。返却値へ次を追加する。

```text
beforeBalance
earnedPoints
balance
state
reward
```

- `state == granted`: `earnedPoints = balance - beforeBalance` とし、実際に保存された増分を表示する。
- `state == already_granted`: `earnedPoints = 0`、前後残高は同値。通常は `last_result_stats` の再利用経路により発生しないが、誤表示を防ぐ。
- `state == save_failed`: 前後残高は同値。予定報酬は内訳へ残してよいが、「付与保留」と表示し、獲得済みとしてカウントアップしない。
- `state == unavailable`: PPの3ブロックと内訳は非表示にし、既存結果表示だけで成立させる。

`pointsBefore = pointsAfter - reward.totalPp` の逆算は使わない。重複報酬キー除外や保存失敗後も正しい値にするため、付与直前の実残高を記録する。

### 3.2 報酬行アダプター

`ResultSystem` に、確定済み `streamPointReward` から0以外の表示行を作る純粋関数を追加する。

通常枠:

| key | id | 表示名 | 初回 |
| --- | --- | --- | --- |
| participationPp | participation | 参加報酬 | false |
| progressPp | progress | 配信継続 | false |
| clearPp | clear | 配信クリア | false |
| bossDefeatPp | boss_defeat | ボス討伐 | false |
| firstStageClearPp | first_stage_clear | 配信枠初回クリア | true |
| firstBossDefeatPp | first_boss_defeat | ボス初回討伐 | true |

配信リレー:

| key | id | 表示名 | 初回 |
| --- | --- | --- | --- |
| participationPp | relay_participation | リレー参加 | false |
| relayStagePp | relay_stage | 配信枠突破 | false |
| relayFinalReachedPp | relay_final_reached | ラスボス戦到達 | false |
| relayFinalClearPp | relay_final_clear | ラストオフライン撃破 | false |
| bossDefeatPp | relay_boss_defeat | 指示コメボス討伐 | false |
| firstRelayClearPp | first_relay_clear | リレー初回完走 | true |

- `amount <= 0` は行を作らない。
- `difficultyMultiplier != 1.0` で実額差がある場合だけ、基礎行合計と `repeatableSubtotal` の差を `difficulty_adjustment` として追加し、全行合計を `pointsEarned` と一致させる。
- 初回行には小さな「初回」バッジを付ける。
- 行数は固定しない。6行までは標準、7行以上はフォントと行間を一段だけ縮小する。スクロールは使わない。

## 4. 完走画面レイアウト

`_result_layout()` は既存の外枠、左列、右キャラクター、下部ボタンの大枠を維持し、完走時だけヘッダー内訳を追加する。

```text
panel
├── titleBlock
├── metricRow
│   ├── evaluationMetric
│   ├── earnedPpMetric
│   └── ownedPpMetric
├── summaryPanel
├── detailPanel
│   ├── highlightCard
│   ├── rewardCard
│   ├── buildCard
│   └── rankingCard
├── characterPanel
└── actionButtons
```

サブ矩形は描画関数内へ散らさず、`_completed_result_detail_layout(detail_rect)` のような純粋関数から返す。

中央列464px高の初期配分:

```text
ハイライト  92px
PP報酬    132px
最終ビルド 112px
ランキング  48px
間隔合計    24px
上下余白    40px
```

- 配信ハイライトは最大5行。0件の項目は作らない。
- 最終ビルドは武器・アクセサリーの2段を維持し、空スロットと間隔だけを縮小可能にする。
- ランキングカードは最大同時視聴者数を補足表示し、`kamiPoint` を参照しない。
- 右列にはPP・ランキング数値を置かない。

## 5. 上部3指標

完走時のランクパネルを横並び3ブロックへ置き換える。

```text
[配信完走評価 S] [今回の獲得 +225 PP] [所持PP 52 -> 277]
```

- 評価ブロック: ピンクから紫。`kamiRank` のみ表示し、`kamiPoint` は非表示。
- 獲得ブロック: 明るい黄色とゴールド。`pointsEarned` を表示。
- 所持ブロック: 薄紫地、濃紫文字、ゴールドの矢印。
- PPコインは専用素材追加を必須にせず、円・縁・`PP`文字の小さな共通描画ヘルパーで作る。
- 数値の優先度は `rank >= earned > owned`。長い数値はブロック幅を変えず段階的にフォントを下げる。

## 6. PP報酬カード

新規 `_draw_result_point_reward_card(rect, point_view, reveal)` を追加する。

- タイトル「PP報酬」
- 左に項目名、右に `N PP`
- 0行は描かない。
- 初回報酬はゴールドの小バッジで区別する。
- 下端に区切り線と「今回の獲得」を表示する。
- `save_failed` は合計欄を「付与保留 +N PP」にし、「ショップで保存を再試行」を小さく表示する。残高増加は演出しない。
- 正常付与時は内訳合計と `pointsEarned` の一致をテストする。

## 7. 表示アニメーション

PPの付与処理と表示アニメーションを分離する。アニメーションは `last_result_data.pointRewardView` を読むだけで、Managerやセーブへ触れない。

既存ドロップ演出終了後を0秒として、初期値を次とする。

```text
0.00s 完走タイトルを確定表示
0.10s 評価ランクを表示
0.28s 獲得PPカウント開始
0.78s 獲得PP確定
0.72s 所持PPの右側をbeforeからafterへカウント開始
1.22s 所持PP確定
1.05s 内訳行を上から0.07秒間隔で表示
1.55s 下部ボタンを操作可能にする
```

追加状態の例:

```gdscript
var result_reveal_elapsed := 0.0
var result_reveal_active := false
var result_reveal_complete := false
var result_reward_se_played := false
var result_shop_emphasis_timer := 0.0
```

- `_update_result_reveal(delta)` は `state == result` かつ完走かつランキング非表示の時だけ進める。
- カウント値・表示行数・各alphaは `_result_reveal_snapshot(elapsed, point_view)` の純粋関数で算出し、テスト可能にする。
- 獲得0、保存失敗、PP利用不可では不要なカウント・SE・ショップ強調を行わない。
- 確定SEは正常付与かつ1PP以上の時に1回だけ。
- 小さなコイン、星粒、黄色い光粒だけをPPブロック周辺に出す。全画面フラッシュと常時点滅は使わない。

## 8. スキップと入力

演出中の最初の決定、キャンセル、左クリックは画面遷移に使わず、`_complete_result_reveal()` を呼んで表示を最終状態へ進め、同イベントを消費する。

- スキップは表示値と行数だけを確定する。
- PP付与、セーブ、ランキング登録を再実行しない。
- 演出中は方向入力によるボタン選択移動も無効にする。
- 演出完了後は既存の4ボタン操作へ戻す。
- マウス、キーボード、ゲームパッドのaccept/cancelで同じ規則にする。
- ランキング表示から戻った時はPP演出を再生せず、完了状態で復元する。

## 9. 下部ボタン

描画と当たり判定の順序を次で統一する。

```text
もう一回 / ランキング / パワーアップ / タイトルへ
```

- `_draw_result_buttons()` 内で4ボタンすべてを描き、現在の末尾にあるショップの個別描画を削除する。
- `PP SHOP` は `パワーアップ` に変更する。
- PPを1以上正常獲得した時だけ、演出終盤にショップボタンへ0.45秒のゴールド外周発光を1回出す。
- 常時点滅させない。ヒット矩形と選択順は既存を維持する。
- ショップを開いてもPP付与処理は呼ばない。既存の保存失敗再試行だけは維持する。

## 10. 変更ファイル候補

- `scripts/systems/result_system.gd`
  - 付与前残高の取得
  - `pointRewardView` の構築
  - 報酬行アダプター
- `scripts/game.gd`
  - 完走ヘッダー、PPカード、中央列、ボタン描画
  - 表示アニメーションとスキップ
- `scripts/tests/test_power_up_shop.gd`
  - 実付与前後残高と二重付与回帰
- 新規 `scripts/tests/test_clear_result_v2.gd` と `.tscn` を推奨
  - 表示データ、レイアウト、アニメーション、ボタン順の純粋テスト

`ui_builder_system.gd` の旧 `result_panel/result_label` は他画面との互換用に残してよい。今回の完走画面は既に `_draw_result_overlay()` が主描画なので、不要な全面置換はしない。

## 11. テスト

### データ

- 通常完走150PP、ボス込み225PP、初回込みの既存期待値を維持。
- `pointsBefore + pointsEarned == pointsAfter`。
- 正常時は報酬行合計が `pointsEarned` と一致。
- 0PP行がない。
- 通常枠とリレーで表示名が切り替わる。
- 同じrunIdの再処理で残高が増えない。
- 保存失敗時は前後残高が同じで、付与済み表示にならない。

### 表示

- 完走画面に `%d pt` / `kamiPoint` が描画されない。
- ランクは表示される。
- 3指標、PP内訳、最終ビルド、ランキング、立ち絵が同時に収まる。
- 4ボタンの描画順とヒット順が一致する。
- ショップラベルが「パワーアップ」。
- 1280x720、1600x900、1920x1080、2560x1440で、canvas_items伸縮後も基準矩形が画面内にある。

### 演出

- カウント途中値が単調増加し、最終値を越えない。
- スキップ後は全値・全行・ボタンが即時確定。
- スキップでPP付与関数が呼ばれない。
- ランキング往復で演出とSEが再発火しない。
- ショップ発光は正常獲得時に1回だけ。

### 回帰

- ランク計算、最大同時視聴者数によるランキング、最終ビルド、再挑戦、ランキング、ショップ、タイトル遷移が維持される。
- 敗北画面の配置・文言・演出が変わらない。
- `git diff --check` とGDScriptパース確認を行う。

## 12. 完成条件

- 完走画面から意味の薄いpt表示が消える。
- 評価、獲得PP、所持PPが役割別に読める。
- PP内訳が確定済み報酬データから構築される。
- PPは表示・スキップ・ショップ遷移で再付与されない。
- 最大同時視聴者数がランキング記録として維持される。
- 既存の最終ビルド、ランキング、キャラクター演出、4遷移が残る。
