import 'package:flutter/material.dart';
import '../../../data/models/inventory_item_new.dart';
import '../../../data/repositories/inventory_repository.dart';
import '../../../app/theme/colors.dart';
import 'adjust_stock_screen.dart';
import 'add_item_screen.dart';
import '../../../core/app_flow/onboarding_service.dart';
import '../../../app/app.dart';
import 'dart:io';

class InventoryScreen extends StatefulWidget {
  final bool isSetupFlow; // true when launched from onboarding/splash setup
  const InventoryScreen({super.key, this.isSetupFlow = false});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<InventoryItemNew> _allItems = [];
  bool _isLoading = true;
  bool _isBoardView = true; // Default to board view
  final InventoryRepository _repository = InventoryRepository();

  @override
  void initState() {
    super.initState();
    _loadInventoryData();
  }

  Future<void> _loadInventoryData() async {
    try {
      print('Loading inventory data...');
      final items = await _repository.getAllItems();
      print('Loaded ${items.length} items');
      setState(() {
        _allItems = items;
        _isLoading = false;
      });

      // Only during setup flow: if items already exist and setup not completed, complete and go to main app
      final hasCompletedInventory = await OnboardingService.hasCompletedInventorySetup();
      if (widget.isSetupFlow && !hasCompletedInventory && items.isNotEmpty && mounted) {
        await OnboardingService.completeInventorySetup();
        // Navigate to main app root
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CluckCareApp()),
        );
      }
    } catch (e) {
      print('Error loading inventory: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    print('Building inventory screen: isLoading=$_isLoading, items=${_allItems.length}, boardView=$_isBoardView');
    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        elevation: 0,
        title: const Text(
          'Inventory',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: FloatingActionButton(
              onPressed: () async {
                // Navigate to add new item screen
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddItemScreen(),
                  ),
                );
                
                // If item was added, reload inventory
                if (result != null && mounted) {
                  // TODO: Refresh inventory list from database
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${result['name']} added successfully!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  _loadInventoryData();
                }
              },
              backgroundColor: AppColors.primaryCta,
              mini: true,
              child: const Icon(Icons.add, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryCta))
          : _allItems.isEmpty
              ? _buildInventoryList() // Setup screen (already scrollable)
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Summary Cards
                      _buildSummaryCards(),
                      
                      // View Toggle
                      _buildViewToggle(),
                      
                      // Inventory Content
                      _isBoardView ? _buildInventoryBoard() : _buildInventoryList(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.inventoryCardSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isBoardView = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isBoardView ? AppColors.secondaryCta : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Board',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isBoardView ? Colors.black : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isBoardView = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isBoardView ? AppColors.secondaryCta : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'List',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: !_isBoardView ? Colors.black : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    final totalItems = _allItems.length;
    final lowStockCount = _allItems.where((item) => item.stockStatus == 'low').length;
    final outOfStockCount = _allItems.where((item) => item.stockStatus == 'out').length;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total Items',
              totalItems.toString(),
              Icons.inventory_2,
              AppColors.accentBlue,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildSummaryCard(
              'Low Stock',
              lowStockCount.toString(),
              Icons.warning,
              AppColors.warning,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildSummaryCard(
              'Out of Stock',
              outOfStockCount.toString(),
              Icons.error,
              AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.inventoryCardSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryList() {
    if (_allItems.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            
            // Large Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryCta.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 60,
                color: AppColors.primaryCta,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Title
            const Text(
              'Setup Required',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 10),
            
            // Description
            const Text(
              'Your inventory is empty. Let\'s get started by adding your first item!',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Quick Setup Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showQuickSetupDialog();
                },
                icon: const Icon(Icons.flash_on, size: 22),
                label: const Text(
                  'Quick Setup',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryCta,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Helper Text
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.inventoryCardSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.accentBlue.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppColors.secondaryCta,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Quick Tips',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildTipRow('Add items for each ingredient you stock'),
                  _buildTipRow('Set par levels for ideal stock amounts'),
                  _buildTipRow('Define reorder points for alerts'),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      );
    }

    // Group items by category
    final groupedItems = <String, List<InventoryItemNew>>{};
    for (final item in _allItems) {
      groupedItems[item.category] = groupedItems[item.category] ?? [];
      groupedItems[item.category]!.add(item);
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: groupedItems.length,
      itemBuilder: (context, index) {
        final category = groupedItems.keys.elementAt(index);
        final items = groupedItems[category]!;
        
        return _buildCategorySection(category, items);
      },
    );
  }

  Widget _buildCategorySection(String category, List<InventoryItemNew> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              _getCategoryIcon(category),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        
        // Items in this category
        ...items.map((item) => _buildInventoryItem(item)),
        
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _getCategoryIcon(String category) {
    IconData iconData;
    Color iconColor;
    
    switch (category) {
      case 'Meats':
        iconData = Icons.restaurant;
        iconColor = AppColors.secondaryCta;
        break;
      case 'Other Meats':
        iconData = Icons.local_dining;
        iconColor = AppColors.error;
        break;
      case 'Vegetables & Starches':
        iconData = Icons.eco;
        iconColor = AppColors.success;
        break;
      case 'Dairy & Extras':
        iconData = Icons.local_drink;
        iconColor = AppColors.warning;
        break;
      case 'Bakery & Grains':
        iconData = Icons.grain;
        iconColor = const Color(0xFFD7CCC8);
        break;
      case 'Dessert Ingredients':
        iconData = Icons.cake;
        iconColor = const Color(0xFFF48FB1);
        break;
      case 'Sauces':
        iconData = Icons.local_fire_department;
        iconColor = AppColors.error;
        break;
      default:
        iconData = Icons.inventory;
        iconColor = AppColors.textSecondary;
    }
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: iconColor, size: 20),
    );
  }

  Widget _buildStockProgressBar(InventoryItemNew item) {
    // Calculate progress percentage (current stock vs par level)
    final progress = item.parLevel > 0 ? (item.currentStock / item.parLevel).clamp(0.0, 1.0) : 0.0;
    
    // Determine color based on stock status
    Color progressColor;
    switch (item.stockStatus) {
      case 'out':
        progressColor = Colors.red;
        break;
      case 'low':
        progressColor = Colors.orange;
        break;
      case 'medium':
        progressColor = Colors.blue;
        break;
      case 'high':
        progressColor = Colors.green;
        break;
      default:
        progressColor = AppColors.textSecondary;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        ),
        const SizedBox(height: 2),
        // Progress text
        Text(
          '${(progress * 100).toStringAsFixed(0)}% of par level',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryItem(InventoryItemNew item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.inventoryCardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(item.stockStatus).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Item Image
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: AppColors.border.withOpacity(0.3)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: _buildItemImage(
                item.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Log failing asset path for debugging
                  // ignore: avoid_print
                  print('Inventory List image load failed: ${item.imagePath} -> $error');
                  return Container(
                    color: AppColors.bgSurface,
                    child: const Icon(
                      Icons.image,
                      color: AppColors.textSecondary,
                      size: 24,
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.currentStock.toStringAsFixed(1)} ${item.unit} | Par: ${item.parLevel.toStringAsFixed(0)} | Reorder: ${item.reorderPoint.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Progress Bar
                _buildStockProgressBar(item),
              ],
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Status and Adjust Button Column
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: _getStatusColor(item.stockStatus).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _getStatusColor(item.stockStatus).withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Status Dot
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: _getStatusColor(item.stockStatus),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      _getStatusText(item.stockStatus),
                      style: TextStyle(
                        color: _getStatusColor(item.stockStatus),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 4),
              
              // Adjust Stock Button
              InkWell(
                onTap: () async {
                  // Navigate to adjust stock screen
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdjustStockScreen(item: item),
                    ),
                  );
                  
                  // If stock was adjusted, reload inventory
                  if (result != null && mounted) {
                    await _loadInventoryData();
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  child: const Icon(
                    Icons.tune,
                    color: AppColors.primaryCta,
                    size: 20,
                  ),
                ),
              ),
            ],
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

  // Render asset images or user-selected file images
  Widget _buildItemImage(String path, {BoxFit fit = BoxFit.cover, Widget Function(BuildContext, Object, StackTrace?)? errorBuilder}) {
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: fit,
        errorBuilder: errorBuilder,
      );
    }
    return Image.file(
      File(path),
      fit: fit,
      errorBuilder: errorBuilder,
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'high':
        return 'High';
      case 'medium':
        return 'Medium';
      case 'low':
        return 'Low';
      case 'out':
        return 'Out of Stock';
      default:
        return 'Unknown';
    }
  }

  String _removeBracketsFromName(String name) {
    // Remove text in brackets (including parentheses, square brackets, or curly brackets)
    return name.replaceAll(RegExp(r'\s*[\[\(].*?[\]\)]\s*'), '').trim();
  }

  Widget _buildTipRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 14,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
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

  void _showQuickSetupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.inventoryCardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.flash_on, color: AppColors.secondaryCta),
            const SizedBox(width: 8),
            const Text(
              'Quick Setup',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pre loaded Inventory Items.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Includes:',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildIncludeItem('✓ Meats (7 items)'),
                  _buildIncludeItem('✓ Other Meats (4 items)'),
                  _buildIncludeItem('✓ Vegetables & Starches (8 items)'),
                  _buildIncludeItem('✓ Dairy & Extras (5 items)'),
                  _buildIncludeItem('✓ Bakery & Grains (4 items)'),
                  _buildIncludeItem('✓ Dessert Ingredients (4 items)'),
                  _buildIncludeItem('✓ Sauces (7 items)'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'You can adjust quantities and remove items you don\'t need later.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performQuickSetup();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryCta,
              foregroundColor: AppColors.textPrimary,
            ),
            child: const Text('Load Items'),
          ),
        ],
      ),
    );
  }

  Widget _buildIncludeItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
      ),
    );
  }

  void _performQuickSetup() async {
    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 16),
            Text('Loading inventory items...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    // During setup flow, mark inventory setup as completed
    if (widget.isSetupFlow) {
      await OnboardingService.completeInventorySetup();
    }
    
    // Seed storage with fallback items to ensure non-empty inventory
    await _repository.seedWithFallback();

    // Load items after seeding
    List<InventoryItemNew> loaded = await _repository.getAllItems();

    if (mounted) {
      setState(() {
        _allItems = loaded;
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_allItems.length} items loaded successfully! 🎉'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );

      // Only navigate away to main app if this screen is part of setup flow
      if (widget.isSetupFlow) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CluckCareApp()),
        );
      }
    }
  }

  Widget _buildInventoryBoard() {
    print('Building inventory board with ${_allItems.length} items');
    
    // Group items by category
    final groupedItems = <String, List<InventoryItemNew>>{};
    for (final item in _allItems) {
      groupedItems[item.category] = groupedItems[item.category] ?? [];
      groupedItems[item.category]!.add(item);
    }

    print('Grouped items: ${groupedItems.keys.toList()}');

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: groupedItems.length,
      itemBuilder: (context, index) {
        final category = groupedItems.keys.elementAt(index);
        final items = groupedItems[category]!;
        
        print('Building category: $category with ${items.length} items');
        return _buildBoardCategorySection(category, items);
      },
    );
  }

  Widget _buildBoardCategorySection(String category, List<InventoryItemNew> items) {
    print('Building board category section: $category with ${items.length} items');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Header
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
          child: Row(
            children: [
              _getCategoryIcon(category),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        
        // Horizontal scrollable items in a continuous row with dashed separators
        SizedBox(
          height: 300,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.inventoryCardSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: items.isEmpty 
              ? const Center(
                  child: Text(
                    'No items in this category',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  separatorBuilder: (context, index) => Container(
                    width: 3,
                    height: 300, // Match the parent container height for full height dashes
                    margin: const EdgeInsets.symmetric(vertical: 0),
                    child: CustomPaint(
                      painter: DashedLinePainter(),
                    ),
                  ),
                  itemBuilder: (context, index) {
                    print('Building board item $index: ${items[index].name}');
                    return Container(
                      width: 170, // Increased width for better proportions with larger content
                      child: _buildBoardItemCard(items[index]),
                    );
                  },
                ),
          ),
        ),
        
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildBoardItemCard(InventoryItemNew item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), // Reduced vertical padding slightly
      // Removed individual card background - now part of continuous container
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Item Image
          Center(
            child: Container(
              width: 130,
              height: 90, // Reduced to prevent Column overflow
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border.withOpacity(0.3)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildItemImage(
                  item.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Log failing asset path for debugging
                    // ignore: avoid_print
                    print('Inventory Board image load failed: ${item.imagePath} -> $error');
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
          ),
          
          const SizedBox(height: 8), // Slightly reduced spacing
          
          // Quantity
          Text(
            '${item.currentStock.toStringAsFixed(1)} ${item.unit}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16, // Increased font size
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 5), // Reduced spacing
          
          // Item Name
          Text(
            _removeBracketsFromName(item.name),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14, // Increased font size
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 5), // Reduced spacing
          
          // Par Level
          Text(
            'Par: ${item.parLevel.toStringAsFixed(0)}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12, // Increased font size
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 3), // Reduced spacing between par and reorder
          
          // Reorder Point
          Text(
            'Reorder: ${item.reorderPoint.toStringAsFixed(0)}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12, // Increased font size
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 5), // Reduced spacing
          
          // Availability Status
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(item.stockStatus).withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${_getStatusText(item.stockStatus)}',
                style: TextStyle(
                  color: _getStatusColor(item.stockStatus),
                  fontSize: 12, // Increased font size
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          
          const SizedBox(height: 6), // Spacing before button
          
          // Adjust Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdjustStockScreen(item: item),
                  ),
                ).then((_) {
                  _loadInventoryData(); // Refresh data after adjustment
                });
              },
              icon: const Icon(Icons.build, size: 15), // Increased icon size
              label: const Text(
                'Adjust',
                style: TextStyle(
                  fontSize: 13, // Increased font size
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryCta,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12), // Slightly reduced vertical padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Increased border radius
                ),
                minimumSize: const Size(0, 36), // Slightly reduced button height
                tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Reduce tap target to minimize height
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textSecondary.withOpacity(0.8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    const dashHeight = 18.0;
    const dashSpace = 8.0;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(1.5, startY), // Center the line within the 3px width
        Offset(1.5, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}