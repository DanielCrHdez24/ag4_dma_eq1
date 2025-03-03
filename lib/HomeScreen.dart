import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'LoginScreen.dart';
import 'MessageScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  User? currentUser;
  List<DocumentSnapshot> users = [];

  @override
  void initState() {
    super.initState();
    _getUsers();
  }

  void _getUsers() async {
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    QuerySnapshot snapshot = await db.collection("users").get();
    setState(() {
      users = snapshot.docs.where((doc) => doc.id != currentUser!.uid).toList();
    });
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contactos", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple, // Color morado profundo para el AppBar
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white), // Icono blanco
            onPressed: _logout,
          ),
        ],
      ),
      body: users.isNotEmpty
          ? ListView.builder(
        itemCount: users.length,
        itemBuilder: (ctx, index) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: Colors.deepPurple, width: 1), // Borde morado
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple, // Fondo morado para avatar
                child: Text(
                  users[index]["email"][0].toUpperCase(),
                  style: TextStyle(color: Colors.white), // Letra blanca en el avatar
                ),
              ),
              title: Text(
                users[index]["email"],
                style: TextStyle(color: Colors.deepPurple), // Texto morado
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MessageScreen(doc: users[index])),
                );
              },
            ),
          );
        },
      )
          : Center(
        child: CircularProgressIndicator(
          color: Colors.deepPurple, // Color morado del indicador
        ),
      ),
    );
  }
}