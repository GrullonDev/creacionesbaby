import 'package:creacionesbaby/config/app_theme.dart';
import 'package:creacionesbaby/core/providers/cart_provider.dart';
import 'package:creacionesbaby/features/store/catalog/presentation/pages/catalog_page.dart';
import 'package:creacionesbaby/features/store/home/presentation/pages/store_home_page.dart';
import 'package:creacionesbaby/core/providers/product_provider.dart';
import 'package:creacionesbaby/features/store/profile/presentation/pages/user_profile_page.dart';
import 'package:creacionesbaby/features/auth/presentation/pages/admin_login_page.dart';
import 'package:creacionesbaby/core/providers/auth_provider.dart';
import 'package:creacionesbaby/utils/page_transitions.dart';
import 'package:creacionesbaby/core/providers/wishlist_provider.dart';
import 'package:creacionesbaby/features/store/wishlist/presentation/pages/wishlist_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StoreAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isSearchVisible;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const StoreAppBar({super.key, this.isSearchVisible = true, this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 1250;
    final isMedium = screenWidth > 600;

    return Material(
      color: Colors.white,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: isWide ? 80 : 65,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isWide ? 24 : 12),
              child: Row(
                children: [
                  // ── Logo / Brand ──────────────────────────────────────────
                  InkWell(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        SmoothPageRoute(page: const StoreHomePage()),
                        (route) => false,
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            height: 60,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.child_care,
                                  color: AppTheme.primaryGreen,
                                  size: 28,
                                ),
                          ),
                          if (isMedium) ...[
                            const SizedBox(width: 12),
                            const Text(
                              'Creaciones Baby',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 19,
                                color: AppTheme.primaryDark,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // ── Navigation categories (desktop only) ───────────────────
                  if (isWide) ...[
                    const SizedBox(width: 20),
                    _navItem(
                      context,
                      'Recién Nacido',
                      icon: Icons.baby_changing_station_outlined,
                      onTap: () => Navigator.push(
                        context,
                        SmoothPageRoute(page: const CatalogPage()),
                      ),
                    ),
                    _navItem(
                      context,
                      'Ropa',
                      icon: Icons.checkroom_outlined,
                      onTap: () => Navigator.push(
                        context,
                        SmoothPageRoute(page: const CatalogPage()),
                      ),
                    ),
                    _navItem(
                      context,
                      'Juguetes',
                      icon: Icons.toys_outlined,
                      onTap: () => Navigator.push(
                        context,
                        SmoothPageRoute(page: const CatalogPage()),
                      ),
                    ),
                    _navItem(
                      context,
                      'Accesorios',
                      icon: Icons.shopping_bag_outlined,
                      onTap: () => Navigator.push(
                        context,
                        SmoothPageRoute(page: const CatalogPage()),
                      ),
                    ),
                    _navItem(
                      context,
                      'Ofertas',
                      icon: Icons.local_offer_outlined,
                      onTap: () => Navigator.push(
                        context,
                        SmoothPageRoute(page: const CatalogPage()),
                      ),
                    ),
                  ],

                  // ── Spacer pushes right-side content ─────────────────────
                  const Spacer(),

                  // ── Search bar (desktop) ──────────────────────────────────
                  if (isWide && isSearchVisible)
                    Container(
                      width: 210,
                      height: 42,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundSoft,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.15),
                        ),
                      ),
                      child: TextField(
                        onSubmitted: (value) {
                          context.read<ProductProvider>().loadProducts(
                            query: value,
                          );
                          if (ModalRoute.of(context)?.settings.name !=
                              '/catalog') {
                            Navigator.push(
                              context,
                              SmoothPageRoute(page: const CatalogPage()),
                            );
                          }
                        },
                        decoration: InputDecoration(
                          hintText: '¿Qué buscas para tu bebé?',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                          prefixIcon: const Icon(Icons.search, size: 18),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),

                  // ── Search icon (mobile) ──────────────────────────────────
                  if (!isWide && isSearchVisible)
                    IconButton(
                      icon: const Icon(
                        Icons.search,
                        color: AppTheme.primaryDark,
                      ),
                      onPressed: () {
                        // Implement a simple search dialog or bottom sheet for mobile
                        showSearch(
                          context: context,
                          delegate: ProductSearchDelegate(),
                        );
                      },
                    ),

                  // ── Profile icon ───────────────────────────────────────────
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) => IconButton(
                      icon: Icon(
                        auth.currentUser != null
                            ? Icons.person_rounded
                            : Icons.person_outline_rounded,
                        size: 26,
                        color: auth.currentUser != null
                            ? AppTheme.primaryGreen
                            : AppTheme.primaryDark,
                      ),
                      onPressed: () {
                        if (auth.currentUser != null) {
                          Navigator.push(
                            context,
                            SmoothPageRoute(page: const UserProfilePage()),
                          );
                        } else {
                          Navigator.push(
                            context,
                            SmoothPageRoute(page: const AdminLoginPage()),
                          );
                        }
                      },
                    ),
                  ),

                  // ── Wishlist icon ───────────────────────────────────────
                  Consumer<WishlistProvider>(
                    builder: (context, wishlist, _) => Badge(
                      label: Text('${wishlist.items.length}'),
                      isLabelVisible: wishlist.items.isNotEmpty,
                      backgroundColor: Colors.red,
                      child: IconButton(
                        icon: const Icon(
                          Icons.favorite_border,
                          size: 26,
                          color: AppTheme.primaryDark,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            SmoothPageRoute(page: const WishlistPage()),
                          );
                        },
                      ),
                    ),
                  ),

                  // ── Cart icon ─────────────────────────────────────────────
                  Consumer<CartProvider>(
                    builder: (context, cart, _) => Badge(
                      label: Text('${cart.itemCount}'),
                      isLabelVisible: cart.itemCount > 0,
                      backgroundColor: AppTheme.primaryGreen,
                      child: IconButton(
                        icon: const Icon(
                          Icons.shopping_cart_outlined,
                          size: 26,
                          color: AppTheme.primaryDark,
                        ),
                        onPressed: () {
                          if (scaffoldKey != null) {
                            scaffoldKey!.currentState?.openEndDrawer();
                          } else {
                            Scaffold.of(context).openEndDrawer();
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    String title, {
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 17,
              color: AppTheme.primaryDark.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 5),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.primaryDark,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

class ProductSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts(query: query);
      close(context, null);
      if (ModalRoute.of(context)?.settings.name != '/catalog') {
        Navigator.push(context, SmoothPageRoute(page: const CatalogPage()));
      }
    });
    return const Center(child: CircularProgressIndicator());
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(child: Text('Busca productos por nombre...'));
  }
}
