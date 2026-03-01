import 'package:creacionesbaby/core/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryProvider extends ChangeNotifier {
  SupabaseClient get _supabase => Supabase.instance.client;

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories() async {
    try {
      _isLoading = true;
      _error = null;
      // notifyListeners();

      final response = await _supabase
          .from('categories')
          .select()
          .order('name', ascending: true);

      _categories = (response as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } catch (e) {
      _error = 'Error cargando categorías: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCategory(String name, {String? icon}) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabase.from('categories').insert({'name': name, 'icon': icon});

      await loadCategories();
    } catch (e) {
      _error = 'Error agregando categoría: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCategory(String id, String name, {String? icon}) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabase
          .from('categories')
          .update({'name': name, 'icon': icon})
          .eq('id', id);

      await loadCategories();
    } catch (e) {
      _error = 'Error actualizando categoría: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabase.from('categories').delete().eq('id', id);

      _categories.removeWhere((c) => c.id == id);
    } catch (e) {
      _error = 'Error eliminando categoría: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
