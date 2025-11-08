import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../data/models/inventory_item.dart';
import '../services/stock_adjustment_service.dart';

class StockHistoryWidget extends StatelessWidget {
  final InventoryItem item;
  final List<StockAdjustment> stockHistory;

  const StockHistoryWidget({
    super.key,
    required this.item,
    required this.stockHistory,
  });

  @override
  Widget build(BuildContext context) {
    if (stockHistory.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No stock adjustments yet',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Stock adjustments will appear here',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final statistics = StockAdjustmentService.calculateStatistics(stockHistory);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Statistics header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.inventoryCardSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stock Adjustment Statistics',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Adjustments',
                      statistics.totalAdjustments.toString(),
                      Icons.timeline,
                      AppColors.primaryCta,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Net Change',
                      '${statistics.netChange >= 0 ? '+' : ''}${statistics.netChange.toStringAsFixed(0)}',
                      Icons.trending_up,
                      statistics.netChange >= 0 ? AppColors.success : AppColors.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Orders',
                      statistics.orderAdjustments.toString(),
                      Icons.shopping_cart,
                      AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Waste',
                      statistics.wasteAdjustments.toString(),
                      Icons.delete,
                      AppColors.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // History list
        Text(
          'Recent Adjustments',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stockHistory.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final adjustment = stockHistory[index];
            return _buildAdjustmentCard(adjustment);
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustmentCard(StockAdjustment adjustment) {
    final isIncrease = adjustment.quantityChange > 0;
    final adjustmentType = adjustment.adjustmentType;
    final typeColor = _getAdjustmentTypeColor(adjustmentType);
    final typeIcon = _getAdjustmentTypeIcon(adjustmentType);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    typeIcon,
                    color: typeColor,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        adjustment.reason,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _formatTimestamp(adjustment.timestamp),
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Quantity change
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isIncrease ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isIncrease ? Icons.add : Icons.remove,
                        color: isIncrease ? AppColors.success : AppColors.error,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${adjustment.quantityChange.abs().toStringAsFixed(0)}',
                        style: TextStyle(
                          color: isIncrease ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Details row
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Change: ${adjustment.quantityChange > 0 ? '+' : ''}${adjustment.quantityChange.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  'By: ${adjustment.adjustedBy}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            
            // Order ID if available
            if (adjustment.orderId != null) ...[
              const SizedBox(height: 4),
              Text(
                'Order: #${adjustment.orderId}',
                style: TextStyle(
                  color: AppColors.primaryCta,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            
            // Notes if available
            if (adjustment.notes != null && adjustment.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Notes: ${adjustment.notes}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getAdjustmentTypeColor(String adjustmentType) {
    switch (adjustmentType) {
      case 'order':
        return AppColors.success;
      case 'waste':
        return AppColors.error;
      case 'delivery':
        return AppColors.accentBlue;
      case 'correction':
        return AppColors.warning;
      case 'manual':
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getAdjustmentTypeIcon(String adjustmentType) {
    switch (adjustmentType) {
      case 'order':
        return Icons.shopping_cart;
      case 'waste':
        return Icons.delete;
      case 'delivery':
        return Icons.local_shipping;
      case 'correction':
        return Icons.edit;
      case 'manual':
      default:
        return Icons.settings;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
