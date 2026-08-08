from __future__ import annotations

import hashlib
import json
import shutil
import tempfile
from collections import deque
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

from process_new_character_assets import (
    alpha_stats,
    remove_green_screen,
    trim_transparent,
)


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = Path.home() / "Desktop" / "ぜんぶコメントのせいだ設定"
BACKUP_DIR = ROOT / "assets" / "source_backups" / "moderator_fortress_visuals"
OUTPUT_DIR = ROOT / "assets" / "weapons" / "moderator_fortress"
MANIFEST_PATH = OUTPUT_DIR / "moderator_fortress_visual_manifest.json"
QC_PATH = Path(tempfile.gettempdir()) / "commentdie_moderator_fortress_visual_qc.png"

ASSETS = {
    "icon": "icon_moderator_fortress.png",
    "body": "moderator_fortress_body.png",
    "hit": "moderator_fortress_hit.png",
    "shockwave": "moderator_fortress_shockwave.png",
    "absorb": "moderator_fortress_absorb.png",
    "bodyCharged": "moderator_fortress_body_charged.png",
    "trail": "moderator_fortress_trail.png",
    "bulletBreak": "moderator_fortress_bullet_break.png",
    "shockwaveCharged": "moderator_fortress_shockwave_charged.png",
}

PANEL_ASSETS = {
    "panelCenter": "moderator_fortress_panel_center.png",
    "panelSide": "moderator_fortress_panel_side.png",
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


def is_neutral_dark_background(r: int, g: int, b: int) -> bool:
    """Match the supplied gray/black backdrop, not the blue shield interior."""
    spread = max(r, g, b) - min(r, g, b)
    return spread <= 42 and max(r, g, b) <= 225


def remove_connected_dark_background(image: Image.Image) -> Image.Image:
    """Remove only neutral pixels connected to the border of the panel asset."""
    rgba = image.convert("RGBA")
    rgb = rgba.convert("RGB")
    pixels = rgb.load()
    width, height = rgb.size
    visited = bytearray(width * height)
    background = Image.new("L", rgb.size, 0)
    background_pixels = background.load()
    queue: deque[tuple[int, int]] = deque()

    for x in range(width):
        queue.append((x, 0))
        queue.append((x, height - 1))
    for y in range(height):
        queue.append((0, y))
        queue.append((width - 1, y))

    while queue:
        x, y = queue.pop()
        index = y * width + x
        if visited[index]:
            continue
        visited[index] = 1
        r, g, b = pixels[x, y]
        if not is_neutral_dark_background(r, g, b):
            continue
        background_pixels[x, y] = 255
        if x > 0:
            queue.append((x - 1, y))
        if x + 1 < width:
            queue.append((x + 1, y))
        if y > 0:
            queue.append((x, y - 1))
        if y + 1 < height:
            queue.append((x, y + 1))

    near_background = background.filter(ImageFilter.MaxFilter(5))
    rgba_pixels = rgba.load()
    near_pixels = near_background.load()
    for y in range(height):
        for x in range(width):
            r, g, b, a = rgba_pixels[x, y]
            if background_pixels[x, y] > 0:
                rgba_pixels[x, y] = (0, 0, 0, 0)
                continue
            if near_pixels[x, y] > 0 and is_neutral_dark_background(r, g, b):
                rgba_pixels[x, y] = (r, g, b, 0)

    rgba.putalpha(rgba.getchannel("A").filter(ImageFilter.GaussianBlur(0.35)))
    rgba_pixels = rgba.load()
    for y in range(height):
        for x in range(width):
            if rgba_pixels[x, y][3] < 4:
                rgba_pixels[x, y] = (0, 0, 0, 0)
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

    panel_source_dir = Path.home() / "Desktop" / "ぜんぶコメントのせいだ設定"
    for asset_id, source_name in PANEL_ASSETS.items():
        source_path = panel_source_dir / source_name
        if not source_path.exists():
            raise FileNotFoundError(source_path)
        backup_path = BACKUP_DIR / source_name
        if not backup_path.exists():
            shutil.copy2(source_path, backup_path)

        original = Image.open(source_path).convert("RGBA")
        cleaned = remove_connected_dark_background(original)
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
            "method": "border-connected green chroma key with local edge despill; panel assets use border-connected neutral dark-background removal",
            "tightCropPadding": 16,
            "resized": False,
        },
        "assets": manifest_assets,
    }
    MANIFEST_PATH.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    make_qc_sheet(processed)
    print(f"processed {len(processed)} moderator fortress visual assets")
    print(MANIFEST_PATH)
    print(QC_PATH)


if __name__ == "__main__":
    main()
