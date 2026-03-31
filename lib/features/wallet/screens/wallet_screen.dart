import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:multando_sdk/multando_sdk.dart';

import '../../../core/colors.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/multando_app_bar.dart';
import '../providers/wallet_provider.dart';
import '../widgets/balance_card.dart';
import '../widgets/staking_card.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);

    return Scaffold(
      appBar: const MultandoAppBar(title: 'Wallet'),
      body: wallet.isLoading && wallet.balance == null
          ? const MultandoLoadingIndicator(message: 'Loading wallet...')
          : wallet.error != null && wallet.balance == null
              ? MultandoErrorWidget(
                  message: wallet.error!,
                  onRetry: () => ref.read(walletProvider.notifier).loadWallet(),
                )
              : RefreshIndicator(
                  color: MultandoColors.brandRed,
                  onRefresh: () =>
                      ref.read(walletProvider.notifier).loadWallet(),
                  child: ListView(
                    children: [
                      // Balance card
                      if (wallet.balance != null)
                        BalanceCard(balance: wallet.balance!),

                      // Rewards preview banner
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              MultandoColors.accentGold.withAlpha(30),
                              MultandoColors.accentGoldLight.withAlpha(15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: MultandoColors.accentGold.withAlpha(50),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: MultandoColors.accentGoldDark, size: 20),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'MULTA points are tracked in our database. '
                                'Blockchain integration coming soon!',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: MultandoColors.surface600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Staking card
                      if (wallet.stakingInfo != null) ...[
                        const SizedBox(height: 8),
                        StakingCard(
                          info: wallet.stakingInfo!,
                          onStake: () => _showAmountDialog(
                            context,
                            'Stake MULTA',
                            (amount) => ref.read(walletProvider.notifier).stake(amount),
                          ),
                          onUnstake: () => _showAmountDialog(
                            context,
                            'Unstake MULTA',
                            (amount) => ref.read(walletProvider.notifier).unstake(amount),
                          ),
                          onClaimRewards: () =>
                              ref.read(walletProvider.notifier).claimRewards(),
                        ),
                      ],

                      // Transactions
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                        child: Text(
                          'Transaction History',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: MultandoColors.surface900,
                          ),
                        ),
                      ),

                      if (wallet.transactions.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: Text(
                              'No transactions yet',
                              style: TextStyle(color: MultandoColors.surface400),
                            ),
                          ),
                        )
                      else
                        ...wallet.transactions.map(
                          (tx) => _TransactionTile(transaction: tx),
                        ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
      bottomNavigationBar: const MultandoBottomNavBar(currentIndex: 3),
    );
  }

  void _showAmountDialog(
    BuildContext context,
    String title,
    void Function(double) onConfirm,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Amount',
            hintText: 'Enter amount',
            suffixText: 'MULTA',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                onConfirm(amount);
                Navigator.pop(context);
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});

  final TokenTransaction transaction;

  IconData get _icon {
    switch (transaction.type) {
      case TokenTxType.reward:
        return Icons.stars;
      case TokenTxType.stake:
        return Icons.lock;
      case TokenTxType.unstake:
        return Icons.lock_open;
      case TokenTxType.transferIn:
        return Icons.arrow_downward;
      case TokenTxType.transferOut:
        return Icons.arrow_upward;
      case TokenTxType.claim:
        return Icons.redeem;
      case TokenTxType.penalty:
        return Icons.warning;
    }
  }

  Color get _color {
    switch (transaction.type) {
      case TokenTxType.reward:
      case TokenTxType.transferIn:
      case TokenTxType.claim:
        return MultandoColors.success;
      case TokenTxType.penalty:
      case TokenTxType.transferOut:
        return MultandoColors.danger;
      case TokenTxType.stake:
      case TokenTxType.unstake:
        return MultandoColors.info;
    }
  }

  String get _sign {
    switch (transaction.type) {
      case TokenTxType.reward:
      case TokenTxType.transferIn:
      case TokenTxType.claim:
      case TokenTxType.unstake:
        return '+';
      case TokenTxType.penalty:
      case TokenTxType.transferOut:
      case TokenTxType.stake:
        return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, h:mm a').format(transaction.createdAt);

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _color.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(_icon, color: _color, size: 20),
      ),
      title: Text(
        transaction.type.value.replaceAll('_', ' ').toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: MultandoColors.surface800,
        ),
      ),
      subtitle: Text(
        transaction.description ?? dateStr,
        style: const TextStyle(fontSize: 12, color: MultandoColors.surface400),
      ),
      trailing: Text(
        '$_sign${transaction.amount.toStringAsFixed(2)}',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: _color,
        ),
      ),
    );
  }
}
