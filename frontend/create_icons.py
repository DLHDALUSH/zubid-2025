#!/usr/bin/env python3
"""Generate PWA icons for ZUBID app"""

import os
from PIL import Image, ImageDraw, ImageFont

# Icon sizes needed for PWA
SIZES = [72, 96, 128, 144, 152, 192, 384, 512]

# Colors
PRIMARY_COLOR = (255, 102, 0)  # #ff6600
SECONDARY_COLOR = (255, 133, 51)  # #ff8533
WHITE = (255, 255, 255)

def create_icon(size):
    """Create a single icon at the specified size"""
    # Create image with transparent background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Draw rounded rectangle background
    radius = int(size * 0.2)
    
    # Create gradient-like effect by drawing multiple rectangles
    for i in range(size):
        # Interpolate color
        ratio = i / size
        r = int(PRIMARY_COLOR[0] + (SECONDARY_COLOR[0] - PRIMARY_COLOR[0]) * ratio)
        g = int(PRIMARY_COLOR[1] + (SECONDARY_COLOR[1] - PRIMARY_COLOR[1]) * ratio)
        b = int(PRIMARY_COLOR[2] + (SECONDARY_COLOR[2] - PRIMARY_COLOR[2]) * ratio)
        color = (r, g, b, 255)
        
        # Draw horizontal line
        draw.line([(radius, i), (size - radius, i)], fill=color)
    
    # Draw rounded corners (simplified - just fill the rectangle)
    draw.rounded_rectangle(
        [(0, 0), (size - 1, size - 1)],
        radius=radius,
        fill=PRIMARY_COLOR
    )
    
    # Draw "Z" letter
    font_size = int(size * 0.55)
    try:
        # Try to use Arial Bold
        font = ImageFont.truetype("arialbd.ttf", font_size)
    except:
        try:
            font = ImageFont.truetype("Arial Bold.ttf", font_size)
        except:
            try:
                font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", font_size)
            except:
                # Fallback to default font
                font = ImageFont.load_default()
    
    # Get text bounding box
    text = "Z"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    # Center the text
    x = (size - text_width) // 2
    y = (size - text_height) // 2 - int(size * 0.05)
    
    draw.text((x, y), text, font=font, fill=WHITE)
    
    # Draw small circle (gavel hint)
    circle_radius = int(size * 0.08)
    circle_x = int(size * 0.75)
    circle_y = int(size * 0.25)
    draw.ellipse(
        [(circle_x - circle_radius, circle_y - circle_radius),
         (circle_x + circle_radius, circle_y + circle_radius)],
        fill=(255, 255, 255, 80)
    )
    
    return img

def main():
    # Create icons directory if it doesn't exist
    icons_dir = os.path.join(os.path.dirname(__file__), 'icons')
    os.makedirs(icons_dir, exist_ok=True)
    
    print("Generating ZUBID PWA icons...")
    
    for size in SIZES:
        icon = create_icon(size)
        filename = os.path.join(icons_dir, f'icon-{size}x{size}.png')
        icon.save(filename, 'PNG')
        print(f"  Created: icon-{size}x{size}.png")
    
    print(f"\nDone! {len(SIZES)} icons created in {icons_dir}")

if __name__ == '__main__':
    main()

