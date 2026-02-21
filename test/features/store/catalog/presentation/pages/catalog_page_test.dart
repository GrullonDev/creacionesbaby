import 'package:creacionesbaby/core/models/product_model.dart';
import 'package:creacionesbaby/core/providers/cart_provider.dart';
import 'package:creacionesbaby/core/providers/product_provider.dart';
import 'package:creacionesbaby/features/store/catalog/presentation/pages/catalog_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';

class FakeProductProvider extends ChangeNotifier implements ProductProvider {
  @override
  bool get isLoading => false;

  @override
  List<ProductModel> get products => [
    ProductModel(
      id: '1',
      name: 'Babero Rosa',
      description: 'Babero de algodón suave',
      price: 99.0,
      stock: 10,
      imagePath: 'https://example.com/image.jpg',
    ),
  ];

  @override
  String? get error => null;

  @override
  Future<void> loadProducts() async {}

  @override
  Future<void> addProduct(
    ProductModel product, {
    Uint8List? imageBytes,
    List<Uint8List>? imageBytesList,
  }) async {}

  @override
  Future<void> updateProduct(
    ProductModel product, {
    Uint8List? imageBytes,
    List<Uint8List>? newImageBytesList,
    List<String>? existingImageUrls,
  }) async {}

  @override
  Future<void> deleteProduct(String id) async {}

  @override
  Future<void> toggleProductStatus(String id, bool isActive) async {}
}

void main() {
  group('CatalogPage Widget Tests', () {
    late CartProvider cartProvider;
    late FakeProductProvider fakeProductProvider;

    setUp(() {
      cartProvider = CartProvider();
      fakeProductProvider = FakeProductProvider();
    });

    Widget createTestWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<ProductProvider>.value(
            value: fakeProductProvider,
          ),
          ChangeNotifierProvider<CartProvider>.value(value: cartProvider),
        ],
        child: const MaterialApp(home: CatalogPage()),
      );
    }

    testWidgets('Renders CatalogPage and displays products', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      // Allow the layout to settle
      await tester.pumpAndSettle();

      // Verify the page title
      expect(find.text('Catálogo'), findsOneWidget);

      // Verify the product name is displayed
      expect(find.text('Babero Rosa'), findsOneWidget);
      expect(find.text('Q99.00'), findsOneWidget);

      // Verify adding to cart via hover overlay might not be immediately visible
      // but we can check standard UI elements.
      expect(find.byType(TextField), findsOneWidget); // Search bar
      expect(
        find.byIcon(Icons.shopping_cart_outlined),
        findsOneWidget,
      ); // Cart icon
    });

    testWidgets('Search filter works properly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter search text that doesn't match
      await tester.enterText(find.byType(TextField), 'Zapatos');
      await tester.pumpAndSettle();

      // Ensure product is no longer shown
      expect(find.text('Babero Rosa'), findsNothing);
      expect(find.text('No se encontraron productos'), findsOneWidget);
    });
  });
}
