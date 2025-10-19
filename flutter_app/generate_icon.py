#!/usr/bin/env python3
from PIL import Image, ImageDraw

def create_mandarat_icon(size=1024):
    """Create Mandarat icon: purple rounded square with white inner square"""
    # Create image with transparent background (for adaptive icon)
    img = Image.new('RGBA', (size, size), color=(0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Purple color (from design)
    purple = (139, 92, 246, 255)  # #8B5CF6
    white = (255, 255, 255, 255)
    
    # Rounded rectangle parameters - larger margin to avoid cutoff
    margin = size // 5  # larger margin for safe area
    radius = size // 10   # corner radius
    
    # Draw rounded rectangle (outer purple)
    x0, y0 = margin, margin
    x1, y1 = size - margin, size - margin
    
    draw.rounded_rectangle(
        [(x0, y0), (x1, y1)],
        radius=radius,
        fill=purple
    )
    
    # Draw inner white square
    inner_margin = size // 2.8  # adjusted for better proportion
    inner_x0 = inner_margin
    inner_y0 = inner_margin
    inner_x1 = size - inner_margin
    inner_y1 = size - inner_margin
    
    inner_radius = size // 25
    draw.rounded_rectangle(
        [(inner_x0, inner_y0), (inner_x1, inner_y1)],
        radius=inner_radius,
        fill=white
    )
    
    return img

# Generate 1024x1024 icon
icon = create_mandarat_icon(1024)
icon.save('/Users/mj/Documents/mandarart-journey/flutter_app/assets/icon/app_icon.png')
print("Icon generated successfully: app_icon.png")

# Generate smaller versions for different uses
for size, name in [(512, 'app_icon_512'), (256, 'app_icon_256'), (128, 'app_banner')]:
    smaller = create_mandarat_icon(size)
    smaller.save(f'/Users/mj/Documents/mandarart-journey/flutter_app/assets/icon/{name}.png')
    print(f"Generated: {name}.png")
