import 'package:creacionesbaby/core/models/order_model.dart';
import 'package:creacionesbaby/core/providers/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gestión de Pedidos'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<OrderProvider>().fetchOrders();
              },
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Todos'),
              Tab(text: 'Pendientes'),
              Tab(text: 'Enviados'),
              Tab(text: 'Entregados'),
            ],
          ),
        ),
        body: Consumer<OrderProvider>(
          builder: (context, orderProvider, child) {
            if (orderProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (orderProvider.error != null) {
              return Center(
                child: Text(
                  'Error: ${orderProvider.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (orderProvider.orders.isEmpty) {
              return const Center(
                child: Text('No hay pedidos realizados aún.'),
              );
            }

            return TabBarView(
              children: [
                _buildOrderList(orderProvider.orders, orderProvider),
                _buildOrderList(
                  orderProvider.orders
                      .where((o) => o.status.toLowerCase() == 'pendiente')
                      .toList(),
                  orderProvider,
                ),
                _buildOrderList(
                  orderProvider.orders
                      .where((o) => o.status.toLowerCase() == 'enviado')
                      .toList(),
                  orderProvider,
                ),
                _buildOrderList(
                  orderProvider.orders
                      .where((o) => o.status.toLowerCase() == 'entregado')
                      .toList(),
                  orderProvider,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders, OrderProvider orderProvider) {
    if (orders.isEmpty) {
      return const Center(child: Text('No hay pedidos en esta categoría.'));
    }

    return ListView.builder(
      itemCount: orders.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final order = orders[index];

        Color statusColor;
        switch (order.status.toLowerCase()) {
          case 'enviado':
            statusColor = Colors.blue;
            break;
          case 'entregado':
            statusColor = Colors.green;
            break;
          case 'cancelado':
            statusColor = Colors.red;
            break;
          case 'pendiente':
          default:
            statusColor = Colors.orange;
        }

        final dateStr = order.createdAt != null
            ? '${order.createdAt!.day}/${order.createdAt!.month}/${order.createdAt!.year}'
            : 'Fecha desconocida';

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text('Pedido #${order.id?.substring(0, 8)}'),
            subtitle: Text(
              'Cliente: ${order.customerName}\n'
              'Total: Q${order.totalAmount.toStringAsFixed(2)} - $dateStr',
            ),
            trailing: Chip(
              label: Text(
                order.status.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
              backgroundColor: statusColor,
            ),
            onTap: () {
              _showOrderDetails(context, order, orderProvider);
            },
          ),
        );
      },
    );
  }

  void _showOrderDetails(
    BuildContext context,
    OrderModel order,
    OrderProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Detalle de Pedido #${order.id?.substring(0, 8)}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Cliente: ${order.customerName}'),
                Text('Email: ${order.customerEmail}'),
                Text('Teléfono: ${order.customerPhone}'),
                Text('Dirección: ${order.shippingAddress}'),
                const Divider(),
                const Text(
                  'Productos:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...order.items.map<Widget>(
                  (item) => Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      '- ${item.quantity}x ${item.productName} (Talla: ${item.size}) - Q${item.totalPrice}',
                    ),
                  ),
                ),
                const Divider(),
                Text(
                  'Total: Q${order.totalAmount}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                provider.updateOrderStatus(order.id!, 'enviado');
                Navigator.pop(context);
              },
              child: const Text('Marcar Enviado'),
            ),
            TextButton(
              onPressed: () {
                provider.updateOrderStatus(order.id!, 'entregado');
                Navigator.pop(context);
              },
              child: const Text('Marcar Entregado'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
