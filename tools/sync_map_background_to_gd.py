from __future__ import annotations

import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "assets" / "generated" / "maps" / "zatsudan_studio_layered_v1" / "manifest.json"
SYSTEM = ROOT / "scripts" / "systems" / "map_background_system.gd"


def gd_rect_from_manifest_rect(rect: list[int]) -> tuple[int, int, int, int]:
    x1, y1, x2, y2 = rect
    return x1, y1, x2 - x1, y2 - y1


def gd_array(name: str, items: list[dict]) -> str:
    lines = [f"const {name} := ["]
    for index, item in enumerate(items):
        x, y, w, h = gd_rect_from_manifest_rect(item["rect"])
        suffix = "," if index < len(items) - 1 else ""
        lines.append(f'\t{{"id": "{item["id"]}", "rect": Rect2({x}, {y}, {w}, {h})}}{suffix}')
    lines.append("]")
    return "\n".join(lines)


def replace_const_array(source: str, name: str, replacement: str) -> str:
    pattern = re.compile(r"const\s+" + re.escape(name) + r"\s*:=\s*\[(?:.*?\n\]|[^\]]*\])", re.DOTALL)
    result, count = pattern.subn(replacement, source, count=1)
    if count != 1:
        raise ValueError(f"Could not replace {name}")
    return result


def main() -> int:
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8-sig"))
    collision_array = gd_array("ZATSUDAN_STUDIO_COLLISION_RECTS", manifest["collision_rects"])
    prop_collision_array = gd_array("ZATSUDAN_STUDIO_PROP_COLLISION_RECTS", manifest.get("prop_collision_rects", []))
    source = SYSTEM.read_text(encoding="utf-8")
    source = replace_const_array(source, "ZATSUDAN_STUDIO_COLLISION_RECTS", collision_array)
    source = replace_const_array(source, "ZATSUDAN_STUDIO_PROP_COLLISION_RECTS", prop_collision_array)
    SYSTEM.write_text(source, encoding="utf-8")
    print(f"synced {len(manifest['collision_rects'])} collision rects and {len(manifest.get('prop_collision_rects', []))} prop rects")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
