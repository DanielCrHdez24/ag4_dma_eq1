import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'homScreem.dart';
import 'Registro.dart'; // Asegúrate de importar la pantalla de registro

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

  @override
  void initState() {
    super.initState();
    _checkUserAuth();
  }

  void _checkUserAuth() async {
    User? user = auth.currentUser;
    if (user != null) {
      // Usar addPostFrameCallback para asegurarse de que la navegación ocurra después del ciclo de construcción
      WidgetsBinding.instance.addPostFrameCallback((_) {
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

    if (email.isNotEmpty && password.isNotEmpty) {
      // Mostrar el SnackBar indicando que se está procesando el login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Iniciando sesión..."),
          duration: Duration(seconds: 2), // Duración del mensaje
        ),
      );

      try {
        UserCredential result = await auth.signInWithEmailAndPassword(
            email: email, password: password);
        String? token = await firebaseMessaging.getToken();

        db.collection("users").doc(result.user!.uid).set({
          "email": result.user!.email,
          "fcmToken": token,
        });

        // Usar Future.delayed para evitar la navegación inmediata
        Future.delayed(Duration(milliseconds: 100), () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomeScreen()));
        });
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Error: $e",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: "Ingresa correo y contraseña",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50], // Fondo más suave
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Título de la pantalla
                Text(
                  "AG4 - Notificaciones",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple[700],
                  ),
                ),
                SizedBox(height: 30),

                // Email input
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: mailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: Colors.black), // Color del texto
                    decoration: InputDecoration(
                      icon: Icon(Icons.email, color: Colors.deepPurple),
                      hintText: "Escribe tu email",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Password input
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: passwordController,
                    obscureText: true,
                    style: TextStyle(color: Colors.black), // Color del texto
                    decoration: InputDecoration(
                      icon: Icon(Icons.lock, color: Colors.deepPurple),
                      hintText: "Escribe tu contraseña",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: 30),

                // Login button
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    backgroundColor: Colors.deepPurple, // Usando backgroundColor
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    "Aceptar",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Botón de registro
                TextButton(
                  onPressed: () {
                    // Navegar a la pantalla de registro
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegistroScreen()),
                    );
                  },
                  child: Text(
                    "¿No tienes cuenta? Regístrate aquí",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.deepPurple[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
