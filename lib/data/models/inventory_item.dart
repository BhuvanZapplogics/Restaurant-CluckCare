class InventoryItemModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final double currentStock;
  final double parLevel;
  final double reorderPoint;
  final String unit;
  final double dailySalesAverage;
  final List<StockAdjustment> stockHistory;
  final String? imageUrl;
  final DateTime lastUpdated;
  final double? price;
  final String? currency;

  InventoryItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.currentStock,
    required this.parLevel,
    required this.reorderPoint,
    required this.unit,
    required this.dailySalesAverage,
    required this.stockHistory,
    this.imageUrl,
    required this.lastUpdated,
    this.price,
    this.currency,
  });

  // Copy with method for updates
  InventoryItemModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? currentStock,
    double? parLevel,
    double? reorderPoint,
    String? unit,
    double? dailySalesAverage,
    List<StockAdjustment>? stockHistory,
    String? imageUrl,
    DateTime? lastUpdated,
  }) {
    return InventoryItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      currentStock: currentStock ?? this.currentStock,
      parLevel: parLevel ?? this.parLevel,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      unit: unit ?? this.unit,
      dailySalesAverage: dailySalesAverage ?? this.dailySalesAverage,
      stockHistory: stockHistory ?? this.stockHistory,
      imageUrl: imageUrl ?? this.imageUrl,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      price: price ?? this.price,
      currency: currency ?? this.currency,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'currentStock': currentStock,
      'parLevel': parLevel,
      'reorderPoint': reorderPoint,
      'unit': unit,
      'dailySalesAverage': dailySalesAverage,
      'stockHistory': stockHistory.map((e) => e.toJson()).toList(),
      'imageUrl': imageUrl,
      'lastUpdated': lastUpdated.toIso8601String(),
      'price': price,
      'currency': currency,
    };
  }

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    return InventoryItemModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      currentStock: json['currentStock']?.toDouble() ?? 0.0,
      parLevel: json['parLevel']?.toDouble() ?? 0.0,
      reorderPoint: json['reorderPoint']?.toDouble() ?? 0.0,
      unit: json['unit'],
      dailySalesAverage: json['dailySalesAverage']?.toDouble() ?? 0.0,
      stockHistory: (json['stockHistory'] as List<dynamic>?)
          ?.map((e) => StockAdjustment.fromJson(e))
          .toList() ?? [],
      imageUrl: json['imageUrl'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
      price: json['price']?.toDouble(),
      currency: json['currency'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InventoryItemModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Stock status getter
  String get stockStatus {
    if (currentStock <= 0) return 'out_of_stock';
    if (currentStock <= reorderPoint) return 'low_stock';
    return 'in_stock';
  }

  // Low stock check getter
  bool get isLowStock {
    return currentStock <= reorderPoint;
  }

  // Factory method to create from menu item
  factory InventoryItemModel.fromMenuItem(
    dynamic menuItem, {
    required double currentStock,
    required double parLevel,
    required double dailySalesAverage,
  }) {
    return InventoryItemModel(
      id: menuItem.id ?? '',
      name: menuItem.name ?? '',
      description: menuItem.description ?? '',
      category: menuItem.category ?? '',
      currentStock: currentStock,
      parLevel: parLevel,
      reorderPoint: parLevel * 0.4, // 40% of par level
      unit: 'pieces',
      dailySalesAverage: dailySalesAverage,
      stockHistory: [],
      imageUrl: menuItem.imageUrl,
      lastUpdated: DateTime.now(),
    );
  }
}

class StockAdjustment {
  final String id;
  final String itemId;
  final double quantityChange;
  final String reason;
  final String adjustedBy;
  final DateTime timestamp;
  final String? notes;
  final String adjustmentType; // 'increase', 'decrease', 'set'
  final String? orderId;

  StockAdjustment({
    required this.id,
    required this.itemId,
    required this.quantityChange,
    required this.reason,
    required this.adjustedBy,
    required this.timestamp,
    this.notes,
    required this.adjustmentType,
    this.orderId,
  });

  // Copy with method
  StockAdjustment copyWith({
    String? id,
    String? itemId,
    double? quantityChange,
    String? reason,
    String? adjustedBy,
    DateTime? timestamp,
    String? notes,
    String? adjustmentType,
    String? orderId,
  }) {
    return StockAdjustment(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      quantityChange: quantityChange ?? this.quantityChange,
      reason: reason ?? this.reason,
      adjustedBy: adjustedBy ?? this.adjustedBy,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
      adjustmentType: adjustmentType ?? this.adjustmentType,
      orderId: orderId ?? this.orderId,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemId': itemId,
      'quantityChange': quantityChange,
      'reason': reason,
      'adjustedBy': adjustedBy,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
      'adjustmentType': adjustmentType,
      'orderId': orderId,
    };
  }

  factory StockAdjustment.fromJson(Map<String, dynamic> json) {
    return StockAdjustment(
      id: json['id'],
      itemId: json['itemId'],
      quantityChange: json['quantityChange']?.toDouble() ?? 0.0,
      reason: json['reason'],
      adjustedBy: json['adjustedBy'],
      timestamp: DateTime.parse(json['timestamp']),
      notes: json['notes'],
      adjustmentType: json['adjustmentType'] ?? 'set',
      orderId: json['orderId'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StockAdjustment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Type alias for backward compatibility
typedef InventoryItem = InventoryItemModel;