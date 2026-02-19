import 'package:creacionesbaby/core/models/product_model.dart';
import 'package:creacionesbaby/core/providers/product_provider.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddEditProductPage extends StatelessWidget {
  final Map<String, dynamic>? product; // If null, it's adding a new product

  const AddEditProductPage({super.key, this.product});

  @override
  Widget build(BuildContext context) {
    // Determine if editing based on passed product map
    final isEditing = product != null;
    final productModel = isEditing
        ? ProductModel(
            id: product!['id']?.toString() ?? '',
            name: product!['name'] ?? '',
            description: product!['description'] ?? '',
            price: (product!['price'] as num?)?.toDouble() ?? 0.0,
            stock: (product!['stock'] as num?)?.toInt() ?? 0,
            imagePath: product!['imagePath'],
            isLocal: false,
          )
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Producto' : 'Nuevo Producto'),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              ProductForm(
                initialProduct: productModel,
                onSave: (newProduct, imageBytes) async {
                  try {
                    if (isEditing) {
                      // TODO: Implement update in provider
                      // for now, we just add as new or show error
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Edición no implementada en backend aún.',
                          ),
                        ),
                      );
                    } else {
                      await provider.addProduct(
                        newProduct,
                        imageBytes: imageBytes,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Producto guardado exitosamente'),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
              ),
              if (provider.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }
}

class ProductForm extends StatefulWidget {
  final ProductModel? initialProduct;
  final Function(ProductModel product, Uint8List? imageBytes) onSave;

  const ProductForm({super.key, this.initialProduct, required this.onSave});

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;

  bool _isActive = true;
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final p = widget.initialProduct;
    _nameController = TextEditingController(text: p?.name ?? '');
    _descController = TextEditingController(text: p?.description ?? '');
    _priceController = TextEditingController(
      text: p != null ? p.price.toString() : '',
    );
    _stockController = TextEditingController(
      text: p != null ? p.stock.toString() : '',
    );
    _isActive = (p?.stock ?? 0) > 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        setState(() {
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo acceder a la cámara')),
        );
      }
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final product = ProductModel(
        id: widget.initialProduct?.id ?? DateTime.now().toString(),
        name: _nameController.text,
        description: _descController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        stock: int.tryParse(_stockController.text) ?? 0,
        imagePath: widget.initialProduct?.imagePath, // Preserve old URL
        isLocal: false,
      );
      widget.onSave(product, _imageBytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildImageSection(),
          const SizedBox(height: 24),
          _buildBasicInfo(),
          const SizedBox(height: 24),
          _buildPricingAndStock(),
          const SizedBox(height: 16),
          _buildStatusCard(),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.save),
            label: const Text('GUARDAR PRODUCTO'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Imágenes del Producto',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: Row(
            children: [
              InkWell(
                onTap: _pickImage,
                child: Container(
                  width: 100,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo,
                        color: Colors.grey[700],
                        size: 32,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cámara',
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (_imageBytes != null)
                _buildPreviewImage(
                  Image.memory(
                    _imageBytes!,
                    fit: BoxFit.cover,
                    width: 100,
                    height: 120,
                  ),
                )
              else if (widget.initialProduct?.imagePath != null)
                _buildPreviewImage(
                  Image.network(
                    widget.initialProduct!.imagePath!,
                    fit: BoxFit.cover,
                    width: 100,
                    height: 120,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewImage(Widget image) {
    return Stack(
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(12), child: image),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _imageBytes = null;
              });
            },
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.red, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información Básica',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nombre del Producto',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.shopping_bag_outlined),
          ),
          validator: (v) => v!.isEmpty ? 'Requerido' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Descripción',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
            prefixIcon: Icon(Icons.description_outlined),
          ),
          validator: (v) => v!.isEmpty ? 'Requerido' : null,
        ),
      ],
    );
  }

  Widget _buildPricingAndStock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Inventario y Precio',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Precio (Q)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stock',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                onChanged: (val) {
                  setState(() {
                    _isActive = (int.tryParse(val) ?? 0) > 0;
                  });
                },
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return Card(
      color: _isActive ? Colors.green[50] : Colors.red[50],
      child: SwitchListTile(
        title: Text(
          _isActive ? 'Producto Activo' : 'Producto Inactivo (Sin Stock)',
          style: TextStyle(
            color: _isActive ? Colors.green[900] : Colors.red[900],
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: const Text('Controla la visibilidad en la tienda'),
        value: _isActive,
        activeThumbColor: Colors.green,
        onChanged: (val) {
          setState(() => _isActive = val);
        },
      ),
    );
  }
}
