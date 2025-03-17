import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../screens/lista_screen.dart';
import '../screens/login_screen.dart';
import 'productos_screen.dart'; // Importar la nueva pantalla de productos

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  _UsuariosScreenState createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  final AuthService authService = AuthService();
  final ApiService apiService = ApiService();
  String rol = '';
  List<Map<String, dynamic>> usuarios = [];
  List<Map<String, dynamic>> usuariosFiltrados = [];
  bool isLoading = true;
  Set<String> loadingActions = {};
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _obtenerRolYUsuarios();
    searchController.addListener(_filtrarUsuarios);
  }

  Future<void> _obtenerRolYUsuarios() async {
    setState(() => isLoading = true);
    try {
      final userRol = await authService.getRol();
      if (userRol != 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ListaScreen()),
        );
        return;
      }
      final data = await apiService.getUsers();
      if (mounted) {
        setState(() {
          rol = userRol ?? '';
          usuarios = data;
          usuariosFiltrados = data;
          isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Error en _obtenerRolYUsuarios: $e");
      _mostrarMensaje("Error al obtener usuarios");
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _filtrarUsuarios() {
    String query = searchController.text.toLowerCase();
    setState(() {
      usuariosFiltrados = usuarios
          .where((usuario) =>
              usuario['nombre'].toLowerCase().contains(query) ||
              usuario['email'].toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _cerrarSesion() async {
    await authService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _eliminarUsuario(int index, String userId) async {
    bool confirmar = await _confirmarEliminacion();
    if (!confirmar) return;

    setState(() => loadingActions.add(userId));
    try {
      final eliminado = await apiService.deleteUser(userId);
      if (eliminado && mounted) {
        setState(() {
          usuariosFiltrados.removeAt(index);
          loadingActions.remove(userId);
        });
        _mostrarMensaje("Usuario eliminado correctamente");
      } else {
        _mostrarMensaje("No se pudo eliminar el usuario");
      }
    } catch (e) {
      print("❌ Error en _eliminarUsuario: $e");
      _mostrarMensaje("Error al eliminar usuario");
    }
    setState(() => loadingActions.remove(userId));
  }

  Future<bool> _confirmarEliminacion() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Confirmar eliminación"),
            content: Text("¿Estás seguro de que quieres eliminar este usuario? Esta acción no se puede deshacer."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text("Eliminar"),
              ),
            ],
          ),
        ) ?? false;
  }

  Future<void> _agregarUsuario() async {
    TextEditingController nombreController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    bool agregado = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Agregar Usuario"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: InputDecoration(labelText: "Nombre"),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: "Email"),
                ),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: "Contraseña"),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nombreController.text.isNotEmpty &&
                      emailController.text.isNotEmpty &&
                      passwordController.text.isNotEmpty) {
                    final nuevoUsuario = await apiService.createUser(
                      nombreController.text,
                      emailController.text,
                      passwordController.text,
                    );

                    if (nuevoUsuario != null && mounted) {
                      setState(() => usuarios.add(nuevoUsuario));
                      _mostrarMensaje("Usuario agregado correctamente");
                      Navigator.pop(context, true);
                    } else {
                      _mostrarMensaje("Error al agregar usuario");
                    }
                  }
                },
                child: Text("Agregar"),
              ),
            ],
          ),
        ) ?? false;

    if (agregado) {
      _obtenerRolYUsuarios();
    }
  }

  Future<void> _editarUsuario(int index, Map<String, dynamic> usuario) async {
    TextEditingController nombreController =
        TextEditingController(text: usuario['nombre']);
    TextEditingController emailController =
        TextEditingController(text: usuario['email']);

    bool actualizado = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Editar Usuario"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: InputDecoration(labelText: "Nombre"),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: "Email"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final actualizado = await apiService.updateUser(
                    usuario['_id'],
                    nombreController.text,
                    emailController.text,
                  );

                  if (actualizado && mounted) {
                    setState(() {
                      usuarios[index]['nombre'] = nombreController.text;
                      usuarios[index]['email'] = emailController.text;
                    });
                    _mostrarMensaje("Usuario actualizado correctamente");
                    Navigator.pop(context, true);
                  } else {
                    _mostrarMensaje("Error al actualizar usuario");
                  }
                },
                child: Text("Guardar"),
              ),
            ],
          ),
        ) ?? false;

    if (actualizado) {
      _obtenerRolYUsuarios();
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  void _irAProductos() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProductosScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usuarios'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _obtenerRolYUsuarios,
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.red),
            onPressed: _cerrarSesion,
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: _irAProductos, // Navegar a la pantalla de productos
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Buscar usuario...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : usuariosFiltrados.isEmpty
              ? Center(child: Text("No hay usuarios disponibles"))
              : ListView.builder(
                  itemCount: usuariosFiltrados.length,
                  itemBuilder: (context, index) {
                    final usuario = usuariosFiltrados[index];
                    final isDeleting = loadingActions.contains(usuario['_id']);
                    return ListTile(
                      title: Text(usuario['nombre'] ?? 'Sin nombre'),
                      subtitle: Text(usuario['email'] ?? 'Sin email'),
                      trailing: rol == 'admin'
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editarUsuario(index, usuario),
                                ),
                                IconButton(
                                  icon: isDeleting
                                      ? CircularProgressIndicator()
                                      : Icon(Icons.delete, color: Colors.red),
                                  onPressed: isDeleting
                                      ? null
                                      : () => _eliminarUsuario(index, usuario['_id']),
                                ),
                              ],
                            )
                          : null,
                    );
                  },
                ),
      floatingActionButton: rol == 'admin'
          ? FloatingActionButton(
              onPressed: _agregarUsuario,
              backgroundColor: Colors.blue,
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}