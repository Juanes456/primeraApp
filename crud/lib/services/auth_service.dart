import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'http://192.168.1.3:5000/api/auth';

  // REGISTRO
  Future<bool> register(String nombre, String email, String password) async {
    try {
      if (nombre.isEmpty || email.isEmpty || password.isEmpty) {
        print("⚠️ Error: Campos vacíos en el registro");
        return false;
      }

      final Map<String, String> userData = {
        "nombre": nombre.trim(),
        "email": email.trim(),
        "password": password,
      };

      print("📌 Enviando datos al backend (registro): ${jsonEncode(userData)}");

      final response = await http.post(
        Uri.parse('$baseUrl/usuarios'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(userData),
      );

      print("📩 Respuesta del servidor (registro): ${response.body}");

      final Map<String, dynamic>? data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return data != null ? _guardarCredenciales(data) : false;
      } else {
        print("❌ Error en registro: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Excepción en registro: $e");
      return false;
    }
  }

  // LOGIN
  Future<bool> login(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        print("⚠️ Error: Campos vacíos en el login");
        return false;
      }

      final Map<String, String> loginData = {
        "email": email.trim(),
        "password": password,
      };

      print("📌 Enviando datos al backend (login): ${jsonEncode(loginData)}");

      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(loginData),
      );

      print("📩 Respuesta del servidor (login): ${response.body}");

      final Map<String, dynamic>? data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data != null ? _guardarCredenciales(data) : false;
      } else {
        print("❌ Error en login: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Excepción en login: $e");
      return false;
    }
  }

  // Guardar credenciales después del login o registro
  Future<bool> _guardarCredenciales(Map<String, dynamic> data) async {
    try {
      if (data["token"] == null) {
        print("⚠️ No se encontró el campo 'token' en la respuesta");
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      bool tokenGuardado = await prefs.setString('token', data['token']);
      bool rolGuardado = await prefs.setString('rol', data["rol"] ?? "usuario");

      if (tokenGuardado && rolGuardado) {
        print("✅ Token y rol guardados exitosamente");
        return true;
      } else {
        print("⚠️ No se pudieron guardar las credenciales");
        return false;
      }
    } catch (e) {
      print("❌ Excepción en _guardarCredenciales: $e");
      return false;
    }
  }

  // Obtener token almacenado
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("🔑 Token obtenido: $token");
    return token;
  }

  // Obtener el rol del usuario
  Future<String?> getRol() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('rol');
  }

  // Cerrar sesión
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('rol');
    print("👋 Sesión cerrada correctamente");
  }

  // Obtener todos los usuarios
  Future<List<dynamic>?> obtenerUsuarios() async {
    try {
      final token = await getToken();

      if (token == null) {
        print("⚠️ No se encontró un token");
        return null;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/usuarios'),
        headers: {
          'Authorization': 'Bearer $token',
          "Content-Type": "application/json",
        },
      );

      print("📩 Respuesta del servidor (obtener usuarios): ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['usuarios'];
      } else {
        print(
          "❌ Error al obtener usuarios: ${response.statusCode} - ${response.body}",
        );
        return null;
      }
    } catch (e) {
      print("❌ Excepción en obtener usuarios: $e");
      return null;
    }
  }
}
