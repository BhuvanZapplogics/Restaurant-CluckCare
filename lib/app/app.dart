import 'package:flutter/material.dart';
import '../features/home/presentation/dashboard_screen.dart';
import '../features/menu/presentation/menu_screen.dart';
import '../features/orders/presentation/orders_screen.dart';
import '../features/inventory/presentation/inventory_screen.dart';
import '../features/staff/presentation/staff_screen.dart';
import '../core/cart/cart_scope.dart';
import '../features/orders/controllers/orders_scope.dart';
import '../core/app_flow/app_controllers.dart';
import '../app/theme/colors.dart';
 

class CluckCareApp extends StatefulWidget {
  final int initialTabIndex;
  const CluckCareApp({super.key, this.initialTabIndex = 0});

  @override
  State<CluckCareApp> createState() => _CluckCareAppState();
}

class _CluckCareAppState extends State<CluckCareApp> {
  @override
  void initState() {
    super.initState();
    // Initialize controllers immediately and synchronously
    AppControllers.initialize();
  }

  @override
  void dispose() {
    // Dispose controllers and close Hive boxes when app is disposed
    AppControllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get controllers - they should be ready now
    final cartController = AppControllers.cartController;
    final ordersController = AppControllers.ordersController;
    final inventoryRepository = AppControllers.inventoryRepository;
    
    print('JusteFriedChickenApp.build() called');
    print('CartController: $cartController');
    print('OrdersController: $ordersController');
    print('InventoryRepository: $inventoryRepository');
    
    // Verify controllers are available
    print('OrdersController is available: ${ordersController.runtimeType}');
    
    return CartScope(
      controller: cartController,
      child: OrdersScope(
        controller: ordersController,
        child: RootScaffold(initialIndex: widget.initialTabIndex),
      ),
    );
  }
}

class RootScaffold extends StatefulWidget {
  final int initialIndex;
  RootScaffold({super.key, this.initialIndex = 0});

  @override
  State<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold> {
  late int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildTabContent(_currentIndex),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.bgSurface,
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.restaurant_menu_outlined), selectedIcon: Icon(Icons.restaurant_menu), label: 'Menu'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Inventory'),
          NavigationDestination(icon: Icon(Icons.group_outlined), selectedIcon: Icon(Icons.group), label: 'Staff'),
        ],
      ),
    );
  }

  Widget _buildTabContent(int index) {
    print('_buildTabContent called with index: $index');
    
    switch (index) {
      case 0:
        return DashboardScreen();
      case 1:
        return MenuScreen();
      case 2:
        // Ensure Orders tab always has OrdersScope in context
        final ordersController = AppControllers.ordersController;
        print('Building Orders tab with controller: $ordersController');
        return OrdersScope(
          controller: ordersController,
          child: OrdersScreen(),
        );
      case 3:
        return const InventoryScreen();
      case 4:
        return const StaffScreen();
      default:
        return DashboardScreen();
    }
  }
}


// Screens moved to feature folders

// (Dashboard widgets moved into features/home/presentation/dashboard_screen.dart)

// (Quick actions moved into features/home/presentation/dashboard_screen.dart)



