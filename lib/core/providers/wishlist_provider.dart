import 'package:creacionesbaby/core/models/product_model.dart';
import 'package:flutter/material.dart';

class WishlistProvider with ChangeNotifier {
  final List<ProductModel> _items = [];

  List<ProductModel> get items => List.unmodifiable(_items);

  bool isFavorite(String productId) {
    return _items.any((item) => item.id == productId);
  }

  void toggleFavorite(ProductModel product) {
    final index = _items.indexWhere((item) => item.id == product.id);
    if (index >= 0) {
      _items.removeAt(index);
    } else {
      _items.add(product);
    }
    notifyListeners();
  }

  void clearWishlist() {
    _items.clear();
    notifyListeners();
  }
}
