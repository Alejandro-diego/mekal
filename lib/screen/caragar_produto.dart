import 'package:brasil_fields/brasil_fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

// ignore: must_be_immutable
class CargarProduto extends StatefulWidget {
  CargarProduto(
      {Key? key,
      required this.description,
      required this.barCode,
      required this.preco,
      required this.produto,
      required this.reference,
      required this.stock})
      : super(key: key);

  int stock;
  int produto;
  String barCode;
  String description;
  double preco;
  String reference;

  @override
  State<CargarProduto> createState() => _CargarProdutoState();
}

class _CargarProdutoState extends State<CargarProduto> {
  TextEditingController produto = TextEditingController();
  TextEditingController stock = TextEditingController();
  TextEditingController precio = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  TextEditingController descripcion = TextEditingController();
  TextEditingController reference = TextEditingController();
  TextEditingController barCode = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void dispose() {
    produto.dispose();
    stock.dispose();
    precio.dispose();
    descripcion.dispose();
    reference.dispose();
    barCode.dispose();

    super.dispose();
  }

  @override
  void initState() {
    if (widget.barCode.isNotEmpty) {
      descripcion.text = widget.description;
      precio.text = widget.preco.toString();
      barCode.text = widget.barCode;
      reference.text = widget.reference;
      stock.text = widget.stock.toString();
      produto.text = widget.produto.toString();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Produto"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Spacer(),
              TextFormField(
                keyboardType: TextInputType.name,
                controller: descripcion,
                cursorColor: Colors.amberAccent,
                // style: const TextStyle(fontSize: 20),
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  labelStyle: TextStyle(color: Colors.white),
                  prefixIcon: Padding(
                    padding: EdgeInsetsDirectional.only(start: 2),
                    child: Icon(
                      Icons.article_outlined,
                      size: 35,
                      color: Colors.grey,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(width: 2, color: Colors.amberAccent),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Descrição';
                  }
                  return null;
                },
              ),
              const Spacer(),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: produto,
                cursorColor: Colors.amberAccent,
                // style: const TextStyle(fontSize: 20),
                decoration: const InputDecoration(
                  labelText: 'Produto',
                  labelStyle: TextStyle(color: Colors.white),
                  prefixIcon: Padding(
                    padding: EdgeInsetsDirectional.only(start: 2),
                    child: Icon(
                      Icons.assignment,
                      size: 35,
                      color: Colors.grey,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(width: 2, color: Colors.amberAccent),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Produto';
                  }
                  return null;
                },
              ),
              const Spacer(),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: barCode,
                cursorColor: Colors.amberAccent,
                // style: const TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  labelText: 'BarCode',
                  labelStyle: const TextStyle(color: Colors.white),
                  prefixIcon: const Padding(
                    padding: EdgeInsetsDirectional.only(start: 2),
                    child: Icon(
                      Icons.edgesensor_high_outlined,
                      size: 35,
                      color: Colors.grey,
                    ),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      scanBarcodeNormal();
                    },
                    icon: const Icon(
                      Icons.barcode_reader,
                      color: Colors.grey,
                    ),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(width: 2, color: Colors.amberAccent),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'BarCode';
                  }
                  return null;
                },
              ),
              const Spacer(),
              TextFormField(
                keyboardType: TextInputType.text,
                controller: reference,
                cursorColor: Colors.amberAccent,
                decoration: const InputDecoration(
                  labelText: 'Referencia',
                  labelStyle: TextStyle(color: Colors.white),
                  prefixIcon: Padding(
                    padding: EdgeInsetsDirectional.only(start: 2),
                    child: Icon(
                      Icons.assignment_late_outlined,
                      size: 35,
                      color: Colors.grey,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(width: 2, color: Colors.amberAccent),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Referencia';
                  }
                  return null;
                },
              ),
              const Spacer(),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: stock,
                cursorColor: Colors.amberAccent,
                // style: const TextStyle(fontSize: 20),
                decoration: const InputDecoration(
                  labelText: 'Quantidade',
                  labelStyle: TextStyle(color: Colors.white),
                  prefixIcon: Padding(
                    padding: EdgeInsetsDirectional.only(start: 2),
                    child: Icon(
                      Icons.fact_check_outlined,
                      size: 35,
                      color: Colors.grey,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(width: 2, color: Colors.amberAccent),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Quantidade';
                  }
                  return null;
                },
              ),
              const Spacer(),
              TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CentavosInputFormatter()
                ],

                controller: precio,
                cursorColor: Colors.amberAccent,
                // style: const TextStyle(fontSize: 20),
                decoration: const InputDecoration(
                  labelText: 'Preco',
                  labelStyle: TextStyle(color: Colors.white),
                  prefixIcon: Padding(
                    padding: EdgeInsetsDirectional.only(start: 2),
                    child: Icon(
                      Icons.attach_money_outlined,
                      size: 35,
                      color: Colors.grey,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(width: 2, color: Colors.amberAccent),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Preco';
                  }
                  return null;
                },
              ),
              const Spacer(),
              ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _db.collection('produtos').doc(produto.text).set({
                        'description': descripcion.text.toUpperCase(),
                        'produto': produto.text,
                        'barCode': barCode.text,
                        'reference': reference.text,
                        'stock': stock.text,
                        'preco': precio.text.replaceAll(',', '.'),
                      });
                      Navigator.of(context).pop();
                    }
                    if (int.parse(stock.text) >= 1) {
                      _db
                          .collection('producFaltante')
                          .doc(produto.text)
                          .delete();
                    }
                  },
                  child: const Text("Add")),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancelar', true, ScanMode.BARCODE);
      if (kDebugMode) {
        print(barcodeScanRes);
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (!mounted) return;

    setState(() {
      barCode.text = barcodeScanRes;
    });
  }
}
