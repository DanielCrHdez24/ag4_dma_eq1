import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessageScreen extends StatefulWidget {
  final DocumentSnapshot doc;

  MessageScreen({required this.doc});

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  User? user;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  void _getUser() async {
    user = auth.currentUser;
    setState(() {});
  }

  void _messageHandler(String message) {
    db.collection("users").doc(widget.doc.id).collection("notifications").add({
      "message": message,
      "title": user!.email,
      "date": FieldValue.serverTimestamp()
    }).then((_) => controller.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.doc["email"], style: TextStyle(color: Colors.white))),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            Flexible(child: TextField(controller: controller, decoration: InputDecoration(hintText: "Escribe tu mensaje"))),
            FloatingActionButton(onPressed: () => _messageHandler(controller.text), child: Icon(Icons.send)),
          ],
        ),
      ),
    );
  }
}
