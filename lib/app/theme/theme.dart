import 'package:flutter/material.dart';
import 'colors.dart';

ThemeData buildDarkTheme() {
  final colorScheme = ColorScheme.dark(
    surface: AppColors.bgSurface,
    primary: AppColors.primaryCta,
    secondary: AppColors.secondaryCta,
    background: AppColors.bgScreen,
    error: AppColors.error,
    onPrimary: AppColors.textPrimary,
    onSecondary: AppColors.textPrimary,
    onSurface: AppColors.textPrimary,
    onBackground: AppColors.textPrimary,
    onError: AppColors.textPrimary,
    // Ensure primary color is used for selected navigation items
    primaryContainer: AppColors.primaryCta.withOpacity(0.2),
    onPrimaryContainer: AppColors.textPrimary,
  );

  final textTheme = Typography.whiteMountainView.copyWith(
    headlineSmall: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
    titleMedium: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    bodyLarge: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
    bodyMedium: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
    bodySmall: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bgScreen,
    canvasColor: AppColors.bgSurface,
    colorScheme: colorScheme,
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bgSurface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      margin: const EdgeInsets.all(0),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryCta,
        foregroundColor: AppColors.textPrimary,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.secondaryCta),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.cardSurface.withOpacity(0.6)),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.accentBlue, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    dividerColor: AppColors.cardSurface.withOpacity(0.6),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.primaryCta),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.bgSurface,
      contentTextStyle: TextStyle(color: AppColors.textPrimary),
      behavior: SnackBarBehavior.floating,
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: AppColors.bgSurface,
      indicatorColor: AppColors.primaryCta,
      labelTextStyle: WidgetStatePropertyAll(TextStyle(color: AppColors.textPrimary)),
      iconTheme: WidgetStatePropertyAll(IconThemeData(color: AppColors.textPrimary)),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
  );
}


