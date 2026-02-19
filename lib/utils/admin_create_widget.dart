import 'package:creacionesbaby/core/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminCreationWidget extends StatefulWidget {
  const AdminCreationWidget({super.key});

  @override
  State<AdminCreationWidget> createState() => _AdminCreationWidgetState();
}

class _AdminCreationWidgetState extends State<AdminCreationWidget> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _message;

  Future<void> _createAdmin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _message = 'Por favor ingresa correo y contraseña');
      return;
    }

    if (password.length < 6) {
      setState(
        () => _message = 'La contraseña debe tener al menos 6 caracteres',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      // Using context.read because we are inside a method, not build
      await context.read<AuthProvider>().signUp(email, password);
      setState(
        () => _message =
            'Usuario administrador creado con éxito! Puedes iniciar sesión.',
      );
    } catch (e) {
      setState(() => _message = 'Error: $e. Verifica que no exista ya.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Crear Admin (Temporal)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Correo Admin',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Contraseña Admin',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            if (_message != null)
              Text(
                _message!,
                style: TextStyle(
                  color: _message!.contains('éxito')
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _createAdmin,
                    child: const Text('Crear Usuario'),
                  ),
          ],
        ),
      ),
    );
  }
}
