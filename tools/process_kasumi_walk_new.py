from __future__ import annotations

from collections import deque
import json
from pathlib import Path

from PIL import Image, ImageFilter


ROOT = Path(__file__).resolve().parents[1]
DESKTOP = Path.home() / "Desktop"
SOURCE_NAME = "きゃすみ歩き新.png"
OUTPUT_PATH = ROOT / "assets" / "generated" / "senior_unit_walk_v1" / "aosumi_kyasumi" / "kyasumi-walk-new-transparent.png"
METADATA_PATH = OUTPUT_PATH.with_name("kyasumi-walk-new-transparent.json")


def find_source() -> Path:
    matches = sorted(DESKTOP.rglob(SOURCE_NAME))
    if not matches:
        raise FileNotFoundError(f"source image not found under {DESKTOP}: {SOURCE_NAME}")
    if len(matches) > 1:
        raise RuntimeError(f"multiple source images found: {matches}")
    return matches[0]


def is_green_key(r: int, g: int, b: int) -> bool:
    strongest_other = max(r, b)
    return (
        g >= 90
        and g - strongest_other >= 28
        and g >= int(r * 1.18)
        and g >= int(b * 1.14)
    )


def border_connected_green(image: Image.Image) -> Image.Image:
    rgb = image.convert("RGB")
    pixels = rgb.load()
    width, height = rgb.size
    visited = bytearray(width * height)
    mask = Image.new("L", rgb.size, 0)
    mask_pixels = mask.load()
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
        mask_pixels[x, y] = 255
        if x > 0:
            queue.append((x - 1, y))
        if x + 1 < width:
            queue.append((x + 1, y))
        if y > 0:
            queue.append((x, y - 1))
        if y + 1 < height:
            queue.append((x, y + 1))
    return mask


def remove_green_screen(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    background = border_connected_green(rgba)
    near_background = background.filter(ImageFilter.MaxFilter(5))
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
            if is_green_key(r, g, b):
                # Remove isolated green-screen spill that is separated from
                # the outer background by the character's dark outline.
                pixels[x, y] = (0, 0, 0, 0)
                continue
            if near_pixels[x, y] == 0:
                continue

            strongest_other = max(r, b)
            green_spill = max(0, g - strongest_other)
            if green_spill <= 6:
                continue
            spill_strength = min(1.0, float(green_spill - 6) / 96.0)
            cleaned_green = min(g, strongest_other + 6)
            cleaned_alpha = round(float(a) * (1.0 - spill_strength * 0.72))
            pixels[x, y] = (r, cleaned_green, b, max(0, cleaned_alpha))
    return rgba


def alpha_stats(image: Image.Image) -> dict[str, int]:
    histogram = image.getchannel("A").histogram()
    return {
        "transparentPixels": histogram[0],
        "partialAlphaPixels": sum(histogram[1:255]),
        "opaquePixels": histogram[255],
    }


def main() -> None:
    source_path = find_source()
    source = Image.open(source_path).convert("RGBA")
    output = remove_green_screen(source)
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    output.save(OUTPUT_PATH, optimize=True)
    metadata = {
        "schemaVersion": 1,
        "sourceFile": SOURCE_NAME,
        "sourceSize": list(source.size),
        "output": OUTPUT_PATH.relative_to(ROOT).as_posix(),
        "outputSize": list(output.size),
        "processing": "border-connected green chroma key with edge despill",
        "alpha": alpha_stats(output),
    }
    METADATA_PATH.write_text(json.dumps(metadata, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"processed {source_path}")
    print(OUTPUT_PATH)


if __name__ == "__main__":
    main()
