# Zatsudan Studio Layered Map

This folder contains the layered runtime background for the zatsudan studio arena.

## Runtime Files

- `zatsudan_studio_floor_2200x1500.png`
  - Base/floor layer.
  - Must be exactly `2200x1500`.
  - Should be fully opaque.
- `zatsudan_studio_props_2200x1500.png`
  - Foreground props and obstacle visuals.
  - Must be exactly `2200x1500`.
  - Empty areas must stay transparent.
- `zatsudan_studio_assembled_2200x1500.png`
  - Preview/assembled image.
  - Useful for visual checks.
- `zatsudan_studio_collision_preview_2200x1500.png`
  - Debug preview.
  - Red rectangles are table blockers.
  - Cyan rectangles are prop blockers.
- `manifest.json`
  - Layer list, map size, collision rectangles, and prop placements.

## Replacement Flow

When replacing this map with final generated art:

1. Keep every runtime image at `2200x1500`.
2. Replace or regenerate the `floor` and `props` layers.
3. Update `manifest.json` collision rectangles to match visible obstacles.
4. Sync the same rectangles into `scripts/systems/map_background_system.gd`:

```powershell
& 'C:\Users\zenih\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' tools\sync_map_background_to_gd.py
```

5. Regenerate `zatsudan_studio_collision_preview_2200x1500.png`.
6. Run:

```powershell
& 'C:\Users\zenih\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' tools\check_map_background_manifest.py
```

## Notes

- Do not bake readable text into the map images. UI text is drawn by the game.
- Keep enemy/player/marshmallow/drops out of the map images.
- If a prop should block movement, it needs a collision rectangle.
- If a prop should only decorate the background, keep it out of collision data.
