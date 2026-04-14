import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multando_sdk/multando_sdk.dart';

import 'storage.dart';

/// Provides a singleton [MultandoClient] for the entire app.
///
/// The client is initialized once with the production config. Switch to
/// sandbox mode via the developer settings by changing [_baseUrl].
class ApiClientNotifier extends Notifier<MultandoClient> {
  static const _prodUrl = 'https://api.multando.com';
  static const _sandboxUrl = 'https://sandbox-api.multando.com';
  // Use --dart-define=API_URL=http://10.0.2.2:8000 for local Docker testing
  // (10.0.2.2 is the Android emulator's alias for host localhost)
  static const _localUrl = String.fromEnvironment('API_URL');
  static const _apiKey = 'multando-flutter-mobile-v1';

  // Default to sandbox — preserves dev/test data separation.
  // Users can toggle to production via developer settings.
  static const _defaultSandbox = true;

  @override
  MultandoClient build() {
    final client = MultandoClient();
    // Initialization happens asynchronously; see initializeClient()
    return client;
  }

  Future<void> initializeClient({bool? sandbox}) async {
    final prefs = ref.read(prefsProvider);
    final isSandbox = sandbox ?? (prefs.getBool('sandbox_mode') ?? _defaultSandbox);
    final baseUrl = _localUrl.isNotEmpty
        ? _localUrl
        : isSandbox
            ? _sandboxUrl
            : _prodUrl;

    await state.initialize(
      MultandoConfig(
        baseUrl: baseUrl,
        apiKey: _apiKey,
        enableOfflineQueue: true,
        logLevel: MultandoLogLevel.debug,
      ),
    );
  }

  Future<void> toggleSandbox(bool enabled) async {
    final prefs = ref.read(prefsProvider);
    await prefs.setBool('sandbox_mode', enabled);
    // Re-initialize with new base URL
    await state.dispose();
    final newClient = MultandoClient();
    state = newClient;
    await initializeClient(sandbox: enabled);
  }
}

final apiClientProvider =
    NotifierProvider<ApiClientNotifier, MultandoClient>(ApiClientNotifier.new);
