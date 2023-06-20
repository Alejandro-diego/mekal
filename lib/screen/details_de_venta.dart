import 'package:brasil_fields/brasil_fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class DetailsOfSales extends StatefulWidget {
  DetailsOfSales({Key? key, required this.cliente, required this.reference})
      : super(key: key);
  String reference;
  String cliente;
  @override
  State<DetailsOfSales> createState() => _DetailsOfSalesState();
}

class _DetailsOfSalesState extends State<DetailsOfSales> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compras de ${widget.cliente}'),
      ),
      body: Column(
        children: [
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
                  return const Text('Algo deu errado');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CupertinoActivityIndicator(),
                  );
                }

                return ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;

                    return ListTile(
                      subtitle: Text('Produto : ${data['produto']}'),
                      title: Text(data['description']),
                      leading: Text('${data['quantidade']}'),
                      trailing: Text(
                        UtilBrasilFields.obterReal(data['preco']),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
