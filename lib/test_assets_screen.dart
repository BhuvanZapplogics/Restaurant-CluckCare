import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class TestAssetsScreen extends StatefulWidget {
  const TestAssetsScreen({super.key});

  @override
  State<TestAssetsScreen> createState() => _TestAssetsScreenState();
}

class _TestAssetsScreenState extends State<TestAssetsScreen> {
  List<String> menuAssets = [];

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final manifest = json.decode(manifestContent) as Map<String, dynamic>;
      
      final assets = <String>[];
      for (final key in manifest.keys) {
        if (key.contains('menu') && key.endsWith('.png')) {
          assets.add(key);
        }
      }
      
      setState(() {
        menuAssets = assets;
      });
    } catch (e) {
      print('Error loading assets: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Assets')),
      body: ListView.builder(
        itemCount: menuAssets.length,
        itemBuilder: (context, index) {
          final asset = menuAssets[index];
          return ListTile(
            title: Text(asset),
            trailing: Image.asset(
              asset,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error, color: Colors.red);
              },
            ),
          );
        },
      ),
    );
  }
}






















