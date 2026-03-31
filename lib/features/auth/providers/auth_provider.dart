import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multando_sdk/multando_sdk.dart';

import '../../../core/api_client.dart';
import '../../../core/storage.dart';

/// Authentication state.
enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.isLoading = false,
    this.error,
  });

  final AuthStatus status;
  final UserProfile? user;
  final bool isLoading;
  final String? error;

  AuthState copyWith({
    AuthStatus? status,
    UserProfile? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _checkAuthStatus();
    return const AuthState();
  }

  Future<void> _checkAuthStatus() async {
    final client = ref.read(apiClientProvider);
    if (!client.isInitialized) return;

    if (client.isAuthenticated && client.currentUser != null) {
      state = AuthState(
        status: AuthStatus.authenticated,
        user: client.currentUser,
      );
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }

    // Listen for session expiry from the SDK.
    client.authStateStream.listen((authenticated) {
      if (!authenticated) {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    });
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final client = ref.read(apiClientProvider);
      await client.auth.login(LoginRequest(email: email, password: password));
      final profile = await client.auth.getProfile();
      state = AuthState(
        status: AuthStatus.authenticated,
        user: profile,
      );
    } on MultandoError catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> register(String fullName, String email, String password, {String? phone}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final client = ref.read(apiClientProvider);
      await client.auth.register(RegisterRequest(
        fullName: fullName,
        email: email,
        password: password,
        phoneNumber: phone,
      ));
      final profile = await client.auth.getProfile();
      state = AuthState(
        status: AuthStatus.authenticated,
        user: profile,
      );
    } on MultandoError catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    final client = ref.read(apiClientProvider);
    await client.auth.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> refreshProfile() async {
    try {
      final client = ref.read(apiClientProvider);
      final profile = await client.auth.getProfile();
      state = state.copyWith(user: profile);
    } catch (_) {
      // Non-fatal
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

/// Whether onboarding has been completed.
/// Uses StateProvider so it can be updated at runtime after the user finishes onboarding.
final onboardingCompleteProvider = StateProvider<bool>((ref) {
  final prefs = ref.watch(prefsProvider);
  return prefs.getBool(StorageKeys.onboardingComplete) ?? false;
});
