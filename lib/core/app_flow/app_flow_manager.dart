import 'package:flutter/material.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/restaurant/presentation/restaurant_screen.dart';
import '../../app/theme/theme.dart';

class AppFlowManager extends StatefulWidget {
  const AppFlowManager({super.key});

  @override
  State<AppFlowManager> createState() => _AppFlowManagerState();
}

class _AppFlowManagerState extends State<AppFlowManager> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Juste Fried Chicken',
      debugShowCheckedModeBanner: false,
      theme: buildDarkTheme(),
      home: const SplashScreen(),
      routes: {
        '/restaurant': (context) => const RestaurantScreen(),
      },
    );
  }
}
