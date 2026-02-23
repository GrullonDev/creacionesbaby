import 'package:creacionesbaby/config/app_theme.dart';
import 'package:creacionesbaby/features/store/catalog/presentation/pages/catalog_page.dart';
import 'package:creacionesbaby/utils/page_transitions.dart';
import 'package:creacionesbaby/core/models/cart_item_model.dart';
import 'package:flutter/material.dart';

class OrderSuccessPage extends StatelessWidget {
  final String orderId;
  final List<dynamic> items; // Can be CartItem or similar

  const OrderSuccessPage({
    super.key,
    required this.orderId,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundSoft,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Creaciones Baby'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            // Success Icon & Message
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: AppTheme.primaryGreen,
                      size: 80,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '¡Gracias por tu compra!',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Estamos preparando todo con mucho amor para la llegada de tu\npedido. ¡Tu bebé lo va a amar!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, height: 1.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Order Summary Card
            Container(
              constraints: const BoxConstraints(maxWidth: 800),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'NÚMERO DE PEDIDO',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '#$orderId',
                              style: const TextStyle(
                                color: AppTheme.primaryGreen,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'ENTREGA ESTIMADA',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '15 de Octubre - 18 de Octubre',
                              style: TextStyle(
                                color: AppTheme.primaryDark,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Resumen de productos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ...items.map((item) => _buildOrderItem(item)),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.pastelGreen.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.email_outlined,
                                color: AppTheme.primaryGreen,
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Confirmación enviada\nHemos enviado un correo de confirmación con todos los detalles de tu compra a tu email registrado.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.primaryDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Actions
            Center(
              child: Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.local_shipping_outlined),
                    label: const Text('Rastrear mi pedido'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      SmoothPageRoute(page: const CatalogPage()),
                    ),
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: const Text('Seguir comprando'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),

            _buildRelatedProducts(context),

            const SizedBox(height: 60),

            _buildSocialSection(context),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(dynamic item) {
    final cartItem = item as CartItemModel;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.backgroundSoft,
              borderRadius: BorderRadius.circular(12),
              image: cartItem.product.imagePath != null
                  ? DecorationImage(
                      image: NetworkImage(cartItem.product.imagePath!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: cartItem.product.imagePath == null
                ? const Icon(Icons.image, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Talla: ${cartItem.size} | Cantidad: ${cartItem.quantity}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          Text(
            'Q${(cartItem.product.price * cartItem.quantity).toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedProducts(BuildContext context) {
    return Column(
      children: [
        const Text(
          'También te podría gustar...',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 40),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              _relatedCard(
                'Zapatitos Artesanales',
                'Q120.00',
                'https://images.unsplash.com/photo-1560506840-ec148e82a604?q=80&w=400',
              ),
              const SizedBox(width: 24),
              _relatedCard(
                'Mordedor Orgánico',
                'Q85.00',
                'https://images.unsplash.com/photo-1519689680058-324335c77eba?q=80&w=400',
              ),
              const SizedBox(width: 24),
              _relatedCard(
                'Gorro de Punto Osito',
                'Q65.00',
                'https://images.unsplash.com/photo-1543789434-633092576081?q=80&w=400',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _relatedCard(String name, String price, String imageUrl) {
    return SizedBox(
      width: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              imageUrl,
              height: 280,
              width: 280,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: const TextStyle(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppTheme.pastelBlue.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          const Text(
            'Únete a nuestra comunidad',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Comparte una foto de tu pedido con el hashtag #BebeCreaciones y etiquétanos para aparecer en nuestras redes.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.camera_alt_outlined),
                onPressed: () {},
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.facebook_outlined),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
