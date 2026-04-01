import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/colors.dart';
import '../../../shared/widgets/multando_app_bar.dart';
import '../widgets/badge_card.dart';
import '../widgets/leaderboard_list.dart';

/// Demo badges (in production, these come from the API).
final _demoBadges = [
  const MultandoBadge(
    id: '1',
    name: 'First Report',
    description: 'Submit your first infraction report',
    icon: Icons.flag,
    rarity: BadgeRarity.common,
    earned: true,
  ),
  const MultandoBadge(
    id: '2',
    name: 'Eagle Eye',
    description: 'Get 10 reports verified',
    icon: Icons.visibility,
    rarity: BadgeRarity.uncommon,
    earned: true,
  ),
  const MultandoBadge(
    id: '3',
    name: 'Verifier',
    description: 'Verify 50 reports from other users',
    icon: Icons.verified,
    rarity: BadgeRarity.rare,
    earned: false,
  ),
  const MultandoBadge(
    id: '4',
    name: 'Guardian',
    description: 'Maintain 95% accuracy for 30 days',
    icon: Icons.shield,
    rarity: BadgeRarity.epic,
    earned: false,
  ),
  const MultandoBadge(
    id: '5',
    name: 'Legend',
    description: 'Reach the top 10 leaderboard',
    icon: Icons.emoji_events,
    rarity: BadgeRarity.legendary,
    earned: false,
  ),
  const MultandoBadge(
    id: '6',
    name: 'Night Owl',
    description: 'Submit a report after midnight',
    icon: Icons.nights_stay,
    rarity: BadgeRarity.uncommon,
    earned: true,
  ),
  const MultandoBadge(
    id: '7',
    name: 'Staker',
    description: 'Stake 100 MULTA tokens',
    icon: Icons.savings,
    rarity: BadgeRarity.rare,
    earned: false,
  ),
  const MultandoBadge(
    id: '8',
    name: 'Explorer',
    description: 'Report from 5 different cities',
    icon: Icons.explore,
    rarity: BadgeRarity.epic,
    earned: false,
  ),
];

final _demoLeaderboard = [
  const LeaderboardEntry(rank: 1, name: 'Maria G.', points: 12450, level: 15),
  const LeaderboardEntry(rank: 2, name: 'Carlos R.', points: 11200, level: 14),
  const LeaderboardEntry(rank: 3, name: 'Ana P.', points: 9800, level: 13),
  const LeaderboardEntry(rank: 4, name: 'Juan D.', points: 8500, level: 12),
  const LeaderboardEntry(rank: 5, name: 'Sofia M.', points: 7200, level: 11, isCurrentUser: true),
  const LeaderboardEntry(rank: 6, name: 'Pedro L.', points: 6100, level: 10),
  const LeaderboardEntry(rank: 7, name: 'Laura V.', points: 5400, level: 9),
  const LeaderboardEntry(rank: 8, name: 'Diego H.', points: 4800, level: 8),
  const LeaderboardEntry(rank: 9, name: 'Camila S.', points: 4200, level: 7),
  const LeaderboardEntry(rank: 10, name: 'Roberto F.', points: 3600, level: 6),
];

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Badges'),
            Tab(text: 'Leaderboard'),
            Tab(text: 'Levels'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Badges tab
          _buildBadgesTab(),
          // Leaderboard tab
          LeaderboardList(entries: _demoLeaderboard),
          // Levels tab
          _buildLevelsTab(),
        ],
      ),
    );
  }

  Widget _buildBadgesTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.85,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _demoBadges.length,
      itemBuilder: (context, index) => BadgeCard(badge: _demoBadges[index]),
    );
  }

  Widget _buildLevelsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 20,
      itemBuilder: (context, index) {
        final level = index + 1;
        final pointsRequired = level * 500;
        final isUnlocked = level <= 5; // Demo: first 5 levels unlocked

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isUnlocked ? Colors.white : MultandoColors.surface100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isUnlocked
                  ? MultandoColors.accentGold.withAlpha(60)
                  : MultandoColors.surface200,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? MultandoColors.accentGold.withAlpha(25)
                      : MultandoColors.surface200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '$level',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isUnlocked
                          ? MultandoColors.accentGold
                          : MultandoColors.surface400,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level $level',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isUnlocked
                            ? MultandoColors.surface900
                            : MultandoColors.surface400,
                      ),
                    ),
                    Text(
                      '$pointsRequired points required',
                      style: const TextStyle(
                        fontSize: 12,
                        color: MultandoColors.surface400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isUnlocked ? Icons.check_circle : Icons.lock,
                color: isUnlocked
                    ? MultandoColors.success
                    : MultandoColors.surface300,
              ),
            ],
          ),
        );
      },
    );
  }
}
