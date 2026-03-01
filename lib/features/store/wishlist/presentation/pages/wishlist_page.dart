import 'package:creacionesbaby/config/app_theme.dart';
import 'package:creacionesbaby/core/providers/wishlist_provider.dart';
import 'package:creacionesbaby/core/providers/cart_provider.dart';
import 'package:creacionesbaby/core/widgets/store_app_bar.dart';
import 'package:creacionesbaby/features/store/catalog/presentation/pages/product_detail_page.dart';
import 'package:creacionesbaby/utils/page_transitions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const StoreAppBar(isSearchVisible: false),
      body: Consumer<WishlistProvider>(
        builder: (context, wishlist, child) {
          if (wishlist.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Tu lista de deseos está vacía',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '¡Guarda los productos que más te gusten!',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text('Explorar productos'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mis Favoritos',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '${wishlist.items.length} productos guardados',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 250,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 24,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: wishlist.items.length,
                  itemBuilder: (context, index) {
                    final product = wishlist.items[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        SmoothPageRoute(
                          page: ProductDetailPage(product: product),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  image: product.imagePath != null
                                      ? DecorationImage(
                                          image: NetworkImage(
                                            product.imagePath!,
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                  color: AppTheme.backgroundSoft,
                                ),
                                child: product.imagePath == null
                                    ? const Center(
                                        child: Icon(
                                          Icons.image,
                                          color: Colors.grey,
                                        ),
                                      )
                                    : null,
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: GestureDetector(
                                  onTap: () => wishlist.toggleFavorite(product),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.favorite,
                                      size: 16,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Q${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                context.read<CartProvider>().addItem(product);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Agregado al carrito'),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryGreen,
                                side: const BorderSide(
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                              child: const Text('Agregar'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
