import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../data/models/inventory_item.dart';
import '../services/low_stock_detector.dart';

class LowStockAlertBanner extends StatelessWidget {
  final List<InventoryItem> urgentItems;
  final VoidCallback? onViewAll;

  const LowStockAlertBanner({
    super.key,
    required this.urgentItems,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (urgentItems.isEmpty) return const SizedBox.shrink();

    final criticalItems = urgentItems.where((item) {
      final analysis = LowStockDetector.analyzeStock(item);
      return analysis.severity == LowStockSeverity.critical;
    }).toList();

    final highPriorityItems = urgentItems.where((item) {
      final analysis = LowStockDetector.analyzeStock(item);
      return analysis.severity == LowStockSeverity.high;
    }).toList();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.error.withOpacity(0.1),
            AppColors.warning.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: criticalItems.isNotEmpty ? AppColors.error : AppColors.warning,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                criticalItems.isNotEmpty ? Icons.dangerous : Icons.warning,
                color: criticalItems.isNotEmpty ? AppColors.error : AppColors.warning,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                criticalItems.isNotEmpty 
                    ? 'CRITICAL STOCK ALERT' 
                    : 'HIGH PRIORITY STOCK ALERT',
                style: TextStyle(
                  color: criticalItems.isNotEmpty ? AppColors.error : AppColors.warning,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: const Text('View All'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Alert summary
          Text(
            criticalItems.isNotEmpty
                ? '${criticalItems.length} item(s) are out of stock or will be out within 24 hours!'
                : '${highPriorityItems.length} item(s) need immediate restocking within 3 days.',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          
          // Item list
          ...urgentItems.take(3).map((item) => _buildAlertItem(item)).toList(),
          
          if (urgentItems.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '+ ${urgentItems.length - 3} more items need attention',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(InventoryItem item) {
    final analysis = LowStockDetector.analyzeStock(item);
    final isCritical = analysis.severity == LowStockSeverity.critical;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isCritical ? AppColors.error : AppColors.warning).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (isCritical ? AppColors.error : AppColors.warning).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Item image
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              image: DecorationImage(
                image: AssetImage(item.imageUrl ?? 'assets/images/P151/P151_Menu_Images_Size Reduced/OnlyBurger.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Item details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Stock: ${item.currentStock.toStringAsFixed(0)} / ${item.parLevel.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                Text(
                  analysis.recommendedAction,
                  style: TextStyle(
                    color: isCritical ? AppColors.error : AppColors.warning,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Severity indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isCritical ? AppColors.error : AppColors.warning,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isCritical ? 'CRITICAL' : 'HIGH',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReorderRecommendationsWidget extends StatelessWidget {
  final List<ReorderRecommendation> recommendations;
  final VoidCallback? onGenerateOrder;

  const ReorderRecommendationsWidget({
    super.key,
    required this.recommendations,
    this.onGenerateOrder,
  });

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.inventoryCardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shopping_cart_outlined, color: AppColors.primaryCta),
              const SizedBox(width: 8),
              Text(
                'Reorder Recommendations',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (onGenerateOrder != null)
                Flexible(
                  child: ElevatedButton(
                    onPressed: onGenerateOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryCta,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Generate Order'),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Recommendations list
          ...recommendations.take(5).map((rec) => _buildRecommendationItem(rec)).toList(),
          
          if (recommendations.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '+ ${recommendations.length - 5} more items recommended for reorder',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(ReorderRecommendation recommendation) {
    final item = recommendation.item;
    final analysis = recommendation.analysis;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          // Item image
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              image: DecorationImage(
                image: AssetImage(item.imageUrl ?? 'assets/images/P151/P151_Menu_Images_Size Reduced/OnlyBurger.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Item details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Order ${recommendation.suggestedOrderQuantity.toStringAsFixed(0)} units',
                  style: TextStyle(
                    color: AppColors.primaryCta,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Current: ${item.currentStock.toStringAsFixed(0)} | Target: ${analysis.recommendedStockLevel.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          
          // Priority indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getPriorityColor(analysis.severity),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _getPriorityText(analysis.severity),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(LowStockSeverity severity) {
    switch (severity) {
      case LowStockSeverity.critical:
        return AppColors.error;
      case LowStockSeverity.high:
        return AppColors.warning;
      case LowStockSeverity.medium:
        return AppColors.accentBlue;
      case LowStockSeverity.low:
        return AppColors.success;
      case LowStockSeverity.normal:
        return AppColors.textSecondary;
    }
  }

  String _getPriorityText(LowStockSeverity severity) {
    switch (severity) {
      case LowStockSeverity.critical:
        return 'URGENT';
      case LowStockSeverity.high:
        return 'HIGH';
      case LowStockSeverity.medium:
        return 'MED';
      case LowStockSeverity.low:
        return 'LOW';
      case LowStockSeverity.normal:
        return 'NORM';
    }
  }
}
