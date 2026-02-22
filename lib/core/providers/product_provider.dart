import 'package:creacionesbaby/core/models/product_model.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductProvider with ChangeNotifier {
  SupabaseClient get _supabase => Supabase.instance.client;

  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _error;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all products
  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('products')
          .select()
          .order('created_at');

      _products = (response as List)
          .map((json) => ProductModel.fromJson(json))
          .toList();
    } catch (e) {
      _error = 'Error cargando productos: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Upload a single image, returns public URL
  Future<String> _uploadImage(Uint8List imageBytes) async {
    final String fileName =
        'product_${DateTime.now().millisecondsSinceEpoch}_${imageBytes.length}.jpg';

    await _supabase.storage
        .from('products_image')
        .uploadBinary(
          fileName,
          imageBytes,
          fileOptions: const FileOptions(upsert: false),
        );

    return _supabase.storage.from('products_image').getPublicUrl(fileName);
  }

  // Upload multiple images, returns list of URLs
  Future<List<String>> _uploadImages(List<Uint8List> imageBytesList) async {
    final List<String> urls = [];
    for (int i = 0; i < imageBytesList.length; i++) {
      final url = await _uploadImage(imageBytesList[i]);
      urls.add(url);
    }
    return urls;
  }

  // Create Product with multiple images
  Future<void> addProduct(
    ProductModel product, {
    Uint8List? imageBytes, // backward compat
    List<Uint8List>? imageBytesList,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      List<String> imageUrls = [];

      // Upload all images
      if (imageBytesList != null && imageBytesList.isNotEmpty) {
        imageUrls = await _uploadImages(imageBytesList);
      } else if (imageBytes != null) {
        final url = await _uploadImage(imageBytes);
        imageUrls = [url];
      }

      // Build product with all uploaded URLs, then toJson encodes them
      final productWithImages = product.copyWith(
        imageUrls: imageUrls,
        imagePath: imageUrls.isNotEmpty ? imageUrls.first : null,
      );
      final productData = productWithImages.toJson();

      final response = await _supabase
          .from('products')
          .insert(productData)
          .select()
          .single();

      _products.add(ProductModel.fromJson(response));
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
        _error = 'Error agregando producto: $e';
      }
      debugPrint(_error);
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update existing product with multiple images
  Future<void> updateProduct(
    ProductModel product, {
    Uint8List? imageBytes,
    List<Uint8List>? newImageBytesList,
    List<String>? existingImageUrls, // URLs to keep
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Start with existing URLs the user wants to keep
      List<String> finalUrls =
          existingImageUrls ?? List.from(product.imageUrls);

      // Upload new images and append
      if (newImageBytesList != null && newImageBytesList.isNotEmpty) {
        final newUrls = await _uploadImages(newImageBytesList);
        finalUrls.addAll(newUrls);
      } else if (imageBytes != null) {
        final url = await _uploadImage(imageBytes);
        finalUrls = [url];
      }

      // Build product with all URLs, then toJson encodes them
      final updatedProduct = product.copyWith(
        imagePath: finalUrls.isNotEmpty ? finalUrls.first : null,
        imageUrls: finalUrls,
      );
      final productData = updatedProduct.toJson();

      await _supabase.from('products').update(productData).eq('id', product.id);

      // Update local list
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index >= 0) {
        _products[index] = updatedProduct.copyWith(isLocal: false);
      }
      notifyListeners();
    } catch (e) {
      _error = 'Error actualizando producto: $e';
      debugPrint(_error);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete Product
  Future<void> deleteProduct(String id) async {
    try {
      await _supabase.from('products').delete().eq('id', id);
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error eliminando producto: $e');
      rethrow;
    }
  }

  // Toggle Active Status
  Future<void> toggleProductStatus(String id, bool isActive) async {
    try {
      await _supabase
          .from('products')
          .update({'is_active': isActive})
          .eq('id', id);

      final index = _products.indexWhere((p) => p.id == id);
      if (index >= 0) {
        _products[index] = _products[index].copyWith(isActive: isActive);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error actualizando estado: $e');
    }
  }
}
