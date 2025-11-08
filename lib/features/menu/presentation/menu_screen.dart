import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/theme/colors.dart';
import '../../menu/controllers/menu_controller.dart' as menu_ctrl;
import '../../../data/repositories/menu_repository.dart';
import '../../../core/cart/cart_scope.dart';
import '../../../core/app_flow/app_controllers.dart';
import '../../billing/presentation/billing_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late final menu_ctrl.MenuItemsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = menu_ctrl.MenuItemsController(CsvMenuRepository());
    _controller.load();
    _controller.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        backgroundColor: AppColors.bgSurface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: _SearchBar(controller: _controller),
            ),
            _CategoryChips(controller: _controller),
            const SizedBox(height: 16),
            Expanded(
              child: _MenuGrid(controller: _controller),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  final menu_ctrl.MenuItemsController controller;
  
  const _SearchBar({required this.controller});
  
  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  late TextEditingController _textController;
  
  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.controller.search);
  }
  
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _textController,
            onChanged: (value) {
              widget.controller.setSearch(value);
            },
            decoration: InputDecoration(
              hintText: 'Search delicious dishes...',
              hintStyle: TextStyle(color: AppColors.textSecondary),
              prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.cardSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryChips extends StatefulWidget {
  final menu_ctrl.MenuItemsController controller;
  
  const _CategoryChips({required this.controller});
  
  @override
  State<_CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<_CategoryChips> {
  // Categories aligned with CsvMenuRepository
  final categories = const [
    'All',
    'BURGERS',
    'BRIOCHE',
    'WINGS',
    'ORTAYA KARIŞIK',
    'BOWLS & COLESLAW',
    'WRAP',
    'TENDERS',
    "COMBO'S",
  ];
  Map<String, int> _counts = const {};
  bool _loadingCounts = false;
  
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    _loadCounts();
  }
  
  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }
  
  void _onControllerChanged() {
    setState(() {});
  }

  Future<void> _loadCounts() async {
    setState(() {
      _loadingCounts = true;
    });
    final repo = widget.controller.repository;
    final Map<String, int> next = {};
    for (final c in categories) {
      final items = await repo.getMenuItems(category: c);
      next[c] = items.length;
    }
    setState(() {
      _counts = next;
      _loadingCounts = false;
    });
  }
  
  int get selectedIndex {
    final currentCategory = widget.controller.category;
    return categories.indexOf(currentCategory);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(categories.length, (i) {
          final isSelected = i == selectedIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              selected: isSelected,
              showCheckmark: false,
              onSelected: (_) {
                widget.controller.setCategory(categories[i]);
              },
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) ...[
                    const Icon(Icons.check, size: 16, color: Colors.white),
                    const SizedBox(width: 4),
                  ],
                  Text(categories[i]),
                  const SizedBox(width: 6),
                  if (!_loadingCounts)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (isSelected ? Colors.white : AppColors.textPrimary).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (isSelected ? Colors.white : AppColors.border).withOpacity(0.4),
                        ),
                      ),
                      child: Text(
                        (_counts[categories[i]] ?? 0).toString().padLeft(2, '0'),
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              selectedColor: AppColors.primaryCta,
              backgroundColor: AppColors.cardSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primaryCta : AppColors.border,
                  width: 1,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _MenuGrid extends StatelessWidget {
  final menu_ctrl.MenuItemsController controller;
  
  const _MenuGrid({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.items.isEmpty) {
      return const Center(child: Text('No items available'));
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: controller.items.length,
        itemBuilder: (context, index) {
          final item = controller.items[index];
          return _MenuCard(item: item);
        },
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final dynamic item; // MenuItemModel
  
  const _MenuCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.asset(
                    item.imageUrl ?? 'assets/images/P151/P151_Menu_Images_Size Reduced/OnlyBurger.jpg',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.restaurant_menu, size: 48, color: Colors.grey[600]),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                item.name,
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Chef's Choice badge for some items
                if (item.name.contains('Grilled') || item.name.contains('Wood Roasted'))
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Chef's Choice",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Content section
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item.price.toStringAsFixed(0)} ${item.currency}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primaryCta,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Bottom plus icon
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _navigateToBilling(context);
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primaryCta.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primaryCta,
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.add,
                            color: AppColors.primaryCta,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToBilling(BuildContext context) {
    // Add item to cart before navigating
    final cart = AppControllers.cartController;
    cart.addItem(
      id: item.id,
      name: item.name,
      price: item.price,
      imageUrl: item.imageUrl,
    );
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CartScope(
          controller: AppControllers.cartController,
          child: const BillingScreen(),
        ),
      ),
    );
  }
}


