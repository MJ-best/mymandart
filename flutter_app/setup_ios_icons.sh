#!/bin/bash

# iOS 아이콘 설정 스크립트

for color in green purple black white; do
  COLOR_UPPER=$(echo $color | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')

  # 1024x1024 아이콘 복사
  cp assets/icon/app_icon_${color}.png ios/Runner/Assets.xcassets/AppIcon-${COLOR_UPPER}.appiconset/Icon-App-1024x1024@1x.png

  # Contents.json 생성
  cat > ios/Runner/Assets.xcassets/AppIcon-${COLOR_UPPER}.appiconset/Contents.json << 'EOF'
{
  "images" : [
    {
      "size" : "20x20",
      "idiom" : "iphone",
      "filename" : "Icon-App-20x20@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "20x20",
      "idiom" : "iphone",
      "filename" : "Icon-App-20x20@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "29x29",
      "idiom" : "iphone",
      "filename" : "Icon-App-29x29@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "29x29",
      "idiom" : "iphone",
      "filename" : "Icon-App-29x29@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "40x40",
      "idiom" : "iphone",
      "filename" : "Icon-App-40x40@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "40x40",
      "idiom" : "iphone",
      "filename" : "Icon-App-40x40@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "60x60",
      "idiom" : "iphone",
      "filename" : "Icon-App-60x60@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "60x60",
      "idiom" : "iphone",
      "filename" : "Icon-App-60x60@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "1024x1024",
      "idiom" : "ios-marketing",
      "filename" : "Icon-App-1024x1024@1x.png",
      "scale" : "1x"
    }
  ],
  "info" : {
    "version" : 1,
    "author" : "xcode"
  }
}
EOF

  # 필요한 크기로 리사이즈 (sips 사용 - macOS 내장 도구)
  sips -z 40 40 assets/icon/app_icon_${color}.png --out ios/Runner/Assets.xcassets/AppIcon-${COLOR_UPPER}.appiconset/Icon-App-20x20@2x.png > /dev/null 2>&1
  sips -z 60 60 assets/icon/app_icon_${color}.png --out ios/Runner/Assets.xcassets/AppIcon-${COLOR_UPPER}.appiconset/Icon-App-20x20@3x.png > /dev/null 2>&1
  sips -z 58 58 assets/icon/app_icon_${color}.png --out ios/Runner/Assets.xcassets/AppIcon-${COLOR_UPPER}.appiconset/Icon-App-29x29@2x.png > /dev/null 2>&1
  sips -z 87 87 assets/icon/app_icon_${color}.png --out ios/Runner/Assets.xcassets/AppIcon-${COLOR_UPPER}.appiconset/Icon-App-29x29@3x.png > /dev/null 2>&1
  sips -z 80 80 assets/icon/app_icon_${color}.png --out ios/Runner/Assets.xcassets/AppIcon-${COLOR_UPPER}.appiconset/Icon-App-40x40@2x.png > /dev/null 2>&1
  sips -z 120 120 assets/icon/app_icon_${color}.png --out ios/Runner/Assets.xcassets/AppIcon-${COLOR_UPPER}.appiconset/Icon-App-40x40@3x.png > /dev/null 2>&1
  sips -z 120 120 assets/icon/app_icon_${color}.png --out ios/Runner/Assets.xcassets/AppIcon-${COLOR_UPPER}.appiconset/Icon-App-60x60@2x.png > /dev/null 2>&1
  sips -z 180 180 assets/icon/app_icon_${color}.png --out ios/Runner/Assets.xcassets/AppIcon-${COLOR_UPPER}.appiconset/Icon-App-60x60@3x.png > /dev/null 2>&1

  echo "iOS 아이콘 설정 완료: AppIcon-${COLOR_UPPER}"
done

echo "\n모든 iOS 아이콘 설정이 완료되었습니다!"
