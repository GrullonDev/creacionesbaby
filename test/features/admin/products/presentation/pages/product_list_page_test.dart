import 'package:creacionesbaby/core/models/product_model.dart';
import 'package:creacionesbaby/core/providers/product_provider.dart';
import 'package:creacionesbaby/features/admin/products/presentation/pages/product_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';

class FakeAdminProductProvider extends ChangeNotifier
    implements ProductProvider {
  bool _isLoading = false;

  @override
  bool get isLoading => _isLoading;

  @override
  List<ProductModel> get products => [
    ProductModel(
      id: '1',
      name: 'Producto Activo',
      description: 'Desc',
      price: 100.0,
      stock: 10,
    ),
    ProductModel(
      id: '2',
      name: 'Producto Inactivo',
      description: 'Desc',
      price: 50.0,
      stock: 0,
    ),
  ];

  @override
  String? get error => null;

  @override
  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 50));
    _isLoading = false;
    notifyListeners();
  }

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

class EmptyFakeAdminProductProvider extends FakeAdminProductProvider {
  @override
  List<ProductModel> get products => [];

  @override
  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();
    // No delay, instant completion
    _isLoading = false;
    notifyListeners();
  }
}

void main() {
  group('Admin ProductListPage Widget Tests', () {
    late FakeAdminProductProvider productProvider;

    setUp(() {
      productProvider = FakeAdminProductProvider();
    });

    Widget createTestWidget() {
      return ChangeNotifierProvider<ProductProvider>.value(
        value: productProvider,
        child: const MaterialApp(home: ProductListPage()),
      );
    }

    testWidgets('Renders ProductListPage and verifies filters', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify page title
      expect(find.text('Gestión de Productos'), findsOneWidget);

      // Initially 'Todos' is selected, both products should be visible
      expect(find.text('Producto Activo'), findsOneWidget);
      expect(find.text('Producto Inactivo'), findsOneWidget);

      // Tap 'Activos (Stock > 0)' filter
      await tester.tap(find.text('Activos (Stock > 0)'));
      await tester.pumpAndSettle();

      // Only active product should be visible
      expect(find.text('Producto Activo'), findsOneWidget);
      expect(find.text('Producto Inactivo'), findsNothing);

      // Tap 'Inactivos (Sin Stock)' filter
      await tester.tap(find.text('Inactivos (Sin Stock)'));
      await tester.pumpAndSettle();

      // Only inactive product should be visible
      expect(find.text('Producto Activo'), findsNothing);
      expect(find.text('Producto Inactivo'), findsOneWidget);
    });

    testWidgets('Shows empty state if no products', (
      WidgetTester tester,
    ) async {
      final emptyProvider = EmptyFakeAdminProductProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<ProductProvider>.value(
          value: emptyProvider,
          child: const MaterialApp(home: ProductListPage()),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('No hay productos registrados.'), findsOneWidget);
    });
  });
}
