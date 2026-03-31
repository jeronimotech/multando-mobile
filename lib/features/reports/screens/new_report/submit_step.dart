import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/colors.dart';
import '../../providers/reports_provider.dart';

/// Step 3: Review and submit the report.
class SubmitStep extends ConsumerWidget {
  const SubmitStep({
    super.key,
    required this.onBack,
  });

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newReport = ref.watch(newReportProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Step 3: Review & Submit',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: MultandoColors.surface900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Review your report details before submitting.',
            style: TextStyle(color: MultandoColors.surface500, fontSize: 14),
          ),
          const SizedBox(height: 24),

          // Summary card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: MultandoColors.surface200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SummaryRow(
                  icon: Icons.camera_alt,
                  label: 'Evidence',
                  value: newReport.capturedImagePath != null
                      ? 'Photo captured'
                      : 'Not captured',
                  valueColor: newReport.capturedImagePath != null
                      ? MultandoColors.success
                      : MultandoColors.danger,
                ),
                const Divider(height: 24),
                _SummaryRow(
                  icon: Icons.gavel,
                  label: 'Infraction',
                  value: newReport.selectedInfractionId ?? 'Not selected',
                ),
                const Divider(height: 24),
                _SummaryRow(
                  icon: Icons.confirmation_number,
                  label: 'Plate Number',
                  value: newReport.plateNumber.isEmpty
                      ? 'Not entered'
                      : newReport.plateNumber,
                ),
                if (newReport.vehicleTypeId != null) ...[
                  const Divider(height: 24),
                  _SummaryRow(
                    icon: Icons.directions_car,
                    label: 'Vehicle Type',
                    value: newReport.vehicleTypeId!,
                  ),
                ],
                const Divider(height: 24),
                _SummaryRow(
                  icon: Icons.location_on,
                  label: 'Location',
                  value: newReport.latitude != null
                      ? '${newReport.latitude!.toStringAsFixed(4)}, ${newReport.longitude!.toStringAsFixed(4)}'
                      : 'Not captured',
                ),
                if (newReport.description.isNotEmpty) ...[
                  const Divider(height: 24),
                  _SummaryRow(
                    icon: Icons.notes,
                    label: 'Description',
                    value: newReport.description,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Terms notice
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: MultandoColors.info.withAlpha(15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: MultandoColors.info.withAlpha(40)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: MultandoColors.info, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'By submitting, you confirm this report is accurate and '
                    'was captured at the time of the violation.',
                    style: TextStyle(fontSize: 12, color: MultandoColors.surface600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Error
          if (newReport.error != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MultandoColors.danger.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                newReport.error!,
                style: const TextStyle(color: MultandoColors.danger, fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: newReport.isSubmitting ? null : onBack,
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: newReport.isSubmitting
                      ? null
                      : () async {
                          final result =
                              await ref.read(newReportProvider.notifier).submit();
                          if (result != null && context.mounted) {
                            _showSuccess(context, ref);
                          }
                        },
                  child: newReport.isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Submit Report'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSuccess(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0x2010B981),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: MultandoColors.success,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Report Submitted!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: MultandoColors.surface900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your report has been submitted for community verification.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: MultandoColors.surface500,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ref.read(newReportProvider.notifier).reset();
                Navigator.of(context).pop();
                context.go('/reports');
              },
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: MultandoColors.surface400),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: MultandoColors.surface400,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? MultandoColors.surface800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
