from __future__ import annotations

import json
from pathlib import Path

from PIL import Image

from process_new_character_assets import alpha_stats, is_green_key, remove_green_screen, trim_transparent


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = Path.home() / "Desktop" / "\u305c\u3093\u3076\u30b3\u30e1\u30f3\u30c8\u306e\u305b\u3044\u3060\u8a2d\u5b9a" / "weapon"
OUTPUT_DIR = ROOT / "assets" / "generated" / "equipment_icons_v1" / "icons"

SOURCES = {
    "moderator_shield": "\u30e2\u30c7\u30ec\u30fc\u30bf\u30fc\u30b7\u30fc\u30eb\u30c9.png",
    "fansa_baton": "\u30d5\u30a1\u30f3\u30b5\u30d0\u30c8\u30f3.png",
    "tsuri_thumbnail_rod": "\u91e3\u308a\u30b5\u30e0\u30cd\u30ed\u30c3\u30c9.png",
}

ICON_SIZE = 96
ICON_MARGIN = 4


def make_icon(source_path: Path) -> tuple[Image.Image, tuple[int, int, int, int]]:
    original = Image.open(source_path).convert("RGBA")
    cleaned = remove_green_screen(original)
    pixels = cleaned.load()
    for y in range(cleaned.height):
        for x in range(cleaned.width):
            r, g, b, _a = pixels[x, y]
            if is_green_key(r, g, b):
                pixels[x, y] = (0, 0, 0, 0)
    trimmed, bbox = trim_transparent(cleaned, padding=16)
    scale = min(
        (ICON_SIZE - ICON_MARGIN * 2) / trimmed.width,
        (ICON_SIZE - ICON_MARGIN * 2) / trimmed.height,
    )
    target_size = (
        max(1, round(trimmed.width * scale)),
        max(1, round(trimmed.height * scale)),
    )
    scaled = trimmed.resize(target_size, Image.Resampling.NEAREST)
    icon = Image.new("RGBA", (ICON_SIZE, ICON_SIZE), (0, 0, 0, 0))
    icon.paste(
        scaled,
        ((ICON_SIZE - scaled.width) // 2, (ICON_SIZE - scaled.height) // 2),
        scaled,
    )
    return icon, bbox


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    manifest: dict[str, object] = {
        "schemaVersion": 1,
        "processing": "border-connected green chroma key with edge despill, transparent trim, nearest-neighbor 96x96 fit",
        "assets": [],
    }
    assets = manifest["assets"]
    assert isinstance(assets, list)
    for asset_id, source_name in SOURCES.items():
        source_path = SOURCE_DIR / source_name
        if not source_path.exists():
            raise FileNotFoundError(source_path)
        original = Image.open(source_path).convert("RGBA")
        icon, bbox = make_icon(source_path)
        output_path = OUTPUT_DIR / f"{asset_id}.png"
        icon.save(output_path, optimize=True)
        assets.append(
            {
                "id": asset_id,
                "sourceFile": source_name,
                "output": output_path.relative_to(ROOT).as_posix(),
                "originalSize": list(original.size),
                "contentBoundsInSource": list(bbox),
                "outputSize": list(icon.size),
                **alpha_stats(icon),
            }
        )
    (OUTPUT_DIR.parent / "weapon_icons_manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(json.dumps(manifest, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
