# 配信リレー後半・ラストオフライン調整実装設計

## 1. 目的

配信リレーのお絵かき枠・コラボ枠だけ戦闘密度を上げ、敵撃破率70%程度の標準プレイで各枠1～2回、2枠合計2～3回以上のレベルアップ機会を作る。

同時に、最終ボス「ラストオフライン」の最大HPを現在値の2倍へ増やし、完成済みの攻撃FSMを保ったまま、常時浮遊・位置変更・フェーズ別移動を追加する。

通常モードのお絵かき枠・コラボ枠、敵1体ごとのHP・攻撃力・経験値、最終ボスの攻撃ダメージは変更しない。

## 2. 現状監査

### 後半2枠

- `RelayStageProfileSystem` は時間帯別の出現倍率を返せるが、追加出現数、全体敵数上限、チャレンジ中の倍率変更を表現できない。
- `SpawnerSystem` は出現倍率を出現間隔へ適用するだけで、1回ごとの追加出現数と全体上限を持たない。
- 全敵共通の「既存最大同時数」は現行コードに存在しない。遠距離・拡散弾・突進・待ち伏せ敵の危険度別上限だけがある。
- 通常スポーナーは、お絵かきギミック中やコラボチャレンジ中も原則更新されている。完全停止を新たに入れる必要はない。
- お絵かき枠とコラボ枠には既にリレー用HP・速度補正がある。今回はこの値を変更しない。

### ラストオフライン

- 最大HPは現在1200。今回の初期調整値は2400とする。
- 攻撃は17種類の専用FSMへ分離済みだが、ボス本体は速度0で中央に静止している。
- 攻撃予告の一部はボス現在位置を起点とするため、移動を単純追加すると予告と実判定がずれる可能性がある。
- ボス接触ダメージは現在0。移動追加後も0を維持する。
- 敵描画は通常の敵描画経路を使うため、浮遊用の描画オフセット・傾き・拡縮を明示的に受け渡す必要がある。

## 3. 実装責務

### `RelayStageProfileSystem`

- リレー限定後半バランス設定の読み込み
- 0～30秒、30～90秒、90～120秒の時間帯選択
- 基本出現量、出現間隔、追加出現数、敵上限の計算
- お絵かき強演出中、コラボチャレンジ中の圧力補正

### `SpawnerSystem`

- 1回の出現数へ追加出現数を加算
- 全体敵数上限の残り枠内だけ生成
- 後半枠専用の敵カテゴリ抽選
- 出現要求数、実出現数、上限停止回数のデバッグ記録

### `EnemySystem`

- 後半枠専用の低耐久・標準・強敵カテゴリ定義
- 既存の危険敵上限と種類別上限の維持
- 通常ウェーブ由来の敵へ `spawnSource = "normal_wave"` を付与

### 新規 `RelayBossMovementSystem`

- ボス移動FSM
- フェーズ別の移動パターン
- アンカー選択、移動範囲、障害物回避
- 攻撃FSMの状態に応じた移動停止
- 浮遊、傾き、拡縮などの描画用パラメータ生成

### `RelayBossSystem` / `RelayBossAttackSystem`

- 移動FSMの更新呼び出し
- 攻撃ごとの移動ポリシー
- 大技前の所定位置への移動
- フェーズ移行時の中央復帰

## 4. 後半枠の設定データ

`data/relay_mode.json` に次の設定を追加する。

```json
{
  "relayStageBalance": {
    "baseActiveEnemyCap": 20,
    "drawing": {
      "spawnAmountMultiplier": 1.35,
      "activeEnemyCapMultiplier": 1.4,
      "minimumCapIncrease": 8,
      "heavyGimmickSpawnAmountMultiplier": 1.1,
      "timePhases": [
        {"start": 0, "end": 30, "spawnIntervalMultiplier": 0.9, "additionalSpawnCountMin": 0, "additionalSpawnCountMax": 0},
        {"start": 30, "end": 90, "spawnIntervalMultiplier": 0.75, "additionalSpawnCountMin": 1, "additionalSpawnCountMax": 1},
        {"start": 90, "end": 120, "spawnIntervalMultiplier": 0.65, "additionalSpawnCountMin": 1, "additionalSpawnCountMax": 2}
      ],
      "enemyTiers": {
        "low": {"weight": 0.65, "kinds": ["drawing_fix_note", "layer_lost"]},
        "standard": {"weight": 0.3, "kinds": ["drawing_fix_note", "layer_lost"]},
        "strong": {"weight": 0.05, "kinds": ["bucket_fill_slime"]}
      }
    },
    "collab": {
      "spawnAmountMultiplier": 1.5,
      "activeEnemyCapMultiplier": 1.6,
      "minimumCapIncrease": 12,
      "challengeSpawnAmountMultiplier": 1.15,
      "timePhases": [
        {"start": 0, "end": 30, "spawnIntervalMultiplier": 0.85, "additionalSpawnCountMin": 1, "additionalSpawnCountMax": 1},
        {"start": 30, "end": 90, "spawnIntervalMultiplier": 0.7, "additionalSpawnCountMin": 1, "additionalSpawnCountMax": 1},
        {"start": 90, "end": 120, "spawnIntervalMultiplier": 0.6, "additionalSpawnCountMin": 2, "additionalSpawnCountMax": 2}
      ],
      "enemyTiers": {
        "low": {"weight": 0.6, "kinds": ["collab_comparison_troll", "collab_messenger_pigeon"]},
        "standard": {"weight": 0.3, "kinds": ["collab_discord_troll", "collab_volume_police"]},
        "strong": {"weight": 0.1, "kinds": ["collab_exclusive_listener"]}
      }
    }
  }
}
```

現行に全体上限がないため、初期の基準値を20体として設定化する。この値は性能計測後にデータだけで変更可能にする。

初期上限は次のとおり。

- お絵かき枠: `max(roundi(20 * 1.40), 20 + 8) = 28体`
- コラボ枠: `max(roundi(20 * 1.60), 20 + 12) = 32体`

## 5. 出現倍率の適用式

後半2枠では既存の `relaySpawnCurves` と新設定を重ね掛けしない。新しい `relayStageBalance` を最終値として使い、意図しない二重増加を防ぐ。

```text
effective_interval
  = base_interval
  * time_phase.spawnIntervalMultiplier
  / current_spawn_amount_multiplier
```

`current_spawn_amount_multiplier` は次の優先順位で決める。

1. コラボチャレンジの `starting` または `active`: 1.15
2. お絵かき枠の強い演出・操作制限中: 1.10
3. 通常のお絵かき枠: 1.35
4. 通常のコラボ枠: 1.50

チャレンジの `success` / `failed` 結果表示へ移った時点で通常値1.50へ戻す。`collab_challenge_status != "idle"` 全体を減速条件にしない。

1回の要求出現数は次で決める。

```text
requested_count = existing_base_count + randomi(additionalSpawnCountMin, additionalSpawnCountMax)
actual_count = min(requested_count, active_cap - active_normal_wave_count)
```

上限到達中もスポーンタイマーは通常どおり次回値へ更新し、毎フレーム再試行しない。

## 6. 敵数上限と対象範囲

上限へ数えるのは `spawnSource = "normal_wave"` の生存敵だけとする。

次は上限に含めない。

- ボス
- 最終ボス召喚
- コラボチャレンジ専用敵
- ジャンルイベント専用敵
- コメント連動で個別生成された敵

通常ウェーブの出現処理は、生成成功後に対象へ `spawnSource = "normal_wave"` を付ける。上限判定は `defeatPending` / `defeatResolved` の敵を除外する。

全体上限とは別に、既存の危険度別上限を必ず維持する。

- 遠距離敵上限
- 拡散弾敵上限
- 突進敵上限
- 待ち伏せ敵上限
- お絵かきの赤ペン先生上限
- コラボ敵の種類別上限

候補が種類別上限に達している場合は、同じティア内で再抽選する。8回失敗したら1段階低い脅威ティアへ落とし、それでも候補がなければその1体分の生成を見送る。強敵へ繰り上げない。

## 7. 敵構成

### お絵かき枠

増加分は処理しやすい敵を中心にする。

- 低耐久: 修正指示コメント、レイヤー迷子
- 標準: 同じ2種類を再抽選し、見た目の偏りだけ抑える
- 強敵: バケツ塗りスライムを最大5%
- 赤ペン先生は増加分の候補に入れず、既存の通常抽選と上限だけで出す

これにより、遠距離弾と減速床が物量倍率と同じ比率で増えることを防ぐ。

### コラボ枠

通常ウェーブ全体を60% / 30% / 10%のティア抽選へ切り替える。

- 低耐久60%: 比較厨、伝書鳩
- 標準30%: 不仲煽り、音量警察
- 強敵10%: 独占リスナー

伝書鳩は低HPだが突進敵なので、既存の突進敵上限を優先する。上限到達時は比較厨へ寄せる。強敵ティアが種類別上限で生成できない場合、標準または低耐久へ落とす。

敵1体のHP、攻撃力、接触ダメージ、経験値は変更しない。

## 8. ギミック・チャレンジ中の扱い

### お絵かき枠

通常スポーンを停止しない。

強い演出や操作制限だけを判定する小さな問い合わせ関数をゲーム側に用意する。

```gdscript
func _relay_drawing_spawn_pressure_reduced() -> bool:
    return drawing_showcase_time_timer > 0.0 or drawing_finish_sequence_active
```

実際の変数名は現行実装へ合わせる。塗り・囲い操作そのものは減速条件にせず、画面を大きく覆う演出や入力制限中だけ1.10へ下げる。

### コラボ枠

`collab_challenge_status` が `starting` または `active` の間だけ1.15へ下げる。敵全消去は行わず、既存敵を維持する。

チャレンジ専用敵は通常ウェーブ上限に含めないが、危険敵の画面占有が過剰にならないよう、通常ウェーブ側の危険度上限は引き続き適用する。

## 9. レベルアップ目標と計測

経験値単価を変更せず、次を枠開始時から終了時まで記録する。

- 要求出現数
- 実出現数
- 上限で見送った数
- ティア別・種類別の実出現数
- 撃破数
- 敵からドロップした経験値合計
- 回収した経験値合計
- レベルアップ回数
- 最大同時敵数
- 最大敵弾数

デバッグ結果へ `relayStageBalance` セクションを追加し、枠終了時に1行で出力できるようにする。

初期調整では標準ビルド相当で各枠を3回以上プレイし、次を確認する。

- 撃破率がおよそ70%の回で各枠1～2レベル上がる。
- 2枠合計で平均2～3回以上レベルアップする。
- 不足時は `spawnAmountMultiplier`、時間帯倍率、上限の順で調整する。
- 経験値単価の増加は第二段階まで行わない。

## 10. ラストオフライン設定

`boss` 配下へ次を追加・変更する。

```json
{
  "maxHp": 2400.0,
  "contactDamage": 0,
  "movement": {
    "hoverAmplitude": 6.0,
    "hoverCycleSeconds": 1.4,
    "tiltDegrees": 1.5,
    "tiltCycleSeconds": 2.0,
    "repositionSpeed": 120.0,
    "finalRepositionSpeed": 150.0,
    "repositionMaxIntervalSeconds": 5.0,
    "repositionArrivalDistance": 8.0,
    "phaseTransitionCenterTime": 0.7,
    "resumeDelayMin": 0.3,
    "resumeDelayMax": 0.5,
    "moveBounds": {"left": 0.15, "right": 0.85, "top": 0.18, "bottom": 0.72},
    "phaseMoveSpeeds": [45.0, 55.0, 60.0, 65.0, 75.0],
    "phaseRepositionAttackCounts": [[2, 3], [2, 2], [2, 2], [2, 2], [1, 2]]
  }
}
```

HPだけを1200から2400へ変更する。攻撃ダメージ、召喚ダメージ、指示コメ、コンビ技ダメージ率、コラボブレイク必要ダメージ率は変更しない。割合ダメージ・割合HPは新しい最大HPから計算する。

## 11. ボス移動FSM

```gdscript
enum BossMovementState {
    HOVER,
    REPOSITION,
    ATTACK_LOCK,
    PHASE_TRANSITION,
    STUNNED,
    DEAD
}
```

`relay_boss_runtime` へ次を追加する。

```gdscript
"movement": {
    "state": BossMovementState.HOVER,
    "target": Vector2.ZERO,
    "anchor_id": "center",
    "previous_anchor_id": "",
    "time_since_reposition": 0.0,
    "attacks_since_reposition": 0,
    "resume_timer": 0.0,
    "pattern_time": 0.0,
    "visual_offset": Vector2.ZERO,
    "visual_rotation": 0.0,
    "visual_scale": 1.0,
    "shadow_scale": 1.0
}
```

### `HOVER`

- フェーズ別の通常移動を行う。
- 攻撃抽選可能。
- 攻撃完了回数と前回位置変更からの時間を数える。

### `REPOSITION`

- 選択したアンカーへ100～140px/秒、最終フェーズは最大150px/秒で移動する。
- 大技を抽選しない。
- 移動時間は0.7～1.2秒を目標にし、到達距離8px以内で終了する。
- 必要ならコメント散弾・ノイズ召喚だけを許可するが、初期実装では移動完了まで攻撃タイマーを止めてもよい。

### `ATTACK_LOCK`

- 位置固定を必要とする攻撃の予兆・発動中に実座標を止める。
- 浮遊の描画オフセットだけは継続できる。
- 攻撃終了後0.3～0.5秒待って `HOVER` へ戻る。

### `PHASE_TRANSITION`

- 攻撃終了と攻撃物消去後、中央アンカーへ約0.7秒で移動する。
- 中央到着後に既存の1.5秒フェーズ演出を開始する。
- 中央移動中はボス無敵を新設しない。既存フェーズ演出中のダメージ停止仕様は維持する。

### `STUNNED`

- コンビ技などで攻撃が中断された時に移動停止する。
- 演出終了後、HP閾値を再評価してフェーズ移行または `HOVER` へ戻る。

### `DEAD`

- 移動・攻撃・浮遊タイマーを停止し、勝利演出へ渡す。

## 12. アンカーと安全な移動範囲

アンカーはアリーナ比率で定義する。

- 中央: (0.50, 0.45)
- 中央左: (0.32, 0.45)
- 中央右: (0.68, 0.45)
- 上側左: (0.28, 0.27)
- 上側右: (0.72, 0.27)
- 下側左: (0.30, 0.65)
- 下側右: (0.70, 0.65)

実際の移動範囲は横15～85%、縦18～72%へクランプする。ボス半径と壁余白を含め、静的壁・一時壁の中へ入る候補は除外する。

次のアンカーは、現在位置からボス直径の1.25倍以上離れた候補を優先する。同じアンカーを連続選択しない。有効候補がない場合は中央へ戻す。

高速位置変更中は接触ダメージ0を維持する。プレイヤーと重なる軌道を選んでもダメージは発生しない。

## 13. フェーズ別移動

### 第1フェーズ: 雑談

- 45px/秒。
- 中央付近を左右へ緩く往復する。
- 攻撃2～3回または5秒経過でアンカー変更。
- プレイヤー追尾はしない。

### 第2フェーズ: ゲーム実況

- 55px/秒。
- 斜めアンカー移動と短い加速を使う。
- 攻撃2回ごとに位置変更。
- `race_lane_charge` は左右端の専用アンカーへ移動してから開始し、終了後は中央寄りへ戻る。

### 第3フェーズ: 歌

- 60px/秒。
- アリーナ中央を中心に、横半径140px・縦半径90px程度の緩い円運動。
- `howling_ring` と `rhythm_explosion` の予兆開始前に停止する。

### 第4フェーズ: お絵かき

- 65px/秒。
- 左右端と上下アンカーを切り替える。
- `eraser_sweep` は左端または右端へ移動してから開始する。
- `paint_warning` の予告開始から停止する。

### 第5フェーズ: コラボ・最終

- 75px/秒、位置変更は150px/秒。
- 攻撃1～2回ごとに短いジグザグ、斜め前への回り込み、左右移動を選ぶ。
- プレイヤー座標は進行方向の参考にするだけで、常時追尾しない。
- `all_genre_rush` は中央へ移動してから開始する。

## 14. 攻撃と移動の接続

各攻撃へ `movementPolicy` と任意の `requiredAnchor` を追加する。

### 移動中でも使用可能

- `comment_shotgun`
- `noise_summon`

`movementPolicy = "mobile"` とする。予告起点は毎フレームのボス実座標へ追従し、発射時に確定する。

### 照準確定時に停止

- `offline_laser`

`movementPolicy = "lock_on_aim_commit"` とする。追尾予告中は移動可能だが、照準角度を固定する瞬間に `ATTACK_LOCK` へ入る。

### 予兆開始から停止

- `kuso_maro_drop`
- `long_comment_line`
- `game_over_barrage`
- `howling_ring`
- `pitch_wave`
- `rhythm_explosion`
- `dirty_paint`
- `paint_warning`
- `division_noise`
- `collab_break`

`movementPolicy = "lock_on_telegraph"` とする。予兆開始時に起点と危険範囲を確定し、攻撃終了まで実座標を固定する。

### 所定位置へ移動してから開始

- `race_lane_charge`: 左右端
- `eraser_sweep`: 左右端
- `all_genre_rush`: 中央

`movementPolicy = "reposition_then_lock"` とする。攻撃抽選時に `pending_attack_id` と `requiredAnchor` を保持し、到着後に攻撃FSMの `TELEGRAPH` を開始する。

攻撃FSMは `REPOSITION` 中の大技を候補から除外する。予兆開始後にボス位置を動かす場合は、予告描画と判定生成の両方が同じ起点を参照する。

## 15. フェーズ移行順序

次の順序で固定する。

1. 現在の攻撃を完了する。
2. ボス弾、攻撃ハザード、召喚物を消去する。
3. 移動FSMを `PHASE_TRANSITION` にし、中央へ約0.7秒で移動する。
4. 中央到着後にフェーズ番号とテーマを更新する。
5. 既存の1.5秒フェーズ演出を再生する。
6. 新フェーズの移動パターンを `HOVER` から開始する。

コンビ技で複数閾値を飛び越えた場合は、最深到達フェーズへ1回だけ遷移する。中央移動中に新しい攻撃や指示コメを開始しない。

## 16. ボス画像の簡易アニメーション

当たり判定へ影響しない描画用パラメータとして実装する。

### 通常時

- 上下オフセット: ±6px、1往復1.4秒
- 傾き: ±1.5度、1往復2.0秒
- 影: 上下動と逆位相で0.96～1.04倍
- コア: 弱い明滅。1枚絵の中央付近へコード描画の発光を重ねる

### 攻撃予兆

- 本体スケール1.04倍
- コア発光を強める
- 0.15秒の小さな振動
- 毎フレーム位置をランダム化せず、攻撃serialから決めた位相で再現可能にする

### 被弾

- 既存の白フラッシュ0.08～0.12秒を維持する
- 通常被弾ごとの大きな画面揺れは追加しない

### フェーズ移行

- ノイズエフェクト
- フェーズテーマ色への発光変更
- 一度だけ強い上下動
- 1枚絵のため、周囲5パーツの別回転は素材が分離された時の拡張項目とする

`EnemyDrawSystem` に汎用変形を入れる場合は、`visualOffset`、`visualRotation`、`visualScale`、`shadowScale` を指定した敵だけへ適用する。通常敵の描画を変えない。

## 17. デバッグと検証

### デバッグ表示

既存の最終ボスデバッグ表示へ次を追加する。

- 移動状態
- 現在アンカーと次アンカー
- 移動速度
- 攻撃後回数
- 位置変更までの残り時間
- `pending_attack_id`
- 実座標と描画オフセット後の座標

後半枠のバランス表示へ次を追加する。

- 現在時間帯
- 基本出現量倍率
- 出現間隔倍率
- 追加出現数
- 通常ウェーブ敵数 / 上限
- ティア別出現数

### 機械確認

- `relayStageBalance` の0秒、30秒、90秒境界値が仕様どおり。
- 通常モードでは新しい補正が一切適用されない。
- お絵かき28体、コラボ32体を超えて通常ウェーブ敵が増えない。
- 上限到達時もスポーンタイマーが更新される。
- 固定乱数1000回のコラボ抽選が60% / 30% / 10%へ概ね収まる。
- 危険敵上限・種類別上限を超えない。
- ラストオフライン最大HPが2400。
- 全アンカーが移動範囲内かつ壁外。
- `ATTACK_LOCK` 中にボス実座標が変わらない。
- `reposition_then_lock` 攻撃が到着前に予兆へ入らない。
- ボス撃破後に移動更新が停止する。

### 手動確認

- お絵かき枠を3回以上プレイし、後半ほど敵処理が途切れにくい。
- コラボ枠を3回以上プレイし、お絵かき枠より密度が高い。
- コラボチャレンジ中も敵が残るが、チャレンジ操作を妨げるほど増えない。
- 各枠1～2回、2枠合計2～3回以上のレベルアップ目標を確認する。
- 最終ボス各フェーズを強制移行し、移動傾向が切り替わる。
- 大技中にボスが停止し、予告と判定がずれない。
- 高速移動で接触ダメージが発生しない。
- 標準ビルドでおおむね180～240秒の戦闘になる。

## 18. 完了条件

- 調整は配信リレーのお絵かき枠・コラボ枠だけへ適用される。
- 敵単体のHP・攻撃力・経験値を変えず、敵数でレベルアップ機会を増やしている。
- 強敵・遠距離敵・減速敵だけが大量に増えていない。
- お絵かきギミックとコラボチャレンジ中も通常スポーンが完全停止しない。
- ラストオフラインのHPが2400で、5フェーズを体験できる戦闘時間になる。
- ボスが攻撃間に移動し、フェーズごとの動きが見分けられる。
- 大技中の停止、予告と判定の一致、接触ダメージ0が守られる。
- 既存の17攻撃FSM、指示コメ、コラボパス、コンビ技、勝利処理を回帰させない。
