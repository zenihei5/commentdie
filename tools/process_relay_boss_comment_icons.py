from __future__ import annotations

import argparse
import json
from pathlib import Path

from PIL import Image, ImageDraw
import numpy as np

from process_boss_cutin_assets import alpha_stats, checkerboard, content_bounds, remove_green_screen


ROOT = Path(__file__).resolve().parents[1]
OUTPUT_DIR = ROOT / "assets" / "generated" / "instruction_comment_icons_v1"
MANIFEST_PATH = OUTPUT_DIR / "relay_boss_comment_icons_manifest.json"
QC_PATH = ROOT / "docs" / "images" / "relay_boss_comment_icons_qc.png"

ASSETS = {
    "負けないで.png": "boss_support_dont_lose_icon.png",
    "頑張れ.png": "boss_support_do_your_best_icon.png",
    "ボス本気出して.png": "relay_boss_attack_up_icon.png",
    "弾幕もっと増やして.png": "relay_boss_projectiles_up_icon.png",
    "もっと動き回って！.png": "relay_boss_movement_up_icon.png",
    "ダッシュ禁止で！.png": "relay_boss_no_dash_icon.png",
    "相方に頼りすぎ！.png": "relay_boss_partner_mute_icon.png",
    "もっと狭いところで戦って！.png": "relay_boss_small_arena_icon.png",
}


def remaining_chroma_green_pixels(image: Image.Image) -> int:
    rgb = np.array(image.convert("RGBA"), dtype=np.uint8)
    red = rgb[:, :, 0].astype(np.int16)
    green = rgb[:, :, 1].astype(np.int16)
    blue = rgb[:, :, 2].astype(np.int16)
    alpha = rgb[:, :, 3]
    mask = (
        (alpha >= 8)
        & (green >= 180)
        & (red <= 90)
        & (blue <= 90)
        & ((green - red) >= 75)
        & ((green - blue) >= 75)
    )
    return int(mask.sum())


def process_asset(source_path: Path, output_path: Path) -> dict[str, object]:
    original = Image.open(source_path).convert("RGBA")
    cleaned = remove_green_screen(original)
    bounds = content_bounds(cleaned, padding=10)
    output = cleaned.crop(bounds)
    output.save(output_path, optimize=True)
    return {
        "sourceFile": source_path.name,
        "output": output_path.relative_to(ROOT).as_posix(),
        "originalSize": list(original.size),
        "contentBoundsInSource": list(bounds),
        "outputSize": list(output.size),
        "remainingChromaGreenPixels": remaining_chroma_green_pixels(output),
        **alpha_stats(output),
    }


def build_qc_sheet(paths: list[Path]) -> None:
    columns = 4
    tile_width = 360
    tile_height = 300
    rows = (len(paths) + columns - 1) // columns
    sheet = Image.new("RGB", (columns * tile_width, rows * tile_height), (30, 32, 39))
    draw = ImageDraw.Draw(sheet)

    for index, path in enumerate(paths):
        column = index % columns
        row = index // columns
        x = column * tile_width
        y = row * tile_height
        preview = checkerboard((tile_width - 20, tile_height - 48))
        image = Image.open(path).convert("RGBA")
        image.thumbnail((preview.width - 16, preview.height - 16), Image.Resampling.LANCZOS)
        preview.paste(
            image,
            ((preview.width - image.width) // 2, (preview.height - image.height) // 2),
            image,
        )
        sheet.paste(preview, (x + 10, y + 10))
        draw.text((x + 12, y + tile_height - 30), path.name, fill=(245, 245, 248))

    QC_PATH.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(QC_PATH, optimize=True)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source-dir", type=Path, required=True)
    args = parser.parse_args()

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    entries: list[dict[str, object]] = []
    output_paths: list[Path] = []
    for source_name, output_name in ASSETS.items():
        source_path = args.source_dir / source_name
        if not source_path.exists():
            raise FileNotFoundError(source_path)
        output_path = OUTPUT_DIR / output_name
        entries.append(process_asset(source_path, output_path))
        output_paths.append(output_path)

    manifest = {
        "schemaVersion": 1,
        "sourceDirectory": "external:user-provided/instruction-comments",
        "processing": {
            "method": "green chroma key with edge alpha and green despill",
            "keyColor": "#00ff00",
            "tightCropPadding": 10,
        },
        "assets": entries,
    }
    MANIFEST_PATH.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    build_qc_sheet(output_paths)
    print(f"processed {len(output_paths)} relay boss comment icons")


if __name__ == "__main__":
    main()
