import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  _ProductosScreenState createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final ApiService apiService = ApiService();
  List<Map<String, dynamic>> productos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _obtenerProductos();
  }

  Future<void> _obtenerProductos() async {
    setState(() => isLoading = true);
    try {
      final data = await apiService.getProducts();
      if (mounted) {
        setState(() {
          productos = data;
          isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Error en _obtenerProductos: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _agregarProducto() async {
    TextEditingController nombreController = TextEditingController();
    TextEditingController descripcionController = TextEditingController();
    TextEditingController precioController = TextEditingController();

    bool agregado =
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text("Agregar Producto"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nombreController,
                      decoration: InputDecoration(labelText: "Nombre"),
                    ),
                    TextField(
                      controller: descripcionController,
                      decoration: InputDecoration(labelText: "Descripción"),
                    ),
                    TextField(
                      controller: precioController,
                      decoration: InputDecoration(labelText: "Precio"),
                      keyboardType: TextInputType.number,
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
                          descripcionController.text.isNotEmpty &&
                          precioController.text.isNotEmpty) {
                        final nuevoProducto = await apiService.createProduct(
                          nombreController.text,
                          descripcionController.text,
                          int.parse(precioController.text).toDouble(),
                        );

                        if (nuevoProducto != null && mounted) {
                          setState(() => productos.add(nuevoProducto));
                          _mostrarMensaje("Producto agregado correctamente");
                          Navigator.pop(context, true);
                        } else {
                          _mostrarMensaje("Error al agregar producto");
                        }
                      }
                    },
                    child: Text("Agregar"),
                  ),
                ],
              ),
        ) ??
        false;

    if (agregado) {
      _obtenerProductos();
    }
  }

  Future<void> _editarProducto(Map<String, dynamic> producto) async {
    TextEditingController nombreController = TextEditingController(
      text: producto['nombre'],
    );
    TextEditingController descripcionController = TextEditingController(
      text: producto['descripcion'],
    );
    TextEditingController precioController = TextEditingController(
      text: producto['precio'].toString(),
    );

    bool actualizado =
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text("Editar Producto"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nombreController,
                      decoration: InputDecoration(labelText: "Nombre"),
                    ),
                    TextField(
                      controller: descripcionController,
                      decoration: InputDecoration(labelText: "Descripción"),
                    ),
                    TextField(
                      controller: precioController,
                      decoration: InputDecoration(labelText: "Precio"),
                      keyboardType: TextInputType.number,
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
                          descripcionController.text.isNotEmpty &&
                          precioController.text.isNotEmpty) {
                        final actualizado = await apiService.updateProduct(
                          producto['_id'],
                          nombreController.text,
                          descripcionController.text,
                          int.parse(precioController.text).toDouble(),
                        );

                        if (actualizado && mounted) {
                          setState(() {
                            producto['nombre'] = nombreController.text;
                            producto['descripcion'] =
                                descripcionController.text;
                            producto['precio'] = int.parse(
                              precioController.text,
                            );
                          });
                          _mostrarMensaje("Producto actualizado correctamente");
                          Navigator.pop(context, true);
                        } else {
                          _mostrarMensaje("Error al actualizar producto");
                        }
                      }
                    },
                    child: Text("Actualizar"),
                  ),
                ],
              ),
        ) ??
        false;

    if (actualizado) {
      _obtenerProductos();
    }
  }

  Future<void> _eliminarProducto(String id) async {
    bool eliminado =
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text("Eliminar Producto"),
                content: Text(
                  "¿Estás seguro de que deseas eliminar este producto?",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text("Cancelar"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final eliminado = await apiService.deleteProduct(id);
                      if (eliminado && mounted) {
                        setState(() {
                          productos.removeWhere(
                            (producto) => producto['_id'] == id,
                          );
                        });
                        _mostrarMensaje("Producto eliminado correctamente");
                        Navigator.pop(context, true);
                      } else {
                        _mostrarMensaje("Error al eliminar producto");
                      }
                    },
                    child: Text("Eliminar"),
                  ),
                ],
              ),
        ) ??
        false;

    if (eliminado) {
      _obtenerProductos();
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Productos'),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _obtenerProductos),
        ],
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : productos.isEmpty
              ? Center(child: Text("No hay productos disponibles"))
              : ListView.builder(
                itemCount: productos.length,
                itemBuilder: (context, index) {
                  final producto = productos[index];
                  return ListTile(
                    title: Text(producto['nombre'] ?? 'Sin nombre'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(producto['descripcion'] ?? 'Sin descripción'),
                        Text("\$${producto['precio']?.toInt() ?? 0}"),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editarProducto(producto),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _eliminarProducto(producto['_id']),
                        ),
                      ],
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarProducto,
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),
    );
  }
}
