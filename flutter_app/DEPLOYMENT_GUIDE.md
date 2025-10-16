# 배포 가이드 - 나의 만다라트노트 (My Mandara Note)

## 1. Android Keystore 생성 및 서명 설정

### 1.1 Keystore 생성
Google Play에 앱을 배포하려면 release용 keystore가 필요합니다.

```bash
cd android
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

명령 실행 시 다음 정보를 입력하세요:
- 키스토어 비밀번호 (잘 기억해두세요!)
- 키 비밀번호 (잘 기억해두세요!)
- 이름, 조직, 위치 등의 정보

**중요**: 생성된 `upload-keystore.jks` 파일과 비밀번호는 안전하게 보관하세요!

### 1.2 key.properties 파일 설정
`android/key.properties.example` 파일을 참고하여 `android/key.properties` 파일을 생성하세요:

```properties
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=upload
storeFile=../upload-keystore.jks
```

**주의**: `key.properties`와 `*.jks` 파일은 절대 git에 커밋하지 마세요! (이미 .gitignore에 포함됨)

### 1.3 Release APK/AAB 빌드
```bash
# APK 빌드
flutter build apk --release

# AAB 빌드 (Google Play 업로드용)
flutter build appbundle --release
```cl

## 2. 커스텀 아이콘 설정

### 2.1 flutter_launcher_icons 사용 (권장)

#### pubspec.yaml에 추가:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
  # 적응형 아이콘 (Android)
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
```

#### 아이콘 이미지 준비:
- `assets/icon/app_icon.png` - 1024x1024 PNG (모든 플랫폼용)
- `assets/icon/app_icon_foreground.png` - 1024x1024 PNG (Android 적응형 아이콘 전경)

#### 아이콘 생성:
```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

### 2.2 수동 설정

#### Android 아이콘 위치:
- `android/app/src/main/res/mipmap-mdpi/ic_launcher.png` (48x48)
- `android/app/src/main/res/mipmap-hdpi/ic_launcher.png` (72x72)
- `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` (96x96)
- `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` (144x144)
- `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` (192x192)

#### iOS 아이콘 위치:
`ios/Runner/Assets.xcassets/AppIcon.appiconset/` 폴더에 다양한 크기의 PNG 파일들:
- Icon-App-20x20@1x.png (20x20)
- Icon-App-20x20@2x.png (40x40)
- Icon-App-20x20@3x.png (60x60)
- Icon-App-29x29@1x.png (29x29)
- Icon-App-29x29@2x.png (58x58)
- Icon-App-29x29@3x.png (87x87)
- Icon-App-40x40@1x.png (40x40)
- Icon-App-40x40@2x.png (80x80)
- Icon-App-40x40@3x.png (120x120)
- Icon-App-60x60@2x.png (120x120)
- Icon-App-60x60@3x.png (180x180)
- Icon-App-76x76@1x.png (76x76)
- Icon-App-76x76@2x.png (152x152)
- Icon-App-83.5x83.5@2x.png (167x167)
- Icon-App-1024x1024@1x.png (1024x1024)

## 3. 배포 전 체크리스트

- [ ] 앱 이름: "나의 만다라트노트" (Android), "나의 만다라트노트" (iOS)
- [ ] 패키지명: com.mandaranote.app
- [ ] 버전: 1.0.0+1
- [ ] Android keystore 생성 및 key.properties 설정 완료
- [ ] 커스텀 아이콘 설정 완료
- [ ] Release 빌드 테스트 완료
- [ ] 모든 플랫폼에서 정상 작동 확인

## 4. Google Play Console 업로드

1. [Google Play Console](https://play.google.com/console)에 접속
2. 새 앱 생성
3. AAB 파일 업로드: `build/app/outputs/bundle/release/app-release.aab`
4. 앱 정보, 스크린샷, 설명 등록
5. 심사 제출

## 5. App Store Connect 업로드 (iOS)

1. [App Store Connect](https://appstoreconnect.apple.com)에 접속
2. 새 앱 생성 (Bundle ID: com.mandaranote.app)
3. Xcode에서 Archive 생성
4. Archive를 App Store Connect에 업로드
5. 앱 정보, 스크린샷, 설명 등록
6. 심사 제출

## 참고 자료

- [Flutter 공식 배포 가이드](https://docs.flutter.dev/deployment)
- [Android 앱 서명](https://developer.android.com/studio/publish/app-signing)
- [iOS 앱 배포](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases)
