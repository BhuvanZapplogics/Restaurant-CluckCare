import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/inventory_item_new.dart';
import '../../../data/repositories/inventory_repository.dart';
import '../../../app/theme/colors.dart';
import 'dart:io';

class AdjustStockScreen extends StatefulWidget {
  final InventoryItemNew item;

  const AdjustStockScreen({super.key, required this.item});

  @override
  State<AdjustStockScreen> createState() => _AdjustStockScreenState();
}

class _AdjustStockScreenState extends State<AdjustStockScreen> {
  late TextEditingController _currentStockController;
  late TextEditingController _parLevelController;
  late TextEditingController _reorderPointController;
  final InventoryRepository _repository = InventoryRepository();
  String? _parErrorText;
  String? _reorderErrorText;
  
  @override
  void initState() {
    super.initState();
    _currentStockController = TextEditingController(
      text: widget.item.currentStock.toStringAsFixed(1),
    );
    _parLevelController = TextEditingController(
      text: widget.item.parLevel.toStringAsFixed(0),
    );
    _reorderPointController = TextEditingController(
      text: widget.item.reorderPoint.toStringAsFixed(0),
    );

    // Live validation listeners
    _parLevelController.addListener(_validateParVsReorder);
    _reorderPointController.addListener(_validateParVsReorder);

    // Initial validation state
    _validateParVsReorder();
  }

  @override
  void dispose() {
    _currentStockController.dispose();
    _parLevelController.dispose();
    _reorderPointController.dispose();
    super.dispose();
  }

  void _validateParVsReorder() {
    final parLevel = double.tryParse(_parLevelController.text);
    final reorderPoint = double.tryParse(_reorderPointController.text);

    String? parErr;
    String? reorderErr;

    if (parLevel != null && reorderPoint != null) {
      if (parLevel <= reorderPoint) {
        parErr = 'Target Stock must be > Reorder Point';
        reorderErr = 'Reorder Point must be < Target Stock';
      }
    }

    if (parErr != _parErrorText || reorderErr != _reorderErrorText) {
      setState(() {
        _parErrorText = parErr;
        _reorderErrorText = reorderErr;
      });
    }
  }

  Future<void> _saveChanges() async {
    try {
      // Parse the values from text controllers
      final currentStock = double.tryParse(_currentStockController.text) ?? widget.item.currentStock;
      final parLevel = double.tryParse(_parLevelController.text) ?? widget.item.parLevel;
      final reorderPoint = double.tryParse(_reorderPointController.text) ?? widget.item.reorderPoint;

      // Validate: Par Level (Target Stock) must be greater than Reorder Point
      if (parLevel <= reorderPoint) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Par Level (Target Stock) must be greater than Reorder Point'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      // Calculate new stock status based on updated values
      String newStockStatus;
      if (currentStock <= 0) {
        newStockStatus = 'out';
      } else if (currentStock <= reorderPoint) {
        newStockStatus = 'low';
      } else if (currentStock >= parLevel * 0.8) {
        newStockStatus = 'high';
      } else {
        newStockStatus = 'medium';
      }

      // Create updated item
      final updatedItem = widget.item.copyWith(
        currentStock: currentStock,
        parLevel: parLevel,
        reorderPoint: reorderPoint,
        stockStatus: newStockStatus,
      );

      // Save to repository
      await _repository.updateItem(updatedItem);
      
      print('Stock updated for ${widget.item.name}:');
      print('  Current Stock: $currentStock ${widget.item.unit}');
      print('  Par Level: $parLevel ${widget.item.unit}');
      print('  Reorder Point: $reorderPoint ${widget.item.unit}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stock adjusted for ${widget.item.name}'),
            backgroundColor: AppColors.success,
          ),
        );
        
        // Return true to indicate changes were made
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('Error saving stock changes: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving changes: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        elevation: 0,
        title: const Text(
          'Adjust Stock',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Info Card
            _buildItemInfoCard(),
            
            const SizedBox(height: 24),
            
            // Current Stock Input
            _buildInputField(
              label: 'Current Stock',
              controller: _currentStockController,
              hint: 'Enter current stock quantity',
              icon: Icons.inventory,
              color: AppColors.accentBlue,
            ),
            
            const SizedBox(height: 16),
            
            // Par Level Input
            _buildInputField(
              label: 'Par Level (Target Stock)',
              controller: _parLevelController,
              hint: 'Enter ideal maximum stock',
              icon: Icons.analytics_outlined,
              color: AppColors.success,
              errorText: _parErrorText,
              onChanged: (_) => _validateParVsReorder(),
            ),
            
            const SizedBox(height: 16),
            
            // Reorder Point Input
            _buildInputField(
              label: 'Reorder Point (Alert Level)',
              controller: _reorderPointController,
              hint: 'Enter reorder alert level',
              icon: Icons.notification_important,
              color: AppColors.warning,
              errorText: _reorderErrorText,
              onChanged: (_) => _validateParVsReorder(),
            ),
            
            const SizedBox(height: 24),
            
            // Info Text
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.inventoryCardSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.accentBlue, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Stock Level Guide',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    '🟢 High Stock:',
                    'When stock is ≥ 80% of Par Level',
                  ),
                  _buildInfoRow(
                    '🟠 Medium Stock:',
                    'Between Reorder Point and 80% of Par',
                  ),
                  _buildInfoRow(
                    '🔴 Low Stock:',
                    'At or below Reorder Point',
                  ),
                  _buildInfoRow(
                    '⚫ Out of Stock:',
                    'When quantity reaches 0',
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryCta,
                  foregroundColor: AppColors.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.inventoryCardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Item Image
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              border: Border.all(color: AppColors.border.withOpacity(0.3)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: widget.item.imagePath.startsWith('assets/')
                  ? Image.asset(
                      widget.item.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.bgSurface,
                          child: const Icon(
                            Icons.image,
                            color: AppColors.textSecondary,
                            size: 32,
                          ),
                        );
                      },
                    )
                  : Image.file(
                      File(widget.item.imagePath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.bgSurface,
                          child: const Icon(
                            Icons.image,
                            color: AppColors.textSecondary,
                            size: 32,
                          ),
                        );
                      },
                    ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.item.category,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(widget.item.stockStatus).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Unit: ${widget.item.unit}',
                    style: TextStyle(
                      color: _getStatusColor(widget.item.stockStatus),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _incrementValue(TextEditingController controller, double step) {
    final currentValue = double.tryParse(controller.text) ?? 0.0;
    final newValue = currentValue + step;
    controller.text = newValue.toStringAsFixed(step < 1 ? 1 : 0);
  }

  void _decrementValue(TextEditingController controller, double step) {
    final currentValue = double.tryParse(controller.text) ?? 0.0;
    final newValue = (currentValue - step).clamp(0.0, double.infinity);
    controller.text = newValue.toStringAsFixed(step < 1 ? 1 : 0);
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color color,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Minus Button
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: IconButton(
                onPressed: () => _decrementValue(controller, 1),
                icon: Icon(Icons.remove, color: color),
                tooltip: 'Decrease',
                padding: const EdgeInsets.all(12),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Text Field
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                onChanged: onChanged,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.5),
                    fontSize: 16,
                  ),
                  filled: true,
                  fillColor: AppColors.bgSurface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: color.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: color.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: color, width: 2),
                  ),
                  errorText: errorText,
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  suffixText: widget.item.unit,
                  suffixStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Plus Button
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: IconButton(
                onPressed: () => _incrementValue(controller, 1),
                icon: Icon(Icons.add, color: color),
                tooltip: 'Increase',
                padding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'high':
        return AppColors.success;
      case 'medium':
        return AppColors.warning;
      case 'low':
        return AppColors.warning;
      case 'out':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}

