import 'package:flutter/material.dart';

class TotalPrice with ChangeNotifier {
  List<double> valores = [];

  double _total = 0.0;
  double _desconto = 0.0;
  double _percentual = 0.0;
  

  double get total => _total;
  double get desconto => _desconto;
  double get percentual => _percentual;
  
  void clearValores() {
    valores = [];
    _total = 0.0;
    notifyListeners();
  }

  void porcentualChangue(String value) {
    debugPrint(((_total * double.parse(value)) / 100).toString());

    _percentual = double.parse(value);

    

    _desconto = ((_total * double.parse(value)) / 100);
    notifyListeners();
  }

  void addTotal(double valor) {
    valores.add(valor);

    _total = valores.reduce((value, element) => value + element);

    notifyListeners();
  }
}
