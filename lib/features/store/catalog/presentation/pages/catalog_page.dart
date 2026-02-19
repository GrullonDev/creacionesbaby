import 'package:creacionesbaby/core/models/product_model.dart';
import 'package:creacionesbaby/core/providers/cart_provider.dart';
import 'package:creacionesbaby/core/providers/product_provider.dart';
import 'package:creacionesbaby/features/store/cart/presentation/pages/mini_cart.dart';
import 'package:creacionesbaby/features/store/catalog/presentation/pages/product_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  // Filters state
  RangeValues _priceRange = const RangeValues(0, 5000);
  final Set<String> _selectedBenefits = {};
  final Set<String> _selectedMaterials = {};

  final List<String> _benefits = [
    'Seguridad Certificada',
    'Ergonómico',
    'Hipoalergénico',
    'Fácil Lavado',
  ];

  final List<String> _materials = [
    'Algodón Orgánico',
    'Bambú',
    'Tejido Transpirable',
    'Sintético Seguro',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const MiniCart(),
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Catálogo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          Consumer<CartProvider>(
            builder: (context, cart, _) => Badge(
              label: Text('${cart.itemCount}'),
              isLabelVisible: cart.itemCount > 0,
              child: IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sticky Filter Sidebar (Desktop)
          if (MediaQuery.of(context).size.width > 900)
            SizedBox(
              width: 300,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filtros',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildPriceFilter(),
                    const Divider(height: 48),
                    _buildCheckboxFilter(
                      'Beneficios',
                      _benefits,
                      _selectedBenefits,
                    ),
                    const Divider(height: 48),
                    _buildCheckboxFilter(
                      'Materiales',
                      _materials,
                      _selectedMaterials,
                    ),
                  ],
                ),
              ),
            ),

          // Product Grid
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.products.isEmpty) {
                  return const Center(
                    child: Text('No hay productos disponibles'),
                  );
                }

                // Apply simple client-side filtering (mock)
                // In a real app, you might do this in the provider or backend
                final filteredProducts = provider.products.where((product) {
                  final matchesPrice =
                      product.price >= _priceRange.start &&
                      product.price <= _priceRange.end;
                  // For now we don't have benefits/materials in ProductModel,
                  // so we only filter by price.
                  return matchesPrice;
                }).toList();

                return GridView.builder(
                  padding: const EdgeInsets.all(24),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 24,
                    childAspectRatio: 0.65, // Taller card for details
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    return _ProductCard(product: filteredProducts[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Precio', style: TextStyle(fontWeight: FontWeight.bold)),
        RangeSlider(
          values: _priceRange,
          min: 0,
          max: 5000,
          divisions: 50,
          labels: RangeLabels(
            'Q${_priceRange.start.round()}',
            'Q${_priceRange.end.round()}',
          ),
          onChanged: (values) {
            setState(() {
              _priceRange = values;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Q${_priceRange.start.round()}'),
            Text('Q${_priceRange.end.round()}'),
          ],
        ),
      ],
    );
  }

  Widget _buildCheckboxFilter(
    String title,
    List<String> options,
    Set<String> selected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...options.map((option) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: selected.contains(option),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selected.add(option);
                        } else {
                          selected.remove(option);
                        }
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(option, style: const TextStyle(fontSize: 14)),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _ProductCard extends StatefulWidget {
  final ProductModel product;

  const _ProductCard({required this.product});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Mock tags for demo
    final isTopRated = widget.product.price > 500;
    final isEco = widget.product.description.toLowerCase().contains('organic');
    final isLowStock = widget.product.stock < 10;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailPage(product: widget.product),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered ? Colors.blue[300]! : Colors.transparent,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Area
                  Expanded(
                    flex: 3,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: widget.product.imagePath != null
                              ? Image.network(
                                  widget.product.imagePath!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                )
                              : Container(
                                  color: Colors.grey[100],
                                  child: const Center(
                                    child: Icon(
                                      Icons.image,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                        ),
                        // Status Tags
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isTopRated)
                                _buildTag('TOP RATED', Colors.amber),
                              if (isEco) _buildTag('ECOLOGICO', Colors.green),
                              if (isLowStock)
                                _buildTag('POCAS UNIDADES', Colors.red),
                            ],
                          ),
                        ),
                        // Quick Add Overlay
                        if (_isHovered)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              color: Colors.blue.withValues(alpha: 0.9),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              alignment: Alignment.center,
                              child: const Text(
                                '+ Añadir Rápido',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Details Area
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Text(
                            'Q${widget.product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Reviews (Mock)
                          Row(
                            children: [
                              ...List.generate(
                                5,
                                (i) => const Icon(
                                  Icons.star,
                                  size: 14,
                                  color: Colors.amber,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(24)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
