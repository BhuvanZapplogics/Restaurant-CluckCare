import 'onboarding_service.dart';

/// Debug helper for testing onboarding flow
class DebugHelper {
  /// Reset onboarding to test the flow again
  static Future<void> resetOnboarding() async {
    await OnboardingService.resetOnboarding();
  }
  
  /// Check if onboarding is completed
  static Future<bool> isOnboardingCompleted() async {
    return await OnboardingService.hasCompletedOnboarding();
  }

  /// Initialize Hive (for testing)
  static Future<void> initializeHive() async {
    await OnboardingService.initialize();
  }
}
