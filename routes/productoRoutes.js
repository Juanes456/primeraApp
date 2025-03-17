const express = require('express');
const { 
  crearProducto, 
  obtenerProductos, 
  actualizarProducto, 
  eliminarProducto 
} = require('../controllers/productoController'); 
const { verificarToken, verificarAdmin } = require('../middlewares/authMiddleware');

const router = express.Router();

// Rutas
router.post('/', verificarToken, verificarAdmin, crearProducto); // Solo Admin
router.get('/', obtenerProductos); // Todos los usuarios pueden ver productos
router.put('/:id', verificarToken, verificarAdmin, actualizarProducto); // Solo Admin
router.delete('/:id', verificarToken, verificarAdmin, eliminarProducto); // Solo Admin

module.exports = router;
