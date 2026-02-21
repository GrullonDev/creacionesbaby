import 'package:creacionesbaby/core/providers/auth_provider.dart';
import 'package:creacionesbaby/core/providers/product_provider.dart';
import 'package:creacionesbaby/features/admin/dashboard/presentation/pages/banner_config_page.dart';
import 'package:creacionesbaby/features/admin/orders/presentation/pages/order_list_page.dart';
import 'package:creacionesbaby/features/admin/products/presentation/pages/product_list_page.dart';
import 'package:creacionesbaby/features/auth/presentation/pages/admin_login_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardOverview(), // Internal widget for now
    const ProductListPage(),
    const OrderListPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(
            selectedIcon: Icon(Icons.dashboard),
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.inventory_2),
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Productos',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.shopping_bag),
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Pedidos',
          ),
        ],
      ),
    );
  }
}

class DashboardOverview extends StatelessWidget {
  const DashboardOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configurar Banner',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BannerConfigPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Cerrar Sesión',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Cerrar Sesión'),
                  content: const Text(
                    '¿Estás seguro que deseas cerrar sesión?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await context.read<AuthProvider>().signOut();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminLoginPage(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      child: const Text(
                        'Cerrar Sesión',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, _) {
          final totalProducts = productProvider.products.length;
          final activeProducts = productProvider.products
              .where((p) => p.stock > 0)
              .length;
          final inactiveProducts = totalProducts - activeProducts;

          return RefreshIndicator(
            onRefresh: () => productProvider.loadProducts(),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Summary Cards with gradients
                Row(
                  children: [
                    Expanded(
                      child: _buildGradientCard(
                        title: 'Total Productos',
                        value: '$totalProducts',
                        icon: Icons.inventory_2_outlined,
                        gradientColors: [
                          const Color(0xFF667eea),
                          const Color(0xFF764ba2),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGradientCard(
                        title: 'Activos',
                        value: '$activeProducts',
                        icon: Icons.check_circle_outline,
                        gradientColors: [
                          const Color(0xFF11998e),
                          const Color(0xFF38ef7d),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildGradientCard(
                        title: 'Sin Stock',
                        value: '$inactiveProducts',
                        icon: Icons.warning_amber_outlined,
                        gradientColors: [
                          const Color(0xFFeb3349),
                          const Color(0xFFf45c43),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGradientCard(
                        title: 'Pedidos',
                        value: '—',
                        icon: Icons.shopping_bag_outlined,
                        gradientColors: [
                          const Color(0xFF2193b0),
                          const Color(0xFF6dd5ed),
                        ],
                        subtitle: 'Próximamente',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const Text(
                  'Actividad Reciente',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildActivityItem(
                  'Productos sincronizados',
                  'Al abrir la app',
                  Colors.blue,
                ),
                if (inactiveProducts > 0)
                  _buildActivityItem(
                    '$inactiveProducts producto(s) sin stock',
                    'Revisar inventario',
                    Colors.orange,
                  ),
                _buildActivityItem(
                  'Sistema funcionando correctamente',
                  'Estado: Conectado',
                  Colors.green,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGradientCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> gradientColors,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(Icons.circle, color: color, size: 12),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
