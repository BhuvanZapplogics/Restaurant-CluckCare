import '../../../data/models/inventory_item.dart';

/// Service for managing stock adjustments with comprehensive tracking and validation
class StockAdjustmentService {
  // Predefined adjustment reasons for quick selection
  static const List<String> commonReasons = [
    'Order placed by customer',
    'Waste/Spillage',
    'Theft/Loss',
    'Quality control rejection',
    'Supplier delivery received',
    'Manual restock',
    'Stock count correction',
    'Promotional increase',
    'End of day adjustment',
    'Kitchen preparation',
    'Staff meal',
    'Expired item disposal',
    'Damaged goods',
    'Return to supplier',
    'Other',
  ];

  // Adjustment types
  static const String adjustmentTypeOrder = 'order';
  static const String adjustmentTypeWaste = 'waste';
  static const String adjustmentTypeDelivery = 'delivery';
  static const String adjustmentTypeManual = 'manual';
  static const String adjustmentTypeCorrection = 'correction';

  /// Validate stock adjustment
  static AdjustmentValidationResult validateAdjustment({
    required InventoryItem item,
    required double delta,
    required String reason,
    String? orderId,
  }) {
    final errors = <String>[];
    final warnings = <String>[];

    // Check for negative stock after adjustment
    final newStock = item.currentStock + delta;
    if (newStock < 0) {
      errors.add('Stock cannot go below zero. Maximum decrease: ${item.currentStock.toStringAsFixed(0)}');
    }

    // Check for extremely high stock (potential error)
    if (newStock > (item.parLevel * 3)) {
      warnings.add('New stock level (${newStock.toStringAsFixed(0)}) is 3x above par level. Please verify.');
    }

    // Check reason validity
    if (reason.trim().isEmpty) {
      errors.add('Reason is required for all stock adjustments');
    }

    // Check for suspicious large decreases
    if (delta < -10 && !reason.toLowerCase().contains('order')) {
      warnings.add('Large decrease detected. Please ensure reason is accurate.');
    }

    // Check for suspicious large increases
    if (delta > 50 && !reason.toLowerCase().contains('delivery')) {
      warnings.add('Large increase detected. Please verify delivery amount.');
    }

    return AdjustmentValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
      suggestedNewStock: newStock.clamp(0, double.infinity),
    );
  }

  /// Create stock adjustment record
  static StockAdjustment createAdjustment({
    required String itemId,
    required double quantityChange,
    required double newStock,
    required String reason,
    String? orderId,
    String? adjustedBy,
    String? notes,
  }) {
    return StockAdjustment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      itemId: itemId,
      quantityChange: quantityChange,
      reason: reason,
      adjustedBy: adjustedBy ?? 'System',
      timestamp: DateTime.now(),
      notes: notes,
      adjustmentType: getAdjustmentType(reason),
      orderId: orderId,
    );
  }

  /// Get adjustment type from reason
  static String getAdjustmentType(String reason) {
    final lowerReason = reason.toLowerCase();
    
    if (lowerReason.contains('order') || lowerReason.contains('customer')) {
      return adjustmentTypeOrder;
    } else if (lowerReason.contains('waste') || lowerReason.contains('spillage') || 
               lowerReason.contains('expired') || lowerReason.contains('damaged')) {
      return adjustmentTypeWaste;
    } else if (lowerReason.contains('delivery') || lowerReason.contains('supplier') || 
               lowerReason.contains('received') || lowerReason.contains('restock')) {
      return adjustmentTypeDelivery;
    } else if (lowerReason.contains('count') || lowerReason.contains('correction') || 
               lowerReason.contains('audit')) {
      return adjustmentTypeCorrection;
    } else {
      return adjustmentTypeManual;
    }
  }

  /// Get color for adjustment type
  static String getAdjustmentTypeColor(String adjustmentType) {
    switch (adjustmentType) {
      case adjustmentTypeOrder:
        return 'success'; // Green - positive business
      case adjustmentTypeWaste:
        return 'error'; // Red - loss
      case adjustmentTypeDelivery:
        return 'info'; // Blue - restocking
      case adjustmentTypeCorrection:
        return 'warning'; // Orange - correction
      case adjustmentTypeManual:
      default:
        return 'secondary'; // Gray - manual
    }
  }

  /// Get icon for adjustment type
  static String getAdjustmentTypeIcon(String adjustmentType) {
    switch (adjustmentType) {
      case adjustmentTypeOrder:
        return 'shopping_cart';
      case adjustmentTypeWaste:
        return 'delete';
      case adjustmentTypeDelivery:
        return 'local_shipping';
      case adjustmentTypeCorrection:
        return 'edit';
      case adjustmentTypeManual:
      default:
        return 'settings';
    }
  }

  /// Calculate adjustment statistics
  static AdjustmentStatistics calculateStatistics(List<StockAdjustment> adjustments) {
    if (adjustments.isEmpty) {
      return AdjustmentStatistics.empty();
    }

    final totalAdjustments = adjustments.length;
    final totalIncrease = adjustments
        .where((adj) => adj.quantityChange > 0)
        .fold(0.0, (sum, adj) => sum + adj.quantityChange);
    
    final totalDecrease = adjustments
        .where((adj) => adj.quantityChange < 0)
        .fold(0.0, (sum, adj) => sum + adj.quantityChange.abs());

    final orderAdjustments = adjustments
        .where((adj) => adj.orderId != null)
        .length;

    final wasteAdjustments = adjustments
        .where((adj) => adj.reason.toLowerCase().contains('waste') || 
                       adj.reason.toLowerCase().contains('spillage'))
        .length;

    final deliveryAdjustments = adjustments
        .where((adj) => adj.reason.toLowerCase().contains('delivery'))
        .length;

    return AdjustmentStatistics(
      totalAdjustments: totalAdjustments,
      totalIncrease: totalIncrease,
      totalDecrease: totalDecrease,
      orderAdjustments: orderAdjustments,
      wasteAdjustments: wasteAdjustments,
      deliveryAdjustments: deliveryAdjustments,
      netChange: totalIncrease - totalDecrease,
      averageAdjustment: (totalIncrease - totalDecrease) / totalAdjustments,
    );
  }

  /// Get recent adjustment trends
  static List<AdjustmentTrend> getAdjustmentTrends(List<StockAdjustment> adjustments, {int days = 7}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final recentAdjustments = adjustments
        .where((adj) => adj.timestamp.isAfter(cutoffDate))
        .toList();

    final trends = <String, List<StockAdjustment>>{};
    
    for (final adj in recentAdjustments) {
      final dateKey = '${adj.timestamp.year}-${adj.timestamp.month.toString().padLeft(2, '0')}-${adj.timestamp.day.toString().padLeft(2, '0')}';
      trends.putIfAbsent(dateKey, () => []).add(adj);
    }

    return trends.entries.map((entry) {
      final date = DateTime.parse(entry.key);
      final dayAdjustments = entry.value;
      
      final totalIncrease = dayAdjustments
          .where((adj) => adj.quantityChange > 0)
          .fold(0.0, (sum, adj) => sum + adj.quantityChange);
      
      final totalDecrease = dayAdjustments
          .where((adj) => adj.quantityChange < 0)
          .fold(0.0, (sum, adj) => sum + adj.quantityChange.abs());

      return AdjustmentTrend(
        date: date,
        totalAdjustments: dayAdjustments.length,
        totalIncrease: totalIncrease,
        totalDecrease: totalDecrease,
        netChange: totalIncrease - totalDecrease,
      );
    }).toList()
    ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Suggest adjustment reasons based on context
  static List<String> suggestReasons({
    required InventoryItem item,
    required double delta,
    String? orderId,
  }) {
    final suggestions = <String>[];

    if (delta > 0) {
      // Positive adjustments
      suggestions.addAll([
        'Supplier delivery received',
        'Manual restock',
        'Stock count correction',
        'Return from customer',
      ]);
    } else {
      // Negative adjustments
      suggestions.addAll([
        'Order placed by customer',
        'Waste/Spillage',
        'Quality control rejection',
        'Staff meal',
        'Expired item disposal',
      ]);
    }

    // Add order-specific reason if orderId is provided
    if (orderId != null) {
      suggestions.insert(0, 'Order #$orderId - Customer purchase');
    }

    // Add category-specific suggestions
    switch (item.category.toLowerCase()) {
      case 'starters':
        if (delta < 0) {
          suggestions.add('Kitchen preparation - appetizers');
        }
        break;
      case 'main course':
        if (delta < 0) {
          suggestions.add('Main course preparation');
        }
        break;
      case 'sandwiches':
        if (delta < 0) {
          suggestions.add('Sandwich assembly');
        }
        break;
    }

    return suggestions.take(5).toList(); // Limit to 5 suggestions
  }
}

/// Validation result for stock adjustments
class AdjustmentValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final double suggestedNewStock;

  const AdjustmentValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
    required this.suggestedNewStock,
  });
}

/// Statistics for stock adjustments
class AdjustmentStatistics {
  final int totalAdjustments;
  final double totalIncrease;
  final double totalDecrease;
  final int orderAdjustments;
  final int wasteAdjustments;
  final int deliveryAdjustments;
  final double netChange;
  final double averageAdjustment;

  const AdjustmentStatistics({
    required this.totalAdjustments,
    required this.totalIncrease,
    required this.totalDecrease,
    required this.orderAdjustments,
    required this.wasteAdjustments,
    required this.deliveryAdjustments,
    required this.netChange,
    required this.averageAdjustment,
  });

  factory AdjustmentStatistics.empty() {
    return const AdjustmentStatistics(
      totalAdjustments: 0,
      totalIncrease: 0,
      totalDecrease: 0,
      orderAdjustments: 0,
      wasteAdjustments: 0,
      deliveryAdjustments: 0,
      netChange: 0,
      averageAdjustment: 0,
    );
  }
}

/// Daily adjustment trend
class AdjustmentTrend {
  final DateTime date;
  final int totalAdjustments;
  final double totalIncrease;
  final double totalDecrease;
  final double netChange;

  const AdjustmentTrend({
    required this.date,
    required this.totalAdjustments,
    required this.totalIncrease,
    required this.totalDecrease,
    required this.netChange,
  });
}

