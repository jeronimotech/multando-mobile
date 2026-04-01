import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  bool _captured = false;

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
          GestureDetector(
            onTap: () {
              // In production, this opens the secure camera.
              // For now, simulate capture.
              ref.read(newReportProvider.notifier).setCapturedImage('/tmp/evidence.jpg');
              setState(() => _captured = true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Evidence captured successfully'),
                  backgroundColor: MultandoColors.success,
                ),
              );
            },
            child: Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: _captured
                    ? MultandoColors.success.withAlpha(20)
                    : MultandoColors.surface100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _captured
                      ? MultandoColors.success
                      : MultandoColors.surface300,
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _captured ? Icons.check_circle : Icons.camera_alt,
                    size: 56,
                    color: _captured
                        ? MultandoColors.success
                        : MultandoColors.surface400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _captured ? 'Evidence Captured' : 'Tap to capture evidence',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _captured
                          ? MultandoColors.success
                          : MultandoColors.surface500,
                    ),
                  ),
                  if (!_captured) ...[
                    const SizedBox(height: 4),
                    const Text(
                      'GPS, timestamp, and watermark will be applied',
                      style: TextStyle(
                        fontSize: 12,
                        color: MultandoColors.surface400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
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
            onPressed: (_captured && newReport.selectedInfractionId != null)
                ? widget.onNext
                : null,
            child: const Text('Next: Vehicle Details'),
          ),
        ],
      ),
    );
  }

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
