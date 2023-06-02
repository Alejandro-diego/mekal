import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mekal/screen/ventas_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_slimy_card/flutter_slimy_card.dart';
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
        body: ListView(
          children: <Widget>[
            const SizedBox(
              height: 40,
            ),
            FlutterSlimyCard(
              color: Colors.white,
              topCardHeight: 160,
              bottomCardHeight: 120,
              topCardWidget: topWidget(),
              bottomCardWidget: bottomWidget(),
            ),
          ],
        ));
  }

  topWidget() {
    return const SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: 90,
            child: Image(
              image: AssetImage('assets/pic/logo1.jpg'),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            'Procure itens',
            style: TextStyle(color: Colors.blue, fontSize: 24),
          ),
          SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }

  bottomWidget() {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Flexible(
            child: ElevatedButton(
                onPressed: () {
                  scanBarcodeNormal();
                },
                child: const Icon(Icons.search)),
          ),
        ],
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

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailPage(
          barCode: barcodeScanRes,
          isNotShell: true,
          reference: '',
        ),
      ),
    );
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
