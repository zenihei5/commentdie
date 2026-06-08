from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageFilter


ROOT = Path(r"C:\Users\zenih\Documents\Codex\2026-05-29\commentdie")
DESK_SRC = Path(r"C:\Users\zenih\Desktop\desk2.png")
KOMONO_SRC = Path(r"C:\Users\zenih\Desktop\komono.png")
KOMONO2_SRC = Path(r"C:\Users\zenih\Desktop\komono2.png")
MAP_DIR = ROOT / "assets" / "generated" / "maps" / "zatsudan_studio_layered_v1"
FLOOR = MAP_DIR / "zatsudan_studio_floor_only_chatgpt_2200x1500.png"
OUT_PROPS = MAP_DIR / "zatsudan_studio_desk_props_2200x1500.png"
OUT_ASSEMBLED = MAP_DIR / "zatsudan_studio_floor_with_desk_props_assembled_2200x1500.png"
OUT_COLLISION = MAP_DIR / "zatsudan_studio_floor_with_desk_props_collision_preview_2200x1500.png"
OUT_MANIFEST = MAP_DIR / "zatsudan_studio_floor_with_desk_props_v1_manifest.json"
OUT_ACTIVE_MANIFEST = MAP_DIR / "manifest.json"

CANVAS_SIZE = (2200, 1500)

# Source rectangles are hand-picked from generated prop sheets. Destination
# rectangles are in map pixels and kept smaller than source previews so the
# props read as set dressing rather than giant obstacles.
PROPS = [
    {
        "id": 'bench_left_top',
        "source": 'desk',
        "src_rect": (50, 115, 690, 285),
        "dst_rect": (619, 390, 360, 95),
        "collision_rect": (619, 413, 351, 55),
    },
    {
        "id": 'bench_right_mid',
        "source": 'desk',
        "src_rect": (742, 118, 1378, 285),
        "dst_rect": (1376, 690, 330, 88),
        "collision_rect": (1388, 717, 312, 44),
    },
    {
        "id": 'bench_bottom_left',
        "source": 'desk',
        "src_rect": (392, 360, 1060, 520),
        "dst_rect": (735, 1050, 365, 92),
        "collision_rect": (742, 1075, 349, 50),
    },
    {
        "id": "streaming_desk_bottom",
        "source": "desk",
        "src_rect": (200, 575, 1260, 990),
        "dst_rect": (825, 1328, 565, 165),
        "collision_rect": (860, 1402, 500, 72),
        "decorative": True,
    },
    {
        "id": 'camera_left_edge',
        "source": 'komono',
        "src_rect": (80, 135, 300, 370),
        "dst_rect": (104, 212, 130, 140),
        "collision_rect": (122, 296, 92, 54),
    },
    {
        "id": 'camera_right_edge',
        "source": 'komono',
        "src_rect": (1180, 135, 1395, 370),
        "dst_rect": (88, 615, 130, 140),
        "collision_rect": (103, 690, 98, 56),
    },
    {
        "id": 'hanging_plant_left',
        "source": 'komono',
        "src_rect": (350, 40, 560, 365),
        "dst_rect": (365, 65, 120, 185),
        "collision_rect": (384, 194, 99, 50),
    },
    {
        "id": 'hanging_plant_right',
        "source": 'komono',
        "src_rect": (670, 40, 880, 365),
        "dst_rect": (1780, 65, 120, 185),
        "collision_rect": (1784, 192, 103, 57),
    },
    {
        "id": 'speaker_top',
        "source": 'komono',
        "src_rect": (960, 145, 1125, 330),
        "dst_rect": (942, 78, 95, 115),
        "collision_rect": (953, 109, 75, 78),
    },
    {
        "id": 'neon_star_panel',
        "source": 'komono',
        "src_rect": (285, 435, 640, 585),
        "dst_rect": (558, 32, 300, 123),
        "collision_rect": (0, 0, 0, 0),
        "decorative": True,
        "no_collision": True,
    },
    {
        "id": 'neon_heart_panel',
        "source": 'komono',
        "src_rect": (670, 430, 1165, 590),
        "dst_rect": (1077, 57, 395, 126),
        "collision_rect": (0, 0, 0, 0),
        "decorative": True,
        "no_collision": True,
    },
    {
        "id": 'bunny_sign_left',
        "source": 'komono',
        "src_rect": (198, 798, 355, 984),
        "dst_rect": (108, 1200, 92, 106),
        "collision_rect": (0, 0, 0, 0),
        "decorative": True,
        "no_collision": True,
    },
    {
        "id": 'bunny_sign_right',
        "source": 'komono',
        "src_rect": (457, 800, 620, 985),
        "dst_rect": (2000, 1200, 92, 106),
        "collision_rect": (0, 0, 0, 0),
        "decorative": True,
        "no_collision": True,
    },
    {
        "id": 'ring_light_left',
        "source": 'komono2',
        "src_rect": (55, 95, 325, 360),
        "dst_rect": (70, 965, 120, 118),
        "collision_rect": (72, 1022, 114, 56),
    },
    {
        "id": 'studio_monitor_right',
        "source": 'komono2',
        "src_rect": (765, 158, 1120, 350),
        "dst_rect": (1431, 609, 220, 118),
        "collision_rect": (0, 0, 0, 0),
        "decorative": True,
        "no_collision": True,
    },
    {
        "id": 'boom_mic_left_bottom',
        "source": 'komono2',
        "src_rect": (52, 445, 385, 715),
        "dst_rect": (210, 1172, 155, 126),
        "collision_rect": (218, 1230, 76, 46),
    },
    {
        "id": 'cable_coil_right_bottom',
        "source": 'komono2',
        "src_rect": (462, 470, 765, 715),
        "dst_rect": (2009, 844, 136, 110),
        "collision_rect": (0, 0, 0, 0),
        "decorative": True,
        "no_collision": True,
    },
    {
        "id": 'gift_box_right',
        "source": 'komono2',
        "src_rect": (845, 480, 1045, 708),
        "dst_rect": (1865, 1030, 92, 104),
        "collision_rect": (1871, 1062, 82, 70),
    },
    {
        "id": 'plush_left',
        "source": 'komono2',
        "src_rect": (1162, 460, 1385, 710),
        "dst_rect": (2000, 1359, 98, 110),
        "collision_rect": (0, 0, 0, 0),
        "decorative": True,
        "no_collision": True,
    },
    {
        "id": 'potted_plant_left_bottom',
        "source": 'komono2',
        "src_rect": (160, 730, 450, 1030),
        "dst_rect": (92, 1290, 122, 126),
        "collision_rect": (110, 1350, 84, 42),
    },
    {
        "id": 'led_bar_bottom',
        "source": 'komono2',
        "src_rect": (565, 842, 1285, 948),
        "dst_rect": (1525, 1427, 330, 48),
        "collision_rect": (1532, 1434, 317, 41),
        "decorative": True,
    },
    {
        "id": 'speaker_top_copy',
        "source": 'komono',
        "src_rect": (960, 145, 1125, 330),
        "dst_rect": (1521, 88, 95, 115),
        "collision_rect": (1533, 119, 75, 78),
    },
    {
        "id": 'led_bar_bottom_copy',
        "source": 'komono2',
        "src_rect": (565, 842, 1285, 948),
        "dst_rect": (427, 1411, 330, 48),
        "collision_rect": (437, 1416, 317, 41),
        "decorative": True,
    },
]


def _is_green_screen_pixel(r: int, g: int, b: int) -> bool:
    return g > 105 and g > r * 1.45 and g > b * 1.28


def remove_green_screen_background(crop: Image.Image, erase_all_green: bool = False) -> Image.Image:
    rgba = crop.convert("RGBA")
    pix = rgba.load()
    w, h = rgba.size

    if erase_all_green:
        for y in range(h):
            for x in range(w):
                r, g, b, a = pix[x, y]
                if _is_green_screen_pixel(r, g, b):
                    pix[x, y] = (r, g, b, 0)
        alpha = rgba.getchannel("A").filter(ImageFilter.GaussianBlur(0.35))
        rgba.putalpha(alpha)
        return rgba

    visited = set()
    stack: list[tuple[int, int]] = []
    for x in range(w):
        stack.append((x, 0))
        stack.append((x, h - 1))
    for y in range(h):
        stack.append((0, y))
        stack.append((w - 1, y))

    while stack:
        x, y = stack.pop()
        if x < 0 or y < 0 or x >= w or y >= h:
            continue
        if (x, y) in visited:
            continue
        visited.add((x, y))
        r, g, b, a = pix[x, y]
        if not _is_green_screen_pixel(r, g, b):
            continue
        pix[x, y] = (r, g, b, 0)
        stack.append((x + 1, y))
        stack.append((x - 1, y))
        stack.append((x, y + 1))
        stack.append((x, y - 1))

    alpha = rgba.getchannel("A").filter(ImageFilter.GaussianBlur(0.45))
    rgba.putalpha(alpha)
    return rgba


def paste_prop(canvas: Image.Image, sources: dict[str, Image.Image], prop: dict) -> None:
    source = sources[prop.get("source", "desk")]
    crop = source.crop(prop["src_rect"])
    crop = remove_green_screen_background(crop, prop.get("source", "desk").startswith("komono"))
    x, y, w, h = prop["dst_rect"]
    resized = crop.resize((w, h), Image.Resampling.LANCZOS)
    if prop["id"].startswith("bench_"):
        px = resized.load()
        for py in range(int(h * 0.58), h):
            for px_x in range(w):
                r, g, b, a = px[px_x, py]
                if a > 0 and _is_green_screen_pixel(r, g, b):
                    px[px_x, py] = (r, g, b, 0)
    canvas.alpha_composite(resized, (x, y))


def draw_collision_preview(base: Image.Image) -> Image.Image:
    preview = base.convert("RGBA")
    overlay = Image.new("RGBA", preview.size, (0, 0, 0, 0))
    from PIL import ImageDraw

    draw = ImageDraw.Draw(overlay)
    for prop in PROPS:
        if prop.get("no_collision", False):
            continue
        x, y, w, h = prop["collision_rect"]
        fill = (255, 60, 80, 150) if not prop.get("decorative") else (255, 160, 60, 115)
        draw.rectangle((x, y, x + w, y + h), fill=fill)
    return Image.alpha_composite(preview, overlay)


def main() -> None:
    sources = {
        "desk": Image.open(DESK_SRC).convert("RGB"),
        "komono": Image.open(KOMONO_SRC).convert("RGB"),
        "komono2": Image.open(KOMONO2_SRC).convert("RGB"),
    }
    floor = Image.open(FLOOR).convert("RGBA")
    if floor.size != CANVAS_SIZE:
        raise RuntimeError(f"Unexpected floor size: {floor.size}")

    props_layer = Image.new("RGBA", CANVAS_SIZE, (0, 0, 0, 0))
    for prop in PROPS:
        paste_prop(props_layer, sources, prop)

    assembled = Image.alpha_composite(floor, props_layer)
    collision_preview = draw_collision_preview(assembled)

    props_layer.save(OUT_PROPS)
    assembled.save(OUT_ASSEMBLED)
    collision_preview.save(OUT_COLLISION)

    manifest = {
        "id": "zatsudan_studio_layered_v1",
        "displayName": "Zatsudan Studio Layered v1",
        "source": {
            "desk": str(DESK_SRC),
            "komono": str(KOMONO_SRC),
            "komono2": str(KOMONO2_SRC),
        },
        "size": [CANVAS_SIZE[0], CANVAS_SIZE[1]],
        "layers": [
            {"id": "floor", "type": "floor", "path": FLOOR.name},
            {"id": "props", "type": "separate_props", "path": OUT_PROPS.name},
        ],
        "collision_rects": [
            {
                "id": prop["id"],
                "rect": [
                    prop["collision_rect"][0],
                    prop["collision_rect"][1],
                    prop["collision_rect"][0] + prop["collision_rect"][2],
                    prop["collision_rect"][1] + prop["collision_rect"][3],
                ],
                "decorative": bool(prop.get("decorative", False)),
            }
            for prop in PROPS
            if not prop.get("no_collision", False)
        ],
        "prop_collision_rects": [],
        "assembledPreview": OUT_ASSEMBLED.name,
        "collisionPreview": OUT_COLLISION.name,
        "notes": [
            "desk2.png had a green-screen background; connected green background was removed in postprocess.",
            "komono.png props were chroma-keyed and placed near map edges.",
            "komono2.png props were added as smaller edge decorations.",
            "The bottom streaming desk is included as a decorative boundary prop.",
        ],
    }
    OUT_MANIFEST.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    OUT_ACTIVE_MANIFEST.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")

    print(f"wrote {OUT_PROPS}")
    print(f"wrote {OUT_ASSEMBLED}")
    print(f"wrote {OUT_COLLISION}")
    print(f"wrote {OUT_MANIFEST}")
    print(f"wrote {OUT_ACTIVE_MANIFEST}")


if __name__ == "__main__":
    main()
