class MenuItemModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final double price;
  final String currency;
  final bool isActive;
  final List<String> tags;
  final List<String> addOns;
  final String? imageUrl;

  const MenuItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.currency,
    this.isActive = true,
    this.tags = const [],
    this.addOns = const [],
    this.imageUrl,
  });

  factory MenuItemModel.fromCsv({
    required String id,
    required String category,
    required String dish,
    required String basePrice,
    required String availableAddOns,
    required String currency,
  }) {
    // Parse price from string like "315 TRY", "100 TRY", "23 - 57 TRY", or "?315"
    // For range prices, use the lower value
    // Handles Turkish Lira symbol (₺) which may appear as "?" due to encoding
    final priceMatch = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(basePrice);
    final price = priceMatch != null ? double.parse(priceMatch.group(1)!) : 0.0;
    
    // Parse add-ons from string
    final addOns = availableAddOns.split(',').map((e) => e.trim()).toList();
    
    // Generate description based on category and dish
    final description = _generateDescription(category, dish);
    
    // Generate tags based on category
    final tags = _generateTags(category);
    
    // Generate image URL (placeholder for now)
    final imageUrl = _generateImageUrl(category, dish);

    return MenuItemModel(
      id: id,
      name: dish,
      category: category,
      description: description,
      price: price,
      currency: currency,
      tags: tags,
      addOns: addOns,
      imageUrl: imageUrl,
    );
  }

  static String _generateDescription(String category, String dish) {
    // Dish-specific descriptions take priority
    final Map<String, String> dishDescriptions = {
      // BURGERS
      'Only Burger': 'Classic smashed beef, cheddar, house sauce on a toasted bun.',
      'Trüf Burger': 'Truffle-infused sauce, double cheddar, caramelized onions.',
      'Sympaty Burger': 'Signature spicy mayo, pickles, melted cheese and crisp lettuce.',
      'Hot Burger': 'Fiery pepper relish, jalapeños and creamy cheese to balance the heat.',

      // BRIOCHE
      'Only Brioche': 'Buttery brioche sandwich with tender chicken and fresh greens.',
      'Trüf Brioche': 'Silky truffle mayo in a soft brioche bun with crisp lettuce.',
      'Ceasar Brioche': 'Caesar-dressed greens and parmesan in a pillowy brioche.',

      // WINGS
      "5'li Wings": 'Five crispy wings tossed in our house spice blend.',
      "7'li Wings": 'Seven golden wings, perfect for sharing or snacking.',
      "9'li Wings": 'Nine-piece feast with crunchy skin and juicy meat.',

      // BOWLS & COLESLAW
      'Grill Chicken Bowl': 'Char-grilled chicken over seasoned rice with fresh veggies.',
      'PopChicken Bowl': 'Crispy chicken bites, pickles and slaw on fragrant rice.',
      'Teriyaki Bowl': 'Sweet-savory teriyaki glazed chicken with sesame and greens.',
      'PopChicken Ceasar Salat': 'Crispy chicken on Caesar-dressed greens with parmesan.',
      'Chicken Ceasar Salat': 'Grilled chicken, romaine, parmesan and Caesar dressing.',
      'Only Cheese Salat': 'Creamy cheese, crunchy greens and a tangy house dressing.',

      // WRAP
      'Only Wrap': 'Grilled chicken wrap with garlic-yogurt and crisp lettuce.',
      'Trüf Wrap': 'Truffle mayo wrap with tender chicken and parmesan.',
      'Ceasar Wrap': 'Caesar chicken wrap with crunchy romaine and parmesan.',

      // TENDERS
      "3'lü Tenders": 'Three hand-breaded tenders with a side of dipping sauce.',
      "5'li Tenders": 'Five crispy tenders, juicy inside and perfectly seasoned.',
      "7'li Tenders": 'Seven-piece crunchy tenders for serious cravings.',

      // COMBOS
      'Only Summer Combo': 'Burger + fries + drink — a refreshing summer set.',
      'Hot Combo': 'Spicy burger with fries and drink to turn up the heat.',
      'Sympaty Combo': 'House-favorite burger combo with fries and a cold drink.',
    };

    if (dishDescriptions.containsKey(dish)) {
      return dishDescriptions[dish]!;
    }

    // Category fallback
    final categoryFallback = {
      'BURGERS': 'Juicy and flavorful burger',
      'BRIOCHE': 'Premium brioche bun sandwich',
      'WINGS': 'Crispy and delicious chicken wings',
      'ORTAYA KARIŞIK': 'Perfect sharing platter',
      'BOWLS & COLESLAW': 'Fresh and nutritious bowl',
      'WRAP': 'Fresh and satisfying wrap',
      'TENDERS': 'Crispy chicken tenders',
      'COMBO\'S': 'Complete meal combo',
    };
    return categoryFallback[category] ?? 'Delicious dish';
  }

  static List<String> _generateTags(String category) {
    final tagMap = {
      'BURGERS': ['burger', 'popular'],
      'BRIOCHE': ['brioche', 'premium'],
      'WINGS': ['wings', 'spicy'],
      'ORTAYA KARIŞIK': ['shared', 'appetizer'],
      'BOWLS & COLESLAW': ['bowl', 'healthy'],
      'WRAP': ['wrap', 'fresh'],
      'TENDERS': ['tenders', 'crispy'],
      'COMBO\'S': ['combo', 'value'],
    };
    return tagMap[category] ?? ['delicious'];
  }

  static String _generateImageUrl(String category, String dish) {
    // Map dish names to reduced-size P151 images
    // Use category + dish combination to handle duplicates
    final key = '$category|$dish';
    
    final dishImages = {
      // BURGERS
      'BURGERS|Only Burger': 'assets/images/P151/P151_Menu_Images_Size Reduced/OnlyBurger.jpg',
      'BURGERS|Trüf Burger': 'assets/images/P151/P151_Menu_Images_Size Reduced/TrfBurger.jpg',
      'BURGERS|Sympaty Burger': 'assets/images/P151/P151_Menu_Images_Size Reduced/SympatyBurger.jpg',
      'BURGERS|Hot Burger': 'assets/images/P151/P151_Menu_Images_Size Reduced/HotBurger.jpg',
      
      // BRIOCHE
      'BRIOCHE|Only Brioche': 'assets/images/P151/P151_Menu_Images_Size Reduced/OnlyBrioche.jpg',
      'BRIOCHE|Trüf Brioche': 'assets/images/P151/P151_Menu_Images_Size Reduced/TrfBrioche.jpg',
      'BRIOCHE|Ceasar Brioche': 'assets/images/P151/P151_Menu_Images_Size Reduced/CeasarBrioche.jpg',
      
      // WINGS
      'WINGS|5\'li Wings': 'assets/images/P151/P151_Menu_Images_Size Reduced/5liWings.jpg',
      'WINGS|7\'li Wings': 'assets/images/P151/P151_Menu_Images_Size Reduced/7liWings.jpg',
      'WINGS|9\'li Wings': 'assets/images/P151/P151_Menu_Images_Size Reduced/9liWings.jpg',
      
      // ORTAYA KARIŞIK
      'ORTAYA KARIŞIK|Çıtır Tavuk': 'assets/images/P151/P151_Menu_Images_Size Reduced/trTavuk.jpg',
      'ORTAYA KARIŞIK|Patates Tava': 'assets/images/P151/P151_Menu_Images_Size Reduced/PatatesTava.jpg',
      'ORTAYA KARIŞIK|Trüflü Parmesanlı Patates': 'assets/images/P151/P151_Menu_Images_Size Reduced/TrflParmesanlPatates.jpg',
      'ORTAYA KARIŞIK|Tapas & Cheddarlı Patates': 'assets/images/P151/P151_Menu_Images_Size Reduced/TapasCheddarlPatates.jpg',
      'ORTAYA KARIŞIK|Only Cheese': 'assets/images/P151/P151_Menu_Images_Size Reduced/OnlyCheese.jpg',
      'ORTAYA KARIŞIK|Hallumi': 'assets/images/P151/P151_Menu_Images_Size Reduced/Hallumi.jpg',
      
      // BOWLS & COLESLAW
      'BOWLS & COLESLAW|Grill Chicken Bowl': 'assets/images/P151/P151_Menu_Images_Size Reduced/GrillChickenBowl.jpg',
      'BOWLS & COLESLAW|PopChicken Bowl': 'assets/images/P151/P151_Menu_Images_Size Reduced/PopChickenBowl.jpg',
      'BOWLS & COLESLAW|Teriyaki Bowl': 'assets/images/P151/P151_Menu_Images_Size Reduced/TeriyakiBowl.jpg',
      'BOWLS & COLESLAW|PopChicken Ceasar Salat': 'assets/images/P151/P151_Menu_Images_Size Reduced/PopChickenCeasarSalat.jpg',
      'BOWLS & COLESLAW|Chicken Ceasar Salat': 'assets/images/P151/P151_Menu_Images_Size Reduced/ChickenCeasarSalat.jpg',
      'BOWLS & COLESLAW|Only Cheese Salat': 'assets/images/P151/P151_Menu_Images_Size Reduced/OnlyCheeseSalat.jpg',
      
      // WRAP
      'WRAP|Only Wrap': 'assets/images/P151/P151_Menu_Images_Size Reduced/OnlyWrap.jpg',
      'WRAP|Trüf Wrap': 'assets/images/P151/P151_Menu_Images_Size Reduced/TrfWrap.jpg',
      'WRAP|Ceasar Wrap': 'assets/images/P151/P151_Menu_Images_Size Reduced/CeasarWrap.jpg',
      
      // TENDERS
      'TENDERS|3\'lü Tenders': 'assets/images/P151/P151_Menu_Images_Size Reduced/3lTenders.jpg',
      'TENDERS|5\'li Tenders': 'assets/images/P151/P151_Menu_Images_Size Reduced/5lTenders.jpg',
      'TENDERS|7\'li Tenders': 'assets/images/P151/P151_Menu_Images_Size Reduced/7lTenders.jpg',
      
      // COMBO'S
      'COMBO\'S|Only Summer Combo': 'assets/images/P151/P151_Menu_Images_Size Reduced/OnlySummerComb.jpeg',
      'COMBO\'S|Hot Combo': 'assets/images/P151/P151_Menu_Images_Size Reduced/HotCombo.jpg',
      'COMBO\'S|Sympaty Combo': 'assets/images/P151/P151_Menu_Images_Size Reduced/SympatyCombo.jpg',
    };
    
    // Return specific image for the dish, or fallback to a default
    return dishImages[key] ?? 'assets/images/P151/P151_Menu_Images_Size Reduced/OnlyBurger.jpg';
  }
}
