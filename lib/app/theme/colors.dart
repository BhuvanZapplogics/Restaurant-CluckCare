import 'package:flutter/material.dart';

/// PRD canonical dark-mode color tokens for Juste Fried Chicken
/// Keep these as the single source of truth for colors across the app.
class AppColors {
  // Backgrounds
  static const Color bgScreen = Color(0xFF151723); // --color-bg-screen (Scaffold background)
  static const Color bgSurface = Color(0xFF3B3C51); // --color-bg-surface (AppBar & NavBar)
  static const Color cardSurface = Color(0xFF3A3D50); // --color-card-surface (global)
  static const Color inventoryCardSurface = Color(0xFF3A3E5C); // specific to Inventory screens

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF); // --color-text-primary
  static const Color textSecondary = Color(0xFFB0B3C6); // --color-text-secondary
  
  // Borders
  static const Color border = Color(0xFF4A4E6B); // --color-border

  // CTAs & Status
  static const Color primaryCta = Color(0xFF4CAF50); // --color-primary-cta
  static const Color secondaryCta = Color(0xFFFBC02D); // --color-secondary-cta
  static const Color success = Color(0xFF4CAF50); // --color-success
  static const Color warning = Color(0xFFFFC107); // --color-warning
  static const Color error = Color(0xFFFF5252); // --color-error
  static const Color accentBlue = Color(0xFF5C6BC0); // --color-accent-blue
}


