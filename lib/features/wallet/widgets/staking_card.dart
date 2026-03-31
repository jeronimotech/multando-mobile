import 'package:flutter/material.dart';
import 'package:multando_sdk/multando_sdk.dart';

import '../../../core/colors.dart';

/// Card showing staking information and actions.
class StakingCard extends StatelessWidget {
  const StakingCard({
    super.key,
    required this.info,
    this.onStake,
    this.onUnstake,
    this.onClaimRewards,
  });

  final StakingInfo info;
  final VoidCallback? onStake;
  final VoidCallback? onUnstake;
  final VoidCallback? onClaimRewards;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.savings, color: MultandoColors.accentGold),
                const SizedBox(width: 8),
                const Text(
                  'Staking',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: MultandoColors.surface900,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: MultandoColors.accentGold.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${info.apy.toStringAsFixed(1)}% APY',
                    style: const TextStyle(
                      color: MultandoColors.accentGoldDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Staked amount
            Row(
              children: [
                Expanded(
                  child: _StakingMetric(
                    label: 'Staked',
                    value: info.stakedAmount.toStringAsFixed(2),
                    icon: Icons.lock,
                    color: MultandoColors.info,
                  ),
                ),
                Expanded(
                  child: _StakingMetric(
                    label: 'Rewards',
                    value: info.pendingRewards.toStringAsFixed(2),
                    icon: Icons.stars,
                    color: MultandoColors.accentGold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Lock status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: MultandoColors.surface100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    info.isLocked ? Icons.lock : Icons.lock_open,
                    size: 16,
                    color: info.isLocked
                        ? MultandoColors.warning
                        : MultandoColors.success,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    info.isLocked ? 'Locked' : 'Unlocked',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: info.isLocked
                          ? MultandoColors.warning
                          : MultandoColors.success,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onStake,
                    child: const Text('Stake'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: info.isLocked ? null : onUnstake,
                    child: const Text('Unstake'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: info.pendingRewards > 0 ? onClaimRewards : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MultandoColors.accentGold,
                    ),
                    child: const Text('Claim'),
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

class _StakingMetric extends StatelessWidget {
  const _StakingMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: MultandoColors.surface400,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: MultandoColors.surface900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
