import 'package:flutter/foundation.dart';
import '../../../data/models/menu_item.dart';
import '../../../data/repositories/menu_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MenuItemsController extends ChangeNotifier {
  final MenuRepository repository;
  MenuItemsController(this.repository);

  List<MenuItemModel> _items = const [];
  String _search = '';
  String _category = 'All';
  bool _loading = false;

  List<MenuItemModel> get items => _items;
  bool get loading => _loading;
  String get category => _category;
  String get search => _search;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _items = await repository.getMenuItems(search: _search, category: _category);
    _loading = false;
    notifyListeners();
  }

  void setSearch(String value) {
    _search = value;
    load();
  }

  void setCategory(String value) {
    _category = value;
    load();
  }
}

final menuItemsControllerProvider = ChangeNotifierProvider<MenuItemsController>((ref) {
  return MenuItemsController(CsvMenuRepository())..load();
});


