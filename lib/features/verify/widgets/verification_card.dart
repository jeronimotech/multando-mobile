import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multando_sdk/multando_sdk.dart';

import '../../../core/colors.dart';

/// A swipeable card for the verification screen.
class VerificationCard extends StatelessWidget {
  const VerificationCard({
    super.key,
    required this.report,
    this.rotation = 0.0,
    this.scale = 1.0,
  });

  final ReportSummary report;
  final double rotation;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, y - h:mm a').format(report.createdAt);

    return Transform.scale(
      scale: scale,
      child: Transform.rotate(
        angle: rotation,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Evidence image placeholder
              Container(
                height: 240,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: MultandoColors.surface200,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo, size: 64, color: MultandoColors.surface400),
                      SizedBox(height: 8),
                      Text(
                        'Evidence Photo',
                        style: TextStyle(
                          color: MultandoColors.surface500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Plate number
                    Row(
                      children: [
                        const Icon(Icons.directions_car, size: 20, color: MultandoColors.surface600),
                        const SizedBox(width: 8),
                        Text(
                          report.plateNumber,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                            color: MultandoColors.surface900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Infraction
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: MultandoColors.brandRed.withAlpha(15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        report.infractionId,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: MultandoColors.brandRed,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Description
                    if (report.description != null) ...[
                      Text(
                        report.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: MultandoColors.surface600,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Date
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: MultandoColors.surface400),
                        const SizedBox(width: 6),
                        Text(
                          dateStr,
                          style: const TextStyle(
                            fontSize: 12,
                            color: MultandoColors.surface400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
