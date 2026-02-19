import 'package:creacionesbaby/core/providers/app_config_provider.dart';
import 'package:creacionesbaby/core/providers/cart_provider.dart';
import 'package:creacionesbaby/core/providers/product_provider.dart';
import 'dart:async';
import 'package:creacionesbaby/features/store/catalog/presentation/pages/catalog_page.dart';
import 'package:creacionesbaby/features/store/cart/presentation/pages/mini_cart.dart';
import 'package:creacionesbaby/features/store/catalog/presentation/pages/product_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StoreHomePage extends StatefulWidget {
  const StoreHomePage({super.key});

  @override
  State<StoreHomePage> createState() => _StoreHomePageState();
}

class _StoreHomePageState extends State<StoreHomePage> {
  int _currentHeroPage = 0;
  late PageController _pageController;
  Timer? _carouselTimer;

  final List<String> _heroImages = [
    'https://images.unsplash.com/photo-1555252333-9f8e92e65df9?q=80&w=2000&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1519689680058-324335c77eba?q=80&w=2000&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?q=80&w=2000&auto=format&fit=crop',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Auto-advance carousel
    _carouselTimer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentHeroPage < _heroImages.length - 1) {
        _currentHeroPage++;
      } else {
        _currentHeroPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentHeroPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
      context.read<AppConfigProvider>().loadConfig();
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const MiniCart(),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(context),
            _buildFeaturesBar(context),
            const SizedBox(height: 40),
            _buildGrowthStages(context),
            const SizedBox(height: 40),
            _buildTrendingSection(context),
            const SizedBox(height: 40),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          const Text(
            'Creaciones Baby',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
          ),
          const SizedBox(width: 40),
          Expanded(
            child: Container(
              height: 45,
              constraints: const BoxConstraints(maxWidth: 500),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search baby essentials...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        if (MediaQuery.of(context).size.width > 800) ...[
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CatalogPage()),
              );
            },
            child: const Text(
              'Catálogo',
              style: TextStyle(color: Colors.black87),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              'Safety Guide',
              style: TextStyle(color: Colors.black87),
            ),
          ),
          const SizedBox(width: 16),
        ],
        IconButton(icon: const Icon(Icons.person_outline), onPressed: () {}),
        IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
        Consumer<CartProvider>(
          builder: (context, cart, child) {
            return Badge(
              label: Text('${cart.itemCount}'),
              isLabelVisible: cart.itemCount > 0,
              backgroundColor: Theme.of(context).primaryColor,
              child: IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            );
          },
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Consumer<AppConfigProvider>(
      builder: (context, config, _) {
        // If config has a specific banner, use it as the first image
        final displayImages = [..._heroImages];
        if (config.bannerImageUrl != null) {
          displayImages.insert(0, config.bannerImageUrl!);
        }

        return SizedBox(
          height: 600, // Taller, more cinematic
          width: double.infinity,
          child: Stack(
            children: [
              // Carousel
              PageView.builder(
                controller: _pageController,
                itemCount: displayImages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentHeroPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Image.network(
                    displayImages[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: Colors.grey[200]);
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                          color: Colors.white,
                        ),
                      );
                    },
                  );
                },
              ),

              // Overlay Gradient for text readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.2),
                      Colors.black.withValues(alpha: 0.5),
                    ],
                  ),
                ),
              ),

              // Content
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Seguridad en la que confías,\ncomodidad que ellos aman',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black45,
                              offset: Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Esenciales premium diseñados para el desarrollo de tu bebé.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 20,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text('VER COLECCIÓN'),
                      ),
                    ],
                  ),
                ),
              ),

              // Indicators
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(displayImages.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentHeroPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentHeroPage == index
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeaturesBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Center(
        child: Wrap(
          spacing: 60,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: [
            _featureItem(
              Icons.local_shipping_outlined,
              'Envío Gratis',
              'En todas las órdenes',
            ),
            _featureItem(
              Icons.medical_services_outlined,
              'Certificación Médica',
              'Aprobado por pediatras',
            ),
            _featureItem(
              Icons.assignment_return_outlined,
              'Devoluciones Fáciles',
              '30 días de garantía',
            ),
            _featureItem(
              Icons.eco_outlined,
              'Materiales Orgánicos',
              '100% Algodón sostenible',
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureItem(IconData icon, String title, String subtitle) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.blue, size: 28),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGrowthStages(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Compra por Etapa',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Productos adaptados para cada momento especial',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
        const SizedBox(height: 48),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              _stageCard(
                'Recién Nacido',
                '0-6 Meses',
                'https://images.unsplash.com/photo-1555252333-9f8e92e65df9?q=80&w=600&auto=format&fit=crop', // Minimalist
              ),
              const SizedBox(width: 24),
              _stageCard(
                'Infante',
                '6-18 Meses',
                'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?q=80&w=600&auto=format&fit=crop', // Minimalist
              ),
              const SizedBox(width: 24),
              _stageCard(
                'Niño Pequeño',
                '18-36 Meses',
                'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?q=80&w=600&auto=format&fit=crop', // Minimalist
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stageCard(String title, String subtitle, String imageUrl) {
    return Container(
      width: 300,
      height: 380,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
          ),
        ),
        padding: const EdgeInsets.all(24),
        alignment: Alignment.bottomLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              'Explore Essentials →',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingSection(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trending Now',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Our most loved pieces this season',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All Products >'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 350,
          child: Consumer<ProductProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              final products = provider.products.take(5).toList();
              if (products.isEmpty) {
                return const Center(child: Text('Coming soon'));
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 24),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailPage(product: product),
                      ),
                    ),
                    child: Container(
                      width: 250,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
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
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: product.imagePath != null
                                  ? Image.network(
                                      product.imagePath!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    )
                                  : Container(
                                      color: Colors.grey[100],
                                      child: const Icon(
                                        Icons.image,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CATEGORY',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Q${product.price.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.amber,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  textStyle: const TextStyle(fontSize: 12),
                                ),
                                child: const Text('Add to Cart'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      color: const Color(0xFF0F172A), // Dark Blue
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            const Text(
              'Creaciones Baby',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.facebook, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              '© 2026 Creaciones Baby. All Rights Reserved.',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
