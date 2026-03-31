import 'package:flutter/material.dart';
import '../../../core/colors.dart';

/// A single leaderboard entry.
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.points,
    required this.level,
    this.isCurrentUser = false,
  });

  final int rank;
  final String name;
  final int points;
  final int level;
  final bool isCurrentUser;
}

/// The leaderboard list widget.
class LeaderboardList extends StatelessWidget {
  const LeaderboardList({super.key, required this.entries});

  final List<LeaderboardEntry> entries;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _LeaderboardTile(entry: entry);
      },
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile({required this.entry});

  final LeaderboardEntry entry;

  Color get _rankColor {
    switch (entry.rank) {
      case 1:
        return MultandoColors.accentGold;
      case 2:
        return MultandoColors.surface400;
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return MultandoColors.surface300;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: entry.isCurrentUser
            ? MultandoColors.brandRed.withAlpha(10)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: entry.isCurrentUser
              ? MultandoColors.brandRed.withAlpha(40)
              : MultandoColors.surface200,
        ),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 36,
            child: entry.rank <= 3
                ? Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _rankColor.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${entry.rank}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: _rankColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      '${entry.rank}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: MultandoColors.surface500,
                        fontSize: 14,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 12),

          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: MultandoColors.surface200,
            child: Text(
              entry.name.isNotEmpty ? entry.name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: MultandoColors.surface600,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name and level
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: entry.isCurrentUser
                        ? MultandoColors.brandRed
                        : MultandoColors.surface900,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Level ${entry.level}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: MultandoColors.surface400,
                  ),
                ),
              ],
            ),
          ),

          // Points
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.points}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: MultandoColors.accentGold,
                  fontSize: 16,
                ),
              ),
              const Text(
                'pts',
                style: TextStyle(
                  fontSize: 10,
                  color: MultandoColors.surface400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
