import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mekal/screen/ventas_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'caragar_produto.dart';
import 'detalles.dart';
import 'list_produc.dart';
import 'orcar_page.dart';

class HomePage1 extends StatefulWidget {
  const HomePage1({Key? key}) : super(key: key);

  @override
  State<HomePage1> createState() => _HomePage1State();
}

class _HomePage1State extends State<HomePage1> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  var uuid = const Uuid();
  late String reference = uuid.v1();
  File? file;
  XFile? imagePiked;
  List<File> filiList = [];

  late String name = "";
  late String email = "";
  late String photo = "";
  @override
  void initState() {
    _getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('MekalStock'),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(name),
              accountEmail: Text(email),
              currentAccountPicture: GestureDetector(
                child: Container(
                  color: Colors.transparent,
                  child: photo.isNotEmpty
                      ? Image.memory(base64Decode(photo))
                      : const Icon(
                          Icons.person,
                          size: 30,
                        ),
                ),
                onLongPress: () {
                  pickImage();
                },
              ),
            ),
            ListTile(
              title: const Text('Orçar produtos'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => OrcamentoPage(
                      reference: uuid.v1(),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Lista de produto'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ListProduct(
                      forShell: true,
                      reference: "",
                    ),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Adicionar Produtos'),
              onTap: () {
                Navigator.of(context).push(_cargarProducto());
              },
            ),
            ListTile(
              title: const Text('Orçamentos'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const VentasPage(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Sair'),
              onTap: () {
                FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(30),
             
              width: size.width - 50,
              height: 400,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    
                    image: AssetImage('assets/pic/logo2.jpg'),
                  ),),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Future<void> _getUser() async {
    SharedPreferences get = await SharedPreferences.getInstance();
    setState(() {
      name = get.getString('nome') ?? 'semNome';
      email = get.getString('email') ?? 'sememail';
      photo = get.getString('foto') ?? '';
    });
  }

  Future pickImage() async {
    final imagePiked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxHeight: 200,
        maxWidth: 100,
        imageQuality: 10);
    SharedPreferences put = await SharedPreferences.getInstance();

    final bytes = File(imagePiked!.path).readAsBytesSync();

    setState(() {
      file = File(imagePiked.path);
      put.setString("foto", base64Encode(bytes));
      debugPrint(base64Encode(bytes));
    });
  }

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;

    barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancelar', true, ScanMode.BARCODE);

    if (!mounted) return;

    debugPrint(barcodeScanRes);

    await _db
        .collection('produto')
        .where('barCode', isEqualTo: int.parse(barcodeScanRes))
        .limit(1)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        debugPrint(doc["produto"].toString());

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DetailPage(
              produto: doc["produto"],
              isNotShell: true,
              reference: '',
            ),
          ),
        );
      }
    });
  }
}

Route _cargarProducto() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => CargarProduto(
      description: '',
      barCode: '',
      preco: 0,
      produto: 0,
      reference: '',
      stock: 0,
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;
      var tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve),
      );

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
