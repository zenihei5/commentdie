from __future__ import annotations

import json
import re
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "assets" / "generated" / "maps" / "zatsudan_studio_layered_v1" / "manifest.json"
SYSTEM = ROOT / "scripts" / "systems" / "map_background_system.gd"


def rects_from_manifest() -> list[tuple[int, int, int, int]]:
    data = json.loads(MANIFEST.read_text(encoding="utf-8-sig"))
    rects = [tuple(item["rect"]) for item in data["collision_rects"]]
    rects.extend(tuple(item["rect"]) for item in data.get("prop_collision_rects", []))
    return rects


def load_manifest() -> dict:
    return json.loads(MANIFEST.read_text(encoding="utf-8-sig"))


def image_alpha_stats(path: Path) -> tuple[int, int]:
    with Image.open(path) as image:
        rgba = image.convert("RGBA")
        alpha = rgba.getchannel("A")
        transparent = 0
        opaque = 0
        for value in alpha.tobytes():
            if value <= 0:
                transparent += 1
            elif value >= 255:
                opaque += 1
        return transparent, opaque


def validate_layers(data: dict) -> list[str]:
    errors: list[str] = []
    expected_size = tuple(data["size"])
    base_dir = MANIFEST.parent
    layer_by_id = {item["id"]: item for item in data["layers"]}
    for item in data["layers"]:
        layer_path = base_dir / item["path"]
        if not layer_path.exists():
            errors.append(f"missing layer: {layer_path}")
            continue
        with Image.open(layer_path) as image:
            if image.size != expected_size:
                errors.append(f"layer size mismatch: {item['id']} {image.size} != {expected_size}")
    floor_item = layer_by_id.get("floor")
    props_item = layer_by_id.get("props")
    if floor_item is not None:
        transparent, opaque = image_alpha_stats(base_dir / floor_item["path"])
        if opaque <= 0:
            errors.append("floor layer has no opaque pixels")
        if transparent > 0:
            errors.append("floor layer should be fully filled, but has transparent pixels")
    if props_item is not None:
        transparent, opaque = image_alpha_stats(base_dir / props_item["path"])
        allow_empty_props = props_item.get("type") == "transparent_placeholder"
        if opaque <= 0 and not allow_empty_props:
            errors.append("props layer has no opaque pixels")
        if transparent <= 0:
            errors.append("props layer should keep transparent empty areas")
    return errors


def _array_block(text: str, const_name: str) -> str:
    pattern = re.compile(r"const\s+" + re.escape(const_name) + r"\s*:=\s*\[(.*?)\]", re.DOTALL)
    match = pattern.search(text)
    if match is None:
        raise ValueError(f"{const_name} not found")
    return match.group(1)


def rects_from_gdscript() -> list[tuple[int, int, int, int]]:
    text = SYSTEM.read_text(encoding="utf-8")
    pattern = re.compile(r"Rect2\(([-0-9.]+),\s*([-0-9.]+),\s*([-0-9.]+),\s*([-0-9.]+)\)")
    blocks = [
        _array_block(text, "ZATSUDAN_STUDIO_COLLISION_RECTS"),
        _array_block(text, "ZATSUDAN_STUDIO_PROP_COLLISION_RECTS"),
    ]
    rects: list[tuple[int, int, int, int]] = []
    for block in blocks:
        rects.extend(tuple(int(float(value)) for value in match.groups()) for match in pattern.finditer(block))
    return rects


def manifest_rect_to_gd_rect(rect: tuple[int, int, int, int]) -> tuple[int, int, int, int]:
    x1, y1, x2, y2 = rect
    return x1, y1, x2 - x1, y2 - y1


def main() -> int:
    data = load_manifest()
    layer_errors = validate_layers(data)
    if layer_errors:
        print("map background layer validation failed")
        for error in layer_errors:
            print(error)
        return 1
    manifest_rects = [manifest_rect_to_gd_rect(rect) for rect in rects_from_manifest()]
    gd_rects = rects_from_gdscript()
    if manifest_rects != gd_rects:
        print("map background collision mismatch")
        print("manifest:", manifest_rects)
        print("gdscript:", gd_rects)
        return 1
    print("map background manifest ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
