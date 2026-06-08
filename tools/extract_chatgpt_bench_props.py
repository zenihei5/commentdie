from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter


ROOT = Path(__file__).resolve().parents[1]
FULL_BG_SOURCE = Path(r"C:\Users\zenih\Desktop\bg.jpg")
OUT_DIR = ROOT / "assets" / "generated" / "maps" / "zatsudan_studio_layered_v1"
TARGET_SIZE = (2200, 1500)


BENCHES = [
    {"id": "bench_left_top", "src_rect": (264, 178, 452, 232), "collision_rect": (584, 400, 954, 477)},
    {"id": "bench_right_mid", "src_rect": (625, 319, 790, 372), "collision_rect": (1358, 703, 1676, 778)},
    {"id": "bench_bottom_left", "src_rect": (315, 486, 523, 542), "collision_rect": (692, 1059, 1100, 1139)},
]


def scaled_rect(rect: tuple[int, int, int, int], sx: float, sy: float) -> tuple[int, int, int, int]:
    x1, y1, x2, y2 = rect
    return round(x1 * sx), round(y1 * sy), round(x2 * sx), round(y2 * sy)


def bench_mask(size: tuple[int, int]) -> Image.Image:
    width, height = size
    mask = Image.new("L", size, 0)
    draw = ImageDraw.Draw(mask)
    body = (6, round(height * 0.18), width - 6, round(height * 0.80))
    shadow = (0, round(height * 0.55), width, height - 1)
    draw.rounded_rectangle(shadow, radius=max(8, height // 5), fill=96)
    draw.rounded_rectangle(body, radius=max(10, height // 4), fill=255)
    return mask.filter(ImageFilter.GaussianBlur(1.2))


def main() -> None:
    source = Image.open(FULL_BG_SOURCE).convert("RGBA")
    sx = TARGET_SIZE[0] / source.size[0]
    sy = TARGET_SIZE[1] / source.size[1]
    props = Image.new("RGBA", TARGET_SIZE, (0, 0, 0, 0))

    collision_rects: list[dict] = []
    for item in BENCHES:
        src_rect = item["src_rect"]
        src_crop = source.crop(src_rect)
        target_rect = scaled_rect(src_rect, sx, sy)
        target_size = (target_rect[2] - target_rect[0], target_rect[3] - target_rect[1])
        crop = src_crop.resize(target_size, Image.Resampling.LANCZOS)
        crop.putalpha(bench_mask(target_size))
        props.alpha_composite(crop, (target_rect[0], target_rect[1]))
        collision_rects.append({"id": item["id"], "rect": list(item["collision_rect"])})

    props_path = OUT_DIR / "zatsudan_studio_bench_props_2200x1500.png"
    assembled_path = OUT_DIR / "zatsudan_studio_floor_with_benches_assembled_2200x1500.png"
    preview_path = OUT_DIR / "zatsudan_studio_floor_with_benches_collision_preview_2200x1500.png"
    floor_path = OUT_DIR / "zatsudan_studio_floor_only_chatgpt_2200x1500.png"

    floor = Image.open(floor_path).convert("RGBA")
    assembled = floor.copy()
    assembled.alpha_composite(props)
    preview = assembled.copy()
    draw = ImageDraw.Draw(preview, "RGBA")
    for item in collision_rects:
        x1, y1, x2, y2 = item["rect"]
        draw.rectangle([x1, y1, x2, y2], outline=(255, 60, 80, 255), width=5, fill=(255, 60, 80, 45))

    props.save(props_path)
    assembled.save(assembled_path)
    preview.save(preview_path)

    manifest = {
        "id": "zatsudan_studio_floor_with_benches_v1",
        "size": list(TARGET_SIZE),
        "source": str(FULL_BG_SOURCE),
        "layers": [
            {"id": "floor", "path": floor_path.name, "type": "base_floor_only"},
            {"id": "props", "path": props_path.name, "type": "separate_bench_props"},
            {"id": "assembled", "path": assembled_path.name, "type": "runtime_background"},
            {"id": "collision_preview", "path": preview_path.name, "type": "debug_preview"},
        ],
        "collision_rects": collision_rects,
        "prop_collision_rects": [],
        "notes": [
            "Bench props were extracted from the user's full ChatGPT background as a first separate-prop pass.",
            "This is a rough alpha extraction intended for gameplay/collision validation.",
            "Replace these crops with clean generated/painted transparent props later if the layout feels good.",
        ],
    }
    (OUT_DIR / "zatsudan_studio_floor_with_benches_v1_manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    print(f"wrote {props_path}")
    print(f"wrote {assembled_path}")
    print(f"wrote {preview_path}")


if __name__ == "__main__":
    main()
