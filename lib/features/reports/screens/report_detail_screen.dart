import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/colors.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../home/widgets/report_marker.dart';
import '../providers/reports_provider.dart';

class ReportDetailScreen extends ConsumerWidget {
  const ReportDetailScreen({super.key, required this.reportId});

  final String reportId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(reportDetailProvider(reportId));

    return Scaffold(
      appBar: AppBar(title: const Text('Report Details')),
      body: reportAsync.when(
        loading: () => const MultandoLoadingIndicator(),
        error: (err, _) => MultandoErrorWidget(
          message: err.toString(),
          onRetry: () => ref.invalidate(reportDetailProvider(reportId)),
        ),
        data: (report) {
          final statusColor = markerColorForStatus(report.status);
          final dateStr = DateFormat('MMMM d, y - h:mm a').format(report.createdAt);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor.withAlpha(60)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.circle, color: statusColor, size: 12),
                      const SizedBox(width: 8),
                      Text(
                        report.status.value.replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      if (report.verificationCount != null)
                        Row(
                          children: [
                            const Icon(Icons.verified, size: 16, color: MultandoColors.success),
                            const SizedBox(width: 4),
                            Text(
                              '${report.verificationCount}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      if (report.rejectionCount != null) ...[
                        const SizedBox(width: 12),
                        Row(
                          children: [
                            const Icon(Icons.cancel, size: 16, color: MultandoColors.danger),
                            const SizedBox(width: 4),
                            Text(
                              '${report.rejectionCount}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Plate number
                _DetailSection(
                  icon: Icons.directions_car,
                  title: 'Vehicle',
                  child: Text(
                    report.plateNumber,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      color: MultandoColors.surface900,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Location
                _DetailSection(
                  icon: Icons.location_on,
                  title: 'Location',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (report.location.address != null)
                        Text(
                          report.location.address!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      Text(
                        '${report.location.latitude.toStringAsFixed(6)}, ${report.location.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: MultandoColors.surface400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Date
                _DetailSection(
                  icon: Icons.calendar_today,
                  title: 'Date',
                  child: Text(dateStr, style: const TextStyle(fontSize: 14)),
                ),
                const SizedBox(height: 20),

                // Description
                if (report.description != null) ...[
                  _DetailSection(
                    icon: Icons.notes,
                    title: 'Description',
                    child: Text(
                      report.description!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Evidence
                if (report.evidence.isNotEmpty) ...[
                  _DetailSection(
                    icon: Icons.photo_library,
                    title: 'Evidence (${report.evidence.length})',
                    child: SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: report.evidence.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final evidence = report.evidence[index];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 120,
                              color: MultandoColors.surface200,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      evidence.type.value == 'photo'
                                          ? Icons.photo
                                          : Icons.videocam,
                                      color: MultandoColors.surface500,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      evidence.type.value,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: MultandoColors.surface500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Report ID
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: MultandoColors.surface100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Report ID: ${report.id}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: MultandoColors.surface400,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: MultandoColors.surface500),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: MultandoColors.surface500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
