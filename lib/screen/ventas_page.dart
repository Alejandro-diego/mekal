import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'details_de_venta.dart';

class VentasPage extends StatefulWidget {
  const VentasPage({Key? key}) : super(key: key);

  @override
  State<VentasPage> createState() => _VentasPageState();
}

class _VentasPageState extends State<VentasPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orçamentos'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('orçamentos').snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return const Text('Deu Merda');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('Cargando');
          }
          return ListView(
            children:
                snapshot.data!.docs.map<Widget>((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  title: Text('Cliente : ${data['cliente']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Data : ${data['data']}'),
                      Text('Hora : ${data['hora']}'),
                      Text('Vendedor : ${data['vendedor']}'),
                      Text('Pagamento : ${data['pagamento']}'),
                    ],
                  ),
                  // leading: Text('${data['quantidade']}'),
                  trailing: Text('Rs ${data['total'].toStringAsFixed(2)}'),
                  onLongPress: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DetailsOfSales(
                          cliente: data['cliente'],
                          reference: data['reference'],
                        ),
                      ),
                    );
                  },
                  isThreeLine: true,
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
