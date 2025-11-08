import 'package:flutter/foundation.dart';
import '../../../data/models/order.dart';
import '../../../data/repositories/orders_repository.dart';

class OrdersController extends ChangeNotifier {
  final OrdersRepository repository;
  OrdersController(this.repository);

  List<OrderModel> _orders = const [];
  List<OrderModel> get orders => _orders;

  Future<void> load() async {
    print('OrdersController.load() called');
    try {
      _orders = await repository.list();
      print('OrdersController.load() - loaded ${_orders.length} orders');
      for (final order in _orders) {
        print('Order: ${order.id} - ${order.type} - ${order.amount} - ${order.items.length} items');
      }
      notifyListeners();
      print('OrdersController.load() - notifyListeners() called');
    } catch (e) {
      print('OrdersController.load() error: $e');
      _orders = [];
      notifyListeners();
    }
  }

  Future<void> add(OrderModel order) async {
    print('OrdersController.add() called with order: ${order.id}');
    try {
      await repository.add(order);
      print('OrdersController.add() - order added to repository');
      await load();
      print('OrdersController.add() - load() completed');
    } catch (e) {
      print('OrdersController.add() error: $e');
    }
  }
}











