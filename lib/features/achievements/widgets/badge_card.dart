import 'package:flutter/material.dart';
import '../../../core/colors.dart';

/// Represents a badge the user can earn.
class MultandoBadge {
  const MultandoBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.rarity,
    this.earned = false,
    this.earnedAt,
  });

  final String id;
  final String name;
  final String description;
  final IconData icon;
  final BadgeRarity rarity;
  final bool earned;
  final DateTime? earnedAt;
}

enum BadgeRarity { common, uncommon, rare, epic, legendary }

Color rarityColor(BadgeRarity rarity) {
  switch (rarity) {
    case BadgeRarity.common:
      return MultandoColors.rarityCommon;
    case BadgeRarity.uncommon:
      return MultandoColors.rarityUncommon;
    case BadgeRarity.rare:
      return MultandoColors.rarityRare;
    case BadgeRarity.epic:
      return MultandoColors.rarityEpic;
    case BadgeRarity.legendary:
      return MultandoColors.rarityLegendary;
  }
}

String rarityLabel(BadgeRarity rarity) {
  switch (rarity) {
    case BadgeRarity.common:
      return 'Common';
    case BadgeRarity.uncommon:
      return 'Uncommon';
    case BadgeRarity.rare:
      return 'Rare';
    case BadgeRarity.epic:
      return 'Epic';
    case BadgeRarity.legendary:
      return 'Legendary';
  }
}

/// Card widget for a single badge.
class BadgeCard extends StatelessWidget {
  const BadgeCard({super.key, required this.badge});

  final MultandoBadge badge;

  @override
  Widget build(BuildContext context) {
    final color = rarityColor(badge.rarity);

    return Container(
      decoration: BoxDecoration(
        color: badge.earned ? Colors.white : MultandoColors.surface100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: badge.earned ? color.withAlpha(60) : MultandoColors.surface200,
          width: badge.earned ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: badge.earned ? color.withAlpha(25) : MultandoColors.surface200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                badge.icon,
                size: 24,
                color: badge.earned ? color : MultandoColors.surface400,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              badge.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: badge.earned
                    ? MultandoColors.surface900
                    : MultandoColors.surface400,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              rarityLabel(badge.rarity),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: badge.earned ? color : MultandoColors.surface300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
