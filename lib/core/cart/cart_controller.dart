import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String name;
  final double unitPrice;
  int quantity;
  final String? imageUrl;

  CartItem({required this.id, required this.name, required this.unitPrice, this.quantity = 1, this.imageUrl});

  double get lineTotal => unitPrice * quantity;
}

class CartController extends ChangeNotifier {
  final Map<String, CartItem> _items = {};
  
  // Order type: 'dine_in' or 'takeaway'
  String _orderType = 'takeaway';
  // Table number for dine-in orders (null for takeaway)
  int? _tableNumber;

  List<CartItem> get items => _items.values.toList(growable: false);

  int get totalQuantity => _items.values.fold(0, (sum, it) => sum + it.quantity);

  double get subtotal => _items.values.fold(0.0, (sum, it) => sum + it.lineTotal);

  double get tax => subtotal * 0.05; // simple 5% placeholder

  double get total => subtotal + tax;
  
  String get orderType => _orderType;
  int? get tableNumber => _tableNumber;
  
  void setOrderType(String type, {int? tableNumber}) {
    _orderType = type;
    _tableNumber = type == 'dine_in' ? tableNumber : null;
    notifyListeners();
  }
  
  void setTableNumber(int? number) {
    _tableNumber = number;
    notifyListeners();
  }

  void addItem({required String id, required String name, required double price, String? imageUrl}) {
    final existing = _items[id];
    if (existing != null) {
      existing.quantity += 1;
    } else {
      _items[id] = CartItem(id: id, name: name, unitPrice: price, quantity: 1, imageUrl: imageUrl);
    }
    notifyListeners();
  }

  void increment(String id) {
    final existing = _items[id];
    if (existing != null) {
      existing.quantity += 1;
      notifyListeners();
    }
  }

  void decrement(String id) {
    final existing = _items[id];
    if (existing != null) {
      existing.quantity -= 1;
      if (existing.quantity <= 0) {
        _items.remove(id);
      }
      notifyListeners();
    }
  }

  void removeItem(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void updateQuantity(String id, int quantity) {
    final existing = _items[id];
    if (existing != null) {
      if (quantity <= 0) {
        _items.remove(id);
      } else {
        existing.quantity = quantity;
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}








