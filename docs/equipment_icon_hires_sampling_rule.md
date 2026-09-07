# Equipment icon hi-res sampling rule

## Production policy

Weapon and accessory icons use two explicit sampling paths.

- Compact equipment UI (`HUD`, `pause`, `gift/evolution`, `results`, and character select) loads icons through `TextureCacheSystem.load_small_ui_texture()` and requests `LINEAR_WITH_MIPMAPS` on an equipment-only `CanvasTexture`.
- Codex detail explicitly uses ordinary `LINEAR` sampling on its `TextureRect`.
- Do not change a root viewport, global canvas, project default, or unrelated UI filter to implement this policy.

The compact wrapper is data-agnostic. It must not contain equipment IDs. A source texture without mipmaps remains valid: the sampler falls back to LOD0 and keeps the existing icon usable.

Current production inventory policy:

- every active dedicated equipment icon whose shortest edge is 512px or larger has generated mipmaps;
- compact-authored 96px sources remain unchanged and use the wrapper's LOD0 fallback;
- `listener_summon_hd_final_1254.png` is the audited shared HD master for compact equipment UI, its field summon, the power-up-shop mascot, and Codex detail;
- the original `listener_summon.png` remains present as a rollback source and is not overwritten;
- `stream_power_hd_final_1254.png` is the audited shared HD master for compact equipment UI, the power-up shop, and Codex detail;
- the original 96px `stream_power.png` remains present as a rollback source and is not overwritten;
- `bullet_support_hd_final_1254.png` is the audited shared HD master for compact equipment UI and Codex detail; the original 96px `bullet_support.png` is preserved unchanged;
- `mental_care_hd_final_1254.png` is the audited shared HD master for compact equipment UI, the power-up-shop `max_hp` card/detail, and Codex detail; the original 96px `mental_care.png` is preserved unchanged;
- `notification_bell_hd_final_1254.png` is the corrected, re-audited shared HD master for compact equipment UI, the power-up-shop `exp_gain` card/detail, and Codex detail. The top-loop hole is transparent; the original 96px `notification_bell.png` and its import are preserved unchanged;
- `mini_humidifier_hd_final_1254.png` is the audited shared HD master for compact equipment UI and Codex detail; the original 96px `mini_humidifier.png` is preserved unchanged. Its procedural healing effect is unaffected, and no power-up-shop icon currently references this item;
- `kusa_wave`, `ban_judgement`, and `starlight_superchat` remain the data-defined compact-old/Codex-HD exceptions.

## Adding or replacing an HD equipment icon

1. Keep the master as a lossless RGBA PNG. A 512–1254px or larger square master is acceptable when its transparent bounds and apparent object scale pass visual review.
2. Enable `mipmaps/generate=true` only on the HD equipment asset's own Godot import.
3. Keep lossless compression, alpha-border repair, and non-premultiplied alpha unless an asset-specific audit proves a change is needed.
4. Verify native 1:1 renderer captures at 30, 39, 40, 44, 48, and 68px through the compact production renderer.
5. Verify Codex detail at 235, 256, 282, and 308px through the Codex production `TextureRect`.
6. Check silhouette, main motif, outline, interior contrast, effect dominance, static noise, and temporal shimmer against the previous production icon.

Do not infer that every texture used as an `iconPath` is a dedicated HD icon. Shared gameplay sprites, pixel-styled assets, and compact-authored masters require an explicit audit before their import settings are changed.

An HD source passes shared use only when compact UI is visually clean with mipmapped sampling and Codex remains sharp with ordinary linear sampling.

`listener_summon` additionally uses the same source across non-equipment presentation paths. Its moving 52–88px field draw and 152px shop mascot explicitly request `LINEAR_WITH_MIPMAPS`; Codex keeps the direct source on ordinary `LINEAR`. The evolved `listener_assembly` keeps its independent formal visual assets.

`emote_mine` shares `assets/generated/equipment_icons_v1/icons/emote_mine.png` (512px) between compact equipment UI, Codex detail, and the placed field mine. The field draw explicitly requests `LINEAR_WITH_MIPMAPS` through the existing per-effect opt-in and reuses the equipment texture cache. Its 60–64px base pulse is scaled by 1.28 to a 76.8–81.92px canvas, compensating transparent margins while keeping the painted width close to the old mine. The PNG, shadow, range indicator, lifetime fade, trigger radius, and combat behavior are unchanged. The old `assets/generated/weapon_fx_v1/emote_mine.png` and its non-mipmapped import are retained. The evolved `emote_festival` continues to use its independent formal field image layers.

`stream_power` uses `stream_power_hd_final_1254.png` as a shared master. Compact equipment UI and the power-up-shop card/detail views use `LINEAR_WITH_MIPMAPS`; Codex detail keeps ordinary `LINEAR`. Its original 96px icon stays in the repository as rollback LOD0.

## Exceptions

If a master is still noisy or loses its primary motif after correct sampling, keep the exception in data rather than UI code.

- Keep `iconPath` pointed at the existing compact asset.
- Put the HD detail asset in the Codex visual override field.
- Keep a Codex-only HD override on ordinary `LINEAR`; it does not need generated mipmaps unless it later enters a compact-UI path.
- Let the shared Codex resolver select that override and fall back to `iconPath` when no override exists.
- Never branch on an equipment ID inside HUD, pause, gift, results, character-select, or Codex UI code.

Current reference exceptions:

- `kusa_wave`: compact UI uses the old 96px icon; Codex uses `kusa_wave_hd_final_1254.png`.
- `ban_judgement`: compact UI uses the old 96px icon; Codex uses `ban_judgement_hd_final_1254.png`.
- `starlight_superchat`: compact UI uses the old 96px icon; Codex uses `starlight_superchat_hd_final_1254.png`.
- `maro_comment_ring`: compact UI uses the old 96px icon; Codex uses `maro_comment_ring_hd_final_1024.png`.

All four are selected through `codexLore.codexVisual.iconPath`; none requires an equipment-ID branch in UI code.

## Regression gate

Before merging a sampling change:

- confirm all intended HD imports contain mip levels;
- confirm all active dedicated 512px-or-larger equipment masters contain mip levels;
- confirm compact-authored 96px icons and audited shared non-HD sources still render unchanged;
- confirm compact icon repeat is disabled;
- run the equipment sampling integration test and the Codex override test;
- run a project import/parse check and `git diff --check`;
- record the added texture-memory cost and a short frame-time comparison.

If a new icon cannot pass this gate, choose a data-defined Codex-HD/compact-old split or create a simplified compact variant. Do not weaken small-UI readability to preserve one-file operation.
