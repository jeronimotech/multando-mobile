/// Evidence signing module.
///
/// This module wraps the Multando SDK's EvidenceSigner for app-level use.
/// See `multando_sdk/lib/src/capture/evidence_signer.dart` for the full
/// implementation.
library;

// Re-export from SDK for app usage.
// In production, import directly from the SDK:
// export 'package:multando_sdk/src/capture/evidence_signer.dart';

/// Placeholder that documents the app's usage of the SDK signer.
/// The actual implementation lives in the multando_sdk package.
class AppEvidenceSigner {
  AppEvidenceSigner._();

  /// Signs evidence using the SDK's EvidenceSigner.
  /// Returns the HMAC-SHA256 signature string.
  static Future<String> signCapture({
    required String imageHash,
    required String timestamp,
    required double latitude,
    required double longitude,
    required String deviceId,
  }) async {
    // Delegates to SDK: EvidenceSigner.signEvidence(...)
    // The SDK handles device key derivation and HMAC computation.
    throw UnimplementedError(
      'Use MultandoSDK EvidenceSigner directly in production builds.',
    );
  }
}
