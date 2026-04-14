import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:multando_sdk/multando_sdk.dart';

import '../../../core/api_client.dart';
import '../../../core/colors.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_widget.dart';
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
        data: (report) => _ReportDetailBody(report: report),
      ),
    );
  }
}

class _ReportDetailBody extends StatelessWidget {
  const _ReportDetailBody({required this.report});
  final ReportDetail report;

  Color _statusColor(String status) {
    switch (status) {
      case 'verified':
        return MultandoColors.success;
      case 'rejected':
        return MultandoColors.danger;
      case 'pending':
        return Colors.orange;
      default:
        return MultandoColors.surface500;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'verified':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'pending':
        return Icons.pending;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(report.status.value);
    final dateStr = DateFormat('MMMM d, y - h:mm a').format(report.createdAt);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Evidence hero image
          if (report.evidence.isNotEmpty) ...[
            _EvidenceHero(evidence: report.evidence),
          ],

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Short ID + Status row
                Row(
                  children: [
                    // Short ID chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: MultandoColors.surface100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.tag, size: 14, color: MultandoColors.surface500),
                          const SizedBox(width: 4),
                          Text(
                            report.id.length > 10 ? report.id.substring(0, 8) : report.id,
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                              color: MultandoColors.surface600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Status chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withAlpha(80)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_statusIcon(report.status.value), color: statusColor, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            report.status.value.replaceAll('_', ' ').toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Plate number (big)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.directions_car, color: Colors.white70, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          report.plateNumber,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                            color: Colors.white,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: report.plateNumber));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Plate copied')),
                          );
                        },
                        child: const Icon(Icons.copy, color: Colors.white38, size: 18),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Info cards grid
                Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.calendar_today,
                        label: 'Date',
                        value: dateStr,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.source,
                        label: 'Source',
                        value: report.source.value,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (report.description != null && report.description!.isNotEmpty) ...[
                  _InfoCard(
                    icon: Icons.notes,
                    label: 'Description',
                    value: report.description!,
                    fullWidth: true,
                  ),
                  const SizedBox(height: 12),
                ],

                // Location map
                const _SectionHeader(icon: Icons.location_on, title: 'Location'),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 180,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(report.location.latitude, report.location.longitude),
                        zoom: 16,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId('report'),
                          position: LatLng(report.location.latitude, report.location.longitude),
                          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                        ),
                      },
                      myLocationEnabled: false,
                      zoomControlsEnabled: false,
                      scrollGesturesEnabled: false,
                      tiltGesturesEnabled: false,
                      rotateGesturesEnabled: false,
                      mapToolbarEnabled: false,
                      liteModeEnabled: true,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${report.location.latitude.toStringAsFixed(6)}, ${report.location.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(fontSize: 11, color: MultandoColors.surface400),
                ),
                if (report.location.address != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    report.location.address!,
                    style: const TextStyle(fontSize: 12, color: MultandoColors.surface600),
                  ),
                ],
                const SizedBox(height: 20),

                // Verification stats
                if (report.verificationCount != null || report.rejectionCount != null) ...[
                  const _SectionHeader(icon: Icons.how_to_vote, title: 'Community Verification'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (report.verificationCount != null)
                        _StatChip(
                          icon: Icons.thumb_up,
                          color: MultandoColors.success,
                          label: 'Verified',
                          count: report.verificationCount!,
                        ),
                      const SizedBox(width: 12),
                      if (report.rejectionCount != null)
                        _StatChip(
                          icon: Icons.thumb_down,
                          color: MultandoColors.danger,
                          label: 'Rejected',
                          count: report.rejectionCount!,
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],

                // Report ID footer
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
                      fontSize: 10,
                      color: MultandoColors.surface400,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Provider for presigned evidence URL
final _evidenceUrlProvider = FutureProvider.family<String, String>((ref, evidenceId) async {
  final client = ref.watch(apiClientProvider);
  if (!client.isInitialized || !client.isAuthenticated) return '';
  final id = int.tryParse(evidenceId);
  if (id == null) return '';
  return client.evidence.getPresignedUrl(id);
});

// Evidence hero — shows images directly from public bucket URLs
class _EvidenceHero extends ConsumerWidget {
  const _EvidenceHero({required this.evidence});
  final List<EvidenceResponse> evidence;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final images = evidence.where((e) =>
        e.url.startsWith('http') &&
        (e.mimeType.startsWith('image/') || e.type.value == 'image')).toList();

    if (images.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 260,
      child: PageView.builder(
        itemCount: images.length,
        itemBuilder: (context, index) {
          final ev = images[index];
          final url = ev.url;

          return GestureDetector(
              onTap: () => _showFullImage(context, url),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    url,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: MultandoColors.surface200,
                        child: const Center(
                          child: CircularProgressIndicator(color: MultandoColors.brandRed),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      color: MultandoColors.surface200,
                      child: const Center(
                        child: Icon(Icons.broken_image, color: MultandoColors.surface400, size: 48),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withAlpha(120)],
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.photo_camera, color: Colors.white70, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Evidence ${index + 1} of ${images.length}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          const Spacer(),
                          const Icon(Icons.zoom_in, color: Colors.white70, size: 16),
                        ],
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

void _showFullImage(BuildContext context, String url) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: InteractiveViewer(
        child: Center(
          child: Image.network(url, fit: BoxFit.contain),
        ),
      ),
    ),
  ));
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: MultandoColors.surface500),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: MultandoColors.surface600,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.fullWidth = false,
  });
  final IconData icon;
  final String label;
  final String value;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MultandoColors.surface100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: MultandoColors.surface400),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(fontSize: 11, color: MultandoColors.surface400)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: MultandoColors.surface800),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.color,
    required this.label,
    required this.count,
  });
  final IconData icon;
  final Color color;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text('$count', style: TextStyle(fontWeight: FontWeight.w700, color: color)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}
