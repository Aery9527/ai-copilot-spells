from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

from PIL import Image


Box = tuple[int, int, int, int]


def parse_box(box_text: str) -> Box:
    parts = [part.strip() for part in box_text.split(",")]
    if len(parts) != 4:
        raise ValueError("Box must contain four comma-separated integers.")

    try:
        left, top, third, fourth = (int(part) for part in parts)
    except ValueError as exc:
        raise ValueError("Box values must be integers.") from exc

    return left, top, third, fourth


def normalize_box(box: Box, image_size: tuple[int, int], box_format: str = "xyxy") -> Box:
    width, height = image_size
    left, top, third, fourth = box

    if box_format == "xywh":
        right = left + third
        bottom = top + fourth
    elif box_format == "xyxy":
        right = third
        bottom = fourth
    else:
        raise ValueError("box_format must be either 'xyxy' or 'xywh'.")

    normalized = (left, top, right, bottom)
    if left < 0 or top < 0 or right > width or bottom > height:
        raise ValueError("Crop box exceeds image bounds.")
    if left >= right or top >= bottom:
        raise ValueError("Crop box must have positive width and height.")

    return normalized


def crop_image(
    source_path: str | Path,
    output_path: str | Path,
    box: Box,
    box_format: str = "xyxy",
) -> dict[str, Any]:
    source = Path(source_path)
    output = Path(output_path)

    with Image.open(source) as image:
        normalized_box = normalize_box(box, image.size, box_format=box_format)
        cropped = image.crop(normalized_box)
        output.parent.mkdir(parents=True, exist_ok=True)
        cropped.save(output)
        crop_width, crop_height = cropped.size

    return {
        "source": str(source.resolve()),
        "output": str(output.resolve()),
        "box": list(normalized_box),
        "size": [crop_width, crop_height],
    }


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Crop a precise region from a source image."
    )
    parser.add_argument("--source", required=True, help="Path to the source image.")
    parser.add_argument("--output", required=True, help="Path to the output image.")
    parser.add_argument(
        "--box",
        required=True,
        help="Crop box as x1,y1,x2,y2 by default, or x,y,width,height with --box-format xywh.",
    )
    parser.add_argument(
        "--box-format",
        choices=("xyxy", "xywh"),
        default="xyxy",
        help="Interpretation of --box.",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Print the result as JSON.",
    )
    return parser


def main() -> None:
    args = build_parser().parse_args()
    result = crop_image(
        args.source,
        args.output,
        parse_box(args.box),
        box_format=args.box_format,
    )

    if args.json:
        print(json.dumps(result, ensure_ascii=False, indent=2))
        return

    print(f"source: {result['source']}")
    print(f"output: {result['output']}")
    print(f"box:    {result['box']}")
    print(f"size:   {result['size'][0]}x{result['size'][1]}")


if __name__ == "__main__":
    main()
