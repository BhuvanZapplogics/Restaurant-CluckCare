import 'package:flutter/material.dart';

class ReceiptScreen extends StatelessWidget {
  final String orderId;
  const ReceiptScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receipt')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Receipt for Order #$orderId'),
            const SizedBox(height: 12),
            const Text('Printable PDF preview will appear here.'),
          ],
        ),
      ),
    );
  }
}

























