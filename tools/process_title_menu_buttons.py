from __future__ import annotations

import argparse
import json
from pathlib import Path

from PIL import Image, ImageDraw

from process_boss_cutin_assets import alpha_stats, content_bounds, remove_green_screen


ROOT = Path(__file__).resolve().parents[1]
OUTPUT_DIR = ROOT / "assets" / "title" / "menu_buttons_v2"
MANIFEST_PATH = OUTPUT_DIR / "manifest.json"
QC_PATH = OUTPUT_DIR / "qc_sheet.png"

BUTTONS = [
    ("01ニューゲーム.png", "title_menu_new_game.png"),
    ("02パワーアップショップ.png", "title_menu_power_up_shop.png"),
    ("03ランキング.png", "title_menu_ranking.png"),
    ("04オプション.png", "title_menu_options.png"),
    ("05終了する.png", "title_menu_quit.png"),
]


def build_qc_sheet(paths: list[Path]) -> None:
    tile_width = 560
    tile_height = 150
    sheet = Image.new("RGB", (tile_width, tile_height * len(paths)), (28, 24, 38))
    draw = ImageDraw.Draw(sheet)
    for row, path in enumerate(paths):
        image = Image.open(path).convert("RGBA")
        available = (tile_width - 24, tile_height - 34)
        scale = min(available[0] / image.width, available[1] / image.height)
        preview_size = (
            max(1, round(image.width * scale)),
            max(1, round(image.height * scale)),
        )
        preview = image.resize(preview_size, Image.Resampling.LANCZOS)
        x = (tile_width - preview.width) // 2
        y = row * tile_height + 6
        checker = Image.new("RGB", preview.size, (66, 61, 76))
        checker_draw = ImageDraw.Draw(checker)
        for cy in range(0, preview.height, 12):
            for cx in range(0, preview.width, 12):
                if (cx // 12 + cy // 12) % 2 == 0:
                    checker_draw.rectangle(
                        (cx, cy, min(cx + 11, preview.width), min(cy + 11, preview.height)),
                        fill=(91, 85, 101),
                    )
        checker.paste(preview, (0, 0), preview)
        sheet.paste(checker, (x, y))
        draw.text((10, row * tile_height + tile_height - 22), path.name, fill=(245, 245, 248))
    sheet.save(QC_PATH, optimize=True)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source-dir", type=Path, required=True)
    args = parser.parse_args()

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    manifest: dict[str, object] = {
        "schemaVersion": 1,
        "sourceDirectory": str(args.source_dir),
        "processing": {
            "method": "green chroma key with edge alpha and green despill",
            "preserveCommonCanvas": True,
        },
        "assets": [],
    }
    entries = manifest["assets"]
    assert isinstance(entries, list)
    output_paths: list[Path] = []

    for source_name, output_name in BUTTONS:
        source_path = args.source_dir / source_name
        if not source_path.exists():
            raise FileNotFoundError(source_path)
        original = Image.open(source_path).convert("RGBA")
        cleaned = remove_green_screen(original)
        bounds = content_bounds(cleaned, padding=12)
        output = cleaned
        output_path = OUTPUT_DIR / output_name
        output.save(output_path, optimize=True)
        output_paths.append(output_path)
        entries.append(
            {
                "sourceFile": source_name,
                "output": output_path.relative_to(ROOT).as_posix(),
                "originalSize": list(original.size),
                "contentBoundsInSource": list(bounds),
                "outputSize": list(output.size),
                "aspectRatio": round(output.width / output.height, 4),
                "preserveCanvas": True,
                **alpha_stats(output),
            }
        )

    MANIFEST_PATH.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    build_qc_sheet(output_paths)
    print(MANIFEST_PATH)
    print(QC_PATH)


if __name__ == "__main__":
    main()
