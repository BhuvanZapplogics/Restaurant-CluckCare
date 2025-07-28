import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:snack_hack_app/app/theme.dart'; // <-- Import your theme
import 'package:snack_hack_app/core/services/challenge_service.dart';
import 'package:snack_hack_app/core/services/badge_service.dart';
import 'package:snack_hack_app/core/services/challenge_submission_service.dart';
import 'package:hive/hive.dart';

class SpinScreen extends StatefulWidget {
  const SpinScreen({super.key});

  @override
  State<SpinScreen> createState() => SpinScreenState();
}

class SpinScreenState extends State<SpinScreen> {
  final StreamController<int> _selected = StreamController<int>();
  int? _lastSelectedIndex;
  bool _isSpinning = false;
  String? _selectedOption;

  final List<String> _options = [
    'Apple',
    'Carrot',
    'Yogurt',
    'Nuts',
    'Banana',
    'Hummus',
    'Berries',
  ];

  final List<Color> _segmentColors = [
    Color(0xFF8F00FF), // Violet
    Color(0xFF4B0082), // Indigo
    Color(0xFF0000FF), // Blue
    Color(0xFF00FF00), // Green
    Color(0xFFFFFF00), // Yellow
    Color(0xFFFF7F00), // Orange
    Color(0xFFFF0000), // Red
  ];

  static const int maxSpinsPerDay = 10;
  int _spinsToday = 0;
  bool _challengeAccepted = false;
  String? _spinsMessage;

  @override
  void initState() {
    super.initState();
    _loadSpinState();
  }

  Future<void> _loadSpinState() async {
    await ChallengeService.resetSpinsIfNewDay();
    final spins = await ChallengeService.getSpinsToday();
    final challenge = await ChallengeService.getTodaysChallenge();
    setState(() {
      _spinsToday = spins;
      _challengeAccepted = challenge != null;
      _spinsMessage = _challengeAccepted
          ? 'Challenge already accepted today.'
          : (_spinsToday >= maxSpinsPerDay
                ? 'No spins left for today.'
                : 'You have ${maxSpinsPerDay - _spinsToday} spins left today.');
    });
  }

  Future<void> refresh() async {
    await _loadSpinState();
  }

  @override
  void dispose() {
    _selected.close();
    super.dispose();
  }

  void _spinWheel() async {
    if (_isSpinning || _spinsToday >= maxSpinsPerDay || _challengeAccepted) {
      return;
    }
    setState(() {
      _isSpinning = true;
      _selectedOption = null;
    });
    await ChallengeService.incrementSpinsToday();
    await _loadSpinState();
    final index = Fortune.randomInt(0, _options.length);
    _selected.add(index);
    _lastSelectedIndex = index;
  }

  String? _getSelectedOption() {
    if (_lastSelectedIndex == null) return null;
    return _options[_lastSelectedIndex!];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.casino, color: AppColors.primaryCTA, size: 28),
            const SizedBox(width: 10),
            Text(
              'SPIN THE WHEEL',
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
        color: AppColors.background, // Use your theme background
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                // Result display
                if (_getSelectedOption() != null && !_isSpinning)
                  AnimatedScale(
                    scale: 1.0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.elasticOut,
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryCTA.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: AppColors.primaryCTA,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryCTA.withOpacity(0.12),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: AppColors.secondaryCTA,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _getSelectedOption()!,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primaryCTA,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _challengeAccepted
                                ? null
                                : () async {
                                    if (_getSelectedOption() == null) return;
                                    final entry = ChallengeEntry(
                                      challengeText: _getSelectedOption()!,
                                      date: DateTime.now(),
                                      modifiers: [],
                                      completed: false,
                                    );
                                    await ChallengeService.saveTodaysChallenge(
                                      entry,
                                    );
                                    // Award badges after accepting a challenge
                                    final spinsToday =
                                        await ChallengeService.getSpinsToday();
                                    final streak =
                                        await ChallengeService.getStreak();
                                    final points =
                                        await ChallengeService.getPoints();
                                    // Get all submissions for proof count and healthy snack
                                    final submissions =
                                        await ChallengeSubmissionService.getAllSubmissions();
                                    final proofCount = submissions.length;
                                    // Assume a healthy snack submission has tag 'healthy' in tags
                                    final healthySnackSubmitted = submissions
                                        .any((s) => s.tags.contains('healthy'));
                                    // Count completed challenges
                                    final box = await Hive.openBox(
                                      'challenges',
                                    );
                                    final completedChallenges = box.values
                                        .where(
                                          (e) =>
                                              (e
                                                  as Map<
                                                    String,
                                                    dynamic
                                                  >)['completed'] ==
                                              true,
                                        )
                                        .length;
                                    print(
                                      'DEBUG: spinsToday= [38;5;2m$spinsToday [39m, awarding first_spin= [38;5;2m${spinsToday >= 1} [39m',
                                    );
                                    await BadgeService.checkAndAwardBadges(
                                      totalSpins: spinsToday,
                                      streak: streak,
                                      proofCount: proofCount,
                                      completedChallenges: completedChallenges,
                                      healthySnackSubmitted:
                                          healthySnackSubmitted,
                                    );
                                    await _loadSpinState();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondaryCTA,
                              foregroundColor: AppColors.textDark,
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text('Accept Challenge'),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),
                // Wheel container with pointer (FortuneWheel)
                SizedBox(
                  width: 320,
                  height: 320,
                  child: FortuneWheel(
                    selected: _selected.stream,
                    animateFirst: false,
                    indicators: const <FortuneIndicator>[
                      FortuneIndicator(
                        alignment: Alignment.topCenter,
                        child: TriangleIndicator(color: Colors.yellowAccent),
                      ),
                    ],
                    items: [
                      for (int i = 0; i < _options.length; i++)
                        FortuneItem(
                          child: Text(
                            _options[i],
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          style: FortuneItemStyle(
                            color: _segmentColors[i % _segmentColors.length],
                            borderColor: Colors.white,
                            borderWidth: 2,
                          ),
                        ),
                    ],
                    onAnimationEnd: () {
                      setState(() {
                        _isSpinning = false;
                        _selectedOption = _getSelectedOption();
                      });
                    },
                  ),
                ),

                const SizedBox(height: 24),
                // Spins left message
                if (_spinsMessage != null &&
                    !_challengeAccepted &&
                    _spinsToday < maxSpinsPerDay)
                  Text.rich(
                    TextSpan(
                      text: 'You have ',
                      style: TextStyle(
                        color: AppColors.primaryCTA,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      children: [
                        TextSpan(
                          text: '${maxSpinsPerDay - _spinsToday}',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.secondaryCTA,
                          ),
                        ),
                        const TextSpan(text: ' spins left today.'),
                      ],
                    ),
                  )
                else if (_spinsMessage != null)
                  Text(
                    _spinsMessage!,
                    style: TextStyle(
                      color: _spinsToday >= maxSpinsPerDay || _challengeAccepted
                          ? Colors.redAccent
                          : AppColors.primaryCTA,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                const SizedBox(height: 24),

                // Spin button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed:
                        _isSpinning ||
                            _spinsToday >= maxSpinsPerDay ||
                            _challengeAccepted
                        ? null
                        : _spinWheel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isSpinning ||
                              _spinsToday >= maxSpinsPerDay ||
                              _challengeAccepted
                          ? Colors.grey
                          : AppColors.primaryCTA,
                      foregroundColor: AppColors.textLight,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: _isSpinning ? 0 : 4,
                      shadowColor: AppColors.primary.withOpacity(0.3),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        if (_isSpinning)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        else
                          const Icon(Icons.rotate_right, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          _isSpinning
                              ? 'Spinning...'
                              : _spinsToday >= maxSpinsPerDay
                              ? 'No Spins Left'
                              : _challengeAccepted
                              ? 'Challenge Accepted'
                              : 'Spin the Wheel',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
