# 配信図鑑マイルストーン報酬 V1 QA報告

実行日: 2026-09-07 (Asia/Tokyo)

対象: `C:/Users/zenih/Documents/Codex/2026-05-29/commentdie` の現行dirty tree

ランタイム: `Godot_v4.6.3-stable_win64_console.exe` / Godot 4.6.3

## 1. 変更ファイル

今回のV1追加・接続は次のファイル。

- `data/codex_rewards.json`
- `scripts/systems/codex_reward_system.gd`
- `scripts/systems/power_up_save_store.gd`
- `scripts/systems/power_up_shop_manager.gd`
- `scripts/systems/codex_manager.gd`
- `scripts/ui/codex_screen.gd`
- `scripts/ui/codex_milestone_notice.gd`
- `scripts/game.gd`
- `scripts/tests/test_codex_milestone_rewards_v1.gd`
- `scenes/tests/test_codex_milestone_rewards_v1.tscn`
- `scripts/tests/test_power_up_reward_transaction.gd`（schema 4互換assertのみ）

`scripts/game.gd`、`scripts/ui/codex_screen.gd`、`scripts/systems/power_up_shop_manager.gd` には開始前から他作業のdirty差分があり、V1以外の差分は保持した。

## 2. 報酬マスター構造

`data/codex_rewards.json` は version 1、対象カテゴリ配列、共通milestone配列を持つ。共通段階は `25% / 25PP`、`50% / 50PP`、`75% / 100PP`、`100% / 200PP`。読込時にカテゴリ、重複、percent/PPの有限正整数、percentの昇順、version 1を検証し、不正時は払い出しを無効化する。

## 3. 実際のカテゴリ内部ID

`characters`, `weapons`, `accessories`, `enemies`, `comments`。集計は報酬側で再実装せず、`CodexManager.get_total_count()` / `get_discovered_count()` を利用する。

## 4. 有効件数と閾値

実データで確認した有効総数と必要件数は次の通り。

| ID | 有効総数 | 25 / 50 / 75 / 100% |
|---|---:|---:|
| characters | 6 | 2 / 3 / 5 / 6 |
| weapons | 26 | 7 / 13 / 20 / 26 |
| accessories | 10 | 3 / 5 / 8 / 10 |
| enemies | 42 | 11 / 21 / 32 / 42 |
| comments | 44 | 11 / 22 / 33 / 44 |

`ceil(total * percent / 100)` を使用。disabled weapon、orphan save entry、コメント到達不能項目は実Codex集計から除外されることを確認した。

## 5. PP受取済み保存方式

`powerUpShop.claimedCodexMilestones: Array[String]` に `category:percent`（例 `characters:25`）を恒久保存する。一般の `rewardedRunIds` / `rewardedRewardKeys`、Codex側save、架空runIdは使用しない。正規化は重複除去・上限なしで、未知の過去IDも保持する。

## 6. schema対応

PP `PowerUpSaveStore.SCHEMA_VERSION` を3から4へ加算的に更新し、default/normalizeの両方へ新fieldを追加した。v3等でfieldが無い場合はメモリ上で `[]` になり、ロード時のPP自動加算・自動受取・自動保存は行わない。既存legacy cutoff 2は変更していない。

## 7. transactional保存経路

`grant_codex_milestone_rewards()` は毎回、最新のprofile、正式な `is_unlocked()`、Codexの最新found/totalから再計算し、対象を1回のcandidate deep copyへまとめて `_commit()` する。成功時だけprofile差替え、`points_changed`、専用完了signalを発火する。図鑑報酬でshop unlockや発見状態変更は行わない。

## 8. 既存セーブ遡及挙動

v3コピーで武器26/26・claimedなしをロードしてもPPは0のまま。明示的に受け取った時だけ4段階375PPを付与し、再ロード後もclaimed 4件を保持する。ロード時に通知を再構築しない。

## 9. 新規セーブ初期3キャラの挙動

新規 `characters 3/6` は25%・50%の75PPをeligibleとして表示するが、`unlocked=false` の間は受取不可。正式なshop unlock後にだけ2件をまとめて受け取れる。報酬受取自体はunlockを変更しない。

## 10. UIスクリーンショット

実レンダラ（NVIDIA D3D12）で1600x900/1280x720を取得し、報酬パネル、独立タブバッジ、未受取／COMPLETE表示、通常プレイ中の通知を目視確認した。

- `screenshots/codex-1600x900-characters-claimable.png`
- `screenshots/codex-1280x720-weapons-next.png`
- `screenshots/codex-1600x900-characters-complete.png`
- `screenshots/codex-1600x900-inplay-achievement-notice.png`

最後の画像はCodexを閉じた `state=playing` のGame上で、武器25%到達通知が表示された実画面。

## 11. 25/50/75/100境界QA

5カテゴリについて各milestoneのrequired-1、required、required+1（total内）を確認。小母数total=1では全段階が1件で到達、total=0では未達・非claimable、invalid category／不正重複masterでは払い出しなしを確認した。最終V1テストは **147 checks / 0 failures**（画像取得を除く隔離logic runは138 checks / 0 failures）。

## 12. 保存失敗→再試行QA

一括受取のsave overrideを失敗させ、1 save call、PP/profile全体/disk bytes不変、busy解除、受取可能状態維持を確認。save復旧後の同じ操作で75PPを一度だけ受け取り、再ロード後も92PPとclaimed 2件を確認した。証拠は `codex-milestone-results.json` の `saveFailureRetry`。

## 13. 全20報酬合計1,875PPの検証

1カテゴリ375PP、5カテゴリ×4段階=20件、全体最大1,875PPをマスター値と実受取結果で確認。武器26/26の一括受取結果は375PP。

## 14. 図鑑既存機能の回帰結果

PASS: `test_codex_manager`、`test_codex_v03_records`、`test_codex_v05_completion_audit`、`test_codex_v06_enemy_profiles`、`test_codex_item_lore_ui_v1`。V1実画面テストでは選択ID、LIST/DETAIL focus、一覧／詳細scroll、NEW snapshotを受取前後で保持し、NEWと報酬バッジを独立確認した。main smoke起動もexit 0。

## 15. PP既存テスト結果

PASS: `test_power_up_reward_transaction` **705 checks / 0 failures**、`test_stream_evaluation_v2`、`test_gift_system`。V1変更後も既存のcandidate deep-copy transaction修正を保持した。

## 16. 既知の既存失敗と今回起因の区別

今回のV1テスト・main smoke・PP transactionに新規failureはない。`test_power_up_shop` は開始時から記録されていた `buzz keep values` / `gift reroll values` の2件が同じくFAIL。現行dirty treeの既存Codexテストには、旧Godot型推論によるParse Error（`test_codex_screen`、`test_codex_v07_final`、`test_codex_layout_v08`）、旧テストのParse Error（`test_codex_v04_content`）、comment lore代表文言1件のFAILが残る。これらはV1 PASSとは別に未修正・未確認として扱い、PASSへ隠していない。

## 17. 開始／終了Git状態

開始記録は `git-status-start.txt`。開始時は branch `main`、HEAD `6437e03ad934a7e94806034f7aeb30aa01ff64d3`、tracked status 78行、untracked status 78行。終了時もbranch/HEADは同じで、全体はtracked status 80行、untracked status 87行（V1追加およびQA成果物を含む）。既存dirty/untrackedは保持し、reset/checkout/cleanは未実行。

## 18. `git diff --check`

終了時 `git diff --check --` はexit 0。既存dirtyファイルについてCRLF→LFの警告のみ出力され、whitespace errorは無かった。
