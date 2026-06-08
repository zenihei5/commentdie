from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
TARGET = ROOT / "tools" / "extract_desk_png_props.py"


def _as_rect(value: Any, key: str) -> tuple[int, int, int, int]:
    if not isinstance(value, list) or len(value) != 4:
        raise ValueError(f"{key} must be a 4-number array")
    return tuple(int(v) for v in value)


def _format_props(props: list[dict[str, Any]]) -> str:
    lines = ["PROPS = ["]
    for prop in props:
        lines.append("    {")
        lines.append(f'        "id": {prop["id"]!r},')
        lines.append(f'        "source": {prop.get("source", "desk")!r},')
        lines.append(f'        "src_rect": {_as_rect(prop["src_rect"], "src_rect")!r},')
        lines.append(f'        "dst_rect": {_as_rect(prop["dst_rect"], "dst_rect")!r},')
        lines.append(f'        "collision_rect": {_as_rect(prop["collision_rect"], "collision_rect")!r},')
        if prop.get("decorative"):
            lines.append('        "decorative": True,')
        if prop.get("no_collision"):
            lines.append('        "no_collision": True,')
        lines.append("    },")
    lines.append("]")
    return "\n".join(lines)


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit("usage: apply_map_prop_editor_export.py <map_prop_editor_export.json>")
    export_path = Path(sys.argv[1])
    data = json.loads(export_path.read_text(encoding="utf-8"))
    if data.get("canvasSize") != [2200, 1500]:
        raise SystemExit(f"unexpected canvasSize: {data.get('canvasSize')}")
    props = data.get("props")
    if not isinstance(props, list) or not props:
        raise SystemExit("export JSON has no props")

    text = TARGET.read_text(encoding="utf-8")
    next_func = "\n\n\ndef _is_green_screen_pixel"
    pattern = r"PROPS = \[.*?\n\]" + re.escape(next_func)
    replacement = _format_props(props) + next_func
    updated = re.sub(pattern, replacement, text, count=1, flags=re.S)
    if updated == text:
        raise SystemExit("failed to replace PROPS block")
    TARGET.write_text(updated, encoding="utf-8")
    print(f"applied {len(props)} props to {TARGET}")


if __name__ == "__main__":
    main()
