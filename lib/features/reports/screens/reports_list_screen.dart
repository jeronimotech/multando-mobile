import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/colors.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/multando_app_bar.dart';
import '../providers/reports_provider.dart';
import '../widgets/report_card.dart';

class ReportsListScreen extends ConsumerStatefulWidget {
  const ReportsListScreen({super.key});

  @override
  ConsumerState<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends ConsumerState<ReportsListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(reportsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportsState = ref.watch(reportsProvider);

    return Scaffold(
      appBar: MultandoAppBar(
        title: 'Reports',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/reports/new'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab bar
          Container(
            color: MultandoColors.brandRed,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              tabs: const [
                Tab(icon: Icon(Icons.list), text: 'List'),
                Tab(icon: Icon(Icons.map), text: 'Map'),
              ],
            ),
          ),
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // List view
                _buildListView(reportsState),
                // Map view placeholder
                const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map, size: 64, color: MultandoColors.surface300),
                      SizedBox(height: 16),
                      Text(
                        'Map view coming soon',
                        style: TextStyle(color: MultandoColors.surface500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/reports/new'),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const MultandoBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildListView(ReportsState reportsState) {
    if (reportsState.isLoading && reportsState.reports.isEmpty) {
      return const MultandoLoadingIndicator(message: 'Loading reports...');
    }

    if (reportsState.error != null && reportsState.reports.isEmpty) {
      return MultandoErrorWidget(
        message: reportsState.error!,
        onRetry: () => ref.read(reportsProvider.notifier).loadReports(refresh: true),
      );
    }

    if (reportsState.reports.isEmpty) {
      return MultandoEmptyState(
        title: 'No reports yet',
        description: 'Start reporting infractions to earn rewards!',
        icon: Icons.description_outlined,
        action: ElevatedButton.icon(
          onPressed: () => context.push('/reports/new'),
          icon: const Icon(Icons.add),
          label: const Text('New Report'),
        ),
      );
    }

    return RefreshIndicator(
      color: MultandoColors.brandRed,
      onRefresh: () => ref.read(reportsProvider.notifier).loadReports(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: reportsState.reports.length + (reportsState.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == reportsState.reports.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(color: MultandoColors.brandRed),
              ),
            );
          }
          final report = reportsState.reports[index];
          return ReportCard(
            report: report,
            onTap: () => context.push('/reports/${report.id}'),
          );
        },
      ),
    );
  }
}
