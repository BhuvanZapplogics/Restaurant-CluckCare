import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'app/router.dart';
import 'app/theme.dart'; // ✅ Import the AppTheme

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path); // <-- ✅
  runApp(const ProviderScope(child: SnackHackApp()));
}

class SnackHackApp extends StatelessWidget {
  const SnackHackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'SnackHack',
      theme: AppTheme.lightTheme, // ✅ Applying custom theme here
      routerConfig:
          appRouter, // <-- Use the actual router config object, not a string
    );
  }
}
