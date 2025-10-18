#!/usr/bin/env python3
from PIL import Image, ImageDraw

def create_mandalart_icon(size=1024):
    """Create a simple Mandalart icon with 3x3 grid pattern"""
    # Create image with purple background
    img = Image.new('RGB', (size, size), color='#8B5CF6')
    draw = ImageDraw.Draw(img)

    # Grid parameters
    margin = size // 4
    grid_size = size - 2 * margin
    cell_size = grid_size // 3

    # Draw grid lines
    line_width = max(4, size // 256)
    line_color = (255, 255, 255, 156)  # White with 60% opacity

    # Horizontal lines
    for i in range(1, 3):
        y = margin + i * cell_size
        draw.line([(margin, y), (margin + grid_size, y)], fill=(255, 255, 255), width=line_width)

    # Vertical lines
    for i in range(1, 3):
        x = margin + i * cell_size
        draw.line([(x, margin), (x, margin + grid_size)], fill=(255, 255, 255), width=line_width)

    # Draw center highlight rectangle
    center_x = margin + cell_size
    center_y = margin + cell_size
    draw.rectangle(
        [(center_x, center_y), (center_x + cell_size, center_y + cell_size)],
        fill=(255, 255, 255, 51)  # 20% opacity white
    )

    # Draw center circle
    center = size // 2
    radius = cell_size // 3
    draw.ellipse(
        [(center - radius, center - radius), (center + radius, center + radius)],
        fill='white'
    )

    # Draw small dots in outer cells
    dot_radius = max(8, size // 85)
    dot_positions = [
        (margin + cell_size // 2, margin + cell_size // 2),  # Top-left
        (margin + cell_size + cell_size // 2, margin + cell_size // 2),  # Top-center
        (margin + 2 * cell_size + cell_size // 2, margin + cell_size // 2),  # Top-right
        (margin + cell_size // 2, margin + cell_size + cell_size // 2),  # Middle-left
        (margin + 2 * cell_size + cell_size // 2, margin + cell_size + cell_size // 2),  # Middle-right
        (margin + cell_size // 2, margin + 2 * cell_size + cell_size // 2),  # Bottom-left
        (margin + cell_size + cell_size // 2, margin + 2 * cell_size + cell_size // 2),  # Bottom-center
        (margin + 2 * cell_size + cell_size // 2, margin + 2 * cell_size + cell_size // 2),  # Bottom-right
    ]

    for x, y in dot_positions:
        draw.ellipse(
            [(x - dot_radius, y - dot_radius), (x + dot_radius, y + dot_radius)],
            fill=(255, 255, 255, 204)  # 80% opacity
        )

    return img

# Generate 1024x1024 icon
icon = create_mandalart_icon(1024)
icon.save('/Users/mj/Documents/mandarart-journey/flutter_app/assets/icon/app_icon.png')
print("Icon generated successfully!")

# Also generate a smaller version for the app banner (128x128)
banner = create_mandalart_icon(128)
banner.save('/Users/mj/Documents/mandarart-journey/flutter_app/assets/icon/app_banner.png')
print("Banner icon generated successfully!")
