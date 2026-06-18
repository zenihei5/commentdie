from __future__ import annotations

import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SYSTEM = ROOT / "scripts" / "systems" / "map_background_system.gd"
OUT = ROOT / "tools" / "trial_field_collision_editor_data.json"
FIELD_BG = ROOT / "assets" / "generated" / "maps" / "trial_field_v1" / "field_trial_cover_2200x1500.png"
FIELD_PREVIEW = ROOT / "assets" / "generated" / "maps" / "trial_field_v1" / "field_trial_collision_preview_2200x1500.png"
CANVAS_SIZE = [2200, 1500]


def _rel(path: Path) -> str:
    return "../" + path.relative_to(ROOT).as_posix()


def _const_block(source: str, name: str) -> str:
    pattern = re.compile(r"const\s+" + re.escape(name) + r"\s*:=\s*\[(.*?)\n\]", re.S)
    match = pattern.search(source)
    if not match:
        raise ValueError(f"Could not find {name}")
    return match.group(1)


def _trial_rects() -> list[dict[str, object]]:
    source = SYSTEM.read_text(encoding="utf-8")
    block = _const_block(source, "TRIAL_FIELD_COLLISION_RECTS")
    pattern = re.compile(
        r'\{"id":\s*"([^"]+)",\s*"rect":\s*Rect2\(\s*([-0-9.]+)\s*,\s*([-0-9.]+)\s*,\s*([-0-9.]+)\s*,\s*([-0-9.]+)\s*\)\s*\}'
    )
    rects: list[dict[str, object]] = []
    for match in pattern.finditer(block):
        x, y, w, h = [int(round(float(v))) for v in match.groups()[1:]]
        rects.append({"id": match.group(1), "rect": [x, y, w, h]})
    if not rects:
        raise ValueError("No TRIAL_FIELD_COLLISION_RECTS entries found")
    return rects


def main() -> int:
    props: list[dict[str, object]] = []
    for item in _trial_rects():
        rect = item["rect"]
        props.append(
            {
                "id": item["id"],
                "source": "collision",
                "src_rect": rect,
                "dst_rect": rect,
                "collision_rect": rect,
                "decorative": False,
                "no_collision": False,
            }
        )

    data = {
        "version": 2,
        "mode": "trial_field_collision",
        "canvasSize": CANVAS_SIZE,
        "floorPath": _rel(FIELD_BG),
        "propsLayerPath": "",
        "assembledPath": _rel(FIELD_BG),
        "collisionPreviewPath": _rel(FIELD_PREVIEW),
        "systemPath": _rel(SYSTEM),
        "defaultEditMode": "collision",
        "showPropsRef": False,
        "showCollision": True,
        "props": props,
        "notes": [
            "Generated for tools/map_prop_editor.html?data=trial_field_collision_editor_data.json.",
            "Edit collision_rect values, export JSON, then run tools/apply_trial_field_collision_editor_export.py.",
        ],
    }
    OUT.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"wrote {OUT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
