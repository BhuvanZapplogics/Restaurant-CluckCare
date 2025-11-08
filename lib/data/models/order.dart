class OrderCartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String? imageUrl;

  const OrderCartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }

  factory OrderCartItem.fromMap(Map<String, dynamic> map) {
    return OrderCartItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 0,
      imageUrl: map['imageUrl'],
    );
  }
}

class OrderModel {
  final String id;
  final DateTime createdAt;
  final String type; // dine_in / takeaway
  final int? tableNumber;
  final int itemCount;
  final double amount;
  final String paymentMethod; // cash/upi/card
  final String? thumbnailUrl; // optional first item image
  final List<OrderCartItem> items; // actual cart items

  const OrderModel({
    required this.id,
    required this.createdAt,
    required this.type,
    this.tableNumber,
    required this.itemCount,
    required this.amount,
    required this.paymentMethod,
    this.thumbnailUrl,
    required this.items,
  });
}








