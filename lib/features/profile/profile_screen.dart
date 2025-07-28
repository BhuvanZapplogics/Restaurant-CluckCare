import 'package:flutter/material.dart';
import 'package:snack_hack_app/app/theme.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
import 'package:snack_hack_app/features/badges/badge_screen.dart';
import 'package:snack_hack_app/features/profile/settings_screen.dart';
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

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(appStatsProvider);
    print(
      'ProfileScreen stats: points=${stats.points}, streak=${stats.streak}, badges=${stats.earnedBadgeIds}',
    );
    final box = Hive.box('settings');
    final avatarPath = box.get('avatarPath');
    File? avatarFile = avatarPath != null ? File(avatarPath) : null;

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
            Icon(Icons.person, color: AppColors.primaryCTA, size: 28),
            const SizedBox(width: 10),
            Text(
              'PROFILE',
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.background, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Card(
                color: AppColors.secondary.withOpacity(0.95),
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 18,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person,
                            color: AppColors.primaryCTA,
                            size: 32,
                          ),
                          const SizedBox(width: 10),
                          ValueListenableBuilder(
                            valueListenable: Hive.box('settings').listenable(),
                            builder: (context, Box box, _) {
                              return Text(
                                box.get('userName', defaultValue: 'You'),
                                style: const TextStyle(
                                  color: AppColors.textLight,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Keep up the healthy snacking! 🥕',
                        style: TextStyle(
                          color: AppColors.textLight.withOpacity(0.7),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.emoji_events,
                            color: AppColors.primaryCTA,
                            size: 26,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${stats.points}',
                            style: const TextStyle(
                              color: AppColors.primaryCTA,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Icon(
                            Icons.local_fire_department,
                            color: Colors.orange,
                            size: 26,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${stats.streak}',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Card(
                color: AppColors.secondary.withOpacity(0.95),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 10,
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Your Badges',
                        style: TextStyle(
                          color: AppColors.primaryCTA,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildBadgesRow(stats.earnedBadgeIds),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const BadgeScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            color: AppColors.secondaryCTA,
                            size: 20,
                          ),
                          label: const Text('View All Badges'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.secondaryCTA,
                            side: const BorderSide(
                              color: AppColors.secondaryCTA,
                              width: 2,
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final nameController = TextEditingController(
                      text: box.get('userName', defaultValue: 'You'),
                    );
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: AppColors.secondary,
                          title: const Text(
                            'Edit Profile',
                            style: TextStyle(color: AppColors.textLight),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Name',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                await box.put(
                                  'userName',
                                  nameController.text.trim(),
                                );
                                Navigator.of(context).pop();
                              },
                              child: const Text('Save'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryCTA,
                    foregroundColor: AppColors.textLight,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                  icon: const Icon(Icons.settings, color: AppColors.primaryCTA),
                  label: const Text('Settings'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryCTA,
                    side: const BorderSide(
                      color: AppColors.primaryCTA,
                      width: 2,
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgesRow(List<String> earnedBadgeIds) {
    print('Badges to display: $earnedBadgeIds');
    final allBadges = [
      Badge(
        id: 'first_spin',
        name: 'First Spin',
        description: '',
        icon: Icons.star,
        color: Colors.amber,
      ),
      Badge(
        id: 'healthy_snack',
        name: 'Healthy Snack',
        description: '',
        icon: Icons.emoji_food_beverage,
        color: Colors.green,
      ),
      Badge(
        id: 'streak_3',
        name: 'Streak 3+',
        description: '',
        icon: Icons.bolt,
        color: Colors.orange,
      ),
      Badge(
        id: 'proof_5',
        name: 'Proof Master',
        description: '',
        icon: Icons.camera_alt,
        color: Colors.blue,
      ),
      Badge(
        id: 'challenge_10',
        name: 'Snack Pro',
        description: '',
        icon: Icons.emoji_events,
        color: Colors.purple,
      ),
    ];
    final earnedBadges = allBadges
        .where((b) => earnedBadgeIds.contains(b.id))
        .toList();
    if (earnedBadges.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 56,
            color: AppColors.secondaryCTA.withOpacity(0.7),
          ),
          const SizedBox(height: 10),
          Text(
            'No badges yet.',
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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

Color _dialogTitleColor(BuildContext context, {bool danger = false}) =>
    danger ? Colors.red : Theme.of(context).primaryColor;
