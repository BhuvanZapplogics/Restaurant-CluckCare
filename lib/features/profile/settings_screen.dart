import 'package:flutter/material.dart';
import 'package:snack_hack_app/app/theme.dart';
import 'package:hive/hive.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _vegetarian = false;
  bool _loading = true;
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final box = await Hive.openBox('settings');
    setState(() {
      _vegetarian = box.get('vegetarian', defaultValue: false);
      _darkMode = box.get('darkMode', defaultValue: false);
      _loading = false;
    });
  }

  Future<void> _saveSettings() async {
    final box = await Hive.openBox('settings');
    await box.put('vegetarian', _vegetarian);
    await box.put('darkMode', _darkMode);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Settings saved!')));
  }

  Future<void> _resetAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent,
              size: 28,
            ),
            const SizedBox(width: 10),
            const Text(
              'Reset All Data',
              style: TextStyle(color: AppColors.textLight),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to reset all app data? This cannot be undone.',
          style: TextStyle(color: AppColors.textLight, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.secondaryCTA,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        print('Reset: Closing and deleting all boxes...');
        // Robustly close and delete each box
        for (final boxName in [
          'users',
          'challenge_submissions',
          'challenges',
          'progress',
          'earned_badges',
        ]) {
          try {
            if (Hive.isBoxOpen(boxName)) {
              await Hive.box(boxName).close();
            }
          } catch (e) {
            print('Box $boxName close error: $e');
          }
          try {
            await Hive.deleteBoxFromDisk(boxName);
          } catch (e) {
            print('Box $boxName delete error: $e');
          }
        }
        print('Reset: Boxes deleted. Clearing settings...');
        // Debug: Check spinsToday after reset
        final spins = await Hive.openBox('progress');
        final todayKey =
            'spins_${DateTime.now().year.toString().padLeft(4, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';
        print(
          'DEBUG after reset: spinsToday = ${spins.get(todayKey, defaultValue: 0)}',
        );
        final settingsBox = await Hive.openBox('settings');
        await settingsBox.clear();
        await settingsBox.put('forceLogin', true);
        print(
          'Reset: Settings cleared and forceLogin set. Navigating to login...',
        );
        if (mounted) {
          context.go('/login');
        }
        setState(() {
          _vegetarian = false;
          _darkMode = false;
        });
      } catch (e, stack) {
        print('Reset error: $e');
        print(stack);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Reset failed: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
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
            Icon(Icons.settings, color: AppColors.primaryCTA, size: 26),
            const SizedBox(width: 10),
            Text(
              'SETTINGS',
              style: const TextStyle(
                color: AppColors.textLight,
                fontSize: 20,
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
              Card(
                color: AppColors.secondary,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: SwitchListTile(
                  value: _vegetarian,
                  onChanged: (val) => setState(() => _vegetarian = val),
                  title: Row(
                    children: [
                      Icon(Icons.eco, color: AppColors.primaryCTA),
                      const SizedBox(width: 8),
                      const Text(
                        'Vegetarian',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  activeColor: AppColors.primaryCTA,
                  inactiveThumbColor: Colors.grey[400],
                  inactiveTrackColor: Colors.grey[700],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
              const SizedBox(height: 18),
              // Allergies field removed
              const SizedBox(height: 18),
              Card(
                color: AppColors.secondary,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: SwitchListTile(
                  value: _darkMode,
                  onChanged: (val) => setState(() => _darkMode = val),
                  title: Row(
                    children: [
                      Icon(Icons.dark_mode, color: AppColors.primaryCTA),
                      const SizedBox(width: 8),
                      const Text(
                        'Dark Mode',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  activeColor: AppColors.primaryCTA,
                  inactiveThumbColor: Colors.grey[400],
                  inactiveTrackColor: Colors.grey[700],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryCTA,
                    foregroundColor: AppColors.textLight,
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: const Text('Save Settings'),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _resetAllData,
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  label: const Text('Reset All Data'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red, width: 2),
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
              const SizedBox(height: 32),
              // Logout button (filled, prominent)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.logout, color: Colors.white, size: 28),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 3,
                  ),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                          'Logout',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        content: const Text(
                          'Are you sure you want to logout?',
                          style: TextStyle(color: Colors.black87),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(
                              'Logout',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      final settingsBox = await Hive.openBox('settings');
                      await settingsBox.delete('loggedInUser');
                      await settingsBox.delete('userName');
                      await settingsBox.delete('isGuest');
                      if (context.mounted) {
                        context.go('/login');
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Delete Account button (filled, prominent)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: const Icon(
                    Icons.delete_forever,
                    color: Colors.white,
                    size: 28,
                  ),
                  label: const Text('Delete Account'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 3,
                  ),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text(
                          'Delete Account',
                          style: TextStyle(color: Colors.red),
                        ),
                        content: const Text(
                          'This will permanently delete your account and all data. Are you sure?',
                          style: TextStyle(color: Colors.black87),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text(
                              'Delete',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      final settingsBox = await Hive.openBox('settings');
                      final usersBox = await Hive.openBox('users');
                      final email = settingsBox.get('loggedInUser');
                      if (email != null) {
                        await usersBox.delete(email);
                      }
                      // Delete all user-related data from other boxes
                      for (final boxName in [
                        'challenge_submissions',
                        'challenges',
                        'progress',
                        'earned_badges',
                      ]) {
                        try {
                          if (Hive.isBoxOpen(boxName)) {
                            await Hive.box(boxName).clear();
                          } else {
                            final box = await Hive.openBox(boxName);
                            await box.clear();
                          }
                        } catch (e) {
                          print('Delete Account: Error clearing $boxName: $e');
                        }
                      }
                      await settingsBox.delete('loggedInUser');
                      await settingsBox.delete('userName');
                      await settingsBox.delete('isGuest');
                      if (context.mounted) {
                        context.go('/login');
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
