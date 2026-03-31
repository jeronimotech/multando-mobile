import 'package:flutter/material.dart';

import '../core/colors.dart';

/// Full-screen secure camera for evidence capture.
///
/// In production, this wraps the SDK's SecureCameraWidget.
/// For development/simulation, it provides a mock capture flow.
class SecureCameraScreen extends StatefulWidget {
  const SecureCameraScreen({
    super.key,
    required this.onCapture,
  });

  /// Called with the file path of the captured image.
  final void Function(String imagePath) onCapture;

  @override
  State<SecureCameraScreen> createState() => _SecureCameraScreenState();
}

class _SecureCameraScreenState extends State<SecureCameraScreen> {
  bool _capturing = false;
  bool _captured = false;

  Future<void> _capture() async {
    setState(() => _capturing = true);

    // Simulate capture delay (in production, uses the SDK's SecureCameraWidget)
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _capturing = false;
        _captured = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera preview placeholder
            Positioned.fill(
              child: Container(
                color: MultandoColors.surface900,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera, size: 80, color: Colors.white24),
                      SizedBox(height: 16),
                      Text(
                        'Camera Preview',
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Watermark overlay
            Positioned(
              top: 12,
              left: 12,
              child: Text(
                'MULTANDO',
                style: TextStyle(
                  color: Colors.white.withAlpha(180),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: const [Shadow(blurRadius: 4, color: Colors.black54)],
                ),
              ),
            ),

            // Timestamp overlay
            Positioned(
              bottom: 100,
              left: 12,
              child: Text(
                DateTime.now().toUtc().toIso8601String(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontFamily: 'monospace',
                  shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                ),
              ),
            ),

            // Verified badge when captured
            if (_captured)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: MultandoColors.success.withAlpha(150),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'VERIFIED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // Controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                child: _captured
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: MultandoColors.surface700,
                              minimumSize: const Size(120, 48),
                            ),
                            onPressed: () => setState(() => _captured = false),
                            child: const Text('Retake'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(120, 48),
                            ),
                            onPressed: () {
                              widget.onCapture('/tmp/evidence_${DateTime.now().millisecondsSinceEpoch}.jpg');
                              Navigator.pop(context);
                            },
                            child: const Text('Confirm'),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          IconButton(
                            icon: const Icon(Icons.flash_off, color: Colors.white),
                            onPressed: () {},
                          ),
                          // Capture button
                          GestureDetector(
                            onTap: _capturing ? null : _capture,
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _capturing ? MultandoColors.brandRed : Colors.white,
                                  width: 4,
                                ),
                              ),
                              child: _capturing
                                  ? const Center(
                                      child: SizedBox(
                                        width: 32,
                                        height: 32,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 3,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      margin: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
                            onPressed: () {},
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
