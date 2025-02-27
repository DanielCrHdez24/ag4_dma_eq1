import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'LoginScreen.dart';
import 'package:ag4_dma/api/firebase_api.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Inicializar las notificaciones (esto lo puedes mover a una clase adecuada también)
  await FirebaseApi().initNotifications();

  runApp(App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: LoginScreen(), // Aquí puede ir tu pantalla de inicio o login
    );
  }
}
