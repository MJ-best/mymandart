#!/usr/bin/env python3
from PIL import Image, ImageDraw

def create_mandarat_icon(size=1024):
    """Create Mandarat icon: white background with centered purple rounded square"""
    # Create image with white background
    img = Image.new('RGB', (size, size), color=(255, 255, 255))
    draw = ImageDraw.Draw(img)
    
    # Purple color (from design)
    purple = (139, 92, 246)  # #8B5CF6
    
    # Centered purple rounded rectangle with larger margin
    margin = size // 4.5  # larger margin to make purple square smaller
    radius = size // 12   # corner radius
    
    # Draw centered purple rounded rectangle
    x0, y0 = margin, margin
    x1, y1 = size - margin, size - margin
    
    draw.rounded_rectangle(
        [(x0, y0), (x1, y1)],
        radius=radius,
        fill=purple
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
