import 'package:creacionesbaby/core/providers/app_config_provider.dart';
import 'package:creacionesbaby/core/providers/cart_provider.dart';
import 'package:creacionesbaby/core/providers/product_provider.dart';
import 'dart:async';
import 'package:creacionesbaby/features/store/catalog/presentation/pages/catalog_page.dart';
import 'package:creacionesbaby/features/store/cart/presentation/pages/mini_cart.dart';
import 'package:creacionesbaby/features/store/catalog/presentation/pages/product_detail_page.dart';
import 'package:creacionesbaby/utils/page_transitions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final isWide = MediaQuery.of(context).size.width > 800;
    return AppBar(
      title: Row(
        children: [
          const Text(
            'Creaciones Baby',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
          ),
          if (isWide) ...[
            const SizedBox(width: 40),
            Expanded(
              child: Container(
                height: 45,
                constraints: const BoxConstraints(maxWidth: 500),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar productos para bebé...',
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
          ] else
            const Spacer(),
        ],
      ),
      actions: [
        if (isWide) ...[
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                SmoothPageRoute(page: const CatalogPage()),
              );
            },
            child: const Text(
              'Catálogo',
              style: TextStyle(color: Colors.black87),
            ),
          ),
          const SizedBox(width: 16),
        ],
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
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Consumer<AppConfigProvider>(
      builder: (context, config, _) {
        final displayImages = [..._heroImages];
        if (config.bannerImageUrl != null) {
          displayImages.insert(0, config.bannerImageUrl!);
        }

        return SizedBox(
          height: isMobile ? 400 : 600,
          width: double.infinity,
          child: Stack(
            children: [
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
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Seguridad en la que confías,\ncomodidad que ellos aman',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 28 : 48,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                          shadows: const [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black45,
                              offset: Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Esenciales premium diseñados para el desarrollo de tu bebé.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 14 : 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            SmoothPageRoute(page: const CatalogPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 24 : 32,
                            vertical: isMobile ? 14 : 20,
                          ),
                          textStyle: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text('VER COLECCIÓN'),
                      ),
                    ],
                  ),
                ),
              ),
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
              'Envío a Domicilio',
              'En toda Guatemala',
            ),
            _featureItem(
              Icons.verified_outlined,
              'Calidad Garantizada',
              'Productos certificados',
            ),
            _featureItem(
              Icons.assignment_return_outlined,
              'Devoluciones Fáciles',
              '30 días de garantía',
            ),
            _featureItem(
              Icons.eco_outlined,
              'Materiales Seguros',
              'Hipoalergénicos para bebé',
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
              'Explorar Productos →',
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
                    'Lo Más Popular',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Nuestros productos favoritos esta temporada',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    SmoothPageRoute(page: const CatalogPage()),
                  );
                },
                child: const Text('Ver Todos los Productos >'),
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
                return const Center(
                  child: Text(
                    'Próximamente — estamos preparando los mejores productos',
                  ),
                );
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
                      SmoothPageRoute(
                        page: ProductDetailPage(product: product),
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
                                  product.stock > 0 ? 'DISPONIBLE' : 'AGOTADO',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: product.stock > 0
                                        ? Colors.green[600]
                                        : Colors.red[600],
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
                                Text(
                                  'Q${product.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
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
                                onPressed: product.stock > 0
                                    ? () {
                                        context.read<CartProvider>().addItem(
                                          product,
                                        );
                                        Scaffold.of(context).openEndDrawer();
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  textStyle: const TextStyle(fontSize: 12),
                                ),
                                child: Text(
                                  product.stock > 0
                                      ? 'Agregar al Carrito'
                                      : 'Agotado',
                                ),
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
    final isMobile = MediaQuery.of(context).size.width < 768;
    return Container(
      color: const Color(0xFF0F172A),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 24 : 60,
              vertical: isMobile ? 32 : 48,
            ),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildFooterBrand(),
                      const SizedBox(height: 32),
                      _buildFooterLinks(context),
                      const SizedBox(height: 32),
                      _buildFooterSocial(),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildFooterBrand()),
                      const SizedBox(width: 48),
                      Expanded(child: _buildFooterLinks(context)),
                      const SizedBox(width: 48),
                      Expanded(child: _buildFooterSocial()),
                    ],
                  ),
          ),
          // Bottom bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white12)),
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children: [
                const Text(
                  '© 2026 CreacionesBaby. Todos los derechos reservados.',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
                const Text(
                  'Hecho con ❤️ en Guatemala',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterBrand() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF472B6), Color(0xFFA78BFA)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.child_care,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'CreacionesBaby',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Productos artesanales para tu bebé, hechos con amor y los mejores materiales. Calidad y cariño en cada creación.',
          style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildFooterLinks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'NAVEGACIÓN',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        _footerLink('Catálogo', () {
          Navigator.push(context, SmoothPageRoute(page: const CatalogPage()));
        }),
        _footerLink('Sobre Nosotros', null),
        _footerLink('Contacto', () {
          launchUrl(Uri.parse('https://wa.me/50200000000'));
        }),
        _footerLink('Política de Privacidad', null),
      ],
    );
  }

  Widget _footerLink(String text, VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: Text(
          text,
          style: TextStyle(
            color: onTap != null ? Colors.white60 : Colors.white30,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildFooterSocial() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SÍGUENOS',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _socialButton(
              icon: Icons.chat_rounded,
              label: 'WhatsApp',
              color: const Color(0xFF25D366),
              url: 'https://wa.me/50242909548',
            ),
            _socialButton(
              icon: Icons.facebook_rounded,
              label: 'Facebook',
              color: const Color(0xFF1877F2),
              url: 'https://facebook.com/IngenieroChapin2020',
            ),
            _socialButton(
              icon: Icons.camera_alt_rounded,
              label: 'Instagram',
              color: const Color(0xFFE4405F),
              url: 'https://instagram.com/jorgegrullondev',
            ),
            _socialButton(
              icon: Icons.music_note_rounded,
              label: 'TikTok',
              color: const Color(0xFF000000),
              url: 'https://tiktok.com/@grullondev',
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          '¿Tienes preguntas? Escríbenos:',
          style: TextStyle(color: Colors.white38, fontSize: 12),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => launchUrl(Uri.parse('mailto:info@creacionesbaby.com')),
          child: const Text(
            'info@creacionesbaby.com',
            style: TextStyle(
              color: Color(0xFFA78BFA),
              fontSize: 14,
              decoration: TextDecoration.underline,
              decorationColor: Color(0xFFA78BFA),
            ),
          ),
        ),
      ],
    );
  }

  Widget _socialButton({
    required IconData icon,
    required String label,
    required Color color,
    required String url,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () =>
            launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
