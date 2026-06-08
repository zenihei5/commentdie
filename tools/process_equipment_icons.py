from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "assets" / "generated" / "equipment_icons_v1" / "raw-sheet.png"
OUT = ROOT / "assets" / "generated" / "equipment_icons_v1" / "icons"
IDS = [
    "ban_hammer",
    "superchat_shot",
    "comment_boomerang",
    "mic_barrier",
    "spotlight",
    "kusa_wave",
    "stream_power",
    "bullet_support",
    "high_speed_connection",
    "wide_angle",
    "light_sneakers",
    "sweet_tooth",
]

BOXES = {
    "ban_hammer": (40, 45, 405, 360),
    "superchat_shot": (420, 55, 820, 340),
    "comment_boomerang": (850, 40, 1220, 355),
    "mic_barrier": (55, 355, 390, 660),
    "spotlight": (430, 360, 825, 665),
    "kusa_wave": (820, 365, 1225, 665),
    "stream_power": (30, 645, 405, 945),
    "bullet_support": (430, 680, 790, 940),
    "high_speed_connection": (835, 680, 1215, 940),
    "wide_angle": (50, 950, 390, 1225),
    "light_sneakers": (430, 950, 790, 1225),
    "sweet_tooth": (835, 950, 1215, 1225),
}


def clear_magenta(image: Image.Image) -> Image.Image:
    result = image.convert("RGBA")
    pixels = result.load()
    width, height = result.size
    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            if r > 225 and g < 80 and b > 210:
                pixels[x, y] = (255, 0, 255, 0)
    return result


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    image = clear_magenta(Image.open(SRC))
    image.save(ROOT / "assets" / "generated" / "equipment_icons_v1" / "sheet-transparent.png")
    for index, icon_id in enumerate(IDS):
        cell = image.crop(BOXES[icon_id])
        bbox = cell.getbbox()
        item = cell.crop(bbox) if bbox else cell
        canvas = Image.new("RGBA", (96, 96), (0, 0, 0, 0))
        item.thumbnail((82, 82), Image.Resampling.LANCZOS)
        canvas.alpha_composite(item, ((96 - item.width) // 2, (96 - item.height) // 2))
        canvas.save(OUT / f"{icon_id}.png")
    print(f"created {len(IDS)} icons")


if __name__ == "__main__":
    main()
