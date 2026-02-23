import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';

class OrderProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;
  String? _lastCreatedOrderId;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get lastCreatedOrderId => _lastCreatedOrderId;

  OrderProvider() {
    fetchOrders(); // Initial fetch
  }

  Future<void> fetchOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('orders')
          .select('*, order_items(*)')
          .order('created_at', ascending: false);

      _orders = (response as List<dynamic>)
          .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = 'Error loading orders: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createOrder({
    required String customerEmail,
    required String customerName,
    required String customerPhone,
    required String shippingAddress,
    required double totalAmount,
    required List<CartItemModel> cartItems,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Create order
      final orderData = {
        'customer_email': customerEmail,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'shipping_address': shippingAddress,
        'total_amount': totalAmount,
        'status': 'pendiente',
      };

      final orderResponse = await _supabase
          .from('orders')
          .insert(orderData)
          .select()
          .single();

      final orderId = orderResponse['id'] as String;
      _lastCreatedOrderId = orderId;

      // 2. Create order items
      final itemsData = cartItems.map((item) {
        return {
          'order_id': orderId,
          'product_id': int.tryParse(item.product.id) ?? item.product.id,
          'product_name': item.product.name,
          'size': item.size,
          'quantity': item.quantity,
          'unit_price': item.product.price,
          'total_price': item.totalPrice,
        };
      }).toList();

      await _supabase.from('order_items').insert(itemsData);

      // 3. Update products stock
      for (final item in cartItems) {
        final currentStock = item.product.stock;
        final newStock = currentStock - item.quantity;

        await _supabase
            .from('products')
            .update({'stock': newStock < 0 ? 0 : newStock})
            .eq('id', int.tryParse(item.product.id) ?? item.product.id);
      }

      await fetchOrders(); // refresh after creating

      return true;
    } catch (e) {
      _error = 'Error creating order: $e';
      debugPrint(_error);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _supabase
          .from('orders')
          .update({'status': newStatus})
          .eq('id', orderId);

      // Optimistic update
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(status: newStatus);
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = 'Error updating status: $e';
      debugPrint(_error);
      return false;
    }
  }
}
