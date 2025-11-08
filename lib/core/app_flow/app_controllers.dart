import 'package:hive_flutter/hive_flutter.dart';
import '../cart/cart_controller.dart';
import '../../features/orders/controllers/orders_controller.dart';
import '../../data/repositories/orders_repository.dart';
import '../../data/repositories/inventory_repository.dart';

/// Singleton controllers to prevent recreation on widget rebuilds
class AppControllers {
  static final AppControllers _instance = AppControllers._internal();
  factory AppControllers() => _instance;
  AppControllers._internal();

  static CartController? _cartController;
  static OrdersController? _ordersController;
  static InventoryRepository? _inventoryRepository;

  static CartController get cartController {
    if (_cartController == null) {
      _cartController = CartController();
    }
    return _cartController!;
  }
  
  static OrdersController get ordersController {
    if (_ordersController == null) {
      _ordersController = OrdersController(HiveOrdersRepository());
      print('OrdersController created in getter');
    }
    return _ordersController!;
  }
  
  static InventoryRepository get inventoryRepository {
    if (_inventoryRepository == null) {
      _inventoryRepository = InventoryRepository();
    }
    return _inventoryRepository!;
  }


  static void initialize() {
    print('AppControllers.initialize() called');
    
    try {
      if (_cartController == null) {
        _cartController = CartController();
        print('CartController created');
      }
      
      if (_ordersController == null) {
        _ordersController = OrdersController(HiveOrdersRepository());
        print('OrdersController created');
        // Load orders data from Hive immediately
        _ordersController!.load();
        print('OrdersController.load() called during initialization');
      }
      
      if (_inventoryRepository == null) {
        _inventoryRepository = InventoryRepository();
        print('InventoryRepository created');
      }
      
      print('AppControllers.initialize() completed successfully');
    } catch (e) {
      print('Error in AppControllers.initialize(): $e');
      // Continue anyway - individual controllers will be created when accessed
    }
  }

  static void dispose() {
    _cartController?.dispose();
    _ordersController?.dispose();
    _cartController = null;
    _ordersController = null;
    _inventoryRepository = null;
    
    // Close Hive boxes to ensure data persistence
    try {
      Hive.close();
      print('Hive boxes closed successfully');
    } catch (e) {
      print('Error closing Hive boxes: $e');
    }
  }
}
