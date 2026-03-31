import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/colors.dart';
import '../providers/reports_provider.dart';
import 'new_report/capture_step.dart';
import 'new_report/confirm_step.dart';
import 'new_report/submit_step.dart';

/// New report wizard screen with 3 steps.
class NewReportScreen extends ConsumerStatefulWidget {
  const NewReportScreen({super.key});

  @override
  ConsumerState<NewReportScreen> createState() => _NewReportScreenState();
}

class _NewReportScreenState extends ConsumerState<NewReportScreen> {
  int _currentStep = 0;

  void _goToStep(int step) {
    setState(() => _currentStep = step.clamp(0, 2));
    ref.read(newReportProvider.notifier).setStep(_currentStep);
  }

  @override
  void dispose() {
    // Reset wizard state when leaving
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          ref.read(newReportProvider.notifier).reset();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('New Report'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              ref.read(newReportProvider.notifier).reset();
              Navigator.pop(context);
            },
          ),
        ),
        body: Column(
          children: [
            // Progress indicator
            _StepIndicator(currentStep: _currentStep),

            // Step content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildStep(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_currentStep) {
      case 0:
        return CaptureStep(
          key: const ValueKey(0),
          onNext: () => _goToStep(1),
        );
      case 1:
        return ConfirmStep(
          key: const ValueKey(1),
          onNext: () => _goToStep(2),
          onBack: () => _goToStep(0),
        );
      case 2:
        return SubmitStep(
          key: const ValueKey(2),
          onBack: () => _goToStep(1),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep});

  final int currentStep;

  static const _labels = ['Capture', 'Details', 'Submit'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: MultandoColors.surface200),
        ),
      ),
      child: Row(
        children: List.generate(_labels.length, (index) {
          final isActive = index == currentStep;
          final isCompleted = index < currentStep;

          return Expanded(
            child: Row(
              children: [
                if (index > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isCompleted
                          ? MultandoColors.brandRed
                          : MultandoColors.surface200,
                    ),
                  ),
                Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? MultandoColors.brandRed
                            : isActive
                                ? MultandoColors.brandRed
                                : MultandoColors.surface200,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check, color: Colors.white, size: 16)
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isActive
                                      ? Colors.white
                                      : MultandoColors.surface500,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _labels[index],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive
                            ? MultandoColors.brandRed
                            : MultandoColors.surface400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
