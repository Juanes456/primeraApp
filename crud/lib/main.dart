import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/usuarios_screen.dart'; // Pantalla del admin
import 'screens/lista_screen.dart'; // Pantalla del usuario normal

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter CRUD',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login', // La app inicia en el login
      routes: {
        '/login': (context) =>  LoginScreen(),
        '/register': (context) =>  RegisterScreen(),
        '/usuarios': (context) =>  UsuariosScreen(), // Pantalla para el admin
        '/usuarios_lista': (context) =>  ListaScreen(), // Pantalla para usuarios normales
      },
    );
  }
}
