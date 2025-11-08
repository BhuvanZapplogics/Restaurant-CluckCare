import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/app_flow/app_flow_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'services/providers/in_app_purchase_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Ensure Hive is properly initialized
  print('Hive initialized successfully');
  
  runApp(
    provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider(create: (_) => InAppPurchaseProvider()),
      ],
      child: const ProviderScope(child: AppFlowManager()),
    ),
  );
}
 
