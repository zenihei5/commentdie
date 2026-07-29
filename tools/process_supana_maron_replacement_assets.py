from __future__ import annotations

import json
from pathlib import Path

from PIL import Image

from process_kasumi_walk_new import remove_green_screen


ROOT = Path(__file__).resolve().parents[1]
DESKTOP = Path.home() / "Desktop" / "ぜんぶコメントのせいだ設定" / "歩行グラ"
FRAME_COUNT = 10
FPS = 12

ASSETS = (
    {
        "slug": "supana_walk_v1",
        "static_name": "すぱな歩き新.png",
        "walk_name": "untitled_1784872992031_front_run_run.png",
        "static_output": "supana-static-transparent.png",
    },
    {
        "slug": "maron_walk_v1",
        "static_name": "まろん歩き.png",
        "walk_name": "untitled_1784873326086_front_run_run.png",
        "static_output": "maron-static-transparent.png",
    },
)


def alpha_stats(image: Image.Image) -> dict[str, int]:
    histogram = image.getchannel("A").histogram()
    return {
        "transparentPixels": histogram[0],
        "partialAlphaPixels": sum(histogram[1:255]),
        "opaquePixels": histogram[255],
    }


def bbox(image: Image.Image) -> list[int] | None:
    bounds = image.getchannel("A").point(lambda value: 255 if value >= 8 else 0).getbbox()
    return list(bounds) if bounds else None


def process_asset(asset: dict[str, str]) -> None:
    static_source_path = DESKTOP / asset["static_name"]
    walk_source_path = DESKTOP / asset["walk_name"]
    if not static_source_path.is_file():
        raise FileNotFoundError(static_source_path)
    if not walk_source_path.is_file():
        raise FileNotFoundError(walk_source_path)

    static_source = Image.open(static_source_path).convert("RGBA")
    static = remove_green_screen(static_source)
    walk_source = Image.open(walk_source_path).convert("RGBA")
    walk = remove_green_screen(walk_source)
    if walk.width % FRAME_COUNT != 0:
        raise ValueError(f"walk sheet width {walk.width} is not divisible by {FRAME_COUNT}")

    cell_width = walk.width // FRAME_COUNT
    cell_height = walk.height
    frames = [
        walk.crop((index * cell_width, 0, (index + 1) * cell_width, cell_height))
        for index in range(FRAME_COUNT)
    ]

    output_dir = ROOT / "assets" / "generated" / asset["slug"]
    output_dir.mkdir(parents=True, exist_ok=True)
    static_path = output_dir / asset["static_output"]
    static.save(static_path, optimize=True)
    walk_path = output_dir / "walk-strip-transparent.png"
    walk.save(walk_path, optimize=True)

    frames_dir = output_dir / "frames"
    frames_dir.mkdir(parents=True, exist_ok=True)
    for index, frame in enumerate(frames):
        frame.save(frames_dir / f"frame-{index + 1:02d}.png", optimize=True)

    gif_frames = [frame.convert("P", palette=Image.Palette.ADAPTIVE, colors=255) for frame in frames]
    gif_frames[0].save(
        output_dir / "animation.gif",
        save_all=True,
        append_images=gif_frames[1:],
        duration=round(1000 / FPS),
        loop=0,
        disposal=2,
        optimize=True,
    )

    metadata = {
        "schemaVersion": 1,
        "static": {
            "sourceFile": static_source_path.name,
            "sourceSize": list(static_source.size),
            "output": static_path.relative_to(ROOT).as_posix(),
            "contentBounds": bbox(static),
            **alpha_stats(static),
        },
        "walk": {
            "sourceFile": walk_source_path.name,
            "sourceSize": list(walk_source.size),
            "output": walk_path.relative_to(ROOT).as_posix(),
            "frameCount": FRAME_COUNT,
            "fps": FPS,
            "cellSize": [cell_width, cell_height],
            "frames": [
                {
                    "index": index,
                    "file": f"frames/frame-{index + 1:02d}.png",
                    "contentBounds": bbox(frame),
                    **alpha_stats(frame),
                }
                for index, frame in enumerate(frames)
            ],
        },
        "processing": {
            "static": "border-connected green chroma key with edge despill",
            "walk": "deterministic equal-cell split and RGBA strip cleanup",
        },
    }
    (output_dir / "manifest.json").write_text(
        json.dumps(metadata, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"processed {asset['slug']}: {static_source_path.name} / {walk_source_path.name}")
    print(output_dir)


def main() -> None:
    for asset in ASSETS:
        process_asset(asset)


if __name__ == "__main__":
    main()
