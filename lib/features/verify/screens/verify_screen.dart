import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multando_sdk/multando_sdk.dart';

import '../../../core/api_client.dart';
import '../../../core/colors.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/multando_app_bar.dart';
import '../widgets/verification_card.dart';

/// Provider for the verification queue.
final _verificationQueueProvider =
    FutureProvider.autoDispose<List<ReportSummary>>((ref) async {
  final client = ref.watch(apiClientProvider);
  if (!client.isInitialized) return [];
  return client.verification.getQueue();
});

class VerifyScreen extends ConsumerStatefulWidget {
  const VerifyScreen({super.key});

  @override
  ConsumerState<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends ConsumerState<VerifyScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  double _dragX = 0;
  bool _isProcessing = false;

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() => _dragX += details.delta.dx);
  }

  void _onPanEnd(DragEndDetails details, List<ReportSummary> queue) {
    if (_dragX.abs() > 100 && !_isProcessing) {
      final isVerify = _dragX > 0;
      _processSwipe(queue, isVerify);
    } else {
      setState(() => _dragX = 0);
    }
  }

  Future<void> _processSwipe(List<ReportSummary> queue, bool isVerify) async {
    if (_currentIndex >= queue.length) return;
    setState(() => _isProcessing = true);

    final report = queue[_currentIndex];
    try {
      final client = ref.read(apiClientProvider);
      if (isVerify) {
        await client.verification.verify(report.id);
      } else {
        await client.verification.reject(
          report.id,
          const RejectRequest(reason: 'Rejected during community verification'),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: MultandoColors.danger),
        );
      }
    }

    if (mounted) {
      setState(() {
        _currentIndex++;
        _dragX = 0;
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final queueAsync = ref.watch(_verificationQueueProvider);

    return Scaffold(
      appBar: const MultandoAppBar(title: 'Verify Reports'),
      body: queueAsync.when(
        loading: () => const MultandoLoadingIndicator(message: 'Loading queue...'),
        error: (err, _) => MultandoErrorWidget(
          message: err.toString(),
          onRetry: () => ref.invalidate(_verificationQueueProvider),
        ),
        data: (queue) {
          if (queue.isEmpty || _currentIndex >= queue.length) {
            return const MultandoEmptyState(
              title: 'No more reports to verify',
              description: 'Check back later for new reports.',
              icon: Icons.verified,
            );
          }

          return Column(
            children: [
              // Instructions
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: MultandoColors.surface100,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.swipe, size: 18, color: MultandoColors.surface500),
                    SizedBox(width: 8),
                    Text(
                      'Swipe right to verify, left to reject',
                      style: TextStyle(
                        fontSize: 13,
                        color: MultandoColors.surface500,
                      ),
                    ),
                  ],
                ),
              ),

              // Card stack
              Expanded(
                child: GestureDetector(
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: (d) => _onPanEnd(d, queue),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background card (next)
                      if (_currentIndex + 1 < queue.length)
                        VerificationCard(
                          report: queue[_currentIndex + 1],
                          scale: 0.95,
                        ),

                      // Current card
                      AnimatedContainer(
                        duration: _dragX == 0
                            ? const Duration(milliseconds: 300)
                            : Duration.zero,
                        transform: Matrix4.identity()
                          ..translate(_dragX, 0.0, 0.0)
                          ..rotateZ(_dragX * 0.001),
                        child: Stack(
                          children: [
                            VerificationCard(report: queue[_currentIndex]),

                            // Verify overlay
                            if (_dragX > 50)
                              Positioned.fill(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: MultandoColors.success.withAlpha(
                                      min((_dragX / 200 * 80).round(), 80),
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Center(
                                    child: Transform.rotate(
                                      angle: -0.3,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: MultandoColors.success,
                                            width: 3,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'VERIFY',
                                          style: TextStyle(
                                            color: MultandoColors.success,
                                            fontSize: 32,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                            // Reject overlay
                            if (_dragX < -50)
                              Positioned.fill(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: MultandoColors.danger.withAlpha(
                                      min((_dragX.abs() / 200 * 80).round(), 80),
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Center(
                                    child: Transform.rotate(
                                      angle: 0.3,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: MultandoColors.danger,
                                            width: 3,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'REJECT',
                                          style: TextStyle(
                                            color: MultandoColors.danger,
                                            fontSize: 32,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 40, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Reject button
                    GestureDetector(
                      onTap: () => _processSwipe(queue, false),
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: MultandoColors.danger.withAlpha(15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: MultandoColors.danger.withAlpha(60),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: MultandoColors.danger,
                          size: 32,
                        ),
                      ),
                    ),
                    // Counter
                    Text(
                      '${_currentIndex + 1} / ${queue.length}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: MultandoColors.surface500,
                      ),
                    ),
                    // Verify button
                    GestureDetector(
                      onTap: () => _processSwipe(queue, true),
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: MultandoColors.success.withAlpha(15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: MultandoColors.success.withAlpha(60),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: MultandoColors.success,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const MultandoBottomNavBar(currentIndex: 2),
    );
  }
}
