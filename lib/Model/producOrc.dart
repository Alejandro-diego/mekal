


import 'package:flutter/foundation.dart';

import 'data.dart';

class ProducProvider with ChangeNotifier {
  final List<Data> _items = [];

  void addItem(Data itemData) {
    _items.add(itemData);
    notifyListeners();
  }

  void clearList() {
    _items.clear();
     notifyListeners();
  }

  void removeItem(Data itemData) {
    _items.remove(itemData);
    notifyListeners();
  }

  List<Data> get producItem {
    return _items;
  }
}
