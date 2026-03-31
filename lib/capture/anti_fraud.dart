/// Anti-fraud module.
///
/// This module wraps the Multando SDK's AntiFraud checks for app-level use.
/// See `multando_sdk/lib/src/capture/anti_fraud.dart` for the full
/// implementation.
library;

/// Placeholder that documents the app's usage of the SDK anti-fraud system.
/// The actual implementation lives in the multando_sdk package.
class AppAntiFraud {
  AppAntiFraud._();

  /// Run client-side fraud checks using the SDK.
  /// Returns true if all checks pass.
  static Future<bool> validateCapture({
    required String captureMethod,
    required String timestamp,
    required double latitude,
    required double longitude,
    required double accuracy,
    required bool motionVerified,
    required String imageHash,
  }) async {
    // Delegates to SDK: AntiFraud.runChecks(...)
    // Checks: capture method, timestamp freshness, GPS freshness,
    //         motion detection, duplicate hash, EXIF consistency
    throw UnimplementedError(
      'Use MultandoSDK AntiFraud directly in production builds.',
    );
  }
}
