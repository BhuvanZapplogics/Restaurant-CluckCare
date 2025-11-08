import '../models/inventory_item_new.dart';
import '../../core/app_flow/onboarding_service.dart';

class InventoryDataService {
  static Future<List<InventoryItemNew>> loadInventoryItems() async {
    // Check if inventory setup has been completed
    final hasSetup = await OnboardingService.hasCompletedInventorySetup();
    
    if (!hasSetup) {
      print('Inventory setup not completed - returning empty list');
      return [];
    }
    
    // Load inventory data
    print('Loading inventory data...');
    return _getFallbackData();
    
    // TODO: Uncomment below when CSV loading is fixed
    /*
    try {
      // Try to load CSV data
      final csvData = await rootBundle.loadString('assets/images/inventory/All ingredients/All ingredients/Inventory_list_Restaurant APP.csv');
      final lines = csvData.split('\n');
      
      print('CSV loaded successfully. Lines count: ${lines.length}');
      
      List<InventoryItemNew> items = [];
      
      // Skip header row (index 0)
      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        
        final parts = line.split(',');
        if (parts.length >= 3) {
          final category = parts[0].trim();
          final name = parts[1].trim();
          final unit = parts[2].trim();
          
          print('Processing item: $name in category: $category');
          
          final item = InventoryItemNew.fromCsvData(
            name: name,
            category: category,
            unit: unit,
          );
          
          items.add(item);
        }
      }
      
      print('Total items loaded: ${items.length}');
      return items;
    } catch (e) {
      print('Error loading CSV, using fallback data: $e');
      // Fallback to hardcoded data if CSV fails
      return _getFallbackData();
    }
    */
  }

  static List<InventoryItemNew> _getFallbackData() {
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
  
  static List<InventoryItemNew> getItemsByCategory(List<InventoryItemNew> items, String category) {
    if (category == 'All') return items;
    return items.where((item) => item.category == category).toList();
  }
  
  static List<String> getCategories(List<InventoryItemNew> items) {
    final categories = items.map((item) => item.category).toSet().toList();
    categories.sort();
    return ['All', ...categories];
  }
  
  static int getTotalItems(List<InventoryItemNew> items) {
    return items.length;
  }
  
  static int getLowStockCount(List<InventoryItemNew> items) {
    return items.where((item) => item.stockStatus == 'low').length;
  }
  
  static int getOutOfStockCount(List<InventoryItemNew> items) {
    return items.where((item) => item.stockStatus == 'out').length;
  }
}
