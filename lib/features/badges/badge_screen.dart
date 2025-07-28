import 'package:flutter/material.dart';
import 'package:snack_hack_app/app/theme.dart';
import 'package:hive/hive.dart';

class Badge {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final bool earned;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.earned = false,
  });
}

class BadgeScreen extends StatefulWidget {
  const BadgeScreen({super.key});

  @override
  State<BadgeScreen> createState() => _BadgeScreenState();
}

class _BadgeScreenState extends State<BadgeScreen> {
  late Future<List<String>> _earnedBadgesFuture;

  @override
  void initState() {
    super.initState();
    _earnedBadgesFuture = _getEarnedBadges();
  }

  Future<List<String>> _getEarnedBadges() async {
    final box = await Hive.openBox('earned_badges');
    return List<String>.from(box.get('badges', defaultValue: <String>[]));
  }

  List<Badge> _allBadges(List<String> earnedBadgeIds) => [
    Badge(
      id: 'first_spin',
      name: 'First Spin',
      description: 'Spin the wheel for the first time.',
      icon: Icons.star,
      color: Colors.amber,
      earned: earnedBadgeIds.contains('first_spin'),
    ),
    Badge(
      id: 'healthy_snack',
      name: 'Healthy Snack',
      description: 'Submit proof of a healthy snack.',
      icon: Icons.emoji_food_beverage,
      color: Colors.green,
      earned: earnedBadgeIds.contains('healthy_snack'),
    ),
    Badge(
      id: 'streak_3',
      name: 'Streak 3+',
      description: 'Complete 3 challenges in a row.',
      icon: Icons.bolt,
      color: Colors.orange,
      earned: earnedBadgeIds.contains('streak_3'),
    ),
    Badge(
      id: 'proof_5',
      name: 'Proof Master',
      description: 'Submit proof 5 times.',
      icon: Icons.camera_alt,
      color: Colors.blue,
      earned: earnedBadgeIds.contains('proof_5'),
    ),
    Badge(
      id: 'challenge_10',
      name: 'Snack Pro',
      description: 'Complete 10 challenges.',
      icon: Icons.emoji_events,
      color: Colors.purple,
      earned: earnedBadgeIds.contains('challenge_10'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events, color: AppColors.primaryCTA, size: 20),
            const SizedBox(width: 10),
            Text(
              'BADGES',
              style: const TextStyle(
                color: AppColors.textLight,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Expanded(
                child: FutureBuilder<List<String>>(
                  future: _earnedBadgesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final earnedBadgeIds = snapshot.data ?? <String>[];
                    final badges = _allBadges(earnedBadgeIds);
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1,
                          ),
                      itemCount: badges.length,
                      itemBuilder: (context, index) {
                        final badge = badges[index];
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                          decoration: BoxDecoration(
                            boxShadow: badge.earned
                                ? [
                                    BoxShadow(
                                      color: badge.color.withOpacity(0.35),
                                      blurRadius: 16,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : [],
                          ),
                          child: _buildBadgeCard(badge),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeCard(Badge badge) {
    return Card(
      color: badge.earned ? badge.color.withOpacity(0.15) : AppColors.secondary,
      elevation: badge.earned ? 6 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    CircleAvatar(
                      backgroundColor: badge.earned
                          ? badge.color
                          : Colors.grey[400],
                      radius: 28,
                      child: Icon(badge.icon, color: Colors.white, size: 32),
                    ),
                    if (badge.earned)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: CircleAvatar(
                          radius: 11,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.check_circle,
                            color: badge.color,
                            size: 18,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  badge.name,
                  style: TextStyle(
                    color: badge.earned ? badge.color : Colors.grey[400],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  badge.description,
                  style: TextStyle(
                    color: badge.earned
                        ? AppColors.textLight
                        : Colors.grey[500],
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
