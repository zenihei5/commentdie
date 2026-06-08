from __future__ import annotations

from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
OUTPUT_DIR = ROOT / "assets" / "generated" / "enemy_sprites_v1"

SOURCES = [
    ("troll", Path(r"C:\Users\zenih\Desktop\enemy1.png")),
    ("rapid_poster", Path(r"C:\Users\zenih\Desktop\enemy2.png")),
    ("backseat_commenter", Path(r"C:\Users\zenih\Desktop\enemy3.png")),
    ("long_comment_guy", Path(r"C:\Users\zenih\Desktop\enemy4.png")),
    ("clipper", Path(r"C:\Users\zenih\Desktop\enemy5.png")),
    ("unread_maro", Path(r"C:\Users\zenih\Desktop\enemy6.png")),
    ("ghost_comment", Path(r"C:\Users\zenih\Desktop\enemy7.png")),
]


def green_screen_alpha(pixel: tuple[int, int, int, int]) -> int:
    r, g, b, a = pixel
    if a == 0:
        return 0
    green_dominance = g - max(r, b)
    if g > 150 and green_dominance > 45:
        return 0
    if g > 115 and green_dominance > 25 and r < 120 and b < 120:
        return 0
    return a


def content_bbox(image: Image.Image) -> tuple[int, int, int, int]:
    alpha = image.getchannel("A")
    bbox = alpha.getbbox()
    if bbox is None:
        raise ValueError("image has no visible pixels after chroma key")
    return bbox


def process(src: Path, dst: Path) -> None:
    image = Image.open(src).convert("RGBA")
    pixels = image.load()
    width, height = image.size
    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            alpha = green_screen_alpha((r, g, b, a))
            pixels[x, y] = (r, g, b, alpha)

    bbox = content_bbox(image)
    crop = image.crop(bbox)

    canvas_size = 256
    max_body = 188
    scale = min(max_body / crop.width, max_body / crop.height)
    new_size = (max(1, round(crop.width * scale)), max(1, round(crop.height * scale)))
    crop = crop.resize(new_size, Image.Resampling.NEAREST)

    canvas = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    x = (canvas_size - crop.width) // 2
    y = canvas_size - crop.height - 34
    canvas.alpha_composite(crop, (x, y))
    canvas.save(dst)


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    for name, source in SOURCES:
        if not source.exists():
            raise FileNotFoundError(source)
        process(source, OUTPUT_DIR / f"{name}.png")
    print(f"processed {len(SOURCES)} enemy sprites -> {OUTPUT_DIR}")


if __name__ == "__main__":
    main()
