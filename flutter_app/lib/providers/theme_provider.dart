import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dynamic_icon_plus/flutter_dynamic_icon_plus.dart';

/// 테마 모드 열거형
enum ThemeMode {
  /// 항상 밝은 테마
  light,

  /// 항상 어두운 테마
  dark,
}

/// 색상 테마 열거형
enum ColorTheme {
  /// 녹색 테마
  green,

  /// 보라색 테마
  purple,

  /// 검은색 테마
  black,

  /// 흰색 테마
  white,
}

/// 테마 상태 모델
class ThemeState {
  final ThemeMode mode;
  final ColorTheme colorTheme;

  const ThemeState({
    required this.mode,
    this.colorTheme = ColorTheme.green,
  });

  /// 실제 적용될 brightness 계산
  Brightness get effectiveBrightness {
    switch (mode) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
    }
  }

  /// 테마 색상 가져오기
  Color get primaryColor {
    switch (colorTheme) {
      case ColorTheme.green:
        return CupertinoColors.systemGreen;
      case ColorTheme.purple:
        return CupertinoColors.systemPurple;
      case ColorTheme.black:
        return CupertinoColors.black;
      case ColorTheme.white:
        return CupertinoColors.white;
    }
  }

  ThemeState copyWith({
    ThemeMode? mode,
    ColorTheme? colorTheme,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      colorTheme: colorTheme ?? this.colorTheme,
    );
  }
}

/// 테마 상태 관리 Notifier
class ThemeNotifier extends StateNotifier<ThemeState> {
  static const String _themeModeKey = 'theme_mode';
  static const String _colorThemeKey = 'color_theme';

  ThemeNotifier()
      : super(const ThemeState(
          mode: ThemeMode.light,
          colorTheme: ColorTheme.green,
        )) {
    _loadTheme();
  }

  /// SharedPreferences에서 저장된 테마 설정 불러오기
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 테마 모드 불러오기
      final modeString = prefs.getString(_themeModeKey);
      ThemeMode mode = ThemeMode.light;
      if (modeString != null) {
        mode = ThemeMode.values.firstWhere(
          (e) => e.name == modeString,
          orElse: () => ThemeMode.light,
        );
      }

      // 색상 테마 불러오기
      final colorThemeString = prefs.getString(_colorThemeKey);
      ColorTheme colorTheme = ColorTheme.green;
      if (colorThemeString != null) {
        colorTheme = ColorTheme.values.firstWhere(
          (e) => e.name == colorThemeString,
          orElse: () => ColorTheme.green,
        );
      }

      state = state.copyWith(mode: mode, colorTheme: colorTheme);
    } catch (e) {
      // 로드 실패 시 기본값 유지
    }
  }

  /// 테마 모드 변경
  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(mode: mode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, mode.name);
    } catch (e) {
      // 저장 실패 시 무시 (상태는 이미 변경됨)
    }
  }

  /// 색상 테마 변경
  Future<void> setColorTheme(ColorTheme colorTheme) async {
    state = state.copyWith(colorTheme: colorTheme);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_colorThemeKey, colorTheme.name);

      // 앱 아이콘 변경 (iOS만 지원, Android는 flutter_dynamic_icon이 자동 처리)
      await _changeAppIcon(colorTheme);
    } catch (e) {
      // 저장 실패 시 무시 (상태는 이미 변경됨)
      if (kDebugMode) {
        print('Error saving color theme: $e');
      }
    }
  }

  /// 앱 아이콘 변경 (모바일 전용)
  Future<void> _changeAppIcon(ColorTheme colorTheme) async {
    // 웹이나 데스크톱에서는 동작하지 않음
    if (kIsWeb) return;

    try {
      // iOS: CFBundleAlternateIcons 사용
      // Android: flutter_dynamic_icon이 자동으로 AndroidManifest.xml 처리
      String iconName;
      switch (colorTheme) {
        case ColorTheme.green:
          iconName = 'AppIcon-Green';
          break;
        case ColorTheme.purple:
          iconName = 'AppIcon-Purple';
          break;
        case ColorTheme.black:
          iconName = 'AppIcon-Black';
          break;
        case ColorTheme.white:
          iconName = 'AppIcon-White';
          break;
      }

      await FlutterDynamicIconPlus.setAlternateIconName(iconName: iconName);
      if (kDebugMode) {
        print('App icon changed to: $iconName');
      }
    } catch (e) {
      // 아이콘 변경 실패는 무시 (앱 내부 색상은 이미 변경됨)
      if (kDebugMode) {
        print('Failed to change app icon: $e');
      }
    }
  }

  /// light/dark 토글 (light ↔ dark)
  Future<void> toggleTheme() async {
    final nextMode = state.mode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    await setThemeMode(nextMode);
  }
}

/// 테마 Provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});
