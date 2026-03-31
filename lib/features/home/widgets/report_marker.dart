import 'package:flutter/material.dart';
import 'package:multando_sdk/multando_sdk.dart';

import '../../../core/colors.dart';

/// Returns the appropriate color for a report status marker on the map.
Color markerColorForStatus(ReportStatus status) {
  switch (status) {
    case ReportStatus.draft:
      return MultandoColors.statusDraft;
    case ReportStatus.submitted:
      return MultandoColors.statusSubmitted;
    case ReportStatus.underReview:
      return MultandoColors.statusUnderReview;
    case ReportStatus.verified:
      return MultandoColors.statusVerified;
    case ReportStatus.rejected:
      return MultandoColors.statusRejected;
    case ReportStatus.appealed:
      return MultandoColors.statusAppealed;
    case ReportStatus.resolved:
      return MultandoColors.statusResolved;
  }
}

/// A styled marker info card shown when a marker is tapped.
class ReportMarkerInfo extends StatelessWidget {
  const ReportMarkerInfo({
    super.key,
    required this.report,
    this.onTap,
  });

  final ReportSummary report;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = markerColorForStatus(report.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  report.plateNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  report.status.value.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
