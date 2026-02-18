import 'package:creacionesbaby/features/admin/products/presentation/pages/add_edit_product_page.dart';
import 'package:flutter/material.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  // Enum for filter: ALL, ACTIVE, INACTIVE
  int _filterIndex = 0; // 0: Todos, 1: Activos, 2: Inactivos

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Productos'),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                FilterChip(
                  label: const Text('Todos'),
                  selected: _filterIndex == 0,
                  onSelected: (bool selected) {
                    setState(() {
                      _filterIndex = 0;
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Activos (Stock > 0)'),
                  selected: _filterIndex == 1,
                  onSelected: (bool selected) {
                    setState(() {
                      _filterIndex = 1;
                    });
                  },
                  checkmarkColor: Colors.green,
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Inactivos (Sin Stock)'),
                  selected: _filterIndex == 2,
                  onSelected: (bool selected) {
                    setState(() {
                      _filterIndex = 2;
                    });
                  },
                  checkmarkColor: Colors.red,
                ),
              ],
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: 10,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          // Mock data logic for demonstration
          final isActive = index % 3 != 0; // Every 3rd item is inactive (mock)

          // Apply filter
          if (_filterIndex == 1 && !isActive) return const SizedBox.shrink();
          if (_filterIndex == 2 && isActive) return const SizedBox.shrink();

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: Stack(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                  if (!isActive)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        color: Colors.red,
                        child: const Icon(
                          Icons.close,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              title: Text('Producto #$index'),
              subtitle: Text(
                'Stock: ${isActive ? '25' : '0'} | Precio: \$15.00',
                style: TextStyle(color: isActive ? Colors.black87 : Colors.red),
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (String value) {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddEditProductPage(
                          product: {
                            'name': 'Producto Mock',
                            'stock': 25,
                            'isActive': true,
                          },
                        ), // Mock passed
                      ),
                    );
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Text('Editar'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Eliminar'),
                  ),
                ],
              ),
              onTap: () {
                // Open Edit Page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddEditProductPage(
                      product: {
                        'name': 'Producto Mock',
                        'stock': 25,
                        'isActive': true,
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditProductPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
