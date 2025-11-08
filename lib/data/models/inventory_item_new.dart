class InventoryItemNew {
  final String name;
  final String category;
  final String unit;
  final String imagePath;
  final double currentStock;
  final double parLevel;
  final double reorderPoint;
  final String stockStatus; // 'high', 'medium', 'low', 'out'

  InventoryItemNew({
    required this.name,
    required this.category,
    required this.unit,
    required this.imagePath,
    required this.currentStock,
    required this.parLevel,
    required this.reorderPoint,
    required this.stockStatus,
  });

  // Factory method to create from CSV data
  factory InventoryItemNew.fromCsvData({
    required String name,
    required String category,
    required String unit,
    double? initialStock,
  }) {
    // Set par level and reorder point
    final parLevel = _getDefaultParLevel(category);
    final reorderPoint = parLevel * 0.2; // 20% of par level
    
    // Use provided initial stock or default to 0
    final currentStock = initialStock ?? 0.0;
    final stockStatus = _getStockStatus(currentStock, reorderPoint, parLevel);
    
    return InventoryItemNew(
      name: name,
      category: category,
      unit: unit,
      imagePath: _getImagePath(category, name),
      currentStock: currentStock,
      parLevel: parLevel,
      reorderPoint: reorderPoint,
      stockStatus: stockStatus,
    );
  }

  static String _getImagePath(String category, String name) {
    // For now, use menu images as fallback since inventory images might have path issues
    return _getFallbackImagePath(name);
  }

  static String _getFallbackImagePath(String name) {
    // Use reduced-size inventory images
    switch (name.toLowerCase()) {
      // Meats - Chicken
      case 'chicken wings':
        return 'assets/images/inventory/P151_Inventory_Images_Reduced Size/Meats/ChickenWings.jpg';
      case 'chicken breast':
        return 'assets/images/inventory/P151_Inventory_Images_Reduced Size/Meats/BonelessChickenBreast.jpg';
      case 'chicken drumsticks / leg quarters':
        return 'assets/images/inventory/P151_Inventory_Images_Reduced Size/Meats/ChickenDrumsticksLegQuarters.jpg';
      case 'boneless chicken thigh':
        return 'assets/images/inventory/P151_Inventory_Images_Reduced Size/Meats/BonelessChickenThigh.jpg';
      case 'whole chicken':
        return 'assets/images/inventory/P151_Inventory_Images_Reduced Size/Meats/WholeChicken.jpg';
      case 'chicken liver & giblets':
        return 'assets/images/inventory/P151_Inventory_Images_Reduced Size/Meats/ChickenLiverGiblets.jpg';
      case 'minced chicken':
        return 'assets/images/inventory/P151_Inventory_Images_Reduced Size/Meats/MincedChicken.jpg';
      
      // Other Meats
      case 'beef brisket':
        return 'assets/images/inventory/P151_Inventory_Images_Reduced Size/Other meats/BeefBrisket.jpg';
      case 'roast beef (rosto)':
        return 'assets/images/inventory/P151_Inventory_Images_Reduced Size/Other meats/RoastBeefRosto.jpg';
      case 'ground beef / lamb':
        return 'assets/images/inventory/P151_Inventory_Images_Reduced Size/Other meats/GroundBeefLamb.jpg';
      case 'lamb ribs':
        return 'assets/images/inventory/P151_Inventory_Images_Reduced Size/Other meats/LambRibs.jpg';
      
      // Vegetables & Starches
      case 'rice (basmati / long grain)':
        return 'assets/images/inventory/P151_Inventory_Images_Reduced Size/Vegetables & Starches/RiceBasmatiLongGrain.jpg';
      case 'potatoes':
        return 'assets/images/inventory/P151_Inventory_Images_Reduced Size/Vegetables & Starches/Potatoes.jpg';
      case 'sweet potatoes':
        return 'assets/images/inventory/P151_Inventory_Images_Reduced Size/Vegetables & Starches/SweetPotatoes.jpg';
      case 'onions':
        return 'assets/images/inventory/P151_Inventory_Images_Reduced Size/Vegetables & Starches/Onions.jpg';
      case 'garlic & ginger':
        return 'assets/images/inventory/P151_Inventory_Images_Reduced Size/Vegetables & Starches/GarlicGinger.jpg';
      case 'carrots & celery':
        return 'assets/images/inventory/P151_Inventory_Images_Reduced Size/Vegetables & Starches/CarrotsCelery.jpg';
      case 'tomatoes':
        return 'assets/images/inventory/P151_Inventory_Images_Reduced Size/Vegetables & Starches/Tomatoes.jpg';
      case 'bell peppers & chilies':
        return 'assets/images/inventory/P151_Inventory_Images_Reduced Size/Vegetables & Starches/BellPeppersChilies.jpg';
      
      // Dairy & Extras
      case 'cheese (cheddar / mozzarella / cream cheese)':
        return 'assets/images/inventory/P151_Inventory_Images_Reduced Size/Dairy & Extras/CheeseCheddarMozzarellaCreamCheese.jpg';
      case 'cream / whipped cream':
        return 'assets/images/inventory/P151_Inventory_Images_Reduced Size/Dairy & Extras/CreamWhippedCream.jpg';
      case 'butter':
        return 'assets/images/inventory/P151_Inventory_Images_Reduced Size/Dairy & Extras/Butter.jpg';
      case 'milk':
        return 'assets/images/inventory/P151_Inventory_Images_Reduced Size/Dairy & Extras/Milk.jpg';
      case 'eggs':
        return 'assets/images/inventory/P151_Inventory_Images_Reduced Size/Dairy & Extras/Eggs.jpg';
      
      // Bakery & Grains
      case 'burger buns / sandwich rolls':
        return 'assets/images/inventory/P151_Inventory_Images_Reduced Size/Bakery & Grains/BurgerBunsSandwichRolls.jpg';
      case 'flatbread / pita':
        return 'assets/images/inventory/P151_Inventory_Images_Reduced Size/Bakery & Grains/FlatbreadPita.jpg';
      case 'garlic bread':
        return 'assets/images/inventory/P151_Inventory_Images_Reduced Size/Bakery & Grains/GarlicBread.jpg';
      case 'pie crusts':
        return 'assets/images/inventory/P151_Inventory_Images_Reduced Size/Bakery & Grains/PieCrusts.jpg';
      
      // Dessert Ingredients
      case 'apples (pie)':
        return 'assets/images/inventory/P151_Inventory_Images_Reduced Size/Desserts Ingredient/ApplesPieIngredients.jpg';
      case 'cream cheese (cheesecake)':
        return 'assets/images/inventory/P151_Inventory_Images_Reduced Size/Desserts Ingredient/CreamCheeseCheesecakeIngredients.jpg';
      case 'fresh fruits (fruit salad)':
        return 'assets/images/inventory/P151_Inventory_Images_Reduced Size/Desserts Ingredient/FreshFruitsFruitSaladIngredients.jpg';
      case 'ice cream (for desserts)':
        return 'assets/images/inventory/P151_Inventory_Images_Reduced Size/Desserts Ingredient/IceCreamfordessertsingredients.jpg';
      
      // Sauces
      case 'bbq sauce':
        return 'assets/images/inventory/P151_Inventory_Images_Reduced Size/Sauces/BBQSauce.jpg';
      case 'mushroom sauce base':
        return 'assets/images/inventory/P151_Inventory_Images_Reduced Size/Sauces/MushroomSauceBase.jpg';
      case 'pepper sauce base':
        return 'assets/images/inventory/P151_Inventory_Images_Reduced Size/Sauces/PepperSauceBase.jpg';
      case 'garlic mayo':
        return 'assets/images/inventory/P151_Inventory_Images_Reduced Size/Sauces/GarlicMayo.jpg';
      case 'hot sauce / chili oil':
        return 'assets/images/inventory/P151_Inventory_Images_Reduced Size/Sauces/HotSauceChiliOil.jpg';
      case 'olive oil / cooking oil':
        return 'assets/images/inventory/P151_Inventory_Images_Reduced Size/Sauces/OliveOilCookingOil.jpg';
      case 'vinegar (white / balsamic / apple cider)':
        return 'assets/images/inventory/P151_Inventory_Images_Reduced Size/Sauces/VinegarWhiteBalsamicAppleCider.jpg';
      
      default:
        return 'assets/images/P151/P151_Menu_Images_Size Reduced/OnlyBurger.jpg';
    }
  }


  static double _getDefaultParLevel(String category) {
    switch (category) {
      case 'Meats':
        return 50.0;
      case 'Other Meats':
        return 30.0;
      case 'Vegetables & Starches':
        return 80.0;
      case 'Dairy & Extras':
        return 25.0;
      case 'Bakery & Grains':
        return 100.0;
      case 'Dessert Ingredients':
        return 15.0;
      case 'Sauces':
        return 20.0;
      default:
        return 30.0;
    }
  }


  static String _getStockStatus(double currentStock, double reorderPoint, double parLevel) {
    if (currentStock <= 0) return 'out';
    if (currentStock <= reorderPoint) return 'low';
    if (currentStock >= parLevel * 0.8) return 'high';
    return 'medium';
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'unit': unit,
      'currentStock': currentStock,
      'parLevel': parLevel,
      'reorderPoint': reorderPoint,
      'imagePath': imagePath,
      'stockStatus': stockStatus,
    };
  }

  // Create from JSON
  factory InventoryItemNew.fromJson(Map<String, dynamic> json) {
    return InventoryItemNew(
      name: json['name'] as String,
      category: json['category'] as String,
      unit: json['unit'] as String,
      currentStock: (json['currentStock'] as num).toDouble(),
      parLevel: (json['parLevel'] as num).toDouble(),
      reorderPoint: (json['reorderPoint'] as num).toDouble(),
      imagePath: json['imagePath'] as String,
      stockStatus: json['stockStatus'] as String,
    );
  }

  // Copy with method for updates
  InventoryItemNew copyWith({
    String? name,
    String? category,
    String? unit,
    double? currentStock,
    double? parLevel,
    double? reorderPoint,
    String? imagePath,
    String? stockStatus,
  }) {
    return InventoryItemNew(
      name: name ?? this.name,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      currentStock: currentStock ?? this.currentStock,
      parLevel: parLevel ?? this.parLevel,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      imagePath: imagePath ?? this.imagePath,
      stockStatus: stockStatus ?? this.stockStatus,
    );
  }
}
