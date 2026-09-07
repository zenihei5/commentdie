# 配信目標 V1 QA報告

実装・QA実行日: 2026-09-07（Asia/Tokyo）  
基準コミット: `6437e03ad934a7e94806034f7aeb30aa01ff64d3`

## 判定

配信目標 V1 のマスタ、正式完走ガード、実績集計、報酬一括保存、再試行、保存互換、UI表示を実装し、対象テストを通過した。

- 配信目標18件、セット6件を `data/stream_missions.json` に固定。
- 1ミッション50 PP、1セット100 PP、最大1500 PP。難易度・評価倍率はミッション報酬に適用しない。
- 全18件達成時は `title_perfect_streamer` を直接所有化し、自動装備・ショップ購入は行わない。
- 正式メニュー起点、正式難易度、非クイックテスト、非デバッグ汚染、正常終了を要求。リレーは5区間の正確な順序、最終ボスのプレイヤー側撃破、スコア付与を要求。
- 保存失敗時はプロフィール・報酬入力・ミッション履歴を変更せず、同一内容を再試行できる pending を保持。
- 結果画面は既存PP合計を二重加算せず、`配信目標 +XXX PP` の集約行を1行だけ表示。

## 自動テスト

すべてのセーブ系テストは `COMMENTDIE_PP_TEST_ROOT` と、その配下に置いた隔離 `APPDATA` を使用した。実機の `user://power_up_shop.json` は読み書きしていない。

| テスト | 結果 |
|---|---:|
| `test_stream_mission_v1.tscn` | PASS — 162 checks / 0 failures |
| `test_stream_mission_ui_v1.tscn` headless | PASS — 7 checks / 0 failures |
| `test_stream_mission_ui_v1.tscn` D3D12実描画 | PASS — 13 checks / 0 failures |
| `test_stream_mission_ui_v1.tscn` OpenGL互換実描画 | PASS — 13 checks / 0 failures |
| `test_power_up_reward_transaction.tscn` | PASS — 705 checks / 0 failures |
| `test_customization_shop_v1.tscn` | PASS — 79 checks / 0 failures |
| `test_clear_result_v2.tscn` | PASS |
| `test_stream_evaluation_v2.tscn` | PASS |
| `test_difficulty_progress_system.tscn` | PASS |
| プロジェクト起動検査 `--headless --path . --quit-after 5` | exit 0 |
| `git diff --check --` | exit 0 |

配信目標テストでは、各閾値の直前・境界・超過、NORMAL/HARD+の可否、通常枠とリレーの取り違え、正式完走前の評価、プレイヤー側／パートナー側ボス撃破、リレー区間ローカル条件、保存失敗2回後の再試行、同一runの冪等性、schema 5 の非遡及、schema 6 の未知ID保持を確認した。

## 描画QA

プロジェクト既定のD3D12とOpenGL互換レンダラーで、以下を保存した。

- 1280×720 枠選択: [stream-frame-select-missions-1280x720.png](rendered-d3d12/stream-frame-select-missions-1280x720.png)
- 1600×900 枠選択: [stream-frame-select-missions-1600x900.png](rendered-d3d12/stream-frame-select-missions-1600x900.png)
- 1600×900 結果PP内訳: [stream-result-mission-breakdown-1600x900.png](rendered-d3d12/stream-result-mission-breakdown-1600x900.png)
- OpenGL互換版: [rendered-gl](rendered-gl/)

枠選択では3件の目標、進捗、`説明｜配信目標` タブ、セット報酬がパネル内に収まることを確認した。結果画面では11行になり得る既存報酬＋配信目標を3列へ再配置し、配信目標行の切れと合計の二重表示がないことを確認した。

## 変更範囲

主な変更は、配信目標マスタ／ラン追跡／評価システム、`PowerUpShopManager` の一括トランザクション、結果画面と枠選択UI、schema 6 保存互換、既存ボス・ジャンルイベント・ステージ計測フック、および専用テストである。既存のカスタマイズショップ改修・アセット・既存テスト更新など、開始時から存在した作業ツリー変更は保持した。

## 既存ベースラインの別扱い

開始時から存在する作業ツリー上の既存変更に紐づく以下の回帰は、配信目標 V1 の判定から分離して記録する。

- `test_power_up_shop.tscn`: 2 failures（既存の buzz/gift keep・reroll期待値）
- `test_power_up_shop_screen_v2.tscn`: 22 failures（既存の上位タブ／画面期待値更新との不一致）

これらは今回の配信目標仕様の実装対象外であり、既存変更を戻す操作は行っていない。

## 注意ログ

Godot実行時には環境由来のルート証明書ストア警告と、終了時のRenderer/TextServer RID・resource leak警告が出るが、対象テストは成功し、プロジェクト検査の終了コードは0だった。
