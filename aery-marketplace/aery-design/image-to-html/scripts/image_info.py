from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

from PIL import Image


def get_image_info(image_path: str | Path) -> dict[str, Any]:
    path = Path(image_path)
    with Image.open(path) as image:
        width, height = image.size
        mode = image.mode

    return {
        "path": str(path.resolve()),
        "width": width,
        "height": height,
        "mode": mode,
    }


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Inspect an image and print its basic dimensions."
    )
    parser.add_argument("--image", required=True, help="Path to the input image.")
    parser.add_argument(
        "--json",
        action="store_true",
        help="Print the result as JSON.",
    )
    return parser


def main() -> None:
    args = build_parser().parse_args()
    info = get_image_info(args.image)

    if args.json:
        print(json.dumps(info, ensure_ascii=False, indent=2))
        return

    print(f"path:   {info['path']}")
    print(f"width:  {info['width']}")
    print(f"height: {info['height']}")
    print(f"mode:   {info['mode']}")


if __name__ == "__main__":
    main()
