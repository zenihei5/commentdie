from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont, PngImagePlugin


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "artifacts" / "equipment_icon_inventory.png"

CANVAS_WIDTH = 2200
CANVAS_HEIGHT = 2020
CARD_WIDTH = 250
CARD_HEIGHT = 266
CARD_GAP = 14
ROW_GAP = 16
ICON_SIZE = 174

FONT_REGULAR = Path(r"C:\Windows\Fonts\YuGothM.ttc")
FONT_BOLD = Path(r"C:\Windows\Fonts\YuGothB.ttc")

WEAPON_PAIRS = [
    ("ban_hammer", "ban_judgement"),
    ("superchat_shot", "starlight_superchat"),
    ("comment_boomerang", "maro_comment_ring"),
    ("moderator_shield", "moderator_fortress"),
    ("fansa_baton", "fansa_climax"),
    ("tsuri_thumbnail_rod", "buzz_thumbnail_rod"),
    ("mic_barrier", "full_voice_dome"),
    ("spotlight", "center_stage"),
    ("kusa_wave", "great_grassland"),
    ("comment_pin", "comment_lockdown"),
    ("emote_mine", "emote_festival"),
    ("ng_word_laser", "all_block_laser"),
    ("listener_summon", "listener_assembly"),
]


def load_json(path: Path) -> list[dict]:
    with path.open("r", encoding="utf-8") as handle:
        value = json.load(handle)
    if not isinstance(value, list):
        raise ValueError(f"Expected an array: {path}")
    return value


def resolve_icon(path: str) -> Path:
    if not path.startswith("res://"):
        raise ValueError(f"Unsupported icon path: {path}")
    return ROOT / path.removeprefix("res://")


def font(path: Path, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(path), size=size)


def fit_font(draw: ImageDraw.ImageDraw, text: str, path: Path, preferred: int, minimum: int, max_width: int) -> ImageFont.FreeTypeFont:
    for size in range(preferred, minimum - 1, -1):
        candidate = font(path, size)
        if draw.textbbox((0, 0), text, font=candidate)[2] <= max_width:
            return candidate
    return font(path, minimum)


def centered_text(draw: ImageDraw.ImageDraw, text: str, center_x: int, y: int, text_font: ImageFont.FreeTypeFont, fill: str) -> None:
    bounds = draw.textbbox((0, 0), text, font=text_font)
    width = bounds[2] - bounds[0]
    draw.text((center_x - width / 2, y), text, font=text_font, fill=fill)


def draw_checker(draw: ImageDraw.ImageDraw, left: int, top: int, size: int) -> None:
    square = 14
    colors = ("#d8dee8", "#bfc8d6")
    for row, y in enumerate(range(top, top + size, square)):
        for column, x in enumerate(range(left, left + size, square)):
            draw.rectangle(
                (x, y, min(x + square - 1, left + size - 1), min(y + square - 1, top + size - 1)),
                fill=colors[(row + column) % 2],
            )


def draw_card(canvas: Image.Image, draw: ImageDraw.ImageDraw, item: dict, x: int, y: int, index_label: str, category: str) -> None:
    evolved = bool(item.get("isEvolved", False))
    if category == "accessory":
        accent = "#f4c95d"
        card_fill = "#242317"
        badge_fill = "#5b4913"
        badge_text = "アクセサリ"
    elif evolved:
        accent = "#c59bff"
        card_fill = "#211b31"
        badge_fill = "#4f337a"
        badge_text = "進化武器"
    else:
        accent = "#73c8ff"
        card_fill = "#172637"
        badge_fill = "#194f72"
        badge_text = "通常武器"

    draw.rounded_rectangle(
        (x, y, x + CARD_WIDTH, y + CARD_HEIGHT),
        radius=18,
        fill=card_fill,
        outline=accent,
        width=2,
    )

    badge_font = font(FONT_BOLD, 13)
    badge_width = draw.textbbox((0, 0), badge_text, font=badge_font)[2] + 22
    draw.rounded_rectangle((x + 12, y + 10, x + 12 + badge_width, y + 34), radius=10, fill=badge_fill)
    draw.text((x + 23, y + 13), badge_text, font=badge_font, fill="#ffffff")
    index_font = font(FONT_BOLD, 13)
    index_bounds = draw.textbbox((0, 0), index_label, font=index_font)
    draw.text((x + CARD_WIDTH - 13 - (index_bounds[2] - index_bounds[0]), y + 13), index_label, font=index_font, fill=accent)

    icon_left = x + (CARD_WIDTH - ICON_SIZE) // 2
    icon_top = y + 42
    draw_checker(draw, icon_left, icon_top, ICON_SIZE)
    draw.rounded_rectangle(
        (icon_left - 1, icon_top - 1, icon_left + ICON_SIZE, icon_top + ICON_SIZE),
        radius=8,
        outline="#8f9bad",
        width=2,
    )

    icon_path = resolve_icon(str(item.get("iconPath", "")))
    if not icon_path.is_file():
        raise FileNotFoundError(f"Missing icon for {item.get('id')}: {icon_path}")
    with Image.open(icon_path) as source:
        icon = source.convert("RGBA")
        icon.thumbnail((ICON_SIZE - 10, ICON_SIZE - 10), Image.Resampling.LANCZOS)
        paste_x = icon_left + (ICON_SIZE - icon.width) // 2
        paste_y = icon_top + (ICON_SIZE - icon.height) // 2
        canvas.alpha_composite(icon, (paste_x, paste_y))

    display_name = str(item.get("displayName", item.get("id", "")))
    name_font = fit_font(draw, display_name, FONT_BOLD, 19, 12, CARD_WIDTH - 20)
    centered_text(draw, display_name, x + CARD_WIDTH // 2, y + 220, name_font, "#f7f9fc")

    item_id = str(item.get("id", ""))
    id_font = fit_font(draw, item_id, FONT_REGULAR, 12, 10, CARD_WIDTH - 20)
    centered_text(draw, item_id, x + CARD_WIDTH // 2, y + 244, id_font, "#aeb8c8")


def section_header(draw: ImageDraw.ImageDraw, y: int, title: str, subtitle: str, accent: str) -> None:
    title_font = font(FONT_BOLD, 28)
    subtitle_font = font(FONT_REGULAR, 16)
    draw.rounded_rectangle((50, y + 6, 62, y + 40), radius=6, fill=accent)
    draw.text((78, y), title, font=title_font, fill="#f7f9fc")
    title_width = draw.textbbox((0, 0), title, font=title_font)[2]
    draw.text((92 + title_width, y + 9), subtitle, font=subtitle_font, fill="#aeb8c8")
    draw.line((50, y + 50, CANVAS_WIDTH - 50, y + 50), fill="#30394a", width=2)


def main() -> None:
    weapons = [
        item
        for item in load_json(ROOT / "data" / "weapons.json")
        if item.get("equipmentType") == "weapon" and item.get("id") != "phase1_null_weapon"
    ]
    accessories = [
        item
        for item in load_json(ROOT / "data" / "gifts.json")
        if item.get("equipmentType") == "accessory"
    ]
    if len(weapons) != 26 or len(accessories) != 10:
        raise ValueError(f"Unexpected item counts: weapons={len(weapons)}, accessories={len(accessories)}")

    weapons_by_id = {str(item["id"]): item for item in weapons}
    ordered_weapons: list[dict] = []
    for normal_id, evolved_id in WEAPON_PAIRS:
        ordered_weapons.extend((weapons_by_id[normal_id], weapons_by_id[evolved_id]))
    if len(ordered_weapons) != len(weapons) or {item["id"] for item in ordered_weapons} != set(weapons_by_id):
        raise ValueError("Weapon pair list does not match the current registry")

    canvas = Image.new("RGBA", (CANVAS_WIDTH, CANVAS_HEIGHT), "#0c1220")
    draw = ImageDraw.Draw(canvas)
    for y in range(CANVAS_HEIGHT):
        ratio = y / max(1, CANVAS_HEIGHT - 1)
        color = (
            int(12 + 4 * ratio),
            int(18 + 5 * ratio),
            int(32 + 7 * ratio),
            255,
        )
        draw.line((0, y, CANVAS_WIDTH, y), fill=color)

    title_font = font(FONT_BOLD, 44)
    subtitle_font = font(FONT_REGULAR, 18)
    draw.text((50, 32), "現行 武器・アクセサリアイコン一覧", font=title_font, fill="#ffffff")
    draw.text(
        (52, 92),
        "武器 26点（通常13 / 進化13）・アクセサリ 10点  |  data/weapons.json / data/gifts.json  |  2026-08-19",
        font=subtitle_font,
        fill="#aeb8c8",
    )

    section_header(draw, 145, "武器", "通常武器と対応する進化武器を左右に配置", "#73c8ff")
    weapon_grid_top = 210
    weapon_grid_width = 8 * CARD_WIDTH + 7 * CARD_GAP
    weapon_grid_left = (CANVAS_WIDTH - weapon_grid_width) // 2
    for index, item in enumerate(ordered_weapons):
        row = index // 8
        column = index % 8
        draw_card(
            canvas,
            draw,
            item,
            weapon_grid_left + column * (CARD_WIDTH + CARD_GAP),
            weapon_grid_top + row * (CARD_HEIGHT + ROW_GAP),
            f"{index + 1:02d}",
            "weapon",
        )

    accessory_header_y = 1350
    section_header(draw, accessory_header_y, "アクセサリ", "現行10点", "#f4c95d")
    accessory_grid_top = 1415
    accessory_columns = 5
    accessory_grid_width = accessory_columns * CARD_WIDTH + (accessory_columns - 1) * CARD_GAP
    accessory_grid_left = (CANVAS_WIDTH - accessory_grid_width) // 2
    for index, item in enumerate(accessories):
        row = index // accessory_columns
        column = index % accessory_columns
        draw_card(
            canvas,
            draw,
            item,
            accessory_grid_left + column * (CARD_WIDTH + CARD_GAP),
            accessory_grid_top + row * (CARD_HEIGHT + ROW_GAP),
            f"A{index + 1:02d}",
            "accessory",
        )

    metadata = PngImagePlugin.PngInfo()
    metadata.add_text("Title", "Current weapon and accessory icon inventory")
    metadata.add_text("Counts", "26 weapons; 10 accessories")
    metadata.add_text("Sources", "data/weapons.json; data/gifts.json")
    canvas.convert("RGB").save(OUTPUT, format="PNG", optimize=True, pnginfo=metadata)
    print(f"WROTE {OUTPUT}")
    print(f"SIZE {CANVAS_WIDTH}x{CANVAS_HEIGHT}")
    print(f"ITEMS {len(ordered_weapons) + len(accessories)}")


if __name__ == "__main__":
    main()
