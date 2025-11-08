import '../../../data/models/inventory_item.dart';

/// Service responsible for intelligent low stock detection based on usage patterns
class LowStockDetector {
  // Configuration constants
  static const double _safetyThreshold = 0.3; // 30% of par level
  static const double _absoluteMinimum = 5.0; // Never go below 5 units
  static const double _highVelocityThreshold = 10.0; // Items selling >10 per day
  static const double _velocityMultiplier = 2.0; // Keep 2x daily sales in stock
  static const int _trendDays = 7; // Look at last 7 days for trends

  /// Main low stock detection method
  static bool isLowStock(InventoryItem item) {
    // Rule 1: Absolute minimum safety rule
    if (item.currentStock <= 0) return true;
    if (item.currentStock < _absoluteMinimum) return true;

    // Rule 2: Percentage-based rule (primary rule)
    if (item.currentStock < (item.parLevel * _safetyThreshold)) return true;

    // Rule 3: Velocity-based rule for popular items
    if (_isHighVelocityItem(item) && _hasInsufficientVelocityStock(item)) return true;

    // Rule 4: Trend-based rule (if we have trend data)
    if (_hasDecliningTrend(item)) return true;

    // Rule 5: Category-specific rules
    if (_isCategorySpecificLowStock(item)) return true;

    return false;
  }

  /// Get detailed low stock analysis
  static LowStockAnalysis analyzeStock(InventoryItem item) {
    final reasons = <String>[];

    // Check absolute minimum
    if (item.currentStock <= 0) {
      reasons.add('Out of stock - immediate restock required');
      return LowStockAnalysis(
        isLowStock: true,
        severity: LowStockSeverity.critical,
        reasons: reasons,
        recommendedAction: 'Restock immediately - item is out of stock',
        daysUntilStockout: 0,
        recommendedStockLevel: item.parLevel,
      );
    }

    if (item.currentStock < _absoluteMinimum) {
      reasons.add('Below absolute minimum safety level (${_absoluteMinimum} units)');
    }

    // Check percentage rule
    final percentageThreshold = item.parLevel * _safetyThreshold;
    if (item.currentStock < percentageThreshold) {
      reasons.add('Below ${(_safetyThreshold * 100).toInt()}% of par level (${percentageThreshold.toStringAsFixed(0)} units)');
    }

    // Check velocity rule
    if (_isHighVelocityItem(item) && _hasInsufficientVelocityStock(item)) {
      final requiredStock = item.dailySalesAverage * _velocityMultiplier;
      reasons.add('High-velocity item needs ${_velocityMultiplier}x daily sales in stock (${requiredStock.toStringAsFixed(0)} units)');
    }

    // Check trend
    if (_hasDecliningTrend(item)) {
      reasons.add('Declining stock trend detected');
    }

    // Check category-specific rules
    final categoryReason = _getCategorySpecificReason(item);
    if (categoryReason.isNotEmpty) {
      reasons.add(categoryReason);
    }

    // Calculate days until stockout
    final daysUntilStockout = _calculateDaysUntilStockout(item);

    // Determine severity
    final severity = _calculateSeverity(item, daysUntilStockout);

    // Get recommended action
    final recommendedAction = _getRecommendedAction(item, daysUntilStockout, severity);

    // Get recommended stock level
    final recommendedStockLevel = _getRecommendedStockLevel(item);

    return LowStockAnalysis(
      isLowStock: reasons.isNotEmpty,
      severity: severity,
      reasons: reasons,
      recommendedAction: recommendedAction,
      daysUntilStockout: daysUntilStockout,
      recommendedStockLevel: recommendedStockLevel,
    );
  }

  /// Check if item is high velocity (popular)
  static bool _isHighVelocityItem(InventoryItem item) {
    return item.dailySalesAverage > _highVelocityThreshold;
  }

  /// Check if item has insufficient stock for its velocity
  static bool _hasInsufficientVelocityStock(InventoryItem item) {
    final requiredStock = item.dailySalesAverage * _velocityMultiplier;
    return item.currentStock < requiredStock;
  }

  /// Check if item has declining stock trend
  static bool _hasDecliningTrend(InventoryItem item) {
    // This would typically analyze stock history over time
    // For now, we'll use a simple heuristic based on recent adjustments
    final recentAdjustments = item.stockHistory
        .where((adj) => adj.timestamp.isAfter(DateTime.now().subtract(const Duration(days: _trendDays))))
        .toList();

    if (recentAdjustments.length < 2) return false;

    // Check if recent adjustments are mostly negative
    final negativeAdjustments = recentAdjustments.where((adj) => adj.quantityChange < 0).length;
    return negativeAdjustments > (recentAdjustments.length * 0.6); // 60% negative adjustments
  }

  /// Check category-specific low stock conditions
  static bool _isCategorySpecificLowStock(InventoryItem item) {
    switch (item.category.toLowerCase()) {
      case 'starters':
        // Starters need higher stock due to high turnover
        return item.currentStock < (item.parLevel * 0.4); // 40% threshold for starters
      
      case 'main course':
        // Main courses are critical - lower threshold
        return item.currentStock < (item.parLevel * 0.25); // 25% threshold for mains
      
      case 'sandwiches':
        // Popular items - need higher stock
        return item.currentStock < (item.parLevel * 0.35); // 35% threshold for sandwiches
      
      case 'side dishes':
        // Side dishes can have lower threshold
        return item.currentStock < (item.parLevel * 0.2); // 20% threshold for sides
      
      default:
        return false;
    }
  }

  /// Get category-specific reason for low stock
  static String _getCategorySpecificReason(InventoryItem item) {
    switch (item.category.toLowerCase()) {
      case 'starters':
        if (item.currentStock < (item.parLevel * 0.4)) {
          return 'Starters need higher stock due to high turnover';
        }
        break;
      case 'main course':
        if (item.currentStock < (item.parLevel * 0.25)) {
          return 'Main courses are critical menu items';
        }
        break;
      case 'sandwiches':
        if (item.currentStock < (item.parLevel * 0.35)) {
          return 'Popular sandwich items need higher stock';
        }
        break;
    }
    return '';
  }

  /// Calculate days until stockout based on daily sales
  static int _calculateDaysUntilStockout(InventoryItem item) {
    if (item.dailySalesAverage <= 0) {
      return 999; // No sales data - assume long time
    }
    
    final days = (item.currentStock / item.dailySalesAverage).floor();
    return days.clamp(0, 999);
  }

  /// Calculate severity level
  static LowStockSeverity _calculateSeverity(InventoryItem item, int daysUntilStockout) {
    if (item.currentStock <= 0) return LowStockSeverity.critical;
    if (daysUntilStockout <= 1) return LowStockSeverity.critical;
    if (daysUntilStockout <= 3) return LowStockSeverity.high;
    if (daysUntilStockout <= 7) return LowStockSeverity.medium;
    return LowStockSeverity.low;
  }

  /// Get recommended action based on analysis
  static String _getRecommendedAction(InventoryItem item, int daysUntilStockout, LowStockSeverity severity) {
    switch (severity) {
      case LowStockSeverity.critical:
        return 'URGENT: Restock immediately - item will be out of stock within 1 day';
      case LowStockSeverity.high:
        return 'HIGH PRIORITY: Restock within 24 hours - item will be out of stock within 3 days';
      case LowStockSeverity.medium:
        return 'MEDIUM PRIORITY: Plan restocking within 2-3 days';
      case LowStockSeverity.low:
        return 'LOW PRIORITY: Monitor stock levels closely';
      case LowStockSeverity.normal:
        return 'Stock levels are healthy';
    }
  }

  /// Get recommended stock level
  static double _getRecommendedStockLevel(InventoryItem item) {
    // Base recommendation on par level
    double recommended = item.parLevel;

    // Adjust for high velocity items
    if (_isHighVelocityItem(item)) {
      recommended = (item.dailySalesAverage * _velocityMultiplier).clamp(item.parLevel, item.parLevel * 1.5);
    }

    // Adjust for category
    switch (item.category.toLowerCase()) {
      case 'starters':
        recommended *= 1.2; // 20% higher for starters
        break;
      case 'main course':
        recommended *= 1.1; // 10% higher for mains
        break;
      case 'sandwiches':
        recommended *= 1.15; // 15% higher for sandwiches
        break;
      case 'side dishes':
        recommended *= 0.9; // 10% lower for sides
        break;
    }

    return recommended.roundToDouble();
  }

  /// Get bulk low stock analysis for multiple items
  static Map<String, LowStockAnalysis> analyzeBulkStock(List<InventoryItem> items) {
    final Map<String, LowStockAnalysis> results = {};
    
    for (final item in items) {
      results[item.id] = analyzeStock(item);
    }
    
    return results;
  }

  /// Get items that need immediate attention (critical/high severity)
  static List<InventoryItem> getUrgentItems(List<InventoryItem> items) {
    return items.where((item) {
      final analysis = analyzeStock(item);
      return analysis.severity == LowStockSeverity.critical || 
             analysis.severity == LowStockSeverity.high;
    }).toList();
  }

  /// Get reorder recommendations
  static List<ReorderRecommendation> getReorderRecommendations(List<InventoryItem> items) {
    final recommendations = <ReorderRecommendation>[];
    
    for (final item in items) {
      final analysis = analyzeStock(item);
      if (analysis.isLowStock) {
        recommendations.add(ReorderRecommendation(
          item: item,
          analysis: analysis,
          priority: _calculatePriority(analysis.severity),
          suggestedOrderQuantity: (analysis.recommendedStockLevel - item.currentStock).clamp(0, double.infinity),
        ));
      }
    }
    
    // Sort by priority (critical first)
    recommendations.sort((a, b) => b.priority.compareTo(a.priority));
    
    return recommendations;
  }

  /// Calculate priority score for reordering
  static int _calculatePriority(LowStockSeverity severity) {
    switch (severity) {
      case LowStockSeverity.critical:
        return 100;
      case LowStockSeverity.high:
        return 80;
      case LowStockSeverity.medium:
        return 60;
      case LowStockSeverity.low:
        return 40;
      case LowStockSeverity.normal:
        return 0;
    }
  }
}

/// Detailed low stock analysis result
class LowStockAnalysis {
  final bool isLowStock;
  final LowStockSeverity severity;
  final List<String> reasons;
  final String recommendedAction;
  final int daysUntilStockout;
  final double recommendedStockLevel;

  const LowStockAnalysis({
    required this.isLowStock,
    required this.severity,
    required this.reasons,
    required this.recommendedAction,
    required this.daysUntilStockout,
    required this.recommendedStockLevel,
  });
}

/// Severity levels for low stock
enum LowStockSeverity {
  normal,
  low,
  medium,
  high,
  critical,
}

/// Reorder recommendation
class ReorderRecommendation {
  final InventoryItem item;
  final LowStockAnalysis analysis;
  final int priority;
  final double suggestedOrderQuantity;

  const ReorderRecommendation({
    required this.item,
    required this.analysis,
    required this.priority,
    required this.suggestedOrderQuantity,
  });
}
