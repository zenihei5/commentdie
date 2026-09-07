# 配信カスタムショップ V1 QA

実施日: 2026-09-07

## 実装対象

- `data/customizations.json`: 商品20件・解禁条件9件、合計7300 PP
- `scripts/systems/customization_database.gd`: マスタ検証・sortOrder管理
- `scripts/systems/customization_provider.gd`: 装飾テーマ・スタンプの表示プリセット
- `scripts/systems/power_up_save_store.gd`: schema 5、購入・装備・解禁条件の保存互換
- `scripts/systems/power_up_shop_manager.gd`: 解禁、購入、装備、解除、保存失敗時の原子性
- `scripts/ui/customization_shop_panel.gd` / `scripts/ui/customization_preview.gd`: ショップ本体とプレビュー
- `scripts/ui/power_up_shop_screen.gd`: パワーアップ画面との上段タブ、キーボード、ゲームパッド、マウス連携
- `scripts/ui/codex_milestone_notice.gd` / `scripts/game.gd`: 新規解禁通知、結果画面・キャラクター選択画面への装備反映

## 結果

- カスタムショップQA（headless）: **78 checks / 0 failures**
- カスタムショップQA（D3D12実機レンダラー）: **83 checks / 0 failures**（実機再取得後）
- PP報酬トランザクション（v4 copy互換を含む親最終回帰）: **710 checks / 0 failures**
- Codexマイルストーン報酬: **138 checks / 0 failures**
- 親タスク独立QA（ロジック境界・通知）: **124 checks / 0 failures**
- 親タスク独立QA（実UI 1280×720 / 1600×900）: **各59 checks / 0 failures**
- 親タスク独立QA（ワイド通知）: **32 checks / 0 failures**
- `git diff --check --`: **exit 0**（既存ファイルのCRLF正規化警告のみ）
- 起動 smoke（headless、5秒）: **exit 0**

## 実機描画確認

D3D12出力（1280×720 / 1600×900）:

- `rendered-d3d12/custom-shop-theme-1280x720.png`: テーマ商品一覧、解禁ゲート、プレビューの非重なり
- `rendered-d3d12/custom-shop-stamp-archive-1280x720.png`: アーカイブの三角スタンプと「アーカイブ残します」表示
- `rendered-d3d12/custom-power-up-theme-neon-pink-1280x720.png`: パワーアップ側の装飾テーマ外枠・装飾線
- `rendered-d3d12/custom-result-1600x900.png`: 結果画面上部の肩書き・テーマ・スタンプ帯
- `rendered-d3d12/custom-character-select-1600x900.png`: `装備中の肩書き 《コメント欄の支配者》` バッジ

## テストシーン

- `scenes/tests/test_customization_shop_v1.tscn`
- `scripts/tests/test_customization_shop_v1.gd`

## 既存テストの注意

`test_power_up_shop_screen_v2.tscn` は開始時 dirty tree と同じハーネスで比較した。開始時は23 failures、今回の実装直後も23 failuresで、内訳は共通22件、開始時のみの `reset dialog layer blocks background input`、今回のみの上位Focus追加による `category tab up moves to Back footer` だった。後者は上位ショップタブへ到達する現在仕様へテストを更新し、パワーアップ→配信カスタム→パワーアップの左右操作も確認した。更新後の残件は共通22件で、今回の実装による増加はない。

比較記録: `OUT/screen-regression-comparison.json`、`parent-screen-baseline.log`、`parent-screen-current.log`（親タスク側保存）。

## QAアーティファクト

- `rendered-headless/customization-shop-results.json`
- `rendered-d3d12/customization-shop-results.json`
- `rendered-d3d12/` 配下の5枚の実機スクリーンショット

なお、作業開始時点でワークツリーは既に dirty だったため、既存の変更・未追跡ファイルは保持している。
