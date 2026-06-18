from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
SYSTEM = ROOT / "scripts" / "systems" / "map_background_system.gd"
FIELD_BG = ROOT / "assets" / "generated" / "maps" / "trial_field_v1" / "field_trial_cover_2200x1500.png"
FIELD_PREVIEW = ROOT / "assets" / "generated" / "maps" / "trial_field_v1" / "field_trial_collision_preview_2200x1500.png"
CANVAS_SIZE = [2200, 1500]


def _as_rect(value: Any, key: str) -> tuple[int, int, int, int]:
    if not isinstance(value, list) or len(value) != 4:
        raise ValueError(f"{key} must be a 4-number array")
    x, y, w, h = tuple(int(round(float(v))) for v in value)
    return x, y, max(0, w), max(0, h)


def _format_gd_array(items: list[dict[str, Any]]) -> str:
    lines = ["const TRIAL_FIELD_COLLISION_RECTS := ["]
    for index, item in enumerate(items):
        x, y, w, h = _as_rect(item["collision_rect"], "collision_rect")
        suffix = "," if index < len(items) - 1 else ""
        lines.append(f'\t{{"id": {json.dumps(str(item["id"]), ensure_ascii=False)}, "rect": Rect2({x}, {y}, {w}, {h})}}{suffix}')
    lines.append("]")
    return "\n".join(lines)


def _replace_trial_rects(source: str, replacement: str) -> str:
    pattern = re.compile(r"const\s+TRIAL_FIELD_COLLISION_RECTS\s*:=\s*\[(?:.*?\n\]|[^\]]*\])", re.S)
    updated, count = pattern.subn(replacement, source, count=1)
    if count != 1:
        raise ValueError("Could not replace TRIAL_FIELD_COLLISION_RECTS")
    return updated


def _collision_items(data: dict[str, Any]) -> list[dict[str, Any]]:
    props = data.get("props")
    if not isinstance(props, list) or not props:
        raise ValueError("export JSON has no props")
    items: list[dict[str, Any]] = []
    for index, prop_value in enumerate(props):
        if not isinstance(prop_value, dict):
            raise ValueError(f"props[{index}] must be an object")
        if prop_value.get("no_collision"):
            continue
        rect = _as_rect(prop_value.get("collision_rect"), "collision_rect")
        if rect[2] <= 0 or rect[3] <= 0:
            continue
        items.append({"id": str(prop_value.get("id", f"collision_{index + 1}")), "collision_rect": list(rect)})
    if not items:
        raise ValueError("export JSON has no active collision rectangles")
    return items


def _render_preview(items: list[dict[str, Any]]) -> None:
    try:
        from PIL import Image, ImageDraw
    except ImportError:
        print("Pillow is not available; skipped collision preview")
        return

    image = Image.open(FIELD_BG).convert("RGBA")
    overlay = Image.new("RGBA", image.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    for item in items:
        x, y, w, h = _as_rect(item["collision_rect"], "collision_rect")
        box = [x, y, x + w, y + h]
        draw.rectangle(box, fill=(255, 60, 90, 54), outline=(255, 40, 80, 255), width=5)
        draw.text((x + 6, y + 6), str(item["id"]), fill=(255, 255, 255, 230))
    image.alpha_composite(overlay)
    FIELD_PREVIEW.parent.mkdir(parents=True, exist_ok=True)
    image.convert("RGB").save(FIELD_PREVIEW)
    print(f"wrote {FIELD_PREVIEW}")


def main() -> int:
    if len(sys.argv) != 2:
        raise SystemExit("usage: apply_trial_field_collision_editor_export.py <map_prop_editor_export.json>")
    export_path = Path(sys.argv[1])
    data = json.loads(export_path.read_text(encoding="utf-8"))
    if data.get("canvasSize") != CANVAS_SIZE:
        raise SystemExit(f"unexpected canvasSize: {data.get('canvasSize')}")
    items = _collision_items(data)

    source = SYSTEM.read_text(encoding="utf-8")
    updated = _replace_trial_rects(source, _format_gd_array(items))
    SYSTEM.write_text(updated, encoding="utf-8")
    _render_preview(items)
    print(f"applied {len(items)} trial collision rects to {SYSTEM}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
