from __future__ import annotations

import argparse
import json
import os
import tempfile
from pathlib import Path

import numpy as np
from PIL import Image


DEFAULT_TARGET_SIZE = 512


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Normalize a high-resolution RGBA equipment icon onto a transparent "
            "square canvas without cropping or upscaling."
        )
    )
    parser.add_argument("input_png", type=Path, help="Source RGBA PNG")
    parser.add_argument("output_png", type=Path, help="Destination PNG")
    parser.add_argument(
        "--target-size",
        type=int,
        default=DEFAULT_TARGET_SIZE,
        help=f"Square output size in pixels (default: {DEFAULT_TARGET_SIZE})",
    )
    return parser.parse_args()


def _premultiplied_lanczos_resize(image: Image.Image, size: tuple[int, int]) -> Image.Image:
    """Resize RGBA in premultiplied-alpha float space using Lanczos."""
    rgba = np.asarray(image.convert("RGBA"), dtype=np.float32) / 255.0
    alpha = rgba[:, :, 3]
    premultiplied_rgb = rgba[:, :, :3] * alpha[:, :, np.newaxis]

    resized_channels: list[np.ndarray] = []
    for channel_index in range(3):
        channel = Image.fromarray(premultiplied_rgb[:, :, channel_index], mode="F")
        resized_channels.append(
            np.asarray(channel.resize(size, Image.Resampling.LANCZOS), dtype=np.float32)
        )
    alpha_image = Image.fromarray(alpha, mode="F")
    resized_alpha = np.asarray(
        alpha_image.resize(size, Image.Resampling.LANCZOS), dtype=np.float32
    )

    resized_alpha = np.clip(resized_alpha, 0.0, 1.0)
    resized_premultiplied = np.stack(resized_channels, axis=2)
    resized_premultiplied = np.clip(
        resized_premultiplied,
        0.0,
        resized_alpha[:, :, np.newaxis],
    )

    output_alpha = np.rint(resized_alpha * 255.0).astype(np.uint8)
    output_rgb = np.zeros_like(resized_premultiplied, dtype=np.float32)
    visible = output_alpha > 0
    np.divide(
        resized_premultiplied,
        resized_alpha[:, :, np.newaxis],
        out=output_rgb,
        where=resized_alpha[:, :, np.newaxis] > 1.0e-8,
    )
    output_rgb = np.rint(np.clip(output_rgb, 0.0, 1.0) * 255.0).astype(np.uint8)
    output_rgb[~visible] = 0

    output_rgba = np.dstack((output_rgb, output_alpha))
    return Image.fromarray(output_rgba, mode="RGBA")


def normalize_equipment_icon(
    input_path: Path,
    output_path: Path,
    target_size: int = DEFAULT_TARGET_SIZE,
) -> dict[str, object]:
    if target_size <= 0:
        raise ValueError("target size must be greater than zero")
    if input_path.suffix.lower() != ".png":
        raise ValueError(f"input must be a PNG: {input_path}")
    if output_path.suffix.lower() != ".png":
        raise ValueError(f"output must be a PNG: {output_path}")
    if not input_path.is_file():
        raise FileNotFoundError(input_path)

    with Image.open(input_path) as source_file:
        source = source_file.convert("RGBA")
        source_size = source.size
        icc_profile = source_file.info.get("icc_profile")

    scale = min(
        1.0,
        target_size / source.width,
        target_size / source.height,
    )
    fitted_size = (
        max(1, round(source.width * scale)),
        max(1, round(source.height * scale)),
    )
    if fitted_size == source.size:
        fitted = source.copy()
    else:
        fitted = _premultiplied_lanczos_resize(source, fitted_size)

    canvas = Image.new("RGBA", (target_size, target_size), (0, 0, 0, 0))
    offset = (
        (target_size - fitted.width) // 2,
        (target_size - fitted.height) // 2,
    )
    canvas.alpha_composite(fitted, offset)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    temporary_path: Path | None = None
    try:
        with tempfile.NamedTemporaryFile(
            prefix=f".{output_path.stem}.",
            suffix=".png",
            dir=output_path.parent,
            delete=False,
        ) as temporary_file:
            temporary_path = Path(temporary_file.name)
        save_options: dict[str, object] = {"format": "PNG", "optimize": True}
        if icc_profile is not None:
            save_options["icc_profile"] = icc_profile
        canvas.save(temporary_path, **save_options)
        os.replace(temporary_path, output_path)
        temporary_path = None
    finally:
        if temporary_path is not None:
            temporary_path.unlink(missing_ok=True)

    return {
        "input": str(input_path.resolve()),
        "output": str(output_path.resolve()),
        "sourceMode": "RGBA",
        "sourceSize": list(source_size),
        "targetSize": [target_size, target_size],
        "fittedSize": list(fitted_size),
        "offset": list(offset),
        "scale": scale,
        "resampled": fitted_size != source_size,
        "resampling": "Lanczos" if fitted_size != source_size else "none",
        "alphaProcessing": "premultiplied float32",
        "cropped": False,
        "upscaled": scale > 1.0,
    }


def main() -> None:
    args = _parse_args()
    result = normalize_equipment_icon(
        args.input_png,
        args.output_png,
        args.target_size,
    )
    print(json.dumps(result, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
