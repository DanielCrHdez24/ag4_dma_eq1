import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'HomeScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final TextEditingController mailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkUserAuth();
  }

  void _checkUserAuth() async {
    User? user = auth.currentUser;
    print("Usuario actual: ${user?.email ?? 'No autenticado'}");

    if (user != null) {
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      });
    }
  }

  void _login() async {
    String email = mailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(
        msg: "Por favor, ingresa email y contraseña",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      UserCredential result = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      String? token = await firebaseMessaging.getToken();

      await db.collection("users").doc(result.user!.uid).set({
        "email": result.user!.email,
        "fcmToken": token,
      }, SetOptions(merge: true));

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case "user-not-found":
          errorMessage = "Usuario no encontrado";
          break;
        case "wrong-password":
          errorMessage = "Contraseña incorrecta";
          break;
        case "invalid-email":
          errorMessage = "Correo electrónico no válido";
          break;
        default:
          errorMessage = "Error: ${e.message}";
      }
      Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Detectar si el tema es oscuro o claro
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Campo de texto para ingresar el correo
              TextField(
                controller: mailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: TextStyle(
                    color: isDarkMode ? Colors.yellow : Colors.black, // Amarillo en tema oscuro
                  ),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 15),
              // Campo de texto para la contraseña
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: "Contraseña",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  backgroundColor: Colors.green,
                ),
                onPressed: _login,
                child: Text("Iniciar sesión", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
