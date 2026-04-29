import pathlib
import sys
import tempfile
import unittest

from PIL import Image


SKILL_ROOT = pathlib.Path(__file__).resolve().parents[1]
SCRIPTS_DIR = SKILL_ROOT / "scripts"
sys.path.insert(0, str(SCRIPTS_DIR))

from image_info import get_image_info  # type: ignore


class ImageInfoTests(unittest.TestCase):
    def test_returns_width_height_and_mode(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            image_path = pathlib.Path(tmp_dir) / "sample.png"
            Image.new("RGB", (7, 5), (10, 20, 30)).save(image_path)

            info = get_image_info(image_path)

        self.assertEqual(info["width"], 7)
        self.assertEqual(info["height"], 5)
        self.assertEqual(info["mode"], "RGB")


if __name__ == "__main__":
    unittest.main()
