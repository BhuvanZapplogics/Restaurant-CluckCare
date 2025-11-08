import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Test asset loading
  try {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    print('Asset manifest loaded successfully');
    
    // Check for specific assets
    final assets = <String>[];
    final manifest = json.decode(manifestContent) as Map<String, dynamic>;
    
    for (final key in manifest.keys) {
      if (key.contains('menu')) {
        assets.add(key);
      }
    }
    
    print('Found ${assets.length} menu assets:');
    for (final asset in assets.take(10)) {
      print('  - $asset');
    }
    
  } catch (e) {
    print('Error loading assets: $e');
  }
}



