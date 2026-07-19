# ラストオフライン大型化・全域移動 差し替え実装設計

## 1. 適用範囲

本設計は `docs/relay_late_stage_and_boss_tuning_design.md` のうち、ラストオフラインの表示・移動に関する第10～17章を置き換える。

次は前回設計を維持する。

- お絵かき枠・コラボ枠の敵数調整
- ラストオフライン最大HP 2400
- 接触ダメージ0
- 17攻撃の攻撃FSM
- 指示コメ、コラボパス、コンビ技、勝利処理

今回の目的は、ラストオフラインを中央付近で小さく移動するボスから、大型の一枚絵で戦闘画面全域を横断する浮遊型ボスへ変更することである。

## 2. 現状との差分

現行の `RelayBossMovementSystem` には次が実装済み。

- 7アンカー
- `HOVER / REPOSITION / ATTACK_LOCK / PHASE_TRANSITION / STUNNED / DEAD`
- フェーズごとの45～75px/秒移動
- 120～150px/秒の位置変更
- 攻撃1～3回または5秒で位置変更
- 攻撃ごとの `movementPolicy`

新仕様に対して不足している点は次のとおり。

- 9アンカーと上下・斜めを含む画面全域移動
- 90～155px/秒の巡航、220～320px/秒の大移動
- 大移動前0.4秒の予兆
- 遠いアンカーを優先する選定
- プレイヤーとの最低距離
- 移動中の小型補助攻撃
- 表示サイズとダメージ受付判定の分離
- 高速移動用の傾き、伸縮、残像、影
- 画像内の論理Markerからの攻撃発射

現行の `_choose_anchor()` は65%の確率で最も近い候補を返すため、新仕様とは逆の挙動になっている。選定処理は差し替える。

## 3. 画面と移動座標

ゲーム全体は1600x900だが、実際の戦闘表示領域は `FIELD_VIEW = Rect2(20, 190, 1200, 590)` である。

ボスを `ARENA` 全体の固定座標へ配置すると、プレイヤーカメラから外れて見えなくなる可能性がある。9アンカーはアリーナ全体ではなく、現在カメラに映っている戦闘領域をワールド座標へ変換した矩形を基準にする。

```gdscript
var visible_world_rect: Rect2 = target.call("_visible_world_rect_for_spawning")
var navigation_rect := visible_world_rect.intersection(arena)
```

アンカーは画面内の位置を表すUV座標として保持し、更新時に現在の `navigation_rect` からワールド座標へ変換する。

高速移動の開始時には `anchor_uv` を固定するが、カメラ移動へ追従できるよう目的地のワールド座標は毎フレーム再計算する。これにより、プレイヤーが移動してもボスが画面外へ残り続けない。

## 4. 表示サイズと判定の分離

現行は `radius` が描画サイズとダメージ受付判定の両方へ使われている。大型化では次を分離する。

```gdscript
boss["damageRadius"] = 110.0
boss["radius"] = boss["damageRadius"]
boss["visualDrawSize"] = Vector2(520.0, 520.0)
boss["visualOpaqueSize"] = Vector2(500.0, 450.0)
boss["showWorldHpBar"] = false
```

- `damageRadius`: 武器・弾・コンビ技が命中する中央本体判定。直径220px。
- `visualDrawSize`: 1024x1024の一枚絵を描く矩形。
- `visualOpaqueSize`: 透明余白を除いた、おおよその見える範囲。画面内クランプに使う。
- `radius` は当たり判定互換のため `damageRadius` と同じ値を維持する。

現在の画像は正方形だが、見えるボス部分は横長寄りである。520x520の描画矩形を初期値にし、画面上の不透明部分がおよそ横430～520px、高さ380～470pxへ収まるよう調整する。

「現在値の1.5～1.7倍」は盲目的に描画矩形へ掛けず、実機で不透明部分の画面占有率を測って調整する。最終的な画面上サイズを優先する。

周囲の5パーツは一枚絵に含まれるが、ダメージ判定を追加しない。HPバーは専用ボスHUDだけを表示し、中央判定の半径を大きく見せない。

## 5. 画面内クランプ

画面内へ収めるための余白は、判定半径ではなく `visualOpaqueSize` から計算する。

```gdscript
var horizontal_margin := visual_opaque_size.x * 0.5 + 40.0
var vertical_margin := visual_opaque_size.y * 0.5 + 40.0
var safe_center_rect := navigation_rect.grow_individual(
    -horizontal_margin,
    -vertical_margin,
    -horizontal_margin,
    -vertical_margin
)
```

戦闘表示領域の高さは590pxなので、ボス高450pxと上下余白80pxを引くと、中心が上下へ動ける範囲は狭くなる。9アンカーの上下段は `safe_center_rect` の上端・中央・下端を使い、左右移動と斜め移動で大きな距離を確保する。

`safe_center_rect` が小さすぎる場合は次の順で縮退する。

1. 追加余白40pxを20pxまで下げる。
2. 予兆・高速移動中だけ描画スケールを最大0.94倍まで下げる。
3. それでも収まらない場合は中央行の3アンカーだけを候補にする。

画像を大きく画面外へ切る選択はしない。

## 6. 9アンカー

```gdscript
const ANCHOR_UV := {
    "upper_left": Vector2(0.0, 0.0),
    "upper_center": Vector2(0.5, 0.0),
    "upper_right": Vector2(1.0, 0.0),
    "middle_left": Vector2(0.0, 0.5),
    "center": Vector2(0.5, 0.5),
    "middle_right": Vector2(1.0, 0.5),
    "lower_left": Vector2(0.0, 1.0),
    "lower_center": Vector2(0.5, 1.0),
    "lower_right": Vector2(1.0, 1.0)
}
```

次の候補は除外する。

- 現在アンカー
- 直前アンカー
- プレイヤーから220px未満
- 静的壁・一時壁とボス中央判定が重なる
- 画像全体が安全矩形へ収まらない

残った候補を距離順に並べ、遠い上位50%から加重抽選する。最遠候補ほど重くする。

```text
weight = pow(distance / farthest_distance, 2.0)
```

最低移動距離は `max(400px, visible_width * 0.30)` を目標にする。ただし大型ボスと1200x590の表示領域では、中央から端まで400px取れない場合がある。

候補の最大距離が最低移動距離より短い場合は、次を実際の閾値にする。

```text
effective_min_distance
  = min(configured_min_distance, farthest_candidate_distance * 0.85)
```

これにより不可能な400px条件で移動が停止せず、その時点で選べる十分遠い地点へ移動する。

有効候補がない場合は0.25秒後に再探索する。プレイヤーに近い地点や画面外を無理に選ばない。

## 7. 差し替え移動FSM

```gdscript
enum BossMovementState {
    IDLE_HOVER,
    CRUISING,
    REPOSITION_WARNING,
    REPOSITIONING,
    ATTACKING,
    PHASE_TRANSITION,
    STUNNED,
    DEAD
}
```

### `IDLE_HOVER`

- 大移動到着後または攻撃終了後の短い待機。
- 最大1.0秒。
- 通常の上下浮遊を表示する。
- 攻撃後の隙は0.6～1.2秒。

### `CRUISING`

- フェーズ別の大きな軌道を通常巡航速度で移動する。
- `mobile` 攻撃だけ使用可能。
- 同じ画面エリアでの滞在時間を数える。
- 次の主攻撃または位置変更条件で終了する。

### `REPOSITION_WARNING`

- 0.4秒。
- 接触ダメージ0を維持する。
- コア発光、進行方向への傾き、グリッチ線、パーツ吸引風の縮小を表示する。
- 目的アンカーをこの状態の開始時に確定する。

### `REPOSITIONING`

- フェーズ別位置変更速度で目的アンカーへ移動する。
- 接触ダメージなし、押し出しなし、無敵なし。
- 大型攻撃を開始しない。
- 0.5秒後から小型補助攻撃を2～3回使用できる。
- 1～2枚の残像を生成する。

### `ATTACKING`

- `lock_on_telegraph`、`lock_on_aim_commit`、`reposition_then_lock` の主攻撃中。
- 攻撃仕様が許可する時点から実座標を固定する。
- 大型攻撃終了まで停止する。

### `PHASE_TRANSITION`

- 既存の攻撃物消去、中央移動、1.5秒演出を維持する。
- 中央移動にも0.4秒予兆は付けない。

### `STUNNED`

- コンビ技などで移動と攻撃を停止する。

### `DEAD`

- 移動、補助攻撃、残像生成を停止する。

## 8. 行動サイクル

基本サイクルを次で固定する。

```text
REPOSITION_WARNING
-> REPOSITIONING
-> IDLE_HOVER
-> 主攻撃
-> 攻撃後0.6～1.2秒
-> CRUISINGまたは次のREPOSITION_WARNING
```

同じアンカーで行える主攻撃数:

- 第1フェーズ: 2回
- 第2～4フェーズ: 1～2回
- 第5フェーズ: 1回

次のどちらかを満たしたら、次の主攻撃前に位置変更する。

- アンカーでの主攻撃回数が上限に達した。
- 大型攻撃を除く滞在時間が4秒に達した。

同じアンカーから3回目の主攻撃を開始してはならない。

大技の `active` 時間とフェーズ演出時間は4秒滞在制限へ数えない。

## 9. 速度設定

`data/relay_mode.json` の `boss.movement` を次へ置き換える。

```json
{
  "visualDrawSize": {"x": 520.0, "y": 520.0},
  "visualOpaqueSize": {"x": 500.0, "y": 450.0},
  "damageRadius": 110.0,
  "edgePadding": 40.0,
  "minimumPlayerDistance": 220.0,
  "minimumTravelDistance": 400.0,
  "minimumTravelWidthRate": 0.3,
  "repositionWarningSeconds": 0.4,
  "arrivalDistance": 10.0,
  "sameAreaMaxSeconds": 4.0,
  "idleHoverMaxSeconds": 1.0,
  "attackRecoveryMin": 0.6,
  "attackRecoveryMax": 1.2,
  "cruiseSpeeds": [90.0, 110.0, 125.0, 140.0, 155.0],
  "repositionSpeeds": [220.0, 240.0, 260.0, 280.0, 320.0],
  "attacksPerAnchor": [[2, 2], [1, 2], [1, 2], [1, 2], [1, 1]],
  "travelVolleyFirstDelay": 0.5,
  "travelVolleyIntervalMin": 0.45,
  "travelVolleyIntervalMax": 0.65,
  "travelVolleyCountMin": 2,
  "travelVolleyCountMax": 3,
  "hoverAmplitude": 6.0,
  "hoverCycleSeconds": 1.4
}
```

旧キー `phaseMoveSpeeds`、単一の `repositionSpeed`、`finalRepositionSpeed`、7アンカー定義は新移動システムから参照しない。

## 10. 移動中の補助攻撃

主攻撃FSMと移動FSMを競合させないため、高速移動中の小型攻撃は「補助攻撃」として扱う。

`RelayBossAttackSystem` に、主攻撃の `active_attack` を変更しない公開関数を追加する。

```gdscript
emit_travel_attack_for_target(target, attack_kind, travel_context)
```

初期実装の補助攻撃:

- `travel_comment_salvo`: コメント散弾の弾数を60%へ減らし、ボスの進行方向と反対側へ広げる。
- `travel_noise_shot`: 小型ノイズ弾を2～3発。完全追尾にしない。
- `travel_noise_summon`: 有効なボス召喚が2体未満の時だけ、最大1体追加。

補助攻撃の抽選目安:

- コメント散弾: 60%
- 小型ノイズ弾: 30%
- ノイズ召喚: 10%

補助攻撃は次へ影響させない。

- 主攻撃の直前攻撃ID
- 主攻撃の `reuseCooldown`
- アンカーでの主攻撃回数
- 大技後の共通攻撃制限

最初の補助攻撃は高速移動開始0.5秒後、以後0.45～0.65秒間隔で最大2～3回。目的地到着後は即座に止める。

弾はプレイヤー現在位置への完全照準ではなく、進行方向の後方120～160度の扇へ発射し、移動軌道と弾の間に回避空間を残す。

## 11. フェーズ別移動

### 第1フェーズ

- 左右の大横断を優先。
- 左列と右列を交互に使う。
- 攻撃2回ごとに大移動。
- プレイヤー座標を追尾判断へ使わない。

### 第2フェーズ

- 対角アンカーを高確率で選ぶ。
- 左上から右下、右上から左下を優先。
- `race_lane_charge` 前は左右端へ大移動する。
- 突進後は中央固定へ戻らず、現在位置から次の遠方アンカーを選ぶ。

### 第3フェーズ

- `CRUISING` 中は画面中央を囲む楕円軌道を使う。
- 横半径は安全矩形幅の35%、縦半径は安全矩形高の45%を上限とする。
- `howling_ring` 開始時に現在地点で停止する。
- 終了後は停止地点に最も近い楕円位相から再開する。

### 第4フェーズ

- 左右端、上下段、対角を切り替える。
- `eraser_sweep` 前は左列または右列へ移動する。
- `paint_warning` の危険側はボス位置だけで決めず、直前2回と同じ安全地帯方向を避ける。

### 第5フェーズ

- 主攻撃1回ごとに大移動する。
- 対角移動、左右横断、外周回り込みを加重抽選する。
- プレイヤーから220px以上離れた横を通り抜ける。
- `all_genre_rush` 前だけ中央へ移動する。

## 12. 主攻撃の移動ポリシー

### 移動可能

- `comment_shotgun`
- `noise_summon`

主攻撃として使う場合も `CRUISING` 中に開始可能。予告起点は画像Markerへ追従し、発射時に確定する。

### 照準確定時に停止

- `offline_laser`

照準追尾中は巡航可能。角度確定時に `ATTACKING` へ入り、その後は攻撃終了まで停止する。

### 予兆開始から停止

- `kuso_maro_drop`
- `long_comment_line`
- `game_over_barrage`
- `fake_gift_trap`
- `howling_ring`
- `pitch_wave`
- `rhythm_explosion`
- `dirty_paint`
- `paint_warning`
- `division_noise`
- `collab_break`

### 所定位置へ大移動してから停止

- `race_lane_charge`
- `eraser_sweep`
- `all_genre_rush`

所定位置へ向かう場合も `REPOSITION_WARNING` を通す。到着前に攻撃FSMの `TELEGRAPH` を始めない。

## 13. 画像内の論理Marker

現行ボスはNode2DではなくDictionary管理なので、Marker2Dへ全面移行しない。画像ローカル座標の論理Markerを設定し、描画変形と同じ計算でワールド座標へ変換する。

```json
{
  "muzzleMarkers": {
    "MuzzleCenter": {"x": 0.0, "y": -0.08},
    "MuzzleLeft": {"x": -0.16, "y": -0.02},
    "MuzzleRight": {"x": 0.16, "y": -0.02},
    "CoreCenter": {"x": 0.0, "y": 0.08},
    "ChatModule": {"x": -0.34, "y": -0.17},
    "GameModule": {"x": 0.34, "y": -0.17},
    "SongModule": {"x": -0.34, "y": 0.17},
    "DrawModule": {"x": 0.34, "y": 0.17},
    "CollabModule": {"x": 0.0, "y": 0.37}
  }
}
```

値は画像中心を(0, 0)、画像幅・高さの半分を1.0とする正規化座標。実機で画像に合わせて微調整する。

```gdscript
marker_world
  = boss.pos
  + visualOffset
  + rotate(
      marker_normalized
      * visualDrawSize * 0.5
      * visualScaleVector,
      visualRotation
    )
```

攻撃との対応:

- コメント散弾、長文コメント: `ChatModule`
- 配信終了レーザー: `CoreCenter`
- ゲーム弾幕、レース: `GameModule`
- ハウリング、音程波、リズム爆発: `SongModule`
- ペイント、消しゴム: `DrawModule`
- 分断ノイズ、コラボブレイク: `CollabModule`
- オールジャンルラッシュ: サブ攻撃ごとのModule

予告描画と実際の弾・レーザー生成は必ず同じMarker関数を使う。

## 14. 大型ボス描画

現行のスプライト描画は回転値をデータへ入れているが、`draw_texture_rect()` が回転を使用していない。ラストオフラインだけ、回転・非等方スケール対応のテクスチャ四角形描画へ切り替える。

CanvasItem全体のカメラ変換を壊さないよう、`draw_set_transform()` で上書きせず、回転済み四隅とUVを使った2三角形で描画する。

### 通常浮遊

- 上下±6px、1.4秒。
- 停止時の傾きは0度へ滑らかに戻す。

### 巡航・高速移動

- 左移動: -3～5度。
- 右移動: +3～5度。
- 上移動: 全体を最大0.97倍。
- 下移動: 全体を最大1.03倍。
- 加速開始時: `Vector2(0.97, 1.03)` の短い伸縮。

### 残像

高速移動中だけ0.12～0.16秒間隔で最大2枚生成する。

```gdscript
{
    "pos": boss.pos,
    "rotation": visual_rotation,
    "scaleVector": visual_scale_vector,
    "life": 0.22,
    "maxLife": 0.22,
    "tint": Color(0.65, 0.55, 1.0, 0.18)
}
```

残像は現在の本体より先に描画し、0.15～0.25秒で消す。常時生成しない。

### 影

- `shadowPos` をボス位置へ遅れて追従させる。
- 通常時は上下浮遊と逆位相に拡縮。
- 高速移動時は進行方向へ最大1.25倍伸ばす。
- 影の遅れは見た目だけで、判定に使わない。

### コア発光

- 通常は弱い脈動。
- `REPOSITION_WARNING`、主攻撃予兆、フェーズ移行で強くする。
- `CoreCenter` Markerを発光中心に使う。

## 15. 接触とダメージ受付

- `contactDamage = 0` を維持する。
- 高速移動中もプレイヤー押し出しを行わない。
- ボスは移動中も無敵にしない。
- 武器の命中判定は `damageRadius = 110` の中央円だけ。
- 画像の周囲5パーツへ個別判定を追加しない。
- ボス画像がプレイヤーへ重なっても接触ダメージは発生しない。

将来接触ダメージを追加する場合だけ、対象別1秒の再ヒット間隔を実装する。今回の必須範囲では追加しない。

## 16. デバッグ

既存F9オーバーレイへ次を追加する。

- 移動FSM状態
- 画面基準の現在アンカー、直前アンカー、目的アンカー
- 現在の安全中心矩形
- 移動距離と実効最低距離
- プレイヤーとの目的地距離
- 巡航速度、位置変更速度
- 補助攻撃回数
- `damageRadius` と `visualOpaqueSize`

デバッグ描画:

- 9アンカー
- 安全中心矩形
- 中央ダメージ受付円
- 全Marker位置と名前
- 高速移動の予定線

F11の強制攻撃時も `reposition_then_lock` は所定位置への移動を通す。別のデバッグ入力で「移動を省略して即発動」も用意し、攻撃単体確認と移動連携確認を分ける。

## 17. 検証

### 機械確認

- 9アンカーが生成される。
- 現在と直前のアンカーを連続選択しない。
- 候補がある場合、近距離候補より遠距離候補の選択率が高い。
- プレイヤーから220px未満の目的地を選ばない。
- ボス不透明領域が戦闘表示外へ大きく出ない。
- 大移動前に0.4秒の `REPOSITION_WARNING` を通る。
- 第5フェーズは主攻撃1回ごとに位置変更する。
- 同一アンカーで3回目の主攻撃を開始しない。
- 高速移動中に大型攻撃が開始されない。
- 補助攻撃が主攻撃のcooldown・直前ID・攻撃回数を変更しない。
- `ATTACKING` 中の固定攻撃で実座標が変わらない。
- `damageRadius` が表示サイズから独立して110のまま。
- Markerの予告起点と実弾起点が一致する。
- 接触ダメージが0のまま。

### 手動確認

- ボス全体の不透明部分が横430～520px、高さ380～470px程度。
- 中央本体とコアが最も目立つ。
- 左右だけでなく上下段・対角へ移動する。
- 1回の大移動が画面上で十分長い。
- 高速移動中にコメント散弾などが2～3回発生する。
- 大型攻撃開始時に停止し、予告と判定がずれない。
- レーザー、弾幕、歌、ペイント、コラボ攻撃が対応Markerから出る。
- 傾き、伸縮、残像、影が移動方向と一致する。
- 画面外へ大きく切れず、プレイヤーを直接追い回さない。
- 最終撃破から `RELAY COMPLETE`、リザルトまで完走する。

## 18. 完了条件

- ラストオフラインが中央の固定砲台に見えず、画面全域を大きく移動する。
- 大型化してもダメージ受付は中央本体だけ。
- 攻撃1～2回、最終フェーズは1回ごとに位置が変わる。
- 移動中の補助攻撃で画面が止まって見えない。
- 大型攻撃は移動完了後に開始し、予告と判定が一致する。
- 高速移動による接触事故、押し出し、画面外残留がない。
- 前回完成した17攻撃、HP2400、後半枠バランス調整を回帰させない。
