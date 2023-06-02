import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mekal/Model/total.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../Model/data.dart';
import '../Model/producOrc.dart';
import 'caragar_produto.dart';

// ignore: must_be_immutable
class DetailPage extends StatefulWidget {
  DetailPage({
    Key? key,
    required this.barCode,
    required this.isNotShell,
    required this.reference,
  }) : super(key: key);
  String barCode;
  bool isNotShell;
  String reference;
  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  CollectionReference produc = FirebaseFirestore.instance.collection("produc");

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late int _quantidade = 1;
  var uuid = const Uuid();

  late int unit = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
          future: produc.doc(widget.barCode).get(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text("Error "));
            }
            if (snapshot.hasData && !snapshot.data!.exists) {
              return const Center(
                child: Text("Produto não encontrado"),
              );
            }
            if (snapshot.connectionState == ConnectionState.done) {
              Map<String, dynamic> data =
                  snapshot.data!.data() as Map<String, dynamic>;

              return Center(
                child: Column(
                  children: [
                    const Spacer(),
                    Container(
                      height: 200.0,
                      width: 300.0,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color.fromARGB(255, 49, 45, 45)),
                        color: Colors.black.withOpacity(.5),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade800,
                            offset: const Offset(6, 6),
                            blurRadius: 15.0,
                            spreadRadius: 1.0,
                          ),
                          const BoxShadow(
                            color: Colors.black,
                            offset: Offset(-6, -6),
                            blurRadius: 15,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Text(
                              data["description"],
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.amber),
                            ),
                          ),
                          Positioned(
                            top: 35,
                            left: 10,
                            child: Text(
                              'Produto N° :  ${data["produto"]}',
                              style: const TextStyle(color: Colors.amber),
                            ),
                          ),
                          Positioned(
                            top: 60,
                            left: 10,
                            child: data["stock"] != 0
                                ? Text(
                                    'Quantidade disponivel :  ${data["stock"]}',
                                    style: const TextStyle(color: Colors.amber),
                                  )
                                : const Text(
                                    'Quantidade disponivel :  SIN STOCK',
                                    style: TextStyle(color: Colors.red),
                                  ),
                          ),
                          widget.isNotShell
                              ? const Text('')
                              : Positioned(
                                  bottom: 10,
                                  right: 10,
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: _quantidade > 1
                                            ? () {
                                                setState(() {
                                                  _quantidade--;
                                                });
                                              }
                                            : () {},
                                        icon:
                                            const Icon(Icons.minimize, fill: 1),
                                      ),
                                      Text(
                                        'Quantidade :   $_quantidade',
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      IconButton(
                                        onPressed: _quantidade < data["stock"]
                                            ? () {
                                                setState(() {
                                                  _quantidade++;
                                                });
                                              }
                                            : () {},
                                        icon: const Icon(Icons.add, fill: 1),
                                      ),
                                    ],
                                  ),
                                ),
                          Positioned(
                            bottom: 60,
                            left: 10,
                            child: Row(
                              children: [
                                const Text("Precio de venda R\$ :  "),
                                Text(
                                  '${data["preco"] * _quantidade}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                      color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    widget.isNotShell
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("OK"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => CargarProduto(
                                        description: data["description"],
                                        barCode: data["barCode"],
                                        preco: data["preco"],
                                        produto: data["produto"],
                                        reference: data["reference"],
                                        stock: data["stock"],
                                      ),
                                    ),
                                  );
                                },
                                child: const Text("Edit"),
                              ),
                              ElevatedButton(
                                  onPressed: () async {
                                    produc.doc(data["barCode"]).delete();
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Apagar"))
                            ],
                          )
                        : Row(
                            /// add produc
                            children: [
                              ElevatedButton(
                                onPressed: data["stock"] != 0
                                    ? () async {
                                        context.read<TotalPrice>().addTotal(
                                            data["preco"] * _quantidade);

                                        context.read<ProducProvider>().addItem(
                                              Data(
                                                codigoDeProduto:
                                                    data["produto"],
                                                qantidade: _quantidade,
                                                stock: data['stock'],
                                                preco:
                                                    data["preco"] * _quantidade,
                                                barCode: data['barCode'],
                                                description:
                                                    data["description"],
                                              ),
                                            );

                                        Navigator.of(context).pop();
                                      }
                                    : () {
                                        _db
                                            .collection("producFaltante")
                                            .doc(widget.barCode)
                                            .set({
                                          'description': data["description"],
                                          'stock': data["stock"],
                                        });
                                      },
                                child: const Text("Agregar Produto"),
                              ),
                            ],
                          ),
                    const Spacer(),
                  ],
                ),
              );
            }

            return const Center(child: LinearProgressIndicator());
          }),
    );
  }
}
