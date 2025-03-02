import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  User? user;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getUser();
    // Solicitar permisos para recibir notificaciones
    firebaseMessaging.requestPermission();
  }

  void _getUser() {
    user = auth.currentUser;
  }

  // Función para enviar el mensaje
  void _messageHandler(String message) async {
    if (message.isEmpty) return;

    print("Enviando mensaje: $message"); // Esto es solo para depurar

    try {
      // Guarda la notificación en Firestore
      await db.collection("users").doc(widget.doc.id).collection("notifications").add({
        "message": message,
        "title": user?.email ?? "Desconocido",
        "date": FieldValue.serverTimestamp(),
      });

      // Llama a la función para enviar la notificación push
      await _sendPushNotification(message);
      print("Mensaje enviado y notificación push realizada"); // Depuración

      controller.clear();
    } catch (e) {
      // Si hay un error, muestra un mensaje en pantalla
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al enviar el mensaje")));
      print("Error al enviar el mensaje: $e"); // Depuración
    }
  }

  // Función para enviar la notificación push
  Future<void> _sendPushNotification(String message) async {
    String? token = await firebaseMessaging.getToken();

    if (token != null) {
      try {
        // Envía la notificación al backend
        final response = await FirebaseFirestore.instance.collection("notifications").add({
          "message": message,
          "token": token, // El token del dispositivo de destino
          "title": "Notificación desde Flutter",
        });

        print("Notificación enviada con éxito: $response");
      } catch (e) {
        print("Error al enviar la notificación push: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.doc["email"], style: TextStyle(color: Colors.white))),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // Campo de texto para ingresar el mensaje y el botón de enviar
            Row(
              children: [
                // Campo de texto
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(hintText: "Escribe tu mensaje"),
                    maxLines: null, // Permite que el TextField se expanda si es necesario
                  ),
                ),
                SizedBox(width: 10), // Espacio entre el campo de texto y el botón
                // Botón de enviar
                FloatingActionButton(
                  onPressed: controller.text.isEmpty
                      ? null
                      : () {
                    _messageHandler(controller.text); // Llama a la función para enviar el mensaje
                  },
                  child: Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
