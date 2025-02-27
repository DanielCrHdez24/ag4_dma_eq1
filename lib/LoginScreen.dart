import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
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
        ToastContext().init(context); // Necesario para usar Toast en versiones recientes
        Toast.show("Error: $e", duration: Toast.lengthLong, gravity: Toast.center);
      }
    } else {
      ToastContext().init(context);
      Toast.show("Provide email and password",
          duration: Toast.lengthShort, gravity: Toast.center);
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
