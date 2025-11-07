#!/usr/bin/env python3
"""Generate platform launcher icons from a single 1024x1024 PNG source."""
from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Iterable, Tuple

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent

ANDROID_RES = ROOT / "android" / "app" / "src" / "main" / "res"
IOS_APPICONSET = ROOT / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
WEB_ICONS = ROOT / "web" / "icons"
WEB_FAVICON = ROOT / "web" / "favicon.png"

ANDROID_SIZES: Tuple[Tuple[str, int], ...] = (
    ("mipmap-mdpi", 48),
    ("mipmap-hdpi", 72),
    ("mipmap-xhdpi", 96),
    ("mipmap-xxhdpi", 144),
    ("mipmap-xxxhdpi", 192),
)

IOS_FILES: Tuple[Tuple[str, float, int], ...] = (
    ("AppIcon-20.png", 20.0, 1),
    ("AppIcon-20@2x.png", 20.0, 2),
    ("AppIcon-20@3x.png", 20.0, 3),
    ("AppIcon-29.png", 29.0, 1),
    ("AppIcon-29@2x.png", 29.0, 2),
    ("AppIcon-29@3x.png", 29.0, 3),
    ("AppIcon-40.png", 40.0, 1),
    ("AppIcon-40@2x.png", 40.0, 2),
    ("AppIcon-40@3x.png", 40.0, 3),
    ("AppIcon-50.png", 50.0, 1),
    ("AppIcon-50@2x.png", 50.0, 2),
    ("AppIcon-57.png", 57.0, 1),
    ("AppIcon-57@2x.png", 57.0, 2),
    ("AppIcon-60@2x.png", 60.0, 2),
    ("AppIcon-60@3x.png", 60.0, 3),
    ("AppIcon-72.png", 72.0, 1),
    ("AppIcon-72@2x.png", 72.0, 2),
    ("AppIcon-76.png", 76.0, 1),
    ("AppIcon-76@2x.png", 76.0, 2),
    ("AppIcon-83.5@2x.png", 83.5, 2),
    ("AppIcon-512@2x.png", 512.0, 2),
    ("Icon-App-20x20@1x.png", 20.0, 1),
    ("Icon-App-20x20@2x.png", 20.0, 2),
    ("Icon-App-20x20@3x.png", 20.0, 3),
    ("Icon-App-29x29@1x.png", 29.0, 1),
    ("Icon-App-29x29@2x.png", 29.0, 2),
    ("Icon-App-29x29@3x.png", 29.0, 3),
    ("Icon-App-40x40@1x.png", 40.0, 1),
    ("Icon-App-40x40@2x.png", 40.0, 2),
    ("Icon-App-40x40@3x.png", 40.0, 3),
    ("Icon-App-50x50@1x.png", 50.0, 1),
    ("Icon-App-50x50@2x.png", 50.0, 2),
    ("Icon-App-57x57@1x.png", 57.0, 1),
    ("Icon-App-57x57@2x.png", 57.0, 2),
    ("Icon-App-60x60@2x.png", 60.0, 2),
    ("Icon-App-60x60@3x.png", 60.0, 3),
    ("Icon-App-72x72@1x.png", 72.0, 1),
    ("Icon-App-72x72@2x.png", 72.0, 2),
    ("Icon-App-76x76@1x.png", 76.0, 1),
    ("Icon-App-76x76@2x.png", 76.0, 2),
    ("Icon-App-83.5x83.5@2x.png", 83.5, 2),
    ("Icon-App-1024x1024@1x.png", 1024.0, 1),
)

IOS_CONTENTS = [
    {"idiom": "iphone", "size": "20x20", "scale": "2x", "filename": "AppIcon-20@2x.png"},
    {"idiom": "iphone", "size": "20x20", "scale": "3x", "filename": "AppIcon-20@3x.png"},
    {"idiom": "iphone", "size": "29x29", "scale": "2x", "filename": "AppIcon-29@2x.png"},
    {"idiom": "iphone", "size": "29x29", "scale": "3x", "filename": "AppIcon-29@3x.png"},
    {"idiom": "iphone", "size": "40x40", "scale": "2x", "filename": "AppIcon-40@2x.png"},
    {"idiom": "iphone", "size": "40x40", "scale": "3x", "filename": "AppIcon-40@3x.png"},
    {"idiom": "iphone", "size": "60x60", "scale": "2x", "filename": "AppIcon-60@2x.png"},
    {"idiom": "iphone", "size": "60x60", "scale": "3x", "filename": "AppIcon-60@3x.png"},
    {"idiom": "ipad", "size": "20x20", "scale": "1x", "filename": "AppIcon-20.png"},
    {"idiom": "ipad", "size": "20x20", "scale": "2x", "filename": "AppIcon-20@2x.png"},
    {"idiom": "ipad", "size": "29x29", "scale": "1x", "filename": "AppIcon-29.png"},
    {"idiom": "ipad", "size": "29x29", "scale": "2x", "filename": "AppIcon-29@2x.png"},
    {"idiom": "ipad", "size": "40x40", "scale": "1x", "filename": "AppIcon-40.png"},
    {"idiom": "ipad", "size": "40x40", "scale": "2x", "filename": "AppIcon-40@2x.png"},
    {"idiom": "ipad", "size": "50x50", "scale": "1x", "filename": "AppIcon-50.png"},
    {"idiom": "ipad", "size": "50x50", "scale": "2x", "filename": "AppIcon-50@2x.png"},
    {"idiom": "ipad", "size": "72x72", "scale": "1x", "filename": "AppIcon-72.png"},
    {"idiom": "ipad", "size": "72x72", "scale": "2x", "filename": "AppIcon-72@2x.png"},
    {"idiom": "ipad", "size": "76x76", "scale": "1x", "filename": "AppIcon-76.png"},
    {"idiom": "ipad", "size": "76x76", "scale": "2x", "filename": "AppIcon-76@2x.png"},
    {"idiom": "ipad", "size": "83.5x83.5", "scale": "2x", "filename": "AppIcon-83.5@2x.png"},
    {"idiom": "ios-marketing", "size": "1024x1024", "scale": "1x", "filename": "AppIcon-512@2x.png"},
]

WEB_TARGETS: Tuple[Tuple[Path, int], ...] = (
    (WEB_ICONS / "Icon-192.png", 192),
    (WEB_ICONS / "Icon-512.png", 512),
    (WEB_ICONS / "Icon-maskable-192.png", 192),
    (WEB_ICONS / "Icon-maskable-512.png", 512),
    (WEB_FAVICON, 16),
)


def _resize_and_save(master: Image.Image, size: int, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    resized = master.resize((size, size), Image.Resampling.LANCZOS)
    resized.save(destination, format="PNG")


def _generate_android(master: Image.Image) -> None:
    for bucket, size in ANDROID_SIZES:
        for filename in ("ic_launcher.png", "launcher_icon.png"):
            dest = ANDROID_RES / bucket / filename
            _resize_and_save(master, size, dest)


def _generate_ios(master: Image.Image) -> None:
    for filename, size_points, scale in IOS_FILES:
        size_px = int(round(size_points * scale))
        dest = IOS_APPICONSET / filename
        _resize_and_save(master, size_px, dest)

    contents = {
        "images": IOS_CONTENTS,
        "info": {"version": 1, "author": "xcode"},
    }
    (IOS_APPICONSET / "Contents.json").write_text(json.dumps(contents, indent=2) + "\n", encoding="utf-8")


def _generate_web(master: Image.Image) -> None:
    for path, size in WEB_TARGETS:
        _resize_and_save(master, size, path)


def main(argv: Iterable[str] | None = None) -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "input",
        nargs="?",
        default=str(ROOT / "assets" / "images" / "waves.png"),
        help="Path to the 1024x1024 PNG source image",
    )
    args = parser.parse_args(argv)

    source_path = Path(args.input).expanduser().resolve()
    if not source_path.exists():
        raise SystemExit(f"Source image not found: {source_path}")

    master = Image.open(source_path).convert("RGBA")
    if master.width != master.height:
        raise SystemExit("Source image must be square")
    if master.width != 1024:
        raise SystemExit("Source image must be 1024x1024 pixels")

    _generate_android(master)
    _generate_ios(master)
    _generate_web(master)

    print("Generated launcher icons from", source_path)


if __name__ == "__main__":
    main()
