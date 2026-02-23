import 'package:creacionesbaby/config/app_theme.dart';
import 'package:creacionesbaby/core/models/product_model.dart';
import 'package:creacionesbaby/core/providers/cart_provider.dart';
import 'package:creacionesbaby/core/providers/product_provider.dart';
import 'package:creacionesbaby/features/store/cart/presentation/pages/mini_cart.dart';
import 'package:creacionesbaby/features/store/catalog/presentation/pages/product_detail_page.dart';
import 'package:creacionesbaby/utils/page_transitions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  RangeValues _priceRange = const RangeValues(0, 5000);
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          Consumer<CartProvider>(
            builder: (context, cart, _) => Badge(
              label: Text('${cart.itemCount}'),
              isLabelVisible: cart.itemCount > 0,
              backgroundColor: AppTheme.primaryGreen,
              child: IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          _buildSecondaryHeader(context),
          _buildBreadcrumbs(context),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (MediaQuery.of(context).size.width > 900)
                  _buildDesktopSidebar(context),
                Expanded(
                  child: Consumer<ProductProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading) return _buildSkeletonGrid();
                      final filteredProducts = provider.products.where((p) {
                        final matchesPrice =
                            p.price >= _priceRange.start &&
                            p.price <= _priceRange.end;
                        final matchesSearch =
                            _searchQuery.isEmpty ||
                            p.name.toLowerCase().contains(_searchQuery);
                        return matchesPrice && matchesSearch;
                      }).toList();
                      return Column(
                        children: [
                          _buildItemsHeader(
                            context,
                            filteredProducts.length,
                            provider.products.length,
                          ),
                          Expanded(
                            child: filteredProducts.isEmpty
                                ? _buildEmptyState()
                                : Column(
                                    children: [
                                      Expanded(
                                        child: GridView.builder(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                          ),
                                          gridDelegate:
                                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                                maxCrossAxisExtent: 300,
                                                mainAxisSpacing: 24,
                                                crossAxisSpacing: 24,
                                                childAspectRatio: 0.72,
                                              ),
                                          itemCount: filteredProducts.length,
                                          itemBuilder: (context, index) =>
                                              _ProductCard(
                                                product:
                                                    filteredProducts[index],
                                              ),
                                        ),
                                      ),
                                      _buildPagination(context),
                                    ],
                                  ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          _buildQuickInfoFooter(context),
        ],
      ),
    );
  }

  Widget _buildSecondaryHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        children: [
          if (MediaQuery.of(context).size.width > 800) ...[
            _headerNav('Recién Nacidos', true),
            _headerNav('Conjuntos', false),
            _headerNav('Pijamas', false),
            _headerNav('Accesorios', false),
            const Spacer(),
          ],
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.backgroundSoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) =>
                    setState(() => _searchQuery = v.toLowerCase()),
                decoration: const InputDecoration(
                  hintText: 'Buscar productos...',
                  prefixIcon: Icon(Icons.search, size: 20),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.only(bottom: 10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerNav(String title, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(right: 32),
      child: InkWell(
        onTap: () {},
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? AppTheme.primaryDark : AppTheme.primaryMedium,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildBreadcrumbs(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: const Row(
        children: [
          Text(
            'Inicio',
            style: TextStyle(color: AppTheme.primaryMedium, fontSize: 13),
          ),
          Icon(Icons.chevron_right, size: 16, color: AppTheme.primaryMedium),
          Text(
            'Ropa',
            style: TextStyle(color: AppTheme.primaryMedium, fontSize: 13),
          ),
          Icon(Icons.chevron_right, size: 16, color: AppTheme.primaryMedium),
          Text(
            'Recién Nacidos',
            style: TextStyle(
              color: AppTheme.primaryDark,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsHeader(BuildContext context, int shown, int total) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          const Icon(Icons.tune_rounded, size: 18),
          const SizedBox(width: 8),
          const Text('Filtros', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
          TextButton(
            onPressed: () =>
                setState(() => _priceRange = const RangeValues(0, 5000)),
            child: const Text(
              'Limpiar todo',
              style: TextStyle(fontSize: 12, color: AppTheme.primaryMedium),
            ),
          ),
          const Spacer(),
          Text(
            'Mostrando $shown de $total productos',
            style: const TextStyle(color: AppTheme.primaryMedium, fontSize: 12),
          ),
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Text('Ordenar por: Destacados', style: TextStyle(fontSize: 12)),
                Icon(Icons.keyboard_arrow_down, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSidebar(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _sidebarSection('Categoría', [
              _checkOption('Mamelucos', true),
              _checkOption('Conjuntos', false),
              _checkOption('Pijamas', false),
            ]),
            _sidebarSection('Edad', [
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ageChip('0-3 meses', false),
                  _ageChip('3-6 meses', false),
                  _ageChip('6-12 meses', true),
                  _ageChip('1-2 años', false),
                ],
              ),
            ]),
            _sidebarSection('Precio', [
              RangeSlider(
                values: _priceRange,
                min: 0,
                max: 5000,
                activeColor: AppTheme.primaryGreen,
                inactiveColor: AppTheme.backgroundSoft,
                onChanged: (v) => setState(() => _priceRange = v),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Q${_priceRange.start.round()}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  Text(
                    'Q${_priceRange.end.round()}',
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _sidebarSection(String title, List<Widget> children) {
    return ExpansionTile(
      initiallyExpanded: true,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      children: children,
      shape: const Border(),
      tilePadding: EdgeInsets.zero,
    );
  }

  Widget _checkOption(String label, bool isChecked) {
    return Row(
      children: [
        Checkbox(
          value: isChecked,
          onChanged: (v) {},
          activeColor: AppTheme.primaryGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  Widget _ageChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? AppTheme.primaryGreen : Colors.grey[200]!,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: isSelected ? AppTheme.primaryGreen : AppTheme.primaryMedium,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildPagination(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _pageArrow(Icons.chevron_left),
          _pageNumber('1', true),
          _pageNumber('2', false),
          _pageNumber('3', false),
          const Text('...'),
          _pageNumber('8', false),
          _pageArrow(Icons.chevron_right),
        ],
      ),
    );
  }

  Widget _pageArrow(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 18, color: AppTheme.primaryMedium),
    );
  }

  Widget _pageNumber(String n, bool isActive) {
    return Container(
      width: 36,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryGreen : Colors.transparent,
        border: Border.all(
          color: isActive ? AppTheme.primaryGreen : Colors.grey[200]!,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        n,
        style: TextStyle(
          color: isActive ? Colors.white : AppTheme.primaryMedium,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'No se encontraron productos',
        style: TextStyle(color: AppTheme.primaryMedium),
      ),
    );
  }

  Widget _buildQuickInfoFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      color: AppTheme.backgroundSoft.withOpacity(0.3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _quickItem(Icons.local_shipping_outlined, 'Envío Gratis'),
          _quickItem(Icons.eco_outlined, '100% Algodón'),
          _quickItem(Icons.verified_user_outlined, 'Pago Seguro'),
          _quickItem(Icons.support_agent_outlined, 'Soporte 24/7'),
        ],
      ),
    );
  }

  Widget _quickItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryGreen),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildSkeletonGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        childAspectRatio: 0.72,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => _SkeletonCard(delay: index * 100),
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
  @override
  Widget build(BuildContext context) {
    final discount = widget.product.price > 400 ? 20 : 0;

    // Determine category color
    Color catColor = AppTheme.backgroundSoft;
    String catLabel = widget.product.category ?? 'General';

    if (catLabel.toLowerCase().contains('niña') ||
        catLabel.toLowerCase().contains('girl')) {
      catColor = AppTheme.girlPink;
    } else if (catLabel.toLowerCase().contains('niño') ||
        catLabel.toLowerCase().contains('boy')) {
      catColor = AppTheme.boyBlue;
    } else if (catLabel.toLowerCase().contains('unisex')) {
      catColor = AppTheme.unisexYellow;
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        SmoothPageRoute(page: ProductDetailPage(product: widget.product)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: catColor.withOpacity(
                      0.2,
                    ), // Use category color as subtle bg
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: widget.product.imagePath != null
                      ? Image.network(
                          widget.product.imagePath!,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image, color: Colors.grey),
                ),
                if (discount > 0)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _badge('-$discount%', Colors.red[400]!),
                  ),
                if (widget.product.stock > 15)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _badge('NUEVO', AppTheme.primaryGreen),
                  ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      size: 16,
                      color: AppTheme.primaryMedium,
                    ),
                  ),
                ),
                // Category indicator
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: catColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      catLabel.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            catLabel,
            style: TextStyle(
              color: AppTheme.primaryMedium,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.product.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Q${widget.product.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
              InkWell(
                onTap: () =>
                    context.read<CartProvider>().addItem(widget.product),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                    size: 16,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatefulWidget {
  final int delay;
  const _SkeletonCard({this.delay = 0});
  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.backgroundSoft.withOpacity(_animation.value),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 12,
              width: double.infinity,
              color: AppTheme.backgroundSoft.withOpacity(_animation.value),
            ),
            const SizedBox(height: 8),
            Container(
              height: 12,
              width: 100,
              color: AppTheme.backgroundSoft.withOpacity(_animation.value),
            ),
          ],
        ),
      ),
    );
  }
}
