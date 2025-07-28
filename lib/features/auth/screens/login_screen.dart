import 'dart:convert'; // For hashing
import 'package:crypto/crypto.dart'; // For hashing, add to pubspec.yaml
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:snack_hack_app/features/auth/widgets/custome_widget.dart';
import 'package:snack_hack_app/app/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _error = false;
  bool _loading = false; // ADDED

  // Hash password (same as signup)
  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }

  Future<void> _loginUser() async {
    setState(() {
      _loading = true;
      _error = false;
    });

    try {
      final usersBox = await Hive.openBox('users');
      final user = usersBox.get(emailController.text.trim());

      if (user != null &&
          user['password'] == _hashPassword(passwordController.text.trim())) {
        // Store logged-in user info locally
        final settingsBox = await Hive.openBox('settings');
        await settingsBox.put('loggedInUser', emailController.text.trim());
        await settingsBox.put('userName', user['name'] ?? '');

        if (!mounted) return;

        context.go('/nav');
      } else {
        setState(() => _error = true);
      }
    } catch (e) {
      setState(() => _error = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.login, color: AppColors.primaryCTA, size: 28),
            const SizedBox(width: 10),
            Text(
              'LOGIN',
              style: const TextStyle(
                color: AppColors.textLight,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                // Playful icon header
                Center(
                  child: Icon(
                    Icons.fingerprint,
                    size: 64,
                    color: AppColors.primaryCTA,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Welcome Back!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Log in to continue your healthy snack adventure.',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  controller: emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!_isValidEmail(value.trim())) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: passwordController,
                  label: 'Password',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                ),
                if (_error)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Invalid credentials",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 24),
                _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryCTA,
                        ),
                      )
                    : SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _loginUser();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryCTA,
                            foregroundColor: AppColors.textLight,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Login'),
                        ),
                      ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.push('/signup'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.secondaryCTA,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  child: const Text("Don't have an account? Sign up"),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () async {
                      final settingsBox = await Hive.openBox('settings');
                      await settingsBox.put('isGuest', true);
                      if (!mounted) return;
                      context.go('/nav');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondaryCTA,
                      side: BorderSide(color: AppColors.secondaryCTA),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    child: const Text('Continue as Guest'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
