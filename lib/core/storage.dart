import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Secure storage for tokens and sensitive data.
const secureStorage = FlutterSecureStorage();

/// Provider for [SharedPreferences] - must be initialized before app starts.
final prefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'prefsProvider must be overridden with a real SharedPreferences instance.',
  );
});

/// Keys used for persistent storage.
class StorageKeys {
  StorageKeys._();

  static const String onboardingComplete = 'onboarding_complete';
  static const String locale = 'locale';
  static const String sandboxMode = 'sandbox_mode';
  static const String developerMode = 'developer_mode';
  static const String notificationsEnabled = 'notifications_enabled';
}
