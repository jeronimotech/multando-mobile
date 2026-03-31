import 'package:flutter/material.dart';

/// Brand and semantic color constants used throughout the Multando app.
class MultandoColors {
  MultandoColors._();

  // Brand
  static const Color brandRed = Color(0xFFE63946);
  static const Color brandRedLight = Color(0xFFFF6B6B);
  static const Color brandRedDark = Color(0xFFB71C2C);

  // Accent
  static const Color accentGold = Color(0xFFF59E0B);
  static const Color accentGoldLight = Color(0xFFFBBF24);
  static const Color accentGoldDark = Color(0xFFD97706);

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF6EE7B7);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFFCA5A5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Surface / Neutral
  static const Color surface50 = Color(0xFFF8FAFC);
  static const Color surface100 = Color(0xFFF1F5F9);
  static const Color surface200 = Color(0xFFE2E8F0);
  static const Color surface300 = Color(0xFFCBD5E1);
  static const Color surface400 = Color(0xFF94A3B8);
  static const Color surface500 = Color(0xFF64748B);
  static const Color surface600 = Color(0xFF475569);
  static const Color surface700 = Color(0xFF334155);
  static const Color surface800 = Color(0xFF1E293B);
  static const Color surface900 = Color(0xFF0F172A);

  // Status colors for reports
  static const Color statusDraft = Color(0xFF94A3B8);
  static const Color statusSubmitted = Color(0xFF3B82F6);
  static const Color statusUnderReview = Color(0xFFF59E0B);
  static const Color statusVerified = Color(0xFF10B981);
  static const Color statusRejected = Color(0xFFEF4444);
  static const Color statusAppealed = Color(0xFF8B5CF6);
  static const Color statusResolved = Color(0xFF06B6D4);

  // Badge rarity
  static const Color rarityCommon = Color(0xFF94A3B8);
  static const Color rarityUncommon = Color(0xFF10B981);
  static const Color rarityRare = Color(0xFF3B82F6);
  static const Color rarityEpic = Color(0xFF8B5CF6);
  static const Color rarityLegendary = Color(0xFFF59E0B);
}
