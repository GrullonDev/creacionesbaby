import 'dart:typed_data';

import 'package:creacionesbaby/core/providers/app_config_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class BannerConfigPage extends StatefulWidget {
  const BannerConfigPage({super.key});

  @override
  State<BannerConfigPage> createState() => _BannerConfigPageState();
}

class _BannerConfigPageState extends State<BannerConfigPage> {
  final _bannerController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // For text validation
  final ImagePicker _picker = ImagePicker();
  Uint8List? _newImageBytes;

  @override
  void initState() {
    super.initState();
    _loadCurrentConfig();
  }

  void _loadCurrentConfig() {
    final provider = context.read<AppConfigProvider>();
    _bannerController.text = provider.bannerText;
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      // Force JPEG and limit size for web compatibility
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _newImageBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _saveConfig() async {
    final provider = context.read<AppConfigProvider>();
    String message = '';
    bool success = true;

    // 1. Update Text
    if (_formKey.currentState!.validate()) {
      try {
        if (_bannerController.text.trim() != provider.bannerText) {
          await provider.updateBannerText(_bannerController.text.trim());
          message += 'Texto actualizado. ';
        }
      } catch (e) {
        success = false;
        message += 'Error texto: $e. ';
      }
    }

    // 2. Update Image if selected
    if (_newImageBytes != null) {
      try {
        await provider.updateBannerImage(_newImageBytes!);
        message += 'Imagen actualizada. ';
        setState(() {
          _newImageBytes = null; // Clear selection after upload
        });
      } catch (e) {
        success = false;
        message += 'Error imagen: $e. ';
      }
    }

    if (mounted && message.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    } else if (mounted && message.isEmpty && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay cambios para guardar.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurar Banner Web')),
      body: Consumer<AppConfigProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Vista Previa del Banner',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Image Preview Area
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                    image: _newImageBytes != null
                        ? DecorationImage(
                            image: MemoryImage(_newImageBytes!),
                            fit: BoxFit.cover,
                          )
                        : (provider.bannerImageUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(provider.bannerImageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null),
                  ),
                  child:
                      (_newImageBytes == null &&
                          provider.bannerImageUrl == null)
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                              Text(
                                'Sin imagen configurada',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : null,
                ),

                const SizedBox(height: 16),

                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('SELECCIONAR IMAGEN'),
                ),

                const SizedBox(height: 32),

                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _bannerController,
                    decoration: const InputDecoration(
                      labelText: 'Texto del Banner (Opcional si hay imagen)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.edit),
                      helperText:
                          'Este texto se mostrará sobre la imagen o si no hay imagen.',
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: provider.isLoading ? null : _saveConfig,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'GUARDAR CAMBIOS',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
