import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 테마 모드 열거형
enum ThemeMode {
  /// 시스템 설정 따름
  system,

  /// 항상 밝은 테마
  light,

  /// 항상 어두운 테마
  dark,
}

/// 테마 상태 모델
class ThemeState {
  final ThemeMode mode;
  final Brightness systemBrightness;

  const ThemeState({
    required this.mode,
    required this.systemBrightness,
  });

  /// 실제 적용될 brightness 계산
  Brightness get effectiveBrightness {
    switch (mode) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return systemBrightness;
    }
  }

  ThemeState copyWith({
    ThemeMode? mode,
    Brightness? systemBrightness,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      systemBrightness: systemBrightness ?? this.systemBrightness,
    );
  }
}

/// 테마 상태 관리 Notifier
class ThemeNotifier extends StateNotifier<ThemeState> {
  static const String _themeModeKey = 'theme_mode';

  ThemeNotifier()
      : super(const ThemeState(
          mode: ThemeMode.system,
          systemBrightness: Brightness.light,
        )) {
    _loadThemeMode();
  }

  /// SharedPreferences에서 저장된 테마 모드 불러오기
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeString = prefs.getString(_themeModeKey);
      if (modeString != null) {
        final mode = ThemeMode.values.firstWhere(
          (e) => e.name == modeString,
          orElse: () => ThemeMode.system,
        );
        state = state.copyWith(mode: mode);
      }
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

  /// 시스템 brightness 업데이트
  void updateSystemBrightness(Brightness brightness) {
    if (state.systemBrightness != brightness) {
      state = state.copyWith(systemBrightness: brightness);
    }
  }

  /// 다음 테마 모드로 순환 전환 (light → dark → system → light)
  Future<void> toggleTheme() async {
    final nextMode = switch (state.mode) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
      ThemeMode.system => ThemeMode.light,
    };
    await setThemeMode(nextMode);
  }
}

/// 테마 Provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});
