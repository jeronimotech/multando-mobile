import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multando_sdk/multando_sdk.dart';

import '../../../core/api_client.dart';

class WalletState {
  const WalletState({
    this.balance,
    this.stakingInfo,
    this.transactions = const [],
    this.isLoading = false,
    this.error,
  });

  final TokenBalance? balance;
  final StakingInfo? stakingInfo;
  final List<TokenTransaction> transactions;
  final bool isLoading;
  final String? error;

  WalletState copyWith({
    TokenBalance? balance,
    StakingInfo? stakingInfo,
    List<TokenTransaction>? transactions,
    bool? isLoading,
    String? error,
  }) {
    return WalletState(
      balance: balance ?? this.balance,
      stakingInfo: stakingInfo ?? this.stakingInfo,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class WalletNotifier extends Notifier<WalletState> {
  @override
  WalletState build() {
    loadWallet();
    return const WalletState(isLoading: true);
  }

  Future<void> loadWallet() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final client = ref.read(apiClientProvider);
      if (!client.isInitialized) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final results = await Future.wait([
        client.blockchain.getBalance(),
        client.blockchain.stakingInfo(),
        client.blockchain.transactions(),
      ]);

      state = WalletState(
        balance: results[0] as TokenBalance,
        stakingInfo: results[1] as StakingInfo,
        transactions: results[2] as List<TokenTransaction>,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> stake(double amount) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final client = ref.read(apiClientProvider);
      await client.blockchain.stake(StakeRequest(amount: amount));
      await loadWallet();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> unstake(double amount) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final client = ref.read(apiClientProvider);
      await client.blockchain.unstake(UnstakeRequest(amount: amount));
      await loadWallet();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> claimRewards() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final client = ref.read(apiClientProvider);
      await client.blockchain.claimRewards();
      await loadWallet();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final walletProvider =
    NotifierProvider<WalletNotifier, WalletState>(WalletNotifier.new);
