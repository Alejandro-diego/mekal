import 'package:brasil_fields/brasil_fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'details_de_venta.dart';

class VentasPage extends StatefulWidget {
  const VentasPage({Key? key}) : super(key: key);

  @override
  State<VentasPage> createState() => _VentasPageState();
}

class _VentasPageState extends State<VentasPage> {
  late bool integadro = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orçamentos'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('orçamentos')
            .orderBy('hora', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return const Text('Deu Error');
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
                  trailing: Column(
                    children: [
                      Text(
                        UtilBrasilFields.obterReal(data['total']),
                      ),
                      data['integrado']
                          ? const Text(
                              'Integrado',
                              style: TextStyle(color: Colors.green),
                            )
                          : const Text(
                              'No Integrado',
                              style: TextStyle(color: Colors.orange),
                            )
                    ],
                  ),
                  onTap: () {
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
