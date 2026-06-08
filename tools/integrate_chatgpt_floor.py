from __future__ import annotations

import json
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE = Path(r"C:\Users\zenih\Desktop\bg2.png")
OUT_DIR = ROOT / "assets" / "generated" / "maps" / "zatsudan_studio_layered_v1"
TARGET_SIZE = (2200, 1500)


def main() -> None:
    image = Image.open(SOURCE).convert("RGB")
    resized = image.resize(TARGET_SIZE, Image.Resampling.LANCZOS)

    floor = OUT_DIR / "zatsudan_studio_floor_only_chatgpt_2200x1500.png"
    props = OUT_DIR / "zatsudan_studio_floor_only_props_2200x1500.png"
    assembled = OUT_DIR / "zatsudan_studio_floor_only_assembled_2200x1500.png"
    preview = OUT_DIR / "zatsudan_studio_floor_only_collision_preview_2200x1500.png"

    resized.save(floor)
    resized.save(assembled)
    Image.new("RGBA", TARGET_SIZE, (0, 0, 0, 0)).save(props)
    resized.save(preview)

    manifest = {
        "id": "zatsudan_studio_floor_only_v1",
        "source": str(SOURCE),
        "sourceSize": list(image.size),
        "size": list(TARGET_SIZE),
        "layers": [
            {"id": "floor", "path": floor.name, "type": "base_floor_only"},
            {"id": "props", "path": props.name, "type": "transparent_placeholder"},
            {"id": "assembled", "path": assembled.name, "type": "runtime_background"},
            {"id": "collision_preview", "path": preview.name, "type": "debug_preview"},
        ],
        "collision_rects": [],
        "prop_collision_rects": [],
        "notes": [
            "User supplied ChatGPT-generated floor-only neon studio background.",
            "Resized to the existing 2200x1500 arena contract.",
            "No obstacle collision is registered in this pass to avoid invisible walls.",
            "Props and collision should be added later as separate layers.",
        ],
    }
    (OUT_DIR / "zatsudan_studio_floor_only_v1_manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    (OUT_DIR / "zatsudan_studio_floor_only_assembled_2200x1500.prompt.txt").write_text(
        "User supplied ChatGPT-generated neon grid floor-only studio background, resized to 2200x1500.\n",
        encoding="utf-8",
    )
    print(f"wrote {floor}")
    print(f"wrote {assembled}")


if __name__ == "__main__":
    main()
