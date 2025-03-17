import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class ListaScreen extends StatefulWidget {
  const ListaScreen({super.key});

  @override
  _ListaScreenState createState() => _ListaScreenState();
}

class _ListaScreenState extends State<ListaScreen> {
  final AuthService authService = AuthService();
  final ApiService apiService = ApiService();
  List<Map<String, dynamic>> usuarios = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _obtenerUsuarios();
  }

  // Función para obtener usuarios desde el servicio API
  Future<void> _obtenerUsuarios() async {
    setState(() => isLoading = true); // Activamos el indicador de carga
    try {
      final data = await apiService.getUsers(); // Llamada a la API
      if (mounted) {
        setState(() {
          usuarios = data;
          isLoading = false; // Desactivamos el indicador de carga
        });
      }
    } catch (e) {
      print("❌ Error en _obtenerUsuarios: $e");
      if (mounted) {
        setState(() => isLoading = false); // Desactivamos el indicador si ocurre error
      }
      _mostrarMensaje("Error al obtener usuarios: $e"); // Mostramos el mensaje de error
    }
  }

  // Función para cerrar sesión
  void _cerrarSesion() async {
    await authService.logout(); // Llamamos al servicio para cerrar sesión
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login'); // Redirigimos a la pantalla de login
    }
  }

  // Función para mostrar mensajes de notificación (SnackBar)
  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Usuarios'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _obtenerUsuarios, // Botón de refresco
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _cerrarSesion, // Botón para cerrar sesión
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text('Cargando usuarios...', style: TextStyle(fontSize: 16)),
                ],
              ),
            )
          : usuarios.isEmpty
              ? Center(child: Text("No hay usuarios disponibles", style: TextStyle(fontSize: 16)))
              : ListView.builder(
                  itemCount: usuarios.length,
                  itemBuilder: (context, index) {
                    final usuario = usuarios[index];
                    return ListTile(
                      title: Text(usuario['nombre'] ?? 'Sin nombre disponible'),
                      subtitle: Text(usuario['email'] ?? 'Sin email disponible'),
                      onTap: () {
                        // Aquí puedes navegar a la pantalla de detalles del usuario si es necesario
                        // Navigator.push(context, MaterialPageRoute(builder: (_) => DetallesUsuarioScreen(usuario: usuario)));
                      },
                    );
                  },
                ),
    );
  }
}
