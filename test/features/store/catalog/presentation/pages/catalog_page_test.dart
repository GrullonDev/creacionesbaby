import 'package:creacionesbaby/core/models/product_model.dart';
import 'package:creacionesbaby/core/providers/cart_provider.dart';
import 'package:creacionesbaby/core/providers/product_provider.dart';
import 'package:creacionesbaby/core/providers/auth_provider.dart';
import 'package:creacionesbaby/core/providers/wishlist_provider.dart';
import 'package:creacionesbaby/core/providers/category_provider.dart';
import 'package:creacionesbaby/core/models/category_model.dart';
import 'package:creacionesbaby/features/store/catalog/presentation/pages/catalog_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
      imagePath: null, // Use null to avoid NetworkImage errors in tests
    ),
  ];

  @override
  String? get error => null;

  @override
  Future<void> loadProducts({String? query}) async {}

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

class FakeCategoryProvider extends ChangeNotifier implements CategoryProvider {
  @override
  List<CategoryModel> get categories => [];
  @override
  bool get isLoading => false;
  @override
  String? get error => null;
  @override
  Future<void> loadCategories() async {}
  @override
  Future<void> addCategory(String name, {String? icon}) async {}
  @override
  Future<void> updateCategory(String id, String name, {String? icon}) async {}
  @override
  Future<void> deleteCategory(String id) async {}
}

class FakeAuthProvider extends ChangeNotifier implements AuthProvider {
  @override
  bool get isLoading => false;
  @override
  String? get error => null;
  @override
  User? get currentUser => null;
  @override
  Future<void> signIn(String email, String password) async {}
  @override
  Future<void> signUp(String email, String password) async {}
  @override
  Future<void> signOut() async {}
}

void main() {
  group('CatalogPage Widget Tests', () {
    late CartProvider cartProvider;
    late FakeProductProvider fakeProductProvider;
    late WishlistProvider wishlistProvider;
    late FakeCategoryProvider fakeCategoryProvider;
    late FakeAuthProvider fakeAuthProvider;

    setUp(() {
      cartProvider = CartProvider();
      fakeProductProvider = FakeProductProvider();
      wishlistProvider = WishlistProvider();
      fakeCategoryProvider = FakeCategoryProvider();
      fakeAuthProvider = FakeAuthProvider();
    });

    Widget createTestWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<ProductProvider>.value(
            value: fakeProductProvider,
          ),
          ChangeNotifierProvider<CartProvider>.value(value: cartProvider),
          ChangeNotifierProvider<WishlistProvider>.value(
            value: wishlistProvider,
          ),
          ChangeNotifierProvider<CategoryProvider>.value(
            value: fakeCategoryProvider,
          ),
          ChangeNotifierProvider<AuthProvider>.value(value: fakeAuthProvider),
        ],
        child: const MaterialApp(home: CatalogPage()),
      );
    }

    testWidgets('Renders CatalogPage and displays products', (
      WidgetTester tester,
    ) async {
      // Use a very wide viewport (>1250) so StoreAppBar uses the wide layout
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify the product name is displayed
      expect(find.text('Babero Rosa'), findsOneWidget);
      expect(find.text('Q99.00'), findsOneWidget);

      // Verify at least one search TextField is present
      expect(find.byType(TextField), findsAtLeastNWidgets(1));
    });

    testWidgets('Search filter works properly', (WidgetTester tester) async {
      // Use a very wide viewport to avoid layout overflow
      tester.view.physicalSize = const Size(3000, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the catalog search bar specifically by its hint text using a predicate
      final catalogSearch = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText == 'Buscar productos...',
      );
      expect(catalogSearch, findsOneWidget);

      // Enter search text that doesn't match any product
      await tester.enterText(catalogSearch, 'Zapatos');
      await tester.pumpAndSettle();

      // Ensure product is no longer shown
      expect(find.text('Babero Rosa'), findsNothing);
      expect(find.text('No se encontraron productos'), findsOneWidget);
    });
  });
}
