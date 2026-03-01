import 'package:creacionesbaby/core/models/coupon_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:creacionesbaby/core/models/product_model.dart';
import 'package:creacionesbaby/core/models/cart_item_model.dart';

class CartProvider with ChangeNotifier {
  final List<CartItemModel> _items = [];
  CouponModel? _appliedCoupon;
  bool _isValidatingCoupon = false;
  String? _couponError;

  // Getters
  List<CartItemModel> get items => _items;
  CouponModel? get appliedCoupon => _appliedCoupon;
  bool get isValidatingCoupon => _isValidatingCoupon;
  String? get couponError => _couponError;

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

  double get discountAmount {
    if (_appliedCoupon == null) return 0.0;
    return _appliedCoupon!.calculateDiscount(totalAmount);
  }

  double get totalAfterDiscount {
    return totalAmount - discountAmount;
  }

  // Add Item
  bool addItem(
    ProductModel product, {
    int quantity = 1,
    String size = 'Única',
  }) {
    // Check if the same product with the same size already exists in the cart
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id && item.size == size,
    );

    if (existingIndex >= 0) {
      // If exists, check stock against total new quantity
      final existingItem = _items[existingIndex];
      if (existingItem.quantity + quantity > product.stock) {
        return false;
      }
      _items[existingIndex] = CartItemModel(
        id: existingItem.id, // Keep original ID
        product: existingItem.product,
        size: existingItem.size,
        quantity: existingItem.quantity + quantity,
        addedAt: existingItem.addedAt,
      );
    } else {
      // If new, check stock against new quantity
      if (quantity > product.stock) {
        return false;
      }
      // If new, add to list
      _items.add(
        CartItemModel(product: product, quantity: quantity, size: size),
      );
    }
    notifyListeners();
    return true;
  }

  // Remove Item
  void removeItem(String cartItemId) {
    _items.removeWhere(
      (item) => item.id == cartItemId,
    ); // Assuming ID is unique per cart item entry
    notifyListeners();
  }

  // Update Quantity
  bool updateQuantity(String cartItemId, int newQuantity) {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index >= 0) {
      if (newQuantity <= 0) {
        _items.removeAt(index);
      } else {
        final existingItem = _items[index];
        if (newQuantity > existingItem.product.stock) {
          return false;
        }
        _items[index] = CartItemModel(
          id: existingItem.id,
          product: existingItem.product,
          size: existingItem.size,
          quantity: newQuantity,
          addedAt: existingItem.addedAt,
        );
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  // Clear Cart
  void clearCart() {
    _items.clear();
    _appliedCoupon = null;
    notifyListeners();
  }

  // Coupon Logic
  Future<bool> validateAndApplyCoupon(String code) async {
    _isValidatingCoupon = true;
    _couponError = null;
    notifyListeners();

    try {
      final response = await Supabase.instance.client
          .from('coupons')
          .select()
          .eq('code', code.toUpperCase())
          .maybeSingle();

      if (response == null) {
        _couponError = 'Cupón no válido';
        _appliedCoupon = null;
        return false;
      }

      final coupon = CouponModel.fromJson(response);

      if (!coupon.isValid) {
        _couponError = 'El cupón ha expirado o no está activo';
        _appliedCoupon = null;
        return false;
      }

      _appliedCoupon = coupon;
      _couponError = null;
      notifyListeners();
      return true;
    } catch (e) {
      _couponError = 'Error validando cupón: $e';
      debugPrint(_couponError);
      return false;
    } finally {
      _isValidatingCoupon = false;
      notifyListeners();
    }
  }

  void removeCoupon() {
    _appliedCoupon = null;
    _couponError = null;
    notifyListeners();
  }
}
