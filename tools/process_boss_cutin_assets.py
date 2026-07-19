from __future__ import annotations

import argparse
import json
import shutil
from pathlib import Path

from PIL import Image, ImageDraw
import numpy as np


ROOT = Path(__file__).resolve().parents[1]
OUTPUT_DIR = ROOT / "assets" / "generated" / "boss_cutin_v3_assets"
QC_PATH = ROOT / "docs" / "images" / "boss_cutin_v3_assets_qc.png"

CHROMA_ASSETS = (
    "boss_cutin_label_boss.png",
    "cutin_bug_loading_bar.png",
    "boss_cutin_label_final.png",
    "cutin_collab_broken_heart.png",
    "cutin_bug_horizontal_noise.png",
    "cutin_redpen_circle.png",
    "cutin_decor_marshmallow_small.png",
    "cutin_decor_kusomaro_crown.png",
    "cutin_bug_pixel_fragment.png",
    "boss_cutin_impact_lines.png",
    "cutin_lastoffline_eye_glow.png",
    "cutin_redpen_line_set.png",
    "cutin_collab_vs_mark.png",
    "boss_cutin_glitch_fragments.png",
    "cutin_collab_crack.png",
    "cutin_lastoffline_power_icon.png",
    "cutin_redpen_cross.png",
    "cutin_lastoffline_mouth_glow.png",
    "cutin_lastoffline_core_glow.png",
    "cutin_pitch_line.png",
    "cutin_pitch_violation_marker.png",
    "cutin_pitch_police_siren.png",
)

OPAQUE_ASSETS = ("boss_cutin_bg_common.png",)

MARSHMALLOW_COLUMN_EDGES = (0, 281, 516, 752, 986, 1254)
MARSHMALLOW_ROW_EDGES = (0, 293, 525, 756, 980, 1254)

# Keep atlas coordinates stable for runtime region drawing.
PRESERVE_CANVAS = {
    "cutin_decor_marshmallow_small.png",
    "cutin_bug_pixel_fragment.png",
    "cutin_redpen_line_set.png",
    "boss_cutin_impact_lines.png",
    "boss_cutin_glitch_fragments.png",
}


def remove_green_screen(image: Image.Image) -> Image.Image:
    rgba = np.array(image.convert("RGBA"), dtype=np.uint8)
    rgb = rgba[:, :, :3].astype(np.int16)
    red = rgb[:, :, 0]
    green = rgb[:, :, 1]
    blue = rgb[:, :, 2]
    strongest_other = np.maximum(red, blue)

    hard_background = (
        (green >= 150)
        & (red <= 90)
        & (blue <= 90)
        & ((green - red) >= 75)
        & ((green - blue) >= 75)
    )
    broad_green = (
        (green >= 90)
        & ((green - strongest_other) >= 24)
        & (green >= red * 1.18)
        & (green >= blue * 1.14)
    )

    # None of the keyed assets intentionally uses green. Clean every residual
    # green-dominant edge pixel so large glow textures do not retain a halo.
    edge_mask = broad_green & ~hard_background

    alpha = rgba[:, :, 3].astype(np.int16)
    green_excess = np.maximum(0, green - strongest_other)
    edge_alpha = np.clip(255 - green_excess, 0, 255)
    alpha[edge_mask] = np.minimum(alpha[edge_mask], edge_alpha[edge_mask])
    alpha[hard_background] = 0

    cleaned_green = np.minimum(green, strongest_other + 6)
    rgb[:, :, 1][edge_mask] = cleaned_green[edge_mask]

    rgba[:, :, :3] = np.clip(rgb, 0, 255).astype(np.uint8)
    rgba[:, :, 3] = np.clip(alpha, 0, 255).astype(np.uint8)
    rgba[rgba[:, :, 3] == 0, :3] = 0
    return Image.fromarray(rgba, "RGBA")


def alpha_stats(image: Image.Image) -> dict[str, int]:
    histogram = image.getchannel("A").histogram()
    return {
        "transparentPixels": histogram[0],
        "partialAlphaPixels": sum(histogram[1:255]),
        "opaquePixels": histogram[255],
    }


def content_bounds(image: Image.Image, padding: int = 8) -> tuple[int, int, int, int]:
    alpha = image.getchannel("A")
    bbox = alpha.point(lambda value: 255 if value >= 4 else 0).getbbox()
    if bbox is None:
        raise ValueError("image has no visible pixels after green-screen removal")
    return (
        max(0, bbox[0] - padding),
        max(0, bbox[1] - padding),
        min(image.width, bbox[2] + padding),
        min(image.height, bbox[3] + padding),
    )


def process_asset(source_path: Path, output_path: Path, preserve_canvas: bool) -> dict:
    original = Image.open(source_path).convert("RGBA")
    cleaned = remove_green_screen(original)
    bbox = content_bounds(cleaned)
    output = cleaned if preserve_canvas else cleaned.crop(bbox)
    output.save(output_path, optimize=True)
    return {
        "sourceFile": source_path.name,
        "output": output_path.relative_to(ROOT).as_posix(),
        "originalSize": list(original.size),
        "contentBoundsInSource": list(bbox),
        "outputSize": list(output.size),
        "preserveCanvas": preserve_canvas,
        **alpha_stats(output),
    }


def split_marshmallow_atlas(atlas: Image.Image) -> list[dict]:
    output_dir = OUTPUT_DIR / "marshmallows"
    output_dir.mkdir(parents=True, exist_ok=True)
    entries: list[dict] = []
    for row in range(5):
        for column in range(5):
            left = round(MARSHMALLOW_COLUMN_EDGES[column] * atlas.width / 1254)
            top = round(MARSHMALLOW_ROW_EDGES[row] * atlas.height / 1254)
            right = round(MARSHMALLOW_COLUMN_EDGES[column + 1] * atlas.width / 1254)
            bottom = round(MARSHMALLOW_ROW_EDGES[row + 1] * atlas.height / 1254)
            cell = atlas.crop((left, top, right, bottom))
            bbox = content_bounds(cell, padding=4)
            cut = cell.crop(bbox)
            index = row * 5 + column + 1
            output_path = output_dir / f"marshmallow_{index:02d}.png"
            cut.save(output_path, optimize=True)
            entries.append({
                "id": f"marshmallow_{index:02d}",
                "sourceRegion": [left, top, right, bottom],
                "contentBoundsInRegion": list(bbox),
                "output": output_path.relative_to(ROOT).as_posix(),
                "outputSize": list(cut.size),
                **alpha_stats(cut),
            })
    return entries


def checkerboard(size: tuple[int, int], cell: int = 12) -> Image.Image:
    width, height = size
    canvas = Image.new("RGB", size, (226, 229, 235))
    draw = ImageDraw.Draw(canvas)
    alternate = (246, 247, 250)
    for y in range(0, height, cell):
        for x in range(0, width, cell):
            if (x // cell + y // cell) % 2 == 0:
                draw.rectangle((x, y, x + cell - 1, y + cell - 1), fill=alternate)
    return canvas


def build_qc_sheet(paths: list[Path]) -> None:
    columns = 4
    tile_width = 360
    tile_height = 230
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
    source_dir: Path = args.source_dir

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    manifest: dict[str, object] = {
        "schemaVersion": 1,
        "sourceDirectory": "external:user-provided/boss-cut-in",
        "processing": {
            "method": "green chroma key with edge alpha and green despill",
            "keyColor": "#00ff00",
            "tightCropPadding": 8,
        },
        "assets": [],
        "marshmallowCuts": [],
    }

    qc_paths: list[Path] = []
    cleaned_marshmallow_atlas: Image.Image | None = None
    assets = manifest["assets"]
    assert isinstance(assets, list)

    for filename in CHROMA_ASSETS:
        source_path = source_dir / filename
        if not source_path.exists():
            raise FileNotFoundError(source_path)
        output_path = OUTPUT_DIR / filename
        item = process_asset(source_path, output_path, filename in PRESERVE_CANVAS)
        assets.append(item)
        qc_paths.append(output_path)
        if filename == "cutin_decor_marshmallow_small.png":
            cleaned_marshmallow_atlas = Image.open(output_path).convert("RGBA")

    for filename in OPAQUE_ASSETS:
        source_path = source_dir / filename
        output_path = OUTPUT_DIR / filename
        shutil.copy2(source_path, output_path)
        image = Image.open(output_path)
        assets.append({
            "sourceFile": filename,
            "output": output_path.relative_to(ROOT).as_posix(),
            "originalSize": list(image.size),
            "outputSize": list(image.size),
            "preserveCanvas": True,
            "opaqueBackground": True,
        })
        qc_paths.append(output_path)

    if cleaned_marshmallow_atlas is None:
        raise RuntimeError("marshmallow atlas was not processed")
    manifest["marshmallowCuts"] = split_marshmallow_atlas(cleaned_marshmallow_atlas)

    manifest_path = OUTPUT_DIR / "manifest.json"
    manifest_path.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    build_qc_sheet(qc_paths)
    print(f"processed {len(CHROMA_ASSETS)} chroma assets and {len(OPAQUE_ASSETS)} opaque background")
    print(f"split {len(manifest['marshmallowCuts'])} marshmallow sprites")
    print(manifest_path)
    print(QC_PATH)


if __name__ == "__main__":
    main()
