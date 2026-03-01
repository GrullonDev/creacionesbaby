import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppConfigProvider extends ChangeNotifier {
  SupabaseClient get _supabase => Supabase.instance.client;

  String _bannerText = 'Nueva Colección 2026';
  String? _bannerImageUrl; // Mantenido por compatibilidad
  List<String> _bannerImageUrls = [];
  String _environment = 'dev'; // default

  // Store Settings
  String _storeName = 'CreacionesBaby';
  String _whatsappNumber = '50200000000';
  String _storeEmail = 'hola@creacionesbaby.com';
  String _seoDescription =
      'La mejor tienda para tu bebé, calidad y ternura en cada puntada.';

  bool _isLoading = false;
  String? _error;

  String get bannerText => _bannerText;
  String? get bannerImageUrl => _bannerImageUrl;
  List<String> get bannerImageUrls => _bannerImageUrls;
  String get environment => _environment;
  String get storeName => _storeName;
  String get whatsappNumber => _whatsappNumber;
  String get storeEmail => _storeEmail;
  String get seoDescription => _seoDescription;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadConfig() async {
    // Avoid double loading if possible, but for config updates we might want to refresh
    try {
      _isLoading = true;
      // notifyListeners(); // Avoid unnecessary rebuilds on start

      // Fetch text, image URLs and environment
      final response = await _supabase
          .from('app_config')
          .select()
          .inFilter('key', [
            'home_banner_text',
            'home_banner_image_url',
            'home_banner_images',
            'environment',
            'store_name',
            'whatsapp_number',
            'store_email',
            'seo_description',
          ]);

      for (var item in response) {
        if (item['key'] == 'home_banner_text' && item['value'] != null) {
          _bannerText = item['value'] as String;
        } else if (item['key'] == 'home_banner_image_url' &&
            item['value'] != null) {
          _bannerImageUrl = item['value'] as String;
        } else if (item['key'] == 'environment' && item['value'] != null) {
          _environment = item['value'] as String;
        } else if (item['key'] == 'home_banner_images' &&
            item['value'] != null) {
          try {
            final decoded = jsonDecode(item['value'] as String);
            if (decoded is List) {
              _bannerImageUrls = decoded.cast<String>();
            }
          } catch (e) {
            debugPrint('Error parsing home_banner_images: $e');
          }
        } else if (item['key'] == 'store_name' && item['value'] != null) {
          _storeName = item['value'] as String;
        } else if (item['key'] == 'whatsapp_number' && item['value'] != null) {
          _whatsappNumber = item['value'] as String;
        } else if (item['key'] == 'store_email' && item['value'] != null) {
          _storeEmail = item['value'] as String;
        } else if (item['key'] == 'seo_description' && item['value'] != null) {
          _seoDescription = item['value'] as String;
        }
      }
    } catch (e) {
      debugPrint('Error loading config: $e');
      // Fallback to default is already set
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateBannerText(String newText) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabase.from('app_config').upsert({
        'key': 'home_banner_text',
        'value': newText,
      });

      _bannerText = newText;
      _error = null;
    } catch (e) {
      _error = 'Error actualizando texto del banner: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateBannerImage(Uint8List imageBytes) async {
    // Legacy method for single image
    return addBannerImage(imageBytes);
  }

  Future<void> addBannerImage(Uint8List imageBytes) async {
    try {
      _isLoading = true;
      notifyListeners();

      final String fileName =
          'banner_${DateTime.now().millisecondsSinceEpoch}.jpg';

      try {
        await _supabase.storage
            .from('banners')
            .uploadBinary(
              fileName,
              imageBytes,
              fileOptions: const FileOptions(upsert: false),
            );
      } catch (uploadError) {
        if (uploadError.toString().contains('Bucket not found')) {
          _error = "ERROR: No existe el bucket 'banners'.";
          throw _error!;
        }
        rethrow;
      }

      final imageUrl = _supabase.storage.from('banners').getPublicUrl(fileName);

      final newUrls = List<String>.from(_bannerImageUrls)..add(imageUrl);

      await _supabase.from('app_config').upsert({
        'key': 'home_banner_images',
        'value': jsonEncode(newUrls),
      });

      // Update old field to maintain single-image backwards compatibility initially
      await _supabase.from('app_config').upsert({
        'key': 'home_banner_image_url',
        'value': imageUrl,
      });

      _bannerImageUrl = imageUrl;
      _bannerImageUrls = newUrls;
      _error = null;
    } catch (e) {
      _error = 'Error agregando imagen del banner: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeBannerImage(String imageUrl) async {
    try {
      _isLoading = true;
      notifyListeners();

      try {
        final uri = Uri.parse(imageUrl);
        final fileName = uri.pathSegments.last;
        await _supabase.storage.from('banners').remove([fileName]);
      } catch (e) {
        debugPrint('Error eliminando archivo de storage: $e');
      }

      final newUrls = List<String>.from(_bannerImageUrls)..remove(imageUrl);

      await _supabase.from('app_config').upsert({
        'key': 'home_banner_images',
        'value': jsonEncode(newUrls),
      });

      // Update legacy url reference
      if (_bannerImageUrl == imageUrl) {
        final newOldUrl = newUrls.isNotEmpty ? newUrls.last : null;
        if (newOldUrl != null) {
          await _supabase.from('app_config').upsert({
            'key': 'home_banner_image_url',
            'value': newOldUrl,
          });
        } else {
          await _supabase
              .from('app_config')
              .delete()
              .eq('key', 'home_banner_image_url');
        }
        _bannerImageUrl = newOldUrl;
      }

      _bannerImageUrls = newUrls;
      _error = null;
    } catch (e) {
      _error = 'Error eliminando imagen del banner: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStoreSettings({
    String? name,
    String? whatsapp,
    String? email,
    String? seo,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final List<Map<String, dynamic>> batch = [];
      if (name != null) batch.add({'key': 'store_name', 'value': name});
      if (whatsapp != null)
        batch.add({'key': 'whatsapp_number', 'value': whatsapp});
      if (email != null) batch.add({'key': 'store_email', 'value': email});
      if (seo != null) batch.add({'key': 'seo_description', 'value': seo});

      if (batch.isNotEmpty) {
        await _supabase.from('app_config').upsert(batch);
        if (name != null) _storeName = name;
        if (whatsapp != null) _whatsappNumber = whatsapp;
        if (email != null) _storeEmail = email;
        if (seo != null) _seoDescription = seo;
      }
      _error = null;
    } catch (e) {
      _error = 'Error actualizando configuración: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
