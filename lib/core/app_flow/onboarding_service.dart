import 'package:hive_flutter/hive_flutter.dart';

class OnboardingService {
  static const String _boxName = 'app_settings';
  static const String _onboardingKey = 'onboarding_completed';
  static const String _inventorySetupKey = 'inventory_setup_completed';
  
  static Box? _box;

  /// Initialize Hive box for app settings
  static Future<void> initialize() async {
    if (_box == null) {
      _box = await Hive.openBox(_boxName);
    }
  }

  /// Check if user has completed onboarding
  static Future<bool> hasCompletedOnboarding() async {
    try {
      await initialize();
      return _box?.get(_onboardingKey, defaultValue: false) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Mark onboarding as completed
  static Future<void> completeOnboarding() async {
    try {
      await initialize();
      await _box?.put(_onboardingKey, true);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Check if user has completed inventory setup
  static Future<bool> hasCompletedInventorySetup() async {
    try {
      await initialize();
      return _box?.get(_inventorySetupKey, defaultValue: false) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Mark inventory setup as completed
  static Future<void> completeInventorySetup() async {
    try {
      await initialize();
      await _box?.put(_inventorySetupKey, true);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Reset onboarding (for testing purposes)
  static Future<void> resetOnboarding() async {
    try {
      await initialize();
      await _box?.delete(_onboardingKey);
      await _box?.delete(_inventorySetupKey);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Close the Hive box when app is disposed
  static Future<void> dispose() async {
    await _box?.close();
    _box = null;
  }
}
