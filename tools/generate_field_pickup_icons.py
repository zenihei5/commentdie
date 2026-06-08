from __future__ import annotations

from pathlib import Path
from math import sin, cos, pi

from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "generated" / "field_pickup_icons_v1" / "icons"
PREVIEW = ROOT / "assets" / "generated" / "field_pickup_icons_v1" / "preview.png"


def font(size: int, bold: bool = True) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = [
        Path("C:/Windows/Fonts/meiryo.ttc"),
        Path("C:/Windows/Fonts/YuGothB.ttc"),
        Path("C:/Windows/Fonts/arialbd.ttf" if bold else "arial.ttf"),
    ]
    for path in candidates:
        if path.exists():
            return ImageFont.truetype(str(path), size)
    return ImageFont.load_default()


def canvas(size: int = 96) -> Image.Image:
    return Image.new("RGBA", (size, size), (0, 0, 0, 0))


def glow_layer(size: int, color: tuple[int, int, int, int], radius: int = 18) -> Image.Image:
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse((18, 18, size - 18, size - 18), fill=color)
    return img.filter(ImageFilter.GaussianBlur(radius))


def text_center(draw: ImageDraw.ImageDraw, box, text: str, fnt, fill, stroke_fill=None, stroke_width=0) -> None:
    bbox = draw.textbbox((0, 0), text, font=fnt, stroke_width=stroke_width)
    x = box[0] + (box[2] - box[0] - (bbox[2] - bbox[0])) / 2
    y = box[1] + (box[3] - box[1] - (bbox[3] - bbox[1])) / 2 - 1
    draw.text((x, y), text, font=fnt, fill=fill, stroke_fill=stroke_fill, stroke_width=stroke_width)


def save(img: Image.Image, name: str) -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    img.save(OUT / name)


def rounded_rect_icon(fill, outline, ribbon=None, label: str = "") -> Image.Image:
    img = canvas()
    img.alpha_composite(glow_layer(96, (*outline[:3], 90), 12))
    d = ImageDraw.Draw(img)
    d.rounded_rectangle((22, 24, 74, 76), radius=9, fill=fill, outline=outline, width=4)
    if ribbon:
        d.rectangle((44, 24, 52, 76), fill=ribbon)
        d.rectangle((22, 45, 74, 53), fill=ribbon)
        d.line((31, 23, 48, 12), fill=ribbon, width=5)
        d.line((65, 23, 48, 12), fill=ribbon, width=5)
        d.line((31, 23, 48, 12), fill=(255, 255, 255, 120), width=2)
    if label:
        text_center(d, (22, 51, 74, 77), label, font(18), (92, 45, 22, 255))
    return img


def care_package() -> Image.Image:
    return rounded_rect_icon((255, 215, 105, 255), (126, 67, 28, 255), (255, 78, 135, 255), "差")


def viewer_boost() -> Image.Image:
    img = canvas()
    img.alpha_composite(glow_layer(96, (55, 217, 255, 110), 15))
    d = ImageDraw.Draw(img)
    d.ellipse((20, 24, 76, 80), fill=(230, 252, 255, 255), outline=(30, 160, 210, 255), width=4)
    for x, y, r in [(38, 45, 8), (58, 45, 8), (48, 35, 9)]:
        d.ellipse((x - r, y - r, x + r, y + r), fill=(0, 133, 185, 255))
    d.rounded_rectangle((27, 54, 69, 68), radius=8, fill=(0, 133, 185, 255))
    text_center(d, (22, 66, 74, 90), "+500", font(18), (255, 255, 255, 255), (0, 102, 150, 255), 2)
    return img


def heal_drink() -> Image.Image:
    img = canvas()
    img.alpha_composite(glow_layer(96, (60, 224, 109, 105), 14))
    d = ImageDraw.Draw(img)
    d.rounded_rectangle((35, 20, 61, 76), radius=8, fill=(42, 216, 107, 255), outline=(238, 255, 245, 255), width=4)
    d.rectangle((40, 13, 56, 24), fill=(210, 255, 238, 255), outline=(56, 166, 105, 255), width=2)
    d.rectangle((45, 34, 51, 62), fill=(255, 255, 255, 255))
    d.rectangle((37, 45, 59, 51), fill=(255, 255, 255, 255))
    text_center(d, (22, 68, 74, 90), "HP", font(18), (255, 255, 255, 255), (20, 121, 61, 255), 2)
    return img


def heart_drop() -> Image.Image:
    img = canvas()
    img.alpha_composite(glow_layer(96, (255, 95, 168, 120), 13))
    d = ImageDraw.Draw(img)
    f = font(56)
    text_center(d, (8, 8, 88, 82), "\u2661", f, (255, 79, 155, 255), (255, 255, 255, 255), 3)
    for x, y in [(27, 28), (70, 27), (65, 67)]:
        d.ellipse((x - 3, y - 3, x + 3, y + 3), fill=(255, 180, 215, 220))
    return img


def marshmallow(name: str, fill, outline, accent=None, bad: bool = False, god: bool = False) -> Image.Image:
    img = canvas()
    glow = (255, 229, 120, 120) if god else ((*outline[:3], 80) if not bad else (30, 0, 45, 105))
    img.alpha_composite(glow_layer(96, glow, 13))
    d = ImageDraw.Draw(img)
    body = (24, 25, 72, 72)
    if bad:
        body = (23, 27, 74, 72)
        points = [(25, 37), (32, 25), (48, 29), (62, 24), (73, 38), (67, 71), (43, 74), (24, 64)]
        d.polygon(points, fill=fill, outline=outline)
        d.line(points + [points[0]], fill=outline, width=4)
    else:
        d.rounded_rectangle(body, radius=19, fill=fill, outline=outline, width=4)
    d.ellipse((35, 41, 41, 47), fill=(84, 64, 94, 255))
    d.ellipse((55, 41, 61, 47), fill=(84, 64, 94, 255))
    d.arc((39, 43, 58, 62), start=18, end=162, fill=(84, 64, 94, 255), width=3)
    d.ellipse((31, 31, 48, 43), fill=(255, 255, 255, 82))
    if accent == "heart":
        text_center(d, (57, 20, 85, 45), "\u2661", font(22), (255, 82, 150, 255), (255, 255, 255, 255), 2)
    elif accent == "star":
        text_center(d, (56, 18, 86, 44), "★", font(21), (255, 188, 45, 255), (255, 255, 255, 255), 2)
    elif accent == "rainbow":
        for i, c in enumerate([(255, 80, 120), (255, 205, 68), (88, 220, 255)]):
            d.arc((18 + i * 4, 17 + i * 4, 78 - i * 4, 77 - i * 4), 210, 320, fill=(*c, 220), width=3)
        text_center(d, (56, 18, 88, 45), "★", font(22), (255, 240, 90, 255), (122, 70, 0, 255), 2)
    elif accent == "smoke":
        for x in [24, 69]:
            d.arc((x - 7, 15, x + 10, 35), 230, 70, fill=(45, 20, 60, 190), width=3)
    elif accent == "leaf":
        d.polygon([(65, 19), (80, 26), (68, 36)], fill=(95, 190, 105, 230))
    elif accent == "burn":
        d.polygon([(62, 16), (72, 39), (58, 34), (68, 61), (48, 37)], fill=(255, 68, 50, 230))
    if bad:
        d.line((32, 36, 42, 40), fill=(40, 20, 45, 255), width=3)
        d.line((64, 36, 54, 40), fill=(40, 20, 45, 255), width=3)
    return img


def make_preview(names: list[str]) -> None:
    cols = 4
    cell = 120
    rows = (len(names) + cols - 1) // cols
    img = Image.new("RGBA", (cols * cell, rows * cell), (245, 248, 255, 255))
    d = ImageDraw.Draw(img)
    for idx, name in enumerate(names):
        icon = Image.open(OUT / name).convert("RGBA")
        x = (idx % cols) * cell
        y = (idx // cols) * cell
        img.alpha_composite(icon, (x + 12, y + 2))
        text_center(d, (x + 0, y + 88, x + cell, y + 118), name.replace(".png", ""), font(12, False), (30, 42, 58, 255))
    PREVIEW.parent.mkdir(parents=True, exist_ok=True)
    img.save(PREVIEW)


def main() -> None:
    icons = {
        "care_package_box.png": care_package(),
        "viewer_boost.png": viewer_boost(),
        "heal_drink.png": heal_drink(),
        "heart_drop.png": heart_drop(),
        "marshmallow_normal_white.png": marshmallow("normal", (255, 248, 238, 255), (235, 205, 222, 255)),
        "marshmallow_pink_heart.png": marshmallow("pink", (255, 213, 232, 255), (255, 118, 170, 255), "heart"),
        "marshmallow_cream_star.png": marshmallow("cream", (255, 242, 182, 255), (245, 184, 72, 255), "star"),
        "marshmallow_gold_rainbow.png": marshmallow("gold", (255, 230, 100, 255), (198, 132, 0, 255), "rainbow", god=True),
        "marshmallow_gray_bad.png": marshmallow("gray", (138, 132, 136, 255), (62, 54, 64, 255), None, bad=True),
        "marshmallow_purple_smoke.png": marshmallow("purple", (119, 80, 160, 255), (45, 24, 68, 255), "smoke", bad=True),
        "marshmallow_green_bad.png": marshmallow("green", (123, 166, 106, 255), (46, 89, 50, 255), "leaf", bad=True),
        "marshmallow_burnt_bad.png": marshmallow("burnt", (55, 32, 37, 255), (144, 38, 34, 255), "burn", bad=True),
    }
    for name, img in icons.items():
        save(img, name)
    make_preview(list(icons.keys()))


if __name__ == "__main__":
    main()
