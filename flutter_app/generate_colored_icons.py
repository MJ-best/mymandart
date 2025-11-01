#!/usr/bin/env python3
"""
앱 아이콘 색상 변경 스크립트
기존 app_icon.png를 읽어서 각 색상 테마별로 아이콘을 생성합니다.
"""

from PIL import Image, ImageDraw
import os

# 색상 정의
COLORS = {
    'green': (52, 199, 89),      # systemGreen
    'purple': (175, 82, 222),     # systemPurple
    'black': (0, 0, 0),           # black
    'white': (255, 255, 255),     # white
}

def create_colored_icon(base_image_path, output_path, color_name, rgb_color):
    """기존 아이콘의 색상을 변경합니다."""
    # 원본 이미지 로드
    img = Image.open(base_image_path).convert('RGBA')
    width, height = img.size

    # 새 이미지 생성
    colored_img = Image.new('RGBA', (width, height), (0, 0, 0, 0))

    # 픽셀 단위로 처리
    pixels = img.load()
    colored_pixels = colored_img.load()

    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]

            if a > 0:  # 투명하지 않은 픽셀만 처리
                # 밝기 계산 (0-1 범위)
                brightness = (r + g + b) / (3 * 255)

                # 흰색/검은색 테마는 특별 처리
                if color_name == 'white':
                    # 흰색 테마: 밝은 부분은 흰색, 어두운 부분은 연한 회색
                    if brightness > 0.5:
                        new_color = (255, 255, 255, a)
                    else:
                        new_color = (200, 200, 200, a)
                elif color_name == 'black':
                    # 검은색 테마: 어두운 부분은 검은색, 밝은 부분은 어두운 회색
                    if brightness < 0.5:
                        new_color = (0, 0, 0, a)
                    else:
                        new_color = (80, 80, 80, a)
                else:
                    # 일반 색상 테마: 원본 밝기를 유지하면서 색상만 변경
                    adjusted_r = int(rgb_color[0] * brightness)
                    adjusted_g = int(rgb_color[1] * brightness)
                    adjusted_b = int(rgb_color[2] * brightness)
                    new_color = (adjusted_r, adjusted_g, adjusted_b, a)

                colored_pixels[x, y] = new_color
            else:
                colored_pixels[x, y] = (0, 0, 0, 0)

    # 저장
    colored_img.save(output_path, 'PNG')
    print(f"Created: {output_path}")

def main():
    # 경로 설정
    base_icon_path = 'assets/icon/app_icon.png'
    output_dir = 'assets/icon'

    # 출력 디렉토리 확인
    os.makedirs(output_dir, exist_ok=True)

    # 각 색상별로 아이콘 생성
    for color_name, rgb_color in COLORS.items():
        output_path = os.path.join(output_dir, f'app_icon_{color_name}.png')
        create_colored_icon(base_icon_path, output_path, color_name, rgb_color)

    print("\n모든 색상 아이콘이 생성되었습니다!")
    print("생성된 파일:")
    for color_name in COLORS.keys():
        print(f"  - assets/icon/app_icon_{color_name}.png")

if __name__ == '__main__':
    main()
