import 'package:creacionesbaby/core/models/product_model.dart';
import 'package:creacionesbaby/core/providers/cart_provider.dart';
import 'package:creacionesbaby/features/store/cart/presentation/pages/mini_cart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductModel product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late ScrollController _scrollController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showStickyBar = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final show = _scrollController.offset > 600;
      if (show != _showStickyBar) {
        setState(() => _showStickyBar = show);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _selectedSize = '0-3 Recién Nacido';
  int _selectedDesignIndex = 0;
  int _quantity = 1;
  int _selectedImageIndex = 0;

  // Mock data for UI demonstration
  final List<String> _sizes = [
    '0-3 Recién Nacido',
    '3-6 Meses',
    '6-9 Meses',
    '9-12 Meses',
    '12-18 Meses',
    '18-24 Meses',
    '2-3 Años',
  ];

  // Designs instead of Colors
  final List<String> _designs = ['Liso', 'Estampado'];

  void _addToCart() {
    context.read<CartProvider>().addItem(widget.product, size: _selectedSize);
    _scaffoldKey.currentState?.openEndDrawer(); // Open Mini Cart Drawer safely
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: const MiniCart(), // Attach MiniCart Drawer
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tienda'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          Consumer<CartProvider>(
            builder: (context, cart, _) => Badge(
              label: Text('${cart.itemCount}'),
              isLabelVisible: cart.itemCount > 0,
              child: IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () {}),
          const SizedBox(width: 16),
        ],
      ),
      body: Builder(
        builder: (context) {
          return Stack(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    _buildBreadcrumbs(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 60 : 20,
                        vertical: 20,
                      ),
                      child: isDesktop
                          ? _buildDesktopLayout()
                          : Column(
                              children: [
                                _buildImageGallery(),
                                const SizedBox(height: 32),
                                _buildProductInfo(),
                              ],
                            ),
                    ),
                    const SizedBox(height: 60),
                    _buildDetailedSections(isDesktop),
                    const SizedBox(height: 60),
                    _buildReviewSection(isDesktop),
                    const SizedBox(height: 60),
                    _buildSocialProofSection(isDesktop),
                    const SizedBox(height: 100), // Space for sticky bar
                  ],
                ),
              ),
              if (_showStickyBar)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Row(
                        children: [
                          if (isDesktop) ...[
                            Text(
                              widget.product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          Text(
                            'Q${widget.product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: widget.product.stock > 0
                                ? _addToCart
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Agregar al Carrito'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBreadcrumbs() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.grey[50],
      child: Row(
        children: [
          Text(
            'Inicio',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
          const SizedBox(width: 8),
          Text('Bebé', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.product.name,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildImageGallery()),
        const SizedBox(width: 60),
        Expanded(flex: 2, child: _buildProductInfo()),
      ],
    );
  }

  Widget _buildImageGallery() {
    // Use all product images from imageUrls
    final images = widget.product.imageUrls.isNotEmpty
        ? widget.product.imageUrls
        : (widget.product.imagePath != null
              ? [widget.product.imagePath!]
              : <String>[]);

    return Column(
      children: [
        // Main Image (Zoomable)
        GestureDetector(
          onTap: () {
            // Open Zoom Dialog
            showDialog(
              context: context,
              builder: (context) => Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: EdgeInsets.zero,
                child: Stack(
                  children: [
                    InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 4.0,
                      child: Center(
                        child: Image.network(
                          images[_selectedImageIndex < images.length
                              ? _selectedImageIndex
                              : 0],
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 80,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      right: 20,
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          child: Stack(
            children: [
              Container(
                height: 500,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F5F2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: images.isNotEmpty
                      ? Image.network(
                          images[_selectedImageIndex < images.length
                              ? _selectedImageIndex
                              : 0],
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(
                              Icons.image,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 80,
                            color: Colors.grey,
                          ),
                        ),
                ),
              ),
              const Positioned(
                bottom: 16,
                right: 16,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.zoom_in, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Thumbnails - Only show if more than 1 image
        if (images.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (index) {
              final isSelected = _selectedImageIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedImageIndex = index),
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      images[index],
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image, size: 20),
                    ),
                  ),
                ),
              );
            }),
          ),
      ],
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ratings
        Row(
          children: [
            Row(
              children: List.generate(
                5,
                (index) => const Icon(
                  Icons.star,
                  size: 18,
                  color: Color(0xFFF59E0B), // Amber color
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(128 reseñas)',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Title
        Text(
          widget.product.name,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            fontFamily: 'Serif', // Fallback for a nice serif
            height: 1.1,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 16),

        // Price
        Text(
          'Q${widget.product.price.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFF3B82F6), // Blue
          ),
        ),
        const SizedBox(height: 24),

        // Description
        Text(
          widget.product.description.isEmpty
              ? 'Diseñado para la máxima comodidad y seguridad. Este producto distribuye el peso de manera uniforme mientras proporciona un soporte superior para su pequeño.'
              : widget.product.description,
          style: TextStyle(fontSize: 16, height: 1.6, color: Colors.grey[600]),
        ),
        const SizedBox(height: 32),

        // Key Features
        const Row(
          children: [
            _FeatureIcon(
              icon: Icons.check_circle_outline,
              label: 'LIBRE DE BPA',
            ),
            SizedBox(width: 24),
            _FeatureIcon(
              icon: Icons.local_shipping_outlined,
              label: 'ENVÍO RÁPIDO',
            ),
            SizedBox(width: 24),
            _FeatureIcon(icon: Icons.eco_outlined, label: 'ORGÁNICO'),
          ],
        ),
        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 32),

        // Design Selection (instead of Color)
        Text(
          'DISEÑO: ${_designs[_selectedDesignIndex].toUpperCase()}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: List.generate(_designs.length, (index) {
            final isSelected = _selectedDesignIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedDesignIndex = index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE0F2FE) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF3B82F6)
                        : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  _designs[index],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? const Color(0xFF3B82F6)
                        : Colors.black87,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),

        // Size Selection
        const Text(
          'EDAD / TAMAÑO',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: _sizes.map((size) {
            final isSelected = _selectedSize == size;
            return GestureDetector(
              onTap: () => setState(() => _selectedSize = size),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE0F2FE) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF3B82F6)
                        : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  size,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? const Color(0xFF3B82F6)
                        : Colors.black87,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),

        // Quantity & Actions
        Row(
          children: [
            // Quantity
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 16),
                    onPressed: () => setState(() {
                      if (_quantity > 1) _quantity--;
                    }),
                  ),
                  Text(
                    '$_quantity',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 16),
                    onPressed: () => setState(() => _quantity++),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.product.stock > 0 ? _addToCart : null,
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('Agregar al Carrito'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6), // Brand Blue
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A), // Dark Slate
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  elevation: 0,
                ),
                child: const Text('Comprar Ahora'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailedSections(bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20),
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildDescriptionContent()),
                const SizedBox(width: 60),
                Expanded(flex: 1, child: _buildSidebar()),
              ],
            )
          : _buildDescriptionContent(),
    );
  }

  Widget _buildDescriptionContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descripción del Producto',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          widget.product.description.isNotEmpty
              ? widget.product.description
              : 'Diseñado para la máxima comodidad y seguridad. ${widget.product.name} distribuye el peso de manera uniforme mientras proporciona un soporte superior para tu pequeño.',
          style: const TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 40),
        const Text(
          'Especificaciones de Seguridad',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildSpecCard(
                'Certificaciones',
                Icons.verified_user_outlined,
                [
                  'Estándar de Seguridad ASTM F2236',
                  'OEKO-TEX Standard 100',
                  'Diseño Ergonómico Certificado',
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildSpecCard('Límites Técnicos', Icons.scale_outlined, [
                'Peso: 3.2 kg - 20 kg',
                'Edad: Recién nacido a 3 años',
                'Tela: 100% Algodón Orgánico',
              ]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpecCard(String title, IconData icon, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿Por qué CreacionesBaby?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildSidebarItem(
            Icons.verified_outlined,
            'Garantía de Calidad',
            'Respaldamos la calidad de nuestros productos.',
          ),
          const SizedBox(height: 16),
          _buildSidebarItem(
            Icons.refresh_outlined,
            '30 Días de Prueba',
            '¿No es lo que esperabas? Devúel velo gratis.',
          ),
          const SizedBox(height: 16),
          _buildSidebarItem(
            Icons.support_agent_outlined,
            'Atención Personalizada',
            'Contáctanos para asesoría de productos.',
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blue[700], size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSection(bool isDesktop) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reseñas de Clientes',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Row(
                        children: List.generate(
                          5,
                          (index) => const Icon(
                            Icons.star,
                            size: 20,
                            color: Color(0xFFF59E0B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '4.8 de 5',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Basado en 128 valoraciones',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Escribir Reseña'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Mock Reviews Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = (constraints.maxWidth > 900)
                  ? 3
                  : 1; // Use LayoutBuilder constraints instead of MediaQuery for better responsiveness
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  mainAxisExtent:
                      220, // Use fixed height instead of aspect ratio to avoid overflow
                ),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[200]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: List.generate(
                            5,
                            (i) => const Icon(
                              Icons.star,
                              size: 14,
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '¡Excelente calidad!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Expanded(
                          child: Text(
                            '"Muy buena calidad, el material es suave y seguro para mi bebé. Lo recomiendo al 100%."',
                            style: TextStyle(
                              color: Colors.black54,
                              fontStyle: FontStyle.italic,
                              fontSize: 13,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.grey[200],
                              child: Text(
                                'SJ',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'María G.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Compra Verificada',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSocialProofSection(bool isDesktop) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preguntas Frecuentes',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildFAQItem(
            '¿Es seguro para recién nacidos?',
            'Sí, nuestro diseño soporta ergonómicamente a bebés desde los 3.2 kg sin necesidad de insertos adicionales.',
          ),
          _buildFAQItem(
            '¿Cómo se lava?',
            'Se puede lavar a máquina en ciclo delicado con agua fría y detergente suave. Secar al aire.',
          ),
          const SizedBox(height: 48),
          const Text(
            'Momentos Reales',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Fotos enviadas por padres felices',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildRealPhoto(
                  'https://images.unsplash.com/photo-1519689680058-324335c77eba?auto=format&fit=crop&q=80&w=400',
                ),
                const SizedBox(width: 16),
                _buildRealPhoto(
                  'https://images.unsplash.com/photo-1555252333-9f8e92e65df9?auto=format&fit=crop&q=80&w=400',
                ),
                const SizedBox(width: 16),
                _buildRealPhoto(
                  'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?auto=format&fit=crop&q=80&w=400',
                ),
                const SizedBox(width: 16),
                _buildRealPhoto(
                  'https://images.unsplash.com/photo-1544126566-475a75bdd8a9?auto=format&fit=crop&q=80&w=400',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50], // Lighter background
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(
            answer,
            style: const TextStyle(color: Colors.black87, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildRealPhoto(String url) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8),
        ],
      ),
    );
  }
}

class _FeatureIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.green),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
