import '../models/order.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class OrdersRepository {
  Future<List<OrderModel>> list();
  Future<void> add(OrderModel order);
}

class InMemoryOrdersRepository implements OrdersRepository {
  final List<OrderModel> _orders = [];

  InMemoryOrdersRepository() {
    // No sample data - orders will be added when users place orders
  }

  @override
  Future<void> add(OrderModel order) async {
    _orders.insert(0, order);
  }

  @override
  Future<List<OrderModel>> list() async {
    // Sort by creation date (newest first)
    final sortedOrders = _orders.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedOrders;
  }

  // Method to add sample orders for testing (optional)
  void addSampleOrders() {
    final now = DateTime.now();
    _orders.addAll([
      OrderModel(
        id: 'sample_1',
        createdAt: now.subtract(const Duration(minutes: 30)),
        type: 'dine_in',
        tableNumber: 5,
        itemCount: 3,
        amount: 940.0,
        paymentMethod: 'cash',
        thumbnailUrl: 'assets/images/P151/P151_Menu_Images/5\'li Wings.jpg',
        items: [
          OrderCartItem(
            id: '1',
            name: '5\'li Wings',
            price: 290.0,
            quantity: 2,
            imageUrl: 'assets/images/P151/P151_Menu_Images/5\'li Wings.jpg',
          ),
          OrderCartItem(
            id: '2',
            name: 'Only Burger',
            price: 315.0,
            quantity: 1,
            imageUrl: 'assets/images/P151/P151_Menu_Images/Only Burger.jpg',
          ),
        ],
      ),
      OrderModel(
        id: 'sample_2',
        createdAt: now.subtract(const Duration(hours: 1, minutes: 15)),
        type: 'takeaway',
        tableNumber: null,
        itemCount: 2,
        amount: 610.0,
        paymentMethod: 'card',
        thumbnailUrl: 'assets/images/P151/P151_Menu_Images/Grill Chicken Bowl.jpg',
        items: [
          OrderCartItem(
            id: '3',
            name: 'Grill Chicken Bowl',
            price: 295.0,
            quantity: 1,
            imageUrl: 'assets/images/P151/P151_Menu_Images/Grill Chicken Bowl.jpg',
          ),
          OrderCartItem(
            id: '4',
            name: 'Chicken Ceasar Salat',
            price: 285.0,
            quantity: 1,
            imageUrl: 'assets/images/P151/P151_Menu_Images/Chicken Ceasar Salat.jpg',
          ),
        ],
      ),
    ]);
  }
}

// Hive-backed implementation (map-based to avoid TypeAdapter for now)
class HiveOrdersRepository implements OrdersRepository {
  static const String boxName = 'orders_box';

  Future<Box<Map>> _box() async {
    // Hive is initialized in main.dart
    try {
      return await Hive.openBox<Map>(boxName);
    } catch (e) {
      print('Error opening Hive box: $e');
      // Try to delete and recreate the box if corrupted
      await Hive.deleteBoxFromDisk(boxName);
      return await Hive.openBox<Map>(boxName);
    }
  }

  @override
  Future<void> add(OrderModel order) async {
    print('HiveOrdersRepository.add() called with order: ${order.id}');
    try {
      final box = await _box();
      print('HiveOrdersRepository.add() - box opened');
      await box.put(order.id, {
        'id': order.id,
        'createdAt': order.createdAt.millisecondsSinceEpoch,
        'type': order.type,
        'tableNumber': order.tableNumber,
        'itemCount': order.itemCount,
        'amount': order.amount,
        'paymentMethod': order.paymentMethod,
        'thumbnailUrl': order.thumbnailUrl,
        'items': order.items.map((item) => item.toMap()).toList(),
      });
      print('HiveOrdersRepository.add() - order stored in Hive');
      print('HiveOrdersRepository.add() - box now has ${box.length} orders');
    } catch (e) {
      print('HiveOrdersRepository.add() error: $e');
      rethrow;
    }
  }

  @override
  Future<List<OrderModel>> list() async {
    print('HiveOrdersRepository.list() called');
    try {
      final box = await _box();
      print('HiveOrdersRepository.list() - box opened with ${box.length} items');
      final List<OrderModel> out = [];
      for (final Map<dynamic, dynamic> v in box.values) {
        try {
          final num amountNum = (v['amount'] ?? 0) is num
              ? (v['amount'] as num)
              : num.tryParse((v['amount'] ?? '0').toString()) ?? 0;

          // Parse items list robustly (Hive may return Map<dynamic,dynamic>)
          final List<OrderCartItem> items = [];
          final dynamic rawItems = v['items'];
          if (rawItems is List) {
            for (final dynamic raw in rawItems) {
              if (raw is Map) {
                final itemMap = Map<String, dynamic>.from(raw);
                items.add(OrderCartItem.fromMap(itemMap));
              }
            }
          }

          // createdAt may be int or String
          final int createdMs = (v['createdAt'] is int)
              ? v['createdAt'] as int
              : int.tryParse((v['createdAt'] ?? '0').toString()) ?? 0;

          final order = OrderModel(
            id: (v['id'] ?? '').toString(),
            createdAt: DateTime.fromMillisecondsSinceEpoch(createdMs),
            type: (v['type'] ?? '').toString(),
            tableNumber: v['tableNumber'] is int ? v['tableNumber'] as int : null,
            itemCount: (v['itemCount'] is int)
                ? v['itemCount'] as int
                : int.tryParse((v['itemCount'] ?? '0').toString()) ?? 0,
            amount: amountNum.toDouble(),
            paymentMethod: (v['paymentMethod'] ?? '').toString(),
            thumbnailUrl: v['thumbnailUrl'] as String?,
            items: items,
          );
          out.add(order);
          print('HiveOrdersRepository.list() - parsed order: ${order.id} with ${order.items.length} items');
        } catch (e) {
          print('HiveOrdersRepository.list() - skipping invalid entry due to error: $e');
        }
      }
      // Sort newest first
      out.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      print('HiveOrdersRepository.list() - returning ${out.length} orders');
      return out;
    } catch (e) {
      print('HiveOrdersRepository.list() error: $e');
      return [];
    }
  }

  // Test method to add a sample order
  Future<void> addTestOrder() async {
    print('HiveOrdersRepository.addTestOrder() called');
    final testOrder = OrderModel(
      id: 'test_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      type: 'dine_in',
      tableNumber: 5,
      itemCount: 2,
      amount: 850.0,
      paymentMethod: 'cash',
      thumbnailUrl: 'assets/images/P151/P151_Menu_Images/Hot Burger.jpg',
      items: [
        OrderCartItem(
          id: '1',
          name: 'Hot Burger',
          price: 315.0,
          quantity: 1,
          imageUrl: 'assets/images/P151/P151_Menu_Images/Hot Burger.jpg',
        ),
        OrderCartItem(
          id: '2',
          name: 'Only Wrap',
          price: 295.0,
          quantity: 1,
          imageUrl: 'assets/images/P151/P151_Menu_Images/Only Wrap.jpg',
        ),
      ],
    );
    await add(testOrder);
    print('HiveOrdersRepository.addTestOrder() - test order added');
  }
}
 








