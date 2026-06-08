from __future__ import annotations

import math
import random
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter


ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "assets" / "generated" / "maps" / "zatsudan_studio_layered_v1"
WIDTH = 2200
HEIGHT = 1500
TABLE_RECTS = [
    (540, 430, 920, 486),
    (1420, 760, 1740, 816),
    (670, 1110, 1100, 1166),
]
PROP_COLLISION_RECTS = [
    {"id": "main_monitor", "rect": (805, 35, 1395, 185)},
    {"id": "left_speaker", "rect": (640, 36, 755, 212)},
    {"id": "right_speaker", "rect": (1445, 36, 1560, 212)},
    {"id": "right_monitor", "rect": (1740, 94, 2110, 222)},
    {"id": "left_monitor", "rect": (150, 108, 450, 226)},
    {"id": "left_top_camera", "rect": (38, 238, 168, 414)},
    {"id": "left_bottom_camera", "rect": (14, 1018, 140, 1200)},
    {"id": "right_bottom_camera", "rect": (1964, 934, 2106, 1118)},
    {"id": "blue_plush", "rect": (28, 34, 108, 120)},
    {"id": "pink_plush", "rect": (2050, 1198, 2142, 1294)},
    {"id": "mint_plush", "rect": (1768, 1227, 1852, 1317)},
    {"id": "streaming_desk", "rect": (780, 1290, 1350, 1485)},
    {"id": "left_shelf", "rect": (18, 108, 150, 252)},
    {"id": "right_light_case", "rect": (2050, 250, 2165, 420)},
]
PROP_PLACEMENTS = [
    {"id": "main_monitor", "type": "monitor", "rect": [805, 30, 1395, 168], "icon": "heart"},
    {"id": "left_speaker", "type": "speaker", "rect": [640, 36, 755, 180]},
    {"id": "right_speaker", "type": "speaker", "rect": [1445, 36, 1560, 180]},
    {"id": "right_monitor", "type": "monitor", "rect": [1740, 94, 2110, 210], "icon": "wave"},
    {"id": "left_monitor", "type": "monitor", "rect": [150, 108, 450, 218], "icon": "star"},
    {"id": "left_top_camera", "type": "camera", "pos": [78, 260]},
    {"id": "left_bottom_camera", "type": "camera", "pos": [55, 1060]},
    {"id": "right_bottom_camera", "type": "camera", "pos": [2010, 980]},
    {"id": "blue_plush", "type": "plush", "pos": [58, 65]},
    {"id": "pink_plush", "type": "plush", "pos": [2085, 1230]},
    {"id": "mint_plush", "type": "plush", "pos": [1800, 1260]},
    {"id": "streaming_desk", "type": "desk", "rect": [780, 1280, 1350, 1490]},
    {"id": "left_shelf", "type": "shelf", "rect": [18, 108, 150, 252]},
    {"id": "right_light_case", "type": "light_case", "rect": [2050, 250, 2165, 420]},
]


def rounded(draw: ImageDraw.ImageDraw, box, radius, fill, outline=None, width=1):
    draw.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)


def glow(base: Image.Image, box, radius, color, blur=18, width=5):
    layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    d.rounded_rectangle(box, radius=radius, outline=color, width=width)
    layer = layer.filter(ImageFilter.GaussianBlur(blur))
    base.alpha_composite(layer)


def soft_rect(base: Image.Image, box, radius, color, blur=16):
    layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    d.rounded_rectangle(box, radius=radius, fill=color)
    layer = layer.filter(ImageFilter.GaussianBlur(blur))
    base.alpha_composite(layer)


def draw_line_glow(base: Image.Image, points, color, width=5, blur=8):
    layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    d.line(points, fill=color, width=width, joint="curve")
    glow_layer = layer.filter(ImageFilter.GaussianBlur(blur))
    base.alpha_composite(glow_layer)
    base.alpha_composite(layer)


def draw_floor(draw: ImageDraw.ImageDraw):
    draw.rectangle((0, 0, WIDTH, HEIGHT), fill=(156, 147, 198, 255))
    tile = 150
    for y in range(0, HEIGHT, tile):
        for x in range(0, WIDTH, tile):
            shade = 0 if ((x // tile + y // tile) % 2 == 0) else 12
            distance = abs((x + tile * 0.5) - WIDTH * 0.5) / WIDTH
            light = int(18 * (1.0 - distance))
            fill = (146 + shade + light, 136 + shade + light, 188 + shade + light, 255)
            draw.rectangle((x, y, x + tile, y + tile), fill=fill)

    for x in range(0, WIDTH, tile):
        draw.line((x, 0, x, HEIGHT), fill=(115, 105, 150, 58), width=2)
    for y in range(0, HEIGHT, tile):
        draw.line((0, y, WIDTH, y), fill=(115, 105, 150, 58), width=2)

    rng = random.Random(12)
    for _ in range(130):
        x = rng.randint(55, WIDTH - 55)
        y = rng.randint(55, HEIGHT - 55)
        r = rng.choice([3, 4, 5, 7])
        col = rng.choice([
            (255, 222, 128, 80),
            (255, 145, 210, 70),
            (120, 240, 255, 55),
            (255, 255, 255, 45),
        ])
        draw.ellipse((x - r, y - r, x + r, y + r), fill=col)

    for _ in range(42):
        x = rng.randint(120, WIDTH - 120)
        y = rng.randint(120, HEIGHT - 120)
        s = rng.randint(9, 17)
        col = rng.choice([(255, 255, 255, 80), (255, 240, 150, 85), (130, 240, 255, 70)])
        draw.line((x - s, y, x + s, y), fill=col, width=2)
        draw.line((x, y - s, x, y + s), fill=col, width=2)

    for _ in range(18):
        x = rng.randint(180, WIDTH - 180)
        y = rng.randint(180, HEIGHT - 180)
        draw.arc((x - 22, y - 10, x + 22, y + 34), 200, 340, fill=(255, 255, 255, 34), width=2)


def draw_monitor(draw: ImageDraw.ImageDraw, base: Image.Image, box, icon="heart"):
    glow(base, box, 18, (255, 84, 190, 95), blur=12, width=5)
    rounded(draw, box, 18, (53, 51, 83, 255), (128, 110, 165, 255), 5)
    inner = (box[0] + 14, box[1] + 14, box[2] - 14, box[3] - 14)
    rounded(draw, inner, 12, (36, 38, 66, 255), (74, 220, 255, 130), 3)
    draw.rectangle((inner[0] + 16, inner[1] + 10, inner[2] - 16, inner[1] + 14), fill=(255, 255, 255, 32))
    cx = (inner[0] + inner[2]) // 2
    cy = (inner[1] + inner[3]) // 2
    if icon == "heart":
        draw.ellipse((cx - 44, cy - 30, cx - 5, cy + 12), fill=(255, 90, 165, 245))
        draw.ellipse((cx + 5, cy - 30, cx + 44, cy + 12), fill=(255, 90, 165, 245))
        draw.polygon([(cx - 48, cy - 5), (cx + 48, cy - 5), (cx, cy + 55)], fill=(255, 90, 165, 245))
    elif icon == "wave":
        for i in range(4):
            x = inner[0] + 35 + i * 54
            draw.arc((x, cy - 30, x + 70, cy + 30), 200, 340, fill=(95, 240, 255, 235), width=8)
    else:
        pts = []
        for i in range(10):
            a = -math.pi / 2 + i * math.pi / 5
            rad = 46 if i % 2 == 0 else 20
            pts.append((cx + math.cos(a) * rad, cy + math.sin(a) * rad))
        draw.polygon(pts, fill=(255, 230, 95, 245))


def draw_speaker(draw: ImageDraw.ImageDraw, box):
    rounded(draw, box, 12, (38, 36, 52, 255), (85, 82, 110, 255), 4)
    cx = (box[0] + box[2]) // 2
    for y in [box[1] + 46, box[3] - 46]:
        draw.ellipse((cx - 40, y - 40, cx + 40, y + 40), fill=(18, 18, 28, 255), outline=(90, 88, 120, 255), width=4)
        draw.ellipse((cx - 15, y - 15, cx + 15, y + 15), fill=(76, 72, 105, 255))


def draw_camera(draw: ImageDraw.ImageDraw, x, y):
    draw.line((x + 38, y + 58, x + 12, y + 155), fill=(28, 28, 36, 255), width=8)
    draw.line((x + 38, y + 58, x + 76, y + 155), fill=(28, 28, 36, 255), width=8)
    draw.line((x + 38, y + 58, x + 38, y + 165), fill=(28, 28, 36, 255), width=7)
    rounded(draw, (x, y, x + 88, y + 62), 12, (35, 34, 46, 255), (95, 92, 125, 255), 4)
    draw.ellipse((x + 18, y + 12, x + 56, y + 50), fill=(20, 22, 36, 255), outline=(120, 220, 255, 210), width=3)
    draw.rectangle((x + 80, y + 22, x + 126, y + 42), fill=(28, 28, 36, 255), outline=(90, 88, 120, 255), width=3)
    draw.line((x + 38, y + 165, x + 18, y + 205), fill=(24, 23, 34, 210), width=5)


def draw_table(draw: ImageDraw.ImageDraw, box):
    shadow = (box[0] + 14, box[1] + 28, box[2] + 14, box[3] + 42)
    rounded(draw, shadow, 12, (40, 30, 55, 95))
    rounded(draw, box, 9, (224, 200, 176, 255), (55, 48, 65, 255), 5)
    draw.rectangle((box[0] + 10, box[3] - 13, box[2] - 10, box[3] - 4), fill=(112, 91, 90, 255))
    draw.line((box[0] + 18, box[1] + 12, box[2] - 18, box[1] + 12), fill=(255, 238, 220, 160), width=3)
    for x in range(box[0] + 52, box[2] - 28, 92):
        draw.line((x, box[1] + 7, x + 28, box[3] - 10), fill=(195, 162, 144, 95), width=2)


def draw_plush(draw: ImageDraw.ImageDraw, x, y, color):
    draw.ellipse((x, y + 28, x + 82, y + 112), fill=color, outline=(75, 55, 95, 255), width=3)
    draw.ellipse((x + 7, y + 5, x + 30, y + 32), fill=color, outline=(75, 55, 95, 255), width=3)
    draw.ellipse((x + 52, y + 5, x + 75, y + 32), fill=color, outline=(75, 55, 95, 255), width=3)
    draw.ellipse((x + 24, y + 58, x + 34, y + 68), fill=(30, 30, 40, 255))
    draw.ellipse((x + 50, y + 58, x + 60, y + 68), fill=(30, 30, 40, 255))
    draw.arc((x + 30, y + 68, x + 55, y + 88), 15, 165, fill=(80, 60, 90, 255), width=3)


def draw_shelf(draw: ImageDraw.ImageDraw, box):
    rounded(draw, box, 12, (70, 54, 88, 245), (118, 104, 145, 255), 4)
    for i in range(3):
        y = box[1] + 30 + i * 35
        draw.rectangle((box[0] + 12, y, box[2] - 12, y + 5), fill=(154, 128, 118, 255))
        for j in range(4):
            x = box[0] + 20 + j * 24
            col = [(255, 146, 196, 255), (118, 230, 245, 255), (255, 221, 108, 255), (180, 160, 255, 255)][(i + j) % 4]
            draw.rounded_rectangle((x, y - 22, x + 13, y - 2), radius=3, fill=col)


def draw_plant(draw: ImageDraw.ImageDraw, x, y, scale=1.0):
    pot_w = int(36 * scale)
    pot_h = int(30 * scale)
    draw.rounded_rectangle((x - pot_w // 2, y, x + pot_w // 2, y + pot_h), radius=7, fill=(224, 205, 184, 255), outline=(88, 70, 82, 255), width=2)
    for angle in [-65, -35, -10, 20, 50]:
        dx = int(math.cos(math.radians(angle)) * 35 * scale)
        dy = int(math.sin(math.radians(angle)) * 28 * scale)
        draw.line((x, y + 4, x + dx, y + dy - 20), fill=(88, 190, 135, 255), width=max(2, int(4 * scale)))
        draw.ellipse((x + dx - 10, y + dy - 30, x + dx + 12, y + dy - 10), fill=(95, 220, 155, 245), outline=(48, 120, 92, 120))


def draw_streaming_desk(draw: ImageDraw.ImageDraw, base: Image.Image, box):
    shadow = (box[0] + 22, box[1] + 28, box[2] + 22, box[3] + 56)
    rounded(draw, shadow, 24, (30, 22, 46, 100))
    rounded(draw, box, 18, (82, 56, 58, 255), (42, 34, 50, 255), 5)
    draw.rectangle((box[0] + 18, box[1] + 24, box[2] - 18, box[1] + 70), fill=(116, 82, 76, 255))
    draw.rectangle((box[0] + 30, box[3] - 24, box[2] - 30, box[3] - 12), fill=(42, 36, 50, 255))
    for x in [box[0] + 120, box[0] + 245, box[0] + 360]:
        draw.line((x, box[1] + 15, x - 80, box[1] - 110), fill=(34, 30, 45, 210), width=6)
    rounded(draw, (box[0] + 66, box[1] + 44, box[0] + 190, box[1] + 116), 10, (42, 42, 58, 255), (130, 120, 160, 255), 3)
    rounded(draw, (box[0] + 245, box[1] + 48, box[0] + 370, box[1] + 115), 10, (40, 42, 58, 255), (120, 220, 255, 150), 3)
    for i in range(8):
        cx = box[0] + 95 + i * 26
        cy = box[1] + 150 + (i % 2) * 12
        draw.ellipse((cx, cy, cx + 13, cy + 13), fill=(255, 93, 168, 210))
    draw_plant(draw, box[2] - 70, box[1] + 118, 0.75)
    soft_rect(base, (box[0] + 50, box[1] - 40, box[2] - 60, box[1] + 80), 34, (255, 98, 185, 30), blur=28)


def draw_light_case(draw: ImageDraw.ImageDraw, box):
    rounded(draw, box, 16, (48, 43, 68, 250), (105, 96, 135, 255), 4)
    for i, col in enumerate([(255, 80, 170, 255), (120, 235, 255, 255), (255, 230, 95, 255)]):
        y = box[1] + 28 + i * 43
        draw.ellipse((box[0] + 22, y, box[0] + 58, y + 36), fill=col)
        draw.rectangle((box[0] + 70, y + 13, box[2] - 18, y + 22), fill=(30, 30, 45, 255))


def draw_edge_props(draw: ImageDraw.ImageDraw, base: Image.Image):
    draw.rectangle((0, 0, WIDTH, 130), fill=(45, 43, 78, 248))
    draw.rectangle((0, HEIGHT - 120, WIDTH, HEIGHT), fill=(46, 42, 70, 242))
    draw.rectangle((0, 0, 135, HEIGHT), fill=(48, 44, 77, 236))
    draw.rectangle((WIDTH - 135, 0, WIDTH, HEIGHT), fill=(48, 44, 77, 236))
    for y in [132, HEIGHT - 122]:
        draw.line((0, y, WIDTH, y), fill=(132, 120, 178, 145), width=5)
    for x in [135, WIDTH - 135]:
        draw.line((x, 0, x, HEIGHT), fill=(132, 120, 178, 112), width=4)
    soft_rect(base, (260, 80, WIDTH - 260, 410), 60, (255, 126, 205, 18), blur=80)
    soft_rect(base, (330, HEIGHT - 420, WIDTH - 360, HEIGHT - 40), 60, (90, 230, 255, 16), blur=70)

    draw_monitor(draw, base, (805, 30, 1395, 168), "heart")
    draw_speaker(draw, (640, 36, 755, 180))
    draw_speaker(draw, (1445, 36, 1560, 180))
    draw_monitor(draw, base, (1740, 94, 2110, 210), "wave")
    draw_monitor(draw, base, (150, 108, 450, 218), "star")

    for x in [470, 565, 1635, 1730, 1825]:
        draw.ellipse((x, 120, x + 20, 140), fill=(255, 220, 110, 255))
        draw.line((x + 10, 45, x + 10, 120), fill=(40, 38, 58, 210), width=3)

    draw_camera(draw, 55, 1060)
    draw_camera(draw, WIDTH - 190, 980)
    draw_camera(draw, 78, 260)
    draw_shelf(draw, (18, 108, 150, 252))
    draw_light_case(draw, (2050, 250, 2165, 420))
    draw_plush(draw, 58, 65, (170, 190, 255, 255))
    draw_plush(draw, WIDTH - 115, 1230, (255, 182, 220, 255))
    draw_plush(draw, 1800, 1260, (190, 255, 220, 255))
    draw_plant(draw, 520, 95, 0.8)
    draw_plant(draw, 1610, 92, 0.8)
    draw_plant(draw, 120, 1265, 0.9)
    draw_plant(draw, WIDTH - 210, 1280, 0.9)

    draw_line_glow(base, [(180, 1420), (390, 1345), (720, 1380), (930, 1300)], (255, 95, 180, 115), 6, 10)
    draw_line_glow(base, [(WIDTH - 120, 1160), (WIDTH - 410, 1210), (WIDTH - 660, 1165)], (100, 230, 255, 95), 6, 10)
    draw_streaming_desk(draw, base, (780, 1280, 1350, 1490))

    for box in TABLE_RECTS:
        draw_table(draw, box)


def main():
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    floor = Image.new("RGBA", (WIDTH, HEIGHT), (0, 0, 0, 0))
    floor_draw = ImageDraw.Draw(floor)
    draw_floor(floor_draw)

    props = Image.new("RGBA", (WIDTH, HEIGHT), (0, 0, 0, 0))
    props_draw = ImageDraw.Draw(props)
    draw_edge_props(props_draw, props)

    base = floor.copy()
    base.alpha_composite(props)

    vignette = Image.new("RGBA", (WIDTH, HEIGHT), (0, 0, 0, 0))
    vd = ImageDraw.Draw(vignette)
    for i in range(80):
        alpha = int(i * 1.2)
        vd.rectangle((i, i, WIDTH - i, HEIGHT - i), outline=(20, 18, 40, alpha), width=2)
    base.alpha_composite(vignette)

    floor_out = OUT_DIR / "zatsudan_studio_floor_2200x1500.png"
    props_out = OUT_DIR / "zatsudan_studio_props_2200x1500.png"
    out = OUT_DIR / "zatsudan_studio_assembled_2200x1500.png"
    collision_preview_out = OUT_DIR / "zatsudan_studio_collision_preview_2200x1500.png"
    floor.convert("RGBA").save(floor_out)
    props.convert("RGBA").save(props_out)
    base.convert("RGBA").save(out)
    collision_preview = base.copy()
    collision_draw = ImageDraw.Draw(collision_preview)
    for rect in TABLE_RECTS:
        collision_draw.rectangle(rect, outline=(255, 80, 80, 255), width=6)
        collision_draw.rectangle(rect, fill=(255, 80, 80, 44))
    for item in PROP_COLLISION_RECTS:
        rect = item["rect"]
        collision_draw.rectangle(rect, outline=(90, 220, 255, 255), width=5)
        collision_draw.rectangle(rect, fill=(90, 220, 255, 34))
    collision_preview.save(collision_preview_out)
    manifest = {
        "id": "zatsudan_studio_layered_v1",
        "size": [WIDTH, HEIGHT],
        "layers": [
            {"id": "floor", "path": floor_out.name, "type": "base"},
            {"id": "props", "path": props_out.name, "type": "decor_and_obstacles"},
            {"id": "assembled", "path": out.name, "type": "runtime_background"},
            {"id": "collision_preview", "path": collision_preview_out.name, "type": "debug_preview"},
        ],
        "collision_rects": [{"id": f"table_{i + 1}", "rect": list(rect)} for i, rect in enumerate(TABLE_RECTS)],
        "prop_collision_rects": [{"id": item["id"], "rect": list(item["rect"])} for item in PROP_COLLISION_RECTS],
        "prop_placements": PROP_PLACEMENTS,
        "notes": [
            "No readable text is baked into the image.",
            "The runtime game draws the floor layer first and the props layer above actors.",
            "This procedural version can be replaced by final generated art if the same size and layer contract are kept.",
            "Collision rectangles mirror the visible table and prop obstacles.",
        ],
    }
    (OUT_DIR / "manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    gd_collision_lines = []
    gd_prop_collision_lines = []
    gd_rect_lines = []
    for rect in TABLE_RECTS:
        x1, y1, x2, y2 = rect
        gd_collision_lines.append(
            f'\t{{"id": "table_{len(gd_collision_lines) + 1}", "rect": Rect2({x1}, {y1}, {x2 - x1}, {y2 - y1})}}'
        )
        gd_rect_lines.append(f"\t\tRect2({x1}, {y1}, {x2 - x1}, {y2 - y1})")
    for item in PROP_COLLISION_RECTS:
        x1, y1, x2, y2 = item["rect"]
        gd_prop_collision_lines.append(
            f'\t{{"id": "{item["id"]}", "rect": Rect2({x1}, {y1}, {x2 - x1}, {y2 - y1})}}'
        )
        gd_rect_lines.append(f"\t\tRect2({x1}, {y1}, {x2 - x1}, {y2 - y1})")
    (OUT_DIR / "map_background_collision_data.gd.snippet").write_text(
        "const ZATSUDAN_STUDIO_COLLISION_RECTS := [\n"
        + ",\n".join(gd_collision_lines)
        + "\n]\n"
        + "const ZATSUDAN_STUDIO_PROP_COLLISION_RECTS := [\n"
        + ",\n".join(gd_prop_collision_lines)
        + "\n]\n",
        encoding="utf-8",
    )
    (OUT_DIR / "static_wall_rects.gd.snippet").write_text(
        "static func zatsudan_static_wall_rects() -> Array:\n"
        "\treturn [\n"
        + ",\n".join(gd_rect_lines)
        + "\n\t]\n",
        encoding="utf-8",
    )
    (OUT_DIR / "zatsudan_studio_assembled_2200x1500.prompt.txt").write_text(
        "Layer-assembled no-text livestream studio arena background. Exact 2200x1500. "
        "Pastel purple tiled floor, open center, edge monitors/lights/cameras/speakers/plushies, "
        "abstract icons only, no readable text. Procedural assembly used because image generation "
        "repeatedly produced text-heavy poster images.",
        encoding="utf-8",
    )
    print(out)


if __name__ == "__main__":
    main()
