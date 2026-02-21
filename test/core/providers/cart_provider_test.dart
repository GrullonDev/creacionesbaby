import 'package:creacionesbaby/core/models/product_model.dart';
import 'package:creacionesbaby/core/providers/cart_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CartProvider Tests', () {
    late CartProvider cartProvider;
    late ProductModel testProduct1;
    late ProductModel testProduct2;

    setUp(() {
      cartProvider = CartProvider();
      testProduct1 = ProductModel(
        id: '1',
        name: 'Test Product 1',
        description: 'Description 1',
        price: 100.0,
        stock: 10,
      );
      testProduct2 = ProductModel(
        id: '2',
        name: 'Test Product 2',
        description: 'Description 2',
        price: 200.0,
        stock: 5,
      );
    });

    test('Initial cart is empty', () {
      expect(cartProvider.items, isEmpty);
      expect(cartProvider.itemCount, 0);
      expect(cartProvider.totalAmount, 0.0);
    });

    test('Add item adds new item to cart', () {
      cartProvider.addItem(testProduct1, quantity: 2);

      expect(cartProvider.items.length, 1);
      expect(cartProvider.itemCount, 2);
      expect(cartProvider.totalAmount, 200.0);
    });

    test('Add same item updates quantity', () {
      cartProvider.addItem(testProduct1, quantity: 1);
      cartProvider.addItem(testProduct1, quantity: 2);

      expect(cartProvider.items.length, 1);
      expect(cartProvider.itemCount, 3);
      expect(cartProvider.totalAmount, 300.0);
    });

    test('Update quantity changes quantity and total', () {
      cartProvider.addItem(testProduct1, quantity: 2);
      final String cartItemId = cartProvider.items.first.id;

      cartProvider.updateQuantity(cartItemId, 5);

      expect(cartProvider.items.length, 1);
      expect(cartProvider.itemCount, 5);
      expect(cartProvider.totalAmount, 500.0);
    });

    test('Update quantity to 0 removes item', () {
      cartProvider.addItem(testProduct1, quantity: 2);
      final String cartItemId = cartProvider.items.first.id;

      cartProvider.updateQuantity(cartItemId, 0);

      expect(cartProvider.items, isEmpty);
      expect(cartProvider.itemCount, 0);
    });

    test('Remove item removes it from cart', () {
      cartProvider.addItem(testProduct1, quantity: 1);
      cartProvider.addItem(testProduct2, quantity: 1);

      final String test1CartItemId = cartProvider.items
          .firstWhere((i) => i.product.id == '1')
          .id;

      cartProvider.removeItem(test1CartItemId);

      expect(cartProvider.items.length, 1);
      expect(cartProvider.items.first.product.id, '2');
      expect(cartProvider.itemCount, 1);
      expect(cartProvider.totalAmount, 200.0);
    });

    test('Clear cart empties all items', () {
      cartProvider.addItem(testProduct1, quantity: 1);
      cartProvider.addItem(testProduct2, quantity: 2);

      cartProvider.clearCart();

      expect(cartProvider.items, isEmpty);
      expect(cartProvider.itemCount, 0);
      expect(cartProvider.totalAmount, 0.0);
    });
  });
}
