import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider with ChangeNotifier {
  SupabaseClient get _supabase => Supabase.instance.client;
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // Current user getter
  User? get currentUser => _supabase.auth.currentUser;

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);

      // Optionally check for admin role here if you have a roles table or metadata
      // For now, any valid login is considered an admin per requirements.
    } catch (e) {
      if (e.toString().contains('Invalid login credentials')) {
        _error = 'Correo o contraseña incorrectos.';
      } else {
        _error = 'Error al iniciar sesión: ${e.toString()}';
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabase.auth.signUp(email: email, password: password);
    } catch (e) {
      _error = 'Error al registrar usuario: ${e.toString()}';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    notifyListeners();
  }
}
