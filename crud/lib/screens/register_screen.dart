import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService authService = AuthService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _register() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    print("📌 Intentando registrar:");
    print("Nombre: $name");
    print("Email: $email");
    print("Password: ${'*' * password.length}"); // No mostrar la contraseña real

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _mostrarMensaje('⚠️ Por favor, completa todos los campos');
      return;
    }

    if (!_validarEmail(email)) {
      _mostrarMensaje('⚠️ Ingresa un correo válido');
      return;
    }

    if (password.length < 6) {
      _mostrarMensaje('⚠️ La contraseña debe tener al menos 6 caracteres');
      return;
    }

    try {
      bool success = await authService.register(name, email, password);
      if (success) {
        _mostrarMensaje('✅ Registro exitoso');
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        _mostrarMensaje('❌ Error al registrar usuario');
      }
    } catch (e) {
      print("❌ Excepción en registro: $e");
      _mostrarMensaje('⚠️ Ocurrió un error, intenta de nuevo');
    }
  }

  bool _validarEmail(String email) {
    final RegExp regex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return regex.hasMatch(email);
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nombre'),
              textInputAction: TextInputAction.next,
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Correo electrónico'),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
              textInputAction: TextInputAction.done,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: Text('Registrarse'),
            ),
          ],
        ),
      ),
    );
  }
}
