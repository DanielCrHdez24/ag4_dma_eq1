import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  // Corrige el nombre del parámetro 'message' para que sea 'RemoteMessage message'
  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Payload: ${message.data}');
  }

  Future<void> initNotifications() async {
    // Solicitar permisos de notificación
    await _firebaseMessaging.requestPermission();

    // Obtener el token FCM
    final fCMToken = await _firebaseMessaging.getToken();
    print('Token: $fCMToken');

    // Establecer el manejador de mensajes en segundo plano
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }
}
