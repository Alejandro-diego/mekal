import 'package:brasil_fields/brasil_fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mekal/Model/data.dart';
import 'package:speed_dial_fab/speed_dial_fab.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

import '../Model/producOrc.dart';
import '../Model/total.dart';
import '../utils.dart';
import 'detalles.dart';
import 'list_produc.dart';

// ignore: must_be_immutable
class OrcamentoPage extends StatefulWidget {
  OrcamentoPage({Key? key, required this.reference}) : super(key: key);
  Data? datos;
  String reference;

  @override
  State<OrcamentoPage> createState() => _OrcamentoPageState();
}

class _OrcamentoPageState extends State<OrcamentoPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _cliente = TextEditingController(text: 'consumidor final');

  String iten1 = 'Dinheiro';

  static const menuItems = <String>[
    'Dinheiro',
    'Pix',
    'Cartão Debito',
    'Cartão Credito',
    'A Prazo',
    'Boleto'
  ];
  final List<DropdownMenuItem<String>> _dropDownMenuItens = menuItems
      .map((String value) => DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          ))
      .toList();

  late String _name = "Pancho";
  final List<String> _msj = [];
  @override
  void initState() {
    initializeDateFormatting();
    _getNome();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var datos = Provider.of<TotalPrice>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orçar Produtos'),
      ),
      floatingActionButton: SpeedDialFabWidget(
        secondaryIconsList: const [
          Icons.data_array_outlined,
          Icons.barcode_reader,
        ],
        secondaryIconsText: const [
          "Lista",
          "ScanProduto",
        ],
        secondaryIconsOnPress: [
          () => {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ListProduct(
                      forShell: false,
                      reference: widget.reference,
                    ),
                  ),
                )
              },
          () => {scanBarcodeNormal(true)},
        ],
        secondaryBackgroundColor: Colors.black,
        secondaryForegroundColor: Colors.white,
        primaryBackgroundColor: Colors.black,
        primaryForegroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Consumer<ProducProvider>(
          builder: (context, data, child) {
            return data.producItem.isNotEmpty
                ? Column(
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
                              contentPadding:
                                  EdgeInsets.fromLTRB(10, 0, 10, 0)),
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
                        child: ListView.builder(
                          itemCount: data.producItem.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(data.producItem[index].description),
                              leading:
                                  Text('${data.producItem[index].qantidade}'),
                              trailing: Text(UtilBrasilFields.obterReal(
                                  data.producItem[index].preco)),
                              onLongPress: () {
                                context
                                    .read<TotalPrice>()
                                    .addTotal(-data.producItem[index].preco);
                                context
                                    .read<ProducProvider>()
                                    .removeItem(data.producItem[index]);
                              },
                            );
                          },
                        ),
                      ),
                      Text(
                          '   Total Sem Desconto R\$ : ${UtilBrasilFields.obterReal(context.watch<TotalPrice>().total)}'),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 40,
                          width: 120,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                suffixText: '%', prefixText: 'Desconto: '),
                            onChanged: (value) => context
                                .read<TotalPrice>()
                                .porcentualChangue(value),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          'Total R\$: ${UtilBrasilFields.obterReal(context.watch<TotalPrice>().total - context.watch<TotalPrice>().desconto, moeda: false)}',
                          style: const TextStyle(fontSize: 30.0),
                        ),
                      ),
                      DropdownButton<String>(
                        value: iten1,
                        onChanged: ((v) {
                          setState(() {
                            debugPrint(v);
                            iten1 = v!;
                          });
                        }),
                        items: _dropDownMenuItens,
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              if (data.producItem.isNotEmpty) {
                                for (var a = 0;
                                    a < data.producItem.length;
                                    a++) {
                                  _db
                                      .collection('orçamentos')
                                      .doc(widget.reference)
                                      .collection("itens")
                                      .doc(data.producItem[a].barCode)
                                      .set({
                                        'produto' : data.producItem[a].codigoDeProduto,
                                    'description':
                                        data.producItem[a].description,
                                    'quantidade': data.producItem[a].qantidade,
                                    'preco': data.producItem[a].preco,
                                    'docref': data.producItem[a].barCode
                                  });

                                  _db
                                      .collection('produc')
                                      .doc(data.producItem[a].barCode)
                                      .update({
                                    'stock': data.producItem[a].stock -
                                        data.producItem[a].qantidade
                                  });
                                }

                                _db
                                    .collection('orçamentos')
                                    .doc(widget.reference)
                                    .set({
                                  'pagamento': iten1,
                                  'cliente': _cliente.text,
                                  'total': datos.total - datos.desconto,
                                  'vendedor': _name,
                                  'reference': widget.reference,
                                  'data': Utils.toDate(DateTime.now()),
                                  'hora': Utils.toTime(DateTime.now())
                                }, SetOptions(merge: true));

                                context.read<ProducProvider>().clearList();
                                context.read<TotalPrice>().clearValores();
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text('Finalizar'),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (data.producItem.isNotEmpty) {
                                for (var a = 0;
                                    a < data.producItem.length;
                                    a++) {
                                  _msj.add(
                                      '${data.producItem[a].qantidade}  ${data.producItem[a].description}  R\$${data.producItem[a].preco}');
                                }
                                debugPrint(
                                    (_msj.toString().replaceAll(',', '\n'))
                                        .replaceAll('[', '')
                                        .replaceAll(']', ''));

                                Share.share(
                                    '${(_msj.toString().replaceAll(',', '\n')).replaceAll('[', '').replaceAll(']', '')}\n Total : ${UtilBrasilFields.obterReal(datos.total - datos.desconto)} ');
                                _msj.clear();
                              }
                            },
                            child: const Icon(Icons.share),
                          ),
                        ],
                      ),
                    ],
                  )
                : const Center(
                    child: Text('Sem Itens'),
                  );
          },
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

    barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancel', true, ScanMode.BARCODE);

    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailPage(
          produto: 12,
          isNotShell: false,
          reference: widget.reference,
        ),
      ),
    );
  }
}
