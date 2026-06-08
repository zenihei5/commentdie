from __future__ import annotations

import importlib.util
import json
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
EXTRACTOR = ROOT / "tools" / "extract_desk_png_props.py"
OUT = ROOT / "tools" / "map_prop_editor_data.json"


def _load_extractor() -> Any:
    spec = importlib.util.spec_from_file_location("extract_desk_png_props", EXTRACTOR)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"Could not load {EXTRACTOR}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def _rel(path: Path) -> str:
    return "../" + path.relative_to(ROOT).as_posix()


def _rect_tuple_to_list(value: tuple[int, int, int, int]) -> list[int]:
    return [int(value[0]), int(value[1]), int(value[2]), int(value[3])]


def main() -> None:
    extractor = _load_extractor()
    props: list[dict[str, Any]] = []
    for prop in extractor.PROPS:
        props.append(
            {
                "id": prop["id"],
                "source": prop.get("source", "desk"),
                "src_rect": _rect_tuple_to_list(prop["src_rect"]),
                "dst_rect": _rect_tuple_to_list(prop["dst_rect"]),
                "collision_rect": _rect_tuple_to_list(prop["collision_rect"]),
                "decorative": bool(prop.get("decorative", False)),
                "no_collision": bool(prop.get("no_collision", False)),
            }
        )

    data = {
        "version": 1,
        "canvasSize": [int(extractor.CANVAS_SIZE[0]), int(extractor.CANVAS_SIZE[1])],
        "floorPath": _rel(extractor.FLOOR),
        "propsLayerPath": _rel(extractor.OUT_PROPS),
        "assembledPath": _rel(extractor.OUT_ASSEMBLED),
        "collisionPreviewPath": _rel(extractor.OUT_COLLISION),
        "manifestPath": _rel(extractor.OUT_ACTIVE_MANIFEST),
        "sources": {
            "desk": str(extractor.DESK_SRC),
            "komono": str(extractor.KOMONO_SRC),
            "komono2": str(extractor.KOMONO2_SRC),
        },
        "props": props,
        "notes": [
            "This file is generated for tools/map_prop_editor.html.",
            "The editor is export-only. It does not overwrite extract_desk_png_props.py.",
            "Copy the exported props JSON back into PROPS, then run extract_desk_png_props.py and sync_map_background_to_gd.py.",
        ],
    }
    OUT.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"wrote {OUT}")


if __name__ == "__main__":
    main()
