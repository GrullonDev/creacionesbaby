import 'package:creacionesbaby/core/models/product_model.dart';
import 'package:flutter/foundation.dart';

class ProductProvider with ChangeNotifier {
  final List<ProductModel> _products = [
    // Mock Data to simulate existing products
    ProductModel(
      id: '1',
      name: 'Vestido Rosa Pastel',
      description: 'Hermoso vestido para niña, talla 3-6 Meses.',
      price: 150.0,
      stock: 5,
      isLocal: false, // Simulated "server" data
    ),
    ProductModel(
      id: '2',
      name: 'Conjunto Azul Cielo',
      description: 'Conjunto cómodo de algodón para niño.',
      price: 120.0,
      stock: 8,
      isLocal: false,
    ),
  ];

  List<ProductModel> get products => _products;

  void addProduct(ProductModel product) {
    _products.add(product);
    notifyListeners();
  }
}
