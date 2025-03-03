import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessageScreen extends StatefulWidget {
  final DocumentSnapshot doc;

  const MessageScreen({super.key, required this.doc});

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
    if (message.isEmpty) {
      // Si el mensaje está vacío, mostramos un error en el Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("El mensaje no puede estar vacío."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    db.collection("users").doc(widget.doc.id).collection("notifications").add({
      "message": message,
      "title": user!.email,
      "date": FieldValue.serverTimestamp()
    }).then((_) {
      controller.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Mensaje enviado con éxito."),
          backgroundColor: Colors.green,
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Hubo un error al enviar el mensaje."),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.doc["email"], style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple, // AppBar morado
        elevation: 4,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        color: Colors.white, // Fondo blanco de la pantalla
        child: Column(
          children: [
            // Área para mostrar los mensajes
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[50], // Fondo gris claro
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.deepPurple), // Borde morado
                ),
                child: ListView(
                  children: [
                    // Aquí se pueden mostrar los mensajes enviados (esto es un ejemplo)
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        child: Text(
                          widget.doc["email"][0].toUpperCase(),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(widget.doc["email"], style: TextStyle(color: Colors.deepPurple)),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),

            // Campo para escribir mensaje
            Row(
              children: [
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: controller,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: "Escribe tu mensaje",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () => _messageHandler(controller.text),
                  backgroundColor: Colors.deepPurple, // Botón flotante morado
                  child: Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}