from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

from PIL import Image, ImageChops


def compare_images(
    expected_path: str | Path,
    actual_path: str | Path,
    threshold: int = 0,
) -> dict[str, Any]:
    expected_file = Path(expected_path)
    actual_file = Path(actual_path)

    with Image.open(expected_file).convert("RGB") as expected_image, Image.open(
        actual_file
    ).convert("RGB") as actual_image:
        if expected_image.size != actual_image.size:
            raise ValueError(
                f"Image size mismatch: expected {expected_image.size}, got {actual_image.size}."
            )

        diff = ImageChops.difference(expected_image, actual_image)
        width, height = expected_image.size
        total_abs_diff = 0
        changed_pixels = 0
        min_x: int | None = None
        min_y: int | None = None
        max_x: int | None = None
        max_y: int | None = None

        for y in range(height):
            for x in range(width):
                r, g, b = diff.getpixel((x, y))
                total_abs_diff += r + g + b
                if max(r, g, b) <= threshold:
                    continue

                changed_pixels += 1
                min_x = x if min_x is None else min(min_x, x)
                min_y = y if min_y is None else min(min_y, y)
                max_x = x if max_x is None else max(max_x, x)
                max_y = y if max_y is None else max(max_y, y)

    diff_bbox = None
    if min_x is not None and min_y is not None and max_x is not None and max_y is not None:
        diff_bbox = [min_x, min_y, max_x + 1, max_y + 1]

    total_channels = width * height * 255 * 3
    mean_diff_ratio = 0.0 if total_channels == 0 else total_abs_diff / total_channels

    return {
        "expected": str(expected_file.resolve()),
        "actual": str(actual_file.resolve()),
        "size": [width, height],
        "threshold": threshold,
        "changed_pixels": changed_pixels,
        "mean_diff_ratio": mean_diff_ratio,
        "diff_bbox": diff_bbox,
    }


def save_artifacts(
    expected_path: str | Path,
    actual_path: str | Path,
    diff_out: str | Path | None = None,
    overlay_out: str | Path | None = None,
) -> None:
    with Image.open(expected_path).convert("RGB") as expected_image, Image.open(
        actual_path
    ).convert("RGB") as actual_image:
        if diff_out is not None:
            diff_image = ImageChops.difference(expected_image, actual_image)
            diff_output = Path(diff_out)
            diff_output.parent.mkdir(parents=True, exist_ok=True)
            diff_image.save(diff_output)

        if overlay_out is not None:
            overlay_image = Image.blend(expected_image, actual_image, 0.5)
            overlay_output = Path(overlay_out)
            overlay_output.parent.mkdir(parents=True, exist_ok=True)
            overlay_image.save(overlay_output)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Compare two same-sized images and report a visual diff summary."
    )
    parser.add_argument("--expected", required=True, help="Reference image path.")
    parser.add_argument("--actual", required=True, help="Rendered image path.")
    parser.add_argument(
        "--threshold",
        type=int,
        default=0,
        help="Ignore per-channel differences less than or equal to this value.",
    )
    parser.add_argument(
        "--diff-out",
        help="Optional path for saving the raw diff image.",
    )
    parser.add_argument(
        "--overlay-out",
        help="Optional path for saving a 50/50 overlay image.",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Print the result as JSON.",
    )
    return parser


def main() -> None:
    args = build_parser().parse_args()
    result = compare_images(args.expected, args.actual, threshold=args.threshold)
    save_artifacts(
        args.expected,
        args.actual,
        diff_out=args.diff_out,
        overlay_out=args.overlay_out,
    )

    if args.json:
        print(json.dumps(result, ensure_ascii=False, indent=2))
        return

    print(f"expected:        {result['expected']}")
    print(f"actual:          {result['actual']}")
    print(f"size:            {result['size'][0]}x{result['size'][1]}")
    print(f"changed_pixels:  {result['changed_pixels']}")
    print(f"mean_diff_ratio: {result['mean_diff_ratio']:.6f}")
    print(f"diff_bbox:       {result['diff_bbox']}")


if __name__ == "__main__":
    main()
