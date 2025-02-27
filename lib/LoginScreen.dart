import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Importación corregida
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

  @override
  void initState() {
    super.initState();
    _checkUserAuth();
  }

  void _checkUserAuth() async {
    User? user = auth.currentUser;
    if (user != null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    }
  }

  void _login() async {
    String email = mailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        UserCredential result = await auth.signInWithEmailAndPassword(
            email: email, password: password);
        String? token = await firebaseMessaging.getToken();

        db.collection("users").doc(result.user!.uid).set({
          "email": result.user!.email,
          "fcmToken": token,
        });

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Error: $e",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: "Provide email and password",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding: EdgeInsets.all(10),
                child: TextField(
                    controller: mailController,
                    decoration: InputDecoration(labelText: "Email"))),
            Padding(
                padding: EdgeInsets.all(10),
                child: TextField(
                    controller: passwordController,
                    decoration: InputDecoration(labelText: "Password"),
                    obscureText: true)),
            MaterialButton(color: Colors.green, onPressed: _login, child: Text("Login")),
          ],
        ),
      ),
    );
  }
}
