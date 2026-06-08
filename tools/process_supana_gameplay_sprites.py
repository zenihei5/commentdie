from __future__ import annotations

import argparse
import json
from collections import deque
from pathlib import Path
from typing import Callable

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_OUTPUT_DIR = ROOT / "assets" / "generated" / "supana_gameplay_sprites_v1"
CELL_SIZE = 128


Pixel = tuple[int, int, int, int]


def is_green_background(pixel: Pixel) -> bool:
    r, g, b, a = pixel
    if a == 0:
        return True
    return g > 170 and g - r > 75 and g - b > 75 and r < 145 and b < 145


def is_black_background(pixel: Pixel) -> bool:
    r, g, b, a = pixel
    if a == 0:
        return True
    return r <= 8 and g <= 8 and b <= 8


def remove_connected_background(image: Image.Image, is_background: Callable[[Pixel], bool]) -> Image.Image:
    result = image.convert("RGBA")
    pixels = result.load()
    width, height = result.size
    visited: set[tuple[int, int]] = set()
    queue: deque[tuple[int, int]] = deque()

    for x in range(width):
        queue.append((x, 0))
        queue.append((x, height - 1))
    for y in range(height):
        queue.append((0, y))
        queue.append((width - 1, y))

    while queue:
        x, y = queue.popleft()
        if x < 0 or y < 0 or x >= width or y >= height or (x, y) in visited:
            continue
        visited.add((x, y))
        if not is_background(pixels[x, y]):
            continue
        r, g, b, _a = pixels[x, y]
        pixels[x, y] = (r, g, b, 0)
        queue.append((x + 1, y))
        queue.append((x - 1, y))
        queue.append((x, y + 1))
        queue.append((x, y - 1))

    return result


def remove_matching_background(image: Image.Image, is_background: Callable[[Pixel], bool]) -> Image.Image:
    result = image.convert("RGBA")
    pixels = result.load()
    width, height = result.size
    for y in range(height):
        for x in range(width):
            if not is_background(pixels[x, y]):
                continue
            r, g, b, _a = pixels[x, y]
            pixels[x, y] = (r, g, b, 0)
    return result


def alpha_bbox(image: Image.Image) -> tuple[int, int, int, int]:
    bbox = image.getchannel("A").getbbox()
    if bbox is None:
        raise ValueError("image has no visible pixels")
    return bbox


def fit_crop_to_cell(
    crop: Image.Image,
    target_height: int,
    target_width: int,
    bottom_margin: int,
    y_offset: int = 0,
) -> tuple[Image.Image, dict]:
    scale = min(target_height / crop.height, target_width / crop.width)
    new_size = (max(1, round(crop.width * scale)), max(1, round(crop.height * scale)))
    resized = crop.resize(new_size, Image.Resampling.NEAREST)
    cell = Image.new("RGBA", (CELL_SIZE, CELL_SIZE), (0, 0, 0, 0))
    x = (CELL_SIZE - resized.width) // 2
    y = CELL_SIZE - bottom_margin - resized.height + y_offset
    cell.alpha_composite(resized, (x, y))
    return cell, {
        "sourceSize": list(crop.size),
        "outputSize": list(resized.size),
        "pastePosition": [x, y],
        "scale": scale,
    }


def save_sheet(frames: list[Image.Image], cols: int, rows: int, path: Path) -> None:
    sheet = Image.new("RGBA", (cols * CELL_SIZE, rows * CELL_SIZE), (0, 0, 0, 0))
    for index, frame in enumerate(frames):
        x = (index % cols) * CELL_SIZE
        y = (index // cols) * CELL_SIZE
        sheet.alpha_composite(frame, (x, y))
    sheet.save(path)


def save_gif(frames: list[Image.Image], path: Path, duration: int) -> None:
    frames[0].save(
        path,
        save_all=True,
        append_images=frames[1:],
        duration=duration,
        loop=0,
        disposal=2,
    )


def process_idle(source: Path, output_dir: Path, slug: str) -> dict:
    image = Image.open(source).convert("RGBA")
    alpha = remove_matching_background(image, is_green_background)
    bbox = alpha_bbox(alpha)
    crop = alpha.crop(bbox)
    frames: list[Image.Image] = []
    frame_meta: list[dict] = []
    for index, y_offset in enumerate([0, -1, 0, 1], start=1):
        frame, meta = fit_crop_to_cell(crop, target_height=116, target_width=112, bottom_margin=7, y_offset=y_offset)
        frame_path = output_dir / f"{slug}_idle-{index}.png"
        frame.save(frame_path)
        frames.append(frame)
        meta["frame"] = index
        meta["yOffset"] = y_offset
        frame_meta.append(meta)
    sheet_path = output_dir / "idle-sheet-transparent.png"
    save_sheet(frames, cols=2, rows=2, path=sheet_path)
    save_gif(frames, output_dir / "idle-animation.gif", duration=220)
    return {
        "source": str(source),
        "sourceSize": list(image.size),
        "sourceBBox": list(bbox),
        "sheet": str(sheet_path),
        "cols": 2,
        "rows": 2,
        "fps": 4,
        "frames": frame_meta,
    }


def process_run(source: Path, output_dir: Path, source_frame_count: int, slug: str) -> dict:
    image = Image.open(source).convert("RGBA")
    if image.width % source_frame_count != 0:
        raise ValueError(f"source width {image.width} is not divisible by {source_frame_count}")
    source_frame_width = image.width // source_frame_count
    frames: list[Image.Image] = []
    frame_meta: list[dict] = []
    for index in range(source_frame_count):
        box = (index * source_frame_width, 0, (index + 1) * source_frame_width, image.height)
        source_frame = image.crop(box)
        alpha = remove_connected_background(source_frame, is_black_background)
        bbox = alpha_bbox(alpha)
        crop = alpha.crop(bbox)
        frame, meta = fit_crop_to_cell(crop, target_height=104, target_width=118, bottom_margin=7)
        frame_path = output_dir / f"{slug}_run-{index + 1}.png"
        frame.save(frame_path)
        frames.append(frame)
        meta["frame"] = index + 1
        meta["sourceBox"] = list(box)
        meta["sourceBBox"] = list(bbox)
        frame_meta.append(meta)
    sheet_path = output_dir / "run-sheet-transparent.png"
    save_sheet(frames, cols=5, rows=2, path=sheet_path)
    save_gif(frames, output_dir / "run-animation.gif", duration=80)
    return {
        "source": str(source),
        "sourceSize": list(image.size),
        "sourceFrameCount": source_frame_count,
        "sheet": str(sheet_path),
        "cols": 5,
        "rows": 2,
        "fps": 12,
        "frames": frame_meta,
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--character-id", default="superchat_chan")
    parser.add_argument("--slug", default="supana")
    parser.add_argument("--idle-source", required=True, type=Path)
    parser.add_argument("--run-source", required=True, type=Path)
    parser.add_argument("--output-dir", default=DEFAULT_OUTPUT_DIR, type=Path)
    parser.add_argument("--run-source-frames", default=10, type=int)
    args = parser.parse_args()

    args.output_dir.mkdir(parents=True, exist_ok=True)
    idle_meta = process_idle(args.idle_source, args.output_dir, args.slug)
    run_meta = process_run(args.run_source, args.output_dir, args.run_source_frames, args.slug)
    meta = {
        "character": args.character_id,
        "cellSize": CELL_SIZE,
        "idle": idle_meta,
        "run": run_meta,
    }
    (args.output_dir / "pipeline-meta.json").write_text(json.dumps(meta, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"processed {args.slug} gameplay sprites -> {args.output_dir}")


if __name__ == "__main__":
    main()
