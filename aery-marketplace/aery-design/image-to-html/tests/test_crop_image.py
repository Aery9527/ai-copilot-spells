import pathlib
import sys
import tempfile
import unittest

from PIL import Image


SKILL_ROOT = pathlib.Path(__file__).resolve().parents[1]
SCRIPTS_DIR = SKILL_ROOT / "scripts"
sys.path.insert(0, str(SCRIPTS_DIR))

from crop_image import crop_image  # type: ignore


class CropImageTests(unittest.TestCase):
    def test_crops_xyxy_region_and_preserves_pixels(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            tmp_path = pathlib.Path(tmp_dir)
            source_path = tmp_path / "source.png"
            output_path = tmp_path / "crop.png"

            image = Image.new("RGB", (4, 4), (255, 255, 255))
            image.putpixel((1, 1), (255, 0, 0))
            image.putpixel((2, 1), (0, 255, 0))
            image.putpixel((1, 2), (0, 0, 255))
            image.save(source_path)

            result = crop_image(source_path, output_path, (1, 1, 3, 3))
            with Image.open(output_path) as cropped:
                self.assertEqual(result["size"], [2, 2])
                self.assertEqual(cropped.size, (2, 2))
                self.assertEqual(cropped.getpixel((0, 0)), (255, 0, 0))
                self.assertEqual(cropped.getpixel((1, 0)), (0, 255, 0))
                self.assertEqual(cropped.getpixel((0, 1)), (0, 0, 255))

    def test_rejects_out_of_bounds_box(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            tmp_path = pathlib.Path(tmp_dir)
            source_path = tmp_path / "source.png"
            output_path = tmp_path / "crop.png"
            Image.new("RGB", (4, 4), (0, 0, 0)).save(source_path)

            with self.assertRaises(ValueError):
                crop_image(source_path, output_path, (0, 0, 6, 6))


if __name__ == "__main__":
    unittest.main()
