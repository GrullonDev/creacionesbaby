import 'package:creacionesbaby/core/models/product_model.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _error;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize and load products
  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('products')
          .select()
          .order('created_at');

      final List<dynamic> data = response;
      _products = data
          .map(
            (json) => ProductModel(
              id: json['id'].toString(),
              name: json['name'] ?? '',
              description: json['description'] ?? '',
              price: (json['price'] as num).toDouble(),
              stock: (json['stock'] as num).toInt(),
              imagePath: json['image_url'],
              isLocal: false,
            ),
          )
          .toList();
    } catch (e) {
      _error = 'Error loading products: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create Product
  Future<void> addProduct(
    ProductModel product, {
    Uint8List? imageBytes,
    String? imagePath,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      String? imageUrl;

      // Upload image if provided
      if (imageBytes != null) {
        final String fileName =
            'product_${DateTime.now().millisecondsSinceEpoch}.jpg';

        await _supabase.storage
            .from('products_image')
            .uploadBinary(
              fileName,
              imageBytes,
              fileOptions: const FileOptions(upsert: false),
            );

        imageUrl = _supabase.storage
            .from('products_image')
            .getPublicUrl(fileName);
      } else if (imagePath != null && !kIsWeb) {
        // Fallback for file path on non-web if bytes aren't passed, though bytes are preferred
        // Not implementing File based upload to keep it clean for web/mobile unified approach.
        // Ensuring UI always passes bytes is better.
      }

      final Map<String, dynamic> productData = {
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'stock': product.stock,
        'image_url': imageUrl,
      };

      final response = await _supabase
          .from('products')
          .insert(productData)
          .select()
          .single();

      final newProduct = ProductModel(
        id: response['id'].toString(),
        name: response['name'] ?? '',
        description: response['description'] ?? '',
        price: (response['price'] as num).toDouble(),
        stock: (response['stock'] as num).toInt(),
        imagePath: response['image_url'], // This will now be the Supabase URL
        isLocal: false,
      );

      _products.add(newProduct);
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      if (e.toString().contains('Bucket not found')) {
        _error =
            "ERROR: No existe el bucket 'products_image' en Supabase. Ve a Storage > Create Bucket > 'products_image' (Publico).";
      } else if (e.toString().contains('statusCode: 403') ||
          e.toString().contains('Unauthorized')) {
        _error =
            "ERROR DE PERMISOS (RLS): No tienes permiso para subir imágenes. Verifica las 'Policies' en Supabase del bucket 'products_image' para permitir INSERT a 'authenticated'.";
      } else {
        _error = 'Error adding product: $e';
      }
      debugPrint(_error);
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete Product (Soft Delete or Hard Delete)
  Future<void> deleteProduct(String id) async {
    try {
      await _supabase.from('products').delete().eq('id', id);
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting product: $e');
      rethrow;
    }
  }

  // Toggle Active Status (Update Stock to 0 or specific 'active' flag if db has it)
  Future<void> toggleProductStatus(String id, bool isActive) async {
    // Implementation depends on DB schema.
    // If 'active' column exists:
    // await _supabase.from('products').update({'active': isActive}).eq('id', id);
  }
}
