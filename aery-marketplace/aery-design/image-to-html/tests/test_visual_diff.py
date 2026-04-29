import pathlib
import sys
import tempfile
import unittest

from PIL import Image


SKILL_ROOT = pathlib.Path(__file__).resolve().parents[1]
SCRIPTS_DIR = SKILL_ROOT / "scripts"
sys.path.insert(0, str(SCRIPTS_DIR))

from visual_diff import compare_images  # type: ignore


class VisualDiffTests(unittest.TestCase):
    def test_identical_images_have_zero_difference(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            tmp_path = pathlib.Path(tmp_dir)
            expected = tmp_path / "expected.png"
            actual = tmp_path / "actual.png"
            Image.new("RGB", (4, 4), (80, 90, 100)).save(expected)
            Image.new("RGB", (4, 4), (80, 90, 100)).save(actual)

            result = compare_images(expected, actual)

        self.assertEqual(result["mean_diff_ratio"], 0.0)
        self.assertIsNone(result["diff_bbox"])
        self.assertEqual(result["changed_pixels"], 0)

    def test_reports_diff_bbox_for_changed_pixels(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            tmp_path = pathlib.Path(tmp_dir)
            expected = tmp_path / "expected.png"
            actual = tmp_path / "actual.png"

            base = Image.new("RGB", (5, 5), (255, 255, 255))
            base.save(expected)
            changed = base.copy()
            changed.putpixel((2, 1), (0, 0, 0))
            changed.putpixel((3, 3), (0, 0, 0))
            changed.save(actual)

            result = compare_images(expected, actual)

        self.assertGreater(result["mean_diff_ratio"], 0.0)
        self.assertEqual(result["diff_bbox"], [2, 1, 4, 4])
        self.assertEqual(result["changed_pixels"], 2)

    def test_rejects_size_mismatch(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            tmp_path = pathlib.Path(tmp_dir)
            expected = tmp_path / "expected.png"
            actual = tmp_path / "actual.png"
            Image.new("RGB", (4, 4), (0, 0, 0)).save(expected)
            Image.new("RGB", (5, 4), (0, 0, 0)).save(actual)

            with self.assertRaises(ValueError):
                compare_images(expected, actual)


if __name__ == "__main__":
    unittest.main()
