import 'package:creacionesbaby/config/app_theme.dart';
import 'package:creacionesbaby/core/providers/cart_provider.dart';
import 'package:creacionesbaby/features/store/catalog/presentation/pages/catalog_page.dart';
import 'package:creacionesbaby/features/store/home/presentation/pages/store_home_page.dart';
import 'package:creacionesbaby/utils/page_transitions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StoreAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showSearch;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const StoreAppBar({super.key, this.showSearch = true, this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 1000;
    return AppBar(
      toolbarHeight: isWide ? 90 : 70,
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 2,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: isWide ? 40 : 0),
        child: Row(
          children: [
            InkWell(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  SmoothPageRoute(page: const StoreHomePage()),
                  (route) => false,
                );
              },
              child: Row(
                children: [
                  const Icon(
                    Icons.child_care,
                    color: AppTheme.primaryGreen,
                    size: 32,
                  ),
                  const SizedBox(width: 8),
                  if (MediaQuery.of(context).size.width > 450)
                    const Text(
                      'Creaciones Baby',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                        color: AppTheme.primaryDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                ],
              ),
            ),
            if (isWide) ...[
              const SizedBox(width: 40),
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
              const Spacer(),
              if (showSearch)
                Container(
                  width: 300,
                  height: 45,
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundSoft,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.1),
                    ),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: '¿Qué buscas para tu bebé?',
                      prefixIcon: Icon(Icons.search, size: 20),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
      actions: [
        if (!isWide && showSearch)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Show mobile search
            },
          ),
        Consumer<CartProvider>(
          builder: (context, cart, child) {
            return Badge(
              label: Text('${cart.itemCount}'),
              isLabelVisible: cart.itemCount > 0,
              backgroundColor: AppTheme.primaryGreen,
              child: IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, size: 26),
                onPressed: () {
                  if (scaffoldKey != null) {
                    scaffoldKey!.currentState?.openEndDrawer();
                  } else {
                    Scaffold.of(context).openEndDrawer();
                  }
                },
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
    String title, {
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: AppTheme.primaryDark.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.primaryDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(90);
}
