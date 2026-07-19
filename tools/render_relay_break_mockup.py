from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parents[1]
ASSET_DIR = ROOT / "assets" / "generated" / "relay_break_v1"
OUTPUT_DIR = ROOT / "docs" / "images"
FONT_REGULAR = ROOT / "assets" / "fonts" / "MPLUSRounded1c-Regular.ttf"
FONT_BLACK = ROOT / "assets" / "fonts" / "MPLUSRounded1c-Black.ttf"
BACKGROUND = ROOT / "assets" / "generated" / "maps" / "collab_studio_v2" / "collab_studio_user_1536x1024.png"


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(FONT_BLACK if bold else FONT_REGULAR), size=size)


def cover(image: Image.Image, size: tuple[int, int]) -> Image.Image:
    scale = max(size[0] / image.width, size[1] / image.height)
    resized = image.resize((round(image.width * scale), round(image.height * scale)), Image.Resampling.LANCZOS)
    left = (resized.width - size[0]) // 2
    top = (resized.height - size[1]) // 2
    return resized.crop((left, top, left + size[0], top + size[1]))


def contain(image: Image.Image, size: tuple[int, int]) -> Image.Image:
    scale = min(size[0] / image.width, size[1] / image.height)
    return image.resize((max(1, round(image.width * scale)), max(1, round(image.height * scale))), Image.Resampling.LANCZOS)


def paste_centered(canvas: Image.Image, image: Image.Image, rect: tuple[int, int, int, int]) -> None:
    x, y, width, height = rect
    resized = contain(image, (width, height))
    canvas.alpha_composite(resized, (x + (width - resized.width) // 2, y + (height - resized.height) // 2))


def text(draw: ImageDraw.ImageDraw, xy: tuple[int, int], value: str, size: int, fill: str, bold: bool = False, anchor: str | None = None) -> None:
    draw.text(xy, value, font=font(size, bold), fill=fill, stroke_width=2, stroke_fill="#fffaff", anchor=anchor)


def rounded_rect(draw: ImageDraw.ImageDraw, rect: tuple[int, int, int, int], radius: int, fill: tuple[int, int, int, int], outline: str | None = None, width: int = 1) -> None:
    draw.rounded_rectangle(rect, radius=radius, fill=fill, outline=outline, width=width)


def draw_progress(draw: ImageDraw.ImageDraw, before_boss: bool) -> None:
    rect = (280, 22, 1320, 74)
    rounded_rect(draw, rect, 16, (255, 251, 255, 242), "#ef8fbd", 3)
    labels = ["CHAT", "GAME", "SONG", "DRAW", "COLLAB", "BOSS"]
    for index, label in enumerate(labels):
        x0 = 294 + index * 168
        item = (x0, 31, x0 + 154, 65)
        cleared = index <= 4 if before_boss else index == 0
        next_item = index == 5 if before_boss else index == 1
        if next_item:
            fill = (255, 233, 194, 255) if before_boss else (221, 248, 255, 255)
            outline = "#d79538" if before_boss else "#66bde5"
            prefix = "> "
        elif cleared:
            fill = (245, 235, 244, 255)
            outline = "#d4bbcf"
            prefix = "✓ "
        else:
            fill = (239, 235, 243, 230)
            outline = "#ddcfdf"
            prefix = ""
        rounded_rect(draw, item, 10, fill, outline, 2)
        draw.text(((item[0] + item[2]) // 2, 49), prefix + label, font=font(14, True), fill="#4b2944", anchor="mm")


def draw_card(canvas: Image.Image, draw: ImageDraw.ImageDraw, kind: str, rect: tuple[int, int, int, int], selected: bool, full_hp: bool = False) -> None:
    x, y, width, height = rect
    if selected:
        glow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
        glow_draw = ImageDraw.Draw(glow)
        glow_draw.rounded_rectangle((x - 8, y - 8, x + width + 8, y + height + 10), radius=30, fill=(93, 220, 217, 76))
        glow = glow.filter(ImageFilter.GaussianBlur(10))
        canvas.alpha_composite(glow)
        y -= 4
    shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.rounded_rectangle((x + 4, y + 9, x + width + 4, y + height + 9), radius=28, fill=(71, 40, 76, 48))
    shadow = shadow.filter(ImageFilter.GaussianBlur(7))
    canvas.alpha_composite(shadow)

    card = Image.open(ASSET_DIR / f"card_{kind}.png").convert("RGBA")
    paste_centered(canvas, card, (x, y, width, height))
    if selected:
        draw.rounded_rectangle((x + 6, y + 6, x + width - 6, y + height - 6), radius=25, outline="#55cdd2", width=4)

    icon = Image.open(ASSET_DIR / f"icon_{kind}.png").convert("RGBA")
    paste_centered(canvas, icon, (x + 140, y + 14, 110, 104))
    center_x = x + width // 2
    if kind == "heal":
        text(draw, (center_x, y + 130), "ひと休みする", 25, "#274e54", True, "mm")
        text(draw, (center_x, y + 164), "メンタルを30％回復", 17, "#477378", False, "mm")
        rounded_rect(draw, (x + 60, y + 194, x + width - 60, y + 236), 18, (255, 255, 255, 220))
        preview = "100 / 100" if full_hp else "HP 34 / 100  →  64 / 100"
        text(draw, (center_x, y + 215), preview, 18, "#225968", True, "mm")
    else:
        text(draw, (center_x, y + 130), "ギフトを開ける", 25, "#7a315c", True, "mm")
        text(draw, (center_x, y + 164), "武器・アクセを強化", 17, "#7d5269", False, "mm")
        rounded_rect(draw, (x + 86, y + 194, x + width - 86, y + 236), 18, (255, 255, 255, 218))
        text(draw, (center_x, y + 215), "3つから1つ選択", 17, "#76506a", True, "mm")


def render(before_boss: bool) -> Path:
    if BACKGROUND.exists():
        base = cover(Image.open(BACKGROUND).convert("RGBA"), (1600, 900))
    else:
        base = Image.new("RGBA", (1600, 900), (72, 56, 83, 255))
    dim = Image.new("RGBA", base.size, (26, 20, 38, 124))
    canvas = Image.alpha_composite(base, dim)
    draw = ImageDraw.Draw(canvas)
    draw_progress(draw, before_boss)

    panel = Image.open(ASSET_DIR / "panel_frame.png").convert("RGBA")
    paste_centered(canvas, panel, (260, 142, 1080, 568))

    character = Image.open(ASSET_DIR / "character_supana.png").convert("RGBA")
    paste_centered(canvas, character, (232, 365, 250, 330))

    text(draw, (338, 199), "BREAK TIME", 17, "#df5790", True)
    title = "最終決戦に備えよう！" if before_boss else "ちょっと休憩！"
    subtitle = "選択後、ラストオフラインへ" if before_boss else "次の配信に備えよう"
    text(draw, (338, 232), title, 34, "#5b3156", True)
    text(draw, (340, 273), subtitle, 17, "#7b6479")

    previous = "コラボ枠 CLEAR!" if before_boss else "雑談枠 CLEAR!"
    next_label = "次は「ラストオフライン」" if before_boss else "次は「ゲーム実況枠」"
    text(draw, (1256, 212), previous, 18, "#a95f8b", True, "ra")
    text(draw, (1256, 250), next_label, 22, "#4c476e", True, "ra")

    if before_boss:
        accent = Image.open(ASSET_DIR / "boss_accent.png").convert("RGBA")
        paste_centered(canvas, accent, (346, 282, 908, 48))

    draw_card(canvas, draw, "heal", (386, 326, 390, 260), True)
    draw_card(canvas, draw, "gift", (824, 326, 390, 260), False)
    rounded_rect(draw, (435, 628, 1165, 670), 18, (255, 255, 255, 205))
    text(draw, (800, 649), "← → / A D：選択　　Enter / Space：決定", 17, "#66526b", True, "mm")

    output = OUTPUT_DIR / ("relay_break_boss_mockup.png" if before_boss else "relay_break_mockup.png")
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    canvas.convert("RGB").save(output, quality=95)
    return output


def main() -> None:
    print(render(False))
    print(render(True))


if __name__ == "__main__":
    main()
