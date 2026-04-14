import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multando_sdk/multando_sdk.dart';

import '../../../../core/colors.dart';
import '../../providers/reports_provider.dart';

/// Step 1: Capture evidence photo and select infraction type.
class CaptureStep extends ConsumerStatefulWidget {
  const CaptureStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  ConsumerState<CaptureStep> createState() => _CaptureStepState();
}

class _CaptureStepState extends ConsumerState<CaptureStep> {
  final ImagePicker _picker = ImagePicker();

  bool _captured = false;
  bool _signing = false;
  bool _signed = false;
  File? _imageFile;
  Uint8List? _imageBytes;
  String? _timestamp;
  double? _latitude;
  double? _longitude;
  SecureEvidence? _evidence;

  // -----------------------------------------------------------------------
  // Image picking — try camera first, fallback to gallery for emulators
  // -----------------------------------------------------------------------

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 90,
      );
      if (picked == null) return;

      final file = File(picked.path);
      final bytes = await file.readAsBytes();

      setState(() {
        _imageFile = file;
        _imageBytes = bytes;
        _captured = true;
        _signed = false;
        _evidence = null;
      });

      // Fetch GPS + sign automatically
      await _signImage(bytes, picked.path, source == ImageSource.camera ? 'camera' : 'gallery');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Capture failed: $e'),
          backgroundColor: MultandoColors.danger,
        ),
      );
    }
  }

  Future<void> _captureWithCameraFallback() async {
    try {
      await _pickImage(ImageSource.camera);
    } catch (_) {
      // Camera not available (e.g. emulator) — fall back to gallery
      await _pickImage(ImageSource.gallery);
    }
  }

  // -----------------------------------------------------------------------
  // GPS + signing
  // -----------------------------------------------------------------------

  Future<void> _signImage(Uint8List bytes, String path, String method) async {
    setState(() => _signing = true);

    try {
      // Get GPS position
      Position position;
      try {
        final perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.denied ||
            perm == LocationPermission.deniedForever) {
          await Geolocator.requestPermission();
        }
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      } catch (_) {
        // Fallback for emulator / no GPS
        position = Position(
          latitude: 0.0,
          longitude: 0.0,
          timestamp: DateTime.now(),
          accuracy: 0.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );
      }

      final now = DateTime.now().toUtc();
      final timestamp = now.toIso8601String();

      // Sign using SDK EvidenceSigner
      final evidence = await EvidenceSigner.signEvidence(
        imageBytes: bytes,
        timestamp: timestamp,
        latitude: position.latitude,
        longitude: position.longitude,
        altitude: position.altitude,
        accuracy: position.accuracy,
        motionVerified: false, // Not using motion detection in this step
        imageUri: path,
      );

      if (!mounted) return;

      setState(() {
        _timestamp = timestamp;
        _latitude = position.latitude;
        _longitude = position.longitude;
        _evidence = evidence;
        _signed = true;
        _signing = false;
      });

      ref.read(newReportProvider.notifier).setCapturedImage(path);
      ref.read(newReportProvider.notifier).setLocation(
        position.latitude,
        position.longitude,
        null,
      );

      // Store signed evidence metadata for submission
      ref.read(newReportProvider.notifier).setEvidence(
        imageBytes: bytes,
        imageHash: evidence.imageHash,
        signature: evidence.signature,
        timestamp: timestamp,
        deviceId: evidence.deviceId,
        captureMethod: evidence.captureMethod,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _signing = false);
      debugPrint('[CaptureStep] Signing failed: $e');
    }
  }

  // -----------------------------------------------------------------------
  // Helpers
  // -----------------------------------------------------------------------

  String _formatTimestamp(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)} '
        '${_pad(dt.hour)}:${_pad(dt.minute)}:${_pad(dt.second)} UTC';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  String _formatGps(double lat, double lon) {
    final latDir = lat >= 0 ? 'N' : 'S';
    final lonDir = lon >= 0 ? 'E' : 'W';
    return '${lat.abs().toStringAsFixed(4)}$latDir '
        '${lon.abs().toStringAsFixed(4)}$lonDir';
  }

  // -----------------------------------------------------------------------
  // Build
  // -----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final infractions = ref.watch(infractionsProvider);
    final newReport = ref.watch(newReportProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step header
          const Text(
            'Step 1: Capture Evidence',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: MultandoColors.surface900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Take a photo of the infraction and select the infraction type.',
            style: TextStyle(color: MultandoColors.surface500, fontSize: 14),
          ),
          const SizedBox(height: 24),

          // Camera capture area
          if (!_captured) _buildCapturePrompt() else _buildImagePreview(),

          const SizedBox(height: 32),

          // Infraction selector
          const Text(
            'Select Infraction Type',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: MultandoColors.surface900,
            ),
          ),
          const SizedBox(height: 12),

          infractions.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(color: MultandoColors.brandRed),
              ),
            ),
            error: (err, _) => Text('Error: $err'),
            data: (items) => _buildInfractionGrid(items, newReport),
          ),

          const SizedBox(height: 32),

          // Next button
          ElevatedButton(
            onPressed: (_captured && _signed && newReport.selectedInfractionId != null)
                ? widget.onNext
                : null,
            child: const Text('Next: Vehicle Details'),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Before capture — prompt with camera/gallery buttons
  // -----------------------------------------------------------------------

  Widget _buildCapturePrompt() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: MultandoColors.surface100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MultandoColors.surface300,
          width: 2,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.camera_alt,
            size: 56,
            color: MultandoColors.surface400,
          ),
          const SizedBox(height: 12),
          const Text(
            'Tap to capture evidence',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: MultandoColors.surface500,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'GPS, timestamp, and watermark will be applied',
            style: TextStyle(
              fontSize: 12,
              color: MultandoColors.surface400,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt, size: 18),
                label: const Text('Camera'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MultandoColors.brandRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library, size: 18),
                label: const Text('Gallery'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: MultandoColors.surface700,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: MultandoColors.surface300),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------------
  // After capture — image preview with watermark overlay
  // -----------------------------------------------------------------------

  Widget _buildImagePreview() {
    return Column(
      children: [
        // Image card with watermark overlay
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _signed ? MultandoColors.success : MultandoColors.surface300,
              width: 2,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
          ),
          child: Stack(
            children: [
              // Actual image
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _imageFile != null
                    ? Image.file(
                        _imageFile!,
                        width: double.infinity,
                        height: 260,
                        fit: BoxFit.cover,
                      )
                    : const SizedBox(height: 260),
              ),

              // Watermark overlay
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withAlpha(100),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withAlpha(140),
                        ],
                        stops: const [0.0, 0.25, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              // Top-left: MULTANDO branding
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: MultandoColors.brandRed.withAlpha(180),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'MULTANDO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Top-right: Signed/Unsigned badge
              Positioned(
                top: 12,
                right: 12,
                child: _buildSignBadge(),
              ),

              // Bottom-left: Timestamp
              if (_timestamp != null)
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Text(
                    _formatTimestamp(_timestamp!),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(blurRadius: 4, color: Colors.black87),
                      ],
                    ),
                  ),
                ),

              // Bottom-right: GPS coordinates
              if (_latitude != null && _longitude != null)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Text(
                    _formatGps(_latitude!, _longitude!),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(blurRadius: 4, color: Colors.black87),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Retake button
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _captured = false;
                    _signed = false;
                    _signing = false;
                    _imageFile = null;
                    _imageBytes = null;
                    _timestamp = null;
                    _latitude = null;
                    _longitude = null;
                    _evidence = null;
                  });
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retake'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: MultandoColors.surface600,
                  side: const BorderSide(color: MultandoColors.surface300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSignBadge() {
    if (_signing) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.withAlpha(180),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 4),
            Text(
              'SIGNING...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    if (_signed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: MultandoColors.success.withAlpha(200),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified, size: 14, color: Colors.white),
            SizedBox(width: 4),
            Text(
              'SIGNED',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(180),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning, size: 14, color: Colors.white),
          SizedBox(width: 4),
          Text(
            'UNSIGNED',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Infraction grid
  // -----------------------------------------------------------------------

  Widget _buildInfractionGrid(
    List<InfractionResponse> items,
    NewReportState newReport,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((infraction) {
        final isSelected = newReport.selectedInfractionId == infraction.id.toString();
        return GestureDetector(
          onTap: () =>
              ref.read(newReportProvider.notifier).setInfraction(infraction.id.toString()),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? MultandoColors.brandRed.withAlpha(20)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? MultandoColors.brandRed
                    : MultandoColors.surface300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _infractionIcon(infraction.category),
                  size: 18,
                  color: isSelected
                      ? MultandoColors.brandRed
                      : MultandoColors.surface600,
                ),
                const SizedBox(width: 6),
                Text(
                  infraction.nameEn,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? MultandoColors.brandRed
                        : MultandoColors.surface700,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _infractionIcon(InfractionCategory category) {
    switch (category) {
      case InfractionCategory.parking:
        return Icons.local_parking;
      case InfractionCategory.speeding:
        return Icons.speed;
      case InfractionCategory.redLight:
        return Icons.traffic;
      case InfractionCategory.illegalTurn:
        return Icons.turn_right;
      case InfractionCategory.wrongWay:
        return Icons.wrong_location;
      case InfractionCategory.noSeatbelt:
        return Icons.airline_seat_recline_normal;
      case InfractionCategory.phoneUse:
        return Icons.phone_android;
      case InfractionCategory.recklessDriving:
        return Icons.warning;
      case InfractionCategory.dui:
        return Icons.local_bar;
      case InfractionCategory.other:
        return Icons.report;
    }
  }
}
