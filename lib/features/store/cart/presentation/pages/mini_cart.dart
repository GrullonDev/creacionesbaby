import 'package:creacionesbaby/config/app_theme.dart';
import 'package:creacionesbaby/core/providers/cart_provider.dart';
import 'package:creacionesbaby/core/providers/product_provider.dart';
import 'package:creacionesbaby/features/store/checkout/presentation/pages/checkout_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MiniCart extends StatelessWidget {
  const MiniCart({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 400,
      backgroundColor: Colors.white,
      child: Consumer<CartProvider>(
        builder: (context, cart, _) {
          return Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tu Carrito (${cart.itemCount})',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Cart Items
              Expanded(
                child: cart.items.isEmpty
                    ? const Center(
                        child: Text(
                          'Tu carrito está vacío',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(24),
                        itemCount: cart.items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 24),
                        itemBuilder: (context, index) {
                          final item = cart.items[index];
                          return Row(
                            children: [
                              // Image
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[100],
                                ),
                                child: item.product.imagePath != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          item.product.imagePath!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return const Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.grey,
                                                );
                                              },
                                        ),
                                      )
                                    : const Icon(
                                        Icons.image,
                                        color: Colors.grey,
                                      ),
                              ),
                              const SizedBox(width: 16),
                              // Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Talla: ${item.size}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Quantity Controls
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey[300]!,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              _QtyBtn(
                                                icon: Icons.remove,
                                                onTap: () =>
                                                    cart.updateQuantity(
                                                      item.id,
                                                      item.quantity - 1,
                                                    ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                    ),
                                                child: Text('${item.quantity}'),
                                              ),
                                              _QtyBtn(
                                                icon: Icons.add,
                                                onTap: () {
                                                  final success = cart
                                                      .updateQuantity(
                                                        item.id,
                                                        item.quantity + 1,
                                                      );
                                                  if (!success) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'No hay suficiente stock para este producto',
                                                        ),
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          'Q${item.totalPrice.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),

              // Dynamic Product Suggestions
              if (cart.items.isNotEmpty) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'También te puede interesar',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Consumer<ProductProvider>(
                        builder: (context, productProvider, _) {
                          // Get products not already in cart
                          final cartProductIds = cart.items
                              .map((i) => i.product.id)
                              .toSet();
                          final suggestions = productProvider.products
                              .where(
                                (p) =>
                                    !cartProductIds.contains(p.id) &&
                                    p.stock > 0,
                              )
                              .take(3)
                              .toList();

                          if (suggestions.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return SizedBox(
                            height: 100,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: suggestions.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final product = suggestions[index];
                                return Container(
                                  width: 250,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey[200]!,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: SizedBox(
                                          width: 60,
                                          height: 60,
                                          child: product.imagePath != null
                                              ? Image.network(
                                                  product.imagePath!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return Container(
                                                          color:
                                                              Colors.grey[100],
                                                          child: const Icon(
                                                            Icons
                                                                .image_not_supported,
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
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              product.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              'Q${product.price.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                          color: AppTheme.primaryGreen,
                                        ),
                                        onPressed: () {
                                          final success = cart.addItem(product);
                                          if (!success) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'No hay suficiente stock para este producto',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  '${product.name} agregado',
                                                ),
                                                duration: const Duration(
                                                  seconds: 1,
                                                ),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],

              // Footer
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Subtotal',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Q${cart.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Impuestos y envío calculados al finalizar compra',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: cart.items.isEmpty
                            ? null
                            : () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CheckoutPage(),
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryDark,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('FINALIZAR COMPRA'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(icon, size: 16, color: Colors.grey[600]),
      ),
    );
  }
}
