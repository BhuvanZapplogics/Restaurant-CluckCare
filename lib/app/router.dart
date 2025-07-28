import 'package:go_router/go_router.dart';
import 'package:snack_hack_app/features/auth/screens/login_screen.dart';
import 'package:snack_hack_app/features/auth/screens/sign_up_screen.dart';
import 'package:snack_hack_app/features/badges/badge_screen.dart';
import 'package:snack_hack_app/features/home/home_screen.dart';
import 'package:snack_hack_app/features/navigation/nav_screen.dart';
import 'package:snack_hack_app/features/onboarding/onboarding_screen.dart';
import 'package:snack_hack_app/features/spin/SpinScreen.dart';
import 'package:snack_hack_app/features/splash/splash_screen.dart';
import 'package:snack_hack_app/features/leader_board/LeaderBoardScreen.dart'
    show StatisticsScreen;

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(path: '/nav', builder: (context, state) => const NavScreen()),
    GoRoute(path: '/spin', builder: (context, state) => const SpinScreen()),
    GoRoute(path: '/badges', builder: (context, state) => const BadgeScreen()),
    GoRoute(
      path: '/statistics',
      builder: (context, state) => const StatisticsScreen(),
    ),
  ],
  redirect: (context, state) {
    // Handle any redirects if needed
    return null;
  },
);
