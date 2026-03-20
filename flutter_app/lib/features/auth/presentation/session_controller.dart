import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mandarart_journey/core/providers/app_providers.dart';
import 'package:mandarart_journey/features/auth/data/auth_repository.dart';
import 'package:mandarart_journey/features/auth/domain/app_user.dart';

class SessionState {
  const SessionState({
    required this.isReady,
    required this.themeMode,
    required this.user,
    required this.isSupabaseConfigured,
    required this.isSigningIn,
    required this.isDemoMode,
    this.errorMessage,
  });

  const SessionState.initial()
      : isReady = false,
        themeMode = ThemeMode.system,
        user = null,
        isSupabaseConfigured = false,
        isSigningIn = false,
        isDemoMode = false,
        errorMessage = null;

  final bool isReady;
  final ThemeMode themeMode;
  final AppUser? user;
  final bool isSupabaseConfigured;
  final bool isSigningIn;
  final bool isDemoMode;
  final String? errorMessage;

  bool get canAccessApp => user != null || isDemoMode;

  SessionState copyWith({
    bool? isReady,
    ThemeMode? themeMode,
    Object? user = _sentinel,
    bool? isSupabaseConfigured,
    bool? isSigningIn,
    bool? isDemoMode,
    Object? errorMessage = _sentinel,
  }) {
    return SessionState(
      isReady: isReady ?? this.isReady,
      themeMode: themeMode ?? this.themeMode,
      user: user == _sentinel ? this.user : user as AppUser?,
      isSupabaseConfigured: isSupabaseConfigured ?? this.isSupabaseConfigured,
      isSigningIn: isSigningIn ?? this.isSigningIn,
      isDemoMode: isDemoMode ?? this.isDemoMode,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

const _sentinel = Object();

final sessionControllerProvider =
    NotifierProvider<SessionController, SessionState>(SessionController.new);

class SessionController extends Notifier<SessionState> {
  static const _themeModeKey = 'platform.theme_mode';
  static const _demoModeKey = 'platform.demo_mode';

  StreamSubscription<AppUser?>? _authSubscription;

  @override
  SessionState build() {
    ref.onDispose(() => _authSubscription?.cancel());
    Future<void>(() async => _bootstrap());
    return const SessionState.initial();
  }

  Future<void> _bootstrap() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final authRepository = ref.read(authRepositoryProvider);
    final isSupabaseConfigured = ref.read(supabaseClientProvider) != null;
    final themeMode = switch (prefs.getString(_themeModeKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    final demoMode = prefs.getBool(_demoModeKey) ?? !isSupabaseConfigured;

    state = state.copyWith(
      themeMode: themeMode,
      user: authRepository.currentUser,
      isDemoMode: authRepository.currentUser == null ? demoMode : false,
      isSupabaseConfigured: isSupabaseConfigured,
    );

    _authSubscription = authRepository.authStateChanges().listen((user) {
      unawaited(_handleAuthChange(user));
    });

    state = state.copyWith(isReady: true);
  }

  Future<void> _handleAuthChange(AppUser? user) async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (user != null) {
      await prefs.setBool(_demoModeKey, false);
    }
    state = state.copyWith(
      user: user,
      isDemoMode: user == null ? state.isDemoMode : false,
      errorMessage: null,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    };
    await prefs.setString(_themeModeKey, value);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> continueInDemoMode() async {
    await ref.read(sharedPreferencesProvider).setBool(_demoModeKey, true);
    state = state.copyWith(isDemoMode: true, errorMessage: null);
  }

  Future<void> signInWithGoogle() async {
    if (!state.isSupabaseConfigured) {
      state = state.copyWith(
        errorMessage: 'Supabase 설정이 없어 Google 로그인을 시작할 수 없습니다.',
      );
      return;
    }

    state = state.copyWith(isSigningIn: true, errorMessage: null);
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
    } catch (error) {
      state = state.copyWith(errorMessage: error.toString());
    } finally {
      state = state.copyWith(isSigningIn: false);
    }
  }

  Future<void> signOut() async {
    const shouldFallbackToLocal = true;
    await ref
        .read(sharedPreferencesProvider)
        .setBool(_demoModeKey, shouldFallbackToLocal);
    await ref.read(authRepositoryProvider).signOut();
    state = state.copyWith(
      user: null,
      isDemoMode: shouldFallbackToLocal,
      errorMessage: null,
    );
  }
}
