import 'package:flutter/material.dart';

class AddEditProductPage extends StatefulWidget {
  final Map<String, dynamic>? product; // If null, it's adding a new product

  const AddEditProductPage({super.key, this.product});

  @override
  State<AddEditProductPage> createState() => _AddEditProductPageState();
}

class _AddEditProductPageState extends State<AddEditProductPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  // State variables
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      // Initialize with existing data if editing
      _nameController.text = widget.product!['name'] ?? '';
      _descController.text = widget.product!['description'] ?? '';
      _priceController.text = widget.product!['price']?.toString() ?? '';
      _stockController.text = widget.product!['stock']?.toString() ?? '';
      _isActive = widget.product!['isActive'] ?? true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Producto' : 'Nuevo Producto'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _saveProduct),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Image Section
            _buildImageSection(),
            const SizedBox(height: 24),

            // Basic Info
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
              validator: (value) =>
                  value == null || value.isEmpty ? 'Campo requerido' : null,
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
              validator: (value) =>
                  value == null || value.isEmpty ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 24),

            // Pricing & Inventory
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
                      labelText: 'Precio (\$)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Requerido' : null,
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
                    onChanged: (value) {
                      // Auto-update active status based on stock
                      final stock = int.tryParse(value) ?? 0;
                      setState(() {
                        _isActive = stock > 0;
                      });
                    },
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Requerido' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Status Card
            Card(
              color: _isActive ? Colors.green[50] : Colors.red[50],
              child: SwitchListTile(
                title: Text(
                  _isActive
                      ? 'Producto Activo'
                      : 'Producto Inactivo (Sin Stock)',
                  style: TextStyle(
                    color: _isActive ? Colors.green[900] : Colors.red[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text('Controla la visibilidad en la tienda'),
                value: _isActive,
                activeColor: Colors.green,
                onChanged: (val) {
                  setState(() {
                    _isActive = val;
                  });
                },
              ),
            ),
          ],
        ),
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
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Add Image Button
              InkWell(
                onTap: () {
                  // TODO: Implement Image Picker
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Funcionalidad de subir imagen pendiente'),
                    ),
                  );
                },
                child: Container(
                  width: 100,
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
                        'Agregar',
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Placeholder for existing images
              _buildImagePlaceholder(Colors.orange[100]!),
              const SizedBox(width: 12),
              _buildImagePlaceholder(Colors.blue[100]!),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder(Color color) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: NetworkImage(
            'https://via.placeholder.com/150',
          ), // Placeholder for now
          fit: BoxFit.cover,
          opacity: 0.6,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 4,
            top: 4,
            child: CircleAvatar(
              radius: 12,
              backgroundColor: Colors.white,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.close, size: 16, color: Colors.red),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement save logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto guardado exitosamente')),
      );
      Navigator.pop(context);
    }
  }
}
