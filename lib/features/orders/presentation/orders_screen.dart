import 'package:flutter/material.dart';
import '../controllers/orders_scope.dart';
import 'order_details_screen.dart';
import '../../../app/theme/colors.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
  }

  Future<void> _loadOrders() async {
    try {
      await OrdersScope.of(context).load();
    } catch (_) {
      // If OrdersScope is not available, silently ignore
    }
  }

  Future<void> _onRefresh() async {
    await _loadOrders();
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    try {
      final controller = OrdersScope.of(context);

      return Scaffold(
        backgroundColor: AppColors.bgScreen,
        appBar: AppBar(
          backgroundColor: AppColors.bgSurface,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'Completed Orders',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final orders = controller.orders.toList();

            return RefreshIndicator(
              onRefresh: _onRefresh,
              backgroundColor: AppColors.cardSurface,
              color: AppColors.textPrimary,
              child: orders.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return _buildOrderCard(order);
                      },
                    ),
            );
          },
        ),
      );
    } catch (e) {
      return _buildErrorState();
    }
  }

  Widget _buildEmptyState() {
    return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: 16),
                Text(
                  'No completed orders yet',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Create a bill to see receipts',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildErrorState() {
    return const Scaffold(
      backgroundColor: AppColors.bgScreen,
      body: Center(
        child: Text(
          'Unable to load orders',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildOrderCard(dynamic order) {
    final orderType = order.type == 'dine_in' ? 'Dine-In' : 'Takeaway';
    final tableNumber = order.tableNumber != null ? 'Table ${order.tableNumber.toString().padLeft(2, '0')}' : 'Takeaway';
    final items = _coerceOrderItems(order);
    final itemCount = items.fold<int>(0, (sum, item) => sum + (item['quantity'] as int));
    final totalAmount = order.amount;
    final timeText = _formatTime(order.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
                          child: InkWell(
          borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => OrderDetailsScreen(order: order),
                                ),
                              );
                            },
                              child: Padding(
            padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                // Items list with first item image, table number, time, and order info
                _buildItemsListWithImage(items, orderType, itemCount, tableNumber, timeText),
                const SizedBox(height: 16),
                
                // SubTotal and Total amount on the right
                                        Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text(
                      'SubTotal: ',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                                                            Text(
                      '₺${totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                                                            ),
                                                          ],
                                                        ),
                const SizedBox(height: 16),
                
                // View Details button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => OrderDetailsScreen(order: order),
                        ),
                      );
                    },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryCta,
                          foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'View Details',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 16),
                                      ],
                                    ),
                                  ),
                                  ),
                                ],
                              ),
                            ),
                          ),
      ),
    );
  }

  Widget _buildBadge(String text, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        ),
      );
    }

  Widget _buildItemsListWithImage(List<Map<String, dynamic>> items, String orderType, int itemCount, String tableNumber, String timeText) {
    if (items.isEmpty) return const SizedBox.shrink();
    
    final firstItem = items.first;
    final displayItems = items.take(2).toList();
    final remainingCount = items.length - displayItems.length;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Large first item image on the left with "Paid" tag
        Stack(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildLargeItemImage(firstItem['imageUrl'] as String?),
              ),
            ),
            // "Paid" tag positioned at the very bottom of the image
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondaryCta, // App's secondary CTA color
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: const Text(
                  'Paid',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        // Order info and items list on the right
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Table number and time in the same row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tableNumber,
                         style: const TextStyle(
                           color: AppColors.textPrimary,
                           fontSize: 18,
                           fontWeight: FontWeight.bold,
                         ),
                  ),
                  Text(
                    timeText,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Order type and item count badges
              Row(
                children: [
                       _buildBadge(orderType, AppColors.secondaryCta, Colors.black),
                       const SizedBox(width: 8),
                       _buildBadge('$itemCount Items', AppColors.primaryCta, AppColors.textPrimary),
                ],
              ),
              const SizedBox(height: 8),
              // Items list
              for (int i = 0; i < displayItems.length; i++)
                _buildItemRow(displayItems[i]),
              if (remainingCount > 0)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                       decoration: BoxDecoration(
                         color: AppColors.bgSurface,
                         borderRadius: BorderRadius.circular(8),
                       ),
                  child: Text(
                    '+$remainingCount More Items',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemRow(Map<String, dynamic> item) {
    final name = item['name'] as String;
    final price = item['price'] as double;
    final quantity = item['quantity'] as int;
    final total = price * quantity;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Small bowl icon
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              Icons.restaurant,
              color: Color(0xFF4CAF50),
              size: 12,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$name...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '₺${total.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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


  Widget _buildLargeItemImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50).withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.restaurant,
          color: Color(0xFF4CAF50),
          size: 32,
        ),
      );
    }

    final isAsset = !(imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));
    
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: isAsset
            ? Image.asset(
                imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildLargeImagePlaceholder();
                },
              )
            : Image.network(
                imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildLargeImagePlaceholder();
                },
              ),
      ),
    );
  }

  Widget _buildLargeImagePlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.restaurant,
        color: Color(0xFF4CAF50),
        size: 32,
      ),
    );
  }

}