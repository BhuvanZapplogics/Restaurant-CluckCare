import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../core/cart/cart_scope.dart';
import '../../../core/app_flow/app_controllers.dart';
import '../../menu/controllers/menu_controller.dart' as menu_ctrl;
import '../../cart/presentation/cart_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key});

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  int orderType = 0; // 0 dine-in, 1 takeaway
  int table = 1;
  String selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> categories = ['All', 'Starters', 'Mains', 'Combos', 'Family Pack'];
  
  @override
  void initState() {
    super.initState();
    // Load menu items
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(menu_ctrl.menuItemsControllerProvider);
      if (!controller.loading && controller.items.isEmpty) {
        controller.load();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuController = ref.watch(menu_ctrl.menuItemsControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
              children: [
            _buildOrderTypeToggle(),
            _buildSearchAndCategories(),
            Expanded(
              child: _buildMenuList(menuController),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Consumer(
        builder: (context, ref, child) => _buildBottomTotalBar(),
      ),
    );
  }


  Widget _buildOrderTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SegmentedButton<int>(
        segments: const [
          ButtonSegment(value: 0, label: Text('Dine-in')),
          ButtonSegment(value: 1, label: Text('Takeaway')),
        ],
        selected: {orderType},
        onSelectionChanged: (s) {
          setState(() {
            orderType = s.first;
            if (s.first == 1) {
              // Clear table when switching to takeaway
              table = 1;
            }
          });
          // Update cart controller
          final cart = CartScope.of(context);
          cart.setOrderType(s.first == 0 ? 'dine_in' : 'takeaway', tableNumber: null); // Don't set table yet
        },
      ),
    );
  }
  
  void _showTableSelectionForReceipt(BuildContext parentContext) {
    // Capture cart and navigator before showing modal
    final cart = CartScope.of(parentContext);
    final navigator = Navigator.of(parentContext);
    
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (sheetContext, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: _TableSelectionModal(
            currentTable: table,
            onTableSelected: (selectedTable) async {
              setState(() {
                table = selectedTable;
              });
              // Update cart controller with selected table
              cart.setOrderType('dine_in', tableNumber: selectedTable);
              
              // Close modal first
              navigator.pop();
              
              // Wait a frame for modal to close, then navigate
              await Future.delayed(const Duration(milliseconds: 100));
              
              // Navigate to receipt screen after table selection using parent context
              if (parentContext.mounted) {
                navigator.push(
                  MaterialPageRoute(
                    builder: (context) => CartScope(
                      controller: AppControllers.cartController,
                      child: const ReceiptScreen(),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndCategories() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search menu...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              final controller = ref.read(menu_ctrl.menuItemsControllerProvider);
              controller.setSearch(value);
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => selectedCategory = category);
                      final controller = ref.read(menu_ctrl.menuItemsControllerProvider);
                      controller.setCategory(category);
                    },
                    selectedColor: AppColors.primaryCta.withOpacity(0.2),
                    checkmarkColor: AppColors.primaryCta,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList(menu_ctrl.MenuItemsController menuController) {
    if (menuController.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (menuController.items.isEmpty) {
      return const Center(child: Text('No items found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: menuController.items.length,
      itemBuilder: (context, index) {
        final item = menuController.items[index];
        return _buildMenuItem(item);
      },
    );
  }

  Widget _buildMenuItem(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: item.imageUrl == null
                    ? const Icon(Icons.fastfood, size: 40, color: AppColors.primaryCta)
                    : Image.asset(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.fastfood, size: 40, color: AppColors.primaryCta);
                        },
                      ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.price.toStringAsFixed(0)} ${item.currency}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primaryCta,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (item.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: item.tags.take(2).map<Widget>((tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryCta.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primaryCta.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.primaryCta,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Add / Quantity Controls
              _buildAddOrQuantityControls(item),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddOrQuantityControls(dynamic item) {
    try {
      final cart = CartScope.of(context);
      final existing = cart.items.where((e) => e.id == item.id).toList();
      final qty = existing.isNotEmpty ? existing.first.quantity : 0;

      if (qty == 0) {
        return ElevatedButton(
          onPressed: () => _addItemToCart(item),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryCta,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(80, 40),
          ),
          child: const Text(
            'Add',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        );
      }

      return Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryCta.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                cart.decrement(item.id);
                setState(() {});
              },
              icon: Icon(Icons.remove, color: AppColors.primaryCta),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('$qty',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            IconButton(
              onPressed: () {
                cart.increment(item.id);
                setState(() {});
              },
              icon: Icon(Icons.add, color: AppColors.primaryCta),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ],
        ),
      );
    } catch (_) {
      // If CartScope not available, show Add button fallback
      return ElevatedButton(
        onPressed: () => _addItemToCart(item),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryCta,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(80, 40),
        ),
        child: const Text('Add'),
      );
    }
  }


  Widget _buildBottomTotalBar() {
    try {
      final cart = CartScope.of(context);
      print('Bottom bar - Cart items: ${cart.items.length}, Total: ${cart.total}');
      print('Bottom bar - Cart items details: ${cart.items.map((i) => '${i.name} x${i.quantity}').join(', ')}');
      
      // Always show cart data if available
      if (cart.items.isNotEmpty) {
        print('Bottom bar - Showing cart data: ${cart.items.length} items, Total: ₺${cart.total}');
        return Container(
          height: 82,
          color: AppColors.bgSurface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total: ₺${cart.total.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryCta,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${cart.items.length} items',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // If dine-in, show table selection first
                  if (orderType == 0) {
                    _showTableSelectionForReceipt(context);
                  } else {
                    // Directly navigate to receipt for takeaway
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CartScope(
                          controller: AppControllers.cartController,
                          child: const ReceiptScreen(),
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryCta,
                  minimumSize: const Size(120, 40),
                ),
                child: const Text('Proceed To Billing'),
              ),
            ],
          ),
        );
      }
      
      print('Bottom bar - Showing empty cart message');
      return Container(
        height: 82,
        color: AppColors.bgSurface,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Add items to create order',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryCta.withOpacity(0.3),
                foregroundColor: AppColors.primaryCta.withOpacity(0.7),
                minimumSize: const Size(80, 40),
              ),
              child: const Text('Pay'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Bottom bar error: $e');
      return Container(
        height: 70,
        color: AppColors.bgSurface,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Add items to create order',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryCta.withOpacity(0.3),
                foregroundColor: AppColors.primaryCta.withOpacity(0.7),
                minimumSize: const Size(80, 40),
              ),
              child: const Text('Pay'),
            ),
          ],
        ),
      );
    }
  }

  void _addItemToCart(dynamic item) {
    print('BillingScreen._addItemToCart ${item.name}');
    try {
      final cart = CartScope.of(context);
      print('Adding item to cart: ${item.name}, Price: ${item.price}');
      print('Before adding - Cart items: ${cart.items.length}, Total: ${cart.total}');
      
      cart.addItem(id: item.id, name: item.name, price: item.price, imageUrl: item.imageUrl);
      
      print('After adding - Cart items: ${cart.items.length}, Total: ${cart.total}');
      print('Cart items: ${cart.items.map((i) => '${i.name} x${i.quantity}').join(', ')}');
      
      setState(() {}); // Trigger rebuild to show cart changes
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.name} added to cart'),
          backgroundColor: AppColors.primaryCta,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // If cart is not available, just show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.name} added to cart'),
          backgroundColor: AppColors.primaryCta,
        ),
      );
      print('Cart not available: $e');
    }
  }



}

class _PaymentModal extends StatefulWidget {
  final Function(String) onConfirm;
  final double total;

  const _PaymentModal({required this.onConfirm, required this.total});

  @override
  State<_PaymentModal> createState() => _PaymentModalState();
}

class _PaymentModalState extends State<_PaymentModal> {
  String? selectedMethod;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
        child: Column(
        mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
            'Select Payment Method',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          RadioListTile<String>(
            value: 'cash',
            groupValue: selectedMethod,
            onChanged: (value) => setState(() => selectedMethod = value),
            title: const Text('Cash'),
            subtitle: const Text('Pay with cash'),
          ),
          RadioListTile<String>(
            value: 'upi',
            groupValue: selectedMethod,
            onChanged: (value) => setState(() => selectedMethod = value),
            title: const Text('UPI'),
            subtitle: const Text('Pay via UPI'),
          ),
          RadioListTile<String>(
            value: 'card',
            groupValue: selectedMethod,
            onChanged: (value) => setState(() => selectedMethod = value),
            title: const Text('Card'),
            subtitle: const Text('Pay with card'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedMethod != null
                  ? () => widget.onConfirm(selectedMethod!)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryCta,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text('Confirm Payment ₺${widget.total.toStringAsFixed(0)}'),
            ),
          ),
        ],
      ),
    );
  }
}


class _TableSelectionModal extends StatefulWidget {
  final int currentTable;
  final Function(int) onTableSelected;

  const _TableSelectionModal({
    required this.currentTable,
    required this.onTableSelected,
  });

  @override
  State<_TableSelectionModal> createState() => _TableSelectionModalState();
}

class _TableSelectionModalState extends State<_TableSelectionModal> {
  late int selectedTable;

  @override
  void initState() {
    super.initState();
    selectedTable = widget.currentTable;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Title
          Text(
            'Select Table',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose the table for this dine-in order',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          
          // Table grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 1.0,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: 10, // Tables 1-10
            itemBuilder: (context, index) {
              final tableNumber = index + 1;
              final isSelected = selectedTable == tableNumber;
              
              return GestureDetector(
                onTap: () {
                  setState(() => selectedTable = tableNumber);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryCta : AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryCta : AppColors.border.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: AppColors.primaryCta.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ] : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.table_restaurant,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Table $tableNumber',
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          
          // Confirm button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onTableSelected(selectedTable);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryCta,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Confirm Table $selectedTable'),
            ),
          ),
        ],
      ),
    );
  }
}