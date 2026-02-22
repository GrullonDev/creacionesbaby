import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';

class OrderProvider extends ChangeNotifier {
  SupabaseClient get _supabase => Supabase.instance.client;

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  OrderProvider();

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

      final orderIdRaw = orderResponse['id'];
      final orderId = orderIdRaw.toString();

      // 2. Create order items
      final itemsData = cartItems.map((item) {
        return {
          'order_id':
              int.tryParse(orderId) ?? orderId, // Send as int if it's numeric
          'product_id': int.tryParse(item.product.id) ?? item.product.id,
          'product_name': item.product.name,
          'size': item.size,
          'quantity': item.quantity,
          'unit_price': item.product.price,
          'total_price': item.totalPrice,
        };
      }).toList();

      debugPrint(
        '📦 Insertando ${itemsData.length} items para el pedido $orderId',
      );
      await _supabase.from('order_items').insert(itemsData);

      // 3. Update products stock (Customer request)
      debugPrint(
        '🔄 Iniciando actualización de stock para ${cartItems.length} productos',
      );
      for (final item in cartItems) {
        await _decreaseProductStock(
          int.tryParse(item.product.id) ?? item.product.id,
          item.quantity,
        );
      }

      await fetchOrders(); // refresh after creating
      debugPrint('✅ Pedido $orderId procesado con éxito');

      return true;
    } catch (e) {
      _error = 'Error creando pedido: $e';
      debugPrint('❌ Error en createOrder: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _decreaseProductStock(dynamic productId, int quantity) async {
    try {
      debugPrint(
        '📉 Intentando disminuir stock - ID: $productId (tipo: ${productId.runtimeType}), Cantidad: $quantity',
      );

      final response = await _supabase
          .from('products')
          .select('id, stock')
          .eq('id', productId)
          .maybeSingle();

      if (response == null) {
        debugPrint(
          '⚠️ Producto no encontrado para stock: $productId. Intentando con String si era int...',
        );
        // Fallback for type issues if any
        final response2 = await _supabase
            .from('products')
            .select('id, stock')
            .eq('id', productId.toString())
            .maybeSingle();

        if (response2 == null) {
          debugPrint(
            '❌ Producto definitivamente no encontrado en Supabase: $productId',
          );
          return;
        }

        final int currentStock = response2['stock'] as int;
        final int newStock = currentStock - quantity;
        await _supabase
            .from('products')
            .update({'stock': newStock < 0 ? 0 : newStock})
            .eq('id', productId.toString());
        debugPrint(
          '✅ Stock actualizado correctamente (via string conversion) para: $productId',
        );
        return;
      }

      final int currentStock = response['stock'] as int;
      final int newStock = currentStock - quantity;
      final finalStock = newStock < 0 ? 0 : newStock;

      debugPrint('🔄 Stock actual: $currentStock -> Nuevo: $finalStock');

      final updateRes = await _supabase
          .from('products')
          .update({'stock': finalStock})
          .eq('id', productId)
          .select();

      if (updateRes.isEmpty) {
        debugPrint('❌ ERROR: El stock no cambió en la base de datos.');
        throw Exception(
          'No se pudo actualizar el stock. Verifica las políticas RLS de UPDATE en Supabase para la tabla "products".',
        );
      }

      debugPrint('✅ Stock actualizado correctamente para: $productId');
    } catch (e) {
      debugPrint(
        '❌ Error fatal en _decreaseProductStock para producto $productId: $e',
      );
      rethrow;
    }
  }

  Future<bool> updateOrderStatus(OrderModel order, String newStatus) async {
    try {
      final oldStatus = order.status.toLowerCase();
      final statusToUpdate = newStatus.toLowerCase();

      debugPrint(
        '🔄 Actualizando pedido ${order.id}: $oldStatus -> $statusToUpdate',
      );

      if (oldStatus == statusToUpdate) return true;

      // 1. Update status in Supabase
      final updateRes = await _supabase
          .from('orders')
          .update({'status': newStatus})
          .eq('id', int.tryParse(order.id!) ?? order.id!)
          .select();

      if (updateRes.isEmpty) {
        throw Exception(
          'No se pudo actualizar el estado del pedido. Verifica permisos RLS en la tabla "orders".',
        );
      }

      // 2. Stock Logic
      final bool oldHadStockDeducted = oldStatus != 'cancelado';
      final bool newShouldHaveStockDeducted = statusToUpdate != 'cancelado';

      if (!oldHadStockDeducted && newShouldHaveStockDeducted) {
        debugPrint(
          '📉 Detectado cambio de Cancelado a Activo. Disminuyendo stock...',
        );
        for (final item in order.items) {
          await _decreaseProductStock(
            int.tryParse(item.productId) ?? item.productId,
            item.quantity,
          );
        }
      } else if (oldHadStockDeducted && !newShouldHaveStockDeducted) {
        debugPrint(
          '📈 Detectado cambio de Activo a Cancelado. Revirtiendo stock...',
        );
        for (final item in order.items) {
          await _increaseProductStock(
            int.tryParse(item.productId) ?? item.productId,
            item.quantity,
          );
        }
      } else {
        debugPrint(
          'ℹ️ No se requiere ajuste de stock para este cambio de estado',
        );
      }

      // Optimistic update
      final index = _orders.indexWhere((o) => o.id == order.id);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(status: newStatus);
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = 'Error actualizando estado: $e';
      debugPrint('❌ Error en updateOrderStatus: $e');
      return false;
    }
  }

  Future<void> _increaseProductStock(dynamic productId, int quantity) async {
    try {
      debugPrint('📈 Revirtiendo stock - ID: $productId, Cantidad: $quantity');

      final response = await _supabase
          .from('products')
          .select('stock')
          .eq('id', productId)
          .maybeSingle();

      if (response == null) {
        debugPrint('⚠️ Producto no encontrado para revertir stock: $productId');
        return;
      }

      final int currentStock = response['stock'] as int;
      final int newStock = currentStock + quantity;

      final updateRes = await _supabase
          .from('products')
          .update({'stock': newStock})
          .eq('id', productId)
          .select();

      if (updateRes.isEmpty) {
        debugPrint(
          '❌ ERROR: No se pudo revertir el stock en la base de datos.',
        );
      } else {
        debugPrint('✅ Stock revertido correctamente para: $productId');
      }
    } catch (e) {
      debugPrint('❌ Error revertiendo stock para producto $productId: $e');
    }
  }
}
