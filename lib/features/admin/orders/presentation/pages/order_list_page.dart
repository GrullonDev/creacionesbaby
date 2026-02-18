import 'package:flutter/material.dart';

class OrderListPage extends StatelessWidget {
  const OrderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Pedidos'),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        itemCount: 8,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          final status = index % 3 == 0
              ? 'Pendiente'
              : (index % 3 == 1 ? 'Enviado' : 'Entregado');
          final color = index % 3 == 0
              ? Colors.orange
              : (index % 3 == 1 ? Colors.blue : Colors.green);

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              title: Text('Pedido #102$index'),
              subtitle: Text(
                'Cliente: Juan Pérez\nFecha: ${DateTime.now().subtract(Duration(days: index)).toString().split(' ')[0]}',
              ),
              trailing: Chip(
                label: Text(
                  status,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                backgroundColor: color,
              ),
              onTap: () {
                // TODO: Navigate to Order Detail
              },
            ),
          );
        },
      ),
    );
  }
}
