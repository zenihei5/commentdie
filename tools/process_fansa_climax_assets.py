from __future__ import annotations

import hashlib
import json
import shutil
import tempfile
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

from process_new_character_assets import alpha_stats, remove_green_screen, trim_transparent


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = Path.home() / "Desktop" / "ぜんぶコメントのせいだ設定"
BACKUP_DIR = ROOT / "assets" / "source_backups" / "fansa_climax_visuals"
OUTPUT_DIR = ROOT / "assets" / "weapons" / "fansa_climax"
MANIFEST_PATH = OUTPUT_DIR / "fansa_climax_visual_manifest.json"
QC_PATH = Path(tempfile.gettempdir()) / "commentdie_fansa_climax_visual_qc.png"

SINGLE_ASSETS = {
    "icon": "icon_fansa_climax.png",
    "slash1": "fansa_climax_slash_1.png",
    "slash2": "fansa_climax_slash_2.png",
    "echo": "fansa_climax_echo.png",
    "finisher": "fansa_climax_finisher.png",
    "xSlash": "fansa_climax_xslash.png",
    "wave": "fansa_climax_wave.png",
    "spark": "fansa_climax_spark.png",
    "finisherBg": "fansa_climax_finisher_bg.png",
    "confetti": "fansa_climax_confetti.png",
}


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def border_opaque_pixels(image: Image.Image) -> int:
    alpha = image.getchannel("A")
    width, height = image.size
    crops = [
        alpha.crop((0, 0, width, 1)),
        alpha.crop((0, height - 1, width, height)),
        alpha.crop((0, 0, 1, height)),
        alpha.crop((width - 1, 0, width, height)),
    ]
    return sum(sum(crop.histogram()[4:]) for crop in crops)


def green_residual_pixels(image: Image.Image) -> int:
    count = 0
    for r, g, b, a in image.getdata():
        if a > 8 and g >= 90 and g - max(r, b) >= 24 and g >= int(r * 1.18) and g >= int(b * 1.14):
            count += 1
    return count


def checkerboard(size: tuple[int, int], cell: int = 12) -> Image.Image:
    image = Image.new("RGBA", size, (225, 229, 239, 255))
    draw = ImageDraw.Draw(image)
    for y in range(0, size[1], cell):
        for x in range(0, size[0], cell):
            if (x // cell + y // cell) % 2:
                draw.rectangle((x, y, x + cell - 1, y + cell - 1), fill=(194, 201, 216, 255))
    return image


def add_transparent_border(image: Image.Image, padding: int = 4) -> Image.Image:
    bordered = Image.new("RGBA", (image.width + padding * 2, image.height + padding * 2), (0, 0, 0, 0))
    bordered.alpha_composite(image, (padding, padding))
    return bordered


def make_qc_sheet(processed: list[tuple[str, Image.Image]]) -> None:
    columns = 4
    tile_width = 300
    tile_height = 235
    rows = (len(processed) + columns - 1) // columns
    sheet = Image.new("RGBA", (columns * tile_width, rows * tile_height), (28, 31, 43, 255))
    font = ImageFont.load_default()
    for index, (asset_id, image) in enumerate(processed):
        x = (index % columns) * tile_width
        y = (index // columns) * tile_height
        preview = checkerboard((tile_width - 20, tile_height - 42))
        fitted = image.copy()
        fitted.thumbnail((tile_width - 44, tile_height - 66), Image.Resampling.LANCZOS)
        preview.alpha_composite(fitted, ((preview.width - fitted.width) // 2, (preview.height - fitted.height) // 2))
        sheet.alpha_composite(preview, (x + 10, y + 30))
        ImageDraw.Draw(sheet).text((x + 12, y + 10), asset_id, fill=(242, 244, 252), font=font)
    sheet.convert("RGB").save(QC_PATH, quality=94)


def manifest_entry(asset_id: str, source_path: Path, backup_path: Path, output_path: Path, original: Image.Image, image: Image.Image, bounds: tuple[int, int, int, int]) -> dict[str, object]:
    return {
        "id": asset_id,
        "sourceFile": source_path.name,
        "sourceBackup": backup_path.relative_to(ROOT).as_posix(),
        "output": output_path.relative_to(ROOT).as_posix(),
        "sourceSha256": sha256(source_path),
        "backupSha256": sha256(backup_path),
        "originalSize": list(original.size),
        "contentBoundsInSource": list(bounds),
        "outputSize": list(image.size),
        "borderOpaquePixels": border_opaque_pixels(image),
        "greenResidualPixels": green_residual_pixels(image),
        **alpha_stats(image),
    }


def main() -> None:
    BACKUP_DIR.mkdir(parents=True, exist_ok=True)
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    processed: list[tuple[str, Image.Image]] = []
    manifest_assets: list[dict[str, object]] = []

    for asset_id, source_name in SINGLE_ASSETS.items():
        source_path = SOURCE_DIR / source_name
        if not source_path.exists():
            raise FileNotFoundError(source_path)
        backup_path = BACKUP_DIR / source_name
        if not backup_path.exists():
            shutil.copy2(source_path, backup_path)
        original = Image.open(source_path).convert("RGBA")
        cleaned = remove_green_screen(original)
        trimmed, bounds = trim_transparent(cleaned, padding=16)
        output_path = OUTPUT_DIR / source_name
        trimmed.save(output_path, optimize=True)
        processed.append((asset_id, trimmed))
        manifest_assets.append(manifest_entry(asset_id, source_path, backup_path, output_path, original, trimmed, bounds))

    # The source sheet contains two batons. Keep a cleaned full backup-compatible
    # copy, but expose only the left/right regions to the runtime visuals.
    for asset_id, source_name in {"batonBody": "fansa_climax_baton_body.png", "batonGlow": "fansa_climax_baton_glow.png"}.items():
        source_path = SOURCE_DIR / source_name
        if not source_path.exists():
            raise FileNotFoundError(source_path)
        backup_path = BACKUP_DIR / source_name
        if not backup_path.exists():
            shutil.copy2(source_path, backup_path)
        original = Image.open(source_path).convert("RGBA")
        cleaned = remove_green_screen(original)
        trimmed_full, bounds = trim_transparent(cleaned, padding=16)
        full_output = OUTPUT_DIR / source_name
        trimmed_full.save(full_output, optimize=True)
        processed.append((asset_id + "Full", trimmed_full))
        manifest_assets.append(manifest_entry(asset_id + "Full", source_path, backup_path, full_output, original, trimmed_full, bounds))

        split_at = cleaned.width // 2
        for side, crop_box in (("Left", (0, 0, split_at, cleaned.height)), ("Right", (split_at, 0, cleaned.width, cleaned.height))):
            split_cleaned = cleaned.crop(crop_box)
            split_image, split_bounds = trim_transparent(split_cleaned, padding=12)
            split_image = add_transparent_border(split_image)
            split_output = OUTPUT_DIR / (Path(source_name).stem + "_" + side.lower() + ".png")
            split_image.save(split_output, optimize=True)
            processed.append((asset_id + side, split_image))
            entry = manifest_entry(asset_id + side, source_path, backup_path, split_output, original, split_image, split_bounds)
            entry["splitRegionInCleanedSource"] = list(crop_box)
            manifest_assets.append(entry)

    manifest = {
        "schemaVersion": 1,
        "processing": {
            "method": "border-connected green chroma key with local edge despill",
            "tightCropPadding": 16,
            "batonSheetSplit": "vertical midpoint after chroma cleanup; full sheets are never used by runtime",
            "resized": False,
        },
        "assets": manifest_assets,
    }
    MANIFEST_PATH.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    make_qc_sheet(processed)
    print(f"processed {len(processed)} fansa climax visual assets")
    print(MANIFEST_PATH)
    print(QC_PATH)


if __name__ == "__main__":
    main()
