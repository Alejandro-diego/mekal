import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/form_sing_in.dart';

class SingUp extends StatefulWidget {
  const SingUp({Key? key}) : super(key: key);

  @override
  State<SingUp> createState() => _SingUpState();
}

class _SingUpState extends State<SingUp> {
  final _formKey = GlobalKey<FormState>();
  final usuario = TextEditingController();
  final senha = TextEditingController();
  final email = TextEditingController();
  

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Positioned(
              width: size.width * 0.88,
              height: size.height,
              left: size.width * 0.10,
              top: size.height * 0.15,
              child: const Text(
                'Sing Up',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
              ),
            ),
            Positioned(
              width: size.width * 0.88,
              height: size.height,
              left: size.width * 0.05,
              top: size.height * 0.05,
              child: FormSigIn(
                keyvalidator: _formKey,
                passcontroller: senha,
                emailcontroller: email,             
                nameController: usuario,
                isSingUP: true,
              ),
            ),
            Positioned(
              left: size.width * 0.2,
              top: size.height * 0.64,
              child: SizedBox(
                height: 60,
                width: size.width * 0.60,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      siginUp();

                      colocarCredenciales();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shadowColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 25),
                  ),
                ),
              ),
            ),
            Positioned(
              right: size.width * 0.01,
              top: size.height * 0.95,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Power By',
                    style: GoogleFonts.cedarvilleCursive(
                      textStyle: const TextStyle(fontSize: 15),
                    ),
                  ),
                  Text(
                    'IOT',
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.w500,
                      textStyle:
                          const TextStyle(color: Colors.red, fontSize: 30),
                    ),
                  ),
                  Text(
                    'ech',
                    style: GoogleFonts.roboto(
                      textStyle:
                          const TextStyle(color: Colors.white, fontSize: 30),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future siginUp() async {
    late String error = "erro";
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: senha.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
     
      if (e.code == 'email-already-in-use') {
        error = "O endereço de e-mail já está sendo usado por outra conta.";
      } else if (e.code == 'invalid-email') {
        error = "O endereço de e-mail está mal formatado";
      } else if (e.code == 'weak-password') {
        error = "A senha e fraca ou nao e suficiente";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.black,
          content: Text(
            error,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  Future<void> colocarCredenciales() async {
    SharedPreferences preference = await SharedPreferences.getInstance();

    preference.setString('email', email.text);
    preference.setString('password', senha.text);
    preference.setString('nome', usuario.text);
  }
}
