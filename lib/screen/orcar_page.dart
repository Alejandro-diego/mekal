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
import '../Model/producorc.dart';
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
  final List<Map> _item = [];

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
          () => {scanBarcodeNormal()},
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
                              trailing: Text(
                                UtilBrasilFields.obterReal(
                                    data.producItem[index].preco),
                              ),
                              onTap: () async {
                                _cantidadModificar(
                                    data.producItem[index].description,
                                    data.producItem[index].qantidade,
                                    data.producItem[index].preco,
                                    data.producItem[index].stock,
                                    index);
                              },
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
                                      .doc(data.producItem[a].codigoDeProduto
                                          .toString())
                                      .set({
                                    'produto':
                                        data.producItem[a].codigoDeProduto,
                                    'description':
                                        data.producItem[a].description,
                                    'quantidade': data.producItem[a].qantidade,
                                    'preco': data.producItem[a].preco,
                                    'docref': data.producItem[a].barCode
                                  });
                                  /*

                                  _db
                                      .collection('produtos')
                                      .doc(data.producItem[a].codigoDeProduto
                                          .toString())
                                      .update({
                                    'stock': (data.producItem[a].stock -
                                            data.producItem[a].qantidade)
                                        .toString()
                                  });*/

                                  _item.add({
                                    'codigo': int.parse(
                                        data.producItem[a].codigoDeProduto),
                                    'quantidade': data.producItem[a].qantidade,
                                    'preco': data.producItem[a].precoUnitario,
                                  });
                                }
                                _db
                                    .collection('pedidos')
                                    .doc(widget.reference)
                                    .set({
                                      'percentual_desconto': datos.percentual,
                                  'codigo_loja': 1,
                                  'valor_desconto': datos.desconto,
                                  'codigo': int.parse(widget.reference),
                                  'data': Utils.toDateWhitBar(DateTime.now()),
                                  'hora': Utils.toTime(DateTime.now()),
                                  'volor_total': double.parse(
                                      (datos.total )
                                          .toStringAsFixed(2)),
                                  'informacoes_cliente': null,
                                  'itens': FieldValue.arrayUnion(_item),
                                  'integrado': false
                                }, SetOptions(merge: true));

                                _db
                                    .collection('orçamentos')
                                    .doc(widget.reference)
                                    .set({
                                  'integrado': false,
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
                                  _item.add({
                                    'codigo':
                                        data.producItem[a].codigoDeProduto,
                                    'quantidade': data.producItem[a].qantidade,
                                    'preco': data.producItem[a].preco
                                  });
                                }

                                _db
                                    .collection('sharepedidos')
                                    .doc(widget.reference)
                                    .set(
                                        {'itens': FieldValue.arrayUnion(_item)},
                                        SetOptions(merge: true));

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

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;

    barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancelar', true, ScanMode.BARCODE);

    if (!mounted) return;

    debugPrint(barcodeScanRes);

    await _db
        .collection('produtos')
        .where('barCode', isEqualTo: barcodeScanRes)
        .limit(1)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        debugPrint(doc["produto"].toString());

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DetailPage(
              produto: doc["produto"],
              isNotShell: false,
              reference: '',
            ),
          ),
        );
      }
    });
  }

  void _cantidadModificar(
      String desc, int quantidades, double price, int stock, int index) async {
    var prunit = price / quantidades;
    var quantidade = quantidades;
    var unit = 0;
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black.withOpacity(.5),
          title: Text(desc),
          content: StatefulBuilder(
            builder: (BuildContext context, setState) {
              return Container(
                padding: const EdgeInsets.all(10),
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Estoque   :${(stock - quantidades) + unit} '),
                    Row(
                      children: [
                        const Text('Quantidade :'),
                        IconButton(
                          onPressed: quantidade > 1
                              ? () {
                                  setState(() {
                                    quantidade--;
                                    unit++;
                                  });
                                }
                              : () {},
                          icon: const Icon(Icons.remove, fill: 1),
                        ),
                        Text('$quantidade'),
                        IconButton(
                          onPressed: quantidade < stock
                              ? () {
                                  setState(() {
                                    quantidade++;
                                    unit--;
                                  });
                                }
                              : () {},
                          icon: const Icon(Icons.add, fill: 1),
                        ),
                      ],
                    ),
                    Text(UtilBrasilFields.obterReal(prunit * quantidade))
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                context
                    .read<ProducProvider>()
                    .updateIten(index, prunit * quantidade, quantidade);

                debugPrint('${(prunit * quantidade - price)}');

                context
                    .read<TotalPrice>()
                    .addTotal((prunit * quantidade) - price);

                Navigator.of(context).pop();
              },
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }
}
