from __future__ import annotations

from collections import deque
import json
from pathlib import Path

from PIL import Image, ImageFilter


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = Path.home() / "Desktop" / "ぜんぶコメントのせいだ設定"
OUTPUT_DIR = ROOT / "assets" / "generated" / "senior_unit_characters_v1"

SOURCES = {
    "aosumi_kyasumi_select": "きゃすみ選択画面2.png",
    "aosumi_kyasumi_gameplay_right": "きゃすみ歩き.png",
    "akarine_rizumu_select": "りずむ選択画面.png",
    "akarine_rizumu_gameplay_right": "りずむ歩き.png",
    "shizuki_miimu_select": "みぃむ選択画2.png",
    "shizuki_miimu_gameplay_right": "みぃむ歩き.png",
}


def is_green_key(r: int, g: int, b: int) -> bool:
    strongest_other = max(r, b)
    return (
        g >= 90
        and g - strongest_other >= 24
        and g >= int(r * 1.18)
        and g >= int(b * 1.14)
    )


def is_strong_green_key(r: int, g: int, b: int) -> bool:
    return g >= 150 and r <= 90 and b <= 90 and g - r >= 75 and g - b >= 75


def border_connected_green(image: Image.Image) -> Image.Image:
    rgb = image.convert("RGB")
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
        if not is_green_key(r, g, b):
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

    for y in range(height):
        for x in range(width):
            r, g, b = pixels[x, y]
            if is_strong_green_key(r, g, b):
                background_pixels[x, y] = 255
    return background


def remove_green_screen(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    background = border_connected_green(rgba)
    near_background = background.filter(ImageFilter.MaxFilter(7))
    pixels = rgba.load()
    background_pixels = background.load()
    near_pixels = near_background.load()
    width, height = rgba.size

    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            if background_pixels[x, y] > 0:
                pixels[x, y] = (0, 0, 0, 0)
                continue
            if near_pixels[x, y] == 0:
                continue

            strongest_other = max(r, b)
            green_spill = max(0, g - strongest_other)
            if green_spill <= 6:
                continue
            spill_strength = min(1.0, float(green_spill - 6) / 72.0)
            cleaned_green = min(g, strongest_other + 6)
            cleaned_alpha = round(float(a) * (1.0 - spill_strength * 0.72))
            pixels[x, y] = (r, cleaned_green, b, max(0, cleaned_alpha))

    rgba.putalpha(rgba.getchannel("A").filter(ImageFilter.GaussianBlur(0.35)))
    pixels = rgba.load()
    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            if a == 0:
                pixels[x, y] = (0, 0, 0, 0)
    return rgba


def trim_transparent(
    image: Image.Image, padding: int = 16
) -> tuple[Image.Image, tuple[int, int, int, int]]:
    alpha = image.getchannel("A")
    bbox = alpha.point(lambda value: 255 if value >= 4 else 0).getbbox()
    if bbox is None:
        raise ValueError("image has no visible pixels after green-screen removal")
    left = max(0, bbox[0] - padding)
    top = max(0, bbox[1] - padding)
    right = min(image.width, bbox[2] + padding)
    bottom = min(image.height, bbox[3] + padding)
    return image.crop((left, top, right, bottom)), (left, top, right, bottom)


def alpha_stats(image: Image.Image) -> dict[str, int]:
    histogram = image.getchannel("A").histogram()
    return {
        "transparentPixels": histogram[0],
        "partialAlphaPixels": sum(histogram[1:255]),
        "opaquePixels": histogram[255],
    }


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    manifest: dict[str, object] = {
        "schemaVersion": 1,
        "sourceDirectory": str(SOURCE_DIR),
        "processing": {
            "method": "border-connected green chroma key with edge despill",
            "tightCropPadding": 16,
        },
        "assets": [],
    }

    assets = manifest["assets"]
    assert isinstance(assets, list)
    for asset_id, source_name in SOURCES.items():
        source_path = SOURCE_DIR / source_name
        if not source_path.exists():
            raise FileNotFoundError(source_path)
        original = Image.open(source_path).convert("RGBA")
        output_path = OUTPUT_DIR / f"{asset_id}.png"
        reused_existing = output_path.exists()
        if reused_existing:
            trimmed = Image.open(output_path).convert("RGBA")
            bbox = None
        else:
            cleaned = remove_green_screen(original)
            trimmed, bbox = trim_transparent(cleaned)
            trimmed.save(output_path, optimize=True)
        assets.append(
            {
                "id": asset_id,
                "sourceFile": source_name,
                "output": output_path.relative_to(ROOT).as_posix(),
                "originalSize": list(original.size),
                "contentBoundsInSource": list(bbox) if bbox is not None else None,
                "outputSize": list(trimmed.size),
                "reusedExisting": reused_existing,
                **alpha_stats(trimmed),
            }
        )

    manifest_path = OUTPUT_DIR / "manifest.json"
    manifest_path.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"processed {len(SOURCES)} new character assets")
    print(manifest_path)


if __name__ == "__main__":
    main()
