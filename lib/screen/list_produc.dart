import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

import 'detalles.dart';

// ignore: must_be_immutable
class ListProduct extends StatefulWidget {
  ListProduct({Key? key, required this.forShell, required this.reference})
      : super(key: key);
  bool forShell = true;
  String reference;
  @override
  State<ListProduct> createState() => _ListProductState();
}

class _ListProductState extends State<ListProduct> {
  late bool find = false;
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Lista de Produto',
            suffixIcon: Icon(Icons.search),
          ),
          onChanged: (value) => setState(() {}),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          child: const Icon(
            Icons.shopping_cart_outlined,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          }),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('produto')
            //.where('stock' ,isEqualTo : null)
            .orderBy('description', descending: find)
            .startAt([_searchController.text.toUpperCase()]).endAt(
                ['${_searchController.text.toUpperCase()}\uf8ff']).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Carregando");
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;

              return ListTile(
                isThreeLine: true,
                title: Text(data['description']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Produto n° :${data['produto']}'),
                    Text(
                      'Estoque : ${data['stock']}',
                      style: TextStyle(
                          color:
                              data['stock'] == "0" ? Colors.red : Colors.white),
                    ),
                  ],
                ),
                trailing: Text('Rs ${data['preco']}'),
                onTap: () {
                  if (data['stock'] != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DetailPage(
                          produto: data['produto'],
                          isNotShell: widget.forShell,
                          reference: widget.reference,
                        ),
                      ),
                    );
                  }
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
