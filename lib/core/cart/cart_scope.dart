import 'package:flutter/widgets.dart';
import 'cart_controller.dart';

class CartScope extends InheritedNotifier<CartController> {
  const CartScope({super.key, required CartController controller, required Widget child})
      : super(notifier: controller, child: child);

  static CartController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CartScope>();
    if (scope == null) {
      throw FlutterError('CartScope not found in context. Make sure CartScope is provided above this widget.');
    }
    final controller = scope.notifier;
    if (controller == null) {
      throw FlutterError('CartController is null in CartScope. Make sure a valid CartController is provided.');
    }
    return controller;
  }
}



