import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'LoginScreen.dart';
import 'MessageScreen.dart';

class HomeScreen extends StatefulWidget {
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
        title: Text("Home", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: Icon(Icons.exit_to_app, color: Colors.black), onPressed: _logout),
        ],
      ),
      body: users.isNotEmpty
          ? ListView.builder(
        itemCount: users.length,
        itemBuilder: (ctx, index) {
          return ListTile(
            leading: CircleAvatar(child: Text(users[index]["email"][0])),
            title: Text(users[index]["email"]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MessageScreen(doc: users[index])),
              );
            },
          );
        },
      )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
