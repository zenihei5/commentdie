from __future__ import annotations

import json
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
DESKTOP = Path.home() / "Desktop"
OUTPUT_DIR = ROOT / "assets" / "generated" / "senior_unit_walk_v1"

ASSETS = [
    {
        "id": "aosumi_kyasumi",
        "source_name": "kyasumi-walk-new-transparent_front_run_run_sheet.png",
        "frame_count": 10,
        "fps": 12,
        "motion": "run",
    },
    {
        "id": "akarine_rizumu",
        "source_name": "untitled_1784812890603_front_run_run.png",
        "frame_count": 10,
        "fps": 12,
        "motion": "run",
    },
    {
        "id": "shizuki_miimu",
        "source_name": "untitled_1784818747470_front_run_run.png",
        "frame_count": 10,
        "fps": 12,
        "motion": "run",
    },
]


def find_source(name: str) -> Path:
    matches = sorted(DESKTOP.rglob(name))
    if not matches:
        raise FileNotFoundError(f"source image not found under {DESKTOP}: {name}")
    if len(matches) > 1:
        raise RuntimeError(f"multiple source images found for {name}: {matches}")
    return matches[0]


def frame_alpha_stats(image: Image.Image) -> dict[str, int]:
    histogram = image.getchannel("A").histogram()
    return {
        "transparentPixels": histogram[0],
        "partialAlphaPixels": sum(histogram[1:255]),
        "opaquePixels": histogram[255],
    }


def frame_bbox(image: Image.Image) -> list[int] | None:
    bbox = image.getchannel("A").point(lambda value: 255 if value >= 8 else 0).getbbox()
    return list(bbox) if bbox is not None else None


def make_preview_gif(frames: list[Image.Image], path: Path, fps: int) -> None:
    # GIF is only a review artifact; the game consumes the lossless PNG strip.
    preview_frames = [frame.convert("P", palette=Image.Palette.ADAPTIVE, colors=255) for frame in frames]
    preview_frames[0].save(
        path,
        save_all=True,
        append_images=preview_frames[1:],
        duration=round(1000 / fps),
        loop=0,
        disposal=2,
        optimize=True,
    )


def process_asset(asset: dict[str, object]) -> dict[str, object]:
    asset_id = str(asset["id"])
    source_name = str(asset["source_name"])
    frame_count = int(asset["frame_count"])
    fps = int(asset["fps"])
    source_path = find_source(source_name)
    source = Image.open(source_path).convert("RGBA")
    if source.width % frame_count != 0:
        raise ValueError(f"{source_path.name} width {source.width} is not divisible by {frame_count}")

    cell_width = source.width // frame_count
    cell_height = source.height
    frames = [
        source.crop((index * cell_width, 0, (index + 1) * cell_width, cell_height))
        for index in range(frame_count)
    ]
    output_dir = OUTPUT_DIR / asset_id
    frames_dir = output_dir / "frames"
    output_dir.mkdir(parents=True, exist_ok=True)
    frames_dir.mkdir(parents=True, exist_ok=True)

    source_copy_path = output_dir / "source.png"
    source.save(source_copy_path, optimize=True)

    strip = Image.new("RGBA", source.size, (0, 0, 0, 0))
    for index, frame in enumerate(frames):
        strip.alpha_composite(frame, (index * cell_width, 0))
        frame.save(frames_dir / f"frame-{index + 1:02d}.png", optimize=True)
    strip_path = output_dir / "walk-strip-transparent.png"
    strip.save(strip_path, optimize=True)
    make_preview_gif(frames, output_dir / "animation.gif", fps)

    frame_records: list[dict[str, object]] = []
    for index, frame in enumerate(frames):
        frame_records.append(
            {
                "index": index,
                "file": f"frames/frame-{index + 1:02d}.png",
                "contentBounds": frame_bbox(frame),
                **frame_alpha_stats(frame),
            }
        )
    metadata = {
        "schemaVersion": 1,
        "assetId": asset_id,
        "motion": str(asset["motion"]),
        "sourceFile": source_name,
        "sourceSize": list(source.size),
        "frameCount": frame_count,
        "fps": fps,
        "cellSize": [cell_width, cell_height],
        "alphaPreserved": True,
        "processing": "deterministic equal-cell split and lossless RGBA strip assembly",
        "runtime": {
            "texture": f"res://assets/generated/senior_unit_walk_v1/{asset_id}/walk-strip-transparent.png",
            "cols": frame_count,
            "rows": 1,
        },
        "frames": frame_records,
    }
    (output_dir / "pipeline-meta.json").write_text(
        json.dumps(metadata, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    return metadata


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    manifest = {
        "schemaVersion": 1,
        "outputDirectory": OUTPUT_DIR.relative_to(ROOT).as_posix(),
        "assets": [process_asset(asset) for asset in ASSETS],
    }
    (OUTPUT_DIR / "manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"processed {len(ASSETS)} senior-unit walk sheets")
    print(OUTPUT_DIR)


if __name__ == "__main__":
    main()
