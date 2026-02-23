import 'package:creacionesbaby/config/app_theme.dart';
import 'package:creacionesbaby/core/providers/cart_provider.dart';
import 'package:creacionesbaby/core/providers/order_provider.dart';
import 'package:creacionesbaby/features/store/cart/presentation/pages/order_success_page.dart';
import 'package:creacionesbaby/utils/page_transitions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    _lastNameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _zipCtrl.dispose();
    super.dispose();
  }

  void _submitOrder() async {
    if (_formKey.currentState!.validate()) {
      final orderProvider = context.read<OrderProvider>();
      final cartProvider = context.read<CartProvider>();

      if (cartProvider.items.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Tu carrito está vacío')));
        return;
      }

      final customerName = '${_nameCtrl.text} ${_lastNameCtrl.text}'.trim();

      final success = await orderProvider.createOrder(
        customerEmail: _emailCtrl.text,
        customerName: customerName,
        customerPhone: _phoneCtrl.text,
        shippingAddress:
            '${_addressCtrl.text}, ${_cityCtrl.text}, ${_zipCtrl.text}',
        totalAmount: cartProvider.totalAmount,
        cartItems: cartProvider.items,
      );

      if (success) {
        final items = List.from(cartProvider.items);
        final orderIdValue = orderProvider.lastCreatedOrderId;
        cartProvider.clearCart();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            SmoothPageRoute(
              page: OrderSuccessPage(
                orderId:
                    orderIdValue ??
                    'CB-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                items: items,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${orderProvider.error}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final isDesktop = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
      backgroundColor: AppTheme.backgroundSoft,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(
              Icons.lock_outline,
              size: 20,
              color: AppTheme.primaryGreen,
            ),
            const SizedBox(width: 8),
            Text(
              'PAGO SEGURO',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppTheme.primaryGreen,
                letterSpacing: 2,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProgressBar(),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 80 : 20,
                vertical: 40,
              ),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildCheckoutForm()),
                        const SizedBox(width: 60),
                        Expanded(flex: 2, child: _buildOrderSummary(cart)),
                      ],
                    )
                  : Column(
                      children: [
                        _buildOrderSummary(cart),
                        const SizedBox(height: 32),
                        _buildCheckoutForm(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _stepIcon(Icons.shopping_cart_outlined, 'Carrito', true),
          _stepDivider(true),
          _stepIcon(Icons.local_shipping_outlined, 'Envío', true),
          _stepDivider(false),
          _stepIcon(Icons.payment_outlined, 'Pago', false),
        ],
      ),
    );
  }

  Widget _stepIcon(IconData icon, String label, bool active) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: active ? AppTheme.primaryGreen : Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: active ? Colors.white : Colors.grey[400],
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active ? AppTheme.primaryDark : Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Widget _stepDivider(bool active) {
    return Container(
      width: 60,
      height: 2,
      margin: const EdgeInsets.only(left: 12, right: 12, bottom: 20),
      color: active ? AppTheme.primaryGreen : Colors.grey[200],
    );
  }

  Widget _buildCheckoutForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Información de Contacto'),
        const SizedBox(height: 24),
        _buildGlassCard(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildField(
                  controller: _emailCtrl,
                  label: 'Correo Electrónico',
                  icon: Icons.email_outlined,
                  hint: 'ejemplo@correo.com',
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    if (!v.contains('@')) return 'Email inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                _sectionTitle('Dirección de Envío'),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        controller: _nameCtrl,
                        label: 'Nombre',
                        hint: 'Tu nombre',
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildField(
                        controller: _lastNameCtrl,
                        label: 'Apellido',
                        hint: 'Tu apellido',
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _addressCtrl,
                  label: 'Dirección',
                  icon: Icons.location_on_outlined,
                  hint: 'Calle, número, apartamento...',
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildField(
                        controller: _cityCtrl,
                        label: 'Ciudad / Departamento',
                        hint: 'Guatemala',
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildField(
                        controller: _zipCtrl,
                        label: 'Código Postal',
                        hint: '01010',
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _phoneCtrl,
                  label: 'Teléfono de Contacto',
                  icon: Icons.phone_android_outlined,
                  hint: '1234 5678',
                  isNumeric: true,
                  maxLength: 8,
                  validator: (v) => v!.length < 8 ? 'Mínimo 8 dígitos' : null,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
        _sectionTitle('Método de Envío'),
        const SizedBox(height: 24),
        _buildShippingMethod(),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryDark,
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    bool isNumeric = false,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: AppTheme.primaryMedium,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          maxLength: maxLength,
          inputFormatters: isNumeric
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null
                ? Icon(icon, size: 20, color: AppTheme.primaryMedium)
                : null,
            counterText: '',
          ),
        ),
      ],
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildShippingMethod() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.local_shipping_outlined, color: AppTheme.primaryGreen),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Envío Estándar (2-3 días hábiles)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Entregas a toda la república de Guatemala',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text('Q25.00', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cart) {
    const double shipping = 25.0;
    final total = cart.totalAmount + shipping;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDark.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tu Pedido',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: ListView.separated(
              itemCount: cart.items.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.white10),
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: item.product.imagePath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  item.product.imagePath!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                Icons.shopping_bag,
                                color: Colors.white24,
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                            ),
                            Text(
                              'Q${item.product.price} x ${item.quantity}',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Q${(item.product.price * item.quantity).toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          _summaryRow('Subtotal', 'Q${cart.totalAmount.toStringAsFixed(2)}'),
          _summaryRow('Envío', 'Q${shipping.toStringAsFixed(2)}'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: Colors.white10),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total a pagar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Q${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppTheme.primaryGreen,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          _buildSubmitButton(),
          const SizedBox(height: 24),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified, color: AppTheme.primaryGreen, size: 16),
              SizedBox(width: 8),
              Text(
                'Pago contra entrega disponible',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final isLoading = context.watch<OrderProvider>().isLoading;
    return ElevatedButton(
      onPressed: isLoading ? null : _submitOrder,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryGreen,
        minimumSize: const Size(double.infinity, 64),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        shadowColor: AppTheme.primaryGreen.withOpacity(0.3),
      ),
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'FINALIZAR PEDIDO',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
    );
  }
}
