import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ContactProvider with ChangeNotifier {
  bool _isSubmitting = false;
  String? _error;
  bool _success = false;

  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  bool get success => _success;

  Future<void> submitContactForm({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    _isSubmitting = true;
    _error = null;
    _success = false;
    notifyListeners();

    try {
      await Supabase.instance.client.from('contact_messages').insert({
        'name': name,
        'email': email,
        'subject': subject,
        'message': message,
      });

      _success = true;
    } catch (e) {
      _error = 'Error enviando mensaje: $e';
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> subscribeNewsletter(String email) async {
    _isSubmitting = true;
    _error = null;
    _success = false;
    notifyListeners();

    try {
      await Supabase.instance.client.from('newsletter_subscriptions').insert({
        'email': email,
      });
      _success = true;
    } catch (e) {
      // Handle unique constraint if user already subscribed
      if (e.toString().contains('unique_newsletter_email')) {
        _error = 'Ya estás suscrito con este correo';
      } else {
        _error = 'Error al suscribirse: $e';
      }
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void reset() {
    _success = false;
    _error = null;
    notifyListeners();
  }
}
