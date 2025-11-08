import 'package:hive_flutter/hive_flutter.dart';
import '../models/inventory_item_new.dart';
import '../../core/app_flow/onboarding_service.dart';

class InventoryRepository {
  static const String _boxName = 'inventory';
  Box<dynamic>? _box;

  // Initialize Hive box
  Future<void> init() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox(_boxName);
    }
  }

  // Get all inventory items
  Future<List<InventoryItemNew>> getAllItems() async {
    await init();
    final List<dynamic> itemsList = _box?.get('inventory_items', defaultValue: []) ?? [];
    
    if (itemsList.isEmpty) {
      // If no items exist, only load fallback data after initial setup
      final hasSetup = await OnboardingService.hasCompletedInventorySetup();
      if (!hasSetup) {
        return [];
      }
      return _getFallbackData();
    }
    
    final loaded = itemsList
        .map((item) => InventoryItemNew.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();

    // Migration: ensure image paths point to reduced-size assets
    final List<InventoryItemNew> migrated = loaded.map((it) {
      final p = it.imagePath;
      final needsUpdate = p.contains('assets/images/inventory/All ingredients') ||
          p.contains('assets/images/P151/P151_Menu_Images');
      if (!needsUpdate) return it;
      final tmp = InventoryItemNew.fromCsvData(
        name: it.name,
        category: it.category,
        unit: it.unit,
        initialStock: it.currentStock,
      );
      return it.copyWith(imagePath: tmp.imagePath);
    }).toList();

    // Persist migration if any changes
    final changed = List.generate(loaded.length, (i) => loaded[i].imagePath != migrated[i].imagePath)
        .any((e) => e);
    if (changed) {
      await saveAllItems(migrated);
    }
    return migrated;
  }

  // Save all inventory items
  Future<void> saveAllItems(List<InventoryItemNew> items) async {
    await init();
    final itemsJson = items.map((item) => item.toJson()).toList();
    await _box?.put('inventory_items', itemsJson);
  }

  // Update a specific item
  Future<void> updateItem(InventoryItemNew updatedItem) async {
    final allItems = await getAllItems();
    final index = allItems.indexWhere((item) => item.name == updatedItem.name && item.category == updatedItem.category);
    if (index != -1) {
      allItems[index] = updatedItem;
      await saveAllItems(allItems);
    }
  }

  // Add a new item
  Future<void> addItem(InventoryItemNew newItem) async {
    final allItems = await getAllItems();
    allItems.add(newItem);
    await saveAllItems(allItems);
  }

  // Delete an item
  Future<void> deleteItem(String itemName, String category) async {
    final allItems = await getAllItems();
    allItems.removeWhere((item) => item.name == itemName && item.category == category);
    await saveAllItems(allItems);
  }

  // Clear all items
  Future<void> clearAll() async {
    await init();
    await _box?.clear();
  }

  // Get fallback data (same as the service)
  List<InventoryItemNew> _getFallbackData() {
    return [
      // Meats
      InventoryItemNew.fromCsvData(name: 'Chicken Wings', category: 'Meats', unit: 'kg'),
      InventoryItemNew.fromCsvData(name: 'Chicken Breast', category: 'Meats', unit: 'kg'),
      InventoryItemNew.fromCsvData(name: 'Chicken Drumsticks / Leg Quarters', category: 'Meats', unit: 'kg'),
      InventoryItemNew.fromCsvData(name: 'Boneless Chicken Thigh', category: 'Meats', unit: 'kg'),
      InventoryItemNew.fromCsvData(name: 'Minced Chicken', category: 'Meats', unit: 'kg'),
      InventoryItemNew.fromCsvData(name: 'Whole Chicken', category: 'Meats', unit: 'kg'),
      InventoryItemNew.fromCsvData(name: 'Chicken Liver & Giblets', category: 'Meats', unit: 'kg'),
      
      // Other Meats
      InventoryItemNew.fromCsvData(name: 'Beef Brisket', category: 'Other Meats', unit: 'kg'),
      InventoryItemNew.fromCsvData(name: 'Roast Beef (Rosto)', category: 'Other Meats', unit: 'kg'),
      InventoryItemNew.fromCsvData(name: 'Ground Beef / Lamb', category: 'Other Meats', unit: 'kg'),
      InventoryItemNew.fromCsvData(name: 'Lamb Ribs', category: 'Other Meats', unit: 'kg'),
      
      // Vegetables & Starches
      InventoryItemNew.fromCsvData(name: 'Rice (Basmati / Long Grain)', category: 'Vegetables & Starches', unit: 'kg'),
      InventoryItemNew.fromCsvData(name: 'Potatoes', category: 'Vegetables & Starches', unit: 'kg'),
      InventoryItemNew.fromCsvData(name: 'Sweet Potatoes', category: 'Vegetables & Starches', unit: 'kg'),
      InventoryItemNew.fromCsvData(name: 'Onions', category: 'Vegetables & Starches', unit: 'kg'),
      InventoryItemNew.fromCsvData(name: 'Garlic & Ginger', category: 'Vegetables & Starches', unit: 'kg'),
      InventoryItemNew.fromCsvData(name: 'Carrots & Celery', category: 'Vegetables & Starches', unit: 'kg'),
      InventoryItemNew.fromCsvData(name: 'Tomatoes', category: 'Vegetables & Starches', unit: 'kg'),
      InventoryItemNew.fromCsvData(name: 'Bell Peppers & Chilies', category: 'Vegetables & Starches', unit: 'kg'),
      
      // Dairy & Extras
      InventoryItemNew.fromCsvData(name: 'Cheese (Cheddar / Mozzarella / Cream Cheese)', category: 'Dairy & Extras', unit: 'kg'),
      InventoryItemNew.fromCsvData(name: 'Cream / Whipped Cream', category: 'Dairy & Extras', unit: 'liters'),
      InventoryItemNew.fromCsvData(name: 'Butter', category: 'Dairy & Extras', unit: 'kg'),
      InventoryItemNew.fromCsvData(name: 'Milk', category: 'Dairy & Extras', unit: 'liters'),
      InventoryItemNew.fromCsvData(name: 'Eggs', category: 'Dairy & Extras', unit: 'dozen'),
      
      // Bakery & Grains
      InventoryItemNew.fromCsvData(name: 'Burger Buns / Sandwich Rolls', category: 'Bakery & Grains', unit: 'pieces'),
      InventoryItemNew.fromCsvData(name: 'Flatbread / Pita', category: 'Bakery & Grains', unit: 'pieces'),
      InventoryItemNew.fromCsvData(name: 'Garlic Bread', category: 'Bakery & Grains', unit: 'pieces'),
      InventoryItemNew.fromCsvData(name: 'Pie Crusts', category: 'Bakery & Grains', unit: 'pieces'),
      
      // Dessert Ingredients
      InventoryItemNew.fromCsvData(name: 'Apples (Pie)', category: 'Dessert Ingredients', unit: 'kg'),
      InventoryItemNew.fromCsvData(name: 'Cream Cheese (Cheesecake)', category: 'Dessert Ingredients', unit: 'kg'),
      InventoryItemNew.fromCsvData(name: 'Fresh Fruits (Fruit Salad)', category: 'Dessert Ingredients', unit: 'kg'),
      InventoryItemNew.fromCsvData(name: 'Ice Cream (for desserts)', category: 'Dessert Ingredients', unit: 'liters'),
      
      // Sauces
      InventoryItemNew.fromCsvData(name: 'BBQ Sauce', category: 'Sauces', unit: 'liters'),
      InventoryItemNew.fromCsvData(name: 'Mushroom Sauce Base', category: 'Sauces', unit: 'liters'),
      InventoryItemNew.fromCsvData(name: 'Pepper Sauce Base', category: 'Sauces', unit: 'liters'),
      InventoryItemNew.fromCsvData(name: 'Garlic Mayo', category: 'Sauces', unit: 'liters'),
      InventoryItemNew.fromCsvData(name: 'Hot Sauce / Chili Oil', category: 'Sauces', unit: 'liters'),
      InventoryItemNew.fromCsvData(name: 'Olive Oil / Cooking Oil', category: 'Sauces', unit: 'liters'),
      InventoryItemNew.fromCsvData(name: 'Vinegar (White / Balsamic / Apple Cider)', category: 'Sauces', unit: 'liters'),
    ];
  }

  // Seed storage with fallback data (used during first-time Quick Setup)
  Future<void> seedWithFallback() async {
    await init();
    final items = _getFallbackData();
    await saveAllItems(items);
  }
}