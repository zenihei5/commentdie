from __future__ import annotations

import hashlib
import json
from pathlib import Path
import shutil
import tempfile

from PIL import Image, ImageDraw, ImageFont

from process_new_character_assets import (
    alpha_stats,
    remove_green_screen,
    trim_transparent,
)


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = (
    Path.home()
    / "Desktop"
    / "\u305c\u3093\u3076\u30b3\u30e1\u30f3\u30c8"
    "\u306e\u305b\u3044\u3060\u8a2d\u5b9a"
)
BACKUP_DIR = ROOT / "assets" / "source_backups" / "stage2_weapon_visuals"
MANIFEST_PATH = ROOT / "assets" / "weapons" / "stage2_weapon_visual_manifest.json"
QC_PATH = Path(tempfile.gettempdir()) / "commentdie_stage2_weapon_visual_qc.png"

ASSETS = {
    "moderator_shield_body": (
        "moderator_shield_body.png",
        "assets/weapons/moderator_shield/moderator_shield_body.png",
    ),
    "moderator_shield_trail": (
        "moderator_shield_trail.png",
        "assets/weapons/moderator_shield/moderator_shield_trail.png",
    ),
    "moderator_shield_bullet_clear": (
        "moderator_shield_bullet_clear.png",
        "assets/weapons/moderator_shield/moderator_shield_bullet_clear.png",
    ),
    "moderator_shield_end_shockwave": (
        "moderator_shield_end_shockwave.png",
        "assets/weapons/moderator_shield/moderator_shield_end_shockwave.png",
    ),
    "fansa_baton_body": (
        "fansa_baton_body.png",
        "assets/weapons/fansa_baton/fansa_baton_body.png",
    ),
    "fansa_baton_swing_right": (
        "fansa_baton_swing_right.png",
        "assets/weapons/fansa_baton/fansa_baton_swing_right.png",
    ),
    "fansa_baton_swing_left": (
        "fansa_baton_swing_left.png",
        "assets/weapons/fansa_baton/fansa_baton_swing_left.png",
    ),
    "fansa_baton_finisher": (
        "fansa_baton_finisher.png",
        "assets/weapons/fansa_baton/fansa_baton_finisher.png",
    ),
    "fansa_baton_x_slash": (
        "fansa_baton_x_slash.png",
        "assets/weapons/fansa_baton/fansa_baton_x_slash.png",
    ),
    "tsuri_thumbnail_rod_body": (
        "tsuri_thumbnail_rod_body.png",
        "assets/weapons/tsuri_thumbnail_rod/tsuri_thumbnail_rod_body.png",
    ),
    "tsuri_thumbnail_bear_lure": (
        "tsuri_thumbnail_bear_lure.png",
        "assets/weapons/tsuri_thumbnail_rod/tsuri_thumbnail_bear_lure.png",
    ),
    "tsuri_thumbnail_gather": (
        "tsuri_thumbnail_gather.png",
        "assets/weapons/tsuri_thumbnail_rod/tsuri_thumbnail_gather.png",
    ),
    "tsuri_thumbnail_reel_hit": (
        "tsuri_thumbnail_reel_hit.png",
        "assets/weapons/tsuri_thumbnail_rod/tsuri_thumbnail_reel_hit.png",
    ),
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
    border_crops = [
        alpha.crop((0, 0, width, 1)),
        alpha.crop((0, height - 1, width, height)),
        alpha.crop((0, 0, 1, height)),
        alpha.crop((width - 1, 0, width, height)),
    ]
    return sum(sum(crop.histogram()[4:]) for crop in border_crops)


def checkerboard(size: tuple[int, int], cell: int = 12) -> Image.Image:
    image = Image.new("RGBA", size, (225, 229, 239, 255))
    draw = ImageDraw.Draw(image)
    for y in range(0, size[1], cell):
        for x in range(0, size[0], cell):
            if (x // cell + y // cell) % 2:
                draw.rectangle(
                    (x, y, x + cell - 1, y + cell - 1),
                    fill=(194, 201, 216, 255),
                )
    return image


def make_qc_sheet(processed: list[tuple[str, Image.Image]]) -> None:
    columns = 3
    tile_width = 360
    tile_height = 250
    rows = (len(processed) + columns - 1) // columns
    sheet = Image.new(
        "RGBA",
        (columns * tile_width, rows * tile_height),
        (28, 31, 43, 255),
    )
    font = ImageFont.load_default()

    for index, (asset_id, image) in enumerate(processed):
        x = (index % columns) * tile_width
        y = (index // columns) * tile_height
        preview = checkerboard((tile_width - 20, tile_height - 42))
        fitted = image.copy()
        fitted.thumbnail((tile_width - 44, tile_height - 66), Image.Resampling.LANCZOS)
        paste_x = (preview.width - fitted.width) // 2
        paste_y = (preview.height - fitted.height) // 2
        preview.alpha_composite(fitted, (paste_x, paste_y))
        sheet.alpha_composite(preview, (x + 10, y + 30))
        draw = ImageDraw.Draw(sheet)
        draw.text((x + 12, y + 10), asset_id, fill=(242, 244, 252), font=font)

    sheet.convert("RGB").save(QC_PATH, quality=94)


def main() -> None:
    BACKUP_DIR.mkdir(parents=True, exist_ok=True)
    processed: list[tuple[str, Image.Image]] = []
    manifest_assets: list[dict[str, object]] = []

    for asset_id, (source_name, output_relative) in ASSETS.items():
        source_path = SOURCE_DIR / source_name
        if not source_path.exists():
            raise FileNotFoundError(source_path)

        backup_path = BACKUP_DIR / source_name
        if not backup_path.exists():
            shutil.copy2(source_path, backup_path)

        output_path = ROOT / output_relative
        output_path.parent.mkdir(parents=True, exist_ok=True)

        original = Image.open(source_path).convert("RGBA")
        cleaned = remove_green_screen(original)
        trimmed, bounds = trim_transparent(cleaned, padding=16)
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
        "assets": manifest_assets,
    }
    MANIFEST_PATH.parent.mkdir(parents=True, exist_ok=True)
    MANIFEST_PATH.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    make_qc_sheet(processed)

    print(f"processed {len(processed)} weapon visual assets")
    print(MANIFEST_PATH)
    print(QC_PATH)


if __name__ == "__main__":
    main()
