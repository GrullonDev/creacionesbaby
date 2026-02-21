import 'package:creacionesbaby/core/models/product_model.dart';
import 'package:creacionesbaby/core/providers/product_provider.dart';
import 'package:creacionesbaby/features/admin/products/presentation/pages/add_edit_product_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  // Enum for filter: ALL, ACTIVE, INACTIVE
  int _filterIndex = 0; // 0: Todos, 1: Activos, 2: Inactivos

  @override
  void initState() {
    super.initState();
    // Load products when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

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
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.products.isEmpty) {
            return const Center(child: Text('No hay productos registrados.'));
          }

          // Apply Filter
          final filteredProducts = provider.products.where((product) {
            final isActive = product.stock > 0;
            if (_filterIndex == 1) return isActive;
            if (_filterIndex == 2) return !isActive;
            return true;
          }).toList();

          return RefreshIndicator(
            onRefresh: () => provider.loadProducts(),
            child: ListView.builder(
              itemCount: filteredProducts.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                final isActive = product.stock > 0;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 64,
                        height: 64,
                        child: product.imagePath != null
                            ? Image.network(
                                product.imagePath!,
                                fit: BoxFit.cover,
                                errorBuilder: (c, o, s) => Container(
                                  color: Colors.grey[200],
                                  child: const Icon(
                                    Icons.image,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                    ),
                    title: Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(
                            isActive ? Icons.check_circle : Icons.cancel,
                            size: 14,
                            color: isActive ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Stock: ${product.stock}',
                            style: TextStyle(
                              color: isActive
                                  ? Colors.green[700]
                                  : Colors.red[700],
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Q${product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (String value) {
                        if (value == 'edit') {
                          _navigateToEdit(context, product);
                        } else if (value == 'delete') {
                          _confirmDelete(context, provider, product);
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Text('Editar'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Text(
                                'Eliminar',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                    ),
                    onTap: () => _navigateToEdit(context, product),
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

  void _navigateToEdit(BuildContext context, ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditProductPage(
          product: {
            'id': product.id,
            'name': product.name,
            'description': product.description,
            'price': product.price,
            'stock': product.stock,
            'imagePath': product.imagePath,
            'imageUrls': product.imageUrls,
            'isActive': product.stock > 0,
          },
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    ProductProvider provider,
    ProductModel product,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Seguro que deseas eliminar "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.deleteProduct(product.id).catchError((e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al eliminar: $e')),
                );
              });
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
