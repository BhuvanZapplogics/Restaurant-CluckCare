import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/theme/colors.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/inventory_item_new.dart';
import '../../../data/repositories/inventory_repository.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _currentStockController = TextEditingController(text: '0');
  final _parLevelController = TextEditingController(text: '50');
  final _reorderPointController = TextEditingController(text: '10');
  
  String _selectedCategory = 'Meats';
  String _selectedUnit = 'kg';
  final InventoryRepository _repository = InventoryRepository();
  String? _pickedImagePath;
  final ImagePicker _picker = ImagePicker();
  
  final List<String> _categories = [
    'Meats',
    'Other Meats',
    'Vegetables & Starches',
    'Dairy & Extras',
    'Bakery & Grains',
    'Dessert Ingredients',
    'Sauces',
  ];
  
  final List<String> _units = [
    'kg',
    'liters',
    'pieces',
    'dozen',
    'grams',
    'ml',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _currentStockController.dispose();
    _parLevelController.dispose();
    _reorderPointController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (image != null) {
        setState(() {
          _pickedImagePath = image.path;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final currentStock = double.tryParse(_currentStockController.text) ?? 0.0;
      final parLevel = double.tryParse(_parLevelController.text) ?? 50.0;
      final reorderPoint = double.tryParse(_reorderPointController.text) ?? 10.0;

      // Compute stock status (mirrors model logic)
      String stockStatus;
      if (currentStock <= 0) {
        stockStatus = 'out';
      } else if (currentStock <= reorderPoint) {
        stockStatus = 'low';
      } else if (currentStock >= parLevel * 0.8) {
        stockStatus = 'high';
      } else {
        stockStatus = 'medium';
      }

      // Get an image suggestion via CSV helper, then override numeric fields
      final template = InventoryItemNew.fromCsvData(
        name: name,
        category: _selectedCategory,
        unit: _selectedUnit,
        initialStock: currentStock,
      );
      final newItem = template.copyWith(
        currentStock: currentStock,
        parLevel: parLevel,
        reorderPoint: reorderPoint,
        stockStatus: stockStatus,
        imagePath: _pickedImagePath ?? template.imagePath,
      );

      await _repository.addItem(newItem);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added $name to inventory'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context, {'name': name});
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        elevation: 0,
        title: const Text(
          'Add New Item',
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image picker / preview
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border.withOpacity(0.3)),
                        color: AppColors.bgSurface,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _pickedImagePath == null
                            ? const Icon(Icons.image, color: AppColors.textSecondary)
                            : Image.file(File(_pickedImagePath!), fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Add Photo'),
                      style: TextButton.styleFrom(foregroundColor: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              // Item Name
              _buildTextField(
                label: 'Item Name',
                controller: _nameController,
                hint: 'e.g., Chicken Wings',
                icon: Icons.inventory_2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter item name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Category and Unit Row
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: 'Category',
                      value: _selectedCategory,
                      items: _categories,
                      icon: Icons.category,
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdown(
                      label: 'Unit',
                      value: _selectedUnit,
                      items: _units,
                      icon: Icons.straighten,
                      onChanged: (value) {
                        setState(() {
                          _selectedUnit = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Current Stock
              _buildNumberField(
                label: 'Current Stock',
                controller: _currentStockController,
                icon: Icons.inventory,
                color: AppColors.accentBlue,
              ),
              
              const SizedBox(height: 20),
              
              // Par Level
              _buildNumberField(
                label: 'Par Level (Target Stock)',
                controller: _parLevelController,
                icon: Icons.analytics_outlined,
                color: AppColors.success,
              ),
              
              const SizedBox(height: 20),
              
              // Reorder Point
              _buildNumberField(
                label: 'Reorder Point (Alert Level)',
                controller: _reorderPointController,
                icon: Icons.notification_important,
                color: AppColors.warning,
              ),
              
              const SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveItem,
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
                      Icon(Icons.add_circle, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Add Item',
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
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primaryCta, size: 20),
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
        TextFormField(
          controller: controller,
          validator: validator,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            filled: true,
            fillColor: AppColors.bgSurface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryCta, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.secondaryCta, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withOpacity(0.3)),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              );
            }).toList(),
            onChanged: onChanged,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
            dropdownColor: AppColors.inventoryCardSurface,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Color color,
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
              child: TextFormField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
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
                  suffixText: _selectedUnit,
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
}

