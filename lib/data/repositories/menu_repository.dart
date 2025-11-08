import '../models/menu_item.dart';

abstract class MenuRepository {
  Future<List<MenuItemModel>> getMenuItems({String? search, String? category});
}

class InMemoryMenuRepository implements MenuRepository {
  final List<MenuItemModel> _items = const [
    MenuItemModel(id: 'mi_1', name: 'Only Burger', category: 'BURGERS', description: 'Juicy and flavorful burger', price: 315, currency: 'TRY', tags: ['burger', 'popular']),
    MenuItemModel(id: 'mi_2', name: '5\'li Wings', category: 'WINGS', description: 'Crispy and delicious chicken wings', price: 290, currency: 'TRY', tags: ['wings', 'spicy']),
    MenuItemModel(id: 'mi_3', name: 'Grill Chicken Bowl', category: 'BOWLS & COLESLAW', description: 'Fresh and nutritious bowl', price: 295, currency: 'TRY', tags: ['bowl', 'healthy']),
  ];

  @override
  Future<List<MenuItemModel>> getMenuItems({String? search, String? category}) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    Iterable<MenuItemModel> src = _items;
    if (category != null && category.isNotEmpty && category.toLowerCase() != 'all') {
      src = src.where((e) => e.category.toLowerCase() == category.toLowerCase());
    }
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      src = src.where((e) => e.name.toLowerCase().contains(q) || e.description.toLowerCase().contains(q));
    }
    return src.toList(growable: false);
  }
}

class CsvMenuRepository implements MenuRepository {
  static List<MenuItemModel> _items = [];
  static bool _isLoaded = false;

  @override
  Future<List<MenuItemModel>> getMenuItems({String? search, String? category}) async {
    if (!_isLoaded) {
      await _loadMenuItems();
    }
    
    String _normalize(String s) => s
        .toLowerCase()
        .replaceAll('’', "'")
        .replaceAll('`', "'")
        .trim();

    Iterable<MenuItemModel> src = _items;
    if (category != null && category.isNotEmpty && _normalize(category) != 'all') {
      final cat = _normalize(category);
      src = src.where((e) => _normalize(e.category) == cat);
    }
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      src = src.where((e) => e.name.toLowerCase().contains(q) || e.description.toLowerCase().contains(q));
    }
    return src.toList(growable: false);
  }

  Future<void> _loadMenuItems() async {
    // P151 Restaurant Menu with TRY pricing
    _items = [
      // BURGERS (4 items)
      MenuItemModel.fromCsv(
        id: 'burger_1',
        category: 'BURGERS',
        dish: 'Only Burger',
        basePrice: '315 TRY',
        availableAddOns: 'Extra Cheese +25 TRY, Bacon +35 TRY, Spicy Sauce +15 TRY',
        currency: 'TRY',
      ),
      MenuItemModel.fromCsv(
        id: 'burger_2',
        category: 'BURGERS',
        dish: 'Trüf Burger',
        basePrice: '315 TRY',
        availableAddOns: 'Extra Cheese +25 TRY, Bacon +35 TRY, Spicy Sauce +15 TRY',
        currency: 'TRY',
      ),
      MenuItemModel.fromCsv(
        id: 'burger_3',
        category: 'BURGERS',
        dish: 'Sympaty Burger',
        basePrice: '315 TRY',
        availableAddOns: 'Extra Cheese +25 TRY, Bacon +35 TRY, Spicy Sauce +15 TRY',
        currency: 'TRY',
      ),
      MenuItemModel.fromCsv(
        id: 'burger_4',
        category: 'BURGERS',
        dish: 'Hot Burger',
        basePrice: '315 TRY',
        availableAddOns: 'Extra Cheese +25 TRY, Bacon +35 TRY, Spicy Sauce +15 TRY',
        currency: 'TRY',
      ),
      
      // BRIOCHE (3 items)
      MenuItemModel.fromCsv(
        id: 'brioche_1',
        category: 'BRIOCHE',
        dish: 'Only Brioche',
        basePrice: '315 TRY',
        availableAddOns: 'Extra Cheese +20 TRY, Truffle Sauce +30 TRY, Avocado +25 TRY',
        currency: 'TRY',
      ),
      MenuItemModel.fromCsv(
        id: 'brioche_2',
        category: 'BRIOCHE',
        dish: 'Trüf Brioche',
        basePrice: '315 TRY',
        availableAddOns: 'Extra Cheese +20 TRY, Truffle Sauce +30 TRY, Avocado +25 TRY',
        currency: 'TRY',
      ),
      MenuItemModel.fromCsv(
        id: 'brioche_3',
        category: 'BRIOCHE',
        dish: 'Ceasar Brioche',
        basePrice: '315 TRY',
        availableAddOns: 'Extra Cheese +20 TRY, Truffle Sauce +30 TRY, Avocado +25 TRY',
        currency: 'TRY',
      ),
      
      // WINGS (3 items)
      MenuItemModel.fromCsv(
        id: 'wings_1',
        category: 'WINGS',
        dish: '5\'li Wings',
        basePrice: '290 TRY',
        availableAddOns: 'Extra Dip +15 TRY, Spicy Upgrade +10 TRY, Cheese Sauce +20 TRY',
        currency: 'TRY',
      ),
      MenuItemModel.fromCsv(
        id: 'wings_2',
        category: 'WINGS',
        dish: '7\'li Wings',
        basePrice: '360 TRY',
        availableAddOns: 'Extra Dip +15 TRY, Spicy Upgrade +10 TRY, Cheese Sauce +20 TRY',
        currency: 'TRY',
      ),
      MenuItemModel.fromCsv(
        id: 'wings_3',
        category: 'WINGS',
        dish: '9\'li Wings',
        basePrice: '460 TRY',
        availableAddOns: 'Extra Dip +15 TRY, Spicy Upgrade +10 TRY, Cheese Sauce +20 TRY',
        currency: 'TRY',
      ),
      
      // ORTAYA KARIŞIK (6 items)
      MenuItemModel.fromCsv(
        id: 'mixed_1',
        category: 'ORTAYA KARIŞIK',
        dish: 'Çıtır Tavuk',
        basePrice: '190 TRY',
        availableAddOns: 'Cheese Dip +20 TRY, Extra Portion +25 TRY, Spicy Mayo +15 TRY',
        currency: 'TRY',
      ),
      MenuItemModel.fromCsv(
        id: 'mixed_2',
        category: 'ORTAYA KARIŞIK',
        dish: 'Patates Tava',
        basePrice: '120 TRY',
        availableAddOns: 'Cheese Dip +20 TRY, Extra Portion +25 TRY, Spicy Mayo +15 TRY',
        currency: 'TRY',
      ),
      MenuItemModel.fromCsv(
        id: 'mixed_3',
        category: 'ORTAYA KARIŞIK',
        dish: 'Trüflü Parmesanlı Patates',
        basePrice: '120 TRY',
        availableAddOns: 'Cheese Dip +20 TRY, Extra Portion +25 TRY, Spicy Mayo +15 TRY',
        currency: 'TRY',
      ),
      MenuItemModel.fromCsv(
        id: 'mixed_4',
        category: 'ORTAYA KARIŞIK',
        dish: 'Tapas & Cheddarlı Patates',
        basePrice: '160 TRY',
        availableAddOns: 'Cheese Dip +20 TRY, Extra Portion +25 TRY, Spicy Mayo +15 TRY',
        currency: 'TRY',
      ),
      MenuItemModel.fromCsv(
        id: 'mixed_5',
        category: 'ORTAYA KARIŞIK',
        dish: 'Only Cheese',
        basePrice: '175 TRY',
        availableAddOns: 'Cheese Dip +20 TRY, Extra Portion +25 TRY, Spicy Mayo +15 TRY',
        currency: 'TRY',
      ),
      MenuItemModel.fromCsv(
        id: 'mixed_6',
        category: 'ORTAYA KARIŞIK',
        dish: 'Hallumi',
        basePrice: '180 TRY',
        availableAddOns: 'Cheese Dip +20 TRY, Extra Portion +25 TRY, Spicy Mayo +15 TRY',
        currency: 'TRY',
      ),
      
      // BOWLS & COLESLAW (6 items)
      MenuItemModel.fromCsv(
        id: 'bowl_1',
        category: 'BOWLS & COLESLAW',
        dish: 'Grill Chicken Bowl',
        basePrice: '295 TRY',
        availableAddOns: 'Extra Chicken +40 TRY, Avocado +25 TRY, Cheese Crumble +20 TRY',
        currency: 'TRY',
      ),
      MenuItemModel.fromCsv(
        id: 'bowl_2',
        category: 'BOWLS & COLESLAW',
        dish: 'PopChicken Bowl',
        basePrice: '295 TRY',
        availableAddOns: 'Extra Chicken +40 TRY, Avocado +25 TRY, Cheese Crumble +20 TRY',
        currency: 'TRY',
      ),
      MenuItemModel.fromCsv(
        id: 'bowl_3',
        category: 'BOWLS & COLESLAW',
        dish: 'Teriyaki Bowl',
        basePrice: '295 TRY',
        availableAddOns: 'Extra Chicken +40 TRY, Avocado +25 TRY, Cheese Crumble +20 TRY',
        currency: 'TRY',
      ),
      MenuItemModel.fromCsv(
        id: 'bowl_4',
        category: 'BOWLS & COLESLAW',
        dish: 'PopChicken Ceasar Salat',
        basePrice: '285 TRY',
        availableAddOns: 'Extra Chicken +40 TRY, Avocado +25 TRY, Cheese Crumble +20 TRY',
        currency: 'TRY',
      ),
      MenuItemModel.fromCsv(
        id: 'bowl_5',
        category: 'BOWLS & COLESLAW',
        dish: 'Chicken Ceasar Salat',
        basePrice: '285 TRY',
        availableAddOns: 'Extra Chicken +40 TRY, Avocado +25 TRY, Cheese Crumble +20 TRY',
        currency: 'TRY',
      ),
      MenuItemModel.fromCsv(
        id: 'bowl_6',
        category: 'BOWLS & COLESLAW',
        dish: 'Only Cheese Salat',
        basePrice: '295 TRY',
        availableAddOns: 'Extra Chicken +40 TRY, Avocado +25 TRY, Cheese Crumble +20 TRY',
        currency: 'TRY',
      ),
      
      // WRAP (3 items)
      MenuItemModel.fromCsv(
        id: 'wrap_1',
        category: 'WRAP',
        dish: 'Only Wrap',
        basePrice: '295 TRY',
        availableAddOns: 'Extra Cheese +20 TRY, Grilled Veggies +25 TRY, Spicy Sauce +15 TRY',
        currency: 'TRY',
      ),
      MenuItemModel.fromCsv(
        id: 'wrap_2',
        category: 'WRAP',
        dish: 'Trüf Wrap',
        basePrice: '295 TRY',
        availableAddOns: 'Extra Cheese +20 TRY, Grilled Veggies +25 TRY, Spicy Sauce +15 TRY',
        currency: 'TRY',
      ),
      MenuItemModel.fromCsv(
        id: 'wrap_3',
        category: 'WRAP',
        dish: 'Ceasar Wrap',
        basePrice: '295 TRY',
        availableAddOns: 'Extra Cheese +20 TRY, Grilled Veggies +25 TRY, Spicy Sauce +15 TRY',
        currency: 'TRY',
      ),
      
      // TENDERS (3 items)
      MenuItemModel.fromCsv(
        id: 'tenders_1',
        category: 'TENDERS',
        dish: '3\'lü Tenders',
        basePrice: '290 TRY',
        availableAddOns: 'Extra Dip +15 TRY, Cheese Melt +20 TRY, Spicy Upgrade +10 TRY',
        currency: 'TRY',
      ),
      MenuItemModel.fromCsv(
        id: 'tenders_2',
        category: 'TENDERS',
        dish: '5\'li Tenders',
        basePrice: '360 TRY',
        availableAddOns: 'Extra Dip +15 TRY, Cheese Melt +20 TRY, Spicy Upgrade +10 TRY',
        currency: 'TRY',
      ),
      MenuItemModel.fromCsv(
        id: 'tenders_3',
        category: 'TENDERS',
        dish: '7\'li Tenders',
        basePrice: '435 TRY',
        availableAddOns: 'Extra Dip +15 TRY, Cheese Melt +20 TRY, Spicy Upgrade +10 TRY',
        currency: 'TRY',
      ),
      
      // COMBO'S (3 items)
      MenuItemModel.fromCsv(
        id: 'combo_1',
        category: 'COMBO\'S',
        dish: 'Only Summer Combo',
        basePrice: '650 TRY',
        availableAddOns: 'Add Fries +40 TRY, Add Drink +35 TRY, Extra Sauce +15 TRY',
        currency: 'TRY',
      ),
      MenuItemModel.fromCsv(
        id: 'combo_2',
        category: 'COMBO\'S',
        dish: 'Hot Combo',
        basePrice: '750 TRY',
        availableAddOns: 'Add Fries +40 TRY, Add Drink +35 TRY, Extra Sauce +15 TRY',
        currency: 'TRY',
      ),
      MenuItemModel.fromCsv(
        id: 'combo_3',
        category: 'COMBO\'S',
        dish: 'Sympaty Combo',
        basePrice: '750 TRY',
        availableAddOns: 'Add Fries +40 TRY, Add Drink +35 TRY, Extra Sauce +15 TRY',
        currency: 'TRY',
      ),
    ];
    
    _isLoaded = true;
  }
}



