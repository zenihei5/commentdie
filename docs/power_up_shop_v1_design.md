# 『ぜんぶコメントのせいだ』
# パワーアップショップ第1版 実装設計

## 1. 目的と設計範囲

本設計は、仕様書 `パワーアップショップ第1版` を現行Godot実装へ接続するための実装設計である。

対象は次の4系統とする。

- 配信ポイント（PP）の計算、確定、保存、リザルト表示
- 8種類・各5段階の恒久強化、購入、全額リセット
- ラン開始時スナップショットとゲーム中の効果適用
- タイトル、リザルト、配信枠選択、ショップ画面の導線

仕様にないキャラクター別強化、強化ツリー、個別レベルダウン、消耗品は追加しない。

参照仕様:

```text
C:/Users/zenih/.codex/attachments/f8937efa-87d1-43ff-bf07-34e310d2628c/pasted-text.txt
```

## 2. 現行実装の確認結果

### 2.1 進行とUI

現行は `scripts/game.gd` が `state` を所有し、描画と入力の大半を管理している。前面画面の状態遷移は `StateFlowSystem` へ一部委譲されている。

現在のタイトルメニューは次の4インデックスである。

```text
0 ニューゲーム
1 ランキング
2 オプション
3 ゲーム終了
```

`title_button_alpha.png` は上3項目を1枚にまとめた画像であり、ショップ行を単純に挿入できない。タイトル改修時は、既存画像の矩形定義へ無理に4行目を足さず、ショップ用ボタンを独立した描画要素として追加する。

現行リザルトの操作は `retry / ranking / title` の3項目である。第1版では仕様どおり次へ変更する。

```text
retry / power_up_shop / stream_frame_select / title
```

ランキングはタイトルから引き続き利用できる。

### 2.2 保存

現行の永続データは用途ごとに別JSONである。

- `user://settings.json`
- `user://rankings.json`
- `user://stream_frame_progress.json`

共通プロフィール保存層はまだない。ショップも独立した `user://power_up_shop.json` とし、ルートキーを `powerUpShop` にする。既存3ファイルは統合・移動しない。

### 2.3 ラン開始と結果確定

- ラン初期化は `RunStateSystem.restart_run_for_target()` が担当する。
- 通常結果と配信リレー結果は `ResultSystem.complete_run_for_target()` へ集約される。
- 現行 `runId` は結果画面作成時に日時とスコアから生成される。
- 配信リレーでは `RelayRunData` がHP、装備、経験値などを区間間で引き継ぐ。

PPの二重付与防止には「結果時生成」では遅いため、`runId` は新しいランを開始した時点で生成する。配信リレーは全区間とラスボス戦で同じ `runId` を保持する。

### 2.4 ボス討伐

通常ボスは `BossSystem.apply_defeat_for_target()`、ラストオフラインは `game.gd::_on_relay_boss_enemy_defeated()` から `RelayBossSystem.mark_defeated()` へ流れる。

現在は `boss_defeated: bool` しかなく、複数体、報酬対象外個体、死亡処理の重複を区別できない。PP用にはラン単位の討伐記録を別に持つ。

### 2.5 恒久補正の接続上の注意

- 攻撃の一部と一時バフは `ModifierSystem.modifier_sources` を利用している。
- 装備取得時に `GiftSystem._apply_equipment_stats_to_target()` が最大HP、攻撃、移動、回収範囲を基礎値から再計算する。
- ダッシュ初速は `PlayerSystem` 内の固定値 `760.0` である。
- 経験値は `ExpSystem.add_exp_to_target()` に集約されている。
- 回復は `GiftSystem`、`DestructibleSystem`、`MarshmallowSystem`、歌枠、お絵かき枠、ラスボス応援コメントなどへ分散している。

したがって、初期値だけへショップ補正を乗せる実装では、装備取得時に補正が消える。ラン用スナップショットを唯一の参照元とし、再計算経路にも同じ合成関数を使う。

## 3. 仕様矛盾の解決

### 3.1 ラストオフラインの初回討伐75PP

仕様の `firstBossDefeats` 例には `last_offline` が含まれる。一方、配信リレーの明記された初回完走額とテスト期待値は次である。

```text
通常完走 960 PP
初回完走ボーナス 200 PP
合計 1,160 PP
```

ラストオフライン初回討伐75PPを加えると1,235PPになり、受け入れ条件と一致しない。本設計では明示された合計とテスト値を優先し、次の扱いに統一する。

- `firstBossDefeats.last_offline` は討伐履歴として更新する。
- ラストオフラインには通常ボス討伐75PPを付けない。
- ラストオフライン単独の初回討伐75PPも付けない。
- 初回の特別報酬は `firstRelayClear = 200 PP` に一本化する。

### 3.2 ボスID

仕様例と現行 `data/bosses.json` では一部IDが異なる。セーブへランタイムIDを直接使わず、ボスデータへ安定ID `ppRewardId` を追加する。

| 現行ランタイムID | `ppRewardId` | 反復PP |
| --- | --- | ---: |
| `boss_kuso_maro_king` | `kusomaro_king` | 75 |
| `bugged_final_boss` | `bugged_final_boss` | 75 |
| `pitch_police_chief` | `pitch_police_chief` | 75 |
| `red_pen_review_chief` | `redpen_retake_dragon` | 75 |
| `collab_crusher` | `collab_crusher` | 75 |
| `last_offline` | `last_offline` | 0 |

`boss_super_long_comment` は第1版の「通常枠5ボス」に含めず、`isPpRewardTarget: false` とする。

### 3.3 配信枠初回クリア

`firstStageClears` は通常枠のリザルトだけで更新する。配信リレー中の区間突破では更新しない。これにより配信リレー報酬の明記額を維持する。

## 4. 新規ファイルと責務

```text
data/power_up_shop.json

scripts/systems/power_up_database.gd
scripts/systems/power_up_save_store.gd
scripts/systems/power_up_shop_manager.gd
scripts/systems/power_up_run_tracker.gd
scripts/systems/stream_point_reward_calculator.gd
scripts/systems/power_up_effect_provider.gd
scripts/systems/stream_point_reward_result.gd
scripts/systems/permanent_upgrade_snapshot.gd

scripts/ui/power_up_shop_screen.tscn
scripts/ui/power_up_shop_screen.gd

scripts/tests/test_power_up_database.gd
scripts/tests/test_stream_point_reward_calculator.gd
scripts/tests/test_power_up_shop_manager.gd
scripts/tests/test_power_up_effect_provider.gd
scripts/tests/test_power_up_shop_integration.gd
```

### 4.1 `PowerUpDatabase`

- `data/power_up_shop.json` のロード
- 強化ID検索
- 報酬設定と難易度倍率の取得
- ID重複、カテゴリ、配列長、値、価格の検証
- 不正項目を表示対象から除外
- エラー一覧と `is_valid` の公開

マスターデータ全体を読めない場合はショップを開かず、PPを変更しない。アイコンだけが欠ける場合は代替アイコンで継続する。

### 4.2 `PowerUpSaveStore`

- `user://power_up_shop.json` のロードと保存
- 初期データ生成
- schemaVersion移行
- 不正レベル、負数PP、欠損キーの補正
- 保存成否を `bool` で返す

保存は一時ファイルへ書き、書いたJSONを再読込して検証してから本ファイルへ反映する。既存ファイルは `.bak` として1世代残す。本ファイルが壊れている場合は `.bak`、それも読めなければ移行済み初期値へフォールバックする。

### 4.3 `PowerUpShopManager`

`RefCounted` のインスタンスとして `game.gd` が1つ所有する。

- 現在PPと強化レベルの所有
- 購入、全リセット、PP付与のトランザクション
- 多重入力ロック
- 初回フラグと `rewardedRunIds` の確定
- UI向けシグナル

公開シグナル:

```gdscript
signal points_changed(previous_value: int, new_value: int)
signal upgrade_purchased(upgrade_id: String, new_level: int, price: int)
signal upgrades_reset(refunded_points: int)
signal shop_unlocked
signal purchase_failed(reason: int)
signal reward_granted(run_id: String, total_pp: int)
```

### 4.4 `PowerUpRunTracker`

ラン中だけ存在する記録を所有する。セーブデータを参照しない。

```gdscript
{
  "runId": "run_20260718_120501_8f2a",
  "rewardEligible": true,
  "resultCommitted": false,
  "shopUpgradesEnabled": true,
  "totalShopUpgradeLevel": 14,
  "rewardedBossKeys": {},
  "defeatedBosses": [],
  "relayFinalReached": false,
  "relayFinalDefeated": false
}
```

責務:

- ラン開始時の一意ID生成
- 報酬対象ランかの記録
- `rewardKey` 単位のボス討伐重複防止
- 配信リレー全区間で同じ記録を維持
- デバッグ生成ボスの除外

通常ボスの推奨 `rewardKey`:

```text
<runId>:<ppRewardId>:<enemy uid>:<boss summon count>
```

### 4.5 `StreamPointRewardCalculator`

副作用を持たない純粋計算クラスとする。プロフィールを変更しない。

入力:

```gdscript
{
  "outcome": "completed | defeated | retired | crashed | debug",
  "rewardEligible": true,
  "isRelay": false,
  "activePlaySeconds": 180.0,
  "stageId": "zatsudan",
  "stageCleared": true,
  "difficultyId": "normal",
  "defeatedBosses": [],
  "relayClearedFrameIds": [],
  "relayFinalReached": false,
  "relayFinalDefeated": false
}
```

別入力として、現在の `firstStageClears`、`firstBossDefeats`、`firstRelayClear` を渡す。

出力は `StreamPointRewardResult` とし、表示内訳に加えて確定用メタデータを持つ。

```gdscript
var newly_cleared_stage_ids: Array[String]
var newly_defeated_boss_ids: Array[String]
var grants_first_relay_clear: bool
```

### 4.6 `PowerUpEffectProvider`

- セーブとマスターから `PermanentUpgradeSnapshot` を作る
- ラン中の恒久補正値を返す
- 既存の常時補正との加算合成
- 経験値と回復の小数端数処理
- ギフト品質ウェイトの補正

ゲーム中の各システムはプロフィールやショップマスターを直接読まず、`target.permanent_upgrade_snapshot` だけを読む。

### 4.7 `PowerUpShopScreen`

既存の `RelayBreakScreen` と同様に独立した `Control` シーンとして一度生成し、通常は非表示にする。ショップUIのフォーカス、マウスヒット、タブ、確認ダイアログ、演出はこのシーンが所有する。

`game.gd` は画面を細かく描画せず、次だけを担当する。

- 画面を開く
- 遷移元を渡す
- Managerをバインドする
- 閉じた際の次状態を決定する

## 5. マスターデータ

`data/power_up_shop.json` は次のルート構造にする。

```json
{
  "schemaVersion": 1,
  "currency": {
    "id": "stream_points",
    "displayName": "配信ポイント",
    "shortName": "PP"
  },
  "rewardRules": {
    "normal": {
      "participation": 5,
      "progressMax": 60,
      "progressDurationSeconds": 180.0,
      "clear": 85,
      "firstStageClear": 50,
      "firstBossDefeat": 75
    },
    "relay": {
      "participation": 10,
      "clearedFrame": 120,
      "finalReached": 100,
      "finalDefeated": 250,
      "firstClear": 200
    },
    "difficulty": {
      "normal": 1.0,
      "hard": 1.0,
      "expert": 1.0
    }
  },
  "categories": [
    {"id": "combat", "displayName": "戦闘"},
    {"id": "support", "displayName": "配信サポート"}
  ],
  "upgrades": []
}
```

8強化の値と価格は仕様書どおり格納する。

| ID | category | values | prices |
| --- | --- | --- | --- |
| `max_hp` | combat | `[0,.04,.08,.12,.16,.20]` | `[120,220,360,540,760]` |
| `attack_power` | combat | `[0,.03,.06,.09,.12,.15]` | `[120,220,360,540,760]` |
| `move_speed` | combat | `[0,.02,.04,.06,.08,.10]` | `[120,220,360,540,760]` |
| `damage_reduction` | combat | `[0,.02,.04,.06,.08,.10]` | `[120,220,360,540,760]` |
| `exp_gain` | support | `[0,.04,.08,.12,.16,.20]` | `[100,180,300,450,650]` |
| `pickup_range` | support | `[0,.06,.12,.18,.24,.30]` | `[100,180,300,450,650]` |
| `healing_power` | support | `[0,.05,.10,.15,.20,.25]` | `[100,180,300,450,650]` |
| `gift_luck` | support | 専用2配列 | `[100,180,300,450,650]` |

`gift_luck`:

```json
{
  "hitWeightMultipliers": [1.0, 1.08, 1.16, 1.24, 1.32, 1.40],
  "jackpotWeightMultipliers": [1.0, 1.12, 1.24, 1.36, 1.48, 1.60]
}
```

ボスデータには次を追加する。

```json
{
  "ppRewardId": "kusomaro_king",
  "basePpReward": 75,
  "isPpRewardTarget": true,
  "isFirstDefeatRewardTarget": true
}
```

ラストオフラインは `data/relay_mode.json` の `boss` に次を持たせる。

```json
{
  "ppRewardId": "last_offline",
  "basePpReward": 0,
  "isPpRewardTarget": false,
  "isFirstDefeatRewardTarget": false,
  "trackFirstDefeat": true
}
```

## 6. セーブデータと移行

保存形式:

```json
{
  "powerUpShop": {
    "schemaVersion": 1,
    "unlocked": false,
    "currentPoints": 0,
    "totalEarnedPoints": 0,
    "totalSpentPoints": 0,
    "upgrades": {
      "max_hp": 0,
      "attack_power": 0,
      "move_speed": 0,
      "damage_reduction": 0,
      "exp_gain": 0,
      "pickup_range": 0,
      "healing_power": 0,
      "gift_luck": 0
    },
    "firstStageClears": {
      "zatsudan": false,
      "gameplay": false,
      "singing": false,
      "drawing": false,
      "collab": false
    },
    "firstBossDefeats": {
      "kusomaro_king": false,
      "bugged_final_boss": false,
      "pitch_police_chief": false,
      "redpen_retake_dragon": false,
      "collab_crusher": false,
      "last_offline": false
    },
    "firstRelayClear": false,
    "rewardedRunIds": []
  }
}
```

`rewardedRunIds` は100件を上限とし、古いものから削除する。

### 6.1 旧セーブ移行

`power_up_shop.json` がない場合:

1. 全強化Lv0、PP 0で作る。
2. `stream_frame_progress.json` の `isCleared` から `firstStageClears` を復元する。
3. `rankings.json` にデバッグ・テストでない結果が1件以上あれば `unlocked = true` とする。
4. ランキングの `bossDefeated` と `bossName` から一意に判定できる場合だけボス初回フラグを復元する。
5. 配信リレー完走記録から `firstRelayClear` と `firstBossDefeats.last_offline` を復元する。
6. 過去プレイへPPを遡及付与しない。

ボス名移行では表示名と旧IDのalias表を使う。判定不能なら `false` のままにする。

### 6.2 設定値

プレイ前のON/OFF既定値は購入セーブと分け、`settings.json` に次を追加する。

```json
{"shopUpgradesEnabled": true}
```

これは次ランの初期選択だけを保存する。OFFにしても購入レベルは変更しない。

## 7. ラン開始ライフサイクル

新しい通常ランまたは配信リレー開始時の順序:

```text
1. pre_run_shop_upgrades_enabled を確定
2. runIdを生成
3. PowerUpRunTrackerを新規作成
4. PermanentUpgradeSnapshotを作成
5. RunStateSystemで基礎値を初期化
6. スナップショットを使って恒久補正を合成
7. キャラクターパッシブを適用
8. ラン開始
```

リザルトの「もう一度」は直前のON/OFF設定を引き継ぐが、必ず新しい `runId` と新しいスナップショットを作る。

配信リレーの区間遷移では1～4をやり直さない。`RelayRunData` に次を追加して端数と記録を維持する。

```text
powerUpExpRemainder
powerUpHealingRemainder
```

スナップショット本体は `game.gd` のラン変数として全区間で保持する。

デバッグ専用ランとクイックテストは `rewardEligible = false`。通常ラン中にデバッグ生成したボスだけは、そのボスへ `ppRewardEligible = false` を付け、ラン全体を無効にはしない。

## 8. PP計算と確定

### 8.1 通常枠

```gdscript
progress_pp = roundi(60.0 * clampf(active_play_seconds / 180.0, 0.0, 1.0))
```

`active_play_seconds` は現行 `elapsed` と同じ進行基準を使い、ポーズ、選択画面、カットインなどでは進めない。

結果別:

- `completed`: 参加、継続、クリア、ボス、初回を計算
- `defeated`: 参加、継続、討伐済みボス、対象初回を計算
- `retired`, `crashed`, `debug`: すべて0、ショップ解禁もしない

### 8.2 配信リレー

```text
10 + cleared_frame_count * 120
+ final_reached ? 100 : 0
+ final_defeated ? 250 : 0
+ first_relay_clear ? 200 : 0
+ リレー中に倒した通常指示コメボスのPP
```

未突破区間の生存時間PPは付けない。

### 8.3 難易度

反復部分を合計した後に1回だけ丸める。

```gdscript
final_repeatable_pp = roundi(repeatable_subtotal * difficulty_multiplier)
total_pp = final_repeatable_pp + one_time_subtotal
```

初回報酬へ倍率をかけない。

### 8.4 確定トランザクション

`ResultSystem.complete_run_for_target()` の結果作成中に次の順で実行する。

```text
1. ラン結果を構築
2. Calculatorで内訳と新規初回フラグを計算
3. Managerへ runId と計算結果を渡す
4. Managerがプロフィールをdeep copy
5. runId重複確認
6. PP、初回フラグ、unlocked、rewardedRunIdsを一括更新
7. 1回保存
8. 保存成功後だけ実プロフィールへ確定
9. 報酬内訳と所持PPをresultDataへ格納
10. 既存の枠進行とランキング保存を続行
```

同じ `runId` が保存済みなら加算せず、保存済み扱いでリザルトを表示する。

保存に失敗した場合:

- メモリ上のPPとフラグを元へ戻す。
- 成功演出を出さない。
- `resultData.ppGrantState = "save_failed"` を設定する。
- ショップ遷移要求時に同じ不変な報酬データで再保存を1回試す。
- 再保存にも失敗した場合はショップを開かず、リザルトへエラーを表示する。

ショップ側で報酬を再計算してはならない。

## 9. ボス討伐記録

通常ボスのHP0確定時、`BossSystem.apply_defeat_for_target()` から次を呼ぶ。

```gdscript
PowerUpRunTracker.register_boss_defeat(target, {
  "bossId": boss.get("bossId"),
  "ppRewardId": boss.get("ppRewardId"),
  "rewardKey": ...,
  "basePpReward": boss.get("basePpReward", 0),
  "isPpRewardTarget": boss.get("isPpRewardTarget", false),
  "isFirstDefeatRewardTarget": boss.get("isFirstDefeatRewardTarget", false),
  "defeatReason": "player_side_damage"
})
```

付属パーツ、分身、残像、召喚雑魚、イベント消去では呼ばない。通常ボスの現行撃破経路はプレイヤー側攻撃によるHP0であるため、ここを正式な `player_side_damage` 確定点とする。

ラストオフラインは `_on_relay_boss_enemy_defeated()` で `relayFinalDefeated = true` と討伐履歴だけを記録する。PPはリレー専用250PPへ委ねる。

## 10. 恒久補正の合成

`PermanentUpgradeSnapshot`:

```gdscript
var enabled := false
var max_hp_bonus := 0.0
var attack_power_bonus := 0.0
var move_speed_bonus := 0.0
var damage_reduction := 0.0
var exp_gain_bonus := 0.0
var pickup_range_bonus := 0.0
var healing_power_bonus := 0.0
var gift_hit_weight_multiplier := 1.0
var gift_jackpot_weight_multiplier := 1.0
var total_upgrade_level := 0
```

OFF時も `total_upgrade_level` は購入総Lvを記録するが、効果値は0、ギフト倍率は1.0とする。

### 10.1 最大HP

現行の `mental_care` は割合ではなく固定値加算なので、互換性を維持して次とする。

```gdscript
final_max_hp = roundi(base_hp * (1.0 + shop_hp_bonus + other_percent_bonus)) + existing_flat_hp_bonus
```

`RunStateSystem.initial_values()` と `GiftSystem._apply_equipment_stats_to_target()` の両方が同じProvider関数を使う。装備再計算時は増えた最大HP分だけ現在HPを増やす現行挙動を維持する。

### 10.2 攻撃力

同カテゴリの恒久補正を加算し、一時補正だけ後乗算する。

```gdscript
constant_rate = 1.0 + shop_bonus + accessory_bonus + weapon_level_bonus + character_bonus
final_damage = base_damage * constant_rate * temporary_multiplier
```

接続先:

- `RunStateSystem.initial_values()` の初期武器
- `GiftSystem._apply_equipment_stats_to_target()` の主武器・追加武器
- `WeaponSystem` の進化武器
- コラボ技ダメージ計算
- 相方支援攻撃
- リスナー召喚

`ModifierSystem` の `playerAttackDamage` はラスボス応援などの一時倍率として残す。ショップ補正を同じ乗算sourceへ入れない。

### 10.3 移動速度

通常速度:

```gdscript
base_speed * (1.0 + shop_bonus + sneaker_bonus + character_bonus) * temporary_multiplier
```

ダッシュ初速:

```gdscript
760.0 * (1.0 + shop_bonus)
```

`PlayerSystem.update_motion()` へ `dashSpeedMultiplier` を追加する。ノックバック、強制移動、コラボチャレンジ固定移動、ステージ自動移動へは渡さない。

### 10.4 被ダメージ軽減

`DamageSystem.apply_damage_source_for_target()` の順序を次へ統一する。

```text
1. 敵・ステージ側の基礎ダメージとステージ倍率を確定
2. 恒久軽減を加算し40%でclamp
3. max(1, round(raw * (1 - constant_reduction)))
4. 歌枠などの一時倍率
5. ModifierSystem.playerDamageTaken の一時倍率
6. 最終整数化、最低1
```

ショップ軽減は `modifier_sources` へ登録しない。これにより「恒久軽減後に一時倍率」の順序を保証する。

### 10.5 経験値

`ExpSystem.add_exp_to_target()` の入口で全対象経験値へ一度だけ適用する。

```gdscript
scaled = amount * (1.0 + snapshot.exp_gain_bonus) + power_up_exp_remainder
granted = floori(scaled)
power_up_exp_remainder = scaled - granted
```

その後に既存 `notification_bell` のボーナス処理を行う。PP、スコア、シンクロスター、固定レベルアップには `add_exp_to_target()` を使わない。

### 10.6 回収範囲

Providerへ次の2種類を用意する。

```gdscript
normal_pickup_radius(base_radius)
normal_attract_radius(base_radius)
```

適用するもの:

- 経験値オーブ
- 破壊物ドロップの回復、ハート、スコア系アイテム
- 通常マシュマロ回収物
- レースコイン
- お絵かき枠のペイントオーブ
- その他、通常アイテムとして明示した回収物

適用しないもの:

- シンクロスター
- コラボパス
- コラボチャレンジ専用コメント・オーブ
- 歌枠の判定用ノートや歌詞カードなどイベント接触物
- ダッシュ床、危険床、攻撃判定

固定距離を見つけるたび無条件に倍率をかけず、回収物種別をallowlistで分類する。

### 10.7 回復量

Providerへ `scaled_heal_amount(target, base_amount, source_id)` を追加し、小さい持続回復でも効果が失われないよう端数を保持する。

```gdscript
bonus_pool = base_amount * healing_power_bonus + power_up_healing_remainder
bonus = floori(bonus_pool)
power_up_healing_remainder = bonus_pool - bonus
return base_amount + bonus
```

適用source:

- `gift_heal`
- `drop_heal`
- `marshmallow_heal`
- `regeneration`
- `equipment_heal`
- `song_note_heal`
- `drawing_green_heal`
- `boss_support_dont_lose`

除外source:

- `relay_break_heal`
- `revive`
- `run_start_full_heal`
- `max_hp_delta`
- `direct_set`
- `debug_heal`

回復禁止状態の確認、倍率適用、最大HPclampの順で処理する。

### 10.8 ギフト祈願

現行 `GiftSystem.roll_level_gain()` の確率を品質ウェイトへ変換する。

| 期待度 | 通常 | 当たり | 大当たり |
| --- | ---: | ---: | ---: |
| 0～39 | 1.00 | 0.00 | 0.00 |
| 40～69 | 0.65 | 0.35 | 0.00 |
| 70～89 | 0.30 | 0.55 | 0.15 |
| 90～100 | 0.15 | 0.35 | 0.50 |

抽選前に次を適用して再正規化する。

```gdscript
hit_weight *= snapshot.gift_hit_weight_multiplier
jackpot_weight *= snapshot.gift_jackpot_weight_multiplier
```

進化枠の先置き、保証枠、候補除外、3択数、武器・アクセサリー比率は現行のままにする。元ウェイトが0の品質を新たに出現させない。

## 11. ショップ画面

### 11.1 状態

`state = "power_up_shop"` を追加する。`StateFlowSystem` の次へ追加する。

- `front_state_action_for_target`
- `has_modal_overlay`
- `overlay_view`
- `shows_comment_countdown`
- タイトルBGM対象

ショップはゲーム中に開けない。

### 11.2 遷移元

```gdscript
enum ShopOrigin { TITLE, RESULT }
```

- TITLEから閉じる: `title`
- RESULTから閉じる: `stream_frame_select`

リザルト起点ではPP保存成功を確認してから画面を開く。

### 11.3 レイアウト

1600x900を基準に全画面Controlで構成し、1280x720でも欠けないアンカーと最小サイズを設定する。

- 上部: 戻る、パワーアップ、所持PP
- 左側: 戦闘 / 配信サポートのタブ
- 中央: 2列x2行の強化カード
- 右側: 選択中強化の詳細と購入
- 下部: 全リセット、操作ヘルプ、トースト

カードは各強化1枚だけとし、カードの内側へ別カードを入れない。角丸は8px以下にする。

カードの安定寸法を固定し、`Lv 5 / 5`、5個のレベルドット、長い日本語名、`MAX` でサイズが変わらないようにする。

### 11.4 入力とフォーカス

- 2x2グリッドの方向移動
- Enter/Zまたはゲームパッド決定で即購入
- Esc/Xまたはキャンセルで戻る
- Q/E、L1/R1でカテゴリ切り替え
- 下端カードから下でリセットへ移動
- カテゴリごとに最後のカード位置を保存
- マウスはクリック時だけ購入

リセット確認の初期フォーカスはキャンセル。

### 11.5 表示状態

- PP不足でもカードと詳細は選択可能
- 価格だけ警告色
- 最大Lvは価格を消して `MAX`
- アイコン欠損は共通代替アイコン
- マスターデータ全体が無効なら画面を開かずエラー

購入成功演出は0.3～0.5秒で、演出中もManagerロックを維持する。

## 12. タイトル・リザルト・プレイ前設定

### 12.1 タイトル

表示順:

```text
配信を始める
パワーアップ
ランキング
オプション
ゲーム終了（既存の独立ボタン）
```

ショップボタンは既存3行画像へ混ぜず、独立したボタンとして追加する。既存のランキングとオプションを下へ調整し、全項目のヒット領域を実際の表示矩形から作る。

未解禁時も表示し、決定時は遷移せず次を表示する。

```text
初回プレイ後に解禁
```

### 12.2 リザルト

`resultData` へ次を追加する。

```text
streamPointReward
streamPointBalance
ppGrantState
shopUnlockedThisRun
```

0以外の内訳だけを表示し、合計と所持PPは常に表示する。既存結果情報を押しつぶさないよう、PP内訳は専用ブロックにまとめる。

アクション:

```text
もう一度
パワーアップ
配信枠選択へ
タイトルへ
```

### 12.3 プレイ前ON/OFF

すべてのランが通る `stream_frame_select` の詳細領域へ、スイッチではなくON/OFFのセグメントコントロールを置く。

```text
ショップ強化  [ON] [OFF]
```

決定値を `_restart()` 直前にスナップショットへコピーする。ランキングエントリへ次を追加する。

```json
{
  "shopUpgradesEnabled": true,
  "totalShopUpgradeLevel": 14
}
```

## 13. 購入とリセット

Managerは変更前プロフィールをdeep copyし、保存成功後だけ確定する。

購入結果:

```text
SUCCESS
LOCKED
BUSY
INVALID_ID
MAX_LEVEL
NOT_ENOUGH_POINTS
SAVE_FAILED
```

リセット返還額は現在レベルと現在マスター価格から再計算する。`totalSpentPoints` と違う場合は警告ログを出し、再計算値を返す。保存失敗時はPP、全Lv、累計消費をすべて戻す。

購入・リセットの価格をUI文字列から読み取らない。

## 14. 実装順序

### Phase 1: データと保存

1. `power_up_shop.json` とDatabase
2. SaveStoreと移行
3. Managerの購入、リセット、保存ロールバック
4. 純粋テスト

### Phase 2: ラン記録とPP

1. runIdをラン開始へ移動
2. RunTracker
3. 通常・ラスボス討伐フック
4. RewardCalculator
5. ResultSystemで1回だけ付与
6. リザルト表示と解禁通知

### Phase 3: 効果適用

1. Snapshot作成
2. HP、攻撃、移動、被ダメージ
3. 経験値、回収、回復
4. ギフト祈願
5. リレー区間引き継ぎ
6. ラン記録へON/OFFを追加

### Phase 4: UIと導線

1. ShopScreen
2. タイトル導線とロック表示
3. リザルト4ボタン
4. 配信枠選択のON/OFF
5. 購入・不足・リセット演出

### Phase 5: 回帰確認

1. 通常・リレー報酬
2. 全強化Lv0/Lv1/Lv5
3. セーブ失敗と多重入力
4. 旧セーブ移行
5. 1600x900 / 1280x720の表示確認
6. Godot headless parseと既存テスト

## 15. 必須テスト期待値

### PP

- 通常180秒クリア: 150PP
- 通常180秒 + ボス: 225PP
- 初回枠 + 初回ボス: 350PP
- 90秒敗北: 35PP（参加5 + 継続30、ボスなし）
- ボス撃破後敗北: 参加 + 継続 + 75 + 初回条件
- 手動リタイア: 0PP
- 同じ `rewardKey`: 1回だけ
- 同じ `runId`: 1回だけ
- リレー5枠突破: 610PP（参加10 + 600、ラスボス未到達時）
- リレー完走: 960PP
- 初回リレー完走: 1,160PP

### 経済

- 戦闘強化1項目のLv5合計: 2,000PP
- サポート強化1項目のLv5合計: 1,680PP
- 全項目Lv5合計: 14,720PP
- リセット返還: 実購入価格と完全一致

### 効果

- 各強化Lv0/Lv1/Lv5
- 装備取得後もショップ補正が消えない
- 配信リレー区間移行後も値が二重適用されない
- OFF時は効果0だがPPと購入Lvは維持
- ラン中にセーブ値を書き換えても現在ランの効果は変わらない
- シンクロスターとコラボ専用回収物へ回収範囲が乗らない
- リレー休憩回復と蘇生へ回復量が乗らない
- 一時被ダメージ倍率が恒久軽減後に適用される
- ギフト進化枠と3択数が変わらない

## 16. 完成条件

- 有効な初回リザルト後にショップが解禁される。
- PPがリザルト確定時に一度だけ保存される。
- 通常・リレーの明記された報酬額と一致する。
- 8種類を5段階購入でき、全額リセットできる。
- 購入・リセットの保存失敗時にロールバックする。
- 全キャラクターへ同じラン用スナップショットが適用される。
- 装備再計算やリレー区間遷移で補正が消失・重複しない。
- タイトルとリザルトからショップへ入り、仕様どおりの画面へ戻れる。
- キーボード、ゲームパッド、マウスで全操作が完結する。
- 旧セーブを壊さず、過去プレイへPPを遡及付与しない。

