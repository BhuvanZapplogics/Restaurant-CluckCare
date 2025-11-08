import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/colors.dart';
import '../../menu/controllers/menu_controller.dart' as menu_ctrl;
import '../../../core/cart/cart_scope.dart';
import '../../billing/presentation/billing_screen.dart';
import '../../orders/controllers/orders_scope.dart';
import '../../../core/app_flow/app_controllers.dart';

class NewOrderScreen extends ConsumerStatefulWidget {
  const NewOrderScreen({super.key});

  @override
  ConsumerState<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends ConsumerState<NewOrderScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String selectedCategory = 'All';
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<String> categories = ['All', 'Starters', 'Mains', 'Combos', 'Family Pack'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(menu_ctrl.menuItemsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Order'),
        backgroundColor: AppColors.bgSurface,
      ),
      backgroundColor: AppColors.bgScreen,
      body: Column(
        children: [
          _buildSearchAndCategories(),
          Expanded(
            child: _buildMenuList(controller),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomCartBar(),
    );
  }

  Widget _buildSearchAndCategories() {
    return Container(
        padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search menu...',
              hintStyle: TextStyle(color: AppColors.textSecondary),
              prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.cardSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            style: TextStyle(color: AppColors.textPrimary),
            onChanged: (value) {
              final controller = ref.read(menu_ctrl.menuItemsControllerProvider);
              controller.setSearch(value);
            },
          ),
          const SizedBox(height: 12),
          // Category chips
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
                    label: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => selectedCategory = category);
                      final controller = ref.read(menu_ctrl.menuItemsControllerProvider);
                      controller.setCategory(category);
                    },
                    selectedColor: AppColors.primaryCta,
                    checkmarkColor: Colors.white,
                    backgroundColor: AppColors.cardSurface,
                    side: BorderSide(color: AppColors.cardSurface),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList(menu_ctrl.MenuItemsController controller) {
    if (controller.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (controller.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No items found',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search or category',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => controller.load(),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.secondaryCta),
              ),
              child: const Text('Reload'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.items.length,
                  itemBuilder: (context, index) {
                    final item = controller.items[index];
        return _buildMenuItem(item);
      },
    );
  }

  Widget _buildMenuItem(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: AppColors.cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showItemDetail(item),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Food image with gradient overlay
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        if (item.imageUrl != null)
                          Image.asset(
                            item.imageUrl,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildImagePlaceholder();
                            },
                          )
                        else
                          _buildImagePlaceholder(),
                        // Gradient overlay for text readability
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.3),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Item details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
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
                          spacing: 4,
                          children: item.tags.take(2).map<Widget>((tag) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentBlue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.accentBlue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                // Quick-add button
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: ElevatedButton(
                        onPressed: () => _addItemToCart(item),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryCta,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(60, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 2,
                        ),
                        child: const Text('Add'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.fastfood,
        color: AppColors.primaryCta,
        size: 32,
      ),
    );
  }

  Widget _buildBottomCartBar() {
    return Container(
      height: 80,
      color: AppColors.bgSurface,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add items to cart',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Tap "Add" on menu items',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _goToBilling,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryCta,
              foregroundColor: Colors.white,
              minimumSize: const Size(120, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text('Go to Billing'),
          ),
        ],
      ),
    );
  }

  void _addItemToCart(dynamic item) async {
    // Quick-add animation
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    try {
      // Try to access cart, but don't fail if not available
      final cart = CartScope.of(context);
      cart.addItem(id: item.id, name: item.name, price: item.price);
      
      // Show toast with flying animation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added: ${item.name} ×1'),
          backgroundColor: AppColors.primaryCta,
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } catch (e) {
      // If cart is not available, just show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added: ${item.name} ×1 (Cart not available)'),
          backgroundColor: AppColors.primaryCta,
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      print('Cart not available: $e');
    }
  }

  void _showItemDetail(dynamic item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
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
            // Item image
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: item.imageUrl != null
                      ? Image.asset(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildImagePlaceholder();
                          },
                        )
                      : _buildImagePlaceholder(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Item details
            Text(
              item.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${item.price.toStringAsFixed(0)} ${item.currency}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primaryCta,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (item.description != null) ...[
              const SizedBox(height: 12),
              Text(
                item.description,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
            if (item.tags.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: item.tags.map<Widget>((tag) => Chip(
                  label: Text(tag),
                  backgroundColor: AppColors.accentBlue.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: AppColors.accentBlue,
                    fontSize: 12,
                  ),
                )).toList(),
              ),
            ],
            const SizedBox(height: 24),
            // Add to cart button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _addItemToCart(item);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryCta,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text('Add to Cart'),
                ),
              ),
          ],
        ),
      ),
    );
  }


  void _goToBilling() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CartScope(
          controller: AppControllers.cartController,
          child: OrdersScope(
            controller: AppControllers.ordersController,
            child: const BillingScreen(),
          ),
        ),
      ),
    );
  }
}
