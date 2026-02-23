import 'package:creacionesbaby/config/app_theme.dart';
import 'package:creacionesbaby/core/providers/app_config_provider.dart';
import 'package:creacionesbaby/core/providers/cart_provider.dart';
import 'package:creacionesbaby/core/providers/product_provider.dart';
import 'dart:async';
import 'package:creacionesbaby/features/store/catalog/presentation/pages/catalog_page.dart';
import 'package:creacionesbaby/features/store/cart/presentation/pages/mini_cart.dart';
import 'package:creacionesbaby/features/store/catalog/presentation/pages/product_detail_page.dart';
import 'package:creacionesbaby/features/store/home/presentation/pages/contact_page.dart';
import 'package:creacionesbaby/features/store/home/presentation/pages/help_center_page.dart';
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Auto-advance carousel
    _carouselTimer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (!mounted) return;
      final config = context.read<AppConfigProvider>();
      final int count = config.bannerImageUrls.isNotEmpty
          ? config.bannerImageUrls.length
          : (config.bannerImageUrl != null ? 1 : 0);

      if (count <= 1) return;

      if (_currentHeroPage < count - 1) {
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
            _buildGenderCategories(context),
            _buildValuesSection(context),
            _buildArtSection(context),
            _buildFounderSection(context),
            _buildCommitmentSection(context),
            const SizedBox(height: 40),
            _buildTrendingSection(context),
            const SizedBox(height: 80),
            _buildNewsletterSection(context),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return AppBar(
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: isWide ? 40 : 0),
        child: Row(
          children: [
            const Icon(
              Icons.child_care,
              color: AppTheme.primaryGreen,
              size: 28,
            ),
            const SizedBox(width: 8),
            const Text(
              'Creaciones Baby',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                color: AppTheme.primaryDark,
              ),
            ),
            if (isWide) ...[
              const SizedBox(width: 60),
              _navItem(
                context,
                'Shop',
                false,
                onTap: () {
                  Navigator.push(
                    context,
                    SmoothPageRoute(page: const CatalogPage()),
                  );
                },
              ),
              _navItem(
                context,
                'Newborn',
                false,
                onTap: () {
                  Navigator.push(
                    context,
                    SmoothPageRoute(page: const CatalogPage()),
                  );
                },
              ),
              _navItem(context, 'Toys', false),
              _navItem(context, 'About Us', false),
              _navItem(
                context,
                'Contacto',
                false,
                onTap: () {
                  Navigator.push(
                    context,
                    SmoothPageRoute(page: const ContactPage()),
                  );
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (!isWide)
          IconButton(icon: const Icon(Icons.search), onPressed: () {})
        else
          IconButton(
            icon: const Icon(Icons.search, size: 20),
            onPressed: () {},
          ),
        Consumer<CartProvider>(
          builder: (context, cart, child) {
            return Badge(
              label: Text('${cart.itemCount}'),
              isLabelVisible: cart.itemCount > 0,
              backgroundColor: AppTheme.primaryGreen,
              child: IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            );
          },
        ),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _navItem(
    BuildContext context,
    String title,
    bool isActive, {
    VoidCallback? onTap,
    Color? dotColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 32),
      child: InkWell(
        onTap: onTap ?? () {},
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style: TextStyle(
                color: isActive
                    ? AppTheme.primaryGreen
                    : AppTheme.primaryDark.withValues(alpha: 0.6),
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppTheme.pastelGreen.withValues(alpha: 0.2),
      ),
      child: Stack(
        children: [
          if (isWide) ...[
            Positioned(
              left: -30,
              top: -30,
              child: _decorativeCircle(
                180,
                AppTheme.girlPink.withValues(alpha: 0.15),
              ),
            ),
            Positioned(
              right: 150,
              bottom: -50,
              child: _decorativeCircle(
                220,
                AppTheme.boyBlue.withValues(alpha: 0.15),
              ),
            ),
            Positioned(
              left: 300,
              bottom: 40,
              child: _decorativeCircle(
                80,
                AppTheme.unisexYellow.withValues(alpha: 0.2),
              ),
            ),
          ],
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1400),
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 80 : 24,
                vertical: isWide ? 80 : 40,
              ),
              child: isWide
                  ? Row(
                      children: [
                        Expanded(child: _buildHeroText(context, true)),
                        const SizedBox(width: 60),
                        Expanded(child: _buildHeroImage()),
                      ],
                    )
                  : Column(
                      children: [
                        _buildHeroText(context, false),
                        const SizedBox(height: 40),
                        _buildHeroImage(),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _decorativeCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildHeroText(BuildContext context, bool isWide) {
    return Column(
      crossAxisAlignment: isWide
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'DESDE 2015',
            style: TextStyle(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 24),
        RichText(
          textAlign: isWide ? TextAlign.left : TextAlign.center,
          text: TextSpan(
            style: Theme.of(
              context,
            ).textTheme.displayLarge?.copyWith(fontSize: isWide ? 56 : 36),
            children: const [
              TextSpan(text: 'Nuestra Historia:\n'),
              TextSpan(
                text: 'Tejida con Amor y Propósito',
                style: TextStyle(color: AppTheme.primaryGreen),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Creaciones Baby nació en 2015 del deseo de una madre de vestir a sus hijos con la suavidad de un abrazo y la pureza de lo natural. Lo que comenzó como un pequeño taller familiar, hoy es una comunidad dedicada a acompañar a padres en la maravillosa aventura de ver crecer a sus pequeños.',
          textAlign: isWide ? TextAlign.left : TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.primaryDark.withValues(alpha: 0.6),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(context, SmoothPageRoute(page: const CatalogPage()));
          },
          icon: const Icon(Icons.arrow_forward, size: 18),
          label: const Text('Explorar Colección'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroImage() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withValues(alpha: 0.3),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?q=80&w=1200&auto=format&fit=crop',
            fit: BoxFit.cover,
            height: 500,
            width: double.infinity,
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValuesSection(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: isWide ? 80 : 24),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            'Valores que nos definen',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 16),
          Text(
            'Cada hilo y cada botón en Creaciones Baby está pensado para el bienestar de los más pequeños y el futuro de nuestro planeta.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 60),
          Wrap(
            spacing: 30,
            runSpacing: 30,
            alignment: WrapAlignment.center,
            children: [
              _valueCard(
                context,
                Icons.eco_rounded,
                'Sostenibilidad',
                'Utilizamos materiales orgánicos y procesos de producción responsables para cuidar el mundo que heredarán.',
              ),
              _valueCard(
                context,
                Icons.auto_awesome_rounded,
                'Calidad Artesanal',
                'Fusionamos técnicas tradicionales de tejido con diseños contemporáneos, garantizando prendas únicas y duraderas.',
              ),
              _valueCard(
                context,
                Icons.verified_user_rounded,
                'Seguridad Total',
                'Telas hipoalergénicas certificadas que respetan la delicada piel de los bebés, desde recién nacidos hasta los 3 años.',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _valueCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.backgroundSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryDark.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(icon, color: AppTheme.primaryGreen, size: 24),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              color: AppTheme.primaryDark.withValues(alpha: 0.6),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtSection(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: isWide ? 80 : 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: isWide
              ? Row(
                  children: [
                    Expanded(child: _buildArtImages()),
                    const SizedBox(width: 80),
                    Expanded(child: _buildArtText(context)),
                  ],
                )
              : Column(
                  children: [
                    _buildArtImages(),
                    const SizedBox(height: 60),
                    _buildArtText(context),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildArtImages() {
    return SizedBox(
      height: 400,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 300,
              height: 350,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1555252333-9f8e92e65df9?q=80&w=600',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: 0,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 8),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?q=80&w=600',
                  ),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtText(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'El Arte detrás de cada Prenda',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 24),
        Text(
          'No solo fabricamos ropa, creamos legados. Nuestro proceso comienza con la selección del mejor Algodón Pima, reconocido mundialmente por su suavidad excepcional y resistencia.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 32),
        _artFeature(
          Icons.check_circle_rounded,
          'Selección de Fibras',
          'Solo hilos naturales que permiten la transpiración de la piel.',
        ),
        _artFeature(
          Icons.check_circle_rounded,
          'Confección Lenta (Slow Fashion)',
          'Respetamos los tiempos de producción para asegurar acabados perfectos.',
        ),
        _artFeature(
          Icons.check_circle_rounded,
          'Control de Pureza',
          'Cada prenda es revisada minuciosamente antes de llegar a tus manos.',
        ),
      ],
    );
  }

  Widget _artFeature(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryGreen, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppTheme.primaryDark.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFounderSection(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: isWide ? 80 : 24),
      decoration: BoxDecoration(
        color: AppTheme.pastelPink.withValues(alpha: 0.2),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withValues(alpha: 0.05),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: isWide
              ? Row(
                  children: [
                    _buildFounderPhoto(),
                    const SizedBox(width: 60),
                    Expanded(child: _buildFounderQuote(context)),
                  ],
                )
              : Column(
                  children: [
                    _buildFounderPhoto(),
                    const SizedBox(height: 40),
                    _buildFounderQuote(context),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildFounderPhoto() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: AppTheme.backgroundSoft,
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=400',
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildFounderQuote(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.format_quote_rounded,
              color: AppTheme.primaryGreen,
              size: 40,
            ),
            const Spacer(),
            Text(
              'Un Mensaje de nuestra Fundadora',
              style: TextStyle(
                color: AppTheme.primaryDark.withValues(alpha: 0.4),
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '"Como madre, entiendo que cada detalle cuenta. Creaciones Baby nació del deseo de ofrecer a mis hijos lo mejor de nuestras tradiciones textiles con un toque moderno. Hoy nos enorgullece vestir a miles de bebés con esta misma filosofía de amor, calidad y respeto por su piel sensible."',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontStyle: FontStyle.italic,
            fontSize: 18,
            color: AppTheme.primaryDark,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Elena Rodríguez',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(
          'Fundadora & Directora Creativa',
          style: TextStyle(
            color: AppTheme.primaryDark.withValues(alpha: 0.5),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildCommitmentSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.pastelGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: AppTheme.primaryGreen,
              size: 40,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Nuestro Compromiso de Calidad',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: const Text(
              'Garantizamos que cada pieza que sale de nuestro taller es segura, cómoda y está diseñada para durar y pasar de generación en generación.',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 60),
          Wrap(
            spacing: 40,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _commitmentItem(Icons.eco_outlined, '100% Algodón Orgánico'),
              _commitmentItem(Icons.local_shipping_outlined, 'Envío Seguro'),
              _commitmentItem(Icons.favorite_border_rounded, 'Hecho a Mano'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _commitmentItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.primaryGreen, size: 24),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildNewsletterSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: AppTheme.pastelGreen,
      width: double.infinity,
      child: Column(
        children: [
          const Text(
            'Únete a nuestra familia',
            style: TextStyle(
              color: AppTheme.primaryDark,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Recibe noticias de nuestras nuevas colecciones y consejos sobre el cuidado de tu bebé.',
            style: TextStyle(color: AppTheme.primaryMedium, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tu correo electrónico',
                      fillColor: Colors.white,
                      hintStyle: TextStyle(
                        color: AppTheme.primaryDark.withValues(alpha: 0.3),
                      ),
                    ),
                    style: const TextStyle(color: AppTheme.primaryDark),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('SUSCRIBIR'),
                ),
              ],
            ),
          ),
        ],
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
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[100],
                                              child: const Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
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
                                        ? AppTheme.primaryGreen
                                        : Colors.red[300],
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
      color: AppTheme.primaryDark,
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
        _footerLink('Shop', () {
          Navigator.push(context, SmoothPageRoute(page: const CatalogPage()));
        }),
        _footerLink('About Us', null),
        _footerLink('Help Center', () {
          Navigator.push(
            context,
            SmoothPageRoute(page: const HelpCenterPage()),
          );
        }),
        _footerLink('Contacto', () {
          Navigator.push(context, SmoothPageRoute(page: const ContactPage()));
        }),
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

  Widget _buildGenderCategories(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 60, horizontal: isWide ? 80 : 24),
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        children: [
          Text(
            'Explora por Colección',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 48),
          isWide
              ? Row(
                  children: [
                    Expanded(
                      child: _categoryCard(
                        context,
                        'Niña',
                        AppTheme.girlPink,
                        Icons.favorite_rounded,
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: _categoryCard(
                        context,
                        'Niño',
                        AppTheme.boyBlue,
                        Icons.directions_car_rounded,
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: _categoryCard(
                        context,
                        'Unisex',
                        AppTheme.unisexYellow,
                        Icons.auto_awesome_rounded,
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _categoryCard(
                      context,
                      'Niña',
                      AppTheme.girlPink,
                      Icons.favorite_rounded,
                    ),
                    const SizedBox(height: 20),
                    _categoryCard(
                      context,
                      'Niño',
                      AppTheme.boyBlue,
                      Icons.directions_car_rounded,
                    ),
                    const SizedBox(height: 20),
                    _categoryCard(
                      context,
                      'Unisex',
                      AppTheme.unisexYellow,
                      Icons.auto_awesome_rounded,
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _categoryCard(
    BuildContext context,
    String title,
    Color color,
    IconData icon,
  ) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 3),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(context, SmoothPageRoute(page: const CatalogPage()));
        },
        borderRadius: BorderRadius.circular(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: color.withValues(alpha: 0.9)),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryDark,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ver colección',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.primaryDark.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
