import 'package:creacionesbaby/core/models/product_model.dart';
import 'package:creacionesbaby/core/providers/product_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddEditProductPage extends StatelessWidget {
  final Map<String, dynamic>? product;

  const AddEditProductPage({super.key, this.product});

  @override
  Widget build(BuildContext context) {
    final isEditing = product != null;
    final productModel = isEditing
        ? ProductModel(
            id: product!['id']?.toString() ?? '',
            name: product!['name'] ?? '',
            description: product!['description'] ?? '',
            price: (product!['price'] as num?)?.toDouble() ?? 0.0,
            stock: (product!['stock'] as num?)?.toInt() ?? 0,
            imagePath: product!['imagePath'],
            imageUrls: product!['imageUrls'] != null
                ? List<String>.from(product!['imageUrls'])
                : [],
            category: product!['category'],
            isActive: product!['isActive'] ?? true,
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
                onSave: (newProduct, imageBytesList, existingUrls) async {
                  try {
                    if (isEditing) {
                      await provider.updateProduct(
                        newProduct,
                        newImageBytesList: imageBytesList,
                        existingImageUrls: existingUrls,
                      );
                    } else {
                      await provider.addProduct(
                        newProduct,
                        imageBytesList: imageBytesList,
                      );
                    }
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isEditing
                                    ? 'Producto actualizado exitosamente'
                                    : 'Producto guardado exitosamente',
                              ),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Error: ${e.toString().replaceAll('PostgrestException(message: ', '').replaceAll(')', '')}',
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 5),
                        ),
                      );
                    }
                  }
                },
              ),
              if (provider.isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
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
  final Function(
    ProductModel product,
    List<Uint8List>? newImageBytesList,
    List<String>? existingImageUrls,
  )
  onSave;

  const ProductForm({super.key, this.initialProduct, required this.onSave});

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  static const int _maxImages = 5;

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;

  bool _isActive = true;
  String? _selectedCategory;

  final List<String> _categories = [
    'Recién Nacido',
    'Conjuntos',
    'Pijamas',
    'Accesorios',
    'Juguetes',
  ];

  final ImagePicker _picker = ImagePicker();

  // Multi-image state
  final List<Uint8List> _newImageBytesList = []; // New images to upload
  late List<String> _existingImageUrls; // Existing URLs from server

  int get _totalImages => _existingImageUrls.length + _newImageBytesList.length;
  bool get _canAddMore => _totalImages < _maxImages;

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

    // Map existing English categories to Spanish to avoid Dropdown error
    final categoryMap = {
      'Newborn': 'Recién Nacido',
      'Bundles': 'Conjuntos',
      'Pajamas': 'Pijamas',
      'Accessories': 'Accesorios',
      'Toys': 'Juguetes',
    };

    final existingCat = p?.category;
    if (existingCat != null) {
      _selectedCategory =
          categoryMap[existingCat] ??
          (_categories.contains(existingCat) ? existingCat : null);
    } else {
      _selectedCategory = null;
    }

    _existingImageUrls = List.from(p?.imageUrls ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage({required ImageSource source}) async {
    if (!_canAddMore) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Máximo 5 imágenes permitidas')),
      );
      return;
    }
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        setState(() {
          _newImageBytesList.add(bytes);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo acceder a la imagen')),
        );
      }
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Cámara'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(source: ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(source: ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImageUrls.removeAt(index);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImageBytesList.removeAt(index);
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Validate at least 1 image when creating
      if (widget.initialProduct == null && _totalImages == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Agrega al menos 1 imagen del producto'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final product = ProductModel(
        id: widget.initialProduct?.id ?? DateTime.now().toString(),
        name: _nameController.text,
        description: _descController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        stock: int.tryParse(_stockController.text) ?? 0,
        imagePath: widget.initialProduct?.imagePath,
        imageUrls: _existingImageUrls,
        category: _selectedCategory,
        isActive: _isActive,
        isLocal: false,
      );
      widget.onSave(
        product,
        _newImageBytesList.isNotEmpty ? _newImageBytesList : null,
        _existingImageUrls.isNotEmpty ? _existingImageUrls : null,
      );
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
          _buildCategorySelection(),
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
        Row(
          children: [
            const Text(
              'Imágenes del Producto',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _totalImages > 0 ? Colors.green[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _totalImages > 0
                      ? Colors.green[300]!
                      : Colors.red[300]!,
                ),
              ),
              child: Text(
                '$_totalImages / $_maxImages',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _totalImages > 0 ? Colors.green[700] : Colors.red[700],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'La primera imagen será la principal. Mínimo 1, máximo $_maxImages.',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Existing images from server
              ..._existingImageUrls.asMap().entries.map((entry) {
                final index = entry.key;
                final url = entry.value;
                return _buildImageTile(
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    width: 110,
                    height: 130,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image),
                  ),
                  isPrimary: index == 0 && _existingImageUrls.isNotEmpty,
                  onRemove: () => _removeExistingImage(index),
                );
              }),
              // New images (not yet uploaded)
              ..._newImageBytesList.asMap().entries.map((entry) {
                final index = entry.key;
                final bytes = entry.value;
                return _buildImageTile(
                  child: Image.memory(
                    bytes,
                    fit: BoxFit.cover,
                    width: 110,
                    height: 130,
                  ),
                  isPrimary: _existingImageUrls.isEmpty && index == 0,
                  isNew: true,
                  onRemove: () => _removeNewImage(index),
                );
              }),
              // Add button
              if (_canAddMore)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: _showImageSourcePicker,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 110,
                      height: 130,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[400]!,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            color: Colors.grey[600],
                            size: 32,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Agregar',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageTile({
    required Widget child,
    required VoidCallback onRemove,
    bool isPrimary = false,
    bool isNew = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Stack(
        children: [
          Container(
            width: 110,
            height: 130,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: isPrimary
                  ? Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 2.5,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isPrimary ? 10 : 12),
              child: child,
            ),
          ),
          // Primary badge
          if (isPrimary)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 3),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(10),
                  ),
                ),
                child: const Text(
                  'PRINCIPAL',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          // "NEW" badge
          if (isNew)
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'NUEVA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          // Remove button
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(Icons.close, color: Colors.red, size: 16),
              ),
            ),
          ),
        ],
      ),
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

  Widget _buildCategorySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categoría',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _selectedCategory,
          decoration: const InputDecoration(
            labelText: 'Selecciona una categoría',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category_outlined),
          ),
          items: _categories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedCategory = newValue;
            });
          },
          validator: (v) =>
              v == null ? 'Por favor selecciona una categoría' : null,
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
