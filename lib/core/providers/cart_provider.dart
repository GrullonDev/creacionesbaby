import 'package:flutter/material.dart';
import 'package:creacionesbaby/core/models/product_model.dart';
import 'package:creacionesbaby/core/models/cart_item_model.dart';

class CartProvider with ChangeNotifier {
  final List<CartItemModel> _items = [];

  // Getters
  List<CartItemModel> get items => _items;

  // Total quantity of items in cart
  int get itemCount {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  // Total price amount
  double get totalAmount {
    return _items.fold(
      0.0,
      (sum, item) => sum + item.product.price * item.quantity,
    );
  }

  // Add Item
  void addItem(
    ProductModel product, {
    int quantity = 1,
    String size = 'Única',
  }) {
    // Check if the same product with the same size already exists in the cart
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id && item.size == size,
    );

    if (existingIndex >= 0) {
      // If exists, update quantity
      final existingItem = _items[existingIndex];
      _items[existingIndex] = CartItemModel(
        id: existingItem.id, // Keep original ID
        product: existingItem.product,
        size: existingItem.size,
        quantity: existingItem.quantity + quantity,
        addedAt: existingItem.addedAt,
      );
    } else {
      // If new, add to list
      _items.add(
        CartItemModel(product: product, quantity: quantity, size: size),
      );
    }
    notifyListeners();
  }

  // Remove Item
  void removeItem(String cartItemId) {
    _items.removeWhere(
      (item) => item.id == cartItemId,
    ); // Assuming ID is unique per cart item entry
    notifyListeners();
  }

  // Update Quantity
  void updateQuantity(String cartItemId, int newQuantity) {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index >= 0) {
      if (newQuantity <= 0) {
        _items.removeAt(index);
      } else {
        final existingItem = _items[index];
        _items[index] = CartItemModel(
          id: existingItem.id,
          product: existingItem.product,
          size: existingItem.size,
          quantity: newQuantity,
          addedAt: existingItem.addedAt,
        );
      }
      notifyListeners();
    }
  }

  // Clear Cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
