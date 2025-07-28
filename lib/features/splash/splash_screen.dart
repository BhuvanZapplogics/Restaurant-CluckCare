import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:go_router/go_router.dart';
import 'package:snack_hack_app/app/theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    _initLogic();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initLogic() async {
    await Future.delayed(const Duration(seconds: 3));
    final settingsBox = await Hive.openBox('settings');
    final forceLogin = settingsBox.get('forceLogin', defaultValue: false);
    if (forceLogin) {
      await settingsBox.put('forceLogin', false);
      context.go('/login');
      return;
    }
    final isFirstLaunch = settingsBox.get('isFirstLaunch', defaultValue: true);
    final loggedInUser = settingsBox.get('loggedInUser');
    if (isFirstLaunch) {
      context.go('/onboarding');
    } else if (loggedInUser != null) {
      context.go('/nav');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _fadeAnim,
              child: Text(
                'SnackHack',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryCTA,
                  letterSpacing: 2.0,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              color: AppColors.primaryCTA,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
