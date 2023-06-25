import 'package:flutter/foundation.dart';

import 'data.dart';

class ProducProvider with ChangeNotifier {
  final List<Data> _items = [];

  void updateIten(int index, double price , int quantia) {
    _items[index].preco = price;
    _items[index].qantidade = quantia;
    notifyListeners();
  }

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
