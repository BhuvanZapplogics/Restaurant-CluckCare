import 'package:flutter/widgets.dart';
import 'orders_controller.dart';

class OrdersScope extends InheritedNotifier<OrdersController> {
  const OrdersScope({super.key, required OrdersController controller, required Widget child})
      : super(notifier: controller, child: child);

  static OrdersController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<OrdersScope>();
    if (scope == null) {
      throw FlutterError('OrdersScope not found in context. Make sure OrdersScope is provided above this widget.');
    }
    final controller = scope.notifier;
    if (controller == null) {
      throw FlutterError('OrdersController is null in OrdersScope. Make sure a valid OrdersController is provided.');
    }
    return controller;
  }
}



