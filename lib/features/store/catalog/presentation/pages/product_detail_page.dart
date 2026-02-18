import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Producto Detalle')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              color: Colors.grey[300],
              child: const Center(child: Icon(Icons.image, size: 100)),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nombre del Producto',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '\$45.00',
                    style: TextStyle(fontSize: 20, color: Colors.green),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Descripción del producto goes here. Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Text(
                        'Talla:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('S'),
                        selected: false,
                        onSelected: (val) {},
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('M'),
                        selected: true,
                        onSelected: (val) {},
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('L'),
                        selected: false,
                        onSelected: (val) {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('AÑADIR AL CARRITO'),
          ),
        ),
      ),
    );
  }
}
