import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';

class OrderDetailsScreen extends StatelessWidget {
  final dynamic order; // expects OrderModel-like object
  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final items = _coerceOrderItems(order);
    final int totalItems = items.fold<int>(0, (sum, it) => sum + (it['quantity'] as int));
    final double computedSubtotal = items.fold<double>(0.0, (sum, it) => sum + ((it['price'] as double) * (it['quantity'] as int)));
    const double serviceRate = 0.03; // 3%
    final double serviceCharge = computedSubtotal * serviceRate;
    final double grandTotal = computedSubtotal + serviceCharge;

    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      appBar: AppBar(
        title: const Text('Order details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // When order details is reached directly after completing payment,
            // ensure the user can navigate back to the main app (home tabs)
            Navigator.of(context).maybePop();
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header card
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child: _buildItemLeading(order.thumbnailUrl as String?),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Proceed To Billing', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(_formatDateTime(order.createdAt), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _chip(order.type == 'dine_in' ? 'Dine-in' : 'Takeaway', order.type == 'dine_in' ? Colors.blue : Colors.purple),
                            if (order.type == 'dine_in' && order.tableNumber != null)
                              _chip('Table ${order.tableNumber}', Colors.orange),
                            // Payment chip removed per requirements
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.green.shade500, Colors.green.shade700]),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Colors.green.shade200, blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Text('₺${grandTotal.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          // Items
          const SizedBox(height: 8),
          Text('Items', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final it = items[i];
                final qty = it['quantity'] as int;
                final unit = it['price'] as double;
                final total = unit * qty;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: _buildItemLeading(it['imageUrl'] as String?),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            it['name'] as String,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text('Qty: $qty • ₺${unit.toStringAsFixed(0)} each', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('₺${total.toStringAsFixed(0)}', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 16),
          // Subtotal section
          const SizedBox(height: 16),
          Text('Summary', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _totalRow(label: 'Items', value: '$totalItems'),
                  const SizedBox(height: 6),
                  _totalRow(label: 'Subtotal', value: '₺${computedSubtotal.toStringAsFixed(0)}'),
                  const SizedBox(height: 6),
                  _totalRow(label: 'Service charge (3%)', value: '₺${serviceCharge.toStringAsFixed(0)}'),
                  const SizedBox(height: 6),
                  const Divider(height: 20),
                  _totalRow(label: 'Grand total', value: '₺${grandTotal.toStringAsFixed(0)}', isEmphasis: true),
                ],
              ),
            ),
          ),

          // Removed payment method footer per requirements
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}/${two(dt.month)}/${dt.year} • ${two(dt.hour)}:${two(dt.minute)}';
  }

  Widget _totalRow({required String label, required String value, bool isEmphasis = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isEmphasis ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isEmphasis ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildItemLeading(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const CircleAvatar(child: Icon(Icons.fastfood));
    }
    final isAsset = !(imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: isAsset
            ? Image.asset(imageUrl, fit: BoxFit.contain)
            : Image.network(imageUrl, fit: BoxFit.contain),
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color.withOpacity(0.9), fontWeight: FontWeight.w700, fontSize: 11),
      ),
    );
  }

  List<Map<String, dynamic>> _coerceOrderItems(dynamic order) {
    final List<Map<String, dynamic>> out = [];
    try {
      final raw = order.items as List<dynamic>? ?? const [];
      for (final it in raw) {
        if (it is Map) {
          final m = Map<String, dynamic>.from(it);
          out.add({
            'id': (m['id'] ?? '').toString(),
            'name': (m['name'] ?? '').toString(),
            'price': (m['price'] is num) ? (m['price'] as num).toDouble() : double.tryParse('${m['price']}') ?? 0.0,
            'quantity': (m['quantity'] is int) ? m['quantity'] as int : int.tryParse('${m['quantity']}') ?? 0,
            'imageUrl': m['imageUrl'] as String?,
          });
        } else {
          // Likely an OrderCartItem
          final name = it.name?.toString() ?? '';
          final price = (it.price is num) ? (it.price as num).toDouble() : 0.0;
          final quantity = (it.quantity is int) ? it.quantity as int : 0;
          final imageUrl = it.imageUrl?.toString();
          final id = it.id?.toString() ?? '';
          out.add({
            'id': id,
            'name': name,
            'price': price,
            'quantity': quantity,
            'imageUrl': imageUrl,
          });
        }
      }
    } catch (_) {}
    return out;
  }
}


