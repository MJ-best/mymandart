import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mandarart_journey/core/providers/app_providers.dart';
import 'package:mandarart_journey/features/auth/domain/app_user.dart';

abstract class AuthRepository {
  AppUser? get currentUser;
  Stream<AppUser?> authStateChanges();
  Future<void> signInWithGoogle();
  Future<void> signOut();
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return SupabaseAuthRepository(client: ref.watch(supabaseClientProvider));
});

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository({required SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  @override
  AppUser? get currentUser {
    final user = _client?.auth.currentUser;
    if (user == null) {
      return null;
    }
    return _mapUser(user);
  }

  @override
  Stream<AppUser?> authStateChanges() {
    if (_client == null) {
      return const Stream<AppUser?>.empty();
    }
    return _client.auth.onAuthStateChange.map((event) {
      final session = event.session;
      final user = session?.user ?? _client.auth.currentUser;
      return user == null ? null : _mapUser(user);
    });
  }

  @override
  Future<void> signInWithGoogle() async {
    if (_client == null) {
      throw StateError('Supabase is not configured.');
    }

    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? null : 'io.supabase.flutter://login-callback/',
    );
  }

  @override
  Future<void> signOut() async {
    if (_client == null) {
      return;
    }
    await _client.auth.signOut();
  }

  AppUser _mapUser(User user) {
    final metadata = user.userMetadata ?? const {};
    return AppUser(
      id: user.id,
      email: user.email,
      displayName:
          metadata['full_name'] as String? ?? metadata['name'] as String?,
      avatarUrl: metadata['avatar_url'] as String?,
    );
  }
}
