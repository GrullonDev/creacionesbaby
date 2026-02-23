import 'package:creacionesbaby/config/app_theme.dart';
import 'package:creacionesbaby/core/providers/cart_provider.dart';
import 'package:creacionesbaby/core/providers/product_provider.dart';
import 'package:creacionesbaby/features/store/checkout/presentation/pages/checkout_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Mi Carrito',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return _buildEmptyCart(context);
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildBreadcrumbs(),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 60 : 20,
                    vertical: 20,
                  ),
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildCartItemsList(context, cart),
                            ),
                            const SizedBox(width: 40),
                            Expanded(
                              flex: 1,
                              child: _buildOrderSummary(context, cart),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _buildCartItemsList(context, cart),
                            const SizedBox(height: 32),
                            _buildOrderSummary(context, cart),
                          ],
                        ),
                ),
                _buildUpsellSection(context),
                _buildFooter(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBreadcrumbs() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: AppTheme.backgroundSoft.withOpacity(0.5),
      child: Row(
        children: [
          Text(
            'Inicio',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
          const SizedBox(width: 8),
          const Text(
            'Tu Carrito',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemsList(BuildContext context, CartProvider cart) {
    const double freeShippingThreshold = 150.0;
    final progress = (cart.totalAmount / freeShippingThreshold).clamp(0.0, 1.0);
    final remaining = freeShippingThreshold - cart.totalAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cesta de Compras (${cart.itemCount} artículos)',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        // Shipping Progress
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.pastelGreen.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    remaining > 0
                        ? '¡Casi tienes envío gratis!'
                        : '¡Felicidades! Tienes envío gratis',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (remaining > 0)
                    Text(
                      'Faltan Q${remaining.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.white,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Items
        ...cart.items.map((item) => _CartItemTile(item: item)),
      ],
    );
  }

  Widget _buildOrderSummary(BuildContext context, CartProvider cart) {
    const shipping = 25.0; // Fixed shipping for demo
    final total = cart.totalAmount > 150
        ? cart.totalAmount
        : cart.totalAmount + shipping;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen del Pedido',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          const Text(
            'CÓDIGO DE DESCUENTO',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Ingresa tu código',
                    fillColor: AppTheme.backgroundSoft,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Código "EXTRA10" aplicado con éxito'),
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryDark,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Aplicar'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _summaryRow(
            'Subtotal (${cart.itemCount} productos)',
            'Q${cart.totalAmount.toStringAsFixed(2)}',
          ),
          _summaryRow(
            'Costo de Envío',
            cart.totalAmount > 150
                ? 'GRATIS'
                : 'Q${shipping.toStringAsFixed(2)}',
            valueColor: cart.totalAmount > 150 ? AppTheme.primaryGreen : null,
          ),
          _summaryRow('Descuento', '-Q0.00', valueColor: Colors.red[400]),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              Text(
                'Q${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CheckoutPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Finalizar Compra',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
          _trustIcon(Icons.verified_user_outlined, 'PAGO SEGURO'),
          _trustIcon(Icons.local_shipping_outlined, 'RASTREO 24/7'),
          _trustIcon(Icons.loop_outlined, 'CAMBIOS FÁCILES'),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _trustIcon(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryMedium),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppTheme.backgroundSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_basket_outlined,
              size: 80,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Tu carrito está vacío',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            '¿Buscas algo especial para tu bebé?',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            ),
            child: const Text('Volver a la Tienda'),
          ),
        ],
      ),
    );
  }

  Widget _buildUpsellSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: AppTheme.backgroundSoft.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Completa el look',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 380,
            child: Consumer<ProductProvider>(
              builder: (context, provider, _) {
                final upsellProducts = provider.products.take(4).toList();
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: upsellProducts.length,
                  itemBuilder: (context, index) => Container(
                    width: 260,
                    margin: const EdgeInsets.only(right: 24),
                    child: _UpsellCard(product: upsellProducts[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.child_care, color: AppTheme.primaryGreen),
              SizedBox(width: 8),
              Text(
                'Creaciones Baby',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Diseñando con ternura para los momentos más especiales de tu bebé.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _socialIcon(Icons.facebook),
              _socialIcon(Icons.camera_alt),
              _socialIcon(Icons.mail_outline),
            ],
          ),
          const SizedBox(height: 40),
          const Text(
            '© 2024 Creaciones Baby. Todos los derechos reservados.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _socialIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Icon(icon, color: AppTheme.primaryMedium, size: 20),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final dynamic item;
  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    Color catColor = AppTheme.backgroundSoft;
    final cat = item.product.category?.toLowerCase() ?? '';
    if (cat.contains('niña'))
      catColor = AppTheme.girlPink;
    else if (cat.contains('niño'))
      catColor = AppTheme.boyBlue;
    else if (cat.contains('unisex'))
      catColor = AppTheme.unisexYellow;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: catColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(12),
            child: item.product.imagePath != null
                ? Image.network(item.product.imagePath!, fit: BoxFit.contain)
                : const Icon(Icons.shopping_bag, color: Colors.grey),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Q${item.product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Talla: ${item.size}',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[200]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 16),
                            onPressed: () =>
                                cart.updateQuantity(item.id, item.quantity - 1),
                          ),
                          Text(
                            '${item.quantity}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 16),
                            onPressed: () =>
                                cart.updateQuantity(item.id, item.quantity + 1),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => cart.removeItem(item.id),
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Colors.grey,
                      ),
                      label: const Text(
                        'Eliminar',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UpsellCard extends StatelessWidget {
  final dynamic product;
  const _UpsellCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: product.imagePath != null
                  ? Image.network(product.imagePath!, fit: BoxFit.contain)
                  : const Icon(Icons.image),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Text(
                  'Q${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
