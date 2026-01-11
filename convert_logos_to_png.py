#!/usr/bin/env python3
"""
Convert ZUBID SVG logos to PNG in multiple sizes
Uses svglib + reportlab for cross-platform SVG rendering
"""

import subprocess
from pathlib import Path

# Define SVG files and their output sizes
SVG_FILES = {
    'zubid_enhanced_logo.svg': 'enhanced',
    'zubid_animated_logo.svg': 'animated',
    'zubid_dark_mode_logo.svg': 'dark_mode',
    'zubid_vibrant_logo.svg': 'vibrant',
}

# PNG sizes: (width, height, name)
PNG_SIZES = [
    (64, 16, 'favicon_16'),
    (128, 32, 'favicon_32'),
    (192, 48, 'favicon_48'),
    (256, 64, 'favicon_64'),
    (512, 128, 'icon_128'),
    (1024, 256, 'icon_256'),
    (2048, 512, 'icon_512'),
    (4096, 1024, 'social_1024'),
]

def install_dependencies():
    """Install required packages"""
    try:
        from svglib.svglib import svg2rlg
        from reportlab.graphics import renderPM
    except ImportError:
        print("Installing required packages...")
        subprocess.check_call(['pip', 'install', 'svglib', 'reportlab', 'pillow'])

def convert_svg_to_png(svg_path, output_dir, sizes):
    """Convert SVG to PNG in multiple sizes using svglib"""
    svg_path = Path(svg_path)
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    if not svg_path.exists():
        print(f"❌ SVG file not found: {svg_path}")
        return False

    try:
        from svglib.svglib import svg2rlg
        from reportlab.graphics import renderPM
        from PIL import Image

        # Convert SVG to RLG drawing
        drawing = svg2rlg(str(svg_path))
        if not drawing:
            print(f"❌ Failed to parse SVG: {svg_path}")
            return False

        success_count = 0

        for width, height, size_name in sizes:
            output_path = output_dir / f"{svg_path.stem}_{size_name}.png"

            try:
                # Scale drawing
                scale_x = width / drawing.width
                scale_y = height / drawing.height
                scale = min(scale_x, scale_y)

                drawing.width = width
                drawing.height = height
                drawing.scale(scale, scale)

                # Render to PNG
                renderPM.drawToFile(drawing, str(output_path), fmt='PNG')
                print(f"✅ Created: {output_path.name} ({width}x{height}px)")
                success_count += 1

            except Exception as e:
                print(f"⚠️  Failed to create {size_name}: {e}")

        return success_count > 0

    except Exception as e:
        print(f"❌ Error converting {svg_path}: {e}")
        return False

def main():
    """Main conversion process"""
    print("🎨 ZUBID Logo PNG Converter")
    print("=" * 60)

    install_dependencies()

    workspace_dir = Path(__file__).parent
    output_base = workspace_dir / 'logo_exports'

    for svg_file, variant_name in SVG_FILES.items():
        svg_path = workspace_dir / svg_file
        output_dir = output_base / variant_name

        print(f"\n📦 Converting {variant_name}...")
        if convert_svg_to_png(svg_path, output_dir, PNG_SIZES):
            print(f"✨ {variant_name} conversion complete!")
        else:
            print(f"⚠️  {variant_name} conversion had issues")

    print("\n" + "=" * 60)
    print(f"📁 All exports saved to: {output_base}")
    print("✅ Conversion process complete!")

if __name__ == '__main__':
    main()

