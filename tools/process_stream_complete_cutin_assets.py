from __future__ import annotations

import hashlib
import json
import shutil
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

from process_new_character_assets import alpha_stats, is_green_key, remove_green_screen, trim_transparent


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = Path(r"C:\Users\zenih\Desktop\ぜんぶコメントのせいだ設定\カットイン")
BACKUP_DIR = ROOT / "assets" / "source_backups" / "stream_complete_cutin"
OUTPUT_DIR = ROOT / "assets" / "generated" / "game_clear_cutin_v1"
MANIFEST_PATH = OUTPUT_DIR / "senior_stream_complete_manifest.json"
QC_PATH = OUTPUT_DIR / "senior_stream_complete_qc.png"

ASSETS = {
    "aosumi_kyasumi": ("GCきゃすみ.png", "kyasumi_stream_complete.png"),
    "akarine_rizumu": ("GCりずむ.png", "rizumu_stream_complete.png"),
    "shizuki_miimu": ("GCみぃむ.png", "miimu_stream_complete.png"),
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


def remove_residual_green_pixels(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    pixels = rgba.load()
    for y in range(rgba.height):
        for x in range(rgba.width):
            r, g, b, a = pixels[x, y]
            if a > 0 and is_green_key(r, g, b):
                pixels[x, y] = (0, 0, 0, 0)
    return rgba


def checkerboard(size: tuple[int, int], cell: int = 12) -> Image.Image:
    image = Image.new("RGBA", size, (225, 229, 239, 255))
    draw = ImageDraw.Draw(image)
    for y in range(0, size[1], cell):
        for x in range(0, size[0], cell):
            if (x // cell + y // cell) % 2:
                draw.rectangle((x, y, x + cell - 1, y + cell - 1), fill=(194, 201, 216, 255))
    return image


def make_qc_sheet(processed: list[tuple[str, Image.Image]]) -> None:
    tile_width = 420
    tile_height = 420
    sheet = Image.new("RGBA", (tile_width * len(processed), tile_height), (28, 31, 43, 255))
    font = ImageFont.load_default()
    for index, (asset_id, image) in enumerate(processed):
        x = index * tile_width
        preview = checkerboard((tile_width - 24, tile_height - 48))
        fitted = image.copy()
        fitted.thumbnail((preview.width - 24, preview.height - 24), Image.Resampling.LANCZOS)
        preview.alpha_composite(fitted, ((preview.width - fitted.width) // 2, (preview.height - fitted.height) // 2))
        sheet.alpha_composite(preview, (x + 12, 36))
        ImageDraw.Draw(sheet).text((x + 14, 14), asset_id, fill=(242, 244, 252), font=font)
    sheet.convert("RGB").save(QC_PATH, quality=94)


def main() -> None:
    BACKUP_DIR.mkdir(parents=True, exist_ok=True)
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    processed: list[tuple[str, Image.Image]] = []
    manifest_assets: list[dict[str, object]] = []

    for asset_id, (source_name, output_name) in ASSETS.items():
        source_path = SOURCE_DIR / source_name
        if not source_path.exists():
            raise FileNotFoundError(source_path)
        backup_path = BACKUP_DIR / source_name
        if not backup_path.exists():
            shutil.copy2(source_path, backup_path)
        original = Image.open(source_path).convert("RGBA")
        cleaned = remove_residual_green_pixels(remove_green_screen(original))
        trimmed, bounds = trim_transparent(cleaned, padding=16)
        output_path = OUTPUT_DIR / output_name
        trimmed.save(output_path, optimize=True)
        processed.append((asset_id, trimmed))
        manifest_assets.append({
            "id": asset_id,
            "sourceFile": source_name,
            "sourceBackup": backup_path.relative_to(ROOT).as_posix(),
            "output": output_path.relative_to(ROOT).as_posix(),
            "sourceSha256": sha256(source_path),
            "backupSha256": sha256(backup_path),
            "originalSize": list(original.size),
            "contentBoundsInSource": list(bounds),
            "outputSize": list(trimmed.size),
            "borderOpaquePixels": border_opaque_pixels(trimmed),
            **alpha_stats(trimmed),
        })

    MANIFEST_PATH.write_text(json.dumps({
        "schemaVersion": 1,
        "processing": {
            "method": "border-connected green chroma key with local edge despill",
            "tightCropPadding": 16,
            "resized": False,
        },
        "assets": manifest_assets,
    }, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    make_qc_sheet(processed)
    print(f"processed {len(processed)} stream-complete cutin assets")
    print(MANIFEST_PATH)
    print(QC_PATH)


if __name__ == "__main__":
    main()
