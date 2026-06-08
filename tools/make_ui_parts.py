from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter, ImageFont


OUT_DIR = "assets/generated/ui_parts_v1"
GIFT_PANEL_AI_SOURCE = f"{OUT_DIR}/gift_choice_panel_ai_source.png"
GIFT_TITLE_AI = f"{OUT_DIR}/gift_choice_title_ai.png"
COMMENT_PANEL_AI_SOURCE = f"{OUT_DIR}/comment_choice_panel_ai_source.png"
COMMENT_TITLE_AI = f"{OUT_DIR}/comment_choice_title_ai.png"
FONT_BOLD = "C:/Windows/Fonts/BIZ-UDGothicB.ttc"
FONT_FALLBACK = "C:/Windows/Fonts/meiryob.ttc"
FONT_REGULAR = "C:/Windows/Fonts/BIZ-UDGothicR.ttc"


def load_font(size, bold=True):
    paths = [FONT_BOLD if bold else FONT_REGULAR, FONT_FALLBACK, "C:/Windows/Fonts/meiryob.ttc"]
    for path in paths:
        try:
            return ImageFont.truetype(path, size)
        except Exception:
            continue
    return ImageFont.load_default()


def rounded_panel(size, radius, fill, border, border_width, shadow=True):
    w, h = size
    pad = 10 if shadow else 0
    img = Image.new("RGBA", (w + pad * 2, h + pad * 2), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    rect = (pad, pad, pad + w - 1, pad + h - 1)
    if shadow:
        shadow_layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
        sdraw = ImageDraw.Draw(shadow_layer)
        sdraw.rounded_rectangle(
            (rect[0] + 2, rect[1] + 4, rect[2] + 2, rect[3] + 4),
            radius=radius,
            fill=(80, 120, 180, 70),
        )
        img.alpha_composite(shadow_layer.filter(ImageFilter.GaussianBlur(6)))
    draw.rounded_rectangle(rect, radius=radius, fill=fill, outline=border, width=border_width)
    return img


def make_comment_panel():
    # Matches Game.SIDE: Rect2(1210, 110, 370, 650)
    w, h = 370, 650
    img = rounded_panel(
        (w, h),
        radius=16,
        fill=(252, 254, 255, 238),
        border=(255, 83, 151, 255),
        border_width=4,
    )
    draw = ImageDraw.Draw(img)
    pad = 10
    x0, y0 = pad, pad
    x1, y1 = pad + w - 1, pad + h - 1

    # Header pill and soft top sheen.
    draw.rounded_rectangle((x0 + 14, y0 + 12, x0 + 58, y0 + 42), radius=12, fill=(255, 72, 135, 255))
    draw.ellipse((x0 + 24, y0 + 21, x0 + 30, y0 + 27), fill=(255, 255, 255, 230))
    draw.ellipse((x0 + 34, y0 + 21, x0 + 40, y0 + 27), fill=(255, 255, 255, 230))
    draw.ellipse((x0 + 44, y0 + 21, x0 + 50, y0 + 27), fill=(255, 255, 255, 230))
    draw.rounded_rectangle((x1 - 76, y0 + 12, x1 - 16, y0 + 42), radius=12, fill=(255, 218, 233, 255))
    for i in range(3):
        draw.ellipse((x1 - 58 + i * 14, y0 + 24, x1 - 53 + i * 14, y0 + 29), fill=(255, 83, 151, 255))

    # Header divider.
    draw.line((x0 + 18, y0 + 50, x1 - 18, y0 + 50), fill=(207, 224, 244, 255), width=2)

    # Comment rows: dots + separators. Godot text is drawn above these.
    row_y = y0 + 72
    for i in range(14):
        cy = row_y + i * 38
        draw.ellipse((x0 + 24, cy - 9, x0 + 42, cy + 9), fill=(216, 224, 236, 255))
        draw.line((x0 + 56, cy + 14, x1 - 54, cy + 14), fill=(214, 225, 238, 220), width=1)

    # Scrollbar.
    track = (x1 - 26, y0 + 68, x1 - 18, y1 - 92)
    draw.rounded_rectangle(track, radius=4, fill=(255, 220, 235, 255))
    draw.rounded_rectangle((track[0], track[1] + 20, track[2], track[1] + 310), radius=4, fill=(255, 72, 135, 255))

    # Input bar.
    draw.rounded_rectangle((x0 + 18, y1 - 58, x1 - 64, y1 - 18), radius=13, fill=(255, 255, 255, 255), outline=(186, 200, 220, 255), width=2)
    draw.rounded_rectangle((x1 - 56, y1 - 58, x1 - 18, y1 - 18), radius=13, fill=(255, 237, 246, 255), outline=(255, 83, 151, 255), width=2)
    draw.polygon([(x1 - 43, y1 - 43), (x1 - 27, y1 - 38), (x1 - 41, y1 - 29)], fill=(255, 83, 151, 255))

    # Decorative stars/confetti kept sparse so text stays readable.
    decorations = [
        (x1 - 20, y0 + 8, (65, 176, 230, 255)),
        (x0 + 8, y1 - 24, (255, 145, 200, 255)),
        (x1 - 44, y0 + 54, (255, 205, 90, 255)),
    ]
    for x, y, color in decorations:
        draw.polygon([(x, y - 7), (x + 3, y - 2), (x + 8, y), (x + 3, y + 2), (x, y + 7), (x - 3, y + 2), (x - 8, y), (x - 3, y - 2)], fill=color)

    img.save(f"{OUT_DIR}/comment_panel_frame.png")


def draw_star(draw, x, y, color):
    draw.polygon(
        [
            (x, y - 7),
            (x + 3, y - 2),
            (x + 8, y),
            (x + 3, y + 2),
            (x, y + 7),
            (x - 3, y + 2),
            (x - 8, y),
            (x - 3, y - 2),
        ],
        fill=color,
    )


def draw_centered_text(draw, text, center_x, y, font, fill, stroke_fill=None, stroke_width=0):
    bbox = draw.textbbox((0, 0), text, font=font, stroke_width=stroke_width)
    x = center_x - (bbox[2] - bbox[0]) / 2
    draw.text((x, y), text, font=font, fill=fill, stroke_fill=stroke_fill, stroke_width=stroke_width)


def draw_pop_title(draw, text, center_x, y, font):
    bbox = draw.textbbox((0, 0), text, font=font, stroke_width=12)
    x = center_x - (bbox[2] - bbox[0]) / 2
    # Layered pop lettering: drop shadow, dark rim, white sticker edge,
    # candy-pink body, then a small upper highlight for a glossier title.
    for ox, oy, alpha in [(5, 7, 130), (3, 5, 185), (0, 4, 95)]:
        draw.text(
            (x + ox, y + oy),
            text,
            font=font,
            fill=(118, 22, 68, alpha),
            stroke_fill=(118, 22, 68, alpha),
            stroke_width=11,
        )
    draw.text(
        (x + 1, y + 2),
        text,
        font=font,
        fill=(255, 64, 136, 255),
        stroke_fill=(157, 25, 82, 255),
        stroke_width=10,
    )
    draw.text(
        (x, y),
        text,
        font=font,
        fill=(255, 82, 154, 255),
        stroke_fill=(255, 255, 255, 255),
        stroke_width=7,
    )
    draw.text(
        (x, y),
        text,
        font=font,
        fill=(255, 58, 137, 255),
        stroke_fill=(255, 174, 211, 255),
        stroke_width=2,
    )
    draw.text(
        (x - 1, y - 4),
        text,
        font=font,
        fill=(255, 255, 255, 86),
        stroke_fill=(255, 255, 255, 28),
        stroke_width=1,
    )


def draw_warning_title(draw, text, center_x, y, font):
    bbox = draw.textbbox((0, 0), text, font=font, stroke_width=10)
    x = center_x - (bbox[2] - bbox[0]) / 2
    for ox, oy, alpha in [(5, 7, 150), (2, 4, 220)]:
        draw.text(
            (x + ox, y + oy),
            text,
            font=font,
            fill=(30, 0, 0, alpha),
            stroke_fill=(30, 0, 0, alpha),
            stroke_width=10,
        )
    draw.text(
        (x + 1, y + 1),
        text,
        font=font,
        fill=(255, 128, 26, 255),
        stroke_fill=(20, 0, 0, 255),
        stroke_width=9,
    )
    draw.text(
        (x, y),
        text,
        font=font,
        fill=(255, 235, 92, 255),
        stroke_fill=(255, 255, 255, 255),
        stroke_width=4,
    )
    draw.text(
        (x, y + 2),
        text,
        font=font,
        fill=(255, 72, 40, 255),
        stroke_fill=(125, 0, 0, 255),
        stroke_width=2,
    )


def paste_ai_gift_title(img, fallback_draw, center_x, y, target_width, fallback_font):
    title_path = Path(GIFT_TITLE_AI)
    if not title_path.exists():
        draw_pop_title(fallback_draw, "ギフトが届いた！", center_x, y + 22, fallback_font)
        return

    title = Image.open(title_path).convert("RGBA")
    ratio = target_width / float(title.width)
    target_height = max(1, int(title.height * ratio))
    title = title.resize((target_width, target_height), Image.Resampling.LANCZOS)
    paste_x = int(center_x - target_width / 2)
    paste_y = int(y)
    img.alpha_composite(title, (paste_x, paste_y))


def paste_ai_comment_title(img, fallback_draw, center_x, y, target_width, max_height, fallback_font):
    title_path = Path(COMMENT_TITLE_AI)
    if not title_path.exists():
        draw_warning_title(fallback_draw, "指示コメントが来た!!", center_x, y + 8, fallback_font)
        return

    title = Image.open(title_path).convert("RGBA")
    alpha_bbox = title.getchannel("A").getbbox()
    if alpha_bbox:
        title = title.crop(alpha_bbox)
    ratio = target_width / float(title.width)
    target_height = max(1, int(title.height * ratio))
    if target_height > max_height:
        ratio = max_height / float(title.height)
        target_width = max(1, int(title.width * ratio))
        target_height = max_height
    title = title.resize((target_width, target_height), Image.Resampling.LANCZOS)
    paste_x = int(center_x - target_width / 2)
    paste_y = int(y)
    img.alpha_composite(title, (paste_x, paste_y))


def draw_gift_icon(draw, x, y):
    # Pink present icon for the gift selection header.
    draw.rounded_rectangle((x + 4, y + 28, x + 74, y + 90), radius=8, fill=(255, 82, 151, 255), outline=(255, 255, 255, 255), width=4)
    draw.rounded_rectangle((x, y + 18, x + 80, y + 44), radius=8, fill=(255, 112, 170, 255), outline=(255, 255, 255, 255), width=4)
    draw.rectangle((x + 35, y + 20, x + 45, y + 90), fill=(255, 235, 94, 255))
    draw.rectangle((x + 6, y + 32, x + 74, y + 41), fill=(255, 235, 94, 255))
    draw.ellipse((x + 16, y + 4, x + 42, y + 28), fill=(255, 235, 94, 255), outline=(255, 255, 255, 255), width=3)
    draw.ellipse((x + 38, y + 4, x + 64, y + 28), fill=(255, 235, 94, 255), outline=(255, 255, 255, 255), width=3)
    draw.ellipse((x + 20, y + 52, x + 28, y + 60), fill=(255, 190, 220, 255))
    draw.ellipse((x + 56, y + 60, x + 64, y + 68), fill=(255, 190, 220, 255))


def draw_uniform_gift_card_slots(img, draw):
    # These slots intentionally match game.gd _gift_choice_card_rect().
    # AI-generated card frames look nicer, but are not pixel-identical; redraw
    # uniform card wells so the cursor/text can align cleanly.
    card_rects = [(116, 160, 322, 440), (346, 160, 552, 440), (576, 160, 782, 440)]
    # First cover the AI card wells so leftover generated borders do not double up.
    for x0, y0, x1, y1 in card_rects:
        cover_rect = (x0 - 13, y0 - 2, x1 + 13, y1 + 16)
        draw.rounded_rectangle(cover_rect, radius=18, fill=(255, 250, 253, 235))
        # Restore a tiny bit of diagonal sheen so the cards still feel integrated.
        sheen = Image.new("RGBA", (890, 500), (0, 0, 0, 0))
        sdraw = ImageDraw.Draw(sheen)
        sdraw.polygon(
            [(x0 - 8, y0 + 26), (x0 + 48, y0 - 12), (x1 + 8, y1 - 74), (x1 + 8, y1 - 34), (x0 - 8, y0 + 70)],
            fill=(255, 255, 255, 72),
        )
        img.alpha_composite(sheen)
    for x0, y0, x1, y1 in card_rects:
        shadow = Image.new("RGBA", (890, 500), (0, 0, 0, 0))
        sdraw = ImageDraw.Draw(shadow)
        sdraw.rounded_rectangle((x0 + 4, y0 + 8, x1 + 4, y1 + 8), radius=16, fill=(220, 70, 135, 55))
        blurred = shadow.filter(ImageFilter.GaussianBlur(7))
        img.alpha_composite(blurred)
        draw.rounded_rectangle((x0, y0, x1, y1), radius=14, fill=(255, 255, 255, 242), outline=(255, 160, 204, 255), width=3)
        draw.rounded_rectangle((x0 + 9, y0 + 9, x1 - 9, y1 - 9), radius=11, outline=(255, 218, 235, 170), width=2)
        draw.line((x0 + 22, y0 + 74, x1 - 22, y0 + 74), fill=(246, 224, 236, 180), width=2)
        draw.line((x0 + 22, y1 - 48, x1 - 22, y1 - 48), fill=(246, 224, 236, 180), width=2)


def draw_small_metric(draw, rect, accent, icon=None):
    x0, y0, x1, y1 = rect
    draw.rounded_rectangle(rect, radius=5, fill=(253, 254, 255, 248), outline=(184, 218, 255, 255), width=3)
    if icon != "hp":
        draw.rectangle((x0, y1 - 5, x1, y1), fill=accent)
    if icon == "heart" or icon == "hp":
        draw.ellipse((x0 + 14, y0 + 14, x0 + 26, y0 + 26), fill=(255, 70, 118, 255))
        draw.ellipse((x0 + 22, y0 + 14, x0 + 34, y0 + 26), fill=(255, 70, 118, 255))
        draw.polygon([(x0 + 14, y0 + 22), (x0 + 34, y0 + 22), (x0 + 24, y0 + 36)], fill=(255, 70, 118, 255))
    elif icon == "people":
        draw.ellipse((x0 + 18, y0 + 14, x0 + 30, y0 + 26), fill=(20, 24, 30, 255))
        draw.ellipse((x0 + 32, y0 + 16, x0 + 42, y0 + 26), fill=(20, 24, 30, 255))
        draw.rectangle((x0 + 16, y0 + 28, x0 + 44, y0 + 37), fill=(20, 24, 30, 255))
    elif icon == "gift":
        draw.rounded_rectangle((x0 + 18, y0 + 20, x0 + 42, y0 + 38), radius=3, fill=(255, 72, 135, 255))
        draw.rectangle((x0 + 28, y0 + 15, x0 + 33, y0 + 38), fill=(255, 255, 255, 220))
        draw.rectangle((x0 + 18, y0 + 24, x0 + 42, y0 + 29), fill=(255, 255, 255, 220))
    elif icon == "ng":
        draw.ellipse((x0 + 20, y0 + 15, x0 + 42, y0 + 37), outline=(255, 72, 135, 255), width=4)
        draw.line((x0 + 24, y0 + 33, x0 + 38, y0 + 19), fill=(255, 72, 135, 255), width=4)


def draw_equipment_panel(draw, rect, accent, label_color):
    x0, y0, x1, y1 = rect
    draw.rounded_rectangle(rect, radius=5, fill=(253, 254, 255, 248), outline=(184, 218, 255, 255), width=3)
    draw.rectangle((x0, y1 - 5, x1, y1), fill=accent)
    # Label tab, text remains Godot-side, this is just the colored tab shape.
    draw.rounded_rectangle((x0, y0, x0 + 56, y0 + 26), radius=5, fill=label_color)
    slot_x = x0 + 66
    for i in range(5):
        sx = slot_x + i * 40
        draw.rounded_rectangle((sx, y0 + 12, sx + 30, y0 + 42), radius=4, fill=(255, 255, 255, 255), outline=(184, 218, 255, 255), width=2)


def make_bottom_hud():
    # Matches Game.HUD: Rect2(20, 790, 1560, 90). Image includes 10px shadow padding.
    w, h = 1560, 90
    img = rounded_panel(
        (w, h),
        radius=4,
        fill=(247, 250, 255, 242),
        border=(184, 218, 255, 255),
        border_width=4,
    )
    draw = ImageDraw.Draw(img)
    pad = 10
    x0, y0 = pad, pad

    # Metric panels use coordinates relative to HUD origin.
    draw_small_metric(draw, (x0 + 14, y0 + 14, x0 + 180, y0 + 60), (74, 222, 128, 255), "hp")
    draw_small_metric(draw, (x0 + 192, y0 + 14, x0 + 468, y0 + 60), (141, 247, 255, 255), "people")
    draw_small_metric(draw, (x0 + 480, y0 + 14, x0 + 648, y0 + 60), (255, 90, 120, 255), "gift")

    # Small resource cards; NG/heart can appear conditionally via text but frame exists.
    draw_small_metric(draw, (x0 + 660, y0 + 14, x0 + 754, y0 + 60), (141, 247, 255, 255), "ng")
    draw_small_metric(draw, (x0 + 766, y0 + 14, x0 + 890, y0 + 60), (255, 145, 200, 255), "heart")

    draw_equipment_panel(draw, (x0 + 900, y0 + 14, x0 + 1166, y0 + 60), (255, 244, 92, 255), (50, 150, 245, 255))
    draw_equipment_panel(draw, (x0 + 1178, y0 + 14, x0 + 1510, y0 + 60), (141, 247, 255, 255), (0, 170, 185, 255))

    # Gauge rails aligned with existing Godot bars.
    draw.rounded_rectangle((x0 + 34, y0 + 72, x0 + 394, y0 + 80), radius=4, fill=(216, 236, 255, 255))
    draw.rounded_rectangle((x0 + 430, y0 + 72, x0 + 710, y0 + 80), radius=4, fill=(255, 225, 235, 255))
    draw_star(draw, x0 + 1520, y0 + 50, (255, 145, 200, 255))

    img.save(f"{OUT_DIR}/bottom_hud_frame.png")


def make_top_hud():
    # Top metrics and current instruction comment strip. Coordinates align with current DrawDataSystem.
    w, h = 820, 122
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    base_x, base_y = 0, 0

    panels = [
        (14, 12, 184, 58, (255, 244, 92, 255), "clock"),
        (194, 12, 379, 58, (141, 247, 255, 255), "frame"),
        (390, 12, 600, 58, (255, 138, 49, 255), "bolt"),
        (14, 64, 778, 106, (255, 145, 200, 255), "comment"),
    ]
    for x0, y0, x1, y1, accent, icon in panels:
        draw.rounded_rectangle(
            (base_x + x0, base_y + y0, base_x + x1, base_y + y1),
            radius=5,
            fill=(253, 254, 255, 238),
            outline=(184, 218, 255, 255),
            width=3,
        )
        draw.rectangle((base_x + x0, base_y + y1 - 5, base_x + x1, base_y + y1), fill=accent)
        ix, iy = base_x + x0 + 16, base_y + y0 + 15
        if icon == "clock":
            draw.ellipse((ix, iy, ix + 18, iy + 18), outline=(35, 45, 60, 255), width=2)
            draw.line((ix + 9, iy + 9, ix + 9, iy + 3), fill=(35, 45, 60, 255), width=2)
            draw.line((ix + 9, iy + 9, ix + 15, iy + 9), fill=(35, 45, 60, 255), width=2)
        elif icon == "frame":
            draw.rounded_rectangle((ix, iy + 1, ix + 22, iy + 17), radius=4, fill=(141, 247, 255, 255))
            draw.rectangle((ix + 6, iy + 5, ix + 16, iy + 14), fill=(255, 255, 255, 230))
        elif icon == "bolt":
            draw.polygon([(ix + 11, iy), (ix + 3, iy + 12), (ix + 10, iy + 12), (ix + 6, iy + 23), (ix + 20, iy + 8), (ix + 12, iy + 8)], fill=(65, 146, 255, 255))
        elif icon == "comment":
            draw.rounded_rectangle((ix, iy + 2, ix + 30, iy + 20), radius=6, fill=(255, 72, 135, 255))
            draw.polygon([(ix + 8, iy + 20), (ix + 14, iy + 20), (ix + 8, iy + 27)], fill=(255, 72, 135, 255))
            for j in range(3):
                draw.ellipse((ix + 7 + j * 8, iy + 10, ix + 11 + j * 8, iy + 14), fill=(255, 255, 255, 235))

    draw_star(draw, 786, 18, (65, 176, 230, 255))
    draw_star(draw, 802, 92, (255, 145, 200, 255))
    img.save(f"{OUT_DIR}/top_hud_frame.png")


def make_gift_choice_panel():
    w, h = 890, 500
    source = Path(GIFT_PANEL_AI_SOURCE)
    if source.exists():
        img = Image.open(source).convert("RGBA").resize((w, h), Image.Resampling.LANCZOS)
        draw = ImageDraw.Draw(img)
        title_font = load_font(54, True)
        subtitle_font = load_font(23, True)
        help_font = load_font(17, True)
        paste_ai_gift_title(img, draw, w / 2 + 18, -8, 545, title_font)
        draw.rounded_rectangle((312, 124, 578, 158), radius=15, fill=(255, 255, 255, 212), outline=(255, 170, 210, 220), width=2)
        draw_centered_text(
            draw,
            "どれを受け取る？",
            w / 2,
            129,
            subtitle_font,
            fill=(20, 26, 38, 255),
            stroke_fill=(255, 255, 255, 240),
            stroke_width=3,
        )
        draw.rounded_rectangle((344, 458, 546, 488), radius=14, fill=(255, 255, 255, 225), outline=(255, 174, 205, 255), width=2)
        draw_centered_text(
            draw,
            "1 / 2 / 3 で選択",
            w / 2,
            460,
            help_font,
            fill=(34, 45, 68, 255),
            stroke_fill=(255, 255, 255, 255),
            stroke_width=2,
        )
        draw_uniform_gift_card_slots(img, draw)
        img.save(f"{OUT_DIR}/gift_choice_panel.png")
        return

    img = rounded_panel(
        (w, h),
        radius=6,
        fill=(255, 250, 253, 238),
        border=(255, 90, 154, 255),
        border_width=5,
        shadow=False,
    )
    draw = ImageDraw.Draw(img)
    x0, y0 = 0, 0
    x1, y1 = w - 1, h - 1
    draw.rounded_rectangle((12, 12, x1 - 12, y1 - 12), radius=5, outline=(255, 210, 232, 165), width=2)
    for x, y, color in [
        (40, 338, (255, 210, 232, 115)),
        (630, 72, (140, 235, 255, 130)),
        (770, 410, (255, 220, 90, 120)),
        (114, 174, (255, 90, 154, 95)),
        (188, 40, (255, 240, 130, 210)),
        (740, 66, (120, 220, 255, 185)),
    ]:
        draw_star(draw, x, y, color)
    draw.rounded_rectangle((24, 340, 226, 346), radius=3, fill=(255, 235, 246, 120))
    draw.rounded_rectangle((674, 340, 862, 346), radius=3, fill=(235, 250, 255, 120))

    # Baked header and help text. Dynamic card text is still drawn by Godot.
    draw_gift_icon(draw, 150, 18)
    title_font = load_font(58, True)
    subtitle_font = load_font(24, True)
    help_font = load_font(17, True)
    paste_ai_gift_title(img, draw, w / 2 + 18, -8, 545, title_font)
    draw_centered_text(
        draw,
        "どれを受け取る？",
        w / 2,
        94,
        subtitle_font,
        fill=(20, 26, 38, 255),
        stroke_fill=(255, 255, 255, 230),
        stroke_width=3,
    )
    draw.rounded_rectangle((344, 458, 546, 488), radius=14, fill=(255, 255, 255, 218), outline=(255, 174, 205, 255), width=2)
    draw_centered_text(
        draw,
        "1 / 2 / 3 で選択",
        w / 2,
        460,
        help_font,
        fill=(34, 45, 68, 255),
        stroke_fill=(255, 255, 255, 255),
        stroke_width=2,
    )
    img.save(f"{OUT_DIR}/gift_choice_panel.png")


def make_comment_choice_panel():
    w, h = 930, 560
    source = Path(COMMENT_PANEL_AI_SOURCE)
    if source.exists():
        src = Image.open(source).convert("RGBA")
        src_ratio = src.width / src.height
        dst_ratio = w / h
        if src_ratio > dst_ratio:
            crop_w = int(src.height * dst_ratio)
            x0 = (src.width - crop_w) // 2
            src = src.crop((x0, 0, x0 + crop_w, src.height))
        elif src_ratio < dst_ratio:
            crop_h = int(src.width / dst_ratio)
            y0 = (src.height - crop_h) // 2
            src = src.crop((0, y0, src.width, y0 + crop_h))
        img = src.resize((w, h), Image.Resampling.LANCZOS)
    else:
        img = Image.new("RGBA", (w, h), (18, 0, 0, 238))
    draw = ImageDraw.Draw(img)
    title_font = load_font(58, True)
    subtitle_font = load_font(26, True)
    help_font = load_font(21, True)

    paste_ai_comment_title(img, draw, w / 2 + 18, 8, 700, 118, title_font)
    draw_centered_text(
        draw,
        "ひとつ選んでね",
        w / 2,
        96,
        subtitle_font,
        fill=(255, 255, 255, 255),
        stroke_fill=(0, 0, 0, 255),
        stroke_width=4,
    )

    # Deterministic bottom help plate. The card art comes from the image,
    # while the dynamic card contents are drawn in Godot.
    draw.rounded_rectangle((260, 508, 670, 548), radius=14, fill=(5, 5, 5, 225), outline=(255, 210, 80, 230), width=2)
    img.save(f"{OUT_DIR}/comment_choice_panel.png")


def make_gift_card(path, border, selected=False):
    w, h = 220, 260
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    fill = (255, 255, 255, 252)
    width = 5 if selected else 3
    draw.rounded_rectangle((0, 0, w - 1, h - 1), radius=8, fill=fill, outline=border, width=width)
    draw.rounded_rectangle((8, 8, w - 9, h - 9), radius=7, outline=(230, 238, 248, 170), width=1)
    draw.rectangle((14, 68, w - 15, 70), fill=(238, 244, 250, 180))
    draw.rectangle((14, h - 44, w - 15, h - 42), fill=(238, 244, 250, 180))
    img.save(f"{OUT_DIR}/{path}")


def make_gift_cards():
    colors = {
        "common": (92, 244, 136, 255),
        "rare": (96, 209, 255, 255),
        "god": (255, 210, 68, 255),
        "flame": (255, 92, 92, 255),
    }
    for name, color in colors.items():
        make_gift_card(f"gift_card_{name}.png", color, False)
        make_gift_card(f"gift_card_{name}_selected.png", color, True)


if __name__ == "__main__":
    make_comment_panel()
    make_bottom_hud()
    make_top_hud()
    make_gift_choice_panel()
    make_comment_choice_panel()
    make_gift_cards()
