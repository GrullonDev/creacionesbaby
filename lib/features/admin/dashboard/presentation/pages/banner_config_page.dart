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

  Future<void> _pickAndUploadImage(AppConfigProvider provider) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        await provider.addBannerImage(bytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Imagen agregada al carrusel.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeImage(AppConfigProvider provider, String url) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar imagen'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar esta imagen del carrusel?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      try {
        await provider.removeBannerImage(url);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Imagen eliminada.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _saveTextConfig() async {
    final provider = context.read<AppConfigProvider>();

    if (_formKey.currentState!.validate()) {
      try {
        if (_bannerController.text.trim() != provider.bannerText) {
          await provider.updateBannerText(_bannerController.text.trim());
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Texto actualizado correctamente.'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No hay cambios en el texto para guardar.'),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar texto: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
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

          final images = provider.bannerImageUrls;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Imágenes del Carrusel',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                if (images.isEmpty)
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                          Text(
                            'Sin imágenes configuradas',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: images.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final url = images[index];
                      return Stack(
                        children: [
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                              image: DecorationImage(
                                image: NetworkImage(url),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.red.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                              onPressed: () => _removeImage(provider, url),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                const SizedBox(height: 16),

                OutlinedButton.icon(
                  onPressed: () => _pickAndUploadImage(provider),
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('AGREGAR IMAGEN AL CARRUSEL'),
                ),

                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),

                const Text(
                  'Texto Principal',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _bannerController,
                    decoration: const InputDecoration(
                      labelText: 'Texto del Banner (Opcional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.edit),
                      helperText:
                          'Este texto se mostrará sobre el carrusel principal.',
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: provider.isLoading ? null : _saveTextConfig,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'GUARDAR TEXTO',
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
