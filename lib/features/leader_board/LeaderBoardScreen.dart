export 'package:snack_hack_app/features/leader_board/LeaderBoardScreen.dart'
    show LeaderBoardScreen, _LeaderBoardScreenState;
import 'package:flutter/material.dart';
import 'package:snack_hack_app/app/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snack_hack_app/providers/app_stats_provider.dart';

// Badge model for use in this file
class Badge {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(appStatsProvider);
    print(
      'LeaderBoardScreen stats: points=${stats.points}, streak=${stats.streak}, badges=${stats.earnedBadgeIds}',
    );

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
            Icon(Icons.bar_chart, color: AppColors.primaryCTA, size: 28),
            const SizedBox(width: 10),
            Text(
              'STATISTICS',
              style: const TextStyle(
                color: AppColors.textLight,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Card(
                color: AppColors.secondary,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.emoji_events,
                            color: AppColors.primaryCTA,
                            size: 36,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Your Stats",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textLight,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildStatRow(
                        "Total Points",
                        stats.points,
                        Icons.emoji_events,
                        AppColors.primaryCTA,
                      ),
                      const SizedBox(height: 16),
                      _buildStatRow(
                        "Current Streak",
                        stats.streak,
                        Icons.local_fire_department,
                        Colors.orange,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Badges Preview
              Text(
                "Your Badges",
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 12),
              _buildBadgesRow(stats.earnedBadgeIds),
              const SizedBox(height: 32),
              const Text(
                "Keep going! Complete more challenges to earn more badges.",
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    int value,
    IconData icon,
    Color iconColor,
  ) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 32),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value.toString(),
          style: const TextStyle(
            color: AppColors.textLight,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Copy badge definitions here for reuse
  List<Badge> getAllBadges() => [
    Badge(
      id: 'first_spin',
      name: 'First Spin',
      description: 'Spin the wheel for the first time.',
      icon: Icons.star,
      color: Colors.amber,
    ),
    Badge(
      id: 'healthy_snack',
      name: 'Healthy Snack',
      description: 'Submit proof of a healthy snack.',
      icon: Icons.emoji_food_beverage,
      color: Colors.green,
    ),
    Badge(
      id: 'streak_3',
      name: 'Streak 3+',
      description: 'Complete 3 challenges in a row.',
      icon: Icons.bolt,
      color: Colors.orange,
    ),
    Badge(
      id: 'proof_5',
      name: 'Proof Master',
      description: 'Submit proof 5 times.',
      icon: Icons.camera_alt,
      color: Colors.blue,
    ),
    Badge(
      id: 'challenge_10',
      name: 'Snack Pro',
      description: 'Complete 10 challenges.',
      icon: Icons.emoji_events,
      color: Colors.purple,
    ),
  ];

  Widget _buildBadgesRow(List<String> earnedBadgeIds) {
    final allBadges = getAllBadges();
    final earnedBadges = allBadges
        .where((b) => earnedBadgeIds.contains(b.id))
        .toList();
    if (earnedBadges.isEmpty) {
      return const Center(
        child: Text(
          'No badges yet.',
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: earnedBadges
          .map(
            (badge) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Tooltip(
                message: badge.name,
                child: CircleAvatar(
                  backgroundColor: badge.color.withOpacity(0.15),
                  radius: 24,
                  child: Icon(badge.icon, color: badge.color, size: 28),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
