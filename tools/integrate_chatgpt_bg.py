from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
SOURCE = Path(r"C:\Users\zenih\Desktop\bg.jpg")
OUT_DIR = ROOT / "assets" / "generated" / "maps" / "zatsudan_studio_layered_v1"
TARGET_SIZE = (2200, 1500)


def rect_from_src(x1: float, y1: float, x2: float, y2: float, sx: float, sy: float) -> list[int]:
    return [round(x1 * sx), round(y1 * sy), round(x2 * sx), round(y2 * sy)]


def main() -> None:
    img = Image.open(SOURCE).convert("RGB")
    sx = TARGET_SIZE[0] / img.size[0]
    sy = TARGET_SIZE[1] / img.size[1]
    resized = img.resize(TARGET_SIZE, Image.Resampling.LANCZOS)

    floor = OUT_DIR / "zatsudan_studio_chatgpt_floor_2200x1500.png"
    props = OUT_DIR / "zatsudan_studio_chatgpt_props_2200x1500.png"
    assembled = OUT_DIR / "zatsudan_studio_chatgpt_assembled_2200x1500.png"
    preview = OUT_DIR / "zatsudan_studio_chatgpt_collision_preview_2200x1500.png"

    resized.save(floor)
    resized.save(assembled)
    Image.new("RGBA", TARGET_SIZE, (0, 0, 0, 0)).save(props)

    collision_rects = [
        {"id": "bench_left_top", "rect": rect_from_src(272, 186, 444, 222, sx, sy)},
        {"id": "bench_right_mid", "rect": rect_from_src(632, 327, 780, 362, sx, sy)},
        {"id": "bench_bottom_left", "rect": rect_from_src(322, 493, 512, 530, sx, sy)},
    ]
    prop_rects = [
        {"id": "top_left_monitor", "rect": rect_from_src(54, 35, 224, 92, sx, sy)},
        {"id": "top_center_monitor", "rect": rect_from_src(382, 25, 632, 95, sx, sy)},
        {"id": "top_right_monitor", "rect": rect_from_src(754, 39, 966, 97, sx, sy)},
        {"id": "top_left_speaker", "rect": rect_from_src(238, 23, 292, 103, sx, sy)},
        {"id": "top_right_speaker", "rect": rect_from_src(649, 20, 705, 104, sx, sy)},
        {"id": "left_camera", "rect": rect_from_src(30, 130, 94, 243, sx, sy)},
        {"id": "left_bottom_camera", "rect": rect_from_src(22, 477, 94, 590, sx, sy)},
        {"id": "right_bottom_camera", "rect": rect_from_src(922, 470, 990, 585, sx, sy)},
        {"id": "bottom_console", "rect": rect_from_src(360, 600, 640, 698, sx, sy)},
        {"id": "bottom_left_plant", "rect": rect_from_src(20, 570, 95, 685, sx, sy)},
        {"id": "bottom_right_plant", "rect": rect_from_src(878, 570, 955, 685, sx, sy)},
        {"id": "top_left_plant", "rect": rect_from_src(220, 0, 282, 75, sx, sy)},
        {"id": "top_right_plant", "rect": rect_from_src(703, 0, 765, 74, sx, sy)},
    ]

    preview_img = resized.convert("RGBA")
    draw = ImageDraw.Draw(preview_img, "RGBA")
    for item in collision_rects:
        x1, y1, x2, y2 = item["rect"]
        draw.rectangle([x1, y1, x2, y2], outline=(255, 60, 80, 255), width=5, fill=(255, 60, 80, 45))
    for item in prop_rects:
        x1, y1, x2, y2 = item["rect"]
        draw.rectangle([x1, y1, x2, y2], outline=(40, 240, 255, 255), width=4, fill=(40, 240, 255, 35))
    preview_img.save(preview)

    manifest = {
        "id": "zatsudan_studio_chatgpt_bg_v1",
        "source": str(SOURCE),
        "sourceSize": list(img.size),
        "size": list(TARGET_SIZE),
        "layers": [
            {"id": "floor", "path": floor.name, "type": "base_with_baked_visual_props"},
            {"id": "props", "path": props.name, "type": "transparent_placeholder"},
            {"id": "assembled", "path": assembled.name, "type": "runtime_background"},
            {"id": "collision_preview", "path": preview.name, "type": "debug_preview"},
        ],
        "collision_rects": collision_rects,
        "prop_collision_rects": prop_rects,
        "notes": [
            "User supplied ChatGPT-generated neon studio background resized for the 2200x1500 arena contract.",
            "Visual props are baked into the floor image for this test pass.",
            "The props layer is intentionally transparent until separate props are produced.",
            "Collision rectangles are first-pass estimates and should be tuned from play screenshots.",
        ],
    }
    (OUT_DIR / "zatsudan_studio_chatgpt_bg_v1_manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    (OUT_DIR / "zatsudan_studio_chatgpt_assembled_2200x1500.prompt.txt").write_text(
        "User supplied ChatGPT-generated neon livestream studio background, resized to 2200x1500 and integrated as a test runtime background.\n",
        encoding="utf-8",
    )
    print(f"wrote {floor}")
    print(f"wrote {assembled}")
    print(f"wrote {preview}")
    print(f"scale {sx:.6f} {sy:.6f}")


if __name__ == "__main__":
    main()
