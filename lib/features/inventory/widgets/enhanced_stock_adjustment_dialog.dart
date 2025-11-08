import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../data/models/inventory_item.dart';
import '../services/stock_adjustment_service.dart';

class EnhancedStockAdjustmentDialog extends StatefulWidget {
  final InventoryItem item;
  final Function(StockAdjustmentRequest) onAdjust;

  const EnhancedStockAdjustmentDialog({
    super.key,
    required this.item,
    required this.onAdjust,
  });

  @override
  State<EnhancedStockAdjustmentDialog> createState() => _EnhancedStockAdjustmentDialogState();
}

class _EnhancedStockAdjustmentDialogState extends State<EnhancedStockAdjustmentDialog> {
  late TextEditingController _quantityController;
  late TextEditingController _reasonController;
  late TextEditingController _notesController;
  late TextEditingController _adjustedByController;
  
  String _selectedReason = '';
  bool _isIncrease = true;
  
  AdjustmentValidationResult? _validationResult;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController();
    _reasonController = TextEditingController();
    _notesController = TextEditingController();
    _adjustedByController = TextEditingController(text: 'Staff Member'); // Default value
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    _notesController.dispose();
    _adjustedByController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Header
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: AssetImage(widget.item.imageUrl ?? 'assets/images/P151/P151_Menu_Images_Size Reduced/OnlyBurger.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Current Stock: ${widget.item.currentStock.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        'Par Level: ${widget.item.parLevel.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Adjustment type toggle
            _buildAdjustmentTypeToggle(),
            
            const SizedBox(height: 20),
            
            // Quantity input
            _buildQuantityInput(),
            
            const SizedBox(height: 16),
            
            // Reason selection
            _buildReasonSelection(),
            
            const SizedBox(height: 16),
            
            // Adjusted by
            _buildAdjustedByInput(),
            
            const SizedBox(height: 16),
            
            // Notes (optional)
            _buildNotesInput(),
            
            const SizedBox(height: 20),
            
            // Validation warnings/errors
            if (_validationResult != null) _buildValidationMessages(),
            
            const SizedBox(height: 24),
            
              // Action buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdjustmentTypeToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Adjustment Type',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTypeButton(
                'Increase',
                Icons.add,
                AppColors.success,
                true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeButton(
                'Decrease',
                Icons.remove,
                AppColors.error,
                false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeButton(String label, IconData icon, Color color, bool isIncrease) {
    final isSelected = _isIncrease == isIncrease;
    
    return InkWell(
      onTap: () {
        setState(() {
          _isIncrease = isIncrease;
          _validateAdjustment();
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.inventoryCardSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quantity ${_isIncrease ? 'to Add' : 'to Remove'}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _quantityController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter quantity',
            prefixIcon: Icon(_isIncrease ? Icons.add : Icons.remove),
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) => _validateAdjustment(),
        ),
      ],
    );
  }

  Widget _buildReasonSelection() {
    final suggestions = StockAdjustmentService.suggestReasons(
      item: widget.item,
      delta: _getDelta(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reason *',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        
        // Quick reason buttons
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions.map((reason) {
            final isSelected = _selectedReason == reason;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedReason = reason;
                  _reasonController.text = reason;
                  _validateAdjustment();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryCta : AppColors.inventoryCardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryCta : AppColors.border,
                  ),
                ),
                child: Text(
                  reason,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        
        const SizedBox(height: 12),
        
        // Custom reason input
        TextField(
          controller: _reasonController,
          decoration: const InputDecoration(
            hintText: 'Or enter custom reason',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              if (_selectedReason != value) {
                _selectedReason = '';
              }
              _validateAdjustment();
            });
          },
        ),
      ],
    );
  }

  Widget _buildAdjustedByInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Adjusted By',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _adjustedByController,
          decoration: const InputDecoration(
            hintText: 'Enter staff name',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Notes (Optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: 'Any additional details...',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildValidationMessages() {
    if (_validationResult == null) return const SizedBox.shrink();

    return Column(
      children: [
        // Errors
        if (_validationResult!.errors.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.error, color: AppColors.error, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Validation Errors',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ..._validationResult!.errors.map((error) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• $error',
                    style: TextStyle(color: AppColors.error, fontSize: 12),
                  ),
                )),
              ],
            ),
          ),
        
        // Warnings
        if (_validationResult!.warnings.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.warning),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning, color: AppColors.warning, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Warnings',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ..._validationResult!.warnings.map((warning) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• $warning',
                    style: TextStyle(color: AppColors.warning, fontSize: 12),
                  ),
                )),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    final isValid = _validationResult?.isValid ?? false;
    
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: isValid ? _submitAdjustment : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isIncrease ? AppColors.success : AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text('${_isIncrease ? 'Increase' : 'Decrease'} Stock'),
          ),
        ),
      ],
    );
  }

  double _getDelta() {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    return _isIncrease ? quantity : -quantity;
  }

  void _validateAdjustment() {
    final delta = _getDelta();
    final reason = _reasonController.text.trim();
    
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    if (quantity > 0 && reason.isNotEmpty) {
      _validationResult = StockAdjustmentService.validateAdjustment(
        item: widget.item,
        delta: delta,
        reason: reason,
      );
    } else {
      _validationResult = null;
    }
    
    setState(() {});
  }

  void _submitAdjustment() {
    if (_validationResult?.isValid == true) {
      final delta = _getDelta();
      final request = StockAdjustmentRequest(
        itemId: widget.item.id,
        delta: delta,
        reason: _reasonController.text.trim(),
        adjustedBy: _adjustedByController.text.trim(),
        notes: _notesController.text.trim(),
      );
      
      widget.onAdjust(request);
      Navigator.of(context).pop();
    }
  }
}

class StockAdjustmentRequest {
  final String itemId;
  final double delta;
  final String reason;
  final String adjustedBy;
  final String notes;

  const StockAdjustmentRequest({
    required this.itemId,
    required this.delta,
    required this.reason,
    required this.adjustedBy,
    required this.notes,
  });
}
