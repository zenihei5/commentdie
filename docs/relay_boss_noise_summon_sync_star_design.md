# ラストオフライン 召喚雑魚増加・シンクロスター供給 実装設計

## 1. 目的

ラストオフラインの `noise_summon` をフェーズ進行に応じた物量へ変更し、召喚ウェーブ内の1体をシンクロスター保持個体として扱う。

同時に、既存の最終ボス用BOSS PASS、コラボ技一括撃破、フェーズ移行時の召喚消去と競合して複数のスターが出ないよう、スター生成経路を一本化する。

本設計は次の既存仕様を維持する。

- 召喚雑魚は `noise_ghost_comment` を使用する。
- 経験値、スコア、ギフト、アイテム、回復は与えない。
- 通常の敵AIでプレイヤーを追跡し、生成後はボスへ追従しない。
- 同じ主攻撃を連続使用しない。
- フェーズ移行、コラボ技、ボス撃破時の既存クリーンアップを維持する。

## 2. 現在実装との差分

現在の `data/relay_mode.json` は `boss.attacks.noise_summon` に次を持つ。

- `count = 2`
- `maxActive = 4`
- `lifetime = 12`
- `contactDamage = 7`
- `reuseCooldown = 12`

現在の `_handle_noise_summon()` は、ChatModule周辺の矩形範囲へ即時生成している。

追加対応が必要な点は次のとおり。

1. 内部フェーズ番号は `0～4` であり、仕様書上の第1～第5フェーズと1つずれる。
2. `ghost_chase` は現在 `lifeTimer` を減算しないため、召喚ノイズへ値を設定するだけでは自然消滅しない。
3. `EnemySystem.apply_kill_for_target()` は `noRewards` の敵を撃破コールバック前にreturnするため、保持個体のスター生成処理を呼べない。
4. 最終ボス中のBOSS PASSは、現在すべての `relayBossSummon` を対象にスターを生成する。保持個体のドロップと併用すると1ウェーブ複数個になる。
5. コラボ技は通常雑魚を即死キューへ入れるため、撃破主体を区別しないと保持個体からスターが出てしまう。
6. `relayBossSummon` はノイズ以外のコラボブレイクコア等にも使われるため、召喚上限の集計にそのまま使用できない。
7. 主攻撃FSMは1攻撃ずつ実行するため、`collab_break` 中の追加召喚には副次ウェーブ処理が必要となる。

## 3. 設定データ

既存の設定階層を維持し、別の `lastOffline` ルートは追加しない。

`boss.attacks.noise_summon` を唯一の正規設定とする。

```json
{
  "boss": {
    "attacks": {
      "noise_summon": {
        "stage": "common",
        "movementPolicy": "mobile",
        "telegraph": 1.0,
        "activeDuration": 0.1,
        "recovery": 0.8,
        "weight": 0.8,
        "cooldownMinSeconds": 11.0,
        "cooldownMaxSeconds": 14.0,
        "enemyKind": "noise_ghost_comment",
        "enemyLifetimeSeconds": 14.0,
        "spawnWarningSeconds": 0.6,
        "spawnGraceSeconds": 0.4,
        "contactDamage": 7,
        "bossDistanceMin": 180.0,
        "bossDistanceMax": 300.0,
        "playerDistanceMin": 180.0,
        "enemySpacingMin": 50.0,
        "arenaMargin": 70.0,
        "bossBodyPadding": 28.0,
        "candidateAttemptsPerEnemy": 48,
        "phaseSettings": [
          {"phaseIndex": 0, "spawnCount": 3, "activeCap": 5},
          {"phaseIndex": 1, "spawnCount": 4, "activeCap": 6},
          {"phaseIndex": 2, "spawnCount": 4, "activeCap": 7},
          {"phaseIndex": 3, "spawnCount": 5, "activeCap": 8},
          {"phaseIndex": 4, "spawnCount": 6, "activeCap": 10}
        ],
        "collabBreakSpawnMultiplier": 0.75,
        "postSummonProtectedAttackSeconds": 2.0,
        "postProtectedAttackSummonSeconds": 1.0,
        "protectedAttackIds": [
          "offline_laser",
          "game_over_barrage",
          "howling_ring",
          "eraser_sweep",
          "paint_warning",
          "all_genre_rush"
        ],
        "syncStar": {
          "enabled": true,
          "maxCarrierCount": 1,
          "maxDropPerWave": 1,
          "normalCooldownSeconds": 18.0,
          "finalPhaseCooldownSeconds": 14.0,
          "iconPath": "res://assets/generated/field_pickup_icons_v1/icons/sync_star.png",
          "dropAllowedOwners": ["player", "partner"],
          "dropOnNaturalDespawn": false,
          "dropOnForcedClear": false,
          "dropOnCollabSkillClear": false
        }
      }
    }
  }
}
```

互換用の `count`、`maxActive`、`lifetime`、`reuseCooldown` は読み込み側のフォールバックとしてのみ残してよい。新実装では上記の設定を優先する。

## 4. 実行時状態

`RelayBossAttackSystem.empty_runtime()` に次を追加する。

```gdscript
{
    "noise_summon_cooldown": 0.0,
    "noise_summon_after_wave_lock": 0.0,
    "noise_summon_after_protected_attack_lock": 0.0,
    "noise_summon_wave_serial": 0,
    "noise_summon_pending_wave": {},
    "sync_star_drop_cooldown": 0.0,
    "sync_star_carrier_uid": -1
}
```

各タイマーはゲームプレイ時間で減算する。フェーズ移行・コラボ技演出による停止中は減算しない。

`noise_summon_pending_wave` は次を持つ。

```gdscript
{
    "waveId": 12,
    "source": "main_attack",
    "phaseIndex": 3,
    "positions": [Vector2(...), Vector2(...)],
    "warningTimer": 0.6,
    "spawned": false
}
```

予兆位置は予約枠ではない。実生成時に上限を再確認し、空き枠を超える位置は破棄する。

## 5. 召喚対象の識別

ノイズ召喚個体へ次を設定する。

```gdscript
enemy["relayBossSummon"] = true
enemy["relayBossNoiseSummon"] = true
enemy["relayBossSummonWaveId"] = wave_id
enemy["relayBossSummonSource"] = "main_attack" # または "collab_break_sidecar", "travel_support"
enemy["relayBossSummonLifetime"] = 14.0
enemy["spawnGraceTimer"] = 0.4
enemy["contactDamage"] = 7
enemy["noRewards"] = true
enemy["score"] = 0
enemy["exp"] = 0
enemy["expDrop"] = 0
enemy["giftHypeReward"] = 0
enemy["itemDrop"] = false
enemy["healDrop"] = false
```

`relayBossNoiseSummon` を同時存在数の集計キーにする。

`relayBossSummon` だけを集計すると、コラボブレイクコアや他の攻撃専用オブジェクトまで上限へ含まれるため使用しない。

有効個体数は次を除外して数える。

- `defeatPending`
- `defeatResolved`
- `relayBossSummonLifetime <= 0`

## 6. フェーズ別召喚数

内部の `relay_boss_phase` をそのまま `phaseIndex` として使用する。

| 内部phaseIndex | 表示フェーズ | spawnCount | activeCap |
| ---: | --- | ---: | ---: |
| 0 | 雑談 | 3 | 5 |
| 1 | ゲーム実況 | 4 | 6 |
| 2 | 歌 | 4 | 7 |
| 3 | お絵かき | 5 | 8 |
| 4 | コラボ・最終 | 6 | 10 |

実生成数は次で求める。

```gdscript
var available := maxi(0, active_cap - active_noise_count)
var actual_count := mini(requested_count, available)
```

`actual_count` が0の場合はウェーブを作らない。生成できなかった数を後から予約しない。

## 7. 攻撃候補の除外

`_pick_and_begin()` で `noise_summon` を候補へ追加する前に、専用の `can_start_noise_summon()` を通す。

次の場合は候補から除外する。

- `noise_summon_cooldown > 0`
- 現在フェーズの `activeCap` に到達している
- フェーズ移行中
- ボス高速位置変更中
- `all_genre_rush` 中
- コラボ技のready、cutin、post中
- ボス撃破処理中
- `noise_summon_after_protected_attack_lock > 0`
- 既に `noise_summon_pending_wave` が存在する

主攻撃の `noise_summon` が実際に1体以上生成された時点で、次を設定する。

```gdscript
runtime["noise_summon_cooldown"] = rng.randf_range(
    cooldown_min_seconds,
    cooldown_max_seconds
)
runtime["noise_summon_after_wave_lock"] = post_summon_protected_attack_seconds
```

従来の固定 `reuseCooldown = 12` を召喚時刻の基準にしない。

上限競合などで実生成数が0になった場合、11～14秒のクールダウンは開始しない。同一攻撃連続禁止により直後の再抽選は防げる。

## 8. 大型攻撃との排他

既存の `large` フラグではなく、設定の `protectedAttackIds` を使用する。

仕様上、`collab_break` と `rhythm_explosion` はこの排他リストへ含めない。

### 召喚後

`noise_summon_after_wave_lock > 0` の間、`protectedAttackIds` の攻撃を候補から除外する。

タイマーは実際にウェーブを生成した時点から2秒で開始する。`noise_summon` 自身のrecovery時間もこの2秒へ含む。

### 大型攻撃後

`protectedAttackIds` の攻撃がrecoveryを完了してIDLEへ戻る時点で、

```gdscript
runtime["noise_summon_after_protected_attack_lock"] = 1.0
```

を設定する。

これにより「大技の実動作が終わったが、recovery中に1秒が消費される」状態を避ける。

## 9. コラボブレイク中の副次ウェーブ

主攻撃FSMは同時に1攻撃しか持てないため、`collab_break` 中の召喚は `active_attack` を上書きしない副次ウェーブとして扱う。

`collab_break` のACTIVE開始時、次をすべて満たす場合だけ1回ウェーブを予約する。

- 召喚クールダウン終了
- activeCap未満
- 保留中ウェーブなし
- ボス撃破状態ではない

召喚数は次で決める。

```gdscript
var requested := maxi(1, floori(float(base_spawn_count) * 0.75))
```

四捨五入ではなく切り捨てを採用する。最終フェーズの `6 * 0.75 = 4.5` を仕様例どおり4体にするためである。

activeCapは通常値を維持する。

副次ウェーブも通常ウェーブと同じ予兆、配置、接触猶予、スター保持判定、11～14秒クールダウンを使用する。

`collab_break` は `protectedAttackIds` に含めないため、この副次ウェーブを許可する。

## 10. 巡航中の補助召喚

主攻撃 `noise_summon` は `movementPolicy = mobile` のため、CRUISING中も通常抽選できる。

既存の `travel_noise_summon` は次のルールへ合わせる。

- `relayBossNoiseSummon` のactiveCapへ含める。
- スター保持個体を生成しない。
- 同じ安全配置判定と0.4秒の接触猶予を使用する。
- 0.6秒の予兆を出せない場合は生成せず `travel_noise_shot` へフォールバックする。
- 主ウェーブの保留中、フェーズ移行中、コラボ技中、ボス撃破中は生成しない。

補助召喚がactiveCapを迂回して敵数を増やさないことを必須とする。

## 11. 召喚位置

ウェーブの予兆開始時に位置候補を決める。

1. ボス中心から180～300pxの円周または半円周へ候補を作る。
2. プレイヤーから180px未満を除外する。
3. 既に選んだ候補から50px未満を除外する。
4. 既存の有効な召喚ノイズから50px未満を除外する。
5. ボス中央接触円と `bossBodyPadding` を加えた範囲を除外する。
6. `arenaMargin` を除いたアリーナ内に収める。
7. `EnemySystem.movement_wall_rects()` と `spawn_position_blocked_by_walls()` で障害物内を除外する。
8. 画面端でプレイヤーの退路を塞ぐ候補を除外する。

各個体につき最大48回候補を試す。見つからなければその個体の生成を諦め、中央やプレイヤー付近へ強制配置しない。

半円配置を使う場合は、プレイヤーがいる方向と反対側を優先する。

## 12. 出現予兆

`noise_summon` の主テレグラフ1.0秒は維持する。

残り時間が `spawnWarningSeconds = 0.6` 以下になった時点で、召喚位置を決定して `noise_summon_pending_wave` へ保存する。

`RelayBossDrawSystem` は保留位置ごとに次を描画する。

- 小さなノイズ円
- 内側へ縮むピンク・水色のリング
- 中心の黒紫ノイズ片
- 残り0.15秒で点滅を速める

主テレグラフ終了時に、保存済み位置から実生成する。

実生成直前にもactiveCapを確認し、空き枠数を超える位置は末尾から破棄する。

## 13. 自然消滅

`ghost_chase` の通常AI処理とは別に、`relayBossNoiseSummon` を持つ敵だけ次を毎フレーム処理する。

```gdscript
enemy["relayBossSummonLifetime"] -= delta
if enemy["relayBossSummonLifetime"] <= 0.0:
    enemy["removeReason"] = "natural_despawn"
    enemy["defeatResolved"] = true
```

自然消滅では次を行わない。

- `queue_defeat_for_enemy()`
- `apply_kill_for_target()`
- 撃破数加算
- 撃破SE
- スタードロップ
- 経験値、スコア、ギフト等の報酬

自然消滅時は短いノイズフェードだけ表示してよい。

## 14. 撃破主体と消滅理由

敵へ次の実行時フィールドを追加する。

```gdscript
enemy["lastHitOwner"] = ""
enemy["defeatOwner"] = ""
enemy["removeReason"] = ""
```

所有者は次の固定値を使用する。

- `player`: プレイヤー武器、プレイヤー由来の通常攻撃
- `partner`: すぱな・まろん・ばんり等の相方支援攻撃
- `collab_skill`: BAN☆スターラッシュ等の画面攻撃
- `environment`: ステージギミック、時間切れ
- `debug`: デバッグ削除

`WeaponSystem._apply_enemy_hit()` は通常プレイヤー武器の命中時に `lastHitOwner = "player"` を設定し、撃破時に `defeatOwner = "player"` を設定する。

`_song_apply_enemy_damage()` は攻撃元を分類し、相方支援なら `partner`、`collab_pair_` で始まるソースなら `collab_skill` を設定する。

未知の攻撃元はスター生成を許可しない。文字列の部分一致だけでプレイヤー撃破と推測しない。

強制削除では `defeatOwner` を設定せず、必要に応じて `removeReason` だけを設定する。

## 15. スター保持個体

実生成数が1体以上で、次をすべて満たす場合だけ、ウェーブ最後の個体を保持個体にする。

- `syncStar.enabled`
- HUD内のスター、転送中スター、フィールド上スターを合計して必要数未満
- 有効な保持個体が存在しない
- `sync_star_drop_cooldown <= 0`
- ボス撃破状態ではない

予約済みスター数は次で数える。

```gdscript
reserved_stars =
    collab_sync_stars
    + collab_sync_star_transfers.size()
    + active_uncollected_sync_star_pickups
```

保持個体へ次を設定する。

```gdscript
enemy["syncStarCarrier"] = true
enemy["syncStarCarrierWaveId"] = wave_id
enemy["syncStarCarrierRevealTimer"] = 0.45
runtime["sync_star_carrier_uid"] = enemy["uid"]
```

保持個体は常に最大1体とする。

UIDはデバッグと高速参照用であり、正規状態は敵配列の有効個体を走査して確認する。自然消滅や強制削除後にUIDだけ残っていても、新しい保持個体を永久に阻害しないよう毎更新で整合させる。

## 16. 保持個体の表示

敵はNodeではなくDictionaryとCanvas描画で管理されているため、子ノードは追加しない。

`EnemyDrawSystem` に保持個体専用のオーバーレイ描画を追加する。

- `syncStar.iconPath` の既存画像を頭上へ32～38pxで表示
- 淡い黄色と水色の発光
- 薄いピンクの輪郭
- 緩い上下浮遊
- 出現後0.45秒だけキラキラ粒子と拡大演出

通常の敵画像、HP、当たり判定は変更しない。

予兆中の保持個体はまだ確定していないため、スター表示は実生成後にのみ出す。

## 17. スタードロップ処理

`EnemySystem.apply_kill_for_target()` の `noRewards` 早期returnより前に、最終ボス召喚撃破通知を行う。

```gdscript
if bool(enemy.get("relayBossNoiseSummon", false)):
    target.call("_on_relay_boss_noise_summon_defeated", enemy)
```

通知側は次をすべて満たす時だけスターを1個生成する。

- `syncStarCarrier == true`
- `defeatOwner` が `player` または `partner`
- `removeReason` が空、または `combat_defeat`
- ボスが撃破状態ではない
- 予約済みスター数が必要数未満
- 同じ敵でドロップ済みではない

成功時に次を行う。

```gdscript
enemy["syncStarDropped"] = true
_spawn_collab_sync_star_pickup(enemy["pos"])
runtime["sync_star_drop_cooldown"] = (
    final_phase_cooldown if relay_boss_phase == 4
    else normal_phase_cooldown
)
runtime["sync_star_carrier_uid"] = -1
```

通常フェーズは18秒、最終フェーズは14秒とする。

クールダウンは保持個体生成時ではなく、`_spawn_collab_sync_star_pickup()` が成功した時点から開始する。

保持個体が自然消滅・強制消去された場合はクールダウンを開始しない。次に実行可能な召喚ウェーブで再判定する。

## 18. BOSS PASSとの統合

現在の最終ボスBOSS PASSは、すべての `relayBossSummon` を対象にし、成功時に直接スターを生成する。

新仕様有効時は次へ変更する。

1. 最終ボス中の `_collab_pick_pass_target()` は、有効な `syncStarCarrier` のみをBOSS PASS候補にする。
2. 保持個体がいない場合はBOSS PASSを開始しない。
3. `_complete_collab_pass()` は最終ボス中にスターを直接生成しない。
4. スター生成は `_on_relay_boss_noise_summon_defeated()` の1経路だけで行う。
5. BOSS PASS成功数、表示、チャットは従来どおり更新してよい。

これにより、BOSS PASS対象の保持個体を倒しても、PASS報酬と保持個体報酬が二重に出ない。

相方が保持個体を倒した場合もスターは出るが、BOSS PASS成功にはしない。

## 19. コラボ技・強制消去

コラボ技の `_queue_collab_combo_instant_kill()` は、

```gdscript
enemy["defeatOwner"] = "collab_skill"
enemy["removeReason"] = "collab_skill_clear"
```

を設定してから撃破キューへ入れる。

保持個体であってもスターを生成しない。

次の削除経路でもスターを生成しない。

- フェーズ移行: `removeReason = "phase_transition_clear"`
- ボス撃破: `removeReason = "boss_defeat_clear"`
- ステージ終了: `removeReason = "stage_end_clear"`
- デバッグ: `removeReason = "debug_clear"`
- 自然消滅: `removeReason = "natural_despawn"`

直接配列から除去する経路は撃破通知を呼ばない。保持UIDは次回更新の整合処理で解除する。

## 20. 接触判定

召喚個体の接触ダメージは7とする。

生成直後は `spawnGraceTimer = 0.4` を設定する。

`EnemySystem.update_enemies()` の接触判定へ次を追加する。

```gdscript
if float(enemy.get("spawnGraceTimer", 0.0)) > 0.0:
    continue
```

現在は `spawnGraceTimer` を減算しているが、通常接触判定で参照していないため、明示的に除外する。

## 21. クリーンアップ

次の開始・終了時に、保留中ウェーブと保持UIDをクリアする。

- 最終ボス開始
- フェーズ移行開始
- コラボ技開始
- ボス撃破
- プレイヤー敗北
- リレー終了
- デバッグ再開始

`sync_star_drop_cooldown` はフェーズ移行では維持する。フェーズをまたいで供給制限を回避できないようにする。

最終ボス戦そのものが終了した場合は0へ戻す。

## 22. デバッグ表示

既存の最終ボスデバッグオーバーレイへ次を追加する。

```text
NOISE phase:4 count:6 cap:8/10 cd:7.2
WAVE pending:4 warning:0.3 source:main_attack
STAR carrier:123 dropCd:11.8 reserved:2/3
LOCK summon->large:1.2 large->summon:0.0
```

F11等の強制 `noise_summon` でもactiveCap、配置安全性、保持個体最大1体を無視しない。

## 23. 実装対象

主な変更対象は次とする。

- `data/relay_mode.json`
- `scripts/systems/relay_boss_attack_system.gd`
- `scripts/systems/relay_boss_system.gd`
- `scripts/systems/relay_boss_draw_system.gd`
- `scripts/systems/enemy_system.gd`
- `scripts/systems/enemy_draw_system.gd`
- `scripts/systems/weapon_system.gd`
- `scripts/game.gd`

大規模な敵システム再設計は行わず、既存Dictionaryモデルと攻撃FSMへ小さく接続する。

## 24. 検証

### 自動確認

- `python -m json.tool data/relay_mode.json`
- Godotの `--check-only --script` で変更GDScriptを検査
- Godot headless起動
- `git diff --check`

### 手動確認

1. phaseIndex 0で3体、上限5体になる。
2. phaseIndex 1で4体、上限6体になる。
3. phaseIndex 2で4体、上限7体になる。
4. phaseIndex 3で5体、上限8体になる。
5. phaseIndex 4で6体、上限10体になる。
6. 空き枠が2体なら2体だけ生成し、後から残りが出ない。
7. 召喚間隔が実生成時点から11～14秒になる。
8. 0.6秒の位置予兆後に生成される。
9. プレイヤーから180px未満、障害物内、ボス中央判定内へ生成されない。
10. 生成後0.4秒は接触ダメージが発生しない。
11. 14秒で自然消滅し、撃破報酬やスターが出ない。
12. 条件を満たすウェーブの最後の1体だけが保持個体になる。
13. 保持個体が同時に2体存在しない。
14. プレイヤー撃破でスターが1個出る。
15. 相方撃破でスターが1個出る。
16. コラボ技撃破ではスターが出ない。
17. フェーズ移行・ボス撃破・デバッグ削除でスターが出ない。
18. BOSS PASS対象撃破でもスターが二重に出ない。
19. 通常フェーズのドロップ後18秒、最終フェーズでは14秒再供給されない。
20. スター最大時とフィールド上の未回収スター込みで供給過多にならない。
21. 召喚後2秒は指定大技が開始しない。
22. 指定大技のrecovery完了後1秒は召喚しない。
23. `collab_break` 中は0.75倍を切り捨てた召喚数で副次ウェーブが出る。
24. `all_genre_rush`、高速位置変更、コラボ技演出、フェーズ移行中は召喚されない。

## 25. 完了条件

- フェーズ進行に応じて召喚密度が増える。
- 召喚上限を超過せず、未生成分を予約しない。
- 召喚位置と接触猶予により理不尽な即被弾がない。
- 召喚ノイズが14秒で確実に自然消滅する。
- スター保持個体が視覚的に判別できる。
- スター生成経路が保持個体撃破へ一本化される。
- 1ウェーブから複数スターが生成されない。
- コラボ技消去から次のコラボ技へ無限循環しない。
- 既存の経験値、スコア、ギフト、回復報酬を増やさない。
