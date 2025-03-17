import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ApiService {
  final String baseUrl = 'http://192.168.1.3:5000/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final token = await _getToken();
      if (token == null) {
        print("⚠️ No hay token disponible");
        return [];
      }

      final response = await http.get(
        Uri.parse('$baseUrl/auth/usuarios'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['usuarios'] ?? []);
      } else {
        print("❌ Error en getUsers: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("❌ Excepción en getUsers: $e");
    }
    return [];
  }

  Future<bool> deleteUser(String id) async {
    try {
      final token = await _getToken();
      if (token == null) {
        print("⚠️ No hay token disponible");
        return false;
      }

      final decodedToken = JwtDecoder.decode(token);
      final rol = decodedToken['rol'];

      if (rol != 'admin') {
        print("❌ El usuario no tiene permisos para eliminar usuarios.");
        return false;
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/auth/usuarios/$id'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print(
          "❌ Error en deleteUser: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      print("❌ Excepción en deleteUser: $e");
    }
    return false;
  }

  Future<bool> updateUser(String id, String nombre, String email) async {
    try {
      final token = await _getToken();
      if (token == null) {
        print("⚠️ No hay token disponible");
        return false;
      }

      final decodedToken = JwtDecoder.decode(token);
      final rol = decodedToken['rol'];

      if (rol != 'admin') {
        print("❌ El usuario no tiene permisos para actualizar usuarios.");
        return false;
      }

      final response = await http.put(
        Uri.parse('$baseUrl/auth/usuarios/$id'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"nombre": nombre, "email": email}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print(
          "❌ Error en updateUser: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      print("❌ Excepción en updateUser: $e");
    }
    return false;
  }

  Future<Map<String, dynamic>?> createUser(
    String nombre,
    String email,
    String password,
  ) async {
    try {
      final token = await _getToken();
      if (token == null) {
        print("⚠️ No hay token disponible");
        return null;
      }

      final decodedToken = JwtDecoder.decode(token);
      final rol = decodedToken['rol'];

      if (rol != 'admin') {
        print("❌ El usuario no tiene permisos para crear usuarios.");
        return null;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/usuarios'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "nombre": nombre,
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print(
          "❌ Error en createUser: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      print("❌ Excepción en createUser: $e");
    }
    return null;
  }

  // Obtener la lista de productos
  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final token = await _getToken();
      if (token == null) {
        print("⚠️ No hay token disponible");
        return [];
      }

      final response = await http.get(
        Uri.parse('$baseUrl/productos'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['productos'] ?? []);
      } else {
        print(
          "❌ Error en getProducts: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      print("❌ Excepción en getProducts: $e");
    }
    return [];
  }

  // Crear producto
  Future<Map<String, dynamic>?> createProduct(
    String nombre,
    String descripcion,
    double precio,
  ) async {
    try {
      final token = await _getToken();
      if (token == null) {
        print("⚠️ No hay token disponible");
        return null;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/productos'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "nombre": nombre,
          "descripcion": descripcion,
          "precio": precio,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print(
          "❌ Error en createProduct: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      print("❌ Excepción en createProduct: $e");
    }
    return null;
  }

  // Actualizar producto
  Future<bool> updateProduct(
    String id,
    String nombre,
    String descripcion,
    double precio,
  ) async {
    try {
      final token = await _getToken();
      if (token == null) {
        print("⚠️ No hay token disponible");
        return false;
      }

      final response = await http.put(
        Uri.parse('$baseUrl/productos/$id'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "nombre": nombre,
          "descripcion": descripcion,
          "precio": precio,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print(
          "❌ Error en updateProduct: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      print("❌ Excepción en updateProduct: $e");
    }
    return false;
  }

  // Eliminar producto
  Future<bool> deleteProduct(String id) async {
    try {
      final token = await _getToken();
      if (token == null) {
        print("⚠️ No hay token disponible");
        return false;
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/productos/$id'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print(
          "❌ Error en deleteProduct: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      print("❌ Excepción en deleteProduct: $e");
    }
    return false;
  }
}
