import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /// Maneja los mensajes cuando la app está en segundo plano o cerrada.
  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print('🔔 Notificación en segundo plano:');
    print('📌 Título: ${message.notification?.title}');
    print('📌 Cuerpo: ${message.notification?.body}');
    print('📌 Datos: ${message.data}');
  }

  /// Inicializa las notificaciones y gestiona los permisos.
  Future<void> initNotifications() async {
    // Solicitar permisos de notificación
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print('❌ Permiso de notificación denegado.');
      return;
    }

    // Obtener el token FCM
    String? fcmToken = await _firebaseMessaging.getToken();
    if (fcmToken != null) {
      print('✅ Token FCM obtenido: $fcmToken');
      await _saveTokenToFirestore(fcmToken);
    }

    // Manejar mensajes en diferentes estados
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🔴 Notificación en primer plano:');
      print('📌 Título: ${message.notification?.title}');
      print('📌 Cuerpo: ${message.notification?.body}');
      print('📌 Datos: ${message.data}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📲 Usuario abrió la app desde la notificación');
      print('📌 Título: ${message.notification?.title}');
      print('📌 Cuerpo: ${message.notification?.body}');
    });
  }

  /// Guarda el token FCM del usuario en Firestore
  Future<void> _saveTokenToFirestore(String token) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'fcmToken': token,
      }).catchError((error) {
        print('⚠️ Error al guardar el token en Firestore: $error');
      });
    }
  }
}
