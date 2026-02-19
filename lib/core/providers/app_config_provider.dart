import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppConfigProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  String _bannerText = 'Nueva Colección 2026';
  String? _bannerImageUrl;
  bool _isLoading = false;
  String? _error;

  String get bannerText => _bannerText;
  String? get bannerImageUrl => _bannerImageUrl;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadConfig() async {
    // Avoid double loading if possible, but for config updates we might want to refresh
    try {
      _isLoading = true;
      // notifyListeners(); // Avoid unnecessary rebuilds on start

      // Fetch both text and image URL
      final response = await _supabase.from('app_config').select().inFilter(
        'key',
        ['home_banner_text', 'home_banner_image_url'],
      );

      for (var item in response) {
        if (item['key'] == 'home_banner_text' && item['value'] != null) {
          _bannerText = item['value'] as String;
        } else if (item['key'] == 'home_banner_image_url' &&
            item['value'] != null) {
          _bannerImageUrl = item['value'] as String;
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
    try {
      _isLoading = true;
      notifyListeners();

      final String fileName =
          'banner_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // 1. Upload to bucket
      try {
        await _supabase.storage
            .from('banners')
            .uploadBinary(
              fileName,
              imageBytes,
              fileOptions: const FileOptions(upsert: false),
            );
      } catch (uploadError) {
        // If 404, suggest creating bucket
        if (uploadError.toString().contains('Bucket not found')) {
          _error =
              "ERROR: No existe el bucket 'banners'. Ejecuta el script SQL 'setup_banner_system.sql'.";
          throw _error!;
        }
        rethrow;
      }

      // 2. Get Public URL
      final imageUrl = _supabase.storage.from('banners').getPublicUrl(fileName);

      // 3. Save URL to config
      await _supabase.from('app_config').upsert({
        'key': 'home_banner_image_url',
        'value': imageUrl,
      });

      _bannerImageUrl = imageUrl;
      _error = null;
    } catch (e) {
      _error = 'Error actualizando imagen del banner: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
