import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multando_sdk/multando_sdk.dart';

import '../../../core/colors.dart';
import '../../home/widgets/report_marker.dart';

/// Card widget for displaying a report summary in a list.
class ReportCard extends StatelessWidget {
  const ReportCard({
    super.key,
    required this.report,
    this.onTap,
  });

  final ReportSummary report;
  final VoidCallback? onTap;

  String _categoryIcon(String infractionId) {
    // Simple icon mapping based on common infraction types
    return '🚗';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = markerColorForStatus(report.status);
    final dateStr = DateFormat('MMM d, y - h:mm a').format(report.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Status indicator
              Container(
                width: 4,
                height: 56,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          report.plateNumber,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: MultandoColors.surface900,
                          ),
                        ),
                        const Spacer(),
                        _StatusBadge(
                          label: report.status.value.replaceAll('_', ' '),
                          color: statusColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (report.description != null)
                      Text(
                        report.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: MultandoColors.surface500,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 12,
                        color: MultandoColors.surface400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: MultandoColors.surface400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
