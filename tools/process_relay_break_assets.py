from __future__ import annotations

from collections import deque
import json
from pathlib import Path

from PIL import Image, ImageFilter


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = Path(r"C:\Users\zenih\Desktop\ぜんぶコメントのせいだ設定\配信リレー")
OUTPUT_DIR = ROOT / "assets" / "generated" / "relay_break_v1"

SOURCES = {
    "panel_frame": "休憩大枠.png",
    "card_heal": "休憩_回復選択カード背景.png",
    "card_gift": "休憩_ギフト選択カード背景.png",
    "icon_heal": "休憩_回復アイコン.png",
    "icon_gift": "休憩_ギフトアイコン.png",
    "character_supana": "休憩_すぱな.png",
    "character_maron": "休憩_まろん.png",
    "character_banri": "休憩_ばんり.png",
    "boss_accent": "休憩_最終ボス前アクセント.png",
    "decoration_atlas": "休憩_装飾アイコン.png",
}

# Regions are measured against the 1448x1086 decoration source. Each crop keeps
# detached highlights that belong to the same icon.
DECORATION_REGIONS = {
    "heart_pink": (120, 150, 405, 440),
    "heart_mint": (560, 150, 865, 445),
    "steam": (1000, 135, 1275, 470),
    "sparkle_gold": (90, 585, 335, 885),
    "sparkle_blue": (390, 585, 630, 885),
    "orb_mint": (660, 560, 990, 920),
    "mug_pink": (1030, 555, 1355, 935),
}


def _is_green_key(r: int, g: int, b: int) -> bool:
    strongest_other = max(r, b)
    return (
        g >= 90
        and g - strongest_other >= 24
        and g >= int(r * 1.18)
        and g >= int(b * 1.14)
    )


def _is_strong_green_key(r: int, g: int, b: int) -> bool:
    # Closed gaps inside hair, arms, or legs are not reachable from the canvas
    # border. The screen green is highly saturated, unlike the mint costume art.
    return g >= 150 and r <= 90 and b <= 90 and g - r >= 75 and g - b >= 75


def _border_connected_green(image: Image.Image) -> Image.Image:
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
        if not _is_green_key(r, g, b):
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
            if _is_strong_green_key(r, g, b):
                background_pixels[x, y] = 255

    return background


def remove_green_screen(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    background = _border_connected_green(rgba)
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

    alpha = rgba.getchannel("A").filter(ImageFilter.GaussianBlur(0.35))
    rgba.putalpha(alpha)

    # Transparent RGB is zeroed so texture filtering cannot pull green into the edge.
    pixels = rgba.load()
    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            if a == 0:
                pixels[x, y] = (0, 0, 0, 0)
    return rgba


def trim_transparent(image: Image.Image, padding: int = 8) -> tuple[Image.Image, tuple[int, int, int, int]]:
    alpha = image.getchannel("A")
    thresholded = alpha.point(lambda value: 255 if value >= 4 else 0)
    bbox = thresholded.getbbox()
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


def save_processed(name: str, source_name: str) -> tuple[Image.Image, dict]:
    source_path = SOURCE_DIR / source_name
    if not source_path.exists():
        raise FileNotFoundError(source_path)
    original = Image.open(source_path).convert("RGBA")
    cleaned_full = remove_green_screen(original)
    trimmed, bbox = trim_transparent(cleaned_full)
    output_path = OUTPUT_DIR / f"{name}.png"
    trimmed.save(output_path, optimize=True)
    return cleaned_full, {
        "id": name,
        "sourceFile": source_name,
        "output": output_path.relative_to(ROOT).as_posix(),
        "originalSize": list(original.size),
        "contentBoundsInSource": list(bbox),
        "outputSize": list(trimmed.size),
        **alpha_stats(trimmed),
    }


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    decorations_dir = OUTPUT_DIR / "decorations"
    decorations_dir.mkdir(parents=True, exist_ok=True)
    manifest: dict[str, object] = {
        "schemaVersion": 1,
        "sourceDirectory": str(SOURCE_DIR),
        "processing": {
            "method": "border-connected green chroma key with edge despill",
            "tightCropPadding": 8,
        },
        "assets": [],
        "decorationCuts": [],
    }

    decoration_full: Image.Image | None = None
    for name, source_name in SOURCES.items():
        cleaned_full, item = save_processed(name, source_name)
        assets = manifest["assets"]
        assert isinstance(assets, list)
        assets.append(item)
        if name == "decoration_atlas":
            decoration_full = cleaned_full

    if decoration_full is None:
        raise RuntimeError("decoration atlas was not processed")

    cuts = manifest["decorationCuts"]
    assert isinstance(cuts, list)
    for name, region in DECORATION_REGIONS.items():
        cut = decoration_full.crop(region)
        trimmed, content_bbox = trim_transparent(cut, padding=6)
        output_path = decorations_dir / f"{name}.png"
        trimmed.save(output_path, optimize=True)
        cuts.append({
            "id": name,
            "sourceRegion": list(region),
            "contentBoundsInRegion": list(content_bbox),
            "output": output_path.relative_to(ROOT).as_posix(),
            "outputSize": list(trimmed.size),
            **alpha_stats(trimmed),
        })

    manifest_path = OUTPUT_DIR / "manifest.json"
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"processed {len(SOURCES)} relay break assets and {len(DECORATION_REGIONS)} decoration cuts")
    print(manifest_path)


if __name__ == "__main__":
    main()
