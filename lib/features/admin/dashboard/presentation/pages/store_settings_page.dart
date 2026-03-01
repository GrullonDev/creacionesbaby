import 'package:creacionesbaby/core/providers/app_config_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StoreSettingsPage extends StatefulWidget {
  const StoreSettingsPage({super.key});

  @override
  State<StoreSettingsPage> createState() => _StoreSettingsPageState();
}

class _StoreSettingsPageState extends State<StoreSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _whatsappController;
  late TextEditingController _emailController;
  late TextEditingController _seoController;

  @override
  void initState() {
    super.initState();
    final config = context.read<AppConfigProvider>();
    _nameController = TextEditingController(text: config.storeName);
    _whatsappController = TextEditingController(text: config.whatsappNumber);
    _emailController = TextEditingController(text: config.storeEmail);
    _seoController = TextEditingController(text: config.seoDescription);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _seoController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      try {
        await context.read<AppConfigProvider>().updateStoreSettings(
          name: _nameController.text.trim(),
          whatsapp: _whatsappController.text.trim(),
          email: _emailController.text.trim(),
          seo: _seoController.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Configuración guardada exitosamente'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AppConfigProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración de la Tienda')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('Información General'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la Tienda',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.store),
                ),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _seoController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción SEO / Meta-descripción',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Contacto y Ventas'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _whatsappController,
                decoration: const InputDecoration(
                  labelText: 'Número de WhatsApp (con código de país)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                  hintText: 'Ej: 50200000000',
                ),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico de Contacto',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'GUARDAR CAMBIOS',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey,
      ),
    );
  }
}
