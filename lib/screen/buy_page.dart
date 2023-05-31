import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:mekal/Model/total.dart';

import 'package:mekal/utils.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'detalles.dart';
import 'list_produc.dart';

// ignore: must_be_immutable
class BuyPage extends StatefulWidget {
  BuyPage({Key? key, required this.reference}) : super(key: key);

  String reference;

  @override
  State<BuyPage> createState() => _BuyPageState();
}

class _BuyPageState extends State<BuyPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _cliente = TextEditingController();

  late String _name = "Pancho";

  @override
  void initState() {
    initializeDateFormatting();
    _getNome();
    super.initState();
  }

  /*
  final Stream<QuerySnapshot> _ventasStream =
      FirebaseFirestore.instance.collection('ventas').snapshots();
*/
  @override
  Widget build(BuildContext context) {
    var datos = Provider.of<TotalPrice>(context, listen: false);
    debugPrint(datos.total.toString());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orçar'),
      ),
      floatingActionButton: Column(
        children: [
          const Spacer(),
          FloatingActionButton(
              heroTag: null,
              backgroundColor: Colors.blue,
              child: const Text(
                "List",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ListProduct(
                      forShell: false,
                      reference: widget.reference,
                    ),
                  ),
                );
              }),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
                heroTag: null,
                backgroundColor: Colors.blue,
                child: const Icon(
                  Icons.barcode_reader,
                  color: Colors.white,
                ),
                onPressed: () {
                  scanBarcodeNormal(true);
                }),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(' ${Utils.toDate(DateTime.now())}'),
            Text(' Vendedor   : $_name'),
            Text(' Ref : ${widget.reference}'),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _cliente,
                decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    labelText: "Cliente",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                    ),
                    contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0)),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
              height: 400,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(8),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('orçamentos')
                    .doc(widget.reference)
                    .collection('itens')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text("Carregando");
                  }
                  if (snapshot.hasData) {
                    debugPrint('lista vacia ');
                  }

                  return ListView(
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;

                      return ListTile(
                        title: Text(data['description']),
                        leading: Text('${data['quantidade']}'),
                        trailing:
                            Text('Rs ${data['preco'].toStringAsFixed(2)}'),
                        onLongPress: () {
                          context.read<TotalPrice>().addTotal(-data['preco']);
                          _db
                              .collection('orçamentos')
                              .doc(widget.reference)
                              .collection('itens')
                              .doc(data['docref'])
                              .delete();

                          _db
                              .collection('produc')
                              .doc(data['docref'])
                              .update({'stock': data['stockdeantes']});
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                'Total R\$: ${context.watch<TotalPrice>().total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 30.0),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (datos.total != 0.0) {
                  debugPrint(datos.total.toString());

                  _db.collection('ventas').doc(widget.reference).set({
                    'cliente': _cliente.text,
                    'total': datos.total,
                    'vendedor': _name,
                    'reference': widget.reference,
                    'data': Utils.toDate(DateTime.now()),
                    'hora': Utils.toTime(DateTime.now())
                  }, SetOptions(merge: true));

                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.black,
                      content: Text(
                        'Sem produto !',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                shadowColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: const Text(
                'Enviar pra Caixa',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getNome() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    setState(() {
      _name = preference.getString('nome') ?? '';
    });
  }

  Future<void> scanBarcodeNormal(bool isShell) async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      if (kDebugMode) {
        print(barcodeScanRes);
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailPage(
          barCode: barcodeScanRes,
          isNotShell: false,
          reference: widget.reference,
        ),
      ),
    );
  }
}
