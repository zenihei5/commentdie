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
BACKUP_DIR = ROOT / "assets" / "source_backups" / "buzz_thumbnail_visuals"
OUTPUT_DIR = ROOT / "assets" / "weapons" / "buzz_thumbnail"
MANIFEST_PATH = OUTPUT_DIR / "buzz_thumbnail_visual_manifest.json"
QC_PATH = Path(tempfile.gettempdir()) / "commentdie_buzz_thumbnail_visual_qc.png"

ASSETS = {
    "icon": "icon_buzz_thumbnail.png",
    "body": "buzz_thumbnail_rod_body.png",
    "lure": "buzz_thumbnail_lure.png",
    "zone": "buzz_thumbnail_zone.png",
    "pull": "buzz_thumbnail_pull.png",
    "throw": "buzz_thumbnail_throw.png",
    "hit": "buzz_thumbnail_hit.png",
    "explosion": "buzz_thumbnail_explosion.png",
    "line": "buzz_thumbnail_line.png",
    "targetMark": "buzz_thumbnail_target_mark.png",
    "bearFlash": "buzz_thumbnail_bear_flash.png",
    "catchMark": "buzz_thumbnail_catch_mark.png",
    "burstDeco": "buzz_thumbnail_burst_deco.png",
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
    border = (
        alpha.crop((0, 0, width, 1)),
        alpha.crop((0, height - 1, width, height)),
        alpha.crop((0, 0, 1, height)),
        alpha.crop((width - 1, 0, width, height)),
    )
    return sum(sum(edge.histogram()[4:]) for edge in border)


def green_residual_pixels(image: Image.Image) -> int:
    count = 0
    for r, g, b, a in image.getdata():
        if a > 8 and g >= 150 and r <= 90 and b <= 90 and g - r >= 75 and g - b >= 75:
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


def make_qc_sheet(processed: list[tuple[str, Image.Image]]) -> None:
    columns = 3
    tile_width = 360
    tile_height = 250
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


def main() -> None:
    BACKUP_DIR.mkdir(parents=True, exist_ok=True)
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    processed: list[tuple[str, Image.Image]] = []
    manifest_assets: list[dict[str, object]] = []

    for asset_id, source_name in ASSETS.items():
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
        manifest_assets.append(
            {
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
                "greenResidualPixels": green_residual_pixels(trimmed),
                **alpha_stats(trimmed),
            }
        )

    manifest = {
        "schemaVersion": 1,
        "processing": {
            "method": "border-connected green chroma key with local edge despill",
            "tightCropPadding": 16,
            "resized": False,
        },
        "notes": {"line": "processed for backup/QC but intentionally not referenced; the runtime dynamic line is the single fishing line"},
        "assets": manifest_assets,
    }
    MANIFEST_PATH.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    make_qc_sheet(processed)
    print(f"processed {len(processed)} buzz thumbnail visual assets")
    print(MANIFEST_PATH)
    print(QC_PATH)


if __name__ == "__main__":
    main()
