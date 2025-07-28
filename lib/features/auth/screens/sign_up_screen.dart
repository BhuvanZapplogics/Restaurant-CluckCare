import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:snack_hack_app/features/auth/widgets/custome_widget.dart';
import 'package:snack_hack_app/app/theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String? _error;
  bool _loading = false;

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }

  bool _isStrongPassword(String password) {
    // At least 6 chars, 1 number, 1 letter
    return password.length >= 6 &&
        RegExp(r'[A-Za-z]').hasMatch(password) &&
        RegExp(r'\d').hasMatch(password);
  }

  Future<void> _signupUser() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final usersBox = await Hive.openBox('users');
      final email = emailController.text.trim();

      if (usersBox.containsKey(email)) {
        setState(() {
          _error = 'Email already exists';
          _loading = false;
        });
        return;
      }

      final hashedPassword = _hashPassword(passwordController.text.trim());

      await usersBox.put(email, {
        'name': nameController.text.trim(),
        'password': hashedPassword,
      });

      // Store logged-in user info locally (auto-login)
      final settingsBox = await Hive.openBox('settings');
      await settingsBox.put('loggedInUser', email);
      await settingsBox.put('userName', nameController.text.trim());

      if (!mounted) return;
      context.go('/nav');
    } catch (e) {
      setState(() {
        _error = 'Signup failed. Please try again.';
      });
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
            Icon(Icons.person_add, color: AppColors.primaryCTA, size: 28),
            const SizedBox(width: 10),
            Text(
              'SIGN UP',
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
                Center(
                  child: Icon(
                    Icons.person_add,
                    size: 64,
                    color: AppColors.primaryCTA,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Create Account',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Join SnackHack and start your healthy snack adventure!',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                CustomTextField(controller: nameController, label: 'Full Name'),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!_isValidEmail(value.trim())) {
                      return 'Enter a valid email (e.g., example@gmail.com)';
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
                    if (!_isStrongPassword(value.trim())) {
                      return 'Password must be at least 6 characters and include a number and a letter';
                    }
                    return null;
                  },
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _error!,
                      style: const TextStyle(
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
                              _signupUser();
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
                          child: const Text('Sign Up'),
                        ),
                      ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go('/login'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.secondaryCTA,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  child: const Text('Already have an account? Login'),
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
